Rem
Rem $Header: rdbms/admin/dbmswrr.sql /st_rdbms_11.2.0/3 2013/04/04 15:54:59 hpoduri Exp $
Rem
Rem dbmswrr.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmswrr.sql - DBMS_WORKLOAD_CAPTURE package
Rem
Rem    DESCRIPTION
Rem      Defines the packages DBMS_WORKLOAD_CAPTURE and 
Rem      DBMS_WORKLOAD_REPLAY.
Rem      
Rem      The DBMS_WORKLOAD_CAPTURE package is used to capture 
Rem      a database workload. A workload capture
Rem      created using this package can be replayed later in a
Rem      different database that is properly setup.
Rem
Rem      The DBMS_WORKLOAD_REPLAY package is used to:
Rem      1) Process the captured workload and make it suitable
Rem         for replaying.
Rem      2) Initiate and control the replay (more to come).
Rem
Rem
Rem    NOTES
Rem      Only SYS can use this feature
Rem
Rem      Package will include procedures that make Trusted Callouts
Rem      to the kernel
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmswrr.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmswrr.sql
Rem SQL_PHASE: CATPDBMS_MAIN
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hpoduri     12/03/12 - fixing lrg-8531281
Rem    yujwang     11/12/12 - fix lrg 8486334
Rem    hpoduri     11/01/12 - support ash compare time period report
Rem    yujwang     08/01/12 - add default value for generate_capture_subset
Rem    yberezin    09/05/12 - move library definitions from body to spec
Rem                           because dbms_random needs them
Rem    kmorfoni    07/17/12 - make object_id the default synchronization method
Rem    lgalanis    05/03/12 - adjust times in dba_workload_captures to match
Rem                           ash time stamps
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    lgalanis    03/15/12 - add TYPE_XML to capture report
Rem    lgalanis    12/22/11 - add set_user_mapping
Rem    spapadom    11/10/11 - API changes from AS Replay
Rem    yujwang     04/05/11 - add separate APIs for consolidated replays
Rem    yujwang     02/16/11 - add remap_connection for consolidation
Rem    kmorfoni    02/09/11 - Merge methods for consolidated replay with
Rem                           methods for normal replay
Rem    yujwang     02/05/10 - add consolidated replay
Rem    rcolle      01/29/10 - add utility to extract captured objects
Rem    lgalanis    01/28/10 - EM API for workload tagging bug 8896806
Rem    sburanaw    01/12/10 - add reuse_replay_filter_set()
Rem    lgalanis    11/20/09 - bug 9134254
Rem    lgalanis    10/16/09 - add doc comments
Rem    yujwang     10/16/09 - add SET_REPLAY_TIMEOUT and GET_REPLAY_TIMEOUT
Rem    lgalanis    09/29/09 - add task name to compare_sqlset_report
Rem    lgalanis    09/22/09 - remove sts_name option from start capture
Rem    lgalanis    09/11/09 - call into replay only when necessary
Rem    rcolle      08/04/09 - add dependent SCN tracking for new
Rem                           synchronization
Rem    lgalanis    04/03/09 - add compare_sqlset_report
Rem    lgalanis    03/24/09 - add support for STS capture with Capture and
Rem                           Replay
Rem    rcolle      03/05/09 - extended divergence reporting for EM
Rem    rcolle      02/23/09 - AS Replay schema
Rem    ushaft      01/14/09 - add dbms_workload_replay.compare_period_report
Rem    rcolle      11/17/08 - add replay filters
Rem    yujwang     10/03/08 - add workload scale-up at prepare_replay
Rem    rcolle      09/30/08 - add export_uc_graph
Rem    sburanaw    05/16/08 - add get_path
Rem    rcolle      08/27/08 - add is_paused feature
Rem    rcolle      08/21/08 - add API for new sync
Rem    rcolle      05/09/08 - add populate_divergence
Rem    rcolle      04/09/08 - fix client_vitals bug
Rem    rcolle      03/19/08 - add user calls metrics graph imp/exp
Rem    rcolle      11/27/07 - add progression estimate for processing
Rem    lgalanis    11/20/07 - add advanced parameters to replay
Rem    lgalanis    09/21/07 - client stats update api
Rem    rcolle      09/07/07 - add KECP_CLIENT_CONNECT_CHK_VSN
Rem    veeve       08/15/07 - add REPLAY.PAUSE/RESUME
Rem    rcolle      06/27/07 - parallel preprocessing
Rem    rcolle      06/15/07 - callout for calibrate
Rem    veeve       05/31/07 - add KECP_CLIENT_CONNECT_CLOCK_TICK
Rem    rcolle      05/18/07 - add KECP_CLIENT_CONNECT_CHKPPID
Rem    veeve       05/29/07 - add force_cleanup to IMPORT_AWR
Rem    lgalanis    04/25/07 - comment changes
Rem    veeve       04/05/07 - added TYPE_ constants
Rem    veeve       02/19/07 - capture/replay export_awr/import_awr API
Rem    veeve       08/30/06 - made initialize_replay mandatory
Rem    lgalanis    08/22/06 - finish capture with a reason
Rem    yujwang     08/06/06 - add remap_connection for workload replay
Rem    veeve       07/27/06 - add reason to CANCEL_REPLAY
Rem    veeve       07/25/06 - add KECP_CLIENT_CONNECT_THRDFAIL
Rem    veeve       07/13/06 - add {get|delete}_{capture|replay}_info
Rem    veeve       06/12/06 - grant permissions to exec_catalog, dba
Rem    lgalanis    06/02/06 - initialize replay 
Rem    kdias       05/25/06 - rename recording to capture 
Rem    veeve       03/27/06 - add replay interface
Rem    lgalanis    03/14/06 - replay interface (partial) 
Rem    veeve       01/25/06 - Created
Rem

/* -------------------------------------------------------------------------
   DBMS_WORKLOAD_CAPTURE_LIB - For all kernel trusted callouts from
                              DBMS_WORKLOAD_CAPTURE
 * ------------------------------------------------------------------------- */

CREATE OR REPLACE LIBRARY dbms_workload_capture_lib TRUSTED IS STATIC;
/

/* -------------------------------------------------------------------------
   DBMS_WORKLOAD_REPLAY_LIB - For all kernel trusted callouts from
                              DBMS_WORKLOAD_REPLAY
 * ------------------------------------------------------------------------- */

CREATE OR REPLACE LIBRARY dbms_workload_replay_lib TRUSTED IS STATIC;
/


CREATE OR REPLACE PACKAGE dbms_workload_capture AS

  -- ***********************************************************
  --  START_CAPTURE
  --    Initiates a database wide workload capture.
  --
  --    All user requests sent to database after a successful 
  --    DBMS_WORKLOAD_CAPTURE.START_CAPTURE() will be recorded in the 
  --    given "dir" directory for the given duration, if one was specified.
  --    If no duration was specified, then the capture will last indefinitely
  --    until DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE() is executed.
  --
  --    One can use workload filters (see DBMS_WORKLOAD_CAPTURE.ADD_FILTER)
  --    to only capture a subset of the user requests sent to the database.
  --    By default, when no workload filters are defined, all user requests
  --    will be captured.
  --
  --    Workload that is initiated from Oracle Database background
  --    processes (such as SMON, PMON, MMON etc) and Oracle Database Scheduler
  --    Jobs (DBMS_SCHEDULER/DBMS_JOB) will not be captured, no matter how
  --    the workload filters are defined. These activities should happen
  --    automatically on an appropriately configured replay system.
  --
  --    By default, all database instances that were started up in
  --    RESTRICTED mode using STARTUP RESTRICT will be UNRESTRICTED upon a
  --    successful START_CAPTURE. Use FALSE for the "auto_unrestrict"
  --    input parameter, if you do not want this behavior.
  --
  --    NOTE:
  --      It is important to have a well-defined starting point for the
  --      workload, so that the replay system could be restored to that
  --      point before initiating a replay of the captured workload.
  --      In order to have a well-defined starting point for the workload
  --      capture, it is preferable to not have any sessions that were
  --      in-flight when START_CAPTURE is executed. If those in-flight 
  --      sessions had in-flight transactions, then those in-flight 
  --      transactions will not be replayed properly in subsequent 
  --      database replays, since only the part of the transaction 
  --      whose calls were executed after START_CAPTURE will actually 
  --      be replayed.
  --      That said, not replaying transactions that were in-flight when
  --      START_CAPTURE was executed is not an issue in many (if not most)
  --      database systems. Please evaluate whether this might be an issue
  --      in your database system and take appropriate action to avoid
  --      in-flight sessions during START_CAPTURE.
  --
  --    The procedure will take as input the following parameters:
  --      name        - name of the workload capture
  --                    (MANDATORY)
  --
  --      dir         - name of the DIRECTORY object (case sensitive)
  --                    where all the workload capture files 
  --                    will be written to. 
  --                    Should contain enough space to hold 
  --                    all the workload capture files.
  --                    (MANDATORY)
  --
  --      duration    - Optional input to specify
  --                    the duration (in seconds) for which 
  --                    the workload needs to be captured.
  --                    DEFAULT VALUE: NULL or in other words
  --                    workload will be captured until the user 
  --                    executes DBMS_WORKLOAD_CAPTURE.FINISH_CAPTURE
  --
  --      default_action - Can be either 'INCLUDE' or 'EXCLUDE'.
  --                       Determines whether, by default, every user 
  --                       request should be captured or not. Also determines,
  --                       whether the workload filters specified
  --                       should be considered as INCLUSION filters or
  --                       EXCLUSION filters.
  --
  --                       If it is 'INCLUDE' then by default all user
  --                       requests to the database will be captured, except
  --                       for the part of the workload defined by the
  --                       filters. In this case, all the filters that were
  --                       specified using the ADD_FILTER() API
  --                       will be treated as EXCLUSION filters, and will
  --                       determine the workload that WILL NOT BE captured.
  --
  --                       If it is 'EXCLUDE' then by default no user
  --                       request to the database will be captured, except
  --                       for the part of the workload defined by the 
  --                       filters. In this case, all the filters that were
  --                       specified using the ADD_FILTER() API
  --                       will be treated as INCLUSION filters, and will
  --                       determine the workload that WILL BE captured.
  --
  --                       DEFAULT VALUE: 'INCLUDE' and all the filters
  --                       specified will be assumed to be EXCLUSION filters.
  --
  --      auto_unrestrict - If this parameter is TRUE, then all instances
  --                        that were started up in RESTRICTED mode using
  --                        STARTUP RESTRICT will be automatically 
  --                        unrestricted upon a successful START_CAPTURE.
  --                        
  --                        If this parameter is FALSE, then no database
  --                        instance will be automatically unrestricted.
  --
  --                        DEFAULT VALUE: TRUE
  --
  --          capture_sts - If this parameter is TRUE, a SQL tuning set
  --                        capture is also started in parallel with workload
  --                        capture. The resulting SQL tuning set can be
  --                        exported using DBMS_WORKLOAD_CAPTURE.EXPORT_AWR
  --                        along with the AWR data. 
  --
  --                        Currently, parallel STS capture
  --                        is not supported in RAC. So, this parameter has
  --                        no effect in RAC. 
  --                        
  --                        Furthermore capture filters defined using the
  --                        dbms_workload_capture APIs do not apply to the
  --                        sql tuning set capture.
  --
  --                        The calling user must have the approriate
  --                        privileges ('administer sql tuning set').
  --        
  --                        If starting SQL set capture fails, workload capture
  --                        is stopped. The reason is stored in 
  --                        DBA_WORKLOAD_CAPTURES.ERROR_MESSAGE
  --                  
  --                        DEFAULT VALUE: FALSE
  --
  --     sts_cap_interval - This parameter specifies the capture interval
  --                        of the SQL set capture from the cursor cache in
  --                        seconds. The default value is 300.
  --                        
  --      
  -- ***********************************************************
  PROCEDURE START_CAPTURE( name             IN VARCHAR2,
                           dir              IN VARCHAR2,
                           duration         IN NUMBER   DEFAULT NULL,
                           default_action   IN VARCHAR2 DEFAULT 'INCLUDE',
                           auto_unrestrict  IN BOOLEAN  DEFAULT TRUE,
                           capture_sts      IN BOOLEAN  DEFAULT FALSE,
                           sts_cap_interval IN NUMBER DEFAULT 300);

  -- ***********************************************************
  --  FINISH_CAPTURE
  --    Signals all connected sessions to stop the workload capture
  --    and then stops future requests to the database from being
  --    captured.
  --
  --    By default, FINISH_CAPTURE will wait for 30 secs to
  --    receive a successful acknowledgement from all sessions 
  --    in the database cluster, before timing out.
  --
  --    All sessions that either were in the middle of executing a 
  --    user request or received a new user request, while FINISH_CAPTURE
  --    was waiting for acknowledgements, will flush their buffers and 
  --    send back their acknowledgement to FINISH_CAPTURE.
  --
  --    If a database session remains idle (waiting for the next user request)
  --    throughout the duration of FINISH_CAPTURE, then that session 
  --    might have unflushed capture buffers and will not send it's
  --    acknowledgement to FINISH_CAPTURE.
  --
  --    In order to avoid such situations, do not have sessions that 
  --    remain idle (waiting for the next user request) throughout the 
  --    duration of FINISH_CAPTURE; either close such database sessions
  --    before running FINISH_CAPTURE or send new database requests 
  --    to those sessions during FINISH_CAPTURE.
  --
  --    The procedure will take as input the following parameters:
  --    timeout - Specify in seconds for how long FINISH_CAPTURE
  --              should wait before it times out.
  --              Pass 0 if you want to CANCEL the current workload
  --              capture and not wait for any sessions to
  --              flush it's capture buffers.
  --              DEFAULT VALUE: 30 seconds
  --
  --    reason  - Specify a reason for calling finish capture. The 
  --              reason will appear in the column ERROR_MESSAGE of the
  --              view DBA_WORKLOAD_CAPTURES. 
  --
  -- ***********************************************************
  PROCEDURE FINISH_CAPTURE(timeout  IN NUMBER  DEFAULT 30,
                           reason   IN VARCHAR2 DEFAULT NULL);

  -- ***********************************************************
  --  GET_CAPTURE_INFO
  --    Looks into the workload capture present in the given directory
  --    and retrieves all the information regarding that capture,
  --    imports the information into the DBA_WORKLOAD_CAPTURES and
  --    DBA_WORKLOAD_FILTERS views and returns the appropriate
  --    DBA_WORKLOAD_CAPTURES.ID
  --    
  --    If an appropriate row describing the capture in the given directory
  --    already exists in DBA_WORKLOAD_CAPTURES, then GET_CAPTURE_INFO
  --    will simply return that row's DBA_WORKLOAD_CAPTURES.ID
  --    If no existing row matches the capture present in the 
  --    given directory a new row will be inserted to DBA_WORKLOAD_CAPTURES
  --    and that rows ID will be returned.
  --    
  --    The procedure will take as input the following parameters:
  --      dir         - name of the DIRECTORY object (case sensitive)
  --                    where all the workload capture files 
  --                    are present. 
  --                    (MANDATORY)
  --
  -- ***********************************************************
  FUNCTION GET_CAPTURE_INFO(dir    IN VARCHAR2)
  RETURN   NUMBER;

  -- ***********************************************************
  --  DELETE_CAPTURE_INFO
  --    Deletes the rows in DBA_WORKLOAD_CAPTURES and DBA_WORKLOAD_FILTERS
  --    that corresponds to the given workload capture id.
  --    
  --    The procedure will take as input the following parameters:
  --      capture_id  - ID of the workload capture that needs 
  --                    to be deleted.
  --                    Corresponds to DBA_WORKLOAD_CAPTURES.ID
  --                    (MANDATORY)
  --
  -- ***********************************************************
  PROCEDURE DELETE_CAPTURE_INFO(capture_id    IN NUMBER);

  -- ***********************************************************
  --  REPORT
  --    Generates a report on the given workload capture.
  --
  --    The function will take as input the following parameters:
  --      capture_id  - ID of the workload capture 
  --                    whose capture report is required.
  --                    (MANDATORY)
  --      format      - Specifies the report format 
  --                    Valid values are 
  --                    DBMS_WORKLOAD_CAPTURE.TYPE_TEXT,
  --                    DBMS_WORKLOAD_CAPTURE.TYPE_HTML and
  --         (internal) DBMS_WORKLOAD_CAPTURE.TYPE_XML
  --                    (MANDATORY)
  -- ***********************************************************

  --
  -- report type (possible values) constants  
  --
  TYPE_TEXT           CONSTANT   VARCHAR2(4) := 'TEXT'       ; 
  TYPE_HTML           CONSTANT   VARCHAR2(4) := 'HTML'       ;
  TYPE_XML            CONSTANT   VARCHAR2(3) := 'XML'        ;
  TYPE_XML_CC         CONSTANT   VARCHAR2(6) := 'XML_CC'     ;

  FUNCTION  REPORT( capture_id IN NUMBER,
                    format     IN VARCHAR2 )
  RETURN    CLOB;

  -- ***********************************************************
  -- ADD_FILTER
  --   Adds a filter to capture only a subset of the workload. 
  --
  --   The workload capture filters work in either
  --   the DEFAULT INCLUSION or the DEFAULT EXCLUSION mode
  --   as determined by the "default_action" input to the 
  --   START_CAPTURE() API.
  -- 
  --   The ADD_FILTER() API adds a new filter that will
  --   affect the next workload capture, and whether the filters
  --   will be considered as "INCLUSION" filters or "EXCLUSION" filters
  --   depends on the value of the "default_action" input to
  --   DBMS_WORKLOAD_CAPTURE.START_CAPTURE()
  -- 
  --   *****************************
  --   SCOPE of the filter specified
  --   *****************************
  --   Filters once specified are valid only for the next workload 
  --   capture. If the same set of filters need to be used for
  --   subsequent capture, they need to be specified each time before
  --   START_CAPTURE is executed. Filters used for past captures can
  --   be queried from the DBA_WORKLOAD_FILTERS view.
  --
  --    The function will take as input the following parameters:
  --        fname      - Name of the filter. Can be used to delete
  --                     the filter later if it is not required.
  --                     (MANDATORY)
  --        fattribute - Specifies the attribute on which the filter is 
  --                     defined. Should be one of the following values:
  --                     INSTANCE_NUMBER - type NUMBER
  --                     USER       - type STRING
  --                     MODULE     - type STRING
  --                     ACTION     - type STRING
  --                     PROGRAM    - type STRING
  --                     SERVICE    - type STRING
  --                     (MANDATORY)
  --        fvalue     - Specifies the value to which the given
  --                     'attribute' should be equal to for the
  --                     filter to be considered active.
  --                     Wildcards like '%' are acceptable for all
  --                     attributes that are of type STRING.
  --                     (MANDATORY)
  --    
  --   In other words, the filter for a NUMBER attribute will be 
  --   equated as:
  --     "attribute = value"
  --   And, the filter for a STRING attribute will be equated as:
  --     "attribute like value"
  -- 
  -- ***********************************************************
  PROCEDURE ADD_FILTER( fname          IN VARCHAR2,
                        fattribute     IN VARCHAR2,
                        fvalue         IN VARCHAR2);
  PROCEDURE ADD_FILTER( fname          IN VARCHAR2,
                        fattribute     IN VARCHAR2,
                        fvalue         IN NUMBER);

  -- ***********************************************************
  -- DELETE_FILTER
  --   Deletes the filter with the given name.
  --
  --    The function will take as input the following parameters:
  --        fname      - Name of the filter that should be deleted.
  --                     (MANDATORY)
  --
  -- ***********************************************************
  PROCEDURE DELETE_FILTER( fname       IN VARCHAR2);

  -- ***********************************************************
  -- EXPORT_AWR/EXPORT_PERFORMANCE_DATA
  --   Exports the AWR snapshots associated with a given
  --   capture_id as well as the SQL set that may have been 
  --   captured along with the workload.
  --
  --   NOTE: This procedure will work only if the corresponding
  --         workload capture was performed in the current database
  --         (meaning that the corresponding row in 
  --         DBA_WORKLOAD_CAPTURES was not created by calling
  --         DBMS_WORKLOAD_CAPTURE.GET_CAPTURE_INFO()) and the
  --         AWR snapshots that correspond to the original capture
  --         time period are still available.
  --
  --    The function will take as input the following parameters:
  --        capture_id  - ID of the capture whose AWR snapshots
  --                      should be exported.
  --                     (MANDATORY)
  --
  --                        DEFAULT VALUE: NULL
  -- EXPORT_PERFORMANCE_DATA and EXPORT_AWR are equivalent
  -- ***********************************************************
  PROCEDURE EXPORT_AWR( capture_id              IN NUMBER);
  PROCEDURE EXPORT_PERFORMANCE_DATA( capture_id IN NUMBER);

  -- ***********************************************************
  -- IMPORT_AWR/IMPORT_PERFORMANCE_DATA
  --   Imports the AWR snapshots from a given capture, provided
  --   those AWR snapshots were exported earlier from the original
  --   capture system using DBMS_WORKLOAD_CAPTURE.EXPORT_AWR(). 
  --   If a sql tuning set was captured along with the workload and
  --   was successfully exported it will be imported also. The name
  --   and owner of the sql tuning sets can be obtained form the 
  --   DBA_WORKLOAD_CAPTURES view.
  --
  --   In order to avoid DBID conflicts, this function will generate
  --   a random DBID and use that DBID to populate the SYS AWR schema.
  --   The value used for DBID can be found in 
  --   DBA_WORKLOAD_CAPTURES.AWR_DBID.
  --
  --    The function will take as input the following parameters:
  --      capture_id      - ID of the capture whose AWR snapshots
  --                        should be imported.
  --                        (MANDATORY)
  --      staging_schema  - Name of a valid schema in the current database
  --                        which can be used as a staging area 
  --                        while importing the AWR snapshots 
  --                        from the capture directory to the SYS AWR schema.
  --                        The 'SYS' schema cannot be used as a staging
  --                        schema and is not a valid input.
  --                        (MANDATORY)
  --      force_cleanup   - TRUE => any AWR data present in the given
  --                        staging_schema will be removed before
  --                        the actual import operation. All tables
  --                        with names that match any of the tables in AWR
  --                        will be dropped before the actual import.
  --                        This will typically be equivalent to
  --                        dropping all tables returned by the 
  --                        following SQL:
  --                          SELECT table_name FROM dba_tables
  --                          WHERE  owner = staging_schema
  --                            AND  table_name like 'WR_$%';
  --                        Use this option only if you are sure that there
  --                        are no important data in any such tables in the 
  --                        staging_schema.
  --                        FALSE => no tables will be dropped from
  --                        the staging_schema prior to the import operation.
  --                        DEFAULT VALUE: FALSE
  --
  --    NOTE: IMPORT_AWR will fail if the given staging_schema contains
  --    any tables with a name that match any of the tables in AWR.
  --
  --    Returns the new randomly generated dbid that was used to
  --    import the AWR snapshots. The same value can be found in
  --    the AWR_DBID column in the DBA_WORKLOAD_CAPTURES view.
  --
  -- ***********************************************************
  FUNCTION IMPORT_AWR( capture_id      IN NUMBER,
                       staging_schema  IN VARCHAR2,
                       force_cleanup   IN BOOLEAN DEFAULT FALSE )
  RETURN NUMBER;
  FUNCTION IMPORT_PERFORMANCE_DATA( 
                       capture_id      IN NUMBER,
                       staging_schema  IN VARCHAR2,
                       force_cleanup   IN BOOLEAN DEFAULT FALSE )
  RETURN NUMBER;

  -- ***********************************************************
  -- END OF PUBLIC FUNCTIONS
  -- ***********************************************************


  -- ***********************************************************
  -- BEGIN PRIVATE FUNCTIONS and CONSTANTS
  --  The following functions are not supported and
  --  will not be documented.
  --  The usage of the following functions is strictly 
  --  prohibited and their use will cause unpredictable behaviour 
  --  in the RDBMS server.
  -- ***********************************************************

  -- ***********************************************************
  -- PRIVATE FUNCTIONS: USED INTERNALLY (not supported)
  --   No documentation required!
  -- ***********************************************************

  /* Type used by user_calls_graph */
  TYPE uc_graph_record IS RECORD(time NUMBER, user_calls NUMBER, flags NUMBER);
  TYPE uc_graph_table  IS TABLE OF uc_graph_record;

  PROCEDURE export_uc_graph(capture_id NUMBER);
  PROCEDURE import_uc_graph(capture_id NUMBER);
  FUNCTION user_calls_graph(capture_id IN NUMBER)
    RETURN uc_graph_table PIPELINED;


  -- ***********************************************************
  --  GET_CAPTURE_PATH
  --    return the full path to the directory 
  --
  --    The function will take as input the following parameters:
  --      capture_id  - ID of the workload capture 
  --                    (MANDATORY)
  -- ***********************************************************
  FUNCTION get_capture_path(capture_id IN NUMBER)
  RETURN VARCHAR2;

  -- ************************************************************
  -- get_perf_data_export_status
  --   populates awr_data and sts_data with the filenames of the 
  --   exported performance data. If no data exists, NULL is set
  --   to the appropriate output variable
  -- ************************************************************
  PROCEDURE get_perf_data_export_status( capture_id     IN  NUMBER,
                                         awr_data      OUT  VARCHAR2,
                                         sts_data      OUT  VARCHAR2);

END DBMS_WORKLOAD_CAPTURE;
/

show errors;


CREATE OR REPLACE PUBLIC SYNONYM dbms_workload_capture
FOR sys.dbms_workload_capture
/

GRANT EXECUTE ON dbms_workload_capture TO execute_catalog_role, dba
/

CREATE OR REPLACE PACKAGE dbms_workload_replay AS

  -- ***********************************************************
  --  PROCESS_CAPTURE
  --    Processes the workload capture found in capture_dir in place.
  --
  --    Analyzes the workload capture found in the capture_dir and 
  --    creates new workload replay specific metadata files that are
  --    required to replay the given workload capture.
  --    This procedure can be run multiple times on the same
  --    capture directory - useful when this procedure encounters 
  --    unexpected errors or is cancelled by the user.
  --    
  --    Once this procedure runs successfully, the capture_dir can be used
  --    as input to INITIALIZE_REPLAY() in order to replay the captured 
  --    workload present in capture_dir.
  --
  --    Before a workload capture can be replayed in a particular database
  --    version, the capture needs to be "processed" using this
  --    PROCESS_CAPTURE procedure in that same database version.
  --    Once created, a processed workload capture can be used to replay
  --    the captured workload multiple times in the same database version.
  --    
  --    For example:
  --      Say workload "foo" was captured in "rec_dir" in Oracle
  --      database version 10.2.0.4
  --      
  --      In order to replay the workload "foo" in version 11.1.0.1
  --      the workload needs to be processed in version 11.1.0.1
  --      The following procedure needs to be executed in a 11.1.0.1 database
  --      in order to process the capture directory "rec_dir"
  --    
  --        DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE('rec_dir');
  --    
  --      Now, rec_dir contains a valid 11.1.0.1 processed workload capture
  --      that can be used to replay the workload "foo" in 11.1.0.1 databases
  --      as many number of times as required.
  --
  --    The procedure will take as input the following parameters:
  --      capture_dir - name of the workload capture directory object.
  --                    (case sensitive)
  --                    The directory object must point to a valid OS
  --                    directory that has appropriate permissions. 
  --                    New files will be added to this directory.
  --                    (MANDATORY)
  --      parallel_level - number of oracle processes used to process the 
  --                       capture in a parallel fashion.
  --                       The NULL default value will auto-compute the 
  --                       parallelism level, whereas a value of 1 will enforce
  --                       serial execution.
  -- ***********************************************************
  PROCEDURE PROCESS_CAPTURE( capture_dir        IN VARCHAR2,
                             parallel_level     IN NUMBER DEFAULT NULL);

  -- ********************************************************************
  --  PROCESS_CAPTURE_COMPLETION
  --    While a process_capture is running on the Database, this function
  --    will return the percentage of the capture files that have already
  --    been processed. That value is updated every minute or so.
  -- ********************************************************************
  FUNCTION PROCESS_CAPTURE_COMPLETION
  RETURN NUMBER;

  -- ********************************************************************
  --  PROCESS_CAPTURE_REMAINING_TIME
  --    While a process_capture is running on the Database, this function
  --    will return an estimate of the time remaining (in minutes) before 
  --    processing is done.
  --
  --    We cannot get a correct estimate before the first minute of 
  --    processing has passed. In that case, this function will return 
  --    NULL.
  --    This will also return NULL if no processing is in progress.
  -- ********************************************************************
  FUNCTION PROCESS_CAPTURE_REMAINING_TIME
  RETURN NUMBER;

  -- ***********************************************************
  --  INITIALIZE_REPLAY
  --    Puts the DB state in INIT for REPLAY mode. The input replay_dir
  --    should point to a valid capture directory processed by
  --    DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE().
  --
  --    Loads data into the replay system that is required before preparing
  --    for the replay (i.e. calling PREPARE_REPLAY). Such data are:
  --    1) Connection data
  --       During capture we record the connection string each session
  --       used to connect to the server. INITIALIZE_REPLAY loads this
  --       data and allows the user to re-map the recorded connection 
  --       string to new connection strings or service points.
  --    
  --    EXAMPLE
  --      Continuing with the example from PROCESS_CAPTURE, one
  --      would invoke the following:
  --
  --        DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY('replay foo #1', 'rec_dir');
  --  
  --      This command will load up the connection map and by default
  --      will set all replay time connection strings to be equal to 
  --      NULL. A NULL replay time connection string means that the workload
  --      replay client's (WRC's) will connect to the default host as
  --      determined by the replay client's runtime environment settings.
  --      The user can change a particular connection string to a new one 
  --      (or a new service point) for replay by using 
  --      DBMS_WORKLOAD_REPLAY.REMAP_CONNECTION
  --
  --    The procedure takes the following input parameter:
  --      replay_name - name of the workload replay.
  --                    Every replay of a processed workload capture
  --                    can be given a name.
  --                    (MANDATORY)
  --      replay_dir - name of the directory object that points to the
  --                   (case sensitive)
  --                   OS directory that contains processed capture
  --                   data
  --   
  --    Prerequisites:
  --      -> Workload capture was already processed using
  --         DBMS_WORKLOAD_REPLAY.PROCESS_CAPTURE in the same
  --         database version.
  --      -> Database state has been logically restored to 
  --         what it was at the beginning of the original workload capture.
  -- 
  -- ***********************************************************
  PROCEDURE INITIALIZE_REPLAY( replay_name     IN VARCHAR2,
                               replay_dir      IN VARCHAR2 );

  -- ***********************************************************
  -- SET_ADVANCED_PARAMETER
  --   Sets an advanced parameter for replay besides the ones used with
  --   PREPARE_REPLAY. The advanced parameters control aspects of the replay
  --   that are more specialized. The advanced parameters are reset to
  --   their default values after the replay has finished. 
  --   
  --   The current parameters and the values that can be used are:
  --
  --   'DO_NO_WAIT_COMMITS': (default: FALSE)
  --      This parameter controls whether the commits issued by replay
  --      sessions will be NOWAIT. The default value for this parameter is
  --      FALSE. In this case all the commits are issued with the mode they
  --      were captured (wait, no-wait, batch, no-batch). If the parameter is
  --      set to TRUE then all commits are issued in no-wait mode.  This is
  --      useful in cases where the replay is becoming noticably slow because
  --      of a high volume of concurrent commits. Setting the parameter to
  --      true will significantly decrease the waits on the 'log file sync'
  --      event during the replay with respect to capture.
  --
  --
  --   The procedures take the following parameters:
  --     pname  - The name of the parameter (case insensitive)
  --     pvalue - The value of the parameter
  --   
  --   Prerequisites:
  --     --> DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY must have been
  --         called.
  --     --> The database must not be in PREPARE mode
  --     --> No replay must be currently ongoing
  -- ***********************************************************
  PROCEDURE SET_ADVANCED_PARAMETER( pname  IN VARCHAR2, 
                                    pvalue IN VARCHAR2);
  PROCEDURE SET_ADVANCED_PARAMETER( pname  IN VARCHAR2,
                                    pvalue IN NUMBER);
  PROCEDURE SET_ADVANCED_PARAMETER( pname  IN VARCHAR2,
                                    pvalue IN BOOLEAN);

  -- ***********************************************************
  -- GET_ADVANCED_PARAMETER
  --   Gets the value of an advanced parameter(see SET_ADVANCED_PARAMETER).
  --   This can be called at anytime. This function returns the value
  --   of the parameters in VARCHAR2 regardless of the parameter type.
  --   For boolean parameters either 'TRUE' or 'FALSE' is returned.
  --
  --   The function takes the following parameters:
  --     pname  - The name of the parameter (case insensitive)
  --
  --   The function returns the value of the parameter in VARCHAR2.
  --
  --   Prerequisites:
  --     NONE
  -- ***********************************************************
  FUNCTION GET_ADVANCED_PARAMETER( pname IN VARCHAR2)
    RETURN VARCHAR2;

  -- ***********************************************************
  -- RESET_ADVANCED_PARAMETERS
  --   Resets all the advanced parameters to their default values.
  --
  --   The procedure does not accept any parameters 
  --   The procedure does not return any value
  -- ***********************************************************
  PROCEDURE RESET_ADVANCED_PARAMETERS;

  -- ***********************************************************
  -- SET_REPLAY_TIMEOUT
  --   Set up replay timeout action. The purpose is to abort user calls that 
  --   might make the replay much slower or even cause a replay hang. 
  --   Once a replay timeout action is enabled, a user call will exit with
  --   ORA-15569 if it has been delayed more than the condition specified by 
  --   the replay action. The call and its error will be reported as error 
  --   divergence.
  --   Here is how the replay timeout action works:
  --       1) The timeout action won't do anything if it is not enabled.
  --       2) If the call delay in minutes is less than a lower bound
  --          specified by parameter min_delay, the timeout action won't 
  --          do anything.
  --       3) If the delay in minutes is more than a upper bound specified by 
  --          parameter max_delay, the timeout action will abort the user call
  --          and throw ORA-15569.
  --       4) For delay that is between the lower bound and upper bound, the
  --          user call will abort with ORA-15569 only when the current
  --          replay elapsed time is more than the multiplication of capture
  --          elapsed time and parameter delay_factor.
  --   The parameters are reset to the default value after the replay has 
  --   finished.
  --   
  --   The procedure takes the following input parameters:
  --     enabled      - TRUE to enable the timeout action and FALSE to disable.
  --                    DEFAULT VALUE: TRUE.
  --     min_delay    - lower bound of call delay in minutes. The replay action
  --                    is activated only when the delay is more than min_delay.
  --                    DEFAULT VALUE: 10 minutes.
  --     max_delay    - upper bound of call delay in minutes. The timeout action
  --                    throws ORA-15569 when the delay is more than max_delay.
  --                    DEFAULT VALUE: 120 minutes.
  --     delay_factor - factor for the call delay that is between min_delay and
  --                    max_delay. The timeout action throws ORA-15569 when the
  --                    current replay elapsed time is more than the multiplication
  --                    of capture elapsed time and delay_factor.
  --                    DEFAULT VALUE: 8
  --   
  --   NOTE: Call delay is defined as the difference of call elapsed time
  --         between replay and capture if replay elapsed time is larger.
  --         SET_REPLAY_TIMEOUT can be called anytime during replay.
  -- 
  -- ***********************************************************
  PROCEDURE SET_REPLAY_TIMEOUT(enabled       IN  BOOLEAN DEFAULT TRUE, 
                               min_delay     IN  NUMBER  DEFAULT 10,
                               max_delay     IN  NUMBER  DEFAULT 120,
                               delay_factor  IN  NUMBER  DEFAULT 8);

  -- ***********************************************************
  -- GET_REPLAY_TIMEOUT
  --   Get the replay timeout setting.
  --
  --   The procedure returns the following output parameters:
  --     enabled      - TRUE if the timeout action is enabled and FALSE otherwise.
  --     min_delay    - lower bound of call delay in minutes. The replay action
  --                    is activated only when the delay is equal or more than
  --                    min_delay.
  --     max_delay    - upper bound of call delay in minutes. The timeout action 
  --                    throw ORA-15569 when the delay is more than max_delay.
  --     delay_factor - the factor for the call delay that is between min_delay
  --                    and max_delay. The timeout action throws ORA-15569 when 
  --                    the current replay elapsed time is more than the 
  --                    multiplication of capture elapsed time and delay_factor.
  --   
  --   NOTE: GET_REPLAY_TIMEOUT can be called anytime during replay.
  --
  -- ***********************************************************
  PROCEDURE GET_REPLAY_TIMEOUT(enabled       OUT  BOOLEAN, 
                               min_delay     OUT  NUMBER,
                               max_delay     OUT  NUMBER,
                               delay_factor  OUT  NUMBER);

  -- ***********************************************************
  --  PREPARE_REPLAY
  --    Puts the DB state in PREPARE mode. The database
  --    should have been initialized for replay using
  --    DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY(), and optionally any 
  --    capture time connection strings that require remapping have been
  --    already done using DBMS_WORKLOAD_REPLAY.REMAP_CONNECTION().
  -- 
  --    One or more external replay clients (WRC) can be started
  --    once the PREPARE_REPLAY procedure has been executed.
  --    
  --    The procedure will take as input the following parameters:
  --      synchronization - Turns synchronization to the given scheme during
  --                        workload replay.
  --                        When synchronization is SCN, the COMMIT order
  --                        observed during the original workload capture
  --                        will be preserved during replay.
  --                        Every action that is replayed will be executed 
  --                        ONLY AFTER all of it's dependent COMMITs (all 
  --                        COMMITs that were issued before the given action 
  --                        in the original workload capture) have finished 
  --                        execution.
  --                        When synchronization is OBJECT_ID, a more advanced
  --                        synchronization scheme is used.
  --                        Every action that is replayed will be executed
  --                        ONLY AFTER the RELEVANT COMMITs have finished 
  --                        executing. The relevant commits are the ones that
  --                        were issued before the given action  in the
  --                        orginal workload capture and that had modified
  --                        at least one of the database objects the given
  --                        action is referencing (either implicitely or 
  --                        explicitely).
  --                        This OBJECT_ID scheme has the same logical 
  --                        property of making sure that any action will see
  --                        the same data it saw during capture, but will
  --                        allow more concurrency during replays for the 
  --                        actions that do not touch the same objects/tables.
  --                        DEFAULT VALUE: OBJECT_ID.
  --                        For legacy reason, there is a boolean version of
  --                        this procedure:
  --                          TRUE  means 'OBJECT_ID'
  --                          FALSE means 'OFF'
  --                       
  --      connect_time_scale       - Scales the time elapsed between the 
  --                                 instant the workload capture was started
  --                                 and session connects with the given value.
  --                                 The input is interpreted as a % value.
  --                                 Can potentially be used to increase or 
  --                                 decrease the number of concurrent
  --                                 users during the workload replay.
  --                                 DEFAULT VALUE: 100
  --                       
  --                                 For example, if the following was observed
  --                                 during the original workload capture:
  --                                 12:00 : Capture was started
  --                                 12:10 : First session connect  (10m after)
  --                                 12:30 : Second session connect (30m after)
  --                                 12:42 : Third session connect  (42m after)
  --                       
  --                                 If the connect_time_scale is 50, then the 
  --                                 session connects will happen as follows:
  --                                 12:00 : Replay was started 
  --                                         with 50% connect time scale
  --                                 12:05 : First session connect  ( 5m after)
  --                                 12:15 : Second session connect (15m after)
  --                                 12:21 : Third session connect  (21m after)
  --                       
  --                                 If the connect_time_scale is 200, then the
  --                                 session connects will happen as follows:
  --                                 12:00 : Replay was started     
  --                                         with 200% connect time scale
  --                                 12:20 : First session connect  (20m after)
  --                                 13:00 : Second session connect (60m after)
  --                                 13:24 : Third session connect  (84m after)
  --                       
  --      think_time_scale         - Scales the time elapsed between two
  --                                 successive user calls from the same 
  --                                 session.
  --                                 The input is interpreted as a % value.
  --                                 Can potentially be used to increase or 
  --                                 decrease the number of concurrent
  --                                 users during the workload replay.
  --                                 DEFAULT VALUE: 100
  --                       
  --                                 For example, if the following was observed
  --                                 during the original workload capture:
  --                                 12:00 : User SCOTT connects
  --                                 12:10 : First user call issued
  --                                         (10m after completion of prevcall)
  --                                 12:14 : First user call completes in 4mins
  --                                 12:30 : Second user call issued 
  --                                         (16m after completion of prevcall)
  --                                 12:40 : Second user call completes in 10m
  --                                 12:42 : Third user call issued 
  --                                         ( 2m after completion of prevcall)
  --                                 12:50 : Third user call completes in 8m
  --                       
  --                                 If the think_time_scale is 50 during the
  --                                 workload replay, then the user calls 
  --                                 will look something like below:
  --                                 12:00 : User SCOTT connects
  --                                 12:05 : First user call issued 5 mins
  --                                         (50% of 10m) after the completion 
  --                                         of prev call
  --                                 12:10 : First user call completes in 5m
  --                                         (takes a minute longer)
  --                                 12:18 : Second user call issued 8 mins
  --                                         (50% of 16m) after the completion
  --                                         of prev call
  --                                 12:25 : Second user call completes in 7m
  --                                         (takes 3 minutes less)
  --                                 12:26 : Third user call issued 1 min 
  --                                         (50% of 2m) after the completion
  --                                         of prev call
  --                                 12:35 : Third user call completes in 9m
  --                                         (takes a minute longer)
  -- 
  --      think_time_auto_correct  - Auto corrects the think time between calls
  --                                 appropriately when user calls takes longer
  --                                 time to complete during replay than
  --                                 how long the same user call took to
  --                                 complete during the original capture.
  --                                 DEFAULT VALUE: TRUE, reduce
  --                                 think time if replay goes slower 
  --                                 than capture.
  --                       
  --                                 For example, if the following was observed
  --                                 during the original workload capture:
  --                                 12:00 : User SCOTT connects
  --                                 12:10 : First user call issued
  --                                         (10m after completion of prevcall)
  --                                 12:14 : First user call completes in 4m
  --                                 12:30 : Second user call issued 
  --                                         (16m after completion of prevcall)
  --                                 12:40 : Second user call completes in 10m
  --                                 12:42 : Third user call issued 
  --                                         ( 2m after completion of prevcall)
  --                                 12:50 : Third user call completes in 8m
  --                       
  --                                 If the think_time_scale is 100 and
  --                                 the think_time_auto_correct is TRUE
  --                                 during the workload replay, then 
  --                                 the user calls will look something
  --                                 like below:
  --                                 12:00 : User SCOTT connects
  --                                 12:10 : First user call issued 10 mins
  --                                         after the completion of prev call
  --                                 12:15 : First user call completes in 5m
  --                                         (takes 1 minute longer)
  --                                 12:30 : Second user call issued 15 mins
  --                                         (16m minus the extra time of 1m
  --                                          the prev call took) after the 
  --                                         completion of prev call
  --                                 12:44 : Second user call completes in 14m
  --                                         (takes 4 minutes longer)
  --                                 12:44 : Third user call issued immediately
  --                                         (2m minus the extra time of 4m 
  --                                          the prev call took) after the
  --                                         completion of prev call
  --                                 12:52 : Third user call completes in 8m
  --      scale_up_multiplier      - Defines the number of times the query workload
  --                                 is scaled up during replay. Each captured session
  --                                 is replayed concurrently as many times as the 
  --                                 value of the scale_up_multiplier. However, only  
  --                                 one of the sessions in each set of identical
  --                                 replay sessions executes both queries and updates.
  --                                 The remaining sessions only execute queries.
  --
  --                                 More specifically note that:
  --                                   1. One replay session (base session) of each set 
  --                                      of identical sessions will replay every call
  --                                      from the capture as usual
  --                                   2. The remaining sessions (scale-up sessions) will
  --                                      only replay calls that are read-only.
  --                                      Thus, DDL, DML, and PLSQL calls that 
  --                                      modified the database will be 
  --                                      skipped. SELECT FOR UPDATE statements are also skipped.
  --                                   3. Read-only calls from the scale-up are
  --                                      synchronized appropriately and obey the
  --                                      timings defined by think_time_scale, connect_time_scale,
  --                                      and think_time_auto_correct. Also the queries
  --                                      are made to wait for the appropriate commits.
  --                                   4. No replay data or error divergence 
  --                                      records will be generated for the 
  --                                      scale-up sessions.
  --                                   5. All base or scale-up sessions that
  --                                      replay the same capture file will connect
  --                                      from the same workload replay client.
  --
  --          capture_sts - If this parameter is TRUE, a SQL tuning set
  --                        capture is also started in parallel with workload
  --                        capture. The resulting SQL tuning set can be
  --                        exported using DBMS_WORKLOAD_REPLAY.EXPORT_AWR
  --                        along with the AWR data. 
  --
  --                        Currently, parallel STS capture
  --                        is not supported in RAC. So, this parameter has
  --                        no effect in RAC. 
  --                     
  --                        Furthermore capture filters defined using the
  --                        dbms_workload_replay APIs do not apply to the
  --                        sql tuning set capture. 
  --
  --                        The calling user must have the approriate
  --                        privileges ('administer sql tuning set').
  --                  
  --                        DEFAULT VALUE: FALSE
  --
  --     sts_cap_interval - This parameter specifies the capture interval
  --                        of the SQL set capture from the cursor cache in
  --                        seconds. The default value is 300.
  --                  
  --
  --    Prerequisites:
  --      -> The database has been initialized for replay using
  --         DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY().
  --      -> Any capture time connections strings that require remapping
  --         during replay have already been remapped using
  --         DBMS_WORKLOAD_REPLAY.REMAP_CONNECTION().
  -- 
  -- ***********************************************************
  PROCEDURE  PREPARE_REPLAY(synchronization         IN BOOLEAN,
                            connect_time_scale      IN NUMBER   DEFAULT 100,
                            think_time_scale        IN NUMBER   DEFAULT 100,
                            think_time_auto_correct IN BOOLEAN  DEFAULT TRUE,
                            scale_up_multiplier     IN NUMBER   DEFAULT 1,
                            capture_sts             IN BOOLEAN  DEFAULT FALSE,
                            sts_cap_interval        IN NUMBER   DEFAULT 300);

  PROCEDURE  PREPARE_REPLAY(
                        synchronization         IN VARCHAR2 DEFAULT 'OBJECT_ID',
                        connect_time_scale      IN NUMBER   DEFAULT 100,
                        think_time_scale        IN NUMBER   DEFAULT 100,
                        think_time_auto_correct IN BOOLEAN  DEFAULT TRUE,
                        scale_up_multiplier     IN NUMBER   DEFAULT 1,
                        capture_sts             IN BOOLEAN  DEFAULT FALSE,
                        sts_cap_interval        IN NUMBER   DEFAULT 300);
                           
  -- ***********************************************************
  --  START_REPLAY
  --    Starts the workload replay. All the external replay clients (WRC)
  --    that are currently connected to the replay database will
  --    automatically be notified and those replay clients (WRC) will
  --    begin issuing the captured workload.
  --    
  --    NOTE: Once the START_REPLAY command has been executed,
  --          new replay clients will not be able to connect to
  --          the database and only clients that were started up
  --          before the START_REPLAY command was issued will be
  --          used to replay the captured workload.
  --    
  --    The procedure does not accept any input parameters.
  --
  --    If a SQL set capture was requested and the start of the SQL set
  --    capture failed, replay is cancelled. The reason is stored in
  --    DBA_WORKLOAD_REPLAYS.ERROR_MESSAGE.
  -- 
  --    Prerequisites:
  --      -> DBMS_WORKLOAD_REPLAY.PREPARE_REPLAY was already issued.
  --      -> Enough number of external replay clients (WRC)
  --         that can faithfully replay the captured workload
  --         have already been started. The status of such
  --         external replay clients can be monitored using
  --         V$WORKLOAD_REPLAY_CLIENTS.
  --         Use the WRC's CALIBRATE mode to determine the number of 
  --         replay clients that might be required to faithfully replay
  --         the captured workload.
  --           Example:
  --           $ wrc mode=calibrate replaydir=./capture
  -- 
  -- ***********************************************************
  PROCEDURE  START_REPLAY;

  -- ***********************************************************
  --  PAUSE_REPLAY
  --    Pauses the in-progress workload replay. All subsequent
  --    user calls from the replay clients will be stalled until
  --    either DBMS_WORKLOAD_REPLAY.RESUME_REPLAY is issued
  --    or the replay is cancelled.
  --
  --    Note: User calls that were already in-progress
  --          when PAUSE_REPLAY was issued will be allowed to run
  --          to completion. Only subsequent user calls, when issued,
  --          will be paused.
  --    
  --    The procedure does not accept any input parameters.
  -- 
  --    Prerequisites:
  --      -> DBMS_WORKLOAD_REPLAY.START_REPLAY was already issued.
  -- 
  -- ***********************************************************
  PROCEDURE  PAUSE_REPLAY;

  -- ***********************************************************
  --  RESUME_REPLAY
  --    Resumes a paused workload replay.
  --
  --    Prerequisites:
  --      -> DBMS_WORKLOAD_REPLAY.PAUSE_REPLAY was already issued.
  -- 
  -- ***********************************************************
  PROCEDURE  RESUME_REPLAY;

  -- ***********************************************************
  --  IS_REPLAY_PAUSED
  --    Returns whether the replay is currenty paused.
  --    It returns TRUE if and only if PAUSE_REPLAY has been called
  --    successfully and RESUME_REPLAY has not been called yet.
  --    
  --    The procedure does not accept any input parameters.
          -- 
  --    Prerequisites:
  --      -> DBMS_WORKLOAD_REPLAY.START_REPLAY was already issued.
  -- 
  -- ***********************************************************
  FUNCTION IS_REPLAY_PAUSED
  RETURN BOOLEAN;

  -- ***********************************************************
  --  CANCEL_REPLAY
  --    Cancels the workload replay in progress. 
  --    All the external replay clients (WRC) will automatically 
  --    be notified to stop issuing the captured workload and exit.
  --    
  --    The procedure will take as input the following parameters:
  --      error_msg     - an optional reason for cancelling the replay
  --                      can be passed which will be recorded
  --                      into DBA_WORKLOAD_REPLAYS.ERROR_MESSAGE
  --                      DEFAULT VALUE: NULL
  --
  --    Prerequisites:
  --      -> DBMS_WORKLOAD_REPLAY.INITIALIZE_REPLAY or PREPARE_REPLAY 
  --         or START_REPLAY was already issued.
  -- 
  -- ***********************************************************
  PROCEDURE  CANCEL_REPLAY(reason    IN VARCHAR2 DEFAULT NULL);

  -- ***********************************************************
  --  GET_REPLAY_INFO
  --    Looks into the given directory and retrieves information 
  --    about the workload capture and the history of all the 
  --    workload replay attempts.
  --
  --    Calls GET_CAPTURE_INFO to import a row into DBA_WORKLOAD_CAPTURES
  --    which will contain information about the capture.
  --    And then, imports a row for every replay attempt retrieved 
  --    from the given replay directory into DBA_WORKLOAD_REPLAYS. 
  --
  --    The procedure will not insert new rows to DBA_WORKLOAD_CAPTURES
  --    and DBA_WORKLOAD_REPLAYS if these views already contain rows
  --    describing the capture and replay history present in the given
  --    directory.
  --
  --    The procedure returns the CAPTURE_ID which can be associated
  --    with both DBA_WORKLOAD_CAPTURES.ID and
  --    DBA_WORKLOAD_REPLAYS.CAPTURE_ID to access the relevant information.
  --    
  --    The procedure will take as input the following parameters:
  --      dir         - name of the workload replay directory object 
  --                    (case sensitive)
  --                    (MANDATORY)
  --
  -- ***********************************************************
  FUNCTION GET_REPLAY_INFO(dir    IN VARCHAR2)
  RETURN NUMBER;

  -- ***********************************************************
  --  DELETE_REPLAY_INFO
  --    Deletes the rows in DBA_WORKLOAD_REPLAYS 
  --    that corresponds to the given workload replay id.
  --    
  --    The procedure will take as input the following parameters:
  --      replay_id  - ID of the workload replay that needs 
  --                    to be deleted.
  --                    Corresponds to DBA_WORKLOAD_REPLAYS.ID
  --                    (MANDATORY)
  --
  -- ***********************************************************
  PROCEDURE DELETE_REPLAY_INFO(replay_id    IN NUMBER);

  -- ***********************************************************
  --  REMAP_CONNECTION
  --    Remap the captured connection to a new one so that the 
  --    user sessions can connect to the database in a desired 
  --    way during workload replay.
  --
  --    By default, all replay_connections will be equal to NULL.
  --    When the replay_connection is NULL (default), then the
  --    replay sessions will connect to the default host as 
  --    determined by the replay client's runtime environment.
  --    So, if no capture time connect strings are remapped, then
  --    all the replay sessions will simply connect to the default host
  --    to replay the workload.
  --
  --    A valid replay_connection should specify a connect identifier or 
  --    a service point. Please refer to the Oracle Database 
  --    Net Services Admin guide for various ways using which one
  --    can specify connect identifiers (such as net service names,
  --    database service names, and net service aliases) and various
  --    naming methods that can be used to resolve a connect identifier
  --    to a connect descriptor.
  --    
  --    An error is returned if no row matches the given 
  --    connection_id.
  --    
  --    The procedure will take as input the following parameters:
  --      connection_id       - ID of the connection to be remapped.
  --                            Corresponds to 
  --                            DBA_WORKLOAD_CONNECTION_MAP.CONN_ID
  --      replay_connection   - new connection string to be used during replay.
  --
  --    NOTE:
  --      Use the DBA_WORKLOAD_CONNECTION_MAP view to review all the 
  --      connection strings that will be used by the subsequent workload
  --      replay, and also to look at connection string remappings
  --      used for previous workload replays.
  --
  -- ***********************************************************
  PROCEDURE REMAP_CONNECTION(connection_id         IN  NUMBER,
                             replay_connection     IN  VARCHAR2);

  /***********************************************************************
   * REMAP_CONNECTION
   *   This procedure remaps the recorded connection to a new one for a
   *   given capture in a multiple-capture replay 
   *
   *   The first parameter schedule_cap_id specifies capture in the replay
   *   schedule. It maps the connection in that capture.
   *
   * Arguments:
   *   schedule_cap_id    - (IN) pointing to a capture in the schedule.
   *                             It's the ID returned by ADD_CAPTURE
   *                             (MANDATORY)
   *   connection_id      - (IN) ID of the connection to be remapped
   *                             (MANDATORY)
   *   replay_connection  - (IN) new connection string to be used
   *                             (MANDATORY)
   *
   ************************************************************************/
  PROCEDURE REMAP_CONNECTION(schedule_cap_id       IN  NUMBER,
                             connection_id         IN  NUMBER,
                             replay_connection     IN  VARCHAR2);

  /************************************************************************
   * SET_USER_MAPPING
   *  This procedure sets a new schema/user name to be used during replay
   *  instead of the captured user.
   *
   * Arguments:
   *   schedule_cap_id    - (IN) the id of the a capture in the scedule.
   *   caputre_user       - (IN) the user name during the time of the
   *                             workload capture
   *   replay_user        - (IN) the user name to which captured user is
   *                             remapped during replay
   * Notes: - a schdule_cap_id of NULL is used for regular non-consolidated
   *          replay.
   *        - The replay must be initialized but not prepared in order 
   *          to use this API
   *        - if replay_user is set to NULL the mapping is disabled
   *        - after multiple calls with the same capture_user, the last
   *          call always takes effect
   *        - to list all the mappings that will be in effect during
   *          the subsequent replay execute the following: 
   *             select * from dba_workload_active_user_map
   *        - the overloaded version without the schedule_cap_id calls
   *          the one with the schedule_cap_id argument by passing in NULL
   *        - mappings are stored in a table made public through the view
   *          dba_workload_user_map. To remove old mappings execute
   *          delete * from dba_workload_user_map.
   ***********************************************************************/
  PROCEDURE SET_USER_MAPPING(schedule_cap_id      IN NUMBER,
                             capture_user         IN VARCHAR2,
                             replay_user          IN VARCHAR2);
  PROCEDURE SET_USER_MAPPING(capture_user         IN VARCHAR2,
                             replay_user          IN VARCHAR2);
   

  -- ***********************************************************
  --  REPORT
  --    Generates a report on the given workload replay.
  --
  --    The function will take as input the following parameters:
  --      replay_id       - ID of the workload replay whose report
  --                        is requested.
  --                        (MANDATORY)
  --      format          - Specifies the report format 
  --                        Valid values are 
  --                        DBMS_WORKLOAD_REPLAY.TYPE_TEXT,
  --                        DBMS_WORKLOAD_REPLAY.TYPE_HTML,
  --             (internal) DBMS_WORKLOAD_REPLAY.TYPE_XML and
  --             (internal) DBMS_WORKLOAD_REPLAY.TYPE_XML_CC 
  --                        (MANDATORY)
  -- ***********************************************************

  --
  -- report type (possible values) constants  
  --
  TYPE_XML            CONSTANT   VARCHAR2(3) := 'XML'        ;
  TYPE_HTML           CONSTANT   VARCHAR2(4) := 'HTML'       ;
  TYPE_TEXT           CONSTANT   VARCHAR2(4) := 'TEXT'       ; 
  TYPE_XML_CC         CONSTANT   VARCHAR2(6) := 'XML_CC'     ;

  FUNCTION  REPORT( replay_id        IN NUMBER,
                    format           IN VARCHAR2 )
  RETURN    CLOB;

  -- ***********************************************************
  --  COMPARE_PERIOD_REPORT
  --    Generates a report comparing a replay to its capture or
  --    to another replay of the same capture. 
  --
  --    The function will take as input the following parameters:
  --      replay_id1      - First ID of the workload replay whose 
  --                        report is requested.
  --      replay_id2      - Second ID of the workload replay whose 
  --                        report is requested. If this is NULL,
  --                        the comparison is done with the capture.
  --      format          - Specifies the report format
  --                        Valid values are
  --                        DBMS_WORKLOAD_CAPTURE.TYPE_HTML and
  --                        DBMS_WORKLOAD_CAPTURE.TYPE_XML.
  --      result          - output of the report (CLOB).
  --    Note, this procedure commits while running ADDM, so it
  --    can not be used as a function inside a SELECT
  -- ***********************************************************
  PROCEDURE COMPARE_PERIOD_REPORT( replay_id1 IN NUMBER,
                                   replay_id2 IN NUMBER,
                                   format     IN VARCHAR2,
                                   result     OUT CLOB );
  
  -- ***********************************************************
  --  COMPARE_SQLSET_REPORT
  --
  --    Generates a report comparing a sqlset captured during replay
  --    replay to one captured during workload capture or to one 
  --    captured during another replay of the same capture. 
  --
  --    The function will take as input the following parameters:
  --      replay_id1      - First ID of the workload replay after
  --                        a change.
  --      replay_id2      - Second ID of the workload replay before
  --                        a change. If this is NULL, the comparison 
  --                        is done with the capture.
  --      format          - Specifies the report format
  --                        Valid values are
  --                        DBMS_WORKLOAD_CAPTURE.TYPE_HTML, 
  --                        DBMS_WORKLOAD_CAPTURE.TYPE_XML and
  --                        DBMS_WORKLOAD_CAPTURE.TYPE_TEXT
  --      r_level         - see level parameter in
  --                        dbms_sqltune.report_analysis_task
  --      r_sections      - see section parameter in 
  --                        dbms_sqltune.report_analysis_task
  --      result          - output of the report (CLOB).
  --
  --     RETURNS: the SPA task name for use later to retrieve the cached
  --              report.
  --
  --    If no sqlset was captured the procedure returns NULL in the
  --    result output variable. To enable sqlset capture during
  --    workload capture and replay see DBMS_WORKLOAD_CAPTURE.START_CAPTURE
  --    and DBMS_WORKLOAD_REPLAY.START_REPLAY.
  -- ***********************************************************
  FUNCTION COMPARE_SQLSET_REPORT( replay_id1    IN NUMBER,
                                  replay_id2    IN NUMBER,
                                  format        IN VARCHAR2,
                                  r_level       IN VARCHAR2 := 'ALL',
                                  r_sections    IN VARCHAR2 := 'ALL',
                                  result        OUT CLOB )
  RETURN VARCHAR2;
  

  -- ***********************************************************
  -- EXPORT_AWR / EXPORT_PERFORMANCE_DATA
  --   Exports the AWR snapshots associated with a given
  --   replay_id as well as any SQL Tuning sets captured along
  --   with the replay.
  --
  --   At the end of each replay, the corresponding AWR snapshots
  --   are automatically exported. So, there is no need to do this
  --   manually after a workload replay is complete, unless the 
  --   automatic EXPORT_AWR() invocation failed.
  --
  --   NOTE: This procedure will work only if the corresponding
  --         workload replay was performed in the current database
  --         (meaning that the corresponding row in 
  --         DBA_WORKLOAD_REPLAYS was not created by calling
  --         DBMS_WORKLOAD_REPLAY.GET_REPLAY_INFO()) and the
  --         AWR snapshots that correspond to that replay
  --         time period are still available.
  --
  --    The function will take as input the following parameters:
  --      replay_id       - ID of the replay whose AWR snapshots
  --                        should be exported.
  --                        (MANDATORY)
  --
  --   EXPORT_PERFORMANCE_DATA and EXPORT_AWR are equivalent.
  -- ***********************************************************
  PROCEDURE EXPORT_AWR( replay_id             IN NUMBER );
  PROCEDURE EXPORT_PERFORMANCE_DATA( replay_id IN NUMBER); 

  -- ***********************************************************
  -- IMPORT_AWR/IMPORT_PERFORMANCE_DATA
  --   Imports the AWR snapshots from a given replay, provided
  --   those AWR snapshots were successfully exported earlier 
  --   from the original replay system.
  --
  --   If a sql tuning set was captured during the replay and
  --   was successfully exported it will be imported also. The name
  --   and owner of the sql tuning sets can be obtained form the 
  --   DBA_WORKLOAD_REPLAYS view.
  --
  --   In order to avoid DBID conflicts, this function will generate
  --   a random DBID and use that DBID to populate the SYS AWR schema.
  --
  --    The function will take as input the following parameters:
  --      replay_id  - ID of the replay whose AWR snapshots
  --                    should be imported.
  --                    (MANDATORY)
  --      staging_schema  - Name of a valid schema in the current database
  --                        which can be used as a staging area 
  --                        while importing the AWR snapshots 
  --                        from the replay directory to the SYS AWR schema.
  --                        The 'SYS' schema cannot be used as a staging
  --                        schema and is not a valid input.
  --                        (MANDATORY)
  --      force_cleanup   - TRUE => any AWR data present in the given
  --                        staging_schema will be removed before
  --                        the actual import operation. All tables
  --                        with names that match any of the tables in AWR
  --                        will be dropped before the actual import.
  --                        This will typically be equivalent to
  --                        dropping all tables returned by the 
  --                        following SQL:
  --                          SELECT table_name FROM dba_tables
  --                          WHERE  owner = staging_schema
  --                            AND  table_name like 'WR_$%';
  --                        Use this option only if you are sure that there
  --                        are no important data in any such tables in the 
  --                        staging_schema.
  --                        FALSE => no tables will be dropped from
  --                        the staging_schema prior to the import operation.
  --                        DEFAULT VALUE: FALSE
  --
  --    NOTE: IMPORT_AWR will fail if the given staging_schema contains
  --    any tables with a name that match any of the tables in AWR.
  --
  --    Returns the new randomly generated dbid that was used to
  --    import the AWR snapshots. The same value can be found in
  --    the AWR_DBID column in the DBA_WORKLOAD_REPLAYS view.
  --
  -- ***********************************************************
  FUNCTION IMPORT_AWR( replay_id       IN NUMBER,
                       staging_schema  IN VARCHAR2,
                       force_cleanup   IN BOOLEAN DEFAULT FALSE )
  RETURN NUMBER;
  FUNCTION IMPORT_PERFORMANCE_DATA( 
                       replay_id       IN NUMBER,
                       staging_schema  IN VARCHAR2,
                       force_cleanup   IN BOOLEAN DEFAULT FALSE )
  RETURN NUMBER;

  -- ***********************************************************
  -- CALIBRATE
  --   Compute the estimated number of replay clients and cpu 
  --   needed to replay a given workload.
  --
  --   The procedure will take as input the following parameters:
  --     capture_dir - name of the directory object that points to the
  --                   (case sensitive)
  --                   OS directory that contains processed capture
  --                   data
  --     process_per_cpu - Maximum number of process allowed per CPU 
  --                       (default is 4)
  --     threads_per_process - Maximum number of threads allowed per
  --                           process (default is 50)
  --
  --   Returns a CLOB formatted as XML, that contains:
  --    o capture information,
  --    o current database version,
  --    o the input to this function, 
  --    o the number of cpus and replay clients  needed to replay the
  --      given workload, 
  --    o some information about the sessions captured 
  --      (total number and maximum concurrency).
  --   
  -- ***********************************************************
  FUNCTION CALIBRATE (capture_dir          IN VARCHAR2,
                      process_per_cpu      IN BINARY_INTEGER DEFAULT 4,
                      threads_per_process  IN BINARY_INTEGER DEFAULT 50)
  RETURN CLOB;

  -- ***********************************************************
  -- GET_CAPTURED_TABLES
  --   Extract from the capture files the list of Database objects that
  --   have been accessed by the captured workload on the capture system.
  --
  --   The procedure will take as input the following parameters:
  --     capture_dir - name of the directory object that points to the
  --                   (case sensitive)
  --                   OS directory that contains processed capture
  --                   data
  --
  --   Returns a CLOB formatted as XML, that contains:
  --    o capture information,
  --    o current database version,
  --    o the list of Database objects that have been accessed by the 
  --      captured workload on the capture system.
  -- 
  --   NOTES
  --    o This function needs to be run on a system with an identical 
  --      schema definition as the capture system. The data contained
  --      in the schema is irrelevant.
  --    o This function will NOT extract the objects accessed by PL/SQL
  --      blocks, functions or procedures.
  --   
  -- ***********************************************************
  FUNCTION GET_CAPTURED_TABLES(capture_dir IN VARCHAR2)
  RETURN CLOB;


  -- ***********************************************************
  -- GET_DIVERGING_STATEMENT
  --   Get some information on a diverging call, inluding the statement 
  --   text, the SQL id and the binds.
  --
  --   The procedure will take as input the following parameters:
  --     replay_id - id of the replay in which that call diverged
  --     stream_id - stream_id of the diverging call
  --     call_counter - call_counter of the diverging call
  -- 
  --   You can get all these information about the diverging call from 
  --   dba_workload_replay_divergence
  --
  --   Returns a CLOB formatted as XML, that contains:
  --    o SQL ID
  --    o SQL Text
  --    o Bind information: position, name and value
  --   
  -- ***********************************************************
  FUNCTION GET_DIVERGING_STATEMENT(replay_id    IN NUMBER,
                                   stream_id    IN NUMBER,
                                   call_counter IN NUMBER)
  RETURN CLOB;

  -- ***********************************************************
  -- POPULATE_DIVERGENCE
  --   Precompute the divergence information for the given call,
  --   stream or the whole replay, so that GET_DIVERGING_STATEMENT
  --   returns almost instantly for the precomputed calls.
  --
  --   The procedure will take as input the following parameters:
  --     replay_id   - id of the replay
  --     stream_id   - stream_id of the diverging call
  --                   If NULL is provided, divergence information will
  --                   be precomputed for all diverging calls in the given 
  --                   replay
  --     call_counter - call_counter of the diverging call
  --                    If NULL is provided, divergence information will
  --                    be precomputed for all diverging calls in the given
  --                    stream
  -- 
  -- ***********************************************************
  PROCEDURE POPULATE_DIVERGENCE(replay_id    IN NUMBER,
                                stream_id    IN NUMBER  DEFAULT NULL,
                                call_counter IN NUMBER  DEFAULT NULL);

  /**************************************************************************
   * POPULATE_DIVERGENCE_STATUS
   *
   *   Status of the divergence detailed information for the given replay
   *     - LOADED: all statement divergence information for this replay is 
   *               loaded
   *     - LOADING: the RDBMS is currently undertaking a bulk load of all of 
   *                the statement divergence data for the given replay
   *     - NOT LOADED: neither of the above, i.e., not LOADING and at least 
   *                   1 statement's divergence data has not been loaded
   **************************************************************************/
  FUNCTION POPULATE_DIVERGENCE_STATUS(replay_id    IN NUMBER)
  RETURN VARCHAR2;

  /**************************************************************************
   * DIVERGING_STATEMENT_STATUS
   *
   *   For a single diverging call in a given replay, has its detailed 
   *   divergence information be loaded.
   *   The possible results are:
   *     - LOADED (statement divergence data for this statement is loaded)
   *     - NOT LOADED (statement divergence data is not loaded yet)
   **************************************************************************/
  FUNCTION DIVERGING_STATEMENT_STATUS(replay_id    IN NUMBER,
                                      stream_id    IN NUMBER,
                                      call_counter IN NUMBER)
  RETURN VARCHAR2;

  -- ***********************************************************
  -- ADD_FILTER
  --   Adds a filter to replay only a subset of the captured workload. 
  --
  --   The ADD_FILTER() API adds a new filter that will
  --   be used in the next replay filter set that will be created using
  --   CREATE_FILTER_SET().
  --   This filter will be considered an "INCLUSION" or "EXCLUSION" filter
  --   based on the argument passed to CREATE_FILTER_SET() when creating
  --   the filter set.
  -- 
  --   *****************************
  --   SCOPE of the filter specified
  --   *****************************
  --   Filters once specified are valid only for the next succesful
  --   call to CREATE_FILTER_SET().
  --   After that, they will be part of the newly created set that can be
  --   used for any replay by calling USE_FILTER_SET().
  --   Filters used for past replays via a filter set can be queried from 
  --   the DBA_WORKLOAD_FILTERS view.
  --
  --    The function will take as input the following parameters:
  --        fname      - Name of the filter. Can be used to delete
  --                     the filter later if it is not required.
  --                     (MANDATORY)
  --        fattribute - Specifies the attribute on which the filter is 
  --                     defined. Should be one of the following values:
  --                     USER              - type STRING
  --                     MODULE            - type STRING
  --                     ACTION            - type STRING
  --                     PROGRAM           - type STRING
  --                     SERVICE           - type STRING
  --                     CONNECTION_STRING - type STRING
  --                     (MANDATORY)
  --        fvalue     - Specifies the value to which the given
  --                     'attribute' should be equal to for the
  --                     filter to be considered active.
  --                     Wildcards like '%' are acceptable for all
  --                     attributes that are of type STRING.
  --                     (MANDATORY)
  --    
  --   In other words, the filter for a NUMBER attribute will be 
  --   equated as:
  --     "attribute = value"
  --   And, the filter for a STRING attribute will be equated as:
  --     "attribute like value"
  -- 
  --   Also, please note that the PROGRAM and SERVICE filters are just
  --   looking at the captured connection string that is used during replay,
  --   There are equivalent to:
  --        CONNECTION_STRING LIKE '%(PROGRAM=fvalue)%
  --     or CONNECTION_STRING LIKE '%(SERVICE=fvalue)%
  -- 
  -- ***********************************************************
  PROCEDURE ADD_FILTER( fname          IN VARCHAR2,
                        fattribute     IN VARCHAR2,
                        fvalue         IN VARCHAR2);
  PROCEDURE ADD_FILTER( fname          IN VARCHAR2,
                        fattribute     IN VARCHAR2,
                        fvalue         IN NUMBER);

  -- ***********************************************************
  -- DELETE_FILTER
  --   Deletes the filter with the given name.
  --
  --    The function will take as input the following parameters:
  --        fname      - Name of the filter that should be deleted.
  --                     (MANDATORY)
  --
  -- ***********************************************************
  PROCEDURE DELETE_FILTER( fname       IN VARCHAR2);

  -- ***********************************************************
  -- REUSE_REPLAY_FILTER_SET
  --   Reuse filters in the specified filter set as if each of them
  --   were added using add_filter(). More than one filter sets can be added
  --   through this procedure. Also, new filter rule can be added, existing
  --   filter can be deleted before invoking create_filter_set() to 
  --   create new filter set.
  --
  --    The function takes as input the following parameters:
  --        replay_dir - Capture id the existing filter set associated to
  --        filter_set - name of the filter set to be reused
  --
  -- ***********************************************************
  PROCEDURE REUSE_REPLAY_FILTER_SET(replay_dir  IN VARCHAR2,
                                    filter_set  IN VARCHAR2);


  -- ***********************************************************
  -- CREATE_FILTER_SET
  --   Uses all the replay filters that have been added (since the previous
  --   succesful call to CREATE_FILTER_SET) to create a set of filters to 
  --   use against the replay in 'replay_dir'. 
  --   This operation needs to be done when no replay is initialized,
  --   prepared or in progress.
  --   After that procedure completed successfully and the filter set has 
  --   created, it can be used to filter the replay in 'replay_dir' by calling
  --   USE_FILTER_SET() after the replay has been initialized.
  --
  --   The procedure will take as input the following parameters:
  --     replay_dir     - object directory of the replay to be filtered
  --     filter_set     - name of the filter set to create 
  --                      (to use in USE_FILTER_SE)
  --     default_action - Can be either 'INCLUDE' or 'EXCLUDE'.
  --                      Determines whether, by default, every captured call
  --                      should be replayed or not. Also determines,
  --                      whether the workload filters specified
  --                      should be considered as INCLUSION filters or
  --                      EXCLUSION filters.
  --
  --                      If it is 'INCLUDE' then by default all captured calls
  --                      will be replayed, except for the part of the 
  --                      workload defined by the filters. 
  --                      In this case, all the filters that were
  --                      specified using the ADD_FILTER() API
  --                      will be treated as EXCLUSION filters, and will
  --                      determine the workload that WILL NOT BE replayed.
  --
  --                      If it is 'EXCLUDE' then by default no captured
  --                      call to the database will be replayed, except
  --                      for the part of the workload defined by the 
  --                      filters. In this case, all the filters that were
  --                      specified using the ADD_FILTER() API
  --                      will be treated as INCLUSION filters, and will
  --                      determine the workload that WILL BE replayed.
  --
  --                      DEFAULT VALUE: 'INCLUDE' and all the filters
  --                      specified will be assumed to be EXCLUSION filters.
  --   
  -- ***********************************************************
  PROCEDURE CREATE_FILTER_SET(replay_dir     IN VARCHAR2,
                              filter_set     IN VARCHAR2,
                              default_action IN VARCHAR2 DEFAULT 'INCLUDE');

  -- ***********************************************************
  -- USE_FILTER_SET
  --   Uses the given filter set that has been created by calling
  --   CREATE_FILTER_SET() to filter the current replay.
  --   This procedure should be called after the replay has been initialized,
  --   and before it is prepared.
  --
  --   The procedure will take as input the following parameters:
  --     filter_set     - name of the filter set use in this replay 
  --   
  -- ***********************************************************
  PROCEDURE USE_FILTER_SET(filter_set     IN VARCHAR2);

  /***************************************************************************
   *  GENERATE_CAPTURE_SUBSET
   *   This procedure creates a new capture from an existing 
   *   workload capture. 
   *
   *  Auguments:
   *    input_capture_dir  - (IN)  name of directory object pointing to
   *                               an existing workload capture 
   *                               (MANDATORY)
   *    output_capture_dir - (IN)  directory object pointing to an empty
   *                               directory where the output workload
   *                               capture will be stored
   *                               (MANDATORY)
   *    new_capture_name   - (IN)  name of the new output capture
   *                               (MANDATORY)
   *    begin_time         - (IN)  begin time of a time range. It is the 
   *                               time offset in seconds from the start 
   *                               of the input workload capture
   *                               Default value is zero.
   *    begin_include_incomplete - (IN) include incomplete calls caused by
   *                               begin_time. Default value is TRUE.
   *    end_time           - (IN)  end time of a time range. It is the time 
   *                               offset in seconds from the start of the
   *                               input workload capture. Zero is a special
   *                               value indicating the end of the capture.
   *                               Default value is zero.
   *    end_include_incomplete - (IN) include incomplete calls caused by
   *                               end_time. Default value is FALSE
   *    parallel_level     - (IN)  number of Oracle processes used to generate 
   *                               the new capture in a parallel fashion.
   *                               Default value is 1
   ***************************************************************************/
  PROCEDURE GENERATE_CAPTURE_SUBSET(
                  input_capture_dir        IN VARCHAR2,
                  output_capture_dir       IN VARCHAR2,
                  new_capture_name         IN VARCHAR2,
                  begin_time               IN NUMBER  DEFAULT 0,
                  begin_include_incomplete IN BOOLEAN DEFAULT TRUE,
                  end_time                 IN NUMBER  DEFAULT 0,
                  end_include_incomplete   IN BOOLEAN DEFAULT FALSE,
                  parallel_level           IN NUMBER  DEFAULT 1);

  /***********************************************************************
   * SET_REPLAY_DIRECTORY
   *   A directory that contains one or more workload captures is set
   *   as a replay directory.
   *
   * Arguments:
   *   replay_dir   - (IN) directory object of directory pointing to an
   *                       OS directory that contains one or multiple
   *                       captures for a workload consolidation.
   *
   ***********************************************************************/
  PROCEDURE SET_REPLAY_DIRECTORY(replay_dir IN  VARCHAR2);

  /***************************************************************************
   * GET_REPLAY_DIRECTORY
   *   return a directory object name that is the current replay directory set 
   *     by SET_REPLAY_DIRECTORY;
   *   return NULL if no replay directory has been set
   ***************************************************************************/
  FUNCTION  GET_REPLAY_DIRECTORY RETURN   VARCHAR2;

  /***************************************************************************
   * BEGIN_REPLAY_SCHEDULE
   *   Initiate the creation of a reusable replay schedule.
   *
   * Arguments:
   * 	 replay_dir_obj - (IN) directory object pointing to the replay directory 
   *                         that contains all the capture directories 
   *                         involved in the schedule
   *   schedule_name  - (IN) identifier for this schedule
   ***************************************************************************/
  PROCEDURE BEGIN_REPLAY_SCHEDULE(schedule_name    IN VARCHAR2);

  /****************************************************************************
   * ADD_CAPTURE
   *   Add the given capture to the current schedule.
   *
   * Arguments:
   *   capture_dir         - (IN) directory object pointing to the workload
   *                              capture under the top-level replay directory
   *                              (MANDATORY)
   *   start_delay_secs    - (IN) when the replay of this capture is ready to 
   *                              start, this is the delay time in seconds that
   *                              the replay will wait before it starts
   *   stop_replay         - (IN) stop the whole replay after the replay of 
   *                              this capture runs into completion
   *   take_begin_snapshot - (IN) take an AWR snapshot when the replay of 
   *                              this capture starts
   *   take_end_snapshot   - (IN) take an AWR snapshot when the replay of 
   *                              this capture finishes
   *   query_only          - (IN) replay only the read-only queries of this
   *                              workload capture
   *
   * Returns:
   *   A unique ID that identifies this capture within this schedule.
   */
  FUNCTION ADD_CAPTURE(capture_dir_name      IN VARCHAR2,
                       start_delay_seconds   IN NUMBER  DEFAULT 0,
                       stop_replay           IN BOOLEAN DEFAULT FALSE,
                       take_begin_snapshot   IN BOOLEAN DEFAULT FALSE,
                       take_end_snapshot     IN BOOLEAN DEFAULT FALSE,
                       query_only            IN BOOLEAN DEFAULT FALSE)
    RETURN NUMBER;

  /******************************************************************
   * ADD_CAPTURE
   *   Allow to add a given capture to the current schedule.
   *   This function overloads the above one so that the ADD_CAPTURE 
   *   function can be used in a SELECT
   *
   * Arguments:
   *   capture_dir         - (IN) directory object pointing to the workload
   *                              capture under the top-level replay directory
   *                              (MANDATORY)
   *   start_delay_secs    - (IN) when the replay of this capture is ready to 
   *                              start, this is the delay time in seconds that
   *                              the replay will wait before it starts
   *                              (MANDATORY)
   *   stop_replay         - (IN) stop the whole replay after the replay of 
   *                              this capture runs into completion
   *                              (MANDATORY)
   *                              value 'Y' or 'N'
   *   take_begin_snapshot - (IN) take an AWR snapshot when the replay of 
   *                              this capture starts
   *                              (MANDATORY)
   *                              value 'Y' or 'N'
   *   take_end_snapshot   - (IN) take an AWR snapshot when the replay of 
   *                              this capture finishes
   *                              (MANDATORY)
   *                              value 'Y' or 'N'
   *   query_only          - (IN) replay only the read-only queries of this
   *                              workload capture
   *                              (MANDATORY)
   *                              value 'Y' or 'N'
   *
   * Returns:
   *   A unique ID that identifies this capture within this schedule.
   ******************************************************************/
  FUNCTION ADD_CAPTURE(capture_dir_name      IN VARCHAR2,
                       start_delay_seconds   IN NUMBER  ,
                       stop_replay           IN VARCHAR2,
                       take_begin_snapshot   IN VARCHAR2 DEFAULT 'N',
                       take_end_snapshot     IN VARCHAR2 DEFAULT 'N',
                       query_only            IN VARCHAR2 DEFAULT 'N')
    RETURN NUMBER;

  /****************************************************************************
   * REMOVE_CAPTURE
   *   Remove the given capture from the current schedule.
   *
   * Arguments:
   *   schedule_capture_id - (IN) unique ID that identifies this capture
   *                              within this schedule
   */
  PROCEDURE REMOVE_CAPTURE(schedule_capture_id IN NUMBER);

  /****************************************************************************
   * ADD_SCHEDULE_ORDERING
   *   Add a wait-for dependency between two captures in the replay schedule.
   *
   * Arguments:
   *   schedule_capture_id - (IN) unique ID pointing to a capture that has 
   *                              been added to the current replay schedule
   *   waitfor_capture_id  - (IN) pointing to a capture that has been added 
   *                              to the current replay schedule
   *                              NULL means it does not wait for any capture.
   */
   PROCEDURE ADD_SCHEDULE_ORDERING(
                    schedule_capture_id  IN NUMBER,
                    waitfor_capture_id   IN NUMBER);

  /****************************************************************************
   * REMOVE_SCHEDULE_ORDERING
   *   Remove a wait-for dependency from a replay schedule.
   *
   * Arguments:
   *   schedule_capture_id - (IN) unique ID pointing to a capture that has 
   *                              been added to the current replay schedule
   *   waitfor_capture_id  - (IN) pointing to a capture that has been added 
   *                              to the current replay schedule
   *                              NULL means it does not wait for any capture.
   */
   PROCEDURE REMOVE_SCHEDULE_ORDERING(
                    schedule_capture_id   IN NUMBER,
                    waitfor_capture_id    IN NUMBER);

  /****************************************************************************
   * END_REPLAY_SCHEDULE
   *   Wraps up the creation of the current schedule.
   *   The schedule is now saved and associated with the replay directory
   *   and can be used for a replay.
   */
  PROCEDURE END_REPLAY_SCHEDULE;

  /****************************************************************************
   * REMOVE_REPLAY_SCHEDULE
   *   This procedure removes an existing replay schedule. All the records 
   *   about its captures and the wait-for capture orders are also deleted. 
   *   The WMD file for replay schedule is modified accordingly.
   *
   * Arguments:
   *   schedule_name    - (IN) identifier for this schedule
   */
  PROCEDURE REMOVE_REPLAY_SCHEDULE(schedule_name  IN VARCHAR2);

  /**************************************************************************
   * INITIALIZE_CONSOLIDATED_REPLAY
   *   initialize_replay for workload consolidation
   *
   *  This procedure puts the DB state in INIT for a multiple-capture replay. 
   *  It uses the replay_dir which has already been defined by 
   *  SET_REPLAY_DIRECTORY, pointing to a directory that contains all the 
   *  capture directories involved in the schedule. It further read data 
   *  about schedule schedule_name from the directory. Similar to the
   *  initialize_replay, it loads connection data etc. into the replay system
   *  that is required before preparing the replay.
   *
   * Arguments:
   *   replay_name     - (IN) name of the workload replay. Every replay must
   *                          be given a name. 
   *                          (MANDATORY)
   *   schedule_name   - (IN) identifier for this replay schedule
   *                          (MANDATORY)
   *************************************************************************/
  PROCEDURE INITIALIZE_CONSOLIDATED_REPLAY(replay_name    IN  VARCHAR2,
                                           schedule_name  IN  VARCHAR2);

  -- ***********************************************************
  --  PREPARE_CONSOLIDATED_REPLAY
  --    Puts the DB state in PREPARE mode. This API is for
  --    a multiple-capture replay. The database should have been 
  --    initialized for replay using
  --    DBMS_WORKLOAD_REPLAY.INITIALIZE_CONSOLIDATED_REPLAY(), and 
  --    optionally any capture time connection strings that require 
  --    remapping have been already done using 
  --    DBMS_WORKLOAD_REPLAY.REMAP_CONNECTION().
  -- ***********************************************************
  PROCEDURE PREPARE_CONSOLIDATED_REPLAY(
                synchronization         IN BOOLEAN,
                connect_time_scale      IN NUMBER   DEFAULT 100,
                think_time_scale        IN NUMBER   DEFAULT 100,
                think_time_auto_correct IN BOOLEAN  DEFAULT TRUE,
                capture_sts             IN BOOLEAN  DEFAULT FALSE,
                sts_cap_interval        IN NUMBER   DEFAULT 300);

  PROCEDURE PREPARE_CONSOLIDATED_REPLAY(
                synchronization         IN VARCHAR2 DEFAULT 'OBJECT_ID',
                connect_time_scale      IN NUMBER   DEFAULT 100,
                think_time_scale        IN NUMBER   DEFAULT 100,
                think_time_auto_correct IN BOOLEAN  DEFAULT TRUE,
                capture_sts             IN BOOLEAN  DEFAULT FALSE,
                sts_cap_interval        IN NUMBER   DEFAULT 300);

  /********************************************
   * START_CONSOLIDATED_REPLAY
   *   start_replay for workload consolidation
   *
   * Prerequisites:
   *   . DBMS_WORKLOAD_REPLAY.PREPARE_CONSOLIDATED_REPLAY has been issued
   *   . Enough number of external replay clients (WRC) has been started
   *
   ********************************************/
  PROCEDURE START_CONSOLIDATED_REPLAY;

  -- ***********************************************************
  -- END OF PUBLIC FUNCTIONS
  -- ***********************************************************


  -- ***********************************************************
  -- BEGIN PRIVATE FUNCTIONS and CONSTANTS
  --  The following functions are not supported and
  --  will not be documented.
  --  The usage of the following functions is strictly 
  --  prohibited and their use will cause unpredictable behaviour 
  --  in the RDBMS server.
  -- ***********************************************************

  -- ***********************************************************
  -- PRIVATE FUNCTIONS: USED INTERNALLY (not supported)
  --   No documentation required!
  -- ***********************************************************

  --
  -- CONSTANTS for CLIENT_CONNECT 
  --
  KECP_CLIENT_CONNECT_LOGIN      CONSTANT   NUMBER   := 1;
  KECP_CLIENT_CONNECT_ADMIN      CONSTANT   NUMBER   := 2;
  KECP_CLIENT_CONNECT_GOODBYE    CONSTANT   NUMBER   := 3;
  KECP_CLIENT_CONNECT_THRDFAIL   CONSTANT   NUMBER   := 4;
  KECP_CLIENT_CONNECT_CHKPPID    CONSTANT   NUMBER   := 5;
  KECP_CLIENT_CONNECT_CLOCK_TICK CONSTANT   NUMBER   := 6;
  KECP_CLIENT_CONNECT_CHK_VSN    CONSTANT   NUMBER   := 7;

  KECP_CMD_END_OF_REPLAY         CONSTANT   NUMBER   := 1;
  KECP_CMD_REPLAY_CANCELLED      CONSTANT   NUMBER   := 2;

  FUNCTION CLIENT_CONNECT(who         IN NUMBER,
                          arg         IN NUMBER DEFAULT 0)
    RETURN   NUMBER;

  PROCEDURE CLIENT_VITALS(id          IN BINARY_INTEGER,
                          name        IN VARCHAR2,
                          value       IN NUMBER);

  PROCEDURE CLIENT_GET_REPLAY_SUBDIR(replay_subdir OUT VARCHAR2,
                                     sched_cap_id  OUT VARCHAR2);

  FUNCTION PROCESS_REPLAY_GRAPH
    RETURN NUMBER;

  FUNCTION SYNCPOINT_WAIT_TO_POST(wait_point IN NUMBER)
    RETURN NUMBER;

  /* Type used by current_uc_graph */
  TYPE uc_graph_record IS RECORD(time NUMBER, user_calls NUMBER, flags NUMBER);
  TYPE uc_graph_table  IS TABLE OF uc_graph_record;

  PROCEDURE export_uc_graph(replay_id NUMBER);
  PROCEDURE import_uc_graph(replay_id NUMBER);
  FUNCTION user_calls_graph(replay_id IN NUMBER)
    RETURN uc_graph_table PIPELINED;
  FUNCTION stop_sts_c(sts_name  IN VARCHAR2, 
                      sts_owner IN VARCHAR2,
                      in_db_caprep OUT BOOLEAN)
    RETURN BOOLEAN;    

  -- ***********************************************************
  --  GET_PROCESSING_PATH
  --    return the full path to the directory 
  --
  --    The function will take as input the following parameters:
  --      capture_id  - ID of the workload capture 
  --                    (MANDATORY)
  -- ***********************************************************

  FUNCTION get_processing_path(capture_id IN NUMBER)
  RETURN VARCHAR2;

  -- ***********************************************************
  --  GET_REPLAY_PATH
  --    return the full path to the directory 
  --
  --    The function will take as input the following parameters:
  --      replay_id  - ID of the workload replay
  --                    (MANDATORY)
  -- ***********************************************************

  FUNCTION get_replay_path(replay_id IN NUMBER)
  RETURN VARCHAR2;

  PROCEDURE initialize_replay_internal( replay_name    IN  VARCHAR2,
                                        replay_dir     IN  VARCHAR2,
                                        replay_type    IN  VARCHAR2);

  -- ************************************************************
  -- get_perf_data_export_status
  --   populates awr_data and sts_data with the filenames of the 
  --   exported performance data. If no data exists, NULL is set
  --   to the appropriate output variable
  -- ************************************************************
  PROCEDURE get_perf_data_export_status( replay_id      IN  NUMBER,
                                         awr_data      OUT  VARCHAR2,
                                         sts_data      OUT  VARCHAR2);

  -- ************************************************************
  -- Capture and Replay Attributes for EM
  -- For internal use only and subject to change in future releases
  -- ************************************************************
  PROCEDURE set_attribute(capture_id IN NUMBER,
                          replay_id  IN NUMBER,
                          name       IN VARCHAR2, -- VARCHAR2(50)
                          value      IN VARCHAR2); -- VARCHAR2(200)

  FUNCTION  get_attribute(capture_id IN NUMBER,
                          replay_id  IN NUMBER,
                          name       IN VARCHAR2)
  RETURN VARCHAR2;

  PROCEDURE delete_attribute(capture_id IN NUMBER,
                             replay_id  IN NUMBER,
                             name       IN VARCHAR2);

  -- persists all attributes across all captures and replays
  PROCEDURE persist_attributes(capture_id IN NUMBER);

  -- load the latest attributes from the os file and upsert the changes 
  -- in the existing attributes. Changes to the file are given priority
  PROCEDURE sync_attributes_from_file(capture_id IN NUMBER);

  -- adjust dbtimezone based start and end time using the timezone offset
  -- recorded by AWR (internal use only).
  PROCEDURE adjust_times_to_snap_timezone(btime in out date,
                                          awrbsnap in number,
                                          etime in out date,
                                          awresnap in number,
                                          dbid in number);

END dbms_workload_replay;
/

show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_workload_replay
FOR sys.dbms_workload_replay
/

GRANT EXECUTE ON dbms_workload_replay TO execute_catalog_role, dba
/
