--
-- $Header: oraolap/src/sql/dbmscbl.sql /st_rdbms_11.2.0/1 2011/01/31 09:16:28 smierau Exp $
--
-- dbmscbl.sql
--
-- Copyright (c) 2008, 2011, Oracle and/or its affiliates. 
-- All rights reserved. 
--
--    NAME
--      dbmscbl.sql - DBMS_CUBE_LOG declarations
--
--    DESCRIPTION
--      Provides interfaces which control logging in the OLAP component
--
--    NOTES
--      <other useful comments, qualifications, etc.>
--
--    MODIFIED   (MM/DD/YY)
--    smierau     01/28/11 - Backport smierau_bug-10432704 from main
--    smierau     01/20/11 - Add create_reject_sql
--    smierau     03/08/10 - Add MAX_REJECT_LOBS, CONTINUE_AFTER_MAX_REJECTS
--    csperry     08/03/09 - add write to log methods
--    smesropi    04/15/09 - Added BUILD_V11200B3
--    cchiappa    04/14/09 - Rename values to match db logging
--    cchiappa    04/09/09 - logging error debugability
--    cchiappa    03/23/09 - Add INVALID_LOCATION exception
--    cchiappa    03/19/09 - CUBE_BUILD_LOG has time zone
--    cchiappa    02/17/09 - Deprecate constants in favor of functions
--    smierau     11/13/08 - Add LOG_EVERY_N parameter.
--    akociube    09/17/08 - Add SET_QUERY_ENV for debugging
--    smesropi    09/02/08 - Added BUILD_V11200
--    cchiappa    08/20/08 - CUBE_BUILD_LOG support
--    cchiappa    08/05/08 - Add {get,set}_log_spec
--    cchiappa    07/07/08 - 
--    akociube    06/19/08 - change verbosity 
--    cchiappa    06/04/08 - DBMS_CUBE_LOG declarations
--    cchiappa    06/04/08 - Created
--      

CREATE OR REPLACE PACKAGE dbms_cube_log AUTHID CURRENT_USER AS

  ---------------------
  --  OVERVIEW
  --
  --  This package is the interface to the OLAP logging infrastructure
  --
  ---------------------
  --  Visibility        
  --   All users
  --

  ---------------------
  --  CONSTANTS

  -- Log types
  TYPE_OPERATIONS_C        CONSTANT BINARY_INTEGER := 1;
  TYPE_REJECTED_RECORDS_C  CONSTANT BINARY_INTEGER := 2;
  TYPE_DIMENSION_COMPILE_C CONSTANT BINARY_INTEGER := 3;
  TYPE_BUILD_C             CONSTANT BINARY_INTEGER := 4;

  -- Log targets
  TARGET_TABLE_C      CONSTANT BINARY_INTEGER := 1;
  TARGET_TRACE_C      CONSTANT BINARY_INTEGER := 2;
  TARGET_FILE_C       CONSTANT BINARY_INTEGER := 3;
  TARGET_LOB_C        CONSTANT BINARY_INTEGER := 4;

  -- Log levels
  LEVEL_LOWEST_C      CONSTANT BINARY_INTEGER := 1;
  LEVEL_LOW_C         CONSTANT BINARY_INTEGER := 2;
  LEVEL_MEDIUM_C      CONSTANT BINARY_INTEGER := 3;
  LEVEL_HIGH_C        CONSTANT BINARY_INTEGER := 4;
  LEVEL_HIGHEST_C     CONSTANT BINARY_INTEGER := 5;
  VERBOSE_ACTION_C    CONSTANT BINARY_INTEGER := LEVEL_LOWEST_C;
  VERBOSE_NOTICE_C    CONSTANT BINARY_INTEGER := LEVEL_LOW_C;
  VERBOSE_INFO_C      CONSTANT BINARY_INTEGER := LEVEL_MEDIUM_C;
  VERBOSE_STATS_C     CONSTANT BINARY_INTEGER := LEVEL_HIGH_C;
  VERBOSE_DEBUG_C     CONSTANT BINARY_INTEGER := LEVEL_HIGHEST_C;

  -- Log table versions
  OPERATIONS_V112ALPHA CONSTANT BINARY_INTEGER := 1;
  OPERATIONS_V112      CONSTANT BINARY_INTEGER := 2;
  OPERATIONS_VCURRENT  CONSTANT BINARY_INTEGER := OPERATIONS_V112;

  REJECTED_RECORDS_V112ALPHA CONSTANT BINARY_INTEGER := 1;
  REJECTED_RECORDS_V112      CONSTANT BINARY_INTEGER := 2;
  REJECTED_RECORDS_VCURRENT  CONSTANT BINARY_INTEGER := REJECTED_RECORDS_V112;

  DIMENSION_COMPILE_V112ALPHA CONSTANT BINARY_INTEGER := 1;
  DIMENSION_COMPILE_V112      CONSTANT BINARY_INTEGER := 2;
  DIMENSION_COMPILE_VCURRENT  CONSTANT BINARY_INTEGER := DIMENSION_COMPILE_V112;

  BUILD_V11106   CONSTANT BINARY_INTEGER := 1;
  BUILD_V11106A  CONSTANT BINARY_INTEGER := 2;
  BUILD_V11107   CONSTANT BINARY_INTEGER := 3;
  BUILD_V11200B2 CONSTANT BINARY_INTEGER := 4;
  BUILD_V11200B3 CONSTANT BINARY_INTEGER := 5;
  BUILD_V11200   CONSTANT BINARY_INTEGER := 6;
  BUILD_VCURRENT CONSTANT BINARY_INTEGER := BUILD_V11200;

  -- Parameters
  -- Maximum errors logged before hard error raised
  MAX_ERRORS      CONSTANT BINARY_INTEGER := 1;
  -- Seconds between flushes of log
  FLUSH_INTERVAL  CONSTANT BINARY_INTEGER := 2;
  -- For rejected records, when do we log the full record?
  LOG_FULL_RECORD CONSTANT BINARY_INTEGER := 3;
    -- Log full record when no ROW_ID available
    FULL_RECORD_AUTO   CONSTANT BINARY_INTEGER := 0;
    -- Always log full record
    FULL_RECORD_ALWAYS CONSTANT BINARY_INTEGER := 1;
    -- Never log full record
    FULL_RECORD_NEVER  CONSTANT BINARY_INTEGER := 2;
  -- During import, log progress after EVERY_N row
  LOG_EVERY_N     CONSTANT BINARY_INTEGER := 4;
  -- Allow errors during logging to reach the user
  ALLOW_ERRORS    CONSTANT BINARY_INTEGER := 5;
  -- Maximum errors logged with LOB column populated
  MAX_REJECT_LOBS      CONSTANT BINARY_INTEGER := 6;
  -- Maximum errors logged with LOB column populated
  CONTINUE_AFTER_MAX_REJECTS  CONSTANT BINARY_INTEGER := 7;
    -- Don't continue after max errors
    CONTINUE_AFTER_MAX_NO CONSTANT BINARY_INTEGER := 0;
    -- Continue after max errors
    CONTINUE_AFTER_MAX_YES CONSTANT BINARY_INTEGER := 1;

  ---------------------
  --  TYPES
  -- For create_reject_sql
  TYPE REJECT_IDS is varray(500) of number;
  TYPE REJECT_SQL is varray(500) of clob;

  ---------------------
  --  EXCEPTIONS
  INVALID_TYPE EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_TYPE, -37561);
  INVALID_TARGET EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_TARGET, -37562);
  INVALID_LEVEL EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_LEVEL, -37563);
  INVALID_VERSION EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_VERSION, -37564);
  INVALID_LOCATION EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_LOCATION, -37566);
  INVALID_SQL_ID EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_SQL_ID, -37571);
  INVALID_ID EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_ID, -37572);
  NO_LIMITS EXCEPTION;
      PRAGMA EXCEPTION_INIT(NO_LIMITS, -37573);
  INVALID_LOG_MSG_NAME EXCEPTION;
      PRAGMA EXCEPTION_INIT(INVALID_LOG_MSG_NAME, -37577);

  ---------------------
  --  PROCEDURES

  -- Enable logging to a particular location with a given level
  PROCEDURE enable(log_type      IN BINARY_INTEGER DEFAULT NULL,
                   log_target    IN BINARY_INTEGER DEFAULT NULL,
                   log_level     IN BINARY_INTEGER DEFAULT NULL);
  PROCEDURE enable(log_type      IN BINARY_INTEGER DEFAULT NULL,
                   log_target    IN BINARY_INTEGER DEFAULT NULL,
                   log_level     IN BINARY_INTEGER DEFAULT NULL,
                   log_location  IN OUT NOCOPY CLOB);
  PROCEDURE enable(log_type      IN BINARY_INTEGER DEFAULT NULL,
                   log_target    IN BINARY_INTEGER DEFAULT NULL,
                   log_level     IN BINARY_INTEGER DEFAULT NULL,
                   log_location  IN VARCHAR2);

  -- Disable logging to a location
  PROCEDURE disable(log_type    IN BINARY_INTEGER DEFAULT NULL,
                    log_target  IN BINARY_INTEGER DEFAULT NULL);

  -- Returns the default name for a logging type
  FUNCTION default_name(log_type IN BINARY_INTEGER
                          DEFAULT DBMS_CUBE_LOG.TYPE_OPERATIONS_C)
    RETURN VARCHAR2;

  -- Get current logging information
  PROCEDURE get_log(log_type     IN BINARY_INTEGER DEFAULT NULL,
                    log_target   IN BINARY_INTEGER DEFAULT NULL,
                    log_level    OUT BINARY_INTEGER,
                    log_location OUT VARCHAR2);

  -- Get string describing current logging
  FUNCTION  get_log_spec RETURN VARCHAR2;

  -- Set all logging based on string
  PROCEDURE set_log_spec(log_spec IN VARCHAR2);

  -- Set all limits for query environment
  PROCEDURE set_query_env(sql_id IN VARCHAR2,
                          id IN NUMBER DEFAULT NULL,
                          tblname IN VARCHAR2 DEFAULT NULL);

  -- Creates an appropriate table for the given log type
  PROCEDURE table_create(log_type IN BINARY_INTEGER
                           DEFAULT DBMS_CUBE_LOG.TYPE_OPERATIONS_C,
                         tblname IN VARCHAR2 DEFAULT NULL);

  -- Retrieve version of table, or current default version
  -- if tblname is NULL
  FUNCTION version(log_type IN BINARY_INTEGER
                     DEFAULT DBMS_CUBE_LOG.TYPE_OPERATIONS_C,
                   tblname IN VARCHAR2 DEFAULT NULL)
    RETURN BINARY_INTEGER;

  -- Set a parameter's value
  PROCEDURE set_parameter(log_type      IN BINARY_INTEGER
                            DEFAULT DBMS_CUBE_LOG.TYPE_OPERATIONS_C,
                          log_parameter IN BINARY_INTEGER,
                          value         IN BINARY_INTEGER);

  -- Retrieve a parameter's value
  FUNCTION get_parameter(log_type      IN BINARY_INTEGER
                           DEFAULT DBMS_CUBE_LOG.TYPE_OPERATIONS_C,
                         log_parameter IN BINARY_INTEGER)
    RETURN BINARY_INTEGER;

  -- Force any open logs to flush
  PROCEDURE flush;

  --------------------
  -- LOGGING FUNCTIONS
  PROCEDURE write_to_oplog (
    oplogHandleId   in  number   default null,
    msgName         in  varchar2 , -- Cannot be null
    msgText         in  varchar2 default null,
    details         in  clob     default null,
    component       in  varchar2 default 'PLSQL',
    operation       in  varchar2 default null, --cannot be null
    recordLogLevel  in  binary_integer default LEVEL_LOW_C);

  PROCEDURE start_oplog (
    oplogHandleId   out number,
    msgName         in  varchar2 , -- Cannot be null
    msgText         in  varchar2 default null,
    component       in  varchar2 default 'PLSQL',
    operation       in  varchar2 default null, -- Cannot be null
    recordLogLevel  in  binary_integer default LEVEL_LOW_C);

  PROCEDURE complete_oplog (
    oplogHandleId   in  number );



  ----------------------
  --  ACCESSOR FUNCTIONS

  -- Log types
  FUNCTION TYPE_OPERATIONS RETURN BINARY_INTEGER;
  FUNCTION TYPE_REJECTED_RECORDS RETURN BINARY_INTEGER;
  FUNCTION TYPE_DIMENSION_COMPILE RETURN BINARY_INTEGER;
  FUNCTION TYPE_BUILD RETURN BINARY_INTEGER;

  -- Log targets
  FUNCTION TARGET_TABLE RETURN BINARY_INTEGER;
  FUNCTION TARGET_TRACE RETURN BINARY_INTEGER;
  FUNCTION TARGET_FILE RETURN BINARY_INTEGER;
  FUNCTION TARGET_LOB RETURN BINARY_INTEGER;

  -- Log levels
  FUNCTION LEVEL_LOWEST RETURN BINARY_INTEGER;
  FUNCTION LEVEL_LOW RETURN BINARY_INTEGER;
  FUNCTION LEVEL_MEDIUM RETURN BINARY_INTEGER;
  FUNCTION LEVEL_HIGH RETURN BINARY_INTEGER;
  FUNCTION LEVEL_HIGHEST RETURN BINARY_INTEGER;
  FUNCTION VERBOSE_ACTION RETURN BINARY_INTEGER;
  FUNCTION VERBOSE_NOTICE RETURN BINARY_INTEGER;
  FUNCTION VERBOSE_INFO RETURN BINARY_INTEGER;
  FUNCTION VERBOSE_STATS RETURN BINARY_INTEGER;
  FUNCTION VERBOSE_DEBUG RETURN BINARY_INTEGER;

  ----------------------
  --  UTILITY FUNCTIONS

  -- Create SQL to find rejected records.
  -- Given a schema, rejected records log table name and
  -- and an array of ID numbers, this returns an array of sql 
  -- statements (1 per ID) that can be used to help find the 
  -- rejected records.  If inIds is null this returns one
  -- SQL statment for every ID the the reject table that
  -- has any associated CLOBs.
  FUNCTION create_reject_sql(schema       IN VARCHAR2,
                             logTableName IN VARCHAR2,
                             inIds        IN REJECT_IDS DEFAULT NULL)
    RETURN REJECT_SQL;

END dbms_cube_log; 
/
show errors;

-- Give execute privileges
CREATE OR REPLACE PUBLIC SYNONYM dbms_cube_log FOR sys.dbms_cube_log
/
GRANT EXECUTE ON dbms_cube_log TO PUBLIC
/
