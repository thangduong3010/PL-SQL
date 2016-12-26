Rem
Rem $Header: addmtmig.sql 26-feb-2007.04:29:23 sburanaw Exp $
Rem
Rem addmtmig.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      addmtmig.sql - ADDM Task Migration
Rem
Rem    DESCRIPTION
Rem      Post upgrade script for 11.1 release to fill new ADDM task
Rem      metadata tables with derived information.
Rem
Rem    NOTES
Rem      If this script is not included in post-upgrade, EM performance 
Rem      pages will not be able to display 10g ADDM tasks properly. 
Rem      There is no other effect on the database.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sburanaw    02/23/07 - fix microsecond for wri$_adv_addm_task
Rem    ushaft      02/05/07 - Created
Rem

Rem 
Rem Find the tasks that need to be upgraded.
Rem 
      
insert into wri$_adv_addm_tasks
(TASK_ID,
 DBID,
 BEGIN_SNAP_ID,
 END_SNAP_ID,
 REQUESTED_ANALYSIS,
 ACTUAL_ANALYSIS,
 DATABASE_TIME)
select t.task_id, 
       to_number(p_dbid.parameter_value),
       to_number(p_bid.parameter_value),
       to_number(p_eid.parameter_value),
       'INSTANCE', 'INSTANCE',
       to_number(p_dbt.parameter_value)
from   dba_advisor_tasks t,
       dba_advisor_parameters p_dbid,
       dba_advisor_parameters p_bid,
       dba_advisor_parameters p_eid,
       dba_advisor_parameters p_dbt
where  t.advisor_name = 'ADDM'
  and  t.status = 'COMPLETED'
  and  p_dbid.task_id = t.task_id
  and  p_dbid.parameter_name = 'DB_ID'
  and  p_bid.task_id = t.task_id
  and  p_bid.parameter_name = 'START_SNAPSHOT'
  and  p_eid.task_id = t.task_id
  and  p_eid.parameter_name = 'END_SNAPSHOT'
  and  p_dbt.task_id = t.task_id
  and  p_dbt.parameter_name = 'DB_ELAPSED_TIME'
  and  t.task_id not in (select task_id from wri$_adv_addm_tasks);

commit;

Rem
Rem Add the estimated analysis version.
Rem

CREATE GLOBAL TEMPORARY TABLE addm$dbv (
  exec_from      timestamp(3),
  exec_to        timestamp(3),
  db_version     varchar2(17)
) 
ON COMMIT DELETE ROWS;

insert into addm$dbv
select min(startup_time), null, version
from   wrm$_database_instance
where  dbid = (select dbid from v$database)
group by version;

update addm$dbv a
set    a.exec_from = (select cast(min(execution_end) as timestamp)
                      from   dba_advisor_tasks)
where  a.exec_from =
       (select min(exec_from)
        from   addm$dbv);

update addm$dbv a
set    a.exec_to = 
      (select nvl(min(exec_from), cast(sysdate as timestamp)) 
       from   addm$dbv b
       where  b.exec_from > a.exec_from);

update wri$_adv_addm_tasks t
set    t.analysis_version = 
       (select min(v.db_version) 
        from addm$dbv v, dba_advisor_tasks a
        where  a.task_id = t.task_id
          and  cast(a.execution_end as timestamp) > v.exec_from
          and  cast(a.execution_end as timestamp) <= v.exec_to)
where  t.analysis_version IS NULL;

drop table addm$dbv;

commit;


Rem
Rem Add the database name, database version, snapshot end time. 
Rem

update wri$_adv_addm_tasks t
set    (t.dbname, t.dbversion, t.end_time) = 
       (select min(d.db_name), min(d.version), min(s.end_interval_time)
        from   wrm$_snapshot s, wrm$_database_instance d
        where  s.dbid = t.dbid
          and  s.snap_id = t.end_snap_id
          and  d.dbid = t.dbid
          and  d.instance_number = s.instance_number
          and  d.startup_time = s.startup_time
        )
where  t.analysis_version like '10.%'
  and  t.dbname IS NULL
  and  t.dbversion IS NULL
  and  t.end_time IS NULL;

commit;

Rem
Rem Add the snapshot begin time. 
Rem

update wri$_adv_addm_tasks t
set    t.begin_time = 
       (select min(s.end_interval_time)
        from   wrm$_snapshot s
        where  s.dbid = t.dbid
          and  s.snap_id = t.begin_snap_id
        )
where  t.analysis_version like '10.%'
  and  t.begin_time IS NULL;

commit;

Rem
Rem Add the active sessions
Rem 

update wri$_adv_addm_tasks t
set    t.active_sessions = 
          t.database_time / 
           (extract(day      from t.end_time - t.begin_time) *24*60*60*1000000 
            + extract(hour   from t.end_time - t.begin_time)    *60*60*1000000 
            + extract(minute from t.end_time - t.begin_time)       *60*1000000
            + extract(second from t.end_time - t.begin_time)          *1000000 )
where  t.active_sessions IS NULL
  and  t.begin_time IS NOT NULL
  and  t.end_time IS NOT NULL
  and  t.database_time IS NOT NULL
  and  t.end_time > t.begin_time;

commit;


Rem 
Rem Add a row for each task into the wri$_adv_addm_inst table
Rem

insert into wri$_adv_addm_inst i
(TASK_ID,
 INSTANCE_NUMBER,
 INSTANCE_NAME,
 HOST_NAME,
 STATUS,
 DATABASE_TIME,
 ACTIVE_SESSIONS,
 PERC_ACTIVE_SESS,
 LOCAL_TASK_ID)
select t.task_id,
       to_number(p.parameter_value),
       d.instance_name,
       d.host_name,
       'ANALYZED',
       t.database_time,
       t.active_sessions,
       100,
       t.task_id
from   wri$_adv_addm_tasks t, dba_advisor_parameters p,
       wrm$_snapshot s, wrm$_database_instance d
where  t.task_id not in (select task_id from wri$_adv_addm_inst)
  and  t.analysis_version like '10.%'
  and  t.actual_analysis = 'INSTANCE'
  and  p.task_id = t.task_id
  and  p.parameter_name = 'INSTANCE'
  and  p.parameter_value IS NOT NULL
  and  p.parameter_value <> 'UNUSED'
  and  s.dbid = t.dbid
  and  s.snap_id = t.end_snap_id
  and  s.instance_number = 
       to_number(decode(p.parameter_value, 'UNUSED', NULL, p.parameter_value))
  and  d.dbid = t.dbid
  and  d.instance_number = s.instance_number
  and  d.startup_time = s.startup_time; 

commit;


Rem
Rem Add a row for each the findings
Rem

insert into wri$_adv_addm_fdg
(TASK_ID,
 FINDING_ID,
 DATABASE_TIME,
 ACTIVE_SESSIONS,
 PERC_ACTIVE_SESS,
 IS_AGGREGATE
)
select t.task_id, 
       a.finding_id,
       a.impact,
       (a.impact * t.active_sessions) / t.database_time,
       (a.impact * 100) / t.database_time,
       'N'
from   wri$_adv_addm_tasks t, dba_advisor_findings a
where  (t.task_id, a.finding_id) not in
           (select task_id, finding_id from wri$_adv_addm_fdg)  
  and  t.analysis_version like '10.%'
  and  t.actual_analysis = 'INSTANCE'
  and  t.task_id = a.task_id
  and  a.type in ('PROBLEM', 'SYMPTOM')
  and  t.database_time > 0; 

commit;
