Rem
Rem $Header: rdbms/admin/catnoawr.sql /st_rdbms_11.2.0/1 2012/07/20 08:21:50 shiyadav Exp $
Rem
Rem catnoawr.sql
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnoawr.sql - Remove Catalog Script for AWR
Rem
Rem    DESCRIPTION
Rem      Catalog script for AWR. Used to drop the  
Rem      Workload Repository Schema.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shiyadav    07/19/12 - bug 13828159: drop few wrh$ tables
Rem    pbelknap    03/11/10 - #8710750: introduce WRI$_SQLTEXT_REFCOUNT
Rem    arbalakr    02/24/09 - drop wrh$_sql_commandtype/toplevelcall tables
Rem    ilistvin    10/23/08 - drop XPL tables
Rem    akini       05/14/08 - drop table WRH$_IOSTAT_DETAIL
Rem    ilistvin    01/28/08 - drop awrrpt_instance_list_type
Rem    ushaft      02/08/07 - add IC_CLIENT_STATS, IC_DEVICE_STATS,
Rem                           MEM_DYNAMIC_COMP, INTERCONNECT_PINGS
Rem    mlfeng      05/21/06 - remove new baseline tables 
Rem    suelee      05/31/06 - Add iostat and resource manager tables 
Rem    gngai       04/28/06 - added wrm$_colored_sql
Rem    amadan      06/05/06 - drop tables WRH$_PERSISTENT_QUEUES and 
Rem                           WRH$_PERSISTENT_SUBSCRIBERS 
Rem    mlfeng      05/17/06 - drops for memory target advice, resize ops
Rem    mlfeng      05/11/05 - drops for mutex sleep, event histogram
Rem    mlfeng      07/27/04 - new table 
Rem    pbelknap    07/16/04 - add dd types 
Rem    ushaft      05/26/04 - drop table WRH$_STREAMS_POOL_ADVICE
Rem    ushaft      05/24/04 - drop WRH$_SGA_TARGET_ADVICE, WRH$_COMP_IOSTAT
Rem    narora      05/20/04 - remove wrh$_sess_time_stats, streams tables
Rem    mlfeng      01/12/04 - class -> instance cache transfer 
Rem    mlfeng      11/24/03 - remove rollstat, add latch_misses_summary
Rem    mlfeng      11/04/03 - add drop for mwin schedule tables 
Rem    pbelknap    11/03/03 - pbelknap_swrfnm_to_awrnm 
Rem    pbelknap    10/28/03 - changing swrf to awr 
Rem    pbelknap    10/09/03 - removing swrfrpt_internal_type 
Rem    pbelknap    10/02/03 - upd swrfrpt types 
Rem    mlfeng      08/26/03 - add drop for rac tables 
Rem    mlfeng      07/10/03 - add drop for service stats
Rem    mlfeng      06/30/03 - drop types
Rem    mlfeng      06/18/03 - add call to remove local dbid from control table
Rem    gngai       06/17/03 - renamed wrh$_session_metric_history
Rem    mlfeng      05/01/03 - remove drops for sequences
Rem    gngai       05/20/03 - added wrm$_snap_error table
Rem    aime        04/25/03 - aime_going_to_main
Rem    mlfeng      03/05/03 - remove drop for wrh$_idle_events
Rem    gngai       03/05/03 - added wrh$_optimizer_env
Rem    gngai       01/31/03 - added wrh$_session_metric_history
Rem    veeve       01/25/03 - added WRH$_OSSTAT and WRH$_SYS_TIME_MODEL
Rem    mlfeng      01/22/03 - drop WRH$_JAVA_POOL_ADVICE, WRH$_THREAD
Rem    mlfeng      01/16/03 - Add drop for wrh$_idle_event
Rem    gngai       01/10/03 - DROP  wrh$_sqlbind table
Rem    wyang       01/24/03 - remove WRH$_ROLLSTAT_BL
Rem    gngai       01/07/03 - added WRH$_METRICNAME
Rem    smuthuli    12/19/02 - drop tablespace related tables
Rem    veeve       11/19/02 - dropped WRH$_ACTIVE_SESSION_HISTORY
Rem    gngai       11/15/02 - added metrics tables
Rem    mlfeng      10/29/02 - Adding the drops for the BL tables
Rem    mlfeng      10/03/02 - SWRF Interfaces and Purging Code
Rem    mlfeng      09/27/02 - Created
Rem


Rem ******************************************************
Rem  Remove the local DBID from the WRM$_WR_CONTROL table
Rem ******************************************************
BEGIN
  dbms_swrf_internal.remove_wr_control;
END;
/

Rem ****************************************************
Rem  Drop the types used for AWR reporting
Rem ****************************************************

drop type AWRRPT_TEXT_TYPE_TABLE
/
drop type AWRRPT_TEXT_TYPE
/
drop type AWRRPT_HTML_TYPE_TABLE
/
drop type AWRDRPT_TEXT_TYPE_TABLE
/
drop type AWRDRPT_TEXT_TYPE
/
drop type AWRRPT_HTML_TYPE
/
drop type AWRRPT_ROW_TYPE
/
drop type AWRRPT_NUM_ARY
/
drop type AWRRPT_VCH_ARY
/
drop type AWRRPT_CLB_ARY
/
drop type AWRSQRPT_TEXT_TYPE_TABLE
/
drop type AWRSQRPT_TEXT_TYPE
/
drop type AWRRPT_INSTANCE_LIST_TYPE
/
drop type AWR_OBJECT_INFO_TABLE_TYPE
/
drop type AWR_OBJECT_INFO_TYPE
/

Rem ******************************
Rem  Drop the AWR Baseline types
Rem ******************************
drop type AWRBL_DETAILS_TYPE_TABLE
/
drop type AWRBL_DETAILS_TYPE
/
drop type AWRBL_METRIC_TYPE_TABLE
/
drop type AWRBL_METRIC_TYPE
/

Rem **************************************************************
Rem ... Dropping the Workload Repository History (WRH$) Tables ...
Rem **************************************************************

drop table WRH$_FILESTATXS
/
drop table WRH$_FILESTATXS_BL
/
drop table WRH$_TEMPSTATXS
/
drop table WRH$_DATAFILE
/
drop table WRH$_TEMPFILE
/
drop table WRH$_COMP_IOSTAT
/
drop table WRH$_IOSTAT_FUNCTION
/
drop table WRH$_IOSTAT_FUNCTION_NAME
/
drop table WRH$_IOSTAT_FILETYPE
/
drop table WRH$_IOSTAT_FILETYPE_NAME
/
drop table WRH$_IOSTAT_DETAIL
/
drop table WRH$_SQLCOMMAND_NAME
/
drop table WRH$_TOPLEVELCALL_NAME
/
Rem ************************************************************************* 
Rem ---------------------- SQL Statistics ---------------------------------- 
Rem ************************************************************************* 

drop table WRH$_SQLSTAT
/
drop table WRH$_SQLSTAT_BL
/
drop table WRH$_SQLTEXT
/
drop table WRI$_SQLTEXT_REFCOUNT
/
drop table WRH$_SQL_SUMMARY
/
drop table WRH$_SQL_PLAN
/
drop table WRH$_SQL_BIND_METADATA
/
drop table WRH$_OPTIMIZER_ENV
/
drop table WRH$_XPL_OPERATION_NAME
/
drop table WRH$_XPL_OPTION_NAME
/
drop table WRH$_PLAN_OPERATION_NAME
/
drop table WRH$_PLAN_OPTION_NAME
/

Rem ************************************************************************* 
Rem ---------------------- Concurrency Statistics --------------------------- 
Rem ************************************************************************* 

drop table WRH$_SYSTEM_EVENT
/
drop table WRH$_SYSTEM_EVENT_BL
/
drop table WRH$_EVENT_NAME
/
drop table WRH$_LATCH_NAME
/
drop table WRH$_BG_EVENT_SUMMARY
/
drop table WRH$_WAITSTAT
/
drop table WRH$_WAITSTAT_BL
/
drop table WRH$_ENQUEUE_STAT
/
drop table WRH$_LATCH
/
drop table WRH$_LATCH_BL
/
drop table WRH$_LATCH_CHILDREN
/
drop table WRH$_LATCH_CHILDREN_BL
/
drop table WRH$_LATCH_PARENT
/
drop table WRH$_LATCH_PARENT_BL
/
drop table WRH$_LATCH_MISSES_SUMMARY
/
drop table WRH$_LATCH_MISSES_SUMMARY_BL
/
drop table WRH$_EVENT_HISTOGRAM
/
drop table WRH$_EVENT_HISTOGRAM_BL
/
drop table WRH$_MUTEX_SLEEP
/

Rem ************************************************************************* 
Rem ---------------------- Instance Statistics ------------------------------ 
Rem ************************************************************************* 

drop table WRH$_LIBRARYCACHE
/
drop table WRH$_DB_CACHE_ADVICE
/
drop table WRH$_DB_CACHE_ADVICE_BL
/
drop table WRH$_BUFFER_POOL_STATISTICS
/
drop table WRH$_SGA
/
drop table WRH$_SGASTAT
/
drop table WRH$_SGASTAT_BL
/
drop table WRH$_PGASTAT
/
drop table WRH$_PROCESS_MEMORY_SUMMARY
/
drop table WRH$_ROWCACHE_SUMMARY
/
drop table WRH$_ROWCACHE_SUMMARY_BL
/
drop table WRH$_RESOURCE_LIMIT
/
drop table WRH$_SHARED_POOL_ADVICE
/
drop table WRH$_STREAMS_POOL_ADVICE
/
drop table WRH$_SQL_WORKAREA_HISTOGRAM
/
drop table WRH$_PGA_TARGET_ADVICE
/
drop table WRH$_INSTANCE_RECOVERY
/
drop table WRH$_JAVA_POOL_ADVICE
/
drop table WRH$_THREAD
/
drop table WRH$_SGA_TARGET_ADVICE
/
drop table WRH$_MEMORY_TARGET_ADVICE
/
drop table WRH$_MEMORY_RESIZE_OPS
/
drop table WRH$_MEM_DYNAMIC_COMP
/
drop table WRH$_INTERCONNECT_PINGS
/
drop table WRH$_INTERCONNECT_PINGS_BL
/


Rem ************************************************************************* 
Rem --------------------- General System Statistics ------------------------- 
Rem ************************************************************************* 

drop table WRH$_SYSSTAT
/
drop table WRH$_SYSSTAT_BL
/
drop table WRH$_SYS_TIME_MODEL
/
drop table WRH$_SYS_TIME_MODEL_BL
/
drop table WRH$_OSSTAT
/
drop table WRH$_OSSTAT_BL
/
drop table WRH$_PARAMETER
/
drop table WRH$_PARAMETER_BL
/
drop table WRH$_STAT_NAME
/
drop table WRH$_OSSTAT_NAME
/
drop table WRH$_PARAMETER_NAME
/
drop table WRH$_MVPARAMETER
/
drop table WRH$_MVPARAMETER_BL
/

Rem ************************************************************************* 
Rem ------------------------- Undo Statistics ------------------------------- 
Rem ************************************************************************* 

drop table WRH$_UNDOSTAT
/

Rem ************************************************************************* 
Rem ----------------------- Segment Statistics ------------------------------ 
Rem ************************************************************************* 

drop table WRH$_SEG_STAT
/
drop table WRH$_SEG_STAT_BL
/
drop table WRH$_SEG_STAT_OBJ
/

Rem ************************************************************************* 
Rem ---------------------- Metrics Tables ----------------------------------- 
Rem ************************************************************************* 
drop table WRH$_METRIC_NAME
/
drop table WRH$_SYSMETRIC_HISTORY
/
drop table WRH$_SYSMETRIC_SUMMARY
/
drop table WRH$_SESSMETRIC_HISTORY
/
drop table WRH$_FILEMETRIC_HISTORY
/
drop table WRH$_WAITCLASSMETRIC_HISTORY
/

Rem ************************************************************************* 
Rem ---------------------- Tablespace Statistics ---------------------------- 
Rem ************************************************************************* 
drop table WRH$_TABLESPACE
/
drop table WRH$_TABLESPACE_SPACE_USAGE
/

Rem ************************************************************************* 
Rem -------------------------- RAC Statistics ------------------------------- 
Rem ************************************************************************* 

drop table WRH$_DLM_MISC
/
drop table WRH$_DLM_MISC_BL
/
drop table WRH$_CR_BLOCK_SERVER
/
drop table WRH$_CURRENT_BLOCK_SERVER
/
drop table WRH$_INST_CACHE_TRANSFER
/
drop table WRH$_INST_CACHE_TRANSFER_BL
/
drop table WRH$_IC_DEVICE_STATS
/
drop table WRH$_IC_CLIENT_STATS
/
drop table WRH$_CLUSTER_INTERCON
/
drop table WRH$_DYN_REMASTER_STATS
/

Rem *************************************************************************
Rem ---------------------Active Session History -----------------------------
Rem *************************************************************************
drop table  WRH$_ACTIVE_SESSION_HISTORY
/
drop table  WRH$_ACTIVE_SESSION_HISTORY_BL
/

Rem ************************************************************************* 
Rem -------------------------- Tablespace Statistics ------------------------ 
Rem ************************************************************************* 
drop table WRH$_TABLESPACE_STAT
/
drop table WRH$_TABLESPACE_STAT_BL
/

Rem ************************************************************************* 
Rem -------------------------- WRH$_LOG Statistics ------------------------ 
Rem ************************************************************************* 
drop table WRH$_LOG
/

Rem ************************************************************************* 
Rem -------------------------- MTTR Target Advice --------------------------- 
Rem ************************************************************************* 
drop table WRH$_MTTR_TARGET_ADVICE
/

Rem ************************************************************************* 
Rem ----------------------- Service Statistics ------------------------------ 
Rem ************************************************************************* 

drop table WRH$_SERVICE_NAME
/
drop table WRH$_SERVICE_STAT
/
drop table WRH$_SERVICE_STAT_BL
/
drop table WRH$_SERVICE_WAIT_CLASS
/
drop table WRH$_SERVICE_WAIT_CLASS_BL
/

Rem ************************************************************************* 
Rem ----------------------- Session Time Stats ------------------------------ 
Rem ************************************************************************* 

drop table WRH$_SESS_TIME_STATS
/

Rem ************************************************************************* 
Rem ----------------------- STREAMS Stats Table ----------------------------- 
Rem ************************************************************************* 

drop table WRH$_STREAMS_CAPTURE
/
drop table WRH$_STREAMS_APPLY_SUM
/
drop table WRH$_BUFFERED_QUEUES
/
drop table WRH$_BUFFERED_SUBSCRIBERS
/
drop table WRH$_RULE_SET
/
drop table WRH$_PERSISTENT_QUEUES
/
drop table WRH$_PERSISTENT_SUBSCRIBERS
/
drop table WRH$_PERSISTENT_QMN_CACHE
/

Rem ************************************************************************* 
Rem -------- Tables For Maintenance Window Auto Tasks Schedules -------------
Rem ************************************************************************* 

drop table WRI$_SCH_CONTROL
/
drop table WRI$_SCH_VOTES
/

Rem *************************************************************************
Rem ------------------ Resource Manager Statistics --------------------------
Rem *************************************************************************

drop table WRH$_RSRC_CONSUMER_GROUP
/
drop table WRH$_RSRC_PLAN
/

Rem ******************************************************
Rem -------------- Shared Server Statistics --------------
Rem ******************************************************
drop table WRH$_DISPATCHER
/
drop table WRH$_SHARED_SERVER_SUMMARY
/

Rem ************************
Rem Drop the Metadata Tables
Rem ************************

drop table WRM$_COLORED_SQL
/
drop table WRM$_BASELINE
/
drop table WRM$_BASELINE_DETAILS
/
drop table WRM$_BASELINE_TEMPLATE
/
drop table WRM$_WR_CONTROL
/
drop table WRM$_SNAPSHOT
/
drop table WRM$_SNAP_ERROR
/
drop table WRM$_DATABASE_INSTANCE
/
