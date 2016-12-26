Rem
Rem $Header: rdbms/admin/catnosch.sql /main/35 2009/01/12 17:00:43 rgmani Exp $
Rem
Rem catnosch.sql
Rem
Rem Copyright (c) 2002, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catnosch.sql - Remove Scheduler views, packages and synonyms
Rem
Rem    DESCRIPTION
Rem      This file removes packages, views and synonyms of the Scheduler
Rem      Component. 
Rem
Rem      It also removes all scheduler objects. 
Rem
Rem    NOTES
Rem      This script must be run as SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rramkiss    03/05/08 - remove 11.1 tables and views
Rem    rgmani      01/18/08 - Drop types job_definiton and job_definition_array
Rem    rramkiss    07/05/06 - update for remote database jobs 
Rem    rramkiss    03/20/06 - drop scheduler credential stuff 
Rem    samepate    07/07/05 - remove old obsolete queue code
Rem    rramkiss    05/11/05 - tweak for chains 
Rem    evoss       01/25/05 - drop scheduler$_int_array_type
Rem    rramkiss    01/06/05 - drop new chain_condition package 
Rem    evoss       06/03/04 - fix deleting global attributes and event_q 
Rem    raavudai    05/25/04 - add commit at the end and flush the shared pool
Rem    rramkiss    04/07/04 - view name updates 
Rem    rramkiss    03/26/04 - drop more chains views 
Rem    rramkiss    03/08/04 - remove all program chains 
Rem    rramkiss    03/08/04 - remove program chain views
Rem    rgmani      05/21/04 - 
Rem    rramkiss    04/21/04 - remove granted CREATE EXTERNAL JOB privs 
Rem    rramkiss    11/04/03 - lrg-1590893 
Rem    rramkiss    09/19/03 - bug-2812539
Rem    rramkiss    09/04/03 - drop job table/chain stuff 
Rem    rramkiss    06/26/03 - remove new sequence for job_name suffixes
Rem    rgmani      06/12/03 - Drop attribute views
Rem    rramkiss    06/20/03 - drop rules/rulesets on the job queue
Rem    rramkiss    02/18/03 - remove scheduler$_job_external/results type
Rem    rgmani      05/02/03 - Drop attributes table
Rem    rramkiss    02/21/03 - drop new all_* views
Rem    evoss       01/16/03 - add scheduler_running_jobs
Rem    srajagop    01/20/03 - logging changes
Rem    rramkiss    01/09/03 - JS_COORDINATOR => SCHEDULER_COORDINATOR
Rem    rramkiss    12/20/02 - update for tweaked views
Rem    rramkiss    12/05/02 - drop_class->drop_job_class
Rem    rramkiss    11/19/02 - Remove ALL_SCHEDULER_* views
Rem    rgmani      12/20/02 - Drop schedule ID index
Rem    rramkiss    10/29/02 - drop oldoids table and sequence
Rem    rramkiss    10/23/02 - drop privilege grants
Rem    rramkiss    10/15/02 - Drop schedule object export package
Rem    rramkiss    10/08/02 - Remove schedule object table and views
Rem    rramkiss    09/30/02 - Remove lines registering export callouts
Rem    rramkiss    09/24/02 - Drop all created packages
Rem    rgmani      10/14/02 - Add functional index on job queue table
Rem    rramkiss    09/05/02 - Drop window group tables, indexes and views
Rem    rgmani      09/12/02 - Change upgrade/downgrade for job tables
Rem    rramkiss    08/29/02 - rramkiss_sched-compat
Rem    rramkiss    08/26/02 - Update to drop tables and remove objects properly
Rem    rramkiss    08/23/02 - TRUNCATE base tables, DELETE cols from obj$
Rem    rramkiss    08/22/02 - Created
Rem

-- Drop scheduler objects
DECLARE
  CURSOR all_programs IS
    SELECT program_name, owner from DBA_SCHEDULER_PROGRAMS;
  CURSOR all_jobs IS
    SELECT job_name, owner from DBA_SCHEDULER_JOBS WHERE job_subname IS NULL;
  CURSOR all_windows IS
    SELECT window_name from DBA_SCHEDULER_WINDOWS;
  CURSOR all_classes IS
    SELECT job_class_name from DBA_SCHEDULER_JOB_CLASSES;
  CURSOR all_window_groups IS
    SELECT window_group_name from DBA_SCHEDULER_WINDOW_GROUPS;
  CURSOR all_schedules IS
    SELECT schedule_name, owner from DBA_SCHEDULER_SCHEDULES;
  CURSOR all_chains IS
    SELECT chain_name, owner from DBA_SCHEDULER_CHAINS;
  CURSOR all_credentials IS
    SELECT credential_name, owner from DBA_SCHEDULER_CREDENTIALS;
BEGIN
  FOR program in all_programs LOOP
    dbms_scheduler.drop_program('"' || program.owner || '"."' ||
      program.program_name || '"',
      TRUE);
  END LOOP;

  FOR job in all_jobs LOOP
    dbms_scheduler.drop_job('"' || job.owner || '"."' || job.job_name || '"',
      TRUE);
  END LOOP;

  FOR class in all_classes LOOP
    dbms_scheduler.drop_job_class('"' || class.job_class_name || '"', TRUE);
  END LOOP;

  FOR window in all_windows LOOP
    dbms_scheduler.drop_window('"' || window.window_name || '"', TRUE);
  END LOOP;

  FOR window_group in all_window_groups LOOP
    dbms_scheduler.drop_window_group('"' || window_group.window_group_name ||
      '"', TRUE);
  END LOOP;

  FOR schedule in all_schedules LOOP
    dbms_scheduler.drop_schedule('"' || schedule.owner || '"."' ||
      schedule.schedule_name || '"', TRUE);
  END LOOP;

  FOR chain in all_chains LOOP
    dbms_scheduler.drop_chain('"' || chain.owner || '"."' ||
      chain.chain_name || '"', TRUE);
  END LOOP;

  FOR credential in all_credentials LOOP
    dbms_scheduler.drop_credential('"' || credential.owner || '"."' ||
      credential.credential_name || '"', TRUE);
  END LOOP;
END;
/

DECLARE
  CURSOR all_subs IS
    SELECT agt_name FROM scheduler$_evtq_sub;
BEGIN
  FOR sub in all_subs LOOP
    dbms_scheduler.remove_event_queue_subscriber('"' || sub.agt_name || '"');
  END LOOP;
END;
/

-- Drop views and their synonyms

DROP VIEW dba_scheduler_programs;
DROP PUBLIC SYNONYM dba_scheduler_programs;
DROP VIEW user_scheduler_programs;
DROP PUBLIC SYNONYM user_scheduler_programs;
DROP VIEW all_scheduler_programs;
DROP PUBLIC SYNONYM all_scheduler_programs;
DROP VIEW dba_scheduler_jobs;
DROP PUBLIC SYNONYM dba_scheduler_jobs;
DROP VIEW user_scheduler_jobs;
DROP PUBLIC SYNONYM user_scheduler_jobs;
DROP VIEW all_scheduler_jobs;
DROP PUBLIC SYNONYM all_scheduler_jobs;
DROP VIEW dba_scheduler_job_classes;
DROP PUBLIC SYNONYM dba_scheduler_job_classes;
DROP VIEW all_scheduler_job_classes;
DROP PUBLIC SYNONYM all_scheduler_job_classes;
DROP VIEW dba_scheduler_windows;
DROP PUBLIC SYNONYM dba_scheduler_windows;
DROP VIEW all_scheduler_windows;
DROP PUBLIC SYNONYM all_scheduler_windows;
DROP VIEW dba_scheduler_program_args;
DROP PUBLIC SYNONYM dba_scheduler_program_args;
DROP VIEW user_scheduler_program_args;
DROP PUBLIC SYNONYM user_scheduler_program_args;
DROP VIEW all_scheduler_program_args;
DROP PUBLIC SYNONYM all_scheduler_program_args;
DROP VIEW dba_scheduler_job_args;
DROP PUBLIC SYNONYM dba_scheduler_job_args;
DROP VIEW user_scheduler_job_args;
DROP PUBLIC SYNONYM user_scheduler_job_args;
DROP VIEW all_scheduler_job_args;
DROP PUBLIC SYNONYM all_scheduler_job_args;
DROP VIEW dba_scheduler_job_log;
DROP PUBLIC SYNONYM dba_scheduler_job_log;
DROP VIEW dba_scheduler_job_run_details;
DROP PUBLIC SYNONYM dba_scheduler_job_run_details;
DROP VIEW user_scheduler_job_log;
DROP PUBLIC SYNONYM user_scheduler_job_log;
DROP VIEW user_scheduler_job_run_details;
DROP PUBLIC SYNONYM user_scheduler_job_run_details;
DROP VIEW all_scheduler_job_log;
DROP PUBLIC SYNONYM all_scheduler_job_log;
DROP VIEW all_scheduler_job_run_details;
DROP PUBLIC SYNONYM all_scheduler_job_run_details;
DROP VIEW dba_scheduler_window_log;
DROP PUBLIC SYNONYM dba_scheduler_window_log;
DROP VIEW dba_scheduler_window_details;
DROP PUBLIC SYNONYM dba_scheduler_window_details;
DROP VIEW all_scheduler_window_log;
DROP PUBLIC SYNONYM all_scheduler_window_log;
DROP VIEW all_scheduler_window_details;
DROP PUBLIC SYNONYM all_scheduler_window_details;
DROP VIEW dba_scheduler_window_groups;
DROP PUBLIC SYNONYM dba_scheduler_window_groups;
DROP VIEW all_scheduler_window_groups;
DROP PUBLIC SYNONYM all_scheduler_window_groups;
DROP VIEW dba_scheduler_wingroup_members;
DROP PUBLIC SYNONYM dba_scheduler_wingroup_members;
DROP VIEW all_scheduler_wingroup_members;
DROP PUBLIC SYNONYM all_scheduler_wingroup_members;
DROP VIEW dba_scheduler_schedules;
DROP PUBLIC SYNONYM dba_scheduler_schedules;
DROP VIEW user_scheduler_schedules;
DROP PUBLIC SYNONYM user_scheduler_schedules;
DROP VIEW all_scheduler_schedules;
DROP PUBLIC SYNONYM all_scheduler_schedules;
DROP VIEW dba_scheduler_running_jobs;
DROP PUBLIC SYNONYM dba_scheduler_running_jobs;
DROP VIEW user_scheduler_running_jobs;
DROP PUBLIC SYNONYM user_scheduler_running_jobs;
DROP VIEW all_scheduler_running_jobs;
DROP PUBLIC SYNONYM all_scheduler_running_jobs;
DROP VIEW dba_scheduler_global_attribute;
DROP PUBLIC SYNONYM dba_scheduler_global_attribute;
DROP VIEW all_scheduler_global_attribute;
DROP PUBLIC SYNONYM all_scheduler_global_attribute;
DROP VIEW dba_scheduler_chains;
DROP PUBLIC SYNONYM dba_scheduler_chains;
DROP VIEW user_scheduler_chains;
DROP PUBLIC SYNONYM user_scheduler_chains;
DROP VIEW all_scheduler_chains;
DROP PUBLIC SYNONYM all_scheduler_chains;
DROP VIEW dba_scheduler_chain_rules;
DROP PUBLIC SYNONYM dba_scheduler_chain_rules;
DROP VIEW user_scheduler_chain_rules;
DROP PUBLIC SYNONYM user_scheduler_chain_rules;
DROP VIEW all_scheduler_chain_rules;
DROP PUBLIC SYNONYM all_scheduler_chain_rules;
DROP VIEW dba_scheduler_chain_steps;
DROP PUBLIC SYNONYM dba_scheduler_chain_steps;
DROP VIEW user_scheduler_chain_steps;
DROP PUBLIC SYNONYM user_scheduler_chain_steps;
DROP VIEW all_scheduler_chain_steps;
DROP PUBLIC SYNONYM all_scheduler_chain_steps;
DROP VIEW dba_scheduler_running_chains;
DROP PUBLIC SYNONYM dba_scheduler_running_chains;
DROP VIEW user_scheduler_running_chains;
DROP PUBLIC SYNONYM user_scheduler_running_chains;
DROP VIEW all_scheduler_running_chains;
DROP PUBLIC SYNONYM all_scheduler_running_chains;
DROP VIEW dba_scheduler_credentials;
DROP PUBLIC SYNONYM dba_scheduler_credentials;
DROP VIEW user_scheduler_credentials;
DROP PUBLIC SYNONYM user_scheduler_credentials;
DROP VIEW all_scheduler_credentials;
DROP PUBLIC SYNONYM all_scheduler_credentials;
DROP VIEW dba_scheduler_job_roles;
DROP PUBLIC SYNONYM dba_scheduler_job_roles;
DROP VIEW scheduler_batch_errors;
DROP PUBLIC SYNONYM scheduler_batch_errors;
DROP VIEW dba_scheduler_remote_databases;
-- DROP PUBLIC SYNONYM dba_scheduler_remote_databases;
DROP VIEW all_scheduler_remote_databases;
-- DROP PUBLIC SYNONYM all_scheduler_remote_databases;
DROP VIEW dba_scheduler_remote_jobstate;
-- DROP PUBLIC SYNONYM dba_scheduler_remote_jobstate;
DROP VIEW all_scheduler_remote_jobstate;
-- DROP PUBLIC SYNONYM all_scheduler_remote_jobstate;
DROP VIEW user_scheduler_remote_jobstate;
-- DROP PUBLIC SYNONYM user_scheduler_remote_jobstate;
DROP VIEW dba_scheduler_file_watchers;
DROP PUBLIC SYNONYM dba_scheduler_file_watchers;
DROP VIEW user_scheduler_file_watchers;
DROP PUBLIC SYNONYM user_scheduler_file_watchers;
DROP VIEW all_scheduler_file_watchers;
DROP PUBLIC SYNONYM all_scheduler_file_watchers;
DROP VIEW dba_scheduler_notifications;
DROP PUBLIC SYNONYM dba_scheduler_notifications;
DROP VIEW user_scheduler_notifications;
DROP PUBLIC SYNONYM user_scheduler_notifications;
DROP VIEW all_scheduler_notifications;
DROP PUBLIC SYNONYM all_scheduler_notifications;

-- Drop scheduler base tables (these should be empty)

DROP TABLE sys.scheduler$_evtq_sub;
DROP SEQUENCE sys.scheduler$_evtseq;
DROP TABLE sys.scheduler$_program;
DROP TABLE sys.scheduler$_class;
DROP TABLE sys.scheduler$_job;
DROP TABLE sys.scheduler$_window;
DROP TABLE sys.scheduler$_program_argument;
DROP TABLE sys.scheduler$_job_argument;
DROP TABLE sys.scheduler$_event_log;
DROP TABLE sys.scheduler$_job_run_details;
DROP TABLE sys.scheduler$_window_details;
DROP TABLE sys.scheduler$_window_group;
DROP TABLE sys.scheduler$_wingrp_member;
DROP TABLE sys.scheduler$_chain;
DROP TABLE sys.scheduler$_step;
DROP TABLE sys.scheduler$_step_state;
DROP TABLE sys.scheduler$_credential;
DROP TABLE sys.scheduler$_file_watcher;
DROP TABLE sys.scheduler$_filewatcher_history;
DROP TABLE sys.scheduler$_notification;

DROP TABLE sys.scheduler$_srcq_map;
DROP TABLE sys.scheduler$_srcq_info;

DROP TABLE sys.scheduler$_lightweight_job;
DROP TABLE sys.scheduler$_rjob_src_db_info;
DROP TABLE sys.scheduler$_remote_dbs;
DROP TABLE scheduler$_remote_job_state;
DROP TABLE sys.scheduler$_saved_oids;
DROP TABLE sys.scheduler$_lwjob_obj;

DROP SEQUENCE sys.scheduler$_rdb_seq;

exec dbms_aqadm.stop_queue(queue_name => 'scheduler$_remdb_jobq');
exec dbms_aqadm.drop_queue(queue_name => 'scheduler$_remdb_jobq');
exec dbms_aqadm.drop_queue_table(queue_table => 'scheduler$_remdb_jobqtab');

exec dbms_aqadm.stop_queue(queue_name => 'scheduler$_event_queue');
exec dbms_aqadm.drop_queue(queue_name => 'scheduler$_event_queue');

exec dbms_aqadm.drop_queue_table(queue_table => 'scheduler$_event_qtab');

exec dbms_aqadm.drop_aq_agent(agent_name => 'SCHEDULER$_EVENT_AGENT');

DROP SEQUENCE sys.scheduler$_lwjob_oid_seq;

drop type scheduler$_job_step_type;
drop type sys.scheduler$_chain_link_list;
drop type sys.scheduler$_chain_link;
drop type sys.scheduler$_step_type_list;
drop type sys.scheduler$_step_type;
drop type sys.scheduler$_rule_list;
drop type sys.scheduler$_rule;
drop type sys.scheduler$_int_array_type;
drop type scheduler$_event_info;
DROP TABLE sys.scheduler$_schedule;
drop table sys.scheduler$_global_attribute;

-- Delete rows pertaining to scheduler objects 
-- (shouldn't be any but just in case)

DELETE FROM objauth$ WHERE obj# IN
 (SELECT obj# FROM obj$
    WHERE type# IN ('66','67','68','69','72','74','77','78','79','82','89')
    AND (NAMESPACE = 1  or NAMESPACE = 51))
/
DELETE FROM obj$ WHERE TYPE# IN ('66','67','68','69', '72','74','77','78',
  '79','82','89')
  AND (NAMESPACE = 1 or NAMESPACE = 51)
/

-- Drop other scheduler stuff

DROP SEQUENCE sys.scheduler$_instance_s;
DROP SEQUENCE sys.scheduler$_jobsuffix_s;
DROP LIBRARY dbms_scheduler_lib;
DROP PACKAGE dbms_scheduler;
DROP PUBLIC SYNONYM dbms_scheduler;
DROP PACKAGE dbms_isched;
DROP PACKAGE dbms_isched_chain_condition;
DROP PACKAGE dbms_isched_remdb_job;
DROP PACKAGE dbms_sched_main_export;
DROP PACKAGE dbms_sched_program_export;
DROP PUBLIC SYNONYM dbms_sched_program_export;
DROP PACKAGE dbms_sched_job_export;
DROP PUBLIC SYNONYM dbms_sched_job_export;
DROP PACKAGE dbms_sched_window_export;
DROP PUBLIC SYNONYM dbms_sched_window_export;
DROP PACKAGE dbms_sched_wingrp_export;
DROP PUBLIC SYNONYM dbms_sched_wingrp_export;
DROP PACKAGE dbms_sched_class_export;
DROP PUBLIC SYNONYM  dbms_sched_class_export;
DROP PACKAGE dbms_sched_schedule_export;
DROP PUBLIC SYNONYM  dbms_sched_schedule_export;
DROP PACKAGE dbms_sched_chain_export;
DROP PUBLIC SYNONYM dbms_sched_chain_export;
DROP PACKAGE dbms_sched_credential_export;
DROP PUBLIC SYNONYM dbms_sched_credential_export;
DROP PACKAGE dbms_sched_export_callouts;
DROP PUBLIC SYNONYM dbms_sched_export_callouts;
DROP ROLE scheduler_admin;
DELETE FROM sys.exppkgobj$ WHERE package LIKE 'DBMS_SCHED_%';
DELETE FROM sys.exppkgact$ WHERE package LIKE 'DBMS_SCHED_%';
DELETE FROM sys.sysauth$ WHERE privilege#
  IN (-264, -265, -266, -267, -268, -280);
DELETE FROM sys.audit$ WHERE option# IN (264, 265, 266, 267, 268, 280);

DROP TYPE sys.scheduler$_remote_db_job_info;
DROP TYPE sys.scheduler$_remote_arg_list;
DROP TYPE sys.scheduler$_remote_arg;
DROP TYPE sys.scheduler$_dest_list;
DROP TYPE SCHEDULER$_BATCHERR_VIEW_T;
DROP TYPE JOB_ARRAY;
DROP TYPE JOB;
DROP TYPE JOB_DEFINITION_ARRAY;
DROP TYPE JOB_DEFINITION;
DROP TYPE SCHEDULER$_BATCHERR_ARRAY;
DROP TYPE SCHEDULER$_BATCHERR;
DROP TYPE JOBATTR_ARRAY;
DROP TYPE JOBATTR;
DROP TYPE JOBARG_ARRAY;
DROP TYPE JOBARG;
DROP FUNCTION SCHEDULER$_BATCHERR_PIPE;

DROP TYPE sys.scheduler_filewatcher_result FORCE;
DROP TYPE sys.scheduler_filewatcher_req_list FORCE;
DROP TYPE sys.scheduler_filewatcher_request FORCE;

-- We shouldn't drop privilege or audit map entries because these get added in
-- sql.bsq, and not in catsch.sql
--DELETE FROM sys.system_privilege_map WHERE privilege 
--  IN (-264, -265, -266, -267, -268);
--DELETE FROM sys.stmt_audit_option_map WHERE option#
--  IN (264, 265, 266, 267, 268);

-- - Commit the changes and flush the shared pool.
commit;
alter system flush shared_pool ;
