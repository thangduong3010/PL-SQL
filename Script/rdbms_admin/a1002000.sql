Rem
Rem $Header: rdbms/admin/a1002000.sql /st_rdbms_11.2.0/2 2013/01/28 12:01:59 pkale Exp $
Rem
Rem a1002000.sql
Rem
Rem Copyright (c) 2005, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      a1002000.sql - additional ANONYMOUS BLOCK dictionary upgrade.
Rem                     Upgrade Oracle RDBMS from 10.2.0 to the new release
Rem
Rem
Rem    DESCRIPTION
Rem      Additional upgrade script to be run during the upgrade of an
Rem      10.2.0 database to the new release.
Rem
Rem      This script is called from catupgrd.sql and a1001000.sql
Rem
Rem      Put any anonymous block related changes here.
Rem      Any dictionary create, alter, updates and deletes  
Rem      that must be performed before catalog.sql and catproc.sql go 
Rem      in c1002000.sql
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: upgrade from 10.2 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      01/22/13 - Backport pkale_blr_backport_14774091_11.2.0.3.0
Rem                           from st_rdbms_11.2.0
Rem    shjoshi     07/26/12 - bug 13646689: Add join predicate on category for
Rem                           sqlobj$auxdata
Rem    shbose      11/04/09 - 9068654: Update destq for Propagation
Rem    shbose      09/20/09 - Bug 8764375: Upgrade changes for schedule
Rem    gagarg      03/28/09 - Lrg 3824865: Move plsql NTFN changes to 
Rem                           a1101000.sql file
Rem    gagarg      09/05/08 - Bug7360952: Drop PLSQL notification queue and
Rem                           queue table
Rem    gagarg      03/10/08 - Add event 10851 to enable DDL on AQ tables
Rem    pbelknap    08/20/07 - #6351429 - check for rerun case for sqltune
Rem                           schema
Rem    vakrishn    07/25/07 - bug 6270136 num_mappings has null value
Rem    rburns      07/10/07 - add 11.1 patch release script
Rem    jawilson    05/23/07 - create metadata cache obj for propagation jobs
Rem    qiwang      06/24/07 - BUG 5845153: lsby ckpt upgrade/downgrade
Rem                           conversion
Rem    jawilson    05/23/07 - create metadata cache obj for propagation jobs
Rem    pbelknap    06/23/07 - correct update of param flags on adv upg
Rem    kyagoub     06/24/07 - use advisor id instead of name
Rem    kyagoub     06/16/07 - set default execution type parameter for sqltune
Rem    absaxena    06/05/07 - use invalidation_reg_id$ instead of aq sequence
Rem    achoi       05/14/07 - use DEFINING_EDITION
Rem    skabraha    05/25/07 - call script to upgrade to type tables
Rem    pbelknap    05/10/07 - set execution types for 10g sqltune tasks during
Rem                           upgrade
Rem    achoi       05/14/07 - redefine "_CURRENT_EDITION_OBJ" here
Rem    cdilling    05/01/07 - fix execute immediates 
Rem    nbhatt      04/20/07 - fix unneeded messages into alert log in
Rem                           subscriber upgrade
Rem    pbelknap    04/05/07 - only set upgraded_exec for tasks not in INITIAL
Rem                           state
Rem    jawilson    04/20/07 - add idle_timeout parameter, handle new
Rem                           default value for propagation start_time
Rem    rburns      04/05/07 - move OCM drop user
Rem    pbelknap    03/05/07 - lrg 2885063 - add execution id to insert
Rem    jawilson    12/19/06 - use event-based schedules for propagation
Rem    dvoss       01/24/07 - gather logmnr table stats
Rem    dvoss       01/04/07 - logminer upgrade fixes
Rem    sjanardh    08/17/06 - Upgrade changes for JMS online subscriber
Rem    cdilling    12/06/06 - 
Rem    vakrishn    12/19/06 - do not convert 9.2 mappings - they are in GMT
Rem    vakrishn    12/05/06 - eliminate dups in smon_scn_time when converting
Rem                           from local_to_gmt
Rem    ddas        10/27/06 - rename OPM to SPM
Rem    ddas        10/02/06 - plan_hash_value=>plan_id, add version
Rem    bpanchap    10/10/06 - CDC purge job upgrade changes
Rem    hosu        10/25/06 - lrg 2599955 (check 942 error for rerun)
Rem    arogers     10/10/06 - 5572026 - remove 4594739 for kswssetupaq 
Rem    mcusson     09/22/06 - Include partition type in call to GetTableMCV
Rem    mziauddi    08/31/06 - do not create sql$_aux (sql$) as an IOT
Rem    hosu        08/19/06 - fix outline_data xml generation
Rem    kyagoub     08/17/06 - fix SPM upgrade diff
Rem    hosu        07/21/06 - upgrade for SPM
Rem    ilistvin    08/02/06 - move AUTOTASK upgrade logic to a procedure
Rem    kyagoub     08/10/06 - remove not null costraints from
Rem                           wri$_adv_sqlt_plans
Rem    schakkap    07/17/06 - upgrade datapump user stats table 
Rem    jawilson    06/23/06 - scheduler-based propagation 
Rem    ilistvin    07/13/06 - enable resource plan for Maintenance WIndows 
Rem    kyagoub     06/12/06 - add new column to wri_adv_sqlt_plan_hash 
Rem    ilistvin    07/06/06 - disable GATHER_STATS_JOB and AUTO_SPACE_ADVISOR 
Rem                           on upgrade 
Rem    abrown      06/12/06 - Set logmnrc_gtlo.logmnrMCV on upgrade 
Rem    adowning    06/13/06 - notification upgrade 
Rem    gssmith     04/19/06 - STS conversion 
Rem    gssmith     03/21/06 - Add advisor items 
Rem    gssmith     06/06/06 - Advisor framework upgrades 
Rem    kneel       06/01/06 - upgrade for ha event subscriber 
Rem    dvoss       05/24/06 - fixup logmnrc_gtlo.unsupportedcols 
Rem    ilistvin    06/07/06 - do not assign resource plan for maintenance 
Rem                           windows 
Rem    ilistvin    05/12/06 - add upgrade script for AUTOTASK 
Rem    kyagoub     05/21/06 - add test_execute action to sqltune 
Rem    kyagoub     05/08/06 - add add suport of multi-exec to advisor 
Rem                           framework 
Rem    vakrishn    02/08/06 - lrg-1960928 : changing index flashback timestamp 
Rem                           to GMT 
Rem    abrown      10/10/05 - bug 3776830: unwind dictionary 
Rem    wyang       10/19/05 - change flashback timestamp to GMT 
Rem    spommere    09/06/05 - Fix bug 4594739 
Rem    samepate    07/18/05 - remove obsolete scheduler objects
Rem    cdilling    06/15/05 - cdilling_add_upgrade_scripts
Rem    cdilling    06/08/05 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 10.2 to current release
Rem =========================================================================

Rem Redefine "_CURRENT_EDITION_OBJ" with a simple OBJ$ definition to speed up
Rem dict view query during component upgrade.
Rem It will be replaced with its proper definition in utlmmig.sql
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
       o.owner#, 
       NULL
from obj$ o
/
execute DBMS_SESSION.RESET_PACKAGE; 


Rem Insert PL/SQL blocks here
   
Rem ===============================
Rem Define the HAE_SUB subscriber for the alert_que (rule changed)
Rem ===============================
  
DECLARE  

  subscriber sys.aq$_agent := sys.aq$_agent('HAE_SUB',null,null); 

BEGIN 

   BEGIN
      
      dbms_aqadm_sys.remove_subscriber(
        queue_name => 'SYS.ALERT_QUE',
        subscriber => subscriber);

   EXCEPTION
      WHEN OTHERS THEN
        IF sqlcode = -24035 THEN NULL;
        ELSE RAISE;
        END IF;
   END;

   dbms_aqadm_sys.add_subscriber(
     queue_name => 'SYS.ALERT_QUE',
     subscriber => subscriber,
     rule => 'tab.user_data.MESSAGE_LEVEL <> '
     || sys.dbms_server_alert.level_clear ||
     ' AND tab.user_data.MESSAGE_GROUP = ' ||
     '''High Availability''',
     transformation => 'SYS.haen_txfm_obj',
     properties =>
     dbms_aqadm_sys.NOTIFICATION_SUBSCRIBER
     + dbms_aqadm_sys.PUBLIC_SUBSCRIBER); 

END;
/

Rem ===============================
Rem Streams notification related upgrade
Rem (Should be before the dbms_scheduler upgrade)       
Rem ===============================

Rem ===============================
Rem Add Subscriber Table columns
Rem SCN_AT_REMOVE, MODIFICATION_TIME,
Rem CREATION_TIME, DELETION_TIME
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
                    || ' ADD (SCN_AT_REMOVE NUMBER, '||
                    'CREATION_TIME TIMESTAMP WITH TIME ZONE, ' ||
                    'MODIFICATION_TIME TIMESTAMP WITH TIME ZONE, ' ||
                    'DELETION_TIME TIMESTAMP WITH TIME ZONE )' ;
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

-- Turn OFF the event to disable DDL on AQ tables
alter session set events  '10851 trace name context off';

DECLARE
  CURSOR reg_cur IS
   SELECT rowid from reg$;

  update_stmt    VARCHAR2(1000);
  reg_id         NUMBER;        
BEGIN

  update_stmt := 'UPDATE REG$ set reg_id = :1 where rowid = :2';
  -- for each existing registration, populate regid
  FOR reg_rec IN reg_cur 
  LOOP 
    EXECUTE IMMEDIATE update_stmt USING 
        sys.invalidation_reg_id$.nextval, reg_rec.rowid;
  END LOOP;
  COMMIT;

END;
/



Rem ===============================
Rem Begin dbms_scheduler changes
Rem drop obsolete scheduler objects
Rem ===============================

-- this drops rules and rulesets on the job queue
-- we need to remove the rules/rulesets manually after calling
-- dbms_streams_adm.remove_rule
DECLARE
  type varchartab is table of varchar2(70);
  rules varchartab;
  rulesets varchartab;
  eval_ctxs varchartab;
  i pls_integer;
BEGIN
  select rule_owner ||'.'|| rule_name name bulk collect into rules
    from dba_streams_message_rules where streams_name
    in ('SCHEDULER_COORDINATOR','SCHEDULER_PICKUP') ;

  select rule_set_owner ||'.'|| rule_set_name name bulk collect into rulesets
    from dba_streams_message_consumers where queue_name = 'SCHEDULER$_JOBQ' ;

  select evaluation_context_owner ||'.'|| evaluation_context_name bulk collect
    into eval_ctxs from dba_evaluation_context_vars where variable_type
    in ('"SYS"."SCHEDULER$_JOB_EXTERNAL"', '"SYS"."SCHEDULER$_JOB_RESULTS"',
        '"SYS"."SCHEDULER$_JOB_FIXED"');

  BEGIN
    sys.dbms_streams_adm.remove_rule(null, 'DEQUEUE', 'SCHEDULER_COORDINATOR',
      true, true);
  EXCEPTION
  WHEN others THEN
    IF sqlcode = -23605 THEN NULL;
       -- suppress invalid value for STREAMS parameter error
    ELSE raise;
    END IF;
  END;

  BEGIN
    sys.dbms_streams_adm.remove_rule(null, 'DEQUEUE', 'SCHEDULER_PICKUP',
      true, true);
  EXCEPTION
  WHEN others THEN
    IF sqlcode = -23605 THEN NULL;
       -- suppress invalid value for STREAMS parameter error
    ELSE raise;
    END IF;
  END;

  IF rules.COUNT > 0 THEN
    FOR i IN rules.FIRST..rules.LAST LOOP
      BEGIN
        dbms_rule_adm.drop_rule(rules(i),TRUE);
      EXCEPTION
      WHEN others THEN
        IF sqlcode = -24147 THEN NULL;
           -- suppress rule does not exist error
        ELSE raise;
        END IF;
      END;
    END LOOP;
    END IF;

  IF rulesets.COUNT > 0 THEN
    FOR i IN rulesets.FIRST..rulesets.LAST LOOP
      BEGIN
        dbms_rule_adm.drop_rule_set(rulesets(i),TRUE);
      EXCEPTION
      WHEN others THEN
        IF sqlcode = -24141 THEN NULL;
           -- suppress rule set does not exist error
        ELSE raise;
        END IF;
      END;
    END LOOP;
  END IF;

  IF eval_ctxs.COUNT > 0 THEN
    FOR i IN eval_ctxs.FIRST..eval_ctxs.LAST LOOP
      BEGIN
        dbms_rule_adm.drop_evaluation_context(eval_ctxs(i),TRUE);
      EXCEPTION
      WHEN others THEN
        IF sqlcode = -24150 THEN NULL;
           -- suppress evaluation context does not exist error
        ELSE raise;
        END IF;
      END;
    END LOOP;
  END IF;

  BEGIN
    dbms_aqadm.stop_queue(queue_name => 'scheduler$_jobq');
    dbms_aqadm.drop_queue(queue_name => 'scheduler$_jobq');
  EXCEPTION
  WHEN others THEN
    IF sqlcode = -24010 THEN NULL;
       -- suppress queue does not exist error
    ELSE raise;
    END IF;
  END;

  BEGIN
    dbms_aqadm.drop_queue_table(queue_table => 'scheduler$_jobqtab');
  EXCEPTION
  WHEN others THEN
    IF sqlcode = -24002 THEN NULL;
       -- suppress queue table does not exist error
    ELSE raise;
    END IF;
  END;
END;
/


Rem ==========================
Rem End dbms_scheduler changes
Rem ==========================


Rem =========================
Rem Begin CDC changes
Rem =========================

DECLARE
CURSOR cdc_c IS	SELECT 	s.job, s.next_date, s.interval, s.broken, s.what
                FROM 	sys.dba_jobs s
		WHERE   s.what = 'SYS.DBMS_CDC_PUBLISH.PURGE();';
NO_JOB         EXCEPTION;
PRAGMA         EXCEPTION_INIT(NO_JOB, -31626);

BEGIN
  FOR cdc_c_rec in cdc_c LOOP
                      
  -- drop old job
  BEGIN
    dbms_ijob.remove(cdc_c_rec.job);
  EXCEPTION
    WHEN no_job  THEN
      dbms_system.ksdwrt(1, 'There is no default CDC purge job');
  END;

  dbms_scheduler.create_job(job_name => 'cdc$_default_purge_job',
    job_type => 'PLSQL_BLOCK',
    job_action=> cdc_c_rec.what,
    start_date => cdc_c_rec.next_date,
    repeat_interval => cdc_c_rec.interval,
    enabled => false);
    
 IF cdc_c_rec.broken = 'N' THEN
    dbms_scheduler.enable('cdc$_default_purge_job');
  END IF;
 
 END LOOP;

END;
/

Rem =========================
Rem END CDC changes
Rem =========================

Rem =====================
Rem Begin Streams changes
Rem =====================

Rem  Upgrade propagation schedules
Rem  

alter session set events '10866 trace name context forever, level 4';

DECLARE
CURSOR s_c IS	SELECT 	s.oid, s.destination, s.duration, s.jobno, s.instance,
			s.latency, s.disabled, s.last_run, s.spare1, 
			s.start_time, s.next_time, t.schema, q.name, t.flags
                FROM    sys.aq$_schedules s, system.aq$_queues q,
                        system.aq$_queue_tables t
		WHERE 	q.oid = s.oid AND t.objno = q.table_objno AND
                        s.job_name IS NULL;
jobname        VARCHAR2(30);
schedule_type  VARCHAR2(30);
q_spec         VARCHAR2(200);
my_start_time  DATE;
saved_state    BOOLEAN;
at_pos         BINARY_INTEGER;
dest_q          BINARY_INTEGER := 0;
NO_JOB         EXCEPTION;
PRAGMA         EXCEPTION_INIT(NO_JOB, -31626);

BEGIN

  -- We create a new propagation schedule using dbms_scheduler,
  -- preserving the properties under dbms_job.
  -- However, we do not set the failure count of the scheduler job,
  -- even if the dbms_job had errors.
  FOR s_c_rec in s_c LOOP
                      
  -- drop old job, ignoring errors if job doesn't exist
  BEGIN
    IF (s_c_rec.jobno IS NOT NULL) THEN
      dbms_ijob.remove(s_c_rec.jobno);
      commit;
    ELSE
      dbms_system.ksdwrt(1, 'AQ: Job is null for schedule:'||
                        'queue:'||s_c_rec.oid ||' destination:'||
                         s_c_rec.destination||' Job :'||s_c_rec.jobno);
    END IF;
  EXCEPTION
    WHEN no_job  THEN
      dbms_system.ksdwrt(1, 'AQ:Job does not exist for schedule:'||
                         'queue:'||s_c_rec.oid ||' destination:'||
                         s_c_rec.destination||' Job :'||s_c_rec.jobno);
    WHEN OTHERS THEN
      dbms_system.ksdwrt(1, 'AQ: ' || SQLERRM);
      dbms_system.ksdwrt(1, 'AQ:Job not dropped for schedule:'||
                         'queue:'||s_c_rec.oid ||' destination:'||
                         s_c_rec.destination||' Job :'||s_c_rec.jobno);
  END;

  -- If start time is in the past, use NULL as the start date (new default)
  IF s_c_rec.start_time < SYSDATE THEN
    my_start_time := NULL;
  ELSE
    my_start_time := s_c_rec.start_time;
  END IF;

  -- determine whether destination queue is specified
  at_pos := INSTRB(s_c_rec.destination, '@', 1, 1); 
  IF (at_pos = LENGTHB(s_c_rec.destination)) THEN
    dest_q := 0;
  ELSE
    dest_q := 1;
  END IF;

  -- determine the type of schedule we will use
  schedule_type := dbms_prvtaqip.get_sched_type(s_c_rec.flags,
                     my_start_time, s_c_rec.duration, s_c_rec.latency,
                     s_c_rec.next_time);

  IF schedule_type = 'EVENT' THEN
    -- Scheduler expects the format A.B,C instead of A.B:C that is the
    -- format for AQ registrations
    dbms_aqadm_syscalls.kwqa_3gl_SetRegistrationName(q_spec,
      s_c_rec.schema, s_c_rec.name, s_c_rec.destination, ',', dest_q);
  END IF;

  jobname := dbms_scheduler.generate_job_name('AQ_JOB$_');

  BEGIN
    sys.dbms_aqadm_syscalls.kwqa_3gl_BeginTrans(TRUE, saved_state);

    sys.dbms_aqadm_syscalls.kwqa_3gl_CreateCacheObject(
      s_c_rec.destination, jobname, s_c_rec.duration,  s_c_rec.oid,
      s_c_rec.latency, dest_q);

    dbms_isched.create_job(
           job_name => jobname,
           job_style => 'REGULAR',
           program_type => 'NAMED',
           program_action => 'SYS.AQ$_PROPAGATION_PROGRAM',
           number_of_arguments => null,
           schedule_type => schedule_type,
           schedule_expr => s_c_rec.next_time,
           queue_spec => q_spec,
           start_date => my_start_time,
           end_date  => null,
           job_class => 'AQ$_PROPAGATION_JOB_CLASS',
           comments => null,
           enabled => false,
           auto_drop => false,
           invoker => 'SYS',
           sys_privs => dbms_scheduler.check_sys_privs(),
           aq_job => TRUE);

    dbms_scheduler.set_attribute(jobname, 'max_failures', 16);
    dbms_scheduler.set_attribute(jobname, 'restartable', TRUE);
    dbms_scheduler.set_attribute(jobname, 'instance_id', s_c_rec.instance);

    dbms_scheduler.set_job_argument_value(job_name => jobname,
      argument_position => 3,
      argument_value => dbms_assert.enquote_name(s_c_rec.schema, FALSE)
                        || '.' ||
                        dbms_assert.enquote_name(s_c_rec.name, FALSE));
    dbms_scheduler.set_job_argument_value(job_name => jobname,
      argument_position => 4,
      argument_value => s_c_rec.destination);
    dbms_scheduler.set_job_argument_value(job_name => jobname,
      argument_position => 5,
      argument_value => s_c_rec.duration);
    dbms_scheduler.set_job_argument_value(job_name => jobname,
      argument_position => 6,
      argument_value => s_c_rec.latency);
    dbms_scheduler.set_job_argument_value(job_name => jobname,
      argument_position => 7,
      argument_value => s_c_rec.spare1);
    dbms_scheduler.set_job_argument_value(job_name => jobname,
      argument_position => 8,
      argument_value => 240);
    dbms_scheduler.set_job_argument_value(job_name => jobname,
      argument_position => 9,
      argument_value => 100);
    dbms_scheduler.set_job_argument_value(job_name => jobname,
      argument_position => 10,
      argument_value => 0);


    UPDATE sys.aq$_schedules 
    SET job_name = jobname, jobno = NULL
    WHERE oid = s_c_rec.oid AND DESTINATION = s_c_rec.destination;

    sys.dbms_aqadm_syscalls.kwqa_3gl_EndTrans(TRUE, saved_state);

    -- note: script is idempotent, except schedules may remain
    -- disabled if errors occur during upgrade
    -- however, we cannot moved enable inside the auto-commit block.
    IF s_c_rec.disabled = 'N' AND schedule_type <> 'ONCE' AND
       schedule_TYPE <> 'NOW' 
    THEN
      dbms_scheduler.enable(jobname);
    END IF;

    -- Run-once schedules: enable if not already run
    IF s_c_rec.disabled = 'N' AND (schedule_type = 'ONCE' OR 
       schedule_type = 'NOW') AND s_c_rec.last_run IS NULL
    THEN
      dbms_scheduler.enable(jobname);
    END IF;

  EXCEPTION
    WHEN OTHERS THEN
      sys.dbms_aqadm_syscalls.kwqa_3gl_EndTrans(FALSE, saved_state);
      -- alert log message
      dbms_system.ksdwrt(dbms_system.trace_file, 'AQ: ' || SQLERRM);
      dbms_system.ksdwrt(dbms_system.trace_file, 
                         'AQ: propagation schedule upgrade failed ' || 
                         ' for queue:' ||s_c_rec.oid ||' destination:'||
                         s_c_rec.destination||' Job :'||s_c_rec.jobno);
  END;
  
  END LOOP;

END;
/

alter session set events '10866 trace name context off';

Rem ===================
Rem End Streams changes
Rem ===================

  
Rem LOGMNRC_GTLO.UNSUPPORTEDCOLS was added in 11.  We need to populate
Rem this on upgrade for anything left in LOGMNRC_GTLO after cleaning out
Rem all of the data covered by the other LOGMNR_* tables.  

declare
  cursor uid_cursor is
       select logmnr_uid from system.logmnr_uid$;
begin
  for uid_rec in uid_cursor loop
    logmnr_dict_cache.cleanout(uid_rec.logmnr_uid, null, null);
    commit;
  end loop;
end;
/

update system.logmnrc_gtlo t
   set unsupportedcols = (
        select sum (distinct case c.type#
                             when /* DTYCHR */ 1 then 0
                             when /* DTYSTR */ 5 then 0
                             when /* DTYAFC */ 96 then 0
                             when /* DTYNUM */ 2 then 0 
                             when /* DTYINT */ 3 then 0
                             when /* DTYFLT */ 4 then 0
                             when /* DTYIBFLOAT */ 100 then 0
                             when /* DTYIBDOUBLE */ 101 then 0
                             when /* DTYBIN */  23 then 0
                             when /* DTYDAT */  12 then 0
                             when /* DTYTIME */ 178 then 0
                             when /* DTYTTZ */ 179 then 0
                             when /* DTYSTAMP */ 180 then 0
                             when /* DTYSTZ */ 181 then 0
                             when /* DTYSITZ */ 231 then 0
                             when /* DTYIYM */ 182 then 0
                             when /* DTYIDS */ 183 then 0
                             when /* DTYCLOB */ 112 then 0
                             when /* DTYBLOB */ 113 then 0
                             when /* DTYLNG */ 8 then 2
                             when /* DTYLBI */ 24 then 4
                             when /* DTYOPQ */ 58 then 8
                             when /* DTYBRI */ 69 then 16
                             when /* DTYADT */ 121 then 32
                             when /* DTYNTB */ 122 then 64
                             when /* DTYNAR */ 123 then 128
                             when /* DTYBURI */ 208 then 256
                             else 1 end) unsupported_flags
          from system.logmnrc_gtcs c
          where c.logmnr_uid = t.logmnr_uid
            and c.obj# = t.baseobj#
            and c.objv# = t.baseobjv#)
        where unsupportedcols is null;
commit;
  
Rem ===========================
Rem Begin changes for upgrade of
Rem logmnrc_gtcs.logmnrMCV.
Rem ===========================

declare
  cursor logmnrc_gtcs_cur is
    select C.LOGMNR_UID, C.KEYOBJ#, C.BASEOBJ#, C.BASEOBJV#, C.UNSUPPORTEDCOLS,
           C.PROPERTY, C.LOGMNRTLOFLAGS, C.COMPLEXTYPECOLS, C.PARTTYPE
    from system.logmnrc_gtlo C, system.logmnr_dictionary$ D
    where C.LOGMNR_UID = D.LOGMNR_UID AND
          (C.LOGMNRMCV is NULL or C.LOGMNRMCV = '99.9.9.9.9');
  LogmnrMCV_out VARCHAR2(30);
  UpdateCount   NUMBER := 0;
begin
  FOR logmnrc_gtcs_v IN logmnrc_gtcs_cur LOOP
    logmnr_dict_cache.GetTableMCV(logmnrc_gtcs_v.LOGMNR_UID,
                                  logmnrc_gtcs_v.BASEOBJ#,
                                  logmnrc_gtcs_v.BASEOBJV#,
                                  logmnrc_gtcs_v.UNSUPPORTEDCOLS,
                                  logmnrc_gtcs_v.PROPERTY,
                                  logmnrc_gtcs_v.PARTTYPE,
                                  logmnrc_gtcs_v.LOGMNRTLOFLAGS,
                                  logmnrc_gtcs_v.COMPLEXTYPECOLS,
                                  TRUE,  /* Use logmnrc_gtcs */
                                  LogmnrMCV_out);
    update system.logmnrc_gtlo co
      set co.LOGMNRMCV = LogmnrMCV_out
      where co.LOGMNR_UID = logmnrc_gtcs_v.LOGMNR_UID AND
            co.KEYOBJ#    = logmnrc_gtcs_v.KEYOBJ# AND
            co.BASEOBJV#  = logmnrc_gtcs_v.BASEOBJV#;
    UpdateCount := UpdateCount + SQL%ROWCOUNT;
    IF UpdateCount > 1000 THEN
      commit;
      UpdateCount := 0;
    END IF;
  END LOOP;
  commit;
end;
/

Rem ===========================
Rem End changes for upgrade of
Rem logmnrc_gtcs.logmnrMCV.
Rem ===========================

Rem Update statistics on partitioned logminer tables
declare
  cursor c1 is 
    select case when bitand(x.flags, 2) = 2
                 then 'LOGMNR_' || x.name 
                 else x.name end name
       from x$krvxdta x
      where bitand(flags,1) = 1;
begin
  for crec in c1 loop
    dbms_output.put_line('gather stats for : ' || crec.name);
    dbms_stats.gather_table_stats('system',
                                  crec.name,
                                  METHOD_OPT => 'FOR ALL COLUMNS SIZE AUTO',
                                  no_invalidate => false);
  end loop;
end;
/

Rem=========================================================================
Rem BEGIN Logical Standby upgrade items
Rem=========================================================================
Rem
Rem BUG 5845153
Rem Convert Logical Standby Ckpt data from 10.2 format to 11 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_102to11;
end;
/

Rem=========================================================================
Rem End Logical Standby upgrade items
Rem=========================================================================

Rem ======================================
Rem SQL Plan Management (SPM) BEGIN
Rem ======================================

Rem 
Rem 1. populdate sqlobj$ table 
Rem    sqlprof$ stores profile which obj_type is 1 and plan_id = 0
Rem    flags is mapped from sqlprof$.status.
Rem    NOTE we are using the old (i.e., 10g) sql$ table. So we must do that
Rem    before step 2.
Rem 
begin
  execute immediate
  'insert into sqlobj$ (signature, category, obj_type, plan_id, ' ||
  'name, flags, last_executed) ' ||
  'select sp.signature, sp.category, 1, 0, ' ||
  '       sp.sp_name, decode(sp.status, 1, 1, 2, 0, sp.status), ' ||
  '       s.last_used ' ||
  '  from sqlprof$ sp, sql$ s ' ||
  '  where sp.signature = s.signature';

  exception
    when others then
      -- Invalid table or column error (in the case of a re-run) 
      if (sqlcode = -942 or sqlcode = -904) then
        null;
      else 
        raise; 
      end if; 
end;
/

commit;


Rem 
Rem 2. change definition of sql$ and move it to SYSAUX
Rem
-- temporary table
create table sql$_aux(
       signature           NUMBER,                                   /* join key */
       inuse_features      NUMBER       NOT NULL,
       flags               NUMBER       NOT NULL,
       spare1              NUMBER,
       spare2              CLOB
--       CONSTRAINT sql$_pkey PRIMARY KEY (signature)
     )
--    ORGANIZATION INDEX
    TABLESPACE sysaux
/

-- copy over values from the old table
insert into sql$_aux (signature, inuse_features, flags)
select signature, inuse_features, flags from sql$
/

-- drop the table and its associated indices
drop table sql$
/

-- rename the temporary table to its new name
alter table sql$_aux rename to sql$
/

create unique index i_sql$_pkey on sql$ (signature)
  tablespace sysaux
/

commit;

Rem
Rem 3. change definition of sql$text and move it to SYSAUX
Rem 
CREATE TABLE sql$text_aux (
       signature           NUMBER        NOT NULL,                   /* join key */
       sql_handle          VARCHAR2(30),                           /* search key */
       sql_text            CLOB          NOT NULL,
       spare1              NUMBER,
       spare2              CLOB
     )
     TABLESPACE sysaux
/

insert into sql$text_aux (signature, sql_text)
select signature, sql_text
from sql$text
/

drop table sql$text
/

alter table sql$text_aux rename to sql$text
/

-- populate sql$text sql_handle
create or replace procedure generate_sql_handle_from_sig(
  sig IN number, handle out varchar2)
is
  language C
    name "qsmoGenSqlHandleExt"
    with context
    parameters(context, sig OCINUMBER, handle STRING)
    library dbms_spm_lib;
/ 

-- copy over values from the old table
declare
  handle varchar2(30);
begin
  for rec in (select signature, sql_text
              from sql$text)
  loop

   generate_sql_handle_from_sig(rec.signature, handle);
   update sql$text t
   set t.sql_handle = handle
   where t.signature = rec.signature;

  end loop; 
end;
/

alter table sql$text modify sql_handle not null;


CREATE UNIQUE INDEX i_sql$text_handle ON sql$text (sql_handle)
 TABLESPACE sysaux
/

drop procedure generate_sql_handle_from_sig;

commit;

Rem
Rem 5. populate sqlobj$data
Rem

begin
  execute immediate
  'insert into sqlobj$data (signature, category, obj_type, ' ||
  'plan_id, comp_data) ' ||
  'select signature, category, 1, 0, ' ||
  '  XMLELEMENT("outline_data", ' ||
  '    XMLAGG(XMLELEMENT("hint", XMLCdata(sa.attr_val)))).getClobVal() ' || 
  'from sqlprof$attr sa ' ||
  'group by signature, category';

  exception
    when others then
      -- Invalid table error (in the case of a re-run) 
      if (sqlcode = -942) then
        null;
      else 
        raise; 
      end if; 
end;
/


-- drop the table and its associated indices 
drop table sqlprof$attr;

Rem
Rem 6. populate the sqlobj$auxdata table
Rem

begin
  execute immediate
  'insert into sqlobj$auxdata (signature, category, obj_type, ' || 
  'plan_id, description, origin, created, last_modified) ' ||
  'select sp.signature, sp.category, 1, 0, ' ||
  '       sd.description, sp.type, sp.created, sp.last_modified ' ||          
  'from sqlprof$ sp, sqlprof$desc sd, sql$ s ' ||
  'where sp.signature = sd.signature(+) and ' ||
  '      sp.category = sd.category(+) and ' ||
  '      sp.signature = s.signature';

  exception
    when others then
      -- Invalid table error (in the case of a re-run) 
      if (sqlcode = -942) then
        null;
      else 
        raise; 
      end if; 
end;
/

-- drop the old table and its associated indices
drop table sqlprof$
/
drop table sqlprof$desc
/

Rem ======================================
Rem SQL Plan Management (SPM) END
Rem ======================================


Rem ===========================
Rem changes for bug 6270136 - 9.2 mappings may have null for num_mappings
Rem ===========================
update smon_scn_time set num_mappings = 0 where num_mappings is NULL
/
commit
/

Rem ===========================
Rem Begin changes for bug 4252637 
Rem ===========================

Rem Change Flashback timestamp in tab$, ind$ and smon_scn_time to GMT
Rem 1. Create timestamp conversion functions.
create or replace library dbms_fmig_lib trusted as static;
/

create or replace function ktf_mig_time(local_to_gmt IN number, time IN number)
return number is
  language C
    name "ktfmigextime"
    with context
    parameters(context, local_to_gmt OCINUMBER, time OCINUMBER, RETURN)
    library dbms_fmig_lib;
/ 

create or replace function ktf_mig_map(local_to_gmt IN number,
                                       maplen IN number, map IN raw)
return raw is
  language C
    name "ktfmigexmap"
    with context
    parameters(context, local_to_gmt OCINUMBER, maplen OCINUMBER,
               map OCIRaw, return INDICATOR sb2, RETURN OCIRaw)
    library dbms_fmig_lib;
/

create or replace function local_time_to_gmt(local_time IN number)
return number is
begin
  return ktf_mig_time(1, local_time);
end;
/

create or replace function local_date_to_gmt(local_date IN date)
return date is
  gmt_date date;
  hour_dif number;
begin
  hour_dif := extract(timezone_hour from systimestamp);
  gmt_date := local_date - numtodsinterval(hour_dif, 'hour');
  return gmt_date;
end;
/

create or replace function local_tim_scn_map_to_gmt(maplen IN number,
                                                    map IN raw)
return raw is
begin
  return ktf_mig_map(1, maplen, map);
end;
/


Rem 2. Do the conversion:
Rem The following updates on tab$, ind$ and smon_scn_time are in one transaction.
Rem During upgrade, the spare6 column of some rows may have been updated and
Rem thus already in GMT. However, we try to err on the conservative side:
Rem (1) if GMT >= local time,
Rem       spare6 of converted rows will be > instance startup time.
Rem       spare6 of other rows will be < instance startup time.
Rem (2) if GMT < local time, converted time will be smaller.
Rem     So it is OK that we miss to convert some rows. But we
Rem     should not convert a row twice.
Rem       spare6 of unconverted rows will be >
Rem         local_date_to_gmt(instance startup time)
declare
  cnt number;
  cursor c1
  is
  select rowid, time_mp from smon_scn_time order by time_mp;
begin
  select count(*) into cnt from props$
  where name = 'Flashback Timestamp TimeZone' and value$ = 'GMT';
  if cnt = 0 then
    delete from props$
    where name = 'Flashback Timestamp TimeZone' and value$ = 'Local Time';
    insert into props$ (name, value$, comment$)
      values('Flashback Timestamp TimeZone', 'GMT',
             'Flashback timestamp converted to GMT');
    if local_date_to_gmt(sysdate) >= sysdate then
      update tab$ set spare6 = local_date_to_gmt(spare6)
        where spare6 < (select startup_time from v$instance);
      update ind$ set spare6 = local_date_to_gmt(spare6)
        where spare6 < (select startup_time from v$instance);
    else
      update tab$ set spare6 = local_date_to_gmt(spare6)
        where spare6 > (select local_date_to_gmt(startup_time) from v$instance);
      update ind$ set spare6 = local_date_to_gmt(spare6)
        where spare6 > (select local_date_to_gmt(startup_time) from v$instance);
    end if;
    delete from smon_scn_time where thread != 0;
    begin
      for c1rec in c1 loop
      begin
        update smon_scn_time set time_mp = local_time_to_gmt(time_mp)
          where orig_thread = 0 and time_mp = c1rec.time_mp;
      exception
        when DUP_VAL_ON_INDEX then
        delete smon_scn_time where rowid = c1rec.rowid and 
          time_mp = c1rec.time_mp;
        continue;
     end;
     end loop;
   end;
   update smon_scn_time set
     tim_scn_map = local_tim_scn_map_to_gmt(num_mappings, tim_scn_map)
     where orig_thread = 0 and num_mappings != 0;
  end if;
  commit;
end;
/

Rem 3. Drop the functions created

drop function local_time_to_gmt;
drop function local_date_to_gmt;
drop function local_tim_scn_map_to_gmt;
drop function ktf_mig_time;
drop function ktf_mig_map;
drop library dbms_fmig_lib;
  
Rem ===========================
Rem End changes for bug 4252637
Rem ===========================


Rem ================================
Rem Begin advisor framework changes
Rem ================================

Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem Upgrade exisitng tasks. We really need it for sqltune tasks. 
Rem because I do not want to do update...select...where, 
Rem I am doing it for every existing task. 
Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

DECLARE
  already_upgraded NUMBER;
BEGIN 

  --
  -- Be careful to avoid re-run of this pl/sql block.  We have insert 
  -- and update statements that we need to avoid running twice.
  -- The TASK_ID column will be changed from NOT NULL to NULL as part of
  -- the upgrade.
  --
  SELECT decode(nullable, 'Y', 1, 0)
  INTO   already_upgraded
  FROM   dba_tab_columns
  WHERE  table_name = 'WRI$_ADV_SQLT_PLANS' and owner = 'SYS' and 
         column_name = 'TASK_ID';

  IF (already_upgraded = 0) THEN

    -- update existing tasks with execution names.  note that we only update
    -- the tasks and objects table for tasks no longer in the INITIAL state.
    -- we do not have these checks on the other tables because tasks in INITIAL
    -- state cannot have findings, recs, actions, etc, as they are all output.
    -- also, plase note that for sql tuning advisor, we update objects but only
    -- the ones created by the advisor when tuning a sql tuning set.  
    UPDATE wri$_adv_tasks 
    SET last_exec_name = 'UPGRADED_EXEC' 
    WHERE status != 1;
  
    UPDATE wri$_adv_objects o 
    SET    exec_name = 'UPGRADED_EXEC' 
    WHERE  EXISTS (SELECT 1 
                   FROM   wri$_adv_tasks t 
                   WHERE  t.id = o.task_id AND t.status != 1 AND
                          (t.advisor_id != 4 /* sqltune */ OR 
                           (t.advisor_id = 4 /* sqltune */ AND
                            o.type = 7 /* sql statement */ AND
                            EXISTS (SELECT 1 
                                    FROM wri$_adv_objects b
                                    WHERE b.task_id = t.id AND 
                                          b.type = 8 /* sql tuning set */))));
  
    UPDATE wri$_adv_findings SET exec_name = 'UPGRADED_EXEC';
    UPDATE wri$_adv_recommendations SET exec_name = 'UPGRADED_EXEC';
    UPDATE wri$_adv_actions SET exec_name = 'UPGRADED_EXEC';
    UPDATE wri$_adv_rationale SET exec_name = 'UPGRADED_EXEC';
    UPDATE wri$_adv_journal SET exec_name = 'UPGRADED_EXEC';
    UPDATE wri$_adv_message_groups SET exec_name = 'UPGRADED_EXEC';

    -- create new executions from the existing tasks. Notice that we are 
    -- only interrested by tasks which have already been executed. I.e.,
    -- which status <> initial (=1)
    --
    --  NOTE we set the execution type to TUNE SQL for old SQL Tuning tasks 
    --  so that our 11g report code will see one
    INSERT INTO wri$_adv_executions
      (id, task_id, name, exec_type, exec_type_id, advisor_id, exec_start, 
       exec_mtime, exec_end, status, status_msg_id, error_msg_id)
    (SELECT wri$_adv_seq_exec.NEXTVAL, id, 'UPGRADED_EXEC', 
            decode(advisor_id, 4, 'TUNE SQL', NULL),     /* sqltune exec_type */
            decode(advisor_id, 4, 1, NULL),           /* sqltune exec_type_id */
            advisor_id, 
            exec_start, mtime, exec_end, 
            status, status_msg_id, error_msg#
     FROM   wri$_adv_tasks
     WHERE  status != 1);
 
    -- in 11 g we use plan_id to identify plan for sqltune
    -- 1. create plan ids in the plan_hash table.
    --    note that we use object_id as sql id for the existing task. 
    --    This is mainly because sql_id is a not null column in this table
    --    and also it is part of the unique index composed key. 
    INSERT INTO wri$_adv_sqlt_plan_hash
      (task_id, exec_name, object_id, sql_id, attribute, plan_hash, plan_id)
      (SELECT task_id, 'UPGRADED_EXEC', object_id, object_id,
              attribute, plan_hash_value, sys.wri$_adv_sqlt_plan_seq.NEXTVAL
       FROM (SELECT UNIQUE task_id, object_id, attribute, 
                           nvl(plan_hash_value, 0) as plan_hash_value
             FROM wri$_adv_sqlt_plans));

    -- 2. update the plan lines table with the new plan ids. 
    UPDATE wri$_adv_sqlt_plans l SET l.plan_id = 
       (SELECT p.plan_id 
        FROM wri$_adv_sqlt_plan_hash p
        WHERE (l.task_id = p.task_id AND  
               l.object_id = p.object_id AND 
               l.attribute = p.attribute));

    -- 3. commit changes;
    commit; 

  END IF;                                              -- already_upgraded = 0
END; 
/

Rem 4. remove existing primary constraint to change it.
ALTER TABLE wri$_adv_sqlt_plans DROP CONSTRAINT wri$_adv_sqlt_plans_pk;

Rem 5. remove not null constraints on columns before set them to null.
ALTER TABLE wri$_adv_sqlt_plans 
MODIFY (task_id NULL, object_id NULL, attribute NULL, plan_hash_value NULL);

Rem 6. set the plan line table old columns to null 
UPDATE wri$_adv_sqlt_plans l 
SET task_id = NULL, object_id = NULL, attribute = NULL, plan_hash_value = NULL;
  
Rem 7. set the new primary key for the plan table
ALTER TABLE wri$_adv_sqlt_plans 
ADD CONSTRAINT wri$_adv_sqlt_plans_pk PRIMARY KEY(plan_id, id)
USING INDEX TABLESPACE SYSAUX;

Rem
Rem Copy new directives to existing tasks
Rem

declare
  cursor task_cur is
    select id,advisor_id
      from sys.wri$_adv_tasks;

  cursor dir_cur (l_id NUMBER) IS
      SELECT a.id,b.name,b.data FROM sys.wri$_adv_directive_defs a,
                    sys.wri$_adv_directive_instances b
        WHERE a.advisor_id = l_id
          and a.id = b.dir_id
          and b.task_id = 0;

  l_task_id binary_integer;
  l_adv_id binary_integer;
  l_dir_id binary_integer;
  l_dir_name varchar2(30);
  l_dir_data clob;
  l_inst_id binary_integer;
  l_cnt binary_integer;
begin
  open task_cur;

  ------------------------------------------------------------------------------
  --  Get each advisor task and copy missing directive instances to it.
  ------------------------------------------------------------------------------

  loop
    fetch task_cur into l_task_id, l_adv_id;
    exit when task_cur%notfound;

    open dir_cur(l_adv_id);
  
    loop
      fetch dir_cur into l_dir_id,l_dir_name,l_dir_data;
      exit when dir_cur%notfound;

      select sys.wri$_adv_seq_dir_inst.nextval into l_inst_id
        from dual;

      select count(*) into l_cnt
        from sys.wri$_adv_directive_instances
        where dir_id = l_dir_id
          and name = l_dir_name
          and task_id = l_task_id;

      --------------------------------------------------------------------------
      --  Only insert new task instance if it doesn't exist
      --------------------------------------------------------------------------

      if l_cnt = 0 then
        insert into sys.wri$_adv_directive_instances 
          (dir_id, inst_id, name, task_id, data)
        values
          (l_dir_id, l_inst_id, l_dir_name, l_task_id, ' ');
  
        update sys.wri$_adv_directive_instances
          set data = l_dir_data
          where inst_id = l_inst_id;
      end if;
    end loop;

    close dir_cur;
  end loop;

  close task_cur;
end;
/

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
    SELECT id,advisor_id FROM sys.wri$_adv_tasks a;

  cursor param_cur (id NUMBER) IS 
    SELECT *
      FROM sys.wri$_adv_def_parameters a
      WHERE a.advisor_id in (id,0);

  l_adv_id binary_integer;
  l_task_id binary_integer;
  l_cnt binary_integer;
  param wri$_adv_def_parameters%ROWTYPE;
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
        INSERT INTO sys.wri$_adv_parameters
          (task_id,name,datatype,value,flags,description)
        VALUES
          (l_task_id, param.name, param.datatype, param.value, 
           param.flags, param.description);
      else
        -- keep the "output" and "not-default" flags if they are already
        -- set.  Overwrite all other flags with the current def_prm values.
        update sys.wri$_adv_parameters
          set description = param.description,
              flags = bitand(flags, 6) + 
                      bitand(param.flags, (POWER(2, 16) - 1) - 6)
        where task_id = l_task_id and name = param.name;
      end if;
    end loop;

    close param_cur;
  end loop;

  close task_cur;
end;
/

Rem=========================================================================
Rem set default execution type for sql tuning advisor
Rem=========================================================================
BEGIN
  EXECUTE IMMEDIATE q'#UPDATE wri$_adv_parameters p 
                       SET value = 'TUNE SQL' 
                       WHERE name = 'DEFAULT_EXECUTION_TYPE' AND 
                             EXISTS (SELECT 1 
                                     FROM wri$_adv_tasks t 
                                     WHERE p.task_id = t.id AND 
                                      t.advisor_id = 4 )#'; /* sqltune */
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE = -942) THEN                 /* table does not exist */
        NULL;
      ELSE
        RAISE;
      END IF;
END;
/
commit;

Rem=========================================================================
Rem Reset all Access Advisor tasks due to STS conversion  
Rem=========================================================================

declare
  cursor task_cur IS 
    SELECT id FROM sys.wri$_adv_tasks a
    where advisor_id = 2;
  l_id number;
begin
  open task_cur;

  loop
    fetch task_cur into l_id;
    exit when task_cur%NOTFOUND;

    prvt_advisor.reset_task(l_id);
  end loop;

  close task_cur;
end;
/

Rem
Rem Initialize new map column data
Rem

update sys.wri$_adv_sqla_map a
  set a.is_sts = 0,
      a.ref_id = 0,
      a.child_id = 0,
      a.name = (select b.name from sys.wri$_adv_tasks b
                where b.id = a.workload_id);
commit;

Rem ===============================
Rem End advisor framework  changes
Rem ===============================

Rem ===============================
Rem Begin AUTOTASK changes
Rem ===============================

BEGIN
 dbms_auto_task_export.POST_UPGRADE_FROM_10G();
EXCEPTION WHEN OTHERS THEN RAISE;
END;
/
Rem ===============================
Rem End AUTOTASK changes
Rem ===============================

Rem ====================================
Rem Begin User stats table format change
Rem ====================================

Rem Stats table definition is changed in 11g, upgrade data pump table.
Rem upgrade_stat_table may recreate the table, so grant the privileges
Rem after upgrading the table

begin
  dbms_stats.upgrade_stat_table('SYS','IMPDP_STATS');
exception
  when others then
    -- ignore already upgraded error message
    if (sqlcode != 20000) then
      raise;
    end if;
end;
/

GRANT SELECT ON sys.impdp_stats TO PUBLIC
/
GRANT INSERT ON sys.impdp_stats TO PUBLIC
/
GRANT DELETE ON sys.impdp_stats TO PUBLIC
/

Rem ===================================
Rem End  User stats table format change
Rem ===================================

Rem==========================================================================
Rem Call script to upgrade type dictionary tables from 8.0 image to
Rem 8.1 image format. If they are already in 8.1 image format, the
Rem script will do nothing.
Rem==========================================================================

set serveroutput on
EXECUTE dbms_objects_utils.upgrade_dict_image;
set serveroutput off

Rem =========================================================================
Rem END type dictionary upgrade
Rem =========================================================================

--Call OCM upgrade remove old CCR schema and directory
@@ocmupgrd

Rem==========================================================================
Rem Call component registry script for 10.2->current release populate 
Rem==========================================================================
EXECUTE dbms_registry_sys.populate_102;

Rem =========================================================================
Rem END STAGE 1: upgrade from 10.2 to the current release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

@@a1101000

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END a1002000.sql
Rem *************************************************************************
