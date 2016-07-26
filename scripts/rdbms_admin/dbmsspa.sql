Rem
Rem $Header: rdbms/admin/dbmsspa.sql /main/11 2009/11/16 21:03:25 hayu Exp $
Rem
Rem dbmsspa.sql
Rem
Rem Copyright (c) 2007, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsspa.sql - DBMS SQL Performance Analyzer
Rem
Rem    DESCRIPTION
Rem      This package provides the main APIs for SQL Performance Analyzer
Rem
Rem    NOTES
Rem      None for now. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hayu        09/11/09 - add task parameter EXECUTE_COUNT
Rem    kyagoub     06/08/09 - rename trace flag of remote spa
Rem    kyagoub     05/14/09 - add KESATM_SQL_FLG_ZEROROWS &
Rem                           KESATM_SQL_FLG_DIFFROWS
Rem    kyagoub     05/01/09 - bug#8207896: add kestsRemoteExecSqlExt
Rem    kyagoub     04/17/09 - bug#8207896: no xml/objects in remote_process_sql
Rem    hayu        03/23/09 - add parameter to remote_process_sql
Rem    kyagoub     04/01/09 - create_analysis_task/sqlset: change default
Rem    pbelknap    03/05/09 - #7916459: materialize io read requests / io write
Rem                           requests
Rem    shjoshi     01/16/09 - Add error numbers for SPA
Rem    hayu        12/12/08 - add extra argument to remote_process_sql
Rem    shjoshi     10/31/08 - Add callout fn get_sess_optimizer_env 
Rem    kyagoub     02/03/08 - log full exec stat for remote test execute
Rem    kyagoub     01/27/08 - add support for remote test execute on 11g
Rem    kyagoub     12/09/07 - add remote test-execute and explain plan actions
Rem    kyagoub     04/18/07 - Created
Rem


-------------------------------------------------------------------------------
--                      DBMS_SQLPA FUNCTION DESCRIPTION                      --
-------------------------------------------------------------------------------
---------------------
--  Main functions
---------------------
--   create_analysis_task:        create an advisor task to process and 
--                                analyze one or more SQL
--   set_analysis_task_parameter: set sql analysis task parameter value
--   execute_analysis_task:       run a previously-created task
--   interrupt_analysis_task:     interrupt a task that is running
--   cancel_analysis_task:        cancel a task that is running, 
--                                removing its results.
--   reset_analysis_task:         prepare a task to be re-executed
--   drop_analysis_task:          drop the advisor task, deleting all data
--   resume_analysis_task:        continue a previously interrupted task
--   report_analysis_task:        get a report of a analysis task results
--
---------------------
--  Utility functions
---------------------
--  none for now.
--
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--                  Library where 3GL callouts will reside                   --
-------------------------------------------------------------------------------
-- I am creating it simply to reserve the library name. I am not really using 
-- it for now. All calout are sunign dbms_sqltune_lib. 
CREATE OR REPLACE LIBRARY dbms_sqlpa_lib trusted as static
/
show errors;
/

-------------------------------------------------------------------------------
--                       dbms_sqlpa package declaration                      --
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_sqlpa AUTHID CURRENT_USER AS

  -----------------------------------------------------------------------------
  --                      global constant declarations                       --
  -----------------------------------------------------------------------------
  ERR_NO_EXEC2                  CONSTANT NUMBER := -15740;
  ERR_NO_COMPARE_EXEC           CONSTANT NUMBER := -15741; 
  ERR_INV_EXEC_NAME             CONSTANT NUMBER := -15742;

  -----------------------------------------------------------------------------
  --                    procedure / function declarations                    --
  -----------------------------------------------------------------------------

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                      -----------------------------                      --
  --                        MAIN PROCEDURES/FUNCTIONS                        --
  --                      -----------------------------                      --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

  --------------------- create_analysis_task - sql text format ----------------
  -- NAME: 
  --     create_analysis_task - CRATE an ANALYSIS TASK in order to process 
  --       and analyzer perfromance of a single SQL statement (sql text format)
  --
  -- DESCRIPTION
  --     This function is called to prepare the analysis of a single statement
  --     given its text. The function mainly creates an advisor task and sets 
  --     its parameters. 
  --
  -- PARAMETERS:
  --     sql_text       (IN) - text of a SQL statement
  --     bind_list      (IN) - a set of bind values
  --     parsing_schema (IN) - the username for who the statement will be tuned
  --     task_name      (IN) - optional analysis task name   
  --     description    (IN) - maximum of 256 SQL analysis description 
  --
  -- RETURNS:
  --     SQL analysis task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_analysis_task(
    sql_text       IN CLOB,
    bind_list      IN sql_binds := NULL,
    parsing_schema IN VARCHAR2  := NULL,
    task_name      IN VARCHAR2  := NULL,
    description    IN VARCHAR2  := NULL)
  RETURN VARCHAR2;
  
  -------------------- create_analysis_task - sql_id format -------------------
  -- NAME: 
  --     create_analysis_task - sql_id format
  --
  -- DESCRIPTION
  --     This function is called to prepare the analysis of a single statement
  --     from the cursor cache given its identifier. The function mainly 
  --     creates an advisor task and sets its parameters. 
  --
  -- PARAMETERS:
  --     sql_id          (IN) - identifier of the statement
  --     plan_hash_value (IN) - hash value of the sql execution plan
  --     task_name       (IN) - optional analysis task name 
  --     description     (IN) - maximum of 256 SQL analysis description
  --
  -- RETURNS:
  --     SQL analysis task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_analysis_task(
    sql_id          IN VARCHAR2, 
    plan_hash_value IN NUMBER   := NULL,     
    task_name       IN VARCHAR2 := NULL,
    description     IN VARCHAR2 := NULL)
  RETURN VARCHAR2;
  
  -------------- create_analysis_task - workload repository format ------------
  -- NAME: 
  --     create_analysis_task - workload repository format
  --
  -- DESCRIPTION
  --     This function is called to prepare the analysis of a single statement
  --     from the workload repository given a range of snapshot identifiers. 
  --     The function mainly creates an advisor task and sets its parameters. 
  --
  -- PARAMETERS:
  --     begin_snap      (IN) - begin snapshot identifier  
  --     end_snap        (IN) - end snapshot identifier  
  --     sql_id          (IN) - identifier of the statement
  --     plan_hash_value (IN) - plan hash value
  --     task_name       (IN) - optional analysis task name 
  --     description     (IN) - maximum of 256 SQL analysis description 
  --
  -- RETURNS:
  --     SQL analysis task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_analysis_task(
    begin_snap      IN NUMBER,
    end_snap        IN NUMBER,
    sql_id          IN VARCHAR2,
    plan_hash_value IN NUMBER   := NULL,
    task_name       IN VARCHAR2 := NULL,
    description     IN VARCHAR2 := NULL)
  RETURN VARCHAR2;
  
  ---------------------- create_analysis_task - sqlset format -----------------
  -- NAME: 
  --     create_analysis_task - sqlset format
  --
  -- DESCRIPTION:
  --     This function is called to prepare the analysis of a sql tuning set.
  --     The function mainly creates an advisor task and sets its parameters. 
  --
  -- PARAMETERS:
  --     sqlset_name       (IN) - sqlset name
  --     basic_filter      (IN) - SQL predicate to filter the SQL from the STS
  --     order_by          (IN) - an order-by clause on the selected SQL
  --     top_sql           (IN) - top N SQL after filtering and ranking
  --     task_name         (IN) - optional analysis task name 
  --     description       (IN) - maximum of 256 SQL analysis description
  --                             
  --     sqlset_owner      (IN) - the owner of the sqlset, or null for current
  --                              schema owner
  --
  -- RETURNS:
  --     SQL analysis task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_analysis_task(
    sqlset_name       IN VARCHAR2 :=  NULL,
    basic_filter      IN VARCHAR2 :=  NULL,
    order_by          IN VARCHAR2 :=  NULL,
    top_sql           IN NUMBER   :=  NULL,
    task_name         IN VARCHAR2 :=  NULL,     
    description       IN VARCHAR2 :=  NULL,
    sqlset_owner      IN VARCHAR2 :=  NULL)
  RETURN VARCHAR2;

  -------------------------- set_analysis_task_parameter ----------------------
  -- NAME: 
  --     set_analysis_task_parameter - set sql analysis task parameter value
  --
  -- DESCRIPTION:
  --     This procedure updates the value of a task analysis parameter
  --     of type VARCHAR2. The possible analysis parameters that can be set 
  --     by this procedure are: 
  --       MODE          : analysis scope (comprehensive, limited)
  --       BASIC_FILTER  : basic filter for sql analysis set
  --       PLAN_FILTER   : plan filter for sql tuning set (see select_sqlset 
  --                       for possible values)
  --       RANK_MEASURE1 : first ranking measure for sql analysis set
  --       RANK_MEASURE2 : second possible ranking measure for sql analysis set
  --       RANK_MEASURE3 : third possible ranking measure for sql analysis set
  --       RESUME_FILTER : a extra filter for sts besides basic_filter
  --
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to execute
  --     parameter (IN) - name of the parameter to set
  --     value     (IN) - new value of the specified parameter
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE set_analysis_task_parameter(
    task_name IN VARCHAR2,
    parameter IN VARCHAR2,
    value     IN VARCHAR2);

  -------------------------- set_analysis_task_parameter ----------------------
  -- NAME: 
  --     set_analysis_task_parameter - set sql analysis task parameter value
  --
  -- DESCRIPTION:
  --     This procedure updates the value of a sql analysis parameter
  --     of type NUMBER. The possible analysis parameters that can be set
  --     by this procedure are: 
  --       DAYS_TO_EXPIRE     : number of days until the task is deleted
  --       TIME_LIMIT         : global time out 
  --       LOCAL_TIME_LIMIT   : local time out
  --       SQL_LIMIT          : maximum number of sts statements to tune
  --       SQL_PERCENTAGE     : percentage filter of sts statements
  --       EXECUTE_COUNT      : multiple execution count to be used 
  --                            in the test execute. We intend to execute 
  --                            them multiple times in test execute.
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to execute
  --     parameter (IN) - name of the parameter to set
  --     value     (IN) - new value of the specified parameter
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE set_analysis_task_parameter(
    task_name IN VARCHAR2,
    parameter IN VARCHAR2,
    value     IN NUMBER);

  ----------------------- set_analysis_default_parameter ----------------------
  -- NAME: 
  --     set_analysis_default_parameter - set sql analysis task parameter 
  --                                      default value
  --
  -- DESCRIPTION:
  --     This procedure is called to update the DEFAULT value of an analyzer
  --     parameter of type VARCHAR2. 
  --
  -- PARAMETERS:
  --     parameter (IN) - name of the parameter to set
  --     value     (IN) - new value of the specified parameter
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE set_analysis_default_parameter(
    parameter IN VARCHAR2,
    value     IN VARCHAR2);

  ------------------------ set_analysis_default_parameter ---------------------
  -- NAME: 
  --     set_analysis_default_parameter - set sql analysis task parameter 
  --                                      default value
  --
  -- DESCRIPTION:
  --     This procedure is called to update the default value of an analyzer
  --     parameter of type NUMBER. 
  --
  -- PARAMETERS:
  --     parameter (IN) - name of the parameter to set
  --     value     (IN) - new value of the specified parameter
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE set_analysis_default_parameter(
    parameter IN VARCHAR2,
    value     IN NUMBER);
  
  ----------------------------- execute_analysis_task -------------------------
  -- NAME: 
  --     execute_analysis_task - execute a sql analysis task
  --
  -- DESCRIPTION:
  --     This procedure is called to execute a previously created analysis task
  --
  -- PARAMETERS:
  --     task_name          (IN) - identifier of the task to execute
  --     execution_type     (IN) - type of the action to perform. Possible
  --                               values are: [TEST] EXECUTE (default),
  --                                           EXPLAIN [PLAN], 
  --                                           COMPARE [PERFORMANCE]
  --                               If NULL it will default to the value of 
  --                               the DEFAULT_EXECUTION_TYPE parameter. 
  --     execution_name     (IN) - A name to qualify and identify an execution.
  --                               If not specified, it be generated by 
  --                               the advisor and returned by function. 
  --     execution_params   (IN) - List of parameters (name, value) for 
  --                               the specified execution. 
  --                               Note that execution parameters are real 
  --                               task parameters that have effect only on 
  --                               the execution they specified for. 
  --                               Example: 
  --                               dbms_advisor.arglist('time_limit',
  --                                                     1000,
  --                                                    'COMPARE_METRIC', 
  --                                                    'buffer_gets * 10')
  --     execution_desc     (IN) - A 256-length string 
  --
  -- RETURNS:
  --     The function version returns the name of the new execution
  -----------------------------------------------------------------------------
  -- function flavor
  FUNCTION execute_analysis_task(
    task_name           IN VARCHAR2,
    execution_type      IN VARCHAR2             := 'test execute',
    execution_name      IN VARCHAR2             := NULL,
    execution_params    IN dbms_advisor.argList := NULL,
    execution_desc      IN VARCHAR2             := NULL)
  RETURN VARCHAR2;

  -- procedure flavor
  PROCEDURE execute_analysis_task(
    task_name           IN VARCHAR2,
    execution_type      IN VARCHAR2             := 'test execute',
    execution_name      IN VARCHAR2             := NULL,
    execution_params    IN dbms_advisor.argList := NULL,
    execution_desc      IN VARCHAR2             := NULL);
    
  ----------------------------- interrupt_analysis_task -----------------------
  -- NAME: 
  --     interrupt_analysis_task - interrupt a sql analysis task
  --
  -- DESCRIPTION:
  --     This procedure interrupts the currently executing analysis task.
  --     The task will end its operations as it would at a normal exit 
  --     so that the user will be able to access the intermediate results at
  --     this point. 
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to execute
  -----------------------------------------------------------------------------
  procedure interrupt_analysis_task(task_name IN VARCHAR2);
  
  ----------------------------- cancel_analysis_task --------------------------
  -- NAME: 
  --     cancel_analysis_task - cancel a sql analysis task
  --
  -- DESCRIPTION:
  --     This procedure is called to cancel the currently executing analysis 
  --     task. All intermediate result data will be removed from the task.
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to execute
  ----------------------------------------------------------------------------
  PROCEDURE cancel_analysis_task(task_name IN VARCHAR2);
  
  ----------------------------- reset_analysis_task --------------------------
  -- NAME: 
  --     reset_analysis_task - reset a sql analysis task
  --
  -- DESCRIPTION:
  --     This procedure resets an analysis task to its initial state. 
  --     All intermediate result data will be deleted.  Call this procedure on
  --     a task that is not currently executing.
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to reset
  -----------------------------------------------------------------------------
  PROCEDURE reset_analysis_task(task_name IN VARCHAR2);
  
  ------------------------------- drop_analysis_task --------------------------
  -- NAME: 
  --     drop_analysis_task - drop a sql analysis task
  --
  -- DESCRIPTION:
  --     This procedure is called to drop a SQL analysis task. 
  --     The task and All its result data will be deleted.
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to execute
  -----------------------------------------------------------------------------
  PROCEDURE drop_analysis_task(task_name IN VARCHAR2);
  
  ----------------------------- resume_analysis_task --------------------------
  -- NAME: 
  --     resume_analysis_task - resume a sql analysis task
  --
  -- DESCRIPTION:
  --     This procedure resumes a previously interrupted task execution. 
  --
  -- PARAMETERS:
  --     task_name    (IN) - identifier of the task to execute
  --     basic_filter (IN) - a SQL predicate to filter the SQL from a STS. 
  --                         Note that this filter will be applied in 
  --                         conjunction with the basic filter 
  --                         (i.e., parameter basic_filter) specified 
  --                         when calling create_analysis_task. 
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE resume_analysis_task(
    task_name    IN VARCHAR2, 
    basic_filter IN VARCHAR2 := NULL);

  ------------------------------- report_analysis_task ------------------------
  -- NAME: 
  --     report_analysis_task - report a SQL analysis task
  --
  -- DESCRIPTION:
  --     This procedure is called to display the results of a analysis task.
  --
  -- PARAMETERS:
  --     task_name      (IN) - name of the task to report. 
  --     type           (IN) - type of the report. 
  --                           Possible values are: TEXT (default), HTML, XML.
  --     level          (IN) - format of the recommendations. Possible values:
  --                           BASIC           - currently, same as typical
  --                           TYPICAL(default)- SQL with perf. changes+errors
  --                           ALL             - details of all SQL
  --                           IMPROVED        - only improved SQL
  --                           REGRESSED       - only regressed SQL
  --                           CHANGED         - only SQL with changed perf.
  --                           UNCHANGED       - only SQL with unchanged perf.
  --                           CHANGED_PLANS   - only SQL with plan changes
  --                           UNCHANGED_PLANS - only SQL with unchanged plans
  --                           ERRORS          - SQL with errors only
  --     section        (IN) - particular section in the report.  
  --                           Possible values are: 
  --                             SUMMARY (default) - workload summary only 
  --                             ALL               - summary + details on SQL
  --     object_id      (IN) - identifier of the advisor framework object that
  --                           represents a given SQL in a tuning set (STS).
  --     top_sql        (IN) - number of statements in a STS for which the
  --                           report is generated.  
  --     execution_name (IN) - name of the task execution to use. If NULL, the
  --                           report will be generated for the last task 
  --                           execution.
  --     task_owner     (IN) - owner of the relevant analysis task.  
  --                           Defaults to the current schema owner.
  --     order_by       (IN) - how to sort SQL statements in the report
  --                           (summary and body). Possible values are: 
  --                           + NULL (default) : order by impact on workload
  --                           + workload_impact: same as null
  --                           + sql_impact     : order by change impact on SQL
  --                           + metric_delta/change_diff: order by change 
  --                               difference in SQL perfomance in terms 
  --                               of the Comparison Metric. 
  -- RETURNS
  --     A clob containing the desired report. 
  -- 
  -- NOTE: 
  --     So far order_by can be used only one report is generated for 
  --     a comparison and not for a single test execute or explain plan. 
  -----------------------------------------------------------------------------
  FUNCTION report_analysis_task(
    task_name      IN VARCHAR2,
    type           IN VARCHAR2 := 'text',
    level          IN VARCHAR2 := 'typical',
    section        IN VARCHAR2 := 'summary', 
    object_id      IN NUMBER   := NULL,
    top_sql        IN NUMBER   := 100,
    execution_name IN VARCHAR2 := NULL,
    task_owner     IN VARCHAR2 := NULL,
    order_by       IN VARCHAR2 := NULL)
  RETURN clob; 

  -----------------------------------------------------------------------------
  -- NAME: 
  --     get_sess_optimizer_env - get session optimizer env 
  --
  -- DESCRIPTION:
  --     This function is a callout function to get the compilation 
  --     environment from the session for a remote SPA trial. The CE
  --     itself is returned in its compact linear representation as a 
  --     RAW data type.
  --
  -- PARAMETERS:
  --     NONE
  --
  -- RETURNS
  --     A raw containing the compilation environment
  --
  -----------------------------------------------------------------------------
  FUNCTION get_sess_optimizer_env
  RETURN RAW;

  ----------------------------------------------------------------------------
  --                                                                        --
  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --
  -- !!!  UNDOCUMENTED FUNCTIONS AND PROCEDURES. FOR INTERNAL USE ONLY  !!! --
  -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --
  --                                                                        --
  ----------------------------------------------------------------------------
  -- 
  ----------------------------------------------------------------------------
  --                    procedure / function declarations                   --
  ----------------------------------------------------------------------------
  ----------------------------- remote_process_sql ---------------------------
  PROCEDURE remote_process_sql(
    sql_text                IN  CLOB, 
    parsing_schema          IN  VARCHAR2,
    bind_data               IN  RAW, 
    bind_list               IN  SQL_BINDS,
    action                  IN  VARCHAR2,
    time_limit              IN  NUMBER,
    plan_hash1              OUT NUMBER,
    buffer_gets             OUT NUMBER,
    cpu_time                OUT NUMBER,
    elapsed_time            OUT NUMBER,
    disk_reads              OUT NUMBER,
    disk_writes             OUT NUMBER,
    rows_processed          OUT NUMBER,
    optimizer_cost          OUT NUMBER, 
    parse_time              OUT NUMBER,
    err_code                OUT NUMBER,
    err_mesg                OUT VARCHAR2,
    trace_flags             IN  BINARY_INTEGER := 0,
    extra_res               OUT NOCOPY VARCHAR2,
    other_xml               IN  OUT NOCOPY VARCHAR2,
    physical_read_requests  OUT NUMBER,
    physical_write_requests OUT NUMBER,
    physical_read_bytes     OUT NUMBER,
    physical_write_bytes    OUT NUMBER,
    user_io_time            OUT NUMBER,
    plan_hash2              OUT NUMBER,
    io_interconnect_bytes   OUT NUMBER,
    action_flags            IN  BINARY_INTEGER := 0,
    control_options_xml     IN  VARCHAR2       := NULL);

END dbms_sqlpa;
/
show errors;


------------------------------------------------------------------------------
--                    Public synonym for the package                        --
------------------------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM dbms_sqlpa FOR dbms_sqlpa
/
show errors;

------------------------------------------------------------------------------
--            Granting the execution privilege to the public role           --
------------------------------------------------------------------------------
GRANT EXECUTE ON dbms_sqlpa TO public
/
show errors;
  

