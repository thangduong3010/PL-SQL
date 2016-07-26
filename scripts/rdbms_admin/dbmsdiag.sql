Rem
Rem $Header: rdbms/admin/dbmsdiag.sql /main/24 2009/12/25 14:41:35 rdongmin Exp $
Rem
Rem dbmsdiag.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsdiag.sql - DBMS SQL DIAGnostic
Rem
Rem    DESCRIPTION
Rem     This package provides the APIs to diagnose SQL statements. 
Rem     It contains the procedure and function declaration for two  
Rem     main sqldiag modules:
Rem        1- sql_testcase
Rem        2- sql_diagnostic
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rdongmin    12/23/09 - #9213113 TCB support dump file to older ver
Rem    rdongmin    08/21/09 - fix TCB README errors, add set_tcb_tracing()
Rem    rdongmin    05/21/09 - import data set to TRUE by default
Rem    rdongmin    05/06/09 - #8402063 do not exlcude pkg if requested by user
Rem    rdongmin    03/03/09 - #7969055 add CE support for sqldiag
Rem    rdongmin    02/24/09 - #8256358 SQL Repair print info if no patch found
Rem    rdongmin    01/23/09 - #7836938 TCB add option preserveSchemaMapping
Rem    mzait       08/20/08 - get_fix_control - get fix control for a given bug
Rem    rdongmin    04/08/08 - #6956403 add findings_basic_info (no fix ctrl)
Rem    mzait       03/06/08 - add procedure: dump optimizer/compiler trace
Rem    rdongmin    12/17/07 - #6695308: SQLTCB: exclude pkg body by default
Rem    rdongmin    11/02/07 - lrg-3207108, set default timelimit for TCB
Rem    rdongmin    06/09/07 - #6120770: TCB user_name default to current user
Rem    tcruanes    04/26/07 - modify user action API to support only data
Rem                           export
Rem    hosu        03/30/07 - add pack/unpack support
Rem    tcruanes    02/27/07 - return the problem type for a SQL incident
Rem    rdongmin    02/08/07 - import_sql_testcase: importData default to FALSE
Rem    pbelknap    01/14/07 - make dbms_sqldiag INVOKER rights
Rem    rdongmin    12/28/06 - rename ADV_SQL_TUNE_NAME to ADV_SQL_DIAG_NAME
Rem    mfallen     12/04/06 - change export_into to function
Rem    tcruanes    11/22/06 - IPS/SQL Test Case builder integration
Rem    tcruanes    10/31/06 - change advisor name
Rem    ansingh     09/13/06 - Fix bug#5404524 with sql_id signature for
Rem                           create_diagnosis_task
Rem    ansingh     08/24/06 - SQL path support functions
Rem    tcruanes    08/02/06 - remove unsupported API
Rem    tcruanes    07/14/06 - add SQL Diagnosability callout support 
Rem    rdongmin    06/30/06 - remove SET stmts 
Rem    ansingh     05/11/06 - add sql diagnosis functions 
Rem    tcruanes    05/08/06 - SQL test case builder support 
Rem    ansingh     05/05/06 - Created
Rem

--------------------------------------------------------------------------------
--                  Library where 3GL callouts will reside                    --
--------------------------------------------------------------------------------
CREATE OR REPLACE LIBRARY dbms_sqldiag_lib trusted as static
/
show errors;
/

CREATE OR REPLACE PACKAGE dbms_sqldiag AUTHID CURRENT_USER AS

  ------------------------------------------------------------------------------
  --                      global constant declarations                        --
  ------------------------------------------------------------------------------
  --
  -- sqldiag advisor name 
  -- 
  ADV_SQL_DIAG_NAME  CONSTANT VARCHAR2(18) := 'SQL Repair Advisor'; 

  --
  -- SQLDIAG advisor task scope parameter values 
  --
  SCOPE_LIMITED       CONSTANT VARCHAR2(7)  := 'LIMITED';
  SCOPE_COMPREHENSIVE CONSTANT VARCHAR2(13) := 'COMPREHENSIVE';
  
  --
  --  SQLDIAG advisor time_limit constants (in seconds)
  --
  TIME_LIMIT_DEFAULT  CONSTANT   NUMBER := 1800;  
  
  --
  -- report type (possible values) constants  
  --
  --   TYPE_TEXT: text report
  --   TYPE_XML:  XML report
  --   TYPE_HTML: html report
  --
  TYPE_TEXT           CONSTANT   VARCHAR2(4) := 'TEXT'       ; 
  TYPE_XML            CONSTANT   VARCHAR2(3) := 'XML'        ;
  TYPE_HTML           CONSTANT   VARCHAR2(4) := 'HTML'       ;
  
  --
  -- report level (possible values) constants  
  --
  --    LEVEL_BASIC:    simple version of the report. 
  --                    Just show info about the actions taken by
  --                    the advisor.
  --    LEVEL_TYPICAL:  show info about every statement
  --                    analyzed, including recs not implemented.
  --    LEVEL_ALL:      verbose report level, also give
  --                    annotations about statements skipped over.
  --
  LEVEL_TYPICAL       CONSTANT   VARCHAR2(7) := 'TYPICAL'    ; 
  LEVEL_BASIC         CONSTANT   VARCHAR2(5) := 'BASIC'      ;
  LEVEL_ALL           CONSTANT   VARCHAR2(3) := 'ALL'        ;

  --
  -- report section (possible values) constants
  --  
  --    SECTION_SUMMARY     - summary information
  --    SECTION_FINDINGS    - sql repair findings
  --    SECTION_PLAN        - explain plans
  --    SECTION_INFORMATION - general information
  --    SECTION_ERROR       - statements with errors
  --    SECTION_ALL         - all statements
  --
  SECTION_SUMMARY     CONSTANT   VARCHAR2(7) := 'SUMMARY'    ; 
  SECTION_FINDINGS    CONSTANT   VARCHAR2(8) := 'FINDINGS'   ; 
  SECTION_PLANS       CONSTANT   VARCHAR2(5) := 'PLANS'      ;
  SECTION_INFORMATION CONSTANT   VARCHAR2(11):= 'INFORMATION';
  SECTION_ERRORS      CONSTANT   VARCHAR2(6) := 'ERRORS'     ;
  SECTION_ALL         CONSTANT   VARCHAR2(3) := 'ALL'        ;

  --
  -- script section constants
  --
  REC_TYPE_ALL          CONSTANT   VARCHAR2(3)  := 'ALL';
  REC_TYPE_SQL_PROFILES CONSTANT   VARCHAR2(8)  := 'PROFILES';
  REC_TYPE_STATS        CONSTANT   VARCHAR2(10) := 'STATISTICS';
  REC_TYPE_INDEXES      CONSTANT   VARCHAR2(7)  := 'INDEXES';

  --
  -- capture section constants
  --
  MODE_REPLACE_OLD_STATS CONSTANT   NUMBER := 1;
  MODE_ACCUMULATE_STATS  CONSTANT   NUMBER := 2;

  --
  -- problem type constants
  --
  -- PERFORMANCE       - User suspects this is a performance problem
  -- WRONG_RESULTS     - User suspects the query is giving inconsistent results
  -- COMPILATION_ERROR - User sees a crash in compilation
  -- EXECUTION_ERROR   - User sees a crash in execution
  -- ALT_PLAN_GEN      - Just explore all alternative plans
  --
  PROBLEM_TYPE_PERFORMANCE         CONSTANT   NUMBER := 1;
  PROBLEM_TYPE_WRONG_RESULTS       CONSTANT   NUMBER := 2;
  PROBLEM_TYPE_COMPILATION_ERROR   CONSTANT   NUMBER := 3;
  PROBLEM_TYPE_EXECUTION_ERROR     CONSTANT   NUMBER := 4;
  PROBLEM_TYPE_ALT_PLAN_GEN        CONSTANT   NUMBER := 5;
  
  --
  -- findings filter constants
  --
  -- All          - Show all possible findings
  -- VALIDATION   - Show status of validation rules over structures
  -- FEATURES     - Show only features used by the query
  -- FILTER_PLANS - Show the alternative plans generated by the advisor
  -- CR_DIFF      - Show difference between two plans
  -- MASK_VARIANT - Mask info for testing, e.g., mask the cost of plans
  -- OBJ_FEATURES - Show object trying features history
  -- BASIC_INFO   - Show features used, but not bug fix control info
  -- 
  SQLDIAG_FINDINGS_ALL                CONSTANT   NUMBER := 1;
  SQLDIAG_FINDINGS_VALIDATION         CONSTANT   NUMBER := 2;
  SQLDIAG_FINDINGS_FEATURES           CONSTANT   NUMBER := 3;
  SQLDIAG_FINDINGS_FILTER_PLANS       CONSTANT   NUMBER := 4;
  SQLDIAG_FINDINGS_CR_DIFF            CONSTANT   NUMBER := 5;
  SQLDIAG_FINDINGS_MASK_VARIANT       CONSTANT   NUMBER := 6;
  SQLDIAG_FINDINGS_OBJ_FEATURES       CONSTANT   NUMBER := 7;
  SQLDIAG_FINDINGS_BASIC_INFO         CONSTANT   NUMBER := 8;

  --
  -- mask mode for filtering findings
  --
  SQLDIAG_MASK_NONE                   CONSTANT   NUMBER := 1;
  SQLDIAG_MASK_COST                   CONSTANT   NUMBER := 2;

  ------------------------------------------------------------------------------
  --                    procedure / function declarations                     --
  ------------------------------------------------------------------------------

  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --               ------------------------------------------                 --
  --               SQL TEST CASE BUILDER PROCEDURES/FUNCTIONS                 --
  --               ------------------------------------------                 --
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

  -------------------------- export_sql_testcase ------------------------
  -- NAME: 
  --     export_sql_testcase
  --
  -- DESCRIPTION:
  --     Export a SQL test case to a directory.
  --     This variant of the API has to be provided with the SQL information
  --
  -- EXPLANATION:
  --
  --     SQL test case generates a set of files needed to help
  --     reproduce a SQL problem on a different machine:
  --
  --   It contains:
  -- 
  --     1. a dump file containing schemas objects and statistics (.dmp)
  --     2. the explain plan for the statements (in advanced mode)
  --     3. diagnostic information gathered on the offending statement
  --     4. an import script to execute to reload the objects.
  --     5. a SQL scripts to replay system statistics of the source
  --     6. A table of content file describing the SQL test case 
  --        metadata. (xxxxmain.xml)
  --
  --     Usually, you only need to reference the last file (metadata file) 
  --     for importing a test case.
  --
  --     The following is an example PL/SQL script for TCB IMPORT.
  --     It uses the metadata file name (xxxxmain.xml) as an input argument
  --     when calling the import API.
  --     (You may have to modify this script for the right arguments)
  --
  --   grant connect, dba, resource, query rewrite to tcb identified by tcb;
  --
  --   create directory TCB_IMP_DIR as '<DIRECTORY_PATH_4_TCB_IMPORT>';
  -- 
  --   conn tcb/tcb;
  --
  --   exec dbms_sqldiag.import_sql_testcase(directory => 'TCB_IMP_DIR' ,
  --                              filename  => '<TCB_METADATA>main.xml');
  --
  --
  --   Note:
  --      !!! You should not run TCB under user SYS !!!
  --      Use another user, such as 'tcb', who can be granted sysdba privilege
  --
  --     .The <DIRECTORY_PATH_4_TCB_IMPORT> is the CURRENT directory where
  --      all the TCB files have resided. It must be an OS path on local 
  --      machine, such as '/tmp/bug8010101'. It cannot be a path to other 
  --      machine, for example by mounting over a network file system.
  --
  --     .By default for TCB, the data is NOT exported
  --      In some case data is required, for example, to diagnose wrong
  --      result problem.
  --        To export data, call export_sql_testcase() with
  --           exportData=>TRUE
  --
  --        Note the data will be imported by default, unless turned OFF by
  --         importData=>FALSE
  --
  --     .TCB includes PL/SQL package spec by default , but not
  --      the PL/SQL package body.
  --      You may need to have the package body as well, for exmaple,  
  --      to invoke the PL/SQL functions.  
  --        To export PL/SQL package body, call export_sql_testcase() with
  --           exportPkgbody=>TRUE
  --        To import PL/SQL package body, call import_sql_testcase() with
  --           importPkgbody=>TRUE
  --
  --     .An example that you need to include PL/SQL package (body) is
  --      you have VPD function defined in a package
  --
  -- PARAMETERS:
  --     directory         (IN)  -  directory to store the various generated files
  --     sql_text          (IN)  -  text of the sql statement to explain
  --     user_name         (IN)  -  name of the user schema to use to parse the sql,
  --                                defaults to current user
  --     bind_list         (IN)  -  list of bind values associated to the statement
  --     exportEnvironment (IN)  -  TRUE if the compilation environment should be 
  --                                exported
  --     exportMetadata    (IN)  -  TRUE if the definition of the objects referenced 
  --                                in the SQL should be exported.
  --     exportData        (IN)  -  TRUE if the data of the objects referenced 
  --                                in the SQL should be exported.
  --     exportPkgbody     (IN)  -  TRUE if the body of the packages referenced 
  --                                in the SQL should be exported.
  --     samplingPercent   (IN)  -  if exportData is TRUE, specify the sampling 
  --                                percentage to use to create the dump file
  --     ctrlOptions       (IN)  -  opaque control parameters
  --     timeLimit         (IN)  -  how much time should we spend exporting the 
  --                                SQL test case
  --     testcase_name     (IN)  -  an optional name for the SQL test case. This
  --                                is used to prefix all the generated scripts.
  --     testcase          (OUT) -  the resulting test case
  --     preserveSchemaMapping
  --                       (IN)  -  TRUE if the schema(s) will NOT be re-mapped
  --                                from the original environment to the test 
  --                                environment.
  --     version           (IN) - The version of database objects to be extracted. 
  --                              This option is only valid for Export.
  --                              Database objects or attributes that are 
  --                              incompatible with the version will not be 
  --                              extracted. 
  --                              Legal values for this parameter are as follows:
  --
  --                              COMPATIBLE - (default) the version of the 
  --                                           metadata corresponds to the 
  --                                           database compatibility level and 
  --                                           the compatibility release level for 
  --                                           feature (as given in the 
  --                                           V$COMPATIBILITY view). 
  --                                           Database compatibility must be set 
  --                                           to 9.2 or higher.
  --                              LATEST     - the version of the metadata 
  --                                           corresponds to the database 
  --                                           version.
  --                              specific database version
  --                                         - for example, '10.0.0'. In Oracle 
  --                                           Database10g, this value cannot be 
  --                                           lower than 10.0.0.
  --
  ------------------------------------------------------------------------------

  PROCEDURE export_sql_testcase(
    directory                IN   VARCHAR2,
    sql_text                 IN   CLOB,
    user_name                IN   VARCHAR2  :=  NULL,
    bind_list                IN   sql_binds :=  NULL,
    exportEnvironment        IN   BOOLEAN   :=  TRUE,
    exportMetadata           IN   BOOLEAN   :=  TRUE,
    exportData               IN   BOOLEAN   :=  FALSE,
    exportPkgbody            IN   BOOLEAN   :=  FALSE,
    samplingPercent          IN   NUMBER    :=  100, 
    ctrlOptions              IN   VARCHAR2  :=  NULL,
    timeLimit                IN   NUMBER    :=  dbms_sqldiag.TIME_LIMIT_DEFAULT,
    testcase_name            IN   VARCHAR2  :=  NULL,
    testcase                 IN OUT NOCOPY CLOB,
    preserveSchemaMapping    IN   BOOLEAN   :=  FALSE,
    version                  IN   VARCHAR2  := 'COMPATIBLE'
  );

  -------------------------- export_sql_testcase ------------------------
  -- NAME: 
  --     export_sql_testcase
  --
  -- DESCRIPTION:
  --     Export a SQL test case to a directory.
  --     This API extract the SQL information from an incident file.
  --     
  -- PARAMETERS:
  --     directory         (IN)  -  directory to store the various generated files
  --     incident_id       (IN)  -  the incident ID containing the offending SQL
  --     exportEnvironment (IN)  -  TRUE if the compilation environment should be 
  --                                exported
  --     exportMetadata    (IN)  -  TRUE if the definition of the objects referenced 
  --                                in the SQL should be exported.
  --     exportData        (IN)  -  TRUE if the data of the objects referenced 
  --                                in the SQL should be exported.
  --     exportPkgbody     (IN)  -  TRUE if the body of the packages referenced 
  --                                in the SQL should be exported.
  --     samplingPercent   (IN)  -  if exportData is TRUE, specify the sampling 
  --                                percentage to use to create the dump file
  --     ctrlOptions       (IN)  -  opaque control parameters
  --     timeLimit         (IN)  -  how much time should we spend exporting the 
  --                                SQL test case
  --     testcase_name     (IN)  -  an optional name for the SQL test case. This
  --                                is used to prefix all the generated scripts.
  --     testcase          (OUT) -  the resulting test case
  --     preserveSchemaMapping
  --                       (IN)  -  TRUE if the schema(s) will NOT be re-mapped
  --                                from the original environment to the test 
  --                                environment.
  --     version           (IN) - The version of database objects to be extracted. 
  --                              This option is only valid for Export.
  --                              Database objects or attributes that are 
  --                              incompatible with the version will not be 
  --                              extracted. 
  --                              Legal values for this parameter are as follows:
  --
  --                              COMPATIBLE - (default) the version of the 
  --                                           metadata corresponds to the 
  --                                           database compatibility level and 
  --                                           the compatibility release level for 
  --                                           feature (as given in the 
  --                                           V$COMPATIBILITY view). 
  --                                           Database compatibility must be set 
  --                                           to 9.2 or higher.
  --                              LATEST     - the version of the metadata 
  --                                           corresponds to the database 
  --                                           version.
  --                              specific database version
  --                                         - for example, '10.0.0'. In Oracle 
  --                                           Database10g, this value cannot be 
  --                                           lower than 10.0.0.
  --
  ------------------------------------------------------------------------------
  PROCEDURE export_sql_testcase(
    directory                IN   VARCHAR2,
    incident_id              IN   VARCHAR2,
    exportEnvironment        IN   BOOLEAN   :=  TRUE,
    exportMetadata           IN   BOOLEAN   :=  TRUE,
    exportData               IN   BOOLEAN   :=  FALSE,
    exportPkgbody            IN   BOOLEAN   :=  FALSE,
    samplingPercent          IN   NUMBER    :=  100, 
    ctrlOptions              IN   VARCHAR2  :=  NULL,
    timeLimit                IN   NUMBER    :=  dbms_sqldiag.TIME_LIMIT_DEFAULT,
    testcase_name            IN   VARCHAR2  :=  NULL,
    testcase                 IN OUT NOCOPY CLOB,
    preserveSchemaMapping    IN   BOOLEAN   :=  FALSE,
    version                  IN   VARCHAR2  := 'COMPATIBLE'
  );


  -------------------------- export_sql_testcase ------------------------
  -- NAME: 
  --     export_sql_testcase
  --
  -- DESCRIPTION:
  --     Export a SQL test case to a directory.
  --     This API allow the SQL Testcase to be generated from a cursor
  --     present in the cursor cache.
  --     Use v$sql to get the SQL identifier and the SQL hash value.
  --     
  -- PARAMETERS:
  --     directory         (IN)  -  directory to store the various generated files
  --     sql_id            (IN)  -  identifier of the statement in the cursor cache
  --     plan_hash_value   (IN)  -  plan hash value of a particula plan of the SQL 
  --     exportEnvironment (IN)  -  TRUE if the compilation environment should be 
  --                                exported
  --     exportMetadata    (IN)  -  TRUE if the definition of the objects referenced 
  --                                in the SQL should be exported.
  --     exportData        (IN)  -  TRUE if the data of the objects referenced 
  --                                in the SQL should be exported.
  --     exportPkgbody     (IN)  -  TRUE if the body of the packages referenced 
  --                                in the SQL should be exported.
  --     samplingPercent   (IN)  -  if exportData is TRUE, specify the sampling 
  --                                percentage to use to create the dump file
  --     ctrlOptions       (IN)  -  opaque control parameters
  --     timeLimit         (IN)  -  how much time should we spend exporting the 
  --                                SQL test case
  --     testcase_name     (IN)  -  an optional name for the SQL test case. This
  --                                is used to prefix all the generated scripts.
  --     testcase          (OUT) -  the resulting test case
  --     preserveSchemaMapping
  --                       (IN)  -  TRUE if the schema(s) will NOT be re-mapped
  --                                from the original environment to the test 
  --                                environment.
  --     version           (IN) - The version of database objects to be extracted. 
  --                              This option is only valid for Export.
  --                              Database objects or attributes that are 
  --                              incompatible with the version will not be 
  --                              extracted. 
  --                              Legal values for this parameter are as follows:
  --
  --                              COMPATIBLE - (default) the version of the 
  --                                           metadata corresponds to the 
  --                                           database compatibility level and 
  --                                           the compatibility release level for 
  --                                           feature (as given in the 
  --                                           V$COMPATIBILITY view). 
  --                                           Database compatibility must be set 
  --                                           to 9.2 or higher.
  --                              LATEST     - the version of the metadata 
  --                                           corresponds to the database 
  --                                           version.
  --                              specific database version
  --                                         - for example, '10.0.0'. In Oracle 
  --                                           Database10g, this value cannot be 
  --                                           lower than 10.0.0.
  --
  ------------------------------------------------------------------------------
  PROCEDURE export_sql_testcase(
    directory                IN   VARCHAR2,
    sql_id                   IN   VARCHAR2, 
    plan_hash_value          IN   NUMBER    :=  NULL,     
    exportEnvironment        IN   BOOLEAN   :=  TRUE,
    exportMetadata           IN   BOOLEAN   :=  TRUE,
    exportData               IN   BOOLEAN   :=  FALSE,
    exportPkgbody            IN   BOOLEAN   :=  FALSE,
    samplingPercent          IN   NUMBER    :=  100, 
    ctrlOptions              IN   VARCHAR2  :=  NULL,
    timeLimit                IN   NUMBER    :=  dbms_sqldiag.TIME_LIMIT_DEFAULT,
    testcase_name            IN   VARCHAR2  :=  NULL,
    testcase                 IN OUT NOCOPY CLOB,
    preserveSchemaMapping    IN   BOOLEAN   :=  FALSE,
    version                  IN   VARCHAR2  := 'COMPATIBLE'
  );

  ------------------------------------------------------------------------------
  FUNCTION export_sql_testcase_dir_by_inc(
    incident_id              IN   NUMBER,
    directory                IN   VARCHAR2,
    samplingPercent          IN   NUMBER    :=  0,
    exportEnvironment        IN   BOOLEAN   :=  TRUE,
    exportMetadata           IN   BOOLEAN   :=  TRUE,
    exportPkgbody            IN   BOOLEAN   :=  FALSE,
    preserveSchemaMapping    IN   BOOLEAN   :=  FALSE,
    version                  IN   VARCHAR2  := 'COMPATIBLE'
  )
  RETURN BOOLEAN;

  FUNCTION export_sql_testcase_dir_by_txt(
    incident_id              IN   NUMBER,
    directory                IN   VARCHAR2,
    sql_text                 IN   CLOB,
    user_name                IN   VARCHAR2  := NULL,
    samplingPercent          IN   NUMBER    := 0,
    exportEnvironment        IN   BOOLEAN   := TRUE,
    exportMetadata           IN   BOOLEAN   := TRUE,
    exportPkgbody            IN   BOOLEAN   := FALSE,
    preserveSchemaMapping    IN   BOOLEAN   := FALSE,
    version                  IN   VARCHAR2  := 'COMPATIBLE'
  )
  RETURN BOOLEAN;

  --------------------- import_sql_testcase -----------------------------
  -- NAME: 
  --     import_sql_testcase
  --
  -- DESCRIPTION:
  --     Import a SQL Test case into a schema
  --
  -- EXPLANATION:
  --
  --     SQL test case contains a set of files needed to help
  --     reproduce a SQL problem on a different machine.
  --
  --   It contains:
  -- 
  --     1. a dump file containing schemas objects and statistics (.dmp)
  --     2. the explain plan for the statements (in advanced mode)
  --     3. diagnostic information gathered on the offending statement
  --     4. an import script to execute to reload the objects.
  --     5. a SQL scripts to replay system statistics of the source
  --     6. A table of content file describing the SQL test case 
  --        metadata. (xxxxmain.xml)
  --
  --     Usually, you only need to reference the last file (metadata file) 
  --     for importing a test case.
  --
  --     The following is an example PL/SQL script for TCB IMPORT.
  --     It uses the metadata file name (xxxxmain.xml) as an input argument
  --     when calling the import API.
  --     (You may have to modify this script for the right arguments)
  --
  --   grant connect, dba, resource, query rewrite to tcb identified by tcb;
  --
  --   create directory TCB_IMP_DIR as '<DIRECTORY_PATH_4_TCB_IMPORT>';
  -- 
  --   conn tcb/tcb;
  --
  --   exec dbms_sqldiag.import_sql_testcase(directory => 'TCB_IMP_DIR' ,
  --                              filename  => '<TCB_METADATA>main.xml');
  --
  --
  --   Note:
  --      !!! You should not run TCB under user SYS !!!
  --      Use another user, such as 'tcb', who can be granted sysdba privilege
  --
  --     .The <DIRECTORY_PATH_4_TCB_IMPORT> is the CURRENT directory where
  --      all the TCB files have resided. It must be an OS path on local 
  --      machine, such as '/tmp/bug8010101'. It cannot be a path to other 
  --      machine, for example by mounting over a network file system.
  --
  --     .By default for TCB, the data is NOT exported
  --      In some case data is required, for example, to diagnose wrong
  --      result problem.
  --        To export data, call export_sql_testcase() with
  --           exportData=>TRUE
  --
  --        Note the data will be imported by default, unless turned OFF by
  --         importData=>FALSE
  --
  --     .TCB includes PL/SQL package spec by default , but not
  --      the PL/SQL package body.
  --      You may need to have the package body as well, for exmaple,  
  --      to invoke the PL/SQL functions.  
  --        To export PL/SQL package body, call export_sql_testcase() with
  --           exportPkgbody=>TRUE
  --        To import PL/SQL package body, call import_sql_testcase() with
  --           importPkgbody=>TRUE
  --
  --     .An example that you need to include PL/SQL package (body) is
  --      you have VPD function defined in a package
  --
  -- PARAMETERS:
  --     directory         (IN) - directory containing testcase files
  --     sqlTestCase       (IN) - an XML document describing the SQL test case
  --     importEnvironment (IN) - TRUE if the compilation environment should be 
  --                              imported
  --     importMetadata    (IN) - TRUE if the definition of the objects referenced 
  --                              in the SQL should be imported.
  --     importData        (IN) - TRUE if the data of the objects referenced 
  --                              in the SQL should be imported.
  --     importPkgbody     (IN) - TRUE if the body of the packages referenced 
  --                              in the SQL should be imported.
  --     importDiagnosis   (IN) - TRUE if the diagnostic information associated to
  --                              the task should be imported
  --     ignoreStorage     (IN) - TRUE if the storage attributes should be ignored
  --     ctrlOptions       (IN) - opaque control parameters
  --     preserveSchemaMapping
  --                       (IN) - TRUE if the schema(s) will NOT be re-mapped
  --                              from the original environment to the test 
  --                              environment.
  ------------------------------------------------------------------------------
  PROCEDURE import_sql_testcase(
    directory                IN   VARCHAR2,
    sqlTestCase              IN   CLOB,
    importEnvironment        IN   BOOLEAN   :=  TRUE,
    importMetadata           IN   BOOLEAN   :=  TRUE,
    importData               IN   BOOLEAN   :=  TRUE,
    importPkgbody            IN   BOOLEAN   :=  FALSE,
    importDiagnosis          IN   BOOLEAN   :=  TRUE,
    ignoreStorage            IN   BOOLEAN   :=  TRUE,
    ctrlOptions              IN   VARCHAR2  :=  NULL,
    preserveSchemaMapping    IN   BOOLEAN   :=  FALSE);


  --------------------- import_sql_testcase -----------------------------
  -- NAME: 
  --     import_sql_testcase
  --
  -- DESCRIPTION:
  --     Import a SQL Test case into a schema from a directory and a file name
  --
  -- PARAMETERS:
  --     directory         (IN) - directory containing testcase files
  --     filename          (IN) - the name of a file containing an XML document 
  --                              describing the SQL test case
  --     importEnvironment (IN) - TRUE if the compilation environment should be 
  --                              imported
  --     importMetadata    (IN) - TRUE if the definition of the objects referenced 
  --                              in the SQL should be imported.
  --     importData        (IN) - TRUE if the data of the objects referenced 
  --                              in the SQL should be imported.
  --     importPkgbody     (IN) - TRUE if the body of the packages referenced 
  --                              in the SQL should be imported.
  --     importDiagnosis   (IN) - TRUE if the diagnostic information associated to
  --                              the task should be imported
  --     ignoreStorage     (IN) - TRUE if the storage attributes should be ignored
  --     ctrlOptions       (IN) - opaque control parameters
  --     preserveSchemaMapping
  --                       (IN) - TRUE if the schema(s) will NOT be re-mapped
  --                              from the original environment to the test 
  --                              environment.
   ------------------------------------------------------------------------------
  PROCEDURE import_sql_testcase(
    directory                IN   VARCHAR2,
    filename                 IN   VARCHAR2,
    importEnvironment        IN   BOOLEAN   :=  TRUE,
    importMetadata           IN   BOOLEAN   :=  TRUE,
    importData               IN   BOOLEAN   :=  TRUE,
    importPkgbody            IN   BOOLEAN   :=  FALSE,
    importDiagnosis          IN   BOOLEAN   :=  TRUE,
    ignoreStorage            IN   BOOLEAN   :=  TRUE,
    ctrlOptions              IN   VARCHAR2  :=  NULL,
    preserveSchemaMapping    IN   BOOLEAN   :=  FALSE);

  ------------------------ explain_sql_testcase -----------------------------
  FUNCTION explain_sql_testcase(
    sqlTestCase        IN CLOB)
  RETURN CLOB;

  ----------------------------- incidentid_2_sql --------------------------
  -- NAME:
  --     incidentid_2_sql: 
  --
  -- DESCRIPTION:
  --     Initialize a sql_setrow from an incident ID.
  --     Given a valid incident ID this function parses the trace file and 
  --     extract as much information as possible about the SQL that causes
  --     the generation of this incident (SQL text, user name, binds, etc...). 
  --        
  -- PARAMETERS
  --     incident_id      (IN)  - Identifier of the incident
  --     sql_stmt         (OUT) - the resulting SQL
  --     problem_type     (OUT) - tentative type of SQL problem (currently 
  --                              among PROBLEM_TYPE_COMPILATION_ERROR and 
  --                              PROBLEM_TYPE_EXECUTION_ERROR)  
  --     err_code         (OUT) - error code if any otherwise it is set to null 
  --     err_mesg         (OUT) - error message if any otherwise it is set to 
  --                              null
  --
  -- RETURN:
  --   VOID
  ------------------------------------------------------------------------------
  PROCEDURE incidentid_2_sql(
    incident_id  IN     VARCHAR2,
    sql_stmt     OUT    SQLSET_ROW,
    problem_type OUT    NUMBER, 
    err_code     OUT    BINARY_INTEGER,
    err_mesg     OUT    VARCHAR2);

  ----------------------------- getSql --------------------------
  -- NAME:
  --     getsql: 
  --
  -- DESCRIPTION:
  --     load a sql_setrow from the trace file associated to an
  --   the given incident ID.
  --
  -- PARAMETERS
  --     incident_id      (IN)  - Identifier of the incident
  --
  -- RETURN:
  --   a sqlset_row containing the SQL statement
  ------------------------------------------------------------------------------
  FUNCTION getsql(
    incident_id  IN     VARCHAR2)
  RETURN SQLSET_ROW;

  ------------------------ set_tcb_tracing -------------------------------------
  -- NAME: 
  --     set_tcb_tracing - enable/disable TCB tracing
  --
  -- DESCRIPTION:
  --     This function enable/disble TCB tracing 
  --     (for Oracle Support/Development use only)
  --
  -- PARAMETERS:
  --     status        (IN)  -  status to set
  ------------------------------------------------------------------------------
  PROCEDURE set_tcb_tracing(status IN   BOOLEAN   :=  TRUE);

  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --                 -------------------------------------                    --
  --                 SQL DIAG ADVISOR PROCEDURES/FUNCTIONS                    --
  --                 -------------------------------------                    --
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

  ----------------------------- create_diagnosis_task --------------------------
  FUNCTION create_diagnosis_task(
    sql_text           IN   CLOB,
    bind_list          IN   sql_binds := NULL,
    user_name          IN   VARCHAR2  := NULL,
    scope              IN   VARCHAR2  := SCOPE_COMPREHENSIVE,    
    time_limit         IN   NUMBER    := TIME_LIMIT_DEFAULT, 
    task_name          IN   VARCHAR2  := NULL,    
    description        IN   VARCHAR2  := NULL,
    problem_type       IN   NUMBER    := PROBLEM_TYPE_PERFORMANCE)
  RETURN VARCHAR2;
  
  ----------------------------- create_diagnosis_task --------------------------
  FUNCTION create_diagnosis_task(
    sql_id             IN   VARCHAR2, 
    plan_hash_value    IN   NUMBER   := NULL, 
    scope              IN   VARCHAR2 := SCOPE_COMPREHENSIVE,    
    time_limit         IN   NUMBER   := TIME_LIMIT_DEFAULT, 
    task_name          IN   VARCHAR2 := NULL,    
    description        IN   VARCHAR2 := NULL,
    problem_type       IN   NUMBER    := PROBLEM_TYPE_PERFORMANCE)
  RETURN VARCHAR2;

  ----------------------------- create_diagnosis_task --------------------------
  FUNCTION create_diagnosis_task(
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
    sqlset_owner      IN VARCHAR2 :=  NULL,
    problem_type      IN NUMBER   := PROBLEM_TYPE_PERFORMANCE)
  RETURN VARCHAR2;

  ----------------------------- drop_diagnosis_task ---------------------------
  PROCEDURE drop_diagnosis_task(
    task_name          IN   VARCHAR2);
  
  ----------------------------- execute_diagnosis_task -------------------------
  PROCEDURE execute_diagnosis_task(
    task_name          IN   VARCHAR2);
  
  ---------------------------- interrupt_diagnosis_task ------------------------
  PROCEDURE interrupt_diagnosis_task(
    task_name          IN   VARCHAR2);
    
  ------------------------------ cancel_diagnosis_task -------------------------
  PROCEDURE cancel_diagnosis_task(
    task_name          IN   VARCHAR2);
    
  ------------------------------ reset_diagnosis_task --------------------------
  PROCEDURE reset_diagnosis_task(
    task_name          IN   VARCHAR2);
    
  ------------------------------ resume_diagnosis_task -------------------------
  PROCEDURE resume_diagnosis_task(
    task_name          IN   VARCHAR2);
  
  ------------------------------- report_diagnosis_task ------------------------
  FUNCTION report_diagnosis_task(
    task_name          IN   VARCHAR2,
    type               IN   VARCHAR2  := TYPE_TEXT,
    level              IN   VARCHAR2  := LEVEL_TYPICAL,
    section            IN   VARCHAR2  := SECTION_FINDINGS, 
    object_id          IN   NUMBER    := NULL,
    result_limit       IN   NUMBER    := NULL,
    owner_name         IN   VARCHAR2  := NULL)
  RETURN CLOB;
 
  -------------------------- set_diagnosis_task_parameter ----------------------
  PROCEDURE set_diagnosis_task_parameter(
    task_name          IN   VARCHAR2,
    parameter          IN   VARCHAR2,
    value              IN   NUMBER);


  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --               ------------------------------------------                 --
  --                        SQL PATCH SUPPORT FUNCTIONS                       --
  --               ------------------------------------------                 --
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
  --++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--

  -- NAME: accept_sql_patch - accept a sqldiag recommended SQL patch,
  --                            FUNCTION version
  -- PURPOSE:  This procedure accepts a SQL patch as recommended by the 
  --           specified SQL tuning task.
  -- INPUTS: task_name    - (REQUIRED) The name of the SQL tuning task.
  --         object_id    - The identifier of the advisor framework object
  --                        representing the SQL statement associated
  --                        to the tuning task.
  --         name         - This is the name of the patch.  It cannot contain
  --                        double quotation marks. The name is case sensitive.
  --                        If not specified, the system will generate a unique
  --                        name for the SQL patch.
  --         description -  A user specified string describing the purpose
  --                        of this SQL patch. Max size of description is 500.
  --         category    -  This is the category name which must match the
  --                        value of the SQLTUNE_CATEGORY parameter in a session
  --                        for the session to use this patch.  It defaults
  --                        to the value "DEFAULT".  This is also the default
  --                        of the SQLTUNE_CATEGORY parameter.  The category
  --                        must be a valid Oracle identifier. The category
  --                        name specified is always converted to upper case.
  --                        The combination of the normalized SQL text and
  --                        category name create a unique key for a patch.
  --                        An accept will fail if this combination is 
  --                        duplicated.
  --         task_owner  -  Owner of the tuning task. This is an optional 
  --                        parameter that has to be specified to accept 
  --                        a SQL Patch associated to a tuning task owned
  --                        by another user. The current user is the default
  --                        value. 
  --         replace      - If the patch already exists, it will be
  --                        replaced if this argument is TRUE.
  --                        It is an error to pass a name that is already
  --                        being used for another signature/category pair,
  --                        even with replace set to TRUE.
  --         force_match  - If TRUE this causes SQL Patchs
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
  -- RETURNS: name        - The name of the SQL patch. 
  --
  -- REQUIRES: "CREATE ANY SQL PATCH" privilege
  --  
  FUNCTION accept_sql_patch(
                   task_name    IN VARCHAR2,
                   object_id    IN NUMBER   := NULL,
                   name         IN VARCHAR2 := NULL,
                   description  IN VARCHAR2 := NULL,
                   category     IN VARCHAR2 := NULL,
                   task_owner   IN VARCHAR2 := NULL,
                   replace      IN BOOLEAN  := FALSE,
                   force_match  IN BOOLEAN  := FALSE)
  RETURN VARCHAR2;
  
  -- NAME: accept_sql_patch - accept a sqldiag recommended SQL patch,
  --                            PROCEDURE version
  -- PURPOSE:  This procedure accepts a SQL patch as recommended by the 
  --           specified SQL tuning task.
  -- INPUTS: task_name    - (REQUIRED) The name of the SQL tuning task.
  --         object_id    - Identifier of the advisor framework
  --                        object representing the SQL statement associated
  --                        to the tuning task.
  --         name         - This is the name of the patch.  It 
  --                        cannot contain double quotation marks. The name is
  --                        case sensitive.
  --         description  - A user specified string describing the purpose
  --                        of this SQL patch. Max size of description is 500.
  --         category     - This is the category name which must match the
  --                        value of the SQLTUNE_CATEGORY parameter in a session
  --                        for the session to use this patch.  It defaults
  --                        to the value "DEFAULT".  This is also the default
  --                        of the SQLTUNE_CATEGORY parameter.  The category
  --                        must be a valid Oracle identifier. The category
  --                        name specified is always converted to upper case.
  --                        The combination of the normalized SQL text and
  --                        category name create a unique key for a patch.
  --                        An accept will fail if this combination is 
  --                        duplicated.
  --         task_owner   - Owner of the tuning task. This is an optional 
  --                        parameter that has to be specified to accept 
  --                        a SQL Patch associated to a tuning task owned
  --                        by another user. The current user is the default
  --                        value. 
  --         replace      - If the patch already exists, it will be
  --                        replaced if this argument is TRUE.
  --                        It is an error to pass a name that is already
  --                        being used for another signature/category pair,
  --                        even with replace set to TRUE.
  --         force_match  - If TRUE this causes SQL Patchs
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
  --
  -- REQUIRES: "CREATE ANY SQL PATCH" privilege
  --  
  PROCEDURE accept_sql_patch(
                   task_name    IN VARCHAR2,
                   object_id    IN NUMBER   := NULL,
                   name         IN VARCHAR2 := NULL,
                   description  IN VARCHAR2 := NULL,
                   category     IN VARCHAR2 := NULL,
                   task_owner   IN VARCHAR2 := NULL,
                   replace      IN BOOLEAN  := FALSE,
                   force_match  IN BOOLEAN  := FALSE);
  
  -- NAME: drop_sql_patch - drop a SQL patch
  -- PURPOSE:  This procedure drops the named SQL patch from the database.
  -- INPUTS: name      - (REQUIRED)Name of patch to be dropped.  The name
  --                     is case sensitive.
  --         ignore    - Ignore errors due to object not existing.
  -- REQUIRES: "DROP ANY SQL PATCH" privilege
  --
  PROCEDURE drop_sql_patch(
                   name          IN VARCHAR2,
                   ignore        IN BOOLEAN  := FALSE);

  -- NAME: alter_sql_patch - alter a SQL patch attribute
  -- PURPOSE: This procedure alters specific attributes of an existing
  --          SQL patch object.  The following attributes can be altered
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
  -- INPUTS: name      - (REQUIRED)Name of SQL patch to alter. The name
  --                     is case sensitive.
  --         attribute_name - (REQUIRED)The attribute name to alter (case
  --                     insensitive).
  --                     See list above for valid attribute names.
  --         value     - (REQUIRED)The new value of the attribute.  See list
  --                     above for valid attribute values.
  -- REQUIRES: "ALTER ANY SQL PATCH" privilege
  --
  PROCEDURE alter_sql_patch(
                   name                 IN VARCHAR2,
                   attribute_name       IN VARCHAR2,
                   value                IN VARCHAR2);

  -------------------------------- dump_trace ---------------------------------
  -- NAME: 
  --     dump_trace - Dump Optimizer Trace
  --
  -- DESCRIPTION:
  --     This procedure dumps the optimizer or compiler trace for a give SQL 
  --     statement identified by a SQL ID and an optional child number. 
  --
  -- PARAMETERS:
  --     p_sql_id          (IN)  -  identifier of the statement in the cursor 
  --                                cache
  --     p_child_number    (IN)  -  child number
  --     p_component       (IN)  -  component name
  --                                Valid values are Optimizer and Compiler
  --                                The default is Optimizer
  --     p_file_id         (IN)  -  file identifier
  ------------------------------------------------------------------------------
  PROCEDURE dump_trace(
                p_sql_id         IN varchar2, 
                p_child_number   IN number   DEFAULT 0, 
                p_component      IN varchar2 DEFAULT 'Optimizer',
                p_file_id        IN varchar2 DEFAULT null);

  -------------------------------- get_fix_control -----------------------------
  -- NAME: 
  --     get_fix_control - Get Fix Control
  --
  -- DESCRIPTION:
  --     This function returns the value of fix control for a given bug number. 
  --
  -- PARAMETERS:
  --     bug_number        (IN)  -  bug number
  ------------------------------------------------------------------------------
  FUNCTION get_fix_control(bug_number IN NUMBER) 
  RETURN NUMBER;

  -------------------------------- load_sqlset_from_tcb ------------------------
  -- NAME: 
  --     load_sqlset_from_tcb - Load a SQLSET from Test Case Builder file
  --
  -- DESCRIPTION:
  --     This function loads a sqlset created from TCB sql object file and 
  --     returns the loaded sqlset name. 
  --
  --     The sqlset can later be used as input for SQL repair advisor etc.
  --
  -- NOTE:
  --     The TCB sql object file is usually named something like: xxxxsql.xml.
  --     It contains the sql_text, parsing_schema, optimizer environment etc
  --     from the original environment where the test case was created.
  --
  --     For example:
  --     ------------
  --      <SQL_OBJECT>
  --        <SQL_ID>6qanqm2xvq94u</SQL_ID>
  --        <SQL_TEXT>explain plan for
  --                  select unit_cost, sold
  --                  from costs c,
  --                  ...
  --                  where c.prod_id = v.prod_id
  --        </SQL_TEXT>
  --        <PARSING_SCHEMA_NAME>SH</PARSING_SCHEMA_NAME>
  --        <MODULE>SQL*Plus</MODULE>
  --        <OPTIMIZER_ENV>  E289FB89E12 ... </OPTIMIZER_ENV>
  --        <PLAN_HASH_VALUE> ... </PLAN_HASH_VALUE>
  --      </SQL_OBJECT>
  --
  -- PARAMETERS:
  --     directory      (IN)     - directory containing testcase files
  --     filename       (IN)     - the name of a file containing the sql object 
  --     sqlset_name    (IN OUT) - a sqlset_row containing the SQL statement
  ------------------------------------------------------------------------------
  FUNCTION load_sqlset_from_tcb(
    directory        IN     VARCHAR2,
    filename         IN     VARCHAR2,
    sqlset_name      IN     VARCHAR2 DEFAULT NULL)
  RETURN VARCHAR2;


  ----------------------------- create_stgtab_sqlpatch ------------------------
  PROCEDURE create_stgtab_sqlpatch(
                table_name            IN VARCHAR2,
                schema_name           IN VARCHAR2 := NULL,
                tablespace_name       IN VARCHAR2 := NULL);

  ------------------------------ pack_stgtab_sqlpatch -------------------------
  PROCEDURE pack_stgtab_sqlpatch(
                  patch_name            IN VARCHAR2 := '%',
                  patch_category        IN VARCHAR2 := 'DEFAULT',
                  staging_table_name    IN VARCHAR2,
                  staging_schema_owner  IN VARCHAR2 := NULL);

  ---------------------------- unpack_stgtab_sqlpatch -------------------------
  PROCEDURE unpack_stgtab_sqlpatch(
                  patch_name            IN VARCHAR2 := '%',
                  patch_category        IN VARCHAR2 := '%',
                  replace               IN BOOLEAN,
                  staging_table_name    IN VARCHAR2,
                  staging_schema_owner  IN VARCHAR2 := NULL);

END dbms_sqldiag;
/ 
show errors;


--------------------------------------------------------------------------------
--                    Public synonym for the package                          --
--------------------------------------------------------------------------------
CREATE OR REPLACE PUBLIC SYNONYM dbms_sqldiag FOR dbms_sqldiag
/
show errors;
/

--------------------------------------------------------------------------------
--            Granting the execution privilege to the public role             --
--------------------------------------------------------------------------------
GRANT EXECUTE ON dbms_sqldiag TO public
/
show errors;
/  
