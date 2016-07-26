Rem
Rem $Header: rdbms/admin/execsch.sql /main/5 2010/02/15 11:53:39 rgmani Exp $
Rem
Rem execsch.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      execsch.sql - EXECute Scheduler PL/SQL
Rem
Rem    DESCRIPTION
Rem      Create Scheduler objects
Rem
Rem    NOTES
Rem      Run after schedule package loads, but before dependents
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rramkiss    11/09/09 - change email_server_ssl to
Rem                           email_server_encryption
Rem    rramkiss    10/20/09 - add new sched attribs for e-mail encryption/auth
Rem    evoss       04/01/09 - add local pseudo destinations
Rem    rgmani      03/14/08 - Add file watch job
Rem    rramkiss    03/13/08 - add new e-mail scheduler attributes
Rem    rburns      07/29/06 - create scheduler objects 
Rem    rburns      07/29/06 - Created
Rem

/* Scheduler admin role */
CREATE ROLE scheduler_admin
/
GRANT create job, create any job, execute any program, execute any class,
manage scheduler, create external job TO scheduler_admin WITH ADMIN OPTION
/
GRANT scheduler_admin TO dba WITH ADMIN OPTION
/

/* Create a default class and grant execute on it to PUBLIC */
begin
dbms_scheduler.create_job_class(job_class_name => 'DEFAULT_JOB_CLASS',
 comments=>'This is the default job class.');
dbms_scheduler.set_attribute('DEFAULT_JOB_CLASS','SYSTEM',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
end;
/
grant execute on sys.default_job_class to public with grant option
/

/* Create a default class and grant execute on it to PUBLIC */
begin
dbms_scheduler.create_job_class(job_class_name => 'SCHED$_LOG_ON_ERRORS_CLASS',
 logging_level => DBMS_SCHEDULER.LOGGING_FAILED_RUNS,
 comments=>'This is the default job if you want minimal logging.');
dbms_scheduler.set_attribute('SCHED$_LOG_ON_ERRORS_CLASS','SYSTEM',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
end;
/


/* Create a job class for jobs created through DBMS_JOB api and 
   grant execute on it to PUBLIC */
begin
dbms_scheduler.create_job_class(job_class_name => 'DBMS_JOB$',
 logging_level=>DBMS_SCHEDULER.LOGGING_OFF,
 comments=>'This is the job class for jobs created through DBMS_JOB.');
dbms_scheduler.set_attribute('DBMS_JOB$','SYSTEM',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
end;
/
grant execute on sys.dbms_job$ to public with grant option
/


-- Only set the 'MAX_JOB_SLAVE_PROCESSES', 'LOG_HISTORY','DEFAULT_TIMEZONE'
-- global attributes to their default values only if they do not already
-- exist in the table.  This is to retain their value on upgrades.

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'MAX_JOB_SLAVE_PROCESSES';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('MAX_JOB_SLAVE_PROCESSES', NULL);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL;
      else raise;
      end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'LOG_HISTORY';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('LOG_HISTORY', 30);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL;
      else raise;
      end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'DEFAULT_TIMEZONE';

EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('DEFAULT_TIMEZONE', 
                            dbms_scheduler.get_sys_time_zone_name);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL;
      else raise;
      end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'EMAIL_SERVER';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('EMAIL_SERVER', NULL);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL; else raise; end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'EMAIL_SERVER_ENCRYPTION';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('EMAIL_SERVER_ENCRYPTION', 'NONE');
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL; else raise; end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'EMAIL_SERVER_CREDENTIAL';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('EMAIL_SERVER_CREDENTIAL', NULL);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL; else raise; end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/

DECLARE
  dummy varchar2(1);
BEGIN
 SELECT null into dummy
 FROM sys.obj$ o, sys.scheduler$_global_attribute a
 WHERE o.obj# = a.obj# AND o.name = 'EMAIL_SENDER';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
  BEGIN
    dbms_scheduler.set_scheduler_attribute('EMAIL_SENDER', NULL);
  EXCEPTION
    WHEN OTHERS THEN
      if sqlcode = -955 then NULL; else raise; end if;
  END;
  WHEN OTHERS THEN RAISE;
END;
/


--Create pseudo local external destination
BEGIN
dbms_isched.create_agent_destination( 
  destination_name => 'sched$_local_pseudo_agent',
  hostname         => 'pseudo_host',
  port             => '0',
  comments         => 'Place holder for synonym LOCAL dest');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

--Create pseudo local db destination
BEGIN
dbms_scheduler.create_database_destination( 
  destination_name  => 'sched$_local_pseudo_db',
  agent             => 'sched$_local_pseudo_agent',
  tns_name          => 'pseudo_inst',
  comments          => 'Place holder for synonym LOCAL_DB dest');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

--Create purge log program.
BEGIN
dbms_scheduler.create_program(
  program_name=>'purge_log_prog',
  program_type=>'STORED_PROCEDURE',
  program_action=>'dbms_scheduler.auto_purge',
  number_of_arguments=>0,
  enabled=>TRUE,
  comments=>'purge log program');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create daily schedule. 
BEGIN
dbms_scheduler.create_schedule(
   schedule_name=>'DAILY_PURGE_SCHEDULE',
   repeat_interval=>'freq=daily;byhour=3;byminute=0;bysecond=0');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create purge log job
BEGIN
  sys.dbms_scheduler.create_job(
    job_name=>'PURGE_LOG',
    program_name=>'purge_log_prog',
    schedule_name=>'DAILY_PURGE_SCHEDULE',
    job_class=>'DEFAULT_JOB_CLASS',
    enabled=>TRUE,
    auto_drop=>FALSE,
    comments=>'purge log job');
  sys.dbms_scheduler.set_attribute('PURGE_LOG','FOLLOW_DEFAULT_TIMEZONE',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create file watcher program
BEGIN
  dbms_scheduler.create_program(
    program_name =>'FILE_WATCHER_PROGRAM',
    program_type=>'STORED_PROCEDURE',
    program_action =>'dbms_isched.file_watch_job',
    number_of_arguments => 0,
    enabled => TRUE,
    comments => 'File Watcher program');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create FileWatcher Schedule
BEGIN
  dbms_scheduler.create_schedule(
    schedule_name => 'FILE_WATCHER_SCHEDULE',
    repeat_interval => 'FREQ=MINUTELY;INTERVAL=10');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create file watcher job
BEGIN
  sys.dbms_scheduler.create_job(
    job_name=>'FILE_WATCHER',
    program_name=>'FILE_WATCHER_PROGRAM',
    schedule_name=>'FILE_WATCHER_SCHEDULE',
    job_class=>'SCHED$_LOG_ON_ERRORS_CLASS',
    enabled=>FALSE,
    auto_drop=>FALSE,
    comments=>'File watcher job');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

begin
  dbms_scheduler.set_scheduler_attribute('LAST_OBSERVED_EVENT', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_scheduler.set_scheduler_attribute('EVENT_EXPIRY_TIME', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

begin
  dbms_scheduler.set_scheduler_attribute('FILE_WATCHER_COUNT', '0');
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

-- ***************************************************************************
-- This has to be the last thing executed in catsch.sql
-- Do not add anything after this
-- ***************************************************************************

begin
  dbms_scheduler.set_scheduler_attribute('CURRENT_OPEN_WINDOW', NULL);
exception
  when others then
    if sqlcode = -955 then NULL;
    else raise;
    end if;
end;
/

