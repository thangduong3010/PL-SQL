Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsawr.sql - DBMS Automatic Workload Repository
Rem                    package for administrators.
Rem
Rem    DESCRIPTION
Rem      Specification for dbms_workload_repository interface
Rem
Rem    NOTES
Rem      Package will include procedures that make Trusted Callouts
Rem      to the kernel
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      03/05/13 - Backport shiyadav_bug-13530446 from main
Rem    ilistvin    11/18/09 - bug8811401: add update_object_info API
Rem    ilistvin    06/01/09 - correct comment for maximum value of topnsql
Rem                           parameter
Rem    akini       07/18/08 - api for ASH report on multiple instances 
Rem    akini       09/12/08 - add data source to ash_report_* api
Rem    mfallen     08/15/08 - bug 6394861: add sqltext purge method
Rem    ilistvin    10/24/07 - add API for Global AWR and Global Compare Period
Rem                           reports
Rem    mlfeng      07/16/07 - allow snapshots in restricted mode (enhancement
Rem                           5630208)
Rem    mlfeng      03/29/07 - create baseline with time range
Rem    mlfeng      06/13/06 - default retention to 8 days 
Rem    mlfeng      05/03/06 - Baseline enhancements 
Rem    gngai       04/14/06 - added colored sql support
Rem    adagarwa    06/24/05 - Added pl/sql target for ASH report
Rem    ysarig      05/26/05 - Fix comments for compare period report 
Rem    veeve       01/10/05 - modify xtra_predicate to args in ash_report
Rem    adagarwa    09/15/04 - Add SQL report procedures
Rem    veeve       07/01/04 - add xtra_predicate option to ash_report
Rem    jxchen      04/26/04 - Split awr_diff_report into text and html 
Rem                           functions. 
Rem    jxchen      12/26/03 - Add Diff-Diff report procedure
Rem    veeve       02/27/04 - added ash_report_text
Rem    mlfeng      05/21/04 - add interfaces for Top N SQL
Rem    mlfeng      11/19/03 - remove stat_changes
Rem    mlfeng      11/25/03 - constant for max interval 
Rem    pbelknap    11/03/03 - pbelknap_swrfnm_to_awrnm 
Rem    pbelknap    10/28/03 - changing swrf to awr 
Rem    pbelknap    09/19/03 - updating with addition of table type 
Rem    mlfeng      08/11/03 - add options 
Rem    gngai       06/02/03 - changed drop_baseline
Rem    mlfeng      06/10/03 - add reporting logic
Rem    mlfeng      04/30/03 - return just completed snap_id and baseline_id
Rem    gngai       04/09/03 - added support for global DBID
Rem    gngai       02/25/03 - changed comments for modify_snapshot_settings
Rem    mlfeng      01/28/03 - Changing create_snapshot interface to 
Rem                           take 'TYPICAL' and 'ALL' string
Rem    mlfeng      01/22/03 - Update comments for stat_changes
Rem    gngai       01/22/03 - changed Drop_Snapshot_Range
Rem    mlfeng      08/01/02 - Updating DBMS_WORKLOAD_REPOSITORY
Rem    mlfeng      07/08/02 - swrf flushing
Rem    mlfeng      06/11/02 - Created
Rem


CREATE OR REPLACE PACKAGE dbms_workload_repository AS

  -- ************************************ --
  --  DBMS_WORKLOAD_REPOSITORY Constants
  -- ************************************ --
  
  -- Minimum and Maximum values for the 
  -- Snapshot Interval Setting (in minutes)
  MIN_INTERVAL    CONSTANT NUMBER := 10;                       /* 10 minutes */
  MAX_INTERVAL    CONSTANT NUMBER := 52560000;                  /* 100 years */

  -- Minimum and Maximum values for the  
  -- Snapshot Retention Setting (in minutes)
  MIN_RETENTION   CONSTANT NUMBER := 1440;                          /* 1 day */
  MAX_RETENTION   CONSTANT NUMBER := 52560000;                  /* 100 years */


  -- *********************************** --
  --  DBMS_WORKLOAD_REPOSITORY Routines
  -- *********************************** --

  -- 
  -- create_snapshot()
  --   Creates a snapshot in the workload repository.  
  -- 
  --   This routine will come in two forms: procedure and function.  
  --   The function returns the snap_id for the snapshot just taken.
  --
  -- Input arguments:
  --   flush_level               - flush level for the snapshot:
  --                               either 'TYPICAL' or 'ALL'
  --
  -- Returns:
  --   NUMBER                    - snap_id for snapshot just taken.
  --

  PROCEDURE create_snapshot(flush_level IN VARCHAR2 DEFAULT 'TYPICAL'
                            );

  FUNCTION create_snapshot(flush_level IN VARCHAR2 DEFAULT 'TYPICAL'
                           )  RETURN NUMBER;

  --
  -- drop_snapshot_range()
  -- purge the snapshots for the given range of snapshots.
  --
  -- Input arguments:
  --   low_snap_id              - low snapshot id of snapshots to drop
  --   high_snap_id             - high snapshot id of snapshots to drop
  --   dbid                     - database id (default to local DBID)
  --

  PROCEDURE drop_snapshot_range(low_snap_id      IN NUMBER,
                                high_snap_id     IN NUMBER,
                                dbid             IN NUMBER DEFAULT NULL
                                );


  --
  -- modify_snapshot_settings()
  -- Procedure to adjust the settings of the snapshot collection.
  --
  -- Input arguments:
  --   retention                - new retention time (in minutes). The
  --                              specified value must be in the range:
  --                              MIN_RETENTION (1 day) to 
  --                              MAX_RETENTION (100 years)
  --
  --                              If ZERO is specified, snapshots will be 
  --                              retained forever. A large system-defined
  --                              value will be used as the retention setting.
  --
  --                              If NULL is specified, the old value for 
  --                              retention is preserved.
  --
  --                              ***************
  --                               NOTE: The retention setting must be 
  --                                     greater than or equal to the window
  --                                     size of the 'SYSTEM_MOVING_WINDOW'
  --                                     baseline.  If the retention needs
  --                                     to be less than the window size,
  --                                     the 'modify_baseline_window_size'
  --                                     routine can be used to adjust the
  --                                     window size.
  --                              ***************
  --
  --   interval                 - the interval between each snapshot, in
  --                              units of minutes. The specified value 
  --                              must be in the range:
  --                              MIN_INTERVAL (10 minutes) to 
  --                              MAX_INTERVAL (100 years)
  --
  --                              If ZERO is specified, automatic and manual 
  --                              snapshots will be disabled.  A large 
  --                              system-defined value will be used as the 
  --                              interval setting.
  --
  --                              If NULL is specified, the 
  --                              current value is preserved.
  --
  --   topnsql (NUMBER)         - Top N SQL size.  The number of Top SQL 
  --                              to flush for each SQL criteria 
  --                              (Elapsed Time, CPU Time, Parse Calls, 
  --                               Shareable Memory, Version Count).  
  --
  --                              The value for this setting will be not 
  --                              be affected by the statistics/flush level 
  --                              and will override the system default 
  --                              behavior for the AWR SQL collection.  The 
  --                              setting will have a minimum value of 30 
  --                              and a maximum value of 50000.  
  --
  --                              IF NULL is specified, the 
  --                              current value is preserved.
  --
  --   topnsql (VARCHAR2)       - Users are allowed to specify the following
  --                              values: ('DEFAULT', 'MAXIMUM', 'N')
  --
  --                              Specifying 'DEFAULT' will revert the system 
  --                              back to the default behavior of Top 30 for 
  --                              level TYPICAL and Top 100 for level ALL.
  --
  --                              Specifying 'MAXIMUM' will cause the system 
  --                              to capture the complete set of SQL in the 
  --                              cursor cache.  Specifying the number 'N' is 
  --                              equivalent to setting the Top N SQL with 
  --                              the NUMBER type. 
  --
  --                              Specifying 'N' will cause the system
  --                              to flush the Top N SQL for each criteria.
  --                              The 'N' string is converted into the number
  --                              for Top N SQL.
  --
  --   dbid                     - database identifier for the database to 
  --                              adjust setting. If NULL is specified, the
  --                              local dbid will be used.
  --
  --  For example, the following statement can be used to set the
  --  Retention and Interval to their minimum settings:
  --
  --    dbms_workload_repository.modify_snapshot_settings
  --              (retention => DBMS_WORKLOAD_REPOSITORY.MIN_RETENTION
  --               interval  => DBMS_WORKLOAD_REPOSITORY.MIN_INTERVAL)
  --
  --  The following statement can be used to set the Retention to 
  --  8 days and the Interval to 60 minutes and the Top N SQL to 
  --  the default setting:
  --
  --    dbms_workload_repository.modify_snapshot_settings
  --              (retention => 11520, interval  => 60, topnsql => 'DEFAULT');
  --
  --  The following statement can be used to set the Top N SQL 
  --  setting to 200:
  --    dbms_workload_repository.modify_snapshot_settings
  --              (topnsql => 200);
  --

  PROCEDURE modify_snapshot_settings(retention  IN NUMBER DEFAULT NULL,
                                     interval   IN NUMBER DEFAULT NULL,
                                     topnsql    IN NUMBER DEFAULT NULL,
                                     dbid       IN NUMBER DEFAULT NULL
                                     );


  PROCEDURE modify_snapshot_settings(retention  IN NUMBER   DEFAULT NULL,
                                     interval   IN NUMBER   DEFAULT NULL,
                                     topnsql    IN VARCHAR2,
                                     dbid       IN NUMBER   DEFAULT NULL
                                     );


  --
  -- add_colored_sql()
  --   Routine to add a colored SQL ID. If an SQL ID is colored, it will
  --   always be captured in every snapshot, independent of its level
  --   of activities (i.e. does not have to be a TOP SQL). Capturiing
  --   will occur if the SQL is found in the cursor cache at
  --   snapshot time.
  --   
  --   To uncolor the SQL, call remove_colored_sql().
  --
  -- Input arguments:
  --   dbid                     - optional dbid, default to Local DBID
  --   sql_id                   - the 13-chararcter external SQL ID
  --
  -- Returns:
  --   none.
  --

  PROCEDURE add_colored_sql(sql_id         IN VARCHAR2,
                            dbid           IN NUMBER DEFAULT NULL
                            );


  --
  -- remove_colored_sql()
  --   Routine to remove a colored SQL ID, i.e. uncolored. After a
  --   SQL is uncolored, it will no longer be captured in a snapshot
  --   automatically, unless it makes the TOP list.
  --
  -- Input arguments:
  --   dbid                     - optional dbid, default to Local DBID
  --   sql_id                   - the 13-chararcter external SQL ID
  --
  -- Returns:
  --   none.
  --

  PROCEDURE remove_colored_sql(sql_id         IN VARCHAR2,
                               dbid           IN NUMBER DEFAULT NULL
                               );


  --
  -- create_baseline()
  --   Routine to create a baseline.  A baseline is set of
  --   of statistics defined by a (begin, end) pair of snapshots.
  --
  --   This routine will come in two forms: procedure and function.  
  --   The function returns the baseline_id for the baseline just created.
  --
  -- Input arguments:
  --   start_snap_id            - start snapshot sequence number for baseline
  --   end_snap_id              - end snapshot sequence number for baseline
  --   baseline_name            - name of baseline (required)
  --   dbid                     - optional dbid, default to Local DBID
  --   expiration               - expiration in number of days for the 
  --                              baseline.  If NULL, then the expiration
  --                              is infinite, meaning do not drop baseline
  --                              ever.  Defaults to NULL.
  --
  -- Returns:
  --   NUMBER                   - baseline_id for the baseline just created
  --

  PROCEDURE create_baseline(start_snap_id  IN NUMBER, 
                            end_snap_id    IN NUMBER,
                            baseline_name  IN VARCHAR2,
                            dbid           IN NUMBER DEFAULT NULL,
                            expiration     IN NUMBER DEFAULT NULL
                            );

  FUNCTION create_baseline(start_snap_id  IN NUMBER, 
                           end_snap_id    IN NUMBER,
                           baseline_name  IN VARCHAR2,
                           dbid           IN NUMBER DEFAULT NULL,
                           expiration     IN NUMBER DEFAULT NULL
                           )  RETURN NUMBER;

  --
  -- create_baseline()
  --   Routine to create a baseline.  This version of create_baseline()
  --   will take in as input a time range.
  --
  -- Input arguments:
  --   start_time               - start time
  --   end_time                 - end time
  --   baseline_name            - name of baseline (required)
  --   dbid                     - optional dbid, default to Local DBID
  --   expiration               - expiration in number of days for the 
  --                              baseline.  If NULL, then the expiration
  --                              is infinite, meaning do not drop baseline
  --                              ever.  Defaults to NULL.
  --
  -- Returns:
  --   NUMBER                   - baseline_id for the baseline just created
  --
  PROCEDURE create_baseline(start_time     IN DATE,
                            end_time       IN DATE,
                            baseline_name  IN VARCHAR2,
                            dbid           IN NUMBER DEFAULT NULL,
                            expiration     IN NUMBER DEFAULT NULL
                            );

  FUNCTION create_baseline(start_time     IN DATE,
                           end_time       IN DATE,
                           baseline_name  IN VARCHAR2,
                           dbid           IN NUMBER DEFAULT NULL,
                           expiration     IN NUMBER DEFAULT NULL
                           )  RETURN NUMBER;

  --
  -- select_baseline_details()
  --   Routine to select the stats for a baseline.  This table function
  --   is used to fill in the stats for the WRM$_BASELINE_DETAILS table,
  --   and to retrieve the stats for the Moving Window Baseline.
  --
  -- Input arguments:
  --   baseline_id     - Baseline Id to view the stats for. If the 
  --                     baseline id is 0, then we are getting stats
  --                     for the moving window baseline.  
  --   dbid            - database id, default to Local DBID
  --
  -- Returns:
  --   awrbl_details_type_table  - AWR Baseline Details Table
  --
  FUNCTION select_baseline_details(l_baseline_id   IN NUMBER,
                                   l_beg_snap      IN NUMBER DEFAULT NULL,
                                   l_end_snap      IN NUMBER DEFAULT NULL,
                                   l_dbid          IN NUMBER DEFAULT NULL)
  RETURN awrbl_details_type_table PIPELINED;

  --
  -- select_baseline_metrics()
  --   Routine to select the metric stats for a baseline.  This table function
  --   will return the baseline metric stats for the user.
  --
  -- Input arguments:
  --   baseline_name   - Baseline Name to view the stats for
  --   dbid            - database id, default to Local DBID
  --   instance_num    - instance id, default to Local Instance Number
  --
  -- Returns:
  --   awrbl_metric_type_table  - AWR Baseline Metric Table
  --
  FUNCTION select_baseline_metric(l_baseline_name  IN VARCHAR2,
                                  l_dbid           IN NUMBER DEFAULT NULL,
                                  l_instance_num   IN NUMBER DEFAULT NULL)
  RETURN awrbl_metric_type_table PIPELINED;

  --
  -- rename_baseline()
  --   Routine to rename a baseline.  
  -- 
  --   This routine will allow the user to rename the Baseline.
  --
  -- Input arguments:
  --   old_baseline_name        - old baseline name
  --   new_baseline_name        - new baseline name
  --   dbid                     - optional dbid, default to Local DBID
  --
  PROCEDURE rename_baseline(old_baseline_name IN VARCHAR2,
                            new_baseline_name IN VARCHAR2,
                            dbid              IN NUMBER DEFAULT NULL
                            );

  --
  -- modify_baseline_window_size()
  --   Routine to modify the window size for the default 
  --   moving window baseline
  -- 
  --   This routine modifies the window size for the Default Moving
  --   Window Baseline.  The user will input the size of the window
  --   in number of days.
  --
  -- Input arguments:
  --   window_size  - New Window size for the default Moving Window
  --                  Baseline, in number of days
  --
  --                  ***************
  --                   NOTE: The window size must be less than or equal to
  --                         the AWR retention setting. If the window size
  --                         needs to be greater than the retention setting,
  --                         the 'modify_snapshot_settings' routine can be
  --                         used to adjust the retention setting.
  --                  ***************
  --
  --   dbid         - optional dbid, default to Local DBID
  --
  PROCEDURE modify_baseline_window_size(window_size IN NUMBER,
                                        dbid        IN NUMBER DEFAULT NULL
                                        );

  --
  -- drop_baseline()
  -- drops a baseline (by name)
  --
  -- Input arguments:
  --   baseline_name            - name of baseline to drop
  --   dbid                     - database id, default to local DBID
  --   cascade                  - if TRUE, the range of snapshots associated 
  --                              with the baseline will also be dropped. 
  --                              Otherwise, only the baseline is removed.
  --
  PROCEDURE drop_baseline(baseline_name IN VARCHAR2,
                          cascade       IN BOOLEAN DEFAULT false,
                          dbid          IN NUMBER DEFAULT NULL
                          );

  -- **************************** --
  --  Baseline Template routines  --
  -- **************************** --

  --
  -- create_baseline_template() - Single Time
  --   This particular routine will create a Baseline Template for a
  --   single time period. There will be a MMON task that will use
  --   these inputs to create a Baseline for the time period when the
  --   time comes.
  --
  -- Input arguments:
  --   start_time    - Start Time for the Baseline to be created
  --   end_time      - End Time for the Baseline to be created
  --   baseline_name - Name of Baseline to be created.  
  --   template_name - Name for the Template
  --   expiration    - expiration in number of days for the baseline.  
  --                   If NULL, then the expiration is infinite, meaning 
  --                   do not drop baseline ever.  Defaults to NULL.
  --   dbid          - Database Identifier for Baseline.  
  --                   If NULL, then use the database identifier for the 
  --                   local database.  Defaults to NULL.
  --
  PROCEDURE create_baseline_template(start_time     IN DATE, 
                                     end_time       IN DATE,
                                     baseline_name  IN VARCHAR2,
                                     template_name  IN VARCHAR2,
                                     expiration     IN NUMBER DEFAULT NULL,
                                     dbid           IN NUMBER DEFAULT NULL
                                     );

  --
  -- create_baseline_template() - Repeating Time
  --   This particular routine will create a Baseline Template for 
  --   creating and dropping Baselines based on repeating time periods. 
  --
  --   There will be a MMON task that will use these inputs to create the
  --   Baseline for the relevant time periods and automatically drop
  --   the Baselines based on their expiration.
  --
  -- Input arguments:
  --   day_of_week   - Day of week that the Baseline should repeat on.  
  --                   Specify one of the following values: 
  --                   ('SUNDAY', 'MONDAY', 'TUESDAY', 'WEDNESDAY', 
  --                    'THURSDAY', 'FRIDAY', 'SATURDAY', 'ALL')
  --   hour_in_day   - Value of 0-23 to specify the Hour in the Day the 
  --                   Baseline should start
  --   duration      - Duration (in number of hours) after hour in the day 
  --                   that the Baseline should last. 
  --   start_time    - Start Time for the Baseline to be created
  --   end_time      - End Time for the Baseline to be created
  --   baseline_name_prefix - Prefix for the Name of Baseline to be created.  
  --   template_name - Name for the Template
  --   expiration    - expiration in number of days for the baseline.  
  --                   If NULL, then the expiration is infinite, meaning 
  --                   do not drop baseline ever.  
  --                   Defaults to 35 days (5 weeks).
  --   dbid          - Database Identifier for Baseline.  
  --                   If NULL, then use the database identifier for the 
  --                   local database.  Defaults to NULL.
  --
  PROCEDURE create_baseline_template(day_of_week          IN VARCHAR2,
                                     hour_in_day          IN NUMBER, 
                                     duration             IN NUMBER,
                                     start_time           IN DATE, 
                                     end_time             IN DATE,
                                     baseline_name_prefix IN VARCHAR2,
                                     template_name        IN VARCHAR2,
                                     expiration           IN NUMBER DEFAULT 35,
                                     dbid                 IN NUMBER 
                                                             DEFAULT NULL
                                     );

  --
  -- drop_baseline_template()
  --   This particular routine will drop a Baseline Template.  The user
  --   provides the name of the Baseline Template they would like to drop.
  --
  -- Input arguments:
  --   template_name - Name of the Baseline Template to drop
  --   dbid          - Database Identifier for Baseline.  
  --                   If NULL, then use the database identifier for the 
  --                   local database.  Defaults to NULL.
  -- 
  PROCEDURE drop_baseline_template(template_name  IN VARCHAR2,
                                   dbid           IN NUMBER DEFAULT NULL
                                   );


  -- ***********************************************************
  --  awr_report_text and _html (FUNCTION)
  --    This is the table function that will display the 
  --    AWR report in either text or HTML.  The output will be 
  --     one column of VARCHAR2(80) or (1500), respectively
  --
  --    The report will take as input the following parameters:
  --      l_dbid     - database identifier
  --      l_inst_num - instance number
  --      l_bid      - Begin Snap Id
  --      l_eid      - End Snapshot Id
  -- ***********************************************************
  FUNCTION awr_report_text(l_dbid     IN NUMBER, 
                           l_inst_num IN NUMBER, 
                           l_bid      IN NUMBER, 
                           l_eid      IN NUMBER,
                           l_options  IN NUMBER DEFAULT 0)
  RETURN awrrpt_text_type_table PIPELINED;

  FUNCTION awr_report_html(l_dbid     IN NUMBER, 
                           l_inst_num IN NUMBER, 
                           l_bid      IN NUMBER, 
                           l_eid      IN NUMBER,
                           l_options  IN NUMBER DEFAULT 0)
  RETURN awrrpt_html_type_table PIPELINED;

  -- ***********************************************************
  --  awr_global_report_text and _html (FUNCTION)
  --    This is the table function that will display the
  --    Global AWR report in either text or HTML.  The output will be
  --     one column of VARCHAR2(320) or (1500), respectively
  --
  --    The report will take as input the following parameters:
  --      l_dbid     - database identifier
  --      l_inst_num - list of instance numbers to be included in report.
  --                   if set to NULL, all instances for which begin and
  --                   end snapshots are available, and which have not
  --                   been restarted between snapshots,
  --                   will be included in the report.
  --      l_bid      - Begin Snap Id
  --      l_eid      - End Snapshot Id
  -- ***********************************************************
  FUNCTION awr_global_report_text(l_dbid     IN NUMBER,
                                  l_inst_num IN AWRRPT_INSTANCE_LIST_TYPE,
                                  l_bid      IN NUMBER,
                                  l_eid      IN NUMBER,
                                  l_options  IN NUMBER DEFAULT 0)
  RETURN awrdrpt_text_type_table PIPELINED;
  --
  -- This version accepts a comma-separated list of instance numbers
  -- No leading zeroes are allowed and no more than 1023 characters total
  --
  FUNCTION awr_global_report_text(l_dbid     IN NUMBER,
                                  l_inst_num IN VARCHAR2,
                                  l_bid      IN NUMBER,
                                  l_eid      IN NUMBER,
                                  l_options  IN NUMBER DEFAULT 0)
  RETURN awrdrpt_text_type_table PIPELINED;

  FUNCTION awr_global_report_html(l_dbid     IN NUMBER,
                                  l_inst_num IN AWRRPT_INSTANCE_LIST_TYPE,
                                  l_bid      IN NUMBER,
                                  l_eid      IN NUMBER,
                                  l_options  IN NUMBER DEFAULT 0)
  RETURN awrrpt_html_type_table PIPELINED;
  --
  -- This version accepts a comma-separated list of instance numbers
  -- No leading zeroes are allowed and no more than 1023 characters total
  --
  FUNCTION awr_global_report_html(l_dbid     IN NUMBER,
                                  l_inst_num IN VARCHAR2,
                                  l_bid      IN NUMBER,
                                  l_eid      IN NUMBER,
                                  l_options  IN NUMBER DEFAULT 0)
  RETURN awrrpt_html_type_table PIPELINED;

  -- ***********************************************************
  --  awr_sql_report_text (FUNCTION)
  --    This is the function that will return the 
  --    AWR SQL Report in text format
  --    Output will be one column of VARCHAR2(120)
  --
  --  awr_sql_report_html (FUNCTION)
  --    This is the function that will return the 
  --    AWR SQL Report in html format
  --    Output will be one column of VARCHAR2(500)
  --
  --    The report will take as input the following parameters:
  --      l_dbid     - database identifier
  --      l_inst_num - instance number
  --      l_bid      - Begin Snapshot Id
  --      l_eid      - End Snapshot Id
  --      l_sqlid    - SQL Id of statement to be analyzed
  --      l_options  - Report level (not used yet)
  FUNCTION awr_sql_report_text(l_dbid     IN NUMBER, 
                               l_inst_num IN NUMBER, 
                               l_bid      IN NUMBER, 
                               l_eid      IN NUMBER,
                               l_sqlid    IN VARCHAR2,
                               l_options  IN NUMBER DEFAULT 0)
  RETURN awrsqrpt_text_type_table PIPELINED;

  FUNCTION awr_sql_report_html(l_dbid     IN NUMBER, 
                               l_inst_num IN NUMBER, 
                               l_bid      IN NUMBER, 
                               l_eid      IN NUMBER,
                               l_sqlid    IN VARCHAR2,
                               l_options  IN NUMBER DEFAULT 0)
  RETURN awrrpt_html_type_table PIPELINED;

 
  -- ***********************************************************
  --  awr_diff_report_text (FUNCTION)
  --    This is the table function that will display the
  --    AWR Compare Periods Report in text format.  The output 
  --    will be one column of VARCHAR2(320).
  --
  --    The report will take as input the following parameters:
  --      dbid1     - 1st database identifier
  --      inst_num1 - 1st instance number
  --      bid1      - 1st Begin Snap Id
  --      eid1      - 1st End Snapshot Id
  --      dbid2     - 2nd database identifier
  --      inst_num2 - 2nd instance number
  --      bid2      - 2nd Begin Snap Id
  --      eid2      - 2nd End Snapshot Id
  -- ***********************************************************
  FUNCTION awr_diff_report_text(dbid1     IN NUMBER,
                                inst_num1 IN NUMBER,
                                bid1      IN NUMBER,
                                eid1      IN NUMBER,
                                dbid2     IN NUMBER,
                                inst_num2 IN NUMBER,
                                bid2      IN NUMBER,
                                eid2      IN NUMBER)
  RETURN awrdrpt_text_type_table PIPELINED;

  -- ***********************************************************
  --  awr_diff_report_html (FUNCTION)
  --    This is the table function that will display the
  --    AWR Compare Periods Report in HTML format.  The output 
  --    will be one column of VARCHAR2(1500).
  --
  --    The report will take as input the following parameters:
  --      dbid1     - 1st database identifier
  --      inst_num1 - 1st instance number
  --      bid1      - 1st Begin Snap Id
  --      eid1      - 1st End Snapshot Id
  --      dbid2     - 2nd database identifier
  --      inst_num2 - 2nd instance number
  --      bid2      - 2nd Begin Snap Id
  --      eid2      - 2nd End Snapshot Id
  -- ***********************************************************
  FUNCTION awr_diff_report_html(dbid1     IN NUMBER,
                                inst_num1 IN NUMBER,
                                bid1      IN NUMBER,
                                eid1      IN NUMBER,
                                dbid2     IN NUMBER,
                                inst_num2 IN NUMBER,
                                bid2      IN NUMBER,
                                eid2      IN NUMBER)
  RETURN awrrpt_html_type_table PIPELINED;

  -- ***********************************************************
  --  awr_global_diff_report_text (FUNCTION)
  --    This is the table function that will display the
  --    Global AWR Compare Periods Report in text format.  The output
  --    will be one column of VARCHAR2(320).
  --
  --    The report will take as input the following parameters:
  --      dbid1     - 1st database identifier
  --      inst_num1 - 1st list of instance numbers
  --                   if set to NULL, all instances for which begin and
  --                   end snapshots are available, and which have not
  --                   been restarted between snapshots,
  --                   will be included in the report.
  --      bid1      - 1st Begin Snap Id
  --      eid1      - 1st End Snapshot Id
  --      dbid2     - 2nd database identifier
  --      inst_num2 - 2nd list of instance numbers
  --                   if set to NULL, all instances for which begin and
  --                   end snapshots are avalable, and which have not
  --                   been restarted between snapshots,
  --                   will be included in the report.
  --      bid2      - 2nd Begin Snap Id
  --      eid2      - 2nd End Snapshot Id
  -- ***********************************************************
  FUNCTION awr_global_diff_report_text(dbid1     IN NUMBER,
                                       inst_num1 IN AWRRPT_INSTANCE_LIST_TYPE,
                                       bid1      IN NUMBER,
                                       eid1      IN NUMBER,
                                       dbid2     IN NUMBER,
                                       inst_num2 IN AWRRPT_INSTANCE_LIST_TYPE,
                                       bid2      IN NUMBER,
                                       eid2      IN NUMBER)
  RETURN awrdrpt_text_type_table PIPELINED;
  --
  -- This version accepts comma-separated lists of instance numbers
  -- for inst_num1 and inst_num2
  -- No leading zeroes are allowed and no more than 1023 characters each
  -- 
  --
  FUNCTION awr_global_diff_report_text(dbid1     IN NUMBER,
                                       inst_num1 IN VARCHAR2,
                                       bid1      IN NUMBER,
                                       eid1      IN NUMBER,
                                       dbid2     IN NUMBER,
                                       inst_num2 IN VARCHAR2,
                                       bid2      IN NUMBER,
                                       eid2      IN NUMBER)
  RETURN awrdrpt_text_type_table PIPELINED;

  -- ***********************************************************
  --  awr_global_diff_report_html (FUNCTION)
  --    This is the table function that will display the
  --    Gobal AWR Compare Periods Report in HTML format.  The output
  --    will be one column of VARCHAR2(1500).
  --
  --    The report will take as input the following parameters:
  --      dbid1     - 1st database identifier
  --      inst_num1 - 1st list of instance numbers
  --                   if set to NULL, all instances for which begin and
  --                   end snapshots are available, and which have not
  --                   been restarted between snapshots,
  --                   will be included in the report.
  --      bid1      - 1st Begin Snap Id
  --      eid1      - 1st End Snapshot Id
  --      dbid2     - 2nd database identifier
  --      inst_num2 - 2nd list of instance numbers
  --                   if set to NULL, all instances for which begin and
  --                   end snapshots are available, and which have not
  --                   been restarted between snapshots,
  --                   will be included in the report.
  --      bid2      - 2nd Begin Snap Id
  --      eid2      - 2nd End Snapshot Id
  -- ***********************************************************
  FUNCTION awr_global_diff_report_html(dbid1     IN NUMBER,
                                       inst_num1 IN AWRRPT_INSTANCE_LIST_TYPE,
                                       bid1      IN NUMBER,
                                       eid1      IN NUMBER,
                                       dbid2     IN NUMBER,
                                       inst_num2 IN AWRRPT_INSTANCE_LIST_TYPE,
                                       bid2      IN NUMBER,
                                       eid2      IN NUMBER)
  RETURN awrrpt_html_type_table PIPELINED;
  --
  -- This version accepts comma-separated lists of instance numbers
  -- for inst_num1 and inst_num2
  -- No leading zeroes are allowed and no more than 1023 characters each
  --
  FUNCTION awr_global_diff_report_html(dbid1     IN NUMBER,
                                       inst_num1 IN VARCHAR2,
                                       bid1      IN NUMBER,
                                       eid1      IN NUMBER,
                                       dbid2     IN NUMBER,
                                       inst_num2 IN VARCHAR2,
                                       bid2      IN NUMBER,
                                       eid2      IN NUMBER)
  RETURN awrrpt_html_type_table PIPELINED;


  -- ***********************************************************
  --  ash_report_text (FUNCTION)
  --    This is the function that will return the 
  --    ASH Spot report in text format. 
  --    Output will be one column of VARCHAR2(80)
  --
  --  ash_report_html (FUNCTION)
  --    This is the function that will return the 
  --    ASH Spot report in html format.
  --    Output will be one column of VARCHAR2(500)
  --
  --    The report will take as input the following parameters:
  --      l_dbid        - Database identifier
  --      l_inst_num    - Instance number
  --      l_btime       - Begin time
  --      l_etime       - End time
  --      l_options     - Report level (not used yet)
  --      l_slot_width  - Specifies (in seconds) how wide the slots used 
  --                      in the "Top Activity" section of the report 
  --                      should be. This argument is optional, and if it is
  --                      not specified the time interval between l_btime and
  --                      l_etime is appropriately split into not 
  --                      more than 10 slots.
  --
  --    The rest of the arguments are optional. All but the last one, l_data_src,
  --    are used to specify 'report targets'. Before getting to the targets, 
  --     
  --      l_data_src    - Can be used to specify a data source
  --                      1 => memory (i.e., V$ACTIVE_SESION_HISTORY)
  --                      2 => disk   (i.e., DBA_HIST_ACTIVE_SESS_HISTORY)
  --                      0 => both   (this is the default value. Here, the 
  --                                   begin and end time parameters are used to
  --                                   get the samples from the appropriate data
  --                                   source, which can be memory, disk, or both
  --                                  )
  -- 
  --    Now for 'report targets' - this is if you want to generate the ASH Report
  --    on a particular target like a sql statement, or a session, or a 
  --    Service/Module combination. 
  --
  --    In other words, these arguments can be specified 
  --    to restrict the ASH rows that would be used to generate the report. 
  --
  --         For example, to generate an ASH report on a 
  --         particular SQL statement, say SQL_ID 'abcdefghij123'
  --         pass that sql_id value to the l_sql_id argument:
  --            l_sql_id => 'abcdefghij123'
  --
  --    Any combination of those optional arguments can be passed in, and
  --    the only rows in ASH that satisfy all of those 'report targets' will
  --    be used. In other words, if multiple 'report targets' are specified
  --    AND conditional logic is used to connect them.
  --
  --         For example, to generate an ASH report on
  --         MODULE "PAYROLL" and ACTION "PROCESS"
  --         one can use the following predicate:
  --            l_module => 'PAYROLL', l_action => 'PROCESS'
  --
  --    Valid SQL wildcards can be used in all the arguments that are of type
  --    VARCHAR2.
  --
  --       ===============   =================================   =========
  --           Argument      Comment                             Wildcards
  --             Name                                            Allowed?
  --       ===============   =================================   =========
  --        l_sid            Session id                          No
  --                         eg. V$SESSION.SID
  --                         
  --        l_sql_id         SQL id                              Yes
  --                         eg. V$SQL.SQL_ID
  --
  --        l_wait_class     Wait class name                     Yes
  --                         eg. V$EVENT_NAME.WAIT_CLASS
  --
  --        l_service_hash   Service name hash                   No
  --                         eg. V$ACTIVE_SERVICES.NAME_HASH
  --
  --        l_module         Module name                         Yes
  --                         eg. V$SESSION.MODULE
  --
  --        l_action         Action name                         Yes
  --                         eg. V$SESSION.ACTION
  --
  --        l_client_id      Client identifier for               Yes
  --                         end-to-end tracing
  --                         eg. V$SESSION.CLIENT_IDENTIFIER
  --  
  --        l_plsql_entry    Name of PL/SQL entry subprogram     Yes
  --                         e.g. "SYS.DBMS_LOB.*"
  --        
  --       ===============   =================================   =========
  --
  -- ***********************************************************
  FUNCTION ash_report_text(l_dbid          IN NUMBER, 
                           l_inst_num      IN NUMBER, 
                           l_btime         IN DATE,
                           l_etime         IN DATE,
                           l_options       IN NUMBER    DEFAULT 0,
                           l_slot_width    IN NUMBER    DEFAULT 0,
                           l_sid           IN NUMBER    DEFAULT NULL,
                           l_sql_id        IN VARCHAR2  DEFAULT NULL,
                           l_wait_class    IN VARCHAR2  DEFAULT NULL,
                           l_service_hash  IN NUMBER    DEFAULT NULL,
                           l_module        IN VARCHAR2  DEFAULT NULL,
                           l_action        IN VARCHAR2  DEFAULT NULL,
                           l_client_id     IN VARCHAR2  DEFAULT NULL,
                           l_plsql_entry   IN VARCHAR2  DEFAULT NULL,
                           l_data_src      IN NUMBER    DEFAULT 0
                          )
  RETURN awrrpt_text_type_table PIPELINED;

  FUNCTION ash_report_html(l_dbid          IN NUMBER, 
                           l_inst_num      IN NUMBER, 
                           l_btime         IN DATE,
                           l_etime         IN DATE,
                           l_options       IN NUMBER    DEFAULT 0,
                           l_slot_width    IN NUMBER    DEFAULT 0,
                           l_sid           IN NUMBER    DEFAULT NULL,
                           l_sql_id        IN VARCHAR2  DEFAULT NULL,
                           l_wait_class    IN VARCHAR2  DEFAULT NULL,
                           l_service_hash  IN NUMBER    DEFAULT NULL,
                           l_module        IN VARCHAR2  DEFAULT NULL,
                           l_action        IN VARCHAR2  DEFAULT NULL,
                           l_client_id     IN VARCHAR2  DEFAULT NULL,
                           l_plsql_entry   IN VARCHAR2  DEFAULT NULL,
                           l_data_src      IN NUMBER    DEFAULT 0
                          )
  RETURN awrrpt_html_type_table PIPELINED;
  FUNCTION ash_global_report_text(l_dbid          IN NUMBER,
                                  l_inst_num      IN VARCHAR2,
                                  l_btime         IN DATE,
                                  l_etime         IN DATE,
                                  l_options       IN NUMBER    DEFAULT 0,
                                  l_slot_width    IN NUMBER    DEFAULT 0,
                                  l_sid           IN NUMBER    DEFAULT NULL,
                                  l_sql_id        IN VARCHAR2  DEFAULT NULL,
                                  l_wait_class    IN VARCHAR2  DEFAULT NULL,
                                  l_service_hash  IN NUMBER    DEFAULT NULL,
                                  l_module        IN VARCHAR2  DEFAULT NULL,
                                  l_action        IN VARCHAR2  DEFAULT NULL,
                                  l_client_id     IN VARCHAR2  DEFAULT NULL,
                                  l_plsql_entry   IN VARCHAR2  DEFAULT NULL,
                                  l_data_src      IN NUMBER    DEFAULT 0
                                 )
  RETURN awrdrpt_text_type_table PIPELINED;
  FUNCTION ash_global_report_html(l_dbid          IN NUMBER,
                                  l_inst_num      IN VARCHAR2,
                                  l_btime         IN DATE,
                                  l_etime         IN DATE,
                                  l_options       IN NUMBER    DEFAULT 0,
                                  l_slot_width    IN NUMBER    DEFAULT 0,
                                  l_sid           IN NUMBER    DEFAULT NULL,
                                  l_sql_id        IN VARCHAR2  DEFAULT NULL,
                                  l_wait_class    IN VARCHAR2  DEFAULT NULL,
                                  l_service_hash  IN NUMBER    DEFAULT NULL,
                                  l_module        IN VARCHAR2  DEFAULT NULL,
                                  l_action        IN VARCHAR2  DEFAULT NULL,
                                  l_client_id     IN VARCHAR2  DEFAULT NULL,
                                  l_plsql_entry   IN VARCHAR2  DEFAULT NULL,
                                  l_data_src      IN NUMBER    DEFAULT 0
                                 )
  RETURN awrrpt_html_type_table PIPELINED;
  --
  -- control_restricted_snapshot()
  --   This routine controls if AWR snapshots are allowed to occur
  --   even if the restricted session mode has been enabled for the 
  --   database.  Calling this with allow=true will allow the AWR 
  --   snapshot capture for the local instance from which this routine
  --   is called.  Calling this with allow=false will disallow the AWR 
  --   snapshot capture in restricted session mode.
  --
  --   By default, if the database is in restricted session mode, AWR
  --   snapshots are NOT allowed.
  --
  --   This routine must be called on each instance if the user wants
  --   the snapshots to happen for each instance.
  --
  --   This routine only affects the behavior of the following procedure:
  --     DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT()
  -- 
  -- Input arguments:
  --   allow - boolean to allow snapshots in restricted session mode
  -- 
  PROCEDURE control_restricted_snapshot(allow IN BOOLEAN);

  -- *************************************************************************
  -- awr_set_report_thresholds  (PROCEDURE)
  --  Allows configuring of specified report thresholds. Allows control of
  --  number of rows in the report.
  --
  --  Parameters
  --   top_n_events  - number of most significant wait events to be included
  --   top_n_files   - number of most active files to be included
  --   top_n_segments - number of most active segments to be included
  --   top_n_services - number of most active services to be included
  --   top_n_sql      - number of most significant SQL statements to be
  --                    included
  --   top_n_sql_max  - number of SQL statements to be included if their 
  --                    activity is greater than that specified by 
  --                    top_sql_pct.
  --   top_sql_pct    - significance threshold for SQL statements between
  --                    top_n_sql and top_n_max_sql
  --   shmem_threshold - shared memory low threshold
  --   versions_threshold - plan version count low threshold
  --
  --  Note: effect of each setting depends on the type of report being 
  --        generated as well as on the underlying AWR data. Not all
  --        settings are meaningful for each report type. 
  --        Invalid settings (such as negative numbers, etc,) are ignored.
  -- *************************************************************************
  PROCEDURE awr_set_report_thresholds(top_n_events      IN NUMBER DEFAULT NULL,
                                      top_n_files       IN NUMBER DEFAULT NULL,
                                      top_n_segments    IN NUMBER DEFAULT NULL,
                                      top_n_services    IN NUMBER DEFAULT NULL,
                                      top_n_sql         IN NUMBER DEFAULT NULL,
                                      top_n_sql_max     IN NUMBER DEFAULT NULL,
                                      top_sql_pct       IN NUMBER DEFAULT NULL,
                                      shmem_threshold   IN NUMBER DEFAULT NULL,
                                      versions_threshold IN NUMBER DEFAULT NULL
                                    );

  --
  -- purge_sql_details()
  --   This routine purges rows from the AWR SQL details tables
  --   (WRH$_SQLTEXT and WHR$_SQL_PLAN) that are no longer required.
  --
  --   This may be helpful in an environment that uses a lot of
  --   literals (leading to SQL statements that are only run once)
  --   and AWR baselines (preserved snapshots).
  --
  --   Note that this routine does not rebuild segments, nor
  --   does it do any other kind of DDL.
  --
  -- Input arguments:
  --   numrows - maximum number of rows to purge at a time
  --   dbid    - database identifier
  -- 
  PROCEDURE purge_sql_details(numrows IN NUMBER DEFAULT NULL,
                              dbid    IN NUMBER DEFAULT NULL);

  -- 
  -- update_object_info()
  --  This routine updates rows of WRH$_SEG_STAT_OBJ table 
  --  that represent objects in the local database.
  -- 
  --    This routine  attempts to determine current names for all objects 
  --  belonging to the local database, except those with 'MISSING' and/or
  --  'TRANSIENT' values in the name columns. 
  --  Amount of work performed at each invocation of this routine may be 
  --  controlled by appropriate settings of the input parameters.
  --  modval are selected for validation. Default settings of modbase (1) and
  --  modval (0) cause all rows to be examined.
  --   
  -- 
  --  Input arguments:
  --   maxrows     - maximum number of rows that will be updated 
  --                 during each invocation of this routine. 
  --                 Default value, 0, means there is no limit. 
  --  

  PROCEDURE update_object_info(maxrows   IN  NUMBER  DEFAULT 0);

  -- 
  -- update_datafile_info()
  --  This routine updates WRH$_DATAFILE rows for the datafile name and 
  --  tablespace name. Whenever this procedure runs, it will update these 
  --  values with the current information in the database.
  --
  --  This routine is useful when a datafile/tablespace has been moved or 
  --  renamed. As this change is generally not always captured in the next 
  --  snapshot in AWR. This change will be captured at max after some 
  --  (generally 50) snapshots. So the AWR and AWR report may be wrong with 
  --  respect to data file name or tablespace name for that duration.
  -- 
  --  To fix this problem, we can use this procedure to sync the table 
  --  WRH$_DATAFILE with the current information in database. 
  --  

  PROCEDURE update_datafile_info;

END dbms_workload_repository;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_workload_repository 
FOR sys.dbms_workload_repository
/
GRANT EXECUTE ON dbms_workload_repository TO dba
/
-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_SWRF_LIB TRUSTED AS STATIC;
/
