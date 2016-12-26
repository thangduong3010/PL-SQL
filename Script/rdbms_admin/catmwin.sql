Rem
Rem $Header: catmwin.sql 04-jan-2008.12:42:54 mjstewar Exp $
Rem
Rem catmwin.sql
Rem
Rem Copyright (c) 2003, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catmwin.sql - Catalog script for Maintenance WINdow
Rem
Rem    DESCRIPTION
Rem      Defines maintenance window and stats collection job.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mjstewar    01/04/08 - Move upgrade changes to a1101000.sql
Rem    mjstewar    11/09/07 - disable HM_CREATE_OFFLINE_DICTIONARY
Rem    husun       09/12/07 - bug-6412947 - add timeout parameter to
Rem                           DRA_REEVALUATE_OPEN_FAILURES
Rem    husun       02/12/07 - bug-5878597 - add dbms_ir.reevaluateopenfailures
Rem                           to maintence window
Rem    ilistvin    11/08/06 - move alert queue creation here
Rem    ilistvin    11/03/06 - do not diable old windows if they exist
Rem    siroych     10/10/06 - add job for offline dictionary creation
Rem    ilistvin    08/01/06 - create WEEKEND and WEEKNIGHT windows
Rem    ilistvin    07/13/06 - set resource plan to DEFAULT_MAINTENANCE_PLAN 
Rem    ilistvin    06/07/06 - set resource plan to NULL 
Rem    ilistvin    04/04/06 - changes for AUTOTASK 
Rem    mtakahar    02/23/05 - #(4175406) change gather_stats_* comments
Rem    mtakahar    09/15/04 - gather_stats_job termination callback
Rem    ilistvin    07/14/04 - move set_attribute outside exception block 
Rem    smuthuli    04/26/04 - auto space advisor 
Rem    jxchen      12/19/03 - Set "restartable" attribute for GATHER_STATS_JOB 
Rem    schakkap    12/05/03 - stop auto stats collection at end of mgmt window 
Rem    evoss       12/02/03 - 
Rem    evoss       11/17/03 - add follow_default_timezone attr for windows and 
Rem    rramkiss    06/16/03 - flag system-managed objects
Rem    rramkiss    06/16/03 - suppress already_exists errors
Rem    jxchen      06/12/03 - Add job definition
Rem    jxchen      06/04/03 - jxchen_mwin_main
Rem    jxchen      05/12/03 - Created
Rem
DECLARE
 MAINTENANCE_PLAN CONSTANT VARCHAR2(30) := 'DEFAULT_MAINTENANCE_PLAN';
BEGIN
  --
  -- Create MONDAY_WINDOW window.
  -- Monday window is 10pm Monday to 2am Tuesday
  --
  BEGIN
     BEGIN
     dbms_scheduler.create_window(
        window_name=>'MONDAY_WINDOW',
        resource_plan=>MAINTENANCE_PLAN,
        repeat_interval=>'freq=daily;byday=MON;byhour=22;' ||
                      'byminute=0; bysecond=0',
        duration=>interval '4' hour,
        comments=>'Monday window for maintenance tasks');
     EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
     END;
     dbms_scheduler.set_attribute('MONDAY_WINDOW','SYSTEM',TRUE);
     dbms_scheduler.set_attribute('MONDAY_WINDOW',
                                   'FOLLOW_DEFAULT_TIMEZONE',TRUE);
  EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
  END;
   
  --
  -- Create TUESDAY_WINDOW window.
  -- Tuesday window is 10pm Tuesday to 2am Wednesday
  --
  BEGIN
     BEGIN
     dbms_scheduler.create_window(
        window_name=>'TUESDAY_WINDOW',
        resource_plan=>MAINTENANCE_PLAN,
        repeat_interval=>'freq=daily;byday=TUE;byhour=22;' ||
                      'byminute=0; bysecond=0',
        duration=>interval '4' hour,
        comments=>'Tuesday window for maintenance tasks');
     EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
     END;
     dbms_scheduler.set_attribute('TUESDAY_WINDOW','SYSTEM',TRUE);
     dbms_scheduler.set_attribute('TUESDAY_WINDOW',
                                   'FOLLOW_DEFAULT_TIMEZONE',TRUE);
  EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
  END;
   
  --
  -- Create WEDNESDAY_WINDOW window.
  -- Wednesday window is 10pm Wednesday to 2am Thursday
  --
  BEGIN
     BEGIN
     dbms_scheduler.create_window(
        window_name=>'WEDNESDAY_WINDOW',
        resource_plan=>MAINTENANCE_PLAN,
        repeat_interval=>'freq=daily;byday=WED;byhour=22;' ||
                      'byminute=0; bysecond=0',
        duration=>interval '4' hour,
        comments=>'Wednesday window for maintenance tasks');
     EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
     END;
     dbms_scheduler.set_attribute('WEDNESDAY_WINDOW','SYSTEM',TRUE);
     dbms_scheduler.set_attribute('WEDNESDAY_WINDOW',
                                   'FOLLOW_DEFAULT_TIMEZONE',TRUE);
  EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
  END;
   
  --
  -- Create THURSDAY_WINDOW window.
  -- Thursday window is 10pm Thursday to 2am Friday
  --
  BEGIN
     BEGIN
     dbms_scheduler.create_window(
        window_name=>'THURSDAY_WINDOW',
        resource_plan=>MAINTENANCE_PLAN,
        repeat_interval=>'freq=daily;byday=THU;byhour=22;' ||
                      'byminute=0; bysecond=0',
        duration=>interval '4' hour,
        comments=>'Thursday window for maintenance tasks');
     EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
     END;
     dbms_scheduler.set_attribute('THURSDAY_WINDOW','SYSTEM',TRUE);
     dbms_scheduler.set_attribute('THURSDAY_WINDOW',
                                   'FOLLOW_DEFAULT_TIMEZONE',TRUE);
  EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
  END;
   
  --
  -- Create FRIDAY_WINDOW window.
  -- Friday window is 10pm Friday to 2am Saturday
  --
  BEGIN
     BEGIN
     dbms_scheduler.create_window(
        window_name=>'FRIDAY_WINDOW',
        resource_plan=>MAINTENANCE_PLAN,
        repeat_interval=>'freq=daily;byday=FRI;byhour=22;' ||
                      'byminute=0; bysecond=0',
        duration=>interval '4' hour,
        comments=>'Friday window for maintenance tasks');
     EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
     END;
     dbms_scheduler.set_attribute('FRIDAY_WINDOW','SYSTEM',TRUE);
     dbms_scheduler.set_attribute('FRIDAY_WINDOW',
                                   'FOLLOW_DEFAULT_TIMEZONE',TRUE);
  EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
  END;
   
  --
  -- Create SATURDAY_WINDOW window.
  -- Friday window is 6 am Saturday to 2am Sunday
  --
  BEGIN
     BEGIN
     dbms_scheduler.create_window(
        window_name=>'SATURDAY_WINDOW',
        resource_plan=>MAINTENANCE_PLAN,
        repeat_interval=>'freq=daily;byday=SAT;byhour=6;' ||
                      'byminute=0; bysecond=0',
        duration=>interval '20' hour,
        comments=>'Saturday window for maintenance tasks');
     EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
     END;
     dbms_scheduler.set_attribute('SATURDAY_WINDOW','SYSTEM',TRUE);
     dbms_scheduler.set_attribute('SATURDAY_WINDOW',
                                   'FOLLOW_DEFAULT_TIMEZONE',TRUE);
  EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
  END;
   
  --
  -- Create SUNDAY_WINDOW window.
  -- Friday window is 6 am Sunday to 2am Monday
  --
  BEGIN
     BEGIN
     dbms_scheduler.create_window(
        window_name=>'SUNDAY_WINDOW',
        resource_plan=>MAINTENANCE_PLAN,
        repeat_interval=>'freq=daily;byday=SUN;byhour=6;' ||
                      'byminute=0; bysecond=0',
        duration=>interval '20' hour,
        comments=>'Sunday window for maintenance tasks');
     EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
     END;
     dbms_scheduler.set_attribute('SUNDAY_WINDOW','SYSTEM',TRUE);
     dbms_scheduler.set_attribute('SUNDAY_WINDOW',
                                   'FOLLOW_DEFAULT_TIMEZONE',TRUE);
  EXCEPTION
        when others then
          if sqlcode = -27477 then NULL;
          else raise;
          end if;
  END;
END;
/

BEGIN
 --
 -- Set up scheduler objects for Automated Maintenance Tasks.
 -- This includes 'MAINTENANCE_WINDOW_GROUP'
 --
 dbms_autotask_prvt.setup(0);
 --
 -- Add new windows to the 'MAINTENANCE_WINDOW_GROUP'.
 --
   BEGIN
   dbms_scheduler.add_window_group_member('MAINTENANCE_WINDOW_GROUP', 
                    'MONDAY_WINDOW');
   dbms_scheduler.add_window_group_member('MAINTENANCE_WINDOW_GROUP', 
                    'TUESDAY_WINDOW');
   dbms_scheduler.add_window_group_member('MAINTENANCE_WINDOW_GROUP', 
                    'WEDNESDAY_WINDOW');
   dbms_scheduler.add_window_group_member('MAINTENANCE_WINDOW_GROUP', 
                    'THURSDAY_WINDOW');
   dbms_scheduler.add_window_group_member('MAINTENANCE_WINDOW_GROUP', 
                    'FRIDAY_WINDOW');
   dbms_scheduler.add_window_group_member('MAINTENANCE_WINDOW_GROUP', 
                    'SATURDAY_WINDOW');
   dbms_scheduler.add_window_group_member('MAINTENANCE_WINDOW_GROUP', 
                    'SUNDAY_WINDOW');
   EXCEPTION
     when others then raise;
   END;
 --
 -- synchronize all AUTOTASK window groups with 'MAINTENANCE_WINDOW_GROUP'
 --
 dbms_autotask_prvt.setup(3);

EXCEPTION
      when others then raise;
END;
/ 

-- Create gather stats program.
BEGIN
dbms_scheduler.create_program(
  program_name=>'gather_stats_prog', 
  program_type=>'STORED_PROCEDURE', 
  program_action=>'dbms_stats.gather_database_stats_job_proc',
  number_of_arguments=>0,
  enabled=>TRUE,
  comments
      =>'Oracle defined automatic optimizer statistics collection program');
EXCEPTION
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create auto space advisor program.
BEGIN
dbms_scheduler.create_program(
  program_name=>'auto_space_advisor_prog',
  program_type=>'STORED_PROCEDURE',
  program_action=>'dbms_space.auto_space_advisor_job_proc',
  number_of_arguments=>0,
  enabled=>TRUE,
  comments=>'auto space advisor maintenance program');
EXCEPTION
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

--Create autotask repository data ageing program
BEGIN
dbms_scheduler.create_program(
  program_name=>'ora$age_autotask_data',
  program_type=>'STORED_PROCEDURE',
  program_action=>'dbms_autotask_prvt.age',
  number_of_arguments=>0,
  enabled=>TRUE,
  comments=>'deletes obsolete AUTOTASK repository data');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create autotask repository data ageing job
BEGIN
  sys.dbms_scheduler.create_job(
    job_name=>'ORA$AUTOTASK_CLEAN',
    program_name=>'ora$age_autotask_data',
    schedule_name=>'DAILY_PURGE_SCHEDULE',
    job_class=>'DEFAULT_JOB_CLASS',
    enabled=>TRUE,
    auto_drop=>FALSE,
    comments=>'Delete obsolete AUTOTASK repository data');
  sys.dbms_scheduler.set_attribute('ORA$AUTOTASK_CLEAN','FOLLOW_DEFAULT_TIMEZONE',TRUE);
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create resource manager consumer group.
execute dbms_resource_manager.create_pending_area;

BEGIN
  dbms_resource_manager.create_consumer_group(
     consumer_group=>'AUTO_TASK_CONSUMER_GROUP',
     comment=>'System maintenance task consumer group');
EXCEPTION
  when others then
    if sqlcode = -29357 then NULL;
    else raise;
    end if;
END;
/
execute dbms_resource_manager.submit_pending_area;

-- Create weeknight window (it is created so that import from 10.x works properly)
BEGIN
   dbms_scheduler.create_window(
      window_name=>'WEEKNIGHT_WINDOW',
      resource_plan=>NULL,
      repeat_interval=>'freq=daily;byday=MON,TUE,WED,THU,FRI;byhour=22;' ||
                    'byminute=0; bysecond=0',
      duration=>interval '480' minute,
      comments=>'Weeknight window - for compatibility only');
   dbms_scheduler.disable('WEEKNIGHT_WINDOW', TRUE);
   dbms_scheduler.set_attribute('WEEKNIGHT_WINDOW',
                                 'SYSTEM',TRUE);
   dbms_scheduler.set_attribute('WEEKNIGHT_WINDOW',
                                 'FOLLOW_DEFAULT_TIMEZONE',TRUE);
EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
END;
/

-- Create weekend window (it is created so that import from 10.x works properly)
BEGIN
    dbms_scheduler.create_window(
       window_name=>'WEEKEND_WINDOW',
       resource_plan=>NULL,
       repeat_interval=>'freq=daily;byday=SAT;byhour=0;byminute=0;bysecond=0',
       duration=>interval '2880' minute,
       comments=>'Weekend window - for compatibility only');
    dbms_scheduler.disable('WEEKEND_WINDOW', TRUE);
    dbms_scheduler.set_attribute('WEEKEND_WINDOW','SYSTEM',TRUE);
    dbms_scheduler.set_attribute('WEEKEND_WINDOW',
                                 'FOLLOW_DEFAULT_TIMEZONE',TRUE);
EXCEPTION
      when others then
        if sqlcode = -27477 then NULL;
        else raise;
        end if;
END;
/

-- Create job for creation of offline dictionary for Database Repair Advisor
BEGIN
  sys.dbms_scheduler.create_job(
    job_name=>'HM_CREATE_OFFLINE_DICTIONARY',
    job_type=>'STORED_PROCEDURE',
    job_action=>'dbms_hm.create_offline_dictionary',
    schedule_name=>'MAINTENANCE_WINDOW_GROUP',
    job_class=>'DEFAULT_JOB_CLASS',
    enabled=>FALSE,
    auto_drop=>FALSE,
    comments=>'Create offline dictionary in ADR for DRA name translation');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Create job for reevaluate open failures for Database Repair Advisor
BEGIN
  sys.dbms_scheduler.create_job(
    job_name=>'DRA_REEVALUATE_OPEN_FAILURES',
    job_type=>'STORED_PROCEDURE',
    job_action=>'dbms_ir.reevaluateopenfailures',
    number_of_arguments=>4,
    schedule_name=>'MAINTENANCE_WINDOW_GROUP',
    job_class=>'DEFAULT_JOB_CLASS',
    enabled=>FALSE,
    auto_drop=>FALSE,
    comments=>'Reevaluate open failures for DRA');
exception
  when others then
    if sqlcode = -27477 then NULL;
    else raise;
    end if;
END;
/

-- Set the parameters.
BEGIN
  -- In previous releases the job did not have any parameters.
  -- So, to handle the case where we're upgrading, set the 
  -- 'number_of_arguments' attribute.  The job must be disabled
  -- to do this.
  sys.dbms_scheduler.disable('DRA_REEVALUATE_OPEN_FAILURES');
  sys.dbms_scheduler.set_attribute(
    name=> 'DRA_REEVALUATE_OPEN_FAILURES',
    attribute=> 'number_of_arguments',
    value=> 4);
  sys.dbms_scheduler.set_job_argument_value(
    job_name=> 'DRA_REEVALUATE_OPEN_FAILURES', 
    argument_position=> 1, 
    argument_value=> 'TRUE');
  sys.dbms_scheduler.set_job_argument_value(
    job_name=> 'DRA_REEVALUATE_OPEN_FAILURES',
    argument_position=> 2,
    argument_value=> 'TRUE');
  sys.dbms_scheduler.set_job_argument_value(
    job_name=> 'DRA_REEVALUATE_OPEN_FAILURES',
    argument_position=> 3,
    argument_value=> 'TRUE');
  -- Timeout of 15 minutes (900 seconds)
  sys.dbms_scheduler.set_job_argument_value(
    job_name=> 'DRA_REEVALUATE_OPEN_FAILURES',
    argument_position=> 4,
    argument_value=> '900');
  sys.dbms_scheduler.enable('DRA_REEVALUATE_OPEN_FAILURES');
END;
/

-- Create alert queue table and alert queue
BEGIN
   BEGIN
   dbms_aqadm.create_queue_table(
            queue_table => 'SYS.ALERT_QT',
            queue_payload_type => 'SYS.ALERT_TYPE',
            storage_clause => 'TABLESPACE "SYSAUX"',
            multiple_consumers => TRUE,
            comment => 'Server Generated Alert Queue Table',
            secure => TRUE);
   dbms_aqadm.create_queue(
            queue_name => 'SYS.ALERT_QUE',
            queue_table => 'SYS.ALERT_QT',
            comment => 'Server Generated Alert Queue');
   EXCEPTION
     when others then
       if sqlcode = -24001 then NULL;
       else raise;
       end if;
   END;
   dbms_aqadm.start_queue('SYS.ALERT_QUE', TRUE, TRUE);
   dbms_aqadm.start_queue('SYS.AQ$_ALERT_QT_E', FALSE, TRUE);
   commit;
EXCEPTION
  when others then
     raise;
END;
/

-- Create an AQ agent to be used to enqueue alert messages
BEGIN
    DECLARE
      agent SYS.AQ$_AGENT;
    BEGIN
      agent := SYS.AQ$_AGENT('server_alert', NULL, NULL);
      dbms_aqadm.create_aq_agent('server_alert');
    EXCEPTION
      when others then
        if sqlcode = -24089 then NULL;
        else raise;
        end if;
    END;
    dbms_aqadm.enable_db_access('server_alert', 'SYS');
EXCEPTION
  when others then raise;
END;
/
