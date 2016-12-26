Rem
Rem $Header: rdbms/admin/dbmssqlu.sql /st_rdbms_11.2.0/1 2012/08/01 16:35:42 shjoshi Exp $
Rem
Rem dbmssqlu.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmssqlu.sql - DBMS SQLtune Utility packages
Rem
Rem    DESCRIPTION
Rem      This file contains the specifications of two utility packages 
Rem      dbms_sqltune_util0 and dbms_sqltune_util1. Each package defines 
Rem      various utility procedures and functions used by sql tuning features 
Rem      such as sqltune through dbms_sqltune and dbms_sqltune_internal 
Rem      packages and SQLPI through prvt_sqlpi internal package. 
Rem      The implementation of both packages is located in sqltune/prvtsqlu.sql.
Rem 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      07/03/12 - Backport shjoshi_rm_newtype from main
Rem    pbelknap    04/18/10 - add constants for sqlset2
Rem    pbelknap    12/12/09 - #8451247: callout for ksugctm()
Rem    pbelknap    06/22/09 - #8618452 - feature usage for reports
Rem    hayu        03/04/09 - update task_spaobj
Rem    shjoshi     01/22/09 - Add type task_spataskobj and 
Rem                           init_task_spataskobj()
Rem    shjoshi     01/16/09 - Add OBJ_SPA_EXEC_PROP# to dbms_sqltune_util1
Rem    shjoshi     09/16/08 - Add OBJ_SPA_TASK# to dbms_sqltune_util1
Rem    shjoshi     08/20/08 - Add function resolve_exec_name
Rem    kyagoub     04/02/08 - add flags to task_sqlobj
Rem    pbelknap    05/09/08 - #5521613: add dbms_sqltune_util2.check_priv
Rem    kyagoub     12/20/07 - add convert sqlset action to spa
Rem    pbelknap    09/06/07 - report_sql_monitor_xml: disable force pq
Rem    pbelknap    06/21/07 - stats_xml to other_xml
Rem    kyagoub     05/25/07 - rename spa advisor
Rem    kyagoub     04/10/07 - add execution type ids
Rem    hosu        02/28/07 - move SMB object type id constants to 
Rem                           dbms_smb_internal
Rem    pbelknap    03/19/07 - remove get_task_names_from_ids
Rem    pbelknap    02/21/07 - add unmap for task_id, owner_id, execution_id
Rem    pbelknap    02/08/07 - add description to sqlset metadata
Rem    pbelknap    12/07/06 - remove exec_name_list, avoid INLIST injections
Rem    pbelknap    01/10/07 - add dbms_sqltune_util2
Rem    pbelknap    08/21/06 - add constant for opm types
Rem    pbelknap    08/18/06 - add get_wkldtype_name
Rem    nachen      08/01/06 - add exec_frequecy to task_sqlobj
Rem    kyagoub     07/11/06 - Created
Rem

-------------------------------------------------------------------------------
--                    dbms_sqltune_util0 package declaration                 --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- NAME:
--     dbms_sqltune_util0
--
-- DESCRIPTION:
--     This package is defined to hold sqltune internal utility procedures and 
--     functions that do not access to dictionary objects. 
--     Some of these utiliies are called as part of upgrade and downgrade 
--     scripts. 
--
-- NOTICE:
--     The functions/procdures you add to this packages MUST not refer to any
--     dictionary objects, such as tables, views, etc., or any other packages
--     that are defined on such objects. 
--     When dictionary objects are altered in the upgrade/downgrade scripts,
--     the pacakges using them become invalid and this beaks upgrade/downgrad 
--     process.  So we MUST very curreful. 
--     Notice also that the functions of this package are also user by other
--     package such dbms_sqltune and dbms_sqltune_internal. 
--
-- PROCEDURES: 
--     The package contains the following utilities:
--       extract_bind
--       extract_binds
--       sqltext_to_signature
--       sqltext_to_sqlid
--       validate_sqlid
--
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_sqltune_util0 AS

  -----------------------------------------------------------------------------
  --                 section for constants and global variables              --
  -----------------------------------------------------------------------------
  INVALID_SQL EXCEPTION;
  PRAGMA EXCEPTION_INIT(INVALID_SQL, -900);

  -----------------------------------------------------------------------------
  --                    procedure/function specifications                    --
  -----------------------------------------------------------------------------


  ------------------------------ sqltext_to_signature -------------------------
  -- 
  -- NAME:  
  --     sqltext_to_signature - sql text to its signature 
  -- 
  -- DESCRIPTION: 
  --     This function returns a sql text's signature.  
  --     The signature can be used to identify sql text in dba_sql_profiles.
  --
  -- PARAMETERS:  
  --     sql_text    (IN) - (REQUIRED) sql text whose signature is required
  --     force_match (IN) - If TRUE this function returns the FORCE maching 
  --                        signature. Otherwise, it return the EXACT signature
  --
  -- RETURNS: 
  --     the signature of the specified sql text
  -----------------------------------------------------------------------------
  FUNCTION sqltext_to_signature(
    sql_text    IN CLOB, 
    force_match IN BINARY_INTEGER := 0)
  RETURN NUMBER;

  ------------------------------ sqltext_to_sqlid -----------------------------
  --
  -- NAME: 
  --     sqltext_to_signature - sql text to its signature
  --
  -- DESCRIPTION:  
  --     This function returns a sql text's id. 
  --     The signature can, for example, be used to identify sql text in 
  --     v$sqlXXX views. 
  --
  -- PARAMETERS:  
  --     sql_text    (IN) - (REQUIRED) sql text whose signature is required
  --
  -- RETURNS: 
  --     sqlid of the specified sql text
  -----------------------------------------------------------------------------
  FUNCTION sqltext_to_sqlid(sql_text IN CLOB) 
  RETURN VARCHAR2; 

  -------------------------------- validate_sqlid -----------------------------
  --
  -- NAME: 
  --     validate_sqlid - VALIDATE syntax of a SQL ID
  --
  -- DESCRIPTION:  
  --     This function checks to make sure that a sql id provided by a client
  --     is valid by converting it to a ub8 and back and checking to make sure
  --     there is no change.
  --
  -- PARAMETERS:  
  --     sql_id      (IN) - (REQUIRED) sql id to validate
  --
  -- RETURNS: 
  --     1 if valid, 0 otherwise.
  -----------------------------------------------------------------------------
  FUNCTION validate_sqlid(sql_id IN VARCHAR2)
  RETURN BINARY_INTEGER;

  --------------------------------- extract_bind ------------------------------
  -- NAME: 
  --     extract_bind 
  --
  -- DESCRIPTION:
  --     Given the value of a bind_data column captured in v$sql and a
  --     bind position, this function returns the value of the bind
  --     variable at that position in the SQL statement. Bind position
  --     start at 1. This function returns value and type information for
  --     the bind (see object type SQL_BIND).
  --
  -- PARAMETERS:
  --     bind_data (IN) - value of bind_data column from v$sql
  --     position  (IN) - bind position in the statement (starts from 1)
  --
  -- RETURN:
  --     This function will return NULL if one of the condition below is
  --     true:
  --       - the specified bind variable was not captured (only interesting
  --         bind values used by the optimizer are captured) 
  --       - bind position is invalid or out-of-bound
  --       - the specified bind_data is NULL.
  --                                 
  -- NOTE:  
  --     name of the bind in SQL_BIND object is not populated by this function
  ----------------------------------------------------------------------------
  FUNCTION extract_bind(
    bind_data  IN RAW,
    bind_pos   IN PLS_INTEGER)
  RETURN SQL_BIND;

  --------------------------------- extract_binds -----------------------------
  -- NAME: 
  --     extract_binds 
  --
  -- DESCRIPTION:
  --     Given the value of a bind_data column captured in v$sql
  --     this function returns the collection (list) of bind values
  --     associated to the corresponding SQL statement. 
  --
  -- PARAMETERS:
  --     bind_data (IN) - value of bind_data column from v$sql
  --
  -- RETURN:
  --     This function returns collection (list) of bind values of 
  --     type sql_bind. 
  --                                 
  -- NOTE:  
  --     For the content of a bind value, refert to function extract_bind
  -----------------------------------------------------------------------------
  FUNCTION extract_binds(
    bind_data  IN RAW)
  RETURN SQL_BIND_SET PIPELINED;

  -------------------------------- is_bind_masked -----------------------------
  -- NAME: 
  --     is_bind_masked
  --
  -- DESCRIPTION:
  --     This function examines a flag to determine if a bind at a given pos
  --     is masked
  --
  -- PARAMETERS:
  --     bind_pos           (IN) - bind position in the stmt (starts from 1)
  --     masked_binds_flag  (IN) - flag to indicate which binds are masked
  --
  -- RETURN:
  --     1 if bind at specified posn is masked, 0 otherwise
  --                                 
  ----------------------------------------------------------------------------
  FUNCTION is_bind_masked(
    bind_pos          IN PLS_INTEGER,
    masked_binds_flag IN RAW DEFAULT NULL)
  RETURN NUMBER;

  ------------------------------- get_binds_count -----------------------------
  -- NAME: 
  --     get_binds_count
  --
  -- DESCRIPTION:
  --     Given the value of a bind_data column in raw type this function 
  --     returns the number of bind values contained in the column.
  --
  -- PARAMETERS:
  --     bind_data  (IN) - value of bind_data column from v$sql
  --                       
  -- RETURN:
  --     Number of bind values in the bind data
  --
  -- EXCEPTIONS:
  --     None
  -----------------------------------------------------------------------------
  FUNCTION get_binds_count(bind_data IN RAW) RETURN PLS_INTEGER;


END dbms_sqltune_util0; 
/
show errors; 


-------------------------------------------------------------------------------
--                    dbms_sqltune_util1 package declaration                 --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- NAME:
--     dbms_sqltune_util1
--
-- DESCRIPTION:
--     As opposed to dbms_sqltune_util0, this package is for sqltune 
--     and sqlpi internal utility procedures and functions that might access 
--     to dictionary objects.  It should be used for all general utility 
--     functions that can/need to be DEFINER's rights. If a function only needs
--     to be accessible from the dbms_sqltune/sqldiag/etc feature layer, do
--     not put it here, but rather in the infrastructure layer (prvssqlf). This
--     layer is for code that should be globally accessible, even from the
--     internal package.
--
-- PROCEDURES: 
--     The package contains the following utilities:
--       TO BE DONE
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_sqltune_util1 AS

  -----------------------------------------------------------------------------
  --                 section for constants and global variables              --
  -----------------------------------------------------------------------------

  -- target object ids which are defined in OBJ_XXX_NUM keat constants  
  OBJ_SQL#             CONSTANT NUMBER       :=  7;       -- obj 
  OBJ_SQLSET#          CONSTANT NUMBER       :=  8;       -- obj 
  OBJ_AUTO_SQLWKLD#    CONSTANT NUMBER       :=  22;      -- obj 
  OBJ_SPA_EXEC_PROP#   CONSTANT NUMBER       :=  23;      -- SPA exec property
  OBJ_SPA_TASK#        CONSTANT NUMBER       :=  24;      -- SPA task obj 

  -- Execution types 
  --   Names:
  SQLTUNE      CONSTANT VARCHAR2(10) := 'TUNE SQL';
  TEST_EXECUTE CONSTANT VARCHAR2(12) := 'TEST EXECUTE';
  EXPLAIN_PLAN CONSTANT VARCHAR2(12) := 'EXPLAIN PLAN';
  COMPARE      CONSTANT VARCHAR2(19) := 'COMPARE PERFORMANCE';
  STS2TRIAL    CONSTANT VARCHAR2(19) := 'CONVERT SQLSET';
  SQLDIAG      CONSTANT VARCHAR2(19) := 'SQL DIAGNOSIS';

  --   IDs: 
  SQLTUNE# CONSTANT PLS_INTEGER := 1;                          /* Sql tuning */
  EXECUTE# CONSTANT PLS_INTEGER := 2;                    /* SQL test execute */
  EXPLAIN# CONSTANT PLS_INTEGER := 3;                    /* SQL explain plan */
  SQLDIAG# CONSTANT PLS_INTEGER := 4;                       /* SQL diagnosis */
  COMPARE# CONSTANT PLS_INTEGER := 5;                   /* compare for SQLPA */

  --
  -- task_wkldobj, task_sqlobj, property_map
  --
  -- The task_wkldobj structure stores information about the input to
  -- a tuning task.  We examine it during the parts of the report where 
  -- we need to have different logic depending on the target object.  The
  -- 'props' field is a hashtable mapping property names to values, and the
  -- 'sql' field defines the current SQL we are operating on.  For 
  -- single-statement tasks it is populated with the sql target object.
  --
  -- For STSes the workload is the same for all executions so we just load
  -- it up once.  For the automatic sql workload, it is different in each 
  -- execution so we have to refresh the data.
  --
  -- We also define constants for valid property names here.
  TYPE property_map IS TABLE OF VARCHAR2(32767) INDEX BY VARCHAR2(32767);
  TYPE task_sqlobj IS RECORD(
    obj_id              NUMBER,
    sql_id              VARCHAR2(13),
    plan_hash_value     NUMBER,
    parsing_schema_name VARCHAR2(30),
    sql_text            CLOB,
    other_xml           CLOB,
    exec_frequency      NUMBER,
    flags               BINARY_INTEGER
  );

  TYPE task_wkldobj IS RECORD(
    adv_id    NUMBER,          -- adivisor id#
    task_name VARCHAR2(30),    -- name of the current task
    type      NUMBER,          -- one of OBJ_XXX_NUM keat constants
    obj_id    NUMBER,          -- object id of target object
    props     property_map,    -- (name, value) pairs describing the target
    cursql    task_sqlobj      -- SQL object for the current statement
  );

  TYPE task_spaobj IS RECORD(
    exec1_name        VARCHAR2(32767),  -- the execution name of trial one
    exec1_type_num    NUMBER,           -- the execution type of trial one
    comp_exec_name    VARCHAR2(32767),  -- compare exec name, max length ?
    ce_obj_id         NUMBER,           -- obj id of comp env 
    target_obj_type   NUMBER,           -- could be SQLSET or SQL
    target_obj_id     NUMBER,           -- id of the target object of SPA task
    wkld              task_wkldobj      -- has the target obj id, 
  );  
    
  -- Constants used as property names in the 'props' hashtable

  -- STS properties
  PROP_SQLSET_NAME   CONSTANT VARCHAR2(30) := 'SQLSET_NAME';   -- sts name
  PROP_SQLSET_OWNER  CONSTANT VARCHAR2(30) := 'SQLSET_OWNER';  -- sts owner
  PROP_SQLSET_ID     CONSTANT VARCHAR2(30) := 'SQLSET_ID';     -- sts id
  PROP_SQLSET_DESC   CONSTANT VARCHAR2(30) := 'SQLSET_DESC';   -- sts desc

  -- Shared properties for multi-statement targets
  PROP_NB_SQL        CONSTANT VARCHAR2(30) := 'NB_STMTS';   -- total #stmts
                                                            -- (NOT # in rept)

  -- properties for STS2 (compare STS)
  PROP_SQLSET_NAME2  CONSTANT VARCHAR2(30) := 'SQLSET_NAME2';
  PROP_SQLSET_OWNER2 CONSTANT VARCHAR2(30) := 'SQLSET_OWNER2';
  PROP_SQLSET_ID2    CONSTANT VARCHAR2(30) := 'SQLSET_ID2';   
  PROP_SQLSET_DESC2  CONSTANT VARCHAR2(30) := 'SQLSET_DESC2'; 
  PROP_NB_SQL2       CONSTANT VARCHAR2(30) := 'NB_STMTS2';

  -- Automatic Workload properties
  PROP_SUM_ELAPSED   CONSTANT VARCHAR2(30) := 'SUM_ELAPSED'; -- sum of elapsed
                                                               
  -- Single statement properties
  PROP_SQL_ID         CONSTANT VARCHAR2(30) := 'SQL_ID';
  PROP_PARSING_SCHEMA CONSTANT VARCHAR2(30) := 'PARSING_SCHEMA';
  PROP_SQL_TEXT       CONSTANT VARCHAR2(30) := 'SQL_TEXT';
  PROP_TUNE_STATS     CONSTANT VARCHAR2(30) := 'TUNE_STATS';

  -- Parse modes for query
  PARSE_MOD_SQLSET  CONSTANT VARCHAR2(6) := 'SQLSET'     ;
  PARSE_MOD_AWR     CONSTANT VARCHAR2(4) := 'AWR'        ;
  PARSE_MOD_CURSOR  CONSTANT VARCHAR2(5) := 'V$SQL'      ;      
  PARSE_MOD_CAPCC   CONSTANT VARCHAR2(8) := 'V$SQLCAP'   ;
  PARSE_MOD_PROFILE CONSTANT VARCHAR2(10):= 'SQLPROFILE' ;   
  -----------------------------------------------------------------------------
  --                  public utility procedures and functions                --
  -----------------------------------------------------------------------------

  ---------------------------- get_sqlset_identifier --------------------------
  -- NAME: 
  --     get_sqlset_identifier 
  --
  -- DESCRIPTION:
  --     This function gets the SqlSet identifier ginven its name
  --
  -- PARAMETERS:
  --     sts_name  (IN) - sqlset name
  --     sts_owner (IN) - owner of sqlset
  --
  -- RETURN:
  --     The SqlSet id.
  -----------------------------------------------------------------------------
  FUNCTION get_sqlset_identifier(sts_name  IN VARCHAR2, sts_owner IN VARCHAR2) 
  RETURN NUMBER;


  ----------------------------- get_sqlset_nb_stmts ---------------------------
  -- NAME: 
  --     get_sqlset_nb_stmts 
  --
  -- DESCRIPTION:
  --     This function gets number of SQL statements in a SQL tuning set
  --
  -- PARAMETERS:
  --     sts_id  (IN) - SQL tuning set id
  --
  -- RETURN:
  --     Number of SQL in SQL tuning sets.
  -----------------------------------------------------------------------------
  FUNCTION get_sqlset_nb_stmts(sts_id IN NUMBER) 
  RETURN NUMBER;  

  ------------------------------------ get_view_text --------------------------
  -- NAME: 
  --     get_view_text 
  --
  -- DESCRIPTION:
  --     This function is used to return the text of the sql to capture plans 
  --     given a parse mode
  --
  -- PARAMETERS:
  --     parse_mode (IN) - parsing mode (PARSE_MOD_XXX constants)
  --
  -- RETURN:
  --     plan query text corresponding to the parsing mode
  -----------------------------------------------------------------------------
  FUNCTION get_view_text(parse_mode IN VARCHAR2) 
  RETURN VARCHAR2;

  ------------------------------ validate_task_status -------------------------
  -- NAME:
  --     validate_task_status: check whether the task status is valid to 
  --                           be reported
  --
  -- DESCRIPTION:
  --     A task report cannot be generated if the task status is INITIAL
  --     or CANCELED
  --
  -- PARAMETERS:
  --     tid        (IN)     - task identifier
  --
  -- RETURN:
  --     VOID
  -----------------------------------------------------------------------------
  PROCEDURE validate_task_status(tid IN NUMBER);

  ----------------------------- get_execution_type ----------------------------
  -- NAME:
  --     get_executin_type: get type of a task execution 
  --                     
  --
  -- DESCRIPTION:
  --     This functin retrieve the type of a given task execution
  --
  -- PARAMETERS:
  --     tid        (IN)     - task identifier
  --     ename      (IN)     - name of the execution
  --
  -- RETURN:
  --     VOID
  -----------------------------------------------------------------------------
  FUNCTION get_execution_type(tid VARCHAR2, ename VARCHAR2) 
  RETURN VARCHAR2;

  ------------------------------ init_task_wkldobj ----------------------------
  -- NAME: 
  --     init_task_wkldobj: initialize the task_wkldobj structure 
  --                        specifying the target of this tuning task.
  --
  -- DESCRIPTION:
  --     This procedure initializes our structure of that defines the object
  --     type of the workload as well as all of its properties.  We pass 
  --     it to different functions in the report that need to have logic about
  --     the input.
  --
  -- PARAMETERS:
  --     tid        (IN)         - task ID
  --     begin_exec (IN)         - first execution name for the report
  --                               (auto wkld only)
  --     end_exec   (IN)         - last execution name for the report 
  --                               (auto wkld only)
  --     target     (OUT NOCOPY) - initialized task_wkldobj structure
  --
  -- RETURN:
  --     VOID
  --
  -- RAISES:
  --     NO_DATA_FOUND if the workload object cannot be located
  -----------------------------------------------------------------------------
  PROCEDURE init_task_wkldobj(
    tid        IN         NUMBER,       
    begin_exec IN         VARCHAR2 := NULL,
    end_exec   IN         VARCHAR2 := NULL, 
    wkld       OUT NOCOPY task_wkldobj);


  ---------------------------- init_task_spaobj -------------------------------
  -- NAME: 
  --     init_task_spaobj: initialize the task_spaobj structure specifying
  --                       the target of this tuning task.
  --
  -- DESCRIPTION:
  --     This procedure initializes our structure of that defines the object
  --     type of SPA task whose regressions will be tuned by the tuning task.
  --
  -- PARAMETERS:
  --     tid             (IN)         - task ID
  --     comp_exec_name  (IN)         - execution name of compare performance
  --                                    trial for the SPA task
  --     spa_task     (OUT NOCOPY)    - initialized task_wkldobj structure
  --
  -- RETURN:
  --     VOID
  --
  -----------------------------------------------------------------------------
  PROCEDURE init_task_spaobj(
    tid              IN         NUMBER, 
    task_name        IN         VARCHAR2,
    comp_exec_name   IN         VARCHAR2,
    spa_task         OUT NOCOPY task_spaobj);


  ------------------------------ get_wkldtype_name ----------------------------
  -- NAME: 
  --     get_wkldtype_name
  --
  -- DESCRIPTION:
  --     This function returns the string version of the workload type 
  --     number.
  --
  -- PARAMETERS:
  --     type_num  (IN) - OBJ_XXX# constant
  --
  -- RETURN:
  --     Workload type name
  -----------------------------------------------------------------------------
  FUNCTION get_wkldtype_name(type_num IN NUMBER)
  RETURN   VARCHAR2;

  --------------------------------- validate_name -----------------------------
  -- NAME: 
  --     validate_name
  --
  -- DESCRIPTION:
  --     This function checks whether a given name (e.g., sqlset name) is valid
  --     A name must not.  It is just a syntactic checker, i.e. it does not
  --     check to see if the object actually exists.
  --
  -- PARAMETERS:
  --     name       (IN) - a given name
  --
  -- RETURN:
  --     VOID.
  -- 
  -- EXCEPTIONS
  --     TO BE DONE
  ---------------------------------------------------------------------------- 
  PROCEDURE validate_name(name IN VARCHAR2);

  -------------------------- alter_session_parameter -------------------------
  -- NAME: 
  --     alter_session_parameter
  --
  -- DESCRIPTION:
  --     This function sets the indicated parameter to a hardcoded value 
  --     if it is currently different, and returns a boolean value indicating
  --     whether or not the value had to be changed.
  --
  --     It is designed to be pretty generic so we can use it for different
  --     parameters but not so generic to cause SQL injections.  Right now
  --     it won't work for anything more than a simple on/off value.  
  --     Values are hardcoded because for the simple boolean scenario it is 
  --     unlikely that we would need to change a session parameter to have
  --     different values.  Typical usage model is as follows:
  --
  --     prm_set := alter_session_parameter(PNUM_XXX);
  --
  --     ...
  --
  --     if (prm_set) then
  --       restore_session_parameter(PNUM_XXX);
  --     end if;
  --
  -- PARAMETERS:
  --     pnum  (IN) - parameter number as PNUM_XXX constant
  --         PNUM_SYSPLS_OBEY_FORCE: set _parallel_syspls_obey_force to FALSE
  --           
  --
  -- RETURN:
  --     TRUE if the parameter value needed to be changed
  ---------------------------------------------------------------------------- 
  PNUM_SYSPLS_OBEY_FORCE CONSTANT NUMBER := 1;    -- change from TRUE to FALSE

  FUNCTION alter_session_parameter(pnum IN NUMBER)
  RETURN BOOLEAN; 

  -------------------------- restore_session_parameter -----------------------
  -- NAME: 
  --     restore_session_parameter
  --
  -- DESCRIPTION:
  --     This function follows up on a call to set_session_parameter by
  --     clearing it back to its initial value.  It should only be called 
  --     when the set function returns TRUE indicating the value was changed.
  --
  -- PARAMETERS:
  --     pnum  (IN) - parameter number as PNUM_XXX constant
  --
  -- RETURN:
  --     NONE
  ---------------------------------------------------------------------------- 
  PROCEDURE restore_session_parameter(pnum IN NUMBER);

  ------------------------------- get_current_time ---------------------------
  -- NAME: 
  --     get_current_time
  --
  -- DESCRIPTION:
  --     Just a wrapper around ksugctm().
  --
  -- PARAMETERS:
  --     None
  --
  -- RETURN:
  --     current time (from ksugctm) as DATE
  ---------------------------------------------------------------------------- 
  FUNCTION get_current_time 
  RETURN DATE;
  

END dbms_sqltune_util1; 
/
show errors; 

-------------------------------------------------------------------------------
--                    dbms_sqltune_util2 package declaration                 --
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- NAME:
--     dbms_sqltune_util2
--
-- DESCRIPTION:
--     This package is for shared utility functions that need to be part of
--     an INVOKER rights package.  Like the other dbms_sqltune_utilX packages,
--     it should NOT be documented.  If a function only needs
--     to be accessible from the dbms_sqltune/sqldiag/etc feature layer, do
--     not put it here, but rather in the infrastructure layer (prvssqlf). This
--     layer is for code that should be globally accessible, even from the
--     internal package.
--
-- PROCEDURES: 
--     The package contains the following utilities:
--       - resolve_username
--       - sql_binds_ntab_to_varray
--       - sql_binds_varray_to_ntab
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_sqltune_util2 AUTHID CURRENT_USER AS

  ------------------------------ resolve_username -----------------------------
  -- NAME: 
  --     resolve_username
  --
  -- DESCRIPTION:
  --     When passed a NULL name, this function returns the current schema
  --     owner.  Otherwise, it returns the name passed in, after validating
  --     it.
  --
  -- PARAMETERS:
  --     user_name    (IN) - the name of the user to resolve
  --     validate     (IN) - true/false validate user name if one is given
  --
  -- RETURN:
  --      VOID
  -----------------------------------------------------------------------------
  FUNCTION resolve_username(user_name IN VARCHAR2,
			    validate  IN BOOLEAN := TRUE)
  RETURN VARCHAR2;

  -------------------------------- validate_snapshot --------------------------
  -- NAME: 
  --     validate_snapshot
  --
  -- DESCRIPTION:
  --     This function checks whether a snapshot id interval is valid.
  --     It raises an error if passed an invalid interval.
  --
  -- PARAMETERS:
  --     begin_snap (IN) - begin snapshot id
  --     end_snap   (IN) - end snapshot id
  --     incl_bid   (IN) - TRUE:  fully-inclusive [begin_snap, end_snap]
  --                       FALSE: half-inclusive  (begin_snap, end_snap]
  --
  -- RETURN:
  --      VOID
  -----------------------------------------------------------------------------
  PROCEDURE validate_snapshot(
    begin_snap IN NUMBER, 
    end_snap   IN NUMBER,
    incl_bid   IN BOOLEAN := FALSE);

  --------------------------- sql_binds_ntab_to_varray ------------------------
  -- NAME: 
  --     sql_binds_ntab_to_varray
  --
  -- DESCRIPTION:
  --     This function converts the sql binds data from the nested table stored
  --     in the staging table on an unpack/pack to the varray type used in the
  --     SQLSET_ROW. It is called by the unpack_stgtab_sqlset function since it
  --     needs to pass binds as a VARRAY to the load_sqlset function
  --
  -- PARAMETERS:
  --     binds_nt      (IN)  - list of binds for a single statement, in the
  --                           sql_binds nested table type
  --                       
  -- RETURN:
  --     Corresponding varray type (sql_binds_varray) to the input, which is
  --     an ordered list of bind values, of type ANYDATA.
  --     If given null as input this function returns null.
  --
  -----------------------------------------------------------------------------
  FUNCTION sql_binds_ntab_to_varray(binds_ntab IN SQL_BIND_SET)
  RETURN SQL_BINDS;

  ------------------------- sql_binds_varray_to_ntab -------------------------
  -- NAME: 
  --     sql_binds_varray_to_ntab
  --
  -- DESCRIPTION:
  --     This function converts the sql binds data from a VARRAY as it exists
  --     in SQLSET_ROW into a nested table that can be stored in the staging 
  --     table.
  --     It is called by pack_stgtab_sqlset as it inserts into the staging 
  --     table from the output of a call to select_sqlset.
  --
  -- PARAMETERS:
  --     binds_varray      (IN)  - list of binds for a single statement, in the
  --                               sql_binds VARRAY type
  --                       
  -- RETURN:
  --     Corresponding nested table type (sql_bind_set) to the input, which is
  --     a list of (position, value) pairs for the information in STMT_BINDS.
  --     If given null as input this function returns null.
  --
  -----------------------------------------------------------------------------
  FUNCTION sql_binds_varray_to_ntab(binds_varray IN SQL_BINDS)
  RETURN SQL_BIND_SET;

  ----------------------------------- check_priv ------------------------------
  -- NAME: 
  --     check_priv
  --
  -- DESCRIPTION:
  --     This function does a callout into the kernel to check for the given 
  --     system privilege.  It returns TRUE or FALSE based on whether the
  --     current user has the privilege enabled.  This replaces the old-style
  --     privilege detection through SQL with the added benefit that it allows
  --     auditing of the privilege.  This function is just a wrapper around
  --     kzpcap.  This is used for the ADVISOR, ADMINISTER SQL TUNING SET,
  --     and ADMINISTER ANY SQL TUNING SET privileges.
  --
  --     NOTE that this function should only be used when checking privileges
  --     from an INVOKER rights package.  In the callout function we do not
  --     switch the user prior to calling kzpcap, so we rely on the proper
  --     security context already being in effect prior to calling this 
  --     function.  If you call it after switching into a DEFINER rights 
  --     package, it will end up checking if SYS has the priv, not the user.
  --     If you have any questions about its proper use, please consult the 
  --     file owner.
  --
  -- PARAMETERS:
  --     priv (IN) - privilege name
  --                       
  -- RETURN:
  --     TRUE if priv is enabled, FALSE otherwise
  --
  -----------------------------------------------------------------------------
  FUNCTION check_priv(priv IN VARCHAR2)
  RETURN BOOLEAN;

  ------------------------------- resolve_exec_name ---------------------------
  -- NAME: 
  --     resolve_exec_name
  --
  -- DESCRIPTION:
  --     This function validates the execution name of a SPA task to ensure 
  --     it was a Compare Performance (type id 5) while if NULL was supplied,
  --     it returns the name of the most recent compare execution for the  
  --     given SPA task
  --
  --
  -- PARAMETERS:
  --     task_name         (IN)     - name of the SPA task whose execution we
  --                                  are examining
  --     compare_exec_name (IN/OUT) - execution name
  --                       
  -- RETURN:
  --     TRUE if exec_name was valid or we found a valid compare execution 
  --     name of the given SPA task, FALSE otherwise
  --
  -----------------------------------------------------------------------------
  FUNCTION resolve_exec_name(
    task_name   IN     VARCHAR2, 
    task_owner  IN     VARCHAR2,
    exec_name   IN OUT VARCHAR2)
  RETURN NUMBER;

END dbms_sqltune_util2;
/
show errors;
/

GRANT EXECUTE ON DBMS_SQLTUNE_UTIL2 TO PUBLIC
/
