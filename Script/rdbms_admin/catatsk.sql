Rem
Rem $Header: catatsk.sql 06-nov-2006.16:51:48 ilistvin Exp $
Rem
Rem catatsk.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catatsk.sql - Catalog Script for Automated Maintenance Tasks
Rem
Rem    DESCRIPTION
Rem      Creates tables, sequence, type and queue for AUTOTASK (ket)
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ilistvin    11/06/06 - 
Rem    rburns      09/16/06 - split for new catproc
Rem    ilistvin    11/21/06 - make ket_window_list type public
Rem    ilistvin    09/27/06 - add dba_autotask_job_history view
Rem    ilistvin    09/15/06 - fix dba_autotask_client view
Rem    ilistvin    08/21/06 - use correct AUTOTASK_HIGH_SUB_PLAN plan name
Rem    ilistvin    06/21/06 - make history views look at all prior windows 
Rem    ilistvin    03/08/06 - Automated maintenance task schema creation. 
Rem    ilistvin    03/08/06 - Created
Rem

-- Table containing current autotask status
CREATE TABLE KET$_AUTOTASK_STATUS (
     DUMMY_KEY         NUMBER CONSTRAINT KETSTATUS_UQ UNIQUE,
     AUTOTASK_STATUS   NUMBER,         -- 2 enabled, 1 - disabled
     ABA_STATE         NUMBER,         -- ABA Processing State
     ABA_STATE_TIME    TIMESTAMP WITH
                         TIME ZONE,
     ABA_OS_PID        VARCHAR2 (64),  -- ABA Process Id
     ABA_START_TIME    TIMESTAMP WITH
                         TIME ZONE,
     MW_NAME           VARCHAR2 (64),  -- Current Maintenance Window Name
     MW_START_TIME     TIMESTAMP WITH
                         TIME ZONE,    -- Current MW Window Start Time
     MW_RECORD_TIME    TIMESTAMP WITH
                         TIME ZONE,    -- Time MW information recorded
     INSTANCE_NAME     VARCHAR2 (16),  -- Recording instance SID
     RECONCILE_TIME    TIMESTAMP WITH 
                         TIME ZONE     -- Last Repository Reconciliation
     )  
     TABLESPACE SYSAUX;

-- Create configuration table
CREATE TABLE KET$_CLIENT_CONFIG (
      CLIENT_ID          NUMBER,             -- 0 for AUTOTASK Configuration
      OPERATION_ID       NUMBER,             -- 0 for Client Configuration
      STATUS             NUMBER DEFAULT 1,   -- 2 enabled, 1 - disabled, others
      ATTRIBUTES         NUMBER DEFAULT 0,   -- attribute flags
      PRIORITY_OVERRIDE  NUMBER DEFAULT 0,   -- 1 -medium, 2 - high, 3 - urgent
      LAST_CHANGE        TIMESTAMP WITH 
                           TIME ZONE 
                         DEFAULT SYSTIMESTAMP,     -- last change timestamp
      SERVICE_NAME       VARCHAR2 (64) 
                           DEFAULT NULL, -- Service Affinity
      GENERATOR_JOB_NAME VARCHAR2 (64) 
                           DEFAULT NULL, -- Name of Task List Generator job
      FIELD_1            NUMBER,         -- Spare field
      FIELD_2            TIMESTAMP WITH 
                           TIME ZONE,     -- Spare field
      FIELD_3            VARCHAR2(2000)
                            DEFAULT NULL, -- Spare field
      CONSTRAINT KET$_CL_PK 
         PRIMARY KEY (OPERATION_ID, CLIENT_ID) 
         USING INDEX TABLESPACE SYSAUX)
  TABLESPACE SYSAUX;

-- Create main repository table
CREATE TABLE KET$_CLIENT_TASKS (
      CLIENT_ID           NUMBER,
      OPERATION_ID        NUMBER,
      TARGET_TYPE         NUMBER,
      TARGET_NAME         VARCHAR2(513),
      ATTRIBUTES          NUMBER DEFAULT 0, -- attribute mask
      ATTRIBUTES_OVERRIDE NUMBER DEFAULT 0, -- attribute mask or NULL
      TASK_PRIORITY       NUMBER DEFAULT 0, -- 1:medium, 2:high, 3:urgent
      PRIORITY_OVERRIDE   NUMBER DEFAULT 0, -- 1:medium, 2:high, 3:urgent
      STATUS              NUMBER DEFAULT 0, -- 1:disabled, 2:enabled, 13:defer
      --
      -- Task Arguments
      --
      ARG_4               VARCHAR2(1024),  -- argument 4
      ARG_5               VARCHAR2(1024),  -- argument 5
      ARG_6               VARCHAR2(1024),  -- argument 6  
      WINDOW_NAME         VARCHAR2(65),    -- if STATUS == 13, deferred to
      CURR_JOB_NAME       VARCHAR2(65),    -- May be NULL if no current job
      CURR_WIN_START      TIMESTAMP WITH TIME ZONE, -- current MW
      --
      -- EST - Estimated resource usage
      --
      EST_TYPE            NUMBER DEfAULT 0, 
                               -- 0: none, 1 : derived, 2: forced, 3: locked
      EST_WEIGHT          NUMBER,
      EST_DURATION        NUMBER,
      EST_CPU_TIME        NUMBER,
      EST_TEMP            NUMBER,
      EST_DOP             NUMBER,
      EST_IO_RATE         NUMBER,
      EST_UNDO_RATE       NUMBER,
      RETRY_COUNT         NUMBER DEFAULT 0,  -- number of failure retries
      GOOD_COUNT          NUMBER DEFAULT 0,
      --
      -- LG - data for Last Good (non-failure) run
      --
      LG_JOB_LOG_ID       NUMBER DEFAULT 0,  -- FK dba_scheduler_job_log
      LG_DATE             TIMESTAMP WITH TIME ZONE,
      LG_PRIORITY         NUMBER,      -- task priority
      LG_DURATION         NUMBER,      -- duration of job
      LG_CPU_TIME         NUMBER,      -- CPU time consumed
      LG_TEMP             NUMBER,      -- max Temp Space used
      LG_DOP              NUMBER,      -- max DOP used
      LG_IO_RATE          NUMBER,      -- mean I/O rate
      LG_UNDO_RATE        NUMBER,      -- undo generation rate
      LG_CPU_WAIT         NUMBER,      -- cumulative CPU wait
      LG_IO_WAIT          NUMBER,      -- cumulativeI/O Wait
      LG_UNDO_WAIT        NUMBER,      -- undo wait
      LG_TEMP_WAIT        NUMBER,      -- temp space wait
      LG_CONCURRENCY      NUMBER,      -- concurrency wait
      LG_CONTENTION       NUMBER,      -- contention wait
      --
      -- LT - data from the Last Try (successful or not)
      --
      Lt_JOB_LOG_ID       NUMBER DEFAULT 0, -- FK dba_scheduler_job_log
      LT_DATE             TIMESTAMP WITH TIME ZONE,
      LT_PRIORITY         NUMBER DEFAULT 0, -- Priority at last try
      LT_TERM_CODE        NUMBER DEFAULT 0, -- 10, 11, 12, 13, 14, 15
      LT_ERROR            NUMBER DEFAULT 0, -- error from last try
      --
      -- Last Try stats
      LT_DURATION         NUMBER,      -- elapsed time of last try
      LT_CPU_TIME         NUMBER,      -- CPU time consumed
      LT_TEMP             NUMBER,      -- max Temp Space used
      LT_DOP              NUMBER,      -- max DOP used
      LT_IO_RATE          NUMBER,      -- mean I/O rate
      LT_UNDO_RATE        NUMBER,   
      LT_CPU_WAIT         NUMBER,
      LT_IO_WAIT          NUMBER,
      LT_UNDO_WAIT        NUMBER,
      LT_TEMP_WAIT        NUMBER,
      LT_CONCURRENCY      NUMBER,
      LT_CONTENTION       NUMBER,
      --
      -- MG - Averaged (Mean) Good run stats 
      --
      MG_DURATION         NUMBER DEFAULT 0,      -- elapsed time
      MG_CPU_TIME         NUMBER DEFAULT 0,
      MG_TEMP             NUMBER DEFAULT 0,
      MG_DOP              NUMBER DEFAULT 0,
      MG_IO_RATE          NUMBER DEFAULT 0,
      MG_UNDO_RATE        NUMBER DEFAULT 0,
      MG_CPU_WAIT         NUMBER DEFAULT 0,
      MG_IO_WAIT          NUMBER DEFAULT 0,
      MG_UNDO_WAIT        NUMBER DEFAULT 0,
      MG_TEMP_WAIT        NUMBER DEFAULT 0,
      MG_CONCURRENCY      NUMBER DEFAULT 0,
      MG_CONTENTION       NUMBER DEFAULT 0,
      --
      -- Fields that may be used by Clients to store task-related data
      --
      INFO_FIELD_1        VARCHAR2 (4000),
      INFO_FIELD_2        CLOB,
      INFO_FIELD_3        NUMBER,
      INFO_FIELD_4        NUMBER,
      CONSTRAINT KET$_TSK_PK 
        PRIMARY KEY (CLIENT_ID, OPERATION_ID, TARGET_TYPE, TARGET_NAME)
      USING INDEX TABLESPACE SYSAUX
     )
    TABLESPACE SYSAUX;
--
-- Types used by dbms_auto_task.get_schedule_date
--      
CREATE OR REPLACE TYPE ket$_window_type IS OBJECT (
   window_name   VARCHAR2(30),
   start_time    TIMESTAMP WITH TIME ZONE,
   duration      INTERVAL DAY TO SECOND)
/
CREATE OR REPLACE TYPE ket$_window_list IS TABLE OF ket$_window_type
/
grant execute on ket$_window_list to PUBLIC
/
