Rem
Rem $Header: rdbms/admin/catratmask.sql /st_rdbms_11.2.0/1 2012/08/01 16:35:42 shjoshi Exp $
Rem
Rem catratmask.sql
Rem
Rem Copyright (c) 2010, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catratmask.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shjoshi     06/15/11 - Add wri$_sts_masking_errors
Rem    sburanaw    12/08/10 - add wri$_masking_errors
Rem    shjoshi     11/24/10 - Add table wri$_sts_masking_exceptions
Rem    shjoshi     11/24/10 - Add script_id to wri$_sts_masking_step_progress
Rem    sburanaw    11/24/10 - sync with catsqlt.sql
Rem    shjoshi     10/28/10 - Add flags and masked_binds_flags to
Rem                           wri$_sqlset_plans
Rem    shjoshi     08/05/10 - Add schema tables for RAT masking
Rem    sburanaw    11/21/10 - Created
Rem


-
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--                    --------------------------------                       --
--                     RAT MASKING SCHEMA DEFINITION                         --
--                    --------------------------------                       --
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
--+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

----------------------------- WRR$_MASKING_DEFINITION -------------------------
-- NAME:
--     WRR$_MASKING_DEFINITION
--
--  DESCRIPTION:
--     This table contains names of all sensitive columns as specified in a 
--     masking script.
--
--  PRIMARY KEY:
--     NONE
--
--------------------------------------------------------------------------------
CREATE TABLE wrr$_masking_definition
(  
  script_id   number,
  owner_name  varchar2(30), 
  table_name  varchar2(30), 
  column_name varchar2(30), 
  columngroup number
)
/

----------------------------- WRR$_MASKING_PARAMETERS -------------------------
-- NAME:
--     WRR$_MASKING_PARAMETERS
--
--  DESCRIPTION:
--     This table contains names and values of masking parameters as specified
--     in a masking script.
--
--  PRIMARY KEY:
--     (script_id, name)
--
--------------------------------------------------------------------------------
CREATE TABLE wrr$_masking_parameters 
(
  script_id  number,
  name       varchar2(30), 
  value      varchar2(4000), 
  datatype   number,
  constraint  WRR$_MASKING_PARAMETERS_PK primary key (script_id, name)
)
/

------------------------------- WRI$_STS_GRANULES ------------------------------
-- NAME:
--     WRI$_STS_GRANULES
--
--  DESCRIPTION:
--     This table contains a subset of the SQLs in a SQL tuning set partitioned
--     by the sql seq#. For RAT masking, it represents a list of work granules
--     with one row per work granule per slave
--
--  PRIMARY KEY:
--     None.  
--
--------------------------------------------------------------------------------
CREATE TABLE WRI$_STS_GRANULES 
(
  script_id      number,
  sqlset_name    varchar2(30), 
  sqlset_owner   varchar2(30), 
  start_sql_seq  number, 
  end_sql_seq    number, 
  server_id      number, 
  granule_number number
)
/

----------------------------- WRI$_STS_SENSITIVE_SQL --------------------------
-- NAME:
--     WRI$_STS_SENSITIVE_SQL
--
--  DESCRIPTION:
--     This table contains a one row for each stmt of an STS that contains 
--     at least one sensitive bind value. The stmt is identified by the stmt_id
--     column of an STS. It will be populated during the extract phase of rat
--     masking and cleared after the replace phase is complete.
--
--  PRIMARY KEY:
--     (script_id, stmt_id)
--
--------------------------------------------------------------------------------
CREATE TABLE WRI$_STS_SENSITIVE_SQL
(
  SCRIPT_ID            NUMBER,
  STMT_ID              NUMBER,
  NUM_SENSITIVE_BINDS  NUMBER,
  constraint  WRI$_STS_SENSITIVE_SQL_PK primary key (script_id, stmt_id)
)
/

--------------------------- WRI$_MASKING_SCRIPT_PROGRESS ----------------------
-- NAME:
--     WRI$_MASKING_SCRIPT_PROGRESS
--
--  DESCRIPTION:
--     This table is created to track the progress of execution of a masking 
--     script. The table will have a row for a step id n after that step 
--     completes its execution.
--
--  PRIMARY KEY:
--     NONE
--
--------------------------------------------------------------------------------
CREATE TABLE WRI$_MASKING_SCRIPT_PROGRESS
(
  SCRIPT_ID            NUMBER,
  STEP_ID              NUMBER
)
/

--------------------------- WRI$_STS_MASKING_STEP_PROGRESS --------------------
-- NAME:
--     WRI$_STS_MASKING_STEP_PROGRESS
--
--  DESCRIPTION:
--     This table is created to track the progress of execution of a masking 
--     script, specifically when STSes are being masked. As soon as a sql with
--     a particular stmt_id is processed, a row is inserted in this table to 
--     reflect this. It is helpful for resuming an interrupted masking run.
--
--  PRIMARY KEY:
--     NONE
--
--------------------------------------------------------------------------------
CREATE TABLE WRI$_STS_MASKING_STEP_PROGRESS
(
  SCRIPT_ID            NUMBER,
  STEP_ID              NUMBER,
  STMT_ID              NUMBER
)
/

---------------------------- WRR$_MASKING_FILE_PROGRESS -----------------------
-- NAME:
--     WRR$_MASKING_FILE_PROGRESS
--
--  DESCRIPTION:
--     This table is created to track the progress of execution of a masking 
--     script, specifically when workload capture files are being masked. 
--     As soon as a record is processed, a row is inserted in this table to 
--     reflect this. It is helpful for resuming an interrupted masking run.
--
--  PRIMARY KEY:
--     NONE
--
--------------------------------------------------------------------------------
CREATE TABLE WRR$_MASKING_FILE_PROGRESS
(
  SCRIPT_ID            NUMBER,
  REC_NAME             VARCHAR2(50)
)
/

----------------------------- WRR$_MASKING_BIND_CACHE -------------------------
-- NAME:
--     WRR$_MASKING_BIND_CACHE
--
--  DESCRIPTION:
--    This table maintains a cache of sqls that were found to be sensitive
--    during the extract phase of rat masking. It stores info about sensitive
--     sqls from capture files.
--
--  PRIMARY KEY:
--     NONE
--
--------------------------------------------------------------------------------
CREATE TABLE WRR$_MASKING_BIND_CACHE
(
  SCRIPT_ID            NUMBER,
  SQL_ID               NUMBER,
  SENSITIVE_COUNT      NUMBER
)
/

------------------------------ WRI$_STS_MASKING_ERRORS ------------------------
-- NAME:
--     WRI$_STS_MASKING_ERRORS
--
--  DESCRIPTION:
--    This table records errors that are encountered while running a masking
--    script to mask STSes. Whenever an error is encountered while processing
--    a stmt in an STS, that error is recorded in this table and the script 
--    moves on to the next stmt in the STS. It is created to help generate a
--     log of masking.
--
--  PRIMARY KEY:
--     NONE
--
-------------------------------------------------------------------------------
CREATE TABLE WRI$_STS_MASKING_ERRORS
(
  SCRIPT_ID            NUMBER,
  STMT_ID              NUMBER,
  ERROR_NUMBER         NUMBER
)
/

------------------------------ WRI$_STS_MASKING_EXCEPTIONS --------------------
-- NAME:
--     WRI$_STS_MASKING_EXCEPTIONS
--
--  DESCRIPTION:
--    This table records any exceptions that are encountered while masking
--    STSes. RAT Masking will terminate when such exceptions are encountered. 
--    It is created to help generate a log of masking.
--
--  PRIMARY KEY:
--     NONE
--
--------------------------------------------------------------------------------
CREATE TABLE WRI$_STS_MASKING_EXCEPTIONS
(
  script_id        number,
  error_number     number
)
/


-- for selecting ranges of contiguous stmt ids
CREATE SEQUENCE WRI$_SQLSET_RATMASK_SEQ
  INCREMENT BY 1
  START WITH 1
  NOMAXVALUE
  CACHE 100
  NOCYCLE
/

commit;
