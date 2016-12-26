Rem
Rem $Header: rdbms/admin/dbmssch.sql /st_rdbms_11.2.0/2 2011/07/26 09:38:43 jdraaije Exp $
Rem
Rem dbmssch.sql
Rem
Rem Copyright (c) 2002, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmssch.sql - DBMS SCHeduler interface
Rem
Rem    DESCRIPTION
Rem      Interface for the job scheduler package
Rem
Rem    NOTES
Rem
Rem      DBMS_SCHEDULER is the only interface for manipulating scheduler jobs.
Rem      Catalog views in catschv.sql are provided for examining jobs.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rgmani      03/09/11 - Backport rgmani_bug-10105085 from main
Rem    rramkiss    05/23/10 - bug #9705789 re-add get_step_state for old chains
Rem    rgmani      05/28/09 - Metadata args
Rem    rramkiss    05/15/09 - remove obsolete code
Rem    rgmani      03/30/09 - Move position of argument in create_file_watcher
Rem    evoss       02/26/09 - add credential and destination to jobs
Rem    evoss       02/03/09 - add multidest api
Rem    evoss       12/10/08 - use variable list instead of callback for re
Rem    rgmani      07/24/08 - 
Rem    rgmani      04/10/08 - 
Rem    evoss       03/13/08 - add remote sql job support
Rem    rramkiss    03/10/08 - add job e-mail notification
Rem    rgmani      02/15/08 - File watching
Rem    mjjones     08/11/08 - 
Rem    rramkiss    06/24/08 - bug #7197969, remove with_grant_option
Rem    rramkiss    06/18/08 - add get_agent_version
Rem    rgmani      01/14/08 - Change attribute name for JOB type
Rem    rramkiss    06/07/07 - add request id for remote external jobs
Rem    rgmani      02/26/07 - Add tracing pkg const
Rem    evoss       01/30/07 - #5855129
Rem    rramkiss    10/16/06 - update for remote chain steps
Rem    rramkiss    09/05/06 - add set_agent_registration_password
Rem    samepate    05/01/06 - add defer to drop_job
Rem    rramkiss    06/30/06 - add get_file and put_file 
Rem    rgmani      06/01/06 - Remote database jobs
Rem    rramkiss    03/21/06 - add apis for new credential object 
Rem    rgmani      01/19/06 - Add batch API 
Rem    rramkiss    04/27/05 - shortcut event constant 
Rem    rgmani      04/26/05 - Fix maxdur event bug 
Rem    rramkiss    03/21/05 - update run_chain 
Rem    rramkiss    03/11/05 - add CHAIN_STALLED event 
Rem    evoss       02/14/05 - remove create_calendar_schedule, now just 
Rem                             create_schedule
Rem    evoss       01/07/05 - make resolve calendar usable from odbc 
Rem    rramkiss    12/20/04 - get_chain_condition utility function 
Rem    rramkiss    09/23/04 - add utility function for EM 
Rem    evoss       08/10/04 - add timezone get 
Rem    rgmani      07/01/04 - Add job disabled event 
Rem    evoss       05/10/04 - add calendar schedule type 
Rem    rramkiss    04/26/04 - chains API tweaks 
Rem    rramkiss    03/08/04 - add get_action_value 
Rem    rramkiss    02/23/04 - job chaining API 
Rem    rgmani      04/27/04 - Event based scheduling 
Rem    evoss       10/28/03 - #3210672: evaluate calendar string changes 
Rem    rramkiss    09/19/03 - add flag to run_job 
Rem    evoss       09/08/03 - make chains internal 
Rem    rramkiss    08/12/03 - add get_default_value
Rem    srajagop    06/20/03 - add auto_purge proc
Rem    srajagop    06/17/03 - purging of logs contd
Rem    srajagop    06/10/03 - purge log
Rem    rramkiss    06/26/03 - fix generate_job_name
Rem    evoss       06/23/03 - job chaining
Rem    rramkiss    06/10/03 - add create/drop for job chains
Rem    rramkiss    01/23/03 - persistent=>auto_drop
Rem    rramkiss    01/13/03 - DEFAULT_CLASS => DEFAULT_JOB_CLASS
Rem    evoss       12/27/02 - add force option to open window
Rem    rramkiss    12/20/02 - add comments to create_window_group
Rem    rramkiss    12/18/02 - overload get/set_attribute for day-sec intervals
Rem    rramkiss    12/17/02 - interval fields => type interval day to second
Rem    rramkiss    12/02/02 - API tweaks
Rem    rramkiss    11/18/02 - remove schedule type window_once
Rem    rramkiss    11/18/02 - change kill_job to a force option of stop_job
Rem    rramkiss    11/15/02 - Add persistent flag to create job
Rem    rramkiss    11/05/02 - Add default program_type for create_program
Rem    rramkiss    10/28/02 - add check_sys_privs
Rem    evoss       10/31/02 - add calendar utility functions
Rem    srajagop    10/07/02 - add executable prog type
Rem    rramkiss    10/08/02 - Add schedule object API
Rem    rramkiss    09/19/02 - Overload API calls specifying arguments
Rem    rramkiss    09/05/02 - Add window groups procedures
Rem    rramkiss    08/29/02 - Remove obsolete library load
Rem    rramkiss    08/21/02 - Remove fields from create_job/window
Rem    rramkiss    08/21/02 - Merge dbms_scheduler_admin into dbms_scheduler
Rem    rramkiss    08/14/02 - Consolidate get/set_parameter procedures
Rem    rramkiss    07/26/02 - Consolidate enable/disable procedures
Rem    srajagop    07/23/02 - srajagop_scheduler_1
Rem    rramkiss    07/21/02 - Update purge_policy, stop_job and kill_job
Rem    rramkiss    07/16/02 - Remove cruft (incl. privileges, priority lists)
Rem    rgmani      07/16/02 - Add window end time internal argument
Rem    rramkiss    06/26/02 - Move check_compat to dbms_isched
Rem                           Compatibility checking requires definer`s privs
Rem    rramkiss    06/25/02 - Change job_weight to be a PLS_INTEGER
Rem    rramkiss    06/25/02 - Change name in create_job to be an IN variable
Rem    rramkiss    06/21/02 - Remove obsolete window fields
Rem    rramkiss    05/17/02 - Sync with Phase 1 requirements
Rem    rramkiss    04/11/02 - Created
Rem


REM  =========================================================
REM  dbms_scheduler: Oracle Scheduler PL/SQL interface
REM  =========================================================

-- Main Scheduler package
CREATE OR REPLACE PACKAGE dbms_scheduler  AUTHID CURRENT_USER AS

-- allowed job logging levels
logging_off   CONSTANT PLS_INTEGER := 32;
logging_runs  CONSTANT PLS_INTEGER := 64;
logging_failed_runs CONSTANT PLS_INTEGER := 128;
logging_full  CONSTANT PLS_INTEGER := 256;

-- defaults for job e-mail notification
default_notification_subject CONSTANT VARCHAR2(100) :=
'Oracle Scheduler Job Notification - %job_owner%.%job_name%.%job_subname% %event_type%';

default_notification_body CONSTANT VARCHAR2(300) :=
'Job: %job_owner%.%job_name%.%job_subname%
Event: %event_type%
Date: %event_timestamp%
Log id: %log_id%
Job class: %job_class_name%
Run count: %run_count%
Failure count: %failure_count%
Retry count: %retry_count%
Error code: %error_code%
Error message:
%error_message%
';

-- Program/Job types
-- 'PLSQL_BLOCK'
-- 'STORED_PROCEDURE'
-- 'EXECUTABLE'
-- 'CHAIN'   (only valid for a job)

-- Metadata attributes (for a program argument)
-- 'JOB_NAME'
-- 'JOB_SUBNAME'
-- 'JOB_OWNER'
-- 'JOB_START'
-- 'SCHEDULED_JOB_START'
-- 'EVENT_MESSAGE'
-- 'WINDOW_START'
-- 'WINDOW_END'

-- Window Priorities
-- 'HIGH'
-- 'LOW'

-- Constants for raise events flags
job_started           CONSTANT PLS_INTEGER := 1;
job_succeeded         CONSTANT PLS_INTEGER := 2;
job_failed            CONSTANT PLS_INTEGER := 4;
job_broken            CONSTANT PLS_INTEGER := 8;
job_completed         CONSTANT PLS_INTEGER := 16;
job_stopped           CONSTANT PLS_INTEGER := 32;
job_sch_lim_reached   CONSTANT PLS_INTEGER := 64;
job_disabled          CONSTANT PLS_INTEGER := 128;
job_chain_stalled     CONSTANT PLS_INTEGER := 256;
job_all_events        CONSTANT PLS_INTEGER := 511;
job_over_max_dur      CONSTANT PLS_INTEGER := 512;
job_run_completed     CONSTANT PLS_INTEGER :=
                        job_succeeded + job_failed + job_stopped;

/*************************************************************
 * Program Administration Procedures
 *************************************************************
 */

-- Program attributes which can be used with set_attribute/get_attribute are:
--
-- program_action     - VARCHAR2
--                      This is a string specifying the action. In case of:
--                      'PLSQL_BLOCK': PLSQL code
--                      'STORED_PROCEDURE: name of the database object
--                         representing the type (optionally with schema).
--                      'EXECUTABLE': Full pathname including the name of the
--                         executable, or shell script.
-- program_type       - VARCHAR2
--                      type of program. This must be one of the supported
--                      program types. Currently these are
--                      'PLSQL_BLOCK', 'STORED_PROCEDURE', 'EXECUTABLE'
-- comments              - VARCHAR2
--                      an optional comment. This can describe what the
--                      program does, or give usage details.
-- number_of_arguments- PLS_INTEGER
--                      the number of arguments of the program that can be set
--                      by any job using it, these arguments MUST be defined
--                      before the program can be enabled
-- enabled            - BOOLEAN
--                      whether the program is enabled or not. When the program
--                      is enabled, checks are made to ensure that the program
--                      is valid.

-- Create a new program. The program name can be optionally qualified with a
-- schema. If enabled is set to TRUE, validity checks will be performed and
-- the program will be created in an enabled state if all are passed.
PROCEDURE create_program(
  program_name            IN VARCHAR2,
  program_type            IN VARCHAR2,
  program_action          IN VARCHAR2,
  number_of_arguments     IN PLS_INTEGER DEFAULT 0,
  enabled                 IN BOOLEAN DEFAULT FALSE,
  comments                IN VARCHAR2 DEFAULT NULL);

-- Drops an existing program (or a comma separated list of programs).
-- When force is set to false the program must not be
-- referred to by any job.  When force is set to true, any jobs referring to
-- this program will be disabled (same behavior as calling the disable routine
-- on those jobs with the force option).
-- Any argument information that was created for this program will be dropped
-- with the program.
PROCEDURE drop_program(
  program_name            IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

-- Define an argument of a program. All arguments of a program must be defined.
-- If given, the argument name must be unique for this program.
-- Any argument already defined at this position will be overwritten.
-- The argument type must be a valid Oracle or user-defined type.
-- out_argument is reserved for future use. The default and only valid value
-- is FALSE.
PROCEDURE define_program_argument(
 program_name            IN VARCHAR2,
 argument_position       IN PLS_INTEGER,
 argument_name           IN VARCHAR2 DEFAULT NULL,
 argument_type           IN VARCHAR2,
 default_value           IN VARCHAR2,
 out_argument            IN BOOLEAN DEFAULT FALSE);

-- Define an argument of a program without a default value.
-- Any job using this program must set a value to this argument.
-- See other notes for define_program_argument above.
PROCEDURE define_program_argument(
 program_name            IN VARCHAR2,
 argument_position       IN PLS_INTEGER,
 argument_name           IN VARCHAR2 DEFAULT NULL,
 argument_type           IN VARCHAR2,
 out_argument            IN BOOLEAN DEFAULT FALSE);

-- Define an argument with a default value encapsulated in an ANYDATA.
-- See other notes for define_program_argument above.
PROCEDURE define_anydata_argument(
  program_name            IN VARCHAR2,
  argument_position       IN PLS_INTEGER,
  argument_name           IN VARCHAR2 DEFAULT NULL,
  argument_type           IN VARCHAR2,
  default_value           IN SYS.ANYDATA,
  out_argument            IN BOOLEAN DEFAULT FALSE);

-- Define a special metadata argument for the program. The program developer
-- can retrieve specific scheduler metadata through this argument.
-- Jobs cannot set values for this argument.
-- valid metadata_attributes are: 'COMPLETION_CODE', 'JOB_SUBNAME','JOB_NAME',
-- 'JOB_OWNER', 'JOB_START', 'WINDOW_START', 'WINDOW_END', 'EVENT_MESSAGE'
-- See other notes for define_program_argument above.
PROCEDURE define_metadata_argument(
  program_name            IN VARCHAR2,
  metadata_attribute      IN VARCHAR2,
  argument_position       IN PLS_INTEGER,
  argument_name           IN VARCHAR2 DEFAULT NULL);

-- drop a program argument either by name or position
PROCEDURE drop_program_argument (
  program_name            IN VARCHAR2,
  argument_position       IN PLS_INTEGER);

PROCEDURE drop_program_argument (
  program_name            IN VARCHAR2,
  argument_name           IN VARCHAR2);

/*************************************************************
 * Job Administration Procedures
 *************************************************************
 */

-- Job attributes which can be used with set_attribute/get_attribute are :
--
-- program_name      - VARCHAR2
--                     The name of a program object to use with this job.
--                     If this is set, job_action, job_type and
--                     number_of_arguments should be NULL
-- job_action        - VARCHAR2
--                     This is a string specifying the action. In case of:
--                      'PLSQL_BLOCK': PLSQL code
--                      'STORED_PROCEDURE': name of the database stored 
--                          procedure (C, Java or PL/SQL), optionally qualified
--                          with a schema name).
--                      'EXECUTABLE': Name of an executable of shell script
--                         including the full pathname and any command-line
--                         flags to it.
--                     If this is set, program_name should be NULL.
-- job_type          - VARCHAR2
--                      type of this job. Can be any of:
--                      'PLSQL_BLOCK', 'STORED_PROCEDURE', 'EXECUTABLE'
--                     If this is set,program_name should be NULL
-- number_of_arguments- PLS_INTEGER
--                     the number of arguments if the program is inlined. If
--                     this is set, program_name should be NULL.
-- schedule_name     - VARCHAR2
--                     The name of a schedule or window or window group to use
--                     as the schedule for this job.
--                     If this is set, end_date, start_date and repeat_interval
--                     should all be NULL.
-- repeat_interval   - VARCHAR2
--                     either a PL/SQL function returning the next date on
--                     which to run,or calendar syntax expression.
--                     If this is set, schedule_name should be NULL.
-- start_date        - TIMESTAMP WITH TIME ZONE
--                     the original date on which this job was or will be
--                     scheduled to start.
--                     If this is set, schedule_name should be NULL.
-- end_date          - TIMESTAMP WITH TIME ZONE
--                     the date after which the job will no longer run (it will
--                     be dropped if auto_drop is set or disabled with the
--                     state changed to 'COMPLETED' if it is)
--                     If this is set, schedule_name should be NULL.
-- schedule_limit    - INTERVAL DAY TO SECOND
--                     time in minutes after the scheduled time after which a
--                     job that has not been run will be rescheduled. This is
--                     only valid for repeating jobs.
--                     If this is NULL, a job will never
--                     be rescheduled unless it has been run (failed or
--                     successfully)
-- job_class         - VARCHAR2
--                     the class this job is associated with.
-- job_priority      - PLS_INTEGER
--                     the priority of this job relative to other jobs in the
--                     same class. The default is 3 and values should
--                     be 1 and 5 (1 being the highest priority)
-- comments           - VARCHAR2
--                     an optional comment.
-- max_runs          - PLS_INTEGER
--                     the maximum number of consecutive times this job will be
--                     allowed to be run (after this number of consecurtive
--                     times it will be disabled and its state will be changed
--                     to 'COMPLETED'
-- job_weight        - PLS_INTEGER
--                     jobs which include parallel queries should set this to
--                     the number of parallel slaves they expect to spawn
-- logging_level     - PLS_INTEGER
--                     represents how much logging pertaining to
--                     this job should be done
-- max_run_duration  - INTERVAL DAY TO SECOND
--                     the max time for the job to run, if the job runs for
--                     longer than this interval, a job_over_max_dur event
--                     will be raised (the job will not be stopped)
-- max_failures      - PLS_INTEGER
--                     the number of times a job can fail on consecutive
--                     scheduled runs before it is automatically disabled. If
--                     this is set to 0 then the job will keep running no
--                     matter how often it has failed. If a job is
--                     automatically disabled after having failed this number
--                     of times, its state will be changed to BROKEN.
-- instance_stickiness- BOOLEAN
--                      If this option is set to TRUE, then for the first run
--                      of the job the scheduler will choose the instance with
--                      the lightest load to run this job on. Subsequent runs
--                      will use the same instance that the first run used
--                      (unless this instance is down). If this is FALSE then
--                      the scheduler will choose the first available instance
--                      to schedule the job on on all runs.
-- stop_on_window_exit - BOOLEAN
--                       If this job has a window or window group as a schedule
--                       it will be stopped if the associated window closes, if
--                       this boolean attribute is set to TRUE.
-- enabled             - BOOLEAN
--                       whether the job is enabled or not
-- auto_drop           - BOOLEAN
--                       whether the job should be dropped after having
--                       completed
-- restartable         - BOOLEAN
--                       whether the job can be safely restarted (and should be
--                       restarted in case of failure). By default this is set
--                       to FALSE.
-- destination_name      VARCHAR2 
--                       Destination name as created with 
--                       create_database_destination
--                       or an external agent destination name 
--                       or destination group name
-- credential            VARCHAR2 
--                       Credential name as created with create_credential

-- create a job in a single call (without using an existing program or
-- schedule).
-- Valid values for job_type and job_action are the same as those for
-- program_type and program_action. If enabled is set TRUE, it will be
-- attempted to enable this job after creating it. If number_of_arguments is
-- set non-zero, values must be set for each of the arguments before enabling
-- the job.
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  job_type                 IN VARCHAR2,
  job_action              IN VARCHAR2,
  number_of_arguments     IN PLS_INTEGER              DEFAULT 0,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  repeat_interval         IN VARCHAR2                 DEFAULT NULL,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                IN VARCHAR2                 DEFAULT NULL,
  credential_name         IN VARCHAR2                 DEFAULT NULL,
  destination_name        IN VARCHAR2                 DEFAULT NULL);

-- create a job using inlined program and inlined event schedule.
-- If enabled is set TRUE, it will be attempted to enable this job after
-- creating it.
-- Values must be set for each argument of the program that does not have a
-- default_value specified (before enabling the job).
-- Note that there are no defaults for event_condition and queue_spec. They
-- must be set explicitly to create an event based job.
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  job_type                 IN VARCHAR2,
  job_action              IN VARCHAR2,
  number_of_arguments     IN PLS_INTEGER              DEFAULT 0,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  event_condition         IN VARCHAR2                 DEFAULT NULL,
  queue_spec              IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                IN VARCHAR2                 DEFAULT NULL,
  credential_name         IN VARCHAR2                 DEFAULT NULL,
  destination_name        IN VARCHAR2                 DEFAULT NULL);

-- create a job using a named schedule object and a named program object.
-- If enabled is set TRUE, it will be attempted to enable this job after
-- creating it.
-- Values must be set for each argument of the program that does not have a
-- default_value specified (before enabling the job).
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  program_name            IN VARCHAR2,
  schedule_name           IN VARCHAR2,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                 IN VARCHAR2                 DEFAULT NULL,
  job_style               IN VARCHAR2                 DEFAULT 'REGULAR',
  credential_name         IN VARCHAR2                 DEFAULT NULL,
  destination_name        IN VARCHAR2                 DEFAULT NULL);

-- create a job using a named program object and an inlined schedule
-- If enabled is set TRUE, it will be attempted to enable this job after
-- creating it.
-- Values must be set for each argument of the program that does not have a
-- default_value specified (before enabling the job).
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  program_name            IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  repeat_interval         IN VARCHAR2                 DEFAULT NULL,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                 IN VARCHAR2                 DEFAULT NULL,
  job_style               IN VARCHAR2                 DEFAULT 'REGULAR',
  credential_name         IN VARCHAR2                 DEFAULT NULL,
  destination_name        IN VARCHAR2                 DEFAULT NULL);

-- create a job using named program and inlined event schedule.
-- If enabled is set TRUE, it will be attempted to enable this job after
-- creating it.
-- Values must be set for each argument of the program that does not have a
-- default_value specified (before enabling the job).
-- Note that there are no defaults for event_condition and queue_spec. They
-- must be set explicitly to create an event based job.
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  program_name            IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  event_condition         IN VARCHAR2                 DEFAULT NULL,
  queue_spec              IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                 IN VARCHAR2                 DEFAULT NULL,
  job_style               IN VARCHAR2                 DEFAULT 'REGULAR',
  credential_name         IN VARCHAR2                 DEFAULT NULL,
  destination_name        IN VARCHAR2                 DEFAULT NULL);

-- create a job using a named schedule object and an inlined program
-- Valid values for job_type and job_action are the same as those for
-- program_type and program_action. If enabled is set TRUE, it will be
-- attempted to enable this job after creating it. If number_of_arguments is
-- set non-zero, values must be set for each of the arguments before enabling
-- the job.
PROCEDURE create_job(
  job_name                IN VARCHAR2,
  schedule_name           IN VARCHAR2,
  job_type                 IN VARCHAR2,
  job_action              IN VARCHAR2,
  number_of_arguments     IN PLS_INTEGER              DEFAULT 0,
  job_class               IN VARCHAR2              DEFAULT 'DEFAULT_JOB_CLASS',
  enabled                 IN BOOLEAN                  DEFAULT FALSE,
  auto_drop               IN BOOLEAN                  DEFAULT TRUE,
  comments                 IN VARCHAR2                 DEFAULT NULL,
  credential_name         IN VARCHAR2                 DEFAULT NULL,
  destination_name        IN VARCHAR2                 DEFAULT NULL);

-- Run a job immediately. If use_current_session is TRUE the job is run in the
-- user's current session. If use_current_session is FALSE the job is run in the
-- background by a dedicated job slave.
PROCEDURE run_job(
  job_name                IN VARCHAR2,
  use_current_session     IN BOOLEAN DEFAULT TRUE);

-- Stop a job or several jobs that are currently running. Job name can also be
-- the name of a job class or a comma-separated list of jobs.
-- If the force option is not specified this will interrupt the job
-- by sending an equivalent of a Ctrl-C to the job. If this fails, an error
-- will be returned.
-- If the force option is specified the job slave will be terminated. Use of
-- the force option requires the MANAGE SCHEDULER system privilege
PROCEDURE stop_job(
  job_name                IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE,
  commit_semantics        IN VARCHAR2 DEFAULT 'STOP_ON_FIRST_ERROR');

-- Copy a job. The new_job will contain all the attributes of the old_job,
-- except that it will be created disabled. The state of the old_job will not
-- be altered.
PROCEDURE copy_job(
  old_job                 IN VARCHAR2,
  new_job                 IN VARCHAR2);

-- Drop a job or several jobs.  Job name can also be
-- the name of a job class or a comma-separated list of jobs.
-- If force is true, all running instances of the job will be stopped by
-- calling stop_job with force set to false. If defer is true, all running
-- instances of the job will be allowed to complete before the job is dropped.
-- If force and defer are false, dropping a job with running instances will 
-- fail.  If force and defer are both true, an error will be raised.
PROCEDURE drop_job(
  job_name                IN VARCHAR2,
  force                   IN BOOLEAN      DEFAULT FALSE,
  defer                   IN BOOLEAN      DEFAULT FALSE,
  commit_semantics        IN VARCHAR2 DEFAULT 'STOP_ON_FIRST_ERROR');

-- Set a value to be passed to one of the arguments of the program (either
-- named, or inlined). If program is inlined, only setting by position is
-- supported. The passed value will override any default value set during
-- definition of the program argument and overwrite any value previously set
-- for this argument position for this job (the previous value will be lost).
PROCEDURE set_job_argument_value(
  job_name                IN VARCHAR2,
  argument_position       IN PLS_INTEGER,
  argument_value          IN VARCHAR2);

-- This refers to a program argument by its name. It can only be used if the
-- job is using a named program (i.e. program_name points to an existing
-- program). The argument_name used must be the same name defined by the
-- program. 
PROCEDURE set_job_argument_value(
  job_name                IN VARCHAR2,
  argument_name           IN VARCHAR2,
  argument_value          IN VARCHAR2);

-- Same as above but accepts the default value encapsulated in an AnyData
PROCEDURE set_job_anydata_value(
  job_name                IN VARCHAR2,
  argument_position       IN PLS_INTEGER,
  argument_value          IN SYS.ANYDATA);

-- This refers to a program argument by its name. It can only be used if the
-- job is using a named program (i.e. program_name points to an existing
-- program). The argument_name used must be the same name defined by the
-- program. 
PROCEDURE set_job_anydata_value(
  job_name                IN VARCHAR2,
  argument_name           IN VARCHAR2,
  argument_value          IN SYS.ANYDATA);

-- Clear a previously set job argument value. All job specific value
-- information for this argument is erased. The job will revert back to the
-- default value for this argument as defined by the program (if any).
PROCEDURE reset_job_argument_value(
  job_name                IN VARCHAR2,
  argument_position       IN PLS_INTEGER);

-- This refers to a program argument by its name. It can only be used if the
-- job is using a named program (i.e. program_name points to an existing
-- program). The argument_name used must be the same name defined by the
-- program. 
PROCEDURE reset_job_argument_value(
  job_name                IN VARCHAR2,
  argument_name           IN VARCHAR2);

/*************************************************************
 * Job Destination Administration Procedures
 *************************************************************
 */
-- * Create group: Create a destination group to be set as a destination of 
--   a job.
-- * The namespace for groups is different from that of database objects
--   but we will not allow creating a group with the name of an existing
--   object.
-- * All members of the group must be of the same type. In the case of a
--   destination group all members must either represent destinations for
--   external jobs or destinations for database jobs.
-- * The format of destination members is
--   [[schema.]credential@][schema.]destination. The credential part is
--   optional.  If  it isn't present the job instance representing this
--   destination will use the default credential specified with the job.
-- * An error will be returned if one of the members does not exist. Or in
--   the  case of destinations groups if either part of the destination
--   (credential or destination) does not exist.
-- * Groups will reside in a particular schema but there are no specific
--   privileges you can grant on groups. Only the owner and SYS can modify
--   the group (create, add, remove, drop) and everybody can see which groups
--   have been created. However, you will only be able to see those member   
--   of a group that you have access to (i.e. privileges on).
--   Even though there are no privileges on destinations, you still will not
--   be able to see those destination group members that contain a credential
--   you have no access to.
-- * When groups are used in API calls, the action will only be performed on
--   those members of the group that you have privileges on.
-- * LOCAL  and  ALL_INSTANCES  are special keywords only to be used as
--   destination group members. LOCAL can be used for external as well as
--   database jobs. In the case of a database job it represents the source
--   database on which the job is created. In the case of an external job it
--   represents the machine on which the source database runs. When the
--   source  database is a RAC database the destination LOCAL_INSTANCES
--   indicates that a database job must be run on every instance of the
--   database and an external job must run on every machine that runs an
--   instance of the database. LOCAL and ALL_INSTANCES can not be used as
--   group names.
-- Arguments:
-- * group_name -- Name of group
-- * group_type --  Group type, currently only 'DESTINATION' is supported
-- * member     --  Optional list of group members. Default is NULL.
-- * comments   --  Comments
PROCEDURE  create_group(

        group_name IN VARCHAR2,
        group_type IN VARCHAR2,
        member     IN VARCHAR2 DEFAULT NULL,
        comments   IN VARCHAR2 DEFAULT NULL);

-- Drop Group:
-- * When a group of type destination is dropped the jobs that have their
--   destination attribute set to this group will be disabled. All its job
--   instances will be removed from the *_scheduler_job_destinations view.
-- Arguments:
-- * group_name Name of group
-- * force      Unused for now
PROCEDURE drop_group(
                group_name IN VARCHAR2,
                force      IN BOOLEAN DEFAULT FALSE);

-- Add group member:
-- * Member is a comma separated list of new members to add.
-- * The  members  of  a group must be of the same type. In the case of
--   destination groups the members must either be all external destinations
--   or all database destinations.
-- * Groups can not be specified in the member list not even to get them
--   fully expanded.
-- * The member will be canonicalized.
-- * This routine will skip a member if it is already a member of the group.
--   It will not error out.
-- * LOCAL  and  ALL_INSTANCES are reserved keywords only to be used as
--   destination group members. See create_group() for more information.
-- Arguments:
-- * group_name: Name of group
-- * member:     Name of one or more members to add to the group
PROCEDURE add_group_member (
         group_name IN VARCHAR2,
         member     IN VARCHAR2);


-- Remove group member:
-- * Member is a comma separated list of members to remove from the group.
-- * An error will be returned if the specified member is not part of the group.
-- * The member will only be removed from this group.
-- * If the member is a destination, any job instances that represent this
--   destination will be removed from the all_scheduler_job_destinations view.
-- Arguments:
-- * group_name Name of group
-- * member     Name of the member to remove from the group
PROCEDURE remove_group_member(
             group_name IN VARCHAR2,
             member     IN VARCHAR2);


-- Create database destination
-- * It's only possible to create a remote database job if first a database
--   destination that represents the remote database has been created.
-- * The agent value must be an existing external destination name.
-- Arguments:
-- * destination_name Name of destination representing the
--                 database that you want to connect to.
-- * agent            Name of the external destination that represents
--                 the agent that is used to connect to the remote database.
-- * tns_name         Name of the local tnsnames.ora entry that
--                  points to the remote database to connect to.
-- * comments         Comments
PROCEDURE create_database_destination(
  destination_name IN VARCHAR2,
  agent            IN VARCHAR2,
  tns_name         IN VARCHAR2,
  comments         IN VARCHAR2 DEFAULT NULL);

-- Drop database destination: 
-- * When a database destination is dropped all members of destination groups
--   that point to this destination will be dropped as well.
-- * When a database destination is dropped all the job instances in the
--   scheduler_job_destinations views that point to this destination will
--   be dropped as well.
-- Arguments:
-- *  destination_name: Name of destination representing the database that 
--     you want to connect to.
PROCEDURE drop_database_destination(
  destination_name IN VARCHAR2);

-- Drop external destination: 
-- * Emergency use only, use agent control utility on agent residing 
--   host to drop the agent destination.
-- * When an agent destination is dropped all the job instances in the
--   scheduler_job_destinations views that point to this destination will
--   be dropped as well.
-- * all database destinations refering to the agent destination will 
--   be dropped as well.
-- * Manage scheduler privilege is required for this procedure
-- Arguments:
-- * destination_name: Name of destination representing the external job 
--    agent 
PROCEDURE drop_agent_destination(
  destination_name IN VARCHAR2);
/*************************************************************
 * Job Class Administration Procedures
 *************************************************************
*/

-- Job Class attributes which can be used with set_attribute/get_attribute are:
--
-- resource_consumer_group - VARCHAR2
--                       resource consumer group a class is associated with
-- service             - VARCHAR2
--                       The service the job class belongs to. Default is NULL,
--                       which implies the default service. This should be the
--                       name of the service database object and not the
--                       service name as defined in tnsnames.ora .
-- log_purge_policy    - VARCHAR2
--                       The policy for purging of scheduler log table entries
--                       pertaining to jobs belonging to this class. By default
--                       log table entries are not purged.
-- comments             - VARCHAR2
--                       an optional comment about the class.

-- Create a job class.
PROCEDURE create_job_class(
  job_class_name          IN VARCHAR2,
  resource_consumer_group IN VARCHAR2     DEFAULT NULL,
  service                 IN VARCHAR2     DEFAULT NULL,
  logging_level           IN PLS_INTEGER  DEFAULT DBMS_SCHEDULER.LOGGING_RUNS,
  log_history             IN PLS_INTEGER  DEFAULT NULL,
  comments                IN VARCHAR2     DEFAULT NULL);

-- Drop a job class (or a comma-separated list of classes). This will return
-- an error if force is set to FALSE and
-- there are still jobs (in any state) that are part of this class.
-- If force is set to TRUE, all jobs that are part of this class will be
-- disabled and their class will be set to the default class.
PROCEDURE drop_job_class(
  job_class_name              IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

/*************************************************************
 * System Window Administration Procedures
 *************************************************************
 */

-- System window attributes that can be used with set_attribute/get_attribute
-- are:
--
-- resource_plan       - VARCHAR2
--                       the resource plan to be associated with a window.
--                       When the window opens, the system will switch to
--                       using this resource plan. When the window closes, the
--                       original resource plan will be restored. If a
--                       resource plan has been made active with the force
--                       option, no resource plan switch will occur.
-- window_priority     - VARCHAR2
--                       The priority of the window. Must be one of
--                       'LOW' (default) , 'HIGH'.
-- duration            - INTERVAL DAY TO SECOND
--                       The duration of the window in minutes.
-- schedule_name       - VARCHAR2
--                       The name of a schedule to use with this window. If
--                       this is set, start_date, end_date and repeat_interval
--                       must all be NULL.
-- repeat_interval     - VARCHAR2
--                       A string using the calendar syntax. PL/SQL date
--                       functions are not allowed
--                       If this is set, schedule_name must be NULL
-- start_date          - TIMESTAMP WITH TIME ZONE
--                       next date on which this window is scheduled to open.
--                       If this is set, schedule_name must be NULL.
-- end_date            - TIMESTAMP WITH TIME ZONE
--                       the date after which the window will no longer open.
--                       If this is set, schedule_name must be NULL.
-- enabled             - BOOLEAN
--                       whether the window is enabled or not
-- comments             - VARCHAR2
--                       an optional comment about the window.
-- The below attribute is only visible through the views and not to
-- get_attribute or set_attribute
-- schedule_type     - VARCHAR2
--                     will be one of: 'CALENDAR_STRING', 'NAMED'

-- Create a system window using a named schedule object. The specified
-- schedule must exist.
PROCEDURE create_window(
  window_name             IN VARCHAR2,
  resource_plan            IN VARCHAR2,
  schedule_name           IN VARCHAR2,
  duration                IN INTERVAL DAY TO SECOND,
  window_priority         IN VARCHAR2                 DEFAULT 'LOW',
  comments                 IN VARCHAR2                 DEFAULT NULL);

-- Create a system window using an inlined schedule.
-- repeat_interval must use the calendar syntax. PL/SQL date functions are not
-- allowed.
PROCEDURE create_window(
  window_name             IN VARCHAR2,
  resource_plan           IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  repeat_interval         IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
  duration                IN INTERVAL DAY TO SECOND,
  window_priority         IN VARCHAR2                 DEFAULT 'LOW',
  comments                 IN VARCHAR2                 DEFAULT NULL);

-- Drops a scheduler system window. Window name can also be a window group (in
-- which case all the windows in that window group are dropped) or a
-- comma-separated list of windows. Dropping a window disables all jobs which
-- use the window as a schedule (leaving currently running jobs running). If
-- the window is open, dropping it will attempt to close it first
-- The window is also dropped from any referring window groups.
PROCEDURE drop_window(
  window_name             IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

-- Immediately opens a scheduler window independent of its specified schedule.
-- The window will be opened for the specified duration. If the duration is
-- null, the window will be opened for the duration as specified when the
-- window was created.
-- The next open time of the window is not updated, and will be as determined
-- by the regular scheduled opening.
-- Opening of the window will fail if the DBA has blocked the scheduler from
-- switching to a different resource plan.
-- If force option not specified and a current window is active the operation
-- will fail, unless the window is the current open window. 
-- If the current open window equals window_name, the closing time  is set to 
-- the system date plus the given duration, i.e. the closing time of the 
-- current window is moved up or down, but no jobs are stopped.
PROCEDURE open_window(
  window_name             IN VARCHAR2,
  duration                IN INTERVAL DAY TO SECOND,
  force                   IN BOOLEAN DEFAULT FALSE);

-- Prematurely closes the currently active window. This premature closing
-- of a window will have the same effect as a regular close e.g. any jobs that
-- have a window or a window group as their schedule and were started at the
-- beginning of this window because of that schedule and have indicated that
--they must be stopped on closing of the window, will be stopped.
PROCEDURE close_window(
  window_name             IN VARCHAR2);

/*************************************************************
 * System Window Administration Procedures
 *************************************************************
 */

-- enable and disable can be used on window groups. They disable/enable the
-- window group as a whole, not the individual windows in the group. 
--
-- member_list refers to a comma-separated list of windows
-- Window groups cannot contain other window groups.

-- Creates a window group optionally containing windows specified in
-- member_list.
PROCEDURE create_window_group(
  group_name             IN VARCHAR2,
  window_list            IN VARCHAR2 DEFAULT NULL,
  comments               IN VARCHAR2 DEFAULT NULL);

-- Adds a window (or comma-separated list of windows) to a window group.
-- If a window is already in the window group, it will not be added again.
PROCEDURE add_window_group_member(
  group_name             IN VARCHAR2,
  window_list            IN VARCHAR2);

-- Removes a window (or comma-separated list of windows) from a window group.
PROCEDURE remove_window_group_member(
  group_name             IN VARCHAR2,
  window_list            IN VARCHAR2);

-- Drops a window group (does not drop windows that are members of this group)
-- Returns an error when force is set to false and there are jobs whose
-- schedule is the name of the window group. If force is set to true, any jobs
-- whose schedule is the name of the window group will be disabled.
PROCEDURE drop_window_group(
  group_name             IN VARCHAR2,
  force                  IN BOOLEAN DEFAULT FALSE);

-- Get scheduler default time and timezone.
-- This would be used for jobs without a start time specified.
-- Follow default timezone can be set to simulate an object with 
-- this attribute set (i.e system windows etc).
FUNCTION stime (
        follow_default_timezone BOOLEAN DEFAULT FALSE) 
        RETURN TIMESTAMP WITH TIME ZONE;

-- Get the version of a Scheduler Execution Agent
FUNCTION get_agent_version(
  agent_host             IN VARCHAR2) RETURN VARCHAR2;

-- Internal.
-- Used for initializing the scheduler default timezone.
FUNCTION get_sys_time_zone_name  RETURN VARCHAR2;

/*************************************************************
 * Schedule Administration Procedures
 *************************************************************
 */

-- Schedule attributes which can be used with set_attribute/get_attribute are :
--
-- repeat_interval   - VARCHAR2
--                     an expression using the calendar syntax
-- comments          - VARCHAR2
--                     an optional comment.
-- end_date          - TIMESTAMP WITH TIME ZONE
--                     cutoff date after which the schedule will not specify
--                     any dates
-- start_date        - TIMESTAMP WITH TIME ZONE
--                     start or reference date used by the calendar syntax
--
-- Schedules cannot be enabled and disabled.

-- Create a named schedule. This must be a valid schedule.
PROCEDURE create_schedule(
  schedule_name           IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE  DEFAULT NULL,
  repeat_interval         IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE  DEFAULT NULL,
  comments                IN VARCHAR2                  DEFAULT NULL);

--- Import helper function. 
PROCEDURE disable1_calendar_check;

-- Create a named event schedule. This must be a valid schedule.
PROCEDURE create_event_schedule(
  schedule_name           IN VARCHAR2,
  start_date              IN TIMESTAMP WITH TIME ZONE  DEFAULT NULL,
  event_condition         IN VARCHAR2                  DEFAULT NULL,
  queue_spec              IN VARCHAR2,
  end_date                IN TIMESTAMP WITH TIME ZONE  DEFAULT NULL,
  comments                IN VARCHAR2                  DEFAULT NULL);

-- Drop a schedule (or comma-separated list of schedules). When force is set
-- to false, and there are jobs or windows
-- that point to this schedule an error will be raised.
-- If force is set to true, any jobs or windows pointing to this schedule will
-- be disabled before the schedule is dropped.
-- Schedules may refer to day calendar schedules in which case no checking 
-- occurs. Thus for day calendar drops  force is always assumed true, 
-- even if specified as false.
PROCEDURE drop_schedule(
  schedule_name           IN VARCHAR2,
  force                   IN BOOLEAN      DEFAULT FALSE);

/*************************************************************
 * Chain Administration Procedures
 *************************************************************
 */

-- Chain attributes which can be used with set_attribute/get_attribute
-- are :
--
-- comments            - VARCHAR2
--                       an optional comment.
-- evaluation_interval - INTERVAL DAY TO SECOND
--                       interval between periodic re-evaluations of a
--                       running chain
--

-- Creates a chain.
-- Chains are created disabled and must be enabled before use.
PROCEDURE create_chain(
  chain_name              IN VARCHAR2,
  rule_set_name           IN VARCHAR2   DEFAULT NULL,
  evaluation_interval     IN INTERVAL DAY TO SECOND DEFAULT NULL,
  comments                IN VARCHAR2   DEFAULT NULL);

-- adds or replaces a chain rule
PROCEDURE define_chain_rule(
  chain_name              IN VARCHAR2,
  condition               IN VARCHAR2,
  action                  IN VARCHAR2,
  rule_name               IN VARCHAR2 DEFAULT NULL,
  comments                IN VARCHAR2 DEFAULT NULL);

-- adds or replaces a chain step and associates it with a program
-- or chain
PROCEDURE define_chain_step(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  program_name            IN VARCHAR2);

-- adds or replaces a chain step and associates it with an event schedule
PROCEDURE define_chain_event_step(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  event_schedule_name     IN VARCHAR2,
  timeout                 IN INTERVAL DAY TO SECOND DEFAULT NULL);

-- adds or replaces a chain step and associates it with an inline event
PROCEDURE define_chain_event_step(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  event_condition         IN VARCHAR2,
  queue_spec              IN VARCHAR2,
  timeout                 IN INTERVAL DAY TO SECOND DEFAULT NULL);

-- drops a chain rule
PROCEDURE drop_chain_rule(
  chain_name              IN VARCHAR2,
  rule_name               IN VARCHAR2,
  force                   IN BOOLEAN  DEFAULT FALSE);

-- drops a chain step
PROCEDURE drop_chain_step(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  force                   IN BOOLEAN  DEFAULT FALSE);

-- alters steps of a chain
PROCEDURE alter_chain(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  attribute               IN VARCHAR2,
  value                   IN BOOLEAN);

-- alters steps of a chain
PROCEDURE alter_chain(
  chain_name              IN VARCHAR2,
  step_name               IN VARCHAR2,
  attribute               IN VARCHAR2,
  char_value              IN VARCHAR2);

-- drops a chain
PROCEDURE drop_chain(
  chain_name              IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

-- analyzes a chain or a list of steps and rules and outputs a list of
-- chain dependencies
PROCEDURE analyze_chain(
chain_name  IN VARCHAR2,
rules       IN sys.scheduler$_rule_list,
steps       IN sys.scheduler$_step_type_list,
step_pairs  OUT sys.scheduler$_chain_link_list);

-- alters steps of a running chain
PROCEDURE alter_running_chain(
  job_name                IN VARCHAR2,
  step_name               IN VARCHAR2,
  attribute               IN VARCHAR2,
  value                   IN BOOLEAN);

-- alters steps of a running chain
PROCEDURE alter_running_chain(
  job_name                IN VARCHAR2,
  step_name               IN VARCHAR2,
  attribute               IN VARCHAR2,
  value                   IN VARCHAR2);

-- forces immediate evaluation of a running chain
PROCEDURE evaluate_running_chain(
  job_name                IN VARCHAR2);

-- immediately runs a job pointing to a chain starting with a list of
-- specified steps. The job will be started in the background.
-- If start_steps is NULL, the chain is run from the beginning.
PROCEDURE run_chain(
  chain_name              IN VARCHAR2,
  start_steps             IN VARCHAR2,
  job_name                IN VARCHAR2 DEFAULT NULL);
-- immediately runs a job pointing to a chain starting with the given
-- list of step states. The job will be started in the background.
-- If step_state_list is NULL, the chain is run from the beginning.
PROCEDURE run_chain(
  chain_name              IN VARCHAR2,
  step_state_list         IN SYS.SCHEDULER$_STEP_TYPE_LIST,
  job_name                IN VARCHAR2 DEFAULT NULL);

/*************************************************************
 * Credential Administration Procedures
 *************************************************************
 */

-- credential attributes which can be used with set_attribute/get_attribute:
--
-- username           - VARCHAR2
--                      user to execute the job as.
-- password           - VARCHAR2
--                      password to use to authenticate the user
-- comments           - VARCHAR2
--                      an optional comment. This can describe what the
--                      credential is intended to be used for.
-- database_role      - VARCHAR2
--                      Database role to use when logging in (either SYSDBA or
--                      SYSOPER or NULL)
-- windows_domain     - VARCHAR2
--                      Windows domain to use when logging in

-- Create a new credential. The credential name can be optionally qualified
-- with a schema.
PROCEDURE create_credential(
  credential_name          IN VARCHAR2,
  username                 IN VARCHAR2,
  password                 IN VARCHAR2,
  database_role            IN VARCHAR2 DEFAULT NULL,
  windows_domain           IN VARCHAR2 DEFAULT NULL,
  comments                 IN VARCHAR2 DEFAULT NULL);

-- Drops an existing credential (or a comma separated list of credentials).
-- When force is set to false the credential must not be
-- referred to by any job.  When force is set to true, any jobs referring to
-- this credential will be disabled (same behavior as calling the disable
-- routine on those jobs with the force option).
PROCEDURE drop_credential(
  credential_name         IN VARCHAR2,
  force                   IN BOOLEAN DEFAULT FALSE);

-- Saves a file to one or more specified destination hosts. Uses a
-- specified credential to login to the given hosts. All specified remote hosts
-- must have an execution agent installed and running.
-- The caller must have the CREATE EXTERNAL JOB system privilege and
-- have EXECUTE privileges on the credential.
procedure put_file (
  destination_file             IN VARCHAR2,
  destination_host             IN VARCHAR2,
  credential_name              IN VARCHAR2,
  file_contents                IN CLOB CHARACTER SET ANY_CS,
  destination_permissions      IN VARCHAR2 DEFAULT NULL);
procedure put_file (
  destination_file             IN VARCHAR2,
  destination_host             IN VARCHAR2,
  credential_name              IN VARCHAR2,
  file_contents                IN BLOB,
  destination_permissions      IN VARCHAR2 DEFAULT NULL);
procedure put_file (
  destination_file             IN VARCHAR2,
  destination_host             IN VARCHAR2,
  credential_name              IN VARCHAR2,
  source_file_name             IN VARCHAR2,
  source_directory_object      IN VARCHAR2,
  destination_permissions      IN VARCHAR2 DEFAULT NULL);

-- Retrieves a file from a specified destination host. Uses a
-- specified credential to login to the given host. Any specified remote host
-- must have an execution agent installed and running.
-- The caller must have the CREATE EXTERNAL JOB system privilege and
-- have EXECUTE privileges on the credential.
procedure get_file (
  source_file                  IN VARCHAR2,
  source_host                  IN VARCHAR2,
  credential_name              IN VARCHAR2,
  file_contents                IN OUT NOCOPY CLOB CHARACTER SET ANY_CS);
procedure get_file (
  source_file                  IN VARCHAR2,
  source_host                  IN VARCHAR2,
  credential_name              IN VARCHAR2,
  file_contents                IN OUT NOCOPY BLOB);
procedure get_file (
  source_file                  IN VARCHAR2,
  source_host                  IN VARCHAR2,
  credential_name              IN VARCHAR2,
  destination_file_name        IN VARCHAR2,
  destination_directory_object IN VARCHAR2,
  destination_permissions      IN VARCHAR2 DEFAULT NULL);

procedure create_file_watcher (
  file_watcher_name            IN VARCHAR2,
  directory_path               IN VARCHAR2,
  file_name                    IN VARCHAR2,
  credential_name              IN VARCHAR2,
  destination                  IN VARCHAR2  DEFAULT NULL,
  min_file_size                IN PLS_INTEGER DEFAULT 0,
  steady_state_duration        IN INTERVAL DAY TO SECOND DEFAULT NULL,
  comments                     IN VARCHAR2 DEFAULT NULL,
  enabled                      IN BOOLEAN DEFAULT TRUE);

procedure drop_file_watcher (
  file_watcher_name          IN VARCHAR2,
  force                      IN BOOLEAN DEFAULT FALSE);

-- PROCEDURE add_job_email_notification:
-- ARGUMENTS:
-- job_name - Name of the job to send e-mail notifications for. Cannot be NULL
-- recipients - Comma-separated list of e-mail addresses to send
--     notifications to. E-mail notifications for all listed events will
--     be sent to all e-mail addresses provided. This cannot be NULL.
-- sender - E-mail address to use as the sender for e-mail
--     notifications. If this is NULL and the scheduler attribute
--     default_email_sender contains a valid e-mail address, that value will
--     be used instead.
-- subject - This will be used as the subject of notification e-mails. This
--     can contain the following variables for which values will be
--     substituted before the e-mail is sent:
--     %job_owner%
--     %job_name%
--     %job_subname%
--     %event_type%
--     %event_timestamp%
--     %log_id%
--     %error_code%
--     %error_message%
--     %run_count%
--     %failure_count%
--     %retry_count%
-- body - This will be used as the body of notification e-mails. This
--     can contain any of the variables that are valid in the subject.
-- events - Comma-separated list of events to e-mail notifications for.
--     E-mail notifications for all specified events will be sent to all
--     e-mail addresses provided. This cannot be NULL. The list of events that
--     can be set is documented under the raise_events attribute of jobs.
-- filter_condition - This will be used to additionally filter e-mail
--     notifications that are sent. If this is NULL (the default), all listed
--     events will be e-mailed to all specified recipient addresses. The
--     format is a SQL where-clause with :event bound to
--     a scheduler$_event_info type object.
--     For example to send e-mail only when the error number is 600 or 700
--     you can use the following filter_condition:
--     :event.error_code=600 or :event.error_code=700
--
-- This will add job e-mail notifications so that e-mails will be sent to the
-- specified recipient addresses whenever any of the listed events are
-- generated by the job. This will automatically modify the job to raise
-- these events by modifying the raise_events flag. If a filter_condition is
-- given, only events which match the filter_condition will generate an
-- e-mail.
-- This will fail if the scheduler attribute email_server is not set or if the
-- job specified does not exist.
PROCEDURE add_job_email_notification
(
  job_name             IN VARCHAR2,
  recipients           IN VARCHAR2,
  sender               IN VARCHAR2 DEFAULT NULL,
  subject              IN VARCHAR2
    DEFAULT dbms_scheduler.default_notification_subject,
  body                 IN VARCHAR2
    DEFAULT dbms_scheduler.default_notification_body,
  events               IN VARCHAR2 DEFAULT
'JOB_FAILED,JOB_BROKEN,JOB_SCH_LIM_REACHED,JOB_CHAIN_STALLED,JOB_OVER_MAX_DUR',
  filter_condition     IN VARCHAR2 DEFAULT NULL);

-- PROCEDURE remove_job_email_notification:
-- ARGUMENTS:
-- job_name - Name of the job to remove e-mail notifications for. This cannot
--     be NULL.
-- recipients - Comma-separated list of e-mail addresses to remove
--     notifications for. If this is NULL, all notifications for the given
--     job and listed events will be removed.
-- events - Comma-separated list of events to remove e-mail notifications for.
--     If this is NULL, all notifications for the given job and the listed
--     e-mail addresses will be removed.
--
-- This is used to remove one or more e-mail notifications for a given job.
-- It will not modify the job to stop raising the events, but no events will
-- be raised if there are no recipients. The user may reset the event flags
-- in the raise_events job attribute if he is sure that these events are not
-- required or used.
-- If one or both of recipients or events are comma-separated lists,
-- all matching combinations for the given job will be removed. If both are
-- NULL then all e-mail notifications for the job are removed. job_name cannot
-- be NULL.
PROCEDURE remove_job_email_notification
(
  job_name             IN VARCHAR2,
  recipients           IN VARCHAR2 DEFAULT NULL,
  events               IN VARCHAR2 DEFAULT NULL
);

/*************************************************************
 * Generic Procedures
 *************************************************************
 */

-- Disable a program, chain, job, window or window_group.
-- The procedure will NOT return an error if the object was already disabled.
-- It will return an error when force is set to false and:
--   name points to a program and there are jobs/chains pointing to the program
--   name points to a chain and there are jobs/chains pointing to the chain
--   name points to a window or window group and a job has that object as its
--     schedule
-- The only purpose of the force option is to point out dependencies. No
-- dependent objects are altered.
PROCEDURE disable(
  name                   IN VARCHAR2,
  force                  IN BOOLEAN DEFAULT FALSE,
  commit_semantics       IN VARCHAR2 DEFAULT 'STOP_ON_FIRST_ERROR');

-- Enable a program, chain, job, window or window group. The procedure will NOT
-- return an error if the object was already enabled.
PROCEDURE enable(
  name                  IN VARCHAR2,
  commit_semantics      IN VARCHAR2 DEFAULT 'STOP_ON_FIRST_ERROR');

-- Set an attribute of a scheduler object. Name can be the name of any
-- Scheduler object. The procedure is overloaded to accept
-- different datatypes.
-- number types are implicitly converted to varchar2
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN BOOLEAN);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN VARCHAR2,
  value2                IN VARCHAR2 DEFAULT NULL);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN DATE);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN TIMESTAMP);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN TIMESTAMP WITH TIME ZONE);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN TIMESTAMP WITH LOCAL TIME ZONE);
PROCEDURE set_attribute(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2,
  value                 IN INTERVAL DAY TO SECOND);

-- Set an attribute of a scheduler program to NULL
-- This is necessary because the overloading above does not allow NULL
-- as a valid value.
PROCEDURE set_attribute_null(
  name                  IN VARCHAR2,
  attribute             IN VARCHAR2);

-- Get the value of an attribute of a Scheduler object.
-- The procedure is overloaded to support different datatypes for the
-- attribute values: PLS_INTEGER, BOOLEAN,VARCHAR2, all date types.
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT PLS_INTEGER);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT BOOLEAN);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT DATE);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT TIMESTAMP);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT TIMESTAMP WITH TIME ZONE);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT TIMESTAMP WITH LOCAL TIME ZONE);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT INTERVAL DAY TO SECOND);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT VARCHAR2);
PROCEDURE get_attribute(
  name                  IN  VARCHAR2,
  attribute             IN  VARCHAR2,
  value                 OUT VARCHAR2,
  value2                OUT VARCHAR2);

/*************************************************************
 * Special Scheduler Administrative Procedures
 *************************************************************
 */

-- There are several scheduler attributes that control the behavior of the
-- scheduler. These have defaults but a DBA may wish to change the default
-- settings or view the current settings. These two functions are provided for
-- this purpose.
-- Even though the scheduler attributes have different types (e.g. strings,
-- numbers) all the values are passed as string literals. The set
-- procedure requires the MANAGE SCHEDULER privilege.
-- This takes effect immediately, but the resulting changes may not be seen
-- immediately.
-- Attributes which may be set are:
-- 'MAX_SLAVE_PROCESSES'(pls_integer), 'DEFAULT_LOG_PURGE_POLICY'(varchar2),
-- 'LOG_HISTORY' (pls_integer)

-- Set the value of a scheduler attribute. This takes effect immediately,
-- but the resulting changes may not be seen immediately.
PROCEDURE set_scheduler_attribute(
  attribute          IN VARCHAR2,
  value              IN VARCHAR2);

-- Get the value of a scheduler attribute.
PROCEDURE get_scheduler_attribute(
  attribute          IN VARCHAR2,
  value             OUT VARCHAR2);

PROCEDURE add_event_queue_subscriber(
  subscriber_name    IN VARCHAR2 DEFAULT NULL);

PROCEDURE remove_event_queue_subscriber(
  subscriber_name    IN VARCHAR2 DEFAULT NULL);

-- The following procedure purges from the logs based on the arguments
-- The default is to purge all entries
PROCEDURE purge_log(
  log_history        IN PLS_INTEGER DEFAULT 0,
  which_log          IN VARCHAR2    DEFAULT 'JOB_AND_WINDOW_LOG',
  job_name           IN VARCHAR2    DEFAULT NULL);


/*************************************************************
 * Auxiliary Functions and Procedures
 *************************************************************
 */

-- This function returns a unique name for a job.
-- If prefix is NULL this will be a number from a sequence, otherwise
-- it will be of the form {prefix}N where N is a number from a sequence.
FUNCTION generate_job_name(
  prefix            IN VARCHAR2 DEFAULT 'JOB$_') RETURN VARCHAR2 ;

/*************************************************************
 * Internal Functions and Procedures
 *************************************************************
 */

-- These functions are for internal scheduler use. They are not intended to
-- be directly called by the user.

FUNCTION check_sys_privs RETURN PLS_INTEGER ;

FUNCTION get_varchar2_value (a SYS.ANYDATA) RETURN VARCHAR2;

-- The following procedure purges from the logs based on class and global
-- log_history
PROCEDURE auto_purge;

-- This accepts an attribute name and returns the default value.
-- If the attribute is not recognized it returns NULL.
-- If the attribute is of type BOOLEAN, it will return 'TRUE' or 'FALSE'.
FUNCTION get_default_value (attribute_name VARCHAR2) RETURN VARCHAR2 ;

-- this is used by chain views to output rule actions
FUNCTION get_chain_rule_action(action_in IN re$nv_list) RETURN VARCHAR2;

-- this is used by chain views to output rule conditions
FUNCTION get_chain_rule_condition(action_in IN re$nv_list, condition_in IN VARCHAR2)
  RETURN VARCHAR2;

-- this is used to retrieve the canonicalized object owner or name
FUNCTION resolve_name(
   full_name      IN VARCHAR2,
   default_owner  IN VARCHAR2,
   return_part    IN NUMBER) RETURN VARCHAR2;

-- this is the execution engine for remote external jobs. It checks all
-- required privileges. This can only be called from the job slave.
PROCEDURE submit_remote_external_job (
  job_name          IN VARCHAR2,
  job_subname       IN VARCHAR2,
  job_owner         IN VARCHAR2,
  command           IN VARCHAR2,
  arguments         IN ODCIVARCHAR2LIST,
  credential_name   IN VARCHAR2,
  credential_owner  IN VARCHAR2,
  destination       IN VARCHAR2,
  destination_owner IN VARCHAR2,
  destination_name  IN VARCHAR2,
  job_dest_id       IN VARCHAR2, 
  job_action        IN VARCHAR2,
  job_scheduled_start IN TIMESTAMP WITH TIME ZONE,
  job_start         IN TIMESTAMP WITH TIME ZONE,
  window_start      IN TIMESTAMP WITH TIME ZONE,
  window_end        IN TIMESTAMP WITH TIME ZONE,
  chainid           IN VARCHAR2,
  request_id        IN NUMBER,
  log_id            IN NUMBER);


/*************************************************************
 * Calendar utility functions for schedule type sched_calendar_string
 *************************************************************
 */

TYPE bylist IS VARRAY (256) OF PLS_INTEGER;

Yearly     Constant Pls_Integer := 1;
Monthly    Constant Pls_Integer := 2;
Weekly     Constant Pls_Integer := 3;
Daily      Constant Pls_Integer := 4;
Hourly     Constant Pls_Integer := 5;
Minutely   Constant Pls_Integer := 6;
Secondly   Constant Pls_Integer := 7;


Monday     Constant Integer := 1;
Tuesday    Constant Integer := 2;
Wednesday  Constant Integer := 3;
Thursday   Constant Integer := 4;
Friday     Constant Integer := 5;
Saturday   Constant Integer := 6;
Sunday     Constant Integer := 7;

-- byday_days contains list of days
-- byday_occurrence contains the corresponding monthly (or yearly)
--   occurrence -5 .. -1,0, 1 .. 5    // 0 meaning any this weekday

-- Example  BYDAY=-2MO, -1MO, 1MO, TU
-- byday_day = Monday,Monday,Monday,Tuesday
-- byday_orrurrence= -2,-1, 1, 0

Procedure create_calendar_string(
   frequency         in   pls_integer,
   interval          in   pls_integer,
   bysecond          in   bylist,
   byminute          in   bylist,
   byhour            in   bylist,
   byday_days        in   bylist,
   byday_occurrence  in   bylist,
   bymonthday        in   bylist,
   byyearday         in   bylist,
   byweekno          in   bylist,
   bymonth           in   bylist,
   calendar_string   out  Varchar2);
--
Procedure resolve_calendar_string(
   calendar_string   in   varchar2,
   frequency         out  pls_integer,
   interval          out  pls_integer,
   calendars_used    out  boolean,
   bysecond          out  scheduler$_int_array_type,
   byminute          out  scheduler$_int_array_type,
   byhour            out  scheduler$_int_array_type,
   byday_days        out  scheduler$_int_array_type,
   byday_occurrence  out  scheduler$_int_array_type,
   bydate_y          out  scheduler$_int_array_type,
   bydate_md         out  scheduler$_int_array_type,
   bymonthday        out  scheduler$_int_array_type,
   byyearday         out  scheduler$_int_array_type,
   byweekno          out  scheduler$_int_array_type,
   bymonth           out  scheduler$_int_array_type,
   bysetpos          out  scheduler$_int_array_type);


Procedure resolve_calendar_string(
   calendar_string   in   varchar2,
   frequency         out  pls_integer,
   interval          out  pls_integer,
   bysecond          out  bylist,
   byminute          out  bylist,
   byhour            out  bylist,
   byday_days        out  bylist,
   byday_occurrence  out  bylist,
   bymonthday        out  bylist,
   byyearday         out  bylist,
   byweekno          out  bylist,
   bymonth           out  bylist);

-- Repeat intervals of jobs, windows or schedules are defined using the
-- scheduler's calendar syntax. This procedure evaluates the calendar string
-- and tells you what the next execution date of a job or window will be. This
-- is very useful for testing the correct definition of the calendar string
-- without having to actually schedule the job or window.
--
-- Parameters
-- calendar_string    The to be evaluated calendar string.
-- start_date         The date by which the calendar string becomes valid.
--                    It might also be used to fill in specific items that are
--                    missing from the calendar string. Can optionally be NULL.
-- return_date_after  With the start_date and the calendar string the scheduler
--                    has sufficient information to determine all valid 
--                    execution dates. By setting this argument the scheduler 
--                    determines which one of all possible matches to return.
--                    When a NULL value is passed for this argument the 
--                    scheduler automatically fills in systimestamp as its 
--                    value.
-- next_run_date      The first timestamp that matches the calendar string and
--                    start date that occurs after the value passed in for the
--                    return_date_after argument.



-- This procedure can also be used to get multiple steps of the repeat interval
-- by passing the next_run_date returned by one invocation as the
-- return_date_after argument of the next invocation of this procedure.

Procedure evaluate_calendar_string(
   calendar_string    in  varchar2,
   start_date         in  timestamp with time zone,
   return_date_after  in  timestamp with time zone,
   next_run_date      OUT timestamp with time zone);

-- Set the remote execution agent registration password for this database
-- optionally limit the password to a limited number of uses or to before a
-- specified expiry date
PROCEDURE set_agent_registration_pass(
   registration_password   IN VARCHAR2,
   expiration_date         IN TIMESTAMP WITH TIME ZONE DEFAULT NULL,
   max_uses                IN PLS_INTEGER DEFAULT NULL);

-- Internal function. Do not document
FUNCTION is_scheduler_created_agent(
   schema_name                 VARCHAR2,
   agent_name                  VARCHAR2) RETURN BOOLEAN;

-- Internal function. Do not document.
FUNCTION get_job_step_cf
(
   iec                         VARCHAR2,
   icn                         VARCHAR2,
   vname                       VARCHAR2,
   iev                         SYS.RE$NV_LIST
) RETURN SYS.RE$VARIABLE_VALUE;

FUNCTION generate_event_list(statusvec NUMBER) return VARCHAR2;

-- ###################################################################
-- ###################################################################
--                           NEW BATCH API
-- ###################################################################
-- ###################################################################

-- In the following routines the argument 'semantics' can have one of
-- the values 'STOP_ON_FIRST_ERROR', 'TRANSACTIONAL', 'ABSORB_ERRORS'.
-- If the value is 'STOP_ON_FIRST_ERROR', the routine will return on
-- the first error but the previous successful operations will be
-- comitted to disk. If the value is 'TRANSACTIONAL', it will return
-- on the first error and the previous successful operations will be
-- rolled back. If the value is 'ABSORB_ERRORS' then even if errors
-- occur, the routine will proceed with until either all jobs in the
-- array have been handled or a "fatal" error occurs. The successful 
-- operations will be comitted to disk. The exact errors for each of 
-- the failed jobs will be stored in UGA memory - calling the 
-- show_errors routine will retrieve them.

-- Batch create job
PROCEDURE create_jobs(
  jobdef_array     IN     SYS.JOB_DEFINITION_ARRAY, 
  commit_semantics IN     VARCHAR2 DEFAULT 'STOP_ON_FIRST_ERROR');

PROCEDURE create_jobs(
  job_array        IN     SYS.JOB_ARRAY, 
  commit_semantics IN     VARCHAR2 DEFAULT 'STOP_ON_FIRST_ERROR');

-- Batch set job attribute
PROCEDURE set_job_attributes(
  jobattr_array    IN     SYS.JOBATTR_ARRAY,
  commit_semantics IN     VARCHAR2 DEFAULT 'STOP_ON_FIRST_ERROR');

-- Batch show errors
PROCEDURE show_errors(
  error_list       OUT    SYS.SCHEDULER$_BATCHERR_ARRAY);

PROCEDURE end_detached_job_run (
  job_name        IN VARCHAR2,
  error_number    IN PLS_INTEGER DEFAULT 0,
  additional_info IN VARCHAR2 DEFAULT NULL);

FUNCTION file_watch_filter(
  sch_name        IN VARCHAR2,
  obj_name        IN VARCHAR2,
  obj_subname     IN VARCHAR2,
  fw_msgid        IN RAW) RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(file_watch_filter, WNDS, WNPS);

  
END dbms_scheduler;
/

show errors;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_scheduler FOR dbms_scheduler
/

GRANT EXECUTE ON dbms_scheduler TO PUBLIC
/
