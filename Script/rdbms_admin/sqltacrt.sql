Rem
Rem $Header: sqltacrt.sql 04-apr-2006.18:35:24 pbelknap Exp $
Rem
Rem sqltacrt.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sqltacrt.sql - SQL Tuning advisor Automatic task CReaTe
Rem
Rem    DESCRIPTION
Rem      This script creates the automatic SQL Tuning task.  It is invoked
Rem      during database creation by catproc (catsvrm) and can be called by the
Rem      user to re-create the task after deleting it.
Rem
Rem      This script must be invoked by SYS.  It creates a task named 
Rem      AUTO_SQL_TUNING_TASK.  If that task already exists, this script will
Rem      error and the user should first delete the existing task by calling
Rem      dbms_advisor.delete_task.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    04/04/06 - automatic tuning task creation 
Rem    pbelknap    04/04/06 - automatic tuning task creation 
Rem    pbelknap    04/04/06 - Created
Rem

--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                       ------------------------------                       --
--                       AUTOMATIC TUNING TASK CREATION                       --
--                       ------------------------------                       --
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

exec sys.dbms_sqltune_internal.i_create_auto_tuning_task;
