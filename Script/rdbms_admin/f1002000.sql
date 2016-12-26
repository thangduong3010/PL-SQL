Rem $Header: rdbms/admin/f1002000.sql /main/25 2009/09/02 14:33:56 rgmani Exp $
Rem
Rem f1002000.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      f1002000.sql - additional downgrade script from current release 
Rem                     to 10.2.0
Rem
Rem    DESCRIPTION
Rem
Rem      Additional downgrade script to be run during the downgrade from
Rem      current release to 10.2. This must be run before e1002000.sql.
Rem
Rem      This script is called from catdwgrd.sql and f1001000.sql
Rem
Rem	 Put any downgrade actions that reference PL/SQL packages here.
Rem      The PL/SQL packages must be called from this script prior to 
Rem      any downgrade actions in e1002000.sql which could invalidate
Rem      the referenced PL/SQL calls.  
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rgmani      08/31/09 - XbranchMerge rgmani_lrg-3945958 from
Rem                           st_rdbms_11.2.0.1.0
Rem    rgmani      07/23/09 - Fix downgrade LRG
Rem    gagarg      03/28/09 - Lrg3824865: Move plsql NTFN changes to
Rem                           f1101000.sql file
Rem    pbelknap    03/20/09 - move STA downgrade before SPM
Rem    gagarg      09/05/08 - Bug7360952: Drop plsql notification queues
Rem                           created for each instance  
Rem    mjstewar    01/08/08 - drop DRA maintenance jobs
Rem    mtao        01/07/08 - bug 6121044: remove foreign log cf entries
Rem    cdilling    11/28/07 - move dbms_assert calls from e1002000.sql
Rem    rgmani      10/24/07 - 
Rem    jawilson    10/23/07 - force kill jobs left in running state
Rem    cdilling    09/25/07 - move drop data mining programs from e1002000.sql
Rem    rburns      09/25/07 - add 11g downgrade
Rem    sylin       09/24/07 - add drop created class
Rem    pbelknap    09/17/07 - drop SYS_AUTO_SQL_TUNING_TASK
Rem    cdilling    07/11/07 - move .downgraded calls here from e1002000.sql
Rem    jawilson    05/25/07 - drop propagation job cache object
Rem    qiwang      06/28/07 - BUG 5845153: LSBY ckpt downgrade
Rem    jawilson    05/25/07 - drop propagation job cache object
Rem    ilistvin    05/01/07 - fix AUTOTASK downgrade logic
Rem    jawilson    04/24/07 - drop AQ$_PROPAGATION_JOB_CLASS
Rem    akoeller    04/12/07 - Access Advisor changes
Rem    hosu        04/06/07 - move dropping spm package to e1002000.sql
Rem    suelee      03/29/07 - LRG 2902772
Rem    kchen       03/19/07 - fixed lrg 2900123
Rem    schakkap    10/24/06 - delete statistics history entries during
Rem                           downgrade
Rem    arogers     10/10/06 - 5572026 - stop and drop created service metrics
Rem                           queue
Rem    ddas        10/27/06 - rename OPM to SPM
Rem    mziauddi    09/23/06 - move in SPM downgrade script from e1002000.sql
Rem    cdilling    09/14/06 - Created 

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release
Rem =========================================================================

@@f1101000.sql

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary from current release to 10.2.0
Rem =========================================================================

BEGIN
   dbms_registry.downgrading('CATALOG');
   dbms_registry.downgrading('CATPROC');
END;
/

Rem ====================================
Rem BEGIN     SQL Tuning Advisor changes
Rem IMPORTANT This must be done BEFORE SPM downgrade
Rem ====================================

--
-- Drop the new auto task that was created during upgrade to 11g.  We add
-- a little extra code just to be careful that we are really dropping the
-- right task.
--
-- Any auto-created SQL profiles will survive the downgrade.
--
declare
  tname wri$_adv_tasks.name%TYPE;
begin
  select max(name)
  into   tname
  from   wri$_adv_tasks t
  where  t.name = prvt_advisor.TASK_RESERVED_NAME_ASQLT and
         t.owner_name = 'SYS' and
         bitand(t.property, prvt_advisor.TASK_PROP_SYSTEMTASK) <> 0;

  if (tname is not null) then
    dbms_sqltune.drop_tuning_task(tname);
  end if;
end;
/

Rem ====================================
Rem END SQL Tuning Advisor changes
Rem ====================================

Rem -----------------------------------------------
Rem SQL Plan Management (SPM) Downgrade Begin
Rem -----------------------------------------------

Rem truncate new tables 
truncate table sqllog$;
truncate table smb$config;

rem change definition of sql$ and move it to SYSAUX
-- temporary table
create table sql$_sys                      /* base table for SQL Tuning Base */
(
  signature    number  not null,         /* signature of normalized SQL text */
  nhash number         not null,           /* hash value for normalized text */
  sqlarea_hash number  not null,                     /* sql cache hash value */
  last_used    date    not null,                         /* week of last use */
  inuse_features number not null, /* bit map of features used by this object */
                               /* 0x01 - SQLProfiles, 0x02 - stored outlines */
  flags        number  not null,                       /* not used currently */
  modified     date    not null,              /* last modification timestamp */
  incarnation  number  not null,          /* modification incarnation number */
  spare1       number,                                       /* spare column */
  spare2       varchar2(1000)                                /* spare column */
)
/

-- copy over values from the old table
insert into sql$_sys (signature, nhash, sqlarea_hash, last_used, 
                      inuse_features, flags, modified, incarnation)
select s.signature, 0, 0,
       nvl(o.last_executed, systimestamp),
       s.inuse_features, s.flags, systimestamp, 0
from sql$ s, sqlobj$auxdata sa, sqlobj$ o
where s.signature = sa.signature
      and sa.signature = o.signature
      and sa.category = o.category
      and sa.obj_type = 1
      and o.obj_type = 1;

commit;

rem change definition of sql$text and move it from SYSAUX
create table sql$text_sys /* holds SQL text for sql$ entries */
(
  signature    number  not null,         /* signature of normalized SQL text */
  sql_text     CLOB    not null,                   /* un-normalized SQL text */
  sql_len      number  not null                        /* length of SQL text */
)
/

-- copy over values from the table in sysaux
insert into sql$text_sys
select signature, sql_text, dbms_lob.getlength(sql_text)
from sql$text t
where exists (select 1
              from sqlobj$ o
              where o.obj_type = 1
                    and o.signature = t.signature);

commit;

-- drop the table 
drop table sql$text;

-- rename the temporary table to its new name
alter table sql$text_sys rename to sql$text;

-- recreate indices
create index i_sql$text on sql$text(signature);

rem create sqlprof$
create table sqlprof$          /* base table for storing SQL profile objects */
(
  sp_name     varchar2(30)       not null,   /* name (potentially generated) */
  signature   number             not null,/* signature of normalized SQL txt */
  category    varchar2(30)       not null,                  /* category name */
  nhash       number             not null, /* hash value for normalized text */
  created     date               not null,                  /* creation date */
  last_modified date             not null,             /* last modified date */
  type        number             not null,                /* '1' for manual, */
                                                        /* '2' for auto-tune */
  status      number             not null,               /* '1' for enabled, */
                                           /* '2' for disabled, '3' for void */
  flags       number             not null,                       /* not used */
  spare1      number,                                        /* spare column */
  spare2      varchar2(1000)                                 /* spare column */
)
/
create unique index i_sqlprof$ on sqlprof$(signature, category)
/
create unique index i_sqlprof$name on sqlprof$(sp_name)
/

rem populate sqlprof$ from sqlobj$ and sqlobj$auxdata
rem sqlprof$.flags must not be null, but not used,
rem we insert a default value 0 for it
insert into sqlprof$ (sp_name, signature, category, nhash, created, 
                      last_modified, type, status, flags)
select s.name, sa.signature, sa.category, 0, sa.created, 
       sa.last_modified, sa.origin,
       decode(s.flags, null, 3, decode(bitand(s.flags, 1), 1, 1, 2)),
       0
from sqlobj$ s, sqlobj$auxdata sa
where s.signature = sa.signature
      and s.obj_type = 1
      and sa.obj_type = 1;

commit;

rem truncate new tables
truncate table sqlobj$;

rem create table sqlprof$attr

create table sqlprof$attr    /* table containing attributes for SQL profiles */
(
  signature   number            not null, /* signature of normalized SQL txt */
  category    varchar2(30)      not null,         /* join key: category name */
  attr#       number            not null,      /* attr number within profile */
  attr_val    varchar2(500)     not null                  /* attribute value */
)
/

rem populate sqlprof$attr from sqlobj$data
insert into sqlprof$attr
select signature, category, 
       row_number()
         over (partition by signature, category order by signature),
       extractValue(value(t), '/hint')
from sqlobj$data sd, 
     table(xmlsequence(extract(xmltype(sd.comp_data),
                               '/outline_data/hint'))) t
where sd.obj_type = 1;

commit;

create unique index i_sqlprof$attr on sqlprof$attr
 (signature, category, attr#)
/

create table sqlprof$desc                   /* descriptions for SQL profiles */
(
  signature   number            not null, /* signature of normalized SQL txt */
  category    varchar2(30)      not null,         /* join key: category name */
  description varchar2(500)   /* profile description (potentially generated) */
)
/

insert into sqlprof$desc 
select signature, category, description
from sqlobj$auxdata
where obj_type = 1;

commit;

rem truncate new table
truncate table sqlobj$data;

-- drop the table and its associated indices
drop table sql$;

-- rename the temporary table to its new name
alter table sql$_sys rename to sql$;

rem recreate indices
create unique index i_sql$signature on sql$(signature);

rem truncate new table sqlobj$auxdata 
truncate table sqlobj$auxdata;

Rem ---------------------------------------------
Rem SQL Plan Management (SPM) Downgrade End
Rem ---------------------------------------------

Rem=========================================================================
Rem Run PL/SQL blocks to downgrade procedural objects
Rem=========================================================================

Rem MV Log-related changes
Rem Downgrade unpublished MV logs
Rem Publish flag: KKZLOGPUBL = 0x2000 = 8192

DECLARE
  curscn NUMBER;
  CURSOR mvlogcur IS
    SELECT greatest(l.youngest+1, sysdate) as maxdate
    FROM sys.mlog$ l WHERE bitand(l.flag, 8192) = 0 FOR UPDATE;
BEGIN
  FOR r1 IN mvlogcur LOOP
    curscn := dbms_flashback.get_system_change_number;
    UPDATE sys.mlog$ SET
      youngest = r1.maxdate,
      oldest = greatest(oldest, r1.maxdate),
      oldest_pk = greatest(oldest_pk, r1.maxdate),
      oldest_seq = greatest(oldest_seq, r1.maxdate),
      oldest_oid = greatest(oldest_oid, r1.maxdate),
      oldest_new = greatest(oldest_new, r1.maxdate),
      oscn = curscn,
      yscn = curscn
    WHERE CURRENT OF mvlogcur;
  END LOOP;
END;
/

COMMIT;


Rem=======================
Rem Streams Changes Begin
Rem=======================

alter session set events '10866 trace name context forever, level 4';

DECLARE
CURSOR s_c IS  SELECT   oid, destination, job_name, last_run
    FROM   sys.aq$_schedules where job_name is not null;
jobname         VARCHAR2(30);
job_no          NUMBER;
mydestination   VARCHAR2(128);
mystart_time    DATE;
myduration      VARCHAR2(8);
mynext_time     VARCHAR2(200);
mylatency       VARCHAR2(8);
disabled_state  VARCHAR2(1);
mybatch_size    NUMBER;
inst            NUMBER;
cur_time        DATE;
saved_state     BOOLEAN;
last_start_date timestamp with time zone;
failure_count   NUMBER;
num_windows     NUMBER;  
sql_stmt        VARCHAR2(2000);
job_state       VARCHAR2(30);
stopped         BOOLEAN := FALSE;
stop_counter    BINARY_INTEGER := 0;
st_time         date;
delta           NUMBER := 0;

STOPPED_STILL_RUNNING exception;
PRAGMA EXCEPTION_INIT(STOPPED_STILL_RUNNING, -27365);

JOB_NOT_RUNNING exception;
PRAGMA EXCEPTION_INIT(JOB_NOT_RUNNING, -27366);

NOT_STOPPED_STILL_RUNNING exception;
PRAGMA EXCEPTION_INIT(NOT_STOPPED_STILL_RUNNING, -27478);

RAC_JOB_TIMEOUT EXCEPTION;
PRAGMA        EXCEPTION_INIT(RAC_JOB_TIMEOUT, -16509);

RAC_JOB_ERR EXCEPTION;
PRAGMA        EXCEPTION_INIT(RAC_JOB_TIMEOUT, -16510);

  
BEGIN
  FOR s_c_rec in s_c LOOP

    BEGIN
      jobname := s_c_rec.job_name;
      stopped := FALSE;

      SELECT   value 
      INTO  mydestination
      FROM   DBA_SCHEDULER_JOB_ARGS 
      WHERE  JOB_NAME=jobname AND ARGUMENT_NAME='DESTINATION';
  
      SELECT   value
      INTO  myduration
      FROM   DBA_SCHEDULER_JOB_ARGS 
      WHERE  JOB_NAME=jobname AND ARGUMENT_NAME='DURATION';
  
      SELECT   value
      INTO  mylatency
      FROM   DBA_SCHEDULER_JOB_ARGS 
      WHERE  JOB_NAME=jobname AND ARGUMENT_NAME='LATENCY';

      SELECT   to_number(value)
      INTO  mybatch_size
      FROM   DBA_SCHEDULER_JOB_ARGS 
      WHERE  JOB_NAME=jobname AND ARGUMENT_NAME='HTTP_BATCH_SIZE';

      SELECT  decode(enabled,'TRUE','N','Y'), state
      INTO  disabled_state, job_state
      FROM   DBA_SCHEDULER_JOBS
      WHERE  JOB_NAME=jobname;
  
      SELECT SYSDATE INTO cur_time FROM dual;

      dbms_scheduler.get_attribute(jobname, 'start_date', mystart_time);
      dbms_scheduler.get_attribute(jobname, 'repeat_interval', mynext_time);
      dbms_scheduler.get_attribute(jobname, 'instance_id', inst);

      -- query properties to updated  aq$_schedules
      sql_stmt := 'SELECT decode(j.failure_count, 1, 16, j.retry_count),'||
                  ' j.last_start_date, '||
                   ' GREATEST(1, (select count (*) '||
                   ' from dba_scheduler_job_run_details '||
                   ' where job_name = j.job_name)) '||
                  ' FROM dba_scheduler_jobs j where job_name = :1';
      EXECUTE IMMEDIATE sql_stmt 
              INTO failure_count, last_start_date, num_windows
              USING jobname;
  
      sys.dbms_aqadm_syscalls.kwqa_3gl_BeginTrans(TRUE, saved_state);

      st_time := SYSDATE;
      WHILE (stopped = FALSE) AND (delta <= 150) AND (stop_counter <= 31) LOOP
        BEGIN
          delta := (SYSDATE-st_time)*24*3600;

          IF (stop_counter > 30) OR ( delta > 150) THEN
            dbms_scheduler.stop_job(jobname, force => TRUE);
          ELSE
            dbms_scheduler.stop_job(jobname);
          END IF;
          stopped := TRUE;
        EXCEPTION
          WHEN STOPPED_STILL_RUNNING THEN
            dbms_lock.sleep(10);
            stop_counter := stop_counter + 1;
          WHEN RAC_JOB_TIMEOUT OR RAC_JOB_ERR THEN
            dbms_lock.sleep(10);
            stop_counter := stop_counter + 1;
          WHEN JOB_NOT_RUNNING OR NOT_STOPPED_STILL_RUNNING THEN
            -- Unrecovered jobs should be given a kill signal to clean
            -- them up.
            SELECT state INTO job_state FROM DBA_SCHEDULER_JOBS 
              WHERE JOB_NAME=jobname;
            IF job_state = 'RUNNING' THEN
              BEGIN
                dbms_scheduler.stop_job(jobname, force => TRUE);
              EXCEPTION WHEN OTHERS THEN
                RAISE;
              END;
            END IF;
            stopped := TRUE;
          WHEN OTHERS THEN
            RAISE;
        END;
      END LOOP;

      
      dbms_scheduler.drop_job(job_name => jobname, force => TRUE);

      sys.dbms_aqadm_syscalls.kwqa_3gl_DestroyCacheObject(
        jobname, mydestination, s_c_rec.oid);

      -- only submit a job if schedule is enabled.
      -- job is started immediately without regard to 
      -- periodicity
      IF (disabled_state = 'N') THEN
        DBMS_JOB.SUBMIT(
          job_no, 
          'next_date := sys.dbms_aqadm.aq$_propaq(job);',
          cur_time,NULL,TRUE, inst);
      END IF;

      -- For run-once jobs that have stopped (succeeded), mark as disabled=N
      -- to match 10.2 semantics but do not submit job.  If last_run is not
      -- null, then the schedule was completed, then upgraded.
      IF disabled_state = 'Y' AND (job_state = 'SUCEEDED' OR 
         s_c_rec.last_run IS NOT NULL)
      THEN
        disabled_state := 'N';
      END IF;
       
      sql_stmt :=  ' UPDATE sys.aq$_schedules '||
                   '  SET   jobno = :1, '||
                   ' latency = :2, '||
                   ' duration = :3, '||
                   ' start_time = :4, '||
                   ' next_time = :5, '||
                   ' spare1 = :6, '||
                   ' instance = :7, '||
                   ' disabled = :8, '||
                   ' job_name = null, '||
                   ' failures = :9, '||
                   ' last_run = :10, '||
                   ' total_windows = :11, '||
                   ' cur_start_time = :12 ' ||
                   ' WHERE job_name = :13 ';
  
      EXECUTE IMMEDIATE sql_stmt 
        USING job_no, mylatency, myduration, nvl(mystart_time, SYSDATE),
               mynext_time, mybatch_size, inst, disabled_state, 
               failure_count, nvl(from_tz(last_start_date, sessiontimezone),
               s_c_rec.last_run),
               num_windows, nvl(mystart_time, SYSDATE), jobname;

      sys.dbms_aqadm_syscalls.kwqa_3gl_EndTrans(TRUE, saved_state);

    EXCEPTION
      WHEN OTHERS THEN
        sys.dbms_aqadm_syscalls.kwqa_3gl_EndTrans(FALSE, saved_state);
        dbms_system.ksdwrt(dbms_system.trace_file, 'AQ: ' || SQLERRM);
        dbms_system.ksdwrt(dbms_system.trace_file, 
                         'AQ: propagation schedule downgrade failed ' ||
                         ' for queue:'||s_c_rec.oid ||
                         ' destination:'|| s_c_rec.destination||
                         ' Job :'||jobname);

    END;
  
  END LOOP;

END;
/

alter session set events '10866 trace name context off';

BEGIN
  DBMS_SCHEDULER.DROP_PROGRAM(
    program_name => 'AQ$_PROPAGATION_PROGRAM',
    force => TRUE);
  DBMS_SCHEDULER.DROP_JOB_CLASS(
    job_class_name => 'AQ$_PROPAGATION_JOB_CLASS',
    force => TRUE);
END;
/

Rem=======================
Rem Streams Changes End
Rem=======================


Rem=========================================================================
Rem BEGIN Logical Standby downgrade items
Rem=========================================================================
Rem
Rem BUG 5845153
Rem Convert Logical Standby Ckpt data from 11 format to 10.2 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_11to102;
end;
/

Rem BUG 6121044
Rem Remove foreign logs from flash recovery area when downgrading to 10.2
Rem

begin
  sys.dbms_backup_restore.cleanupforeignarchivedlogs;
end;
/

Rem=========================================================================
Rem End Logical Standby downgrade items
Rem=========================================================================

Rem============================================================================
Rem Begin BSLN Changes
Rem============================================================================

Rem ********************************
Rem * drop scheduler entities
Rem ********************************

declare
  K_NOTAJOB      constant binary_integer := 27475;
  K_DOESNOTEXIST constant binary_integer := 27476;
begin
  begin
    dbms_scheduler.drop_job('BSLN_MAINTAIN_STATS_JOB', TRUE);
  exception
  when others then
    if SQLCODE = K_NOTAJOB then NULL; else raise; end if;
  end;

  begin
    dbms_scheduler.drop_schedule('BSLN_MAINTAIN_STATS_SCHED', TRUE);
  exception
  when others then
    if SQLCODE = K_DOESNOTEXIST then NULL; else raise; end if;
  end;

  begin
    dbms_scheduler.drop_program('BSLN_MAINTAIN_STATS_PROG', TRUE);
  exception
  when others then
    if SQLCODE = K_DOESNOTEXIST then NULL; else raise; end if;
  end;
end;
/

Rem ********************************
Rem * 1. truncate tables
Rem ********************************

alter table dbsnmp.bsln_statistics disable constraint bsln_statistics_fk;
alter table dbsnmp.bsln_threshold_params disable constraint bsln_thresholds_fk;

truncate table dbsnmp.bsln_threshold_params;
truncate table dbsnmp.bsln_statistics;
truncate table dbsnmp.bsln_baselines;
truncate table dbsnmp.bsln_timegroups;
truncate table dbsnmp.bsln_metric_defaults;

alter table dbsnmp.bsln_statistics enable constraint bsln_statistics_fk;
alter table dbsnmp.bsln_threshold_params enable constraint bsln_thresholds_fk;

Rem ********************************
Rem * 2. drop views
Rem ******************************** 

drop view dbsnmp.mgmt_bsln_intervals;
drop view dbsnmp.mgmt_bsln_metrics;
drop view dbsnmp.mgmt_bsln_statistics;
drop view dbsnmp.mgmt_bsln_threshold_parms;
drop view dbsnmp.mgmt_bsln_baselines;
drop view dbsnmp.mgmt_bsln_datasources;

Rem ********************************
Rem * 3. drop packages
Rem ********************************

drop synonym dbsnmp.mgmt_bsln;
drop package dbsnmp.bsln;
drop package dbsnmp.bsln_internal;

Rem ********************************
Rem * 4. drop types
Rem ********************************

drop type dbsnmp.bsln_metric_set;
drop type dbsnmp.bsln_metric_t;

drop type dbsnmp.bsln_variance_set;
drop type dbsnmp.bsln_variance_t;

drop type dbsnmp.bsln_observation_set;
drop type dbsnmp.bsln_observation_t;

drop type dbsnmp.bsln_statistics_set;
drop type dbsnmp.bsln_statistics_t;

Rem ********************************
Rem * 5. restore legacy tables
Rem ********************************

declare

  -- prefixes to replace on rename
  K_BSLN_OLDPREFIX  constant varchar2(10) := 'MGMT_BSLN_';
  K_BSLN_CURRPREFIX constant varchar2(9)  := 'BSLN_102_';

begin

  -- loop over the set of tables
  for l_tab in
      (select table_name current_name
             ,K_BSLN_OLDPREFIX||SUBSTR(table_name,LENGTH(K_BSLN_CURRPREFIX)+1)
                         old_name
         from dba_tables
        where owner = 'DBSNMP'
          and table_name like K_BSLN_CURRPREFIX||'%')
  loop

    -- rename here, trapping exceptions that may arise in the case the 
    --  tables have already been renamed
    begin
      execute immediate 'alter table dbsnmp.'|| 
                         dbms_assert.enquote_name(l_tab.current_name, FALSE) ||
                        ' rename to '|| 
                         dbms_assert.enquote_name(l_tab.old_name, FALSE);
    exception
    when others then
      if (SQLCODE = -942) then
        NULL;
      else
        raise;
      end if;
    end;

  end loop;

end;
/

Rem============================================================================
Rem BSLN Changes End
Rem============================================================================

-- drop program for automatic sql tuning task
begin
  dbms_scheduler.drop_program('AUTO_SQL_TUNING_PROG', true);
exception
  when others then
    if (sqlcode = -27476) then -- prog does not exist
      null;
    else
      raise;
    end if;
end;
/

Rem ==========================
Rem Begin AUTOTASK changes
Rem ==========================

exec dbms_auto_task_export.downgrade_from_11g;

Rem ==========================
Rem End AUTOTASK changes
Rem ==========================


Rem ===============================
Rem Begin dbms_scheduler changes
Rem ===============================

Rem Drop scheduler credentials
DECLARE
  CURSOR all_credentials IS
    SELECT credential_name, owner from DBA_SCHEDULER_CREDENTIALS;
BEGIN
  FOR credential in all_credentials LOOP
    dbms_scheduler.drop_credential('"' || credential.owner || '"."' ||
      credential.credential_name || '"', TRUE);
  END LOOP;
END;
/

Rem remove all lightweight jobs
declare
  cursor all_lwjobs IS
    select owner, job_name from dba_scheduler_jobs 
    where job_style <> 'REGULAR';
begin
  for lwjob in all_lwjobs loop
    dbms_scheduler.drop_job
      ('"' || lwjob.owner || '"."' || lwjob.job_name || '"',
       TRUE);
  end loop;
end;
/

-- stop and drop created remote database jobs queue
BEGIN
  dbms_aqadm.stop_queue('SYS.SCHEDULER$_REMDB_JOBQ');
  dbms_aqadm.drop_queue('SYS.SCHEDULER$_REMDB_JOBQ');
  dbms_aqadm.drop_queue_table('SYS.SCHEDULER$_REMDB_JOBQTAB');
END;
/

-- stop and drop created service metrics queue
BEGIN 
 dbms_aqadm.remove_subscriber(queue_name=>'SYS$SERVICE_METRICS', 
        subscriber=>sys.aq$_agent('SYS$RLB_GEN_SUB',null,null));
 dbms_transform.drop_transformation('SYS','SYS$SERVICE_METRICS_GEN_TS');
 dbms_transform.drop_transformation('SYS','SYS$SERVICE_METRICS_TS'); 
 dbms_aqadm.stop_queue('SYS$SERVICE_METRICS'); 
 dbms_aqadm.drop_queue('SYS$SERVICE_METRICS'); 
 dbms_aqadm.drop_queue_table('SYS$SERVICE_METRICS_TAB');
END; 
/

begin

sys.dbms_scheduler.drop_program ( 'hs_parallel_sampling', true ) ;

exception when others then
if SQLCODE != -27476  THEN
   raise ;
end if;

end;
/

Rem drop created class. This class is only used if compat >= 11
begin
dbms_scheduler.drop_job_class(job_class_name => 'DBMS_JOB$', force=>true);
exception
  when others then
    if sqlcode = -27476 then NULL;
    else raise;    
    end if;
end;   
/

Rem Truncate attribute LAST_OBSERVED_EVENT
declare
  attrval varchar2(256);
begin
  select value into attrval from dba_scheduler_global_attribute
  where attribute_name = 'LAST_OBSERVED_EVENT';

  if length(attrval) > 32 then
    dbms_isched.drop_scheduler_attribute('LAST_OBSERVED_EVENT');
    dbms_scheduler.set_scheduler_attribute('LAST_OBSERVED_EVENT', 
                                           substr(attrval, 1, 32));
  end if;
exception
  when others then
    if abs(sqlcode) = 942 or abs(sqlcode) = 1403 or abs(sqlcode) = 955 then
      null;
    else raise;
    end if;
end;
/

Rem ===============================
Rem  Drop Timestamp and SCN columns 
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
                   || ' SET SCN_AT_REMOVE = NULL, ' ||
                   'CREATION_TIME = NULL, MODIFICATION_TIME = NULL,' || 
                   'DELETION_TIME = NULL ';
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

Rem ====================================
Rem BEGIN Extended stats related changes
Rem ====================================

Rem  We have added a new column to the stats history table during upgrade
Rem  to 11g. We can not use the history once we downgrade the database. The
Rem  following stmt will purge all statistics history entries.

exec dbms_stats.purge_stats(systimestamp);


Rem ====================================
Rem END Extended stats related changes
Rem ====================================


Rem ====================================
Rem BEGIN SQL Access Advisor changes
Rem ====================================

Rem Reset all AA tasks.  This will delete all data from the new 11g tables, 
Rem so no truncate is necessary later in e1002000.sql

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

Rem ====================================
Rem END SQL Access Advisor changes
Rem ====================================

Rem drop data mining programs
exec dbms_scheduler.drop_program('sys.jdm_build_program', true ); 
exec dbms_scheduler.drop_program('sys.jdm_test_program', true );
exec dbms_scheduler.drop_program('sys.jdm_sql_apply_program', true );
exec dbms_scheduler.drop_program('sys.jdm_export_program', true );
exec dbms_scheduler.drop_program('sys.jdm_import_program', true );
exec dbms_scheduler.drop_program('sys.jdm_xform_program', true );
exec dbms_scheduler.drop_program('sys.jdm_predict_program', true );
exec dbms_scheduler.drop_program('sys.jdm_explain_program', true );

DECLARE
  /*
  Procedure to drop user
  */
  PROCEDURE  drop_user( user  IN VARCHAR2,dir_name IN VARCHAR2)
  IS
    l_ll_user_exists       NUMBER;
    l_ll_pkg_exists       NUMBER;
    l_vers            v$instance.version%TYPE;
    l_dirobj_cnt   NUMBER;
  BEGIN
   select count(*) into l_ll_user_exists from dba_users where username = user;
   IF l_ll_user_exists = 1 THEN
        SELECT count(*) into l_ll_pkg_exists FROM sys.user$ u, sys.obj$ o WHERE u.name = user AND o.name ='MGMT_DB_LL_METRICS' AND o.owner# = u.user# AND o.type# = 9 AND o.status LIKE '%' ;
        IF l_ll_pkg_exists = 1 THEN
                execute immediate 'drop user '|| 
                dbms_assert.enquote_name(user, FALSE) ||' cascade';
        END IF;
   END IF;
   select substr(version,1,5) into l_vers from v$instance;
   IF l_vers != '9.0.1' AND l_vers != '8.1.7' THEN
        select count(*) into l_dirobj_cnt from  dba_directories where DIRECTORY_NAME = dir_name ;
        IF l_dirobj_cnt = 1 THEN
                execute immediate 'DROP DIRECTORY ' || 
                dbms_assert.enquote_name(dir_name, FALSE);
        END IF;
   END IF;
  END drop_user; 
BEGIN
  -- Drop previous OCM user
  drop_user('ORACLE_OCM','ORACLE_OCM_CONFIG_DIR'); 
END;
/

Rem ==========================
Rem Begin DRA changes
Rem ==========================

BEGIN
  dbms_scheduler.drop_job(
     job_name => 'HM_CREATE_OFFLINE_DICTIONARY', 
     force => TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -27475 THEN NULL;   -- Not a job
    ELSE raise; 
    END IF;
END;
/

BEGIN
  dbms_scheduler.drop_job(
     job_name => 'DRA_REEVALUATE_OPEN_FAILURES', 
     force => TRUE);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -27475 THEN NULL;   -- Not a job
    ELSE raise; 
    END IF;
END;
/

Rem ==========================
Rem End DRA changes
Rem ==========================

Rem =========================================================================
Rem END STAGE 2: downgrade dictionary from current release 10.2.0
Rem =========================================================================

Rem update status in component registry (last)

BEGIN
   dbms_registry.downgraded('CATALOG','10.2.0');
   dbms_registry.downgraded('CATPROC','10.2.0');
END;
/

Rem *************************************************************************
Rem END f1002000.sql
Rem *************************************************************************

