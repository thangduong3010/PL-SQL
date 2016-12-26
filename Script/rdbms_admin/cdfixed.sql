Rem
Rem $Header: rdbms/admin/cdfixed.sql /st_rdbms_11.2.0/15 2013/03/25 02:00:22 nikgugup Exp $
Rem
Rem cdfixed.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cdfixed.sql - Catalog FIXED views
Rem
Rem    DESCRIPTION
Rem      Objects which reference fixed views.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    youngtak    02/28/13 - Backport youngtak_bug-16223559 from main
Rem    nrcorcor   02/22/13 - Backport nrcorcor_corcoran_trans_12395847_2 / main
Rem    kmeiyyap    02/15/13 - Backport of kmeiyyap_cell_thread_history_rename
Rem                           from main
Rem    kmeiyyap    02/15/13 - Backport of rahkrish_v_oflcellthreadhistory_main
Rem                           from main
Rem    nikgugup    02/12/13 - Backport maniverm_fixedtable from
Rem    apant       02/10/13 - Backport apant_bug-13900198 from main
Rem    lexuxu      02/04/13 - Backport lexuxu_bug-12963089 from main
Rem    huntran     01/21/13 - Backport huntran_bug-14338486 from main
Rem    kamotwan    01/08/13 - Backport kamotwan_featuretracking_1 from main
Rem                           (as kamotwan_bug-15967833)
Rem    jgiloni     11/26/12 - Backport jgiloni_bug-14300206 from main
Rem                           Add DEAD_CLEANUP view
Rem    lzheng      06/15/12 - move gv$goldengate_capture to catcap.sql
Rem    kquinn      05/06/11 - 10357961: correct *_fix_control,
Rem                           *_transportable_platform synonyms
Rem    kquinn      05/10/11 - Backport kquinn_bug-10357961 from main
Rem    huntran     03/15/11 - cdr stats
Rem    huntran     02/08/11 - Backport huntran_bug-11678106 from main
Rem    huntran     02/01/11 - v/gv$goldengate_table_stats
Rem    wbattist    01/19/11 - Backport wbattist_bug-10256769 from main
Rem    smuthuli    08/01/10 - fast space usage changes
Rem    rmao        05/04/10 - rename streams_name/type in
Rem                           g/gv$xstream/goldengate_transaction to
Rem                           component_name/type
Rem    haxu        04/25/10 - add sga_allocated_knstasl
Rem    rmao        04/15/10 - bug 9577760:fix GoldenGate/XStream view problems
Rem    wbattist    03/18/10 - bug 9384642 - add V$HANG_INFO and
Rem                           V$HANG_SESSION_INFO
Rem    rmao        03/29/10 - add v/gv$xstream/goldengate_transaction,
Rem                           v/gv$xstream/goldengate_message_tracking views
Rem    rmao        03/23/10 - add v/gv$xstream/goldengate_capture views
Rem    ssprasad    12/28/09 - add v$asm_acfs_encryption_info
Rem                           add v$asm_acfs_security_info
Rem    slahoran    12/14/09 - bug #8722860 : nls_instance_parameters should
Rem                           depend on v$system_parameter
Rem    adalee      12/07/09 - add v$database_key_info
Rem    shjoshi     11/11/09 - Add synonyms for [g]v$advisor_current_sqlplan
Rem    molagapp    06/03/09 - add recovery_area_usage views
Rem    adalee      05/27/09 - add [g]v$file_optimized_histogram
Rem    mchainan    02/07/09 - Add v$session_blockers and gv$session_blockers
Rem    gravipat    04/21/09 - Add synonyms for v$libcache_locks,
Rem                           gv$libcache_locks
Rem    ssahu       03/31/09 - synonyms for view cpool_conn_info
Rem    shbose      03/24/09 - change [g]v$persistent_tm_cache to
Rem                           [g]v$persistent_qmn_cache
Rem    mbastawa    03/13/09 - make client_result_cache_stats views internal
Rem    arbalakr    02/23/09 - bug 7350685: add GV/V$SQLCOMMAND and 
Rem                           GV/V$TOPLEVELCALL
Rem    bdagevil    02/12/09 - add [g]v$ash_info
Rem    sidatta     12/23/08 - Adding public synonyms for v$cell_config and
Rem                           gv$cell_config
Rem    ethibaul    01/08/09 - remove deprecated ofs syn
Rem    hongyang    01/04/09 - add GV$DATAGUARD_STATS, 
Rem                           remove GV/V$STANDBY_APPLY_SNAPSHOT
Rem    pbelknap    11/19/08 - add V$SQLPA_METRIC
Rem    jgiloni     08/02/08 - Add GV/V$LISTENER_NETWORK
Rem    rlong       08/07/08 - 
Rem    josmith     07/28/08 - Add ACFS view synonyms
Rem    mziauddi    07/31/08 - add G(V)$OBJECT_DML_STATISTICS
Rem    ruqtang     07/14/08 - Change back v$aw_longops to public grant
Rem    nchoudhu    07/14/08 - XbranchMerge nchoudhu_sage_july_merge117 from
Rem                           st_rdbms_11.1.0
Rem    sugpande    07/14/08 - Change v$cell_name to v$cell
Rem    vkolla      04/25/08 - Add [g]v$iostat_function_detail
Rem    atsukerm    04/22/08 - rename OSS views
Rem    mjaiswal    03/10/08 - add QMON (G)V$ views
Rem    nmacnaug    01/28/08 - add v$policy_history
Rem    jiashi      01/12/08 - add v$standby_event_histogram
Rem    bdagevil    12/18/07 - add v$sqlstats_plan_hash
Rem    nchoudhu    12/18/07 - XbranchMerge nchoudhu_sage1_merge from
Rem                           st_rdbms_11.1
Rem    ethibaul    12/11/07 - add v$asm_ofssnapshots
Rem    sugpande    12/05/07 - Add gv$sagecell and v$sagecell
Rem    tbhosle     10/19/07 - public synonyms for v$emon and gv$emon
Rem    amysoren    10/09/07 - add v$wlm_pc_stats, v$wlm_pcmetric and
Rem                           v$wlm_pcmetric_history
Rem    atsukerm    09/14/07 - add OSS fixed views
Rem    hqian       07/19/07 - #6238754: add (g)v$asm_user, (g)v$asm_usergroup,
Rem                           and (g)v$asm_usergroup_member
Rem    ysarig      07/09/07 - Add v$diag_critical_error
Rem    avaliani    03/28/07 - remove v$wait_chains_history
Rem    molagapp    02/27/07 - rename remote_archived_log to foreign_archived_log
Rem    rfrank      02/07/07 - change v$unfs -> v$dnfs
Rem    vkolla      01/23/07 - calibration_results to status
Rem    rfrank      01/12/07 - Add v$unfs_channels
Rem    skaluska    12/01/06 - bug 5679933: remove v$inststat
Rem    arogers     12/04/06 - 5379252 add v$process_group and v$detached_session
Rem    sackulka    11/20/06 - Add V$SECUREFILE_TIMER
Rem    vkolla      11/17/06 - v$io_calibration_results
Rem    slahoran    10/17/06 - Add v$inststat
Rem    gngai       10/02/06 - added v$diaginfo
Rem    jgalanes    10/06/06 - remove synonymns for IDR views since internal
Rem                           only
Rem    ltominna    09/29/06 - lrg-2575704
Rem    averhuls    08/22/06 - Add {g}v_asm_volume, {g}v_asm_volume_stat,
Rem                           {g}v_asm_filesystem, {g}v_asm_ofsvolumes
Rem    esoyleme    05/19/06 - correct privs for v$aw_* 
Rem    mabhatta    09/06/06 - adding v$flashback_txn_* views
Rem    nthombre    08/31/06 - add gv$ and v$sqlfn_metadata
Rem    nthombre    09/05/06 - Added gv$ and v$sqlfn_arg_metadata
Rem    sdizdar     07/17/06 - add synonym gv$, v$_rman_compression_algorithms
Rem    bbaddepu    08/23/06 - bug 5483084: remove dup of resize_ops
Rem    adalee      08/08/06 - add v$encrypted_tablespaces
Rem    rfrank      08/11/06 - add unfs fixed fiews
Rem    bkuchibh    08/03/06 - create incmeter view synonyms
Rem    kamsubra    07/25/06 - add view creation for cpool_stats (fixed views) 
Rem    kamsubra    07/18/06 - renamed cpool views bug 5396075
Rem    rmir        07/10/06 - add public synonyms for v$encryption_wallet and
Rem                           gv$ encryption_wallet
Rem    veeve       07/13/06 - add v$workload_replay_thread
Rem    bdagevil    06/05/06 - add SQL monitoring views ([G]V$SQL_MONITOR and
Rem                           [G]V$SQL_PLAN_MONITOR
Rem    mlfeng      07/10/06 - add iofuncmetric, rsrcmgrmetric 
Rem    mbastawa    07/12/06 - client result cache:synonyms for V$ fixed views
Rem    avaliani    07/11/06 - add v$wait_chains and v$wait_chains_history
Rem    vkapoor     06/30/06 - Bug 5220793 
Rem    mtao        07/07/06 - proj 17789 synonym gv$, v$_remote_archived_log
Rem    sourghos    06/09/06 - add view for WLM 
Rem    mjstewar    06/12/06 - Fix ir_manual_checklist 
Rem    balajkri    06/12/06 - Transaction layer diagnosability features 
Rem    bbaddepu    06/16/06 - add memory_target views
Rem    absaxena    06/02/06 - add public synonyms for subscr_registration_stats
Rem    chliang     05/19/06 - add sscr fixed views
Rem    amadan      05/24/06 - add public synonyms for PERSISTENT_QUEUES 
Rem    dsemler     06/12/06 - reinstate lost views for hm and ir 
Rem    kamsubra    05/19/06 - Adding views for cpool stats 
Rem    rwickrem    05/25/06 - add asm_attribute 
Rem    dsemler     05/30/06 - add in view def lost in ref/merge 
Rem    mzait       05/19/06 - ACS - support for new fixed views 
Rem                            V$SQL_CS_HISTOGRAM
Rem                            V$SQL_CS_SELECTIVITY 
Rem                            V$SQL_CS_STATISTICS 
Rem    vkolla      05/19/06 - Adding iostats fixed views 
Rem    bkuchibh    05/17/06 - create v$hm views,synonyms 
Rem    dsemler     05/17/06 - add fixed view definitions and grants 
Rem    cdilling    05/04/06 - Created
Rem


remark
remark  FAMILY "FIXED (VIRTUAL) VIEWS"
remark


-------------------------------------------------------------------------------
--   GoldenGate/XStream views based on Streams views
--
--   These views are defined here but not in kqfv.h because we want to reuse
-- the definitions of their corresponding streams view to save maintain cost.
-------------------------------------------------------------------------------

create or replace view GV_$XSTREAM_CAPTURE
as
select  INST_ID, SID, SERIAL#, CAPTURE#, CAPTURE_NAME, LOGMINER_ID,
        STARTUP_TIME, STATE, TOTAL_PREFILTER_DISCARDED, TOTAL_PREFILTER_KEPT,
        TOTAL_PREFILTER_EVALUATIONS,TOTAL_MESSAGES_CAPTURED, CAPTURE_TIME,
        CAPTURE_MESSAGE_NUMBER, CAPTURE_MESSAGE_CREATE_TIME,
        TOTAL_MESSAGES_CREATED, TOTAL_FULL_EVALUATIONS,
        TOTAL_MESSAGES_ENQUEUED, ENQUEUE_TIME, ENQUEUE_MESSAGE_NUMBER,
        ENQUEUE_MESSAGE_CREATE_TIME, AVAILABLE_MESSAGE_NUMBER,
        AVAILABLE_MESSAGE_CREATE_TIME, ELAPSED_CAPTURE_TIME,
        ELAPSED_RULE_TIME,ELAPSED_ENQUEUE_TIME,
        ELAPSED_LCR_TIME, ELAPSED_REDO_WAIT_TIME, ELAPSED_PAUSE_TIME, 
        STATE_CHANGED_TIME, 
        SGA_USED, SGA_ALLOCATED, 
        BYTES_OF_REDO_MINED, SESSION_RESTART_SCN
 from gv$streams_capture where purpose = 'XStream';
create or replace public synonym GV$XSTREAM_CAPTURE for GV_$XSTREAM_CAPTURE;
grant select on GV_$XSTREAM_CAPTURE to select_catalog_role;

create or replace view V_$XSTREAM_CAPTURE
as
select  SID, SERIAL#, CAPTURE#, CAPTURE_NAME, LOGMINER_ID,
        STARTUP_TIME, STATE, TOTAL_PREFILTER_DISCARDED, TOTAL_PREFILTER_KEPT,
        TOTAL_PREFILTER_EVALUATIONS,TOTAL_MESSAGES_CAPTURED, CAPTURE_TIME,
        CAPTURE_MESSAGE_NUMBER, CAPTURE_MESSAGE_CREATE_TIME,
        TOTAL_MESSAGES_CREATED, TOTAL_FULL_EVALUATIONS,
        TOTAL_MESSAGES_ENQUEUED, ENQUEUE_TIME, ENQUEUE_MESSAGE_NUMBER,
        ENQUEUE_MESSAGE_CREATE_TIME, AVAILABLE_MESSAGE_NUMBER,
        AVAILABLE_MESSAGE_CREATE_TIME, ELAPSED_CAPTURE_TIME,
        ELAPSED_RULE_TIME,ELAPSED_ENQUEUE_TIME,
        ELAPSED_LCR_TIME, ELAPSED_REDO_WAIT_TIME, ELAPSED_PAUSE_TIME, 
        STATE_CHANGED_TIME,
        SGA_USED, SGA_ALLOCATED, 
        BYTES_OF_REDO_MINED, SESSION_RESTART_SCN
 from gv$xstream_capture where INST_ID = USERENV('Instance');
create or replace public synonym V$XSTREAM_CAPTURE for V_$XSTREAM_CAPTURE;
grant select on V_$XSTREAM_CAPTURE to select_catalog_role;

--gv/v$xstream/goldengate_transaction views
create or replace view gv_$xstream_transaction as
  select INST_Id, STREAMS_NAME COMPONENT_NAME, STREAMS_TYPE COMPONENT_TYPE,
         XIDUSN, XIDSLT, XIDSQN,
         CUMULATIVE_MESSAGE_COUNT, TOTAL_MESSAGE_COUNT,
         FIRST_MESSAGE_TIME, FIRST_MESSAGE_NUMBER,
         LAST_MESSAGE_TIME, LAST_MESSAGE_NUMBER,
         FIRST_MESSAGE_POSITION, LAST_MESSAGE_POSITION, TRANSACTION_ID
    from gv$streams_transaction
   where PURPOSE = 'XStream';
create or replace public synonym gv$xstream_transaction
  for gv_$xstream_transaction;
grant select on gv_$xstream_transaction to select_catalog_role;

create or replace view v_$xstream_transaction as
  select COMPONENT_NAME, COMPONENT_TYPE, XIDUSN, XIDSLT, XIDSQN,
         CUMULATIVE_MESSAGE_COUNT, TOTAL_MESSAGE_COUNT,
         FIRST_MESSAGE_TIME, FIRST_MESSAGE_NUMBER,
         LAST_MESSAGE_TIME, LAST_MESSAGE_NUMBER,
         FIRST_MESSAGE_POSITION, LAST_MESSAGE_POSITION, TRANSACTION_ID
    from gv$xstream_transaction where INST_ID = USERENV('Instance');
create or replace public synonym v$xstream_transaction
  for v_$xstream_transaction;
grant select on v_$xstream_transaction to select_catalog_role;

create or replace view gv_$goldengate_transaction as
  select INST_Id, STREAMS_NAME COMPONENT_NAME, STREAMS_TYPE COMPONENT_TYPE,
         XIDUSN, XIDSLT, XIDSQN,
         CUMULATIVE_MESSAGE_COUNT, TOTAL_MESSAGE_COUNT,
         FIRST_MESSAGE_TIME, FIRST_MESSAGE_NUMBER,
         LAST_MESSAGE_TIME, LAST_MESSAGE_NUMBER,
        cast(utl_raw.cast_to_varchar2(FIRST_MESSAGE_POSITION) as varchar2(64))
           as FIRST_MESSAGE_POSITION,
         cast(utl_raw.cast_to_varchar2(LAST_MESSAGE_POSITION) as varchar2(64))
           as LAST_MESSAGE_POSITION,
         TRANSACTION_ID
    from gv$streams_transaction
   where PURPOSE = 'GoldenGate';
  select * from gv$streams_transaction;
create or replace public synonym gv$goldengate_transaction
  for gv_$goldengate_transaction;
grant select on gv_$goldengate_transaction to select_catalog_role;

create or replace view v_$goldengate_transaction as
  select COMPONENT_NAME, COMPONENT_TYPE, XIDUSN, XIDSLT, XIDSQN,
         CUMULATIVE_MESSAGE_COUNT, TOTAL_MESSAGE_COUNT,
         FIRST_MESSAGE_TIME, FIRST_MESSAGE_NUMBER,
         LAST_MESSAGE_TIME, LAST_MESSAGE_NUMBER,
         FIRST_MESSAGE_POSITION, LAST_MESSAGE_POSITION, TRANSACTION_ID
    from gv$goldengate_transaction where INST_ID = USERENV('Instance');
create or replace public synonym v$goldengate_transaction
  for v_$goldengate_transaction;
grant select on v_$goldengate_transaction to select_catalog_role;

--gv/v$xstream/goldengate_message_tracking views
create or replace view gv_$xstream_message_tracking as
  select INST_ID, TRACKING_LABEL, TAG, COMPONENT_NAME, COMPONENT_TYPE,
         ACTION, ACTION_DETAILS, TIMESTAMP, MESSAGE_CREATION_TIME,
         MESSAGE_NUMBER, TRACKING_ID, SOURCE_DATABASE_NAME, OBJECT_OWNER,
         OBJECT_NAME, XID, COMMAND_TYPE, MESSAGE_POSITION
         from   GV$STREAMS_MESSAGE_TRACKING
         where  PURPOSE = 'XStream';
create or replace public synonym gv$xstream_message_tracking
  for gv_$xstream_message_tracking;
grant select on gv_$xstream_message_tracking to select_catalog_role;

create or replace view v_$xstream_message_tracking as
  select TRACKING_LABEL, TAG, COMPONENT_NAME, COMPONENT_TYPE,
         ACTION, ACTION_DETAILS, TIMESTAMP, MESSAGE_CREATION_TIME,
         MESSAGE_NUMBER, TRACKING_ID, SOURCE_DATABASE_NAME, OBJECT_OWNER,
         OBJECT_NAME, XID, COMMAND_TYPE, MESSAGE_POSITION
         from   GV$XSTREAM_MESSAGE_TRACKING
         where   INST_ID = USERENV('Instance');
create or replace public synonym v$xstream_message_tracking
  for v_$xstream_message_tracking;
grant select on v_$xstream_message_tracking to select_catalog_role;

create or replace view gv_$goldengate_messagetracking as
  select INST_ID, TRACKING_LABEL, TAG, COMPONENT_NAME, COMPONENT_TYPE,
         ACTION, ACTION_DETAILS, TIMESTAMP, MESSAGE_CREATION_TIME,
         MESSAGE_NUMBER, TRACKING_ID, SOURCE_DATABASE_NAME, OBJECT_OWNER,
         OBJECT_NAME, XID, COMMAND_TYPE, MESSAGE_POSITION
         from   GV$STREAMS_MESSAGE_TRACKING
         where  PURPOSE = 'GoldenGate';
create or replace public synonym gv$goldengate_message_tracking
  for gv_$goldengate_messagetracking;
grant select on gv_$goldengate_messagetracking to select_catalog_role;

create or replace view v_$goldengate_message_tracking as
  select TRACKING_LABEL, TAG, COMPONENT_NAME, COMPONENT_TYPE,
         ACTION, ACTION_DETAILS, TIMESTAMP, MESSAGE_CREATION_TIME,
         MESSAGE_NUMBER, TRACKING_ID, SOURCE_DATABASE_NAME, OBJECT_OWNER,
         OBJECT_NAME, XID, COMMAND_TYPE, MESSAGE_POSITION
         from   GV$GOLDENGATE_MESSAGE_TRACKING
         where   INST_ID = USERENV('Instance');
create or replace public synonym v$goldengate_message_tracking
  for v_$goldengate_message_tracking;
grant select on v_$goldengate_message_tracking to select_catalog_role;

create or replace view gv_$goldengate_table_stats as
  select inst_id, server_name, server_id, source_table_owner,
         source_table_name, destination_table_owner, destination_table_name,
         last_update, total_inserts, total_updates, total_deletes,
         insert_collisions, update_collisions, delete_collisions,
         reperror_records, reperror_ignores, wait_dependencies,
         cdr_insert_row_exists, cdr_update_row_exists,
         cdr_update_row_missing, cdr_delete_row_exists,
         cdr_delete_row_missing, 
         cdr_successful_resolutions, cdr_failed_resolutions
         from   gv$xstream_table_stats
         where  purpose = 'GoldenGate';
create or replace public synonym gv$goldengate_table_stats
  for gv_$goldengate_table_stats;
grant select on gv_$goldengate_table_stats to select_catalog_role;

create or replace view v_$goldengate_table_stats as
  select server_name, server_id, source_table_owner,
         source_table_name, destination_table_owner, destination_table_name,
         last_update, total_inserts, total_updates, total_deletes,
         insert_collisions, update_collisions, delete_collisions,
         reperror_records, reperror_ignores, wait_dependencies,
         cdr_insert_row_exists, cdr_update_row_exists,
         cdr_update_row_missing, cdr_delete_row_exists,
         cdr_delete_row_missing, 
         cdr_successful_resolutions, cdr_failed_resolutions
         from gv$goldengate_table_stats where INST_ID = USERENV('Instance');
create or replace public synonym v$goldengate_table_stats
  for v_$goldengate_table_stats;
grant select on v_$goldengate_table_stats to select_catalog_role;

-------------------------------------------------------------------------------
-- end of GoldenGate/XStream views
-------------------------------------------------------------------------------


create or replace view v_$map_library as select * from v$map_library;
create or replace public synonym v$map_library for v_$map_library;
grant select on v_$map_library to select_catalog_role;

create or replace view v_$map_file as select * from v$map_file;
create or replace public synonym v$map_file for v_$map_file;
grant select on v_$map_file to select_catalog_role;

create or replace view v_$map_file_extent as select * from v$map_file_extent;
create or replace public synonym v$map_file_extent for v_$map_file_extent;
grant select on v_$map_file_extent to select_catalog_role;

create or replace view v_$map_element as select * from v$map_element;
create or replace public synonym v$map_element for v_$map_element;
grant select on v_$map_element to select_catalog_role;

create or replace view v_$map_ext_element as select * from v$map_ext_element;
create or replace public synonym v$map_ext_element for v_$map_ext_element;
grant select on v_$map_ext_element to select_catalog_role;

create or replace view v_$map_comp_list as select * from v$map_comp_list;
create or replace public synonym v$map_comp_list for v_$map_comp_list;
grant select on v_$map_comp_list to select_catalog_role;

create or replace view v_$map_subelement as select * from v$map_subelement;
create or replace public synonym v$map_subelement for v_$map_subelement;
grant select on v_$map_subelement to select_catalog_role;

create or replace view v_$map_file_io_stack as select * from v$map_file_io_stack;

create or replace public synonym v$map_file_io_stack for v_$map_file_io_stack;
grant select on v_$map_file_io_stack to select_catalog_role;


create or replace view v_$sql_redirection as select * from v$sql_redirection;
create or replace public synonym v$sql_redirection for v_$sql_redirection;
grant select on v_$sql_redirection to select_catalog_role;

create or replace view v_$sql_plan as select * from v$sql_plan;
create or replace public synonym v$sql_plan for v_$sql_plan;
grant select on v_$sql_plan to select_catalog_role;

create or replace view v_$sql_plan_statistics as
  select * from v$sql_plan_statistics;
create or replace public synonym v$sql_plan_statistics
  for v_$sql_plan_statistics;
grant select on v_$sql_plan_statistics to select_catalog_role;

create or replace view v_$sql_plan_statistics_all as
  select * from v$sql_plan_statistics_all;
create or replace public synonym v$sql_plan_statistics_all
  for v_$sql_plan_statistics_all;
grant select on v_$sql_plan_statistics_all to select_catalog_role;

create or replace view v_$advisor_current_sqlplan as
  select * from v$advisor_current_sqlplan;
create or replace public synonym v$advisor_current_sqlplan
  for v_$advisor_current_sqlplan;
grant select on v_$advisor_current_sqlplan to public;

create or replace view v_$sql_workarea as select * from v$sql_workarea;
create or replace public synonym v$sql_workarea for v_$sql_workarea;
grant select on v_$sql_workarea to select_catalog_role;

create or replace view v_$sql_workarea_active
  as select * from v$sql_workarea_active;
create or replace public synonym v$sql_workarea_active
   for v_$sql_workarea_active;
grant select on v_$sql_workarea_active to select_catalog_role;

create or replace view v_$sql_workarea_histogram
   as select * from v$sql_workarea_histogram;
create or replace public synonym v$sql_workarea_histogram
   for v_$sql_workarea_histogram;
grant select on v_$sql_workarea_histogram to select_catalog_role;

create or replace view v_$pga_target_advice as select * from v$pga_target_advice;
create or replace public synonym v$pga_target_advice for v_$pga_target_advice;
grant select on v_$pga_target_advice to select_catalog_role;

create or replace view v_$pga_target_advice_histogram
  as select * from v$pga_target_advice_histogram;
create or replace public synonym v$pga_target_advice_histogram
  for v_$pga_target_advice_histogram;
grant select on v_$pga_target_advice_histogram to select_catalog_role;

create or replace view v_$pgastat as select * from v$pgastat;
create or replace public synonym v$pgastat for v_$pgastat;
grant select on v_$pgastat to select_catalog_role;

create or replace view v_$sys_optimizer_env
  as select * from v$sys_optimizer_env;
create or replace public synonym v$sys_optimizer_env for v_$sys_optimizer_env;
grant select on v_$sys_optimizer_env to select_catalog_role;

create or replace view v_$ses_optimizer_env
  as select * from v$ses_optimizer_env;
create or replace public synonym v$ses_optimizer_env for v_$ses_optimizer_env;
grant select on v_$ses_optimizer_env to select_catalog_role;

create or replace view v_$sql_optimizer_env
  as select * from v$sql_optimizer_env;
create or replace public synonym v$sql_optimizer_env for v_$sql_optimizer_env;
grant select on v_$sql_optimizer_env to select_catalog_role;

create or replace view v_$dlm_misc as select * from v$dlm_misc;
create or replace public synonym v$dlm_misc for v_$dlm_misc;
grant select on v_$dlm_misc to select_catalog_role;

create or replace view v_$dlm_latch as select * from v$dlm_latch;
create or replace public synonym v$dlm_latch for v_$dlm_latch;
grant select on v_$dlm_latch to select_catalog_role;

create or replace view v_$dlm_convert_local as select * from v$dlm_convert_local;
create or replace public synonym v$dlm_convert_local for v_$dlm_convert_local;
grant select on v_$dlm_convert_local to select_catalog_role;

create or replace view v_$dlm_convert_remote as select * from v$dlm_convert_remote;
create or replace public synonym v$dlm_convert_remote
   for v_$dlm_convert_remote;
grant select on v_$dlm_convert_remote to select_catalog_role;

create or replace view v_$dlm_all_locks as select * from v$dlm_all_locks;
create or replace public synonym v$dlm_all_locks for v_$dlm_all_locks;
grant select on v_$dlm_all_locks to select_catalog_role;

create or replace view v_$dlm_locks as select * from v$dlm_locks;
create or replace public synonym v$dlm_locks for v_$dlm_locks;
grant select on v_$dlm_locks to select_catalog_role;

create or replace view v_$dlm_ress as select * from v$dlm_ress;
create or replace public synonym v$dlm_ress for v_$dlm_ress;
grant select on v_$dlm_ress to select_catalog_role;

create or replace view v_$hvmaster_info as select * from v$hvmaster_info;
create or replace public synonym v$hvmaster_info for v_$hvmaster_info;
grant select on v_$hvmaster_info to select_catalog_role;

create or replace view v_$gcshvmaster_info as select * from v$gcshvmaster_info;
create or replace public synonym v$gcshvmaster_info for v_$gcshvmaster_info;
grant select on v_$gcshvmaster_info to select_catalog_role;

create or replace view v_$gcspfmaster_info as select * from v$gcspfmaster_info;
create or replace public synonym v$gcspfmaster_info for v_$gcspfmaster_info;
grant select on v_$gcspfmaster_info to select_catalog_role;

create or replace view gv_$dlm_traffic_controller as
select * from gv$dlm_traffic_controller;
create or replace public synonym gv$dlm_traffic_controller
   for gv_$dlm_traffic_controller;
grant select on gv_$dlm_traffic_controller to select_catalog_role;

create or replace view v_$dlm_traffic_controller as
select * from v$dlm_traffic_controller;
create or replace public synonym v$dlm_traffic_controller
   for v_$dlm_traffic_controller;
grant select on v_$dlm_traffic_controller to select_catalog_role;

create or replace view gv_$dynamic_remaster_stats 
as select * from gv$dynamic_remaster_stats;
create or replace public synonym gv$dynamic_remaster_stats
                             for gv_$dynamic_remaster_stats;
grant select on gv_$dynamic_remaster_stats to select_catalog_role;

create or replace view v_$dynamic_remaster_stats 
as select * from v$dynamic_remaster_stats;
create or replace public synonym v$dynamic_remaster_stats
                             for v_$dynamic_remaster_stats;
grant select on v_$dynamic_remaster_stats to select_catalog_role;

create or replace view v_$ges_enqueue as
select * from v$ges_enqueue;
create or replace public synonym v$ges_enqueue for v_$ges_enqueue;
grant select on v_$ges_enqueue to select_catalog_role;

create or replace view v_$ges_blocking_enqueue as
select * from v$ges_blocking_enqueue;
create or replace public synonym v$ges_blocking_enqueue
   for v_$ges_blocking_enqueue;
grant select on v_$ges_blocking_enqueue to select_catalog_role;

create or replace view v_$gc_element as
select * from v$gc_element;
create or replace public synonym v$gc_element for v_$gc_element;
grant select on v_$gc_element to select_catalog_role;

create or replace view v_$cr_block_server as
select * from v$cr_block_server;
create or replace public synonym v$cr_block_server for v_$cr_block_server;
grant select on v_$cr_block_server to select_catalog_role;

create or replace view v_$current_block_server as
select * from v$current_block_server;
create or replace public synonym v$current_block_server for v_$current_block_server;
grant select on v_$current_block_server to select_catalog_role;

create or replace view v_$policy_history as
select * from v$policy_history;
create or replace public synonym v$policy_history for v_$policy_history;
grant select on v_$policy_history to select_catalog_role;

create or replace view v_$gc_elements_w_collisions as
select * from v$gc_elements_with_collisions;
create or replace public synonym v$gc_elements_with_collisions
   for v_$gc_elements_w_collisions;
grant select on v_$gc_elements_w_collisions to select_catalog_role;

create or replace view v_$file_cache_transfer as
select * from v$file_cache_transfer;
create or replace public synonym v$file_cache_transfer
   for v_$file_cache_transfer;
grant select on v_$file_cache_transfer to select_catalog_role;

create or replace view v_$temp_cache_transfer as
select * from v$temp_cache_transfer;
create or replace public synonym v$temp_cache_transfer
   for v_$temp_cache_transfer;
grant select on v_$temp_cache_transfer to select_catalog_role;

create or replace view v_$class_cache_transfer as
select * from v$class_cache_transfer;
create or replace public synonym v$class_cache_transfer
   for v_$class_cache_transfer;
grant select on v_$class_cache_transfer to select_catalog_role;

create or replace view v_$bh as select * from v$bh;
create or replace public synonym v$bh for v_$bh;
grant select on v_$bh to public;

create or replace view v_$sqlfn_metadata as
select * from v$sqlfn_metadata;
create or replace public synonym v$sqlfn_metadata
   for v_$sqlfn_metadata;
grant select on v_$sqlfn_metadata to public;

create or replace view v_$sqlfn_arg_metadata as
select * from v$sqlfn_arg_metadata;
create or replace public synonym v$sqlfn_arg_metadata
   for v_$sqlfn_arg_metadata;
grant select on v_$sqlfn_arg_metadata to public;


create or replace view v_$lock_element as select * from v$lock_element;
create or replace public synonym v$lock_element for v_$lock_element;
grant select on v_$lock_element to select_catalog_role;

create or replace view v_$locks_with_collisions as
select * from v$locks_with_collisions;
create or replace public synonym v$locks_with_collisions
   for v_$locks_with_collisions;
grant select on v_$locks_with_collisions to select_catalog_role;

create or replace view v_$file_ping as select * from v$file_ping;
create or replace public synonym v$file_ping for v_$file_ping;
grant select on v_$file_ping to select_catalog_role;

create or replace view v_$temp_ping as select * from v$temp_ping;
create or replace public synonym v$temp_ping for v_$temp_ping;
grant select on v_$temp_ping to select_catalog_role;

create or replace view v_$class_ping as select * from v$class_ping;
create or replace public synonym v$class_ping for v_$class_ping;
grant select on v_$class_ping to select_catalog_role;

create or replace view v_$instance_cache_transfer as
select * from v$instance_cache_transfer;
create or replace public synonym v$instance_cache_transfer
   for v_$instance_cache_transfer;
grant select on v_$instance_cache_transfer to select_catalog_role;

create or replace view v_$buffer_pool as select * from v$buffer_pool;
create or replace public synonym v$buffer_pool for v_$buffer_pool;
grant select on v_$buffer_pool to select_catalog_role;

create or replace view v_$buffer_pool_statistics as
select * from v$buffer_pool_statistics;
create or replace public synonym v$buffer_pool_statistics
   for v_$buffer_pool_statistics;
grant select on v_$buffer_pool_statistics to select_catalog_role;

create or replace view v_$instance_recovery as
select * from v$instance_recovery;
create or replace public synonym v$instance_recovery for v_$instance_recovery;
grant select on v_$instance_recovery to select_catalog_role;

create or replace view v_$controlfile as select * from v$controlfile;
create or replace public synonym v$controlfile for v_$controlfile;
grant select on v_$controlfile to select_catalog_role;

create or replace view v_$log as select * from v$log;
create or replace public synonym v$log for v_$log;
grant select on v_$log to SELECT_CATALOG_ROLE;

create or replace view v_$standby_log as select * from v$standby_log;
create or replace public synonym v$standby_log for v_$standby_log;
grant select on v_$standby_log to SELECT_CATALOG_ROLE;

create or replace view v_$dataguard_status as select * from v$dataguard_status;
create or replace public synonym v$dataguard_status for v_$dataguard_status;
grant select on v_$dataguard_status to SELECT_CATALOG_ROLE;

create or replace view v_$thread as select * from v$thread;
create or replace public synonym v$thread for v_$thread;
grant select on v_$thread to select_catalog_role;

create or replace view v_$process as select * from v$process;
create or replace public synonym v$process for v_$process;
grant select on v_$process to select_catalog_role;

create or replace view v_$bgprocess as select * from v$bgprocess;
create or replace public synonym v$bgprocess for v_$bgprocess;
grant select on v_$bgprocess to select_catalog_role;

create or replace view v_$session as select * from v$session;
create or replace public synonym v$session for v_$session;
grant select on v_$session to select_catalog_role;

create or replace view v_$license as select * from v$license;
create or replace public synonym v$license for v_$license;
grant select on v_$license to select_catalog_role;

create or replace view v_$transaction as select * from v$transaction;
create or replace public synonym v$transaction for v_$transaction;
grant select on v_$transaction to select_catalog_role;

create or replace view v_$bsp as select * from v$bsp;
create or replace public synonym v$bsp for v_$bsp;
grant select on v_$bsp to select_catalog_role;

create or replace view v_$fast_start_servers as
select * from v$fast_start_servers;
create or replace public synonym v$fast_start_servers
   for v_$fast_start_servers;
grant select on v_$fast_start_servers to select_catalog_role;

create or replace view v_$fast_start_transactions
as select * from v$fast_start_transactions;
create or replace public synonym v$fast_start_transactions
   for v_$fast_start_transactions;
grant select on v_$fast_start_transactions to select_catalog_role;

create or replace view v_$locked_object as select * from v$locked_object;
create or replace public synonym v$locked_object for v_$locked_object;
grant select on v_$locked_object to select_catalog_role;

create or replace view v_$latch as select * from v$latch;
create or replace public synonym v$latch for v_$latch;
grant select on v_$latch to select_catalog_role;

create or replace view v_$latch_children as select * from v$latch_children;
create or replace public synonym v$latch_children for v_$latch_children;
grant select on v_$latch_children to select_catalog_role;

create or replace view v_$latch_parent as select * from v$latch_parent;
create or replace public synonym v$latch_parent for v_$latch_parent;
grant select on v_$latch_parent to select_catalog_role;

create or replace view v_$latchname as select * from v$latchname;
create or replace public synonym v$latchname for v_$latchname;
grant select on v_$latchname to select_catalog_role;

create or replace view v_$latchholder as select * from v$latchholder;
create or replace public synonym v$latchholder for v_$latchholder;
grant select on v_$latchholder to select_catalog_role;

create or replace view v_$latch_misses as select * from v$latch_misses;
create or replace public synonym v$latch_misses for v_$latch_misses;
grant select on v_$latch_misses to select_catalog_role;

create or replace view v_$session_longops as select * from v$session_longops;
create or replace public synonym v$session_longops for v_$session_longops;
grant select on v_$session_longops to public;

create or replace view v_$resource as select * from v$resource;
create or replace public synonym v$resource for v_$resource;
grant select on v_$resource to select_catalog_role;

create or replace view v_$_lock as select * from v$_lock;
create or replace public synonym v$_lock for v_$_lock;
grant select on v_$_lock to select_catalog_role;

create or replace view v_$lock as select * from v$lock;
create or replace public synonym v$lock for v_$lock;
grant select on v_$lock to select_catalog_role;

create or replace view v_$sesstat as select * from v$sesstat;
create or replace public synonym v$sesstat for v_$sesstat;
grant select on v_$sesstat to select_catalog_role;

create or replace view v_$mystat as select * from v$mystat;
create or replace public synonym v$mystat for v_$mystat;
grant select on v_$mystat to select_catalog_role;

create or replace view v_$subcache as select * from v$subcache;
create or replace public synonym v$subcache for v_$subcache;
grant select on v_$subcache to select_catalog_role;

create or replace view v_$sysstat as select * from v$sysstat;
create or replace public synonym v$sysstat for v_$sysstat;
grant select on v_$sysstat to select_catalog_role;

create or replace view v_$statname as select * from v$statname;
create or replace public synonym v$statname for v_$statname;
grant select on v_$statname to select_catalog_role;

create or replace view v_$osstat as select * from v$osstat;
create or replace public synonym v$osstat for v_$osstat;
grant select on v_$osstat to select_catalog_role;

create or replace view v_$access as select * from v$access;
create or replace public synonym v$access for v_$access;
grant select on v_$access to select_catalog_role;

create or replace view v_$object_dependency as
  select * from v$object_dependency;
create or replace public synonym v$object_dependency for v_$object_dependency;
grant select on v_$object_dependency to select_catalog_role;

create or replace view v_$dbfile as select * from v$dbfile;
create or replace public synonym v$dbfile for v_$dbfile;
grant select on v_$dbfile to select_catalog_role;

create or replace view v_$filestat as select * from v$filestat;
create or replace public synonym v$filestat for v_$filestat;
grant select on v_$filestat to select_catalog_role;

create or replace view v_$tempstat as select * from v$tempstat;
create or replace public synonym v$tempstat for v_$tempstat;
grant select on v_$tempstat to select_catalog_role;

create or replace view v_$logfile as select * from v$logfile;
create or replace public synonym v$logfile for v_$logfile;
grant select on v_$logfile to select_catalog_role;

create or replace view v_$flashback_database_logfile as
  select * from v$flashback_database_logfile;
create or replace public synonym v$flashback_database_logfile
  for v_$flashback_database_logfile;
grant select on v_$flashback_database_logfile to select_catalog_role;

create or replace view v_$flashback_database_log as
  select * from v$flashback_database_log;
create or replace public synonym v$flashback_database_log
  for v_$flashback_database_log;
grant select on v_$flashback_database_log to select_catalog_role;

create or replace view v_$flashback_database_stat as
  select * from v$flashback_database_stat;
create or replace public synonym v$flashback_database_stat
  for v_$flashback_database_stat;
grant select on v_$flashback_database_stat to select_catalog_role;

create or replace view v_$restore_point as
  select * from v$restore_point;
create or replace public synonym v$restore_point
  for v_$restore_point;
grant select on v_$restore_point to public;

create or replace view v_$rollname as select x$kturd.kturdusn usn,undo$.name
   from x$kturd, undo$
   where x$kturd.kturdusn=undo$.us# and x$kturd.kturdsiz!=0;
create or replace public synonym v$rollname for v_$rollname;
grant select on v_$rollname to select_catalog_role;

create or replace view v_$rollstat as select * from v$rollstat;
create or replace public synonym v$rollstat for v_$rollstat;
grant select on v_$rollstat to select_catalog_role;

create or replace view v_$undostat as select * from v$undostat;
create or replace public synonym v$undostat for v_$undostat;
grant select on v_$undostat to select_catalog_role;

create or replace view v_$sga as select * from v$sga;
create or replace public synonym v$sga for v_$sga;
grant select on v_$sga to select_catalog_role;

create or replace view v_$cluster_interconnects 
       as select * from v$cluster_interconnects;
create or replace public synonym v$cluster_interconnects 
       for v_$cluster_interconnects;
grant select on v_$cluster_interconnects to select_catalog_role;

create or replace view v_$configured_interconnects 
       as select * from v$configured_interconnects;
create or replace public synonym v$configured_interconnects 
       for v_$configured_interconnects;
grant select on v_$configured_interconnects to select_catalog_role;

create or replace view v_$parameter as select * from v$parameter;
create or replace public synonym v$parameter for v_$parameter;
grant select on v_$parameter to select_catalog_role;

create or replace view v_$parameter2 as select * from v$parameter2;
create or replace public synonym v$parameter2 for v_$parameter2;
grant select on v_$parameter2 to select_catalog_role;

create or replace view v_$obsolete_parameter as
  select * from v$obsolete_parameter;
create or replace public synonym v$obsolete_parameter
   for v_$obsolete_parameter;
grant select on v_$obsolete_parameter to select_catalog_role;

create or replace view v_$system_parameter as select * from v$system_parameter;
create or replace public synonym v$system_parameter for v_$system_parameter;
grant select on v_$system_parameter to select_catalog_role;

create or replace view v_$system_parameter2 as select * from v$system_parameter2;
create or replace public synonym v$system_parameter2 for v_$system_parameter2;
grant select on v_$system_parameter2 to select_catalog_role;

create or replace view v_$spparameter as select * from v$spparameter;
create or replace public synonym v$spparameter for v_$spparameter;
grant select on v_$spparameter to select_catalog_role;

create or replace view v_$parameter_valid_values 
       as select * from v$parameter_valid_values;
create or replace public synonym v$parameter_valid_values 
       for v_$parameter_valid_values;
grant select on v_$parameter_valid_values to select_catalog_role;

create or replace view v_$rowcache as select * from v$rowcache;
create or replace public synonym v$rowcache for v_$rowcache;
grant select on v_$rowcache to select_catalog_role;

create or replace view v_$rowcache_parent as select * from v$rowcache_parent;
create or replace public synonym v$rowcache_parent for v_$rowcache_parent;
grant select on v_$rowcache_parent to select_catalog_role;

create or replace view v_$rowcache_subordinate as
  select * from v$rowcache_subordinate;
create or replace public synonym v$rowcache_subordinate
   for v_$rowcache_subordinate;
grant select on v_$rowcache_subordinate to select_catalog_role;

create or replace view v_$enabledprivs as select * from v$enabledprivs;
create or replace public synonym v$enabledprivs for v_$enabledprivs;
grant select on v_$enabledprivs to select_catalog_role;

create or replace view v_$nls_parameters as select * from v$nls_parameters;
create or replace public synonym v$nls_parameters for v_$nls_parameters;
grant select on v_$nls_parameters to public;

create or replace view v_$nls_valid_values as
select * from v$nls_valid_values;
create or replace public synonym v$nls_valid_values for v_$nls_valid_values;
grant select on v_$nls_valid_values to public;

create or replace view v_$librarycache as select * from v$librarycache;
create or replace public synonym v$librarycache for v_$librarycache;
grant select on v_$librarycache to select_catalog_role;

create or replace view v_$libcache_locks as select * from v$libcache_locks;
create or replace public synonym v$libcache_locks for v_$libcache_locks;
grant select on v_$libcache_locks to select_catalog_role;

create or replace view v_$type_size as select * from v$type_size;
create or replace public synonym v$type_size for v_$type_size;
grant select on v_$type_size to select_catalog_role;

create or replace view v_$archive as select * from v$archive;
create or replace public synonym v$archive for v_$archive;
grant select on v_$archive to select_catalog_role;

create or replace view v_$circuit as select * from v$circuit;
create or replace public synonym v$circuit for v_$circuit;
grant select on v_$circuit to select_catalog_role;

create or replace view v_$database as select * from v$database;
create or replace public synonym v$database for v_$database;
grant select on v_$database to select_catalog_role;

create or replace view v_$instance as select * from v$instance;
create or replace public synonym v$instance for v_$instance;
grant select on v_$instance to select_catalog_role;

create or replace view v_$dispatcher as select * from v$dispatcher;
create or replace public synonym v$dispatcher for v_$dispatcher;
grant select on v_$dispatcher to select_catalog_role;

create or replace view v_$dispatcher_config
  as select * from v$dispatcher_config;
create or replace public synonym v$dispatcher_config for v_$dispatcher_config;
grant select on v_$dispatcher_config to select_catalog_role;

create or replace view v_$dispatcher_rate as select * from v$dispatcher_rate;
create or replace public synonym v$dispatcher_rate for v_$dispatcher_rate;
grant select on v_$dispatcher_rate to select_catalog_role;

create or replace view v_$loghist as select * from v$loghist;
create or replace public synonym v$loghist for v_$loghist;
grant select on v_$loghist to select_catalog_role;

REM create or replace view v_$plsarea as select * from v$plsarea;
REM create or replace public synonym v$plsarea for v_$plsarea;

create or replace view v_$sqlarea as select * from v$sqlarea;
create or replace public synonym v$sqlarea for v_$sqlarea;
grant select on v_$sqlarea to select_catalog_role;

create or replace view v_$sqlarea_plan_hash 
        as select * from v$sqlarea_plan_hash;
create or replace public synonym v$sqlarea_plan_hash for v_$sqlarea_plan_hash;
grant select on v_$sqlarea_plan_hash to select_catalog_role;

create or replace view v_$sqltext as select * from v$sqltext;
create or replace public synonym v$sqltext for v_$sqltext;
grant select on v_$sqltext to select_catalog_role;

create or replace view v_$sqltext_with_newlines as
      select * from v$sqltext_with_newlines;
create or replace public synonym v$sqltext_with_newlines
   for v_$sqltext_with_newlines;
grant select on v_$sqltext_with_newlines to select_catalog_role;

create or replace view v_$sql as select * from v$sql;
create or replace public synonym v$sql for v_$sql;
grant select on v_$sql to select_catalog_role;

create or replace view v_$sql_shared_cursor as select * from v$sql_shared_cursor;
create or replace public synonym v$sql_shared_cursor for v_$sql_shared_cursor;
grant select on v_$sql_shared_cursor to select_catalog_role;

create or replace view v_$db_pipes as select * from v$db_pipes;
create or replace public synonym v$db_pipes for v_$db_pipes;
grant select on v_$db_pipes to select_catalog_role;

create or replace view v_$db_object_cache as select * from v$db_object_cache;
create or replace public synonym v$db_object_cache for v_$db_object_cache;
grant select on v_$db_object_cache to select_catalog_role;

create or replace view v_$open_cursor as select * from v$open_cursor;
create or replace public synonym v$open_cursor for v_$open_cursor;
grant select on v_$open_cursor to select_catalog_role;

create or replace view v_$option as select * from v$option;
create or replace public synonym v$option for v_$option;
grant select on v_$option to public;

create or replace view v_$version as select * from v$version;
create or replace public synonym v$version for v_$version;
grant select on v_$version to public;

create or replace view v_$pq_sesstat as select * from v$pq_sesstat;
create or replace public synonym v$pq_sesstat for v_$pq_sesstat;
grant select on v_$pq_sesstat to public;

create or replace view v_$pq_sysstat as select * from v$pq_sysstat;
create or replace public synonym v$pq_sysstat for v_$pq_sysstat;
grant select on v_$pq_sysstat to select_catalog_role;

create or replace view v_$pq_slave as select * from v$pq_slave;
create or replace public synonym v$pq_slave for v_$pq_slave;
grant select on v_$pq_slave to select_catalog_role;

create or replace view v_$queue as select * from v$queue;
create or replace public synonym v$queue for v_$queue;
grant select on v_$queue to select_catalog_role;

create or replace view v_$shared_server_monitor as select * from v$shared_server_monitor;
create or replace public synonym v$shared_server_monitor
   for v_$shared_server_monitor;
grant select on v_$shared_server_monitor to select_catalog_role;

create or replace view v_$dblink as select * from v$dblink;
create or replace public synonym v$dblink for v_$dblink;
grant select on v_$dblink to select_catalog_role;

create or replace view v_$pwfile_users as select * from v$pwfile_users;
create or replace public synonym v$pwfile_users for v_$pwfile_users;
grant select on v_$pwfile_users to select_catalog_role;

create or replace view v_$reqdist as select * from v$reqdist;
create or replace public synonym v$reqdist for v_$reqdist;
grant select on v_$reqdist to select_catalog_role;

create or replace view v_$sgastat as select * from v$sgastat;
create or replace public synonym v$sgastat for v_$sgastat;
grant select on v_$sgastat to select_catalog_role;

create or replace view v_$sgainfo as select * from v$sgainfo;
create or replace public synonym v$sgainfo for v_$sgainfo;
grant select on v_$sgainfo to select_catalog_role;

create or replace view v_$waitstat as select * from v$waitstat;
create or replace public synonym v$waitstat for v_$waitstat;
grant select on v_$waitstat to select_catalog_role;

create or replace view v_$shared_server as select * from v$shared_server;
create or replace public synonym v$shared_server for v_$shared_server;
grant select on v_$shared_server to select_catalog_role;

create or replace view v_$timer as select * from v$timer;
create or replace public synonym v$timer for v_$timer;
grant select on v_$timer to select_catalog_role;

create or replace view v_$recover_file as select * from v$recover_file;
create or replace public synonym v$recover_file for v_$recover_file;
grant select on v_$recover_file to select_catalog_role;

create or replace view v_$backup as select * from v$backup;
create or replace public synonym v$backup for v_$backup;
grant select on v_$backup to select_catalog_role;


create or replace view v_$backup_set as select * from v$backup_set;
create or replace public synonym v$backup_set for v_$backup_set;
grant select on v_$backup_set to select_catalog_role;

create or replace view v_$backup_piece as select * from v$backup_piece;
create or replace public synonym v$backup_piece for v_$backup_piece;
grant select on v_$backup_piece to select_catalog_role;

create or replace view v_$backup_datafile as select * from v$backup_datafile;
create or replace public synonym v$backup_datafile for v_$backup_datafile;
grant select on v_$backup_datafile to select_catalog_role;

create or replace view v_$backup_spfile as select * from v$backup_spfile;
create or replace public synonym v$backup_spfile for v_$backup_spfile;
grant select on v_$backup_spfile to select_catalog_role;

create or replace view v_$backup_redolog as select * from v$backup_redolog;
create or replace public synonym v$backup_redolog for v_$backup_redolog;
grant select on v_$backup_redolog to select_catalog_role;

create or replace view v_$backup_corruption as select * from v$backup_corruption;
create or replace public synonym v$backup_corruption for v_$backup_corruption;
grant select on v_$backup_corruption to select_catalog_role;

create or replace view v_$copy_corruption as select * from v$copy_corruption;
create or replace public synonym v$copy_corruption for v_$copy_corruption;
grant select on v_$copy_corruption to select_catalog_role;

create or replace view v_$database_block_corruption as select * from
   v$database_block_corruption;
create or replace public synonym v$database_block_corruption
   for v_$database_block_corruption;
grant select on v_$database_block_corruption to select_catalog_role;

create or replace view v_$mttr_target_advice as select * from
   v$mttr_target_advice;
create or replace public synonym v$mttr_target_advice
   for v_$mttr_target_advice;
grant select on v_$mttr_target_advice to select_catalog_role;

create or replace view v_$statistics_level as select * from
   v$statistics_level;
create or replace public synonym v$statistics_level
   for v_$statistics_level;
grant select on v_$statistics_level to select_catalog_role;

create or replace view v_$deleted_object as select * from v$deleted_object;
create or replace public synonym v$deleted_object for v_$deleted_object;
grant select on v_$deleted_object to select_catalog_role;

create or replace view v_$proxy_datafile as select * from v$proxy_datafile;
create or replace public synonym v$proxy_datafile for v_$proxy_datafile;
grant select on v_$proxy_datafile to select_catalog_role;

create or replace view v_$proxy_archivedlog as select * from v$proxy_archivedlog;
create or replace public synonym v$proxy_archivedlog for v_$proxy_archivedlog;
grant select on v_$proxy_archivedlog to select_catalog_role;

create or replace view v_$controlfile_record_section as select * from v$controlfile_record_section;
create or replace public synonym v$controlfile_record_section
   for v_$controlfile_record_section;
grant select on v_$controlfile_record_section to select_catalog_role;

create or replace view v_$archived_log as select * from v$archived_log;
create or replace public synonym v$archived_log for v_$archived_log;
grant select on v_$archived_log to select_catalog_role;

create or replace view v_$foreign_archived_log as select * from v$foreign_archived_log;
create or replace public synonym v$foreign_archived_log for v_$foreign_archived_log;
grant select on v_$foreign_archived_log to select_catalog_role;

create or replace view v_$offline_range as select * from v$offline_range;
create or replace public synonym v$offline_range for v_$offline_range;
grant select on v_$offline_range to select_catalog_role;

create or replace view v_$datafile_copy as select * from v$datafile_copy;
create or replace public synonym v$datafile_copy for v_$datafile_copy;
grant select on v_$datafile_copy to select_catalog_role;

create or replace view v_$log_history as select * from v$log_history;
create or replace public synonym v$log_history for v_$log_history;
grant select on v_$log_history to select_catalog_role;

create or replace view v_$recovery_log as select * from v$recovery_log;
create or replace public synonym v$recovery_log for v_$recovery_log;
grant select on v_$recovery_log to select_catalog_role;

create or replace view v_$archive_gap as select * from v$archive_gap;
create or replace public synonym v$archive_gap for v_$archive_gap;
grant select on v_$archive_gap to select_catalog_role;

create or replace view v_$datafile_header as select * from v$datafile_header;
create or replace public synonym v$datafile_header for v_$datafile_header;
grant select on v_$datafile_header to select_catalog_role;

create or replace view v_$datafile as select * from v$datafile;
create or replace public synonym v$datafile for v_$datafile;
grant select on v_$datafile to SELECT_CATALOG_ROLE;

create or replace view v_$tempfile as select * from v$tempfile;
create or replace public synonym v$tempfile for v_$tempfile;
grant select on v_$tempfile to SELECT_CATALOG_ROLE;

create or replace view v_$tablespace as select * from v$tablespace;
create or replace public synonym v$tablespace for v_$tablespace;
grant select on v_$tablespace to select_catalog_role;

create or replace view v_$backup_device as select * from v$backup_device;
create or replace public synonym v$backup_device for v_$backup_device;
grant select on v_$backup_device to select_catalog_role;

create or replace view v_$managed_standby as select * from v$managed_standby;
create or replace public synonym v$managed_standby for v_$managed_standby;
grant select on v_$managed_standby to select_catalog_role;

create or replace view v_$archive_processes as select * from v$archive_processes;
create or replace public synonym v$archive_processes for v_$archive_processes;
grant select on v_$archive_processes to select_catalog_role;

create or replace view v_$archive_dest as select * from v$archive_dest;
create or replace public synonym v$archive_dest for v_$archive_dest;
grant select on v_$archive_dest to select_catalog_role;

create or replace view v_$redo_dest_resp_histogram as 
  select * from v$redo_dest_resp_histogram;
create or replace public synonym v$redo_dest_resp_histogram for 
  v_$redo_dest_resp_histogram;
grant select on v_$redo_dest_resp_histogram to select_catalog_role;

create or replace view v_$dataguard_config as select * from v$dataguard_config;
create or replace public synonym v$dataguard_config for v_$dataguard_config;
grant select on v_$dataguard_config to select_catalog_role;

create or replace view v_$dataguard_stats as select * from v$dataguard_stats;
create or replace public synonym v$dataguard_stats for v_$dataguard_stats;
grant select on v_$dataguard_stats to select_catalog_role;

create or replace view v_$fixed_table as select * from v$fixed_table;
create or replace public synonym v$fixed_table for v_$fixed_table;
grant select on v_$fixed_table to select_catalog_role;

create or replace view v_$fixed_view_definition as
   select * from v$fixed_view_definition;
create or replace public synonym v$fixed_view_definition
   for v_$fixed_view_definition;
grant select on v_$fixed_view_definition to select_catalog_role;

create or replace view v_$indexed_fixed_column as
  select * from v$indexed_fixed_column;
create or replace public synonym v$indexed_fixed_column
   for v_$indexed_fixed_column;
grant select on v_$indexed_fixed_column to select_catalog_role;

create or replace view v_$session_cursor_cache as
  select * from v$session_cursor_cache;
create or replace public synonym v$session_cursor_cache
   for v_$session_cursor_cache;
grant select on v_$session_cursor_cache to select_catalog_role;

create or replace view v_$session_wait_class as
  select * from v$session_wait_class;
create or replace public synonym v$session_wait_class for v_$session_wait_class;
grant select on v_$session_wait_class to select_catalog_role;

create or replace view v_$session_wait as
  select * from v$session_wait;
create or replace public synonym v$session_wait for v_$session_wait;
grant select on v_$session_wait to select_catalog_role;

create or replace view v_$session_wait_history as
  select * from v$session_wait_history;
create or replace public synonym v$session_wait_history for
  v_$session_wait_history;
grant select on v_$session_wait_history to select_catalog_role;
 
create or replace view v_$session_blockers as
  select * from v$session_blockers;
create or replace public synonym v$session_blockers for
  v_$session_blockers;
grant select on v_$session_blockers to select_catalog_role; 

create or replace view v_$wait_chains as
  select * from v$wait_chains;
create or replace public synonym v$wait_chains for v_$wait_chains;
grant select on v_$wait_chains to select_catalog_role;

create or replace view v_$session_event as
  select * from v$session_event;
create or replace public synonym v$session_event for v_$session_event;
grant select on v_$session_event to select_catalog_role;

create or replace view v_$session_connect_info as
  select * from v$session_connect_info;
create or replace public synonym v$session_connect_info
   for v_$session_connect_info;
grant select on v_$session_connect_info to public;

create or replace view v_$system_wait_class as
  select * from v$system_wait_class;
create or replace public synonym v$system_wait_class for v_$system_wait_class;
grant select on v_$system_wait_class to select_catalog_role;

create or replace view v_$system_event as
  select * from v$system_event;
create or replace public synonym v$system_event for v_$system_event;
grant select on v_$system_event to select_catalog_role;

create or replace view v_$event_name as
  select * from v$event_name;
create or replace public synonym v$event_name for v_$event_name;
grant select on v_$event_name to select_catalog_role;

create or replace view v_$event_histogram as
  select * from v$event_histogram;
create or replace public synonym v$event_histogram for v_$event_histogram;
grant select on v_$event_histogram to select_catalog_role;

create or replace view v_$file_histogram as
  select * from v$file_histogram;
create or replace public synonym v$file_histogram for v_$file_histogram;
grant select on v_$file_histogram to select_catalog_role;

create or replace view v_$file_optimized_histogram as
  select * from v$file_optimized_histogram;
create or replace public synonym v$file_optimized_histogram 
  for v_$file_optimized_histogram;
grant select on v_$file_optimized_histogram to select_catalog_role;

create or replace view v_$execution as
  select * from v$execution;
create or replace public synonym v$execution for v_$execution;
grant select on v_$execution to select_catalog_role;

create or replace view v_$system_cursor_cache as
  select * from v$system_cursor_cache;
create or replace public synonym v$system_cursor_cache
   for v_$system_cursor_cache;
grant select on v_$system_cursor_cache to select_catalog_role;

create or replace view v_$sess_io as
  select * from v$sess_io;
create or replace public synonym v$sess_io for v_$sess_io;
grant select on v_$sess_io to select_catalog_role;

create or replace view v_$recovery_status as
  select * from v$recovery_status;
create or replace public synonym v$recovery_status for v_$recovery_status;
grant select on v_$recovery_status to select_catalog_role;

create or replace view v_$recovery_file_status as
  select * from v$recovery_file_status;
create or replace public synonym v$recovery_file_status
   for v_$recovery_file_status;
grant select on v_$recovery_file_status to select_catalog_role;

create or replace view v_$recovery_progress as
  select * from v$recovery_progress;
create or replace public synonym v$recovery_progress for v_$recovery_progress;
grant select on v_$recovery_progress to select_catalog_role;

create or replace view v_$shared_pool_reserved as
  select * from v$shared_pool_reserved;
create or replace public synonym v$shared_pool_reserved
   for v_$shared_pool_reserved;
grant select on v_$shared_pool_reserved to select_catalog_role;

create or replace view v_$sort_segment as select * from v$sort_segment;
create or replace public synonym v$sort_segment for v_$sort_segment;
grant select on v_$sort_segment to select_catalog_role;

create or replace view v_$sort_usage as select * from v$sort_usage;
create or replace public synonym v$tempseg_usage for v_$sort_usage;
create or replace public synonym v$sort_usage for v_$sort_usage;
grant select on v_$sort_usage to select_catalog_role;

create or replace view v_$resource_limit as select * from v$resource_limit;
create or replace public synonym v$resource_limit for v_$resource_limit;
grant select on v_$resource_limit to select_catalog_role;

create or replace view v_$enqueue_lock as select * from v$enqueue_lock;
create or replace public synonym v$enqueue_lock for v_$enqueue_lock;
grant select on v_$enqueue_lock to select_catalog_role;

create or replace view v_$transaction_enqueue as select * from v$transaction_enqueue;
create or replace public synonym v$transaction_enqueue
   for v_$transaction_enqueue;
grant select on v_$transaction_enqueue to select_catalog_role;

create or replace view v_$pq_tqstat as select * from v$pq_tqstat;
create or replace public synonym v$pq_tqstat for v_$pq_tqstat;
grant select on v_$pq_tqstat to public;

create or replace view v_$active_instances as select * from v$active_instances;
create or replace public synonym v$active_instances for v_$active_instances;
grant select on v_$active_instances to public;

create or replace view v_$sql_cursor as select * from v$sql_cursor;
create or replace public synonym v$sql_cursor for v_$sql_cursor;
grant select on v_$sql_cursor to select_catalog_role;

create or replace view v_$sql_bind_metadata as
  select * from v$sql_bind_metadata;
create or replace public synonym v$sql_bind_metadata for v_$sql_bind_metadata;
grant select on v_$sql_bind_metadata to select_catalog_role;

create or replace view v_$sql_bind_data as select * from v$sql_bind_data;
create or replace public synonym v$sql_bind_data for v_$sql_bind_data;
grant select on v_$sql_bind_data to select_catalog_role;

create or replace view v_$sql_shared_memory
  as select * from v$sql_shared_memory;
create or replace public synonym v$sql_shared_memory for v_$sql_shared_memory;
grant select on v_$sql_shared_memory to select_catalog_role;

create or replace view v_$global_transaction
  as select * from v$global_transaction;
create or replace public synonym v$global_transaction
   for v_$global_transaction;
grant select on v_$global_transaction to select_catalog_role;

create or replace view v_$session_object_cache as
  select * from v$session_object_cache;
create or replace public synonym v$session_object_cache
   for v_$session_object_cache;
grant select on v_$session_object_cache to select_catalog_role;

CREATE OR replace VIEW v_$kccfe AS
  SELECT * FROM x$kccfe;
GRANT SELECT ON v_$kccfe TO select_catalog_role;

CREATE OR replace VIEW v_$kccdi AS
  SELECT * FROM x$kccdi;
GRANT SELECT ON v_$kccdi TO select_catalog_role;

create or replace view v_$lock_activity as
  select * from v$lock_activity;
create or replace public synonym v$lock_activity for v_$lock_activity;
grant select on v_$lock_activity to public;

create or replace view v_$aq1 as
  select * from v$aq1;
create or replace public synonym v$aq1 for v_$aq1;
grant select on v_$aq1 to select_catalog_role;

create or replace view v_$hs_agent as
  select * from v$hs_agent;
create or replace public synonym v$hs_agent for v_$hs_agent;
grant select on v_$hs_agent to select_catalog_role;

create or replace view v_$hs_session as
  select * from v$hs_session;
create or replace public synonym v$hs_session for v_$hs_session;
grant select on v_$hs_session to select_catalog_role;

create or replace view v_$hs_parameter as
  select * from v$hs_parameter;
create or replace public synonym v$hs_parameter for v_$hs_parameter;
grant select on v_$hs_parameter to select_catalog_role;

create or replace view v_$rsrc_consumer_group_cpu_mth as
  select * from v$rsrc_consumer_group_cpu_mth;
create or replace public synonym v$rsrc_consumer_group_cpu_mth
   for v_$rsrc_consumer_group_cpu_mth;
grant select on v_$rsrc_consumer_group_cpu_mth to public;

create or replace view v_$rsrc_plan_cpu_mth as
  select * from v$rsrc_plan_cpu_mth;
create or replace public synonym v$rsrc_plan_cpu_mth for v_$rsrc_plan_cpu_mth;
grant select on v_$rsrc_plan_cpu_mth to public;

create or replace view v_$rsrc_consumer_group as
  select * from v$rsrc_consumer_group;
create or replace public synonym v$rsrc_consumer_group
   for v_$rsrc_consumer_group;
grant select on v_$rsrc_consumer_group to public;

create or replace view v_$rsrc_session_info as
  select * from v$rsrc_session_info;
create or replace public synonym v$rsrc_session_info
   for v_$rsrc_session_info;
grant select on v_$rsrc_session_info to public;

create or replace view v_$rsrc_plan as
  select * from v$rsrc_plan;
create or replace public synonym v$rsrc_plan for v_$rsrc_plan;
grant select on v_$rsrc_plan to public;

create or replace view v_$rsrc_cons_group_history as
  select * from v$rsrc_cons_group_history;
create or replace public synonym v$rsrc_cons_group_history 
  for v_$rsrc_cons_group_history;
grant select on v_$rsrc_cons_group_history to public;

create or replace view v_$rsrc_plan_history as
  select * from v$rsrc_plan_history;
create or replace public synonym v$rsrc_plan_history for v_$rsrc_plan_history;
grant select on v_$rsrc_plan_history to public;

create or replace view v_$blocking_quiesce as
  select * from v$blocking_quiesce;
create or replace public synonym v$blocking_quiesce
   for v_$blocking_quiesce;
grant select on v_$blocking_quiesce to public;

create or replace view v_$px_buffer_advice as
  select * from v$px_buffer_advice;
create or replace public synonym v$px_buffer_advice for v_$px_buffer_advice;
grant select on v_$px_buffer_advice to select_catalog_role;

create or replace view v_$px_session as
  select * from v$px_session;
create or replace public synonym v$px_session for v_$px_session;
grant select on v_$px_session to select_catalog_role;

create or replace view v_$px_sesstat as
  select * from v$px_sesstat;
create or replace public synonym v$px_sesstat for v_$px_sesstat;
grant select on v_$px_sesstat to select_catalog_role;

create or replace view v_$backup_sync_io as
  select * from v$backup_sync_io;
create or replace public synonym v$backup_sync_io for v_$backup_sync_io;
grant select on v_$backup_sync_io to select_catalog_role;

create or replace view v_$backup_async_io as
  select * from v$backup_async_io;
create or replace public synonym v$backup_async_io for v_$backup_async_io;
grant select on v_$backup_async_io to select_catalog_role;

create or replace view v_$temporary_lobs as select * from v$temporary_lobs;
create or replace public synonym v$temporary_lobs for v_$temporary_lobs;
grant select on v_$temporary_lobs to public;

create or replace view v_$px_process as
  select * from v$px_process;
create or replace public synonym v$px_process for v_$px_process;
grant select on v_$px_process to select_catalog_role;

create or replace view v_$px_process_sysstat as
  select * from v$px_process_sysstat;
create or replace public synonym v$px_process_sysstat for v_$px_process_sysstat;
grant select on v_$px_process_sysstat to select_catalog_role;

create or replace view v_$logmnr_contents as
  select * from v$logmnr_contents;
create or replace public synonym v$logmnr_contents for v_$logmnr_contents;
grant select on v_$logmnr_contents to select_catalog_role;

create or replace view v_$logmnr_parameters as
  select * from v$logmnr_parameters;
create or replace public synonym v$logmnr_parameters for v_$logmnr_parameters;
grant select on v_$logmnr_parameters to select_catalog_role;

create or replace view v_$logmnr_dictionary as
  select * from v$logmnr_dictionary;
create or replace public synonym v$logmnr_dictionary for v_$logmnr_dictionary;
grant select on v_$logmnr_dictionary to select_catalog_role;

create or replace view v_$logmnr_logs as
  select * from v$logmnr_logs;
create or replace public synonym v$logmnr_logs for v_$logmnr_logs;
grant select on v_$logmnr_logs to select_catalog_role;

create or replace view v_$logmnr_stats as select * from v$logmnr_stats;
create or replace public synonym v$logmnr_stats for v_$logmnr_stats;
grant select on v_$logmnr_stats to select_catalog_role;

create or replace view v_$logmnr_dictionary_load as
  select * from v$logmnr_dictionary_load;
create or replace public synonym v$logmnr_dictionary_load
  for v_$logmnr_dictionary_load;
grant select on v_$logmnr_dictionary_load to select_catalog_role;

create or replace view v_$rfs_thread as
  select * from v$rfs_thread;
create or replace public synonym v$rfs_thread
  for v_$rfs_thread;
grant select on v_$rfs_thread to select_catalog_role;

create or replace view v_$standby_event_histogram as
  select * from v$standby_event_histogram;
create or replace public synonym v$standby_event_histogram
  for v_$standby_event_histogram;
grant select on v_$standby_event_histogram to select_catalog_role;

create or replace view v_$global_blocked_locks as
select * from v$global_blocked_locks;
create or replace public synonym v$global_blocked_locks
   for v_$global_blocked_locks;
grant select on v_$global_blocked_locks to select_catalog_role;

create or replace view v_$aw_olap as select * from v$aw_olap;
create or replace public synonym v$aw_olap for v_$aw_olap;
grant select on v_$aw_olap to select_catalog_role;

create or replace view v_$aw_calc as select * from v$aw_calc;
create or replace public synonym v$aw_calc for v_$aw_calc;
grant select on v_$aw_calc to select_catalog_role;

create or replace view v_$aw_session_info as select * from v$aw_session_info;
create or replace public synonym v$aw_session_info for v_$aw_session_info;
grant select on v_$aw_session_info to select_catalog_role;

create or replace view gv_$aw_aggregate_op as select * from gv$aw_aggregate_op;
create or replace public synonym gv$aw_aggregate_op for gv_$aw_aggregate_op;
grant select on gv_$aw_aggregate_op to select_catalog_role;

create or replace view v_$aw_aggregate_op as select * from v$aw_aggregate_op;
create or replace public synonym v$aw_aggregate_op for v_$aw_aggregate_op;
grant select on v_$aw_aggregate_op to select_catalog_role;

create or replace view gv_$aw_allocate_op as select * from gv$aw_allocate_op;
create or replace public synonym gv$aw_allocate_op for gv_$aw_allocate_op;
grant select on gv_$aw_allocate_op to select_catalog_role;

create or replace view v_$aw_allocate_op as select * from v$aw_allocate_op;
create or replace public synonym v$aw_allocate_op for v_$aw_allocate_op;
grant select on v_$aw_allocate_op to select_catalog_role;

create or replace view v_$aw_longops as select * from v$aw_longops;
create or replace public synonym v$aw_longops for v_$aw_longops;
grant select on v_$aw_longops to public;

create or replace view v_$max_active_sess_target_mth as
  select * from v$max_active_sess_target_mth;
create or replace public synonym v$max_active_sess_target_mth
   for v_$max_active_sess_target_mth;
grant select on v_$max_active_sess_target_mth to public;

create or replace view v_$active_sess_pool_mth as
  select * from v$active_sess_pool_mth;
create or replace public synonym v$active_sess_pool_mth
   for v_$active_sess_pool_mth;
grant select on v_$active_sess_pool_mth to public;


create or replace view v_$parallel_degree_limit_mth as
  select * from v$parallel_degree_limit_mth;
create or replace public synonym v$parallel_degree_limit_mth
   for v_$parallel_degree_limit_mth;
grant select on v_$parallel_degree_limit_mth to public;

create or replace view v_$queueing_mth as
  select * from v$queueing_mth;
create or replace public synonym v$queueing_mth for v_$queueing_mth;
grant select on v_$queueing_mth to public;

create or replace view v_$reserved_words as
  select * from v$reserved_words;
create or replace public synonym v$reserved_words for v_$reserved_words;
grant select on v_$reserved_words to select_catalog_role;

create or replace view v_$archive_dest_status as select * from v$archive_dest_status;
create or replace public synonym v$archive_dest_status
   for v_$archive_dest_status;
grant select on v_$archive_dest_status to select_catalog_role;

create or replace view v_$db_cache_advice as select * from v$db_cache_advice;
create or replace public synonym v$db_cache_advice for v_$db_cache_advice;
grant select on v_$db_cache_advice to select_catalog_role;

create or replace view v_$sga_target_advice as 
  select * from v$sga_target_advice;
create or replace public synonym v$sga_target_advice for v_$sga_target_advice;
grant select on v_$sga_target_advice to select_catalog_role;

create or replace view v_$memory_target_advice as
  select * from v$memory_target_advice;
create or replace public synonym v$memory_target_advice 
  for v_$memory_target_advice;
grant select on v_$memory_target_advice to select_catalog_role;

create or replace view v_$memory_resize_ops as
  select * from v$memory_resize_ops;
create or replace public synonym v$memory_resize_ops for v_$memory_resize_ops;
grant select on v_$memory_resize_ops to select_catalog_role;

create or replace view v_$memory_current_resize_ops as
  select * from v$memory_current_resize_ops;
create or replace public synonym v$memory_current_resize_ops 
  for v_$memory_current_resize_ops;
grant select on v_$memory_current_resize_ops to select_catalog_role;

create or replace view v_$memory_dynamic_components as
  select * from v$memory_dynamic_components;
create or replace public synonym v$memory_dynamic_components 
  for v_$memory_dynamic_components;
grant select on v_$memory_dynamic_components to select_catalog_role;

create or replace view gv_$memory_target_advice as
  select * from gv$memory_target_advice;
create or replace public synonym gv$memory_target_advice 
  for gv_$memory_target_advice;
grant select on gv_$memory_target_advice to select_catalog_role;

create or replace view gv_$memory_resize_ops as
  select * from gv$memory_resize_ops;
create or replace public synonym gv$memory_resize_ops 
  for gv_$memory_resize_ops;
grant select on gv_$memory_resize_ops to select_catalog_role;

create or replace view gv_$memory_current_resize_ops as
  select * from gv$memory_current_resize_ops;
create or replace public synonym gv$memory_current_resize_ops 
  for gv_$memory_current_resize_ops;
grant select on gv_$memory_current_resize_ops to select_catalog_role;

create or replace view gv_$memory_dynamic_components as
  select * from gv$memory_dynamic_components;
create or replace public synonym gv$memory_dynamic_components 
  for gv_$memory_dynamic_components;
grant select on gv_$memory_dynamic_components to select_catalog_role;

create or replace view v_$segment_statistics as
  select * from v$segment_statistics;
create or replace public synonym v$segment_statistics
  for v_$segment_statistics;
grant select on v_$segment_statistics to select_catalog_role;


create or replace view v_$segstat_name as
  select * from v$segstat_name;
create or replace public synonym v$segstat_name
  for v_$segstat_name;
grant select on v_$segstat_name to select_catalog_role;

create or replace view v_$segstat as select * from v$segstat;
create or replace public synonym v$segstat for v_$segstat;
grant select on v_$segstat to select_catalog_role;

create or replace view v_$library_cache_memory as
  select * from v$library_cache_memory;
create or replace public synonym v$library_cache_memory
  for v_$library_cache_memory;
grant select on v_$library_cache_memory to select_catalog_role;

create or replace view v_$java_library_cache_memory as
  select * from v$java_library_cache_memory;
create or replace public synonym v$java_library_cache_memory
  for v_$java_library_cache_memory;
grant select on v_$java_library_cache_memory to select_catalog_role;

create or replace view v_$shared_pool_advice as
  select * from v$shared_pool_advice;
create or replace public synonym v$shared_pool_advice
  for v_$shared_pool_advice;
grant select on v_$shared_pool_advice to select_catalog_role;

create or replace view v_$java_pool_advice as
  select * from v$java_pool_advice;
create or replace public synonym v$java_pool_advice
  for v_$java_pool_advice;
grant select on v_$java_pool_advice to select_catalog_role;

create or replace view v_$streams_pool_advice as
  select * from v$streams_pool_advice;
create or replace public synonym v$streams_pool_advice
  for v_$streams_pool_advice;
grant select on v_$streams_pool_advice to select_catalog_role;

create or replace view v_$goldengate_capabilities as
  select * from v$goldengate_capabilities;
create or replace public synonym v$goldengate_capabilities
  for v_$goldengate_capabilities;
grant select on v_$goldengate_capabilities to select_catalog_role;

create or replace view v_$sga_current_resize_ops as
  select * from v$sga_current_resize_ops;
create or replace public synonym v$sga_current_resize_ops
  for v_$sga_current_resize_ops;
grant select on v_$sga_current_resize_ops to select_catalog_role;

create or replace view v_$sga_resize_ops as
  select * from v$sga_resize_ops;
create or replace public synonym v$sga_resize_ops
  for v_$sga_resize_ops;
grant select on v_$sga_resize_ops to select_catalog_role;

create or replace view v_$sga_dynamic_components as
  select * from v$sga_dynamic_components;
create or replace public synonym v$sga_dynamic_components
  for v_$sga_dynamic_components;
grant select on v_$sga_dynamic_components to select_catalog_role;

create or replace view v_$sga_dynamic_free_memory as
  select * from v$sga_dynamic_free_memory;
create or replace public synonym v$sga_dynamic_free_memory
  for v_$sga_dynamic_free_memory;
grant select on v_$sga_dynamic_free_memory to select_catalog_role;

create or replace view v_$resumable as select * from v$resumable;
create or replace public synonym v$resumable for v_$resumable;
grant select on v_$resumable to select_catalog_role;

create or replace view v_$timezone_names as select * from v$timezone_names;
create or replace public synonym v$timezone_names for v_$timezone_names;
grant select on v_$timezone_names to public;

create or replace view v_$timezone_file as select * from v$timezone_file;
create or replace public synonym v$timezone_file for v_$timezone_file;
grant select on v_$timezone_file to public;

create or replace view v_$enqueue_stat as select * from v$enqueue_stat;
create or replace public synonym v$enqueue_stat for v_$enqueue_stat;
grant select on v_$enqueue_stat to select_catalog_role;

create or replace view v_$enqueue_statistics as select * from v$enqueue_statistics;
create or replace public synonym v$enqueue_statistics for v_$enqueue_statistics;
grant select on v_$enqueue_statistics to select_catalog_role;

create or replace view v_$lock_type as select * from v$lock_type;
create or replace public synonym v$lock_type for v_$lock_type;
grant select on v_$lock_type to select_catalog_role;

create or replace view v_$rman_configuration as select * from v$rman_configuration;
create or replace public synonym v$rman_configuration
   for v_$rman_configuration;
grant select on v_$rman_configuration to select_catalog_role;

create or replace view v_$database_incarnation as select * from
   v$database_incarnation;
create or replace public synonym v$database_incarnation
   for v_$database_incarnation;
grant select on v_$database_incarnation to select_catalog_role;

create or replace view v_$metric as select * from v$metric;
create or replace public synonym v$metric for v_$metric;
grant select on v_$metric to select_catalog_role;

create or replace view v_$metric_history as
          select * from v$metric_history;
create or replace public synonym v$metric_history for v_$metric_history;
grant select on v_$metric_history to select_catalog_role;

create or replace view v_$sysmetric as select * from v$sysmetric;
create or replace public synonym v$sysmetric for v_$sysmetric;
grant select on v_$sysmetric to select_catalog_role;

create or replace view v_$sysmetric_history as
          select * from v$sysmetric_history;
create or replace public synonym v$sysmetric_history for v_$sysmetric_history;
grant select on v_$sysmetric_history to select_catalog_role;

create or replace view v_$metricname as select * from v$metricname;
create or replace public synonym v$metricname for v_$metricname;
grant select on v_$metricname to select_catalog_role;

create or replace view v_$metricgroup as select * from v$metricgroup;
create or replace public synonym v$metricgroup for v_$metricgroup;
grant select on v_$metricgroup to select_catalog_role;

create or replace view v_$service_wait_class as select * from v$service_wait_class;
create or replace public synonym v$service_wait_class for v_$service_wait_class;
grant select on v_$service_wait_class to select_catalog_role;

create or replace view v_$service_event as select * from v$service_event;
create or replace public synonym v$service_event for v_$service_event;
grant select on v_$service_event to select_catalog_role;

create or replace view v_$active_services as select * from v$active_services;
create or replace public synonym v$active_services for v_$active_services;
grant select on v_$active_services to select_catalog_role;

create or replace view v_$services as select * from v$services;
create or replace public synonym v$services for v_$services;
grant select on v_$services to select_catalog_role;

create or replace view v_$sysmetric_summary as
    select * from v$sysmetric_summary;
create or replace public synonym v$sysmetric_summary
    for v_$sysmetric_summary;
grant select on v_$sysmetric_summary to select_catalog_role;

create or replace view v_$sessmetric as select * from v$sessmetric;
create or replace public synonym v$sessmetric for v_$sessmetric;
grant select on v_$sessmetric to select_catalog_role;

create or replace view v_$filemetric as select * from v$filemetric;
create or replace public synonym v$filemetric for v_$filemetric;
grant select on v_$filemetric to select_catalog_role;

create or replace view v_$filemetric_history as
    select * from v$filemetric_history;
create or replace public synonym v$filemetric_history
    for v_$filemetric_history;
grant select on v_$filemetric_history to select_catalog_role;

create or replace view v_$eventmetric as select * from v$eventmetric;
create or replace public synonym v$eventmetric for v_$eventmetric;
grant select on v_$eventmetric to select_catalog_role;

create or replace view v_$waitclassmetric as
    select * from v$waitclassmetric;
create or replace public synonym v$waitclassmetric for v_$waitclassmetric;
grant select on v_$waitclassmetric to select_catalog_role;

create or replace view v_$waitclassmetric_history as
    select * from v$waitclassmetric_history;
create or replace public synonym v$waitclassmetric_history
    for v_$waitclassmetric_history;
grant select on v_$waitclassmetric_history to select_catalog_role;

create or replace view v_$servicemetric as select * from v$servicemetric;
create or replace public synonym v$servicemetric for v_$servicemetric;
grant select on v_$servicemetric to select_catalog_role;

create or replace view v_$servicemetric_history
    as select * from v$servicemetric_history;
create or replace public synonym v$servicemetric_history
    for v_$servicemetric_history;
grant select on v_$servicemetric_history to select_catalog_role;

create or replace view v_$iofuncmetric as select * from v$iofuncmetric;
create or replace public synonym v$iofuncmetric for v_$iofuncmetric;
grant select on v_$iofuncmetric to select_catalog_role;

create or replace view v_$iofuncmetric_history
    as select * from v$iofuncmetric_history;
create or replace public synonym v$iofuncmetric_history
    for v_$iofuncmetric_history;
grant select on v_$iofuncmetric_history to select_catalog_role;

create or replace view v_$rsrcmgrmetric as select * from v$rsrcmgrmetric;
create or replace public synonym v$rsrcmgrmetric for v_$rsrcmgrmetric;
grant select on v_$rsrcmgrmetric to select_catalog_role;

create or replace view v_$rsrcmgrmetric_history
    as select * from v$rsrcmgrmetric_history;
create or replace public synonym v$rsrcmgrmetric_history
    for v_$rsrcmgrmetric_history;
grant select on v_$rsrcmgrmetric_history to select_catalog_role;

create or replace view v_$wlm_pcmetric as select * from v$wlm_pcmetric;
create or replace public synonym v$wlm_pcmetric for v_$wlm_pcmetric;
grant select on v_$wlm_pcmetric to select_catalog_role;

create or replace view v_$wlm_pcmetric_history
    as select * from v$wlm_pcmetric_history;
create or replace public synonym v$wlm_pcmetric_history
    for v_$wlm_pcmetric_history;
grant select on v_$wlm_pcmetric_history to select_catalog_role;

create or replace view v_$wlm_pc_stats as select * from v$wlm_pc_stats;
create or replace public synonym v$wlm_pc_stats for v_$wlm_pc_stats;
grant select on v_$wlm_pc_stats to select_catalog_role;

create or replace view v_$advisor_progress
    as select * from v$advisor_progress;
create or replace public synonym v$advisor_progress
    for v_$advisor_progress;
grant select on v_$advisor_progress to public;

--
-- Add SQL Performance Analyzer (SPA) fixed views
--

create or replace view gv_$sqlpa_metric
    as select * from gv$sqlpa_metric;
create or replace public synonym gv$sqlpa_metric
    for gv_$sqlpa_metric;
grant select on gv_$sqlpa_metric to select_catalog_role;

create or replace view v_$sqlpa_metric
    as select * from v$sqlpa_metric;
create or replace public synonym v$sqlpa_metric
    for v_$sqlpa_metric;
grant select on v_$sqlpa_metric to public;

create or replace view v_$xml_audit_trail
    as select * from v$xml_audit_trail;
create or replace public synonym v$xml_audit_trail
    for v_$xml_audit_trail;
grant select on v_$xml_audit_trail to select_catalog_role;

create or replace view v_$sql_join_filter
    as select * from v$sql_join_filter;
create or replace public synonym v$sql_join_filter
    for v_$sql_join_filter;
grant select on v_$sql_join_filter to select_catalog_role;

create or replace view v_$process_memory as select * from v$process_memory;
create or replace public synonym v$process_memory for v_$process_memory;
grant select on v_$process_memory to select_catalog_role;

create or replace view v_$process_memory_detail
    as select * from v$process_memory_detail;
create or replace public synonym v$process_memory_detail
    for v_$process_memory_detail;
grant select on v_$process_memory_detail to select_catalog_role;

create or replace view v_$process_memory_detail_prog
    as select * from v$process_memory_detail_prog;
create or replace public synonym v$process_memory_detail_prog
    for v_$process_memory_detail_prog;
grant select on v_$process_memory_detail_prog to select_catalog_role;

create or replace view v_$sqlstats as select * from v$sqlstats;
create or replace public synonym v$sqlstats for v_$sqlstats;
grant select on v_$sqlstats to select_catalog_role;

create or replace view v_$sqlstats_plan_hash as select * from v$sqlstats_plan_hash;
create or replace public synonym v$sqlstats_plan_hash for v_$sqlstats_plan_hash;
grant select on v_$sqlstats_plan_hash to select_catalog_role;

create or replace view v_$mutex_sleep as select * from v$mutex_sleep;
create or replace public synonym v$mutex_sleep for v_$mutex_sleep;
grant select on v_$mutex_sleep to select_catalog_role;

create or replace view v_$mutex_sleep_history as
      select * from v$mutex_sleep_history;
create or replace public synonym v$mutex_sleep_history
   for v_$mutex_sleep_history;
grant select on v_$mutex_sleep_history to select_catalog_role;

create or replace view v_$object_privilege
       as select * from v$object_privilege;
create or replace public synonym v$object_privilege
       for v_$object_privilege;
grant select on v_$object_privilege to select_catalog_role;


create or replace view v_$calltag as select * from v$calltag;
create or replace public synonym v$calltag for v_$calltag;
grant select on v_$calltag to select_catalog_role;

create or replace view v_$process_group
       as select * from v$process_group;
create or replace public synonym v$process_group
       for v_$process_group;
grant select on v_$process_group to select_catalog_role;

create or replace view v_$detached_session
       as select * from v$detached_session;
create or replace public synonym v$detached_session
       for v_$detached_session;
grant select on v_$detached_session to select_catalog_role;

remark Create synonyms for the global fixed views
remark
remark

create or replace view gv_$mutex_sleep as select * from gv$mutex_sleep;
create or replace public synonym gv$mutex_sleep for gv_$mutex_sleep;
grant select on gv_$mutex_sleep to select_catalog_role;

create or replace view gv_$mutex_sleep_history as
      select * from gv$mutex_sleep_history;
create or replace public synonym gv$mutex_sleep_history
   for gv_$mutex_sleep_history;
grant select on gv_$mutex_sleep_history to select_catalog_role;

create or replace view gv_$sqlstats as select * from gv$sqlstats;
create or replace public synonym gv$sqlstats for gv_$sqlstats;
grant select on gv_$sqlstats to select_catalog_role;

create or replace view gv_$sqlstats_plan_hash as select * from gv$sqlstats_plan_hash;
create or replace public synonym gv$sqlstats_plan_hash for gv_$sqlstats_plan_hash;
grant select on gv_$sqlstats_plan_hash to select_catalog_role;

create or replace view gv_$map_library as select * from gv$map_library;
create or replace public synonym gv$map_library for gv_$map_library;
grant select on gv_$map_library to select_catalog_role;

create or replace view gv_$map_file as select * from gv$map_file;
create or replace public synonym gv$map_file for gv_$map_file;
grant select on gv_$map_file to select_catalog_role;

create or replace view gv_$map_file_extent as select * from gv$map_file_extent;
create or replace public synonym gv$map_file_extent for gv_$map_file_extent;
grant select on gv_$map_file_extent to select_catalog_role;

create or replace view gv_$map_element as select * from gv$map_element;
create or replace public synonym gv$map_element for gv_$map_element;
grant select on gv_$map_element to select_catalog_role;

create or replace view gv_$map_ext_element as select * from gv$map_ext_element;
create or replace public synonym gv$map_ext_element for gv_$map_ext_element;
grant select on gv_$map_ext_element to select_catalog_role;

create or replace view gv_$map_comp_list as select * from gv$map_comp_list;
create or replace public synonym gv$map_comp_list for gv_$map_comp_list;
grant select on gv_$map_comp_list to select_catalog_role;

create or replace view gv_$map_subelement as select * from gv$map_subelement;
create or replace public synonym gv$map_subelement for gv_$map_subelement;
grant select on gv_$map_subelement to select_catalog_role;

create or replace view gv_$map_file_io_stack as select * from gv$map_file_io_stack;
create or replace public synonym gv$map_file_io_stack for gv_$map_file_io_stack;
grant select on gv_$map_file_io_stack to select_catalog_role;

create or replace view gv_$bsp as select * from gv$bsp;
create or replace public synonym gv$bsp for gv_$bsp;
grant select on gv_$bsp to select_catalog_role;

create or replace view gv_$obsolete_parameter as
 select * from gv$obsolete_parameter;
create or replace public synonym gv$obsolete_parameter
   for gv_$obsolete_parameter;
grant select on gv_$obsolete_parameter to select_catalog_role;

create or replace view gv_$fast_start_servers
as select * from gv$fast_start_servers;
create or replace public synonym gv$fast_start_servers
   for gv_$fast_start_servers;
grant select on gv_$fast_start_servers to select_catalog_role;

create or replace view gv_$fast_start_transactions
as select * from gv$fast_start_transactions;
create or replace public synonym gv$fast_start_transactions
   for gv_$fast_start_transactions;
grant select on gv_$fast_start_transactions to select_catalog_role;

create or replace view gv_$enqueue_lock as select * from gv$enqueue_lock;
create or replace public synonym gv$enqueue_lock for gv_$enqueue_lock;
grant select on gv_$enqueue_lock to select_catalog_role;

create or replace view gv_$transaction_enqueue as select * from gv$transaction_enqueue;
create or replace public synonym gv$transaction_enqueue
   for gv_$transaction_enqueue;
grant select on gv_$transaction_enqueue to select_catalog_role;

create or replace view gv_$resource_limit as select * from gv$resource_limit;
create or replace public synonym gv$resource_limit for gv_$resource_limit;
grant select on gv_$resource_limit to select_catalog_role;

create or replace view gv_$sql_redirection as select * from gv$sql_redirection;
create or replace public synonym gv$sql_redirection for gv_$sql_redirection;
grant select on gv_$sql_redirection to select_catalog_role;

create or replace view gv_$sql_plan as select * from gv$sql_plan;
create or replace public synonym gv$sql_plan for gv_$sql_plan;
grant select on gv_$sql_plan to select_catalog_role;

create or replace view gv_$sql_plan_statistics as
  select * from gv$sql_plan_statistics;
create or replace public synonym gv$sql_plan_statistics
  for gv_$sql_plan_statistics;
grant select on gv_$sql_plan_statistics to select_catalog_role;

create or replace view gv_$sql_plan_statistics_all as
  select * from gv$sql_plan_statistics_all;
create or replace public synonym gv$sql_plan_statistics_all
  for gv_$sql_plan_statistics_all;
grant select on gv_$sql_plan_statistics_all to select_catalog_role;

create or replace view gv_$advisor_current_sqlplan as
  select * from gv$advisor_current_sqlplan;
create or replace public synonym gv$advisor_current_sqlplan
  for gv_$advisor_current_sqlplan;
grant select on gv_$advisor_current_sqlplan to public;

create or replace view gv_$sql_workarea as select * from gv$sql_workarea;
create or replace public synonym gv$sql_workarea for gv_$sql_workarea;
grant select on gv_$sql_workarea to select_catalog_role;

create or replace view gv_$sql_workarea_active
  as select * from gv$sql_workarea_active;
create or replace public synonym gv$sql_workarea_active
   for gv_$sql_workarea_active;
grant select on gv_$sql_workarea_active to select_catalog_role;

create or replace view gv_$sql_workarea_histogram
  as select * from gv$sql_workarea_histogram;
create or replace public synonym gv$sql_workarea_histogram
   for gv_$sql_workarea_histogram;
grant select on gv_$sql_workarea_histogram to select_catalog_role;

create or replace view gv_$pga_target_advice
  as select * from gv$pga_target_advice;
create or replace public synonym gv$pga_target_advice
  for gv_$pga_target_advice;
grant select on gv_$pga_target_advice to select_catalog_role;

create or replace view gv_$pgatarget_advice_histogram
  as select * from gv$pga_target_advice_histogram;
create or replace public synonym gv$pga_target_advice_histogram
  for gv_$pgatarget_advice_histogram;
grant select on gv_$pgatarget_advice_histogram to select_catalog_role;

create or replace view gv_$pgastat as select * from gv$pgastat;
create or replace public synonym gv$pgastat for gv_$pgastat;
grant select on gv_$pgastat to select_catalog_role;

create or replace view gv_$sys_optimizer_env
  as select * from gv$sys_optimizer_env;
create or replace public synonym gv$sys_optimizer_env for gv_$sys_optimizer_env;
grant select on gv_$sys_optimizer_env to select_catalog_role;

create or replace view gv_$ses_optimizer_env
  as select * from gv$ses_optimizer_env;
create or replace public synonym gv$ses_optimizer_env for gv_$ses_optimizer_env;
grant select on gv_$ses_optimizer_env to select_catalog_role;

create or replace view gv_$sql_optimizer_env
  as select * from gv$sql_optimizer_env;
create or replace public synonym gv$sql_optimizer_env for gv_$sql_optimizer_env;
grant select on gv_$sql_optimizer_env to select_catalog_role;

create or replace view gv_$dlm_misc as select * from gv$dlm_misc;
create or replace public synonym gv$dlm_misc for gv_$dlm_misc;
grant select on gv_$dlm_misc to select_catalog_role;

create or replace view gv_$dlm_latch as select * from gv$dlm_latch;
create or replace public synonym gv$dlm_latch for gv_$dlm_latch;
grant select on gv_$dlm_latch to select_catalog_role;

create or replace view gv_$dlm_convert_local as select * from gv$dlm_convert_local;
create or replace public synonym gv$dlm_convert_local
   for gv_$dlm_convert_local;
grant select on gv_$dlm_convert_local to select_catalog_role;

create or replace view gv_$dlm_convert_remote as select * from gv$dlm_convert_remote;
create or replace public synonym gv$dlm_convert_remote
   for gv_$dlm_convert_remote;
grant select on gv_$dlm_convert_remote to select_catalog_role;

create or replace view gv_$dlm_all_locks as select * from gv$dlm_all_locks;
create or replace public synonym gv$dlm_all_locks for gv_$dlm_all_locks;
grant select on gv_$dlm_all_locks to select_catalog_role;

create or replace view gv_$dlm_locks as select * from gv$dlm_locks;
create or replace public synonym gv$dlm_locks for gv_$dlm_locks;
grant select on gv_$dlm_locks to select_catalog_role;

create or replace view gv_$dlm_ress as select * from gv$dlm_ress;
create or replace public synonym gv$dlm_ress for gv_$dlm_ress;
grant select on gv_$dlm_ress to select_catalog_role;

create or replace view gv_$hvmaster_info as select * from gv$hvmaster_info;
create or replace public synonym gv$hvmaster_info for gv_$hvmaster_info;
grant select on gv_$hvmaster_info to select_catalog_role;

create or replace view gv_$gcshvmaster_info as select * from gv$gcshvmaster_info
;
create or replace public synonym gv$gcshvmaster_info for gv_$gcshvmaster_info;
grant select on gv_$gcshvmaster_info to select_catalog_role;

create or replace view gv_$gcspfmaster_info as
select * from gv$gcspfmaster_info;
create or replace public synonym gv$gcspfmaster_info for gv_$gcspfmaster_info;
grant select on gv_$gcspfmaster_info to select_catalog_role;

create or replace view gv_$ges_enqueue as
select * from gv$ges_enqueue;
create or replace public synonym gv$ges_enqueue for gv_$ges_enqueue;
grant select on gv_$ges_enqueue to select_catalog_role;

create or replace view gv_$ges_blocking_enqueue as
select * from gv$ges_blocking_enqueue;
create or replace public synonym gv$ges_blocking_enqueue
   for gv_$ges_blocking_enqueue;
grant select on gv_$ges_blocking_enqueue to select_catalog_role;

create or replace view gv_$gc_element as
select * from gv$gc_element;
create or replace public synonym gv$gc_element for gv_$gc_element;
grant select on gv_$gc_element to select_catalog_role;

create or replace view gv_$cr_block_server as
select * from gv$cr_block_server;
create or replace public synonym gv$cr_block_server for gv_$cr_block_server;
grant select on gv_$cr_block_server to select_catalog_role;

create or replace view gv_$current_block_server as
select * from gv$current_block_server;
create or replace public synonym gv$current_block_server for gv_$current_block_server;
grant select on gv_$current_block_server to select_catalog_role;

create or replace view gv_$policy_history as
select * from gv$policy_history;
create or replace public synonym gv$policy_history for gv_$policy_history;
grant select on gv_$policy_history to select_catalog_role;

create or replace view gv_$gc_elements_w_collisions as
select * from gv$gc_elements_with_collisions;
create or replace public synonym gv$gc_elements_with_collisions for
gv_$gc_elements_w_collisions;
grant select on gv_$gc_elements_w_collisions to select_catalog_role;

create or replace view gv_$file_cache_transfer as
select * from gv$file_cache_transfer;
create or replace public synonym gv$file_cache_transfer
   for gv_$file_cache_transfer;
grant select on gv_$file_cache_transfer to select_catalog_role;

create or replace view gv_$temp_cache_transfer as
select * from gv$temp_cache_transfer;
create or replace public synonym gv$temp_cache_transfer for gv_$temp_cache_transfer;
grant select on gv_$temp_cache_transfer to select_catalog_role;

create or replace view gv_$class_cache_transfer as
select * from gv$class_cache_transfer;
create or replace public synonym gv$class_cache_transfer for gv_$class_cache_transfer;
grant select on gv_$class_cache_transfer to select_catalog_role;

create or replace view gv_$bh as select * from gv$bh;
create or replace public synonym gv$bh for gv_$bh;
grant select on gv_$bh to public;

create or replace view gv_$sqlfn_metadata as
select * from gv$sqlfn_metadata;
create or replace public synonym gv$sqlfn_metadata
   for gv_$sqlfn_metadata;
grant select on gv_$sqlfn_metadata to public;

create or replace view gv_$sqlfn_arg_metadata as
select * from gv$sqlfn_arg_metadata;
create or replace public synonym gv$sqlfn_arg_metadata
   for gv_$sqlfn_arg_metadata;
grant select on gv_$sqlfn_arg_metadata to public;

create or replace view gv_$lock_element as select * from gv$lock_element;
create or replace public synonym gv$lock_element for gv_$lock_element;
grant select on gv_$lock_element to select_catalog_role;

create or replace view gv_$locks_with_collisions as select * from gv$locks_with_collisions;
create or replace public synonym gv$locks_with_collisions
   for gv_$locks_with_collisions;
grant select on gv_$locks_with_collisions to select_catalog_role;

create or replace view gv_$file_ping as select * from gv$file_ping;
create or replace public synonym gv$file_ping for gv_$file_ping;
grant select on gv_$file_ping to select_catalog_role;

create or replace view gv_$temp_ping as select * from gv$temp_ping;
create or replace public synonym gv$temp_ping for gv_$temp_ping;
grant select on gv_$temp_ping to select_catalog_role;

create or replace view gv_$class_ping as select * from gv$class_ping;
create or replace public synonym gv$class_ping for gv_$class_ping;
grant select on gv_$class_ping to select_catalog_role;

create or replace view gv_$instance_cache_transfer as
select * from gv$instance_cache_transfer;
create or replace public synonym gv$instance_cache_transfer for gv_$instance_cache_transfer;
grant select on gv_$instance_cache_transfer to select_catalog_role;

create or replace view gv_$buffer_pool as select * from gv$buffer_pool;
create or replace public synonym gv$buffer_pool for gv_$buffer_pool;
grant select on gv_$buffer_pool to select_catalog_role;

create or replace view gv_$buffer_pool_statistics as select * from gv$buffer_pool_statistics;
create or replace public synonym gv$buffer_pool_statistics
   for gv_$buffer_pool_statistics;
grant select on gv_$buffer_pool_statistics to select_catalog_role;

create or replace view gv_$instance_recovery as select * from gv$instance_recovery;
create or replace public synonym gv$instance_recovery
   for gv_$instance_recovery;
grant select on gv_$instance_recovery to select_catalog_role;

create or replace view gv_$controlfile as select * from gv$controlfile;
create or replace public synonym gv$controlfile for gv_$controlfile;
grant select on gv_$controlfile to select_catalog_role;

create or replace view gv_$log as select * from gv$log;
create or replace public synonym gv$log for gv_$log;
grant select on gv_$log to SELECT_CATALOG_ROLE;

create or replace view gv_$standby_log as select * from gv$standby_log;
create or replace public synonym gv$standby_log for gv_$standby_log;
grant select on gv_$standby_log to SELECT_CATALOG_ROLE;

create or replace view gv_$dataguard_status as select * from gv$dataguard_status;
create or replace public synonym gv$dataguard_status for gv_$dataguard_status;
grant select on gv_$dataguard_status to SELECT_CATALOG_ROLE;

create or replace view gv_$thread as select * from gv$thread;
create or replace public synonym gv$thread for gv_$thread;
grant select on gv_$thread to select_catalog_role;

create or replace view gv_$process as select * from gv$process;
create or replace public synonym gv$process for gv_$process;
grant select on gv_$process to select_catalog_role;

create or replace view gv_$bgprocess as select * from gv$bgprocess;
create or replace public synonym gv$bgprocess for gv_$bgprocess;
grant select on gv_$bgprocess to select_catalog_role;

create or replace view gv_$session as select * from gv$session;
create or replace public synonym gv$session for gv_$session;
grant select on gv_$session to select_catalog_role;

create or replace view gv_$license as select * from gv$license;
create or replace public synonym gv$license for gv_$license;
grant select on gv_$license to select_catalog_role;

create or replace view gv_$transaction as select * from gv$transaction;
create or replace public synonym gv$transaction for gv_$transaction;
grant select on gv_$transaction to select_catalog_role;

create or replace view gv_$locked_object as select * from gv$locked_object;
create or replace public synonym gv$locked_object for gv_$locked_object;
grant select on gv_$locked_object to select_catalog_role;

create or replace view gv_$latch as select * from gv$latch;
create or replace public synonym gv$latch for gv_$latch;
grant select on gv_$latch to select_catalog_role;

create or replace view gv_$latch_children as select * from gv$latch_children;
create or replace public synonym gv$latch_children for gv_$latch_children;
grant select on gv_$latch_children to select_catalog_role;

create or replace view gv_$latch_parent as select * from gv$latch_parent;
create or replace public synonym gv$latch_parent for gv_$latch_parent;
grant select on gv_$latch_parent to select_catalog_role;

create or replace view gv_$latchname as select * from gv$latchname;
create or replace public synonym gv$latchname for gv_$latchname;
grant select on gv_$latchname to select_catalog_role;

create or replace view gv_$latchholder as select * from gv$latchholder;
create or replace public synonym gv$latchholder for gv_$latchholder;
grant select on gv_$latchholder to select_catalog_role;

create or replace view gv_$latch_misses as select * from gv$latch_misses;
create or replace public synonym gv$latch_misses for gv_$latch_misses;
grant select on gv_$latch_misses to select_catalog_role;

create or replace view gv_$session_longops as select * from gv$session_longops;
create or replace public synonym gv$session_longops for gv_$session_longops;
grant select on gv_$session_longops to public;

create or replace view gv_$resource as select * from gv$resource;
create or replace public synonym gv$resource for gv_$resource;
grant select on gv_$resource to select_catalog_role;

create or replace view gv_$_lock as select * from gv$_lock;
create or replace public synonym gv$_lock for gv_$_lock;
grant select on gv_$_lock to select_catalog_role;

create or replace view gv_$lock as select * from gv$lock;
create or replace public synonym gv$lock for gv_$lock;
grant select on gv_$lock to select_catalog_role;

create or replace view gv_$sesstat as select * from gv$sesstat;
create or replace public synonym gv$sesstat for gv_$sesstat;
grant select on gv_$sesstat to select_catalog_role;

create or replace view gv_$mystat as select * from gv$mystat;
create or replace public synonym gv$mystat for gv_$mystat;
grant select on gv_$mystat to select_catalog_role;

create or replace view gv_$subcache as select * from gv$subcache;
create or replace public synonym gv$subcache for gv_$subcache;
grant select on gv_$subcache to select_catalog_role;

create or replace view gv_$sysstat as select * from gv$sysstat;
create or replace public synonym gv$sysstat for gv_$sysstat;
grant select on gv_$sysstat to select_catalog_role;

create or replace view gv_$statname as select * from gv$statname;
create or replace public synonym gv$statname for gv_$statname;
grant select on gv_$statname to select_catalog_role;

create or replace view gv_$osstat as select * from gv$osstat;
create or replace public synonym gv$osstat for gv_$osstat;
grant select on gv_$osstat to select_catalog_role;

create or replace view gv_$access as select * from gv$access;
create or replace public synonym gv$access for gv_$access;
grant select on gv_$access to select_catalog_role;

create or replace view gv_$object_dependency as
  select * from gv$object_dependency;
create or replace public synonym gv$object_dependency
   for gv_$object_dependency;
grant select on gv_$object_dependency to select_catalog_role;

create or replace view gv_$dbfile as select * from gv$dbfile;
create or replace public synonym gv$dbfile for gv_$dbfile;
grant select on gv_$dbfile to select_catalog_role;

create or replace view gv_$datafile as select * from gv$datafile;
create or replace public synonym gv$datafile for gv_$datafile;
grant select on gv_$datafile to SELECT_CATALOG_ROLE;

create or replace view gv_$tempfile as select * from gv$tempfile;
create or replace public synonym gv$tempfile for gv_$tempfile;
grant select on gv_$tempfile to SELECT_CATALOG_ROLE;

create or replace view gv_$tablespace as select * from gv$tablespace;
create or replace public synonym gv$tablespace for gv_$tablespace;
grant select on gv_$tablespace to select_catalog_role;

create or replace view gv_$filestat as select * from gv$filestat;
create or replace public synonym gv$filestat for gv_$filestat;
grant select on gv_$filestat to select_catalog_role;

create or replace view gv_$tempstat as select * from gv$tempstat;
create or replace public synonym gv$tempstat for gv_$tempstat;
grant select on gv_$tempstat to select_catalog_role;

create or replace view gv_$logfile as select * from gv$logfile;
create or replace public synonym gv$logfile for gv_$logfile;
grant select on gv_$logfile to select_catalog_role;

create or replace view gv_$flashback_database_logfile as
  select * from gv$flashback_database_logfile;
create or replace public synonym gv$flashback_database_logfile
  for gv_$flashback_database_logfile;
grant select on gv_$flashback_database_logfile to select_catalog_role;

create or replace view gv_$flashback_database_log as
  select * from gv$flashback_database_log;
create or replace public synonym gv$flashback_database_log
  for gv_$flashback_database_log;
grant select on gv_$flashback_database_log to select_catalog_role;

create or replace view gv_$flashback_database_stat as
  select * from gv$flashback_database_stat;
create or replace public synonym gv$flashback_database_stat
  for gv_$flashback_database_stat;
grant select on gv_$flashback_database_stat to select_catalog_role;

create or replace view gv_$restore_point as
  select * from gv$restore_point;
create or replace public synonym gv$restore_point
  for gv_$restore_point;
grant select on gv_$restore_point to public;

remark This is bad for gv$ views.  Need to fix or just forget -msc-
remark create or replace view gv_$rollname as select
remark     x$kturd.kturdusn usn,undo$.name
remark   from x$kturd, undo$
remark   where x$kturd.kturdusn=undo$.us# and x$kturd.kturdsiz!=0;
remark create or replace public synonym gv$rollname for gv_$rollname;
remark grant select on gv_$rollname to select_catalog_role;

create or replace view gv_$rollstat as select * from gv$rollstat;
create or replace public synonym gv$rollstat for gv_$rollstat;
grant select on gv_$rollstat to select_catalog_role;

create or replace view gv_$undostat as select * from gv$undostat;
create or replace public synonym gv$undostat for gv_$undostat;
grant select on gv_$undostat to select_catalog_role;

create or replace view gv_$sga as select * from gv$sga;
create or replace public synonym gv$sga for gv_$sga;
grant select on gv_$sga to select_catalog_role;

create or replace view gv_$cluster_interconnects 
       as select * from gv$cluster_interconnects;
create or replace public synonym gv$cluster_interconnects 
        for gv_$cluster_interconnects;
grant select on gv_$cluster_interconnects to select_catalog_role;

create or replace view gv_$configured_interconnects 
       as select * from gv$configured_interconnects;
create or replace public synonym gv$configured_interconnects 
       for gv_$configured_interconnects;
grant select on gv_$configured_interconnects to select_catalog_role;

create or replace view gv_$parameter as select * from gv$parameter;
create or replace public synonym gv$parameter for gv_$parameter;
grant select on gv_$parameter to select_catalog_role;

create or replace view gv_$parameter2 as select * from gv$parameter2;
create or replace public synonym gv$parameter2 for gv_$parameter2;
grant select on gv_$parameter2 to select_catalog_role;

create or replace view gv_$system_parameter as select * from gv$system_parameter;
create or replace public synonym gv$system_parameter for gv_$system_parameter;
grant select on gv_$system_parameter to select_catalog_role;

create or replace view gv_$system_parameter2 as select * from gv$system_parameter2;
create or replace public synonym gv$system_parameter2
   for gv_$system_parameter2;
grant select on gv_$system_parameter2 to select_catalog_role;

create or replace view gv_$spparameter as select * from gv$spparameter;
create or replace public synonym gv$spparameter for gv_$spparameter;
grant select on gv_$spparameter to select_catalog_role;

create or replace view gv_$parameter_valid_values 
       as select * from gv$parameter_valid_values;
create or replace public synonym gv$parameter_valid_values 
       for gv_$parameter_valid_values;
grant select on gv_$parameter_valid_values to select_catalog_role;

create or replace view gv_$rowcache as select * from gv$rowcache;
create or replace public synonym gv$rowcache for gv_$rowcache;
grant select on gv_$rowcache to select_catalog_role;

create or replace view gv_$rowcache_parent as select * from gv$rowcache_parent;
create or replace public synonym gv$rowcache_parent for gv_$rowcache_parent;
grant select on gv_$rowcache_parent to select_catalog_role;

create or replace view gv_$rowcache_subordinate as
  select * from gv$rowcache_subordinate;
create or replace public synonym gv$rowcache_subordinate
   for gv_$rowcache_subordinate;
grant select on gv_$rowcache_subordinate to select_catalog_role;

create or replace view gv_$enabledprivs as select * from gv$enabledprivs;
create or replace public synonym gv$enabledprivs for gv_$enabledprivs;
grant select on gv_$enabledprivs to select_catalog_role;

create or replace view gv_$nls_parameters as select * from gv$nls_parameters;
create or replace public synonym gv$nls_parameters for gv_$nls_parameters;
grant select on gv_$nls_parameters to public;

create or replace view gv_$nls_valid_values as
select * from gv$nls_valid_values;
create or replace public synonym gv$nls_valid_values for gv_$nls_valid_values;
grant select on gv_$nls_valid_values to public;

create or replace view gv_$librarycache as select * from gv$librarycache;
create or replace public synonym gv$librarycache for gv_$librarycache;
grant select on gv_$librarycache to select_catalog_role;

create or replace view gv_$libcache_locks as select * from gv$libcache_locks;
create or replace public synonym gv$libcache_locks for gv_$libcache_locks;
grant select on gv_$libcache_locks to select_catalog_role;

create or replace view gv_$type_size as select * from gv$type_size;
create or replace public synonym gv$type_size for gv_$type_size;
grant select on gv_$type_size to select_catalog_role;

create or replace view gv_$archive as select * from gv$archive;
create or replace public synonym gv$archive for gv_$archive;
grant select on gv_$archive to select_catalog_role;

create or replace view gv_$circuit as select * from gv$circuit;
create or replace public synonym gv$circuit for gv_$circuit;
grant select on gv_$circuit to select_catalog_role;

create or replace view gv_$database as select * from gv$database;
create or replace public synonym gv$database for gv_$database;
grant select on gv_$database to select_catalog_role;

create or replace view gv_$instance as select * from gv$instance;
create or replace public synonym gv$instance for gv_$instance;
grant select on gv_$instance to select_catalog_role;

create or replace view gv_$dispatcher as select * from gv$dispatcher;
create or replace public synonym gv$dispatcher for gv_$dispatcher;
grant select on gv_$dispatcher to select_catalog_role;

create or replace view gv_$dispatcher_config
  as select * from gv$dispatcher_config;
create or replace public synonym gv$dispatcher_config
  for gv_$dispatcher_config;
grant select on gv_$dispatcher_config to select_catalog_role;

create or replace view gv_$dispatcher_rate as select * from gv$dispatcher_rate;
create or replace public synonym gv$dispatcher_rate for gv_$dispatcher_rate;
grant select on gv_$dispatcher_rate to select_catalog_role;

create or replace view gv_$loghist as select * from gv$loghist;
create or replace public synonym gv$loghist for gv_$loghist;
grant select on gv_$loghist to select_catalog_role;

REM create or replace view gv_$plsarea as select * from gv$plsarea;
REM create or replace public synonym gv$plsarea for gv_$plsarea;

create or replace view gv_$sqlarea as select * from gv$sqlarea;
create or replace public synonym gv$sqlarea for gv_$sqlarea;
grant select on gv_$sqlarea to select_catalog_role;

create or replace view gv_$sqlarea_plan_hash 
        as select * from gv$sqlarea_plan_hash;
create or replace public synonym gv$sqlarea_plan_hash for gv_$sqlarea_plan_hash;
grant select on gv_$sqlarea_plan_hash to select_catalog_role;

create or replace view gv_$sqltext as select * from gv$sqltext;
create or replace public synonym gv$sqltext for gv_$sqltext;
grant select on gv_$sqltext to select_catalog_role;

create or replace view gv_$sqltext_with_newlines as
      select * from gv$sqltext_with_newlines;
create or replace public synonym gv$sqltext_with_newlines
   for gv_$sqltext_with_newlines;
grant select on gv_$sqltext_with_newlines to select_catalog_role;

create or replace view gv_$sql as select * from gv$sql;
create or replace public synonym gv$sql for gv_$sql;
grant select on gv_$sql to select_catalog_role;

create or replace view gv_$sql_shared_cursor as select * from gv$sql_shared_cursor;
create or replace public synonym gv$sql_shared_cursor for gv_$sql_shared_cursor;
grant select on gv_$sql_shared_cursor to select_catalog_role;

create or replace view gv_$db_pipes as select * from gv$db_pipes;
create or replace public synonym gv$db_pipes for gv_$db_pipes;
grant select on gv_$db_pipes to select_catalog_role;

create or replace view gv_$db_object_cache as select * from gv$db_object_cache;
create or replace public synonym gv$db_object_cache for gv_$db_object_cache;
grant select on gv_$db_object_cache to select_catalog_role;

create or replace view gv_$open_cursor as select * from gv$open_cursor;
create or replace public synonym gv$open_cursor for gv_$open_cursor;
grant select on gv_$open_cursor to select_catalog_role;

create or replace view gv_$option as select * from gv$option;
create or replace public synonym gv$option for gv_$option;
grant select on gv_$option to public;

create or replace view gv_$version as select * from gv$version;
create or replace public synonym gv$version for gv_$version;
grant select on gv_$version to public;

create or replace view gv_$pq_sesstat as select * from gv$pq_sesstat;
create or replace public synonym gv$pq_sesstat for gv_$pq_sesstat;
grant select on gv_$pq_sesstat to public;

create or replace view gv_$pq_sysstat as select * from gv$pq_sysstat;
create or replace public synonym gv$pq_sysstat for gv_$pq_sysstat;
grant select on gv_$pq_sysstat to select_catalog_role;

create or replace view gv_$pq_slave as select * from gv$pq_slave;
create or replace public synonym gv$pq_slave for gv_$pq_slave;
grant select on gv_$pq_slave to select_catalog_role;

create or replace view gv_$queue as select * from gv$queue;
create or replace public synonym gv$queue for gv_$queue;
grant select on gv_$queue to select_catalog_role;

create or replace view gv_$shared_server_monitor as select * from gv$shared_server_monitor;
create or replace public synonym gv$shared_server_monitor
   for gv_$shared_server_monitor;
grant select on gv_$shared_server_monitor to select_catalog_role;

create or replace view gv_$dblink as select * from gv$dblink;
create or replace public synonym gv$dblink for gv_$dblink;
grant select on gv_$dblink to select_catalog_role;

create or replace view gv_$pwfile_users as select * from gv$pwfile_users;
create or replace public synonym gv$pwfile_users for gv_$pwfile_users;
grant select on gv_$pwfile_users to select_catalog_role;

create or replace view gv_$reqdist as select * from gv$reqdist;
create or replace public synonym gv$reqdist for gv_$reqdist;
grant select on gv_$reqdist to select_catalog_role;

create or replace view gv_$sgastat as select * from gv$sgastat;
create or replace public synonym gv$sgastat for gv_$sgastat;
grant select on gv_$sgastat to select_catalog_role;

create or replace view gv_$sgainfo as select * from gv$sgainfo;
create or replace public synonym gv$sgainfo for gv_$sgainfo;
grant select on gv_$sgainfo to select_catalog_role;

create or replace view gv_$waitstat as select * from gv$waitstat;
create or replace public synonym gv$waitstat for gv_$waitstat;
grant select on gv_$waitstat to select_catalog_role;

create or replace view gv_$shared_server as select * from gv$shared_server;
create or replace public synonym gv$shared_server for gv_$shared_server;
grant select on gv_$shared_server to select_catalog_role;

create or replace view gv_$timer as select * from gv$timer;
create or replace public synonym gv$timer for gv_$timer;
grant select on gv_$timer to select_catalog_role;

create or replace view gv_$recover_file as select * from gv$recover_file;
create or replace public synonym gv$recover_file for gv_$recover_file;
grant select on gv_$recover_file to select_catalog_role;

create or replace view gv_$backup as select * from gv$backup;
create or replace public synonym gv$backup for gv_$backup;
grant select on gv_$backup to select_catalog_role;


create or replace view gv_$backup_set as select * from gv$backup_set;
create or replace public synonym gv$backup_set for gv_$backup_set;
grant select on gv_$backup_set to select_catalog_role;

create or replace view gv_$backup_piece as select * from gv$backup_piece;
create or replace public synonym gv$backup_piece for gv_$backup_piece;
grant select on gv_$backup_piece to select_catalog_role;

create or replace view gv_$backup_datafile as select * from gv$backup_datafile;
create or replace public synonym gv$backup_datafile for gv_$backup_datafile;
grant select on gv_$backup_datafile to select_catalog_role;

create or replace view gv_$backup_spfile as select * from gv$backup_spfile;
create or replace public synonym gv$backup_spfile for gv_$backup_spfile;
grant select on gv_$backup_spfile to select_catalog_role;

create or replace view gv_$backup_redolog as select * from gv$backup_redolog;
create or replace public synonym gv$backup_redolog for gv_$backup_redolog;
grant select on gv_$backup_redolog to select_catalog_role;

create or replace view gv_$backup_corruption as select * from gv$backup_corruption;
create or replace public synonym gv$backup_corruption
   for gv_$backup_corruption;
grant select on gv_$backup_corruption to select_catalog_role;

create or replace view gv_$copy_corruption as select * from gv$copy_corruption;
create or replace public synonym gv$copy_corruption for gv_$copy_corruption;
grant select on gv_$copy_corruption to select_catalog_role;

create or replace view gv_$database_block_corruption as select * from
   gv$database_block_corruption;
create or replace public synonym gv$database_block_corruption
   for gv_$database_block_corruption;
grant select on gv_$database_block_corruption to select_catalog_role;

create or replace view gv_$mttr_target_advice as select * from
   gv$mttr_target_advice;
create or replace public synonym gv$mttr_target_advice
   for gv_$mttr_target_advice;
grant select on gv_$mttr_target_advice to select_catalog_role;

create or replace view gv_$statistics_level as select * from
   gv$statistics_level;
create or replace public synonym gv$statistics_level
   for gv_$statistics_level;
grant select on gv_$statistics_level to select_catalog_role;

create or replace view gv_$deleted_object as select * from gv$deleted_object;
create or replace public synonym gv$deleted_object for gv_$deleted_object;
grant select on gv_$deleted_object to select_catalog_role;

create or replace view gv_$proxy_datafile as select * from gv$proxy_datafile;
create or replace public synonym gv$proxy_datafile for gv_$proxy_datafile;
grant select on gv_$proxy_datafile to select_catalog_role;

create or replace view gv_$proxy_archivedlog as select * from gv$proxy_archivedlog;
create or replace public synonym gv$proxy_archivedlog
   for gv_$proxy_archivedlog;
grant select on gv_$proxy_archivedlog to select_catalog_role;

create or replace view gv_$controlfile_record_section as select * from gv$controlfile_record_section;
create or replace public synonym gv$controlfile_record_section
   for gv_$controlfile_record_section;
grant select on gv_$controlfile_record_section to select_catalog_role;

create or replace view gv_$archived_log as select * from gv$archived_log;
create or replace public synonym gv$archived_log for gv_$archived_log;
grant select on gv_$archived_log to select_catalog_role;

create or replace view gv_$foreign_archived_log as select * from gv$foreign_archived_log;
create or replace public synonym gv$foreign_archived_log for gv_$foreign_archived_log;
grant select on gv_$foreign_archived_log to select_catalog_role;

create or replace view gv_$offline_range as select * from gv$offline_range;
create or replace public synonym gv$offline_range for gv_$offline_range;
grant select on gv_$offline_range to select_catalog_role;

create or replace view gv_$datafile_copy as select * from gv$datafile_copy;
create or replace public synonym gv$datafile_copy for gv_$datafile_copy;
grant select on gv_$datafile_copy to select_catalog_role;

create or replace view gv_$log_history as select * from gv$log_history;
create or replace public synonym gv$log_history for gv_$log_history;
grant select on gv_$log_history to select_catalog_role;

create or replace view gv_$recovery_log as select * from gv$recovery_log;
create or replace public synonym gv$recovery_log for gv_$recovery_log;
grant select on gv_$recovery_log to select_catalog_role;

create or replace view gv_$archive_gap as select * from gv$archive_gap;
create or replace public synonym gv$archive_gap for gv_$archive_gap;
grant select on gv_$archive_gap to select_catalog_role;

create or replace view gv_$datafile_header as select * from gv$datafile_header;
create or replace public synonym gv$datafile_header for gv_$datafile_header;
grant select on gv_$datafile_header to select_catalog_role;

create or replace view gv_$backup_device as select * from gv$backup_device;
create or replace public synonym gv$backup_device for gv_$backup_device;
grant select on gv_$backup_device to select_catalog_role;

create or replace view gv_$managed_standby as select * from gv$managed_standby;
create or replace public synonym gv$managed_standby for gv_$managed_standby;
grant select on gv_$managed_standby to select_catalog_role;

create or replace view gv_$archive_processes as select * from gv$archive_processes;
create or replace public synonym gv$archive_processes
   for gv_$archive_processes;
grant select on gv_$archive_processes to select_catalog_role;

create or replace view gv_$archive_dest as select * from gv$archive_dest;
create or replace public synonym gv$archive_dest for gv_$archive_dest;
grant select on gv_$archive_dest to select_catalog_role;

create or replace view gv_$redo_dest_resp_histogram as 
  select * from gv$redo_dest_resp_histogram;
create or replace public synonym gv$redo_dest_resp_histogram for 
  gv_$redo_dest_resp_histogram;
grant select on gv_$redo_dest_resp_histogram to select_catalog_role;

create or replace view gv_$dataguard_config as
   select * from gv$dataguard_config;
create or replace public synonym gv$dataguard_config for gv_$dataguard_config;
grant select on gv_$dataguard_config to select_catalog_role;

create or replace view gv_$fixed_table as select * from gv$fixed_table;
create or replace public synonym gv$fixed_table for gv_$fixed_table;
grant select on gv_$fixed_table to select_catalog_role;

create or replace view gv_$fixed_view_definition as
   select * from gv$fixed_view_definition;
create or replace public synonym gv$fixed_view_definition
   for gv_$fixed_view_definition;
grant select on gv_$fixed_view_definition to select_catalog_role;

create or replace view gv_$indexed_fixed_column as
  select * from gv$indexed_fixed_column;
create or replace public synonym gv$indexed_fixed_column
   for gv_$indexed_fixed_column;
grant select on gv_$indexed_fixed_column to select_catalog_role;

create or replace view gv_$session_cursor_cache as
  select * from gv$session_cursor_cache;
create or replace public synonym gv$session_cursor_cache
   for gv_$session_cursor_cache;
grant select on gv_$session_cursor_cache to select_catalog_role;

create or replace view gv_$session_wait_class as
  select * from gv$session_wait_class;
create or replace public synonym gv$session_wait_class
  for gv_$session_wait_class;
grant select on gv_$session_wait_class to select_catalog_role;

create or replace view gv_$session_wait as
  select * from gv$session_wait;
create or replace public synonym gv$session_wait for gv_$session_wait;
grant select on gv_$session_wait to select_catalog_role;

create or replace view gv_$session_wait_history as
  select * from gv$session_wait_history;
create or replace public synonym gv$session_wait_history
  for gv_$session_wait_history;
grant select on gv_$session_wait_history to select_catalog_role;

create or replace view gv_$session_blockers as
  select * from gv$session_blockers;
create or replace public synonym gv$session_blockers
  for gv_$session_blockers;
grant select on gv_$session_blockers to select_catalog_role; 

create or replace view gv_$session_event as
  select * from gv$session_event;
create or replace public synonym gv$session_event for gv_$session_event;
grant select on gv_$session_event to select_catalog_role;

create or replace view gv_$session_connect_info as
  select * from gv$session_connect_info;
create or replace public synonym gv$session_connect_info
   for gv_$session_connect_info;
grant select on gv_$session_connect_info to select_catalog_role;

create or replace view gv_$system_wait_class as
  select * from gv$system_wait_class;
create or replace public synonym gv$system_wait_class for gv_$system_wait_class;
grant select on gv_$system_wait_class to select_catalog_role;

create or replace view gv_$system_event as
  select * from gv$system_event;
create or replace public synonym gv$system_event for gv_$system_event;
grant select on gv_$system_event to select_catalog_role;

create or replace view gv_$event_name as
  select * from gv$event_name;
create or replace public synonym gv$event_name for gv_$event_name;
grant select on gv_$event_name to select_catalog_role;

create or replace view gv_$event_histogram as
  select * from gv$event_histogram;
create or replace public synonym gv$event_histogram for gv_$event_histogram;
grant select on gv_$event_histogram to select_catalog_role;

create or replace view gv_$file_histogram as
  select * from gv$file_histogram;
create or replace public synonym gv$file_histogram for gv_$file_histogram;
grant select on gv_$file_histogram to select_catalog_role;

create or replace view gv_$file_optimized_histogram as
  select * from gv$file_optimized_histogram;
create or replace public synonym gv$file_optimized_histogram 
  for gv_$file_optimized_histogram;
grant select on gv_$file_optimized_histogram to select_catalog_role;

create or replace view gv_$execution as
  select * from gv$execution;
create or replace public synonym gv$execution for gv_$execution;
grant select on gv_$execution to select_catalog_role;

create or replace view gv_$system_cursor_cache as
  select * from gv$system_cursor_cache;
create or replace public synonym gv$system_cursor_cache
   for gv_$system_cursor_cache;
grant select on gv_$system_cursor_cache to select_catalog_role;

create or replace view gv_$sess_io as
  select * from gv$sess_io;
create or replace public synonym gv$sess_io for gv_$sess_io;
grant select on gv_$sess_io to select_catalog_role;

create or replace view gv_$recovery_status as
  select * from gv$recovery_status;
create or replace public synonym gv$recovery_status for gv_$recovery_status;
grant select on gv_$recovery_status to select_catalog_role;

create or replace view gv_$recovery_file_status as
  select * from gv$recovery_file_status;
create or replace public synonym gv$recovery_file_status
   for gv_$recovery_file_status;
grant select on gv_$recovery_file_status to select_catalog_role;

create or replace view gv_$recovery_progress as
  select * from gv$recovery_progress;
create or replace public synonym gv$recovery_progress
   for gv_$recovery_progress;
grant select on gv_$recovery_progress to select_catalog_role;

create or replace view gv_$shared_pool_reserved as
  select * from gv$shared_pool_reserved;
create or replace public synonym gv$shared_pool_reserved
   for gv_$shared_pool_reserved;
grant select on gv_$shared_pool_reserved to select_catalog_role;

create or replace view gv_$sort_segment as select * from gv$sort_segment;
create or replace public synonym gv$sort_segment for gv_$sort_segment;
grant select on gv_$sort_segment to select_catalog_role;

create or replace view gv_$sort_usage as select * from gv$sort_usage;
create or replace public synonym gv$tempseg_usage for gv_$sort_usage;
create or replace public synonym gv$sort_usage for gv_$sort_usage;
grant select on gv_$sort_usage to select_catalog_role;

create or replace view gv_$pq_tqstat as select * from gv$pq_tqstat;
create or replace public synonym gv$pq_tqstat for gv_$pq_tqstat;
grant select on gv_$pq_tqstat to public;

create or replace view gv_$active_instances as select * from gv$active_instances;
create or replace public synonym gv$active_instances for gv_$active_instances;
grant select on gv_$active_instances to public;

create or replace view gv_$sql_cursor as select * from gv$sql_cursor;
create or replace public synonym gv$sql_cursor for gv_$sql_cursor;
grant select on gv_$sql_cursor to select_catalog_role;

create or replace view gv_$sql_bind_metadata as
  select * from gv$sql_bind_metadata;
create or replace public synonym gv$sql_bind_metadata
   for gv_$sql_bind_metadata;
grant select on gv_$sql_bind_metadata to select_catalog_role;

create or replace view gv_$sql_bind_data as select * from gv$sql_bind_data;
create or replace public synonym gv$sql_bind_data for gv_$sql_bind_data;
grant select on gv_$sql_bind_data to select_catalog_role;

create or replace view gv_$sql_shared_memory
  as select * from gv$sql_shared_memory;
create or replace public synonym gv$sql_shared_memory
   for gv_$sql_shared_memory;
grant select on gv_$sql_shared_memory to select_catalog_role;

create or replace view gv_$global_transaction
  as select * from gv$global_transaction;
create or replace public synonym gv$global_transaction
   for gv_$global_transaction;
grant select on gv_$global_transaction to select_catalog_role;

create or replace view gv_$session_object_cache as
  select * from gv$session_object_cache;
create or replace public synonym gv$session_object_cache
   for gv_$session_object_cache;
grant select on gv_$session_object_cache to select_catalog_role;

create or replace view gv_$aq1 as
  select * from gv$aq1;
create or replace public synonym gv$aq1 for gv_$aq1;
grant select on gv_$aq1 to select_catalog_role;

create or replace view gv_$lock_activity as
  select * from gv$lock_activity;
create or replace public synonym gv$lock_activity for gv_$lock_activity;
grant select on gv_$lock_activity to public;

create or replace view gv_$hs_agent as
  select * from gv$hs_agent;
create or replace public synonym gv$hs_agent for gv_$hs_agent;
grant select on gv_$hs_agent to select_catalog_role;

create or replace view gv_$hs_session as
  select * from gv$hs_session;
create or replace public synonym gv$hs_session for gv_$hs_session;
grant select on gv_$hs_session to select_catalog_role;

create or replace view gv_$hs_parameter as
  select * from gv$hs_parameter;
create or replace public synonym gv$hs_parameter for gv_$hs_parameter;
grant select on gv_$hs_parameter to select_catalog_role;

create or replace view gv_$rsrc_consume_group_cpu_mth as
  select * from gv$rsrc_consumer_group_cpu_mth;
create or replace public synonym gv$rsrc_consumer_group_cpu_mth
   for gv_$rsrc_consume_group_cpu_mth;
grant select on gv_$rsrc_consume_group_cpu_mth to public;

create or replace view gv_$rsrc_plan_cpu_mth as
  select * from gv$rsrc_plan_cpu_mth;
create or replace public synonym gv$rsrc_plan_cpu_mth
   for gv_$rsrc_plan_cpu_mth;
grant select on gv_$rsrc_plan_cpu_mth to public;

create or replace view gv_$rsrc_consumer_group as
  select * from gv$rsrc_consumer_group;
create or replace public synonym gv$rsrc_consumer_group
   for gv_$rsrc_consumer_group;
grant select on gv_$rsrc_consumer_group to public;

create or replace view gv_$rsrc_session_info as
  select * from gv$rsrc_session_info;
create or replace public synonym gv$rsrc_session_info
   for gv_$rsrc_session_info;
grant select on gv_$rsrc_session_info to public;

create or replace view gv_$rsrc_plan as
  select * from gv$rsrc_plan;
create or replace public synonym gv$rsrc_plan for gv_$rsrc_plan;
grant select on gv_$rsrc_plan to public;

create or replace view gv_$rsrc_cons_group_history as
  select * from gv$rsrc_cons_group_history;
create or replace public synonym gv$rsrc_cons_group_history 
  for gv_$rsrc_cons_group_history;
grant select on gv_$rsrc_cons_group_history to public;

create or replace view gv_$rsrc_plan_history as
  select * from gv$rsrc_plan_history;
create or replace public synonym gv$rsrc_plan_history 
  for gv_$rsrc_plan_history;
grant select on gv_$rsrc_plan_history to public;

create or replace view gv_$blocking_quiesce as
  select * from gv$blocking_quiesce;
create or replace public synonym gv$blocking_quiesce
   for gv_$blocking_quiesce;
grant select on gv_$blocking_quiesce to public;

create or replace view gv_$px_buffer_advice as
  select * from gv$px_buffer_advice;
create or replace public synonym gv$px_buffer_advice for gv_$px_buffer_advice;
grant select on gv_$px_buffer_advice to select_catalog_role;

create or replace view gv_$px_session as
  select * from gv$px_session;
create or replace public synonym gv$px_session for gv_$px_session;
grant select on gv_$px_session to select_catalog_role;

create or replace view gv_$px_sesstat as
  select * from gv$px_sesstat;
create or replace public synonym gv$px_sesstat for gv_$px_sesstat;
grant select on gv_$px_sesstat to select_catalog_role;

create or replace view gv_$backup_sync_io as
  select * from gv$backup_sync_io;
create or replace public synonym gv$backup_sync_io for gv_$backup_sync_io;
grant select on gv_$backup_sync_io to select_catalog_role;

create or replace view gv_$backup_async_io as
  select * from gv$backup_async_io;
create or replace public synonym gv$backup_async_io for gv_$backup_async_io;
grant select on gv_$backup_async_io to select_catalog_role;

create or replace view gv_$temporary_lobs as select * from gv$temporary_lobs;
create or replace public synonym gv$temporary_lobs for gv_$temporary_lobs;
grant select on gv_$temporary_lobs to public;

create or replace view gv_$px_process as
  select * from gv$px_process;
create or replace public synonym gv$px_process for gv_$px_process;
grant select on gv_$px_process to select_catalog_role;

create or replace view gv_$px_process_sysstat as
  select * from gv$px_process_sysstat;
create or replace public synonym gv$px_process_sysstat
   for gv_$px_process_sysstat;
grant select on gv_$px_process_sysstat to select_catalog_role;

create or replace view gv_$logmnr_contents as
  select * from gv$logmnr_contents;
create or replace public synonym gv$logmnr_contents for gv_$logmnr_contents;
grant select on gv_$logmnr_contents to select_catalog_role;

create or replace view gv_$logmnr_parameters as
  select * from gv$logmnr_parameters;
create or replace public synonym gv$logmnr_parameters
   for gv_$logmnr_parameters;
grant select on gv_$logmnr_parameters to select_catalog_role;

create or replace view gv_$logmnr_dictionary as
  select * from gv$logmnr_dictionary;
create or replace public synonym gv$logmnr_dictionary
   for gv_$logmnr_dictionary;
grant select on gv_$logmnr_dictionary to select_catalog_role;

create or replace view gv_$logmnr_logs as
  select * from gv$logmnr_logs;
create or replace public synonym gv$logmnr_logs for gv_$logmnr_logs;
grant select on gv_$logmnr_logs to select_catalog_role;

create or replace view gv_$rfs_thread as
  select * from gv$rfs_thread;
create or replace public synonym gv$rfs_thread for gv_$rfs_thread;
grant select on gv_$rfs_thread to select_catalog_role;

create or replace view gv_$dataguard_stats as select * from gv$dataguard_stats;
create or replace public synonym gv$dataguard_stats for gv_$dataguard_stats;
grant select on gv_$dataguard_stats to select_catalog_role;

create or replace view gv_$global_blocked_locks as
select * from gv$global_blocked_locks;
create or replace public synonym gv$global_blocked_locks
   for gv_$global_blocked_locks;
grant select on gv_$global_blocked_locks to select_catalog_role;

create or replace view gv_$aw_olap as select * from gv$aw_olap;
create or replace public synonym gv$aw_olap for gv_$aw_olap;
grant select on gv_$aw_olap to select_catalog_role;

create or replace view gv_$aw_calc as select * from gv$aw_calc;
create or replace public synonym gv$aw_calc for gv_$aw_calc;
grant select on gv_$aw_calc to select_catalog_role;

create or replace view gv_$aw_session_info as select * from gv$aw_session_info;
create or replace public synonym gv$aw_session_info for gv_$aw_session_info;
grant select on gv_$aw_session_info to select_catalog_role;

create or replace view gv_$aw_longops as select * from gv$aw_longops;
create or replace public synonym gv$aw_longops for gv_$aw_longops;
grant select on gv_$aw_longops to public;

create or replace view gv_$max_active_sess_target_mth as
  select * from gv$max_active_sess_target_mth;
create or replace public synonym gv$max_active_sess_target_mth
   for gv_$max_active_sess_target_mth;
grant select on gv_$max_active_sess_target_mth to public;

create or replace view gv_$active_sess_pool_mth as
  select * from gv$active_sess_pool_mth;
create or replace public synonym gv$active_sess_pool_mth
   for gv_$active_sess_pool_mth;
grant select on gv_$active_sess_pool_mth to public;

create or replace view gv_$parallel_degree_limit_mth as
  select * from gv$parallel_degree_limit_mth;
create or replace public synonym gv$parallel_degree_limit_mth
   for gv_$parallel_degree_limit_mth;
grant select on gv_$parallel_degree_limit_mth to public;

create or replace view gv_$queueing_mth as
  select * from gv$queueing_mth;
create or replace public synonym gv$queueing_mth for gv_$queueing_mth;
grant select on gv_$queueing_mth to public;

create or replace view gv_$reserved_words as
  select * from gv$reserved_words;
create or replace public synonym gv$reserved_words for gv_$reserved_words;
grant select on gv_$reserved_words to select_catalog_role;

create or replace view gv_$archive_dest_status as select * from gv$archive_dest_status;
create or replace public synonym gv$archive_dest_status
   for gv_$archive_dest_status;
grant select on gv_$archive_dest_status to select_catalog_role;


create or replace view v_$logmnr_logfile as
  select * from v$logmnr_logfile;
create or replace public synonym v$logmnr_logfile for v_$logmnr_logfile;
grant select on v_$logmnr_logfile to select_catalog_role;

create or replace view v_$logmnr_process as
  select * from v$logmnr_process;
create or replace public synonym v$logmnr_process for v_$logmnr_process;
grant select on v_$logmnr_process to select_catalog_role;

create or replace view v_$logmnr_latch as
  select * from v$logmnr_latch;
create or replace public synonym v$logmnr_latch for v_$logmnr_latch;
grant select on v_$logmnr_latch to select_catalog_role;

create or replace view v_$logmnr_transaction as
  select * from v$logmnr_transaction;
create or replace public synonym v$logmnr_transaction
   for v_$logmnr_transaction;
grant select on v_$logmnr_transaction to select_catalog_role;

create or replace view v_$logmnr_region as
  select * from v$logmnr_region;
create or replace public synonym v$logmnr_region for v_$logmnr_region;
grant select on v_$logmnr_region to select_catalog_role;

create or replace view v_$logmnr_callback as
  select * from v$logmnr_callback;
create or replace public synonym v$logmnr_callback for v_$logmnr_callback;
grant select on v_$logmnr_callback to select_catalog_role;

create or replace view v_$logmnr_session as
  select * from v$logmnr_session;
create or replace public synonym v$logmnr_session for v_$logmnr_session;
grant select on v_$logmnr_session to select_catalog_role;


create or replace view gv_$logmnr_logfile as
  select * from gv$logmnr_logfile;
create or replace public synonym gv$logmnr_logfile for gv_$logmnr_logfile;
grant select on gv_$logmnr_logfile to select_catalog_role;

create or replace view gv_$logmnr_process as
  select * from gv$logmnr_process;
create or replace public synonym gv$logmnr_process for gv_$logmnr_process;
grant select on gv_$logmnr_process to select_catalog_role;

create or replace view gv_$logmnr_latch as
  select * from gv$logmnr_latch;
create or replace public synonym gv$logmnr_latch for gv_$logmnr_latch;
grant select on gv_$logmnr_latch to select_catalog_role;

create or replace view gv_$logmnr_transaction as
  select * from gv$logmnr_transaction;
create or replace public synonym gv$logmnr_transaction
   for gv_$logmnr_transaction;
grant select on gv_$logmnr_transaction to select_catalog_role;

create or replace view gv_$logmnr_region as
  select * from gv$logmnr_region;
create or replace public synonym gv$logmnr_region for gv_$logmnr_region;
grant select on gv_$logmnr_region to select_catalog_role;

create or replace view gv_$logmnr_callback as
  select * from gv$logmnr_callback;
create or replace public synonym gv$logmnr_callback for gv_$logmnr_callback;
grant select on gv_$logmnr_callback to select_catalog_role;

create or replace view gv_$logmnr_session as
  select * from gv$logmnr_session;
create or replace public synonym gv$logmnr_session for gv_$logmnr_session;
grant select on gv_$logmnr_session to select_catalog_role;

create or replace view gv_$logmnr_stats as select * from gv$logmnr_stats;
create or replace public synonym gv$logmnr_stats for gv_$logmnr_stats;
grant select on gv_$logmnr_stats to select_catalog_role;

create or replace view gv_$logmnr_dictionary_load as
  select * from gv$logmnr_dictionary_load;
create or replace public synonym gv$logmnr_dictionary_load
  for gv_$logmnr_dictionary_load;
grant select on gv_$logmnr_dictionary_load to select_catalog_role;

create or replace view gv_$db_cache_advice as select * from gv$db_cache_advice;
create or replace public synonym gv$db_cache_advice for gv_$db_cache_advice;
grant select on gv_$db_cache_advice to select_catalog_role;

create or replace view gv_$sga_target_advice as select * from gv$sga_target_advice;
create or replace public synonym gv$sga_target_advice for gv_$sga_target_advice;
grant select on gv_$sga_target_advice to select_catalog_role;

create or replace view gv_$segment_statistics as
  select * from gv$segment_statistics;
create or replace public synonym gv$segment_statistics
  for gv_$segment_statistics;
grant select on gv_$segment_statistics to select_catalog_role;

create or replace view gv_$segstat_name as
  select * from gv$segstat_name;
create or replace public synonym gv$segstat_name
  for gv_$segstat_name;
grant select on gv_$segstat_name to select_catalog_role;

create or replace view gv_$segstat as select * from gv$segstat;
create or replace public synonym gv$segstat for gv_$segstat;
grant select on gv_$segstat to select_catalog_role;

create or replace view gv_$library_cache_memory as
  select * from gv$library_cache_memory;
create or replace public synonym gv$library_cache_memory
  for gv_$library_cache_memory;
grant select on gv_$library_cache_memory to select_catalog_role;

create or replace view gv_$java_library_cache_memory as
  select * from gv$java_library_cache_memory;
create or replace public synonym gv$java_library_cache_memory
  for gv_$java_library_cache_memory;
grant select on gv_$java_library_cache_memory to select_catalog_role;

create or replace view gv_$shared_pool_advice as
  select * from gv$shared_pool_advice;
create or replace public synonym gv$shared_pool_advice
  for gv_$shared_pool_advice;
grant select on gv_$shared_pool_advice to select_catalog_role;

create or replace view gv_$java_pool_advice as
  select * from gv$java_pool_advice;
create or replace public synonym gv$java_pool_advice
  for gv_$java_pool_advice;
grant select on gv_$java_pool_advice to select_catalog_role;

create or replace view gv_$streams_pool_advice as
  select * from gv$streams_pool_advice;
create or replace public synonym gv$streams_pool_advice
  for gv_$streams_pool_advice;
grant select on gv_$streams_pool_advice to select_catalog_role;

create or replace view gv_$goldengate_capabilities as
  select * from gv$goldengate_capabilities;
create or replace public synonym gv$goldengate_capabilities
  for gv_$goldengate_capabilities;
grant select on gv_$goldengate_capabilities to select_catalog_role;

create or replace view gv_$sga_current_resize_ops as
  select * from gv$sga_current_resize_ops;
create or replace public synonym gv$sga_current_resize_ops
  for gv_$sga_current_resize_ops;
grant select on gv_$sga_current_resize_ops to select_catalog_role;

create or replace view gv_$sga_resize_ops as
  select * from gv$sga_resize_ops;
create or replace public synonym gv$sga_resize_ops
  for gv_$sga_resize_ops;
grant select on gv_$sga_resize_ops to select_catalog_role;

create or replace view gv_$sga_dynamic_components as
  select * from gv$sga_dynamic_components;
create or replace public synonym gv$sga_dynamic_components
  for gv_$sga_dynamic_components;
grant select on gv_$sga_dynamic_components to select_catalog_role;

create or replace view gv_$sga_dynamic_free_memory as
  select * from gv$sga_dynamic_free_memory;
create or replace public synonym gv$sga_dynamic_free_memory
  for gv_$sga_dynamic_free_memory;
grant select on gv_$sga_dynamic_free_memory to select_catalog_role;

create or replace view gv_$resumable as select * from gv$resumable;
create or replace public synonym gv$resumable for gv_$resumable;
grant select on gv_$resumable to select_catalog_role;

create or replace view gv_$timezone_names as select * from gv$timezone_names;
create or replace public synonym gv$timezone_names for gv_$timezone_names;
grant select on gv_$timezone_names to public;

create or replace view gv_$timezone_file as select * from gv$timezone_file;
create or replace public synonym gv$timezone_file for gv_$timezone_file;
grant select on gv_$timezone_file to public;

create or replace view gv_$enqueue_stat as select * from gv$enqueue_stat;
create or replace public synonym gv$enqueue_stat for gv_$enqueue_stat;
grant select on gv_$enqueue_stat to select_catalog_role;

create or replace view gv_$enqueue_statistics as select * from gv$enqueue_statistics;
create or replace public synonym gv$enqueue_statistics for gv_$enqueue_statistics;
grant select on gv_$enqueue_statistics to select_catalog_role;

create or replace view gv_$lock_type as select * from gv$lock_type;
create or replace public synonym gv$lock_type for gv_$lock_type;
grant select on gv_$lock_type to select_catalog_role;

create or replace view gv_$rman_configuration as select * from gv$rman_configuration;
create or replace public synonym gv$rman_configuration
   for gv_$rman_configuration;
grant select on gv_$rman_configuration to select_catalog_role;

create or replace view gv_$vpd_policy as
  select * from gv$vpd_policy;
create or replace public synonym gv$vpd_policy for gv_$vpd_policy;
grant select on gv_$vpd_policy to select_catalog_role;

create or replace view v_$vpd_policy as
  select * from v$vpd_policy;
create or replace public synonym v$vpd_policy for v_$vpd_policy;
grant select on v_$vpd_policy to select_catalog_role;

create or replace view gv_$database_incarnation as select * from
   gv$database_incarnation;
create or replace public synonym gv$database_incarnation
   for gv_$database_incarnation;
grant select on gv_$database_incarnation to select_catalog_role;

CREATE or replace VIEW gv_$asm_template as
  SELECT * FROM gv$asm_template;
  CREATE or replace PUBLIC synonym gv$asm_template FOR gv_$asm_template;
  GRANT SELECT ON gv_$asm_template TO select_catalog_role;

  CREATE or replace VIEW v_$asm_template as
    SELECT * FROM v$asm_template;
 CREATE or replace PUBLIC synonym v$asm_template FOR v_$asm_template;
 GRANT SELECT ON v_$asm_template TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_file as
  SELECT * FROM gv$asm_file;
  CREATE or replace PUBLIC synonym gv$asm_file FOR gv_$asm_file;
  GRANT SELECT ON gv_$asm_file TO select_catalog_role;

  CREATE or replace VIEW v_$asm_file as
    SELECT * FROM v$asm_file;
 CREATE or replace PUBLIC synonym v$asm_file FOR v_$asm_file;
 GRANT SELECT ON v_$asm_file TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_diskgroup as
  SELECT * FROM gv$asm_diskgroup;
  CREATE or replace PUBLIC synonym gv$asm_diskgroup FOR gv_$asm_diskgroup;
  GRANT SELECT ON gv_$asm_diskgroup TO select_catalog_role;

  CREATE or replace VIEW v_$asm_diskgroup as
    SELECT * FROM v$asm_diskgroup;
 CREATE or replace PUBLIC synonym v$asm_diskgroup FOR v_$asm_diskgroup;
 GRANT SELECT ON v_$asm_diskgroup TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_diskgroup_stat as
  SELECT * FROM gv$asm_diskgroup_stat;
  CREATE or replace PUBLIC synonym gv$asm_diskgroup_stat FOR
    gv_$asm_diskgroup_stat;
  GRANT SELECT ON gv_$asm_diskgroup_stat TO select_catalog_role;

  CREATE or replace VIEW v_$asm_diskgroup_stat as
    SELECT * FROM v$asm_diskgroup_stat;
 CREATE or replace PUBLIC synonym v$asm_diskgroup_stat FOR
    v_$asm_diskgroup_stat;
 GRANT SELECT ON v_$asm_diskgroup_stat TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_disk as
  SELECT * FROM gv$asm_disk;
  CREATE or replace PUBLIC synonym gv$asm_disk FOR gv_$asm_disk;
  GRANT SELECT ON gv_$asm_disk TO select_catalog_role;

  CREATE or replace VIEW v_$asm_disk as
    SELECT * FROM v$asm_disk;
 CREATE or replace PUBLIC synonym v$asm_disk FOR v_$asm_disk;
 GRANT SELECT ON v_$asm_disk TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_disk_stat as
  SELECT * FROM gv$asm_disk_stat;
  CREATE or replace PUBLIC synonym gv$asm_disk_stat FOR gv_$asm_disk_stat;
  GRANT SELECT ON gv_$asm_disk_stat TO select_catalog_role;

  CREATE or replace VIEW v_$asm_disk_stat as
    SELECT * FROM v$asm_disk_stat;
 CREATE or replace PUBLIC synonym v$asm_disk_stat FOR v_$asm_disk_stat;
 GRANT SELECT ON v_$asm_disk_stat TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_client as
  SELECT * FROM gv$asm_client;
  CREATE or replace PUBLIC synonym gv$asm_client FOR gv_$asm_client;
  GRANT SELECT ON gv_$asm_client TO select_catalog_role;

  CREATE or replace VIEW v_$asm_client as
    SELECT * FROM v$asm_client;
 CREATE or replace PUBLIC synonym v$asm_client FOR v_$asm_client;
 GRANT SELECT ON v_$asm_client TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_alias as
  SELECT * FROM gv$asm_alias;
  CREATE or replace PUBLIC synonym gv$asm_alias FOR gv_$asm_alias;
  GRANT SELECT ON gv_$asm_alias TO select_catalog_role;

  CREATE or replace VIEW v_$asm_alias as
    SELECT * FROM v$asm_alias;
 CREATE or replace PUBLIC synonym v$asm_alias FOR v_$asm_alias;
 GRANT SELECT ON v_$asm_alias TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_attribute as
  SELECT * FROM gv$asm_attribute;
  CREATE or replace PUBLIC synonym gv$asm_attribute FOR gv_$asm_attribute;
  GRANT SELECT ON gv_$asm_attribute TO select_catalog_role;

  CREATE or replace VIEW v_$asm_attribute as
    SELECT * FROM v$asm_attribute;
 CREATE or replace PUBLIC synonym v$asm_attribute FOR v_$asm_attribute;
 GRANT SELECT ON v_$asm_attribute TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_operation as
  SELECT * FROM gv$asm_operation;
  CREATE or replace PUBLIC synonym gv$asm_operation FOR gv_$asm_operation;
  GRANT SELECT ON gv_$asm_operation TO select_catalog_role;

  CREATE or replace VIEW v_$asm_operation as
    SELECT * FROM v$asm_operation;
 CREATE or replace PUBLIC synonym v$asm_operation FOR v_$asm_operation;
 GRANT SELECT ON v_$asm_operation TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_user as
  SELECT * FROM gv$asm_user;
  CREATE or replace PUBLIC synonym gv$asm_user FOR gv_$asm_user;
  GRANT SELECT ON gv_$asm_user TO select_catalog_role;

  CREATE or replace VIEW v_$asm_user as
    SELECT * FROM v$asm_user;
 CREATE or replace PUBLIC synonym v$asm_user FOR v_$asm_user;
 GRANT SELECT ON v_$asm_user TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_usergroup as
  SELECT * FROM gv$asm_usergroup;
  CREATE or replace PUBLIC synonym gv$asm_usergroup FOR gv_$asm_usergroup;
  GRANT SELECT ON gv_$asm_usergroup TO select_catalog_role;

  CREATE or replace VIEW v_$asm_usergroup as
    SELECT * FROM v$asm_usergroup;
 CREATE or replace PUBLIC synonym v$asm_usergroup FOR v_$asm_usergroup;
 GRANT SELECT ON v_$asm_usergroup TO select_catalog_role;

 CREATE or replace VIEW gv_$asm_usergroup_member as
  SELECT * FROM gv$asm_usergroup_member;
  CREATE or replace PUBLIC synonym gv$asm_usergroup_member
    FOR gv_$asm_usergroup_member;
  GRANT SELECT ON gv_$asm_usergroup_member TO select_catalog_role;

  CREATE or replace VIEW v_$asm_usergroup_member as
    SELECT * FROM v$asm_usergroup_member;
 CREATE or replace PUBLIC synonym v$asm_usergroup_member
   FOR v_$asm_usergroup_member;
 GRANT SELECT ON v_$asm_usergroup_member TO select_catalog_role;

create or replace view gv_$rule_set as select * from gv$rule_set;
create or replace public synonym gv$rule_set for gv_$rule_set;
grant select on gv_$rule_set to select_catalog_role;

create or replace view v_$rule_set as select * from v$rule_set;
create or replace public synonym v$rule_set for v_$rule_set;
grant select on v_$rule_set to select_catalog_role;

create or replace view gv_$rule as select * from gv$rule;
create or replace public synonym gv$rule for gv_$rule;
grant select on gv_$rule to select_catalog_role;

create or replace view v_$rule as select * from v$rule;
create or replace public synonym v$rule for v_$rule;
grant select on v_$rule to select_catalog_role;

create or replace view gv_$rule_set_aggregate_stats as
    select * from gv$rule_set_aggregate_stats;
create or replace public synonym gv$rule_set_aggregate_stats for
    gv_$rule_set_aggregate_stats;
grant select on gv_$rule_set_aggregate_stats to select_catalog_role;

create or replace view v_$rule_set_aggregate_stats as
    select * from v$rule_set_aggregate_stats;
create or replace public synonym v$rule_set_aggregate_stats for
    v_$rule_set_aggregate_stats;
grant select on v_$rule_set_aggregate_stats to select_catalog_role;

create or replace view gv_$javapool as
    select * from gv$javapool;
create or replace public synonym gv$javapool for gv_$javapool;
grant select on gv_$javapool to select_catalog_role;

create or replace view v_$javapool as
    select * from v$javapool;
create or replace public synonym v$javapool for v_$javapool;
grant select on v_$javapool to select_catalog_role;

create or replace view gv_$sysaux_occupants as
    select * from gv$sysaux_occupants;
create or replace public synonym gv$sysaux_occupants for gv_$sysaux_occupants;
grant select on gv_$sysaux_occupants to select_catalog_role;

create or replace view v_$sysaux_occupants as
    select * from v$sysaux_occupants;
create or replace public synonym v$sysaux_occupants for v_$sysaux_occupants;
grant select on v_$sysaux_occupants to select_catalog_role;

create or replace view v_$rman_status as select * from v$rman_status;
create or replace public synonym v$rman_status
   for v_$rman_status;
grant select on v_$rman_status to select_catalog_role;

create or replace view v_$rman_output as select * from v$rman_output;
create or replace public synonym v$rman_output
   for v_$rman_output;
grant select on v_$rman_output to select_catalog_role;

create or replace view gv_$rman_output as select * from gv$rman_output;
create or replace public synonym gv$rman_output
   for gv_$rman_output;
grant select on gv_$rman_output to select_catalog_role;

create or replace view v_$recovery_file_dest as select * from
   v$recovery_file_dest;
create or replace public synonym v$recovery_file_dest
   for v_$recovery_file_dest;
grant select on v_$recovery_file_dest to select_catalog_role;

create or replace view v_$flash_recovery_area_usage as select * from
   v$flash_recovery_area_usage;
create or replace public synonym v$flash_recovery_area_usage
   for v_$flash_recovery_area_usage;
grant select on v_$flash_recovery_area_usage to select_catalog_role;

create or replace view v_$recovery_area_usage as select * from
   v$recovery_area_usage;
create or replace public synonym v$recovery_area_usage
   for v_$recovery_area_usage;
grant select on v_$recovery_area_usage to select_catalog_role;

create or replace view v_$block_change_tracking as
    select * from v$block_change_tracking;
create or replace public synonym v$block_change_tracking for
    v_$block_change_tracking;
grant select on v_$block_change_tracking to select_catalog_role;

create or replace view gv_$metric as select * from gv$metric;
create or replace public synonym gv$metric for gv_$metric;
grant select on gv_$metric to select_catalog_role;

create or replace view gv_$metric_history as
          select * from gv$metric_history;
create or replace public synonym gv$metric_history
          for gv_$metric_history;
grant select on gv_$metric_history to select_catalog_role;

create or replace view gv_$sysmetric as select * from gv$sysmetric;
create or replace public synonym gv$sysmetric for gv_$sysmetric;
grant select on gv_$sysmetric to select_catalog_role;

create or replace view gv_$sysmetric_history as
          select * from gv$sysmetric_history;
create or replace public synonym gv$sysmetric_history
          for gv_$sysmetric_history;
grant select on gv_$sysmetric_history to select_catalog_role;

create or replace view gv_$metricname as select * from gv$metricname;
create or replace public synonym gv$metricname for gv_$metricname;
grant select on gv_$metricname to select_catalog_role;

create or replace view gv_$metricgroup as select * from gv$metricgroup;
create or replace public synonym gv$metricgroup for gv_$metricgroup;
grant select on gv_$metricgroup to select_catalog_role;

create or replace view gv_$active_session_history as
    select * from gv$active_session_history;
create or replace public synonym gv$active_session_history
      for gv_$active_session_history;
grant select on gv_$active_session_history to select_catalog_role;

create or replace view v_$active_session_history as
    select * from v$active_session_history;
create or replace public synonym v$active_session_history
      for v_$active_session_history;
grant select on v_$active_session_history to select_catalog_role;

create or replace view gv_$ash_info as
    select * from gv$ash_info;
create or replace public synonym gv$ash_info
      for gv_$ash_info;
grant select on gv_$ash_info to select_catalog_role;

create or replace view v_$ash_info as
    select * from v$ash_info;
create or replace public synonym v$ash_info
      for v_$ash_info;
grant select on v_$ash_info to select_catalog_role;

create or replace view gv_$workload_replay_thread as
    select * from gv$workload_replay_thread;
create or replace public synonym gv$workload_replay_thread
      for gv_$workload_replay_thread;
grant select on gv_$workload_replay_thread to select_catalog_role;

create or replace view v_$workload_replay_thread as
    select * from v$workload_replay_thread;
create or replace public synonym v$workload_replay_thread
      for v_$workload_replay_thread;
grant select on v_$workload_replay_thread to select_catalog_role;

create or replace view gv_$instance_log_group as
    select * from gv$instance_log_group;
create or replace public synonym gv$instance_log_group
      for gv_$instance_log_group;
grant select on gv_$instance_log_group to select_catalog_role;

create or replace view v_$instance_log_group as
    select * from v$instance_log_group;
create or replace public synonym v$instance_log_group
      for v_$instance_log_group;
grant select on v_$instance_log_group to select_catalog_role;

create or replace view gv_$service_wait_class as select * from gv$service_wait_class;
create or replace public synonym gv$service_wait_class for gv_$service_wait_class;
grant select on gv_$service_wait_class to select_catalog_role;

create or replace view gv_$service_event as select * from gv$service_event;
create or replace public synonym gv$service_event for gv_$service_event;
grant select on gv_$service_event to select_catalog_role;

create or replace view gv_$active_services as select * from gv$active_services;
create or replace public synonym gv$active_services for gv_$active_services;
grant select on gv_$active_services to select_catalog_role;

create or replace view gv_$services as select * from gv$services;
create or replace public synonym gv$services for gv_$services;
grant select on gv_$services to select_catalog_role;

create or replace view v_$scheduler_running_jobs as
    select * from v$scheduler_running_jobs;
create or replace public synonym v$scheduler_running_jobs
      for v_$scheduler_running_jobs;
grant select on v_$scheduler_running_jobs to select_catalog_role;

create or replace view gv_$scheduler_running_jobs as
    select * from gv$scheduler_running_jobs;
create or replace public synonym gv$scheduler_running_jobs
      for gv_$scheduler_running_jobs;
grant select on gv_$scheduler_running_jobs to select_catalog_role;

create or replace view gv_$buffered_queues as
    select * from gv$buffered_queues;
create or replace public synonym gv$buffered_queues
    for gv_$buffered_queues;
grant select on gv_$buffered_queues to select_catalog_role;

create or replace view v_$buffered_queues as
    select * from v$buffered_queues;
create or replace public synonym v$buffered_queues
    for v_$buffered_queues;
grant select on v_$buffered_queues to select_catalog_role;

create or replace view gv_$buffered_subscribers as
    select * from gv$buffered_subscribers;
create or replace public synonym gv$buffered_subscribers
    for gv_$buffered_subscribers;
grant select on gv_$buffered_subscribers to select_catalog_role;

create or replace view v_$buffered_subscribers as
    select * from v$buffered_subscribers;
create or replace public synonym v$buffered_subscribers
    for v_$buffered_subscribers;
grant select on v_$buffered_subscribers to select_catalog_role;

create or replace view gv_$buffered_publishers as
    select * from gv$buffered_publishers;
create or replace public synonym gv$buffered_publishers
    for gv_$buffered_publishers;
grant select on gv_$buffered_publishers to select_catalog_role;

create or replace view v_$buffered_publishers as
    select * from v$buffered_publishers;
create or replace public synonym v$buffered_publishers
    for v_$buffered_publishers;
grant select on v_$buffered_publishers to select_catalog_role;

create or replace view gv_$tsm_sessions as
    select * from gv$tsm_sessions;
create or replace public synonym gv$tsm_sessions
    for gv_$tsm_sessions;
grant select on gv_$tsm_sessions to select_catalog_role;

create or replace view v_$tsm_sessions as
    select * from v$tsm_sessions;
create or replace public synonym v$tsm_sessions
    for v_$tsm_sessions;
grant select on v_$tsm_sessions to select_catalog_role;

create or replace view gv_$propagation_sender as
    select * from gv$propagation_sender;
create or replace public synonym gv$propagation_sender
    for gv_$propagation_sender;
grant select on gv_$propagation_sender to select_catalog_role;

create or replace view v_$propagation_sender as
    select * from v$propagation_sender;
create or replace public synonym v$propagation_sender
    for v_$propagation_sender;
grant select on v_$propagation_sender to select_catalog_role;

create or replace view gv_$propagation_receiver as
    select * from gv$propagation_receiver;
create or replace public synonym gv$propagation_receiver
    for gv_$propagation_receiver;
grant select on gv_$propagation_receiver to select_catalog_role;

create or replace view v_$propagation_receiver as
    select * from v$propagation_receiver;
create or replace public synonym v$propagation_receiver
    for v_$propagation_receiver;
grant select on v_$propagation_receiver to select_catalog_role;

create or replace view gv_$subscr_registration_stats as
    select * from gv$subscr_registration_stats;
create or replace public synonym gv$subscr_registration_stats
    for gv_$subscr_registration_stats;
grant select on gv_$subscr_registration_stats to select_catalog_role;

create or replace view v_$subscr_registration_stats as
    select * from v$subscr_registration_stats;
create or replace public synonym v$subscr_registration_stats
    for v_$subscr_registration_stats;
grant select on v_$subscr_registration_stats to select_catalog_role;

create or replace view gv_$emon as
    select * from gv$emon;
create or replace public synonym gv$emon
    for gv_$emon;
grant select on gv_$emon to select_catalog_role;

create or replace view v_$emon as
    select * from v$emon;
create or replace public synonym v$emon
    for v_$emon;
grant select on v_$emon to select_catalog_role;


create or replace view gv_$sysmetric_summary as
    select * from gv$sysmetric_summary;
create or replace public synonym gv$sysmetric_summary
    for gv_$sysmetric_summary;
grant select on gv_$sysmetric_summary to select_catalog_role;

create or replace view gv_$sessmetric as select * from gv$sessmetric;
create or replace public synonym gv$sessmetric for gv_$sessmetric;
grant select on gv_$sessmetric to select_catalog_role;

create or replace view gv_$filemetric as select * from gv$filemetric;
create or replace public synonym gv$filemetric for gv_$filemetric;
grant select on gv_$filemetric to select_catalog_role;

create or replace view gv_$filemetric_history as
    select * from gv$filemetric_history;
create or replace public synonym gv$filemetric_history
    for gv_$filemetric_history;
grant select on gv_$filemetric_history to select_catalog_role;

create or replace view gv_$eventmetric as select * from gv$eventmetric;
create or replace public synonym gv$eventmetric for gv_$eventmetric;
grant select on gv_$eventmetric to select_catalog_role;

create or replace view gv_$waitclassmetric as
    select * from gv$waitclassmetric;
create or replace public synonym gv$waitclassmetric for gv_$waitclassmetric;
grant select on gv_$waitclassmetric to select_catalog_role;

create or replace view gv_$waitclassmetric_history as
    select * from gv$waitclassmetric_history;
create or replace public synonym gv$waitclassmetric_history
    for gv_$waitclassmetric_history;
grant select on gv_$waitclassmetric_history to select_catalog_role;

create or replace view gv_$servicemetric as select * from gv$servicemetric;
create or replace public synonym gv$servicemetric for gv_$servicemetric;
grant select on gv_$servicemetric to select_catalog_role;

create or replace view gv_$servicemetric_history
    as select * from gv$servicemetric_history;
create or replace public synonym gv$servicemetric_history
    for gv_$servicemetric_history;
grant select on gv_$servicemetric_history to select_catalog_role;

create or replace view gv_$iofuncmetric as select * from gv$iofuncmetric;
create or replace public synonym gv$iofuncmetric for gv_$iofuncmetric;
grant select on gv_$iofuncmetric to select_catalog_role;

create or replace view gv_$iofuncmetric_history
    as select * from gv$iofuncmetric_history;
create or replace public synonym gv$iofuncmetric_history
    for gv_$iofuncmetric_history;
grant select on gv_$iofuncmetric_history to select_catalog_role;

create or replace view gv_$rsrcmgrmetric as select * from gv$rsrcmgrmetric;
create or replace public synonym gv$rsrcmgrmetric for gv_$rsrcmgrmetric;
grant select on gv_$rsrcmgrmetric to select_catalog_role;

create or replace view gv_$rsrcmgrmetric_history
    as select * from gv$rsrcmgrmetric_history;
create or replace public synonym gv$rsrcmgrmetric_history
    for gv_$rsrcmgrmetric_history;
grant select on gv_$rsrcmgrmetric_history to select_catalog_role;

create or replace view gv_$wlm_pcmetric as select * from gv$wlm_pcmetric;
create or replace public synonym gv$wlm_pcmetric for gv_$wlm_pcmetric;
grant select on gv_$wlm_pcmetric to select_catalog_role;

create or replace view gv_$wlm_pcmetric_history
    as select * from gv$wlm_pcmetric_history;
create or replace public synonym gv$wlm_pcmetric_history
    for gv_$wlm_pcmetric_history;
grant select on gv_$wlm_pcmetric_history to select_catalog_role;

create or replace view gv_$wlm_pc_stats as select * from gv$wlm_pc_stats;
create or replace public synonym gv$wlm_pc_stats for gv_$wlm_pc_stats;
grant select on gv_$wlm_pc_stats to select_catalog_role;

create or replace view gv_$advisor_progress
    as select * from gv$advisor_progress;
create or replace public synonym gv$advisor_progress
    for gv_$advisor_progress;
grant select on gv_$advisor_progress to select_catalog_role;

create or replace view gv_$xml_audit_trail
    as select * from gv$xml_audit_trail;
create or replace public synonym gv$xml_audit_trail
    for gv_$xml_audit_trail;
grant select on gv_$xml_audit_trail to select_catalog_role;

create or replace view gv_$sql_join_filter
    as select * from gv$sql_join_filter;
create or replace public synonym gv$sql_join_filter
    for gv_$sql_join_filter;
grant select on gv_$sql_join_filter to select_catalog_role;

create or replace view gv_$process_memory as select * from gv$process_memory;
create or replace public synonym gv$process_memory for gv_$process_memory;
grant select on gv_$process_memory to select_catalog_role;

create or replace view gv_$process_memory_detail
    as select * from gv$process_memory_detail;
create or replace public synonym gv$process_memory_detail
    for gv_$process_memory_detail;
grant select on gv_$process_memory_detail to select_catalog_role;

create or replace view gv_$process_memory_detail_prog
    as select * from gv$process_memory_detail_prog;
create or replace public synonym gv$process_memory_detail_prog
    for gv_$process_memory_detail_prog;
grant select on gv_$process_memory_detail_prog to select_catalog_role;

create or replace view gv_$wallet
    as select * from gv$wallet;
create or replace public synonym gv$wallet
    for gv_$wallet;
grant select on gv_$wallet to select_catalog_role;

create or replace view v_$wallet
    as select * from v$wallet;
create or replace public synonym v$wallet
    for v_$wallet;
grant select on v_$wallet to select_catalog_role;

create or replace view gv_$system_fix_control 
  as select * from gv$system_fix_control;
create or replace public synonym gv$system_fix_control 
  for gv_$system_fix_control;
grant select on gv_$system_fix_control to select_catalog_role;

create or replace view v_$system_fix_control 
  as select * from v$system_fix_control;
create or replace public synonym v$system_fix_control 
  for v_$system_fix_control;
grant select on v_$system_fix_control to select_catalog_role;

create or replace view gv_$session_fix_control 
  as select * from gv$session_fix_control;
create or replace public synonym gv$session_fix_control 
  for gv_$session_fix_control;
grant select on gv_$session_fix_control to select_catalog_role;

create or replace view v_$session_fix_control 
  as select * from v$session_fix_control;
create or replace public synonym v$session_fix_control 
  for v_$session_fix_control;
grant select on v_$session_fix_control to select_catalog_role;

create or replace view gv_$fs_failover_histogram 
as select * from gv$fs_failover_histogram;
create or replace public synonym gv$fs_failover_histogram
                             for gv_$fs_failover_histogram;
grant select on gv_$fs_failover_histogram to select_catalog_role;

create or replace view v_$fs_failover_histogram 
as select * from v$fs_failover_histogram;
create or replace public synonym v$fs_failover_histogram
                             for v_$fs_failover_histogram;
grant select on v_$fs_failover_histogram to select_catalog_role;

create or replace view gv_$sql_feature 
  as select * from gv$sql_feature;
create or replace public synonym gv$sql_feature 
  for gv_$sql_feature;
grant select on gv_$sql_feature to select_catalog_role;

create or replace view v_$sql_feature 
  as select * from v$sql_feature;
create or replace public synonym v$sql_feature 
  for v_$sql_feature;
grant select on v_$sql_feature to select_catalog_role;

create or replace view gv_$sql_feature_hierarchy 
  as select * from gv$sql_feature_hierarchy;
create or replace public synonym gv$sql_feature_hierarchy 
  for gv_$sql_feature_hierarchy;
grant select on gv_$sql_feature_hierarchy to select_catalog_role;

create or replace view v_$sql_feature_hierarchy 
  as select * from v$sql_feature_hierarchy;
create or replace public synonym v$sql_feature_hierarchy 
  for v_$sql_feature_hierarchy;
grant select on v_$sql_feature_hierarchy to select_catalog_role;

create or replace view gv_$sql_feature_dependency 
  as select * from gv$sql_feature_dependency;
create or replace public synonym gv$sql_feature_dependency 
  for gv_$sql_feature_dependency;
grant select on gv_$sql_feature_dependency to select_catalog_role;

create or replace view v_$sql_feature_dependency 
  as select * from v$sql_feature_dependency;
create or replace public synonym v$sql_feature_dependency 
  for v_$sql_feature_dependency;
grant select on v_$sql_feature_dependency to select_catalog_role;

create or replace view gv_$sql_hint 
  as select * from gv$sql_hint;
create or replace public synonym gv$sql_hint 
  for gv_$sql_hint;
grant select on gv_$sql_hint to select_catalog_role;

create or replace view v_$sql_hint 
  as select * from v$sql_hint;
create or replace public synonym v$sql_hint 
  for v_$sql_hint;
grant select on v_$sql_hint to select_catalog_role;

create or replace view gv_$sql_feature_dependency 
  as select * from gv$sql_feature_dependency;
create or replace public synonym gv$sql_feature_dependency 
  for gv_$sql_feature_dependency;
grant select on gv_$sql_feature_dependency to select_catalog_role;

create or replace view v_$sql_feature_dependency 
  as select * from v$sql_feature_dependency;
create or replace public synonym v$sql_feature_dependency 
  for v_$sql_feature_dependency;
grant select on v_$sql_feature_dependency to select_catalog_role;

create or replace view gv_$sql_hint 
  as select * from gv$sql_hint;
create or replace public synonym gv$sql_hint 
  for gv_$sql_hint;
grant select on gv_$sql_hint to select_catalog_role;

create or replace view v_$sql_hint 
  as select * from v$sql_hint;
create or replace public synonym v$sql_hint 
  for v_$sql_hint;
grant select on v_$sql_hint to select_catalog_role;
create or replace view gv_$result_cache_statistics
as select * from gv$result_cache_statistics;
create or replace public synonym gv$result_cache_statistics
                             for gv_$result_cache_statistics;
grant select on gv_$result_cache_statistics to select_catalog_role;

create or replace view v_$result_cache_statistics
as select * from v$result_cache_statistics;
create or replace public synonym v$result_cache_statistics
                             for v_$result_cache_statistics;
grant select on v_$result_cache_statistics to select_catalog_role;

create or replace view gv_$result_cache_memory
as select * from gv$result_cache_memory;
create or replace public synonym gv$result_cache_memory
                             for gv_$result_cache_memory;
grant select on gv_$result_cache_memory to select_catalog_role;

create or replace view v_$result_cache_memory
as select * from v$result_cache_memory;
create or replace public synonym v$result_cache_memory
                             for v_$result_cache_memory;
grant select on v_$result_cache_memory to select_catalog_role;

create or replace view gv_$result_cache_objects
as select * from gv$result_cache_objects;
create or replace public synonym gv$result_cache_objects
                             for gv_$result_cache_objects;
grant select on gv_$result_cache_objects to select_catalog_role;

create or replace view v_$result_cache_objects
as select * from v$result_cache_objects;
create or replace public synonym v$result_cache_objects
                             for v_$result_cache_objects;
grant select on v_$result_cache_objects to select_catalog_role;

create or replace view gv_$result_cache_dependency
as select * from gv$result_cache_dependency;
create or replace public synonym gv$result_cache_dependency
                             for gv_$result_cache_dependency;
grant select on gv_$result_cache_dependency to select_catalog_role;

create or replace view v_$result_cache_dependency
as select * from v$result_cache_dependency;
create or replace public synonym v$result_cache_dependency
                             for v_$result_cache_dependency;
grant select on v_$result_cache_dependency to select_catalog_role;

Rem
Rem Add ACS fixed views
Rem

create or replace view gv_$sql_cs_histogram 
  as select * from gv$sql_cs_histogram;
create or replace public synonym gv$sql_cs_histogram 
  for gv_$sql_cs_histogram;
grant select on gv_$sql_cs_histogram to select_catalog_role;

create or replace view v_$sql_cs_histogram 
  as select * from v$sql_cs_histogram;
create or replace public synonym v$sql_cs_histogram 
 for v_$sql_cs_histogram;
grant select on v_$sql_cs_histogram to select_catalog_role;

create or replace view gv_$sql_cs_selectivity 
  as select * from gv$sql_cs_selectivity;
create or replace public synonym gv$sql_cs_selectivity 
  for gv_$sql_cs_selectivity;
grant select on gv_$sql_cs_selectivity to select_catalog_role;

create or replace view v_$sql_cs_selectivity 
  as select * from v$sql_cs_selectivity;
create or replace public synonym v$sql_cs_selectivity 
  for v_$sql_cs_selectivity;
grant select on v_$sql_cs_selectivity to select_catalog_role;

create or replace view gv_$sql_cs_statistics 
  as select * from gv$sql_cs_statistics;
create or replace public synonym gv$sql_cs_statistics 
  for gv_$sql_cs_statistics;
grant select on gv_$sql_cs_statistics to select_catalog_role;

create or replace view v_$sql_cs_statistics 
  as select * from v$sql_cs_statistics;
create or replace public synonym v$sql_cs_statistics 
  for v_$sql_cs_statistics;
grant select on v_$sql_cs_statistics to select_catalog_role;

Rem
Rem Add SQL Monitoring fixed views
Rem

create or replace view gv_$sql_monitor 
  as select * from gv$sql_monitor;
create or replace public synonym gv$sql_monitor 
  for gv_$sql_monitor;
grant select on gv_$sql_monitor to select_catalog_role;

create or replace view v_$sql_monitor 
  as select * from v$sql_monitor;
create or replace public synonym v$sql_monitor 
 for v_$sql_monitor;
grant select on v_$sql_monitor to select_catalog_role;

create or replace view gv_$sql_plan_monitor 
  as select * from gv$sql_plan_monitor;
create or replace public synonym gv$sql_plan_monitor 
  for gv_$sql_plan_monitor;
grant select on gv_$sql_plan_monitor to select_catalog_role;

create or replace view v_$sql_plan_monitor 
  as select * from v$sql_plan_monitor;
create or replace public synonym v$sql_plan_monitor 
 for v_$sql_plan_monitor;
grant select on v_$sql_plan_monitor to select_catalog_role;

remark
remark  FAMILY "NLS"
remark

create or replace view NLS_SESSION_PARAMETERS (PARAMETER, VALUE) as
select substr(parameter, 1, 30),
       substr(value, 1, 40)
from v$nls_parameters
where parameter != 'NLS_CHARACTERSET' and
 parameter != 'NLS_NCHAR_CHARACTERSET'
/
comment on table NLS_SESSION_PARAMETERS is
'NLS parameters of the user session'
/
comment on column NLS_SESSION_PARAMETERS.PARAMETER is
'Parameter name'
/
comment on column NLS_SESSION_PARAMETERS.VALUE is
'Parameter value'
/
create or replace public synonym NLS_SESSION_PARAMETERS
   for NLS_SESSION_PARAMETERS
/
grant select on NLS_SESSION_PARAMETERS to PUBLIC with grant option
/
create or replace view NLS_INSTANCE_PARAMETERS (PARAMETER, VALUE) as
select substr(upper(name), 1, 30),
       substr(value, 1, 40)
from v$system_parameter
where name like 'nls%'
/
comment on table NLS_INSTANCE_PARAMETERS is
'NLS parameters of the instance'
/
comment on column NLS_INSTANCE_PARAMETERS.PARAMETER is
'Parameter name'
/
comment on column NLS_INSTANCE_PARAMETERS.VALUE is
'Parameter value'
/
create or replace public synonym NLS_INSTANCE_PARAMETERS
   for NLS_INSTANCE_PARAMETERS
/
grant select on NLS_INSTANCE_PARAMETERS to PUBLIC with grant option
/
create or replace view NLS_DATABASE_PARAMETERS (PARAMETER, VALUE) as
select name,
       substr(value$, 1, 40)
from props$
where name like 'NLS%'
/
comment on table NLS_DATABASE_PARAMETERS is
'Permanent NLS parameters of the database'
/
comment on column NLS_DATABASE_PARAMETERS.PARAMETER is
'Parameter name'
/
comment on column NLS_DATABASE_PARAMETERS.VALUE is
'Parameter value'
/
create or replace public synonym NLS_DATABASE_PARAMETERS
   for NLS_DATABASE_PARAMETERS
/
grant select on NLS_DATABASE_PARAMETERS to PUBLIC with grant option
/

rem
rem family "DATABASE"
rem
create or replace view DATABASE_COMPATIBLE_LEVEL
    (value, description)
  as
select value,description
from v$parameter
where name = 'compatible'
/
comment on table DATABASE_COMPATIBLE_LEVEL is
'Database compatible parameter set via init.ora'
/
comment on column DATABASE_COMPATIBLE_LEVEL.VALUE is
'Parameter value'
/
comment on column DATABASE_COMPATIBLE_LEVEL.DESCRIPTION is
'Description of value'
/
create or replace public synonym DATABASE_COMPATIBLE_LEVEL
   for DATABASE_COMPATIBLE_LEVEL
/
grant select on DATABASE_COMPATIBLE_LEVEL to PUBLIC with grant option
/


Rem     PRODUCT COMPONENT VERSION
create or replace view product_component_version(product,version,status) as
(select
substr(banner,1, instr(banner,'Version')-1),
substr(banner, instr(banner,'Version')+8,
instr(banner,' - ')-(instr(banner,'Version')+8)),
substr(banner,instr(banner,' - ')+3)
from v$version
where instr(banner,'Version') > 0
and
((instr(banner,'Version') <   instr(banner,'Release')) or
instr(banner,'Release') = 0))
union
(select
substr(banner,1, instr(banner,'Release')-1),
substr(banner, instr(banner,'Release')+8,
instr(banner,' - ')-(instr(banner,'Release')+8)),
substr(banner,instr(banner,' - ')+3)
from v$version
where instr(banner,'Release') > 0
and
instr(banner,'Release') <   instr(banner,' - '))
/
comment on table product_component_version is
'version and status information for component products'
/
comment on column product_component_version.product is
'product name'
/
comment on column product_component_version.version is
'version number'
/
comment on column product_component_version.status is
'status of release'
/
grant select on product_component_version to public with grant option
/
create or replace public synonym product_component_version
   for product_component_version
/


Rem Add support for ejb generated classes
Rem This is just a stub view - the actual view is created during
Rem the JIS initialization
Rem This statement must happen before @catexp.
create or replace view sns$ejb$gen$ (owner, shortname) as
  select u.name, o.name from user$ u, obj$ o where 1=2
/


create or replace view V_$TRANSPORTABLE_PLATFORM
as select * from V$TRANSPORTABLE_PLATFORM
/
create or replace public synonym V$TRANSPORTABLE_PLATFORM
for V_$TRANSPORTABLE_PLATFORM
/
grant select on V_$TRANSPORTABLE_PLATFORM to select_catalog_role
/
create or replace view GV_$TRANSPORTABLE_PLATFORM
as select * from GV$TRANSPORTABLE_PLATFORM
/
create or replace public synonym GV$TRANSPORTABLE_PLATFORM
for GV_$TRANSPORTABLE_PLATFORM
/
grant select on GV_$TRANSPORTABLE_PLATFORM to select_catalog_role
/

create or replace view V_$DB_TRANSPORTABLE_PLATFORM
as select * from V$DB_TRANSPORTABLE_PLATFORM
/
create or replace public synonym V$DB_TRANSPORTABLE_PLATFORM
for V_$DB_TRANSPORTABLE_PLATFORM
/
grant select on V_$DB_TRANSPORTABLE_PLATFORM to select_catalog_role
/
create or replace view GV_$DB_TRANSPORTABLE_PLATFORM
as select * from GV$DB_TRANSPORTABLE_PLATFORM
/
create or replace public synonym GV$DB_TRANSPORTABLE_PLATFORM
for GV_$DB_TRANSPORTABLE_PLATFORM
/
grant select on GV_$DB_TRANSPORTABLE_PLATFORM to select_catalog_role
/

create or replace view v_$iostat_network as select * from v$iostat_network;
create or replace public synonym v$iostat_network for v_$iostat_network;
grant select on v_$iostat_network to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_network as select * from gv$iostat_network;
create or replace public synonym gv$iostat_network for gv_$iostat_network;
grant select on gv_$iostat_network to SELECT_CATALOG_ROLE;

create or replace view gv_$cpool_cc_stats as select * from gv$cpool_cc_stats;
create or replace public synonym gv$cpool_cc_stats for gv_$cpool_cc_stats;
grant select on gv_$cpool_cc_stats to select_catalog_role;

create or replace view v_$cpool_cc_stats as select * from v$cpool_cc_stats;
create or replace public synonym v$cpool_cc_stats for v_$cpool_cc_stats;
grant select on v_$cpool_cc_stats to select_catalog_role;

create or replace view gv_$cpool_cc_info as select * from gv$cpool_cc_info;
create or replace public synonym gv$cpool_cc_info for gv_$cpool_cc_info;
grant select on gv_$cpool_cc_info to select_catalog_role;

create or replace view v_$cpool_cc_info as select * from v$cpool_cc_info;
create or replace public synonym v$cpool_cc_info for v_$cpool_cc_info;
grant select on v_$cpool_cc_info to select_catalog_role;

create or replace view gv_$cpool_stats as select * from gv$cpool_stats;
create or replace public synonym gv$cpool_stats for gv_$cpool_stats;
grant select on gv_$cpool_stats to select_catalog_role;

create or replace view v_$cpool_stats as select * from v$cpool_stats;
create or replace public synonym v$cpool_stats for v_$cpool_stats;
grant select on v_$cpool_stats to select_catalog_role; 

create or replace view gv_$cpool_conn_info as select * from gv$cpool_conn_info;
create or replace public synonym gv$cpool_conn_info for gv_$cpool_conn_info;
grant select on gv_$cpool_conn_info to select_catalog_role; 

create or replace view v_$cpool_conn_info as select * from v$cpool_conn_info;
create or replace public synonym v$cpool_conn_info for v_$cpool_conn_info;
grant select on v_$cpool_conn_info to select_catalog_role; 

create or replace view gv_$hm_run as select * from gv$hm_run;
create or replace public synonym gv$hm_run for gv_$hm_run;
grant select on gv_$hm_run to select_catalog_role;

create or replace view v_$hm_run as select * from v$hm_run;
create or replace public synonym v$hm_run for v_$hm_run;
grant select on v_$hm_run to select_catalog_role;

create or replace view gv_$hm_finding as select * from gv$hm_finding;
create or replace public synonym gv$hm_finding for gv_$hm_finding;
grant select on gv_$hm_finding to select_catalog_role;

create or replace view v_$hm_finding as select * from v$hm_finding;
create or replace public synonym v$hm_finding for v_$hm_finding;
grant select on v_$hm_finding to select_catalog_role;

create or replace view gv_$hm_recommendation as
  select * from gv$hm_recommendation;
create or replace public synonym gv$hm_recommendation for gv_$hm_recommendation;
grant select on gv_$hm_recommendation to select_catalog_role;

create or replace view v_$hm_recommendation as
  select * from v$hm_recommendation;
create or replace public synonym v$hm_recommendation for v_$hm_recommendation;
grant select on v_$hm_recommendation to select_catalog_role;

create or replace view gv_$hm_info as select * from gv$hm_info;
create or replace public synonym gv$hm_info for gv_$hm_info;
grant select on gv_$hm_info to select_catalog_role;

create or replace view v_$hm_info as select * from v$hm_info;
create or replace public synonym v$hm_info for v_$hm_info;
grant select on v_$hm_info to select_catalog_role;

create or replace view gv_$hm_check as select * from gv$hm_check;
create or replace public synonym gv$hm_check for gv_$hm_check;
grant select on gv_$hm_check to select_catalog_role;

create or replace view v_$hm_check as select * from v$hm_check;
create or replace public synonym v$hm_check for v_$hm_check;
grant select on v_$hm_check to select_catalog_role;

create or replace view gv_$hm_check_param as select * from gv$hm_check_param;
create or replace public synonym gv$hm_check_param for gv_$hm_check_param;
grant select on gv_$hm_check_param to select_catalog_role;

create or replace view v_$hm_check_param as select * from v$hm_check_param;
create or replace public synonym v$hm_check_param for v_$hm_check_param;
grant select on v_$hm_check_param to select_catalog_role;

create or replace view gv_$ir_failure as select * from gv$ir_failure;
create or replace public synonym gv$ir_failure for gv_$ir_failure;
grant select on gv_$ir_failure to select_catalog_role;

create or replace view v_$ir_failure as select * from v$ir_failure;
create or replace public synonym v$ir_failure for v_$ir_failure;
grant select on v_$ir_failure to select_catalog_role;

create or replace view gv_$ir_repair as select * from gv$ir_repair;
create or replace public synonym gv$ir_repair for gv_$ir_repair;
grant select on gv_$ir_repair to select_catalog_role;

create or replace view v_$ir_repair as select * from v$ir_repair;
create or replace public synonym v$ir_repair for v_$ir_repair;
grant select on v_$ir_repair to select_catalog_role;

create or replace view gv_$ir_manual_checklist as select * from gv$ir_manual_checklist;
create or replace public synonym gv$ir_manual_checklist for gv_$ir_manual_checklist;
grant select on gv_$ir_manual_checklist to select_catalog_role;

create or replace view v_$ir_manual_checklist as select * from v$ir_manual_checklist;
create or replace public synonym v$ir_manual_checklist for v_$ir_manual_checklist;
grant select on v_$ir_manual_checklist to select_catalog_role;

create or replace view gv_$ir_failure_set as select * from gv$ir_failure_set;
create or replace public synonym gv$ir_failure_set for gv_$ir_failure_set;
grant select on gv_$ir_failure_set to select_catalog_role;

create or replace view v_$ir_failure_set as select * from v$ir_failure_set;
create or replace public synonym v$ir_failure_set for v_$ir_failure_set;
grant select on v_$ir_failure_set to select_catalog_role;

create or replace view v_$px_instance_group
as select * from v$px_instance_group;
create or replace public synonym v$px_instance_group
for v_$px_instance_group;
grant select on v_$px_instance_group to select_catalog_role;

create or replace view gv_$px_instance_group
as select * from gv$px_instance_group;     
create or replace public synonym gv$px_instance_group
for gv_$px_instance_group;
grant select on gv_$px_instance_group to select_catalog_role;

create or replace view v_$iostat_consumer_group 
as select * from v$iostat_consumer_group;
create or replace public synonym v$iostat_consumer_group 
                             for v_$iostat_consumer_group;
grant select on v_$iostat_consumer_group to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_consumer_group 
as select * from gv$iostat_consumer_group;
create or replace public synonym gv$iostat_consumer_group 
                             for gv_$iostat_consumer_group;
grant select on gv_$iostat_consumer_group to SELECT_CATALOG_ROLE;


create or replace view v_$iostat_function 
as select * from v$iostat_function;
create or replace public synonym v$iostat_function 
                             for v_$iostat_function;
grant select on v_$iostat_function to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_function 
as select * from gv$iostat_function;
create or replace public synonym gv$iostat_function 
                             for gv_$iostat_function;
grant select on gv_$iostat_function to SELECT_CATALOG_ROLE;


create or replace view v_$iostat_function_detail
as select * from v$iostat_function_detail;
create or replace public synonym v$iostat_function_detail
                             for v_$iostat_function_detail;
grant select on v_$iostat_function_detail to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_function_detail 
as select * from gv$iostat_function_detail;
create or replace public synonym gv$iostat_function_detail 
                             for gv_$iostat_function_detail;
grant select on gv_$iostat_function_detail to SELECT_CATALOG_ROLE;


create or replace view v_$iostat_file 
as select * from v$iostat_file;
create or replace public synonym v$iostat_file 
                             for v_$iostat_file;
grant select on v_$iostat_file to SELECT_CATALOG_ROLE;

create or replace view gv_$iostat_file 
as select * from gv$iostat_file;
create or replace public synonym gv$iostat_file 
                             for gv_$iostat_file;
grant select on gv_$iostat_file to SELECT_CATALOG_ROLE;


create or replace view v_$io_calibration_status
as select * from v$io_calibration_status;
create or replace public synonym v$io_calibration_status
                             for v_$io_calibration_status;
grant select on v_$io_calibration_status to SELECT_CATALOG_ROLE;

create or replace view gv_$io_calibration_status
as select * from gv$io_calibration_status;
create or replace public synonym gv$io_calibration_status 
                             for gv_$io_calibration_status;
grant select on gv_$io_calibration_status to SELECT_CATALOG_ROLE;


create or replace view gv_$corrupt_xid_list as select * from gv$corrupt_xid_list;
create or replace public synonym gv$corrupt_xid_list for gv_$corrupt_xid_list;
grant select on gv_$corrupt_xid_list to SELECT_CATALOG_ROLE;

create or replace view gv_$calltag as select * from gv$calltag;
create or replace public synonym gv$calltag for gv_$calltag;
grant select on gv_$calltag to select_catalog_role;
create or replace view v_$corrupt_xid_list as select * from v$corrupt_xid_list;
create or replace public synonym v$corrupt_xid_list for v_$corrupt_xid_list;
grant select on v_$corrupt_xid_list to SELECT_CATALOG_ROLE;

create or replace view gv_$persistent_queues as
    select * from gv$persistent_queues;
create or replace public synonym gv$persistent_queues
    for gv_$persistent_queues;
grant select on gv_$persistent_queues to select_catalog_role;

create or replace view v_$persistent_queues as
    select * from v$persistent_queues;
create or replace public synonym v$persistent_queues
    for v_$persistent_queues;
grant select on v_$persistent_queues to select_catalog_role;

create or replace view gv_$persistent_subscribers as
    select * from gv$persistent_subscribers;
create or replace public synonym gv$persistent_subscribers
    for gv_$persistent_subscribers;
grant select on gv_$persistent_subscribers to select_catalog_role;

create or replace view v_$persistent_subscribers as
    select * from v$persistent_subscribers;
create or replace public synonym v$persistent_subscribers
    for v_$persistent_subscribers;
grant select on v_$persistent_subscribers to select_catalog_role;

create or replace view gv_$persistent_publishers as
    select * from gv$persistent_publishers;
create or replace public synonym gv$persistent_publishers
    for gv_$persistent_publishers;
grant select on gv_$persistent_publishers to select_catalog_role;

create or replace view v_$persistent_publishers as
    select * from v$persistent_publishers;
create or replace public synonym v$persistent_publishers
    for v_$persistent_publishers;
grant select on v_$persistent_publishers to select_catalog_role;

create or replace view gv_$ro_user_account as
    select * from gv$ro_user_account;
create or replace public synonym gv$ro_user_account
    for gv_$ro_user_account;
grant select on gv_$ro_user_account to select_catalog_role;

create or replace view v_$ro_user_account as
    select * from v$ro_user_account;
create or replace public synonym v$ro_user_account
    for v_$ro_user_account;
grant select on v_$ro_user_account to select_catalog_role;

Rem
Rem Process group fixed views
Rem

create or replace view gv_$process_group
       as select * from gv$process_group;
create or replace public synonym gv$process_group
       for gv_$process_group;
grant select on gv_$process_group to select_catalog_role;

create or replace view gv_$detached_session
       as select * from gv$detached_session;
create or replace public synonym gv$detached_session
       for gv_$detached_session;
grant select on gv_$detached_session to select_catalog_role;

Rem 
Rem SSCR fixed views
Rem
create or replace view gv_$sscr_sessions as
    select * from gv$sscr_sessions;
create or replace public synonym gv$sscr_sessions
    for gv_$sscr_sessions;
grant select on gv_$sscr_sessions to select_catalog_role;

create or replace view v_$sscr_sessions as
    select * from v$sscr_sessions;
create or replace public synonym v$sscr_sessions
    for v_$sscr_sessions;
grant select on v_$sscr_sessions to select_catalog_role;
Rem
Rem NFS fixed views
Rem
create or replace view gv_$nfs_clients as
    select * from gv$nfs_clients;
create or replace public synonym gv$nfs_clients
    for gv_$nfs_clients;
grant select on gv_$nfs_clients to select_catalog_role;

create or replace view v_$nfs_clients as
    select * from v$nfs_clients;
create or replace public synonym v$nfs_clients
    for v_$nfs_clients;
grant select on v_$nfs_clients to select_catalog_role;

create or replace view gv_$nfs_open_files as
    select * from gv$nfs_open_files;
create or replace public synonym gv$nfs_open_files
    for gv_$nfs_open_files;
grant select on gv_$nfs_open_files to select_catalog_role;

create or replace view v_$nfs_open_files as
    select * from v$nfs_open_files;
create or replace public synonym v$nfs_open_files
    for v_$nfs_open_files;
grant select on v_$nfs_open_files to select_catalog_role;

create or replace view gv_$nfs_locks as
    select * from gv$nfs_locks;
create or replace public synonym gv$nfs_locks
    for gv_$nfs_locks;
grant select on gv_$nfs_locks to select_catalog_role;

create or replace view v_$nfs_locks as
    select * from v$nfs_locks;
create or replace public synonym v$nfs_locks
    for v_$nfs_locks;
grant select on v_$nfs_locks to select_catalog_role;

Rem
Rem RMAN compression fixed views
Rem

create or replace view v_$rman_compression_algorithm as 
    select * from v$rman_compression_algorithm;
create or replace public synonym v$rman_compression_algorithm 
    for v_$rman_compression_algorithm;
grant select on v_$rman_compression_algorithm to select_catalog_role;

create or replace view gv_$rman_compression_algorithm as 
    select * from gv$rman_compression_algorithm;
create or replace public synonym gv$rman_compression_algorithm 
    for gv_$rman_compression_algorithm;
grant select on gv_$rman_compression_algorithm to select_catalog_role;

Rem
Rem Encryption fixed views
Rem

create or replace view v_$encryption_wallet as
    select * from v$encryption_wallet;
create or replace public synonym v$encryption_wallet 
    for v_$encryption_wallet;
grant select on v_$encryption_wallet to select_catalog_role;

create or replace view gv_$encryption_wallet as 
    select * from gv$encryption_wallet;
create or replace public synonym gv$encryption_wallet 
    for gv_$encryption_wallet;
grant select on gv_$encryption_wallet to select_catalog_role;

create or replace view v_$encrypted_tablespaces as
select * from v$encrypted_tablespaces;
create or replace public synonym v$encrypted_tablespaces
   for v_$encrypted_tablespaces;
grant select on v_$encrypted_tablespaces to select_catalog_role;

create or replace view gv_$encrypted_tablespaces as
select * from gv$encrypted_tablespaces;
create or replace public synonym gv$encrypted_tablespaces
   for gv_$encrypted_tablespaces;
grant select on gv_$encrypted_tablespaces to select_catalog_role;

create or replace view v_$database_key_info as
select * from v$database_key_info;
create or replace public synonym v$database_key_info
   for v_$database_key_info;
grant select on v_$database_key_info to select_catalog_role;

create or replace view gv_$database_key_info as
select * from gv$database_key_info;
create or replace public synonym gv$database_key_info
   for gv_$database_key_info;
grant select on gv_$database_key_info to select_catalog_role;

Rem
Rem INCMETER fixed views
Rem
create or replace view gv_$incmeter_config as select * from gv$incmeter_config;
create or replace public synonym gv$incmeter_config for gv_$incmeter_config;
grant select on gv_$incmeter_config to select_catalog_role;

create or replace view v_$incmeter_config as select * from v$incmeter_config;
create or replace public synonym v$incmeter_config for v_$incmeter_config;
grant select on v_$incmeter_config to select_catalog_role;

create or replace view gv_$incmeter_summary as 
    select * from gv$incmeter_summary;
create or replace public synonym gv$incmeter_summary for gv_$incmeter_summary;
grant select on gv_$incmeter_summary to select_catalog_role;

create or replace view v_$incmeter_summary as select * from v$incmeter_summary;
create or replace public synonym v$incmeter_summary for v_$incmeter_summary;
grant select on v_$incmeter_summary to select_catalog_role;

create or replace view gv_$incmeter_info as select * from gv$incmeter_info;
create or replace public synonym gv$incmeter_info for gv_$incmeter_info;
grant select on gv_$incmeter_info to select_catalog_role;

create or replace view v_$incmeter_info as select * from v$incmeter_info;
create or replace public synonym v$incmeter_info for v_$incmeter_info;
grant select on v_$incmeter_info to select_catalog_role;

create or replace view gv_$dnfs_stats as
  select * from gv$dnfs_stats;
create or replace public synonym gv$dnfs_stats for gv_$dnfs_stats;
grant select on gv_$dnfs_stats to select_catalog_role;

create or replace view v_$dnfs_stats as
  select * from v$dnfs_stats;
create or replace public synonym v$dnfs_stats for v_$dnfs_stats;
grant select on v_$dnfs_stats to select_catalog_role;

create or replace view gv_$dnfs_files as
  select * from gv$dnfs_files;
create or replace public synonym gv$dnfs_files for gv_$dnfs_files;
grant select on gv_$dnfs_files to select_catalog_role;

create or replace view v_$dnfs_files as
  select * from v$dnfs_files;
create or replace public synonym v$dnfs_files for v_$dnfs_files;
grant select on v_$dnfs_files to select_catalog_role;

create or replace view gv_$dnfs_servers as
  select * from gv$dnfs_servers;
create or replace public synonym gv$dnfs_servers for gv_$dnfs_servers;
grant select on gv_$dnfs_servers to select_catalog_role;

create or replace view v_$dnfs_servers as
  select * from v$dnfs_servers;
create or replace public synonym v$dnfs_servers for v_$dnfs_servers;
grant select on v_$dnfs_servers to select_catalog_role;

Rem
Rem ASM volume views
Rem

create or replace view gv_$asm_volume as
    select * from gv$asm_volume;
create or replace public synonym gv$asm_volume
    for gv_$asm_volume;
grant select on gv_$asm_volume to select_catalog_role;

create or replace view v_$asm_volume as
    select * from v$asm_volume;
create or replace public synonym v$asm_volume
    for v_$asm_volume;
grant select on v_$asm_volume to select_catalog_role;

create or replace view gv_$asm_volume_stat as
    select * from gv$asm_volume_stat;
create or replace public synonym gv$asm_volume_stat
    for gv_$asm_volume_stat;
grant select on gv_$asm_volume_stat to select_catalog_role;

create or replace view v_$asm_volume_stat as
    select * from v$asm_volume_stat;
create or replace public synonym v$asm_volume_stat
    for v_$asm_volume_stat;
grant select on v_$asm_volume_stat to select_catalog_role;

create or replace view gv_$asm_filesystem as
    select * from gv$asm_filesystem;
create or replace public synonym gv$asm_filesystem
    for gv_$asm_filesystem;
grant select on gv_$asm_filesystem to select_catalog_role;

create or replace view v_$asm_filesystem as
    select * from v$asm_filesystem;
create or replace public synonym v$asm_filesystem
    for v_$asm_filesystem;
grant select on v_$asm_filesystem to select_catalog_role;

create or replace view gv_$asm_acfsvolumes as
    select * from gv$asm_acfsvolumes;
create or replace public synonym gv$asm_acfsvolumes
    for gv_$asm_acfsvolumes;
grant select on gv_$asm_acfsvolumes to select_catalog_role;

create or replace view v_$asm_acfsvolumes as
    select * from v$asm_acfsvolumes;
create or replace public synonym v$asm_acfsvolumes
    for v_$asm_acfsvolumes;
grant select on v_$asm_acfsvolumes to select_catalog_role;

create or replace view gv_$asm_acfssnapshots as
    select * from gv$asm_acfssnapshots;
create or replace public synonym gv$asm_acfssnapshots
    for gv_$asm_acfssnapshots;
grant select on gv_$asm_acfssnapshots to select_catalog_role;

create or replace view v_$asm_acfssnapshots as
    select * from v$asm_acfssnapshots;
create or replace public synonym v$asm_acfssnapshots
    for v_$asm_acfssnapshots;
grant select on v_$asm_acfssnapshots to select_catalog_role;

create or replace view gv_$asm_acfs_security_info as
    select * from gv$asm_acfs_security_info;
create or replace public synonym gv$asm_acfs_security_info
    for gv_$asm_acfs_security_info;
grant select on gv_$asm_acfs_security_info to select_catalog_role;

create or replace view v_$asm_acfs_security_info as
    select * from v$asm_acfs_security_info;
create or replace public synonym v$asm_acfs_security_info
    for v_$asm_acfs_security_info;
grant select on v_$asm_acfs_security_info to select_catalog_role;

create or replace view gv_$asm_acfs_encryption_info as
    select * from gv$asm_acfs_encryption_info;
create or replace public synonym gv$asm_acfs_encryption_info
    for gv_$asm_acfs_encryption_info;
grant select on gv_$asm_acfs_encryption_info to select_catalog_role;

create or replace view v_$asm_acfs_encryption_info as
    select * from v$asm_acfs_encryption_info;
create or replace public synonym v$asm_acfs_encryption_info
    for v_$asm_acfs_encryption_info;
grant select on v_$asm_acfs_encryption_info to select_catalog_role;

create or replace view v_$flashback_txn_mods as 
  select * from v$flashback_txn_mods;
create or replace public synonym v$flashback_txn_mods 
  for v_$flashback_txn_mods;
grant select on v_$flashback_txn_mods to public;

create or replace view v_$flashback_txn_graph as 
  select * from v$flashback_txn_graph;
create or replace public synonym v$flashback_txn_graph
  for v_$flashback_txn_graph;
grant select on v_$flashback_txn_graph to public;     

create or replace view gv_$lobstat as
  select * from gv$lobstat;
create or replace public synonym gv$lobstat for gv_$lobstat;
grant select on gv_$lobstat to select_catalog_role;

create or replace view v_$lobstat as
  select * from v$lobstat;
create or replace public synonym v$lobstat for v_$lobstat;
grant select on v_$lobstat to select_catalog_role;

create or replace view gv_$fs_failover_stats as
  select * from gv$fs_failover_stats;
create or replace public synonym gv$fs_failover_stats 
  for gv_$fs_failover_stats;
grant select on gv_$fs_failover_stats to select_catalog_role;

create or replace view v_$fs_failover_stats as
  select * from v$fs_failover_stats;
create or replace public synonym v$fs_failover_stats for v_$fs_failover_stats;
grant select on v_$fs_failover_stats to select_catalog_role;

create or replace view gv_$asm_disk_iostat as
  select * from gv$asm_disk_iostat;
create or replace public synonym gv$asm_disk_iostat 
  for gv_$asm_disk_iostat;
grant select on gv_$asm_disk_iostat to select_catalog_role;

create or replace view v_$asm_disk_iostat as
  select * from v$asm_disk_iostat;
create or replace public synonym v$asm_disk_iostat for v_$asm_disk_iostat;
grant select on v_$asm_disk_iostat to select_catalog_role;


Rem
Rem DIAG_INFO fixed views
Rem
create or replace view gv_$diag_info as select * from gv$diag_info;
create or replace public synonym gv$diag_info for gv_$diag_info;
grant select on gv_$diag_info to public;

create or replace view v_$diag_info as select * from v$diag_info;
create or replace public synonym v$diag_info for v_$diag_info;
grant select on v_$diag_info to public;

Rem Securefiles fixed views

create or replace view gv_$securefile_timer as
  select * from gv$securefile_timer;
create or replace public synonym gv$securefile_timer
  for gv_$securefile_timer;
grant select on gv_$securefile_timer to select_catalog_role;

create or replace view v_$securefile_timer as
  select * from v$securefile_timer;
create or replace public synonym v$securefile_timer
  for v_$securefile_timer;
grant select on v_$securefile_timer to select_catalog_role;

create or replace view gv_$dnfs_channels as
  select * from gv$dnfs_channels;
create or replace public synonym gv$dnfs_channels 
  for gv_$dnfs_channels;
grant select on gv_$dnfs_channels to select_catalog_role;

create or replace view v_$dnfs_channels as
  select * from v$dnfs_channels;
create or replace public synonym v$dnfs_channels 
  for v_$dnfs_channels;
grant select on v_$dnfs_channels to select_catalog_role;

Rem
Rem DIAG_CRITICAL_ERROR fixed view
Rem
create or replace view v_$diag_critical_error as 
  select * from v$diag_critical_error;
create or replace public synonym v$diag_critical_error
  for v_$diag_critical_error;
grant select on v_$diag_critical_error to public;

create or replace view gv_$cell_state as
  select * from gv$cell_state;
create or replace public synonym gv$cell_state 
  for gv_$cell_state;
grant select on gv_$cell_state to select_catalog_role;

create or replace view v_$cell_state as
  select * from v$cell_state;
create or replace public synonym v$cell_state 
  for v_$cell_state;
grant select on v_$cell_state to select_catalog_role;

create or replace view gv_$cell_thread_history as
  select * from gv$cell_thread_history;
create or replace public synonym gv$cell_thread_history 
  for gv_$cell_thread_history;
grant select on gv_$cell_thread_history to select_catalog_role;

create or replace view v_$cell_thread_history as
  select * from v$cell_thread_history;
create or replace public synonym v$cell_thread_history 
  for v_$cell_thread_history;
grant select on v_$cell_thread_history to select_catalog_role;

create or replace view gv_$cell_ofl_thread_history as
  select * from gv$cell_ofl_thread_history;
create or replace public synonym gv$cell_ofl_thread_history 
  for gv_$cell_ofl_thread_history;
grant select on gv_$cell_ofl_thread_history to select_catalog_role;

create or replace view v_$cell_ofl_thread_history as
  select * from v$cell_ofl_thread_history;
create or replace public synonym v$cell_ofl_thread_history 
  for v_$cell_ofl_thread_history;
grant select on v_$cell_ofl_thread_history to select_catalog_role;

create or replace view gv_$cell_request_totals as
  select * from gv$cell_request_totals;
create or replace public synonym gv$cell_request_totals 
  for gv_$cell_request_totals;
grant select on gv_$cell_request_totals to select_catalog_role;

create or replace view v_$cell_request_totals as
  select * from v$cell_request_totals;
create or replace public synonym v$cell_request_totals 
  for v_$cell_request_totals;
grant select on v_$cell_request_totals to select_catalog_role;

create or replace view gv_$cell as
  select * from gv$cell;
create or replace public synonym gv$cell
  for gv_$cell;
grant select on gv_$cell to select_catalog_role;

create or replace view v_$cell as
  select * from v$cell;
create or replace public synonym v$cell
  for v_$cell;
grant select on v_$cell to select_catalog_role;

create or replace view gv_$cell_config as
  select * from gv$cell_config;
create or replace public synonym gv$cell_config
  for gv_$cell_config;
grant select on gv_$cell_config to select_catalog_role;

create or replace view v_$cell_config as
  select * from v$cell_config;
create or replace public synonym v$cell_config
  for v_$cell_config;
grant select on v_$cell_config to select_catalog_role;

Rem
Rem QMON and persistent queue time manager fixed views
Rem

create or replace view gv_$qmon_coordinator_stats as
    select * from gv$qmon_coordinator_stats;
create or replace public synonym gv$qmon_coordinator_stats
    for gv_$qmon_coordinator_stats;
grant select on gv_$qmon_coordinator_stats to select_catalog_role;

create or replace view v_$qmon_coordinator_stats as
    select * from v$qmon_coordinator_stats;
create or replace public synonym v$qmon_coordinator_stats
    for v_$qmon_coordinator_stats;
grant select on v_$qmon_coordinator_stats to select_catalog_role;


create or replace view gv_$qmon_server_stats as
    select * from gv$qmon_server_stats;
create or replace public synonym gv$qmon_server_stats
    for gv_$qmon_server_stats;
grant select on gv_$qmon_server_stats to select_catalog_role;

create or replace view v_$qmon_server_stats as
    select * from v$qmon_server_stats;
create or replace public synonym v$qmon_server_stats
    for v_$qmon_server_stats;
grant select on v_$qmon_server_stats to select_catalog_role;


create or replace view gv_$qmon_tasks as
    select * from gv$qmon_tasks;
create or replace public synonym gv$qmon_tasks
    for gv_$qmon_tasks;
grant select on gv_$qmon_tasks to select_catalog_role;

create or replace view v_$qmon_tasks as
    select * from v$qmon_tasks;
create or replace public synonym v$qmon_tasks
    for v_$qmon_tasks;
grant select on v_$qmon_tasks to select_catalog_role;


create or replace view gv_$qmon_task_stats as
    select * from gv$qmon_task_stats;
create or replace public synonym gv$qmon_task_stats
    for gv_$qmon_task_stats;
grant select on gv_$qmon_task_stats to select_catalog_role;

create or replace view v_$qmon_task_stats as
    select * from v$qmon_task_stats;
create or replace public synonym v$qmon_task_stats
    for v_$qmon_task_stats;
grant select on v_$qmon_task_stats to select_catalog_role;


create or replace view gv_$persistent_qmn_cache as
    select * from gv$persistent_qmn_cache;
create or replace public synonym gv$persistent_qmn_cache
    for gv_$persistent_qmn_cache;
grant select on gv_$persistent_qmn_cache to select_catalog_role;

create or replace view v_$persistent_qmn_cache as
    select * from v$persistent_qmn_cache;
create or replace public synonym v$persistent_qmn_cache
    for v_$persistent_qmn_cache;
grant select on v_$persistent_qmn_cache to select_catalog_role;

create or replace view gv_$object_dml_frequencies as
    select * from gv$object_dml_frequencies;
create or replace public synonym gv$object_dml_frequencies
    for gv_$object_dml_frequencies;
grant select on gv_$object_dml_frequencies to select_catalog_role;

create or replace view v_$object_dml_frequencies as
    select * from v$object_dml_frequencies;
create or replace public synonym v$object_dml_frequencies
    for v_$object_dml_frequencies;
grant select on v_$object_dml_frequencies to select_catalog_role;

Rem
Rem LISTENER_NETWORK fixed views
Rem
create or replace view gv_$listener_network as
    select * from gv$listener_network;
create or replace public synonym gv$listener_network
    for gv_$listener_network;
grant select on gv_$listener_network to select_catalog_role;

create or replace view v_$listener_network as
    select * from v$listener_network;
create or replace public synonym v$listener_network
    for v_$listener_network;
grant select on v_$listener_network to select_catalog_role;


Rem
Rem SQLCOMMAND fixed views
Rem
create or replace view gv_$sqlcommand as
    select * from gv$sqlcommand;
create or replace public synonym gv$sqlcommand 
    for gv_$sqlcommand;
grant select on gv_$sqlcommand to select_catalog_role;

create or replace view v_$sqlcommand as
    select * from v$sqlcommand;
create or replace public synonym v$sqlcommand
    for v_$sqlcommand;
grant select on v_$sqlcommand to select_catalog_role;

Rem
Rem TOPLEVELCALL fixed views
Rem

create or replace view gv_$toplevelcall as
    select * from gv$toplevelcall;
create or replace public synonym gv$toplevelcall
    for gv_$toplevelcall;
grant select on gv_$toplevelcall to select_catalog_role;

create or replace view v_$toplevelcall as
    select * from v$toplevelcall;
create or replace public synonym v$toplevelcall
    for v_$toplevelcall;
grant select on v_$toplevelcall to select_catalog_role;

Rem
Rem Hang Manager fixed views
Rem

create or replace view v_$hang_info as
  select * from v$hang_info;
create or replace public synonym v$hang_info for v_$hang_info;
grant select on v_$hang_info to select_catalog_role;

create or replace view v_$hang_session_info as
  select * from v$hang_session_info;
create or replace public synonym v$hang_session_info for v_$hang_session_info;
grant select on v_$hang_session_info to select_catalog_role;

Rem
Rem Hang Manager hang statistics fixed views
Rem 

create or replace view v_$hang_statistics as
    select * from v$hang_statistics;
create or replace public synonym v$hang_statistics for v_$hang_statistics;
grant select on v_$hang_statistics to select_catalog_role;
    
create or replace view gv_$hang_statistics as
    select * from gv$hang_statistics;
create or replace public synonym gv$hang_statistics for gv_$hang_statistics;
grant select on gv_$hang_statistics to select_catalog_role;

Rem
Rem Fast space usage views.
Rem

create or replace view v_$segspace_usage as select * from v$segspace_usage;
create or replace public synonym v$segspace_usage for v_$segspace_usage;
grant select on v_$segspace_usage to SELECT_CATALOG_ROLE;

create or replace view gv_$segspace_usage as select * from gv$segspace_usage;
create or replace public synonym gv$segspace_usage for gv_$segspace_usage;
grant select on gv_$segspace_usage to SELECT_CATALOG_ROLE;

Rem
Rem [G]V$DEAD_CLEANUP fixed views
Rem
create or replace view v_$dead_cleanup as
    select * from v$dead_cleanup;
create or replace public synonym v$dead_cleanup
    for v_$dead_cleanup;
grant select on v_$dead_cleanup to select_catalog_role;

create or replace view gv_$dead_cleanup as
    select * from gv$dead_cleanup;
create or replace public synonym gv$dead_cleanup
    for gv_$dead_cleanup;
grant select on gv_$dead_cleanup to select_catalog_role;

Rem
Rem [G]V$CLONEDFILE fixed views
Rem
create or replace view v_$clonedfile as select * from v$clonedfile;
create or replace public synonym v$clonedfile for v_$clonedfile;
grant select on v_$clonedfile to select_catalog_role;

create or replace view gv_$clonedfile as
  select * from gv$clonedfile;
create or replace public synonym gv$clonedfile for gv_$clonedfile;
grant select on gv_$clonedfile to select_catalog_role;

Rem
Rem GV$AUTO_BMR_STATISTICS fixed views
Rem
create or replace view gv_$auto_bmr_statistics as 
    select * from gv$auto_bmr_statistics;
create or replace public synonym gv$auto_bmr_statistics 
    for gv_$auto_bmr_statistics;
grant select on gv_$auto_bmr_statistics to select_catalog_role;

Rem
Rem [G]V$CHANNEL_WAITS fixed views
Rem
create or replace view v_$channel_waits as
    select * from v$channel_waits;
create or replace public synonym v$channel_waits
    for v_$channel_waits;
grant select on v_$channel_waits to select_catalog_role;

create or replace view gv_$channel_waits as
    select * from gv$channel_waits;
create or replace public synonym gv$channel_waits
    for gv_$channel_waits;
grant select on gv_$channel_waits to select_catalog_role;

Rem
Rem [G]V$FS_OBSERVER_HISTOGRAM fixed views
Rem
create or replace view gv_$fs_observer_histogram as
    select * from gv$fs_observer_histogram;
create or replace public synonym gv$fs_observer_histogram
    for gv_$fs_observer_histogram;
grant select on gv_$fs_observer_histogram to select_catalog_role;

create or replace view v_$fs_observer_histogram as
    select * from v$fs_observer_histogram;
create or replace public synonym v$fs_observer_histogram
    for v_$fs_observer_histogram;
grant select on v_$fs_observer_histogram to select_catalog_role;
