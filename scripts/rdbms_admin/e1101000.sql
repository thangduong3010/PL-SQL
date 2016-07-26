Rem $Header: rdbms/admin/e1101000.sql /st_rdbms_11.2.0/1 2013/03/05 09:31:13 cdilling Exp $
Rem
Rem e1101000.sql
Rem
Rem Copyright (c) 2005, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      e1101000.sql - downgrade Oracle RDBMS to the 11.1.0 release
Rem
Rem      **DO NOT ADD DOWNGRADE ACTIONS THAT CALL PL/SQL PACKAGES HERE
Rem      **THOSE ACTIONS NOW BELONG IN f1101000.sql.
Rem
Rem    DESCRIPTION
Rem
Rem      This scripts is run from catdwgrd.sql and e1002000.sql 
Rem      to perform any dictionary actions to downgrade to 11.1.0
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       cdilling 03/02/13 - clear any obj$.flags to handle ub4 back to ub2
Rem       dsirmuka 04/29/10 - #8865038.Drop dbms_xds, dbms_xdsutl
Rem       mfallen  11/16/09 - bug 5842726: move drpadrvw.sql to e1102000.sql
Rem       pbelknap 09/28/09 - preserve wri$_adv_usage for 10.2.0.5 case
Rem       abrown   08/31/09 - downgrade for tianli_bug-8733323
Rem       cdilling 08/03/09 - invoke patch downgrade script
Rem       weizhang 07/16/09 - bug 8689239: segadv property change
Rem       adng     07/06/09 - add stats for Exadata
Rem       jklein   07/13/09 - downgrade for sql check
Rem       baleti   07/06/09 - split SF tracking into user and system categories
Rem       pbelknap 06/23/09 - #8618452: db feature usg for sql monitor,
Rem                           reporting
Rem       amullick 06/15/09 - Consolidate archive provider/manager into
Rem                           DBFS HS: remove archive manager entities
Rem       cchui    06/21/09 - drop database vault feature tracking procedure
Rem       baleti   06/22/09 - drop feature tracking procedure for securefiles
Rem       molagapp 06/03/09 - drop recovery_area_usage view
Rem       suelee   06/05/09 - Drop dbms_feature_resource_manager procedure
Rem       fsanchez 06/05/09 - change compression name DEFAULT -> BASIC
Rem       weizhang 06/02/09 - bug 7026782: drop dbms_feature_segadv_user
Rem       kkunchit 05/27/09 - no downgrade actions for content-api
Rem       adalee   05/27/09 - drop file_optimized_histogram views
Rem       vmarwah  05/15/09 - Drop Hybrid Columnar Compression feature tracking
Rem                           procedure
Rem       svivian  04/29/09 - drop dba_logstdby_eds_supported view
Rem       gagarg   04/29/09 - Bug 8450499: drop dbms_aqadm_inv  package.
Rem       qyu      04/23/09 - reverse yi's change
Rem       mchainan 04/09/09 - drop v$session_blockers and gv$session_blockers
Rem       juyuan   04/15/09 - drop v$streams_pool_statistics
Rem       gravipat 04/22/09 - Drop new fixed views v$ and gv$libcache_locks
Rem       shbose   04/10/09 - bug 7530052: drop view ALL_INT_DEQUEUE_QUEUES
Rem       fsanchez 04/06/09 - bug 8411943
Rem       juyuan   03/20/09 - drop package dbms_streams_mc
Rem       mthiyaga 04/13/09 - Fix bug 8348017
Rem       fsanchez 04/06/09 - bug 8411943
Rem       dvoss    04/10/09 - remove new logstdby$skip indexes
Rem       rmao     04/08/09 - bug8418598: rename get_instance_number to
Rem                           get_thread_number
Rem       jkundu   04/06/09 - need to drop logmnr_gt_xid_include
Rem       ssahu    03/31/09 - Drop synonyms v$ and gv$cpool_conn_info
Rem       yifeng   03/29/09 - drop xmlQuery and xmlExists for XMLTYPE
Rem       svivian  03/25/09 - deal with new LOGSTDBY EDS objects
Rem       shbose   03/24/09 - change [g]v$persistent_tm_cache to
Rem                           [g]v$persistent_qmn_cache
Rem       mbastawa 03/20/09 - drop client result cache package
Rem       rcolle   03/10/09 - clear divergence_details_status in wrr$_replays
Rem       spapadom 03/20/09 - drop as_replay package
Rem       sarchak  03/18/09 - Bug 7829203,default_pwd$ should not be recreated
Rem       slynn    03/16/09 - Drop dbms_lob_am_private package.
Rem       hosu     03/24/09 - remove unique constraints for synopsis related
Rem                           dictionary tables
Rem       dsemler  03/10/09 - drop the public synonym for WLM_CLASSIFIER_PLAN
Rem       jdhunter 03/04/09 - delete OLAP API callback from expdepact$, 
Rem                           exppkgact$
Rem       spapadom 02/28/09 - add support for ECIDs
Rem       amullick 02/27/09 - bug8291480: add/ remove drop of objects for 
Rem                           Archive Provider
Rem       rramkiss 02/26/09 - drop new scheduler views
Rem       arbalakr 02/24/09 - drop DBA_HIST_SQLCOMMAND_NAME/TOPLEVELCALL
Rem       arbalakr 02/23/09 - bug 7350685: drop v$sqlcommandtype/toplevelcall
Rem       skabraha 02/19/09 - bug #7446912: anytype.getinfo parameter change
Rem       jheng    02/17/09 - remove the run_invoker column
Rem       rmao     02/17/09 - drop streams$_propagation_process.seqnum and
Rem                           streams$_propagation_seqnum sequence
Rem       jomcdon  02/03/09 - add max_utilization_limit
Rem       elu      02/03/09 - update apply spill
Rem       ssvemuri 09/26/08 - CQN related downgrades
Rem       wwchan   02/16/09 - remove caching to ora_tq_case during downgrade
Rem       geadon   02/09/09 - bug 7654925: update tab$ trigflag for BJI /
Rem                           ref-ptn tables
Rem       dvoss    02/05/09 - logstdby$events.event_time not null
Rem       rcolle   02/04/09 - clear table from OBJID replay sync
Rem       elu      02/03/09 - update apply spill
Rem       dgagne   02/02/09 - add drop of ku_list_filter_temp tables
Rem       bdagevil 02/12/09 - drop fixed views gv$ash_info
Rem       rcolle   01/29/09 - clear tables for replay filters
Rem       amullick 01/22/09 - archive provider drop actions
Rem       kkunchit 01/22/09 - content-api drop/downgrade actions
Rem       pbelknap 12/09/08 - add pack/unpack sqlset id temp table
Rem       swshekha 01/16/09 - drop new view All_transformations
Rem       hayu     12/25/08 - update _sqltune_control value
Rem       pbelknap 12/09/08 - add pack/unpack sqlset id temp table
Rem       hongyang 01/08/09 - drop gv$dataguard_stats
Rem       ethibaul 01/08/09 - Remove ofs views
Rem       absaxena 08/19/08 - drop dbms_aq_exp_dequeuelog_tables package
Rem       liding   01/02/09 - downgrade MVs for lrg3745491
Rem       jinwu    12/29/08 - undo changes for stmt handler
Rem       sidatta  12/23/08 - Adding public synonyms for v$cell_config and
Rem                           gv$cell_config
Rem       praghuna 12/22/08 - Drop get_row_text and get_where_clause
Rem       rmao     12/19/08 - remove dba_streams_split_merge_hist and
Rem                           dba_recoverable_script_hist views
Rem       rsamuels 12/18/08 - OLAP API null out new columns & undo renamings
Rem       rsamuels 12/18/08 - truncate olap_multi_options$
Rem       dgagne   12/16/08 - remove sys.ku_refpar_level view
Rem       weizhang 12/12/08 - downgrade DBA_TABLESPACE_USAGE_METRICS
Rem       swshekha 12/10/08 - Drop new view all_queue_schedules
Rem       matfarre 12/09/08 - bug 7596712: drop session actions table
Rem       thoang   12/05/08 - set apply$_error.xid columns to null 
Rem       pbelknap 11/19/08 - add V$SQLPA_METRIC
Rem       jinwu    11/18/08 - undo changes for stmt handler
Rem       dvoss    11/17/08 - bug 7480265, restore logminer sequence setttings
Rem       tianli   11/10/08 - add edition methods
Rem       ilistvin 11/07/08 - drop DBA_TABLESPACE_THRESHOLDS view
Rem       ilistvin 10/23/08 - Drop DBA_HIST_PLAN* views
Rem       sjanardh 10/20/08 - Drop new index aq$_subscriber_table_i
Rem       gssmith  10/15/08 - Upgrade Access Advisor for lrg 3651498
Rem       ssonawan 10/11/08 - Bug 7295457: Remove audit options from 
Rem                           stmt_audit_option_map
Rem       yujwang  10/03/08 - reset column scale_up_multiplier at wrr$_replays
Rem       rgmani   04/15/08 - Scheduler file watching related actions
Rem       elu      04/11/08 - add LCR methods
Rem       rramkiss 04/08/08 - downgrade 11.2 scheduler job email notifications
Rem       ssonawan 07/08/08 - bug 5921164: set powner# column of fga$ to NULL 
Rem       rihuang  09/29/08 - Add removal of view DBA_STREAMS_KEEP_COLUMNS
Rem       rlong    09/25/08 - 
Rem       nkgopal  09/17/08 - Bug 6856975: Remove ALL STATEMENTS from 
Rem                           STMT_AUDIT_OPTION_MAP
Rem       fsanchez 09/16/08 - bug-6623413
Rem       sburanaw 09/16/08 - Truncate WRR$_REPLAY_DATA
Rem       apsrivas 09/11/08 - BUG 7294185 - avoid duplicate entries in OBJ$
Rem                           when dblink is up
Rem       rcolle   09/11/08 - remove column to DB replay schema for PAUSE
Rem                           support
Rem       schitti  09/09/08 - Table name changes for DBMA_AM
Rem       amullick 09/08/08 - drop packages and views for Archive Manager
Rem       rmao     09/05/08 - undo changes to comparison_scan$
Rem       hayu     09/01/08 - update _sqltune_control value
Rem       lgalanis 08/28/08 - downgrade for sequence exceptions for replay
Rem       rcolle   08/28/08 - drop columns and tables for DB replay
Rem                           populate_diveregence
Rem       jgalanes 08/26/08 - Drop new LOGMNRC_GSBA table on downgrade
Rem       rcolle   08/12/08 - truncate tables WRR$_*_UC_HRAPH
Rem       rmao     08/11/08 - 
Rem       rlong    08/07/08 - 
Rem       jgiloni  08/06/08 - Drop LISTENER_NETWORK views
Rem       praghuna 08/03/08 - drop get_row_text of lcr$_row_record
Rem       alui     07/31/08 - drop additional objects in APPQOSSYS schema
Rem       nkgopal  07/23/08 - Bug 6830207: Delete ALTER DATABASE LINK and ALTER
Rem                           PUBLIC DATABASE LINK from  SYSTEM_PRIVILEGE_MAP 
Rem                           and STMT_AUDIT_OPTION_MAP
Rem       elu      07/22/08 - lcr pos
Rem       ssonawan 07/08/08 - bug 5921164: set powner# column of fga$ to NULL 
Rem       liaguo   07/29/08 - drop dbms_flashback_archive
Rem       josmith  07/28/08 - Add ACFS views to replace the OFS views
Rem       nchoudhu 07/25/08 - 
Rem       rmao     07/22/08 - remove unschedule_time from
Rem                           streams$_propagation_process
Rem       cchiappa 07/21/08 - 
Rem       nchoudhu 07/14/08 - XbranchMerge nchoudhu_sage_july_merge117 from
Rem                           st_rdbms_11.1.0
Rem       sugpande 07/14/08 - Rename v$cell_name to v$cell
Rem       vliang   07/07/08 - 
Rem       huagli   07/03/08 - truncate DST patching pre-defined tables
Rem       legao    07/02/08 - modify get_instance_number return type
Rem       akociube 07/02/08 - Drop olap log package
Rem       mjgreave 06/10/08 - remove OUTLINE from STMT_AUDIT_OPTION_MAP #6845085
Rem       rdongmin 06/10/08 - lrg 3408532: delete plandiff objects
Rem       elu      06/03/08 - drop xstream views
Rem       mfallen  05/18/08 - drop/truncate wrh$_dyn_remaster_stats
Rem       kchen    05/09/08 - drop hs_admin_select_role and
Rem                           hs_admin_execute_role
Rem       msakayed 05/01/08 - compression/encryption feature tracking for 11.2
Rem       jcarey   05/01/08 - Add olap rename trigger
Rem       nchoudhu 04/30/08 - rename oss views
Rem       haxu     04/29/08 - drop error_date, error_msg from 
Rem                           streams$_propagation_process
Rem       vkolla   04/25/08 - drop [g]v$iostat_function_detail
Rem       amitsha  04/25/08 - drop type for compression advisor
Rem       akini    04/23/08 - downgrade awr table wrh$_iostat_detail
Rem       akini    04/23/08 - downgrade awr table wrh$_iostat_function_detail
Rem       schitti  04/22/08 - DBMS_AM cleanup
Rem       jgiloni  04/17/08 - Drop shared server AWR tables and views
Rem       elu      04/11/08 - add LCR methods
Rem       rdongmin 04/09/08 - drop wri$_rept_plan_diff
Rem       rdongmin 04/09/08 - drop wri$_rept_plan_diff
Rem       lbarton  04/21/08 - add dbms_metadata_diff
Rem       jgiloni  04/17/08 - Drop shared server AWR tables and views
Rem       rmao     04/17/08 - drop _dba_streams_unsupported_11_2 and
Rem                           _dba_streams_newly_supted_11_2
Rem       ssamaran 04/11/08 - add downgrade for bzip feature tracking
Rem       elu      04/11/08 - add LCR methods
Rem       rdongmin 04/09/08 - drop wri$_rept_plan_diff
Rem       huagli   01/08/08 - drop views and package for DST patching
Rem       nkgopal  04/10/08 - Bug 6954407: Rename DBMS_AUDIT_MGMT_* views to
Rem                           DBA_AUDIT_MGMT_* views
Rem       rdongmin 04/09/08 - drop wri$_rept_plan_diff
Rem       rmao     04/06/08 - drop dbms_streams_auto_int package
Rem       asohi    03/31/08 - Drop STATE column from sys.reg$ table
Rem       huagli   01/08/08 - drop views and package for DST patching
Rem       vmarwah  03/31/08 - Archive Compression: truncate compression$
Rem       schitti  03/27/08 - Downgrade for AM
Rem       nkgopal  03/27/08 - Bug 6810355: Dont drop PLHOL column
Rem                           Check where AUD$ exists to add back I_AUD1
Rem       dsemler  03/26/08 - drop additional objects in APPQOSSYS schema
Rem       tbhosle  03/19/08 - drop v$emon views
Rem       thoang   03/19/08 - drop get_instance_number from lcr types. 
Rem       jklein   03/19/08 - drop adr views
Rem       rmao     03/18/08 - drop streams$_capture_server table
Rem       jiashi   03/16/08 - remove v$standby_event_histogram 
Rem       mjaiswal 03/13/08 - downgrade changes for (G)V$ qmon views
Rem       yujwang  03/13/08 - set CALL_TIME to zero at WRR$_REPLAY_SCN_ORDER 
Rem       tchorma  03/12/08 - Drop new logstdby 11.2 views upon downgrade
Rem       achoi    03/04/08 - remove DBMS_PARALLEL_EXECUTE pkg
Rem       geadon   03/04/08 - bug 5373923: TRANSIENT_IOT$
Rem       elu      03/03/08 - modify apply spill tables
Rem       thoang   02/29/08 - Truncate xstream tables 
Rem       rmao     02/20/08 - drop streams$_split_merge table
Rem       bvaranas 02/13/08 - Project 25274: Deferred Segment Creation.
Rem                           Truncate deferred_stg$
Rem       dsemler  01/14/08 - Remove the QOS (wlm) support on downgrade
Rem       pbagal   12/13/07 - Add 11.2 views from e1002..
Rem       amysoren 10/12/07 - add wlm stat and metric views
Rem       adalee   09/27/07 - Drop dbms_cacheutil package
Rem       bmccarth 03/06/08 - datapump_dir_objs
Rem       nmacnaug 02/19/08 - remove policy_history
Rem       ilistvin 02/14/08 - drop dbms_awr_report_layout package
Rem       akini    02/13/08 - downgrade IPv6 addresses in AWR
Rem       sburanaw 02/05/08 - remove update to null on AWR tables
Rem       rgmani   01/24/08 - Drop scheduler type
Rem       nkgopal  01/28/08 - lrg 3282232: drop index in PL/SQL
Rem       nkgopal  01/12/08 - Downgrade DBMS_AUDIT_MGMT changes
Rem       bdagevil 12/18/07 - drop [g]v$sqlstats_plan_hash synonyms
Rem       srtata   01/15/08 - create xs$session_hws table
Rem       sburanaw 12/12/07 - remove blocking_inst_id, ecid to ASH
Rem       zqiu     12/12/07 - remove secondary CUBE MV pct metadata
Rem       rburns   12/07/07 - add SDO downgrade
Rem       sugpande 12/05/07 - Add downgrade of sagecell views
Rem       atsukerm 09/25/07 - add downgrade of OSS views
Rem       yujwang  12/06/07 - add schema change for Database Replay
Rem       snadhika 10/16/07 - Drop index on sessions table
Rem       gagarg   10/16/07 - Bug 6488226:  Drop attribute RULE_NAME in
Rem                           AQ$_subscriber type on downgrade
Rem       mjaiswal 10/03/07 - downgrade changes for xs$parameters
Rem       sylin    09/24/07 - drop package utl_ident
Rem       averhuls 08/22/06 - drop {g}v$asm_volume, {g}v$asm_volume_stat,
Rem                           {g}v$asm_filesystem, {g}v$asm_ofsvolumes 
Rem       rburns   08/22/07 - 11g downgrade
Rem       cdilling 08/06/07 - Add support for patch set downgrades
Rem       hqian    07/25/07 - Add (g)v_$asm_user* downgrade
Rem *************************************************************************
Rem BEGIN e1101000.sql
Rem *************************************************************************

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release
Rem =========================================================================

@@e1102000.sql

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release
Rem =========================================================================


Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary from current release to 11.1.0
Rem =========================================================================

drop view V_$DIAG_CRITICAL_ERROR;
drop public synonym V$DIAG_CRITICAL_ERROR;

drop package utl_ident;
drop public synonym utl_ident;

Rem Remove session_blockers
drop public synonym v$session_blockers;
drop view v_$session_blockers;
drop public synonym gv$session_blockers;
drop view gv_$session_blockers;

Rem Remove ASM volume views
drop public synonym v$asm_volume;
drop view v_$asm_volume;
drop public synonym gv$asm_volume;
drop view gv_$asm_volume;

drop public synonym v$asm_volume_stat;
drop view v_$asm_volume_stat;
drop public synonym gv$asm_volume_stat;
drop view gv_$asm_volume_stat;

drop public synonym v$asm_filesystem;
drop view v_$asm_filesystem;
drop public synonym gv$asm_filesystem;
drop view gv_$asm_filesystem;

drop public synonym v$asm_acfsvolumes;
drop view v_$asm_acfsvolumes;
drop public synonym gv$acfsvolumes;
drop view gv_$asm_acfsvolumes;

drop public synonym v$asm_acfssnapshots;
drop view v_$asm_acfssnapshots;
drop public synonym gv$acfssnapshots;
drop view gv_$asm_acfssnapshots;

drop public synonym v$wlm_pcmetric;
drop view v_$wlm_pcmetric;
drop public synonym gv$wlm_pcmetric;
drop view gv_$wlm_pcmetric;
drop public synonym v$wlm_pcmetric_history;
drop view v_$wlm_pcmetric_history;
drop public synonym gv$wlm_pcmetric_history;
drop view gv_$wlm_pcmetric_history;

Rem Remove gv$dataguard_stats
drop public synonym gv$dataguard_stats;
drop view gv_$dataguard_stats;

Rem Remove the WLM user and its table
Rem Drop table required due to package dependencies
drop table appqossys.wlm_classifier_plan;
drop table appqossys.wlm_metrics_stream;
drop public synonym wlm_metrics_stream;
drop public synonym wlm_classifier_plan;
drop synonym appqossys.dbms_wlm;
drop user appqossys;

Rem Remove AWR stat views
drop public synonym v$wlm_pc_stats;
drop view v_$wlm_pc_stats;
drop public synonym gv$wlm_pc_stats;
drop view gv_$wlm_pc_stats;

Rem Note that the (g)v_$asm_user* view drops will be moved to
Rem e1101000.sql once it's created.
drop public synonym v$asm_user;
drop view v_$asm_user;
drop public synonym gv$asm_user;
drop view gv_$asm_user;
drop public synonym v$asm_usergroup;
drop view v_$asm_usergroup;
drop public synonym gv$asm_usergroup;
drop view gv_$asm_usergroup;
drop public synonym v$asm_usergroup_member;
drop view v_$asm_usergroup_member;
drop public synonym gv$asm_usergroup_member;
drop view gv_$asm_usergroup_member;

drop public synonym v$sqlstats_plan_hash;
drop view v_$sqlstats_plan_hash;
drop public synonym gv$sqlstats_plan_hash;
drop view gv_$sqlstats_plan_hash;
drop public synonym gv$sqlarea_plan_hash;
drop view gv_$sqlarea_plan_hash;

drop public synonym v$standby_event_histogram;
drop view v_$standby_event_histogram;

Rem Remove iostat_function_detail views
drop public synonym v$iostat_function_detail;
drop view v_$iostat_function_detail;
drop public synonym gv$iostat_function_detail;
drop view gv_$iostat_function_detail;

Rem Misc Cache Utilities
drop package dbms_cacheutil;
drop PUBLIC SYNONYM dbms_cacheutil; 

Rem Remove Logstdby Support/Unsupport Views
drop view logstdby_support_tab_11_2;
drop view logstdby_unsupport_tab_11_2;

Rem
Rem Remove logstdby EDS related changes
Rem
DROP PUBLIC SYNONYM dba_logstdby_eds_tables;
DROP VIEW sys.dba_logstdby_eds_tables;
TRUNCATE TABLE system.logstdby$eds_tables;
DROP PACKAGE sys.logstdby_internal;
DROP PUBLIC SYNONYM dba_logstdby_eds_supported;
DROP VIEW sys.dba_logstdby_eds_supported;

Rem 
Rem  Datapump (catdpb.sql) additions for 11.2
Rem
DROP PUBLIC SYNONYM DATAPUMP_DIR_OBJS;
DROP VIEW SYS.DATAPUMP_DIR_OBJS;
DROP TABLE SYS.KU$_LIST_FILTER_TEMP;
DROP TABLE SYS.KU$_LIST_FILTER_TEMP_2;

Rem
Rem  Datapump (prvthpw.sql) additions for 11.2
Rem
DROP VIEW sys.ku$_refpar_level;

Rem Remove dbms_metadata_diff
drop package dbms_metadata_diff;
drop public synonym dbms_metadata_diff;

Rem =======================================================================
Rem  Begin Changes for AWR
Rem =======================================================================

Rem
Rem store message in place of IPv6 address
Rem
update WRH$_CLUSTER_INTERCON 
set ip_address = ' ' 
where length(ip_address) > 16;

update WRH$_IC_DEVICE_STATS
set ip_addr = ' ' 
where length(ip_addr) > 16;

update WRH$_SQLSTAT
set cell_uncompressed_bytes_total = 0; 

update WRH$_SQLSTAT
set cell_uncompressed_bytes_delta = 0; 

update WRH$_SQLSTAT
set io_offload_return_bytes_total = 0; 

update WRH$_SQLSTAT
set io_offload_return_bytes_delta = 0; 

Rem
Rem WRH$_DISPATCHER changes
Rem
drop view DBA_HIST_DISPATCHER;
drop public synonym DBA_HIST_DISPATCHER;
truncate table WRH$_DISPATCHER;

Rem
Rem WRH$_SHARED_SERVER_SUMMARY changes
Rem
drop view DBA_HIST_SHARED_SERVER_SUMMARY;
drop public synonym DBA_HIST_SHARED_SERVER_SUMMARY;
truncate table WRH$_SHARED_SERVER_SUMMARY;

Rem
Rem downgrade actions for new awr i/o table and corresponding view
Rem
drop view DBA_HIST_IOSTAT_DETAIL;
drop PUBLIC SYNONYM DBA_HIST_IOSTAT_DETAIL;
truncate table WRH$_IOSTAT_DETAIL;

Rem
Rem WRH$_DYN_REMASTER_STATS changes
Rem
drop view DBA_HIST_DYN_REMASTER_STATS ;
drop public synonym DBA_HIST_DYN_REMASTER_STATS;
truncate table WRH$_DYN_REMASTER_STATS;

Rem 
Rem WRH$_PLAN_OPERATION_NAME changes
Rem
drop view DBA_HIST_PLAN_OPERATION_NAME;
drop public synonym DBA_HIST_PLAN_OPERATION_NAME;
truncate table WRH$_PLAN_OPERATION_NAME;

Rem 
Rem WRH$_PLAN_OPTION_NAME changes
Rem
drop view DBA_HIST_PLAN_OPTION_NAME;
drop public synonym DBA_HIST_PLAN_OPTION_NAME;
truncate table WRH$_PLAN_OPTION_NAME;

Rem
Rem WRH$_SQLCOMMAND_NAME changes
Rem
drop view DBA_HIST_SQLCOMMAND_NAME;
drop public synonym DBA_HIST_SQLCOMMAND_NAME;
truncate table WRH$_SQLCOMMAND_NAME;

Rem
Rem WRH$_TOPLEVELCALL changes
Rem
drop view DBA_HIST_TOPLEVELCALL_NAME;
drop public synonym DBA_HIST_TOPLEVELCALL_NAME;
truncate table WRH$_TOPLEVELCALL_NAME;


Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==          (11gR1 = SWRF Version 3)                 ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  downgrade changes.  Place all other AWR          ==
Rem ==  downgrade changes above this.                    ==
Rem =======================================================

BEGIN
  UPDATE wrm$_wr_control SET swrf_version = 3;
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -942) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/



Rem =======================================================================
Rem  End Changes for AWR
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Database Replay
Rem =======================================================================

Rem WRR Tables and Sequences
Rem ========================

Rem
Rem Set COLUMN call_time to zero at SCN_ORDER table
Rem
update WRR$_REPLAY_SCN_ORDER set call_time=0;

Rem
Rem Set columns sql_phase and sql_exec_call_ctr to NULL in
Rem WRR$_REPLAY_DIVERGENCE
Rem
update WRR$_REPLAY_DIVERGENCE set sql_phase = NULL, sql_exec_call_ctr = NULL;

Rem
Rem Clear tables WRR$_REPLAY_SQL_TEXT and WRR$_REPLAY_SQL_BINDS
Rem
truncate table WRR$_REPLAY_SQL_TEXT;
truncate table WRR$_REPLAY_SQL_BINDS;

Rem
Rem Truncate tables WRR$_CAPTURE_UC_GRAPH and WRR$_REPLAY_UC_GRAPH
Rem 
truncate table WRR$_CAPTURE_UC_GRAPH;
truncate table WRR$_REPLAY_UC_GRAPH;

Rem
Rem Drop WRR$_SEQUENCE_EXCEPTIONS for downgrade
Rem
truncate table WRR$_SEQUENCE_EXCEPTIONS;

Rem 
Rem Set column time_paused to NULL for downgrade
Rem
update WRR$_REPLAY_STATS set time_paused = NULL;

Rem
Rem Clear tables WRR$_REPLAY_DATA
Rem
truncate table WRR$_REPLAY_DATA;

Rem
Rem Set COLUMN scale_up_multiplier to one at WRR$_REPLAYS table
Rem
update WRR$_REPLAYS set scale_up_multiplier=1;

Rem
Rem Clear tables for replay filters
Rem
truncate table WRR$_REPLAY_CALL_FILTER;
truncate table WRR$_REPLAY_FILTER_SET;

Rem
Rem Clear tables for replay OBJID sync
Rem
truncate table WRR$_REPLAY_DEP_GRAPH;
truncate table WRR$_REPLAY_COMMITS;
truncate table WRR$_REPLAY_REFERENCES;

Rem
Rem Set column divergence_details_status to NULL for downgrade
Rem
update WRR$_REPLAYS set divergence_details_status = NULL;

Rem
Rem Set COLUMN replay_type to null 
Rem
update WRR$_REPLAYS set replay_type = NULL; 

Rem
Rem Set columns ecid, ecid_hash to null
Rem
update WRR$_REPLAY_SCN_ORDER set ecid = NULL, ecid_hash = NULL; 

Rem WRR Packages and Libraries
Rem ==========================

drop package as_replay;

Rem =======================================================================
Rem  End Changes for Database Replay
Rem =======================================================================

Rem =================
Rem  Begin AQ changes
Rem =================

-- Bug fix of 6488226
ALTER TYPE sys.aq$_subscriber
  DROP ATTRIBUTE (rule_name) CASCADE
/

drop public synonym gv$qmon_coordinator_stats;
drop view gv_$qmon_coordinator_stats;
drop public synonym v$qmon_coordinator_stats;
drop view v_$qmon_coordinator_stats;

drop public synonym gv$qmon_server_stats;
drop view gv_$qmon_server_stats;
drop public synonym v$qmon_server_stats;
drop view v_$qmon_server_stats;

drop public synonym gv$qmon_tasks;
drop view gv_$qmon_tasks;
drop public synonym v$qmon_tasks;
drop view v_$qmon_tasks;

drop public synonym gv$qmon_task_stats;
drop view gv_$qmon_task_stats;
drop public synonym v$qmon_task_stats;
drop view v_$qmon_task_stats;

drop public synonym gv$persistent_qmn_cache;
drop view gv_$persistent_qmn_cache;
drop public synonym v$persistent_qmn_cache;
drop view v_$persistent_qmn_cache;


Rem
Rem Drop STATE column from sys.REG$ table
Rem
alter table sys.REG$ drop column state;

DROP VIEW v_$emon;
DROP PUBLIC synonym v$emon;
DROP VIEW gv_$emon;
DROP PUBLIC synonym gv$emon;

DROP INDEX sys.aq$_subscriber_table_i 
/
ALTER TABLE AQ$_SUBSCRIBER_TABLE DROP (scn_at_add)
/
ALTER TABLE AQ$_SUBSCRIBER_TABLE DROP (client_session_guid)
/
ALTER TABLE AQ$_SUBSCRIBER_TABLE DROP (instance_id)
/
DROP CONTEXT global_aqclntdb_ctx 
/
DROP SEQUENCE sys.aq$_nondursub_sequence
/

DROP PUBLIC synonym ALL_QUEUE_SCHEDULES;
DROP VIEW ALL_QUEUE_SCHEDULES;
DROP VIEW "_ALL_QUEUE_SCHEDULES";
/

DROP PUBLIC synonym ALL_INT_DEQUEUE_QUEUES;
DROP VIEW ALL_INT_DEQUEUE_QUEUES;

-- drop package for exporting dequeue log tables
drop public synonym dbms_aq_exp_dequeuelog_tables;
drop package dbms_aq_exp_dequeuelog_tables;

-- Bug 8450499: drop invoker's right package.
drop package dbms_aqadm_inv;

DROP VIEW ALL_TRANSFORMATIONS;
DROP VIEW ALL_ATTRIBUTE_TRANSFORMATIONS;
/

Rem =================
Rem  End AQ changes
Rem =================

Rem =======================================================================
Rem  Begin Changes for CUBE MV Summary
Rem =======================================================================

Rem adjust row counts in sum$ where it is marked as a CUBE MV

update sum$ set NUMDETAILTAB = 
    NUMDETAILTAB - (select count(*) from SUMDETAIL$ 
       where sumobj# = obj# and bitand(DETAILEUT, 2147483648) = 2147483648) 
    where bitand(xpflags, 4294967296) = 4294967296;
update sum$ set NUMKEYCOLUMNS = 
    NUMKEYCOLUMNS - (select count(*) from SUMKEY$ 
       where sumobj# = obj# and 
             bitand(DETAILCOLFUNCTION, 2147483648) = 2147483648)
    where bitand(xpflags, 4294967296) = 4294967296;

Rem then delete secondary MV PCT metadata from sumkey$ and sumdetail$
Rem  (these special rows are marked with ub8 high bit in 
Rem  DETAILEUT/DETAILCOLFUNCTION.)

delete from SUMDETAIL$ where bitand(DETAILEUT, 2147483648) = 2147483648;
delete from SUMKEY$ where bitand(DETAILCOLFUNCTION, 2147483648) = 2147483648;

COMMIT;

Rem =======================================================================
Rem  End Changes for CUBE MV Summary
Rem =======================================================================

drop public synonym v$cell_state;
drop view v_$cell_state;
drop public synonym gv$cell_state;
drop view gv_$cell_state;
drop public synonym v$cell_thread_history;
drop view v_$cell_thread_history;
drop public synonym gv$cell_thread_history;
drop view gv_$cell_thread_history;
drop public synonym v$cell_request_totals;
drop view v_$cell_request_totals;
drop public synonym gv$cell_request_totals;
drop view gv_$cell_request_totals;
drop public synonym v$cell;
drop view v_$cell;
drop public synonym gv$cell;
drop view gv_$cell;
drop public synonym v$cell_config;
drop view v_$cell_config;
drop public synonym gv$cell_config;
drop view gv_$cell_config;
Rem =======================================================================
Rem  Begin Changes for OLAP 
Rem =======================================================================

drop trigger aw_ren_trg;
drop procedure aw_ren_proc;
drop public synonym dbms_cube_log;
drop package dbms_cube_log;

Rem OLAP Data Dictionary tables

truncate table olap_multi_options$;

update olap_aw_deployment_controls$ set spare5 = NULL;
update olap_impl_options$ set spare5 = NULL;
update olap_cube_dimensions$ set type# = NULL, length = NULL, 
  charsetform = NULL, precision# = NULL, scale = NULL, type_property = NULL;
update olap_descriptions$ set spare1 = NULL;
update olap_dim_levels$ set spare1 = NULL;
update olap_hierarchies$ set spare1 = NULL;
update olap_attributes$ set target_attribute# = NULL, type_property = NULL, spare1 = NULL;
update olap_measures$ set type_property = NULL, spare1 = NULL;
update olap_dimensionality$ set owning_diml_id = NULL, attribute_id = NULL, 
  breakout_flags = NULL;
update olap_models$ set spare1 = NULL;

alter table olap_descriptions$ drop (spare1);
alter table olap_dim_levels$ drop (spare1);
alter table olap_hierarchies$ drop (spare1);
alter table olap_attributes$ drop (spare1);
alter table olap_measures$ drop (spare1);
alter table olap_models$ drop (spare1);

ALTER TABLE olap_descriptions$ RENAME COLUMN description_class TO spare1;
ALTER TABLE olap_dim_levels$ RENAME COLUMN level_order TO spare1;
ALTER TABLE olap_hierarchies$ RENAME COLUMN hierarchy_order TO spare1;
ALTER TABLE olap_attributes$ RENAME COLUMN attribute_order TO spare1;
ALTER TABLE olap_measures$ RENAME COLUMN measure_order TO spare1;
ALTER TABLE olap_models$ RENAME COLUMN explicit_dim_id TO spare1;

Rem OLAP API callback for table export

delete from expdepact$ where schema = 'SYS' and package = 'DBMS_CUBE_EXP';
delete from exppkgact$ where schema = 'SYS' and package = 'DBMS_CUBE_EXP' 
  and class = 4;
commit;

Rem =======================================================================
Rem  End Changes for OLAP 
Rem =======================================================================


Rem =======================================================================
Rem  Begin Changes for AWR Reports
Rem =======================================================================

drop package sys.dbms_awr_report_layout;

drop type awrrpt_instance_list_type force;

Rem =======================================================================
Rem  End Changes for AWR Reports
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Server-Generated Alerts 
Rem =======================================================================
drop public synonym dba_tablespace_thresholds;
drop view dba_tablespace_thresholds;
Rem =======================================================================
Rem  End Changes for Server-Generated Alerts 
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for SPACE
Rem =======================================================================
Rem Downgrade  DBA_TABLESPACE_USAGE_METRICS 
drop public synonym DBA_TABLESPACE_USAGE_METRICS;
drop view DBA_TABLESPACE_USAGE_METRICS;

Rem =======================================================================
Rem  End Changes for SPACE
Rem =======================================================================


Rem=========================================================================
Rem Drop all new types here
Rem=========================================================================

-- drop your report subtype synonyms here
drop public synonym wri$_rept_plan_diff;

-- delete plandiff objects before drop the subtype
delete from sys.wri$_rept_components 
where treat(object as wri$_rept_plan_diff) is not null;

-- drop your report subtypes here 
drop type wri$_rept_plan_diff validate;

Rem=========================================================================
Rem END RDBMS patch downgrade
Rem=========================================================================

Rem *************************************************************************
Rem remove/downgrade audit clean up setup
Rem *************************************************************************
Rem Add back the index on aud$
DECLARE
  AUD_SCHEMA     VARCHAR2(32);
BEGIN
  -- First, check where is AUD$ present
  SELECT u.name INTO AUD_SCHEMA FROM obj$ o, user$ u
         WHERE o.name = 'AUD$' AND o.type#=2 AND o.owner# = u.user#
               AND o.remoteowner is null AND o.linkname is null
               AND u.name IN ('SYS', 'SYSTEM');

  EXECUTE IMMEDIATE 'CREATE INDEX ' || AUD_SCHEMA || '.I_AUD1' ||
                    ' ON ' || AUD_SCHEMA || '.AUD$(SESSIONID, SES$TID)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -01408 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem Drop DBMS_AUDIT_MGMT package and tables/views
Rem Will not drop DBA_AUDIT_MGMT_CLEAN_EVENTS view and 
Rem DAM_CLEANUP_EVENTS$ table since it will have the cleanup history
Rem done by DBMS_AUDIT_MGMT.
drop public synonym DBA_AUDIT_MGMT_CLEANUP_JOBS;
drop public synonym DBA_AUDIT_MGMT_LAST_ARCH_TS;
drop public synonym DBA_AUDIT_MGMT_CONFIG_PARAMS;
drop view DBA_AUDIT_MGMT_CLEANUP_JOBS;
drop view DBA_AUDIT_MGMT_LAST_ARCH_TS;
drop view DBA_AUDIT_MGMT_CONFIG_PARAMS;
drop sequence DAM_CLEANUP_SEQ$;
truncate table DAM_CLEANUP_JOBS$;
truncate table DAM_LAST_ARCH_TS$;
alter table DAM_CONFIG_PARAM$ disable constraint DAM_CONFIG_PARAM_FK1;
truncate table DAM_CONFIG_PARAM$;
truncate table DAM_PARAM_TAB$;
alter table DAM_CONFIG_PARAM$ enable constraint DAM_CONFIG_PARAM_FK1;
drop package dbms_audit_mgmt;
drop library dbms_audit_mgmt_lib;

Rem *************************************************************************
Rem END audit clean up un-setup
Rem *************************************************************************

Rem =======================================================================
Rem Remove new audit options 
Rem =======================================================================

delete from STMT_AUDIT_OPTION_MAP where option# = 51;

Rem =======================================================================
Rem  Bug-7295457 : Delete audit options from stmt_audit_option_map
Rem ======================================================================= 
delete from STMT_AUDIT_OPTION_MAP where option# = 186;
delete from STMT_AUDIT_OPTION_MAP where option# = 200;
delete from STMT_AUDIT_OPTION_MAP where option# = 201;
delete from STMT_AUDIT_OPTION_MAP where option# = 202;
delete from STMT_AUDIT_OPTION_MAP where option# = 203;
delete from STMT_AUDIT_OPTION_MAP where option# = 204;
delete from STMT_AUDIT_OPTION_MAP where option# = 205;
delete from STMT_AUDIT_OPTION_MAP where option# = 206;
delete from STMT_AUDIT_OPTION_MAP where option# = 207;
delete from STMT_AUDIT_OPTION_MAP where option# = 208;
delete from STMT_AUDIT_OPTION_MAP where option# = 209;
delete from STMT_AUDIT_OPTION_MAP where option# = 212;
delete from STMT_AUDIT_OPTION_MAP where option# = 213;
delete from STMT_AUDIT_OPTION_MAP where option# = 227;
delete from STMT_AUDIT_OPTION_MAP where option# = 228;
Rem =======================================================================
Rem  End Changes for Bug-7295457
Rem ======================================================================= 

Rem =======================================================================
Rem  Begin Changes for Scheduler
Rem =======================================================================

DROP PUBLIC SYNONYM JOB_DEFINITION;
DROP PUBLIC SYNONYM JOB_DEFINITION_ARRAY;

DECLARE
previous_version varchar2(30);

BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version LIKE '11.1.0.6%' THEN 
    execute immediate
      'drop type body sys.job_definition';
    execute immediate
      'drop type sys.job_definition_array force';
    execute immediate
      'drop type sys.job_definition force';
  END IF;
END;
/

-- downgrade event_info type to remove object_subname and job_class_name
-- we can't drop the attributes because they are columns in a SYS table
-- the type body will be recreated by catsch while running catproc
ALTER TYPE sys.scheduler$_event_info DROP
  CONSTRUCTOR FUNCTION scheduler$_event_info (
    event_type         VARCHAR2,
    object_owner       VARCHAR2,
    object_name        VARCHAR2,
    event_timestamp    TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
    error_code         NUMBER DEFAULT NULL,
    error_msg          VARCHAR2 DEFAULT NULL,
    event_status       NUMBER DEFAULT NULL,
    log_id             NUMBER DEFAULT NULL,
    run_count          NUMBER DEFAULT NULL,
    failure_count      NUMBER DEFAULT NULL,
    retry_count        NUMBER DEFAULT NULL,
    spare1             NUMBER DEFAULT NULL,
    spare2             NUMBER DEFAULT NULL,
    spare3             VARCHAR2 DEFAULT NULL,
    spare4             VARCHAR2 DEFAULT NULL,
    spare5             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare6             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare7             RAW DEFAULT NULL,
    spare8             RAW DEFAULT NULL,
    object_subname     VARCHAR2 DEFAULT NULL,
    job_class_name     VARCHAR2 DEFAULT NULL)
    RETURN SELF AS RESULT CASCADE;

ALTER TYPE sys.scheduler$_event_info ADD
  CONSTRUCTOR FUNCTION scheduler$_event_info (
    event_type         VARCHAR2,
    object_owner       VARCHAR2,
    object_name        VARCHAR2,
    event_timestamp    TIMESTAMP WITH TIME ZONE DEFAULT SYSTIMESTAMP,
    error_code         NUMBER DEFAULT NULL,
    error_msg          VARCHAR2 DEFAULT NULL,
    event_status       NUMBER DEFAULT NULL,
    log_id             NUMBER DEFAULT NULL,
    run_count          NUMBER DEFAULT NULL,
    failure_count      NUMBER DEFAULT NULL,
    retry_count        NUMBER DEFAULT NULL,
    spare1             NUMBER DEFAULT NULL,
    spare2             NUMBER DEFAULT NULL,
    spare3             VARCHAR2 DEFAULT NULL,
    spare4             VARCHAR2 DEFAULT NULL,
    spare5             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare6             TIMESTAMP WITH TIME ZONE DEFAULT NULL,
    spare7             RAW DEFAULT NULL,
    spare8             RAW DEFAULT NULL)
    RETURN SELF AS RESULT CASCADE;


-- Drop scheduler file watcher related types

drop type scheduler_filewatcher_hst_list force;
drop type scheduler_filewatcher_history force;
drop type scheduler_filewatcher_res_list force;
drop type scheduler_filewatcher_result force;
drop type scheduler_filewatcher_req_list force;
drop type scheduler_filewatcher_request force;

truncate table scheduler$_filewatcher_history;

DROP PACKAGE BODY dbms_sched_file_watcher_export;
DROP PACKAGE dbms_sched_file_watcher_export;
DROP PUBLIC SYNONYM dbms_sched_file_watcher_export;

ALTER TABLE sys.scheduler$_wingrp_member 
DROP CONSTRAINT scheduler$_wingrp_member_uq;

ALTER TABLE sys.scheduler$_wingrp_member 
ADD CONSTRAINT scheduler$_wingrp_member_pk 
PRIMARY KEY (oid, member_oid);

-- remove scheduler e-mail notification event handler
DROP PROCEDURE sys.scheduler$_job_event_handler;

-- update run_invoker columns to NULL
UPDATE sys.scheduler$_job set run_invoker = NULL;
UPDATE sys.scheduler$_lightweight_job set run_invoker = NULL;

-- drop scheduler attribute export package
DROP PACKAGE BODY dbms_sched_attribute_export;
DROP PACKAGE dbms_sched_attribute_export;

-- drop all 11.2 new views and public synonyms
DROP VIEW dba_scheduler_job_dests;
DROP PUBLIC SYNONYM dba_scheduler_job_dests;
DROP VIEW user_scheduler_job_dests;
DROP PUBLIC SYNONYM user_scheduler_job_dests;
DROP VIEW all_scheduler_job_dests;
DROP PUBLIC SYNONYM all_scheduler_job_dests;
DROP VIEW dba_scheduler_groups;
DROP PUBLIC SYNONYM dba_scheduler_groups;
DROP VIEW user_scheduler_groups;
DROP PUBLIC SYNONYM user_scheduler_groups;
DROP VIEW all_scheduler_groups;
DROP PUBLIC SYNONYM all_scheduler_groups;
DROP VIEW dba_scheduler_group_members;
DROP PUBLIC SYNONYM dba_scheduler_group_members;
DROP VIEW user_scheduler_group_members;
DROP PUBLIC SYNONYM user_scheduler_group_members;
DROP VIEW all_scheduler_group_members;
DROP PUBLIC SYNONYM all_scheduler_group_members;
DROP VIEW dba_scheduler_file_watchers;
DROP PUBLIC SYNONYM dba_scheduler_file_watchers;
DROP VIEW user_scheduler_file_watchers;
DROP PUBLIC SYNONYM user_scheduler_file_watchers;
DROP VIEW all_scheduler_file_watchers;
DROP PUBLIC SYNONYM all_scheduler_file_watchers;
DROP VIEW dba_scheduler_dests;
DROP PUBLIC SYNONYM dba_scheduler_dests;
DROP VIEW user_scheduler_dests;
DROP PUBLIC SYNONYM user_scheduler_dests;
DROP VIEW all_scheduler_dests;
DROP PUBLIC SYNONYM all_scheduler_dests;
DROP VIEW dba_scheduler_external_dests;
DROP PUBLIC SYNONYM dba_scheduler_external_dests;
DROP VIEW all_scheduler_external_dests;
DROP PUBLIC SYNONYM all_scheduler_external_dests;
DROP VIEW dba_scheduler_db_dests;
DROP PUBLIC SYNONYM dba_scheduler_db_dests;
DROP VIEW user_scheduler_db_dests;
DROP PUBLIC SYNONYM user_scheduler_db_dests;
DROP VIEW all_scheduler_db_dests;
DROP PUBLIC SYNONYM all_scheduler_db_dests;
DROP VIEW dba_scheduler_notifications;
DROP PUBLIC SYNONYM dba_scheduler_notifications;
DROP VIEW user_scheduler_notifications;
DROP PUBLIC SYNONYM user_scheduler_notifications;
DROP VIEW all_scheduler_notifications;
DROP PUBLIC SYNONYM all_scheduler_notifications;

Rem =======================================================================
Rem  End Changes for Scheduler
Rem =======================================================================


Rem =======================================================================
Rem  Begin Changes for object policy
Rem =======================================================================

DROP VIEW v_$policy_history;
DROP PUBLIC synonym v$policy_history;
DROP VIEW gv_$policy_history;
DROP PUBLIC synonym gv$policy_history;

Rem =======================================================================
Rem  End Changes for object policy
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for DBMS_PARALLEL_EXECUTE pkg
Rem =======================================================================

drop role           ADM_PARALLEL_EXECUTE_TASK;
drop view           USER_PARALLEL_EXECUTE_TASKS;
drop view           USER_PARALLEL_EXECUTE_CHUNKS;
drop view           DBA_PARALLEL_EXECUTE_TASKS;
drop view           DBA_PARALLEL_EXECUTE_CHUNKS;
drop public synonym USER_PARALLEL_EXECUTE_TASKS;
drop public synonym USER_PARALLEL_EXECUTE_CHUNKS;
drop PUBLIC SYNONYM DBA_PARALLEL_EXECUTE_TASKS;
drop public synonym DBA_PARALLEL_EXECUTE_CHUNKS;
truncate table      DBMS_PARALLEL_EXECUTE_CHUNKS$;
alter table DBMS_PARALLEL_EXECUTE_CHUNKS$
  disable constraint FK_DBMS_PARALLEL_EXECUTE_1;
truncate table      DBMS_PARALLEL_EXECUTE_TASK$;
drop sequence       dbms_parallel_execute_seq$;
drop package        dbms_parallel_execute;
drop package        dbms_parallel_execute_internal;

Rem =======================================================================
Rem  End Changes for DBMS_PARALLEL_EXECUTE pkg
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for DBMS_CROSSEDITION_TRIGGER pkg
Rem =======================================================================

drop package dbms_crossedition_trigger;
drop PUBLIC SYNONYM dbms_crossedition_trigger;

Rem =======================================================================
Rem  End Changes for DBMS_CROSSEDITION_TRIGGER pkg
Rem =======================================================================

-- Downgrade XS objects
Alter table xs$sessions drop (userid, userguid) ;
Alter table xs$sessions add 
(userid              raw(16)        not null ) ;

ALTER TABLE xs$sessions RENAME COLUMN sessize TO authtimeout ;
UPDATE xs$sessions SET authtimeout = NULL ;
ALTER TABLE xs$sessions MODIFY (authtimeout number(6)) ;
ALTER TABLE xs$sessions DROP (proxyid);
ALTER TABLE xs$sessions RENAME COLUMN  proxyguid TO proxyid;

ALTER TABLE xs$session_appns DROP (modtime);

-- Drop index on sessions tables
DROP index xs$sessions_i1 ;
DROP index xs$session_roles_i1 ;
DROP index xs$session_appns_i1 ;

TRUNCATE TABLE xs$parameters;
ALTER TABLE xs$parameters drop (registration_sequence, flags);

create table xs$session_hws
(
  sid             raw(16)        not null ,       /* Light Weight Session ID */
  hwsid           number         not null ,       /* Heavy Weight Session ID */
  hwserial#       number         not null , /* Heavy Weight Session serial # */
  flags           number(10)     not null                           /* Flags */
)
tablespace SYSAUX
/

DROP SEQUENCE xsparam_reg_sequence$;

drop package dbms_xs_system ;
drop package dbms_xs_system_ffi ;
drop package dbms_xs_fidm ;
drop package xs_util;

Rem Bug 5373923: table for transient IOTs created during IOT partition
Rem              maintenance operations
truncate table transient_iot$;

Rem =======================================================================
Rem  Begin Changes for Streams
Rem =======================================================================

alter type lcr$_row_record drop member function
   get_thread_number return number cascade;

alter type lcr$_row_record drop member function
   get_position return raw cascade;

alter type lcr$_row_record drop static function
   get_scn_from_position(position in raw) return number cascade;

alter type lcr$_row_record drop static function
   get_commit_scn_from_position(position in raw) return number cascade;

alter type lcr$_row_record drop  member procedure
   get_row_text(self in lcr$_row_record,
                row_text in out nocopy clob) cascade;

alter type lcr$_row_record drop member procedure 
   get_where_clause (self     IN lcr$_row_record,
                     where_clause IN OUT NOCOPY CLOB) cascade;

alter type lcr$_row_record drop  member procedure
   get_row_text(self in lcr$_row_record,
                row_text in out nocopy clob,
                variable_list in out nocopy sys.lcr$_row_list,
                bind_var_syntax in varchar2 default ':') cascade;

alter type lcr$_row_record drop member procedure
   get_where_clause(self IN lcr$_row_record,
                    where_clause    IN OUT NOCOPY CLOB,
                    variable_list   IN OUT NOCOPY sys.lcr$_row_list,
                    bind_var_syntax IN VARCHAR2 DEFAULT ':') cascade;

alter type lcr$_row_record drop static function construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL,
     old_values                 in sys.lcr$_row_list DEFAULT NULL,
     new_values                 in sys.lcr$_row_list DEFAULT NULL,
     position                   in raw               DEFAULT NULL
   )  RETURN lcr$_row_record cascade;

alter type lcr$_row_record add static function construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL,
     old_values                 in sys.lcr$_row_list DEFAULT NULL,
     new_values                 in sys.lcr$_row_list DEFAULT NULL
   )  RETURN lcr$_row_record cascade;

alter type lcr$_ddl_record drop member function
   get_thread_number return number cascade;

alter type lcr$_ddl_record drop member function
   get_position return raw cascade;

alter type lcr$_ddl_record drop static function
   get_scn_from_position(position in raw) return number cascade;

alter type lcr$_ddl_record drop static function
   get_commit_scn_from_position(position in raw) return number cascade;

alter type lcr$_ddl_record drop member function
   get_edition_name return varchar2 cascade;

alter type lcr$_ddl_record drop member procedure
   set_edition_name(self in out nocopy lcr$_ddl_record,
                    edition_name  in varchar2) cascade;

alter type lcr$_ddl_record drop static function construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     object_type                in varchar2,
     ddl_text                   in clob,
     logon_user                 in varchar2,
     current_schema             in varchar2,
     base_table_owner           in varchar2,
     base_table_name            in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL,
     position                   in raw               DEFAULT NULL,
     edition_name               in varchar2          DEFAULT NULL
   )
   RETURN lcr$_ddl_record cascade;

alter type lcr$_ddl_record add static function construct(
     source_database_name       in varchar2,
     command_type               in varchar2,
     object_owner               in varchar2,
     object_name                in varchar2,
     object_type                in varchar2,
     ddl_text                   in clob,
     logon_user                 in varchar2,
     current_schema             in varchar2,
     base_table_owner           in varchar2,
     base_table_name            in varchar2,
     tag                        in raw               DEFAULT NULL,
     transaction_id             in varchar2          DEFAULT NULL,
     scn                        in number            DEFAULT NULL
   )
   RETURN lcr$_ddl_record cascade;

update streams$_apply_milestone
  set oldest_position            = NULL,
      spill_lwm_position         = NULL,
      processed_position         = NULL,
      start_position             = NULL,
      xout_processed_position    = NULL,
      xout_processed_create_time = NULL,
      xout_processed_tid         = NULL,
      xout_processed_time        = NULL,
      applied_high_position      = NULL,
      oldest_create_time         = NULL,
      spill_lwm_create_time      = NULL,
      spare4                     = NULL,
      spare5                     = NULL,
      spare6                     = NULL,
      spare7                     = NULL;
commit;

update streams$_apply_progress
  set commit_position = NULL,
      transaction_id  = NULL;
commit;

update streams$_apply_spill_messages
  set position = NULL;
commit;

update streams$_apply_spill_msgs_part
  set position = NULL;
commit;

update streams$_apply_spill_txn
  set first_position=NULL,
      last_position=NULL,
      commit_position=NULL,
      last_message_create_time=NULL,
      transaction_id=NULL,
      parent_transaction_id=NULL;
commit;

update apply$_error set commit_time=NULL, xidusn = NULL, 
  xidslt = NULL, xidsqn = NULL;
commit;

truncate table xstream$_server;
truncate table xstream$_subset_rules;
truncate table xstream$_sysgen_objs;

drop view dba_xstream_outbound;
drop view dba_xstream_outbound_progress;
drop view dba_xstream_inbound;
drop view dba_xstream_inbound_progress;
drop view dba_xstream_rules;

drop public synonym dba_xstream_outbound;
drop public synonym dba_xstream_outbound_progress;
drop public synonym dba_xstream_inbound;
drop public synonym dba_xstream_rules;

drop view all_xstream_outbound;
drop view all_xstream_outbound_progress;
drop view all_xstream_inbound;
drop view all_xstream_inbound_progress;
drop view all_xstream_rules;

drop public synonym all_xstream_outbound;
drop public synonym all_xstream_outbound_progress;
drop public synonym all_xstream_inbound;
drop public synonym all_xstream_rules;

drop package dbms_xstream_adm;
drop package dbms_xstream_adm_utl;

update streams$_propagation_process
   set error_date = NULL,
       error_msg = NULL,
       unschedule_time = NULL,
       seqnum = NULL,
       spare3 = NULL,
       spare4 = NULL,
       spare5 = NULL,
       spare6 = NULL,
       spare7 = NULL,
       spare8 = NULL;
commit;

drop sequence streams$_propagation_seqnum;

drop view "_DBA_STREAMS_UNSUPPORTED_11_2";
drop view "_DBA_STREAMS_NEWLY_SUPTED_11_2";

Rem -------------- Begin Changes for streams: auto split-----------------------

drop public synonym DBA_STREAMS_SPLIT_MERGE_HIST;

drop view DBA_STREAMS_SPLIT_MERGE_HIST;

drop public synonym DBA_STREAMS_SPLIT_MERGE;

drop view DBA_STREAMS_SPLIT_MERGE;

truncate table streams$_split_merge;

drop sequence streams$_cap_sub_inst;

truncate table streams$_capture_server;

drop package DBMS_STREAMS_AUTO_INT;

Rem --------------- End Changes for streams: auto split------------------------

Rem -------------- Begin Changes for streams: recoverable script --------------

drop public synonym DBA_RECOVERABLE_SCRIPT_HIST;

drop view DBA_RECOVERABLE_SCRIPT_HIST;

Rem --------------- End Changes for streams: recoverable script----------------

Rem --------------- Begin undo changes to stmt handler ------------------------

DROP INDEX i_apply_dest_obj_ops1;
CREATE UNIQUE INDEX i_apply_dest_obj_ops1 on
  apply$_dest_obj_ops (sname, oname, apply_operation, apply_name)
/

UPDATE apply$_dest_obj_ops SET handler_name = null;
COMMIT;

DROP INDEX i_streams_stmt_handlers;
DROP INDEX i_streams_stmt_handler_ids;
DROP INDEX i_apply_change_handlers;
DROP TABLE streams$_stmt_handlers;
DROP TABLE streams$_stmt_handler_stmts;
DROP TABLE apply$_change_handlers;
DROP SEQUENCE streams$_stmt_handler_seq;

DROP PACKAGE dbms_apply_handler_adm;
DROP PACKAGE dbms_apply_handler_internal;

DROP PUBLIC SYNONYM dbms_streams_handler_adm;
DROP PACKAGE dbms_streams_handler_adm;
DROP PACKAGE dbms_streams_handler_internal;


DROP PUBLIC SYNONYM ALL_STREAMS_STMTS;
DROP VIEW ALL_STREAMS_STMTS;

DROP PUBLIC SYNONYM DBA_STREAMS_STMTS;
DROP VIEW DBA_STREAMS_STMTS;
DROP VIEW "_DBA_STREAMS_STMTS";

DROP PUBLIC SYNONYM ALL_STREAMS_STMT_HANDLERS;
DROP VIEW ALL_STREAMS_STMT_HANDLERS;

DROP PUBLIC SYNONYM DBA_STREAMS_STMT_HANDLERS;
DROP VIEW DBA_STREAMS_STMT_HANDLERS;
DROP VIEW "_DBA_STREAMS_STMT_HANDLERS";

DROP PUBLIC SYNONYM ALL_APPLY_CHANGE_HANDLERS;
DROP VIEW ALL_APPLY_CHANGE_HANDLERS;

DROP PUBLIC SYNONYM DBA_APPLY_CHANGE_HANDLERS;
DROP VIEW DBA_APPLY_CHANGE_HANDLERS;
DROP VIEW "_DBA_APPLY_CHANGE_HANDLERS";

DROP PACKAGE dbms_streams_mc;
DROP PACKAGE dbms_streams_mc_inv;
Rem --------------- End undo changes to stmt handler --------------------------

Rem ----------------Begin undo changes to V$STREAMS_POOL_STATISTICS------------
DROP PUBLIC SYNONYM V$STREAMS_POOL_STATISTICS;
DROP VIEW V_$STREAMS_POOL_STATISTICS;

DROP PUBLIC SYNONYM GV$STREAMS_POOL_STATISTICS;
DROP VIEW GV_$STREAMS_POOL_STATISTICS;

Rem ----------------End undo changes to V$STREAMS_POOL_STATISTICS------------

Rem ----------------begin undo changes to comparison_scan$---------------------

ALTER TABLE comparison_scan$ DROP (spare5, spare6, spare7, spare8);

UPDATE comparison_scan$
   SET spare1 = NULL,
       spare2 = NULL,
       spare3 = NULL;

COMMIT;

Rem ----------------end undo changes to comparison_scan$-----------------------

drop public synonym DBA_STREAMS_KEEP_COLUMNS;

drop view DBA_STREAMS_KEEP_COLUMNS;

Rem =======================================================================
Rem  End Changes for Streams
Rem =======================================================================

Rem*************************************************************************
Rem BEGIN Changes for LogMiner
Rem*************************************************************************

Rem This table is being dropped rather than truncated because it is a 
Rem partitioned table with unknown partitions.
drop table system.logmnrc_gsba;
drop table system.logmnr_gt_xid_include$;

Rem Restore previous cache settings.
alter sequence system.logmnr_evolve_seq$ cache 20;
alter sequence system.logmnr_seq$ cache 20;
alter sequence system.logmnr_uids$ cache 20;

Rem =============================
Rem Begin changes for bug 7596712
Rem =============================

DROP TABLE SYSTEM.LOGMNR_SESSION_ACTIONS$;

Rem =============================
Rem End changes for bug 7596712
Rem =============================

Rem downgrade for tianli_bug-8733323: clear new bit
update system.logmnrc_gtlo
set LogmnrTLOFlags = LogmnrTLOFlags - 32
where bitand(32,LogmnrTLOFlags) = 32;
commit;

Rem =======================================================================
Rem  End Changes for LogMiner
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Logical Standby
Rem =======================================================================

alter table system.logstdby$events modify (event_time timestamp null);

drop index system.logstdby$skip_idx1;
drop index system.logstdby$skip_idx2;

Rem =======================================================================
Rem  End Changes for Logical Standby
Rem =======================================================================


Rem=========================================================================
Rem BEGIN Changes for DST patching
Rem=========================================================================

drop view USER_TSTZ_TAB_COLS;
drop public synonym USER_TSTZ_TAB_COLS;

drop view ALL_TSTZ_TAB_COLS;
drop public synonym ALL_TSTZ_TAB_COLS;

drop view DBA_TSTZ_TAB_COLS;
drop public synonym DBA_TSTZ_TAB_COLS;

drop view USER_TSTZ_TABLES;
drop public synonym USER_TSTZ_TABLES;

drop view ALL_TSTZ_TABLES;
drop public synonym ALL_TSTZ_TABLES;

drop view DBA_TSTZ_TABLES;
drop public synonym DBA_TSTZ_TABLES;

drop package dbms_dst;
drop public synonym dbms_dst;

truncate table dst$affected_tables;

truncate table dst$error_table;

truncate table dst$trigger_table;

Rem=========================================================================
Rem END Changes for DST patching
Rem=========================================================================

Rem ===================================
Rem  Begin Client Result Cache Changes
Rem ===================================
drop package body  dbms_client_result_cache;
drop package dbms_client_result_cache;

Rem =================================
Rem  End Client Result Cache Changes
Rem =================================

Rem ===================================
Rem  Begin Advanced Compression Changes
Rem ===================================

truncate table compression$;

drop package dbms_compression;
drop package prvt_compression;

drop public synonym dbms_compression;

drop type int_array force;

DELETE FROM wri$_adv_definitions d 
WHERE d.id = 10 /* compression advisor */;

DELETE FROM wri$_adv_def_parameters
WHERE advisor_id = 10 /* compression advisor parameters */;

drop type wri$_adv_compression_t validate;
DROP PROCEDURE dbms_feature_hcc;

Rem =================================
Rem  End Advanced Compression Changes
Rem =================================

Rem ========================================================================
Rem Feature usage procedures
Rem ========================================================================

DROP PROCEDURE dbms_feature_rman_bzip2;
DROP PROCEDURE dbms_feature_rman_basic;
DROP PROCEDURE dbms_feature_rman_low;
DROP PROCEDURE dbms_feature_rman_medium;
DROP PROCEDURE dbms_feature_rman_high;

DROP PROCEDURE dbms_feature_segadv_user;
DROP PROCEDURE dbms_feature_securefiles_sys;
DROP PROCEDURE dbms_feature_securefiles_usr;
DROP PROCEDURE dbms_feature_sfencrypt_sys;
DROP PROCEDURE dbms_feature_sfencrypt_usr;
DROP PROCEDURE dbms_feature_sfcompress_sys;
DROP PROCEDURE dbms_feature_sfcompress_usr;
DROP PROCEDURE dbms_feature_sfdedup_sys;
DROP PROCEDURE dbms_feature_sfdedup_usr;
DROP PROCEDURE DBMS_FEATURE_EXADATA;

Rem ========================================================================
Rem End - Feature usage procedures
Rem ========================================================================

Rem =========================================================================
Rem END STAGE 2: downgrade dictionary from current release to 11.1.0
Rem =========================================================================

Rem*************************************************************************
Rem BEGIN Changes for Deferred Segment Creation
Rem*************************************************************************

truncate table deferred_stg$;

Rem*************************************************************************
Rem END Changes for Deferred Segment Creation
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for Utilities Feature Tracking
Rem*************************************************************************

drop package sys.kupu$utilities;
drop package sys.kupu$utilities_int;
drop procedure dbms_feature_utilities1;
drop procedure dbms_feature_utilities2;
drop procedure dbms_feature_utilities3;
drop procedure dbms_feature_utilities4;

update sys.ku_utluse set encryptcnt = 0, compresscnt = 0, last_used = NULL;

commit;

Rem*************************************************************************
Rem END Changes for Utilities Feature Tracking
Rem*************************************************************************

Rem =======================================================================
Rem  Begin Changes for Shared Servers
Rem =======================================================================

drop view gv_$listener_network;
drop public synonym gv$listener_network;

drop view v_$listener_network;
drop public synonym v$listener_network;

Rem =======================================================================
Rem  End Changes for Shared Servers
Rem =======================================================================

Rem*************************************************************************
Rem BEGIN Changes for HS
Rem*************************************************************************
drop role HS_ADMIN_SELECT_ROLE
drop role HS_ADMIN_EXECUTE_ROLE
Rem*************************************************************************
Rem END Changes for  HS
Rem*************************************************************************  

Rem*************************************************************************
Rem  BEGIN Bug 5921164: Set powner# column of fga$ to NULL
Rem*************************************************************************
alter table fga$ modify (powner# NUMBER NULL);
update fga$ set powner# = NULL;
Rem*************************************************************************
Rem  End Changes for Bug 5921164 
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Unco changes for ALTER DATABASE LINK (bug 6830207)
Rem*************************************************************************

delete from SYSTEM_PRIVILEGE_MAP where privilege in (-328,-329);
delete from STMT_AUDIT_OPTION_MAP where option# in (328,329);
Rem Bug 6856975
delete from STMT_AUDIT_OPTION_MAP where option# = 78;
commit;

Rem*************************************************************************
Rem END Undo changes for ALTER DATABASE LINK (bug 6830207)
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for Flashback Data Archive (FDA)
Rem*************************************************************************
drop public synonym dbms_flashback_archive;
drop package SYS.DBMS_FLASHBACK_ARCHIVE;
drop library dbms_fda_lib;

Rem*************************************************************************
Rem END Changes for  Flashback Data Archive (FDA)
Rem*************************************************************************  

Rem*************************************************************************
Rem BEGIN Changes for SQL Access Advisor
Rem*************************************************************************

delete from sys.wri$_adv_def_parameters
  where advisor_id = 2
    and name = '_SCRIPT_LIMIT';

delete from sys.wri$_adv_parameters
  where name = '_SCRIPT_LIMIT'
    and task_id in (select id from sys.wri$_adv_tasks
                     where advisor_id = 2);

commit;

Rem*************************************************************************
Rem END Changes for SQL Access Advisor
Rem*************************************************************************  

Rem*************************************************************************
Rem BEGIN Changes for SQL Performance Analyzer (SPA)
Rem*************************************************************************

drop public synonym gv$sqlpa_metric;
drop public synonym v$sqlpa_metric;
drop view gv_$sqlpa_metric;
drop view v_$sqlpa_metric;

Rem*************************************************************************
Rem END Changes for SQL Performance Analyzer (SPA)
Rem*************************************************************************

Rem BEGIN Changes for Archive Provider
Rem*************************************************************************

drop public synonym DBA_DBFS_HS;
drop view DBA_DBFS_HS;
drop public synonym USER_DBFS_HS;
drop view USER_DBFS_HS;
drop public synonym DBA_DBFS_HS_PROPERTIES;
drop view DBA_DBFS_HS_PROPERTIES;
drop public synonym USER_DBFS_HS_PROPERTIES;
drop view USER_DBFS_HS_PROPERTIES;
drop public synonym DBA_DBFS_HS_COMMANDS;
drop view DBA_DBFS_HS_COMMANDS;
drop public synonym USER_DBFS_HS_COMMANDS;
drop view USER_DBFS_HS_COMMANDS;
drop public synonym USER_DBFS_HS_FILES;
drop view USER_DBFS_HS_FILES;
drop public synonym DBA_DBFS_HS_FIXED_PROPERTIES;
drop view DBA_DBFS_HS_FIXED_PROPERTIES;
drop public synonym USER_DBFS_HS_FIXED_PROPERTIES;
drop view USER_DBFS_HS_FIXED_PROPERTIES;

drop package body sys.dbms_lob_am_private;
drop package sys.dbms_lob_am_private;
drop package body SYS.dbms_dbfs_hs;
drop public synonym dbms_dbfs_hs;
drop package SYS.dbms_dbfs_hs;

drop package body sys.dbms_apbackend;
drop package sys.dbms_apbackend;

drop package body sys.dbms_arch_provider_intl;
drop package sys.dbms_arch_provider_intl;
drop library dbms_apbackend_lib;

drop SEQUENCE sys.dbfs_hs$_StoreIdSeq;
drop SEQUENCE sys.dbfs_hs$_ArchiveRefIdSeq;
drop SEQUENCE sys.dbfs_hs$_TarballSeq;
drop SEQUENCE sys.dbfs_hs$_PolicyIdSeq;
drop SEQUENCE sys.dbfs_hs$_BackupFileIdSeq;
drop SEQUENCE sys.dbfs_hs$_rseq;

truncate table sys.dbfs_hs$_SFLocatorTable;
truncate table sys.dbfs_hs$_BackupFileTable;
truncate table sys.dbfs_hs$_ContentFnMapTbl;
truncate table sys.dbfs_hs$_StoreCommands;
truncate table sys.dbfs_hs$_StoreId2PolicyCtx;
truncate table sys.dbfs_hs$_StoreProperties;
truncate table sys.dbfs_hs$_StoreIdTable;
truncate table sys.dbfs_hs$_fs;
truncate table sys.dbfs_hs$_property;

drop public synonym dbms_dbfs_hs_litems_t force;
drop type sys.dbms_dbfs_hs_litems_t force;
drop public synonym dbms_dbfs_hs_item_t force;
drop type sys.dbms_dbfs_hs_item_t force;

Rem*************************************************************************
Rem END Changes for Archive Provider
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for SQL Tuning Sets (STS)
Rem*************************************************************************  

Rem changes for SQLSET_STS_TOPACK table/views.  We do not drop/truncate
Rem the table because it is a temp table and should be empty
 
drop public synonym "_ALL_SQLSET_STS_TOPACK"
/

drop view "_ALL_SQLSET_STS_TOPACK"
/

drop table wri$_sqlset_sts_topack
/

Rem*************************************************************************
Rem END Changes for SQL Tuning Sets (STS)
Rem*************************************************************************  

Rem*************************************************************************
Rem BEGIN
Rem   update _sqltune_control parameter
Rem*************************************************************************

Rem set back default value of _sqltune_control for tasks to 15
BEGIN
  EXECUTE IMMEDIATE
    'UPDATE wri$_adv_def_parameters 
     SET value = ''15'' 
     WHERE name = ''_SQLTUNE_CONTROL'' and advisor_id = 4 and value = ''63''';
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -942) THEN                       /* table does not exist */
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

commit;

Rem set back the old default value of _sqltune_control to 15
Rem for sys_auto_sql_tuning_task.

BEGIN
  EXECUTE IMMEDIATE
    'UPDATE wri$_adv_parameters
     SET value = ''15''
     WHERE name = ''_SQLTUNE_CONTROL'' and 
           value = ''63'' and 
           task_id = (select min(id) 
                      from   wri$_adv_tasks 
                      where  name = ''SYS_AUTO_SQL_TUNING_TASK'' and 
                             bitand(property, 32) <> 0 and 
                             advisor_id = 4)';
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -942) THEN                       /* table does not exist */
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

commit;

Rem*************************************************************************
Rem END
Rem update the _sqltune_control parameter
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Advisor Framework Changes
Rem*************************************************************************

alter table wri$_adv_usage drop constraint wri$_adv_usage_pk;

Rem note that we intentionally do not reset wri$_adv_usage new columns
Rem to their default values because 10.2.0.5 will use this information
Rem and there is no harm in leaving it there.

drop public synonym dba_sql_monitor_usage;
drop view dba_sql_monitor_usage;
truncate table wri$_sqlmon_usage;

Rem*************************************************************************
Rem END Advisor Framework Changes
Rem*************************************************************************


Rem*************************************************************************
Rem BEGIN Changes for refresh operations of non-updatable replication MVs
Rem*************************************************************************

Rem Set status of non-updatable replication MVs to regenerate refresh
Rem operations
UPDATE sys.snap$ s SET s.status = 0
 WHERE bitand(s.flag, 4096) = 0 AND
       bitand(s.flag, 8192) = 0 AND
       bitand(s.flag, 16384) = 0 AND 
       bitand(s.flag, 2) = 0 AND s.instsite = 0;

Rem  Delete 11g fast refresh operations for non-updatable replication MVs
DELETE FROM sys.snap_refop$ sr
 WHERE EXISTS 
  ( SELECT 1 from sys.snap$ s 
     WHERE bitand(s.flag, 4096) = 0 AND
           bitand(s.flag, 8192) = 0 AND
           bitand(s.flag, 16384) = 0 AND 
           bitand(s.flag, 2) = 0 AND s.instsite = 0 AND
           sr.sowner = s.sowner AND
           sr.vname = s.vname ) ;
COMMIT; 

Rem*************************************************************************
Rem END Changes for refresh operations of non-updatable replication MVs
   
Rem*************************************************************************
   
Rem ************************************************************************
Rem Resource Manager related changes - BEGIN
Rem ************************************************************************

update resource_plan_directive$ set
  max_utilization_limit = NULL;
commit;

drop procedure DBMS_FEATURE_RESOURCE_MANAGER;

Rem ************************************************************************
Rem Resource Manager related changes - END
Rem ************************************************************************

Rem*************************************************************************
Rem BEGIN changes for ref partitioning metadata
Rem In 11.1 ref partitioning overloads the TAB$ flag for bitmap join indexes.
Rem*************************************************************************

update sys.tab$
  set trigflag = trigflag + 262144
  where obj# IN (select obj# from sys.partobj$ where bitand(flags, 32) != 0)
    and bitand(trigflag, 262144) = 0;

Rem*************************************************************************
Rem END changes for ref partitioning metadata
Rem*************************************************************************


Rem remove caching during downgrade
alter sequence ora_tq_base$ nocache;


Rem*************************************************************************
Rem BEGIN Changes for CQ Notification (CQN)
Rem*************************************************************************
truncate table chnf$_query_dependencies;

Rem*************************************************************************
Rem END Changes for  CQ Notification (CQN)
Rem************************************************************************* 

Rem*************************************************************************
Rem BEGIN Changes for SQLCOMMAND
Rem*************************************************************************

drop public synonym gv$sqlcommand;
drop public synonym v$sqlcommand;
drop view gv_$sqlcommand;
drop view v_$sqlcommand;

Rem*************************************************************************
Rem END Changes for SQLCOMMAND
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for V$TOPLEVELCALL
Rem*************************************************************************

drop public synonym gv$toplevelcall;
drop public synonym v$toplevelcall;
drop view gv_$toplevelcall;
drop view v_$toplevelcall;

Rem*************************************************************************
Rem END Changes for V$TOPLEVELCALL
Rem*************************************************************************


Rem *************************************************************************
Rem  7446912: getinfo: parameter change for anytype 
Rem *************************************************************************
 
Rem Changing the getinfo parameter back to count from numelems. 

alter TYPE ANYTYPE replace
AS OPAQUE VARYING (*)
USING library DBMS_ANYTYPE_LIB
(
  STATIC PROCEDURE BeginCreate(typecode IN PLS_INTEGER,
                               atype OUT NOCOPY AnyType),
  MEMBER PROCEDURE SetInfo(self IN OUT NOCOPY AnyType,
           prec IN PLS_INTEGER, scale IN PLS_INTEGER,
           len IN PLS_INTEGER,
           csid IN PLS_INTEGER, csfrm IN PLS_INTEGER,
           atype IN ANYTYPE DEFAULT NULL,
           elem_tc IN PLS_INTEGER DEFAULT NULL,
           elem_count IN PLS_INTEGER DEFAULT 0),
  MEMBER PROCEDURE AddAttr(self IN OUT NOCOPY AnyType,
           aname IN VARCHAR2,
           typecode IN PLS_INTEGER,
           prec IN PLS_INTEGER, scale IN PLS_INTEGER,
           len IN PLS_INTEGER,
           csid IN PLS_INTEGER, csfrm IN PLS_INTEGER,
           attr_type IN ANYTYPE DEFAULT NULL),
  MEMBER PROCEDURE EndCreate(self IN OUT NOCOPY AnyType),
  STATIC FUNCTION GetPersistent(schema_name IN VARCHAR2,
                      type_name IN VARCHAR2,
                      version IN varchar2 DEFAULT NULL) return AnyType,
  MEMBER FUNCTION GetInfo (self IN AnyType,
       prec OUT PLS_INTEGER, scale OUT PLS_INTEGER,
       len OUT PLS_INTEGER, csid OUT PLS_INTEGER,
       csfrm OUT PLS_INTEGER,
       schema_name OUT VARCHAR2, type_name OUT VARCHAR2, version OUT varchar2,
       count OUT PLS_INTEGER)
                 return PLS_INTEGER,
  MEMBER FUNCTION GetAttrElemInfo (self IN AnyType, pos IN PLS_INTEGER,
       prec OUT PLS_INTEGER, scale OUT PLS_INTEGER,
       len OUT PLS_INTEGER, csid OUT PLS_INTEGER, csfrm OUT PLS_INTEGER,
       attr_elt_type OUT ANYTYPE, aname OUT VARCHAR2) return PLS_INTEGER
);

alter system flush shared_pool;

Rem The REPLACE above will invalidate all dependent objects, except table.
Rem To avoid various difs, we need to recompile a few.

alter type RE$NV_LIST compile reuse settings;
alter type ANYDATA compile reuse settings;
alter type SQL_BIND compile reuse settings;
alter type SQL_BIND_SET compile reuse settings;
alter package dbms_sqltune_util0 compile reuse settings;

alter system flush shared_pool;

Rem*************************************************************************
Rem BEGIN Changes for active session history (ASH)
Rem*************************************************************************

drop public synonym gv$ash_info;
drop public synonym v$ash_info;
drop view gv_$ash_info;
drop view v_$ash_info;

Rem*************************************************************************
Rem END Changes for active session history (ASH)
Rem*************************************************************************

Rem *************************************************************************
Rem END Changes for anytype
Rem *************************************************************************

Rem*************************************************************************
Rem Changes for drcp
Rem*************************************************************************
drop public synonym gv$cpool_conn_info;
drop view gv_$cpool_conn_info;

drop public synonym v$cpool_conn_info;
drop view v_$cpool_conn_info;
Rem*************************************************************************
Rem Changes for drcp end
Rem*************************************************************************

Rem remove v$, gv$libcachelocks and its synonyms
drop public synonym gv$libcache_locks;
drop view gv_$libcache_locks;
drop public synonym v$libcache_locks;
drop view v_$libcache_locks;

Rem*************************************************************************
Rem BEGIN Changes for Bug 7829203,default_pwd$ should not be recreated
Rem*************************************************************************

Rem Remove the entries present in the base release version (11.1.0.6)

delete from SYS.DEFAULT_PWD$  where user_name='AASH' and
pwd_verifier='9B52488370BB3D77';
delete from SYS.DEFAULT_PWD$  where user_name='ABA1' and
pwd_verifier='30FD307004F350DE';
delete from SYS.DEFAULT_PWD$  where user_name='ABM' and
pwd_verifier='D0F2982F121C7840';
delete from SYS.DEFAULT_PWD$  where user_name='AD_MONITOR' and
pwd_verifier='54F0C83F51B03F49';
delete from SYS.DEFAULT_PWD$  where user_name='ADAMS' and
pwd_verifier='72CDEF4A3483F60D';
delete from SYS.DEFAULT_PWD$  where user_name='ADS' and
pwd_verifier='D23F0F5D871EB69F';
delete from SYS.DEFAULT_PWD$  where user_name='ADSEUL_US' and
pwd_verifier='4953B2EB6FCB4339';
delete from SYS.DEFAULT_PWD$  where user_name='AHL' and
pwd_verifier='7910AE63C9F7EEEE';
delete from SYS.DEFAULT_PWD$  where user_name='AHM' and
pwd_verifier='33C2E27CF5E401A4';
delete from SYS.DEFAULT_PWD$  where user_name='AK' and
pwd_verifier='8FCB78BBA8A59515';
delete from SYS.DEFAULT_PWD$  where user_name='AL' and
pwd_verifier='384B2C568DE4C2B5';
delete from SYS.DEFAULT_PWD$  where user_name='ALA1' and
pwd_verifier='90AAC5BD7981A3BA';
delete from SYS.DEFAULT_PWD$  where user_name='ALLUSERS' and
pwd_verifier='42F7CD03B7D2CA0F';
delete from SYS.DEFAULT_PWD$  where user_name='ALR' and
pwd_verifier='BE89B24F9F8231A9';
delete from SYS.DEFAULT_PWD$  where user_name='AMA1' and
pwd_verifier='585565C23AB68F71';
delete from SYS.DEFAULT_PWD$  where user_name='AMA2' and
pwd_verifier='37E458EE1688E463';
delete from SYS.DEFAULT_PWD$  where user_name='AMA3' and
pwd_verifier='81A66D026DC5E2ED';
delete from SYS.DEFAULT_PWD$  where user_name='AMA4' and
pwd_verifier='194CCC94A481DCDE';
delete from SYS.DEFAULT_PWD$  where user_name='AMF' and
pwd_verifier='EC9419F55CDC666B';
delete from SYS.DEFAULT_PWD$  where user_name='AMS' and
pwd_verifier='BD821F59270E5F34';
delete from SYS.DEFAULT_PWD$  where user_name='AMS1' and
pwd_verifier='DB8573759A76394B';
delete from SYS.DEFAULT_PWD$  where user_name='AMS2' and
pwd_verifier='EF611999C6AD1FD7';
delete from SYS.DEFAULT_PWD$  where user_name='AMS3' and
pwd_verifier='41D1084F3F966440';
delete from SYS.DEFAULT_PWD$  where user_name='AMS4' and
pwd_verifier='5F5903367FFFB3A3';
delete from SYS.DEFAULT_PWD$  where user_name='AMSYS' and
pwd_verifier='4C1EF14ECE13B5DE';
delete from SYS.DEFAULT_PWD$  where user_name='AMV' and
pwd_verifier='38BC87EB334A1AC4';
delete from SYS.DEFAULT_PWD$  where user_name='AMW' and
pwd_verifier='0E123471AACA2A62';
delete from SYS.DEFAULT_PWD$  where user_name='ANNE' and
pwd_verifier='1EEA3E6F588599A6';
delete from SYS.DEFAULT_PWD$  where user_name='ANONYMOUS' and
pwd_verifier='94C33111FD9C66F3';
delete from SYS.DEFAULT_PWD$  where user_name='AOLDEMO' and
pwd_verifier='D04BBDD5E643C436';
delete from SYS.DEFAULT_PWD$  where user_name='AP' and
pwd_verifier='EED09A552944B6AD';
delete from SYS.DEFAULT_PWD$  where user_name='APA1' and
pwd_verifier='D00197BF551B2A79';
delete from SYS.DEFAULT_PWD$  where user_name='APA2' and
pwd_verifier='121C6F5BD4674A33';
delete from SYS.DEFAULT_PWD$  where user_name='APA3' and
pwd_verifier='5F843C0692560518';
delete from SYS.DEFAULT_PWD$  where user_name='APA4' and
pwd_verifier='BF21227532D2794A';
delete from SYS.DEFAULT_PWD$  where user_name='APPLEAD' and
pwd_verifier='5331DB9C240E093B';
delete from SYS.DEFAULT_PWD$  where user_name='APPLSYS' and
pwd_verifier='0F886772980B8C79';
delete from SYS.DEFAULT_PWD$  where user_name='APPLSYS' and
pwd_verifier='E153FFF4DAE6C9F7';
delete from SYS.DEFAULT_PWD$  where user_name='APPLSYSPUB' and
pwd_verifier='D2E3EF40EE87221E';
delete from SYS.DEFAULT_PWD$  where user_name='APPS' and
pwd_verifier='D728438E8A5925E0';
delete from SYS.DEFAULT_PWD$  where user_name='APS1' and
pwd_verifier='F65751C55EA079E6';
delete from SYS.DEFAULT_PWD$  where user_name='APS2' and
pwd_verifier='5CACE7B928382C8B';
delete from SYS.DEFAULT_PWD$  where user_name='APS3' and
pwd_verifier='C786695324D7FB3B';
delete from SYS.DEFAULT_PWD$  where user_name='APS4' and
pwd_verifier='F86074C4F4F82D2C';
delete from SYS.DEFAULT_PWD$  where user_name='AQDEMO' and
pwd_verifier='5140E342712061DD';
delete from SYS.DEFAULT_PWD$  where user_name='AQJAVA' and
pwd_verifier='8765D2543274B42E';
delete from SYS.DEFAULT_PWD$  where user_name='AQUSER' and
pwd_verifier='4CF13BDAC1D7511C';
delete from SYS.DEFAULT_PWD$  where user_name='AR' and
pwd_verifier='BBBFE175688DED7E';
delete from SYS.DEFAULT_PWD$  where user_name='ARA1' and
pwd_verifier='4B9F4E0667857EB8';
delete from SYS.DEFAULT_PWD$  where user_name='ARA2' and
pwd_verifier='F4E52BFBED4652CD';
delete from SYS.DEFAULT_PWD$  where user_name='ARA3' and
pwd_verifier='E3D8D73AE399F7FE';
delete from SYS.DEFAULT_PWD$  where user_name='ARA4' and
pwd_verifier='758FD31D826E9143';
delete from SYS.DEFAULT_PWD$  where user_name='ARS1' and
pwd_verifier='433263ED08C7A4FD';
delete from SYS.DEFAULT_PWD$  where user_name='ARS2' and
pwd_verifier='F3AF9F26D0213538';
delete from SYS.DEFAULT_PWD$  where user_name='ARS3' and
pwd_verifier='F6755F08CC1E7831';
delete from SYS.DEFAULT_PWD$  where user_name='ARS4' and
pwd_verifier='452B5A381CABB241';
delete from SYS.DEFAULT_PWD$  where user_name='ART' and
pwd_verifier='665168849666C4F3';
delete from SYS.DEFAULT_PWD$  where user_name='ASF' and
pwd_verifier='B6FD427D08619EEE';
delete from SYS.DEFAULT_PWD$  where user_name='ASG' and
pwd_verifier='1EF8D8BD87CF16BE';
delete from SYS.DEFAULT_PWD$  where user_name='ASL' and
pwd_verifier='03B20D2C323D0BFE';
delete from SYS.DEFAULT_PWD$  where user_name='ASN' and
pwd_verifier='1EE6AEBD9A23D4E0';
delete from SYS.DEFAULT_PWD$  where user_name='ASO' and
pwd_verifier='F712D80109E3C9D8';
delete from SYS.DEFAULT_PWD$  where user_name='ASP' and
pwd_verifier='CF95D2C6C85FF513';
delete from SYS.DEFAULT_PWD$  where user_name='AST' and
pwd_verifier='F13FF949563EAB3C';
delete from SYS.DEFAULT_PWD$  where user_name='AUC_GUEST' and
pwd_verifier='8A59D349DAEC26F7';
delete from SYS.DEFAULT_PWD$  where user_name='AURORA$ORB$UNAUTHENTICATED' and
pwd_verifier='80C099F0EADF877E';
delete from SYS.DEFAULT_PWD$  where user_name='AUTHORIA' and
pwd_verifier='CC78120E79B57093';
delete from SYS.DEFAULT_PWD$  where user_name='AX' and
pwd_verifier='0A8303530E86FCDD';
delete from SYS.DEFAULT_PWD$  where user_name='AZ' and
pwd_verifier='AAA18B5D51B0D5AC';
delete from SYS.DEFAULT_PWD$  where user_name='B2B' and
pwd_verifier='CC387B24E013C616';
delete from SYS.DEFAULT_PWD$  where user_name='BAM' and
pwd_verifier='031091A1D1A30061';
delete from SYS.DEFAULT_PWD$  where user_name='BCA1' and
pwd_verifier='398A69209360BD9D';
delete from SYS.DEFAULT_PWD$  where user_name='BCA2' and
pwd_verifier='801D9C90EBC89371';
delete from SYS.DEFAULT_PWD$  where user_name='BEN' and
pwd_verifier='9671866348E03616';
delete from SYS.DEFAULT_PWD$  where user_name='BIC' and
pwd_verifier='E84CC95CBBAC1B67';
delete from SYS.DEFAULT_PWD$  where user_name='BIL' and
pwd_verifier='BF24BCE2409BE1F7';
delete from SYS.DEFAULT_PWD$  where user_name='BIM' and
pwd_verifier='6026F9A8A54B9468';
delete from SYS.DEFAULT_PWD$  where user_name='BIS' and
pwd_verifier='7E9901882E5F3565';
delete from SYS.DEFAULT_PWD$  where user_name='BIV' and
pwd_verifier='2564B34BE50C2524';
delete from SYS.DEFAULT_PWD$  where user_name='BIX' and
pwd_verifier='3DD36935EAEDE2E3';
delete from SYS.DEFAULT_PWD$  where user_name='BLAKE' and
pwd_verifier='9435F2E60569158E';
delete from SYS.DEFAULT_PWD$  where user_name='BMEADOWS' and
pwd_verifier='2882BA3D3EE1F65A';
delete from SYS.DEFAULT_PWD$  where user_name='BNE' and
pwd_verifier='080B5C7EE819BF78';
delete from SYS.DEFAULT_PWD$  where user_name='BOM' and
pwd_verifier='56DB3E89EAE5788E';
delete from SYS.DEFAULT_PWD$  where user_name='BP01' and
pwd_verifier='612D669D2833FACD';
delete from SYS.DEFAULT_PWD$  where user_name='BP02' and
pwd_verifier='FCE0C089A3ECECEE';
delete from SYS.DEFAULT_PWD$  where user_name='BP03' and
pwd_verifier='0723FFEEFBA61545';
delete from SYS.DEFAULT_PWD$  where user_name='BP04' and
pwd_verifier='E5797698E0F8934E';
delete from SYS.DEFAULT_PWD$  where user_name='BP05' and
pwd_verifier='58FFC821F778D7E9';
delete from SYS.DEFAULT_PWD$  where user_name='BP06' and
pwd_verifier='2F358909A4AA6059';
delete from SYS.DEFAULT_PWD$  where user_name='BSC' and
pwd_verifier='EC481FD7DCE6366A';
delete from SYS.DEFAULT_PWD$  where user_name='BUYACCT' and
pwd_verifier='D6B388366ECF2F61';
delete from SYS.DEFAULT_PWD$  where user_name='BUYAPPR1' and
pwd_verifier='CB04931693309228';
delete from SYS.DEFAULT_PWD$  where user_name='BUYAPPR2' and
pwd_verifier='3F98A3ADC037F49C';
delete from SYS.DEFAULT_PWD$  where user_name='BUYAPPR3' and
pwd_verifier='E65D8AD3ACC23DA3';
delete from SYS.DEFAULT_PWD$  where user_name='BUYER' and
pwd_verifier='547BDA4286A2ECAE';
delete from SYS.DEFAULT_PWD$  where user_name='BUYMTCH' and
pwd_verifier='0DA5E3B504CC7497';
delete from SYS.DEFAULT_PWD$  where user_name='CAMRON' and
pwd_verifier='4384E3F9C9C9B8F1';
delete from SYS.DEFAULT_PWD$  where user_name='CANDICE' and
pwd_verifier='CF458B3230215199';
delete from SYS.DEFAULT_PWD$  where user_name='CARL' and
pwd_verifier='99ECCC664FFDFEA2';
delete from SYS.DEFAULT_PWD$  where user_name='CARLY' and
pwd_verifier='F7D90C099F9097F1';
delete from SYS.DEFAULT_PWD$  where user_name='CARMEN' and
pwd_verifier='46E23E1FD86A4277';
delete from SYS.DEFAULT_PWD$  where user_name='CARRIECONYERS' and
pwd_verifier='9BA83B1E43A5885B';
delete from SYS.DEFAULT_PWD$  where user_name='CATADMIN' and
pwd_verifier='AF9AB905347E004F';
delete from SYS.DEFAULT_PWD$  where user_name='CE' and
pwd_verifier='E7FDFE26A524FE39';
delete from SYS.DEFAULT_PWD$  where user_name='CEASAR' and
pwd_verifier='E69833B8205D5DD7';
delete from SYS.DEFAULT_PWD$  where user_name='CENTRA' and
pwd_verifier='63BF5FFE5E3EA16D';
delete from SYS.DEFAULT_PWD$  where user_name='CFD' and
pwd_verifier='667B018D4703C739';
delete from SYS.DEFAULT_PWD$  where user_name='CHANDRA' and
pwd_verifier='184503FA7786C82D';
delete from SYS.DEFAULT_PWD$  where user_name='CHARLEY' and
pwd_verifier='E500DAA705382E8D';
delete from SYS.DEFAULT_PWD$  where user_name='CHRISBAKER' and
pwd_verifier='52AFB6B3BE485F81';
delete from SYS.DEFAULT_PWD$  where user_name='CHRISTIE' and
pwd_verifier='C08B79CCEC43E798';
delete from SYS.DEFAULT_PWD$  where user_name='CINDY' and
pwd_verifier='3AB2C717D1BD0887';
delete from SYS.DEFAULT_PWD$  where user_name='CLARK' and
pwd_verifier='74DF527800B6D713';
delete from SYS.DEFAULT_PWD$  where user_name='CLARK' and
pwd_verifier='7AAFE7D01511D73F';
delete from SYS.DEFAULT_PWD$  where user_name='CLAUDE' and
pwd_verifier='C6082BCBD0B69D20';
delete from SYS.DEFAULT_PWD$  where user_name='CLINT' and
pwd_verifier='163FF8CCB7F11691';
delete from SYS.DEFAULT_PWD$  where user_name='CLN' and
pwd_verifier='A18899D42066BFCA';
delete from SYS.DEFAULT_PWD$  where user_name='CN' and
pwd_verifier='73F284637A54777D';
delete from SYS.DEFAULT_PWD$  where user_name='CNCADMIN' and
pwd_verifier='C7C8933C678F7BF9';
delete from SYS.DEFAULT_PWD$  where user_name='CONNIE' and
pwd_verifier='982F4C420DD38307';
delete from SYS.DEFAULT_PWD$  where user_name='CONNOR' and
pwd_verifier='52875AEB74008D78';
delete from SYS.DEFAULT_PWD$  where user_name='CORY' and
pwd_verifier='93CE4CCE632ADCD2';
delete from SYS.DEFAULT_PWD$  where user_name='CRM1' and
pwd_verifier='6966EA64B0DFC44E';
delete from SYS.DEFAULT_PWD$  where user_name='CRM2' and
pwd_verifier='B041F3BEEDA87F72';
delete from SYS.DEFAULT_PWD$  where user_name='CRP' and
pwd_verifier='F165BDE5462AD557';
delete from SYS.DEFAULT_PWD$  where user_name='CRPB733' and
pwd_verifier='2C9AB93FF2999125';
delete from SYS.DEFAULT_PWD$  where user_name='CRPCTL' and
pwd_verifier='4C7A200FB33A531D';
delete from SYS.DEFAULT_PWD$  where user_name='CRPDTA' and
pwd_verifier='6665270166D613BC';
delete from SYS.DEFAULT_PWD$  where user_name='CS' and
pwd_verifier='DB78866145D4E1C3';
delete from SYS.DEFAULT_PWD$  where user_name='CSADMIN' and
pwd_verifier='94327195EF560924';
delete from SYS.DEFAULT_PWD$  where user_name='CSAPPR1' and
pwd_verifier='47D841B5A01168FF';
delete from SYS.DEFAULT_PWD$  where user_name='CSC' and
pwd_verifier='EDECA9762A8C79CD';
delete from SYS.DEFAULT_PWD$  where user_name='CSD' and
pwd_verifier='144441CEBAFC91CF';
delete from SYS.DEFAULT_PWD$  where user_name='CSDUMMY' and
pwd_verifier='7A587C459B93ACE4';
delete from SYS.DEFAULT_PWD$  where user_name='CSE' and
pwd_verifier='D8CC61E8F42537DA';
delete from SYS.DEFAULT_PWD$  where user_name='CSF' and
pwd_verifier='684E28B3C899D42C';
delete from SYS.DEFAULT_PWD$  where user_name='CSI' and
pwd_verifier='71C2B12C28B79294';
delete from SYS.DEFAULT_PWD$  where user_name='CSL' and
pwd_verifier='C4D7FE062EFB85AB';
delete from SYS.DEFAULT_PWD$  where user_name='CSM' and
pwd_verifier='94C24FC0BE22F77F';
delete from SYS.DEFAULT_PWD$  where user_name='CSMIG' and
pwd_verifier='09B4BB013FBD0D65';
delete from SYS.DEFAULT_PWD$  where user_name='CSP' and
pwd_verifier='5746C5E077719DB4';
delete from SYS.DEFAULT_PWD$  where user_name='CSR' and
pwd_verifier='0E0F7C1B1FE3FA32';
delete from SYS.DEFAULT_PWD$  where user_name='CSS' and
pwd_verifier='3C6B8C73DDC6B04F';
delete from SYS.DEFAULT_PWD$  where user_name='CTXDEMO' and
pwd_verifier='CB6B5E9D9672FE89';
delete from SYS.DEFAULT_PWD$  where user_name='CTXSYS' and
pwd_verifier='24ABAB8B06281B4C';
delete from SYS.DEFAULT_PWD$  where user_name='CTXSYS' and
pwd_verifier='71E687F036AD56E5';
delete from SYS.DEFAULT_PWD$  where user_name='CTXTEST' and
pwd_verifier='064717C317B551B6';
delete from SYS.DEFAULT_PWD$  where user_name='CUA' and
pwd_verifier='CB7B2E6FFDD7976F';
delete from SYS.DEFAULT_PWD$  where user_name='CUE' and
pwd_verifier='A219FE4CA25023AA';
delete from SYS.DEFAULT_PWD$  where user_name='CUF' and
pwd_verifier='82959A9BD2D51297';
delete from SYS.DEFAULT_PWD$  where user_name='CUG' and
pwd_verifier='21FBCADAEAFCC489';
delete from SYS.DEFAULT_PWD$  where user_name='CUI' and
pwd_verifier='AD7862E01FA80912';
delete from SYS.DEFAULT_PWD$  where user_name='CUN' and
pwd_verifier='41C2D31F3C85A79D';
delete from SYS.DEFAULT_PWD$  where user_name='CUP' and
pwd_verifier='C03082CD3B13EC42';
delete from SYS.DEFAULT_PWD$  where user_name='CUS' and
pwd_verifier='00A12CC6EBF8EDB8';
delete from SYS.DEFAULT_PWD$  where user_name='CZ' and
pwd_verifier='9B667E9C5A0D21A6';
delete from SYS.DEFAULT_PWD$  where user_name='DAVIDMORGAN' and
pwd_verifier='B717BAB262B7A070';
delete from SYS.DEFAULT_PWD$  where user_name='DBSNMP' and
pwd_verifier='E066D214D5421CCC';
delete from SYS.DEFAULT_PWD$  where user_name='DCM' and
pwd_verifier='45CCF86E1058D3A5';
delete from SYS.DEFAULT_PWD$  where user_name='DD7333' and
pwd_verifier='44886308CF32B5D4';
delete from SYS.DEFAULT_PWD$  where user_name='DD7334' and
pwd_verifier='D7511E19D9BD0F90';
delete from SYS.DEFAULT_PWD$  where user_name='DD810' and
pwd_verifier='0F9473D8D8105590';
delete from SYS.DEFAULT_PWD$  where user_name='DD811' and
pwd_verifier='D8084AE609C9A2FD';
delete from SYS.DEFAULT_PWD$  where user_name='DD812' and
pwd_verifier='AB71915CF21E849E';
delete from SYS.DEFAULT_PWD$  where user_name='DD9' and
pwd_verifier='E81821D03070818C';
delete from SYS.DEFAULT_PWD$  where user_name='DDB733' and
pwd_verifier='7D11619CEE99DE12';
delete from SYS.DEFAULT_PWD$  where user_name='DDD' and
pwd_verifier='6CB03AF4F6DD133D';
delete from SYS.DEFAULT_PWD$  where user_name='DEMO8' and
pwd_verifier='0E7260738FDFD678';
delete from SYS.DEFAULT_PWD$  where user_name='DES' and
pwd_verifier='ABFEC5AC2274E54D';
delete from SYS.DEFAULT_PWD$  where user_name='DES2K' and
pwd_verifier='611E7A73EC4B425A';
delete from SYS.DEFAULT_PWD$  where user_name='DEV2000_DEMOS' and
pwd_verifier='18A0C8BD6B13BEE2';
delete from SYS.DEFAULT_PWD$  where user_name='DEVB733' and
pwd_verifier='7500DF89DC99C057';
delete from SYS.DEFAULT_PWD$  where user_name='DEVUSER' and
pwd_verifier='C10B4A80D00CA7A5';
delete from SYS.DEFAULT_PWD$  where user_name='DGRAY' and
pwd_verifier='5B76A1EB8F212B85';
delete from SYS.DEFAULT_PWD$  where user_name='DIP' and
pwd_verifier='CE4A36B8E06CA59C';
delete from SYS.DEFAULT_PWD$  where user_name='DISCOVERER5' and
pwd_verifier='AF0EDB66D914B731';
delete from SYS.DEFAULT_PWD$  where user_name='DKING' and
pwd_verifier='255C2B0E1F0912EA';
delete from SYS.DEFAULT_PWD$  where user_name='DLD' and
pwd_verifier='4454B932A1E0E320';
delete from SYS.DEFAULT_PWD$  where user_name='DMADMIN' and
pwd_verifier='E6681A8926B40826';
delete from SYS.DEFAULT_PWD$  where user_name='DMATS' and
pwd_verifier='8C692701A4531286';
delete from SYS.DEFAULT_PWD$  where user_name='DMS' and
pwd_verifier='1351DC7ED400BD59';
delete from SYS.DEFAULT_PWD$  where user_name='DMSYS' and
pwd_verifier='BFBA5A553FD9E28A';
delete from SYS.DEFAULT_PWD$  where user_name='DOM' and
pwd_verifier='51C9F2BECA78AE0E';
delete from SYS.DEFAULT_PWD$  where user_name='DPOND' and
pwd_verifier='79D6A52960EEC216';
delete from SYS.DEFAULT_PWD$  where user_name='DSGATEWAY' and
pwd_verifier='6869F3CFD027983A';
delete from SYS.DEFAULT_PWD$  where user_name='DV7333' and
pwd_verifier='36AFA5CD674BA841';
delete from SYS.DEFAULT_PWD$  where user_name='DV7334' and
pwd_verifier='473B568021BDB428';
delete from SYS.DEFAULT_PWD$  where user_name='DV810' and
pwd_verifier='52C38F48C99A0352';
delete from SYS.DEFAULT_PWD$  where user_name='DV811' and
pwd_verifier='B6DC5AAB55ECB66C';
delete from SYS.DEFAULT_PWD$  where user_name='DV812' and
pwd_verifier='7359E6E060B945BA';
delete from SYS.DEFAULT_PWD$  where user_name='DV9' and
pwd_verifier='07A1D03FD26E5820';
delete from SYS.DEFAULT_PWD$  where user_name='DVP1' and
pwd_verifier='0559A0D3DE0759A6';
delete from SYS.DEFAULT_PWD$  where user_name='EAA' and
pwd_verifier='A410B2C5A0958CDF';
delete from SYS.DEFAULT_PWD$  where user_name='EAM' and
pwd_verifier='CE8234D92FCFB563';
delete from SYS.DEFAULT_PWD$  where user_name='EC' and
pwd_verifier='6A066C462B62DD46';
delete from SYS.DEFAULT_PWD$  where user_name='ECX' and
pwd_verifier='0A30645183812087';
delete from SYS.DEFAULT_PWD$  where user_name='EDR' and
pwd_verifier='5FEC29516474BB3A';
delete from SYS.DEFAULT_PWD$  where user_name='EDWEUL_US' and
pwd_verifier='5922BA2E72C49787';
delete from SYS.DEFAULT_PWD$  where user_name='EDWREP' and
pwd_verifier='79372B4AB748501F';
delete from SYS.DEFAULT_PWD$  where user_name='EGC1' and
pwd_verifier='D78E0F2BE306450D';
delete from SYS.DEFAULT_PWD$  where user_name='EGD1' and
pwd_verifier='DA6D6F2089885BA6';
delete from SYS.DEFAULT_PWD$  where user_name='EGM1' and
pwd_verifier='FB949D5E4B5255C0';
delete from SYS.DEFAULT_PWD$  where user_name='EGO' and
pwd_verifier='B9D919E5F5A9DA71';
delete from SYS.DEFAULT_PWD$  where user_name='EGR1' and
pwd_verifier='BB636336ADC5824A';
delete from SYS.DEFAULT_PWD$  where user_name='END1' and
pwd_verifier='688499930C210B75';
delete from SYS.DEFAULT_PWD$  where user_name='ENG' and
pwd_verifier='4553A3B443FB3207';
delete from SYS.DEFAULT_PWD$  where user_name='ENI' and
pwd_verifier='05A92C0958AFBCBC';
delete from SYS.DEFAULT_PWD$  where user_name='ENM1' and
pwd_verifier='3BDABFD1246BFEA2';
delete from SYS.DEFAULT_PWD$  where user_name='ENS1' and
pwd_verifier='F68A5D0D6D2BB25B';
delete from SYS.DEFAULT_PWD$  where user_name='ENTMGR_CUST' and
pwd_verifier='45812601EAA2B8BD';
delete from SYS.DEFAULT_PWD$  where user_name='ENTMGR_PRO' and
pwd_verifier='20002682991470B3';
delete from SYS.DEFAULT_PWD$  where user_name='ENTMGR_TRAIN' and
pwd_verifier='BE40A3BE306DD857';
delete from SYS.DEFAULT_PWD$  where user_name='EOPP_PORTALADM' and
pwd_verifier='B60557FD8C45005A';
delete from SYS.DEFAULT_PWD$  where user_name='EOPP_PORTALMGR' and
pwd_verifier='9BB3CF93F7DE25F1';
delete from SYS.DEFAULT_PWD$  where user_name='EOPP_USER' and
pwd_verifier='13709991FC4800A1';
delete from SYS.DEFAULT_PWD$  where user_name='EUL_US' and
pwd_verifier='28AEC22561414B29';
delete from SYS.DEFAULT_PWD$  where user_name='EVM' and
pwd_verifier='137CEDC20DE69F71';
delete from SYS.DEFAULT_PWD$  where user_name='EXA1' and
pwd_verifier='091BCD95EE112EE3';
delete from SYS.DEFAULT_PWD$  where user_name='EXA2' and
pwd_verifier='E4C0A21DBD06B890';
delete from SYS.DEFAULT_PWD$  where user_name='EXA3' and
pwd_verifier='40DC4FA801A73560';
delete from SYS.DEFAULT_PWD$  where user_name='EXA4' and
pwd_verifier='953885D52BDF5C86';
delete from SYS.DEFAULT_PWD$  where user_name='EXFSYS' and
pwd_verifier='66F4EF5650C20355';
delete from SYS.DEFAULT_PWD$  where user_name='EXS1' and
pwd_verifier='C5572BAB195817F0';
delete from SYS.DEFAULT_PWD$  where user_name='EXS2' and
pwd_verifier='8FAA3AC645793562';
delete from SYS.DEFAULT_PWD$  where user_name='EXS3' and
pwd_verifier='E3050174EE1844BA';
delete from SYS.DEFAULT_PWD$  where user_name='EXS4' and
pwd_verifier='E963BFE157475F7D';
delete from SYS.DEFAULT_PWD$  where user_name='FA' and
pwd_verifier='21A837D0AED8F8E5';
delete from SYS.DEFAULT_PWD$  where user_name='FEM' and
pwd_verifier='BD63D79ADF5262E7';
delete from SYS.DEFAULT_PWD$  where user_name='FIA1' and
pwd_verifier='2EB76E07D3E094EC';
delete from SYS.DEFAULT_PWD$  where user_name='FII' and
pwd_verifier='CF39DE29C08F71B9';
delete from SYS.DEFAULT_PWD$  where user_name='FLM' and
pwd_verifier='CEE2C4B59E7567A3';
delete from SYS.DEFAULT_PWD$  where user_name='FNI1' and
pwd_verifier='308839029D04F80C';
delete from SYS.DEFAULT_PWD$  where user_name='FNI2' and
pwd_verifier='05C69C8FEAB4F0B9';
delete from SYS.DEFAULT_PWD$  where user_name='FPA' and
pwd_verifier='9FD6074B9FD3754C';
delete from SYS.DEFAULT_PWD$  where user_name='FPT' and
pwd_verifier='73E3EC9C0D1FAECF';
delete from SYS.DEFAULT_PWD$  where user_name='FRM' and
pwd_verifier='9A2A7E2EBE6E4F71';
delete from SYS.DEFAULT_PWD$  where user_name='FTA1' and
pwd_verifier='65FF9AB3A49E8A13';
delete from SYS.DEFAULT_PWD$  where user_name='FTE' and
pwd_verifier='2FB4D2C9BAE2CCCA';
delete from SYS.DEFAULT_PWD$  where user_name='FUN' and
pwd_verifier='8A7055CA462DB219';
delete from SYS.DEFAULT_PWD$  where user_name='FV' and
pwd_verifier='907D70C0891A85B1';
delete from SYS.DEFAULT_PWD$  where user_name='FVP1' and
pwd_verifier='6CC7825EADF994E8';
delete from SYS.DEFAULT_PWD$  where user_name='GALLEN' and
pwd_verifier='F8E8ED9F15842428';
delete from SYS.DEFAULT_PWD$  where user_name='GCA1' and
pwd_verifier='47DA9864E018539B';
delete from SYS.DEFAULT_PWD$  where user_name='GCA2' and
pwd_verifier='FD6E06F7DD50E868';
delete from SYS.DEFAULT_PWD$  where user_name='GCA3' and
pwd_verifier='4A4B9C2E9624C410';
delete from SYS.DEFAULT_PWD$  where user_name='GCA9' and
pwd_verifier='48A7205A4C52D6B5';
delete from SYS.DEFAULT_PWD$  where user_name='GCMGR1' and
pwd_verifier='14A1C1A08EA915D6';
delete from SYS.DEFAULT_PWD$  where user_name='GCMGR2' and
pwd_verifier='F4F11339A4221A4D';
delete from SYS.DEFAULT_PWD$  where user_name='GCMGR3' and
pwd_verifier='320F0D4258B9D190';
delete from SYS.DEFAULT_PWD$  where user_name='GCS' and
pwd_verifier='7AE34CA7F597EBF7';
delete from SYS.DEFAULT_PWD$  where user_name='GCS1' and
pwd_verifier='2AE8E84D2400E61D';
delete from SYS.DEFAULT_PWD$  where user_name='GCS2' and
pwd_verifier='C242D2B83162FF3D';
delete from SYS.DEFAULT_PWD$  where user_name='GCS3' and
pwd_verifier='DCCB4B49C68D77E2';
delete from SYS.DEFAULT_PWD$  where user_name='GEORGIAWINE' and
pwd_verifier='F05B1C50A1C926DE';
delete from SYS.DEFAULT_PWD$  where user_name='GL' and
pwd_verifier='CD6E99DACE4EA3A6';
delete from SYS.DEFAULT_PWD$  where user_name='GLA1' and
pwd_verifier='86C88007729EB36F';
delete from SYS.DEFAULT_PWD$  where user_name='GLA2' and
pwd_verifier='807622529F170C02';
delete from SYS.DEFAULT_PWD$  where user_name='GLA3' and
pwd_verifier='863A20A4EFF7386B';
delete from SYS.DEFAULT_PWD$  where user_name='GLA4' and
pwd_verifier='DB882CF89A758377';
delete from SYS.DEFAULT_PWD$  where user_name='GLS1' and
pwd_verifier='7485C6BD564E75D1';
delete from SYS.DEFAULT_PWD$  where user_name='GLS2' and
pwd_verifier='319E08C55B04C672';
delete from SYS.DEFAULT_PWD$  where user_name='GLS3' and
pwd_verifier='A7699C43BB136229';
delete from SYS.DEFAULT_PWD$  where user_name='GLS4' and
pwd_verifier='7C171E6980BE2DB9';
delete from SYS.DEFAULT_PWD$  where user_name='GM_AWDA' and
pwd_verifier='4A06A107E7A3BB10';
delete from SYS.DEFAULT_PWD$  where user_name='GM_COPI' and
pwd_verifier='03929AE296BAAFF2';
delete from SYS.DEFAULT_PWD$  where user_name='GM_DPHD' and
pwd_verifier='0519252EDF68FA86';
delete from SYS.DEFAULT_PWD$  where user_name='GM_MLCT' and
pwd_verifier='24E8B569E8D1E93E';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLADMA' and
pwd_verifier='2946218A27B554D8';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLADMH' and
pwd_verifier='2F6EDE96313AF1B7';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLCCA' and
pwd_verifier='7A99244B545A038D';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLCCH' and
pwd_verifier='770D9045741499E6';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLCOMA' and
pwd_verifier='91524D7DE2B789A8';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLCOMH' and
pwd_verifier='FC1C6E0864BF0AF2';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLCONA' and
pwd_verifier='1F531397B19B1E05';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLCONH' and
pwd_verifier='C5FE216EB8FCD023';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLNSCA' and
pwd_verifier='DB9DD2361D011A30';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLNSCH' and
pwd_verifier='C80D557351110D51';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLSCTA' and
pwd_verifier='3A778986229BA20C';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLSCTH' and
pwd_verifier='9E50865473B63347';
delete from SYS.DEFAULT_PWD$  where user_name='GM_PLVET' and
pwd_verifier='674885FDB93D34B9';
delete from SYS.DEFAULT_PWD$  where user_name='GM_SPO' and
pwd_verifier='E57D4BD77DAF92F0';
delete from SYS.DEFAULT_PWD$  where user_name='GM_STKH' and
pwd_verifier='C498A86BE2663899';
delete from SYS.DEFAULT_PWD$  where user_name='GMA' and
pwd_verifier='DC7948E807DFE242';
delete from SYS.DEFAULT_PWD$  where user_name='GMD' and
pwd_verifier='E269165256F22F01';
delete from SYS.DEFAULT_PWD$  where user_name='GME' and
pwd_verifier='B2F0E221F45A228F';
delete from SYS.DEFAULT_PWD$  where user_name='GMF' and
pwd_verifier='A07F1956E3E468E1';
delete from SYS.DEFAULT_PWD$  where user_name='GMI' and
pwd_verifier='82542940B0CF9C16';
delete from SYS.DEFAULT_PWD$  where user_name='GML' and
pwd_verifier='5F1869AD455BBA73';
delete from SYS.DEFAULT_PWD$  where user_name='GMP' and
pwd_verifier='450793ACFCC7B58E';
delete from SYS.DEFAULT_PWD$  where user_name='GMS' and
pwd_verifier='E654261035504804';
delete from SYS.DEFAULT_PWD$  where user_name='GR' and
pwd_verifier='F5AB0AA3197AEE42';
delete from SYS.DEFAULT_PWD$  where user_name='GUEST' and
pwd_verifier='1C0A090E404CECD0';
delete from SYS.DEFAULT_PWD$  where user_name='HCC' and
pwd_verifier='25A25A7FEFAC17B6';
delete from SYS.DEFAULT_PWD$  where user_name='HHCFO' and
pwd_verifier='62DF37933FB35E9F';
delete from SYS.DEFAULT_PWD$  where user_name='HR' and
pwd_verifier='4C6D73C3E8B0F0DA';
delete from SYS.DEFAULT_PWD$  where user_name='HRI' and
pwd_verifier='49A3A09B8FC291D0';
delete from SYS.DEFAULT_PWD$  where user_name='HXC' and
pwd_verifier='4CEA0BF02214DA55';
delete from SYS.DEFAULT_PWD$  where user_name='HXT' and
pwd_verifier='169018EB8E2C4A77';
delete from SYS.DEFAULT_PWD$  where user_name='IA' and
pwd_verifier='42C7EAFBCEEC09CC';
delete from SYS.DEFAULT_PWD$  where user_name='IBA' and
pwd_verifier='0BD475D5BF449C63';
delete from SYS.DEFAULT_PWD$  where user_name='IBC' and
pwd_verifier='9FB08604A30A4951';
delete from SYS.DEFAULT_PWD$  where user_name='IBE' and
pwd_verifier='9D41D2B3DD095227';
delete from SYS.DEFAULT_PWD$  where user_name='IBP' and
pwd_verifier='840267B7BD30C82E';
delete from SYS.DEFAULT_PWD$  where user_name='IBU' and
pwd_verifier='0AD9ABABC74B3057';
delete from SYS.DEFAULT_PWD$  where user_name='IBY' and
pwd_verifier='F483A48F6A8C51EC';
delete from SYS.DEFAULT_PWD$  where user_name='ICX' and
pwd_verifier='7766E887AF4DCC46';
delete from SYS.DEFAULT_PWD$  where user_name='IEB' and
pwd_verifier='A695699F0F71C300';
delete from SYS.DEFAULT_PWD$  where user_name='IEC' and
pwd_verifier='CA39F929AF0A2DEC';
delete from SYS.DEFAULT_PWD$  where user_name='IEM' and
pwd_verifier='37EF7B2DD17279B5';
delete from SYS.DEFAULT_PWD$  where user_name='IEO' and
pwd_verifier='E93196E9196653F1';
delete from SYS.DEFAULT_PWD$  where user_name='IES' and
pwd_verifier='30802533ADACFE14';
delete from SYS.DEFAULT_PWD$  where user_name='IEU' and
pwd_verifier='5D0E790B9E882230';
delete from SYS.DEFAULT_PWD$  where user_name='IEX' and
pwd_verifier='6CC978F56D21258D';
delete from SYS.DEFAULT_PWD$  where user_name='IGC' and
pwd_verifier='D33CEB8277F25346';
delete from SYS.DEFAULT_PWD$  where user_name='IGF' and
pwd_verifier='1740079EFF46AB81';
delete from SYS.DEFAULT_PWD$  where user_name='IGI' and
pwd_verifier='8C69D50E9D92B9D0';
delete from SYS.DEFAULT_PWD$  where user_name='IGS' and
pwd_verifier='DAF602231281B5AC';
delete from SYS.DEFAULT_PWD$  where user_name='IGW' and
pwd_verifier='B39565F4E3CF744B';
delete from SYS.DEFAULT_PWD$  where user_name='IMC' and
pwd_verifier='C7D0B9CDE0B42C73';
delete from SYS.DEFAULT_PWD$  where user_name='IMT' and
pwd_verifier='E4AAF998653C9A72';
delete from SYS.DEFAULT_PWD$  where user_name='INS1 ' and
pwd_verifier='2ADC32A0B154F897';
delete from SYS.DEFAULT_PWD$  where user_name='INS2 ' and
pwd_verifier='EA372A684B790E2A';
delete from SYS.DEFAULT_PWD$  where user_name='INTERNET_APPSERVER_REGISTRY' and
pwd_verifier='A1F98A977FFD73CD';
delete from SYS.DEFAULT_PWD$  where user_name='INV' and
pwd_verifier='ACEAB015589CF4BC';
delete from SYS.DEFAULT_PWD$  where user_name='IP' and
pwd_verifier='D29012C144B58A40';
delete from SYS.DEFAULT_PWD$  where user_name='IPA' and
pwd_verifier='EB265A08759A15B4';
delete from SYS.DEFAULT_PWD$  where user_name='IPD' and
pwd_verifier='066A2E3072C1F2F3';
delete from SYS.DEFAULT_PWD$  where user_name='ISC' and
pwd_verifier='373F527DC0CFAE98';
delete from SYS.DEFAULT_PWD$  where user_name='ISTEWARD' and
pwd_verifier='8735CA4085DE3EEA';
delete from SYS.DEFAULT_PWD$  where user_name='ITG' and
pwd_verifier='D90F98746B68E6CA';
delete from SYS.DEFAULT_PWD$  where user_name='JA' and
pwd_verifier='9AC2B58153C23F3D';
delete from SYS.DEFAULT_PWD$  where user_name='JD7333' and
pwd_verifier='FB5B8A12AE623D52';
delete from SYS.DEFAULT_PWD$  where user_name='JD7334' and
pwd_verifier='322810FCE43285D9';
delete from SYS.DEFAULT_PWD$  where user_name='JD9' and
pwd_verifier='9BFAEC92526D027B';
delete from SYS.DEFAULT_PWD$  where user_name='JDE' and
pwd_verifier='7566DC952E73E869';
delete from SYS.DEFAULT_PWD$  where user_name='JDEDBA' and
pwd_verifier='B239DD5313303B1D';
delete from SYS.DEFAULT_PWD$  where user_name='JE' and
pwd_verifier='FBB3209FD6280E69';
delete from SYS.DEFAULT_PWD$  where user_name='JG' and
pwd_verifier='37A99698752A1CF1';
delete from SYS.DEFAULT_PWD$  where user_name='JL' and
pwd_verifier='489B61E488094A8D';
delete from SYS.DEFAULT_PWD$  where user_name='JOHNINARI' and
pwd_verifier='B3AD4DA00F9120CE';
delete from SYS.DEFAULT_PWD$  where user_name='JONES' and
pwd_verifier='B9E99443032F059D';
delete from SYS.DEFAULT_PWD$  where user_name='JTF' and
pwd_verifier='5C5F6FC2EBB94124';
delete from SYS.DEFAULT_PWD$  where user_name='JTI' and
pwd_verifier='B8F03D3E72C96F71';
delete from SYS.DEFAULT_PWD$  where user_name='JTM' and
pwd_verifier='6D79A2259D5B4B5A';
delete from SYS.DEFAULT_PWD$  where user_name='JTR' and
pwd_verifier='B4E2BE38B556048F';
delete from SYS.DEFAULT_PWD$  where user_name='JTS' and
pwd_verifier='4087EE6EB7F9CD7C';
delete from SYS.DEFAULT_PWD$  where user_name='JUNK_PS' and
pwd_verifier='BBC38DB05D2D3A7A';
delete from SYS.DEFAULT_PWD$  where user_name='JUSTOSHUM' and
pwd_verifier='53369CD63902FAAA';
delete from SYS.DEFAULT_PWD$  where user_name='KELLYJONES' and
pwd_verifier='DD4A3FF809D2A6CF';
delete from SYS.DEFAULT_PWD$  where user_name='KEVINDONS' and
pwd_verifier='7C6D9540B45BBC39';
delete from SYS.DEFAULT_PWD$  where user_name='KPN' and
pwd_verifier='DF0AED05DE318728';
delete from SYS.DEFAULT_PWD$  where user_name='LADAMS' and
pwd_verifier='AE542B99505CDCD2';
delete from SYS.DEFAULT_PWD$  where user_name='LBA' and
pwd_verifier='18E5E15A436E7157';
delete from SYS.DEFAULT_PWD$  where user_name='LBACSYS' and
pwd_verifier='AC9700FD3F1410EB';
delete from SYS.DEFAULT_PWD$  where user_name='LDQUAL' and
pwd_verifier='1274872AB40D4FCD';
delete from SYS.DEFAULT_PWD$  where user_name='LHILL' and
pwd_verifier='E70CA2CA0ED555F5';
delete from SYS.DEFAULT_PWD$  where user_name='LNS' and
pwd_verifier='F8D2BC61C10941B2';
delete from SYS.DEFAULT_PWD$  where user_name='LQUINCY' and
pwd_verifier='13F9B9C1372A41B6';
delete from SYS.DEFAULT_PWD$  where user_name='LSA' and
pwd_verifier='2D5E6036E3127B7E';
delete from SYS.DEFAULT_PWD$  where user_name='MDDATA' and
pwd_verifier='DF02A496267DEE66';
delete from SYS.DEFAULT_PWD$  where user_name='MDSYS' and
pwd_verifier='72979A94BAD2AF80';
delete from SYS.DEFAULT_PWD$  where user_name='MDSYS' and
pwd_verifier='9AAEB2214DCC9A31';
delete from SYS.DEFAULT_PWD$  where user_name='ME' and
pwd_verifier='E5436F7169B29E4D';
delete from SYS.DEFAULT_PWD$  where user_name='MFG' and
pwd_verifier='FC1B0DD35E790847';
delete from SYS.DEFAULT_PWD$  where user_name='MGR1 ' and
pwd_verifier='E013305AB0185A97';
delete from SYS.DEFAULT_PWD$  where user_name='MGR2' and
pwd_verifier='5ADE358F8ACE73E8';
delete from SYS.DEFAULT_PWD$  where user_name='MGR3' and
pwd_verifier='05C365C883F1251A';
delete from SYS.DEFAULT_PWD$  where user_name='MGR4' and
pwd_verifier='E229E942E8542565';
delete from SYS.DEFAULT_PWD$  where user_name='MIKEIKEGAMI' and
pwd_verifier='AAF7A168C83D5C47';
delete from SYS.DEFAULT_PWD$  where user_name='MJONES' and
pwd_verifier='EE7BB3FEA50A21C5';
delete from SYS.DEFAULT_PWD$  where user_name='MLAKE' and
pwd_verifier='7EC40274AC1609CA';
delete from SYS.DEFAULT_PWD$  where user_name='MM1' and
pwd_verifier='4418294570E152E7';
delete from SYS.DEFAULT_PWD$  where user_name='MM2' and
pwd_verifier='C06B5B28222E1E62';
delete from SYS.DEFAULT_PWD$  where user_name='MM3' and
pwd_verifier='A975B1BD0C093DA3';
delete from SYS.DEFAULT_PWD$  where user_name='MM4' and
pwd_verifier='88256901EB03A012';
delete from SYS.DEFAULT_PWD$  where user_name='MM5' and
pwd_verifier='4CEA62CBE776DCEC';
delete from SYS.DEFAULT_PWD$  where user_name='MMARTIN' and
pwd_verifier='D52F60115FE87AA4';
delete from SYS.DEFAULT_PWD$  where user_name='MOBILEADMIN' and
pwd_verifier='253922686A4A45CC';
delete from SYS.DEFAULT_PWD$  where user_name='MRP' and
pwd_verifier='B45D4DF02D4E0C85';
delete from SYS.DEFAULT_PWD$  where user_name='MSC' and
pwd_verifier='89A8C104725367B2';
delete from SYS.DEFAULT_PWD$  where user_name='MSD' and
pwd_verifier='6A29482069E23675';
delete from SYS.DEFAULT_PWD$  where user_name='MSO' and
pwd_verifier='3BAA3289DB35813C';
delete from SYS.DEFAULT_PWD$  where user_name='MSR' and
pwd_verifier='C9D53D00FE77D813';
delete from SYS.DEFAULT_PWD$  where user_name='MST' and
pwd_verifier='A96D2408F62BE1BC';
delete from SYS.DEFAULT_PWD$  where user_name='MWA' and
pwd_verifier='1E2F06BE2A1D41A6';
delete from SYS.DEFAULT_PWD$  where user_name='NEILKATSU' and
pwd_verifier='1F625BB9FEBC7617';
delete from SYS.DEFAULT_PWD$  where user_name='OBJ7333' and
pwd_verifier='D7BDC9748AFEDB52';
delete from SYS.DEFAULT_PWD$  where user_name='OBJ7334' and
pwd_verifier='EB6C5E9DB4643CAC';
delete from SYS.DEFAULT_PWD$  where user_name='OBJB733' and
pwd_verifier='61737A9F7D54EF5F';
delete from SYS.DEFAULT_PWD$  where user_name='OCA' and
pwd_verifier='9BC450E4C6569492';
delete from SYS.DEFAULT_PWD$  where user_name='ODM' and
pwd_verifier='C252E8FA117AF049';
delete from SYS.DEFAULT_PWD$  where user_name='ODM_MTR' and
pwd_verifier='A7A32CD03D3CE8D5';
delete from SYS.DEFAULT_PWD$  where user_name='ODS' and
pwd_verifier='89804494ADFC71BC';
delete from SYS.DEFAULT_PWD$  where user_name='ODSCOMMON' and
pwd_verifier='59BBED977430C1A8';
delete from SYS.DEFAULT_PWD$  where user_name='OE' and
pwd_verifier='D1A2DFC623FDA40A';
delete from SYS.DEFAULT_PWD$  where user_name='OKB' and
pwd_verifier='A01A5F0698FC9E31';
delete from SYS.DEFAULT_PWD$  where user_name='OKC' and
pwd_verifier='31C1DDF4D5D63FE6';
delete from SYS.DEFAULT_PWD$  where user_name='OKE' and
pwd_verifier='B7C1BB95646C16FE';
delete from SYS.DEFAULT_PWD$  where user_name='OKI' and
pwd_verifier='991C817E5FD0F35A';
delete from SYS.DEFAULT_PWD$  where user_name='OKL' and
pwd_verifier='DE058868E3D2B966';
delete from SYS.DEFAULT_PWD$  where user_name='OKO' and
pwd_verifier='6E204632EC7CA65D';
delete from SYS.DEFAULT_PWD$  where user_name='OKR' and
pwd_verifier='BB0E28666845FCDC';
delete from SYS.DEFAULT_PWD$  where user_name='OKS' and
pwd_verifier='C2B4C76AB8257DF5';
delete from SYS.DEFAULT_PWD$  where user_name='OKX' and
pwd_verifier='F9FDEB0DE52F5D6B';
delete from SYS.DEFAULT_PWD$  where user_name='OL810' and
pwd_verifier='E2DA59561CBD0296';
delete from SYS.DEFAULT_PWD$  where user_name='OL811' and
pwd_verifier='B3E88767A01403F8';
delete from SYS.DEFAULT_PWD$  where user_name='OL812' and
pwd_verifier='AE8C7989346785BA';
delete from SYS.DEFAULT_PWD$  where user_name='OL9' and
pwd_verifier='17EC83E44FB7DB5B';
delete from SYS.DEFAULT_PWD$  where user_name='OLAPSYS' and
pwd_verifier='3FB8EF9DB538647C';
delete from SYS.DEFAULT_PWD$  where user_name='ONT' and
pwd_verifier='9E3C81574654100A';
delete from SYS.DEFAULT_PWD$  where user_name='OPI' and
pwd_verifier='1BF23812A0AEEDA0';
delete from SYS.DEFAULT_PWD$  where user_name='ORABAM' and
pwd_verifier='D0A4EA93EF21CE25';
delete from SYS.DEFAULT_PWD$  where user_name='ORABAMSAMPLES' and
pwd_verifier='507F11063496F222';
delete from SYS.DEFAULT_PWD$  where user_name='ORABPEL' and
pwd_verifier='26EFDE0C9C051988';
delete from SYS.DEFAULT_PWD$  where user_name='ORAESB' and
pwd_verifier='CC7FCCB3A1719EDA';
delete from SYS.DEFAULT_PWD$  where user_name='ORAOCA_PUBLIC' and
pwd_verifier='FA99021634DDC111';
delete from SYS.DEFAULT_PWD$  where user_name='ORASAGENT' and
pwd_verifier='234B6F4505AD8F25';
delete from SYS.DEFAULT_PWD$  where user_name='ORASSO' and
pwd_verifier='F3701A008AA578CF';
delete from SYS.DEFAULT_PWD$  where user_name='ORASSO_DS' and
pwd_verifier='17DC8E02BC75C141';
delete from SYS.DEFAULT_PWD$  where user_name='ORASSO_PA' and
pwd_verifier='133F8D161296CB8F';
delete from SYS.DEFAULT_PWD$  where user_name='ORASSO_PS' and
pwd_verifier='63BB534256053305';
delete from SYS.DEFAULT_PWD$  where user_name='ORASSO_PUBLIC' and
pwd_verifier='C6EED68A8F75F5D3';
delete from SYS.DEFAULT_PWD$  where user_name='ORDPLUGINS' and
pwd_verifier='88A2B2C183431F00';
delete from SYS.DEFAULT_PWD$  where user_name='ORDSYS' and
pwd_verifier='7EFA02EC7EA6B86F';
delete from SYS.DEFAULT_PWD$  where user_name='OSM' and
pwd_verifier='106AE118841A5D8C';
delete from SYS.DEFAULT_PWD$  where user_name='OTA' and
pwd_verifier='F5E498AC7009A217';
delete from SYS.DEFAULT_PWD$  where user_name='OUTLN' and
pwd_verifier='4A3BA55E08595C81';
delete from SYS.DEFAULT_PWD$  where user_name='OWAPUB' and
pwd_verifier='6696361B64F9E0A9';
delete from SYS.DEFAULT_PWD$  where user_name='OWF_MGR' and
pwd_verifier='3CBED37697EB01D1';
delete from SYS.DEFAULT_PWD$  where user_name='OZF' and
pwd_verifier='970B962D942D0C75';
delete from SYS.DEFAULT_PWD$  where user_name='OZP' and
pwd_verifier='B650B1BB35E86863';
delete from SYS.DEFAULT_PWD$  where user_name='OZS' and
pwd_verifier='0DABFF67E0D33623';
delete from SYS.DEFAULT_PWD$  where user_name='PA' and
pwd_verifier='8CE2703752DB36D8';
delete from SYS.DEFAULT_PWD$  where user_name='PABLO' and
pwd_verifier='5E309CB43FE2C2FF';
delete from SYS.DEFAULT_PWD$  where user_name='PAIGE' and
pwd_verifier='02B6B704DFDCE620';
delete from SYS.DEFAULT_PWD$  where user_name='PAM' and
pwd_verifier='1383324A0068757C';
delete from SYS.DEFAULT_PWD$  where user_name='PARRISH' and
pwd_verifier='79193FDACFCE46F6';
delete from SYS.DEFAULT_PWD$  where user_name='PARSON' and
pwd_verifier='AE28B2BD64720CD7';
delete from SYS.DEFAULT_PWD$  where user_name='PAT' and
pwd_verifier='DD20769D59F4F7BF';
delete from SYS.DEFAULT_PWD$  where user_name='PATORILY' and
pwd_verifier='46B7664BD15859F9';
delete from SYS.DEFAULT_PWD$  where user_name='PATRICKSANCHEZ' and
pwd_verifier='47F74BD3AD4B5F0A';
delete from SYS.DEFAULT_PWD$  where user_name='PATSY' and
pwd_verifier='4A63F91FEC7980B7';
delete from SYS.DEFAULT_PWD$  where user_name='PAUL' and
pwd_verifier='35EC0362643ADD3F';
delete from SYS.DEFAULT_PWD$  where user_name='PAULA' and
pwd_verifier='BB0DC58A94C17805';
delete from SYS.DEFAULT_PWD$  where user_name='PAXTON' and
pwd_verifier='4EB5D8FAD3434CCC';
delete from SYS.DEFAULT_PWD$  where user_name='PCA1' and
pwd_verifier='8B2E303DEEEEA0C0';
delete from SYS.DEFAULT_PWD$  where user_name='PCA2' and
pwd_verifier='7AD6CE22462A5781';
delete from SYS.DEFAULT_PWD$  where user_name='PCA3' and
pwd_verifier='B8194D12FD4F537D';
delete from SYS.DEFAULT_PWD$  where user_name='PCA4' and
pwd_verifier='83AD05F1D0B0C603';
delete from SYS.DEFAULT_PWD$  where user_name='PCS1' and
pwd_verifier='2BE6DD3D1DEA4A16';
delete from SYS.DEFAULT_PWD$  where user_name='PCS2' and
pwd_verifier='78117145145592B1';
delete from SYS.DEFAULT_PWD$  where user_name='PCS3' and
pwd_verifier='F48449F028A065B1';
delete from SYS.DEFAULT_PWD$  where user_name='PCS4' and
pwd_verifier='E1385509C0B16BED';
delete from SYS.DEFAULT_PWD$  where user_name='PD7333' and
pwd_verifier='5FFAD8604D9DC00F';
delete from SYS.DEFAULT_PWD$  where user_name='PD7334' and
pwd_verifier='CDCF262B5EE254E1';
delete from SYS.DEFAULT_PWD$  where user_name='PD810' and
pwd_verifier='EB04A177A74C6BCB';
delete from SYS.DEFAULT_PWD$  where user_name='PD811' and
pwd_verifier='3B3C0EFA4F20AC37';
delete from SYS.DEFAULT_PWD$  where user_name='PD812' and
pwd_verifier='E73A81DB32776026';
delete from SYS.DEFAULT_PWD$  where user_name='PD9' and
pwd_verifier='CACEB3F9EA16B9B7';
delete from SYS.DEFAULT_PWD$  where user_name='PDA1' and
pwd_verifier='C7703B70B573D20F';
delete from SYS.DEFAULT_PWD$  where user_name='PEARL' and
pwd_verifier='E0AFD95B9EBD0261';
delete from SYS.DEFAULT_PWD$  where user_name='PEG' and
pwd_verifier='20577ED9A8DB8D22';
delete from SYS.DEFAULT_PWD$  where user_name='PENNY' and
pwd_verifier='BB6103E073D7B811';
delete from SYS.DEFAULT_PWD$  where user_name='PEOPLE' and
pwd_verifier='613459773123B38A';
delete from SYS.DEFAULT_PWD$  where user_name='PERCY' and
pwd_verifier='EB9E8B33A2DDFD11';
delete from SYS.DEFAULT_PWD$  where user_name='PERRY' and
pwd_verifier='D62B14B93EE176B6';
delete from SYS.DEFAULT_PWD$  where user_name='PETE' and
pwd_verifier='4040619819A9C76E';
delete from SYS.DEFAULT_PWD$  where user_name='PEYTON' and
pwd_verifier='B7127140004677FC';
delete from SYS.DEFAULT_PWD$  where user_name='PHIL' and
pwd_verifier='181446AE258EE2F6';
delete from SYS.DEFAULT_PWD$  where user_name='PJI' and
pwd_verifier='5024B1B412CD4AB9';
delete from SYS.DEFAULT_PWD$  where user_name='PJM' and
pwd_verifier='021B05DBB892D11F';
delete from SYS.DEFAULT_PWD$  where user_name='PMI' and
pwd_verifier='A7F7978B21A6F65E';
delete from SYS.DEFAULT_PWD$  where user_name='PN' and
pwd_verifier='D40D0FEF9C8DC624';
delete from SYS.DEFAULT_PWD$  where user_name='PO' and
pwd_verifier='355CBEC355C10FEF';
delete from SYS.DEFAULT_PWD$  where user_name='POA' and
pwd_verifier='2AB40F104D8517A0';
delete from SYS.DEFAULT_PWD$  where user_name='POLLY' and
pwd_verifier='ABC770C112D23DBE';
delete from SYS.DEFAULT_PWD$  where user_name='POM' and
pwd_verifier='123CF56E05D4EF3C';
delete from SYS.DEFAULT_PWD$  where user_name='PON' and
pwd_verifier='582090FD3CC44DA3';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL' and
pwd_verifier='A96255A27EC33614';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL_APP' and
pwd_verifier='831A79AFB0BD29EC';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL_DEMO' and
pwd_verifier='A0A3A6A577A931A3';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL_PUBLIC' and
pwd_verifier='70A9169655669CE8';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL30' and
pwd_verifier='969F9C3839672C6D';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL30_DEMO' and
pwd_verifier='CFD1302A7F832068';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL30_PUBLIC' and
pwd_verifier='42068201613CA6E2';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL30_SSO' and
pwd_verifier='882B80B587FCDBC8';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL30_SSO_PS' and
pwd_verifier='F2C3DC8003BC90F8';
delete from SYS.DEFAULT_PWD$  where user_name='PORTAL30_SSO_PUBLIC' and
pwd_verifier='98741BDA2AC7FFB2';
delete from SYS.DEFAULT_PWD$  where user_name='POS' and
pwd_verifier='6F6675F272217CF7';
delete from SYS.DEFAULT_PWD$  where user_name='PPM1' and
pwd_verifier='AA4AE24987D0E84B';
delete from SYS.DEFAULT_PWD$  where user_name='PPM2' and
pwd_verifier='4023F995FF78077C';
delete from SYS.DEFAULT_PWD$  where user_name='PPM3' and
pwd_verifier='12F56FADDA87BBF9';
delete from SYS.DEFAULT_PWD$  where user_name='PPM4' and
pwd_verifier='84E17CB7A3B0E769';
delete from SYS.DEFAULT_PWD$  where user_name='PPM5' and
pwd_verifier='804C159C660F902C';
delete from SYS.DEFAULT_PWD$  where user_name='PRISTB733' and
pwd_verifier='1D1BCF8E03151EF5';
delete from SYS.DEFAULT_PWD$  where user_name='PRISTCTL' and
pwd_verifier='78562A983A2F78FB';
delete from SYS.DEFAULT_PWD$  where user_name='PRISTDTA' and
pwd_verifier='3FCBC379C8FE079C';
delete from SYS.DEFAULT_PWD$  where user_name='PRODB733' and
pwd_verifier='9CCD49EB30CB80C4';
delete from SYS.DEFAULT_PWD$  where user_name='PRODCTL' and
pwd_verifier='E5DE2F01529AE93C';
delete from SYS.DEFAULT_PWD$  where user_name='PRODDTA' and
pwd_verifier='2A97CD2281B256BA';
delete from SYS.DEFAULT_PWD$  where user_name='PRODUSER' and
pwd_verifier='752E503EFBF2C2CA';
delete from SYS.DEFAULT_PWD$  where user_name='PROJMFG' and
pwd_verifier='34D61E5C9BC7147E';
delete from SYS.DEFAULT_PWD$  where user_name='PRP' and
pwd_verifier='C1C4328F8862BC16';
delete from SYS.DEFAULT_PWD$  where user_name='PS' and
pwd_verifier='0AE52ADF439D30BD';
delete from SYS.DEFAULT_PWD$  where user_name='PS810' and
pwd_verifier='90C0BEC7CA10777E';
delete from SYS.DEFAULT_PWD$  where user_name='PS810CTL' and
pwd_verifier='D32CCE5BDCD8B9F9';
delete from SYS.DEFAULT_PWD$  where user_name='PS810DTA' and
pwd_verifier='AC0B7353A58FC778';
delete from SYS.DEFAULT_PWD$  where user_name='PS811' and
pwd_verifier='B5A174184403822F';
delete from SYS.DEFAULT_PWD$  where user_name='PS811CTL' and
pwd_verifier='18EDE0C5CCAE4C5A';
delete from SYS.DEFAULT_PWD$  where user_name='PS811DTA' and
pwd_verifier='7961547C7FB96920';
delete from SYS.DEFAULT_PWD$  where user_name='PS812' and
pwd_verifier='39F0304F007D92C8';
delete from SYS.DEFAULT_PWD$  where user_name='PS812CTL' and
pwd_verifier='E39B1CE3456ECBE5';
delete from SYS.DEFAULT_PWD$  where user_name='PS812DTA' and
pwd_verifier='3780281C933FE164';
delete from SYS.DEFAULT_PWD$  where user_name='PSA' and
pwd_verifier='FF4B266F9E61F911';
delete from SYS.DEFAULT_PWD$  where user_name='PSB' and
pwd_verifier='28EE1E024FC55E66';
delete from SYS.DEFAULT_PWD$  where user_name='PSBASS' and
pwd_verifier='F739804B718D4406';
delete from SYS.DEFAULT_PWD$  where user_name='PSEM' and
pwd_verifier='40ACD8C0F1466A57';
delete from SYS.DEFAULT_PWD$  where user_name='PSFT' and
pwd_verifier='7B07F6F3EC08E30D';
delete from SYS.DEFAULT_PWD$  where user_name='PSFTDBA' and
pwd_verifier='E1ECD83073C4E134';
delete from SYS.DEFAULT_PWD$  where user_name='PSP' and
pwd_verifier='4FE07360D435E2F0';
delete from SYS.DEFAULT_PWD$  where user_name='PTADMIN ' and
pwd_verifier='4C35813E45705EBA';
delete from SYS.DEFAULT_PWD$  where user_name='PTCNE ' and
pwd_verifier='463AEFECBA55BEE8';
delete from SYS.DEFAULT_PWD$  where user_name='PTDMO ' and
pwd_verifier='251D71390034576A';
delete from SYS.DEFAULT_PWD$  where user_name='PTE' and
pwd_verifier='380FDDB696F0F266';
delete from SYS.DEFAULT_PWD$  where user_name='PTESP ' and
pwd_verifier='5553404C13601916';
delete from SYS.DEFAULT_PWD$  where user_name='PTFRA ' and
pwd_verifier='A360DAD317F583E3';
delete from SYS.DEFAULT_PWD$  where user_name='PTG' and
pwd_verifier='7AB0D62E485C9A3D';
delete from SYS.DEFAULT_PWD$  where user_name='PTGER ' and
pwd_verifier='C8D1296B4DF96518';
delete from SYS.DEFAULT_PWD$  where user_name='PTJPN' and
pwd_verifier='2159C2EAF20011BF';
delete from SYS.DEFAULT_PWD$  where user_name='PTUKE ' and
pwd_verifier='D0EF510BCB2992A3';
delete from SYS.DEFAULT_PWD$  where user_name='PTUPG ' and
pwd_verifier='2C27080C7CC57D06';
delete from SYS.DEFAULT_PWD$  where user_name='PTWEB ' and
pwd_verifier='8F7F509D4DC01DF6';
delete from SYS.DEFAULT_PWD$  where user_name='PTWEBSERVER' and
pwd_verifier='3C8050536003278B';
delete from SYS.DEFAULT_PWD$  where user_name='PV' and
pwd_verifier='76224BCC80895D3D';
delete from SYS.DEFAULT_PWD$  where user_name='PY7333' and
pwd_verifier='2A9C53FE066B852F';
delete from SYS.DEFAULT_PWD$  where user_name='PY7334' and
pwd_verifier='F3BBFAE0DDC5F7AC';
delete from SYS.DEFAULT_PWD$  where user_name='PY810' and
pwd_verifier='95082D35E94B88C2';
delete from SYS.DEFAULT_PWD$  where user_name='PY811' and
pwd_verifier='DC548D6438E4D6B7';
delete from SYS.DEFAULT_PWD$  where user_name='PY812' and
pwd_verifier='99C575A55E9FDA63';
delete from SYS.DEFAULT_PWD$  where user_name='PY9' and
pwd_verifier='B8D4E503D0C4FCFD';
delete from SYS.DEFAULT_PWD$  where user_name='QA' and
pwd_verifier='C7AEAA2D59EB1EAE';
delete from SYS.DEFAULT_PWD$  where user_name='QOT' and
pwd_verifier='B27D0E5BA4DC8DEA';
delete from SYS.DEFAULT_PWD$  where user_name='QP' and
pwd_verifier='10A40A72991DCA15';
delete from SYS.DEFAULT_PWD$  where user_name='QRM' and
pwd_verifier='098286E4200B22DE';
delete from SYS.DEFAULT_PWD$  where user_name='QS' and
pwd_verifier='4603BCD2744BDE4F';
delete from SYS.DEFAULT_PWD$  where user_name='QS_ADM' and
pwd_verifier='3990FB418162F2A0';
delete from SYS.DEFAULT_PWD$  where user_name='QS_CB' and
pwd_verifier='870C36D8E6CD7CF5';
delete from SYS.DEFAULT_PWD$  where user_name='QS_CBADM' and
pwd_verifier='20E788F9D4F1D92C';
delete from SYS.DEFAULT_PWD$  where user_name='QS_CS' and
pwd_verifier='2CA6D0FC25128CF3';
delete from SYS.DEFAULT_PWD$  where user_name='QS_ES' and
pwd_verifier='9A5F2D9F5D1A9EF4';
delete from SYS.DEFAULT_PWD$  where user_name='QS_OS' and
pwd_verifier='0EF5997DC2638A61';
delete from SYS.DEFAULT_PWD$  where user_name='QS_WS' and
pwd_verifier='0447F2F756B4F460';
delete from SYS.DEFAULT_PWD$  where user_name='RENE' and
pwd_verifier='9AAD141AB0954CF0';
delete from SYS.DEFAULT_PWD$  where user_name='REPADMIN' and
pwd_verifier='915C93F34954F5F8';
delete from SYS.DEFAULT_PWD$  where user_name='REPORTS' and
pwd_verifier='0D9D14FE6653CF69';
delete from SYS.DEFAULT_PWD$  where user_name='REPORTS_USER' and
pwd_verifier='635074B4416CD3AC';
delete from SYS.DEFAULT_PWD$  where user_name='RESTRICTED_US' and
pwd_verifier='E7E67B60CFAFBB2D';
delete from SYS.DEFAULT_PWD$  where user_name='RG' and
pwd_verifier='0FAA06DA0F42F21F';
delete from SYS.DEFAULT_PWD$  where user_name='RHX' and
pwd_verifier='FFDF6A0C8C96E676';
delete from SYS.DEFAULT_PWD$  where user_name='RLA' and
pwd_verifier='C1959B03F36C9BB2';
delete from SYS.DEFAULT_PWD$  where user_name='RLM' and
pwd_verifier='4B16ACDA351B557D';
delete from SYS.DEFAULT_PWD$  where user_name='RM1' and
pwd_verifier='CD43500DAB99F447';
delete from SYS.DEFAULT_PWD$  where user_name='RM2' and
pwd_verifier='2D8EE7F8857D477E';
delete from SYS.DEFAULT_PWD$  where user_name='RM3' and
pwd_verifier='1A95960A95AC2E1D';
delete from SYS.DEFAULT_PWD$  where user_name='RM4' and
pwd_verifier='651BFD4E1DE4B040';
delete from SYS.DEFAULT_PWD$  where user_name='RM5' and
pwd_verifier='FDCC34D74A22517C';
delete from SYS.DEFAULT_PWD$  where user_name='RMAN' and
pwd_verifier='E7B5D92911C831E1';
delete from SYS.DEFAULT_PWD$  where user_name='ROB' and
pwd_verifier='94405F516486CA24';
delete from SYS.DEFAULT_PWD$  where user_name='RPARKER' and
pwd_verifier='CEBFE4C41BBCC306';
delete from SYS.DEFAULT_PWD$  where user_name='RWA1' and
pwd_verifier='B07E53895E37DBBB';
delete from SYS.DEFAULT_PWD$  where user_name='SALLYH' and
pwd_verifier='21457C94616F5716';
delete from SYS.DEFAULT_PWD$  where user_name='SAM' and
pwd_verifier='4B95138CB6A4DB94';
delete from SYS.DEFAULT_PWD$  where user_name='SARAHMANDY' and
pwd_verifier='60BE21D8711EE7D9';
delete from SYS.DEFAULT_PWD$  where user_name='SCM1' and
pwd_verifier='507306749131B393';
delete from SYS.DEFAULT_PWD$  where user_name='SCM2' and
pwd_verifier='CBE8D6FAC7821E85';
delete from SYS.DEFAULT_PWD$  where user_name='SCM3' and
pwd_verifier='2B311B9CDC70F056';
delete from SYS.DEFAULT_PWD$  where user_name='SCM4' and
pwd_verifier='1FDF372790D5A016';
delete from SYS.DEFAULT_PWD$  where user_name='SCOTT' and
pwd_verifier='F894844C34402B67';
delete from SYS.DEFAULT_PWD$  where user_name='SDAVIS' and
pwd_verifier='A9A3B88C6A550559';
delete from SYS.DEFAULT_PWD$  where user_name='SECDEMO' and
pwd_verifier='009BBE8142502E10';
delete from SYS.DEFAULT_PWD$  where user_name='SEDWARDS' and
pwd_verifier='00A2EDFD7835BC43';
delete from SYS.DEFAULT_PWD$  where user_name='SELLCM' and
pwd_verifier='8318F67F72276445';
delete from SYS.DEFAULT_PWD$  where user_name='SELLER' and
pwd_verifier='B7F439E172D5C3D0';
delete from SYS.DEFAULT_PWD$  where user_name='SELLTREAS' and
pwd_verifier='6EE7BA85E9F84560';
delete from SYS.DEFAULT_PWD$  where user_name='SERVICES' and
pwd_verifier='B2BE254B514118A5';
delete from SYS.DEFAULT_PWD$  where user_name='SETUP' and
pwd_verifier='9EA55682C163B9A3';
delete from SYS.DEFAULT_PWD$  where user_name='SH' and
pwd_verifier='54B253CBBAAA8C48';
delete from SYS.DEFAULT_PWD$  where user_name='SI_INFORMTN_SCHEMA' and
pwd_verifier='84B8CBCA4D477FA3';
delete from SYS.DEFAULT_PWD$  where user_name='SID' and
pwd_verifier='CFA11E6EBA79D33E';
delete from SYS.DEFAULT_PWD$  where user_name='SKAYE' and
pwd_verifier='ED671B63BDDB6B50';
delete from SYS.DEFAULT_PWD$  where user_name='SKYTETSUKA' and
pwd_verifier='EB5DA777D1F756EC';
delete from SYS.DEFAULT_PWD$  where user_name='SLSAA' and
pwd_verifier='99064FC6A2E4BBE8';
delete from SYS.DEFAULT_PWD$  where user_name='SLSMGR' and
pwd_verifier='0ED44093917BE294';
delete from SYS.DEFAULT_PWD$  where user_name='SLSREP' and
pwd_verifier='847B6AAB9471B0A5';
delete from SYS.DEFAULT_PWD$  where user_name='SRABBITT' and
pwd_verifier='85F734E71E391DF5';
delete from SYS.DEFAULT_PWD$  where user_name='SRALPHS' and
pwd_verifier='975601AA57CBD61A';
delete from SYS.DEFAULT_PWD$  where user_name='SRAY' and
pwd_verifier='C233B26CFC5DC643';
delete from SYS.DEFAULT_PWD$  where user_name='SRIVERS' and
pwd_verifier='95FE94ADC2B39E08';
delete from SYS.DEFAULT_PWD$  where user_name='SSA1' and
pwd_verifier='DEE6E1BEB962AA8B';
delete from SYS.DEFAULT_PWD$  where user_name='SSA2' and
pwd_verifier='96CA278B20579E34';
delete from SYS.DEFAULT_PWD$  where user_name='SSA3' and
pwd_verifier='C3E8C3B002690CD4';
delete from SYS.DEFAULT_PWD$  where user_name='SSC1' and
pwd_verifier='4F7AC652CC728980';
delete from SYS.DEFAULT_PWD$  where user_name='SSC2' and
pwd_verifier='A1350B328E74AE87';
delete from SYS.DEFAULT_PWD$  where user_name='SSC3' and
pwd_verifier='EE3906EC2DA586D8';
delete from SYS.DEFAULT_PWD$  where user_name='SSOSDK' and
pwd_verifier='7C48B6FF3D54D006';
delete from SYS.DEFAULT_PWD$  where user_name='SSP' and
pwd_verifier='87470D6CE203FB4D';
delete from SYS.DEFAULT_PWD$  where user_name='SSS1' and
pwd_verifier='E78C515C31E83848';
delete from SYS.DEFAULT_PWD$  where user_name='SUPPLIER' and
pwd_verifier='2B45928C2FE77279';
delete from SYS.DEFAULT_PWD$  where user_name='SVM7333' and
pwd_verifier='04B731B0EE953972';
delete from SYS.DEFAULT_PWD$  where user_name='SVM7334' and
pwd_verifier='62E2A2E886945CC8';
delete from SYS.DEFAULT_PWD$  where user_name='SVM810' and
pwd_verifier='0A3DCD8CA3B6ABD9';
delete from SYS.DEFAULT_PWD$  where user_name='SVM811' and
pwd_verifier='2B0CD57B1091C936';
delete from SYS.DEFAULT_PWD$  where user_name='SVM812' and
pwd_verifier='778632974E3947C9';
delete from SYS.DEFAULT_PWD$  where user_name='SVM9' and
pwd_verifier='552A60D8F84441F1';
delete from SYS.DEFAULT_PWD$  where user_name='SVMB733' and
pwd_verifier='DD2BFB14346146FE';
delete from SYS.DEFAULT_PWD$  where user_name='SVP1' and
pwd_verifier='F7BF1FFECE27A834';
delete from SYS.DEFAULT_PWD$  where user_name='SY810' and
pwd_verifier='D56934CED7019318';
delete from SYS.DEFAULT_PWD$  where user_name='SY811' and
pwd_verifier='2FDC83B401477628';
delete from SYS.DEFAULT_PWD$  where user_name='SY812' and
pwd_verifier='812B8D7211E7DEF1';
delete from SYS.DEFAULT_PWD$  where user_name='SY9' and
pwd_verifier='3991E64C4BC2EC5D';
delete from SYS.DEFAULT_PWD$  where user_name='SYS' and
pwd_verifier='43CA255A7916ECFE';
delete from SYS.DEFAULT_PWD$  where user_name='SYS' and
pwd_verifier='5638228DAF52805F';
delete from SYS.DEFAULT_PWD$  where user_name='SYS' and
pwd_verifier='D4C5016086B2DC6A';
delete from SYS.DEFAULT_PWD$  where user_name='SYS7333' and
pwd_verifier='D7CDB3124F91351E';
delete from SYS.DEFAULT_PWD$  where user_name='SYS7334' and
pwd_verifier='06959F7C9850F1E3';
delete from SYS.DEFAULT_PWD$  where user_name='SYSADMIN' and
pwd_verifier='DC86E8DEAA619C1A';
delete from SYS.DEFAULT_PWD$  where user_name='SYSB733' and
pwd_verifier='7A7F5C90BEC02F0E';
delete from SYS.DEFAULT_PWD$  where user_name='SYSMAN' and
pwd_verifier='EB258E708132DD2D';
delete from SYS.DEFAULT_PWD$  where user_name='SYSTEM' and
pwd_verifier='4D27CA6E3E3066E6';
delete from SYS.DEFAULT_PWD$  where user_name='SYSTEM' and
pwd_verifier='D4DF7931AB130E37';
delete from SYS.DEFAULT_PWD$  where user_name='TDEMARCO' and
pwd_verifier='CAB71A14FA426FAE';
delete from SYS.DEFAULT_PWD$  where user_name='TDOS_ICSAP' and
pwd_verifier='7C0900F751723768';
delete from SYS.DEFAULT_PWD$  where user_name='TESTCTL' and
pwd_verifier='205FA8DF03A1B0A6';
delete from SYS.DEFAULT_PWD$  where user_name='TESTDTA' and
pwd_verifier='EEAF97B5F20A3FA3';
delete from SYS.DEFAULT_PWD$  where user_name='TRA1' and
pwd_verifier='BE8EDAE6464BA413';
delete from SYS.DEFAULT_PWD$  where user_name='TRACESVR' and
pwd_verifier='F9DA8977092B7B81';
delete from SYS.DEFAULT_PWD$  where user_name='TRBM1' and
pwd_verifier='B10ED16CD76DBB60';
delete from SYS.DEFAULT_PWD$  where user_name='TRCM1' and
pwd_verifier='530E1F53715105D0';
delete from SYS.DEFAULT_PWD$  where user_name='TRDM1' and
pwd_verifier='FB1B8EF14CF3DEE7';
delete from SYS.DEFAULT_PWD$  where user_name='TRRM1' and
pwd_verifier='4F29D85290E62EBE';
delete from SYS.DEFAULT_PWD$  where user_name='TWILLIAMS' and
pwd_verifier='6BF819CE663B8499';
delete from SYS.DEFAULT_PWD$  where user_name='UDDISYS' and
pwd_verifier='BF5E56915C3E1C64';
delete from SYS.DEFAULT_PWD$  where user_name='VEA' and
pwd_verifier='D38D161C22345902';
delete from SYS.DEFAULT_PWD$  where user_name='VEH' and
pwd_verifier='72A90A786AAE2914';
delete from SYS.DEFAULT_PWD$  where user_name='VIDEO31' and
pwd_verifier='2FA72981199F9B97';
delete from SYS.DEFAULT_PWD$  where user_name='VIDEO4' and
pwd_verifier='9E9B1524C454EEDE';
delete from SYS.DEFAULT_PWD$  where user_name='VIDEO5' and
pwd_verifier='748481CFF7BE98BB';
delete from SYS.DEFAULT_PWD$  where user_name='VP1' and
pwd_verifier='3CE03CD65316DBC7';
delete from SYS.DEFAULT_PWD$  where user_name='VP2' and
pwd_verifier='FCCEFD28824DFEC5';
delete from SYS.DEFAULT_PWD$  where user_name='VP3' and
pwd_verifier='DEA4D8290AA247B2';
delete from SYS.DEFAULT_PWD$  where user_name='VP4' and
pwd_verifier='F4730B0FA4F701DC';
delete from SYS.DEFAULT_PWD$  where user_name='VP5' and
pwd_verifier='7DD67A696734AE29';
delete from SYS.DEFAULT_PWD$  where user_name='VP6' and
pwd_verifier='45660DEE49534ADB';
delete from SYS.DEFAULT_PWD$  where user_name='WAA1' and
pwd_verifier='CF013DC80A9CBEE3';
delete from SYS.DEFAULT_PWD$  where user_name='WAA2' and
pwd_verifier='6160E7A17091741A';
delete from SYS.DEFAULT_PWD$  where user_name='WCRSYS' and
pwd_verifier='090263F40B744BD8';
delete from SYS.DEFAULT_PWD$  where user_name='WEBDB' and
pwd_verifier='D4C4DCDD41B05A5D';
delete from SYS.DEFAULT_PWD$  where user_name='WEBSYS' and
pwd_verifier='54BA0A1CB5994D64';
delete from SYS.DEFAULT_PWD$  where user_name='WENDYCHO' and
pwd_verifier='7E628CDDF051633A';
delete from SYS.DEFAULT_PWD$  where user_name='WH' and
pwd_verifier='91792EFFCB2464F9';
delete from SYS.DEFAULT_PWD$  where user_name='WIP' and
pwd_verifier='D326D25AE0A0355C';
delete from SYS.DEFAULT_PWD$  where user_name='WIRELESS' and
pwd_verifier='1495D279640E6C3A';
delete from SYS.DEFAULT_PWD$  where user_name='WIRELESS' and
pwd_verifier='EB9615631433603E';
delete from SYS.DEFAULT_PWD$  where user_name='WK_TEST' and
pwd_verifier='29802572EB547DBF';
delete from SYS.DEFAULT_PWD$  where user_name='WKPROXY' and
pwd_verifier='AA3CB2A4D9188DDB';
delete from SYS.DEFAULT_PWD$  where user_name='WKSYS' and
pwd_verifier='545E13456B7DDEA0';
delete from SYS.DEFAULT_PWD$  where user_name='WMS' and
pwd_verifier='D7837F182995E381';
delete from SYS.DEFAULT_PWD$  where user_name='WMSYS' and
pwd_verifier='7C9BA362F8314299';
delete from SYS.DEFAULT_PWD$  where user_name='WPS' and
pwd_verifier='50D22B9D18547CF7';
delete from SYS.DEFAULT_PWD$  where user_name='WSH' and
pwd_verifier='D4D76D217B02BD7A';
delete from SYS.DEFAULT_PWD$  where user_name='WSM' and
pwd_verifier='750F2B109F49CC13';
delete from SYS.DEFAULT_PWD$  where user_name='XDB' and
pwd_verifier='88D8364765FCE6AF';
delete from SYS.DEFAULT_PWD$  where user_name='XDO' and
pwd_verifier='E9DDE8ACFA7FE8E4';
delete from SYS.DEFAULT_PWD$  where user_name='XDP' and
pwd_verifier='F05E53C662835FA2';
delete from SYS.DEFAULT_PWD$  where user_name='XLA' and
pwd_verifier='2A8ED59E27D86D41';
delete from SYS.DEFAULT_PWD$  where user_name='XLE' and
pwd_verifier='CEEBE966CC6A3E39';
delete from SYS.DEFAULT_PWD$  where user_name='XNB' and
pwd_verifier='03935918FA35C993';
delete from SYS.DEFAULT_PWD$  where user_name='XNC' and
pwd_verifier='BD8EA41168F6C664';
delete from SYS.DEFAULT_PWD$  where user_name='XNI' and
pwd_verifier='F55561567EF71890';
delete from SYS.DEFAULT_PWD$  where user_name='XNM' and
pwd_verifier='92776EA17B8B5555';
delete from SYS.DEFAULT_PWD$  where user_name='XNP' and
pwd_verifier='3D1FB783F96D1F5E';
delete from SYS.DEFAULT_PWD$  where user_name='XNS' and
pwd_verifier='FABA49C38150455E';
delete from SYS.DEFAULT_PWD$  where user_name='XTR' and
pwd_verifier='A43EE9629FA90CAE';
delete from SYS.DEFAULT_PWD$  where user_name='YCAMPOS' and
pwd_verifier='C3BBC657F099A10F';
delete from SYS.DEFAULT_PWD$  where user_name='YSANCHEZ' and
pwd_verifier='E0C033C4C8CC9D84';
delete from SYS.DEFAULT_PWD$  where user_name='ZFA' and
pwd_verifier='742E092A27DDFB77';
delete from SYS.DEFAULT_PWD$  where user_name='ZPB' and
pwd_verifier='CAF58375B6D06513';
delete from SYS.DEFAULT_PWD$  where user_name='ZSA' and
pwd_verifier='AFD3BD3C7987CBB6';
delete from SYS.DEFAULT_PWD$  where user_name='ZX' and 
pwd_verifier='7B06550956254585';

drop index SYS.I_DEFAULT_PWD;

Rem *************************************************************************
Rem END Changes for Bug 7829203,default_pwd$ should not be recreated 
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN  Changes for Stats Related Dictionary Tables
Rem *************************************************************************

drop index i_wri$_optstat_synoppartgrp
/

create index i_wri$_optstat_synoppartgrp on 
  wri$_optstat_synopsis_partgrp (obj#)
  tablespace sysaux
/

drop index i_wri$_optstat_synophead 
/

create index i_wri$_optstat_synophead on 
  wri$_optstat_synopsis_head$ (bo#, group#, intcol#)
  tablespace sysaux
/


Rem *************************************************************************
Rem END  Changes for Stats Related Dictionary Tables
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN: Bug 8348017, Drop additional fields from RewriteMessage
Rem *************************************************************************

ALTER TYPE SYS.RewriteMessage DROP ATTRIBUTE
      (query_block_no,                 /* block no of the current subquery */
       rewritten_text,                             /* rewritten query text */
       mv_in_msg,                                 /* MV in current message */
       measure_in_msg,                       /* Measure in current message */
       join_back_tbl,                    /* Join back table in current msg */ 
       join_back_col,                   /* Join back column in current msg */ 
       original_cost,                               /* original query cost */ 
       rewritten_cost                              /* rewritten query cost */ 
      ) CASCADE;
  
Rem *************************************************************************
Rem END: Bug 8348017, Drop additional fields from RewriteMessage
Rem *************************************************************************

Rem**************************************************************************
Rem BEGIN LRG 5954743: kqdobflg was extended to accommodate 32 bits in 11.2
Rem**************************************************************************

update obj$ set flags = bitand(flags, 65535) where flags > 65535;

Rem**************************************************************************
Rem END LRG 5954743: kqdobflg was extended to accommodate 32 bits in 11.2
Rem**************************************************************************


Rem*************************************************************************
Rem BEGIN Changes for FILE_OPTIMIZED_HISTOGRAM
Rem*************************************************************************

drop public synonym gv$file_optimized_histogram;
drop public synonym v$file_optimized_histogram;
drop view gv_$file_optimized_histogram;
drop view v_$file_optimized_histogram;

Rem*************************************************************************
Rem END Changes for FILE_OPTIMIZED_HISTOGRAM
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for RECOVERY_AREA_USAGE
Rem*************************************************************************

drop public synonym v$recovery_area_usage;
drop view v_$recovery_area_usage;

Rem*************************************************************************
Rem END Changes for RECOVERY_AREA_USAGE
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for DATABASE VAULT USAGE
Rem*************************************************************************

drop procedure dbms_feature_database_vault;

Rem*************************************************************************
Rem END Changes for DATABASE VAULT USAGE
Rem*************************************************************************

Rem
Rem Sql dictionary check rule downgrade
Rem
update sql_tk_coll_chk$ set expr='not between 0 and 95'
where table_name = 'OBJ$'
and   col_list = 'type#'
and   expr = 'not between 0 and 101';


Rem*************************************************************************
Rem BEGIN Changes for Segment Advisor
Rem*************************************************************************

Rem reset the segment advisor property

update  wri$_adv_definitions d 
  set   property = 3
  where d.id = 5;
commit;

Rem*************************************************************************
Rem END Changes for Segment Advisor
Rem*************************************************************************

Rem*************************************************************************
Rem START Changes for dbms_xds, dbms_xdsutl
Rem*************************************************************************

drop public synonym dbms_xds;
drop public synonym dbms_xdsutl;
drop package dbms_xds;
drop package dbms_xdsutl;

Rem*************************************************************************
Rem END Changes for dbms_xds, dbms_xdsutl
Rem*************************************************************************

Rem *************************************************************************
Rem END e1101000.sql
Rem *************************************************************************

