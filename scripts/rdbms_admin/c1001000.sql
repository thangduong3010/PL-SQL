Rem
Rem $Header: rdbms/admin/c1001000.sql /st_rdbms_11.2.0/1 2011/03/21 21:41:34 yberezin Exp $
Rem
Rem c1001000.sql
Rem
Rem Copyright (c) 1999, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      c1001000.sql - upgrade Oracle RDBMS from 10.1.0 to the new release
Rem
Rem    DESCRIPTION
Rem      Put any dictionary related changes here (ie-create, alter,
Rem      update,...).  If you must upgrade using PL/SQL packages, 
Rem      put the PL/SQL block in a1001000.sql since catalog.sql and 
Rem      catproc.sql will be run before a1001000.sql is invoked.
Rem
Rem      This script is called from u1001000.sql and c0902000.sql
Rem
Rem      This script performs the upgrade in the following stages:
Rem        STAGE 1: upgrade from 10.1.0 to 10.2.0
Rem        STAGE 2: call catalog.sql and catproc.sql
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yberezin    03/21/11 - Backport yberezin_bug-10398280 from main
Rem    vaselvap    02/05/10 - Fix for bug 7246231
Rem    dvoss       08/22/08 - bug 7036453 - delete from logmnr_log$ too slow
Rem    gagarg      03/10/08 - Add event 10851 to enable DDL on AQ tables
Rem    cdilling    10/04/07 - fix up TABLE_PRIVILEGE_MAP
Rem    pbelknap    05/07/07 - #5999827 - set STS owner in adv table
Rem    rburns      04/30/07 - fix execute immediates
Rem    dvoss       01/25/07 - fix logmnr lob settings
Rem    dvoss       01/24/07 - move logmnrt_mddl
Rem    dvoss       01/22/07 - fix logmnr_log$ pk
Rem    dvoss       01/04/07 - logminer upgrade split
Rem    jawilson    03/08/06 - 5049756: change sys.aq$_descriptor queue name 
Rem                           length 
Rem    rburns      11/10/05 - move duc$ truncate
Rem    cdilling    10/03/05 - move session_history changes to c1002000.sql 
Rem    qyu         08/09/05 - #4508836: reverse #3979461 fix 
Rem    adagarwa    04/25/05 - added plsql columns to wrh$_active_sess_history
Rem    cdilling    06/08/05 - call c1002000 
Rem    mmpandey    06/07/05 - 4390808: increase the cache value in audses$
Rem    pthornto    06/20/05 - correct revoke statments for CONNECT 
Rem    mlfeng      05/31/05 - fix null column with re-upgrade
Rem    mlfeng      05/25/05 - bug 4393879: disable metrics constraints 
Rem    dalpern     05/18/05 - 4180912: improved info in PLSQL_TRACE_EVENTS 
Rem    bpwang      05/20/05 - Bug 4382313: Zero out flags in streams$_prepare*
Rem    mlfeng      05/19/05 - fix AWR upgrade issues
Rem    ssvemuri    05/16/05 - increase the row_id member size in chnf$_rdesc
Rem    mvemulap    05/13/05 - lrg 1852422 fix 
Rem    ajadams     05/09/05 - dbms_logstdby_public package depricated 
Rem    pbelknap    05/02/05 - wri$_adv_sqlt_rtn_plan constraint name change 
Rem    mvemulap    05/03/05 - bug fix for 4318925 
Rem    qyu         04/28/05 - #4280015: update array_index col name 
Rem    mhho        04/20/05 - change colklc column size in enc$ 
Rem    ksurlake    04/22/05 - add constructor for aq$_reg_info
Rem    mlfeng      04/11/05 - add column to wrh$_sqlstat 
Rem    adagarwa    03/24/05 - added new columns to wrh$_active_sess_history
Rem    tfyu        03/17/05 - Bug 4262763
Rem    htran       03/11/05 - remove transportable from fgr$_tablespace_info
Rem    lkaplan     03/18/05 - bug 4112826 - upgrade and downgrade of 
Rem                           catqueue.sql needed 
Rem    bvaranas    03/15/05 - Upgrade script for bug 4186885 - sync partition 
Rem                           numbers for overflow partitions with base 
Rem                           table partitions 
Rem    rburns      03/14/05 - use dbms_registry_sys timestamp 
Rem    wyang       03/02/05 - add columns to wrh&undostat 
Rem    alakshmi    02/23/05 - error recovery for maintain_ apis
Rem    bdagevil    02/24/05 - increase maximum line size for dbms_xplan 
Rem    mtao        02/16/05 - Bug 4189150, remove logmnr_log$_active index
Rem    jmallory    02/02/05 - Drop dbms_dbupgrade 
Rem    mture       01/19/05 - 3979461: revoke public exec priv for xml funcs
Rem                           and drop AggXMLInputType
Rem    evoss       01/18/05 - scheduler_run_details cpu_used datatype change 
Rem    ddas        01/11/05 - #(4052436) add hint_string to outln.ol$hints 
Rem    sourghos    01/06/05 - 
Rem    elu         01/03/05 - apply spilling 
Rem    sourghos    12/30/04 - Fix bug 4043119 
Rem    ilyubash    11/05/04 - Add gen column to i_aw_prop$ index 
Rem    htran       11/16/04 - streams$_prepare_*: add spare2 and flags columns
Rem    apadmana    10/05/04 - bug3607838: manage any queue
Rem    rpfau       11/17/04 - Add revoke and drop synonym for the utl_xml 
Rem                           package. 
Rem    clei        11/15/04 - lrg 1796684 delete old privs before reuse
Rem    clei        10/28/04 - add merger [any] view permission
Rem    kyagoub     10/10/04 - add other column to advisor objects table 
Rem    mlfeng      09/03/04 - add indexes to AWR tables
Rem    rgmani      10/26/04 - scheduler attributes table has new columns 
Rem    jgalanes    10/15/04 - 3651756 revoke SELECT on exu?lnk from 
Rem                           SELECT_CATALOG_ROLE 
Rem    mxyang      09/27/04 - insert rows for plsql_ccflags in settings$
Rem    rramkiss    09/21/04 - security bug #3897723 
Rem    arithikr    09/13/04 - 3877613 - create index atempind$ 
Rem    mtakahar    09/03/04 - #(3350342) create mon_mods_all$
Rem    rburns      09/02/04 - remove serveroutput 
Rem    jnarasin    08/02/04 - EUS Proxy auditing changes 
Rem    mlfeng      07/29/04 - modifications for AWR tables 
Rem    xuhuali     06/30/04 - audit java 
Rem    pbelknap    07/16/04 - AWR report types 
Rem    kyagoub     08/03/04 - add new column diret_writes to 
Rem                           wri$_adv_sqlt_statistics 
Rem    rjenkins    08/11/04 - 3074260: func indexes should use REF 
Rem                           dependencies 
Rem    jnesheiw    08/03/04 - Revoke CONNECT role from LOGSTDBY_ADMINISTRATOR 
Rem    rramkiss    04/21/04 - add CREATE EXTERNAL JOB system privilege 
Rem    kdias       07/21/04 - privs for OUTLN user 
Rem    nmanappa    07/20/04 - bug 3690876 - clean privs 194-199,239,240
Rem    rburns      07/15/04 - remove dbms_output compiles 
Rem    dmwong      07/21/04 - remove old priv. from connect 
Rem    skaluska    07/09/04 - split tsm_hist$ into tsm_src$, tsm_dst$ 
Rem    pbelknap    07/14/04 - rerun case for STS changes 
Rem    araghava    07/07/04 - (3748430): make partitioning indexes unique 
Rem    clei        07/07/04 - add enc$ for Transparent Column Encryption
Rem    pbelknap    06/29/04 - move sqlt block to 'a' script 
Rem    pbelknap    06/29/04 - upgrade_regress errors 
Rem    pbelknap    06/28/04 - add plan_hash_value to mask table 
Rem    nbhatt      06/11/04 - add delivery mode to message_properties_t 
Rem    hxlin       06/28/04 - upgrade sql response time 
Rem    ajadams     06/20/04 - add index to logstdby events table 
Rem    rburns      06/18/04 - remove final timestamp 
Rem    veeve       06/16/04 - increase size of WRH$_ASH.PROGRAM
Rem    sbalaram    06/14/04 - Bug 3676284: drop dbms_streams_xml_lcr_utl pkg
Rem    mramache    05/28/04 - upgrade awr report types 
Rem    pbelknap    06/25/04 - add timestamp to plans table 
Rem    pbelknap    06/11/04 - add deltas for capture 
Rem    pbelknap    05/14/04 - SQLSET_ROW change 
Rem    pbelknap    05/12/04 - SQL tuning set schema changes 
Rem    ssvemuri    06/15/04 - Change notification dictionary and types
Rem    ahwang      06/10/04 - add restore point audit_actions rows
Rem    mlfeng      05/21/04 - upgrade wr_control with topnsql
Rem    ksurlake    06/01/04 - Evolve reg$ and related types
Rem    bdagevil    06/03/04 - increase size of object_node 
Rem    rvissapr    05/05/04 - add upgrade for dblink pwd encoding 
Rem    vakrishn    06/01/04 - add status column to WRH$_UNDOSTAT
Rem    veeve       05/28/04 - add WRH$_SEG_STAT_OBJ.[INDEX_TYPE,BASE*]
Rem    rramkiss    05/31/04 - update name column of scheduler$_event_log 
Rem    rramkiss    05/13/04 - truncate obsoleted scheduler chains data
Rem    liwong      06/09/04 - Add get_source_time 
Rem    liwong      06/08/04 - Add oldest_transaction_id 
Rem    dcassine    05/27/04 - changed streams$_apply_process
Rem    dsemler     05/14/04 - add dtp support 
Rem    bdagevil    05/26/04 - generalize timestamp column in explain plan 
Rem    bdagevil    05/24/04 - new other_xml in plan table 
Rem    veeve       05/06/04 - blocking_session,xid columns in ASH 
Rem    mlfeng      05/18/04 - update swrf_version in wr_control 
Rem    skaluska    05/05/04 - merge to MAIN 
Rem    skaluska    04/28/04 - sync with RDBMS_MAIN_SOLARIS_040426 
Rem    jciminsk    04/28/04 - merge from RDBMS_MAIN_SOLARIS_040426 
Rem    skaluska    04/15/04 - TSM modifications 
Rem    lchidamb    04/09/04 - merge 
Rem    jciminsk    04/09/04 - merge from RDBMS_MAIN_SOLARIS_040405 
Rem    lchidamb    03/23/04 - add director history/reason table 
Rem    skaluska    03/30/04 - instance SID in tsm_hist$ 
Rem    skaluska    03/18/04 - move TSM changes from c0902000.sql to 
Rem    jciminsk    03/04/04 - move grid from c0902000 
Rem    ckantarj    02/27/04 - add cardinality columns to service$ 
Rem    jstamos     02/25/04 - director indexes 
Rem    mxiao       05/13/04 - add chdlevid# to dimjoinkey$ 
Rem    weiwang     03/09/04 - rules upgrade change 
Rem    lkaplan     02/22/04 - generic lob assembly 
Rem    rgmani      05/19/04 - Upgrade for scheduler 
Rem    smuthuli    05/18/04 - one more stat to seg_stat 
Rem    vmedi       05/04/04 - bugfix 3431498: drop extract & existsnode op
Rem    htran       04/22/04 - file group tables
Rem    alakshmi    04/19/04 - system privilege READ_ANY_FILE_GROUP 
Rem    gssmith     04/20/04 - Adding new member to advisor type 
Rem    sbodagal    04/14/04 - ADD a column TO dimlevel$
Rem    dsemler     04/13/04 - upgrade service$ for 10g2 
Rem    rburns      04/07/04 - add scripts for release upgrade 
Rem    jmzhang     05/12/04 - alter column datatype to system.logstdby$events
Rem                         - add columns to system.logstdby$apply_milestone
Rem                         - add columns to system.logstdby$apply_progress
Rem    mlfeng      04/26/04 - p1, p2, p3 for event name 
Rem    rburns      03/26/04 - invalidate MVs 
Rem    mxiao       03/30/04 - add columns to Materialized View metadata
Rem    arithikr    03/29/04 - 3473968 - correct mispell privilege 
Rem    mbrey       04/08/04 - CDC meta changes for sequences 
Rem    mbrey       03/30/04 - CDC change sources/propagations 
Rem    ayoaz       03/03/04 - add index on type$.hashcode
Rem    clei        03/02/04 - remove encryption profiles
Rem    bpwang      02/09/04 - Upgrade apply$_error 
Rem    alakshmi    02/24/04 - insert new system privileges for file groups 
Rem    pbelknap    02/12/04 - case-sensitive sqlset definitions 
Rem    mlfeng      02/03/04 - awr seg stat and rac changes 
Rem    sbalaram    02/03/04 - add apply$_error_txn
Rem    gssmith     02/11/04 - Advisor Framework changes 
Rem    rburns      01/16/04 - rburns_add_10_1_updw_scripts 
Rem    rburns      01/07/04 - Created

Rem=========================================================================
Rem BEGIN STAGE 1: upgrade from 10.1.0 to 10.2
Rem=========================================================================

Rem=========================================================================
Rem Begin Advisor Framework upgrade items 
Rem=========================================================================

alter table sys.wri$_adv_recommendations add (flags number);
alter table sys.wri$_adv_def_parameters add (description varchar2(9));
alter table sys.wri$_adv_parameters add (description varchar2(9));
alter table sys.wri$_adv_sqlt_plans add (other_xml clob);
alter table sys.wri$_adv_objects add (other clob);

alter type wri$_adv_abstract_t
  add member procedure sub_implement(task_id in number, 
                                     rec_id in number,
                                     exit_on_error number)
  cascade;

alter type wri$_adv_sqlaccess_adv
  add overriding member procedure sub_implement(task_id in number, 
                                                rec_id in number,
                                                exit_on_error number)
  cascade;

alter type wri$_adv_tunemview_adv
  add overriding member procedure sub_implement(task_id in number, 
                                                rec_id in number,
                                                exit_on_error number)
  cascade;

Rem=========================================================================
Rem End Advisor Framework upgrade items 
Rem=========================================================================

Rem=========================================================================
Rem Add new system privileges here 
Rem=========================================================================

delete from SYSAUTH$ where privilege# = -233;
delete from SYSTEM_PRIVILEGE_MAP where privilege = -233;
delete from audit$ where option# = 233;

insert into SYSTEM_PRIVILEGE_MAP values (-233, 'MERGE ANY VIEW', 0);
insert into SYSTEM_PRIVILEGE_MAP values (-276, 'MANAGE FILE GROUP', 1);
insert into SYSTEM_PRIVILEGE_MAP values (-277, 'MANAGE ANY FILE GROUP', 1);
insert into SYSTEM_PRIVILEGE_MAP values (-278, 'READ ANY FILE GROUP', 1);
insert into  SYSTEM_PRIVILEGE_MAP values (-279, 'CHANGE NOTIFICATION', 0);
insert into  SYSTEM_PRIVILEGE_MAP values (-280, 'CREATE EXTERNAL JOB', 0);
grant all privileges, analyze any dictionary to dba with admin option;

delete from SYSTEM_PRIVILEGE_MAP
  where privilege in (-194, -195, -196, -197, -198, -199,
                      -229, -230, -231, -232,
                      -239, -240);

delete from STMT_AUDIT_OPTION_MAP
  where option# in (194, 195, 196, 197, 198, 199,
                    239, 240);

update SYSTEM_PRIVILEGE_MAP set name = 'GRANT ANY OBJECT PRIVILEGE' 
  where privilege=-244; 
update STMT_AUDIT_OPTION_MAP set name = 'GRANT ANY OBJECT PRIVILEGE' 
  where option#=244; 

delete from sysauth$ where privilege# in (-194, -195, -196, -197, -198, -199,
                                          -229, -230, -231, -232, -239, -240);

delete from audit$ where option# in (194, 195, 196, 197, 198, 199, 
                                     229, 230, 231, 232, 239, 240);
BEGIN
  EXECUTE IMMEDIATE
   'REVOKE CONNECT from LOGSTDBY_ADMINISTRATOR';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE IN (-1917, -1918, -1919, -1951, -1952) THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

Rem=========================================================================
Rem Add new object privileges here
Rem=========================================================================

insert into TABLE_PRIVILEGE_MAP values (28, 'MERGE VIEW');

Rem===========================================================================
Rem Grant CREATE EXTERNAL JOB to all users with CREATE JOB (for compatibility)
Rem==========================================================================

DECLARE
  TYPE user_clause IS RECORD (grantee varchar(30), admin varchar(30));
  TYPE varchartab IS TABLE OF user_clause;
  user_clauses varchartab;
  i PLS_INTEGER;
BEGIN

  SELECT grantee,
    decode(admin_option,'YES',' WITH ADMIN OPTION','') as admin
  BULK COLLECT INTO user_clauses FROM dba_sys_privs
  WHERE PRIVILEGE='CREATE JOB';

  FOR i IN user_clauses.FIRST ..  user_clauses.LAST
  LOOP
    EXECUTE IMMEDIATE 'GRANT CREATE EXTERNAL JOB TO ' || 
             dbms_assert.enquote_name(user_clauses(i).grantee, FALSE) ||
             user_clauses(i).admin;
  END LOOP;
END;
/

Rem=========================================================================
Rem Removal old privileges from CONNECT role
Rem=========================================================================
BEGIN
  EXECUTE IMMEDIATE 'REVOKE ALTER SESSION FROM CONNECT';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1952 THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE SYNONYM FROM CONNECT';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1952 THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE VIEW FROM CONNECT';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1952 THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE DATABASE LINK FROM CONNECT';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1952 THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE TABLE FROM CONNECT';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1952 THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE CLUSTER FROM CONNECT';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1952 THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE CREATE SEQUENCE FROM CONNECT';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1952 THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem=========================================================================
Rem Revoke SELECT on exu?lnk FROM SELECT_CATALOG_ROLE
Rem=========================================================================
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON sys.exu9lnk FROM SELECT_CATALOG_ROLE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON sys.exu8lnk FROM SELECT_CATALOG_ROLE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/
BEGIN
  EXECUTE IMMEDIATE 'REVOKE SELECT ON sys.exu7lnk FROM SELECT_CATALOG_ROLE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -942, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem=========================================================================
Rem Add new audit options here 
Rem=========================================================================

insert into STMT_AUDIT_OPTION_MAP values (233, 'MERGE ANY VIEW', 0);
insert into STMT_AUDIT_OPTION_MAP values (276, 'MANAGE FILE GROUP', 0);
insert into STMT_AUDIT_OPTION_MAP values (277, 'MANAGE ANY FILE GROUP', 0);
insert into STMT_AUDIT_OPTION_MAP values (278, 'READ ANY FILE GROUP', 0);
insert into STMT_AUDIT_OPTION_MAP values (279, 'CHANGE NOTIFICATION', 0);
insert into STMT_AUDIT_OPTION_MAP values (280, 'CREATE EXTERNAL JOB', 0);

insert into STMT_AUDIT_OPTION_MAP values (93, 'CREATE JAVA SOURCE', 0);
insert into STMT_AUDIT_OPTION_MAP values (94, 'CREATE JAVA CLASS', 0);
insert into STMT_AUDIT_OPTION_MAP values (95, 'CREATE JAVA RESOURCE', 0);
insert into STMT_AUDIT_OPTION_MAP values (96, 'ALTER JAVA SOURCE', 0);
insert into STMT_AUDIT_OPTION_MAP values (97, 'ALTER JAVA CLASS', 0);
insert into STMT_AUDIT_OPTION_MAP values (98, 'ALTER JAVA RESOURCE', 0);
insert into STMT_AUDIT_OPTION_MAP values (99, 'DROP JAVA SOURCE', 0);
insert into STMT_AUDIT_OPTION_MAP values (100, 'DROP JAVA CLASS', 0);
insert into STMT_AUDIT_OPTION_MAP values (101, 'DROP JAVA RESOURCE', 0);

update STMT_AUDIT_OPTION_MAP set property = 0
  where option# = 218 and name = 'MANAGE ANY QUEUE'; 
update STMT_AUDIT_OPTION_MAP set property = 0
  where option# = 219 and name = 'ENQUEUE ANY QUEUE'; 
update STMT_AUDIT_OPTION_MAP set property = 0
  where option# = 220 and name = 'DEQUEUE ANY QUEUE'; 

insert into STMT_AUDIT_OPTION_MAP values (245, 'CREATE EVALUATION CONTEXT', 0);
insert into STMT_AUDIT_OPTION_MAP
   values (246, 'CREATE ANY EVALUATION CONTEXT', 0);
insert into STMT_AUDIT_OPTION_MAP
   values (247, 'ALTER ANY EVALUATION CONTEXT', 0);
insert into STMT_AUDIT_OPTION_MAP
   values (248, 'DROP ANY EVALUATION CONTEXT', 0);
insert into STMT_AUDIT_OPTION_MAP
   values (249, 'EXECUTE ANY EVALUATION CONTEXT', 0);
insert into STMT_AUDIT_OPTION_MAP values (250, 'CREATE RULE SET', 0);
insert into STMT_AUDIT_OPTION_MAP values (251, 'CREATE ANY RULE SET', 0);
insert into STMT_AUDIT_OPTION_MAP values (252, 'ALTER ANY RULE SET', 0);
insert into STMT_AUDIT_OPTION_MAP values (253, 'DROP ANY RULE SET', 0);
insert into STMT_AUDIT_OPTION_MAP values (254, 'EXECUTE ANY RULE SET', 0);
insert into STMT_AUDIT_OPTION_MAP values (257, 'CREATE RULE', 0);
insert into STMT_AUDIT_OPTION_MAP values (258, 'CREATE ANY RULE', 0);
insert into STMT_AUDIT_OPTION_MAP values (259, 'ALTER ANY RULE', 0);
insert into STMT_AUDIT_OPTION_MAP values (260, 'DROP ANY RULE', 0);
insert into STMT_AUDIT_OPTION_MAP values (261, 'EXECUTE ANY RULE', 0);

Rem=========================================================================
Rem Add new audit_actions rows here 
Rem=========================================================================

-- add restore point related rows

insert into audit_actions values (206, 'CREATE RESTORE POINT');
insert into audit_actions values (207, 'DROP RESTORE POINT');

-- add single session proxy related rows

insert into audit_actions values (208, 'PROXY AUTHENTICATION ONLY') ;

Rem=========================================================================
Rem Drop views removed from last release here 
Rem Remove obsolete dependencies for any fixed views in i1001000.sql
Rem=========================================================================
drop view DBA_HIST_CLASS_CACHE_TRANSFER;
drop public synonym DBA_HIST_CLASS_CACHE_TRANSFER;

Rem=========================================================================
Rem Drop packages removed from last release here 
Rem=========================================================================

drop package DBMS_STREAMS_XML_LCR_UTL;
drop package DBMS_DBUPGRADE;
drop package DBMS_LOGSTDBY_PUBLIC;

Rem=========================================================================
Rem For the 10.1 to 10.2 upgrade, utlip.sql is NOT run as part of the 
Rem upgrade since PL/SQL objects do not need to be recompiled.  Any other
Rem types of objects that need to be invalidated should be include here.
Rem=========================================================================

Rem Invalite Materialized Views
update obj$ set status = 5 where type# = 42;
commit;

Rem=========================================================================
Rem Add changes to sql.bsq dictionary tables here 
Rem=========================================================================

Rem Recreate atempind$ just in case it did not get create by c0800050.sql
Rem ORA-00955 if the index is already created.
create index atempind$ on atemptab$(id)
              /* indexes backing up workspaces on disk claim to be atempind$ */
/

Rem
Rem Add generation number to i_aw_prop$ index

begin
  execute immediate 'drop index sys.i_aw_prop$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create index sys.i_aw_prop$
  on sys.aw_prop$ (awseq#, oid, propname, gen#)
  tablespace sysaux
/


Rem 
Rem Add cardinality columns to service$

ALTER TABLE service$ ADD
(
  min_cardinality    number,                                  /* cardinality */
  max_cardinality    number,
  goal               number,                                 /* service goal */
                                                                 /* none : 0 */
                                                         /* service time : 1 */
                                                             /* throughput : 2 */
  flags              number                       /* service attribute flags */
                                                       /* GRID enabled : 0x1 */
                                                        /* DTP service : 0x2 */
);

Rem
Rem director changes

begin
  execute immediate 'drop index sys.i_dir$migrate_ui';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index sys.i_dir$migrate_ui
  on sys.dir$migrate_operations(job_name, status)
  tablespace sysaux
/

create index sys.i_dir$migrate_status
  on sys.dir$migrate_operations(status)
  tablespace sysaux
/

begin
  execute immediate 'drop index sys.i_dir$service_ui';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index sys.i_dir$service_ui
  on sys.dir$service_operations(job_name, status)
  tablespace sysaux
/

create index sys.i_dir$service_status
  on sys.dir$service_operations(status)
  tablespace sysaux
/

begin
  execute immediate 'drop index sys.i_dir$quiesce_ui';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index sys.i_dir$quiesce_ui
  on sys.dir$quiesce_operations(job_name, status)
  tablespace sysaux
/

begin
  execute immediate 'drop index sys.i_dir$resonate_ui';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index sys.i_dir$resonate_ui
  on sys.dir$resonate_operations(job_name, status)
  tablespace sysaux
/

begin
  execute immediate 'drop index i_dir$escalate_ui';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index sys.i_dir$escalate_ui
  on sys.dir$escalate_operations(escalation_id, status)
  tablespace sysaux
/

create index sys.i_dir$escalate_status
  on sys.dir$escalate_operations(status)
  tablespace sysaux
/

begin
  execute immediate 'drop index sys.i_dir$db_attributes_ui';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index sys.i_dir$db_attributes_ui
  on sys.dir$database_attributes(database_name, attribute_name)
  tablespace sysaux
/

begin
  execute immediate 'drop index sys.i_dir$service_attributes_serv';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index sys.i_dir$service_attributes_ui
  on sys.dir$service_attributes(service_id, attribute_name)
  tablespace sysaux
/

rem table used by director for keeping alert history
create table dir$alert_history
( 
   alert_name       varchar2(200),
   message_level    number,
   action_id        number,
   reason_id        number,
   last_time        date,
   next_time        date,
   action_time      date,
   incarnation_info varchar2(4000),
   job_name         varchar2(100),
   sparen1          number,
   sparen2          number,
   sparen3          number,
   sparen4          number,
   sparen5          number,
   sparevc1         varchar2(4000),
   sparevc2         varchar2(4000),
   sparevc3         varchar2(4000),
   sparevc4         varchar2(4000),
   sparevc5         varchar2(4000))
tablespace sysaux
/

create index sys.i_dir$alert_history_name
  on sys.dir$alert_history(alert_name)
  tablespace sysaux
/
create index sys.i_dir$alert_history_action_id
  on sys.dir$alert_history(action_id)
  tablespace sysaux
/
create index sys.i_dir$alert_history_reason_id
  on sys.dir$alert_history(reason_id)
  tablespace sysaux
/
create index sys.i_dir$alert_history_at
  on sys.dir$alert_history(action_time)
  tablespace sysaux
/

rem table used by director for keeping reasons
create table dir$reason_strings
( 
   reason_id        number,
   reason           varchar2(4000),
   sparen1          number,
   sparen2          number,
   sparevc1         varchar2(4000),
   sparevc2         varchar2(4000))
tablespace sysaux
/

create unique index sys.i_dir$reason_strings_ui
  on sys.dir$reason_strings(reason_id)
  tablespace sysaux
/

Rem 
Rem TSM (transparent session migration)
Rem

begin 
  execute immediate 'drop index i_tsm_hist1'; 
exception 
   when others then 
      if sqlcode = -1418 then null; 
      else raise; 
      end if; 
end; 
/
drop table tsm_hist$;
/
create table tsm_src$
(
  /* the following are set by start_migration */
  src_db_name               varchar2(4000),                /* source db name */
  src_inst_name             varchar2(4000),          /* source instance name */
  src_inst_id               varchar2(4000),            /* source instance id */
  src_inst_start_time       timestamp with time zone,
                                           /* start time for source instance */
  sequence#                 number,             /* migration sequence number */
  src_sid                   number,         /* session id on source instance */
  src_serial#               number,            /* serial# on source instance */
  src_state                 number,                       /* migration state */
  connect_string            varchar2(4000),    /* destination connect string */
  src_start_time            timestamp with time zone,/* migration start time */
  /* the following are updated by source session */
  cost                      number,              /* estimated migration cost */
  failure_reason            number,       /* reason for failure of migration */
  src_end_time              timestamp with time zone,  /* migration end time */
  roundtrips                number, /* number of roundtrips during migration */
  src_userid                number,                               /* user id */
  src_schemaid              number,                             /* schema id */
  dst_db_name               varchar2(4000)            /* destination db name */
)
tablespace SYSAUX
/
create index i_tsm_src1$ on tsm_src$(sequence#)
tablespace SYSAUX
/
create index i_tsm_src2$ on tsm_src$(src_sid, src_serial#, sequence#)
tablespace SYSAUX
/
create table tsm_dst$
(
  src_db_name               varchar2(4000),                /* source db name */
  dst_db_name               varchar2(4000),           /* destination db name */
  dst_inst_name             varchar2(4000),     /* destination instance name */
  dst_inst_id               varchar2(4000),       /* destination instance id */
  dst_inst_start_time       timestamp with time zone,
                                      /* start time for destination instance */
  sequence#                 number,             /* migration sequence number */
  dst_sid                   number,    /* session id on destination instance */
  dst_serial#               number,       /* serial# on destination instance */
  dst_start_time            timestamp with time zone,/* migration start time */
  dst_end_time              timestamp with time zone,  /* migration end time */
  dst_userid                number,                               /* user id */
  dst_schemaid              number,                             /* schema id */
  dst_state                 number            /* destination migration state */
)
tablespace SYSAUX
/
create index i_tsm_dst1$ on tsm_dst$(sequence#)
tablespace SYSAUX
/
create index i_tsm_dst2$ on tsm_dst$(dst_sid, dst_serial#, sequence#)
tablespace SYSAUX
/
create sequence tsm_mig_seq$
  increment by 1
  start with 1
  minvalue 0
  nomaxvalue
  cache 10
  order
  nocycle
/
  
Rem Add columns to Materialized View metadata
ALTER TABLE snap$   ADD(syn_count  INTEGER);
ALTER TABLE sumdep$ ADD(syn_own    VARCHAR2(30));
ALTER TABLE sumdep$ ADD(syn_name   VARCHAR2(30));
ALTER TABLE sumdep$ ADD(syn_master NUMBER);
ALTER TABLE sumdep$ ADD(vw_query LONG);
ALTER TABLE sumdep$ ADD(vw_query_len NUMBER);
UPDATE snap$   SET syn_count  = 0;
UPDATE sumdep$ SET syn_master = 0;
UPDATE sumdep$ SET vw_query_len = 0;

Rem Begin streams changes.
-- add lob assembly
alter table sys.apply$_dest_obj_ops add
  (assemble_lobs        char(1) default 'N');

rem table used to store message ids of error transactions for Streams
create table apply$_error_txn
(
  msg_id               raw(16),        /* unique id of a msg, same as in the */
                                                              /* queue table */
  local_transaction_id varchar2(22),       /* id of txn that created the err */
  txn_message_number   number          /* unique number of a msg in the txn. */
)
/


rem Recoverable script : table storing recoverable script details
create table reco_script$
( 
  oid                    raw(16),                        /* global unique id */
  invoking_package_owner varchar2(30),         /* pkg owner of invoking proc */
  invoking_package       varchar2(30),           /* name of the invoking pkg */
  invoking_procedure     varchar2(30),          /* name of the invoking proc */
  invoking_user          varchar2(30),                      /* invoking user */
  total_blocks           number,     /* total number of blocks in the script */
  context                clob,        /* any context the user wishes to pass */
                                /* between blocks, like some state variables */
  status                 number,   /* GENERATING, EXECUTING, EXECUTED, ERROR */
  done_block_num         number,
                            /* nth block that has been successfully executed */
  script_comment         varchar2(4000),       /* comments passed in by user */
  ctime                  date default SYSDATE,         /* script create time */
  spare1                 number,
  spare2                 number,
  spare3                 number,
  spare4                 varchar2(1000),
  spare5                 varchar2(1000),
  spare6                 date
)
tablespace SYSAUX
/ 

create unique index reco_script$_unq
  on reco_script$ (oid)
tablespace SYSAUX
/

rem Recoverable script : table storing operation parameters
create table reco_script_params$
(
  oid            raw(16),               /* global unique id of the operation */
  param_index    number,               /* to associate multivalue parameters */
  name           varchar2(30),                          /* name of parameter */
  value          varchar2(4000),                       /* value of parameter */
  spare1         number,
  spare2         number,
  spare3         varchar2(1000)
)
tablespace SYSAUX
/

create unique index reco_script_params$_unq
  on reco_script_params$ (oid, name, param_index)
tablespace SYSAUX
/

rem Recoverable script : table storing recoverable script blocks
create table reco_script_block$
(
  oid                  raw(16),                          /* global unique id */
  block_num            number,                    /* nth block in the script */
  forward_block        clob,                 /* forward block to be executed */
  forward_block_dblink varchar2(128),     /* where forward block is executed */
  undo_block           clob,     /* block to be executed in case of rollback */
  undo_block_dblink    varchar2(128),        /* where undo block is executed */
  state_block          clob,        /* block to be executed to set the state */
  status               number,   /* EXECUTED, ERROR, NOT EXECUTED, EXECUTING */
  context              clob,              /* any ctx the user wishes to pass */
  block_comment        varchar2(4000),        /* user comments for the block */
  ctime                date default SYSDATE,   /* time the block was created */
  spare1               number,
  spare2               number,
  spare3               number,
  spare4               varchar2(1000),
  spare5               varchar2(1000),
  spare6               date
)
tablespace SYSAUX
/

create unique index reco_script_block$_unq
  on reco_script_block$ (oid, block_num)
tablespace SYSAUX
/

rem Recoverable script : table storing recoverable script errors
create table reco_script_error$
(
  oid                 raw(16),                           /* global unique id */
  block_num           number,                       /* nth block that failed */
  error_number        number,                                /* error number */
  error_message       varchar2(4000),                       /* error message */
  error_creation_time date default SYSDATE,            /* time error occured */
  spare1              number,
  spare2              varchar2(1000)
)
tablespace SYSAUX
/


Rem add oldest_transaction_id to streams$_apply_milestone
ALTER TABLE streams$_apply_milestone ADD
(
  oldest_transaction_id varchar2(22)                /* oldest transaction id */
)
/

Rem add ua_notification_handler to streams$_apply_process 
ALTER TABLE streams$_apply_process ADD
(
  UA_NOTIFICATION_HANDLER VARCHAR2(98),
  UA_RULESET_OWNER        VARCHAR2(30),
  UA_RULESET_NAME         VARCHAR2(30)
);

create unique index streams$_apply_error_txn_unq
  on apply$_error_txn(local_transaction_id, txn_message_number)
  tablespace SYSAUX
/

ALTER TABLE apply$_error ADD 
(  
  error_creation_time   date                     /* time this error occurred */
)
/

Rem apply spilling transaction information
create table streams$_apply_spill_txn
(
  applyname              varchar2(30) NOT NULL, /* name of the apply process */
  xidusn                    number NOT NULL,    /* source transaction ID usn */
  xidslt                    number NOT NULL,    /* source transaction ID slt */
  xidsqn                    number NOT NULL,    /* source transaction ID sqn */
  first_scn                 number NOT NULL,         /* first SCN in the txn */
  last_scn                  number,                   /* last SCN in the txn */
  last_scn_seq              number,              /* last sequence in the txn */
  last_cap_instno           number,          /* capture instantiation number */
  commit_scn                number,                /* commit SCN for the txn */
  spillcount                number,        /* the number of messages spilled */
  err_num                   number,                          /* raised error */
  err_idx                   number,       /* index of lcr which raised error */
  sender                    varchar2(30),       /* user who enqueued the txn */
  flags                     number,                       /* txn level flags */
  priv_state                number,                             /* txn state */
  distrib_cscn              number,                /* distributed commit SCN */
  src_commit_time           number,  /* time when txn commited on the source */
  dep_flag                  number,                      /* dependency state */
  spill_flags               number,                  /* spill specific flags */
  first_message_create_time date,          /* time first message was created */
  spill_creation_time       date DEFAULT SYSDATE,  /* time of spill creation */
  txnkey                    number,       /* the id key for this transaction */
  spare1          number,
  spare2          number,
  spare3          number,
  spare4          number,
  spare5          varchar2(4000),
  spare6          varchar2(4000),
  spare7          varchar2(4000)
)
tablespace SYSAUX
/
create unique index i_streams_apply_spill_txn
 on streams$_apply_spill_txn(applyname, xidusn, xidslt, xidsqn)
tablespace SYSAUX
/

rem apply spill tracking table
create table streams$_apply_spill_txn_list
(
  txnkey                    number,/* the id key in streams$_apply_spill_txn */
  status                    varchar2(1),
  spare1                    number,
  spare2                    number,
  spare3                    varchar2(4000),
  spare4                    varchar2(4000)
)
tablespace SYSAUX
/

Rem add spare2 and flags columns to streams$_prepare_ddl
ALTER TABLE streams$_prepare_ddl ADD
(
  flags       number,           /* flags for supplemental logging: see knl.h */
  spare2      varchar2(1000)
)
/

Rem add spare2 and flags columns to streams$_prepare_object
ALTER TABLE streams$_prepare_object ADD
(
  flags       number,           /* flags for supplemental logging: see knl.h */
  spare2      varchar2(1000)
)
/

Rem Zero out flags column
UPDATE streams$_prepare_ddl
  SET flags = 0
  WHERE flags IS NULL;
COMMIT;

UPDATE streams$_prepare_object
  SET flags = 0
  WHERE flags IS NULL;
COMMIT;

Rem  Move capture process flags to new positions.
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

Rem
Rem Begin CDC changes here
Rem

Rem add new columns to cdc_change_sources$

alter table cdc_change_sources$
add (
  capture_name       varchar2(30),            /* Streams capture engine name */
  capqueue_name      varchar2(30),             /* Streams capture queue name */
  capqueue_tabname   varchar2(30),       /* Streams capture queue table name */
  source_enabled     char(1)                  /* Y or N - is capture started */
)
/

Rem add new columns to cdc_change_sets$

alter table cdc_change_sets$
add (
  set_sequence  varchar2(30)                /* sequence object name for rsid */
)
/

Rem add new tables

create table cdc_propagations$                       /* cdc propagation info */
(                                          /* describes a given propagation  */
  propagation_name   varchar2(30) not null,       /*Streams propagation name */
  destqueue_publisher varchar2(30) not null,          /* owner of dest queue */
  destqueue_name     varchar2(30) not null,        /* destination queue name */
  staging_database   varchar2(128) not null,         /* stage db global name */
  sourceid_name      varchar2(30) not null,
                                        /* source identifier name for propag */
  source_class       number not null    /* class of source                   */
                                        /* 1=propag starts at change source  */
                                        /* 2=propag starts at change set     */
)
/
create index i_cdc_propagations$ on cdc_propagations$(propagation_name)
/
create table cdc_propagated_sets$                /* cdc set propagation info */
(                                    /* correlates progations to change sets */
  propagation_name    varchar2(30) not null,       /*Streams propagation name*/
  change_set_publisher varchar2(30) not null,       /* change set publisher  */
  change_set_name     varchar2(30) not null       /* change set name-stage db*/
)
/
create index i_cdc_propagated_sets$ on cdc_propagated_sets$(propagation_name)
/

Rem
Rem end CDC changes 
Rem

Rem BEGIN File Group tables

rem file groups
create table fgr$_file_groups
(
  file_group_id     number             not null,      /* obj# for file group */
  keep_files        varchar2(1)        not null,        /* keep files setting*/
  min_versions      number             not null,       /* min number to keep */
  max_versions      number             not null,       /* max number to keep */
  retention_days    number             not null,         /* max days to keep */
  creator           varchar2(30) not null,             /* file group creator */
  creation_time     timestamp with time zone not null,      /* creation time */
  sequence_name     varchar2(30) not null,        /* sequence for version id */
  audit$            varchar2(38) not null,               /* auditing options */
  user_comment      varchar2(4000),                          /* user comment */
  default_dir_obj   varchar2(30),                /* default directory object */
  spare1            number,
  spare2            number,
  spare3            varchar2(30),
  spare4            varchar2(128)
)
/

create unique index i_fgr$_file_groups1
 on fgr$_file_groups(file_group_id)
/

rem file group versions
create table fgr$_file_group_versions
(
  version_id        number             not null,      /* internal version id */
  file_group_id     number             not null,     /* version's file group */
  creator           varchar2(30) not null,              /* version's creator */
  creation_time     timestamp with time zone not null,      /* creation time */
  version_guid      raw(16)            not null,           /* version's GUID */
  version_name      varchar2(30) not null,                /* name of version */
  user_comment      varchar2(4000),                          /* user comment */
  default_dir_obj   varchar2(30),                /* default directory object */
  spare1            number,
  spare2            number,
  spare3            varchar2(30),
  spare4            varchar2(128)
)
/
create unique index i_fgr$_file_group_versions1
 on fgr$_file_group_versions(version_name, file_group_id)
/
create unique index i_fgr$_file_group_versions2
 on fgr$_file_group_versions(file_group_id, version_id)
/
create unique index i_fgr$_file_group_versions3
 on fgr$_file_group_versions(version_guid)
/

rem file group versions export info
create table fgr$_file_group_export_info
(
  version_guid      raw(16)            not null,           /* version's GUID */
  export_version    varchar2(30) not null,           /* export compatibility */
  export_platform   varchar2(101)      not null,          /* export platform */
  export_time       date               not null,              /* export time */
  export_scn        number,                                    /* export scn */
  source_db_name    varchar2(128),              /* global name of the source */
  spare1            number,
  spare2            number,
  spare3            varchar2(30),
  spare4            varchar2(128)
)
/
create unique index i_fgr$_file_group_export_info1
 on fgr$_file_group_export_info(version_guid)
/

rem file group files
create table fgr$_file_group_files
(
  file_name         varchar2(512) not null,                     /* file name */
  creator           VARCHAR2(30) not null,                   /* file creator */
  /* file's creation time */
  creation_time     timestamp with time zone not null,
  file_dir_obj      varchar2(30) not null,/* directory object for file */
  version_guid      raw(16)            not null,           /* version's GUID */
  file_size         number,                                     /* file size */
  file_blocksize    number,                               /* file block size */
  file_type         varchar2(32),                               /* file type */
  user_comment      varchar2(4000),                          /* user comment */
  spare1            number,
  spare2            number,
  spare3            varchar2(30),
  spare4            varchar2(128)
)
/
create unique index i_fgr$_file_group_files1
 on fgr$_file_group_files(file_name, version_guid)
/
create index i_fgr$_file_group_files2
 on fgr$_file_group_files(version_guid)
/

create table fgr$_tablespace_info
(
  version_guid      raw(16)            not null,           /* version's GUID */
  tablespace_name   varchar2(30)       not null,          /* tablespace name */
  spare1            number,
  spare2            number,
  spare3            varchar2(30),
  spare4            varchar2(128)
)
/
create unique index i_fgr$_tablespace_info1
 on fgr$_tablespace_info(version_guid, tablespace_name)
/
create index i_fgr$_tablespace_info2
 on fgr$_tablespace_info(tablespace_name)
/

create table fgr$_table_info
(
  version_guid      raw(16)            not null,           /* version's GUID */
  schema_name       varchar2(30) not null,                    /* schema name */
  table_name        varchar2(30) not null,                     /* table name */
  tablespace_name   varchar2(30),                         /* tablespace name */
  scn               number,                                    /* export scn */
  spare1            number,
  spare2            number,
  spare3            varchar2(30),
  spare4            varchar2(128)
)
/
create unique index i_fgr$_table_info1
 on fgr$_table_info(version_guid, schema_name, table_name, tablespace_name)
/
create index i_fgr$_table_info2
 on fgr$_table_info(schema_name, table_name, tablespace_name)
/
create index i_fgr$_table_info3
 on fgr$_table_info(table_name)
/

Rem END File Group tables

Rem Add a new column to dimlevel$ TO support dimensions with SKIP WHEN NULL
ALTER TABLE sys.dimlevel$ ADD (flags NUMBER DEFAULT 0);

Rem Add a new column to dimjoinkey$ for child level id
ALTER TABLE sys.dimjoinkey$ ADD (chdlevid# NUMBER DEFAULT 0);

rem Add goal column to service$
alter table service$ add
(
  goal       number,                                         /* service goal */
                                                                 /* none : 0 */
                                                         /* service time : 1 */
                                                             /* throughput : 2 */
  flags      number                               /* service attribute flags */
                                                        /* DTP service : 0x1 */
)
/

Rem LINK$ TABLE HAS TWO NEW COLUMNS


ALTER TABLE link$ ADD (passwordx RAW(128));
ALTER TABLE link$ ADD (authpwdx  RAW(128));

Rem Change partitioning index to be unique (bug 3748430)
Rem before creating unique indexes, lets fix bug 3802863 which could have
Rem created non-unique part# values in indpart$ and indsubpart$.

merge into indpart$ ip0 using 
  (select lf.frag# part#, ip.obj# obj#
   from   indpart$ ip, lobfrag$ lf 
   where  ip.obj# = lf.indfragobj# and ip.part# != lf.frag#) ip1
on (ip1.obj# = ip0.obj#)
when matched then
update set ip0.part# = ip1.part#;

merge into indsubpart$ isp0 using 
  (select lf.frag# subpart#, isp.obj# obj#
   from   indsubpart$ isp, lobfrag$ lf
   where  isp.obj# = lf.indfragobj# and isp.subpart# != lf.frag#) isp1
on (isp1.obj# = isp0.obj#)
when matched then
update set isp0.subpart# = isp1.subpart#;


begin
  execute immediate 'drop index i_tabpart$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_tabpart_bopart$ on tabpart$(bo#, part#)
/

begin
  execute immediate 'drop index i_tabpart_obj$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_tabpart_obj$ on tabpart$(obj#)
/

begin
  execute immediate 'drop index i_indpart$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_indpart_bopart$ on indpart$(bo#, part#)
/

begin
  execute immediate 'drop index i_indpart_obj$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_indpart_obj$ on indpart$(obj#)
/

begin
  execute immediate 'drop index i_tabsubpart$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_tabsubpart_pobjsubpart$ on tabsubpart$(pobj#, subpart#)
/

begin
  execute immediate 'drop index i_tabsubpart$_obj$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_tabsubpart$_obj$ on tabsubpart$(obj#)
/

begin
  execute immediate 'drop index i_indsubpart$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_indsubpart_pobjsubpart$ on indsubpart$(pobj#, subpart#)
/

begin
  execute immediate 'drop index i_indsubpart_obj$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_indsubpart_obj$ on indsubpart$(obj#)
/

create unique index i_tabcompart_bopart$ on tabcompart$(bo#, part#)
/

create unique index i_indcompart_bopart$ on indcompart$(bo#, part#)
/

begin
  execute immediate 'drop index i_lobfrag$_parentobj$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_lobfrag_parentobjfrag$ on lobfrag$(parentobj#, frag#)
/

begin
  execute immediate 'drop index i_lobfrag$_fragobj$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_lobfrag$_fragobj$ on lobfrag$(fragobj#)
/

begin
  execute immediate 'drop index i_lobcomppart$_partlobj$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create index i_lobcomppart_lobjpart$ on lobcomppart$(lobj#, part#)
/

begin
  execute immediate 'drop index i_lobcomppart$_partobj$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_lobcomppart$_partobj$ on lobcomppart$(partobj#)
/

begin
  execute immediate 'drop index i_defsubpart$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_defsubpart$ on defsubpart$(bo#, spart_position)
/

begin
  execute immediate 'drop index i_defsubpartlob$';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

create unique index i_defsubpartlob$ on defsubpartlob$ 
(bo#, intcol#, spart_position)
/

Rem end make partitioning indexes unique

Rem ========================================================================
Rem Begin (bug 4186885): sync partition numbers for overflow partitions
Rem                      with base table partitions
Rem ========================================================================

merge into sys.tabpart$ tp0 using
(select ovfl_parts.tp_obj# obj#, base_parts.tp_part# part#
from
(select row_number() over (partition by tp.bo# order by tp.part#) tp_rank#,
  tp.part# tp_part#, tp.obj# tp_obj#, t.bobj# t_bobj#, t.obj# t_obj#
  from sys.tabpart$ tp, sys.tab$ t
  where tp.bo# = t.obj# and to_number(bitand(t.property,544))=544) ovfl_parts,
(select row_number() over (partition by tp.bo# order by tp.part#) tp_rank#,
  tp.part# tp_part#, t.bobj# t_bobj#, t.obj# t_obj#
  from sys.tabpart$ tp, sys.tab$ t
  where tp.bo# = t.obj# and to_number(bitand(t.property,224))=224) base_parts
where
ovfl_parts.t_bobj#   = base_parts.t_obj#   and
base_parts.t_bobj#   = ovfl_parts.t_obj#   and
base_parts.tp_part# != ovfl_parts.tp_part# and
ovfl_parts.tp_rank#  = base_parts.tp_rank#) tp1
on (tp1.obj# = tp0.obj#)
when matched then
update set tp0.part# = tp1.part#;

commit;

Rem ========================================================================
Rem  End (bug 4186885)
Rem ========================================================================



Rem BEGIN Transparent Column Encryption

create table enc$ (
  obj#    number,                                     /* table object number */
  owner#  number,                         /* user id of the master key owner */
  mkeyid  varchar2(64),                           /* global id of master key */
  encalg  number,                                 /* encryption algorithm id */
  intalg  number,                                  /* integrity algorithm id */
  colklc  raw(2000),                                   /* column key locator */
  klclen  number,                                   /* length of key locator */
  flag    number                                                     /* flag */
)
/

create unique index enc_idx on enc$(obj#, owner#)
/
Rem END Transparent Column Encryption

Rem Change notification related dictionary tables
create table invalidation_registry$ (
  regid   number,
  regflags NUMBER,
  numobjs number,
  objarray  RAW(512),
  plsqlcallback varchar2(128),
  changelag number,
  username varchar2(30)
)
/
create index i_invalidation_registry$ on invalidation_registry$(regid)
/
create sequence invalidation_reg_id$          /* registration sequence number */
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 20
  order
  nocycle
/
Rem End Change notification related dictionary tables


Rem #(3350342) Secondary modification info table with partition rollup

create table mon_mods_all$
(
  obj#              number,                                 /* object number */
  inserts           number,  /* approx. number of inserts since last analyze */
  updates           number,  /* approx. number of updates since last analyze */
  deletes           number,  /* approx. number of deletes since last analyze */
  timestamp         date,     /* timestamp of last time this row was changed */
  flags             number,                                         /* flags */
                                           /* 0x01 object has been truncated */
  drop_segments     number   /* number of segemnt in part/subpartition table */
)
  storage (initial 200K next 100k maxextents unlimited pctincrease 0) 
/
create unique index i_mon_mods_all$_obj on mon_mods_all$(obj#)
  storage (maxextents unlimited)
/

Rem=========================================================================
Rem Begin bug 4318925 fix
DECLARE
  EXTENT_MANAGEMENT VARCHAR2(10);
BEGIN
  select EXTENT_MANAGEMENT into EXTENT_MANAGEMENT 
	from dba_tablespaces where tablespace_name='SYSTEM';
  IF (EXTENT_MANAGEMENT <> 'LOCAL') THEN
     EXECUTE IMMEDIATE
      'alter table ncomp_dll$ modify lob (dll) ' || 
        '(storage (next 1m maxextents unlimited pctincrease 0))';
  END IF;
END;
/
Rem End   bug 4318925 fix
Rem=========================================================================
Rem
Rem update array_index col name to sys_nc_array_index$ for octs

update col$ c set c.name='SYS_NC_ARRAY_INDEX$'
  where c.name = 'ARRAY_INDEX' and c.col#=0 and c.intcol#=1 and
    bitand(c.property, 32) = 32 and c.obj# in (select n.ntab# from ntab$ n)
/
 
commit;

Rem=========================================================================
Rem Add changes to other SYS dictionary objects here 
Rem     (created in catproc.sql scripts)
Rem=========================================================================

Rem ------------------------------------------------
Rem  XMLAgg and XMLSequence related changes - BEGIN
Rem ------------------------------------------------

drop type AggXMLInputType FORCE;

-- the following 5 privileges were not in 8.17 or 9.01

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON XMLAGG FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem ------------------------------------------------
Rem  XMLAgg and XMLSequence related changes - END
Rem ------------------------------------------------


Rem
Rem Metadata API changes
Rem Make sys.utl_xml private (PL/SQL wrapper to CORE's C-based XML/XSL
Rem processor). Drop public synonym and revoke grants.
Rem
drop public synonym utl_xml;

-- Grant was to PUBLIC in 9.01 and 9.20
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON utl_xml FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

-- Grant was to EXECUTE_CATALOG_ROLE in 10.1
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON utl_xml FROM EXECUTE_CATALOG_ROLE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem
Rem End Metadata API changes
Rem

Rem=========================================================================
Rem upgrade rules engine objects
Rem=========================================================================
Rem Begin Scheduler Upgrade
Rem=========================================================================

ALTER TABLE sys.scheduler$_job ADD (
  queue_owner     varchar2(30),
  queue_name      varchar2(30),
  queue_agent     varchar2(30),
  event_rule      varchar2(65),
  mxdur_msgid     raw(16));

ALTER TABLE sys.scheduler$_schedule ADD (
  queue_owner     varchar2(30),
  queue_name      varchar2(30),
  queue_agent     varchar2(30));

ALTER TABLE sys.scheduler$_global_attribute ADD (
  attr_tstamp     timestamp with time zone,
  attr_intv       interval day(3) to second(0));



Rem=========================================================================
Rem End Scheduler Upgrade
Rem=========================================================================


Rem=========================================================================
Rem Add changes to other SYS dictionary objects here 
Rem     (created in catproc.sql scripts)
Rem=========================================================================
alter table rule$ add (uactx_client varchar2(30));
  

Rem ========================================================================
Rem PLSQL_TRACE_EVENTS is an optionally-present table, created by tracetab.sql.
Rem Add fields added for bug 4180912, if not already present.  Table not found
Rem or fields already present are possible, and should just be ignored.
Rem Note - these fields are deliberately not dropped on downgrade, since bug
Rem txn might have been backported and their presence won't harm anything.
Rem ========================================================================
alter table sys.plsql_trace_events add
(
-- Fields from dbms_application_info, dbms_session, and ECID
  module          varchar2(4000),
  action          varchar2(4000),
  client_info     varchar2(4000),
  client_id       varchar2(4000),
  ecid_id         varchar2(4000),
  ecid_seq        number,
--
--
-- Fields for extended callstack and errorstack info
--  (currently set only for "Exception raised" events)
--
  callstack       clob,
  errorstack      clob
);

-- Turn ON the event to enable DDL on AQ tables
alter session set events  '10851 trace name context forever, level 1';

Rem ========================================================================
Rem AQ related upgade
Rem ========================================================================
ALTER TYPE sys.msg_prop_t add attribute (delivery_mode NUMBER) CASCADE;  

ALTER TYPE sys.aq$_srvntfn_message
ADD ATTRIBUTE (delivery_mode NUMBER, ntfn_flags NUMBER) CASCADE;  

-- Turn OFF the event to disable DDL on AQ tables
alter session set events  '10851 trace name context off';

Rem ==========================
Rem Begin STS schema changes
Rem ==========================

-- in R2, wri$_sqlset_definitions stores owner names case-sensitively
-- make a best effort to convert case-insensitive R1 names into case-sensitive
-- R2 names
BEGIN
  EXECUTE IMMEDIATE 
    'UPDATE wri$_sqlset_definitions set owner = ' ||
         ' (select name from user$ u1 where upper(u1.name) = owner) ' ||
         '  where ' ||
               '(select count(*) from user$ u2 ' ||
               ' where upper(u2.name) = owner) = 1';
EXCEPTION  
   WHEN OTHERS THEN
     IF (SQLCODE = -942) THEN
       NULL;
     ELSE
       RAISE;
     END IF;
END;
/

-- SQL tuning set names are also now unique by (name,owner) rather than
-- just by name (the index is re-created in catsqlt)

BEGIN
  EXECUTE IMMEDIATE
    'drop index wri$_sqlset_definitions_idx_01';
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -1418) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

-- We will need to migrate data from the 10gR1 versions of the statements
-- and binds tables into a 10gR2 version.  We rename the R1 versions of the
-- tables here, and then in a1001000 we move the data from the R1 version to
-- the R2 version (after first detecting the re-run case)

DECLARE
  already_r2 NUMBER;
BEGIN
  already_r2 := 0;
   
  -- Check to see if the data migration has already been done
  --  in R2 we have no buffer gets column in the statements table
  select DECODE(count(*),
                0, 1,
                0)
  into   already_r2
  from   dba_tab_columns
  where  owner = 'SYS' and table_name = 'WRI$_SQLSET_STATEMENTS' AND
         column_name = 'BUFFER_GETS';  
  
  IF (already_r2 = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE wri$_sqlset_statements RENAME TO '  ||
                      ' wri$_sqlset_statements_10gR1';
    EXECUTE IMMEDIATE 'ALTER TABLE wri$_sqlset_statements_10gR1 '      || 
                      ' RENAME CONSTRAINT wri$_sqlset_statements_pk '  || 
                      ' TO wri$_sqlset_stmts_pk_10gR1';

    BEGIN
      EXECUTE IMMEDIATE 'ALTER INDEX wri$_sqlset_statements_pk '       ||
                        ' RENAME TO wri$_sqlset_stmts_pk_10gR1';
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE = -1418) THEN
            NULL;
          ELSE
            RAISE;
          END IF;
    END;

    EXECUTE IMMEDIATE 'ALTER TABLE wri$_sqlset_binds '                 ||
                      ' RENAME TO wri$_sqlset_binds_10gR1';
    EXECUTE IMMEDIATE 'ALTER TABLE wri$_sqlset_binds_10gR1 '           ||
                      ' RENAME CONSTRAINT wri$_sqlset_binds_pk '       ||
                      ' TO wri$_sqlset_binds_pk_10gR1';
    BEGIN
      EXECUTE IMMEDIATE 'ALTER INDEX wri$_sqlset_binds_pk '            ||
                        ' RENAME TO wri$_sqlset_binds_pk_10gR1';
      EXCEPTION
        WHEN OTHERS THEN
          IF (SQLCODE = -1418) THEN
            NULL;
          ELSE
            RAISE;
          END IF;
    END;

    END IF; -- if the schema is in its R2 format we dont need to do anything
END;
/

Rem ========================
Rem End STS schema changes
Rem ======================== 

Rem =============================
Rem Begin sqltune schema changes
Rem ============================= 
ALTER TABLE wri$_adv_sqlt_statistics ADD (direct_writes NUMBER)
/

-- 
-- in R1 the wri$_adv_sqlt_rtn_plan table had the same name as its constraint 
-- 

ALTER TABLE wri$_adv_sqlt_rtn_plan RENAME CONSTRAINT wri$_adv_sqlt_rtn_plan TO wri$_adv_sqlt_rtn_plan_pk
/

BEGIN
  EXECUTE IMMEDIATE 'ALTER INDEX wri$_adv_sqlt_rtn_plan '            ||
                    'RENAME TO wri$_adv_sqlt_rtn_plan_pk';
  EXCEPTION
    WHEN OTHERS THEN
      IF (SQLCODE = -1418) THEN
        NULL;
      ELSE
        RAISE;
      END IF;
END;
/

--
-- bug#5999827 - after upgrade sts could not be found
--
-- Starting in 10.2 STS names are unique per-owner, where in 10.1 they were
-- globally unique.  So we need to populate attr3 of the object in 10.2.
-- 

BEGIN
  EXECUTE IMMEDIATE
    'UPDATE wri$_adv_objects o
     SET    attr3 = (SELECT max(owner) 
                     FROM   wri$_sqlset_definitions 
                     WHERE  name = o.attr1)
     WHERE  type = 8 /* SQLSET */ and
            EXISTS (SELECT 1
                    FROM   wri$_adv_tasks t
                    WHERE  t.id = o.task_id and t.advisor_id = 4)';
EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = -942) THEN                      /* table does not exist */
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

commit;

Rem =============================
Rem End sqltune schema changes
Rem ============================= 

Rem
Rem Bugfix# 3431498
Rem
drop public synonym extract;
drop operator extract;
drop public synonym existsnode;
drop operator existsnode;
  
Rem=============
Rem AWR Changes
Rem=============

-- Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

-- these types are obsoleted
drop type NUM_ARY force;
drop type VCH_ARY force;
drop type CLB_ARY force;

-- Drop these AWR report types so they will be recreated when catalog is run
drop type AWRRPT_ROW_TYPE force;
drop type AWRRPT_TEXT_TYPE_TABLE force;
drop type AWRRPT_TEXT_TYPE force;
drop type AWRRPT_HTML_TYPE_TABLE force;
drop type AWRRPT_HTML_TYPE force;
drop type AWRDRPT_TEXT_TYPE_TABLE force;
drop type AWRDRPT_TEXT_TYPE force;

-- drop the WRH$_SQLBIND and associate BL table.  This
-- table has been replaced by WRH$_SQL_BIND_METADATA
-- and the BIND_DATA column in WRH$_SQLSTAT.
drop table WRH$_SQLBIND;
drop table WRH$_SQLBIND_BL;

drop table WRH$_CLASS_CACHE_TRANSFER;
drop table WRH$_CLASS_CACHE_TRANSFER_BL;

-- add and rename columns to WRH$_SQLSTAT and WRH$_SQLSTAT_BL
alter table WRH$_SQLSTAT    add PX_SERVERS_EXECS_TOTAL   number;
alter table WRH$_SQLSTAT    add PX_SERVERS_EXECS_DELTA   number;
alter table WRH$_SQLSTAT    add FORCE_MATCHING_SIGNATURE number;
alter table WRH$_SQLSTAT    add PARSING_SCHEMA_NAME      varchar2(30);
alter table WRH$_SQLSTAT    add BIND_DATA                raw(2000);
alter table WRH$_SQLSTAT    add FLAG                     number;

alter table WRH$_SQLSTAT_BL add PX_SERVERS_EXECS_TOTAL   number;
alter table WRH$_SQLSTAT_BL add PX_SERVERS_EXECS_DELTA   number;
alter table WRH$_SQLSTAT_BL add FORCE_MATCHING_SIGNATURE number;
alter table WRH$_SQLSTAT_BL add PARSING_SCHEMA_NAME      varchar2(30);
alter table WRH$_SQLSTAT_BL add BIND_DATA                raw(2000);
alter table WRH$_SQLSTAT_BL add FLAG                     number;

-- bump up size of optimizer env column
alter table WRH$_OPTIMIZER_ENV  modify (OPTIMIZER_ENV raw(1000));

-- add and rename columns to WRH$_SEG_STAT and WRH$_SEG_STAT_BL
alter table WRH$_SEG_STAT add GC_BUFFER_BUSY_TOTAL number;
alter table WRH$_SEG_STAT add GC_BUFFER_BUSY_DELTA number;
alter table WRH$_SEG_STAT 
  rename column GC_CR_BLOCKS_SERVED_TOTAL to GC_CR_BLOCKS_RECEIVED_TOTAL;
alter table WRH$_SEG_STAT 
  rename column GC_CR_BLOCKS_SERVED_DELTA to GC_CR_BLOCKS_RECEIVED_DELTA;
alter table WRH$_SEG_STAT 
  rename column GC_CU_BLOCKS_SERVED_TOTAL to GC_CU_BLOCKS_RECEIVED_TOTAL;
alter table WRH$_SEG_STAT 
  rename column GC_CU_BLOCKS_SERVED_DELTA to GC_CU_BLOCKS_RECEIVED_DELTA;
alter table WRH$_SEG_STAT add chain_row_excess_total number;
alter table WRH$_SEG_STAT add chain_row_excess_delta number;

alter table WRH$_SEG_STAT_BL add GC_BUFFER_BUSY_TOTAL number;
alter table WRH$_SEG_STAT_BL add GC_BUFFER_BUSY_DELTA number;
alter table WRH$_SEG_STAT_BL
  rename column GC_CR_BLOCKS_SERVED_TOTAL to GC_CR_BLOCKS_RECEIVED_TOTAL;
alter table WRH$_SEG_STAT_BL 
  rename column GC_CR_BLOCKS_SERVED_DELTA to GC_CR_BLOCKS_RECEIVED_DELTA;
alter table WRH$_SEG_STAT_BL
  rename column GC_CU_BLOCKS_SERVED_TOTAL to GC_CU_BLOCKS_RECEIVED_TOTAL;
alter table WRH$_SEG_STAT_BL
  rename column GC_CU_BLOCKS_SERVED_DELTA to GC_CU_BLOCKS_RECEIVED_DELTA;
alter table WRH$_SEG_STAT_BL add chain_row_excess_total number;
alter table WRH$_SEG_STAT_BL add chain_row_excess_delta number;

-- add new timestamp column to wrh$_sql_plan
alter table sys.wrh$_sql_plan add (timestamp date);

-- add new other_xml column to wrh$_sql_plan
alter table sys.wrh$_sql_plan add (other_xml clob);

-- increase size of the object_node column in wrh$_sql_plan
alter table sys.wrh$_sql_plan modify (object_node varchar2(128));

-- increase size of the pool column in wrh$_sgastat_bl
alter table sys.wrh$_sgastat_bl modify (pool varchar2(12));

-- reorganize primary key
alter table WRH$_SEG_STAT
  drop constraint WRH$_SEG_STAT_PK;
alter table WRH$_SEG_STAT 
  add  constraint WRH$_SEG_STAT_PK
    PRIMARY KEY (dbid, snap_id, instance_number, obj#, dataobj#)
    using index local tablespace SYSAUX;

alter table WRH$_SEG_STAT_BL 
  drop constraint WRH$_SEG_STAT_BL_PK;
alter table WRH$_SEG_STAT_BL 
  add  constraint WRH$_SEG_STAT_BL_PK
    PRIMARY KEY (dbid, snap_id, instance_number, obj#, dataobj#)
    using index tablespace SYSAUX;

alter table WRH$_SEG_STAT_OBJ 
  drop constraint WRH$_SEG_STAT_OBJ_PK;
alter table WRH$_SEG_STAT_OBJ 
  add  constraint WRH$_SEG_STAT_OBJ_PK
    PRIMARY KEY (dbid, obj#, dataobj#)
    using index tablespace SYSAUX;

alter table WRH$_SEG_STAT_OBJ
  add ( index_type           varchar2(27)
      , base_obj#            number
      , base_object_name     varchar2(30)
      , base_object_owner    varchar2(30) );

alter table WRH$_CURRENT_BLOCK_SERVER 
  drop constraint WRH$_CURRENT_BLOCK_SERVER_PK;
alter table WRH$_CURRENT_BLOCK_SERVER 
  add  constraint WRH$_CURRENT_BLOCK_SERVER_PK
    PRIMARY KEY (dbid, snap_id, instance_number)
    using index tablespace SYSAUX;

alter table WRM$_SNAP_ERROR 
  drop constraint WRM$_SNAP_ERROR_PK;
alter table WRM$_SNAP_ERROR 
  add  constraint WRM$_SNAP_ERROR_PK
    PRIMARY KEY (dbid, snap_id, instance_number, table_name)
    using index tablespace SYSAUX;

Rem
Rem Clean up the duplicate metrics data from the previous release
Rem Disabled until we add constraints to the metrics tables.
Rem
Rem DECLARE
Rem  PROCEDURE exec_delete(table_name IN VARCHAR2, 
Rem                        metric_cols IN VARCHAR2) IS
Rem    pkcols           VARCHAR2(100);
Rem    sqlstr           VARCHAR2(1000);
Rem    table_not_exist  EXCEPTION;
Rem    PRAGMA exception_init(table_not_exist, -942);
Rem  BEGIN
Rem    -- set up the PK columns
Rem    pkcols := 'dbid, snap_id, instance_number, ' || metric_cols;
Rem    -- set up the SQL string
Rem    sqlstr := 'delete from ' || table_name ||
Rem                 ' where ('  || pkcols     || ')' ||
Rem                 ' in (select '    || pkcols      ||
Rem                      ' from '     || table_name  ||
Rem                      ' group by ' || pkcols      ||
Rem                      ' having count(*) > 1)';
Rem
Rem    execute immediate sqlstr;
Rem    commit;
Rem  EXCEPTION
Rem    WHEN table_not_exist THEN null;
Rem  END;
Rem BEGIN
Rem   exec_delete('WRH$_SYSMETRIC_HISTORY', 'group_id, metric_id, begin_time');
Rem   exec_delete('WRH$_SYSMETRIC_SUMMARY', 'group_id, metric_id');
Rem   exec_delete('WRH$_SESSMETRIC_HISTORY', 
Rem               'group_id, sessid, metric_id, begin_time');
Rem   exec_delete('WRH$_FILEMETRIC_HISTORY', 'group_id, fileid, begin_time');
Rem   exec_delete('WRH$_WAITCLASSMETRIC_HISTORY', 
Rem               'group_id, wait_class_id, begin_time');
Rem END;
Rem /

Rem
Rem Add indexes to metrics tables
Rem 

DECLARE
 PROCEDURE exec_addindex(table_name IN VARCHAR2,
                         index_name IN VARCHAR2,
                         metric_cols IN VARCHAR2) IS
   index_cols       VARCHAR2(100);
   sqlstr           VARCHAR2(1000); 
   table_not_exist  EXCEPTION;
   PRAGMA exception_init(table_not_exist, -942);
 BEGIN 
   -- add the common columns
   index_cols := 'dbid, snap_id, instance_number, ' || metric_cols;
   -- set up the SQL string 
   sqlstr := 'create index '|| index_name ||
             ' on '         || table_name ||
             '('            || index_cols ||
             ') tablespace SYSAUX';
   execute immediate sqlstr;
   commit;
 EXCEPTION
   WHEN table_not_exist THEN null;
 END;  
BEGIN  
  -- internal procedure exec_addindex invoked with literals constants only
  exec_addindex('WRH$_SYSMETRIC_HISTORY', 'WRH$_SYSMETRIC_HISTORY_INDEX',
                'group_id, metric_id, begin_time'); 
  exec_addindex('WRH$_SYSMETRIC_SUMMARY', 'WRH$_SYSMETRIC_SUMMARY_INDEX',
                'group_id, metric_id');
  exec_addindex('WRH$_SESSMETRIC_HISTORY', 'WRH$_SESSMETRIC_HISTORY_INDEX',
              'group_id, sessid, metric_id, begin_time');
  exec_addindex('WRH$_FILEMETRIC_HISTORY', 'WRH$_FILEMETRIC_HISTORY_INDEX',
                'group_id, fileid, begin_time');
  exec_addindex('WRH$_WAITCLASSMETRIC_HISTORY', 'WRH$_WAITCLASSMETRIC_HIST_IND',
                'group_id, wait_class_id, begin_time');
END;
/

Rem 
Rem Add blocking_session_serial#, force_matching_signature to 
Rem WRH$_ACTIVE_SESSION_HISTORY, WRH$_ACTIVE_SESSION_HISTORY_BL
Rem Add blocking_session,xid to WRH$_ACTIVE_SESSION_HISTORY and its _BL
Rem Modify program to be varchar2(64)
Rem 

alter table WRH$_ACTIVE_SESSION_HISTORY add (force_matching_signature  NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (blocking_session          NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (blocking_session_serial#  NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (xid                       RAW(8));

alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (force_matching_signature  NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (blocking_session          NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (blocking_session_serial#  NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (xid                       RAW(8));

alter table WRH$_ACTIVE_SESSION_HISTORY    modify (program  VARCHAR2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY_BL modify (program  VARCHAR2(64));

Rem 
Rem Add P1, P2, P3 columns to WRH$_EVENT_NAME
Rem 
alter table WRH$_EVENT_NAME add (PARAMETER1 varchar2(64));
alter table WRH$_EVENT_NAME add (PARAMETER2 varchar2(64));
alter table WRH$_EVENT_NAME add (PARAMETER3 varchar2(64));

alter table WRH$_UNDOSTAT ADD (status NUMBER DEFAULT 0);
alter table WRH$_UNDOSTAT ADD (spcprs_retention NUMBER DEFAULT 0);
alter table WRH$_UNDOSTAT ADD (runawayquerysqlid varchar2(13) DEFAULT NULL);

Rem 
Rem Add the Top N SQL column to the WRM$_WR_CONTROL table
Rem and set the the Top N SQL column to the Default value.
Rem
alter table WRM$_WR_CONTROL add (TOPNSQL number);
BEGIN
  execute immediate 'update WRM$_WR_CONTROL set TOPNSQL = 2000000000';
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


Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==          (10gR2 = SWRF Version 2)                 ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  upgrade changes.  Place all other AWR upgrade    ==
Rem ==  changes above this.                              ==
Rem =======================================================

BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control SET swrf_version = 2';
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

-- Turn OFF the event to disable the partition check for AWR
alter session set events  '14524 trace name context off';

-- truncate obsoleted Scheduler chains data if present
-- these tables are no longer created or used in 10.2 and up
-- their use was never supported in 10.1
BEGIN
EXECUTE IMMEDIATE 'delete from sys.obj$ where obj# in ' ||
 '(select obj# from sys.scheduler$_job_chain)';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -942 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/
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
  -- internal procedure execute_truncate called with literal constants only
  execute_truncate('sys.scheduler$_job_chain');
  execute_truncate('sys.scheduler$_chain_varlist');
  execute_truncate('sys.scheduler$_job_step_state');
  execute_truncate('sys.scheduler$_job_step');
END;
/

-- name column of table scheduler$_event_log has an increased length
ALTER TABLE scheduler$_event_log MODIFY name varchar2(65);

--  datatype change for cpu_used 
BEGIN
EXECUTE IMMEDIATE 'UPDATE sys.scheduler$_job_run_details SET cpu_used = NULL';
EXCEPTION
   WHEN OTHERS THEN
      IF SQLCODE = -942 THEN NULL;
      ELSE RAISE;
      END IF;
END;
/

COMMIT;

ALTER TABLE sys.scheduler$_job_run_details MODIFY 
(
  cpu_used        interval day(3) to second(2)
);




Rem=========================================================================
Rem  Add changes to SYSTEM dictionary objects here 
Rem=========================================================================
  
UPDATE sys.aq$_propagation_status set destqueue_id = 0;

ALTER TABLE sys.aq$_propagation_status
DROP CONSTRAINT aq$_propagation_status_primary;

ALTER TABLE sys.aq$_propagation_status
ADD CONSTRAINT aq$_propagation_status_primary
PRIMARY KEY (queue_id, destination,destqueue_id);

ALTER TABLE sys.aq$_propagation_status
MODIFY (destqueue_id DEFAULT 0);

-- drop any index on the event_time column of logstdby$events table
declare
  ind_name varchar2(30) := null;
  ind_owner varchar2(30) := null;

begin
 begin
  select index_owner, index_name into ind_owner, ind_name
  from dba_ind_columns
  where table_name  = 'LOGSTDBY$EVENTS' and
        table_owner = 'SYSTEM' and
        column_name = 'EVENT_TIME';
exception
  when others then
     ind_name := null;
 end;

 if (ind_name is not null) then
   execute immediate 'drop index ' 
             || dbms_assert.enquote_name(ind_owner, FALSE) || 
         '.' || dbms_assert.enquote_name(ind_name, FALSE);
 end if;
end;
/

-- drop an index added in 9.2.0.7, logmnr_log$_active.  
-- no longer needed because the primary key is sufficient in 10g
begin
  execute immediate 'drop index system.logmnr_log$_active';
exception
   when others then
      if sqlcode = -1418 then null;
      else raise;
      end if;
end;
/

 -- change the datatype of column event_time in logstdby$events
alter table system.logstdby$events modify (event_time timestamp);
 -- add columns to logstdby$apply_milestone
alter table system.logstdby$apply_milestone 
     add (commit_time date, processed_time date);
 -- add column to logstdby$apply_progress
alter table system.logstdby$apply_progress add (commit_time date);

Rem ======================
Rem Begin Logminer Upgrade
Rem ======================


-- this was post 10ir1
alter table SYSTEM.LOGMNR_SESSION$ add(spill_time date);

/* Added in 10.1.0.3 */
alter table SYSTEM.LOGMNR_DICTSTATE$ add
  (RBASQN NUMBER,
   RBABLK NUMBER,
   RBABYTE NUMBER);

alter table SYSTEM.LOGMNR_INDPART$ add (part# number);
alter table SYSTEM.LOGMNR_TABPART$ add (part# number);

alter table SYSTEM.LOGMNRC_GTLO add (ASSOC# NUMBER);

-- New primary key and sequence used for logmnr_session_evolve$

-- Remove duplicate rows which would violate the primary key
-- Must be done dynamically because logmnr_session_evolve$ will
-- not yet exist in some upgrade scenarios.
declare
 cursor c1 is
   select a.branch_level, a.session#, a.db_id, a.reset_scn,
          a.reset_timestamp, a.prev_reset_scn, 
          a.prev_reset_timestamp, a.status, a.spare1, a.spare2,
          a.spare3, a.spare4
     from system.logmnr_session_evolve$ a
     order by session#, db_id, reset_scn, reset_timestamp
     for update;
 c1_prev c1%ROWTYPE;
 cnt number := 0;
begin
  for c1_rec in c1 LOOP
    IF (cnt > 0 AND c1_rec.session# = c1_prev.session# AND
        c1_rec.db_id = c1_prev.db_id AND
        c1_rec.reset_scn = c1_prev.reset_scn AND
        c1_rec.reset_timestamp = c1_prev.reset_timestamp) THEN
       delete system.logmnr_session_evolve$ where current of  c1;
     ELSE
       c1_prev := c1_rec;
     END IF;
     cnt := cnt + 1;
  end loop;
  commit;
end;
/

alter table system.logmnr_session_evolve$ drop primary key;
alter table system.logmnr_session_evolve$
       add constraint logmnr_session_evolve$_pk
           primary key (session#, db_id, reset_scn, reset_timestamp)
       using index tablespace SYSAUX logging;

 
/*
 *  In 10.2 we should make sure logmnr_session$ and its indexes are 
 *  located in SYSTEM tablespace so that 'open db' notifier can always
 *  access them.
 */
alter table system.logmnr_session$ move tablespace system;
alter index system.logmnr_session_pk rebuild tablespace system;
alter index system.logmnr_session_uk1 rebuild tablespace system;

/*
 *  BUG: 3761784
 *    In 10.1.0.2 we did not handle special dictionary builds
 *    correctly in a RAC environment.  
 */
declare
  type  curtype is ref cursor;
  rcur1  curtype;
  prev_logmnr_uid number := 0;
  prev_redo_thread number := 0;
  prev_scnbas  number := 0;
  prev_scnwrp  number := 0;
  prev_rbasqn  number := 0;
  prev_rbablk  number := 0;
  prev_rbabyte number := 0;
  loc_logmnr_uid number;
  loc_redo_thread number;
  loc_scnbas  number;
  loc_scnwrp  number;
  loc_rbasqn  number;
  loc_rbablk  number;
  loc_rbabyte number;
  loc_rowid urowid;
begin
  open rcur1 for
         'select logmnr_uid, redo_thread, end_scnbas, end_scnwrp,
                 NVL(rbasqn,-1), NVL(rbablk,-1), NVL(rbabyte,-1),  rowid
            from system.logmnr_dictstate$
            order by logmnr_uid asc, redo_thread asc,
                     end_scnwrp desc, end_scnbas desc,
                     start_scnwrp desc, start_scnbas desc,
                     5, 6, 7';
  loop
    fetch rcur1 into loc_logmnr_uid, loc_redo_thread, 
                     loc_scnbas, loc_scnwrp,
                     loc_rbasqn, loc_rbablk, loc_rbabyte,
                     loc_rowid;
    exit when rcur1%notfound;
    if ((loc_logmnr_uid = prev_logmnr_uid) and
        (loc_redo_thread = prev_redo_thread) and
        (loc_scnbas = prev_scnbas) and
        (loc_scnwrp = prev_scnwrp) and
        (loc_rbasqn = prev_rbasqn) and
        (loc_rbablk = prev_rbablk) and
        (loc_rbabyte = prev_rbabyte)) then
      execute immediate 
          'delete from system.logmnr_dictstate$
                 where rowid = :1' using loc_rowid;
    else
      prev_logmnr_uid := loc_logmnr_uid;
      prev_redo_thread := loc_redo_thread;
      prev_scnbas := loc_scnbas;
      prev_scnwrp := loc_scnwrp;
      prev_rbasqn := loc_rbasqn;
      prev_rbablk := loc_rbablk;
      prev_rbabyte := loc_rbabyte;
    end if;
  end loop;
  commit;
end;
/

-- bug 3923511 set obj$ remoteowner/linkname values to 'UNKNOWN'
--
update SYSTEM.LOGMNR_OBJ$ O
   set o.linkname = 'UNKNOWN', 
       o.remoteowner = 'UNKNOWN'
 where o.linkname IS NULL and o.remoteowner IS NULL and o.type# = 2
   and o.obj# NOT IN 
       (select obj# from SYSTEM.LOGMNR_TAB$ t 
        where o.logmnr_uid = t.logmnr_uid);
commit;

/* bug 4352127
 * Buildlog and gather tables must be in SYSTEM.  Gather tables
 * are recreated with each release, buildlog must be moved to cover
 * the 10.1 to 10.2 upgrade case.
 */
alter table sys.logmnr_buildlog move tablespace SYSTEM;
alter index sys.logmnr_buildlog_pk rebuild tablespace SYSTEM;

CREATE TABLE SYSTEM.LOGMNR_PARAMETER$ (
                session#        number not null,
                name            varchar2(30) not null,
                value           varchar2(2000),
                type            number,
                scn             number,
                spare1          number,
                spare2          number,
                spare3          varchar2(2000))
            TABLESPACE SYSTEM LOGGING;

CREATE INDEX SYSTEM.LOGMNR_PARAMETER_INDX ON 
                SYSTEM.LOGMNR_PARAMETER$(SESSION#, name) 
            TABLESPACE SYSTEM LOGGING;

-- bug # 4219586
-- For 10.2 we want to remove next_change# from the primary key definition.
-- Next_change# may not have been present in the key for 9.2 but was there
-- for 10.1.  To ensure that the new primary key will be unique for all
-- rows currently in logmnr_log$, we remove potential duplicats such that
-- only the duplicate with the largest next_change# remains.

declare
  sess# number := 0;
  thrd# number := 0;
  sequ# number := 0;
  fchg# number := 0;
  dbid  number := 0;
  rchg# number := 0;
  rtime number := 0;
  newrid rowid := null;
  oldrid rowid := null;
begin
  for log_rec in (select SESSION#, THREAD#, SEQUENCE#, FIRST_CHANGE#, DB_ID,
                  RESETLOGS_CHANGE#, RESET_TIMESTAMP, rowid rid
                  from system.logmnr_log$ 
                  order by SESSION#, THREAD#, SEQUENCE#, FIRST_CHANGE#, DB_ID,
                  RESETLOGS_CHANGE#, RESET_TIMESTAMP, next_change#) loop
    if (log_rec.session# = sess# AND
        log_rec.thread# = thrd# AND
        log_rec.sequence# = sequ# AND
        log_rec.first_change# = fchg# AND
        log_rec.db_id = dbid AND
        log_rec.resetlogs_change# = rchg# AND
        log_rec.reset_timestamp = rtime) THEN
      newrid := log_rec.rid;
      delete from system.logmnr_log$ where rowid = oldrid;
      oldrid := newrid;
   else
      sess# := log_rec.session#;
      thrd# := log_rec.thread#;
      sequ# := log_rec.sequence#;
      fchg# := log_rec.first_change#;
      dbid := log_rec.db_id;
      rchg# := log_rec.resetlogs_change#;
      rtime := log_rec.reset_timestamp;
      oldrid := log_rec.rid;
   end if;
 end loop;
 commit;
end;
/

alter table SYSTEM.LOGMNR_LOG$ drop primary key cascade;

alter table SYSTEM.LOGMNR_LOG$ add constraint LOGMNR_LOG$_PK
     primary key (SESSION#, THREAD#, SEQUENCE#, FIRST_CHANGE#, DB_ID,
                  RESETLOGS_CHANGE#, RESET_TIMESTAMP)
     USING INDEX TABLESPACE SYSAUX LOGGING;

alter table system.logmnr_log$ modify (next_change# null);

CREATE GLOBAL TEMPORARY TABLE system.logmnrt_mddl$ (
                  source_obj#     NUMBER,
                  source_rowid    ROWID,
                  dest_rowid      ROWID NOT NULL,
                    CONSTRAINT logmnrt_mddl$_pk
                      PRIMARY KEY(source_obj#, source_rowid)
                  ) on commit delete rows;

Rem ====================
Rem End Logminer Upgrade
Rem ====================

Rem=========================================================================
Rem Begin SQL Response Time upgrade items
Rem=========================================================================

drop table dbsnmp.mgmt_response_v$sql_snapshot;
drop table dbsnmp.mgmt_response_baseline;
drop table dbsnmp.mgmt_response_capture;
drop table dbsnmp.mgmt_response_config;
drop table dbsnmp.mgmt_response_tempt;
drop sequence dbsnmp.mgmt_response_capture_id;
drop sequence dbsnmp.mgmt_response_snapshot_id;

Rem=========================================================================
Rem Begin SQL Response Time upgrade items
Rem=========================================================================


Rem ========================================================================
Rem Upgrade system types to 10.2
Rem ========================================================================
Rem Evolve Type sys.aq$_reg_info

-- Turn ON the event to enable DDL on AQ tables
alter session set events  '10851 trace name context forever, level 1';

ALTER TYPE sys.aq$_reg_info
ADD ATTRIBUTE(qosflags NUMBER, payloadcbk  VARCHAR2(4000), timeout NUMBER)
CASCADE;

ALTER TYPE sys.aq$_reg_info ADD CONSTRUCTOR FUNCTION aq$_reg_info(
  name             VARCHAR2,
  namespace        NUMBER,
  callback         VARCHAR2,
  context          RAW,
  anyctx           SYS.ANYDATA,
  ctxtype          NUMBER)
RETURN SELF AS RESULT CASCADE;

ALTER TYPE sys.aq$_reg_info ADD CONSTRUCTOR FUNCTION aq$_reg_info(
  name             VARCHAR2,
  namespace        NUMBER,
  callback         VARCHAR2,
  context          RAW,
  qosflags         NUMBER,
  timeout          NUMBER)
RETURN SELF AS RESULT CASCADE;

ALTER TYPE sys.aq$_event_message MODIFY ATTRIBUTE
(sub_name VARCHAR2(128), queue_name VARCHAR2(65)) CASCADE
/

ALTER TYPE sys.aq$_srvntfn_message MODIFY ATTRIBUTE
queue_name VARCHAR2(65) CASCADE
/
-- create type for storing generic ntfn descriptor for plsql notification
-- and add the type as an atribute to aq$_descriptor
CREATE or replace TYPE sys.aq$_ntfn_descriptor AS OBJECT (
        ntfn_flags         number)                     -- flags
/
ALTER TYPE sys.aq$_descriptor
  ADD ATTRIBUTE(gen_desc sys.aq$_ntfn_descriptor)
  CASCADE
/

ALTER TYPE sys.aq$_descriptor MODIFY ATTRIBUTE
queue_name VARCHAR2(65) CASCADE
/

ALTER TYPE sys.aq$_post_info MODIFY ATTRIBUTE
payload RAW(32767) CASCADE
/

-- Turn OFF the event to disable DDL on AQ tables
alter session set events  '10851 trace name context off';

Rem ========================================================================
Rem  All additions/modifications to lcr$_{row,ddl}_record must go here.
Rem ========================================================================

ALTER TYPE lcr$_row_record ADD MEMBER FUNCTION
   get_source_time RETURN DATE CASCADE;

ALTER TYPE lcr$_ddl_record ADD MEMBER FUNCTION
   get_source_time RETURN DATE CASCADE;
Rem Evolve Type sys.aq$_reg_info

Rem Change notification types
create or replace type sys.chnf$_reg_info_oc4j as object (
       network_ip_address varchar2(128),
       network_port number,
       qosflags number,
       timeout number,
       operations_filter number,
       transaction_lag number)
/

create or replace type sys.chnf$_reg_info as object (
       callback varchar2(64),
       qosflags number,
       timeout number,
       operations_filter number,
       transaction_lag number)
/

create or replace type chnf$_rdesc as object(
   opflags number,
   row_id varchar2(2000))
/

create or replace type chnf$_rdesc_array as VARRAY(1024) of chnf$_rdesc
/

create or replace type chnf$_tdesc as object(
   opflags number,
   table_name varchar2(64),
   numrows number,
   row_desc_array chnf$_rdesc_array)
/

create or replace type chnf$_tdesc_array as VARRAY(1024) of chnf$_tdesc
/

create or replace type chnf$_desc as object(
   registration_id number,
   transaction_id  raw(8),
   dbname          varchar2(30),
   event_type      number,
   numtables       number,
   table_desc_array   chnf$_tdesc_array)
/


GRANT EXECUTE on chnf$_reg_info_oc4j to PUBLIC;
/
GRANT EXECUTE on chnf$_reg_info to PUBLIC;
/
GRANT EXECUTE on chnf$_desc to PUBLIC;
/
GRANT EXECUTE on chnf$_tdesc to PUBLIC;
/
GRANT EXECUTE on chnf$_rdesc to PUBLIC;

Rem End change notification types

CREATE OR REPLACE LIBRARY UPGRADE_LIB TRUSTED AS STATIC
/

CREATE OR REPLACE PROCEDURE upgrade_system_types_from_101 IS
LANGUAGE C
NAME "UPG_FROM_101"
LIBRARY UPGRADE_LIB;
/

DROP PROCEDURE upgrade_system_types_from_101;

Rem -----------------------------
Rem  SQL Tuning Set type changes
Rem -----------------------------

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

Rem =========================
Rem Begin bug-4390868 changes

ALTER SEQUENCE sys.audses$ CACHE 10000
/

Rem End bug-4390868 changes
Rem =======================

Rem =====================
Rem Begin outline changes
Rem ===================== 

Rem  OUTLN user priv changes
revoke connect from outln;
grant create session to outln;

Rem Add hint_string to outln.ol$hints
alter table outln.ol$hints add (hint_string clob);

Rem Add hint_string to system.ol$hints
alter table system.ol$hints add (hint_string clob);

Rem ===================
Rem End outline changes
Rem =================== 


Rem ========================
Rem Begin dbms_xplan changes
Rem ======================== 

alter type dbms_xplan_type modify attribute (plan_table_output varchar2(300)) cascade;

Rem ======================
Rem End dbms_xplan changes
Rem ====================== 

Rem -----------------------------
Rem  dbms_sched_main_export changes
Rem -----------------------------
revoke execute on dbms_sched_main_export from public;
drop public synonym dbms_sched_main_export;

Rem ----------------------------------------------------------------
Rem  3074260: Function-based indexes should use REF dependencies
Rem ----------------------------------------------------------------

update dependency$
  set property = 2
  where property = 1
    and d_obj# in (select obj# from ind$ i 
                     where bitand(i.property, 16) = 16)
    and p_obj# in (select obj# from obj$ o where type# in (8,9));

Rem
Rem The table settings$ stores the persistent switches for all stored PL/SQL
Rem units. The plsql_ccflags switch did not exist in pre-10gR2 releases.
Rem The default value of plsql_ccflags is the empty string ''. We need to
Rem insert rows into the settings$ table so that each stored PL/SQL unit
Rem will have a row containing the empty string '' for the plsql_ccflags
Rem switch.
Rem
insert into settings$
  (select unique(obj#), 'plsql_ccflags', '' from settings$ MINUS
   select obj#, param, '' from settings$ where param = 'plsql_ccflags');
commit;

Rem=========================================================================
Rem END STAGE 1: upgrade from 10.1.0 to 10.2.0
Rem=========================================================================

Rem
Rem Invoke script for subsequent release
Rem 

@@c1002000

Rem*************************************************************************
Rem END c1001000.sql
Rem*************************************************************************
