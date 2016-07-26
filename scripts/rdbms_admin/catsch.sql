Rem
Rem $Header: rdbms/admin/catsch.sql /st_rdbms_11.2.0/1 2010/11/10 18:11:29 rramkiss Exp $
Rem
Rem catsch.sql
Rem
Rem Copyright (c) 2002, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catsch.sql - Create tables and catalog views for the job scheduler
Rem
Rem    DESCRIPTION
Rem
Rem
Rem    NOTES
Rem This script must be run while connected as SYS or INTERNAL.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rramkiss    11/08/10 - Backport rramkiss_bug-10166489 from main
Rem    rramkiss    09/04/09 - add variable value type for internal use only
Rem    evoss       02/19/09 - add agtdest_id to destinations table
Rem    rramkiss    02/17/09 - update for external dests
Rem    rgmani      01/28/09 - Add lw job columns
Rem    rramkiss    02/04/09 - add run_invoker field for data vault
Rem    rgmani      05/21/08 - 
Rem    rramkiss    04/04/08 - update event_info object with subname and class
Rem    rgmani      03/10/08 - 
Rem    rramkiss    03/05/08 - add e-mail notification base table
Rem    rgmani      02/15/08 - File watching
Rem    evoss       05/15/08 - 6978599 and 6133709 add index on
Rem                           scheduler_run_details.log_id
Rem    rgmani      12/14/07 - Change attribute names for JOB type
Rem    rramkiss    03/06/07 - lrg-2882492, rebuild indexes on timezone cols
Rem    rgmani      10/03/06 - 
Rem    rramkiss    10/16/06 - update for remote chain steps
Rem    rburns      07/31/06 - restructure
Rem    nbhatt      07/11/06 - 
Rem    rgmani      07/09/06 - AQ enhancements 
Rem    rgmani      07/06/06 - 
Rem    samepate    03/16/06 - add instance_id,defer drop,dbms_job$ job class
Rem    rgmani      06/01/06 - Remote database jobs
Rem    sschodav    06/25/06 - add owner udn field to scheduler$_job 
Rem    rgmani      06/15/06 - Fix unique constraint violation LRG 
Rem    rmacnico    06/07/06 - Add dba_scheduler_job_roles view
Rem    rramkiss    04/17/06 - add credential attribute to jobs 
Rem    rramkiss    03/20/06 - add base tables and views for credentials
Rem    rgmani      01/19/06 - Add batch API 
Rem    rmacnico    05/15/06 - allow scheduler to run on standby servers
Rem    sschodav    03/01/06 - bug4904904 , new metadata arg 
Rem                           job_scheduled_start 
Rem    samepate    10/25/05 - bug #4486890
Rem    samepate    06/30/05 - remove old obsolete queue code
Rem    rramkiss    05/24/05 - expose DETACHED attribute 
Rem    rramkiss    05/12/05 - update running_chains views 
Rem    evoss       05/09/05 - remove calendar column 
Rem    rramkiss    04/19/05 - add missing entry in views 
Rem    rramkiss    03/15/05 - add RESTART_ON_RECOVERY chain step flag 
Rem    rramkiss    03/07/05 - add CHAIN_STALLED job state 
Rem    samepate    02/02/05 - add NEXT_START_DATE to window_group views
Rem    samepate    01/06/05 - bug #3838374 
Rem    evoss       01/07/05 - make resolve calendar usable from odbc 
Rem    rramkiss    12/20/04 - updatre chain rule views for new syntax 
Rem    rramkiss    11/04/04 - bug #3987649 - fix 
Rem                           all_scheduler_job_log/job_run_details 
Rem    evoss       10/26/04 - #3971324: fix reporting of cpu used 
Rem    rramkiss    10/20/04 - bug #3953140 - asynch run jobs have no status 
Rem    rramkiss    09/24/04 - show state of subchain steps even after the 
Rem                           subchain is complete 
Rem    rramkiss    04/21/04 - grant CREATE EXTERNAL JOB to SCHEDULER_ADMIN 
Rem    rgmani      09/24/04 - Add new fields to global attribute 
Rem    rgmani      09/02/04 - grabtrans 'evoss_bug-3484069' 
Rem    evoss       08/30/04 - add STOPPED status 
Rem    rramkiss    08/24/04 - add log_id to chain step_state table 
Rem    rgmani      08/25/04 - Fix running jobs view definition 
Rem    evoss       08/11/04 - set scheduler default timezone from system env 
Rem    rramkiss    07/22/04 - *_SCHEDULER_RUNNING_JOBS should show running 
Rem                           chains 
Rem    rgmani      07/19/04 - Fix enabled column defn in *_scheduler_jobs 
Rem    evoss       07/06/04 - make calendar resolve types global 
Rem    rramkiss    06/23/04 - update *running_chains views 
Rem    rramkiss    06/14/04 - OEM bug, add step_type to *_CHAIN_STEP views 
Rem    rgmani      05/13/04 - Notify for queue subscribe/unsubscribe 
Rem    rgmani      05/12/04 - Add event-related global attributes 
Rem    rgmani      05/05/04 - Create sequence for generating rule names 
Rem    rgmani      05/04/04 - Fix errors 
Rem    rgmani      04/27/04 - Event based scheduling 
Rem    evoss       05/14/04 - add calendar column to schedule views 
Rem    rramkiss    04/07/04 - remove job_step (merge into job_step_state)
Rem    rramkiss    04/07/04 - don't need duration in step_state base table 
Rem    rramkiss    04/06/04 - updates names, new columns 
Rem    rramkiss    03/25/04 - views for running job chain steps 
Rem    rramkiss    03/25/04 - update job_step_state format 
Rem    rramkiss    03/16/04 - job step state views and updates to table 
Rem    rramkiss    03/12/04 - job_chain->chain 
Rem    rramkiss    03/08/04 - all_* and user_* chain views 
Rem    rramkiss    03/08/04 - chains views 
Rem    evoss       12/16/03 - add session serial number to scheduler running 
Rem                           jobs view 
Rem    evoss       11/17/03 - add default_timezone, follow_default_timezone 
Rem    rramkiss    12/04/03 - fix last_start_date in windows views 
Rem    rramkiss    09/23/03 - bug #3154787 
Rem    rgmani      09/08/03 - 
Rem    rramkiss    08/30/03 - restore job table 
Rem    rramkiss    08/04/03 - enable created indexes (bug #3078899) 
Rem    rramkiss    08/13/03 - SUCCESS->SUCCEEDED
Rem    rramkiss    06/26/03 - add sequence for job_name suffixes
Rem    rgmani      07/03/03 - Move current open window to end
Rem    rramkiss    06/30/03 - trap already_exists error
Rem    rramkiss    07/08/03 - trivial view tweaks
Rem    rramkiss    06/16/03 - flag default job class as SYSTEM
Rem    rramkiss    05/29/03 - do not replace type sys.scheduler$_job_external
Rem    rramkiss    05/08/03 - remote jobs are enabled by definition
Rem    rramkiss    04/10/03 - remove distributed scheduling setup stuff
Rem    rramkiss    03/24/03 - add new subscriber for incoming external jobs
Rem    rramkiss    03/24/03 - add job status accessor fn to job_fixed type
Rem    rramkiss    03/19/03 - add new REMOTE job state
Rem    rramkiss    03/06/03 - alter external job type
Rem    rramkiss    02/18/03 - add external job type
Rem    rramkiss    02/04/03 - add destination accessor method to _job_fixed
Rem    rramkiss    02/03/03 - add source and destination job fields
Rem    rramkiss    06/10/03 - grabtrans 'rramkiss_bug-2996860'
Rem    rramkiss    06/03/03 - remove comments for max_run_dur
Rem    rramkiss    06/03/03 - add new 'RETRY SCHEDULED' status
Rem    rramkiss    06/03/03 - Expose retries in job views
Rem    rramkiss    06/09/03 - mask already_exists error
Rem    rramkiss    06/09/03 - update comments for running_jobs
Rem    rgmani      06/10/03 - Add global parameters view
Rem    srajagop    06/10/03 - purging log
Rem    rramkiss    05/08/03 - comments for new system flag
Rem    rramkiss    05/07/03 - add SYSTEM flag to jobs views
Rem    rramkiss    04/22/03 - don't show SYS objects to non-SYS users w/out object privs
Rem    rgmani      05/20/03 - Modify global sttrib table
Rem    srajagop    03/20/03 - make additional info a clob
Rem    rramkiss    04/09/03 - bug #2875611-all_job_log not showing dropped jobs
Rem    rramkiss    03/31/03 - bug #2869920 - mask "already exists" errors
Rem    rgmani      04/03/03 - Add parameters table
Rem    rramkiss    02/21/03 - all all_scheduler_ views should be views
Rem    rramkiss    02/17/03 - stop_on_window_exit=>stop_on_window_close
Rem    raavudai    03/12/03 - add order clause to scheduler$_instance_s
Rem    rramkiss    02/18/03 - service colmn for classes should be 64 chars long
Rem    rgmani      02/26/03 - Add new window fields
Rem    rramkiss    02/10/03 - update argument types
Rem    srajagop    02/07/03 - add actual_start_date to win
Rem    srajagop    01/31/03 - add comments to logging views
Rem    rramkiss    02/14/03 - expose job flags field in views
Rem    rramkiss    01/23/03 - persistent=>auto_drop
Rem    srajagop    01/15/03 - add clientid and guid to job views
Rem    evoss       01/16/03 - add scheduler_running_jobs
Rem    srajagop    01/17/03 - make type number in evtlog
Rem    rramkiss    01/09/03 - JS_COORDINATOR => SCHEDULER_COORDINATOR
Rem    rramkiss    01/07/03 - Remove instance-specific cols from job views
Rem    rramkiss    12/19/02 - View tweaks
Rem    rramkiss    12/17/02 - Change schedule_limit and duration to intervals
Rem    srajagop    01/03/03 - add nls env to job view
Rem    rramkiss    01/13/03 - DEFAULT_CLASS => DEFAULT_JOB_CLASS
Rem    srajagop    01/06/03 - job logging update
Rem    rramkiss    12/04/02 - API tweaks
Rem    rgmani      12/19/02 - Use cscn/dscn for job mutable data
Rem    rgmani      12/13/02 - Add ODCI Describe and Prepare functions
Rem    rramkiss    11/21/02 - window creator should be varchar2
Rem    rramkiss    11/20/02 - Move job and window log tables to sysaux tblspace
Rem    rramkiss    11/20/02 - Update log tables to store names instead of ids
Rem    rramkiss    12/02/02 - update job views to show new statuses
Rem    rramkiss    11/26/02 - Add window creator to views
Rem    rramkiss    11/18/02 - Add ALL_SCHEDULER_* views
Rem    rramkiss    11/18/02 - update job views to show schedule_type now
Rem    rramkiss    11/15/02 - Add persistent flag to job views
Rem    srajagop    11/26/02 - new fields for job q for nls
Rem    rramkiss    11/11/02 - Add new creator field to job_t
Rem    rramkiss    11/05/02 - grant execute on default_class to public
Rem    evoss       11/13/02 - rename simple schedule to calendar string
Rem    rramkiss    10/23/02 - create scheduler_admin role and grant it to dba
Rem    rgmani      10/18/02 - Fix typo
Rem    rgmani      10/18/02 - Add sequence and table for old oids
Rem    rramkiss    10/15/02 - Register export pkg for schedule objects
Rem    rramkiss    10/08/02 - Add tables and views for new schedule object
Rem    rramkiss    09/24/02 - Register procedural objects for export
Rem    rgmani      10/14/02 - Add functional index on job queue table
Rem    rramkiss    09/17/02 - Fixes for argument views
Rem    rramkiss    09/05/02 - Add window groups tables and views
Rem    srajagop    08/30/02 - add failed next time computation to job log
Rem    rramkiss    08/21/02 - dbms_scheduler_admin=>dbms_scheduler.create_class
Rem    rramkiss    08/13/02 - Add missing start_date for windows view
Rem    rgmani      08/12/02 - Add job object type
Rem    rgmani      08/01/02 - Add user callback columns to job table
Rem    rramkiss    07/26/02 - Add missing fields to job views
Rem    srajagop    07/23/02 - srajagop_scheduler_1
Rem    srajagop    07/21/02 - add job, window logs
Rem    rramkiss    07/18/02 - Add schedule_type of once to job views
Rem    rramkiss    07/17/02 - Add program/job argument views
Rem    rramkiss    07/17/02 - Add windows/classes views. Remove priority_list
Rem    rramkiss    07/16/02 - Add views for programs and jobs
Rem    rgmani      07/16/02 - Add columns to scheduler job table
Rem    rramkiss    07/10/02 - Remove default_exists col from program_arg table
Rem    rramkiss    07/10/02 - Update argument table field names
Rem    rramkiss    07/09/02 - Add creation of DEFAULT_CLASS
Rem    rramkiss    07/02/02 - Update $_window fields
Rem    rramkiss    06/26/02 - Add prvthsch and prvtbsch package scripts
Rem    rramkiss    06/25/02 - Add program_action field to scheduler$_job
Rem    rramkiss    05/23/02 - Change timestamp to timestamp_with_time_zone
Rem    rramkiss    04/11/02 - Created
Rem

CREATE TABLE sys.scheduler$_program
(
  obj#            number              NOT NULL         /* program identifier */
                  CONSTRAINT scheduler$_program_pk PRIMARY KEY,
  action          varchar2(4000),               /* filename/subprogram/block */
  number_of_args  number,     /* number of arguments required by the program */
  comments        varchar2(240),                        /* program comments */
  flags           number,                         /* includes execution type */
  schedule_limit  interval day(3) to second (0),  /* interval after which the 
                                                     job must be rescheduled */
  priority        number,                      /* requested program priority */
  job_weight      number,            /* weight of job */
  max_runs        number,            /* Maximum number of runs after which job 
                                        will be disabled */
  max_failures    number,          /* Maximum number of times a job can fail 
                                         before it is automatically disabled */
  max_run_duration interval day(3) to second(0), /* reserved for future use */
  nls_env           varchar2(4000),           /* NLS environment of this job */ 
  env               raw(32),                         /* Misc env of this job */
  run_count       number                              /* number of times run */
)
/

CREATE TABLE sys.scheduler$_class
(
  obj#             number             NOT NULL          /* class identifier */
                   CONSTRAINT scheduler$_class_pk PRIMARY KEY,
  res_grp_name     varchar2(30),             /* name of assoc resource group */
  default_priority number,          /* The default priority for the class in 
                                             any window that does not have a
                                            priority plan associated with it */
  affinity         varchar2(64),     /* name of the affined service/instance */
  log_history      number,   /* The number of days worth of logs to preserve */
  flags            number,     /* includes purge policy, stop on window exit */
  comments         varchar2(240)                          /* class comments */
)
/

CREATE TABLE sys.scheduler$_job
(
  /* Fixed fields */
  obj#            number              NOT NULL             /* job identifier */
                  CONSTRAINT scheduler$_job_pk PRIMARY KEY,
  program_oid     number,                              /* program identifier */
  program_action  varchar2(4000),                          /* program action */
  schedule_expr   varchar2(4000),          /* string specifying the schedule */
  queue_owner     varchar2(30),               /* Owner of event source queue */
  queue_name      varchar2(30),                    /* Source queue for event */
  queue_agent     varchar2(256),       /* For secure queues - agent used for 
                                                subscription to source queue */
  event_rule      varchar2(65),            /* Rule name associated with this 
                                              job (if event based else NULL) */
  schedule_limit  interval day(3) to second (0),  /* interval after which the 
                                                     job must be rescheduled */
  schedule_id     number,            /* object ID representing the schedule
                                        this can be a window, a window group or
                                        a named schedule */
  start_date      timestamp with time zone,    /* the date on which this job
                                                                     started */
  end_date        timestamp with time zone, /* the date after which this job
                                                             will not be run */
  last_enabled_time timestamp with time zone,   /* time job was last enabled */
  class_oid       number,          /* identifier of associated class, if any */
  priority        number,                      /* requested program priority */
  job_weight      number,            /* weight of job */
  number_of_args  number,                  /* Number of times to retry a job 
                                                            before giving up */
  max_runs        number,            /* Maximum number of runs after which job 
                                        will be disabled */
  max_failures    number,          /* Maximum number of times a job can fail 
                                         before it is automatically disabled */
  max_run_duration interval day(3) to second(0), /* reserved for future use */
  mxdur_msgid     raw(16),          /* Message ID of max run duration event */
  flags           number,    /* state code, execution/schedule type, output? */
  comments        varchar2(240),                            /* job comments */
  user_callback    varchar2(92),                   /* User callback routine */
  user_callback_ctx number,  /* Context in which callback should be invoked */
  creator           varchar2(30),           /* original creator of this job */
  client_id         varchar2(64),                   /* clientid of this job */
  guid              varchar2(32),                       /* GUID of this job */
  nls_env           varchar2(4000),           /* NLS environment of this job */
  env               raw(32),                         /* Misc env of this job */
  char_env          varchar2(4000),               /* Used for Trusted Oracle */
  source            varchar2(128),                  /* source global DB name */
  dest_oid          number,                               /* Destination oid */
  destination       varchar2(128),             /* destination global DB name */
  database_role     varchar2(16),     /* identify standby jobs, null=primary 
                                             else {primary, logical standby} */
  instance_id       number,          /* instance user requests job to run on */
  credential_name   varchar2(30),                         /* credential name */
  credential_owner  varchar2(30),                        /* credential owner */
  credential_oid    number,                          /* credential object ID */
  owner_udn         varchar2(4000),               /* owner's udn infromation */
  fw_name           varchar2(65),                       /* File watcher name */
  fw_oid            number,                /* File watcher ID, if applicable */
  /* Mutable fields */
  job_status      number,                 /* Job status running/disabled etc */
  next_run_date   timestamp with time zone,/* next date this job will run on */
  last_start_date timestamp with time zone,/* last date on which the job was
                                                                     started */
  last_end_date   timestamp with time zone,   /* last date on which this job
                                                                   completed */
  retry_count     number,            /* Current number of unsuccessful 
                                        retries of this job */
  run_count       number,                             /* number of times run */
  failure_count   number,                          /* number of times failed */
  running_instance number,              /* Instance on which job is running */
  running_slave    number,          /* Slave ID of slave that is running job */
  dist_flags      number,    /* Flags needed for remote database job feature */
  job_dest_id    number,
  run_invoker    number                  /* this is the invoker of a run_job */
)
/
CREATE INDEX sys.i_scheduler_job1
  ON sys.scheduler$_job (next_run_date)
/
CREATE INDEX sys.i_scheduler_job2
  ON sys.scheduler$_job (class_oid)
/
CREATE INDEX sys.i_scheduler_job3
  ON sys.scheduler$_job (schedule_id)
/
CREATE INDEX sys.i_scheduler_job4
  ON sys.scheduler$_job (bitand(job_status, 515))
/

CREATE SEQUENCE sys.scheduler$_lwjob_oid_seq nocache
/

-- An index on a timezone col is internally a functional index using
-- sys_extract_utc. Rebuild it in case it has changed
alter index sys.i_scheduler_job1 rebuild;

CREATE TABLE sys.scheduler$_saved_oids
(
  oididx          number NOT NULL
    CONSTRAINT scheduler$_soid_pk PRIMARY KEY,
  savedoid        number NOT NULL
)
/

begin
  INSERT INTO sys.scheduler$_saved_oids VALUES (0, 0);
exception
  when others then 
    if sqlcode = -1 then null;
    else raise;
    end if;
end;
/

commit;

CREATE TABLE sys.scheduler$_lwjob_obj
(
  obj#            number NOT NULL
    CONSTRAINT scheduler$_lobj_pk PRIMARY KEY,
  userid          number NOT NULL,
  name            VARCHAR2(30) NOT NULL,
  subname         VARCHAR2(30),
    CONSTRAINT scheduler$_lobj_uk UNIQUE (userid, name, subname),
  prgoid          NUMBER NOT NULL,
  creation_time   DATE NOT NULL,
  mod_time        DATE NOT NULL,
  spec_time       DATE NOT NULL,
  flags           NUMBER
)
/ 

CREATE TABLE sys.scheduler$_lightweight_job
(
  obj#            number              NOT NULL             /* job identifier */
                  CONSTRAINT scheduler$_lwjob_pk PRIMARY KEY,
  program_oid     number,                              /* program identifier */
  start_date      timestamp with time zone,    /* the date on which this job
                                                                     started */
  end_date        timestamp with time zone, /* the date after which this job
                                                             will not be run */
  schedule_expr   varchar2(4000),          /* string specifying the schedule */
  queue_owner     varchar2(30),               /* Owner of event source queue */
  queue_name      varchar2(30),                    /* Source queue for event */
  queue_agent     varchar2(256),       /* For secure queues - agent used for 
                                                subscription to source queue */
  event_rule      varchar2(65),            /* Rule name associated with this 
                                              job (if event based else NULL) */
  schedule_id     number,            /* object ID representing the schedule
                                        this can be a window, a window group or
                                        a named schedule */
  last_enabled_time timestamp with time zone,   /* time job was last enabled */
  class_oid       number,          /* identifier of associated class, if any */
  mxdur_msgid     raw(16),          /* Message ID of max run duration event */
  flags           number,    /* state code, execution/schedule type, output? */
  creator           varchar2(30),           /* original creator of this job */
  client_id         varchar2(64),                   /* clientid of this job */
  guid              varchar2(32),                       /* GUID of this job */
  char_env          varchar2(4000),               /* Used for Trusted Oracle */
  fw_name           varchar2(65),                      /* File watcher owner */
  fw_oid            number,                /* File watcher ID, if applicable */
  job_status      number,                 /* Job status running/disabled etc */
  next_run_date   timestamp with time zone,/* next date this job will run on */
  last_start_date timestamp with time zone,/* last date on which the job was
                                                                     started */
  last_end_date   timestamp with time zone,   /* last date on which this job
                                                                   completed */
  retry_count     number,            /* Current number of unsuccessful 
                                        retries of this job */
  run_count       number,                             /* number of times run */
  failure_count   number,                          /* number of times failed */
  running_instance number,              /* Instance on which job is running */
  running_slave    number,          /* Slave ID of slave that is running job */
  instance_id       number,          /* instance user requests job to run on */
  dest_oid          number,                               /* destination oid */
  destination       varchar2(128),                    /* Name of destination */
  credential_name   varchar2(30),                         /* credential name */
  credential_owner  varchar2(30),                        /* credential owner */
  credential_oid    number,                          /* credential object ID */
  job_dest_id       number,
  run_invoker       number               /* this is the invoker of a run_job */
)
/

CREATE TABLE sys.scheduler$_job_argument
(
  oid             number              NOT NULL,            /* job identifier */
  name            varchar2(30),                             /* argument name */
  position        number              NOT NULL,   /* posn of arg in arg list */
                  CONSTRAINT scheduler$_job_arg_pk
                    PRIMARY KEY (oid, position) ,
  type_number     number,                          /* type of value expected */
  user_type_num   number,           /* for a user type, the user type number */
  value           sys.anydata,                             /* assigned value */
  flags           number                                      /* flags field */
)
/
CREATE INDEX sys.i_scheduler_job_argument1
  ON sys.scheduler$_job_argument (oid)
/

CREATE TABLE sys.scheduler$_window
(
  obj#            number              NOT NULL          /* window identifier */
                  CONSTRAINT scheduler$_window_pk PRIMARY KEY,
  res_plan        varchar2(30),                 /* ID of assoc resource plan */
  next_start_date timestamp with time zone,     /* next scheduled start date
                                                               of the window */
  manual_open_time timestamp with time zone,    /* Time when manually opened */
  duration        interval day(3) to second(0),    /* duration of the window */
  manual_duration interval day(3) to second(0),   /* duration of manual open */
  schedule_expr   varchar2(4000),              /* inline schedule expression */
  start_date      timestamp with time zone,   /* Date when this window first
                                                                     started */
  end_date        timestamp with time zone,  /* Date after which this window
                                                             will be invalid */
  last_start_date timestamp with time zone, /* Date this window last started
                                                                          on */
  actual_start_date timestamp with time zone, /* Date this window actually 
                                                                  started on */
  scaling_factor  number,            /* The scaling factor to use to determine
                                        the throughput target of the scheduler.
                                        By default it is three times number of
                                        CPUs */
  creator              varchar2(30),/* logged-in user who created the window */
  unused_slave_policy  number,    /* Policy of what to do with unused slaves */
  min_slave_percent    number,           /* Valid for only certain policies,
                                         minimum percentage of typical slave
                                          allocation guaranteed to any class */
  max_slave_percent    number,          /* The maximum percentage of typical
                                          slave allocation that can be given
                                                                to any class */
  schedule_id     number,            /* object ID representing the schedule
                                        this can be a window, a window group or
                                        a named schedule */
  flags                number,  /* includes enabled?, logging, schedule type */
  max_conc_jobs        number,    /* maximum concurrent jobs for this window */
  priority             number,                    /* priority of this window */
  comments             varchar2(240)                     /* window comments */
)
/
CREATE INDEX sys.i_scheduler_window1
  ON sys.scheduler$_window (next_start_date)
/

-- An index on a timezone col is internally a functional index using
-- sys_extract_utc. Rebuild it in case it has changed
alter index sys.i_scheduler_window1 rebuild;

CREATE TABLE sys.scheduler$_program_argument
(
  oid             number              NOT NULL,        /* program identifier */
  name            varchar2(30),                             /* argument name */
  position        number              NOT NULL,   /* posn of arg in arg list */
                  CONSTRAINT scheduler$_program_arg_pk 
                    PRIMARY KEY (oid, position) ,
  type_number     number,                          /* type of value expected */
  user_type_num   number,           /* for a user type, the user type number */
  value           sys.anydata,                      /* default value, if any */
  flags           number                                      /* flags field */
)
/
REM We can`t create unique index because name can be NULL, however uniqueness
REM of a name which is not NULL should be enforced by the API
CREATE INDEX sys.i_scheduler_program_argument1
  ON sys.scheduler$_program_argument (oid, name)
/

CREATE TABLE sys.scheduler$_srcq_info
(
  obj#            number              NOT NULL
                  CONSTRAINT scheduler$_qinfo_pk PRIMARY KEY,
  ruleset_name    varchar2(30),
  rule_count      number,
  flags           number
)
/

CREATE TABLE sys.scheduler$_srcq_map
(
  oid            number               NOT NULL,
  rule_name      VARCHAR2(256)        NOT NULL,
                  CONSTRAINT scheduler$_srcq_map_pk 
                    PRIMARY KEY (oid, rule_name) ,
  joboid         number               NOT NULL,
  flags          number
)
/

CREATE TABLE sys.scheduler$_evtq_sub
(
  agt_name       VARCHAR2(30)         NOT NULL
                 CONSTRAINT scheduler$_evtq_sub_pk PRIMARY KEY,
  uname          VARCHAR2(30)         NOT NULL
)
/

CREATE SEQUENCE sys.scheduler$_instance_s
/

-- log_id is a candidate key on each server: standby event logs contain
-- events from more than one server i.e. primary and standby,
-- so the combination of log_id and dbid is unique
create table scheduler$_event_log
(
 log_id   number NOT NULL,                   /* assigned job instance ID */
 log_date timestamp with time zone,  /* The timestamp of the operation */
 type#      number,             /* Type of object for this entry is made */
 name       varchar2(65),                      /* The name of the object */
 owner      varchar2(30),                    /* The schema of the object */
 class_id   number,  /* id of the class the job belonged to at time of entry */
 operation  varchar2(30),                  /* The kind of operation done */
 status     varchar2(30),                        /* success/failure, etc */
 user_name        varchar2(30),                 /* Who performed the operation */
 client_id  varchar2(64),                 /* The client_id of the object */
 guid       varchar2(32),                      /* The guid of the object */
 dbid       number,           /* null or remote dbid for logical standby */
 flags      number,                                       /* Flags field */
 credential  varchar2(65),                       /* Full credential name */
 destination varchar2(128),                           /* job destination */
 additional_info clob,                 /* add. info. in name value pairs */
 CONSTRAINT scheduler$_instance_pk UNIQUE (log_id, dbid)
            USING INDEX TABLESPACE sysaux
) TABLESPACE sysaux;

create table scheduler$_job_run_details
(
  log_id       number, 
  log_date     timestamp with time zone, /* The timestamp of the operation */
  req_start_date  timestamp with time zone,      /* Requested start date */
  start_date      timestamp with time zone,         /* Actual start date */
  run_duration    interval day(3) to second(0),         /* Run duration */
  instance_id     number,              /* Instance on which the job ran */
  session_id      varchar2(30),  /* ID of the session this job ran with */
  slave_pid       varchar2(30), /* process ID of the slave this job ran with */
                                        /* amount of cpu used for this job */
  cpu_used        interval day(3) to second(2),
  error#          number,              /* The error returned for this run */
  additional_info   varchar2(4000),     /* add. info. in name value pairs */
  credential  varchar2(65),                       /* Full credential name */
  destination     varchar2(128)           /* destination at which job ran */
) TABLESPACE sysaux;

CREATE INDEX sys.i_scheduler_job_run_details
  ON sys.scheduler$_job_run_details (log_id)
  TABLESPACE sysaux
/

create table scheduler$_window_details
(
  log_id     number, 
  log_date   timestamp with time zone, /* The timestamp of the operation */
  instance_id    number,                 /* The instance this window ran on */
  req_start_date  timestamp with time zone,    /* The requested start date */
  start_date   timestamp with time zone,         /* Actual start of window */
  duration     interval day(3) to second(0), /* The duration of the window */
  actual_duration interval day(3) to second(0),    /* The actual duration */
  additional_info  varchar2(4000)       /* add. info. in name value pairs */
) TABLESPACE sysaux;

CREATE INDEX sys.i_scheduler_window_details
  ON sys.scheduler$_window_details (log_id)
  TABLESPACE sysaux
/


CREATE TABLE sys.scheduler$_window_group
(
  obj#             number             NOT NULL    /* window group identifier */
                   CONSTRAINT scheduler$_window_group_pk PRIMARY KEY,
  comments         varchar2(240),                        /* optional comment */
  flags            number                          /* includes enabled flag */
)
/

CREATE TABLE sys.scheduler$_wingrp_member
(
  oid             number              NOT NULL,   /* window group identifier */
  member_oid      number              NOT NULL,            /* job identifier */
  member_oid2     number,                             
                  CONSTRAINT scheduler$_wingrp_member_uq
                    UNIQUE (oid, member_oid, member_oid2)
)
/
CREATE INDEX sys.i_scheduler_wingrp_member1
  ON sys.scheduler$_wingrp_member (oid)
/
CREATE INDEX sys.i_scheduler_wingrp_member2
  ON sys.scheduler$_wingrp_member (member_oid)
/
CREATE INDEX sys.i_scheduler_wingrp_member3
  ON sys.scheduler$_wingrp_member (member_oid2)
/

CREATE TABLE sys.scheduler$_schedule
(
  obj#            number              NOT NULL        /* schedule identifier */
                  CONSTRAINT scheduler$_schedule_pk PRIMARY KEY,
  recurrence_expr varchar2(4000),          /* string specifying the schedule */
  queue_owner     varchar2(30),               /* Owner of event source queue */
  queue_name      varchar2(30),                /* Name of event source queue */
  queue_agent     varchar2(30),     /* For secure queues - AQ agent name for 
                                                                source queue */
  reference_date  timestamp with time zone,    /* reference date for special
                                                           recurrence syntax */
  end_date        timestamp with time zone,           /* the end cutoff date */
  comments        varchar2(240),                        /* schedule comments */
  flags           number,                                   /* schedule type */
  max_count       number,                   /* Maximum number of occurrences */
  fw_name         varchar2(65)                       /* Name of file watcher */
)
/

CREATE TABLE sys.scheduler$_chain
(
  obj#            number              NOT NULL   /* running chain identifier */
                  CONSTRAINT scheduler$_chain_pk PRIMARY KEY,
  rule_set        varchar2(30),            /* rule set assoc with this chain */
  rule_set_owner  varchar2(30),                    /* schema of the rule set */
  comments        varchar2(240),                        /* schedule comments */
  eval_interval   interval day(3) to second(0),    /* period of reevaluation */
  flags           number                                    /* schedule type */
)
/

CREATE TABLE sys.scheduler$_step
(
  oid             number              NOT NULL,  /* running chain identifier */
  var_name        varchar2(30)        NOT NULL,            /* job identifier */
  object_name     varchar2(98),
  timeout         interval day(3) to second(0),
  queue_owner     varchar2(30),               /* Owner of event source queue */
  queue_name      varchar2(30),                    /* Source queue for event */
  queue_agent     varchar2(30),        /* For secure queues - agent used for
                                                subscription to source queue */
  condition       varchar2(4000),           /* condition for an inline event */
  credential_owner varchar2(30),                         /* credential owner */
  credential_name  varchar2(30),                          /* credential name */
  destination      varchar2(128),
  flags           number              NOT NULL
)
/
CREATE INDEX sys.i_scheduler_step1
  ON sys.scheduler$_step (oid)
/
CREATE UNIQUE INDEX sys.i_scheduler_step2
  ON sys.scheduler$_step (oid, var_name)
/

CREATE TABLE sys.scheduler$_step_state
(
  job_oid         number        NOT NULL,
  step_name       varchar2(30)  NOT NULL,
                  CONSTRAINT scheduler$_step_state_pk PRIMARY KEY
                  (job_oid, step_name)  USING INDEX TABLESPACE sysaux,
  status          char,
  error_code      number,
  start_date      timestamp with time zone,    /* the date on which this job
                                                                step started */
  end_date        timestamp with time zone,    /* the date on which this job
                                                              step completed */
  job_step_oid    number,
  job_step_log_id number,                /* log id if the step has completed */
  destination     varchar2(128),             /* remote destination for step  */
  flags           number
) TABLESPACE sysaux
/

create or replace type sys.scheduler$_job_step_type as object (
   state           varchar2(12),
   error_code      number,
   completed       varchar2(5),
   start_date      timestamp with time zone,   /* the date on which this job
                                                                step started */
   end_date        timestamp with time zone,   /* the date on which this job
                                                              step completed */
   duration        interval day (3) to second(3)
)
/

-- the below types are used by dbms_scheduler.analyze_chain
CREATE TYPE sys.scheduler$_rule  IS OBJECT (
       rule_name         VARCHAR2(65),
       rule_condition    VARCHAR2(4000),
       rule_action       VARCHAR2(4000))
/
CREATE TYPE sys.scheduler$_rule_list IS
 TABLE OF sys.scheduler$_rule
/

create type sys.scheduler$_variable_value as object
(variable_name           varchar2(32),
 variable_data           sys.scheduler$_job_step_type)
/

create type sys.scheduler$_var_value_list is
  VARRAY(2147483647) of sys.scheduler$_variable_value;
/

-- step type is not interpreted (just output in the chain_link_list)
-- step types used by the scheduler are 'PROGRAM', 'EVENT', 'BEGIN', 'END'
-- steps of type 'BEGIN' and 'END' are not real steps
CREATE TYPE sys.scheduler$_step_type IS OBJECT (
       step_name    VARCHAR2(32),
       step_type    VARCHAR2(32))
/
CREATE TYPE sys.scheduler$_step_type_list IS
 TABLE OF sys.scheduler$_step_type
/

-- pseudo-steps of type 'BEGIN' will be named '"BEGIN"'
-- pseudo-steps of type 'END' will be named '"END"'
-- possible action types are 'START', 'STOP', 'END_SUCCESS', 'END_FAILURE',
-- 'END_STEP_ERROR_CODE'
CREATE TYPE sys.scheduler$_chain_link IS OBJECT (
       first_step_name    VARCHAR2(32),
       first_step_type    VARCHAR2(32),
       second_step_name   VARCHAR2(32),
       second_step_type   VARCHAR2(32),
       rule_name          VARCHAR2(32),
       rule_owner         VARCHAR2(32),
       action_type        VARCHAR2(32))
/
CREATE TYPE sys.scheduler$_chain_link_list IS
 TABLE OF sys.scheduler$_chain_link
/

GRANT EXECUTE ON sys.scheduler$_rule TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_rule_list TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_step_type TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_step_type_list TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_chain_link TO PUBLIC
/
GRANT EXECUTE ON sys.scheduler$_chain_link_list TO PUBLIC
/

CREATE TABLE sys.scheduler$_global_attribute
(
  obj#            number              NOT NULL              /* Attribute OID */
                  CONSTRAINT scheduler$_attrib_pk PRIMARY KEY,
  value           varchar2(128),                          /* Attribute value */
  flags           number,                                      /* Misc flags */
  modified_inst   number,               /* Instance that last modified param */
  additional_info varchar2(128),         /* Any other additional information */
  attr_tstamp     timestamp with time zone,             /* A timestamp field */
  attr_intv       interval day(3) to second(0)          /* An interval field */
)
/

-- credential base tables and types
CREATE TABLE sys.scheduler$_credential
(
  obj#            number           NOT NULL          /* credential object ID */
                  CONSTRAINT scheduler$_credential_pk PRIMARY KEY,
  username        varchar2(64)     NOT NULL,        /* operating system user */
  password        varchar2(255)    NOT NULL,                  /* OS password */
  domain          varchar2(30),                            /* Windows domain */
  comments        varchar2(240),                   /* user-provided comments */
  flags           number                           /* flags field (bitfield) */
)
/

CREATE TABLE sys.scheduler$_rjob_src_db_info
(
  joboid         number NOT NULL
                 CONSTRAINT scheduler$_rdbi_pk PRIMARY KEY,
  source_db      varchar2(512) NOT NULL,
  source_schema  varchar2(30)  NOT NULL
)
/

CREATE SEQUENCE sys.scheduler$_rdb_seq
/


CREATE TABLE sys.scheduler$_remote_dbs
(
  database_name  varchar2(512)       NOT NULL,
  reg_status     number              NOT NULL,
 CONSTRAINT scheduler$_rdb_pk PRIMARY KEY
            (database_name, reg_status),
  db_index       number              NOT NULL,
  database_link  varchar2(512)       NOT NULL
)
/

CREATE TABLE scheduler$_remote_job_state
(
  joboid           NUMBER,
  destination      VARCHAR2(512),
 CONSTRAINT scheduler$_rjs_pk PRIMARY KEY
            (joboid, destination),
  next_start_date  TIMESTAMP WITH TIME ZONE,
  run_count        NUMBER,
  failure_count    NUMBER,
  retry_count      NUMBER,
  last_start_date  TIMESTAMP WITH TIME ZONE,
  last_end_date    TIMESTAMP WITH TIME ZONE,
  job_status       NUMBER
)
/

CREATE TABLE scheduler$_file_watcher
(
  obj#                  NUMBER        NOT NULL
                        CONSTRAINT scheduler$_fw_pk PRIMARY KEY,
  directory_path        VARCHAR2(4000)   NOT NULL,
  file_name             VARCHAR2(512)    NOT NULL,
  destination           VARCHAR2(128),
  destoid               NUMBER,
  credoid               NUMBER,
  min_file_size         NUMBER           NOT NULL,
  steady_state_duration INTERVAL DAY(3) TO SECOND(0),
  comments              VARCHAR2(240),
  last_modified_time    TIMESTAMP WITH TIME ZONE,
  flags                 NUMBER
)
/

CREATE TABLE scheduler$_filewatcher_history
(
  directory_path      VARCHAR2(4000),
  last_check_time     TIMESTAMP WITH TIME ZONE
)
/

CREATE TABLE scheduler$_filewatcher_resend
(
  destination         VARCHAR2(128)
                      CONSTRAINT scheduler$_fw_rs_pk PRIMARY KEY,
  fw_owner            VARCHAR2(30),
  fw_name             VARCHAR2(30),
  ins_tstamp          TIMESTAMP WITH TIME ZONE
)
/

CREATE OR REPLACE TYPE scheduler_filewatcher_request AS OBJECT
(
  owner                 VARCHAR2(4000),
  name                  VARCHAR2(4000),
  requested_path_name   VARCHAR2(4000),
  requested_file_name   VARCHAR2(4000),
  credential_owner      VARCHAR2(4000),
  credential_name       VARCHAR2(4000),
  min_file_size         NUMBER,
  steady_state_dur      NUMBER
)
/

CREATE OR REPLACE TYPE scheduler_filewatcher_req_list AS
  TABLE OF scheduler_filewatcher_request
/

CREATE OR REPLACE TYPE scheduler_filewatcher_result AS OBJECT
(
  destination         VARCHAR2(4000),
  directory_path      VARCHAR2(4000),
  actual_file_name    VARCHAR2(4000),
  file_size           NUMBER,
  file_timestamp      TIMESTAMP WITH TIME ZONE,
  ts_ms_from_epoch    NUMBER,
  matching_requests   SYS.SCHEDULER_FILEWATCHER_REQ_LIST
)
/

CREATE OR REPLACE TYPE scheduler_filewatcher_res_list AS
  TABLE OF scheduler_filewatcher_result
/

CREATE OR REPLACE TYPE scheduler_filewatcher_history AS OBJECT
(
  directory_path      VARCHAR2(4000),
  last_check_time     NUMBER,
  insert_elem         VARCHAR2(1),
  delete_elem         VARCHAR2(1)
)
/

CREATE OR REPLACE TYPE scheduler_filewatcher_hst_list AS
  TABLE OF scheduler_filewatcher_history
/

grant execute on sys.scheduler_filewatcher_request to public;
grant execute on sys.scheduler_filewatcher_req_list to public;
grant execute on sys.scheduler_filewatcher_result to public;
grant execute on sys.scheduler_filewatcher_res_list to public;

-- Job e-mail notifications: one per recipient per subscribed event
CREATE TABLE scheduler$_notification
( job_name            VARCHAR2(30)   NOT NULL,
  job_subname         VARCHAR2(30),
  owner               VARCHAR2(30)   NOT NULL,
  recipient           VARCHAR2(4000) NOT NULL,
  sender              VARCHAR2(4000),
  subject             VARCHAR2(4000),
  body                VARCHAR2(4000),
  event_flag          NUMBER         NOT NULL,
  filter_condition    VARCHAR2(4000),
  flags               NUMBER         NOT NULL)
/

/* this speeds up queries on user_s_n and removing notifinations */
CREATE INDEX sys.i_scheduler_notification1
  ON scheduler$_notification (owner, job_name, job_subname);

/* this speeds up the main query in the AQ PL/SQL callback */
CREATE INDEX sys.i_scheduler_notification2
  ON scheduler$_notification (owner, job_name, job_subname, event_flag);

/* this speeds up selects on user_s_n */
CREATE INDEX sys.i_scheduler_notification3
  ON scheduler$_notification (owner);

CREATE TABLE scheduler$_destinations
( obj#                 NUMBER 
     CONSTRAINT scheduler$_dest_pk PRIMARY KEY,
  connect_info         VARCHAR2(4000),
  hostname             VARCHAR2(256),
  ip_address           VARCHAR2(64),
  port                 NUMBER,
  shared_key           RAW(64),
  expiry_date          TIMESTAMP,
  additional_info1     NUMBER,
  additional_info2     VARCHAR2(4000),
  flags                NUMBER,
  agtdestoid           NUMBER,
  comments             VARCHAR2(240))
/

CREATE TABLE scheduler$_job_destinations
( oid                  NUMBER,
  job_dest_id         NUMBER,
  CONSTRAINT scheduler$_jobdest_pk PRIMARY KEY
       (oid, job_dest_id),
  credoid              NUMBER,
  credential           VARCHAR2(65),
  destoid              NUMBER,
  destination          VARCHAR2(128),
  job_status           NUMBER,
  next_start_date      TIMESTAMP WITH TIME ZONE,
  run_count            NUMBER,
  retry_count          NUMBER,
  failure_count        NUMBER,
  last_enabled_time    TIMESTAMP WITH TIME ZONE, 
  last_start_date      TIMESTAMP WITH TIME ZONE,
  last_end_date        TIMESTAMP WITH TIME ZONE)
/
  

CREATE OR REPLACE TYPE sys.scheduler$_dest_list as 
 varray(1024) of VARCHAR2(512)
/

CREATE OR REPLACE TYPE scheduler$_remote_arg as object
(
  arg_position       NUMBER,
  arg_anydata_value  SYS.ANYDATA,
  change_vector      NUMBER
)
/

CREATE OR REPLACE TYPE scheduler$_remote_arg_list as 
 table of SCHEDULER$_REMOTE_ARG
/


CREATE OR REPLACE TYPE sys.scheduler$_remote_db_job_info as object
(
  operation          NUMBER,
  source             VARCHAR2(512),
  destination_list   SYS.SCHEDULER$_DEST_LIST,
  destination_schema VARCHAR2(30),
  destination_pwd    VARCHAR2(256),
  credential_info    RAW(2000),
  job_name           VARCHAR2(100),
  job_class          VARCHAR2(32),
  program_type       VARCHAR2(30),
  job_action         VARCHAR2(4000),
  repeat_interval    VARCHAR2(4000),
  schedule_limit     INTERVAL DAY TO SECOND,
  start_date         TIMESTAMP WITH TIME ZONE,
  end_date           TIMESTAMP WITH TIME ZONE,
  queue_spec         VARCHAR2(100),
  comments           VARCHAR2(240),
  number_of_args     NUMBER,
  arguments          SYS.SCHEDULER$_REMOTE_ARG_LIST,
  priority           NUMBER,
  job_weight         NUMBER,
  max_run_duration   INTERVAL DAY TO SECOND,
  max_runs           NUMBER,
  max_failures       NUMBER,
  raise_events       NUMBER,
  stop_wdw_cls       VARCHAR2(5),
  follw_def_tz       VARCHAR2(5),
  parallel_inst      VARCHAR2(5),
  auto_drop          VARCHAR2(5),
  restartable        VARCHAR2(5),
  log_level          NUMBER,
  chg_vector         NUMBER 
)
/

/* Scheduler Event Queue ADT */

create or replace type sys.scheduler$_event_info as object
(
  event_type         VARCHAR2(4000),
  object_owner       VARCHAR2(4000),
  object_name        VARCHAR2(4000),
  event_timestamp    TIMESTAMP WITH TIME ZONE,
  error_code         NUMBER,
  error_msg          VARCHAR2(4000),
  event_status       NUMBER,
  log_id             NUMBER,
  run_count          NUMBER,
  failure_count      NUMBER,
  retry_count        NUMBER,
  spare1             NUMBER,
  spare2             NUMBER,
  spare3             VARCHAR2(4000),
  spare4             VARCHAR2(4000),
  spare5             TIMESTAMP WITH TIME ZONE,
  spare6             TIMESTAMP WITH TIME ZONE,
  spare7             RAW(2000),
  spare8             RAW(2000),
  object_subname     VARCHAR2(4000),
  job_class_name     VARCHAR2(4000),
  CONSTRUCTOR FUNCTION scheduler$_event_info (
    event_type         VARCHAR2,
    object_owner       VARCHAR2,
    object_name        VARCHAR2,
    event_timestamp    TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
    error_code         NUMBER DEFAULT NULL,
    error_msg          VARCHAR2 DEFAULT NULL,
    event_status       NUMBER DEFAULT NULL,
    log_id             NUMBER DEFAULT NULL,
    run_count          NUMBER DEFAULT NULL,
    failure_count      NUMBER DEFAULT NULL,
    retry_count        NUMBER DEFAULT NULL,
    spare1             NUMBER DEFAULT NULL,
    spare2             NUMBER DEFAULT NULL,
    spare3             VARCHAR2 DEFAULT NULL,
    spare4             VARCHAR2 DEFAULT NULL,
    spare5             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare6             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare7             RAW DEFAULT NULL,
    spare8             RAW DEFAULT NULL,
    object_subname     VARCHAR2 DEFAULT NULL,
    job_class_name     VARCHAR2 DEFAULT NULL)
    RETURN SELF AS RESULT
);
/

create or replace type body sys.scheduler$_event_info as
  CONSTRUCTOR FUNCTION scheduler$_event_info (
    event_type         VARCHAR2,
    object_owner       VARCHAR2,
    object_name        VARCHAR2,
    event_timestamp    TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
    error_code         NUMBER DEFAULT NULL,
    error_msg          VARCHAR2 DEFAULT NULL,
    event_status       NUMBER DEFAULT NULL,
    log_id             NUMBER DEFAULT NULL,
    run_count          NUMBER DEFAULT NULL,
    failure_count      NUMBER DEFAULT NULL,
    retry_count        NUMBER DEFAULT NULL,
    spare1             NUMBER DEFAULT NULL,
    spare2             NUMBER DEFAULT NULL,
    spare3             VARCHAR2 DEFAULT NULL,
    spare4             VARCHAR2 DEFAULT NULL,
    spare5             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare6             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare7             RAW DEFAULT NULL,
    spare8             RAW DEFAULT NULL,
    object_subname     VARCHAR2 DEFAULT NULL,
    job_class_name     VARCHAR2 DEFAULT NULL)
    RETURN SELF AS RESULT
  AS
  BEGIN
    SELF.event_type  := event_type;
    SELF.object_owner := object_owner;
    SELF.object_name := object_name;
    SELF.event_timestamp := event_timestamp;
    SELF.error_code := error_code;
    SELF.error_msg := error_msg;
    SELF.event_status := event_status;
    SELF.log_id := log_id;
    SELF.run_count := run_count;
    SELF.failure_count := failure_count;
    SELF.retry_count := retry_count;
    SELF.spare1 := spare1;
    SELF.spare2 := spare2;
    SELF.spare3 := spare3;
    SELF.spare4 := spare4;
    SELF.spare5 := spare5;
    SELF.spare6 := spare6;
    SELF.spare7 := spare7;
    SELF.spare8 := spare8;
    SELF.object_subname := object_subname;
    SELF.job_class_name := job_class_name;
    RETURN;
  END;
END;
/

grant execute on sys.scheduler$_event_info to public;

create sequence sys.scheduler$_evtseq
/

/*************************************************************
 * Calendar types and constants
 *************************************************************
 */

CREATE OR REPLACE TYPE scheduler$_int_array_type IS VARRAY (1000) OF INTEGER
/

GRANT EXECUTE ON scheduler$_int_array_type TO public
/

/********************************************************************/
/*                   Batch API Types and Constants                  */
/********************************************************************/

-- Job Argument 

CREATE OR REPLACE TYPE JOBARG AS OBJECT
(
  arg_position          NUMBER,
  arg_text_value        VARCHAR2(4000),
  arg_anydata_value     SYS.ANYDATA,
  arg_operation         VARCHAR2(5),
  -- Set text argument
  CONSTRUCTOR FUNCTION jobarg
  (
    arg_position        IN     POSITIVEN,
    arg_value           IN     VARCHAR2
  )
  RETURN SELF AS RESULT,
  -- Set anydata argument
  CONSTRUCTOR FUNCTION jobarg
  (
    arg_position        IN     POSITIVEN,
    arg_value           IN     SYS.ANYDATA
  )
  RETURN SELF AS RESULT,
  -- If arg_reset is TRUE then the argument at that position is reset,
  -- otherwise it is set to a NULL value.
  CONSTRUCTOR FUNCTION jobarg
  (
    arg_position        IN     POSITIVEN,
    arg_reset           IN     BOOLEAN DEFAULT FALSE
  )
  RETURN SELF AS RESULT
);
/

-- Array of job arguments

CREATE OR REPLACE TYPE JOBARG_ARRAY AS TABLE OF JOBARG;
/

-- Jobs

CREATE OR REPLACE TYPE JOB_DEFINITION AS OBJECT
(
  -- Job name and classification
  job_name                VARCHAR2(100),
  job_class               VARCHAR2(32),
  job_style               VARCHAR2(11),

  -- Program/template related attributes
  -- Lightweight jobs cannot have inlined program
  program_name            VARCHAR2(100),
  job_action              VARCHAR2(4000),
  job_type                VARCHAR2(20),

  -- Schedule related attributes
  -- Lightweight jobs cannot have start_date, end_date or
  -- schedule_limit set.
  schedule_name           VARCHAR2(65),
  repeat_interval         VARCHAR2(4000),
  schedule_limit          INTERVAL DAY TO SECOND,
  start_date              TIMESTAMP WITH TIME ZONE,
  end_date                TIMESTAMP WITH TIME ZONE,
  event_condition         VARCHAR2(4000),
  queue_spec              VARCHAR2(100),

  -- Argument related attributes
  number_of_arguments     NUMBER,
  arguments               SYS.JOBARG_ARRAY,

  -- Misc other attributes
  -- Of these only priority, logging_level, restartable and
  -- stop_on_window_close are settable for lightweight jobs
  job_priority            NUMBER,
  job_weight              NUMBER,
  max_run_duration        INTERVAL DAY TO SECOND,
  max_runs                NUMBER,
  max_failures            NUMBER,
  logging_level           NUMBER,
  restartable             VARCHAR2(5),
  stop_on_window_close    VARCHAR2(5),
  raise_events            NUMBER,
  comments                VARCHAR2(240),
  auto_drop               VARCHAR2(5),
  enabled                 VARCHAR2(5),
  follow_default_timezone VARCHAR2(5),
  parallel_instances      VARCHAR2(5),
  aq_job                  VARCHAR2(5),
  instance_id             NUMBER,
  credential_name         VARCHAR2(65),
  destination             VARCHAR2(4000),
  database_role           VARCHAR2(20),
  allow_runs_in_restricted_mode  VARCHAR2(5), 
  -- named program and named schedule
  CONSTRUCTOR FUNCTION job_definition
  (
    job_name                IN     VARCHAR2,
    job_style               IN     VARCHAR2 DEFAULT 'REGULAR',
    program_name            IN     VARCHAR2 DEFAULT NULL,
    job_action              IN     VARCHAR2 DEFAULT NULL,
    job_type                IN     VARCHAR2 DEFAULT NULL,
    schedule_name           IN     VARCHAR2 DEFAULT NULL,
    repeat_interval         IN     VARCHAR2 DEFAULT NULL,
    event_condition         IN     VARCHAR2 DEFAULT NULL,
    queue_spec              IN     VARCHAR2 DEFAULT NULL,
    start_date              IN     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    end_date                IN     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    number_of_arguments     IN     NATURAL DEFAULT NULL,
    arguments               IN     SYS.JOBARG_ARRAY DEFAULT NULL,
    job_class               IN     VARCHAR2 DEFAULT 'DEFAULT_JOB_CLASS',
    schedule_limit          IN     INTERVAL DAY TO SECOND DEFAULT NULL,
    job_priority            IN     NATURAL DEFAULT NULL,
    job_weight              IN     NATURAL DEFAULT NULL,
    max_run_duration        IN     INTERVAL DAY TO SECOND DEFAULT NULL,
    max_runs                IN     NATURAL DEFAULT NULL,
    max_failures            IN     NATURAL DEFAULT NULL,
    logging_level           IN     NATURALN DEFAULT 64,
    restartable             IN     BOOLEAN DEFAULT FALSE,
    stop_on_window_close    IN     BOOLEAN DEFAULT FALSE,
    raise_events            IN     NATURAL DEFAULT NULL,
    comments                IN     VARCHAR2 DEFAULT NULL,
    auto_drop               IN     BOOLEAN DEFAULT TRUE,
    enabled                 IN     BOOLEAN DEFAULT FALSE,
    follow_default_timezone IN     BOOLEAN DEFAULT FALSE,
    parallel_instances      IN     BOOLEAN DEFAULT FALSE,
    aq_job                  IN     BOOLEAN DEFAULT FALSE,
    instance_id             IN     NATURAL DEFAULT NULL,
    credential_name         IN     VARCHAR2 DEFAULT NULL,
    destination             IN     VARCHAR2 DEFAULT NULL,
    database_role           IN     VARCHAR2 DEFAULT NULL,
    allow_runs_in_restricted_mode IN BOOLEAN DEFAULT FALSE
  )
  RETURN SELF AS RESULT
);
/

-- Array of jobs

CREATE OR REPLACE TYPE JOB_DEFINITION_ARRAY AS TABLE OF JOB_DEFINITION;
/

-- Job attribute

CREATE OR REPLACE TYPE JOBATTR AS OBJECT
(   
  job_name              VARCHAR2(100),
  attr_name             VARCHAR2(30),
  char_value            VARCHAR2(4000),
  char_value2           VARCHAR2(4000),
  args_value            SYS.JOBARG_ARRAY,
  num_value             NUMBER,
  timestamp_value       TIMESTAMP WITH TIME ZONE,
  interval_value        INTERVAL DAY TO SECOND,
  CONSTRUCTOR FUNCTION jobattr
  (
    job_name            IN     VARCHAR2,
    attr_name           IN     VARCHAR2,
    attr_value          IN     VARCHAR2,
    attr_value2         IN     VARCHAR2 DEFAULT NULL
  )
  RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION jobattr
  (
    job_name            IN     VARCHAR2,
    attr_name           IN     VARCHAR2,
    attr_value          IN     NUMBER
  )
  RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION jobattr
  (
    job_name            IN     VARCHAR2,
    attr_name           IN     VARCHAR2,
    attr_value          IN     BOOLEAN
  )
  RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION jobattr
  (
    job_name            IN     VARCHAR2,
    attr_name           IN     VARCHAR2,
    attr_value          IN     TIMESTAMP WITH TIME ZONE
  )
  RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION jobattr
  (
    job_name            IN     VARCHAR2,
    attr_name           IN     VARCHAR2,
    attr_value          IN     INTERVAL DAY TO SECOND
  )
  RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION jobattr
  (
    job_name            IN     VARCHAR2,
    attr_name           IN     VARCHAR2,
    attr_value          IN     SYS.JOBARG_ARRAY
  )
  RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION jobattr
  (
    job_name            IN     VARCHAR2,
    attr_name           IN     VARCHAR2
  )
  RETURN SELF AS RESULT
);
/

-- Array of job attributes

CREATE OR REPLACE TYPE JOBATTR_ARRAY AS TABLE OF JOBATTR;
/

-- Scheduler batch errors type
CREATE OR REPLACE TYPE SCHEDULER$_BATCHERR AS OBJECT
(
  array_index           NUMBER,
  object_type           VARCHAR2(30),
  object_name           VARCHAR2(100),
  attr_name             VARCHAR2(30),
  error_code            NUMBER,
  error_message         VARCHAR2(4000),
  additional_info       VARCHAR2(4000)
);
/

-- Array of scheduler errors type

CREATE OR REPLACE TYPE SCHEDULER$_BATCHERR_ARRAY AS 
  TABLE OF SCHEDULER$_BATCHERR;
/

/*****************************************************************************
 **                TYPE JOB HAS BEEN DEPRECATED - DO NOT USE                **
 *****************************************************************************/

CREATE OR REPLACE TYPE JOB AS OBJECT
(
  -- Job name and classification
  job_name              VARCHAR2(100),
  job_class             VARCHAR2(32),
  job_style             VARCHAR2(11),

  -- Program/template related attributes
  -- Lightweight jobs cannot have inlined program
  job_template          VARCHAR2(100),
  program_action        VARCHAR2(4000),
  action_type           VARCHAR2(20),

  -- Schedule related attributes
  -- Lightweight jobs cannot have start_date, end_date or
  -- schedule_limit set.
  schedule_name         VARCHAR2(65),
  repeat_interval       VARCHAR2(4000),
  schedule_limit        INTERVAL DAY TO SECOND,
  start_date            TIMESTAMP WITH TIME ZONE,
  end_date              TIMESTAMP WITH TIME ZONE,
  event_condition       VARCHAR2(4000),
  queue_spec            VARCHAR2(100),

  -- Argument related attributes
  number_of_args        NUMBER,
  arguments             SYS.JOBARG_ARRAY,

  -- Misc other attributes
  -- Of these only priority, logging_level, restartable and
  -- stop_on_window_exit are settable for lightweight jobs
  priority              NUMBER,
  job_weight            NUMBER,
  max_run_duration      INTERVAL DAY TO SECOND,
  max_runs              NUMBER,
  max_failures          NUMBER,
  logging_level         NUMBER,
  restartable           VARCHAR2(5),
  stop_on_window_exit   VARCHAR2(5),
  raise_events          NUMBER,
  comments              VARCHAR2(240),
  auto_drop             VARCHAR2(5),
  enabled               VARCHAR2(5),
  follow_default_tz     VARCHAR2(5),
  parallel_instances    VARCHAR2(5),
  aq_job                VARCHAR2(5),
  instance_id           NUMBER,
  -- named program and named schedule
  CONSTRUCTOR FUNCTION job
  (
    job_name            IN     VARCHAR2,
    job_style           IN     VARCHAR2 DEFAULT 'REGULAR',
    job_template        IN     VARCHAR2 DEFAULT NULL,
    program_action      IN     VARCHAR2 DEFAULT NULL,
    action_type         IN     VARCHAR2 DEFAULT NULL,
    schedule_name       IN     VARCHAR2 DEFAULT NULL,
    repeat_interval     IN     VARCHAR2 DEFAULT NULL,
    event_condition     IN     VARCHAR2 DEFAULT NULL,
    queue_spec          IN     VARCHAR2 DEFAULT NULL,
    start_date          IN     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    end_date            IN     TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    number_of_args      IN     NATURAL DEFAULT NULL,
    arguments           IN     SYS.JOBARG_ARRAY DEFAULT NULL,
    job_class           IN     VARCHAR2 DEFAULT 'DEFAULT_JOB_CLASS',
    schedule_limit      IN     INTERVAL DAY TO SECOND DEFAULT NULL,
    priority            IN     NATURAL DEFAULT NULL,
    job_weight          IN     NATURAL DEFAULT NULL,
    max_run_duration    IN     INTERVAL DAY TO SECOND DEFAULT NULL,
    max_runs            IN     NATURAL DEFAULT NULL,
    max_failures        IN     NATURAL DEFAULT NULL,
    logging_level       IN     NATURALN DEFAULT 64,
    restartable         IN     BOOLEAN DEFAULT FALSE,
    stop_on_window_exit IN     BOOLEAN DEFAULT FALSE,
    raise_events        IN     NATURAL DEFAULT NULL,
    comments            IN     VARCHAR2 DEFAULT NULL,
    auto_drop           IN     BOOLEAN DEFAULT TRUE,
    enabled             IN     BOOLEAN DEFAULT FALSE,
    follow_default_tz   IN     BOOLEAN DEFAULT FALSE,
    parallel_instances  IN     BOOLEAN DEFAULT FALSE,
    aq_job              IN     BOOLEAN DEFAULT FALSE,
    instance_id         IN     NATURAL DEFAULT NULL
  )
  RETURN SELF AS RESULT
);
/


/*****************************************************************************
 **             TYPE JOB_ARRAY HAS BEEN DEPRECATED - DO NOT USE             **
 *****************************************************************************/
-- Array of jobs

CREATE OR REPLACE TYPE JOB_ARRAY AS TABLE OF JOB;
/


-- moved object type to caschv.sql

-- moved @@dbmssch.sql to catpdbms 

-- moved dependent views to catschv.sql

/* Create sequence for job_name suffixes. This is used by generate_job_name */
create sequence scheduler$_jobsuffix_s;
grant select on sys.scheduler$_jobsuffix_s to public with grant option;

-- Moved prvt files to catpdbms and catpprvt

/* Moved all AQ-related calls to catscqa.sql */

-- moved scheduler anonymous blocks to execsch.sql

