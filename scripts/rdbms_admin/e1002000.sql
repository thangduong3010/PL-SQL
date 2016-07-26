Rem
Rem $Header: rdbms/admin/e1002000.sql /st_rdbms_11.2.0/5 2012/03/15 11:19:35 vradhakr Exp $
Rem
Rem e1002000.sql
Rem
Rem Copyright (c) 2005, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      e1002000.sql - downgrade Oracle RDBMS from current release to 10.2.0
Rem
Rem      **DO NOT ADD DOWNGRADE ACTIONS THAT CALL PL/SQL PACKAGES HERE
Rem      **THOSE ACTIONS NOW BELONG IN f1002000.sql.
Rem
Rem    DESCRIPTION
Rem
Rem
Rem      This script performs the downgrade in the following stages:
Rem        STAGE 1: downgrade from the current release to 11g;
Rem                 this stage is a no-op for 11g since the current release
Rem                 is 11.
Rem        STAGE 2: downgrade base data dictionary objects from current 
Rem                 release to 10.2
Rem                 a. remove new current release system/object privileges
Rem                 b. remove new current release catalog views/synonyms
Rem                    (previous release views will be recreated after)
Rem                 c. remove program units referring to new current 
Rem                    release fixed views or non-compiling in 10.2
Rem                 d. update new current release columns to NULL or 
Rem                    other values,delete rows from new current release
Rem                    tables, and drop new current release type attributes,
Rem                    methods, etc.
Rem                 e. downgrade system types from current release to 10.2
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vradhakr    03/13/12 - Bug 13744220: Reset FBA internal flag in tab$.
Rem    skabraha    01/12/12 - drop dbms_objects_utils package
Rem    yberezin    03/21/11 - Backport yberezin_bug-10398280 from main
Rem    avangala    03/13/11 - Bug 10117795: remove xxpflags from xpflags
Rem    pxwong      11/16/10 - Backport pxwong_bug-10096081 from main
Rem    cmlim       05/03/10 - lrg 4599562 - drop dbms_space pkg during
Rem                           downgrade
Rem    dongfwan    01/22/10 - Bug 9264020: add wrm$_snapshot_details table to AWR
Rem    liaguo      10/05/09 - Remove Flashback Archive views
Rem    achoi       04/30/09 - remove alter edition
Rem    gssmith     10/16/08 - Fix Access Advisor downgrade for 10g
Rem    achoi       09/02/08 - conditionalize dropping ora$base
Rem    sburanaw    02/05/08 - remove updates to null on AWR tables
Rem    rgmani      01/18/08 - Drop types job_definiton and job_definition_array
Rem    mtao        01/08/08 - bug 6121044: remove foreign log cf entries
Rem    cdilling    11/28/07 - move references to dbms_assert to f1002000.sql
Rem    cdilling    09/25/07 - move data mining drops to f1002000.sql
Rem    sylin       09/24/07 - move drop created class to f1002000.sql
Rem    cdilling    09/10/07 - create or replace dba_source to avoid losing APEX
Rem                           grants
Rem    pcastro     08/20/07 - lrg 3101367: drop HS table function objects
Rem    nlee        07/20/07 - Fix for bug 6059870.
Rem    cdilling    08/06/07 - call e1101000.sql for major release downgrade
Rem    rburns      07/27/07 - drop bsq table for re-upgrade
Rem    ysarig      07/12/07 - drop V$DIAG_CRITICAL_ERROR
Rem    cdilling    07/11/07 - move .downgraded calls to f scripts
Rem    tcruanes    07/11/07 - 3058493: drop dbms_sqltcb_internal package
Rem    jaeblee     07/11/07 - invalidate views and synonyms as well as
Rem                           tables dependent on public synonyms to
Rem                           recompile and recompute negative dependencies
Rem    evoss       06/18/07 - dbms scheduler feature tracking
Rem    cdilling    06/06/07 - remove drop of WWV_FLOW_VAL_LIB 
Rem    rmacnico    06/05/07 - bug 5666482: flashback logstdby
Rem    kyagoub     05/25/07 - rename spa advisor
Rem    pbelknap    05/07/07 - #6026921 - downgrade _sqltune_control
Rem    cdilling    05/22/07 - drop procedure dbms_feature_rman_zlib
Rem    cdilling    04/30/07 - fix execute immediates
Rem    shbose      05/08/07 - drop _[dba/user]_queue_schedules[_compat] views
Rem    cdilling    05/04/07 - create or replace dba_tablespaces instead of drop
Rem    sfeinste    05/03/07 - rename olap_build_processes$ to
Rem                           olap_cube_build_processes$
Rem    ushaft      04/23/07 - drop prvt_smgutil
Rem    siroych     04/30/07 - lrg 2942424: drop ASMM feature usage procedures
Rem    rmacnico    04/17/07 - bug 5496852: lsby skip on grant and revoke
Rem    bdagevil    04/24/07 - drop SQL package on downgrade
Rem    bdagevil    03/25/07 - drop SQL monitor object on downgrade
Rem    pbelknap    04/03/07 - add parsing_user_id to sqlstat_bl tables too
Rem    pbelknap    03/20/07 - remove sqlobj$probation_stats
Rem    shan        04/12/07 - remove default password table and view
Rem    pbelknap    04/19/07 - drop wrr type
Rem    akoeller    04/12/07 - Access Advisor fixes
Rem    rburns      04/06/07 - drop DBMS_INTERNAL_LOGSTDBY
Rem    hosu        04/05/07 - spm downgrade
Rem    rmacnico    04/04/07 - bug 5971328: increase col width for plsql skip
Rem    sjanardh    04/06/07 - Bug fix 5943749.
Rem    qiwang      04/02/07 - BUG 5743875: memory spill table schema change
Rem    yifeng      03/29/07 - drop OLDIMAGE_COLUMNS views
Rem    pabingha    03/29/07 - LRG 2905879 - add downgrade for Access Advisor
Rem                           Datapump Scripts
Rem    avaliani    03/28/07 - remove v$wait_chains_history
Rem    hosu        03/15/07 - drop "administer sql management object"
Rem                           privilege
Rem    sburanaw    03/02/07 - rename column top_sql* to top_level_sql* in
Rem                           WRH$_ACTIVE_SESSION_HISTORY
Rem    absaxena    03/13/07 - add reg_id to aq$_srvntfn_message
Rem    cschmidt    03/21/07 - drop streams switch packages
Rem    mbastawa    03/09/07 - drop client query cache stats
Rem    veeve       03/06/07 - NULL out flags in ASH
Rem    ssonawan    03/06/07 - bug 5609854: remove audit options 
Rem    molagapp    02/28/07 - rename remote_archived_log to foreign_archived_log
Rem    suelee      12/14/06 - Add consumer group category
Rem    jaeblee     03/06/07 - truncate table objerror$
Rem    jaeblee     03/06/07 - truncate table objerror$
Rem    rramkiss    03/06/07 - lrg 2882492 - drop timezone indexes
Rem    rgmani      03/02/07 - Fix lrgum2 dif
Rem    veeve       02/26/07 - drop dbms_feature_wcr_*
Rem    wfisher     02/07/07 - Drop ku$_list_filter_temp on downgrade
Rem    pbelknap    02/22/07 - drop new advisor sequence
Rem    vkolla      01/23/07 - use DBA_RSRC_IO_CALIBRATE
Rem    rgmani      11/29/06 - lw job downgrade
Rem    ychan       02/20/07 - Drop dbsnmp table proc
Rem    pbelknap    02/07/07 - adv fmwk finding flags
Rem    wechen      02/17/07 - rename olap_primary_dimensions$ and
Rem                           olap_interactions$ to olap_cube_dimensions$
Rem                           and olap_build_processes$
Rem    absaxena    02/16/07 - add grouping_inst_id to reg$
Rem    jmzhang     02/14/07 - lrg 2859621 drop dba_logstdby_unsupported_table
Rem    mzait       02/08/07 - replace private by pending
Rem    jinwu       01/31/07 - null creation_time in 
Rem                           streams$_propagation_process
Rem    rfrank      02/07/07 - change v$unfs -> v$dnfs
Rem    dvoss       02/08/07 - drop logmnr pkgs that use new fixed table
Rem    dvoss       02/08/07 - put back logmnr_header tables
Rem    ushaft      02/08/07 - add IC_CLIENT_STATS, IC_DEVICE_STATS,
Rem                           MEM_DYNAMIC_COMP, INTERCONNECT_PINGS
Rem    jmzhang     01/24/07 - drop lsby support and unsupport views
Rem    pbelknap    01/14/07 - drop new sqltune packages
Rem    ushaft      01/03/07 - drop new package dbms_management_packs
Rem    cdilling    01/31/07 - add drop package initjvmaux
Rem    kyagoub     01/31/07 - lrg#2849037: drop wri$_rept_xplan
Rem    ilistvin    10/19/06 - AWR report types
Rem    jkundu      01/09/07 - drop logmnr_em_support on downgrade
Rem    rfrank      01/12/07 - remove v$dnfs_channels
Rem    sjanardh    09/13/06 - Downgrade script for AQ$_SUBSCRIBER_TABLE
Rem    pstengar    12/11/06 - bug 5586631: remove MINING MODEL entries to
Rem                                        AUDIT_ACTIONS
Rem    skaluska    12/01/06 - bug 5679933: remove v$inststat
Rem    juyuan      12/15/06 - remove "_DBA_STREAMS_TABLE_COMPAT"
Rem    wxli        01/03/07 - LRG 2784117: dropping ORABASE
Rem    dmukhin     12/08/06 - bug 5557333: AR scoping
Rem    arogers     12/04/06 - 5379252 add v$process_group and v$detached_session
Rem    sackulka    12/01/06 - Drop v$securefile_timer
Rem    vakrishn    12/19/06 - do not convert 9.2 mappings - they are in GMT as
Rem                           required in 9.2
Rem    ssvemuri    12/19/06 - drop chnf_reg_info type body
Rem    rvenkate    12/12/06 - drop service usage procedure
Rem    vakrishn    12/08/06 - eliminate dups in smon_scn_time when converting
Rem                           from gmt_to_local
Rem    gviswana    12/05/06 - Flush shared pool after props$ delete
Rem    zliu        12/01/06 - add drop with force for new user defined
Rem                           operators
Rem    zliu        11/29/06 - drop xquery poly agg operators
Rem    ssvemuri    11/16/06 - query notification type change
Rem    liaguo      11/16/06 - flashback archive privilege
Rem    achoi       11/21/06 - lrg2673799: rename dbms_edition to 
Rem                           dbms_editions_utilities
Rem    bpwang      11/02/06 - drop dbms_streams_control_adm package
Rem    vkolla      11/13/06 - remove DBA_RSRC_IO_CALIBRATE
Rem    wechen      11/25/06 - remove "update any primary dimension"
Rem    kchen       11/21/06 - fixed lrg 2672412
Rem    kchen       10/30/06 - remove objects related to dbms_hs_parallel 
Rem    spsundar    11/13/06 - drop procedures odcipartinfodump
Rem    rburns      11/07/06 - add dba_invalid_objects
Rem    absaxena    11/04/06 - drop attributes from aq$_[srvntfn|event]_message
Rem    rdecker     10/26/06 - plscope tables are now in SYSAUX
Rem    banand      11/01/06 - drop rman_encryption_algorithms
Rem    ushaft      10/30/06 - remove new views and synonyms (dba_addm*)
Rem    slynn       10/12/06 - smartfile->securefile
Rem    schakkap    10/24/06 - move reference to dbms_stats package to
Rem                           f1002000.sql
Rem    schakkap    10/23/06 - drop extended stats views
Rem    slahoran    10/26/06 - Drop inststat views
Rem    achoi       08/27/06 - replace dbms_patch with dbms_edition 
Rem    gngai       10/08/06 - added downgrade for diag_info views
Rem    msakayed    10/06/06 - drop feature usage information
Rem    arogers     10/23/06 - 5572026 - Drop type SYS$RLBTYP 
Rem    achoi       09/19/06 - remove *_AE views
Rem    rburns      10/13/06 - remove more objects
Rem    rdecker     08/15/06 - delete plscope_settings
Rem    kkunchit    07/28/06 - dbms_lobutil downgrade 
Rem    ilistvin    10/11/06 - drop DBA_AUTOTASK_JOB_HISTORY view
Rem    jgalanes    10/06/06 - remove synonymns for IDR views since internal
Rem                           only
Rem    gviswana    09/28/06 - Fine-grain dependency info downgrade
Rem    ltominna    10/03/06 - lrg-2575704
Rem    kyagoub     09/28/06 - replace task parameter
Rem                           _SQLTUNE_TRACE/_TRACE_CONTROL
Rem    hosu        07/17/06 - downgrade for OPM
Rem    dvoss       09/21/06 - put back sys.logmnr_interesting_cols 
Rem    cdilling    09/14/06 - restructure to move pl/sql to f1002000.sql
Rem    kyagoub     09/10/06 - bug#5518178: extend optimizer_env size to 2000
Rem    mbastawa    09/09/06 - truncate client result cache table
Rem    akruglik    09/01/06 - CMVs became EVs
Rem    mhho        08/24/06 - Drop xs$parameters
Rem    ilistvin    09/13/06 - add alert_type downgrade
Rem    sdizdar     07/18/06 - drop v$rman_compression_algorithm
Rem    nthombre    09/04/06 - Drop V$SQLFN_METADATA v$ and gv$ views
Rem    eshirk      07/14/06 - Add private_jdbc package 
Rem    mabhatta    09/06/06 - drop v$flashback_txn_ fixed views
Rem    nthombre    09/05/06 - Drop gv$ & v$sqlfn_arg_metadata for downgrade
Rem    pbelknap    08/28/06 - fix order of drop report fmwk types
Rem    ciyer       08/05/06 - audit support for edition objects
Rem    sburanaw    08/04/06 - drop current_row#
Rem    pstengar    08/29/06 - remove rename audit option for mining models
Rem    wesmith     08/18/06 - drop "_DBA_TRIGGER_ORDERING"
Rem    jaeblee     08/10/06 - unset spare1 field for PUBLIC in user$
Rem    adalee      08/14/06 - drop v$encrypted_tablespaces and
Rem                           gv$encrypted_tablespaces
Rem    atsukerm    08/21/06 - drop tablespace views
Rem    jcarey      08/17/06 - drop aw_trunc_trg lrg 2400463
Rem    veeve       08/18/06 - fix lrg 2503348
Rem    wechen      08/14/06 - remove OLAP API system privileges
Rem    jsoule      08/11/06 - fix truncate table typo
Rem    rfrank      08/15/06 - drop unfs views, synonyms
Rem    pbelknap    08/08/06 - add sqlt report type
Rem    ushaft      08/03/06 - null out new column in wrh$_pga_target_advice
Rem    mlfeng      07/21/06 - remove interconnect stats 
Rem    mmcracke    08/07/06 - Remove OC persistence types (data mining)
Rem    bkuchibh    08/03/06 - drop incmeter synonyms
Rem    dvoss       08/02/06 - drop new logmnr views
Rem    dvoss       05/01/06 - drop new logmnr temporary tables 
Rem    thoang      06/13/06 - drop all_sync_capture_tables view 
Rem    xbarr       07/31/06 - drop data mining types/function 
Rem    gssmith     07/27/06 - Add downgrade for SQL Access Advisor 
Rem    juyuan      07/07/06 - do not drop dba_streams_tables 
Rem    jinwu       07/06/06 - drop streams component property tables/views 
Rem    kamsubra    07/25/06 - add cleaning up of cpool_stats 
Rem    kamsubra    07/18/06 - fix for bug 5396075
Rem    rmir        07/11/06 - drop v$encryption_wallet and gv$encryption_wallet
Rem    mlfeng      07/17/06 - add sum squares 
Rem    jsoule      06/18/06 - add bsln downgrade
Rem    jawilson    06/02/06 - scheduler-based propagation
Rem    rburns      07/19/06 - fix typo 
Rem    hosu        07/14/06 - extended stats
Rem    ilistvin    07/25/06 - fix autotask downgrade 
Rem    veeve       07/19/06 - drop dba_hist_ash
Rem    ilistvin    07/18/06 - correct resource plan name for auutotask 
Rem    ifitzger    06/14/06 - Remove TDE_MASTER_KEY_ID from props$ 
Rem    rramkiss    07/11/06 - remove remote database job stuff 
Rem    samepate    05/02/06 - null out extra column from scheduler$_job
Rem    kyagoub     06/12/06 - ade new methode to wri_adv_sqltune object type 
Rem    bdagevil    06/09/06 - remove V$SQL_MONITOR_* when downgrading
Rem    lgalanis    07/13/06 - drop workload capture/replay fixed views items
Rem    mlfeng      07/10/06 - drop iofuncmetric, rsrcmgrmetric 
Rem    mdilman     07/05/06 - remove duplication in HM/IR views drop 
Rem    mbastawa    07/12/06 - drop client result cache synonyms,fixed views
Rem    avaliani    07/11/06 - drop v$wait_chains and v$wait_chains_history
Rem    vkapoor     06/30/06 - Bug 5220793 
Rem    ramekuma    07/07/06 - truncate indrebuild$
Rem    rburns      07/11/06 - fix lob partition 
Rem    mtao        07/07/06 - projb 17789, logmnr_global$, fix log$ 
Rem    ushaft      07/07/06 - drop prvt_hdm (lrg 2384860)
Rem    jkundu      07/07/06 - typo in dropping logmnr temporary tables 
Rem    veeve       06/26/06 - add new 11g ASH columns
Rem    xbarr       07/05/06 - fix lrg2397144
Rem    absaxena    07/05/06 - lrg 2389020: typo in update reg$ 
Rem    mlfeng      06/13/06 - remove moving window bl 
Rem    mlfeng      06/13/06 - AWR baseline downgrade changes 
Rem    rdongmin    06/30/06 - drop SQL Diag packages 
Rem    sourghos    06/09/06 - drop v$ view for wlm 
Rem    sourghos    06/07/06 - drop public synonym for dbms_wlm 
Rem    sourghos    06/07/06 - drop WLM package 
Rem    mzait       05/30/06 - Support for separation between gather and 
Rem                           publish 
Rem    achoi       06/30/06 - remove EDITION_OBJ view 
Rem    abrown      05/19/06 - clear logmnr_mcv on downgrade 
Rem    gssmith     07/05/06 - lrg 2389020 
Rem    fsymonds    05/31/06 - Proj 19542: RM WLM PC consumer group mapping 
Rem    molagapp    06/15/06 - drop IR views
Rem    mjstewar    05/26/06 - IR integration 
Rem    ssonawan    06/21/06 - bug5346555: del AUDIT_ACTIONS 166 ALTER INDEXTYPE
Rem    pstengar    06/08/06 - downgrade mining model privileges
Rem    suelee      06/11/06 - Add IO calibration tables 
Rem    suelee      05/18/06 - Add IO statistics tables to AWR 
Rem    pbelknap    06/12/06 - drop colored sql view 
Rem    pbelknap    06/06/06 - add sub_param_validate for sqltune 
Rem    balajkri    06/12/06 - drop v$corrupt_xid_list and gv$corrupt_xid_list
Rem    liaguo      06/26/06 - Project 17991 - flashback archive
Rem    sbodagal    06/12/06 - MV log-related changes
Rem    bvaranas    06/13/06 - truncate table insert_tsn_list$ 
Rem    nbhatt      06/09/06 - drop lob attribute
Rem    absaxena    06/02/06 - drop/modify types for grouping notification
Rem    absaxena    06/02/06 - drop constructor for aq$_reg_info 
Rem    dkapoor     06/19/06 - drop ORACLE_OCM user 
Rem    shwang      06/17/06 - safer iot lob flag clear
Rem    bvaranas    03/14/05 - Change flags in partobj$ to remove IOT top index 
Rem                           flag and LOBcol index flag values 
Rem    veeve       06/14/06 - truncate new WRR$ tables
Rem    bbaddepu    06/19/06 - remove mem tgt synonyms 
Rem    kchen       06/14/06 - drop hs bulk load type 
Rem    smesropi    05/30/06 - drop olap data dictionary tables
Rem    chliang     05/22/06 - drop sscr tables, views and package
Rem    ushaft      04/21/06 - drop procedure from type wri$_hdm_adv_t
Rem                           changes to wrh$_inst_cache_transfer
Rem                           drop ADDM additions 
Rem    ssvemuri    06/08/06 - Downgrade change notification objects 
Rem    smangala    06/20/06 - lrg2289522: drop dba_logstdby_parameters 
Rem    jkundu      06/13/06 - drop logminer global temporary tables 
Rem    mmcracke    06/14/06 - Add drop of DM export/import sequence 
Rem    veeve       02/10/06 - handle the new qc_session_serial# in ASH 
Rem    amadan      05/24/06 - drop new streams aq performance views 
Rem    gssmith     04/27/06 - Downgrade SQL Access Advisor
Rem    achoi       06/08/06 - tmp fix lrg 2246884
Rem    mlfeng      05/17/06 - add awr memory tables 
Rem    dsemler     06/13/06 - fix missing downgrade bits from another merge 
Rem                           problem 
Rem    kamsubra    04/07/06 - drop cpool$ and views
Rem    rmacnico    06/07/06 - redefine scheduler$_event_log PK
Rem    rwickrem    06/12/06 - cleanup g/v$asm_attribute
Rem    gssmith     06/12/06 - Advisor framework downgrade items
Rem    mabhatta    06/08/06 - moving smon_scn_time back to system ts 
Rem    rdecker     05/30/06 - Downgrade PL/Scope data
Rem    jinwu       06/06/06 - rename DBA_STREAMS_* to DBA_STREAMS_TP_*
Rem                           and drop new streams$_ tables
Rem    ciyer       05/17/06 - edition syntax changes 
Rem    nkarkhan    05/26/06 - Project 19620: Add support for application
Rem                           initiated Fast-Start Failover.
Rem    jaskwon     05/25/06 - Remove max_concurrent_ios 
Rem    hosu        06/01/06 - truncate new tables for incremental maintenance
Rem                           of statistics on partitioned tables
Rem    juyuan      05/16/06 - drop dba_streams_columns view 
Rem    smuthuli    05/19/06 - project 18567: nglob 
Rem    smuthuli    04/18/06 - project 18567: nglob 
Rem    smuthuli    04/17/06 - project 18567: nglob 
Rem    ilistvin    06/07/06 - do not truncate ket_test_tasks 
Rem    jklein      06/07/06 - drop sql toolkit 
Rem    cchiappa    06/01/06 - Truncate new catalog tables for OLAP tables 
Rem    sylin       06/01/06 - drop package dbms_hprof and public synonym
Rem    jingliu     05/22/06 - truncate triggerdep$,drop *_trigger_ordering
Rem    abrown      05/23/06 - 
Rem    jnarasin    05/31/06 - Add Subordinate set to store HWS info in LWTS 
Rem    amysoren    06/01/06 - fix lrg 2245115 
Rem    rgmani      05/24/06 - Downgrade for LW Jobs 
Rem    wesmith     05/01/06 - add online redefinition downgrade 
Rem    suelee      06/01/06 - Fix resource manager downgrade issues 
Rem    weizhang    05/25/06 - proj 19400: downgrade ts# for GTT 
Rem    pbelknap    05/22/06 - new advisor methods 
Rem    liwong      05/29/06 - external position 
Rem    dsemler     06/01/06 - fix downgrade problem - missing remove of 
Rem                           px_instance 
Rem    bmilenov    05/23/06 - Update GLM types 
Rem    ilistvin    05/12/06 - add downgrade steps for AUTOTASK 
Rem    rvenkate    01/26/06 - delete comparison$ rows
Rem    gviswana    05/20/06 - Remove diana_version 
Rem    jarisank    05/27/06 - bug4054238 - update sumagg$.agginfo
Rem    rmacnico    05/23/06 - remove scheduler ability on standby servers
Rem    dmukhin     05/17/06 - prj 18876: scoring cost matrix 
Rem    amysoren    05/17/06 - WRH$_SYSTEM_EVENT changes 
Rem    mzait       05/19/06 - ACS - support for new fixed views 
Rem    jinwu       05/19/06 - drop dbms_streams_adv_adm_utl_invok 
Rem    kyagoub     05/21/06 - add test_execute action to sqltune 
Rem    achoi       05/04/06 - drop "_*_EDITION_OBJ" view family 
Rem    vkolla      05/19/06 - drop v$iostat_{file,consumer_group,function}
Rem    mabhatta    05/15/06 - adding removals for transaction backout
Rem    bkuchibh    05/16/06 - drop HM package,views,synonyms 
Rem    elu         05/10/06 - add spill scn to apply milestone table 
Rem    dsemler     03/10/06 - downgrade to remove v$px_instance_group 
Rem    bgarin      05/04/06 - Downgrade Logminer V11 metadata 
Rem    mbrey       05/15/06 - drop CDC metadata 
Rem    liwong      05/10/06 - sync capture cleanup 
Rem    xbarr       05/16/06 - lrg 2214042 
Rem    kyagoub     04/30/06 - add suport of multi-exec to advisor framework 
Rem    srirkris    05/08/06 - lrg 2199385
Rem    mgirkar     05/11/06 - drop redo_dest_resp_histogram related views and 
Rem                           synonyms; also drop logmnr related views which
Rem                           were not dropped due to an oversight (jgalanes)
Rem    kyagoub     05/04/06 - drop new package dbms_sqltune_util0 
Rem    bkuchibh    05/04/06 - fix lrg#2188905 
Rem    xbarr       05/03/06 - lrg 2173646: drop public synonyms 
Rem    suelee      03/28/06 - Modifications for IO Resource Management 
Rem    rdongmin    04/12/06 - drop fixed view for hint definition 
Rem    sbodagal    05/02/06 - update sumdetail$
Rem    pbelknap    04/24/06 - lrg2171525
Rem    rdecker     04/28/06 - lrg 2187228: syntax errors from remove assemblies
Rem    srirkris    03/30/06 - Drop CompInfo attribute
Rem    rdecker     03/28/06 - Remove assemblies
Rem    bkuchibh    03/08/06 - null out extra column from wri$_adv_findings 
Rem    bkuchibh    03/08/06 - null out extra column from wri$_adv_findings 
Rem    xbarr       04/21/06 - fix lrg 2171012 
Rem    jgalanes    04/21/06 - Remove public synonyms added for LogMiner views 
Rem                           in 11g. 
Rem    tbingol     04/14/06 - Result_Cache: Drop synonyms, fixed views, 
Rem                           package & library
Rem    spsundar    03/23/06 - drop more 11gR1 related extensiblity types
Rem    pbelknap    03/23/06 - report framework changes 
Rem    mxyang      04/05/06 - lrg 2144785: drop ORA$BASE
Rem    sichandr    04/12/06 - drop member function getSchemaId 
Rem    akruglik    04/07/06 - truncate EV$ and EVCOL$, and get rid of 
Rem                           *_EDITIONING_VIEWS and *_EDITIONING_VIEW_COLUMNS 
Rem                           views and synonyms defined on them
Rem    lvbcheng    04/03/06 - 4635392 - dbmshtdb
Rem       hozeng   04/13/06 - fix the garbled lines 
Rem    kyagoub     04/06/06 - downgrade process workspace 
Rem    abrown      03/28/06 - Clear LOGMNRC_GTCS.COL#
Rem    amozes      03/27/06 - remove types for supervised binning 
Rem    dvoss       03/24/06 - drop logmnr_tab_col support views 
Rem    abrown      03/14/06 - Downgrade Logminer V11 metadata 
Rem    jinwu       03/09/06 - drop/truncate streams per-database views/tables
Rem    rramkiss    03/20/06 - remove Scheduler credential new objects 
Rem    mxyang      03/06/06 - drop application edition privileges / audit options
Rem    achoi       03/06/06 - drop Application Edition 
Rem    shshanka    03/12/06 - truncate ecol$ 
Rem    rdongmin    03/15/06 - drop feature control fixed views 
Rem    xbarr       03/13/06 - Add Data Mining downgrade  
Rem    msusaira    03/06/06 - add drop of v$iostat_network 
Rem    jnarasin    03/10/06 - Add KGL invalidation for Security Classes 
Rem    vakrishn    02/08/06 - lrg-1960928 : changing index flashback timestamp to
Rem                           GMT.
Rem    jnarasin    02/23/06 - LWTS Application Namespaces 
Rem    mhho        02/13/06 - drop XS session packages on downgrade 
Rem    juyuan      01/16/06 - drop package dbms_streams_sm 
Rem    jnarasin    01/30/06 - LWT sessions tables 
Rem    srtata      01/25/06 - dsec.bsq changes 
Rem    cchiappa    01/19/06 - Add OLAP cell access tracking catalogs 
Rem    achoi       12/15/05 - clear 0x00200000 in trigflag during downgrade 
Rem    abrown      09/22/05 - bug 3776830: unwind dictionary 
Rem    spsundar    12/21/05 - Drop 11gR1 extensibility related types
Rem    dgagne      11/18/05 - add drop of plugts objects 
Rem    yohu        11/18/05 - Add drop dbms_xa and its types
Rem    nitgupta    11/02/05 - print config changes to xmltype
Rem    wyang       10/17/05 - flashback timestamp revert to local time 
Rem    svivian     10/12/05 - drop fixed fs_failover views 
Rem    cdilling    10/03/05 - move session_history changes from e1001000.sql 
Rem    thoang      09/28/05 - drop dba_synchronous_capture_tables view 
Rem    zqiu        09/08/05 - Drop OLAP sparsity advisor types 
Rem    pyam        08/30/05 - Add drop dbms_shared_pool 
Rem    pbelknap    08/08/05 - dbms_sqltune changes: drop temp table 
Rem    tyurek      07/29/05 - drop gv$/v$dynamic_remaster_stats 
Rem    rdongmin    06/27/05 - Drop bug control service fixed views
Rem    mlfeng      06/21/05 - AWR mutex summary, event histogram 
Rem    gmulagun    06/24/05 - bug 4035677 drop object_privilege views 
Rem    cdilling    06/15/05 - cdilling_add_upgrade_scripts
Rem    cdilling    06/08/05 - Created

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release to 11g
Rem =========================================================================

@@e1101000.sql

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release to 11g
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary from current release to 10.2
Rem =========================================================================

Rem=========================================================================
Rem Delete new system privileges here
Rem=========================================================================
Rem  Delete data mining model system privileges
delete from SYSAUTH$ where privilege# in 
(-290, -291, -292, -293, -294, -295); 
delete from SYSTEM_PRIVILEGE_MAP where privilege in 
(-290, -291, -292, -293, -294, -295); 
commit;

-- create any/drop any/alter any edition
delete from SYSAUTH$ where privilege# in
(-281, -282, -283);
delete from SYSTEM_PRIVILEGE_MAP where privilege in
(-281, -282, -283);
commit;

Rem Delete .NET assembly system privileges
delete from SYSAUTH$ where privilege# in
(-284, -285, -286, -287, -288, -289); 
delete from SYSTEM_PRIVILEGE_MAP where privilege in 
(-284, -285, -286, -287, -288, -289);
commit;

Rem Delete OLAP API system privileges 
delete from SYSAUTH$ where privilege# in
(-301, -302, -303, -304, -305, -306, -307, -308, -309, -310, -311,
 -312, -313, -314, -315, -316, -317, -318, -319, -320, -321, -322, -326);
delete from SYSTEM_PRIVILEGE_MAP where privilege in
(-301, -302, -303, -304, -305, -306, -307, -308, -309, -310, -311,
 -312, -313, -314, -315, -316, -317, -318, -319, -320, -321, -322, -326);
commit; 

Rem Delete FLASHBACK ARCHIVE system privileges 
delete from SYSAUTH$ where privilege# in
(-350);
delete from SYSTEM_PRIVILEGE_MAP where privilege in
(-350);
commit; 

Rem=========================================================================
Rem Delete new object privileges here
Rem=========================================================================

-- USE privilege
delete from OBJAUTH$            where privilege# = 29;
delete from TABLE_PRIVILEGE_MAP where privilege  = 29;

Rem  Delete data mining model object privileges
delete from OBJAUTH$ where obj# in (select obj# from obj$ where type#=82);

-- FLASHBACK ARCHIVE privilege
delete from OBJAUTH$            where privilege# = 30;
delete from TABLE_PRIVILEGE_MAP where privilege  = 30;

rem delete "administer sql management object" privilege

delete from SYSTEM_PRIVILEGE_MAP
where privilege = -327;

delete from STMT_AUDIT_OPTION_MAP 
where option# = 327;

delete from AUDIT$ 
where option# = 327;

delete from SYSAUTH$ 
where privilege# = -327;

Rem=========================================================================
Rem Delete new audit options here
Rem=========================================================================
Rem  Delete data mining model audit options
delete from AUDIT$                where option# in 
(52, 290, 291, 292, 293, 294, 295, 296, 297, 298, 300); 
delete from STMT_AUDIT_OPTION_MAP where option# in 
(52, 290, 291, 292, 293, 294, 295, 296, 297, 298, 300); 
delete from AUDIT_ACTIONS where action in (130, 131, 133);
commit;

delete from AUDIT$                
  where option# in (284, 285, 286, 287, 288, 289);
delete from STMT_AUDIT_OPTION_MAP 
  where option# in (284, 285, 286, 287, 288, 289);
delete from AUDIT_ACTIONS where action = 166;
commit;

-- delete from AUDIT$                where option# in (<list of option#>);
-- delete from STMT_AUDIT_OPTION_MAP where option# in (<list of option#>);
-- commit;

-- create any/drop any/alter any edition
delete from AUDIT$ where option# in (281, 282, 283, 323, 324, 325);
delete from STMT_AUDIT_OPTION_MAP
  where option# in (281, 282, 283, 323, 324, 325);
delete from AUDIT_ACTIONS where action in (212, 213, 214);
commit;

-- Delete OLAP API audit options
delete from AUDIT$ where option# in
(301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311,
 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 326);
delete from STMT_AUDIT_OPTION_MAP where option# in
(301, 302, 303, 304, 305, 306, 307, 308, 309, 310, 311,
 312, 313, 314, 315, 316, 317, 318, 319, 320, 321, 322, 326);
commit;

-- Delete FLASHBACK ARCHIVE
delete from AUDIT$                
  where option# in (350);
delete from STMT_AUDIT_OPTION_MAP 
  where option# in (350);
commit;

-- Add audit options
insert into STMT_AUDIT_OPTION_MAP values (157, 'CREATE DIRECTORY', 0);
insert into STMT_AUDIT_OPTION_MAP values (158, 'DROP DIRECTORY', 0);
insert into STMT_AUDIT_OPTION_MAP values (185, 'GRANT LIBRARY', 0);
insert into STMT_AUDIT_OPTION_MAP values ( 87, 'EXISTS', 0);


Rem=========================================================================
Rem Drop new fixed views here
Rem=========================================================================

drop public synonym v$wait_chains;
drop view v_$wait_chains;

drop public synonym v$iostat_network;
drop view v_$iostat_network;
drop public synonym gv$iostat_network;
drop view gv_$iostat_network;

drop public synonym v$iostat_consumer_group;
drop view v_$iostat_consumer_group;
drop public synonym gv$iostat_consumer_group;
drop view gv_$iostat_consumer_group;

drop public synonym v$iostat_function;
drop view v_$iostat_function;
drop public synonym gv$iostat_function;
drop view gv_$iostat_function;

drop public synonym v$iostat_file;
drop view v_$iostat_file;
drop public synonym gv$iostat_file;
drop view gv_$iostat_file;

drop public synonym v$io_calibration_status;
drop view v_$io_calibration_status;
drop public synonym gv$io_calibration_status;
drop view gv_$io_calibration_status;

drop public synonym v$corrupt_xid_list;
drop view v_$corrupt_xid_list;
drop public synonym gv$corrupt_xid_list;
drop view gv_$corrupt_xid_list;

drop public synonym v$calltag;
drop view v_$calltag;
drop public synonym gv$calltag;
drop view gv_$calltag;

drop public synonym v$process_group;
drop view v_$process_group;
drop public synonym gv$process_group; 
drop view gv_$process_group;

drop public synonym v$detached_session;
drop view v_$detached_session;     
drop public synonym gv$detached_session;
drop view gv_$detached_session;


Rem
Rem drop dynamic Object privilege views
Rem
DROP PUBLIC SYNONYM v$object_privilege;
DROP VIEW v_$object_privilege;

Rem Remove bug control service views
drop public synonym v$session_fix_control;
drop view v_$session_fix_control;
drop public synonym gv$session_fix_control;
drop view gv_$session_fix_control;
drop public synonym v$system_fix_control;
drop view v_$system_fix_control;
drop public synonym gv$system_fix_control;
drop view gv_$system_fix_control;

Rem Remove rac drm stats views
drop public synonym v$dynamic_remaster_stats;
drop view v_$dynamic_remaster_stats;
drop public synonym gv$dynamic_remaster_stats;
drop view gv_$dynamic_remaster_stats;

Rem Remove Fast-Start Failover fixed views
drop public synonym v$fs_failover_histogram;
drop view v_$fs_failover_histogram;
drop public synonym gv$fs_failover_histogram;
drop view gv_$fs_failover_histogram;
drop public synonym v$fs_failover_stats;
drop view v_$fs_failover_stats;
drop public synonym gv$fs_failover_stats;
drop view gv_$fs_failover_stats;

drop view v_$redo_dest_resp_histogram;
drop view gv_$redo_dest_resp_histogram;


Rem Remove Encryption fixed views
drop public synonym v$encryption_wallet;
drop view v_$encryption_wallet;
drop public synonym gv$encryption_wallet;
drop view gv_$encryption_wallet;

Rem Remove Tablespace Encryption fixed views
drop public synonym v$encrypted_tablespaces;
drop view v_$encrypted_tablespaces;
drop public synonym gv$encrypted_tablespaces;
drop view gv_$encrypted_tablespaces;

Rem Remove SQLFN_METADATA views
drop public synonym v$sqlfn_metadata;
drop view v_$sqlfn_metadata;
drop public synonym gv$sqlfn_metadata;
drop view gv_$sqlfn_metadata;

Rem Remove SQLFN_ARG_METADATA views
drop public synonym v$sqlfn_arg_metadata;
drop view v_$sqlfn_arg_metadata;
drop public synonym gv$sqlfn_arg_metadata;
drop view gv_$sqlfn_arg_metadata;

Rem
Rem Remove feature control fixed views
Rem
drop public synonym v$sql_feature;
drop view v_$sql_feature;
drop public synonym gv$sql_feature;
drop view gv_$sql_feature;
drop public synonym v$sql_feature_hierarchy;
drop view v_$sql_feature_hierarchy;
drop public synonym gv$sql_feature_hierarchy;
drop view gv_$sql_feature_hierarchy;
drop public synonym v$sql_feature_dependency;
drop view v_$sql_feature_dependency;
drop public synonym gv$sql_feature_dependency;
drop view gv_$sql_feature_dependency;

Rem
Rem Result Cache fixed views
Rem
drop public synonym v$result_cache_statistics;
drop view v_$result_cache_statistics;
drop public synonym gv$result_cache_statistics;
drop view gv_$result_cache_statistics;
drop public synonym v$result_cache_memory;
drop view v_$result_cache_memory;
drop public synonym gv$result_cache_memory;
drop view gv_$result_cache_memory;
drop public synonym v$result_cache_objects;
drop view v_$result_cache_objects;
drop public synonym gv$result_cache_objects;
drop view gv_$result_cache_objects;
drop public synonym v$result_cache_dependency;
drop view v_$result_cache_dependency;
drop public synonym gv$result_cache_dependency;
drop view gv_$result_cache_dependency;

Rem 
Rem Client result cache
Rem 
drop public synonym v$client_result_cache_stats;
drop view v_$client_result_cache_stats;
drop public synonym gv$client_result_cache_stats;
drop view gv_$client_result_cache_stats;
drop public synonym client_result_cache_stats$;
drop view crcstats_$;
truncate table CRC$_RESULT_CACHE_STATS;

Rem Remove v$streams_message_tracking
drop public synonym V$STREAMS_MESSAGE_TRACKING;
drop view V_$STREAMS_MESSAGE_TRACKING;
drop public synonym GV$STREAMS_MESSAGE_TRACKING;
drop view GV_$STREAMS_MESSAGE_TRACKING; 

Rem
Rem Remove hint fixed views
Rem
drop public synonym v$sql_hint;
drop view v_$sql_hint;
drop public synonym gv$sql_hint;
drop view gv_$sql_hint;

Rem
Rem Remove HM/IR fixed views and public synonyms
Rem
drop public synonym v$hm_run;
drop view v_$hm_run;
drop public synonym gv$hm_run;
drop view gv_$hm_run;
drop public synonym v$hm_finding;
drop view v_$hm_finding;
drop public synonym gv$hm_finding;
drop view gv_$hm_finding;
drop public synonym v$hm_recommendation;
drop view v_$hm_recommendation;
drop public synonym gv$hm_recommendation;
drop view gv_$hm_recommendation;
drop public synonym v$hm_info;
drop view v_$hm_info;
drop public synonym gv$hm_info;
drop view gv_$hm_info;
drop public synonym v$hm_check;
drop view v_$hm_check;
drop public synonym gv$hm_check;
drop view gv_$hm_check;
drop public synonym v$hm_check_param;
drop view v_$hm_check_param;
drop public synonym gv$hm_check_param;
drop view gv_$hm_check_param;
drop public synonym v$ir_failure;
drop view v_$ir_failure;
drop public synonym gv$ir_failure;
drop view gv_$ir_failure;
drop public synonym v$ir_repair;
drop view v_$ir_repair;
drop public synonym gv$ir_repair;
drop view gv_$ir_repair;
drop public synonym v$ir_manual_checklist;
drop view v_$ir_manual_checklist;
drop public synonym gv$ir_manual_checklist;
drop view gv_$ir_manual_checklist;
drop public synonym v$ir_failure_set;
drop view v_$ir_failure_set;
drop public synonym gv$ir_failure_set;
drop view gv_$ir_failure_set;

drop public synonym v$sql_cs_selectivity;
drop view v_$sql_cs_selectivity;
drop public synonym gv$sql_cs_selectivity;
drop view gv_$sql_cs_selectivity;

drop public synonym v$sql_cs_histogram;
drop view v_$sql_cs_histogram;
drop public synonym gv$sql_cs_histogram;
drop view gv_$sql_cs_histogram;

drop public synonym v$sql_cs_statistics;
drop view v_$sql_cs_statistics;
drop public synonym gv$sql_cs_statistics;
drop view gv_$sql_cs_statistics;

Rem Remove g/v$px_instance_group views
drop public synonym v$px_instance_group;
drop view v_$px_instance_group;
drop public synonym gv$px_instance_group;
drop view gv_$px_instance_group;

Rem Remove g/v$asm_attribute
drop public synonym v$asm_attribute;
drop view v_$asm_attribute;
drop public synonym gv$asm_attribute;
drop view gv_$asm_attribute;

Rem============================
Rem Streams AQ Changes Begin
Rem============================

Rem Remove streams AQ performance views
drop public synonym V$PERSISTENT_QUEUES;
drop view V_$PERSISTENT_QUEUES;
drop public synonym GV$PERSISTENT_QUEUES;
drop view GV_$PERSISTENT_QUEUES; 
drop public synonym V$PERSISTENT_SUBSCRIBERS;
drop view V_$PERSISTENT_SUBSCRIBERS;
drop public synonym GV$PERSISTENT_SUBSCRIBERS;
drop view GV_$PERSISTENT_SUBSCRIBERS; 
drop public synonym V$PERSISTENT_PUBLISHERS;
drop view V_$PERSISTENT_PUBLISHERS;
drop public synonym GV$PERSISTENT_PUBLISHERS;
drop view GV_$PERSISTENT_PUBLISHERS; 

Rem Remove memory_target views
drop public synonym v$memory_dynamic_components;
drop view v_$memory_dynamic_components;
drop public synonym v$memory_target_advice;
drop view v_$memory_target_advice;
drop public synonym v$memory_current_resize_ops;
drop view v_$memory_current_resize_ops;
drop public synonym v$memory_resize_ops;
drop view v_$memory_resize_ops;
drop public synonym gv$memory_dynamic_components;
drop view gv_$memory_dynamic_components;
drop public synonym gv$memory_target_advice;
drop view gv_$memory_target_advice;
drop public synonym gv$memory_current_resize_ops;
drop view gv_$memory_current_resize_ops;
drop public synonym gv$memory_resize_ops;
drop view gv_$memory_resize_ops;

Rem Remove streams AQ notifications views
drop public synonym v$subscr_registration_stats;
drop view v_$subscr_registration_stats;
drop public synonym gv$subscr_registration_stats;
drop view gv_$subscr_registration_stats;

Rem Remove workload capture and replay views
drop public synonym v$workload_replay_thread;
drop view v_$workload_replay_thread;
drop public synonym gv$workload_replay_thread; 
drop view gv_$workload_replay_thread;

Rem
Rem Remove SQL Monitoring fixed views
Rem
drop view gv_$sql_monitor;
drop view v_$sql_monitor;
drop public synonym v$sql_monitor;
drop public synonym gv$sql_monitor;

drop view gv_$sql_plan_monitor;
drop view v_$sql_plan_monitor;
drop public synonym gv$sql_plan_monitor;
drop public synonym v$sql_plan_monitor;

Rem Remove AWR metrics views
drop public synonym v$iofuncmetric;
drop view v_$iofuncmetric;
drop public synonym gv$iofuncmetric;
drop view gv_$iofuncmetric;
drop public synonym v$iofuncmetric_history;
drop view v_$iofuncmetric_history;
drop public synonym gv$iofuncmetric_history;
drop view gv_$iofuncmetric_history;

drop public synonym v$rsrcmgrmetric;
drop view v_$rsrcmgrmetric;
drop public synonym gv$rsrcmgrmetric;
drop view gv_$rsrcmgrmetric;
drop public synonym v$rsrcmgrmetric_history;
drop view v_$rsrcmgrmetric_history;
drop public synonym gv$rsrcmgrmetric_history;
drop view gv_$rsrcmgrmetric_history;

Rem Remove INCIDENT METER views
drop public synonym v$incmeter_config;
drop view v_$incmeter_config;
drop public synonym gv$incmeter_config;
drop view gv_$incmeter_config;
drop public synonym v$incmeter_summary;
drop view v_$incmeter_summary;
drop public synonym gv$incmeter_summary;
drop view gv_$incmeter_summary;
drop public synonym v$incmeter_info;
drop view v_$incmeter_info;
drop public synonym gv$incmeter_info;
drop view gv_$incmeter_info;

Rem Remove User mode NFS views 
drop public synonym v$dnfs_stats;
drop view v_$dnfs_stats;
drop public synonym gv$dnfs_stats;
drop view gv_$dnfs_stats;
drop public synonym v$dnfs_files;
drop view v_$dnfs_files;
drop public synonym gv$dnfs_files;
drop view gv_$dnfs_files;
drop public synonym v$dnfs_servers;
drop view v_$dnfs_servers;
drop public synonym gv$dnfs_servers;
drop view gv_$dnfs_servers;
drop public synonym v$dnfs_channels;
drop view v_$dnfs_channels;
drop public synonym gv$dnfs_channels;
drop view gv_$dnfs_channels;

drop public synonym v$lobstat;
drop view v_$lobstat;
drop public synonym gv$lobstat;
drop view gv_$lobstat;
drop public synonym v$asm_disk_iostat;
drop view v_$asm_disk_iostat;
drop public synonym gv$asm_disk_iostat;
drop view gv_$asm_disk_iostat;

Rem
Rem Remove diag_info fixed views and public synonyms
Rem
drop public synonym v$diag_info;
drop view v_$diag_info;
drop public synonym gv$diag_info;
drop view gv_$diag_info;

Rem
Rem Remove diag_critical_error fixed views and public synonyms
Rem
drop public synonym v$diag_critical_error;
drop view v_$diag_critical_error;

Rem drop v$securefile_timer
drop public synonym v$securefile_timer;
drop view v_$securefile_timer;
drop public synonym gv$securefile_timer;
drop view gv_$securefile_timer;

Rem=========================================================================
Rem Drop all new ALL/DBA/USER views here
Rem=========================================================================

Rem Drop view for invalid object check
drop public synonym DBA_INVALID_OBJECTS;
drop view DBA_INVALID_OBJECTS;

Rem Remove synchronous capture views
drop view dba_sync_capture_tables;
drop view all_sync_capture_tables;
drop view dba_sync_capture;
drop view all_sync_capture;
drop view dba_sync_capture_prepared_tabs;
drop view all_sync_capture_prepared_tabs;

Rem Remove comparison views
drop view dba_comparison;
drop view dba_comparison_columns;
drop view dba_comparison_scan;
drop view dba_comparison_scan_values;
drop view dba_comparison_row_dif;
drop view user_comparison;
drop view user_comparison_columns;
drop view user_comparison_scan;
drop view user_comparison_scan_values;
drop view user_comparison_row_dif;
drop view "_USER_COMPARISON_ROW_DIF";

Rem Remove assembly support
drop view dba_assemblies;
drop public synonym dba_assemblies;
drop view user_assemblies;
drop public synonym user_assemblies;
drop view all_assemblies;
drop public synonym all_assemblies;

Rem Remove Logminer Support Views
drop view logmnr_tab_cols_support;
drop view logmnr_tab_cols_cat_support;
drop view logmnr_gtcs_support;
drop view logmnr_gtcs_cat_support;

Rem Remove queue schedule views
drop view "_DBA_QUEUE_SCHEDULES";
drop view "_DBA_QUEUE_SCHEDULES_COMPAT";
drop view "_USER_QUEUE_SCHEDULES";
drop view "_USER_QUEUE_SCHEDULES_COMPAT";

Rem Remove Logstdby Support/Unsupport Views
drop view dba_logstdby_unsupported_table;
drop public synonym logstdby_unsupported_tables;
drop public synonym logstdby_unsupported_table;

drop function logstdby$tabf;
drop type logstdby$srecs force;
drop view logstdby_support_tab_11_1;
drop view logstdby_support_tab_10_2;
drop view logstdby_support_tab_10_1;

drop function logstdby$utabf;
drop type logstdby$urecs force;
drop view logstdby_unsupport_tab_11_1;
drop view logstdby_unsupport_tab_10_2;
drop view logstdby_unsupport_tab_10_1;

drop view logstdby_support_11lob; 

delete from system.logstdby$skip
where length(name) > 30 or statement_opt = 'PL/SQL';
commit;
update system.logstdby$skip 
set statement_opt='GRANT OBJECT'
where statement_opt = 'GRANT';
commit;
update system.logstdby$skip 
set statement_opt='REVOKE OBJECT'
where statement_opt = 'REVOKE';
commit;

alter table system.logstdby$skip modify (name varchar2(30));
alter table system.logstdby$skip_support drop column reg;

truncate table system.logstdby$flashback_scn;

Rem Remove SSCR objects
drop view gv_$sscr_sessions;
drop public synonym gv$sscr_sessions;
drop view v_$sscr_sessions;
drop public synonym v$sscr_sessions;
truncate table sscr_cap$;
truncate table sscr_res$;
drop sequence sscr_cap_seq$;
drop view dba_sscr_capture;
drop view dba_sscr_restore;
drop package dbms_session_state;

Rem Remove NFS views
drop view gv_$nfs_clients;
drop public synonym gv$nfs_clients;
drop view v_$nfs_clients;
drop public synonym v$nfs_clients;
drop view gv_$nfs_open_files;
drop public synonym gv$nfs_open_files;
drop view v_$nfs_open_files;
drop public synonym v$nfs_open_files;
drop view gv_$nfs_locks;
drop public synonym gv$nfs_locks;
drop view v_$nfs_locks;
drop public synonym v$nfs_locks;

Rem Remove PL/Scope views
drop view dba_identifiers;
drop public synonym dba_identifiers;
drop view user_identifiers;
drop public synonym user_identifiers;
drop view all_identifiers;
drop public synonym all_identifiers;

Rem Remove Logstdby views to resolve dependency on x$dglparams
drop view dba_logstdby_parameters;
drop public synonym dba_logstdby_parameters;

Rem Remove rman compression algorithm views
drop view gv_$rman_compression_algorithm;
drop public synonym gv$rman_compression_algorithm;
drop view v_$rman_compression_algorithm;
drop public synonym v$rman_compression_algorithm;

Rem Remove rman encryption algorithm views
drop view v_$rman_encryption_algorithms;
drop public synonym v$rman_encryption_algorithms;

Rem Remove PL/Scope views

Rem Remove security user with default password view
drop public synonym DBA_USERS_WITH_DEFPWD;
drop view SYS.DBA_USERS_WITH_DEFPWD;

Rem==============================
Rem Connection pool changes begin
Rem==============================

Rem Remove CC stats
drop public synonym gv$cpool_cc_stats;
drop view gv_$cpool_cc_stats;
drop public synonym v$cpool_cc_stats;
drop view v_$cpool_cc_stats;

Rem Remove Pool + CC info
drop public synonym gv$cpool_cc_info;
drop view gv_$cpool_cc_info;
drop public synonym v$cpool_cc_info;
drop view v_$cpool_cc_info;

Rem Remove CP stats
drop public synonym gv$cpool_stats;
drop view gv_$cpool_stats;
drop public synonym v$cpool_stats;
drop view v_$cpool_stats;

Rem Remove cpool$ view
drop public synonym dba_cpool_info;
drop view dba_cpool_info;

Rem Remove packages & libs
drop library sys.dbms_connection_pool_lib;
drop package sys.dbms_connection_pool;
truncate table cpool$;

Rem==============================
Rem Connection pool changes end
Rem==============================


Rem Remove EDITIONS view family
drop public synonym ALL_EDITIONS;
drop public synonym DBA_EDITIONS;
drop view ALL_EDITIONS;
drop view DBA_EDITIONS;

Rem Remove EDITIONS_COMMENTS view family
drop public synonym ALL_EDITION_COMMENTS;
drop public synonym DBA_EDITION_COMMENTS;
drop view ALL_EDITION_COMMENTS;
drop view DBA_EDITION_COMMENTS;

Rem Remove OBJECTS_AE view family
drop public synonym USER_OBJECTS_AE;
drop public synonym ALL_OBJECTS_AE;
drop public synonym DBA_OBJECTS_AE;
drop view USER_OBJECTS_AE;
drop view ALL_OBJECTS_AE;
drop view DBA_OBJECTS_AE;

Rem Remove ERRORS_AE view family
drop public synonym USER_ERRORS_AE;
drop public synonym ALL_ERRORS_AE;
drop public synonym DBA_ERRORS_AE;
drop view USER_ERRORS_AE;
drop view ALL_ERRORS_AE;
drop view DBA_ERRORS_AE;

Rem Remove SOURCE_AE view family
drop public synonym USER_SOURCE_AE;
drop public synonym ALL_SOURCE_AE;
drop public synonym DBA_SOURCE_AE;
drop view USER_SOURCE_AE;
drop view ALL_SOURCE_AE;
drop view DBA_SOURCE_AE;

Rem Remove SOURCE view family
drop public synonym USER_SOURCE;
drop public synonym ALL_SOURCE;
drop public synonym DBA_SOURCE;
drop view USER_SOURCE;
drop view ALL_SOURCE;

Rem Remove VIEWS_AE view family
drop public synonym USER_VIEWS_AE;
drop public synonym ALL_VIEWS_AE;
drop public synonym DBA_VIEWS_AE;
drop view USER_VIEWS_AE;
drop view ALL_VIEWS_AE;
drop view DBA_VIEWS_AE;

Rem Remove EDITIONING_VIEWS_AE view family
drop public synonym USER_EDITIONING_VIEWS_AE;
drop public synonym ALL_EDITIONING_VIEWS_AE;
drop public synonym DBA_EDITIONING_VIEWS_AE;
drop view USER_EDITIONING_VIEWS_AE;
drop view ALL_EDITIONING_VIEWS_AE;
drop view DBA_EDITIONING_VIEWS_AE;

Rem Remove EDITIONING_VIEW_COLS_AE view family
drop public synonym USER_EDITIONING_VIEW_COLS_AE;
drop public synonym ALL_EDITIONING_VIEW_COLS_AE;
drop public synonym DBA_EDITIONING_VIEW_COLS_AE;
drop view USER_EDITIONING_VIEW_COLS_AE;
drop view ALL_EDITIONING_VIEW_COLS_AE;
drop view DBA_EDITIONING_VIEW_COLS_AE;

Rem=======================
Rem Streams Changes Begin
Rem=======================

Rem Remove Streams topology per-database views
drop view "_DBA_STREAMS_COMPONENT";
drop view "_DBA_STREAMS_COMPONENT_LINK";
drop view "_DBA_STREAMS_COMPONENT_PROP";
drop view "_DBA_STREAMS_COMPONENT_STAT";
drop view "_DBA_STREAMS_COMPONENT_EVENT";
drop public synonym "_DBA_STREAMS_COMPONENT";
drop public synonym "_DBA_STREAMS_COMPONENT_LINK";
drop public synonym "_DBA_STREAMS_COMPONENT_PROP";
drop public synonym "_DBA_STREAMS_COMPONENT_STAT";
drop public synonym "_DBA_STREAMS_COMPONENT_EVENT";

drop view "_DBA_STREAMS_FINDINGS";
drop view "_DBA_STREAMS_RECOMMENDATIONS";
drop view "_DBA_STREAMS_ACTIONS";
drop public synonym "_DBA_STREAMS_FINDINGS";
drop public synonym "_DBA_STREAMS_RECOMMENDATIONS";
drop public synonym "_DBA_STREAMS_ACTIONS";

drop view DBA_STREAMS_TP_COMPONENT;
drop view DBA_STREAMS_TP_COMPONENT_LINK;
drop view DBA_STREAMS_TP_COMPONENT_STAT;
drop view DBA_STREAMS_TP_DATABASE;
drop view DBA_STREAMS_TP_PATH_STAT;
drop view DBA_STREAMS_TP_PATH_BOTTLENECK;
drop public synonym DBA_STREAMS_TP_COMPONENT;
drop public synonym DBA_STREAMS_TP_COMPONENT_LINK;
drop public synonym DBA_STREAMS_TP_COMPONENT_STAT;
drop public synonym DBA_STREAMS_TP_DATABASE;
drop public synonym DBA_STREAMS_TP_PATH_STAT;
drop public synonym DBA_STREAMS_TP_PATH_BOTTLENECK;

drop view "_DBA_STREAMS_TP_COMPONENT_PROP";
drop public synonym "_DBA_STREAMS_TP_COMPONENT_PROP";

Rem Drop temporary tables for Configuration/Performance/Error Advisor
drop table streams$_component_in;
drop table streams$_component_link_in;
drop table streams$_component_prop_in;
drop table streams$_component_stat_in;
drop table streams$_component_event_in;
drop table streams$_local_findings_in;
drop table streams$_local_actions_in;
drop table streams$_local_recs_in;
drop table streams$_component_stat_out;
drop table streams$_path_stat_out;
drop table streams$_path_bottleneck_out;

Rem Truncate persistent tables for storing Streams topoloy information
truncate table streams$_database;
truncate table streams$_component;
truncate table streams$_component_link;
truncate table streams$_component_prop;

Rem  STREAMS$_PROPAGATION_PROCESS changes 
Rem    - NULL out the new columns in 
Rem      streams$_propagation_process
Rem 
update STREAMS$_PROPAGATION_PROCESS
   set original_propagation_name    = NULL,
       original_source_queue_schema = NULL,
       original_source_queue        = NULL,
       acked_scn                    = NULL,
       auto_merge_threshold         = NULL,
       creation_time                = NULL;
commit;

update streams$_prepare_object set cap_type = 0;
update aq$_schedules set job_name = NULL;
commit;

update streams$_apply_milestone
  set spill_lwm_scn = NULL, 
      lwm_external_pos = NULL,
      spare2 = NULL,
      spare3 = NULL;
commit;

update apply$_source_obj
  set inst_external_pos = NULL,
      spare2 = NULL,
      spare3 = NULL;
commit;

update apply$_source_schema
  set inst_external_pos = NULL,
      spare2 = NULL,
      spare3 = NULL;
commit;

update apply$_error
  set external_source_pos = NULL,
      spare4 = NULL,
      spare5 = NULL;
commit;

drop view "_DBA_APPLY_INST_OBJECTS";
drop public synonym "_DBA_APPLY_INST_OBJECTS";

drop view "_DBA_APPLY_INST_SCHEMAS";
drop public synonym "_DBA_APPLY_INST_SCHEMAS";

drop view "_DBA_APPLY_INST_GLOBAL";
drop public synonym "_DBA_APPLY_INST_GLOBAL";

drop view "_DBA_APPLY_PROGRESS_POSITION";
drop public synonym "_DBA_APPLY_PROGRESS_POSITION";

drop view "_ALL_APPLY_PROGRESS_POSITION";
drop public synonym "_ALL_APPLY_PROGRESS_POSITION";

drop view "_DBA_APPLY_ERROR_POSITION";
drop public synonym "_DBA_APPLY_ERROR_POSITION";

drop view "_ALL_APPLY_ERROR_POSITION";
drop public synonym "_ALL_APPLY_ERROR_POSITION";

Rem Drop AQ Notifications views on reg$ table
drop view USER_SUBSCR_REGISTRATIONS;
drop view DBA_SUBSCR_REGISTRATIONS;

Rem
Rem - NULL out the new columns in reg$ table for AQ Notifications
Rem
update REG$
   set reg_id                     = NULL,
       reg_time                   = NULL,
       ntfn_grouping_class        = NULL,
       ntfn_grouping_value        = NULL,
       ntfn_grouping_type         = NULL,
       ntfn_grouping_start_time   = NULL,
       ntfn_grouping_repeat_count = NULL,
       grouping_inst_id           = NULL;
commit;

Rem Drop Streams Unsupported column view
drop public synonym dba_streams_columns;
drop view dba_streams_columns;
drop public synonym all_streams_columns;
drop view all_streams_columns;
drop view "_DBA_STREAMS_UNSUPPORTED_11_1";
drop view "_DBA_STREAMS_NEWLY_SUPTED_11_1";

drop sequence streams$_sm_id;

Rem  Move capture process flags to old positions.
declare
  SCRIPT_VER        constant binary_integer := 10;
  COMMON_BITS_09_10 constant binary_integer := to_number(  '201','xxxxxxxx');
  COMMON_BITS_09_11 constant binary_integer := to_number(    '1','xxxxxxxx');
  COMMON_BITS_10_11 constant binary_integer := to_number(  '1ff','xxxxxxxx');
  CLONE_09          constant binary_integer := to_number(    '2','xxxxxxxx');
  CLONE_11          constant binary_integer := to_number( '4000','xxxxxxxx');
  SESS_AUDIT_09     constant binary_integer := to_number(  '200','xxxxxxxx');
  SESS_AUDIT_10     constant binary_integer := SESS_AUDIT_09;
  SESS_AUDIT_11     constant binary_integer := to_number(  '800','xxxxxxxx');
  SESS_ATTR_FREE_10 constant binary_integer := to_number(  '400','xxxxxxxx');
  SESS_ATTR_FREE_11 constant binary_integer := to_number('10000','xxxxxxxx');
  clone          boolean;
  sess_audit     boolean;
  sess_attr_free boolean;
  lowver         binary_integer;
  highver        binary_integer;
begin
  select substr( prv_version, 1, instr(prv_version,'.')-1 ) into lowver
    from registry$ where cid='CATPROC';
  select substr( version, 1, instr(version,'.')-1 ) into highver
    from registry$ where cid='CATPROC';

  if lowver = 9 and highver = 10 then
    if SCRIPT_VER = 9 then
      -- clear the other bits
      update streams$_capture_process
              set flags = bitand( flags, COMMON_BITS_09_10 );
      commit;
    end if;

  elsif lowver = 9 and highver >= 11 then
    if SCRIPT_VER = 9 then
      for r in (select flags, rowid from streams$_capture_process) loop
        clone      := bitand( r.flags, CLONE_11      ) > 0;
        sess_audit := bitand( r.flags, SESS_AUDIT_11 ) > 0;
        r.flags    := bitand( r.flags, COMMON_BITS_09_11 );
        if clone then
          r.flags := r.flags + CLONE_09;
        end if;
        if sess_audit then
          r.flags := r.flags + SESS_AUDIT_09;
        end if;
        -- set the two bits and clear the others
        update streams$_capture_process
                set flags = r.flags where rowid = r.rowid;
      end loop;
      commit;
    end if;

  elsif lowver = 10 and highver >= 11 then
    if SCRIPT_VER = 10 then
      for r in (select flags, rowid from streams$_capture_process) loop
        sess_audit     := bitand( r.flags, SESS_AUDIT_11     ) > 0;
        sess_attr_free := bitand( r.flags, SESS_ATTR_FREE_11 ) > 0;
        r.flags        := bitand( r.flags, COMMON_BITS_10_11 );
        if sess_audit then
          r.flags := r.flags + SESS_AUDIT_10;
        end if;
        if sess_attr_free then
          r.flags := r.flags + SESS_ATTR_FREE_10;
        end if;
        -- set the two bits and clear the others
        update streams$_capture_process
                set flags = r.flags where rowid = r.rowid;
      end loop;
      commit;
    end if;

  end if;
end;
/

Rem=======================
Rem Streams Changes End
Rem=======================

Rem=========================================================================
Rem Begin DBSNMP objects for DB Feature Usage
Rem=========================================================================
drop procedure dbsnmp.mgmt_update_db_feature_log;
drop table dbsnmp.mgmt_db_feature_log;

Rem=========================================================================
Rem END  DBSNMP objects for DB Feature Usage
Rem=========================================================================

Rem===================
Rem AWR Changes Begin
Rem===================
drop view DBA_HIST_EVENT_HISTOGRAM;
drop public synonym DBA_HIST_EVENT_HISTOGRAM;
drop view DBA_HIST_MUTEX_SLEEP;
drop public synonym DBA_HIST_MUTEX_SLEEP;
drop view DBA_HIST_COLORED_SQL;
drop public synonym DBA_HIST_COLORED_SQL;
drop view DBA_HIST_MEMORY_TARGET_ADVICE;
drop public synonym DBA_HIST_MEMORY_TARGET_ADVICE;
drop view DBA_HIST_MEMORY_RESIZE_OPS;
drop public synonym DBA_HIST_MEMORY_RESIZE_OPS;
drop view DBA_HIST_BASELINE_METADATA;
drop public synonym DBA_HIST_BASELINE_METADATA;
drop view DBA_HIST_BASELINE_DETAILS;
drop public synonym DBA_HIST_BASELINE_DETAILS;
drop view DBA_HIST_BASELINE_TEMPLATE;
drop public synonym DBA_HIST_BASELINE_TEMPLATE;
drop view DBA_HIST_MEM_DYNAMIC_COMP;
drop public synonym DBA_HIST_MEM_DYNAMIC_COMP;
drop view DBA_HIST_IC_CLIENT_STATS;
drop public synonym DBA_HIST_IC_CLIENT_STATS;
drop view DBA_HIST_IC_DEVICE_STATS;
drop public synonym DBA_HIST_IC_DEVICE_STATS;
drop view DBA_HIST_INTERCONNECT_PINGS;
drop public synonym DBA_HIST_INTERCONNECT_PINGS;



truncate table WRH$_EVENT_HISTOGRAM;
truncate table WRH$_EVENT_HISTOGRAM_BL;
truncate table WRH$_MUTEX_SLEEP;
truncate table WRM$_COLORED_SQL;
truncate table WRH$_MEMORY_TARGET_ADVICE;
truncate table WRH$_MEMORY_RESIZE_OPS;
truncate table WRM$_BASELINE_DETAILS;
truncate table WRM$_BASELINE_TEMPLATE;
truncate table WRH$_MEM_DYNAMIC_COMP;
truncate table WRH$_IC_DEVICE_STATS;
truncate table WRH$_IC_CLIENT_STATS;
truncate table WRH$_INTERCONNECT_PINGS;
truncate table WRH$_INTERCONNECT_PINGS_BL;
truncate table WRM$_SNAPSHOT_DETAILS;

drop type AWRBL_DETAILS_TYPE_TABLE force;
drop type AWRBL_DETAILS_TYPE force;


drop view DBA_HIST_PERSISTENT_QUEUES;
drop public synonym DBA_HIST_PERSISTENT_QUEUES;
drop view DBA_HIST_PERSISTENT_SUBS;
drop public synonym DBA_HIST_PERSISTENT_SUBS;

truncate table WRH$_PERSISTENT_QUEUES;
truncate table WRH$_PERSISTENT_SUBSCRIBERS;

Rem 
Rem  WRH$_ACTIVE_SESSION_HISTORY changes 
Rem 
drop view DBA_HIST_ACTIVE_SESS_HISTORY;
drop public synonym DBA_HIST_ACTIVE_SESS_HISTORY;

Rem  WRH$_IOSTAT_FUNCTION changes
drop view DBA_HIST_IOSTAT_FUNCTION;
drop public synonym DBA_HIST_IOSTAT_FUNCTION;
truncate table WRH$_IOSTAT_FUNCTION;

Rem  WRH$_IOSTAT_FUNCTION_NAME changes
drop view DBA_HIST_IOSTAT_FUNCTION_NAME;
drop public synonym DBA_HIST_IOSTAT_FUNCTION_NAME;
truncate table WRH$_IOSTAT_FUNCTION_NAME;

Rem  WRH$_IOSTAT_FILETYPE changes
drop view DBA_HIST_IOSTAT_FILETYPE;
drop public synonym DBA_HIST_IOSTAT_FILETYPE;
truncate table WRH$_IOSTAT_FILETYPE;

Rem  WRH$_IOSTAT_FILETYPE_NAME changes
drop view DBA_HIST_IOSTAT_FILETYPE_NAME;
drop public synonym DBA_HIST_IOSTAT_FILETYPE_NAME;
truncate table WRH$_IOSTAT_FILETYPE_NAME;

Rem  WRH$_RSRC_CONSUMER_GROUP changes
drop view DBA_HIST_RSRC_CONSUMER_GROUP;
drop public synonym DBA_HIST_RSRC_CONSUMER_GROUP;
truncate table WRH$_RSRC_CONSUMER_GROUP;

Rem  WRH$_RSRC_PLAN changes
drop view DBA_HIST_RSRC_PLAN;
drop public synonym DBA_HIST_RSRC_PLAN;
truncate table WRH$_RSRC_PLAN;

Rem  WRH$_CLUSTER_INTERCON changes
drop view DBA_HIST_CLUSTER_INTERCON;
drop public synonym DBA_HIST_CLUSTER_INTERCON;
truncate table WRH$_CLUSTER_INTERCON;

delete from WRM$_BASELINE where baseline_id = 0;
commit;

Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem Bug#5518178: in 11g the size of optimizer env column was extended 
Rem   from 1000 to 2000. In here we do not resize the column back to 
Rem   1000, but instead to set all values that are longer then 1000
Rem   to be NULL. 
Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
UPDATE wrh$_optimizer_env SET optimizer_env = NULL
WHERE utl_raw.length(optimizer_env) > 1000
/


Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==          (10gR2 = SWRF Version 2)                 ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  downgrade changes.  Place all other AWR          ==
Rem ==  downgrade changes above this.                    ==
Rem =======================================================

BEGIN
  UPDATE wrm$_wr_control SET swrf_version = 2;
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

Rem=================
Rem AWR Changes End
Rem=================


Rem =================
Rem WRR Changes Begin
Rem =================

Rem New Database Properties
Rem =======================
delete from PROPS$ where name = 'WORKLOAD_CAPTURE_MODE';
delete from PROPS$ where name = 'WORKLOAD_REPLAY_MODE';
commit;

Rem WRR Tables and Sequences
Rem ========================
truncate table WRR$_FILTERS;

truncate table WRR$_CAPTURES;
drop sequence WRR$_CAPTURE_ID;

truncate table WRR$_CAPTURE_STATS;

truncate table WRR$_REPLAYS;
drop sequence WRR$_REPLAY_ID;

truncate table WRR$_REPLAY_DIVERGENCE;

truncate table WRR$_REPLAY_SCN_ORDER;

truncate table WRR$_REPLAY_SEQ_DATA;

truncate table WRR$_CONNECTION_MAP;

Rem WRR Views
Rem =========

drop view dba_workload_filters;
drop public synonym dba_workload_filters;

drop view dba_workload_captures;
drop public synonym dba_workload_captures;

drop view dba_workload_replays;
drop public synonym dba_workload_replays;

drop view dba_workload_replay_divergence;
drop public synonym dba_workload_replay_divergence;

drop view dba_workload_connection_map;
drop public synonym dba_workload_connection_map;

Rem WRR Packages and Libraries
Rem ==========================

drop package dbms_workload_capture;
drop public synonym dbms_workload_capture;

drop package dbms_workload_replay;
drop public synonym dbms_workload_replay;

drop package dbms_wrr_internal;

drop library dbms_workload_capture_lib;
drop library dbms_workload_replay_lib;

Rem ===============
Rem WRR Changes End
Rem ===============


Rem ======================
Rem CDC Changes Begin
Rem ====================== 

Rem Null out added columns
update  CDC_CHANGE_SETS$ 
  set lowest_timestamp = NULL,
      time_scn_name = NULL;
COMMIT;

Rem ======================
Rem CDC Changes End
Rem ====================== 

Rem ======================
Rem DefPWD changes BEGIN
Rem ======================

truncate table SYS.DEFAULT_PWD$;

Rem ======================
Rem DefPWD changes end
Rem ======================

Rem ----------------------------------------
Rem Extended stats related changes - BEGIN
Rem ----------------------------------------

Rem Drop views (and related objects) that shows statistics extensions 

DROP PUBLIC SYNONYM all_stat_extensions;
DROP VIEW all_stat_extensions;

DROP PUBLIC SYNONYM dba_stat_extensions;
DROP VIEW dba_stat_extensions;

DROP PUBLIC SYNONYM user_stat_extensions;
DROP VIEW user_stat_extensions;

DROP FUNCTION GET_STATS_EXTENSION;

Rem ----------------------------------------
Rem Extended stats related changes - END
Rem ----------------------------------------


Rem ==============================================
Rem Incremental maintenance of stats changes begin
Rem ============================================== 

truncate table sys.WRI$_OPTSTAT_SYNOPSIS_PARTGRP;
truncate table sys.WRI$_OPTSTAT_SYNOPSIS$;
delete from sys.WRI$_OPTSTAT_SYNOPSIS_HEAD$;
COMMIT;

Rem ============================================
Rem Incremental maintenance of stats changes End
Rem ============================================

Rem ============================================================================
Rem Begin advisor framework changes
Rem ============================================================================

Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem 0. downgrade sqltune tasks here. sqltune is the only multi-exec advisor 
Rem    in 11g. Its tasks might have multiple executions. When dowgrading
Rem    we always keep the last execution. 
Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

BEGIN 
  FOR rec IN (SELECT task_id, name 
              FROM wri$_adv_executions e
              WHERE e.advisor_id = 4 AND 
                    NOT EXISTS (SELECT 0 
                                FROM wri$_adv_tasks t
                                WHERE t.id = e.task_id AND 
                                      t.last_exec_name = e.name AND
                                      t.advisor_id = 4))
  LOOP
    -- delete from advisor framework tables
    DELETE wri$_adv_tasks 
      WHERE id = rec.task_id AND last_exec_name = rec.name;
    DELETE wri$_adv_objects 
      WHERE task_id = rec.task_id AND exec_name = rec.name;
    DELETE wri$_adv_findings 
      WHERE task_id = rec.task_id AND exec_name = rec.name;
    DELETE wri$_adv_recommendations 
      WHERE task_id = rec.task_id AND exec_name = rec.name;
    DELETE wri$_adv_actions 
      WHERE task_id = rec.task_id AND exec_name = rec.name;
    DELETE wri$_adv_rationale 
       WHERE task_id = rec.task_id AND exec_name = rec.name;
    DELETE wri$_adv_journal 
       WHERE task_id = rec.task_id AND exec_name = rec.name;
    DELETE wri$_adv_message_groups 
       WHERE task_id = rec.task_id AND exec_name = rec.name;
   
   -- delete from sqltune tables 
    DELETE wri$_adv_sqlt_plans l
       WHERE EXISTS (select plan_id 
                     from wri$_adv_sqlt_plan_hash p
                     where p.plan_id = l.plan_id AND
                           task_id = rec.task_id AND 
                           exec_name = rec.name);

    DELETE wri$_adv_sqlt_rtn_plan
       WHERE task_id = rec.task_id AND exec_name = rec.name;

  END LOOP; 
  
  -- commit; changes 
  commit;
END; 
/

Rem 
Rem rename sqltune task internal parameter _TRACE_CONTROL back to _SQLTUNE_TRACE.
Rem Please NOTE that the query we are using to rename the chaged parameter 
Rem refers to the advisor definition table which is truncated later in this file.
Rem So please this query must be executed first

Rem 1. rename parameter in the parameter definition table
UPDATE wri$_adv_def_parameters 
SET name = '_SQLTUNE_TRACE' 
WHERE name = '_TRACE_CONTROL' and 
      advisor_id = (SELECT id 
                    FROM wri$_adv_definitions 
                    WHERE name = 'SQL Tuning Advisor');

Rem 2. rename parameter for the existing sql tuning advisor tasks  
UPDATE wri$_adv_parameters p 
SET name = '_SQLTUNE_TRACE' 
WHERE name = '_TRACE_CONTROL' AND 
      EXISTS (SELECT 1 
              FROM wri$_adv_tasks t 
              WHERE p.task_id = t.id AND 
              t.advisor_name = 'SQL Tuning Advisor');

Rem
Rem the _sqltune_control parameter has an additional value for the
Rem alternate plan analysis engine in 11g.  Change the default parameter
Rem value prior to downgrade.

UPDATE wri$_adv_def_parameters 
SET value = '7' 
WHERE name = '_SQLTUNE_CONTROL' and advisor_id = 4 and value = '15';

commit;

Rem ++++++++++++++++++++++++++++++++++++++++++
Rem 1. Changes in the advisor abstract objects
Rem ++++++++++++++++++++++++++++++++++++++++++
Rem drop existing methods here
Rem ++++++++++++++++++++++++++++

Rem
Rem sub_create (New to SQL Access Advisor 11g)
Rem

ALTER TYPE wri$_adv_sqlaccess_adv
  DROP OVERRIDING MEMBER procedure sub_create(task_id IN NUMBER, 
                                              from_task_id IN NUMBER)
  CASCADE;

Rem 
Rem sub_resume
Rem 
ALTER TYPE wri$_adv_sqltune
  DROP OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER, 
                                              err_num OUT NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_sqlaccess_adv
  DROP OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER, 
                                              err_num OUT NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_tunemview_adv
  DROP OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER, 
                                             err_num OUT NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_abstract_t
  DROP MEMBER procedure sub_resume(task_id IN NUMBER, err_num OUT NUMBER)
  CASCADE;

Rem 
Rem sub_script
Rem 
ALTER TYPE wri$_adv_sqltune 
  DROP OVERRIDING MEMBER procedure sub_get_script(task_id IN NUMBER,
                                                  type IN VARCHAR2,
                                                  buffer IN OUT NOCOPY CLOB,
                                                  rec_id IN NUMBER,
                                                  act_id IN NUMBER,
                                                  execution_name IN VARCHAR2,
                                                  object_id IN NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_abstract_t
  DROP MEMBER procedure sub_get_script(task_id IN NUMBER,
                                       type IN VARCHAR2,
                                       buffer IN OUT NOCOPY CLOB,
                                       rec_id IN NUMBER,
                                       act_id IN NUMBER,
                                       execution_name IN VARCHAR2,
                                       object_id IN NUMBER)
  CASCADE;

Rem 
Rem sub_report
Rem 
ALTER TYPE wri$_adv_sqltune 
  DROP OVERRIDING MEMBER procedure sub_get_report(task_id IN NUMBER,
                                                  type IN VARCHAR2,
                                                  level IN VARCHAR2,
                                                  section IN VARCHAR2,
                                                  buffer IN OUT NOCOPY CLOB, 
                                                  execution_name IN VARCHAR2,
                                                  object_id IN NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_abstract_t
  DROP MEMBER procedure sub_get_report(task_id IN NUMBER,
                                       type IN VARCHAR2,
                                       level IN VARCHAR2,
                                       section IN VARCHAR2,
                                       buffer IN OUT NOCOPY CLOB, 
                                       execution_name IN VARCHAR2,
                                       object_id IN NUMBER)
  CASCADE;

Rem
Rem sub_delete_execution
Rem

ALTER TYPE wri$_adv_sqltune
  DROP OVERRIDING MEMBER procedure sub_delete_execution(
                                                    task_id IN NUMBER, 
                                                    execution_name IN VARCHAR2)
  CASCADE;

ALTER TYPE wri$_adv_abstract_t
  DROP MEMBER procedure sub_delete_execution(task_id IN NUMBER, 
                                             execution_name IN VARCHAR2)
  CASCADE;

Rem
Rem sub_param_validate
Rem 
ALTER TYPE wri$_adv_sqltune 
  DROP OVERRIDING MEMBER procedure sub_param_validate(task_id IN NUMBER,
                                                      name    IN VARCHAR2, 
                                                      value   IN OUT VARCHAR2)
  CASCADE;

Rem add new methods here
Rem ++++++++++++++++++++++++++++

Rem 
Rem sub_resume
Rem 
ALTER TYPE wri$_adv_abstract_t
  ADD MEMBER procedure sub_resume(task_id IN NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_sqltune
  ADD OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER) 
  CASCADE;

ALTER TYPE wri$_adv_sqlaccess_adv
  ADD OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_tunemview_adv
  ADD OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER)
  CASCADE;


Rem 
Rem sub_script
Rem 
ALTER TYPE wri$_adv_sqltune 
  ADD OVERRIDING MEMBER procedure sub_get_script(task_id IN NUMBER,
                                                 type IN VARCHAR2,
                                                 buffer IN OUT NOCOPY CLOB,
                                                 rec_id IN NUMBER,
                                                 act_id IN NUMBER)
  CASCADE;


Rem 
Rem sub_report
Rem 
ALTER TYPE wri$_adv_sqltune 
  ADD OVERRIDING MEMBER procedure sub_get_report(task_id IN NUMBER,
                                                 type IN VARCHAR2,
                                                 level IN VARCHAR2,
                                                 section IN VARCHAR2,
                                                 buffer IN OUT NOCOPY CLOB)
  CASCADE;

Rem +++++++++++++++++++++++++++++++++++++++++++
Rem 2. Changes in the advisor dictionary tables
Rem +++++++++++++++++++++++++++++++++++++++++++
Rem truncate the advisor definition table so that all 
Rem advisor objects will be recreated. 
TRUNCATE TABLE wri$_adv_definitions;

update wri$_adv_findings set filtered = NULL;
update wri$_adv_findings set flags = NULL;
update wri$_adv_recommendations set filtered = NULL;
update wri$_adv_actions set filtered = NULL;

Rem drop new types here because there is dependent instances in the 
Rem wri$_adv_definition table truncated above. 
Rem Notice that when we drop a sub-type, we do it with validate option
Rem instead of FORCE, otherwise column TYPE of the table will be 
Rem marked as unusable and wont be part of the table. 
Rem ++++++++++++++++++++++++++++
DROP TYPE sys.wri$_adv_sqlpi VALIDATE;

Rem
Rem change type properties here 
Rem ++++++++++++++++++++++++++++
ALTER TYPE wri$_adv_sqltune FINAL CASCADE;

Rem drop new views and synonyms in 11g

DROP PUBLIC SYNONYM DBA_OLDIMAGE_COLUMNS;
DROP PUBLIC SYNONYM USER_OLDIMAGE_COLUMNS;

DROP PUBLIC SYNONYM dba_advisor_finding_names;
DROP PUBLIC SYNONYM dba_advisor_execution_types;
DROP PUBLIC SYNONYM dba_advisor_executions;
DROP PUBLIC SYNONYM user_advisor_executions;
DROP PUBLIC SYNONYM dba_advisor_exec_parameters;
DROP PUBLIC SYNONYM user_advisor_exec_parameters;

DROP PUBLIC SYNONYM dba_advisor_dir_definitions;
DROP PUBLIC SYNONYM dba_advisor_dir_instances;
DROP PUBLIC SYNONYM dba_advisor_dir_task_inst;
DROP PUBLIC SYNONYM user_advisor_dir_task_inst;

DROP PUBLIC SYNONYM user_advisor_sqlstats;
DROP PUBLIC SYNONYM dba_advisor_sqlstats;
DROP PUBLIC SYNONYM user_advisor_sqlplans;
DROP PUBLIC SYNONYM dba_advisor_sqlplans;

DROP VIEW DBA_OLDIMAGE_COLUMNS;
DROP VIEW USER_OLDIMAGE_COLUMNS;

DROP VIEW dba_advisor_finding_names;
DROP VIEW dba_advisor_execution_types;
DROP VIEW dba_advisor_executions;
DROP VIEW user_advisor_executions;
DROP VIEW dba_advisor_exec_parameters;
DROP VIEW user_advisor_exec_parameters;

DROP VIEW dba_advisor_dir_definitions;
DROP VIEW dba_advisor_dir_instances;
DROP VIEW dba_advisor_dir_task_inst;
DROP VIEW user_advisor_dir_task_inst;

DROP view user_advisor_sqlstats;
DROP VIEW dba_advisor_sqlstats;
DROP view user_advisor_sqlplans;
DROP view dba_advisor_sqlplans;

Rem truncate new tables in 11g
TRUNCATE TABLE wri$_adv_def_exec_types
/
TRUNCATE TABLE wri$_adv_executions
/
TRUNCATE TABLE wri$_adv_exec_parameters
/
TRUNCATE TABLE wri$_adv_directive_instances
/
TRUNCATE TABLE wri$_adv_directive_meta
/
TRUNCATE TABLE wri$_adv_directive_defs
/
Rem notice that plan related tables are truncated in sqltune section below. 

Rem drop new sequences in 11g
DROP SEQUENCE wri$_adv_seq_exec
/

Rem update new columns in 11g
UPDATE sys.wri$_adv_findings set name_msg_code = NULL
/
UPDATE wri$_adv_def_parameters set exec_type = NULL
/
UPDATE wri$_adv_tasks set last_exec_name = NULL
/
UPDATE wri$_adv_objects set 
  exec_name = NULL,
  attr6     = NULL,
  attr7     = NULL,
  attr8     = NULL,
  attr9     = NULL,
  attr10    = NULL
/
UPDATE wri$_adv_findings set exec_name = NULL
/
UPDATE wri$_adv_recommendations set exec_name = NULL
/
UPDATE wri$_adv_actions set  exec_name = NULL
/
UPDATE wri$_adv_rationale set exec_name = NULL
/
UPDATE wri$_adv_journal set exec_name = NULL
/
UPDATE wri$_adv_message_groups set exec_name = NULL
/

Rem persist changes
commit; 

Rem ===========================================================================
Rem End advisor framework changes
Rem ===========================================================================

Rem ===========================================================================
Rem Begin sql tuning advisor changes
Rem ===========================================================================

Rem The temp table we use for captures now has a different primary key name
ALTER TABLE wri$_sqlset_plans_tocap 
RENAME CONSTRAINT wri$_sqlset_plans_tocap_pk TO wri$_sqlset_plans_tocap;

Rem Rename the index using EXEC IMMED to avoid errors on re-run (these are not
Rem suppressed)
begin
  EXECUTE IMMEDIATE 'ALTER INDEX wri$_sqlset_plans_tocap_pk ' ||
                    'RENAME TO wri$_sqlset_plans_tocap';
exception
  when others then
    if (sqlcode = -1418) then              /* specified index does not exist */
      null;
    else
      raise;
    end if;
end;
/

Rem (We drop the new columns to plan_lines below, in the conditional step)


Rem ++++++++++++++++++++++++++++++++++++++++++
Rem Changes in the SQL tuning advisor tables
Rem ++++++++++++++++++++++++++++++++++++++++++
Rem plan table
ALTER TABLE wri$_adv_sqlt_plans DROP CONSTRAINT wri$_adv_sqlt_plans_pk
/
UPDATE wri$_adv_sqlt_plans l 
 SET (task_id, object_id, attribute, plan_hash_value) = 
     (SELECT task_id, object_id, attribute, plan_hash 
      FROM wri$_adv_sqlt_plan_hash p
      WHERE p.plan_id = l.plan_id)
/
UPDATE wri$_adv_sqlt_plans SET plan_id = NULL
/
ALTER TABLE wri$_adv_sqlt_plans ADD CONSTRAINT wri$_adv_sqlt_plans_pk
  PRIMARY KEY(task_id, object_id, attribute, id)
  USING INDEX TABLESPACE SYSAUX
/

Rem plan-rational association table 
ALTER TABLE wri$_adv_sqlt_rtn_plan DROP CONSTRAINT wri$_adv_sqlt_rtn_plan_pk
/
UPDATE wri$_adv_sqlt_rtn_plan SET exec_name = NULL
/
ALTER TABLE wri$_adv_sqlt_rtn_plan ADD CONSTRAINT wri$_adv_sqlt_rtn_plan_pk
  PRIMARY KEY(task_id, rtn_id, object_id, plan_attr, operation_id)
  USING INDEX TABLESPACE SYSAUX
/

Rem truncate test_execute new tables. 
Rem Note that plan related dba/user new 11g are part of the advisor framework
Rem Their names have also changed to contain advisor domain name instead 
Rem of sqltune. Truncating this tables should be done in the advisor framework
Rem section. 
TRUNCATE TABLE wri$_adv_sqlt_plan_hash
/
TRUNCATE TABLE wri$_adv_sqlt_plan_stats 
/
DROP SEQUENCE WRI$_ADV_SQLT_PLAN_SEQ
/

Rem drop sql profile new views
DROP PUBLIC SYNONYM dba_sql_profile_statistics;
DROP VIEW dba_sql_profile_statistics;

Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem Bug#5518178: in 11g the size of optimizer env column was extended 
Rem   from 1000 to 2000. In here we do not resize the column back to 
Rem   1000, but instead to set all values that are longer then 1000
Rem   to be NULL.
Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
UPDATE wri$_adv_sqlt_statistics SET optimizer_env = NULL
WHERE utl_raw.length(optimizer_env) > 1000
/
UPDATE wri$_sqlset_plans SET optimizer_env = NULL
WHERE utl_raw.length(optimizer_env) > 1000
/
Rem
Rem Notice that only widening of type attributes is allowed. This 
Rem is why we drop this type here and in the c1002000 upgrade script 
Rem instead of changing its size. The type will be re-created 
Rem when running catsqlt.sql. 
Rem
DROP PUBLIC SYNONYM sqlset
/
DROP TYPE sqlset FORCE
/
DROP PUBLIC SYNONYM sqlset_row
/
DROP TYPE sqlset_row FORCE
/

Rem +++++++++++++++++++++++++++++++++
Rem SQL tuning set workspace changes
Rem +++++++++++++++++++++++++++++++++
Rem NOTE: We drop the workspace because it stores a column of type 
Rem       sql_plan_table_type. 
Rem       this table will be re-created in the catsqlt.sql script. 
DROP TABLE wri$_sqlset_workspace
/
DROP SEQUENCE wri$_sqlset_workspace_plan_seq
/
DROP TABLE wri$_sqlset_workspace_plans
/

Rem +++++++++++++++++++++++++++++++++
Rem drop new packages here 
Rem +++++++++++++++++++++++++++++++++
DROP PACKAGE DBMS_SQLTUNE_UTIL1;
DROP PACKAGE DBMS_SQLTUNE_UTIL2;
DROP PACKAGE PRVT_SQLADV_INFRA;
DROP PACKAGE PRVT_SQLSET_INFRA;
DROP PACKAGE PRVT_SQLPROF_INFRA;
DROP PUBLIC SYNONYM DBMS_SQLPA;
DROP PACKAGE DBMS_SQLPA;
DROP PACKAGE PRVT_SQLPA;
DROP LIBRARY DBMS_SQLPA_LIB;

Rem ++++++++++++++++++++++++++++++++++++++++
Rem drop packages that refer to fixed tables
Rem ++++++++++++++++++++++++++++++++++++++++
DROP PUBLIC SYNONYM dbms_sqltune;
DROP PACKAGE dbms_sqltune;

Rem ===========================================================================
Rem End sql tuning advisor changes
Rem ===========================================================================

Rem ===========================================================================
Rem Begin ADDM changes
Rem ===========================================================================

alter type wri$_adv_hdm_t
drop overriding MEMBER PROCEDURE sub_param_validate(
               task_id in number, name in varchar2, value in out varchar2),
drop overriding member procedure sub_reset(task_id in number),
drop overriding member procedure sub_delete(task_id in number)
cascade;

truncate table wri$_adv_addm_tasks;
truncate table wri$_adv_addm_inst;
truncate table wri$_adv_addm_fdg;
truncate table wri$_adv_inst_fdg;
drop public synonym DBA_ADDM_TASKS;
drop public synonym USER_ADDM_TASKS;
drop public synonym DBA_ADDM_INSTANCES;
drop public synonym USER_ADDM_INSTANCES;
drop public synonym DBA_ADDM_FINDINGS;
drop public synonym USER_ADDM_FINDINGS;
drop public synonym DBA_ADDM_FDG_BREAKDOWN;
drop public synonym USER_ADDM_FDG_BREAKDOWN;
drop public synonym DBA_ADVISOR_FDG_BREAKDOWN;
drop public synonym USER_ADVISOR_FDG_BREAKDOWN;
drop public synonym dba_addm_system_directives;
drop public synonym dba_addm_task_directives;
drop public synonym user_addm_task_directives;
drop view DBA_ADDM_TASKS;
drop view USER_ADDM_TASKS;
drop view DBA_ADDM_INSTANCES;
drop view USER_ADDM_INSTANCES;
drop view DBA_ADDM_FINDINGS;
drop view USER_ADDM_FINDINGS;
drop view DBA_ADDM_FDG_BREAKDOWN;
drop view USER_ADDM_FDG_BREAKDOWN;
drop view DBA_ADVISOR_FDG_BREAKDOWN;
drop view USER_ADVISOR_FDG_BREAKDOWN;
drop view dba_addm_system_directives;
drop view dba_addm_task_directives;
drop view user_addm_task_directives;
drop public synonym dbms_addm;
drop package dbms_addm;
drop package prvt_hdm;

Rem ===========================================================================
Rem End ADDM changes
Rem ===========================================================================

Rem ===========================================================================
Rem Begin generic manageability changes
Rem ===========================================================================
drop public synonym dbms_management_packs;
drop package dbms_management_packs;
drop package prvt_smgutil;
drop library dbms_keg_lib;

Rem ===========================================================================
Rem End generic manageability changes
Rem ===========================================================================

Rem ==========================
Rem Begin AUTOTASK changes
Rem ==========================
  --
  -- Deal with schema objects
  --
  drop package dbms_auto_task_export;
  drop package dbms_auto_task_admin;
  drop public synonym dba_autotask_client;
  drop view dba_autotask_client;
  drop public synonym dba_autotask_client_history;
  drop view dba_autotask_client_history;
  drop public synonym dba_autotask_window_history;
  drop view dba_autotask_window_history;
  drop public synonym dba_autotask_window_clients;
  drop view dba_autotask_window_clients;
  drop public synonym DBA_AUTOTASK_SCHEDULE;
  drop view DBA_AUTOTASK_SCHEDULE;
  drop public synonym DBA_AUTOTASK_TASK;
  drop view  DBA_AUTOTASK_TASK;
  drop public synonym DBA_AUTOTASK_CLIENT_JOB;
  drop view  DBA_AUTOTASK_CLIENT_JOB;
  drop public synonym DBA_AUTOTASK_OPERATION;
  drop view DBA_AUTOTASK_OPERATION;
  drop public synonym dba_autotask_job_history;
  drop view dba_autotask_job_history;
  drop package dbms_auto_task;
  drop package dbms_autotask_prvt;
  drop package dbms_auto_task_immediate;
  truncate table ket$_autotask_status;
  truncate table ket$_client_config;
  truncate table ket$_client_tasks;
  drop type ket$_window_list;
  drop type ket$_window_type;
Rem ==========================
Rem End AUTOTASK changes
Rem ==========================

Rem ======================================
Rem Begin SQL Access Advisor downgrade 
Rem ======================================

Rem Resetting AA tasks is now done in f1002000.sql!

Rem delete unsupported rows from upgraded map table

delete from sys.wri$_adv_sqla_map
  where is_sts = 1;

Rem Change SQL_ID back to a number.  The table should be empty at this point.

alter table sys.wri$_adv_sqla_stmts
  modify sql_id number;

Rem new 11g views

drop public synonym dba_advisor_sqla_tabvol;
drop public synonym user_advisor_sqla_tabvol;
drop view dba_advisor_sqla_tabvol;
drop view user_advisor_sqla_tabvol;

drop public synonym dba_advisor_sqla_colvol;
drop public synonym user_advisor_sqla_colvol;
drop view dba_advisor_sqla_colvol;
drop view user_advisor_sqla_colvol;

drop public synonym dba_advisor_sqla_tables;
drop public synonym user_advisor_sqla_tables;
drop view dba_advisor_sqla_tables;
drop view user_advisor_sqla_tables;

drop public synonym dba_advisor_sqla_wk_sum;
drop public synonym user_advisor_sqla_wk_sum;
drop view dba_advisor_sqla_wk_sum;
drop view user_advisor_sqla_wk_sum;


Rem remove Datapump-based script package
drop package prvt_partrec_nopriv;

Rem
Rem Set the correct execution parameters for 10g
Rem

declare
  cursor param_cur  IS 
    SELECT name,value,task_id
      FROM sys.wri$_adv_parameters a
      WHERE name in ('ANALYSIS_SCOPE','RANKING_MEASURE');

  l_task_id binary_integer;
  l_data varchar2(2000);
  l_name varchar2(100);
  cnt binary_integer;
begin
  open param_cur;

  loop
    fetch param_cur INTO l_name,l_data,l_task_id;
    EXIT WHEN param_cur%NOTFOUND;

    if l_name = 'ANALYSIS_SCOPE' then
      if l_data = 'EVALUATION' then
        update sys.wri$_adv_parameters
          set value = 'TRUE'
          where name = 'EVALUATION_ONLY'
            and task_id = l_task_id;
      else
        if l_data = 'ALL' then
          l_data := 'FULL';
        elsif l_data = 'INDEX' then
          l_data := 'INDEX_ONLY';
        elsif l_data = 'MVIEW' then
          l_data := 'MVIEW_ONLY';
        elsif l_data = 'MVLOG' then
          l_data := 'MVIEW_LOG_ONLY';
        else
          l_data := 'ALL';
        end if;
  
        update sys.wri$_adv_parameters
          set value = l_data
          where name = 'EXECUTION_TYPE'
            and task_id = l_task_id;
      end if;
    elsif l_name = 'RANKING_MEASURE' then
      update sys.wri$_adv_parameters
        set value = l_data
        where name = 'ORDER_LIST'
          and task_id = l_task_id;
    end if;
  end loop;

  close param_cur;

  commit;
end;
/

Rem remove 11g task parameters

delete from sys.wri$_adv_def_parameters
  where advisor_id in (2,7)
    and name in 
     ('_IDX_MAX_AGG_OPS','_MAX_MV_PARTITIONSCHEMES','_MAX_PERCENT_MV_WORKLOAD',
      '_MAX_PUBLISH_POINTS','_PA_LIST_BUCKET_MIN_FREQ','_PA_MAX_NUM_PART_ENUMS',
      '_PA_MAX_NUM_PART_SCHEMES','_PA_MAX_NUM_PART_TABLES','_PA_MAX_NUM_PARTS',
      '_PA_MAX_WORKLOAD','_PA_MIN_COLUMNSET_UTIL','_PA_MIN_MVCOLUMNSET_UTIL',
      '_PA_MIN_NUM_PARTS','_PA_MIN_TABLE_SIZE_PART','_PA_OUTPUT_INTERVALS',
      '_PA_PUBLISH_POINT','_PA_QRY_LIMIT_PART','_PA_REC_THRESHOLD_START',
      '_PA_TARGET_NUM_PARTS','_SCRIPT_VERSION','_SQL_LIMIT','_TEST_FACTORS',
      '_WK_CHUNK_FACTOR','_WK_CHUNK_SIZE','ANALYSIS_SCOPE','COMPATIBILITY',
      'DEF_PARTITION_TABLESPACE','LIMIT_PARTITION_SCHEMES','MAX_NUMBER_PARTITIONS',
      'PARTITION_NAME_TEMPLATE','PARTITIONING_GOAL','PARTITIONING_TYPES',
      'RANKING_MEASURE','TUNE_MVIEW','USE_BASE_TABLE_PARTITIONS','USE_ILM',
      'USE_SEPARATE_TABLESPACES','WORKLOAD_COMPRESSION','WORKLOAD_SAMPLING');

delete from sys.wri$_adv_parameters
  where name in
     ('_IDX_MAX_AGG_OPS','_MAX_MV_PARTITIONSCHEMES','_MAX_PERCENT_MV_WORKLOAD',
      '_MAX_PUBLISH_POINTS','_PA_LIST_BUCKET_MIN_FREQ','_PA_MAX_NUM_PART_ENUMS',
      '_PA_MAX_NUM_PART_SCHEMES','_PA_MAX_NUM_PART_TABLES','_PA_MAX_NUM_PARTS',
      '_PA_MAX_WORKLOAD','_PA_MIN_COLUMNSET_UTIL','_PA_MIN_MVCOLUMNSET_UTIL',
      '_PA_MIN_NUM_PARTS','_PA_MIN_TABLE_SIZE_PART','_PA_OUTPUT_INTERVALS',
      '_PA_PUBLISH_POINT','_PA_QRY_LIMIT_PART','_PA_REC_THRESHOLD_START',
      '_PA_TARGET_NUM_PARTS','_SCRIPT_VERSION','_SQL_LIMIT','_TEST_FACTORS',
      '_WK_CHUNK_FACTOR','_WK_CHUNK_SIZE','ANALYSIS_SCOPE','COMPATIBILITY',
      'DEF_PARTITION_TABLESPACE','LIMIT_PARTITION_SCHEMES','MAX_NUMBER_PARTITIONS',
      'PARTITION_NAME_TEMPLATE','PARTITIONING_GOAL','PARTITIONING_TYPES',
      'RANKING_MEASURE','TUNE_MVIEW','USE_BASE_TABLE_PARTITIONS','USE_ILM',
      'USE_SEPARATE_TABLESPACES','WORKLOAD_COMPRESSION','WORKLOAD_SAMPLING')
    and task_id in (select id from sys.wri$_adv_tasks
                     where advisor_id in (2,7));

commit;

Rem ======================================
Rem End SQL Access Advisor downgrade 
Rem ======================================

Rem ======================================
Rem Begin drop Data Mining catalog views 
Rem ======================================
DROP VIEW DBA_MINING_MODELS;
DROP VIEW ALL_MINING_MODELS;
DROP VIEW USER_MINING_MODELS;
DROP VIEW DBA_MINING_MODEL_TABLES;
DROP VIEW DBA_MINING_MODEL_ATTRIBUTES;
DROP VIEW ALL_MINING_MODEL_ATTRIBUTES;
DROP VIEW USER_MINING_MODEL_ATTRIBUTES;
DROP VIEW DBA_MINING_MODEL_SETTINGS;
DROP VIEW ALL_MINING_MODEL_SETTINGS;
DROP VIEW ALL_MINING_MODEL_SETTINGS;
DROP VIEW DM_USER_MODELS;

Rem ======================================
Rem End drop Data Mining catalog views
Rem ======================================

Rem ======================================
Rem Begin drop Editioning View views
Rem ======================================

DROP VIEW user_editioning_views;
DROP VIEW all_editioning_views;
DROP VIEW dba_editioning_views;

DROP VIEW user_editioning_view_cols;
DROP VIEW all_editioning_view_cols;
DROP VIEW dba_editioning_view_cols;

Rem ======================================
Rem End drop Editioning View views
Rem ======================================

Rem ============================
Rem Begin dbms_report changes
Rem ============================

DROP VIEW report_components;
DROP VIEW report_files;
DROP VIEW report_formats;
DROP VIEW "_REPORT_COMPONENT_OBJECTS";
DROP VIEW "_REPORT_FORMATS";

-- 
-- We have to drop the components table rather than truncating it to avoid
-- issues on re-upgrade (e.g., the drop type force below of the abstract 
-- object causes the "object" column of this table to disappear, and it
-- is not re-added during upgrade)
-- 
DROP TABLE wri$_rept_components;
TRUNCATE TABLE wri$_rept_reports;
TRUNCATE TABLE wri$_rept_files;
TRUNCATE TABLE wri$_rept_formats; 

DROP SEQUENCE wri$_rept_comp_id_seq;
DROP SEQUENCE wri$_rept_rept_id_seq;
DROP SEQUENCE wri$_rept_file_id_seq;
DROP SEQUENCE wri$_rept_format_id_seq;

Rem =========================
Rem End dbms_report changes
Rem =========================

Rem ----------------------------------------
Rem Resource Manager related changes - BEGIN
Rem ----------------------------------------

update resource_plan$ set
  cpu_method = mgmt_method
  where mgmt_method is not null;

update resource_plan$ set 
  sub_plan    = NULL,
  mgmt_method = NULL,
  max_iops    = NULL,
  max_mbps    = NULL;

update resource_consumer_group$ set 
  cpu_method = mgmt_method
  where mgmt_method is not null;

update resource_consumer_group$ set 
  internal_use = NULL,
  mgmt_method = NULL,
  category = NULL;

truncate table resource_category$;

update resource_plan_directive$ set
  cpu_p1 = mgmt_p1,
  cpu_p2 = mgmt_p2,
  cpu_p3 = mgmt_p3,
  cpu_p4 = mgmt_p4,
  cpu_p5 = mgmt_p5,
  cpu_p6 = mgmt_p6,
  cpu_p7 = mgmt_p7,
  cpu_p8 = mgmt_p8,
  switch_back = switch_for_call
  where switch_io_megabytes is not null;

update resource_plan_directive$ set
  mgmt_p1             = NULL,
  mgmt_p2             = NULL,
  mgmt_p3             = NULL,
  mgmt_p4             = NULL,
  mgmt_p5             = NULL,
  mgmt_p6             = NULL,
  mgmt_p7             = NULL,
  mgmt_p8             = NULL,
  switch_for_call     = NULL,
  switch_io_megabytes = NULL,
  switch_io_reqs      = NULL;

truncate table resource_storage_pool_mapping$;
truncate table resource_capability$;
truncate table resource_instance_capability$;
truncate table resource_io_calibrate$;

drop view DBA_RSRC_STORAGE_POOL_MAPPING;
drop view DBA_RSRC_CAPABILITY;
drop view DBA_RSRC_INSTANCE_CAPABILITY;
drop view DBA_RSRC_IO_CALIBRATE;

drop public synonym DBA_RSRC_STORAGE_POOL_MAPPING;
drop public synonym DBA_RSRC_CAPABILITY;
drop public synonym DBA_RSRC_INSTANCE_CAPABILITY;
drop public synonym DBA_RSRC_IO_CALIBRATE;

delete from resource_group_mapping$ where
  attribute = 'PERFORMANCE_CLASS';
commit;

Rem --------------------------------------
Rem Resource Manager related changes - END
Rem --------------------------------------

Rem =====================================
Rem Begin drop Flashback Archive changes
Rem =====================================
drop view DBA_FLASHBACK_ARCHIVE;
drop view DBA_FLASHBACK_ARCHIVE_TS;
drop view DBA_FLASHBACK_ARCHIVE_TABLES;
drop view USER_FLASHBACK_ARCHIVE;
drop view USER_FLASHBACK_ARCHIVE_TABLES;

drop public synonym DBA_FLASHBACK_ARCHIVE;
drop public synonym DBA_FLASHBACK_ARCHIVE_TS;
drop public synonym DBA_FLASHBACK_ARCHIVE_TABLES;
drop public synonym USER_FLASHBACK_ARCHIVE;
drop public synonym USER_FLASHBACK_ARCHIVE_TABLES;

Rem Clear FBA internal bit
update  tab$ set property = property - power(2,33)
  where bitand(property,power(2,33)) = power(2,33);
commit;

Rem =====================================
Rem End drop Flashback Archive changes
Rem =====================================

Rem --------------------------------------------------
Rem Remove Flashback Transaction Backout changes - END
Rem --------------------------------------------------
drop public synonym USER_FLASHBACK_TXN_STATE;
drop public synonym USER_FLASHBACK_TXN_REPORT;
drop public synonym DBA_FLASHBACK_TXN_STATE;
drop public synonym DBA_FLASHBACK_TXN_REPORT;
drop view DBA_FLASHBACK_TXN_STATE;
drop view DBA_FLASHBACK_TXN_REPORT;
drop view USER_FLASHBACK_TXN_STATE;
drop view USER_FLASHBACK_TXN_REPORT;
truncate table TRANSACTION_BACKOUT_STATE$;
truncate table  TRANSACTION_BACKOUT_REPORT$;

drop public synonym v$flashback_txn_mods;
drop public synonym v$flashback_txn_graph;
drop view v_$flashback_txn_mods;
drop view v_$flashback_txn_graph;

Rem ------------------------------------------------------------------------
Rem move the smon scn-time mapping table from sysaux tablespace to sys - END
Rem ------------------------------------------------------------------------

Rem ==============================================
Rem BEGIN Clean optimizer statistics objects
Rem ==============================================

Rem truncate the preferences table
truncate table OPTSTAT_USER_PREFS$;

Rem drop public the new views
drop view ALL_TAB_PENDING_STATS;
drop view DBA_TAB_PENDING_STATS;
drop view USER_TAB_PENDING_STATS;

drop view ALL_IND_PENDING_STATS;
drop view DBA_IND_PENDING_STATS;
drop view USER_IND_PENDING_STATS;

drop view ALL_COL_PENDING_STATS;
drop view DBA_COL_PENDING_STATS;
drop view USER_COL_PENDING_STATS;

drop view ALL_TAB_HISTGRM_PENDING_STATS;
drop view DBA_TAB_HISTGRM_PENDING_STATS;
drop view USER_TAB_HISTGRM_PENDING_STATS;

drop view ALL_TAB_STAT_PREFS;
drop view DBA_TAB_STAT_PREFS;
drop view USER_TAB_STAT_PREFS;

Rem drop the new public synonyms
drop public synonym ALL_TAB_PENDING_STATS;
drop public synonym DBA_TAB_PENDING_STATS;
drop public synonym USER_TAB_PENDING_STATS;

drop public synonym ALL_IND_PENDING_STATS;
drop public synonym DBA_IND_PENDING_STATS;
drop public synonym USER_IND_PENDING_STATS;

drop public synonym ALL_COL_PENDING_STATS;
drop public synonym DBA_COL_PENDING_STATS;
drop public synonym USER_COL_PENDING_STATS;

drop public synonym ALL_TAB_HISTGRM_PENDING_STATS;
drop public synonym DBA_TAB_HISTGRM_PENDING_STATS;
drop public synonym USER_TAB_HISTGRM_PENDING_STATS;

drop public synonym ALL_TAB_STAT_PREFS;
drop public synonym DBA_TAB_STAT_PREFS;
drop public synonym USER_TAB_STAT_PREFS;


Rem ==============================================
Rem END Drop optimizer statistics objects
Rem ==============================================

create cluster smon_scn_to_time (
  thread number                                     /* thread, compatibility */
) tablespace SYSTEM
/

create index smon_scn_to_time_idx on cluster smon_scn_to_time
/

create table smon_scn_time_sys (
  thread number,                                    /* thread, compatibility */
  time_mp number,                         /* time this recent scn represents */
  time_dp date,                               /* time as date, compatibility */
  scn_wrp number,                                  /* scn.wrp, compatibility */
  scn_bas number,                                  /* scn.bas, compatibility */
  num_mappings number,
  tim_scn_map raw(1200),
  scn number default 0,                                               /* scn */
  orig_thread number default 0                              /* for downgrade */
) cluster smon_scn_to_time (thread)
/

rem copy over values from the old table
insert into smon_scn_time_sys select * from smon_scn_time
/

rem drop the table and its associated indeces
drop table smon_scn_time
/
drop cluster smon_scn_to_time_aux
/


rem rename the temporary table to its new name
alter table smon_scn_time_sys rename to smon_scn_time
/

rem recreate the indeces
create unique index smon_scn_time_tim_idx on smon_scn_time(time_mp) 
  tablespace SYSTEM
/
create unique index smon_scn_time_scn_idx on smon_scn_time(scn)
  tablespace SYSTEM
/


Rem change notification 11g related downgrades
drop view USER_CQ_NOTIFICATION_QUERIES;
drop view DBA_CQ_NOTIFICATION_QUERIES;

Rem truncate 11g change notification dictionary tables
truncate table chnf$_queries;
truncate table chnf$_reg_queries;
truncate table chnf$_query_object;
truncate table chnf$_clauses;
truncate table chnf$_clause_dependents;
truncate table chnf$_group_filter_iot;
truncate table chnf$_query_binds;
truncate table chnfdirectload$;

Rem downgrade the evolved type
drop public synonym CQ_NOTIFICATION$_DESCRIPTOR
/

alter type sys.chnf$_desc drop attribute (query_desc_array) cascade;

Rem drop the newly created type body for chnf$_reg_info
drop type body sys.chnf$_reg_info;

Rem drop the constructor func for base properties
alter type sys.chnf$_reg_info DROP CONSTRUCTOR FUNCTION chnf$_reg_info(
  callback varchar2,
  qosflags number,
  timeout number)
  RETURN SELF AS RESULT  CASCADE
/


Rem drop the constructor function that provides 10gR2 type
alter type sys.chnf$_reg_info DROP CONSTRUCTOR FUNCTION chnf$_reg_info(
  callback varchar2,
  qosflags number,
  timeout number,
  operations_filter number,
  transaction_lag number)  
  RETURN SELF AS RESULT CASCADE
/


Rem drop the constructor function that depracates transaction_lag
alter type sys.chnf$_reg_info DROP CONSTRUCTOR FUNCTION chnf$_reg_info(
  callback varchar2,
  qosflags number,
  timeout number,
  operations_filter number,
  ntfn_grouping_class        NUMBER,
  ntfn_grouping_value        NUMBER,
  ntfn_grouping_type         NUMBER,
  ntfn_grouping_start_time   TIMESTAMP WITH TIME ZONE,
  ntfn_grouping_repeat_count NUMBER)
  RETURN SELF AS RESULT CASCADE
/

Rem drop new attributes added in 11g
alter type sys.chnf$_reg_info
DROP ATTRIBUTE (ntfn_grouping_class, ntfn_grouping_value, 
                ntfn_grouping_type, ntfn_grouping_start_time,
                ntfn_grouping_repeat_count) CASCADE
/

Rem drop new synonyms and new types that were created in 11g
drop public synonym CQ_NOTIFICATION$_QUERY_ARRAY
/
drop type chnf$_qdesc_array force 
/
drop public synonym CQ_NOTIFICATION$_QUERY
/
drop type chnf$_qdesc force
/
drop public synonym  CQ_NOTIFICATION$_TABLE_ARRAY
/
drop public synonym  CQ_NOTIFICATION$_TABLE
/
drop public synonym  CQ_NOTIFICATION$_ROW_ARRAY
/
drop public synonym  CQ_NOTIFICATION$_ROW
/
drop public synonym CQ_NOTIFICATION$_REG_INFO
/
drop public synonym dbms_cq_notification;

Rem drop the 10gR2 descriptor types which were altered.
drop type chnf$_desc force;
drop type chnf$_tdesc_array force ;
drop type chnf$_tdesc force ;
drop type chnf$_rdesc_array force ;
drop type chnf$_rdesc force;

Rem -----------------------------------------------
Rem SQL Plan Management (SPM) Downgrade Begin
Rem -----------------------------------------------

Rem dbms_spm package
DROP PUBLIC SYNONYM dbms_spm;
DROP PACKAGE dbms_spm;

Rem dbms_spm_internal package
DROP PACKAGE dbms_spm_internal;

Rem dbms_smb package
DROP PACKAGE dbms_smb;

Rem dbms_smb_internal package
DROP PACKAGE dbms_smb_internal;

Rem drop dba_sql_plan_baselines view
DROP PUBLIC SYNONYM dba_sql_plan_baselines;
DROP VIEW dba_sql_plan_baselines;

DROP PUBLIC SYNONYM dba_sql_management_config;
DROP VIEW dba_sql_management_config;

Rem ---------------------------------------------
Rem SQL Plan Management (SPM) Downgrade End
Rem ---------------------------------------------

Rem ===============================
Rem Begin dbms_scheduler changes
Rem ===============================

Rem Remove Scheduler credential views
DROP VIEW dba_scheduler_credentials;
DROP PUBLIC SYNONYM dba_scheduler_credentials;
DROP VIEW user_scheduler_credentials;
DROP PUBLIC SYNONYM user_scheduler_credentials;
DROP VIEW all_scheduler_credentials;
DROP PUBLIC SYNONYM all_scheduler_credentials;

Rem remove Scheduler credential info
truncate table sys.scheduler$_credential;

Rem Null out the extra columns from scheduler$_job , job$
update sys.scheduler$_job
  set instance_id = null;

update sys.job$
  set scheduler_flags = null, xid = null;
commit;

update sys.scheduler$_program 
set schedule_limit = NULL,
    priority = NULL,
    job_weight = NULL,
    max_runs = NULL,
    max_failures = NULL,
    max_run_duration = NULL,
    nls_env = NULL,
    env = NULL;
commit;

DROP PUBLIC SYNONYM JOBARG;
DROP PUBLIC SYNONYM JOBARG_ARRAY;
DROP PUBLIC SYNONYM JOB;
DROP PUBLIC SYNONYM JOB_ARRAY;
DROP PUBLIC SYNONYM JOBATTR;
DROP PUBLIC SYNONYM JOBATTR_ARRAY;
DROP PUBLIC SYNONYM SCHEDULER_BATCH_ERRORS;

drop view sys.scheduler_batch_errors;
drop function sys.scheduler$_batcherr_pipe;

-- An index on a timezone col is internally a functional index using
-- sys_extract_utc. Drop them in case they have changed.
-- The next run of catsch.sql will recreate them
drop index sys.i_scheduler_job1;
drop index sys.i_scheduler_window1;

update sys.scheduler$_job set queue_agent = substr(queue_agent, 1, 30)
where length(queue_agent) > 30;
commit;
alter table scheduler$_job modify (queue_agent varchar2(30));


drop sequence sys.scheduler$_rdb_seq;

Rem Types which dbms_scheduler depend on are dropped conditionally at the end

Rem ===============================
Rem End dbms_scheduler changes
Rem ===============================

Rem ===============================
Rem  Truncate aq$_subscriber_table
Rem ===============================

truncate table sys.aq$_subscriber_table ;

Rem=========================================================================
Rem Drop all new types here
Rem=========================================================================

drop TYPE DBMS_XA_XID force;
drop TYPE DBMS_XA_XID_ARRAY force;

drop TYPE DBMS_XS_ROLELIST force;
drop TYPE DBMS_XS_PRIVID_LIST force;

-- drop your report subtype synonyms here
drop public synonym wri$_rept_sqlpi;
drop public synonym wri$_rept_sqlt;
drop public synonym wri$_rept_xplan;
drop public synonym wri$_rept_dbreplay;
drop public synonym wri$_rept_sqlmonitor;

-- drop your report subtypes here 
drop type wri$_rept_sqlpi force;
drop type wri$_rept_sqlt force;
drop type wri$_rept_xplan force;
drop type wri$_rept_dbreplay force;
drop type wri$_rept_sqlmonitor force;

-- drop framework parent type 
drop type wri$_rept_abstract_t force;
drop public synonym wri$_rept_abstract_t;

Rem Drop Supervised Binning Internal types and functions
drop PUBLIC SYNONYM ORA_DMSB_Nodes;
drop PUBLIC SYNONYM ORA_FI_SUPERVISED_BINNING;
drop function ORA_FI_SUPERVISED_BINNING;
drop type ORA_DMSB_Nodes force;
drop type ORA_DMSB_Node force;

Rem dbms_lobutil types
drop type dbms_lobutil_lobextents_t force;
drop type dbms_lobutil_lobextent_t  force;
drop type dbms_lobutil_lobmap_t     force;
drop type dbms_lobutil_inode_t      force;

Rem=========================================================================
Rem ALTER types to drop current release attributes, methods here
Rem=========================================================================

Rem 
Rem  AQ changes
Rem
ALTER TYPE sys.aq$_reg_info DROP CONSTRUCTOR FUNCTION aq$_reg_info(
  name             VARCHAR2,
  namespace        NUMBER,
  callback         VARCHAR2,
  context          RAW,
  anyctx           SYS.ANYDATA,
  ctxtype          NUMBER,
  qosflags         NUMBER,
  payloadcbk       VARCHAR2,
  timeout          NUMBER)
  RETURN SELF AS RESULT CASCADE
/
ALTER TYPE sys.aq$_reg_info DROP CONSTRUCTOR FUNCTION aq$_reg_info(
  name                       VARCHAR2,
  namespace                  NUMBER,
  callback                   VARCHAR2,
  context                    RAW,
  qosflags                   NUMBER,
  timeout                    NUMBER,
  ntfn_grouping_class        NUMBER,
  ntfn_grouping_value        NUMBER,
  ntfn_grouping_type         NUMBER,
  ntfn_grouping_start_time   TIMESTAMP WITH TIME ZONE,
  ntfn_grouping_repeat_count NUMBER)
  RETURN SELF AS RESULT CASCADE
/
ALTER TYPE sys.aq$_reg_info
DROP ATTRIBUTE (ntfn_grouping_class, ntfn_grouping_value,
                ntfn_grouping_type,  
                ntfn_grouping_start_time,
                ntfn_grouping_repeat_count) CASCADE
/

-- drop attributes from sys.aq$_descriptor
ALTER TYPE sys.aq$_descriptor
  DROP ATTRIBUTE (msgid_array, ntfnsRecdInGrp) CASCADE
/

-- drop attributes from aq$_srvntfn_message
ALTER TYPE sys.aq$_srvntfn_message
  DROP ATTRIBUTE(reg_id, msgid_array, ntfnsRecdInGrp, pblob) CASCADE
/

--Bug fix of 5943749. 
drop type aq$_ntfn_msgid_array force;

-- drop attributes from aq$_event_message
ALTER TYPE sys.aq$_event_message
  DROP ATTRIBUTE(pblob) CASCADE
/

Rem  Changes for XMLType

alter type sys.XMLType
  ---New Print Configuration Functions
  DROP member function getClobVal(pflag IN number, indent IN number) return CLOB deterministic ,
  DROP member function getBlobVal(csid IN number, pflag IN number, indent IN number) return BLOB deterministic ,
  DROP member function getStringVal(pflag IN number, indent IN number) return varchar2 deterministic parallel_enable ,
  DROP static function createXMLFromBinary(xmlData IN blob) return sys.XMLType deterministic parallel_enable,
  DROP member function getSchemaId return raw deterministic parallel_enable
CASCADE;

--drop the user defined xquery aggregator
drop public synonym SYS_IXQAGGSUM;
drop function SYS_IXQAGGSUM;
drop type AggXQSumImp force;

drop public synonym SYS_IXQAGGAVG;
drop function SYS_IXQAGGAVG;
drop type AggXQAvgImp force;


Rem Changes for extensibility related types here

alter type sys.ODCIColInfo 
   drop attribute (ColInfoFlags, OrderByPosition, 
                   TablePartitionIden, TablePartitionTotal) cascade;

alter type sys.ODCIIndexInfo
   drop attribute (IndexPartitionIden, IndexPartitionTotal) cascade;

alter type sys.ODCIPartInfo
   drop attribute (IndexPartitionIden, PartOp) cascade;

alter type sys.ODCIQueryInfo
   drop attribute (CompInfo) cascade;
Rem --------------------------------------------------
Rem Remove Flashback Transaction Backout changes - END
Rem --------------------------------------------------
drop type xid_array;
drop type txname_array;   

-- drop Extensibility related types now
DROP TYPE sys.ODCIColArrayValList FORCE;
DROP TYPE sys.ODCIColValList FORCE;
DROP TYPE sys.ODCICompQueryInfo FORCE;
DROP TYPE sys.ODCIOrderByInfoList FORCE;
DROP TYPE sys.ODCIOrderByInfo FORCE;
DROP TYPE sys.ODCIAuxPredInfoList FORCE;
DROP TYPE sys.ODCIAuxPredInfo FORCE;
DROP TYPE sys.ODCIPartInfoList FORCE;

Rem=========================================================================
Rem Drop all new packages here
Rem=========================================================================

drop package dbms_shared_pool;
drop package dbms_xa;
drop package dbms_editions_utilities;
drop package dbms_streams_sm;
drop package dbms_streams_advisor_adm;
drop package dbms_streams_advisor_adm_utl;
drop package dbms_apply_position;
drop package dbms_streams_adv_adm_utl;
drop package dbms_streams_adv_adm_utl_invok;
drop package dbms_streams_control_adm;
drop package dbms_xs_sessions;
drop package dbms_xs_sessions_ffi;
drop package dbms_xs_secclass_int ;
drop package dbms_xs_secclass_int_ffi ;
drop package sys.htmldb_system;
drop package prvt_report_registry;
drop package prvt_report_tags;
drop package dbms_report;
drop package dbms_hm;
drop package dbms_hprof;
drop package dbms_sqltcb_internal;
drop package dbms_sqldiag_internal;
drop package dbms_sqldiag;
drop package dbms_ir;
drop package dbms_objects_utils;

Rem Result Cache
drop package dbms_result_cache;

Rem drop data mining packages
drop PACKAGE DBMS_JDM_INTERNAL;
drop PACKAGE ODM_MODEL_UTIL;
drop PACKAGE DBMS_PREDICTIVE_ANALYTICS;
drop PACKAGE BLAST_CUR;
drop PACKAGE DBMS_DM_EXP_INTERNAL;
drop PACKAGE DBMS_DM_MODEL_IMP;
drop PACKAGE DBMS_DATA_MINING_INTERNAL;
drop PACKAGE DM_CL_CUR;
drop PACKAGE DM_NMF_CUR;
drop PACKAGE DM_SVM_CUR;
drop PACKAGE DM_GLM_CUR;
drop PACKAGE DBMS_DM_MODEL_EXP;
drop PACKAGE DBMS_DM_IMP_INTERNAL;
drop PACKAGE DMP_SEC;
drop PACKAGE ODM_OC_CLUSTERING_MODEL;
drop PACKAGE ODM_CLUSTERING_UTIL;
drop PACKAGE DBMS_DM_UTIL;
drop PACKAGE ODM_ASSOCIATION_RULE_MODEL;
drop PACKAGE DBMS_DM_UTIL_INTERNAL;
drop PACKAGE ODM_ABN_MODEL;
drop PACKAGE DMP_SYS;
drop PACKAGE DBMS_DATA_MINING;
drop PACKAGE DBMS_DATA_MINING_TRANSFORM;
drop PACKAGE DM_XFORM;
drop PACKAGE ODM_UTIL;
drop PACKAGE DM_QGEN;
drop PACKAGE DBMS_COMPARISON;
drop PACKAGE DBMS_CMP_INT;

-- remove credentials export support
DROP PACKAGE dbms_sched_credential_export;
DROP PUBLIC SYNONYM dbms_sched_credential_export;

Rem Remove DBMS_DG package
drop PACKAGE DBMS_DG;

Rem dbms_lobutil package
drop package dbms_lobutil;

Rem Streams switch packages
drop package sys.dbms_capture_switch_internal;
drop package sys.dbms_capture_switch_adm;
drop public synonym dbms_capture_switch_adm;

Rem=========================================================================
Rem Drop all new synonyms here
Rem=========================================================================
drop PUBLIC SYNONYM dbms_wlm;
drop PUBLIC SYNONYM dbms_xa force;
drop PUBLIC SYNONYM dbms_xa_xid force;
drop PUBLIC SYNONYM dbms_xa_xid_array force;
drop PUBLIC SYNONYM dbms_xs_sessions;
drop PUBLIC SYNONYM dbms_xs_rolelist;
drop PUBLIC SYNONYM dbms_editions_utilities;
drop PUBLIC SYNONYM dba_comparison;
drop PUBLIC SYNONYM dba_comparison_columns;
drop PUBLIC SYNONYM dba_comparison_scan;
drop PUBLIC SYNONYM dba_comparison_scan_values;
drop PUBLIC SYNONYM dba_comparison_row_dif;
drop PUBLIC SYNONYM user_comparison;
drop PUBLIC SYNONYM user_comparison_columns;
drop PUBLIC SYNONYM user_comparison_scan;
drop PUBLIC SYNONYM user_comparison_scan_values;
drop PUBLIC SYNONYM user_comparison_row_dif;
drop PUBLIC SYNONYM "_USER_COMPARISON_ROW_DIF";
drop PUBLIC SYNONYM dbms_comparison_adm;
drop PUBLIC SYNONYM htmldb_system;
drop PUBLIC SYNONYM dbms_hprof;

drop public synonym gv$redo_dest_resp_histogram;
drop public synonym v$redo_dest_resp_histogram;


Rem  Report framework synonyms
drop PUBLIC SYNONYM dbms_report;
drop PUBLIC SYNONYM report_components;
drop PUBLIC SYNONYM report_files;
drop PUBLIC SYNONYM report_formats;
drop PUBLIC SYNONYM "_REPORT_COMPONENT_OBJECTS";
drop PUBLIC SYNONYM "_REPORT_FORMATS";
drop PUBLIC SYNONYM wri$_rept_abstract_t;
drop PUBLIC SYNONYM wri$_rept_sqlt;

Rem Result Cache
drop PUBLIC SYNONYM dbms_result_cache;

Rem Remove data mining synonyms
drop public synonym user_mining_models;
drop public synonym all_mining_models;
drop public synonym user_mining_model_settings;
drop public synonym all_mining_model_settings;
drop public synonym user_mining_model_attributes;
drop public synonym all_mining_model_attributes;
drop public synonym dm_user_models;

Rem dbms_lobutil synonyms
drop public synonym dbms_lobutil;
drop public synonym dbms_lobutil_lobextents_t;
drop public synonym dbms_lobutil_lobextent_t;
drop public synonym dbms_lobutil_lobmap_t;
drop public synonym dbms_lobutil_inode_t;

Rem ======================================
Rem Begin drop public synonyms for Editioning View views
Rem ======================================

DROP PUBLIC SYNONYM user_editioning_views;
DROP PUBLIC SYNONYM all_editioning_views;
DROP PUBLIC SYNONYM dba_editioning_views;

DROP PUBLIC SYNONYM user_editioning_view_cols;
DROP PUBLIC SYNONYM all_editioning_view_cols;
DROP PUBLIC SYNONYM dba_editioning_view_cols;

Rem ==================================================
Rem End drop public synonyms for Editioning View views
Rem ==================================================

drop public synonym DBMS_DM_MODEL_IMP;
drop public synonym DMP_SYS;
drop public synonym DM_ABN_DETAIL;
drop public synonym DM_ABN_DETAILS;
drop public synonym DM_CHILD;
drop public synonym DM_CHILDREN;
drop public synonym DM_CLUSTER;
drop public synonym DM_CLUSTERS;
drop public synonym DM_CL_APPLY;
drop public synonym DM_CL_BUILD;
drop public synonym DM_CONDITIONAL;
drop public synonym DM_CONDITIONALS;
drop public synonym DM_HISTOGRAMS;
drop public synonym DM_HISTOGRAM_BIN;
drop public synonym DM_ITEM;
drop public synonym DM_ITEMS;
drop public synonym DM_ITEMSET;
drop public synonym DM_ITEMSETS;
drop public synonym DM_MODEL_SETTING;
drop public synonym DM_MODEL_SETTINGS;
drop public synonym DM_MODEL_SIGNATURE;
drop public synonym DM_MODEL_SIGNATURE_ATTRIBUTE;
drop public synonym DM_NB_DETAIL;
drop public synonym DM_NB_DETAILS;
drop public synonym DM_NESTED_CATEGORICAL;
drop public synonym DM_NESTED_CATEGORICALS;
drop public synonym DM_NESTED_NUMERICAL;
drop public synonym DM_NESTED_NUMERICALS;
drop public synonym DM_NMF_ATTRIBUTE;
drop public synonym DM_NMF_ATTRIBUTE_SET;
drop public synonym DM_NMF_BUILD;
drop public synonym DM_NMF_FEATURE;
drop public synonym DM_NMF_FEATURE_SET;
drop public synonym DM_PREDICATE;
drop public synonym DM_PREDICATES;
drop public synonym DM_RANKED_ATTRIBUTE;
drop public synonym DM_RANKED_ATTRIBUTES;
drop public synonym DM_RULE;
drop public synonym DM_RULES;
drop public synonym DM_SVM_APPLY;
drop public synonym DM_SVM_ATTRIBUTE;
drop public synonym DM_SVM_ATTRIBUTE_SET;
drop public synonym DM_SVM_BUILD;
drop public synonym DM_SVM_LINEAR_COEFF;
drop public synonym DM_SVM_LINEAR_COEFF_SET;
DROP PUBLIC synonym dm_glm_coeff;
DROP PUBLIC synonym dm_glm_coeff_set;
DROP PUBLIC synonym dm_model_global_detail;
DROP PUBLIC synonym dm_model_global_details;
drop public synonym ODM_ABN_MODEL;
drop public synonym ODM_ASSOCIATION_RULE_MODEL;
drop public synonym ODM_CLUSTERING_UTIL;
drop public synonym ODM_UTIL;
drop public synonym DBMS_DATA_MINING;
drop public synonym DBMS_DATA_MINING_TRANSFORM;
drop public synonym dm_transforms;
drop public synonym dm_transform;
drop public synonym dm_cost_matrix;
drop public synonym dm_cost_element;
drop public synonym DBMS_DG;

Rem --------------------------------------------------
Rem Remove Flashback Transaction Backout changes - END
Rem --------------------------------------------------
drop public synonym USER_FLASHBACK_TXN_STATE;
drop public synonym USER_FLASHBACK_TXN_REPORT;

Rem Health Monitor
drop PUBLIC SYNONYM dbms_hm;

Rem Intelligent Repair
drop PUBLIC SYNONYM dbms_ir;

Rem=========================================================================
Rem Drop all new libraries here
Rem=========================================================================

drop LIBRARY dbms_xa_lib;
drop LIBRARY dbms_xss_lib;
drop LIBRARY dbms_xsc_lib;
drop LIBRARY dbms_report_lib;

Rem Result Cache
drop LIBRARY dbms_rc_lib;

Rem  drop data mining library
drop LIBRARY DMUTIL_LIB;
drop LIBRARY DMSVM_LIB;
drop LIBRARY DMBLAST_LIB;
drop LIBRARY DMNMF_LIB;
drop LIBRARY DMCL_LIB;
drop LIBRARY DMSVMA_LIB;
drop LIBRARY DMGLM_LIB;

Rem  drop library dbms_wlm_lib
drop library dbms_wlm_lib;
drop package dbms_wlm;
 
Rem drop datamining export/import sequence
drop SEQUENCE DM$EXPIMP_ID_SEQ;

Rem ========================================================================
Rem Downgrade PL/SQL compiler parameters
Rem ========================================================================

Rem ========================================================================
Rem Downgrade *_ARGUMENTS view family
Rem ========================================================================
drop view sys.dba_arguments;
drop public synonym dba_arguments;

Rem ========================================================================
Rem Downgrade *_TRIGGER_ORDERING family 
Rem ========================================================================
truncate table sys.triggerdep$;
drop PUBLIC SYNONYM user_trigger_ordering;
drop PUBLIC SYNONYM all_trigger_ordering;
drop PUBLIC SYNONYM dba_trigger_ordering;
drop view user_trigger_ordering;
drop view all_trigger_ordering;
drop view dba_trigger_ordering;
drop view "_DBA_TRIGGER_ORDERING";

Rem Downgrade changes for interval partitioning 
Rem ========================================================================
truncate table sys.insert_tsn_list$;

Rem ========================================================================
Rem Begin Logminer Downgrade
Rem =========================================================================
-- recreate system.logmnr_spill$ table
DROP TABLE SYSTEM.logmnr_spill$ PURGE;
CREATE TABLE SYSTEM.logmnr_spill$ (
                session#     number,
                xidusn       number,
                xidslt       number,
                xidsqn       number,
                chunk        integer,
                sequence#    number,
                offset       number,
                spill_data   blob,
                spare1     number,
                spare2     number,
                CONSTRAINT LOGMNR_SPILL$_PK PRIMARY KEY
                  (session#, xidusn, xidslt, xidsqn, chunk, sequence#)
                  USING INDEX TABLESPACE SYSAUX LOGGING)
            LOB (spill_data)
              STORE AS (TABLESPACE SYSAUX CACHE LOGGING PCTVERSION 0
                        CHUNK 16k STORAGE (INITIAL 16K NEXT 16K))
            TABLESPACE SYSAUX LOGGING
/

CREATE TABLE SYS.LOGMNR_INTERESTING_COLS 
         ( OBJ# NUMBER NOT NULL,
           INTCOL# NUMBER NOT NULL,
           ONAME VARCHAR2(30) NOT NULL,
           CNAME VARCHAR2(30) NOT NULL );
CREATE TABLE system.logmnr_header1$ (logmnr_uid NUMBER(22))
              tablespace SYSAUX;
CREATE TABLE system.logmnr_header2$ ( logmnr_flags NUMBER(22) )
              tablespace SYSAUX;
drop table SYS.LOGMNRT_LOGMNR_BUILDLOG;
drop table SYS.LOGMNRT_NTAB$;
drop table SYS.LOGMNRT_OPQTYPE$;
drop table SYS.LOGMNRT_SUBCOLTYPE$;
drop table SYS.LOGMNRT_KOPM$;
drop table SYS.LOGMNRT_PROPS$;
drop table SYS.LOGMNRT_ENC$;
drop table SYS.LOGMNRT_REFCON$;
truncate table SYSTEM.LOGMNR_LOGMNR_BUILDLOG;
truncate table SYSTEM.LOGMNR_SEED$;
truncate table SYSTEM.LOGMNR_NTAB$;
truncate table SYSTEM.LOGMNR_OPQTYPE$;
truncate table SYSTEM.LOGMNR_SUBCOLTYPE$;
truncate table SYSTEM.LOGMNR_KOPM$;
truncate table SYSTEM.LOGMNR_PROPS$;
truncate table SYSTEM.LOGMNR_ENC$;
truncate table SYSTEM.LOGMNR_REFCON$;
truncate table SYSTEM.LOGMNR_GLOBAL$;
alter table SYSTEM.LOGMNR_TAB$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_COL$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_ATTRCOL$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_TS$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_IND$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_TABPART$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_TABSUBPART$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_TABCOMPART$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_TYPE$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_COLTYPE$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_ATTRIBUTE$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_LOB$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_CDEF$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_CCOL$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_ICOL$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_LOBFRAG$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_INDPART$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_INDSUBPART$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_INDCOMPART$ rename column LOGMNR_FLAGS to OBJV#;
alter table SYSTEM.LOGMNR_LOGMNR_BUILDLOG rename column LOGMNR_FLAGS to OBJV#;

update SYSTEM.LOGMNRC_GTLO
  set UNSUPPORTEDCOLS = NULL, COMPLEXTYPECOLS = NULL, NTPARENTOBJNUM = NULL,
      NTPARENTOBJVERSION = NULL, NTPARENTINTCOLNUM = NULL,
      LOGMNRTLOFLAGS = NULL, PARTTYPE = NULL, SUBPARTTYPE = NULL, LOGMNRMCV = NULL;
commit;
update SYSTEM.LOGMNRC_GTCS
  set XTYPENAME = NULL, XFQCOLNAME = NULL,
      XTOPINTCOL = NULL, XREFFEDTABLEOBJN = NULL, XREFFEDTABLEOBJV = NULL,
      XCOLTYPEFLAGS = NULL, XOPQTYPETYPE = NULL, XOPQTYPEFLAGS = NULL,
      XOPQLOBINTCOL = NULL, XOPQOBJINTCOL = NULL, XXMLINTCOL = NULL,
      EAOWNER# = NULL, EAMKEYID = NULL, EAENCALG = NULL, EAINTALG = NULL, 
      EACOLKLC = NULL, EAKLCLEN = NULL, EAFLAGS = NULL,
      COL# = NULL;
commit;
update SYSTEM.LOGMNR_TYPE$
  set VERSION = NULL, TYPECODE = NULL, METHODS = NULL, HIDDENMETHODS = NULL,
      SUPERTYPES = NULL, SUBTYPES = NULL, EXTERNTYPE = NULL,
      EXTERNNAME = NULL, HELPERCLASSNAME = NULL, LOCAL_ATTRS = NULL,
      LOCAL_METHODS = NULL, TYPEID = NULL, ROOTTOID = NULL, SPARE1 = NULL,
      SPARE2 = NULL, SUPERTOID = NULL, HASHCODE = NULL, OBJV# = NULL;
commit;
update SYSTEM.LOGMNR_COLTYPE$
  set PACKED = NULL, INTCOL#S = NULL, FLAGS = NULL, SYNOBJ# = NULL,
      OBJV# = NULL;
commit;
update SYSTEM.LOGMNR_ATTRIBUTE$
  set SYNOBJ# = NULL, CHARSETID = NULL, CHARSETFORM = NULL, LENGTH = NULL,
      PRECISION# = NULL, SCALE = NULL, EXTERNNAME = NULL, XFLAGS = NULL,
      SPARE1 = NULL,  SPARE2 = NULL,  SPARE3 = NULL,  SPARE4 = NULL,
      SPARE5 = NULL, SETTER = NULL, GETTER = NULL, OBJV# = NULL;
commit;
update SYSTEM.LOGMNR_DICTIONARY$
set LOGMNR_FLAGS = NULL;
commit;
update SYSTEM.LOGMNR_OBJ$
set LOGMNR_FLAGS = NULL;
commit;
update SYSTEM.LOGMNR_USER$
set LOGMNR_FLAGS = NULL;
commit;
update SYSTEM.LOGMNR_DICTSTATE$
set LOGMNR_FLAGS = NULL;
commit;
update SYSTEM.LOGMNR_LOG$
set RECID = NULL, RECSTAMP = NULL, MARK_DELETE_TIMESTAMP = NULL;
commit;
Rem Remove dummy entries from log$
delete from SYSTEM.LOGMNR_LOG$ where bitand(flags,16) = 16;
commit;
Rem Bug 6121044: Remove foreign log entries from log$
delete from SYSTEM.LOGMNR_LOG$ where bitand(flags,1) = 1;
commit;

update SYSTEM.LOGMNR_TAB$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_COL$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_ATTRCOL$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_TS$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_IND$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_TABPART$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_TABSUBPART$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_TABCOMPART$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_LOB$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_CDEF$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_CCOL$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_ICOL$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_LOBFRAG$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_INDPART$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_INDSUBPART$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_INDCOMPART$ set objv# = NULL;
commit;
update SYSTEM.LOGMNR_LOGMNR_BUILDLOG set objv# = NULL;
commit;

drop table SYSTEM.LOGMNR_GT_TAB_INCLUDE$;
drop table SYSTEM.LOGMNR_GT_USER_INCLUDE$;

drop public synonym gv$foreign_archived_log;
drop view gv_$foreign_archived_log;
drop public synonym v$foreign_archived_log;
drop view v_$foreign_archived_log;
begin
  execute immediate 'drop index system.logmnr_log$_recid';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

drop package logmnr_em_support;
drop package sys.dbms_logmnr_internal;
drop procedure sys.logmnr_krvrdluid3;
drop procedure sys.logmnr_krvrdrepdict3;
drop procedure sys.dbms_logmnr_ffvtologmnrt;

Rem ========================================================================
Rem End Logminer Downgrade
Rem =========================================================================

Rem ========================================================================
Rem Olap Changes
Rem ========================================================================

DROP TRIGGER sys.aw_trunc_trg;

DROP PROCEDURE sys.aw_trunc_proc;


Rem ========================================================================
Rem End Olap Changes
Rem ========================================================================

Rem ========================================================================
Rem Feature usage procedures
Rem ========================================================================

DROP PROCEDURE dbms_feature_services;
DROP PROCEDURE dbms_feature_autosta;
DROP PROCEDURE dbms_feature_wcr_capture;
DROP PROCEDURE dbms_feature_wcr_replay;
DROP PROCEDURE dbms_feature_dyn_sga;
DROP PROCEDURE dbms_feature_auto_mem;
DROP PROCEDURE dbms_feature_auto_sga;
DROP PROCEDURE dbms_feature_rman_zlib;
DROP PROCEDURE dbms_feature_job_scheduler;


Rem ========================================================================
Rem End - Feature usage procedures
Rem ========================================================================


update scheduler$_job set database_role = NULL;
commit;

Rem restore the old (log_id) PK constraint from (log_id, dbid)
alter table scheduler$_event_log 
  drop constraint scheduler$_instance_pk;
delete scheduler$_event_log where dbid is not null;
commit;
alter table scheduler$_event_log 
  add constraint scheduler$_instance_pk
  primary key (log_id) using index tablespace sysaux;

Rem drop new view
drop public synonym dba_scheduler_job_roles;
drop view sys.dba_scheduler_job_roles;

truncate table comparison$;
truncate table comparison_col$;
truncate table comparison_scan$;
truncate table comparison_scan_val$;
truncate table comparison_row_dif$;

update sumdetail$ set tabscnctr = 0;

Rem downgrade .NET assembly support
Rem Tried using truncate table assembly$ here, but that fails 
Rem with ORA-3292.  delete seems to work...
delete from  assembly$;

Rem=========================================================================
Rem Instead of dropping dba_tablespaces/user_tablespaces/dba_source, 
Rem issue a create or replace so that GRANTS on these objects remain intact
Rem=========================================================================
create or replace view dba_tablespaces as select null nn from dual;
create or replace view user_tablespaces as select null nn from dual;
create or replace view dba_source as select null nn from dual;

Rem=========================================================================
Rem Revert 10.2 changes to sql.bsq dictionary tables here
Rem=========================================================================

update partlob$ set defmaxsize = NULL,
                    defretention = NULL,
                    defmintime = NULL;

update tabcompart$ set defmaxsize = NULL; 

update partobj$ set defmaxsize = NULL;

update lobcomppart$ set defmaxsize = NULL,
                       defretention = NULL, 
                       defmintime = NULL;

update indcompart$ set defmaxsize = NULL;

Rem clear 0x00200000 (read-only table flag) in trigflag during downgrade
update tab$ set trigflag = trigflag - 2097152
  where bitand(trigflag, 2097152) <> 0;

Rem clear ts# of temporary objects in tab$ & ind$, no need to update lob$
update tab$ set ts# = 0
  where bitand(property, 4194304) <> 0
    and ts# <> 0;
update ind$ set ts# = 0
  where bitand(property, 32) <> 0
    and ts# <> 0;
commit;

Rem OLAP Analytic Workspace Access Tracking table
truncate table sys.aw_track$;

Rem OLAP table catalogs
Rem This is a precaution only - you should not be able to downgrade if 
Rem you have ever created OLAP tables since they require 11.0 compatibility
truncate table sys.olap_tab_col$;
truncate table sys.olap_tab_hier$;
truncate table sys.olap_tab$;
Rem OLAP Analytical Workspace Program 
truncate table aw_prg$;

Rem OLAP Data Dictionary tables
truncate table olap_mappings$;
truncate table olap_models$;
truncate table olap_model_parents$;
truncate table olap_model_assignments$;
truncate table olap_calculated_members$;
truncate table olap_syntax$;
truncate table olap_descriptions$;
truncate table olap_cube_build_processes$;
truncate table olap_aw_views$;
truncate table olap_aw_view_columns$;
truncate table olap_measure_folders$;
truncate table olap_meas_folder_contents$;
truncate table olap_aw_deployment_controls$;
truncate table olap_impl_options$;
truncate table olap_cube_dimensions$;
truncate table olap_dim_levels$;
truncate table olap_attributes$;
truncate table olap_attribute_visibility$;
truncate table olap_hierarchies$;
truncate table olap_hier_levels$;
truncate table olap_cubes$;
truncate table olap_measures$;
truncate table olap_dimensionality$;

Rem Fusion Extensible Security LW users verifiers table
truncate table SYS.xs$verifiers;

Rem Light Weight Sessions and Roles
truncate table SYS.xs$sessions ;
truncate table SYS.xs$session_roles ;
truncate table SYS.xs$session_appns ;
truncate table SYS.xs$session_hws ;
truncate table SYS.xs$parameters ;

Rem  truncate data mining tables
Rem  Using the existence of model$ as a trigger for needing to run 
Rem  utlip in catupstr (no utlip if model$ exists, since that would be
Rem  a patch scenario or a re-run scenario).  Drop it instead of
Rem  truncating it so that on a re-upgrade, utlip.sql will be run.
drop table sys.model$;
truncate table sys.modelatt$;
truncate table sys.modelset$;
truncate table sys.modeltab$;

Rem  truncate Editioning View tables
TRUNCATE TABLE ev$;
TRUNCATE TABLE evcol$;

Rem truncate ecol$
truncate table ecol$;

Rem truncate indrebuild$
truncate table indrebuild$;

Rem bug-4054238
Rem In current release column size of sumagg$.agginfo is M_VCSZ (4000 bytes)
Rem 10.2 server may not have column size longer than 2000 bytes
Rem So, truncate sumagg$.agginfo column value to 2000 bytes
update sumagg$ set agginfo = substr(agginfo,1,2000);
commit;

Rem =========================================================================
delete from props$ where name = 'TDE_MASTER_KEY_ID';
commit;

Rem Begin Online Redefintion downgrade
Rem=========================================================================
Rem remove all 11.0 online redefinition metadata
DECLARE
  CURSOR redef11gR1 IS
    SELECT id FROM sys.redef$ r
    WHERE bitand(r.flag, 8192) = 8192;
BEGIN
  FOR r2 IN redef11gR1 LOOP
    DELETE FROM sys.redef_object$ r
    WHERE r.redef_id = r2.id;

    DELETE FROM sys.redef_dep_error$ r
    WHERE r.redef_id = r2.id;

    DELETE FROM sys.redef$ r
    WHERE r.id = r2.id;
    COMMIT;
  END LOOP;
END;
/

Rem=========================================================================
Rem End Online Redefintion downgrade
Rem=========================================================================

Rem=========================================================================
Rem Remove sum$.xxpflags and xmflags from sum$.xpflags and mflags.
Rem=========================================================================
update sys.obj$ o set o.status = 5 
  where o.obj# in (select s.obj# from sys.sum$ s
                   where s.xpflags > 4294967295 or s.mflags > 4294967295);

update sys.sum$ s set s.xpflags = bitand(s.xpflags,4294967295),
                      s.mflags  = bitand(s.mflags, 4294967295)
  where s.xpflags > 4294967295 or s.mflags > 4294967295;

Rem=========================================================================
Rem End of changes in sum$ flags.
Rem=========================================================================

Rem Drop older-version Diana information
truncate table diana_version$;

Rem
Rem  Drop feature usage information
Rem
truncate table sys.ku_utluse
/

Rem =========================================================================
Rem END STAGE 2: downgrade dictionary from current release to 10.2
Rem =========================================================================

Rem drop the dbms_assert package and its public synonym
-- conditionally drop objects that are required in subsequent downgrade steps
DECLARE
  previous_version  varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE cid = 'CATPROC';
  
  IF previous_version NOT LIKE '9.2.0%' THEN
     NULL;
  END IF;

  IF previous_version LIKE '10.2.0%' THEN
    -- If we are going to stop downgrading at 10.2, then drop the new columns
    -- from plan_lines now.  Otherwise drop them in e1001000.sql 
    -- (downgrade to 10.1).  The column drop is necessary because 10.2.0.1 code
    -- has an INSERT AS SELECT that does not specify a column list

    EXECUTE IMMEDIATE 
      'alter table wri$_sqlset_plan_lines drop (  
         last_starts,
         last_output_rows,
         last_cr_buffer_gets,
         last_cu_buffer_gets,
         last_disk_reads,
         last_disk_writes,
         last_elapsed_time,
         policy,
         estimated_optimal_size,
         estimated_onepass_size,
         last_memory_used,
         last_execution,
         last_degree,
         total_executions,
         optimal_executions,
         onepass_executions,
         multipasses_executions,
         active_time,
         max_tempseg_size,
         last_tempseg_size)';

    -- likewise we drop the new type for plan stats here.  there is a dependency
    -- from dbms_sqltune to this type, as well as to the workspace table, so
    -- they cannot be dropped yet if we are downgrading beyond 10.2.  
    -- 
    EXECUTE IMMEDIATE 'drop public synonym sql_plan_allstat_row_type';
    EXECUTE IMMEDIATE 'drop type sql_plan_allstat_row_type force';
  END IF;
END;
/

Rem
Rem drop dbms_sqltune_util0 if needed. Drop the package only if we are going 
Rem to stop downgrading at 10.2. Otherwise drop it in e1001000.sql
Rem
DECLARE
  previous_version  varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE cid = 'CATPROC';
  
  -- check the version 
  IF previous_version LIKE '10.2.0%' THEN
    EXECUTE IMMEDIATE 'DROP PACKAGE DBMS_SQLTUNE_UTIL0';
  END IF;
END;
/


Rem Change Flashback timestamp in tab$, ind$, smon_scn_time back to local time 
Rem 1. Create timestamp conversion functions.
create or replace library dbms_fmig_lib trusted as static;
/

create or replace function ktf_mig_time(local_to_gmt IN number, time IN number)
return number is
  language C
    name "ktfmigextime"
    with context
    parameters(context, local_to_gmt OCINUMBER, time OCINUMBER, RETURN)
    library dbms_fmig_lib;
/

create or replace function ktf_mig_map(local_to_gmt IN number,
                                       maplen IN number, map IN raw)
return raw is
  language C
    name "ktfmigexmap"
    with context
    parameters(context, local_to_gmt OCINUMBER, maplen OCINUMBER,
               map OCIRaw, return INDICATOR sb2, RETURN OCIRaw)
    library dbms_fmig_lib;
/

create or replace function gmt_time_to_local(gmt_time IN number)
return number is
  local_time number;
begin
  local_time := ktf_mig_time(0, gmt_time);
  return local_time;
end;
/

create or replace function gmt_date_to_local(gmt_date IN date)
return date is
  local_date date;
  hour_dif number;
begin
  hour_dif := extract(timezone_hour from systimestamp);
  local_date := gmt_date + numtodsinterval(hour_dif, 'hour');
  return local_date;
end;
/

create or replace function gmt_tim_scn_map_to_local(maplen IN number,
                                                    map IN raw)
return raw is
begin
  return ktf_mig_map(0, maplen, map);
end;
/

Rem 2. Do the conversion:
Rem The following updates on tab$, ind$ and smon_scn_time are in one transaction.
Rem During downgrade, the spare6 column of some rows may be changed after
Rem the following statements.  
DECLARE
  cnt number;
  cursor c1
  is
  select rowid, time_mp from smon_scn_time order by time_mp;
BEGIN
  select count(*) into cnt from props$
    where name = 'Flashback Timestamp TimeZone' and value$ = 'Local Time';
  if cnt = 0 then
    delete from props$ 
      where name = 'Flashback Timestamp TimeZone' and value$ = 'GMT';
    insert into props$ (name, value$, comment$)
      values('Flashback Timestamp TimeZone', 'Local Time',
             'Flashback timestamp converted to local time');
    update tab$ set spare6 = gmt_date_to_local(spare6);
    update ind$ set spare6 = gmt_date_to_local(spare6);
    delete from smon_scn_time where thread != 0;
    begin
      for c1rec in c1 loop
      begin
        update smon_scn_time set time_mp = gmt_time_to_local(time_mp)
          where orig_thread = 0 and time_mp = c1rec.time_mp;
      exception
        when DUP_VAL_ON_INDEX then
        delete smon_scn_time where rowid = c1rec.rowid and 
          time_mp = c1rec.time_mp ;
        continue;
     end;
     end loop;
   end;
   update smon_scn_time set 
     tim_scn_map = gmt_tim_scn_map_to_local(num_mappings, tim_scn_map)
     where orig_thread = 0 and num_mappings != 0;
  end if;
  commit;
END;
/

Rem 3. Drop the functions created

drop function gmt_time_to_local;
drop function gmt_date_to_local;
drop function gmt_tim_scn_map_to_local;
drop function ktf_mig_time;
drop function ktf_mig_map;
drop library dbms_fmig_lib;

drop procedure sys.ODCIColInfoFlagsDump;
drop procedure sys.ODCIPartInfoDump;
drop procedure sys.ODCIPartInfoListDump;

Rem drop transportable tablespace global temporary tables.
drop table sys.tts_tbs$;
drop table sys.tts_usr$;
drop table sys.tts_error$;

Rem drop data mining functions 
drop FUNCTION DM_SVM_BUILD;
drop FUNCTION DM_SVM_APPLY;
drop FUNCTION DM_NMF_BUILD;
drop FUNCTION DM_CL_BUILD;
drop FUNCTION DM_CL_APPLY;
drop FUNCTION DM_GLM_BUILD;
drop FUNCTION BLASTN_COMPRESS;
drop FUNCTION BLASTP_MATCH;
drop FUNCTION TBLAST_MATCH;
drop FUNCTION BLASTN_ALIGN;
drop FUNCTION BLASTP_ALIGN;
drop FUNCTION TBLAST_ALIGN;
drop FUNCTION BLASTN_MATCH;
drop FUNCTION DM_MOD_BUILD;


Rem=========================================================================
Rem Drop all new types here
Rem=========================================================================

-- Drop OLAP sparsity advisor types;
DROP PUBLIC SYNONYM dbms_aw$_dimension_sources_t;
DROP TYPE sys.dbms_aw$_dimension_sources_t;
DROP PUBLIC SYNONYM dbms_aw$_dimension_source_t;
DROP TYPE sys.dbms_aw$_dimension_source_t;
DROP PUBLIC SYNONYM dbms_aw$_columnlist_t;
DROP TYPE sys.dbms_aw$_columnlist_t;

Rem  drop data mining types

drop TYPE DMSVMBO force;
drop TYPE DMSVMBOS force;
drop TYPE DMSVMAO force;
drop TYPE DMSVMAOS force;
drop TYPE DMSVMBIMP force;
drop TYPE DMSVMAIMP force;
drop TYPE DMNMFBO force;
drop TYPE DMNMFBOS force;
drop TYPE DMNMFBIMP force;
drop TYPE DMCLBO force;
drop TYPE DMCLBOS force;
drop TYPE DMCLAO force;
drop TYPE DMCLAOS force;
drop TYPE DMCLBIMP force;
drop TYPE DMCLAIMP force;
drop TYPE DMGLMBO force;
drop TYPE DMGLMBOS force;
drop TYPE DMGLMBIMP force;
drop TYPE DMBGO force;
drop TYPE DMBGOS force;
drop TYPE DMBMO force;
drop TYPE DMBMOS force;
drop TYPE DMBAO force;
drop TYPE DMBAOS force;
drop TYPE DMBCO force;
drop TYPE DMBCOS force;
drop TYPE DMBMNIMP force;
drop TYPE DMBMPIMP force;
drop TYPE DMBMTIMP force;
drop TYPE DMBANIMP force;
drop TYPE DMBAPIMP force;
drop TYPE DMBATIMP force;
drop TYPE DMBCNIMP force;
drop TYPE JDM_ATTR_NAMES force;
drop TYPE JDM_NUM_VALS force;
drop TYPE JDM_STR_VALS force;
drop TYPE ORA_MINING_NUMBER_NT force;
drop TYPE ORA_MINING_VARCHAR2_NT force;
drop TYPE DM_MODEL_SIGNATURE_ATTRIBUTE force;
drop TYPE DM_MODEL_SIGNATURE force;
drop TYPE DM_MODEL_SETTING force;
drop TYPE DM_MODEL_SETTINGS force;
drop TYPE DM_PREDICATE force;
drop TYPE DM_PREDICATES force;
drop TYPE DM_RULE force;
drop TYPE DM_RULES force;
drop TYPE DM_ITEM force;
drop TYPE DM_ITEMS force;
drop TYPE DM_ITEMSET force;
drop TYPE DM_ITEMSETS force;
drop TYPE DM_CENTROID force;
drop TYPE DM_CENTROIDS force;
drop TYPE DM_HISTOGRAM_BIN force;
drop TYPE DM_HISTOGRAMS force;
drop TYPE DM_CHILD force;
drop TYPE DM_CHILDREN force;
drop TYPE DM_CLUSTER force;
drop TYPE DM_CLUSTERS force;
drop TYPE DM_CONDITIONAL force;
drop TYPE DM_CONDITIONALS force;
drop TYPE DM_NB_DETAIL force;
drop TYPE DM_NB_DETAILS force;
drop TYPE DM_ABN_DETAIL force;
drop TYPE DM_ABN_DETAILS force;
drop TYPE DM_NMF_ATTRIBUTE force;
drop TYPE DM_NMF_ATTRIBUTE_SET force;
drop TYPE DM_NMF_FEATURE force;
drop TYPE DM_NMF_FEATURE_SET force;
drop TYPE DM_SVM_ATTRIBUTE force;
drop TYPE DM_SVM_ATTRIBUTE_SET force;
drop TYPE DM_SVM_LINEAR_COEFF force;
drop TYPE DM_SVM_LINEAR_COEFF_SET force;
drop TYPE DM_GLM_COEFF force;
drop TYPE DM_GLM_COEFF_SET force;
DROP TYPE dm_model_global_detail force;
DROP TYPE dm_model_global_details force;
drop TYPE DM_NESTED_NUMERICAL force;
drop TYPE DM_NESTED_NUMERICALS force;
drop TYPE DM_NESTED_CATEGORICAL force;
drop TYPE DM_NESTED_CATEGORICALS force;
drop TYPE DM_RANKED_ATTRIBUTE force;
drop TYPE DM_RANKED_ATTRIBUTES force;
drop type dm_transforms force;
drop type dm_transform force;
drop type dm_cost_matrix force;
drop type dm_cost_element force;
DROP TYPE ora_mining_tables_nt FORCE;
DROP TYPE ora_mining_table_type FORCE;
DROP TYPE DMMODBIMP force;
DROP TYPE DMMODBO force;
DROP TYPE DMMODBOS force;

drop public synonym DM_CENTROID;
drop public synonym DM_CENTROIDS;

DROP PUBLIC SYNONYM ora_mining_tables_nt;
DROP PUBLIC SYNONYM ora_mining_tables_type;

DROP PUBLIC SYNONYM DM_MOD_BUILD;


Rem Drop Java Package 
drop package initjvmaux;

Rem Drop Logminer package that uses new fixed views
drop package DBMS_INTERNAL_LOGSTDBY;

Rem Downgrade PL/Scope support
truncate table sys.plscope_identifier$;
truncate table sys.plscope_action$;
delete from settings$ where param='plscope_settings';

-- Drop scheduler types
declare
  previous_version  varchar2(30);
begin
  SELECT prv_version INTO previous_version FROM registry$
  WHERE cid = 'CATPROC';

  -- Drop scheduler types only if the target version for this
  -- downgrade is 10.2. If we are downgrading to an earlier 
  -- version, dropping the types here will cripple the 
  -- dbms_scheduler package and those downgrade scripts will
  -- fail.
  IF previous_version LIKE '10.2.0%' THEN
    execute immediate
      'drop type body sys.scheduler$_batcherr_view_t';
    execute immediate
      'drop type body sys.jobattr';
    execute immediate
      'drop type body sys.job';
    execute immediate
      'drop type body sys.job_definition';
    execute immediate
      'drop type body sys.jobarg';

    execute immediate
      'drop type sys.scheduler$_batcherr_array force';
    execute immediate
      'drop type sys.jobattr_array force';
    execute immediate 
      'drop type sys.job_array force';
    execute immediate
      'drop type sys.job_definition_array force';
    execute immediate
      'drop type sys.jobarg_array force';

    execute immediate
      'drop type sys.scheduler$_batcherr_view_t force';
    execute immediate 
      'drop type sys.jobattr force';
    execute immediate
      'drop type sys.job force';
    execute immediate
      'drop type sys.job_definition force';
    execute immediate
      'drop type sys.jobarg force';
    execute immediate
      'drop type sys.scheduler$_batcherr force';

    execute immediate 'drop type sys.scheduler$_remote_db_job_info force';
    execute immediate 'drop type sys.scheduler$_dest_list force';
    execute immediate 'drop type sys.scheduler$_remote_arg_list force';
    execute immediate 'drop type sys.scheduler$_remote_arg force';

    execute immediate 'drop package sys.dbms_isched_remdb_job';

  END IF;
END;
/

-- Drop HS Bulk Load  package and types
drop public synonym DBMS_HS_PARALLEL;
drop package  DBMS_HS_PARALLEL;

drop public synonym dbms_hs_parallel_metadata;
drop package dbms_hs_parallel_metadata;

drop type HS_PARTITION_OBJ force;
drop type HS_PART_OBJ force;
drop type hs_sample_obj force; 

drop type HSBLKNamLst force;
drop type HSBLKValAry force;

drop sequence hs_bulk_seq;

truncate table HS_BULKLOAD_VIEW_OBJ;

drop public synonym HS_PARALLEL_METADATA;
drop view HS_PARALLEL_METADATA;
drop public synonym hs_parallel_partition_data;
drop view hs_parallel_partition_data;
drop public synonym hs_parallel_histogram_data;
drop view hs_parallel_histogram_data;
drop public synonym hs_parallel_sample_data;
drop view hs_parallel_sample_data;

drop  table hs$_parallel_partition_data;
drop  table hs$_parallel_histogram_data;
drop  table hs$_parallel_sample_data;
drop  table hs$_parallel_metadata;
 
commit;

Rem======================================================================
Rem bug 10096081 - drop existing HS class when downgrade to 10.2 or below
Rem========================================================================
DECLARE
  cursor c1 is
  select fds_class_name from hs_fds_class;
  n1 varchar2(30);
BEGIN
  open c1;
  LOOP
    BEGIN
      fetch c1 into n1;
      dbms_hs.drop_fds_class(n1);
    EXCEPTION
      when others then exit;
    END;
  END LOOP;
END;
/


-- Drop HS Table Function implementation
DROP FUNCTION SYS.HS$_DDTF_SQLTabStats;
DROP FUNCTION SYS.HS$_DDTF_SQLTabForKeys;
DROP FUNCTION SYS.HS$_DDTF_SQLTabPriKeys;
DROP FUNCTION SYS.HS$_DDTF_SQLStatistics;
DROP TYPE     SYS.HS$_DDTF_SQLStatistics_T;
DROP TYPE     SYS.HS$_DDTF_SQLStatistics_O;
DROP FUNCTION SYS.HS$_DDTF_SQLProcedures;
DROP TYPE     SYS.HS$_DDTF_SQLProcedures_T;
DROP TYPE     SYS.HS$_DDTF_SQLProcedures_O;
DROP FUNCTION SYS.HS$_DDTF_SQLForeignKeys;
DROP TYPE     SYS.HS$_DDTF_SQLForeignKeys_T;
DROP TYPE     SYS.HS$_DDTF_SQLForeignKeys_O;
DROP FUNCTION SYS.HS$_DDTF_SQLPrimaryKeys;
DROP TYPE     SYS.HS$_DDTF_SQLPrimaryKeys_T;
DROP TYPE     SYS.HS$_DDTF_SQLPrimaryKeys_O;
DROP FUNCTION SYS.HS$_DDTF_SQLColumns;
DROP TYPE     SYS.HS$_DDTF_SQLColumns_T;
DROP TYPE     SYS.HS$_DDTF_SQLColumns_O;
DROP FUNCTION SYS.HS$_DDTF_SQLTables;
DROP TYPE     SYS.HS$_DDTF_SQLTables_T;
DROP TYPE     SYS.HS$_DDTF_SQLTables_O;

commit;


Rem *************************************************************************
Rem BEGIN Change flags in partobj$ to remove IOT top and LOB index values
Rem *************************************************************************

update sys.partobj$ p$
set p$.flags = p$.flags-256
where to_number(bitand(p$.flags,256)) = 256;

update sys.partobj$ p$
set p$.flags = p$.flags-512
where to_number(bitand(p$.flags,512)) = 512;

commit;

Rem *************************************************************************
Rem END Change flags in partobj$ to remove IOT top and LOB index values
Rem *************************************************************************

-- SQL Toolkit for HM
drop package hm_sqltk_internal;
truncate table sql_tk_coll_chk$;
truncate table sql_tk_row_chk$;
truncate table sql_tk_ref_chk$;

Rem PRIVATE_JDBC
DROP PUBLIC SYNONYM PRIVATE_JDBC;
DROP PACKAGE PRIVATE_JDBC;

Rem *************************************************************************
Rem downgrade for alert type changes
Rem *************************************************************************
update wri$_alert_outstanding 
  set execution_context_id = substr(execution_context_id,1,21);
update wri$_alert_history 
  set execution_context_id = substr(execution_context_id,1,21);
commit;

Rem *************************************************************************
Rem downgrade for AWR report type changes
Rem *************************************************************************
drop type AWRRPT_ROW_TYPE FORCE
/
drop type AWRRPT_NUM_ARY FORCE
/
drop type AWRRPT_VCH_ARY FORCE
/
drop type AWRRPT_CLB_ARY FORCE
/

Rem *************************************************************************
Rem remove/downgrade fine-grain dependency information
Rem *************************************************************************

-- Remove all FG info
update dependency$ set property = property - 4, d_attrs = null
   where bitand(property, 4) != 0;

--
-- Restore old fixed bitvector for view to synonym dependencies
-- PL/SQL to synonym bitvector is regenerated by invalidating and recompiling
--
update dependency$ set property = property + 4, d_attrs = hextoraw('06')
   where d_obj# in (select obj# from obj$ where type# = 4)
     and p_obj# in (select obj# from obj$ where type# = 5);

commit;


Rem *************************************************************************
Rem remove/downgrade temporary tables used by Data Pump
Rem *************************************************************************
drop table sys.ku$_list_filter_temp;


Rem=========================================================================
Rem Truncate objerror$ and unset obj$ flags
Rem=========================================================================
truncate table objerror$;
update obj$ set flags = flags - 32768
  where bitand(flags, 32768) <> 0;

commit;

Rem=========================================================================
Rem Invalidate views and synonyms
Rem=========================================================================
update obj$ set status = 6 where status not in (5,6) and type# in (4, 5);

commit;

Rem=========================================================================
Rem Invalidate tables that depend on public synonyms
Rem=========================================================================
update obj$ set status = 6
  where status not in (5,6) and type#=2 and
  obj# in (select d_obj# from dependency$ where p_obj# in 
  (select obj# from obj$ where type#=5 and owner#=1));

commit;

Rem=========================================================================
Rem Set flag so that these tables can be recompiled via alter table upgrade
Rem=========================================================================
update obj$ set flags = flags + 4096
   where bitand(flags, 4096) = 0 and
   type#=2 and status=6
   and obj# in (select d_obj# from dependency$ where p_obj# in 
   (select obj# from obj$ where type#=5 and owner#=1));
  
commit;

alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

Rem !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Rem           !!! Please keep it at the end of this file !!!
Rem           !!! Every downgrade action should happen above this block !!!
Rem !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
Rem 
Rem drop _*_EDITION_OBJ view family
DECLARE
  previous_version  varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE cid = 'CATPROC';
  
  -- check the version 
  IF previous_version LIKE '10.2.0%' THEN
    EXECUTE IMMEDIATE 'drop view "_CURRENT_EDITION_OBJ"';
    EXECUTE IMMEDIATE 'drop view "_ACTUAL_EDITION_OBJ"';
    EXECUTE IMMEDIATE 'drop view "_BASE_USER"';

    -- drop ORA$BASE Edition
    EXECUTE IMMEDIATE 'drop edition ORA$BASE CASCADE';

    delete from sys.props$ where name = 'DEFAULT_EDITION';
    commit;
  END IF;
END;
/

update user$ 
set spare1=spare1-16
where bitand(spare1, 16) = 16 and name='PUBLIC';

commit;
alter system flush shared_pool;


-- bug 5572026 stop and drop created service metrics queue 
DROP TYPE SYS$RLBTYP;

-- lrg 4599562 - drop dbms_space pkg during
DROP PACKAGE sys.dbms_space;

Rem *************************************************************************
Rem END e1002000.sql
