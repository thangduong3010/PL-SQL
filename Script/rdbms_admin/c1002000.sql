Rem
Rem $Header: rdbms/admin/c1002000.sql /st_rdbms_11.2.0/2 2011/04/28 12:11:10 jaeblee Exp $
Rem
Rem c1002000.sql
Rem
Rem Copyright (c) 2005, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      c1002000.sql - upgrade Oracle RDBMS from 10.2.0 to the new release
Rem
Rem    DESCRIPTION
Rem      Put any dictionary related changes here (ie-create, alter,
Rem      update,...).  If you must upgrade using PL/SQL packages, 
Rem      put the PL/SQL block in a1002000.sql since catalog.sql and 
Rem      catproc.sql will be run before a1002000.sql is invoked.
Rem
Rem      This script is called from catupgrd.sql and c1001000.sql
Rem
Rem      This script performs the upgrade in the following stages:
Rem        STAGE 1: upgrade from 10.2.0 to the current release
Rem        STAGE 2: call catalog.sql and catproc.sql
Rem        STAGE 3: Complete upgrade steps
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jaeblee     04/21/11 - Backport jaeblee_bug-11826782 from main
Rem    pxwong      11/16/10 - Backport pxwong_bug-10096081 from main
Rem    hosu        03/16/10 - 9038395: suppress ora-00904 error for reupgrading
Rem    apsrivas    02/23/10 - Bug 9337796: Fix sql injection vulnerability in
Rem                           insert_into_defpwd procedure
Rem    rdecker     04/03/09 - bug 7361575: move assembly$ create to i1002000
Rem    sarchak     03/02/09 - Bug 7829203,default_pwd$ should not be recreated
Rem    dvoss       10/02/08 - remove logmnr integer changes, 11.2 uses numbers
Rem    gagarg      03/10/08 - Add event 10851 to enable DDL on AQ tables
Rem    cdilling    10/16/07 - add enquote_name to col_list
Rem    srirkris    08/16/07 - bug 6215620:  public execute on xml imp types
Rem    vakrishn    07/25/07 - bug 6270136 num_mappings has null value
Rem    rburns      07/10/07 - add 11.1 patch release script
Rem    jaeblee     07/09/07 - invalidate tables, views, and synonyms that
Rem                           have negative dependencies
Rem    rburns      05/25/07 - add tz_version
Rem    mtao        06/04/07 - clear out logmnr_session$.branch_scn on upgrade
Rem    mbrey       05/30/07 - CDC bug 6083095
Rem    pbelknap    05/07/07 - #6026921 - upgrade _sqltune_control
Rem    rburns      05/22/07 - drop STATSpack DYNAMIC_REM_STATS view
Rem    cdilling    04/30/07 - fix execute immediates
Rem    vakrishn    05/07/07 - bug 6014356: remove duplicate values in
Rem                           smon_scn_time
Rem    sfeinste    04/27/07 - rename build process to cube build process
Rem    rmacnico    04/17/07 - bug 5496852, lsby skip on grant and revoke
Rem    nachen      04/19/07 - add constraint for mgmt_snapshot table
Rem    smangala    04/25/07 - bug5937028: set max_servers if needed
Rem    pbelknap    04/03/07 - add parsing_user_id to sqlstat_bl tables too
Rem    pbelknap    03/20/07 - remove sqlobj$probation_stats
Rem    mlfeng      04/18/07 - platform name to wrm$_database_instance
Rem    mbrey       04/10/07 - CDC metadata change
Rem    mlfeng      04/10/07 - bug with baseline upgrade
Rem    rburns      03/05/07 - move OCM drop user
Rem    rmacnico    04/04/07 - bug 5971328: increase col width for plsql skip
Rem    sjanardh    03/26/07 - bug fix 5943749
Rem    qiwang      04/02/07 - BUG 5743875: memory spill table schema change
Rem    mtao        03/27/07 - bug 5880925: add version_timestamp to global$
Rem    hosu        02/26/07 - add "Administer SQL Management Object" 
Rem                           privilege
Rem    wechen      03/23/07 - rename primary dimension to cube dimension,
Rem                           rename interaction to build process
Rem    vakrishn    02/12/07 - reorder ddls to avoid duplicate rows in
Rem                           smon_scn_time_aux
Rem    sburanaw    03/02/07 - rename column top_sql* to top_level_sql* in 
Rem                           WRH$_ACTIVE_SESSION_HISTORY
Rem    akociube    03/13/07 - revoke olapimpl_t grant
Rem    dvoss       03/15/07 - move certain logmnr actions from c0902000.sql
Rem    jinwu       03/13/07 - create perf advisor tables in SYSAUX tablespace
Rem    jinwu       02/03/07 - add support for management pack access
Rem    absaxena    03/13/07 - add reg_id to aq$_srvntfn_message
Rem    veeve       03/06/07 - add flags to ASH
Rem    ssonawan    03/06/07 - bug 5609854: remove audit options 
Rem    mtao        03/05/07 - bug 5903103: Rename logical remote log to foreign
Rem    suelee      12/14/06 - Add consumer group category
Rem    jaeblee     03/04/07 - add objerror$ creation and population 
Rem    vkolla      01/23/07 - add process mbps to resource_io_calibrate
Rem    rgmani      11/27/06 - Modifications to scheduler tables
Rem    mlfeng      02/20/07 - increase column size
Rem    absaxena    02/16/07 - add grouping_inst_id to reg$
Rem    pbelknap    02/07/07 - adv fmwk finding flags
Rem    gssmith     02/13/07 - Remove Summary Advisor
Rem    jinwu       01/31/07 - add creation_time to streams$_propagation_process
Rem    dvoss       02/06/07 - fixup logmnrc_gtlo for bug 5862287
Rem    dvoss       02/08/07 - logminer upgrade cleanup
Rem    mziauddi    02/01/07 - fix module and action column lengths
Rem    mziauddi    01/21/07 - insert into smb$config values ('SPM_TRACING', 0)
Rem    ilistvin    10/19/06 - AWR Report Types
Rem    jingliu     01/09/07 - move triggerdep$ to i* script
Rem    achoi       11/14/06 - update obj$.spare3 to store base owner#
Rem    femekci     01/05/07 - adding a temp table for inc. maintenance of
Rem                           histogram
Rem    pbelknap    01/08/07 - fix exception handler for wri$_adv_definitions
Rem    pstengar    12/11/06 - bug 5586631: add MINING MODEL entries to
Rem                                        AUDIT_ACTIONS
Rem    jinwu       12/18/06 - add column access_status
Rem    thoang      12/18/06 - remove DBMS_APPLY_USER_AGENT 
Rem    ddas        01/05/07 - #(5664495) create index on ol$nodes
Rem    mbrey       12/18/06 - lrg 2747920
Rem    rburns      12/01/06 - move OLAP creates to i1002000.sql
Rem    ssvemuri    11/15/06 - query notification type evolution
Rem    liaguo      11/16/06 - flashback archive privilege
Rem    vkolla      11/13/06 - add latency and numdisks to calibration
Rem    wechen      11/18/06 - add "update any primary dimension"
Rem    rramkiss    11/12/06 - update for remote job chain steps
Rem    ddas        10/27/06 - rename OPM to SPM
Rem    ddas        10/02/06 - plan_hash_value=>plan_id, add version
Rem    gssmith     10/06/06 - Fix bug 5557639
Rem    xbarr       11/03/06 - fix lrg2625331 - remove 'rename' audit option 
Rem    schakkap    09/21/06 - Add optimizer tables (used to be in catost.sql)
Rem                           Do not ignore error in block for extended stats
Rem    suelee      10/12/06 - Change resource_plan$ default values for max_iops
Rem                           and max_mbps
Rem    jinwu       10/10/06 - add column original_path_id
Rem    mlfeng      10/05/06 - pctfree sysmetric_history
Rem    mmcracke    10/05/06 - Change modelset$.value datatype to varchar2(4k)
Rem    xbarr       10/03/06 - add 'grant all privileges to dba' statement
Rem    kyagoub     09/28/06 - replace task parameter
Rem                           _SQLTUNE_TRACE/_TRACE_CONTROL
Rem    bvaranas    09/28/06 - Add position# to insert_tsn_list#$
Rem    jinwu       09/07/06 - add path_flag to streams$_component_link
Rem    kyagoub     08/17/06 - fix SPM upgrade diff
Rem    pbelknap    08/10/06 - change sqlprof$auxdata
Rem    hosu        07/26/06 - upgrade for SPM
Rem    kyagoub     09/10/06 - bug#5518178: extend optimizer_env size to 2000
Rem    dvoss       04/18/06 - bug 4746074 - drop logmnr_interesting_cols 
Rem    dmwong      09/20/06 - no sysaux for xs$parameter
Rem    mlfeng      09/18/06 - baseline renaming errors
Rem    mhho        08/24/06 - Add xs$parameters
Rem    mlfeng      08/29/06 - rename the BL indices
Rem    wxli        08/31/06 - drop procedure pstub
Rem    ciyer       08/04/06 - audit support for edition objects
Rem    sburanaw    08/04/06 - add current_row# to wrh$_active_session_history
Rem    pstengar    08/29/06 - remove rename audit option for mining models
Rem    ilistvin    09/05/06 - 
Rem    gviswana    08/17/06 - Add AUD$.OBJ$EDITION
Rem    ilistvin    08/29/06 - add steps to upgrade alert_type
Rem    ghicks      08/22/06 - add column to aw$
Rem    mhho        08/18/06 - add apps_feature to global_var namespace
Rem    wechen      08/14/06 - add OLAP API system privileges
Rem    rburns      08/15/06 - add pl/sql block for re-run error
Rem    ushaft      08/03/06 - add column to wrh$_pga_target_advice
Rem    juyuan      07/11/06 - do not drop _DBA_STREAMS_UNSUPPORTED_* and 
Rem                           _DBA_STREAMS_NEWLY_SUPTED_* views  
Rem    jinwu       07/06/06 - add streams$_component_prop 
Rem    mlfeng      07/17/06 - add sum squares 
Rem    jsoule      07/12/06 - add modifications for bsln upgrade
Rem    rburns      07/20/06 - PL/SQL block for TRUNCATE statement 
Rem    hosu        07/14/06 - extended stats
Rem    kquinn      07/20/06 - 5383828: convert col$.spare3 null values 
Rem    jawilson    06/02/06 - scheduler-based propagation
Rem    absaxena    07/18/06 - change reg_id in reg$ from varchar2 to number 
Rem    jsoule      07/14/06 - splice out bsln in preparation for EMDBSA
Rem    samepate    05/02/06 - add columns to scheduler$_job and job$
Rem    kyagoub     06/12/06 - ade a new method to wri_adv_sqltune object type 
Rem    veeve       06/26/06 - add new 11g ASH columns
Rem    sschodav    07/03/06 - bug5111250: add owner_udn to scheduler$_job 
Rem    mlfeng      06/13/06 - insert AWR system moving window baseline 
Rem    mlfeng      06/13/06 - baseline upgrade changes 
Rem    ssonawan    06/21/06 - bug5346555: add AUDIT_ACTIONS 166 ALTER INDEXTYPE
Rem    pstengar    06/08/06 - audit support for mining model objects
Rem    suelee      06/11/06 - Add IO calibration tables 
Rem    pbelknap    06/06/06 - add sub_param_validate for sqltune 
Rem    liaguo      06/26/06 - Project 17991 - flashback archive 
Rem    sbodagal    06/08/06 - publish MV logs
Rem    mmcracke    06/13/06 - Add export/import sequence. 
Rem    bvaranas    06/13/06 - Add table insert_tsn_list$ 
Rem    nbhatt      06/09/06 - lob attribute 
Rem    dkapoor     06/02/06 - integrate OCM 
Rem    cchiappa    06/01/06 - New catalog tables for OLAP tables 
Rem    bvaranas    03/14/05 - Change flags in partobj$ for IOT top index and 
Rem                           LOB col index. 
Rem    smesropi    05/30/06 - add olap data dictionary
Rem    ushaft      04/21/06 - add method to type wri$_hdm_adv_t, 
Rem                           added columns to wrh$_inst_cache_transfer
Rem    ssvemuri    06/12/06 - Evolve change notification types 
Rem    gssmith     03/21/06 - Add advisor items 
Rem    veeve       02/10/06 - add QC_SESSION_SERIAL# to ASH
Rem    mabhatta    06/08/06 - move smon_scn_time to sysaux 
Rem    jinwu       06/10/06 - add streams$_database
Rem    liwong      06/05/06 - update apply_process.flags 
Rem    mxyang      05/17/06 - app edition syntax change
Rem    jaskwon     05/25/06 - Remove max_concurrent_ios 
Rem    juyuan      06/05/06 - drop _DBA_STREAMS_UNSUPPORTED_* and 
Rem                           _DBA_STREAMS_NEWLY_SUPTED_* views 
Rem    jingliu     05/22/06 - Support trigger with FOLLOWS 
Rem    jnarasin    05/31/06 - Add Subordinate set to store HWS info in LWTS 
Rem    rramkiss    05/04/06 - upgrade changes for Scheduler credentials
Rem    rgmani      05/24/06 - Upgrade for LW Jobs 
Rem    suelee      06/01/06 - Fix resource manager downgrade issues 
Rem    pbelknap    05/22/06 - new advisor methods 
Rem    liwong      05/29/06 - external position 
Rem    rvenkate    01/26/06 - add comparison$ 
Rem    jarisank    05/24/06 - bug4054238 - modify sumagg$.agginfo size
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rmacnico    05/23/06 - allow scheduler on standby servers
Rem    kyagoub     05/21/06 - add test_execute action to sqltune 
Rem    dalpern     05/21/06 - bugs 4148555, 5218202: remove dbms_dbupgrade 
Rem    amysoren    05/17/06 - wrh$_system_event new fg columns 
Rem    mbrey       05/15/06 - add CDC 11G changes 
Rem    elu         05/10/06 - add spill scn to apply milestone table
Rem    liwong      05/10/06 - sync capture cleanup 
Rem    kyagoub     04/30/06 - add suport of multi-exec to advisor framework 
Rem    suelee      03/28/06 - Modifications for IO Resource Management 
Rem    shsong      04/24/06 - Bug 5014810: remove useless v$temp_histogram 
Rem    srirkris    04/28/06 - Add CDI types 
Rem    absaxena    05/07/06 - add/modify types for grouping notification
Rem    absaxena    05/04/06 - add constructor for aq$_reg_info
Rem    rdecker     03/28/06 - Add assemblies
Rem    bkuchibh    03/08/06 - add column to wri$_adv_findings 
Rem    bkuchibh    03/08/06 - add column to wri$_adv_findings 
Rem    sdavidso    03/03/06 - add new column for metascript$ 
Rem    spsundar    03/23/06 - add new attributes to ODCIIndexInfo and ColInfo
Rem    jinwu       03/14/06 - create streams per-database tables 
Rem    juyuan      01/04/06 - add columns to streams$_propagation_process 
Rem    hozeng      04/12/06 - fix a syntax error (adding slash)
Rem    kyagoub     04/06/06 - upgrade sts process workspace 
Rem    kumamage    03/28/06 - fix x$ksllt 
Rem    mxyang      03/06/06 - add 'USE' object privileges
Rem    achoi       03/06/06 - add Application Edition
Rem    jnarasin    03/16/06 - Fix the cookie length to 1024 in lwts table 
Rem    jnarasin    03/02/06 - LWTS C-API 
Rem    xbarr       03/13/06 - Add data mining upgrade 
Rem    jnarasin    02/23/06 - LWTS Application Namespaces 
Rem    jnarasin    01/30/06 - LWT sessions tables 
Rem    srtata      01/25/06 - dsec.bsq changes 
Rem    rburns      01/23/06 - use timestamp for CPU history 
Rem    nlee        01/22/06 - Fix for bug 4638550.
Rem    cchiappa    01/19/06 - Add OLAP cell access tracking catalogs 
Rem    achoi       12/09/05 - clear 0x00200000 in trigflag during upgrade 
Rem    spsundar    12/21/05 - modify sys.ODCIColInfo
Rem    ayoaz       12/20/05 - revoke public execute on xml imp types
Rem    dgagne      11/18/05 - add drop of plugts objects 
Rem    rburns      11/30/05 - modify registry$history table
Rem    rburns      11/10/05 - move truncate duc$ for all upgrades
Rem    wxli        10/13/05 - drop package dbms_schema_copy, 
Rem                           dbms_upgrade_internal 
Rem    cdilling    10/03/05 - move session history changes from 1001000.sql 
Rem    dsirmuka    10/03/05 - #4107478.Update obj$.flags value for SYNONYM
Rem    sdavidso    08/12/05 - add new columns for metaxslparam$ 
Rem    pbelknap    08/08/05 - sql tuning set changes: drop temp table
Rem    samepate    07/18/05 - remove obsolete scheduler objects
Rem    cdilling    06/08/05 - Created

Rem=========================================================================
Rem BEGIN STAGE 1: upgrade from 10.2 to the current release
Rem=========================================================================

Rem Moved from catupstr.sql to avoid running for patch upgrades
Rem
Rem 4523571: Invalidate views with object columns
Rem
update sys.obj$ set status = 6
 where status not in (5, 6) and
       obj# in (select obj# from view$ v where (bitand(v.property, 31) != 0));
update sys.obj$ SET status = 6
 where obj# in
       (select /*+ index (dependency$ i_dependency2) */ d_obj# from dependency$
        connect by prior d_obj# = p_obj#
        start with p_obj# in
        (select obj# from view$ where bitand(property, 31) !=0));
commit;

-- objerror$ tracks certain types of objects that have authorization errors
-- (status 2) or compilation errors (status 3).
create table objerror$
(
  obj#          number not null                            /* object number */
)
/

-- set a flag in the obj$ entry for certain types of objects that are
-- currently in status 2 or 3
update obj$ set flags = flags + 32768
  where bitand(flags, 32768) = 0 and 
  status in (2, 3) and 
  type# in (4, 5, 7, 8, 9, 11, 12, 13, 14); 

-- populate objerror$ with the objects that are in status 2 or 3
insert into  objerror$  select obj# from obj$ where status in (2, 3) and 
type# in (4, 5, 7, 8, 9, 11, 12, 13, 14);

commit;

-- Invalidate tables, views and synonyms that depend on a local 
-- non-existent object.  This is necessary as we no longer have
-- negative dependencies in 11.1.  We only invalidate these types here
-- as utlip already has invalidated everything else that we care about.
update obj$ set status = 6
  where status not in (5, 6) and type# in (2,4,5) and
  obj# in (select d_obj# from dependency$ where p_obj# in
  (select obj# from obj$ where type#=10 and linkname is null));

commit;

-- Set bit 262144 in the tables we just invalidated so that these tables
-- can be compiled via "alter table upgrade".
update obj$ set flags = flags + 524288
  where bitand(flags, 524288) = 0 and
  type# = 2 and
  obj# in (select d_obj# from dependency$ where p_obj# in
  (select obj# from obj$ where type#=10 and linkname is null));

-- commit the changes
commit;

-- flush the shared pool before continuing
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

-- Starting in 11g, obj$.spare3 will store the base user# of the owner. For
-- ORA$BASE edition, the base user will simply be the owner. Therefore on upgrade,
-- we'll set spare3 to be the owner#.
-- For large databases, limit the number of rows changed before commit to
-- avoid rollback problems during upgrade
begin
  loop
      execute immediate
        'update sys.obj$ set spare3 = owner#
                where spare3 IS NULL and
                      rownum <10000';
      exit when sql%rowcount = 0;
      commit;
   end loop;
end;
/
commit
/

Rem Remove entries from sys.duc$ - rebuilt for 10.2 by catalog and catproc
truncate table duc$;

Rem=========================================================================
Rem Begin Advisor Framework upgrade items 
Rem=========================================================================

Rem
Rem Add columns to base advisor tables
alter table sys.wri$_adv_findings add (filtered char(1));
alter table sys.wri$_adv_findings add (flags number);
alter table sys.wri$_adv_recommendations add (filtered char(1));
alter table sys.wri$_adv_actions add (filtered char(1));

Rem
Rem Add no member method for SQL Access Advisor

alter type wri$_adv_sqlaccess_adv
  add overriding member procedure sub_create(task_id in number,
                                             from_task_id in number)
  cascade;

Rem
Rem Add new columns to workload map table to support STS workload
Rem

alter table sys.wri$_adv_sqlw_sum add (sqlset_ref_id number);

alter table sys.wri$_adv_sqla_map
  add (ref_id number,
       is_sts number,
       name varchar2(30),
       child_id number);

Rem
Rem Access Advisor statements table
Rem

alter table sys.wri$_adv_sqla_stmts
  add (stmt_id number);

alter table sys.wri$_adv_sqla_stmts
  add sql_id_tmp number;

begin      
  execute immediate 'update sys.wri$_adv_sqla_stmts set sql_id_tmp = sql_id';

  execute immediate 'update sys.wri$_adv_sqla_stmts set sql_id = null';

  commit;
EXCEPTION 
  WHEN OTHERS THEN
   IF SQLCODE = -942 THEN 
     NULL;  -- Table not found in pre-10g
   ELSE
     RAISE;
   END IF;
end;
/

alter table sys.wri$_adv_sqla_stmts
  modify sql_id varchar2(13);

begin
  execute immediate 'update sys.wri$_adv_sqla_stmts set sql_id = sql_id_tmp';

  commit;
EXCEPTION 
  WHEN OTHERS THEN
   IF SQLCODE = -942 THEN 
     NULL;  -- Table not found in pre-10g
   ELSE
     RAISE;
   END IF;
end;
/

Rem=========================================================================
Rem End Advisor Framework upgrade items 
Rem=========================================================================

Rem=========================================================================
Rem Add new system privileges here 
Rem=========================================================================
insert into SYSTEM_PRIVILEGE_MAP values (-284, 'CREATE ASSEMBLY', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-285, 'CREATE ANY ASSEMBLY', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-286, 'ALTER ANY ASSEMBLY', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-287, 'DROP ANY ASSEMBLY', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-288, 'EXECUTE ANY ASSEMBLY', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-289, 'EXECUTE ASSEMBLY', 0);
insert into SYSTEM_PRIVILEGE_MAP
  values (-281, 'CREATE ANY EDITION',  0);
insert into SYSTEM_PRIVILEGE_MAP
  values (-282, 'DROP ANY EDITION',    0);
insert into SYSTEM_PRIVILEGE_MAP
  values (-283, 'ALTER ANY EDITION', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-301, 'CREATE CUBE DIMENSION', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-302, 'ALTER ANY CUBE DIMENSION', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-303, 'CREATE ANY CUBE DIMENSION', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-304, 'DELETE ANY CUBE DIMENSION', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-305, 'DROP ANY CUBE DIMENSION', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-306, 'INSERT ANY CUBE DIMENSION', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-307, 'SELECT ANY CUBE DIMENSION', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-308, 'CREATE CUBE', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-309, 'ALTER ANY CUBE', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-310, 'CREATE ANY CUBE', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-311, 'DROP ANY CUBE', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-312, 'SELECT ANY CUBE', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-313, 'UPDATE ANY CUBE', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-314, 'CREATE MEASURE FOLDER', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-315, 'CREATE ANY MEASURE FOLDER', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-316, 'DELETE ANY MEASURE FOLDER', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-317, 'DROP ANY MEASURE FOLDER', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-318, 'INSERT ANY MEASURE FOLDER', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-319, 'CREATE CUBE BUILD PROCESS', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-320, 'CREATE ANY CUBE BUILD PROCESS', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-321, 'DROP ANY CUBE BUILD PROCESS', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-322, 'UPDATE ANY CUBE BUILD PROCESS', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-326, 'UPDATE ANY CUBE DIMENSION', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-350, 'FLASHBACK ARCHIVE ADMINISTER', 0);

Rem  add system privileges for data mining models (dsec.bsq)
insert into SYSTEM_PRIVILEGE_MAP values (-290, 'CREATE MINING MODEL', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-291, 'CREATE ANY MINING MODEL', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-292, 'DROP ANY MINING MODEL', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-293, 'SELECT ANY MINING MODEL', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-294, 'ALTER ANY MINING MODEL', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-295, 'COMMENT ANY MINING MODEL', 0);

grant all privileges, analyze any dictionary to dba with admin option;

Rem=========================================================================
Rem Add new object privileges here
Rem=========================================================================

insert into TABLE_PRIVILEGE_MAP values (29, 'USE');
insert into TABLE_PRIVILEGE_MAP values (30, 'FLASHBACK ARCHIVE');

Rem=========================================================================
Rem Add new audit options here 
Rem=========================================================================
insert into STMT_AUDIT_OPTION_MAP values (284, 'CREATE ASSEMBLY', 0);
insert into STMT_AUDIT_OPTION_MAP values (285, 'CREATE ANY ASSEMBLY', 0);
insert into STMT_AUDIT_OPTION_MAP values (286, 'ALTER ANY ASSEMBLY', 0);
insert into STMT_AUDIT_OPTION_MAP values (287, 'DROP ANY ASSEMBLY', 0);
insert into STMT_AUDIT_OPTION_MAP values (288, 'EXECUTE ANY ASSEMBLY', 0);
insert into STMT_AUDIT_OPTION_MAP values (289, 'EXECUTE ASSEMBLY', 0);
insert into STMT_AUDIT_OPTION_MAP values (281, 'CREATE ANY EDITION', 0);
insert into STMT_AUDIT_OPTION_MAP values (282, 'DROP ANY EDITION', 0);
insert into STMT_AUDIT_OPTION_MAP values (283, 'ALTER ANY EDITION', 0);
insert into STMT_AUDIT_OPTION_MAP values (301, 'CREATE CUBE DIMENSION', 0);
insert into STMT_AUDIT_OPTION_MAP values (302, 'ALTER ANY CUBE DIMENSION', 0);
insert into STMT_AUDIT_OPTION_MAP values (303, 'CREATE ANY CUBE DIMENSION', 0);
insert into STMT_AUDIT_OPTION_MAP values (304, 'DELETE ANY CUBE DIMENSION', 0);
insert into STMT_AUDIT_OPTION_MAP values (305, 'DROP ANY CUBE DIMENSION', 0);
insert into STMT_AUDIT_OPTION_MAP values (306, 'INSERT ANY CUBE DIMENSION', 0);
insert into STMT_AUDIT_OPTION_MAP values (307, 'SELECT ANY CUBE DIMENSION', 0);
insert into STMT_AUDIT_OPTION_MAP values (308, 'CREATE CUBE', 0);
insert into STMT_AUDIT_OPTION_MAP values (309, 'ALTER ANY CUBE', 0);
insert into STMT_AUDIT_OPTION_MAP values (310, 'CREATE ANY CUBE', 0);
insert into STMT_AUDIT_OPTION_MAP values (311, 'DROP ANY CUBE', 0);
insert into STMT_AUDIT_OPTION_MAP values (312, 'SELECT ANY CUBE', 0);
insert into STMT_AUDIT_OPTION_MAP values (313, 'UPDATE ANY CUBE', 0);
insert into STMT_AUDIT_OPTION_MAP values (314, 'CREATE MEASURE FOLDER', 0);
insert into STMT_AUDIT_OPTION_MAP values (315, 'CREATE ANY MEASURE FOLDER', 0);
insert into STMT_AUDIT_OPTION_MAP values (316, 'DELETE ANY MEASURE FOLDER', 0);
insert into STMT_AUDIT_OPTION_MAP values (317, 'DROP ANY MEASURE FOLDER', 0);
insert into STMT_AUDIT_OPTION_MAP values (318, 'INSERT ANY MEASURE FOLDER', 0);
insert into STMT_AUDIT_OPTION_MAP values (319, 'CREATE CUBE BUILD PROCESS', 0);
insert into STMT_AUDIT_OPTION_MAP values (320, 'CREATE ANY CUBE BUILD PROCESS', 0);
insert into STMT_AUDIT_OPTION_MAP values (321, 'DROP ANY CUBE BUILD PROCESS', 0);
insert into STMT_AUDIT_OPTION_MAP values (322, 'UPDATE ANY CUBE BUILD PROCESS', 0);
insert into STMT_AUDIT_OPTION_MAP values (323, 'COMMENT EDITION', 0);
insert into STMT_AUDIT_OPTION_MAP values (324, 'GRANT EDITION', 0);
insert into STMT_AUDIT_OPTION_MAP values (325, 'USE EDITION', 0);
insert into STMT_AUDIT_OPTION_MAP values (326, 'UPDATE ANY CUBE DIMENSION', 0);

Rem  Add audit options for data mining models 
insert into STMT_AUDIT_OPTION_MAP values ( 52, 'MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (290, 'CREATE MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (291, 'CREATE ANY MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (292, 'DROP ANY MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (293, 'SELECT ANY MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (294, 'ALTER ANY MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (295, 'COMMENT ANY MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (296, 'ALTER MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (297, 'COMMENT MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (298, 'GRANT MINING MODEL', 0);
insert into STMT_AUDIT_OPTION_MAP values (300, 'SELECT MINING MODEL', 0);

Rem Remove invalid audit options
delete from AUDIT$                where option# in (157, 158, 185, 87);
delete from STMT_AUDIT_OPTION_MAP where option# in (157, 158, 185, 87);

Rem=========================================================================
Rem Add new audit_actions rows here 
Rem=========================================================================
insert into AUDIT_ACTIONS values (166, 'ALTER INDEXTYPE');
insert into AUDIT_ACTIONS values (212, 'CREATE EDITION');
insert into AUDIT_ACTIONS values (213, 'ALTER EDITION');
insert into AUDIT_ACTIONS values (214, 'DROP EDITION');
insert into AUDIT_ACTIONS values (130, 'ALTER MINING MODEL');
insert into AUDIT_ACTIONS values (131, 'SELECT MINING MODEL');
insert into AUDIT_ACTIONS values (133, 'CREATE MINING MODEL');

Rem=========================================================================
Rem Add new audit options here 
Rem=========================================================================
insert into STMT_AUDIT_OPTION_MAP values (350, 'FLASHBACK ARCHIVE ADMINISTER', 0);

Rem=========================================================================
Rem Drop views removed from last release here 
Rem Remove obsolete dependencies for any fixed views in i1002000.sql
Rem=========================================================================
drop view X_$KSLLT;
drop public synonym X$KSLLT;
drop view V_$TEMP_HISTOGRAM;
drop public synonym V$TEMP_HISTOGRAM;
drop view GV_$TEMP_HISTOGRAM;
drop public synonym GV$TEMP_HISTOGRAM;

drop view STATS$V_$DYNAMIC_REM_STATS;
drop public synonym STATS$V_$DYNAMIC_REM_STATS;

Rem=========================================================================
Rem Drop packages removed from last release here 
Rem=========================================================================
drop package dbms_upgrade_internal;
drop package dbms_schema_copy;

drop procedure sys.pstubt;
drop procedure sys.pstub;

drop package dbms_sumadv;
drop package dbms_sumadvisor;

Rem=========================================================================
Rem DBMS_DBUPGRADE was supposed to be removed in 10.2, but its tables and
Rem view weren't actually dropped.  Be sure it's fully gone.
Rem=========================================================================
drop table sys.dbms_dbupgrade_usercat$ ;
drop table sys.dbms_dbupgrade_source$ ;
drop view sys.dbms_dbupgrade_user_initcat ;
drop package sys.dbms_dbupgrade ;

Rem=========================================================================
Rem For the 10.2 upgrade, utlip.sql is NOT run as part of the 
Rem upgrade since PL/SQL objects do not need to be recompiled.  Any other
Rem types of objects that need to be invalidated should be include here.
Rem=========================================================================

Rem Invalite Materialized Views
update obj$ set status = 5 where type# = 42;
commit;

Rem Remove character length semantics for raw columns.
UPDATE col$ SET property=property-bitand(property, 8388608), spare3=0
  WHERE type#=23 AND spare3 > 0;
COMMIT;

Rem=========================================================================
Rem Add changes to sql.bsq dictionary tables here 
Rem=========================================================================
Rem
Rem Metadata API changes
Rem
alter table metaxslparam$ add (datatype     number);
alter table metaxslparam$ add (lower_bound  number);
alter table metaxslparam$ add (upper_bound  number);
alter table metascript$   add (soseq#       number);
Rem
Rem Table for Fusion extensible Security
Rem
create table xs$verifiers
( user#       NUMBER        NOT NULL,             /* light weight user's UID */
  verifier    VARCHAR2(256) NOT NULL,                   /* password verifier */
  type#       NUMBER                                        /* verifier type */
)
/
create unique index i_xs$verifiers1 on xs$verifiers(user#)
/

Rem Light Weight Sessions and Roles
create table xs$sessions
(
  username             varchar2(4000) not null ,   /* Light Weight User Name */
  userid               raw(16)        not null ,     /* Light Weight User ID */
  acloid               raw(16)                 ,                  /* ACL OID */
  sid                  raw(16)        not null ,  /* Light Weight Session ID */
  cookie               varchar2(1024) unique   ,                   /* Cookie */
  proxyid              raw(16)                 ,            /* Proxy User ID */
  creatorid            raw(16)        not null ,          /* Creator User ID */
  updateid             raw(16)        not null ,          /* Updator User ID */
  createtime           timestamp      not null ,      /* Session Create time */
  authtime             timestamp      not null , /* Last Authentication Time */
  accesstime           timestamp      not null ,         /* Last Access Time */
  inactivetimeout      number(6)               ,       /* Inactivity Timeout */
  authtimeout          number(6)               ,   /* Authentication Timeout */
  nls_calendar         varchar2(255)           ,
  nls_comp             varchar2(255)           ,
  nls_credit           varchar2(255)           ,
  nls_currency         varchar2(255)           ,
  nls_date_format      varchar2(255)           ,
  nls_date_language    varchar2(255)           ,
  nls_debit            varchar2(255)           ,
  nls_iso_currency     varchar2(255)           ,
  nls_lang             varchar2(255)           ,
  nls_language         varchar2(255)           ,
  nls_length_semantics varchar2(255)           ,
  nls_list_separator   varchar2(255)           ,
  nls_monetary_chrs    varchar2(255)           ,
  nls_nchar_conv_excp  varchar2(255)           ,
  nls_numeric_chrs     varchar2(255)           ,
  nls_sort             varchar2(255)           ,
  nls_territory        varchar2(255)           ,
  nls_timestamp_fmt    varchar2(255)           ,
  nls_timestamp_tz_fmt varchar2(255)           ,
  nls_dual_currency    varchar2(255)           ,
  apps_feature         varchar2(255)        
)
tablespace SYSAUX
/
create table xs$session_roles
(
  sid             raw(16)        not null ,       /* Light Weight Session ID */
  roleintid       number(10)     not null ,              /* Role Internal ID */
  roleid          raw(16)        not null ,                       /* Role ID */
  rolename        varchar2(4000) not null ,                     /* Role Name */
  roleflags       number(10)     not null                      /* Role Flags */
)
tablespace SYSAUX
/
create table xs$session_appns
(
  sid             raw(16)        not null ,       /* Light Weight Session ID */
  nsname          varchar2(4000) not null ,                /* Namespace Name */
  attrname        varchar2(4000)          ,                /* Attribute Name */
  nsacloid        raw(16)                 ,         /* ACL OID for Namespace */
  nshandler       varchar2(255)           ,             /* Namespace Handler */
  nsaudit         number(10)              ,                 /* Audit Options */
  flags           number(10)              ,               /* Namespace Flags */
  attrvalue       varchar2(4000)                          /* Attribute Value */
)
tablespace SYSAUX
/
create table xs$session_hws
(
  sid             raw(16)        not null ,       /* Light Weight Session ID */
  hwsid           number         not null ,       /* Heavy Weight Session ID */
  hwserial#       number         not null , /* Heavy Weight Session serial # */
  flags           number(10)     not null                           /* Flags */
)
tablespace SYSAUX
/
create table xs$parameters
(
  name            varchar2(256)  not null ,                /* Parameter Name */
  value           varchar2(4000) not null ,               /* Parameter Value */
  description     varchar2(4000) not null           /* Parameter Description */
)
/



Rem  Add Data Mining objects (ddm.bsq)
Rem  
Rem  data mining model table
Rem  the audit$ field length should be the same as S_OPFL defined in gendef.
create table model$
(
  obj#                number      not null,        /* unique model object id */
  func                number,                 /* mining function (bit flags) */
  alg                 number,                /* mining algorithm (bit flags) */
  bdur                number,                               /* time to build */
  msize               number,                          /* size of model (MB) */
  version             number,                               /* model version */
  audit$              varchar2(38) not null        /* auditing options */
)
storage (maxextents unlimited)
tablespace SYSAUX
/
create unique index model$idx
  on model$ (obj#)
storage (maxextents unlimited)
tablespace SYSAUX
/

Rem data mining model components table
create table modeltab$
(
  mod#                number       not null,              /* model object id */
  obj#                number       not null,              /* table object id */
  typ#                number       not null              /* model table type */
)
storage (maxextents unlimited)
tablespace SYSAUX
/
create unique index modeltab$idx
  on modeltab$ (mod#, typ#)
storage (maxextents unlimited)
tablespace SYSAUX
/

Rem data mining model attribute table
create table modelatt$
(
  mod#                number         not null,            /* model object id */
  name                varchar2(30)   not null,             /* attribute name */
  atyp                number,                              /* attribute type */
  dtyp                number         not null,                  /* data type */
  length              number,                                 /* data length */
  precision#          number,                                   /* precision */
  scale               number,                                       /* scale */
  properties          number                                   /* properties */
)
storage (maxextents unlimited)
tablespace SYSAUX
/
create index modelatt$idx
  on modelatt$ (mod#)
storage (maxextents unlimited)
tablespace SYSAUX
/

Rem data mining model settings table
create table modelset$
(
  mod#                number         not null,            /* model object id */
  name                varchar2(30)   not null,               /* setting name */
  value               varchar2(4000),                       /* setting value */
  properties          number                                   /* properties */
)
storage (maxextents unlimited)
tablespace SYSAUX
/
create index modelset$idx
  on modelset$ (mod#)
storage (maxextents unlimited)
tablespace SYSAUX
/
create or replace type ora_mining_table_type as object
  (table_name varchar2(30),
   table_type varchar2(30))
/
create or replace public synonym ora_mining_table_type
for sys.ora_mining_table_type
/
grant execute on ora_mining_table_type to public with grant option
/
create or replace type ora_mining_tables_nt as
table of sys.ora_mining_table_type
/
create or replace public synonym ora_mining_tables_nt
for sys.ora_mining_tables_nt
/
grant execute on ora_mining_tables_nt to public
/
create sequence DM$EXPIMP_ID_SEQ
/
grant select on DM$EXPIMP_ID_SEQ to public
/

 

Rem --------------------------------------------------
Rem increase column sumagg$.agginfo size to 4000 [bug-4054238]
Rem 
alter table sumagg$ modify agginfo varchar2(4000);

Rem
Rem Add edition name column to aud$, fga_log$
Rem
alter table fga_log$ add (obj$edition varchar2(30));

DECLARE
  schema_name   VARCHAR2(10);
BEGIN
  -- find out in which schema AUD$ table exists
  SELECT u.name INTO schema_name FROM obj$ o, user$ u
         WHERE o.name = 'AUD$' AND o.type#=2 AND o.owner# = u.user#
               AND u.name IN ('SYS', 'SYSTEM');

  -- construct Alter Table statement and execute it
  EXECUTE IMMEDIATE
     'ALTER TABLE ' || dbms_assert.enquote_name(schema_name, FALSE) 
                    || '.AUD$ add (' 
                    || ' obj$edition varchar2(30))';
END;
/


Rem ------------------------------------------------------------------------
Rem move the smon scn-time mapping table from sys tablespace to sysaux - END
Rem ------------------------------------------------------------------------

Rem start clean
drop table smon_scn_time_aux
/

create cluster smon_scn_to_time_aux (
  thread number                                     /* thread, compatibility */
) tablespace SYSAUX
/


BEGIN
   execute immediate 
    'create index smon_scn_to_time_aux_idx on cluster smon_scn_to_time_aux';
EXCEPTION WHEN OTHERS THEN
   IF SQLCODE = -2033 THEN NULL;  -- cluster index already exists
   END IF;
END;
/

create table smon_scn_time_aux (
  thread number,                                    /* thread, compatibility */
  time_mp number,                         /* time this recent scn represents */
  time_dp date,                               /* time as date, compatibility */
  scn_wrp number,                                  /* scn.wrp, compatibility */
  scn_bas number,                                  /* scn.bas, compatibility */
  num_mappings number,
  tim_scn_map raw(1200),
  scn number default 0,                                               /* scn */
  orig_thread number default 0                              /* for downgrade */
) cluster smon_scn_to_time_aux (thread)
/

rem copy over values from the old table
insert into smon_scn_time_aux select distinct * from smon_scn_time
/

commit
/

Rem ===========================
Rem changes for bug 6270136 - 9.2 mappings may have null for num_mappings
Rem ===========================
update smon_scn_time_aux set num_mappings = 0 where num_mappings is NULL
/
commit
/

rem exceptions table to catch dup time_mp and scn values in smon_scn_time_aux
create table exceptions(row_id rowid,
                        owner varchar2(30),
                        table_name varchar2(30),
                        constraint varchar2(30))
/

rem delete duplicates of time_mp from smon_scn_time_aux so create index succeeds
declare
  dup_exist boolean := TRUE;
  dup_keys_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(dup_keys_found, -2299);
begin
  while (dup_exist = TRUE) loop
  begin
    execute immediate
      'alter table smon_scn_time_aux add constraint smon_scn_time_cons01 
         unique(time_mp) exceptions into exceptions';
  exception
    when dup_keys_found then
      delete from smon_scn_time_aux where rowid in
        (select minrid from (SELECT time_mp, MIN(e.row_id) minrid
                               FROM EXCEPTIONS e,  smon_scn_time_aux t
                               WHERE t.ROWID=e.row_id GROUP BY  time_mp)
        );
      commit;
    continue;
  end;
    dup_exist := FALSE;
  end loop;
end;
/

rem drop the constraint built above to remove duplicates
alter table smon_scn_time_aux drop constraint smon_scn_time_cons01
/

rem start afresh for deleting duplicates for scn column
truncate table exceptions
/

rem delete duplicates of scn from smon_scn_time_aux so create index succeeds
declare 
  dup_exist boolean := TRUE;
  dup_keys_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(dup_keys_found, -2299);
begin
  while (dup_exist = TRUE) loop
  begin
    execute immediate
      'alter table smon_scn_time_aux add constraint smon_scn_time_cons01 
         unique(scn) exceptions into exceptions';
  exception
    when dup_keys_found then
      delete from smon_scn_time_aux where rowid in 
        (select minrid from (SELECT scn, MIN(e.row_id) minrid 
                               FROM EXCEPTIONS e,  smon_scn_time_aux t
                               WHERE t.ROWID=e.row_id GROUP BY  scn)
        );
      commit;
    continue;
  end;
    dup_exist := FALSE;
  end loop;
end;
/

rem drop the constraint built above to remove duplicates
alter table smon_scn_time_aux drop constraint smon_scn_time_cons01
/

rem drop the exceptions table created to remove duplicates in smon_scn_time_aux
drop table exceptions
/

rem drop indexes of smon_scn_time to create the same on smon_scn_time_aux
drop index smon_scn_time_tim_idx
/
drop index smon_scn_time_scn_idx
/

rem recreate the indeces - should succeed as we have removed duplicates
create unique index smon_scn_time_tim_idx on smon_scn_time_aux(time_mp) 
  tablespace SYSAUX
/
create unique index smon_scn_time_scn_idx on smon_scn_time_aux(scn)
  tablespace SYSAUX
/

rem drop the table and its associated indeces
drop table smon_scn_time
/
drop cluster smon_scn_to_time
/

rem rename the temporary table smon_scn_time_aux to its new name smon_scn_time
alter table smon_scn_time_aux rename to smon_scn_time
/

Rem ----------------------------------------
Rem SQL Plan Management (SPM) - BEGIN
Rem ----------------------------------------

rem create new table sqllog and sequence for it
 
CREATE TABLE sqllog$ (
       signature           NUMBER,
       batch#              NUMBER        NOT NULL,
       CONSTRAINT sqllog$_pkey PRIMARY KEY (signature)
     )
     ORGANIZATION INDEX
     TABLESPACE sysaux
    /

CREATE SEQUENCE sqllog$_seq
      START WITH 1
      INCREMENT BY 1
      MINVALUE 1
      MAXVALUE 100000000000000000000
      NOORDER
      CYCLE
    /

rem create new table smb$config
CREATE TABLE smb$config (
       parameter_name      VARCHAR2(30)  NOT NULL,
       parameter_value     NUMBER        NOT NULL,
       last_updated        TIMESTAMP,
       updated_by          VARCHAR2(30)
    )
     TABLESPACE sysaux
    /


CREATE UNIQUE INDEX i_smb$config_pkey ON smb$config (parameter_name)
     TABLESPACE sysaux
    /

-- Store 10 percent as the default SYSAUX storage space for SMB.
INSERT INTO smb$config (parameter_name, parameter_value)
     VALUES ('SPACE_BUDGET_PERCENT', 10)
    /

-- Store 53 weeks as the default retention period for plan baselines.
INSERT INTO smb$config (parameter_name, parameter_value)
     VALUES ('PLAN_RETENTION_WEEKS', 53)
    /

-- Store 0 as the default debug value for the tracing of DBMS_SPM code.
INSERT INTO smb$config (parameter_name, parameter_value)
     VALUES ('SPM_TRACING', 0)
    /

rem create new table sqlobj$
CREATE TABLE sqlobj$ (
   signature           NUMBER,                                   /* join key */
   category            VARCHAR2(30),                             /* join key */
   obj_type            NUMBER,                                   /* join key */
   plan_id             NUMBER,                                   /* join key */
   name                VARCHAR2(30)  NOT NULL,                 /* search key */
   flags               NUMBER        NOT NULL,
   last_executed       TIMESTAMP,
   spare1              NUMBER,
   spare2              CLOB,
   CONSTRAINT sqlobj$_pkey PRIMARY KEY (signature,
                                        category,
                                        obj_type,
                                        plan_id)
 )
ORGANIZATION INDEX
 TABLESPACE sysaux
/
CREATE UNIQUE INDEX i_sqlobj$name_type on sqlobj$(name, obj_type)
 TABLESPACE sysaux
/

rem create new table sqlobj$data
rem table population is done in a1002000.sql (need to use XML Package)
CREATE TABLE sqlobj$data (
       signature           NUMBER,                               /* join key */
       category            VARCHAR2(30),                         /* join key */
       obj_type            NUMBER,                               /* join key */
       plan_id             NUMBER,                               /* join key */
       comp_data           CLOB          NOT NULL,       /* hints collection */
       spare1              NUMBER,
       spare2              CLOB,
       CONSTRAINT sqlobj$data_pkey PRIMARY KEY (signature,
                                               category,
                                               obj_type,
                                               plan_id)
    )
   ORGANIZATION INDEX
    TABLESPACE sysaux
   /

rem create new table sqlobj$auxdata. It is populated in a1002000.sql
CREATE TABLE sqlobj$auxdata (
   signature            NUMBER        NOT NULL,                  /* join key */
   category             VARCHAR2(30)  NOT NULL,                  /* join key */
   obj_type             NUMBER        NOT NULL,                  /* join key */
   plan_id              NUMBER        NOT NULL,                  /* join key */
   description          VARCHAR2(500),
   creator              VARCHAR2(30),
   origin               NUMBER        NOT NULL,        /* manual, auto, etc. */
   version              VARCHAR2(64),               /* db version @ creation */
-- temporal data
   created              TIMESTAMP     NOT NULL,
   last_modified        TIMESTAMP,
   last_verified        TIMESTAMP,
-- compilation information
   parse_cpu_time       NUMBER,
   optimizer_cost       NUMBER,
-- user criteria
   module               VARCHAR2(48),
   action               VARCHAR2(32),
   priority             NUMBER,
-- execution context
   optimizer_env        RAW(2000),
   bind_data            RAW(2000),
   parsing_schema_name  VARCHAR2(30),
-- execution statistics
   executions           NUMBER,
   elapsed_time         NUMBER,
   cpu_time             NUMBER,
   buffer_gets          NUMBER,
   disk_reads           NUMBER,
   direct_writes        NUMBER,
   rows_processed       NUMBER,
   fetches              NUMBER,
   end_of_fetch_count   NUMBER,
-- map sql profile data back to the tuning task that created it
   task_id              NUMBER,                          /* adv fmwk task id */
   task_exec_name       VARCHAR2(30),             /* adv fmwk execution name */
   task_obj_id          NUMBER,                        /* adv fmwk object id */
   task_fnd_id          NUMBER,                       /* adv fmwk finding id */
   task_rec_id          NUMBER,                /* adv fmwk recommendation id */
   flags                NUMBER,                               /* spare flags */
   spare1               NUMBER,
   spare2               CLOB
 )
 TABLESPACE sysaux
/
CREATE UNIQUE INDEX i_sqlobj$auxdata_pkey ON sqlobj$auxdata (signature,
                                                             category, 
                                                             obj_type,
                                                             plan_id)
 TABLESPACE sysaux
/

CREATE INDEX i_sqlobj$auxdata_task ON sqlobj$auxdata
 (task_id, task_exec_name, task_obj_id, task_fnd_id, task_rec_id)
 TABLESPACE sysaux
/


Rem 
Rem This table will be re-created in a1002000.sql and populated.
Rem add a column to is in here make sure the dba_sql_plan_baselines 
Rem will be created without error, and so the dbms_spm package. 
Rem Note that the a100xxxx.sql scripts are executed after cat*.sql, 
Rem dbms*.sql, prvt*plb are sourced.
Rem
alter table  sql$text add (sql_handle VARCHAR2(30))
/

Rem
Rem add a new "administer sql management object" privilege
Rem

insert into SYSTEM_PRIVILEGE_MAP 
values (-327, 'ADMINISTER SQL MANAGEMENT OBJECT', 0);

insert into STMT_AUDIT_OPTION_MAP 
values (327, 'ADMINISTER SQL MANAGEMENT OBJECT', 0);

Rem ----------------------------------------
Rem SQL Plan Management (SPM) - END
Rem ----------------------------------------  

Rem
Rem  insert_tsn_list$ table(from dpart.bsq)
Rem  This table has a row per tablespace specified in the store-in clause
Rem  for interval partitioned tables. These tablespaces are used in a 
Rem  round-robin fashion for on-the-fly segment creation during inserts
Rem  bo#,position# forms the key
Rem
create table insert_tsn_list$ (
  bo#       number not null,      /* object number of base partitioned table */
  position# number not null,     /* position of tablespace specified by user */
  ts#       number not null)                            /* tablespace number */
/

Rem=========================================================================
Rem Add changes to other SYS dictionary objects here 
Rem     (created in catproc.sql scripts)
Rem=========================================================================  

Rem drop transportable tablespace global temporary tables.
drop table sys.transts_tmp$;
drop table sys.transts_error$;


Rem Use TIMESTAMP for registry$history (8.1.7, 9.0.1, 9.2.0 CPUs used DATE)
ALTER TABLE registry$history modify (action_time TIMESTAMP);
Rem Add tz_version to registry$ database if it is not already there
ALTER TABLE registry$database ADD (tz_version NUMBER);

Rem ===============================
Rem Begin streams changes drep.bsq
Rem ===============================

CREATE TABLE comparison$(
  comparison_id      NUMBER NOT NULL,
  comparison_name    VARCHAR2(30) NOT NULL,
  user#              NUMBER,
  comparison_mode    NUMBER,
  schema_name        VARCHAR2(30),   
  object_name        VARCHAR2(30),   
  object_type        NUMBER,
  rmt_schema_name    VARCHAR2(30),   
  rmt_object_name    VARCHAR2(30),   
  rmt_object_type    NUMBER,
  dblink_name        VARCHAR2(128),  
  scan_mode          NUMBER,
  scan_percent       NUMBER,
  cyl_idx_val        VARCHAR2(100),
  null_value         VARCHAR2(4000),
  loc_converge_tag   RAW(2000),
  rmt_converge_tag   RAW(2000),
  max_num_buckets    NUMBER,
  min_rows_in_bucket NUMBER,
  last_update_time   TIMESTAMP,
  flags              NUMBER,
  spare1             NUMBER,           
  spare2             NUMBER,
  spare3             NUMBER,
  spare4             VARCHAR2(1000)
)
tablespace SYSAUX
/
CREATE UNIQUE INDEX cmp_uniq_idx1 ON comparison$ (comparison_id)
tablespace SYSAUX
/

CREATE UNIQUE INDEX cmp_uniq_idx2 ON comparison$ (comparison_name)
tablespace SYSAUX
/

rem 
rem Stores the index columns as well as other columns used in comparison.
rem

CREATE TABLE comparison_col$(
  comparison_id      NUMBER             NOT NULL,
  col_position       NUMBER             NOT NULL,
  col_name           VARCHAR2(30)       NOT NULL,
  data_type          NUMBER,
  flags              NUMBER,
  spare1             NUMBER,           
  spare2             NUMBER,
  spare3             NUMBER,
  spare4             VARCHAR2(1000)
)
tablespace SYSAUX
/

CREATE UNIQUE INDEX cmpcol_uniq_idx1 ON comparison_col$ 
(comparison_id, col_position, col_name)
tablespace SYSAUX
/

Rem
Rem Stores the results for a particular scan iteration of a comparison.
Rem Each top level scan will have the parent_scan_id as NULL.
Rem 
CREATE TABLE comparison_scan$ (
  comparison_id         NUMBER  NOT NULL,
  scan_id               NUMBER  NOT NULL,  
  parent_scan_id        NUMBER,
  num_rows              NUMBER,
  status                NUMBER,
  flags                 NUMBER,
  last_update_time      TIMESTAMP,
  spare1                NUMBER,           
  spare2                NUMBER,
  spare3                NUMBER,
  spare4                VARCHAR2(1000)
)
tablespace SYSAUX
/

CREATE UNIQUE INDEX cmp_scan_uniq_idx ON comparison_scan$ 
  (comparison_id, scan_id)
tablespace SYSAUX
/

rem
rem Stores the column ranges for a scan.
rem 
CREATE TABLE comparison_scan_val$ (
  comparison_id         NUMBER NOT NULL,
  scan_id               NUMBER NOT NULL,  
  column_position       NUMBER NOT NULL,
  min_val               VARCHAR2(4000),
  max_val               VARCHAR2(4000),
  flags                 NUMBER,
  last_update_time      TIMESTAMP,
  spare1                NUMBER,           
  spare2                NUMBER,
  spare3                NUMBER,
  spare4                VARCHAR2(1000)
)
tablespace SYSAUX
/

CREATE UNIQUE INDEX cmp_scan_val_uniq_idx ON comparison_scan_val$ 
  (comparison_id, scan_id, column_position)
tablespace SYSAUX
/

Rem Stores the row difs of a scan
CREATE TABLE comparison_row_dif$ (
  comparison_id         NUMBER          NOT NULL,
  scan_id               NUMBER          NOT NULL,
  loc_rowid             ROWID,
  rmt_rowid             ROWID,
  idx_val               VARCHAR2(4000),
  status                NUMBER,
  last_update_time      TIMESTAMP,
  spare1                NUMBER,           
  spare2                NUMBER,
  spare3                NUMBER,
  spare4                VARCHAR2(1000)
)
tablespace SYSAUX
/

CREATE UNIQUE INDEX cmp_row_dif_uniq_idx_1 ON comparison_row_dif$ 
  (comparison_id, scan_id, loc_rowid, rmt_rowid)
tablespace SYSAUX
/

CREATE UNIQUE INDEX cmp_row_dif_uniq_idx_2 ON comparison_row_dif$ 
  (comparison_id, scan_id, rmt_rowid, loc_rowid)
tablespace SYSAUX
/

CREATE SEQUENCE comparison_seq$  
  START WITH 1 
  INCREMENT BY 1
  MINVALUE 1
  NOCACHE
/

CREATE SEQUENCE comparison_scan_seq$ 
  START WITH 1
  INCREMENT BY 1
  MINVALUE 1
  MAXVALUE 4294967295
  CYCLE
  CACHE 20
/

Rem ===============================
Rem End streams changes
Rem ===============================

Rem ===============================
Rem Begin dbms_scheduler changes
Rem ===============================

Rem drop obsolete scheduler objects
drop function scheduler$_argpipe;
drop function scheduler$_jobpipe;

drop type scheduler$_job_results;
drop type scheduler$_jobarg_view_t;
drop type scheduler$_job_view_t;
drop type scheduler$_jobarglst_t;
drop type scheduler$_joblst_t;
drop type scheduler$_job_argument_t;
drop type scheduler$_job_t;
drop type scheduler$_job_external;
drop type scheduler$_job_mutable;
drop type scheduler$_job_fixed;

drop library scheduler_job_lib;

drop table sys.scheduler$_oldoids;
drop sequence sys.scheduler$_oldoids_s;

Rem Changes to allow scheduler to run on standby servers
alter table scheduler$_job add 
  (database_role varchar2(16),
   instance_id   number,
   dist_flags    number);
alter table scheduler$_event_log add dbid number;

Rem Changes to allow scheduler to store distinguished name
alter table scheduler$_job add owner_udn varchar2(4000);

alter table sys.scheduler$_program add 
  (schedule_limit  interval day(3) to second (0),
   priority        number, 
   job_weight      number, 
   max_runs        number, 
   max_failures    number,
   max_run_duration interval day(3) to second(0),
   nls_env           varchar2(4000),
   env               raw(32));
   
Rem Add columns to job$
ALTER TABLE sys.job$ add 
  (scheduler_flags number,
   xid             varchar2(40));

Rem add new columns for job credentials
alter table scheduler$_job add (credential_name   varchar2(30));
alter table scheduler$_job add (credential_owner  varchar2(30));
alter table scheduler$_job add (credential_oid    number);
alter table scheduler$_event_log add (destination varchar2(128));
alter table scheduler$_step add (credential_name   varchar2(30));
alter table scheduler$_step add (credential_owner  varchar2(30));
alter table scheduler$_step add (destination       varchar2(128));


Rem Modify length of event agent column
alter table scheduler$_job modify (queue_agent varchar2(256));

Rem Make necessary changes to srcq_map table
alter table scheduler$_srcq_map add (flags number);
alter table scheduler$_srcq_map modify (rule_name varchar2(256));

Rem ==========================
Rem End dbms_scheduler changes
Rem ==========================

Rem ============================================================================
Rem Begin advisor framework changes
Rem ============================================================================
Rem 
Rem rename sqltune task internal parameter _SQLTUNE_TRACE to _TRACE_CONTROL.
Rem Please NOTE that the query we are using to rename the chaged parameter 
Rem refers to the advisor definition table which is truncated in the next
Rem statement. So please this query must be executed first

BEGIN
  -- 1. rename parameter in the parameter definition table
  EXECUTE IMMEDIATE q'#UPDATE wri$_adv_def_parameters 
                       SET name = '_TRACE_CONTROL' 
                       WHERE name = '_SQLTUNE_TRACE' and 
                             advisor_id = (SELECT id 
                                           FROM wri$_adv_definitions 
                                           WHERE name = 'SQL Tuning Advisor')#';

  -- 2. rename parameter for the existing sql tuning advisor tasks  
  EXECUTE IMMEDIATE q'#UPDATE wri$_adv_parameters p 
                       SET name = '_TRACE_CONTROL' 
                       WHERE name = '_SQLTUNE_TRACE' AND 
                             EXISTS (SELECT 1 
                                     FROM wri$_adv_tasks t 
                                     WHERE p.task_id = t.id AND 
                                      t.advisor_name = 'SQL Tuning Advisor')#';

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

Rem 
Rem As a workaround truncate the sys.wri$_adv_definitions table. This table 
Rem contains instances of the object types altered below. 
Rem Altering a type to be NOT FINAL is generating an ora-600 during upgrade
Rem the command tries to update the instances already present in the table.
Rem new nstances of these object types will be re-created in catproc.sql, anyway.
Rem 
BEGIN
   EXECUTE IMMEDIATE 'TRUNCATE TABLE SYS.WRI$_ADV_DEFINITIONS';
EXCEPTION 
  WHEN OTHERS THEN
    IF SQLCODE = -942 
      THEN NULL;
    ELSE
      RAISE;
    END IF;
END;
/

Rem
Rem the _sqltune_control parameter has an additional value for the
Rem alternate plan analysis engine in 11g.  Change the default parameter
Rem value prior to upgrade.

BEGIN
  EXECUTE IMMEDIATE
    'UPDATE wri$_adv_def_parameters 
     SET value = ''15'' 
     WHERE name = ''_SQLTUNE_CONTROL'' and advisor_id = 4 and value = ''7''';
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

Rem ++++++++++++++++++++++++++++++++++++++++++
Rem 1. Changes in the advisor abstract objects
Rem ++++++++++++++++++++++++++++++++++++++++++
Rem drop methods here 
Rem ++++++++++++++++++++
Rem
Rem resume
Rem
ALTER TYPE wri$_adv_sqlaccess_adv
  DROP OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_sqltune
  DROP OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_tunemview_adv
  DROP OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_abstract_t
  DROP MEMBER procedure sub_resume(task_id IN NUMBER)
  CASCADE;


Rem
Rem script
Rem
ALTER TYPE wri$_adv_sqltune
  DROP OVERRIDING MEMBER procedure sub_get_script(task_id IN NUMBER,
                                                  type IN VARCHAR2,
                                                  buffer IN OUT NOCOPY CLOB,
                                                  rec_id IN NUMBER,
                                                  act_id IN NUMBER)
  CASCADE;

Rem
Rem report
Rem
ALTER TYPE wri$_adv_sqltune 
  DROP OVERRIDING MEMBER procedure sub_get_report(task_id IN NUMBER,
                                                  type IN VARCHAR2,
                                                  level IN VARCHAR2,
                                                  section IN VARCHAR2,
                                                  buffer IN OUT NOCOPY CLOB)
  CASCADE;


Rem add new method here
Rem ++++++++++++++++++++
Rem
Rem resume 
Rem 
ALTER TYPE wri$_adv_abstract_t
  ADD MEMBER procedure sub_resume(task_id IN NUMBER, err_num OUT NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_sqltune
  ADD OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER, 
                                             err_num OUT NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_sqlaccess_adv
  ADD OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER, 
                                             err_num OUT NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_tunemview_adv
  ADD OVERRIDING MEMBER procedure sub_resume(task_id IN NUMBER, 
                                             err_num OUT NUMBER)
  CASCADE;


Rem
Rem script 
Rem
ALTER TYPE wri$_adv_abstract_t
  ADD MEMBER procedure sub_get_script(task_id IN NUMBER,
                                      type IN VARCHAR2,
                                      buffer IN OUT NOCOPY CLOB,
                                      rec_id IN NUMBER,
                                      act_id IN NUMBER,
                                      execution_name IN VARCHAR2,
                                      object_id IN NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_sqltune 
  ADD OVERRIDING MEMBER procedure sub_get_script(task_id IN NUMBER,
                                                 type IN VARCHAR2,
                                                 buffer IN OUT NOCOPY CLOB,
                                                 rec_id IN NUMBER,
                                                 act_id IN NUMBER,
                                                 execution_name IN VARCHAR2,
                                                 object_id IN NUMBER)
  CASCADE;

Rem
Rem report
Rem
ALTER TYPE wri$_adv_abstract_t
  ADD MEMBER procedure sub_get_report(task_id IN NUMBER,
                                      type IN VARCHAR2,
                                      level IN VARCHAR2,
                                      section IN VARCHAR2,
                                      buffer IN OUT NOCOPY CLOB, 
                                      execution_name IN VARCHAR2,
                                      object_id IN NUMBER)
  CASCADE;

ALTER TYPE wri$_adv_sqltune 
  ADD OVERRIDING MEMBER procedure sub_get_report(task_id IN NUMBER,
                                                 type IN VARCHAR2,
                                                 level IN VARCHAR2,
                                                 section IN VARCHAR2,
                                                 buffer IN OUT NOCOPY CLOB, 
                                                 execution_name IN VARCHAR2,
                                                 object_id IN NUMBER)
  CASCADE;

Rem
Rem delete execution
Rem
ALTER TYPE wri$_adv_abstract_t
  ADD MEMBER procedure sub_delete_execution(task_id IN NUMBER, 
                                            execution_name IN VARCHAR2)
  CASCADE;

ALTER TYPE wri$_adv_sqltune
  ADD OVERRIDING MEMBER procedure sub_delete_execution(
                                                    task_id IN NUMBER, 
                                                    execution_name IN VARCHAR2)
  CASCADE;

ALTER TYPE wri$_adv_sqltune
  ADD OVERRIDING MEMBER procedure sub_param_validate(task_id IN NUMBER,
                                                     name    IN VARCHAR2, 
                                                     value   IN OUT VARCHAR2)
  CASCADE;

Rem change object type properties here
Rem +++++++++++++++++++++++++++++++++++
ALTER TYPE wri$_adv_sqltune NOT FINAL CASCADE;


Rem +++++++++++++++++++++++++++++++++++++++++++
Rem 2. Changes in the advisor dictionary tables
Rem +++++++++++++++++++++++++++++++++++++++++++
ALTER TABLE wri$_adv_def_parameters ADD (exec_type varchar2(30))
/
ALTER TABLE wri$_adv_tasks ADD (last_exec_name varchar2(30))
/
ALTER TABLE wri$_adv_objects ADD (exec_name varchar2(30),
                                  attr6     raw(2000),
                                  attr7     number,
                                  attr8     number,
                                  attr9     number,
                                  attr10    number)
/
ALTER TABLE wri$_adv_findings ADD (exec_name varchar2(30))
/
ALTER TABLE wri$_adv_recommendations ADD (exec_name varchar2(30))
/
ALTER TABLE wri$_adv_actions ADD (exec_name varchar2(30))
/
ALTER TABLE wri$_adv_rationale ADD (exec_name varchar2(30))
/
ALTER TABLE wri$_adv_journal ADD (exec_name varchar2(30))
/
ALTER TABLE wri$_adv_message_groups ADD (exec_name varchar2(30))
/

Rem Add the extra column to the wri$_adv_findings
Rem the new version of the views will be created by the catproc

alter table wri$_adv_findings add (name_msg_code   varchar2(9));

Rem ============================================================================
Rem End advisor framework changes
Rem ============================================================================



Rem ============================================================================
Rem Begin sql tuning advisor changes
Rem ============================================================================

Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem The temp table we use for captures now has a different primary key name
Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ALTER TABLE wri$_sqlset_plans_tocap 
  RENAME CONSTRAINT wri$_sqlset_plans_tocap TO wri$_sqlset_plans_tocap_pk;

Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem Rename the index using EXEC IMMED to avoid errors on re-run (these are
Rem not suppressed)
Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
begin
  EXECUTE IMMEDIATE 'ALTER INDEX wri$_sqlset_plans_tocap ' ||
                    'RENAME TO wri$_sqlset_plans_tocap_pk';
exception
  when others then
    if (sqlcode = -1418) then               /* specified index does not exist */
      null;
    else
      raise;
    end if;
end;
/

Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem Add the extra columns to the plan_lines table that are new to 11g
Rem The new versions of the views will be created by catproc
Rem +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
alter table wri$_sqlset_plan_lines add (
  last_starts            NUMBER,
  last_output_rows       NUMBER,
  last_cr_buffer_gets    NUMBER,
  last_cu_buffer_gets    NUMBER,
  last_disk_reads        NUMBER,
  last_disk_writes       NUMBER,
  last_elapsed_time      NUMBER,
  policy                 VARCHAR2(10),
  estimated_optimal_size NUMBER,
  estimated_onepass_size NUMBER,
  last_memory_used       NUMBER,
  last_execution         VARCHAR2(10),
  last_degree            NUMBER,
  total_executions       NUMBER,
  optimal_executions     NUMBER,
  onepass_executions     NUMBER,
  multipasses_executions NUMBER,
  active_time            NUMBER,
  max_tempseg_size       NUMBER,
  last_tempseg_size      NUMBER)
/

Rem ++++++++++++++++++++++++++++++++++++++++++
Rem Changes in the SQL tuning advisor tables
Rem ++++++++++++++++++++++++++++++++++++++++++
Rem
Rem add exec_name column to existing tables
Rem
ALTER TABLE wri$_adv_sqlt_rtn_plan ADD (exec_name varchar2(30))
/

Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem Upgrade SQL tuning tasks.
Rem Notice that the other advisor tables are upgraded as part 
Rem advisor framework upgrade in script a1002000.sql
Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
DECLARE 
  ename varchar2(30) := 'UPGRADED_EXEC';
BEGIN 

  execute immediate 'UPDATE wri$_adv_sqlt_rtn_plan set exec_name = :ename'
  using ename;
  
  -- exception handler
  EXCEPTION
    WHEN OTHERS THEN
      -- the two tables do not exist yet if we are upgrading from 
      -- a pre-10g release.
      IF (SQLCODE = -942) THEN
        NULL;
      ELSE
        RAISE;
      END IF;
END; 
/

Rem ++++++++++++++++++++++++++++++++++++++++++
Rem Modify existing constraints
Rem ++++++++++++++++++++++++++++++++++++++++++
Rem plan-rational association table 
ALTER TABLE wri$_adv_sqlt_rtn_plan DROP CONSTRAINT wri$_adv_sqlt_rtn_plan_pk
/
ALTER TABLE wri$_adv_sqlt_rtn_plan ADD CONSTRAINT wri$_adv_sqlt_rtn_plan_pk
  PRIMARY KEY(task_id, exec_name, rtn_id, object_id, plan_attr, operation_id)
  USING INDEX TABLESPACE SYSAUX
/

Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem Bug#5518178: extend size of optimizer env column to 2000
Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
ALTER TABLE wri$_adv_sqlt_statistics MODIFY (optimizer_env RAW(2000))
/
ALTER TABLE wri$_sqlset_plans MODIFY (optimizer_env RAW(2000))
/
Rem
Rem Notice that only widening of type attributes is allowed. This 
Rem is why we drop this type here and in the e1002000 downgrade script 
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

Rem ============================================================================
Rem End sql tuning advisor changes
Rem ============================================================================


Rem ============================================================================
Rem Begin SQL tuning set workspace changes
Rem ============================================================================

Rem This will drop the workspace table and its nested table as well. 
Rem the table will be re-created in the catsqlt.sql script.
DROP TABLE wri$_sqlset_workspace
/

Rem ============================================================================
Rem End SQL tuning set workspace changes
Rem ============================================================================

Rem ============================================================================
Rem Begin ADDM changes
Rem ============================================================================

alter type wri$_adv_hdm_t 
add overriding MEMBER PROCEDURE sub_param_validate(
               task_id in number, name in varchar2, value in out varchar2), 
add overriding member procedure sub_reset(task_id in number),
add overriding member procedure sub_delete(task_id in number)
cascade;

Rem ============================================================================
Rem End ADDM changes
Rem ============================================================================


Rem=============
Rem AWR Changes
Rem=============

Rem Add plsql_entry_object_id, plsql_entry_subprogram_id,
Rem     plsql_object_id, plsql_subprogram_id to
Rem     WRH$_ACTIVE_SESSION_HISTORY, WRH$_ACTIVE_SESSION_HISTORY_BL

alter table WRH$_ACTIVE_SESSION_HISTORY add (consumer_group_id         NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (plsql_entry_object_id     NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (plsql_entry_subprogram_id NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (plsql_object_id           NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (plsql_subprogram_id       NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (qc_session_serial#        NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (remote_instance#          NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (sql_plan_line_id          NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (sql_plan_operation#       NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (sql_plan_options#         NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (sql_exec_id               NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (sql_exec_start            DATE);
alter table WRH$_ACTIVE_SESSION_HISTORY add (time_model                NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (top_level_sql_id          VARCHAR2(13));
alter table WRH$_ACTIVE_SESSION_HISTORY add (top_level_sql_opcode      NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (current_row#              NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (flags                     NUMBER);

alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (consumer_group_id         NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (plsql_entry_object_id     NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (plsql_entry_subprogram_id NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (plsql_object_id           NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (plsql_subprogram_id       NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (qc_session_serial#        NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (remote_instance#          NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (sql_plan_line_id          NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (sql_plan_operation#       NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (sql_plan_options#         NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (sql_exec_id               NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (sql_exec_start            DATE);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (time_model                NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (top_level_sql_id          VARCHAR2(13));
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (top_level_sql_opcode      NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (current_row#              NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (flags                     NUMBER);

alter table WRH$_INST_CACHE_TRANSFER add (lost NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (cr_2hop NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (cr_3hop NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (current_2hop NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (current_3hop NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (cr_block_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (cr_busy_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (cr_congested_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (current_block_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (current_busy_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (current_congested_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (lost_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (cr_2hop_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (cr_3hop_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (current_2hop_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER add (current_3hop_time NUMBER);

alter table WRH$_INST_CACHE_TRANSFER_BL add (lost NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (cr_2hop NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (cr_3hop NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (current_2hop NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (current_3hop NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (cr_block_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (cr_busy_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (cr_congested_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (current_block_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (current_busy_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (current_congested_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (lost_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (cr_2hop_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (cr_3hop_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (current_2hop_time NUMBER);
alter table WRH$_INST_CACHE_TRANSFER_BL add (current_3hop_time NUMBER);
Rem Add total_waits_fg, total_timeouts_fg, time_waited_micro_fg to
Rem WRH$_SYSTEM_EVENT, WRH$_SYSTEM_EVENT_BL

alter table WRH$_SYSTEM_EVENT add (total_waits_fg       NUMBER);
alter table WRH$_SYSTEM_EVENT add (total_timeouts_fg    NUMBER);
alter table WRH$_SYSTEM_EVENT add (time_waited_micro_fg NUMBER);

alter table WRH$_SYSTEM_EVENT_BL add (total_waits_fg       NUMBER);
alter table WRH$_SYSTEM_EVENT_BL add (total_timeouts_fg    NUMBER);
alter table WRH$_SYSTEM_EVENT_BL add (time_waited_micro_fg NUMBER);

alter table WRH$_SYSMETRIC_SUMMARY add (sum_squares NUMBER);

alter table WRM$_BASELINE modify (start_snap_id      number  null);
alter table WRM$_BASELINE modify (end_snap_id        number  null);
alter table WRM$_BASELINE add    (baseline_type      varchar2(13));
alter table WRM$_BASELINE add    (moving_window_size number);
alter table WRM$_BASELINE add    (creation_time      date);
alter table WRM$_BASELINE add    (expiration         number);
alter table WRM$_BASELINE add    (template_name      varchar2(64));
alter table WRM$_BASELINE add    (last_time_computed date);

alter table WRH$_PGA_TARGET_ADVICE add (estd_time number);

alter table WRH$_SQLSTAT add (parsing_user_id number);
alter table WRH$_SQLSTAT_BL add (parsing_user_id number);

-- increase column size 
alter table WRH$_SQL_PLAN modify (PARTITION_START varchar2(64));
alter table WRH$_SQL_PLAN modify (PARTITION_STOP  varchar2(64));

-- PCTFREE of 1 for sysmetric_history table
alter table WRH$_SYSMETRIC_HISTORY pctfree 1;

Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++
Rem Bug#5518178: extend size of optimizer column to 2000
Rem ++++++++++++++++++++++++++++++++++++++++++++++++++++
ALTER TABLE wrh$_optimizer_env MODIFY (optimizer_env RAW(2000));

Rem
Rem Add PLATFORM_NAME to wrm$_database_instance
Rem
alter table WRM$_DATABASE_INSTANCE add (platform_name VARCHAR2(101));


BEGIN
  execute immediate
   'update WRM$_BASELINE 
      set baseline_type = ''STATIC'',
          creation_time = SYSDATE';
  execute immediate
   'insert into WRM$_BASELINE
      (dbid, baseline_id, baseline_name, start_snap_id, end_snap_id,
       baseline_type, moving_window_size, creation_time,
       expiration, template_name, last_time_computed)
    select 
        dbid, 0, ''SYSTEM_MOVING_WINDOW'', NULL, NULL,
        ''MOVING_WINDOW'', LEAST(91, extract(DAY from retention)), SYSDATE,
        NULL, NULL, NULL
     from WRM$_WR_CONTROL
    where dbid in (select dbid from v$database)';
  commit;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -942) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

Rem 
Rem Add the Most Recent Baseline Template ID  column to the WRM$_WR_CONTROL 
Rem table and set the the column to the Default value.
Rem
alter table WRM$_WR_CONTROL add (MRCT_BLTMPL_ID number);
BEGIN
  execute immediate 'update WRM$_WR_CONTROL set MRCT_BLTMPL_ID = 0';
  commit;
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -942) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

Rem
Rem Rename the Baseline tables
Rem 

DECLARE
  bl_moved number;
  /* table flag */
  KEWRTF_PARTN_BYSID      CONSTANT BINARY_INTEGER := POWER(2,  0);

  /* Baseline Original and Rename Suffix */
  KEWRTB_BL_ORIG_SUFFIX   CONSTANT VARCHAR2(3) := '_BL';
  KEWRTB_BL_RENAME_SUFFIX CONSTANT VARCHAR2(3) := '_BR';

  CURSOR awr_tables IS
    SELECT table_name_kewrtb table_name, 
           table_flag_kewrtb table_flag
      FROM sys.x$kewrtb;  
  tab awr_tables%ROWTYPE;

  CURSOR awr_indices IS
    SELECT io.name  name
      FROM sys.ind$ i, sys.obj$ io, sys.obj$ bo, sys.user$ iu
     WHERE i.obj#    = io.obj#
       AND i.bo#     = bo.obj#
       AND io.owner# = iu.user#
       AND iu.name   = 'SYS'
       AND bo.name like 'WRH$\_%\_BR' escape '\';
  ind awr_indices%ROWTYPE;

  CURSOR awr_constraints IS
    select oc.name name, o.name tabname 
      from  con$ oc, cdef$ cd, obj$ o, user$ u
     where oc.con# = cd.con#
       and cd.obj# = o.obj#
   and oc.owner# = u.user#
   and cd.type# in (2,3)                 /* primary key or unique constraint */
   and u.name = 'SYS'
   and o.name like 'WRH$\_%\_BR' escape '\';
  cons awr_constraints%ROWTYPE;

BEGIN

  /* open cursor to fetch AWR tables to do the Data Filtering */
  OPEN awr_tables;
  LOOP
    FETCH awr_tables INTO tab;
    EXIT WHEN awr_tables%NOTFOUND;

    IF (bitand(tab.table_flag, KEWRTF_PARTN_BYSID) = KEWRTF_PARTN_BYSID) THEN

      BEGIN
        /* rename the table from _BL to _BR */
        execute immediate 'alter table ' 
                      || dbms_assert.enquote_name(tab.table_name 
                      || KEWRTB_BL_ORIG_SUFFIX, FALSE)
                      || ' rename to ' 
                      || dbms_assert.enquote_name(tab.table_name 
                      || KEWRTB_BL_RENAME_SUFFIX, FALSE);
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE = -942) THEN NULL;
          ELSE RAISE;
          END IF;
      END;

    END IF;
  END LOOP;

  /* open cursor to fetch AWR index name */
  OPEN awr_indices;
  LOOP
    FETCH awr_indices INTO ind;
    EXIT WHEN awr_indices%NOTFOUND;

    BEGIN
      /* rename the index from _BL to _BR */
      execute immediate 'alter index ' 
            ||  dbms_assert.enquote_name(ind.name, FALSE)
            || ' rename to ' || 
            dbms_assert.enquote_name(replace(ind.name, '_BL_', '_BR_'), FALSE);
    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE = -955) THEN NULL;
        ELSE RAISE;
        END IF;
    END;
    
  END LOOP;

  /* open cursor to fetch AWR constraint names */
  OPEN awr_constraints;
  LOOP
    FETCH awr_constraints INTO cons;
    EXIT WHEN awr_constraints%NOTFOUND;

    BEGIN
      /* rename the constraint from _BL to _BR */
      execute immediate 'alter table '  || 
           dbms_assert.enquote_name(cons.tabname, FALSE) 
           || ' rename constraint ' || 
           dbms_assert.enquote_name(cons.name, FALSE) 
           || ' to '  ||  
           dbms_assert.enquote_name(replace(cons.name, '_BL_', '_BR_'), FALSE);
    EXCEPTION
      WHEN OTHERS THEN
        IF (SQLCODE = -2264) THEN NULL;
        ELSE RAISE;
        END IF;
    END;

  END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -942) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/


Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==          (11gR1 = SWRF Version 3)                 ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  upgrade changes.  Place all other AWR upgrade    ==
Rem ==  changes above this.                              ==
Rem =======================================================

BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control SET swrf_version = 3';
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

Rem=============
Rem End AWR Changes
Rem=============

Rem============================================================================
Rem Begin BSLN Changes
Rem============================================================================

Rem ********************************
Rem * 1. turn off the BSLN jobs if they are running
Rem ********************************

begin
  execute immediate 'begin dbsnmp.mgmt_bsln.delete_bsln_jobs; end;';
exception
when others then
  NULL;
end;
/

Rem ********************************
Rem * 2. drop the BSLN packages
Rem ********************************

drop package dbsnmp.mgmt_bsln;
drop package dbsnmp.mgmt_bsln_internal;

Rem ********************************
Rem * 3. drop the BSLN types
Rem ********************************

drop type dbsnmp.bsln_interval_set;
drop type dbsnmp.bsln_interval_t;

drop type dbsnmp.bsln_observation_set;
drop type dbsnmp.bsln_observation_t;

drop type dbsnmp.bsln_statistics_set;
drop type dbsnmp.bsln_statistics_t;

Rem ********************************
Rem * 4. save off (rename) the mgmt_bsln tables
Rem ********************************

declare

  -- prefixes to replace on rename
  K_BSLN_CURRPREFIX constant varchar2(10) := 'MGMT_BSLN_';
  K_BSLN_NEWPREFIX  constant varchar2(9)  := 'BSLN_102_';

begin

  -- loop over the set of tables
  for l_tab in
      (select table_name current_name
             ,K_BSLN_NEWPREFIX||SUBSTR(table_name,LENGTH(K_BSLN_CURRPREFIX)+1)
                         new_name
         from dba_tables
        where owner = 'DBSNMP'
          and table_name like K_BSLN_CURRPREFIX||'%')
  loop

    -- rename here, trapping exceptions that may arise in the case the 
    --  tables have already been renamed
    begin
      execute immediate 'alter table dbsnmp.'|| 
                        dbms_assert.enquote_name(l_tab.current_name, FALSE)||
                        ' rename to '|| 
                        dbms_assert.enquote_name(l_tab.new_name, FALSE);
    exception
    when others then
      if (SQLCODE = -942) then
        NULL;
      else
        raise;
      end if;
    end;

  end loop;

end;
/

Rem============================================================================
Rem End BSLN Changes
Rem============================================================================

Rem=======================
Rem Begin Logminer Changes
Rem=======================

Rem logminer needs a log group to track enc$
declare
  cnt number;
begin
  select count(1) into cnt
    from con$ co, cdef$ cd, obj$ o, user$ u
    where o.name = 'ENC$'
      and u.name = 'SYS'
      and co.name = 'ENC$_LOG_GRP'
      and cd.obj# = o.obj#
      and cd.con# = co.con#;
  if cnt = 0 then
    execute immediate 'alter table sys.enc$
                          add supplemental log group 
                          enc$_log_grp (obj#, owner#) always';
  end if;
end;
/

Rem drop obsolete logminer objects
drop table sys.logmnr_interesting_cols;
drop table system.logmnr_header1$;
drop table system.logmnr_header2$;
drop function sys.logmnr_dpc;
drop procedure sys.dbms_logmnr_octologmnrt;
drop procedure sys.logmnr_create_replace_metadata;

DROP TABLE SYS.LOGMNRT_SEED$;
DROP TABLE SYS.LOGMNRT_DICTIONARY$ ;
DROP TABLE SYS.LOGMNRT_OBJ$ ;
DROP TABLE SYS.LOGMNRT_TAB$ ;
DROP TABLE SYS.LOGMNRT_COL$ ;
DROP TABLE SYS.LOGMNRT_ATTRCOL$ ;
DROP TABLE SYS.LOGMNRT_TS$ ;
DROP TABLE SYS.LOGMNRT_IND$ ;
DROP TABLE SYS.LOGMNRT_USER$ ;
DROP TABLE SYS.LOGMNRT_TABPART$ ;
DROP TABLE SYS.LOGMNRT_TABSUBPART$ ;
DROP TABLE SYS.LOGMNRT_TABCOMPART$ ;
DROP TABLE SYS.LOGMNRT_TYPE$ ;
DROP TABLE SYS.LOGMNRT_COLTYPE$ ;
DROP TABLE SYS.LOGMNRT_ATTRIBUTE$ ;
DROP TABLE SYS.LOGMNRT_LOB$ ;
DROP TABLE SYS.LOGMNRT_CDEF$ ;
DROP TABLE SYS.LOGMNRT_CCOL$ ;
DROP TABLE SYS.LOGMNRT_ICOL$ ;
DROP TABLE SYS.LOGMNRT_LOBFRAG$ ;
DROP TABLE SYS.LOGMNRT_INDPART$ ;
DROP TABLE SYS.LOGMNRT_INDSUBPART$ ;
DROP TABLE SYS.LOGMNRT_INDCOMPART$ ;
DROP TABLE SYS.LOGMNRT_LOGMNR_BUILDLOG ;
DROP TABLE SYS.LOGMNRT_NTAB$ ;
DROP TABLE SYS.LOGMNRT_OPQTYPE$ ;
DROP TABLE SYS.LOGMNRT_SUBCOLTYPE$ ;
DROP TABLE SYS.LOGMNRT_KOPM$ ;
DROP TABLE SYS.LOGMNRT_PROPS$ ;
DROP TABLE SYS.LOGMNRT_ENC$ ;
DROP TABLE SYS.LOGMNRT_REFCON$ ;
DROP TABLE SYS.LOGMNRT_PARTOBJ$ ;

-- logmnr_session$.session_name -  varchar2(32) should be varchar2(128)
alter table system.logmnr_session$ modify (session_name varchar2(128));

-- various missing not null constraints
alter table system.logmnr_attrcol$ modify (obj# not null);
alter table system.logmnr_attribute$ modify (toid not null);
alter table system.logmnr_ccol$ modify (intcol# not null);
alter table system.logmnr_cdef$ modify (obj# not null);
alter table system.logmnr_col$ modify (obj# not null);
alter table system.logmnr_coltype$ modify (obj# not null);
alter table system.logmnr_dictionary$ modify (db_dict_objectcount not null);
alter table system.logmnr_icol$ modify (intcol# not null);
alter table system.logmnr_ind$ modify (obj# not null);
alter table system.logmnr_indcompart$ modify (part# not null);
alter table system.logmnr_indpart$ modify (ts# not null);
alter table system.logmnr_indsubpart$ modify (ts# not null);
alter table system.logmnr_lob$ modify (chunk not null);
alter table system.logmnr_lobfrag$ modify (frag# not null);
alter table system.logmnr_obj$ modify (obj# not null);
alter table system.logmnr_tab$ modify (obj# not null);
alter table system.logmnr_tabcompart$ modify (part# not null);
alter table system.logmnr_tabpart$ modify (bo# not null);
alter table system.logmnr_tabsubpart$ modify (ts# not null);
alter table system.logmnr_ts$ modify (blocksize not null);
alter table system.logmnr_type$ modify (toid not null);
alter table system.logmnr_user$ modify (name not null);

CREATE TABLE system.logmnr_global$ (
      high_recid_foreign      number, 
      high_recid_deleted      number, 
      local_reset_scn         number,
      local_reset_timestamp   number,
      version_timestamp       number,
      spare1                  number,
      spare2                  number,
      spare3                  number,
      spare4                  varchar2(2000),
      spare5                  date)
   tablespace SYSAUX LOGGING;

CREATE TABLE SYSTEM.LOGMNR_FILTER$ (
                session#                number,
                filter_type             varchar2(30),
                attr1                   number,
                attr2                   number,
                attr3                   number,
                attr4                   number,
                attr5                   number,
                attr6                   number,
                filter_scn              number,
                spare1                  number,
                spare2                  number,
                spare3                  date)
            TABLESPACE SYSAUX LOGGING;

CREATE GLOBAL TEMPORARY TABLE system.logmnr_gt_tab_include$ (
	schema_name            varchar2(32),
        table_name             varchar2(32)
        ) on commit preserve rows;

CREATE GLOBAL TEMPORARY TABLE system.logmnr_gt_user_include$ (
                user_name            varchar2(32),
                user_type            number  /* 0 DB_USER, 1 OS_USER */
                ) on commit preserve rows;

declare
    type stmt_typ is record (stmt varchar2(4000));
    type stmt_cur_typ is ref cursor;
    stmt_cur       stmt_cur_typ;
    stmt_rec       stmt_typ;
    stmt_query     varchar2(4000);
BEGIN 

-- 0.
-- Remove any transient sessions.  No sessions may be active at this time.  The
-- The only session data present now is due to improperly terminated adhoc.
--

-- This query returns commands to be executed to clean out all logminer
-- dictionary tables, except for logmnr_uid$, for all transient session.

  stmt_query :=
 'select ''delete from system.'' || o.name ||
         '' x where x.logmnr_uid IN (select lu.logmnr_uid
                                     from system.logmnr_uid$ lu
                                     where lu.session# > 2147483647)'' cmd
  from sys.obj$ o, sys.tab$ t, sys.user$ u, x$krvxdta x
  where o.name = case when bitand(x.flags, 2) = 2
                      then ''LOGMNR_'' || x.name
                      else x.name end and
        bitand(x.flags, 1) = 1 and
        bitand(t.property,32) = 0 and
        o.obj# = t.obj# and
        o.owner# = u.user# and
        u.name = ''SYSTEM''
  UNION
  select ''alter table system.'' || o.name || '' drop partition P'' ||
         lu.logmnr_uid cmd
  from x$krvxdta x, sys.obj$ o, sys.tab$ t, sys.user$ u, system.logmnr_uid$ lu
  where o.name = case when bitand(x.flags, 2) = 2 
                 then ''LOGMNR_''|| x.name
                 else x.name end  and
        bitand(x.flags, 1) = 1 and
        o.obj# = t.obj# and
        bitand(t.property, 32) = 32 and
        o.owner# = u.user# and
        u.name = ''SYSTEM'' and
        lu.session# > 2147483647';

  open stmt_cur for stmt_query;
  loop
    fetch stmt_cur into stmt_rec;
    exit when stmt_cur%NOTFOUND;
    execute immediate stmt_rec.stmt;
    commit;
  end loop;
  close stmt_cur;
  delete from system.logmnr_uid$ where session# > 2147483647;
  COMMIT;

end;
/


alter table SYSTEM.LOGMNRC_GTLO add
  (PARTTYPE NUMBER,
   SUBPARTTYPE NUMBER,
   UNSUPPORTEDCOLS NUMBER,
   COMPLEXTYPECOLS NUMBER,
   NTPARENTOBJNUM NUMBER,
   NTPARENTOBJVERSION NUMBER,
   NTPARENTINTCOLNUM NUMBER,
   LOGMNRTLOFLAGS NUMBER,
   LOGMNRMCV VARCHAR2(30));

alter table SYSTEM.LOGMNRC_GTCS add
  (COL# NUMBER,
   XTYPESCHEMANAME VARCHAR2(30),
   XTYPENAME VARCHAR2(4000),
   XFQCOLNAME VARCHAR2(4000),
   XTOPINTCOL NUMBER,
   XREFFEDTABLEOBJN NUMBER,
   XREFFEDTABLEOBJV NUMBER,
   XCOLTYPEFLAGS NUMBER,
   XOPQTYPETYPE NUMBER,
   XOPQTYPEFLAGS NUMBER,
   XOPQLOBINTCOL NUMBER,
   XOPQOBJINTCOL NUMBER,
   XXMLINTCOL NUMBER,
   EAOWNER# NUMBER,
   EAMKEYID VARCHAR2(64),
   EAENCALG NUMBER,
   EAINTALG NUMBER,
   EACOLKLC RAW(2000),
   EAKLCLEN NUMBER,
   EAFLAGS  NUMBER);

alter table SYSTEM.LOGMNR_LOG$ add
  (recid number,
   recstamp number,
   mark_delete_timestamp number);

alter table SYSTEM.LOGMNR_SESSION$ add (redo_compat varchar2(20));

alter table SYS.LOGMNRT_SEED$ add (logmnr_uid number);

alter table SYSTEM.LOGMNR_TYPE$ add
  (version varchar2(30),
   typecode number,
   methods number,
   hiddenMethods number,
   supertypes number,
   subtypes number,
   externtype number,
   externname varchar2(4000),
   helperclassname varchar2(4000),
   local_attrs number,
   local_methods number,
   typeid raw(16),
   roottoid raw(16),
   spare1 number,
   spare2 number,
   spare3 number,
   supertoid raw(16),
   hashcode raw(17));

alter table SYSTEM.LOGMNR_COLTYPE$ add
  (packed number,
   intcol#s raw(2000),
   flags number,
   synobj# number);

alter table SYSTEM.LOGMNR_ATTRIBUTE$ add
  (synobj# number,
   charsetid number,
   charsetform number,
   length number,
   precision# number,
   scale number,
   externname varchar2(4000),
   xflags number,
   spare1 number,
   spare2 number,
   spare3 number,
   spare4 number,
   spare5 number,
   setter number,
   getter number);

alter table SYSTEM.LOGMNR_TAB$ rename column objv# to logmnr_flags; 
alter table SYSTEM.LOGMNR_COL$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_ATTRCOL$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_TS$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_IND$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_TABPART$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_TABSUBPART$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_TABCOMPART$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_TYPE$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_COLTYPE$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_ATTRIBUTE$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_LOB$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_CDEF$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_CCOL$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_ICOL$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_LOBFRAG$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_INDPART$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_INDSUBPART$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_INDCOMPART$ rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_LOGMNR_BUILDLOG rename column objv# to logmnr_flags;
alter table SYSTEM.LOGMNR_DICTIONARY$ add (LOGMNR_FLAGS NUMBER(22));
alter table SYSTEM.LOGMNR_OBJ$ add (LOGMNR_FLAGS NUMBER(22));
alter table SYSTEM.LOGMNR_USER$ add (LOGMNR_FLAGS NUMBER(22));
alter table SYSTEM.LOGMNR_DICTSTATE$ add(LOGMNR_FLAGS NUMBER(22));

-- system.logmnr_session$.start_scn must have the start_scn of the session.  
-- start_scn is often 0.  We assume that for existing sessions the
-- dictionary must be of the correct SCN, so we set the session start_scn
-- to be the dictionary start_scn.
update system.logmnr_session$ s
    set s.start_scn =
          (select max(d.start_scnwrp * 4294967296 + d.start_scnbas)
             from system.logmnr_dictstate$ d, system.logmnr_uid$ u
            where d.logmnr_uid = u.logmnr_uid and
                  u.session# = s.session#)
  where s.start_scn = 0 or s.start_scn is null;
commit;

Rem Clear invalid drop_scn values from Streams MVDD entries
update system.logmnrc_gtlo
   set drop_scn = NULL
 where logmnr_uid in (select logmnr_uid from system.logmnrc_dbname_uid_map);
commit;

CREATE INDEX system.logmnr_log$_recid ON 
        system.logmnr_log$(recid) 
        TABLESPACE SYSAUX LOGGING;
Rem ===========================
Rem Begin changes for bug 3776830
Rem ===========================

Rem Semantics of logmnr_dictstate$.start_scn* changed from version 9 to
Rem version 10.  When build locked the system catalog for the duration of
Rem the build the commit scn of the build was recorded as the dictionary
Rem start_scn, though any scn during the build would have been acceptable.
Rem In v 10, with the introduction of flash back query in the build, the
Rem dictionary start_scn became the lockdownSCN, aka, the flashback SCN used,
Rem which also happend to be the first_change# of the logfile with the
Rem dictionary_begin bit set.
Rem With the advent of unwind dictionary, a session verification is done
Rem to check that the session's start SCN is at least as great as the
Rem the logmnr dictionary start SCN.  If it is not, the logmnr dictionary
Rem is unwound so that it will be.  Since the session's start SCN is typically
Rem the first change# of the file with the dictionary begin bit set, and
Rem since a 9.2 session will typically have a dictionary start scn that is
Rem larger than this, an adjustment is required.

declare
begin
  update system.logmnr_dictstate$ ds
  set (ds.start_scnwrp, ds.start_scnbas) =
      (select FLOOR(x.min_start_scn / 4294967296) as scnwrp,
              MOD(x.min_start_scn, 4294967296) as scnbas
       from (select logmnr_uid as logmnr_uid,
                    min(startscn) as min_start_scn
             from (select (ds1.start_scnwrp * 4294967296 +
                             ds1. start_scnbas) as startscn,
                           ds1.logmnr_uid as logmnr_uid
                   from system.logmnr_dictstate$ ds1
                   union
                   select s.start_scn as startscn,
                          u.logmnr_uid as logmnr_uid
                   from system.logmnr_session$ s, system.logmnr_uid$ u
                   where u.session# = s.session#)
             group by logmnr_uid) x
       where ds.logmnr_uid = x.logmnr_uid
       );
  commit;
end;
/

Rem ===========================
Rem End changes for bug 3776830
Rem ===========================

-- logmnr_attribute$ -- number(22) => number
alter table system.logmnr_attribute$ modify (attribute# number);
alter table system.logmnr_attribute$ modify (attr_version# number);
alter table system.logmnr_attribute$ modify (properties number);
alter table system.logmnr_attribute$ modify (version# number);
  
-- logmnr_coltype$ -- number(22) => number
alter table system.logmnr_coltype$ modify (col# number);
alter table system.logmnr_coltype$ modify (intcol# number);
alter table system.logmnr_coltype$ modify (intcols number);
alter table system.logmnr_coltype$ modify (typidcol# number);
alter table system.logmnr_coltype$ modify (version# number);
alter table system.logmnr_coltype$ modify (obj# number);

-- logmnr_type$ -- number(22) => number
alter table system.logmnr_type$ modify (version# number);
alter table system.logmnr_type$ modify (properties number);
alter table system.logmnr_type$ modify (attributes number);

-- Make sure we use named constraints
declare
  buf varchar2(4000);
  cursor constraint_names_cursor is
       SELECT c.name                   CONSTRAINT_NAME,
              substr(c.name, 1, 6)     CONSTRAINT_PREFIX,
              u.name || '.' || io.name INDEX_FULL_NAME,
              substr(io.name, 1, 6)    INDEX_PREFIX,
              u.name || '.' || o.name  TABLE_FULL_NAME,
              o.name                   TABLE_NAME,
              u.name                   SCHEMA_NAME,
              io.name                  INDEX_NAME
       FROM sys.con$ c, sys.obj$ o, sys.user$ u, sys.cdef$ cd
       LEFT OUTER JOIN sys.obj$ io
       ON cd.enabled = io.obj#
       WHERE cd.con# = c.con# and cd.obj# = o.obj# and cd.type# = 2 and
             o.owner# = u.user# and u.name = 'SYSTEM' and
             o.name in ('LOGMNR_UID$', 'LOGMNR_ATTRIBUTE$',
                        'LOGMNR_DICTIONARY$', 'LOGMNR_DICTSTATE$');
begin
    FOR name_rec IN constraint_names_cursor LOOP
      IF NOT 'LOGMNR' = name_rec.CONSTRAINT_PREFIX THEN
        buf := 'ALTER TABLE ' ||  
               dbms_assert.enquote_name(name_rec.SCHEMA_NAME, FALSE) || '.' ||
               dbms_assert.enquote_name(name_rec.TABLE_NAME, FALSE) ||
              ' RENAME CONSTRAINT ' ||  
              dbms_assert.enquote_name(name_rec.CONSTRAINT_NAME, FALSE) ||
              ' TO ' || 
               dbms_assert.enquote_name(name_rec.TABLE_NAME || '_PK', FALSE);
        EXECUTE IMMEDIATE buf;
      END IF;
      IF NOT (name_rec.INDEX_PREFIX IS NULL OR
             'LOGMNR' = name_rec.INDEX_PREFIX) THEN
        buf := 'ALTER INDEX ' ||  
                dbms_assert.enquote_name(name_rec.SCHEMA_NAME, FALSE) || '.' ||
	        dbms_assert.enquote_name(name_rec.INDEX_NAME, FALSE) ||
               ' RENAME TO ' ||
               dbms_assert.enquote_name(name_rec.TABLE_NAME || '_PK', FALSE);
        EXECUTE IMMEDIATE buf;
      END IF;
    END LOOP;
    COMMIT;
end;
/

Rem Recreate all LOGMNRG tables.
DROP TABLE SYS.LOGMNRG_SEED$ PURGE;
DROP TABLE SYS.LOGMNRG_DICTIONARY$ PURGE;
DROP TABLE SYS.LOGMNRG_OBJ$ PURGE;
DROP TABLE SYS.LOGMNRG_TAB$ PURGE;
DROP TABLE SYS.LOGMNRG_COL$ PURGE;
DROP TABLE SYS.LOGMNRG_ATTRCOL$ PURGE;
DROP TABLE SYS.LOGMNRG_TS$ PURGE;
DROP TABLE SYS.LOGMNRG_IND$ PURGE;
DROP TABLE SYS.LOGMNRG_USER$ PURGE;
DROP TABLE SYS.LOGMNRG_TABPART$ PURGE;
DROP TABLE SYS.LOGMNRG_TABSUBPART$ PURGE;
DROP TABLE SYS.LOGMNRG_TABCOMPART$ PURGE;
DROP TABLE SYS.LOGMNRG_TYPE$ PURGE;
DROP TABLE SYS.LOGMNRG_COLTYPE$ PURGE;
DROP TABLE SYS.LOGMNRG_ATTRIBUTE$ PURGE;
DROP TABLE SYS.LOGMNRG_LOB$ PURGE;
DROP TABLE SYS.LOGMNRG_CDEF$ PURGE;
DROP TABLE SYS.LOGMNRG_CCOL$ PURGE;
DROP TABLE SYS.LOGMNRG_ICOL$ PURGE;
DROP TABLE SYS.LOGMNRG_LOBFRAG$ PURGE;
DROP TABLE SYS.LOGMNRG_INDPART$ PURGE;
DROP TABLE SYS.LOGMNRG_INDSUBPART$ PURGE;
DROP TABLE SYS.LOGMNRG_INDCOMPART$ PURGE;
DROP TABLE SYS.LOGMNRG_LOGMNR_BUILDLOG;
DROP TABLE SYS.LOGMNRG_NTAB$ PURGE;
DROP TABLE SYS.LOGMNRG_OPQTYPE$ PURGE;
DROP TABLE SYS.LOGMNRG_SUBCOLTYPE$ PURGE;
DROP TABLE SYS.LOGMNRG_KOPM$ PURGE;
DROP TABLE SYS.LOGMNRG_PROPS$ PURGE;
DROP TABLE SYS.LOGMNRG_ENC$ PURGE;
DROP TABLE SYS.LOGMNRG_REFCON$ PURGE;
DROP TABLE SYS.LOGMNRG_PARTOBJ$ PURGE;

CREATE TABLE SYS.LOGMNRG_SEED$ (
      SEED_VERSION NUMBER(22),
      GATHER_VERSION NUMBER(22),
      SCHEMANAME VARCHAR2(30),
      OBJ# NUMBER,
      OBJV# NUMBER(22),
      TABLE_NAME VARCHAR2(30),
      COL_NAME VARCHAR2(30),
      COL# NUMBER,
      INTCOL# NUMBER,
      SEGCOL# NUMBER,
      TYPE# NUMBER,
      LENGTH NUMBER,
      PRECISION# NUMBER,
      SCALE NUMBER,
      NULL$ NUMBER NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_DICTIONARY$ (
      DB_NAME VARCHAR2(9),
      DB_ID NUMBER(20),
      DB_CREATED VARCHAR2(20),
      DB_DICT_CREATED VARCHAR2(20),
      DB_DICT_SCN NUMBER(22),
      DB_THREAD_MAP RAW(8),
      DB_TXN_SCNBAS NUMBER(22),
      DB_TXN_SCNWRP NUMBER(22),
      DB_RESETLOGS_CHANGE# NUMBER(22),
      DB_RESETLOGS_TIME VARCHAR2(20),
      DB_VERSION_TIME VARCHAR2(20),
      DB_REDO_TYPE_ID VARCHAR2(8),
      DB_REDO_RELEASE VARCHAR2(60),
      DB_CHARACTER_SET VARCHAR2(30),
      DB_VERSION VARCHAR2(64),
      DB_STATUS VARCHAR2(64),
      DB_GLOBAL_NAME VARCHAR(128),
      DB_DICT_MAXOBJECTS NUMBER(22),
      DB_DICT_OBJECTCOUNT NUMBER(22) NOT NULL  ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_OBJ$ (
      OBJV# NUMBER(22),
      OWNER# NUMBER(22),
      NAME VARCHAR2(30),
      NAMESPACE NUMBER(22),
      SUBNAME VARCHAR2(30),
      TYPE# NUMBER(22),
      OID$  RAW(16),
      REMOTEOWNER VARCHAR2(30),
      LINKNAME VARCHAR(128),
      FLAGS NUMBER(22),
      SPARE3 NUMBER(22),
      STIME DATE,
      OBJ# NUMBER(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_TAB$ (
      TS# NUMBER(22),
      COLS NUMBER(22),
      PROPERTY NUMBER(22),
      INTCOLS NUMBER(22),
      KERNELCOLS NUMBER(22),
      BOBJ# NUMBER(22),
      TRIGFLAG NUMBER(22),
      FLAGS NUMBER(22),
      OBJ# NUMBER(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_COL$ (
      COL# NUMBER(22),
      SEGCOL# NUMBER(22),
      NAME VARCHAR2(30),
      TYPE# NUMBER(22),
      LENGTH NUMBER(22),
      PRECISION# NUMBER(22),
      SCALE NUMBER(22),
      NULL$ NUMBER(22),
      INTCOL# NUMBER(22),
      PROPERTY NUMBER(22),
      CHARSETID NUMBER(22),
      CHARSETFORM NUMBER(22),
      SPARE1 NUMBER(22),
      SPARE2 NUMBER(22),
      OBJ# NUMBER(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_ATTRCOL$ (
      INTCOL#   number,
      NAME      varchar2(4000),
      OBJ#      number NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_TS$ (
      TS# NUMBER(22),
      NAME VARCHAR2(30),
      OWNER# NUMBER(22),
      BLOCKSIZE NUMBER(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_IND$ (
     BO#     NUMBER(22),
     COLS     NUMBER(22),
     TYPE#    NUMBER(22),
     FLAGS    NUMBER,
     PROPERTY NUMBER,
     OBJ#     NUMBER(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_USER$ (
      USER# NUMBER(22),
      NAME VARCHAR2(30) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_TABPART$ (
      OBJ# NUMBER(22),
      TS# NUMBER(22),
      PART# NUMBER,
      BO# NUMBER(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_TABSUBPART$ (
      OBJ# NUMBER(22),
      DATAOBJ# NUMBER(22),
      POBJ# NUMBER(22),
      SUBPART# NUMBER(22),
      TS# NUMBER(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_TABCOMPART$ (
      OBJ# NUMBER(22),
      BO# NUMBER(22),
      PART# NUMBER(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_TYPE$ (
      version# number,
      version varchar2(30),
      tvoid raw(16),
      typecode number,
      properties number,
      attributes number,
      methods number,
      hiddenMethods number,
      supertypes number,
      subtypes number,
      externtype number,
      externname varchar2(4000),
      helperclassname varchar2(4000),
      local_attrs number,
      local_methods number,
      typeid raw(16),
      roottoid raw(16),
      spare1 number,
      spare2 number,
      spare3 number,
      supertoid raw(16),
      hashcode raw(17),
      toid raw(16) not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_COLTYPE$ (
      col# number,
      intcol# number,
      toid raw(16),
      version# number,
      packed number,
      intcols number,
      intcol#s raw(2000),
      flags number,
      typidcol# number,
      synobj# number,
      obj# number not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_ATTRIBUTE$ (
      version#      number,
      name          varchar2(30),
      attribute#    number,
      attr_toid     raw(16),
      attr_version# number,
      synobj#       number,
      properties    number,
      charsetid     number,
      charsetform   number,
      length        number,
      precision#    number,
      scale         number,
      externname    varchar2(4000),
      xflags        number,
      spare1        number,
      spare2        number,
      spare3        number,
      spare4        number,
      spare5        number,
      setter        number,
      getter        number,
      toid          raw(16) not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_LOB$ (
      OBJ#          NUMBER,
      INTCOL#       NUMBER,
      COL#          NUMBER,
      LOBJ#         NUMBER,
      CHUNK         NUMBER NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_CDEF$ (
      CON#          NUMBER,
      COLS          NUMBER,
      TYPE#         NUMBER,
      ROBJ#         NUMBER, 
      RCON#         NUMBER, 
      ENABLED       NUMBER,
      DEFER         NUMBER,
      OBJ#          NUMBER NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_CCOL$ (
      CON#          NUMBER,
      OBJ#          NUMBER,
      COL#          NUMBER,
      POS#          NUMBER,
      INTCOL#       NUMBER NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_ICOL$ (
      OBJ#          NUMBER,
      BO#           NUMBER,
      COL#          NUMBER,
      POS#          NUMBER,
      SEGCOL#       NUMBER,
      INTCOL#       NUMBER NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_LOBFRAG$ (
      FRAGOBJ#      NUMBER,
      PARENTOBJ#    NUMBER,
      TABFRAGOBJ#   NUMBER,
      INDFRAGOBJ#   NUMBER,
      FRAG#         NUMBER NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_INDPART$ (
      OBJ# NUMBER,
      BO#  NUMBER,
      PART# NUMBER,
      TS#  NUMBER NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_INDSUBPART$ (
      OBJ# NUMBER(22),
      DATAOBJ# NUMBER(22),
      POBJ# NUMBER(22),
      SUBPART# NUMBER(22),
      TS# NUMBER(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_INDCOMPART$ (
      OBJ#     NUMBER,
      DATAOBJ# NUMBER,
      BO#      NUMBER,
      PART#    NUMBER NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_LOGMNR_BUILDLOG (
       BUILD_DATE VARCHAR2(20),
       DB_TXN_SCNBAS NUMBER,
       DB_TXN_SCNWRP NUMBER,
       CURRENT_BUILD_STATE NUMBER,
       COMPLETION_STATUS NUMBER,
       MARKED_LOG_FILE_LOW_SCN NUMBER,
       INITIAL_XID VARCHAR2(22) NOT NULL ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_NTAB$ (
       col# number,
       intcol# number,
       ntab# number,
       name varchar2(4000),
       obj# number not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_OPQTYPE$ (
       intcol# number not null,
       type number,
       flags number,
       lobcol number,
       objcol number,
       extracol number,
       schemaoid raw(16),
       elemnum number,
       schemaurl varchar2(4000),
       obj# number not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_SUBCOLTYPE$ (
       intcol# number not null,
       toid raw(16) not null,
       version# number not null,
       intcols number,
       intcol#s raw(2000),
       flags number,
       synobj# number,
       obj# number not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_KOPM$ (
       length number,
       metadata raw(255),
       name varchar2(30) not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_PROPS$ (
       value$ varchar2(4000),
       comment$ varchar2(4000),
       name varchar2(30) not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_ENC$ (
       obj# number,
       owner# number,
       encalg number,
       intalg number,
       colklc raw(2000),
       klclen number,
       flag number,
       mkeyid varchar2(64) not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_REFCON$ (
       col#     number,
       intcol#  number,
       reftyp   number,
       stabid   raw(16),
       expctoid raw(16),
       obj#     number not null ) 
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYS.LOGMNRG_PARTOBJ$ (
      parttype    number,
       partcnt     number,
       partkeycols number,
       flags       number,
       defts#      number,
       defpctfree  number,
       defpctused  number,
       defpctthres number,
       definitrans number,
       defmaxtrans number,
       deftiniexts number,
       defextsize  number,
       defminexts  number,
       defmaxexts  number,
       defextpct   number,
       deflists    number,
       defgroups   number,
       deflogging  number,
       spare1      number,
       spare2      number,
       spare3      number,
       definclcol  number,
       parameters  varchar2(1000),
       obj#        number not null ) 
   TABLESPACE SYSTEM LOGGING
/


-- Earlier releases may not have used partitioning for logminer metadata.
declare
  cursor c1 is 
   select x.name
     from obj$ o, tab$ t, user$ u,
     (select case when bitand(x.flags, 2) = 2
                 then 'LOGMNR_' || x.name 
                 else x.name  end name
      from x$krvxdta x
      where bitand(x.flags,1) = 1) x
    where u.name = 'SYSTEM'
      and u.user# = o.owner#
      and x.name = o.name
      and o.remoteowner is null
      and o.linkname is null
      and o.type# = 2
      and o.obj# = t.obj#
      and bitand(t.property,32) = 0;
  cursor c2 (table_name varchar2) is
    select c.name 
      from obj$ o, col$ c, user$ u
      where o.name = table_name
        and o.obj# = c.obj#
        and o.type# = 2
        and o.remoteowner is null
        and o.linkname is null
        and u.name = 'SYSTEM'
        and o.owner# = u.user#;
  table_empty boolean;
  dummy number;
  newtable varchar2(30);
  col_list varchar2(30000);
  first_col boolean;
begin
  for crec in c1 loop
    table_empty := false;
    begin
      execute immediate 'select 1 from SYSTEM.' || 
              dbms_assert.enquote_name(crec.name, FALSE) || ' where rownum <2'
        into dummy;
    exception when no_data_found then
      table_empty := true;
    end;
    if table_empty then 
      execute immediate 'drop table SYSTEM.' || 
                        dbms_assert.enquote_name(crec.name, FALSE);
    else
      newtable := crec.name || '_MIG';
      first_col := true;
      for c2rec in c2 (crec.name) loop
        if first_col then
          first_col := false;  
          col_list := dbms_assert.enquote_name(c2rec.name, FALSE);
        else
          col_list := col_list || ', ' || 
                      dbms_assert.enquote_name(c2rec.name, FALSE);
        end if;
      end loop;
      execute immediate 'create table SYSTEM.' ||
                         dbms_assert.enquote_name(newtable, FALSE) ||
                        ' as select * from SYSTEM.' ||
                         dbms_assert.enquote_name(crec.name, FALSE) ||
                        ' where 1=2';

      execute immediate 'insert into SYSTEM.'||
                         dbms_assert.enquote_name(newtable, FALSE) || 
                        ' ( ' ||col_list|| ') select ' ||
                        col_list || ' from SYSTEM.' || 
                        dbms_assert.enquote_name(crec.name, FALSE);
      execute immediate 'delete from SYSTEM.' || 
                        dbms_assert.enquote_name(crec.name, FALSE);
      commit;
      execute immediate 'drop table SYSTEM.' || 
                         dbms_assert.enquote_name(crec.name, FALSE);
    end if;
  end loop;
end;
/
alter session set events '14524 trace name context forever, level 1';
-- The following create tables are redundant in most cases, but are
-- required here in the event we are upgrading from a nonpartitioned
-- logminer configuration.  In that case the above PL/SQL will have
-- dropped these tables.
CREATE TABLE SYSTEM.LOGMNR_DICTSTATE$ (
                    LOGMNR_UID NUMBER(22),
                    START_SCNBAS NUMBER,
                    START_SCNWRP NUMBER,
                    END_SCNBAS NUMBER,
                    END_SCNWRP NUMBER,
                    REDO_THREAD NUMBER,
                    RBASQN NUMBER,
                    RBABLK NUMBER,
                    RBABYTE NUMBER,
                    LOGMNR_FLAGS NUMBER(22),
                    constraint LOGMNR_DICTSTATE$_PK
                       primary key (LOGMNR_UID) disable)
                 PARTITION BY RANGE(logmnr_uid)
                    ( PARTITION p_lessthan100 VALUES LESS THAN (100))
                 TABLESPACE SYSAUX LOGGING
/
CREATE TABLE SYSTEM.LOGMNRC_GTLO( 
                  LOGMNR_UID         NUMBER NOT NULL, 
                  KEYOBJ#            NUMBER NOT NULL,
                  LVLCNT             NUMBER NOT NULL,  /* level count */
                  BASEOBJ#           NUMBER NOT NULL,  /* base object number */
                  BASEOBJV#          NUMBER NOT NULL,  
                                                      /* base object version */
                  LVL1OBJ#           NUMBER,  /* level 1 object number */
                  LVL2OBJ#           NUMBER,  /* level 2 object number */
                  LVL0TYPE#          NUMBER NOT NULL,
                                              /* level 0 (base obj) type # */
                  LVL1TYPE#          NUMBER,  /* level 1 type # */
                  LVL2TYPE#          NUMBER,  /* level 2 type # */
                  OWNER#             NUMBER,  /* owner number */
                  OWNERNAME          VARCHAR2(30) NOT NULL,
                  LVL0NAME           VARCHAR2(30) NOT NULL,
                                              /* name of level 0 (base obj)  */
                  LVL1NAME           VARCHAR2(30), /* name of level 1 object */
                  LVL2NAME           VARCHAR2(30), /* name of level 2 object */
                  INTCOLS            NUMBER NOT NULL,
                              /* for table object, number of all types cols  */
                  COLS               NUMBER,
                           /* for table object, number of user visable cols  */
                  KERNELCOLS         NUMBER,
                        /* for table object, number of non zero secol# cols  */
                  TAB_FLAGS          NUMBER,   /* TAB$.FLAGS        */
                  TRIGFLAG           NUMBER,   /* TAB$.TRIGFLAG     */
                  ASSOC#             NUMBER,   /* IOT/OF Associated object */
                  OBJ_FLAGS          NUMBER,   /* OBJ$.FLAGS        */
                  TS#                NUMBER, /* table space number */
                  TSNAME             VARCHAR2(30), /* table space name   */
                  PROPERTY           NUMBER,
                  /* Replication Dictionary Specific Columns  */
                  START_SCN          NUMBER NOT NULL,
                                            /* SCN at which existance begins */
                  DROP_SCN         NUMBER,  /* SCN at which existance end    */
                  XIDUSN             NUMBER,
                                        /* src txn which created this object */
                  XIDSLT             NUMBER,
                  XIDSQN             NUMBER,
                  FLAGS              NUMBER,
                  LOGMNR_SPARE1             NUMBER,
                  LOGMNR_SPARE2             NUMBER,
                  LOGMNR_SPARE3             VARCHAR2(1000),
                  LOGMNR_SPARE4             DATE,
                  LOGMNR_SPARE5             NUMBER,
                  LOGMNR_SPARE6             NUMBER,
                  LOGMNR_SPARE7             NUMBER,
                  LOGMNR_SPARE8             NUMBER,
                  LOGMNR_SPARE9             NUMBER,
                /* New in V11  */
                  PARTTYPE                  NUMBER,
                  SUBPARTTYPE               NUMBER,
                  UNSUPPORTEDCOLS           NUMBER,
                  COMPLEXTYPECOLS           NUMBER,
                  NTPARENTOBJNUM            NUMBER,
                  NTPARENTOBJVERSION        NUMBER,
                  NTPARENTINTCOLNUM         NUMBER,
                  LOGMNRTLOFLAGS            NUMBER,
                  LOGMNRMCV                 VARCHAR2(30),
                    CONSTRAINT LOGMNRC_GTLO_PK
                    PRIMARY KEY(LOGMNR_UID, KEYOBJ#, BASEOBJV#)
                    USING INDEX LOCAL
                  ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
                  TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNRC_I2GTLO 
    ON SYSTEM.LOGMNRC_GTLO (logmnr_uid, baseobj#, baseobjv#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNRC_I3GTLO 
    ON SYSTEM.LOGMNRC_GTLO (logmnr_uid, drop_scn) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNRC_GTCS(
                   LOGMNR_UID                NUMBER NOT NULL,
                   OBJ#                      NUMBER NOT NULL,
                                              /* table (base) object number  */
                   OBJV#                     NUMBER NOT NULL,
                                              /* table object version        */
                   SEGCOL#                   NUMBER NOT NULL,
                                              /* segcol# of column           */
                   INTCOL#                   NUMBER NOT NULL,
                                              /* intcol# of column           */
                   COLNAME                   VARCHAR2(30) NOT NULL, 
                                              /* name of column              */
                   TYPE#                     NUMBER NOT NULL, /* column type */
                   LENGTH                    NUMBER, /* data length */
                   PRECISION                 NUMBER, /* data precision */
                   SCALE                     NUMBER, /* data scale */
                   INTERVAL_LEADING_PRECISION  NUMBER,
                                       /* Interval Leading Precision, if any */
                   INTERVAL_TRAILING_PRECISION NUMBER,
                                      /* Interval trailing precision, if any */
                   PROPERTY                  NUMBER,
                   TOID                      RAW(16),
                   CHARSETID                 NUMBER,
                   CHARSETFORM               NUMBER,
                   TYPENAME                  VARCHAR2(30),
                   FQCOLNAME                 VARCHAR2(4000),
                                              /* fully-qualified column name */
                   NUMINTCOLS                NUMBER, /* Number of Int Cols  */
                   NUMATTRS                  NUMBER,
                   ADTORDER                  NUMBER,
                   LOGMNR_SPARE1                    NUMBER,
                   LOGMNR_SPARE2                    NUMBER,
                   LOGMNR_SPARE3                    VARCHAR2(1000),
                   LOGMNR_SPARE4                    DATE,
                   LOGMNR_SPARE5             NUMBER,
                   LOGMNR_SPARE6             NUMBER,
                   LOGMNR_SPARE7             NUMBER,
                   LOGMNR_SPARE8             NUMBER,
                   LOGMNR_SPARE9             NUMBER,
                /* New for V11.  */
                   COL#                      NUMBER,
                   XTYPESCHEMANAME           VARCHAR2(30),
                   XTYPENAME                 VARCHAR2(4000),
                   XFQCOLNAME                VARCHAR2(4000),
                   XTOPINTCOL                NUMBER,
                   XREFFEDTABLEOBJN          NUMBER,
                   XREFFEDTABLEOBJV          NUMBER,
                   XCOLTYPEFLAGS             NUMBER,
                   XOPQTYPETYPE              NUMBER,
                   XOPQTYPEFLAGS             NUMBER,
                   XOPQLOBINTCOL             NUMBER,
                   XOPQOBJINTCOL             NUMBER,
                   XXMLINTCOL                NUMBER,
                   EAOWNER#                  NUMBER,
                   EAMKEYID                  VARCHAR2(64),
                   EAENCALG                  NUMBER,
                   EAINTALG                  NUMBER,
                   EACOLKLC                  RAW(2000),
                   EAKLCLEN                  NUMBER,
                   EAFLAGS                   NUMBER,
                     constraint logmnrc_gtcs_pk
                     primary key(logmnr_uid, obj#, objv#,intcol#)
                     using index local
                  ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
                    TABLESPACE SYSAUX LOGGING
/
CREATE TABLE SYSTEM.LOGMNRC_GSII(
                   LOGMNR_UID                NUMBER NOT NULL,
                   OBJ#                      NUMBER NOT NULL,
                   BO#                       NUMBER NOT NULL,
                   INDTYPE#                  NUMBER NOT NULL,
                   DROP_SCN                  NUMBER,
                   LOGMNR_SPARE1             NUMBER,
                   LOGMNR_SPARE2             NUMBER,
                   LOGMNR_SPARE3             VARCHAR2(1000),
                   LOGMNR_SPARE4             DATE,
                     constraint logmnrc_gsii_pk primary key(logmnr_uid, obj#)
                                 using index local
                  ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
                    TABLESPACE SYSAUX LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_SEED$ (
      SEED_VERSION NUMBER(22),
      GATHER_VERSION NUMBER(22),
      SCHEMANAME VARCHAR2(30),
      OBJ# NUMBER,
      OBJV# NUMBER(22),
      TABLE_NAME VARCHAR2(30),
      COL_NAME VARCHAR2(30),
      COL# NUMBER,
      INTCOL# NUMBER,
      SEGCOL# NUMBER,
      TYPE# NUMBER,
      LENGTH NUMBER,
      PRECISION# NUMBER,
      SCALE NUMBER,
      NULL$ NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_SEED$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1SEED$ 
    ON SYSTEM.LOGMNR_SEED$ (LOGMNR_UID, OBJ#, INTCOL#)
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2SEED$ 
    ON SYSTEM.LOGMNR_SEED$ (logmnr_uid, schemaname, table_name,
                     col_name, obj#, intcol#)
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_DICTIONARY$ (
      DB_NAME VARCHAR2(9),
      DB_ID NUMBER(20),
      DB_CREATED VARCHAR2(20),
      DB_DICT_CREATED VARCHAR2(20),
      DB_DICT_SCN NUMBER(22),
      DB_THREAD_MAP RAW(8),
      DB_TXN_SCNBAS NUMBER(22),
      DB_TXN_SCNWRP NUMBER(22),
      DB_RESETLOGS_CHANGE# NUMBER(22),
      DB_RESETLOGS_TIME VARCHAR2(20),
      DB_VERSION_TIME VARCHAR2(20),
      DB_REDO_TYPE_ID VARCHAR2(8),
      DB_REDO_RELEASE VARCHAR2(60),
      DB_CHARACTER_SET VARCHAR2(30),
      DB_VERSION VARCHAR2(64),
      DB_STATUS VARCHAR2(64),
      DB_GLOBAL_NAME VARCHAR(128),
      DB_DICT_MAXOBJECTS NUMBER(22),
      DB_DICT_OBJECTCOUNT NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_DICTIONARY$_pk primary key (LOGMNR_UID) disable  ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1DICTIONARY$ 
    ON SYSTEM.LOGMNR_DICTIONARY$ (LOGMNR_UID)
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_OBJ$ (
      OBJV# NUMBER(22),
      OWNER# NUMBER(22),
      NAME VARCHAR2(30),
      NAMESPACE NUMBER(22),
      SUBNAME VARCHAR2(30),
      TYPE# NUMBER(22),
      OID$  RAW(16),
      REMOTEOWNER VARCHAR2(30),
      LINKNAME VARCHAR(128),
      FLAGS NUMBER(22),
      SPARE3 NUMBER(22),
      STIME DATE,
      OBJ# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      START_SCNBAS NUMBER,
      START_SCNWRP NUMBER,
      constraint LOGMNR_OBJ$_pk primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1OBJ$ 
    ON SYSTEM.LOGMNR_OBJ$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2OBJ$ 
    ON SYSTEM.LOGMNR_OBJ$ (logmnr_uid, oid$) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TAB$ (
      TS# NUMBER(22),
      COLS NUMBER(22),
      PROPERTY NUMBER(22),
      INTCOLS NUMBER(22),
      KERNELCOLS NUMBER(22),
      BOBJ# NUMBER(22),
      TRIGFLAG NUMBER(22),
      FLAGS NUMBER(22),
      OBJ# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TAB$_pk primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TAB$ 
    ON SYSTEM.LOGMNR_TAB$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2TAB$ 
    ON SYSTEM.LOGMNR_TAB$ (logmnr_uid, bobj#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_COL$ (
      COL# NUMBER(22),
      SEGCOL# NUMBER(22),
      NAME VARCHAR2(30),
      TYPE# NUMBER(22),
      LENGTH NUMBER(22),
      PRECISION# NUMBER(22),
      SCALE NUMBER(22),
      NULL$ NUMBER(22),
      INTCOL# NUMBER(22),
      PROPERTY NUMBER(22),
      CHARSETID NUMBER(22),
      CHARSETFORM NUMBER(22),
      SPARE1 NUMBER(22),
      SPARE2 NUMBER(22),
      OBJ# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_COL$_pk 
        primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1COL$ 
    ON SYSTEM.LOGMNR_COL$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2COL$ 
    ON SYSTEM.LOGMNR_COL$ (logmnr_uid, obj#, name) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I3COL$ 
    ON SYSTEM.LOGMNR_COL$ (logmnr_uid, obj#, col#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_ATTRCOL$ (
      INTCOL#   number,
      NAME      varchar2(4000),
      OBJ#      number NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_ATTRCOL$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1ATTRCOL$
    ON SYSTEM.LOGMNR_ATTRCOL$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TS$ (
      TS# NUMBER(22),
      NAME VARCHAR2(30),
      OWNER# NUMBER(22),
      BLOCKSIZE NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TS$_pk primary key (LOGMNR_UID, TS#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TS$ 
    ON SYSTEM.LOGMNR_TS$ (LOGMNR_UID, TS#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_IND$ (
     BO#     NUMBER(22),
     COLS     NUMBER(22),
     TYPE#    NUMBER(22),
     FLAGS    NUMBER,
     PROPERTY NUMBER,
     OBJ#     NUMBER(22) NOT NULL,
     logmnr_uid NUMBER(22),
     logmnr_flags NUMBER(22),
     constraint LOGMNR_IND$_pk primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1IND$
    ON SYSTEM.LOGMNR_IND$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2IND$
    ON SYSTEM.LOGMNR_IND$ (LOGMNR_UID, BO#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_USER$ (
      USER# NUMBER(22),
      NAME VARCHAR2(30) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_USER$_pk primary key (LOGMNR_UID, USER#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1USER$ 
    ON SYSTEM.LOGMNR_USER$ (LOGMNR_UID, USER#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TABPART$ (
      OBJ# NUMBER(22),
      TS# NUMBER(22),
      PART# NUMBER,
      BO# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TABPART$_pk 
         primary key (LOGMNR_UID, OBJ#, BO#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TABPART$
    ON SYSTEM.LOGMNR_TABPART$ (LOGMNR_UID, OBJ#, BO#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2TABPART$
    ON SYSTEM.LOGMNR_TABPART$ (logmnr_uid, bo#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TABSUBPART$ (
      OBJ# NUMBER(22),
      DATAOBJ# NUMBER(22),
      POBJ# NUMBER(22),
      SUBPART# NUMBER(22),
      TS# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TABSUBPART$_pk 
         primary key (LOGMNR_UID, OBJ#, POBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TABSUBPART$
    ON SYSTEM.LOGMNR_TABSUBPART$ (LOGMNR_UID, OBJ#, POBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2TABSUBPART$
    ON SYSTEM.LOGMNR_TABSUBPART$ (logmnr_uid, pobj#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TABCOMPART$ (
      OBJ# NUMBER(22),
      BO# NUMBER(22),
      PART# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TABCOMPART$_pk 
         primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TABCOMPART$
    ON SYSTEM.LOGMNR_TABCOMPART$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2TABCOMPART$
    ON SYSTEM.LOGMNR_TABCOMPART$ (logmnr_uid, bo#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TYPE$ (
      version# number,
      version varchar2(30),
      tvoid raw(16),
      typecode number,
      properties number,
      attributes number,
      methods number,
      hiddenMethods number,
      supertypes number,
      subtypes number,
      externtype number,
      externname varchar2(4000),
      helperclassname varchar2(4000),
      local_attrs number,
      local_methods number,
      typeid raw(16),
      roottoid raw(16),
      spare1 number,
      spare2 number,
      spare3 number,
      supertoid raw(16),
      hashcode raw(17),
      toid raw(16) not null,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TYPE$_pk 
         primary key (LOGMNR_UID, TOID, VERSION#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TYPE$
    ON SYSTEM.LOGMNR_TYPE$ (LOGMNR_UID, TOID, VERSION#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_COLTYPE$ (
      col# number,
      intcol# number,
      toid raw(16),
      version# number,
      packed number,
      intcols number,
      intcol#s raw(2000),
      flags number,
      typidcol# number,
      synobj# number,
      obj# number not null,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_COLTYPE$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1COLTYPE$
    ON SYSTEM.LOGMNR_COLTYPE$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_ATTRIBUTE$ (
      version#      number,
      name          varchar2(30),
      attribute#    number,
      attr_toid     raw(16),
      attr_version# number,
      synobj#       number,
      properties    number,
      charsetid     number,
      charsetform   number,
      length        number,
      precision#    number,
      scale         number,
      externname    varchar2(4000),
      xflags        number,
      spare1        number,
      spare2        number,
      spare3        number,
      spare4        number,
      spare5        number,
      setter        number,
      getter        number,
      toid          raw(16) not null,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_ATTRIBUTE$_pk 
         primary key (LOGMNR_UID, TOID, VERSION#, ATTRIBUTE#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1ATTRIBUTE$
    ON SYSTEM.LOGMNR_ATTRIBUTE$ (LOGMNR_UID, TOID, VERSION#, ATTRIBUTE#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_LOB$ (
      OBJ#          NUMBER,
      INTCOL#       NUMBER,
      COL#          NUMBER,
      LOBJ#         NUMBER,
      CHUNK         NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_LOB$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1LOB$
    ON SYSTEM.LOGMNR_LOB$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_CDEF$ (
      CON#          NUMBER,
      COLS          NUMBER,
      TYPE#         NUMBER,
      ROBJ#         NUMBER, 
      RCON#         NUMBER, 
      ENABLED       NUMBER,
      DEFER         NUMBER,
      OBJ#          NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_CDEF$_pk primary key (LOGMNR_UID, CON#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1CDEF$
    ON SYSTEM.LOGMNR_CDEF$ (LOGMNR_UID, CON#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_CCOL$ (
      CON#          NUMBER,
      OBJ#          NUMBER,
      COL#          NUMBER,
      POS#          NUMBER,
      INTCOL#       NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_CCOL$_pk 
         primary key (LOGMNR_UID, CON#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1CCOL$
    ON SYSTEM.LOGMNR_CCOL$ (LOGMNR_UID, CON#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_ICOL$ (
      OBJ#          NUMBER,
      BO#           NUMBER,
      COL#          NUMBER,
      POS#          NUMBER,
      SEGCOL#       NUMBER,
      INTCOL#       NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_ICOL$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1ICOL$
    ON SYSTEM.LOGMNR_ICOL$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_LOBFRAG$ (
      FRAGOBJ#      NUMBER,
      PARENTOBJ#    NUMBER,
      TABFRAGOBJ#   NUMBER,
      INDFRAGOBJ#   NUMBER,
      FRAG#         NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_LOBFRAG$_pk 
         primary key (LOGMNR_UID, FRAGOBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1LOBFRAG$
    ON SYSTEM.LOGMNR_LOBFRAG$ (LOGMNR_UID, FRAGOBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_INDPART$ (
      OBJ# NUMBER,
      BO#  NUMBER,
      PART# NUMBER,
      TS#  NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_INDPART$_pk 
         primary key (LOGMNR_UID, OBJ#, BO#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1INDPART$
    ON SYSTEM.LOGMNR_INDPART$ (LOGMNR_UID, OBJ#, BO#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2INDPART$
    ON SYSTEM.LOGMNR_INDPART$ (logmnr_uid, bo#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_INDSUBPART$ (
      OBJ# NUMBER(22),
      DATAOBJ# NUMBER(22),
      POBJ# NUMBER(22),
      SUBPART# NUMBER(22),
      TS# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_INDSUBPART$_pk 
         primary key (LOGMNR_UID, OBJ#, POBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1INDSUBPART$
    ON SYSTEM.LOGMNR_INDSUBPART$ (LOGMNR_UID, OBJ#, POBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_INDCOMPART$ (
      OBJ#     NUMBER,
      DATAOBJ# NUMBER,
      BO#      NUMBER,
      PART#    NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_INDCOMPART$_pk 
         primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1INDCOMPART$
    ON SYSTEM.LOGMNR_INDCOMPART$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_LOGMNR_BUILDLOG (
       BUILD_DATE VARCHAR2(20),
       DB_TXN_SCNBAS NUMBER,
       DB_TXN_SCNWRP NUMBER,
       CURRENT_BUILD_STATE NUMBER,
       COMPLETION_STATUS NUMBER,
       MARKED_LOG_FILE_LOW_SCN NUMBER,
       INITIAL_XID VARCHAR2(22) NOT NULL,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_LOGMNR_BUILDLOG_pk 
          primary key (LOGMNR_UID, INITIAL_XID) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1LOGMNR_BUILDLOG
    ON SYSTEM.LOGMNR_LOGMNR_BUILDLOG (LOGMNR_UID, INITIAL_XID) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_NTAB$ (
       col# number,
       intcol# number,
       ntab# number,
       name varchar2(4000),
       obj# number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_NTAB$_pk 
          primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1NTAB$
    ON SYSTEM.LOGMNR_NTAB$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2NTAB$
    ON SYSTEM.LOGMNR_NTAB$ (logmnr_uid, ntab#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_OPQTYPE$ (
       intcol# number not null,
       type number,
       flags number,
       lobcol number,
       objcol number,
       extracol number,
       schemaoid raw(16),
       elemnum number,
       schemaurl varchar2(4000),
       obj# number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_OPQTYPE$_pk 
          primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1OPQTYPE$
    ON SYSTEM.LOGMNR_OPQTYPE$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_SUBCOLTYPE$ (
       intcol# number not null,
       toid raw(16) not null,
       version# number not null,
       intcols number,
       intcol#s raw(2000),
       flags number,
       synobj# number,
       obj# number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_SUBCOLTYPE$_pk 
          primary key (LOGMNR_UID, OBJ#, INTCOL#, TOID) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1SUBCOLTYPE$
    ON SYSTEM.LOGMNR_SUBCOLTYPE$ (LOGMNR_UID, OBJ#, INTCOL#, TOID) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_KOPM$ (
       length number,
       metadata raw(255),
       name varchar2(30) not null,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_KOPM$_pk 
         primary key (LOGMNR_UID, NAME) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1KOPM$
    ON SYSTEM.LOGMNR_KOPM$ (LOGMNR_UID, NAME) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_PROPS$ (
       value$ varchar2(4000),
       comment$ varchar2(4000),
       name varchar2(30) not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_PROPS$_pk 
          primary key (LOGMNR_UID, NAME) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1PROPS$
    ON SYSTEM.LOGMNR_PROPS$ (LOGMNR_UID, NAME) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_ENC$ (
       obj# number,
       owner# number,
       encalg number,
       intalg number,
       colklc raw(2000),
       klclen number,
       flag number,
       mkeyid varchar2(64) not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_ENC$_pk 
          primary key (LOGMNR_UID, OBJ#, OWNER#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1ENC$
    ON SYSTEM.LOGMNR_ENC$ (LOGMNR_UID, OBJ#, OWNER#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_REFCON$ (
       col#     number,
       intcol#  number,
       reftyp   number,
       stabid   raw(16),
       expctoid raw(16),
       obj#     number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_REFCON$_pk 
          primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1REFCON$
    ON SYSTEM.LOGMNR_REFCON$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_PARTOBJ$ (
      parttype    number,
       partcnt     number,
       partkeycols number,
       flags       number,
       defts#      number,
       defpctfree  number,
       defpctused  number,
       defpctthres number,
       definitrans number,
       defmaxtrans number,
       deftiniexts number,
       defextsize  number,
       defminexts  number,
       defmaxexts  number,
       defextpct   number,
       deflists    number,
       defgroups   number,
       deflogging  number,
       spare1      number,
       spare2      number,
       spare3      number,
       definclcol  number,
       parameters  varchar2(1000),
       obj#        number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_PARTOBJ$_pk 
          primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1PARTOBJ$
    ON SYSTEM.LOGMNR_PARTOBJ$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNRP_CTAS_PART_MAP (
                    LOGMNR_UID         NUMBER NOT NULL,
                    BASEOBJ#           NUMBER NOT NULL,
                    BASEOBJV#          NUMBER NOT NULL,  
                    KEYOBJ#            NUMBER NOT NULL,
                    PART#              NUMBER NOT NULL,
                    SPARE1             NUMBER,
                    SPARE2             NUMBER,
                    SPARE3             VARCHAR2(1000),
                    CONSTRAINT LOGMNRP_CTAS_PART_MAP_PK 
                       PRIMARY KEY(LOGMNR_UID, BASEOBJV#, KEYOBJ#) 
                       using index local )
              PARTITION BY RANGE(logmnr_uid)
                 ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
              TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNRP_CTAS_PART_MAP_I ON
                    SYSTEM.LOGMNRP_CTAS_PART_MAP (
                      LOGMNR_UID, BASEOBJ#, BASEOBJV#, PART#)
                    TABLESPACE SYSAUX LOCAL LOGGING
/
alter session set events '14524 trace name context off';

-- Create any missing partitions
declare
    type part_typ is record (table_name varchar2(32), 
                             part_name varchar2(32),
                             values_less_than number);
    type part_cur_typ is ref cursor;
    part_cur       part_cur_typ;
    part_rec       part_typ;
    part_query     varchar2(4000);
    alter_stmt     varchar2(4000);
BEGIN 

  part_query :=
    'select case when bitand(x.flags, 2) = 2 
                 then ''LOGMNR_''|| x.name
                 else x.name end table_name,
           ''P''|| TO_CHAR(ui.logmnr_uid) part_name,
           ui.logmnr_uid + 1 values_less_than
       from x$krvxdta x, system.logmnr_uid$ ui
      where bitand(x.flags,1) = 1 
        and exists (select 1 
                    from obj$ o, user$ usr
                    where o.owner# = usr.user#
                      and usr.name = ''SYSTEM''
                      and o.name = case when bitand(x.flags, 2) = 2 
                                        then ''LOGMNR_''|| x.name
                                        else x.name end
                      and o.remoteowner is null 
                      and o.linkname is null
                      and o.type# = 2)
        and not exists (select 1 
                        from obj$ o, user$ usr
                        where o.owner# = usr.user#
                          and usr.name = ''SYSTEM''
                          and o.name = case when bitand(x.flags, 2) = 2 
                                            then ''LOGMNR_''|| x.name
                                            else x.name end
                          and o.subname = ''P''|| TO_CHAR(ui.logmnr_uid)
                          and o.remoteowner is null 
                          and o.linkname is null
                          and o.type# = 19)
   union
     select case when bitand(x.flags, 2) = 2 
                 then ''LOGMNR_''|| x.name
                 else x.name end table_name,
           ''P''|| TO_CHAR(ui.logmnr_uid) part_name,
           ui.logmnr_uid + 1 values_less_than
       from x$krvxdta x, system.logmnrc_dbname_uid_map ui
      where bitand(x.flags,1) = 1 
        and bitand(x.flags,16) = 16 
        and exists (select 1 
                    from obj$ o, user$ usr
                    where o.owner# = usr.user#
                      and usr.name = ''SYSTEM''
                      and o.name = case when bitand(x.flags, 2) = 2 
                                        then ''LOGMNR_''|| x.name
                                        else x.name end
                      and o.remoteowner is null 
                      and o.linkname is null
                      and o.type# = 2)
        and not exists (select 1 
                        from obj$ o, user$ usr
                        where o.owner# = usr.user#
                          and usr.name = ''SYSTEM''
                          and o.name = case when bitand(x.flags, 2) = 2 
                                            then ''LOGMNR_''|| x.name
                                            else x.name end
                          and o.subname = ''P''|| TO_CHAR(ui.logmnr_uid)
                          and o.remoteowner is null 
                          and o.linkname is null
                          and o.type# = 19)
      order by values_less_than asc';
  open part_cur for part_query;
  loop
    -- part_rec.values_less_than is a number that is being converted to 
    -- a string so it does not need to be validity checked
    fetch part_cur into part_rec;
    exit when part_cur%NOTFOUND;
    alter_stmt := 'alter table system.' ||  
                   dbms_assert.enquote_name(part_rec.table_name, FALSE) || 
                   ' add partition ' || 
                   dbms_assert.enquote_name(part_rec.part_name, FALSE) ||
                   ' values less than (' || 
                   part_rec.values_less_than || 
                   ') logging';
    execute immediate alter_stmt;
    commit;
  end loop;
  close part_cur;
end;
/
-- Now move any migrated data into the partitioned tables
declare
  cursor c1 is 
   select o.name
     from obj$ o, user$ u,
    (select case when bitand(x.flags, 2) = 2
                 then 'LOGMNR_' || x.name || '_MIG' 
                 else x.name || '_MIG' end name
       from x$krvxdta x
      where bitand(flags,1) = 1) x
    where u.name = 'SYSTEM'
      and u.user# = o.owner#
      and x.name = o.name
      and o.remoteowner is null
      and o.linkname is null
      and o.type# = 2;
  cursor c2 (table_name varchar2) is
    select c.name 
      from obj$ o, col$ c, user$ u
      where o.name = table_name
        and o.obj# = c.obj#
        and o.remoteowner is null
        and o.linkname is null
        and o.type# = 2
        and u.name = 'SYSTEM'
        and o.owner# = u.user#;
  table_empty boolean;
  dummy number;
  newtable varchar2(30);
  newcol varchar2(30);
  col_list varchar2(30000);
  first_col boolean;
  stmt varchar2(4000);
begin
  for crec in c1 loop
    table_empty := false;
    begin
      execute immediate 'select 1 from SYSTEM.' || 
                         dbms_assert.enquote_name(crec.name, FALSE) || 
                        ' where rownum <2'
        into dummy;
    exception when no_data_found then
      table_empty := true;
    end;
    if table_empty then 
      stmt := 'drop table SYSTEM.'||dbms_assert.enquote_name(crec.name, FALSE);
      execute immediate stmt;
    else
      newtable := replace(crec.name, '_MIG');
      first_col := true;
      for c2rec in c2 (crec.name) loop
        if first_col then
          first_col := false;  
          col_list := dbms_assert.enquote_name(c2rec.name, FALSE);
        else
          col_list := col_list || ', ' || 
                      dbms_assert.enquote_name(c2rec.name, FALSE);
        end if;
      end loop;
      stmt :=  'insert into SYSTEM.'||
               dbms_assert.enquote_name(newtable, FALSE) || 
               ' ( ' ||col_list|| ') select ' ||
               col_list || ' from SYSTEM.' || 
               dbms_assert.enquote_name(crec.name, FALSE);
      execute immediate stmt;
      stmt := 'delete from SYSTEM.' ||
              dbms_assert.enquote_name(crec.name, FALSE);
      execute immediate 'delete from SYSTEM.' || 
                         dbms_assert.enquote_name(crec.name, FALSE);
      commit;
      stmt := 'drop table SYSTEM.' || 
              dbms_assert.enquote_name(crec.name, FALSE);
      execute immediate stmt;
    end if;
  end loop;
end;
/

-- Ensure all logminer data is marked for logging
ALTER TABLE SYSTEM.LOGMNR_AGE_SPILL$ 
               MODIFY LOB (SPILL_DATA) (PCTVERSION 0 CACHE);
ALTER TABLE SYSTEM.LOGMNR_RESTART_CKPT$
               MODIFY LOB (ckpt_info) (PCTVERSION 0 CACHE);
ALTER TABLE SYSTEM.LOGMNR_RESTART_CKPT$
               MODIFY LOB (client_data) (PCTVERSION 0 CACHE);
ALTER TABLE SYSTEM.LOGMNR_RESTART_CKPT_TXINFO$
               MODIFY LOB (TX_DATA) (PCTVERSION 0 CACHE);
ALTER TABLE SYS.LOGMNR_BUILDLOG LOGGING;
ALTER TABLE SYSTEM.LOGMNRC_DBNAME_UID_MAP LOGGING;
ALTER TABLE SYSTEM.LOGMNRC_GSII LOGGING;
ALTER TABLE SYSTEM.LOGMNRC_GTCS LOGGING;
ALTER TABLE SYSTEM.LOGMNRC_GTLO LOGGING;
ALTER TABLE SYSTEM.LOGMNRP_CTAS_PART_MAP LOGGING;
ALTER TABLE SYSTEM.LOGMNR_AGE_SPILL$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_ATTRCOL$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_ATTRIBUTE$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_CCOL$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_CDEF$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_COL$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_COLTYPE$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_DICTIONARY$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_DICTSTATE$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_ENC$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_ERROR$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_FILTER$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_GLOBAL$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_ICOL$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_IND$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_INDCOMPART$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_INDPART$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_INDSUBPART$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_KOPM$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_LOB$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_LOBFRAG$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_LOG$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_LOGMNR_BUILDLOG LOGGING;
ALTER TABLE SYSTEM.LOGMNR_NTAB$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_OBJ$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_OPQTYPE$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_PARAMETER$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_PARTOBJ$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_PROCESSED_LOG$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_PROPS$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_REFCON$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_RESTART_CKPT$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_RESTART_CKPT_TXINFO$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_SEED$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_SESSION$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_SESSION_EVOLVE$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_SUBCOLTYPE$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_TAB$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_TABCOMPART$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_TABPART$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_TABSUBPART$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_TS$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_TYPE$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_UID$ LOGGING;
ALTER TABLE SYSTEM.LOGMNR_USER$ LOGGING;
ALTER INDEX SYS.LOGMNR_BUILDLOG_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNRC_DBNAME_UID_MAP_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNRC_GSII_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNRC_GTCS_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNRC_I3GTLO LOGGING;
ALTER INDEX SYSTEM.LOGMNRC_GTLO_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNRC_I2GTLO LOGGING;
ALTER INDEX SYSTEM.LOGMNRP_CTAS_PART_MAP_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNRP_CTAS_PART_MAP_I LOGGING;
ALTER INDEX SYSTEM.LOGMNR_AGE_SPILL$_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1ATTRCOL$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1ATTRIBUTE$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1CCOL$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1CDEF$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1COL$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2COL$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I3COL$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1COLTYPE$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1DICTIONARY$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1ENC$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1ICOL$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2IND$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1IND$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1INDCOMPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2INDPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1INDPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1INDSUBPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1KOPM$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1LOB$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1LOBFRAG$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_LOG$_RECID LOGGING;
ALTER INDEX SYSTEM.LOGMNR_LOG$_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNR_LOG$_FLAGS LOGGING;
ALTER INDEX SYSTEM.LOGMNR_LOG$_FIRST_CHANGE# LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1LOGMNR_BUILDLOG LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1NTAB$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2NTAB$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1OBJ$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2OBJ$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1OPQTYPE$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_PARAMETER_INDX LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1PARTOBJ$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_PROCESSED_LOG$_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1PROPS$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1REFCON$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_RESTART_CKPT$_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNR_RESTART_CKPT_TXINFO$_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1SEED$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2SEED$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_SESSION_UK1 LOGGING;
ALTER INDEX SYSTEM.LOGMNR_SESSION_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNR_SESSION_EVOLVE$_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1SUBCOLTYPE$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2TAB$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1TAB$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1TABCOMPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2TABCOMPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1TABPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2TABPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1TABSUBPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I2TABSUBPART$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1TS$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1TYPE$ LOGGING;
ALTER INDEX SYSTEM.LOGMNR_UID$_PK LOGGING;
ALTER INDEX SYSTEM.LOGMNR_I1USER$ LOGGING;

-- Bug 5690427: Deprecate usage of system.logmnr_session$.branch_scn in 11
update system.logmnr_session$ set branch_scn = 0;
commit;
  
Rem=======================
Rem End Logminer Changes
Rem=======================

Rem==============================
Rem Begin Logical Standby Changes
Rem==============================

alter table system.logstdby$skip modify (name varchar2(65));
alter table system.logstdby$skip_support add (reg smallint);

-- Clean up skip rules based on audit actions which have no octdef
delete from system.logstdby$skip s
where s.statement_opt not in 
  (select a.name from sys.audit_actions a 
   where  a.action not between 100 and 150
   union
   select ss.name from system.logstdby$skip_support ss
   where  ss.action > 0); 
commit;

-- Grant and revoke both ignore the schema and name predicates
-- If they had defined multiple grant/revoke rules leave only the one
-- that dgls_skipddl would actually select
--
-- 1) Clean up rules for Grant:
update system.logstdby$skip s
set schema = '%', name = '%', statement_opt='GRANT'
where statement_opt = 'GRANT OBJECT';

delete from system.logstdby$skip s1
where statement_opt = 'GRANT'
and rowid != (select s3.rowid from 
                (select s2.rowid from system.logstdby$skip s2 
                 where statement_opt = 'GRANT' order by proc) s3
              where rownum < 2);
commit;

-- 2) Clean up rules for Revoke:
update system.logstdby$skip s
set schema = '%', name = '%', statement_opt='REVOKE'
where statement_opt = 'REVOKE OBJECT';

delete from system.logstdby$skip s1
where statement_opt = 'REVOKE'
and rowid != (select s3.rowid from 
                (select s2.rowid from system.logstdby$skip s2 
                 where statement_opt = 'REVOKE' order by proc) s3
              where rownum < 2);
commit;

-- Check if prepare/apply server settings by user will exceed default
-- max_servers.  If so, update max_servers in parameters table.
declare
  max_servers     NUMBER;
  apply_servers   NUMBER;
  prepare_servers NUMBER;
  stmt            varchar2(4000);
begin
  select nvl((select to_number(value) from system.logstdby$parameters
              where name = 'MAX_SERVERS'), 0),
         nvl((select to_number(value) from system.logstdby$parameters
              where name = 'PREPARE_SERVERS'), 0),
         nvl((select to_number(value) from system.logstdby$parameters
              where name = 'APPLY_SERVERS'), 0)
    into max_servers, prepare_servers, apply_servers from dual;

    -- check if prepare/apply server settings will exceed default max_servers
    if (max_servers = 0 and (prepare_servers + apply_servers > 0))
    then
      -- may need to set max_servers
      if (prepare_servers = 0)
      then
        prepare_servers := 1; -- need at least on preparer
      end if;

      if (apply_servers = 0)
      then
        apply_servers := 1;   -- need at least on applier
      end if;

      -- include fetch, reader and builder and check against default
      if (prepare_servers + apply_servers + 3 > 9)
      then
        -- max_servers needs to be at least this much
        -- max_servers is being converted from a number to a string so 
        -- does not require validity checking
        max_servers := prepare_servers + apply_servers + 3;
        stmt := 'insert into system.logstdby$parameters (name, value, type)' ||
                ' values (''MAX_SERVERS'', '|| max_servers ||', 1)';
        execute immediate stmt;
        commit;
      end if;

    end if;
end;
/

Rem============================
Rem End Logical Standby Changes
Rem============================

Rem======================
Rem Begin Streams Changes
Rem======================

DROP PACKAGE sys.dbms_apply_user_agent;

ALTER TABLE aq$_schedules ADD (job_name  VARCHAR2(30));

ALTER TABLE streams$_propagation_process ADD (
  original_propagation_name    varchar2(30),
  original_source_queue_schema varchar2(30),
  original_source_queue        varchar2(30),
  acked_scn                    number,
  auto_merge_threshold         number,
  creation_time                date DEFAULT SYSDATE
);

ALTER TABLE streams$_prepare_object ADD (
  cap_type            number default 0
);

drop index i_streams_prepare1;

create unique index i_streams_prepare1 on streams$_prepare_object
  (obj#, cap_type)
/

rem create a sequence for split-merge api
create sequence streams$_sm_id
 start with     1
 increment by   1
 nocache
 nocycle
/
Rem ****************************************************************
Rem Persistent tables for storing Streams topoloy information
Rem   -  streams$_database
Rem   -  streams$_component
Rem   -  streams$_component_link
Rem   -  streams$_component_prop
Rem ****************************************************************

Rem persistent table for Streams database

create table streams$_database
(
  global_name     varchar2(128) not null,         /* database covered by */
                                                    /* stream topologies */
  last_queried    date not null,        /* time stream topology data was */
                                          /* collected from the database */
  version         varchar2(30),                      /* database version */
                                           /* same as v$instance.version */
  compatibility   varchar2(30),           /* database compatible setting */
  management_pack_access
                  varchar2(30),       /* management pack access, values: */
                                      /* NULL :                 pre-11.1 */
                                      /* NONE : 11.1, no diagnostic pack */
                                      /* DIAGNOSTIC                      */
                                      /* DIAGNOSTIC+TUNING               */
  spare1          number,                              /* spare column 1 */
  spare2          number,                              /* spare column 2 */
  spare3          varchar2(4000),                      /* spare column 3 */
  spare4          date                                 /* spare column 4 */
)
tablespace SYSAUX
/
create unique index streams$_database_ind on streams$_database(global_name)
tablespace SYSAUX
/

Rem persistent table for Streams component
CREATE TABLE streams$_component
(
    COMPONENT_ID       NUMBER NOT NULL, /*system assigned unique component ID*/
    COMPONENT_NAME     VARCHAR2(194),               /* name of the component */
                                       /* COMPONENT_NAME of the Propagation  */
                                       /* Sender has the following form:     */
                                       /* "queue_schema"."queue_name"@dblink */
                                       /*  queue_schema   varchar2(30)       */
                                       /*  queue_name     varchar2(30)       */
                                       /*  dblink         varchar2(128)      */
                                       /*  In total 30 + 30 + 128 + 6 = 194  */
    COMPONENT_DB       VARCHAR2(128),     /* database on which comp. resides */
    COMPONENT_TYPE     NUMBER,              /* type of the Streams component */
                                                   /* 1              capture */
                                                   /* 2   propagation sender */
                                                   /* 3 propagation receiver */
                                                   /* 4                apply */
                                                   /* 5                queue */
    COMPONENT_PROPERTY NUMBER,                /* properties of the component */
                                                   /* 0x1 downstream capture */
                                                   /* 0x2      local capture */
                                                   /* 0x3         hot mining */
                                                   /* 0x4        cold mining */
                                                   /* 0x5     buffered queue */
                                                   /* 0x6   persistent queue */
    COMPONENT_CHANGED_TIME DATE, /* time that the component was last changed */
    SPARE1             NUMBER,                             /* spare column 1 */
    SPARE2             NUMBER,                             /* spare column 2 */
    SPARE3             VARCHAR2(4000),                     /* spare column 3 */
    SPARE4             DATE                                /* spare column 4 */
)
tablespace SYSAUX
/
CREATE UNIQUE INDEX streams$_component_ind ON
streams$_component(COMPONENT_ID)
tablespace SYSAUX
/

Rem persistent table for Streams component link
CREATE TABLE streams$_component_link
(
    SOURCE_COMPONENT_ID NUMBER NOT NULL,       /* ID of the source component */
    DEST_COMPONENT_ID   NUMBER NOT NULL,  /* ID of the destination component */
    PATH_ID             NUMBER NOT NULL,/*ID of the path the link belongs to */
    POSITION            NUMBER,/*1-based position of the link on stream path */
    PATH_FLAG           RAW(4) DEFAULT '00000000',/* flag of the stream path */
                         /* bit 1 -    whether the link is on an active path */
                         /* bit 2 - whether the link is on an optimized path */
                             /* value '00000000' - inactive unoptimized path */
                             /* value '00000001' -   active unoptimized path */
                             /* value '00000002' -   inactive optimized path */
                             /* value '00000003' -     active optimized path */
    ORIGINAL_PATH_ID    NUMBER DEFAULT NULL,/*id of the original stream path */
                          /* and it is only populated for the optimized path */
    SPARE1              NUMBER,                            /* spare column 1 */
    SPARE2              NUMBER,                            /* spare column 2 */
    SPARE3              VARCHAR2(4000),                    /* spare column 3 */
    SPARE4              DATE                               /* spare column 4 */
)
tablespace SYSAUX
/
CREATE UNIQUE INDEX streams$_component_link_ind ON
streams$_component_link(SOURCE_COMPONENT_ID, DEST_COMPONENT_ID, PATH_ID)
tablespace SYSAUX
/

Rem persistent table for Streams component properties
Rem such as source_database, apply_captured and message_delivery_mode
CREATE TABLE streams$_component_prop
(
    COMPONENT_ID       NUMBER NOT NULL, /*system assigned unique component ID*/
    PROP_NAME          VARCHAR2(30),                 /* name of the property */
    PROP_VALUE         VARCHAR2(4000),              /* value of the property */
    SPARE1             NUMBER,                             /* spare column 1 */
    SPARE2             NUMBER,                             /* spare column 2 */
    SPARE3             VARCHAR2(4000),                     /* spare column 3 */
    SPARE4             DATE                                /* spare column 4 */
)
tablespace SYSAUX
/
CREATE UNIQUE INDEX streams$_component_prop_ind ON
streams$_component_prop(COMPONENT_ID, PROP_NAME)
tablespace SYSAUX
/

-- If apply_captured is FALSE, then assume that the apply is for persistent
-- messages
update streams$_apply_process set flags = flags + 256
  where bitand (flags, 1) = 0 and bitand(flags, 256) = 0;
commit;

ALTER TABLE streams$_apply_milestone ADD (
  spill_lwm_scn       number,                                   /* spill SCN */
  lwm_external_pos    raw(64),            /* low watermark external position */
  spare2              number,
  spare3              varchar2(4000)
);

ALTER TABLE apply$_source_obj ADD (
  inst_external_pos   raw(64),    /* 128 (length of correlation ID) / 2 = 64 */
                                   /* external position, aka stream position */
  spare2              varchar2(4000),
  spare3              raw(2000)
);

ALTER TABLE apply$_source_schema ADD (
  inst_external_pos   raw(64),    /* 128 (length of correlation ID) / 2 = 64 */
                                   /* external position, aka stream position */
  spare2              varchar2(4000),
  spare3              raw(2000)
);

ALTER TABLE apply$_error ADD (
  external_source_pos   raw(64),                 /* external source position */
  spare4                raw(2000),
  spare5                varchar2(4000)
);

Rem AQ Notifications new columns in reg$
ALTER TABLE reg$ ADD (
  reg_id                     number,
  reg_time                   timestamp with time zone,
  ntfn_grouping_class        number,
  ntfn_grouping_value        number,
  ntfn_grouping_type         number,
  ntfn_grouping_start_time   timestamp with time zone,
  ntfn_grouping_repeat_count number,
  grouping_inst_id           number
);

Rem======================
Rem End Streams Changes
Rem======================

Rem======================
Rem Begin CDC Changes
Rem======================

Rem add new columns to cdc_change_sets$

alter table cdc_change_sets$
add (
  lowest_timestamp  date,                 /* lowest timestamp for set */
  time_scn_name     varchar2(30)          /* table tomap timestamp-scn for set */
)
/

Rem we changed the names of the views in 11g, must drop old objects if exist

drop view change_sources;
drop public synonym change_sources;
drop view change_sets;
drop public synonym change_sets;
drop view change_tables;
drop public synonym change_tables;
drop view change_propagations;
drop public synonym change_propagations;
drop view change_propagation_sets;
drop public synonym change_propagation_sets;

Rem old 9.2 view was never dropped
drop view logmnr_dict;
drop public synonym logmnr_dict;

Rem add missing metadata into row
update cdc_change_sources$ set publisher='SYSTEM', capqueue_name='NONE',
   capqueue_tabname='NONE', source_enabled='Y' where
   source_name='HOTLOG_SOURCE';
update cdc_change_sources$ set publisher='SYSTEM', capture_name='NONE',
   capqueue_name='NONE', capqueue_tabname='NONE', source_enabled='Y' where
   source_name='SYNC_SOURCE';

Rem dropping the all_xxx objects as these are duplicates of the user_xxxx ones
Rem then we added a synonym to point user_xxx to all_xxx object
drop view all_source_tables;
drop public synonym all_source_tables;
drop view all_published_columns;
drop public synonym all_published_columns;
drop view all_subscriptions;
drop public synonym all_subscriptions;
drop view all_subscribed_tables;
drop public synonym all_subscribed_tables;
drop view all_subscribed_columns;
drop public synonym all_subscribed_columns;


Rem======================
Rem End CDC Changes
Rem======================


Rem ------------------------------------------------
Rem  OLAP related changes - BEGIN
Rem ------------------------------------------------

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON OLAPImpl_t FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON OLAPRanCurImpl_t FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem ------------------------------------------------
Rem  OLAP related changes - END
Rem ------------------------------------------------

Rem ----------------------------------------
Rem Resource Manager related changes - BEGIN
Rem ----------------------------------------

alter table resource_plan$ add (
  sub_plan    NUMBER,
  mgmt_method VARCHAR2(30),
  max_iops    NUMBER,
  max_mbps    NUMBER
);
update resource_plan$ set 
  mgmt_method = cpu_method, 
  max_iops = 0, 
  max_mbps = 0
  where mgmt_method is null;

commit;

update resource_plan$ set 
  sub_plan = 0 where sub_plan is NULL; 
commit;

alter table resource_consumer_group$ add (
  internal_use NUMBER,
  mgmt_method varchar2(30),
  category varchar2(30)
);
update resource_consumer_group$ set 
  mgmt_method = cpu_method
  where mgmt_method is null;
commit;

update resource_consumer_group$ set 
  internal_use = 0 where internal_use is NULL;
commit;

update resource_consumer_group$ set 
  category = 'OTHER' where category is NULL;
commit;

create table resource_category$
( name              varchar2(30),                        /* name of category */
  mandatory         number,                 /* whether category is mandatory */
  description       varchar2(2000),                               /* comment */
  status            varchar2(30)                /* whether active or pending */
);

truncate table resource_category$;

insert into resource_category$ 
  values ('ADMINISTRATIVE', 0, 'Administrative Consumer Groups', 'ACTIVE');
insert into resource_category$ 
  values ('INTERACTIVE', 0, 'Interactive, OLTP Consumer Groups', 'ACTIVE');
insert into resource_category$ 
  values ('BATCH', 0, 'Batch, Non-Interactive Consumer Groups', 'ACTIVE');
insert into resource_category$ 
  values ('MAINTENANCE', 0, 'Maintenance Consumer Groups', 'ACTIVE');
insert into resource_category$ 
  values ('OTHER', 1, 'Unclassified Consumer Groups', 'ACTIVE');

alter table resource_plan_directive$ add (
  mgmt_p1             NUMBER,
  mgmt_p2             NUMBER,
  mgmt_p3             NUMBER,
  mgmt_p4             NUMBER,
  mgmt_p5             NUMBER,
  mgmt_p6             NUMBER,
  mgmt_p7             NUMBER,
  mgmt_p8             NUMBER,
  switch_for_call     NUMBER,
  switch_io_megabytes NUMBER,
  switch_io_reqs      NUMBER
); 
update resource_plan_directive$ set 
  mgmt_p1 = cpu_p1,
  mgmt_p2 = cpu_p2,
  mgmt_p3 = cpu_p3,
  mgmt_p4 = cpu_p4,
  mgmt_p5 = cpu_p5,
  mgmt_p6 = cpu_p6,
  mgmt_p7 = cpu_p7,
  mgmt_p8 = cpu_p8,
  switch_for_call = switch_back,
  switch_io_megabytes = 4294967295,
  switch_io_reqs = 4294967295
  where switch_io_megabytes is null;
commit;

create table resource_storage_pool_mapping$
( attribute           varchar2(30),                     /* mapping attribute */
  value               varchar2(30),                       /* attribute value */
  pool_name           varchar2(30),                  /* name of storage pool */
  status              varchar2(30)              /* whether active or pending */
);

truncate table resource_storage_pool_mapping$;

insert into resource_storage_pool_mapping$ 
  (attribute, pool_name, status)
  values ('LOG_FILES', 'MANAGED_FILES', 'ACTIVE');

insert into resource_storage_pool_mapping$ 
  (attribute, pool_name, status)
  values ('TEMP_FILES', 'MANAGED_FILES', 'ACTIVE');

insert into resource_storage_pool_mapping$ 
  (attribute, pool_name, status)
  values ('RECOVERY_AREA', 'MANAGED_FILES', 'ACTIVE');

create table resource_capability$
( cpu_capable         number,                 /* TRUE, if CPU can be managed */
  io_capable          varchar2(30),                 /* type of IO management */
  status              varchar2(30)              /* whether active or pending */
);

truncate table resource_capability$;

insert into resource_capability$ 
  (cpu_capable, status)
  values (1, 'ACTIVE');

create table resource_instance_capability$
( instance_number     number,                             /* instance number */
  io_shares           number,       /* number of IO shares for this instance */
  status              varchar2(30)              /* whether active or pending */
);

create table resource_io_calibrate$
( start_time          timestamp,                /* start time of calibration */
  end_time            timestamp,                  /* end time of calibration */
  max_iops            number,        /* maximum small IO requests per second */
  max_mbps            number,           /* maximum MB per second of large IO */
  max_pmbps           number,      /* per process - maximum MBPS of large IO */
  latency             number,            /* latency for db-block sized i/o's */
  num_disks           number        /* # of physical disks specified by user */
);

Rem ----------------------------------------
Rem Resource Manager related changes - END
Rem ----------------------------------------

Rem ==========================================================================
Rem --------------------------------------------------------------------------
Rem Optimizer tables - BEGIN
Rem Some of these tables used to be in catost.sql which was invoked during 
Rem catproc time. So there were no upgrade action for these tables. In 11g,
Rem these tables are moved to doptim.bsq which is not invoked during upgrade.
Rem Hence the create table statements are added in this upgrade script. When
Rem we upgrade from 10g, these tables may exist in the database, but it is ok
Rem since we suppress already exist errors when we run this script.
Rem --------------------------------------------------------------------------

Rem=========================================================================
Rem Begin Optimizer statistics history tables.
Rem=========================================================================

Rem Table to store optimizer statistics history 
Rem for table and table partition objects
create table WRI$_OPTSTAT_TAB_HISTORY
( obj#          number not null,                            /* object number */
  savtime       timestamp with time zone,      /* timestamp when stats saved */
  flags         number,
  rowcnt        number,                                    /* number of rows */
  blkcnt        number,                                  /* number of blocks */
  avgrln        number,                                /* average row length */
  samplesize    number,                 /* number of rows sampled by Analyze */
  analyzetime   date,                        /* timestamp when last analyzed */
  cachedblk     number,                            /* blocks in buffer cache */
  cachehit      number,                                   /* cache hit ratio */
  logicalread   number,                           /* number of logical reads */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        timestamp with time zone
) tablespace SYSAUX 
pctfree 1
enable row movement
/
create unique index I_WRI$_OPTSTAT_TAB_OBJ#_ST on 
  wri$_optstat_tab_history(obj#, savtime)
  tablespace SYSAUX
/
create index I_WRI$_OPTSTAT_TAB_ST on 
  wri$_optstat_tab_history(savtime)
  tablespace SYSAUX
/

Rem Table to store optimizer statistics history 
Rem for index and index partition objects
create table WRI$_OPTSTAT_IND_HISTORY
( obj#          number not null,                            /* object number */
  savtime       timestamp with time zone,      /* timestamp when stats saved */
  flags         number,
  rowcnt        number,                       /* number of rows in the index */
  blevel        number,                                       /* btree level */
  leafcnt       number,                                  /* # of leaf blocks */
  distkey       number,                                   /* # distinct keys */
  lblkkey       number,                          /* avg # of leaf blocks/key */
  dblkkey       number,                          /* avg # of data blocks/key */
  clufac        number,                                 /* clustering factor */
  samplesize    number,                 /* number of rows sampled by Analyze */
  analyzetime   date,                        /* timestamp when last analyzed */
  guessq        number,                                 /* IOT guess quality */
  cachedblk     number,                            /* blocks in buffer cache */
  cachehit      number,                                   /* cache hit ratio */
  logicalread   number,                           /* number of logical reads */
  spare1        number,
  spare2        number,
  spare3        number,
  spare4        varchar2(1000),
  spare5        varchar2(1000),
  spare6        timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/
create unique index I_WRI$_OPTSTAT_IND_OBJ#_ST on 
  wri$_optstat_ind_history(obj#, savtime)
  tablespace SYSAUX
/
create index I_WRI$_OPTSTAT_IND_ST on 
  wri$_optstat_ind_history(savtime)
  tablespace SYSAUX
/

Rem Column statistics history
create table WRI$_OPTSTAT_HISTHEAD_HISTORY
 (obj#            number not null,                          /* object number */
  intcol#         number not null,                 /* internal column number */
  savtime         timestamp with time zone,    /* timestamp when stats saved */
  flags           number,                                           /* flags */
  null_cnt        number,                  /* number of nulls in this column */
  minimum         number,           /* minimum value (if 1-bucket histogram) */
  maximum         number,           /* minimum value (if 1-bucket histogram) */
  distcnt         number,                            /* # of distinct values */
  density         number,                                   /* density value */
  lowval          raw(32),
                        /* lowest value of column (second lowest if default) */
  hival           raw(32),
                      /* highest value of column (second highest if default) */
  avgcln          number,                           /* average column length */
  sample_distcnt  number,                /* sample number of distinct values */
  sample_size     number,             /* for estimated stats, size of sample */
  timestamp#      date,                   /* date of histogram's last update */
  expression      clob,                         /* extension of column group */
  colname         varchar2(30),               /* column name if an extension */ 
  spare1          number,           
  spare2          number,
  spare3          number,            
  spare4          varchar2(1000),                        
  spare5          varchar2(1000),
  spare6          timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/

Rem In 11g we added 2 more columns to the table and changed the index defn.
Rem So change these definitions. 
alter table wri$_optstat_histhead_history add expression clob
/
alter table  wri$_optstat_histhead_history add colname varchar2(30)
/
drop index I_WRI$_OPTSTAT_HH_OBJ_ICOL_ST
/

create unique index I_WRI$_OPTSTAT_HH_OBJ_ICOL_ST on
  wri$_optstat_histhead_history (obj#, intcol#, savtime, colname)
  tablespace SYSAUX
/
create index I_WRI$_OPTSTAT_HH_ST on
  wri$_optstat_histhead_history (savtime)
  tablespace SYSAUX
/

Rem Histogram history
create table WRI$_OPTSTAT_HISTGRM_HISTORY
( obj#            number not null,                          /* object number */
  intcol#         number not null,                 /* internal column number */
  savtime         timestamp with time zone,    /* timestamp when stats saved */
  bucket          number not null,                          /* bucket number */
  endpoint        number not null,                  /* endpoint hashed value */
  epvalue         varchar2(1000),              /* endpoint value information */
  colname         varchar2(30),               /* column name if an extension */
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/

Rem In 11g we added 1 more column to the table and changed the index defn.
Rem So change these definitions. 
alter table  wri$_optstat_histgrm_history add colname varchar2(30)
/
drop index I_WRI$_OPTSTAT_H_OBJ#_ICOL#_ST
/

create index I_WRI$_OPTSTAT_H_OBJ#_ICOL#_ST on 
  wri$_optstat_histgrm_history(obj#, intcol#, savtime, colname)
  tablespace SYSAUX
/
create index I_WRI$_OPTSTAT_H_ST on 
  wri$_optstat_histgrm_history(savtime)
  tablespace SYSAUX
/

Rem Aux_stats$ history
create table WRI$_OPTSTAT_AUX_HISTORY
( 
  savtime timestamp with time zone,
  sname varchar2(30),  -- M_IDEN
  pname varchar2(30),  -- M_IDEN
  pval1 number,
  pval2 varchar2(255), 
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/
create index I_WRI$_OPTSTAT_AUX_ST on 
  wri$_optstat_aux_history(savtime)
  tablespace SYSAUX
/

Rem Optimizer stats operations history
create table WRI$_OPTSTAT_OPR
( operation       varchar2(64),
  target          varchar2(64),
  start_time      timestamp with time zone,
  end_time        timestamp with time zone,
  flags           number,
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone
) tablespace SYSAUX
pctfree 1
enable row movement
/
create index I_WRI$_OPTSTAT_OPR_STIME on 
  wri$_optstat_opr(start_time)
  tablespace SYSAUX
/

Rem=========================================================================
Rem END Optimizer statistics history tables.
Rem=========================================================================


Rem=========================================================================
Rem Begin Optimizer statistics preference tables
Rem=========================================================================

Rem This table contains various settings used in maintaining
Rem stats history. Currently the following are stored. 
Rem  sname             sval1    sval2  
Rem  -----------------------
Rem  SKIP_TIME         null   time used for purging history or time
Rem                           when we last skiped saving old stats
Rem  STATS_RETENTION  retention  null
Rem                   in days
Rem This table is not created in SYSAUX so that we can
Rem write into it even if SYSAUX is offline.
Rem
Rem This table also contains the default values for dbms_stats
Rem procedure arguments. The procedures set_param, get_param 
Rem allows the users to change the default.
Rem
Rem Columns             Used for
Rem -----------------------------------------------
Rem sname               parameter name
Rem sval1               parameter value
Rem sval2               time of setting the default
Rem spare1              1 if oracle default, null if set by user.
Rem spare4              parameter value (stored in varchar,
Rem                       please refer to set_param, get_param)
Rem 
create table OPTSTAT_HIST_CONTROL$
( 
  sname           varchar2(30),  -- M_IDEN
  sval1           number,
  sval2           timestamp with time zone,
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          varchar2(1000),
  spare5          varchar2(1000),
  spare6          timestamp with time zone
)
/

Rem 
Rem This table contains the statistics preferences specified by a user.
Rem The preferences are added, changed, deleted, imported and exported 
Rem via a set of new pl/sql procedures in the dbms_stats package.
Rem See procedures *PREFERENCE in file dbmsstat.sql.
Rem 
Rem Columns            Description
Rem ---------------------------------------------------------------
Rem obj#               table object number (tp join with obj$.obj#)
Rem pname              preference name (e.g, METHOD_OPT)
Rem valnum             parameter number value
Rem valchar            parameter number character
Rem chgtime            changed time
Rem 
create table OPTSTAT_USER_PREFS$
(
  obj#            number,        -- table object number 
  pname           varchar2(30),  -- M_IDEN
  valnum          number,
  valchar         varchar2(1000),
  chgtime         timestamp with time zone,
  spare1          number
)
/
create unique index i_user_prefs$ on optstat_user_prefs$ (obj#, pname)
/

Rem=========================================================================
Rem END Optimizer statistics preference tables
Rem=========================================================================


Rem=========================================================================
Rem BEGIN Synopsis tables
Rem=========================================================================

Rem Table to store mapping relationship between partition groups 
Rem to synopis#. for example, 100 partitions are divided into 2 
Rem groups, partition 1 - 10 has one synopsis and partition 11 - 
Rem 100 has another synopsis
Rem if 1 partition corresponds to 1 group, we add a special row
Rem (obj#, ONE_TO_ONE) where obj# is the tables obj and ONE_TO_ONE
Rem marks the mapping from partitions to group is one to one.
create table WRI$_OPTSTAT_SYNOPSIS_PARTGRP
( obj#   number not null,   /* obj# of a partition or a table */
  group# number not null                      /* group number */
) tablespace SYSAUX 
pctfree 1
enable row movement
/
create index I_WRI$_OPTSTAT_SYNOPPARTGRP on 
  wri$_optstat_synopsis_partgrp (obj#)
  tablespace SYSAUX
/

Rem Table to store synopsis meta data
create table WRI$_OPTSTAT_SYNOPSIS_HEAD$ 
( bo#           number not null,    /* table obj# */
  group#        number not null,    /* partition group number */
  intcol#       number not null,             /* column number */
  synopsis#     number not null primary key,                           
  split         number,     
              /* number of splits during creation of synopsis */
  analyzetime   date,
              /* time when this synopsis is gathered */
  spare1        number,
  spare2        clob
) tablespace SYSAUX 
pctfree 1
enable row movement
/
create index I_WRI$_OPTSTAT_SYNOPHEAD on 
  wri$_optstat_synopsis_head$ (bo#, group#, intcol#)
  tablespace SYSAUX
/

Rem Table to store the synopsis
create table WRI$_OPTSTAT_SYNOPSIS$
( synopsis#     number not null,           
  hashvalue     number not null 
) tablespace SYSAUX 
pctfree 1
enable row movement
/

begin
execute immediate
q'#create index I_WRI$_OPTSTAT_SYNOPSIS on 
   wri$_optstat_synopsis$ (synopsis#)
   tablespace SYSAUX #';
exception
  when others then
    if (sqlcode = -904) then 
      -- ORA-904 during reupgrde: "S"."SYNOPSIS#": invalid identifier 
      -- when insert statement is executed
      null;
    else
      raise;
    end if;
end;
/

create sequence group_num_seq START WITH 1 INCREMENT BY 1;

create sequence synopsis_num_seq START WITH 1 INCREMENT BY 1;

Rem=========================================================================
Rem END Synopsis tables
Rem=========================================================================

Rem create index on ol$nodes
create index outln.ol$node_ol_name on outln.ol$nodes(ol_name)
/

Rem =========================================================================
Rem BEGIN Global temporary table for incr. maintenance of histograms
Rem =========================================================================

create global temporary table finalhist$ 
(endpoint        number not null,                  /* endpoint hashed value */
 epvalue         varchar2(1000),              /* endpoint value information */
 bucket          number not null,                          /* bucket number*/
 spare1          varchar2(1000),
 spare2          number,
 spare3          number
) on commit delete rows
/
Rem =========================================================================
Rem END Global temporary table for incr. maintenance of histograms
Rem =========================================================================

Rem ----------------------------------------
Rem Optimizer tables - END
Rem ----------------------------------------
Rem ========================================================================

Rem MV Log related changes
REM Publish MV logs (set KKZLOGPUBL flag) (KKZLOGPUBL = 0x2000 = 8192)
update sys.mlog$ set flag = flag + 8192 where bitand(flag, 8192) = 0;
commit;

Rem=========================================================================
Rem  Add changes to SYSTEM dictionary objects here 
Rem=========================================================================

Rem synonym specific policies associated with the parent synonyms
update obj$ o set flags = flags + 256
  where type# = 5 and
        bitand (flags, 256) = 0 and
        exists (select 1 from rls$ r where o.obj# = r.ptype);
commit;

Rem clear 0x00200000 (read-only table flag) in trigflag during upgrade
update tab$ set trigflag = trigflag - 2097152
  where bitand(trigflag, 2097152) <> 0;
commit;

Rem Bug 5383828: Change NULLs found in col$.spare3 to zero
update col$ set spare3 = 0 where spare3 is null;
commit;

Rem ========================================================================
Rem Upgrade system types to 10.2
Rem ========================================================================

--
-- Used to pass info about FILTER BY  columns to 
-- ODCIIndexStart, ODCIIndexCost and ODCIIndexSelectivity
--
-- /*******************************************************/
-- /* TYPE ODCIFilterInfo:                                */
-- /* ColInfo     -- information about FILTER BY columns  */
-- /* Flags       -- see ODCIConst.ODCIPredInfo.Flags     */
-- /* Strt        -- start value                          */
-- /* Stop        -- stop value                           */
-- /*******************************************************/

CREATE OR REPLACE TYPE ODCIFilterInfo AS OBJECT
(
  ColInfo     SYS.ODCIColInfo,
  Flags       NUMBER,
  Strt        SYS.ANYDATA,
  Stop        SYS.ANYDATA
);
/

CREATE OR REPLACE TYPE ODCIFilterInfoList 
  AS VARRAY(32000) OF ODCIFilterInfo;
/


--
-- Used to pass info about ORDER BY  columns to 
-- ODCIIndexStart, ODCIIndexCost and ODCIIndexSelectivity
--
-- /*******************************************************/
-- /* TYPE ODCIOrderByInfo:                               */
-- /* ExprType       -- denotes COLUMN or Ancillary Op    */
-- /* ObjectSchema   -- Schema of the ancillary op/table  */
-- /* TableName      -- Table name for column             */ 
-- /* ExprName       -- Column or Anc Op  name            */
-- /* SortOrder      -- ASC or DESC sort                  */
-- /*******************************************************/

CREATE OR REPLACE TYPE ODCIOrderByInfo AS OBJECT
(
  ExprType          NUMBER,
  ObjectSchema      VARCHAR2(30),
  TableName         VARCHAR2(30),
  ExprName          VARCHAR2(30),
  SortOrder         NUMBER
);
/  

CREATE OR REPLACE TYPE ODCIOrderByInfoList
  AS VARRAY(32) OF ODCIOrderByInfo;
/


--
-- Used by ODCIIndexStart, ODCIStatsIndexCost
--
--/*********************************************************/
--/*     TYPE ODCICompQueryInfo:                           */
--/* PredInfo       -- info about FILTER BY columns        */
--/* ObyInfo       -- info about ORDER BY columns/anc op   */
--/*********************************************************/

CREATE OR REPLACE TYPE ODCICompQueryInfo AS OBJECT
(
  PredInfo    ODCIFilterInfoList,
  ObyInfo     ODCIOrderByInfoList
);
/

ALTER TYPE sys.ODCIColInfo ADD ATTRIBUTE 
   (ColInfoFlags NUMBER, OrderByPosition NUMBER, 
    TablePartitionIden NUMBER, TablePartitionTotal NUMBER) CASCADE;

ALTER TYPE sys.ODCIQueryInfo ADD ATTRIBUTE 
   (CompInfo ODCICompQueryInfo) CASCADE;

ALTER TYPE sys.ODCIIndexInfo ADD ATTRIBUTE
   (IndexPartitionIden NUMBER, IndexPartitionTotal NUMBER) CASCADE;

ALTER TYPE sys.ODCIPartInfo ADD ATTRIBUTE
   (IndexPartitionIden NUMBER, PartOp NUMBER) CASCADE;

Rem Evolve Type sys.aq$_reg_info

-- Turn ON the event to enable DDL on AQ tables
alter session set events  '10851 trace name context forever, level 1';

ALTER TYPE sys.aq$_reg_info
ADD ATTRIBUTE(ntfn_grouping_class NUMBER, ntfn_grouping_value NUMBER,
              ntfn_grouping_type  NUMBER,  
              ntfn_grouping_start_time   TIMESTAMP WITH TIME ZONE,
              ntfn_grouping_repeat_count NUMBER)
CASCADE;

ALTER TYPE sys.aq$_reg_info ADD CONSTRUCTOR FUNCTION aq$_reg_info(
  name             VARCHAR2,
  namespace        NUMBER,
  callback         VARCHAR2,
  context          RAW,
  anyctx           SYS.ANYDATA,
  ctxtype          NUMBER,
  qosflags         NUMBER,
  payloadcbk       VARCHAR2,
  timeout          NUMBER)
RETURN SELF AS RESULT CASCADE;

ALTER TYPE sys.aq$_reg_info ADD CONSTRUCTOR FUNCTION aq$_reg_info(
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
RETURN SELF AS RESULT CASCADE;

-- create type for storing grouping ntfn data for AQ namespace
CREATE or replace TYPE sys.aq$_ntfn_msgid_array 
AS VARRAY(1073741824) OF raw(16)
/

--Bug fix of 5943749.
GRANT EXECUTE ON aq$_ntfn_msgid_array TO PUBLIC
/

ALTER TYPE sys.aq$_descriptor
  ADD ATTRIBUTE(msgid_array sys.aq$_ntfn_msgid_array, ntfnsRecdInGrp NUMBER)
  CASCADE
/

ALTER TYPE sys.aq$_srvntfn_message
  ADD ATTRIBUTE(msgid_array sys.aq$_ntfn_msgid_array, ntfnsRecdInGrp NUMBER, pblob BLOB)
  CASCADE
/

-- added a separate alter type here per comment by file owner
ALTER TYPE sys.aq$_srvntfn_message
  ADD ATTRIBUTE(reg_id NUMBER)
  CASCADE
/

ALTER TYPE sys.aq$_event_message
  ADD ATTRIBUTE(pblob BLOB)
  CASCADE
/

-- Turn OFF the event to disable DDL on AQ tables
alter session set events  '10851 trace name context off';

-- Types evolved by 11g change notification
-- We are dropping the old type definitions here because we have
--  increased the VARRAY upper limit in some of these types.
-- The types should get recreated (incluiding the new ones) when
-- catchnf.sql is executed.

drop type chnf$_desc;
drop type chnf$_tdesc_array;
drop type chnf$_tdesc;
drop type chnf$_rdesc_array;
drop type chnf$_rdesc;

-- New attributes and constructor function added to chnf$_reg_info
ALTER TYPE sys.chnf$_reg_info 
ADD ATTRIBUTE(ntfn_grouping_class NUMBER, ntfn_grouping_value NUMBER,
              ntfn_grouping_type  NUMBER,
              ntfn_grouping_start_time   TIMESTAMP WITH TIME ZONE,
              ntfn_grouping_repeat_count NUMBER) CASCADE;

ALTER TYPE sys.chnf$_reg_info ADD CONSTRUCTOR FUNCTION chnf$_reg_info(
  callback varchar2,
  qosflags number,
  timeout number)
RETURN SELF AS RESULT CASCADE;

ALTER TYPE sys.chnf$_reg_info ADD CONSTRUCTOR FUNCTION chnf$_reg_info(
  callback varchar2,
  qosflags number,
  timeout number,
  operations_filter number,
  transaction_lag number)  -- 10gR2 type for backward compat
RETURN SELF AS RESULT CASCADE;

ALTER TYPE sys.chnf$_reg_info ADD CONSTRUCTOR FUNCTION chnf$_reg_info(
  callback varchar2,
  qosflags number,
  timeout number,
  operations_filter number,
  ntfn_grouping_class        NUMBER,
  ntfn_grouping_value        NUMBER,
  ntfn_grouping_type         NUMBER,
  ntfn_grouping_start_time   TIMESTAMP WITH TIME ZONE,
  ntfn_grouping_repeat_count NUMBER)
RETURN SELF AS RESULT CASCADE;

                              
Rem ========================================================================
Rem  All additions/modifications to lcr$_{row,ddl}_record must go here.
Rem ========================================================================


Rem ========================================================================
Rem  Begin (modify flags in partobj$ for IOT top indexes and LOB indexes)
Rem ========================================================================

update sys.partobj$ p$
set p$.flags = p$.flags+256
where to_number(bitand(p$.flags,256)) = 0
and p$.obj# in
(select obj# from sys.ind$ where type#=4);

update sys.partobj$ p$
set p$.flags = p$.flags+512
where to_number(bitand(p$.flags,512)) = 0
and p$.obj# in
(select obj# from sys.ind$ where type#=8);

commit;

Rem ========================================================================
Rem  End (modify flags in partobj$ for IOT top indexes and LOB indexes)
Rem ========================================================================


Rem ========================================================================
Rem ALERT_TYPE upgrade execution_context_id to varchar2(128)
Rem ========================================================================
ALTER TABLE wri$_alert_outstanding 
         MODIFY ( execution_context_id VARCHAR2(128) ); 
ALTER TABLE wri$_alert_history 
         MODIFY ( execution_context_id VARCHAR2(128) ); 

-- type alert_type is used for AQ messages
-- Turn ON the event to enable DDL on AQ tables
alter session set events  '10851 trace name context forever, level 1';

alter type sys.alert_type
      modify attribute execution_context_id varchar2(128) cascade;

-- Turn OFF the event to disable DDL on AQ tables
alter session set events  '10851 trace name context off';

Rem ========================================================================
Rem AWR Report Types
Rem ========================================================================
/*
 * Upgrade AWR report types
 */
drop type AWRRPT_ROW_TYPE FORCE
/
drop type AWRRPT_NUM_ARY FORCE
/
drop type AWRRPT_VCH_ARY FORCE
/
drop type AWRRPT_CLB_ARY FORCE
/
alter type AWRDRPT_TEXT_TYPE modify attribute output varchar2(320 CHAR) cascade;
/

declare
  type MgmtSnapshotCurTyp is ref cursor;
  mgmtSnapshotCur MgmtSnapshotCurTyp;
  snapId NUMBER;
  instanceNum NUMBER;
  prevInstNum NUMBER;
begin
  prevInstNum := -1;
  open mgmtSnapshotCur for
    'select snap_id, instance_number from dbsnmp.mgmt_snapshot order by instance_number for update';
  loop
      fetch mgmtSnapshotCur into snapId, instanceNum;
      exit when mgmtSnapshotCur%NOTFOUND;
      if prevInstNum = instanceNum then
        execute immediate 'delete from dbsnmp.mgmt_snapshot
        where snap_id = ' || snapId || ' and instance_number = ' || instanceNum;
      else
        prevInstNum := instanceNum;
      end if;
  end loop;
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -942 THEN
       NULL; -- Table not found
      ELSE
       RAISE;
      END IF;
  close mgmtSnapshotCur;
end;
/
commit
/

alter table dbsnmp.mgmt_snapshot drop constraint INST_NUM_KEY
/
alter table dbsnmp.mgmt_snapshot add (constraint INST_NUM_KEY unique (instance_number))
/

Rem=========================================================================
Rem BEGIN : BUG 7829203, DEFAULT_PWD$ CHANGES
Rem=========================================================================

Rem Created SYS.DEFAULT_PWD$
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE SYS.DEFAULT_PWD$ (user_name varchar2(128),
                     pwd_verifier  varchar2(512),pv_type NUMBER default 0)';
EXCEPTION
  WHEN OTHERS THEN
  IF SQLCODE IN ( -00955) THEN NULL; --ignore when table already exists
    DBMS_OUTPUT.PUT_LINE('TABLE SYS.DEFAULT_PWD$ ALREADY EXISTS');
  ELSE RAISE;
  END IF;
END;
/

Rem Create UNIQUE Index ON SYS.DEFAULT_PWD$

BEGIN
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

Rem Create Procedure for inserting into SYS.DEFAULT_PWD$

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

Rem Inserting values into SYS.DEFAULT_PWD$
Rem List of accounts with default passwords

exec insert_into_defpwd('AASH',  '9B52488370BB3D77');
exec insert_into_defpwd('ABA1',  '30FD307004F350DE');
exec insert_into_defpwd('ABM',  'D0F2982F121C7840');
exec insert_into_defpwd('AD_MONITOR',  '54F0C83F51B03F49');
exec insert_into_defpwd('ADAMS',  '72CDEF4A3483F60D');
exec insert_into_defpwd('ADS',  'D23F0F5D871EB69F');
exec insert_into_defpwd('ADSEUL_US',  '4953B2EB6FCB4339');
exec insert_into_defpwd('AHL',  '7910AE63C9F7EEEE');
exec insert_into_defpwd('AHM',  '33C2E27CF5E401A4');
exec insert_into_defpwd('AK',  '8FCB78BBA8A59515');
exec insert_into_defpwd('AL',  '384B2C568DE4C2B5');
exec insert_into_defpwd('ALA1',  '90AAC5BD7981A3BA');
exec insert_into_defpwd('ALLUSERS',  '42F7CD03B7D2CA0F');
exec insert_into_defpwd('ALR',  'BE89B24F9F8231A9');
exec insert_into_defpwd('AMA1',  '585565C23AB68F71');
exec insert_into_defpwd('AMA2',  '37E458EE1688E463');
exec insert_into_defpwd('AMA3',  '81A66D026DC5E2ED');
exec insert_into_defpwd('AMA4',  '194CCC94A481DCDE');
exec insert_into_defpwd('AMF',  'EC9419F55CDC666B');
exec insert_into_defpwd('AMS',  'BD821F59270E5F34');
exec insert_into_defpwd('AMS1',  'DB8573759A76394B');
exec insert_into_defpwd('AMS2',  'EF611999C6AD1FD7');
exec insert_into_defpwd('AMS3',  '41D1084F3F966440');
exec insert_into_defpwd('AMS4',  '5F5903367FFFB3A3');
exec insert_into_defpwd('AMSYS',  '4C1EF14ECE13B5DE');
exec insert_into_defpwd('AMV',  '38BC87EB334A1AC4');
exec insert_into_defpwd('AMW',  '0E123471AACA2A62');
exec insert_into_defpwd('ANNE',  '1EEA3E6F588599A6');
exec insert_into_defpwd('ANONYMOUS',  '94C33111FD9C66F3');
exec insert_into_defpwd('AOLDEMO',  'D04BBDD5E643C436');
exec insert_into_defpwd('AP',  'EED09A552944B6AD');
exec insert_into_defpwd('APA1',  'D00197BF551B2A79');
exec insert_into_defpwd('APA2',  '121C6F5BD4674A33');
exec insert_into_defpwd('APA3',  '5F843C0692560518');
exec insert_into_defpwd('APA4',  'BF21227532D2794A');
exec insert_into_defpwd('APEX_PUBLIC_USER',  '084062DA5B2E2B75');
exec insert_into_defpwd('APPLEAD',  '5331DB9C240E093B');
exec insert_into_defpwd('APPLSYS',  '0F886772980B8C79');
exec insert_into_defpwd('APPLSYS',  'E153FFF4DAE6C9F7');
exec insert_into_defpwd('APPLSYSPUB',  'D2E3EF40EE87221E');
exec insert_into_defpwd('APPS',  'D728438E8A5925E0');
exec insert_into_defpwd('APS1',  'F65751C55EA079E6');
exec insert_into_defpwd('APS2',  '5CACE7B928382C8B');
exec insert_into_defpwd('APS3',  'C786695324D7FB3B');
exec insert_into_defpwd('APS4',  'F86074C4F4F82D2C');
exec insert_into_defpwd('AQDEMO',  '5140E342712061DD');
exec insert_into_defpwd('AQJAVA',  '8765D2543274B42E');
exec insert_into_defpwd('AQUSER',  '4CF13BDAC1D7511C');
exec insert_into_defpwd('AR',  'BBBFE175688DED7E');
exec insert_into_defpwd('ARA1',  '4B9F4E0667857EB8');
exec insert_into_defpwd('ARA2',  'F4E52BFBED4652CD');
exec insert_into_defpwd('ARA3',  'E3D8D73AE399F7FE');
exec insert_into_defpwd('ARA4',  '758FD31D826E9143');
exec insert_into_defpwd('ARS1',  '433263ED08C7A4FD');
exec insert_into_defpwd('ARS2',  'F3AF9F26D0213538');
exec insert_into_defpwd('ARS3',  'F6755F08CC1E7831');
exec insert_into_defpwd('ARS4',  '452B5A381CABB241');
exec insert_into_defpwd('ART',  '665168849666C4F3');
exec insert_into_defpwd('ASF',  'B6FD427D08619EEE');
exec insert_into_defpwd('ASG',  '1EF8D8BD87CF16BE');
exec insert_into_defpwd('ASL',  '03B20D2C323D0BFE');
exec insert_into_defpwd('ASN',  '1EE6AEBD9A23D4E0');
exec insert_into_defpwd('ASO',  'F712D80109E3C9D8');
exec insert_into_defpwd('ASP',  'CF95D2C6C85FF513');
exec insert_into_defpwd('AST',  'F13FF949563EAB3C');
exec insert_into_defpwd('AUC_GUEST',  '8A59D349DAEC26F7');
exec insert_into_defpwd('AURORA$ORB$UNAUTHENTICATED',  '80C099F0EADF877E');
exec insert_into_defpwd('AUTHORIA',  'CC78120E79B57093');
exec insert_into_defpwd('AX',  '0A8303530E86FCDD');
exec insert_into_defpwd('AZ',  'AAA18B5D51B0D5AC');
exec insert_into_defpwd('B2B',  'CC387B24E013C616');
exec insert_into_defpwd('BAM',  '031091A1D1A30061');
exec insert_into_defpwd('BCA1',  '398A69209360BD9D');
exec insert_into_defpwd('BCA2',  '801D9C90EBC89371');
exec insert_into_defpwd('BEN',  '9671866348E03616');
exec insert_into_defpwd('BI',  'FA1D2B85B70213F3');
exec insert_into_defpwd('BIC',  'E84CC95CBBAC1B67');
exec insert_into_defpwd('BIL',  'BF24BCE2409BE1F7');
exec insert_into_defpwd('BIM',  '6026F9A8A54B9468');
exec insert_into_defpwd('BIS',  '7E9901882E5F3565');
exec insert_into_defpwd('BIV',  '2564B34BE50C2524');
exec insert_into_defpwd('BIX',  '3DD36935EAEDE2E3');
exec insert_into_defpwd('BLAKE',  '9435F2E60569158E');
exec insert_into_defpwd('BMEADOWS',  '2882BA3D3EE1F65A');
exec insert_into_defpwd('BNE',  '080B5C7EE819BF78');
exec insert_into_defpwd('BOM',  '56DB3E89EAE5788E');
exec insert_into_defpwd('BP01',  '612D669D2833FACD');
exec insert_into_defpwd('BP02',  'FCE0C089A3ECECEE');
exec insert_into_defpwd('BP03',  '0723FFEEFBA61545');
exec insert_into_defpwd('BP04',  'E5797698E0F8934E');
exec insert_into_defpwd('BP05',  '58FFC821F778D7E9');
exec insert_into_defpwd('BP06',  '2F358909A4AA6059');
exec insert_into_defpwd('BSC',  'EC481FD7DCE6366A');
exec insert_into_defpwd('BUYACCT',  'D6B388366ECF2F61');
exec insert_into_defpwd('BUYAPPR1',  'CB04931693309228');
exec insert_into_defpwd('BUYAPPR2',  '3F98A3ADC037F49C');
exec insert_into_defpwd('BUYAPPR3',  'E65D8AD3ACC23DA3');
exec insert_into_defpwd('BUYER',  '547BDA4286A2ECAE');
exec insert_into_defpwd('BUYMTCH',  '0DA5E3B504CC7497');
exec insert_into_defpwd('CAMRON',  '4384E3F9C9C9B8F1');
exec insert_into_defpwd('CANDICE',  'CF458B3230215199');
exec insert_into_defpwd('CARL',  '99ECCC664FFDFEA2');
exec insert_into_defpwd('CARLY',  'F7D90C099F9097F1');
exec insert_into_defpwd('CARMEN',  '46E23E1FD86A4277');
exec insert_into_defpwd('CARRIECONYERS',  '9BA83B1E43A5885B');
exec insert_into_defpwd('CATADMIN',  'AF9AB905347E004F');
exec insert_into_defpwd('CE',  'E7FDFE26A524FE39');
exec insert_into_defpwd('CEASAR',  'E69833B8205D5DD7');
exec insert_into_defpwd('CENTRA',  '63BF5FFE5E3EA16D');
exec insert_into_defpwd('CFD',  '667B018D4703C739');
exec insert_into_defpwd('CHANDRA',  '184503FA7786C82D');
exec insert_into_defpwd('CHARLEY',  'E500DAA705382E8D');
exec insert_into_defpwd('CHRISBAKER',  '52AFB6B3BE485F81');
exec insert_into_defpwd('CHRISTIE',  'C08B79CCEC43E798');
exec insert_into_defpwd('CINDY',  '3AB2C717D1BD0887');
exec insert_into_defpwd('CLARK',  '74DF527800B6D713');
exec insert_into_defpwd('CLARK',  '7AAFE7D01511D73F');
exec insert_into_defpwd('CLAUDE',  'C6082BCBD0B69D20');
exec insert_into_defpwd('CLINT',  '163FF8CCB7F11691');
exec insert_into_defpwd('CLN',  'A18899D42066BFCA');
exec insert_into_defpwd('CN',  '73F284637A54777D');
exec insert_into_defpwd('CNCADMIN',  'C7C8933C678F7BF9');
exec insert_into_defpwd('CONNIE',  '982F4C420DD38307');
exec insert_into_defpwd('CONNOR',  '52875AEB74008D78');
exec insert_into_defpwd('CORY',  '93CE4CCE632ADCD2');
exec insert_into_defpwd('CRM1',  '6966EA64B0DFC44E');
exec insert_into_defpwd('CRM2',  'B041F3BEEDA87F72');
exec insert_into_defpwd('CRP',  'F165BDE5462AD557');
exec insert_into_defpwd('CRPB733',  '2C9AB93FF2999125');
exec insert_into_defpwd('CRPCTL',  '4C7A200FB33A531D');
exec insert_into_defpwd('CRPDTA',  '6665270166D613BC');
exec insert_into_defpwd('CS',  'DB78866145D4E1C3');
exec insert_into_defpwd('CSADMIN',  '94327195EF560924');
exec insert_into_defpwd('CSAPPR1',  '47D841B5A01168FF');
exec insert_into_defpwd('CSC',  'EDECA9762A8C79CD');
exec insert_into_defpwd('CSD',  '144441CEBAFC91CF');
exec insert_into_defpwd('CSDUMMY',  '7A587C459B93ACE4');
exec insert_into_defpwd('CSE',  'D8CC61E8F42537DA');
exec insert_into_defpwd('CSF',  '684E28B3C899D42C');
exec insert_into_defpwd('CSI',  '71C2B12C28B79294');
exec insert_into_defpwd('CSL',  'C4D7FE062EFB85AB');
exec insert_into_defpwd('CSM',  '94C24FC0BE22F77F');
exec insert_into_defpwd('CSMIG',  '09B4BB013FBD0D65');
exec insert_into_defpwd('CSP',  '5746C5E077719DB4');
exec insert_into_defpwd('CSR',  '0E0F7C1B1FE3FA32');
exec insert_into_defpwd('CSS',  '3C6B8C73DDC6B04F');
exec insert_into_defpwd('CTXDEMO',  'CB6B5E9D9672FE89');
exec insert_into_defpwd('CTXSYS',  '24ABAB8B06281B4C');
exec insert_into_defpwd('CTXSYS',  '71E687F036AD56E5');
exec insert_into_defpwd('CTXTEST',  '064717C317B551B6');
exec insert_into_defpwd('CUA',  'CB7B2E6FFDD7976F');
exec insert_into_defpwd('CUE',  'A219FE4CA25023AA');
exec insert_into_defpwd('CUF',  '82959A9BD2D51297');
exec insert_into_defpwd('CUG',  '21FBCADAEAFCC489');
exec insert_into_defpwd('CUI',  'AD7862E01FA80912');
exec insert_into_defpwd('CUN',  '41C2D31F3C85A79D');
exec insert_into_defpwd('CUP',  'C03082CD3B13EC42');
exec insert_into_defpwd('CUS',  '00A12CC6EBF8EDB8');
exec insert_into_defpwd('CZ',  '9B667E9C5A0D21A6');
exec insert_into_defpwd('DAVIDMORGAN',  'B717BAB262B7A070');
exec insert_into_defpwd('DBSNMP',  'E066D214D5421CCC');
exec insert_into_defpwd('DCM',  '45CCF86E1058D3A5');
exec insert_into_defpwd('DD7333',  '44886308CF32B5D4');
exec insert_into_defpwd('DD7334',  'D7511E19D9BD0F90');
exec insert_into_defpwd('DD810',  '0F9473D8D8105590');
exec insert_into_defpwd('DD811',  'D8084AE609C9A2FD');
exec insert_into_defpwd('DD812',  'AB71915CF21E849E');
exec insert_into_defpwd('DD9',  'E81821D03070818C');
exec insert_into_defpwd('DDB733',  '7D11619CEE99DE12');
exec insert_into_defpwd('DDD',  '6CB03AF4F6DD133D');
exec insert_into_defpwd('DEMO8',  '0E7260738FDFD678');
exec insert_into_defpwd('DES',  'ABFEC5AC2274E54D');
exec insert_into_defpwd('DES2K',  '611E7A73EC4B425A');
exec insert_into_defpwd('DEV2000_DEMOS',  '18A0C8BD6B13BEE2');
exec insert_into_defpwd('DEVB733',  '7500DF89DC99C057');
exec insert_into_defpwd('DEVUSER',  'C10B4A80D00CA7A5');
exec insert_into_defpwd('DGRAY',  '5B76A1EB8F212B85');
exec insert_into_defpwd('DIP',  'CE4A36B8E06CA59C');
exec insert_into_defpwd('DISCOVERER5',  'AF0EDB66D914B731');
exec insert_into_defpwd('DKING',  '255C2B0E1F0912EA');
exec insert_into_defpwd('DLD',  '4454B932A1E0E320');
exec insert_into_defpwd('DMADMIN',  'E6681A8926B40826');
exec insert_into_defpwd('DMATS',  '8C692701A4531286');
exec insert_into_defpwd('DMS',  '1351DC7ED400BD59');
exec insert_into_defpwd('DMSYS',  'BFBA5A553FD9E28A');
exec insert_into_defpwd('DOM',  '51C9F2BECA78AE0E');
exec insert_into_defpwd('DPOND',  '79D6A52960EEC216');
exec insert_into_defpwd('DSGATEWAY',  '6869F3CFD027983A');
exec insert_into_defpwd('DV7333',  '36AFA5CD674BA841');
exec insert_into_defpwd('DV7334',  '473B568021BDB428');
exec insert_into_defpwd('DV810',  '52C38F48C99A0352');
exec insert_into_defpwd('DV811',  'B6DC5AAB55ECB66C');
exec insert_into_defpwd('DV812',  '7359E6E060B945BA');
exec insert_into_defpwd('DV9',  '07A1D03FD26E5820');
exec insert_into_defpwd('DVP1',  '0559A0D3DE0759A6');
exec insert_into_defpwd('EAA',  'A410B2C5A0958CDF');
exec insert_into_defpwd('EAM',  'CE8234D92FCFB563');
exec insert_into_defpwd('EC',  '6A066C462B62DD46');
exec insert_into_defpwd('ECX',  '0A30645183812087');
exec insert_into_defpwd('EDR',  '5FEC29516474BB3A');
exec insert_into_defpwd('EDWEUL_US',  '5922BA2E72C49787');
exec insert_into_defpwd('EDWREP',  '79372B4AB748501F');
exec insert_into_defpwd('EGC1',  'D78E0F2BE306450D');
exec insert_into_defpwd('EGD1',  'DA6D6F2089885BA6');
exec insert_into_defpwd('EGM1',  'FB949D5E4B5255C0');
exec insert_into_defpwd('EGO',  'B9D919E5F5A9DA71');
exec insert_into_defpwd('EGR1',  'BB636336ADC5824A');
exec insert_into_defpwd('END1',  '688499930C210B75');
exec insert_into_defpwd('ENG',  '4553A3B443FB3207');
exec insert_into_defpwd('ENI',  '05A92C0958AFBCBC');
exec insert_into_defpwd('ENM1',  '3BDABFD1246BFEA2');
exec insert_into_defpwd('ENS1',  'F68A5D0D6D2BB25B');
exec insert_into_defpwd('ENTMGR_CUST',  '45812601EAA2B8BD');
exec insert_into_defpwd('ENTMGR_PRO',  '20002682991470B3');
exec insert_into_defpwd('ENTMGR_TRAIN',  'BE40A3BE306DD857');
exec insert_into_defpwd('EOPP_PORTALADM',  'B60557FD8C45005A');
exec insert_into_defpwd('EOPP_PORTALMGR',  '9BB3CF93F7DE25F1');
exec insert_into_defpwd('EOPP_USER',  '13709991FC4800A1');
exec insert_into_defpwd('EUL_US',  '28AEC22561414B29');
exec insert_into_defpwd('EVM',  '137CEDC20DE69F71');
exec insert_into_defpwd('EXA1',  '091BCD95EE112EE3');
exec insert_into_defpwd('EXA2',  'E4C0A21DBD06B890');
exec insert_into_defpwd('EXA3',  '40DC4FA801A73560');
exec insert_into_defpwd('EXA4',  '953885D52BDF5C86');
exec insert_into_defpwd('EXFSYS',  '66F4EF5650C20355');
exec insert_into_defpwd('EXS1',  'C5572BAB195817F0');
exec insert_into_defpwd('EXS2',  '8FAA3AC645793562');
exec insert_into_defpwd('EXS3',  'E3050174EE1844BA');
exec insert_into_defpwd('EXS4',  'E963BFE157475F7D');
exec insert_into_defpwd('FA',  '21A837D0AED8F8E5');
exec insert_into_defpwd('FEM',  'BD63D79ADF5262E7');
exec insert_into_defpwd('FIA1',  '2EB76E07D3E094EC');
exec insert_into_defpwd('FII',  'CF39DE29C08F71B9');
exec insert_into_defpwd('FLM',  'CEE2C4B59E7567A3');
exec insert_into_defpwd('FLOWS_030000',  'FA1D2B85B70213F3');
exec insert_into_defpwd('FLOWS_FILES',  '0CE415AC5D50F7A1');
exec insert_into_defpwd('FNI1',  '308839029D04F80C');
exec insert_into_defpwd('FNI2',  '05C69C8FEAB4F0B9');
exec insert_into_defpwd('FPA',  '9FD6074B9FD3754C');
exec insert_into_defpwd('FPT',  '73E3EC9C0D1FAECF');
exec insert_into_defpwd('FRM',  '9A2A7E2EBE6E4F71');
exec insert_into_defpwd('FTA1',  '65FF9AB3A49E8A13');
exec insert_into_defpwd('FTE',  '2FB4D2C9BAE2CCCA');
exec insert_into_defpwd('FUN',  '8A7055CA462DB219');
exec insert_into_defpwd('FV',  '907D70C0891A85B1');
exec insert_into_defpwd('FVP1',  '6CC7825EADF994E8');
exec insert_into_defpwd('GALLEN',  'F8E8ED9F15842428');
exec insert_into_defpwd('GCA1',  '47DA9864E018539B');
exec insert_into_defpwd('GCA2',  'FD6E06F7DD50E868');
exec insert_into_defpwd('GCA3',  '4A4B9C2E9624C410');
exec insert_into_defpwd('GCA9',  '48A7205A4C52D6B5');
exec insert_into_defpwd('GCMGR1',  '14A1C1A08EA915D6');
exec insert_into_defpwd('GCMGR2',  'F4F11339A4221A4D');
exec insert_into_defpwd('GCMGR3',  '320F0D4258B9D190');
exec insert_into_defpwd('GCS',  '7AE34CA7F597EBF7');
exec insert_into_defpwd('GCS1',  '2AE8E84D2400E61D');
exec insert_into_defpwd('GCS2',  'C242D2B83162FF3D');
exec insert_into_defpwd('GCS3',  'DCCB4B49C68D77E2');
exec insert_into_defpwd('GEORGIAWINE',  'F05B1C50A1C926DE');
exec insert_into_defpwd('GL',  'CD6E99DACE4EA3A6');
exec insert_into_defpwd('GLA1',  '86C88007729EB36F');
exec insert_into_defpwd('GLA2',  '807622529F170C02');
exec insert_into_defpwd('GLA3',  '863A20A4EFF7386B');
exec insert_into_defpwd('GLA4',  'DB882CF89A758377');
exec insert_into_defpwd('GLS1',  '7485C6BD564E75D1');
exec insert_into_defpwd('GLS2',  '319E08C55B04C672');
exec insert_into_defpwd('GLS3',  'A7699C43BB136229');
exec insert_into_defpwd('GLS4',  '7C171E6980BE2DB9');
exec insert_into_defpwd('GM_AWDA',  '4A06A107E7A3BB10');
exec insert_into_defpwd('GM_COPI',  '03929AE296BAAFF2');
exec insert_into_defpwd('GM_DPHD',  '0519252EDF68FA86');
exec insert_into_defpwd('GM_MLCT',  '24E8B569E8D1E93E');
exec insert_into_defpwd('GM_PLADMA',  '2946218A27B554D8');
exec insert_into_defpwd('GM_PLADMH',  '2F6EDE96313AF1B7');
exec insert_into_defpwd('GM_PLCCA',  '7A99244B545A038D');
exec insert_into_defpwd('GM_PLCCH',  '770D9045741499E6');
exec insert_into_defpwd('GM_PLCOMA',  '91524D7DE2B789A8');
exec insert_into_defpwd('GM_PLCOMH',  'FC1C6E0864BF0AF2');
exec insert_into_defpwd('GM_PLCONA',  '1F531397B19B1E05');
exec insert_into_defpwd('GM_PLCONH',  'C5FE216EB8FCD023');
exec insert_into_defpwd('GM_PLNSCA',  'DB9DD2361D011A30');
exec insert_into_defpwd('GM_PLNSCH',  'C80D557351110D51');
exec insert_into_defpwd('GM_PLSCTA',  '3A778986229BA20C');
exec insert_into_defpwd('GM_PLSCTH',  '9E50865473B63347');
exec insert_into_defpwd('GM_PLVET',  '674885FDB93D34B9');
exec insert_into_defpwd('GM_SPO',  'E57D4BD77DAF92F0');
exec insert_into_defpwd('GM_STKH',  'C498A86BE2663899');
exec insert_into_defpwd('GMA',  'DC7948E807DFE242');
exec insert_into_defpwd('GMD',  'E269165256F22F01');
exec insert_into_defpwd('GME',  'B2F0E221F45A228F');
exec insert_into_defpwd('GMF',  'A07F1956E3E468E1');
exec insert_into_defpwd('GMI',  '82542940B0CF9C16');
exec insert_into_defpwd('GML',  '5F1869AD455BBA73');
exec insert_into_defpwd('GMP',  '450793ACFCC7B58E');
exec insert_into_defpwd('GMS',  'E654261035504804');
exec insert_into_defpwd('GR',  'F5AB0AA3197AEE42');
exec insert_into_defpwd('GUEST',  '1C0A090E404CECD0');
exec insert_into_defpwd('HCC',  '25A25A7FEFAC17B6');
exec insert_into_defpwd('HHCFO',  '62DF37933FB35E9F');
exec insert_into_defpwd('HR',  '4C6D73C3E8B0F0DA');
exec insert_into_defpwd('HRI',  '49A3A09B8FC291D0');
exec insert_into_defpwd('HXC',  '4CEA0BF02214DA55');
exec insert_into_defpwd('HXT',  '169018EB8E2C4A77');
exec insert_into_defpwd('IA',  '42C7EAFBCEEC09CC');
exec insert_into_defpwd('IBA',  '0BD475D5BF449C63');
exec insert_into_defpwd('IBC',  '9FB08604A30A4951');
exec insert_into_defpwd('IBE',  '9D41D2B3DD095227');
exec insert_into_defpwd('IBP',  '840267B7BD30C82E');
exec insert_into_defpwd('IBU',  '0AD9ABABC74B3057');
exec insert_into_defpwd('IBY',  'F483A48F6A8C51EC');
exec insert_into_defpwd('ICX',  '7766E887AF4DCC46');
exec insert_into_defpwd('IEB',  'A695699F0F71C300');
exec insert_into_defpwd('IEC',  'CA39F929AF0A2DEC');
exec insert_into_defpwd('IEM',  '37EF7B2DD17279B5');
exec insert_into_defpwd('IEO',  'E93196E9196653F1');
exec insert_into_defpwd('IES',  '30802533ADACFE14');
exec insert_into_defpwd('IEU',  '5D0E790B9E882230');
exec insert_into_defpwd('IEX',  '6CC978F56D21258D');
exec insert_into_defpwd('IGC',  'D33CEB8277F25346');
exec insert_into_defpwd('IGF',  '1740079EFF46AB81');
exec insert_into_defpwd('IGI',  '8C69D50E9D92B9D0');
exec insert_into_defpwd('IGS',  'DAF602231281B5AC');
exec insert_into_defpwd('IGW',  'B39565F4E3CF744B');
exec insert_into_defpwd('IMC',  'C7D0B9CDE0B42C73');
exec insert_into_defpwd('IMT',  'E4AAF998653C9A72');
exec insert_into_defpwd('INS1',  '2ADC32A0B154F897');
exec insert_into_defpwd('INS2',  'EA372A684B790E2A');
exec insert_into_defpwd('INTERNET_APPSERVER_REGISTRY',  'A1F98A977FFD73CD');
exec insert_into_defpwd('INV',  'ACEAB015589CF4BC');
exec insert_into_defpwd('IP',  'D29012C144B58A40');
exec insert_into_defpwd('IPA',  'EB265A08759A15B4');
exec insert_into_defpwd('IPD',  '066A2E3072C1F2F3');
exec insert_into_defpwd('ISC',  '373F527DC0CFAE98');
exec insert_into_defpwd('ISTEWARD',  '8735CA4085DE3EEA');
exec insert_into_defpwd('ITG',  'D90F98746B68E6CA');
exec insert_into_defpwd('IX',  '2BE6F80744E08FEB');
exec insert_into_defpwd('JA',  '9AC2B58153C23F3D');
exec insert_into_defpwd('JD7333',  'FB5B8A12AE623D52');
exec insert_into_defpwd('JD7334',  '322810FCE43285D9');
exec insert_into_defpwd('JD9',  '9BFAEC92526D027B');
exec insert_into_defpwd('JDE',  '7566DC952E73E869');
exec insert_into_defpwd('JDEDBA',  'B239DD5313303B1D');
exec insert_into_defpwd('JE',  'FBB3209FD6280E69');
exec insert_into_defpwd('JG',  '37A99698752A1CF1');
exec insert_into_defpwd('JL',  '489B61E488094A8D');
exec insert_into_defpwd('JOHNINARI',  'B3AD4DA00F9120CE');
exec insert_into_defpwd('JONES',  'B9E99443032F059D');
exec insert_into_defpwd('JTF',  '5C5F6FC2EBB94124');
exec insert_into_defpwd('JTI',  'B8F03D3E72C96F71');
exec insert_into_defpwd('JTM',  '6D79A2259D5B4B5A');
exec insert_into_defpwd('JTR',  'B4E2BE38B556048F');
exec insert_into_defpwd('JTS',  '4087EE6EB7F9CD7C');
exec insert_into_defpwd('JUNK_PS',  'BBC38DB05D2D3A7A');
exec insert_into_defpwd('JUSTOSHUM',  '53369CD63902FAAA');
exec insert_into_defpwd('KELLYJONES',  'DD4A3FF809D2A6CF');
exec insert_into_defpwd('KEVINDONS',  '7C6D9540B45BBC39');
exec insert_into_defpwd('KPN',  'DF0AED05DE318728');
exec insert_into_defpwd('LADAMS',  'AE542B99505CDCD2');
exec insert_into_defpwd('LBA',  '18E5E15A436E7157');
exec insert_into_defpwd('LBACSYS',  'AC9700FD3F1410EB');
exec insert_into_defpwd('LDQUAL',  '1274872AB40D4FCD');
exec insert_into_defpwd('LHILL',  'E70CA2CA0ED555F5');
exec insert_into_defpwd('LNS',  'F8D2BC61C10941B2');
exec insert_into_defpwd('LQUINCY',  '13F9B9C1372A41B6');
exec insert_into_defpwd('LSA',  '2D5E6036E3127B7E');
exec insert_into_defpwd('MDDATA',  'DF02A496267DEE66');
exec insert_into_defpwd('MDSYS',  '72979A94BAD2AF80');
exec insert_into_defpwd('MDSYS',  '9AAEB2214DCC9A31');
exec insert_into_defpwd('ME',  'E5436F7169B29E4D');
exec insert_into_defpwd('MFG',  'FC1B0DD35E790847');
exec insert_into_defpwd('MGR1',  'E013305AB0185A97');
exec insert_into_defpwd('MGR2',  '5ADE358F8ACE73E8');
exec insert_into_defpwd('MGR3',  '05C365C883F1251A');
exec insert_into_defpwd('MGR4',  'E229E942E8542565');
exec insert_into_defpwd('MGMT_VIEW',  '5D5BC23A318B6F53');
exec insert_into_defpwd('MIKEIKEGAMI',  'AAF7A168C83D5C47');
exec insert_into_defpwd('MJONES',  'EE7BB3FEA50A21C5');
exec insert_into_defpwd('MLAKE',  '7EC40274AC1609CA');
exec insert_into_defpwd('MM1',  '4418294570E152E7');
exec insert_into_defpwd('MM2',  'C06B5B28222E1E62');
exec insert_into_defpwd('MM3',  'A975B1BD0C093DA3');
exec insert_into_defpwd('MM4',  '88256901EB03A012');
exec insert_into_defpwd('MM5',  '4CEA62CBE776DCEC');
exec insert_into_defpwd('MMARTIN',  'D52F60115FE87AA4');
exec insert_into_defpwd('MOBILEADMIN',  '253922686A4A45CC');
exec insert_into_defpwd('MRP',  'B45D4DF02D4E0C85');
exec insert_into_defpwd('MSC',  '89A8C104725367B2');
exec insert_into_defpwd('MSD',  '6A29482069E23675');
exec insert_into_defpwd('MSO',  '3BAA3289DB35813C');
exec insert_into_defpwd('MSR',  'C9D53D00FE77D813');
exec insert_into_defpwd('MST',  'A96D2408F62BE1BC');
exec insert_into_defpwd('MWA',  '1E2F06BE2A1D41A6');
exec insert_into_defpwd('NEILKATSU',  '1F625BB9FEBC7617');
exec insert_into_defpwd('OBJ7333',  'D7BDC9748AFEDB52');
exec insert_into_defpwd('OBJ7334',  'EB6C5E9DB4643CAC');
exec insert_into_defpwd('OBJB733',  '61737A9F7D54EF5F');
exec insert_into_defpwd('OCA',  '9BC450E4C6569492');
exec insert_into_defpwd('ODM',  'C252E8FA117AF049');
exec insert_into_defpwd('ODM_MTR',  'A7A32CD03D3CE8D5');
exec insert_into_defpwd('ODS',  '89804494ADFC71BC');
exec insert_into_defpwd('ODSCOMMON',  '59BBED977430C1A8');
exec insert_into_defpwd('OE',  'D1A2DFC623FDA40A');
exec insert_into_defpwd('OKB',  'A01A5F0698FC9E31');
exec insert_into_defpwd('OKC',  '31C1DDF4D5D63FE6');
exec insert_into_defpwd('OKE',  'B7C1BB95646C16FE');
exec insert_into_defpwd('OKI',  '991C817E5FD0F35A');
exec insert_into_defpwd('OKL',  'DE058868E3D2B966');
exec insert_into_defpwd('OKO',  '6E204632EC7CA65D');
exec insert_into_defpwd('OKR',  'BB0E28666845FCDC');
exec insert_into_defpwd('OKS',  'C2B4C76AB8257DF5');
exec insert_into_defpwd('OKX',  'F9FDEB0DE52F5D6B');
exec insert_into_defpwd('OL810',  'E2DA59561CBD0296');
exec insert_into_defpwd('OL811',  'B3E88767A01403F8');
exec insert_into_defpwd('OL812',  'AE8C7989346785BA');
exec insert_into_defpwd('OL9',  '17EC83E44FB7DB5B');
exec insert_into_defpwd('OLAPSYS',  '3FB8EF9DB538647C');
exec insert_into_defpwd('ONT',  '9E3C81574654100A');
exec insert_into_defpwd('OPI',  '1BF23812A0AEEDA0');
exec insert_into_defpwd('ORABAM',  'D0A4EA93EF21CE25');
exec insert_into_defpwd('ORABAMSAMPLES',  '507F11063496F222');
exec insert_into_defpwd('ORABPEL',  '26EFDE0C9C051988');
exec insert_into_defpwd('ORACLE_OCM',  '6D17CF1EB1611F94');
exec insert_into_defpwd('ORAESB',  'CC7FCCB3A1719EDA');
exec insert_into_defpwd('ORAOCA_PUBLIC',  'FA99021634DDC111');
exec insert_into_defpwd('ORASAGENT',  '234B6F4505AD8F25');
exec insert_into_defpwd('ORASSO',  'F3701A008AA578CF');
exec insert_into_defpwd('ORASSO_DS',  '17DC8E02BC75C141');
exec insert_into_defpwd('ORASSO_PA',  '133F8D161296CB8F');
exec insert_into_defpwd('ORASSO_PS',  '63BB534256053305');
exec insert_into_defpwd('ORASSO_PUBLIC',  'C6EED68A8F75F5D3');
exec insert_into_defpwd('ORDPLUGINS',  '88A2B2C183431F00');
exec insert_into_defpwd('ORDSYS',  '7EFA02EC7EA6B86F');
exec insert_into_defpwd('OSM',  '106AE118841A5D8C');
exec insert_into_defpwd('OTA',  'F5E498AC7009A217');
exec insert_into_defpwd('OUTLN',  '4A3BA55E08595C81');
exec insert_into_defpwd('OWAPUB',  '6696361B64F9E0A9');
exec insert_into_defpwd('OWBSYS',  '610A3C38F301776F');
exec insert_into_defpwd('OWF_MGR',  '3CBED37697EB01D1');
exec insert_into_defpwd('OZF',  '970B962D942D0C75');
exec insert_into_defpwd('OZP',  'B650B1BB35E86863');
exec insert_into_defpwd('OZS',  '0DABFF67E0D33623');
exec insert_into_defpwd('PA',  '8CE2703752DB36D8');
exec insert_into_defpwd('PABLO',  '5E309CB43FE2C2FF');
exec insert_into_defpwd('PAIGE',  '02B6B704DFDCE620');
exec insert_into_defpwd('PAM',  '1383324A0068757C');
exec insert_into_defpwd('PARRISH',  '79193FDACFCE46F6');
exec insert_into_defpwd('PARSON',  'AE28B2BD64720CD7');
exec insert_into_defpwd('PAT',  'DD20769D59F4F7BF');
exec insert_into_defpwd('PATORILY',  '46B7664BD15859F9');
exec insert_into_defpwd('PATRICKSANCHEZ',  '47F74BD3AD4B5F0A');
exec insert_into_defpwd('PATSY',  '4A63F91FEC7980B7');
exec insert_into_defpwd('PAUL',  '35EC0362643ADD3F');
exec insert_into_defpwd('PAULA',  'BB0DC58A94C17805');
exec insert_into_defpwd('PAXTON',  '4EB5D8FAD3434CCC');
exec insert_into_defpwd('PCA1',  '8B2E303DEEEEA0C0');
exec insert_into_defpwd('PCA2',  '7AD6CE22462A5781');
exec insert_into_defpwd('PCA3',  'B8194D12FD4F537D');
exec insert_into_defpwd('PCA4',  '83AD05F1D0B0C603');
exec insert_into_defpwd('PCS1',  '2BE6DD3D1DEA4A16');
exec insert_into_defpwd('PCS2',  '78117145145592B1');
exec insert_into_defpwd('PCS3',  'F48449F028A065B1');
exec insert_into_defpwd('PCS4',  'E1385509C0B16BED');
exec insert_into_defpwd('PD7333',  '5FFAD8604D9DC00F');
exec insert_into_defpwd('PD7334',  'CDCF262B5EE254E1');
exec insert_into_defpwd('PD810',  'EB04A177A74C6BCB');
exec insert_into_defpwd('PD811',  '3B3C0EFA4F20AC37');
exec insert_into_defpwd('PD812',  'E73A81DB32776026');
exec insert_into_defpwd('PD9',  'CACEB3F9EA16B9B7');
exec insert_into_defpwd('PDA1',  'C7703B70B573D20F');
exec insert_into_defpwd('PEARL',  'E0AFD95B9EBD0261');
exec insert_into_defpwd('PEG',  '20577ED9A8DB8D22');
exec insert_into_defpwd('PENNY',  'BB6103E073D7B811');
exec insert_into_defpwd('PEOPLE',  '613459773123B38A');
exec insert_into_defpwd('PERCY',  'EB9E8B33A2DDFD11');
exec insert_into_defpwd('PERRY',  'D62B14B93EE176B6');
exec insert_into_defpwd('PETE',  '4040619819A9C76E');
exec insert_into_defpwd('PEYTON',  'B7127140004677FC');
exec insert_into_defpwd('PHIL',  '181446AE258EE2F6');
exec insert_into_defpwd('PJI',  '5024B1B412CD4AB9');
exec insert_into_defpwd('PJM',  '021B05DBB892D11F');
exec insert_into_defpwd('PM',  '72E382A52E8955A');
exec insert_into_defpwd('PMI',  'A7F7978B21A6F65E');
exec insert_into_defpwd('PN',  'D40D0FEF9C8DC624');
exec insert_into_defpwd('PO',  '355CBEC355C10FEF');
exec insert_into_defpwd('POA',  '2AB40F104D8517A0');
exec insert_into_defpwd('POLLY',  'ABC770C112D23DBE');
exec insert_into_defpwd('POM',  '123CF56E05D4EF3C');
exec insert_into_defpwd('PON',  '582090FD3CC44DA3');
exec insert_into_defpwd('PORTAL',  'A96255A27EC33614');
exec insert_into_defpwd('PORTAL_APP',  '831A79AFB0BD29EC');
exec insert_into_defpwd('PORTAL_DEMO',  'A0A3A6A577A931A3');
exec insert_into_defpwd('PORTAL_PUBLIC',  '70A9169655669CE8');
exec insert_into_defpwd('PORTAL30',  '969F9C3839672C6D');
exec insert_into_defpwd('PORTAL30_DEMO',  'CFD1302A7F832068');
exec insert_into_defpwd('PORTAL30_PUBLIC',  '42068201613CA6E2');
exec insert_into_defpwd('PORTAL30_SSO',  '882B80B587FCDBC8');
exec insert_into_defpwd('PORTAL30_SSO_PS',  'F2C3DC8003BC90F8');
exec insert_into_defpwd('PORTAL30_SSO_PUBLIC',  '98741BDA2AC7FFB2');
exec insert_into_defpwd('POS',  '6F6675F272217CF7');
exec insert_into_defpwd('PPM1',  'AA4AE24987D0E84B');
exec insert_into_defpwd('PPM2',  '4023F995FF78077C');
exec insert_into_defpwd('PPM3',  '12F56FADDA87BBF9');
exec insert_into_defpwd('PPM4',  '84E17CB7A3B0E769');
exec insert_into_defpwd('PPM5',  '804C159C660F902C');
exec insert_into_defpwd('PRISTB733',  '1D1BCF8E03151EF5');
exec insert_into_defpwd('PRISTCTL',  '78562A983A2F78FB');
exec insert_into_defpwd('PRISTDTA',  '3FCBC379C8FE079C');
exec insert_into_defpwd('PRODB733',  '9CCD49EB30CB80C4');
exec insert_into_defpwd('PRODCTL',  'E5DE2F01529AE93C');
exec insert_into_defpwd('PRODDTA',  '2A97CD2281B256BA');
exec insert_into_defpwd('PRODUSER',  '752E503EFBF2C2CA');
exec insert_into_defpwd('PROJMFG',  '34D61E5C9BC7147E');
exec insert_into_defpwd('PRP',  'C1C4328F8862BC16');
exec insert_into_defpwd('PS',  '0AE52ADF439D30BD');
exec insert_into_defpwd('PS810',  '90C0BEC7CA10777E');
exec insert_into_defpwd('PS810CTL',  'D32CCE5BDCD8B9F9');
exec insert_into_defpwd('PS810DTA',  'AC0B7353A58FC778');
exec insert_into_defpwd('PS811',  'B5A174184403822F');
exec insert_into_defpwd('PS811CTL',  '18EDE0C5CCAE4C5A');
exec insert_into_defpwd('PS811DTA',  '7961547C7FB96920');
exec insert_into_defpwd('PS812',  '39F0304F007D92C8');
exec insert_into_defpwd('PS812CTL',  'E39B1CE3456ECBE5');
exec insert_into_defpwd('PS812DTA',  '3780281C933FE164');
exec insert_into_defpwd('PSA',  'FF4B266F9E61F911');
exec insert_into_defpwd('PSB',  '28EE1E024FC55E66');
exec insert_into_defpwd('PSBASS',  'F739804B718D4406');
exec insert_into_defpwd('PSEM',  '40ACD8C0F1466A57');
exec insert_into_defpwd('PSFT',  '7B07F6F3EC08E30D');
exec insert_into_defpwd('PSFTDBA',  'E1ECD83073C4E134');
exec insert_into_defpwd('PSP',  '4FE07360D435E2F0');
exec insert_into_defpwd('PTADMIN',  '4C35813E45705EBA');
exec insert_into_defpwd('PTCNE',  '463AEFECBA55BEE8');
exec insert_into_defpwd('PTDMO',  '251D71390034576A');
exec insert_into_defpwd('PTE',  '380FDDB696F0F266');
exec insert_into_defpwd('PTESP',  '5553404C13601916');
exec insert_into_defpwd('PTFRA',  'A360DAD317F583E3');
exec insert_into_defpwd('PTG',  '7AB0D62E485C9A3D');
exec insert_into_defpwd('PTGER',  'C8D1296B4DF96518');
exec insert_into_defpwd('PTJPN',  '2159C2EAF20011BF');
exec insert_into_defpwd('PTUKE',  'D0EF510BCB2992A3');
exec insert_into_defpwd('PTUPG',  '2C27080C7CC57D06');
exec insert_into_defpwd('PTWEB',  '8F7F509D4DC01DF6');
exec insert_into_defpwd('PTWEBSERVER',  '3C8050536003278B');
exec insert_into_defpwd('PV',  '76224BCC80895D3D');
exec insert_into_defpwd('PY7333',  '2A9C53FE066B852F');
exec insert_into_defpwd('PY7334',  'F3BBFAE0DDC5F7AC');
exec insert_into_defpwd('PY810',  '95082D35E94B88C2');
exec insert_into_defpwd('PY811',  'DC548D6438E4D6B7');
exec insert_into_defpwd('PY812',  '99C575A55E9FDA63');
exec insert_into_defpwd('PY9',  'B8D4E503D0C4FCFD');
exec insert_into_defpwd('QA',  'C7AEAA2D59EB1EAE');
exec insert_into_defpwd('QOT',  'B27D0E5BA4DC8DEA');
exec insert_into_defpwd('QP',  '10A40A72991DCA15');
exec insert_into_defpwd('QRM',  '098286E4200B22DE');
exec insert_into_defpwd('QS',  '4603BCD2744BDE4F');
exec insert_into_defpwd('QS_ADM',  '3990FB418162F2A0');
exec insert_into_defpwd('QS_CB',  '870C36D8E6CD7CF5');
exec insert_into_defpwd('QS_CBADM',  '20E788F9D4F1D92C');
exec insert_into_defpwd('QS_CS',  '2CA6D0FC25128CF3');
exec insert_into_defpwd('QS_ES',  '9A5F2D9F5D1A9EF4');
exec insert_into_defpwd('QS_OS',  '0EF5997DC2638A61');
exec insert_into_defpwd('QS_WS',  '0447F2F756B4F460');
exec insert_into_defpwd('RENE',  '9AAD141AB0954CF0');
exec insert_into_defpwd('REPADMIN',  '915C93F34954F5F8');
exec insert_into_defpwd('REPORTS',  '0D9D14FE6653CF69');
exec insert_into_defpwd('REPORTS_USER',  '635074B4416CD3AC');
exec insert_into_defpwd('RESTRICTED_US',  'E7E67B60CFAFBB2D');
exec insert_into_defpwd('RG',  '0FAA06DA0F42F21F');
exec insert_into_defpwd('RHX',  'FFDF6A0C8C96E676');
exec insert_into_defpwd('RLA',  'C1959B03F36C9BB2');
exec insert_into_defpwd('RLM',  '4B16ACDA351B557D');
exec insert_into_defpwd('RM1',  'CD43500DAB99F447');
exec insert_into_defpwd('RM2',  '2D8EE7F8857D477E');
exec insert_into_defpwd('RM3',  '1A95960A95AC2E1D');
exec insert_into_defpwd('RM4',  '651BFD4E1DE4B040');
exec insert_into_defpwd('RM5',  'FDCC34D74A22517C');
exec insert_into_defpwd('RMAN',  'E7B5D92911C831E1');
exec insert_into_defpwd('ROB',  '94405F516486CA24');
exec insert_into_defpwd('RPARKER',  'CEBFE4C41BBCC306');
exec insert_into_defpwd('RWA1',  'B07E53895E37DBBB');
exec insert_into_defpwd('SALLYH',  '21457C94616F5716');
exec insert_into_defpwd('SAM',  '4B95138CB6A4DB94');
exec insert_into_defpwd('SARAHMANDY',  '60BE21D8711EE7D9');
exec insert_into_defpwd('SCM1',  '507306749131B393');
exec insert_into_defpwd('SCM2',  'CBE8D6FAC7821E85');
exec insert_into_defpwd('SCM3',  '2B311B9CDC70F056');
exec insert_into_defpwd('SCM4',  '1FDF372790D5A016');
exec insert_into_defpwd('SCOTT',  'F894844C34402B67');
exec insert_into_defpwd('SDAVIS',  'A9A3B88C6A550559');
exec insert_into_defpwd('SECDEMO',  '009BBE8142502E10');
exec insert_into_defpwd('SEDWARDS',  '00A2EDFD7835BC43');
exec insert_into_defpwd('SELLCM',  '8318F67F72276445');
exec insert_into_defpwd('SELLER',  'B7F439E172D5C3D0');
exec insert_into_defpwd('SELLTREAS',  '6EE7BA85E9F84560');
exec insert_into_defpwd('SERVICES',  'B2BE254B514118A5');
exec insert_into_defpwd('SETUP',  '9EA55682C163B9A3');
exec insert_into_defpwd('SH',  '54B253CBBAAA8C48');
exec insert_into_defpwd('SI_INFORMTN_SCHEMA',  '84B8CBCA4D477FA3');
exec insert_into_defpwd('SID',  'CFA11E6EBA79D33E');
exec insert_into_defpwd('SKAYE',  'ED671B63BDDB6B50');
exec insert_into_defpwd('SKYTETSUKA',  'EB5DA777D1F756EC');
exec insert_into_defpwd('SLSAA',  '99064FC6A2E4BBE8');
exec insert_into_defpwd('SLSMGR',  '0ED44093917BE294');
exec insert_into_defpwd('SLSREP',  '847B6AAB9471B0A5');
exec insert_into_defpwd('SPATIAL_CSW_ADMIN_USR',  '1B290858DD14107E');
exec insert_into_defpwd('SPATIAL_WFS_ADMIN_USR',  '7117215D6BEE6E82');
exec insert_into_defpwd('SRABBITT',  '85F734E71E391DF5');
exec insert_into_defpwd('SRALPHS',  '975601AA57CBD61A');
exec insert_into_defpwd('SRAY',  'C233B26CFC5DC643');
exec insert_into_defpwd('SRIVERS',  '95FE94ADC2B39E08');
exec insert_into_defpwd('SSA1',  'DEE6E1BEB962AA8B');
exec insert_into_defpwd('SSA2',  '96CA278B20579E34');
exec insert_into_defpwd('SSA3',  'C3E8C3B002690CD4');
exec insert_into_defpwd('SSC1',  '4F7AC652CC728980');
exec insert_into_defpwd('SSC2',  'A1350B328E74AE87');
exec insert_into_defpwd('SSC3',  'EE3906EC2DA586D8');
exec insert_into_defpwd('SSOSDK',  '7C48B6FF3D54D006');
exec insert_into_defpwd('SSP',  '87470D6CE203FB4D');
exec insert_into_defpwd('SSS1',  'E78C515C31E83848');
exec insert_into_defpwd('SUPPLIER',  '2B45928C2FE77279');
exec insert_into_defpwd('SVM7333',  '04B731B0EE953972');
exec insert_into_defpwd('SVM7334',  '62E2A2E886945CC8');
exec insert_into_defpwd('SVM810',  '0A3DCD8CA3B6ABD9');
exec insert_into_defpwd('SVM811',  '2B0CD57B1091C936');
exec insert_into_defpwd('SVM812',  '778632974E3947C9');
exec insert_into_defpwd('SVM9',  '552A60D8F84441F1');
exec insert_into_defpwd('SVMB733',  'DD2BFB14346146FE');
exec insert_into_defpwd('SVP1',  'F7BF1FFECE27A834');
exec insert_into_defpwd('SY810',  'D56934CED7019318');
exec insert_into_defpwd('SY811',  '2FDC83B401477628');
exec insert_into_defpwd('SY812',  '812B8D7211E7DEF1');
exec insert_into_defpwd('SY9',  '3991E64C4BC2EC5D');
exec insert_into_defpwd('SYS',  '43CA255A7916ECFE');
exec insert_into_defpwd('SYS',  '5638228DAF52805F');
exec insert_into_defpwd('SYS',  'D4C5016086B2DC6A');
exec insert_into_defpwd('SYS7333',  'D7CDB3124F91351E');
exec insert_into_defpwd('SYS7334',  '06959F7C9850F1E3');
exec insert_into_defpwd('SYSADMIN',  'DC86E8DEAA619C1A');
exec insert_into_defpwd('SYSB733',  '7A7F5C90BEC02F0E');
exec insert_into_defpwd('SYSMAN',  'EB258E708132DD2D');
exec insert_into_defpwd('SYSTEM',  '4D27CA6E3E3066E6');
exec insert_into_defpwd('SYSTEM',  'D4DF7931AB130E37');
exec insert_into_defpwd('TDEMARCO',  'CAB71A14FA426FAE');
exec insert_into_defpwd('TDOS_ICSAP',  '7C0900F751723768');
exec insert_into_defpwd('TESTCTL',  '205FA8DF03A1B0A6');
exec insert_into_defpwd('TESTDTA',  'EEAF97B5F20A3FA3');
exec insert_into_defpwd('TRA1',  'BE8EDAE6464BA413');
exec insert_into_defpwd('TRACESVR',  'F9DA8977092B7B81');
exec insert_into_defpwd('TRBM1',  'B10ED16CD76DBB60');
exec insert_into_defpwd('TRCM1',  '530E1F53715105D0');
exec insert_into_defpwd('TRDM1',  'FB1B8EF14CF3DEE7');
exec insert_into_defpwd('TRRM1',  '4F29D85290E62EBE');
exec insert_into_defpwd('TSMSYS',  '3DF26A8B17D0F29F');
exec insert_into_defpwd('TWILLIAMS',  '6BF819CE663B8499');
exec insert_into_defpwd('UDDISYS',  'BF5E56915C3E1C64');
exec insert_into_defpwd('VEA',  'D38D161C22345902');
exec insert_into_defpwd('VEH',  '72A90A786AAE2914');
exec insert_into_defpwd('VIDEO31',  '2FA72981199F9B97');
exec insert_into_defpwd('VIDEO4',  '9E9B1524C454EEDE');
exec insert_into_defpwd('VIDEO5',  '748481CFF7BE98BB');
exec insert_into_defpwd('VP1',  '3CE03CD65316DBC7');
exec insert_into_defpwd('VP2',  'FCCEFD28824DFEC5');
exec insert_into_defpwd('VP3',  'DEA4D8290AA247B2');
exec insert_into_defpwd('VP4',  'F4730B0FA4F701DC');
exec insert_into_defpwd('VP5',  '7DD67A696734AE29');
exec insert_into_defpwd('VP6',  '45660DEE49534ADB');
exec insert_into_defpwd('WAA1',  'CF013DC80A9CBEE3');
exec insert_into_defpwd('WAA2',  '6160E7A17091741A');
exec insert_into_defpwd('WCRSYS',  '090263F40B744BD8');
exec insert_into_defpwd('WEBDB',  'D4C4DCDD41B05A5D');
exec insert_into_defpwd('WEBSYS',  '54BA0A1CB5994D64');
exec insert_into_defpwd('WENDYCHO',  '7E628CDDF051633A');
exec insert_into_defpwd('WH',  '91792EFFCB2464F9');
exec insert_into_defpwd('WIP',  'D326D25AE0A0355C');
exec insert_into_defpwd('WIRELESS',  '1495D279640E6C3A');
exec insert_into_defpwd('WIRELESS',  'EB9615631433603E');
exec insert_into_defpwd('WK_TEST',  '29802572EB547DBF');
exec insert_into_defpwd('WKPROXY',  'AA3CB2A4D9188DDB');
exec insert_into_defpwd('WKSYS',  '545E13456B7DDEA0');
exec insert_into_defpwd('WMS',  'D7837F182995E381');
exec insert_into_defpwd('WMSYS',  '7C9BA362F8314299');
exec insert_into_defpwd('WPS',  '50D22B9D18547CF7');
exec insert_into_defpwd('WSH',  'D4D76D217B02BD7A');
exec insert_into_defpwd('WSM',  '750F2B109F49CC13');
exec insert_into_defpwd('XDB',  '88D8364765FCE6AF');
exec insert_into_defpwd('XDO',  'E9DDE8ACFA7FE8E4');
exec insert_into_defpwd('XDP',  'F05E53C662835FA2');
exec insert_into_defpwd('XLA',  '2A8ED59E27D86D41');
exec insert_into_defpwd('XLE',  'CEEBE966CC6A3E39');
exec insert_into_defpwd('XNB',  '03935918FA35C993');
exec insert_into_defpwd('XNC',  'BD8EA41168F6C664');
exec insert_into_defpwd('XNI',  'F55561567EF71890');
exec insert_into_defpwd('XNM',  '92776EA17B8B5555');
exec insert_into_defpwd('XNP',  '3D1FB783F96D1F5E');
exec insert_into_defpwd('XNS',  'FABA49C38150455E');
exec insert_into_defpwd('XS$NULL',  'DC4FCC8CB69A6733');
exec insert_into_defpwd('XTR',  'A43EE9629FA90CAE');
exec insert_into_defpwd('YCAMPOS',  'C3BBC657F099A10F');
exec insert_into_defpwd('YSANCHEZ',  'E0C033C4C8CC9D84');
exec insert_into_defpwd('ZFA',  '742E092A27DDFB77');
exec insert_into_defpwd('ZPB',  'CAF58375B6D06513');
exec insert_into_defpwd('ZSA',  'AFD3BD3C7987CBB6');
exec insert_into_defpwd('ZX',  '7B06550956254585');

commit;

drop procedure insert_into_defpwd;

Rem=========================================================================
Rem END: BUG 7829203, DEFAULT_PWD$ CHANGES
Rem=========================================================================

Rem======================================================================
Rem bug 10096081 - drop existing HS class definition
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

   
Rem=========================================================================
Rem END STAGE 1: upgrade from 10.2.0 to the current release
Rem=========================================================================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

@@c1101000

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem*************************************************************************
Rem END c1002000.sql
Rem*************************************************************************
