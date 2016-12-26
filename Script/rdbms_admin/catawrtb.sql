Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catawrtb.sql - Catalog script for AWR Tables
Rem
Rem    DESCRIPTION
Rem      Catalog script for AWR Tables. Used to create the  
Rem      Workload Repository Schema.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem      The WRM$_WR_CONTROL table must be the LAST table created in this
Rem      file.  Please add any new statistics tables before the WRM$ tables.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mfallen     07/18/12 - bug 14226622: add IP to WRH$_CLUSTER_INTERCON_PK
Rem    mfallen     01/16/13 - Backport mfallen_bug-14226622 from
Rem    shiyadav    07/22/11 - Backport shiyadav_bug-12317689 from main
Rem    pbelknap    02/25/10 - #8710750: AWR deadlocks
Rem    bdagevil    03/14/10 - add px_flags column to
Rem                           WRH$_ACTIVE_SESSION_HISTORY
Rem    dongfwan    02/22/10 - Bug 9266913: add snap_timezone to wrm$_snapshot
Rem    dongfwan    01/13/10 - Bug 9264020: add wrm$_snapshot_details table to AWR
Rem    sburanaw    02/04/10 - add db replay's callid to ASH
Rem    jomcdon     01/21/10 - Bug 9207475: Allow end_time to be null
Rem    jomcdon     12/31/09 - bug 9212250: add PQQ fields to AWR tables
Rem    ilistvin    11/18/09 - bug8811401: add AWR_OBJECT_INFO_TYPE
Rem    amadan      11/13/09 - Bug 9115881: Update
Rem                           persistent_queues/persistent_subscribers
Rem    arbalakr    11/13/09 - increase length of module and action columns
Rem    ilistvin    08/17/09 - add public synonym for AWRRPT_INSTANCE_LIST_TYPE
Rem    sriganes    07/24/09 - bug 8413874: add multi-valued parameters in AWR
Rem    adng        07/01/09 - add stats for Exadata
Rem    mfallen     06/16/09 - add wrm$_report_usage
Rem    mfallen     03/20/09 - bug 8347956: add flash cache columns
Rem    arbalakr    02/24/09 - add wrh$_sqlcommand_name/toplevelcall_name
Rem    arbalakr    02/23/09 - bug 7350685/8283758 add top_level_call#,
Rem                           hostname and portnum 
Rem                           to WRH$_ACTIVE_SESSION_HISTORY
Rem    lgalanis    02/17/09 - bug 7483450 impact on awr import
Rem    amysoren    02/05/09 - bug 7483450: add foreground values to
Rem                           waitclassmetric
Rem    mfallen     01/04/09 - bug 7650345: add new sqlstat and seg_stat columns
Rem    bdagevil    01/02/09 - add STASH columns to ASH
Rem    mfallen     10/27/08 - bug 7247999: modify pkey for wrh$_ic_device_stats
Rem    ilistvin    10/22/08 - add wrh$_plan_operation_name and
Rem                           wrh$_plan_option_name tables
Rem    mfallen     05/15/08 - bug 7029198: add wrh$_dyn_remaster_stats
Rem    jgiloni     04/15/08 - Shared Server AWR Stats
Rem    akini       03/18/08 - added WRH$_IOSTAT_DETAIL
Rem    mfallen     03/12/08 - bug 6861722: add column to wrh$_db_cache_advice
Rem    akini       02/13/08 - increase length of ip addresses for IPv6
Rem    ilistvin    10/22/07 - add awr_instance_list_type
Rem    sburanaw    12/11/07 - add blocking_inst_id, ecid to ASH
Rem    mlfeng      08/22/07 - increase size of NAME column for the cluster 
Rem                           interconnect table
Rem    mlfeng      07/13/07 - re-introduce ts# as part o f the primary key 
Rem                           (bug 6214874)
Rem    mlfeng      06/28/07 - BL tables and base table must have the same
Rem                           column order (bug 6155322)
Rem    pbelknap    04/03/07 - add parsing_user_id to sqlstat_bl tables too
Rem    pbelknap    03/23/07 - add parsing_user_id to sqlstat
Rem    mlfeng      04/18/07 - platform name to database_instance
Rem    sburanaw    03/02/07 - rename column top_sql* to top_level_sql* in
Rem                           WRH$_ACTIVE_SESSION_HISTORY
Rem    ushaft      02/08/07 - add IC_CLIENT_STATS, IC_DEVICE_STATS,
Rem                           MEM_DYNAMIC_COMP, INTERCONNECT_PINGS
Rem    veeve       03/06/07 - added flags to WRH$_ACTIVE_SESSION_HISTORY
Rem    mlfeng      02/20/07 - sql plan column lengths
Rem    amadan      02/10/07 - add first_activity_time to WRH$_PERSISTENT_QUEUES
Rem    ilistvin    08/08/06 - increase the number of columns in reports
Rem    suelee      01/02/07 - Disable IORM
Rem    mlfeng      10/05/06 - pctfree sysmetric_history
Rem    kyagoub     09/10/06 - extend optimizer_env size to 2000
Rem    sburanaw    08/03/06 - add current_row# column to 
Rem                           WRH$_ACTIVE_SESSION_HISTORY
Rem    ushaft      08/03/06 - add column to pga_target_advice
Rem    mlfeng      07/21/06 - add interconnect table
Rem    suelee      07/25/06 - Fix units for Resource Manager views 
Rem    mlfeng      07/17/06 - add sum squares 
Rem    veeve       06/21/06 - add new 11g WRH$_ACTIVE_SESSION_HISTORY columns
Rem    mlfeng      06/11/06 - add last_time_computed 
Rem    mlfeng      05/20/06 - add columns to baselines 
Rem    suelee      05/18/06 - Add IO statistics tables 
Rem    gngai       04/14/06 - added wrm$_colored_sql
Rem    ushaft      05/26/06 - added 16 columns to WRH$_INST_CACHE_TRANSFER
Rem    amadan      05/22/06 - add WRH_PERSISTENT_SUBSCRIBERS 
Rem    amadan      05/16/06 - add WRH$_PERSISTENT_QUEUES 
Rem    mlfeng      05/14/06 - add memory tables 
Rem    amysoren    05/17/06 - foreground component in system_event 
Rem    veeve       02/10/06 - add qc_session_serial# to ASH 
Rem    adagarwa    04/25/05 - Added PL/SQL stack fields to 
Rem                           WRH$_ACTIVE_SESSION_HISTORY
Rem    mlfeng      05/10/05 - add event histogram, mutex sleep 
Rem    mlfeng      05/25/05 - bug 4393879: disable metrics constraints 
Rem    mlfeng      04/11/05 - add flag to WRH$_SQLSTAT
Rem    adagarwa    03/04/05 - Added force_match_sig,blocking_session_srl# 
Rem                           to WRH$_ACTIVE_SESSION_HISTORY
Rem    narora      03/07/05 - add queue_id to WRH$_BUFFERED_QUEUES 
Rem    wyang       02/18/05 - add columns to wrh$_undostat
Rem    adagarwa    11/22/04 - Created new table type for AWR SQL Report 
Rem    mlfeng      09/21/04 - add parsing_schema_name 
Rem    mlfeng      09/02/04 - add indices for metric tables 
Rem    mlfeng      07/23/04 - sqlbind changes, new tables 
Rem    pbelknap    08/04/04 - make awr html types bigger 
Rem    pbelknap    07/16/04 - report types now defined on characters not bytes
Rem    veeve       06/16/04 - modify PROGRAM from 48 to 64
Rem    veeve       05/28/04 - add WRH$_SEG_STAT_OBJ.[INDEX_TYPE,BASE*]
Rem    narora      05/20/04 - add wrh$_sess_time_stats, streams tables 
Rem    mlfeng      05/21/04 - add topnsql column 
Rem    vakrishn    05/22/04 - adding status to wrh$_undostat 
Rem    ushaft      05/26/04 - added WRH$_STREAMS_POOL_ADVICE
Rem    ushaft      05/15/04 - Added WRH$_COMP_IO_STATS, WRH$_SGA_TARGET_ADVICE
Rem    bdagevil    06/03/04 - increase size of object_node 
Rem    bdagevil    05/26/04 - add timestamp column in explain plan 
Rem    bdagevil    05/13/04 - add other_xml column 
Rem    veeve       05/06/04 - add blocking_session,xid to ASH 
Rem    smuthuli    05/13/04 - add CHAIN_ROW* stats to wrh$_seg_stat 
Rem    mlfeng      04/26/04 - p1, p2, p3 for event name 
Rem    mlfeng      01/30/04 - add gc buffer busy 
Rem    mlfeng      01/12/04 - class -> instance cache transfer 
Rem    jxchen      02/16/04 - Increase size of MAX_COLUMNS 
Rem    jxchen      12/26/03 - Add types for Diff-Diff Report 
Rem    mlfeng      12/16/03 - partitioning event off 
Rem    mlfeng      11/24/03 - pctfree 1
Rem    veeve       11/20/03 - removed sample_time from ASH index
Rem    mlfeng      11/24/03 - remove rollstat, add latch_misses_summary_bl
Rem    mlfeng      11/12/03 - add flag bit to the wrm$_snapshot table
Rem    mlfeng      11/06/03 - update wrh$_sql_plan, instance_name nullable
Rem    mlfeng      11/04/03 - add new tables for mwin schedules 
Rem    pbelknap    11/03/03 - pbelknap_swrfnm_to_awrnm 
Rem    pbelknap    10/28/03 - changing swrf to awr 
Rem    pbelknap    10/09/03 - remove swrfrpt_internal_type
Rem    mlfeng      09/24/03 - turn off event
Rem    pbelknap    09/19/03 - Adding types for HTML support 
Rem    mlfeng      08/29/03 - sync up with v$ changes 
Rem    mlfeng      08/26/03 - add new RAC tables 
Rem    mlfeng      07/10/03 - add service stats
Rem    nmacnaug    08/13/03 - remove unused statistic 
Rem    mlfeng      08/04/03 - remove address columns from ash, sql_bind 
Rem    mlfeng      08/05/03 - remove not null constraint from wrh$_sgastat 
Rem    mlfeng      07/25/03 - add group name to metric name
Rem    gngai       08/01/03 - changed event class metrics
Rem    mramache    06/24/03 - hintset_applied -> sql_profile
Rem    mlfeng      06/30/03 - types for reporting
Rem    gngai       06/17/03 - renamed wrh$_session_metric_history
Rem    mlfeng      05/30/03 - remove (6) from snap_id
Rem    mramache    05/19/03 - pls/java time cursor stat
Rem    gngai       05/20/03 - added new error info table
Rem    bdagevil    04/28/03 - merge new file
Rem    mlfeng      03/17/03 - Adding hash to name tables
Rem    gngai       04/03/03 - added dbid as range partition key
Rem    mlfeng      04/01/03 - add block_size to wrh$_datafile, wrh$_tempfile
Rem    gngai       03/15/03 - fixed flush_elapsed wrm$_snapshot
Rem    veeve       04/22/03 - Modified WRH$_ACTIVE_SESSION_HISTORY[_BL] table
Rem                           sql_hash_value OUT, sql_id IN, sql_address OUT
Rem                           removed sql_address  
Rem    bdagevil    04/23/03 - wrh$_undostat: use sql_id instead of signature
Rem    mlfeng      04/22/03 - Modify signature/hash value to sql_id
Rem    mlfeng      04/14/03 - modify columns to sqlstat, sqltext
Rem    veeve       03/05/03 - renamed service_id to service_hash
Rem                           in WRH$_ACTIVE_SESSION_HISTORY
Rem    mlfeng      03/05/03 - disable partitioning check
Rem    gngai       03/06/03 - added split_time in wrm$_wr_control
Rem    gngai       03/05/03 - added wrh$_optimizer_env
Rem    smuthuli    02/18/03 - increase rtime data size
Rem    mlfeng      02/13/03 - Move Tablespace Usage table
Rem    mlfeng      02/13/03 - Remove wrh$_idle_event, add 'class' to event name
Rem    gngai       02/24/03 - changed wrm$_wr_control
Rem    gngai       01/31/03 - added WRH$_SESSION_METRIC_HISTORY
Rem    veeve       01/25/03 - added WRH$_OSSTAT and WRH$_SYS_TIME_MODEL
Rem                           added coln PARTITION_TYPE TO WRH$_SEG_STAT_OBJ
Rem                           added new WRH$_SQLSTAT columns
Rem    mlfeng      01/22/03 - Add WRH$_THREAD, WRH$_JAVA_POOL_ADVICE
Rem    mlfeng      01/22/03 - Updating enqueue_stat, shared_pool_advice
Rem    gngai       01/10/03 - add wrh$_sqlbind
Rem    wyang       01/22/03 - make rollstat non-partitioned
Rem    gngai       01/21/03 - added Flag to wrm$_snapshot 
Rem    veeve       12/31/02 - added snap_id to wrh$_ash
Rem    smuthuli    01/07/03 - create index on WRH$_TABLESPACE_SPACE_USAGE
Rem    mlfeng      01/16/03 - Adding WRH$_IDLE_EVENTS
Rem    smuthuli    01/20/03 - add timestamp to tablespace swrf table
Rem    gngai       12/20/02 - added HDM stats
Rem    gngai       01/14/03 - fixed WRH$_SGASTAT
Rem    gngai       01/07/03 - added WRH$_METRIC_NAME
Rem    vakrishn    12/27/02 - change undostat
Rem    mlfeng      12/05/02 - Moved ASH tables before the metadata tables
Rem    mlfeng      11/22/02 - Updating segment statistics table
Rem    veeve       11/22/02 - Added last_ash_sample_id 
Rem                           in WRM$_DATABASE_INSTANCE
Rem    smuthuli    11/26/02 - Add WRH$_TABLESPACE_SPACE_USAGE
Rem    mlfeng      12/11/02 - Adding column to control table/
Rem    gngai       12/10/02 - added precision to TIMESTAMP columns
Rem    veeve       11/19/02 - Added WRH$_ACTIVE_SESSION_HISTORY
Rem    gngai       11/15/02 - added metrics tables
Rem    mlfeng      10/29/02 - Adding BL tables and partitioned tables
Rem    mlfeng      10/23/02 - updating control table
Rem    mlfeng      10/18/02 - Modifying Segment Statistics Table
Rem    mlfeng      10/03/02 - SWRF Interfaces and Purging Code
Rem    mlfeng      09/27/02 - Created
Rem

Rem =========================================================================
Rem ************************************************************************* 
Rem Creating the Workload Repository History (WRH$) Tables ...
Rem
Rem ************************************************************************* 
Rem ======================== File Statistics ================================
Rem ************************************************************************* 

-- Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table          WRH$_FILESTATXS
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,file#                number          not null
,creation_change#     number          not null
,phyrds               number
,phywrts              number
,singleblkrds         number
,readtim              number
,writetim             number
,singleblkrdtim       number
,phyblkrd             number
,phyblkwrt            number
,wait_count           number
,time                 number
,constraint WRH$_FILESTATXS_PK primary key 
     (dbid, snap_id, instance_number, file#)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_FILESTATXS_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_FILESTATXS_BL;
create table WRH$_FILESTATXS_BL tablespace SYSAUX 
 as select * from WRH$_FILESTATXS where rownum < 1
/

alter table  WRH$_FILESTATXS_BL
 add constraint WRH$_FILESTATXS_BL_PK primary key 
     (dbid, snap_id, instance_number, file#)
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_TEMPSTATXS
(snap_id             number        not null
,dbid                number        not null
,instance_number     number        not null
,file#               number        not null
,creation_change#    number        not null
,phyrds              number
,phywrts             number
,singleblkrds        number
,readtim             number
,writetim            number
,singleblkrdtim      number
,phyblkrd            number
,phyblkwrt           number
,wait_count          number
,time                number
,constraint WRH$_TEMPSTATXS_PK primary key
     (dbid, snap_id, instance_number, file#)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

create table WRH$_DATAFILE
(snap_id             number                /* last snap id, used for purging */
,dbid                number         not null
,file#               number         not null
,creation_change#    number         not null
,filename            varchar2(513)  not null
,ts#                 number         not null
,tsname              varchar2(30)   not null
,block_size          number
,constraint WRH$_DATAFILE_PK primary key
     (dbid, file#, creation_change#)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

create table WRH$_TEMPFILE
(snap_id             number                /* last snap id, used for purging */
,dbid                number         not null
,file#               number         not null
,creation_change#    number         not null
,filename            varchar2(513)  not null
,ts#                 number         not null
,tsname              varchar2(30)   not null
,block_size          number
,constraint WRH$_TEMPFILE_PK primary key
     (dbid, file#, creation_change#)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 
Rem Table to capture I/O stats aggregated on component level.
Rem Component: kernel internal component (e.g., 'RMAN')
Rem File_type: aggregate level for files (e.g., 'DATAFILE', 'LOGFILE', 'TAPE')
Rem io_type : one of 'SYNC', 'ASYNC'
Rem operation: one of 'READ', 'WRITE'
Rem bytes: total number of bytes used in the operation
Rem io_count: total number of io requests for the operation
Rem
Rem Note that not all components or file types are represented in this table
Rem

create table WRH$_COMP_IOSTAT
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,component            varchar2(64)    not null
,file_type            varchar2(64)    not null
,io_type              char(5)         not null
,operation            char(5)         not null
,bytes                number          not null
,io_count             number          not null
,constraint WRH$_COMP_IOSTAT_PK primary key
    (dbid, snap_id, instance_number, component, file_type, io_type, operation)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 
Rem Table to capture I/O statistics by function, based on the I/O statistics
Rem captured by v$iostat_function.
Rem

create table WRH$_IOSTAT_FUNCTION
(snap_id               number          not null,
 dbid                  number          not null,
 instance_number       number          not null,
 function_id           number          not null,
 small_read_megabytes  number          not null,
 small_write_megabytes number          not null,
 large_read_megabytes  number          not null,
 large_write_megabytes number          not null,
 small_read_reqs       number          not null,
 small_write_reqs      number          not null,
 large_read_reqs       number          not null,
 large_write_reqs      number          not null,
 number_of_waits       number          not null,
 wait_time             number          not null,
 constraint WRH$_IOSTAT_FUNCTION_PK primary key
   (dbid, snap_id, instance_number, function_id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 
Rem Table of function names for WRH$_IOSTAT_FUNCTION
Rem

create table WRH$_IOSTAT_FUNCTION_NAME
(dbid                 number          not null,
 function_id          number          not null,
 function_name        varchar2(30)    not null,
 constraint WRH$_IOSTAT_FUNCTION_NAME_PK primary key (dbid, function_id)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 
Rem Table to capture I/O statistics by file type, based on the I/O statistics
Rem captured by v$iostat_file.
Rem

create table WRH$_IOSTAT_FILETYPE
(snap_id                   number     not null,
 dbid                      number     not null,
 instance_number           number     not null,
 filetype_id               number     not null,
 small_read_megabytes      number     not null,
 small_write_megabytes     number     not null,
 large_read_megabytes      number     not null,
 large_write_megabytes     number     not null,
 small_read_reqs           number     not null,
 small_write_reqs          number     not null,
 small_sync_read_reqs      number     not null,
 large_read_reqs           number     not null,
 large_write_reqs          number     not null,
 small_read_servicetime    number     not null,
 small_write_servicetime   number     not null,
 small_sync_read_latency   number     not null,
 large_read_servicetime    number     not null,
 large_write_servicetime   number     not null,
 retries_on_error          number     not null,
 constraint WRH$_IOSTAT_FILETYPE_PK primary key
   (dbid, snap_id, instance_number, filetype_id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 
Rem Table of file type names for WRH$_IOSTAT_FILETYPE
Rem

create table WRH$_IOSTAT_FILETYPE_NAME
(dbid                 number          not null,
 filetype_id          number          not null,
 filetype_name        varchar2(30)    not null,
 constraint WRH$_IOSTAT_FILETYPE_NAME_PK primary key (dbid, filetype_id)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 
Rem Table to capture I/O stats aggregated by component (function) and filetype,
Rem based on the stats captured by v$iostat_function_detail

create table WRH$_IOSTAT_DETAIL
(snap_id               number          not null,
 dbid                  number          not null,
 instance_number       number          not null,
 function_id           number          not null,
 filetype_id           number          not null,
 small_read_megabytes  number          not null,
 small_write_megabytes number          not null,
 large_read_megabytes  number          not null,
 large_write_megabytes number          not null,
 small_read_reqs       number          not null,
 small_write_reqs      number          not null,
 large_read_reqs       number          not null,
 large_write_reqs      number          not null,
 number_of_waits       number          not null,
 wait_time             number          not null,
 constraint WRH$_IOSTAT_DETAIL_PK primary key
   (dbid, snap_id, instance_number, function_id, filetype_id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

Rem ************************************************************************* 
Rem ======================= SQL Statistics ================================== 
Rem ************************************************************************* 

Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%%  
create table          WRH$_SQLSTAT
(snap_id                    number           not null
,dbid                       number           not null
,instance_number            number           not null
,sql_id                     varchar2(13)     not null
,plan_hash_value            number           not null
,optimizer_cost             number
,optimizer_mode             varchar2(10)
,optimizer_env_hash_value   number
,sharable_mem               number
,loaded_versions            number
,version_count              number
,module                     varchar2(64)
,action                     varchar2(64)
,sql_profile                varchar2(64)
,force_matching_signature   number
,parsing_schema_id          number
,parsing_schema_name        varchar2(30)
,fetches_total              number
,fetches_delta              number
,end_of_fetch_count_total   number
,end_of_fetch_count_delta   number
,sorts_total                number
,sorts_delta                number
,executions_total           number
,executions_delta           number
,px_servers_execs_total     number
,px_servers_execs_delta     number
,loads_total                number
,loads_delta                number
,invalidations_total        number
,invalidations_delta        number
,parse_calls_total          number
,parse_calls_delta          number
,disk_reads_total           number
,disk_reads_delta           number
,buffer_gets_total          number
,buffer_gets_delta          number
,rows_processed_total       number
,rows_processed_delta       number
,cpu_time_total             number
,cpu_time_delta             number
,elapsed_time_total         number
,elapsed_time_delta         number
,iowait_total               number
,iowait_delta               number
,clwait_total               number
,clwait_delta               number
,apwait_total               number
,apwait_delta               number
,ccwait_total               number
,ccwait_delta               number
,direct_writes_total        number
,direct_writes_delta        number
,plsexec_time_total         number
,plsexec_time_delta         number
,javexec_time_total         number
,javexec_time_delta         number
,bind_data                  raw(2000)
,flag                       number
,parsing_user_id            number
,io_offload_elig_bytes_total    number
,io_offload_elig_bytes_delta    number
,io_interconnect_bytes_total    number
,io_interconnect_bytes_delta    number
,physical_read_requests_total   number
,physical_read_requests_delta   number
,physical_read_bytes_total      number
,physical_read_bytes_delta      number
,physical_write_requests_total  number
,physical_write_requests_delta  number
,physical_write_bytes_total     number
,physical_write_bytes_delta     number
,optimized_physical_reads_total number
,optimized_physical_reads_delta number
,cell_uncompressed_bytes_total  number
,cell_uncompressed_bytes_delta  number
,io_offload_return_bytes_total  number
,io_offload_return_bytes_delta  number
,constraint WRH$_SQLSTAT_PK primary key
    (dbid, snap_id, instance_number, sql_id, plan_hash_value)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_SQLSTAT_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/


Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem  create an additional index on the WRH$_SQLSTAT table
Rem  This index is useful if users want to select the AWR
Rem  SQL data for a particular sql_id.
Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create index WRH$_SQLSTAT_INDEX 
  on WRH$_SQLSTAT(sql_id, dbid) 
  local tablespace SYSAUX
/


Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_SQLSTAT_BL;
create table WRH$_SQLSTAT_BL tablespace SYSAUX 
 as select * from WRH$_SQLSTAT where rownum < 1
/

alter table  WRH$_SQLSTAT_BL
 add constraint WRH$_SQLSTAT_BL_PK primary key
    (dbid, snap_id, instance_number, sql_id, plan_hash_value)
 using index tablespace SYSAUX
/

Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem  create an additional index on the WRH$_SQLSTAT_BL table
Rem  This index is useful if users want to select the AWR
Rem  SQL data for a particular sql_id.
Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create index WRH$_SQLSTAT_BL_INDEX 
  on WRH$_SQLSTAT_BL(sql_id, dbid) 
  tablespace SYSAUX
/


Rem ========================================================================= 

create table WRH$_SQLTEXT
(snap_id         number                    /* last snap id, used for purging */
,dbid            number       not null
,sql_id          varchar2(13) not null
,sql_text        clob
,command_type    number
,ref_count       number         /* no longer used, see WRI$_SQLTEXT_REFCOUNT */
,constraint WRH$_SQLTEXT_PK primary key (dbid, sql_id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

Rem
Rem The ref_count in WRH$_SQLTEXT is no longer used and instead we track
Rem ref counts in this table to avoid contention.  Ref counting is used by
Rem clients such as SQL Tuning Sets and Automatic SQL Tuning.  At present
Rem this table only stores rows for the local DBID, as ref counting is only
Rem allowed on local snapshots.  For this reason it is omitted from extract
Rem and load.
Rem

create table WRI$_SQLTEXT_REFCOUNT
(dbid           number not null
,sql_id         varchar2(13) not null
,ref_count      number not null
,constraint WRI$_SQLTEXT_REFCOUNT_PK primary key (dbid, sql_id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRH$_SQL_SUMMARY
(snap_id              number          not null
,dbid                 number           not null
,instance_number      number           not null
,total_sql            number           not null
,total_sql_mem        number           not null
,single_use_sql       number           not null
,single_use_sql_mem   number           not null
,constraint WRH$_SQL_SUMMARY_PK primary key 
    (dbid, snap_id, instance_number)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

create table WRH$_SQL_PLAN
(snap_id              number               /* last snap id, used for purging */
,dbid                 number          not null
,sql_id               varchar2(13)    not null
,plan_hash_value      number          not null
,id                   number          not null
,operation            varchar2(30)
,options              varchar2(30)
,object_node          varchar2(128)
,object#              number
,object_owner         varchar2(30)
,object_name          varchar2(31)
,object_alias         varchar2(65)
,object_type          varchar2(20)
,optimizer            varchar2(20)
,parent_id            number
,depth                number
,position             number
,search_columns       number
,cost                 number
,cardinality          number
,bytes                number
,other_tag            varchar2(35)
,partition_start      varchar2(64)
,partition_stop       varchar2(64)
,partition_id         number
,other                varchar2(4000)
,distribution         varchar2(20)
,cpu_cost             number
,io_cost              number
,temp_space           number
,access_predicates    varchar2(4000)
,filter_predicates    varchar2(4000)
,projection           varchar2(4000)
,time                 number
,qblock_name          varchar2(31)
,remarks              varchar2(4000)
,timestamp            date
,other_xml            clob
,constraint WRH$_SQL_PLAN_PK primary key
    (dbid, sql_id, plan_hash_value, id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

create table WRH$_SQL_BIND_METADATA
(snap_id          NUMBER                /* last snapshot id used for purging */
,dbid             NUMBER       NOT NULL   
,sql_id           VARCHAR2(13) NOT NULL
,name             VARCHAR2(30)
,position         NUMBER
,dup_position     NUMBER
,datatype         NUMBER
,datatype_string  VARCHAR2(15)
,character_sid    NUMBER
,precision        NUMBER
,scale            NUMBER
,max_length       NUMBER
,constraint WRH$_SQL_BIND_METADATA_PK primary key
    (dbid, sql_id, position)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
  
Rem =========================================================================

create table WRH$_OPTIMIZER_ENV
(snap_id         number                    /* last snap id, used for purging */
,dbid            number       not null
,optimizer_env_hash_value     number       not null
,optimizer_env   raw(2000)
,constraint WRH$_OPTIMIZER_ENV_PK 
            primary key (dbid, optimizer_env_hash_value)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ************************************************************************* 
Rem ====================== Concurrency Statistics ===========================
Rem ************************************************************************* 

Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table          WRH$_SYSTEM_EVENT
(snap_id              number         not null
,dbid                 number         not null
,instance_number      number         not null
,event_id             number         not null
,total_waits          number
,total_timeouts       number
,time_waited_micro    number
,total_waits_fg       number
,total_timeouts_fg    number
,time_waited_micro_fg number
,constraint WRH$_SYSTEM_EVENT_PK primary key 
    (dbid, snap_id, instance_number, event_id) 
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_SYSTEM_EVEN_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_SYSTEM_EVENT_BL;
create table WRH$_SYSTEM_EVENT_BL tablespace SYSAUX 
 as select * from WRH$_SYSTEM_EVENT where rownum < 1
/

alter table  WRH$_SYSTEM_EVENT_BL
 add constraint WRH$_SYSTEM_EVENT_BL_PK primary key 
    (dbid, snap_id, instance_number, event_id) 
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_EVENT_NAME
(dbid                 number         not null
,event_id             number         not null
,event_name           varchar2(64)   not null
,parameter1           varchar2(64)
,parameter2           varchar2(64)
,parameter3           varchar2(64)
,wait_class_id        number
,wait_class           varchar2(64)
,constraint WRH$_EVENT_NAME_PK primary key (dbid, event_id)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_LATCH_NAME
(dbid                 number         not null
,latch_hash           number         not null
,latch_name           varchar2(64)   not null
,latch#               number                 /* for ADDM ('latch free' - P2) */
,constraint WRH$_LATCH_NAME_PK primary key (dbid, latch_hash)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_BG_EVENT_SUMMARY
(snap_id              number         not null
,dbid                 number         not null
,instance_number      number         not null
,event_id             number         not null
,total_waits          number
,total_timeouts       number
,time_waited_micro    number
,constraint WRH$_BG_EVENT_SUMMARY_PK primary key 
    (dbid, snap_id, instance_number, event_id) 
 using index tablespace SYSAUX
) tablespace SYSAUX
pctfree 1
/

Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table          WRH$_WAITSTAT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,class                varchar2(18)
,wait_count           number
,time                 number
,constraint WRH$_WAITSTAT_PK primary key 
    (dbid, snap_id, instance_number, class)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_WAITSTAT_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_WAITSTAT_BL;
create table WRH$_WAITSTAT_BL tablespace SYSAUX 
 as select * from WRH$_WAITSTAT where rownum < 1
/

alter table  WRH$_WAITSTAT_BL
 add constraint WRH$_WAITSTAT_BL_PK primary key 
    (dbid, snap_id, instance_number, class)
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_ENQUEUE_STAT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,eq_type              varchar2(2)      not null
,req_reason           varchar2(64)     not null
,total_req#           number
,total_wait#          number
,succ_req#            number
,failed_req#          number
,cum_wait_time        number 
,event#               number
,constraint WRH$_ENQUEUE_STAT_PK primary key 
    (dbid, snap_id, instance_number, eq_type, req_reason)
 using index tablespace SYSAUX
) tablespace SYSAUX
pctfree 1
/

Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table          WRH$_LATCH
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,latch_hash           number          not null
,level#               number
,gets                 number
,misses               number
,sleeps               number
,immediate_gets       number
,immediate_misses     number
,spin_gets            number
,sleep1               number
,sleep2               number
,sleep3               number
,sleep4               number
,wait_time            number
,constraint WRH$_LATCH_PK primary key 
    (dbid, snap_id, instance_number, latch_hash) 
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_LATCH_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_LATCH_BL;
create table WRH$_LATCH_BL tablespace SYSAUX 
 as select * from WRH$_LATCH where rownum < 1
/

alter table  WRH$_LATCH_BL
 add constraint WRH$_LATCH_BL_PK primary key 
    (dbid, snap_id, instance_number, latch_hash) 
 using index tablespace SYSAUX
/

Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table          WRH$_LATCH_CHILDREN
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,latch_hash           number          not null
,child#               number          not null
,gets                 number
,misses               number
,sleeps               number
,immediate_gets       number
,immediate_misses     number
,spin_gets            number
,sleep1               number
,sleep2               number
,sleep3               number
,sleep4               number
,wait_time            number
,constraint WRH$_LATCH_CHILDREN_PK primary key 
    (dbid, snap_id, instance_number, latch_hash, child#) 
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_LATCH_CHILD_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_LATCH_CHILDREN_BL;
create table WRH$_LATCH_CHILDREN_BL tablespace SYSAUX 
 as select * from WRH$_LATCH_CHILDREN where rownum < 1
/

alter table  WRH$_LATCH_CHILDREN_BL
 add constraint WRH$_LATCH_CHILDREN_BL_PK primary key 
    (dbid, snap_id, instance_number, latch_hash, child#) 
 using index tablespace SYSAUX
/

Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table          WRH$_LATCH_PARENT
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,latch_hash           number          not null
,level#               number          not null
,gets                 number
,misses               number
,sleeps               number
,immediate_gets       number
,immediate_misses     number
,spin_gets            number
,sleep1               number
,sleep2               number
,sleep3               number
,sleep4               number
,wait_time            number
,constraint WRH$_LATCH_PARENT_PK primary key 
    (dbid, snap_id, instance_number, latch_hash) 
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_LATCH_PAREN_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_LATCH_PARENT_BL;
create table WRH$_LATCH_PARENT_BL tablespace SYSAUX 
 as select * from WRH$_LATCH_PARENT where rownum < 1
/

alter table  WRH$_LATCH_PARENT_BL
 add constraint WRH$_LATCH_PARENT_BL_PK primary key 
    (dbid, snap_id, instance_number, latch_hash) 
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_LATCH_MISSES_SUMMARY
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,parent_name          varchar2(50)
,where_in_code        varchar2(64)
,nwfail_count         number
,sleep_count          number
,wtr_slp_count        number
,constraint WRH$_LATCH_MISSES_SUMMARY_PK primary key 
    (dbid, snap_id, instance_number, parent_name, where_in_code)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_LATCH_MISSE_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_LATCH_MISSES_SUMMARY_BL;
create table WRH$_LATCH_MISSES_SUMMARY_BL tablespace SYSAUX 
 as select * from WRH$_LATCH_MISSES_SUMMARY where rownum < 1
/

alter table  WRH$_LATCH_MISSES_SUMMARY_BL
 add constraint WRH$_LATCH_MISSES_SUMRY_BL_PK primary key 
    (dbid, snap_id, instance_number, parent_name, where_in_code)
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_EVENT_HISTOGRAM
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,event_id             number          not null
,wait_time_milli      number          not null
,wait_count           number
,constraint WRH$_EVENT_HISTOGRAM_PK primary key 
    (dbid, snap_id, instance_number, event_id, wait_time_milli) 
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_EVENT_HISTO_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_EVENT_HISTOGRAM_BL;
create table WRH$_EVENT_HISTOGRAM_BL tablespace SYSAUX 
 as select * from WRH$_EVENT_HISTOGRAM where rownum < 1
/

alter table  WRH$_EVENT_HISTOGRAM_BL
 add constraint WRH$_EVENT_HISTOGRAM_BL_PK primary key 
    (dbid, snap_id, instance_number, event_id, wait_time_milli) 
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_MUTEX_SLEEP
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,mutex_type           varchar2(32)     not null
,location             varchar2(40)     not null
,sleeps               number
,wait_time            number
,constraint WRH$_MUTEX_SLEEP_PK primary key 
    (dbid, snap_id, instance_number, mutex_type, location)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

/* Note: There are 44 possible values for (mutex_type, location) and 
 * rows only appear in v$mutex_sleep if a sleep has occurred.  So, it 
 * should be ok to make this table non-partitioned.
 */


Rem ************************************************************************* 
Rem ====================== Instance Statistics ============================== 
Rem ************************************************************************* 
Rem ========================================================================= 

create table            WRH$_LIBRARYCACHE
(snap_id                number          not null
,dbid                   number          not null
,instance_number        number          not null
,namespace              varchar2(15)    not null
,gets                   number
,gethits                number
,pins                   number
,pinhits                number
,reloads                number
,invalidations          number
,dlm_lock_requests      number
,dlm_pin_requests       number
,dlm_pin_releases       number
,dlm_invalidation_requests  number
,dlm_invalidations      number
,constraint WRH$_LIBRARYCACHE_PK primary key 
    (dbid, snap_id, instance_number, namespace)
 using index tablespace SYSAUX
) tablespace SYSAUX
/


Rem ========================================================================= 
Rem %%% %%% %%% Partition %%% %%% %%% 
create table  WRH$_DB_CACHE_ADVICE
(snap_id                number          not null
,dbid                   number          not null
,instance_number        number          not null
,bpid                   number          not null
,buffers_for_estimate   number          not null      
,name                   varchar2(20)
,block_size             number      
,advice_status          varchar2(3) 
,size_for_estimate      number      
,size_factor            number      
,physical_reads         number      
,base_physical_reads    number      
,actual_physical_reads  number      
,estd_physical_read_time number
,constraint WRH$_DB_CACHE_ADVICE_PK primary key 
     (dbid, snap_id, instance_number, bpid, buffers_for_estimate)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_DB_CACHE_AD_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/


Rem ========================================================================= 
Rem %%% %%% %%% Partition %%% %%% %%% 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_DB_CACHE_ADVICE_BL;
create table WRH$_DB_CACHE_ADVICE_BL tablespace SYSAUX 
 as select * from WRH$_DB_CACHE_ADVICE where rownum < 1
/

alter table  WRH$_DB_CACHE_ADVICE_BL
 add constraint WRH$_DB_CACHE_ADVICE_BL_PK primary key 
     (dbid, snap_id, instance_number, bpid, buffers_for_estimate)
 using index tablespace SYSAUX
/


Rem ========================================================================= 

create table             WRH$_BUFFER_POOL_STATISTICS
(snap_id                 number           not null
,dbid                    number           not null
,instance_number         number           not null
,id                      number           not null
,name                    varchar2(20)
,block_size              number
,set_msize               number
,cnum_repl               number
,cnum_write              number
,cnum_set                number
,buf_got                 number
,sum_write               number
,sum_scan                number
,free_buffer_wait        number
,write_complete_wait     number
,buffer_busy_wait        number
,free_buffer_inspected   number
,dirty_buffers_inspected number
,db_block_change         number
,db_block_gets           number
,consistent_gets         number
,physical_reads          number
,physical_writes         number       
,constraint WRH$_BUFFER_POOL_STATS_PK primary key
    (dbid, snap_id, instance_number, id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table          WRH$_ROWCACHE_SUMMARY
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,parameter            varchar2 (32)
,total_usage          number
,usage                number
,gets                 number
,getmisses            number
,scans                number
,scanmisses           number
,scancompletes        number
,modifications        number
,flushes              number
,dlm_requests         number
,dlm_conflicts        number
,dlm_releases         number
,constraint WRH$_ROWCACHE_SUMMARY_PK primary key 
    (dbid, snap_id, instance_number, parameter) 
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_ROWCACHE_SU_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_ROWCACHE_SUMMARY_BL;
create table WRH$_ROWCACHE_SUMMARY_BL tablespace SYSAUX 
 as select * from WRH$_ROWCACHE_SUMMARY where rownum < 1
/

alter table  WRH$_ROWCACHE_SUMMARY_BL
 add constraint WRH$_ROWCACHE_SUMMARY_BL_PK primary key 
    (dbid, snap_id, instance_number, parameter) 
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_SGA
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,name                 varchar2(64)     not null
,value                number           not null
,constraint WRH$_SGA_PK primary key 
    (dbid, snap_id, instance_number, name)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table          WRH$_SGASTAT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,name                 varchar2(64)
,pool                 varchar2(12)
,bytes                number
,constraint WRH$_SGASTAT_U unique    
    (dbid, snap_id, instance_number, name, pool)
  using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_SGASTAT_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_SGASTAT_BL;
create table WRH$_SGASTAT_BL tablespace SYSAUX 
 as select * from WRH$_SGASTAT where rownum < 1
/

alter table  WRH$_SGASTAT_BL
 add constraint WRH$_SGASTAT_BL_U unique    
    (dbid, snap_id, instance_number, name, pool)
  using index tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_PGASTAT
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,name                 varchar2(64)    not null
,value                number
,constraint WRH$_PGASTAT_PK primary key
    (dbid, snap_id, instance_number, name)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_PROCESS_MEMORY_SUMMARY
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,category             varchar2(15)
,num_processes        number
,non_zero_allocs      number
,used_total           number
,allocated_total      number
,allocated_stddev     number
,allocated_max        number
,max_allocated_max    number
,constraint WRH$_PROCESS_MEM_SUMMARY_PK primary key
    (dbid, snap_id, instance_number, category)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_RESOURCE_LIMIT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,resource_name        varchar2(30)     not null
,current_utilization  number
,max_utilization      number
,initial_allocation   varchar2(10)
,limit_value          varchar2(10)
,constraint WRH$_RESOURCE_LIMIT_PK primary key
    (dbid, snap_id, instance_number, resource_name)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

create table WRH$_SHARED_POOL_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,shared_pool_size_for_estimate  number     not null
,shared_pool_size_factor        number
,estd_lc_size                   number
,estd_lc_memory_objects         number
,estd_lc_time_saved             number
,estd_lc_time_saved_factor      number
,estd_lc_load_time              number
,estd_lc_load_time_factor       number
,estd_lc_memory_object_hits     number
,constraint WRH$_SHARED_POOL_ADVICE_PK primary key 
     (dbid, snap_id, instance_number, shared_pool_size_for_estimate)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

create table WRH$_STREAMS_POOL_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,size_for_estimate              number     not null
,size_factor                    number
,estd_spill_count               number
,estd_spill_time                number
,estd_unspill_count             number
,estd_unspill_time              number
,constraint WRH$_STREAMS_POOL_ADVICE_PK primary key 
     (dbid, snap_id, instance_number, size_for_estimate)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 


create table WRH$_SQL_WORKAREA_HISTOGRAM
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,low_optimal_size               number     not null
,high_optimal_size              number     not null
,optimal_executions             number
,onepass_executions             number
,multipasses_executions         number
,total_executions               number
,constraint WRH$_SQL_WORKAREA_HIST_PK primary key 
     (dbid, snap_id, instance_number, low_optimal_size, high_optimal_size)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_PGA_TARGET_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,pga_target_for_estimate        number     not null
,pga_target_factor              number
,advice_status                  varchar2(3)
,bytes_processed                number
,estd_extra_bytes_rw            number
,estd_pga_cache_hit_percentage  number
,estd_overalloc_count           number
,estd_time                      number
,constraint WRH$_PGA_TARGET_ADVICE_PK primary key 
     (dbid, snap_id, instance_number, pga_target_for_estimate)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 
Rem
Rem Like all advice tables, we have multiple rows per snapshot,
Rem simulating the impact (estd_db_time) and number of physical read operations
Rem (estd_physical_reads) for sga_size. The rwo with sga_size_factor=1
Rem has the current sga_size and the non-simulated reads and db-time.  
Rem 

create table WRH$_SGA_TARGET_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,sga_size                       number     not null
,sga_size_factor                number     not null
,estd_db_time                   number     not null
,estd_physical_reads            number
,constraint WRH$_SGA_TARGET_ADVICE_PK primary key 
     (dbid, snap_id, instance_number, sga_size)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_MEMORY_TARGET_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,memory_size                    number     not null
,memory_size_factor             number
,estd_db_time                   number
,estd_db_time_factor            number
,version                        number
,constraint WRH$_MEMORY_TARGET_ADVICE_PK primary key 
     (dbid, snap_id, instance_number, memory_size)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_MEMORY_RESIZE_OPS
(snap_id                        number        not null
,dbid                           number        not null
,instance_number                number        not null
,component                      varchar2(64)  not null
,oper_type                      varchar2(13)  not null
,start_time                     date          not null
,end_time                       date          not null
,target_size                    number        not null
,oper_mode                      varchar2(9)
,parameter                      varchar2(80)
,initial_size                   number
,final_size                     number
,status                         varchar2(9)
,constraint WRH$_MEMORY_RESIZE_OPS_PK primary key 
     (dbid, snap_id, instance_number, 
      component, oper_type, start_time, target_size)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 


create table          WRH$_INSTANCE_RECOVERY
(snap_id                          number           not null
,dbid                             number           not null
,instance_number                  number           not null
,recovery_estimated_ios           number
,actual_redo_blks                 number
,target_redo_blks                 number
,log_file_size_redo_blks          number
,log_chkpt_timeout_redo_blks      number
,log_chkpt_interval_redo_blks     number
,fast_start_io_target_redo_blks   number
,target_mttr                      number
,estimated_mttr                   number
,ckpt_block_writes                number
,optimal_logfile_size             number
,estd_cluster_available_time      number
,writes_mttr                      number
,writes_logfile_size              number
,writes_log_checkpoint_settings   number
,writes_other_settings            number
,writes_autotune                  number
,writes_full_thread_ckpt          number
,constraint WRH$_INSTANCE_RECOVERY_PK primary key 
    (dbid, snap_id, instance_number)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

create table WRH$_JAVA_POOL_ADVICE
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,java_pool_size_for_estimate    number     not null
,java_pool_size_factor          number
,estd_lc_size                   number
,estd_lc_memory_objects         number
,estd_lc_time_saved             number
,estd_lc_time_saved_factor      number
,estd_lc_load_time              number
,estd_lc_load_time_factor       number
,estd_lc_memory_object_hits     number
,constraint WRH$_JAVA_POOL_ADVICE_PK primary key
     (dbid, snap_id, instance_number, java_pool_size_for_estimate)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem =========================================================================  

create table WRH$_THREAD
(snap_id                        number     not null
,dbid                           number     not null
,instance_number                number     not null
,thread#                        number     not null
,thread_instance_number         number
,status                         varchar2(6)
,open_time                      date
,current_group#                 number
,sequence#                      number
,constraint WRH$_THREAD_PK primary key
     (dbid, snap_id, instance_number, thread#)
 using index tablespace SYSAUX
) tablespace SYSAUX
/


Rem ************************************************************************* 
Rem ===================== General System Statistics ========================= 
Rem ************************************************************************* 

Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table          WRH$_SYSSTAT
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,stat_id              number          not null
,value                number
,constraint WRH$_SYSSTAT_PK primary key 
    (dbid, snap_id, instance_number, stat_id) 
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_SYSSTAT_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem %%% %%% %%% Baseline Table for WRH$_SYSSTAT %%% %%% %%% 
Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_SYSSTAT_BL;
create table WRH$_SYSSTAT_BL tablespace SYSAUX 
 as select * from WRH$_SYSSTAT where rownum < 1
/

alter table  WRH$_SYSSTAT_BL
 add constraint WRH$_SYSSTAT_BL_PK primary key 
    (dbid, snap_id, instance_number, stat_id) 
 using index tablespace SYSAUX
/


Rem =========================================================================
Rem            Time model statistics
Rem =========================================================================

Rem %%% %%% %%% Partition %%% %%% %%%
create table          WRH$_SYS_TIME_MODEL
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,stat_id              number          not null
,value                number
,constraint WRH$_SYS_TIME_MODEL_PK primary key
    (dbid, snap_id, instance_number, stat_id)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_SYS_TIME_MO_MXDB_MXSN values less than (MAXVALUE, MAXVALUE)
    tablespace SYSAUX)
enable row movement
/

Rem =========================================================================

Rem %%% %%% %%% Baseline Table for WRH$_SYS_TIME_MODEL %%% %%%
Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_SYS_TIME_MODEL_BL;
create table WRH$_SYS_TIME_MODEL_BL tablespace SYSAUX 
 as select * from WRH$_SYS_TIME_MODEL where rownum < 1
/

alter table  WRH$_SYS_TIME_MODEL_BL
 add constraint WRH$_SYS_TIME_MODEL_BL_PK primary key
    (dbid, snap_id, instance_number, stat_id)
 using index tablespace SYSAUX
/

Rem =========================================================================
Rem                 OS statistics
Rem =========================================================================

Rem %%% %%% %%% Partition %%% %%% %%%
create table          WRH$_OSSTAT
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,stat_id              number          not null
,value                number
,constraint WRH$_OSSTAT_PK primary key
    (dbid, snap_id, instance_number, stat_id)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_OSSTAT_MXDB_MXSN values less than (MAXVALUE, MAXVALUE)
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem =========================================================================

Rem %%% %%% %%% Baseline Table for WRH$_OSSTAT %%% %%%
Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_OSSTAT_BL;
create table WRH$_OSSTAT_BL tablespace SYSAUX 
 as select * from WRH$_OSSTAT where rownum < 1
/

alter table  WRH$_OSSTAT_BL
 add constraint WRH$_OSSTAT_BL_PK primary key
    (dbid, snap_id, instance_number, stat_id)
 using index tablespace SYSAUX
/

Rem =========================================================================

Rem %%% %%% %%% Partition %%% %%% %%%
create table          WRH$_PARAMETER
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,parameter_hash       number           not null
,value                varchar2(512)
,isdefault            varchar2(9)
,ismodified           varchar2(10)
,constraint WRH$_PARAMETER_PK primary key 
    (dbid, snap_id, instance_number, parameter_hash)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_PARAMETER_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem =========================================================================

create table          WRH$_MVPARAMETER
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,parameter_hash       number           not null
,ordinal              number           not null
,value                varchar2(512)
,isdefault            varchar2(9)
,ismodified           varchar2(10)
,constraint WRH$_MVPARAMETER_PK primary key 
    (dbid, snap_id, instance_number, parameter_hash, ordinal)
 using index local tablespace SYSAUX 
) partition by range (dbid, snap_id)
  (partition WRH$_MVPARAMETER_MXDB_MXSN values less than (MAXVALUE, MAXVALUE)
   tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_PARAMETER_BL;
create table WRH$_PARAMETER_BL tablespace SYSAUX 
 as select * from WRH$_PARAMETER where rownum < 1
/

alter table  WRH$_PARAMETER_BL
 add constraint WRH$_PARAMETER_BL_PK primary key 
    (dbid, snap_id, instance_number, parameter_hash)
 using index tablespace SYSAUX
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_MVPARAMETER_BL;
create table WRH$_MVPARAMETER_BL tablespace SYSAUX 
 as select * from WRH$_MVPARAMETER where rownum < 1
/

alter table  WRH$_MVPARAMETER_BL
 add constraint WRH$_MVPARAMETER_BL_PK primary key 
    (dbid, snap_id, instance_number, parameter_hash, ordinal)
 using index tablespace SYSAUX
/

Rem =========================================================================

create table          WRH$_STAT_NAME
(dbid                 number         not null
,stat_id              number         not null
,stat_name            varchar2(64)   not null
,constraint WRH$_STAT_NAME_PK primary key (dbid, stat_id)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRH$_OSSTAT_NAME
(dbid                 number         not null
,stat_id              number         not null
,stat_name            varchar2(64)   not null
,constraint WRH$_OSSTAT_NAME_PK primary key (dbid, stat_id)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRH$_PARAMETER_NAME
(dbid                 number         not null
,parameter_hash       number         not null
,parameter_name       varchar2(64)   not null
,constraint WRH$_PARAMETER_NAME_PK primary key (dbid, parameter_hash)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRH$_PLAN_OPERATION_NAME
(dbid                 number         not null
,operation_id         number         not null
,operation_name       varchar2(64)
,constraint WRH$_PLAN_OPERATION_NAME_PK primary key (dbid, operation_id)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRH$_PLAN_OPTION_NAME
(dbid                 number         not null
,option_id            number         not null
,option_name          varchar2(64)
,constraint WRH$_PLAN_OPTION_NAME_PK primary key (dbid, option_id)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================

create table          WRH$_SQLCOMMAND_NAME
(dbid                 number        not null
,command_type         number        not null
,command_name         varchar2(64)
,constraint WRH$_SQLCOMMAND_NAME_PK primary key (dbid, command_type)
     using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================

create table          WRH$_TOPLEVELCALL_NAME
(dbid                 number       not null
,top_level_call#      number       not null
,top_level_call_name  varchar2(64)
,constraint WRH$_TOPLEVELCALL_NAME_PK primary key (dbid, top_level_call#)
     using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem *************************************************************************
Rem ========================= Undo Statistics ===============================
Rem ************************************************************************* 

Rem ========================================================================= 

create table WRH$_UNDOSTAT
(begin_time           date            not null
,end_time             date            not null
,dbid                 number          not null
,instance_number      number          not null
,snap_id              number          not null
,undotsn              number          not null
,undoblks             number
,txncount             number
,maxquerylen          number
,maxquerysqlid        varchar2(13)
,maxconcurrency       number
,unxpstealcnt         number
,unxpblkrelcnt        number
,unxpblkreucnt        number
,expstealcnt          number
,expblkrelcnt         number
,expblkreucnt         number
,ssolderrcnt          number
,nospaceerrcnt        number
,activeblks           number
,unexpiredblks        number
,expiredblks          number
,tuned_undoretention  number
,status               number
,spcprs_retention     number
,runawayquerysqlid    varchar2(13)
,constraint WRH$_UNDOSTAT_PK primary key
    (begin_time, end_time, dbid, instance_number)
 using index tablespace SYSAUX
) tablespace SYSAUX
/
Rem ========================================================================= 

Rem ************************************************************************* 
Rem ======================= Segment Statistics ============================== 
Rem ************************************************************************* 

Rem ========================================================================= 

Rem %%% %%% %%% Partition %%% %%% %%% 
create table WRH$_SEG_STAT
(snap_id                         number      not null
,dbid                            number      not null
,instance_number                 number      not null
,ts#                             number
,obj#                            number      not null
,dataobj#                        number
,logical_reads_total                   number
,logical_reads_delta                   number
,buffer_busy_waits_total               number
,buffer_busy_waits_delta               number
,db_block_changes_total                number
,db_block_changes_delta                number
,physical_reads_total                  number
,physical_reads_delta                  number
,physical_writes_total                 number
,physical_writes_delta                 number
,physical_reads_direct_total           number
,physical_reads_direct_delta           number
,physical_writes_direct_total          number
,physical_writes_direct_delta          number
,itl_waits_total                       number
,itl_waits_delta                       number
,row_lock_waits_total                  number
,row_lock_waits_delta                  number
,gc_buffer_busy_total                  number
,gc_buffer_busy_delta                  number
,gc_cr_blocks_received_total           number
,gc_cr_blocks_received_delta           number
,gc_cu_blocks_received_total           number
,gc_cu_blocks_received_delta           number
,space_used_total                      number 
,space_used_delta                      number 
,space_allocated_total                 number 
,space_allocated_delta                 number 
,table_scans_total                     number 
,table_scans_delta                     number 
,chain_row_excess_total                number 
,chain_row_excess_delta                number 
,physical_read_requests_total          number
,physical_read_requests_delta          number
,physical_write_requests_total         number
,physical_write_requests_delta         number
,optimized_physical_reads_total        number
,optimized_physical_reads_delta        number
,constraint WRH$_SEG_STAT_PK primary key
   (dbid, snap_id, instance_number, ts#, obj#, dataobj#)
  using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_SEG_STAT_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/


Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_SEG_STAT_BL;
create table WRH$_SEG_STAT_BL tablespace SYSAUX 
 as select * from WRH$_SEG_STAT where rownum < 1
/

alter table  WRH$_SEG_STAT_BL
 add constraint WRH$_SEG_STAT_BL_PK primary key
   (dbid, snap_id, instance_number, ts#, obj#, dataobj#)
  using index tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_SEG_STAT_OBJ
(snap_id              number               /* last snap id, used for purging */
,dbid                 number      not null
,ts#                  number
,obj#                 number      not null
,dataobj#             number
,owner                varchar(30) not null
,object_name          varchar(30) not null
,subobject_name       varchar(30)
,partition_type       varchar(8)
,object_type          varchar2(18)
,tablespace_name      varchar(30) not null
,index_type           varchar2(27)
,base_obj#            number
,base_object_name     varchar2(30)
,base_object_owner    varchar2(30)
,constraint WRH$_SEG_STAT_OBJ_PK primary key
  (dbid, ts#, obj#, dataobj#)
  using index tablespace SYSAUX
) tablespace SYSAUX
/

create index WRH$_SEG_STAT_OBJ_INDEX on WRH$_SEG_STAT_OBJ(dbid, snap_id)
  tablespace SYSAUX
/

Rem ************************************************************************* 
Rem ====================== Metrics Tables =================================== 
Rem ************************************************************************* 
Rem ========================================================================= 

create table          WRH$_METRIC_NAME
(dbid                 number         not null
,group_id             number         not null
,group_name           varchar2(64)
,metric_id            number         not null
,metric_name          varchar2(64)   not null
,metric_unit          varchar2(64)   not null
,constraint WRH$_METRIC_NAME_PK 
            primary key (dbid, group_id, metric_id)
    using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table            WRH$_SYSMETRIC_HISTORY
(snap_id                number          not null
,dbid                   number          not null
,instance_number        number          not null
,begin_time             DATE            not null
,end_time               DATE            not null
,intsize                number          not null
,group_id               number          not null
,metric_id              number          not null
,value                  number          not null
) tablespace SYSAUX
pctfree 1
/

Rem -- Constraints on metrics tables are disabled for now
Rem ,constraint WRH$_SYSMETRIC_HISTORY_PK primary key
Rem   (dbid, snap_id, instance_number, group_id, metric_id, begin_time)
Rem  using index tablespace SYSAUX

Rem -- Remove index when constraint is enabled
create index WRH$_SYSMETRIC_HISTORY_INDEX 
 on WRH$_SYSMETRIC_HISTORY
 (dbid, snap_id, instance_number, group_id, metric_id, begin_time)
tablespace SYSAUX
/


Rem ========================================================================= 

create table            WRH$_SYSMETRIC_SUMMARY
(snap_id                number          not null
,dbid                   number          not null
,instance_number        number          not null
,begin_time             DATE            not null
,end_time               DATE            not null
,intsize                number          not null
,group_id               number          not null
,metric_id              number          not null
,num_interval           number          not null
,maxval                 number          not null
,minval                 number          not null
,average                number          not null
,standard_deviation     number          not null
,sum_squares            number
) tablespace SYSAUX
pctfree 1
/

Rem -- Constraints on metrics tables are disabled for now
Rem ,constraint WRH$_SYSMETRIC_SUMMARY_PK primary key
Rem   (dbid, snap_id, instance_number, group_id, metric_id)
Rem  using index tablespace SYSAUX

Rem -- Remove index when constraint is enabled
create index WRH$_SYSMETRIC_SUMMARY_INDEX 
 on WRH$_SYSMETRIC_SUMMARY
 (dbid, snap_id, instance_number, group_id, metric_id)
tablespace SYSAUX
/


Rem ========================================================================= 

create table            WRH$_SESSMETRIC_HISTORY
(snap_id                number          not null
,dbid                   number          not null
,instance_number        number          not null
,begin_time             DATE            not null
,end_time               DATE            not null
,sessid                 number          not null
,serial#                number          not null
,intsize                number          not null
,group_id               number          not null
,metric_id              number          not null
,value                  number          not null
) tablespace SYSAUX
/

Rem -- Constraints on metrics tables are disabled for now
Rem ,constraint WRH$_SESSMETRIC_HISTORY_PK primary key
Rem   (dbid, snap_id, instance_number, group_id, sessid, metric_id, begin_time)
Rem  using index tablespace SYSAUX

Rem -- Remove index when constraint is enabled
create index WRH$_SESSMETRIC_HISTORY_INDEX 
 on WRH$_SESSMETRIC_HISTORY
 (dbid, snap_id, instance_number, group_id, sessid, metric_id, begin_time)
tablespace SYSAUX
/


Rem ========================================================================= 

create table            WRH$_FILEMETRIC_HISTORY
(snap_id                number          not null
,dbid                   number          not null
,instance_number        number          not null
,fileid                 number          not null
,creationtime           number          not null
,begin_time             DATE            not null
,end_time               DATE            not null
,intsize                number          not null
,group_id               number          not null
,avgreadtime            number          not null
,avgwritetime           number          not null
,physicalread           number          not null
,physicalwrite          number          not null
,phyblkread             number          not null
,phyblkwrite            number          not null
) tablespace SYSAUX
/

Rem -- Constraints on metrics tables are disabled for now
Rem ,constraint WRH$_FILEMETRIC_HISTORY_PK primary key
Rem   (dbid, snap_id, instance_number, group_id, fileid, begin_time)
Rem  using index tablespace SYSAUX

Rem -- Remove index when constraint is enabled
create index WRH$_FILEMETRIC_HISTORY_INDEX 
 on WRH$_FILEMETRIC_HISTORY
 (dbid, snap_id, instance_number, group_id, fileid, begin_time)
tablespace SYSAUX
/


Rem ========================================================================= 

create table            WRH$_WAITCLASSMETRIC_HISTORY
(snap_id                number          not null
,dbid                   number          not null
,instance_number        number          not null
,wait_class_id          number          not null
,begin_time             DATE            not null
,end_time               DATE            not null
,intsize                number          not null
,group_id               number          not null
,average_waiter_count   number          not null
,dbtime_in_wait         number          not null
,time_waited            number          not null
,wait_count             number          not null
,time_waited_fg         number
,wait_count_fg          number
) tablespace SYSAUX
/

Rem -- Constraints on metrics tables are disabled for now
Rem ,constraint WRH$_WAITCLASSMETRIC_HIST_PK primary key
Rem   (dbid, snap_id, instance_number, group_id, wait_class_id, begin_time)
Rem  using index tablespace SYSAUX

Rem -- Remove index when constraint is enabled
create index WRH$_WAITCLASSMETRIC_HIST_IND 
 on WRH$_WAITCLASSMETRIC_HISTORY
 (dbid, snap_id, instance_number, group_id, wait_class_id, begin_time)
tablespace SYSAUX
/


Rem ************************************************************************* 
Rem ========================== RAC Statistics =============================== 
Rem ************************************************************************* 

Rem ========================================================================= 

create table WRH$_DLM_MISC
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,statistic#           number          not null
,name                 varchar2(38)
,value                number
,constraint WRH$_DLM_MISC_PK primary key
    (dbid, snap_id, instance_number, statistic#)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_DLM_MISC_MXDB_MXSN values less than (MAXVALUE, MAXVALUE)
    tablespace SYSAUX)
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_DLM_MISC_BL;
create table WRH$_DLM_MISC_BL tablespace SYSAUX 
 as select * from WRH$_DLM_MISC where rownum < 1
/

alter table  WRH$_DLM_MISC_BL
 add constraint WRH$_DLM_MISC_BL_PK primary key
    (dbid, snap_id, instance_number, statistic#)
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_CR_BLOCK_SERVER
(snap_id                   number          not null
,dbid                      number          not null
,instance_number           number          not null
,cr_requests               number
,current_requests          number
,data_requests             number
,undo_requests             number
,tx_requests               number
,current_results           number
,private_results           number
,zero_results              number
,disk_read_results         number
,fail_results              number
,fairness_down_converts    number
,fairness_clears           number
,free_gc_elements          number
,flushes                   number
,flushes_queued            number
,flush_queue_full          number
,flush_max_time            number
,light_works               number
,errors                    number
,constraint WRH$_CR_BLOCK_SERVER_PK primary key
    (dbid, snap_id, instance_number)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_CURRENT_BLOCK_SERVER
(snap_id              number          not null
,dbid                 number          not null
,instance_number      number          not null
,pin1                 number
,pin10                number
,pin100               number
,pin1000              number
,pin10000             number
,flush1               number
,flush10              number
,flush100             number
,flush1000            number
,flush10000           number
,write1               number
,write10              number
,write100             number
,write1000            number
,write10000           number
,constraint WRH$_CURRENT_BLOCK_SERVER_PK primary key
    (dbid, snap_id, instance_number)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table WRH$_INST_CACHE_TRANSFER
(snap_id                  number          not null
,dbid                     number          not null
,instance_number          number          not null
,instance                 number          not null
,class                    varchar2(18)    not null
,cr_block                 number
,cr_busy                  number
,cr_congested             number
,current_block            number
,current_busy             number
,current_congested        number
,lost                     number
,cr_2hop                  number
,cr_3hop                  number
,current_2hop             number
,current_3hop             number
,cr_block_time            number
,cr_busy_time             number
,cr_congested_time        number
,current_block_time       number
,current_busy_time        number
,current_congested_time   number
,lost_time                number
,cr_2hop_time             number
,cr_3hop_time             number
,current_2hop_time        number
,current_3hop_time        number
,constraint WRH$_INST_CACHE_TRANSFER_PK primary key
    (dbid, snap_id, instance_number, instance, class)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_INST_CACHE_MXDB_MXSN values less than (MAXVALUE, MAXVALUE)
    tablespace SYSAUX)
enable row movement
/

Rem =========================================================================

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_INST_CACHE_TRANSFER_BL;
create table WRH$_INST_CACHE_TRANSFER_BL tablespace SYSAUX 
 as select * from WRH$_INST_CACHE_TRANSFER where rownum < 1
/

alter table  WRH$_INST_CACHE_TRANSFER_BL
 add constraint WRH$_INST_CACHE_TRANSFER_BL_PK primary key
    (dbid, snap_id, instance_number, instance, class)
 using index tablespace SYSAUX
/

Rem *************************************************************************
Rem                 Active Session History WR Tables
Rem *************************************************************************

Rem %%% %%% %%% Table Partitioned on snap_id %%% %%% %%%
create table WRH$_ACTIVE_SESSION_HISTORY
(
 /* AWR/ASH meta attributes */
 snap_id                    number          not null
,dbid                       number          not null
,instance_number            number          not null
,sample_id                  number          not null
,sample_time                timestamp(3)    not null
 /* Session/User attributes */
,session_id                 number          not null
,session_serial#            number
,user_id                    number
 /* SQL attributes */
,sql_id                     varchar2(13)
,sql_child_number           number
 /* SQL Plan/Execution attributes */
,sql_plan_hash_value        number
 /* Application attributes */
,service_hash               number
 /* Session/User attributes */
,session_type               number
 /* SQL attributes */
,sql_opcode                 number
 /* PQ attributes */
,qc_session_id              number
,qc_instance_id             number
 /* Session's working context */
,current_obj#               number
,current_file#              number
,current_block#             number
 /* Wait event attributes */
,seq#                       number
,event_id                   number
,p1                         number
,p2                         number
,p3                         number
,wait_time                  number
,time_waited                number
 /* Application attributes */
,program                    varchar2(64)
,module                     varchar2(64)
,action                     varchar2(64)
,client_id                  varchar2(64)
 /* SQL attributes */
,force_matching_signature   number
 /* Wait event attributes */
,blocking_session           number
,blocking_session_serial#   number
 /* Session's working context */
,xid                        raw(8)
 /* Session's working context (introduced 11g)*/
,consumer_group_id          number
 /* PL/SQL attributes (introduced 11g) */
,plsql_entry_object_id      number
,plsql_entry_subprogram_id  number
,plsql_object_id            number
,plsql_subprogram_id        number
 /* PQ attributes (introduced 11g) */
,qc_session_serial#         number
 /* Session's working context (introduced 11g)*/
,remote_instance#           number
 /* SQL Plan/Execution attributes (introduced 11g) */
,sql_plan_line_id           number
,sql_plan_operation#        number
,sql_plan_options#          number
,sql_exec_id                number
,sql_exec_start             date
 /* Session's working context (introduced 11g)*/
,time_model                 number
 /* SQL attributes (introduced 11g) */
,top_level_sql_id           varchar2(13)
,top_level_sql_opcode       number
 /* Session's working context (introduced 11g)*/
,current_row#               number
 /* Session/User attributes (introduced 11g) */
,flags                      number
,blocking_inst_id           number
,ecid                       varchar2(64)
/* stash columns (introduced in 11.2) */
,tm_delta_time               number
,tm_delta_cpu_time           number
,tm_delta_db_time            number
,delta_time                  number
,delta_read_io_requests      number
,delta_write_io_requests     number
,delta_read_io_bytes         number
,delta_write_io_bytes        number
,delta_interconnect_io_bytes number
,pga_allocated               number
,temp_space_allocated        number
/* Session's working context top level call number (introduced 11.2) */
,top_level_call#            number
/* Session/User attributes (introduced 11.2)*/
,machine                   varchar2(64)
,port                      number
/* DB Replay info introduced 11.2.0.2 */
,dbreplay_file_id            number
,dbreplay_call_counter       number
/* PX flags introduced 11.2.0.2 */
,px_flags                    number
,constraint WRH$_ACTIVE_SESSION_HISTORY_PK primary key
    (dbid, snap_id, instance_number, sample_id, session_id )
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_ACTIVE_SES_MXDB_MXSN values less than (MAXVALUE, MAXVALUE)
    tablespace SYSAUX)
pctfree 1
enable row movement
/


Rem
Rem %%% %%% %%% ASH Baseline Table %%% %%% %%%
Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_ACTIVE_SESSION_HISTORY_BL;
create table WRH$_ACTIVE_SESSION_HISTORY_BL tablespace SYSAUX as
  select * from WRH$_ACTIVE_SESSION_HISTORY where rownum < 1
/

alter table WRH$_ACTIVE_SESSION_HISTORY_BL
 add constraint WRH$_ASH_BL_PK primary key
    (dbid, snap_id, instance_number, sample_id, session_id )
 using index tablespace SYSAUX
/


Rem ************************************************************************* 
Rem ========================== Tablespace Statistics ======================== 
Rem ************************************************************************* 

Rem ========================================================================= 

create table WRH$_TABLESPACE_STAT
(snap_id                     number          not null
,dbid                        number          not null
,instance_number             number          not null
,ts#                         number          not null
,tsname                      varchar2(30)
,contents                    varchar2(9) 
,status                      varchar2(9) 
,segment_space_management    varchar2(6) 
,extent_management           varchar2(10)
,is_backup                   varchar2(5) 
,constraint WRH$_TABLESPACE_STAT_PK primary key 
     (dbid, snap_id, instance_number, ts#)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_TABLESPACE_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
enable row movement
/


Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_TABLESPACE_STAT_BL;
create table WRH$_TABLESPACE_STAT_BL tablespace SYSAUX 
 as select * from WRH$_TABLESPACE_STAT where rownum < 1
/

alter table  WRH$_TABLESPACE_STAT_BL
 add constraint WRH$_TABLESPACE_STAT_BL_PK primary key 
     (dbid, snap_id, instance_number, ts#)
 using index tablespace SYSAUX
/


Rem ************************************************************************* 
Rem ========================== WRH$_LOG Statistics ======================== 
Rem ************************************************************************* 

Rem ========================================================================= 

create table WRH$_LOG
(snap_id                     number      not null
,dbid                        number      not null
,instance_number             number      not null
,group#                      number      not null
,thread#                     number      not null
,sequence#                   number      not null
,bytes                       number
,members                     number
,archived                    varchar2(3)
,status                      varchar2(16)
,first_change#               number
,first_time                  date
,constraint WRH$_LOG_PK primary key
     (dbid, snap_id, instance_number, group#, thread#, sequence#)
 using index tablespace SYSAUX
) tablespace SYSAUX
/


Rem ************************************************************************* 
Rem ========================== MTTR Target Advice =========================== 
Rem ************************************************************************* 

Rem ========================================================================= 

create table WRH$_MTTR_TARGET_ADVICE
(snap_id                     number      not null
,dbid                        number      not null
,instance_number             number      not null
,mttr_target_for_estimate    number      
,advice_status               varchar(5)  
,dirty_limit                 number      
,estd_cache_writes           number      
,estd_cache_write_factor     number      
,estd_total_writes           number
,estd_total_write_factor     number
,estd_total_ios              number
,estd_total_io_factor        number
) tablespace SYSAUX
/

Rem *** Does this need a uniqueness constraint??
Rem ,constraint WRH$_MTTR_TARGET_ADVICE_PK primary key 
Rem    (dbid, snap_id, instance_number, ...)
Rem   using index tablespace SYSAUX


Rem =========================================================================

Rem *************************************************************************
Rem                 Tablespace Space Usage History WR Tables
Rem *************************************************************************
Rem ========================================================================= 

create table WRH$_TABLESPACE
(snap_id                     number        /* last snap id, used for purging */
,dbid                        number         not null
,ts#                         number         not null
,tsname                      varchar2(30)   not null
,contents                    varchar2(30) 
,segment_space_management    varchar2(30) 
,extent_management           varchar2(30)
,constraint WRH$_TABLESPACE_PK primary key
     (dbid, ts#)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem %%% %%% %%% Tablespace Space Usage History %%% %%% %%%
create table WRH$_TABLESPACE_SPACE_USAGE
(dbid                 number          not null
,snap_id              number 
,tablespace_id        number  
,tablespace_size      number 
,tablespace_maxsize   number
,tablespace_usedsize  number
,rtime                varchar2(25)
) tablespace SYSAUX
/

Rem ========================================================
Rem create an index on the WRH$_TABLESPACE_SPACE_USAGE table
Rem ========================================================

create index WRH$_TS_SPACE_USAGE_IND on
WRH$_TABLESPACE_SPACE_USAGE(dbid, snap_id, tablespace_id) 
tablespace SYSAUX
/


Rem *************************************************************************
Rem                      Service Statistics
Rem *************************************************************************

create table          WRH$_SERVICE_NAME
(snap_id              number               /* last snap id, used for purging */
,dbid                 number         not null
,service_name_hash    number         not null
,service_name         varchar2(64)   not null
,constraint WRH$_SERVICE_NAME_PK primary key 
    (dbid, service_name_hash)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_SERVICE_STAT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,service_name_hash    number
,stat_id              number
,value                number
,constraint WRH$_SERVICE_STAT_PK primary key 
    (dbid, snap_id, instance_number, service_name_hash, stat_id)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_SERVICE_STAT_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_SERVICE_STAT_BL;
create table WRH$_SERVICE_STAT_BL tablespace SYSAUX 
 as select * from WRH$_SERVICE_STAT where rownum < 1
/

alter table  WRH$_SERVICE_STAT_BL
 add constraint WRH$_SERVICE_STAT_BL_PK primary key 
    (dbid, snap_id, instance_number, service_name_hash, stat_id)
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_SERVICE_WAIT_CLASS
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,service_name_hash    number           not null
,wait_class_id        number           not null
,wait_class           varchar2(64)
,total_waits          number
,time_waited          number
,constraint WRH$_SERVICE_WAIT_CLASS_PK primary key 
    (dbid, snap_id, instance_number, service_name_hash, wait_class_id)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_SERVICE_WAIT_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

Rem ========================================================================= 

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_SERVICE_WAIT_CLASS_BL;
create table WRH$_SERVICE_WAIT_CLASS_BL tablespace SYSAUX 
 as select * from WRH$_SERVICE_WAIT_CLASS where rownum < 1
/

alter table  WRH$_SERVICE_WAIT_CLASS_BL
 add constraint WRH$_SERVICE_WAIT_CLASS_BL_PK primary key 
    (dbid, snap_id, instance_number, service_name_hash, wait_class_id)
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table          WRH$_SESS_TIME_STATS
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,session_type         varchar2(64)     not null
,min_logon_time       date
,sum_cpu_time         number
,sum_sys_io_wait      number
,sum_user_io_wait     number
,constraint WRH$_SESS_TIME_STATS_PK primary key 
    (dbid, snap_id, instance_number, session_type)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_STREAMS_CAPTURE
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,capture_name                   varchar2(30) not null
,startup_time                   date         not null
,lag                            number
,total_messages_captured        number
,total_messages_enqueued        number
,elapsed_rule_time              number
,elapsed_enqueue_time           number
,elapsed_redo_wait_time         number
,elapsed_pause_time             number
,constraint WRH$_STREAMS_CAPTURE_PK primary key
  (dbid, snap_id, instance_number, capture_name)
   using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_STREAMS_APPLY_SUM
(snap_id                              number       not null
,dbid                                 number       not null
,instance_number                      number       not null
,apply_name                           varchar2(30) not null
,startup_time                         date         not null
,reader_total_messages_dequeued       number
,reader_lag                           number
,coord_total_received                 number
,coord_total_applied                  number
,coord_total_rollbacks                number
,coord_total_wait_deps                number
,coord_total_wait_cmts                number
,coord_lwm_lag                        number
,server_total_messages_applied        number
,server_elapsed_dequeue_time          number
,server_elapsed_apply_time            number
,constraint WRH$_STREAMS_APPLY_SUM_PK primary key
  (dbid, snap_id, instance_number, apply_name)
   using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_BUFFERED_QUEUES
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,queue_schema                   varchar2(30) not null
,queue_name                     varchar2(30) not null
,startup_time                   date         not null
,queue_id                       number       not null
,num_msgs                       number
,spill_msgs                     number
,cnum_msgs                      number
,cspill_msgs                    number
,expired_msgs                   number
,oldest_msgid                   raw(16)
,oldest_msg_enqtm               timestamp(3)
,queue_state                    varchar2(25)
,elapsed_enqueue_time           number
,elapsed_dequeue_time           number
,elapsed_transformation_time    number
,elapsed_rule_evaluation_time   number
,enqueue_cpu_time               number
,dequeue_cpu_time               number
,last_enqueue_time              timestamp(3)
,last_dequeue_time              timestamp(3)
,constraint WRH$_BUFFERED_QUEUES_PK primary key
  (dbid, snap_id, instance_number, queue_schema, queue_name)
   using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_BUFFERED_SUBSCRIBERS
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,queue_schema                   varchar2(30) not null
,queue_name                     varchar2(30) not null
,subscriber_id                  number       not null 
,subscriber_name                varchar2(30) 
,subscriber_address             varchar2(1024)
,subscriber_type                varchar2(30)
,startup_time                   date         not null
,num_msgs                       number
,cnum_msgs                      number
,total_spilled_msg              number
,last_browsed_seq               number
,last_browsed_num               number
,last_dequeued_seq              number
,last_dequeued_num              number
,current_enq_seq                number
,total_dequeued_msg             number
,expired_msgs                   number
,message_lag                    number
,elapsed_dequeue_time           number
,dequeue_cpu_time               number
,last_dequeue_time              timestamp(3)
,oldest_msgid                   raw(16)
,oldest_msg_enqtm               timestamp(3)
,constraint WRH$_BUFFERED_SUBSCRIBERS_PK primary key
  (dbid, snap_id, instance_number, queue_schema, queue_name, subscriber_id)
   using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_PERSISTENT_QUEUES
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,queue_schema                   varchar2(30) not null
,queue_name                     varchar2(30) not null
,queue_id                       number       not null
,first_activity_time            timestamp(6)
,enqueued_msgs                  number
,dequeued_msgs                  number
,elapsed_enqueue_time           number
,elapsed_dequeue_time           number
,elapsed_transformation_time    number
,elapsed_rule_evaluation_time   number
,enqueued_expiry_msgs           number
,enqueued_delay_msgs            number
,msgs_made_expired              number
,msgs_made_ready                number
,last_enqueue_time              timestamp(6)
,last_dequeue_time              timestamp(6)
,last_tm_expiry_time            timestamp(6)
,last_tm_ready_time             timestamp(6)
,browsed_msgs                   number
,enqueue_cpu_time               number
,dequeue_cpu_time               number
,avg_msg_age                    number
,dequeued_msg_latency           number
,enqueue_transactions           number
,dequeue_transactions           number
,execution_count                number
,constraint WRH$_PERSISTENT_QUEUES_PK primary key
  (dbid, snap_id, instance_number, queue_schema, queue_id)
   using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_PERSISTENT_SUBSCRIBERS
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,queue_schema                   varchar2(30) not null
,queue_name                     varchar2(30) not null
,subscriber_id                  number       not null 
,subscriber_name                varchar2(30)  
,subscriber_address             varchar2(1024)
,subscriber_type                varchar2(30)
,first_activity_time            timestamp(6)
,enqueued_msgs                  number
,dequeued_msgs                  number
,expired_msgs                   number
,dequeued_msg_latency           number
,last_enqueue_time              timestamp(6)
,last_dequeue_time              timestamp(6)
,avg_msg_age                    number
,browsed_msgs                   number
,elapsed_dequeue_time           number
,dequeue_cpu_time               number
,dequeue_transactions           number
,execution_count                number
,constraint WRH$_PERSISTENT_SUBSCRIBERS_PK primary key
  (dbid, snap_id, instance_number, queue_schema, queue_name, subscriber_id)
   using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_RULE_SET
(snap_id                        number       not null
,dbid                           number       not null
,instance_number                number       not null
,owner                          varchar2(30) not null
,name                           varchar2(30) not null
,startup_time                   date         not null
,cpu_time                       number
,elapsed_time                   number
,evaluations                    number
,sql_free_evaluations           number
,sql_executions                 number
,reloads                        number
,constraint WRH$_RULE_SET_PK primary key
  (dbid, snap_id, instance_number, owner, name)
   using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

Rem *************************************************************************
Rem ======== Tables For Maintenance Window Auto Tasks Schedules =============
Rem *************************************************************************

Rem ========================================================================= 
Rem              WRI$_SCH_CONTROL - Control Table 
Rem ========================================================================= 

create table WRI$_SCH_CONTROL
(schedule_id     number       not null
,schedule_mode   number       not null
,start_calibrate number                 /* when we first started calibrating */
,last_vote       number                                /* last time we voted */
,num_votes       number                     /* number of times we have voted */
,synced_time     number                            /* synced wallclock time,
                                                  (num of secs from 12:00AM) */
,status          number                            /* status of the schedule */
,constraint WRM$_SCH_CONTROL_PK primary key (schedule_id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 
Rem             WRI$_SCH_VOTES - Table to store votes
Rem ========================================================================= 

create table WRI$_SCH_VOTES
(schedule_id     number       not null
,vector_index    number       not null               /* index for the vector */
,vector          number                                  /* vector of values */
,constraint WRM$_SCH_VOTES_PK primary key (schedule_id, vector_index)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem *************************************************************************
Rem                      Resource Manager Statistics
Rem *************************************************************************

Rem ========================================================================= 
Rem Table to capture Resource Manager statistics for each consumer group,
Rem based on the statistics captured by v$rsrc_cons_group_history.

create table WRH$_RSRC_CONSUMER_GROUP
(snap_id                     number         not null,
 dbid                        number         not null,
 instance_number             number         not null,
 sequence#                   number         not null,
 consumer_group_id           number         not null,
 consumer_group_name         varchar2(30)   not null,
 requests                    number         not null,
 cpu_wait_time               number         not null,
 cpu_waits                   number         not null,
 consumed_cpu_time           number         not null,
 yields                      number         not null,
 active_sess_limit_hit       number         not null,
 undo_limit_hit              number         not null,
 switches_in_cpu_time        number         not null,
 switches_out_cpu_time       number         not null,
 switches_in_io_megabytes    number         not null,
 switches_out_io_megabytes   number         not null,
 switches_in_io_requests     number         not null,
 switches_out_io_requests    number         not null,
 sql_canceled                number         not null,
 active_sess_killed          number         not null,
 idle_sess_killed            number         not null,
 idle_blkr_sess_killed       number         not null,
 queued_time                 number         not null,
 queue_time_outs             number         not null,
 io_service_time             number         not null,
 io_service_waits            number         not null,
 small_read_megabytes        number         not null,
 small_write_megabytes       number         not null,
 large_read_megabytes        number         not null,
 large_write_megabytes       number         not null,
 small_read_requests         number         not null,
 small_write_requests        number         not null,
 large_read_requests         number         not null,
 large_write_requests        number         not null,
 pqs_queued                  number,
 pq_queued_time              number,
 pq_queue_time_outs          number,
 pqs_completed               number,
 pq_servers_used             number,
 pq_active_time              number,
 constraint WRH$_RSRC_CONSUMER_GROUP_PK primary key 
    (dbid, snap_id, instance_number, sequence#, consumer_group_id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 
Rem Table to capture Resource Manager statistics for each plan,
Rem based on the statistics captured by v$rsrc_plan_history.

create table WRH$_RSRC_PLAN
(snap_id              number         not null,
 dbid                 number         not null,
 instance_number      number         not null,
 sequence#            number         not null,
 start_time           date           not null,
 end_time             date,
 plan_id              number         not null,
 plan_name            varchar2(30)   not null,
 cpu_managed          varchar2(4)    not null,
 parallel_execution_managed     varchar2(4),
 constraint WRH$_RSRC_PLAN_PK primary key 
    (dbid, snap_id, instance_number, sequence#)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_CLUSTER_INTERCON
(snap_id              number         not null
,dbid                 number         not null
,instance_number      number         not null
,name                 varchar2(256)  not null
,ip_address           varchar2(64)   not null
,is_public            varchar2(3)
,source               varchar2(31)
,constraint WRH$_CLUSTER_INTERCON_PK primary key
    (dbid, snap_id, instance_number, name, ip_address)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_IC_DEVICE_STATS
(snap_id              number         not null
,dbid                 number         not null
,instance_number      number         not null
,if_name              varchar2(256)  not null
,ip_addr              varchar2(64)   not null
,net_mask             varchar2(16)
,flags                varchar2(32)
,mtu                  number
,bytes_received       number
,packets_received     number
,receive_errors       number
,receive_dropped      number
,receive_buf_or       number
,receive_frame_err    number
,bytes_sent           number
,packets_sent         number
,send_errors          number
,sends_dropped        number
,send_buf_or          number
,send_carrier_lost    number
,constraint WRH$_IC_DEVICE_STATS_PK primary key    
     (dbid, snap_id, instance_number, if_name, ip_addr)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_IC_CLIENT_STATS
(snap_id              number         not null
,dbid                 number         not null
,instance_number      number         not null
,name                 varchar2(9)    not null
,bytes_sent           number
,bytes_received       number
,constraint WRH$_IC_CLIENT_STATS_PK primary key    
     (dbid, snap_id, instance_number, name)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_MEM_DYNAMIC_COMP
(snap_id              number         not null
,dbid                 number         not null
,instance_number      number         not null
,component            varchar2(64)   not null
,current_size         number
,min_size             number
,max_size             number
,user_specified_size  number
,oper_count           number
,last_oper_type       varchar2(13)
,last_oper_mode       varchar2(9)
,last_oper_time       date
,granule_size         number
,constraint WRH$_MEM_DYNAMIC_COMP_PK primary key    
     (dbid, snap_id, instance_number, component)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_INTERCONNECT_PINGS
(snap_id              number         not null
,dbid                 number         not null
,instance_number      number         not null
,target_instance      number         not null
,cnt_500b             number
,wait_500b            number
,waitsq_500b          number
,cnt_8k               number
,wait_8k              number
,waitsq_8k            number
,constraint WRH$_INTERCONNECT_PINGS_PK primary key    
     (dbid, snap_id, instance_number, target_instance)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_IC_PINGS_MXDB_MXSN values less than (MAXVALUE, MAXVALUE)
    tablespace SYSAUX)
enable row movement
/

Rem
Rem Set up the Baseline table -
Rem  (1) Drop the BL table and create BL with same schema as base table 
Rem  (2) Add primary key constraint
Rem
drop table   WRH$_INTERCONNECT_PINGS_BL;
create table WRH$_INTERCONNECT_PINGS_BL tablespace SYSAUX 
 as select * from WRH$_INTERCONNECT_PINGS where rownum < 1
/

alter table  WRH$_INTERCONNECT_PINGS_BL
 add constraint WRH$_INTERCONNECT_PINGS_BL_PK primary key    
     (dbid, snap_id, instance_number, target_instance)
 using index tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_DISPATCHER
(snap_id            number      not null
,dbid               number      not null
,instance_number    number      not null
,name               varchar2(4) not null
,serial#            number
,idle               number
,busy               number
,wait               number
,totalq             number
,sampled_total_conn number
,constraint WRH$_DISPATCHER_PK primary key
    (dbid, snap_id, instance_number, name)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_SHARED_SERVER_SUMMARY
(snap_id             number not null
,dbid                number not null
,instance_number     number not null
,num_samples         number
,sample_time         number
,sampled_total_conn  number
,sampled_active_conn number
,sampled_total_srv   number
,sampled_active_srv  number
,sampled_total_disp  number
,sampled_active_disp number
,srv_busy            number
,srv_idle            number
,srv_in_net          number
,srv_out_net         number
,srv_messages        number
,srv_bytes           number
,cq_wait             number
,cq_totalq           number
,dq_totalq           number
,constraint WRH$_SHARED_SERVER_SUMMARY_PK primary key
    (dbid, snap_id, instance_number)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

create table WRH$_DYN_REMASTER_STATS
(snap_id             number not null
,dbid                number not null
,instance_number     number not null
,remaster_ops        number
,remaster_time       number
,remastered_objects  number
,quiesce_time        number
,freeze_time         number
,cleanup_time        number
,replay_time         number
,fixwrite_time       number
,sync_time           number
,resources_cleaned   number
,replayed_locks_sent number
,replayed_locks_received number
,current_objects     number
,constraint WRH$_DYN_REMASTER_STATS_PK primary key
    (dbid, snap_id, instance_number)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================
create table WRH$_PERSISTENT_QMN_CACHE
(snap_id                          number          not null
,dbid                             number          not null
,instance_number                  number          not null
,queue_table_id                   number          not null
,type                             varchar2(32)
,status                           number
,next_service_time                timestamp(3)
,window_end_time                  timestamp(3)
,total_runs                       number
,total_latency                    number
,total_elapsed_time               number
,total_cpu_time                   number
,tmgr_rows_processed              number
,tmgr_elapsed_time                number
,tmgr_cpu_time                    number
,last_tmgr_processing_time        timestamp(3)
,deqlog_rows_processed            number
,deqlog_processing_elapsed_time   number
,deqlog_processing_cpu_time       number
,last_deqlog_processing_time      timestamp(3)
,dequeue_index_blocks_freed       number
,history_index_blocks_freed       number
,time_index_blocks_freed          number
,index_cleanup_count              number
,index_cleanup_elapsed_time       number
,index_cleanup_cpu_time           number
,last_index_cleanup_time          timestamp(3)
,constraint WRH$_PERSISTENT_QMN_CACHE_PK primary key
  (dbid, snap_id, instance_number, queue_table_id)
   using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem ========================================================================= 

Rem *************************************************************************
Rem  Create the type used for Baselines
Rem *************************************************************************

/* AWR Baseline Details Type */
create type AWRBL_DETAILS_TYPE
  as object (dbid                number
            ,baseline_id         number
            ,instance_number     number
            ,start_snap_id       number
            ,start_snap_time     timestamp(3)
            ,end_snap_id         number
            ,end_snap_time       timestamp(3)
            ,shutdown            varchar2(3)
            ,error_count         number
            ,pct_total_time      number)
/
create type AWRBL_DETAILS_TYPE_TABLE
  as table of AWRBL_DETAILS_TYPE
/
create or replace public synonym AWRBL_DETAILS_TYPE for AWRBL_DETAILS_TYPE
/
create or replace public synonym AWRBL_DETAILS_TYPE_TABLE 
                             for AWRBL_DETAILS_TYPE_TABLE
/
grant execute on AWRBL_DETAILS_TYPE to public
/
grant execute on AWRBL_DETAILS_TYPE_TABLE to public
/

/* AWR Baseline Metric Type */
create type AWRBL_METRIC_TYPE
  as object (baseline_name       varchar2(64)
            ,dbid                number
            ,instance_number     number
            ,beg_time            timestamp(3)
            ,end_time            timestamp(3)
            ,metric_name         varchar2(64)
            ,metric_unit         varchar2(64)
            ,num_interval        number
            ,interval_size       number
            ,average             number
            ,minimum             number
            ,maximum             number)
/
create type AWRBL_METRIC_TYPE_TABLE
  as table of AWRBL_METRIC_TYPE
/
create or replace public synonym AWRBL_METRIC_TYPE for AWRBL_METRIC_TYPE
/
create or replace public synonym AWRBL_METRIC_TYPE_TABLE 
                             for AWRBL_METRIC_TYPE_TABLE
/
grant execute on AWRBL_METRIC_TYPE to public
/
grant execute on AWRBL_METRIC_TYPE_TABLE to public
/

Rem *************************************************************************
Rem  Create the types used for reporting
Rem *************************************************************************

Rem ==============================================================
Rem Type used to specify list of instances for report generation.
Rem ==============================================================

create or replace type AWRRPT_INSTANCE_LIST_TYPE as TABLE OF NUMBER
/

-- Public synonym for the types
create or replace public synonym AWRRPT_INSTANCE_LIST_TYPE 
                             for AWRRPT_INSTANCE_LIST_TYPE
/

Rem ==================================================
Rem  Types for displaying the row information for the 
Rem  AWR report.  The following types are returned:
Rem  All HTML reports:       varchar(8000)
Rem  Diff-Diff Text Report:  varchar(320)
Rem  SQL Text Report:        varchar(120)
Rem  All other text reports: varchar(80)
Rem ==================================================

create type AWRRPT_TEXT_TYPE 
  as object (output varchar2(80 CHAR))
/
create type AWRRPT_HTML_TYPE
  as object (output varchar2(8000 CHAR))
/
create type AWRRPT_TEXT_TYPE_TABLE
  as table of AWRRPT_TEXT_TYPE
/
create type AWRRPT_HTML_TYPE_TABLE
  as table of AWRRPT_HTML_TYPE
/
create type AWRDRPT_TEXT_TYPE
  as object (output varchar2(320 CHAR))
/
create type AWRDRPT_TEXT_TYPE_TABLE
  as table of AWRDRPT_TEXT_TYPE
/
create type AWRSQRPT_TEXT_TYPE
  as object (output varchar2(120 CHAR))
/
create type AWRSQRPT_TEXT_TYPE_TABLE
  as table of AWRSQRPT_TEXT_TYPE
/

-- Public synonym for the types
create or replace public synonym AWRRPT_TEXT_TYPE for AWRRPT_TEXT_TYPE
/
create or replace public synonym AWRRPT_HTML_TYPE for AWRRPT_HTML_TYPE
/
create or replace public synonym AWRRPT_TEXT_TYPE_TABLE for AWRRPT_TEXT_TYPE_TABLE
/
create or replace public synonym AWRRPT_HTML_TYPE_TABLE for AWRRPT_HTML_TYPE_TABLE
/
create or replace public synonym AWRDRPT_TEXT_TYPE for AWRDRPT_TEXT_TYPE
/
create or replace public synonym AWRDRPT_TEXT_TYPE_TABLE for AWRDRPT_TEXT_TYPE_TABLE
/
create or replace public synonym AWRSQRPT_TEXT_TYPE for AWRSQRPT_TEXT_TYPE
/
create or replace public synonym AWRSQRPT_TEXT_TYPE_TABLE for AWRSQRPT_TEXT_TYPE_TABLE
/
grant execute on AWRRPT_TEXT_TYPE to public
/
grant execute on AWRRPT_HTML_TYPE to public
/
grant execute on AWRRPT_TEXT_TYPE_TABLE to public
/
grant execute on AWRRPT_HTML_TYPE_TABLE to public
/
grant execute on AWRDRPT_TEXT_TYPE to public
/
grant execute on AWRDRPT_TEXT_TYPE_TABLE to public
/
grant execute on AWRSQRPT_TEXT_TYPE to public
/
grant execute on AWRSQRPT_TEXT_TYPE_TABLE to public
/

Rem ===============================================
Rem  Types for storing the row information for the 
Rem  AWR report
Rem ===============================================

create type AWRRPT_NUM_ARY IS VARRAY(30) of NUMBER
/
create type AWRRPT_VCH_ARY IS VARRAY(30) OF VARCHAR2(80 CHAR)
/
create type AWRRPT_CLB_ARY IS VARRAY(30) OF CLOB
/
create type AWRRPT_ROW_TYPE
  as object ( num_dfn AWRRPT_NUM_ARY,
              vch_dfn AWRRPT_VCH_ARY,
              clb_dfn AWRRPT_CLB_ARY)
/

-- Public synonyms and execute privileges for the types
create or replace public synonym AWRRPT_NUM_ARY for AWRRPT_NUM_ARY
/
create or replace public synonym AWRRPT_VCH_ARY for AWRRPT_VCH_ARY
/
create or replace public synonym AWRRPT_CLB_ARY for AWRRPT_CLB_ARY
/
create or replace public synonym AWRRPT_ROW_TYPE for AWRRPT_ROW_TYPE
/
grant execute on AWRRPT_NUM_ARY to public
/
grant execute on AWRRPT_VCH_ARY to public
/
grant execute on AWRRPT_CLB_ARY to public
/
grant execute on AWRRPT_ROW_TYPE to public
/

Rem *************************************************************************
Rem  Types used for updating object information in wrh$_seg_stat_obj
Rem *************************************************************************

create type AWR_OBJECT_INFO_TYPE
 as object (
             owner_name       VARCHAR2(64)
           , object_name      VARCHAR2(256)
           , subobject_name   VARCHAR2(256)
           , tablespace_name  VARCHAR2(64)
           , object_type      VARCHAR2(64)
)
/
create type AWR_OBJECT_INFO_TABLE_TYPE as table of AWR_OBJECT_INFO_TYPE
/
create or replace public synonym AWR_OBJECT_INFO_TYPE for AWR_OBJECT_INFO_TYPE
/
create or replace public synonym AWR_OBJECT_INFO_TABLE_TYPE
                             for AWR_OBJECT_INFO_TABLE_TYPE
/


Rem *************************************************************************
Rem  Place new statistics tables above this line.
Rem *************************************************************************

Rem *************************************************************************
Rem Creating the Workload Repository Metadata (WRM$) Tables ...
Rem   These tables must be created LAST as we use their existence
Rem   to detect if the WR schema has been created successfully.
Rem *************************************************************************

Rem =========================================================================

create table          WRM$_WR_USAGE
(feature_type         varchar2(32) not null
,feature_name         varchar2(64) not null
,usage_time           timestamp(3) not null
) tablespace SYSAUX
/

create index WRM$_WR_USAGE_INDEX 
  on WRM$_WR_USAGE(usage_time)
  tablespace SYSAUX
/

Rem =========================================================================

create table          WRM$_DATABASE_INSTANCE
(dbid                 number       not null
,instance_number      number       not null
,startup_time         timestamp(3) not null
,parallel             varchar2(3)  not null
,version              varchar2(17) not null
,db_name              varchar2(9)
,instance_name        varchar2(16)
,host_name            varchar2(64)
,last_ash_sample_id   number       not null
,platform_name        varchar2(101) 
,constraint WRM$_DATABASE_INSTANCE_PK primary key
    (dbid, instance_number, startup_time)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRM$_SNAPSHOT
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,startup_time         timestamp(3)     not null
,begin_interval_time  timestamp(3)     not null
,end_interval_time    timestamp(3)     not null
,flush_elapsed        interval day(5) to second(1)
,snap_level           number
,status               number
,error_count          number
,bl_moved             number
,snap_flag            number
,snap_timezone        interval day(0) to second(0)
,constraint WRM$_SNAPSHOT_PK primary key (dbid, snap_id, instance_number)
 using index tablespace SYSAUX
,constraint WRM$_SNAPSHOT_FK foreign key (dbid, instance_number, startup_time)
    references WRM$_DATABASE_INSTANCE on delete cascade
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRM$_SNAPSHOT_DETAILS
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,table_id             number           not null
,begin_time           timestamp(3)     
,end_time             timestamp(3)     
) tablespace SYSAUX
/

Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem  create index on the WRM$_SNAPSHOT_DETAILS table
Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
create index WRM$_SNAPSHOT_DETAILS_INDEX 
  on WRM$_SNAPSHOT_DETAILS(snap_id, dbid, instance_number, table_id) 
  tablespace SYSAUX
/

Rem =========================================================================

create table          WRM$_SNAP_ERROR
(snap_id              number           not null
,dbid                 number           not null
,instance_number      number           not null
,table_name           varchar2(30)     not null
,error_number         number           not null
,constraint WRM$_SNAP_ERROR_PK 
      primary key (dbid, snap_id, instance_number, table_name)
   using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================
Rem 
Rem create table          WRM$_SNAP_ERROR
Rem (snap_id              number           not null
Rem ,dbid                 number           not null
Rem ,instance_number      number           not null
Rem ,table_name           varchar2(30)     not null
Rem ,error_number         number           not null
Rem ,constraint WRM$_SNAP_ERROR_PK primary key (snap_id, dbid, instance_number)
Rem  using index tablespace SYSAUX
Rem ,constraint WRM$_SNAP_ERROR_FK foreign key (dbid, instance_number, snap_id)
Rem     references WRM$_SNAPSHOT on delete cascade
Rem ) tablespace SYSAUX
Rem /

Rem =========================================================================

create table          WRM$_BASELINE
(dbid                 number           not null
,baseline_id          number           not null
,baseline_name        varchar2(64)
,start_snap_id        number
,end_snap_id          number
,baseline_type        varchar2(13)
,moving_window_size   number
,creation_time        date
,expiration           number
,template_name        varchar2(64)
,last_time_computed   date
,constraint WRM$_BASELINE_PK 
  primary key (dbid, baseline_id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRM$_COLORED_SQL
(dbid                 number           not null
,sql_id               varchar2(13)     not null
,owner                number           not null
,create_time          date             not null
,constraint WRM$_COLORED_SQL_PK primary key (dbid, sql_id, owner)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRM$_BASELINE_DETAILS
(dbid                 number           not null
,baseline_id          number           not null
,instance_number      number           not null
,start_snap_id        number
,start_snap_time      timestamp(3)
,end_snap_id          number
,end_snap_time        timestamp(3)
,shutdown             varchar2(3)
,error_count          number
,pct_total_time       number
,constraint WRM$_BASELINE_DETAILS_PK 
  primary key (dbid, baseline_id, instance_number)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================

create table          WRM$_BASELINE_TEMPLATE
(dbid                 number           not null
,template_id          number           not null
,template_name        varchar2(30)     not null
,template_type        varchar2(9)      not null
,baseline_name_prefix varchar2(30)     not null
,start_time           date             not null
,end_time             date             not null
,day_of_week          varchar2(9)
,hour_in_day          number
,duration             number
,expiration           number
,repeat_interval      varchar2(128)
,last_generated       date
,constraint WRM$_BASELINE_TEMPLATE_PK 
  primary key (dbid, template_id)
 using index tablespace SYSAUX
) tablespace SYSAUX
/


Rem =========================================================================
Rem
Rem  Registration_Status:   0 - complete
Rem                         1 - incomplete
Rem

create table          WRM$_WR_CONTROL
(dbid                   number                 not null
,snap_interval          interval day(5) to second(1) not null
,snapint_num            number
,retention              interval day(5) to second(1) not null
,retention_num          number
,most_recent_snap_id    number                 not null
,most_recent_snap_time  timestamp(3)
,mrct_snap_time_num     number
,status_flag            number
,most_recent_purge_time timestamp(3)
,mrct_purge_time_num    number
,most_recent_split_id   number
,most_recent_split_time number
,swrf_version           number
,registration_status    number
,mrct_baseline_id       number
,topnsql                number
,mrct_bltmpl_id         number
,constraint WRM$_WR_CONTROL_PK primary key (dbid)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem =========================================================================
Rem 
Rem Initialize start times to 1 year from beginning of ksugctm clock.
Rem


Rem **********************************************************************
Rem Skip INSERT for local database. Registration for local dbid occurs
Rem at the end of CATSWRF.SQL.
Rem **********************************************************************
Rem insert into WRM$_WR_CONTROL(dbid, snap_interval, snapint_num, retention,
Rem                             retention_num, mrct_snap_time_num,
Rem                             most_recent_snap_time, most_recent_snap_id,
Rem                             status_flag, mrct_purge_time_num,
Rem                             most_recent_purge_time, most_recent_split_id,
Rem                             most_recent_split_time, swrf_version,
Rem                             registration_status, mrct_baseline_id)
Rem select dbid, INTERVAL '30' MINUTE, 1800, INTERVAL '7' DAY, 604800,
Rem        31536000, SYSTIMESTAMP, 0, 0, 31536000, SYSTIMESTAMP, 
Rem        0, 31536000, 0, 1, 0 from V$DATABASE
Rem /
Rem commit
Rem /
Rem **********************************************************************


Rem *************************************************************************
Rem  Note:
Rem   The WRM$_WR_CONTROL table must be the LAST table created in this
Rem   file.  Please add any new statistics tables before the WRM$ tables.
Rem *************************************************************************

-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';
