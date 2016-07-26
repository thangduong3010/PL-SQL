Rem $Header: rdbms/admin/e1102000.sql /st_rdbms_11.2.0/78 2013/07/07 09:03:20 mjungerm Exp $
Rem
Rem $Header: rdbms/admin/e1102000.sql /st_rdbms_11.2.0/78 2013/07/07 09:03:20 mjungerm Exp $
Rem
Rem e1102000.sql
Rem
Rem Copyright (c) 2009, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      e1102000.sql - downgrade Oracle from 11.2.0.4 patch release
Rem
Rem    DESCRIPTION
Rem
Rem      This scripts is run from catdwgrd.sql to perform any actions
Rem      needed to downgrade from the current 11.2 patch release to
Rem      prior 11.2 patch releases
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      * The database must be open in UPGRADE mode/DOWNGRADE mode.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vgokhale    03/28/13 - Drop dbms_scn package
Rem    arbalakr    03/22/13 - Bug 16538416: Revoke grant privileges on
Rem                           ashviewer.
Rem    youngtak    02/28/13 - Backport youngtak_bug-16223559 from main
Rem    nrcorcor    02/25/13 - Backport nrcorcor_corcoran_trans_12395847_2 from
Rem                           main
Rem    abrown      02/22/13 - abrown_bp_logmnr_ggtrigger_eliminate
Rem                           o Bug 14378546 : Logminer must track CON$
Rem                           o Bug 14283060: drop logmnrc_*_gg tables
Rem    jovillag    02/27/13 - Backport 14669017 from main
Rem    csantelm    02/28/13 - Bug 14377545
Rem    kmeiyyap    02/15/13 - Backport of kmeiyyap_cell_thread_history_rename
Rem                           from main
Rem    kmeiyyap    02/15/13 - Backport of rahkrish_v_oflcellthreadhistory_main
Rem                           from main
Rem    arbalakr    02/01/13 - Drop cpaddm and rtaddm packages
Rem    elu         02/20/13 - drop get_oldversion_hashcode2
Rem    nikgugup    02/12/13 - Backport maniverm_fixedtable from
Rem    rrungta     02/07/13 - Backport rrungta_bug-10637191 from
Rem    apant       02/10/13 - Backport apant_bug-13900198 from main
Rem    rrungta     02/07/13 - Backport rrungta_bug-10637191 from
Rem    lexuxu      02/04/13 - Backport lexuxu_bug-12963089 from main
Rem    huntran     01/28/13 - Backport huntran_bug-14338486 from main
Rem    kamotwan    01/08/13 - Backport kamotwan_featuretracking_1 and 
Rem                           lzheng_bug-13917054 from main
Rem                           (as kamotwan_bug-15967833)
Rem    anighosh    01/15/13 - Backport anighosh_bug-14296972 from MAIN
Rem    gclaborn    12/24/12 - backport 14530180/14851837 from main
Rem    cchiappa    12/10/12 - Backport
Rem                           cchiappa_bug-10332890_olap_full_transport
Rem                           (10332890 - OLAP / AW SUPPORT FOR FULL DATABASE
Rem                           TRANSPORTABLE EXPORT / IMPORT)
Rem    jmuller     12/03/12 - Backport
Rem                           apfwkr_blr_backport_14162791_11.2.0.3.11exadbbp
Rem                           from st_rdbms_11.2.0.3.0exadbbp
Rem    apfwkr      10/08/12 - Backport apfwkr_blr_backport_14162791_11.2.0.3.0
Rem                           from
Rem    apfwkr      07/12/12 - Backport jmuller_bug-14162791 from
Rem                           st_rdbms_11.2.0
Rem    jmuller     07/06/12 - Bug 14162791 changes
Rem    jgiloni     11/26/12 - Backport jgiloni_bug-14300206 from main
Rem                           Add DEAD_CLEANUP view
Rem    apfwkr      11/12/12 - Backport romorale_bug-14693211 from main
Rem    myuin       11/19/12 - Backport myuin_bug-14744396 from main
Rem    siravic     10/13/12 - Bug# 13888340: Data redaction feature usage
Rem                           tracking
Rem    fergutie    09/26/12 - Backport fergutie_bug-14312761 from main
Rem    pknaggs     09/04/12 - Bug #14133343: Add radm_td$ and radm_cd$ tables.
Rem    huntran     09/02/12 - Backport huntran_bug-13471035 from
Rem    apfwkr      08/20/12 - Backport shiyadav_bug-14320459 from
Rem    vgerard     08/15/12 - set_by backport
Rem    pknaggs     08/14/12 - Proj 44284: Data Redaction downgrd from 11.2.0.4
Rem    apfwkr      08/10/12 - Backport vgerard_bug-14284283 from
Rem    nkgopal     07/11/12 - Bug 12853348: Drop Audit Trail export views
Rem    apfwkr      07/03/12 - Backport shjoshi_rm_newtype from main
Rem    praghuna    07/01/12 - Backport praghuna_bug-13110976 from main
Rem    lzheng      06/22/12 - drop _SXGG_DBA_CAPTURe
Rem    yujwang     06/12/12 - Backport
Rem                           apfwkr_blr_backport_13947480_11.2.0.3.2dbpsu from
Rem                           st_rdbms_11.2.0.3.0dbpsu
Rem    jkundu      06/04/12 - bp 13615340: always log group on seq
Rem    thoang      03/27/12 - lrg 6792616: remove dbms_xstream_gg_internal
Rem    cchiappa    03/15/12 - Backport cchiappa_bug-12957533 from main
Rem    alhollow    02/17/12 - Backport alhollow_bug-13041324 from main
Rem    huntran     05/03/12 - Add error_seq#/error_rba/error_index# for error
Rem                           table
Rem    elu         04/10/12 - add persistent apply tables
Rem    elu         03/20/12 - xin persistent table stats
Rem    tianli      03/20/12 - add seq/rba/index to error tables
Rem    cchiappa    12/15/11 - Bug12957533: Drop awlogseq$ on downgrade
Rem    apfwkr      01/08/12 - Backport yberezin_bug-12926385 from main
Rem    sjanardh    08/12/11 - Selective downgrade for REG$ table
Rem    jomcdon     08/03/11 - lrg 5758311: fix resource manager downgrade
Rem    yurxu       07/25/11 - lrg-5739217
Rem    yujwang     07/19/11 - fix lrg 5731701 (remove default_action at
Rem                         - wrr$_replay_filter_set for 11.2.0.1)
Rem    dvoss       07/22/11 - Backport dvoss_bug-12701895 from main
Rem    hosu        07/21/11 - downgrade synopsis table only when downgrade
Rem                           version is prior to 11.2.0.2
Rem    yurxu       07/18/11 - Backport yurxu_bug-12701917 from main
Rem    alui        07/12/11 - Backport alui_bug-12698413 from main
Rem    elu         06/06/11 - Backport elu_bug-12592488 from main
Rem    thoang      05/19/11 - fix downgrade LRG
Rem    rramkiss    05/17/11 - remove 11.2.0.3 scheduler arg export support
Rem    yurxu       05/04/11 - Backport yurxu_bug-12391440 from main
Rem    rdongmin    05/03/11 - Backport rdongmin_bug-10264073 from main
Rem    prakumar    03/24/11 - Backport prakumar_redef_priv from main
Rem    yurxu       04/12/11 - Backport yurxu_bug-11922716 from main
Rem    bpwang      04/14/11 - Backport bpwang_bug-11815316 from main
Rem    abrown      04/11/11 - Backport abrown_bug-11737200 from main
Rem    elu         03/23/11 - Backport elu_bug-9690366 from main
Rem    alui        03/14/11 - Backport alui_bug-11668542 from main
Rem    sylin       03/09/11 - drop dbms_sql2
Rem    elu         03/03/11 - Backport elu_bug-11725453 from main
Rem    kshergil    02/24/11 - Backport kshergil_bug-11691477 from main
Rem    kkunchit    03/02/11 - Backport kkunchit_bug-10349967 from main
Rem    huntran     02/08/11 - Backport huntran_bug-11678106 from main
Rem    elu         02/16/11 - modify eager_size
Rem    elu         02/19/11 - lcr changes
Rem    kkunchit    02/25/11 - bug-10349967: dbfs export/import support
Rem    huntran     01/26/11 - XStream table stats
Rem    elu         05/25/11 - remove xml schema
Rem    huntran     01/13/11 - conflict, error, and collision handlers
Rem    elu         01/12/11 - error queue
Rem    gkulkarn    01/30/11 - Backport 10271153: Logminer: downgrade from 11203
Rem    avangala    01/29/11 - Backport avangala_bug-9873405 from main
Rem    wbattist    01/19/11 - Backport wbattist_bug-10256769 from main
Rem    ilistvin    01/06/11 - Backport ilistvin_bug-10427840 from main
Rem    mtozawa     12/01/10 - Backport mtozawa_bug-10280821 from main
Rem    fsanchez    10/30/10 - Backport fsanchez_bug-9689580 from main
Rem    smuthuli    08/01/10 - fast space usage changes
Rem    thoang      07/29/10 - drop dba_xstream_outbound view 
Rem    qiwang      05/26/10 - truncate logmnr integrated spill table
Rem                         - (gkulkarn) Set logmnr_session$.spare1 to null
Rem                           on downgrade
Rem    tbhosle     05/04/10 - 8670389: remove session_key from reg$
Rem    jawilson    05/05/10 - Change aq$_replay_info address format
Rem    pbelknap    04/27/10 - add dbms_auto_sqltune
Rem    thoang      04/27/10 - change Streams parameter names
Rem    pbelknap    02/25/10 - #8710750: introduce WRI$_SQLTEXT_REFCOUNT
Rem    wbattist    04/13/10 - drop v$hang_info and v$hang_session_info views
Rem    ptearle     04/09/10 - 8354888: drop synonym for DBA_TAB_MODIFICATIONS
Rem    rmao        03/29/10 - drop v/gv$xstream/goldengate_transaction,
Rem                           v/gv$xstream/goldengate_message_tracking views
Rem    abrown      03/24/10 - bug-9501098: GG XMLOR support
Rem    rmao        03/10/10 - drop v$xstream/goldenate_capture views
Rem    lgalanis    02/16/10 - workload attributes table
Rem    jomcdon     02/10/10 - bug 9368895: add parallel_queue_timeout
Rem    bvaranas    02/10/10 - Drop feature usage tracking procedure for
Rem                           deferred segment creation
Rem    hosu        02/15/10 - 9038395: wri$_optstat_synopsis$ schema change
Rem    jomcdon     02/10/10 - bug 9207475: undo end_time allowed to be null
Rem    rramkiss    02/04/10 - remove new scheduler types
Rem    juyuan      02/01/10 - drop lcr$_row_record.get_object_id
Rem    sburanaw    01/13/10 - filter_set_name in wrr$_replays and
Rem                           default_action in wrr$_replay_filter_set
Rem    juyuan      01/14/10 - re-create ALL_STREAMS_STMT_HANDLERS and
Rem                           ALL_STREAMS_STMTS
Rem    ssprasad    12/28/09 - add vasm_acfs_encryption_info
Rem                           add v$asm_acfs_security_info
Rem    juyuan      12/23/09 - drop {dba,user}_goldengate_privileges
Rem    gngai       09/15/09 - bug 6976775: downgrade adr
Rem    juyuan      01/14/10 - re-create ALL_STREAMS_STMT_HANDLERS and
Rem                           ALL_STREAMS_STMTS
Rem    msusaira    01/11/10 - dbmsdnfs.sql changes
Rem    gagarg      12/24/09 - Bug8656192: Drop rules engine package
Rem                           dbms_rule_internal
Rem    amadan      11/19/09 - Bug 9115881 drop DBA_HIST_PERSISTENT_QMN_CACHE
Rem    adalee      12/08/09 - drop [g]v$database_key_info
Rem    dvoss       12/10/09 - Bug 9128849: delete lsby underscore skip entries
Rem    thoang      12/03/09 - drop synonym dbms_xstream_gg
Rem    shjoshi     11/12/09 - drop view v$advisor_current_sqlplan for downgrade
Rem    arbalakr    11/12/09 - drop views that uses X$MODACT_LENGTH
Rem    jomcdon     12/03/09 - project 24605: clear max_active_sess_target_p1
Rem    ilistvin    11/20/09 - bug 8811401: drop index on WRH$_SEG_STAT_OBJ
Rem    akruglik    11/18/09 - 31113 (SCHEMA SYNONYMS): adding support for 
Rem                           auditing CREATE/DROP SCHEMA SYNONYM
Rem    mfallen     11/15/09 - bug 5842726: add drpadrvw.sql
Rem    mziauddi    11/13/09 - drop views and synonyms for DFT
Rem    arbalakr    11/12/09 - drop views that uses X$MODACT_LENGTH
Rem    xingjin     11/15/09 - Bug 9086576: modify construct in lcr$_row_record
Rem    akruglik    11/10/09 - add/remove new audit_actions rows
Rem    shbose      11/05/09 - Bug 9068654: update destq column
Rem    praghuna    11/03/09 - Drop some columns added in 11.2
Rem    juyuan      10/31/09 - drop a row in sys.props$ where
Rem                           name='GG_XSTREAM_FOR_STREAMS'
Rem    gravipat    10/27/09 - Truncate sqlerror$
Rem    lgalanis    10/27/09 - STS capture for DB Replay
Rem    haxu        10/26/09 - add DBA_APPLY_DML_CONF_HANDLERS changes
Rem    msakayed    10/22/09 - Bug #5842629: direct path load auditing
Rem    praghuna    10/19/09 - Make start_scn_time, first_scn_time NULL
Rem    tianli      10/14/09 - add xstream change
Rem    thoang      10/13/09 - add uncommitted data mode for XStream
Rem    bpwang      10/11/09 - drop DBA_XSTREAM_OUT_SUPPORT_MODE
Rem    elu         10/06/09 - stmt lcr
Rem    alui        10/26/09 - drop objects in APPQOSSYS schema
Rem    msakayed    10/22/09 - Bug #8862486: AUDIT_ACTION for directory execute
Rem    gkulkarn    10/06/09 - Downgrade for ID Key Supplemental logging
Rem    achoi       09/21/09 - edition as a service attribute
Rem    shbose      09/18/09 - Bug 8764375: add destq column to
Rem    sriganes    09/03/09 - bug 8413874: changes for DBA_HIST_MVPARAMETER
Rem    abrown      09/02/09 - downgrade for tianli_bug-8733323
Rem    cdilling    07/31/09 - Patch downgrade script for 11.2
Rem    cdilling    07/31/09 - Created
Rem

Rem *************************************************************************
Rem BEGIN e1102000.sql
Rem *************************************************************************

Rem ========================================================================
Rem Begin Changes for AQ
Rem ========================================================================

update aq$_schedules set destq = NULL;

Rem WRH$_PERSISTENT_QMN_CACHE changes
Rem
drop view DBA_HIST_PERSISTENT_QMN_CACHE;
drop public synonym DBA_HIST_PERSISTENT_QMN_CACHE;
truncate table WRH$_PERSISTENT_QMN_CACHE;


DECLARE
CURSOR s_c IS   SELECT  r.eventid, r.agent.address as address
                from sys.aq$_replay_info r where r.agent.address IS NOT NULL;
dom_pos         BINARY_INTEGER;
db_domain       VARCHAR2(1024);
new_address     VARCHAR2(1024);
BEGIN

  SELECT UPPER(value) INTO db_domain FROM v$parameter WHERE name = 'db_domain';

  IF db_domain IS NOT NULL THEN
    FOR s_c_rec in s_c LOOP
      dom_pos := INSTRB(s_c_rec.address, db_domain, 1, 1);
      IF (dom_pos != 0) THEN
        new_address := SUBSTRB(s_c_rec.address, 1, dom_pos - 2);
        UPDATE sys.aq$_replay_info r set r.agent.address = new_address WHERE
          r.eventid = s_c_rec.eventid AND r.agent.address = s_c_rec.address;
      END IF;

      COMMIT;
    END LOOP;
  END IF;
END;
/

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.2.0' THEN
    EXECUTE IMMEDIATE 'drop index sys.reg$_idx';
    EXECUTE IMMEDIATE 'alter table sys.reg$ drop column session_key';
    -- hidden table to contain session keys for registrations
    EXECUTE IMMEDIATE 'create table sys.regz$( reg_id number, session_key varchar2(1024))';
  END IF; -- of 11.2.0.2.0
END;
/

Rem ========================================================================
Rem End Changes for AQ
Rem ========================================================================

Rem *************************************************************************
Rem Project 44284 - Data Redaction downgrade from 11.2.0.4 changes - BEGIN
Rem (The 12c project id for Data Redaction is 32006)
Rem These changes are for Data Redaction downgrade from 11.2.0.4.
Rem
Rem  Drop all Data Redaction policies (done in f1102000.sql).
Rem  Truncate the Data Reaction dictionary tables
Rem     radm$, radm_mc$, radm_fptm$
Rem  and drop everything created by the following catalog scripts.
Rem     $SRCHOME/rdbms/admin/dbmsredacta.sql
Rem     $SRCHOME/rdbms/src/server/security/dbmasking/prvtredacta.sql
Rem  Delete the EXEMPT REDACTION POLICY system privilege.
Rem *************************************************************************

truncate table radm$;
truncate table radm_mc$;
truncate table radm_td$;
truncate table radm_cd$;
drop public synonym dbms_redact;
drop package body sys.dbms_redact;
drop package sys.dbms_redact;
drop package dbms_redact_int;
drop library dbms_redact_lib;
truncate table radm_fptm$;
truncate table radm_fptm_lob$;
drop view REDACTION_POLICIES;
drop public synonym REDACTION_POLICIES;
drop view REDACTION_COLUMNS;
drop public synonym REDACTION_COLUMNS;
drop view REDACTION_VALUES_FOR_TYPE_FULL;
drop public synonym REDACTION_VALUES_FOR_TYPE_FULL;

Rem Delete the EXEMPT REDACTION POLICY system privilege.
delete from STMT_AUDIT_OPTION_MAP where option# = 351;
delete from SYSTEM_PRIVILEGE_MAP where privilege = -351;
delete from SYSAUTH$ where privilege#=-351;

Rem *************************************************************************
Rem Project 44284 - Data Redaction downgrade from 11.2.0.4 changes - END
Rem *************************************************************************

Rem===================
Rem AWR Changes Begin
Rem===================

Rem  WRH$_MVPARAMETER changes

drop view DBA_HIST_MVPARAMETER;
drop public synonym DBA_HIST_MVPARAMETER;
truncate table WRH$_MVPARAMETER;
truncate table WRH$_MVPARAMETER_BL;

Rem Bug 8811401 changes
drop index WRH$_SEG_STAT_OBJ_INDEX;
truncate table wrh$_tablespace;
drop public synonym AWR_OBJECT_INFO_TABLE_TYPE;
drop public synonym AWR_OBJECT_INFO_TYPE;
drop type AWR_OBJECT_INFO_TABLE_TYPE force;
drop type AWR_OBJECT_INFO_TYPE force;

Rem=================
Rem AWR Changes End
Rem=================

Rem ===========================================================================
Rem Begin Bug#8710750 changes: split WRH$_SQLTEXT table to avoid ref counting
Rem contention.
Rem ===========================================================================

-- Move ref counts back into WRH$_SQLTEXT
MERGE
/*+ FULL(@"SEL$F5BB74E1" "WRI$_SQLTEXT_REFCOUNT"@"SEL$2") */ 
INTO WRH$_SQLTEXT S
USING (SELECT DBID, SQL_ID, REF_COUNT FROM WRI$_SQLTEXT_REFCOUNT) R
ON (R.DBID (+) = S.DBID AND R.SQL_ID (+) = S.SQL_ID)
WHEN MATCHED THEN UPDATE
  SET S.REF_COUNT = nvl(R.REF_COUNT, 0);

commit;

TRUNCATE TABLE WRI$_SQLTEXT_REFCOUNT
/

Rem ===========================================================================
Rem End Bug#8710750 changes: split WRH$_SQLTEXT table to avoid ref counting
Rem contention.
Rem ===========================================================================


Rem===================
Rem ADR Changes Begin
Rem===================

@@drpadrvw.sql

Rem=================
Rem ADR Changes End
Rem=================


Rem*************************************************************************
Rem BEGIN Changes for LogMiner
Rem*************************************************************************

DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version < '11.2.0.2' THEN

     /* downgrade for tianli_bug-8733323: clear new bit */
     /* add downgrade for abrown_bug-9501098. clear another new bit. */
     /* Note: 4294967199 == FFFFFF9F */

     update system.logmnrc_gtlo
     set LogmnrTLOFlags = bitand(LogmnrTLOFlags, 4294967199)
     where bitand(32,LogmnrTLOFlags) = 32 or bitand(64,LogmnrTLOFlags) = 64;
     commit;

     /* downgrade for ID KEY supplemental logging : clear new bit */
     update sys.tab$
     set trigflag = trigflag - 512
     where bitand(512,trigflag) = 512;
     commit;

     /* downgrade for sessionFlags2 */
     update system.logmnr_session$
     set spare1 = null;
     commit;

  END IF;
END;
/ 

drop view logstdby_support_tab_11_2b;
drop view logstdby_unsupport_tab_11_2b;

truncate table SYSTEM.logmnr_integrated_spill$;

drop procedure sys.logmnr_rmt_bld;
drop trigger sys.logmnrggc_trigger;
drop procedure sys.logmnr_ddl_trigger_proc;
drop function system.logmnr_get_gt_protocol;

Rem =======================================================================
Rem  End Changes for LogMiner
Rem =======================================================================

Rem =======================================================================
Rem Begin changes for read-only database user account login tracking/status
Rem ======================================================================
drop public synonym gv$ro_user_account;
drop view gv_$ro_user_account;
drop public synonym v$ro_user_account;
drop view v_$ro_user_account;

Rem =======================================================================
Rem  Begin Changes for ADR
Rem =======================================================================

drop public synonym dbms_adr;
drop package body sys.dbms_adr;
drop package sys.dbms_adr;
drop library dbms_adr_lib;

Rem =======================================================================
Rem  End Changes for ADR
Rem =======================================================================

Rem =======================================================================
Rem Begin Changes for Logical Standby
Rem =======================================================================


DECLARE
previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version < '11.2.0.2' THEN

  delete from system.logstdby$skip
    where statement_opt = '_UNSUPPORTED_OVERRIDE';
  commit;

  END IF;
END;
/ 

Rem =======================================================================
Rem  End Changes for Logical Standby
Rem =======================================================================

Rem =======================================================================
Rem  Begin Changes for XStream/Streams
Rem =======================================================================
Rem
Rem !!! Be sure to protect any dml/truncate table statements with 
Rem the previous version checks !!!

Rem Drop Views and Packages
drop view DBA_STREAMS_TRANSFORMATIONS;
drop public synonym DBA_STREAMS_TRANSFORMATIONS;
drop view USER_STREAMS_TRANSFORMATIONS;
drop public synonym USER_STREAMS_TRANSFORMATIONS;
drop view ALL_STREAMS_TRANSFORMATIONS;
drop public synonym ALL_STREAMS_TRANSFORMATIONS;
drop view DBA_ATTRIBUTE_TRANSFORMATIONS;
drop public synonym DBA_ATTRIBUTE_TRANSFORMATIONS;
drop view USER_ATTRIBUTE_TRANSFORMATIONS;
drop public synonym USER_ATTRIBUTE_TRANSFORMATIONS;
drop view ALL_ATTRIBUTE_TRANSFORMATIONS;
drop public synonym ALL_ATTRIBUTE_TRANSFORMATIONS;
drop view ALL_STREAMS_KEEP_COLUMNS;
drop public synonym ALL_STREAMS_KEEP_COLUMNS;
drop view ALL_APPLY_INSTANTIATED_OBJECTS;
drop public synonym ALL_APPLY_INSTANTIATED_OBJECTS;
drop view ALL_APPLY_INSTANTIATED_SCHEMAS;
drop public synonym ALL_APPLY_INSTANTIATED_SCHEMAS;
drop view ALL_APPLY_INSTANTIATED_GLOBAL;
drop public synonym ALL_APPLY_INSTANTIATED_GLOBAL;
drop view ALL_APPLY_SPILL_TXN;
drop public synonym ALL_APPLY_SPILL_TXN;
drop view all_comparison_scan_summary;
drop public synonym all_comparison_scan_summary;
drop view ALL_XSTREAM_ADMINISTRATOR;
drop public synonym ALL_XSTREAM_ADMINISTRATOR;

drop view all_xstream_out_support_mode;
drop public synonym all_xstream_out_support_mode;
drop view dba_xstream_out_support_mode;
drop public synonym dba_xstream_out_support_mode;

drop view "_DBA_XSTREAM_OUT_ALL_TABLES";
drop view "_DBA_XSTREAM_OUT_ADT_PK_TABLES";

drop view dba_goldengate_support_mode;
drop public synonym dba_goldengate_support_mode;

drop public synonym ALL_APPLY_DML_CONF_HANDLERS;
drop view ALL_APPLY_DML_CONF_HANDLERS;
drop public synonym DBA_APPLY_DML_CONF_HANDLERS;
drop view DBA_APPLY_DML_CONF_HANDLERS;
drop view "_DBA_APPLY_DML_CONF_HANDLERS";

Rem xstream conflict handler columns
drop public synonym ALL_APPLY_DML_CONF_COLUMNS;
drop view ALL_APPLY_DML_CONF_COLUMNS;
drop public synonym DBA_APPLY_DML_CONF_COLUMNS;
drop view DBA_APPLY_DML_CONF_COLUMNS;
drop view "_DBA_APPLY_DML_CONF_COLUMNS";

Rem xstream collision handlers
drop public synonym ALL_APPLY_HANDLE_COLLISIONS;
drop view ALL_APPLY_HANDLE_COLLISIONS;
drop public synonym DBA_APPLY_HANDLE_COLLISIONS;
drop view DBA_APPLY_HANDLE_COLLISIONS;
drop view "_DBA_APPLY_HANDLE_COLLISIONS";

Rem xstream collision handlers
drop public synonym ALL_APPLY_REPERROR_HANDLERS;
drop view ALL_APPLY_REPERROR_HANDLERS;
drop public synonym DBA_APPLY_REPERROR_HANDLERS;
drop view DBA_APPLY_REPERROR_HANDLERS;
drop view "_DBA_APPLY_REPERROR_HANDLERS";

Rem USER_APPLY_ERROR view
drop public synonym USER_APPLY_ERROR;
drop view USER_APPLY_ERROR;
drop public synonym DBA_APPLY_ERROR_MESSAGES;
drop view DBA_APPLY_ERROR_MESSAGES;
drop public synonym ALL_APPLY_ERROR_MESSAGES;
drop view ALL_APPLY_ERROR_MESSAGES;

drop public synonym GV$XSTREAM_TABLE_STATS;
drop view GV_$XSTREAM_TABLE_STATS;
drop public synonym V$XSTREAM_TABLE_STATS;
drop view V_$XSTREAM_TABLE_STATS;
drop view "_DBA_APPLY_TABLE_STATS";

drop public synonym GV$GOLDENGATE_TABLE_STATS;
drop view GV_$GOLDENGATE_TABLE_STATS;
drop public synonym V$GOLDENGATE_TABLE_STATS;
drop view V_$GOLDENGATE_TABLE_STATS;

drop view ALL_GOLDENGATE_PRIVILEGES;
drop public synonym ALL_GOLDENGATE_PRIVILEGES;
drop public synonym dba_goldengate_privileges;
drop public synonym user_goldengate_privileges;
drop view dba_goldengate_privileges;
drop view user_goldengate_privileges;

Rem Drop DBA_XSTREAM_OUTBOUND because in 11.2.0.2 this view refers to
Rem gv$xstream_outbound_server, which is not available in 11.2.0.1.
drop view DBA_XSTREAM_OUTBOUND;

drop view "_DBA_XSTREAM_OUTBOUND";
drop view "_DBA_XSTREAM_CONNECTION";

drop public synonym V$XSTREAM_OUTBOUND_SERVER;
drop view V_$XSTREAM_OUTBOUND_SERVER;
drop public synonym GV$XSTREAM_OUTBOUND_SERVER;
drop view GV_$XSTREAM_OUTBOUND_SERVER;

drop view "_DBA_APPLY_COORDINATOR_STATS";
drop view "_DBA_APPLY_SERVER_STATS";
drop view "_DBA_APPLY_READER_STATS";
drop view "_DBA_APPLY_BATCH_SQL_STATS";

drop public synonym gv$xstream_capture;
drop view gv_$xstream_capture;
drop public synonym v$xstream_capture;
drop view v_$xstream_capture;

drop public synonym gv$goldengate_capture;
drop view gv_$goldengate_capture;
drop public synonym v$goldengate_capture;
drop view v_$goldengate_capture;

drop public synonym gv$xstream_transaction;
drop view gv_$xstream_transaction;
drop public synonym v$xstream_transaction;
drop view v_$xstream_transaction;

drop public synonym gv$goldengate_transaction;
drop view gv_$goldengate_transaction;
drop public synonym v$goldengate_transaction;
drop view v_$goldengate_transaction;

drop public synonym gv$xstream_message_tracking;
drop view gv_$xstream_message_tracking;
drop public synonym v$xstream_message_tracking;
drop view v_$xstream_message_tracking;

drop public synonym gv$goldengate_message_tracking;
drop view gv_$goldengate_messagetracking;
drop public synonym v$goldengate_message_tracking;
drop view v_$goldengate_message_tracking;

drop public synonym gv$xstream_apply_coordinator;
drop view gv_$xstream_apply_coordinator;
drop public synonym v$xstream_apply_coordinator;
drop view v_$xstream_apply_coordinator;

drop public synonym gv$xstream_apply_reader;
drop view gv_$xstream_apply_reader;
drop public synonym v$xstream_apply_reader;
drop view v_$xstream_apply_reader;

drop public synonym gv$xstream_apply_server;
drop view gv_$xstream_apply_server;
drop public synonym v$xstream_apply_server;
drop view v_$xstream_apply_server;

drop public synonym gv$xstream_apply_receiver;
drop view gv_$xstream_apply_receiver;
drop public synonym v$xstream_apply_receiver;
drop view v_$xstream_apply_receiver;

drop public synonym gv$gg_apply_coordinator;
drop view gv_$gg_apply_coordinator;
drop public synonym v$gg_apply_coordinator;
drop view v_$gg_apply_coordinator;

drop public synonym gv$gg_apply_reader;
drop view gv_$gg_apply_reader;
drop public synonym v$gg_apply_reader;
drop view v_$gg_apply_reader;

drop public synonym gv$gg_apply_server;
drop view gv_$gg_apply_server;
drop public synonym v$gg_apply_server;
drop view v_$gg_apply_server;

drop public synonym gv$gg_apply_receiver;
drop view gv_$gg_apply_receiver;
drop public synonym v$gg_apply_receiver;
drop view v_$gg_apply_receiver;

drop view dba_goldengate_inbound;
drop public synonym dba_goldengate_inbound;
drop view all_goldengate_inbound;
drop public synonym all_goldengate_inbound;

drop view dba_gg_inbound_progress;
drop public synonym dba_gg_inbound_progress;
drop view all_gg_inbound_progress;
drop public synonym all_gg_inbound_progress;

drop package dbms_xstream_utl_ivk;
drop package dbms_xstream_adm_internal;
drop package dbms_xstream_gg;
drop package dbms_xstream_gg_internal;
drop package dbms_xstream_auth;
drop PUBLIC SYNONYM dbms_xstream_gg; 
drop PUBLIC SYNONYM dbms_xstream_auth; 

drop public synonym dbms_xstream_gg_adm;
drop public synonym dbms_goldengate_auth;
drop package dbms_xstream_gg_adm;
drop package dbms_goldengate_auth;

drop view "_SXGG_DBA_CAPTURE";
drop view DBA_CAPTURE;
drop public synonym DBA_CAPTURE;

-- drop synonym for dbms_ash_internal package
drop public synonym ashviewer;

-- Revoke execute privileges on dbms_ash_internal pacakge
revoke execute on dbms_ash_internal from public 

-- drop Real Time ADDM package
drop package prvt_rtaddm;

-- drop Compare Period ADDM packages
drop package prvt_awr_data;
drop package prvt_awr_data_cp;
drop package prvt_cpaddm;

-- drop Compare Period types
drop type prvt_awr_period FORCE;
drop type prvt_awr_inst_meta_tab FORCE;
drop type prvt_awr_inst_meta FORCE;

alter type lcr$_ddl_record drop STATIC FUNCTION construct(
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
     edition_name               in varchar2          DEFAULT NULL,
     current_user               in varchar2          DEFAULT NULL
   )
   RETURN lcr$_ddl_record cascade;

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.3.0' THEN
    EXECUTE IMMEDIATE 'alter type lcr$_ddl_record ' || 
     'add STATIC FUNCTION construct(' || 
     '  source_database_name       in varchar2,' || 
     '  command_type               in varchar2,' || 
     '  object_owner               in varchar2,' || 
     '  object_name                in varchar2,' || 
     '  object_type                in varchar2,' || 
     '  ddl_text                   in clob,' || 
     '  logon_user                 in varchar2,' || 
     '  current_schema             in varchar2,' || 
     '  base_table_owner           in varchar2,' || 
     '  base_table_name            in varchar2,' || 
     '  tag                        in raw               DEFAULT NULL,' || 
     '  transaction_id             in varchar2          DEFAULT NULL,' || 
     '  scn                        in number            DEFAULT NULL,' || 
     '  position                   in raw               DEFAULT NULL,' || 
     '  edition_name               in varchar2          DEFAULT NULL' || 
     ')' || 
   '  RETURN lcr$_ddl_record cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_ddl_record ' ||
      'drop MEMBER FUNCTION get_current_user RETURN varchar2 cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_ddl_record '|| 
      'drop MEMBER PROCEDURE set_current_user '||
      '(self in out nocopy lcr$_ddl_record, current_user IN VARCHAR2) cascade';

  ELSE
    EXECUTE IMMEDIATE 'alter type lcr$_ddl_record ' || 
     'add STATIC FUNCTION construct(' || 
     '  source_database_name       in varchar2,' || 
     '  command_type               in varchar2,' || 
     '  object_owner               in varchar2,' || 
     '  object_name                in varchar2,' || 
     '  object_type                in varchar2,' || 
     '  ddl_text                   in clob,' || 
     '  logon_user                 in varchar2,' || 
     '  current_schema             in varchar2,' || 
     '  base_table_owner           in varchar2,' || 
     '  base_table_name            in varchar2,' || 
     '  tag                        in raw               DEFAULT NULL,' || 
     '  transaction_id             in varchar2          DEFAULT NULL,' || 
     '  scn                        in number            DEFAULT NULL,' || 
     '  position                   in raw               DEFAULT NULL,' || 
     '  edition_name               in varchar2          DEFAULT NULL,' || 
     '  current_user               in varchar2          DEFAULT NULL' ||
     ')' || 
   '  RETURN lcr$_ddl_record cascade';
  END IF;
END;
/

Rem Changes to Row LCR 

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
     position                   in raw               DEFAULT NULL,
     statement                  in varchar2          DEFAULT NULL,
     bind_variables             in sys.lcr$_row_list DEFAULT NULL,
     bind_by_position           in varchar2          DEFAULT 'N'
   )  RETURN lcr$_row_record cascade;

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.2.0' THEN

    EXECUTE IMMEDIATE 'alter type lcr$_row_record drop member function '||
       'is_statement_lcr return varchar2 cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_row_record drop  member procedure '||
       'set_row_text(self in out nocopy lcr$_row_record, '||
       '             row_text           IN CLOB, '||
       '             variable_list IN sys.lcr$_row_list DEFAULT NULL, '||
       '             bind_by_position in varchar2 DEFAULT ''N'') cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_row_record '||
     'add static function construct('||
     '  source_database_name       in varchar2,'||
     '  command_type               in varchar2,'||
     '  object_owner               in varchar2,'||
     '  object_name                in varchar2,'||
     '  tag                        in raw               DEFAULT NULL,'||
     '  transaction_id             in varchar2          DEFAULT NULL,'||
     '  scn                        in number            DEFAULT NULL,'||
     '  old_values                 in sys.lcr$_row_list DEFAULT NULL,'||
     '  new_values                 in sys.lcr$_row_list DEFAULT NULL,'||
     '  position                   in raw               DEFAULT NULL'||
     ')  RETURN lcr$_row_record cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_row_record drop member function '||
       'get_base_object_id return number cascade';

    EXECUTE IMMEDIATE 'alter type lcr$_row_record drop member function '||
       'get_object_id return number cascade';

  ELSE
    EXECUTE IMMEDIATE 'alter type lcr$_row_record '||
     'add static function construct('||
     '  source_database_name       in varchar2,'||
     '  command_type               in varchar2,'||
     '  object_owner               in varchar2,'||
     '  object_name                in varchar2,'||
     '  tag                        in raw               DEFAULT NULL,'||
     '  transaction_id             in varchar2          DEFAULT NULL,'||
     '  scn                        in number            DEFAULT NULL,'||
     '  old_values                 in sys.lcr$_row_list DEFAULT NULL,'||
     '  new_values                 in sys.lcr$_row_list DEFAULT NULL,'||
     '  position                   in raw               DEFAULT NULL,'||
     '  statement                  in varchar2          DEFAULT NULL,'||
     '  bind_variables             in sys.lcr$_row_list DEFAULT NULL,'||
     '  bind_by_position           in varchar2          DEFAULT ''N'''||
     ')  RETURN lcr$_row_record cascade';
  END IF;

END;
/ 

DECLARE
  previous_version varchar2(30);
  -- the variables used for copying xstream$_privileges
  user_names_xs     dbms_sql.varchar2s;
  cnt               NUMBER;
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.3.0' THEN

    -- Copy xstream users from xstream$_privileges to streams$_privileged_user
    BEGIN
      SELECT xp.username
      BULK COLLECT INTO user_names_xs
      FROM sys.xstream$_privileges xp;

      FOR i IN 1 .. user_names_xs.count 
      LOOP 
        -- insert into streams$_privileged_user
        SELECT count(*) into cnt 
          FROM sys.streams$_privileged_user
          WHERE user# IN
           (SELECT u.user#
            FROM sys.user$ u
            WHERE u.name = user_names_xs(i));

        IF (cnt = 0) THEN
          INSERT INTO sys.streams$_privileged_user(user#, privs, flags)
           SELECT u.user#, 1, 1
            FROM user$ u
            WHERE u.name = user_names_xs(i);
        ELSE
          UPDATE sys.streams$_privileged_user
           SET privs = dbms_logrep_util.bis(privs,
                       dbms_streams_adm_utl.privs_local_offset),
              flags = dbms_logrep_util.bis(0, 1)
          WHERE user# IN
           (SELECT u.user#
            FROM sys.user$ u
            WHERE u.name = user_names_xs(i));
        END IF;
      END LOOP;
    END;
  END IF; -- of 11.2.0.3.0
END;
/

DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.4.0' THEN
    update apply$_error 
      set error_pos = NULL,
          start_seq# = NULL,
          end_seq# = NULL,
          start_rba = NULL,
          end_rba = NULL,
          error_seq# = NULL,
          error_rba = NULL,
          error_index# = NULL,
          spare6 = NULL,
          spare7 = NULL,
          spare8 = NULL,
          spare9 = NULL,
          spare10 = NULL,
          spare11 = NULL,
          spare12 = NULL;
    commit;
  
    update apply$_error_txn 
      set seq# = NULL,
          index# = NULL,
          rba = NULL,
          spare7 = NULL,
          spare8 = NULL,
          spare9 = NULL,
          spare10 = NULL,
          spare11 = NULL,
          spare12 = NULL;
    commit;

    update apply$_dest_obj_ops set set_by = NULL;
    commit;
    update xstream$_dml_conflict_handler set set_by = NULL;
    commit;
    update xstream$_reperror_handler set set_by = NULL;
    commit;
    update xstream$_handle_collisions set set_by = NULL;
    commit;

  END IF; -- of 11.2.0.4.0

  IF previous_version < '11.2.0.3.0' THEN
    update sys.streams$_process_params 
      set name = '_MAX_PARALLELISM', internal_flag = 1
      where name = 'MAX_PARALLELISM';

    update sys.streams$_process_params 
      set name = '_EAGER_SIZE', internal_flag = 1 
      where name = 'EAGER_SIZE';

    update xstream$_server set
      connect_user = null;

    update xstream$_server
      set status_change_time = NULL;
  END IF; -- of 11.2.0.3.0

  IF previous_version < '11.2.0.2.0' THEN

    -- Set the new columns to null in older releases
    update  streams$_apply_milestone 
      set spare8 = null, 
          spare9 = null, 
          spare10 = null, 
          spare11 = null,
          eager_error_retry = NULL;

    update sys.streams$_process_params
      set name = '_CMPKEY_ONLY', internal_flag = 1
      where name = 'COMPARE_KEY_ONLY';

    update sys.streams$_process_params
      set name = '_IGNORE_TRANSACTION', internal_flag = 1
      where name = 'IGNORE_TRANSACTION';

    update sys.streams$_process_params
      set name = '_IGNORE_UNSUPERR_TABLE', internal_flag = 1
      where name = 'IGNORE_UNSUPPORTED_TABLE';

    -- Nullify the scn_time fields for lower versions
    update streams$_capture_process 
    set start_scn_time = NULL, first_scn_time = NULL;

    update sys.apply$_error
      set retry_count = NULL,
          flags       = NULL;

     -- Clear uncommitted data flag
    update xstream$_server  
      set flags = flags - 4  where bitand(flags, 4) = 4;

    update streams$_apply_process set
          spare4                      = NULL,
          spare5                      = NULL,
          spare6                      = NULL,
          spare7                      = NULL,
          spare8                      = NULL,
          spare9                      = NULL;

    update streams$_privileged_user set
          flags                       = NULL,
          spare1                      = NULL,
          spare2                      = NULL,
          spare3                      = NULL,
          spare4                      = NULL;
 
    update sys.apply$_error_txn
      set source_object_owner = NULL,
          source_object_name  = NULL,
          dest_object_owner   = NULL,
          dest_object_name    = NULL,
          primary_key         = NULL,
          position            = NULL,
          message_flags       = NULL,
          operation           = NULL;
 
    delete from sys.props$ where name='GG_XSTREAM_FOR_STREAMS';

  END IF; -- of 11.2.0.2.0

END;
/
commit;

Rem DDLs for changes in patchsets
DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';

  IF previous_version < '11.2.0.4.0' THEN

    EXECUTE IMMEDIATE 'truncate table apply$_table_stats';
    EXECUTE IMMEDIATE 'truncate table apply$_coordinator_stats';
    EXECUTE IMMEDIATE 'truncate table apply$_server_stats';
    EXECUTE IMMEDIATE 'truncate table apply$_reader_stats';
    EXECUTE IMMEDIATE 'truncate table apply$_batch_sql_stats';

  END IF; -- of 11.2.0.4.0

  IF previous_version < '11.2.0.3.0' THEN

    EXECUTE IMMEDIATE 'truncate table xstream$_dml_conflict_columns';
    EXECUTE IMMEDIATE 'truncate table xstream$_handle_collisions';
    EXECUTE IMMEDIATE 'truncate table xstream$_reperror_handler';
    EXECUTE IMMEDIATE 'truncate table sys.xstream$_privileges';
    EXECUTE IMMEDIATE 'drop index i_xstream_privileges';

  END IF; -- of 11.2.0.3.0

  IF previous_version < '11.2.0.2.0' THEN
    -- xstream parameter changes
    EXECUTE IMMEDIATE 'drop view "_DBA_XSTREAM_PARAMETERS"';
    EXECUTE IMMEDIATE 'truncate table xstream$_parameters';
    EXECUTE IMMEDIATE 'drop index i_xstream_parameters';

    -- xstream dml_conflict_handler
    EXECUTE IMMEDIATE 'truncate table xstream$_dml_conflict_handler';

    EXECUTE IMMEDIATE 'truncate table xstream$_ddl_conflict_handler';
    EXECUTE IMMEDIATE 'truncate table xstream$_map';

    EXECUTE IMMEDIATE 'truncate table xstream$_server_connection';


    EXECUTE IMMEDIATE 'truncate table sys.goldengate$_privileges';
  END IF; -- of 11.2.0.2.0
END;
/


declare
 oldflag number;
 CURSOR all_apply IS 
   select apply#, flags from sys.streams$_apply_milestone;
begin
 FOR app IN all_apply 
 LOOP
   oldflag := 0;
   /* Pass on used flag KNALA_PTO_USED -> KNAPROCFPTOUSED */
   IF (bitand(app.flags, 1) = 1) THEN
     oldflag := 8192;
     /* Pass on recovered flag KNALA_PTO_RECOVERED -> KNAPROCFPTRDONE */
     IF (bitand(app.flags, 2) = 2) THEN
       oldflag := oldflag + 2048;
     END IF;
   END IF;
   update sys.streams$_apply_process set flags = oldflag 
   where apply# = app.apply#;
   /* Not clearing the milestone flags for debugging purpose */
 END LOOP; 
 COMMIT;
  
end;
/


Rem Remove Replication Bundle row from sys.props$
BEGIN
  EXECUTE IMMEDIATE 'delete from sys.props$ where NAME='''||
  'REPLICATION_BUNDLE''';
END;
/

Rem =======================================================================
Rem  End Changes for XStream/Streams
Rem =======================================================================

Rem*************************************************************************
Rem BEGIN Changes for Service
Rem*************************************************************************

Rem remove the edition column
update service$ set edition = null;
commit;

Rem =======================================================================
Rem  End Changes for Service
Rem =======================================================================

Rem truncate sqlerroror$
truncate table sqlerror$;

Rem =======================================================================
Rem  Bug #5842629 : direct path load and direct path export
Rem =======================================================================
delete from STMT_AUDIT_OPTION_MAP where option# = 330;
delete from STMT_AUDIT_OPTION_MAP where option# = 331;
Rem =======================================================================
Rem  End Changes for Bug #5842629
Rem =======================================================================  

Rem =======================================================================
Rem  Begin Changes for Database Replay
Rem =======================================================================
Rem
Rem NULL out columns added for STS tracking
Rem
Rem wrr$_captures
update WRR$_CAPTURES set sqlset_owner = NULL, sqlset_name = NULL;
Rem wrr$_replays
update WRR$_REPLAYS 
set sqlset_owner = NULL, sqlset_name = NULL, 
    sqlset_cap_interval = NULL,
    filter_set_name = NULL,
    num_admins = NULL,
    schedule_name = NULL;

Rem
Rem Delete entries related to consolidated replay
Rem
delete from WRR$_REPLAY_DIVERGENCE where file_id <> cap_file_id;
delete from WRR$_REPLAY_SQL_BINDS where file_id <> cap_file_id;

Rem
Rem Update the remaining entries which correspond to non-consolidated replays
Rem
update WRR$_REPLAY_DIVERGENCE set cap_file_id = NULL;
update WRR$_REPLAY_SQL_BINDS  set cap_file_id = NULL;

Rem
Rem Drop this column since the table was introduced at 11.2.0.1
Rem      and the column was added at 11.2.0.2
Rem
DECLARE
  previous_version varchar2(30);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version LIKE '11.2.0.1%' THEN
    execute immediate 'alter table WRR$_REPLAY_FILTER_SET drop column default_action';
  END IF;
END;
/
commit;

Rem
Rem truncate attributes table
Rem
truncate table wrr$_workload_attributes;

Rem truncate user map and related views
truncate table wrr$_user_map;
drop view dba_workload_user_map;
drop public synonym dba_workload_user_map;
drop view dba_workload_active_user_map;
drop public synonym dba_workload_active_user_map;

Rem =======================================================================
Rem  End Changes for Database Replay
Rem =======================================================================

Rem ==========================
Rem Begin Bug #8862486 changes
Rem ==========================

Rem Directory EXECUTE auditing (action #135)
delete from AUDIT_ACTIONS where action = 135;

Rem ========================
Rem End Bug #8862486 changes
Rem ========================


Rem*************************************************************************
Rem BEGIN Changes for WLM
Rem*************************************************************************
Rem Drop table required due to package dependencies
Rem so that the WLM user, appqossys can be dropped without cascade
Rem specified after all its tables are removed.

drop public synonym wlm_mpa_stream;
drop public synonym wlm_violation_stream;
drop table appqossys.wlm_mpa_stream;
drop table appqossys.wlm_violation_stream;

drop public synonym WLM_CAPABILITY_OBJECT;
drop public synonym WLM_CAPABILITY_ARRAY;
drop type WLM_CAPABILITY_ARRAY force;
drop type WLM_CAPABILITY_OBJECT force;

Rem =======================================================================
Rem  End Changes for WLM
Rem =======================================================================

Rem ==========================
Rem Begin ALTER USER RENAME changes
Rem ==========================

-- Schema Synonyms got postponed to 12g
-- delete from audit_actions where action in (222, 224);
-- delete from stmt_audit_option_map where option# in (332, 333);

Rem ========================
Rem End ALTER USER RENAME changes
Rem ========================

Rem =======================================================================
Rem  Begin Changes for DML frequency tracking (DFT)
Rem =======================================================================

DROP VIEW v_$object_dml_frequencies;
DROP PUBLIC synonym v$object_dml_frequencies;
DROP VIEW gv_$object_dml_frequencies;
DROP PUBLIC synonym gv$object_dml_frequencies;

Rem =======================================================================
Rem  End Changes for DML frequency tracking (DFT)
Rem =======================================================================

Rem ************************************************************************
Rem Resource Manager related changes - BEGIN
Rem ************************************************************************

DECLARE
previous_version varchar2(30);
ddl varchar2(200);
BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
  IF previous_version < '11.2.0.2' THEN

    update resource_plan_directive$ set
      max_active_sess_target_p1 = 4294967295;
    update resource_plan_directive$ set
      parallel_queue_timeout = NULL;
    commit;

    -- Remove all entries with null values.
    -- Undo the change in upgrade to allow null values (see bug #9207475)
    delete from wrh$_rsrc_plan where end_time is null;
    ddl := 'alter table wrh$_rsrc_plan modify (end_time date not null)';

    execute immediate ddl;
  END IF;
END;
/

Rem ************************************************************************
Rem Resource Manager related changes - END
Rem ************************************************************************

Rem**************************************************************************
Rem BEGIN Drop all the views that use X$MODACT_LENGTH
Rem**************************************************************************

drop view DBA_HIST_SQLSTAT;
drop public synonym DBA_HIST_SQLSTAT;

drop view DBA_HIST_ACTIVE_SESS_HISTORY;
drop public synonym DBA_HIST_ACTIVE_SESS_HISTORY;

drop view DBA_WORKLOAD_REPLAY_DIVERGENCE;
drop public synonym DBA_WORKLOAD_REPLAY_DIVERGENCE;

drop view DBA_SQLTUNE_STATISTICS;
drop public synonym DBA_SQLTUNE_STATISTICS;

drop view USER_SQLTUNE_STATISTICS;
drop public synonym USER_SQLTUNE_STATISTICS;

drop view DBA_SQLSET_STATEMENTS;
drop public synonym DBA_SQLSET_STATEMENTS;

drop view USER_SQLSET_STATEMENTS;
drop public synonym USER_SQLSET_STATEMENTS;

drop view ALL_SQLSET_STATEMENTS;
drop public synonym ALL_SQLSET_STATEMENTS;

drop view "_ALL_SQLSET_STATEMENTS_ONLY";
drop public synonym "_ALL_SQLSET_STATEMENTS_ONLY";

drop view "_ALL_SQLSET_STATEMENTS_PHV";
drop public synonym "_ALL_SQLSET_STATEMENTS_PHV";

drop view "_DBA_STREAMS_COMPONENT_EVENT";
drop public synonym "_DBA_STREAMS_COMPONENT_EVENT";

drop view DBA_SQL_PLAN_BASELINES;
drop public synonym DBA_SQL_PLAN_BASELINES;

drop view DBA_ADVISOR_SQLW_STMTS;
drop public synonym DBA_ADVISOR_SQLW_STMTS;

drop view USER_ADVISOR_SQLW_STMTS;
drop public synonym USER_ADVISOR_SQLW_STMTS;

Rem**************************************************************************
Rem END Drop all the views that use X$MODACT_LENGTH
Rem**************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for SPA
Rem*************************************************************************

drop public synonym gv$advisor_current_sqlplan;
drop public synonym v$advisor_current_sqlplan;
drop view gv_$advisor_current_sqlplan;
drop view v_$advisor_current_sqlplan;

Rem =======================================================================
Rem  End Changes for SPA
Rem =======================================================================

Rem*************************************************************************
Rem BEGIN Changes for SPA
Rem*************************************************************************

drop package dbms_auto_sqltune;
drop public synonym dbms_auto_sqltune;

Rem*************************************************************************
Rem END Changes for SPA
Rem*************************************************************************


Rem ************************************************************************
Rem TDE Tablespace encrypton related changes - BEGIN
Rem ************************************************************************

drop public synonym v$database_key_info;
drop view v_$database_key_info;
drop public synonym gv$database_key_info;
drop view gv_$database_key_info;

Rem ************************************************************************
Rem TDE Tablespace encrypton related changes - END
Rem ************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for Scheduler - remove new import callouts
Rem*************************************************************************

DROP VIEW system.scheduler_program_args;
DROP VIEW system.scheduler_job_args;
TRUNCATE TABLE system.scheduler_program_args_tbl;
TRUNCATE TABLE system.scheduler_job_args_tbl;

Rem*************************************************************************
Rem END Changes for Scheduler - remove new import callouts
Rem*************************************************************************

Rem ************************************************************************
Rem Rules engine related changes - BEGIN
Rem ************************************************************************

Rem Bug 8656192: Rule/chain performance improvement.
drop public synonym dbms_rule_internal;
drop package sys.dbms_rule_internal;

Rem ************************************************************************
Rem Rules engine related changes - END
Rem ************************************************************************


Rem ************************************************************************
Rem Scheduler/Chains  related changes - BEGIN
Rem ************************************************************************

Rem Bug 8656192: Rule/chain performance improvement
drop type sys.scheduler$_var_value_list FORCE;
drop type sys.scheduler$_variable_value FORCE;

Rem ************************************************************************
Rem Scheduler/Chains  related changes - END
Rem ************************************************************************


Rem ************************************************************************
Rem Direct NFS changes - BEGIN
Rem ************************************************************************

drop PUBLIC SYNONYM dbms_dnfs;
drop package dbms_dnfs;

Rem ************************************************************************
Rem Direct NFS changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem ACFS Security and Encryption related changes - BEGIN
Rem ************************************************************************

drop public synonym v$asm_acfs_security_info;
drop view v_$asm_acfs_security_info;
drop public synonym gv$asm_acfs_security_info;
drop view gv_$asm_acfs_security_info;

drop public synonym v$asm_acfs_encryption_info;
drop view v_$asm_acfs_encryption_info;
drop public synonym gv$asm_acfs_encryption_info;
drop view gv_$asm_acfs_encryption_info;

Rem ************************************************************************
Rem ACFS Security and Encryption related changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for Deferred Seg Creation related changes - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_DEFERRED_SEG_CRT;

Rem ************************************************************************
Rem Feature Usage tracking for Deferred Seg Creation related changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for Data Redaction - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_DATA_REDACTION;

Rem ************************************************************************
Rem Feature Usage tracking for Data Redaction - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for rman functionality - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_BACKUP_ENCRYPTION;
drop procedure DBMS_FEATURE_RMAN_BACKUP;
drop procedure DBMS_FEATURE_RMAN_DISK_BACKUP;
drop procedure DBMS_FEATURE_RMAN_TAPE_BACKUP;

Rem ************************************************************************
Rem Feature Usage tracking for rman functionality - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for DMU - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_DMU;

Rem ************************************************************************
Rem Feature Usage tracking for DMU - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for QOSM - BEGIN
Rem ************************************************************************

drop procedure DBMS_FEATURE_QOSM;

Rem ************************************************************************
Rem Feature Usage tracking for QOSM - END
Rem ************************************************************************

Rem ************************************************************************
Rem Feature Usage tracking for GoldenGate - BEGIN
Rem ************************************************************************

drop procedure dbms_feature_goldengate;
drop public synonym v$goldengate_capabilities;
drop view v_$goldengate_capabilities;
drop public synonym gv$goldengate_capabilities;
drop view gv_$goldengate_capabilities;
drop procedure dbms_feature_streams;
drop procedure dbms_feature_xstream_out;
drop procedure dbms_feature_xstream_in;
drop procedure dbms_feature_xstream_streams;

Rem ************************************************************************
Rem Feature Usage tracking for GoldenGate - END
Rem ************************************************************************

Rem ************************************************************************
Rem Optimizer changes - BEGIN
Rem ************************************************************************

DECLARE
  previous_version varchar2(30);

BEGIN
  SELECT prv_version INTO previous_version FROM registry$
  WHERE  cid = 'CATPROC';
 
  IF (substr(previous_version, 1, 8) < '11.2.0.2') THEN
    -- downgrade to a version prior to (not including) 11.2.0.2
    execute immediate
     'rename wri$_optstat_synopsis$ to tmp_wri$_optstat_synopsis$';

    execute immediate
      'create table wri$_optstat_synopsis$
       (synopsis#   number not null,
        hashvalue   number not null
       ) nologging
       tablespace sysaux
       pctfree 1
       enable row movement';

    execute immediate
      'insert /*+ append */ 
       into wri$_optstat_synopsis$
       select /*+ full(h) full(s) leading(h s) use_hash(h s) */
         h.synopsis#, s.hashvalue
       from tmp_wri$_optstat_synopsis$ s, 
            wri$_optstat_synopsis_head$ h
       where s.bo# = h.bo# 
         and s.group# = h.group# 
         and s.intcol# = h.intcol#';

    execute immediate
      'alter table wri$_optstat_synopsis$ logging';

    execute immediate
      'create index i_wri$_optstat_synopsis on 
       wri$_optstat_synopsis$ (synopsis#)
       tablespace sysaux';

    execute immediate
      'drop table tmp_wri$_optstat_synopsis$';
  END IF;
END;
/

drop public synonym DBA_TAB_MODIFICATIONS;

Rem ************************************************************************
Rem Optimizer changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem Hang Manager changes - BEGIN
Rem ************************************************************************

drop public synonym v$hang_info;
drop view v_$hang_info;

drop public synonym v$hang_session_info;
drop view v_$hang_session_info;

Rem ************************************************************************
Rem Hang Manger changes - END
Rem ************************************************************************

Rem ************************************************************************
Rem Hang Manger changes - BEGIN - downgrade from 11.2.0.3
Rem ************************************************************************

drop public synonym v$hang_statistics;
drop view v_$hang_statistics;

drop public synonym gv$hang_statistics;
drop view gv_$hang_statistics;

Rem ************************************************************************
Rem Hang Manger changes - END - downgrade from 11.2.0.3
Rem ************************************************************************


Rem
Rem Fast Space Usage Views.
Rem

drop public synonym v$segspace_usage ;
drop view v_$segspace_usage ;

drop public synonym gv$segspace_usage ;
drop view gv_$segspace_usage ;


Rem
Rem import callout registration table
Rem
truncate table impcalloutreg$;

Rem *************************************************************************
Rem Downgrade  AWR version
Rem *************************************************************************
Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==     to   (11gR203 and later => SWRF Version 5)    ==
Rem ==          (11gR202 and earlier => SWRF Version 4)  ==
Rem =======================================================
DECLARE
  previous_version      VARCHAR2(30);
  previous_swrf_version NUMBER;
BEGIN

   SELECT prv_version INTO previous_version FROM registry$
    WHERE  cid = 'CATPROC';

   IF previous_version < '11.2.0.3' THEN
     previous_swrf_version := 4;
   ELSE
     previous_swrf_version := 5;
   END IF;
   
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control ' ||
                    ' SET swrf_version = :prv ' 
              USING previous_swrf_version;
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

Rem *************************************************************************
Rem End Downgrade AWR version
Rem *************************************************************************

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

Rem *************************************************************************
Rem BEGIN Downgrade feature tracking 
Rem *************************************************************************

drop procedure dbms_feature_stats_incremental;

Rem *************************************************************************
Rem End Downgrade feature tracking
Rem *************************************************************************

Rem ********************************************************
Rem BEGIN SYS.DBMS_PARALLEL_EXECUTE changes via bug14296972 
Rem ********************************************************

alter table DBMS_PARALLEL_EXECUTE_TASK$ modify EDITION VARCHAR2(32);
alter table DBMS_PARALLEL_EXECUTE_TASK$ modify APPLY_CROSSEDITION_TRIGGER VARCHAR2(32);

Rem ********************************************************
Rem End SYS.DBMS_PARALLEL_EXECUTE changes via bug14296972
Rem ********************************************************

Rem *************************************************************************
Rem Consolidated Database changes - BEGIN
Rem *************************************************************************

Rem *************************************************************************
Rem Package dbms_log (Bug 10637191) - START
Rem *************************************************************************

drop package dbms_log;
drop public synonym dbms_log;

Rem *************************************************************************
Rem Package dbms_log (Bug 10637191) - END
Rem *************************************************************************

Rem *************************************************************************
Rem END   e1102000.sql
Rem *************************************************************************



Rem *************************************************************************
Rem *************************************************************************
Rem *************************** 11203 DOWNGRADE ACTIONS *********************
Rem *************************************************************************
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN Downgrade Actions for 11.2.0.3
Rem *************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for LogMiner - for downgrade from 11203
Rem*************************************************************************

drop type sys.logmnr$alwayssuplog_srecs force;
drop type sys.logmnr$alwayssuplog_srec force;
drop type sys.logmnr$intcol_arr_type force;

drop procedure sys.logmnr$alwayssuplog_proc;
drop function sys.logmnr$alwsuplog_tabf_public;

drop view  sys.logmnr$schema_allkey_suplog ;
drop public synonym logmnr$always_suplog_columns;
drop public synonym logmnr$schema_allkey_suplog;

declare
 previous_version varchar2(30);
 cnt number;
begin
  select prv_version into previous_version from registry$
  where  cid = 'CATPROC';

  select count(1) into cnt
  from con$ co, cdef$ cd, obj$ o, user$ u
  where o.name = 'SEQ$'
    and u.name = 'SYS'
    and co.name = 'SEQ$_LOG_GRP'
    and cd.obj# = o.obj#
    and cd.con# = co.con#
    and u.user# = o.owner#;

    /* 
     * Note we only drop the log group if we are downgrading below
     * 11.2.0.3, since some GoldenGate customers may already have put
     * such an ALWAYS log group in 11.2.0.3
     */

  if previous_version < '11.2.0.3.0' and cnt > 0 then
    execute immediate 'alter table sys.seq$ 
                       drop supplemental log group seq$_log_grp';
  end if;
end;
/
Rem These tables are being dropped rather than truncated because these are
Rem partitioned tables with unknown partitions.
drop table system.logmnrc_seq_gg;
drop table system.logmnrc_ind_gg;
drop table system.logmnrc_indcol_gg;
drop table system.logmnrc_con_gg;
drop table system.logmnrc_concol_gg;

Rem For bug 14378546 Logminer tables for CON$ were added.  Rather than
Rem truncate, we drop.  This avoids problem of finding all partitions.
Rem Logmnrg* table names may be used in certain cursors so best that it
Rem be dropped as well.

DROP TABLE SYSTEM.LOGMNR_CON$
/
DROP TABLE SYS.LOGMNRG_CON$
/
DROP INDEX SYSTEM.LOGMNR_I2CDEF$
/


Rem drop functions created for GG
drop function SYSTEM.LOGMNR$TAB_GG_TABF_PUBLIC;
drop function SYSTEM.LOGMNR$COL_GG_TABF_PUBLIC;
drop function SYSTEM.LOGMNR$SEQ_GG_TABF_PUBLIC;
drop function SYSTEM.LOGMNR$KEY_GG_TABF_PUBLIC;


Rem drop types created for using in GG functions
drop type SYSTEM.LOGMNR$TAB_GG_RECS force;
drop type SYSTEM.LOGMNR$COL_GG_RECS force;
drop type SYSTEM.LOGMNR$SEQ_GG_RECS force;
drop type SYSTEM.LOGMNR$KEY_GG_RECS force;

drop type SYSTEM.LOGMNR$TAB_GG_REC force;
drop type SYSTEM.LOGMNR$COL_GG_REC force;
drop type SYSTEM.LOGMNR$SEQ_GG_REC force;
drop type SYSTEM.LOGMNR$KEY_GG_REC force;

Rem ************************************************************************
Rem End Changes for LogMiner - for downgrade from 11203
Rem ************************************************************************

Rem*************************************************************************
Rem BEGIN Changes for dbms_lobutil_lobmap_t - for downgrade from 11203
Rem*************************************************************************

DROP TYPE dbms_lobutil_dedupset_t FORCE;
DROP PUBLIC SYNONYM dbms_lobutil_dedupset_t;

Rem*************************************************************************
Rem END Changes for dbms_lobutil_lobmap_t - for downgrade from 11203
Rem*************************************************************************

Rem ************************************************************************
Rem BEGIN dbms_sql2 changes - for downgrade from 11202 and 12.1
Rem ************************************************************************
drop public synonym dbms_sql2;
drop package dbms_sql2;

Rem *************************************************************************
Rem BEGIN dbfs export/import downgrade
Rem *************************************************************************

Rem delete procedural action registrations

delete
from    sys.exppkgact$
where   package = 'DBMS_DBFS_SFS_ADMIN'
    and schema  = 'SYS';

delete
from    sys.expdepact$
where   package = 'DBMS_DBFS_SFS_ADMIN'
    and schema  = 'SYS';

commit;

Rem *************************************************************************
Rem END dbfs export/import downgrade
Rem *************************************************************************

Rem ************************************************************************
Rem Online redef changes - BEGIN
Rem ************************************************************************

drop package dbms_redefinition_internal;


Rem *************************************************************************
Rem BEGIN Changes to catsqlt for RAT Masking
Rem *************************************************************************

Rem 1. Set the values of the 2 new columns in sts plans table to null
update wri$_sqlset_plans 
set flags = null,
    masked_binds_flag = null;

Rem 2. Truncate all new catalog objects created in this txn
truncate table wrr$_masking_definition;

truncate table wrr$_masking_parameters;

truncate table wri$_sts_granules;

truncate table wri$_sts_sensitive_sql;

truncate table wri$_masking_script_progress;

truncate table  wri$_sts_masking_step_progress;

truncate table wrr$_masking_file_progress;

truncate table wrr$_masking_bind_cache;

truncate table wri$_sts_masking_errors;

truncate table  wri$_sts_masking_exceptions;

drop sequence wri$_sqlset_ratmask_seq;

Rem 3. Drop program units
drop package body dbms_rat_mask;
drop package dbms_rat_mask;
drop public synonym dbms_rat_mask;

Rem *************************************************************************
Rem END Changes to catsqlt for RAT Masking
Rem *************************************************************************

Rem ************************************************************************
Rem Online redef changes - END
Rem ************************************************************************

--File rdbms/admin/catmntr.sql

truncate table wri$_tracing_enabled;
alter table wri$_tracing_enabled modify qualifier_id1 varchar2(48);
alter table wri$_tracing_enabled modify qualifier_id2 varchar2(32);

Rem ************************************************************************
Rem Changes for Pillar/ ZFS HCC feature tracking - BEGIN
Rem ************************************************************************

drop library dbms_storage_type_lib;
drop procedure kdzstoragetype;
drop procedure dbms_feature_zfs_storage;
drop procedure dbms_feature_pillar_storage;
drop procedure dbms_feature_zfs_ehcc;
drop procedure dbms_feature_pillar_ehcc;

Rem ************************************************************************
Rem Changes for Pillar/ ZFS HCC feature tracking  - END
Rem ************************************************************************

drop public synonym dba_sscr_capture;
drop public synonym dba_sscr_restore;


drop sequence sys.awlogseq$;

Rem *************************************************************************
Rem Begin Datapump changes. Bug 12853348 / 14530180
Rem ************************************************************************* 
drop table fga_log$for_export_tbl;
drop view fga_log$for_export;
drop table audtab$tbs$for_export_tbl;
drop view audtab$tbs$for_export;
drop view ku$_all_tsltz_tables;
drop view ku$_all_tsltz_tab_cols;
Rem *************************************************************************
Rem End Datapump changes
Rem ************************************************************************* 

Rem =======================================================================
Rem  Bug #14162791 : enhancement to utl_recomp
Rem =======================================================================
drop view utl_recomp_invalid_mv;
Rem =======================================================================
Rem  End Changes for Bug #14162791
Rem =======================================================================  

Rem *************************************************************************
Rem END Downgrade Actions for 11.2.0.3
Rem ************************************************************************* 

INSERT INTO sys.noexp$ (owner, name, obj_type)
  (SELECT u.name, 'AW$'||a.awname, 2
     FROM sys.aw$ a, sys.user$ u
    WHERE awseq# >= 1000 AND u.user#=a.owner#)
/

Rem *************************************************************************
Rem VOS Downgrade - BEGIN
Rem ************************************************************************* 
drop public synonym v$dead_cleanup;
drop public synonym gv$dead_cleanup;
drop view v_$dead_cleanup;
drop view gv_$dead_cleanup;
Rem *************************************************************************
Rem VOS Downgrade - END
Rem ************************************************************************* 

Rem *************************************************************************
Rem Exadata Downgrade - START
Rem *************************************************************************

drop public synonym v$cell_ofl_thread_history;
drop view v_$cell_ofl_thread_history;
drop public synonym gv$cell_ofl_thread_history;
drop view gv_$cell_ofl_thread_history;

Rem *************************************************************************
Rem Exadata Downgrade - END
Rem *************************************************************************


drop public synonym get_oldversion_hashcode2
/

drop function get_oldversion_hashcode2
/


Rem *************************************************************************
Rem BEGIN drop for CLONEDFILE
Rem *************************************************************************

drop public synonym v$clonedfile;
drop view v_$clonedfile;
drop public synonym gv$clonedfile;
drop view gv_$clonedfile;

Rem *************************************************************************
Rem END drop for CLONEDFILE
Rem *************************************************************************


Rem *************************************************************************
Rem Downgrade GV$AUTO_BMR_STATISTICS - START
Rem *************************************************************************

drop public synonym gv$auto_bmr_statistics;
drop view gv_$auto_bmr_statistics;

Rem *************************************************************************
Rem Downgrade GV$AUTO_BMR_STATISTICS - END
Rem *************************************************************************

Rem *************************************************************************
Rem KSR Channel Waits - BEGIN
Rem *************************************************************************
drop public synonym gv$channel_waits;
drop view gv_$channel_waits;
drop public synonym v$channel_waits;
drop view v_$channel_waits;
Rem *************************************************************************
Rem KSR Channel Waits - END
Rem *************************************************************************


Rem *************************************************************************
Rem BEGIN : Delete default user-password entries from sys.default_pwd$
Rem *************************************************************************

delete from SYS.DEFAULT_PWD$  where user_name='OWBSYS_AUDIT' and pwd_verifier='FD8C3D14F6B60015';

Rem *************************************************************************
Rem END : Delete Default user-password entries from sys.default_pwd$
Rem *************************************************************************


Rem *************************************************************************
Rem Downgrade [G]V$FS_OBSERVER_HISTOGRAM - BEGIN
Rem *************************************************************************
drop public synonym v$fs_observer_histogram;
drop view v_$fs_observer_histogram;
drop public synonym gv$fs_observer_histogram;
drop view gv_$fs_observer_histogram;
Rem *************************************************************************
Rem Downgrade [G]V$FS_OBSERVER_HISTOGRAM - END
Rem *************************************************************************


Rem ******** dbms_scn
drop public synonym dbms_scn;
drop package body sys.dbms_scn;
drop package sys.dbms_scn;
drop library dbms_scn_lib;
