Rem Copyright (c) 2003, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catawrvw.sql - Catalog script for AWR Views
Rem
Rem    DESCRIPTION
Rem      Catalog script for AWR Views. Used to create the  
Rem      Workload Repository Schema.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bdagevil    03/14/10 - add px_flags column to
Rem                           DBA_HIST_ACTIVE_SESS_HISTORY
Rem    dongfwan    02/22/10 - Bug 9266913: add snap_timezone to wrm$_snapshot
Rem    sburanaw    02/04/10 - add db replay's callid to ASH
Rem    jomcdon     12/31/09 - bug 9212250: add PQQ fields to AWR tables
Rem    ilistvin    11/23/09 - bug8811401: add DBA_HIST_TABLESPACE view
Rem    amadan      11/19/09 - Bug 9115881 Add and Update AQ related AWR views 
Rem    arbalakr    11/12/09 - truncate module/action to max lengths in
Rem                           X$MODACT_LENGTH
Rem    sriganes    07/24/09 - bug 8413874: add multi-valued parameters in AWR
Rem    mfallen     03/20/09 - bug 8347956: add flash cache columns
Rem    akini       03/16/09 - add dba_hist_ash_snapshot
Rem    arbalakr    03/16/09 - bug 8283759: add hostname, port num to ASH view
Rem    arbalakr    02/24/09 - add DBA_HIST_SQLCOMMAND_NAME/TOPLEVELCALL_NAME
Rem    arbalakr    02/23/09 - bug 7350685: add sql_opname,top_level_call#/name
Rem                           to ASH view
Rem    amysoren    02/05/09 - bug 7483450: add foreground values to
Rem                           waitclassmetric
Rem    mfallen     01/04/09 - bug 7650345: add new sqlstat and seg_stat columns
Rem    bdagevil    01/02/09 - add STASH columns to ASH view
Rem    ilistvin    10/22/08 - add DBA_HIST_PLAN_OPTION_NAME and
Rem                           DBA_HIST_PLAN_OPERATION_NAME
Rem    sburanaw    09/29/08 - is_captured/is_replayed, capture/replay_overhead
Rem                           to ash
Rem    ushaft      08/19/08 - add columns to ASH view
Rem    sburanaw    08/15/08 - expose time_mode, is_sqlid_current, in_capture,
Rem                           in_replay in ASH
Rem    amysoren    08/14/08 - add ash bit for sequence load
Rem    mfallen     05/15/08 - bug 7029198: add dba_hist_dyn_remaster_stats
Rem    akini       04/23/08 - added DBA_HIST_IOSTAT_DETAIL
Rem    jgiloni     04/15/08 - Shared Server AWR Stats
Rem    mfallen     03/12/08 - bug 6861722: add dba_hist_db_cache_advice column
Rem    sburanaw    12/11/07 - add blocking_inst_id, ecid to ASH
Rem    pbelknap    03/23/07 - add parsing_user_id to sqlstat
Rem    mlfeng      04/18/07 - platform name to database_instance, 
Rem                           bug with join in iostat views
Rem    sburanaw    03/02/07 - rename column top_sql* to top_level_sql* in
Rem                           DBA_HIST_ACTIVE_SESS_HISTORY
Rem                           redefine ash session_type
Rem                           remove in_background column
Rem    ushaft      02/08/07 - add IC_CLIENT_STATS, IC_DEVICE_STATS, 
Rem                           MEM_DYNAMIC_COMP, INTERCONNECT_PINGS
Rem    veeve       03/08/07 - add flags to DBA_HIST_ASH
Rem    amadan      02/10/07 - add first_activity_time to
Rem                           DBA_HIST_PERSISTENT_QUEUES
Rem    mlfeng      12/21/06 - add snap_flag to dba_hist_snapshot
Rem    suelee      01/02/07 - Disable IORM
Rem    ilistvin    11/09/06 - move views with package dependencies to
Rem                           catawrpd.sql
Rem    pbelknap    11/20/06 - add flag column to DBA_HIST_SQLSTAT
Rem    mlfeng      10/25/06 - do not join with BL table
Rem    sburanaw    08/04/06 - rename "time_model" columns to "in_" columns,
Rem                           remove parse columns, redefine session_type     
Rem    sburanaw    08/03/06 - add current_row# to dba_hist_active_sess_history
Rem    ushaft      08/03/06 - add column to pga_target_advice
Rem    mlfeng      07/21/06 - add interconnect table 
Rem    suelee      07/25/06 - Fix units for Resource Manager views 
Rem    mlfeng      07/17/06 - add sum squares 
Rem    veeve       06/23/06 - add new 11g columns to DBA_HIST_ASH
Rem    mlfeng      06/17/06 - remove union all from Baseline tables 
Rem    mlfeng      06/11/06 - add last_time_computed 
Rem    mlfeng      05/20/06 - add columns to baselines 
Rem    suelee      05/18/06 - Add IO statistics tables 
Rem    gngai       04/14/06 - added coloredsql view
Rem    ushaft      05/26/06 - added 16 columns to DBA_HIST_INST_CACHE_TRANSFER
Rem    amadan      05/16/06 - add DBA_HIST_PERSISTENT_QUEUES 
Rem    mlfeng      05/14/06 - add memory views 
Rem    amysoren    05/17/06 - DBA_HIST_SYSTEM_EVENT changes 
Rem    veeve       03/01/06 - modified DBA_HIST_ASH to show eflushed rows
Rem    veeve       02/10/06 - add qc_session_serial# to ASH 
Rem    adagarwa    04/25/05 - Added PL/SQL stack fields to DBA_HIST_ASH
Rem    mlfeng      05/10/05 - add event histogram, mutex sleep 
Rem    mlfeng      05/26/05 - Fix tablespace space usage view
Rem    veeve       03/10/05 - made DBA_HIST_ASH.QC* NULL when invalid
Rem    adagarwa    03/04/05 - Added force_matching_sig,blocking_sesison_srl#
Rem                           to DBA_HIST_ACTIVE_SESS_HISTORY
Rem    narora      03/07/05 - add queue_id to WRH$_BUFFERED_QUEUES 
Rem    kyagoub     09/12/04 - add bind_data to dba_hist_sqlstat 
Rem    veeve       10/19/04 - add p1text,p2text,p3text to 
Rem                           dba_hist_active_sess_history 
Rem    mlfeng      09/21/04 - add parsing_schema_name 
Rem    mlfeng      07/27/04 - add new sql columns, new tables 
Rem    bdagevil    08/02/04 - fix DBA_HIST_SQLBIND view 
Rem    mlfeng      05/21/04 - add topnsql column 
Rem    ushaft      05/26/04 - added DBA_HIST_STREAMS_POOL_ADVICE
Rem    ushaft      05/15/04 - add views for WRH$_COMP_IOSTAT, WRH$_SGA_TARGET..
Rem    bdagevil    05/26/04 - add timestamp column in explain plan 
Rem    bdagevil    05/13/04 - add other_xml column 
Rem    narora      05/20/04 - add wrh$_sess_time_stats, streams tables
Rem    veeve       05/12/04 - made DBA_HIST_ASH similiar to its V$
Rem                           add blocking_session,xid to DBA_HIST_ASH
Rem    mlfeng      04/26/04 - p1, p2, p3 for event name 
Rem    mlfeng      01/30/04 - add gc buffer busy 
Rem    mlfeng      01/12/04 - class -> instance cache transfer 
Rem    mlfeng      12/09/03 - fix bug with baseline view 
Rem    mlfeng      11/24/03 - remove rollstat, add latch_misses_summary
Rem    pbelknap    11/03/03 - pbelknap_swrfnm_to_awrnm 
Rem    mlfeng      08/29/03 - sync up with v$ changes
Rem    mlfeng      08/27/03 - add rac tables 
Rem    mlfeng      07/10/03 - add service stats
Rem    nmacnaug    08/13/03 - remove unused statistic 
Rem    mlfeng      08/04/03 - remove address columns from ash, sql_bind 
Rem    mlfeng      07/25/03 - add group_name to metric name
Rem    gngai       08/01/03 - changed event class metrics
Rem    mramache    06/24/03 - hintset_applied -> sql_profile
Rem    gngai       06/17/03 - changed dba_hist_sysmetric_history
Rem    gngai       06/24/03 - fixed wrh$ views to use union all
Rem    mlfeng      06/03/03 - add wrh$_instance_recovery columns
Rem    mramache    05/20/03 - add plsql/java time columns to DBA_HIST_SQLSTAT
Rem    veeve       04/22/03 - Modified DBA_HIST_ACTIVE_SESS_HISTORY
Rem                           sql_hash_value OUT, sql_id IN, sql_address OUT
Rem    bdagevil    04/23/03 - undostat views: use sql_id instead of signature
Rem    mlfeng      04/22/03 - Modify signature/hash value to sql_id
Rem    mlfeng      04/14/03 - Modify DBA_HIST_SQLSTAT, DBA_HIST_SQLTEXT
Rem    mlfeng      04/11/03 - Add DBA_HIST_OPTIMIZER_ENV
Rem    bdagevil    04/28/03 - merge new file
Rem    mlfeng      03/17/03 - Adding hash to name tables
Rem    mlfeng      04/01/03 - add block size to datafile, tempfile
Rem    veeve       03/05/03 - rename service_id to service_hash
Rem                           in DBA_HIST_ACTIVE_SESS_HISTORY
Rem    mlfeng      03/05/03 - add SQL Bind view
Rem    mlfeng      03/04/03 - add new dba_hist views to sync with catswrtb
Rem    mlfeng      03/04/03 - remove wrh$_idle_event
Rem    mlfeng      02/13/03 - modify dba_hist_event_name
Rem    mlfeng      01/27/03 - mlfeng_swrf_reporting
Rem    mlfeng      01/24/03 - update undostat view
Rem    mlfeng      01/16/03 - Creation of DBA_HIST views
Rem    mlfeng      01/16/03 - Created
Rem


Rem ************************************************************************* 
Rem Creating the Workload Repository History (DBA_HIST) Catalog Views ...
Rem ************************************************************************* 


/***************************************
 *     DBA_HIST_DATABASE_INSTANCE
 ***************************************/

create or replace view DBA_HIST_DATABASE_INSTANCE
  (DBID, INSTANCE_NUMBER, STARTUP_TIME, PARALLEL, VERSION, 
   DB_NAME, INSTANCE_NAME, HOST_NAME, LAST_ASH_SAMPLE_ID, 
   PLATFORM_NAME)
as
select dbid, instance_number, startup_time, parallel, version, 
       db_name, instance_name, host_name, last_ash_sample_id,
       platform_name
from WRM$_DATABASE_INSTANCE
/
comment on table DBA_HIST_DATABASE_INSTANCE is
'Database Instance Information'
/
create or replace public synonym DBA_HIST_DATABASE_INSTANCE 
    for DBA_HIST_DATABASE_INSTANCE
/
grant select on DBA_HIST_DATABASE_INSTANCE to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SNAPSHOT
 ***************************************/

/* only the valid snapshots (status = 0) will be displayed) */
create or replace view DBA_HIST_SNAPSHOT
  (SNAP_ID, DBID, INSTANCE_NUMBER, STARTUP_TIME, 
   BEGIN_INTERVAL_TIME, END_INTERVAL_TIME,
   FLUSH_ELAPSED, SNAP_LEVEL, ERROR_COUNT, SNAP_FLAG, SNAP_TIMEZONE)
as
select snap_id, dbid, instance_number, startup_time, 
       begin_interval_time, end_interval_time,
       flush_elapsed, snap_level, error_count, snap_flag, snap_timezone
from WRM$_SNAPSHOT
where status = 0;
/
comment on table DBA_HIST_SNAPSHOT is
'Snapshot Information'
/
create or replace public synonym DBA_HIST_SNAPSHOT 
    for DBA_HIST_SNAPSHOT
/
grant select on DBA_HIST_SNAPSHOT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SNAP_ERROR
 ***************************************/

/* shows error information for each snapshot */
create or replace view DBA_HIST_SNAP_ERROR
  (SNAP_ID, DBID, INSTANCE_NUMBER, TABLE_NAME, ERROR_NUMBER)
as select snap_id, dbid, instance_number, table_name, error_number
  from wrm$_snap_error;
/
comment on table DBA_HIST_SNAP_ERROR is
'Snapshot Error Information'
/
create or replace public synonym DBA_HIST_SNAP_ERROR
    for DBA_HIST_SNAP_ERROR
/
grant select on DBA_HIST_SNAP_ERROR to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_COLORED_SQL
 ***************************************/

/* shows list of colored SQL IDs */
create or replace view DBA_HIST_COLORED_SQL
  (dbid, sql_id, create_time)
as select dbid, sql_id, create_time
  from wrm$_colored_sql where owner = 1;
/
comment on table DBA_HIST_COLORED_SQL is
'Marked SQLs for snapshots'
/
create or replace public synonym DBA_HIST_COLORED_SQL
    for DBA_HIST_COLORED_SQL
/
grant select on DBA_HIST_COLORED_SQL to SELECT_CATALOG_ROLE
/

/***************************************
 *    DBA_HIST_BASELINE_METADATA
 ***************************************/
create or replace view DBA_HIST_BASELINE_METADATA
  (dbid, baseline_id, baseline_name, baseline_type,
   start_snap_id, end_snap_id, moving_window_size, 
   creation_time, expiration, template_name,
   last_time_computed)
as
select dbid, baseline_id, 
       baseline_name, baseline_type,
       start_snap_id, end_snap_id,
       moving_window_size, creation_time,
       expiration, template_name, last_time_computed
from
  WRM$_BASELINE
/
comment on table DBA_HIST_BASELINE_METADATA is
'Baseline Metadata Information'
/
create or replace public synonym DBA_HIST_BASELINE_METADATA
    for DBA_HIST_BASELINE_METADATA
/
grant select on DBA_HIST_BASELINE_METADATA to SELECT_CATALOG_ROLE
/

/************************************
 *   DBA_HIST_BASELINE_TEMPLATE
 ************************************/

create or replace view DBA_HIST_BASELINE_TEMPLATE
  (dbid, template_id, template_name, template_type,
   baseline_name_prefix, start_time, end_time,
   day_of_week, hour_in_day, duration,
   expiration, repeat_interval, last_generated)
as
select dbid, template_id, template_name, template_type,
       baseline_name_prefix, start_time, end_time,
       day_of_week, hour_in_day, duration,
       expiration, repeat_interval, last_generated
from
  WRM$_BASELINE_TEMPLATE
/
comment on table DBA_HIST_BASELINE_TEMPLATE is
'Baseline Template Information'
/
create or replace public synonym DBA_HIST_BASELINE_TEMPLATE
    for DBA_HIST_BASELINE_TEMPLATE
/
grant select on DBA_HIST_BASELINE_TEMPLATE to SELECT_CATALOG_ROLE
/


/***************************************
 *       DBA_HIST_WR_CONTROL
 ***************************************/

create or replace view DBA_HIST_WR_CONTROL
  (DBID, SNAP_INTERVAL, RETENTION, TOPNSQL)
as
select dbid, snap_interval, retention, 
       decode(topnsql, 2000000000, 'DEFAULT', 
                       2000000001, 'MAXIMUM',
                       to_char(topnsql, '999999999')) topnsql
from WRM$_WR_CONTROL
/
comment on table DBA_HIST_WR_CONTROL is
'Workload Repository Control Information'
/
create or replace public synonym DBA_HIST_WR_CONTROL 
    for DBA_HIST_WR_CONTROL
/
grant select on DBA_HIST_WR_CONTROL to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_TABLESPACE
 ***************************************/

create or replace view DBA_HIST_TABLESPACE 
  (SNAP_ID, DBID, TS#, TSNAME, CONTENTS, 
   SEGMENT_SPACE_MANAGEMENT, EXTENT_MANAGEMENT)
as
select tbs.snap_id, tbs.dbid, tbs.ts#, tbs.tsname, tbs.contents, 
       tbs.segment_space_management, tbs.extent_management
  from WRH$_TABLESPACE tbs
/

comment on table DBA_HIST_TABLESPACE is
  'Tablespace Static Information'
/
create or replace public synonym DBA_HIST_TABLESPACE
    for DBA_HIST_TABLESPACE
/
grant select on DBA_HIST_TABLESPACE to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_DATAFILE
 ***************************************/


create or replace view DBA_HIST_DATAFILE
  (DBID, FILE#, CREATION_CHANGE#, 
   FILENAME, TS#, TSNAME, BLOCK_SIZE) 
as
select dbid, file#, creation_change#,
       filename, ts#, coalesce(t.tsname, d.tsname) tsname, block_size
from WRH$_DATAFILE d LEFT OUTER JOIN WRH$_TABLESPACE t USING (dbid, ts#)
/
comment on table DBA_HIST_DATAFILE is
'Names of Datafiles'
/
create or replace public synonym DBA_HIST_DATAFILE for DBA_HIST_DATAFILE
/
grant select on DBA_HIST_DATAFILE to SELECT_CATALOG_ROLE
/


/*****************************************
 *        DBA_HIST_FILESTATXS
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed. (bug 5352801)
 *****************************************/
create or replace view DBA_HIST_FILESTATXS 
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   FILE#, CREATION_CHANGE#, FILENAME, TS#, TSNAME, BLOCK_SIZE,
   PHYRDS, PHYWRTS, SINGLEBLKRDS, READTIM, WRITETIM, 
   SINGLEBLKRDTIM, PHYBLKRD, PHYBLKWRT, WAIT_COUNT, TIME) 
as
select f.snap_id, f.dbid, f.instance_number, 
       f.file#, f.creation_change#, fn.filename, 
       fn.ts#, fn.tsname, fn.block_size,
       phyrds, phywrts, singleblkrds, readtim, writetim, 
       singleblkrdtim, phyblkrd, phyblkwrt, wait_count, time
from WRM$_SNAPSHOT sn, WRH$_FILESTATXS f, DBA_HIST_DATAFILE fn
where      f.dbid             = fn.dbid
      and  f.file#            = fn.file#
      and  f.creation_change# = fn.creation_change#
      and  f.snap_id          = sn.snap_id
      and  f.dbid             = sn.dbid
      and  f.instance_number  = sn.instance_number
      and  sn.status          = 0
/

comment on table DBA_HIST_FILESTATXS is
'Datafile Historical Statistics Information'
/
create or replace public synonym DBA_HIST_FILESTATXS for DBA_HIST_FILESTATXS
/
grant select on DBA_HIST_FILESTATXS to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_TEMPFILE
 ***************************************/

create or replace view DBA_HIST_TEMPFILE
  (DBID, FILE#, CREATION_CHANGE#, 
   FILENAME, TS#, TSNAME, BLOCK_SIZE) 
as
select dbid, file#, creation_change#, 
       filename, ts#, coalesce(t.tsname, d.tsname) tsname, block_size
from WRH$_TEMPFILE d LEFT OUTER JOIN WRH$_TABLESPACE t USING (dbid, ts#)
/
comment on table DBA_HIST_TEMPFILE is
'Names of Temporary Datafiles'
/
create or replace public synonym DBA_HIST_TEMPFILE for DBA_HIST_TEMPFILE
/
grant select on DBA_HIST_TEMPFILE to SELECT_CATALOG_ROLE
/


/*****************************************
 *        DBA_HIST_TEMPSTATXS
 *****************************************/
create or replace view DBA_HIST_TEMPSTATXS
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   FILE#, CREATION_CHANGE#, FILENAME, TS#, TSNAME, BLOCK_SIZE,
   PHYRDS, PHYWRTS, SINGLEBLKRDS, READTIM, WRITETIM, 
   SINGLEBLKRDTIM, PHYBLKRD, PHYBLKWRT, WAIT_COUNT, TIME) 
as
select t.snap_id, t.dbid, t.instance_number, 
       t.file#, t.creation_change#, tn.filename, 
       tn.ts#, tn.tsname, tn.block_size, 
       phyrds, phywrts, singleblkrds, readtim, writetim, 
       singleblkrdtim, phyblkrd, phyblkwrt, wait_count, time
from WRM$_SNAPSHOT sn, WRH$_TEMPSTATXS t, DBA_HIST_TEMPFILE tn
where     t.dbid             = tn.dbid
      and t.file#            = tn.file#
      and t.creation_change# = tn.creation_change#
      and sn.snap_id         = t.snap_id
      and sn.dbid            = t.dbid
      and sn.instance_number = t.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_TEMPSTATXS is
'Temporary Datafile Historical Statistics Information'
/
create or replace public synonym DBA_HIST_TEMPSTATXS for DBA_HIST_TEMPSTATXS
/
grant select on DBA_HIST_TEMPSTATXS to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_COMP_IOSTAT
 ***************************************/

create or replace view DBA_HIST_COMP_IOSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, COMPONENT, 
   FILE_TYPE, IO_TYPE, OPERATION, BYTES, IO_COUNT) 
as
select io.snap_id, io.dbid, io.instance_number, io.component,
       io.file_type, io.io_type, io.operation, io.bytes, io.io_count
  from wrm$_snapshot sn, WRH$_COMP_IOSTAT io
  where     sn.snap_id         = io.snap_id
        and sn.dbid            = io.dbid
        and sn.instance_number = io.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_COMP_IOSTAT is
'I/O stats aggregated on component level'
/
create or replace public synonym DBA_HIST_COMP_IOSTAT 
  for DBA_HIST_COMP_IOSTAT
/
grant select on DBA_HIST_COMP_IOSTAT to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_SQLSTAT
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_SQLSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   SQL_ID, PLAN_HASH_VALUE, 
   OPTIMIZER_COST, OPTIMIZER_MODE, OPTIMIZER_ENV_HASH_VALUE,
   SHARABLE_MEM, LOADED_VERSIONS, VERSION_COUNT,
   MODULE, ACTION,
   SQL_PROFILE, FORCE_MATCHING_SIGNATURE, 
   PARSING_SCHEMA_ID, PARSING_SCHEMA_NAME, PARSING_USER_ID, 
   FETCHES_TOTAL, FETCHES_DELTA, 
   END_OF_FETCH_COUNT_TOTAL, END_OF_FETCH_COUNT_DELTA,
   SORTS_TOTAL, SORTS_DELTA, 
   EXECUTIONS_TOTAL, EXECUTIONS_DELTA, 
   PX_SERVERS_EXECS_TOTAL, PX_SERVERS_EXECS_DELTA, 
   LOADS_TOTAL, LOADS_DELTA, 
   INVALIDATIONS_TOTAL, INVALIDATIONS_DELTA,
   PARSE_CALLS_TOTAL, PARSE_CALLS_DELTA, DISK_READS_TOTAL, 
   DISK_READS_DELTA, BUFFER_GETS_TOTAL, BUFFER_GETS_DELTA,
   ROWS_PROCESSED_TOTAL, ROWS_PROCESSED_DELTA, CPU_TIME_TOTAL,
   CPU_TIME_DELTA, ELAPSED_TIME_TOTAL, ELAPSED_TIME_DELTA,
   IOWAIT_TOTAL, IOWAIT_DELTA, CLWAIT_TOTAL, CLWAIT_DELTA,
   APWAIT_TOTAL, APWAIT_DELTA, CCWAIT_TOTAL, CCWAIT_DELTA,
   DIRECT_WRITES_TOTAL, DIRECT_WRITES_DELTA, PLSEXEC_TIME_TOTAL,
   PLSEXEC_TIME_DELTA, JAVEXEC_TIME_TOTAL, JAVEXEC_TIME_DELTA,
   IO_OFFLOAD_ELIG_BYTES_TOTAL, IO_OFFLOAD_ELIG_BYTES_DELTA,
   IO_INTERCONNECT_BYTES_TOTAL, IO_INTERCONNECT_BYTES_DELTA,
   PHYSICAL_READ_REQUESTS_TOTAL, PHYSICAL_READ_REQUESTS_DELTA,
   PHYSICAL_READ_BYTES_TOTAL, PHYSICAL_READ_BYTES_DELTA,
   PHYSICAL_WRITE_REQUESTS_TOTAL, PHYSICAL_WRITE_REQUESTS_DELTA,
   PHYSICAL_WRITE_BYTES_TOTAL, PHYSICAL_WRITE_BYTES_DELTA,
   OPTIMIZED_PHYSICAL_READS_TOTAL, OPTIMIZED_PHYSICAL_READS_DELTA,
   CELL_UNCOMPRESSED_BYTES_TOTAL, CELL_UNCOMPRESSED_BYTES_DELTA,
   IO_OFFLOAD_RETURN_BYTES_TOTAL, IO_OFFLOAD_RETURN_BYTES_DELTA,
   BIND_DATA, FLAG)
as
select sql.snap_id, sql.dbid, sql.instance_number,
       sql_id, plan_hash_value, 
       optimizer_cost, optimizer_mode, optimizer_env_hash_value,
       sharable_mem, loaded_versions, version_count,
       substrb(module,1,(select ksumodlen from x$modact_length)) module, 
       substrb(action,1,(select ksuactlen from x$modact_length)) action,
       sql_profile, force_matching_signature, 
       parsing_schema_id, parsing_schema_name, parsing_user_id,
       fetches_total, fetches_delta, 
       end_of_fetch_count_total, end_of_fetch_count_delta,
       sorts_total, sorts_delta, 
       executions_total, executions_delta, 
       px_servers_execs_total, px_servers_execs_delta, 
       loads_total, loads_delta, 
       invalidations_total, invalidations_delta,
       parse_calls_total, parse_calls_delta, disk_reads_total, 
       disk_reads_delta, buffer_gets_total, buffer_gets_delta,
       rows_processed_total, rows_processed_delta, cpu_time_total,
       cpu_time_delta, elapsed_time_total, elapsed_time_delta,
       iowait_total, iowait_delta, clwait_total, clwait_delta,
       apwait_total, apwait_delta, ccwait_total, ccwait_delta,
       direct_writes_total, direct_writes_delta, plsexec_time_total,
       plsexec_time_delta, javexec_time_total, javexec_time_delta,
       io_offload_elig_bytes_total, io_offload_elig_bytes_delta,
       io_interconnect_bytes_total, io_interconnect_bytes_delta,
       physical_read_requests_total, physical_read_requests_delta,
       physical_read_bytes_total, physical_read_bytes_delta,
       physical_write_requests_total, physical_write_requests_delta,
       physical_write_bytes_total, physical_write_bytes_delta,
       optimized_physical_reads_total, optimized_physical_reads_delta,
       cell_uncompressed_bytes_total, cell_uncompressed_bytes_delta,
       io_offload_return_bytes_total, io_offload_return_bytes_delta, 
       bind_data, sql.flag
from WRM$_SNAPSHOT sn, WRH$_SQLSTAT sql
  where     sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SQLSTAT is
'SQL Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SQLSTAT for DBA_HIST_SQLSTAT
/
grant select on DBA_HIST_SQLSTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SQLTEXT
 ***************************************/

create or replace view DBA_HIST_SQLTEXT
  (DBID, SQL_ID, SQL_TEXT, COMMAND_TYPE)
as
select dbid, sql_id, sql_text, command_type
from WRH$_SQLTEXT
/
comment on table DBA_HIST_SQLTEXT is
'SQL Text'
/
create or replace public synonym DBA_HIST_SQLTEXT for DBA_HIST_SQLTEXT
/
grant select on DBA_HIST_SQLTEXT to SELECT_CATALOG_ROLE
/


/***************************************
 *       DBA_HIST_SQL_SUMMARY
 ***************************************/

create or replace view DBA_HIST_SQL_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, TOTAL_SQL, TOTAL_SQL_MEM,
   SINGLE_USE_SQL, SINGLE_USE_SQL_MEM)
as
select ss.snap_id, ss.dbid, ss.instance_number, 
       total_sql, total_sql_mem,
       single_use_sql, single_use_sql_mem
from WRM$_SNAPSHOT sn, WRH$_SQL_SUMMARY ss
where     sn.snap_id         = ss.snap_id
      and sn.dbid            = ss.dbid
      and sn.instance_number = ss.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_SQL_SUMMARY is
'Summary of SQL Statistics'
/
create or replace public synonym DBA_HIST_SQL_SUMMARY 
   for DBA_HIST_SQL_SUMMARY
/
grant select on DBA_HIST_SQL_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SQL_PLAN
 ***************************************/

create or replace view DBA_HIST_SQL_PLAN
  (DBID, SQL_ID, PLAN_HASH_VALUE, ID, OPERATION, OPTIONS,
   OBJECT_NODE, OBJECT#, OBJECT_OWNER, OBJECT_NAME,
   OBJECT_ALIAS, OBJECT_TYPE, OPTIMIZER,
   PARENT_ID, DEPTH, POSITION, SEARCH_COLUMNS, COST, CARDINALITY,
   BYTES, OTHER_TAG, PARTITION_START, PARTITION_STOP, PARTITION_ID,
   OTHER, DISTRIBUTION, CPU_COST, IO_COST, TEMP_SPACE, 
   ACCESS_PREDICATES, FILTER_PREDICATES,
   PROJECTION, TIME, QBLOCK_NAME, REMARKS, TIMESTAMP, OTHER_XML)
as
select dbid, sql_id, plan_hash_value, id, operation, options,
       object_node, object#, object_owner, object_name, 
       object_alias, object_type, optimizer,
       parent_id, depth, position, search_columns, cost, cardinality,
       bytes, other_tag, partition_start, partition_stop, partition_id,
       other, distribution, cpu_cost, io_cost, temp_space, 
       access_predicates, filter_predicates,
       projection, time, qblock_name, remarks, timestamp, other_xml
from WRH$_SQL_PLAN
/
comment on table DBA_HIST_SQL_PLAN is
'SQL Plan Information'
/
create or replace public synonym DBA_HIST_SQL_PLAN for DBA_HIST_SQL_PLAN
/
grant select on DBA_HIST_SQL_PLAN to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_SQL_BIND_METADATA
 ***************************************/

create or replace view DBA_HIST_SQL_BIND_METADATA
  (DBID, SQL_ID, NAME, POSITION, DUP_POSITION, 
   DATATYPE, DATATYPE_STRING, 
   CHARACTER_SID, PRECISION, SCALE, MAX_LENGTH)
as
select dbid, sql_id, name, position, dup_position, 
       datatype, datatype_string, 
       character_sid, precision, scale, max_length
  from WRH$_SQL_BIND_METADATA 
/

comment on table DBA_HIST_SQL_BIND_METADATA is
'SQL Bind Metadata Information'
/
create or replace public synonym DBA_HIST_SQL_BIND_METADATA 
  for DBA_HIST_SQL_BIND_METADATA
/
grant select on DBA_HIST_SQL_BIND_METADATA to SELECT_CATALOG_ROLE
/

/***************************************
 *      DBA_HIST_OPTIMIZER_ENV
 ***************************************/

create or replace view DBA_HIST_OPTIMIZER_ENV
  (DBID, OPTIMIZER_ENV_HASH_VALUE, OPTIMIZER_ENV)
as
select dbid, optimizer_env_hash_value, optimizer_env
from WRH$_OPTIMIZER_ENV
/
comment on table DBA_HIST_OPTIMIZER_ENV is
'Optimizer Environment Information'
/
create or replace public synonym DBA_HIST_OPTIMIZER_ENV 
   for DBA_HIST_OPTIMIZER_ENV
/
grant select on DBA_HIST_OPTIMIZER_ENV to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_EVENT_NAME
 ***************************************/

create or replace view DBA_HIST_EVENT_NAME
  (DBID, EVENT_ID, EVENT_NAME, PARAMETER1, PARAMETER2, PARAMETER3, 
   WAIT_CLASS_ID, WAIT_CLASS)
as
select dbid, event_id, event_name, parameter1, parameter2, parameter3, 
       wait_class_id, wait_class
  from WRH$_EVENT_NAME
/

comment on table DBA_HIST_EVENT_NAME is
'Event Names'
/
create or replace public synonym DBA_HIST_EVENT_NAME for DBA_HIST_EVENT_NAME
/
grant select on DBA_HIST_EVENT_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_SYSTEM_EVENT
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_SYSTEM_EVENT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   EVENT_ID, EVENT_NAME, WAIT_CLASS_ID, WAIT_CLASS,
   TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED_MICRO,
   TOTAL_WAITS_FG, TOTAL_TIMEOUTS_FG, TIME_WAITED_MICRO_FG)
as
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       total_waits, total_timeouts, time_waited_micro,
       total_waits_fg, total_timeouts_fg, time_waited_micro_fg
from WRM$_SNAPSHOT sn, WRH$_SYSTEM_EVENT e, 
     DBA_HIST_EVENT_NAME en
where     e.event_id         = en.event_id
      and e.dbid             = en.dbid
      and e.snap_id          = sn.snap_id
      and e.dbid             = sn.dbid
      and e.instance_number  = sn.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_SYSTEM_EVENT is
'System Event Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SYSTEM_EVENT 
    for DBA_HIST_SYSTEM_EVENT
/
grant select on DBA_HIST_SYSTEM_EVENT to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_BG_EVENT_SUMMARY
 ***************************************/

create or replace view DBA_HIST_BG_EVENT_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   EVENT_ID, EVENT_NAME, WAIT_CLASS_ID, WAIT_CLASS,
   TOTAL_WAITS, TOTAL_TIMEOUTS, TIME_WAITED_MICRO) 
as
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       total_waits, total_timeouts, time_waited_micro
from WRM$_SNAPSHOT sn, WRH$_BG_EVENT_SUMMARY e, DBA_HIST_EVENT_NAME en
where     sn.snap_id         = e.snap_id
      and sn.dbid            = e.dbid
      and sn.instance_number = e.instance_number
      and sn.status          = 0
      and e.event_id         = en.event_id
      and e.dbid             = en.dbid
/

comment on table DBA_HIST_BG_EVENT_SUMMARY is
'Summary of Background Event Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BG_EVENT_SUMMARY 
   for DBA_HIST_BG_EVENT_SUMMARY
/
grant select on DBA_HIST_BG_EVENT_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_WAITSTAT
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_WAITSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, CLASS,
   WAIT_COUNT, TIME) 
as
select wt.snap_id, wt.dbid, wt.instance_number, 
       class, wait_count, time
  from wrm$_snapshot sn, WRH$_WAITSTAT wt
  where     sn.snap_id         = wt.snap_id
        and sn.dbid            = wt.dbid
        and sn.instance_number = wt.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_WAITSTAT is
'Wait Historical Statistics Information'
/
create or replace public synonym DBA_HIST_WAITSTAT for DBA_HIST_WAITSTAT
/
grant select on DBA_HIST_WAITSTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_ENQUEUE_STAT
 ***************************************/

create or replace view DBA_HIST_ENQUEUE_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, EQ_TYPE, REQ_REASON, TOTAL_REQ#,
   TOTAL_WAIT#, SUCC_REQ#, FAILED_REQ#, CUM_WAIT_TIME, EVENT#) 
as
select eq.snap_id, eq.dbid, eq.instance_number, 
       eq_type, req_reason, total_req#,
       total_wait#, succ_req#, failed_req#, cum_wait_time, event#
  from wrm$_snapshot sn, WRH$_ENQUEUE_STAT eq
  where     sn.snap_id         = eq.snap_id
        and sn.dbid            = eq.dbid
        and sn.instance_number = eq.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_ENQUEUE_STAT is
'Enqueue Historical Statistics Information'
/
create or replace public synonym DBA_HIST_ENQUEUE_STAT 
    for DBA_HIST_ENQUEUE_STAT
/
grant select on DBA_HIST_ENQUEUE_STAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LATCH_NAME
 ***************************************/

create or replace view DBA_HIST_LATCH_NAME
  (DBID, LATCH_HASH, LATCH_NAME)
as
select dbid, latch_hash, latch_name
from WRH$_LATCH_NAME
/

comment on table DBA_HIST_LATCH_NAME is
'Latch Names'
/
create or replace public synonym DBA_HIST_LATCH_NAME for DBA_HIST_LATCH_NAME
/
grant select on DBA_HIST_LATCH_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LATCH
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_LATCH
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   LATCH_HASH, LATCH_NAME, LEVEL#, GETS,
   MISSES, SLEEPS, IMMEDIATE_GETS, IMMEDIATE_MISSES, SPIN_GETS,
   SLEEP1, SLEEP2, SLEEP3, SLEEP4, WAIT_TIME) 
as
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, level#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time
from WRM$_SNAPSHOT sn, WRH$_LATCH l, DBA_HIST_LATCH_NAME ln
where      l.latch_hash       = ln.latch_hash
      and  l.dbid             = ln.dbid
      and  l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
      and  sn.status          = 0
/

comment on table DBA_HIST_LATCH is
'Latch Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH for DBA_HIST_LATCH
/
grant select on DBA_HIST_LATCH to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_LATCH_CHILDREN
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_LATCH_CHILDREN
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   LATCH_HASH, LATCH_NAME, CHILD#, GETS,
   MISSES, SLEEPS, IMMEDIATE_GETS, IMMEDIATE_MISSES, SPIN_GETS,
   SLEEP1, SLEEP2, SLEEP3, SLEEP4, WAIT_TIME)
as
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, child#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time
from WRM$_SNAPSHOT sn, WRH$_LATCH_CHILDREN l, DBA_HIST_LATCH_NAME ln
where      l.latch_hash       = ln.latch_hash
      and  l.dbid             = ln.dbid
      and  l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
      and  sn.status          = 0
/

comment on table DBA_HIST_LATCH_CHILDREN is
'Latch Children Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH_CHILDREN 
    for DBA_HIST_LATCH_CHILDREN
/
grant select on DBA_HIST_LATCH_CHILDREN to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LATCH_PARENT
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_LATCH_PARENT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   LATCH_HASH, LATCH_NAME, LEVEL#, GETS,
   MISSES, SLEEPS, IMMEDIATE_GETS, IMMEDIATE_MISSES, SPIN_GETS,
   SLEEP1, SLEEP2, SLEEP3, SLEEP4, WAIT_TIME)
as
select l.snap_id, l.dbid, l.instance_number, 
       l.latch_hash, ln.latch_name, level#, 
       gets, misses, sleeps, immediate_gets, immediate_misses, spin_gets,
       sleep1, sleep2, sleep3, sleep4, wait_time
from WRM$_SNAPSHOT sn, WRH$_LATCH_PARENT l, DBA_HIST_LATCH_NAME ln
where      l.latch_hash       = ln.latch_hash
      and  l.dbid             = ln.dbid
      and  l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
      and  sn.status          = 0
/

comment on table DBA_HIST_LATCH_PARENT is
'Latch Parent Historical Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH_PARENT 
    for DBA_HIST_LATCH_PARENT
/
grant select on DBA_HIST_LATCH_PARENT to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_LATCH_MISSES_SUMMARY
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_LATCH_MISSES_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARENT_NAME, WHERE_IN_CODE,
   NWFAIL_COUNT, SLEEP_COUNT, WTR_SLP_COUNT) 
as
select l.snap_id, l.dbid, l.instance_number, parent_name, where_in_code,
       nwfail_count, sleep_count, wtr_slp_count
from WRM$_SNAPSHOT sn, WRH$_LATCH_MISSES_SUMMARY l
where      l.snap_id          = sn.snap_id
      and  l.dbid             = sn.dbid
      and  l.instance_number  = sn.instance_number
      and  sn.status          = 0
/

comment on table DBA_HIST_LATCH_MISSES_SUMMARY is
'Latch Misses Summary Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LATCH_MISSES_SUMMARY 
    for DBA_HIST_LATCH_MISSES_SUMMARY
/
grant select on DBA_HIST_LATCH_MISSES_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_EVENT_HISTOGRAM
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_EVENT_HISTOGRAM
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   EVENT_ID, EVENT_NAME, WAIT_CLASS_ID, WAIT_CLASS,
   WAIT_TIME_MILLI, WAIT_COUNT)
as
select e.snap_id, e.dbid, e.instance_number, 
       e.event_id, en.event_name, en.wait_class_id, en.wait_class,
       e.wait_time_milli, e.wait_count
from WRM$_SNAPSHOT sn, WRH$_EVENT_HISTOGRAM e,
     DBA_HIST_EVENT_NAME en
where     e.event_id         = en.event_id
      and e.dbid             = en.dbid
      and e.snap_id          = sn.snap_id
      and e.dbid             = sn.dbid
      and e.instance_number  = sn.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_EVENT_HISTOGRAM is
'Event Histogram Historical Statistics Information'
/
create or replace public synonym DBA_HIST_EVENT_HISTOGRAM 
    for DBA_HIST_EVENT_HISTOGRAM
/
grant select on DBA_HIST_EVENT_HISTOGRAM to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_MUTEX_SLEEP
 ***************************************/

create or replace view DBA_HIST_MUTEX_SLEEP
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   MUTEX_TYPE, LOCATION, SLEEPS, WAIT_TIME)
as
select m.snap_id, m.dbid, m.instance_number, 
       mutex_type, location, sleeps, wait_time
from WRM$_SNAPSHOT sn, WRH$_MUTEX_SLEEP m
where      m.snap_id          = sn.snap_id
      and  m.dbid             = sn.dbid
      and  m.instance_number  = sn.instance_number
      and  sn.status          = 0
/

comment on table DBA_HIST_MUTEX_SLEEP is
'Mutex Sleep Summary Historical Statistics Information'
/
create or replace public synonym DBA_HIST_MUTEX_SLEEP 
    for DBA_HIST_MUTEX_SLEEP
/
grant select on DBA_HIST_MUTEX_SLEEP to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LIBRARYCACHE
 ***************************************/

create or replace view DBA_HIST_LIBRARYCACHE
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAMESPACE, GETS, 
   GETHITS, PINS, PINHITS, RELOADS, INVALIDATIONS, 
   DLM_LOCK_REQUESTS, DLM_PIN_REQUESTS, DLM_PIN_RELEASES, 
   DLM_INVALIDATION_REQUESTS, DLM_INVALIDATIONS)
as
select lc.snap_id, lc.dbid, lc.instance_number, namespace, gets, 
       gethits, pins, pinhits, reloads, invalidations, 
       dlm_lock_requests, dlm_pin_requests, dlm_pin_releases, 
       dlm_invalidation_requests, dlm_invalidations
  from wrm$_snapshot sn, WRH$_LIBRARYCACHE lc
  where     sn.snap_id         = lc.snap_id
        and sn.dbid            = lc.dbid
        and sn.instance_number = lc.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_LIBRARYCACHE is
'Library Cache Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LIBRARYCACHE 
    for DBA_HIST_LIBRARYCACHE
/
grant select on DBA_HIST_LIBRARYCACHE to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_DB_CACHE_ADVICE
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_DB_CACHE_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, BPID, BUFFERS_FOR_ESTIMATE,
   NAME, BLOCK_SIZE, ADVICE_STATUS, SIZE_FOR_ESTIMATE, 
   SIZE_FACTOR, PHYSICAL_READS, BASE_PHYSICAL_READS,
   ACTUAL_PHYSICAL_READS, ESTD_PHYSICAL_READ_TIME)
as
select db.snap_id, db.dbid, db.instance_number, 
       bpid, buffers_for_estimate,
       name, block_size, advice_status, size_for_estimate, 
       size_factor, physical_reads, base_physical_reads,
       actual_physical_reads, estd_physical_read_time
from WRM$_SNAPSHOT sn, WRH$_DB_CACHE_ADVICE db
where      db.snap_id          = sn.snap_id
      and  db.dbid             = sn.dbid
      and  db.instance_number  = sn.instance_number
      and  sn.status           = 0
/

comment on table DBA_HIST_DB_CACHE_ADVICE is
'DB Cache Advice History Information'
/
create or replace public synonym DBA_HIST_DB_CACHE_ADVICE
    for DBA_HIST_DB_CACHE_ADVICE
/
grant select on DBA_HIST_DB_CACHE_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_BUFFER_POOL_STAT
 ***************************************/

create or replace view DBA_HIST_BUFFER_POOL_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, ID, NAME, BLOCK_SIZE, SET_MSIZE,
   CNUM_REPL, CNUM_WRITE, CNUM_SET, BUF_GOT, SUM_WRITE, SUM_SCAN,
   FREE_BUFFER_WAIT, WRITE_COMPLETE_WAIT, BUFFER_BUSY_WAIT,
   FREE_BUFFER_INSPECTED, DIRTY_BUFFERS_INSPECTED,
   DB_BLOCK_CHANGE, DB_BLOCK_GETS, CONSISTENT_GETS,
   PHYSICAL_READS, PHYSICAL_WRITES) 
as
select bp.snap_id, bp.dbid, bp.instance_number, 
       id, name, block_size, set_msize,
       cnum_repl, cnum_write, cnum_set, buf_got, sum_write, sum_scan,
       free_buffer_wait, write_complete_wait, buffer_busy_wait,
       free_buffer_inspected, dirty_buffers_inspected,
       db_block_change, db_block_gets, consistent_gets,
       physical_reads, physical_writes
  from WRM$_SNAPSHOT sn, WRH$_BUFFER_POOL_STATISTICS bp
  where     sn.snap_id         = bp.snap_id
        and sn.dbid            = bp.dbid
        and sn.instance_number = bp.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_BUFFER_POOL_STAT is
'Buffer Pool Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BUFFER_POOL_STAT
    for DBA_HIST_BUFFER_POOL_STAT
/
grant select on DBA_HIST_BUFFER_POOL_STAT to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_ROWCACHE_SUMMARY
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_ROWCACHE_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARAMETER, TOTAL_USAGE,
   USAGE, GETS, GETMISSES, SCANS, SCANMISSES, SCANCOMPLETES,
   MODIFICATIONS, FLUSHES, DLM_REQUESTS, DLM_CONFLICTS, 
   DLM_RELEASES)
as
select rc.snap_id, rc.dbid, rc.instance_number, 
       parameter, total_usage,
       usage, gets, getmisses, scans, scanmisses, scancompletes,
       modifications, flushes, dlm_requests, dlm_conflicts, 
       dlm_releases
  from WRM$_SNAPSHOT sn, WRH$_ROWCACHE_SUMMARY rc
  where     sn.snap_id         = rc.snap_id
        and sn.dbid            = rc.dbid
        and sn.instance_number = rc.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_ROWCACHE_SUMMARY is
'Row Cache Historical Statistics Information Summary'
/
create or replace public synonym DBA_HIST_ROWCACHE_SUMMARY
    for DBA_HIST_ROWCACHE_SUMMARY
/
grant select on DBA_HIST_ROWCACHE_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SGA
 ***************************************/

create or replace view DBA_HIST_SGA
 (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, VALUE)
as
select sga.snap_id, sga.dbid, sga.instance_number, name, value
  from wrm$_snapshot sn, WRH$_SGA sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SGA is
'SGA Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SGA for DBA_HIST_SGA
/
grant select on DBA_HIST_SGA to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SGASTAT
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_SGASTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, POOL, BYTES) 
as
select sga.snap_id, sga.dbid, sga.instance_number, name, pool, bytes
  from wrm$_snapshot sn, WRH$_SGASTAT sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SGASTAT is
'SGA Pool Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SGASTAT for DBA_HIST_SGASTAT
/
grant select on DBA_HIST_SGASTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_PGASTAT
 ***************************************/

create or replace view DBA_HIST_PGASTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, VALUE) 
as
select pga.snap_id, pga.dbid, pga.instance_number, name, value
  from wrm$_snapshot sn, WRH$_PGASTAT pga
  where     sn.snap_id         = pga.snap_id
        and sn.dbid            = pga.dbid
        and sn.instance_number = pga.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_PGASTAT is
'PGA Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PGASTAT for DBA_HIST_PGASTAT
/
grant select on DBA_HIST_PGASTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *   DBA_HIST_PROCESS_MEM_SUMMARY
 ***************************************/

create or replace view DBA_HIST_PROCESS_MEM_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   CATEGORY, NUM_PROCESSES, NON_ZERO_ALLOCS, 
   USED_TOTAL, ALLOCATED_TOTAL, ALLOCATED_AVG, 
   ALLOCATED_STDDEV, ALLOCATED_MAX, MAX_ALLOCATED_MAX)
as
select pmem.snap_id, pmem.dbid, pmem.instance_number,
       category, num_processes, non_zero_allocs, 
       used_total, allocated_total, allocated_total / num_processes, 
       allocated_stddev, allocated_max, max_allocated_max
  from wrm$_snapshot sn, WRH$_PROCESS_MEMORY_SUMMARY pmem
  where     sn.snap_id         = pmem.snap_id
        and sn.dbid            = pmem.dbid
        and sn.instance_number = pmem.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_PROCESS_MEM_SUMMARY is
'Process Memory Historical Summary Information'
/
create or replace public synonym DBA_HIST_PROCESS_MEM_SUMMARY 
   for DBA_HIST_PROCESS_MEM_SUMMARY
/
grant select on DBA_HIST_PROCESS_MEM_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_RESOURCE_LIMIT
 ***************************************/

create or replace view DBA_HIST_RESOURCE_LIMIT
  (SNAP_ID, DBID, INSTANCE_NUMBER, RESOURCE_NAME, 
   CURRENT_UTILIZATION, MAX_UTILIZATION, INITIAL_ALLOCATION,
   LIMIT_VALUE)
as
select rl.snap_id, rl.dbid, rl.instance_number, resource_name, 
       current_utilization, max_utilization, initial_allocation,
       limit_value
  from wrm$_snapshot sn, WRH$_RESOURCE_LIMIT rl
  where     sn.snap_id         = rl.snap_id
        and sn.dbid            = rl.dbid
        and sn.instance_number = rl.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_RESOURCE_LIMIT is
'Resource Limit Historical Statistics Information'
/
create or replace public synonym DBA_HIST_RESOURCE_LIMIT 
    for DBA_HIST_RESOURCE_LIMIT
/
grant select on DBA_HIST_RESOURCE_LIMIT to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_SHARED_POOL_ADVICE
 ***************************************/

create or replace view DBA_HIST_SHARED_POOL_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, SHARED_POOL_SIZE_FOR_ESTIMATE,
   SHARED_POOL_SIZE_FACTOR, ESTD_LC_SIZE, ESTD_LC_MEMORY_OBJECTS,
   ESTD_LC_TIME_SAVED, ESTD_LC_TIME_SAVED_FACTOR, 
   ESTD_LC_LOAD_TIME, ESTD_LC_LOAD_TIME_FACTOR, 
   ESTD_LC_MEMORY_OBJECT_HITS) 
as
select sp.snap_id, sp.dbid, sp.instance_number, 
       shared_pool_size_for_estimate,
       shared_pool_size_factor, estd_lc_size, estd_lc_memory_objects,
       estd_lc_time_saved, estd_lc_time_saved_factor, 
       estd_lc_load_time, estd_lc_load_time_factor, 
       estd_lc_memory_object_hits
  from wrm$_snapshot sn, WRH$_SHARED_POOL_ADVICE sp
  where     sn.snap_id         = sp.snap_id
        and sn.dbid            = sp.dbid
        and sn.instance_number = sp.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SHARED_POOL_ADVICE is
'Shared Pool Advice History'
/
create or replace public synonym DBA_HIST_SHARED_POOL_ADVICE 
    for DBA_HIST_SHARED_POOL_ADVICE
/
grant select on DBA_HIST_SHARED_POOL_ADVICE to SELECT_CATALOG_ROLE
/

/***************************************
 *    DBA_HIST_STREAMS_POOL_ADVICE
 ***************************************/

create or replace view DBA_HIST_STREAMS_POOL_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, SIZE_FOR_ESTIMATE,
   SIZE_FACTOR, ESTD_SPILL_COUNT, ESTD_SPILL_TIME,
   ESTD_UNSPILL_COUNT, ESTD_UNSPILL_TIME) 
as
select sp.snap_id, sp.dbid, sp.instance_number, 
       size_for_estimate, size_factor, 
       estd_spill_count, estd_spill_time, 
       estd_unspill_count, estd_unspill_time     
  from wrm$_snapshot sn, WRH$_STREAMS_POOL_ADVICE sp
  where     sn.snap_id         = sp.snap_id
        and sn.dbid            = sp.dbid
        and sn.instance_number = sp.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_STREAMS_POOL_ADVICE is
'Streams Pool Advice History'
/
create or replace public synonym DBA_HIST_STREAMS_POOL_ADVICE 
    for DBA_HIST_STREAMS_POOL_ADVICE
/
grant select on DBA_HIST_STREAMS_POOL_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_SQL_WORKAREA_HSTGRM
 ***************************************/

create or replace view DBA_HIST_SQL_WORKAREA_HSTGRM
  (SNAP_ID, DBID, INSTANCE_NUMBER, LOW_OPTIMAL_SIZE, 
   HIGH_OPTIMAL_SIZE, OPTIMAL_EXECUTIONS, ONEPASS_EXECUTIONS,
   MULTIPASSES_EXECUTIONS, TOTAL_EXECUTIONS) 
as
select swh.snap_id, swh.dbid, swh.instance_number, low_optimal_size, 
       high_optimal_size, optimal_executions, onepass_executions,
       multipasses_executions, total_executions
  from wrm$_snapshot sn, WRH$_SQL_WORKAREA_HISTOGRAM swh
  where     sn.snap_id         = swh.snap_id
        and sn.dbid            = swh.dbid
        and sn.instance_number = swh.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SQL_WORKAREA_HSTGRM is
'SQL Workarea Histogram History'
/
create or replace public synonym DBA_HIST_SQL_WORKAREA_HSTGRM 
    for DBA_HIST_SQL_WORKAREA_HSTGRM
/
grant select on DBA_HIST_SQL_WORKAREA_HSTGRM to SELECT_CATALOG_ROLE
/


/***************************************
 *     DBA_HIST_PGA_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_PGA_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, PGA_TARGET_FOR_ESTIMATE,
   PGA_TARGET_FACTOR, ADVICE_STATUS, BYTES_PROCESSED,
   ESTD_TIME, ESTD_EXTRA_BYTES_RW, 
   ESTD_PGA_CACHE_HIT_PERCENTAGE, ESTD_OVERALLOC_COUNT)
as
select pga.snap_id, pga.dbid, pga.instance_number, 
       pga_target_for_estimate,
       pga_target_factor, advice_status, bytes_processed,
       estd_time, estd_extra_bytes_rw, 
       estd_pga_cache_hit_percentage, estd_overalloc_count
  from wrm$_snapshot sn, WRH$_PGA_TARGET_ADVICE pga
  where     sn.snap_id         = pga.snap_id
        and sn.dbid            = pga.dbid
        and sn.instance_number = pga.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_PGA_TARGET_ADVICE is
'PGA Target Advice History'
/
create or replace public synonym DBA_HIST_PGA_TARGET_ADVICE
    for DBA_HIST_PGA_TARGET_ADVICE
/
grant select on DBA_HIST_PGA_TARGET_ADVICE to SELECT_CATALOG_ROLE
/

/***************************************
 *     DBA_HIST_SGA_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_SGA_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, SGA_SIZE, SGA_SIZE_FACTOR,
   ESTD_DB_TIME, ESTD_PHYSICAL_READS)
as
select sga.snap_id, sga.dbid, sga.instance_number, 
       sga.sga_size, sga.sga_size_factor, sga.estd_db_time,   
       sga.estd_physical_reads
  from wrm$_snapshot sn, WRH$_SGA_TARGET_ADVICE sga
  where     sn.snap_id         = sga.snap_id
        and sn.dbid            = sga.dbid
        and sn.instance_number = sga.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SGA_TARGET_ADVICE is
'SGA Target Advice History'
/
create or replace public synonym DBA_HIST_SGA_TARGET_ADVICE
    for DBA_HIST_SGA_TARGET_ADVICE
/
grant select on DBA_HIST_SGA_TARGET_ADVICE to SELECT_CATALOG_ROLE
/

/***************************************
 *   DBA_HIST_MEMORY_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_MEMORY_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   MEMORY_SIZE, MEMORY_SIZE_FACTOR, ESTD_DB_TIME, 
   ESTD_DB_TIME_FACTOR, VERSION)
as
select mem.snap_id, mem.dbid, mem.instance_number, 
       memory_size, memory_size_factor, 
       estd_db_time, estd_db_time_factor, version
  from wrm$_snapshot sn, WRH$_MEMORY_TARGET_ADVICE mem
  where     sn.snap_id         = mem.snap_id
        and sn.dbid            = mem.dbid
        and sn.instance_number = mem.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_MEMORY_TARGET_ADVICE is
'Memory Target Advice History'
/
create or replace public synonym DBA_HIST_MEMORY_TARGET_ADVICE
    for DBA_HIST_MEMORY_TARGET_ADVICE
/
grant select on DBA_HIST_MEMORY_TARGET_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_MEMORY_RESIZE_OPS
 ***************************************/

create or replace view DBA_HIST_MEMORY_RESIZE_OPS
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   COMPONENT, OPER_TYPE, START_TIME, END_TIME,
   TARGET_SIZE, OPER_MODE, PARAMETER, INITIAL_SIZE,
   FINAL_SIZE, STATUS)
as
select mro.snap_id, mro.dbid, mro.instance_number, 
       component, oper_type, start_time, end_time,
       target_size, oper_mode, parameter, initial_size,
       final_size, mro.status
  from wrm$_snapshot sn, WRH$_MEMORY_RESIZE_OPS mro
  where     sn.snap_id         = mro.snap_id
        and sn.dbid            = mro.dbid
        and sn.instance_number = mro.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_MEMORY_RESIZE_OPS is
'Memory Resize Operations History'
/
create or replace public synonym DBA_HIST_MEMORY_RESIZE_OPS
    for DBA_HIST_MEMORY_RESIZE_OPS
/
grant select on DBA_HIST_MEMORY_RESIZE_OPS to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_INSTANCE_RECOVERY
 ***************************************/

create or replace view DBA_HIST_INSTANCE_RECOVERY
  (SNAP_ID, DBID, INSTANCE_NUMBER, RECOVERY_ESTIMATED_IOS,
   ACTUAL_REDO_BLKS, TARGET_REDO_BLKS, LOG_FILE_SIZE_REDO_BLKS,
   LOG_CHKPT_TIMEOUT_REDO_BLKS, LOG_CHKPT_INTERVAL_REDO_BLKS,
   FAST_START_IO_TARGET_REDO_BLKS, TARGET_MTTR, ESTIMATED_MTTR,
   CKPT_BLOCK_WRITES, OPTIMAL_LOGFILE_SIZE, ESTD_CLUSTER_AVAILABLE_TIME,
   WRITES_MTTR, WRITES_LOGFILE_SIZE, WRITES_LOG_CHECKPOINT_SETTINGS,
   WRITES_OTHER_SETTINGS, WRITES_AUTOTUNE, WRITES_FULL_THREAD_CKPT)
as
select ir.snap_id, ir.dbid, ir.instance_number, recovery_estimated_ios,
       actual_redo_blks, target_redo_blks, log_file_size_redo_blks,
       log_chkpt_timeout_redo_blks, log_chkpt_interval_redo_blks,
       fast_start_io_target_redo_blks, target_mttr, estimated_mttr,
       ckpt_block_writes, optimal_logfile_size, estd_cluster_available_time,
       writes_mttr, writes_logfile_size, writes_log_checkpoint_settings,
       writes_other_settings, writes_autotune, writes_full_thread_ckpt
  from wrm$_snapshot sn, WRH$_INSTANCE_RECOVERY ir
  where     sn.snap_id         = ir.snap_id
        and sn.dbid            = ir.dbid
        and sn.instance_number = ir.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_INSTANCE_RECOVERY is
'Instance Recovery Historical Statistics Information'
/
create or replace public synonym DBA_HIST_INSTANCE_RECOVERY 
    for DBA_HIST_INSTANCE_RECOVERY
/
grant select on DBA_HIST_INSTANCE_RECOVERY to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_JAVA_POOL_ADVICE
 ***************************************/

create or replace view DBA_HIST_JAVA_POOL_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   JAVA_POOL_SIZE_FOR_ESTIMATE, JAVA_POOL_SIZE_FACTOR, 
   ESTD_LC_SIZE, ESTD_LC_MEMORY_OBJECTS, 
   ESTD_LC_TIME_SAVED, ESTD_LC_TIME_SAVED_FACTOR,
   ESTD_LC_LOAD_TIME, ESTD_LC_LOAD_TIME_FACTOR, 
   ESTD_LC_MEMORY_OBJECT_HITS)
as
select jp.snap_id, jp.dbid, jp.instance_number, 
       java_pool_size_for_estimate, java_pool_size_factor, 
       estd_lc_size, estd_lc_memory_objects, 
       estd_lc_time_saved, estd_lc_time_saved_factor,
       estd_lc_load_time, estd_lc_load_time_factor, 
       estd_lc_memory_object_hits
  from wrm$_snapshot sn, WRH$_JAVA_POOL_ADVICE jp
  where     sn.snap_id         = jp.snap_id
        and sn.dbid            = jp.dbid
        and sn.instance_number = jp.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_JAVA_POOL_ADVICE is
'Java Pool Advice History'
/
create or replace public synonym DBA_HIST_JAVA_POOL_ADVICE 
    for DBA_HIST_JAVA_POOL_ADVICE
/
grant select on DBA_HIST_JAVA_POOL_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_THREAD
 ***************************************/

create or replace view DBA_HIST_THREAD
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   THREAD#, THREAD_INSTANCE_NUMBER, STATUS,
   OPEN_TIME, CURRENT_GROUP#, SEQUENCE#)
as
select th.snap_id, th.dbid, th.instance_number, 
       thread#, thread_instance_number, th.status,
       open_time, current_group#, sequence#
  from wrm$_snapshot sn, WRH$_THREAD th
  where     sn.snap_id         = th.snap_id
        and sn.dbid            = th.dbid
        and sn.instance_number = th.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_THREAD is
'Thread Historical Statistics Information'
/
create or replace public synonym DBA_HIST_THREAD 
    for DBA_HIST_THREAD
/
grant select on DBA_HIST_THREAD to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_STAT_NAME
 ***************************************/

create or replace view DBA_HIST_STAT_NAME
  (DBID, STAT_ID, STAT_NAME)
as
select dbid, stat_id, stat_name
from WRH$_STAT_NAME
/

comment on table DBA_HIST_STAT_NAME is
'Statistic Names'
/
create or replace public synonym DBA_HIST_STAT_NAME for DBA_HIST_STAT_NAME
/
grant select on DBA_HIST_STAT_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SYSSTAT
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_SYSSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   STAT_ID, STAT_NAME, VALUE) 
as
select s.snap_id, s.dbid, s.instance_number, 
       s.stat_id, nm.stat_name, value
from WRM$_SNAPSHOT sn, WRH$_SYSSTAT s, DBA_HIST_STAT_NAME nm
where      s.stat_id          = nm.stat_id
      and  s.dbid             = nm.dbid
      and  s.snap_id          = sn.snap_id
      and  s.dbid             = sn.dbid
      and  s.instance_number  = sn.instance_number
      and  sn.status          = 0
/

comment on table DBA_HIST_SYSSTAT is
'System Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SYSSTAT for DBA_HIST_SYSSTAT
/
grant select on DBA_HIST_SYSSTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SYS_TIME_MODEL
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_SYS_TIME_MODEL
  (SNAP_ID, DBID, INSTANCE_NUMBER, STAT_ID, STAT_NAME, VALUE) 
as
select s.snap_id, s.dbid, s.instance_number, s.stat_id, 
       nm.stat_name, value
from WRM$_SNAPSHOT sn, WRH$_SYS_TIME_MODEL s, DBA_HIST_STAT_NAME nm
where      s.stat_id          = nm.stat_id
      and  s.dbid             = nm.dbid
      and  s.snap_id          = sn.snap_id
      and  s.dbid             = sn.dbid
      and  s.instance_number  = sn.instance_number
      and  sn.status          = 0
/

comment on table DBA_HIST_SYS_TIME_MODEL is
'System Time Model Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SYS_TIME_MODEL 
   for DBA_HIST_SYS_TIME_MODEL
/
grant select on DBA_HIST_SYS_TIME_MODEL to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_OSSTAT_NAME
 ***************************************/

create or replace view DBA_HIST_OSSTAT_NAME
  (DBID, STAT_ID, STAT_NAME)
as
select dbid, stat_id, stat_name
from WRH$_OSSTAT_NAME
/

comment on table DBA_HIST_OSSTAT_NAME is
'Operating System Statistic Names'
/
create or replace public synonym DBA_HIST_OSSTAT_NAME 
  for DBA_HIST_OSSTAT_NAME
/
grant select on DBA_HIST_OSSTAT_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_OSSTAT
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_OSSTAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, STAT_ID, STAT_NAME, VALUE) 
as
select s.snap_id, s.dbid, s.instance_number, s.stat_id, 
       nm.stat_name, value
from WRM$_SNAPSHOT sn, WRH$_OSSTAT s, DBA_HIST_OSSTAT_NAME nm
where     s.stat_id          = nm.stat_id
      and s.dbid             = nm.dbid
      and s.snap_id          = sn.snap_id
      and s.dbid             = sn.dbid
      and s.instance_number  = sn.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_OSSTAT is
'Operating System Historical Statistics Information'
/
create or replace public synonym DBA_HIST_OSSTAT 
   for DBA_HIST_OSSTAT
/
grant select on DBA_HIST_OSSTAT to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_PARAMETER_NAME
 ***************************************/

create or replace view DBA_HIST_PARAMETER_NAME
  (DBID, PARAMETER_HASH, PARAMETER_NAME)
as
select dbid, parameter_hash, parameter_name
from WRH$_PARAMETER_NAME 
where (translate(parameter_name,'_','#') not like '#%')
/

comment on table DBA_HIST_PARAMETER_NAME is
'Parameter Names'
/
create or replace public synonym DBA_HIST_PARAMETER_NAME 
    for DBA_HIST_PARAMETER_NAME
/
grant select on DBA_HIST_PARAMETER_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_PARAMETER
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_PARAMETER
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARAMETER_HASH,
   PARAMETER_NAME, VALUE, ISDEFAULT, ISMODIFIED)
as
select p.snap_id, p.dbid, p.instance_number, 
       p.parameter_hash, pn.parameter_name, 
       value, isdefault, ismodified
from WRM$_SNAPSHOT sn, WRH$_PARAMETER p, WRH$_PARAMETER_NAME pn
where     p.parameter_hash   = pn.parameter_hash
      and p.dbid             = pn.dbid
      and p.snap_id          = sn.snap_id
      and p.dbid             = sn.dbid
      and p.instance_number  = sn.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_PARAMETER is
'Parameter Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PARAMETER 
    for DBA_HIST_PARAMETER
/
grant select on DBA_HIST_PARAMETER to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_MVPARAMETER
 ***************************************/

create or replace view DBA_HIST_MVPARAMETER
  (SNAP_ID, DBID, INSTANCE_NUMBER, PARAMETER_HASH,
   PARAMETER_NAME, ORDINAL, VALUE, ISDEFAULT, ISMODIFIED)
as
select mp.snap_id, mp.dbid, mp.instance_number, 
       mp.parameter_hash, pn.parameter_name, 
       mp.ordinal, mp.value, mp.isdefault, mp.ismodified
from WRM$_SNAPSHOT sn, WRH$_MVPARAMETER mp, WRH$_PARAMETER_NAME pn
where     mp.parameter_hash   = pn.parameter_hash
      and mp.dbid             = pn.dbid
      and mp.snap_id          = sn.snap_id
      and mp.dbid             = sn.dbid
      and mp.instance_number  = sn.instance_number
      and sn.status           = 0
/

comment on table DBA_HIST_MVPARAMETER is
'Multi-valued Parameter Historical Statistics Information'
/
create or replace public synonym DBA_HIST_MVPARAMETER 
    for DBA_HIST_MVPARAMETER
/
grant select on DBA_HIST_MVPARAMETER to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_UNDOSTAT
 ***************************************/

create or replace view DBA_HIST_UNDOSTAT
  (BEGIN_TIME, END_TIME, DBID, INSTANCE_NUMBER, SNAP_ID, UNDOTSN,
   UNDOBLKS, TXNCOUNT, MAXQUERYLEN, MAXQUERYSQLID,
   MAXCONCURRENCY, UNXPSTEALCNT, UNXPBLKRELCNT, UNXPBLKREUCNT, 
   EXPSTEALCNT, EXPBLKRELCNT, EXPBLKREUCNT, SSOLDERRCNT, 
   NOSPACEERRCNT, ACTIVEBLKS, UNEXPIREDBLKS, EXPIREDBLKS,
   TUNED_UNDORETENTION)
as
select begin_time, end_time, ud.dbid, ud.instance_number, 
       ud.snap_id, undotsn,
       undoblks, txncount, maxquerylen, maxquerysqlid,
       maxconcurrency, unxpstealcnt, unxpblkrelcnt, unxpblkreucnt, 
       expstealcnt, expblkrelcnt, expblkreucnt, ssolderrcnt, 
       nospaceerrcnt, activeblks, unexpiredblks, expiredblks,
       tuned_undoretention
  from wrm$_snapshot sn, WRH$_UNDOSTAT ud
  where     sn.snap_id         = ud.snap_id
        and sn.dbid            = ud.dbid
        and sn.instance_number = ud.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_UNDOSTAT is
'Undo Historical Statistics Information'
/
create or replace public synonym DBA_HIST_UNDOSTAT 
    for DBA_HIST_UNDOSTAT
/
grant select on DBA_HIST_UNDOSTAT to SELECT_CATALOG_ROLE
/


/*****************************************************************************
 *   DBA_HIST_SEG_STAT
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 * 
 * Note: In WRH$_SEG_STAT, we have renamed the GC CR/Current Blocks 
 *       Served columns to GC CR/Current Blocks Received.  For 
 *       compatibility reasons, we will keep the Served columns 
 *       in the DBA_HIST_SEG_STAT view in case any product has a
 *       dependency on the column name.  We will remove this column
 *       after two releases (remove in release 12).
 *
 *       To obsolete the columns, simply remove the following:
 *          GC_CR_BLOCKS_SERVED_TOTAL, GC_CR_BLOCKS_SERVED_DELTA,
 *          GC_CU_BLOCKS_SERVED_TOTAL, GC_CU_BLOCKS_SERVED_DELTA,
 *****************************************************************************/

create or replace view DBA_HIST_SEG_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, TS#, OBJ#, DATAOBJ#, 
   LOGICAL_READS_TOTAL, LOGICAL_READS_DELTA,
   BUFFER_BUSY_WAITS_TOTAL, BUFFER_BUSY_WAITS_DELTA,
   DB_BLOCK_CHANGES_TOTAL, DB_BLOCK_CHANGES_DELTA,
   PHYSICAL_READS_TOTAL, PHYSICAL_READS_DELTA, 
   PHYSICAL_WRITES_TOTAL, PHYSICAL_WRITES_DELTA,
   PHYSICAL_READS_DIRECT_TOTAL, PHYSICAL_READS_DIRECT_DELTA,
   PHYSICAL_WRITES_DIRECT_TOTAL, PHYSICAL_WRITES_DIRECT_DELTA,
   ITL_WAITS_TOTAL, ITL_WAITS_DELTA,
   ROW_LOCK_WAITS_TOTAL, ROW_LOCK_WAITS_DELTA, 
   GC_CR_BLOCKS_SERVED_TOTAL, GC_CR_BLOCKS_SERVED_DELTA,
   GC_CU_BLOCKS_SERVED_TOTAL, GC_CU_BLOCKS_SERVED_DELTA,
   GC_BUFFER_BUSY_TOTAL, GC_BUFFER_BUSY_DELTA,
   GC_CR_BLOCKS_RECEIVED_TOTAL, GC_CR_BLOCKS_RECEIVED_DELTA,
   GC_CU_BLOCKS_RECEIVED_TOTAL, GC_CU_BLOCKS_RECEIVED_DELTA,
   SPACE_USED_TOTAL, SPACE_USED_DELTA,
   SPACE_ALLOCATED_TOTAL, SPACE_ALLOCATED_DELTA,
   TABLE_SCANS_TOTAL, TABLE_SCANS_DELTA,
   CHAIN_ROW_EXCESS_TOTAL, CHAIN_ROW_EXCESS_DELTA,
   PHYSICAL_READ_REQUESTS_TOTAL, PHYSICAL_READ_REQUESTS_DELTA,
   PHYSICAL_WRITE_REQUESTS_TOTAL, PHYSICAL_WRITE_REQUESTS_DELTA,
   OPTIMIZED_PHYSICAL_READS_TOTAL, OPTIMIZED_PHYSICAL_READS_DELTA)
as
select seg.snap_id, seg.dbid, seg.instance_number, ts#, obj#, dataobj#, 
       logical_reads_total, logical_reads_delta,
       buffer_busy_waits_total, buffer_busy_waits_delta,
       db_block_changes_total, db_block_changes_delta,
       physical_reads_total, physical_reads_delta, 
       physical_writes_total, physical_writes_delta,
       physical_reads_direct_total, physical_reads_direct_delta,
       physical_writes_direct_total, physical_writes_direct_delta,
       itl_waits_total, itl_waits_delta,
       row_lock_waits_total, row_lock_waits_delta, 
       gc_cr_blocks_received_total, gc_cr_blocks_received_delta,
       gc_cu_blocks_received_total, gc_cu_blocks_received_delta,
       gc_buffer_busy_total, gc_buffer_busy_delta,
       gc_cr_blocks_received_total, gc_cr_blocks_received_delta,
       gc_cu_blocks_received_total, gc_cu_blocks_received_delta,
       space_used_total, space_used_delta,
       space_allocated_total, space_allocated_delta,
       table_scans_total, table_scans_delta,
       chain_row_excess_total, chain_row_excess_delta,
       physical_read_requests_total, physical_read_requests_delta,
       physical_write_requests_total, physical_write_requests_delta,
       optimized_physical_reads_total, optimized_physical_reads_delta
from WRM$_SNAPSHOT sn, WRH$_SEG_STAT seg
where     seg.snap_id         = sn.snap_id
      and seg.dbid            = sn.dbid
      and seg.instance_number = sn.instance_number
      and sn.status           = 0
/

comment on table DBA_HIST_SEG_STAT is
' Historical Statistics Information'
/
create or replace public synonym DBA_HIST_SEG_STAT 
    for DBA_HIST_SEG_STAT
/
grant select on DBA_HIST_SEG_STAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_SEG_STAT_OBJ
 ***************************************/

create or replace view DBA_HIST_SEG_STAT_OBJ
  (DBID, TS#, OBJ#, DATAOBJ#, OWNER, OBJECT_NAME, 
   SUBOBJECT_NAME, OBJECT_TYPE, TABLESPACE_NAME, PARTITION_TYPE)
as
select dbid, ts#, obj#, dataobj#, owner, object_name, 
       subobject_name, object_type, 
       coalesce(tsname, tablespace_name) tablespace_name,
       partition_type
from WRH$_SEG_STAT_OBJ so LEFT OUTER JOIN WRH$_TABLESPACE ts USING (dbid, ts#)
/
comment on table DBA_HIST_SEG_STAT_OBJ is
'Segment Names'
/
create or replace public synonym DBA_HIST_SEG_STAT_OBJ 
    for DBA_HIST_SEG_STAT_OBJ
/
grant select on DBA_HIST_SEG_STAT_OBJ to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_METRIC_NAME
 ***************************************/

/* The Metric Id will remain the same across releases */
create or replace view DBA_HIST_METRIC_NAME
  (DBID, GROUP_ID, GROUP_NAME, METRIC_ID, METRIC_NAME, METRIC_UNIT)
as
select dbid, group_id, group_name, metric_id, metric_name, metric_unit
from WRH$_METRIC_NAME
/
comment on table DBA_HIST_METRIC_NAME is
'Segment Names'
/
create or replace public synonym DBA_HIST_METRIC_NAME
    for DBA_HIST_METRIC_NAME
/
grant select on DBA_HIST_METRIC_NAME to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_SYSMETRIC_HISTORY
 ***************************************/

create or replace view DBA_HIST_SYSMETRIC_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, INTSIZE,
   GROUP_ID, METRIC_ID, METRIC_NAME, VALUE, METRIC_UNIT)
as
select m.snap_id, m.dbid, m.instance_number, 
       begin_time, end_time, intsize,
       m.group_id, m.metric_id, mn.metric_name, value, mn.metric_unit
from wrm$_snapshot sn, WRH$_SYSMETRIC_HISTORY m, DBA_HIST_METRIC_NAME mn
where       m.group_id       = mn.group_id
      and   m.metric_id      = mn.metric_id
      and   m.dbid           = mn.dbid
      and   sn.snap_id       = m.snap_id
      and sn.dbid            = m.dbid
      and sn.instance_number = m.instance_number
      and sn.status          = 0
/

comment on table DBA_HIST_SYSMETRIC_HISTORY is
'System Metrics History'
/
create or replace public synonym DBA_HIST_SYSMETRIC_HISTORY 
    for DBA_HIST_SYSMETRIC_HISTORY
/
grant select on DBA_HIST_SYSMETRIC_HISTORY to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_SYSMETRIC_SUMMARY
 ***************************************/

create or replace view DBA_HIST_SYSMETRIC_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, INTSIZE,
   GROUP_ID, METRIC_ID, METRIC_NAME, METRIC_UNIT, NUM_INTERVAL, 
   MINVAL, MAXVAL, AVERAGE, STANDARD_DEVIATION, SUM_SQUARES)
as
select m.snap_id, m.dbid, m.instance_number, 
       begin_time, end_time, intsize,
       m.group_id, m.metric_id, mn.metric_name, mn.metric_unit, 
       num_interval, minval, maxval, average, standard_deviation, sum_squares
  from wrm$_snapshot sn, WRH$_SYSMETRIC_SUMMARY m, DBA_HIST_METRIC_NAME mn
  where     m.group_id         = mn.group_id
        and m.metric_id        = mn.metric_id
        and m.dbid             = mn.dbid
        and sn.snap_id         = m.snap_id
        and sn.dbid            = m.dbid
        and sn.instance_number = m.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SYSMETRIC_SUMMARY is
'System Metrics History'
/
create or replace public synonym DBA_HIST_SYSMETRIC_SUMMARY 
    for DBA_HIST_SYSMETRIC_SUMMARY
/
grant select on DBA_HIST_SYSMETRIC_SUMMARY to SELECT_CATALOG_ROLE
/


/***************************************
 *   DBA_HIST_SESSMETRIC_HISTORY
 ***************************************/

create or replace view DBA_HIST_SESSMETRIC_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, BEGIN_TIME, END_TIME, SESSID,
   SERIAL#, INTSIZE, GROUP_ID, METRIC_ID, METRIC_NAME, VALUE, METRIC_UNIT)
as
select m.snap_id, m.dbid, m.instance_number, begin_time, end_time, sessid,
       serial#, intsize, m.group_id, m.metric_id, mn.metric_name, 
       value, mn.metric_unit
  from wrm$_snapshot sn, WRH$_SESSMETRIC_HISTORY m, DBA_HIST_METRIC_NAME mn
  where     m.group_id         = mn.group_id
        and m.metric_id        = mn.metric_id
        and m.dbid             = mn.dbid
        and sn.snap_id         = m.snap_id
        and sn.dbid            = m.dbid
        and sn.instance_number = m.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_SESSMETRIC_HISTORY is
'System Metrics History'
/
create or replace public synonym DBA_HIST_SESSMETRIC_HISTORY 
    for DBA_HIST_SESSMETRIC_HISTORY
/
grant select on DBA_HIST_SESSMETRIC_HISTORY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_FILEMETRIC_HISTORY
 ***************************************/

create or replace view DBA_HIST_FILEMETRIC_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, FILEID, CREATIONTIME, BEGIN_TIME,
   END_TIME, INTSIZE, GROUP_ID, AVGREADTIME, AVGWRITETIME, PHYSICALREAD,
   PHYSICALWRITE, PHYBLKREAD, PHYBLKWRITE)
as
select fm.snap_id, fm.dbid, fm.instance_number, 
       fileid, creationtime, begin_time,
       end_time, intsize, group_id, avgreadtime, avgwritetime, 
       physicalread, physicalwrite, phyblkread, phyblkwrite
  from wrm$_snapshot sn, WRH$_FILEMETRIC_HISTORY fm
  where     sn.snap_id         = fm.snap_id
        and sn.dbid            = fm.dbid
        and sn.instance_number = fm.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_FILEMETRIC_HISTORY is
'File Metrics History'
/
create or replace public synonym DBA_HIST_FILEMETRIC_HISTORY 
    for DBA_HIST_FILEMETRIC_HISTORY
/
grant select on DBA_HIST_FILEMETRIC_HISTORY to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_WAITCLASSMET_HISTORY
 ***************************************/

create or replace view DBA_HIST_WAITCLASSMET_HISTORY
  (SNAP_ID, DBID, INSTANCE_NUMBER, WAIT_CLASS_ID, WAIT_CLASS,
   BEGIN_TIME, END_TIME, INTSIZE, GROUP_ID, AVERAGE_WAITER_COUNT,
   DBTIME_IN_WAIT, TIME_WAITED, WAIT_COUNT, TIME_WAITED_FG, WAIT_COUNT_FG)
as
select em.snap_id, em.dbid, em.instance_number, 
       em.wait_class_id, wn.wait_class, begin_time, end_time, intsize, 
       group_id, average_waiter_count, dbtime_in_wait,
       time_waited, wait_count, time_waited_fg, wait_count_fg
  from wrm$_snapshot sn, WRH$_WAITCLASSMETRIC_HISTORY em,
       (select wait_class_id, wait_class from wrh$_event_name
        group by wait_class_id, wait_class) wn
  where     em.wait_class_id   = wn.wait_class_id
        and sn.snap_id         = em.snap_id
        and sn.dbid            = em.dbid
        and sn.instance_number = em.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_WAITCLASSMET_HISTORY is
'Wait Class Metric History'
/
create or replace public synonym DBA_HIST_WAITCLASSMET_HISTORY 
    for DBA_HIST_WAITCLASSMET_HISTORY
/
grant select on DBA_HIST_WAITCLASSMET_HISTORY to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_DLM_MISC
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_DLM_MISC
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   STATISTIC#, NAME, VALUE)
as
select dlm.snap_id, dlm.dbid, dlm.instance_number,
       statistic#, name, value
  from wrm$_snapshot sn, WRH$_DLM_MISC dlm
  where     sn.snap_id         = dlm.snap_id
        and sn.dbid            = dlm.dbid
        and sn.instance_number = dlm.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_DLM_MISC is
'Distributed Lock Manager Miscellaneous Historical Statistics Information'
/
create or replace public synonym DBA_HIST_DLM_MISC 
    for DBA_HIST_DLM_MISC
/
grant select on DBA_HIST_DLM_MISC to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_CR_BLOCK_SERVER
 ***************************************/

create or replace view DBA_HIST_CR_BLOCK_SERVER
(SNAP_ID, DBID, INSTANCE_NUMBER,
 CR_REQUESTS, CURRENT_REQUESTS, 
 DATA_REQUESTS, UNDO_REQUESTS, TX_REQUESTS, 
 CURRENT_RESULTS, PRIVATE_RESULTS, ZERO_RESULTS,
 DISK_READ_RESULTS, FAIL_RESULTS,
 FAIRNESS_DOWN_CONVERTS, FAIRNESS_CLEARS, FREE_GC_ELEMENTS,
 FLUSHES, FLUSHES_QUEUED, FLUSH_QUEUE_FULL, FLUSH_MAX_TIME,
 LIGHT_WORKS, ERRORS)
as
select crb.snap_id, crb.dbid, crb.instance_number,
       cr_requests, current_requests, 
       data_requests, undo_requests, tx_requests, 
       current_results, private_results, zero_results,
       disk_read_results, fail_results,
       fairness_down_converts, fairness_clears, free_gc_elements,
       flushes, flushes_queued, flush_queue_full, flush_max_time,
       light_works, errors
  from wrm$_snapshot sn, WRH$_CR_BLOCK_SERVER crb
  where     sn.snap_id         = crb.snap_id
        and sn.dbid            = crb.dbid
        and sn.instance_number = crb.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_CR_BLOCK_SERVER is
'Consistent Read Block Server Historical Statistics'
/
create or replace public synonym DBA_HIST_CR_BLOCK_SERVER 
    for DBA_HIST_CR_BLOCK_SERVER
/
grant select on DBA_HIST_CR_BLOCK_SERVER to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_CURRENT_BLOCK_SERVER
 ***************************************/

create or replace view DBA_HIST_CURRENT_BLOCK_SERVER
(SNAP_ID, DBID, INSTANCE_NUMBER,
 PIN1,   PIN10,   PIN100,   PIN1000,   PIN10000,
 FLUSH1, FLUSH10, FLUSH100, FLUSH1000, FLUSH10000,
 WRITE1, WRITE10, WRITE100, WRITE1000, WRITE10000)
as
select cub.snap_id, cub.dbid, cub.instance_number,
       pin1,   pin10,   pin100,   pin1000,   pin10000,
       flush1, flush10, flush100, flush1000, flush10000,
       write1, write10, write100, write1000, write10000
  from wrm$_snapshot sn, WRH$_CURRENT_BLOCK_SERVER cub
  where     sn.snap_id         = cub.snap_id
        and sn.dbid            = cub.dbid
        and sn.instance_number = cub.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_CURRENT_BLOCK_SERVER is
'Current Block Server Historical Statistics'
/
create or replace public synonym DBA_HIST_CURRENT_BLOCK_SERVER 
    for DBA_HIST_CURRENT_BLOCK_SERVER
/
grant select on DBA_HIST_CURRENT_BLOCK_SERVER to SELECT_CATALOG_ROLE
/


/***************************************
 *    DBA_HIST_INST_CACHE_TRANSFER
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***************************************/

create or replace view DBA_HIST_INST_CACHE_TRANSFER
(SNAP_ID, DBID, INSTANCE_NUMBER, 
 INSTANCE, CLASS, CR_BLOCK, CR_BUSY, CR_CONGESTED, 
 CURRENT_BLOCK, CURRENT_BUSY, CURRENT_CONGESTED
 ,lost ,cr_2hop ,cr_3hop ,current_2hop ,current_3hop 
 ,cr_block_time ,cr_busy_time ,cr_congested_time ,current_block_time 
 ,current_busy_time ,current_congested_time ,lost_time ,cr_2hop_time
 ,cr_3hop_time ,current_2hop_time ,current_3hop_time
)
as
select ict.snap_id, ict.dbid, ict.instance_number, 
       instance, class, cr_block, cr_busy, cr_congested, 
       current_block, current_busy, current_congested
      ,lost ,cr_2hop ,cr_3hop ,current_2hop ,current_3hop
      ,cr_block_time ,cr_busy_time ,cr_congested_time ,current_block_time
      ,current_busy_time ,current_congested_time ,lost_time ,cr_2hop_time
      ,cr_3hop_time ,current_2hop_time ,current_3hop_time
  from wrm$_snapshot sn, WRH$_INST_CACHE_TRANSFER ict
  where     sn.snap_id         = ict.snap_id
        and sn.dbid            = ict.dbid
        and sn.instance_number = ict.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_INST_CACHE_TRANSFER is
'Instance Cache Transfer Historical Statistics'
/
create or replace public synonym DBA_HIST_INST_CACHE_TRANSFER 
    for DBA_HIST_INST_CACHE_TRANSFER
/
grant select on DBA_HIST_INST_CACHE_TRANSFER to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_PLAN_OPERATION_NAME
 ***************************************/

create or replace view DBA_HIST_PLAN_OPERATION_NAME
  (DBID, OPERATION_ID, OPERATION_NAME)
as
select dbid, operation_id, operation_name
from WRH$_PLAN_OPERATION_NAME
/

comment on table DBA_HIST_PLAN_OPERATION_NAME is
'Optimizer Explain Plan Operation Names'
/
create or replace public synonym DBA_HIST_PLAN_OPERATION_NAME 
  for DBA_HIST_PLAN_OPERATION_NAME
/
grant select on DBA_HIST_PLAN_OPERATION_NAME to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_PLAN_OPTION_NAME
 ***************************************/

create or replace view DBA_HIST_PLAN_OPTION_NAME
  (DBID, OPTION_ID, OPTION_NAME)
as
select dbid, option_id, option_name
from WRH$_PLAN_OPTION_NAME
/

comment on table DBA_HIST_PLAN_OPTION_NAME is
'Optimizer Explain Plan Option Names'
/
create or replace public synonym DBA_HIST_PLAN_OPTION_NAME 
  for DBA_HIST_PLAN_OPTION_NAME
/
grant select on DBA_HIST_PLAN_OPTION_NAME to SELECT_CATALOG_ROLE
/

/*****************************************
 *   DBA_HIST_SQLCOMMAND_NAME
 *****************************************/

create or replace view DBA_HIST_SQLCOMMAND_NAME
  (DBID, COMMAND_TYPE, COMMAND_NAME)
as
select dbid, command_type,command_name 
from WRH$_SQLCOMMAND_NAME
/

comment on table DBA_HIST_SQLCOMMAND_NAME is
'Sql command types'
/
create or replace public synonym DBA_HIST_SQLCOMMAND_NAME
  for DBA_HIST_SQLCOMMAND_NAME
/
grant select on DBA_HIST_SQLCOMMAND_NAME to SELECT_CATALOG_ROLE
/

/*****************************************
 *   DBA_HIST_TOPLEVELCALL_NAME
 *****************************************/

create or replace view DBA_HIST_TOPLEVELCALL_NAME
  (DBID, TOP_LEVEL_CALL#,TOP_LEVEL_CALL_NAME)
as
select dbid, top_level_call#,top_level_call_name 
from WRH$_TOPLEVELCALL_NAME
/

comment on table DBA_HIST_TOPLEVELCALL_NAME is
'Oracle top level call type'
/
create or replace public synonym DBA_HIST_TOPLEVELCALL_NAME
  for DBA_HIST_TOPLEVELCALL_NAME
/
grant select on DBA_HIST_TOPLEVELCALL_NAME to SELECT_CATALOG_ROLE
/

/***************************************
 *    DBA_HIST_ACTIVE_SESS_HISTORY
 ***************************************/

create or replace view DBA_HIST_ACTIVE_SESS_HISTORY
 ( /* ASH/AWR meta attributes */
   SNAP_ID, DBID, INSTANCE_NUMBER, 
   SAMPLE_ID, SAMPLE_TIME,
   /* Session/User attributes */
   SESSION_ID, SESSION_SERIAL#, 
   SESSION_TYPE, 
   FLAGS,
   USER_ID,
   /* SQL attributes */
   SQL_ID, IS_SQLID_CURRENT, SQL_CHILD_NUMBER, SQL_OPCODE, SQL_OPNAME,
   FORCE_MATCHING_SIGNATURE,
   TOP_LEVEL_SQL_ID, 
   TOP_LEVEL_SQL_OPCODE,
   /* SQL Plan/Execution attributes */
   SQL_PLAN_HASH_VALUE, 
   SQL_PLAN_LINE_ID, 
   SQL_PLAN_OPERATION, SQL_PLAN_OPTIONS,
   SQL_EXEC_ID, 
   SQL_EXEC_START,
   /* PL/SQL attributes */
   PLSQL_ENTRY_OBJECT_ID, 
   PLSQL_ENTRY_SUBPROGRAM_ID, 
   PLSQL_OBJECT_ID, 
   PLSQL_SUBPROGRAM_ID, 
   /* PQ attributes */
   QC_INSTANCE_ID, QC_SESSION_ID, QC_SESSION_SERIAL#, PX_FLAGS,
   /* Wait event attributes */
   EVENT, 
   EVENT_ID, 
   SEQ#, 
   P1TEXT, P1, 
   P2TEXT, P2, 
   P3TEXT, P3, 
   WAIT_CLASS, 
   WAIT_CLASS_ID,
   WAIT_TIME, 
   SESSION_STATE,
   TIME_WAITED,
   BLOCKING_SESSION_STATUS,
   BLOCKING_SESSION,
   BLOCKING_SESSION_SERIAL#,
   BLOCKING_INST_ID,
   BLOCKING_HANGCHAIN_INFO,
   /* Session's working context */
   CURRENT_OBJ#, CURRENT_FILE#, CURRENT_BLOCK#, CURRENT_ROW#,
   TOP_LEVEL_CALL#, TOP_LEVEL_CALL_NAME,
   CONSUMER_GROUP_ID, 
   XID,
   REMOTE_INSTANCE#,
   TIME_MODEL,
   IN_CONNECTION_MGMT,
   IN_PARSE,
   IN_HARD_PARSE,
   IN_SQL_EXECUTION,
   IN_PLSQL_EXECUTION,
   IN_PLSQL_RPC,
   IN_PLSQL_COMPILATION,
   IN_JAVA_EXECUTION,
   IN_BIND,
   IN_CURSOR_CLOSE,
   IN_SEQUENCE_LOAD,
   CAPTURE_OVERHEAD,
   REPLAY_OVERHEAD,
   IS_CAPTURED,
   IS_REPLAYED,
   /* Application attributes */
   SERVICE_HASH, PROGRAM, MODULE, ACTION, CLIENT_ID, 
   MACHINE, PORT, ECID,
   /* DB Replay info */
   DBREPLAY_FILE_ID, DBREPLAY_CALL_COUNTER,
   /* STASH columns */
   TM_DELTA_TIME,
   TM_DELTA_CPU_TIME,
   TM_DELTA_DB_TIME,
   DELTA_TIME,
   DELTA_READ_IO_REQUESTS,
   DELTA_WRITE_IO_REQUESTS,
   DELTA_READ_IO_BYTES,
   DELTA_WRITE_IO_BYTES,
   DELTA_INTERCONNECT_IO_BYTES,
   PGA_ALLOCATED,
   TEMP_SPACE_ALLOCATED)
as
select /* ASH/AWR meta attributes */
       ash.snap_id, ash.dbid, ash.instance_number, 
       ash.sample_id, ash.sample_time,
       /* Session/User attributes */
       ash.session_id, ash.session_serial#, 
       decode(ash.session_type, 1,'FOREGROUND', 'BACKGROUND'),
       ash.flags,
       ash.user_id,
       /* SQL attributes */
       ash.sql_id, 
       decode(bitand(ash.flags, power(2, 4)), NULL, 'N', 0, 'N', 'Y'),
       ash.sql_child_number, ash.sql_opcode,
       (select command_name from DBA_HIST_SQLCOMMAND_NAME 
        where command_type = ash.sql_opcode
        and dbid = ash.dbid) as sql_opname,
       ash.force_matching_signature,
       decode(ash.top_level_sql_id, NULL, ash.sql_id, ash.top_level_sql_id),
       decode(ash.top_level_sql_id, NULL, ash.sql_opcode, 
              ash.top_level_sql_opcode),
       /* SQL Plan/Execution attributes */
       ash.sql_plan_hash_value, 
       decode(ash.sql_plan_line_id, 0, to_number(NULL), ash.sql_plan_line_id),
       (select operation_name from DBA_HIST_PLAN_OPERATION_NAME
        where  operation_id = ash.sql_plan_operation# 
          and  dbid = ash.dbid) as sql_plan_operation,
       (select option_name from DBA_HIST_PLAN_OPTION_NAME
        where  option_id = ash.sql_plan_options# 
          and  dbid = ash.dbid) as sql_plan_options,
       decode(ash.sql_exec_id, 0, to_number(NULL), ash.sql_exec_id),
       ash.sql_exec_start,
       /* PL/SQL attributes */
       decode(ash.plsql_entry_object_id,0,to_number(NULL),
              ash.plsql_entry_object_id),
       decode(ash.plsql_entry_object_id,0,to_number(NULL),
              ash.plsql_entry_subprogram_id),
       decode(ash.plsql_object_id,0,to_number(NULL),
              ash.plsql_object_id),
       decode(ash.plsql_object_id,0,to_number(NULL),
              ash.plsql_subprogram_id),
       /* PQ attributes */
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_instance_id),
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_session_id),
       decode(ash.qc_session_id, 0, to_number(NULL), ash.qc_session_serial#),
       decode(ash.px_flags,      0, to_number(NULL), ash.px_flags),
       /* Wait event attributes */
       decode(ash.wait_time, 0, evt.event_name, NULL),
       decode(ash.wait_time, 0, evt.event_id,   NULL),
       ash.seq#, 
       evt.parameter1, ash.p1, 
       evt.parameter2, ash.p2, 
       evt.parameter3, ash.p3, 
       decode(ash.wait_time, 0, evt.wait_class,    NULL),
       decode(ash.wait_time, 0, evt.wait_class_id, NULL),
       ash.wait_time, 
       decode(ash.wait_time, 0, 'WAITING', 'ON CPU'),
       ash.time_waited,
       (case when ash.blocking_session = 4294967295
               then 'UNKNOWN'
             when ash.blocking_session = 4294967294
               then 'GLOBAL'
             when ash.blocking_session = 4294967293
               then 'UNKNOWN'
             when ash.blocking_session = 4294967292
               then 'NO HOLDER'
             when ash.blocking_session = 4294967291
               then 'NOT IN WAIT'
             else 'VALID'
        end),
       (case when ash.blocking_session between 4294967291 and 4294967295
               then to_number(NULL)
             else ash.blocking_session
        end),
       (case when ash.blocking_session between 4294967291 and 4294967295
               then to_number(NULL)
             else ash.blocking_session_serial#
        end),
       (case when ash.blocking_session between 4294967291 and 4294967295 
               then to_number(NULL)
             else ash.blocking_inst_id
          end), 
       (case when ash.blocking_session between 4294967291 and 4294967295 
               then NULL
             else decode(bitand(ash.flags, power(2, 3)), NULL, 'N', 
                         0, 'N', 'Y')
          end),
       /* Session's working context */
       ash.current_obj#, ash.current_file#, ash.current_block#, 
       ash.current_row#, ash.top_level_call#,
       (select top_level_call_name from DBA_HIST_TOPLEVELCALL_NAME
        where top_level_call# = ash.top_level_call#
        and dbid = ash.dbid) as top_level_call_name,
       decode(ash.consumer_group_id, 0, to_number(NULL), 
              ash.consumer_group_id),
       ash.xid,
       decode(ash.remote_instance#, 0, to_number(NULL), ash.remote_instance#),
       ash.time_model,
       decode(bitand(ash.time_model,power(2, 3)),0,'N','Y') 
                                                         as in_connection_mgmt,
       decode(bitand(ash.time_model,power(2, 4)),0,'N','Y')as in_parse,
       decode(bitand(ash.time_model,power(2, 7)),0,'N','Y')as in_hard_parse,
       decode(bitand(ash.time_model,power(2,10)),0,'N','Y')as in_sql_execution,
       decode(bitand(ash.time_model,power(2,11)),0,'N','Y')
                                                         as in_plsql_execution,
       decode(bitand(ash.time_model,power(2,12)),0,'N','Y')as in_plsql_rpc,
       decode(bitand(ash.time_model,power(2,13)),0,'N','Y')
                                                       as in_plsql_compilation,
       decode(bitand(ash.time_model,power(2,14)),0,'N','Y')
                                                       as in_java_execution,
       decode(bitand(ash.time_model,power(2,15)),0,'N','Y')as in_bind,
       decode(bitand(ash.time_model,power(2,16)),0,'N','Y')as in_cursor_close,
       decode(bitand(ash.time_model,power(2,17)),0,'N','Y')as in_sequence_load,
       decode(bitand(ash.flags,power(2,5)),NULL,'N',0,'N','Y')
                                                       as capture_overhead,
       decode(bitand(ash.flags,power(2,6)), NULL,'N',0,'N','Y' )
                                                           as replay_overhead,
       decode(bitand(ash.flags,power(2,0)),NULL,'N',0,'N','Y') as is_captured,
       decode(bitand(ash.flags,power(2,2)), NULL,'N',0,'N','Y' )as is_replayed,
       /* Application attributes */
       ash.service_hash, ash.program, 
       substrb(ash.module,1,(select ksumodlen from x$modact_length)) module,
       substrb(ash.action,1,(select ksuactlen from x$modact_length)) action,
       ash.client_id,
       ash.machine, ash.port, ash.ecid,
       /* DB Replay info */
       ash.dbreplay_file_id, ash.dbreplay_call_counter,
       /* stash columns */
       ash.tm_delta_time,
       ash.tm_delta_cpu_time,
       ash.tm_delta_db_time,
       ash.delta_time,
       ash.delta_read_io_requests,
       ash.delta_write_io_requests,
       ash.delta_read_io_bytes,
       ash.delta_write_io_bytes,
       ash.delta_interconnect_io_bytes,
       ash.pga_allocated,
       ash.temp_space_allocated
from WRM$_SNAPSHOT sn, WRH$_ACTIVE_SESSION_HISTORY ash, WRH$_EVENT_NAME evt
where      ash.snap_id          = sn.snap_id(+)
      and  ash.dbid             = sn.dbid(+)
      and  ash.instance_number  = sn.instance_number(+)
      and  ash.dbid             = evt.dbid
      and  ash.event_id         = evt.event_id
/

comment on table DBA_HIST_ACTIVE_SESS_HISTORY is
'Active Session Historical Statistics Information'
/
create or replace public synonym DBA_HIST_ACTIVE_SESS_HISTORY 
    for DBA_HIST_ACTIVE_SESS_HISTORY
/
grant select on DBA_HIST_ACTIVE_SESS_HISTORY to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_ASH_SNAPSHOTS
 ***************************************/
create or replace view DBA_HIST_ASH_SNAPSHOT as
select s.*
  from WRM$_SNAPSHOT s 
 where s.status in (0,1)        
   and s.flush_elapsed is not null 
   and (s.snap_id,dbid,instance_number) not in 
       (select e.snap_id,dbid,instance_number 
          from WRM$_SNAP_ERROR e
         where e.table_name = 'WRH$_ACTIVE_SESSION_HISTORY');
       
/
-- create a public synonym for the view
create or replace public synonym DBA_HIST_ASH_SNAPSHOT
  for DBA_HIST_ASH_SNAPSHOT
/
-- grant a select privilege on the view to the SELECT_CATALOG_ROLE
grant select on DBA_HIST_ASH_SNAPSHOT to SELECT_CATALOG_ROLE
/


/***************************************
 *      DBA_HIST_TABLESPACE_STAT
 *
 ***************************************/

create or replace view DBA_HIST_TABLESPACE_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER, TS#, TSNAME, CONTENTS, 
   STATUS, SEGMENT_SPACE_MANAGEMENT, EXTENT_MANAGEMENT,
   IS_BACKUP)
as
select tbs.snap_id, tbs.dbid, tbs.instance_number, ts#, tsname, contents, 
       tbs.status, segment_space_management, extent_management,
       is_backup
from WRM$_SNAPSHOT sn, WRH$_TABLESPACE_STAT tbs
where      tbs.snap_id          = sn.snap_id
      and  tbs.dbid             = sn.dbid
      and  tbs.instance_number  = sn.instance_number
      and  sn.status            = 0
/

comment on table DBA_HIST_TABLESPACE_STAT is
'Tablespace Historical Statistics Information'
/
create or replace public synonym DBA_HIST_TABLESPACE_STAT 
    for DBA_HIST_TABLESPACE_STAT
/
grant select on DBA_HIST_TABLESPACE_STAT to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_LOG
 ***************************************/

create or replace view DBA_HIST_LOG
  (SNAP_ID, DBID, INSTANCE_NUMBER, GROUP#, THREAD#, SEQUENCE#,
   BYTES, MEMBERS, ARCHIVED, STATUS, FIRST_CHANGE#, FIRST_TIME)
as
select log.snap_id, log.dbid, log.instance_number, 
       group#, thread#, sequence#, bytes, members, 
       archived, log.status, first_change#, first_time
  from wrm$_snapshot sn, WRH$_LOG log
  where     sn.snap_id         = log.snap_id
        and sn.dbid            = log.dbid
        and sn.instance_number = log.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_LOG is
'Log Historical Statistics Information'
/
create or replace public synonym DBA_HIST_LOG 
    for DBA_HIST_LOG
/
grant select on DBA_HIST_LOG to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_MTTR_TARGET_ADVICE
 ***************************************/

create or replace view DBA_HIST_MTTR_TARGET_ADVICE
  (SNAP_ID, DBID, INSTANCE_NUMBER, MTTR_TARGET_FOR_ESTIMATE,
   ADVICE_STATUS, DIRTY_LIMIT, 
   ESTD_CACHE_WRITES, ESTD_CACHE_WRITE_FACTOR, 
   ESTD_TOTAL_WRITES, ESTD_TOTAL_WRITE_FACTOR,
   ESTD_TOTAL_IOS, ESTD_TOTAL_IO_FACTOR)
as
select mt.snap_id, mt.dbid, mt.instance_number, mttr_target_for_estimate,
       advice_status, dirty_limit, 
       estd_cache_writes, estd_cache_write_factor, 
       estd_total_writes, estd_total_write_factor,
       estd_total_ios, estd_total_io_factor
  from wrm$_snapshot sn, WRH$_MTTR_TARGET_ADVICE mt
  where     sn.snap_id         = mt.snap_id
        and sn.dbid            = mt.dbid
        and sn.instance_number = mt.instance_number
        and sn.status          = 0
/

comment on table DBA_HIST_MTTR_TARGET_ADVICE is
'Mean-Time-To-Recover Target Advice History'
/
create or replace public synonym DBA_HIST_MTTR_TARGET_ADVICE 
    for DBA_HIST_MTTR_TARGET_ADVICE
/
grant select on DBA_HIST_MTTR_TARGET_ADVICE to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_TBSPC_SPACE_USAGE
 ***************************************/

create or replace view DBA_HIST_TBSPC_SPACE_USAGE
  (SNAP_ID, DBID, TABLESPACE_ID, TABLESPACE_SIZE,
   TABLESPACE_MAXSIZE, TABLESPACE_USEDSIZE, RTIME)
as
select tb.snap_id, tb.dbid, tablespace_id, tablespace_size,
       tablespace_maxsize, tablespace_usedsize, rtime
  from (select distinct snap_id, dbid 
          from WRM$_SNAPSHOT where status = 0) sn, 
       WRH$_TABLESPACE_SPACE_USAGE tb
  where     sn.snap_id         = tb.snap_id
        and sn.dbid            = tb.dbid
/

comment on table DBA_HIST_TBSPC_SPACE_USAGE is
'Tablespace Usage Historical Statistics Information'
/
create or replace public synonym DBA_HIST_TBSPC_SPACE_USAGE 
    for DBA_HIST_TBSPC_SPACE_USAGE
/
grant select on DBA_HIST_TBSPC_SPACE_USAGE to SELECT_CATALOG_ROLE
/


/*********************************
 *     DBA_HIST_SERVICE_NAME
 *********************************/

create or replace view DBA_HIST_SERVICE_NAME
  (DBID, SERVICE_NAME_HASH, SERVICE_NAME)
as
select dbid, service_name_hash, service_name
  from WRH$_SERVICE_NAME sn
/
comment on table DBA_HIST_SERVICE_NAME is
'Service Names'
/
create or replace public synonym DBA_HIST_SERVICE_NAME 
    for DBA_HIST_SERVICE_NAME
/
grant select on DBA_HIST_SERVICE_NAME to SELECT_CATALOG_ROLE
/


/*********************************
 *     DBA_HIST_SERVICE_STAT
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 *********************************/

create or replace view DBA_HIST_SERVICE_STAT
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   SERVICE_NAME_HASH, SERVICE_NAME,
   STAT_ID, STAT_NAME, VALUE)
as
select st.snap_id, st.dbid, st.instance_number,
       st.service_name_hash, sv.service_name, 
       nm.stat_id, nm.stat_name, value
  from WRM$_SNAPSHOT sn, WRH$_SERVICE_STAT st, 
       WRH$_SERVICE_NAME sv, WRH$_STAT_NAME nm
  where    st.service_name_hash = sv.service_name_hash
      and  st.dbid              = sv.dbid
      and  st.stat_id           = nm.stat_id
      and  st.dbid              = nm.dbid
      and  st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  sn.status            = 0
/
comment on table DBA_HIST_SERVICE_STAT is
'Historical Service Statistics'
/
create or replace public synonym DBA_HIST_SERVICE_STAT 
    for DBA_HIST_SERVICE_STAT
/
grant select on DBA_HIST_SERVICE_STAT to SELECT_CATALOG_ROLE
/


/***********************************
 *   DBA_HIST_SERVICE_WAIT_CLASS
 *
 *  NOTE: Convert this to not use the BL once the
 *        crash in the Diff-Diff report is fixed.
 ***********************************/

create or replace view DBA_HIST_SERVICE_WAIT_CLASS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   SERVICE_NAME_HASH, SERVICE_NAME, 
   WAIT_CLASS_ID, WAIT_CLASS, TOTAL_WAITS, TIME_WAITED)
as
select st.snap_id, st.dbid, st.instance_number,
       st.service_name_hash, nm.service_name, 
       wait_class_id, wait_class, total_waits, time_waited 
  from WRM$_SNAPSHOT sn, WRH$_SERVICE_WAIT_CLASS st, 
       WRH$_SERVICE_NAME nm
  where    st.service_name_hash = nm.service_name_hash
      and  st.dbid              = nm.dbid
      and  st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  sn.status            = 0
/
comment on table DBA_HIST_SERVICE_WAIT_CLASS is
'Historical Service Wait Class Statistics'
/
create or replace public synonym DBA_HIST_SERVICE_WAIT_CLASS 
    for DBA_HIST_SERVICE_WAIT_CLASS
/
grant select on DBA_HIST_SERVICE_WAIT_CLASS to SELECT_CATALOG_ROLE
/


/***********************************
 *   DBA_HIST_SESS_TIME_STATS
 ***********************************/

create or replace view DBA_HIST_SESS_TIME_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER, SESSION_TYPE, MIN_LOGON_TIME,
   SUM_CPU_TIME, SUM_SYS_IO_WAIT, SUM_USER_IO_WAIT)
as
select st.snap_id, st.dbid, st.instance_number, st.session_type,
       st.min_logon_time, st.sum_cpu_time, st.sum_sys_io_wait,
       st.sum_user_io_wait
  from WRM$_SNAPSHOT sn, WRH$_SESS_TIME_STATS st
  where    st.snap_id           = sn.snap_id
      and  st.dbid              = sn.dbid
      and  st.instance_number   = sn.instance_number
      and  sn.status            = 0
/
comment on table DBA_HIST_SESS_TIME_STATS is
'CPU and I/O time for interesting (STREAMS) sessions'
/
create or replace public synonym DBA_HIST_SESS_TIME_STATS
    for DBA_HIST_SESS_TIME_STATS
/
grant select on DBA_HIST_SESS_TIME_STATS to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_STREAMS_CAPTURE
 ***************************************/

create or replace view DBA_HIST_STREAMS_CAPTURE
  (SNAP_ID, DBID, INSTANCE_NUMBER, CAPTURE_NAME, STARTUP_TIME, LAG,
   TOTAL_MESSAGES_CAPTURED, TOTAL_MESSAGES_ENQUEUED,
   ELAPSED_RULE_TIME, ELAPSED_ENQUEUE_TIME,
   ELAPSED_REDO_WAIT_TIME, ELAPSED_PAUSE_TIME)
as
select cs.snap_id, cs.dbid, cs.instance_number, cs.capture_name, 
       cs.startup_time, cs.lag,
       cs.total_messages_captured, cs.total_messages_enqueued,
       cs.elapsed_rule_time, cs.elapsed_enqueue_time,
       cs.elapsed_redo_wait_time, cs.elapsed_pause_time
  from wrh$_streams_capture cs, wrm$_snapshot sn
  where     sn.snap_id          = cs.snap_id
        and sn.dbid             = cs.dbid
        and sn.instance_number  = cs.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_STREAMS_CAPTURE is
'STREAMS Capture Historical Statistics Information'
/
create or replace public synonym DBA_HIST_STREAMS_CAPTURE
    for DBA_HIST_STREAMS_CAPTURE
/
grant select on DBA_HIST_STREAMS_CAPTURE to SELECT_CATALOG_ROLE
/

/***********************************************
 *        DBA_HIST_STREAMS_APPLY_SUM
 ***********************************************/

create or replace view DBA_HIST_STREAMS_APPLY_SUM
  (SNAP_ID, DBID, INSTANCE_NUMBER, APPLY_NAME, STARTUP_TIME,
   READER_TOTAL_MESSAGES_DEQUEUED, READER_LAG,
   coord_total_received, coord_total_applied, coord_total_rollbacks,
   coord_total_wait_deps, coord_total_wait_cmts, coord_lwm_lag,
   server_total_messages_applied, server_elapsed_dequeue_time,
   server_elapsed_apply_time)
as
select sas.snap_id, sas.dbid, sas.instance_number, sas.apply_name,
       sas.startup_time, sas.reader_total_messages_dequeued, sas.reader_lag,
       sas.coord_total_received, sas.coord_total_applied,
       sas.coord_total_rollbacks, sas.coord_total_wait_deps,
       sas.coord_total_wait_cmts, sas.coord_lwm_lag,
       sas.server_total_messages_applied, sas.server_elapsed_dequeue_time,
       sas.server_elapsed_apply_time
  from wrh$_streams_apply_sum sas, wrm$_snapshot sn
  where     sn.snap_id          = sas.snap_id
        and sn.dbid             = sas.dbid
        and sn.instance_number  = sas.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_STREAMS_APPLY_SUM is
'STREAMS Apply Historical Statistics Information'
/
create or replace public synonym DBA_HIST_STREAMS_APPLY_SUM
    for DBA_HIST_STREAMS_APPLY_SUM
/
grant select on DBA_HIST_STREAMS_APPLY_SUM to SELECT_CATALOG_ROLE
/

/*****************************************
 *        DBA_HIST_BUFFERED_QUEUES
 *****************************************/

create or replace view DBA_HIST_BUFFERED_QUEUES
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME, STARTUP_TIME,
   QUEUE_ID, NUM_MSGS, SPILL_MSGS, CNUM_MSGS, CSPILL_MSGS, EXPIRED_MSGS,
   OLDEST_MSGID, OLDEST_MSG_ENQTM, QUEUE_STATE,
   ELAPSED_ENQUEUE_TIME, ELAPSED_DEQUEUE_TIME, ELAPSED_TRANSFORMATION_TIME,
   ELAPSED_RULE_EVALUATION_TIME, ENQUEUE_CPU_TIME, DEQUEUE_CPU_TIME,
   LAST_ENQUEUE_TIME, LAST_DEQUEUE_TIME )
as
select qs.snap_id, qs.dbid, qs.instance_number, qs.queue_schema, qs.queue_name,
       qs.startup_time, qs.queue_id, qs.num_msgs, qs.spill_msgs, qs.cnum_msgs,
       qs.cspill_msgs, qs.expired_msgs, qs.oldest_msgid, qs.oldest_msg_enqtm,
       qs.queue_state, qs.elapsed_enqueue_time,
       qs.elapsed_dequeue_time, qs.elapsed_transformation_time,
       qs.elapsed_rule_evaluation_time, qs.enqueue_cpu_time, 
       qs.dequeue_cpu_time, qs.last_enqueue_time, qs.last_dequeue_time
  from wrh$_buffered_queues qs, wrm$_snapshot sn
  where     sn.snap_id          = qs.snap_id
        and sn.dbid             = qs.dbid
        and sn.instance_number  = qs.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_BUFFERED_QUEUES is
'STREAMS Buffered Queues Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BUFFERED_QUEUES
    for DBA_HIST_BUFFERED_QUEUES
/
grant select on DBA_HIST_BUFFERED_QUEUES to SELECT_CATALOG_ROLE
/

/**********************************************
 *        DBA_HIST_BUFFERED_SUBSCRIBERS
 **********************************************/

create or replace view DBA_HIST_BUFFERED_SUBSCRIBERS
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME,
   SUBSCRIBER_ID, SUBSCRIBER_NAME, SUBSCRIBER_ADDRESS, SUBSCRIBER_TYPE,
   STARTUP_TIME, LAST_BROWSED_SEQ, LAST_BROWSED_NUM, LAST_DEQUEUED_SEQ,
   LAST_DEQUEUED_NUM, CURRENT_ENQ_SEQ, NUM_MSGS, CNUM_MSGS,
   TOTAL_DEQUEUED_MSG, TOTAL_SPILLED_MSG, EXPIRED_MSGS, MESSAGE_LAG, 
   ELAPSED_DEQUEUE_TIME, DEQUEUE_CPU_TIME, LAST_DEQUEUE_TIME, OLDEST_MSGID, 
   OLDEST_MSG_ENQTM )
as
select ss.snap_id, ss.dbid, ss.instance_number, ss.queue_schema, ss.queue_name,
       ss.subscriber_id, ss.subscriber_name, ss.subscriber_address,
       ss.subscriber_type, ss.startup_time, ss.last_browsed_seq,
       ss.last_browsed_num, ss.last_dequeued_seq, ss.last_dequeued_num,
       ss.current_enq_seq, ss.num_msgs, ss.cnum_msgs,
       ss.total_dequeued_msg, ss.total_spilled_msg, ss.expired_msgs, 
       ss.message_lag, ss.elapsed_dequeue_time, ss.dequeue_cpu_time,
       ss.last_dequeue_time, ss.oldest_msgid, ss.oldest_msg_enqtm
  from wrh$_buffered_subscribers ss, wrm$_snapshot sn
  where     sn.snap_id          = ss.snap_id
        and sn.dbid             = ss.dbid
        and sn.instance_number  = ss.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_BUFFERED_SUBSCRIBERS is
'STREAMS Buffered Queue Subscribers Historical Statistics Information'
/
create or replace public synonym DBA_HIST_BUFFERED_SUBSCRIBERS
    for DBA_HIST_BUFFERED_SUBSCRIBERS
/
grant select on DBA_HIST_BUFFERED_SUBSCRIBERS to SELECT_CATALOG_ROLE
/

/**********************************************
 *        DBA_HIST_RULE_SET
 **********************************************/

create or replace view DBA_HIST_RULE_SET
  (SNAP_ID, DBID, INSTANCE_NUMBER, OWNER, NAME,
  STARTUP_TIME, CPU_TIME, ELAPSED_TIME, EVALUATIONS, SQL_FREE_EVALUATIONS,
  SQL_EXECUTIONS, RELOADS)
as
select rs.snap_id, rs.dbid, rs.instance_number,
       rs.owner, rs.name, rs.startup_time, rs.cpu_time, rs.elapsed_time,
       rs.evaluations, rs.sql_free_evaluations, rs.sql_executions, rs.reloads
  from wrh$_rule_set rs, wrm$_snapshot sn
  where     sn.snap_id          = rs.snap_id
        and sn.dbid             = rs.dbid
        and sn.instance_number  = rs.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_RULE_SET is
'Rule sets historical statistics information'
/
create or replace public synonym DBA_HIST_RULE_SET
    for DBA_HIST_RULE_SET
/
grant select on DBA_HIST_RULE_SET to SELECT_CATALOG_ROLE
/


/*****************************************
 *        DBA_HIST_PERSISTENT_QUEUES
 *****************************************/

create or replace view DBA_HIST_PERSISTENT_QUEUES
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME, QUEUE_ID, 
   FIRST_ACTIVITY_TIME, ENQUEUED_MSGS, DEQUEUED_MSGS, BROWSED_MSGS,
   ELAPSED_ENQUEUE_TIME, ELAPSED_DEQUEUE_TIME, ENQUEUE_CPU_TIME, 
   DEQUEUE_CPU_TIME, AVG_MSG_AGE, DEQUEUED_MSG_LATENCY, 
   ELAPSED_TRANSFORMATION_TIME, 
   ELAPSED_RULE_EVALUATION_TIME, ENQUEUED_EXPIRY_MSGS, ENQUEUED_DELAY_MSGS,
   MSGS_MADE_EXPIRED, MSGS_MADE_READY, LAST_ENQUEUE_TIME, LAST_DEQUEUE_TIME,
   LAST_TM_EXPIRY_TIME, LAST_TM_READY_TIME, ENQUEUE_TRANSACTIONS,
   DEQUEUE_TRANSACTIONS, EXECUTION_COUNT )
as
select pqs.snap_id, pqs.dbid, pqs.instance_number, pqs.queue_schema, 
       pqs.queue_name,pqs.queue_id, pqs.first_activity_time, pqs.enqueued_msgs,
       pqs.dequeued_msgs, pqs.browsed_msgs, pqs.elapsed_enqueue_time, 
       pqs.elapsed_dequeue_time, pqs.enqueue_cpu_time, pqs.dequeue_cpu_time,
       pqs.avg_msg_age, pqs.dequeued_msg_latency,
       pqs.elapsed_transformation_time, pqs.elapsed_rule_evaluation_time,
       pqs.enqueued_expiry_msgs, pqs.enqueued_delay_msgs, 
       pqs.msgs_made_expired, pqs.msgs_made_ready, pqs.last_enqueue_time,
       pqs.last_dequeue_time, pqs.last_tm_expiry_time, pqs.last_tm_ready_time,
       pqs.enqueue_transactions, pqs.dequeue_transactions, pqs.execution_count
  from wrh$_persistent_queues pqs, wrm$_snapshot sn
  where     sn.snap_id          = pqs.snap_id
        and sn.dbid             = pqs.dbid
        and sn.instance_number  = pqs.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_PERSISTENT_QUEUES is
'STREAMS AQ Persistent Queues Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PERSISTENT_QUEUES
    for DBA_HIST_PERSISTENT_QUEUES
/
grant select on DBA_HIST_PERSISTENT_QUEUES to SELECT_CATALOG_ROLE
/

/**********************************************
 *        DBA_HIST_PERSISTENT_SUBS
 **********************************************/

create or replace view DBA_HIST_PERSISTENT_SUBS
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_SCHEMA, QUEUE_NAME,
   SUBSCRIBER_ID, SUBSCRIBER_NAME, SUBSCRIBER_ADDRESS, SUBSCRIBER_TYPE,
   FIRST_ACTIVITY_TIME, ENQUEUED_MSGS, DEQUEUED_MSGS, AVG_MSG_AGE,BROWSED_MSGS,
   EXPIRED_MSGS, DEQUEUED_MSG_LATENCY, LAST_ENQUEUE_TIME, LAST_DEQUEUE_TIME,
   ELAPSED_DEQUEUE_TIME,DEQUEUE_CPU_TIME,DEQUEUE_TRANSACTIONS, EXECUTION_COUNT)
as
select pss.snap_id, pss.dbid, pss.instance_number,
       pss.queue_schema, pss.queue_name, pss.subscriber_id,
       pss.subscriber_name, pss.subscriber_address, pss.subscriber_type,
       pss.first_activity_time, pss.enqueued_msgs, pss.dequeued_msgs, 
       pss.avg_msg_age, pss.browsed_msgs,
       pss.expired_msgs, pss.dequeued_msg_latency, pss.last_enqueue_time,
       pss.last_dequeue_time, pss.elapsed_dequeue_time,pss.dequeue_cpu_time,
       pss.dequeue_transactions, pss.execution_count
  from wrh$_persistent_subscribers pss, wrm$_snapshot sn
  where     sn.snap_id          = pss.snap_id
        and sn.dbid             = pss.dbid
        and sn.instance_number  = pss.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_PERSISTENT_SUBS is
'STREAMS AQ Persistent Queue Subscribers Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PERSISTENT_SUBS
    for DBA_HIST_PERSISTENT_SUBS
/
grant select on DBA_HIST_PERSISTENT_SUBS to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_IOSTAT_FUNCTION
 ***************************************/

create or replace view DBA_HIST_IOSTAT_FUNCTION
  (SNAP_ID, DBID, INSTANCE_NUMBER, FUNCTION_ID, FUNCTION_NAME, 
   SMALL_READ_MEGABYTES, SMALL_WRITE_MEGABYTES, 
   LARGE_READ_MEGABYTES, LARGE_WRITE_MEGABYTES,
   SMALL_READ_REQS, SMALL_WRITE_REQS, LARGE_READ_REQS, LARGE_WRITE_REQS,
   NUMBER_OF_WAITS, WAIT_TIME) 
as
select io.snap_id, io.dbid, io.instance_number, 
       nm.function_id, nm.function_name, 
       io.small_read_megabytes, io.small_write_megabytes, 
       io.large_read_megabytes, io.large_write_megabytes,
       io.small_read_reqs, io.small_write_reqs, 
       io.large_read_reqs, io.large_write_reqs,
       io.number_of_waits, io.wait_time
  from wrm$_snapshot sn, WRH$_IOSTAT_FUNCTION io, WRH$_IOSTAT_FUNCTION_NAME nm
  where     sn.snap_id         = io.snap_id
        and sn.dbid            = io.dbid
        and sn.instance_number = io.instance_number
        and sn.status          = 0
        and io.function_id     = nm.function_id
        and io.dbid            = nm.dbid
/
comment on table DBA_HIST_IOSTAT_FUNCTION is
'Historical I/O statistics by function'
/
create or replace public synonym DBA_HIST_IOSTAT_FUNCTION 
  for DBA_HIST_IOSTAT_FUNCTION
/
grant select on DBA_HIST_IOSTAT_FUNCTION to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_IOSTAT_FUNCTION_NAME
 ***************************************/

create or replace view DBA_HIST_IOSTAT_FUNCTION_NAME
  (DBID, FUNCTION_ID, FUNCTION_NAME)
as
select dbid, 
       function_id, 
       function_name 
  from WRH$_IOSTAT_FUNCTION_NAME
/
comment on table DBA_HIST_IOSTAT_FUNCTION_NAME is
'Function names for historical I/O statistics'
/
create or replace public synonym DBA_HIST_IOSTAT_FUNCTION_NAME 
  for DBA_HIST_IOSTAT_FUNCTION_NAME
/
grant select on DBA_HIST_IOSTAT_FUNCTION_NAME to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_IOSTAT_FILETYPE
 ***************************************/

create or replace view DBA_HIST_IOSTAT_FILETYPE
  (SNAP_ID, DBID, INSTANCE_NUMBER, FILETYPE_ID, FILETYPE_NAME,
   SMALL_READ_MEGABYTES, SMALL_WRITE_MEGABYTES, 
   LARGE_READ_MEGABYTES, LARGE_WRITE_MEGABYTES,
   SMALL_READ_REQS, SMALL_WRITE_REQS, SMALL_SYNC_READ_REQS,
   LARGE_READ_REQS, LARGE_WRITE_REQS,
   SMALL_READ_SERVICETIME, SMALL_WRITE_SERVICETIME, SMALL_SYNC_READ_LATENCY, 
   LARGE_READ_SERVICETIME, LARGE_WRITE_SERVICETIME, RETRIES_ON_ERROR)
as
select io.snap_id, io.dbid, io.instance_number, 
       nm.filetype_id, nm.filetype_name,
       io.small_read_megabytes, io.small_write_megabytes, 
       io.large_read_megabytes, io.large_write_megabytes,
       io.small_read_reqs, io.small_write_reqs, io.small_sync_read_reqs,
       io.large_read_reqs, io.large_write_reqs,
       io.small_read_servicetime, io.small_write_servicetime, 
       io.small_sync_read_latency, 
       io.large_read_servicetime, io.large_write_servicetime, 
       io.retries_on_error
  from wrm$_snapshot sn, WRH$_IOSTAT_FILETYPE io, WRH$_IOSTAT_FILETYPE_NAME nm
  where     sn.snap_id         = io.snap_id
        and sn.dbid            = io.dbid
        and sn.instance_number = io.instance_number
        and sn.status          = 0
        and io.filetype_id     = nm.filetype_id
        and io.dbid            = nm.dbid
/
comment on table DBA_HIST_IOSTAT_FILETYPE is
'Historical I/O statistics by file type'
/
create or replace public synonym DBA_HIST_IOSTAT_FILETYPE 
  for DBA_HIST_IOSTAT_FILETYPE
/
grant select on DBA_HIST_IOSTAT_FILETYPE to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_IOSTAT_FILETYPE_NAME
 ***************************************/

create or replace view DBA_HIST_IOSTAT_FILETYPE_NAME
  (DBID, FILETYPE_ID, FILETYPE_NAME)
as
select dbid, 
       filetype_id, 
       filetype_name 
  from WRH$_IOSTAT_FILETYPE_NAME
/
comment on table DBA_HIST_IOSTAT_FILETYPE_NAME is
'File type names for historical I/O statistics'
/
create or replace public synonym DBA_HIST_IOSTAT_FILETYPE_NAME 
  for DBA_HIST_IOSTAT_FILETYPE_NAME
/
grant select on DBA_HIST_IOSTAT_FILETYPE_NAME to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_IOSTAT_DETAIL
 ***************************************/

create or replace view DBA_HIST_IOSTAT_DETAIL
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   FUNCTION_ID, FUNCTION_NAME, FILETYPE_ID, FILETYPE_NAME,
   SMALL_READ_MEGABYTES, SMALL_WRITE_MEGABYTES, 
   LARGE_READ_MEGABYTES, LARGE_WRITE_MEGABYTES,
   SMALL_READ_REQS, SMALL_WRITE_REQS, LARGE_READ_REQS, LARGE_WRITE_REQS,
   NUMBER_OF_WAITS, WAIT_TIME) 
as
select io.snap_id, io.dbid, io.instance_number, 
       io.function_id, nmfn.function_name, 
       io.filetype_id, nmft.filetype_name,
       io.small_read_megabytes, io.small_write_megabytes, 
       io.large_read_megabytes, io.large_write_megabytes,
       io.small_read_reqs, io.small_write_reqs, 
       io.large_read_reqs, io.large_write_reqs,
       io.number_of_waits, io.wait_time
  from  wrm$_snapshot sn, 
        WRH$_IOSTAT_DETAIL io, 
        WRH$_IOSTAT_FUNCTION_NAME nmfn, WRH$_IOSTAT_FILETYPE_NAME nmft
  where     sn.snap_id         = io.snap_id
        and sn.dbid            = io.dbid
        and sn.instance_number = io.instance_number
        and sn.status          = 0
        and io.function_id     = nmfn.function_id
        and io.dbid            = nmfn.dbid
        and io.filetype_id     = nmft.filetype_id
        and io.dbid            = nmft.dbid
/
comment on table DBA_HIST_IOSTAT_DETAIL is
'Historical I/O statistics by function and filetype'
/
create or replace public synonym DBA_HIST_IOSTAT_DETAIL
  for DBA_HIST_IOSTAT_DETAIL
/
grant select on DBA_HIST_IOSTAT_DETAIL to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_RSRC_CONSUMER_GROUP
 ***************************************/

create or replace view DBA_HIST_RSRC_CONSUMER_GROUP
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   SEQUENCE#,
   CONSUMER_GROUP_ID, 
   CONSUMER_GROUP_NAME, 
   REQUESTS,
   CPU_WAIT_TIME, 
   CPU_WAITS,
   CONSUMED_CPU_TIME,
   YIELDS,
   ACTIVE_SESS_LIMIT_HIT,
   UNDO_LIMIT_HIT,
   SWITCHES_IN_CPU_TIME,
   SWITCHES_OUT_CPU_TIME,
   SWITCHES_IN_IO_MEGABYTES,
   SWITCHES_OUT_IO_MEGABYTES,
   SWITCHES_IN_IO_REQUESTS,
   SWITCHES_OUT_IO_REQUESTS,
   SQL_CANCELED,
   ACTIVE_SESS_KILLED,
   IDLE_SESS_KILLED,
   IDLE_BLKR_SESS_KILLED,
   QUEUED_TIME,
   QUEUE_TIME_OUTS,
   IO_SERVICE_TIME,
   IO_SERVICE_WAITS,
   SMALL_READ_MEGABYTES,
   SMALL_WRITE_MEGABYTES,
   LARGE_READ_MEGABYTES,
   LARGE_WRITE_MEGABYTES,
   SMALL_READ_REQUESTS,
   SMALL_WRITE_REQUESTS,
   LARGE_READ_REQUESTS,
   LARGE_WRITE_REQUESTS,
   PQS_QUEUED,
   PQ_QUEUED_TIME,
   PQ_QUEUE_TIME_OUTS,
   PQS_COMPLETED,
   PQ_SERVERS_USED,
   PQ_ACTIVE_TIME)
as
select 
  cg.snap_id,
  cg.dbid,
  cg.instance_number,
  cg.sequence#,
  cg.consumer_group_id,
  cg.consumer_group_name,
  cg.requests,
  cg.cpu_wait_time,
  cg.cpu_waits,
  cg.consumed_cpu_time,
  cg.yields,
  cg.active_sess_limit_hit,
  cg.undo_limit_hit,
  cg.switches_in_cpu_time,
  cg.switches_out_cpu_time,
  cg.switches_in_io_megabytes,
  cg.switches_out_io_megabytes,
  cg.switches_in_io_requests,
  cg.switches_out_io_requests,
  cg.sql_canceled,
  cg.active_sess_killed,
  cg.idle_sess_killed,
  cg.idle_blkr_sess_killed,
  cg.queued_time,
  cg.queue_time_outs,
  cg.io_service_time,
  cg.io_service_waits,
  cg.small_read_megabytes,
  cg.small_write_megabytes,
  cg.large_read_megabytes,
  cg.large_write_megabytes,
  cg.small_read_requests,
  cg.small_write_requests,
  cg.large_read_requests,
  cg.large_write_requests,
  nvl(cg.pqs_queued, 0),
  nvl(cg.pq_queued_time, 0),
  nvl(cg.pq_queue_time_outs, 0),
  nvl(cg.pqs_completed, 0),
  nvl(cg.pq_servers_used, 0),
  nvl(cg.pq_active_time, 0)
  from wrm$_snapshot sn, WRH$_RSRC_CONSUMER_GROUP cg
  where     sn.snap_id         = cg.snap_id
        and sn.dbid            = cg.dbid
        and sn.instance_number = cg.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_RSRC_CONSUMER_GROUP is
'Historical resource consumer group statistics'
/
create or replace public synonym DBA_HIST_RSRC_CONSUMER_GROUP 
  for DBA_HIST_RSRC_CONSUMER_GROUP
/
grant select on DBA_HIST_RSRC_CONSUMER_GROUP to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_RSRC_PLAN
 ***************************************/

create or replace view DBA_HIST_RSRC_PLAN
  (SNAP_ID, DBID, INSTANCE_NUMBER, SEQUENCE#, START_TIME, END_TIME, 
   PLAN_ID, PLAN_NAME, CPU_MANAGED, PARALLEL_EXECUTION_MANAGED)
as
select 
  pl.snap_id,
  pl.dbid,
  pl.instance_number,
  pl.sequence#,
  pl.start_time, 
  pl.end_time, 
  pl.plan_id, 
  pl.plan_name, 
  pl.cpu_managed,
  nvl(pl.parallel_execution_managed, 'OFF')
  from wrm$_snapshot sn, WRH$_RSRC_PLAN pl
  where     sn.snap_id         = pl.snap_id
        and sn.dbid            = pl.dbid
        and sn.instance_number = pl.instance_number
        and sn.status          = 0
/
comment on table DBA_HIST_RSRC_PLAN is
'Historical resource plan statistics'
/
create or replace public synonym DBA_HIST_RSRC_PLAN 
  for DBA_HIST_RSRC_PLAN
/
grant select on DBA_HIST_RSRC_PLAN to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_CLUSTER_INTERCON
 ***************************************/

create or replace view DBA_HIST_CLUSTER_INTERCON
  (SNAP_ID, DBID, INSTANCE_NUMBER, NAME, IP_ADDRESS, 
   IS_PUBLIC, SOURCE)
as
select 
  sn.snap_id, sn.dbid, sn.instance_number,
  ci.name, ci.ip_address, ci.is_public, ci.source
 from wrm$_snapshot sn, WRH$_CLUSTER_INTERCON ci
 where     sn.snap_id         = ci.snap_id
       and sn.dbid            = ci.dbid
       and sn.instance_number = ci.instance_number
       and sn.status          = 0
/
comment on table DBA_HIST_CLUSTER_INTERCON is
'Cluster Interconnect Historical Stats'
/
create or replace public synonym DBA_HIST_CLUSTER_INTERCON 
  for DBA_HIST_CLUSTER_INTERCON
/
grant select on DBA_HIST_CLUSTER_INTERCON to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_MEM_DYNACIC_COMP
 ***************************************/

create or replace view DBA_HIST_MEM_DYNAMIC_COMP
  (SNAP_ID, DBID, INSTANCE_NUMBER, 
   component ,current_size, min_size, max_size,
   user_specified_size, oper_count, last_oper_type,
   last_oper_mode, last_oper_time, granule_size)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  t.component ,t.current_size, t.min_size, t.max_size,
  t.user_specified_size, t.oper_count, t.last_oper_type,
  t.last_oper_mode, t.last_oper_time, t.granule_size
 from wrm$_snapshot sn, WRH$_MEM_DYNAMIC_COMP t
 where     sn.snap_id         = t.snap_id
       and sn.dbid            = t.dbid
       and sn.instance_number = t.instance_number
       and sn.status          = 0
/
comment on table DBA_HIST_MEM_DYNAMIC_COMP is
'Historical memory component sizes'
/
create or replace public synonym DBA_HIST_MEM_DYNAMIC_COMP
  for DBA_HIST_MEM_DYNAMIC_COMP
/
grant select on DBA_HIST_MEM_DYNAMIC_COMP to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_IC_CLIENT_STATS
 ***************************************/

create or replace view DBA_HIST_IC_CLIENT_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   name, bytes_sent, bytes_received)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  t.name, t.bytes_sent, t.bytes_received
 from wrm$_snapshot sn, WRH$_IC_CLIENT_STATS t
 where     sn.snap_id         = t.snap_id
       and sn.dbid            = t.dbid
       and sn.instance_number = t.instance_number
       and sn.status          = 0
/
comment on table DBA_HIST_IC_CLIENT_STATS is
'Historical interconnect client statistics'
/
create or replace public synonym DBA_HIST_IC_CLIENT_STATS
  for DBA_HIST_IC_CLIENT_STATS
/
grant select on DBA_HIST_IC_CLIENT_STATS to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_IC_DEVICE_STATS
 ***************************************/

create or replace view DBA_HIST_IC_DEVICE_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   if_name ,ip_addr ,net_mask ,flags ,mtu ,bytes_received,
   packets_received, receive_errors ,receive_dropped,
   receive_buf_or ,receive_frame_err, bytes_sent ,packets_sent,
   send_errors ,sends_dropped ,send_buf_or, send_carrier_lost)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  t.if_name ,t.ip_addr ,t.net_mask ,t.flags ,t.mtu ,t.bytes_received,
  t.packets_received, t.receive_errors ,t.receive_dropped,
  t.receive_buf_or ,t.receive_frame_err, t.bytes_sent ,t.packets_sent,
  t.send_errors ,t.sends_dropped ,t.send_buf_or, t.send_carrier_lost
 from wrm$_snapshot sn, WRH$_IC_DEVICE_STATS t
 where     sn.snap_id         = t.snap_id
       and sn.dbid            = t.dbid
       and sn.instance_number = t.instance_number
       and sn.status          = 0
/
comment on table DBA_HIST_IC_DEVICE_STATS is
'Historical interconnect device statistics'
/
create or replace public synonym DBA_HIST_IC_DEVICE_STATS
  for DBA_HIST_IC_DEVICE_STATS
/
grant select on DBA_HIST_IC_DEVICE_STATS to SELECT_CATALOG_ROLE
/


/***************************************
 *        DBA_HIST_INTERCONNECT_PINGS
 ***************************************/

create or replace view DBA_HIST_INTERCONNECT_PINGS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   target_instance, cnt_500b, wait_500b, waitsq_500b,
   cnt_8k, wait_8k, waitsq_8k)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  t.target_instance, t.cnt_500b, t.wait_500b, t.waitsq_500b,
  t.cnt_8k, t.wait_8k, t.waitsq_8k
 from wrm$_snapshot sn, WRH$_INTERCONNECT_PINGS t
 where     sn.snap_id         = t.snap_id
       and sn.dbid            = t.dbid
       and sn.instance_number = t.instance_number
       and sn.status          = 0
/
comment on table DBA_HIST_INTERCONNECT_PINGS is
'Instance to instance ping stats'
/
create or replace public synonym DBA_HIST_INTERCONNECT_PINGS
  for DBA_HIST_INTERCONNECT_PINGS
/
grant select on DBA_HIST_INTERCONNECT_PINGS to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_DISPATCHER
 ***************************************/

create or replace view DBA_HIST_DISPATCHER
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   name, serial#, idle, busy, wait, totalq, sampled_total_conn)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  d.name, d.serial#, d.idle, d.busy, d.wait, d.totalq, d.sampled_total_conn
from WRM$_SNAPSHOT sn, WRH$_DISPATCHER d
where     sn.snap_id         = d.snap_id
      and sn.dbid            = d.dbid
      and sn.instance_number = d.instance_number
      and sn.status          = 0
/
comment on table DBA_HIST_DISPATCHER is
'Dispatcher statistics'
/
create or replace public synonym DBA_HIST_DISPATCHER
    for DBA_HIST_DISPATCHER
/
grant select on DBA_HIST_DISPATCHER to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_SHARED_SERVER_SUMMARY
 ***************************************/

create or replace view DBA_HIST_SHARED_SERVER_SUMMARY
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   num_samples, sample_time, 
   sampled_total_conn, sampled_active_conn,
   sampled_total_srv, sampled_active_srv,
   sampled_total_disp, sampled_active_disp,
   srv_busy, srv_idle, srv_in_net, srv_out_net, srv_messages, srv_bytes,
   cq_wait, cq_totalq,
   dq_totalq)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
  s.num_samples, s.sample_time, 
  s.sampled_total_conn, s.sampled_active_conn,
  s.sampled_total_srv, s.sampled_active_srv,
  s.sampled_total_disp, s.sampled_active_disp,
  s.srv_busy, s.srv_idle, s.srv_in_net, s.srv_out_net, 
  s.srv_messages, s.srv_bytes,
  s.cq_wait, s.cq_totalq,
  s.dq_totalq  
from WRM$_SNAPSHOT sn, WRH$_SHARED_SERVER_SUMMARY s
where     sn.snap_id         = s.snap_id
      and sn.dbid            = s.dbid
      and sn.instance_number = s.instance_number
      and sn.status          = 0
/
comment on table DBA_HIST_SHARED_SERVER_SUMMARY is
'Shared Server summary statistics'
/
create or replace public synonym DBA_HIST_SHARED_SERVER_SUMMARY
  for DBA_HIST_SHARED_SERVER_SUMMARY
/
grant select on DBA_HIST_SHARED_SERVER_SUMMARY to SELECT_CATALOG_ROLE
/

/***************************************
 *        DBA_HIST_DYN_REMASTER_STATS
 ***************************************/

create or replace view DBA_HIST_DYN_REMASTER_STATS
  (SNAP_ID, DBID, INSTANCE_NUMBER,
   remaster_ops, remaster_time, remastered_objects, 
   quiesce_time, freeze_time, cleanup_time, 
   replay_time, fixwrite_time, sync_time, 
   resources_cleaned, replayed_locks_sent, 
   replayed_locks_received, current_objects)
as
select
  sn.snap_id, sn.dbid, sn.instance_number,
   s.remaster_ops, s.remaster_time, s.remastered_objects,
   s.quiesce_time, s.freeze_time, s.cleanup_time,
   s.replay_time, s.fixwrite_time, s.sync_time,
   s.resources_cleaned, s.replayed_locks_sent,
   s.replayed_locks_received, s.current_objects
from WRM$_SNAPSHOT sn, WRH$_DYN_REMASTER_STATS s
where     sn.snap_id         = s.snap_id
      and sn.dbid            = s.dbid
      and sn.instance_number = s.instance_number
      and sn.status          = 0
/
comment on table DBA_HIST_DYN_REMASTER_STATS is
'Dynamic remastering statistics'
/
create or replace public synonym DBA_HIST_DYN_REMASTER_STATS
  for DBA_HIST_DYN_REMASTER_STATS
/
grant select on DBA_HIST_DYN_REMASTER_STATS to SELECT_CATALOG_ROLE
/

/*****************************************
 *        DBA_HIST_PERSISTENT_QMN_CACHE
 *****************************************/

create or replace view DBA_HIST_PERSISTENT_QMN_CACHE
  (SNAP_ID, DBID, INSTANCE_NUMBER, QUEUE_TABLE_ID, TYPE, STATUS,
   NEXT_SERVICE_TIME, WINDOW_END_TIME, TOTAL_RUNS, TOTAL_LATENCY,
   TOTAL_ELAPSED_TIME, TOTAL_CPU_TIME, TMGR_ROWS_PROCESSED,
   TMGR_ELAPSED_TIME, TMGR_CPU_TIME, LAST_TMGR_PROCESSING_TIME,
   DEQLOG_ROWS_PROCESSED, DEQLOG_PROCESSING_ELAPSED_TIME,
   DEQLOG_PROCESSING_CPU_TIME, LAST_DEQLOG_PROCESSING_TIME,
   DEQUEUE_INDEX_BLOCKS_FREED, HISTORY_INDEX_BLOCKS_FREED , 
   TIME_INDEX_BLOCKS_FREED, INDEX_CLEANUP_COUNT, INDEX_CLEANUP_ELAPSED_TIME,
   INDEX_CLEANUP_CPU_TIME, LAST_INDEX_CLEANUP_TIME )
as
select pqc.snap_id, pqc.dbid, pqc.instance_number, pqc.queue_table_id,
       pqc.type, pqc.status, pqc.next_service_time, pqc.window_end_time,
       pqc.TOTAL_RUNS, pqc.TOTAL_LATENCY, pqc.TOTAL_ELAPSED_TIME,
       pqc.TOTAL_CPU_TIME, pqc.TMGR_ROWS_PROCESSED, pqc.TMGR_ELAPSED_TIME,
       pqc.TMGR_CPU_TIME, pqc.LAST_TMGR_PROCESSING_TIME,
       pqc.DEQLOG_ROWS_PROCESSED, pqc.DEQLOG_PROCESSING_ELAPSED_TIME,
       pqc.DEQLOG_PROCESSING_CPU_TIME, pqc.LAST_DEQLOG_PROCESSING_TIME,
       pqc.DEQUEUE_INDEX_BLOCKS_FREED, pqc.HISTORY_INDEX_BLOCKS_FREED,
       pqc.TIME_INDEX_BLOCKS_FREED, pqc.INDEX_CLEANUP_COUNT,
       pqc.INDEX_CLEANUP_ELAPSED_TIME, pqc.INDEX_CLEANUP_CPU_TIME, 
       pqc.LAST_INDEX_CLEANUP_TIME
  from wrh$_persistent_qmn_cache pqc, wrm$_snapshot sn
  where     sn.snap_id          = pqc.snap_id
        and sn.dbid             = pqc.dbid
        and sn.instance_number  = pqc.instance_number
        and sn.status           = 0
/

comment on table DBA_HIST_PERSISTENT_QMN_CACHE is
'STREAMS AQ Persistent QMN Cache Historical Statistics Information'
/
create or replace public synonym DBA_HIST_PERSISTENT_QMN_CACHE
    for DBA_HIST_PERSISTENT_QMN_CACHE
/
grant select on DBA_HIST_PERSISTENT_QMN_CACHE to SELECT_CATALOG_ROLE
/
