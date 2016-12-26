Rem
Rem $Header: rdbms/admin/f1101000.sql /main/18 2009/08/31 11:08:26 cdilling Exp $
Rem
Rem f1101000.sql
Rem
Rem Copyright (c) 2005, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      f1101000.sql - Downgrade actions requiring the use of PL/SQL
Rem                     packages.
Rem
Rem    DESCRIPTION
Rem
Rem      Additional downgrade script to be run during the downgrade from
Rem      current release to 11.1. This must be run before e1101000.sql.
Rem
Rem      This script is called from catdwgrd.sql and f1002000.sql
Rem
Rem	 Put any downgrade actions that reference PL/SQL packages here.
Rem      The PL/SQL packages must be called from this script prior to 
Rem      any downgrade actions in e1101000.sql which could invalidate
Rem      the referenced PL/SQL objects.  
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem      cdilling 08/03/09 - invoke patch downgrade script
Rem      kkunchit 05/27/09 - no downgrade actions for content-api
Rem      gagarg   04/23/09 - Bug 8450499: Use exec immediate instead of
Rem                          dbms_prvtaqis.execute_stmt2
Rem      gagarg   03/28/09 - Drop PLSQL notification queue and queue table
Rem      rramkiss 02/26/09 - drop all scheduler destinations and groups
Rem      amullick 01/22/09 - archive provider drop/ downgrade actions
Rem      kkunchit 01/22/09 - content-api drop/downgrade actions
Rem      gagarg   12/25/08 - Bug 6016633: AQ changes recreate AQ<QT>_F view
Rem      absaxena 07/03/08 - drop dequeue logs and recreate base views for 
Rem                          multiconsumer queue tables
Rem      rgmani   04/04/08 - Drop Scheduler java code
Rem      sjanardh 10/15/08 - SCN_AT_ADD new column in subscriber tables
Rem      rapayne  08/26/08 - Put back the removal of mdapi schema definitions
Rem                          which are new in 11.2.
Rem      qiwang   07/10/08 - BUG 6909095: logical standby ckpt
Rem                          upgrade/downgrade
Rem      lbarton  06/12/08 - mdapi XML schemas no longer in db build
Rem      lbarton  06/04/08 - bug 6120168: kusparse.xsd
Rem      rapayne  05/14/08 - Remove mdapi schema definitions which are
Rem                          new in 11.2 (i.e., not previous versions).
Rem                          during downgrade.
Rem      gagarg   02/18/08 - Bug4241238 AQ changes: Recreate AQ<QT>_S view
Rem      mjstewar 01/08/08 - Fix DRA downgrade issues
Rem      rburns   8/15/08   Created

Rem *************************************************************************
Rem BEGIN f1101000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release
Rem =========================================================================

@@f1102000.sql

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release
Rem =========================================================================

BEGIN
   dbms_registry.downgrading('CATALOG');
   dbms_registry.downgrading('CATPROC');
END;
/

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary from current release to 11.1.0
Rem =========================================================================

Rem =====================================================================
Rem Scheduler java code changes
Rem =====================================================================

declare
  CURSOR all_fw_jobs IS
    SELECT owner, job_name from dba_scheduler_jobs
    where enabled = 'TRUE' AND BITAND(flags, 34359738368) <> 0;
begin
  FOR fw_job IN all_fw_jobs LOOP
    dbms_scheduler.disable('"' || fw_job.owner || '"."' || 
                           fw_job.job_name || '"', TRUE);
    dbms_scheduler.drop_job('"' || fw_job.owner || '"."' || 
                            fw_job.job_name || '"', TRUE);
  END LOOP;
end;
/

declare
  CURSOR all_fw IS
    SELECT owner, file_watcher_name from dba_scheduler_file_watchers;
begin
  FOR fw IN all_fw LOOP
    dbms_scheduler.disable('"' || fw.owner || '"."' ||
                           fw.file_watcher_name || '"', TRUE);
    dbms_scheduler.drop_file_watcher('"' || fw.owner || '"."' ||
                                     fw.file_watcher_name || '"', TRUE);
  END LOOP;
end;
/

begin
  dbms_scheduler.drop_job('FILE_WATCHER', TRUE);
end;
/

begin
  dbms_scheduler.drop_program('FILE_WATCHER_PROGRAM', TRUE);
end;
/

begin
  dbms_scheduler.drop_schedule('FILE_WATCHER_SCHEDULE', TRUE);
end;
/

begin
  dbms_aqadm.stop_queue('SYS.SCHEDULER_FILEWATCHER_Q');
  dbms_aqadm.drop_queue('SYS.SCHEDULER_FILEWATCHER_Q');
  dbms_aqadm.drop_queue_table('SYS.SCHEDULER_FILEWATCHER_QT');
end;
/

begin
  dbms_isched.drop_scheduler_attribute('FILE_WATCHER_COUNT');
end;
/

-- remove scheduler named destinations and all jobs pointing to
-- named destinations
declare
  CURSOR all_dest_jobs IS
    SELECT owner, job_name from dba_scheduler_jobs
    where BITAND(flags, 274877906944) <> 0 and job_subname is null;
begin
  FOR dest_job IN all_dest_jobs LOOP
    dbms_scheduler.disable('"' || dest_job.owner || '"."' ||
                           dest_job.job_name || '"', TRUE);
    dbms_scheduler.drop_job('"' || dest_job.owner || '"."' ||
                            dest_job.job_name || '"', TRUE);
  END LOOP;
end;
/

-- drop all database destinations
declare
  CURSOR all_dest IS
    SELECT owner, destination_name from dba_scheduler_db_dests;
begin
  FOR dest IN all_dest LOOP
    dbms_scheduler.disable('"' || dest.owner || '"."' ||
                           dest.destination_name || '"', TRUE);
    dbms_scheduler.drop_database_destination('"' || dest.owner || '"."' ||
                                     dest.destination_name || '"');
  END LOOP;
end;
/

-- drop agent destinatons
declare
  CURSOR all_ext_dest IS
    SELECT destination_name from dba_scheduler_external_dests;
begin
  FOR dest IN all_ext_dest LOOP
    dbms_scheduler.disable('"SYS"."' ||
                           dest.destination_name || '"', TRUE);
    dbms_scheduler.drop_agent_destination('"SYS"."' ||
                                     dest.destination_name || '"');
  END LOOP;
end;
/

-- drop non-window groups
declare
  CURSOR all_groups IS
    SELECT owner, group_name from dba_scheduler_groups
    WHERE GROUP_TYPE != 'WINDOW';
begin
  FOR grp IN all_groups LOOP
    dbms_scheduler.disable('"' || grp.owner || '"."' ||
                           grp.group_name || '"', TRUE);
    dbms_scheduler.drop_group('"' || grp.owner || '"."' ||
                                     grp.group_name || '"', TRUE);
  END LOOP;
end;
/

-- declare
--  CURSOR all_sch_agt IS
--    SELECT agent_name from dba_aq_agents where agent_name like 'SCHED$_AGT$_%';
-- begin
--   FOR sch_agt IN all_sch_agt LOOP
--     dbms_aqadm.drop_aq_agent(sch_agt.agent_name);
--   END LOOP;
-- end;
-- /

Rem ==========================
Rem Begin DRA changes
Rem ==========================

-- Parameters for DRA_REVAULAATE_OPEN_FAILURES job changed from 11.1.0.6
-- to 11.1.0.7.  So if downgrading to 11.1.0.6 recreate the job.
DECLARE
 previous_version varchar2(30);

BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version LIKE '11.1.0.6%' THEN

    -- Drop job for reevaluate open failures.  Parameters are no longer valid.
    BEGIN
      dbms_scheduler.drop_job(
         job_name => 'DRA_REEVALUATE_OPEN_FAILURES', 
         force => TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -27475 THEN NULL;          -- Not a job
        ELSE raise; 
        END IF;
    END;

    -- Recreate job for reevaluate open failures with no parameters and 
    -- leave disabled.
    BEGIN
      sys.dbms_scheduler.create_job(
        job_name=>'DRA_REEVALUATE_OPEN_FAILURES',
        job_type=>'STORED_PROCEDURE',
        job_action=>'dbms_ir.reevaluateopenfailures',
        schedule_name=>'MAINTENANCE_WINDOW_GROUP',
        job_class=>'DEFAULT_JOB_CLASS',
        enabled=>FALSE,
        auto_drop=>FALSE,
        comments=>'Reevaluate open failures for DRA');
    END;

  END IF;

END;
/

Rem ==========================
Rem End DRA changes
Rem ==========================

Rem=========================================================================
Rem Begin Advanced Queuing downgrade items
Rem=========================================================================


-- Bug 4241238: Recreate AQ$<QT>_S subscribers view to drop QUEUE_TO_QUEUE 
-- column. 
DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name, qt.flags
  FROM system.aq$_queue_tables qt;
BEGIN 
  FOR qt_rec IN qt_cur LOOP
    -- for multiconsumer newstyle, recreate.
    BEGIN 
      IF (bitand(qt_rec.flags, 1) = 1 and bitand(qt_rec.flags, 8) = 8) THEN
        -- Bug 8450499: Use exec immediate.
        EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW '              ||
               dbms_assert.enquote_name('"'||qt_rec.schema||'"') || '.'      ||
               dbms_assert.enquote_name('"'||'AQ$'||qt_rec.name || '_S'||'"') ||
               ' AS SELECT '                                       ||
               'queue_name QUEUE, '                ||
               'name NAME , '                      ||
               'address ADDRESS , '                ||
               'protocol PROTOCOL, '               ||
               'trans_name TRANSFORMATION '       ||
               ' FROM '                            ||
               dbms_assert.enquote_name('"'||'AQ$_' ||qt_rec.name|| '_S'||'"') || ' s '  ||
               ' WHERE (bitand(s.subscriber_type, 1) = 1) '            ||
               ' WITH READ ONLY';

      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'f1101000.sql: recreate of subscriber view ' || 
                           'failed for AQ table ' || qt_rec.schema || '.' ||
                           qt_rec.name); 
    END;
  END LOOP;
END;
/

Rem ===============================
Rem  Drop SCN_AT_ADD column
Rem    in subscriber tables.
Rem ===============================

DECLARE
  qt_schema    VARCHAR2(30);
  qt_name      VARCHAR2(30);
  qt_flags     NUMBER;
  CURSOR find_qt_c IS SELECT schema, name, flags, objno
                   FROM system.aq$_queue_tables;
  subtab_sql   VARCHAR2(1024);
  upd_col_sql  VARCHAR2(300);
  ignore       INTEGER;
  q_name       VARCHAR2(30);
BEGIN
  FOR q_rec IN find_qt_c LOOP         -- iterate all queue tables
    qt_schema := q_rec.schema;        -- get queue table schema
    qt_name   := q_rec.name;          -- get queue table name
    qt_flags  := q_rec.flags;         -- get queue table flags
    IF ((bitand(qt_flags, 8) = 8) AND (bitand(qt_flags, 1) = 1)) THEN
        upd_col_sql := 'UPDATE ' ||
                   dbms_assert.enquote_name(qt_schema, FALSE) || '.' ||
                   dbms_assert.enquote_name('AQ$_'  || qt_name || '_S', FALSE)
                   || ' SET SCN_AT_ADD = NULL ' ; 
        BEGIN
           EXECUTE IMMEDIATE upd_col_sql;
        EXCEPTION
           WHEN OTHERS THEN
                dbms_system.ksdwrt(1,' Error Msg ' || SQLERRM) ;
        END;
    END IF;
  END LOOP;
END;
/

-- Bug 6016633: Create deq_view compatible with pre 11.2 releases. 
-- In 11.2 onwards, timestamps are adjusted to session timezone whereas 
-- in pre 11.2 view timestamps are with reference to queue table timezone.
-- During downgrade recreate the views to pre 11.2 types   
DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name, qt.flags
  FROM system.aq$_queue_tables qt;
  BASE_TABLE_DOES_NOT_EXIST exception;
  PRAGMA EXCEPTION_INIT(BASE_TABLE_DOES_NOT_EXIST, -24344);
BEGIN
  FOR qt_rec IN qt_cur LOOP

    BEGIN
      IF dbms_aqadm_sys.mcq_8_1(qt_rec.flags) THEN
        sys.dbms_prvtaqim.create_deq_view_pre11_2(qt_rec.schema, qt_rec.name,
                                                  qt_rec.flags);
      ELSE
        sys.dbms_aqadm_sys.create_deq_view_pre11_2(qt_rec.schema, qt_rec.name,
                                                   qt_rec.flags);
      END IF;

    EXCEPTION
      when others then
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'f1101000.sql:  recreate deq view ' ||
                           'failed for ' || qt_rec.schema || '.' ||
                           qt_rec.name);
    END;
  END LOOP;

END;
/

-- drop dequeue logs and recreate base views for multiconsumer queue tables
declare
  cursor qt_cur is select schema, name, flags from system.aq$_queue_tables;
begin
  for qt in qt_cur loop
    if (sys.dbms_aqadm_sys.mcq_8_1(qt.flags)) then
      begin
        sys.dbms_prvtaqim.drop_dequeue_log(qt.schema, qt.name);
        sys.dbms_prvtaqim.create_base_view11_1_0(qt.schema, qt.name, qt.flags);
      exception
        when others then
          dbms_system.ksdwrt(dbms_system.alert_file, 
                         'f1101000.sql: drop dequeue log or recreate base' ||
                         ' view failed for ' || qt.schema || '.' || qt.name);
      end;
    end if;
  end loop;
end;
/

-- Bug7360952:Drop plsql notification tables created for each instance
-- One queue table is created for each instance dynamically at time of 
-- startup of emon coordinator. The number of queue table created will vary
-- with the number of RAC instances started. Hence using 'like' clause in
-- select stmt. 
DECLARE
  CURSOR qt_cur IS
  SELECT qt.name FROM system.aq$_queue_tables qt
  WHERE  qt.schema = 'SYS'
  AND    qt.name like 'AQ_SRVNTFN_TABLE_%';
BEGIN
  FOR qt_ntfn in qt_cur LOOP
    BEGIN
    dbms_aqadm.drop_queue_table('"' || 'SYS' || '"."' || qt_ntfn.name || '"',
                                TRUE);
    EXCEPTION
      WHEN OTHERS THEN
        dbms_system.ksdwrt(dbms_system.alert_file, 
                           'f1101000.sql: dropping of queue table ' ||
                           'SYS.' || qt_ntfn.name || ' failed.');
        IF SQLCODE = -24002 THEN
          dbms_system.ksdwrt(dbms_system.alert_file,
                             'Queue table does not exists');
        ELSE 
          dbms_system.ksdwrt(dbms_system.alert_file,
                             'sqlerrm= '||sqlerrm);
        END IF;
    END;
  END LOOP;
END;
/


Rem=========================================================================
Rem End Advanced Queuing downgrade items
Rem=========================================================================

Rem=========================================================================
Rem Begin Metadata API downgrade items
Rem=========================================================================
-- delete the appropriate (i.e., new in 11.2) xml schema definitions
DECLARE
previous_version varchar2(30);

BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  -- If we are downgrading to 11.1.0.6 or 11.1.0.7 then we need to remove the schemas
  -- that are new in 11.2. Note: these might not have been loaded so we trap any errors
  -- and don't raise them to avoid lrg noise.
  IF previous_version LIKE '11.1.0.%' THEN
     dbms_xmlschema.deleteschema('kuscomp.xsd',  dbms_xmlschema.DELETE_CASCADE_FORCE);
     dbms_xmlschema.deleteschema('kustype.xsd',  dbms_xmlschema.DELETE_CASCADE_FORCE);
     dbms_xmlschema.deleteschema('kustypt.xsd',  dbms_xmlschema.DELETE_CASCADE_FORCE);
     dbms_xmlschema.deleteschema('kustypb.xsd',  dbms_xmlschema.DELETE_CASCADE_FORCE);
     dbms_xmlschema.deleteschema('kustypbt.xsd', dbms_xmlschema.DELETE_CASCADE_FORCE);
     dbms_xmlschema.deleteschema('kusparse.xsd', dbms_xmlschema.DELETE_CASCADE_FORCE);
  END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -31000 THEN NULL;          -- Not an xml schema
        ELSE raise; 
        END IF;
END;
/

Rem=========================================================================
Rem End Metadata API downgrade items
Rem=========================================================================

Rem=========================================================================
Rem BEGIN Logical Standby downgrade items
Rem=========================================================================
Rem
Rem BUG 6909095
Rem Convert Logical Standby Ckpt data from 11.2 format to 11.1 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_112to11;
end;
/

Rem=========================================================================
Rem End Logical Standby downgrade items
Rem=========================================================================


Rem *************************************************************************
Rem BEGIN Archive Provider drop/downgrade actions
Rem
Rem Drop all tables created by DBMS_ARCHIVE_PROVIDER
Rem *************************************************************************

begin
    sys.dbms_arch_provider_intl.dropProviderTables;
end;
/

Rem *************************************************************************
Rem END   archive provider drop/downgrade actions
Rem *************************************************************************



Rem =========================================================================
Rem END STAGE 2: downgrade dictionary from current release 11.1.0
Rem =========================================================================

BEGIN
   dbms_registry.downgraded('CATALOG','11.1.0');
   dbms_registry.downgraded('CATPROC','11.1.0');
END;
/

Rem *************************************************************************
Rem END f1101000.sql
Rem *************************************************************************
