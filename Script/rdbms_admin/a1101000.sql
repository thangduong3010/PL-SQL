Rem
Rem $Header: rdbms/admin/a1101000.sql /main/19 2009/09/29 06:17:50 jklein Exp $
Rem
Rem a1101000.sql
Rem
Rem Copyright (c) 2007, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      a1101000.sql - additional ANONYMOUS BLOCK dictionary upgrade
Rem                     making use of PL/SQL packages installed by
Rem                     catproc.sql.
Rem
Rem    DESCRIPTION
Rem      Additional upgrade script to be run during the upgrade of an
Rem      11.1.0 database to the new release.
Rem
Rem      This script is called from catupgrd.sql and a1002000.sql
Rem
Rem      Put any anonymous block related changes here.
Rem      Any dictionary create, alter, updates and deletes  
Rem      that must be performed before catalog.sql and catproc.sql go 
Rem      in c1101000.sql
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: upgrade from 11.1 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jklein      09/25/09 - fix uet/seg ref check
Rem    cdilling    08/03/09 - invoke 11.2.0 patch upgrade script
Rem    bkuchibh    07/21/09 - fix bug 8502349: modify the fk_filter
Rem    jklein      07/14/09 - run dictionary check rules on upgrade
Rem    gagarg      03/28/09 - Drop PLSQL notification queue and queue table
Rem    sanagara    03/03/09 - compile invalid AQ types
Rem    gagarg      12/02/08 - Bug 6016633: AQ changes recreate AQ<QT>_F view
Rem    absaxena    07/03/08 - create dequeue logs and recreate base views for 
Rem                           old multiconsumer queue tables
Rem    pyoun       12/11/08 - bug 7423840, create dummy salt key in props
Rem                           dollar
Rem    sjanardh    10/15/08 - SCN_AT_ADD new column in subscriber tables
Rem    gssmith     10/15/08 - Upgrade Access Advisor for lrg 3651498
Rem    achoi       10/01/08 - move drop user to the a script
Rem    qiwang      07/10/08 - BUG 6909095: logical standby ckpt
Rem                           upgrade/downgrade
Rem    dvoss       06/26/08 - bug 7033630 - resolve duplicate segcols
Rem    gagarg      02/18/08 - Bug4241238 AQ changes:recreate AQ<QT>_S view
Rem    mjstewar    01/04/08 - Add DRA upgrade
Rem    hosu        08/06/07 - 6320985: create unique index on sql$text.signature
Rem    rburns      07/10/07 - required for 11g upgrade
Rem    rburns      07/10/07 - Created
Rem

Rem *************************************************************************
Rem BEGIN a1101000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 11.1.0 to the current release
Rem =========================================================================

Rem *************************************************************************
Rem Drop user TSMSYS
Rem *************************************************************************
DROP USER TSMSYS CASCADE;
Rem *************************************************************************

Rem ======================================
Rem SQL Plan Management (SPM) BEGIN
Rem ======================================

CREATE UNIQUE INDEX i_sql$text_pkey ON sql$text (signature)
 TABLESPACE sysaux
/

Rem ======================================
Rem SQL Plan Management (SPM) END
Rem ======================================

Rem =======================================================================
Rem  Data Recovery Advisor (DRA) BEGIN 
Rem =======================================================================

Rem
Rem Maintenance job HM_CREATE_OFFLINE_DICTIONARY should be disabled.
Rem
BEGIN
  sys.dbms_scheduler.disable(
     name=> 'HM_CREATE_OFFLINE_DICTIONARY',
     force=> TRUE);
EXCEPTION
  when others then
    if sqlcode = -27476 then   -- Does not exist 
      NULL;
    else 
      raise;
    end if;
END;
/

Rem =======================================================================
Rem  Data Recovery Advisor (DRA) END
Rem =======================================================================

Rem=========================================================================
Rem Begin Advanced Queuing upgrade items
Rem=========================================================================

Rem ==================================================================
Rem Compile any invalid types that have queue tables dependent on them
Rem or else the views created in the following pl/sql blocks may get
Rem compilation errors
Rem ==================================================================

DECLARE
  CURSOR typ_cur IS
  SELECT qt.schema, qt.name, d.referenced_owner, d.referenced_name
  FROM system.aq$_queue_tables qt, dba_dependencies d, dba_objects o
  WHERE qt.schema = d.owner
  AND qt.name = d.name
  AND d.referenced_type = 'TYPE'
  AND o.object_name = d.referenced_name
  AND o.owner = d.referenced_owner
  AND o.status = 'INVALID';
BEGIN
  FOR typ_rec in typ_cur LOOP
    BEGIN
      EXECUTE IMMEDIATE 'alter type "' ||
          typ_rec.referenced_owner || '"."' || typ_rec.referenced_name ||
                '" compile specification reuse settings';
    EXCEPTION
      WHEN OTHERS THEN
        dbms_system.ksdwrt(dbms_system.alert_file,
                    'a1101000.sql: Error while compiling type' ||
                    typ_rec.referenced_owner|| '.' || typ_rec.referenced_name);
    END;
  END LOOP;
END;
/

-- Bug 4241238: Recreate AQ$<QT>_S subscribers view to drop QUEUE_TO_QUEUE 
-- column. 
DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name, qt.flags
  FROM system.aq$_queue_tables qt;
BEGIN 
  FOR qt_rec IN qt_cur LOOP
    -- for multiconsumer newstyle, recreate.
    IF (bitand(qt_rec.flags, 1) = 1 and bitand(qt_rec.flags, 8) = 8) THEN
      sys.dbms_prvtaqis.create_subscriber_view(qt_rec.schema, qt_rec.name);
    END IF;
  END LOOP;
END;
/

Rem ===============================
Rem Add Subscriber Table columns
Rem SCN_AT_ADD
Rem ===============================

-- Turn ON the event to enable DDL on AQ tables
alter session set events  '10851 trace name context forever, level 1';

DECLARE
  qt_schema    VARCHAR2(30);
  qt_name      VARCHAR2(30);
  qt_flags     NUMBER;
  -- Select the 8.1 style multi-consumer queue tables      
  CURSOR find_qt_c IS SELECT schema, name, flags, objno
                   FROM system.aq$_queue_tables
                   WHERE bitand(flags, 8)=8 and bitand(flags, 1)=1;
  subtab_sql   VARCHAR2(1024);
  add_col_sql  VARCHAR2(300);
  sel_queues   VARCHAR2(300);
  qcur         INTEGER;
  ignore       INTEGER;
  q_name       VARCHAR2(30);
  no_cmprs_sql      VARCHAR2(300);
  rebuild_idx_sql   VARCHAR2(300);
  tab_sp1           NUMBER;
  CURSOR rbi_c(tab_owner VARCHAR2, tab_name VARCHAR2) IS
    SELECT owner, index_name
      FROM dba_indexes
      WHERE table_owner=tab_owner
        AND table_name=tab_name
        AND status= 'UNUSABLE';
BEGIN

  FOR q_rec IN find_qt_c LOOP         -- iterate all 8.1 mcq queue tables
    qt_schema := q_rec.schema;        -- get queue table schema
    qt_name   := q_rec.name;          -- get queue table name

    -- Cannot add/drop column from compressed table if 9.2 compatible,
    -- so first uncompress the table if it is compressed.
    BEGIN
       SELECT t.spare1 INTO tab_sp1 FROM tab$ t, obj$ o, user$ u
       WHERE t.obj# = o.obj# AND u.user# = o.owner#
       AND o.name = 'AQ$_'||qt_name || '_S' AND u.name = qt_schema;

       DBMS_SYSTEM.ksdwrt(1, 'Upgrade Queue table subscriber format' ||
                             'AQ$_'||qt_name || '_S') ;
       IF BITAND(tab_sp1, 131072)=131072 THEN        -- table is compressed
           no_cmprs_sql := 'alter table ' ||
                   dbms_assert.enquote_name(qt_schema, FALSE) || '.' ||
                    dbms_assert.enquote_name('AQ$_'||qt_name || '_S', FALSE) ||
                     ' move nocompress';

           EXECUTE IMMEDIATE no_cmprs_sql;           -- uncompress the table

           -- rebuild any unusable indexes for the table
           FOR r IN rbi_c(qt_schema, 'AQ$_'||qt_name || '_S') LOOP
               rebuild_idx_sql:= 'ALTER INDEX ' ||
                       dbms_assert.enquote_name(r.owner, FALSE) || '.'
                       || dbms_assert.enquote_name(r.index_name, FALSE)
                       || ' REBUILD';
                 EXECUTE IMMEDIATE rebuild_idx_sql;
           END LOOP;
       END IF;
    EXCEPTION
       WHEN OTHERS THEN
           dbms_system.ksdwrt(dbms_system.alert_file,
                              'Upgrade Queue table subscriber format:'||
                              'Error Msg in table objno select "' ||
                               qt_schema || '"."' || 'AQ$_'|| qt_name ||
                                '_S"' || SQLERRM) ;
    END;

    add_col_sql := 'ALTER TABLE '|| dbms_assert.enquote_name(qt_schema, FALSE)
                    || '.' ||
                    dbms_assert.enquote_name('AQ$_'|| qt_name || '_S', FALSE)
                    || ' ADD (SCN_AT_ADD NUMBER )' ;
    BEGIN
      EXECUTE IMMEDIATE add_col_sql;
    EXCEPTION
       WHEN OTHERS THEN
           dbms_system.ksdwrt(dbms_system.alert_file,
                              'Upgrade Queue table subscriber format:'||
                               'Error Msg Add Col "' ||
                                qt_schema || '"."' || 'AQ$_'|| qt_name ||
                                '_S"' || SQLERRM) ;
    END;

  END LOOP;

END;
/

-- Bug 6016633: Create deq_view compatible with 11.2 releases. 
-- In 11.2 onwards, timestamps are adjusted to session timezone whereas 
-- in pre 11.2 view timestamps are with reference to queue table timezone.
-- During upgrade, recreate the views compatible to 11.2    
DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name, qt.flags
  FROM system.aq$_queue_tables qt;
BEGIN
  FOR qt_rec IN qt_cur LOOP

    BEGIN
      IF dbms_aqadm_sys.mcq_8_1(qt_rec.flags) THEN
        sys.dbms_prvtaqim.create_deq_view(qt_rec.schema, qt_rec.name,
                                          qt_rec.flags);
      ELSE
        sys.dbms_aqadm_sys.create_deq_view(qt_rec.schema, qt_rec.name,
                                           qt_rec.flags);
      END IF;
    
    EXCEPTION
      when others then
        dbms_system.ksdwrt(dbms_system.alert_file, 
                           'a1101000.sql:  recreate deq view ' ||
                           'failed for ' || qt_rec.schema || '.' || 
                           qt_rec.name);
    END; 
  END LOOP;
END;
/


-- create dequeue logs and recreate base views for old multiconsumer qtables
declare
  cursor qt_cur is select schema, name, flags from system.aq$_queue_tables;
begin
  for qt in qt_cur loop
    if (sys.dbms_aqadm_sys.mcq_8_1(qt.flags)) then
      begin
        if not sys.dbms_aqadm_sys.object_exists(qt.schema, 'AQ$_' || qt.name ||
         '_L', 'TABLE') then
          sys.dbms_prvtaqim.create_dequeue_log(qt.schema, qt.name, qt.flags);
        end if;
        sys.dbms_prvtaqim.create_base_view(qt.schema, qt.name, qt.flags);
      exception
        when others then
          dbms_system.ksdwrt(dbms_system.alert_file, 
                         'a1101000.sql: create dequeue log or recreate base' ||
                         ' view failed for ' || qt.schema || '.' || qt.name);
      end;
    end if;
  end loop;
end;
/

-- Drop PLSQL notification queue table
DECLARE
BEGIN
  BEGIN
    dbms_aqadm.stop_queue('SYS.AQ_SRVNTFN_TABLE_Q');
  EXCEPTION
    WHEN OTHERS THEN
      dbms_system.ksdwrt(dbms_system.alert_file,
                         'a1101000.sql: stopping of queue ' ||
                         'SYS.AQ_SRVNTFN_TABLE_Q failed.');
      IF SQLCODE = -24010 THEN
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'Queue does not exists.'); 
      ELSE 
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'sqlerrm= '||sqlerrm);
      END IF;
  END;
  
  BEGIN
    dbms_aqadm.drop_queue('SYS.AQ_SRVNTFN_TABLE_Q'); 
  EXCEPTION
    WHEN OTHERS THEN
      dbms_system.ksdwrt(dbms_system.alert_file,
                         'a1101000.sql: dropping of queue ' ||
                         'SYS.AQ_SRVNTFN_TABLE_Q failed.');

      IF SQLCODE = -24010 THEN
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'Queue does not exists.');
      ELSE
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'sqlerrm= '||sqlerrm);
        
      END IF;
  END;

  BEGIN
    dbms_aqadm.drop_queue_table('SYS.AQ_SRVNTFN_TABLE');
  EXCEPTION
    WHEN OTHERS THEN
      dbms_system.ksdwrt(dbms_system.alert_file,
                         'a1101000.sql: dropping of queue table ' ||
                         'SYS.AQ_SRVNTFN_TABLE failed.');
      IF SQLCODE = -24002 THEN
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'Queue table does not exists.');
      ELSE
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'sqlerrm= '||sqlerrm);
      END IF;
  END;
END;
/
-- Turn OFF the event to disable DDL on AQ tables
alter session set events  '10851 trace name context off';

Rem=========================================================================
Rem End Advanced Queuing upgrade items
Rem=========================================================================

Rem=========================================================================
Rem BEGIN Logical Standby upgrade items
Rem=========================================================================
Rem
Rem BUG 6909095
Rem Convert Logical Standby Ckpt data from 11.1 format to 11.2 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_11to112;
end;
/

Rem=========================================================================
Rem End Logical Standby upgrade items
Rem=========================================================================

Rem =======================================================================
Rem  Begin Changes for Logminer
Rem =======================================================================

execute dbms_session.reset_package;

begin
  dbms_stats.gather_table_stats('system','logmnrc_gtcs',
                                METHOD_OPT => 'FOR ALL COLUMNS SIZE AUTO',
                                no_invalidate => false);
end;
/

declare
  cnt number := 0;
  bugtab number := null;
  now timestamp := current_timestamp;
begin
  select count(1) into cnt from system.logmnrc_gtcs a
   where exists ( select 1 from system.logmnrc_gtcs b where
                           a.logmnr_uid = b.logmnr_uid and
                           a.obj# = b.obj# and
                           a.objv# = b.objv# and
                           a.segcol# = b.segcol# and
                           a.segcol# <> 0 and
                           a.intcol# > b.intcol# and
                           a.colname = b.colname and
                           a.type# = b.type# and
                           a.length = b.length and
                           a.property = b.property);

  if cnt > 0 then  -- bug encountered
    select count(1) into cnt from sys.obj$
       where owner# = 0 and type# = 2 and name ='BUG_7033630_FIX';
    if cnt = 1 then -- rename old table
      select obj# into bugtab from sys.obj$
         where owner# = 0 and type# = 2 and name ='BUG_7033630_FIX';
      execute immediate 
                'alter table sys.BUG_7033630_FIX rename to
                                 BUG_7033630_FIX_' || bugtab;
    end if;
    execute immediate 
                'create table sys.BUG_7033630_FIX (
                   logmnr_uid                number,
                   obj#                      number,
                   objv#                     number,
                   segcol#                   number,
                   intcol#                   number,
                   colname                   varchar2(30), 
                   type#                     number,
                   length                    number,
                   precision                 number,
                   scale                     number,
                   interval_leading_precision  number,
                   interval_trailing_precision number,
                   property                  number,
                   toid                      raw(16),
                   charsetid                 number,
                   charsetform               number,
                   typename                  varchar2(30),
                   fqcolname                 varchar2(4000),
                   numintcols                number,
                   numattrs                  number,
                   adtorder                  number,
                   logmnr_spare1             number,
                   logmnr_spare2             number,
                   logmnr_spare3             varchar2(1000),
                   logmnr_spare4             date,
                   logmnr_spare5             number,
                   logmnr_spare6             number,
                   logmnr_spare7             number,
                   logmnr_spare8             number,
                   logmnr_spare9             number,
                   COL#                      NUMBER,
                   XTYPESCHEMANAME           VARCHAR2(30),
                   XTYPENAME                 VARCHAR2(4000),
                   XFQCOLNAME                VARCHAR2(4000),
                   XTOPINTCOL                NUMBER,
                   XREFFEDTABLEOBJN          NUMBER,
                   XREFFEDTABLEOBJV          NUMBER,
                   XCOLTYPEFLAGS             NUMBER,
                   XOPQTYPETYPE              NUMBER,
                   XOPQTYPEFLAGS             NUMBER,
                   XOPQLOBINTCOL             NUMBER,
                   XOPQOBJINTCOL             NUMBER,
                   XXMLINTCOL                NUMBER,
                   EAOWNER#                  NUMBER,
                   EAMKEYID                  VARCHAR2(64),
                   EAENCALG                  NUMBER,
                   EAINTALG                  NUMBER,
                   EACOLKLC                  RAW(2000),
                   EAKLCLEN                  NUMBER,
                   EAFLAGS                   NUMBER,
                   gtcs_rowid                rowid,
                   when_record_found         timestamp)';
    execute immediate
     'insert into sys.BUG_7033630_FIX 
        select
         a.logmnr_uid, a.obj#, a.objv#, a.segcol#, a.intcol#, a.colname, 
         a.type#, a.length, a.precision, a.scale, a.interval_leading_precision,
         a.interval_trailing_precision, a.property, a.toid, a.charsetid,
         a.charsetform, a.typename, a.fqcolname, a.numintcols, a.numattrs,
         a.adtorder, a.logmnr_spare1, a.logmnr_spare2, a.logmnr_spare3,
         a.logmnr_spare4, a.logmnr_spare5, a.logmnr_spare6, a.logmnr_spare7,
         a.logmnr_spare8, a.logmnr_spare9, a.COL#, a.XTYPESCHEMANAME,
         a.XTYPENAME, a.XFQCOLNAME, a.XTOPINTCOL, a.XREFFEDTABLEOBJN,
         a.XREFFEDTABLEOBJV, a.XCOLTYPEFLAGS, a.XOPQTYPETYPE, a.XOPQTYPEFLAGS,
         a.XOPQLOBINTCOL, a.XOPQOBJINTCOL, a.XXMLINTCOL, a.EAOWNER#,
         a.EAMKEYID, a.EAENCALG, a.EAINTALG, a.EACOLKLC, a.EAKLCLEN, a.EAFLAGS,
         rowid gtcs_rowid, :1 when_record_found
          from system.logmnrc_gtcs a
          where exists ( select 1 from system.logmnrc_gtcs b where
                           a.logmnr_uid = b.logmnr_uid and
                           a.obj# = b.obj# and
                           a.objv# = b.objv# and
                           a.segcol# = b.segcol# and
                           a.segcol# <> 0 and
                           a.intcol# > b.intcol# and
                           a.colname = b.colname and
                           a.type# = b.type# and
                           a.length = b.length and
                           a.property = b.property)' using now;
    execute immediate
     'delete from system.logmnrc_gtcs a
      where (a.logmnr_uid, a.obj#, a.objv#, a.segcol#, a.intcol#,
             a.colname, a.type#, a.length, a.property, rowid) in
              (select b.logmnr_uid, b.obj#, b.objv#, b.segcol#, b.intcol#,
                      b.colname, b.type#, b.length, b.property, b.gtcs_rowid
                 from sys.bug_7033630_fix b
                 where when_record_found = :1)' using now;
    commit;
   end if;
end;
/

Rem =======================================================================
Rem  End Changes for Logminer
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for SQL Access Advisor
Rem =======================================================================

Rem
Rem Move new default task parameters to existing tasks.
Rem
Rem   This is a 3-level loop.  
Rem     1. For each task, fetch its task id and advisor id
Rem     2. Fetch default task parameters
Rem     3. For each default task parameter, we fetch related tasks
Rem     4. For each task, we move a copy of the new default
Rem        task parameter to the task, if it does not already
Rem        exist in the task
Rem

declare
  cursor task_cur IS 
    SELECT id,advisor_id FROM sys.wri$_adv_tasks a
    where advisor_id in (2,7);

  cursor param_cur (id NUMBER) IS 
    SELECT *
      FROM sys.wri$_adv_def_parameters a
      WHERE a.advisor_id = id;

  l_adv_id binary_integer;
  l_task_id binary_integer;
  l_cnt binary_integer;
  param wri$_adv_def_parameters%ROWTYPE;
  l_data varchar2(2000);
begin
  open task_cur;
  
  loop
    fetch task_cur into l_task_id,l_adv_id;
    exit when task_cur%NOTFOUND;
    
    open param_cur(l_adv_id);

    loop
      fetch param_cur INTO param;
      EXIT WHEN param_cur%NOTFOUND;

      select count(*) into l_cnt from sys.wri$_adv_parameters
        where name = param.name and task_id = l_task_id;

      if l_cnt = 0 then
        if param.name = 'ANALYSIS_SCOPE' then
          select value into l_data
            from sys.wri$_adv_parameters
            where name = 'EVALUATION_ONLY' and task_id = l_task_id;

          if l_data <> 'TRUE' then
            select value into l_data
              from sys.wri$_adv_parameters
              where name = 'EXECUTION_TYPE' and task_id = l_task_id;
          end if;

          if l_data = 'TRUE' then
            param.value := 'EVALUATION';
          elsif l_data = 'FULL' then
            param.value := 'ALL';
          elsif l_data = 'INDEX_ONLY' then
            param.value := 'INDEX';
          elsif l_data = 'MVIEW_ONLY' then
            param.value := 'MVIEW';
          elsif l_data = 'MVIEW_LOG_ONLY' then
            param.value := 'MVLOG';
          else
            param.value := NULL;
          end if;
        end if;

        INSERT INTO sys.wri$_adv_parameters
          (task_id,name,datatype,value,flags,description)
        VALUES
          (l_task_id, param.name, param.datatype, param.value, 
           param.flags, param.description);
      end if;
    end loop;

    close param_cur;
  end loop;

  close task_cur;

  commit;
end;
/

Rem =======================================================================
Rem  End Changes for SQL Access Advisor
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for authentication confounder
Rem =======================================================================
insert into props$
    (select 'NO_USERID_VERIFIER_SALT', RAWTOHEX(DBMS_CRYPTO.RANDOMBYTES (16)),
NULL from dual
     where 'NO_USERID_VERIFIER_SALT' NOT IN (select name from props$));
Rem =======================================================================
Rem  End Changes for Authentication confounder
Rem =======================================================================


Rem =======================================================================
Rem Sql dictionary check rule upgrades
Rem =======================================================================
update sql_tk_coll_chk$ set expr='not between 0 and 101'
where table_name = 'OBJ$'
and   col_list = 'type#'
and   expr = 'not between 0 and 95';

update sql_tk_row_chk$ set col_list='user#,role#'
where table_name = 'DEFROLE$'
and   col_list = 'user#'
and   constraint_type = 'PRIMARY KEY';

update sql_tk_ref_chk$ set fk_filter='node is null'
where table_name = 'SYN$'
and   pk_table_name = 'user$'
and   fk_col_list = 'owner'
and   pk_col_list = 'name';

update sql_tk_ref_chk$ set fk_filter='file# != 0 and file# != 1024'
where table_name = 'TAB$'
and   pk_table_name = 'file$'
and   fk_col_list = 'file#'
and   pk_col_list = 'file#';

update sql_tk_ref_chk$ set fk_filter='file# != 1024'
where table_name = 'CLU$'
and   pk_table_name = 'file$'
and   fk_col_list = 'file#'
and   pk_col_list = 'file#';

update sql_tk_ref_chk$ 
set   fk_filter='obj$.type# = 2 and remoteowner is null and linkname is null'
where table_name = 'OBJ$'
and   pk_table_name = 'tab$'
and   fk_col_list = 'obj#'
and   pk_col_list = 'obj#';

update sql_tk_ref_chk$
set    fk_col_list='ts#,segfile#,segblock#'
where  table_name = 'UET$'
and    fk_col_list='ts#,file#,segblock#';

Rem =========================================================================
Rem END STAGE 1: upgrade from 11.1.0 to the current release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem Invoke patch upgrade script

@@a1102000.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END a1101000.sql
Rem *************************************************************************
