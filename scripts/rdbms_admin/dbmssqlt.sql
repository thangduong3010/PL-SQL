Rem
Rem $Header: rdbms/admin/dbmssqlt.sql /main/62 2010/05/10 20:24:09 pbelknap Exp $
Rem
Rem dbmssqlt.sql
Rem
Rem Copyright (c) 2002, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmssqlt.sql - DBMS SQL Tune
Rem
Rem    DESCRIPTION
Rem     This package provides the APIs to tune SQL statements. 
Rem     It contains the procedure and function declaration OF three (03) 
Rem     main sqltune modules:
Rem        1- sqlTune 
Rem        2- sqlset  
Rem        3- sqlProfile
Rem  
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    04/14/10 - add dbms_auto_sqltune
Rem    pbelknap    03/23/10 - add select_sqlpa_task
Rem    bdagevil    12/31/09 - #9229095: align stash data with activity data
Rem    cgervasi    11/16/09 - sql details: add duration_history,data_source
Rem    arbalakr    11/12/09 - add new sqlset staging table version
Rem    hayu        09/30/09 - add filter for recursive sqls
Rem    lgalanis    09/08/09 - add replay helper to inspect an sts staging table
Rem    cgervasi    07/09/09 - sql_detail: change default report type
Rem    cgervasi    04/22/09 - change comment sql_detail comment
Rem    pbelknap    03/23/09 - reorder arguments to report_sql_monitor_xml
Rem    cgervasi    03/19/09 - add sql_plan_hash_value to sql_monitor
Rem                           add sql_detail
Rem    bdagevil    02/26/09 - add stash support
Rem    shjoshi     02/10/09 - bg8243982: Add fns for moving STS to 10.2 and 11.1
Rem    shjoshi     08/18/08 - Add create_tuning_task API that uses SPA task
Rem    hayu        01/16/09 - add alternative plans to script_tuning_task
Rem    hayu        11/17/08 - add create_sql_plan_baseline interface
Rem    hayu        06/27/08 - add new parameter to accept_sql_profile
Rem    pbelknap    10/27/08 - test_execute: full/auto/off
Rem    bdagevil    11/15/08 - src_path -> base_path
Rem    pbelknap    10/22/08 - select/capture plans by default
Rem    bdagevil    09/27/08 - kghscDumpData(): use UTS
Rem    bdagevil    09/23/08 - REPORT_SQL_MONITOR_XML() signature change
Rem    bdagevil    07/31/08 - improve report_sql_monitor_list_xml()
Rem    hayu        07/29/08 - remove synonym from mapping_table
Rem    bdagevil    07/09/08 - add src_path
Rem    bdagevil    07/05/08 - fix comment for report_sql_monitor()
Rem    pbelknap    03/06/08 - set_auto_tuning_task_parameter
Rem    hayu        02/12/08 - change the default mapping table to NULL
Rem    hayu        01/16/08 - add select_mode to select_sql_trace
Rem    pbelknap    01/13/08 - remove comments for fetch_sql_trace_next_sql
Rem    pbelknap    01/11/08 - correct select_sql_trace comment
Rem    hayu        01/10/08 - add default mapping table name
Rem    hayu        01/08/08 - add option to select_sql_trace
Rem    hayu        12/11/07 - add select_sql_trace
Rem    kyagoub     04/18/07 - move sqlpa to a new package dbms_sqlpa
Rem    pbelknap    05/06/07 - fix comment
Rem    bdagevil    04/26/07 - do not resignal external errors
Rem    bdagevil    04/18/07 - fix issue with additionnal rows
Rem    bdagevil    04/17/07 - fix issue with additionnal rows
Rem    bdagevil    03/25/07 - add report object for SQL monitor
Rem    pbelknap    04/06/07 - bug# 5917151 - pass profile as xml
Rem    pbelknap    03/20/07 - remove extra args to report_auto_t_t
Rem    kyagoub     04/08/07 - add sqlset_progress_stats
Rem    hosu        04/03/07 - update comments
Rem    hosu        03/12/07 - use "ADMINISTER SQL MANAGEMENT OBJECT" privilege
Rem                           instead of "*** ANY SQL PROFILE" privilege
Rem    pbelknap    12/01/06 - fix comments on report_auto_tuning_task
Rem    pbelknap    01/10/07 - move functions to dbms_sqltune_util3
Rem    rdongmin    12/28/06 - make validate_name and check_sqlset_privs public
Rem    hosu        08/07/06 - make resolve_user_name public
Rem    pbelknap    09/07/06 - bug 5501150 - change prepare_awr_statement
Rem    kyagoub     08/06/06 - fix comment for create_tuning_task
Rem    kyagoub     06/22/06 - rename paramList to argList 
Rem    kyagoub     06/09/06 - add goal arg to create_tuning_task APIs 
Rem    pbelknap    06/01/06 - add test-execute task parameter 
Rem    pbelknap    04/03/06 - new automatic apis 
Rem    kyagoub     05/12/06 - add a function version of execute_tuning_task 
Rem    pbelknap    04/03/06 - new internal funcs
Rem    kyagoub     04/25/06 - add exec_name to report/script_tuning_task 
Rem    pbelknap    08/08/05 - fix sqltext_to_signature comment 
Rem    dsampath    05/26/05 - add a new flavour of sqltext_to_signature
Rem    kyagoub     03/31/05 - fix resume_tuning_task 
Rem    pbelknap    02/18/05 - change capture comments 
Rem    pbelknap    02/21/05 - fix report comment 
Rem    kyagoub     11/03/04 - add set_tuning_task_parameter APIs 
Rem    kyagoub     09/30/04 - replace sql_binds_ntab_row/sql_bind and 
Rem                           sql_binds_ntab/sql_bind_set 
Rem    kyagoub     09/26/04 - add support for bind_data 
Rem    pbelknap    08/25/04 - add defaults for select_xxx
Rem    bdagevil    07/26/04 - add extract_bind 
Rem    kyagoub     07/14/04 - move i_transform_sqlset_cursor from the internal 
Rem                           package 
Rem    kyagoub     06/29/04 - remove tabs 
Rem    kyagoub     06/25/04 - update attribute_list comments 
Rem    kyagoub     06/20/04 - add plan_filter to select_sqlset 
Rem    pbelknap    06/18/04 - capture test 
Rem    kyagoub     06/10/04 - overload update_sqlset 
Rem    pbelknap    06/11/04 - full capture 
Rem    kyagoub     06/01/04 - add owner to report_tuning_task 
Rem    kyagoub     06/01/04 - add summary section to tuning report 
Rem    pbelknap    05/17/04 - imp/exp sqlprof 
Rem    kyagoub     05/11/04 - add attribute_list to select_xxx functions 
Rem    pbelknap    04/29/04 - export import sts 
Rem    kyagoub     04/28/04 - replace parsing_schema_id/parsing_schema_name 
Rem    mramache    05/07/04 - sql profiles for literal SQL 
Rem    pbelknap    02/06/04 - create/replace 
Rem    pbelknap    03/01/04 - autocommit, new ownership model 
Rem    pbelknap    12/23/03 - adding script func for sqltune 
Rem    pbelknap    12/11/03 - adding procedure versions to API 
Rem    pbelknap    12/05/03 - allow sts creation without specifying name 
Rem    kyagoub     11/16/03 - remove tabs 
Rem    kyagoub     11/14/03 - add task_owner parameter to accept_sql_profile 
Rem    amysoren    08/28/03 - add interface to get signature of sqltext 
Rem    kyagoub     07/11/03 - change signature of report_tuning_task
Rem    kyagoub     07/09/03 - fix report for sqlset
Rem    kyagoub     07/03/03 - change report to a function returning a clob
Rem    kyagoub     06/22/03 - make accept_sql_profile a function
Rem    mramache    06/20/03 - sql_profile
Rem    kyagoub     05/19/03 - change create_tuning_task for cursor and swrf.
Rem    kyagoub     05/09/03 - use of object_id instead of statement_id
Rem    bdagevil    05/09/03 - remove tabs
Rem    kyagoub     05/05/03 - add sql_record type
Rem    bdagevil    04/26/03 - replace signature/sql_id
Rem    kyagoub     04/14/03 - rename delete_tuning_task/drop_tuning_task
Rem    bdagevil    04/28/03 - merge new file
Rem    aime        04/25/03 - aime_going_to_main
Rem    kyagoub     03/10/03 - add scope/default value for time limit
REM                           support of task name 
Rem    kyagoub     02/14/03 - enable sqlset privileges
Rem    kyagoub     02/07/03 - remore username fro report function
Rem    kyagoub     01/21/03 - add username to the report function
Rem    kyagoub     11/29/02 - rename type wri$_sql_binds to sql_binds
Rem    kyagoub     11/20/02 - change the data type of advMode 
Rem                           from boolean TO varchar2
Rem    kyagoub     11/06/02 - replace swoid/swoname in sqltune swo interface
Rem    kyagoub     11/04/02 - replace child_number/child_address
Rem    kyagoub     11/03/02 - add exec and endFetch stats 
Rem                           to cursor cache sqltune interface
Rem    mramache    01/15/03 - mramache_5955_stb
Rem    mramache    01/13/03 - get rid of hard-tabs
Rem    mramache    01/06/03 - update comments
Rem    mramache    09/26/02 - Created
Rem

------------------------------------------------------------------------------
--                   DBMS_SQLTUNE FUNCTION DESCRIPTIONS                     --
------------------------------------------------------------------------------
--  SQL Tuning Set functions
-----------------------------
--    DDL
--     create_sqlset:        create a SQL tuning set (create DDL)
--     drop_sqlset:          drop a SQL tuning set   (drop DDL)
--
--    DML
--     delete_sqlset:        delete statements from SQL tuning set (delete DML)
--     load_sqlset:          load statements into SQL tuning set   (insert DML)
--     update_sqlset:        update statements in a SQL tuning set (update DML)
--
--     capture_cursor_cache_sqlset: incrementally capture statements from
--                            the cursor cache into a SQL tuning set, repeating
--                            over a fixed interval.
--
--
--    add/remove_sqlset_reference: add/remove a reference to a SQL tuning set
--    
--    select_cursor_cache/workload_repository/sqlset: select statements from
--                           a data source and return them in a format ready to
--                           be inserted into a SQL tuning set.
--    select_sql_trace:      same as the above only for SQL trace files
--    select_sqlpa_task:     same as the above, only for a SPA trial  
--
--    Import/Export
--      create_stgtab_sqlset: create staging table
--      pack_stgtab_sqlset:   dump SQL tuning set(s) into staging table
--      unpack_stgtab_sqlset: create SQL tuning set(s) from staging table data
--      remap_stgtab_sqlset:  update data in staging table
--
---------------------
--  SqlTune functions
---------------------
--
--   create_tuning_task:        create an Advisor task to tune one or more SQL
--   set_tuning_task_parameter: set sql tuning task parameter value
--   execute_tuning_task:       run a previously-created task
--   interrupt_tuning_task:     interrupt a task that is running
--   cancel_tuning_task:        cancel a task that is running, 
--                              removing its results.
--   reset_tuning_task:         prepare a task to be re-executed
--   drop_tuning_task:          drop the advisor task, deleting all data
--   resume_tuning_task:        continue a previously interrupted task
--   
--   report_tuning_task:        get a text report of a tuning task results
--   script_tuning_task:        get a SQL*Plus script to impl. recommendations
--   
--   create_sql_plan_baseline:  create a plan baseline for an existing plan 
--  
--   For automatic tuning task only:
--     report_auto_tuning_task:        get a report from the automatic task
--     See DBMS_AUTO_SQLTUNE, below, for more.
--
-------------------------
--  SQL Profile functions
-------------------------
--   DDL
--    accept_sql_profile:    create a sql profile recommended by SQLTune
--    drop_sql_profile:      permanently remove a sql profile from the system
--    alter_sql_profile:     change an attribute of a sql profile
--    
--   Import/Export
--    create_stgtab_sqlprof: create a staging table to store SQL profiles
--    pack_stgtab_sqlprof:   insert one or more profiles into the staging table
--    unpack_stgtab_sqlprof: create a sql profile from staging table data
--    remap_stgtab_sqlprof:  update data in the staging table
--
---------------------
--  Utility functions
---------------------
--
--   extract_bind:          given the value of a bind_data column captued 
--                          from v$sql and a bind position, return the value of
--                          the associated bind variable (an object of type 
--                          sql_bind). NULL is returned if the bind variable
--                          was not captured.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
--    CATALOG OBJECTS - THIS SECTION IS HERE ONLY FOR COMPILATION REASONS    --
-------------------------------------------------------------------------------
 
-------------------------------------------------------------------------------
--                  Library where 3GL callouts will reside                   --
-------------------------------------------------------------------------------
CREATE OR REPLACE LIBRARY dbms_sqltune_lib trusted as static
/
show errors;

-------------------------------------------------------------------------------
--                     dbms_sqltune package declaration                      --
-------------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_sqltune AUTHID CURRENT_USER AS
  -----------------------------------------------------------------------------
  --                      global constant declarations                       --
  -----------------------------------------------------------------------------
  --
  -- sqltune advisor name 
  ADV_SQLTUNE_NAME  CONSTANT VARCHAR2(18) := 'SQL Tuning Advisor'; 

  --
  -- SQLTune advisor task scope parameter values 
  --
  SCOPE_LIMITED       CONSTANT VARCHAR2(7)  := 'LIMITED';
  SCOPE_COMPREHENSIVE CONSTANT VARCHAR2(13) := 'COMPREHENSIVE';
  
  --
  --  SQLTune advisor time_limit constants
  --
  TIME_LIMIT_DEFAULT  CONSTANT   NUMBER := 1800;  
  
  --
  -- report type (possible values) constants  
  --
  TYPE_TEXT           CONSTANT   VARCHAR2(4) := 'TEXT'       ; 
  TYPE_XML            CONSTANT   VARCHAR2(3) := 'XML'        ;
  TYPE_HTML           CONSTANT   VARCHAR2(4) := 'HTML'       ;
  
  --
  -- report level (possible values) constants  
  --
  LEVEL_TYPICAL       CONSTANT   VARCHAR2(7) := 'TYPICAL'    ; 
  LEVEL_BASIC         CONSTANT   VARCHAR2(5) := 'BASIC'      ;
  LEVEL_ALL           CONSTANT   VARCHAR2(3) := 'ALL'        ;

  --
  -- report section (possible values) constants  
  --
  SECTION_FINDINGS    CONSTANT   VARCHAR2(8) := 'FINDINGS'   ; 
  SECTION_PLANS       CONSTANT   VARCHAR2(5) := 'PLANS'      ;
  SECTION_INFORMATION CONSTANT   VARCHAR2(11):= 'INFORMATION';
  SECTION_ERRORS      CONSTANT   VARCHAR2(6) := 'ERRORS'     ;
  SECTION_ALL         CONSTANT   VARCHAR2(3) := 'ALL'        ;
  SECTION_SUMMARY     CONSTANT   VARCHAR2(7) := 'SUMMARY'    ; 

  -- some common date format
  DATE_FMT       constant varchar2(21)       :=  'mm/dd/yyyy hh24:mi:ss';

  --
  -- script section constants
  --
  REC_TYPE_ALL          CONSTANT   VARCHAR2(3)  := 'ALL';
  REC_TYPE_SQL_PROFILES CONSTANT   VARCHAR2(8)  := 'PROFILES';
  REC_TYPE_STATS        CONSTANT   VARCHAR2(10) := 'STATISTICS';
  REC_TYPE_INDEXES      CONSTANT   VARCHAR2(7)  := 'INDEXES';
  REC_TYPE_PX           CONSTANT   VARCHAR2(18) := 'PARALLEL_EXECUTION';
  REC_TYPE_ALTER_PLANS  CONSTANT   VARCHAR2(17) := 'ALTERNATIVE_PLANS';

  --
  -- capture section constants
  --
  MODE_REPLACE_OLD_STATS CONSTANT   NUMBER := 1;
  MODE_ACCUMULATE_STATS  CONSTANT   NUMBER := 2;
  
  --
  -- SQL tuning set constants
  --
  SINGLE_EXECUTION       CONSTANT   POSITIVE := 1;
  ALL_EXECUTIONS         CONSTANT   POSITIVE := 2;
  LIMITED_COMMAND_TYPE   CONSTANT   BINARY_INTEGER  := 1;
  ALL_COMMAND_TYPE       CONSTANT   BINARY_INTEGER  := 2;

  --
  -- SQL profile type
  --
  REGULAR_PROFILE        CONSTANT   VARCHAR2(11) := 'SQL PROFILE';
  PX_PROFILE             CONSTANT   VARCHAR2(10) := 'PX PROFILE';

  -- sqlset staging table constants
  STS_STGTAB_10_2_VERSION     CONSTANT NUMBER := 1;
  STS_STGTAB_11_1_VERSION     CONSTANT NUMBER := 2;
  STS_STGTAB_11_2_VERSION     CONSTANT NUMBER := 3;
  STS_STGTAB_11_202_VERSION   CONSTANT NUMBER := 4;
  

  -- constant for recursive sql filter
  NO_RECURSIVE_SQL            CONSTANT VARCHAR2(30) := 'N';
  HAS_RECURSIVE_SQL           CONSTANT VARCHAR2(30) := 'Y';

  -----------------------------------------------------------------------------
  --                    procedure / function declarations                    --
  -----------------------------------------------------------------------------

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                      -----------------------------                      --
  --                      SQL TUNE PROCEDURES/FUNCTIONS                      --
  --                      -----------------------------                      --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

  --------------------- create_tuning_task - sql text format ------------------
  -- NAME: 
  --     create_tuning_task - CRATE a TUNING TASK in order to tune a single SQL
  --     statement (sql text format)
  --
  -- DESCRIPTION
  --     This function is called to prepare the tuning of a single statement
  --     given its text. 
  --     The function mainly creates an advisor task and sets its parameters. 
  --
  -- PARAMETERS:
  --     sql_text    (IN) - text of a SQL statement
  --     bind_list   (IN) - a set of bind values
  --     user_name   (IN) - the username for who the statement will be tuned
  --     scope       (IN) - tuning scope (limited/comprehensive)
  --     time_limit  (IN) - maximum duration in second for the tuning session
  --     task_name   (IN) - optional tuning task name   
  --     description (IN) - maximum of 256 SQL tuning session description 
  --
  -- RETURNS:
  --     SQL tuning task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_tuning_task(
    sql_text    IN CLOB,
    bind_list   IN sql_binds := NULL,
    user_name   IN VARCHAR2  := NULL,
    scope       IN VARCHAR2  := SCOPE_COMPREHENSIVE,
    time_limit  IN NUMBER    := TIME_LIMIT_DEFAULT,
    task_name   IN VARCHAR2  := NULL,
    description IN VARCHAR2  := NULL)
  RETURN VARCHAR2;
  
  --------------------- create_tuning_task - sql_id format --------------------
  -- NAME: 
  --     create_tuning_task - sql_id format
  --
  -- DESCRIPTION
  --     This function is called to prepare the tuning of a single statement
  --     from the Cursor Cache given its identifier. 
  --     The function mainly creates an advisor task and sets its parameters. 
  --
  -- PARAMETERS:
  --     sql_id          (IN) - identifier of the statement
  --     plan_hash_value (IN) - hash value of the sql execution plan
  --     scope           (IN) - tuning scope (limited/comprehensive)  
  --     time_limit      (IN) - maximum tuning duration in second
  --     task_name       (IN) - optional tuning task name 
  --     description     (IN) - maximum of 256 SQL tuning session description 
  --
  -- RETURNS:
  --     SQL tuning task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_tuning_task(
    sql_id          IN VARCHAR2, 
    plan_hash_value IN NUMBER   := NULL,     
    scope           IN VARCHAR2 := SCOPE_COMPREHENSIVE,    
    time_limit      IN NUMBER   := TIME_LIMIT_DEFAULT, 
    task_name       IN VARCHAR2 := NULL,     
    description     IN VARCHAR2 := NULL)
  RETURN VARCHAR2;
  
  -------------- create_tuning_task - workload repository format --------------
  -- NAME: 
  --     create_tuning_task - workload repository format
  --
  -- DESCRIPTION
  --     This function is called to prepare the tuning of a single statement
  --     from the workload repository given a range of snapshot identifiers. 
  --     The function mainly creates an advisor task and sets its parameters. 
  --
  -- PARAMETERS:
  --     begin_snap      (IN) - begin snapshot identifier  
  --     end_snap        (IN) - end snapshot identifier  
  --     sql_id          (IN) - identifier of the statement
  --     plan_hash_value (IN) - plan hash value
  --     scope           (IN) - tuning scope (limited/comprehensive)  
  --     time_limit      (IN) - maximum duration in second for tuning 
  --     task_name       (IN) - optional tuning task name 
  --     description     (IN) - maximum of 256 SQL tuning session description 
  --
  -- RETURNS:
  --     SQL tuning task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_tuning_task(
    begin_snap      IN NUMBER,
    end_snap        IN NUMBER,
    sql_id          IN VARCHAR2, 
    plan_hash_value IN NUMBER   := NULL,     
    scope           IN VARCHAR2 := SCOPE_COMPREHENSIVE,    
    time_limit      IN NUMBER   := TIME_LIMIT_DEFAULT, 
    task_name       IN VARCHAR2 := NULL,     
    description     IN VARCHAR2 := NULL)
  RETURN VARCHAR2;
  
  ---------------------- create_tuning_task - sqlset format -------------------
  -- NAME: 
  --     create_tuning_task - sqlset format
  --
  -- DESCRIPTION:
  --     This function is called to prepare the tuning of a sqlset
  --     The function mainly creates an advisor task and sets its parameters. 
  --
  -- PARAMETERS:
  --     sqlset_name       (IN) - sqlset name
  --     basic_filter      (IN) - SQL predicate to filter the SQL from the STS
  --     object_filter     (IN) - object filter
  --     rank(i)           (IN) - an order-by clause on the selected SQL
  --     result_percentage (IN) - a percentage on the sum of a ranking measure
  --     result_limit      (IN) - top L(imit) SQL from the (filtered/ranked) SQL
  --     scope             (IN) - tuning scope (limited/comprehensive)    
  --     time_limit        (IN) - maximum tuning duration in seconds
  --     task_name         (IN) - optional tuning task name 
  --     description       (IN) - maximum of 256 SQL tuning session description
  --     plan_filter       (IN) - plan filter. It is applicable in case there 
  --                              are multiple plans (plan_hash_value) 
  --                              associated to the same statement. This filter
  --                              allows selecting one plan (plan_hash_value) 
  --                              only. Possible values are:
  --                              + LAST_GENERATED: plan with most recent 
  --                                                timestamp.
  --                              + FIRST_GENERATED: opposite to LAST_GENERATED
  --                              + LAST_LOADED: plan with most recent 
  --                                             first_load_time stat info. 
  --                              + FIRST_LOADED: opposite to LAST_LOADED
  --                              + MAX_ELAPSED_TIME: plan with max elapsed 
  --                                                  time
  --                              + MAX_BUFFER_GETS: plan with max buffer gets
  --                              + MAX_DISK_READS: plan with max disk reads
  --                              + MAX_DIRECT_WRITES: plan with max direct 
  --                                                   writes
  --                              + MAX_OPTIMIZER_COST: plan with max opt. cost
  --                             
  --     sqlset_owner      (IN) - the owner of the sqlset, or null for current
  --                              schema owner
  --
  -- RETURNS:
  --     SQL tuning task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_tuning_task(
    sqlset_name       IN VARCHAR2,
    basic_filter      IN VARCHAR2 :=  NULL,
    object_filter     IN VARCHAR2 :=  NULL,
    rank1             IN VARCHAR2 :=  NULL,
    rank2             IN VARCHAR2 :=  NULL,
    rank3             IN VARCHAR2 :=  NULL,
    result_percentage IN NUMBER   :=  NULL,
    result_limit      IN NUMBER   :=  NULL,
    scope             IN VARCHAR2 :=  SCOPE_COMPREHENSIVE,    
    time_limit        IN NUMBER   :=  TIME_LIMIT_DEFAULT, 
    task_name         IN VARCHAR2 :=  NULL,     
    description       IN VARCHAR2 :=  NULL,
    plan_filter       IN VARCHAR2 :=  'MAX_ELAPSED_TIME',
    sqlset_owner      IN VARCHAR2 :=  NULL)
  RETURN VARCHAR2;

  ---------------------- create_tuning_task - SPA Task format -----------------
  -- NAME: 
  --     create_tuning_task - SQL Performance Analyzer (SPA) task format
  --
  -- DESCRIPTION:
  --     This function is called to prepare the tuning of sql stmts obtained
  --     from a SPA task. The specified (or latest) 'compare performance' 
  --     trial of the SPA task is checked for regressed SQLs and only those SQL
  --     statements are tuned by the tuning task. The regressed SQLs are tuned
  --     using the compilation environment captured during the second execution
  --     trial of the SPA task.
  --     The function mainly creates an advisor task and sets its parameters. 
  --
  -- PARAMETERS:
  --     spa_task_name     (IN) - SPA task name
  --     spa_task_owner    (IN) - Owner of specified SPA task or null for 
  --                              current user
  --     spa_compare_exec  (IN) - Execution name of Compare Performance trial of
  --                              SPA task. If NULL, we use the most recent 
  --                              execution of the given SPA task, of type 
  --                              'compare performance'
  --     basic_filter      (IN) - SQL predicate to filter the SQL from the STS
  --     time_limit        (IN) - Execution time limit
  --     task_name         (IN) - optional tuning task name 
  --     description       (IN) - maximum of 256 SQL tuning session description
  --
  -- RETURNS:
  --     SQL tuning task unique name
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION create_tuning_task(
    spa_task_name     IN VARCHAR2,
    spa_task_owner    IN VARCHAR2 :=  NULL,
    spa_compare_exec  IN VARCHAR2 :=  NULL,
    basic_filter      IN VARCHAR2 :=  NULL,
    time_limit        IN NUMBER   :=  TIME_LIMIT_DEFAULT, 
    task_name         IN VARCHAR2 :=  NULL,     
    description       IN VARCHAR2 :=  NULL)
  RETURN VARCHAR2;

  -------------------------- set_tuning_task_parameter ------------------------
  -- NAME: 
  --     set_tuning_task_parameter - set sql tuning task parameter value
  --
  -- DESCRIPTION:
  --     This procedure is called to update the value of a sql tuning parameter
  --     of type VARCHAR2.
  --     The task must be set to its initial state before calling this 
  --     procedure. The possible tuning parameters that can be set by this 
  --     procedure are: 
  --       MODE          : tuning scope (comprehensive, limited)
  --       USERNAME      : username under which the statement will be parsed
  --       BASIC_FILTER  : basic filter for sql tuning set
  --       OBJECT_FILTER : object filter for sql tuning set
  --       PLAN_FILTER   : plan filter for sql tuning set (see select_sqlset 
  --                       for possible values)
  --       RANK_MEASURE1 : first ranking measure for sql tuning set
  --       RANK_MEASURE2 : second possible ranking measure for sql tuning set
  --       RANK_MEASURE3 : third possible ranking measure for sql tuning set
  --       RESUME_FILTER : a extra filter for sts besides basic_filter
  --       TEST_EXECUTE  : FULL/AUTO/OFF whether the advisor should test-
  --                       execute sql statements to verify the recommendation
  --                       benefit.
  --                          - FULL test-executes up to the local time limit
  --                          - AUTO test-executes for an automatically-chosen
  --                            period
  --
  --     The following parameters are supported for the automatic tuning task
  --     only:
  --       ACCEPT_SQL_PROFILES       : TRUE/FALSE whether the system should
  --                                   accept SQL Profiles automatically
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
  PROCEDURE set_tuning_task_parameter(
    task_name IN VARCHAR2,
    parameter IN VARCHAR2,
    value     IN VARCHAR2);

  -------------------------- set_tuning_task_parameter ------------------------
  -- NAME: 
  --     set_tuning_task_parameter - set sql tuning task parameter value
  --
  -- DESCRIPTION:
  --     This procedure is called to update the value of a sql tuning parameter
  --     of type NUMBER. The task must be set to its initial state before 
  --     calling this procedure. The possible tuning parameters that can be set
  --     by this procedure are: 
  --       DAYS_TO_EXPIRE     : number of days until the task is deleted
  --       EXECUTION_DAYS_TO_
  --        EXPIRE            : number of days until the tasks's executions
  --                            will be deleted (without deleting the task)
  --       TARGET_OBJECTS     : id of advisor framework object to tune
  --       TIME_LIMIT         : global time out 
  --       LOCAL_TIME_LIMIT   : local time out
  --       SQL_LIMIT          : maximum number of sts statements to tune
  --       SQL_PERCENTAGE     : percentage filter of sts statements
  --       COMMIT_ROWS        : number of tuned statements after which tuning 
  --                            results will be commited to be accessible by
  --                            the user.
  --
  --     The following parameters are supported for the automatic tuning task
  --     only:
  --       MAX_SQL_PROFILES_PER_EXEC : Max # of SQL Profiles to create per run
  --       MAX_AUTO_SQL_PROFILES     : Max # of automatic SQL Profiles allowed
  --                                   on the system in total
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
  PROCEDURE set_tuning_task_parameter(
    task_name IN VARCHAR2,
    parameter IN VARCHAR2,
    value     IN NUMBER);

  ----------------------------- set_tuning_task_parameter ---------------------
  -- NAME: 
  --     set_tuning_task_parameter - set sql tuning task parameter 
  --                                 default value
  --
  -- DESCRIPTION:
  --     This procedure is called to update the default value of a sql tuning 
  --     parameter of type VARCHAR2. The task must be set to its initial state 
  --     before calling this procedure (see set_tuning_task_parameter above 
  --     for more details about possible parameters and their possible values 
  --     that can be set by this procedure). 
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
  PROCEDURE set_tuning_task_parameter(
    parameter IN VARCHAR2,
    value     IN VARCHAR2);

  ------------------------- set_tuning_task_parameter -------------------------
  -- NAME: 
  --     set_tuning_task_parameter - set sql tuning task parameter 
  --                                 default value
  --
  -- DESCRIPTION:
  --     This procedure is called to update the default value of a sql tuning 
  --     parameter of type NUMBER. The task must be set to its initial state 
  --     before calling this procedure (see set_tuning_task_parameter above 
  --     for more details about possible parameters and their possible values 
  --     that can be set by this procedure). 
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
  PROCEDURE set_tuning_task_parameter(
    parameter IN VARCHAR2,
    value     IN NUMBER);
  
  ------------------------------ execute_tuning_task --------------------------
  -- NAME: 
  --     execute_tuning_task - execute a sql tuning task
  --
  -- DESCRIPTION:
  --     This procedure is called to execute a previously created tuning task
  --
  -- PARAMETERS:
  --     task_name        (IN) - identifier of the task to execute
  --     execution_name   (IN) - A name to qualify and identify an execution
  --                             If not specified, it be generated by 
  --                             the advisor and returned by function. 
  --     execution_params (IN) - List of parameters (name, value) for 
  --                             the specified execution. Notice that execution
  --                             parameters are real task parameters that
  --                             have effect only on the execution they 
  --                             specified for. 
  --                             Example: 
  --                             dbms_advisor.arglist('time_limit', 12, 
  --                                                  'username', 'foo')
  --     execution_desc   (IN) - A 256-length string describing the execution. 
  --
  -- RETURNS:
  --     The function version returns the name of the new execution
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION execute_tuning_task(
    task_name        IN VARCHAR2,
    execution_name   IN VARCHAR2               := NULL,
    execution_params IN dbms_advisor.argList   := NULL,
    execution_desc   IN VARCHAR2               := NULL) 
  RETURN VARCHAR2;
  --
  PROCEDURE execute_tuning_task(
    task_name        IN VARCHAR2,
    execution_name   IN VARCHAR2               := NULL,
    execution_params IN dbms_advisor.argList   := NULL,
    execution_desc   IN VARCHAR2               := NULL);

    
  ----------------------------- interrupt_tuning_task -------------------------
  -- NAME: 
  --     interrupt_tuning_task - interrupt a sql tuning task
  --
  -- DESCRIPTION:
  --     This procedure is called to interrupt the currently executing tuning 
  --     task. The task will end its operations as it would at a normal exit 
  --     so that the user will be able to access the intermediate results at
  --     this point. 
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to execute
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  procedure interrupt_tuning_task(task_name IN VARCHAR2);
  
  ----------------------------- cancel_tuning_task ----------------------------
  -- NAME: 
  --     cancel_tuning_task - cancel a sql tuning task
  --
  -- DESCRIPTION:
  --     This procedure is called to cancel the currently executing tuning 
  --     task. All intermediate result data will be removed from the task.
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to execute
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE cancel_tuning_task(task_name IN VARCHAR2);
  
  ----------------------------- reset_tuning_task -----------------------------
  -- NAME: 
  --     reset_tuning_task - reset a sql tuning task
  --
  -- DESCRIPTION:
  --     This procedure is called to reset a tuning task to its initial state. 
  --     All intermediate result data will be deleted.  Call this procedure on
  --     a task that is not currently executing.
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to reset
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE reset_tuning_task(task_name IN VARCHAR2);
  
  ------------------------------- drop_tuning_task ----------------------------
  -- NAME: 
  --     drop_tuning_task - drop a sql tuning task
  --
  -- DESCRIPTION:
  --     This procedure is called to drop a SQL tuning task. 
  --     The task and All its result data will be deleted.
  --
  -- PARAMETERS:
  --     task_name (IN) - identifier of the task to execute
  --
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE drop_tuning_task(task_name IN VARCHAR2);
  
  ----------------------------- resume_tuning_task ----------------------------
  -- NAME: 
  --     resume_tuning_task - resume a sql tuning task
  --
  -- DESCRIPTION:
  --     This procedure is called to resume a previously interrupted task.
  --
  -- PARAMETERS:
  --     task_name    (IN) - identifier of the task to execute
  --     basic_filter (IN) - a SQL predicate to filter the SQL from a STS. 
  --                         Note that this filter will be applied in 
  --                         conjunction with the basic filter 
  --                         (i.e., parameter basic_filter) specified 
  --                         when calling create_tuning_task. 
  -- RETURNS:
  --     NONE
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  PROCEDURE resume_tuning_task(
    task_name    IN VARCHAR2, 
    basic_filter IN VARCHAR2 := NULL);

  ------------------------------- report_tuning_task --------------------------
  -- NAME: 
  --     report_tuning_task - report a SQL tuning task
  --
  -- DESCRIPTION:
  --     This procedure is called to display the results of a tuning task.
  --
  -- PARAMETERS:
  --     task_name      (IN) - name of the task to report. 
  --     type           (IN) - type of the report. 
  --                           Possible values are: TEXT, HTML, XML.
  --     level          (IN) - format of the recommendations.
  --                           Possible values are TYPICAL, BASIC, ALL.
  --     section        (IN) - particular section in the report.  
  --                           Possible values are: 
  --                             SUMMARY, 
  --                             FINDINGS, 
  --                             PLAN, 
  --                             INFORMATION,
  --                             ERROR, 
  --                             ALL.
  --     object_id      (IN) - identifier of the advisor framework object that 
  --                           represents a given statement in a SQL Tuning Set
  --                          (STS).   
  --     result_limit   (IN) - number of statements in a STS for which the
  --                           report is generated.  
  --     owner_name     (IN) - owner of the relevant tuning task.  Defaults to
  --                           the current schema owner.
  --     execution_name (IN) - name of the task execution to use. If NULL, the
  --                           report will be generated for the last task 
  --                           execution.
  -- RETURNS
  --     A clob containing the desired report. 
  -----------------------------------------------------------------------------
  FUNCTION report_tuning_task(
    task_name      IN VARCHAR2,
    type           IN VARCHAR2 := TYPE_TEXT,
    level          IN VARCHAR2 := LEVEL_TYPICAL,
    section        IN VARCHAR2 := SECTION_ALL, 
    object_id      IN NUMBER   := NULL,
    result_limit   IN NUMBER   := NULL,
    owner_name     IN VARCHAR2 := NULL,
    execution_name IN VARCHAR2 := NULL)
  RETURN clob;   
   
  ------------------------------ script_tuning_task ---------------------------
  -- NAME: 
  --     script_tuning_task - get a script to implement a subset of 
  --                          recommendations.
  --
  -- DESCRIPTION:
  --     This function will return a CLOB containing the PL/SQL calls
  --     to be executed to implement the subset of recommendations dictated by
  --     the arguments.  This script should then by checked by the DBA and 
  --     executed.
  --
  --     Wrap with a call to dbms_advisor.create_file to put it into a file.
  --
  -- PARAMETERS:
  --     task_name      (IN) - name of the task to get a script for
  --     rec_type       (IN) - filter the script by types of recommendations 
  --                           to include.
  --                           Any subset of the following separated by commas,
  --                           or 'ALL':    'PROFILES' 'STATISTICS' 'INDEXES'
  --                           'ALTERNATIVE_PLANS'
  --                           e.g. script with profiles and stats: 
  --                               'PROFILES, STATISTICS'
  --     object_id      (IN) - optionally filter by a single object ID
  --     result_limit   (IN) - optionally show commands for only top N sql
  --                           (ordered by object id and ignored if an 
  --                            object_id is also specified)
  --     owner_name     (IN) - owner of the relevant tuning task.  Defaults to
  --                           the current schema owner.
  --     execution_name (IN) - name of the task execution to use. If NULL, the
  --                           script will be generated for the last task 
  --                           execution.
  -- RETURNS
  --     script as a CLOB
  -----------------------------------------------------------------------------
  FUNCTION script_tuning_task(
    task_name      IN VARCHAR2,
    rec_type       IN VARCHAR2 := REC_TYPE_ALL,
    object_id      IN NUMBER   := NULL,
    result_limit   IN NUMBER   := NULL,
    owner_name     IN VARCHAR2 := NULL,
    execution_name IN VARCHAR2 := NULL)
  RETURN CLOB;


  ------------------------------ create_sql_plan_baseline ----------------------
  -- NAME: 
  --     create_sql_plan_baseline - create a sql plan baseline 
  --                                for an existing plan
  --
  -- DESCRIPTION:
  --    SQL tune advisor will detect regressions. If there are better plans
  --    than the original one, the advisor will recommend you to use this API
  --    to prevent the regression in the future. 
  --
  -- PARAMETERS:
  --     task_name       (IN) - name of the task to get a script for
  --     object_id       (IN) - the object ID which the sql is corresponding to
  --     plan_hash_value (IN) - the plan to create plan baseline
  --     owner_name      (IN) - owner of the relevant tuning task.  Defaults to
  --                            the current schema owner.
  -- RETURNS
  --     NONE
  -----------------------------------------------------------------------------
  PROCEDURE create_sql_plan_baseline(
    task_name            IN VARCHAR2,
    object_id            IN NUMBER := NULL,
    plan_hash_value      IN NUMBER,
    owner_name           IN VARCHAR2 := NULL);

  ---------------------------- implement_tuning_task --------------------------
  -- NAME: 
  --     implement_tuning_task - implement a set of recommendations from a 
  --                             tuning task
  --
  -- DESCRIPTION:
  --     This function will implement a set of SQL Profile recommendations made
  --     by the SQL Tuning Advisor.  Calling it is analogous to calling 
  --     script_tuning_task and then running the script.
  --
  -- PARAMETERS:
  --     task_name      (IN) - name of the task to get a script for
  --     rec_type       (IN) - filter the types of recs to implement.
  --                           Currently the only one supported is 'PROFILES'.
  --     owner_name     (IN) - owner of the relevant tuning task.  Defaults to
  --                           the current schema owner.
  --     execution_name (IN) - name of the task execution to use. If NULL, the
  --                           script will be generated for the last task 
  --                           execution.
  -- RETURNS
  --     NONE
  -----------------------------------------------------------------------------
  PROCEDURE implement_tuning_task(
    task_name      IN VARCHAR2,
    rec_type       IN VARCHAR2 := REC_TYPE_SQL_PROFILES,
    owner_name     IN VARCHAR2 := NULL,
    execution_name IN VARCHAR2 := NULL);
  
  -----------------------------------------------------------------------------
  --                      automatic tuning task functions                    --
  -----------------------------------------------------------------------------
  -- NOTE that only an API for getting a report is provided here.  For all   --
  -- other usage of the automatic tuning task, please see DBMS_AUTO_SQLTUNE. --
  -----------------------------------------------------------------------------

  -------------------------------- report_auto_tuning_task --------------------
  -- NAME: 
  --     report_auto_tuning_task 
  --
  -- DESCRIPTION:
  --     Get a report from the automatic tuning task.  This differs from the
  --     report_tuning_task API in that it takes a range of subtasks to report
  --     on.
  --
  -- PARAMETERS:
  --     begin_exec     (IN) - name of execution to begin the report from. Null
  --                           to get a report on the most recent run.  See
  --                           DBA_ADVISOR_EXECUTIONS.
  --     end_exec       (IN) - name of execution to end the report at.  Null to
  --                           get a report on the most recent run.  See
  --                           DBA_ADVISOR_EXECUTIONS.
  --     type           (IN) - output type for report, one of:
  --                             TYPE_TEXT: text report
  --                             TYPE_HTML: html report
  --     level          (IN) - level of detail in the report:
  --                             LEVEL_BASIC: simple version of the report. 
  --                               Just show info about the actions taken by
  --                               the advisor.
  --                             LEVEL_TYPICAL: show info about every statement
  --                               analyzed, including recs not implemented.
  --                             LEVEL_ALL: verbose report level, also give
  --                               annotations about statements skipped over.
  --     section        (IN) - sections of report to show (comma-separated):
  --                             SECTION_SUMMARY     - summary information
  --                             SECTION_FINDINGS    - tuning findings
  --                             SECTION_PLAN        - explain plans
  --                             SECTION_INFORMATION - general information
  --                             SECTION_ERROR       - statements with errors
  --                             SECTION_ALL         - all statements
  --     object_id      (IN) - advisor framework object id that represents a 
  --                           single statement to restrict reporting to.  NULL
  --                           for all statements.  Only valid for reports 
  --                           that target a single execution.
  --     result_limit   (IN) - maximum number of SQL to show in the report
  --
  -- RETURNS:
  --     CLOB with report content
  --
  -- PRIVILEGES:
  --     Need SELECT privilege on the DBA_ADVISOR views
  -----------------------------------------------------------------------------
  FUNCTION report_auto_tuning_task(
    begin_exec     IN VARCHAR2  := NULL,
    end_exec       IN VARCHAR2  := NULL,
    type           IN VARCHAR2  := TYPE_TEXT,
    level          IN VARCHAR2  := LEVEL_TYPICAL,
    section        IN VARCHAR2  := SECTION_ALL,
    object_id      IN NUMBER    := NULL,
    result_limit   IN NUMBER    := NULL)
  RETURN CLOB;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                        ---------------------------                      --
  --                        SQLSET PROCEDURES/FUNCTIONS                      --
  --                        ---------------------------                      --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  
  -----------------------------------------------------------------------------
  --                                 Examples                                --
  -----------------------------------------------------------------------------
  -- In the following we give two examples that show how to use the package in 
  -- order to create, populate, manipulate and drop a sqlset. 
  -- The first example shows how to build a new sqlset by extracting 
  -- data from the Cursor cache, while the second one explains how to build a 
  -- sqlset from a USER defined workload. 
  --
  --------------------------------------------
  -- EXAMPLE 1: select from the cursor cache --
  --------------------------------------------
  --
  -- DECLARE
  --    sqlset_name  VARCHAR2(30);                            /* sqlset name */
  --    sqltset_cur  dbms_sqltune.sqlset_cursor; /* a sqlset cursor variable */
  --    ref_id       NUMBER;                      /* a reference on a sqlset */
  -- BEGIN
  --
  --   /* Choose an name for the sqlset to create */
  --   sqlset_name := 'SQLSET_TEST_1';
  --
  --   /* Create an empty sqlset. You automatically become the owner of 
  --      this sqlset */
  --   dbms_sqltune.create_sqlset(sqlset_name, 'test purpose');
  --
  --   /***********************************************************************
  --    * Call the select_cursor_cache table function to order the sql        *
  --    * statements in the cursor cache by cpu_time (ranking measure1) and   *
  --    * then, select only that subset of statements, which contribute to 90%*
  --    * (result percentage) of total cpu_time, but not more than Only 100   *
  --    * statements, i.e., top 100 which represents (result_limit).          *
  --    * Only the firts ranking measure is spefied and the content of        *
  --    * the cursor cache is not filtered.                                   *
  --    *                                                                     *
  --    * The OPEN-FOR statement associates the sqlset cursor variable        *
  --    * with the SELECT-FROM-TABLE dynamic query which is used to call the  *
  --    * table function and fetch its results. Notice that you need not to   *
  --    * close the cursor. When this cursor is used to populate a Sql Tuning *
  --    * Set using the load_sqlset procedure, this later will close          *
  --    * it for you.                                                         *
  --    *                                                                     *
  --    * Notice the use of function VALUE(P) which takes as its argument,    *
  --    * the table alias for the table function and returns object instances *
  --    * corresponding to rows as retuned by the table function which are    *
  --    * instances of type SQLSET_ROW.                                     *
  --    * ********************************************************************/
  --   OPEN sqlset_cur FOR
  --     SELECT VALUE(P)                            /* use of function VALUE */
  --     FROM TABLE(
  --      dbms_sqltune.select_cursor_cache(NULL,             /* basic filter */
  --                                       NULL,            /* object filter */
  --                                       'cpu_time',      /* first ranking */
  --                                       NULL,           /* second ranking */
  --                                       NULL,            /* third ranking */
  --                                       0.9,                /* percentage */
  --                                       100)                     /* top N */
  --               ) P;                                    /* table instance */
  --
  --
  --   /***********************************************************************
  --    * Call the load_sqlset procedure to populated the created             *
  --    * sqlset by the results of the cursor cache table function            *
  --    **********************************************************************/
  --    dbms_sqltune.load_sqlset(sqlset_name, sqlset_cur);
  --
  --   /***********************************************************************
  --    * Add a reference to the sqlset so that other users cannot            *
  --    * modified it, i.e., drop it, delete statement from it, update it or  *
  --    * load it. Like this, the sqlset is protected. User have only         *
  --    * a read-only access to the sqlset.                                   *
  --    * The add_reference function returns a reference ID that will be used *
  --    * later to deactivate the sqlset.                                     *
  --    **********************************************************************/
  --    ref_id := 
  --      dbms_sqltune.add_sqlset_reference(sqlset_name, 
  --                                        'test sqlset: '|| sqlset_name);
  --
  --    /* process your sqlset */
  --    ...
  --    ...
  --    ...
  --
  --    /**********************************************************************
  --     * When your are done, remove the reference on the sqlset, so that it *
  --     * can be modified either by you (owner) or by another user who has a *
  --     * supper privilege ADMINISTER ANY SQLSET, etc.                       *
  --     *********************************************************************/
  --     dbms_sqltune.remove_sqlset_reference(sqlset_name, ref_id);
  --
  --
  --     /* Call the drop procedure to drop the sqlset */
  --     dbms_sqltune.drop_sqlset(sqlset_name);
  --     ...
  -- END
  --
  -------------------------------------------
  -- EXAMPLE 2: select from a user workload --
  -------------------------------------------
  --
  -- DECLARE
  --    sqlset_name VARCHAR2(30);                             /* sqlset name */
  --    sqlset_cur  dbms_sqltune.sqlset_cursor;  /* a sqlset cursor variable */
  --    ref_id      NUMBER;                       /* a reference on a sqlset */
  -- BEGIN
  --
  --   /* Choose an name for the sqlset to create */
  --   sqlset_name := 'SQLSET_TEST_2';
  --
  --   /* Create an empty sqlset. You automatically become the owner of 
  --      this SQLSET */
  --   dbms_sqltune.create_sqlset(sqlset_name, 'test purpose');
  --
  --   /***********************************************************************
  --    * In this example we suppose that the user workload is stored in      *
  --    * a single table USER_WORKLOAD_TABLE. We suppose that the table stores*
  --    * only the text of a set of SQL statements identified by their sql_id.*
  --    * Use the OPEN-FOR statement to associate the query that extracts the *
  --    * content of the user workload, with a sqlset cursor before loading it*
  --    * into the sqlset.                                                    *
  --    * Notice the use of the CONSTRUCTOR of the sqlset_row object type     *
  --    * This is IMPORTANT because the cursor MUST contains instances        *
  --    * of this type as required by the load_sql function. Otherwise an     *
  --    * error will occur and the SQLSET will not be loaded.                 *
  --    **********************************************************************/
  --    OPEN sqlset_cur FOR
  --      SELECT 
  --        SQLSET_ROW(sql_id, sql_text, null, null, null, null,
  --                   null, 0, 0, 0, 0, 0, 0, 0, 0, 0, null, 0, 0, 0, 0
  --                   ) AS row 
  --        FROM user_workload_table;     
  --     
  --   /***********************************************************************
  --    * Call the load_sql procedure to populated the created sqlset by the  *
  --    * results of the cursor                                               *
  --    **********************************************************************/
  --   dbms_sqltune.load_sqlset(sqlsetname, sqlsetcur);
  --   
  --   /* the rest of the steps are similar to those in example 1 */
  --   ...
  --   ...
  --   ...
  -- END;
  --  
  -----------------------------------------------------------------------------
  
  -----------------------------------------------------------------------------
  --                               type declarations                         --
  -----------------------------------------------------------------------------
  ----------------------------------- sqlset_cursor ---------------------------
  -- NAME: 
  --     sqlset_cursor 
  --
  -- DESCRIPTION: 
  --     define a cursor type for SQL statements with their related data. 
  --     This type is mainly used by the load_sqlset procedure 
  --     as an argument to populate a sqlset from a possible data 
  --     source. See the load_sqlset description for more details.   
  --
  -- NOTES:
  --    It is important to keep in mind that this cursor is WEAKLY DEFINED.
  --    A variable of type sqlStatCursor when it is used either as an input
  --    by the load_sql procedure or returned by all table functions, it MUST
  --    contains rows of type sqlset_row.
  ----------------------------------------------------------------------------
  TYPE sqlset_cursor IS REF CURSOR;
  
  
  -----------------------------------------------------------------------------
  --                        procedure/function declarations                  --
  -----------------------------------------------------------------------------
  ---------------------------------- create_sqlset ----------------------------
  -- NAME:
  --     create_sqlset
  --
  -- DESCRIPTION:
  --     This procedure creates a sqlset object in the database.
  --
  -- PARAMETERS:
  --    sqlset_name  (IN) - the sqlset name
  --    description  (IN) - the description of the sqlset
  --    sqlset_owner (IN) - the owner of the sqlset, or null for current schema
  --                        owner
  -----------------------------------------------------------------------------
  PROCEDURE create_sqlset(
    sqlset_name  IN VARCHAR2,
    description  IN VARCHAR2 := NULL,
    sqlset_owner IN VARCHAR2 := NULL);
  
  ---------------------------------- create_sqlset ----------------------------
  -- NAME: 
  --     create_sqlset
  --
  -- DESCRIPTION: 
  --     This procedure creates a sqlset object in the database.
  --
  -- PARAMETERS:
  --    sqlset_name  (IN) - the sqlset name, can be NULL or omitted 
  --                        (in which case a name is generated automatically)
  --    description  (IN) - the description of the sqlset
  --    sqlset_owner (IN) - the owner of the sqlset, or null for current schema
  --                        owner
  --
  -- RETURNS:
  --     name of sqlset created.  This will be the name passed in or, if a name
  --     is omitted (or NULL arg passed), the name we automatically create for
  --     the sqlset
  -----------------------------------------------------------------------------
  FUNCTION create_sqlset(
    sqlset_name   IN VARCHAR2 := NULL,
    description   IN VARCHAR2 := NULL,
    sqlset_owner  IN VARCHAR2 := NULL)
  RETURN VARCHAR2;
  
  ----------------------------------- drop_sqlset -----------------------------
  -- NAME: 
  --     drop_sqlset
  --
  -- DESCRIPTION:
  --     This procedure is used to drop a sqlset if it is not active.
  --     When a sqlset is referenced by one or more clients 
  --     (e.g. SQL tune advisor), it cannot be dropped.
  --
  -- PARAMETERS:
  --     sqlset_name  (IN) - the sqlset name.
  --     sqlset_owner (IN) - the owner of the sqlset, or null for current 
  --                         schema owner
  -----------------------------------------------------------------------------
  PROCEDURE drop_sqlset(
    sqlset_name   IN VARCHAR2,
    sqlset_owner  IN VARCHAR2 := NULL);
  
  -------------------------------- delete_sqlset ------------------------------
  -- NAME: 
  --     delete_sqlset
  --
  -- DESCRIPTION:
  --     Allows the deletion of a set of SQL statements from a sqlset.
  --
  -- PARAMETERS:
  --     sqlset_name  (IN) - the sqlset name
  --     basic_filter (IN) - SQL predicate to filter the SQL from the 
  --                         sqlset. This basic filter is used as 
  --                         a where clause on the sqlset content to 
  --                         select a desired subset of Sql from the Tuning Set
  --     sqlset_owner (IN) - the owner of the sqlset, or null for current 
  --                         schema owner  
  -----------------------------------------------------------------------------
  PROCEDURE delete_sqlset(
    sqlset_name  IN VARCHAR2,
    basic_filter IN VARCHAR2 := NULL,  
    sqlset_owner IN VARCHAR2 := NULL);
  
  ---------------------------------- load_sqlset ------------------------------
  -- NAME: 
  --  load_sqlset
  --
  -- DESCRIPTION:
  --  This procedure populates the sqlset with a set of selected SQL.
  --
  -- PARAMETERS:
  --  sqlset_name        (IN) - the name of sqlset to populate
  --  populate_cursor    (IN) - the cursor reference to populate from
  --  load_option        (IN) - specifies how the statements will be loaded 
  --                            into the SQL tuning set. 
  --                            The possible values are: 
  --                             + INSERT (default):  add only new statements 
  --                             + UPDATE: update existing the SQL statements 
  --                             + MERGE: this is a combination of the two 
  --                                      other options. This option inserts 
  --                                      new statements and updates the 
  --                                      information of the existing ones. 
  --  update_option      (IN) - specifies how the existing statements will be 
  --                            updated. This parameter is considered only if 
  --                            load_option is specified with 'UPDATE'/'MERGE'
  --                            as an option. The possible values are:
  --                             + REPLACE (default): update the statement 
  --                                 using the new statistics, bind list, 
  --                                 object list, etc. 
  --                             + ACCUMULATE: when possible combine attributes
  --                                (e.g., statistics like elapsed_time, etc.) 
  --                                otherwise just replace the old values 
  --                                (e.g., module, action, etc.) by the new 
  --                                provided ones. The SQL statement attributes
  --                                that can be accumulated are: elapsed_time,
  --                                buffer_gets, disk_reads, row_processed, 
  --                                fetches, executions, end_of_fetch_count, 
  --                                stat_period and active_stat_period.
  --  update_attributes (IN) - specifies the list of a SQL statement attributes
  --                           to update during a merge or update operation.  
  --                           The possible values are:
  --                            + NULL (default): the content of the input 
  --                               cursor except the execution context. 
  --                               On other terms, it is equivalent to ALL 
  --                               without execution context like module,
  --                               action, etc. 
  --                            + BASIC: statistics and binds only.
  --                            + TYPICAL: BASIC + SQL plans (without 
  --                                   row source statistics) and without 
  --                                   object reference list. 
  --                            + ALL: all attributes including the execution
  --                                context attributes like module, action, etc
  --                            + List of comma separated attribute names to 
  --                                update: EXECUTION_CONTEXT,
  --                                        EXECUTION_STATISTICS,
  --                                        SQL_BINDS,
  --                                        SQL_PLAN,
  --                                        SQL_PLAN_STATISTICS: similar to
  --                                        SQL_PLAN + row source statistics.
  --  update_condition (IN) - specifies a where clause to execute the update 
  --                          operation. The update is performed only if 
  --                          the specified condition is true. The condition 
  --                          can refer to either the data source or 
  --                          destination. The condition must use the following
  --                          prefixes to refer to attributes from the source
  --                          or the destination:
  --                           + OLD: to refer to statement attributes from
  --                                  the SQL tuning set (destination)
  --                           + NEW: to refer to statements attributes from
  --                                  the input statements (source)
  --                         Example: 'new.executions >= old.executions'. 
  --  ignore_null     (IN) - If true do not update an attribute if the new 
  --                         value is null, i.e., do not override with null 
  --                         values unless it is intentional.
  --  commit_rows     (IN) - if a value is provided, the load will commit
  --                         after each set of that many statements is 
  --                         inserted.  If NULL is provided, the load will
  --                         commit only once, at the end of the operation.
  --  sqlset_owner    (IN) - the owner of the sqlset or null for current
  --                         schema owner.
  -- Exceptions:
  --  This procedure returns an error when sqlset_name is invalid 
  --  or a corresponding sqlset does not exist, the populate_cursor 
  --  is incorrect and cannot be executed.
  --  FIXME: other exceptions are raised by this procedure. Need to update 
  --         comments.
  -----------------------------------------------------------------------------
  PROCEDURE load_sqlset(
    sqlset_name       IN VARCHAR2,
    populate_cursor   IN sqlset_cursor,  
    load_option       IN VARCHAR2 := 'INSERT',  
    update_option     IN VARCHAR2 := 'REPLACE', 
    update_condition  IN VARCHAR2 :=  NULL,
    update_attributes IN VARCHAR2 :=  NULL, 
    ignore_null       IN BOOLEAN  :=  TRUE,
    commit_rows       IN POSITIVE :=  NULL,
    sqlset_owner      IN VARCHAR2 :=  NULL);

  ---------------------------- capture_cursor_cache_sqlset --------------------
  -- NAME: 
  --     capture_cursor_cache_sqlset
  --
  -- DESCRIPTION:
  --     This procedure captures a workload from the cursor cache into a SQL
  --     tuning set, polling the cache multiple times over a time period and
  --     updating the workload data stored there.  It can execute over as long
  --     a period as required to capture an entire system workload.
  --
  --     Note that this procedure commits after each incremental capture of
  --     statements, so you can monitor its progress by looking at the sqlset
  --     views.  This operation is much more efficient than 
  --     select_cursor_cache/load_sqlset so it should be used whenever you need
  --     to repeatedly capture a workload from the cursor cache.
  --
  --     ** ALSO NOTE ** This function does not capture the SQL present
  --     in the cursor cache when it is invoked, but rather it collects those
  --     SQL run over the 'time_limit' period in which it is executing.
  --
  -- PARAMETERS:
  --     sqlset_name     (IN)- the SQLSET name
  --     time_limit      (IN)- the total amount of time, in seconds, to execute
  --     repeat_interval (IN)- the amount of time, in seconds, to pause 
  --                           between sampling
  --     capture_option  (IN)- during capture, either insert new statements,
  --                           update existing ones, or both.  'INSERT', 
  --                           'UPDATE', or 'MERGE' just like load_option in
  --                           load_sqlset
  --     capture_mode    (IN)- capture mode (UPDATE and MERGE capture options).
  --                           Possible values:
  --                            + MODE_REPLACE_OLD_STATS - Replace statistics
  --                              when the number of executions seen is greater
  --                              than that stored in the STS
  --                            + MODE_ACCUMULATE_STATS - Add new values to 
  --                              current values for SQL we already store.
  --                              Note that this mode detects if a statement
  --                              has been aged out, so the final value for a
  --                              statistics will be the sum of the statistics
  --                              of all cursors that statement existed under.
  --     basic_filter    (IN)- filter to apply to cursor cache on each sampling
  --                            (see select_xxx)
  --     sqlset_owner    (IN)- the owner of the sqlset, or null for current
  --                           schema owner
  --     recursive_sql   (IN) - filter out the recursive SQL if NO_RECURSIVE_SQL
  -----------------------------------------------------------------------------
  PROCEDURE capture_cursor_cache_sqlset(
    sqlset_name         IN VARCHAR2,
    time_limit          IN POSITIVE := 1800,
    repeat_interval     IN POSITIVE := 300,
    capture_option      IN VARCHAR2 := 'MERGE',
    capture_mode        IN NUMBER   := MODE_REPLACE_OLD_STATS,
    basic_filter        IN VARCHAR2 := NULL,
    sqlset_owner        IN VARCHAR2 := NULL,
    recursive_sql       IN VARCHAR2 := HAS_RECURSIVE_SQL);
    
  ----------------------------------- update_sqlset ---------------------------
  -- NAME: 
  --     update_sqlset
  --
  -- DESCRIPTION:
  --     This procedure updates selected string fields for a SQL statement 
  --     in a sqlset.
  --     Fields that could be updated are MODULE, ACTION, PARSING_SCHEMA_NAME 
  --     and OTHER.
  --
  -- PARAMETERS:
  --     sqlset_name     (IN) - the SQLSET name
  --     sql_id          (IN) - identifier of the statement to update
  --     attribute_name  (IN) - the name of the attribute to modify. 
  --     attribute_value (IN) - the new value of the attribute
  --     sqlset_owner    (IN) - the owner of the sqlset, or null for current
  --                            schema owner
  -----------------------------------------------------------------------------
  PROCEDURE update_sqlset(
    sqlset_name     IN VARCHAR2,
    sql_id          IN VARCHAR2,
    attribute_name  IN VARCHAR2,
    attribute_value IN VARCHAR2 := NULL,
    sqlset_owner    IN VARCHAR2 := NULL);

  ----------------------------------- update_sqlset ---------------------------
  PROCEDURE update_sqlset(
    sqlset_name     IN VARCHAR2,
    sql_id          IN VARCHAR2,
    plan_hash_value IN NUMBER,
    attribute_name  IN VARCHAR2,
    attribute_value IN VARCHAR2 := NULL,
    sqlset_owner    IN VARCHAR2 := NULL);
  
  ----------------------------------- update_sqlset ---------------------------
  -- NAME: 
  --     update_sqlset
  --
  -- DESCRIPTION:
  --     This is an overloaded procedure of the previous one. It is provided 
  --     to be able to set numerical attributes of a SQL in a sqlset.
  --     The only NUMBER attribute that could be updated is PRIORITY. 
  --     If the statement has more than one plan (i.e., multiple plans with an 
  --     entry for every different plan_hash_value in plan table), 
  --     the attribute value will be then changed (replaced) for all plan 
  --     entries of the statement using the same (new) value. 
  --     To update the attribute value for a particular plan use the other 
  --     version of this procedure that, besides sql_id, it takes 
  --     a plan_hash_value as an argument. 
  --
  -- PARAMETERS: 
  --     sqlset_name     (IN) - the sqlset name
  --     sql_id          (IN) - identifier of the statement to update
  --     plan_hash_value (IN) - plan hash value of a particular plan of 
  --                            the SQL 
  --     attribute_name  (IN) - the name of the attribute to modify. 
  --     attribute_value (IN) - the new value of the attribute
  --     sqlset_owner    (IN) - the owner of the sqlset, or null for current
  --                            schema owner
  -----------------------------------------------------------------------------
  PROCEDURE update_sqlset(
    sqlset_name     IN VARCHAR2,
    sql_id          IN VARCHAR2,
    attribute_name  IN VARCHAR2,
    attribute_value IN NUMBER   := NULL,  
    sqlset_owner    IN VARCHAR2 := NULL);

  ----------------------------------- update_sqlset ---------------------------
  PROCEDURE update_sqlset(
    sqlset_name     IN VARCHAR2,
    sql_id          IN VARCHAR2,
    plan_hash_value IN NUMBER,
    attribute_name  IN VARCHAR2,
    attribute_value IN NUMBER   := NULL,  
    sqlset_owner    IN VARCHAR2 := NULL);
  
  ------------------------------ add_sqlset_reference -------------------------
  -- NAME: 
  --     add_sqlset_reference
  --
  -- DESCRIPTION:
  --     This function adds a new reference to an existing sqlset 
  --     to indicate its use by a client.
  --
  -- PARAMETERS:
  --    sqlset_name  (IN) - the sqlset name.
  --    description  (IN) - description of the usage of sqlset.
  --    sqlset_owner (IN) - the owner of the sqlset, or null for current schema
  --                        owner
  --
  -- RETURN:
  --     The identifier of the added reference.
  -----------------------------------------------------------------------------
  FUNCTION add_sqlset_reference(
    sqlset_name  IN VARCHAR2,
    description  IN VARCHAR2 := NULL,
    sqlset_owner IN VARCHAR2 := NULL)
  RETURN NUMBER;
    
  ------------------------------ remove_sqlset_reference ----------------------
  -- NAME: 
  --     remove_sqlset_reference
  --
  -- DESCRIPTION:
  --     This procedure is used to deactivate a sqlset to indicate it 
  --     is no longer used by the client.
  --
  -- PARAMETERS:
  --     name         (IN) - the SQLSET name
  --     reference_id (IN) - the identifier of the reference to remove. 
  --     sqlset_owner (IN) - the owner of the sqlset, or null for current
  --                         schema owner
  -----------------------------------------------------------------------------
  PROCEDURE remove_sqlset_reference(
    sqlset_name  IN VARCHAR2,
    reference_id IN NUMBER,
    sqlset_owner IN VARCHAR2 := NULL);
        
  ----------------------------------- select_sqlset ---------------------------
  -- NAME: 
  --     select_sqlset
  --
  -- DESCRIPTION:
  --     This is a table function to read sql tuning set content.
  --
  -- PARAMETERS:
  --     sqlset_name        (IN) - sqlset name to select from
  --     basic_filter       (IN) - SQL predicate to filter the SQL statements 
  --                               from the specified sqlset
  --     object_filter      (IN) - objects that should exist in the object list
  --                               of selected SQL.  Currently not supported.
  --     ranking_measure(i) (IN) - an order-by clause on the selected SQL
  --     result_percentage  (IN) - a percentage on the sum of a ranking measure
  --     result_limit       (IN) - top L(imit) SQL from the (filtered) source 
  --                               ranked by the ranking measure         
  --     attribute_list     (IN) - list of SQL statement attributes to return 
  --                               in the result. 
  --                               The possible values are:
  --                               + BASIC: all attributes are
  --                                   returned except the plans and the object
  --                                   references. i.e., execution statistics
  --                                   and binds. The execution context is
  --                                   always part of the result.
  --                               + TYPICAL (default): BASIC + SQL plan
  --                                   (without row source statistics) and 
  --                                   without object reference list. 
  --                               + ALL: return all attributes 
  --                               + Comma separated list of attribute names: 
  --                                   this allows to return only a subset of
  --                                   SQL attributes:
  --                                     EXECUTION_STATISTICS,
  --                                     SQL_BINDS,
  --                                     SQL_PLAN,
  --                                     SQL_PLAN_STATISTICS: similar to 
  --                                       SQL_PLAN + row source statistics. 
  --     plan_filter       (IN) - plan filter. It is applicable in case there 
  --                              are multiple plans (plan_hash_value) 
  --                              associated to the same statement. This filter
  --                              allows selecting one plan (plan_hash_value) 
  --                              only. Possible values are:
  --                              + LAST_GENERATED: plan with most recent 
  --                                                timestamp.
  --                              + FIRST_GENERATED: opposite to LAST_GENERATED
  --                              + LAST_LOADED: plan with most recent 
  --                                             first_load_time stat info. 
  --                              + FIRST_LOADED: opposite to LAST_LOADED
  --                              + MAX_ELAPSED_TIME: plan with max elapsed 
  --                                                  time
  --                              + MAX_BUFFER_GETS: plan with max buffer gets
  --                              + MAX_DISK_READS: plan with max disk reads
  --                              + MAX_DIRECT_WRITES: plan with max direct 
  --                                                   writes
  --                              + MAX_OPTIMIZER_COST: plan with max opt. cost
  --     sqlset_owner      (IN) - the owner of the sqlset, or null for current
  --                              schema owner
  --     recursive_sql     (IN) - filter out the recursive SQL 
  --                              if NO_RECURSIVE_SQL
  -- RETURN:
  --     This function returns a sqlset object.
  -----------------------------------------------------------------------------
  FUNCTION select_sqlset( 
    sqlset_name       IN VARCHAR2,
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    ranking_measure1  IN VARCHAR2 := NULL,
    ranking_measure2  IN VARCHAR2 := NULL,
    ranking_measure3  IN VARCHAR2 := NULL,
    result_percentage IN NUMBER   := 1,
    result_limit      IN NUMBER   := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL',
    plan_filter       IN VARCHAR2 := NULL,
    sqlset_owner      IN VARCHAR2 := NULL,
    recursive_sql     IN VARCHAR2 := HAS_RECURSIVE_SQL)
  RETURN sys.sqlset PIPELINED;
  
  ---------------------------- select_cursor_cache ----------------------------
  -- NAME: 
  --     select_cursor_cache
  --
  -- DESCRIPTION:
  --     This function is provided to be able to collect SQL statements from 
  --     the Cursor Cache.
  --
  -- PARAMETERS:
  --     basic_filter       (IN) - SQL predicate to filter the SQL from the 
  --                               cursor cache.
  --     object_filter      (IN) - specifies the objects that should exist in 
  --                               the  object list of selected SQL from the
  --                               cursor cache.  Currently not supported.
  --     ranking_measure(i) (IN) - an order-by clause on the selected SQL.
  --     result_percentage  (IN) - a percentage on the sum of a rank measure.
  --     result_limit       (IN) - top L(imit) SQL from the (filtered) source 
  --                               ranked by the ranking measure. 
  --     attribute_list     (IN) - list of SQL statement attributes to return 
  --                               in the result. 
  --                               The possible values are:
  --                               + BASIC: all attributes are
  --                                   returned except the plans and the object
  --                                   references. i.e., execution statistics
  --                                   and binds. The execution context is
  --                                   always part of the result.
  --                               + TYPICAL (default): BASIC + SQL plan
  --                                   (without row source statistics) and
  --                                   without object reference list. 
  --                               + ALL: return all attributes 
  --                               + Comma separated list of attribute names: 
  --                                   this allows to return only a subset of
  --                                   SQL attributes:
  --                                     EXECUTION_STATISTICS,
  --                                     SQL_BINDS,
  --                                     SQL_PLAN,
  --                                     SQL_PLAN_STATISTICS: similar 
  --                                       to SQL_PLAN + row source statistics
  --
  --     recursive_sql       (IN) - filter out the recursive SQL 
  --                                if NO_RECURSIVE_SQL
  -- RETURN:
  --     This function returns a sqlset object.
  -----------------------------------------------------------------------------
  FUNCTION select_cursor_cache(
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    ranking_measure1  IN VARCHAR2 := NULL,
    ranking_measure2  IN VARCHAR2 := NULL,
    ranking_measure3  IN VARCHAR2 := NULL,
    result_percentage IN NUMBER   := 1,
    result_limit      IN NUMBER   := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL',
    recursive_sql     IN VARCHAR2 := HAS_RECURSIVE_SQL)
  RETURN sys.sqlset PIPELINED;  
  
  ------------------------- select_workload_repository ------------------------
  -- NAME: 
  --     select_workload_repository
  --
  -- DESCRIPTION:
  --     This function is provided to be able to collect SQL statements from 
  --     the workload repository. It is used to collect SQL statements from all
  --     snapshots between begin_snap and and end_snap or from a specified
  --     baseline. 
  --
  -- PARAMETERS:
  --     begin_snap         (IN) - begin snapshot
  --     end_snap           (IN) - end snapshot
  --     baseline_name      (IN) - the name of the baseline period.   
  --     basic_filter       (IN) - SQL predicate to filter the SQL from AWR.
  --     object_filter      (IN) - specifies the objects that should exist in 
  --                               the  object list of selected SQL from AWR.
  --                               Currently not supported.
  --     ranking_measure(i) (IN) - an order-by clause on the selected SQL.
  --     result_percentage  (IN) - a percentage on the sum of a rank measure.
  --     result_limit       (IN) - top L(imit) SQL from the (filtered) source 
  --                               ranked by the ranking measure.         
  --     attribute_list     (IN) - list of SQL statement attributes to return 
  --                               in the result. 
  --                               The possible values are:
  --                               + BASIC: all attributes are
  --                                   returned except the plans and the object
  --                                   references. i.e., execution statistics
  --                                   and binds. The execution context is
  --                                   always part of the result.
  --                               + TYPICAL (default): BASIC + SQL plan
  --                                   (without row source statistics) and
  --                                   without object reference list. 
  --                               + ALL: return all attributes 
  --                               + Comma separated list of attribute names: 
  --                                   this allows to return only a subset of
  --                                   SQL attributes:
  --                                     EXECUTION_STATISTICS,
  --                                     SQL_BINDS,
  --                                     SQL_PLAN,
  --                                     SQL_PLAN_STATISTICS: similar 
  --                                       to SQL_PLAN + row source statistics
  --     recursive_sql       (IN) - filter out the recursive SQL 
  --                                if NO_RECURSIVE_SQL
  -- RETURN:
  --     This function returns a sqlset object.
  -----------------------------------------------------------------------------
  FUNCTION select_workload_repository(
    begin_snap        IN NUMBER,
    end_snap          IN NUMBER,
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    ranking_measure1  IN VARCHAR2 := NULL,
    ranking_measure2  IN VARCHAR2 := NULL,
    ranking_measure3  IN VARCHAR2 := NULL,
    result_percentage IN NUMBER   := 1,
    result_limit      IN NUMBER   := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL',
    recursive_sql     IN VARCHAR2 := HAS_RECURSIVE_SQL)
  RETURN sys.sqlset PIPELINED;    
  
  -------------------------- select_workload_repository -----------------------
  FUNCTION select_workload_repository(
    baseline_name     IN VARCHAR2,
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    ranking_measure1  IN VARCHAR2 := NULL,
    ranking_measure2  IN VARCHAR2 := NULL,
    ranking_measure3  IN VARCHAR2 := NULL,
    result_percentage IN NUMBER   := 1,
    result_limit      IN NUMBER   := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL',
    recursive_sql     IN VARCHAR2 := HAS_RECURSIVE_SQL)
  RETURN sys.sqlset PIPELINED;        

  ------------------------------ select_sql_trace -----------------------------
  -- NAME: 
  --     select_sql_trace
  --
  -- DESCRIPTION:
  --     This table function reads the content of one or more trace 
  --     files and returns the sql statements it finds in the format
  --     of sqlset_row.
  --
  -- PARAMETERS:
  --     directory     (IN) - directory/location/path of the trace file(s).
  --                          This field is mandatory.
  --     file_name     (IN) - all or part of name of the trace file(s) 
  --                          to process. If NULL then the current or most 
  --                          recent file in the specified localtion/path 
  --                          will be used. '%' wildcards are supported for
  --                          matching trace file names.
  --     mapping_table_name       
  --                   (IN) - the mapping table name. Note that
  --                          the mapping table name is case insensitive.
  --                          If the mapping table name is NULL, the mappings
  --                          in the current database will be used.
  --     mapping_table_owner
  --                   (IN) - the mapping table owner. If it is NULL, the
  --                          current user will be used.
  --     select_mode   (IN) - It is the mode for selecting sqls from the trace.
  --                          SINGLE_EXECUTION: return one execution of a SQL.
  --                                            It is the default.
  --                          ALL_EXECUTIONS: return all executions.
  --
  --     options       (IN) - the options. 
  --                          LIMITED_COMMAND_TYPE: we only return the sqls
  --                          with the command types: CREATE, INSERT, SELECT,
  --                          UPDATE, DELETE, UPSERT. It is the default.
  --                          ALL_COMMAND_TYPE: return the sqls with all
  --                          command type.
  --     pattern_start (IN) - opening delimiting pattern of the trace file
  --                          section(s) to consider. NOT USED FOR NOW.
  --     pattern_end   (IN) - closing delimiting pattern of the trace file 
  --                          section(s) to process. NOT USED FOR NOW.
  --     result_limit  (IN) - top SQL from the (filtered) source. Default 
  --                          to MAXSB4 if NULL; 
  --
  -- return:
  --     This function returns a sqlset_row object.
  --
  ------------------------------------------------------------------------
  -- EXAMPLE: LOAD SQLs from SQL TRACE INTO STS and convert it into trial
  ------------------------------------------------------------------------
  --  /* turn on the SQL trace in the capture database */
  --  alter session set events '10046 trace name context forever, level 4'
  --
  --  /* create mapping table from the capture database */
  --  create table mapping as 
  --    select  object_id id, owner, substr(object_name, 1, 30) name 
  --    from  dba_objects 
  --    where object_type NOT IN ('CONSUMER GROUP', 'EVALUATION CONTEXT',
  --                              'FUNCTION', 'INDEXTYPE', 'JAVA CLASS',
  --                              'JAVA DATA', 'JAVA RESOURCE', 'LIBRARY',
  --                              'LOB', 'OPERATOR', 'PACKAGE',
  --                              'PACKAGE BODY', 'PROCEDURE', 'QUEUE',
  --                              'RESOURCE PLAN', 'TRIGGER', 'TYPE',
  --                              'TYPE BODY', 'SYNONYM') 
  --    union all 
  --    select  user_id id, username owner, null name 
  --    from  dba_users;
  --
  --  /* create the STS on the database running the SPA */
  --  dbms_sqltune.create_sqlset('my_sts', 'test purpose');
  --
  --  /* load the sqls into STS from SQL TRACE */
  --  DECLARE
  --     cur sys_refcursor;
  --  BEGIN
  --     OPEN cur for
  --       select value(p) 
  --         from TABLE(
  --            dbms_sqltune.select_sql_trace(
  --                    directory=>'SQL_TRACE_DIR', 
  --                    file_name=>'%trc',
  --                    mapping_table_name=>'mapping')) p;
  --    dbms_sqltune.load_sqlset('my_sts', cur);
  --  END;
  --  /
  --
  --  /* create a trial from the STS */
  --  var aname varchar2(30)
  --  exec :aname := dbms_sqlpa.create_analysis_task(
  --                                  sqlset_name => 'my_sts');
  --  exec dbms_sqlpa.execute_analysis_task(task_name =>:aname,
  --                                  execution_type => 'convert sqlset');
  -----------------------------------------------------------------------------
  FUNCTION select_sql_trace( 
    directory              IN VARCHAR2,
    file_name              IN VARCHAR2 := NULL,
    mapping_table_name     IN VARCHAR2 := NULL,
    mapping_table_owner    IN VARCHAR2 := NULL,
    select_mode            IN POSITIVE := SINGLE_EXECUTION,
    options                IN BINARY_INTEGER := LIMITED_COMMAND_TYPE,
    pattern_start          IN VARCHAR2 := NULL,
    pattern_end            IN VARCHAR2 := NULL,
    result_limit           IN POSITIVE := NULL)
  RETURN sys.sqlset PIPELINED;

  ----------------------------- select_sqlpa_task -----------------------------
  -- NAME: 
  --     select_sqlpa_task
  --
  -- DESCRIPTION:
  --     This function is provided to be able to collect SQL statements from 
  --     a SQL performance analyzer task.  One example usage is for creating
  --     a SQL Tuning Set containing the subset of SQL statements that
  --     regressed during a SQL Performance Analyzer (SPA) experiment.
  --     Other arbitrary filters can also be specified.
  --
  -- PARAMETERS:
  --     task_name          (IN) - name of the SQL Performance Analyzer task
  --     task_owner         (IN) - owner of the SQL Performance Analyzer task.
  --                               If NULL, then assume the current user.
  --     execution_name     (IN) - name of the SQL Performance Analyzer task
  --                               execution (type COMPARE PERFORMANCE) from
  --                               which the change_filter will be applied.
  --                               If NULL, then assume the most recent
  --                               COMPARE PERFORMANCE execution.
  --     level_filter       (IN) - filter to specify which subset of SQLs
  --                               to include.  Same format as DBMS_SQLPA. 
  --                                 REPORT_ANALYSIS_TASK.LEVEL, with some
  --                                 possible strings removed.
  --                               IMPROVED        - improved SQL
  --                               REGRESSED (default) - regressed SQL
  --                               CHANGED         - SQL w/ changed perf
  --                               UNCHANGED       - SQL w/ unchanged perf
  --                               CHANGED_PLANS   - SQL w/ plan changes
  --                               UNCHANGED_PLANS - SQL w/ unchanged plans
  --                               ERRORS          - SQL with errors only
  --                               MISSING_SQL     - Missing SQLs (Across STS)
  --                               NEW_SQL         - New SQLs (Across STS)
  --     basic_filter       (IN) - SQL predicate to filter the SQL in
  --                               addition to the filters above.
  --     object_filter      (IN) - specifies the objects that should exist in 
  --                               the  object list of selected SQL from the
  --                               cursor cache.  Currently not supported.
  --     attribute_list     (IN) - list of SQL statement attributes to return 
  --                               in the result. 
  --                               The possible values are:
  --                               + BASIC: all attributes are
  --                                   returned except the plans and the object
  --                                   references. i.e., execution statistics
  --                                   and binds. The execution context is
  --                                   always part of the result.
  --                               + TYPICAL (default): BASIC + SQL plan
  --                                   (without row source statistics) and
  --                                   without object reference list. 
  --                               + ALL: return all attributes 
  --                               + Comma separated list of attribute names: 
  --                                   this allows to return only a subset of
  --                                   SQL attributes:
  --                                     EXECUTION_STATISTICS,
  --                                     SQL_BINDS,
  --                                     SQL_PLAN,
  --                                     SQL_PLAN_STATISTICS: similar 
  --                                       to SQL_PLAN + row source statistics
  --
  -- RETURN:
  --     This function returns a sqlset object.
  -----------------------------------------------------------------------------
  FUNCTION select_sqlpa_task(
    task_name         IN VARCHAR2,
    task_owner        IN VARCHAR2 := NULL,
    execution_name    IN VARCHAR2 := NULL,
    level_filter      IN VARCHAR2 := 'REGRESSED',
    basic_filter      IN VARCHAR2 := NULL,
    object_filter     IN VARCHAR2 := NULL,
    attribute_list    IN VARCHAR2 := 'TYPICAL')
  RETURN sys.sqlset PIPELINED;

  -----------------------------------------------------------------------------
  --          Pack / Unpack SQL tuning set procedures and functions          --
  --                                                                         --
  -- SQL tuning sets can be moved ("packed") from their location on a system --
  -- into an opaque table in any user schema.  You can then move that table  --
  -- to another system using the method of your choice (expdp/impdp,         --
  -- database link, etc), and then import them into the SQL tuning set       --
  -- schema on the new system ("unpack").                                    --
  --                                                                         --
  -----------------------------------------------------------------------------
  ---------------------------------
  -- EXAMPLE: PACK/UNPACK TWO STS --
  ---------------------------------
  --   /* Create a staging table to move to */                             
  --   dbms_sqltune.create_stgtab_sqlset(table_name => 'STAGING_TABLE'); 
  --                                                                         
  --   /* Put two STS in the staging table */                                
  --   dbms_sqltune.pack_stgtab_sqlset(sqlset_name => 'my_sts',     
  --                                   staging_table_name => 'STAGING_TABLE');
  --   dbms_sqltune.pack_stgtab_sqlset(sqlset_name => 'full_app_workload',
  --                                   staging_table_name => 'STAGING_TABLE');
  --                                                                         
  --   /* transport STS_STAGING_TABLE to foreign system */                   
  --   ...
  --
  --   /* On new system, unpack both from staging table */
  --   dbms_sqltune.unpack_stgtab_sqlset(sqlset_name => '%',
  --                                    replace => TRUE,
  --                                    staging_table_name => 'STAGING_TABLE');
  --
  -----------------------------------------------------------------------------

  ------------------------------- create_stgtab_sqlset ------------------------
  -- NAME: 
  --     create_stgtab_sqlset
  --
  -- DESCRIPTION:
  --     This procedure creates a staging table to be used by the pack
  --     procedure.  Call it once before issuing a pack call.  It can
  --     be called on multiple schemas if you would like to have different
  --     tuning sets in different staging tables.
  --
  --     Note that this is a DDL operation, so it does not occur within a
  --     transaction.  Users issuing the call must have permission to create
  --     a table in the schema provided.
  --
  -- PARAMETERS:
  --     table_name          (IN)   - name of table to create (case-sensitive)
  --     schema_name         (IN    - user schema to create table within, or
  --                                  NULL for current schema owner
  --                                  (case-sensitive)
  --     tablespace_name     (IN)   - tablespace to store the staging table in,
  --                                  or NULL for schema's default tablespace
  --                                  (case-sensitive)
  --     db_version          (IN)   - database version to decide the format of
  --                                  the staging table. It is possible to 
  --                                  create an older DB version staging table
  --                                  so that an STS can be exported to an 
  --                                  older DB version. 
  --                                  It can take one of the following values:
  --                                  NULL (default)          : current DB 
  --                                                            version
  --                                  STS_STGTAB_10_2_VERSION : 10.2 DB version
  --                                  STS_STGTAB_11_1_VERSION : 11.1 DB version
  --                                  STS_STGTAB_11_2_VERSION : 11.2 DB version
  -----------------------------------------------------------------------------
  PROCEDURE create_stgtab_sqlset(
    table_name           IN VARCHAR2,
    schema_name          IN VARCHAR2 := NULL,                             
    tablespace_name      IN VARCHAR2 := NULL,
    db_version           IN NUMBER   := NULL);

  ----------------------------- pack_stgtab_sqlset ----------------------------
  -- NAME: 
  --     pack_stgtab_sqlset
  --
  -- DESCRIPTION:
  --     This function moves one or more STS from their location in the SYS
  --     schema to a staging table created by the create_stgtab_sqlset fct.
  --     It can be called several times to move more than one STS.  Users can
  --     then move the populated staging table to another system using any
  --     method of their choice, such as database link or datapump (expdp/
  --     impdp functions).  Users can then call unpack_stgtab_sqlset to create 
  --     the STS on the other system.
  --
  --     Note that this fct commits after packing each STS, so if it raises
  --     an error mid-execution, some STS may already be in the staging table.
  --
  -- PARAMETERS:
  --     sqlset_name          (IN)  - name of STS to pack (not NULL). 
  --                                  Wildcard characters ('%') are supported 
  --                                  to move multiple STS in a single call.
  --     sqlset_owner         (IN)  - name of STS owner, or NULL for current
  --                                  schema owner. Wildcard characters ('%') 
  --                                  are supported to pack STS from multiple
  --                                  owners in one call.
  --     staging_table_name   (IN)  - name of staging table, created by
  --                                  create_stgtab_sqlset (case-sensitive)
  --     staging_schema_owner (IN)  - name of staging table owner, or NULL for
  --                                  current schema owner (case-sensitive)
  --     db_version           (IN)  - database version to decide the format of
  --                                  the staging table. It is possible to 
  --                                  pack an STS to an older DB version 
  --                                  staging table so that it can be exported
  --                                  to an that version. 
  --                                  It can take one of the following values:
  --                                  NULL (default)          : current DB 
  --                                                            version
  --                                  STS_STGTAB_10_2_VERSION : 10.2 DB version
  --                                  STS_STGTAB_11_1_VERSION : 11.1 DB version
  --                                  STS_STGTAB_11_2_VERSION : 11.2 DB version
  ------------------------------------------------------------------------------
  PROCEDURE pack_stgtab_sqlset(
    sqlset_name          IN VARCHAR2,
    sqlset_owner         IN VARCHAR2 := NULL,
    staging_table_name   IN VARCHAR2,
    staging_schema_owner IN VARCHAR2 := NULL,
    db_version           IN NUMBER   := NULL);
  
  --------------------------- unpack_stgtab_sqlset ----------------------------
  -- NAME: 
  --     unpack_stgtab_sqlset
  --
  -- DESCRIPTION:
  --     Moves one or more STS from the staging table, as populated by a call
  --     to pack_stgtab_sqlset and moved by the user, into the STS schema, 
  --     making them proper STS. Users can drop the staging table after this 
  --     procedure completes successfully.
  --
  --     The unpack procedure commits after successfully loading each STS.  If
  --     it fails with one, no part of that STS will have been unpacked, but
  --     those which it saw previously will exist.  When failures occur due to
  --     sts name or owner conflicts, users should use the remap_stgtab_sqlset
  --     function to patch the staging table, and then call this procedure 
  --     again to unpack those STS that remain.
  --
  -- PARAMETERS:
  --     sqlset_name          (IN)  - name of STS to unpack (not NULL). 
  --                                  Wildcard characters ('%') are supported 
  --                                  to unpack multiple STS in a single call.
  --                                  for example, just specify '%' to unpack
  --                                  all STS from the staging table.
  --     sqlset_owner         (IN)  - name of STS owner, or NULL for current
  --                                  schema owner.  Wildcards supported
  --     replace              (IN)  - replace STS if they already exist.
  --                                  If FALSE, function errors when trying to
  --                                  unpack an existing STS
  --     staging_table_name   (IN)  - name of staging table, moved after a call
  --                                  to pack_stgtab_sqlset (case-sensitive)
  --     staging_schema_owner (IN)  - name of staging table owner, or NULL for
  --                                  current schema owner (case-sensitive)
  -----------------------------------------------------------------------------
  PROCEDURE unpack_stgtab_sqlset(
    sqlset_name          IN VARCHAR2 := '%',
    sqlset_owner         IN VARCHAR2 := NULL,
    replace              IN BOOLEAN,
    staging_table_name   IN VARCHAR2,
    staging_schema_owner IN VARCHAR2 := NULL);

  ------------------------------- remap_stgtab_sqlset -------------------------
  -- NAME: 
  --     remap_stgtab_sqlset
  --
  -- DESCRIPTION:
  --     Changes the sqlset names and owners in the staging table so that they
  --     can be unpacked with different values than they had on the host 
  --     system.
  --     Users should first check to see if the names they are changing to will
  --     conflict first -- this function does not enforce that constraint.
  --
  --     Users can call this procedure multiple times to remap more than one
  --     STS name/owner.  Note that this procedure only handles one STS per
  --     call.
  --
  -- PARAMETERS:
  --     old_sqlset_name      (IN)  - name of STS to target for a name/owner
  --                                  remap. Wildcards are NOT supported.
  --     old_sqlset_owner     (IN)  - name of STS owner to target for a
  --                                  remap.  NULL for current schema owner.
  --     new_sqlset_name      (IN)  - new name for STS. NULL to keep the same
  --                                  name.
  --     new_sqlset_owner     (IN)  - new owner name for STS.  NULL to keep the
  --                                  same owner name.
  --     staging_table_name   (IN)  - name of staging table (case-sensitive)
  --     staging_schema_owner (IN)  - name of staging table owner, or NULL for
  --                                  current schema owner (case-sensitive)
  -----------------------------------------------------------------------------
  PROCEDURE remap_stgtab_sqlset(
    old_sqlset_name        IN VARCHAR2,
    old_sqlset_owner       IN VARCHAR2 := NULL,
    new_sqlset_name        IN VARCHAR2 := NULL,
    new_sqlset_owner       IN VARCHAR2 := NULL,
    staging_table_name     IN VARCHAR2,
    staging_schema_owner   IN VARCHAR2 := NULL);

  --------------------------- transform_sqlset_cursor -------------------------
  -- NAME: 
  --     transform_sqlset_cursor 
  --
  -- DESCRIPTION:
  --     This function transforms a user specified sql tuning set cursor to 
  --     a table (function) so that the cursor can be queried in SQL query. 
  --     The function is also used to transform an internal cursor created 
  --     to contain all statements to be deleted from the sql tuning set using 
  --     the delete_sqlset API.
  --   
  --
  -- PARAMETERS:
  --     populate_cursor  (IN)  - cursor to transform.
  -- RETURN:
  --     rows of type sqlset_row. 
  --                                 
  -- NOTICE: 
  --    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  --    ! This function exists for internal use and MUST NOT be documented  !
  --    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  ----------------------------------------------------------------------------
  FUNCTION transform_sqlset_cursor(
    populate_cursor IN sqlset_cursor) 
  RETURN sys.sqlset PIPELINED;




  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                      --------------------------------                   --
  --                      SQL PROFILE PROCEDURES/FUNCTIONS                   --
  --                      --------------------------------                   --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  -------------------
  --  EXPORTED PROCEDURES/FUNCTIONS
  --
  --

  -- SQL PROFILE OVERVIEW  
  --  SQL profiles are collections of SQL compiler statistics that can
  -- be associated to a particular SQL text.  During SQL parse
  -- (compilation) if a SQL profile is associated with the current
  -- SQL statement, the statistics within the profile will be made
  -- available to the compiler.  Profiles are matched to compiling
  -- SQL if the normalized text of the SQL statement matches the
  -- normalized SQL text provided at SQL profile creation time.  The
  -- normalization of the SQL text entails uppercasing all non-literal
  -- text and removal of all whitespace. The session
  -- performing the compilation must also have the same value for
  -- the parameter sqltune_category as the category under which the
  -- SQL Profile was created.  Category allows multiple profiles to exist
  -- for the same SQL statement.  It also allows a session to test
  -- profiles privately (by working and creating profiles in a unique
  -- category namespace).
  --  SQL profiles can only be used by certain SQL statement types.  These
  -- include:
  --    SELECT statements
  --    UPDATE statements
  --    INSERT (but only with a SELECT clause) statements
  --    DELETE statements
  --    CREATE TABLE (but only with the AS SELECT clause)
  --    MERGE statements (the upsert operation)
  --
  --  Internally executed SQL statements against the data dictionary
  -- (referred to as recursive dictionary SQL) will ignore profiles.  Also,
  -- any SQL executed before the database is open will not be able to
  -- lookup and use profiles. 
  --  SQL profiles and stored outlines are related in that they influence
  -- the compilation of SQL.  If a stored outline can be used for
  -- compiling a SQL statement, then any profiles are ignored.  Note
  -- that a profile can be used during the SQL compilation that
  -- creates a stored outline.  For example, if there is a profile on
  -- a SQL statement that has the CREATE OUTLINE statement executed for
  -- it (and categories match), the profile will be used to determine
  -- the plan that will then be saved as the stored outline.
  --  A profile's status can be enabled or disabled.  A disabled profile
  -- will not be used for compiling cursors. When profiles are
  -- created/accepted they are enabled.  Use the ALTER_SQL_PROFILE procedure 
  -- to toggle between the enabled and disabled status.
  --

  -------------------------
  --  PROFILE DDL OPERATIONS
  -------------------------

  -- NAME: accept_sql_profile - accept a sqltune recommended SQL profile,
  --                            FUNCTION version
  -- PURPOSE:  This procedure accepts a SQL profile as recommended by the 
  --           specified SQL tuning task.
  -- INPUTS: task_name    - (REQUIRED) The name of the SQL tuning task.
  --         object_id    - The identifier of the advisor framework object
  --                        representing the SQL statement associated
  --                        to the tuning task.
  --         name         - This is the name of the profile.  It cannot contain
  --                        double quotation marks. The name is case sensitive.
  --                        If not specified, the system will generate a unique
  --                        name for the SQL profile.
  --         description -  A user specified string describing the purpose
  --                        of this SQL profile. Max size of description is 500
  --         category    -  This is the category name which must match the
  --                        value of parameter SQLTUNE_CATEGORY in a session
  --                        for the session to use this profile.  It defaults
  --                        to the value "DEFAULT".  This is also the default
  --                        of the SQLTUNE_CATEGORY parameter.  The category
  --                        must be a valid Oracle identifier. The category
  --                        name specified is always converted to upper case.
  --                        The combination of the normalized SQL text and
  --                        category name create a unique key for a profile.
  --                        An accept will fail if this combination is 
  --                        duplicated.
  --         task_owner  -  Owner of the tuning task. This is an optional 
  --                        parameter that has to be specified to accept 
  --                        a SQL Profile associated to a tuning task owned
  --                        by another user. The current user is the default
  --                        value. 
  --         replace      - If the profile already exists, it will be
  --                        replaced if this argument is TRUE.
  --                        It is an error to pass a name that is already
  --                        being used for another signature/category pair,
  --                        even with replace set to TRUE.
  --         force_match  - If TRUE this causes SQL Profiles
  --                        to target all SQL statements which have the same
  --                        text after normalizing all literal values into
  --                        bind variables. (Note that if a combination of
  --                        literal values and bind values is used in a
  --                        SQL statement, no bind transformation occurs.)
  --                        This is analogous to the matching algorithm
  --                        used by the "FORCE" option of the
  --                        CURSOR_SHARING parameter.  If FALSE, literals are
  --                        not transformed.  This is analogous to the
  --                        matching algorithm used by the "EXACT" option of
  --                        the CURSOR_SHARING parameter.
  --         profile_type - The profile type. If NULL, it means the SQL
  --                        profile. 
  --
  -- RETURNS: name        - The name of the SQL profile. 
  --
  -- REQUIRES: "ADMINISTER SQL MANAGEMENT OBJECT" privilege ("CREATE ANY 
  --            SQL PROFILE" privilege deprecated)
  --  
  FUNCTION accept_sql_profile(
                   task_name    IN VARCHAR2,
                   object_id    IN NUMBER   := NULL,
                   name         IN VARCHAR2 := NULL,
                   description  IN VARCHAR2 := NULL,
                   category     IN VARCHAR2 := NULL,
                   task_owner   IN VARCHAR2 := NULL,
                   replace      IN BOOLEAN  := FALSE,
                   force_match  IN BOOLEAN  := FALSE,
                   profile_type IN VARCHAR2 := REGULAR_PROFILE)
  RETURN VARCHAR2;
  
  -- NAME: accept_sql_profile - accept a sqltune recommended SQL profile,
  --                            PROCEDURE version
  -- PURPOSE:  This procedure accepts a SQL profile as recommended by the 
  --           specified SQL tuning task.
  -- INPUTS: task_name    - (REQUIRED) The name of the SQL tuning task.
  --         object_id    - Identifier of the advisor framework
  --                        object representing the SQL statement associated
  --                        to the tuning task.
  --         name         - This is the name of the profile.  It 
  --                        cannot contain double quotation marks. The name is
  --                        case sensitive.
  --         description  - A user specified string describing the purpose
  --                        of this SQL profile. Max size of description is 500
  --         category     - This is the category name which must match the
  --                        value of parameter SQLTUNE_CATEGORY in a session
  --                        for the session to use this profile.  It defaults
  --                        to the value "DEFAULT".  This is also the default
  --                        of the SQLTUNE_CATEGORY parameter.  The category
  --                        must be a valid Oracle identifier. The category
  --                        name specified is always converted to upper case.
  --                        The combination of the normalized SQL text and
  --                        category name create a unique key for a profile.
  --                        An accept will fail if this combination is 
  --                        duplicated.
  --         task_owner   - Owner of the tuning task. This is an optional 
  --                        parameter that has to be specified to accept 
  --                        a SQL Profile associated to a tuning task owned
  --                        by another user. The current user is the default
  --                        value. 
  --         replace      - If the profile already exists, it will be
  --                        replaced if this argument is TRUE.
  --                        It is an error to pass a name that is already
  --                        being used for another signature/category pair,
  --                        even with replace set to TRUE.
  --         force_match  - If TRUE this causes SQL Profiles
  --                        to target all SQL statements which have the same
  --                        text after normalizing all literal values into
  --                        bind variables. (Note that if a combination of
  --                        literal values and bind values is used in a
  --                        SQL statement, no bind transformation occurs.)
  --                        This is analogous to the matching algorithm
  --                        used by the "FORCE" option of the
  --                        CURSOR_SHARING parameter.  If FALSE, literals are
  --                        not transformed.  This is analogous to the
  --                        matching algorithm used by the "EXACT" option of
  --                        the CURSOR_SHARING parameter.
  --         profile_type - The profile type. If NULL, it means the SQL
  --                        profile. 
  --
  -- REQUIRES: "ADMINISTER SQL MANAGEMENT OBJECT" privilege ("CREATE ANY 
  --            SQL PROFILE" privilege deprecated)
  --  
  PROCEDURE accept_sql_profile(
                   task_name    IN VARCHAR2,
                   object_id    IN NUMBER   := NULL,
                   name         IN VARCHAR2 := NULL,
                   description  IN VARCHAR2 := NULL,
                   category     IN VARCHAR2 := NULL,
                   task_owner   IN VARCHAR2 := NULL,
                   replace      IN BOOLEAN  := FALSE,
                   force_match  IN BOOLEAN  := FALSE,
                   profile_type IN VARCHAR2 := REGULAR_PROFILE);
  
  -- NAME: drop_sql_profile - drop a SQL profile
  -- PURPOSE:  This procedure drops the named SQL profile from the database.
  -- INPUTS: name      - (REQUIRED)Name of profile to be dropped.  The name
  --                     is case sensitive.
  --         ignore    - Ignore errors due to object not existing.
  -- REQUIRES: "ADMINISTER SQL MANAGEMENT OBJECT" privilege ("DROP ANY 
  --           SQL PROFILE" privilege deprecated)
  --
  PROCEDURE drop_sql_profile(
                   name          IN VARCHAR2,
                   ignore        IN BOOLEAN  := FALSE);

  -- NAME: alter_sql_profile - alter a SQL profile attribute
  -- PURPOSE: This procedure alters specific attributes of an existing
  --          SQL profile object.  The following attributes can be altered
  --          (using these attribute names):
  --            "STATUS" -> can be set to "ENABLED" or "DISABLED"
  --            "NAME"   -> can be reset to a valid name (must be
  --                        a valid Oracle identifier and must be
  --                        unique).
  --            "DESCRIPTION" -> can be set to any string of size no
  --                             more than 500
  --            "CATEGORY" -> can be reset to a valid category name (must
  --                          be valid Oracle identifier and must be unique
  --                          when combined with normalized SQL text)
  -- INPUTS: name      - (REQUIRED)Name of SQL profile to alter. The name
  --                     is case sensitive.
  --         attribute_name - (REQUIRED)The attribute name to alter (case
  --                     insensitive).
  --                     See list above for valid attribute names.
  --         value     - (REQUIRED)The new value of the attribute.  See list
  --                     above for valid attribute values.
  -- REQUIRES: "ADMINISTER SQL MANAGEMENT OBJECT" privilege ("ALTER ANY 
  --           SQL PROFILE" privilege deprecated)
  --
  PROCEDURE alter_sql_profile(
                   name                 IN VARCHAR2,
                   attribute_name       IN VARCHAR2,
                   value                IN VARCHAR2);

  -- NAME:    import_sql_profile - import a SQL profile
  -- PURPOSE: This procedure is only used by import.
  -- INPUTS:   (see accept_sql_profile)
  -- REQUIRES: "ADMINISTER SQL MANAGEMENT OBJECT" privilege ("CREATE ANY 
  --           SQL PROFILE" privilege deprecated)
  --
  PROCEDURE import_sql_profile(
                   sql_text      IN CLOB,
                   profile       IN sqlprof_attr,
                   name          IN VARCHAR2 := NULL,
                   description   IN VARCHAR2 := NULL,
                   category      IN VARCHAR2 := NULL,
                   validate      IN BOOLEAN  := TRUE,
                   replace       IN BOOLEAN  := FALSE,
                   force_match   IN BOOLEAN  := FALSE);

  PROCEDURE import_sql_profile(
                   sql_text      IN CLOB,
                   profile_xml   IN CLOB,
                   name          IN VARCHAR2 := NULL,
                   description   IN VARCHAR2 := NULL,
                   category      IN VARCHAR2 := NULL,
                   validate      IN BOOLEAN  := TRUE,
                   replace       IN BOOLEAN  := FALSE,
                   force_match   IN BOOLEAN  := FALSE);

  -- NAME: sqltext_to_signature - sql text to its signature
  -- PURPOSE:  This function returns a sql text's signature. 
  --       The signature can be used to identify sql text in dba_sql_profiles.
  -- INPUTS:  sql_text    - (REQUIRED) sql text whose signature is required
  --          force_match - If TRUE this causes SQL Profiles
  --                        to target all SQL statements which have the same
  --                        text after normalizing all literal values into
  --                        bind variables. (Note that if a combination of
  --                        literal values and bind values is used in a
  --                        SQL statement, no bind transformation occurs.)
  --                        This is analogous to the matching algorithm
  --                        used by the "FORCE" option of the 
  --                        CURSOR_SHARING parameter.  If FALSE (the default), 
  --                        literals are not transformed.  This is analogous to
  --                        the matching algorithm used by the "EXACT" option
  --                        of the CURSOR_SHARING parameter.
  -- RETURNS: the signature of the specified sql text
  -- REQUIRES: 
  --
  FUNCTION sqltext_to_signature(sql_text    IN CLOB,
                                force_match IN BOOLEAN  := FALSE)
  RETURN NUMBER;

  -- NAME: sqltext_to_signature - sql text to its signature
  -- PURPOSE:  This function returns a sql text's signature. 
  --       The signature can be used to identify sql text in dba_sql_profiles.
  -- INPUTS:  sql_text    - (REQUIRED) sql text whose signature is required
  --          force_match - If 1, this causes SQL Profiles
  --                        to target all SQL statements which have the same
  --                        text after normalizing all literal values into
  --                        bind variables. (Note that if a combination of
  --                        literal values and bind values is used in a
  --                        SQL statement, no bind transformation occurs.)
  --                        This is analogous to the matching algorithm
  --                        used by the "FORCE" option of the 
  --                        CURSOR_SHARING parameter.  If 0, the default 
  --                        literals are not transformed.  This is analogous to
  --                        the matching algorithm used by the "EXACT" option
  --                        of the CURSOR_SHARING parameter.
  -- RETURNS: the signature of the specified sql text
  -- COMMENTS: To enable calling from sql so that integer can be passed 
  --           0 is FALSE rest is TRUE
  -- REQUIRES: 
  --
  FUNCTION sqltext_to_signature(sql_text    IN CLOB,
                                force_match IN BINARY_INTEGER)
  RETURN NUMBER;

  -------------------------
  --  PROFILE PACK/UNPACK
  -------------------------
  --  Profiles can be exported out of one system and imported into another
  --  by means of a staging table, provided by procedures in this package. Like
  --  with SQL tuning sets, the operation of inserting into the staging table 
  --  is called a "pack", and the operation of creating profiles from staging 
  --  table data is the "unpack".
  --  DBAs should perform a pack/unpack as follows:
  --
  --  1) Create a staging table through a call to create_stgtab_sqlprof
  --  2) Call pack_stgtab_sqlprof one or more times to write SQL profile
  --     data into the staging table
  --  3) Move the staging table through the means of choice (e.g. datapump,
  --     database link, etc)
  --  4) Call unpack_stgtab_sqlprof to create sql profiles on the new system
  --     from the profile data in the staging table
  --
  --
  --  EXAMPLES:
  --
  --  1) Create a staging table owned by user 'SCOTT':
  --     exec dbms_sqltune.create_stgtab_sqlprof(table_name => 'STAGING_TABLE',
  --                                             schema_name => 'SCOTT');
  --  2) Copy data for all SQL profiles in the DEFAULT category into a staging 
  --     table owned by the current schema owner.
  --     exec dbms_sqltune.pack_stgtab_sqlprof(
  --                                  staging_table_name => 'STAGING_TABLE');
  --  3) Copy data for sql profile SP_FIND_EMPLOYEE only into a staging table
  --     owned by the current schema owner.
  --     exec dbms_sqltune.pack_stgtab_sqlprof(
  --                                  profile_name => 'SP_FIND_EMPLOYEE',
  --                                  staging_table_name => 'STAGING_TABLE');
  --  4) Change the name in the data for the SP_FIND_EMPLOYEE profile stored
  --     in the staging table to 'SP_FIND_EMP_PROD':
  --     exec dbms_sqltune.remap_stgtab_sqlprof(
  --                                  old_profile_name => 'SP_FIND_EMPLOYEE',
  --                                  new_profile_name => 'SP_FIND_EMP_PROD',
  --                                  staging_table_name => 'STAGING_TABLE');
  --  5) Create profiles for all the data stored in the staging table, 
  --     replacing those that already exist
  --     exec dbms_sqltune.unpack_stgtab_sqlprof(
  --                                  replace => TRUE,
  --                                  staging_table_name => 'STAGING_TABLE');

  -- NAME: create_stgtab_sqlprof
  -- PURPOSE: This procedure creates the staging table used for transporting
  --          sql profiles from one system to another (just like SQL tuning
  --          set pack/unpack) 
  -- INPUTS:  table_name      - (REQUIRED) the name of the table to create
  --                            (case-sensitive)
  --          schema_name     - schema to create the table in, or NULL for
  --                            current schema (case-sensitive)
  --          tablespace_name - tablespace to store the staging table within,
  --                            or NULL for current user's default tablespace
  --                            (case-sensitive)
  -- REQUIRES: "CREATE TABLE" privilege and tablespace quota
  --
  PROCEDURE create_stgtab_sqlprof(
                  table_name            IN VARCHAR2,
                  schema_name           IN VARCHAR2 := NULL,
                  tablespace_name       IN VARCHAR2 := NULL);

  -- NAME: pack_stgtab_sqlprof
  -- PURPOSE: This procedure packs into the staging table created by a call
  --          to create_stgtab_sqlprof.  It moves profile data out of the SYS
  --          schema into the staging table.  
  -- 
  --          By default, we move all SQL profiles in category DEFAULT.  See
  --          the examples section above for details.  Note that this function
  --          issues a COMMIT after packing each sql profile, so if an error is
  --          raised mid-execution, some profiles may be in the staging table.
  --
  -- INPUTS:  profile_name         - name of profile to pack (% wildcards OK)
  --                                 (case-sensitive)
  --          profile_category     - category to pack profiles from
  --                                 (% wildcards OK, case-insensitive)
  --          staging_table_name   - (REQUIRED) the name of the table to use
  --                                 (case-sensitive)
  --          staging_schema_owner - schema where the table resides, or NULL 
  --                                 for current schema (case-sensitive)
  -- REQUIRES: "ADMINISTER SQL PLAN MANAGEMENT OBJECT" privilege,
  --           "INSERT" privilege on staging table
  --
  PROCEDURE pack_stgtab_sqlprof(
                  profile_name          IN VARCHAR2 := '%',
                  profile_category      IN VARCHAR2 := 'DEFAULT',
                  staging_table_name    IN VARCHAR2,
                  staging_schema_owner  IN VARCHAR2 := NULL);

  -- NAME: unpack_stgtab_sqlprof
  -- PURPOSE: This procedure unpacks from the staging table populated by a call
  --          to pack_stgtab_sqlprof.  It uses the profile data stored in the
  --          staging table to create profiles on this system.  Users can opt
  --          to replace existing profiles with profile data when they exist
  --          already.  In this case, note that we can only replace profiles
  --          referring to the same statement if the names are the same (see
  --          accept_sql_profile).
  -- 
  --          By default, we move all SQL profiles in the staging table.  The
  --          function commits after successfully loading each profile.  If it
  --          fails creating an individual profile, it raises an error and does
  --          not proceed to the remaining ones in the staging table.  For
  --          profile name or category errors, users should use the 
  --          remap_stgtab_sqlprof function to patch the staging table and then
  --          call unpack again to create the remaining profiles.
  --
  --
  -- INPUTS:  profile_name         - name of profile to unpack (% wildcards OK)
  --                                 (case-sensitive)
  --          profile_category     - category to unpack profiles from
  --                                 (% wildcards OK, case-insensitive)
  --          replace              - replace profiles if they already exist?
  --                                 Note that profiles cannot be replaced if
  --                                 one in the staging table has the same name
  --                                 as an active profile on different SQL.
  --                                 If FALSE, this function errors whenever a
  --                                 profile we try to create already exists.
  --          staging_table_name   - (REQUIRED) the name of the table to use
  --                                 (case-sensitive)
  --          staging_schema_owner - schema where the table resides, or NULL 
  --                                 for current schema (case-sensitive)
  -- REQUIRES: "ADMINISTER SQL MANAGEMENT OBJECT" privilege and "SELECT" 
  --           privilege on staging table ("CREATE ANY SQL PROFILE" privilege
  --           deprecated)
  --
  PROCEDURE unpack_stgtab_sqlprof(
                  profile_name          IN VARCHAR2 := '%',
                  profile_category      IN VARCHAR2 := '%',
                  replace               IN BOOLEAN,
                  staging_table_name    IN VARCHAR2,
                  staging_schema_owner  IN VARCHAR2 := NULL);

  -- NAME: remap_stgtab_sqlprof
  -- PURPOSE: This procedure allows DBAs to change the profile data values
  --          kept in the staging table prior to performing a unpack operation.
  --          It can be used, for example, to change the name of a profile if
  --          one already exists on the system with the same name.
  --
  -- INPUTS:  old_profile_name     - (REQUIRED) the name of the profile to 
  --                                 target for a remap operation
  --                                 (case-sensitive)
  --          new_profile_name     - new name for profile, or NULL to remain
  --                                 the same (case-sensitive)
  --          new_profile_category - new category for the profile, or NULL to
  --                                 remain the same (case-insensitive)
  --          staging_table_name   - (REQUIRED) the name of the table to 
  --                                 perform the remap operation 
  --                                 (case-sensitive)
  --          staging_schema_owner - schema where the table resides, or NULL
  --                                 for current schema (case-sensitive)
  -- REQUIRES: "UPDATE" privilege on staging table
  --
  PROCEDURE remap_stgtab_sqlprof(
                  old_profile_name      IN VARCHAR2,
                  new_profile_name      IN VARCHAR2 := NULL,
                  new_profile_category  IN VARCHAR2 := NULL,
                  staging_table_name    IN VARCHAR2,
                  staging_schema_owner  IN VARCHAR2 := NULL);



  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                  -------------------------------------------            --
  --                  SQL MONITORING RELATED FUNCTIONS/PROCEDURE             --
  --                  -------------------------------------------            --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

  ------------------------------- report_sql_monitor --------------------------
  -- NAME: 
  --     report_sql_monitor
  --
  -- DESCRIPTION:
  --
  --     This function builds a report (text, simple html, active html, xml) for
  --     the monitoring  information collected on behalf of the targeted
  --     statement execution. 
  --
  --     The target SQL statement for this report can be:
  --
  --       - the last SQL monitored by Oracle (default, no parameter)
  --       - the last SQL executed by a specified session and monitored
  --         by Oracle. The session is identified by its session id and
  --         optionally it serial# (-1 is current session). For example, use
  --         sess_id=>-1 for the current session or sess_id=>20,
  --         sess_serial=>103 for session id 20, serial number 103.
  --       - the last execution of a specific statement identified by
  --         its sql_id.
  --       - a specific execution of a SQL statement identified by the
  --         triplet (sql_id, sql_exec_start and sql_exec_id).
  --
  -- PARAMETERS:
  --                       
  --      - sql_id:      SQL_ID for which monitoring information should be
  --                     displayed. Use NULL (the default) to display
  --                     monitoring information for the last statement
  --                     monitored by Oracle.
  --
  --      - session_id:  Target only the sub-set of statements executed and
  --                     monitored on behalf of the specified session.
  --                     Default is NULL. Use -1 or USERENV('SID') for current
  --                     seesion.
  --
  --      - session_serial:
  --                     In addition to the above <session_id> parameter, one
  --                     can also specify its session serial to ensure that
  --                     the desired session incarnation is targeted. Ignored
  --                     when <session_id> is NULL.
  --
  --      - (sql_exec_start, sql_exec_id):
  --                     Only applicable when <sql_id> is also specified and
  --                     can be used to display monitoring information for a
  --                     particular execution of <sql_id>. When NULL (the
  --                     default), the last execution of <sql_id> is shown.
  -- 
  --      - inst_id:     Only look at queries started on the specified 
  --                     instance. Use -1 to target the current instance.
  --                     The default, NULL will target all instances.
  --
  --      - start_time_filter:
  --                     If non NULL, the report will show only activity
  --                     (from V$ACTIVE_SESSION_HISTORY) started after this
  --                     date. If NULL, the reported activity will start when
  --                     the targeted SQL statement has started.
  --
  --      - end_time_filter:
  --                     If non NULL, the report will show only activity
  --                     (from V$ACTIVE_SESSION_HISTORY) collected before this
  --                     date. If NULL, the reported activity will end when
  --                     the targeted SQL statement has ended or SYSDATE if the
  --                     statement is still executing.
  --
  --      - instance_id_filter:
  --                     Only look at activity for the specified instance. Use
  --                     NULL (the default) to target all instances. Only
  --                     relevant if the query runs parallel.
  --
  --      - parallel_filter:
  --                     Parallel filter applies only to parallel execution and
  --                     allows to select only a subset of the processes
  --                     involved in the parallel execution. The string
  --                     parallel_filter can be:
  --                     - NULL (target all parallel execution servers + the
  --                       query coordinator)
  --                     - ['qc'][servers(<svr_grp>[,] <svr_set>[,] <srv_num>)]
  --                        where any NULL value is interpreted as ALL.
  --
  --                      The following examples show how one can set
  --                      <parallel_filter> to target only a subset of the
  --                      parallel sessions:
  --                        - 'qc' to target only the query coordinator
  --                        - servers(1)': to target all px servers in group 1
  --                          servers(,2)': to target all px servers in set 1,
  --                                        any group
  --                        - servers(1,1)': group 1, set 1
  --                        - servers(1,2,4)': group 1, set 3, server number 4
  --                        - qc servers(1,2,4)': same as above by also
  --                          including QC
  -- 
  --      - plan_line_filter:
  --                     This filter selects activity and execution stats for
  --                     the specified line number in the plan of a SQL 
  -- 
  --      - event_detail:
  --                     When set to 'no', the activity is aggregated by
  --                     wait_class only. Use 'yes' (the default) to aggregate
  --                     by (wait_class, event_name)
  --
  --     The next 2 parameters are used to control the activity histogram. By
  --     default, the maximum number of buckets is set to 128 and we derive the
  --     bucket_interval based on this. Basically, <bucket_interval> (value is
  --     in seconds) is computed such that it is the smallest possible power of
  --     2 value (starting at 1s) without causing to exceed the maximum number
  --     of buckets. For example, if the query has executed for 600s, we will
  --     pick a bucket_interval of 8s (a power of two) since 600/8 = 74 which
  --     is less than 128 buckets maximum. Smaller than 8s would be 4s, but
  --     that would cause to have more buckets than the 128 maximum.
  --     If <bucket_interval> is specified, we will use that value instead of
  --     deriving it from bucket_max_count. 
  --     
  --      - bucket_max_count:
  --                     If specified, this should be the maximum number of
  --                     histogram buckets created in the report
  --
  --      - bucket_interval:
  --                     If specified, this represents the exact time interval
  --                     in seconds, of all histogram buckets. If specified,
  --                     bucket_max_count is ignored.
  --
  --      - base_path:  this is the URL path for flex HTML ressources since
  --                    flex HTML format requires to access external files
  --                    (java scripts and the flash swf file itself).
  --
  --      - last_refresh_time:
  --                     If not null (default is null), time when the
  --                     report was last retrieved (see sysdate attribute
  --                     of the report tag). Use this option when you want
  --                     to display the report of an running query and when
  --                     that report is refreshed on a regular basis. This
  --                     will optimize the size of the report since only
  --                     the new/changed information will be returned. In
  --                     particular, the following will be optimized:
  --                     - SQL text will not be returned when this option
  --                       is specified
  --                     - activity histogram will start at the bucket that
  --                       intersect that time. The entire content of the
  --                       bucket will be return, even if last_refresh_time
  --                       is after the start of that bucket
  --
  --      - report_level:
  --                     level of detail for the report, either 'none', 'basic',
  --                     'typical' or 'all'. Default assumes 'typical'. Their
  --                     meanings are explained below.
  --                     
  --                     In addition, individual report sections can also
  --                     be enabled/disabled by using a +/-<section_name>.
  --                     Several sections are defined: 'plan', 'xplan',
  --                     'parallel', 'sessions', 'instance', 'binds', 'activity',
  --                     'activity_histogram', 'plan_histogram', 'metrics',
  --                     'other'.
  --                     Their meanings are as follows:
  --                     xplan          :   Show explain plan, 
  --                                        ON by default
  --                     plan           :   Show plan monitoring stats, 
  --                                        ON by default
  --                     sessions       :   Show session details. Applies only
  --                                        to parallel queries
  --                                        ON by default
  --                     instance       :   Show instance details. Applies only
  --                                        to parallel and cross instance 
  --                                        queries
  --                                        ON by default      
  --                     parallel       :   An umbrella parameter for 
  --                                        specifying sessions+instance
  --                                        details
  --                     activity :         Show activity summary at global
  --                                        level, plan line level and session/
  --                                        instance level (if applicable). 
  --                                        ON by default
  --                     binds          :   Show bind information when available
  --                                        ON by default
  --                     metrics        :   Show metric data (CPU, IOs, ...)
  --                                        over time
  --                                        ON by default
  --                     activity_histogram :
  --                                        Show an histogram of the overall
  --                                        query activity
  --                                        ON by default
  --                     plan_histogram  :  Show activity histogram at plan
  --                                        line level 
  --                                        OFF by default
  --                     other           :  Other info
  --                                        ON by default
  --
  --                     In addition, SQL text can be specified at different
  --                     levels:
  --                     -sql_text      : No SQL text in report
  --                     +sql_text      : OK with partial SQL text, i.e. upto 
  --                                      the first 2000 chars as stored in 
  --                                      gv$sql_monitor 
  --                     -sql_fulltext  : No full SQL text, i.e +sql_text
  --                     +sql_fulltext  : Show full SQL text (default value)
  --
  --                     The meanings of the three top-level report levels are:
  --                     none    = the minimum possible
  --                     basic   = sql_text-plan-xplan-sessions-instance
  --                               -activity_histogram-plan_histogram
  --                               -metrics
  --                     typical = everything but plan_histogram
  --                     all     = everything
  --
  --                    Only one of these 4 levels can be specified and if it 
  --                    is, then it has to be at the start of the report_level 
  --                    string
  -- 
  --                     Examples:
  --                       Use 'basic+parallel' to show the basic
  --                       report with additional section reporting parallel
  --                       information. Use 'all-plan-instance' for full
  --                       report minus plan detail and instance information.
  --
  --      - type:
  --            Report TYPE. Can be either 'TEXT' (text report, the default),
  --            'HTML' (simple HTML report, 'ACTIVE' (database active reports),
  --            'XML' (raw data for the report). Some information (activity
  --            histogram, metrics, ...) are only shown when the ACTIVE report
  --            type is selected.
  --
  --      - sql_plan_hash_value:
  --                     Target only those with the specified plan_hash_value.
  --                      Default is NULL.
  --   
  -- RETURN:
  --     The SQL monitor report, an XML document
  --
  -- NOTE:
  --     The user tunning this function needs to have privilege to access the
  --     following fixed views:
  --       - GV$SQL_MONITOR
  --       - GV$SQL_PLAN_MONITOR
  --       - GV$ACTIVE_SESSION_HISTORY
  --       - GV$SESSION_LONGOPS
  --       - GV$SQL if SQL fulltext is asked and its length is > 2K
  -----------------------------------------------------------------------------
  FUNCTION report_sql_monitor(
       sql_id                    in varchar2 default  NULL,
       session_id                in number   default  NULL,
       session_serial            in number   default  NULL,
       sql_exec_start            in date     default  NULL,
       sql_exec_id               in number   default  NULL,
       inst_id                   in number   default  NULL,
       start_time_filter         in date     default  NULL,
       end_time_filter           in date     default  NULL,
       instance_id_filter        in number   default  NULL,
       parallel_filter           in varchar2 default  NULL,
       plan_line_filter          in number   default  NULL,
       event_detail              in varchar2 default  'yes',
       bucket_max_count          in number   default  128,
       bucket_interval           in number   default  NULL,
       base_path                 in varchar2 default  NULL,
       last_refresh_time         in date     default  NULL,
       report_level              in varchar2 default 'TYPICAL',
       type                      in varchar2 default 'TEXT',
       sql_plan_hash_value       in number   default  NULL)
  RETURN clob;


  ------------------------------- report_sql_monitor_xml ----------------------
  -- NAME: 
  --     report_sql_monitor_xml
  --
  -- DESCRIPTION:
  --
  --     Same as above function (report_sql_monitor()) except that the result
  --     is only XML, hence the return type is xmltype. 
  --
  -----------------------------------------------------------------------------
  FUNCTION report_sql_monitor_xml(
       sql_id                    in varchar2 default  NULL,
       session_id                in number   default  NULL,
       session_serial            in number   default  NULL,
       sql_exec_start            in date     default  NULL,
       sql_exec_id               in number   default  NULL,
       inst_id                   in number   default  NULL,
       start_time_filter         in date     default  NULL,
       end_time_filter           in date     default  NULL,
       instance_id_filter        in number   default  NULL,
       parallel_filter           in varchar2 default  NULL,
       plan_line_filter          in number   default  NULL,
       event_detail              in varchar2 default  'yes',
       bucket_max_count          in number   default  128,
       bucket_interval           in number   default  NULL,
       base_path                 in varchar2 default  NULL,
       last_refresh_time         in date     default  NULL,
       report_level              in varchar2 default 'TYPICAL',
       auto_refresh              in number   default  NULL,
       sql_plan_hash_value       in number   default  NULL)
  return xmltype;


  ---------------------------- report_sql_monitor_list ------------------------
  -- NAME: 
  --     report_sql_monitor_list
  --
  -- DESCRIPTION:
  --
  --     This function builds a report for all or a sub-set of statements
  --     that have been monitored by Oracle. For each statement, it gives
  --     key information and associated global statistics.
  --
  --     Use report_sql_monitor() to get detail monitoring information for
  --     a single SQL statement
  --
  -- PARAMETERS:
  --                       
  --      - sql_id:      SQL_ID for which monitoring information should be
  --                     displayed. Use NULL (the default) to display
  --                     monitoring information for the last statement
  --                     monitored by Oracle.
  --
  --      - session_id:  Target only the sub-set of statements executed and
  --                     monitored on behalf of the specified session.
  --                     Default is NULL. Use -1 (or USERENV('SID')) for
  --                     current session.
  --
  --      - session_serial:
  --                     In addition to the above <session_id> parameter, one
  --                     can also specify its session serial to ensure that
  --                     the desired session incarnation is targeted. Ignored
  --                     when <session_id> is NULL.
  --
  --      - inst_id:     Only look at monitored statements originating from
  --                     the specified instance. Special value -1 can be used
  --                     to target the instance where the  report executed.
  --                     To target all instances, use NULL (the default).
  --
  --      - active_since_date:
  --                     If not null (default is null), only returns monitored
  --                     statements that have been active since specified
  --                     time. This includes all statements that are still
  --                     executing plus all statements that have completed
  --                     their execution after the specified date/time.
  --
  --      - active_since_sec:
  --                     Same as above but the date is specified relativelly
  --                     to the current sysdate minus specified number of
  --                     seconds. For example, use 3600 to limit the report
  --                     to all statements that have been active in the past
  --                     1 hour.
  --
  --      - last_refresh_time:
  --                     If not null (default is null), date/time when the
  --                     list report was last retrieved. This is to optimize
  --                     the case where an application shows the list and
  --                     refresh the report on a regular basis (say once every
  --                     5s). In this case, the report will only show detail
  --                     about the execution of monitored queries that have
  --                     been active since the specified <last_refresh_time>.
  --                     For other queries, the report will only return the
  --                     execution key (i.e. sql_id, sql_exec_start,
  --                     sql_exec_id). Also, for queries that have their
  --                     first refresh time after the specified date, only
  --                     the SQL execution key and statistics are returned.
  --
  --      - report_level:
  --                     level of detail for the report. The level can be
  --                     either basic (SQL text up to 200 character),
  --                     typical (include full SQL text assuming that cursor
  --                     has not aged out, in which case the SQL text is
  --                     included up to 2000 characters). report_level can
  --                     also be all which is the same as typical for now.
  --
  -- RETURN:
  --     A report (xml, text, html) for the list of SQL statements that have
  --     been monitored. 
  --
  -- NOTE:
  --     The user tunning this function needs to have privilege to access the
  --     following fixed views:
  --       - GV$SQL_MONITOR and GV$SQL
  -----------------------------------------------------------------------------
 FUNCTION report_sql_monitor_list(
    sql_id                    in varchar2 default  NULL,
    session_id                in number   default  NULL,
    session_serial            in number   default  NULL,
    inst_id                   in number   default  NULL,
    active_since_date         in date     default  NULL,
    active_since_sec          in number   default  NULL,
    last_refresh_time         in date     default  NULL,
    report_level              in varchar2 default  'TYPICAL',
    auto_refresh              in number   default  NULL,
    base_path                 in varchar2 default  NULL,
    type                      in varchar2 default 'TEXT')
  RETURN clob;


  ---------------------------- report_sql_monitor_list_xml -------------------
  -- NAME: 
  --     report_sql_monitor_list_xml
  --
  -- DESCRIPTION:
  --
  --     Same as above function (report_sql_monitor) except that the result
  --     is only XML, hence the return type is xmltype
  -- 
  --
  -- RETURN:
  --     An XML document for the list of SQL statements that have been
  --     monitored. 
  --
  -- NOTE:
  --     The user tunning this function needs to have privilege to access the
  --     following fixed views:
  --       - GV$SQL_MONITOR and GV$SQL
  -----------------------------------------------------------------------------
 FUNCTION report_sql_monitor_list_xml(
    sql_id                    in varchar2 default  NULL,
    session_id                in number   default  NULL,
    session_serial            in number   default  NULL,
    inst_id                   in number   default  NULL,
    active_since_date         in date     default  NULL,
    active_since_sec          in number   default  NULL,
    last_refresh_time         in date     default  NULL,
    report_level              in varchar2 default  'TYPICAL',
    auto_refresh              in number   default  NULL,
    base_path                 in varchar2 default  NULL)
  RETURN xmltype;

  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                  -------------------------------------------            --
  --                  SQL DETAIL RELATED FUNCTIONS/PROCEDURE                 --
  --                  -------------------------------------------            --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

  ------------------------------- report_sql_detail ---------------------------
  -- NAME:
  --     report_sql_detail
  --
  -- DESCRIPTION:
  --
  -- This function builds a report for a specific sql_id.  For each sql_id
  -- it gives various statistics and details as obtained from the v$ views
  --
  -- PARAMETERS:
  --      - sql_id:      SQL_ID for which SQL statistics and details should
  --                     be displayed.  If NULL (default) display statistics
  --                     for the sql_id of the last sql statement executed
  --                     in the current session.
  --
  --      - sql_plan_hash_value:
  --                     Displays SQL statistics and details for a
  --                     specific plan_hash_value.
  --                     If NULL (default) displays statistics and details
  --                     for all plans of the sql_id.
  --   
  --      - start_time:  If specified, shows SQL activity
  --                     (from gv$active_session_history) starting at 
  --                     this time.
  --                     Default is NULL.
  --    
  --     - duration:     duration of activity (ASH) in seconds for the report.
  --                     If NULL (default), then 3600 seconds
  --
  --     - inst_id:      target_instance to get sql details from
  --                     If NULL, uses data from all instances
  --                     If 0 or -1, uses current instance.
  --
  --     - dbid:         target dbid to get sql details from
  --                     If NULL, uses current dbid
  --
  --     - event_detail:
  --                     When set to 'no', the activity is aggregated by
  --                     wait_class only. Use 'yes' (the default) to aggregate
  --                     by (wait_class, event_name)
  --
  --     The next 2 parameters are used to control the activity histogram. By
  --     default, the maximum number of buckets is set to 128 and we derive the
  --     bucket_interval based on this. Basically, <bucket_interval> (value is
  --     in seconds) is computed such that it is the smallest possible power of
  --     2 value (starting at 1s) without causing to exceed the maximum number
  --     of buckets. For example, if the query has executed for 600s, we will
  --     pick a bucket_interval of 8s (a power of two) since 600/8 = 74 which
  --     is less than 128 buckets maximum. Smaller than 8s would be 4s, but
  --     that would cause to have more buckets than the 128 maximum.
  --     If <bucket_interval> is specified, we will use that value instead of
  --     deriving it from bucket_max_count. 
  --     
  --      - bucket_max_count:
  --                     If specified, this should be the maximum number of
  --                     histogram buckets created in the report
  --
  --      - bucket_interval:
  --                     If specified, this represents the exact time interval
  --                     in seconds, of all histogram buckets. If specified,
  --                     bucket_max_count is ignored.
  -- 
  --     - top_n:  Controls the number of entries to display per dimension
  --                     in the top dimensions section.  DEFAULT 10
  --
  --     - report_level: level of detail for the report, either 'basic',
  --                     'typical' or 'all'. Default assumes 'typical'. Their
  --                     meanings are explained below.
  --                     
  --                     In addition, individual report sections can also
  --                     be enabled/disabled by using a +/-<section_name>.
  --                     Several sections are defined, as follows:
  --                     Their meanings are as follows:
  --                     top            :   show top values for the 
  --                                        ASH dimensions for a SQL statement
  --                                        ON by default
  --                     spm            :   show existing plan baselines 
  --                                        for a SQL statement
  --                                        OFF by default
  --                     sqltune        :   show SQL Tuning history for a
  --                                        SQL statement
  --                                        OFF by default      
  --                     sqlpatch       :   show SQL Patches for a
  --                                        SQL statement
  --                                        OFF by default
  --                     tunehist       :   show SQL Tuning history for a
  --                                        SQL statement
  --                                        OFF by default
  --                     mismatch       :   show reasons for creating
  --                                        new child cursors; i.e.
  --                                        sharing criteria violations
  --                                        OFF by default
  --                     stats          :   Show SQL execution stats per plan
  --                                        from gv$sqlarea_plan_hash
  --                                        ON by default
  --                     activity       :   Show top activity from ASH for
  --                                        each plan of a SQL statement
  --                                        ON by default
  --                     activity_all   :   Show top activity from ASH
  --                                        for each line of the plan for a
  --                                        SQL statement
  --                                        OFF by default
  --                     histogram      :   Show activity histogram for
  --                                        each plan of a SQL statement
  --                                        (plan timeline histogram)
  --                                        ON by default
  --                     sessions       :   Show activity for top sessions for
  --                                        each plan of a SQL satement
  --                                        OFF by default
  --                     monitor        :   Show one monitored SQL exectuion
  --                                        per execution plan
  --                                        ON by default
  --                     xplan          :   show execution plans
  --                                        ON by default
  --                     binds          :   show captured bind data
  --                                        ON by default
  --
  --                     In addition, SQL text can be specified at different
  --                     levels:
  --                     -sql_text      : No SQL text in report
  --                     +sql_text      : OK with partial SQL text, i.e. upto 
  --                                      the first 2000 chars as stored in 
  --                                      gv$sql
  --                     -sql_fulltext  : No full SQL text, i.e +sql_text
  --                     +sql_fulltext  : Show full SQL text (default value)
  --
  --                     The meanings of the three top-level report levels are:
  --                     basic   = sql_text+stats+activity
  --                               plan_histogram
  --                     typical = sql_fulltext+top+binds+stats+activity
  --                               +histogram+xplan+monitor
  --                     all     = sql_fulltext+top+spm+sqltune+sqlpatch
  --                               +tunehist
  --                               +mismatch
  --                               +binds+stats+activity_all+histogram+sessions
  --                               +monitor+xplan
  --
  --                    Only one of these 3 levels can be specified and if it 
  --                    is, then it has to be at the start of the report_level 
  --                    string
  -- 
  --                     Examples:
  --                       Use 'basic+histogram' to show the basic
  --                       report with additional section reporting activity
  --                       information
  --
  --     - type:         'text','html' or 'xml'.  only 'xml' is implemented
  --                     currently.
  --
  --     - data_source:  determines data source of sql data
  --                     'memory' - gv$ views
  --                     'disk'   - dba_hist_*
  --                     'auto'   - automatically determines source based on 
  --                                time frame (default)
  --
  --      - end_time:  If specified, shows SQL activity from start_time
  --                   to end_time
  --                     If NULL (default), systimestamp
  --
  --     - duration_stats: duration of additional SQL execution statistics
  --                     from AWR (in hours), for the report.
  --                     If NULL (default) then 24 hours
  --                         
  --     Behavior of time parameters:
  --       if start_time and end_time are specified then
  --          duration and duration_stats are ignored
  --          activity and historical stats are retrieved from start_time to
  --          end_time
  --       if start_time is specified, but end_time is not specified then
  --          activity (ASH) is retrieved from start_time to duration 
  --            (default duration is 3600 seconds)
  --          SQL execution stats is retrieved from start_time 
  --          to duration_stats (default duration_stats is 24 hours)
  --       if start_time is not specified (DEFAULT), then
  --          activity (ASH) is retrieved for past duration seconds (default
  --            3600s) from end_time (if end_time is NULL, then use
  --            systimestamp)
  --          SQL execution stats is retrieved for past duration_stats hours
  --            (default 24 hours) from end_time (if end_time is NULL,
  --            then use systimestamp)
  --       The default behavior is the past hour (3600s) of ASH activity
  --       and the past 24 hours for SQL execution statistics.
  --                    
  -- RETURN
  --   The SQL Statistics Detail report, a CLOB document
  --
  -- NOTE:
  --   The user generating the report needs to have privileges to access
  --   the following fixed views:
  --     - GV$ASH_INFO
  --     - GV$ACTIVE_SESSION_HISTORY
  --     - GV$SQLAREA_PLAN_HASH
  --     - GV$SQL
  --     - GV$SQL_SHARED_CURSOR
  --     - GV$SQL_BIND_CAPTURE
  --     - V$DATABASE
  --     - V$SESSION
  --     - GV$PARAMETER
  --     - DBA_HIST_* views
  --     - DBA_SQL_PROFILES
  --     - DBA_SQL_PLAN_BASELINES
  --     - DBA_SERVICES, DBA_USERS, DBA_OBJECTS, DBA_PROCEDURES
  --     - DBA_ADVISOR_* views
  --     - DBA_ADDM_* views
  --   and privileges required by the following packages
  --     - DBMS_XPLAN
  --     - DBMS_SQLTUNE.SQL_MONITOR
  --     - DBMS_SQLTUNE.REPORT_SQL_MONITOR
  --     - DBMS_SQLTUNE.REPORT_SQL_MONITOR_LIST
  -----------------------------------------------------------------------------
  FUNCTION report_sql_detail(
       sql_id                   in  varchar2   default NULL,
       sql_plan_hash_value      in  number     default NULL,
       start_time               in  date       default NULL,
       duration                 in  number     default NULL,
       inst_id                  in  number     default NULL,
       dbid                     in  number     default NULL,
       event_detail             in  varchar2   default 'yes',
       bucket_max_count         in  number     default 128,
       bucket_interval          in  number     default NULL,
       top_n                    in  number     default 10,
       report_level             in  varchar2   default 'typical',
       type                     in  varchar2   default 'ACTIVE',
       data_source              in  varchar2   default 'auto',
       end_time                 in  date       default NULL,
       duration_stats           in  number     default NULL)
  RETURN clob;


  ------------------------------- report_sql_detail_xml -----------------------
  -- NAME:
  --     report_sql_detail_xml
  --
  -- DESCRIPTION:
  --
  --     This function builds a XML report on behalf of report_sql_detail().
  --     Please refer to that function for a full description.
  -----------------------------------------------------------------------------
  FUNCTION report_sql_detail_xml(
       sql_id                   in  varchar2   default NULL,
       sql_plan_hash_value      in  number     default NULL,
       start_time               in  date       default NULL,
       duration                 in  number     default NULL,
       inst_id                  in  number     default NULL,
       dbid                     in  number     default NULL,
       event_detail             in  varchar2   default 'yes',
       bucket_max_count         in  number     default 128,
       bucket_interval          in  number     default NULL,
       top_n                    in  number     default 10,
       report_level             in  varchar2   default 'typical',
       data_source              in  varchar2   default 'auto',
       end_time                 in  date       default NULL,
       duration_stats           in  number     default NULL)
  return xmltype;


  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                        ----------------------------                     --
  --                        UTILITY PROCEDURES/FUNCTIONS                     --
  --                        ----------------------------                     --
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
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
  -----------------------------------------------------------------------------
  FUNCTION extract_bind(
    bind_data   IN RAW,
    bind_pos    IN PLS_INTEGER) RETURN SQL_BIND;

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
  --     For the content of a bind value, refer to function extract_bind
  ----------------------------------------------------------------------------
  FUNCTION extract_binds(
    bind_data IN RAW) 
  RETURN SQL_BIND_SET PIPELINED;


  -----------------------------------------------------------------------------
  --                                                                         --
  --  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  --
  --  !!!  UNDOCUMENTED FUNCTIONS AND PROCEDURES. FOR INTERNAL USE ONLY !!!  --
  --  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  --
  --                                                                         --
  -----------------------------------------------------------------------------

  -- DEPRECATED: see DBMS_AUTO_SQLTUNE
  PROCEDURE set_auto_tuning_task_parameter(
    parameter IN VARCHAR2,
    value     IN VARCHAR2);

  -- DEPRECATED: see DBMS_AUTO_SQLTUNE
  PROCEDURE set_auto_tuning_task_parameter(
    parameter IN VARCHAR2,
    value     IN NUMBER);

  --
  FUNCTION build_stash_xml(
       session_id                in number   default  NULL,
       session_serial            in number   default  NULL,
       session_inst_id           in number   default  NULL,
       px_mode                   in varchar2 default  'yes',
       start_time                in date     default  NULL,
       end_time                  in date     default  NULL,
       missing_seconds           in number   default  NULL,
       instance_low_filter       in number   default  0,
       instance_high_filter      in number   default  10000,
       bucket_max_count          in number   default  128,
       bucket_interval           in number   default  NULL,
       report_level              in varchar2 default 'TYPICAL',
       cpu_cores                 in binary_integer  default  NULL,
       is_hyper                  in varchar2        default  NULL)
  RETURN xmltype;

  --
  PROCEDURE check_sqlset_privs(
    sqlset_name   IN VARCHAR2, 
    sqlset_owner  IN VARCHAR2,
    sqlset_create IN BOOLEAN := false,
    read_only     IN BOOLEAN := false);

  --
  PROCEDURE check_sql_profile_priv(priv IN VARCHAR2);

  --
  PROCEDURE cap_sts_cbk(
      sqlset_name    IN VARCHAR2,
      iterations     IN POSITIVE,
      cap_option     IN VARCHAR2,
      cap_mode       IN NUMBER,
      cbk_proc_name  IN VARCHAR2,
      basic_filter   IN VARCHAR2 := NULL,
      sqlset_owner   IN VARCHAR2 := NULL);

  --
  FUNCTION prepare_sqlset_statement(
    sqlset_name        IN            VARCHAR2,
    sqlset_owner       IN            VARCHAR2,
    basic_filter       IN            VARCHAR2 := NULL,
    stmt_filter        IN            BOOLEAN  := FALSE,
    object_filter      IN            VARCHAR2 := NULL,
    plan_filter        IN            VARCHAR2 := NULL,
    rank1              IN            VARCHAR2 := NULL,
    rank2              IN            VARCHAR2 := NULL,
    rank3              IN            VARCHAR2 := NULL,
    result_percentage  IN            NUMBER   := 1,
    result_limit       IN            NUMBER   := NULL, 
    attribute_list     IN            VARCHAR2 := NULL,
    attribute_selected IN OUT NOCOPY BINARY_INTEGER,
    wrap_obj_ctor      IN            BOOLEAN := FALSE,
    check_binds        IN            BOOLEAN := TRUE,
    sts_id             OUT           NUMBER,
    first_rows_hint    IN            BOOLEAN  :=  TRUE)
  RETURN VARCHAR2;

  --
  FLAG_PREPAWR_WRAPCTOR  CONSTANT NUMBER := POWER(2, 0); 
  FLAG_PREPAWR_NOCKBINDS CONSTANT NUMBER := POWER(2, 1); 
  FLAG_PREPAWR_INCLBID   CONSTANT NUMBER := POWER(2, 2);

  FUNCTION prepare_awr_statement(
    begin_snap         IN             NUMBER, 
    end_snap           IN             NUMBER,
    basic_filter       IN             VARCHAR2 := NULL,
    stmt_filter        IN             BOOLEAN  := FALSE,
    object_filter      IN             VARCHAR2 := NULL,
    rank1              IN             VARCHAR2 := NULL,
    rank2              IN             VARCHAR2 := NULL,
    rank3              IN             VARCHAR2 := NULL,
    result_percentage  IN             NUMBER   := 1,
    result_limit       IN             NUMBER   := NULL, 
    attribute_list     IN             VARCHAR2 := NULL,
    attribute_selected IN OUT NOCOPY  BINARY_INTEGER,
    flags              IN             NUMBER   := 0)
  RETURN VARCHAR2;

  -- 
  PROCEDURE sqlset_progress_stats(
    sqlset_name        IN            VARCHAR2,
    sqlset_owner       IN            VARCHAR2,
    basic_filter       IN            VARCHAR2 := NULL,
    plan_filter        IN            VARCHAR2 := NULL,
    rank1              IN            VARCHAR2 := NULL,
    rank2              IN            VARCHAR2 := NULL,
    rank3              IN            VARCHAR2 := NULL,
    result_percentage  IN            NUMBER   := 1,
    result_limit       IN            NUMBER   := NULL, 
    sql_count          OUT           NUMBER,
    workload_time      OUT           NUMBER,
    exec_type#         IN            PLS_INTEGER);

  --
  PROCEDURE examine_stgtab(
    stgtab_owner       IN            VARCHAR2,
    stgtab             IN            VARCHAR2,
    sts_name           OUT           VARCHAR2,
    sts_owner          OUT           VARCHAR2);

END dbms_sqltune;
/
show errors;

------------------------------------------------------------------------------
--                    Public synonym for the package                        --
------------------------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM dbms_sqltune FOR dbms_sqltune
/
show errors;

------------------------------------------------------------------------------
--            Granting the execution privilege to the public role           --
------------------------------------------------------------------------------
GRANT EXECUTE ON dbms_sqltune TO public
/
show errors;

  
------------------------------------------------------------------------------
--              DBMS_AUTO_SQLTUNE FUNCTION DECLARATIONS                     --
------------------------------------------------------------------------------
-- Description:
--    This package provides PL/SQL APIs to help manage the automatic sql 
--    tuning task, SYS_AUTO_SQL_TUNING_TASK.  It has execution granted to
--    DBA only because this feature is designed to be used only by
--    highly privileged users.
--
-- Notes:
--    We have a reserved system task called "SYS_AUTO_SQL_TUNING_TASK" that
--    performs SQL Tuning in the maintenance window, within the Autotask
--    framework. It automatically chooses a set of high-load SQL from AWR and
--    runs the SQL Tuning Advisor upon them.  If it finds a SQL Profile with
--    beneficial effect it creates it immediately (when the
--    ACCEPT_SQL_PROFILES parameter is TRUE), causing the optimizer to choose
--    a better plan for that statement in the future.
--                                                 
--    The automatic task is created by the system as part of the catalog
--    scripts.  It has its own special APIs for getting the report, and it
--    shares the other APIs with the standard tuning tasks.
--                                        
--    To set parameters of the automatic task, use the special
--    set_auto_tuning_task_parameter APIs as any user with ADVISOR privilege
--    AND execute privileges on the DBMS_AUTO_SQLTUNE package.
--
-- Functions:
--    execute_auto_tuning_task       - execute the task immediately (SYS only)
--    report_auto_tuning_task        - get a text report on the auto tuning
--                                     task's history
--    set_auto_tuning_task_parameter - change a task parameter value for the 
--                                     daily auto sqltune runs
-------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_auto_sqltune AUTHID CURRENT_USER AS

  --
  -- report type (possible values) constants  
  --
  TYPE_TEXT           CONSTANT   VARCHAR2(4) := dbms_sqltune.TYPE_TEXT;
  TYPE_XML            CONSTANT   VARCHAR2(3) := dbms_sqltune.TYPE_XML;
  TYPE_HTML           CONSTANT   VARCHAR2(4) := dbms_sqltune.TYPE_HTML;
  
  --
  -- report level (possible values) constants  
  --
  LEVEL_TYPICAL       CONSTANT   VARCHAR2(7) := dbms_sqltune.LEVEL_TYPICAL;
  LEVEL_BASIC         CONSTANT   VARCHAR2(5) := dbms_sqltune.LEVEL_BASIC;
  LEVEL_ALL           CONSTANT   VARCHAR2(3) := dbms_sqltune.LEVEL_ALL;

  --
  -- report section (possible values) constants  
  --
  SECTION_FINDINGS    CONSTANT   VARCHAR2(8) := dbms_sqltune.SECTION_FINDINGS;
  SECTION_PLANS       CONSTANT   VARCHAR2(5) := dbms_sqltune.SECTION_PLANS;
  SECTION_INFORMATION CONSTANT   VARCHAR2(11):= 
                                             dbms_sqltune.SECTION_INFORMATION;
  SECTION_ERRORS      CONSTANT   VARCHAR2(6) := dbms_sqltune.SECTION_ERRORS;
  SECTION_ALL         CONSTANT   VARCHAR2(3) := dbms_sqltune.SECTION_ALL;
  SECTION_SUMMARY     CONSTANT   VARCHAR2(7) := dbms_sqltune.SECTION_SUMMARY;


  --------------------------- execute_auto_tuning_task ------------------------
  -- NAME: 
  --     execute_auto_tuning_task - execute the SYS_AUTO_SQL_TUNING_TASK
  --
  -- DESCRIPTION:
  --     This procedure is called to execute SYS_AUTO_SQL_TUNING_TASK 
  --     manually.  The behavior will be the same as in automatic executions.
  --     NOTE only SYS can call this API.
  --
  -- PARAMETERS:
  --     execution_name   (IN) - A name to qualify and identify an execution
  --                             If not specified, it be generated by 
  --                             the advisor and returned by function. 
  --     execution_params (IN) - List of parameters (name, value) for 
  --                             the specified execution. Notice that execution
  --                             parameters are real task parameters that
  --                             have effect only on the execution they 
  --                             specified for. 
  --                             Example: 
  --                             dbms_advisor.arglist('time_limit', 12, 
  --                                                  'username', 'foo')
  --     execution_desc   (IN) - A 256-length string describing the execution. 
  --
  -- RETURNS:
  --     The function version returns the name of the new execution
  --
  -- EXCEPTIONS:
  --     To be done
  -----------------------------------------------------------------------------
  FUNCTION execute_auto_tuning_task(
    execution_name   IN VARCHAR2               := NULL,
    execution_params IN dbms_advisor.argList   := NULL,
    execution_desc   IN VARCHAR2               := NULL) 
  RETURN VARCHAR2;
  --
  PROCEDURE execute_auto_tuning_task(
    execution_name   IN VARCHAR2               := NULL,
    execution_params IN dbms_advisor.argList   := NULL,
    execution_desc   IN VARCHAR2               := NULL);

  --------------------------- report_auto_tuning_task -------------------------
  -- NAME: 
  --     report_auto_tuning_task 
  --
  -- DESCRIPTION:
  --     Get a report from the automatic tuning task.  This differs from the
  --     report_tuning_task API in that it takes a range of subtasks to report
  --     on.  NOTE that this API also exists in the DBMS_SQLTUNE package so
  --     all users with access to the views can see a report.
  --
  -- PARAMETERS:
  --     begin_exec     (IN) - name of execution to begin the report from. Null
  --                           to get a report on the most recent run.  See
  --                           DBA_ADVISOR_EXECUTIONS.
  --     end_exec       (IN) - name of execution to end the report at.  Null to
  --                           get a report on the most recent run.  See
  --                           DBA_ADVISOR_EXECUTIONS.
  --     type           (IN) - output type for report, one of:
  --                             TYPE_TEXT: text report
  --                             TYPE_HTML: html report
  --     level          (IN) - level of detail in the report:
  --                             LEVEL_BASIC: simple version of the report. 
  --                               Just show info about the actions taken by
  --                               the advisor.
  --                             LEVEL_TYPICAL: show info about every statement
  --                               analyzed, including recs not implemented.
  --                             LEVEL_ALL: verbose report level, also give
  --                               annotations about statements skipped over.
  --     section        (IN) - sections of report to show (comma-separated):
  --                             SECTION_SUMMARY     - summary information
  --                             SECTION_FINDINGS    - tuning findings
  --                             SECTION_PLAN        - explain plans
  --                             SECTION_INFORMATION - general information
  --                             SECTION_ERROR       - statements with errors
  --                             SECTION_ALL         - all statements
  --     object_id      (IN) - advisor framework object id that represents a 
  --                           single statement to restrict reporting to.  NULL
  --                           for all statements.  Only valid for reports 
  --                           that target a single execution.
  --     result_limit   (IN) - maximum number of SQL to show in the report
  --
  -- RETURNS:
  --     CLOB with report content
  --
  -- PRIVILEGES:
  --     Need SELECT privilege on the DBA_ADVISOR views
  -----------------------------------------------------------------------------
  FUNCTION report_auto_tuning_task(
    begin_exec     IN VARCHAR2  := NULL,
    end_exec       IN VARCHAR2  := NULL,
    type           IN VARCHAR2  := TYPE_TEXT,
    level          IN VARCHAR2  := LEVEL_TYPICAL,
    section        IN VARCHAR2  := SECTION_ALL,
    object_id      IN NUMBER    := NULL,
    result_limit   IN NUMBER    := NULL)
  RETURN CLOB;

  ------------------------ set_auto_tuning_task_parameter ---------------------
  -- NAME: 
  --     set_auto_tuning_task_parameter - set auto sql tuning task parameter
  --                                      value (VARCHAR2 value).
  --
  -- DESCRIPTION:
  --     Similar to set_tuning_task_parameter, but used for the reserved auto
  --     tuning task.  Using this API any user with ADVISOR privilege and
  --     EXECUTE on this package can set the auto tuning task parameters; 
  --     using dbms_sqltune.set_tuning_task_parameter only SYS can set them.
  --
  --     For a description of the parameters that can be set using this API,
  --     see the comments for dbms_sqltune.set_tuning_task_parameter.
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
  PROCEDURE set_auto_tuning_task_parameter(
    parameter IN VARCHAR2,
    value     IN VARCHAR2);

  ------------------------ set_auto_tuning_task_parameter ---------------------
  -- NAME: 
  --     set_auto_tuning_task_parameter - set auto sql tuning task parameter
  --                                      value (NUMBER value).
  --
  -- DESCRIPTION:
  --     Similar to set_tuning_task_parameter, but used for the reserved auto
  --     tuning task.  Using this API any user with ADVISOR privilege and
  --     EXECUTE on this package can set the auto tuning task parameters; 
  --     using dbms_sqltune.set_tuning_task_parameter only SYS can set them.
  --
  --     For a description of the parameters that can be set using this API,
  --     see the comments for dbms_sqltune.set_tuning_task_parameter.
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
  PROCEDURE set_auto_tuning_task_parameter(
    parameter IN VARCHAR2,
    value     IN NUMBER);

END dbms_auto_sqltune;
/
show errors;

------------------------------------------------------------------------------
--                    Public synonym for the package                        --
------------------------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM dbms_auto_sqltune FOR 
dbms_auto_sqltune
/
show errors;

------------------------------------------------------------------------------
--            Granting the execution privilege to the dba role              --
------------------------------------------------------------------------------
GRANT EXECUTE ON dbms_auto_sqltune TO dba
/
show errors;
