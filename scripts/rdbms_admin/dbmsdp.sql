Rem
Rem $Header: rdbms/admin/dbmsdp.sql /st_rdbms_11.2.0/3 2012/03/12 08:41:52 jkaloger Exp $
Rem
Rem Copyright (c) 2001, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem 
Rem    NAME
Rem     dbmsdp.sql - Package header for DBMS_DATAPUMP.
Rem     NOTE - Package body is in:
Rem            /vobs/rdbms/src/server/datapump/api/prvtdp.sql
Rem    DESCRIPTION
Rem     This file contains the public interface for the DataPump API.
Rem     The package body is to be released only in PL/SQL binary form.
Rem
Rem    PUBLIC FUNCTIONS / PROCEDURES
Rem     ADD_DEVICE        - Specifies a sequential device for the dump file set
Rem     ADD_FILE          - Specifies a file for the dump file set 
Rem     ATTACH            - Allows a user session to monitor/control a job
Rem     DATA_FILTER       - Constrains data processed by a job
Rem     DATA_REMAP        - Modifies data processed by a job
Rem     DETACH            - Disconnects a user session from a job
Rem     GET_DUMPFILE_INFO - Retrieve information about a dumpfile
Rem     GET_STATUS        - Obtains the current status of a job
Rem     LOG_ENTRY         - Adds an entry to the log file
Rem     METADATA_FILTER   - Constrains metadata processed by a job
Rem     METADATA_REMAP    - Remaps metadata processed by a job
Rem     METADATA_TRANSFORM - Transforms metadata processed by a job
Rem     OPEN              - Creates a new job
Rem     SET_PARALLEL      - Specifies the parallelism for the job
Rem     SET_PARAMETER     - Alters default processing by a job
Rem     START_JOB         - Starts or restarts a job
Rem     STOP_JOB          - Performs an orderly shutdown of a job
Rem     WAIT_FOR_JOB      - Wait for job to terminate and return to caller
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     apfwkr    03/02/12  - Backport jkaloger_bug-13724931 from main
Rem     gclaborn  02/17/11  - Add new import callout flag defs
Rem     gclaborn  09/21/10  - add flags for import callout registrations
Rem     jkaloger  04/12/10  - BUG:9571351 - allow Terabyte unit for FILESIZE
Rem     sdipirro  12/30/08  - Establish_remote_context needs to establish
Rem                           context for kuppwami also
Rem     jkaloger  02/06/09  - BUG:6862260 - add DISABL_APPEND_HINT to
Rem                           data_options
Rem     jkaloger  07/30/08  - Add comment regarding data_options bits.
Rem     dgagne    06/27/08  - add as is to client_lob_append
Rem     sdipirro  10/09/07  - New RAC info in get_status
Rem     jkaloger  09/14/07  - BUG:6377844 - add some constants for 
Rem                           get_dumpfile_info
Rem     wfisher   02/06/07  - Adding support for long table name lists
Rem     wfisher   01/18/07  - Support Clobs as filter values
Rem     wfisher   05/01/06  - Adding new apis for 11g. 
Rem     jkaloger  12/07/05  - PROJECT:15995_2 - Data Layer compression 
Rem     rapayne   04/11/06  - Add data_options bitmask defs.
Rem     jkaloger  02/09/06  - BUG:4996026 - remove references to FILE_ERROR 
Rem     emagrath  10/10/05  - Rework set_debug args
Rem     jkaloger  06/14/05  - Add reuseFile parameter to ADD_FILE call 
Rem     sdipirro  05/12/05  - Param_t string needs to be bumped from 2k to 4k 
Rem     jkaloger  04/18/05  - BUG:3779917 - master table file spanning
Rem     sdipirro  01/28/05  - Fix SQL injection security bugs 
Rem     sdipirro  06/04/04  - New error for get_dumpfile_info 
Rem     jkaloger  05/18/04  - Change compression default to metadata 
Rem     sdipirro  04/20/04  - Add global_name to jobdesc1020, dump file 
Rem                           info API, and compression parameter to open
Rem     sdipirro  04/07/04  - Change metadata_filter object_type to object_path
Rem     sdipirro  03/05/04  - Tablespace rack info in job_desc 
Rem     sdipirro  11/13/03  - Negotiate version for network mode get_status 
Rem     sdipirro  09/26/03  - Get_status timeout should default 
Rem     sdipirro  08/12/03  - Get_status and log_error API changes/additions
Rem     sdipirro  05/15/03  - Add interfaces to establish remote job context
Rem     rapayne   03/24/03  - Add REMOTE_LINK, LOG_FILE and SQL_FILE to 
Rem                           KU$_JOBDESC object.
Rem     wfisher   03/21/03  - Moving remote link to OPEN API
Rem     sdipirro  03/14/03  - Change stop_job default delay
Rem     sdipirro  02/10/03  - Add total bytes and restart count to job
Rem                           status object
Rem     sdipirro  11/19/02  - Cleanup obsolete types from DataPump emulation
Rem     sdipirro  09/30/02  - Incorporate code review comments
Rem     sdipirro  09/27/02  - Changes to dumpfile get_status object
Rem     sdipirro  09/24/02  - Another error message pass
Rem     sdipirro  09/16/02  - Fixup get_status comments
Rem     sdipirro  08/28/02  - New parameters for add_file and log_entry
Rem     dgagne    08/28/02  - add support for jdeveloper
Rem     sdipirro  08/06/02  - Add undocumented wrapper for priv check
Rem     rapayne   07/19/02  - change object_name size to 4000
Rem                         - change object_type_path size to 200 
Rem     sdipirro  06/28/02  - Next round of changes to status object defs
Rem     sdipirro  06/21/02  - Exception number consistency with e29250.msg
Rem     sdipirro  05/23/02  - BL1 integration with fixed view code
Rem     sdipirro  05/07/02  - Update start_job interface
Rem     sdipirro  04/30/02  - Update priv names
Rem     sdipirro  04/23/02  - Fix error/exception message usage.
Rem     gclaborn  04/19/02  - gclaborn_headersbl0
Rem     sdipirro  04/16/02 -  All changes required for BL0 checkin
Rem     sdipirro  02/28/02 -  Creation
Rem

-------------------------------------------------------------------------------
-- Types used by the DBMS_DATAPUMP interface:
---------------------------------------------
-- The following types are used in the interface to the DataPump API, primarily
-- with the DBMS_DATAPUMP.GET_STATUS interface, which can return several
-- different objects and embedded objects as the returned job status data.
-- The worker status types describe what each worker process is doing,
-- supplying the current schema, object name, and object type being processed.
-- For workers processing metadata, status on the last object processed
-- is provided. For workers handling user data, the partition name for
-- a partitioned table (if any), the number of bytes processed in the
-- partition, the number of rows processed, and the number of errors detected
-- in the partition are returned. There is no status provided on idle workers.

-- API object definitions follow
-- The following object type definitions are for objects that are public
-- to the DBMS_DATAPUMP package, primarily for the get_status API, but some
-- of the types are used in the message definitions and, so, need to be
-- defined first.

-- Worker (MCP worker process) status types

CREATE TYPE sys.ku$_WorkerStatus1010 AS OBJECT
        (
                worker_number     NUMBER,       -- Worker process identifier
                process_name      VARCHAR2(30), -- Worker process name
                state             VARCHAR2(30), -- Worker process state
                schema            VARCHAR2(30), -- Schema name
                name              VARCHAR2(4000),-- Object name
                object_type       VARCHAR2(200),-- Object type
                partition         VARCHAR2(30), -- Partition name
                completed_objects NUMBER,       -- Completed number of objects
                total_objects     NUMBER,       -- Total number of objects
                completed_rows    NUMBER,       -- Number of rows completed
                completed_bytes   NUMBER,       -- Number of bytes completed
                percent_done      NUMBER        -- Percent done current object
        )
/

GRANT EXECUTE ON sys.ku$_WorkerStatus1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_WorkerStatus1010
  FOR sys.ku$_WorkerStatus1010;

CREATE TYPE sys.ku$_WorkerStatus1020 AS OBJECT
        (
                worker_number     NUMBER,       -- Worker process identifier
                process_name      VARCHAR2(30), -- Worker process name
                state             VARCHAR2(30), -- Worker process state
                schema            VARCHAR2(30), -- Schema name
                name              VARCHAR2(4000),-- Object name
                object_type       VARCHAR2(200),-- Object type
                partition         VARCHAR2(30), -- Partition name
                completed_objects NUMBER,       -- Completed number of objects
                total_objects     NUMBER,       -- Total number of objects
                completed_rows    NUMBER,       -- Number of rows completed
                completed_bytes   NUMBER,       -- Number of bytes completed
                percent_done      NUMBER,       -- Percent done current object
                degree            NUMBER        -- Degree of parallelism
        )
/

GRANT EXECUTE ON sys.ku$_WorkerStatus1020 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_WorkerStatus1020
  FOR sys.ku$_WorkerStatus1020;

CREATE TYPE sys.ku$_WorkerStatus1120 AS OBJECT
        (
                worker_number     NUMBER,       -- Worker process identifier
                process_name      VARCHAR2(30), -- Worker process name
                state             VARCHAR2(30), -- Worker process state
                schema            VARCHAR2(30), -- Schema name
                name              VARCHAR2(4000),-- Object name
                object_type       VARCHAR2(200),-- Object type
                partition         VARCHAR2(30), -- Partition name
                completed_objects NUMBER,       -- Completed number of objects
                total_objects     NUMBER,       -- Total number of objects
                completed_rows    NUMBER,       -- Number of rows completed
                completed_bytes   NUMBER,       -- Number of bytes completed
                percent_done      NUMBER,       -- Percent done current object
                degree            NUMBER,       -- Degree of parallelism
                instance_id       NUMBER        -- Instance ID where running
        )
/

GRANT EXECUTE ON sys.ku$_WorkerStatus1120 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_WorkerStatus1120
  FOR sys.ku$_WorkerStatus1120;

CREATE OR REPLACE PUBLIC SYNONYM ku$_WorkerStatus FOR ku$_WorkerStatus1120;

CREATE TYPE sys.ku$_WorkerStatusList1010 AS TABLE OF sys.ku$_WorkerStatus1010
/
CREATE TYPE sys.ku$_WorkerStatusList1020 AS TABLE OF sys.ku$_WorkerStatus1020
/
CREATE TYPE sys.ku$_WorkerStatusList1120 AS TABLE OF sys.ku$_WorkerStatus1120
/
GRANT EXECUTE ON sys.ku$_WorkerStatusList1010 TO PUBLIC; 
GRANT EXECUTE ON sys.ku$_WorkerStatusList1020 TO PUBLIC; 
GRANT EXECUTE ON sys.ku$_WorkerStatusList1120 TO PUBLIC; 

CREATE OR REPLACE PUBLIC SYNONYM ku$_WorkerStatusList1010
  FOR sys.ku$_WorkerStatusList1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_WorkerStatusList1020
  FOR sys.ku$_WorkerStatusList1020;
CREATE OR REPLACE PUBLIC SYNONYM ku$_WorkerStatusList1120
  FOR sys.ku$_WorkerStatusList1120;

CREATE OR REPLACE PUBLIC SYNONYM ku$_WorkerStatusList
  FOR ku$_WorkerStatusList1120;

CREATE TYPE sys.ku$_DumpFile1010 IS OBJECT
        (
                file_name           VARCHAR2(4000),   -- Fully-qualified name
                file_type           NUMBER,           -- 0=Disk, 1=Pipe, etc.
                file_size           NUMBER,           -- Its length in bytes
                file_bytes_written  NUMBER            -- Bytes written so far
        )
/

GRANT EXECUTE ON sys.ku$_DumpFile1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_DumpFile1010 FOR sys.ku$_DumpFile1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_DumpFile1020 FOR sys.ku$_DumpFile1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_DumpFile FOR ku$_DumpFile1010;

CREATE TYPE sys.ku$_DumpFileSet1010 AS TABLE OF sys.ku$_DumpFile1010
/

GRANT EXECUTE ON sys.ku$_DumpFileSet1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_DumpFileSet1010 FOR 
  sys.ku$_DumpFileSet1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_DumpFileSet1020 FOR 
  sys.ku$_DumpFileSet1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_DumpFileSet FOR ku$_DumpFileSet1010;

-- Log entry types provide a monitoring program with a description of log file
-- entries created by the executing job. The errorNumber parameter is null for
-- informational messages but a non null value for error messages. Each log
-- entry may contain several lines of text messages.

CREATE TYPE sys.ku$_LogLine1010 IS OBJECT
        (
                logLineNumber   NUMBER,                 -- Line # in log file
                errorNumber     NUMBER,                 -- Error number
                LogText         VARCHAR2(2000)          -- Log entry text
        )
/

GRANT EXECUTE ON sys.ku$_LogLine1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_LogLine1010 FOR sys.ku$_LogLine1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_LogLine1020 FOR sys.ku$_LogLine1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_LogLine FOR ku$_LogLine1010;

CREATE TYPE sys.ku$_LogEntry1010 AS TABLE OF sys.ku$_LogLine1010
/

GRANT EXECUTE ON sys.ku$_LogEntry1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_LogEntry1010 FOR sys.ku$_LogEntry1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_LogEntry1020 FOR sys.ku$_LogEntry1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_LogEntry FOR ku$_LogEntry1010;

-- The job status types are used to describe information about a running
-- job through the DBMS_DATAPUMP.GET_STATUS API.

CREATE TYPE sys.ku$_JobStatus1010 IS OBJECT
        (
                job_name        VARCHAR2(30),           -- Name of the job
                operation       VARCHAR2(30),           -- Current operation
                job_mode        VARCHAR2(30),           -- Current mode
                bytes_processed NUMBER,                 -- Bytes so far
                total_bytes     NUMBER,                 -- Total bytes for job
                percent_done    NUMBER,                 -- Percent done
                degree          NUMBER,                 -- Of job parallelism
                error_count     NUMBER,                 -- #errors so far
                state           VARCHAR2(30),           -- Current job state
                phase           NUMBER,                 -- Job phase
                restart_count   NUMBER,                 -- #Job restarts
                worker_status_list ku$_WorkerStatusList1010, -- For (non-idle)
                                                        -- job worker processes
                files           ku$_DumpFileSet1010     -- Dump file info
        )
/

GRANT EXECUTE ON sys.ku$_JobStatus1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_JobStatus1010 FOR sys.ku$_JobStatus1010;

CREATE TYPE sys.ku$_JobStatus1020 IS OBJECT
        (
                job_name        VARCHAR2(30),           -- Name of the job
                operation       VARCHAR2(30),           -- Current operation
                job_mode        VARCHAR2(30),           -- Current mode
                bytes_processed NUMBER,                 -- Bytes so far
                total_bytes     NUMBER,                 -- Total bytes for job
                percent_done    NUMBER,                 -- Percent done
                degree          NUMBER,                 -- Of job parallelism
                error_count     NUMBER,                 -- #errors so far
                state           VARCHAR2(30),           -- Current job state
                phase           NUMBER,                 -- Job phase
                restart_count   NUMBER,                 -- #Job restarts
                worker_status_list ku$_WorkerStatusList1020, -- For (non-idle)
                                                        -- job worker processes
                files           ku$_DumpFileSet1010     -- Dump file info
        )
/

GRANT EXECUTE ON sys.ku$_JobStatus1020 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_JobStatus1020 FOR sys.ku$_JobStatus1020;

CREATE TYPE sys.ku$_JobStatus1120 IS OBJECT
        (
                job_name        VARCHAR2(30),           -- Name of the job
                operation       VARCHAR2(30),           -- Current operation
                job_mode        VARCHAR2(30),           -- Current mode
                bytes_processed NUMBER,                 -- Bytes so far
                total_bytes     NUMBER,                 -- Total bytes for job
                percent_done    NUMBER,                 -- Percent done
                degree          NUMBER,                 -- Of job parallelism
                error_count     NUMBER,                 -- #errors so far
                state           VARCHAR2(30),           -- Current job state
                phase           NUMBER,                 -- Job phase
                restart_count   NUMBER,                 -- #Job restarts
                worker_status_list ku$_WorkerStatusList1120, -- For (non-idle)
                                                        -- job worker processes
                files           ku$_DumpFileSet1010     -- Dump file info
        )
/

GRANT EXECUTE ON sys.ku$_JobStatus1120 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_JobStatus1120 FOR sys.ku$_JobStatus1120;

CREATE OR REPLACE PUBLIC SYNONYM ku$_JobStatus FOR ku$_JobStatus1120;

-- The job description types are used to describe "environmental" information
-- about a running job through the DBMS_DATAPUMP.GET_STATUS API.

CREATE TYPE sys.ku$_ParamValue1010 IS OBJECT
        (
                param_name      VARCHAR2(30),           -- Parameter name
                param_op        VARCHAR2(30),           -- Param operation
                param_type      VARCHAR2(30),           -- Its type
                param_length    NUMBER,                 -- Its length in bytes
                param_value_n   NUMBER,                 -- Numeric value
                param_value_t   VARCHAR2(4000)          -- And its text value
        )
/

GRANT EXECUTE ON sys.ku$_ParamValue1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_ParamValue1010 FOR sys.ku$_ParamValue1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ParamValue1020 FOR sys.ku$_ParamValue1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ParamValue FOR ku$_ParamValue1010;

CREATE TYPE sys.ku$_ParamValues1010 AS TABLE OF sys.ku$_ParamValue1010
/

GRANT EXECUTE ON sys.ku$_ParamValues1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_ParamValues1010 FOR 
  sys.ku$_ParamValues1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ParamValues1020 FOR 
  sys.ku$_ParamValues1010;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ParamValues FOR ku$_ParamValues1010;

CREATE TYPE sys.ku$_JobDesc1010 IS OBJECT
        (
                job_name        VARCHAR2(30),           -- The job name
                guid            RAW(16),                -- The job GUID
                operation       VARCHAR2(30),           -- Current operation
                job_mode        VARCHAR2(30),           -- Current mode
                remote_link     VARCHAR2(4000),         -- DB link, if any
                owner           VARCHAR2(30),           -- Job owner
                instance        VARCHAR2(16),           -- The instance name
                db_version      VARCHAR2(30),           -- Version of objects
                creator_privs   VARCHAR2(30),           -- Privs of job
                start_time      DATE,                   -- This job start time
                max_degree      NUMBER,                 -- Max. parallelism
                log_file        VARCHAR2(4000),         -- Log file name
                sql_file        VARCHAR2(4000),         -- SQL file name
                params          ku$_ParamValues1010     -- Parameter list
        )
/

GRANT EXECUTE ON sys.ku$_JobDesc1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_JobDesc1010 FOR sys.ku$_JobDesc1010;

CREATE TYPE sys.ku$_JobDesc1020 IS OBJECT
        (
                job_name        VARCHAR2(30),           -- The job name
                guid            RAW(16),                -- The job GUID
                operation       VARCHAR2(30),           -- Current operation
                job_mode        VARCHAR2(30),           -- Current mode
                remote_link     VARCHAR2(4000),         -- DB link, if any
                owner           VARCHAR2(30),           -- Job owner
                platform        VARCHAR2(101),          -- Current job platform
                exp_platform    VARCHAR2(101),          -- Export platform
                global_name     VARCHAR2(4000),         -- Current global name
                exp_global_name VARCHAR2(4000),         -- Export global name
                instance        VARCHAR2(16),           -- The instance name
                db_version      VARCHAR2(30),           -- Version of objects
                exp_db_version  VARCHAR2(30),           -- Export version
                scn             NUMBER,                 -- Job SCN   
                creator_privs   VARCHAR2(30),           -- Privs of job
                start_time      DATE,                   -- This job start time
                exp_start_time  DATE,                   -- Export start time
                term_reason     NUMBER,                 -- Job termination code
                max_degree      NUMBER,                 -- Max. parallelism
                log_file        VARCHAR2(4000),         -- Log file name
                sql_file        VARCHAR2(4000),         -- SQL file name
                params          ku$_ParamValues1010     -- Parameter list
        )
/

GRANT EXECUTE ON sys.ku$_JobDesc1020 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_JobDesc1020 FOR sys.ku$_JobDesc1020;

CREATE OR REPLACE PUBLIC SYNONYM ku$_JobDesc FOR ku$_JobDesc1020;

CREATE TYPE sys.ku$_Status1010 IS OBJECT
        (
                mask            NUMBER,           -- Status types present
                wip             ku$_LogEntry1010, -- Work in progress
                job_description ku$_JobDesc1010,  -- Complete job description
                job_status      ku$_JobStatus1010,-- Detailed job status
                error           ku$_LogEntry1010  -- Multi-level context errors
        )
/

GRANT EXECUTE ON sys.ku$_Status1010 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_Status1010 FOR sys.ku$_Status1010;

CREATE TYPE sys.ku$_Status1020 IS OBJECT
        (
                mask            NUMBER,           -- Status types present
                wip             ku$_LogEntry1010, -- Work in progress
                job_description ku$_JobDesc1020,  -- Complete job description
                job_status      ku$_JobStatus1020,-- Detailed job status
                error           ku$_LogEntry1010  -- Multi-level context errors
        )
/

GRANT EXECUTE ON sys.ku$_Status1020 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_Status1020 FOR sys.ku$_Status1020;

CREATE TYPE sys.ku$_Status1120 IS OBJECT
        (
                mask            NUMBER,           -- Status types present
                wip             ku$_LogEntry1010, -- Work in progress
                job_description ku$_JobDesc1020,  -- Complete job description
                job_status      ku$_JobStatus1120,-- Detailed job status
                error           ku$_LogEntry1010  -- Multi-level context errors
        )
/

GRANT EXECUTE ON sys.ku$_Status1120 TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_Status1120 FOR sys.ku$_Status1120;

CREATE OR REPLACE PUBLIC SYNONYM ku$_Status FOR ku$_Status1120;

-- Define types to use with the dumpfile info API

CREATE TYPE sys.ku$_dumpfile_item IS OBJECT
        (
                item_code       NUMBER,           -- Identifies header item
                value           VARCHAR2(2048)    -- Text string value
        )
/
GRANT EXECUTE ON sys.ku$_dumpfile_item TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_dumpfile_item FOR sys.ku$_dumpfile_item;

CREATE TYPE sys.ku$_dumpfile_info AS TABLE OF sys.ku$_dumpfile_item
/
GRANT EXECUTE ON sys.ku$_dumpfile_info TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM ku$_dumpfile_info FOR sys.ku$_dumpfile_info;










CREATE OR REPLACE PACKAGE dbms_datapump AUTHID CURRENT_USER AS 
---------------------------------------------------------------------
-- Overview
-- This pkg implements the DBMS_DATAPUMP API, a mechanism to allow users
-- to move all or parts of a database between databases, superseding
-- functionality previously associated with the Export and Import utilities
-- (which will now rely on the dbms_datapump interface). Dbms_datapump will
-- also support the loading and unloading of data in a proprietary format.
---------------------------------------------------------------------
-- SECURITY
-- This package is owned by SYS with execute access granted to PUBLIC.
-- It runs with invokers rights for the most part, i.e., with the security
-- profile of the caller. Two roles allow users to take full advantage of
-- the API:
-- EXP_FULL_DATABASE (only affects Export and Estimate operations) allows:
--      o Operations outside the scope of a user's schema
--      o Operations with increased parallelism
--      o Writes to log and dump files without setting up DIRECTORY objects
--        to reference their owning directories
--      o Use of sequential media within a dump file set
--      o Restarts of previously stopped jobs initiated by another user
-- IMP_FULL_DATABASE (only affects Import, Network, and Sql_file 
--        operations) allows:
--      o Operations outside the scope of their schema
--      o Operations with increased parallelism
--      o Reads to dump file sets and writes to log files without the use of
--        DIRECTORY objects
--      o Use of sequential media within the dump file set
--      o Restarts of previously stopped jobs initiated by another user
-- Note that some internal operations will run in a more privileged context.
--------------------
--  PUBLIC CONSTANTS
--
KU$_STATUS_WIP                 CONSTANT BINARY_INTEGER := 1;
KU$_STATUS_JOB_DESC            CONSTANT BINARY_INTEGER := 2;
KU$_STATUS_JOB_STATUS          CONSTANT BINARY_INTEGER := 4;
KU$_STATUS_JOB_ERROR           CONSTANT BINARY_INTEGER := 8;

KU$_FILE_TYPE_DUMP_FILE        CONSTANT BINARY_INTEGER := 1;
KU$_FILE_TYPE_BAD_FILE         CONSTANT BINARY_INTEGER := 2;
KU$_FILE_TYPE_LOG_FILE         CONSTANT BINARY_INTEGER := 3;
KU$_FILE_TYPE_SQL_FILE         CONSTANT BINARY_INTEGER := 4;

KU$_DUMPFILE_TYPE_DISK         CONSTANT BINARY_INTEGER := 0;
KU$_DUMPFILE_TYPE_PIPE         CONSTANT BINARY_INTEGER := 1;
KU$_DUMPFILE_TYPE_TAPE         CONSTANT BINARY_INTEGER := 2;
KU$_DUMPFILE_TYPE_TEMPLATE     CONSTANT BINARY_INTEGER := 3;

KU$_STATUS_VERSION_1           CONSTANT NUMBER := 1;
KU$_STATUS_VERSION_2           CONSTANT NUMBER := 2;
KU$_STATUS_VERSION_3           CONSTANT NUMBER := 3;
KU$_STATUS_VERSION             CONSTANT NUMBER := KU$_STATUS_VERSION_3;

KU$_JOB_VIEW_ALL               CONSTANT NUMBER := 0;
KU$_JOB_VIEW_TTS_TABLESPACES   CONSTANT NUMBER := 1;
KU$_JOB_VIEW_ENCCOL_TABLES     CONSTANT NUMBER := 2;

KU$_JOB_COMPLETE               CONSTANT NUMBER := 1;
KU$_JOB_COMPLETE_ERRORS        CONSTANT NUMBER := 2;
KU$_JOB_STOPPED                CONSTANT NUMBER := 3;
KU$_JOB_ABORTED                CONSTANT NUMBER := 4;

--
-- Items codes for entry in a dump file info table (of type ku$_dumpfile_info).
--
-- NOTE: For each constant defined here there is a corresponding constant
--       defined in kupf.h named KUPF_DFINFO_xxx_IDX where xxx is VERSION,
--       MASTER_PRESENT, GUID, etc. Any changes to the constants defined
--       *MUST* be reflected to those defined in kupf.h
--
KU$_DFHDR_FILE_VERSION         CONSTANT NUMBER := 1;
KU$_DFHDR_MASTER_PRESENT       CONSTANT NUMBER := 2;
KU$_DFHDR_GUID                 CONSTANT NUMBER := 3;
KU$_DFHDR_FILE_NUMBER          CONSTANT NUMBER := 4;
KU$_DFHDR_CHARSET_ID           CONSTANT NUMBER := 5;
KU$_DFHDR_CREATION_DATE        CONSTANT NUMBER := 6;
KU$_DFHDR_FLAGS                CONSTANT NUMBER := 7;
KU$_DFHDR_JOB_NAME             CONSTANT NUMBER := 8;
KU$_DFHDR_PLATFORM             CONSTANT NUMBER := 9;
KU$_DFHDR_INSTANCE             CONSTANT NUMBER := 10;
KU$_DFHDR_LANGUAGE             CONSTANT NUMBER := 11;
KU$_DFHDR_BLOCKSIZE            CONSTANT NUMBER := 12;
KU$_DFHDR_DIRPATH              CONSTANT NUMBER := 13;
KU$_DFHDR_METADATA_COMPRESSED  CONSTANT NUMBER := 14;
KU$_DFHDR_DB_VERSION           CONSTANT NUMBER := 15;
KU$_DFHDR_MASTER_PIECE_COUNT   CONSTANT NUMBER := 16;
KU$_DFHDR_MASTER_PIECE_NUMBER  CONSTANT NUMBER := 17;
KU$_DFHDR_DATA_COMPRESSED      CONSTANT NUMBER := 18;
KU$_DFHDR_METADATA_ENCRYPTED   CONSTANT NUMBER := 19;
KU$_DFHDR_DATA_ENCRYPTED       CONSTANT NUMBER := 20;
KU$_DFHDR_COLUMNS_ENCRYPTED    CONSTANT NUMBER := 21;
--
-- Item codes KU$_DFHDR_ENCPWD_MODE and KU$_DFHDR_ENCPWD_MODE_xxx
-- are obsolescent and will be removed in a future version. Instead, 
-- KU$_DFHDR_ENCRYPTION_MODE and KU$_DFHDR_ENCMODE_xxx should be used.
--
KU$_DFHDR_ENCPWD_MODE          CONSTANT NUMBER := 22;
  KU$_DFHDR_ENCPWD_MODE_UNKNOWN   CONSTANT NUMBER := 1;
  KU$_DFHDR_ENCPWD_MODE_NONE      CONSTANT NUMBER := 2;
  KU$_DFHDR_ENCPWD_MODE_PASSWORD  CONSTANT NUMBER := 3;
  KU$_DFHDR_ENCPWD_MODE_DUAL      CONSTANT NUMBER := 4;
  KU$_DFHDR_ENCPWD_MODE_TRANS     CONSTANT NUMBER := 5;

-- 
-- KU$_DFHDR_ENCMODE_xxx are values that can be returned
-- for item code KU$_DFHDR_ENCRYPTION_MODE.
--
KU$_DFHDR_ENCRYPTION_MODE      CONSTANT NUMBER := 22;
  KU$_DFHDR_ENCMODE_UNKNOWN       CONSTANT NUMBER := 1;
  KU$_DFHDR_ENCMODE_NONE          CONSTANT NUMBER := 2;
  KU$_DFHDR_ENCMODE_PASSWORD      CONSTANT NUMBER := 3;
  KU$_DFHDR_ENCMODE_DUAL          CONSTANT NUMBER := 4;
  KU$_DFHDR_ENCMODE_TRANS         CONSTANT NUMBER := 5;

KU$_DFHDR_MAX_ITEM_CODE        CONSTANT NUMBER := 22;

KU$_COMPRESS_NONE              CONSTANT NUMBER := 1;
KU$_COMPRESS_METADATA          CONSTANT NUMBER := 2;

-- Bitmask defs used in DATA_OPTIONS parameter. Values above 1048576 are 
-- reserved for internal use.

KU$_DATAOPT_SKIP_CONST_ERR       CONSTANT NUMBER := 1;
KU$_DATAOPT_XMLTYPE_CLOB         CONSTANT NUMBER := 2;
KU$_DATAOPT_NOTYPE_EVOL          CONSTANT NUMBER := 4;
KU$_DATAOPT_DISABL_APPEND_HINT   CONSTANT NUMBER := 8;

-- Bitmask defs for the flags field of dictionary table impcalloutreg$
-- See dtools.bsq for detailed descriptions

KU$_ICRFLAGS_IS_EXPR             CONSTANT NUMBER := 1;
KU$_ICRFLAGS_EARLY_IMPORT        CONSTANT NUMBER := 2;
KU$_ICRFLAGS_GET_DEPENDENTS      CONSTANT NUMBER := 4;
KU$_ICRFLAGS_EXCLUDE             CONSTANT NUMBER := 8;
KU$_ICRFLAGS_XDB_NO_TTS          CONSTANT NUMBER := 16;

-------------
-- EXCEPTIONS
--      The following exceptions can be generated by the DBMS_DATAPUMP API:
-- INVALID_ARGVAL, PRIVILEGE_ERROR, INVALID_OPERATION,
-- OBJECT_NOT_FOUND, INVALID_HANDLE, INVALID_STATE, INCONSISTENT_ARGS,
-- JOB_EXISTS, NO_SUCH_JOB, INVALID_VALUE, SUCCESS_WITH_INFO
--
  invalid_argval EXCEPTION; -- OK
    PRAGMA EXCEPTION_INIT(invalid_argval, -39001);
    invalid_argval_num NUMBER := -39001;
-- "Invalid argument value"
-- *Cause:  The user specified API parameters were of the wrong type or
--          value range.  Subsequent messages supplied by 
--          DBMS_DATAPUMP.GET_STATUS will further describe the error.
-- *Action: Correct the bad argument and retry the API.

  invalid_operation EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_operation, -39002);
    invalid_operation_num NUMBER := -39002;
-- "invalid operation"
-- *Cause:  The current API cannot be executed because of inconsistencies
--          between the API and the current definition of the job.
--          Subsequent messages supplied by DBMS_DATAPUMP.GET_STATUS 
--          will further describe the error.
-- *Action: Modify the API call to be consistent with the current job or 
--          redefine the job in a manner that will support the specified API.

  inconsistent_args EXCEPTION; -- OK
    PRAGMA EXCEPTION_INIT(inconsistent_args, -39005);
    inconsistent_args_num NUMBER := -39005;
-- "inconsistent arguments"
-- *Cause:  The current API cannot be executed because of inconsistencies
--          between arguments of the API call.
--          Subsequent messages supplied by DBMS_DATAPUMP.GET_STATUS 
--          will further describe the error.
-- *Action: Modify the API call to be consistent with itself.

  privilege_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(privilege_error, -31631);
    privilege_error_num NUMBER := -31631;
-- "privileges are required"
-- *Cause:  The necessary privileges are not available for operations such
--          as: restarting a job on behalf of another owner, using a device
--          as a member of the dump file set, or ommiting a directory
--          object associated with any of the various output files.  
-- *Action: Select a different job to restart, try a different operation, or
--          contact a database administrator to acquire the needed privileges.

  invalid_handle EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_handle, -31623);
    invalid_handle_num NUMBER := -31623;
-- "The current session is not attached to the specified handle"
-- *Cause:  User specified an incorrect handle for a job.
-- *Action: Make sure handle was returned by DBMS_DATAPUMP.OPEN call.

  invalid_state EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_state, -39004);
    invalid_state_num NUMBER := -39004;
-- "invalid state"
-- *Cause:  The state of the job precludes the execution of the API.
-- *Action: Rerun the job to specify the API when the job is an appropriate 
--          state.

  job_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(job_exists, -31634);
    job_exists_num NUMBER := -31634;
-- "job already exists"
-- *Cause:  Job creation or restart failed because a job having the selected
--          name is currently executing.  This also generally indicates that
--          a Master Table with that job name exists in the user schema.
-- *Action: Select a different job name, or stop the currently executing job
--          and re-try the operation (may require a DROP on the Master Table).

  no_such_job EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_such_job, -31626);
    no_such_job_num NUMBER := -31626;
-- "job does not exist"
-- *Cause:  A invalid reference to a job which is no longer executing,
--          is not executing on the instance where the operation was
--          attempted, or that does not have a valid Master Table.
--          Refer to the secondary error messages that follow this one for
--          clarification concerning the problems with the Master Table.
-- *Action: Start a new job, or attach to an existing job that has a
--          valid Master Table.

  internal_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(internal_error, -39006);
    internal_error_num NUMBER := -39006;
-- "internal error"
-- *Cause:  An unexpected error occurred while processing a DataPump job.
--          Subsequent messages supplied by DBMS_DATAPUMP.GET_STATUS 
--          will further describe the error.
-- *Action: Contact Oracle Support.

  success_with_info EXCEPTION;
    PRAGMA EXCEPTION_INIT(success_with_info, -31627);
    success_with_info_num NUMBER := -31627;
-- "API call succeeded but more information is available."
-- *Cause: User specified job parameters that yielded informational messages. 
-- *Action: Call DBMS_DATAPUMP.GET_STATUS to retrieve additional information.

  no_dumpfile_info EXCEPTION;
    PRAGMA EXCEPTION_INIT(no_dumpfile_info, -39211);
    no_dumpfile_info_num NUMBER := -39211;
-- "Unable to retrieve dumpfile information as specified."
-- *Cause:  User specified an invalid or inaccessible file with the specified
--          filename and directory object.
-- *Action: Retry the operation with a valid directory object and filename.

---------------------------
-- PROCEDURES AND FUNCTIONS
---------------------------
--
-- ADD_DEVICE: Adds a sequential device to the dump file set for Export,
--             Import, or Sql_file operations.
-- PARAMETERS:
--      handle     - Handle of the job (returned by OPEN)
--      devicename - Name of the device being added.
--      volumesize - Backing store capacity for the device.
--
-- RETURNS:
--      None
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      PRIVILEGE_ERROR   - User didn't have EXP_FULL_DATABASE or
--                          IMP_FULL_DATABASE role
--      INVALID_OPERATION - The file was specified for a Network or Estimate
--                          operation, or the file was specified for an
--                          executing import or sql_file operation.
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE add_device (
                handle          IN  NUMBER,
                devicename      IN  VARCHAR2,
                volumesize      IN  VARCHAR2 DEFAULT NULL
        );

-- ADD_FILE: Adds a file to the dump file set for Export, Import, or Sql_file
--           operations as well as log files, bad files, and sql files.
-- PARAMETERS:
--      handle    - Handle of the job (returned by OPEN)
--      filename  - Name of the file being added. This must be a simple
--                  filename with no directory path information if the
--                  directory parameter is specified. Filename can contain
--                  substitution characters to use this name as a template to
--                  create multiple files.
--      directory - Name of the directory object within the database that is
--                  used to locate the filename. Users with
--                  IMP_FULL_DATABASE or EXP_FULL_DATABASE roles can
--                  specify the directory path in the filename, but other
--                  users must specify this parameter.
--      filesize  - Size of the file being added. It may be specified as number
--                  of bytes, number of kilobytes (followed by 'K'), number of
--                  megabytes (followed by 'M'), number of gigabytes
--                  (followed by 'G') or the number of terabytes (followed
--                  by 'T'). This parameter is ignored for import and
--                  sql_file operations. On export operations, no more than
--                  the specified number of bytes will be written to the file,
--                  and if there is insufficient space on the device, the
--                  operation will fail. If not specified on export, the
--                  default will be unlimited size with allocations in 50 Mbyte
--                  increments. The minimum allowed filesize is 10 times the
--                  default block size for the file system.
--      filetype  - Type of file being added to the job. This numeric constant
--                  indicates whether it is a dump file, log file, bad file,
--                  or sql file being added to the job.
--     reusefile  - Flag indicating whether or not an existing dumpfile
--                  should be reused (i.e., overwritten) during an export
--                  operation. Valid values are:
--                    NULL - use the default behavior for the file type:
--                           for dump files, the default is do not reuse;
--                           for log and sql files, the default is reuse.
--                       0 - do not reuse (only meaningful for dump files).
--                       1 - reuse (only meaningful for dump files).
--
-- RETURNS:
--      None
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      INVALID_STATE     - The current job state does not allow for the
--                          addition of files to the job (only for SQL and
--                          LOG files)
--      INVALID_OPERATION - The file was specified for a Network or Estimate
--                          operation, or the file was specified for an
--                          executing import or sql_file operation.
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE add_file (
                handle          IN  NUMBER,
                filename        IN  VARCHAR2,
                directory       IN  VARCHAR2 DEFAULT NULL,
                filesize        IN  VARCHAR2 DEFAULT NULL,
                filetype        IN  NUMBER DEFAULT KU$_FILE_TYPE_DUMP_FILE,
               reusefile        IN  NUMBER DEFAULT NULL
        );


-- ATTACH: Acquire access to an active or stopped job
--
-- PARAMETERS:
--      job_name  - Identifies the particular job or operation. It will default
--                  to the name of a job owned by the user specified by
--                  job_owner if that user has only one job in the defining,
--                  executing, idling, waiting, or completing states.
--      job_owner - The user that started the job. If NULL, it defaults to the
--                  owner of the current session. To specify a different
--                  job_owner (than themselves), users must have
--                  IMP_FULL_DATABASE or EXP_FULL_DATABASE roles
--                  (depending on the operation)
--
-- RETURNS:
--      A handle to be used in subsequent calls to all other DBMS_DATAPUMP
--      operations.
-- EXCEPTIONS:
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      INVALID_OPERATION - This operation can not be restarted
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  FUNCTION attach (
                job_name        IN  VARCHAR2 DEFAULT NULL,
                job_owner       IN  VARCHAR2 DEFAULT NULL
        )
        RETURN NUMBER;


-- DATA_FILTER: Filter data using subqueries or excluding all user data
--
-- PARAMETERS:
--      handle      - Identifies the particular job or operation (from OPEN)
--      name        - The filter name or type to use (see documentation)
--      value       - Filter details
--      table_name  - Table name for applying the filter. Will default to all
--                    all tables if not specified.
--      schema_name - Name of the schema owning the table to apply the data
--                    filter. Null implies all schemas in the job.
--
-- RETURNS:
--      NONE
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      PRIVILEGE_ERROR   - The specified operation requires privileges
--      INVALID_STATE     - The job is not in the defining state
--      INCONSISTENT_ARGS - The datatype of value does not match the filter
--                          name
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE data_filter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  NUMBER,
                table_name      IN  VARCHAR2 DEFAULT NULL,
                schema_name     IN  VARCHAR2 DEFAULT NULL
        );

  PROCEDURE data_filter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  CLOB,
                table_name      IN  VARCHAR2 DEFAULT NULL,
                schema_name     IN  VARCHAR2 DEFAULT NULL
        );

  PROCEDURE data_filter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  VARCHAR2,
                table_name      IN  VARCHAR2 DEFAULT NULL,
                schema_name     IN  VARCHAR2 DEFAULT NULL
        );


-- DATA_REMAP: Modify the values of data in user tables
--
-- PARAMETERS:
--      handle      - Identifies the particular job or operation (from OPEN)
--      name        - The type of data remapping to be performed
--      table_name  - Table name for applying the remap.
--      column      - Column name for where the data needs to be remapped
--      function    - Function used to remap the column data.
--      schema      - Name of the schema owning the table to apply the data
--                    remap. Null implies all schemas in the job.
--
-- RETURNS:
--      NONE
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE data_remap (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                table_name      IN  VARCHAR2,
                column          IN  VARCHAR2,
                function        IN  VARCHAR2,
                schema          IN  VARCHAR2 DEFAULT NULL
        );


-- DETACH: Detach current session (and handle) from job
--
-- PARAMETERS:
--      handle  - Identifies the particular job or operation (from OPEN/ATTACH)
--
-- RETURNS:
--      NONE
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE detach (
                handle          IN  NUMBER
        );


-- GET_DUMPFILE_INFO: Analyze specified file and return dumpfile information
--
-- PARAMETERS:
--      filename   - Name of the file being added. This must be a simple
--                   filename with no directory path information.
--      directory  - Name of the directory object within the database that is
--                   used to locate the filename.
--      info_table - (OUT) The ku$_dumpfile_info table to be
--                   populated with dumpfile header information.
--      filetype   - (OUT) 0 => Unknown file type
--                         1 => Data Pump dumpfile
--                         2 => Classic Export dumpfile
-- RETURNS:
--      NONE
--
-- EXCEPTIONS:
--      Fatal exceptions raised - all others eaten

  PROCEDURE get_dumpfile_info (
                filename        IN     VARCHAR2,
                directory       IN     VARCHAR2,
                info_table      OUT    ku$_dumpfile_info,
                filetype        OUT    NUMBER
        );


-- GET_STATUS: Get status of job (for monitoring and control)
-- 
-- PARAMETERS:
--      handle      - Identifies the particular job (from OPEN/ATTACH)
--      mask        - Bit mask to specify the information to be returned:
--                      Bit 0  - Retrieve work in progress (wip) information
--                      Bit 1  - Retrieve job complete description information
--                      Bit 2  - Retrieve detailed job and per-worker progress
--                               and status (NOTE: Retrieving the job status
--                               and checking the job state for 'COMPLETED' is
--                               the proper mechanism for detecting that a job
--                               has completed successfully. Once the job has
--                               entered this state, subsequent calls will
--                               likely result in an invalid_handle exception)
--                      Bit 3  - Retrieve error packet/log entry information
--      timeout    - Max seconds to wait if no pending status queue entries.
--                   Specifying zero or null results in an immediate return
--                   and -1 will wait indefinitely. The timeout will be
--                   ignored when the job is in the 'COMPLETING' or
--                   'COMPLETED' states.
--      job_state  - (OUT) Current job state of this Data Pump job (newer
--                   procedural interface only)
--      status     - (OUT) ku$_Status object with requested information in the
--                   newer procedural interface only
--
-- RETURNS:
--      ku$_Status object with requested information in the initial functional
--      interface only (to be deprecated)
--
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  FUNCTION get_status (
                handle          IN  NUMBER,
                mask            IN  INTEGER,
                timeout         IN  NUMBER DEFAULT NULL
        )
        RETURN ku$_Status;

  PROCEDURE get_status (
                handle          IN  NUMBER,
                mask            IN  INTEGER,
                timeout         IN  NUMBER DEFAULT NULL,
                job_state       OUT VARCHAR2,
                status          OUT ku$_Status1010
        );

  PROCEDURE get_status (
                handle          IN  NUMBER,
                mask            IN  INTEGER,
                timeout         IN  NUMBER DEFAULT NULL,
                job_state       OUT VARCHAR2,
                status          OUT ku$_Status1020
        );

  PROCEDURE get_status (
                handle          IN  NUMBER,
                mask            IN  INTEGER,
                timeout         IN  NUMBER DEFAULT NULL,
                job_state       OUT VARCHAR2,
                status          OUT ku$_Status1120
        );

-- LOG_ENTRY: Add entry to log file and broadcast to all get_status callers
--
-- PARAMETERS:
--      handle        - Identifies the particular job (from OPEN/ATTACH)
--      message       - Text to be added to the log file
--      log_file_only - Specified text to be written to the log file only and
--                      not to the status queues like other log messages
--
-- RETURNS:
--      NONE
--
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE log_entry (
                handle          IN  NUMBER,
                message         IN  VARCHAR2,
                log_file_only   IN  NUMBER DEFAULT 0
        );


-- METADATA_FILTER: Applies transformations to objects' DDL during import,
--                  network, and sql_file operations
--
-- PARAMETERS:
--      handle      - Identifies the particular job or operation (from OPEN)
--      name        - Name of the metadata filter (see documentation).
--      value       - Text expression for the filter in the name parameter
--      object_path - The object path to which the filter applies (default=all
--                    objects).
--      object_type - For backward compatibility, can be used to specify the
--                    object path (see above)
--
-- RETURNS:
--      NONE
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      INVALID_STATE     - The job is not in the defining state
--      INCONSISTENT_ARGS - The value specification does not match the metadata
--                          filter name
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE metadata_filter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  VARCHAR2,
                object_path     IN  VARCHAR2 DEFAULT NULL,
                object_type     IN  VARCHAR2 DEFAULT NULL
        );

  PROCEDURE metadata_filter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  CLOB,
                object_path     IN  VARCHAR2 DEFAULT NULL,
                object_type     IN  VARCHAR2 DEFAULT NULL
        );

-- METADATA_TRANSFORM: Allows transformations applied to objects during jobs
--
-- PARAMETERS:
--      handle      - Identifies the particular job or operation (from OPEN)
--      name        - Name of the transformation (see documentation).
--      value       - The value of the parameter for the transform
--      object_type - The object type to which the transform applies
--                    (default=all objects)
--
-- RETURNS:
--      NONE
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      INVALID_STATE     - The job is not in the defining state or operation
--                          is either export or estimate which don't support
--                          transforms.
--      INVALID_OPERATION - Transforms not permitted for this operation
--      INCONSISTENT_ARGS - The value specification does not match the metadata
--                          transform name
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE metadata_transform (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  VARCHAR2,
                object_type     IN  VARCHAR2 DEFAULT NULL
        );

  PROCEDURE metadata_transform (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  NUMBER,
                object_type     IN  VARCHAR2 DEFAULT NULL
        );


-- METADATA_REMAP: Allows remappings applied to objects during jobs
--
-- PARAMETERS:
--      handle      - Identifies the particular job or operation (from OPEN)
--      name        - Name of the mapping to occur (see documentation).
--      old_value   - Previous value to reset to new value (value parameter)
--      value       - The value of the parameter for the mapping
--      object_type - The object type to which the mapping applies (default=all
--                    objects)
--
-- RETURNS:
--      NONE
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      INVALID_STATE     - The job is not in the defining state or operation
--                          is either export or estimate which don't support
--                          transforms.
--      INVALID_OPERATION - Remaps not permitted for this operation
--      INCONSISTENT_ARGS - The value specification does not match the metadata
--                          transform name
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE metadata_remap (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                old_value       IN  VARCHAR2,
                value           IN  VARCHAR2,
                object_type     IN  VARCHAR2 DEFAULT NULL
        );



-- OPEN: Create a new DataPump job/operation
--
-- PARAMETERS:
--      operation       - The type of operation to be performed (EXPORT,
--                        IMPORT, SQL_FILE)
--      job_mode        - Operation mode (FULL, SCHEMA, TABLE, TABLESPACE,
--                        TRANSPORTABLE)
--      remote_link     - Link to source database to be used for network
--                        operations.
--      job_name        - Name of the job, implicitly qualified by the schema
--                        and must be unique to that schema
--      version         - Version of the database objects to be extracted (for
--                        export, estimate, and network only). Possible values
--                        are COMPATIBLE (the default), LATEST, or a specific
--                        database version.
--      compression     - Compression to use job-wide on export
--
-- RETURNS:
--      A handle to be used in all subsequent calls (except ATTACH)
--
-- EXCEPTIONS:
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      JOB_EXISTS        - A table having the name job_name already exists.
--      PRIVILEGE_ERROR   - User doesn't have the privilege to create the
--                          specified master table
--      INTERNAL_ERROR    - There was an internal error trying to create the
--                          DataPump job as specified
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  FUNCTION open (
                operation       IN  VARCHAR2,
                job_mode        IN  VARCHAR2,
                remote_link     IN  VARCHAR2 DEFAULT NULL,
                job_name        IN  VARCHAR2 DEFAULT NULL,
                version         IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                compression     IN  NUMBER DEFAULT KU$_COMPRESS_METADATA
        )
        RETURN NUMBER;


-- SET_PARALLEL: Throttle the degree of parallelism within a job
--
-- PARAMETERS:
--      handle  - Identifies the particular job or operation (from OPEN/ATTACH)
--      degree  - Max number of worker processes that can be used for the job
--
-- RETURNS:
--      NONE
--
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      INVALID_OPERATION - Changing the degree of parallelism is not permitted
--                          for this operation
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE set_parallel (
                handle          IN  NUMBER,
                degree          IN  NUMBER
        );


-- SET_PARAMETER: Specify a variety of processing options for a particular job
--
-- PARAMETERS:
--      handle  - Identifies the particular job or operation (from OPEN/ATTACH)
--      name    - Parameter name (see documentation).
--      value   - Value for this parameter
--
-- RETURNS:
--      NONE
--
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_ARGVAL    - A NULL or invalid value was supplied for an input
--                          parameter.
--      INVALID_STATE     - Job must be in the defining state
--      INCONSISTENT_ARGS - Datatype of value inconsistent with parameter type
--      INVALID_OPERATION - The specified parameter is not allowed for the
--                          current operation
--      PRIVILEGE_ERROR   - The specified parameter requires privileges
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE set_parameter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  VARCHAR2
        );

  PROCEDURE set_parameter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  NUMBER
        );


-- START_JOB: Start or restart a job
--
-- PARAMETERS:
--      handle       - Identifies the particular job or operation (from
--                     OPEN/ATTACH)
--      skip_current - If set (on a restart only - ignored on initial start),
--                     will cause incomplete actions from a previous start to
--                     be skipped. Default is false.
--      abort_step   - For testing only
--      cluster_ok   - If =0, all workers are started in the current intance.
--                     Otherwise, workers are started on instances usable by
--                     the job.
--      service_name - If specified, indicates a service name used to constain
--                     the job to specific instances or to a specific resource
--                     group.
--
-- RETURNS:
--      NONE
--
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_STATE     - Job can't be started due to insufficient info
--      INVALID_OPERATION - The operation as defined has insufficient or
--                          conflicting attributes and can not be started
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE start_job (
                handle          IN  NUMBER,
                skip_current    IN  NUMBER DEFAULT 0,
                abort_step      IN  NUMBER DEFAULT 0,
                cluster_ok      IN  NUMBER DEFAULT 1,
                service_name    IN  VARCHAR2 DEFAULT NULL
        );


-- STOP_JOB: Terminate a job while preserving its state
--
-- PARAMETERS:
--      handle      - Identifies the particular job or operation (from
--                    OPEN/ATTACH). This handle is detached on successful
--                    completion of this call.
--      immediate   - If true, worker processes are aborted immediately instead
--                    of being allowed to complete their current work items.
--                    This halts the job more rapidly at the expense of having
--                    to rerun parts of the job on a restart.
--      keep_master - If non-zero, the master table is retained when the job is
--                    stopped. If zero, the master table is dropped when the
--                    job is stopped. If null, retention is based on the
--                    KEEP_MASTER parameter setting.
--      delay       - Number of seconds that should be waited until other
--                    attached sessions are forcibly detached. The delay
--                    allows other sessions attached to the job to be notified
--                    that a stop has been performed. If delay=0 is specified,
--                    other attached sessions will find their handles are
--                    invalid at their next calls to the datapump API.
--
-- RETURNS:
--      NONE
--
-- EXCEPTIONS:
--      INVALID_HANDLE    - The current session is not attached to this handle
--      INVALID_OPERATION - This operation can not be stopped
--      SUCCESS_WITH_INFO - API succeeded but further information available
--                          through the get_status API
--      NO_SUCH_JOB       - The job handle is no longer valid or job no longer
--                          exists

  PROCEDURE stop_job (
                handle          IN  NUMBER,
                immediate       IN  NUMBER DEFAULT 0,
                keep_master     IN  NUMBER DEFAULT NULL,
                delay           IN  NUMBER DEFAULT 60
        );

-- WAIT_FOR_JOB: Wait for job to complete and then return
--
-- PARAMETERS:
--      handle      - Identifies the particular job or operation (from
--                    OPEN/ATTACH). This handle is detached on successful
--                    completion of this call.
--      job_state   - (OUT) The job state at job completion
-- RETURNS:
--      NONE
--
-- EXCEPTIONS:
--      Fatal exceptions raised - all others eaten

  PROCEDURE wait_for_job (
                handle          IN  NUMBER,
                job_state       OUT VARCHAR2
        );


-- DATAPUMP_JOB: Is it or is it not?

  FUNCTION datapump_job RETURN BOOLEAN;

-- Privs - Yes or no?

  FUNCTION has_privs(
                oper  IN VARCHAR2)
    RETURN BOOLEAN;

-- Establish remote Data Pump job context

  PROCEDURE establish_remote_context(
                worker_id    IN NUMBER,
                remote_link  IN VARCHAR2);

  PROCEDURE set_remote_worker(
                worker_id    IN NUMBER);

-- Set up remote Data Pump job context

  PROCEDURE setup_remote_context(
                user_name       IN VARCHAR2,
                job_name        IN VARCHAR2,
                version         IN NUMBER,
                status_xml      IN VARCHAR2,
                status_xml_len  IN NUMBER,
                more            IN NUMBER);

-- To determine ku$_Status object version to use for network operations

  FUNCTION get_status_version(
                version  IN NUMBER)
    RETURN NUMBER;

-- Test remote Data Pump job context

  PROCEDURE test_remote_context1010;
  PROCEDURE test_remote_context1020;
  PROCEDURE test_remote_context1120;

-- LOG_ERROR: Add error to log file and broadcast to all get_status callers

  PROCEDURE log_error (
                handle          IN  NUMBER,
                message         IN  VARCHAR2,
                error_number    IN  NUMBER DEFAULT 0,
                fatal_error     IN  NUMBER DEFAULT 0,
                log_file_only   IN  NUMBER DEFAULT 0
        );

-- Create view into master table for a job

  PROCEDURE create_job_view (
                job_schema      IN VARCHAR2,
                job_name        IN VARCHAR2,
                view_name       IN VARCHAR2,
                view_type       IN NUMBER DEFAULT KU$_JOB_VIEW_ALL
        );

  PROCEDURE create_job_view (
                handle          IN NUMBER,
                view_name       IN VARCHAR2,
                view_type       IN NUMBER DEFAULT KU$_JOB_VIEW_ALL
        );

-- SET_DEBUG: Enable debug/trace features - pre 11.0
-- PARAMETERS:
--      on_off          - new switch state.
--      ip_addr         - IP Address to connected to jdeveloper

  PROCEDURE set_debug (
                on_off          IN NUMBER,
                ip_addr         IN VARCHAR2 DEFAULT NULL
        );

-- SET_DEBUG: Enable debug/trace features - 11.0 forward
-- PARAMETERS:
--      debug_flags:  Trace/debug flags from /TRACE param, or event, and
--                    possibly global trace/debug flags
--      version_flag: Any integer, no default

  PROCEDURE set_debug (
                debug_flags     IN BINARY_INTEGER,
                version_flag    IN BINARY_INTEGER
        );

-- Temporary home for clob helper routines
 PROCEDURE client_lob_append (
		value		IN  VARCHAR2,
                position        IN  NUMBER,
                as_is           IN  NUMBER DEFAULT 0
	);
 FUNCTION client_lob_get RETURN CLOB;
 PROCEDURE client_lob_delete;

END DBMS_DATAPUMP;
/
GRANT EXECUTE ON sys.dbms_datapump TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM dbms_datapump FOR sys.dbms_datapump;

