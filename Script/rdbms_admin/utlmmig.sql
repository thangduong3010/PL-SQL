Rem
Rem $Header: rdbms/admin/utlmmig.sql /st_rdbms_11.2.0/2 2013/07/02 00:23:42 traney Exp $
Rem
Rem utlmmig.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      utlmmig.sql - Mini MIGration for Bootstrap objects
Rem
Rem    DESCRIPTION
Rem      This mini migration script replaces obj$ and user$ with new
Rem      definitions with new indexes.
Rem
Rem      Mini Migration is done in the following steps:
Rem      0. Logminer Dictionary Conditional Special Build
Rem      1. Create the new objects obj$mig, user$mig and its indexes.
Rem      2. Prepare the bootstrap sql text for the new objects
Rem      ***
Rem      *** Any failure between step 3 and 8 will cause this script to quit
Rem      ***
Rem      3. Copy data from old table to the new table. From now on, we should
Rem         not do any more DDL.
Rem      4. Swap the name of the new tables and old tables in obj$mig.
Rem      5. Remove the old object entries in bootstrap$mig.
Rem      6. Insert the new object entries in bootstrap$mig.
Rem      7. Update dependency$ directly
Rem      8. Forward all privilege grants from obj$/user$ to obj$mig/user$mig
Rem      ***
Rem      *** From this point on, ignore errors so we do shutdown the database
Rem      ***
Rem      9. Swap bootstrap$mig with bootstrap$
Rem      10. SHUTDOWN THE DATABASE..
Rem
Rem    NOTES
Rem      If this script fails, then it must be rerun while the database is
Rem      opened in UPGRADE mode. Attempts to start the database in normal
Rem      mode will result in ORA-39714.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    traney      06/28/13 - 17026653: backport of traney_lrg-7149217
Rem    jerrede     06/21/12 - Backport jerrede_bug-13719893 from main
Rem    akruglik    02/06/09 - DBMS_STATS (used in this script) now depends on
Rem                           DBMS_UTILITY which may have gotten invalidated by
Rem                           some preceeding DDL statement, so package state
Rem                           needs to be cleared to avoid ORA-04068
Rem    achoi       11/20/08 - bootstrpa object need to be created in SYSTEM
Rem                           tablespace
Rem    achoi       05/30/08 - bug7140173
Rem    achoi       04/03/08 - change i_obj2 ordering to restore partition
Rem                           performance
Rem    achoi       07/17/07 - bug6247730 - fix "CURRENT_EDITION_OBJ"
Rem    achoi       05/14/07 - redefine "_CURRENT_EDITION_OBJ" properly
Rem    achoi       02/20/07 - add i_obj5
Rem    achoi       05/14/07 - replace "_CURRENT_EDITION_OBJ"
Rem    dvoss       02/19/07 - move whenever sqlerror
Rem    abrown      02/09/07 - Add Logminer Dictionary build
Rem    achoi       12/07/06 - invalidate those depends on USER$
Rem    achoi       11/15/06 - Created
Rem

/*
 * Redefine "_CURRENT_EDITION_OBJ" with its proper definition.
 * It was defined as OBJ$ in a100200.sql to speed up dict view query during
 * component upgrade since obj$/user$ indexes were not available.
 */
create or replace view "_CURRENT_EDITION_OBJ"
 (    obj#,
      dataobj#,
      defining_owner#,
      name,
      namespace,
      subname,
      type#,
      ctime,
      mtime,
      stime,
      status,
      remoteowner,
      linkname,
      flags,
      oid$,
      spare1,
      spare2,
      spare3,
      spare4,
      spare5,
      spare6,
      owner#,
      defining_edition
 )
as
select o.*,
       o.spare3, 
       case when (o.type# not in (4,5,7,8,9,10,11,12,13,14,22,87) or
                  bitand(u.spare1, 16) = 0) then
         null
       when (u.type# = 2) then
        (select eo.name from obj$ eo where eo.obj# = u.spare2)
       else
        'ORA$BASE'
       end
from obj$ o, user$ u
where o.owner# = u.user#
  and (   /* non-versionable object */
          (   o.type# not in (4,5,7,8,9,10,11,12,13,14,22,87,88)
           or bitand(u.spare1, 16) = 0)
          /* versionable object visible in current edition */
       or (    o.type# in (4,5,7,8,9,10,11,12,13,14,22,87)
           and (   (u.type# <> 2 and 
                    sys_context('userenv', 'current_edition_name') = 'ORA$BASE')
                or (u.type# = 2 and
                    u.spare2 = sys_context('userenv', 'current_edition_id'))
                or exists (select 1 from obj$ o2, user$ u2
                           where o2.type# = 88
                             and o2.dataobj# = o.obj#
                             and o2.owner# = u2.user#
                             and u2.type#  = 2
                             and u2.spare2 = 
                                  sys_context('userenv', 'current_edition_id'))
               )
          )
      )
/


/*
 * We've started the bootstrap$ upgrade. Insert a row 'BOOTSTRAP_UPGRADE_ERROR'
 * into PROPS$ to indicate that. This row will be removed after we've completed
 * step 9. If something failed in between, we'll see this row when we bring up
 * the db. We'll instruct the user to startup in upgrade mode and rerun this
 * script if the row exists in PROPS$.
 */


/*****************************************************************************/
/*
 * We need to exit immediately on any error.  If this script fails, the
 * script must be run again from the beginning.
 */
WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK


/*
 * Step 0 - Logminer Dictionary Conditional Special Build
 *
 *    A Logminer Dictionary Build specific to utlmmig is conditionally
 *    invoked here.   If supplemental logging is not enabled for this
 *    database this will be a NOP.  If a prior invocation of utlmmig
 *    failed after the a complete, final build and before the successful
 *    swap of bootstrap$mig, Logminer will not have the correct obj#s for
 *    OBJ$ and USER$.  This build will communicate the these new obj#s to
 *    Logminer.
 */

DECLARE
  LS_Special_2            CONSTANT NUMBER := 10;
  LOCbldlogid             VARCHAR2(22) := NULL;
  LOCLockDownScn          NUMBER;
  UpgradeErrorCount       NUMBER := 0;
  rowcnt                  NUMBER;
BEGIN

  -- See if there is already a BOOTSTRAP_UPGRADE_ERROR in PROPS$
  select count(*) into UpgradeErrorCount
  from sys.props$
  where name = 'BOOTSTRAP_UPGRADE_ERROR';

  IF (0 = UpgradeErrorCount) THEN
    -- If no BOOTSTRAP_UPGRADE_ERROR in PROPS$, insert one.
    insert into props$ (name, value$, comment$)
    values ('BOOTSTRAP_UPGRADE_ERROR', NULL,
            'startup the db in upgrade mode and rerun utlmmig.sql');
  ELSE
    -- If there is a BOOTSTRAP_UPGRADE_ERROR in PROPS$ it means that this
    -- is a second try.  We may need a special Logminer Dictionary build
    -- to ensure that Logminer has correct obj# for obj$ and user$.
    SELECT COUNT(1) into rowcnt
    FROM SYS.V$DATABASE V
    WHERE V.LOG_MODE = 'ARCHIVELOG' and
          V.SUPPLEMENTAL_LOG_DATA_MIN != 'NO' and
          exists (select 1 from sys.props$
                  where name = 'LOGMNR_BOOTSTRAP_UPGRADE_ERROR');
    IF 0 != rowcnt THEN
      -- Logminer may be mining this redo stream, and we failed in a bad
      -- place on the first try, so we must build again.
      sys.dbms_logmnr_internal.DO_INT_BUILD(build_op=>LS_Special_2,
                                            dictionary_filename=>NULL,
                                            dictionary_location=>NULL,
                                            bldlogid_initxid=>LOCbldlogid,
                                            LockDownScn=>LOCLockDownScn,
                                            release_locks=>FALSE);
      delete from sys.props$
             where name = 'LOGMNR_BOOTSTRAP_UPGRADE_ERROR';
      commit;
    END IF;
  END IF;
END;
/

commit
/


/*****************************************************************************/
/*
 * Step 1 - Create the new replacement tables for the existing bootstrap table.
 *
 * Currently, we're creating replacement tables for:
 *   OBJ$
 *   USER$
 * We'll create indexes for each of the table we created. Note that existing
 * indexes on the old table won't carry over to the new tables.
 *
 * Currently, we're creating indexes:
 *   OBJ$MIG  - I_OBJ_MIG1, I_OBJ_MIG2, I_OBJ_MIG3, I_OBJ_MIG4, I_OBJ_MIG5
 *   USER$MIG - I_USER_MIG1, I_USER_MIG2
 */
/*****************************************************************************/
drop table obj$mig
/
create table obj$mig                                         /* object table */
( obj#          number not null,                            /* object number */
  dataobj#      number,                          /* data layer object number */
  owner#        number not null,                        /* owner user number */
  name          varchar2(30) not null,                  /* object name */
  namespace     number not null,         /* namespace of object (see KQD.H): */
 /* 1 = TABLE/PROCEDURE/TYPE, 2 = BODY, 3 = TRIGGER, 4 = INDEX, 5 = CLUSTER, */
                                                  /* 8 = LOB, 9 = DIRECTORY, */
  /* 10 = QUEUE, 11 = REPLICATION OBJECT GROUP, 12 = REPLICATION PROPAGATOR, */
                                     /* 13 = JAVA SOURCE, 14 = JAVA RESOURCE */
                                                 /* 58 = (Data Mining) MODEL */
  subname       varchar2(30),               /* subordinate to the name */
  type#         number not null,                 /* object type (see KQD.H): */
  /* 1 = INDEX, 2 = TABLE, 3 = CLUSTER, 4 = VIEW, 5 = SYNONYM, 6 = SEQUENCE, */
             /* 7 = PROCEDURE, 8 = FUNCTION, 9 = PACKAGE, 10 = NON-EXISTENT, */
              /* 11 = PACKAGE BODY, 12 = TRIGGER, 13 = TYPE, 14 = TYPE BODY, */
      /* 19 = TABLE PARTITION, 20 = INDEX PARTITION, 21 = LOB, 22 = LIBRARY, */
                                             /* 23 = DIRECTORY , 24 = QUEUE, */
    /* 25 = IOT, 26 = REPLICATION OBJECT GROUP, 27 = REPLICATION PROPAGATOR, */
    /* 28 = JAVA SOURCE, 29 = JAVA CLASS, 30 = JAVA RESOURCE, 31 = JAVA JAR, */
                 /* 32 = INDEXTYPE, 33 = OPERATOR , 34 = TABLE SUBPARTITION, */
                                                  /* 35 = INDEX SUBPARTITION */
                                                 /* 82 = (Data Mining) MODEL */
                             /* 92 = OLAP PRIMARY DIMENSION,  93 = OLAP CUBE */
                          /* 94 = OLAP MEASURE FOLDER, 95 = OLAP INTERACTION */
  ctime         date not null,                       /* object creation time */
  mtime         date not null,                      /* DDL modification time */
  stime         date not null,          /* specification timestamp (version) */
  status        number not null,            /* status of object (see KQD.H): */
                                     /* 1 = VALID/AUTHORIZED WITHOUT ERRORS, */
                          /* 2 = VALID/AUTHORIZED WITH AUTHORIZATION ERRORS, */
                            /* 3 = VALID/AUTHORIZED WITH COMPILATION ERRORS, */
                         /* 4 = VALID/UNAUTHORIZED, 5 = INVALID/UNAUTHORIZED */
  remoteowner   varchar2(30),     /* remote owner name (remote object) */
  linkname      varchar2(128),             /* link name (remote object) */
  flags         number,               /* 0x01 = extent map checking required */
                                      /* 0x02 = temporary object             */
                                      /* 0x04 = system generated object      */
                                      /* 0x08 = unbound (invoker's rights)   */
                                      /* 0x10 = secondary object             */
                                      /* 0x20 = in-memory temp table         */
                                      /* 0x80 = dropped table (RecycleBin)   */
                                      /* 0x100 = synonym VPD policies        */
                                      /* 0x200 = synonym VPD groups          */
                                      /* 0x400 = synonym VPD context         */
  oid$          raw(16),        /* OID for typed table, typed view, and type */
  spare1        number,                      /* sql version flag: see kpul.h */
  spare2        number,                             /* object version number */
  spare3        number,                                        /* base user# */
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        date
)
  tablespace system
  storage (initial 10k next 100k maxextents unlimited pctincrease 0)
/

create unique index i_obj_mig1 on obj$mig(obj#, owner#, type#)
 tablespace system
/
create unique index i_obj_mig2 on obj$mig(owner#, name, namespace, remoteowner,
linkname, subname, type#, spare3, obj#)
tablespace system
/
create index i_obj_mig3 on obj$mig(oid$) tablespace system
/
create index i_obj_mig4 on obj$mig(dataobj#, type#, owner#) tablespace system
/
create unique index i_obj_mig5 on obj$mig(spare3, name, namespace, type#,
owner#, remoteowner, linkname, subname, obj#) tablespace system
/


drop table user$mig
/
create table user$mig                                          /* user table */
( user#         number not null,                   /* user identifier number */
  name          varchar2(30) not null,                 /* name of user */
  type#         number not null,                       /* 0 = role, 1 = user */
  password      varchar2(30),                    /* encrypted password */
  datats#       number not null, /* default tablespace for permanent objects */
  tempts#       number not null,  /* default tablespace for temporary tables */
  ctime         date not null,                 /* user account creation time */
  ptime         date,                                /* password change time */
  exptime       date,                     /* actual password expiration time */
  ltime         date,                         /* time when account is locked */
  resource$     number not null,                        /* resource profile# */
  audit$        varchar2(38),                    /* user audit options */
  defrole       number not null,                  /* default role indicator: */
               /* 0 = no roles, 1 = all roles granted, 2 = roles in defrole$ */
  defgrp#       number,                                /* default undo group */
  defgrp_seq#   number,               /* global sequence number for  the grp *
  spare         varchar2(30),                   /* reserved for future */
  astatus       number default 0 not null,          /* status of the account */
                /* 1 = Locked, 2 = Expired, 3 = Locked and Expired, 0 - open */
  lcount        number default 0 not null, /* count of failed login attempts */
  defschclass   varchar2(30),                /* initial consumer group */
  ext_username  varchar2(4000),                     /* external username */
                             /* also as base schema name for adjunct schemas */
  spare1        number, /* used for schema level supp. logging: see ktscts.h */
  spare2        number,      /* used to store edition id for adjunct schemas */
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        date
)
cluster c_user#(user#)
/
create unique index i_user_mig1 on user$mig(name) tablespace system
/
create unique index i_user_mig2 on user$mig(user#, type#, spare1, spare2)
 tablespace system
/

drop table bootstrap$mig
/
create table bootstrap$mig
( line#         number not null,                       /* statement order id */
  obj#          number not null,                            /* object number */
  sql_text      varchar2(4000) not null)                        /* statement */
tablespace system
/


/*****************************************************************************/
/* Step 2 - Prepare the bootstrap sql text for the new objects
*/
/*****************************************************************************/
/* This table stores the new obj bootstrap sql text. */
drop table bootstrap$tmpstr;
create table bootstrap$tmpstr
( line#         number not null,                       /* statement order id */
  obj#          number not null,                            /* object number */
  sql_text      varchar2(4000) not null)                        /* statement */
/

declare
  pl_objtxt       varchar2(4000);   /* bootstrap$.sql_text for the new obj */
  pl_obj_num      number;           /* obj# of the new obj */
  pl_line_num number;               /* line# in bootstrap$ for the new obj */

  /* Get Obj Number in OBJ$
     Given the obj name and namespace, return the obj# in obj$.
  */
  function get_obj_num(pl_objname varchar2, pl_nmspc number) return number
  is
    pl_obn number;
  begin
    select obj# into pl_obn from sys.obj$
      where owner#=0 and name=pl_objname and namespace=pl_nmspc
        and linkname is null and subname is null;

    return pl_obn;
  end;

  /* Get Line Number in bootstrap$
     Given the obj name and namespace, returns the line# in boostrap$. If the
     obj doesn't exists, then return null.
  */
  function get_line_num(pl_objname varchar2, pl_nmspc number) return number
  is
    pl_bln number;
  begin
    select b.line# into pl_bln
    from sys.bootstrap$ b, sys.obj$ o
    where o.owner#    = 0
      and o.name      = pl_objname
      and o.obj#      = b.obj#
      and o.namespace = pl_nmspc;

    return pl_bln;
  exception
    when NO_DATA_FOUND then
    return NULL;
  end;

  /* Storage text generation
     The bootstrap$ sql_text requires the DDL to provide the storage 
     parameters. The following function will generate the storage
     parameter for table creation and index creation, given the obj# as input.
  */
  -- generate storage parameter
  --   it requires some info from tab$/ind$, seg$, ts$
  function gen_storage(pl_objnum number, pl_objtype varchar2) return varchar2
  is
    pl_text        varchar2(4000);
    pl_pctf        number;
    pl_pctused     number;
    pl_initrans    number;
    pl_maxtrans    number;
    pl_file_num    number;
    pl_block_num   number;
    pl_ts_num      number;
    pl_tab_num     number;
    pl_initial     number;
    pl_next        number;
    pl_minext      number;
    pl_maxext      number;
    pl_pctinc      number;
    pl_block_size  number;
  begin
    if (pl_objtype = 'TABLE') then
      -- info from tab$
      select pctfree$, pctused$, initrans, maxtrans, file#, block#, ts#
        into pl_pctf,     pl_pctused,   pl_initrans, pl_maxtrans, 
             pl_file_num, pl_block_num, pl_ts_num
      from sys.tab$
      where obj# = pl_objnum;
    elsif (pl_objtype = 'CLUSTER TABLE') then
      select tab# 
        into pl_tab_num
      from sys.tab$
      where obj# = pl_objnum;
    elsif (pl_objtype = 'INDEX') then
      -- info from ind$
      select pctfree$, initrans, maxtrans, file#, block#, ts#
        into pl_pctf,     pl_initrans,  pl_maxtrans, 
             pl_file_num, pl_block_num, pl_ts_num
      from ind$ where obj# = pl_objnum;
    end if;

    if (pl_objtype != 'CLUSTER TABLE') then
      -- info from seg$
      select iniexts,    minexts,   maxexts,   extsize, extpct
        into pl_initial, pl_minext, pl_maxext, pl_next, pl_pctinc
      from sys.seg$
      where file#  = pl_file_num
        and block# = pl_block_num
        and ts#    = pl_ts_num;

      -- info from ts$
      select blocksize into pl_block_size from sys.ts$ where ts# = pl_ts_num;
      pl_initial := pl_initial * pl_block_size;
      pl_next    := pl_next    * pl_block_size;
    end if;

    if (pl_objtype = 'TABLE') then
      -- generate the table storage text
      pl_text := ' PCTFREE '  || pl_pctf     || ' PCTUSED ' || pl_pctused  ||
                 ' INITRANS ' || pl_initrans || ' MAXTRANS '|| pl_maxtrans ||
                 ' STORAGE (  INITIAL '     || pl_initial ||
                            ' NEXT '        || pl_next    ||
                            ' MINEXTENTS '  || pl_minext  ||
                            ' MAXEXTENTS '  || pl_maxext  ||
                            ' PCTINCREASE ' || pl_pctinc  ||
                            ' OBJNO '       || pl_obj_num ||
                            ' EXTENTS (FILE '  || pl_file_num  ||
                                     ' BLOCK ' || pl_block_num ||'))';
    elsif (pl_objtype = 'CLUSTER TABLE') then
      pl_text := ' STORAGE (  OBJNO '|| pl_obj_num ||
                            ' TABNO '|| pl_tab_num ||
                 ') CLUSTER C_USER#(USER#)';
    elsif (pl_objtype = 'INDEX') then
      -- generate the index storage text
      pl_text := ' PCTFREE '  || pl_pctf     ||
                 ' INITRANS ' || pl_initrans ||
                 ' MAXTRANS ' || pl_maxtrans ||
                 ' STORAGE (  INITIAL '     || pl_initial ||
                            ' NEXT '        || pl_next    ||
                            ' MINEXTENTS '  || pl_minext  ||
                            ' MAXEXTENTS '  || pl_maxext  ||
                            ' PCTINCREASE ' || pl_pctinc  ||
                            ' OBJNO '       || pl_obj_num ||
                            ' EXTENTS (FILE '  || pl_file_num  ||
                                     ' BLOCK ' || pl_block_num ||'))';
    end if;

    return pl_text;
  end;

begin
  /* Create the bootstrap sql text for OBJ$  */
  pl_obj_num  := get_obj_num('OBJ$MIG', 1);
  pl_line_num := get_line_num('OBJ$', 1);
  pl_objtxt := 'CREATE TABLE OBJ$("OBJ#" NUMBER NOT NULL,"DATAOBJ#" NUMBER,"OWNER#" NUMBER NOT NULL,"NAME" VARCHAR2(30) NOT NULL,"NAMESPACE" NUMBER NOT NULL,"SUBNAME" VARCHAR2(30),"TYPE#" NUMBER NOT NULL,"CTIME" DATE NOT NULL,"MTIME" DATE NOT NULL,"STIME" DATE NOT NULL,"STATUS" NUMBER NOT NULL,"REMOTEOWNER" VARCHAR2(30),"LINKNAME" VARCHAR2(128),"FLAGS" NUMBER,"OID$" RAW(16),"SPARE1" NUMBER,"SPARE2" NUMBER,"SPARE3" NUMBER,"SPARE4" VARCHAR2(1000),"SPARE5" VARCHAR2(1000),"SPARE6" DATE)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'TABLE');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;


  /* Create the bootstrap sql text for I_OBJ_MIG1 (replace i_obj1) */
  pl_obj_num  := get_obj_num('I_OBJ_MIG1', 4);
  pl_line_num := get_line_num('I_OBJ1', 4);
  pl_objtxt :='create unique index i_obj1 on obj$(obj#, owner#, type#)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'INDEX');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;


  /* Create the bootstrap sql text for I_OBJ_MIG2 (replace i_obj2) */
  pl_obj_num  := get_obj_num('I_OBJ_MIG2', 4);
  pl_line_num := get_line_num('I_OBJ2', 4);
  pl_objtxt := 'create unique index i_obj2 on obj$(owner#, name, namespace,remoteowner, linkname, subname, type#, spare3, obj#)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'INDEX');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;


  /* Create the bootstrap sql text for I_OBJ_MIG3 (replace i_obj3) */
  pl_obj_num  := get_obj_num('I_OBJ_MIG3', 4);
  pl_line_num := get_line_num('I_OBJ3', 4);
  pl_objtxt := 'create index i_obj3 on obj$(oid$)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'INDEX');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;


  /* Create the bootstrap sql text for I_OBJ_MIG4 
       The line number for I_OBJ4 won't exist if we're upgrading from 10.1. So,
       we're taking the max(line)+1 from bootstrap$.
  */
  pl_obj_num  := get_obj_num('I_OBJ_MIG4', 4);
  pl_line_num := get_line_num('I_OBJ4', 4);
  if (pl_line_num is NULL) then
    select max(line#)+1 into pl_line_num from sys.bootstrap$;
  end if;
  pl_objtxt := 'create index i_obj4 on obj$(dataobj#, type#, owner#)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'INDEX');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;

  /* Create the bootstrap sql text for I_OBJ_MIG5 
       The line number for I_OBJ5 won't exist if we're upgrading from 10.1. So,
       we're taking the max(line)+1 from bootstrap$.
  */
  pl_obj_num  := get_obj_num('I_OBJ_MIG5', 4);
  pl_line_num := get_line_num('I_OBJ5', 4);
  if (pl_line_num is NULL) then
    select max(line#)+2 into pl_line_num from sys.bootstrap$;
  end if;
  pl_objtxt := 'create unique index i_obj5 on obj$(spare3, name, namespace, type#, owner#, remoteowner, linkname, subname, obj#)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'INDEX');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;

  /* Create the bootstrap sql text for USER$  */
  pl_obj_num  := get_obj_num('USER$MIG', 1);
  pl_line_num := get_line_num('USER$', 1);
  pl_objtxt := 'CREATE TABLE USER$("USER#" NUMBER NOT NULL,"NAME" VARCHAR2(30) NOT NULL,"TYPE#" NUMBER NOT NULL,"PASSWORD" VARCHAR2(30),"DATATS#" NUMBER NOT NULL,"TEMPTS#" NUMBER NOT NULL,"CTIME" DATE NOT NULL,"PTIME" DATE,"EXPTIME" DATE,"LTIME" DATE,"RESOURCE$" NUMBER NOT NULL,"AUDIT$" VARCHAR2(38),"DEFROLE" NUMBER NOT NULL,"DEFGRP#" NUMBER,"DEFGRP_SEQ#" NUMBER,"ASTATUS" NUMBER NOT NULL,"LCOUNT" NUMBER NOT NULL,"DEFSCHCLASS" VARCHAR2(30),"EXT_USERNAME" VARCHAR2(4000),"SPARE1" NUMBER,"SPARE2" NUMBER,"SPARE3" NUMBER,"SPARE4" VARCHAR2(1000),"SPARE5" VARCHAR2(1000),"SPARE6" DATE)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'CLUSTER TABLE');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;

  /* Create the bootstrap sql text for I_USER_MIG1 (replace i_user1) */
  pl_obj_num  := get_obj_num('I_USER_MIG1', 4);
  pl_line_num := get_line_num('I_USER1', 4);
  pl_objtxt := 'create unique index i_user1 on user$(name)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'INDEX');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;


  /* Create the bootstrap sql text for I_USER_MIG2
       The line number for I_USER2 won't exist if we're upgrading from 10.1.
       So, we're taking the max(line)+1 from bootstrap$.
  */
  pl_obj_num  := get_obj_num('I_USER_MIG2', 4);
  pl_line_num := get_line_num('I_USER2', 4);
  if (pl_line_num is NULL) then
    select max(line#)+3 into pl_line_num from sys.bootstrap$;
  end if;
  pl_objtxt := 'create unique index i_user2 on user$(user#, type#, spare1, spare2)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'INDEX');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;


  /* Create the bootstrap sql text for BOOTSTRAP$  */
  pl_obj_num  := get_obj_num('BOOTSTRAP$MIG', 1);
  pl_line_num := get_line_num('BOOTSTRAP$', 1);
  pl_objtxt := 'CREATE TABLE BOOTSTRAP$("LINE#" NUMBER NOT NULL,"OBJ#" NUMBER NOT NULL,"SQL_TEXT" VARCHAR2(4000) NOT NULL)';
  pl_objtxt := pl_objtxt || gen_storage(pl_obj_num, 'TABLE');
  insert into bootstrap$tmpstr values(pl_line_num, pl_obj_num, pl_objtxt);
  commit;

end;
/


/*****************************************************************************/
/*
 * Step 3 - Copy data from old tables to the new tables.
 *
 * There must be no DDL from now on.
 */
/*****************************************************************************/

-- for large databases, limit the number of rows changed before each commit to
-- avoid rollback space problems during upgrade
declare
  upperbound number;
  lowerbound number;
  maxobjnum  number;
begin
  lowerbound := 0;
  upperbound := 10000;
  select max(obj#) into maxobjnum from obj$;
  loop
    insert into obj$mig select * from obj$
      where obj#>=lowerbound and obj#<upperbound;
    commit;
    exit when upperbound > maxobjnum;
    lowerbound := upperbound;
    upperbound := upperbound + 10000;
  end loop;
end;
/

insert into user$mig select * from user$;
insert into bootstrap$mig select * from bootstrap$;
commit;

-- DBMS_STATS now depends on DBMS_UTILITY which may have gotten invalidated 
-- by some preceeding DDL statement, so package state needs to be cleared to 
-- avoid ORA-04068
execute dbms_session.reset_package;

-- we also need to update the statistic
begin
  dbms_stats.delete_table_stats('SYS', 'OBJ$MIG');
  dbms_stats.delete_table_stats('SYS', 'USER$MIG');
  dbms_Stats.gather_table_stats('SYS', 'OBJ$MIG',  estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
  dbms_Stats.gather_table_stats('SYS', 'USER$MIG', estimate_percent => 100,
                                 method_opt=>'FOR ALL COLUMNS SIZE SKEWONLY');
end;
/

-- lrg 7149217: interval partitioning can create objects while gathering
-- stats, so we need to copy them over to obj$mig.
delete from obj$mig where name='_NEXT_OBJECT';
insert into obj$mig
  (obj#, dataobj#, owner#, name, namespace, subname, type#, ctime, mtime,
   stime, status, remoteowner, linkname, flags, oid$, spare1, spare2,
   spare3, spare4, spare5, spare6)
  select
   obj#, dataobj#, owner#, name, namespace, subname, type#, ctime, mtime,
   stime, status, remoteowner, linkname, flags, oid$, spare1, spare2,
   spare3, spare4, spare5, spare6
  from obj$
  where obj# not in (select obj# from obj$mig);
commit;


/*****************************************************************************/
/* Step 4 - Swap the name of the new and old table/index in obj$mig
*/
/*****************************************************************************/
declare
  type vc_nst_type is table of varchar2(30);
  type nb_nst_type is table of number;
  old_name_array vc_nst_type;                       /* old object name array */
  new_name_array vc_nst_type;                       /* new object name array */
  ns_array       nb_nst_type;                     /* namespace of the object */
begin
  old_name_array := vc_nst_type('OBJ$',     'I_OBJ1', 'I_OBJ2', 
                                            'I_OBJ3', 'I_OBJ4',
                                            'I_OBJ5',
                                'USER$',    'I_USER1', 'I_USER2',
                                'BOOTSTRAP$');
  new_name_array := vc_nst_type('OBJ$MIG',  'I_OBJ_MIG1', 'I_OBJ_MIG2',
                                            'I_OBJ_MIG3', 'I_OBJ_MIG4',
                                            'I_OBJ_MIG5',
                                'USER$MIG', 'I_USER_MIG1','I_USER_MIG2',
                                'BOOTSTRAP$MIG');
  ns_array       := nb_nst_type(1,4,4,4,4,4,
                                1,4,4,
                                1);

  /* Swap the name in old_name_array with new_name_array in OBJ$MIG */
  for i in old_name_array.FIRST .. old_name_array.LAST
  loop
    update obj$mig set name = 'ORA$MIG_TMP'
      where name = old_name_array(i) and owner# = 0 and namespace=ns_array(i);
    update obj$mig set name = old_name_array(i)
      where name = new_name_array(i) and owner# = 0 and namespace=ns_array(i);
    update obj$mig set name = new_name_array(i)
      where name = 'ORA$MIG_TMP'     and owner# = 0 and namespace=ns_array(i);
  end loop;

  /* Commit when we're done with the swap */
  commit;
end;
/


/*****************************************************************************/
/* Step 5 - Remove the old object entries in bootstrap$mig
*/
/*****************************************************************************/
delete from bootstrap$mig where obj# in 
 (select obj# from obj$ 
  where name in ('OBJ$',  'I_OBJ1',  'I_OBJ2', 'I_OBJ3', 'I_OBJ4', 'I_OBJ5',
                 'USER$', 'I_USER1', 'I_USER2',
                 'BOOTSTRAP$'));
commit;


/*****************************************************************************/
/* Step 6 - Insert the new object entries in bootstrap$mig
*/
/*****************************************************************************/
insert into bootstrap$mig select * from bootstrap$tmpstr;
commit;


/*****************************************************************************/
/* Step 7 - Update dependency$ directly
   Step 8 - Forward all object privil from obj$/user$ to obj$mig/user$mig
*/
/*****************************************************************************/
declare
  type vc_nst_type is table of varchar2(30);
  old_obj_num number;
  new_obj_num number;
  new_ts      timestamp;
  old_name    vc_nst_type;
  new_name    vc_nst_type;
begin
  old_name := vc_nst_type('OBJ$',    'USER$',    'BOOTSTRAP$');
  new_name := vc_nst_type('OBJ$MIG', 'USER$MIG', 'BOOTSTRAP$MIG');

  for i in old_name.FIRST .. old_name.LAST
  loop
    select obj# into old_obj_num from obj$ 
      where owner#=0 and name=old_name(i) and namespace=1 and linkname is null
        and subname is null;
    select obj#, stime into new_obj_num, new_ts from obj$
      where owner#=0 and name=new_name(i) and namespace=1 and linkname is null
        and subname is null;

    -- Step 7
    update dependency$ 
      set p_obj#      = new_obj_num, 
          p_timestamp = new_ts
      where p_obj# = old_obj_num;

    -- Step 8
    update objauth$ set obj# = new_obj_num where obj# = old_obj_num;

  end loop;

  commit;
end;
/


/*****************************************************************************/
/* Step 9 - Swap bootstrap$mig with bootstrap$
*/
/*****************************************************************************/
/* According to JKLEIN, performing 3 count(*) will ensure there are
   no dirty itl's present in bootstrap$. */
select count(*) from bootstrap$;
select count(*) from bootstrap$;
select count(*) from bootstrap$;
select count(*) from bootstrap$mig;
select count(*) from bootstrap$mig;
select count(*) from bootstrap$mig;

WHENEVER SQLERROR CONTINUE 

declare
  LS_Special_3            CONSTANT NUMBER := 11;
  LOCbldlogid             VARCHAR2(22) := NULL;
  LOCLockDownScn          NUMBER;
  rowcnt                  NUMBER;
begin
  SELECT COUNT(1) into rowcnt
  FROM SYS.V$DATABASE V
  WHERE V.LOG_MODE = 'ARCHIVELOG' and
        V.SUPPLEMENTAL_LOG_DATA_MIN != 'NO';
  IF 0 != rowcnt THEN
    -- Logminer may be mining this redo stream, so we must do a special
    -- logminer dictionary build to capture the revised obj# etc.
    sys.dbms_logmnr_internal.DO_INT_BUILD(build_op=>LS_Special_3,
                                          dictionary_filename=>NULL,
                                          dictionary_location=>NULL,
                                          bldlogid_initxid=>LOCbldlogid,
                                          LockDownScn=>LOCLockDownScn,
                                          release_locks=>FALSE);
  END IF;

  -- Now we can do the swap.
  dbms_ddl_internal.swap_bootstrap('BOOTSTRAP$MIG');

  -- We've completed the swap.
  -- Remove the BOOTSTRAP_UPGRADE_ERROR entry in props$.
  delete from props$ where name = 'BOOTSTRAP_UPGRADE_ERROR';
  delete from props$ where name = 'LOGMNR_BOOTSTRAP_UPGRADE_ERROR';
  commit;
end;
/


/*****************************************************************************/
/* Step 10 - REPORT TIMINGS AND SHUTDOWN THE DATABASE..!!!!! 
*/
/*****************************************************************************/

Rem =====================================================================
Rem Record UPGRADE complete
Rem Note:  NO DDL STATEMENTS. DO NOT RECOMMEND ANY SQL BEYOND THIS POINT.
Rem =====================================================================

EXECUTE dbms_session.reset_package;

BEGIN
   dbms_registry_sys.record_action('UPGRADE',NULL,'Upgraded from ' || 
       dbms_registry.prev_version('CATPROC'));
END;
/

Rem =====================================================================
Rem Run component status as the last output
Rem Note:  NO DDL STATEMENTS. DO NOT RECOMMEND ANY SQL BEYOND THIS POINT.
Rem Note:  ACTIONS_END must stay here to get the correct upgrade time.
Rem =====================================================================

SELECT dbms_registry_sys.time_stamp('ACTIONS_END') AS timestamp FROM DUAL;
SELECT dbms_registry_sys.time_stamp('UPGRD_END') AS timestamp FROM DUAL;
@@utlusts TEXT
commit;

shutdown immediate;


