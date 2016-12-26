Rem
Rem $Header: rdbms/admin/e1001000.sql /st_rdbms_11.2.0/1 2010/12/02 02:20:42 ineall Exp $
Rem
Rem e1001000.sql
Rem
Rem Copyright (c) 2000, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      e1001000.sql - downgrade Oracle RDBMS from current release to 10.1.0
Rem
Rem    DESCRIPTION
Rem
Rem
Rem      This script performs the downgrade in the following stages:
Rem        STAGE 1: downgrade from the current release to 10.2;
Rem                 this stage is a no-op for 10.2 since the current release
Rem                 is 10.2.
Rem        STAGE 2: downgrade base data dictionary objects from 10.2 to 10.1.0
Rem                 a. remove new 10.2 system/object privileges
Rem                 b. remove new 10.2 catalog views/synonyms
Rem                    (previous release views will be recreated after)
Rem                 c. remove program units referring to new 10.2 fixed views
Rem                    or non-compiling in 10.1.0
Rem                 d. update new 10.2 columns to NULL or other values,
Rem                    delete rows from new 10.2 tables, and drop new
Rem                    10.2 type attributes, methods, etc.
Rem                 e. downgrade system types from 10.2 to 10.1.0
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release's environment
Rem        (before installing the release to which you want to downgrade).
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ineall      12/02/10 - Bug 10128898: backport added new dependency
Rem    achoi       04/30/09 - remove alter edition
Rem    dvoss       11/07/08 - bug 7553884 - clear logminer chunk_supress bit
Rem                           for logical standby
Rem    achoi       09/02/08 - drop orabase
Rem    rgmani      01/18/08 - Drop types job_definiton and job_definition_array
Rem    cdilling    11/29/07 - move dbms_assert calls to f1001000.sql
Rem    cdilling    09/25/07 - move drop_transformation to f1001000.sql 
Rem    araghava    07/06/07 - 6144565: drop unique indexes on partitioning
Rem                           tables and recreate them as non-unique indexes
Rem    cdilling    07/11/07 - move .downgraded calls to f scripts
Rem    bkuchibh    05/31/07 - fix bug #6071289
Rem    pbelknap    05/07/07 - #5999827 - set attr3 of SQLSET object to NULL
Rem    rburns      04/30/07 - fix execute immediates
Rem    akociube    03/13/07 - grant execute on olapimpl_t
Rem    mlfeng      12/15/06 - partitioning enabling
Rem    gviswana    12/05/06 - Flush shared pool after props$ delete
Rem    achoi       10/03/06 - drop "_BASE_USER"
Rem    jsoule      10/13/06 - suppress bsln 942s on downgrade from 11.1
Rem    cdilling    09/14/06 - restructure to move pl/sql to f1001000.sql
Rem    rburns      07/21/06 - reset session 
Rem    rramkiss    07/11/06 - drop more 11g scheduler types 
Rem    achoi       06/30/06 - remove EDITION_OBJ view 
Rem    achoi       06/08/06 - 
Rem    rgmani      05/30/06 - 
Rem    kyagoub     05/04/06 - drop new package dbms_sqltune_util0 
Rem    kyagoub     05/04/06 - fix lrg#2182885 
Rem    cdilling    10/24/05 - add semicolon 
Rem    cdilling    10/03/05 - move session_history changes to e1002000.sql 
Rem    pbelknap    08/17/05 - add dbms_sqltune dependencies to drop here
Rem    dsampath    06/28/05 - fix bug 4449955, upgrade SQL profiles dont match
Rem    adagarwa    04/25/05 - null out l/sql stack cols in wrh$_active_sess_history
Rem    cdilling    06/08/05 - invoke e1002000.sql 
Rem    rburns      06/07/05 - drop stats package 
Rem    dsampath    05/26/05 - revert sqltext signature in dictionary tables
Rem    mlfeng      05/25/05 - bug 4393879: disable metrics constraints 
Rem    kyagoub     04/06/05 - add sqltune resume_filter 
Rem    mlfeng      05/09/05 - drop public synonym 
Rem    evoss       05/16/05 - remove calendar downgrade 
Rem    preilly     05/05/05 - Empty LOGMNRP_CTAS_PART_MAP during downgrade 
Rem    pbelknap    05/02/05 - wri$_adv_sqlt_plan constraint name change 
Rem    pbelknap    04/28/05 - add sqlset plan temp table
Rem    svshah      05/11/05 - 
Rem    qyu         04/28/05 - #4280015: change name back to array_index for octs 
Rem    weiwang     04/28/05 - remove 10.2 attribute in msg_prop_t 
Rem    abrown      04/26/05 - bug 4219586: revert logmnr_log primary key 
Rem    ksurlake    04/22/05 - drop constructor for aq$_reg_info
Rem    mxu         04/14/05 - Drop dbms_sqlhash package 
Rem    mlfeng      04/11/05 - null out column for wrh$_sqlstat 
Rem    alakshmi    03/31/05 - drop dbms_streams_mt 
Rem    rburns      04/02/05 - fix lrg problems 
Rem    adagarwa    03/24/05 - null out new columns in wrh$_active_sess_history
Rem    weiwang     03/25/05 - invalidate rules engine objects in downgrade 
Rem    tfyu        03/17/05 - Bug 4262763
Rem    lkaplan     03/18/05 - bug 4112826 - upgrade and downgrade of 
Rem                           catqueue.sql needed 
Rem    alakshmi    03/09/05 - recoverable scripts 
Rem    wyang       03/02/05 - null out columns in wrh$undostat 
Rem    nshodhan    03/04/05 - drop v$streams_transaction
Rem    sylin       02/25/05 - drop dbms_sqlplus_script 
Rem    alakshmi    02/23/05 - error recovery for maintain_ apis
Rem    twtong      02/21/05 - bug-4168683
Rem    rburns      02/21/05 - drop dbms_assert last 
Rem    gviswana    02/08/05 - Remove UTL_RECOMP views 
Rem    weiwang     02/09/05 - 
Rem    hxlin       02/07/05 - Drop sql response view 
Rem    htran       02/01/05 - drop dba_streams_apply_spill_txn view
Rem    alakshmi    01/28/05 - streams$_apply_spill_msgs_part
Rem    mture       01/26/05 - add AggXMLInputType during downgrade.
Rem                           grant public exec privs back to xmlagg, xmlseq
Rem    evoss       01/25/05 - drop type scheduler int array 
Rem    evoss       01/18/05 - scheduler_run_details cpu_used datatype change 
Rem    ddas        01/11/05 - #(4052436) downgrade for outln.ol$hints 
Rem    mcusson     01/04/05 - drop logmnr_parameter$ during downgrade 
Rem    elu         01/03/05 - apply spilling
Rem    rramkiss    01/06/05 - drop dbms_isched_chain_condition package 
Rem    rburns      12/22/04 - fix dbms_assert drop 
Rem    kumamage    12/13/04 - remove parameter views 
Rem    dbronnik    12/13/04 - drop package dbms_assert
Rem    ksurlake    12/07/04 - drop type sys.re$rule_list
Rem    adagarwa    11/23/04 - Remove SQL Report related tables 
Rem    htran       11/16/04 - downgrade spare2 and flags in streams$_prepare_*
Rem    clei        11/15/04 - lrg 1796684 delete reused privs before restore it
Rem    kmeiyyap    11/12/04 - drop prvtaqiu.sql package 
Rem    mbastawa    11/12/04 - drop 10.2 TSMSYS schema for 10.1 
Rem    kneel       11/09/04 - lrg 1795206 upgrade/downgrade issues 
Rem    kyagoub     11/03/04 - remove sqltune R2 new parameter 
Rem    kyagoub     10/04/04 - use bind_data vs bind_list is sts 
Rem    weiwang     11/04/04 - fix downgrade script
Rem    lvbcheng    11/03/04 - Drop UTL_NLA types 
Rem    apareek     10/21/04 - drop library dbms_extended_tts_checks_lib
Rem    apadmana    11/02/04 - bug3986609: drop dbms_transform_eximp_internal 
Rem    weiwang     10/12/04 - drop deq by condition view 
Rem    rvissapr    10/28/04 - rvissapr_bug-3802440
Rem    jmzhang     10/15/04 - add gv/v$standby_apply_snapshot
Rem                         - drop logstdby_thread
Rem    mlfeng      10/07/04 - awr sqlstat changes 
Rem    rgmani      10/26/04 - scheduler attributes table has new columns 
Rem    clei        10/28/04 - remove merge [any] view permissions
Rem    pthornto    10/07/04 - drop DBA_CONNECT_ROLE_GRANTEES view
Rem    apadmana    10/05/04 - bug3607838: manage any queue
Rem    abrumm      09/29/04 - LRG 1745604: drop dbms_errlog 
Rem    banand      09/27/04 - drop rman_backup_type 
Rem    qiwang      08/26/04 - truncate  logmnr_filter$ table 
Rem    mtakahar    09/03/04 - downgrade mon_mods$/mon_mods_all$
Rem    nbhatt      08/30/04 - make aq downgrande idempotent 
Rem    mhho        08/31/04 - drop DPCR package for downgrade 
Rem    mlfeng      07/29/04 - truncate new AWR tables 
Rem    ssvemuri    08/30/04 - drop change notification views
Rem    xuhuali     08/11/04 - audit java
Rem    jnarasin    08/02/04 - EUS Proxy auditing changes 
Rem    jmzhang     08/26/04 - drop v$logstdby_status
Rem                           change v$pstdby_status to v$datagurd_stats
Rem    mxyang      07/30/04 - drop package dbms_preprocessor
Rem    jwwarner    08/19/04 - drop new xquery objects 
Rem    pbelknap    07/16/04 - AWR report types 
Rem    jmzhang     08/17/04 - drop gv$logstdby_thread, v$logstdby_status
Rem                           drop v$phystdby_status
Rem    kyagoub     08/16/04 - remove public synonym sql_object 
Rem    kyagoub     07/28/04 - drop sql tuning all_views_xxx 
Rem    jsoule      08/03/04 - downgrade from dbsnmp baselines 
Rem    jmzhang     07/25/04 - drop v$/gv$rfs_thread
Rem    gmulagun    08/02/04 - drop DBA_COMMON_AUDIT_TRAIL view 
Rem    gssmith     07/29/04 - Add DROP of PRVT_WORKLOAD_NOPRIV 
Rem    rburns      07/29/04 - move some actions to catdwgrd.sql 
Rem    nshodhan    07/29/04 - remove _DBA_STREAMS_NEWLY_SUPTED_10_2 
Rem    htran       06/18/04 - remove commit time qtab export support
Rem    bemeng      07/26/04 - drop dbms_space: reference to new fixed table
Rem    hxlin       07/20/04 - Update SQL Response Time downgrade
Rem    kdias       07/21/04 - privs for OUTLN user 
Rem    mhho        07/20/04 - drop synonyms own downgrade 
Rem    nmanappa    07/20/04 - bug 3690876 - add privs 194-199,239,240
Rem    dmwong      07/21/04 - grant priv. back to connect role 
Rem    skaluska    07/09/04 - split tsm_hist$ into tsm_src$, tsm_dst$ 
Rem    clei        06/29/04 - drop Transparent Column Encryption dict objects
Rem    twtong      07/02/04 - drop package dbms_cdc_sys_ipublish 
Rem    kyagoub     06/30/04 - remove plan filter parameter 
Rem    pbelknap    06/28/04 - add mask to join 
Rem    nbhatt      06/30/04 - downgrade invalidation bug 
Rem    sbalaram    05/25/04 - AQ: recreate base view, alter primary key
Rem    hxlin       06/28/04 - downgrade sql response time 
Rem    htran       06/18/04 - remove file group export registrations
Rem    svshah      06/28/04 - Drop synonyms for v$sqlstats 
Rem    ssvemuri    06/25/04 - drop change notification dictionary objs
Rem    bhabeck     06/14/04 - drop v$process_memory_detail 
Rem    rburns      06/18/04 - drop dbms_rcvman 
Rem    veeve       06/16/04 - drop package dbms_ash_internal
Rem    ajadams     06/15/04 - drop index on logstdby events table 
Rem    suelee      06/04/04 - add new view resource manager views 
Rem    mramache    06/01/04 - AWR report types 
Rem    kneel       06/25/04 - instance down alert reliability work 
Rem    aahluwal    06/23/04 - drop DBMS_HAEVENTNOT_PRVT_LIB 
Rem    kneel       06/10/04 - drop DBMS_SVRALRT_PRVT_LIB 
Rem    kneel       06/08/04 - drop package dbms_ha_alerts_prvt 
Rem    pbelknap    06/25/04 - drop sql plan types 
Rem    bdagevil    06/19/04 - add [g]v$sqlstats and [g]v$sqlarea_plan_hash 
Rem    pbelknap    06/04/04 - remap sts names 
Rem    pbelknap    05/14/04 - SQLSET_ROW change 
Rem    kyagoub     05/14/04 - replace sql_binds_nt/sql_binds_ntab 
Rem    pbelknap    05/07/04 - sqltune bind types, STS schema 
Rem    sridsubr    06/04/04 - Drop new tables 
Rem    weili       06/07/04 - drop decision tree internal function 
Rem    rvissapr    06/10/04 - drop exp views 
Rem    ahwang      06/10/04 - remov restore point audit_actions rows
Rem    mlfeng      05/21/04 - downgrade wr_control for topnsql
Rem    veeve       05/28/04 - NULL out WRH$_SEG_STAT_OBJ.[INDEX_TYPE,BASE*]
Rem    narora      05/20/04 - truncate wrh$_sess_time_stats, streams tables
Rem    narora      05/20/04 - drop sess_time_stats, streams views
Rem    ushaft      05/15/04 - truncate WRH$_COMP_IOSTAT, WRH$_SGA_TARGET_ADVICE
Rem                           and drop views
Rem    rburns      06/04/04 - truncate registry schemas 
Rem    ksurlake    06/01/04 - downgrade aq$_reg_info
Rem    jnarasin    05/27/04 - Alter User changes for EUS Proxy project 
Rem    gmulagun    05/26/04 - drop v$xml_audit_trail related views 
Rem    lvbcheng    06/02/04 - drop utl_nla
Rem    evoss       06/14/04 - fix downgrade of calendars
Rem    rramkiss    06/14/04 - lrg 1708395-don't drop scheduler types for 9.2 
Rem                           downgrade 
Rem    kpatel      05/18/04 - drop v$asm_diskgroup_stat and v$asm_disk_stat
Rem    dcassine    05/13/04 - Streams Dependency downgrade
Rem    ahwang      05/26/04 - drop restore point related objects 
Rem    molagapp    05/22/04 - drop v$flash_recovery_area_usage view
Rem    bhabeck     05/23/04 - drop v$process_memory on downgrades 
Rem    rvissapr    05/24/04 - drop dbms_dblink 
Rem    evoss       05/28/04 - downgrade calendar schedules 
Rem    vakrishn    06/01/04 - add downgrade for status column of WRH$_UNDOSTAT
Rem    banand      05/21/04 - drop RMAN job views
Rem    mlfeng      05/18/04 - update swrf_version in wr_control 
Rem    kneel       05/26/04 - remove new package dbms_server_alert_prvt 
Rem    ushaft      05/26/04 - drop views for wrh$_streams_pool_advice
Rem    narora      05/19/04 - drop new v$streams_pool_advice views 
Rem    mxyang      06/02/04 - drop package DBMS_DB_VERSION
Rem    dcassine    06/11/04 - drop DBMS_APPLY_USER_AGENT package
Rem    liwong      06/09/04 - Add get_source_time 
Rem    liwong      06/08/04 - Add oldest_transaction_id 
Rem    dcassine    05/27/04 - change streams$_apply_process 
Rem    wesmith     05/24/04 - add online redefinition downgrade 
Rem    rdecker     05/24/04 - drop package UTL_MATCH
Rem    tcruanes    05/29/04 - add downgrade support for SQL_JOIN_FILTER 
Rem    dsemler     05/14/04 - add dtp support 
Rem    dsemler     04/26/04 - add downgrade for goal column in service$. 
Rem    bdagevil    05/26/04 - generalize timestamp column in explain plan 
Rem    bdagevil    05/24/04 - add code to downgrade other_xml column 
Rem    nfolkert    05/25/04 - drop index rebuild list objects
Rem    veeve       05/06/04 - blocking_session,xid columns in ASH 
Rem    skaluska    05/05/04 - merge to MAIN 
Rem    skaluska    04/28/04 - sync with RDBMS_MAIN_SOLARIS_040426 
Rem    jciminsk    04/28/04 - merge from RDBMS_MAIN_SOLARIS_040426 
Rem    skaluska    04/15/04 - TSM modifications 
Rem    jciminsk    04/09/04 - merge from RDBMS_MAIN_SOLARIS_040405 
Rem    lchidamb    03/23/04 - drop director history/reason table 
Rem    skaluska    03/18/04 - move TSM changes from e0902000.sql to 
Rem    jstamos     03/16/04 - drop dbms_db_director_policy 
Rem    rramkiss    03/08/04 - drop scheduler chains
Rem    rramkiss    03/08/04 - remove scheduler chain views
Rem    jciminsk    03/05/04 - move drop of dbms_tsm 
Rem    jciminsk    03/04/04 - move grid from e0902000 
Rem    ckantarj    02/27/04 - add cardinality columns to service$ 
Rem    mxiao       05/13/04 - set chdlevid# in dimjoinkey$ 
Rem    bpwang      03/10/04 - internal lcr transformation downgrade
Rem    weiwang     03/09/04 - rules downgrade change 
Rem    mbrey       05/03/04 - CDC new views removal 
Rem    mbrey       04/08/04 - CDC meta changes for sequences 
Rem    mbrey       03/30/04 - CDC change sources/propagations 
Rem    lkaplan     04/01/04 - generic lob assembly 
Rem    nmukherj    05/12/04 - delete rows from wri$_alert_threshold 
Rem                           corresponding to bytes based thresholds 
Rem                           with metric id 9001
Rem    wyang       03/12/04 - transportable database 
Rem    smuthuli    05/21/04 - auto advisor changes 
Rem    smuthuli    05/18/04 - one more stat to seg_stat 
Rem    weiwang     03/12/04 - truncate new rules engine tables 
Rem    liwong      02/21/04 - Fast column value evaluation 
Rem    pokumar     05/12/04 - remove sga_target_advice views
Rem    rgmani      05/19/04 - Downgrade for scheduler 
Rem    mxyang      05/10/04 - drop plsql_ccflags
Rem    atsukerm    04/27/04 - remove the database-level trace 
Rem    htran       04/19/04 - drop file group packages/views. truncate tables
Rem    alakshmi    04/19/04 - system privilege READ_ANY_FILE_GROUP 
Rem    alakshmi    02/24/04 - delete new system privileges for file groups 
Rem    alakshmi    02/16/04 - Drop dbms_file_group packages
Rem    sbodagal    04/27/04 - set flags to 0 in dimlevel$
Rem    ajadams     05/13/04 - drop logstdby_transaction 
Rem    jmzhang     05/12/04 - alter column datatype in system.logstdby$events
Rem                         - nullify new columns in logstdby$apply_milestone
Rem                         - nullify new column in logstdby$apply_progress
Rem    smangala    04/21/04 - drop logmnr_dictionary_load view 
Rem    mlfeng      04/27/04 - set values to NULL for AWR table
Rem    nshodhan    04/05/04 - remove downstream capture hotmining
Rem    rramkiss    04/21/04 - remove 10.2 CREATE EXTERNAL JOB system privilege 
Rem    bgarin      04/08/04 - Add LogMiner downgrade section 
Rem    mxiao       03/30/04 - set values to NULL for MV metadata
Rem    gssmith     04/07/04 - SQL Access Advisor adjustments 
Rem    jgalanes    03/16/04 - Follow up for 3467567 - drop new views on Dgrade
Rem    clei        03/02/04 - put back encryption profile privileges
Rem    rdecker     03/03/04 - support procedureplsql$
Rem    bpwang      02/19/04 - downgrade error creation time in apply$_error 
Rem    mjaeger     02/09/04 - bug 3369744: drop support views for ALL_SYNONYMS
Rem    pbelknap    02/12/04 - case-sensitive sqlset definitions
Rem    bmccarth    02/16/04 - drop export partition template views
Rem    mlfeng      02/03/04 - AWR segstat and rac changes
Rem    sbalaram    02/03/04 - truncate apply$_error_txn
Rem    gssmith     02/11/04 - Advisor Framework changes 
Rem    rburns      01/16/04 - rburns_add_10_1_updw_scripts
Rem    rburns      01/08/04 -
Rem    rburns      01/07/04 - Created

Rem =========================================================================
Rem BEGIN STAGE 1: downgrade from the current release to 10.2
Rem =========================================================================

@@e1002000

Rem =========================================================================
Rem END STAGE 1: downgrade from the current release to 10.2
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade dictionary from 10.2 to 10.1
Rem =========================================================================

Rem=========================================================================
Rem Delete new system privileges here
Rem=========================================================================

-- delete merge any view system privilege
delete from SYSAUTH$ where privilege# = -233;
delete from SYSTEM_PRIVILEGE_MAP where privilege = -233;

insert into SYSTEM_PRIVILEGE_MAP values (-194, 'WRITEDOWN DBLOW', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-195, 'READUP DBHIGH', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-196, 'WRITEUP DBHIGH', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-197, 'WRITEDOWN', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-198, 'READUP', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-199, 'WRITEUP', 0);

insert into SYSTEM_PRIVILEGE_MAP values (-229, 'CREATE SECURITY PROFILE',0);
insert into SYSTEM_PRIVILEGE_MAP values (-230, 'CREATE ANY SECURITY PROFILE',0);
insert into SYSTEM_PRIVILEGE_MAP values (-231, 'DROP ANY SECURITY PROFILE',0);
insert into SYSTEM_PRIVILEGE_MAP values (-232, 'ALTER ANY SECURITY PROFILE',0);
insert into SYSTEM_PRIVILEGE_MAP values (-233, 'ADMINISTER SECURITY', 0);

insert into SYSTEM_PRIVILEGE_MAP values (-239, 'DEBUG CONNECT USER', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-240, 'DEBUG CONNECT ANY', 0);

insert into STMT_AUDIT_OPTION_MAP values (194, 'WRITEDOWN DBLOW', 0);
insert into STMT_AUDIT_OPTION_MAP values (195, 'READUP DBHIGH', 0);
insert into STMT_AUDIT_OPTION_MAP values (196, 'WRITEUP DBHIGH', 0);
insert into STMT_AUDIT_OPTION_MAP values (197, 'WRITEDOWN', 0);
insert into STMT_AUDIT_OPTION_MAP values (198, 'READUP', 0);
insert into STMT_AUDIT_OPTION_MAP values (199, 'WRITEUP', 0);

insert into STMT_AUDIT_OPTION_MAP values (239, 'DEBUG CONNECT USER', 0);
insert into STMT_AUDIT_OPTION_MAP values (240, 'DEBUG CONNECT ANY', 0);

-- delete from SYSAUTH$ where privilege# in (<list of privilege#s>);
-- delete from SYSTEM_PRIVILEGE_MAP where privilege in (<list of privilege#s>);
-- commit;

-- delete file group system privileges
delete from SYSAUTH$ where privilege# in (-276, -277, -278);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-276, -277, -278);

-- delete change notification and create external job privilege
delete from SYSAUTH$ where privilege# in (-279, -280);
delete from SYSTEM_PRIVILEGE_MAP where privilege in (-279, -280);

commit;
Rem=========================================================================
Rem Delete new object privileges here
Rem=========================================================================

--delete from OBJAUTH$            where privilege# in ();
--delete from TABLE_PRIVILEGE_MAP where privilege in ();


-- delete merge view object privilege
delete from OBJAUTH$            where privilege# in (28);
delete from TABLE_PRIVILEGE_MAP where privilege in (28);
commit;

Rem=========================================================================
Rem Undo removal of privileges from CONNECT role here
Rem=========================================================================

-- grant the privileges back
grant alter session,create synonym,create view,
  create database link,create table,create cluster,create sequence to connect;
commit;

Rem=========================================================================
Rem Delete new audit options here
Rem=========================================================================

-- delete from AUDIT$                where option# in (<list of option#>);
-- delete from STMT_AUDIT_OPTION_MAP where option# in (<list of option#>);
-- commit;

delete from AUDIT$                where option# in (276, 277, 278);
delete from STMT_AUDIT_OPTION_MAP where option# in (276, 277, 278);

delete from AUDIT$ where option# in (279, 280);
delete from STMT_AUDIT_OPTION_MAP where option# in (279, 280);

delete from AUDIT$ where option# in (93, 94, 95, 96, 97, 98, 99, 100, 101);
delete from STMT_AUDIT_OPTION_MAP 
where option# in (93, 94, 95, 96, 97, 98, 99, 100, 101);

delete from AUDIT$                where option# in (233);
delete from STMT_AUDIT_OPTION_MAP where option# in (233);

-- AQ system privileges
update STMT_AUDIT_OPTION_MAP set property = 1
  where option# = 218 and name = 'MANAGE ANY QUEUE'; 
update STMT_AUDIT_OPTION_MAP set property = 1
  where option# = 219 and name = 'ENQUEUE ANY QUEUE'; 
update STMT_AUDIT_OPTION_MAP set property = 1
  where option# = 220 and name = 'DEQUEUE ANY QUEUE'; 
delete from AUDIT$ where option# in (218, 219, 220);

-- Rules Engine system privileges
delete from STMT_AUDIT_OPTION_MAP
  where option# = 245 and name = 'CREATE EVALUATION CONTEXT';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 246 and name = 'CREATE ANY EVALUATION CONTEXT';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 247 and name = 'ALTER ANY EVALUATION CONTEXT';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 248 and name = 'DROP ANY EVALUATION CONTEXT';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 249 and name = 'EXECUTE ANY EVALUATION CONTEXT';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 250 and name = 'CREATE RULE SET';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 251 and name = 'CREATE ANY RULE SET';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 252 and name = 'ALTER ANY RULE SET';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 253 and name = 'DROP ANY RULE SET';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 254 and name = 'EXECUTE ANY RULE SET';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 257 and name = 'CREATE RULE';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 258 and name = 'CREATE ANY RULE';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 259 and name = 'ALTER ANY RULE';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 260 and name = 'DROP ANY RULE';
delete from STMT_AUDIT_OPTION_MAP
  where option# = 261 and name = 'EXECUTE ANY RULE';
delete from AUDIT$ where option# in (245, 246, 247, 248, 249, 250, 251, 252,
                                     253, 254, 257, 258, 259, 260, 261);

commit;

Rem Delete new audit_actions rows
Rem=========================================================================

-- delete restore point related rows

delete from AUDIT_ACTIONS where action = 206 or action = 207;

-- delete single session proxy related rows

DELETE FROM  audit_actions
       WHERE action = 208 ;

commit;


Rem =========================================================================
Rem Begin Downgrade Advisor Framework items
Rem =========================================================================

alter type wri$_adv_sqlaccess_adv
  drop overriding member procedure sub_implement(task_id in number, 
                                                 rec_id in number,
                                                 exit_on_error number)
  cascade;

alter type wri$_adv_tunemview_adv
  drop overriding member procedure sub_implement(task_id in number, 
                                                 rec_id in number,
                                                 exit_on_error number)
  cascade;

alter type wri$_adv_abstract_t
  drop member procedure sub_implement(task_id in number, 
                                      rec_id in number,
                                      exit_on_error number)
  cascade;

Rem
Rem change the journaling flags back to prior settings
Rem

declare
  dtype binary_integer;
begin
  select datatype into dtype from sys.wri$_adv_def_parameters
    where name = 'JOURNALING';

  if dtype = 2 then 
    update sys.wri$_adv_journal
      set type = decode(type,4,1,3,2,2,3,1,4,type);

    update sys.wri$_adv_def_parameters
      set value = decode(value,'UNUSED',0,'FATAL',4,'ERROR',3,'WARNING',2,
                         'INFORMATION',1,
                         'INFORMATION2',5,'INFORMATION3',6,'INFORMATION4',6,'INFORMATION5',
                         8,'INFORMATION6',9,0),
          datatype = 1
      where name = 'JOURNALING';

    update sys.wri$_adv_parameters
      set value = decode(value,'UNUSED',0,'FATAL',4,'ERROR',3,'WARNING',2,
                         'INFORMATION',1,
                         'INFORMATION2',5,'INFORMATION3',6,'INFORMATION4',6,'INFORMATION5',
                         8,'INFORMATION6',9,0),
          datatype = 1
      where name = 'JOURNALING';
  end if;
end;
/

Rem
Rem Remove new default task parameters for advisors
Rem

create or replace procedure advfmwk_delete_def_parameter (l_id    number,
                                                          l_name  varchar2)
  is
    l_cnt binary_integer;
  begin
    select count(*) into l_cnt from wri$_adv_def_parameters
      where advisor_id = l_id and name = l_name;

    if l_cnt > 0 then
      delete from wri$_adv_def_parameters 
        where advisor_id = l_id and name = l_name;
    end if;
  end advfmwk_delete_def_parameter;
/

Rem
Rem Remove the new advisor-specified default parameters
Rem

begin
  advfmwk_delete_def_parameter (2, '_IMP_ERROR_LIST');
  advfmwk_delete_def_parameter (2, '_INCLUDE_SCRIPT_HEADER');
  advfmwk_delete_def_parameter (2, '_INVALID_SQLCOMMENTS_LIST');
  advfmwk_delete_def_parameter (2, '_INVALID_USERNAME_LIST');
  advfmwk_delete_def_parameter (2, '_SHOW_ADV_PARAMETERS');
  advfmwk_delete_def_parameter (2, '_TEST_MODE');
  advfmwk_delete_def_parameter (2, 'DISABLE_FILTERS');
  advfmwk_delete_def_parameter (2, 'IMPLEMENT_EXIT_ON_ERROR');
  advfmwk_delete_def_parameter (2, 'INVALID_ACTION_LIST');
  advfmwk_delete_def_parameter (2, 'INVALID_MODULE_LIST');
  advfmwk_delete_def_parameter (2, 'INVALID_SQLSTRING_LIST');
  advfmwk_delete_def_parameter (2, 'INVALID_USERNAME_LIST');
  advfmwk_delete_def_parameter (2, 'RECOMMEND_MV_EXACT_TEXT_MATCH');
  advfmwk_delete_def_parameter (2, 'SHOW_RETAINS');
  advfmwk_delete_def_parameter (2, 'STORAGE_MODE');
  advfmwk_delete_def_parameter (2, 'VALID_ACTION_LIST');
  advfmwk_delete_def_parameter (2, 'VALID_MODULE_LIST');
  advfmwk_delete_def_parameter (2, 'VALID_SQLSTRING_LIST');
  advfmwk_delete_def_parameter (2, 'VALID_USERNAME_LIST');

  advfmwk_delete_def_parameter (4, 'PLAN_FILTER');
  advfmwk_delete_def_parameter (4, 'LOCAL_TIME_LIMIT');
  advfmwk_delete_def_parameter (4, 'COMMIT_ROWS');
  advfmwk_delete_def_parameter (4, '_SQLTUNE_TRACE');
  advfmwk_delete_def_parameter (4, 'RESUME_FILTER');

  advfmwk_delete_def_parameter (6, '_INVALID_SQLCOMMENTS_LIST');
  advfmwk_delete_def_parameter (6, '_INVALID_USERNAME_LIST');
  advfmwk_delete_def_parameter (6, '_SHOW_ADV_PARAMETERS');
  advfmwk_delete_def_parameter (6, '_TEST_MODE');
  advfmwk_delete_def_parameter (6, 'DISABLE_FILTERS');
  advfmwk_delete_def_parameter (6, 'INVALID_ACTION_LIST');
  advfmwk_delete_def_parameter (6, 'INVALID_MODULE_LIST');
  advfmwk_delete_def_parameter (6, 'INVALID_SQLSTRING_LIST');
  advfmwk_delete_def_parameter (6, 'INVALID_USERNAME_LIST');
  advfmwk_delete_def_parameter (6, 'VALID_ACTION_LIST');
  advfmwk_delete_def_parameter (6, 'VALID_MODULE_LIST');
  advfmwk_delete_def_parameter (6, 'VALID_SQLSTRING_LIST');
  advfmwk_delete_def_parameter (6, 'VALID_USERNAME_LIST');

  advfmwk_delete_def_parameter (7, '_IMP_ERROR_LIST');
  advfmwk_delete_def_parameter (7, '_INCLUDE_SCRIPT_HEADER');
  advfmwk_delete_def_parameter (7, '_INVALID_SQLCOMMENTS_LIST');
  advfmwk_delete_def_parameter (7, '_INVALID_USERNAME_LIST');
  advfmwk_delete_def_parameter (7, '_SHOW_ADV_PARAMETERS');
  advfmwk_delete_def_parameter (7, '_TEST_MODE');
  advfmwk_delete_def_parameter (7, 'DISABLE_FILTERS');
  advfmwk_delete_def_parameter (7, 'IMPLEMENT_EXIT_ON_ERROR');
  advfmwk_delete_def_parameter (7, 'INVALID_ACTION_LIST');
  advfmwk_delete_def_parameter (7, 'INVALID_MODULE_LIST');
  advfmwk_delete_def_parameter (7, 'INVALID_SQLSTRING_LIST');
  advfmwk_delete_def_parameter (7, 'INVALID_USERNAME_LIST');
  advfmwk_delete_def_parameter (7, 'RECOMMEND_MV_EXACT_TEXT_MATCH');
  advfmwk_delete_def_parameter (7, 'SHOW_RETAINS');
  advfmwk_delete_def_parameter (7, 'STORAGE_MODE');
  advfmwk_delete_def_parameter (7, 'VALID_ACTION_LIST');
  advfmwk_delete_def_parameter (7, 'VALID_MODULE_LIST');
  advfmwk_delete_def_parameter (7, 'VALID_SQLSTRING_LIST');
  advfmwk_delete_def_parameter (7, 'VALID_USERNAME_LIST');
end;
/

drop procedure advfmwk_delete_def_parameter;

Rem
Rem Remove new default task parameters from existing tasks
Rem

declare
  cursor param_cur IS 
    SELECT a.task_id,a.name
      FROM sys.wri$_adv_parameters a,sys.wri$_adv_tasks b
      WHERE a.task_id = b.id
        and not exists (select c.name from sys.wri$_adv_def_parameters c
                        where (c.advisor_id = b.advisor_id or c.advisor_id = 0)
                          and c.name = a.name);

  l_task_id binary_integer;
  l_name VARCHAR2(30);
begin
  open param_cur;
  
  loop
    fetch param_cur into l_task_id,l_name;
    exit when param_cur%NOTFOUND;
    
    delete from sys.wri$_adv_parameters
      where name = l_name and task_id = l_task_id;
  end loop;

  close param_cur;

end;
/

Rem
Rem  Simple updates
Rem
update sys.wri$_adv_def_parameters
  set flags = 0
  where name = 'TIME_LIMIT';

update sys.wri$_adv_parameters
  set flags = 0
  where name = 'TIME_LIMIT';

update sys.wri$_adv_def_parameters
  set flags = 0
  where name = 'EM_DATA';

update sys.wri$_adv_parameters
  set flags = bitand(flags,14)
  where name = 'EM_DATA';

update sys.wri$_adv_def_parameters
  set description = null;

update sys.wri$_adv_parameters
  set description = null;

update sys.wri$_adv_recommendations
  set flags = 0;

update sys.wri$_adv_sqlt_plans
  set other_xml = null;

update sys.wri$_adv_objects
  set other = null;

Rem
Rem Changes in advisor definitions: make sqltune task not resumable 
Rem
update wri$_adv_definitions
  set property = 3
  where id = 4; 

Rem
Rem Delete 9001 metric rows from wri$_alert_threshold 
Rem

delete from wri$_alert_threshold where t_metrics_id = 9001;

commit;

drop package prvt_workload_nopriv;

Rem =========================================================================
Rem End Downgrade Advisor Framework items
Rem =========================================================================

Rem Downgrade mon_mods$/mon_mods_all$: Copy the entries back to mon_mods$
Rem except for the ones that are non-physical fragments.
begin
  merge into mon_mods$ m
    using
    (select
       mma.obj#, mma.inserts, mma.updates, mma.deletes,
       mma.timestamp, mma.flags, mma.drop_segments
     from mon_mods_all$ mma
     where not exists
          (select * from
             (select obj# from tab$ where bitand(property, 32) != 0
              union all
              select obj# from tabcompart$ tp) t
           where t.obj# = mma.obj#)
     ) v on (m.obj# = v.obj#)
    when matched then
      update
        set m.inserts = m.inserts + v.inserts,
            m.updates = m.updates + v.updates,
            m.deletes = m.deletes + v.deletes,
            m.flags = m.flags + v.flags - bitand(m.flags,v.flags)
                                                  /* bitor(m.flags,v.flags) */,
            m.drop_segments = m.drop_segments + v.drop_segments
      when NOT matched then
        insert
          values (v.obj#, v.inserts, v.updates, v.deletes, sysdate,
                  v.flags, v.drop_segments);
  commit;

  execute immediate 'truncate table mon_mods_all$';
end;
/

Rem remove plsql metadata table
delete from procedureplsql$;

Rem
Rem update sys_nc_array_index$ col name back to array_index for octs

update col$ c set c.name='ARRAY_INDEX'
  where c.name = 'SYS_NC_ARRAY_INDEX$' and c.col#=0 and c.intcol#=1 and
    bitand(c.property, 32) = 32 and c.obj# in (select n.ntab# from ntab$ n)
/
 
commit;

Rem=========================================================================
Rem Drop new fixed views here
Rem=========================================================================

Rem
Rem STREAMS SGA ADVISORY view
Rem
drop public synonym V$STREAMS_POOL_ADVICE;
drop view V_$STREAMS_POOL_ADVICE;
drop public synonym GV$STREAMS_POOL_ADVICE;
drop view GV_$STREAMS_POOL_ADVICE;
  
Rem
Rem STREAMS Transaction view
Rem
drop public synonym V$STREAMS_TRANSACTION;
drop view V_$STREAMS_TRANSACTION;
drop public synonym GV$STREAMS_TRANSACTION;
drop view GV_$STREAMS_TRANSACTION;
  
Rem 
Rem Drop SQL_JOIN_FILTER views
Rem 
DROP VIEW gv_$sql_join_filter;
DROP PUBLIC SYNONYM gv$sql_join_filter;
DROP VIEW v_$sql_join_filter;
DROP PUBLIC SYNONYM v$sql_join_filter;

Rem 
Rem Drop TSM views
Rem 
DROP VIEW gv_$tsm_sessions;
DROP PUBLIC SYNONYM gv$tsm_sessions;
DROP VIEW v_$tsm_sessions;
DROP PUBLIC SYNONYM v$tsm_sessions;

Rem 
Rem RMAN views dealing with RMAN backup jobs
Rem
drop public synonym v$rman_backup_subjob_details;
drop view v_$rman_backup_subjob_details;
drop public synonym v$rman_backup_job_details;
drop view v_$rman_backup_job_details;
drop public synonym v$backup_set_details;
drop view v_$backup_set_details;
drop public synonym v$backup_piece_details;
drop view v_$backup_piece_details;
drop public synonym v$backup_copy_details;
drop view v_$backup_copy_details;
drop public synonym v$proxy_copy_details;
drop view v_$proxy_copy_details;
drop public synonym v$proxy_archivelog_details;
drop view v_$proxy_archivelog_details;
drop public synonym v$backup_datafile_details;
drop view v_$backup_datafile_details;
drop public synonym v$backup_controlfile_details;
drop view v_$backup_controlfile_details;
drop public synonym v$backup_archivelog_details;
drop view v_$backup_archivelog_details;
drop public synonym v$backup_spfile_details;
drop view v_$backup_spfile_details;
drop public synonym v$backup_set_summary;
drop view v_$backup_set_summary;
drop public synonym v$backup_datafile_summary;
drop view v_$backup_datafile_summary;
drop public synonym v$backup_controlfile_summary;
drop view v_$backup_controlfile_summary;
drop public synonym v$backup_archivelog_summary;
drop view v_$backup_archivelog_summary;
drop public synonym v$backup_spfile_summary;
drop view v_$backup_spfile_summary;
drop public synonym v$backup_copy_summary;
drop view v_$backup_copy_summary;
drop public synonym v$proxy_copy_summary;
drop view v_$proxy_copy_summary;
drop public synonym v$proxy_archivelog_summary;
drop view v_$proxy_archivelog_summary;
drop public synonym v$unusable_backupfile_details;
drop view v_$unusable_backupfile_details;
drop public synonym v$rman_backup_type;
drop view v_$rman_backup_type;
drop function v_listBackupPipe;
drop type v_lbRecSetImpl_t;
drop type v_lbRecSet_t;
drop type v_lbRec_t; 

Rem
Rem exp views dealing with table subpartition templates
Rem
drop view sys.exptabsubpart;
drop view sys.exptabsubpartdata_view;
drop view sys.exptabsubpartlobfrag;
drop view sys.exptabsubpartlob_view;

Rem
Rem imp views dealing with LOBs having triggers or NOT NULL constraints
Rem
drop view sys.imp_tab_trig;
drop view sys.imp_lob_notnull;

Rem
Rem LogMiner dictionary load view
Rem
drop public synonym v$logmnr_dictionary_load;
drop view v_$logmnr_dictionary_load;
drop public synonym gv$logmnr_dictionary_load;
drop view gv_$logmnr_dictionary_load;

Rem
Rem RFS fixed views
Rem
drop public synonym gv$rfs_thread;
drop view gv_$rfs_thread;
drop public synonym v$rfs_thread;
drop view v_$rfs_thread;

Rem
Rem asm fixed views
Rem
drop public synonym v$asm_diskgroup_stat;
drop view v_$asm_diskgroup_stat;
drop public synonym gv$asm_diskgroup_stat;
drop view gv_$asm_diskgroup_stat;
drop public synonym v$asm_disk_stat;
drop view v_$asm_disk_stat;
drop public synonym gv$asm_disk_stat;
drop view gv_$asm_disk_stat;

Rem
Rem flash_recovery_area_usage view
Rem
drop public synonym v$flash_recovery_area_usage;
drop view v_$flash_recovery_area_usage;

Rem
Rem restore_point view
Rem
drop public synonym v$restore_point;
drop view v_$restore_point;
drop public synonym gv$restore_point;
drop view gv_$restore_point;

Rem
Rem Remove SGA_TARGET_ADVICE views
Rem
drop public synonym v$sga_target_advice;
drop view v_$sga_target_advice;
drop public synonym gv$sga_target_advice;
drop view gv_$sga_target_advice;

Rem
Rem Remove Transparent Database Encryption related views
Rem
drop public synonym v$wallet;
drop view v_$wallet;
drop public synonym gv$wallet;
drop view gv_$wallet;

Rem
Rem Remove resource manager-related views 
Rem 
drop public synonym v$rsrc_cons_group_history;
drop view v_$rsrc_cons_group_history;
drop public synonym gv$rsrc_cons_group_history;
drop view gv_$rsrc_cons_group_history;
drop public synonym v$rsrc_plan_history;
drop view v_$rsrc_plan_history;
drop public synonym gv$rsrc_plan_history;
drop view gv_$rsrc_plan_history;

Rem
Rem Remove interconnect views
Rem
drop public synonym v$cluster_interconnects;
drop view v_$cluster_interconnects;
drop public synonym gv$cluster_interconnects;
drop view gv_$cluster_interconnects;

drop public synonym v$configured_interconnects;
drop view v_$configured_interconnects;
drop public synonym gv$configured_interconnects;
drop view gv_$configured_interconnects;

Rem
Rem Remove parameter views
Rem
drop public synonym v$parameter_valid_values;
drop view v_$parameter_valid_values;
drop public synonym gv$parameter_valid_values;
drop view gv_$parameter_valid_values;

Rem
Rem Remove RSRC_SESSION_INFO
Rem
drop public synonym v$rsrc_session_info;
drop view v_$rsrc_session_info;
drop public synonym gv$rsrc_session_info;
drop view gv_$rsrc_session_info;

Rem
Rem Remove BLOCKING_QUIESCE
Rem
drop public synonym v$blocking_quiesce;
drop view v_$blocking_quiesce;
drop public synonym gv$blocking_quiesce;
drop view gv_$blocking_quiesce;

Rem
Rem Remove SQLAREA_PLAN_HASH
Rem
drop public synonym v$sqlarea_plan_hash;
drop view v_$sqlarea_plan_hash;
drop public synonym gv$sqlarea_plan_hash;
drop view gv_$sqlarea_plan_hash;

Rem
Rem Remove SQLSTATS
Rem
drop public synonym v$sqlstats;
drop view v_$sqlstats;
drop public synonym gv$sqlstats;
drop view gv_$sqlstats;

Rem
Rem Logstdby views
Rem
drop public synonym v$logstdby_state;
drop view v_$logstdby_state;
drop public synonym v$logstdby_progress;
drop view v_$logstdby_progress;
drop public synonym v$logstdby_process;
drop view v_$logstdby_process;
drop public synonym v$logstdby_transaction;
drop view v_$logstdby_transaction;

drop public synonym gv$logstdby_state;
drop view gv_$logstdby_state;
drop public synonym gv$logstdby_progress;
drop view gv_$logstdby_progress;
drop public synonym gv$logstdby_process;
drop view gv_$logstdby_process;
drop public synonym gv$logstdby_transaction;
drop view gv_$logstdby_transaction;

Rem Dataguard views
Rem
drop public synonym v$dataguard_stats;
drop view v_$dataguard_stats;
drop public synonym v$standby_apply_snapshot;
drop view v_$standby_apply_snapshot;

drop public synonym gv$standby_apply_snapshot;
drop view gv_$standby_apply_snapshot;

Rem
Rem xml format audit trail view
Rem
drop public synonym v$xml_audit_trail;
drop view v_$xml_audit_trail;
drop public synonym gv$xml_audit_trail;
drop view gv_$xml_audit_trail;

Rem
Rem Process memory named-category view
Rem
drop public synonym v$process_memory;
drop view v_$process_memory;
drop public synonym gv$process_memory;
drop view gv_$process_memory;

Rem
Rem Process memory heap scan totals and progress views
Rem
drop public synonym v$process_memory_detail;
drop view v_$process_memory_detail;
drop public synonym gv$process_memory_detail;
drop view gv_$process_memory_detail;
drop public synonym v$process_memory_detail_prog;
drop view v_$process_memory_detail_prog;
drop public synonym gv$process_memory_detail_prog;
drop view gv_$process_memory_detail_prog;

Rem
Rem SQL statistics view 
Rem
DROP VIEW gv_$sqlstats;
DROP PUBLIC SYNONYM gv$sqlstats;
DROP VIEW v_$sqlstats;
DROP PUBLIC SYNONYM v$sqlstats;

Rem
Rem MUTEX view
Rem
drop public synonym v$mutex_sleep;
drop view v_$mutex_sleep;
drop public synonym gv$mutex_sleep;
drop view gv_$mutex_sleep;
drop public synonym v$mutex_sleep_history;
drop view v_$mutex_sleep_history;
drop public synonym gv$mutex_sleep_history;
drop view gv_$mutex_sleep_history;

Rem=========================================================================
Rem Drop all new ALL/DBA/USER views here
Rem=========================================================================

drop view "_ALL_SYNONYMS_FOR_SYNONYMS";
drop view "_ALL_SYNONYMS_FOR_AUTH_OBJECTS";
drop view "_ALL_SYNONYMS_TREE";

drop view V_$DB_TRANSPORTABLE_PLATFORM;
drop public synonym V$DB_TRANSPORTABLE_PLATFORM; 
drop view GV_$DB_TRANSPORTABLE_PLATFORM;
drop public synonym GV$DB_TRANSPORTABLE_PLATFORM;

Rem BEGIN drop file group views

drop view dba_file_groups;
drop view dba_file_group_versions;
drop view dba_file_group_files;
drop view dba_file_group_export_info;
drop view dba_file_group_tables;
drop view dba_file_group_tablespaces;

drop public synonym dba_file_groups;
drop public synonym dba_file_group_versions;
drop public synonym dba_file_group_files;
drop public synonym dba_file_group_export_info;
drop public synonym dba_file_group_tables;
drop public synonym dba_file_group_tablespaces;

drop view all_file_groups;
drop view all_file_group_versions;
drop view all_file_group_files;
drop view all_file_group_export_info;
drop view all_file_group_tables;
drop view all_file_group_tablespaces;

drop view "_ALL_FILE_GROUPS";
drop view "_ALL_FILE_GROUP_VERSIONS";
drop view "_ALL_FILE_GROUP_FILES";
drop view "_ALL_FILE_GROUP_EXPORT_INFO";
drop view "_ALL_FILE_GROUP_TABLES";
drop view "_ALL_FILE_GROUP_TABLESPACES";

drop public synonym all_file_groups;
drop public synonym all_file_group_versions;
drop public synonym all_file_group_files;
drop public synonym all_file_group_export_info;
drop public synonym all_file_group_tables;
drop public synonym all_file_group_tablespaces;

drop view user_file_groups;
drop view user_file_group_versions;
drop view user_file_group_files;
drop view user_file_group_export_info;
drop view user_file_group_tables;
drop view user_file_group_tablespaces;

drop view "_USER_FILE_GROUPS";

drop public synonym user_file_groups;
drop public synonym user_file_group_versions;
drop public synonym user_file_group_files;
drop public synonym user_file_group_export_info;
drop public synonym user_file_group_tables;
drop public synonym user_file_group_tablespaces;

Rem END drop file group views


Rem BEGIN drop recoverable script views

drop view DBA_RECOVERABLE_SCRIPT_PARAMS;
drop view DBA_RECOVERABLE_SCRIPT_BLOCKS;
drop view DBA_RECOVERABLE_SCRIPT_ERRORS;
drop view DBA_RECOVERABLE_SCRIPT;

Rem END drop recoverable script views


Rem BEGIN drop catalog views and synonyms for Transparent Data Encryption

drop public synonym USER_ENCRYPTED_COLUMNS;
drop view USER_ENCRYPTED_COLUMNS;
drop public synonym ALL_ENCRYPTED_COLUMNS;
drop view ALL_ENCRYPTED_COLUMNS;
drop public synonym DBA_ENCRYPTED_COLUMNS;
drop view DBA_ENCRYPTED_COLUMNS;

Rem END Transparent Data Encryption

Rem======================
Rem Begin sqltune Changes
Rem======================
update wri$_adv_sqlt_statistics set direct_writes = NULL;
    
-- 
-- in R1 the wri$_adv_sqlt_rtn_plan table had the same name as its constraint 
-- 
ALTER TABLE wri$_adv_sqlt_rtn_plan RENAME CONSTRAINT wri$_adv_sqlt_rtn_plan_pk TO wri$_adv_sqlt_rtn_plan
/

ALTER INDEX wri$_adv_sqlt_rtn_plan_pk RENAME TO wri$_adv_sqlt_rtn_plan
/

--
-- bug#5999827 - after upgrade sts could not be found
--
-- Starting in 10.2 STS names are unique per-owner, where in 10.1 they were
-- globally unique.  So we need to remove attr3 from the object in 10.1.
-- 

UPDATE wri$_adv_objects o
SET    attr3 = null
WHERE  type = 8 /* SQLSET */ and
       EXISTS (SELECT 1
               FROM   wri$_adv_tasks t
               WHERE  t.id = o.task_id and t.advisor_id = 4);

commit;


Rem======================
Rem End sqltune Changes
Rem======================
Rem drop the view so that there will be no references to dropped fixed table
drop view dba_common_audit_trail;

Rem drop view DBA_CONNECT_ROLE_GRANTEES for completeness
drop view DBA_CONNECT_ROLE_GRANTEES;
drop public synonym DBA_CONNECT_ROLE_GRANTEES;


Rem==========================
Rem DB Feature Usage Changes
Rem==========================
Rem
Rem Truncate the new DB Feature Usage (WRI$_DBU) Tables and View
Rem 
truncate table WRI$_DBU_CPU_USAGE;
truncate table WRI$_DBU_CPU_USAGE_SAMPLE;

drop view DBA_CPU_USAGE_STATISTICS;
drop public SYNONYM DBA_CPU_USAGE_STATISTICS;

Rem
Rem Drop newly created DB Feature Usage report public synonym and package
Rem
drop public synonym DBMS_FEATURE_USAGE_REPORT;
drop package DBMS_FEATURE_USAGE_REPORT;


Rem=============
Rem AWR Changes
Rem=============
-- Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

drop view DBA_HIST_INST_CACHE_TRANSFER;
drop public synonym DBA_HIST_INST_CACHE_TRANSFER;
drop view DBA_HIST_STREAMS_POOL_ADVICE;
drop public synonym DBA_HIST_STREAMS_POOL_ADVICE;
drop view DBA_HIST_COMP_IOSTAT;
drop public synonym DBA_HIST_COMP_IOSTAT;
drop view DBA_HIST_SGA_TARGET_ADVICE;
drop public synonym DBA_HIST_SGA_TARGET_ADVICE;
drop view DBA_HIST_SESS_TIME_STATS;
drop public synonym DBA_HIST_SESS_TIME_STATS;
drop view DBA_HIST_STREAMS_CAPTURE;
drop public synonym DBA_HIST_STREAMS_CAPTURE;
drop view DBA_HIST_STREAMS_APPLY_SUM;
drop public synonym DBA_HIST_STREAMS_APPLY_SUM;
drop view DBA_HIST_BUFFERED_QUEUES;
drop public synonym DBA_HIST_BUFFERED_QUEUES;
drop view DBA_HIST_BUFFERED_SUBSCRIBERS;
drop public synonym DBA_HIST_BUFFERED_SUBSCRIBERS;
drop view DBA_HIST_RULE_SET;
drop public synonym DBA_HIST_RULE_SET;
drop view DBA_HIST_PROCESS_MEM_SUMMARY;
drop public synonym DBA_HIST_PROCESS_MEM_SUMMARY;
drop view DBA_HIST_SQL_BIND_METADATA;
drop public synonym DBA_HIST_SQL_BIND_METADATA;

truncate table WRH$_INST_CACHE_TRANSFER;
truncate table WRH$_INST_CACHE_TRANSFER_BL;
truncate table WRH$_STREAMS_POOL_ADVICE;
truncate table WRH$_COMP_IOSTAT;
truncate table WRH$_SGA_TARGET_ADVICE;
truncate table WRH$_SESS_TIME_STATS;
truncate table WRH$_STREAMS_CAPTURE;
truncate table WRH$_STREAMS_APPLY_SUM;
truncate table WRH$_BUFFERED_QUEUES;
truncate table WRH$_BUFFERED_SUBSCRIBERS;
truncate table WRH$_RULE_SET;
truncate table WRH$_PROCESS_MEMORY_SUMMARY;
truncate table WRH$_SQL_BIND_METADATA;

Rem ===
Rem Drop the new dbms_ash_internal package
Rem ===
drop package dbms_ash_internal;

-- Drop these AWR report types so they will be recreated when catalog is run
drop type AWRRPT_ROW_TYPE force;
drop type AWRRPT_NUM_ARY force;
drop type AWRRPT_VCH_ARY force;
drop type AWRRPT_CLB_ARY force;
drop type AWRRPT_TEXT_TYPE_TABLE force;
drop type AWRRPT_TEXT_TYPE force;
drop type AWRRPT_HTML_TYPE_TABLE force;
drop type AWRRPT_HTML_TYPE force;
drop type AWRDRPT_TEXT_TYPE_TABLE force;
drop type AWRDRPT_TEXT_TYPE force;
drop type AWRSQRPT_TEXT_TYPE_TABLE force;
drop type AWRSQRPT_TEXT_TYPE force;

Rem
Rem Recreate tables dropped in 10gR2
Rem
create table WRH$_SQLBIND
(snap_id         NUMBER       NOT NULL
,dbid            NUMBER       NOT NULL   
,instance_number NUMBER       NOT NULL
,sql_id          VARCHAR2(13) NOT NULL
,child_number    NUMBER
,name            VARCHAR2(30)
,position        NUMBER
,dup_position    NUMBER
,datatype        NUMBER
,datatype_string VARCHAR2(15)
,character_sid   NUMBER
,precision       NUMBER
,scale           NUMBER
,max_length      NUMBER
,was_captured    VARCHAR2(3)
,last_captured   DATE
,value_string    VARCHAR2(4000)
,value_anydata   anydata
,constraint WRH$_SQLBIND_PK primary key
    (dbid, snap_id, instance_number, sql_id, position)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_SQLBIND_MXDB_MXSN values less than (MAXVALUE, MAXVALUE) 
    tablespace SYSAUX)
pctfree 1
enable row movement
/

create table WRH$_SQLBIND_BL
(snap_id         NUMBER       NOT NULL
,dbid            NUMBER       NOT NULL   
,instance_number NUMBER       NOT NULL
,sql_id          VARCHAR2(13) NOT NULL
,child_number    NUMBER
,name            VARCHAR2(30)
,position        NUMBER
,dup_position    NUMBER
,datatype        NUMBER
,datatype_string VARCHAR2(15)
,character_sid   NUMBER
,precision       NUMBER
,scale           NUMBER
,max_length      NUMBER
,was_captured    VARCHAR2(3)
,last_captured   DATE
,value_string    VARCHAR2(4000)
,value_anydata   anydata
,constraint WRH$_SQLBIND_BL_PK primary key
    (dbid, snap_id, instance_number, sql_id, position)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

create table WRH$_CLASS_CACHE_TRANSFER
(snap_id                  number          not null
,dbid                     number          not null
,instance_number          number          not null
,class                    varchar2(18)    not null
,cr_transfer              number
,current_transfer         number
,x_2_null                 number
,x_2_null_forced_write    number
,x_2_null_forced_stale    number
,x_2_s                    number
,x_2_s_forced_write       number
,s_2_null                 number
,s_2_null_forced_stale    number
,null_2_x                 number
,s_2_x                    number
,null_2_s                 number
,constraint WRH$_CLASS_CACHE_TRANSFER_PK primary key
    (snap_id, dbid, instance_number, class)
 using index local tablespace SYSAUX
) partition by range (dbid, snap_id)
  (partition WRH$_CLASS_CACH_MXDB_MXSN values less than (MAXVALUE, MAXVALUE)
    tablespace SYSAUX)
enable row movement
/

create table WRH$_CLASS_CACHE_TRANSFER_BL
(snap_id                  number          not null
,dbid                     number          not null
,instance_number          number          not null
,class                    varchar2(18)    not null
,cr_transfer              number
,current_transfer         number
,x_2_null                 number
,x_2_null_forced_write    number
,x_2_null_forced_stale    number
,x_2_s                    number
,x_2_s_forced_write       number
,s_2_null                 number
,s_2_null_forced_stale    number
,null_2_x                 number
,s_2_x                    number
,null_2_s                 number
,constraint WRH$_CLASS_CACHE_TRANS_BL_PK primary key
    (snap_id, dbid, instance_number, class)
 using index tablespace SYSAUX
) tablespace SYSAUX
/

Rem
Rem  Remove the indexes created in 10gR2
Rem  for the Metrics Tables
Rem

drop index WRH$_SYSMETRIC_HISTORY_INDEX;
drop index WRH$_SYSMETRIC_SUMMARY_INDEX;
drop index WRH$_SESSMETRIC_HISTORY_INDEX;
drop index WRH$_FILEMETRIC_HISTORY_INDEX;
drop index WRH$_WAITCLASSMETRIC_HIST_IND;

Rem
Rem  WRH$_SQLSTAT changes
Rem
-- set the new columns in WRH$_SQLSTAT to NULL
update WRH$_SQLSTAT    set PX_SERVERS_EXECS_TOTAL   = NULL;
update WRH$_SQLSTAT    set PX_SERVERS_EXECS_DELTA   = NULL;
update WRH$_SQLSTAT    set FORCE_MATCHING_SIGNATURE = NULL;
update WRH$_SQLSTAT    set PARSING_SCHEMA_NAME      = NULL;
update WRH$_SQLSTAT    set BIND_DATA                = NULL;
update WRH$_SQLSTAT    set FLAG                     = NULL;

update WRH$_SQLSTAT_BL set PX_SERVERS_EXECS_TOTAL   = NULL;
update WRH$_SQLSTAT_BL set PX_SERVERS_EXECS_DELTA   = NULL;
update WRH$_SQLSTAT_BL set FORCE_MATCHING_SIGNATURE = NULL;
update WRH$_SQLSTAT_BL set PARSING_SCHEMA_NAME      = NULL;
update WRH$_SQLSTAT_BL set BIND_DATA                = NULL;
update WRH$_SQLSTAT_BL set FLAG                     = NULL;
commit;

Rem
Rem  WRH$_SEG_STAT changes
Rem
-- set the new column values to NULL
update WRH$_SEG_STAT    set GC_BUFFER_BUSY_TOTAL = NULL;
update WRH$_SEG_STAT    set GC_BUFFER_BUSY_DELTA = NULL;
update WRH$_SEG_STAT    set CHAIN_ROW_EXCESS_TOTAL = null;
update WRH$_SEG_STAT    set CHAIN_ROW_EXCESS_DELTA = null;

update WRH$_SEG_STAT_BL set GC_BUFFER_BUSY_TOTAL = NULL;
update WRH$_SEG_STAT_BL set GC_BUFFER_BUSY_DELTA = NULL;
update WRH$_SEG_STAT_BL set CHAIN_ROW_EXCESS_DELTA = null;
update WRH$_SEG_STAT_BL set CHAIN_ROW_EXCESS_TOTAL = null;
commit;

-- rename columns to previous values
alter table WRH$_SEG_STAT
  rename column GC_CR_BLOCKS_RECEIVED_TOTAL to GC_CR_BLOCKS_SERVED_TOTAL;
alter table WRH$_SEG_STAT
  rename column GC_CR_BLOCKS_RECEIVED_DELTA to GC_CR_BLOCKS_SERVED_DELTA;
alter table WRH$_SEG_STAT
  rename column GC_CU_BLOCKS_RECEIVED_TOTAL to GC_CU_BLOCKS_SERVED_TOTAL;
alter table WRH$_SEG_STAT
  rename column GC_CU_BLOCKS_RECEIVED_DELTA to GC_CU_BLOCKS_SERVED_DELTA;

alter table WRH$_SEG_STAT_BL
  rename column GC_CR_BLOCKS_RECEIVED_TOTAL to GC_CR_BLOCKS_SERVED_TOTAL;
alter table WRH$_SEG_STAT_BL
  rename column GC_CR_BLOCKS_RECEIVED_DELTA to GC_CR_BLOCKS_SERVED_DELTA;
alter table WRH$_SEG_STAT_BL
  rename column GC_CU_BLOCKS_RECEIVED_TOTAL to GC_CU_BLOCKS_SERVED_TOTAL;
alter table WRH$_SEG_STAT_BL
  rename column GC_CU_BLOCKS_RECEIVED_DELTA to GC_CU_BLOCKS_SERVED_DELTA;

Rem
Rem  WRH$_SEG_STAT_OBJ changes
Rem
Rem  Set new columns in WRH$_SEG_STAT_OBJ to NULL
update WRH$_SEG_STAT_OBJ
   set index_type = NULL,
       base_obj# = NULL,
       base_object_name  = NULL,
       base_object_owner = NULL;

Rem
Rem  WRH$_SQL_PLAN changes
Rem
-- clear new other_xml column in wrh$_sql_plan
update sys.wrh$_sql_plan
  set other_xml = null;
commit;

update sys.wrh$_sql_plan
  set timestamp = null;
commit;

Rem 
Rem  WRH$_UNDOSTAT changes
Rem 
update WRH$_UNDOSTAT set status = 0;
update WRH$_UNDOSTAT set spcprs_retention = 0;
update WRH$_UNDOSTAT set runawayquerysqlid = NULL;
commit;

Rem 
Rem  WRH$_EVENT_NAME changes
Rem 
update WRH$_EVENT_NAME set PARAMETER1 = NULL;
update WRH$_EVENT_NAME set PARAMETER2 = NULL;
update WRH$_EVENT_NAME set PARAMETER3 = NULL;
commit;

Rem 
Rem  WRH$_ACTIVE_SESSION_HISTORY changes 
Rem    - NULL out the 10gR2 new columns in ASH
Rem 
update WRH$_ACTIVE_SESSION_HISTORY    
   set force_matching_signature  = NULL,
       blocking_session          = NULL,
       blocking_session_serial#  = NULL,
       xid                       = NULL;

update WRH$_ACTIVE_SESSION_HISTORY_BL 
   set force_matching_signature  = NULL,
       blocking_session          = NULL,
       blocking_session_serial#  = NULL,
       xid                       = NULL;
commit;

Rem
Rem  WRM$_WR_CONTROL changes 
Rem    - Set the new Top N SQL column to NULL
Rem
update WRM$_WR_CONTROL set TOPNSQL = NULL;
commit;

Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==          (10gR1 = SWRF Version 1)                 ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  downgrade changes.  Place all other AWR          ==
Rem ==  downgrade changes above this.                    ==
Rem =======================================================

BEGIN
  UPDATE wrm$_wr_control SET swrf_version = 1;
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

-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';


Rem 
Rem BEGIN of dropping STREAMS views
Rem 

drop public synonym DBA_STREAMS_TRANSFORMATIONS;
drop view DBA_STREAMS_TRANSFORMATIONS;

drop public synonym DBA_STREAMS_DELETE_COLUMN;
drop view DBA_STREAMS_DELETE_COLUMN;

drop public synonym DBA_STREAMS_RENAME_COLUMN;
drop view DBA_STREAMS_RENAME_COLUMN;

drop public synonym DBA_STREAMS_ADD_COLUMN;
drop view DBA_STREAMS_ADD_COLUMN;

drop public synonym DBA_STREAMS_RENAME_TABLE;
drop view DBA_STREAMS_RENAME_TABLE;

drop public synonym DBA_STREAMS_RENAME_SCHEMA;
drop view DBA_STREAMS_RENAME_SCHEMA;

DROP VIEW "_DBA_STREAMS_TRANSFORMATIONS";

DROP VIEW "_DBA_STREAMS_TRANSFM_FUNCTION";

DROP VIEW "_DBA_STREAMS_NEWLY_SUPTED_10_2";

drop public synonym DBA_APPLY_VALUE_DEPENDENCIES;
drop public synonym DBA_APPLY_OBJECT_DEPENDENCIES;

Rem
Rem END of dropping STREAMS views
Rem 

Rem Drop change Notification Views
drop public synonym DBA_CHANGE_NOTIFICATION_REGS;
drop view DBA_CHANGE_NOTIFICATION_REGS;

drop public synonym USER_CHANGE_NOTIFICATION_REGS;
drop view USER_CHANGE_NOTIFICATION_REGS;

Rem ===
Rem NULL out the 10gR2 new columns in ASH
Rem ===
update WRH$_ACTIVE_SESSION_HISTORY    
   set blocking_session = NULL,
       xid = NULL;
update WRH$_ACTIVE_SESSION_HISTORY_BL 
   set blocking_session = NULL,
       xid = NULL;
commit;

Rem Drop TSM user 
DROP USER TSMSYS CASCADE;

Rem=========================================================================
Rem Drop all new types here
Rem=========================================================================

Rem
Rem BEGIN of dropping STREAMS types
Rem 

-- The following type must be conditionally dropped because it will
-- invalidate dbms_streams_adm, which e0902000.sql relies upon.  Thus
-- if the version we upgraded from is 9.2, do not drop this type
DECLARE
  previous_version  varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$ 
  WHERE cid = 'CATPROC';

  IF previous_version NOT LIKE '9.2.0%' THEN
    execute immediate 'drop type sys.streams$transformation_info force'; 
  END IF;
END;
/

DROP TYPE streams$_anydata_array FORCE
/

Rem
Rem END of dropping STREAMS types
Rem 

-- Drop MV refresh index rebuild types
DROP TYPE SYS.IndexRebuildList FORCE;
DROP TYPE SYS.IndexRebuildRecord FORCE;

Rem
Rem Rules changes
Rem
drop type sys.re$rule_list force
/

Rem 
Rem  AQ changes
Rem
ALTER TYPE sys.aq$_reg_info DROP CONSTRUCTOR FUNCTION aq$_reg_info(
  name             VARCHAR2,
  namespace        NUMBER,
  callback         VARCHAR2,
  context          RAW,
  qosflags         NUMBER,
  timeout          NUMBER)
  RETURN SELF AS RESULT CASCADE
/
ALTER TYPE sys.aq$_reg_info DROP CONSTRUCTOR FUNCTION aq$_reg_info(
  name             VARCHAR2,
  namespace        NUMBER,
  callback         VARCHAR2,
  context          RAW,
  anyctx           SYS.ANYDATA,
  ctxtype          NUMBER)
  RETURN SELF AS RESULT CASCADE
/
ALTER TYPE sys.aq$_reg_info
DROP ATTRIBUTE (qosflags, payloadcbk, timeout) CASCADE
/

-- drop attribute from sys.aq$_descriptor and then drop the type
ALTER TYPE sys.aq$_descriptor
  DROP ATTRIBUTE(gen_desc) CASCADE
/
DROP TYPE sys.aq$_ntfn_descriptor force;

ALTER TYPE sys.msg_prop_t DROP ATTRIBUTE (delivery_mode) CASCADE
/

ALTER TYPE sys.aq$_srvntfn_message 
DROP ATTRIBUTE (delivery_mode, ntfn_flags) CASCADE
/

Rem Avoid ORA-04068 for DBMS_AQADM_SYS
execute DBMS_SESSION.RESET_PACKAGE; 

-- Drop change notification types;
DROP TYPE sys.chnf$_reg_info_oc4j FORCE;
DROP TYPE sys.chnf$_reg_info FORCE;
DROP TYPE chnf$_desc FORCE;
DROP TYPE chnf$_tdesc_array FORCE;
DROP TYPE chnf$_tdesc FORCE;
DROP TYPE chnf$_rdesc_array FORCE;
DROP TYPE chnf$_rdesc FORCE;

Rem=========================================================================
Rem ALTER types to drop 10.2 attributes, methods here
Rem=========================================================================

Rem
Rem Alter types and associated functions related to lcr$_{row,ddl}_record
Rem

ALTER TYPE lcr$_row_record DROP MEMBER FUNCTION
   get_source_time RETURN DATE CASCADE;

ALTER TYPE lcr$_ddl_record DROP MEMBER FUNCTION
   get_source_time RETURN DATE CASCADE;

Rem=========================================================================
Rem Drop all new packages here
Rem=========================================================================

Rem Drop dbms_errlog package
drop package sys.dbms_errlog;
drop public synonym dbms_errlog;
  
Rem Drop utl_nla package
drop library sys.utl_mat_lib;
drop package sys.utl_nla;
drop type SYS.UTL_NLA_ARRAY_DBL;
drop type SYS.UTL_NLA_ARRAY_FLT;
drop type SYS.UTL_NLA_ARRAY_INT;

Rem
Rem Drop dbms_tsm package
Rem
drop library sys.dbms_tsm_lib;
drop package sys.dbms_tsm;
drop package sys.dbms_tsm_prvt;

Rem
Rem Drop dbms_extended_tts_checks_lib 
Rem
drop library sys.dbms_extended_tts_checks_lib;

Rem Drop dbms_space (reference to new fixed table)
drop package dbms_space;

Rem
Rem Drop tde_crypto_tookit_library
Rem
drop library tde_library;
drop package dbms_tde_toolkit;
drop package dbms_tde_toolkit_ffi;
drop public synonym dbms_tde_toolkit;

Rem Drop dbms_sqlhash package
drop package sys.dbms_sqlhash;
drop public synonym dbms_sqlhash;

Rem Drop dbms_sqlplus_script package
drop library sys.dbms_sqlplus_script_lib;
drop package sys.dbms_sqlplus_script;
drop public synonym dbms_sqlplus_script;

Rem ========================================================================
Rem Downgrade PL/SQL compiler parameters
Rem ========================================================================

DELETE FROM settings$ WHERE param IN ('plsql_ccflags');
commit;

REm ==============================================================
REm Drop dblink stuff - project 5523
REm =============================================================


DROP VIEW exu10lnku;
DROP VIEW exu10lnk;

Rem Drop dbms_dblink 
drop  library  sys.dbms_dblink_lib;
drop  package  sys.dbms_dblink;

REM ===============================================
REM End dblink
REM ===============================================

DROP LIBRARY dbms_file_group_lib;
DROP PACKAGE dbms_file_group;
DROP PUBLIC SYNONYM dbms_file_group;
DROP PACKAGE dbms_file_group_utl;
DROP PACKAGE dbms_file_group_utl_invok;
DROP PACKAGE dbms_file_group_internal_invok;
DROP PACKAGE dbms_file_group_decl;
DROP PACKAGE dbms_file_group_exp;
DROP PACKAGE dbms_file_group_exp_internal;
DROP PACKAGE dbms_file_group_imp;
DROP PACKAGE dbms_file_group_imp_internal;

-- drop file group sequence
DROP SEQUENCE fgr$_names_s;

Rem END dropping file group packages

Rem BEGIN dropping recoverable scripts packages

DROP PACKAGE dbms_reco_script_int;
DROP PACKAGE dbms_reco_script_invok;
DROP PACKAGE dbms_recoverable_script;

Rem END dropping recoverable scripts packages

Rem BEGIN dropping commit-time queue packages

DROP PACKAGE dbms_aq_exp_cmt_time_tables;
DROP PUBLIC SYNONYM dbms_aq_exp_cmt_time_tables;

Rem END dropping commit-time queue packages

Rem drop dbms_tdb package 
DROP PACKAGE dbms_tdb;

Rem drop server alerts private package and library
DROP PACKAGE dbms_server_alert_prvt;
DROP LIBRARY dbms_svralrt_prvt_lib;

Rem drop dbms_ha_alerts packages and library
DROP PACKAGE dbms_ha_alerts;
DROP PACKAGE dbms_ha_alerts_prvt;
DROP LIBRARY dbms_ha_alert_lib;

Rem BEGIN drop ha event notification objects

DROP LIBRARY dbms_haeventnot_prvt_lib;
DROP FUNCTION haen_txfm_text;

Rem END drop ha event notification objects


-- drop DBMS_APPLY_USER_AGENT
-- note this is an internal package no synonym
DROP PACKAGE DBMS_APPLY_USER_AGENT;

Rem drop dbms_change_notification
DROP PACKAGE dbms_change_notification;
DROP PUBLIC SYNONYM dbms_change_notification;

Rem=========================================================================
Rem Revert 10.2 changes to SYSTEM dictionary tables here
Rem=========================================================================

Rem
Rem Logminer Downgrade
Rem

Rem Update session attributes for logical standby sessions.
update system.logmnr_session$
  set session_attr = session_attr - 4
  where client# = 2
    and bitand(session_attr, 4) = 4;

commit;

drop table system.logmnr_parameter$ purge;

Rem --------------------------
Rem  Begin STS schema changes
Rem --------------------------

--
-- Change back to our old SQL tuning set schema.  This is done in two steps:
--  1. Rebuild the R1 format of the  _statements and _binds tables from their
--     R2 equivalents. We convert from parsing schema names back to IDs along 
--     the way, and then drop the R2 tables
--  2. Normilze sql tuning set names
--  3. Drop sql tuning set types 
--  4. Drop the old _plans, _mask, and _statistics tables
--  5. Drop the old sequences
--  6. drop all new sql tuning set synonyms and views 
--  7. Drop statements, binds views (they are invalid now)
--  8. drop the table and index created for sqlset workspace   
--

Rem ===========================================================
Rem 1. Rebuild R1 versions of the _statements and _binds tables
Rem ===========================================================
-- We will rename these tables and indexes/constraints when we're done
create table wri$_sqlset_statements_tmp 
(
  sqlset_id          NUMBER       NOT NULL, 
  sql_id             VARCHAR(13)  NOT NULL,
  parsing_schema_id  NUMBER,  
  module             VARCHAR2(48),
  action             VARCHAR2(32),
  elapsed_time       NUMBER,
  cpu_time           NUMBER, 
  buffer_gets        NUMBER, 
  disk_reads         NUMBER,  
  rows_processed     NUMBER, 
  fetches            NUMBER,
  executions         NUMBER, 
  end_of_fetch_count NUMBER,
  optimizer_cost     NUMBER,
  optimizer_env      RAW(1000),  
  priority           NUMBER,
  command_type       NUMBER,
  stat_period        NUMBER, 
  active_stat_period NUMBER,
  constraint wri$_sqlset_statements_tmp_pk primary key (sqlset_id, sql_id)
  using INDEX tablespace SYSAUX
) 
tablespace SYSAUX
/

create table wri$_sqlset_binds_tmp 
(
  sqlset_id  NUMBER      NOT NULL, 
  sql_id     VARCHAR(13) NOT NULL,
  position   NUMBER      NOT NULL, 
  VALUE      ANYDATA,
  constraint wri$_sqlset_binds_tmp_pk primary key (sqlset_id, sql_id, position)
  using INDEX tablespace SYSAUX          
) 
tablespace SYSAUX
/

-- 
-- A. Copy the binds We do the actual merge/copy in a PL/SQL block to 
--    avoid doing it twice. Notice please that if we fail in the following
--    block (probably because of errors in the dbms_sqltune package after 
--    invalidating it by for example dropping one of the tables or views it 
--    is using) the binds (i.e., bind_data) will not be converted. This is
--    a worse case where sql tuning sets will be downgraded without any bind
--    information.
-- 
DECLARE
  already_r1 NUMBER;
BEGIN
  already_r1 := 0;  

  -- Migration already done? Check to see if binds table still has old
  -- sql_id column.
  select DECODE(count(*),
                0, 0,
                1)
  into   already_r1
  from   dba_tab_columns
  where  owner = 'SYS' and table_name = 'WRI$_SQLSET_BINDS' and
         column_name = 'SQL_ID';

  IF (already_r1 = 0) THEN
    -- Move the binds from _binds to _binds_tmp
    -- We just take the binds from one hash value
    -- 1. move bind_data first
    --    DO NOT ADD APPEND hint to the two following queries otherwise you
    --    will get error ORA-12838.
    EXECUTE IMMEDIATE
      'INSERT INTO wri$_sqlset_binds_tmp '                                    ||
      'SELECT stmt.sqlset_id sqlset_id, stmt.sql_id sql_id, '                 ||
      '       b.position position, b.value_anydata as value '                 ||
      'FROM   wri$_sqlset_statements stmt, '                                  ||
      '       wri$_sqlset_plans p, '                                          ||
      '       TABLE(dbms_sqltune_util0.extract_binds(p.bind_data)) b '        ||
      'WHERE  stmt.id = p.stmt_id AND p.bind_data IS NOT NULL AND '           ||
      '       p.plan_hash_value = '                                           ||
      '         (SELECT min(plan_hash_value) '                                ||
      '          FROM   wri$_sqlset_plans p_2 '                               ||
      '          WHERE  p.stmt_id = p_2.stmt_id) ';   

    -- 2. move the user sepecified binds for the reset of statements if any
    EXECUTE IMMEDIATE
      'INSERT INTO wri$_sqlset_binds_tmp '                                    ||
      'SELECT s.sqlset_id sqlset_id, s.sql_id sql_id, '                       ||
      '       b_1.position position, b_1.value value '                        ||
      'FROM   wri$_sqlset_statements s, wri$_sqlset_binds b_1 '               ||
      'WHERE  s.id = b_1.stmt_id AND '                                        ||
      '       b_1.plan_hash_value = '                                         ||
      '         (SELECT min(plan_hash_value) '                                ||
      '          FROM   wri$_sqlset_binds b_2 '                               ||
      '          WHERE  b_1.stmt_id = b_2.stmt_id) AND '                      ||
      '       NOT EXISTS ( '                                                  ||
      '         SELECT 1 '                                                    ||
      '         FROM   wri$_sqlset_binds_tmp t '                              ||
      '         WHERE  t.sqlset_id = s.sqlset_id and s.sql_id = t.sql_id)';
    COMMIT;

  END IF;

END;
/

--
-- b. Copy statements and stats. We do the actual merge/copy in a PL/SQL block 
--    to avoid doing it twice
--
DECLARE
  already_r1 NUMBER;
BEGIN
  already_r1 := 0;  

  -- Migration already done? Check to see if statements table still has old
  -- buffer_gets column.
  select DECODE(count(*),
                0, 0,
                1)
  into   already_r1
  from   dba_tab_columns
  where  owner = 'SYS' and table_name = 'WRI$_SQLSET_STATEMENTS' and
         column_name = 'BUFFER_GETS';

  IF (already_r1 = 1) THEN
    -- Migration is done.  Drop the temp tables we just created and continue
    EXECUTE IMMEDIATE 'DROP TABLE WRI$_SQLSET_STATEMENTS_TMP';
    EXECUTE IMMEDIATE 'DROP TABLE WRI$_SQLSET_BINDS_TMP';
  ELSE
    -- Merge the _statistics, _plans, _statements, and _mask tables into the
    -- _statements_tmp table.  We sum statistics over all their plans.
    -- 
    -- Note that we do an outer join in the DBA_USERS view so that if a
    -- statement has a parsing schema name that does not join it will still
    -- get a row in the R1 version of the table
    EXECUTE IMMEDIATE
      'INSERT /*+ APPEND */ INTO wri$_sqlset_statements_tmp '                 ||
      'SELECT stmt.sqlset_id sqlset_id, stmt.sql_id sql_id, '                 ||
      '       min(u.user_id) parsing_schema_id, min(stmt.module) module, '    ||
      '       min(stmt.action) action, sum(stats.elapsed_time) elapsed_time, '||
      '       sum(stats.cpu_time) cpu_time, '                                 ||
      '       sum(stats.buffer_gets) buffer_gets, '                           ||
      '       sum(stats.disk_reads) disk_reads, '                             ||
      '       sum(stats.rows_processed) rows_processed, '                     ||
      '       sum(stats.fetches) fetches, sum(stats.executions) executions, ' ||
      '       sum(stats.end_of_fetch_count) end_of_fetch_count, '             ||
      '       sum(stats.optimizer_cost) optimizer_cost, '                     ||
      '       min(plans.optimizer_env) optimizer_env, '                       ||
      '       min(mask.priority) priority, '                                  ||
      '       min(stmt.command_type) command_type, '                          ||
      '       min(stats.stat_period) stat_period, '                           ||
      '       min(stats.active_stat_period) active_stat_period '              ||
      'FROM   wri$_sqlset_statements stmt, wri$_sqlset_statistics stats, '    ||
      '       wri$_sqlset_mask mask, wri$_sqlset_plans plans, dba_users u '   ||
      'WHERE  stmt.id = stats.stmt_id and stmt.id = mask.stmt_id and '        ||
      '       stmt.id = plans.stmt_id and '                                   ||
      '       plans.plan_hash_value = stats.plan_hash_value and '             ||
      '       plans.plan_hash_value = mask.plan_hash_value and '              ||
      '       u.username (+) = stmt.parsing_schema_name  '                    ||
      'GROUP BY stmt.sqlset_id, stmt.sql_id'; 

    COMMIT;

    -- Drop the R2 _statements and _binds tables
    EXECUTE IMMEDIATE 'DROP TABLE wri$_sqlset_statements';
    EXECUTE IMMEDIATE 'DROP TABLE wri$_sqlset_binds';

    -- Rename _statements_tmp and _binds_tmp tables and constraints
    EXECUTE IMMEDIATE 'ALTER TABLE wri$_sqlset_statements_tmp RENAME TO '    ||
                      'wri$_sqlset_statements';
    EXECUTE IMMEDIATE 'ALTER TABLE wri$_sqlset_statements RENAME '           ||
                      'CONSTRAINT wri$_sqlset_statements_tmp_pk TO '         ||
                      'wri$_sqlset_statements_pk';
    EXECUTE IMMEDIATE 'ALTER INDEX wri$_sqlset_statements_tmp_pk RENAME TO ' ||
                      'wri$_sqlset_statements_pk';
    -- Binds table
    EXECUTE IMMEDIATE 'ALTER TABLE wri$_sqlset_binds_tmp RENAME TO '         ||
                      'wri$_sqlset_binds';
    EXECUTE IMMEDIATE 'ALTER TABLE wri$_sqlset_binds RENAME '                ||
                      'CONSTRAINT wri$_sqlset_binds_tmp_pk TO '              ||
                      'wri$_sqlset_binds_pk';
    EXECUTE IMMEDIATE 'ALTER INDEX wri$_sqlset_binds_tmp_pk RENAME TO '      ||
                      'wri$_sqlset_binds_pk';

  END IF;

END;
/

Rem =====================================================================
Rem 2. Normalize sql tuning set names 
Rem    in R2, wri$_sqlset_definitions stores owner names case-sensitively
Rem    re-set all names to be stored case-insenstively
Rem =====================================================================
BEGIN
  EXECUTE IMMEDIATE 'update wri$_sqlset_definitions set owner = upper(owner)';
EXCEPTION
   WHEN OTHERS THEN
     IF (SQLCODE = -942) THEN
       NULL;
     ELSE
       RAISE;
     END IF;
END;
/

-- in R2 sql tuning sets are unique by (name,owner) but in R1 they are just
-- unique by (name)
-- New index will be created in the catproc

drop index wri$_sqlset_definitions_idx_01
/

-- Patch names of SQL tuning sets
-- If in R2 two STS had the same name, in R1 they must have different names
DECLARE
  -- all sts names we have to rename
  CURSOR r2_names IS
    select name, owner from wri$_sqlset_definitions ds 
    where  (select count(*) from wri$_sqlset_definitions ds2
            where ds2.name = ds.name) > 1;

  cnt       NUMBER;
  postfix   NUMBER;
  new_name  VARCHAR2(30);
  old_name  VARCHAR2(30);
  old_owner VARCHAR2(30);
BEGIN

  FOR name_rec IN r2_names LOOP
    old_name  := name_rec.name;
    old_owner := name_rec.owner;
    new_name  := SUBSTRB(name_rec.name,1,9) || '_' || 
                 SUBSTRB(name_rec.owner,1,9);
    postfix := 0;
    
    -- Try several possibilities for remapping name
    LOOP
      SELECT count(*) INTO cnt 
      FROM   wri$_sqlset_definitions 
      WHERE  name = new_name;

      EXIT WHEN (cnt = 0);
      postfix  := postfix + 1;
      new_name := SUBSTRB(name_rec.name,1,9) || '_' || 
                  SUBSTRB(name_rec.owner,1,9)  || '_' || postfix;
    END LOOP;

    UPDATE wri$_sqlset_definitions
    SET    name = new_name
    WHERE  name = old_name AND
           owner = old_owner;

  END LOOP;

  commit;
END;
/

Rem ===========================================================
Rem 3. SQL Tuning Set type changes
Rem Notice that sql tuning set are droped in this place 
Rem        Instead of the type change type section beacause
Rem        we need these types do downgrade the bind values 
Rem        bind_data (RAW) into bind_list (list of bind values)
Rem ===========================================================
-- We now store plans in the SQL tuning set, which means they are also
-- in the SQLSET_ROW.  We drop the type here and recreate it later in catsqlt.

DROP TYPE sqlset_row FORCE
/
DROP TYPE sqlset FORCE
/
DROP PUBLIC SYNONYM sqlset_row
/
DROP PUBLIC SYNONYM sqlset
/

-- sqltune/sqlset new bind (single and set) types
DROP TYPE sql_bind_set 
/
DROP PUBLIC SYNONYM sql_bind_set
/
DROP TYPE sql_bind
/
DROP PUBLIC SYNONYM sql_bind
/  

-- 
-- Plan types
--   NOTE: sql_plan_allstat_row_type is new to 11g.  We drop it here because
--         for downgrades from 11g->10g and beyond, we could not drop it in
--         e1002000 for fear of invalidating dbms_sqltune
-- 
DROP TYPE sql_plan_table_type FORCE
/
DROP PUBLIC SYNONYM sql_plan_table_type
/
DROP TYPE sql_plan_stat_row_type FORCE
/
DROP PUBLIC SYNONYM sql_plan_stat_row_type
/
DROP TYPE sql_plan_allstat_row_type FORCE
/
DROP PUBLIC SYNONYM sql_plan_allstat_row_type
/
DROP TYPE sql_plan_row_type FORCE
/
DROP PUBLIC SYNONYM sql_plan_row_type
/

Rem =================================================
Rem 4. Drop the _plan_, _mask, and _statistics tables
Rem =================================================
DROP TABLE wri$_sqlset_plan_lines
/
DROP TABLE wri$_sqlset_plans
/
DROP TABLE wri$_sqlset_mask
/
DROP TABLE wri$_sqlset_statistics
/

Rem =================
Rem 5. drop sequences
Rem =================

DROP SEQUENCE wri$_sqlset_stmt_id_seq
/

Rem =================================================
Rem 6. drop all new sql tuning set synonyms and views 
Rem =================================================

drop public synonym dba_sqlset_plans;

drop public synonym user_sqlset_plans;

drop public synonym all_sqlset;
drop public synonym all_sqlset_statements;
drop public synonym all_sqlset_references;
drop public synonym all_sqlset_binds;
drop public synonym all_sqlset_plans;

drop public synonym "_ALL_SQLSET_STATEMENTS_ONLY";
drop public synonym "_ALL_SQLSET_STATEMENTS_PHV";

drop view dba_sqlset_plans;

drop view user_sqlset_plans;

drop view all_sqlset;
drop view all_sqlset_statements;
drop view all_sqlset_references;
drop view all_sqlset_binds;
drop view all_sqlset_plans;

drop view "_ALL_SQLSET_STATEMENTS_ONLY";
drop view "_ALL_SQLSET_STATEMENTS_PHV";
drop view "_ALL_SQLSET_STATISTICS_ONLY";

Rem ======================================================
Rem 7. Drop statements, binds views (they are invalid now)
Rem=======================================================
drop public synonym user_sqlset_statements;
drop public synonym user_sqlset_binds;
drop public synonym dba_sqlset_statements;
drop public synonym dba_sqlset_binds;

DROP VIEW dba_sqlset_binds
/
DROP VIEW user_sqlset_binds
/
DROP VIEW dba_sqlset_statements
/
DROP VIEW user_sqlset_binds
/
DROP VIEW user_sqlset_statements
/

Rem ========================================================
Rem 8. drop the table and index created for sqlset workspace   
Rem ========================================================
DROP TABLE wri$_sqlset_workspace
/

Rem ========================================================
Rem 9. drop the temp table we use in capture
Rem ========================================================
DROP TABLE wri$_sqlset_plans_tocap
/

Rem --------------------------
Rem  End STS schema changes
Rem --------------------------

Rem --------------------------
Rem  Begin Outline  changes
Rem --------------------------

revoke create session from outln;
grant connect to outln;


Rem ==================================================
Rem drop the dbms_sqltune_util0. This is needed only if we are downgrading 
Rem from an 11g release or higher. The following command should fail is we 
Rem are downgrading directly from 10gR2 to 10gR1 because the package is 
Rem created in 11g. 
Rem ==================================================
DROP PACKAGE DBMS_SQLTUNE_UTIL0;

Rem --------------------------
Rem  End Outline changes
Rem --------------------------

begin
  execute immediate 'drop index system.logstdby$events_ind';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/
 -- change the datatype of date column in logstdby$events
alter table system.logstdby$events modify (event_time date);
 --  nullify new columns in logstdby$apply_milestone
update system.logstdby$apply_milestone 
     set commit_time = NULL;
update system.logstdby$apply_milestone 
     set  processed_time = NULL;
 -- nullify new column in logstdby$apply_progress
update system.logstdby$apply_progress 
     set commit_time = NULL;
commit;

Rem=========================================================================
Rem downgrade rules engine objects
Rem=========================================================================
update rule$ set uactx_client = NULL;
commit;


Rem=========================================================================
Rem Begin Scheduler Downgrade
Rem=========================================================================

drop type scheduler$_event_info;

drop sequence sys.scheduler$_evtseq;

Rem NULL out the two new columns of the global attribute table

update sys.scheduler$_global_attribute 
set attr_tstamp = NULL, attr_intv = NULL;

-- Drop new 10gR2 Scheduler types. Dropping these types will invalidate
-- DBMS_SCHEDULER so for downgrade to 9.2 do them later. Also do not call
-- dbms_scheduler after this.
DECLARE
  previous_version  varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$ 
  WHERE cid = 'CATPROC';

  IF previous_version NOT LIKE '9.2.0%' THEN
    EXECUTE IMMEDIATE 'DROP TYPE sys.scheduler$_int_array_type FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE sys.scheduler$_chain_link_list FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE sys.scheduler$_chain_link FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE sys.scheduler$_step_type_list FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE sys.scheduler$_step_type FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE sys.scheduler$_rule_list FORCE';
    EXECUTE IMMEDIATE 'DROP TYPE sys.scheduler$_rule FORCE';
    -- this type has changed in 10gR2, drop it so catsch.sql will recreate it
    EXECUTE IMMEDIATE 'DROP TYPE sys.scheduler$_job_step_type FORCE';
    EXECUTE IMMEDIATE 'DROP VIEW dba_scheduler_chains';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM dba_scheduler_chains';
    EXECUTE IMMEDIATE 'DROP VIEW user_scheduler_chains';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM user_scheduler_chains';
    EXECUTE IMMEDIATE 'DROP VIEW all_scheduler_chains';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM all_scheduler_chains';
    EXECUTE IMMEDIATE 'DROP VIEW dba_scheduler_chain_rules';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM dba_scheduler_chain_rules';
    EXECUTE IMMEDIATE 'DROP VIEW user_scheduler_chain_rules';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM user_scheduler_chain_rules';
    EXECUTE IMMEDIATE 'DROP VIEW all_scheduler_chain_rules';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM all_scheduler_chain_rules';
    EXECUTE IMMEDIATE 'DROP VIEW dba_scheduler_chain_steps';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM dba_scheduler_chain_steps';
    EXECUTE IMMEDIATE 'DROP VIEW user_scheduler_chain_steps';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM user_scheduler_chain_steps';
    EXECUTE IMMEDIATE 'DROP VIEW all_scheduler_chain_steps';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM all_scheduler_chain_steps';
    EXECUTE IMMEDIATE 'DROP VIEW dba_scheduler_running_chains';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM dba_scheduler_running_chains';
    EXECUTE IMMEDIATE 'DROP VIEW user_scheduler_running_chains';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM user_scheduler_running_chains';
    EXECUTE IMMEDIATE 'DROP VIEW all_scheduler_running_chains';
    EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM all_scheduler_running_chains';

  END IF;
END;
/

-- Job run details table column cpu_used datatype changed in 10R2 from number
-- to interval day second. Here we change it back to number.
-- Note this is an exception to our backward compatibillity policies

update scheduler$_job_run_details set cpu_used = null;
commit;
-- modifed in execute immediate later in script

-- remove chains export support
DROP PACKAGE dbms_sched_chain_export;
DROP PUBLIC SYNONYM dbms_sched_chain_export;

-- create tables no longer created in 10gR2
CREATE TABLE sys.scheduler$_job_chain
(
  obj#            number              NOT NULL       /* job chain identifier */
                  CONSTRAINT scheduler$_job_chain_pk PRIMARY KEY,
  rule_set        varchar2(30),            /* rule set assoc with this chain */
  rule_set_owner  varchar2(30),                    /* schema of the rule set */
  comments        varchar2(240),                        /* schedule comments */
  flags           number                                    /* schedule type */
)
/

CREATE TABLE sys.scheduler$_chain_varlist
(
  oid             number              NOT NULL,      /* job chain identifier */
  var_name        varchar2(30)        NOT NULL,            /* job identifier */
  program_name    varchar2(98)        NOT NULL
)
/
CREATE INDEX sys.i_scheduler_chain_varlist1
  ON sys.scheduler$_chain_varlist (oid)
/

CREATE TABLE sys.scheduler$_job_step_state
(
  job_name        varchar2(100)       NOT NULL
                  CONSTRAINT scheduler$_job_step_state_pk PRIMARY KEY
                   USING INDEX TABLESPACE sysaux,
  status          char,
  error_code      number
) TABLESPACE sysaux
/
grant select on sys.scheduler$_job_step_state to public with grant option;

CREATE TABLE sys.scheduler$_job_step
(
   master_job_oid    number       NOT NULL,
   variable_name     varchar2(30) NOT NULL,
                  CONSTRAINT scheduler$_job_step_pk
                  PRIMARY KEY (master_job_oid, variable_name),
   job_step_oid      number       NOT NULL
)
/

Rem These are types we added for 11g. If we were downgrading from  11g
Rem to 10.1, we could not drop them in the 10.2 downgrade script since
Rem that would invalidate dbms_scheduler. So, we wait till the downgrade
Rem to 10.1 is done and then drop the types. 

drop type body sys.scheduler$_batcherr_view_t;
drop type body sys.jobattr;
drop type body sys.job;
drop type body sys.job_definition;
drop type body sys.jobarg;

drop type sys.scheduler$_batcherr_array force;
drop type sys.jobattr_array force;
drop type sys.job_array force;
drop type sys.job_definition_array force;
drop type sys.jobarg_array force;

drop type sys.scheduler$_batcherr_view_t force;
drop type sys.jobattr force;
drop type sys.job force;
drop type sys.job_definition force;
drop type sys.jobarg force;
drop type sys.scheduler$_batcherr force;

drop package sys.dbms_isched_remdb_job;

Rem The new internal dbms_isched_chain_condition package is dropped lower down
Rem in a PL/SQL conditional block.

Rem=========================================================================
Rem End Scheduler Downgrade
Rem=========================================================================


Rem=========================================================================
Rem Revert 10.2 changes to sql.bsq dictionary tables here
Rem=========================================================================

Rem
Rem Delete TSM table rows
Rem
truncate table tsm_src$; 
truncate table tsm_dst$;

Rem
Rem Create TSM table tsm_hist$ that existed in 10.1
Rem
create table tsm_hist$
(
  source_sid           number,              /* session id on source instance */
  source_serial#       number,                 /* serial# on source instance */
  state                number,                            /* migration state */
  cost                 number,                   /* estimated migration cost */
  source               varchar2(4000),                    /* source instance */
  destination          varchar2(4000),               /* destination instance */
  connect_string       varchar2(4000),         /* destination connect string */
  failure_reason       number,            /* reason for failure of migration */
  destination_sid      number,         /* session id on destination instance */
  destination_serial#  number,            /* serial# on destination instance */
  start_time           date,                         /* migration start time */
  end_time             date                            /* migration end time */
)
tablespace SYSAUX
/
create index i_tsm_hist1 on tsm_hist$(source_sid, source_serial#)
tablespace SYSAUX
/

truncate table dir$alert_history;
truncate table dir$reason_strings;

Rem
Rem downgrade service$ cardinality columns
Rem
UPDATE service$ set
       min_cardinality = NULL,
       max_cardinality = NULL,
       flags = NULL;

Rem
Rem High Availability Alerts Downgrade
Rem

truncate table recent_resource_incarnations$;
drop public synonym DBA_RESOURCE_INCARNATIONS;
drop view DBA_RESOURCE_INCARNATIONS;

Rem
Rem Delete all hints for outlines created in 10.2 and then delete
Rem those outlines
Rem
delete outln.ol$hints
where ol_name in (select ol_name
                  from outln.ol$
                  where version = '10.2.0.0.0');

delete outln.ol$nodes
where ol_name in (select ol_name
                  from outln.ol$
                  where version = '10.2.0.0.0');

delete outln.ol$
where version = '10.2.0.0.0';

Rem Set hint_string column in outln.ol$hints to NULL

update outln.ol$hints set
       hint_string = null;

Rem
Rem Do the same as above for private outlines
Rem
delete system.ol$hints
where ol_name in (select ol_name
                  from system.ol$
                  where version = '10.2.0.0.0');

delete system.ol$nodes
where ol_name in (select ol_name
                  from system.ol$
                  where version = '10.2.0.0.0');

delete system.ol$
where version = '10.2.0.0.0';

Rem Set hint_string column in system.ol$hints to NULL

update system.ol$hints set
       hint_string = null;

Rem=========================================================================
Rem Begin Streams Downgrade
Rem=========================================================================
TRUNCATE TABLE apply$_error_txn;

UPDATE sys.apply$_dest_obj_ops SET assemble_lobs = 'N';
commit;

BEGIN
  UPDATE apply$_error SET error_creation_time = NULL;
  COMMIT;
END;
/

TRUNCATE TABLE sys.streams$_internal_transform;

-- apply spill
TRUNCATE TABLE sys.streams$_apply_spill_txn;
TRUNCATE TABLE sys.streams$_apply_spill_messages;
TRUNCATE TABLE sys.streams$_apply_spill_msgs_part;
TRUNCATE TABLE sys.streams$_apply_spill_txn_list;
drop sequence sys.streams$_apply_spill_txnkey_s;
DROP view DBA_APPLY_SPILL_TXN;
DROP view "_DBA_APPLY_SPILL_TXN";

UPDATE streams$_prepare_ddl SET flags = NULL, spare2 = NULL;
UPDATE streams$_prepare_object SET flags = NULL, spare2 = NULL;
COMMIT;

Rem BEGIN file groups tables downgrade

truncate table fgr$_file_groups;
truncate table fgr$_file_group_versions;
truncate table fgr$_file_group_files;
truncate table fgr$_file_group_export_info;
truncate table fgr$_table_info;
truncate table fgr$_tablespace_info;

Rem END file groups tables downgrade

-- DOWNSTREAM_REAL_TIME_MINE option introduced in 10gR2
BEGIN
  DELETE FROM streams$_process_params 
         WHERE name = 'DOWNSTREAM_REAL_TIME_MINE'
         AND   process_type = 2;
  COMMIT;
END;
/

-- Dependency Computation features introduced in 10gR2
TRUNCATE TABLE sys.apply$_constraint_columns;
TRUNCATE TABLE sys.apply$_virtual_obj_cons;

Rem reset oldest_transaction_id in streams$_apply_milestone

UPDATE streams$_apply_milestone
  SET oldest_transaction_id = NULL;
COMMIT;

Rem remove UA_NOTIFICATION_HANDLER from streams$_apply_process 
Rem remove any value stored in the column

UPDATE streams$_apply_process 
  SET UA_NOTIFICATION_HANDLER = NULL,
      UA_RULESET_OWNER = NULL,
      UA_RULESET_NAME = NULL;
COMMIT;


DECLARE
  vt sys.re$variable_type_list;
BEGIN
  vt := sys.re$variable_type_list(
    sys.re$variable_type('DML', 'SYS.LCR$_ROW_RECORD', 
       'SYS.DBMS_STREAMS_INTERNAL.ROW_VARIABLE_VALUE_FUNCTION',
       'SYS.DBMS_STREAMS_INTERNAL.ROW_FAST_EVALUATION_FUNCTION'),
    sys.re$variable_type('DDL', 'SYS.LCR$_DDL_RECORD',
       'SYS.DBMS_STREAMS_INTERNAL.DDL_VARIABLE_VALUE_FUNCTION',
       'SYS.DBMS_STREAMS_INTERNAL.DDL_FAST_EVALUATION_FUNCTION'));

  dbms_rule_adm.alter_evaluation_context(
    evaluation_context_name=>'SYS.STREAMS$_EVALUATION_CONTEXT',
    variable_types=>vt);
EXCEPTION WHEN OTHERS THEN
  IF SQLCODE = -24150 THEN
    -- suppress evaluation context does not exist error to minimize
    -- unwanted noise during downgrade.
    NULL;
  ELSE
    RAISE;
  END IF;
END;
/

BEGIN
  UPDATE sys.reg$ SET qosflags = 0, payload_callback = null, timeout = null,
    subscription_name = REPLACE(subscription_name, '"');
  COMMIT;
END;
/

--
-- Recoverable scripts downgrade
--
TRUNCATE TABLE sys.reco_script_params$;
TRUNCATE TABLE sys.reco_script_block$;
TRUNCATE TABLE sys.reco_script_error$;
TRUNCATE TABLE sys.reco_script$;


Rem=========================================================================
Rem End Streams Downgrade
Rem=========================================================================

Rem
Rem Transparent Data Encryption
Rem
truncate table enc$;

Rem
Rem Delete Scheduler Chain rows
Rem
truncate table scheduler$_chain;
truncate table scheduler$_step;
truncate table scheduler$_step_state;

Rem
Rem Begin CDC changes here
Rem

Rem set columns added in 10.2 to null
UPDATE cdc_change_sources$ SET capture_name = NULL;
UPDATE cdc_change_sources$ SET capqueue_name = NULL;
UPDATE cdc_change_sources$ SET capqueue_tabname = NULL;
UPDATE cdc_change_sources$ SET source_enabled = NULL;
UPDATE cdc_change_sets$ SET set_sequence = NULL;
COMMIT;

Rem truncate tables added in 10.2
TRUNCATE table cdc_propagations$;
TRUNCATE table cdc_propagated_sets$;

Rem return pre-defined changes sources to original values
Rem return autolog change sources back to a value of 2 .
BEGIN
  UPDATE cdc_change_sources$
    SET source_type = 3
    WHERE source_name = 'HOTLOG_SOURCE';

  UPDATE cdc_change_sources$
    SET source_type = 4
    WHERE source_name = 'SYNC_SOURCE';

  UPDATE cdc_change_sources$
    SET source_type = 2
    WHERE BITAND(source_type,2) = 2;

  COMMIT;
END;
/

Rem drop the views added 
DROP view  change_propagations;
DROP view  change_propagation_sets;

Rem drop package added in 10.2
DROP package dbms_cdc_sys_ipublish;

Rem
Rem End CDC changes
Rem

Rem=========================================================================
Rem Begin Advanced Queuing downgrade
Rem=========================================================================
execute DBMS_SESSION.RESET_PACKAGE; 

REM drop views that exists only in 10.2

drop public synonym all_dequeue_queues;
drop view all_dequeue_queues;

drop public synonym user_queue_subscribers;
drop view user_queue_subscribers;

drop public synonym all_queue_subscribers;
drop view all_queue_subscribers;

drop public synonym dba_queue_subscribers;
drop view dba_queue_subscribers;

drop function aq$_get_subscribers;
drop type sys.aq$_subscriber_t force;
drop type sys.aq$_subscriber force;

drop package sys.dbms_transform_eximp_internal;

drop package sys.dbms_aq_inv;


Rem=========================================================================
Rem End Advanced Queuing downgrade
Rem=========================================================================

Rem=========================================================================
Rem Beging Rules engine downgrade
Rem=========================================================================

truncate table rule_set_nl$;
truncate table rule_set_pr$;

Rem=========================================================================
Rem End Rules engine downgrade
Rem=========================================================================

Rem=========================================================================
Rem Begin SQL Response Time Downgrade
Rem=========================================================================

drop table dbsnmp.mgmt_snapshot;
drop table dbsnmp.mgmt_snapshot_sql;
drop table dbsnmp.mgmt_baseline;
drop table dbsnmp.mgmt_baseline_sql;
drop table dbsnmp.mgmt_capture;
drop table dbsnmp.mgmt_capture_sql;
drop table dbsnmp.mgmt_response_config;
drop table dbsnmp.mgmt_latest;
drop table dbsnmp.mgmt_latest_sql;
drop table dbsnmp.mgmt_history;
drop table dbsnmp.mgmt_history_sql;
drop table dbsnmp.mgmt_tempt_sql;
drop sequence dbsnmp.mgmt_response_capture_id;
drop sequence dbsnmp.mgmt_response_snapshot_id;
drop view dbsnmp.mgmt_response_baseline;

Rem=========================================================================
Rem End SQL Response Time Downgrade
Rem=========================================================================

Rem=========================================================================
Rem Begin Dynamic Baselines Downgrade
Rem=========================================================================

drop package dbsnmp.mgmt_bsln;
drop package dbsnmp.mgmt_bsln_internal;

drop type dbsnmp.bsln_interval_set force;
drop type dbsnmp.bsln_interval_t force;

drop type dbsnmp.bsln_observation_set force;
drop type dbsnmp.bsln_observation_t force;

drop type dbsnmp.bsln_statistics_set force;
drop type dbsnmp.bsln_statistics_t force;

alter table dbsnmp.mgmt_bsln_intervals disable constraint bsln_intervals_fk1;
alter table dbsnmp.mgmt_bsln_statistics disable constraint bsln_statistics_fk1;
alter table dbsnmp.mgmt_bsln_statistics disable constraint bsln_statistics_fk2;
alter table dbsnmp.mgmt_bsln_threshold_parms disable constraint bsln_thresholds_fk1;
alter table dbsnmp.mgmt_bsln_threshold_parms disable constraint bsln_thresholds_fk2;

DECLARE
  PROCEDURE execute_truncate(table_name IN VARCHAR2) IS
    no_such_table  EXCEPTION;
    PRAGMA exception_init(no_such_table, -942);
  BEGIN
    execute immediate 'truncate table ' || table_name;
  EXCEPTION
    WHEN no_such_table THEN null;
  END;
BEGIN
  -- execute_truncation procedure invoked only with literal constants
  execute_truncate('dbsnmp.mgmt_bsln_intervals');
  execute_truncate('dbsnmp.mgmt_bsln_metrics');
  execute_truncate('dbsnmp.mgmt_bsln_statistics');
  execute_truncate('dbsnmp.mgmt_bsln_threshold_parms');
  execute_truncate('dbsnmp.mgmt_bsln_baselines');
  execute_truncate('dbsnmp.mgmt_bsln_datasources');
  execute_truncate('dbsnmp.mgmt_bsln_rawdata');
END;
/

alter table dbsnmp.mgmt_bsln_intervals enable constraint bsln_intervals_fk1;
alter table dbsnmp.mgmt_bsln_statistics enable constraint bsln_statistics_fk1;
alter table dbsnmp.mgmt_bsln_statistics enable constraint bsln_statistics_fk2;
alter table dbsnmp.mgmt_bsln_threshold_parms enable constraint bsln_thresholds_fk1;
alter table dbsnmp.mgmt_bsln_threshold_parms enable constraint bsln_thresholds_fk2;

Rem=========================================================================
Rem End Dynamic Baselines Downgrade
Rem=========================================================================

Rem=========================================================================
Rem EUS Proxy downgrade - Begin
Rem=========================================================================

DELETE FROM  proxy_info$
       WHERE bitand(flags, 16)  = 16 ;

Rem=========================================================================
Rem EUS Proxy downgrade - End
Rem=========================================================================

Rem Remove the database-level trace entries from wri$_tracing_enabled
delete from wri$_tracing_enabled where trace_type = 6;
commit;

Rem set Materialized View metadata 
UPDATE snap$   set syn_count  = NULL;
UPDATE sumdep$ set syn_own    = NULL;
UPDATE sumdep$ set syn_name   = NULL;
UPDATE sumdep$ set syn_master = NULL;
UPDATE sumdep$ set vw_query = NULL;
UPDATE sumdep$ set vw_query_len = NULL;

Rem remove all 10.2 online redefinition metadata
DECLARE
  CURSOR redef10gR2 IS
    SELECT id FROM sys.redef$ r
    WHERE bitand(r.flag, 4096) = 4096;
BEGIN
  FOR r2 IN redef10gR2 LOOP
    DELETE FROM sys.redef_object$ r
    WHERE r.redef_id = r2.id;

    DELETE FROM sys.redef_dep_error$ r
    WHERE r.redef_id = r2.id;

    DELETE FROM sys.redef$ r
    WHERE r.id = r2.id;
  END LOOP;
  COMMIT;
END;
/

Rem set the new column (flags) value to 0 in dimlevel$
UPDATE sys.dimlevel$ SET flags = 0;  
Rem set the new column (chdlevid#) value to 0 in dimjoinkey$
UPDATE sys.dimjoinkey$ SET chdlevid# = 0;

Rem Set service$.goal and service$.flags columns to null
UPDATE service$ set goal = NULL;
UPDATE service$ set flags = NULL;

Rem drop the utl_match package
drop package utl_match;

Rem Component Registry downgrade
truncate table registry$schemas;

Rem drop the dbms_db_version package and its public synonym
drop public synonym dbms_db_version;
drop package dbms_db_version;

Rem drop the dbms_preprocessor package and its public synonym
drop public synonym dbms_preprocessor;
drop package dbms_preprocessor;

Rem Drop Decision Tree Internal types and functions
drop PUBLIC SYNONYM ORA_DM_Tree_Nodes;
drop PUBLIC SYNONYM ORA_FI_DECISION_TREE_HORIZ;
drop function ORA_FI_DECISION_TREE_HORIZ;
drop type ORA_DM_Tree_Nodes force;
drop type ORA_DM_Tree_Node  force;

Rem change notification tables
truncate table invalidation_registry$;

Rem=========================================================================
Rem XQuery related downgrade - begin
Rem=========================================================================

drop public synonym SYS_IXQAGG;
drop function SYS_IXQAGG;
drop type AggXQImp;
drop public synonym XQSequence;
drop operator XQSequence;
drop function XQSequenceFromXMLType;
drop type XQSeq_Imp_t;


Rem=========================================================================
Rem XQuery related downgrade - end
Rem=========================================================================


Rem=========================================================================
Rem XMLAgg and XMLSequence related downgrade - begin
Rem=========================================================================

Rem ** Type Frozen.  Any additions must be through alter type add.
create or replace type AggXMLInputType OID '00000000000000000000000000020103'
  authid current_user as object
(
  input sys.XMLType,
  format sys.XMLGenFormatType 
);
/
grant execute on AggXMLInputType to public with grant option;

-- the following 5 privileges were not in 8.17 or 9.01
grant execute on XMLSeq_Imp_t to public with grant option;
grant execute on XMLSeqCur_Imp_t to public with grant option;
grant execute on XMLSeqCur2_Imp_t to public with grant option;
grant execute on AggXMLImp to public with grant option;
grant execute on XMLAGG to public with grant option;

Rem=========================================================================
Rem XMLAgg and XMLSequence related downgrade - end
Rem=========================================================================

Rem=========================================================================
Rem OLAP related downgrade - begin
Rem=========================================================================

grant execute on OLAPImpl_t to public;
grant execute on OLAPRanCurImpl_t to public;

Rem=========================================================================
Rem OLAP related downgrade - end
Rem=========================================================================

-- Drop new UTL_RECOMP views
drop view utl_recomp_all_objects;
 
Rem=========================================================================
Rem Java Dictionary javaobj$ downgrade
Rem=========================================================================
truncate table javaobj$;

Rem bug 6144565: in 10.2 we created some indexes as unique. the 10.1 code
Rem does not handle unique indexes correctly. recreate them as non unique

drop index i_tabpart_bopart$
/
create index i_tabpart$ on tabpart$(bo#, obj#)
/
drop index i_tabpart_obj$
/
create index i_tabpart_obj$ on tabpart$(obj#)
/
drop index i_indpart_bopart$
/
create index i_indpart$ on indpart$(bo#, obj#)
/
drop index i_indpart_obj$
/
create index i_indpart_obj$ on indpart$(obj#)
/
drop index i_tabsubpart_pobjsubpart$
/
create index i_tabsubpart$ on tabsubpart$(pobj#, obj#)
/
drop index i_tabsubpart$_obj$
/
create index i_tabsubpart$_obj$ on tabsubpart$(obj#)
/
drop index i_indsubpart_pobjsubpart$
/
create index i_indsubpart$ on indsubpart$(pobj#, obj#)
/
drop index i_indsubpart_obj$
/
create index i_indsubpart_obj$ on indsubpart$(obj#)
/
drop index i_tabcompart_bopart$
/
drop index i_indcompart_bopart$
/
drop index i_lobfrag$_parentobj$
/
create index i_lobfrag$_parentobj$ on lobfrag$(parentobj#)
/
drop index i_lobfrag$_fragobj$
/
create index i_lobfrag$_fragobj$ on lobfrag$(fragobj#)
/
drop index i_lobcomppart$_lobjpart$
/
create index i_lobcomppart$_partlobj$ on lobcomppart$(lobj#)
/
drop index i_lobcomppart$_partobj$
/
create index i_lobcomppart$_partobj$ on lobcomppart$(partobj#)
/
drop index i_defsubpart$
/
create index i_defsubpart$ on defsubpart$(bo#, spart_position)
/
drop index i_defsubpartlob$
/
create index i_defsubpartlob$ on defsubpartlob$ (bo#, intcol#, spart_position)
/

Rem =========================================================================
Rem END STAGE 2: downgrade dictionary from 10.2 to 10.1
Rem =========================================================================

Rem drop the dbms_assert package and its public synonym
-- if the version we upgraded from is 9.2, do not drop these packages yet
-- DBMS_UTILITY and DBMS_REGISTRY need it in the 9.2 downgrade
-- dbms_isched_chain_condition cannot be dropped during downgrade to 9.2
-- either since it is required by the 10.1->9.2 downgrade (e0902000.sql)
DECLARE
  previous_version  varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE cid = 'CATPROC';

  IF previous_version NOT LIKE '9.2.0%' THEN
    execute immediate 'drop public synonym dbms_assert';
    execute immediate 'drop package dbms_assert';
    execute immediate 'drop package dbms_isched_chain_condition';
    execute immediate 'drop package dbms_propagation_internal';

    -- The following package must be conditionally dropped because it will
    -- invalidate dbms_streams_adm, which e0902000.sql relies upon.  Thus
    -- if the version we upgraded from is 9.2, do not drop this package.
    execute immediate 'DROP PACKAGE dbms_streams_mt'; 
    
    -- drop the dba_queue_schedules and user_queue_schedules views
    -- These will be recreated by catqueue again
    execute immediate 'drop public synonym dba_queue_schedules';
    execute immediate 'drop view dba_queue_schedules';
    execute immediate 'drop public synonym user_queue_schedules';
    execute immediate 'drop view user_queue_schedules';

    -- dbms_isched has dependency on this table
    execute immediate 'alter table scheduler$_job_run_details modify 
                      (cpu_used number)';
    -- Drop package with dependency on X$KQFOPT
    execute immediate 'drop package dbms_stats_internal';

  END IF;
END;
/

Rem=========================================================================
Rem invalidate rules engine objects
Rem=========================================================================
UPDATE sys.obj$ SET status = 5
where obj# in
  ((select obj# from obj$ where type# = 62 or type# = 46 or type# = 59)
   union all
   (select /*+ index (dependency$ i_dependency2) */ 
      d_obj# from dependency$
      connect by prior d_obj# = p_obj#
      start with p_obj# in
        (select obj# from obj$ where type# = 62 or type# = 46 or type# = 59)))
/
commit
/

Rem=========================================================================
Rem drop _*_EDITION_OBJ view family
Rem=========================================================================
drop view "_CURRENT_EDITION_OBJ";
drop view "_ACTUAL_EDITION_OBJ";
drop view "_BASE_USER";

Rem=========================================================================
Rem drop edition ORA$BASE
Rem=========================================================================
drop edition ORA$BASE CASCADE;

delete from sys.props$ where name = 'DEFAULT_EDITION';
commit;

alter system flush shared_pool;

Rem *************************************************************************
Rem END e1001000.sql
Rem *************************************************************************
