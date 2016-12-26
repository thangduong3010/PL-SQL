Rem
Rem $Header: rdbms/admin/c1101000.sql /st_rdbms_11.2.0/10 2013/04/24 13:57:42 yanlili Exp $
Rem
Rem c1101000.sql
Rem
Rem Copyright (c) 2005, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      c1101000.sql - Script to upgrade from 11.1.0 to the new release
Rem
Rem    DESCRIPTION
Rem      Put any dictionary related changes here (ie - create, alter,
Rem      update,...).  If you must upgrade using PL/SQL packages, 
Rem      put the PL/SQL block in a1101000.sql since catalog.sql and 
Rem      catproc.sql will be run before a1101000.sql is invoked.
Rem
Rem      This script is called from catupgrd.sql and c1002000.sql
Rem
Rem    NOTES
Rem      Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      The database must be open for UPGRADE
Rem      
Rem    MODIFIED   (MM/DD/YY)
Rem    yanlili     04/19/13 - Backport minx_bug-16369584 from main
Rem    mfallen     01/16/13 - bug 14226622: add IP to WRHS_CLUSTER_INTERCON_PK
Rem    hosu        08/28/12 - Backport hosu_bug-14159402 from
Rem    bhammers    07/01/11 - Backport bhammers_bug-12674093 from main
Rem    cmlim       06/16/11 - bug 11864197 - rewrite update of dbid column in
Rem                           aud$/fga_log$
Rem    yberezin    03/21/11 - Backport yberezin_bug-10398280 from main
Rem    cdilling    02/03/11 - Backport cdilling_bug-10373381 from
Rem                           st_rdbms_11.2.0.1.0
Rem    slynn       04/14/10 - Fix Security bug-9563080.
Rem    apsrivas    02/22/10 - Bug 9337796: Fix sql injection vulnerability in
Rem                           insert_into_defpwd procedure
Rem    pbelknap    09/28/09 - reorder wri$_adv_usage for 10.2.0.5 case
Rem    mmcracke    08/10/09 - Include changes from bug 7027820
Rem    cdilling    08/03/09 - invoke 11.2 patch upgrade script
Rem    pbelknap    07/15/09 - handle re-upgrade for primary key on adv usage
Rem    rkgautam    07/15/09 - #8675976, adding another def pwds for ORACLE_OCM
Rem    rangrish    07/15/09 - revoke under on uritype
Rem    adng        07/01/09 - add stats for Exadata
Rem    pbelknap    06/22/09 - #8618452 - feature usage for reports
Rem    rkgautam    06/22/09 - Bug 8617056, adding second def pwds for EXFSYS
Rem    rkgautam    06/05/09 - Bug 8569337: adding def pwds for EUL4_US, EUL5_US
Rem    bvaranas    06/04/09 - 8549808: Drop table deferred_stg$ before 
Rem                           creating it
Rem    nkgopal     05/29/09 - Bug 8331425: Populated DBID in AUD$ and FGA_LOG$
Rem    kyagoub     04/15/09 - fix lrg#3856072: spa re-upgrade
Rem    mthiyaga    04/08/09 - Fix bug 8348017
Rem    rmao        04/08/09 - bug8418598: rename get_instance_number to
Rem                           get_thread_number
Rem    arbalakr    04/06/09 - fix for bug 8413011
Rem    jkundu      04/06/09 - add logmnr_gt_xid_include
Rem    rkgautam    04/06/09 - Bug 8399691,adding default pwds for AIA, JMSUSER
Rem    kyagoub     03/29/09 - add upgrade SPA 11.2 task parameters
Rem    rkgautam    03/26/09 - Bug 8339992,8356126,8351767 more default accounts
Rem    mbastawa    03/26/09 - drop client result cache views
Rem    yiru        03/25/09 - fix bug 8355329
Rem    hosu        03/24/09 - unique constraints added for stats related
Rem                           dictionary tables
Rem    mfallen     03/20/09 - bug 8347956: add flash cache columns to AWR tabs
Rem    juyuan      03/19/09 - drop table system.def$_temp$lob
Rem    arbalakr    03/16/09 - bug 8283759: add hostname and port number to ASH
Rem    rcolle      03/10/09 - add divergence_details_status in wrr$_replays
Rem    sarchak     03/02/09 - Bug 7829203,default_pwd$ should not be recreated
Rem    yujwang     03/06/09 - add WRR$_SEQUENCE_EXCEPTIONS to fix bug 8265167
Rem    jdhunter    03/05/09 - add OLAP API callback to expdepact$, exppkgact$
Rem    rmacnico    03/03/09 - Changes to compression$
Rem    spapadom    02/27/09 - Support for AS Replay
Rem    rmao        02/17/09 - add streams$_propagation_process.seqnum and
Rem                           streams$_propagation_seqnum sequence
Rem    ssvemuri    02/04/09 - Upgrade chnf catalog tables
Rem    elu         02/03/09 - update apply spill
Rem    bvaranas    02/17/09 - Remove not null constraints from
Rem                           sys.deferred_stg$
Rem    wwchan      02/16/09 - add caching to ora_tq_case during upgrade
Rem    skabraha    02/15/09 - bug #7446912: anytype.getinfo parameter change
Rem    asohi       02/11/09 - Add state column for sys.REG$
Rem    arbalakr    02/09/09 - bug 7350685: add orafn number to ASH
Rem    geadon      02/09/09 - bug 7654925: update tab$ trigflag for BJI /
Rem                           ref-ptn tables
Rem    amysoren    02/05/09 - bug 7483450: add foreground values to
Rem                           waitclassmetric
Rem    dvoss       02/05/09 - logstdby$events.event_time not null
Rem    rgmani      02/04/09 - Add lw fields
Rem    elu         02/03/09 - update apply spill
Rem    jomcdon     02/03/09 - add max_utilization_limit
Rem    rramkiss    02/04/09 - add run_job invoker field for data vault
Rem    rcolle      01/23/09 - bug 7441901: remove NOT NULL constraint for
Rem                           WRR$_REPLAY_SCN_ORDER
Rem    mfallen     01/16/09 - bug 7650345: add new sqlstat and seg_stat columns
Rem    slynn       01/12/09 - Bug-7694580: Change IDGEN CACHE size to 1000.
Rem    hongyang    01/06/09 - remove v$standby_apply_snapshot
Rem    bdagevil    01/02/09 - add STASH columns to ASH
Rem    yurxu       12/30/08 - Bug 7676952: remove DBA_CACHEABLE_OBJECTS
Rem    hayu        09/01/08 - update _sqltune_control value
Rem    liding      01/02/09 - upgrade MVs for lrg3745491
Rem    yurxu       12/30/08 - Bug 7676952: remove DBA_CACHEABLE_OBJECTS
Rem    rsamuels    12/19/08 - add and rename columns for olap api dict tables
Rem    yurxu       12/15/08 - Bug 7425686: Drop iAS packages
Rem    hayu        09/01/08 - update _sqltune_control value
Rem    matfarre    12/09/08 - bug 7596712: add session actions table
Rem    kyagoub     10/24/08 - rename sage to use cell
Rem    juyuan      12/01/08 - change handler
Rem    jinwu       11/19/08 - upgrade for stmt handler
Rem    thoang      11/18/08 - add kxid columns to apply$_error
Rem    mfallen     12/08/08 - bug 7621616: correct pk on WRH$_SEG_STAT_BR
Rem    vakrishn    12/05/08 - add owner column to SYS_FBA_FA of Flashback
Rem                           Archive
Rem    sjanardh    10/20/08 - Add scn_at_add column
Rem    ssonawan    09/29/08 - Bug 7295457: Add missing audit options in 
Rem                           stmt_audit_option_map
Rem    nkgopal     09/17/08 - Bug 6856975: Add ALL STATEMENTS to 
Rem                           STMT_AUDIT_OPTION_MAP
Rem    hayu        09/01/08 - update _sqltune_control value
Rem    dvoss       11/07/08 - bug 7553884 - set logminer chunk_supress bit for
Rem                           logical standby
Rem    mfallen     10/30/08 - bug 7247999: modify primary key for
Rem                           IC_DEVICE_STATS
Rem    elu         10/28/08 - remove commit pos
Rem    yujwang     10/03/08 - add scale_up_multiplier to wrr$_replays
Rem    ilistvin    10/24/08 - change AWR version from 3 to 4
Rem    astoler     10/15/08 - bug 6970590, fix CDC privileges
Rem    yujwang     10/03/08 - add scale_up_multiplier to wrr$_replays
Rem    rgmani      04/15/08 - Scheduler file watching related actions
Rem    rramkiss    04/08/08 - upgrade for 11.2 scheduler email notification
Rem    dvoss       10/14/08 - convert logmnr integers to numbers
Rem    achoi       10/08/08 - move drop user to the a script
Rem    amitsha     10/03/08 - modify compression$ table
Rem    ssonawan    07/08/08 - bug 5921164: add column powner to fga$ 
Rem    apsrivas    09/11/08 - BUG 7294185 - avoid duplicate entries in OBJ$
Rem                           when dblink is up
Rem    shiyer      09/18/08 - #6854917:drop TSMSYS
Rem    sburanaw    09/16/08 - add wrr$_replay_data
Rem    rcolle      09/11/08 - add columns to DB replay schema for PAUSE support
Rem    ushaft      08/06/08 - add columns to ADDM table
Rem    rmao        09/05/08 - change comparison_scan$ table to improve query
Rem                           performance on dba/user_comparison_scan(_summary)
Rem                           views
Rem    rcolle      08/20/08 - add columns for DB replay populate_diveregence
Rem    nkgopal     07/23/08 - Bug 6830207: Add ALTER DATABASE LINK and ALTER
Rem                           PUBLIC DATABASE LINK to SYSTEM_PRIVILEGE_MAP 
Rem                           and STMT_AUDIT_OPTION_MAP
Rem    rmao        08/09/08 - change index on streams$_capture_server
Rem    elu         08/08/08 - change streams$_apply_spill_messages
Rem    legao       08/05/08 - add inactive_time column to 
Rem                         - streams$_capture_server
Rem    praghuna    08/03/08 - Add get_row_text function to lcr$_row_record
Rem    elu         07/22/08 - lcr pos
Rem    snadhika    07/23/08 - upgrade fix for bug 7197834 
Rem    bmilenov    07/23/08 - Bug-7197860: Revoke data mining grants
Rem    rmao        07/22/08 - add unschedule_time to
Rem                           streams$_propagation_process
Rem    kchen       07/16/08 - revoke all on hs_bulkload_view_obj
Rem    nchoudhu    07/14/08 - XbranchMerge nchoudhu_sage_july_merge117 from
Rem                           st_rdbms_11.1.0
Rem    vliang      07/07/08 - 
Rem    huagli      07/03/08 - create DST patching pre-defined tables
Rem    legao       07/02/08 - modify get_instance_number return type
Rem    rramkiss    06/24/08 - bug #7197969 - remove with_grant_option from
Rem                           scheduler pkgs
Rem    hayu        06/20/08 - fix lrg 3450341
Rem    mjgreave    06/14/08 - Add OUTLINE to STMT_AUDIT_OPTION_MAP. #6845085
Rem    msakayed    05/30/08 - revoke public access to datapump packages
Rem    kyagoub     05/21/08 - add new task parameter for spa
Rem    geadon      05/14/08 - bug 6957265: patchup tab$.ts# and tabpart$.ts#
Rem                           for IOTs
Rem    hayu        05/11/08 - add columns for sql tune
Rem    kchen       05/13/08 - fixed bug 7028356
Rem    sburanaw    05/12/08 - add rep_dir_id to wrr$_replays, 
Rem                           unique_id to wrr$_captures
Rem    kyagoub     05/11/08 - add new column to wri$_adv_sqlt_plan_stats
Rem    rmao        05/05/08 - Modify streams$_split_merge and 
Rem                           streams$_capture_server tables
Rem    haxu        04/29/08 - add error_date, error_msg to 
Rem                           streams$_propagation_process
Rem    elu         04/11/08 - add LCR methods
Rem    msakayed    05/01/08 - compression/encryption feature tracking for 11.2
Rem    huagli      04/18/08 - lrg 3369670: move MV related upgrade script
Rem                           to i1101000.sql
Rem    sursridh    04/10/08 - Add compression level column to
Rem                           deferred_stg$
Rem    rmao        04/04/08 - modify streams$_split_merge table
Rem    huagli      03/08/08 - Project 25482: commit SCN-based MV logs
Rem    wesmith     10/17/07 - MV log purge optimization
Rem    nkgopal     03/27/08 - Bug 6810355: Check where I_AUD1 exists
Rem                           before dropping it
Rem                           Dont drop PLHOL column from FGA_LOG$
Rem    thoang      03/19/08 - add get_instantiation_num method to lcr type 
Rem    rmao        03/18/08 - add streams$_capture_server table
Rem    mfallen     03/12/08 - bug 6861722: add column to wrh$_db_cache_advice
Rem    elu         03/03/08 - modify apply spill tables
Rem    thoang      02/29/08 - Add XStream tables and views 
Rem    rmao        02/20/08 - add streams$_split_merge table
Rem    jaeblee     02/27/08 - create index i_syn2 on syn$
Rem    akini       02/13/08 - increase length of ip addresses for IPv6
Rem    bvaranas    02/13/08 - Project 25274: Deferred segment creation. Add
Rem                           deferred_stg$
Rem    nkgopal     01/28/08 - lrg 3282232: drop PLHOL in PL/SQL
Rem    nkgopal     01/12/08 - Add DBMS_AUDIT_MGMT changes
Rem    srtata      01/15/08 - drop xs$session_hws table
Rem    sburanaw    12/12/07 - add blocking_inst_id, ecid to ASH
Rem    yujwang     11/29/07 - add schema change for Database Replay
Rem    rburns      11/05/07 - reorder xs$sessions alters
Rem    chliang     10/25/07 - fix index type for xs$ tables
Rem    snadhika    10/16/07 - create unique index on sessions table
Rem    dgagne      10/26/07 - add revoke of public grant to plts package
Rem    vmarwah     10/18/07 - Archive Compression: Upgrade changes from 11.1
Rem    gagarg      10/16/07 - Bug 6488226 6: Add attribute RULE_NAME in
Rem                           AQ$_subscriber type
Rem    cdilling    10/04/07 - fixup table_privilege_map
Rem    mjaiswal    10/03/07 - upgrade changes for xs$parameters
Rem    mlfeng      08/22/07 - increase size of NAME column for the cluster
Rem                           interconnect AWR table
Rem    rburns      08/20/07 - Created for 11.1 major release upgrades
Rem    mlfeng      07/24/07 - change the primary key for segment stat table
Rem    rburns      07/10/07 - changes for 11.1 patch release
Rem    cdilling    12/06/06 - add Data Vault
Rem    rburns      07/13/06 - enable MGW 
Rem    rburns      03/24/06 - remove ODM 
Rem    rburns      10/11/05 - add DBUA timestamp 
Rem    cdilling    10/10/05 - disable own and mgw for patch 
Rem    cdilling    06/15/05 - cdilling_add_upgrade_scripts
Rem    rburns      03/14/05 - use dbms_registry_sys
Rem    rburns      01/18/05 - comment out htmldb for 10.2 
Rem    rburns      11/11/04 - move CONTEXT 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      10/21/04 - rburns_rename_catpatch
Rem    rburns      10/18/04 - rename to c1002000.sql (was catpatch.sql)
Rem    rburns      10/11/04 - add RUL 
Rem    rburns      06/17/04 - final timestamp to catupgrd 
Rem    rburns      04/07/04 - move utllmup.sql to catupgrd 
Rem    rburns      02/23/04 - add EM 
Rem    rburns      08/28/03 - cleanup 
Rem    rburns      04/25/03 - use timestamp
Rem    rburns      04/08/03 - use function for script names
Rem    rburns      01/20/03 - fix version, add exf, re-order olap
Rem    rburns      01/18/03 - use server registry
Rem    dvoss       01/14/03 - add utllmup.sql
Rem    rburns      08/27/02 - add Ultra Search patch
Rem    rburns      07/18/02 - comment components not in patch release
Rem    rburns      05/14/02 - convert for 9.2.0.2
Rem    rburns      03/29/02 - convert for 9.2.0
Rem    rburns      10/15/01 - add scope argument
Rem    rburns      10/10/01 - Merged rburns_patchset_tests
Rem    rburns      09/26/01 - Version for 9.0.1.2.0 patchset
Rem    rburns      09/26/01 - Created
Rem

Rem *************************************************************************
Rem BEGIN c1101000.sql
Rem *************************************************************************

Rem=========================================================================
Rem BEGIN STAGE 1: upgrade from 11.1.0 to the current release
Rem=========================================================================


Rem=========================================================================
Rem Add new system privileges here 
Rem=========================================================================


Rem=========================================================================
Rem Add new object privileges here
Rem=========================================================================

Rem
Rem For  TABLE_PRIVILEGE_MAP set privilege name to 'MERGE VIEW'
Rem
update TABLE_PRIVILEGE_MAP set name = 'MERGE VIEW' 
  where privilege = 28 and name = 'MERGE';

Rem ===================================
Rem  Begin Advanved Compression Changes
Rem ===================================
REM archive compression dictionary tables
create table compression$
(
  ts#           number,                                 /* tablespace number */
  file#         number,                        /* segment header file number */
  block#        number,                       /* segment header block number */
  obj#          number not null,                            /* object number */
  dataobj#      number,                          /* data layer object number */
  ulevel        number not null,         /* user specified compression level */
  sublevel      number,                              /* compression sublevel */
  ilevel        number,                                /* internal algorithm */
  flags         number,                                        /* misc flags */
  bestsortcol   number,             /* Best sort column computed by analyzer */
  tinsize       number,            /* target input size computed by analyzer */
  ctinsize      number,                         /* current target input size */
  toutsize      number,            /* target output size passed to cu engine */
  cmpsize       number,                    /* total compressed size of table */
  uncmpsize     number,                  /* total uncompressed size of table */
  mtime         date,                        /* timestamp of compression map */
  analyzer      blob,                                /* analyzer information */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        number
)
/
create unique index i_compression1 on compression$(obj#, ulevel, mtime)
/

Rem =================================
Rem  End Advanced Compression Changes
Rem =================================


Rem=========================================================================
Rem Add new audit options here 
Rem=========================================================================

insert into STMT_AUDIT_OPTION_MAP values ( 51, 'OUTLINE', 0);

Rem =======================================================================
Rem  Bug-7295457 :
Rem =======================================================================  
insert into STMT_AUDIT_OPTION_MAP values (186, 'UNDER ANY TYPE', 0);
insert into STMT_AUDIT_OPTION_MAP values (200, 'CREATE OPERATOR', 0);
insert into STMT_AUDIT_OPTION_MAP values (201, 'CREATE ANY OPERATOR', 0);
insert into STMT_AUDIT_OPTION_MAP values (202, 'ALTER ANY OPERATOR', 0);
insert into STMT_AUDIT_OPTION_MAP values (203, 'DROP ANY OPERATOR', 0);
insert into STMT_AUDIT_OPTION_MAP values (204, 'EXECUTE ANY OPERATOR', 0);
insert into STMT_AUDIT_OPTION_MAP values (205, 'CREATE INDEXTYPE', 0);
insert into STMT_AUDIT_OPTION_MAP values (206, 'CREATE ANY INDEXTYPE', 0);
insert into STMT_AUDIT_OPTION_MAP values (207, 'ALTER ANY INDEXTYPE', 0);
insert into STMT_AUDIT_OPTION_MAP values (208, 'DROP ANY INDEXTYPE', 0);
insert into STMT_AUDIT_OPTION_MAP values (209, 'UNDER ANY VIEW', 0);
insert into STMT_AUDIT_OPTION_MAP values (212, 'EXECUTE ANY INDEXTYPE', 0);
insert into STMT_AUDIT_OPTION_MAP values (213, 'UNDER ANY TABLE', 0);
insert into STMT_AUDIT_OPTION_MAP values (227, 'ADMINISTER RESOURCE MANAGER', 1);
insert into STMT_AUDIT_OPTION_MAP values (228, 'ADMINISTER DATABASE TRIGGER',0);
commit;
Rem =======================================================================
Rem  End Changes for Bug-7295457
Rem =======================================================================  


Rem=========================================================================
Rem Drop views and packages removed from last release here 
Rem Remove obsolete dependencies for any fixed views in i1101000.sql
Rem=========================================================================

Rem =======================================================================
Rem  Begin Dropping iAS packages
Rem =======================================================================

drop package DBMS_IAS_CONFICURE;
drop package DBMS_IAS_INST;
drop package DBMS_IAS_INST_UTL;
drop package DBMS_IAS_INST_UTL_EXP;
drop package DBMS_IAS_MT_INST;
drop package DBMS_IAS_MT_INST_INTERNAL;
drop package DBMS_IAS_QUERY;
drop package DBMS_IAS_SESSION;
drop package DBMS_IAS_TEMPLATE;
drop package DBMS_IAS_TEMPLATE_INTERNAL;
drop package DBMS_IAS_TEMPLATE_UTL;

Rem =======================================================================
Rem  End Dropping iAS packages 
Rem =======================================================================

Rem =======================================================================
Rem  Begin Dropping DBA_CACHEABLE_OBJECTS AND RELATED
Rem =======================================================================

drop view "DBA_CACHEABLE_NONTABLE_OBJECTS";
drop view "DBA_CACHEABLE_OBJECTS";
drop view "DBA_CACHEABLE_OBJECTS_BASE";
drop view "DBA_CACHEABLE_TABLES";
drop view "DBA_CACHEABLE_TABLES_BASE";

drop public synonym "DBA_CACHEABLE_OBJECTS";
drop public synonym "DBA_CACHEABLE_OBJECTS_BASE";
drop public synonym "DBA_CACHEABLE_TABLES";

drop public synonym "DBMS_IAS_SESSION";
drop public synonym "DBMS_IAS_CONFIGURE";
drop public synonym "DBMS_IAS_QUERY";

drop public synonym "DBMS_IAS_TEMPLATE";

drop public synonym "DBMS_IAS_INST";
drop public synonym "DBMS_IAS_MT_INST";

Rem =======================================================================
Rem  End Dropping DBA_CACHEABLE_OBJECTS AND RELATED
Rem =======================================================================

Rem=========================================================================
Rem Add changes to dictionary tables and object types here 
Rem=========================================================================

Rem
Rem Create index i_syn2 on syn$
Rem
create index i_syn2 on syn$(owner,name);

Rem ===================
Rem  Begin AWR Changes
Rem ===================

-- Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

Rem 
Rem Change the primary key for seg stat (bug 6214874)
Rem 
-- reorganize primary key
alter table WRH$_SEG_STAT
  drop constraint WRH$_SEG_STAT_PK;
alter table WRH$_SEG_STAT 
  add  constraint WRH$_SEG_STAT_PK
    PRIMARY KEY (dbid, snap_id, instance_number, ts#, obj#, dataobj#)
    using index local tablespace SYSAUX;

-- reorganize primary key
alter table WRH$_SEG_STAT_BL
  drop constraint WRH$_SEG_STAT_BL_PK;
alter table WRH$_SEG_STAT_BL
  add  constraint WRH$_SEG_STAT_BL_PK
    PRIMARY KEY (dbid, snap_id, instance_number, ts#, obj#, dataobj#)
    using index tablespace SYSAUX;

-- reorganize primary key
alter table WRH$_SEG_STAT_BR
  drop constraint WRH$_SEG_STAT_BR_PK;
alter table WRH$_SEG_STAT_BR
  add constraint WRH$_SEG_STAT_BR_PK
    PRIMARY KEY (dbid, snap_id, instance_number, ts#, obj#, dataobj#)
    using index tablespace SYSAUX;

alter table WRH$_SEG_STAT_OBJ 
  drop constraint WRH$_SEG_STAT_OBJ_PK;
alter table WRH$_SEG_STAT_OBJ 
  add  constraint WRH$_SEG_STAT_OBJ_PK
    PRIMARY KEY (dbid, ts#, obj#, dataobj#)
    using index tablespace SYSAUX;

Rem 
Rem Add columns for seg stats (bug 7650345)
Rem 
alter table WRH$_SEG_STAT add (physical_read_requests_total    NUMBER);
alter table WRH$_SEG_STAT add (physical_read_requests_delta    NUMBER);
alter table WRH$_SEG_STAT add (physical_write_requests_total   NUMBER);
alter table WRH$_SEG_STAT add (physical_write_requests_delta   NUMBER);
alter table WRH$_SEG_STAT add (optimized_physical_reads_total  NUMBER);
alter table WRH$_SEG_STAT add (optimized_physical_reads_delta  NUMBER);

Rem 
Rem Add columns for SQL stat (bug 7650345)
Rem 
alter table WRH$_SQLSTAT add (io_offload_elig_bytes_total      NUMBER);
alter table WRH$_SQLSTAT add (io_offload_elig_bytes_delta      NUMBER);
alter table WRH$_SQLSTAT add (io_interconnect_bytes_total      NUMBER);
alter table WRH$_SQLSTAT add (io_interconnect_bytes_delta      NUMBER);
alter table WRH$_SQLSTAT add (physical_read_requests_total     NUMBER);
alter table WRH$_SQLSTAT add (physical_read_requests_delta     NUMBER);
alter table WRH$_SQLSTAT add (physical_read_bytes_total        NUMBER);
alter table WRH$_SQLSTAT add (physical_read_bytes_delta        NUMBER);
alter table WRH$_SQLSTAT add (physical_write_requests_total    NUMBER);
alter table WRH$_SQLSTAT add (physical_write_requests_delta    NUMBER);
alter table WRH$_SQLSTAT add (physical_write_bytes_total       NUMBER);
alter table WRH$_SQLSTAT add (physical_write_bytes_delta       NUMBER);
alter table WRH$_SQLSTAT add (optimized_physical_reads_total   NUMBER);
alter table WRH$_SQLSTAT add (optimized_physical_reads_delta   NUMBER);
alter table WRH$_SQLSTAT add (cell_uncompressed_bytes_total    NUMBER);
alter table WRH$_SQLSTAT add (cell_uncompressed_bytes_delta    NUMBER);
alter table WRH$_SQLSTAT add (io_offload_return_bytes_total    NUMBER);
alter table WRH$_SQLSTAT add (io_offload_return_bytes_delta    NUMBER);

Rem 
Rem Change the primary key for ic device stats (bug 7247999)
Rem 
-- drop key to add new columns - for efficiency reasons, before columns change
alter table WRH$_IC_DEVICE_STATS
  drop constraint WRH$_IC_DEVICE_STATS_PK;

Rem
Rem Change the size of the NAME column for cluster interconnect
Rem
alter table WRH$_CLUSTER_INTERCON modify (NAME    varchar2(256));
alter table WRH$_IC_DEVICE_STATS  modify (IF_NAME varchar2(256));

Rem
Rem IPv6 changes, increase varchar lengths
Rem 
alter table WRH$_CLUSTER_INTERCON modify (IP_ADDRESS varchar2(64));
alter table WRH$_IC_DEVICE_STATS  modify (IP_ADDR    varchar2(64));

-- create key using additional column
alter table WRH$_IC_DEVICE_STATS
  add constraint WRH$_IC_DEVICE_STATS_PK
    PRIMARY KEY (dbid, snap_id, instance_number, if_name, ip_addr)
    using index tablespace SYSAUX;

Rem 
Rem Change the primary key for cluster interconnect (bug 14226622)
Rem 

alter table WRH$_CLUSTER_INTERCON drop primary key drop index
/
alter table WRH$_CLUSTER_INTERCON add
constraint WRH$_CLUSTER_INTERCON_PK primary key
    (dbid, snap_id, instance_number, name, ip_address)
 using index tablespace SYSAUX
/

-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';

Rem
Rem WRH$_ACTIVE_SESSION_HISTORY changes
Rem   - Add columns to ASH
Rem

alter table WRH$_ACTIVE_SESSION_HISTORY add (blocking_inst_id    NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (ecid                VARCHAR2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY add (top_level_call#     NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (machine             VARCHAR2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY add (port                NUMBER);

alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (blocking_inst_id NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (ecid             VARCHAR2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (top_level_call#  NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (machine          VARCHAR2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (port             NUMBER);

Rem stash columns
alter table WRH$_ACTIVE_SESSION_HISTORY add (tm_delta_time             NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (tm_delta_cpu_time         NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (tm_delta_db_time          NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (delta_time                NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (delta_read_io_requests    NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (delta_write_io_requests   NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (delta_read_io_bytes       NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (delta_write_io_bytes      NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (delta_interconnect_io_bytes
                                                                       NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (pga_allocated             NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (temp_space_allocated      NUMBER);

alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (tm_delta_time          NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (tm_delta_cpu_time      NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (tm_delta_db_time       NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (delta_time             NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (delta_read_io_requests NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (delta_write_io_requests 
                                                                       NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (delta_read_io_bytes    NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (delta_write_io_bytes   NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (delta_interconnect_io_bytes
                                                                       NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (pga_allocated          NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (temp_space_allocated   NUMBER);

Rem
Rem WRH$_DB_CACHE_ADVICE changes
Rem   - Add column ESTD_PHYSICAL_READ_TIME
Rem
alter table WRH$_DB_CACHE_ADVICE add (estd_physical_read_time NUMBER);

Rem
Rem IPv6 changes
Rem   - Increase varchar lengths

alter table WRH$_CLUSTER_INTERCON modify ip_address varchar2(64);
alter table WRH$_IC_DEVICE_STATS modify ip_addr varchar2(64);

Rem 
Rem WRH$_WAITCLASSMETRIC_HISTORY changes
Rem

alter table WRH$_WAITCLASSMETRIC_HISTORY add (time_waited_fg number);
alter table WRH$_WAITCLASSMETRIC_HISTORY add (wait_count_fg number);

Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==          (11gR2 = SWRF Version 4)                 ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  upgrade changes.  Place all other AWR upgrade    ==
Rem ==  changes above this.                              ==
Rem =======================================================

BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control SET swrf_version = 4';
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


Rem =================
Rem  End AWR Changes
Rem =================

Rem ==========================================================================
Rem Begin advisor framework changes 
Rem ==========================================================================

Rem WRI$_ADV_SQLT_PLAN_STATS

alter table wri$_adv_sqlt_plan_stats add (io_interconnect_bytes number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n1 number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n2 number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n3 number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n4 number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n5 number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_c1 varchar2(4000))
/

alter table wri$_adv_sqlt_plan_stats add (spare_c2 varchar2(4000))
/

alter table wri$_adv_sqlt_plan_stats add (spare_c3 clob)
/

alter table wri$_adv_sqlt_plan_stats add (testexec_total_execs number)
/

alter table wri$_adv_sqlt_plan_stats add (flags number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n6 number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n7 number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n8 number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n9 number)
/

alter table wri$_adv_sqlt_plan_stats add (spare_n10 number)
/


Rem add columns to adv plan hash 
alter table sys.wri$_adv_sqlt_plan_hash add (spare_n1 number)
/

alter table sys.wri$_adv_sqlt_plan_hash add (spare_n2 number)
/

alter table sys.wri$_adv_sqlt_plan_hash add (spare_n3 number)
/

alter table sys.wri$_adv_sqlt_plan_hash add (spare_n4 number)
/

alter table sys.wri$_adv_sqlt_plan_hash add (spare_n5 number)
/

alter table sys.wri$_adv_sqlt_plan_hash add (spare_c1 varchar2(4000))
/

alter table sys.wri$_adv_sqlt_plan_hash add (spare_c2 varchar2(4000))
/


Rem add columns to addm table
alter table wri$_adv_addm_fdg add (query_type number)
/

alter table wri$_adv_addm_fdg add (query_is_approx char(1))
/

alter table wri$_adv_addm_fdg add (query_args varchar2(4000))
/


Rem #8618452: add columns for advisor feature usage
Rem these come before we re-create the table and create the PK because
Rem the data may already be there (10.2.0.5 upgrade case)
Rem
alter table wri$_adv_usage add(num_db_reports number default 0 not null)
/

alter table wri$_adv_usage add(first_report_time date)
/

alter table wri$_adv_usage add(last_report_time date)
/

Rem fix wri$_adv_usage to have proper primary key constraint
Rem dynamic sql to avoid errors during 9i upgrade
begin
  execute immediate
    'create table wri$_adv_usage_tmp as 
       select advisor_id, last_exec_time, num_execs, 
              num_db_reports, first_report_time, last_report_time 
       from (select u.*, 
                    row_number() over (partition by advisor_id 
                                       order by num_execs desc) rn 
             from wri$_adv_usage u) 
       where rn = 1';

  execute immediate 'truncate table wri$_adv_usage';

  execute immediate 
    'insert into wri$_adv_usage(advisor_id, last_exec_time, num_execs,
                                num_db_reports, first_report_time, 
                                last_report_time)
        select advisor_id, last_exec_time, num_execs,
               num_db_reports, first_report_time, last_report_time
        from   wri$_adv_usage_tmp';

  commit;

  execute immediate 'drop table wri$_adv_usage_tmp';

exception
  when others then
    if (sqlcode = -942) then  -- ORA-942 during 9i upgrade
      null;
    else
      raise;
    end if;
end;
/

begin
  execute immediate 
    'alter table wri$_adv_usage add constraint
     wri$_adv_usage_pk primary key(advisor_id)
     using index tablespace sysaux';

exception
  when others then
    if (sqlcode = -2260) then  -- re-upgrade case: pk exists already
      null;
    else
      raise;  
    end if;
end;
/

Rem spare cols in wri$_adv_objects
alter table wri$_adv_objects add(spare_n1 number)
/

alter table wri$_adv_objects add(spare_n2 number)
/

alter table wri$_adv_objects add(spare_n3 number)
/

alter table wri$_adv_objects add(spare_n4 number)
/

alter table wri$_adv_objects add(spare_c1 varchar2(4000))
/

alter table wri$_adv_objects add(spare_c2 varchar2(4000))
/

alter table wri$_adv_objects add(spare_c3 varchar2(4000))
/

alter table wri$_adv_objects add(spare_c4 varchar2(4000))
/


Rem ==========================================================================
Rem End advisor framework changes 
Rem ==========================================================================

Rem ==========================================================================
Rem Begin advisor framework / SPA changes
Rem ==========================================================================
Rem 
Rem In 11.1.0.7 we extended SPA to use it to test CELL storage and remote test 
Rem execute SQL. 
Rem We have added two new task parameters called DATABASE_LINK and  
Rem CELL_SIMULATION_ENABLED and this is a reason we need to upgrade existing 
Rem SPA's tasks.
Rem In 11.2 we added (03) three new task parameters to fix convert STS
Rem task execution when comparing two STSs. 
Rem A forth parameter has also been added to disable/enable SPA multi-exec. 
Rem 
Rem Note that we do not need to upgade task executions. Task executions inherit
Rem task parameters and values from the task itself. 

BEGIN
  -- add new parameters to existing tasks. Note that the definition 
  -- of these two parameters will be added later during upgrade 
  -- when dbms_advisor.setup_repository is called. 
  -- Also note that parameter DATABASE_LINK might exist for some 
  -- tasks if they were created using 11.1.0.6 + one-off for remote 
  -- test-execute
  -- Same for cell_simulation_enabled if we are upgrading from 11.1.0.7
  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'DATABASE_LINK', 'UNUSED', 2,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'DATABASE_LINK')
        UNION ALL 
        SELECT t.id, 'CELL_SIMULATION_ENABLED', 'FALSE', 2, 8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'CELL_SIMULATION_ENABLED')
        UNION ALL 
        SELECT t.id, 'SQLSET_NAME', 'UNUSED', 2,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'SQLSET_NAME')
        UNION ALL 
        SELECT t.id, 'SQLSET_OWNER', 'UNUSED', 2,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer'  AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'SQLSET_OWNER')
        UNION ALL 
        SELECT t.id, '_SQLSET_REFERENCE', 'UNUSED', 2,  9 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = '_SQLSET_REFERENCE')
        UNION ALL 
        SELECT t.id, 'METRIC_DELTA_THRESHOLD', '0', 1,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'METRIC_DELTA_THRESHOLD')
        UNION ALL
        SELECT t.id, 'DISABLE_MULTI_EXEC', 'FALSE', 2,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'DISABLE_MULTI_EXEC'))#';

  -- handle exception when upgrading from 9i. The advisor tables do not exist
  EXCEPTION 
    WHEN OTHERS THEN
      IF SQLCODE = -942 
        THEN NULL;
      ELSE
        RAISE;
      END IF;
END;
/

Rem =======================================================================
Rem End advisor framework / SPA changes 
Rem =======================================================================




Rem =======================================================================
Rem Revoke grants not needed in 10.2.*
Rem =======================================================================

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DBMS_PLUGTSP FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON sys.dbms_ias_session FROM PUBLIC';

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON sys.dbms_ias_query FROM PUBLIC';

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON sys.dbms_ias_configure FROM EXECUTE_CATALOG_ROLE';

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON sys.dbms_ias_template FROM EXECUTE_CATALOG_ROLE';

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
 
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON sys.dbms_ias_template_internal FROM EXECUTE_CATALOG_ROLE';

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON sys.dbms_ias_mt_inst FROM EXECUTE_CATALOG_ROLE';

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON sys.dbms_ias_inst FROM EXECUTE_CATALOG_ROLE';

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON sys.dbms_ias_inst_utl_exp FROM EXP_FULL_DATABASE';

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE UNDER ON SYS.URITYPE FROM PUBLIC FORCE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem =======================================================================
Rem Revoke grants no longer granted with the grant option
Rem =======================================================================

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DBMS_JOB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DBMS_SCHEDULER FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DBMS_SCHED_JOB_EXPORT FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE ON SYS.DBMS_SCHED_PROGRAM_EXPORT FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE ON SYS.DBMS_SCHED_SCHEDULE_EXPORT FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE ON SYS.DBMS_SCHED_CLASS_EXPORT FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE ON SYS.DBMS_SCHED_WINDOW_EXPORT FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE ON SYS.DBMS_SCHED_WINGRP_EXPORT FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE ON SYS.DBMS_SCHED_CHAIN_EXPORT FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE ON SYS.DBMS_SCHED_CREDENTIAL_EXPORT FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE
    'REVOKE EXECUTE ON SYS.DBMS_SCHED_EXPORT_CALLOUTS FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem =======================================================================
Rem  Begin Changes for Database Replay 
Rem =======================================================================

Rem
Rem Add a column call_time at SCN_ORDER table
Rem
alter table WRR$_REPLAY_SCN_ORDER add (call_time number);

Rem
Rem Add a column rep_dir_id to WRR$_REPLAYS table
Rem
alter table WRR$_REPLAYS add (replay_dir_number   NUMBER);

Rem
Rem Add a column unique_id to WRR$_CAPTURES table
Rem
alter table WRR$_CAPTURES add (workload_id    VARCHAR2(40));

Rem
Rem Add columns sql_phase and sql_exec_call_ctr to WRR$_REPLAY_DIVERGENCE
Rem
alter table WRR$_REPLAY_DIVERGENCE add (sql_phase number);
alter table WRR$_REPLAY_DIVERGENCE add (sql_exec_call_ctr number);

Rem
Rem Add column time_paused to WRR$_REPLAY_STATS
Rem
alter table WRR$_REPLAY_STATS add (time_paused number);


Rem 
Rem Add WRR$_REPLAY_DATA
Rem 
Rem

create table WRR$_REPLAY_DATA
( file_id     number           not null
 ,call_ctr    number           not null
 ,rank        number           not null
 ,data_type   number           not null
 ,value       raw(255)
 ,constraint  WRR$_REPLAY_DATA_PK primary key
    (file_id, call_ctr, rank, data_type)
) organization index
  tablespace SYSAUX
/

Rem
Rem Add a column scale_up_multiplier at WRR$_REPLAYS table
Rem
alter table WRR$_REPLAYS add (scale_up_multiplier number default 1 not null);

Rem
Rem Create WRR$_SEQUENCE_EXCEPTIONS
Rem
drop table WRR$_SEQUENCE_EXCEPTIONS;

create table WRR$_SEQUENCE_EXCEPTIONS
( sequence_owner  varchar2(30) not null
 ,sequence_name   varchar2(30) not null
) tablespace SYSAUX;

insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'SQLLOG$_SEQ');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN1$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN2$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN3$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN4$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN5$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN6$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN7$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN8$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN9$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'IDGEN10$');
insert into WRR$_SEQUENCE_EXCEPTIONS values ('SYS', 'AQ$_IOTENQTXID');
commit;

Rem
Rem Add a column divergence_details_status to WRR$_REPLAYS table
Rem
alter table WRR$_REPLAYS add (divergence_details_status VARCHAR2(40));

Rem
Rem Add a column replay_type to distinguish between AS and DB replays
Rem
alter table WRR$_REPLAYS add (replay_type varchar2(10) default 'DB');

Rem
Rem Add columns for ECIDs
Rem
alter table WRR$_REPLAY_SCN_ORDER add (ecid varchar2(100));
alter table WRR$_REPLAY_SCN_ORDER add (ecid_hash number);

Rem =======================================================================
Rem  End Changes for Database Replay 
Rem =======================================================================
Rem =================
Rem  Begin AQ changes
Rem =================

-- Bug fix of 6488226
ALTER TYPE sys.aq$_subscriber 
  ADD ATTRIBUTE(rule_name VARCHAR2(30))
  CASCADE
/ 

ALTER TABLE AQ$_SUBSCRIBER_TABLE ADD (scn_at_add NUMBER)
/

ALTER TABLE AQ$_SUBSCRIBER_TABLE ADD (client_session_guid VARCHAR2(36))
/

ALTER TABLE AQ$_SUBSCRIBER_TABLE ADD (instance_id NUMBER)
/

--Create a Global context to maintain a JM session to DB session relation
--for AQJMS non-durable subscribers
CREATE OR REPLACE CONTEXT global_aqclntdb_ctx USING dbms_aqjms ACCESSED GLOBALLY
/

-- Creating a sequence for non-durable subscriber names
CREATE SEQUENCE sys.aq$_nondursub_sequence INCREMENT BY 1 START WITH 1
/

Rem
Rem Add STATE column to sys.REG$ table
Rem
alter table sys.REG$ add (state NUMBER DEFAULT 0);

Rem =================
Rem  End AQ changes
Rem =================

Rem =========================
Rem  Begin Scheduler changes
Rem =========================

-- Add file watcher related columns to tables

ALTER TABLE sys.scheduler$_job ADD
(fw_name           varchar2(65),
 fw_oid            number,
 dest_oid          number,
 job_dest_id       number,
 run_invoker       number);

ALTER TABLE sys.scheduler$_lightweight_job ADD
(fw_name           varchar2(65),
 fw_oid            number,
 dest_oid          number, 
 destination       varchar2(128),
 credential_name   varchar2(30),
 credential_owner  varchar2(30),
 credential_oid    number,
 job_dest_id       number,
 run_invoker       number
);

ALTER TABLE sys.scheduler$_schedule ADD
(fw_name         varchar2(65));

-- For Scheduler job e-mail notifications we need to add job_subname and
-- job_class_name to the event_info object
ALTER TYPE sys.scheduler$_event_info ADD ATTRIBUTE
  (object_subname varchar2(30), job_class_name varchar2(30)) CASCADE;

-- update the type, the type body will be updated when catproc is run
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
    spare8             RAW DEFAULT NULL)
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
    spare8             RAW DEFAULT NULL,
    object_subname     VARCHAR2 DEFAULT NULL,
    job_class_name     VARCHAR2 DEFAULT NULL)
    RETURN SELF AS RESULT CASCADE;

ALTER TABLE sys.scheduler$_wingrp_member 
DROP CONSTRAINT scheduler$_wingrp_member_pk;

ALTER TABLE sys.scheduler$_wingrp_member ADD
(member_oid2    NUMBER);

ALTER TABLE sys.scheduler$_wingrp_member 
ADD CONSTRAINT scheduler$_wingrp_member_uq UNIQUE 
(oid, member_oid, member_oid2);

ALTER TABLE scheduler$_event_log ADD
(flags        number,
 credential   varchar2(65));

ALTER TABLE scheduler$_job_run_details ADD
(credential  varchar2(65),
 destination varchar2(128));

Rem =======================
Rem  End Scheduler changes
Rem =======================

Rem*************************************************************************
Rem DBMS_AUDIT_MGMT package changes
Rem*************************************************************************
Rem Check where I_AUD1 exists before dropping it

DECLARE
  AUD_SCHEMA     VARCHAR2(32);
BEGIN
   -- First, check where is AUD$ present
   SELECT u.name INTO AUD_SCHEMA FROM obj$ o, user$ u
          WHERE o.name = 'AUD$' AND 
                o.type#=2 AND 
                o.owner# = u.user# AND 
                o.remoteowner is NULL AND
                o.linkname is NULL AND
                u.name IN ('SYS', 'SYSTEM');

   EXECUTE IMMEDIATE 'DROP INDEX ' || AUD_SCHEMA || '.I_AUD1';
END;
/

Rem*************************************************************************
Rem DBMS_AUDIT_MGMT package changes
Rem*************************************************************************


-- BEGIN XS upgrade actions
--

Rem Bug - 5701752 - Drop unique constraint and add unique index
Alter table xs$sessions DROP UNIQUE(COOKIE);
create unique index i_xs$sessions1 on xs$sessions(cookie);

Rem Drop uid column (raw) and create uid (number) and guid (raw)
Alter table xs$sessions drop (userid) ;

Rem bug 8355329 - Add the columns separately to fix the problem when 
Rem re-running the script
Alter table xs$sessions add 
(  userid               number(10)     not null) ;
Alter table xs$sessions add
(  userguid             raw(16)        not null) ;

ALTER TABLE xs$sessions RENAME COLUMN authtimeout TO sessize ;
ALTER TABLE xs$sessions MODIFY (sessize number) ;
ALTER TABLE xs$sessions RENAME COLUMN proxyid TO proxyguid;
ALTER TABLE xs$sessions ADD (proxyid number(10));

ALTER TABLE xs$session_appns add (modtime TIMESTAMP);

-- Create index on sessions table
create unique index xs$sessions_i1 on xs$sessions(sid);
create index xs$session_roles_i1 on xs$session_roles(sid);
create index xs$session_appns_i1 on xs$session_appns(sid);

TRUNCATE TABLE xs$parameters;

ALTER TABLE xs$parameters ADD (
  registration_sequence NUMBER         NOT NULL,
  flags                 NUMBER         NOT NULL
);

DROP TABLE xs$session_hws;

create sequence xsparam_reg_sequence$
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 20
  order
  nocycle;

--
-- END XS upgrade actions
--

Rem =======================================================================
Rem  Begin Changes for Streams
Rem =======================================================================

Rem add columns for apply spill tables
alter table streams$_apply_spill_messages add
(
  position         raw(64),                      /* LCR position for XStream */
  spare7           date,
  spare8           timestamp,
  spare9           raw(100)
);

alter table streams$_apply_spill_msgs_part add
(
  position         raw(64),                      /* LCR position for XStream */
  spare7           date,
  spare8           timestamp,
  spare9           raw(100)
);

alter table streams$_apply_spill_txn add
(
  first_position            raw(64),            /* first position in the txn */
  last_position             raw(64),             /* last position in the txn */
  commit_position           raw(64),          /* commit position for the txn */
  last_message_create_time  date,
  transaction_id            varchar2(128),
  parent_transaction_id     varchar2(128),     /* PDML parent transaction ID */
  spare8                    date,
  spare9                    raw(100)
);

Rem add commit_time and kxid columns to apply$_error
alter table apply$_error add
( 
  commit_time     number,            /* time when txn commited on the source */
  xidusn          number,
  xidslt          number,
  xidsqn          number
);

Rem XStream Servers
create table xstream$_server
(
  server_name       varchar2(30) not null,            /* XStream server name */
  app_src_database  varchar2(128) default null,            /* apply's src db */
  capture_name      varchar2(30) default NULL,               /* capture name */
  cap_src_database  varchar2(128) default null,          /* capture's src db */
  queue_owner       varchar2(30) not null,                    /* queue owner */
  queue_name        varchar2(30) not null,                     /* queue name */
  flags             number,                          /* XStream server flags */
                                                     /* XStream Out   0x0001 */
                                                     /* XStream In    0x0002 */
  user_comment      varchar2(4000),                          /* user comment */
  create_date       timestamp,                /* server's creation timestamp */
  spare1            number,
  spare2            number,
  spare3            number,
  spare4            timestamp,
  spare5            varchar2(4000),
  spare6            varchar2(4000)
)
/
create unique index i_xstream_server1 on
  xstream$_server(server_name)
/
create index i_xstream_server2 on
  xstream$_server(capture_name)
/

Rem Subset rules defined on XStream Servers
create table xstream$_subset_rules
(
  server_name       varchar2(30) not null,            /* XStream server name */
  rules_owner       varchar2(30) not null,                    /* Rules owner */
  insert_rule       varchar2(30) not null,               /* insert rule name */
  delete_rule       varchar2(30) not null,               /* delete rule name */
  update_rule       varchar2(30) not null,               /* update rule name */
  spare1            number,
  spare2            number,
  spare3            number,
  spare4            timestamp,
  spare5            varchar2(4000),
  spare6            varchar2(4000)
)
/
create unique index i_xstream_subset_rules on
  xstream$_subset_rules(server_name, rules_owner, insert_rule, delete_rule,
                        update_rule)
/

Rem System-generated objects for XStream servers
create table xstream$_sysgen_objs
(
  server_name       varchar2(30) not null,            /* XStream server name */
  object_owner      varchar2(30) not null,            /* generated obj owner */
  object_name       varchar2(30) not null,             /* generated obj name */
  object_type       varchar2(30) not null,                    /* object type */
  spare1            number,
  spare2            number,
  spare3            number,
  spare4            timestamp,
  spare5            varchar2(4000),
  spare6            varchar2(4000)
)
/
create index i_xstream_sysgen_objs1 on
  xstream$_sysgen_objs(server_name)
/
create index i_xstream_sysgen_objs2 on
  xstream$_sysgen_objs(object_owner, object_name, object_type)
/

alter table streams$_apply_progress add 
(
  commit_position raw(64),
  transaction_id  varchar2(128) 
)
/

alter table streams$_apply_milestone modify 
(
  oldest_transaction_id varchar2(128)
)
/

alter table streams$_apply_milestone add
(
  oldest_position                raw(64),
  spill_lwm_position             raw(64),
  processed_position             raw(64),
  start_position                 raw(64),
  xout_processed_position        raw(64),
  xout_processed_create_time     date,
  xout_processed_tid             varchar2(128),
  xout_processed_time            date,
  applied_high_position          raw(64),
  oldest_create_time             date,
  spill_lwm_create_time          date,
  spare4                         raw(64),
  spare5                         raw(64),
  spare6                         date,
  spare7                         date
)
/

alter table apply$_error modify 
(
  source_transaction_id varchar2(128)
)
/

alter type lcr$_row_record add member function
   get_thread_number return number cascade;

alter type lcr$_row_record add member function
   get_position return raw cascade;

alter type lcr$_row_record add member procedure
   get_row_text(self in lcr$_row_record,
                row_text in out nocopy clob) cascade;

alter type lcr$_row_record add member procedure 
   get_where_clause (self     IN lcr$_row_record,
                     where_clause IN OUT NOCOPY CLOB) cascade;

alter type lcr$_row_record add member procedure
   get_row_text(self in lcr$_row_record,
                row_text in out nocopy clob,
                variable_list in out nocopy sys.lcr$_row_list,
                bind_var_syntax in varchar2 default ':') cascade;

alter type lcr$_row_record add member procedure
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
     new_values                 in sys.lcr$_row_list DEFAULT NULL
   )  RETURN lcr$_row_record cascade;

alter type lcr$_row_record add static function get_scn_from_position(
     position IN RAW) RETURN NUMBER cascade;

alter type lcr$_row_record add static function get_commit_scn_from_position(
     position IN RAW) RETURN NUMBER cascade;

alter type lcr$_row_record add static function construct(
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

alter type lcr$_ddl_record add member function
   get_thread_number return number cascade;

alter type lcr$_ddl_record add member function
   get_position return raw cascade;

alter type lcr$_ddl_record add static function get_scn_from_position(
     position IN RAW) RETURN NUMBER cascade;

alter type lcr$_ddl_record add static function get_commit_scn_from_position(
     position IN RAW) RETURN NUMBER cascade;

alter type lcr$_ddl_record add member function
   get_edition_name return varchar2 cascade;

alter type lcr$_ddl_record add member procedure
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
     scn                        in number            DEFAULT NULL
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
     scn                        in number            DEFAULT NULL,
     position                   in raw               DEFAULT NULL,
     edition_name               in varchar2          DEFAULT NULL
   )
   RETURN lcr$_ddl_record cascade;

Rem Drop unused position views
drop view "_DBA_APPLY_PROGRESS_POSITION";
drop public synonym "_DBA_APPLY_PROGRESS_POSITION";

drop view "_ALL_APPLY_PROGRESS_POSITION";
drop public synonym "_ALL_APPLY_PROGRESS_POSITION";

drop view "_DBA_APPLY_ERROR_POSITION";
drop public synonym "_DBA_APPLY_ERROR_POSITION";

drop view "_ALL_APPLY_ERROR_POSITION";
drop public synonym "_ALL_APPLY_ERROR_POSITION";


Rem add error_date, error_msg, unschedule_time, seqnum
Rem to streams$_propagation_process
alter table sys.streams$_propagation_process add
(
  error_date                   date,          /* the time last error occured */
  error_msg                    varchar2(4000),         /* last error message */
  unschedule_time              DATE   DEFAULT NULL, /* time when unscheduled */
  seqnum                       number,             /* unique sequence number */
  spare3                       number,
  spare4                       number,
  spare5                       date,
  spare6                       date,
  spare7                       varchar2(4000),
  spare8                       varchar2(4000)  
);

Rem squence for streams$_propagation_process.seqnum
create sequence streams$_propagation_seqnum
 start with     1
 increment by   1
 nocache
 nocycle
/

Rem --------------- begin of auto_split_merge related tables ------------------
-- tabel for dba_streams_slit_merge view
create table streams$_split_merge
(
  original_capture_name  VARCHAR2(30)   not null,    /* the original capture */
  cloned_capture_name    VARCHAR2(30)   default null,  /* the cloned capture */
  original_queue_owner   varchar2(30)   default null,
  original_queue_name    varchar2(30)   default null, 
  cloned_queue_owner     varchar2(30)   default null, 
  cloned_queue_name      varchar2(30)   default null,
  streams_type           number         default null,
                                             /* propagation (1) or apply (2) */
  original_streams_name  varchar2(30)   default null,
                                 /* original propagation or local apply name */
  cloned_streams_name    varchar2(30)   default null,   
                                   /* cloned propagation or local apply name */
  recoverable_script_id  RAW(16)        default null,
                       /* unique oid of the script to split or merge streams */
  action_type            number         default null,   
            /* type of action performed on this streams (1:split or 2:merge) */
  action_threshold       NUMBER         default null,          
                    /* value of auto_split_threshold or auto_merge_threshold */
  active                 number         default null,    
                                       /* whether there is a job on this row */
  status                 number         default null,  
                                                        /* status of streams */
  status_update_time     timestamp      default null,
                                        /* time when status was last updated */
  creation_time          timestamp      default systimestamp,  
                                             /* time when the row is created */
  job_owner              varchar2(30)   default null,
  job_name               VARCHAR2(30)   default null,  
                                /* name of the job to split or merge streams */
  schedule_owner         varchar2(30)   default null,
  schedule_name          VARCHAR2(30)   default null,
                   /* name of the schedule to run split or merge streams job */
  lag                    NUMBER         default null,      
                        /* specifies the time in seconds that cloned capture */
                                             /* lags behind original capture */
  error_number           number         default null,
                                             /* error number reported if any */
  error_message          varchar2(4000) default null,/* explanation of error */
  spare1                 number         default null,              /* unused */
  spare2                 number         default null,              /* unused */
  spare3                 number         default null,              /* unused */
  spare4                 number         default null,              /* unused */
  spare5                 varchar2(4000) default null,              /* unused */
  spare6                 varchar2(4000) default null,              /* unused */
  spare7                 varchar2(4000) default null,              /* unused */
  spare8                 varchar2(4000) default null,              /* unused */
  spare9                 date           default null,              /* unused */
  spare10                date           default null,              /* unused */
  spare11                date           default null,              /* unused */
  spare12                date           default null,              /* unused */
  spare13                timestamp      default null,              /* unused */
  spare14                timestamp      default null,              /* unused */
  spare15                timestamp      default null,              /* unused */
  spare16                timestamp      default null               /* unused */
)
/

create unique index i_streams_split_merge on streams$_split_merge
 (original_capture_name, cloned_capture_name, job_name, job_owner)
/

create sequence streams$_cap_sub_inst  
                                  /* capture subscriber instantiation number */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295                           /* max portable value of UB4 */
  cycle
  nocache
/

create table streams$_capture_server
(
  QUEUE_SCHEMA               VARCHAR2(30),
  QUEUE_NAME                 VARCHAR2(30),
  DST_QUEUE_SCHEMA           VARCHAR2(30),
  DST_QUEUE_NAME             VARCHAR2(30),
  STARTUP_TIME               DATE,
  DBLINK                     VARCHAR2(128),
  STATUS                     VARCHAR2(30),
  TOTAL_MSGS                 NUMBER,
  TOTAL_BYTES                NUMBER,
  LAST_LCR_CREATION_TIME     DATE default null,
  LAST_LCR_PROPAGATION_TIME  DATE,
  DST_DATABASE_NAME          VARCHAR2(128),
  SESSION_ID                 NUMBER,
  SERIAL#                    NUMBER,
  SPID                       VARCHAR2(30),
  PROPAGATION_NAME           VARCHAR2(30) default null,
  CAPTURE_NAME               VARCHAR2(30) default null,
  APPLY_NAME                 VARCHAR2(30) default null,
  APPLY_OBJ#                 NUMBER default 0,
  FIRST_APPLIED_SCN          NUMBER default 0,
  INACTIVE_TIME              DATE DEFAULT NULL,
  SUB_NUM                    NUMBER default 0,
  SPARE1                     NUMBER,
  SPARE2                     NUMBER,
  SPARE3                     VARCHAR2(4000),
  SPARE4                     VARCHAR2(4000),
  SPARE5                     DATE,
  SPARE6                     DATE
)
/

create unique index i_streams_capture_server on streams$_capture_server
  (capture_name, PROPAGATION_NAME, APPLY_NAME)
/

Rem  Move capture process flags to new positions.
declare
  SCRIPT_VER        constant binary_integer := 11;
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
  select substr( version, 1, instr(version,'.')-1 ) into lowver
    from registry$ where cid='CATPROC';
  select substr( version, 1, instr(version,'.')-1 ) into highver
    from v$instance;

  if lowver = 9 and highver = 10 then
    if SCRIPT_VER = 10 then
      -- clear the other bits
      update streams$_capture_process
              set flags = bitand( flags, COMMON_BITS_09_10 );
      commit;
    end if;

  elsif lowver = 9 and highver >= 11 then
    if SCRIPT_VER = 11 then
      for r in (select flags, rowid from streams$_capture_process) loop
        clone      := bitand( r.flags, CLONE_09      ) > 0;
        sess_audit := bitand( r.flags, SESS_AUDIT_09 ) > 0;
        r.flags    := bitand( r.flags, COMMON_BITS_09_11 );
        if clone then
          r.flags := r.flags + CLONE_11;
        end if;
        if sess_audit then
          r.flags := r.flags + SESS_AUDIT_11;
        end if;
        if clone or sess_audit then
          -- set the two bits
          update streams$_capture_process
                  set flags = r.flags where rowid = r.rowid;
        end if;
      end loop;
      commit;
    end if;

  elsif lowver = 10 and highver >= 11 then
    if SCRIPT_VER = 11 then
      for r in (select flags, rowid from streams$_capture_process) loop
        sess_audit     := bitand( r.flags, SESS_AUDIT_10     ) > 0;
        sess_attr_free := bitand( r.flags, SESS_ATTR_FREE_10 ) > 0;
        r.flags        := bitand( r.flags, COMMON_BITS_10_11 );
        if sess_audit then
          r.flags := r.flags + SESS_AUDIT_11;
        end if;
        if sess_attr_free then
          r.flags := r.flags + SESS_ATTR_FREE_11;
        end if;
        if sess_audit or sess_attr_free then
          -- set the two bits
          update streams$_capture_process
                  set flags = r.flags where rowid = r.rowid;
        end if;
      end loop;
      commit;
    end if;

  end if;
end;
/

Rem --------------- end of auto_split_merge related tables --------------------

Rem ---- begin: change comparison_scan$ table to improve query          -------
Rem ----        performance on dba/user_comparison_scan(_summary) views -------

Rem In comparison_scan$ table, use spare1 for current_dif_count, spare2 for
Rem initial_dif_count and spare3 for root_scan_id
Rem If spare3 of a root scan is not null, then stop undating its tree of scans.

DECLARE
  TYPE scan_typ IS RECORD (
    cmp_id      comparison_scan$.comparison_id%TYPE,
    scan_id     comparison_scan$.scan_id%TYPE,
    row_id      rowid,  --rowid in comparison_scan$ table
    p_ind       NUMBER, --index of parent in array of scan tree nodes
    cur_count   NUMBER, --current dif count
    ini_count   NUMBER, --initial dif count
    expanded    VARCHAR(1)--whether the node has been expanded to find children
  );

  TYPE scan_tree      IS TABLE OF scan_typ;
  TYPE rowid_set      IS TABLE OF rowid;
  TYPE scan_id_set    IS TABLE OF comparison_scan$.scan_id%TYPE;
  TYPE cmp_id_set     IS TABLE OF comparison_scan$.comparison_id%TYPE;

  -- rowids, comparison_ids and scan_ids of all root scans
  root_rowid_set      rowid_set   := rowid_set();
  root_cmp_id_set     cmp_id_set  := cmp_id_set();
  root_scan_id_set    scan_id_set := scan_id_set();

  --we do each scan tree at a time and commit;
  -- each tree is processed in a DFS style.
  -- in each loop, get the scan at the end of the array.
  -- (1) if it is not expanded, expand it and add all its children to end of 
  --     the array.  If it is a leaf, set its dif count.
  -- (2) if it is expanded, since it is at the end of array, all its children
  --     have been processed.  So, update its parent in array, update itself
  --     in comparison_scan$ table, and remove from array.
  tree                scan_tree   := scan_tree();
  child_tree          scan_tree   := scan_tree();  -- all children of a scan
  tree_size           NUMBER;
  scan                scan_typ;

  --each time, extend a bulk to tree to avoid frequent extension
  bulk_size  CONSTANT NUMBER := 100;

BEGIN
  COMMIT;

  -- get all roots that are not processed yet.
  SELECT rowid, comparison_id, scan_id
    BULK COLLECT INTO root_rowid_set, root_cmp_id_set, root_scan_id_set
    FROM comparison_scan$
   WHERE parent_scan_id IS NULL
     AND spare3 IS NULL;

  -- loop for every tree
  FOR r in 1..root_rowid_set.count LOOP

    --initialize tree
    child_tree.delete;
    tree_size := 1;
    IF tree.count < tree_size THEN
      tree.extend(bulk_size);
    END IF;

    --insert root into tree array
    tree(tree_size).row_id    := root_rowid_set(r);
    tree(tree_size).cmp_id    := root_cmp_id_set(r);
    tree(tree_size).scan_id   := root_scan_id_set(r);
    tree(tree_size).p_ind     := 0;  -- 0 means no parent
    tree(tree_size).cur_count := 0;
    tree(tree_size).ini_count := 0;
    tree(tree_size).expanded  := 'N';

    -- loop for all scans in tree
    WHILE tree_size > 0 LOOP

      -- if the scan is not expanded yet, find all its children and put them
      -- into scan tree array
      IF tree(tree_size).expanded = 'N' THEN
        BEGIN
          SELECT comparison_id, scan_id, rowid, tree_size, 0, 0, 'N'
            BULK COLLECT INTO child_tree
            FROM comparison_scan$
           WHERE parent_scan_id = tree(tree_size).scan_id
             AND comparison_id  = tree(tree_size).cmp_id;
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            NULL;
          WHEN OTHERS THEN
            RAISE;
        END;

        tree(tree_size).expanded := 'Y';

        -- if found children, put them into end of array.
        IF child_tree.count > 0 THEN
          --extend array if necessary
          IF tree_size + child_tree.count > tree.count THEN
            tree.extend(bulk_size + tree_size + child_tree.count - tree.count);
          END If;

          --append children
          FOR i in 1..child_tree.count LOOP
            tree(tree_size + i) := child_tree(i);
          END LOOP;

          tree_size := tree_size + child_tree.count;

        -- if leaf, set its count
        ELSE
          SELECT NVL(SUM(DECODE(status, 2, 1, 0)),0), count(1)
            INTO tree(tree_size).cur_count, tree(tree_size).ini_count
            FROM comparison_row_dif$ crd
           WHERE crd.comparison_id = tree(tree_size).cmp_id
             AND crd.scan_id       = tree(tree_size).scan_id;
        END IF;
  
      -- if expanded, and since it is the last one,all children were processed
      -- so update its parent, update itself in table, and remove itself
      ELSE
        --update parent in array
        IF tree(tree_size).p_ind != 0 THEN
          tree(tree(tree_size).p_ind).cur_count :=
            tree(tree(tree_size).p_ind).cur_count + tree(tree_size).cur_count;
          tree(tree(tree_size).p_ind).ini_count :=
            tree(tree(tree_size).p_ind).ini_count + tree(tree_size).ini_count;
        END IF;

        --update itself in table
        UPDATE comparison_scan$
           SET spare1 = tree(tree_size).cur_count,
               spare2 = tree(tree_size).ini_count,
               spare3 = root_scan_id_set(r)
         WHERE rowid = tree(tree_size).row_id;

        -- remove itself from array
        tree_size := tree_size - 1;
      END IF;
               
    END LOOP;

    COMMIT;
  END LOOP;

EXCEPTION WHEN OTHERS THEN
  dbms_logrep_util.dump_trace(dbms_utility.format_error_stack, FALSE);
  dbms_logrep_util.dump_trace('root scans (' || root_rowid_set.count || '):',
                              FALSE);
  FOR i in 1..root_rowid_set.count LOOP
    dbms_logrep_util.dump_trace('  ' || i || ': c_id: ' || root_cmp_id_set(i)||
                         ', s_id: '  || root_scan_id_set(i) ||
                         ', rowid: ' || root_rowid_set(i), FALSE);
  END LOOP;

  dbms_logrep_util.dump_trace('scan tree (size = ' || tree_size ||
                              ',count = ' || tree.count || '):', FALSE);
  FOR i in 1..tree.count LOOP
    dbms_logrep_util.dump_trace('  ' || i || ': c_id: ' || tree(i).cmp_id ||
                         ', s_id: '      || tree(i).scan_id   ||
                         ', p_ind: '     || tree(i).p_ind     ||
                         ', cur_count: ' || tree(i).cur_count ||
                         ', ini_count: ' || tree(i).ini_count ||
                         ', rowid: '     || tree(i).row_id    ||
                         ', expanded: '  || tree(i).expanded, FALSE);
  END LOOP;

  ROLLBACK;
  RAISE;
END;
/


--add columns to comparison_scan$
ALTER TABLE comparison_scan$
  ADD (spare5 NUMBER, spare6 NUMBER, spare7 NUMBER, spare8 TIMESTAMP);

Rem ---- end: change of comparison_scan$ table --------------------------------

ALTER TABLE apply$_dest_obj_ops ADD (handler_name varchar2(30));

drop index i_apply_dest_obj_ops1;

create unique index i_apply_dest_obj_ops1 on apply$_dest_obj_ops
 (sname, oname, apply_operation, apply_name, handler_name)
/

Rem generate unique id for streams stmt handlers
create sequence streams$_stmt_handler_seq start with 1 increment by 1
/

create table streams$_stmt_handlers
(
  handler_id          number not null,                         /* handler id */
  handler_name        varchar2(30) not null,                 /* handler name */
  handler_comment     varchar2(4000) default null,        /* handler comment */
  handler_flag        raw(4) default '00000000',             /* handler flag */
  creation_time       timestamp,      /* time when the statement was created */
  modification_time   timestamp,     /* time when the statement was modified */
  spare1              number,
  spare2              number,
  spare3              varchar2(4000),
  spare4              timestamp,
  spare5              raw(2000)
)
/

create unique index i_streams_stmt_handlers on streams$_stmt_handlers
 (handler_name)
/

create unique index i_streams_stmt_handler_ids on streams$_stmt_handlers
 (handler_id)
/

rem streams handler stmts
create table streams$_stmt_handler_stmts
(
  handler_id          number not null,                       /* handler name */
  statement           clob,                                     /* statement */
  statement_type      number not null,                  /* type of statement */
  execution_sequence  number not null,    /* execution sequence of statement */
  creation_time       timestamp,      /* time when the statement was created */
  modification_time   timestamp,     /* time when the statement was modified */
  spare1              number,
  spare2              number,
  spare3              varchar2(4000),
  spare4              varchar2(4000),
  spare5              timestamp,
  spare6              raw(2000)
)
/
create unique index i_streams_stmt_handler_stmts on streams$_stmt_handler_stmts
 (handler_id, execution_sequence)
/

rem apply change handler
create table apply$_change_handlers (
  change_table_owner  varchar2(30),
  change_table_name   varchar2(30),
  source_table_owner  varchar2(30),
  source_table_name   varchar2(30),
  handler_name        varchar2(30),
  capture_values      number,
  apply_name          varchar2(30),
  operation           number,
  creation_time       timestamp,
  modification_time   timestamp,
  spare1              number,
  spare2              number,
  spare3              varchar2(4000),
  spare4              varchar2(4000),
  spare5              timestamp,
  spare6              timestamp,
  spare7              raw(2000)
)
/
create unique index i_apply_change_handlers on apply$_change_handlers
 (change_table_owner, change_table_name, source_table_owner,
  source_table_name, handler_name, apply_name, operation)
/
Rem =======================================================================
Rem  End Changes for Streams
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for Logminer
Rem =======================================================================

alter sequence system.logmnr_evolve_seq$ nocache;

alter sequence system.logmnr_seq$ nocache;

alter sequence system.logmnr_uids$ nocache;

alter table system.logmnr_age_spill$ modify (chunk number);

-- recreate logmnr_spill$ table
DROP TABLE SYSTEM.logmnr_spill$ PURGE;

CREATE TABLE SYSTEM.logmnr_spill$ (
                session#     number,
                xidusn       number,
                xidslt       number,
                xidsqn       number,
                chunk        number,
                startidx     number,
                endidx       number,
                flag         number,  
                sequence#    number,
                spill_data   blob,
                spare1     number,
                spare2     number,
                CONSTRAINT LOGMNR_SPILL$_PK PRIMARY KEY
                 (session#, xidusn, xidslt, xidsqn, chunk, 
                  startidx, endidx, flag, sequence#)
                  USING INDEX TABLESPACE SYSAUX LOGGING)
            LOB (spill_data)
              STORE AS (TABLESPACE SYSAUX CACHE LOGGING PCTVERSION 0
                        CHUNK 16k STORAGE (INITIAL 16K NEXT 16K))
            TABLESPACE SYSAUX LOGGING
/

Rem Update session attributes for logical standby sessions.
update system.logmnr_session$
  set session_attr = session_attr + 4
  where client# = 2
    and bitand(session_attr, 4) = 0;

commit;

CREATE GLOBAL TEMPORARY TABLE system.logmnr_gt_xid_include$ (
		xidusn   number,
		xidslt   number,
		xidsqn   number
        	) on commit preserve rows;

CREATE TABLE SYSTEM.LOGMNR_SESSION_ACTIONS$ (
                /* Non Initial Attributes  */
                FlagsRunTime     number default 0, /* FLAGSM_SET_KRVUSA */
                DropSCN          number,
                ModifyTime       timestamp,
                DispatchTime     timestamp,
                DropTime         timestamp,
                LCRCount         number default 0,
                /* Initial Attibutes        */
                ActionName       varchar2(30) NOT NULL,
                LogmnrSession#   number NOT NULL,
                ProcessRole#     number NOT NULL,
                ActionType#      number NOT NULL,
                FlagsDefineTime  number,
                CreateTime       timestamp,
                XIDusn           number,
                XIDslt           number,
                XIDsqn           number,
                Thread#          number,
                StartSCN         number,
                StartSubSCN      number,
                EndSCN           number,
                EndSubSCN        number,
                RBAsqn           number,
                RBAblk           number,
                RBAbyte          number,
                Session#         number,
                Obj#             number,
                attr1            number,
                attr2            number,
                attr3            number,
                spare1           number,
                spare2           number,
                spare3           timestamp,
                spare4           varchar2(2000),
              CONSTRAINT LOGMNR_SESSION_ACTION$_PK
                PRIMARY KEY (LogmnrSession#, ActionName)
                USING INDEX TABLESPACE SYSAUX LOGGING enable)
            TABLESPACE SYSAUX LOGGING
/
Rem =======================================================================
Rem  End Changes for Logminer
Rem =======================================================================


Rem =======================================================================
Rem  Begin Changes for Logical Standby
Rem =======================================================================

declare
  local_ts timestamp := systimestamp;
begin
  update system.logstdby$events
     set event_time = local_ts
   where event_time is null;
  if SQL%ROWCOUNT > 0 then
    insert into system.logstdby$events (event_time, event) values
       (local_ts, 'NULL event_time values updated during upgrade.');
  end if;
  commit;
end;
/

alter table system.logstdby$events modify (event_time timestamp not null);

Rem =======================================================================
Rem  End Changes for Logical Standby
Rem =======================================================================


Rem =======================================================================
Rem Revoke grants not needed 
Rem =======================================================================

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DBMS_RWEQUIV_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DBMS_XMV_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DBMS_XRW_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/


Rem*************************************************************************
Rem BEGIN Changes for HS
Rem*************************************************************************

BEGIN
   EXECUTE IMMEDIATE 'REVOKE all ON SYS.hs_bulk_seq FROM PUBLIC';
   EXECUTE IMMEDIATE 'GRANT select ON SYS.hs_bulk_seq to PUBLIC';
   EXECUTE IMMEDIATE 'REVOKE all ON SYS.HS_BULKLOAD_VIEW_OBJ FROM PUBLIC';
   EXECUTE IMMEDIATE 'GRANT  select ON SYS.HS_BULKLOAD_VIEW_OBJ to PUBLIC';
   EXECUTE IMMEDIATE 'REVOKE all ON SYS.HS_PARTITION_OBJ FROM PUBLIC';
   EXECUTE IMMEDIATE 'GRANT execute ON SYS.HS_PARTITION_OBJ to PUBLIC';
   EXECUTE IMMEDIATE 'REVOKE all ON SYS.HSBLKValAry FROM PUBLIC';
   EXECUTE IMMEDIATE 'GRANT execute ON SYS.HSBLKValAry to  PUBLIC';
   EXECUTE IMMEDIATE 'REVOKE all ON SYS.HSBLKNamLst FROM PUBLIC';
   EXECUTE IMMEDIATE 'GRANT execute ON SYS.HSBLKNamLst to PUBLIC';
   EXECUTE IMMEDIATE 'REVOKE all ON SYS.HS_PART_OBJ FROM PUBLIC';
   EXECUTE IMMEDIATE 'GRANT execute ON SYS.HS_PART_OBJ to PUBLIC';
   EXECUTE IMMEDIATE 'REVOKE all ON SYS.hs_sample_obj FROM PUBLIC';
   EXECUTE IMMEDIATE 'GRANT execute ON SYS.hs_sample_obj to PUBLIC';
   EXECUTE IMMEDIATE 'REVOKE execute ON SYS.dbms_hs_parallel_metadata FROM PUBLIC';

   
 EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
     ELSE RAISE;
     END IF;
 END;
/ 

Rem =======================================================================
Rem  End Changes for HS
Rem =======================================================================

Rem =======================================================================
Rem Bug 7197834 : lbacsys packages granted exec to public with grant option
Rem =======================================================================

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.LABEL_LIST_TO_CHAR FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.LABEL_LIST_TO_CHAR TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.LABEL_LIST_TO_NAMED_CHAR FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.LABEL_LIST_TO_NAMED_CHAR TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.LBAC_LABEL_TO_CHAR FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.LBAC_LABEL_TO_CHAR TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.NUMERIC_LABEL_TO_CHAR FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.NUMERIC_LABEL_TO_CHAR TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.PRIVS_TO_CHAR FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.PRIVS_TO_CHAR TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.TO_LBAC_LABEL FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.TO_LBAC_LABEL TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.TO_NUMERIC_LABEL FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.TO_NUMERIC_LABEL TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.LBAC_SESSION FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.LBAC_SESSION TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.LBAC_UTL FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.LBAC_UTL TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON LBACSYS.TO_LABEL_LIST FROM PUBLIC';
 EXECUTE IMMEDIATE 'GRANT EXECUTE ON LBACSYS.TO_LABEL_LIST TO PUBLIC';
 EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/


Rem =======================================================================
Rem  Bug 6957265: patch tab$.ts# and tabpart$.ts# for IOTs
Rem =======================================================================

-- set tab$.ts# = 0 for all IOTs
update tab$ set ts# = 0 where bitand(property, 64) = 64 AND ts# != 0;

-- set tabpart$.ts# for IOTs to ts# of the associated primary key index ptn
update tabpart$ tp
  set ts# = (select ip.ts# from tab$ t, indpart$ ip 
               where tp.bo# = t.obj# and t.pctused$ = ip.bo#
                 and ip.part# = tp.part#)
  where tp.ts# = 0
    AND tp.bo# in (select obj# from tab$ where bitand(property, 96) = 96);

Rem =======================================================================
Rem  End Changes for Bug 6957265
Rem =======================================================================

Rem =======================================================================
Rem  Bug 5921164: add policy-owner column (powner#) to fga$
Rem =======================================================================

ALTER TABLE fga$ ADD (powner# NUMBER);

Rem Upgrade existing FGA policies to set powner# = object_owner
UPDATE fga$ f 
  SET f.powner# = (SELECT o.owner# FROM obj$ o WHERE 
                     o.obj# = f.obj# AND
                     o.type# IN (2, 4) AND 
                     o.remoteowner IS NULL AND
                     o.linkname IS NULL)
  WHERE f.powner# IS NULL;

ALTER TABLE fga$ MODIFY (powner# NUMBER NOT NULL);

Rem =======================================================================
Rem  End Changes for Bug 5921164 
Rem =======================================================================
Rem =========================
Rem  Begin DST Patch Changes
Rem =========================

CREATE TABLE dst$affected_tables (
           table_owner VARCHAR2(30) NOT NULL,
           table_name  VARCHAR2(30) NOT NULL,
           column_name VARCHAR2(4000) NOT NULL,
           row_count   NUMBER,
           error_count NUMBER
);

CREATE TABLE dst$error_table (
           table_owner  VARCHAR2(30) NOT NULL,
           table_name   VARCHAR2(30) NOT NULL,
           column_name  VARCHAR2(4000) NOT NULL,
           rid          UROWID,
           error_number NUMBER
);

CREATE TABLE dst$trigger_table (
           trigger_owner  VARCHAR2(30) NOT NULL,
           trigger_name   VARCHAR2(30) NOT NULL
);

Rem =========================
Rem  End DST Patch Changes
Rem =========================

Rem ========================
Rem  Begin OLAP API changes
Rem ========================

Rem ----------------------------------
Rem Rename OLAP API dictionary columns
Rem ----------------------------------

ALTER TABLE olap_descriptions$ RENAME COLUMN spare1 TO description_class;
ALTER TABLE olap_dim_levels$ RENAME COLUMN spare1 TO level_order;
ALTER TABLE olap_hierarchies$ RENAME COLUMN spare1 TO hierarchy_order;
ALTER TABLE olap_attributes$ RENAME COLUMN spare1 TO attribute_order;
ALTER TABLE olap_measures$ RENAME COLUMN spare1 TO measure_order;
ALTER TABLE olap_models$ RENAME COLUMN spare1 TO explicit_dim_id;

Rem ----------------------------------
Rem Create OLAP API dictionary columns
Rem ----------------------------------

alter table olap_cube_dimensions$ add (
  type# number,             /* Data type of the dimension */
  length number,            /* Data type length */
  charsetform number,       /* Charsetform of data type */
  precision# number,        /* Numeric precision of data type */
  scale number,             /* Numeric scale of data type */
  type_property number      /* Data type flags */
);
alter table olap_descriptions$ add (spare1 number);
alter table olap_dim_levels$ add (spare1 number);
alter table olap_hierarchies$ add (spare1 number);

alter table olap_attributes$ add (
  target_attribute# number,  /* Target attribute */
  type_property number,      /* Data type flags */
  spare1 number
);

alter table olap_measures$ add (
  type_property number,     /* Data type flags */
  spare1 number
);

alter table olap_dimensionality$ add (
  owning_diml_id number,    /* ID of owning dim'ality for a breakout dim */
  attribute_id number,      /* ID of attribute for a breakout dim */
  breakout_flags number     /* Numeric field for style of breakout */
);

alter table olap_models$ add (spare1 number);

Rem ----------------------------------
Rem Add OLAP API table export callback
Rem ----------------------------------

delete from exppkgact$ where schema = 'SYS' and package = 'DBMS_CUBE_EXP' 
  and class = 4;
insert into exppkgact$ values('DBMS_CUBE_EXP', 'SYS', 4, 1050);
insert into expdepact$ 
  (select o.obj#, 'DBMS_CUBE_EXP', 'SYS'
     from sys.obj$ o, sys.aw$ a
     where o.name='AW$'||a.awname 
       and o.owner#=a.owner# 
       and o.type#=2
       and o.obj# not in
         (select obj# FROM sys.expdepact$
            where package='DBMS_CUBE_EXP' AND schema='SYS'))
/
commit;

Rem ======================
Rem  End OLAP API changes
Rem ======================


Rem=========================================================================
Rem END STAGE 1: upgrade from 11.1.0 to the current release
Rem=========================================================================

Rem*************************************************************************
Rem BEGIN Changes for Deferred Segment Creation
Rem*************************************************************************

REM Create table deferred_stg$ for deferred segment creation.
REM For objects with deferred segment creation, a row will be inserted
REM into deferred_stg$ instead of seg$. This row will contain storage
REM attributes which will be used during the first insert.

REM Table deferred_stg$ was introduced into 11.1.0.7 because
REM of a bad merge into c1101000.sql. Rather than drop it now 
REM and recreate it, as was done to fix bug 8549808, which resulted
REM in bug 10373381, alter the existing table to add the NULL constraint
REM for cases where this table may already exist. For cases of upgrading 
REM where this table does not already exist, then create it in its proper
REM form.

REM Create the table to cover cases of an upgrade from pre-11.1.0.7
create table deferred_stg$                           /* shadow segment table */
( 
  obj#          number not null,                            /* object number */
  pctfree_stg   number,                                           /* PCTFREE */
  pctused_stg   number,                                           /* PCTUSED */
  size_stg      number,                                              /* SIZE */   
  initial_stg   number,                                           /* INITIAL */
  next_stg      number,                                              /* NEXT */
  minext_stg    number,                                        /* MINEXTENTS */
  maxext_stg    number,                                        /* MAXEXTENTS */
  maxsiz_stg    number,                                           /* MAXSIZE */
  lobret_stg    number,                                      /* LOBRETENTION */
  mintim_stg    number,                                           /* MIN tim */
  pctinc_stg    number,                                       /* PCTINCREASE */
  initra_stg    number,                                          /* INITRANS */
  maxtra_stg    number,                                          /* MAXTRANS */
  optimal_stg   number,                                           /* OPTIMAL */
  maxins_stg    number,                                      /* MAXINSTANCES */
  frlins_stg    number,                                    /* LISTS/instance */
  flags_stg     number,                                             /* flags */
  bfp_stg       number,                                       /* BUFFER_POOL */
  enc_stg       number,                                        /* encryption */
  cmpflag_stg   number,                                  /* compression type */
  cmplvl_stg    number)                                 /* compression level */
/
CREATE UNIQUE INDEX i_deferred_stg1 ON deferred_stg$(obj#)
/

REM
REM Alter the table to its correct structure for upgrades from 11.1.0.7
REM where the table may already exist in the incorrect form.
REM
alter table deferred_stg$ modify (  pctfree_stg   number null);
alter table deferred_stg$ modify (  pctused_stg   number null);
alter table deferred_stg$ modify (  size_stg      number null);
alter table deferred_stg$ modify (  initial_stg   number null);
alter table deferred_stg$ modify (  next_stg      number null);
alter table deferred_stg$ modify (  minext_stg    number null);
alter table deferred_stg$ modify (  maxext_stg    number null);
alter table deferred_stg$ modify (  maxsiz_stg    number null);
alter table deferred_stg$ modify (  lobret_stg    number null);
alter table deferred_stg$ modify (  mintim_stg    number null);
alter table deferred_stg$ modify (  pctinc_stg    number null);
alter table deferred_stg$ modify (  initra_stg    number null);
alter table deferred_stg$ modify (  maxtra_stg    number null);
alter table deferred_stg$ modify (  optimal_stg   number null);
alter table deferred_stg$ modify (  maxins_stg    number null);
alter table deferred_stg$ modify (  frlins_stg    number null);
alter table deferred_stg$ modify (  flags_stg     number null);
alter table deferred_stg$ modify (  bfp_stg       number null);
alter table deferred_stg$ modify (  enc_stg       number null);
alter table deferred_stg$ modify (  cmpflag_stg   number null);
alter table deferred_stg$ modify (  cmplvl_stg    number null);

Rem*************************************************************************
Rem END Changes for Deferred Segment Creation
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for Utilities Feature Tracking
Rem*************************************************************************

alter table sys.ku_utluse 
 add (encryptcnt number default 0, compresscnt number default 0);

Rem*************************************************************************
Rem END Changes for Utilities Feature Tracking
Rem*************************************************************************

Rem =======================================================================
Rem  begin Changes for advisor framework
Rem =======================================================================

alter table WRI$_ADV_SQLT_PLAN_STATS add (testexec_total_execs number);
alter table WRI$_ADV_SQLT_PLAN_STATS add (flags number);

Rem =======================================================================
Rem  End Changes for advisor framework
Rem =======================================================================

Rem*************************************************************************
Rem BEGIN Changes for datapump utility packages
Rem*************************************************************************

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.ORACLE_LOADER FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/ 

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.ORACLE_DATAPUMP FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/ 
Rem*************************************************************************
Rem END Changes for datapump utility packages
Rem*************************************************************************
  
Rem =======================================================================
Rem  Bug 7197860: data mining grants
Rem =======================================================================
  
BEGIN
EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DM_MOD_BUILD FROM PUBLIC'; -- 'with grant option'
EXECUTE IMMEDIATE 'GRANT  EXECUTE ON SYS.DM_MOD_BUILD TO PUBLIC';      -- 'without grant option'
EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DM_NMF_BUILD FROM PUBLIC'; -- 'with grant option'
EXECUTE IMMEDIATE 'GRANT  EXECUTE ON SYS.DM_NMF_BUILD TO PUBLIC';      -- 'without grant option'
EXCEPTION
WHEN OTHERS THEN
  IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
  ELSE RAISE;
  END IF;
END;
/

Rem =======================================================================
Rem  End Changes for Bug 7197860
Rem =======================================================================  

Rem*************************************************************************
Rem BEGIN Alter sumagg$.expression to VARCHAR2(4000);
Rem*************************************************************************

ALTER TABLE SUMAGG$ MODIFY EXPRESSION VARCHAR2(4000);

Rem*************************************************************************
Rem END Alter sumagg$.expression to VARCHAR2(4000);
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for ALTER DATABASE LINK (bug 6830207)
Rem*************************************************************************

insert into SYSTEM_PRIVILEGE_MAP values (-328,
                                         'ALTER PUBLIC DATABASE LINK', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-329,
                                         'ALTER DATABASE LINK', 0);
insert into STMT_AUDIT_OPTION_MAP values (328,
                                         'ALTER PUBLIC DATABASE LINK', 0);
insert into STMT_AUDIT_OPTION_MAP values (329,
                                         'ALTER DATABASE LINK', 0);
Rem Bug 6856975
insert into STMT_AUDIT_OPTION_MAP values (78,
                                         'ALL STATEMENTS', 0);
commit;

Rem*************************************************************************
Rem END Changes for ALTER DATABASE LINK (bug 6830207)
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for CDC privs
Rem*************************************************************************
BEGIN
 EXECUTE IMMEDIATE 'REVOKE EXECUTE ON sys.dbms_cdc_utility FROM SELECT_CATALOG_ROLE';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

Rem*************************************************************************
Rem END Changes for CDC privs
Rem*************************************************************************

Rem*************************************************************************
Rem BEGIN
Rem   update _sqltune_control parameter
Rem*************************************************************************

Rem set new default value of _sqltune_control for future tasks assuming 
Rem the current value is 15 (def)
BEGIN
  EXECUTE IMMEDIATE
    'UPDATE wri$_adv_def_parameters 
     SET value = ''63'' 
     WHERE name = ''_SQLTUNE_CONTROL'' and advisor_id = 4 and value = ''15''';
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

Rem set new value of _sqltune_control to 63 for sys_auto_sql_tuning_task 
Rem assuming the current value is 15 (def)

BEGIN
  EXECUTE IMMEDIATE
    'UPDATE wri$_adv_parameters
     SET value = ''63''
     WHERE name = ''_SQLTUNE_CONTROL'' and 
           value = ''15'' and 
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


Rem *************************************************************************
Rem BEGIN Changes for dropping TSMSYS schema and DBMS_TSM* packages 
Rem *************************************************************************
DROP INDEX TSMSYS.SRSIDX;
DROP TABLE TSMSYS.SRS$;

DROP PACKAGE DBMS_TSM;
DROP PACKAGE DBMS_TSM_PRVT;
DROP LIBRARY DBMS_TSM_LIB;
Rem *************************************************************************
Rem END Changes for dropping TSMSYS schema and DBMS_TSM* packages 
Rem *************************************************************************

Rem *************************************************************************
Rem Resource Manager related changes - BEGIN
Rem *************************************************************************

alter table resource_plan_directive$ add (
  max_utilization_limit NUMBER
);
update resource_plan_directive$ set
  max_utilization_limit = 4294967295;
commit;

Rem *************************************************************************
Rem Resource Manager related changes - END
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Changes for Flashback Archive (Total Recall)
Rem =======================================================================
ALTER TABLE sys.sys_fba_fa ADD (
  OWNERNAME    varchar2(30)
)
/
Rem =======================================================================
Rem  End Changes for Flashback Archive (Total Recall)
Rem =======================================================================

drop view gv_$standby_apply_snapshot;
drop public synonym gv$standby_apply_snapshot;
drop view v_$standby_apply_snapshot;
drop public synonym v$standby_apply_snapshot;



Rem *************************************************************************
Rem BEGIN Changes for refresh operations of non-updatable replication MVs
Rem *************************************************************************

Rem  Set status of non-updatable replication MVs to regenerate refresh 
Rem  operations
UPDATE sys.snap$ s SET s.status = 0
 WHERE bitand(s.flag, 4096) = 0 AND
       bitand(s.flag, 8192) = 0 AND
       bitand(s.flag, 16384) = 0 AND 
       bitand(s.flag, 2) = 0 AND s.instsite = 0;

Rem  Delete old fast refresh operations for non-updatable replication MVs
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

Rem *************************************************************************
Rem END Changes for refresh operations of non-updatable replication MVs
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for IDGEN sequences
Rem *************************************************************************
DECLARE
  CURSOR idgen_cur IS
    SELECT sequence_owner, sequence_name FROM dba_sequences 
      WHERE sequence_name LIKE 'IDGEN%$' and cache_size=20;
BEGIN
  FOR idgen_seq IN idgen_cur LOOP
    execute immediate 'ALTER SEQUENCE ' || 
      dbms_assert.enquote_name(idgen_seq.sequence_owner, FALSE) || '.' || 
      dbms_assert.enquote_name(idgen_seq.sequence_name, FALSE) || ' CACHE 1000';
  END LOOP;
END;
/
COMMIT;
Rem *************************************************************************
Rem END Changes for IDGEN sequences
Rem *************************************************************************

Rem Add caching to ora_tq_base sequence
alter sequence ora_tq_base$ cache 10000;

Rem*************************************************************************
Rem BEGIN changes for ref partitioning metadata
Rem In 11.2 ref partitioning does not overload the TAB$ flag for
Rem bitmap join indexes.
Rem*************************************************************************

update sys.tab$
  set trigflag = trigflag - 262144
  where bitand(trigflag, 262144) != 0
    and obj# NOT IN (select tab1obj# from jijoin$ UNION ALL
                     select tab2obj# from jijoin$);

Rem*************************************************************************
Rem END changes for ref partitioning metadata
Rem*************************************************************************

Rem *************************************************************************
Rem  7446912: getinfo: parameter change for anytype 
Rem *************************************************************************

Rem Changing the getinfor parameter count to numelems. 

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
       numelems OUT PLS_INTEGER)
                 return PLS_INTEGER,
  MEMBER FUNCTION GetAttrElemInfo (self IN AnyType, pos IN PLS_INTEGER,
       prec OUT PLS_INTEGER, scale OUT PLS_INTEGER,
       len OUT PLS_INTEGER, csid OUT PLS_INTEGER, csfrm OUT PLS_INTEGER,
       attr_elt_type OUT ANYTYPE, aname OUT VARCHAR2) return PLS_INTEGER
);

alter system flush shared_pool;

Rem The REPLACE above will invalidate all dependent objects, except table.
Rem To avoid various difs, we need to recompile a few.
alter type ANYDATA compile reuse settings;
alter type XMLTYPE compile reuse settings;

Rem Ignore compilation errors at this point.
DECLARE
BEGIN
  execute immediate  'alter view ALL_XML_SCHEMAS compile';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/


DECLARE
BEGIN
  execute immediate  'alter package XDB.DBMS_CSX_INT compile reuse settings';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

alter system flush shared_pool;

Rem *************************************************************************
Rem END Changes for anytype
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for Client Result Cache
Rem *************************************************************************
drop public synonym v$client_result_cache_stats;
drop view v_$client_result_cache_stats;
drop public synonym gv$client_result_cache_stats;
drop view gv_$client_result_cache_stats;
drop public synonym client_result_cache_stats$;
Rem Do not drop any view/synonym related to client_result_cache_stats$
Rem as its needed for 11.1. The above drop views are to keep the fixed views
Rem for client result cache as internal.


Rem *************************************************************************
Rem END Changes for Client Result Cache 
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN Changes for CQ Notification
Rem *************************************************************************
create table chnf$_query_dependencies(primarytype NUMBER,
                                      primaryid   NUMBER,
                                      dependencytype NUMBER,
                                      dependentname VARCHAR2(256))
/

create index i1_chnf$_query_deps on chnf$_query_dependencies(dependencytype, dependentname)
/

create index i2_chnf$_query_deps on chnf$_query_dependencies(primarytype, primaryid)
/                                 

Rem *************************************************************************
Rem END  Changes for Change Notification
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN Changes for Stats Related Dictionary Tables
Rem *************************************************************************

drop index i_wri$_optstat_synoppartgrp
/

-- bug 14159402: might contain duplicate values so that unique index
-- fails to create.
truncate table wri$_optstat_synopsis_partgrp;

create unique index i_wri$_optstat_synoppartgrp on 
  wri$_optstat_synopsis_partgrp (obj#)
  tablespace sysaux
/

-- remove duplicate entries
declare
  type numtab is table of number;
  tobjns numtab;
begin
  -- find bo# with duplicate entries
  select distinct bo# bulk collect into tobjns
  from wri$_optstat_synopsis_head$
  group by bo#, group#, intcol#
  having count(*) > 1;

  -- remove these bo# entries from synopsis$
  for i in 1..tobjns.count loop
    execute immediate
    'delete from wri$_optstat_synopsis$
     where synopsis# in (select synopsis# 
                         from wri$_optstat_synopsis_head$
                         where bo# = :tobjn)' using tobjns(i);
  end loop;

  -- remove these bo# entries from synopsis_head$
  forall i in 1..tobjns.count
    delete from wri$_optstat_synopsis_head$
    where bo# = tobjns(i);

exception 
  when others then
    if (sqlcode = -904) then 
      -- hit ORA-904: "S"."SYNOPSIS#": invalid identifier
      -- during reupgrade.
      return;
    else
      raise;
    end if;
end;
/

drop index i_wri$_optstat_synophead 
/

create unique index i_wri$_optstat_synophead on 
  wri$_optstat_synopsis_head$ (bo#, group#, intcol#)
  tablespace sysaux
/

Rem *************************************************************************
Rem END  Changes for Stats Related Dictionary Tables
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes for Advanced Replication
Rem *************************************************************************

drop public synonym temp$lob;
drop table system.def$_temp$lob;

Rem *************************************************************************
Rem END Changes for Advanced Replication
Rem *************************************************************************

      
Rem *************************************************************************
Rem BEGIN: Bug 7829203, Changes required for default_pwd$
Rem *************************************************************************

Rem Create SYS.DEFAULT_PWD$

BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE SYS.DEFAULT_PWD$ (user_name varchar2(128),
                     pwd_verifier varchar2(512),pv_type NUMBER default 0)';
EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE IN ( -00955) THEN NULL; --ignore when table already exists
    DBMS_OUTPUT.PUT_LINE('TABLE SYS.DEFAULT_PWD$ ALREADY EXISTS');
  ELSE RAISE;
  END IF;
END;
/

Rem Created UNIQUE Index ON SYS.DEFAULT_PWD$

BEGIN
  EXECUTE IMMEDIATE ' DELETE FROM default_pwd$ A WHERE a.rowid > ANY 
                      ( SELECT B.rowid FROM default_pwd$ B WHERE
                      A.user_name = B.user_name AND
                      A.pwd_verifier = B.pwd_verifier AND
                      A.pv_type = B.pv_type )'; 
  EXECUTE IMMEDIATE 'CREATE UNIQUE INDEX SYS.i_DEFAULT_PWD ON
                     SYS.DEFAULT_PWD$(user_name,pwd_verifier)';
EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE IN ( -00955) THEN NULL; --ignore when index already exists
    DBMS_OUTPUT.PUT_LINE('INDEX SYS.i_DEFAULT_PWD ALREADY EXISTS');
  ELSE RAISE;
  END IF;
END;
/

Rem Created Procedure for inserting into SYS.DEFAULT_PWD$

CREATE OR REPLACE PROCEDURE insert_into_defpwd
           (tuser_name                IN  VARCHAR2,
            tpwd_verifier             IN  VARCHAR2,
            tpv_type                  IN PLS_INTEGER DEFAULT 0
           )
AUTHID CURRENT_USER
IS
    m_sql_stmt       VARCHAR2(4000);
BEGIN
    m_sql_stmt    := 'insert into SYS.DEFAULT_PWD$ values(:1, :2, :3)';
    EXECUTE IMMEDIATE m_sql_stmt USING tuser_name, tpwd_verifier, tpv_type;
EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
      DBMS_OUTPUT.PUT_LINE('User: '||tuser_name||' already exists');
  ELSE RAISE;
  END IF;
END;
/

Rem Insert values into SYS.DEFAULT_PWD$
Rem List of accounts with default password from 11.1.0.6 to 11.2

exec dbms_session.modify_package_state(dbms_session.reinitialize);
exec insert_into_defpwd('AIA',  '3866BBB1FB9D80C3');
exec insert_into_defpwd('ALT_ADMIN',  '779344313F899066');
exec insert_into_defpwd('APEX_PUBLIC_USER',  '084062DA5B2E2B75');
exec insert_into_defpwd('APPQOSSYS',  '519D632B7EE7F63A');
exec insert_into_defpwd('BC4J_INTERNAL',  'D15756F15F62D5BA');
exec insert_into_defpwd('BI',  'FA1D2B85B70213F3');
exec insert_into_defpwd('CCT',  'C6AF8FCA0B51B32F');
exec insert_into_defpwd('CDR_DPSERVER',  'D9AA439707214B0D');
exec insert_into_defpwd('CLIENT_STORAGE',  '66AA3738639CCA31');
exec insert_into_defpwd('DDR',  '834EC9EAC5998DC3');
exec insert_into_defpwd('DNA',  'C5E32FB2E153E257');
exec insert_into_defpwd('DPP',  '9C332D64EAF7243E');
exec insert_into_defpwd('EM_MONITOR',  '5BEEF0684A63B990');
exec insert_into_defpwd('EUL4_US',  '89867444DCC3C48C');
exec insert_into_defpwd('EUL5_US',  'B94851DE238A8AFF');
exec insert_into_defpwd('EXFSYS',  '33C758A8E388DEE5');
exec insert_into_defpwd('FLOWS_030000',  'FA1D2B85B70213F3');
exec insert_into_defpwd('FLOWS_FILES',  '0CE415AC5D50F7A1');
exec insert_into_defpwd('FOD',  '9C140B8BA4ADB59B');
exec insert_into_defpwd('FTP',  '958CCB397C152ED2');
exec insert_into_defpwd('GMO',  '09965CDCFEAFF416');
exec insert_into_defpwd('IBW',  '33261A65FA16710E');
exec insert_into_defpwd('INL',  '1E0296A1C65D2DA1');
exec insert_into_defpwd('IPM',  'CC6375A05C243C9E');
exec insert_into_defpwd('ITA',  '7FF3EB385C43C19B');
exec insert_into_defpwd('IX',  '885DA62CD26FED7E');
exec insert_into_defpwd('IX',  '2BE6F80744E08FEB');
exec insert_into_defpwd('IZU',  '66ADE345B0C57B1C');
exec insert_into_defpwd('JMF',  'E135EB82FB383423');
exec insert_into_defpwd('JMSUSER',  'A79CAEC8EC0D7A44');
exec insert_into_defpwd('MGDSYS',  'C4F9B839D589AA92');
exec insert_into_defpwd('MGMT_VIEW',  '5D5BC23A318B6F53');
exec insert_into_defpwd('MTH',  '6FB1B758D9877D4F');
exec insert_into_defpwd('OLAPSYS',  '4AC23CC3B15E2208');
exec insert_into_defpwd('OPS$OPAPPS',  '75E951CFD55482F9');
exec insert_into_defpwd('OPS$GUEST1',  '9F7E5A6AAA14AB3F');
exec insert_into_defpwd('OPS$GUEST2',  '0129EC7B1A376587');
exec insert_into_defpwd('OPS$GUEST3',  'FB268CD96FFD8D15');
exec insert_into_defpwd('OPS$GUEST4',  'A885B9C548D9D575');
exec insert_into_defpwd('OPS$GUEST5',  '31462E009CD7016F');
exec insert_into_defpwd('OPS$GUEST6',  '75BB189B6BE55A3D');
exec insert_into_defpwd('OPS$GUEST7',  '2D2B86A16BC8B14A');
exec insert_into_defpwd('OPS$GUEST8',  '8F18911775F065A0');
exec insert_into_defpwd('OPS$GUEST9',  'F2A99B33E50A8076');
exec insert_into_defpwd('OPS$TMSBROWSER',  '7602826AEE50895C');
exec insert_into_defpwd('ORDDATA',  'A93EC937FCD1DC2A');
exec insert_into_defpwd('ORACLE_OCM',  '5A2E026A9157958C');
exec insert_into_defpwd('ORACLE_OCM',  '6D17CF1EB1611F94');
exec insert_into_defpwd('OWBSYS',  '610A3C38F301776F');
exec insert_into_defpwd('PFT',  'F5B571D73A38C13F');
exec insert_into_defpwd('PLM','53544627CD6E8B7F');
exec insert_into_defpwd('PM',  '72E382A52E89575A');
exec insert_into_defpwd('QPR',  '9D58E13752C8A432');
exec insert_into_defpwd('RDW13DEV',  'FEAC65EA45E13825');
exec insert_into_defpwd('RDWDEV',  '0EB196C95E3E3F68');
exec insert_into_defpwd('RDWDM',  'FDD277EC7AAF5E38');
exec insert_into_defpwd('RDWSYS',  '91C718625D7E26DA');
exec insert_into_defpwd('RRS',  '5CA8F5380C959CA9');
exec insert_into_defpwd('RXA_ACCESS',  'F502B0CF72A32DE3');
exec insert_into_defpwd('RXA_DES',  '27CE2AC19A98CE9C');
exec insert_into_defpwd('RXA_LR',  'D13AF40CCA5F3915');
exec insert_into_defpwd('RXA_RAND',  '6345DA1B5503537B');
exec insert_into_defpwd('RXA_READ',  '6D8E49FC0F60ED57');
exec insert_into_defpwd('RXC',  '043FA64BA9C19AB9');
exec insert_into_defpwd('RXC_COMMON',  '7A5E40AD77667314');
exec insert_into_defpwd('RXC_DISC_REP',  '8769BDF187623626');
exec insert_into_defpwd('RXC_MAA',  '4F7E585AF66C8D1A');
exec insert_into_defpwd('RXC_PD',  '62D0273BFE2D71EA');
exec insert_into_defpwd('RXC_REP',  '47FE00E292BD12BF');
exec insert_into_defpwd('RXC_SERVLETSP',  '8CBCAC11A95CBF3B');
exec insert_into_defpwd('RXC_SERVLETST',  'E1D2A7B96C1DBA94');
exec insert_into_defpwd('SPATIAL_CSW_ADMIN_USR',  '1B290858DD14107E');
exec insert_into_defpwd('SPATIAL_WFS_ADMIN_USR',  '7117215D6BEE6E82');
exec insert_into_defpwd('SRDEMO',  '7C3269BF04F441BD');
exec insert_into_defpwd('SST',  '2DACCD0C919B4435');
exec insert_into_defpwd('SUPERUSER',  '84DEF330533B56EF');
exec insert_into_defpwd('SYS',  '089509EC42EF6C07');
exec insert_into_defpwd('SYS_ADMIN',  '4B85054970355BBD');
exec insert_into_defpwd('TDX',  'C54CC64803BD0EEB');
exec insert_into_defpwd('TMS',  'CD5EB4CEAB7AAA3C');
exec insert_into_defpwd('TSMSYS',  '3DF26A8B17D0F29F');
exec insert_into_defpwd('XDB',  'FD6C945857807E3C');
exec insert_into_defpwd('XS$NULL',  'NOLOGIN000000000', -1);

commit;

drop procedure insert_into_defpwd;
Rem *************************************************************************
Rem END: Bug 7829203, Changes required for default_pwd$
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN: Bug 8348017, Add additional fields for RewriteMessage
Rem *************************************************************************

ALTER TYPE SYS.RewriteMessage ADD ATTRIBUTE
      (query_block_no  NUMBER(3),      /* block no of the current subquery */
      rewritten_text  VARCHAR2(2000),              /* rewritten query text */
      mv_in_msg       VARCHAR2(30),               /* MV in current message */
      measure_in_msg  VARCHAR2(30),          /* Measure in current message */
      join_back_tbl   VARCHAR2(30),      /* Join back table in current msg */ 
      join_back_col   VARCHAR2(30),     /* Join back column in current msg */ 
      original_cost   NUMBER(10),                   /* original query cost */ 
      rewritten_cost  NUMBER(10)                   /* rewritten query cost */ 
      ) CASCADE;
  
Rem *************************************************************************
Rem END: Bug 8348017, Add additional fields for RewriteMessage
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN: Bug 8331425, Populated DBID in AUD$ and FGA_LOG$
Rem bug 11864197 - rewrite populate_dbid_audit to use bulk update
Rem *************************************************************************

Rem 5/6/11 bug 11864197
Rem replaced original populate_dbid_audit with new one to speed up update

create or replace procedure populate_dbid_audit(tab_owner VARCHAR2,
                                                tab_name  VARCHAR2)
as
  cur_dbid  number := 0; 
  type ctyp is ref cursor; 
  rowid_cur ctyp; 
  rowid_tab dbms_sql.urowid_table;
  nrows number := 0;
  rows_updated number := 0;
  rows_not_updated number := 0;
  counter number := 0;
  current_time timestamp(6);
begin 

  execute immediate
    'select count(*) from ' || tab_owner || '.' || tab_name || 
    ' where dbid is null' into nrows;

  counter := ceil(nrows/1000000);
  dbms_output.put_line('.');
  dbms_output.put_line('-------------------------------------------------------------------------');
  IF (counter = 0) THEN
    dbms_output.put_line('There are not any null DBIDs in ' || tab_owner ||
                         '.' || tab_name || ' to update.');
    dbms_output.put_line('-------------------------------------------------------------------------');
    return;
  ELSE
    select current_timestamp into current_time from dual;
    dbms_output.put_line('Start DBID update in ' || tab_owner || '.' ||
                          tab_name || ' at: ' || current_time || '...');
    dbms_output.put_line('Will update at least ' || nrows || ' rows.');
  END IF;
   
  select dbid into cur_dbid from v$database;

  -- Populate column DBID in audit table if NULL.

  LOOP
    IF (counter = 0) THEN
      EXIT;
    END IF;

    OPEN rowid_cur FOR 'select rowid from ' || tab_owner || '.' || tab_name || 
                       ' where dbid is null and rownum <= 1000000';

    FETCH rowid_cur bulk collect into rowid_tab limit 100000;

    IF (rowid_tab.count = 0) THEN 
      EXIT; 
    END IF;

    LOOP 
      FORALL i in 1..rowid_tab.count 
        execute immediate 
          'UPDATE ' || tab_owner || '.' || tab_name || 
          ' SET dbid = ' || cur_dbid || 
          ' WHERE dbid IS NULL and rowid = :1' using rowid_tab(i); 
      COMMIT;
      IF (counter = 1 and nrows <= 100000) THEN
        EXIT;
      END IF;
      nrows := nrows - 100000;
      FETCH rowid_cur bulk collect into rowid_tab limit 100000;
      IF (rowid_tab.count = 0) THEN 
        EXIT; 
      END IF;
    END LOOP;
    counter := counter - 1;
  END LOOP;
  CLOSE rowid_cur;
  COMMIT;

  execute immediate
    'select count(*) from ' || tab_owner || '.' || tab_name || 
    ' where dbid is not null' into rows_updated;
  dbms_output.put_line('Total rows in table updated: ' || rows_updated);
  execute immediate
    'select count(*) from ' || tab_owner || '.' || tab_name || 
    ' where dbid is null' into rows_not_updated;
  dbms_output.put_line('Total rows in table not yet updated: ' || rows_not_updated);
  select current_timestamp into current_time from dual;
  dbms_output.put_line('End update at: ' || current_time || '.');
  dbms_output.put_line('-------------------------------------------------------------------------');
  
EXCEPTION
  WHEN OTHERS THEN
    rollback;
END;
/

declare
  schema     varchar2(32);
begin
   -- First, check where is AUD$ present
   select u.name into schema from obj$ o, user$ u
          where o.name = 'AUD$' and
                o.type#=2 and
                o.owner# = u.user# and 
                o.remoteowner is NULL and
                o.linkname is NULL and
                u.name in ('SYS', 'SYSTEM');

   populate_dbid_audit(schema, 'AUD$');
   populate_dbid_audit('SYS', 'FGA_LOG$');
end;
/
  
drop procedure populate_dbid_audit;

Rem *************************************************************************
Rem END: Bug 8331425, Populated DBID in AUD$ and FGA_LOG$
Rem *************************************************************************

Rem =======================================================================
Rem  Begin Changes for Data Mining Libraries (bug 7027820)
Rem =======================================================================

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DMSVM_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DMSVMA_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DMNMF_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DMMOD_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DMCL_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DMGLM_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.DMBLAST_LIB FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem =======================================================================
Rem  End Changes for Data Mining Libraries
Rem =======================================================================


Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

@@c1102000

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================


Rem *************************************************************************
Rem END c1101000.sql
Rem *************************************************************************

