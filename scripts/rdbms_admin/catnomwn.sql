Rem
Rem $Header: catnomwn.sql 12-jun-2003.15:38:01 jxchen Exp $
Rem
Rem catnomwn.sql
Rem
Rem Copyright (c) 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catnomwn.sql - Remove Maintenance WiNdow Definition
Rem
Rem    DESCRIPTION
Rem      Catalog script for maintenance window.  Used to drop maintenance 
Rem      window definition.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jxchen      06/12/03 - Drop job
Rem    jxchen      06/04/03 - jxchen_mwin_main
Rem    jxchen      05/13/03 - Created
Rem

exec dbms_scheduler.drop_job('gather_stats_job');
execute dbms_scheduler.drop_window_group('MAINTENANCE_WINDOW_GROUP');
execute dbms_scheduler.drop_window('WEEKEND_WINDOW');
execute dbms_scheduler.drop_window('WEEKNIGHT_WINDOW');
execute dbms_scheduler.drop_program('gather_stats_prog');
execute dbms_scheduler.drop_job_class('AUTO_TASKS_JOB_CLASS');
execute dbms_resource_manager.create_pending_area;
execute dbms_resource_manager.delete_consumer_group('AUTO_TASK_CONSUMER_GROUP');
execute dbms_resource_manager.submit_pending_area;
