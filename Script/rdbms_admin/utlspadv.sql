Rem
Rem $Header: rdbms/admin/utlspadv.sql /st_rdbms_11.2.0/2 2011/01/14 09:53:51 vchandar Exp $
Rem
Rem utlspadv.sql
Rem
Rem Copyright (c) 2007, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utlspadv.sql - Streams Performance ADVisor Utility
Rem
Rem    DESCRIPTION
Rem      A utility package for collecting streams topology and statistics,
Rem      which are similar to what Strmmon produces.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vchandar    01/12/11 - Backport vchandar_bug-10384221 from main
Rem    vchandar    12/25/10 - Bug 10384221
Rem    vchandar    06/30/10 - Account for all component/subcomponent types
Rem    vchandar    06/21/10 - use utl_file
Rem    vchandar    05/17/10 - lrg 4527973
Rem    vchandar    02/12/10 - add secondary index for comp_stat table
Rem    vchandar    02/04/10 - Handle multiple bottlenecks for a single runid
Rem    bpwang      02/01/10 - Bug 9256726: Handle component state
Rem    vchandar    12/13/09 - Pass html bottleneck info in spare3
Rem    vchandar    12/11/09 - Remove usage of htp package
Rem    vchandar    12/10/09 - make save_comp_stat default TRUE
Rem    vchandar    09/08/09 - Adding support for html report
Rem    jinwu       06/19/09 - allow purge in stop_monitoring
Rem    jinwu       04/21/09 - fix bug 7508507 (reduce sharable memory use)
Rem    jinwu       09/09/08 - add show_stats_table in streams$_pa_monitoring
Rem    jinwu       09/09/08 - donot persist streams$_pa_show_comp_stat
Rem    jinwu       09/08/08 - add param_unit to streams$_pa_control
Rem    jinwu       09/08/08 - add table streams$_pa_database_prop
Rem    tianli      09/15/08 - add spadv support for xstream
Rem    jinwu       08/18/08 - collect stats for active component only
Rem    jinwu       07/21/08 - add is/start/alter/stop_monitoring
Rem    jinwu       04/08/08 - change show_cca_mode to show_optimization
Rem    jinwu       04/04/08 - use scientific representation for BANDWIDTH
Rem    jinwu       04/04/08 - remove column original_path_id and active
Rem    jinwu       02/08/08 - change ANR to PS+PR for local CCAC
Rem    jinwu       12/31/07 - add CAP+PS for remote CCA
Rem    jinwu       12/31/07 - add cca_mode
Rem    jinwu       10/19/07 - fix ####### in percentage
Rem    jinwu       08/15/07 - fix bug 6343077
Rem    jinwu       07/06/07 - aggregate TOP EVENT percentage for APS and LMP
Rem    jinwu       07/05/07 - rename 'CAPTURE PROCESS' to 'CAPTURE SESSION'
Rem    jinwu       06/13/07 - change param stat_table to path_stat_table.
Rem    jinwu       06/05/07 - Created
Rem

-- set up some environment for html report
-- this should probably be moved to whichever script loads utlspadv
-- html tags have &
set define off;

-- Create tables for monitoring API
drop table streams$_pa_monitoring;
create table streams$_pa_monitoring
(
  job_name           varchar2(30) not null,
  client_name        varchar2(30) default null,
  query_user_name    varchar2(30) default null,
  show_stats_table   varchar2(30) default 'STREAMS$_PA_SHOW_PATH_STAT',
  started_time       timestamp default null,
  stopped_time       timestamp default null,
  altered_time       timestamp default null,
  state              varchar2(30) default null           /* ENABLED, STOPPED */
)
/

-- PROP_NAME:
--   VERSION
--   COMPATIBILITY
--   MANAGEMENT_PACK_ACCESS
--   DB_UNIQUE_NAME
drop table streams$_pa_database;
create table streams$_pa_database
(
  global_name        varchar2(128) not null,
  last_queried       date default null,
  error_number       number default null,
  error_message      varchar2(4000) default null
)
/

drop table streams$_pa_database_prop;
create table streams$_pa_database_prop
(
  global_name        varchar2(128) not null,
  prop_name          varchar2(30),
  prop_value         varchar2(30)
)
/

drop table streams$_pa_component;
create table streams$_pa_component
(
  component_id       number not null,
  component_name     varchar2(194),
  component_db       varchar2(128),
  component_type     varchar2(20),          /* type of the streams component */
                                                     /*              CAPTURE */
                                                     /*   PROPAGATION SENDER */
                                                     /* PROPAGATION RECEIVER */
                                                     /*                APPLY */
                                                     /*                QUEUE */
  component_changed_time date,   /* time that the component was last changed */
  spare1             number,                               /* spare column 1 */
  spare2             number,                               /* spare column 2 */
  spare3             varchar2(4000),                       /* spare column 3 */
  spare4             date                                  /* spare column 4 */
)
/

-- PROP_NAME: (CAPTURE) SOURCE_DATABASE, PARALLELISM, OPTIMIZATION_MODE
--            ( APPLY ) SOURCE_DATABASE, PARALLELISM, APPLY_CAPTURED,
--                      MESSAGE_DELIVERY_MODE
drop table streams$_pa_component_prop;
create table streams$_pa_component_prop
(
  component_id   number not null,                     /* id of the component */
  prop_name      varchar2(30),                       /* name of the property */
  prop_value     varchar2(4000),                    /* value of the property */
  spare1         number,
  spare2         number,
  spare3         varchar2(4000),
  spare4         date
)
/

drop table streams$_pa_component_link;
create table streams$_pa_component_link
(
  path_id             number not null,
  path_key            varchar2(4000),           /* unique key to stream path */
  source_component_id number not null,
  destination_component_id number not null,
  position            number, /* 1-based position of the link on stream path */
  spare1              number,                              /* spare column 1 */
  spare2              number,                              /* spare column 2 */
  spare3              varchar2(4000),                      /* spare column 3 */
  spare4              date                                 /* spare column 4 */
)
/

-- PARAM_NAME:
--   INTERVAL (default 60 seconds)
--   RETENTION_TIME (default 24 hours)
--   TOP_EVENT_THRESHOLD (default 15)
--   BOTTLENECK_IDLE_THRESHOLD (default 50)
--   BOTTLENECK_FLOWCTRL_THRESHOLD (default 50)

drop table streams$_pa_control;
create table streams$_pa_control
(
  advisor_run_id     number,        /* 1-based logical number of advisor run */
  advisor_run_time   date,                  /* time that the advisor was run */
  param_name         varchar2(30),
  param_value        varchar2(4000),
  param_unit         varchar2(30),
  spare1             number,                               /* spare column 1 */
  spare2             number,                               /* spare column 2 */
  spare3             varchar2(4000),                       /* spare column 3 */
  spare4             date                                  /* spare column 4 */
)
/

drop table streams$_pa_component_stat;
create table streams$_pa_component_stat
(
  advisor_run_id   number,          /* 1-based logical number of advisor run */
  advisor_run_time date,                    /* time that the advisor was run */
  component_id     number,                            /* id of the component */
  statistic_time   date,                /* time that the statistic was taken */
  statistic_name   varchar2(64),  /* name of the statistic. arbitrary length */
  statistic_value  number,                         /* value of the statistic */
  statistic_unit   varchar2(64),  /* unit of the statistic. arbitrary length */
  sub_component_type varchar2(64) default null,     /* type of sub-component */
  session_id       number default null,                 /* id of the session */
  session_serial#  number default null,            /* serial# of the session */
  spare1           number,
  spare2           number,
  spare3           varchar2(4000),
  spare4           date
)
/

-- statistic_name: LATENCY
--                 THROUGHPUT

/* APPLY_DATABASE_TIMESTAMP is stored as statistic */
drop table streams$_pa_path_stat;
create table streams$_pa_path_stat
(
  advisor_run_id   number,          /* 1-based logical number of advisor run */
  advisor_run_time date,                    /* time that the advisor was run */
  path_id          number,                                  /* id the stream */
  path_key         varchar2(4000),              /* unique key to stream path */
  statistic_time   date,                /* time that the statistic was taken */
  statistic_name   varchar2(64),  /* name of the statistic. arbitrary length */
  statistic_value  number,                         /* value of the statistic */
  statistic_unit   varchar2(64),  /* unit of the statistic. arbitrary length */
  spare1           number,
  spare2           number,
  spare3           varchar2(4000),
  spare4           date
)
/

drop table streams$_pa_path_bottleneck;
create table streams$_pa_path_bottleneck
(
  advisor_run_id      number,       /* 1-based logical number of advisor run */
  advisor_run_time    date,                 /* time that the advisor was run */
  advisor_run_reason  varchar2(4000),       /* reason for bottleneck results */
  path_id             number,                               /* id the stream */
  path_key            varchar2(4000),           /* unique key to stream path */
  component_id        number,                         /* id of the component */
  top_session_id      number,             /* top session id of the component */
  top_session_serial# number,  /* top session serial number of the component */
  action_name         varchar2(32),   /* the action name for the top session */
  bottleneck_identified varchar2(30),   /* whether bottleneck was identified */
  spare1              number,
  spare2              number,
  spare3              varchar2(4000),
  spare4              date
)
/

drop table streams$_pa_show_comp_stat;
create table streams$_pa_show_comp_stat(
  advisor_run_id     number,
  advisor_run_time   date,
  path_id            number,
  position           number,
  component_id       number,
  component_name     varchar2(194),
  component_type     varchar2(30),
  sub_component_type varchar2(30),
  session_id         number,
  session_serial#    number,
  statistic_alias    varchar2(30),
  statistic_name     varchar2(128),
  statistic_value    number,
  statistic_unit     varchar2(128)
)
/

CREATE INDEX comp_stat_pkey ON streams$_pa_show_comp_stat
                               (advisor_run_id, path_id, position, 
                                statistic_alias)
/

drop table streams$_pa_show_path_stat;
create table streams$_pa_show_path_stat(
  path_id            number,
  advisor_run_id     number,
  advisor_run_time   date,  
  setting            varchar2(2000),
  statistics         varchar2(4000),
  session_statistics varchar2(4000),
  optimization       number
)
/


-- Streams Performance Advisor Utility Package.
create or replace package UTL_SPADV authid current_user as
  -- Package version
  VERSION CONSTANT VARCHAR2(30) := '2.0';

  ----------------------------------------------------------------------------=
  -- SHOW_STATS
  --   Print statistics for a stream path.
  ----------------------------------------------------------------------------=
  procedure SHOW_STATS(
    path_stat_table   in varchar2 default 'STREAMS$_ADVISOR_PATH_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10,
    show_path_id      in boolean  default TRUE,
    show_run_id       in boolean  default TRUE,
    show_run_time     in boolean  default TRUE,
    show_optimization in boolean  default TRUE,
    show_setting      in boolean  default FALSE,
    show_stat         in boolean  default TRUE,
    show_sess         in boolean  default FALSE,
    show_legend       in boolean  default TRUE);

  ----------------------------------------------------------------------------=
  -- COLLECT_STATS
  --   Collect statistics for all active stream paths.
  ----------------------------------------------------------------------------=
  procedure COLLECT_STATS(
    interval                  in number   default 60,
    num_runs                  in number   default 10,
    comp_stat_table           in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_stat_table           in varchar2 default 'STREAMS$_ADVISOR_PATH_STAT',
    top_event_threshold       in number   default 15,
    bottleneck_idle_threshold in number   default 50,
    bottleneck_flowctrl_threshold in number default 50);

  ----------------------------------------------------------------------------=
  -- IS_MONITORING
  --   Checks if a client has submitted a monitoring job.
  --
  ----------------------------------------------------------------------------=
  function IS_MONITORING(
    job_name    IN VARCHAR2 DEFAULT 'STREAMS$_MONITORING_JOB',
    client_name IN VARCHAR2 DEFAULT NULL) return BOOLEAN;

  ----------------------------------------------------------------------------=
  -- START_MONITORING
  --   Begins persistent monitoring of Streams performance.
  --   Allows (1) at most one monitoring job per schema, and
  --          (2) at most one EM monitoring job per database.
  --
  -- Currently we require the following from the invoking user:
  -- 1. Database links to all participating Streams databases
  -- 2. Privilege to run the analyze_current_performance
  -- 3. Enough space to store monitoring results in tables
  -- 4. Privilege to create a job
  -- 
  -- Parameters:
  --   job_name:         The name of the job to create.
  --   client_name:      The name of the client
  --   query_user_name:  Privileges will be granted to this user to query 
  --                     the result tables.
  --   interval:         The frequency of monitoring in seconds, up to a 
  --                     maximum of 3600 seconds. 
  --   top_event_threshold:
  --                     The percentage of time over which an
  --                     event will be classified as a top event.
  --   bottleneck_idle_threshold:
  --   bottleneck_flowctrl_threshold:
  --                     The thresholds above which a given compenent
  --                     will not be considered a bottleneck.
  --   retention_time:   The number of hours to persist results.
  --
  -- Errors:
  --   ORA-XXXXX:        Monitoring already started. If for example you want 
  --                     to change the user that is monitoring, first call 
  --                     stop_monitoring, then call start_monitoring with 
  --                     the new user name.
  --   ORA-20111:
  --     'cannot start monitoring due to active EM monitoring job'
  --   ORA-20112:
  --     'cannot start monitoring due to active Streams monitoring job'
  --
  procedure START_MONITORING(
    job_name                     IN VARCHAR2 DEFAULT 'STREAMS$_MONITORING_JOB',
    client_name                  IN VARCHAR2 DEFAULT NULL,
    query_user_name              IN VARCHAR2 DEFAULT NULL,
    interval                     IN NUMBER DEFAULT 60,
    top_event_threshold          IN NUMBER DEFAULT 15,
    bottleneck_idle_threshold    IN NUMBER DEFAULT 50,
    bottleneck_flowctrl_threshold IN NUMBER DEFAULT 50,
    retention_time                IN NUMBER DEFAULT 24);

  ----------------------------------------------------------------------------=
  -- ALTER_MONITORING
  --   Alters monitoring of Streams performance
  --
  -- Parameters:
  --   interval:         The frequency of monitoring in seconds, up to a 
  --                     maximum of 3600 seconds. 
  --   top_event_threshold:  
  --                     The percentage of time over which an
  --                     event will be classified as a top event. 
  --   bottleneck_idle_threshold:  
  --   bottleneck_flowctrl_threshold:  
  --                     The thresholds above which a given compenent
  --                     will not be considered a bottleneck.
  --   retention_time:   The number of hours to persist results. 
  --
  -- Errors:
  --   ORA-20113: 'no active monitoring job found'
  --
  procedure ALTER_MONITORING(
    interval                      IN NUMBER DEFAULT null,
    top_event_threshold           IN NUMBER DEFAULT null,
    bottleneck_idle_threshold     IN NUMBER DEFAULT null,
    bottleneck_flowctrl_threshold IN NUMBER DEFAULT null,
    retention_time                IN NUMBER DEFAULT null);

  ----------------------------------------------------------------------------=
  -- STOP_MONITORING
  --   Stops persistent monitoring of Streams performance.
  --
  -- Parameters:
  --   purge:      Whether or not to purge monitoring results from disk
  --
  -- Returns:
  --   TRUE if monitoring has been enabled, false otherwise
  --
  -- Errors:
  --   ORA-20113: 'no active monitoring job found'
  procedure STOP_MONITORING(purge IN BOOLEAN DEFAULT FALSE);

  ----------------------------------------------------------------------------=
  -- SHOW_STATS_HTML
  --    generates a html report of the streams performance statistics 
  --    collected using collect_stats
  --
  -- Parameters :
  --   directory       :   directory object name to place the html report
  --   reportName      :   name of the report file to be generated
  --   comp_stat_table :   the comp_stat_tbl used in the previous call to
  --                       collect_stats
  --   path_id         :   path for which statistics needs to be generated
  --   bgn_run_id      :   start run id to generate statistics
  --   end_run_id      :   end run id to generate statistics
  --   detailed        :   TRUE generates run level/ component level 
  --                       statistics also
  --   Print statistics for a stream path.
  ----------------------------------------------------------------------------=
  procedure SHOW_STATS_HTML(
    directory         in varchar2,
    reportName        in varchar2 default 'SPADVREPORT.HTML',
    comp_stat_table   in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10,
    detailed          in boolean  default TRUE
    );

end UTL_SPADV;
/
show errors;


create or replace package body UTL_SPADV as

  -- Constants about date, time
  minutes_per_day  CONSTANT NUMBER := 1440;
  seconds_per_day  CONSTANT NUMBER := 86400;
  seconds_per_hour CONSTANT NUMBER := 3600;

  -- Streams Advisor control parameters
  param_interval               NUMBER := 60;  -- in seconds
  param_retention_time         NUMBER := 24;  -- in hours
  param_top_event_threshold    NUMBER := 15;
  param_bot_idle_threshold     NUMBER := 50;
  param_bot_flowctrl_threshold NUMBER := 50;
  total_param_cnt              NUMBER := 5;

  monitoring_job_name        VARCHAR2(30) := null;
  monitoring_client_name     VARCHAR2(30) := null;
  monitoring_query_user_name VARCHAR2(30) := null;
  monitoring_started_time    TIMESTAMP    := null;
  -- Timestamp that the monitoring job was last altered
  monitoring_altered_time    TIMESTAMP    := null;

  ----------------------------------------------------------------------------=
  -- The STATISTIC_ALIAS in STAT_TYPE and STREAMS$_ADVISOR_COMP_STAT can have
  -- the following values: 'S1', 'S2', 'S3', 'S4', 'S5', 'S6' and 'S7'. These
  -- numbered values are sorted to order stream component statistics into the
  -- single-line representation.
  --
  -- CAPTURE:
  --   'S1'   <msgs captured/sec>                                 CAPTURE RATE
  --   'S2'   <msgs enqueued/sec>                                 ENQUEUE RATE
  --   'S3'   <latency>                                                LATENCY
  --
  -- CAPTURE SUB-COMPONENT LEVEL:
  --   'S4'   <LMP parallelism>
  --   'S5'   <idl%>                                                      IDLE
  --   'S6'   <flwctrl%>                                          FLOW CONTROL
  --   'S7'   <topevt%>                                               EVENT: %
  --
  -- PROPAGATION SENDER:
  --   'S1'   <msgs sent/sec>                                        SEND RATE
  --   'S2'   <bytes sent/sec>                                       BANDWIDTH
  --   'S3'   <latency>                                                LATENCY
  --   'S4'   NA
  --   'S5'   <idl%>                                                      IDLE
  --   'S6'   <flwctrl%>                                          FLOW CONTROL
  --   'S7'   <topevt%>                                               EVENT: %
  --
  -- PROPAGATION RECEIVER:
  --   'S5'   <idl%>                                                      IDLE
  --   'S6'   <flwctrl%>                                          FLOW CONTROL
  --   'S7'   <topevt%>                                               EVENT: %
  --
  -- QUEUE:
  --   'S1'   <msgs enqueued/sec>                                 ENQUEUE RATE
  --   'S2'   <msgs spilled/sec>                                    SPILL RATE
  --   'S3'   <msgs in queue>                               CURRENT QUEUE SIZE
  --
  -- APPLY:
  --   'S1'   <msgs applied/sec>                            MESSAGE APPLY RATE
  --   'S2'   <txns applied/sec>                        TRANSACTION APPLY RATE
  --   'S3'   <latency>                                                LATENCY
  --
  -- APPLY SUB-COMPONENT LEVEL:
  --   'S4'   <APS parallelism>
  --   'S5'   <idl%>                                                      IDLE
  --   'S6'   <flwctrl%>                                          FLOW CONTROL
  --   'S7'   <topevt%>                                               EVENT: %
  ----------------------------------------------------------------------------=

  -- Record type for component statistic
  TYPE STAT_TYPE IS RECORD (
         advisor_run_id     number        default 0,
         advisor_run_time   date          default SYSDATE,
         path_id            number        default 0,
         position           number        default 0,
         component_id       number        default 0,
         component_name     varchar2(194),
         component_type     varchar2(30),
         sub_component_type varchar2(30),
         session_id         number,
         session_serial#    number,
         statistic_alias    varchar2(30)  default 'UNKNOWN',
         statistic_name     varchar2(128) default 'UNKNOWN',
         statistic_value    number        default 0,
         statistic_unit     varchar2(128));

  -- Stores a statistic name and value pair
  TYPE STAT_PAIR is Record(
   stat_name     varchar2(128) default 'UNKNOWN',
   stat_value    number        default -1);

  ----------------------------------------------------------------------------=
  -- get_acronym
  --   generates the component acronyms for the html report
  --  NOTE: keep in sync with component/subcomponent types listed in catsadv
  ----------------------------------------------------------------------------=
  function get_acronym(
    type in varchar2,
    subtype in varchar2 default ''
  ) 
  return varchar2 as
  begin
    if type = 'PROPAGATION SENDER' then
      return 'PS';
    elsif type = 'PROPAGATION RECEIVER' then
      return 'PR';
    elsif type = 'QUEUE' then
      return 'Q';
    elsif subtype = 'LOGMINER READER' then
      return 'LMR';
    elsif subtype = 'LOGMINER PREPARER' then
      return 'LMP';
    elsif subtype = 'LOGMINER BUILDER' then
      return 'LMB';
    elsif subtype = 'APPLY READER' then
      return 'APR';
    elsif subtype = 'APPLY COORDINATOR' then
      return 'APC';
    elsif subtype = 'APPLY SERVER' then
      return 'APS';
    elsif subtype = 'CAPTURE SESSION' then
      return 'CP';
    elsif subtype = 'PROPAGATION SENDER+RECEIVER' then
      return 'PS+PR';
    elsif type = 'CAPTURE' then
      return 'CAPTURE';
    elsif type = 'APPLY' then
      return 'APPLY';
    else
      return type || ' ' || subtype;
    end if;
  end get_acronym;

  ----------------------------------------------------------------------------=
  -- get_component_db
  --   provides component db name given a component id
  ----------------------------------------------------------------------------=
  function get_component_db (
    componentID in number
  )
  return varchar2 
  is
   compDB varchar2(128);
  begin
    begin
      select component_db into compDB from streams$_pa_component
        where component_id = componentID;
    exception when others then
      compDB := ' ';
    end;
    return compDB;
  end get_component_db;

  ----------------------------------------------------------------------------=
  -- check_report_directory
  --   provides component db name given a component id
  ----------------------------------------------------------------------------=
  function check_report_directory (
    dir in varchar2
  )
  return boolean
  is
   cnt number;
  begin
    cnt := 0;
    begin
      select count(*) into cnt from all_directories 
        where directory_name = dir;
    exception when others then
      return FALSE;
    end;

    if cnt > 0 then
      return TRUE;
    else 
      return FALSE;
    end if;

  end check_report_directory;

   ----------------------------------------------------------------------------=
  -- get_statistic_by_position
  --   Retrieve the statistis for a path and run based on component position
  ----------------------------------------------------------------------------=
  function get_statistic_by_position (
    comp_stat_table in varchar2,
    alias in varchar2,
    path_id in number,
    run_id in number,
    position in number,
    indexName in varchar2
  )
  return STAT_PAIR
  is 
    type cur_type is ref cursor;
    stat_cur cur_type;
    stat STAT_PAIR;
    sel_cursor   NUMBER;
    sel_stmt varchar2(4000);
    numRows number;
  begin
    
    sel_stmt := 'select /*+ INDEX(' || comp_stat_table || ' ' || 
                              indexName || ') */ ' ||
                             'statistic_name, statistic_value from ' ||
                              comp_stat_table || 
                              ' where statistic_alias = :alias' ||
                              ' and advisor_run_id = :run_id ' ||
                              ' and path_id = :path_id ' ||
                              ' and position = :position ' ||
                              ' and session_id is null  ' || 
                              ' and session_serial# is null';

    sel_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(sel_cursor, sel_stmt, dbms_sql.native);
    dbms_sql.bind_variable(sel_cursor, ':alias', alias);
    dbms_sql.bind_variable(sel_cursor, ':run_id', run_id);
    dbms_sql.bind_variable(sel_cursor, ':path_id', path_id);
    dbms_sql.bind_variable(sel_cursor, ':position', position);

    dbms_sql.define_column(sel_cursor, 1, stat.stat_name, 128);
    dbms_sql.define_column(sel_cursor, 2, stat.stat_value);

    numRows := dbms_sql.execute_and_fetch(sel_cursor);
    if numRows > 0 then
      dbms_sql.column_value(sel_cursor, 1, stat.stat_name);
      dbms_sql.column_value(sel_cursor, 2, stat.stat_value);
    else
      stat.stat_name :=  null;
      stat.stat_value := -1;
    end if;
    dbms_sql.close_cursor(sel_cursor);

    return stat;
  end get_statistic_by_position;

  ----------------------------------------------------------------------------=
  -- get_statistic_by_component
  --   Retrieve statistics of a path and run based on the component type
  ----------------------------------------------------------------------------=

  function get_statistic_by_component(
    comp_stat_table in varchar2,
    alias in varchar2,
    path_id in number,
    run_id in number,
    comp_type in varchar2,
    comp_stype in varchar2
  )
  return STAT_PAIR
  is 
    type cur_type is ref cursor;
    stat_cur cur_type;
    stat STAT_PAIR;
    comp_acronym varchar2(20);
    sel_cursor   NUMBER;
    sel_stmt varchar2(4000);
    numRows number;
  begin
    
    comp_acronym := get_acronym(comp_type,comp_stype);
    sel_stmt := 'select statistic_name, statistic_value from ' ||
                              comp_stat_table || 
                              ' where statistic_alias = :alias ' ||
                              ' and advisor_run_id = :run_id ' ||
                              ' and path_id = :path_id ' ||   
                              ' and component_type = :comp_type' ||
                              case when comp_acronym = 'PS' 
                                        or comp_acronym ='PR'
                                        or comp_stype is null
                                then ' and sub_component_type is null'
                                else 
                                     ' and sub_component_type = ''' ||
                                     comp_stype || ''''
                              end ||
                              ' and session_id is null  ' || 
                              ' and session_serial# is null';

    sel_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(sel_cursor, sel_stmt, dbms_sql.native);
    dbms_sql.bind_variable(sel_cursor, ':alias', alias);
    dbms_sql.bind_variable(sel_cursor, ':run_id', run_id);
    dbms_sql.bind_variable(sel_cursor, ':path_id', path_id);
    dbms_sql.bind_variable(sel_cursor, ':comp_type', comp_type);

    dbms_sql.define_column(sel_cursor, 1, stat.stat_name, 128);
    dbms_sql.define_column(sel_cursor, 2, stat.stat_value);

    numRows := dbms_sql.execute_and_fetch(sel_cursor);
    if numRows > 0 then
      dbms_sql.column_value(sel_cursor, 1, stat.stat_name);
      dbms_sql.column_value(sel_cursor, 2, stat.stat_value);
    else
      stat.stat_name :=  null;
      stat.stat_value := -1;
    end if;
    dbms_sql.close_cursor(sel_cursor);

    return stat;
  end get_statistic_by_component;


  ----------------------------------------------------------------------------=
  -- get_avg_statistic_by_component
  --   Retrieves the avg value of statistic across runs for a given path 
  --   and component type
  ----------------------------------------------------------------------------=
  function get_avg_statistic_by_component(
    comp_stat_table in varchar2,
    alias in varchar2,
    path_id in number,
    bgn_run_id in number,
    end_run_id in number,
    comp_type in varchar2,
    comp_stype in varchar2
  )
  return number
  is 
    type cur_type is ref cursor;
    stat_cur cur_type;
    statistic number;
    comp_acronym varchar2(20);
    sel_cursor   NUMBER;
    sel_stmt varchar2(4000);
    numRows number;
  begin
    
    comp_acronym := get_acronym(comp_type,comp_stype);
    sel_stmt := 'select avg(statistic_value) from ' ||
                              comp_stat_table || 
                              ' where statistic_alias = :alias' ||
                              ' and path_id = :path_id ' ||   
                              ' and advisor_run_id <= :end_run_id '||
                              ' and advisor_run_id >= :bgn_run_id ' ||
                              ' and component_type = :comp_type ' ||
                              case when comp_acronym = 'PS' 
                                        or comp_acronym ='PR'
                                        or comp_stype is null
                                then ' and sub_component_type is null'
                                else ' and sub_component_type = ''' || 
                                     comp_stype || ''''
                              end ||
                              ' and session_id is null  ' || 
                              ' and session_serial# is null';

    sel_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(sel_cursor, sel_stmt, dbms_sql.native);
    dbms_sql.bind_variable(sel_cursor, ':alias', alias);
    dbms_sql.bind_variable(sel_cursor, ':end_run_id', end_run_id);
    dbms_sql.bind_variable(sel_cursor, ':path_id', path_id);
    dbms_sql.bind_variable(sel_cursor, ':comp_type', comp_type);
    dbms_sql.bind_variable(sel_cursor, ':bgn_run_id', bgn_run_id);

    dbms_sql.define_column(sel_cursor, 1, statistic);

    numRows := dbms_sql.execute_and_fetch(sel_cursor);
    if numRows > 0 then
      dbms_sql.column_value(sel_cursor, 1, statistic);
    else
      statistic := -1;
    end if;
    dbms_sql.close_cursor(sel_cursor);

    return statistic;
  end get_avg_statistic_by_component;

  ----------------------------------------------------------------------------=
  -- GET_RUN_TIME
  -- gets the run time for a run
  ----------------------------------------------------------------------------=
  function GET_RUN_TIME (
  comp_stat_table in varchar2,
  indexName in varchar2,
  run_id in number,
  path_id in number
  )
  return varchar2 as
    runTime varchar2(50);
    sel_cursor   NUMBER;
    sel_stmt varchar2(4000);
    numRows number;
  begin
    sel_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                indexName || ') */ ' ||
                'distinct ' || 
                'to_char(advisor_run_time,''DD-MON-YYYY HH24:MI:SS'') ' ||
                ' from ' || comp_stat_table || 
                ' where advisor_run_id = :run_id ' ||
                ' and path_id = :path_id ';
    sel_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(sel_cursor, sel_stmt, dbms_sql.native);
    dbms_sql.bind_variable(sel_cursor, ':path_id', path_id);
    dbms_sql.bind_variable(sel_cursor, ':run_id', run_id);

    dbms_sql.define_column(sel_cursor, 1, runTime, 50);

    numRows := dbms_sql.execute_and_fetch(sel_cursor);
    if numRows > 0 then
      dbms_sql.column_value(sel_cursor, 1, runTime);
    else
      runTime := '';
    end if;
    dbms_sql.close_cursor(sel_cursor);
    return runTime;
  end GET_RUN_TIME;

  ----------------------------------------------------------------------------=
  -- GET_BOTTLENECK_HTML
  --   Get bottleneck information in the following form:
  --      advisor_run_reason
  --   OR
  --      component_acronym topevent% "topevent"
  ----------------------------------------------------------------------------=
  function GET_BOTTLENECK_HTML(run_id in number, path_id in number)
  return varchar2 as
    val  varchar2(4000) := null; 
    val2 varchar2(4000) := null;
    bott DBA_STREAMS_TP_COMPONENT_STAT%ROWTYPE;
  begin
    begin
      for bott in (
        select distinct S.*
        from dba_streams_tp_path_bottleneck B,
           ( select distinct *
             from dba_streams_tp_component_stat
             where statistic_name LIKE 'EVENT: %' and
                   session_id is not null and
                   session_serial# is not null and
                   advisor_run_id = GET_BOTTLENECK_HTML.run_id ) S
        where B.path_id = GET_BOTTLENECK_HTML.path_id and
              B.advisor_run_id = GET_BOTTLENECK_HTML.run_id and
              B.top_session_id is not null and
              B.top_session_serial# is not null and
              B.bottleneck_identified = 'YES' and
              B.advisor_run_id = S.advisor_run_id (+) and
              B.component_id = S.component_id (+) and
              B.top_session_id = S.session_id (+) and
              B.top_session_serial# = S.session_serial# (+)
        order by S.statistic_value desc)
      loop
        val := ' ' || get_acronym(bott.component_type, bott.sub_component_type) 
               ||' '|| to_char(bott.statistic_value, 'FM999D9') || '% "' ||
               regexp_replace(bott.statistic_name, '^EVENT: ', NULL) || '"';
        exit when val is not null;
      end loop;

      if val is null then
        -- post process for XStream Bottleneck in case 'EXTERNAL' is 
        -- the bottleneck. In this case, bottleneck_identified is set to 'YES'
        -- but component id/session_id/session_serial will all be NULL and will
        -- not be covered by previous step. 
        select '"EXTERNAL"' into val2
        from dba_streams_tp_path_bottleneck
        where advisor_run_id = GET_BOTTLENECK_HTML.run_id AND
              path_id = GET_BOTTLENECK_HTML.path_id AND
              action_name = 'EXTERNAL' AND
              bottleneck_identified = 'YES';
        
        if val2 is not null then
          val := val2;
        else
          select distinct ' "' || advisor_run_reason || '"' into val
          from dba_streams_tp_path_bottleneck B
          where B.path_id = GET_BOTTLENECK_HTML.path_id and
                B.advisor_run_id = GET_BOTTLENECK_HTML.run_id;
        end if;
      end if;

    exception when others then
       val := '' || 'NO BOTTLENECK IDENTIFIED';
    end;

    return val;
  end GET_BOTTLENECK_HTML;

  ----------------------------------------------------------------------------=
  -- get_bottleneck_percent
  --   returns the % of time a component was the bottleneck within some
  --   run id range
  ----------------------------------------------------------------------------=
  function get_bottleneck_percent(
    comp_acronym in varchar2,
    path_id number,
    bgn_run_id number,
    end_run_id number
  )
  return number
  is
    type cur_type is ref cursor;
    bottleneck_cur cur_type;
    bcount number;
    run_id number;
    bottleneckInfo varchar2(4000);
  begin
    
    bcount  := 0.0;
    for run_id in bgn_run_id .. end_run_id loop
        -- get the bottleneck info we wrote earlier
        open bottleneck_cur for 'select B.spare3 from ' || 
                                ' streams$_pa_path_bottleneck B' ||
                                ' where  B.advisor_run_id =' ||  run_id || 
                                ' and  B.path_id = ' || path_id;
        loop
          fetch bottleneck_cur into bottleneckInfo;
          exit when bottleneck_cur%notfound;

          if bottleneckInfo like '%'|| comp_acronym ||'%' then
            bcount := bcount + 1;
          end if;
          
        end loop;
        close bottleneck_cur;
    end loop;

    return (bcount / (end_run_id - bgn_run_id + 1)) * 100.0;
  end get_bottleneck_percent;


  ----------------------------------------------------------------------------=
  -- JOIN_VALUE
  --   Join values into a list.
  ----------------------------------------------------------------------------=
  function JOIN_VALUE(
    p_cur in sys_refcursor,
    p_del in varchar2 default ' ')
  return varchar2
  is
    l_value   varchar2(32767);
    l_result  varchar2(32767);
  begin
    begin
      loop
        fetch p_cur into l_value;
        exit when p_cur%notfound;
  
        if l_result is not null then
          l_result := l_result || p_del;
        end if;
  
        l_result := l_result || l_value;
      end loop;
      close p_cur;
    exception when others then
     if p_cur%isopen then
       close p_cur;
     end if;
     raise;
    end;

    return l_result;
  end JOIN_VALUE;

  ----------------------------------------------------------------------------=
  -- GET_COMP_TYPEE
  ----------------------------------------------------------------------------=
  function GET_COMP_TYPE(component_type in varchar2)
  return varchar2 is
    val varchar2(10);
  begin
    val := 
      case when component_type = 'CAPTURE'              then '|<C>'
           when component_type = 'APPLY'                then '|<A>'
           when component_type = 'QUEUE'                then '|<Q>'
           when component_type = 'PROPAGATION SENDER'   then '|<PS>'
           when component_type = 'PROPAGATION RECEIVER' then '|<PR>'
           else component_type
      end;

    return val;
  end GET_COMP_TYPE;

  ----------------------------------------------------------------------------=
  -- GET_COMP_NAME
  ----------------------------------------------------------------------------=
  function GET_COMP_NAME(component_type in varchar2,
                         component_name in varchar2)
  return varchar2 is
    val varchar2(194);
  begin
    -- PROPAGATION SENDER:
    --    "src_schema"."src_queue"=>"dst_schema"."dst_queue"@database
    -- changed to:
    --    =>database
    --
    -- PROPAGATION RECEIVER:
    --    "src_schema"."src_queue"@database=>"dst_schema"."dst_queue"
    -- changed to:
    --    database=>
    val := 
      case when component_type = 'PROPAGATION SENDER' then
             regexp_replace(
                regexp_replace(component_name, '^.*=>', '=>'), '^=>.*@', '=>')
           when component_type = 'PROPAGATION RECEIVER' then
             regexp_replace(
                regexp_replace(component_name, '=>.*$', '=>'), '^.*@', null)
           else component_name
      end;

    return val;
  end GET_COMP_NAME;

  ----------------------------------------------------------------------------=
  -- GET_SUB_COMP_TYPE
  ----------------------------------------------------------------------------=
  function GET_SUB_COMP_TYPE(sub_component_type in varchar2)
  return varchar2 is
    val varchar2(10);
  begin
    val :=
      case when sub_component_type = 'LOGMINER READER'        then 'LMR'
           when sub_component_type = 'LOGMINER PREPARER'      then 'LMP'
           when sub_component_type = 'LOGMINER BUILDER'       then 'LMB'
           when sub_component_type = 'CAPTURE SESSION'        then 'CAP'
           when sub_component_type = 'PROPAGATION SENDER+RECEIVER'
                                                              then 'PS+PR'
           when sub_component_type = 'APPLY READER'           then 'APR'
           when sub_component_type = 'APPLY COORDINATOR'      then 'APC'
           when sub_component_type = 'APPLY SERVER'           then 'APS'
           when sub_component_type = 'CAPTURE SESSION + PS'   then 'CAP+PS'
           else sub_component_type
      end;

    return val;
  end GET_SUB_COMP_TYPE;

  ----------------------------------------------------------------------------=
  -- JOIN_STAT
  ----------------------------------------------------------------------------=
  function JOIN_STAT(
    prev                in stat_type,    -- previously joined stat
    curr                in stat_type,    -- current stat to be joined
    top_event_threshold in number default 15,
    is_session_level    in boolean default FALSE)
  return varchar2
  is
    sval varchar2(800);
  begin
    -- Format statistic value
    if (curr.statistic_alias = 'S1' OR
        curr.statistic_alias = 'S2' ) then
      if (curr.statistic_name = 'BANDWIDTH') then
        -- Use scientific representation
        sval := to_char(curr.statistic_value, 'FM9.99EEEE');
      else
        -- Use integer for throughput (S1 and S2)
        if (curr.statistic_value > 10) then
          sval := to_char(curr.statistic_value, 'FM99999999999');
        elsif (curr.statistic_value > 0.01) then
          sval := to_char(curr.statistic_value, 'FM99999999999.99');
        else
          sval := '0.01';
        end if;
      end if;
    elsif (curr.statistic_alias = 'S3') then
      -- S3 is latency (accuracy at one tenth second)
      sval := to_char(curr.statistic_value, 'FM999999999D9');
    elsif (curr.statistic_alias = 'S5' OR
           curr.statistic_alias = 'S6' OR
           curr.statistic_alias = 'S7' ) then
      -- S5 S6 S7 are percentage
      sval := to_char(curr.statistic_value, 'FM99999999D9');
    elsif (curr.statistic_name = 'PARALLELISM') then
      -- Use integer for 'PARALLELISM'
      sval := to_char(curr.statistic_value, 'FM99999999');
    else
      sval := to_char(curr.statistic_value, 'FM999999999D9');
    end if;
  
    if sval is not null then
      sval := regexp_replace(sval, '^\.', '0.');
      sval := regexp_replace(sval, '\.$', null);
    end if;

    -- Add decoration to statistic value
    if (curr.statistic_alias = 'S5' OR
        curr.statistic_alias = 'S6' OR
        curr.statistic_alias = 'S7' ) then
      sval := sval || '%';
    end if;

    -- Show PARALLELISM for LMP and APC 
    if (curr.statistic_name = 'PARALLELISM') then
      sval := '(' || sval || ')';
    end if;

    -- Use prev to determine how to join current stat.
    -- Show TOP EVENT only if it meets the threshold
    if (curr.statistic_alias = 'S7') then
      if (prev.statistic_alias = 'S7' AND
          prev.statistic_value = curr.statistic_value) then
         -- Show only one TOP EVENT
         -- when multiple TOP EVENTs have the same statistic_value
         sval := null;
      else
        if (to_number(curr.statistic_value) > top_event_threshold) then
           sval := sval || ' "' || curr.statistic_name || '"';
        else
           sval := sval || ' ""';
        end if;
      end if;
    end if;

    -- Session-Level STATISTICS
    if is_session_level = TRUE then
      -- Add SESSION_ID and SESSION_SERIAL#
      if (curr.statistic_alias = 'S5') then
        sval := curr.session_id ||' '||
                curr.session_serial# ||' '||
                sval;
      end if;

      -- Add SUB_COMPONENT_TYPE
      if (curr.statistic_alias = 'S5' AND
          curr.component_type in ('CAPTURE', 'APPLY')) then
        sval := get_sub_comp_type(curr.sub_component_type) ||' '||
                sval;
      end if;

    -- Component-Level and Sub-Component-Level STATISTICS
    else
      -- Add SUB_COMPONENT_TYPE
      if (curr.sub_component_type is not null AND
          (prev.sub_component_type is null OR
           prev.sub_component_type != curr.sub_component_type)) then
        sval := get_sub_comp_type(curr.sub_component_type) ||' '|| sval;
      end if;
    end if;

    -- Add COMPONENT_TYPE and COMPONENT_NAME
    if (curr.component_id != prev.component_id) then
      sval := get_comp_type(curr.component_type) ||' '||
              get_comp_name(curr.component_type, curr.component_name) ||' '||
              sval;
    end if;

    return sval;
  end JOIN_STAT;

  ----------------------------------------------------------------------------=
  -- INIT_SPADV_COMP_STAT
  --   Create a table (default STREAMS$_ADVISOR_COMP_STAT) for comp statistics.
  ----------------------------------------------------------------------------=
  function INIT_SPADV_COMP_STAT(
    output_table in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT'
  ) return varchar2 as
    stmt     varchar2(4000) := null;
    indStmt  varchar2(4000) := null;
    tbl_name varchar2(30)   := null;
    tbl_desc varchar2(4000) := null;
    tbl_sign varchar2(1000) :=
      '1 ADVISOR_RUN_ID NUMBER 2 ADVISOR_RUN_TIME DATE ' ||
      '3 PATH_ID NUMBER 4 POSITION NUMBER ' ||
      '5 COMPONENT_ID NUMBER 6 COMPONENT_NAME VARCHAR2 ' ||
      '7 COMPONENT_TYPE VARCHAR2 8 SUB_COMPONENT_TYPE VARCHAR2 ' ||
      '9 SESSION_ID NUMBER 10 SESSION_SERIAL# NUMBER '||
      '11 STATISTIC_ALIAS VARCHAR2 12 STATISTIC_NAME VARCHAR2 ' ||
      '13 STATISTIC_VALUE NUMBER 14 STATISTIC_UNIT VARCHAR2';

    cur sys_refcursor;
    tbl_exception exception;
    PRAGMA EXCEPTION_INIT(tbl_exception, -955);
  begin
    if output_table is not null then
      tbl_name := dbms_assert.qualified_sql_name(output_table);
    else
      tbl_name := 'STREAMS$_ADVISOR_COMP_STAT';
    end if;
    tbl_name := upper(tbl_name);
  
    stmt := 'create table ' || tbl_name || '(' ||
            ' advisor_run_id     number, '||
            ' advisor_run_time   date, '||
            ' path_id            number, '||
            ' position           number, '||
            ' component_id       number, '||
            ' component_name     varchar2(194), '||
            ' component_type     varchar2(30), '||
            ' sub_component_type varchar2(30), '||
            ' session_id         number, '||
            ' session_serial#    number, '||
            ' statistic_alias    varchar2(30), '||
            ' statistic_name     varchar2(128), '||
            ' statistic_value    number, '||
            ' statistic_unit     varchar2(128))';

    -- create a unique to speed queries up for spadv html report
    indStmt := 'create index '|| tbl_name ||'_pk on ' || tbl_name ||
                ' (advisor_run_id, path_id, position, statistic_alias)';

    begin
      select table_name into tbl_name from user_tables
      where table_name = tbl_name;
    exception when NO_DATA_FOUND then
      execute immediate stmt;
      execute immediate indStmt;
      dbms_output.put_line('create table ' || tbl_name);
    end;
  
    begin
      open cur for
        select column_id || ' ' || column_name || ' ' || data_type
        from user_tab_columns
        where table_name = tbl_name
        order by column_id;

      tbl_desc := join_value(cur, ' ');
    exception when others then
      tbl_desc := 'UNKNOWN';
    end;

    -- Throw exception if the two tables do not have the same shape.
    if tbl_desc != tbl_sign then
      raise tbl_exception;
    end if;
  
    return tbl_name;
  end INIT_SPADV_COMP_STAT;
  
  ----------------------------------------------------------------------------=
  -- CHECK_SPADV_COMP_STAT
  --   Check the table (default STREAMS$_ADVISOR_COMP_STAT)
  ----------------------------------------------------------------------------=
  function CHECK_SPADV_COMP_STAT(
    output_table in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT'
  ) 
  return varchar2 as
    tbl_name varchar2(30)   := null;
    tbl_desc varchar2(4000) := null;
    tbl_sign varchar2(1000) :=
      '1 ADVISOR_RUN_ID NUMBER 2 ADVISOR_RUN_TIME DATE ' ||
      '3 PATH_ID NUMBER 4 POSITION NUMBER ' ||
      '5 COMPONENT_ID NUMBER 6 COMPONENT_NAME VARCHAR2 ' ||
      '7 COMPONENT_TYPE VARCHAR2 8 SUB_COMPONENT_TYPE VARCHAR2 ' ||
      '9 SESSION_ID NUMBER 10 SESSION_SERIAL# NUMBER '||
      '11 STATISTIC_ALIAS VARCHAR2 12 STATISTIC_NAME VARCHAR2 ' ||
      '13 STATISTIC_VALUE NUMBER 14 STATISTIC_UNIT VARCHAR2';
    cur sys_refcursor;
  begin
    if output_table is not null then
      tbl_name := dbms_assert.qualified_sql_name(output_table);
    else
      tbl_name := 'STREAMS$_ADVISOR_COMP_STAT';
    end if;

    tbl_name := upper(tbl_name);
  
    begin
      select table_name into tbl_name from user_tables
      where table_name = tbl_name;
    exception when NO_DATA_FOUND then
      raise_application_error(-20100,
        'Non-existing table ''' || output_table || '''');
    end;
  
    begin
      open cur for
        select column_id || ' ' || column_name || ' ' || data_type
        from user_tab_columns
        where table_name = tbl_name
        order by column_id;

      tbl_desc := join_value(cur, ' ');
    exception when others then
      tbl_desc := 'UNKNOWN';
    end;
  
    if tbl_desc != tbl_sign then
      raise_application_error(-20100,
        'Invalid table ''' || output_table || '''');
    end if;
  
    return tbl_name;
  end CHECK_SPADV_COMP_STAT;

  ----------------------------------------------------------------------------=
  -- INIT_SPADV_PATH_STAT
  --   Create a table (default STREAMS$_ADVISOR_PATH_STAT) for path statistics.
  ----------------------------------------------------------------------------=
  function INIT_SPADV_PATH_STAT(
    output_table in varchar2 default 'STREAMS$_ADVISOR_PATH_STAT'
  ) return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_name varchar2(30)    := null;
    tbl_desc varchar2(4000)  := null;
    tbl_sign varchar2(1000)  :=
      '1 PATH_ID NUMBER 2 ADVISOR_RUN_ID NUMBER 3 ADVISOR_RUN_TIME DATE '
    ||'4 SETTING VARCHAR2 5 STATISTICS VARCHAR2 6 SESSION_STATISTICS VARCHAR2 '
    ||'7 OPTIMIZATION NUMBER';

    cur sys_refcursor;
    tbl_exception exception;
    PRAGMA EXCEPTION_INIT(tbl_exception, -955); 
  begin
    if output_table is not null then
      tbl_name := dbms_assert.qualified_sql_name(output_table);
    else
      tbl_name := 'STREAMS$_ADVISOR_PATH_STAT';
    end if;
    tbl_name := upper(tbl_name);
  
    stmt := 'create table ' || tbl_name || '(' ||
            ' path_id            number, ' ||
            ' advisor_run_id     number, ' ||
            ' advisor_run_time   date,   ' ||
            ' setting            varchar2(2000), ' ||
            ' statistics         varchar2(4000), ' ||
            ' session_statistics varchar2(4000), ' ||
            ' optimization       number)';
  
    begin
      select table_name into tbl_name from user_tables
      where table_name = tbl_name;
    exception when NO_DATA_FOUND then
      execute immediate stmt;
      dbms_output.put_line('create table ' || tbl_name);
    end;
  
    begin
      open cur for
        select column_id || ' ' || column_name || ' ' || data_type
        from user_tab_columns
        where table_name = tbl_name
        order by column_id;

      tbl_desc := join_value(cur, ' ');
    exception when others then
      tbl_desc := 'UNKNOWN';
    end;
  
    -- Throw exception if the two tables do not have the same shape.
    if tbl_desc != tbl_sign then
      raise tbl_exception;
    end if;
  
    return tbl_name;
  end INIT_SPADV_PATH_STAT;
  
  ----------------------------------------------------------------------------=
  -- CHECK_SPADV_PATH_STAT
  --   Check the table (default STREAMS$_ADVISOR_PATH_STAT) for path statistics
  ----------------------------------------------------------------------------=
  function CHECK_SPADV_PATH_STAT(
    output_table in varchar2 default 'STREAMS$_ADVISOR_PATH_STAT'
  ) return varchar2 as
    tbl_name varchar2(30)    := null;
    tbl_desc varchar2(4000)  := null;
    tbl_sign varchar2(1000)  :=
      '1 PATH_ID NUMBER 2 ADVISOR_RUN_ID NUMBER 3 ADVISOR_RUN_TIME DATE '
    ||'4 SETTING VARCHAR2 5 STATISTICS VARCHAR2 6 SESSION_STATISTICS VARCHAR2 '
    ||'7 OPTIMIZATION NUMBER';
    cur sys_refcursor;
  begin
    if output_table is not null then
      tbl_name := dbms_assert.qualified_sql_name(output_table);
    else
      tbl_name := 'STREAMS$_ADVISOR_PATH_STAT';
    end if;
    tbl_name := upper(tbl_name);
  
    begin
      select table_name into tbl_name from user_tables
      where table_name = tbl_name;
    exception when NO_DATA_FOUND then
      raise_application_error(-20100,
        'Non-existing table ''' || output_table || '''');
    end;
  
    begin
      open cur for
        select column_id || ' ' || column_name || ' ' || data_type
        from user_tab_columns
        where table_name = tbl_name
        order by column_id;

      tbl_desc := join_value(cur, ' ');
    exception when others then
      tbl_desc := 'UNKNOWN';
    end;
  
    if tbl_desc != tbl_sign then
      raise_application_error(-20100,
        'Invalid table ''' || output_table || '''');
    end if;
  
    return tbl_name;
  end CHECK_SPADV_PATH_STAT;

  ----------------------------------------------------------------------------=
  -- Init tables required by monitoring API.
  --
  ----------------------------------------------------------------------------=
  function INIT_TBL(tbl_name in varchar2,
                    tbl_sign in varchar2,
                    stmt     in varchar2)
  return varchar2 as
    t_name varchar2(30)   := null;
    t_sign varchar2(4000) := null;
    cur sys_refcursor;
    tbl_exception exception;
    PRAGMA EXCEPTION_INIT(tbl_exception, -955); 
  begin
    begin
      select table_name into t_name from user_tables
      where table_name = tbl_name;
    exception when NO_DATA_FOUND then
      execute immediate stmt;
      dbms_output.put_line('create table ' || tbl_name);
    end;
  
    begin
      open cur for
        select column_id || ' ' || column_name || ' ' || data_type
        from user_tab_columns
        where table_name = tbl_name
        order by column_id;

      t_sign := join_value(cur, ' ');
    exception when others then
      t_sign := 'UNKNOWN';
    end;
  
    -- Throw exception if the two tables do not have the same shape.
    if t_sign != tbl_sign then
      raise tbl_exception;
    end if;
  
    return tbl_name;
  end INIT_TBL;

  function INIT_TBL_PA_MONITORING
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_sign varchar2(1000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_MONITORING';
  begin
    stmt :=
       'create table ' || tbl_name || '(' ||
       ' job_name           varchar2(30) not null, ' ||
       ' client_name        varchar2(30) default null, ' ||
       ' query_user_name    varchar2(30) default null, ' ||
       ' show_stats_table   varchar2(30) default ' ||
                                         '''STREAMS$_PA_SHOW_PATH_STAT'', ' ||
       ' started_time       timestamp default null, ' ||
       ' stopped_time       timestamp default null, ' ||
       ' altered_time       timestamp default null, ' ||
       ' state              varchar2(30) default null)';

    tbl_sign :=
       '1 JOB_NAME VARCHAR2 '||
       '2 CLIENT_NAME VARCHAR2 '||
       '3 QUERY_USER_NAME VARCHAR2 '||
       '4 SHOW_STATS_TABLE VARCHAR2 '||
       '5 STARTED_TIME TIMESTAMP(6) '||
       '6 STOPPED_TIME TIMESTAMP(6) '||
       '7 ALTERED_TIME TIMESTAMP(6) '||
       '8 STATE VARCHAR2';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_MONITORING;

  function INIT_TBL_PA_DATABASE
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_sign varchar2(1000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_DATABASE';
  begin
    stmt :=
      'create table ' || tbl_name || '(' ||
      ' global_name        varchar2(128) not null, ' ||
      ' last_queried       date default null, ' ||
      ' error_number       number default null, ' ||
      ' error_message      varchar2(4000) default null)';

    tbl_sign :=
      '1 GLOBAL_NAME VARCHAR2 '||
      '2 LAST_QUERIED DATE '||
      '3 ERROR_NUMBER NUMBER '||
      '4 ERROR_MESSAGE VARCHAR2';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_DATABASE;

  function INIT_TBL_PA_DATABASE_PROP
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_sign varchar2(1000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_DATABASE_PROP';
  begin
    stmt :=
      'create table ' || tbl_name || '(' ||
      ' global_name        varchar2(128) not null, ' ||
      ' prop_name          varchar2(30), ' ||
      ' prop_value         varchar2(30))';

    tbl_sign :=
      '1 GLOBAL_NAME VARCHAR2 '||
      '2 PROP_NAME VARCHAR2 '||
      '3 PROP_VALUE VARCHAR2';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_DATABASE_PROP;

  function INIT_TBL_PA_COMPONENT
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_sign varchar2(1000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_COMPONENT';
  begin
    stmt :=
      'create table ' || tbl_name || '(' ||
      ' component_id       number not null, ' ||
      ' component_name     varchar2(194), ' ||
      ' component_db       varchar2(128), ' ||
      ' component_type     varchar2(20), ' ||
      ' component_changed_time date, ' ||
      ' spare1             number, ' ||
      ' spare2             number, ' ||
      ' spare3             varchar2(4000), ' ||
      ' spare4             date)';

    tbl_sign :=
       '1 COMPONENT_ID NUMBER '||
       '2 COMPONENT_NAME VARCHAR2 '||
       '3 COMPONENT_DB VARCHAR2 '||
       '4 COMPONENT_TYPE VARCHAR2 '||
       '5 COMPONENT_CHANGED_TIME DATE '||
       '6 SPARE1 NUMBER '||
       '7 SPARE2 NUMBER '||
       '8 SPARE3 VARCHAR2 '||
       '9 SPARE4 DATE';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_COMPONENT;

  function INIT_TBL_PA_COMPONENT_LINK
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_COMPONENT_LINK';
    tbl_sign varchar2(1000)  := null;
  begin
    stmt :=
      'create table ' || tbl_name || '(' ||
      ' path_id             number not null, ' ||
      ' path_key            varchar2(4000), ' ||
      ' source_component_id number not null, ' ||
      ' destination_component_id number not null, ' ||
      ' position            number, ' ||
      ' spare1              number, ' ||
      ' spare2              number, ' ||
      ' spare3              varchar2(4000), ' ||
      ' spare4              date)';

    tbl_sign :=
       '1 PATH_ID NUMBER '||
       '2 PATH_KEY VARCHAR2 '||
       '3 SOURCE_COMPONENT_ID NUMBER '||
       '4 DESTINATION_COMPONENT_ID NUMBER '||
       '5 POSITION NUMBER '||
       '6 SPARE1 NUMBER '||
       '7 SPARE2 NUMBER '||
       '8 SPARE3 VARCHAR2 '||
       '9 SPARE4 DATE';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_COMPONENT_LINK;

  function INIT_TBL_PA_COMPONENT_PROP
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_COMPONENT_PROP';
    tbl_sign varchar2(1000)  := null;
  begin
    stmt :=
      'create table ' || tbl_name || '(' ||
      ' component_id   number not null, ' ||
      ' prop_name      varchar2(30), ' ||
      ' prop_value     varchar2(4000), ' ||
      ' spare1         number, ' ||
      ' spare2         number, ' ||
      ' spare3         varchar2(4000), ' ||
      ' spare4         date)';

    tbl_sign :=
      '1 COMPONENT_ID NUMBER '||
      '2 PROP_NAME VARCHAR2 '||
      '3 PROP_VALUE VARCHAR2 '||
      '4 SPARE1 NUMBER '||
      '5 SPARE2 NUMBER '||
      '6 SPARE3 VARCHAR2 '||
      '7 SPARE4 DATE';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_COMPONENT_PROP;

  function INIT_TBL_PA_CONTROL
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_CONTROL';
    tbl_sign varchar2(1000)  := null;
  begin
    stmt :=
      'create table ' || tbl_name || '(' ||
      ' advisor_run_id     number, '||
      ' advisor_run_time   date, '||
      ' param_name         varchar2(30), '||
      ' param_value        varchar2(4000), '||
      ' param_unit         varchar2(30), '||
      ' spare1             number, '||
      ' spare2             number, '||
      ' spare3             varchar2(4000), '||
      ' spare4             date)';

    tbl_sign :=
      '1 ADVISOR_RUN_ID NUMBER '||
      '2 ADVISOR_RUN_TIME DATE '||
      '3 PARAM_NAME VARCHAR2 '||
      '4 PARAM_VALUE VARCHAR2 '||
      '5 PARAM_UNIT VARCHAR2 '||
      '6 SPARE1 NUMBER '||
      '7 SPARE2 NUMBER '||
      '8 SPARE3 VARCHAR2 '||
      '9 SPARE4 DATE';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_CONTROL;

  function INIT_TBL_PA_COMPONENT_STAT
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_COMPONENT_STAT';
    tbl_sign varchar2(1000)  := null;
  begin
    stmt :=
      'create table ' || tbl_name || '(' ||
      ' advisor_run_id   number, '||
      ' advisor_run_time date, '||
      ' component_id     number, '||
      ' statistic_time   date, '||
      ' statistic_name   varchar2(64), '||
      ' statistic_value  number, '||
      ' statistic_unit   varchar2(64), '||
      ' sub_component_type varchar2(64) default null, '||
      ' session_id       number default null, '||
      ' session_serial#  number default null, '||
      ' spare1           number, '||
      ' spare2           number, '||
      ' spare3           varchar2(4000), '||
      ' spare4           date)';

    tbl_sign :=
      '1 ADVISOR_RUN_ID NUMBER '||
      '2 ADVISOR_RUN_TIME DATE '||
      '3 COMPONENT_ID NUMBER '||
      '4 STATISTIC_TIME DATE '||
      '5 STATISTIC_NAME VARCHAR2 '||
      '6 STATISTIC_VALUE NUMBER '||
      '7 STATISTIC_UNIT VARCHAR2 '||
      '8 SUB_COMPONENT_TYPE VARCHAR2 '||
      '9 SESSION_ID NUMBER '||
      '10 SESSION_SERIAL# NUMBER '||
      '11 SPARE1 NUMBER '||
      '12 SPARE2 NUMBER '||
      '13 SPARE3 VARCHAR2 '||
      '14 SPARE4 DATE';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_COMPONENT_STAT;

  function INIT_TBL_PA_PATH_STAT
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_PATH_STAT';
    tbl_sign varchar2(1000)  := null;
  begin
    stmt :=
      'create table ' || tbl_name || '(' ||
      ' advisor_run_id   number, '||
      ' advisor_run_time date, '||
      ' path_id          number, '||
      ' path_key         varchar2(4000), '||
      ' statistic_time   date, '||
      ' statistic_name   varchar2(64), '||
      ' statistic_value  number, '||
      ' statistic_unit   varchar2(64), '||
      ' spare1           number, '||
      ' spare2           number, '||
      ' spare3           varchar2(4000), '||
      ' spare4           date)';

    tbl_sign :=
      '1 ADVISOR_RUN_ID NUMBER '||
      '2 ADVISOR_RUN_TIME DATE '||
      '3 PATH_ID NUMBER '||
      '4 PATH_KEY VARCHAR2 '||
      '5 STATISTIC_TIME DATE '||
      '6 STATISTIC_NAME VARCHAR2 '||
      '7 STATISTIC_VALUE NUMBER '||
      '8 STATISTIC_UNIT VARCHAR2 '||
      '9 SPARE1 NUMBER '||
      '10 SPARE2 NUMBER '||
      '11 SPARE3 VARCHAR2 '||
      '12 SPARE4 DATE';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_PATH_STAT;

  function INIT_TBL_PA_PATH_BOTTLENECK
  return varchar2 as
    stmt     varchar2(4000)  := null;
    tbl_name varchar2(30)    := 'STREAMS$_PA_PATH_BOTTLENECK';
    tbl_sign varchar2(1000)  := null;
  begin
    stmt :=
      'create table ' || tbl_name || '(' ||
      ' advisor_run_id      number, '||
      ' advisor_run_time    date, '||
      ' advisor_run_reason  varchar2(4000), '||
      ' path_id             number, '||
      ' path_key            varchar2(4000), '||
      ' component_id        number, '||
      ' top_session_id      number, '||
      ' top_session_serial# number, '||
      ' action_name         varchar2(32), '||
      ' bottleneck_identified varchar2(30), '||
      ' spare1              number, '||
      ' spare2              number, '||
      ' spare3              varchar2(4000), '||
      ' spare4              date)';

    tbl_sign :=
      '1 ADVISOR_RUN_ID NUMBER '||
      '2 ADVISOR_RUN_TIME DATE '||
      '3 ADVISOR_RUN_REASON VARCHAR2 '||
      '4 PATH_ID NUMBER '||
      '5 PATH_KEY VARCHAR2 '||
      '6 COMPONENT_ID NUMBER '||
      '7 TOP_SESSION_ID NUMBER '||
      '8 TOP_SESSION_SERIAL# NUMBER '||
      '9 ACTION_NAME VARCHAR2 '||
      '10 BOTTLENECK_IDENTIFIED VARCHAR2 '||
      '11 SPARE1 NUMBER '||
      '12 SPARE2 NUMBER '||
      '13 SPARE3 VARCHAR2 '||
      '14 SPARE4 DATE';

    return INIT_TBL(tbl_name, tbl_sign, stmt);
  end INIT_TBL_PA_PATH_BOTTLENECK;

  function INIT_TBL_PA_SHOW_COMP_STAT
  return varchar2 as
    tbl_name varchar2(30) := 'STREAMS$_PA_SHOW_COMP_STAT';
  begin
    return INIT_SPADV_COMP_STAT(tbl_name);
  end INIT_TBL_PA_SHOW_COMP_STAT;

  function INIT_TBL_PA_SHOW_PATH_STAT
  return varchar2 as
    tbl_name varchar2(30) := 'STREAMS$_PA_SHOW_PATH_STAT';
  begin
    return INIT_SPADV_PATH_STAT(tbl_name);
  end INIT_TBL_PA_SHOW_PATH_STAT;

  ----------------------------------------------------------------------------=
  -- AGGREGATE_TOP_EVENT
  --   Aggregate TOP EVENT statistics for streams subcomponents that include
  --   LOGMINER PREPARER and APPLY SERVER because of parallel sessions. Only
  --   the top three event of each parallel session will be considered.
  --
  --   Return the aggregated TOP EVENT PERCENTAGE over all session of a Streams
  --   sub-component and the TOP EVENT of the sub-component. For example if the
  --   APPLY SERVER has 3 parallel sessions, each having 3 top events:
  --     Session 79  TOP EVENT 1: 'CPU + Wait for CPU'  65
  --                 TOP EVENT 2: 'X'                   20
  --                 TOP EVENT 3: 'Y'                    5
  --
  --     Session 80  TOP EVENT 1: 'CPU + Wait for CPU'  45
  --                 TOP EVENT 2: 'X'                   35
  --                 TOP EVENT 3: 'Y'                   17
  --
  --     Session 81  TOP EVENT 1: 'X'                   40
  --                 TOP EVENT 2: 'CPU + Wait for CPU'  25
  --                 TOP EVENT 3: 'Z'                   25
  --
  --   The aggregated TOP EVENT percentage over the three sessions will be:
  --                 TOP EVENT 1: 'CPU + Wait for CPU'  65+45+25=135
  --                 TOP EVENT 2: 'X'                   20+35+40=95
  --                 TOP EVENT 3: 'Z'                   25
  --                 TOP EVENT 4: 'Y'                   5+17=22
  --
  --   The TOP EVENT of the sub-component is 'CPU + Wait for CPU'. So the
  --   returned value in varchar2 is as follows:
  --     135.0% "CPU + Wait for CPU"
  ----------------------------------------------------------------------------=
  function AGGREGATE_TOP_EVENT(
    run_id   in number,
    comp_id  in number,
    sub_type in varchar2,
    top_event_threshold in number default 15)
  return varchar2 as
    TYPE cur_type is ref cursor;
    stmt       varchar2(4000) := null;
    sval       varchar2(800)  := null;
    stat_cur   cur_type;
    stat_name  dba_streams_tp_component_stat.statistic_name%TYPE := null;
    stat_value dba_streams_tp_component_stat.statistic_value%TYPE := 0;
  begin
    stmt :=
      ' select statistic_name, statistic_value '||
      ' from ( select statistic_name, statistic_value '||
             ' from ( select distinct statistic_name, '||
                           ' SUM(statistic_value) as statistic_value '||
                      ' from dba_streams_tp_component_stat '||
                      ' where statistic_name like ''EVENT:%'' and '||
                            ' session_id is not null and  '||
                            ' session_serial# is not null and '||
                            ' component_id = ' || comp_id || ' and '||
                            ' advisor_run_id = ' || run_id || ' and '||
                            ' sub_component_type = ''' || sub_type || ''' '||
                      ' group by statistic_name ) '||
             ' order by statistic_value DESC, statistic_name ) '||
      ' where rownum = 1';

    begin
      open stat_cur for stmt;
      fetch stat_cur into stat_name, stat_value;
      close stat_cur;
    exception when others then
      if stat_cur%isopen then
        close stat_cur;
      end if;
      raise;
    end;

    -- Represent TOP EVENT in percentage
    sval := to_char(stat_value, 'FM9999D9');
    sval := regexp_replace(sval, '^\.', '0.');
    sval := regexp_replace(sval, '\.$', null);
    sval := sval || '% "' ||
            case when stat_value > top_event_threshold then
                      regexp_replace(stat_name, '^EVENT: ', NULL)
                 else null
            end  || '"';

    return sval;
  end AGGREGATE_TOP_EVENT;

  ----------------------------------------------------------------------------=
  -- PREPARE_CAP_PS
  --   Prepare statistics for 'CAP+PS' which is a capture and also a propagaton
  --   sender in CCA. Note that capture and propagaton sender share the same
  --   session_id and session_serial# in CCA mode.
  --
  -- PREPARE_CAP_PS is for converting the following
  --
  -- |<C> CAPTURE_USER1 2 0 0 0.E+00 LMR 97% 0% 3% "" LMP (1) 99.7% 0% 0.3% ""
  -- LMB 99% 0% 1% "" CAP 99.3% 0% 0.7% "" |<Q> "STRSEEDADM"."STRM_SEED_Q" 0 0
  -- 0 |<PS> =>DBS2.REGRESS.RDBMS.DEV.US.ORACLE.COM 0 0 2 99.3% 0% 0.7% ""
  -- |<PR> DBS1.REGRESS.RDBMS.DEV.US.ORACLE.COM=> 100% 0% 0% "" |<PR> ...
  -- |<C> CAPTURE_USER1 LMR 75 10 97% 0% 3% "" LMP 77 5 99.7% 0% 0.3% ""
  -- LMB 83 7 99% 0% 1% "" CAP 92 7 99.3% 0% 0.7% "" |<PS>
  -- =>DBS2.REGRESS.RDBMS.DEV.US.ORACLE.COM 92 7 99.3% 0% 0.7% "" |<PR> ...
  --
  -- TO
  --
  -- |<C> CAPTURE_USER1=>DBS2.REGRESS.RDBMS.DEV.US.ORACLE.COM 2 0 0 0.E+00
  -- LMR 97% 0% 3% "" LMP (1) 99.7% 0% 0.3% "" LMB 99% 0% 1% "" CAP+PS 0 0 2
  -- 99.3% 0% 0.7% "" |<PR> ...
  -- |<C> CAPTURE_USER1=>DBS2.REGRESS.RDBMS.DEV.US.ORACLE.COM
  -- LMR 75 10 97% 0% 3% "" LMP 77 5 99.7% 0% 0.3% "" LMB 83 7 99% 0% 1% ""
  -- CAP+PS 92 7 99.3% 0% 0.7% "" |<PR> ...
  --
  ----------------------------------------------------------------------------=
  procedure PREPARE_CAP_PS(
    run_id   in number,
    tbl_name in varchar2) as
    TYPE cur_type is ref cursor;
    s_cur    cur_type;
    s_rec    stat_type;
    stmt1    varchar2(4000) := null;
    stmt2    varchar2(4000) := null;
  begin

    -- Find 'CAPTURE SESSION' sharing the same path_id and
    -- the same session_id/serial# with 'PROPAGATON SENDER'
    stmt1 :=
     ' select A.advisor_run_id, '||
            ' A.advisor_run_time, '||
            ' A.path_id, '||
            ' A.position, '||
            ' A.component_id, '||
            ' (A.component_name || '||
            '  regexp_replace( '||
            '    regexp_replace(B.component_name, ''^.*=>'', ''=>''), '||
            '    ''^=>.*@'', ''=>'') ), '||
            ' A.component_type, '||
            ' A.sub_component_type, '||
            ' A.session_id, '||
            ' A.session_serial#, '||
            ' A.statistic_alias, '||
            ' A.statistic_name, '||
            ' A.statistic_value, '||
            ' A.statistic_unit '||
     ' from ' || tbl_name || ' A, ' || tbl_name || ' B '||
     ' where A.component_type = ''CAPTURE'' '||
       ' and A.sub_component_type = ''CAPTURE SESSION'' '||
       -- statistic IDLE is guaranteed by performance advisor
       ' and A.statistic_name = ''IDLE'' '||
       ' and B.component_type = ''PROPAGATION SENDER'' '||
       ' and B.sub_component_type is null '||
       -- statistic IDLE is guaranteed by performance advisor
       ' and B.statistic_name = ''IDLE'' '||
       ' and A.path_id = B.path_id '||
       ' and A.session_id = B.session_id '||
       ' and A.session_serial# = B.session_serial# '||
       ' and A.advisor_run_id = B.advisor_run_id '||
       ' and A.advisor_run_time = B.advisor_run_time '||
       ' and (A.advisor_run_id, A.advisor_run_time) in '||
           ' (select distinct advisor_run_id, advisor_run_time '||
           '  from dba_streams_tp_component_stat '||
           '  where advisor_run_id = '|| run_id ||')';

    begin
      open s_cur for stmt1;
      loop
        fetch s_cur into s_rec;
        exit when s_cur%notfound;

        -- Change 'PROPAGATION SENDER' to 'CAPTURE SESSION + PS'
        stmt2 :=
         ' update ' || tbl_name ||
         ' set component_type = ''CAPTURE'', '||
         '     sub_component_type = ''CAPTURE SESSION + PS'', '||
         '     position = ' || s_rec.position || ', '||
         '     component_id = ' || s_rec.component_id || ', '||
         '     component_name = ''' || s_rec.component_name || ''' ' ||
         ' where component_type = ''PROPAGATION SENDER'' '||
           ' and path_id = ' || s_rec.path_id ||
           ' and position = ' || ceil(s_rec.position+1) ||
           ' and advisor_run_id = ' || s_rec.advisor_run_id ||
           ' and advisor_run_time = '||
                 'to_date(''' ||
                  to_char(s_rec.advisor_run_time, 'YYYY-MON-DD HH24:MI:SS') ||
                          ''', ''YYYY-MON-DD HH24:MI:SS'')';
        execute immediate stmt2;
        commit;

        -- Delete redundat 'CAPTURE SESSION' at sub-component and session level
        stmt2 :=
         ' delete from ' || tbl_name ||
         ' where component_type = ''CAPTURE'' '||
           ' and sub_component_type = ''CAPTURE SESSION'' '||
           ' and path_id = ' || s_rec.path_id ||
           ' and position = ' || s_rec.position ||
           ' and advisor_run_id = ' || s_rec.advisor_run_id ||
           ' and advisor_run_time = '||
                 'to_date(''' ||
                  to_char(s_rec.advisor_run_time, 'YYYY-MON-DD HH24:MI:SS') ||
                          ''', ''YYYY-MON-DD HH24:MI:SS'')';
        execute immediate stmt2;
        commit;

        -- Delete redundant 'QUEUE' between 'CAPTURE' and 'PROPAGATION SENDER'
        stmt2 :=
         ' delete from ' || tbl_name ||
         ' where component_type = ''QUEUE'' '||
           ' and path_id = ' || s_rec.path_id ||
           ' and position = ' || ceil(s_rec.position) ||
           ' and advisor_run_id = ' || s_rec.advisor_run_id ||
           ' and advisor_run_time = '||
                 'to_date(''' ||
                  to_char(s_rec.advisor_run_time, 'YYYY-MON-DD HH24:MI:SS') ||
                          ''', ''YYYY-MON-DD HH24:MI:SS'')';
        execute immediate stmt2;
        commit;

        -- Update capture name to <capture>=><destination database>
        stmt2 :=
         ' update ' || tbl_name ||
         ' set component_name = ''' || s_rec.component_name || '''' ||
         ' where component_type = ''CAPTURE'' '||
           ' and path_id = ' || s_rec.path_id ||
           ' and advisor_run_id = ' || s_rec.advisor_run_id ||
           ' and advisor_run_time = '||
                 'to_date(''' ||
                  to_char(s_rec.advisor_run_time, 'YYYY-MON-DD HH24:MI:SS') ||
                          ''', ''YYYY-MON-DD HH24:MI:SS'')';
        execute immediate stmt2;
        commit;

      end loop;
      close s_cur;
    exception when others then
      if s_cur%isopen then
        close s_cur;
      end if;
      raise;
    end;

  end PREPARE_CAP_PS;

  ----------------------------------------------------------------------------=
  -- COLLECT_COMP_STAT 
  --   Collect component statistics for all active stream paths.
  ----------------------------------------------------------------------------=
  procedure COLLECT_COMP_STAT(
    run_id   in number,
    tbl_name in varchar2) as
    stmt           varchar2(4000) := null;
    cur_handle     number;
    rows_processed number;
  begin
    stmt :=
    ' insert into ' || tbl_name || '( '||
             ' advisor_run_id, '||
             ' advisor_run_time, '||
             ' path_id, '||
             ' position, '||
             ' component_id, '||
             ' component_name, '||
             ' component_type, '||
             ' sub_component_type, '||
             ' session_id, '||
             ' session_serial#, '||
             ' statistic_alias, '||
             ' statistic_name, '||
             ' statistic_value, '||
             ' statistic_unit ) '||
    'values(:1, :2, :3, :4, :5, :6, :7, :8, :9, :10, :11, :12, :13, :14)';
    
    cur_handle := dbms_sql.open_cursor;
    dbms_sql.parse(cur_handle, stmt, DBMS_SQL.NATIVE);
    
    -- Fix Bug 7508507 by reducing sharable memory use.
    -- Split the original gigantic query into smaller pieces
    -- so that cursors will consume less sharable memory.
    --
    -- The dbms_sql is used to bind individual component statistics
    -- for fast repeated execution.
    --
    
    -- Need alias statistics with 'Sn' to position them in proper order.
    for stat_rec in (
      select p.advisor_run_id,
             P.advisor_run_time,
             P.path_id,
             P.position,
             P.component_id,
             P.component_name,
             P.component_type,
             S.sub_component_type,
             S.session_id,
             S.session_serial#,
             S.statistic_alias,
             S.statistic_name,
             S.statistic_value,
             S.statistic_unit
      from
      ( select P1.advisor_run_id,
               P1.advisor_run_time,
               P1.path_id,
               P2.position,
               P2.component_id,
               P2.component_name,
               P2.component_type
        from ( select distinct
                      path_id,
                      advisor_run_id,
                      advisor_run_time
               from dba_streams_tp_path_stat
               where advisor_run_id = run_id) P1,
             ( select path_id,
                      source_component_id   as component_id,
                      source_component_name as component_name,
                      source_component_type as component_type,
                      position
               from dba_streams_tp_component_link
               where position = 1
               union
               select path_id,
                      destination_component_id   as component_id,
                      destination_component_name as component_name,
                      destination_component_type as component_type,
                      (position + 1)             as position
               from dba_streams_tp_component_link ) P2
        where P1.path_id = P2.path_id ) P,
      ( select distinct 
               component_id,
               sub_component_type,
               session_id,
               session_serial#,
               decode(statistic_name,
                 'IDLE',                          'S5',
                 'FLOW CONTROL',                  'S6',
                 decode(component_type,
                   'CAPTURE', decode(statistic_name,
                        'CAPTURE RATE',           'S1',
                        'ENQUEUE RATE',           'S2',
                        'LATENCY',                'S3', 'S4'),
                   'APPLY', decode(statistic_name,
                        'MESSAGE APPLY RATE',     'S1',
                        'TRANSACTION APPLY RATE', 'S2',
                        'LATENCY',                'S3', 'S4'),
                   'QUEUE', decode(statistic_name,
                        'ENQUEUE RATE',           'S1',
                        'SPILL RATE',             'S2',
                        'CURRENT QUEUE SIZE',     'S3', 'S4'),
                   'PROPAGATION SENDER', decode(statistic_name,
                        'SEND RATE',              'S1',
                        'BANDWIDTH',              'S2',
                        'LATENCY',                'S3', 'S4'),
                    'S0') ) as statistic_alias,
               statistic_name,
               statistic_value,
               statistic_unit
        from dba_streams_tp_component_stat
        where statistic_name in (
               'LATENCY',
               'IDLE', 'FLOW CONTROL',
               'CAPTURE RATE', 'ENQUEUE RATE',
               'MESSAGE APPLY RATE', 'TRANSACTION APPLY RATE',
               'ENQUEUE RATE', 'SPILL RATE', 'CURRENT QUEUE SIZE',
               'SEND RATE', 'BANDWIDTH')
          and advisor_run_id = run_id) S
      where P.component_id = S.component_id )
    loop
      dbms_sql.bind_variable(cur_handle, ':1',  stat_rec.advisor_run_id);
      dbms_sql.bind_variable(cur_handle, ':2',  stat_rec.advisor_run_time);
      dbms_sql.bind_variable(cur_handle, ':3',  stat_rec.path_id);
      dbms_sql.bind_variable(cur_handle, ':4',  stat_rec.position);
      dbms_sql.bind_variable(cur_handle, ':5',  stat_rec.component_id);
      dbms_sql.bind_variable(cur_handle, ':6',  stat_rec.component_name);
      dbms_sql.bind_variable(cur_handle, ':7',  stat_rec.component_type);
      dbms_sql.bind_variable(cur_handle, ':8',  stat_rec.sub_component_type);
      dbms_sql.bind_variable(cur_handle, ':9',  stat_rec.session_id);
      dbms_sql.bind_variable(cur_handle, ':10', stat_rec.session_serial#);
      dbms_sql.bind_variable(cur_handle, ':11', stat_rec.statistic_alias);
      dbms_sql.bind_variable(cur_handle, ':12', stat_rec.statistic_name);
      dbms_sql.bind_variable(cur_handle, ':13', stat_rec.statistic_value);
      dbms_sql.bind_variable(cur_handle, ':14', stat_rec.statistic_unit);
        
      rows_processed := dbms_sql.execute(cur_handle);
    end loop;
    
    -- S4 (PARALLELISM) FOR 'APPLY SERVER'
    -- S4 (PARALLELISM) FOR 'LOGMINER PREPARER'
    for stat_rec in (
      select p.advisor_run_id,
             P.advisor_run_time,
             P.path_id,
             P.position,
             P.component_id,
             P.component_name,
             P.component_type,
             S.sub_component_type,
             S.session_id,
             S.session_serial#,
             S.statistic_alias,
             S.statistic_name,
             S.statistic_value,
             S.statistic_unit
      from
      ( select P1.advisor_run_id,
               P1.advisor_run_time,
               P1.path_id,
               P2.position,
               P2.component_id,
               P2.component_name,
               P2.component_type
        from ( select distinct
                      path_id,
                      advisor_run_id,
                      advisor_run_time
               from dba_streams_tp_path_stat
               where advisor_run_id = run_id) P1,
             ( select path_id,
                      source_component_id   as component_id,
                      source_component_name as component_name,
                      source_component_type as component_type,
                      position
               from dba_streams_tp_component_link
               where position = 1
               union
               select path_id,
                      destination_component_id   as component_id,
                      destination_component_name as component_name,
                      destination_component_type as component_type,
                      (position + 1)             as position
               from dba_streams_tp_component_link ) P2
        where P1.path_id = P2.path_id ) P,
      ( select component_id,
               decode(component_type,
                      'APPLY', 'APPLY SERVER', 'LOGMINER PREPARER')
                                     as sub_component_type,
               NULL                  as session_id,
               NULL                  as session_serial#,
               'S4'                  as statistic_alias,
               prop_name             as statistic_name,
               to_number(prop_value) as statistic_value,
               'NUMBER'              as statistic_unit
        from "_DBA_STREAMS_TP_COMPONENT_PROP"
        where prop_name = 'PARALLELISM'
          and component_type in ('APPLY', 'CAPTURE') ) S
      where P.component_id = S.component_id )
    loop
      dbms_sql.bind_variable(cur_handle, ':1',  stat_rec.advisor_run_id);
      dbms_sql.bind_variable(cur_handle, ':2',  stat_rec.advisor_run_time);
      dbms_sql.bind_variable(cur_handle, ':3',  stat_rec.path_id);
      dbms_sql.bind_variable(cur_handle, ':4',  stat_rec.position);
      dbms_sql.bind_variable(cur_handle, ':5',  stat_rec.component_id);
      dbms_sql.bind_variable(cur_handle, ':6',  stat_rec.component_name);
      dbms_sql.bind_variable(cur_handle, ':7',  stat_rec.component_type);
      dbms_sql.bind_variable(cur_handle, ':8',  stat_rec.sub_component_type);
      dbms_sql.bind_variable(cur_handle, ':9',  stat_rec.session_id);
      dbms_sql.bind_variable(cur_handle, ':10', stat_rec.session_serial#);
      dbms_sql.bind_variable(cur_handle, ':11', stat_rec.statistic_alias);
      dbms_sql.bind_variable(cur_handle, ':12', stat_rec.statistic_name);
      dbms_sql.bind_variable(cur_handle, ':13', stat_rec.statistic_value);
      dbms_sql.bind_variable(cur_handle, ':14', stat_rec.statistic_unit);
        
      rows_processed := dbms_sql.execute(cur_handle);
    end loop;
    
    -- S5 (IDLE%)
    -- S6 (FLOW CONTROL%)
    for stat_rec in (
      select p.advisor_run_id,
             P.advisor_run_time,
             P.path_id,
             P.position,
             P.component_id,
             P.component_name,
             P.component_type,
             S.sub_component_type,
             S.session_id,
             S.session_serial#,
             S.statistic_alias,
             S.statistic_name,
             S.statistic_value,
             S.statistic_unit
      from
      ( select P1.advisor_run_id,
               P1.advisor_run_time,
               P1.path_id,
               P2.position,
               P2.component_id,
               P2.component_name,
               P2.component_type
        from ( select distinct
                      path_id,
                      advisor_run_id,
                      advisor_run_time
               from dba_streams_tp_path_stat
               where advisor_run_id = run_id) P1,
             ( select path_id,
                      source_component_id   as component_id,
                      source_component_name as component_name,
                      source_component_type as component_type,
                      position
               from dba_streams_tp_component_link
               where position = 1
               union
               select path_id,
                      destination_component_id   as component_id,
                      destination_component_name as component_name,
                      destination_component_type as component_type,
                      (position + 1)             as position
               from dba_streams_tp_component_link ) P2
        where P1.path_id = P2.path_id ) P,
      ( select component_id,
               sub_component_type,
               NULL as session_id ,
               NULL as session_serial#,
               decode(statistic_name, 'IDLE', 'S5', 'S6')
                                    as statistic_alias,
               statistic_name       as statistic_name,
               SUM(statistic_value) as statistic_value,
               statistic_unit       as statistic_unit
        from dba_streams_tp_component_stat
        where statistic_name in ('IDLE', 'FLOW CONTROL')
          and session_id is not null
          and session_serial# is not null
          and advisor_run_id = run_id
        group by component_id,
                 sub_component_type,
                 statistic_name, statistic_unit ) S
      where P.component_id = S.component_id )
    loop
      dbms_sql.bind_variable(cur_handle, ':1',  stat_rec.advisor_run_id);
      dbms_sql.bind_variable(cur_handle, ':2',  stat_rec.advisor_run_time);
      dbms_sql.bind_variable(cur_handle, ':3',  stat_rec.path_id);
      dbms_sql.bind_variable(cur_handle, ':4',  stat_rec.position);
      dbms_sql.bind_variable(cur_handle, ':5',  stat_rec.component_id);
      dbms_sql.bind_variable(cur_handle, ':6',  stat_rec.component_name);
      dbms_sql.bind_variable(cur_handle, ':7',  stat_rec.component_type);
      dbms_sql.bind_variable(cur_handle, ':8',  stat_rec.sub_component_type);
      dbms_sql.bind_variable(cur_handle, ':9',  stat_rec.session_id);
      dbms_sql.bind_variable(cur_handle, ':10', stat_rec.session_serial#);
      dbms_sql.bind_variable(cur_handle, ':11', stat_rec.statistic_alias);
      dbms_sql.bind_variable(cur_handle, ':12', stat_rec.statistic_name);
      dbms_sql.bind_variable(cur_handle, ':13', stat_rec.statistic_value);
      dbms_sql.bind_variable(cur_handle, ':14', stat_rec.statistic_unit);
        
      rows_processed := dbms_sql.execute(cur_handle);
    end loop;

    -- S7 (TOP EVENT%) FOR SESSION
    for stat_rec in (
      select p.advisor_run_id,
             P.advisor_run_time,
             P.path_id,
             P.position,
             P.component_id,
             P.component_name,
             P.component_type,
             S.sub_component_type,
             S.session_id,
             S.session_serial#,
             S.statistic_alias,
             S.statistic_name,
             S.statistic_value,
             S.statistic_unit
      from
      ( select P1.advisor_run_id,
               P1.advisor_run_time,
               P1.path_id,
               P2.position,
               P2.component_id,
               P2.component_name,
               P2.component_type
        from ( select distinct
                      path_id,
                      advisor_run_id,
                      advisor_run_time
               from dba_streams_tp_path_stat
               where advisor_run_id = run_id) P1,
             ( select path_id,
                      source_component_id   as component_id,
                      source_component_name as component_name,
                      source_component_type as component_type,
                      position
               from dba_streams_tp_component_link
               where position = 1
               union
               select path_id,
                      destination_component_id   as component_id,
                      destination_component_name as component_name,
                      destination_component_type as component_type,
                      (position + 1)             as position
               from dba_streams_tp_component_link ) P2
        where P1.path_id = P2.path_id ) P,
      ( select component_id,
               sub_component_type,
               session_id,
               session_serial#,
               'S7' as statistic_alias,
               regexp_replace(statistic_name, '^EVENT: ', NULL)
                    as statistic_name,
               statistic_value,
               statistic_unit
        from ( select component_id,
                      sub_component_type,
                      session_id,
                      session_serial#,
                      statistic_name,
                      statistic_value,
                      statistic_unit,
                      max(statistic_value)
                        over (partition by
                              component_id, sub_component_type,
                              session_id, session_serial#)
                        as max_statistic_value
               from dba_streams_tp_component_stat
               where statistic_name LIKE 'EVENT: %'
                 and session_id is not null
                 and session_serial# is not null
                 and advisor_run_id = run_id )
        where statistic_value = max_statistic_value ) S
      where P.component_id = S.component_id )
    loop
      dbms_sql.bind_variable(cur_handle, ':1',  stat_rec.advisor_run_id);
      dbms_sql.bind_variable(cur_handle, ':2',  stat_rec.advisor_run_time);
      dbms_sql.bind_variable(cur_handle, ':3',  stat_rec.path_id);
      dbms_sql.bind_variable(cur_handle, ':4',  stat_rec.position);
      dbms_sql.bind_variable(cur_handle, ':5',  stat_rec.component_id);
      dbms_sql.bind_variable(cur_handle, ':6',  stat_rec.component_name);
      dbms_sql.bind_variable(cur_handle, ':7',  stat_rec.component_type);
      dbms_sql.bind_variable(cur_handle, ':8',  stat_rec.sub_component_type);
      dbms_sql.bind_variable(cur_handle, ':9',  stat_rec.session_id);
      dbms_sql.bind_variable(cur_handle, ':10', stat_rec.session_serial#);
      dbms_sql.bind_variable(cur_handle, ':11', stat_rec.statistic_alias);
      dbms_sql.bind_variable(cur_handle, ':12', stat_rec.statistic_name);
      dbms_sql.bind_variable(cur_handle, ':13', stat_rec.statistic_value);
      dbms_sql.bind_variable(cur_handle, ':14', stat_rec.statistic_unit);
        
      rows_processed := dbms_sql.execute(cur_handle);
    end loop;
    
    -- S7 (TOP EVENT%) FOR SUB_COMPONENT
    -- S7 (TOP EVENT%) TOP_LEVEL COMPONENT WITHOUT SUB_COMPONENT
    for stat_rec in (
      select p.advisor_run_id,
             P.advisor_run_time,
             P.path_id,
             P.position,
             P.component_id,
             P.component_name,
             P.component_type,
             S.sub_component_type,
             S.session_id,
             S.session_serial#,
             S.statistic_alias,
             S.statistic_name,
             S.statistic_value,
             S.statistic_unit
      from
      ( select P1.advisor_run_id,
               P1.advisor_run_time,
               P1.path_id,
               P2.position,
               P2.component_id,
               P2.component_name,
               P2.component_type
        from ( select distinct
                      path_id,
                      advisor_run_id,
                      advisor_run_time
               from dba_streams_tp_path_stat
               where advisor_run_id = run_id) P1,
             ( select path_id,
                      source_component_id   as component_id,
                      source_component_name as component_name,
                      source_component_type as component_type,
                      position
               from dba_streams_tp_component_link
               where position = 1
               union
               select path_id,
                      destination_component_id   as component_id,
                      destination_component_name as component_name,
                      destination_component_type as component_type,
                      (position + 1)             as position
               from dba_streams_tp_component_link ) P2
        where P1.path_id = P2.path_id ) P,
      ( select distinct 
               component_id,
               sub_component_type,
               null   as session_id,
               null   as session_serial#,
               'S7'   as statistic_alias,
               regexp_replace(statistic_name, '^EVENT: ', NULL)
                      as statistic_name,
               statistic_value,
               statistic_unit
        from ( select component_id,
                      sub_component_type,
                      statistic_name,
                      statistic_value,
                      statistic_unit,
                      max(statistic_value)
                        over (partition by
                              component_id, sub_component_type)
                        as max_statistic_value
               from dba_streams_tp_component_stat
               where statistic_name LIKE 'EVENT: %'
                 and session_id is not null
                 and session_serial# is not null
                 and advisor_run_id = run_id )
        where statistic_value = max_statistic_value ) S
      where P.component_id = S.component_id )
    loop
      dbms_sql.bind_variable(cur_handle, ':1',  stat_rec.advisor_run_id);
      dbms_sql.bind_variable(cur_handle, ':2',  stat_rec.advisor_run_time);
      dbms_sql.bind_variable(cur_handle, ':3',  stat_rec.path_id);
      dbms_sql.bind_variable(cur_handle, ':4',  stat_rec.position);
      dbms_sql.bind_variable(cur_handle, ':5',  stat_rec.component_id);
      dbms_sql.bind_variable(cur_handle, ':6',  stat_rec.component_name);
      dbms_sql.bind_variable(cur_handle, ':7',  stat_rec.component_type);
      dbms_sql.bind_variable(cur_handle, ':8',  stat_rec.sub_component_type);
      dbms_sql.bind_variable(cur_handle, ':9',  stat_rec.session_id);
      dbms_sql.bind_variable(cur_handle, ':10', stat_rec.session_serial#);
      dbms_sql.bind_variable(cur_handle, ':11', stat_rec.statistic_alias);
      dbms_sql.bind_variable(cur_handle, ':12', stat_rec.statistic_name);
      dbms_sql.bind_variable(cur_handle, ':13', stat_rec.statistic_value);
      dbms_sql.bind_variable(cur_handle, ':14', stat_rec.statistic_unit);
        
      rows_processed := dbms_sql.execute(cur_handle);
    end loop;
    
    -- FILL IN S7 (TOP EVENT%) IF MISSING FOR SESSION
    for stat_rec in (
      select p.advisor_run_id,
             P.advisor_run_time,
             P.path_id,
             P.position,
             P.component_id,
             P.component_name,
             P.component_type,
             S.sub_component_type,
             S.session_id,
             S.session_serial#,
             S.statistic_alias,
             S.statistic_name,
             S.statistic_value,
             S.statistic_unit
      from
      ( select P1.advisor_run_id,
               P1.advisor_run_time,
               P1.path_id,
               P2.position,
               P2.component_id,
               P2.component_name,
               P2.component_type
        from ( select distinct
                      path_id,
                      advisor_run_id,
                      advisor_run_time
               from dba_streams_tp_path_stat
               where advisor_run_id = run_id) P1,
             ( select path_id,
                      source_component_id   as component_id,
                      source_component_name as component_name,
                      source_component_type as component_type,
                      position
               from dba_streams_tp_component_link
               where position = 1
               union
               select path_id,
                      destination_component_id   as component_id,
                      destination_component_name as component_name,
                      destination_component_type as component_type,
                      (position + 1)             as position
               from dba_streams_tp_component_link ) P2
        where P1.path_id = P2.path_id ) P,
      ( select distinct
               component_id,
               sub_component_type,
               session_id,
               session_serial#,
               'S7'           as statistic_alias,
               NULL           as statistic_name,
               0              as statistic_value,
               'PERCENT'      as statistic_unit
        from dba_streams_tp_component_stat S1
        where S1.component_type != 'QUEUE'
          and S1.session_id is not null
          and S1.session_serial# is not null
          and S1.advisor_run_id = run_id and
              not exists (
              select component_id
              from dba_streams_tp_component_stat S2
              where S2.statistic_name like 'EVENT: %' and
                    S1.session_serial# = S2.session_serial# and
                    S1.session_id = S2.session_id and
                    S1.component_id = S2.component_id and
                    S1.advisor_run_id = S2.advisor_run_id ) ) S
      where P.component_id = S.component_id )
    loop
      dbms_sql.bind_variable(cur_handle, ':1',  stat_rec.advisor_run_id);
      dbms_sql.bind_variable(cur_handle, ':2',  stat_rec.advisor_run_time);
      dbms_sql.bind_variable(cur_handle, ':3',  stat_rec.path_id);
      dbms_sql.bind_variable(cur_handle, ':4',  stat_rec.position);
      dbms_sql.bind_variable(cur_handle, ':5',  stat_rec.component_id);
      dbms_sql.bind_variable(cur_handle, ':6',  stat_rec.component_name);
      dbms_sql.bind_variable(cur_handle, ':7',  stat_rec.component_type);
      dbms_sql.bind_variable(cur_handle, ':8',  stat_rec.sub_component_type);
      dbms_sql.bind_variable(cur_handle, ':9',  stat_rec.session_id);
      dbms_sql.bind_variable(cur_handle, ':10', stat_rec.session_serial#);
      dbms_sql.bind_variable(cur_handle, ':11', stat_rec.statistic_alias);
      dbms_sql.bind_variable(cur_handle, ':12', stat_rec.statistic_name);
      dbms_sql.bind_variable(cur_handle, ':13', stat_rec.statistic_value);
      dbms_sql.bind_variable(cur_handle, ':14', stat_rec.statistic_unit);
        
      rows_processed := dbms_sql.execute(cur_handle);
    end loop;
    
    -- FILL IN S7 (TOP EVENT%) IF MISSING FOR SUB_COMPONENT_TYPE
    for stat_rec in (
      select p.advisor_run_id,
             P.advisor_run_time,
             P.path_id,
             P.position,
             P.component_id,
             P.component_name,
             P.component_type,
             S.sub_component_type,
             S.session_id,
             S.session_serial#,
             S.statistic_alias,
             S.statistic_name,
             S.statistic_value,
             S.statistic_unit
      from
      ( select P1.advisor_run_id,
               P1.advisor_run_time,
               P1.path_id,
               P2.position,
               P2.component_id,
               P2.component_name,
               P2.component_type
        from ( select distinct
                      path_id,
                      advisor_run_id,
                      advisor_run_time
               from dba_streams_tp_path_stat
               where advisor_run_id = run_id) P1,
             ( select path_id,
                      source_component_id   as component_id,
                      source_component_name as component_name,
                      source_component_type as component_type,
                      position
               from dba_streams_tp_component_link
               where position = 1
               union
               select path_id,
                      destination_component_id   as component_id,
                      destination_component_name as component_name,
                      destination_component_type as component_type,
                      (position + 1)             as position
               from dba_streams_tp_component_link ) P2
        where P1.path_id = P2.path_id ) P,
      ( select distinct
               component_id,
               sub_component_type,
               NULL           as session_id,
               NULL           as session_serial#,
               'S7'           as statistic_alias,
               NULL           as statistic_name,
               0              as statistic_value,
               'PERCENT'      as statistic_unit
        from dba_streams_tp_component_stat S1
        where S1.component_type in ('CAPTURE', 'APPLY')
          and S1.sub_component_type is not null
          and S1.advisor_run_id = run_id
          and not exists (
                select component_id
                from dba_streams_tp_component_stat S2
                where S2.statistic_name like 'EVENT: %'
                  and S1.sub_component_type = S2.sub_component_type
                  and S1.component_id = S2.component_id
                  and S1.advisor_run_id = S2.advisor_run_id ) ) S
      where P.component_id = S.component_id )
    loop
      dbms_sql.bind_variable(cur_handle, ':1',  stat_rec.advisor_run_id);
      dbms_sql.bind_variable(cur_handle, ':2',  stat_rec.advisor_run_time);
      dbms_sql.bind_variable(cur_handle, ':3',  stat_rec.path_id);
      dbms_sql.bind_variable(cur_handle, ':4',  stat_rec.position);
      dbms_sql.bind_variable(cur_handle, ':5',  stat_rec.component_id);
      dbms_sql.bind_variable(cur_handle, ':6',  stat_rec.component_name);
      dbms_sql.bind_variable(cur_handle, ':7',  stat_rec.component_type);
      dbms_sql.bind_variable(cur_handle, ':8',  stat_rec.sub_component_type);
      dbms_sql.bind_variable(cur_handle, ':9',  stat_rec.session_id);
      dbms_sql.bind_variable(cur_handle, ':10', stat_rec.session_serial#);
      dbms_sql.bind_variable(cur_handle, ':11', stat_rec.statistic_alias);
      dbms_sql.bind_variable(cur_handle, ':12', stat_rec.statistic_name);
      dbms_sql.bind_variable(cur_handle, ':13', stat_rec.statistic_value);
      dbms_sql.bind_variable(cur_handle, ':14', stat_rec.statistic_unit);
        
      rows_processed := dbms_sql.execute(cur_handle);
    end loop;
    
    -- FILL IN S7 (TOP EVENT%) IF MISSING FOR TOP_LEVEL COMPONENT
    for stat_rec in (
      select p.advisor_run_id,
             P.advisor_run_time,
             P.path_id,
             P.position,
             P.component_id,
             P.component_name,
             P.component_type,
             S.sub_component_type,
             S.session_id,
             S.session_serial#,
             S.statistic_alias,
             S.statistic_name,
             S.statistic_value,
             S.statistic_unit
      from
      ( select P1.advisor_run_id,
               P1.advisor_run_time,
               P1.path_id,
               P2.position,
               P2.component_id,
               P2.component_name,
               P2.component_type
        from ( select distinct
                      path_id,
                      advisor_run_id,
                      advisor_run_time
               from dba_streams_tp_path_stat
               where advisor_run_id = run_id) P1,
             ( select path_id,
                      source_component_id   as component_id,
                      source_component_name as component_name,
                      source_component_type as component_type,
                      position
               from dba_streams_tp_component_link
               where position = 1
               union
               select path_id,
                      destination_component_id   as component_id,
                      destination_component_name as component_name,
                      destination_component_type as component_type,
                      (position + 1)             as position
               from dba_streams_tp_component_link ) P2
        where P1.path_id = P2.path_id ) P,
      ( select distinct
               component_id,
               NULL         as sub_component_type,
               NULL         as session_id,
               NULL         as session_serial#,
               'S7'         as statistic_alias,
               NULL         as statistic_name,
               0            as statistic_value,
               'PERCENT'    as statistic_unit
        from dba_streams_tp_component_stat S1
        where S1.component_type not in ('CAPTURE', 'APPLY', 'QUEUE')
          and S1.sub_component_type is null
          and S1.advisor_run_id = run_id
          and not exists (
                select component_id
                from dba_streams_tp_component_stat S2
                where S2.statistic_name like 'EVENT: %'
                  and S1.component_id = S2.component_id
                  and S1.advisor_run_id = S2.advisor_run_id ) ) S
      where P.component_id = S.component_id )
    loop
      dbms_sql.bind_variable(cur_handle, ':1',  stat_rec.advisor_run_id);
      dbms_sql.bind_variable(cur_handle, ':2',  stat_rec.advisor_run_time);
      dbms_sql.bind_variable(cur_handle, ':3',  stat_rec.path_id);
      dbms_sql.bind_variable(cur_handle, ':4',  stat_rec.position);
      dbms_sql.bind_variable(cur_handle, ':5',  stat_rec.component_id);
      dbms_sql.bind_variable(cur_handle, ':6',  stat_rec.component_name);
      dbms_sql.bind_variable(cur_handle, ':7',  stat_rec.component_type);
      dbms_sql.bind_variable(cur_handle, ':8',  stat_rec.sub_component_type);
      dbms_sql.bind_variable(cur_handle, ':9',  stat_rec.session_id);
      dbms_sql.bind_variable(cur_handle, ':10', stat_rec.session_serial#);
      dbms_sql.bind_variable(cur_handle, ':11', stat_rec.statistic_alias);
      dbms_sql.bind_variable(cur_handle, ':12', stat_rec.statistic_name);
      dbms_sql.bind_variable(cur_handle, ':13', stat_rec.statistic_value);
      dbms_sql.bind_variable(cur_handle, ':14', stat_rec.statistic_unit);
        
      rows_processed := dbms_sql.execute(cur_handle);
    end loop;
    
    -- Close cursor
    dbms_sql.close_cursor(cur_handle);

    -- Update position for statistics at different levels.
    -- Positions of sub-components of a top level component are
    -- determined according to the direction streams data flow.
    stmt :=
     ' update ' || tbl_name ||
     ' set position = '||
           ' floor(position) + '||
           ' decode(sub_component_type, '||
           '   ''LOGMINER READER'',        0.1, '||
           '   ''LOGMINER PREPARER'',      0.2, '||
           '   ''LOGMINER BUILDER'',       0.3, '||
           '   ''CAPTURE SESSION'',        0.4, '||
           '   ''PROPAGATION SENDER+RECEIVER'', 0.1, '||
           '   ''APPLY READER'',           0.2, '||
           '   ''APPLY COORDINATOR'',      0.3, '||
           '   ''APPLY SERVER'',           0.4, '||
           '   0.0) '||
     ' where (advisor_run_id, advisor_run_time) in '||
           ' ( select distinct advisor_run_id, advisor_run_time '||
           '   from dba_streams_tp_component_stat '||
           '   where advisor_run_id = ' || run_id || ') ';
    execute immediate stmt;
    commit;

    -- TODO this may be not needed anymore since component_level
    -- statistics calculation now has a 'distinct' 
    -- Delete duplicate TOP EVENTs with the same percentage
    stmt :=
      ' delete from ' || tbl_name || ' A '||
      ' where rowid > ( '||
      '   select MIN(rowid) from ' || tbl_name || ' B '||
      '   where A.advisor_run_id = B.advisor_run_id and '||
      '         A.advisor_run_time = B.advisor_run_time and '||
      '         A.path_id = B.path_id and '||
      '         A.position = B.position and '||
      '         A.component_id = B.component_id and '||
      '         A.sub_component_type = B.sub_component_type and '||
      '         A.session_id = B.session_id and '||
      '         A.session_serial# = B.session_serial# and '||
      '         A.statistic_alias = B.statistic_alias and '||
      '         A.statistic_value = B.statistic_value ) '||
      '   and statistic_alias = ''S7'' '||
      '   and ( advisor_run_id, advisor_run_time ) in '||
      '       ( select distinct advisor_run_id, advisor_run_time '||
      '         from dba_streams_tp_component_stat '||
      '         where advisor_run_id = '|| run_id ||')';
    execute immediate stmt;
    commit;

    -- Preare CCA statistics for displaying 'CAP+PS'
    PREPARE_CAP_PS(run_id, tbl_name);

  end COLLECT_COMP_STAT;

  ----------------------------------------------------------------------------=
  -- GET_BOTTLENECK
  --   Get bottleneck information in the following form:
  --     |<B> advisor_run_reason
  --   OR
  --     |<B> component_name sub_component_name sid serial topevent% "topevent"
  ----------------------------------------------------------------------------=
  function GET_BOTTLENECK(run_id in number, path_id in number)
  return varchar2 as
    val  varchar2(4000) := null; 
    val2 varchar2(4000) := null;
    bott DBA_STREAMS_TP_COMPONENT_STAT%ROWTYPE;
  begin
    begin
      for bott in (
        select distinct S.*
        from dba_streams_tp_path_bottleneck B,
           ( select distinct *
             from dba_streams_tp_component_stat
             where statistic_name LIKE 'EVENT: %' and
                   session_id is not null and
                   session_serial# is not null and
                   advisor_run_id = GET_BOTTLENECK.run_id ) S
        where B.path_id = GET_BOTTLENECK.path_id and
              B.advisor_run_id = GET_BOTTLENECK.run_id and
              B.top_session_id is not null and
              B.top_session_serial# is not null and
              B.bottleneck_identified = 'YES' and
              B.advisor_run_id = S.advisor_run_id (+) and
              B.component_id = S.component_id (+) and
              B.top_session_id = S.session_id (+) and
              B.top_session_serial# = S.session_serial# (+)
        order by S.statistic_value desc)
      loop
        val := '|<B> ' ||
               get_comp_name(bott.component_type, bott.component_name) ||' '||
               case when (bott.component_type = 'APPLY' OR
                          bott.component_type = 'CAPTURE') then
                         get_sub_comp_type(bott.sub_component_type) || ' '
                    else NULL
               end ||
               bott.session_id ||' '|| bott.session_serial# ||' '||
               to_char(bott.statistic_value, 'FM999D9') || '% "' ||
               regexp_replace(bott.statistic_name, '^EVENT: ', NULL) || '"';
        exit when val is not null;
      end loop;

      if val is null then
        -- post process for XStream Bottleneck in case 'EXTERNAL' is 
        -- the bottleneck. In this case, bottleneck_identified is set to 'YES'
        -- but component id/session_id/session_serial will all be NULL and will
        -- not be covered by previous step. 
        select '|<B> "EXTERNAL"' into val2
        from dba_streams_tp_path_bottleneck
        where advisor_run_id = GET_BOTTLENECK.run_id AND
              path_id = GET_BOTTLENECK.path_id AND
              action_name = 'EXTERNAL' AND
              bottleneck_identified = 'YES';
        
        if val2 is not null then
          val := val2;
        else
          select distinct '|<B> "' || advisor_run_reason || '"' into val
          from dba_streams_tp_path_bottleneck B
          where B.path_id = GET_BOTTLENECK.path_id and
                B.advisor_run_id = GET_BOTTLENECK.run_id;
        end if;
      end if;

    exception when others then
       val := '|<B> ' || 'NO BOTTLENECK IDENTIFIED';
    end;

    return val;
  end GET_BOTTLENECK;

  ----------------------------------------------------------------------------=
  -- COLLECT_PATH_STAT
  --   Collect path statistics by concatenating component statistics into
  --   one single line representation for each active path. The output is
  --   similar to STRMMON output.
  ----------------------------------------------------------------------------=
  procedure COLLECT_PATH_STAT(
    run_id              in number,
    input_tbl           in varchar2,
    output_tbl          in varchar2,
    top_event_threshold in number default 15)
  as
    stmt1 varchar2(4000);
    stmt2 varchar2(4000);

    TYPE cur_type is ref cursor;
    s_cur         cur_type;
    s_rec         stat_type;
    p_rec         stat_type; -- previous s_rec
    p_rec_default stat_type; -- reset p_rec to the default
    path_stat     varchar2(4000) := null;
    TYPE maptype IS TABLE OF boolean INDEX BY VARCHAR2(30);
    topEventMap maptype;
  begin
    stmt1 :=
      ' select advisor_run_id, '||
             ' advisor_run_time, '||
             ' path_id, '||
             ' position, '||
             ' component_id, '||
             ' component_name, '||
             ' component_type, '||
             ' sub_component_type, '||
             ' session_id, '||
             ' session_serial#, '||
             ' statistic_alias, '||
             ' statistic_name, '||
             ' statistic_value, '||
             ' statistic_unit '||
      ' from ' || input_tbl ||
      ' where ( advisor_run_id, advisor_run_time ) in '||
      '       ( select distinct advisor_run_id, advisor_run_time '||
      '         from dba_streams_tp_component_stat '||
      '         where advisor_run_id = '|| run_id ||') and '||
              -- filter out session level statistics
      '       session_id is null and '|| 
      '       session_serial# is null '||  
      ' order by path_id, position, statistic_alias';

    begin
      open s_cur for stmt1;
      loop
        fetch s_cur into s_rec;
        exit when s_cur%notfound;

        if p_rec.path_id = 0 then
           path_stat := null;
           p_rec.path_id := s_rec.path_id;
        end if;

        if p_rec.path_id = s_rec.path_id then
           if path_stat is null then
             path_stat := join_stat(p_rec, s_rec, top_event_threshold);
           else
             if s_rec.statistic_alias = 'S7' and s_rec.sub_component_type in
                ('LOGMINER PREPARER', 'APPLY SERVER') then
               -- check if we have aggregated them already for this path
               if topEventMap.exists(s_rec.sub_component_type) then
                 continue;
               else
                  topEventMap(s_rec.sub_component_type) := TRUE;
               end if;

               -- Aggregate TOP EVENT percentage for LMP and APS
               path_stat := path_stat || ' ' ||
                            aggregate_top_event(run_id,
                                                s_rec.component_id,
                                                s_rec.sub_component_type,
                                                top_event_threshold);
             else
               path_stat := path_stat || ' ' ||
                            join_stat(p_rec, s_rec, top_event_threshold);
             end if;
           end if;
        else
           -- Append bottleneck information
           path_stat := path_stat || ' ' ||
                        get_bottleneck(p_rec.advisor_run_id, p_rec.path_id);

           stmt2 :=
             'insert into ' || output_tbl ||
             '(path_id, advisor_run_id, advisor_run_time, statistics) '||
             'values( '||
                p_rec.path_id || ',' ||
                p_rec.advisor_run_id || ',' ||
                'to_date(''' ||
                to_char(p_rec.advisor_run_time, 'YYYY-MON-DD HH24:MI:SS')||
                         ''', ''YYYY-MON-DD HH24:MI:SS''), ''' ||
                path_stat || ''')';
           execute immediate stmt2;
           commit;

           p_rec := p_rec_default;
           p_rec.path_id := s_rec.path_id;
           path_stat := join_stat(p_rec, s_rec, top_event_threshold);
           topEventMap.delete;
        end if;

        p_rec := s_rec;
      end loop;
      close s_cur;

      if path_stat is not null then
        -- Append bottleneck information
        path_stat := path_stat || ' ' ||
                     get_bottleneck(p_rec.advisor_run_id, p_rec.path_id);

        stmt2 :=
          'insert into ' || output_tbl ||
             '(path_id, advisor_run_id, advisor_run_time, statistics) '||
             'values( '||
                p_rec.path_id || ',' ||
                p_rec.advisor_run_id || ',' ||
                'to_date(''' ||
                to_char(p_rec.advisor_run_time, 'YYYY-MON-DD HH24:MI:SS')||
                         ''', ''YYYY-MON-DD HH24:MI:SS''), ''' ||
                path_stat || ''')';
        execute immediate stmt2;
        commit;
      end if;
    exception when others then
      if s_cur%isopen then
        close s_cur;
      end if;
      raise;
    end;

  end COLLECT_PATH_STAT;
  
  ----------------------------------------------------------------------------=
  -- COLLECT_PATH_SESS
  --   Collect session level statistics for each active stream path.
  ----------------------------------------------------------------------------=
  procedure COLLECT_PATH_SESS(
    run_id              in number,
    input_tbl           in varchar2,
    output_tbl          in varchar2,
    top_event_threshold in number default 15) as
    stmt1 varchar2(4000);
    stmt2 varchar2(4000);

    TYPE cur_type is ref cursor;
    s_cur         cur_type;
    s_rec         stat_type;
    p_rec         stat_type; -- previous s_rec
    p_rec_default stat_type; -- reset p_rec to the default
    path_sess     varchar2(4000) := null;
  begin
    stmt1 :=
      ' select advisor_run_id, '||
             ' advisor_run_time, '||
             ' path_id, '||
             ' position, '||
             ' component_id, '||
             ' component_name, '||
             ' component_type, '||
             ' sub_component_type, '||
             ' session_id, '||
             ' session_serial#, '||
             ' statistic_alias, '||
             ' statistic_name, '||
             ' statistic_value, '||
             ' statistic_unit '||
      ' from ' || input_tbl ||
      ' where ( advisor_run_id, advisor_run_time ) in '||
      '       ( select distinct advisor_run_id, advisor_run_time '||
      '         from dba_streams_tp_component_stat '||
      '         where advisor_run_id = '|| run_id ||') and '||
              -- select session level statistics only
      '       session_id is not null and '|| 
      '       session_serial# is not null '|| 
      ' order by path_id,position,session_id,session_serial#,statistic_alias';

    begin
      open s_cur for stmt1;
      loop
        fetch s_cur into s_rec;
        exit when s_cur%notfound;

        if p_rec.path_id = 0 then
           path_sess := null;
           p_rec.path_id := s_rec.path_id;
        end if;

        if p_rec.path_id = s_rec.path_id then
           if path_sess is null then
             path_sess := join_stat(p_rec, s_rec, top_event_threshold, TRUE);
           else
             path_sess := path_sess || ' ' ||
                          join_stat(p_rec, s_rec, top_event_threshold, TRUE);
           end if;
        else
           stmt2 :=
            'update ' || output_tbl || ' V set V.session_statistics = '||
            '''' || path_sess || ''' '|| 
            'where (V.advisor_run_id, V.advisor_run_time) in '||
            '      (select distinct advisor_run_id, advisor_run_time '||
            '       from dba_streams_tp_component_stat '||
            '       where advisor_run_id = ' || run_id || ') and '||
            '       V.path_id = ' || p_rec.path_id;
           execute immediate stmt2;
           commit;

           p_rec := p_rec_default;
           p_rec.path_id := s_rec.path_id;
           path_sess := join_stat(p_rec, s_rec, top_event_threshold, TRUE);
        end if;

        p_rec := s_rec;
      end loop;
      close s_cur;

      if path_sess is not null then
        stmt2 :=
          'update ' || output_tbl || ' V set V.session_statistics = '||
          '''' || path_sess || ''' '|| 
          'where (V.advisor_run_id, V.advisor_run_time) in '||
          '      (select distinct advisor_run_id, advisor_run_time '||
          '       from dba_streams_tp_component_stat '||
          '       where advisor_run_id = ' || run_id || ') and '||
          '       V.path_id = ' || p_rec.path_id;
        execute immediate stmt2;
        commit;
      end if;
    exception when others then
      if s_cur%isopen then
        close s_cur;
      end if;
      raise;
    end;

  end COLLECT_PATH_SESS;
  
  ----------------------------------------------------------------------------=
  -- COLLECT_CONTROL_SETTING
  --   Collect statistics control setting for all active stream paths.
  ----------------------------------------------------------------------------=
  procedure COLLECT_CONTROL_SETTING(
    run_id              in number,
    output_tbl          in varchar2,
    setting             in varchar2) as
    stmt varchar2(2400);
  begin
  
    stmt :=
    'update ' || output_tbl || ' V set V.setting = ''' ||setting|| ''' '||
    'where (V.advisor_run_id, V.advisor_run_time) in '||
    '      (select distinct advisor_run_id, advisor_run_time '||
    '       from dba_streams_tp_component_stat '||
    '       where advisor_run_id = ' || run_id || ')';
    execute immediate stmt;
  
    commit;
  end COLLECT_CONTROL_SETTING;
  
  ----------------------------------------------------------------------------=
  -- COLLECT_OPTIMIZATION_MODE
  --   Collect property OPTIMIZATION_MODE for all active stream paths.
  ----------------------------------------------------------------------------=
  procedure COLLECT_OPTIMIZATION_MODE(
    run_id              in number,
    output_tbl          in varchar2) as
    stmt varchar2(2400);
  begin
    -- optimization_mode:
    --   0 non-CCA mode
    --   1 CCA mode
    --   2 CCAC mode

    stmt :=
    'update ' || output_tbl || ' V set V.optimization = '||
    ' ( select STATISTIC_VALUE '||
    '   from dba_streams_tp_path_stat S '||
    '   where statistic_name = ''OPTIMIZATION_MODE'' '||
    '     and V.path_id = S.path_id '||
    '     and V.advisor_run_id = S.advisor_run_id '||
    '     and V.advisor_run_time = S.advisor_run_time ) '||
    'where (V.advisor_run_id, V.advisor_run_time) in '||
    '      (select distinct advisor_run_id, advisor_run_time '||
    '       from dba_streams_tp_path_stat '||
    '       where advisor_run_id = ' || run_id || ')';
    execute immediate stmt;
  
    commit;
  end COLLECT_OPTIMIZATION_MODE;

  ----------------------------------------------------------------------------=
  -- PERSIST_LINE_DISPLAY
  --   Persist statics for showing streams performance in line-display format.
  ----------------------------------------------------------------------------=
  procedure PERSIST_LINE_DISPLAY(
    run_id         in number,
    comp_stat_tbl  in varchar2,
    path_stat_tbl  in varchar2,
    raise_error    in boolean default FALSE,
    save_comp_stat in boolean default TRUE)
  as
    param_setting varchar2(2000);
  begin
    -- Get control parameter setting
    param_setting :=
      'TOP_EVENT_THRESHOLD=' ||
         param_top_event_threshold ||
      ' BOTTLENECK_IDLE_THRESHOLD=' ||
         dbms_streams_advisor_adm.bottleneck_idle_threshold ||
      ' BOTTLENECK_FLOWCTRL_THRESHOLD=' ||
         dbms_streams_advisor_adm.bottleneck_flowctrl_threshold;
    
    -- Save component statistics
    begin
      COLLECT_COMP_STAT(run_id, comp_stat_tbl);
    exception when others then
      if raise_error then
        raise;
      else
        NULL;
      end if;
    end;
    
    -- Save top-level path statistics
    begin
      COLLECT_PATH_STAT(run_id, comp_stat_tbl, path_stat_tbl,
                        param_top_event_threshold);
    exception when others then
      if raise_error then
        raise;
      else
        NULL;
      end if;
    end;

    -- Save session-level path statistics
    begin
      COLLECT_PATH_SESS(run_id, comp_stat_tbl, path_stat_tbl,
                        param_top_event_threshold);
    exception when others then
      if raise_error then
        raise;
      else
        NULL;
      end if;
    end;
    
    -- Save OPTIMIZATION_MODE property
    begin
      COLLECT_OPTIMIZATION_MODE(run_id, path_stat_tbl);
    exception when others then
      if raise_error then
        raise;
      else
        NULL;
      end if;
    end;
    
    -- Save the control parameter setting
    begin
      COLLECT_CONTROL_SETTING(run_id, path_stat_tbl, param_setting);
    exception when others then
      if raise_error then
        raise;
      else
        NULL;
      end if;
    end;

    if (save_comp_stat = FALSE) then
      delete from streams$_pa_show_comp_stat;
      commit;
    end if;
  
  end PERSIST_LINE_DISPLAY;

  ----------------------------------------------------------------------------=
  -- CHECK_DATABASE_LINKS
  --   Persist database information upon each advisor run.
  ----------------------------------------------------------------------------=
  procedure CHECK_DATABASE_LINKS
  as
    TYPE CUR_TYPE IS ref cursor;
    TYPE DBLINK_TYPE IS RECORD(db_link VARCHAR2(128));
    TYPE DBNAME_TYPE IS RECORD(global_name   varchar2(128),
                               db_unique_name varchar2(30));

    cur        cur_type;
    dbname_rec dbname_type;
    dblink_rec dblink_type;
    canon_user varchar2(30);
    stmt       varchar2(4000);
    ecode      number;
    emesg      varchar2(200);
  begin
    canon_user := SYS_CONTEXT('USERENV', 'CURRENT_USER');

    for dblink_rec in (
      select global_name as db_link from global_name
      union
      select db_link from dba_db_links
      where owner = canon_user or username = canon_user)
    loop
      stmt := 'select global_name, db_unique_name from ' ||
              'global_name@' || dblink_rec.db_link ||', '||
              'v$database@'  || dblink_rec.db_link;
      begin
        open cur for stmt;
        loop
          fetch cur into dbname_rec;
          exit when cur%NOTFOUND;

          -- upsert streams$_pa_database
          merge into streams$_pa_database T
          using (select dbname_rec.global_name as global_name from dual) N
          on (T.global_name = N.global_name)
          when matched then
               update set T.error_number = null,
                          T.error_message = null
          when not matched then
               insert (T.global_name)
               values (N.global_name);
          commit;

          -- upsert streams$_pa_database_prop
          merge into streams$_pa_database_prop T
          using (select dbname_rec.global_name    as global_name,
                        'DB_UNIQUE_NAME'          as prop_name,
                        dbname_rec.db_unique_name as prop_value
                 from dual) N
          on (T.global_name = N.global_name and T.prop_name = N.prop_name)
          when matched then
               update set T.prop_value = N.prop_value
          when not matched then
               insert (T.global_name, T.prop_name, T.prop_value)
               values (N.global_name, N.prop_name, N.prop_value);
          commit;
        end loop;

        close cur;
      exception when others then
        close cur;

        ecode := SQLCODE;
        emesg := SQLERRM;

        -- Assume global_name set to TRUE
        update streams$_pa_database
        set error_number = ecode, error_message = emesg
        where global_name = dblink_rec.db_link;
        commit;
      end; -- End processing stmt

    end loop;

  end CHECK_DATABASE_LINKS;

  ----------------------------------------------------------------------------=
  -- LOAD_MONITORING_INFO
  --   Load advisor monitoring info upon each advisor run.
  ----------------------------------------------------------------------------=
  procedure LOAD_MONITORING_INFO
  as
  begin
    begin
      select job_name,
             client_name,
             query_user_name,
             started_time
       into  monitoring_job_name,
             monitoring_client_name,
             monitoring_query_user_name,
             monitoring_started_time
      from streams$_pa_monitoring
      where state = 'STARTED';
    exception when others then
      null;
    end;
  end LOAD_MONITORING_INFO;

  ----------------------------------------------------------------------------=
  -- SAVE_CONTROL_PARAMS
  --   Persist advisor control parameters upon each advisor run.
  ----------------------------------------------------------------------------=
  procedure SAVE_CONTROL_PARAMS(run_id in number, run_time date)
  as
  begin

    -----------------------------------------
    -- Persist advisor control parameters. --
    -----------------------------------------
    -- PARAM_NAME:
    --   INTERVAL
    --   RETENTION_TIME
    --   TOP_EVENT_THRESHOLD
    --   BOTTLENECK_IDLE_THRESHOLD
    --   BOTTLENECK_FLOWCTRL_THRESHOLD

    insert into streams$_pa_control(
           advisor_run_id,
           advisor_run_time,
           param_name,
           param_value,
           param_unit)
    values(run_id,
           run_time,
           'INTERVAL',
           param_interval,
           'SECOND');
    commit;
    
    insert into streams$_pa_control(
           advisor_run_id,
           advisor_run_time,
           param_name,
           param_value,
           param_unit)
    values(run_id,
           run_time,
           'RETENTION_TIME',
           param_retention_time,
           'HOUR');
    commit;

    insert into streams$_pa_control(
           advisor_run_id,
           advisor_run_time,
           param_name,
           param_value,
           param_unit)
    values(run_id,
           run_time,
           'TOP_EVENT_THRESHOLD',
           param_top_event_threshold,
           'PERCENT');
    commit;

    insert into streams$_pa_control(
           advisor_run_id,
           advisor_run_time,
           param_name,
           param_value,
           param_unit)
    values(run_id,
           run_time,
           'BOTTLENECK_IDLE_THRESHOLD',
           param_bot_idle_threshold,
           'PERCENT');
    commit;

    insert into streams$_pa_control(
           advisor_run_id,
           advisor_run_time,
           param_name,
           param_value,
           param_unit)
    values(run_id,
           run_time,
           'BOTTLENECK_FLOWCTRL_THRESHOLD',
           param_bot_flowctrl_threshold,
           'PERCENT');
    commit;

  end SAVE_CONTROL_PARAMS;

  ----------------------------------------------------------------------------=
  -- RECOVER_CONTROL_PARAMS
  --   Load advisor control parameters upon each advisor run.
  ----------------------------------------------------------------------------=
  procedure RECOVER_CONTROL_PARAMS
  as
    cnt number := 0;
  begin
    begin
      select count(*) into cnt
      from streams$_pa_monitoring
      where state = 'STARTED';

      if (cnt = 0) then
        -- Someone manually deletes monitoring information for an active job.
        insert into streams$_pa_monitoring(
               job_name,
               client_name,
               query_user_name,
               started_time,
               altered_time,
               state)
        values(monitoring_job_name,
               monitoring_client_name,
               monitoring_query_user_name,
               monitoring_started_time,
               monitoring_altered_time,
               'STARTED');
        commit;
      end if;
    exception when others then
      null;
    end;

    begin
      select count(advisor_run_id) into cnt
      from streams$_pa_control
      where advisor_run_id = 0;

      if (cnt < total_param_cnt) then
         -- Someone manually deletes some control parameters.
         delete from streams$_pa_control where advisor_run_id = 0;
         commit;
         
         -- update using current control parameters.
         SAVE_CONTROL_PARAMS(0, null);
      end if;
    exception when others then
      null;
    end;

  end RECOVER_CONTROL_PARAMS;

  ----------------------------------------------------------------------------=
  -- LOAD_CONTROL_PARAMS
  --   Load advisor control parameters upon each advisor run.
  ----------------------------------------------------------------------------=
  procedure LOAD_CONTROL_PARAMS
  as
    alt_time timestamp := null;
  begin

    ------------------------------------------------
    -- Check and load advisor control parameters. --
    ------------------------------------------------
    begin
      select nvl(altered_time, started_time) into alt_time
      from streams$_pa_monitoring
      where state = 'STARTED';
    exception when others then
      alt_time := null;
    end;

    if(monitoring_altered_time is null or
       monitoring_altered_time < alt_time) then
      monitoring_altered_time := alt_time;

      begin
        select param_value into param_interval
        from streams$_pa_control
        where advisor_run_id = 0 and
              advisor_run_time is null and
              param_name = 'INTERVAL';
      exception when others then
        null;
      end;

      begin
        select param_value into param_retention_time
        from streams$_pa_control
        where advisor_run_id = 0 and
              advisor_run_time is null and
              param_name = 'RETENTION_TIME';

        -- Set advisor retention_time.
        -- No need to use monitoring API's retention_time
        -- since all we need is to keep the latest advisor run.
        dbms_streams_advisor_adm.retention_time
          := param_interval * 0.9 / seconds_per_hour;
      exception when others then
        null;
      end;

      begin
        select param_value into param_top_event_threshold
        from streams$_pa_control
        where advisor_run_id = 0 and
              advisor_run_time is null and
              param_name = 'TOP_EVENT_THRESHOLD';
      exception when others then
        null;
      end;

      begin
        select param_value into param_bot_idle_threshold
        from streams$_pa_control
        where advisor_run_id = 0 and
              advisor_run_time is null and
              param_name = 'BOTTLENECK_IDLE_THRESHOLD';

        -- Set bottleneck_idle_threshold
        dbms_streams_advisor_adm.bottleneck_idle_threshold
          := param_bot_idle_threshold;
      exception when others then
        null;
      end;

      begin
        select param_value into param_bot_flowctrl_threshold
        from streams$_pa_control
        where advisor_run_id = 0 and
              advisor_run_time is null and
              param_name = 'BOTTLENECK_FLOWCTRL_THRESHOLD';

        -- bottleneck_flowctrl_threshold
        dbms_streams_advisor_adm.bottleneck_flowctrl_threshold
          := param_bot_flowctrl_threshold;
      exception when others then
        null;
      end;
    end if;

  end LOAD_CONTROL_PARAMS;

  ----------------------------------------------------------------------------=
  -- CLEAN_RETENTION
  --   Perform retention cleanup upon each advisor run.
  ----------------------------------------------------------------------------=
  procedure CLEAN_RETENTION(run_time date)
  as
    oldest_time date; 
  begin
    oldest_time := run_time - param_retention_time/24;

    delete from streams$_pa_control
    where advisor_run_time < oldest_time;
    commit;

    delete from streams$_pa_component_stat
    where advisor_run_time < oldest_time;
    commit;

    delete from streams$_pa_path_bottleneck
    where advisor_run_time < oldest_time;
    commit;

    delete from streams$_pa_path_stat
    where advisor_run_time < oldest_time;
    commit;

    delete from streams$_pa_monitoring
    where stopped_time is not null and stopped_time < oldest_time;
    commit;

    delete from streams$_pa_show_comp_stat
    where advisor_run_time < oldest_time;
    commit;

    delete from streams$_pa_show_path_stat
    where advisor_run_time < oldest_time;
    commit;
  end CLEAN_RETENTION;

  ----------------------------------------------------------------------------=
  -- PERSIST_ADVISOR_RUN
  --   Persist statistics for all active stream paths for a given advisor run.
  ----------------------------------------------------------------------------=
  procedure PERSIST_ADVISOR_RUN(run_id in number)
  as
    type cur_type is ref cursor;
    run_time     date := null;
    path_key     varchar2(4000) := null;
    path_id      number;
    path_id_cur  cur_type;
    bottleneck   varchar2(4000) := null;
  begin
    select advisor_run_time into run_time
    from (select max(advisor_run_time) as advisor_run_time
          from DBA_STREAMS_TP_PATH_STAT where advisor_run_id = run_id);

    -- upsert streams$_pa_database.
    merge into streams$_pa_database T
    using (select global_name,
                  last_queried
          from dba_streams_tp_database) N
    on (T.global_name = N.global_name)
    when matched then
         update set T.last_queried = N.last_queried
    when not matched then
         insert (T.global_name, T.last_queried)
         values (N.global_name, N.last_queried);
    commit;

    -- upsert streams$_pa_database_prop.
    merge into streams$_pa_database_prop T
    using (select global_name as global_name,
                  'VERSION'   as prop_name,
                  version     as prop_value
          from dba_streams_tp_database) N
    on (T.global_name = N.global_name and T.prop_name = N.prop_name)
    when matched then
         update set T.prop_value = N.prop_value
    when not matched then
         insert (T.global_name, T.prop_name, T.prop_value)
         values (N.global_name, N.prop_name, N.prop_value);

    merge into streams$_pa_database_prop T
    using (select global_name     as global_name,
                  'COMPATIBILITY' as prop_name,
                   compatibility  as prop_value
          from dba_streams_tp_database) N
    on (T.global_name = N.global_name and T.prop_name = N.prop_name)
    when matched then
         update set T.prop_value = N.prop_value
    when not matched then
         insert (T.global_name, T.prop_name, T.prop_value)
         values (N.global_name, N.prop_name, N.prop_value);

    merge into streams$_pa_database_prop T
    using (select global_name              as global_name,
                  'MANAGEMENT_PACK_ACCESS' as prop_name,
                   management_pack_access  as prop_value
          from dba_streams_tp_database) N
    on (T.global_name = N.global_name and T.prop_name = N.prop_name)
    when matched then
         update set T.prop_value = N.prop_value
    when not matched then
         insert (T.global_name, T.prop_name, T.prop_value)
         values (N.global_name, N.prop_name, N.prop_value);
    commit;

    -- check each db_link to get DB_UNIQUE_NAME or ERROR_NUMBER/VERSION.
    CHECK_DATABASE_LINKS();

    -- remove those databases which have never been queried.
    delete from streams$_pa_database_prop
    where global_name in (select global_name
                          from streams$_pa_database
                          where last_queried is null);
    commit;
    delete from streams$_pa_database
    where last_queried is null;
    commit;

    -- upsert streams$_pa_component.
    merge into streams$_pa_component T
    using (select component_id,
                  component_name,
                  component_db,
                  component_type,
                  component_changed_time
           from dba_streams_tp_component) N
    on (T.component_id = N.component_id)
    when matched then
        update set T.component_changed_time = N.component_changed_time
    when not matched then
        insert (T.component_id,
                T.component_name,
                T.component_db,
                T.component_type,
                T.component_changed_time)
        values (N.component_id,
                N.component_name,
                N.component_db,
                N.component_type,
                N.component_changed_time);
    commit;

    -- upsert streams$_pa_component_link.
    merge into streams$_pa_component_link T
    using (select path_id,
                  position,
                  source_component_id,
                  destination_component_id
           from dba_streams_tp_component_link) N
    on (T.path_id = N.path_id and
        T.position = N.position and
        T.source_component_id = N.source_component_id and
        T.destination_component_id = N.destination_component_id)
    when not matched then
        insert (T.path_id,
                T.position,
                T.source_component_id,
                T.destination_component_id)
        values (N.path_id,
                N.position,
                N.source_component_id,
                N.destination_component_id);
    commit;

    -- persist component properties.
    delete from streams$_pa_component_prop;
    commit;
    insert into streams$_pa_component_prop(
           component_id,
           prop_name,
           prop_value)
    select component_id,
           prop_name,
           prop_value
    from "_DBA_STREAMS_TP_COMPONENT_PROP";
    commit;

    -- persist component statistics.
    insert into streams$_pa_component_stat(
           advisor_run_id,
           advisor_run_time,
           component_id,
           sub_component_type,
           session_id,
           session_serial#,
           statistic_time,
           statistic_name,
           statistic_value,
           statistic_unit, 
           spare3)
    select advisor_run_id,
           advisor_run_time,
           component_id,
           sub_component_type,
           session_id,
           session_serial#,
           statistic_time,
           statistic_name,
           -- The state statistic will be a varchar2, store this in spare3
           decode(statistic_name,
                  'STATE', 0,
                  statistic_value),
           statistic_unit,
           -- Spare3 will store varchar2 statistic values
           decode(statistic_name,
                  'STATE', statistic_value,
                  NULL)
    from DBA_STREAMS_TP_COMPONENT_STAT
    where advisor_run_id = PERSIST_ADVISOR_RUN.run_id;
    commit;

    -- persist path statistics.
    insert into streams$_pa_path_stat(
           advisor_run_id,
           advisor_run_time,
           path_id,
           statistic_time,
           statistic_name,
           statistic_value,
           statistic_unit)
    select advisor_run_id,
           advisor_run_time,
           path_id,
           statistic_time,
           statistic_name,
           statistic_value,
           statistic_unit
    from DBA_STREAMS_TP_PATH_STAT
    where advisor_run_id = PERSIST_ADVISOR_RUN.run_id;
    commit;

    -- persist path bottleneck information.
    insert into streams$_pa_path_bottleneck(
           advisor_run_id,
           advisor_run_time,
           advisor_run_reason,
           path_id,
           component_id,
           top_session_id,
           top_session_serial#,
           action_name,
           bottleneck_identified)
    select advisor_run_id,
           advisor_run_time,
           advisor_run_reason,
           path_id,
           component_id,
           top_session_id,
           top_session_serial#,
           action_name,
           bottleneck_identified
    from DBA_STREAMS_TP_PATH_BOTTLENECK
    where advisor_run_id = PERSIST_ADVISOR_RUN.run_id;
    commit;
    
    -- EM requires path_key to uniquely identify a stream path.
    --
    -- path_key: apply_name@apply_database_global_name.
    -- 
    -- Streams performance advisor reports only complete path
    -- starting with CAPTURE and ending with APPLY. The apply
    -- name and database is the unique key for stream path.

    -- update path_key for apply component
    update streams$_pa_component_link L
    set path_key = (
        select distinct (component_name || '@' || component_db)
        from streams$_pa_component C
        where C.component_type = 'APPLY' and 
              C.component_id = L.destination_component_id);
    commit;

    -- update path_key for other components
    update streams$_pa_component_link L
    set path_key = (
        select distinct  L2.path_key
        from streams$_pa_component C,
             streams$_pa_component_link L2
        where L.path_id = L2.path_id and
              C.component_type = 'APPLY' and 
              C.component_id = L2.destination_component_id);
    commit;
    
    -- update path_key for path stat
    update streams$_pa_path_stat T
    set path_key = (
        select distinct L.path_key
        from streams$_pa_component_link L
        where T.path_id = L.path_id)
    where advisor_run_id = PERSIST_ADVISOR_RUN.run_id and
          advisor_run_time = run_time;
    commit;

    -- update path_key for path bottleneck
    update streams$_pa_path_bottleneck T
    set path_key = (
        select distinct L.path_key
        from streams$_pa_component_link L
        where T.path_id = L.path_id)
    where advisor_run_id = PERSIST_ADVISOR_RUN.run_id and
          advisor_run_time = run_time;
    commit;

     -- Update bottleneck output for html report
     open path_id_cur for 'select distinct path_id from ' || 
                          ' DBA_STREAMS_TP_PATH_BOTTLENECK';
     loop
       fetch path_id_cur into path_id;
       exit when path_id_cur%notfound;
       
       bottleneck := get_bottleneck_html(PERSIST_ADVISOR_RUN.run_id, 
                                         path_id);

       update streams$_pa_path_bottleneck B
       set B.spare3 =  bottleneck
       where B.advisor_run_id = PERSIST_ADVISOR_RUN.run_id 
             and B.path_id =  PERSIST_ADVISOR_RUN.path_id;
       commit;
     end loop;
     close path_id_cur;

    -- persist advisor control parameters.
    SAVE_CONTROL_PARAMS(run_id, run_time);

    -- recover monitoring and control params.
    RECOVER_CONTROL_PARAMS();

    -- reload control params in case of altering.
    LOAD_CONTROL_PARAMS();

    -- clean obsolete data based on retention_time.
    CLEAN_RETENTION(run_time);

  end PERSIST_ADVISOR_RUN;

  ----------------------------------------------------------------------------=
  -- PERSIST_ADVISOR_RUNS
  --   Collect statistics for all active stream paths and
  --   save in the persistent tables.
  ----------------------------------------------------------------------------=
  procedure PERSIST_ADVISOR_RUNS(comp_stat_tbl in varchar2,
                                 path_stat_tbl in varchar2)
  as
    prev_time     date;
    curr_time     date;
    sleep_time    number := 0;
    last_run_id   number := 0;
  begin
    -- Get the last advisor_run_id
    begin
      select max(advisor_run_id) into last_run_id
      from dba_streams_tp_component_stat;
  
      if last_run_id is null then
        last_run_id := 0;
      end if;
    end;

    -- Load advisor control parameters before the first advisor run
    LOAD_CONTROL_PARAMS();

    -- Load advisor monitoring information before the first advisor run
    LOAD_MONITORING_INFO();

    -- No exit condition. Monitoring is only stopped by stop_monitoring.
    while(TRUE)
    loop
      prev_time := sysdate();
      dbms_streams_advisor_adm.analyze_current_performance;
      curr_time := sysdate();
  
      last_run_id := last_run_id + 1;
      dbms_output.put_line('Run ' || last_run_id);

      -- Save line-display statistics
      PERSIST_LINE_DISPLAY(last_run_id, comp_stat_tbl, path_stat_tbl);

      -- Save result for each advisor run
      PERSIST_ADVISOR_RUN(last_run_id);

      sleep_time := param_interval - (curr_time - prev_time) * 86400;
      if sleep_time > 0 then
        dbms_lock.sleep(sleep_time);
      end if;
    end loop;

    -- Update monitoring job state in case of auto-drop
    update streams$_pa_monitoring
    set state = 'STOPPED', stopped_time = systimestamp
    where state = 'STARTED';
    commit;

  end PERSIST_ADVISOR_RUNS;

  ----------------------------------------------------------------------------=
  -- ALTER_MONITORING_PARAM
  --   Alter Streams monitoring job control parameter.
  ----------------------------------------------------------------------------=
  procedure ALTER_MONITORING_PARAM(p_name       IN VARCHAR2,
                                   p_value      IN VARCHAR2,
                                   p_unit       IN VARCHAR2,
                                   altered_time IN TIMESTAMP DEFAULT NULL)
  as
  begin

    merge into streams$_pa_control T
    using (select p_value as param_value from dual) N
    on (T.advisor_run_id = 0 and
        T.advisor_run_time is null and
        T.param_name = p_name)
    when matched then
        update set T.param_value = N.param_value
    when not matched then
        insert (T.advisor_run_id,
                T.advisor_run_time,
                T.param_name,
                T.param_value,
                T.param_unit)
        values (0, null, p_name, p_value, p_unit);
    commit;

    if (altered_time is not null) then
      update streams$_pa_monitoring T
      set T.altered_time = ALTER_MONITORING_PARAM.altered_time
      where T.state = 'STARTED';
      commit;
    end if;

  end ALTER_MONITORING_PARAM;

  ----------------------------------------------------------------------------=
  -- CHECK_JOB_CONFLICT
  --   EM agent must have client_name set to to 'EM'.
  --   No more than one active monitoring job exists at any time.
  --
  -- RAISED EXCEPTIONS:
  --
  -- ORA-20111:
  --   cannot start monitoring due to active EM monitoring job
  -- ORA-20112:
  --   cannot start monitoring due to active Streams monitoring job
  --
  ----------------------------------------------------------------------------=
  procedure CHECK_JOB_CONFLICT(canon_job_name    varchar2,
                               canon_client_name varchar2)
  as
    sch_job_cnt number := 0;
    monitoring boolean := FALSE;
    active_cnt number := 0;
    active_em_cnt number := 0;
    canon_submit_job_name varchar(30) := null;
  begin
    select count(*) into active_cnt
    from streams$_pa_monitoring
    where state = 'STARTED';

    if (active_cnt = 0) then
      -- Check if there is an EM monitoring job per database.
      if ((canon_client_name is not null)
           and (canon_client_name = 'EM')
           and IS_MONITORING(canon_job_name, canon_client_name)) then
        raise_application_error(-20111,
          'cannot start monitoring ' ||
          'due to active EM monitoring job');
      end if;
    else
      if canon_client_name is not null then
         canon_submit_job_name := canon_job_name ||'_'|| canon_client_name;
      else
         canon_submit_job_name := canon_job_name;
      end if;

      begin
        select count(*) into sch_job_cnt from dba_scheduler_jobs
        where enabled = 'TRUE' and
              job_name = canon_submit_job_name;
      exception when others then
        sch_job_cnt := 0;
      end;

      if (sch_job_cnt = 0) then
        -- no scheduled job is found, database may be bounced.
        update streams$_pa_monitoring set state = 'STOPPED'
        where job_name = canon_job_name and
              client_name||'X' = canon_client_name||'X';
        commit;
      else
        select count(*) into active_em_cnt
        from streams$_pa_monitoring
        where state = 'STARTED' and client_name = 'EM';

        if (active_em_cnt > 0) then
          raise_application_error(-20111,
            'cannot start monitoring '||
            'due to active EM monitoring job');
        else
          raise_application_error(-20112,
            'cannot start monitoring '||
            'due to active Streams monitoring job');
        end if;
      end if;
    end if;

  end CHECK_JOB_CONFLICT;

  ----------------------------------------------------------------------------=
  -- COLLECT_STATS
  --   Collect statistics for all active stream paths.
  ----------------------------------------------------------------------------=
  procedure COLLECT_STATS(
    interval                  in number   default 60,
    num_runs                  in number   default 10,
    comp_stat_table           in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_stat_table           in varchar2 default 'STREAMS$_ADVISOR_PATH_STAT',
    top_event_threshold       in number   default 15,
    bottleneck_idle_threshold in number   default 50,
    bottleneck_flowctrl_threshold in number default 50)
  as
    prev_time     date;
    curr_time     date;
    sleep_time    number := 0;
    last_run_id   number := 0;
    comp_stat_tbl varchar2(30);
    path_stat_tbl varchar2(30);
    param_setting varchar2(2000);

    cnt           number := 0;
    monitoring    boolean:= FALSE;
    job_started   boolean:= FALSE;
  begin
    -- Initialize the tables if they do not exist 
    comp_stat_tbl := INIT_SPADV_COMP_STAT(comp_stat_table);
    path_stat_tbl := INIT_SPADV_PATH_STAT(path_stat_table);

    -- Check if invoked by START_MONITORING
    begin
      select count(*) into cnt
      from streams$_pa_monitoring
      where state = 'STARTED';

      if cnt > 0 then
        job_started := TRUE;
      end if;
    exception when others then
      job_started := FALSE;
    end;

    -- Check control parameters
    if (nvl(interval, 60) < 1) then
      raise_application_error(-20100, 'Invalid interval, too small');
    end if;

    if (nvl(num_runs, 10) < 1) then
      raise_application_error(-20100, 'Invalid num_runs, too small');
    end if;

    if (nvl(top_event_threshold, 15) < 0 or
        nvl(top_event_threshold, 15) > 100 ) then
      raise_application_error(-20100, 'Invalid top_event_threshold');
    end if;
  
    if (nvl(bottleneck_idle_threshold, 50) < 0 or
        nvl(bottleneck_idle_threshold, 50) > 100 ) then
      raise_application_error(-20100, 'Invalid bottleneck_idle_threshold');
    end if;
  
    if (nvl(bottleneck_flowctrl_threshold, 50) < 0 or
        nvl(bottleneck_flowctrl_threshold, 50) > 100 ) then
      raise_application_error(-20100, 'Invalid bottleneck_flowctrl_threshold');
    end if;
  
    param_interval               := nvl(interval, 60); -- in seconds
    param_top_event_threshold    := nvl(top_event_threshold, 15);
    param_bot_idle_threshold     := nvl(bottleneck_idle_threshold, 50);
    param_bot_flowctrl_threshold := nvl(bottleneck_flowctrl_threshold, 50);

    -- Set bottleneck_idle_threshold and bottleneck_flowctrl_threshold
    dbms_streams_advisor_adm.bottleneck_idle_threshold
      := param_bot_idle_threshold;
    dbms_streams_advisor_adm.bottleneck_flowctrl_threshold
      := param_bot_flowctrl_threshold;

    -- check if invoked by start_monitoring.
    if job_started = TRUE then
      if(comp_stat_tbl <> 'STREAMS$_PA_SHOW_COMP_STAT' or
         path_stat_tbl <> 'STREAMS$_PA_SHOW_PATH_STAT' ) then
        monitoring := FALSE;
      else
        monitoring := TRUE;
      end if;
    else
      monitoring := FALSE;
    end if;

    --
    -- START_MONITORING
    --
    if monitoring = TRUE then
      PERSIST_ADVISOR_RUNS(comp_stat_tbl, path_stat_tbl);
      return;
    end if;

    if (monitoring = FALSE and num_runs is null) then
      raise_application_error(-20100, 'Invalid num_runs, '||
                                      'cannot be NULL without monitoring');
    end if;

    --
    -- COLLECT_STATS (blocking-mode)
    --

    -- Get the last advisor_run_id
    begin
      select max(advisor_run_id) into last_run_id
      from dba_streams_tp_component_stat;
  
      if last_run_id is null then
        last_run_id := 0;
      end if;
    end;
  
    for i in 1 .. nvl(num_runs, 10) loop
      prev_time := sysdate();
      dbms_streams_advisor_adm.analyze_current_performance;
      curr_time := sysdate();
  
      -- Save result for each run
      last_run_id := last_run_id + 1;
      dbms_output.put_line('Run ' || last_run_id);

      PERSIST_LINE_DISPLAY(last_run_id,
                           comp_stat_tbl,
                           path_stat_tbl,
                           TRUE, TRUE);
  
      -- No sleep for the last run
      if (i < num_runs) then
        sleep_time := interval - (curr_time - prev_time) * 86400;
        if sleep_time > 0 then
          dbms_lock.sleep(sleep_time);
        end if;
      end if;
    end loop;
  end COLLECT_STATS;

  ----------------------------------------------------------------------------=
  -- SHOW_STATS
  --   Print statistics for a stream path.
  ----------------------------------------------------------------------------=
  procedure SHOW_STATS(
    path_stat_table   in varchar2 default 'STREAMS$_ADVISOR_PATH_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10,
    show_path_id      in boolean  default TRUE,
    show_run_id       in boolean  default TRUE,
    show_run_time     in boolean  default TRUE,
    show_optimization in boolean  default TRUE,
    show_setting      in boolean  default FALSE,
    show_stat         in boolean  default TRUE,
    show_sess         in boolean  default FALSE,
    show_legend       in boolean  default TRUE
  ) as
    type cur_type is ref cursor;
    type stat_rec_type is record(
              path_id            number,
              advisor_run_id     number,
              advisor_run_time   date,
              setting            varchar2(200),
              statistics         varchar2(4000),
              session_statistics varchar2(4000),
              optimization       number);
    cur       cur_type;
    stat_rec  stat_rec_type;
    svalue    varchar2(2000);
    stmt      varchar2(2000);
    stmt_run  varchar2(2000);
    chk_table varchar2(30);
  begin

    if (upper(path_stat_table) = 'STREAMS$_ADVISOR_PATH_STAT') then
       -- Initialize the table if the default table does not exist.
       chk_table := INIT_SPADV_PATH_STAT(path_stat_table);
    else
       -- Check if the user specified path stat table exists.
       chk_table := CHECK_SPADV_PATH_STAT(path_stat_table);
    end if;

    -- Print the legend
    if show_legend = TRUE then 
      dbms_output.put_line('LEGEND');
      dbms_output.put_line(
        '<statistics>= <capture> [ <queue> <psender> <preceiver> <queue> ] '||
        '<apply> <bottleneck>');
  
      dbms_output.put_line(
        '<capture>   = ''|<C>'' <name> <msgs captured/sec> '||
        '<msgs enqueued/sec> <latency>');
      dbms_output.put_line(chr(9)||'            '||
        '''LMR'' <idl%> <flwctrl%> <topevt%> <topevt>');
      dbms_output.put_line(chr(9)||'            '||
        '''LMP'' (<parallelism>) <idl%> <flwctrl%> <topevt%> <topevt>');
      dbms_output.put_line(chr(9)||'            '||
        '''LMB'' <idl%> <flwctrl%> <topevt%> <topevt>');
      dbms_output.put_line(chr(9)||'            '||
        '''CAP'' <idl%> <flwctrl%> <topevt%> <topevt>');
      dbms_output.put_line(chr(9)||'            '||
        '''CAP+PS'' <msgs sent/sec> <bytes sent/sec> ' ||
        '<latency> <idl%> <flwctrl%> <topevt%> <topevt>');
  
      dbms_output.put_line(
        '<apply>     = ''|<A>'' <name> <msgs applied/sec> ' ||
        '<txns applied/sec> <latency>');
      dbms_output.put_line(chr(9)||'            '||
        '''PS+PR'' <idl%> <flwctrl%> <topevt%> <topevt>');
      dbms_output.put_line(chr(9)||'            '||
        '''APR'' <idl%> <flwctrl%> <topevt%> <topevt>');
      dbms_output.put_line(chr(9)||'            '||
        '''APC'' <idl%> <flwctrl%> <topevt%> <topevt>');
      dbms_output.put_line(chr(9)||'            '||
        '''APS'' (<parallelism>) <idl%> <flwctrl%> <topevt%> <topevt>');
  
      dbms_output.put_line(
        '<queue>     = ''|<Q>'' <name> <msgs enqueued/sec> '||
        '<msgs spilled/sec> <msgs in queue>');
      dbms_output.put_line(
        '<psender>   = ''|<PS>'' <name> <msgs sent/sec> <bytes sent/sec> '||
        '<latency> <idl%> <flwctrl%> <topevt%> <topevt>');
      dbms_output.put_line(
        '<preceiver> = ''|<PR>'' <name> <idl%> <flwctrl%> <topevt%> <topevt>');
      dbms_output.put_line(
        '<bottleneck>= ''|<B>'' <name> <sub_name> '||
        '<sessionid> <serial#> <topevt%> <topevt>');
      dbms_output.put_line(chr(10));
      dbms_output.put_line('OUTPUT');
    end if;
  
    -- Check arguments
    if (path_id is not null and path_id < 1) then
      raise_application_error(-20100, 'Invalid path_id');
    end if;
    if (bgn_run_id is null or bgn_run_id = 0) then
      raise_application_error(-20100, 'Invalid bgn_run_id');
    end if;
    if (end_run_id is null or end_run_id = 0) then
      raise_application_error(-20100, 'Invalid end_run_id');
    end if;
  
    -- Start with the first run (1)
    if (bgn_run_id > 0 and bgn_run_id > end_run_id) then
      raise_application_error(-20100, 'Invalid end_run_id');
    end if;
    -- Start with the latest run (-1)
    if (bgn_run_id < 0 and bgn_run_id < end_run_id ) then
      raise_application_error(-20100, 'Invalid end_run_id');
    end if;
  
    stmt_run :=
      case when bgn_run_id > 0 then
            '(select ' || bgn_run_id || ' as bgn_run_id, '
                       || end_run_id || ' as end_run_id from dual)'
           else 
            '(select distinct ' ||
            '  (latest_run_id + ' || end_run_id || ' + 1) as bgn_run_id, ' ||
            '  (latest_run_id + ' || bgn_run_id || ' + 1) as end_run_id  ' ||
            ' from ( select advisor_run_id as latest_run_id ' ||
                   ' from ' || upper(chk_table) ||
                   ' where advisor_run_time in (' ||
                          ' select max(advisor_run_time) ' ||
                          ' from ' || upper(chk_table) || ') ) )'
      end;
  
    stmt :=
      'select S.path_id, S.advisor_run_id, S.advisor_run_time, ' ||
      '       S.setting, S.statistics, S.session_statistics, S.optimization '||
      'from ' || upper(chk_table) || ' S, ' || stmt_run || ' R, ' ||
      '     ( select distinct path_id ' ||
      '       from dba_streams_tp_component_link ) P ' ||
      'where S.advisor_run_id >= R.bgn_run_id ' ||
      '  and S.advisor_run_id <= R.end_run_id ' ||
      '  and S.path_id = P.path_id ' ||
      case when path_id is NULL then NULL
           else ' and S.path_id  = ' || path_id
      end ||
      ' order by P.path_id, S.advisor_run_time, S.advisor_run_id';
  
    begin
      open cur for stmt;
      loop
        fetch cur into stat_rec;
        exit when cur%notfound;
  
        -- Print PATH RUN_ID RUN_TIME
        -- PATH 2  RUN_ID 8  RUN_TIME 29-MAY-007 15:58:04
        svalue := null;
        if show_path_id = TRUE then
          svalue := 'PATH ' || stat_rec.path_id;
        end if;
  
        if show_run_id = TRUE then
          svalue := case when svalue is null then null
                         else svalue || ' ' end ||
                    'RUN_ID ' || stat_rec.advisor_run_id;
        end if;
  
        if show_run_time = TRUE then
          svalue := case when svalue is null then null
                         else svalue || ' ' end ||
                    'RUN_TIME ' ||
                 to_char(stat_rec.advisor_run_time, 'YYYY-MON-DD HH24:MI:SS');
        end if;

        if show_optimization = TRUE then
          svalue := case when svalue is null then null
                         else svalue || ' ' end ||
                    'CCA ' ||
                    case when stat_rec.optimization = 0
                         then 'N'
                         else 'Y'
                    end;
        end if;
  
        if svalue is not null then
          dbms_output.put_line(svalue);
        end if;
  
        -- Print SETTING
        if show_setting = TRUE then
          dbms_output.put_line(stat_rec.setting);
        end if;
  
        -- Print STATISTICS
        if show_stat = TRUE then
          dbms_output.put_line(stat_rec.statistics);
        end if;
  
        -- Print SESSION_STATISTICS
        if show_sess = TRUE then
          dbms_output.put_line(stat_rec.session_statistics);
        end if;
  
        dbms_output.put_line(chr(10));
      end loop;
      close cur;
    exception when others then
      if cur%isopen then
        close cur;
      end if;
      raise;
    end;
  
  end SHOW_STATS;

  ----------------------------------------------------------------------------=
  -- GET_ACTIVE_JOB_NAME
  --   Gets the scheduled job name;
  ----------------------------------------------------------------------------=
  function GET_ACTIVE_JOB_NAME return varchar2
  as
    active_job_name varchar(30) := null;
  begin
    begin
      select case when client_name is null then job_name
                  else job_name || '_' || client_name
             end into active_job_name
      from streams$_pa_monitoring
      where state = 'STARTED';
    exception when others then
      active_job_name := null;
    end;

    return active_job_name;
  end GET_ACTIVE_JOB_NAME;

  ----------------------------------------------------------------------------=
  -- GET_LATEST_JOB_NAME
  --   Gets the most recently scheduled job name;
  ----------------------------------------------------------------------------=
  function GET_LATEST_JOB_NAME return varchar2
  as
    latest_job_name varchar(30) := null;
  begin
    -- don't care if STARTED or not
    begin
      select job_name into latest_job_name
      from ( select case when client_name is null then job_name
                         else job_name || '_' || client_name
                    end as job_name 
             from streams$_pa_monitoring
             order by started_time desc )
      where rownum = 1;
    exception when others then
      latest_job_name := null;
    end;

    return latest_job_name;
  end GET_LATEST_JOB_NAME;

  ----------------------------------------------------------------------------=
  -- IS_MONITORING
  --   Checks if a client has submitted a monitoring job.
  ----------------------------------------------------------------------------=
  function IS_MONITORING(
    job_name    IN VARCHAR2 DEFAULT 'STREAMS$_MONITORING_JOB',
    client_name IN VARCHAR2 DEFAULT NULL) return BOOLEAN
  as
    ret                   NUMBER := 0;
    tbl                   VARCHAR2(30) := null;
    canon_job_name        VARCHAR2(30) := null;
    canon_client_name     VARCHAR2(30) := null;
    canon_submit_job_name VARCHAR2(30) := null;
  begin
    -- check table
    tbl := INIT_TBL_PA_MONITORING();

    if job_name is null then
      canon_job_name := 'STREAMS$_MONITORING_JOB';
    else
      dbms_utility.canonicalize(job_name, canon_job_name, 30);
    end if;

    if client_name is not null then
      dbms_utility.canonicalize(client_name, canon_client_name, 30);
    end if;

    if canon_client_name is not null then
       if not ((length(canon_job_name) + length(canon_client_name)) < 30) then
         raise_application_error(-20100,
           'Combined length of job_name and client_name must be less than 30');
       end if;

       dbms_utility.canonicalize(
         canon_job_name ||'_'|| canon_client_name, canon_submit_job_name, 30);
    else
       canon_submit_job_name := canon_job_name;
    end if;

    -- At most one EM monitoring job per database.
    if (canon_client_name is not null and canon_client_name = 'EM') then
      begin
        select 1 into ret from dba_scheduler_jobs
        where enabled = 'TRUE' and
              job_name = canon_submit_job_name;
      exception when others then
        ret := 0;
      end;
    else
    -- At most one monitoring job per schema.
      begin
        select 1 into ret from streams$_pa_monitoring
        where state = 'STARTED' and
              job_name = canon_job_name and
              client_name||'X' = canon_client_name||'X';
      exception when others then
        ret := 0;
      end;

    end if;

    if ret = 1 then
      return TRUE;
    else
      return FALSE;
    end if;

  end IS_MONITORING;

  ----------------------------------------------------------------------------=
  -- GRANT_PRIVILEGE
  --   Grant select privilege to query user.
  ----------------------------------------------------------------------------=
  procedure GRANT_PRIVILEGE(canon_query_user in VARCHAR2)
  as
    stmt varchar2(400) := null;
    head varchar2(100) := null;
    tail varchar2(100) := null;
  begin
    head := 'GRANT SELECT ON ';
    tail := ' TO ' || canon_query_user;

    stmt := head || 'STREAMS$_PA_MONITORING' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_DATABASE' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_DATABASE_PROP' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_CONTROL' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_COMPONENT' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_COMPONENT_PROP' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_COMPONENT_LINK' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_COMPONENT_STAT' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_PATH_STAT' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_PATH_BOTTLENECK' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_SHOW_COMP_STAT' || tail;
    execute immediate stmt;
    
    stmt := head || 'STREAMS$_PA_SHOW_PATH_STAT' || tail;
    execute immediate stmt;
    
  end GRANT_PRIVILEGE;
  
  ----------------------------------------------------------------------------=
  -- START_MONITORING
  -- 
  -- Raised Exceptions:
  --   ORA-20100:
  --     'Invalid interval, too small'
  --     'Invalid top_event_threshold'
  --     'Invalid bottleneck_idle_threshold'
  --     'Invalid bottleneck_flowctrl_threshold'
  --     'Invalid retention_time, too small'
  --     'Combined length of job_name and client_name must be less than 30'
  --
  ----------------------------------------------------------------------------=
  procedure START_MONITORING(
    job_name                     IN VARCHAR2 DEFAULT 'STREAMS$_MONITORING_JOB',
    client_name                  IN VARCHAR2 DEFAULT NULL,
    query_user_name              IN VARCHAR2 DEFAULT NULL,
    interval                     IN NUMBER DEFAULT 60,
    top_event_threshold          IN NUMBER DEFAULT 15,
    bottleneck_idle_threshold    IN NUMBER DEFAULT 50,
    bottleneck_flowctrl_threshold IN NUMBER DEFAULT 50,
    retention_time                IN NUMBER DEFAULT 24)
  as
    tbl                   VARCHAR2(30) := null;
    canon_job_name        VARCHAR2(30) := null;
    canon_client_name     VARCHAR2(30) := null;
    canon_query_user_name VARCHAR2(30) := null;
    canon_submit_job_name VARCHAR2(30) := null;
    start_monitoring_time timestamp := systimestamp;
  begin
    -- Check tables
    tbl := INIT_TBL_PA_MONITORING();
    tbl := INIT_TBL_PA_DATABASE();
    tbl := INIT_TBL_PA_DATABASE_PROP();
    tbl := INIT_TBL_PA_COMPONENT();
    tbl := INIT_TBL_PA_COMPONENT_LINK();
    tbl := INIT_TBL_PA_COMPONENT_PROP();
    tbl := INIT_TBL_PA_CONTROL();
    tbl := INIT_TBL_PA_COMPONENT_STAT();
    tbl := INIT_TBL_PA_PATH_STAT();
    tbl := INIT_TBL_PA_PATH_BOTTLENECK();
    tbl := INIT_TBL_PA_SHOW_COMP_STAT();
    tbl := INIT_TBL_PA_SHOW_PATH_STAT();

    if job_name is null then
      canon_job_name := 'STREAMS$_MONITORING_JOB';
    else
      dbms_utility.canonicalize(job_name, canon_job_name, 30);
    end if;

    if client_name is not null then
      dbms_utility.canonicalize(client_name, canon_client_name, 30);
    end if;

    if query_user_name is not null then
      dbms_utility.canonicalize(query_user_name, canon_query_user_name, 30);
      GRANT_PRIVILEGE(canon_query_user_name);
    end if;

    if canon_client_name is not null then
       if not ((length(canon_job_name) + length(canon_client_name)) < 30) then
         raise_application_error(-20100,
           'Combined length of job_name and client_name must be less than 30');
       end if;
       dbms_utility.canonicalize(
         canon_job_name ||'_'|| canon_client_name, canon_submit_job_name, 30);
    else
       canon_submit_job_name := canon_job_name;
    end if;

    CHECK_JOB_CONFLICT(canon_job_name, canon_client_name);

    -- Check control parameters
    if (nvl(interval, 60) < 1) then
      raise_application_error(-20100, 'Invalid interval, too small');
    end if;

    if (nvl(top_event_threshold, 15) < 0 or
        nvl(top_event_threshold, 15) > 100 ) then
      raise_application_error(-20100, 'Invalid top_event_threshold');
    end if;
  
    if (nvl(bottleneck_idle_threshold, 50) < 0 or
        nvl(bottleneck_idle_threshold, 50) > 100 ) then
      raise_application_error(-20100, 'Invalid bottleneck_idle_threshold');
    end if;
  
    if (nvl(bottleneck_flowctrl_threshold, 50) < 0 or
        nvl(bottleneck_flowctrl_threshold, 50) > 100 ) then
      raise_application_error(-20100, 'Invalid bottleneck_flowctrl_threshold');
    end if;

    -- Retention time must at least cover 10 intervals
    if (nvl(retention_time, 24) <
        (nvl(interval, 60) * 10)/seconds_per_hour) then
      raise_application_error(-20100, 'Invalid retention_time, too small');
    end if;

    param_interval               := nvl(interval, 60); -- in seconds
    param_retention_time         := nvl(retention_time, 24); -- in hours
    param_top_event_threshold    := nvl(top_event_threshold, 15);
    param_bot_idle_threshold     := nvl(bottleneck_idle_threshold, 50);
    param_bot_flowctrl_threshold := nvl(bottleneck_flowctrl_threshold, 50);

    -- Print trace info
    dbms_output.put_line('Monitoring Job Control Parameters:');
    dbms_output.put_line(chr(9)||'  INTERVAL='||
      param_interval);
    dbms_output.put_line(chr(9)||'  RETENTION_TIME='||
      param_retention_time);
    dbms_output.put_line(chr(9)||'  TOP_EVENT_THRESHOLD='||
      param_top_event_threshold);
    dbms_output.put_line(chr(9)||'  BOTTLENECK_IDLE_THRESHOLD='||
      param_bot_idle_threshold);
    dbms_output.put_line(chr(9)||'  BOTTLENECK_FLOWCTRL_THRESHOLD='||
      param_bot_flowctrl_threshold);

    -- Start the monitoring job in 1 second. 
    start_monitoring_time := systimestamp + (1/seconds_per_day);

    insert into streams$_pa_monitoring(
           job_name,
           client_name,
           query_user_name,
           started_time,
           stopped_time,
           altered_time,
           state)
    values(canon_job_name,
           canon_client_name,
           canon_query_user_name,
           start_monitoring_time,
           null,
           null,
           'STARTED');
    commit;

    alter_monitoring_param('INTERVAL',
                           param_interval,
                           'SECOND');
    alter_monitoring_param('RETENTION_TIME',
                           param_retention_time,
                           'HOUR');
    alter_monitoring_param('TOP_EVENT_THRESHOLD',
                           param_top_event_threshold,
                           'PERCENT');
    alter_monitoring_param('BOTTLENECK_IDLE_THRESHOLD',
                           param_bot_idle_threshold,
                           'PERCENT');
    alter_monitoring_param('BOTTLENECK_FLOWCTRL_THRESHOLD',
                           param_bot_flowctrl_threshold,
                           'PERCENT');

    begin
      dbms_scheduler.create_job(
        job_name    => canon_submit_job_name, 
        start_date  => start_monitoring_time,
        repeat_interval => null,
        job_type    => 'plsql_block',
        job_action  => 'begin utl_spadv.collect_stats(' ||
                       'interval => ' || param_interval || ', ' ||
                       'num_runs => NULL, ' ||
                       'comp_stat_table => ''streams$_pa_show_comp_stat'', ' ||
                       'path_stat_table => ''streams$_pa_show_path_stat'', ' ||
                       'top_event_threshold => ' ||
                          param_top_event_threshold || ', ' ||
                       'bottleneck_idle_threshold => ' ||
                          param_bot_idle_threshold || ', ' ||
                       'bottleneck_flowctrl_threshold => ' ||
                          param_bot_flowctrl_threshold ||
                       '); end;',
        number_of_arguments => 0,
        enabled     => TRUE,
        auto_drop   => FALSE);

      dbms_scheduler.set_attribute(
        name      =>  canon_submit_job_name,
        attribute => 'restartable',
        value     => true);
    exception when others then
      delete from streams$_pa_monitoring
      where state = 'STARTED' and
            job_name = canon_job_name and
            started_time = start_monitoring_time;
      commit;

      raise;
    end;

  end START_MONITORING;

  ----------------------------------------------------------------------------=
  -- ALTER_MONITORING
  -- 
  -- Raised Exceptions:
  --   ORA-20113: 'no active monitoring job found'
  ----------------------------------------------------------------------------=
  procedure ALTER_MONITORING(
    interval                      IN NUMBER DEFAULT null,
    top_event_threshold           IN NUMBER DEFAULT null,
    bottleneck_idle_threshold     IN NUMBER DEFAULT null,
    bottleneck_flowctrl_threshold IN NUMBER DEFAULT null,
    retention_time                IN NUMBER DEFAULT null)
  as
    tbl             VARCHAR2(30) := null;
    p_name          VARCHAR2(30) := null;
    p_value         NUMBER       := null;
    p_unit          VARCHAR2(30) := null;
    active_job_name VARCHAR2(30) := null;
  begin
    -- Check tables
    tbl := INIT_TBL_PA_CONTROL();
    tbl := INIT_TBL_PA_MONITORING();

    active_job_name := GET_ACTIVE_JOB_NAME();
    if(active_job_name is null) then
      raise_application_error(-20113, 'no active monitoring job found');
    end if;

    -- Check control parameters
    if (nvl(interval, 60) < 1) then
      raise_application_error(-20100, 'Invalid interval, too small');
    end if;

    if (nvl(top_event_threshold, 15) < 0 or
        nvl(top_event_threshold, 15) > 100 ) then
      raise_application_error(-20100, 'Invalid top_event_threshold');
    end if;
  
    if (nvl(bottleneck_idle_threshold, 50) < 0 or
        nvl(bottleneck_idle_threshold, 50) > 100 ) then
      raise_application_error(-20100, 'Invalid bottleneck_idle_threshold');
    end if;
  
    if (nvl(bottleneck_flowctrl_threshold, 50) < 0 or
        nvl(bottleneck_flowctrl_threshold, 50) > 100 ) then
      raise_application_error(-20100, 'Invalid bottleneck_flowctrl_threshold');
    end if;

    -- Retention time must at least cover 10 intervals
    if (nvl(retention_time, 24) <
        (nvl(interval, 60) * 10)/seconds_per_hour) then
      raise_application_error(-20100, 'Invalid retention_time, too small');
    end if;

    -- Indicate that job was altered
    update streams$_pa_monitoring
    set altered_time = systimestamp
    where state = 'STARTED';
    commit;

    -- If parameter is null, the original parameter will be kept.
    if (interval is not null) then
      p_name := 'INTERVAL';
      p_value := interval;
      p_unit := 'SECOND';
      alter_monitoring_param(p_name, p_value, p_unit);
    end if;

    if (retention_time is not null) then
      p_name := 'RETENTION_TIME';
      p_value := retention_time;
      p_unit := 'HOUR';
      alter_monitoring_param(p_name, p_value, p_unit);
    end if;

    if (top_event_threshold is not null) then
      p_name := 'TOP_EVENT_THRESHOLD';
      p_value := top_event_threshold;
      p_unit := 'PERCENT';
      alter_monitoring_param(p_name, p_value, p_unit);
    end if;

    if (bottleneck_idle_threshold is not null) then
      p_name := 'BOTTLENECK_IDLE_THRESHOLD';
      p_value := bottleneck_idle_threshold;
      p_unit := 'PERCENT';
      alter_monitoring_param(p_name, p_value, p_unit);
    end if;

    if (bottleneck_flowctrl_threshold is not null) then
      p_name := 'BOTTLENECK_FLOWCTRL_THRESHOLD';
      p_value := bottleneck_flowctrl_threshold;
      p_unit := 'PERCENT';
      alter_monitoring_param(p_name, p_value, p_unit);
    end if;
    
  end ALTER_MONITORING;

  ----------------------------------------------------------------------------=
  -- STOP_MONITORING
  --   Stops persistent monitoring of Streams performance.
  --
  -- Parameters:
  --   purge:      Whether or not to purge monitoring results from disk
  --
  -- Returns:
  --   TRUE if monitoring has been enabled, false otherwise
  --
  -- Raised Exceptions:
  --   ORA-20113: 'no active monitoring job found'
  --
  procedure STOP_MONITORING(purge IN BOOLEAN DEFAULT FALSE)
  as
    tbl             VARCHAR2(30) := null;
    active_job_name VARCHAR2(30) := null;
    jobs	          NUMBER       := 0;
  begin
    -- Check tables
    tbl := INIT_TBL_PA_MONITORING();
    tbl := INIT_TBL_PA_DATABASE();
    tbl := INIT_TBL_PA_DATABASE_PROP();
    tbl := INIT_TBL_PA_COMPONENT();
    tbl := INIT_TBL_PA_COMPONENT_LINK();
    tbl := INIT_TBL_PA_COMPONENT_PROP();
    tbl := INIT_TBL_PA_CONTROL();
    tbl := INIT_TBL_PA_COMPONENT_STAT();
    tbl := INIT_TBL_PA_PATH_STAT();
    tbl := INIT_TBL_PA_PATH_BOTTLENECK();
    tbl := INIT_TBL_PA_SHOW_COMP_STAT();
    tbl := INIT_TBL_PA_SHOW_PATH_STAT();

    active_job_name := GET_ACTIVE_JOB_NAME();
    if(active_job_name is null AND purge) then
       active_job_name := GET_LATEST_JOB_NAME();
    end if;

    if(active_job_name is null) then
     raise_application_error(-20113, 'no active monitoring job found');
    end if;

    select count(job_name) into jobs
      from user_scheduler_jobs where job_name = active_job_name;

    if (jobs > 0) then
      dbms_scheduler.drop_job(
        job_name => active_job_name, force => true);
    end if;

    update streams$_pa_monitoring
    set state = 'STOPPED', stopped_time = systimestamp
    where state = 'STARTED';
    commit;

    if purge then
      delete from streams$_pa_control;
      delete from streams$_pa_database;
      delete from streams$_pa_database_prop;
      delete from streams$_pa_component;
      delete from streams$_pa_monitoring;
      delete from streams$_pa_component_link;
      delete from streams$_pa_component_prop;
      delete from streams$_pa_component_stat;
      delete from streams$_pa_path_bottleneck;
      delete from streams$_pa_path_stat;
      delete from streams$_pa_show_comp_stat;
      delete from streams$_pa_show_path_stat;
      commit;
    end if;

  end STOP_MONITORING;

  -----------------------------------------------------------------------------=
  -- HTML REPORT 
  -----------------------------------------------------------------------------=

  -----------------------------------------------------------------------------=
  -- PRINT_HEADER
  --   Prints the headers etc for the html file
  -----------------------------------------------------------------------------=
  procedure PRINT_HEADER(
    directory         in varchar2,
    reportName        in varchar2
  ) IS
    file  utl_file.file_type;
  begin
    
    file := utl_file.fopen(directory, reportName, 'W');
    -- print the headers etc
    utl_file.put_line(file, '<html>');
    utl_file.put_line(file, '<head>');

    -- TODO clean this up
    utl_file.put_line(file, '<script type="text/javascript">'||
         ' function DoNav(theUrl){ ' ||
         ' document.location.href = theUrl;}' || 
         ' function ChangeColor(tableRow, highLight)' ||
         ' { ' ||
         ' if (highLight)' ||
         ' { tableRow.style.backgroundColor = ''red''; }' ||
         ' else { tableRow.style.backgroundColor = ''white''; } }' ||
         ' </script>');

    utl_file.put_line(file, '<style type=''text/css''>' ||
          ' body {  ' ||
          'font:10pt Arial,Helvetica,sans-serif; color:black;' || 
          ' background:White;}' || 
          'p {font:10pt Arial,Helvetica,sans-serif; color:black;' ||
          ' background:White;} ' || 
          'table,tr,td {font:10pt Arial,Helvetica,sans-serif; ' ||
          'color:Black; background:#f7f7e7; padding:0px 0px 0px 0px; ' ||
          'margin:0px 0px 0px 0px;}' ||
          ' th {font:bold 10pt Arial,Helvetica,sans-serif; color:#336699;' ||
          ' background:#cccc99; padding:0px 0px 0px 0px;} ' ||
          ' h1 {font:16pt Arial,Helvetica,Geneva,sans-serif; ' ||
          'color:#336699; background-color:White; border-bottom:1px ' ||
          'solid #cccc99; margin-top:0pt; margin-bottom:0pt; ' ||
          'padding:0px 0px 0px 0px;} h2 {font:bold 10pt Arial,' ||
          'Helvetica,Geneva,sans-serif; color:#336699; ' ||
          'background-color:White; margin-top:4pt; margin-bottom:0pt;} ' || 
          '</style>');
    utl_file.put_line(file, '<title> SPADV Report </title>');
    utl_file.put_line(file, '</head>');
    utl_file.put_line(file, '<body>');

    utl_file.fclose(file);

  end PRINT_HEADER;

  -----------------------------------------------------------------------------=
  -- PRINT_FOOTER
  --   Prints the footer for the html file
  -----------------------------------------------------------------------------=
  procedure PRINT_FOOTER(
    directory         in varchar2,
    reportName        in varchar2
  ) IS
    file  utl_file.file_type;
  begin
    file := utl_file.fopen(directory, reportName, 'A');

    -- close the html tags etc 
    utl_file.put_line(file, '</body>');
    utl_file.put_line(file, '</html>');

    utl_file.fclose(file);
  end PRINT_FOOTER;

  -----------------------------------------------------------------------------=
  -- PRINT_EVENT_SUMMARY
  --   Displays a summary of avg statistics for a path
  -----------------------------------------------------------------------------=
  procedure PRINT_EVENT_SUMMARY(
    directory         in varchar2,
    reportName        in varchar2,
    comp_stat_table   in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10
  )
  IS
  type cur_type is ref cursor;
  event_cur cur_type;
  event_stmt varchar2(4000);
  curr_path_id number;
  path_id_stmt varchar2(4000);
  path_id_cur cur_type;
  event_val number;
  event_name varchar2(500);
  comp_cur cur_type;
  comp_stmt varchar2(4000);
  comp_type varchar2(100);
  comp_acronym varchar2(100);
  comp_stype varchar2(100);
  comp_position number;
  stat STAT_PAIR;
  file  utl_file.file_type;
  indexName varchar2(200);
  begin

    if lower(comp_stat_table) = 'streams$_pa_show_comp_stat' then
      indexName := 'comp_stat_pkey';
    else
      indexName := lower(comp_stat_table) || '_pk';
    end if;

    file := utl_file.fopen(directory, reportName, 'A');

    utl_file.put_line(file,'<h2><a name="eventsummary">PATH LEVEL EVENT SUMMARY'
                          || '</a></h2>');
    utl_file.put_line(file, '<h5>(Click on Component acronym to view' 
                            || ' statistics for that component)</h5>');
    utl_file.put_line(file, '<table border=2>');
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<th>Path Id</th>');
    utl_file.put_line(file, '<th>Component</th>'); 
    utl_file.put_line(file, '<th>Topevent 1</th>');
    utl_file.put_line(file, '<th>% Topevent 1</th>');
    utl_file.put_line(file, '<th>Topevent 2</th>');
    utl_file.put_line(file, '<th>% Topevent 2</th>');
    utl_file.put_line(file, '<th>Topevent 3</th>');
    utl_file.put_line(file, '<th>% Topevent 3</th>');
    utl_file.put_line(file, '<th>% Bottleneck</th>');
    utl_file.put_line(file, '</tr>');
    

    --if path_id is null extract for all paths
    path_id_stmt := 'select distinct path_id from ' || comp_stat_table ||' ';
    if path_id is not null then
      path_id_stmt := path_id_stmt || ' where path_id = ' || path_id;
    end if;
    path_id_stmt := path_id_stmt || '  order by path_id';

  
    begin 
      open path_id_cur for path_id_stmt;
      loop 
        fetch path_id_cur into curr_path_id;
        exit when path_id_cur%notfound;

        comp_stmt := 'select distinct  component_type, sub_component_type ' ||
                     ', position from ' || comp_stat_table ||
                     ' where path_id =' || curr_path_id ||
                     ' order by position';
            

         -- get all the components out there
         open comp_cur for comp_stmt;
         loop
           fetch comp_cur into comp_type, comp_stype, comp_position;
           exit when comp_cur%notfound;

           comp_acronym := get_acronym(comp_type,comp_stype);

           -- we are only interested in subcomponents
           continue when comp_acronym = 'CAPTURE' or comp_acronym = 'APPLY';

           event_stmt := 'select statistic_name, avg(statistic_value)' || 
                         ' from ' ||
                          comp_stat_table || 
                         ' where path_id = ' || curr_path_id ||
                         ' and  statistic_alias = ''S7'' ' ||
                         ' and advisor_run_id <= ' || end_run_id ||
                         ' and advisor_run_id >= ' || bgn_run_id ||
                         ' and component_type = ''' || comp_type || '''' ||
                             case when comp_acronym = 'PS' 
                                  or comp_acronym ='PR'
                                  or comp_stype is null
                             then ' and sub_component_type is null'
                             else 
                            ' and sub_component_type = ''' || comp_stype || ''''
                             end ||
                         ' and session_id is null  ' || 
                         ' and session_serial# is null ' ||
                         ' group by statistic_name ' ||
                         'order by avg(statistic_value) desc';

           open event_cur for event_stmt;

           utl_file.put_line(file, '<tr>');
  
           -- add the path id
           utl_file.put_line(file, '<td>' || curr_path_id || '</td>');

           -- add component name
           if comp_acronym != 'APS' and comp_acronym != 'LMP' then
             if comp_acronym = 'Q' or comp_acronym = 'PS' or
                comp_acronym = 'PR' then
               utl_file.put_line(file, '<td><a href="'|| reportName || '_'
                               || comp_acronym ||'at'|| comp_position||'.html">'
                               || comp_acronym ||'</a>' || '</td>');
             else
               utl_file.put_line(file, '<td><a href="'|| reportName || '_' 
                              || comp_acronym ||'.html">' ||
                              comp_acronym ||'</a>' || '</td>');
             end if;
           else
             stat := get_statistic_by_position(
                          comp_stat_table,'S4', curr_path_id, bgn_run_id,
                          comp_position, indexName);
              utl_file.put_line(file, '<td><a href="'|| reportName || '_' 
                            || comp_acronym || '.html">' ||
                            comp_acronym || '(' || stat.stat_value || ')</a>' 
                            || '</td>');
           end if;

           -- topevent 1
           fetch event_cur into event_name, event_val;
           if event_cur%notfound or event_val <= 0.0 then
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           else
             
             utl_file.put_line(file, '<td>' || event_name || '</td>');
             utl_file.put_line(file, '<td>' || to_char(event_val, 
                                     'FM99999999.99') || '</td>');
           end if;
        
           -- topevent 2
           fetch event_cur into event_name, event_val;
           if event_cur%notfound or event_val <= 0.0 then
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           else
             utl_file.put_line(file, '<td>' || event_name || '</td>');
             utl_file.put_line(file, '<td>' || to_char(event_val, 
                                     'FM99999999.99') 
                                     || '</td>');
           end if;

           -- topevent 3
           fetch event_cur into event_name, event_val;
           if event_cur%notfound or event_val <= 0.0 then
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           else
             utl_file.put_line(file, '<td>' || event_name || '</td>');
             utl_file.put_line(file, '<td>' || 
                                     to_char(event_val, 'FM99999999.99') 
                                     || '</td>');
           end if;

           -- % of time this event was the bottleneck
           utl_file.put_line(file, '<td>' 
                        || to_char(get_bottleneck_percent(comp_acronym, 
                        curr_path_id, bgn_run_id, end_run_id),'FM99999999.99') 
                        || '</td>');

           -- close the row
           utl_file.put_line(file, '</tr>');
           

           close event_cur;        

         end loop;
         close comp_cur;  
       end loop;
       close path_id_cur;
    end;
    -- close the table
    utl_file.put_line(file, '</table>');
    utl_file.put_line(file, '<br>');
    utl_file.fclose(file);
  end PRINT_EVENT_SUMMARY;
 
  -----------------------------------------------------------------------------=
  -- PRINT_PATH_LEVEL_SUMMARY
  --   Displays a summary of avg statistics for a path
  -----------------------------------------------------------------------------=
  procedure PRINT_PATH_LEVEL_SUMMARY(
    directory         in varchar2,
    reportName        in varchar2,
    comp_stat_table   in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10
  )
  IS
  type cur_type is ref cursor;
  comp_cur cur_type;
  comp_stmt varchar2(4000);
  comp_type varchar2(100);
  comp_stype varchar2(100);
  comp_position number;
  stat_cur cur_type;
  curr_path_id number;
  path_id_stmt varchar2(4000);
  path_id_cur cur_type;
  stat number;
  stat_alias varchar2(10);
  comp_acronym varchar2(20);
  file  utl_file.file_type;
  begin
    file := utl_file.fopen(directory, reportName, 'A');

    utl_file.put_line(file, '<h2><a name="pathsummary">PATH LEVEL SUMMARY'
                          || '</a></h2>');
 
    utl_file.put_line(file, '<table border=2>');
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<th>Path Id</th>'); 
    utl_file.put_line(file, '<th>Avg CAPTURE msgs/sec</th>');
    utl_file.put_line(file, '<th>Avg CAPTURE latency</th>');
    utl_file.put_line(file, '<th>Avg APPLY txns/sec</th>');
    utl_file.put_line(file, '<th>Avg APPLY msgs/sec</th>');
    utl_file.put_line(file, '<th>Avg APPLY latency</th>');
    utl_file.put_line(file, '</tr>');
    

    --if path_id is null extract for all paths
    path_id_stmt := 'select distinct path_id from ' || comp_stat_table ||' ';
    if path_id is not null then
      path_id_stmt := path_id_stmt || ' where path_id = ' || path_id;
    end if;
    path_id_stmt := path_id_stmt || '  order by path_id';

    begin 
      open path_id_cur for path_id_stmt;
      loop 
        fetch path_id_cur into curr_path_id;
        exit when path_id_cur%notfound;

           utl_file.put_line(file, '<tr>');
           
           -- add the path id
           utl_file.put_line(file, '<td>' || curr_path_id || '</td>');

         
           -- CAP msgs/sec
           stat := get_avg_statistic_by_component(
                            comp_stat_table,'S2', curr_path_id, bgn_run_id,
                            end_run_id, 'CAPTURE', null);
           if stat >= 0  then
             utl_file.put_line(file, '<td>' || to_char(stat, 'FM99999999.99') 
                                   || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- CAP Latency
           stat := get_avg_statistic_by_component(
                            comp_stat_table,'S3', curr_path_id, bgn_run_id,
                            end_run_id, 'CAPTURE', null);
          
           if stat >= 0 then
             utl_file.put_line(file, '<td>' || to_char(stat, 'FM99999999.99') 
                                   || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- Apply txns/sec
           stat := get_avg_statistic_by_component(
                            comp_stat_table,'S2', curr_path_id, bgn_run_id,
                            end_run_id, 'APPLY', null);
          
           if stat >= 0 then
             utl_file.put_line(file, '<td>' || to_char(stat, 'FM99999999.99') 
                                  || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- Apply msgs/sec
           stat := get_avg_statistic_by_component(
                            comp_stat_table,'S1', curr_path_id, bgn_run_id,
                            end_run_id, 'APPLY', null);
          
           if stat >= 0 then
             utl_file.put_line(file, '<td>' || to_char(stat, 'FM99999999.99') 
                                   || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- Apply Latency
           stat := get_avg_statistic_by_component(
                            comp_stat_table,'S3', curr_path_id, bgn_run_id,
                            end_run_id, 'APPLY', null);
         
           if stat >= 0 then
             utl_file.put_line(file, '<td>' || to_char(stat, 'FM99999999.99') 
                                  || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- close the row
          utl_file.put_line(file, '</tr>');
          

      end loop;
      close path_id_cur;
    end;
    -- close the table
    utl_file.put_line(file, '</table>');
    utl_file.put_line(file, '<br>');
    utl_file.fclose(file);
  end PRINT_PATH_LEVEL_SUMMARY;

  -----------------------------------------------------------------------------=
  -- PRINT_RATE_LEVEL_STATS
  --   Displays a table of statistics at the rate level
  -----------------------------------------------------------------------------=
  procedure PRINT_RATE_LEVEL_STATS(
    directory         in varchar2,
    reportName        in varchar2,
    comp_stat_table   in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10
  )
  IS
  type cur_type is ref cursor;
  comp_cur cur_type;
  comp_stmt varchar2(4000);
  comp_type varchar2(100);
  comp_stype varchar2(100);
  comp_position number;
  stat_cur cur_type;
  run_id number;
  run_time_cur cur_type;
  run_time varchar2(50);
  curr_path_id number;
  path_id_stmt varchar2(4000);
  path_id_cur cur_type;
  stat STAT_PAIR default null;
  stat_alias varchar2(10);
  comp_acronym varchar2(20);
  bottleneckInfo varchar2(4000);
  bottleneck_cur cur_type;
  file  utl_file.file_type;
  begin
    file := utl_file.fopen(directory, reportName, 'A');
    bottleneckInfo := null;

    utl_file.put_line(file, '<h2><a name="ratesummary">RATE LEVEL STATS' 
                             || '</a></h2>');
    utl_file.put_line(file, '<h5>(Click on each row to view stats for the' 
                            || ' specific run)</h5>');
    utl_file.put_line(file, '<table border=2>');
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<th>Path Id</th>'); 
    utl_file.put_line(file, '<th>Run Id</th>');
    utl_file.put_line(file, '<th>Run time</th>');
    utl_file.put_line(file, '<th>CAP msgs/sec</th>');
    utl_file.put_line(file, '<th>CAP latency</th>');
    utl_file.put_line(file, '<th>APPLY txns/sec</th>');
    utl_file.put_line(file, '<th>APPLY msgs/sec</th>');
    utl_file.put_line(file, '<th>APPLY latency</th>');
    utl_file.put_line(file, '<th>Bottleneck</th>');
    utl_file.put_line(file, '</tr>');
    

    --if path_id is null extract for all paths
    path_id_stmt := 'select distinct path_id from ' || comp_stat_table ||' ';
    if path_id is not null then
      path_id_stmt := path_id_stmt || ' where path_id = ' || path_id;
    end if;
    path_id_stmt := path_id_stmt || '  order by path_id';

    begin 
      open path_id_cur for path_id_stmt;
      loop 
        fetch path_id_cur into curr_path_id;
        exit when path_id_cur%notfound;
        -- for every run
        for run_id in bgn_run_id..end_run_id loop

           utl_file.put_line(file, '<tr onclick="DoNav(''' || reportName 
                     || '_' || curr_path_id || '_' || run_id 
                     ||'.html'');" onmouseout="ChangeColor(this,false);"' ||
                    ' onmouseover="ChangeColor(this,true);">');
           
           -- add the path id
           utl_file.put_line(file, '<td>' || curr_path_id || '</td>');

           -- add the run id
           utl_file.put_line(file, '<td>' || run_id || '</td>');

           -- add the run time
           open run_time_cur for 'select distinct ' || 
                    'to_char( advisor_run_time,''DD-MON-YYYY HH24:MI:SS'') ' ||
                    ' from ' || comp_stat_table || 
                    ' where advisor_run_id = ' || run_id ||
                    ' and path_id = '||curr_path_id;
           fetch run_time_cur into run_time;
           close run_time_cur;
           utl_file.put_line(file, '<td>' || run_time || '</td>');

           -- CAP msgs/sec
           stat := get_statistic_by_component(
                            comp_stat_table,'S2', curr_path_id, run_id,
                            'CAPTURE', null);
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- CAP Latency
           stat := get_statistic_by_component(
                            comp_stat_table,'S3', curr_path_id, run_id,
                            'CAPTURE', null);
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- Apply txns/sec
           stat := get_statistic_by_component(
                            comp_stat_table,'S2', curr_path_id, run_id,
                            'APPLY', null);
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- Apply msgs/sec
           stat := get_statistic_by_component(
                            comp_stat_table,'S1', curr_path_id, run_id,
                            'APPLY', null);
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- Apply Latency
           stat := get_statistic_by_component(
                            comp_stat_table,'S3', curr_path_id, run_id,
                            'APPLY', null);
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- Bottleneck
           utl_file.put(file, '<td>');
           open bottleneck_cur for 'select B.spare3 ' || 
                                   ' from streams$_pa_path_bottleneck B ' ||
                                   ' where B.advisor_run_id = ' || run_id || 
                                   ' and B.path_id = ' || curr_path_id;
           loop
             fetch bottleneck_cur into bottleneckInfo;
             exit when bottleneck_cur%notfound;
             utl_file.put(file, bottleneckInfo || ',');
           end loop;
           
           if bottleneckInfo is null then
             utl_file.put(file, '&nbsp');
           end if;

           close bottleneck_cur;

           utl_file.put_line(file, '</td>');
           -- close the row
           utl_file.put_line(file, '</tr>');
           
         
        end loop;
      end loop;
      close path_id_cur;
    end;
    -- close the table
    utl_file.put_line(file, '</table>');
    utl_file.put_line(file, '<br>');
    utl_file.fclose(file);
  end PRINT_RATE_LEVEL_STATS;

  -----------------------------------------------------------------------------=
  -- PRINT_COMPONENT_LEVEL_STATS
  --   Displays a table of statistics at the component level
  -----------------------------------------------------------------------------=
  procedure PRINT_COMPONENT_LEVEL_STATS(
    directory         in varchar2,
    reportName        in varchar2,
    comp_stat_table   in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10
  )
  IS
  type cur_type is ref cursor;
  comp_cur cur_type;
  comp_stmt varchar2(4000);
  comp_type varchar2(100);
  comp_stype varchar2(100);
  comp_position number;
  stat_cur cur_type;
  run_time_cur cur_type;
  run_id number;
  run_time varchar2(50);
  curr_path_id number;
  path_id_stmt varchar2(4000);
  path_id_cur cur_type;
  stat STAT_PAIR default null;
  stat_alias varchar2(10);
  comp_acronym varchar2(20);
  event_stmt varchar2(4000);
  event_cur  cur_type;
  event_name varchar2(200);
  event_val number;
  file  utl_file.file_type; 
  fileName varchar2(200);
  indexName varchar2(100);
  begin

    if lower(comp_stat_table) = 'streams$_pa_show_comp_stat' then
      indexName := 'comp_stat_pkey';
    else
      indexName := lower(comp_stat_table) || '_pk';
    end if;

    --if path_id is null extract for all paths
    path_id_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                    indexName || ') */ ' || 
                   ' distinct path_id from ' || comp_stat_table || ' ' ;
    if path_id is not null then
      path_id_stmt := path_id_stmt || ' where path_id = ' || path_id;
    end if;
    path_id_stmt := path_id_stmt || '  order by path_id';

    comp_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                  indexName || ') */ ' ||
                  ' distinct  component_type, sub_component_type ' ||
                  ', position from ' || comp_stat_table ||
                  ' order by position';

    -- get all the components out there
    open comp_cur for comp_stmt;
      loop
        fetch comp_cur into comp_type, comp_stype, comp_position;
        exit when comp_cur%notfound;
        
        -- open file for component
        comp_acronym := get_acronym(comp_type,comp_stype);

        if comp_acronym = 'Q' or comp_acronym = 'PS' 
           or comp_acronym = 'PR' then
          fileName :=  comp_acronym ||'at' || comp_position;
        else
          fileName := comp_acronym;
        end if;

        fileName := reportName || '_' || fileName || '.html';
        print_header(directory, fileName);
        file := utl_file.fopen(directory, fileName, 'A');

        utl_file.put_line(file,'<h2><a name="complevelstats">' 
                               || 'COMPONENT LEVEL STATS' 
                               || '</a></h2>');
        utl_file.put_line(file, '<b><a name = "'||  fileName || '">'
                              ||comp_acronym ||'</a></b>');

         -- create a table
        utl_file.put_line(file, '<table border=2>');
        utl_file.put_line(file, '<tr>');
        utl_file.put_line(file, '<th>Path Id</th>');
        utl_file.put_line(file, '<th>Run Id</th>'); 
        utl_file.put_line(file, '<th>Run time</th>');
        utl_file.put_line(file, '<th>Throughput</th>');

        -- display 'rate 2' as actual statistic
        if comp_acronym = 'CAPTURE' then
          utl_file.put_line(file, '<th>Captured/sec</th>');
        elsif comp_acronym = 'Q' then
          utl_file.put_line(file, '<th>No of msgs</th>');
        elsif comp_acronym = 'PS' then
          utl_file.put_line(file, '<th>bytes/sec</th>');
        elsif comp_acronym = 'APPLY' then
          utl_file.put_line(file, '<th>txns applied/sec</th>');
        else
          utl_file.put_line(file, '<th>Rate 2</th>');
        end if;

        utl_file.put_line(file, '<th>Latency</th>');
        utl_file.put_line(file, '<th>% Idle</th>');
        utl_file.put_line(file, '<th>% Flwctrl</th>');
        utl_file.put_line(file, '<th>% Topevent 1</th>');
        utl_file.put_line(file, '<th>Topevent 1</th>');
        utl_file.put_line(file, '<th>% Topevent 2</th>');
        utl_file.put_line(file, '<th>Topevent 2</th>');
        utl_file.put_line(file, '<th>% Topevent 3</th>');
        utl_file.put_line(file, '<th>Topevent 3</th>');
        utl_file.put_line(file, '</tr>');
    
        begin 
          open path_id_cur for path_id_stmt;
          loop 
            -- for every path
            fetch path_id_cur into curr_path_id;
            exit when path_id_cur%notfound;
            
            -- for every run
            for run_id in bgn_run_id..end_run_id loop

              utl_file.put_line(file, '<tr onclick="DoNav(''' || reportName 
                          || '_' || curr_path_id || '_' || run_id 
                          ||'.html'');" onmouseout="ChangeColor(this,false);"' 
                          || ' onmouseover="ChangeColor(this,true);">');
           
              -- add the path id
              utl_file.put_line(file, '<td>' || curr_path_id || '</td>');

              -- add the run id
              utl_file.put_line(file, '<td>' || run_id || '</td>');

              -- add the run time 
              open run_time_cur for 'select /* INDEX(' || comp_stat_table || 
                    ' ' || indexName || ') */ ' ||' distinct ' || 
                    'to_char( advisor_run_time,''DD-MON-YYYY HH24:MI:SS'') ' ||
                    ' from ' || comp_stat_table || 
                    ' where advisor_run_id = ' || run_id ||
                    ' and path_id = '||curr_path_id;
              fetch run_time_cur into run_time;
              close run_time_cur;
              utl_file.put_line(file, '<td>' || run_time || '</td>');

              -- populate throughput
              if comp_acronym = 'CAPTURE' then          
              -- for capture display enqueued/sec
                stat_alias := 'S2';
              else
                stat_alias := 'S1';
              end if;
          
              stat := get_statistic_by_position(
                            comp_stat_table,stat_alias, curr_path_id, run_id,
                            comp_position, indexName);
         
              if stat.stat_name is not null then
                utl_file.put_line(file, '<td>' || 
                            to_char(stat.stat_value, 'FM99999999') || '</td>');
              else
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
              end if;

              -- populate rate2 
              if comp_acronym = 'CAPTURE' then
                -- for capture display captured/sec
                stat_alias := 'S1';
              elsif comp_acronym = 'Q' then
                stat_alias := 'S3';
              else
                stat_alias := 'S2';
              end if;
          
              stat := get_statistic_by_position(
                            comp_stat_table,stat_alias, curr_path_id, run_id,
                            comp_position, indexName);
         
              if stat.stat_name is not null then
                utl_file.put_line(file, '<td>' || 
                            to_char(stat.stat_value, 'FM99999999') || '</td>');
              else
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
              end if;



              -- populate latency
              if comp_acronym != 'Q' then 
                -- for Queues, S3 mean something else
                stat := get_statistic_by_position(
                               comp_stat_table,'S3', curr_path_id, run_id,
                               comp_position, indexName);
         
                 if stat.stat_name is not null then
                   utl_file.put_line(file, '<td>' || 
                               to_char(stat.stat_value, 'FM99999999') || 
                               '</td>');
                 else
                   utl_file.put_line(file, '<td>&nbsp' || '</td>');
                 end if;
              else
                 utl_file.put_line(file, '<td>&nbsp' || '</td>');
              end if;


              -- populate idle %
              stat := get_statistic_by_position(
                             comp_stat_table,'S5', curr_path_id, run_id,
                             comp_position, indexName);
         
              if stat.stat_name is not null then
                utl_file.put_line(file, '<td>' || 
                            to_char(stat.stat_value, 'FM99999999D9') || 
                            '</td>');
              else
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
              end if;

              -- populate flwctrl%
              stat := get_statistic_by_position(
                            comp_stat_table,'S6', curr_path_id, run_id,
                            comp_position, indexName);
              if stat.stat_name is not null then
                utl_file.put_line(file, '<td>' || 
                            to_char(stat.stat_value, 'FM99999999D9') || 
                            '</td>');
              else
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
              end if;
          
             
              -- populate topevents%,topevents

              event_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                            indexName || ') */ ' || 
                            ' statistic_name, statistic_value' || 
                            ' from ' ||
                             comp_stat_table || 
                            ' where path_id = ' || curr_path_id ||
                            ' and  statistic_alias = ''S7'' ' ||
                            ' and position = '|| comp_position ||
                            ' and advisor_run_id = ' || run_id ||
                            ' and component_type = ''' || comp_type || '''' ||
                             case when comp_acronym = 'PS' 
                                   or comp_acronym ='PR'
                                   or comp_stype is null
                               then ' and sub_component_type is null'
                               else ' and sub_component_type = ''' || 
                                    comp_stype || ''''
                             end ||
                            ' and session_id is null  ' || 
                            ' and session_serial# is null ' ||
                            ' order by statistic_value desc';

              open event_cur for event_stmt;

           
              -- topevent 1
              fetch event_cur into event_name, event_val;
              if event_cur%notfound or event_val <= 0.0 then
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
              else
                utl_file.put_line(file, '<td>' || 
                            to_char(event_val, 'FM99999999.99') || '</td>');
                utl_file.put_line(file, '<td>' || event_name || '</td>');
              end if;
        
              -- topevent 2
              fetch event_cur into event_name, event_val;
              if event_cur%notfound or event_val <= 0.0 then
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
              else
                utl_file.put_line(file, '<td>' || 
                            to_char(event_val, 'FM99999999.99') || '</td>');
                utl_file.put_line(file, '<td>' || event_name || '</td>');
              end if;

              -- topevent 3
              fetch event_cur into event_name, event_val;
              if event_cur%notfound or event_val <= 0.0 then
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
                utl_file.put_line(file, '<td>&nbsp' || '</td>');
              else
                utl_file.put_line(file, '<td>' || 
                            to_char(event_val, 'FM99999999.99') || '</td>');
                utl_file.put_line(file, '<td>' || event_name || '</td>');
              end if;
 
              close event_cur;

              utl_file.put_line(file, '</tr>');
              

            end loop; -- ends for 
          end loop;
          close path_id_cur;
        end;-- table ends when stats are printed for all pathids and runids
        utl_file.put_line(file, '</table>');
        utl_file.put_line(file, '<br>');
        utl_file.put_line(file,'<h3><a href="'|| reportName ||'">' 
                               || 'Back to Report Home' 
                               || '</a></h3>');
        utl_file.fclose(file);
        print_footer(directory, fileName);
      end loop;
    close comp_cur;

  end PRINT_COMPONENT_LEVEL_STATS;
 

  -----------------------------------------------------------------------------=
  -- PRINT_RUN_LEVEL_STATS
  --   Displays a table of statistics at the run level
  -----------------------------------------------------------------------------=
  procedure PRINT_RUN_LEVEL_STATS(
    directory         in varchar2,
    reportName        in varchar2,
    comp_stat_table   in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10
  )
  IS
  type cur_type is ref cursor;
  comp_cur cur_type;
  comp_stmt varchar2(4000);
  comp_type varchar2(100);
  comp_stype varchar2(100);
  comp_position number;
  stat_cur cur_type;
  run_id number;
  run_time varchar2(50);
  curr_path_id number;
  path_id_stmt varchar2(4000);
  path_id_cur cur_type;
  stat STAT_PAIR default null;
  stat_alias varchar2(10);
  comp_acronym varchar2(20);
  event_stmt varchar2(4000);
  event_cur  cur_type;
  event_name varchar2(200);
  event_val number;
  file  utl_file.file_type;
  fileName varchar2(200);
  indexName varchar2(200);
  --NOTE:  Assumes there are no more than 30 components in a run
  type compTypeArr is varray(30) of varchar2(100);
  type compStypeArr is varray(30) of varchar2(100);
  type compPositionArr is varray(30) of number;

  comp_types compTypeArr;
  comp_stypes compStypeArr;
  comp_positions compPositionArr;
  i number;
  begin

     --if path_id is null extract for all paths
    path_id_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                    indexName || ') */ ' ||
                    ' distinct path_id from ' ||comp_stat_table || ' ';
    if path_id is not null then
      path_id_stmt := path_id_stmt || ' where path_id = ' || path_id;
    end if;
    path_id_stmt := path_id_stmt || '  order by path_id';

    if lower(comp_stat_table) = 'streams$_pa_show_comp_stat' then
      indexName := 'comp_stat_pkey';
    else
      indexName := lower(comp_stat_table) || '_pk';
    end if;


    begin 
      open path_id_cur for path_id_stmt;
      loop 
        fetch path_id_cur into curr_path_id;
        exit when path_id_cur%notfound;

        -- store all the component information for the path
        comp_types := compTypeArr();
        comp_stypes := compStypeArr();
        comp_positions := compPositionArr();

        comp_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                    indexName || ') */ ' ||
                     'distinct  component_type, sub_component_type ' ||
                     ', position from ' || comp_stat_table ||
                     ' where path_id =' || curr_path_id ||
                     ' order by position';
        open comp_cur for comp_stmt;
        loop
          fetch comp_cur into comp_type, comp_stype, comp_position;
          exit when comp_cur%notfound;
          comp_types.extend(1);
          comp_stypes.extend(1);
          comp_positions.extend(1);
          comp_types(comp_types.last) := comp_type;
          comp_stypes(comp_stypes.last) := comp_stype;
          comp_positions(comp_positions.last) := comp_position;
        end loop;
        close comp_cur;
               

        -- for every run
        for run_id in bgn_run_id..end_run_id loop

          fileName := reportName ||'_' || curr_path_id || '_'
                      || run_id || '.html';
          print_header(directory, fileName);
          file := utl_file.fopen(directory, fileName, 'A');

          utl_file.put_line(file, '<h2><a name = "runlevelstats">' 
                                  || 'RUN LEVEL STATS' ||'</a></h2>');

          comp_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                       indexName || ') */ ' ||
                       'distinct  component_type, sub_component_type ' ||
                       ', position from ' || comp_stat_table ||
                       ' where path_id =' || curr_path_id ||
                       ' and advisor_run_id =' || run_id ||
                       ' order by position';
      
          open comp_cur for 'select /* INDEX(' || comp_stat_table || ' ' ||
                    indexName || ') */ ' ||
                    'distinct ' || 
                    'to_char(advisor_run_time,''DD-MON-YYYY HH24:MI:SS'') ' ||
                    ' from ' || comp_stat_table || 
                    ' where advisor_run_id = ' || run_id ||
                    ' and path_id = '||curr_path_id;
          fetch comp_cur into run_time;
          close comp_cur;

          utl_file.put_line(file, '<b><a name="'|| curr_path_id || '-' 
                               || run_id ||'">'|| 'Path: ' || curr_path_id 
                               || ' Run id: ' || run_id  ||
                               ' Run time: ' || run_time || '</a></b>');

          utl_file.put_line(file, '<table border=2>');
          utl_file.put_line(file, '<tr>');
          utl_file.put_line(file, '<th>Component</th>'); 
          utl_file.put_line(file, '<th>Throughput</th>');
          utl_file.put_line(file, '<th>Rate 2</th>');
          utl_file.put_line(file, '<th>Latency</th>');
          utl_file.put_line(file, '<th>% Idle </th>');
          utl_file.put_line(file, '<th>% Flwctrl </th>');
          utl_file.put_line(file, '<th>% Topevent 1</th>');
          utl_file.put_line(file, '<th>Topevent 1</th>');
          utl_file.put_line(file, '<th>% Topevent 2</th>');
          utl_file.put_line(file, '<th>Topevent 2</th>');
          utl_file.put_line(file, '<th>% Topevent 3</th>');
          utl_file.put_line(file, '<th>Topevent 3</th>');
          utl_file.put_line(file, '</tr>');


         -- get all the components out there
         for i in comp_types.first .. comp_types.last 
         loop
           comp_type := comp_types(i);
           comp_stype :=  comp_stypes(i);
           comp_position := comp_positions(i);
       
           comp_acronym := get_acronym(comp_type,comp_stype);

           -- for every such component extract the data
           utl_file.put_line(file, '<tr>');

           -- populate component name
           if comp_acronym != 'APS' and comp_acronym != 'LMP' then
             if comp_acronym = 'Q' or comp_acronym = 'PS' or
                comp_acronym = 'PR' then
                 utl_file.put_line(file, '<td><a href="' || reportName || '_'
                               || comp_acronym ||'at'|| 
                               comp_position||'.html">' ||
                               comp_acronym ||'</a>' || '</td>');
             else
               utl_file.put_line(file, '<td><a href="' || reportName || '_' 
                               || comp_acronym ||'.html">' ||
                              comp_acronym ||'</a>' || '</td>');
             end if;
           else
             stat := get_statistic_by_position(
                          comp_stat_table,'S4', curr_path_id, run_id,
                          comp_position, indexName);
              utl_file.put_line(file, '<td><a href="'|| reportName || '_' 
                            || comp_acronym || '.html">' ||
                            comp_acronym || '(' || stat.stat_value || ')</a>' 
                            || '</td>');
           end if;

           -- populate throughput
           if comp_acronym = 'CAPTURE' then
             -- for capture display enqueued/sec
             stat_alias := 'S2';
           else
             stat_alias := 'S1';
           end if;
          
          stat := get_statistic_by_position(
                          comp_stat_table,stat_alias, curr_path_id, run_id,
                          comp_position, indexName);
         
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;

           -- populate rate2 
          if comp_acronym = 'CAPTURE' then
             -- for capture display captured/sec
             stat_alias := 'S1';
           elsif comp_acronym = 'Q' then
             stat_alias := 'S3';
           else
             stat_alias := 'S2';
           end if;
          
           stat := get_statistic_by_position(
                          comp_stat_table,stat_alias, curr_path_id, run_id,
                          comp_position, indexName);
         
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;



           -- populate latency
           if comp_acronym != 'Q' then 
             -- for Queues, S3 mean something else
             stat := get_statistic_by_position(
                            comp_stat_table,'S3', curr_path_id, run_id,
                            comp_position, indexName);
         
             if stat.stat_name is not null then
               utl_file.put_line(file, '<td>' || 
                           to_char(stat.stat_value, 'FM99999999') || '</td>');
             else
               utl_file.put_line(file, '<td>&nbsp' || '</td>');
             end if;
           else
              utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;


           -- populate idle %
           stat := get_statistic_by_position(
                          comp_stat_table,'S5', curr_path_id, run_id,
                          comp_position, indexName);
         
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999D9') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;
           -- populate flwctrl%
           stat := get_statistic_by_position(
                          comp_stat_table,'S6', curr_path_id, run_id,
                          comp_position, indexName);
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999D9') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           end if;
          
           -- populate topevents%,topevents

           event_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                         indexName || ') */ ' || 
                         ' statistic_name, statistic_value' || 
                         ' from ' ||
                          comp_stat_table || 
                         ' where path_id = ' || curr_path_id ||
                         ' and  statistic_alias = ''S7'' ' ||
                         ' and position = '|| comp_position ||
                         ' and advisor_run_id = ' || run_id ||
                         ' and component_type = ''' || comp_type || '''' ||
                         case when comp_acronym = 'PS' or comp_acronym ='PR'
                                    or comp_stype is null
                               then ' and sub_component_type is null'
                               else ' and sub_component_type = ''' || 
                                    comp_stype || ''''
                         end ||
                         ' and session_id is null  ' || 
                         ' and session_serial# is null ' ||
                         ' order by statistic_value desc';

           open event_cur for event_stmt;

          
           -- topevent 1
           fetch event_cur into event_name, event_val;
           if event_cur%notfound or event_val <= 0.0 then
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           else
             utl_file.put_line(file, '<td>' || to_char(event_val, 
                                     'FM99999999.99') || '</td>');
             utl_file.put_line(file, '<td>' || event_name || '</td>');
           end if;
        
           -- topevent 2
           fetch event_cur into event_name, event_val;
           if event_cur%notfound or event_val <= 0.0 then
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           else
             utl_file.put_line(file, '<td>' || to_char(event_val, 
                                     'FM99999999.99') || '</td>');
             utl_file.put_line(file, '<td>' || event_name || '</td>');
           end if;

           -- topevent 3
           fetch event_cur into event_name, event_val;
           if event_cur%notfound or event_val <= 0.0 then
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
           else
             utl_file.put_line(file, '<td>' || to_char(event_val, 
                                    'FM99999999.99') || '</td>');
             utl_file.put_line(file, '<td>' || event_name || '</td>');
           end if;
 
           close event_cur;

           utl_file.put_line(file, '</tr>');
           
         end loop;
         utl_file.put_line(file, '</table>');
         utl_file.put_line(file, '<br>');
         utl_file.put_line(file,'<h3><a href="'|| reportName ||'">' 
                               || 'Back to Report Home' 
                               || '</a></h3>');
         utl_file.fclose(file);
         print_footer(directory, fileName);
       end loop;

       -- clear all the component info for the path
       comp_types.delete();
       comp_stypes.delete();
       comp_positions.delete();
     end loop;
     close path_id_cur;
    end;
  end PRINT_RUN_LEVEL_STATS;


  -----------------------------------------------------------------------------=
  -- PRINT_RUN_AND_COMP_LEVEL_STATS
  --   Displays a table of statistics at the run level and component level
  --   clubbed into one to improve performance
  -----------------------------------------------------------------------------=
  procedure PRINT_RUN_AND_COMP_LEVEL_STATS(
    directory         in varchar2,
    reportName        in varchar2,
    comp_stat_table   in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10
  )
  IS
  type cur_type is ref cursor;
  comp_cur cur_type;
  comp_stmt varchar2(4000);
  comp_type varchar2(100);
  comp_stype varchar2(100);
  comp_position number;
  stat_cur cur_type;
  run_id number;
  run_time varchar2(50);
  curr_path_id number;
  path_id_stmt varchar2(4000);
  path_id_cur cur_type;
  stat STAT_PAIR default null;
  stat_alias varchar2(10);
  comp_acronym varchar2(20);
  event_stmt varchar2(4000);
  event_cur  cur_type;
  event_name varchar2(200);
  event_val number;
  file  utl_file.file_type;
  fileName varchar2(200);
  indexName varchar2(200);
  --NOTE:  Assumes there are no more than 30 components in a run
  type compTypeArr is varray(30) of varchar2(100);
  type compStypeArr is varray(30) of varchar2(100);
  type compPositionArr is varray(30) of number;
  type fileArr is varray(30) of varchar2(200);
  type fileMap is TABLE OF utl_file.file_type INDEX BY VARCHAR2(200);

  comp_types compTypeArr;
  comp_stypes compStypeArr;
  comp_positions compPositionArr;
  compFiles fileArr;
  compFile utl_file.file_type;
  openCompFiles fileMap;
  compFileName varchar2(200);
  i number;

  eventCursor number;
  eventRows  number;
  begin

     --if path_id is null extract for all paths
    path_id_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                    indexName || ') */ ' ||
                    ' distinct path_id from ' ||comp_stat_table || ' ';
    if path_id is not null then
      path_id_stmt := path_id_stmt || ' where path_id = ' || path_id;
    end if;
    path_id_stmt := path_id_stmt || '  order by path_id';

    if lower(comp_stat_table) = 'streams$_pa_show_comp_stat' then
      indexName := 'comp_stat_pkey';
    else
      indexName := lower(comp_stat_table) || '_pk';
    end if;


    begin 
      open path_id_cur for path_id_stmt;
      loop 
        fetch path_id_cur into curr_path_id;
        exit when path_id_cur%notfound;

        -- store all the component information for the path
        comp_types := compTypeArr();
        comp_stypes := compStypeArr();
        comp_positions := compPositionArr();
        compFiles := fileArr();

        comp_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                    indexName || ') */ ' ||
                     'distinct  component_type, sub_component_type ' ||
                     ', position from ' || comp_stat_table ||
                     ' where path_id =' || curr_path_id ||
                     ' order by position';
        open comp_cur for comp_stmt;
        loop
          fetch comp_cur into comp_type, comp_stype, comp_position;
          exit when comp_cur%notfound;
          comp_types.extend(1);
          comp_stypes.extend(1);
          comp_positions.extend(1);
          compFiles.extend(1);
          comp_types(comp_types.last) := comp_type;
          comp_stypes(comp_stypes.last) := comp_stype;
          comp_positions(comp_positions.last) := comp_position;
          
          -- open file for component
          comp_acronym := get_acronym(comp_type,comp_stype);
          if comp_acronym = 'Q' or comp_acronym = 'PS' 
            or comp_acronym = 'PR' then
            compFileName :=  comp_acronym ||'at' || comp_position;
          else
            compFileName := comp_acronym;
          end if;

          compFileName := reportName || '_' || compFileName || '.html';

          -- print the header if not done already 
          if not openCompFiles.exists(compFileName) then
            print_header(directory, compFileName);
            compFile := utl_file.fopen(directory, compFileName, 'A');

            utl_file.put_line(compFile,'<h2><a name="complevelstats">' 
                               || 'COMPONENT LEVEL STATS' 
                               || '</a></h2>');
            utl_file.put_line(compFile, '<b><a name = "'||  fileName || '">'
                              ||comp_acronym ||'</a></b>');
            -- create a table
            utl_file.put_line(compFile, '<table border=2>');
            utl_file.put_line(compFile, '<tr>');
            utl_file.put_line(compFile, '<th>Path Id</th>');
            utl_file.put_line(compFile, '<th>Run Id</th>'); 
            utl_file.put_line(compFile, '<th>Run time</th>');
            utl_file.put_line(compFile, '<th>Throughput</th>');
            
              -- display 'rate 2' as actual statistic
           if comp_acronym = 'CAPTURE' then
             utl_file.put_line(compFile, '<th>Captured/sec</th>');
           elsif comp_acronym = 'Q' then
             utl_file.put_line(compFile, '<th>No of msgs</th>');
           elsif comp_acronym = 'PS' then
             utl_file.put_line(compFile, '<th>bytes/sec</th>');
           elsif comp_acronym = 'APPLY' then
             utl_file.put_line(compFile, '<th>txns applied/sec</th>');
           else
             utl_file.put_line(compFile, '<th>Rate 2</th>');
           end if;

           utl_file.put_line(compFile, '<th>Latency</th>');
           utl_file.put_line(compFile, '<th>% Idle</th>');
           utl_file.put_line(compFile, '<th>% Flwctrl</th>');
           utl_file.put_line(compFile, '<th>% Topevent 1</th>');
           utl_file.put_line(compFile, '<th>Topevent 1</th>');
           utl_file.put_line(compFile, '<th>% Topevent 2</th>');
           utl_file.put_line(compFile, '<th>Topevent 2</th>');
           utl_file.put_line(compFile, '<th>% Topevent 3</th>');
           utl_file.put_line(compFile, '<th>Topevent 3</th>');
           utl_file.put_line(compFile, '</tr>');

           openCompFiles(compFileName) := compFile;

          end if;
          compFiles(compFiles.last) := compFileName;

        end loop;
        close comp_cur;
               

        -- for every run
        for run_id in bgn_run_id..end_run_id loop

          fileName := reportName ||'_' || curr_path_id || '_'
                      || run_id || '.html';
          print_header(directory, fileName);
          file := utl_file.fopen(directory, fileName, 'A');

          utl_file.put_line(file, '<h2><a name = "runlevelstats">' 
                                  || 'RUN LEVEL STATS' ||'</a></h2>');
      
          run_time := get_run_time(comp_stat_table, indexName, run_id,
                                   curr_path_id);

          utl_file.put_line(file, '<b><a name="'|| curr_path_id || '-' 
                               || run_id ||'">'|| 'Path: ' || curr_path_id 
                               || ' Run id: ' || run_id  ||
                               ' Run time: ' || run_time || '</a></b>');

          utl_file.put_line(file, '<table border=2>');
          utl_file.put_line(file, '<tr>');
          utl_file.put_line(file, '<th>Component</th>'); 
          utl_file.put_line(file, '<th>Throughput</th>');
          utl_file.put_line(file, '<th>Rate 2</th>');
          utl_file.put_line(file, '<th>Latency</th>');
          utl_file.put_line(file, '<th>% Idle </th>');
          utl_file.put_line(file, '<th>% Flwctrl </th>');
          utl_file.put_line(file, '<th>% Topevent 1</th>');
          utl_file.put_line(file, '<th>Topevent 1</th>');
          utl_file.put_line(file, '<th>% Topevent 2</th>');
          utl_file.put_line(file, '<th>Topevent 2</th>');
          utl_file.put_line(file, '<th>% Topevent 3</th>');
          utl_file.put_line(file, '<th>Topevent 3</th>');
          utl_file.put_line(file, '</tr>');


         -- get all the components out there
         for i in comp_types.first .. comp_types.last 
         loop
           comp_type := comp_types(i);
           comp_stype :=  comp_stypes(i);
           comp_position := comp_positions(i);
       
           comp_acronym := get_acronym(comp_type,comp_stype);
           compFile := openCompFiles(compFiles(i));

           -- for every such component extract the data
           utl_file.put_line(file, '<tr>');
           utl_file.put_line(compFile, '<tr onclick="DoNav(''' || reportName 
                          || '_' || curr_path_id || '_' || run_id 
                          ||'.html'');" onmouseout="ChangeColor(this,false);"' 
                          || ' onmouseover="ChangeColor(this,true);">');


           -- comp level : path_id, run_id , run_time
           utl_file.put_line(compFile, '<td>' || curr_path_id || '</td>');
           utl_file.put_line(compFile, '<td>' || run_id || '</td>');
           utl_file.put_line(compFile, '<td>' || run_time || '</td>');

           -- populate component name
           if comp_acronym != 'APS' and comp_acronym != 'LMP' then
             if comp_acronym = 'Q' or comp_acronym = 'PS' or
                comp_acronym = 'PR' then
               utl_file.put_line(file, '<td><a href="' || reportName || '_'
                               || comp_acronym ||'at'|| 
                               comp_position||'.html">' ||
                               comp_acronym ||'</a>' || '</td>');
             else
               utl_file.put_line(file, '<td><a href="' || reportName || '_' 
                               || comp_acronym ||'.html">' ||
                              comp_acronym ||'</a>' || '</td>');
             end if;
           else
             stat := get_statistic_by_position(
                          comp_stat_table,'S4', curr_path_id, run_id,
                          comp_position, indexName);
              utl_file.put_line(file, '<td><a href="'|| reportName || '_' 
                            || comp_acronym || '.html">' ||
                            comp_acronym || '(' || stat.stat_value || ')</a>' 
                            || '</td>');
           end if;

           -- populate throughput
           if comp_acronym = 'CAPTURE' then
             -- for capture display enqueued/sec
             stat_alias := 'S2';
           else
             stat_alias := 'S1';
           end if;
          
          stat := get_statistic_by_position(
                          comp_stat_table,stat_alias, curr_path_id, run_id,
                          comp_position, indexName);
         
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
             utl_file.put_line(compFile, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
           end if;

           -- populate rate2 
          if comp_acronym = 'CAPTURE' then
             -- for capture display captured/sec
             stat_alias := 'S1';
           elsif comp_acronym = 'Q' then
             stat_alias := 'S3';
           else
             stat_alias := 'S2';
           end if;
          
           stat := get_statistic_by_position(
                          comp_stat_table,stat_alias, curr_path_id, run_id,
                          comp_position, indexName);
         
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
             utl_file.put_line(compFile, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
           end if;



           -- populate latency
           if comp_acronym != 'Q' then 
             -- for Queues, S3 mean something else
             stat := get_statistic_by_position(
                            comp_stat_table,'S3', curr_path_id, run_id,
                            comp_position, indexName);
         
             if stat.stat_name is not null then
               utl_file.put_line(file, '<td>' || 
                           to_char(stat.stat_value, 'FM99999999') || '</td>');
               utl_file.put_line(compFile, '<td>' || 
                           to_char(stat.stat_value, 'FM99999999') || '</td>');
             else
               utl_file.put_line(file, '<td>&nbsp' || '</td>');
               utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
             end if;
           else
              utl_file.put_line(file, '<td>&nbsp' || '</td>');
              utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
           end if;


           -- populate idle %
           stat := get_statistic_by_position(
                          comp_stat_table,'S5', curr_path_id, run_id,
                          comp_position, indexName);
         
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999D9') || '</td>');
             utl_file.put_line(compFile, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999D9') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
           end if;
           -- populate flwctrl%
           stat := get_statistic_by_position(
                          comp_stat_table,'S6', curr_path_id, run_id,
                          comp_position, indexName);
           if stat.stat_name is not null then
             utl_file.put_line(file, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999D9') || '</td>');
             utl_file.put_line(compFile, '<td>' || 
                         to_char(stat.stat_value, 'FM99999999D9') || '</td>');
           else
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
           end if;
          
           -- populate topevents%,topevents
           event_stmt := 'select /* INDEX(' || comp_stat_table || ' ' ||
                         indexName || ') */ ' || 
                         ' statistic_name, statistic_value' || 
                         ' from ' ||
                          comp_stat_table || 
                         ' where path_id = :curr_path_id ' ||
                         ' and  statistic_alias = ''S7'' ' ||
                         ' and position = :comp_position ' ||
                         ' and advisor_run_id = :run_id ' ||
                         ' and component_type = :comp_type ' ||
                         case when comp_acronym = 'PS' or comp_acronym ='PR'
                                    or comp_stype is null
                               then ' and sub_component_type is null'
                               else ' and sub_component_type = :comp_stype '
                         end ||
                         ' and session_id is null  ' || 
                         ' and session_serial# is null ' ||
                         ' order by statistic_value desc';
           eventCursor := dbms_sql.open_cursor;
           dbms_sql.parse(eventCursor, event_stmt, dbms_sql.native);
           dbms_sql.bind_variable(eventCursor, ':curr_path_id', curr_path_id);
           dbms_sql.bind_variable(eventCursor, ':run_id', run_id);
           dbms_sql.bind_variable(eventCursor, ':comp_position', comp_position);
           dbms_sql.bind_variable(eventCursor, ':comp_type', comp_type);
           if not (comp_acronym = 'PS' or comp_acronym ='PR'
                   or comp_stype is null) then
             dbms_sql.bind_variable(eventCursor, ':comp_stype', comp_stype);
           end if;
           dbms_sql.define_column(eventCursor, 1, event_name, 200);
           dbms_sql.define_column(eventCursor, 2, event_val);
           
           eventRows := dbms_sql.execute(eventCursor);
          
           eventRows := 0;
           -- top events
           while dbms_sql.fetch_rows(eventCursor) > 0 loop
             dbms_sql.column_value(eventCursor, 1, event_name);
             dbms_sql.column_value(eventCursor, 2, event_val);
             if event_val <= 0.0 then
               utl_file.put_line(file, '<td>&nbsp' || '</td>');
               utl_file.put_line(file, '<td>&nbsp' || '</td>');
               utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
               utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
             else
               utl_file.put_line(file, '<td>' || to_char(event_val, 
                                     'FM99999999.99') || '</td>');
               utl_file.put_line(file, '<td>' || event_name || '</td>');
               utl_file.put_line(compFile, '<td>' || to_char(event_val, 
                                     'FM99999999.99') || '</td>');
               utl_file.put_line(compFile, '<td>' || event_name || '</td>');
             end if;

             eventRows := eventRows + 1;
             exit when eventRows = 3;
           end loop;

           -- put in empty rows if we had < 3 events
           while (3 - eventRows) > 0 loop
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(file, '<td>&nbsp' || '</td>');
             utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
             utl_file.put_line(compFile, '<td>&nbsp' || '</td>');
             eventRows := eventRows + 1;
           end loop;

           dbms_sql.close_cursor(eventCursor);

           utl_file.put_line(file, '</tr>');
           utl_file.put_line(compFile, '</tr>');
           
         end loop;
         utl_file.put_line(file, '</table>');
         utl_file.put_line(file, '<br>');
         utl_file.put_line(file,'<h3><a href="'|| reportName ||'">' 
                               || 'Back to Report Home' 
                               || '</a></h3>');
         utl_file.fclose(file);
         print_footer(directory, fileName);
       end loop;

       -- clear all the component info for the path
       comp_types.delete();
       comp_stypes.delete();
       comp_positions.delete();
       compFiles.delete();
     end loop;
     close path_id_cur;
    end;

    -- print footers for all the open component files
    compFileName := openCompFiles.FIRST;
    while compFileName is not null loop
      compFile := openCompFiles(compFileName);
      utl_file.put_line(compFile, '</table>');
      utl_file.put_line(compFile, '<br>');
      utl_file.put_line(compFile,'<h3><a href="'|| reportName ||'">' 
                               || 'Back to Report Home' 
                               || '</a></h3>');
      utl_file.fclose(compFile);
      print_footer(directory, compFileName);
      compFileName := openCompFiles.next(compFileName);
    end loop;


  end PRINT_RUN_AND_COMP_LEVEL_STATS;

  -----------------------------------------------------------------------------=
  -- PRINT_PATHS
  --   Displays a table of all the paths of interest
  --
  -----------------------------------------------------------------------------=
  procedure PRINT_PATHS(
    directory         in varchar2,
    reportName        in varchar2,
    comp_stat_table   in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_id in number default null)
  IS
    type cur_type is ref cursor;
    path_id_cur cur_type;
    query_cur cur_type;
    comp_name varchar2(100);
    comp_type varchar2(100);
    comp_stype varchar2(100);
    comp_acronym varchar2(20);
    comp_position number;
    comp_id number;
    path_id_stmt varchar2(4000) := null;
    query_stmt varchar2(4000)   := null;
    current_path_id STREAMS$_PA_COMPONENT_LINK.path_id%TYPE;
    file  utl_file.file_type;
  begin

    file := utl_file.fopen(directory, reportName, 'A');

    utl_file.put_line(file, '<h2><a name="paths">PATHS</a></h2>');


    path_id_stmt := 'select distinct path_id from ' || comp_stat_table || ' ';
    if path_id is not null then
      path_id_stmt := path_id_stmt || ' where path_id = ' || path_id;
    end if;
    path_id_stmt := path_id_stmt || ' order by path_id';
   
    begin 
      open path_id_cur for path_id_stmt;
      loop 
        fetch path_id_cur into current_path_id;
        exit when path_id_cur%notfound;

        -- print the path id
        utl_file.put_line(file, '<b>Path ' || current_path_id || '</b>');
        utl_file.put_line(file, '<table border=2>');
        utl_file.put_line(file, '<tr>');
        utl_file.put_line(file, '<th>Component</th>'); 
        utl_file.put_line(file, '<th>Name</th>');
        utl_file.put_line(file, '<th>Database</th>');
        utl_file.put_line(file, '</tr>');   
       
        query_stmt := 'select distinct component_name, component_type, ' ||
                      'sub_component_type, position, component_id ' || 
                      ' from ' || comp_stat_table ||' ' || 
                      ' where ' ||
                      ' path_id = ' || current_path_id || 
                      ' order by position';

        open query_cur for query_stmt;
        loop
          fetch query_cur into comp_name, comp_type, comp_stype, 
                               comp_position, comp_id;
          exit when query_cur%notfound;

          comp_acronym := get_acronym(comp_type, comp_stype);
          
          if comp_acronym = 'CAPTURE' or 
             comp_acronym = 'Q' or
             comp_acronym = 'PR' or
             comp_acronym = 'PS' or
             comp_acronym = 'APPLY'
          then
            utl_file.put_line(file, '<tr>');
            utl_file.put_line(file, '<td>' || comp_acronym || '</td>');
            utl_file.put_line(file, '<td>' || comp_name || '</td>'); 
            utl_file.put_line(file, '<td>' || get_component_db(comp_id) 
                                  || '</td>');
            utl_file.put_line(file, '</tr>');
          end if;
        end loop;
        close query_cur;
        
        -- close the table 
        utl_file.put_line(file, '</table>');

      end loop;
      close path_id_cur;  
    end;
    utl_file.fclose(file);
  end PRINT_PATHS;
  
  -----------------------------------------------------------------------------=
  -- PRINT_TOC
  --   Prints the TOC for the report
  -----------------------------------------------------------------------------=
  procedure PRINT_TOC(
    directory         in varchar2,
    reportName        in varchar2
  ) IS
    file  utl_file.file_type;
  begin
    file := utl_file.fopen(directory, reportName, 'A');

    utl_file.put_line(file, '<h1>Contents</h1>');
    utl_file.put_line(file, '<h2><a href="#legend">Legend</a></h2>');
    utl_file.put_line(file, '<h2><a href="#eventmetrics">Event Metrics' 
                             || '</a></h2>');
    utl_file.put_line(file, '<h2><a href="#paths">Paths</a></h2>');
    utl_file.put_line(file, '<h2><a href="#pathsummary">Path Summary</a></h2>');
    utl_file.put_line(file, '<h2><a href="#eventsummary">Path Level Event ' 
                          || 'Summary </a></h2>');
    utl_file.put_line(file, '<h2><a href="#ratesummary">Rate Level Stats'
                          || '</a></h2>');
    utl_file.put_line(file, '<br>');

    utl_file.fclose(file);
  end PRINT_TOC;

  -----------------------------------------------------------------------------=
  -- PRINT_LEGEND
  --   Prints the legend for the interpreting the various columns in the report
  -----------------------------------------------------------------------------=
  procedure PRINT_LEGEND(
    directory         in varchar2,
    reportName        in varchar2
  ) IS
    file  utl_file.file_type;
  begin

    file := utl_file.fopen(directory, reportName, 'A');

    utl_file.put_line(file, '<h2><a name="legend">Legend</a></h2>');
    utl_file.put_line(file, '<table border=2>');
   
    -- column headers
    utl_file.put_line(file, '<tr>');
     utl_file.put_line(file, '<th>Acronym</th>'); 
     utl_file.put_line(file, '<th>Component</th>');
     utl_file.put_line(file, '<th>Throughput</th>');  
     utl_file.put_line(file, '<th>Rate 2</th>');
    utl_file.put_line(file, '</tr>');

    -- CAP
    utl_file.put_line(file, '<tr>'); 
    utl_file.put_line(file, '<td>CAPTURE' || '</td>');
    utl_file.put_line(file, '<td>Capture Component' || '</td>');
    utl_file.put_line(file, '<td>msgs enqueued/sec' || '</td>');
    utl_file.put_line(file, '<td>msgs captured/sec' || '</td>');
    utl_file.put_line(file, '</tr>');

    -- LMR
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>LMR' || '</td>');
    utl_file.put_line(file, '<td>Log Miner Reader' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '</tr>');

    -- LMP
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>LMP' || '</td>');
    utl_file.put_line(file, '<td>Log Miner Preparer' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '</tr>');

    -- LMB
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>LMB' || '</td>');
    utl_file.put_line(file, '<td>Log Miner Builder' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '</tr>');

    -- CP
    utl_file.put_line(file, '<tr>'); 
    utl_file.put_line(file, '<td>CP' || '</td>');
    utl_file.put_line(file, '<td>Capture Process' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '</tr>');
   
    -- Q
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>Q' || '</td>');
    utl_file.put_line(file, '<td>Queue' || '</td>');
    utl_file.put_line(file, '<td>enqueued/sec' || '</td>');
    utl_file.put_line(file, '<td>no of msgs in queue' || '</td>');
    utl_file.put_line(file, '</tr>');

    -- PS
    utl_file.put_line(file, '<tr>'); 
    utl_file.put_line(file, '<td>PS' || '</td>');
    utl_file.put_line(file, '<td>Propagation Sender' || '</td>');
    utl_file.put_line(file, '<td>msgs/sec' || '</td>');
    utl_file.put_line(file, '<td>bytes/sec' || '</td>');
    utl_file.put_line(file, '</tr>');

    -- PR
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>PR' || '</td>');
    utl_file.put_line(file, '<td>Propagation Receiver' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '</tr>');


    -- APPLY
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>APPLY</td>'); 
    utl_file.put_line(file, '<td>Apply component' || '</td>'); 
    utl_file.put_line(file, '<td>msgs applied/sec' || '</td>');
    utl_file.put_line(file, '<td>txns applied/sec' || '</td>');
    utl_file.put_line(file, '</tr>');

    -- APR
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>APR' || '</td>');
    utl_file.put_line(file, '<td>Apply Reader' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '</tr>');
   
    -- APC
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>APC' || '</td>');
    utl_file.put_line(file, '<td>Apply Coordinator' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '</tr>');
   
    -- APS
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>APS' || '</td>'); 
    utl_file.put_line(file, '<td>Apply Slave' || '</td>'); 
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '<td>n/a' || '</td>');
    utl_file.put_line(file, '</tr>');

    utl_file.put_line(file, '</table>');

    utl_file.put_line(file, '<h2><a name="eventmetrics">Event Metrics</a>'
                             ||'</h2>');
    utl_file.put_line(file, '<table border=2>'); 

    -- column headers
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<th>Metric</th>'); 
    utl_file.put_line(file, '<th>Description</th>');
    utl_file.put_line(file, '</tr>');

    --IDLE %
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>IDLE%' || '</td>'); 
    utl_file.put_line(file, '<td>Percent of time in the run,' 
                         || ' spent waiting on upstream ' || 
                         'component' || '</td>'); 
    utl_file.put_line(file, '</tr>');

    --FLWCTRL %
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>FLWCTRL%</td>'); 
    utl_file.put_line(file, '<td>Percent of time in the run, ' 
                         || 'spent waiting on downstream ' ||
                         'component' || '</td>'); 
    utl_file.put_line(file, '</tr>');

    --TOPEVENT
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>TOPEVENT</td>'); 
    utl_file.put_line(file, '<td>Non-idle,Non-flwctrl Event which occupies ' 
                         || 'most of ' || 
                         'run time' || '</td>'); 
    utl_file.put_line(file, '</tr>');
   
    --TOPEVENT%
    utl_file.put_line(file, '<tr>');
    utl_file.put_line(file, '<td>TOPEVENT%' || '</td>'); 
    utl_file.put_line(file, '<td>Percent of time in the run, spent on Topevent' 
                         || '</td>'); 
    utl_file.put_line(file, '</tr>');

    utl_file.put_line(file, '</table>');
    utl_file.fclose(file);
  end PRINT_LEGEND;

  ----------------------------------------------------------------------------=
  -- SHOW_STATS_HTML
  --    generates a html report of the streams performance statistics 
  --    collected using collect_stats
  --
  -- Parameters :
  --   directory       :   directory object name to place the html report
  --   reportName      :   name of the report file to be generated
  --   comp_stat_table :   the comp_stat_tbl used in the previous call to
  --                       collect_stats
  --   path_id         :   path for which statistics needs to be generated
  --   bgn_run_id      :   start run id to generate statistics
  --   end_run_id      :   end run id to generate statistics
  --   detailed        :   TRUE generates run level/ component level 
  --                       statistics also
  --   Print statistics for a stream path.
  ----------------------------------------------------------------------------=
  procedure SHOW_STATS_HTML(
    directory         in varchar2,
    reportName        in varchar2 default 'SPADVREPORT.HTML',
    comp_stat_table   in varchar2 default 'STREAMS$_ADVISOR_COMP_STAT',
    path_id           in number   default null,  -- show all stream paths
    bgn_run_id        in number   default -1,    -- show the last 10 runs
    end_run_id        in number   default -10,
    detailed          in boolean  default TRUE
  ) as
    type cur_type is ref cursor;
    latest_run_id     number default 0;
    actual_bgn_run_id number default 0;
    actual_end_run_id number default 0;
    comp_stat_tbl varchar2(30);
    stmt          varchar2(4000);
    dir           varchar2(255);
    cur cur_type;
  begin
   
    -- check the existence of directory
    dir := UPPER(directory);
    if not check_report_directory(dir) then
      raise_application_error(-20100, 'Invalid Report Directory');
    end if;
 
    -- check existence of table etc
    comp_stat_tbl := CHECK_SPADV_COMP_STAT(comp_stat_table);
    
    -- Check arguments
    if (path_id is not null and path_id < 1) then
      raise_application_error(-20100, 'Invalid path_id');
    end if;
    if (bgn_run_id is null or bgn_run_id = 0) then
      raise_application_error(-20100, 'Invalid bgn_run_id');
    end if;
    if (end_run_id is null or end_run_id = 0) then
      raise_application_error(-20100, 'Invalid end_run_id');
    end if;

    -- Start with the first run (1)
    if (bgn_run_id > 0 and bgn_run_id > end_run_id) then
      raise_application_error(-20100, 'Invalid end_run_id');
    end if;
    -- Start with the latest run (-1)
    if (bgn_run_id < 0 and bgn_run_id < end_run_id ) then
      raise_application_error(-20100, 'Invalid end_run_id');
    end if;
 
    if bgn_run_id <= 0  then
       stmt := 'select distinct advisor_run_id 
       from  ' || comp_stat_tbl || '
       where advisor_run_time in (
                  select max(advisor_run_time)
                  from ' || comp_stat_tbl ||' )';

       open cur for stmt;
       fetch cur into latest_run_id;
       close cur;
 
       actual_bgn_run_id := latest_run_id +  end_run_id  + 1;
       actual_end_run_id := latest_run_id +  bgn_run_id  + 1;
    else
      actual_bgn_run_id := bgn_run_id;
      actual_end_run_id := end_run_id;
    end if;

    PRINT_HEADER(directory, reportName);
    PRINT_TOC(directory, reportName);
    PRINT_LEGEND(directory, reportName);
    PRINT_PATHS(directory, reportName, comp_stat_tbl, path_id);
    PRINT_PATH_LEVEL_SUMMARY(directory, reportName,
                             comp_stat_tbl, path_id, actual_bgn_run_id, 
                             actual_end_run_id);
    PRINT_EVENT_SUMMARY(directory, reportName, 
                        comp_stat_tbl, path_id, actual_bgn_run_id, 
                        actual_end_run_id);
    PRINT_RATE_LEVEL_STATS(directory, reportName,
                           comp_stat_tbl, path_id, actual_bgn_run_id, 
                           actual_end_run_id);
    if detailed then
      PRINT_RUN_AND_COMP_LEVEL_STATS(directory, reportName,
                                  comp_stat_tbl, path_id, actual_bgn_run_id, 
                                  actual_end_run_id);
    end if;
    PRINT_FOOTER(directory, reportName);     

  end SHOW_STATS_HTML;

------------------------------------------------------------------------------=
end UTL_SPADV;
/
show errors;

-- Fix bug 6343077:
-- Drop utl_spadv package and package body 
-- Raise error when utl_spadv is loaded under SYS or SYSTEM
declare
  current_user varchar2(30);
begin
  current_user := SYS_CONTEXT('USERENV', 'CURRENT_USER');

  if (current_user in ('SYS', 'SYSTEM')) then
     execute immediate 'drop package utl_spadv';

     raise_application_error(-20100,
       'The package UTL_SPADV should be loaded into a '||
       'Streams administration schema: current user is '||
       current_user || '.');
  end if;
end;
/
