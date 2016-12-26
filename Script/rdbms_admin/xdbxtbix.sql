Rem
Rem $Header: rdbms/admin/xdbxtbix.sql /st_rdbms_11.2.0/2 2011/04/11 10:17:29 juding Exp $
Rem
Rem xdbxtbix.sql
Rem
Rem Copyright (c) 2010, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbxtbix.sql - XDB Xml TaBle IndeX
Rem
Rem    DESCRIPTION
Rem      Upgrade SXI from 11.2.0.1 to 11.2.0.2 -
Rem      1) (commented out) drop KEY column of leaf child SXI table
Rem      2) recreate secondary index on KEY column as local
Rem      3) recreate foreign key constraint referencing parent KEY column
Rem      4) recreate secondary index on OID, RID, PKEY column as local
Rem      5) add OID column to SXI table created for partitioned xmltype table
Rem      6) add KEY column to SXI leaf table
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    juding      04/08/11 - Backport juding_bug11071061u from main
Rem    juding      02/09/11 - Backport juding_bug-11070995 from main
Rem    juding      05/02/10 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

alter session set events '19119 trace name context forever, level 0x20000000';

drop table XDB.XDB$UPGRADE_TMP;

create table XDB.XDB$UPGRADE_TMP as
    select u.NAME user_name
         , o.NAME xtab_name
         , t.PTABOBJ# parent_id
         , f.CONSTRAINT_NAME fk_cons_name
         , pu.NAME puser_name
         , po.NAME pxtab_name
    from XDB.XDB$XTAB t, OBJ$ o, USER$ u
       , all_constraints f
       , OBJ$ po, USER$ pu
    where bitand(t.FLAGS, 16384) = 16384
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#
    and u.NAME = f.OWNER
    and o.NAME = f.TABLE_NAME
    and f.CONSTRAINT_TYPE = 'R'
    and t.PTABOBJ# = po.OBJ#
    and po.OWNER# = pu.USER#;

declare
  cursor XTAB_CUR_1 is
    select u.NAME user_name
         , o.NAME xtab_name
         , t.PTABOBJ# parent_id
         , count(k.XMLTABOBJ#) kid_cnt
    from XDB.XDB$XTAB t, OBJ$ o, USER$ u
       , XDB.XDB$XTAB k
    where 1=1
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#
    and t.XMLTABOBJ# = k.PTABOBJ# (+)
    group by u.NAME
           , o.NAME
           , t.PTABOBJ#;

  cursor XTAB_CUR_2 is
    select u.NAME user_name
         , o.NAME xtab_name
         , t.PTABOBJ# parent_id
         , c.CONSTRAINT_NAME pk_cons_name
         , c.OWNER pk_idx_owner
         , c.INDEX_NAME pk_idx_name
    from XDB.XDB$XTAB t, OBJ$ o, USER$ u
       , all_constraints c
    where bitand(t.FLAGS, 16384) = 16384
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#
    and u.NAME = c.OWNER
    and o.NAME = c.TABLE_NAME
    and c.CONSTRAINT_TYPE = 'P';

  cursor XTAB_CUR_3 is
    select * from XDB.XDB$UPGRADE_TMP;

  cursor XTAB_CUR_4 is
    select u.NAME user_name
         , o.NAME xtab_name
         , t.PTABOBJ# parent_id
         , i.INDEX_OWNER index_owner
         , i.INDEX_NAME index_name
         , i.COLUMN_NAME column_name
    from XDB.XDB$XTAB t, OBJ$ o, USER$ u
       , all_ind_columns i
    where bitand(t.FLAGS, 16384) = 16384
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#
    and u.NAME = i.TABLE_OWNER
    and o.NAME = i.TABLE_NAME
    and i.COLUMN_NAME in ('OID', 'RID', 'PKEY');

  stmt varchar2(2000);
begin
  /* Don't do this since it is destructive.
  for XTAB_REC in XTAB_CUR_1
  loop
      if XTAB_REC.kid_cnt = 0
      then
        stmt :=
        'alter table '
        || XTAB_REC.user_name || '.' || XTAB_REC.xtab_name
        || ' drop column "KEY"';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
      end if;
  end loop;
  */

  for XTAB_REC in XTAB_CUR_2
  loop
        stmt :=
      	'alter table '
      	|| XTAB_REC.user_name || '.' || XTAB_REC.xtab_name
      	|| ' drop primary key cascade drop index';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;

        stmt :=
        'create index '
        || XTAB_REC.pk_idx_name
        || ' on '
        || XTAB_REC.user_name || '.' || XTAB_REC.xtab_name
        || ' ("KEY") local';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;

        stmt :=
      	'alter table '
      	|| XTAB_REC.user_name || '.' || XTAB_REC.xtab_name
      	|| ' add constraint '
      	|| XTAB_REC.pk_cons_name
      	|| ' primary key ("KEY") using index '
      	|| XTAB_REC.pk_idx_name;
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
  end loop;

  for XTAB_REC in XTAB_CUR_3
  loop
        stmt :=
        'alter table '
        || XTAB_REC.user_name || '.' || XTAB_REC.xtab_name
        || ' add constraint '
        || XTAB_REC.fk_cons_name
        || ' foreign key ("PKEY") references '
        || XTAB_REC.puser_name || '.' || XTAB_REC.pxtab_name
        || ' ("KEY") on delete cascade initially deferred';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
  end loop;

  for XTAB_REC in XTAB_CUR_4
  loop
        stmt :=
        'drop index '
        || XTAB_REC.index_owner || '.' || XTAB_REC.index_name;
        -- dbms_output.put_line(stmt);
        execute immediate stmt;

        stmt :=
        'create index '
        || XTAB_REC.index_owner || '.' || XTAB_REC.index_name
        || ' on '
        || XTAB_REC.user_name || '.' || XTAB_REC.xtab_name
        || ' ("'
        || XTAB_REC.column_name
        || '") local';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
  end loop;
end;
/

drop table XDB.XDB$UPGRADE_TMP;

-- local SXI table created for partitioned xmltype table
create table XDB.XDB$UPGRADE_TMP as
    select t.IDXOBJ# idx_id
         , t.XMLTABOBJ# idxtab_id
         , bu.NAME btab_user
         , bo.NAME btab_name
         , u.NAME xtab_user
         , o.NAME xtab_name
    from XDB.XDB$XTAB t
       , IND$ i, OBJ$ bo, USER$ bu
       , OBJ$ o, USER$ u
    where bitand(t.FLAGS, 16640) = 16640
    and t.IDXOBJ# = i.OBJ#
    and i.BO# = bo.OBJ#
    and bo.OWNER# = bu.USER#
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#;

declare
  /* stage 0: SXI table has no OID column
   *       1: SXI table has nullable OID column (not populated yet)
   *       2: SXI table has non-nullable OID column (already populated)
   */
  cursor XTAB_CUR_5 is
    select v.idx_id
         , v.idxtab_id
         , v.btab_user
         , v.btab_name
         , v.xtab_user
         , v.xtab_name
         , 0 stage
    from XDB.XDB$UPGRADE_TMP v
    where not exists
         (select 1
          from all_tab_cols c
          where v.xtab_user = c.OWNER
          and v.xtab_name = c.TABLE_NAME
          and c.COLUMN_NAME = 'OID')
    union all
    select v.idx_id
         , v.idxtab_id
         , v.btab_user
         , v.btab_name
         , v.xtab_user
         , v.xtab_name
         , decode(c.NULLABLE, 'N', 2, 1) stage
    from XDB.XDB$UPGRADE_TMP v
       , all_tab_cols c
    where v.xtab_user = c.OWNER
    and v.xtab_name = c.TABLE_NAME
    and c.COLUMN_NAME = 'OID';

  stmt varchar2(2000);
  idxnm varchar2(200);
  idxcnt integer;
begin
  for XTAB_REC in XTAB_CUR_5
  loop
      if XTAB_REC.stage < 1
      then
        -- add OID column
        stmt :=
        'alter table '
        || XTAB_REC.xtab_user || '.' || XTAB_REC.xtab_name
        || ' add (OID raw(16))';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
      end if;

      if XTAB_REC.stage < 2
      then
        -- populate OID column
        stmt :=
        'update '
        || XTAB_REC.xtab_user || '.' || XTAB_REC.xtab_name || ' xt'
        || ' set OID = (select bt.sys_nc_oid$ from '
        || XTAB_REC.btab_user || '.' || XTAB_REC.btab_name || ' bt'
        || ' where bt.rowid = xt.RID)';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;

        -- set OID column not null
        stmt :=
        'alter table '
        || XTAB_REC.xtab_user || '.' || XTAB_REC.xtab_name
        || ' modify (OID not null)';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
      end if;

      idxnm := 'SYS' || XTAB_REC.idx_id || '_'
               || XTAB_REC.idxtab_id || '_OID_IDX';

      -- OID column has index?
      select count(*) into idxcnt
      from all_indexes
      where OWNER = XTAB_REC.xtab_user
      and INDEX_NAME = idxnm;

      if idxcnt < 1
      then
        -- create index on OID column
        stmt :=
        'create index '
        || XTAB_REC.xtab_user || '.' || idxnm || ' on '
        || XTAB_REC.xtab_user || '.' || XTAB_REC.xtab_name
        || ' (OID) local';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
      end if;
  end loop;
end;
/

drop table XDB.XDB$UPGRADE_TMP;

/*
 * SXI leaf table
 */
create table XDB.XDB$UPGRADE_TMP as
    select u.NAME xtab_user
         , o.NAME xtab_name
         , t.IDXOBJ# idx_id
         , t.XMLTABOBJ# idxtab_id
         , iu.NAME xidx_user
         , io.NAME xidx_name
         , decode(bitand(t.FLAGS, 16384), 16384, 'local', '') ptlcl
    from XDB.XDB$XTAB t, OBJ$ o, USER$ u
       , XDB.XDB$XTAB k, OBJ$ io, USER$ iu
    where 1=1
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#
    and t.XMLTABOBJ# = k.PTABOBJ# (+)
    and t.IDXOBJ# = io.OBJ#
    and io.OWNER# = iu.USER#
    group by u.NAME
           , o.NAME
           , t.PTABOBJ#
           , t.IDXOBJ#
           , t.XMLTABOBJ#
           , iu.NAME
           , io.NAME
           , t.FLAGS
    having count(k.XMLTABOBJ#) = 0;

drop table XDB.XDB$UPGRADE_TMP2;

/* stage 0: SXI leaf table has no KEY column
 *       1: SXI leaf table has nullable KEY column (not populated yet)
 *       2: SXI leaf table has non-nullable KEY column (already populated)
 */
create table XDB.XDB$UPGRADE_TMP2 as
    select v.idx_id
         , v.idxtab_id
         , v.xidx_user
         , v.xidx_name
         , v.xtab_user
         , v.xtab_name
         , v.ptlcl
         , 0 stage
    from XDB.XDB$UPGRADE_TMP v
    where not exists
         (select 1
          from all_tab_cols c
          where v.xtab_user = c.OWNER
          and v.xtab_name = c.TABLE_NAME
          and c.COLUMN_NAME = 'KEY')
    union all
    select v.idx_id
         , v.idxtab_id
         , v.xidx_user
         , v.xidx_name
         , v.xtab_user
         , v.xtab_name
         , v.ptlcl
         , decode(c.NULLABLE, 'N', 2, 1) stage
    from XDB.XDB$UPGRADE_TMP v
       , all_tab_cols c
    where v.xtab_user = c.OWNER
    and v.xtab_name = c.TABLE_NAME
    and c.COLUMN_NAME = 'KEY';

declare
  cursor XTAB_CUR_6 is
    select v.*
    from XDB.XDB$UPGRADE_TMP2 v
    where v.stage < 2;

  cursor XTAB_CUR_7 is
    select distinct
           v.xidx_user
         , v.xidx_name
    from XDB.XDB$UPGRADE_TMP2 v
    where v.stage < 2;

  cursor XTAB_CUR_8 is
    select v.*
    from XDB.XDB$UPGRADE_TMP2 v
    where v.stage = 2;

  stmt varchar2(2000);
  idxnm varchar2(200);
  idxcnt integer;
  cstcnt integer;
begin
  for XTAB_REC in XTAB_CUR_6
  loop
      if XTAB_REC.stage < 1
      then
        -- add KEY column
        stmt :=
        'alter table '
        || XTAB_REC.xtab_user || '.' || XTAB_REC.xtab_name
        || ' add (KEY RAW(1000))';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
      end if;

      -- truncate table
      stmt :=
      'truncate table '
      || XTAB_REC.xtab_user || '.' || XTAB_REC.xtab_name;
      -- dbms_output.put_line(stmt);
      execute immediate stmt;
  end loop;

  for XTAB_REC in XTAB_CUR_7
  loop
      -- populate table
      -- dbms_output.put_line(
      --   'xdb.dbms_xmlindex0.reload_sxi_leaf(' ||
      --      XTAB_REC.xidx_user || ', ' || XTAB_REC.xidx_name || ')');
      xdb.dbms_xmlindex0.reload_sxi_leaf(
        XTAB_REC.xidx_user, XTAB_REC.xidx_name
      );
  end loop;

  /*
   * Commented out, since no index or primary key constraint on KEY column.
   *
  for XTAB_REC in XTAB_CUR_6
  loop
      idxnm := 'SYS' || XTAB_REC.idx_id || '_'
               || XTAB_REC.idxtab_id || '_KEY_IDX';

      -- KEY column has index?
      select count(*) into idxcnt
      from all_indexes
      where OWNER = XTAB_REC.xtab_user
      and INDEX_NAME = idxnm;

      if idxcnt < 1
      then
        -- create index on KEY column
        stmt :=
        'create index '
        || XTAB_REC.xtab_user || '.' || idxnm || ' on '
        || XTAB_REC.xtab_user || '.' || XTAB_REC.xtab_name
        || ' (KEY) ' || XTAB_REC.ptlcl;
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
      end if;

      -- create primary key on KEY column
      stmt :=
      'alter table '
      || XTAB_REC.xtab_user || '.' || XTAB_REC.xtab_name
      || ' add constraint ' || idxnm
      || ' primary key (KEY) using index '
      || XTAB_REC.xtab_user || '.' || idxnm;
      -- dbms_output.put_line(stmt);
      execute immediate stmt;
  end loop;
  */

  for XTAB_REC in XTAB_CUR_8
  loop
      idxnm := 'SYS' || XTAB_REC.idx_id || '_'
               || XTAB_REC.idxtab_id || '_KEY_IDX';

      -- KEY column is primary key?
      select count(*) into cstcnt
      from all_constraints
      where OWNER = XTAB_REC.xtab_user
      and CONSTRAINT_NAME = idxnm
      and CONSTRAINT_TYPE = 'P'
      and TABLE_NAME = XTAB_REC.xtab_name;

      if cstcnt > 0
      then
        -- drop primary key constraint on KEY column
        stmt :=
        'alter table '
        || XTAB_REC.xtab_user || '.' || XTAB_REC.xtab_name
        || ' drop primary key drop index';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
      end if;
  end loop;
end;
/

drop table XDB.XDB$UPGRADE_TMP2;

drop table XDB.XDB$UPGRADE_TMP;

alter session set events '19119 trace name context off';

