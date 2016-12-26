Rem
Rem $Header: rdbms/admin/c1102000.sql /st_rdbms_11.2.0.4.0dbpsu/1 2014/07/15 16:24:41 jerrede Exp $
Rem
Rem c1102000.sql
Rem
Rem Copyright (c) 2009, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      c1102000.sql - Script to apply current release patch release
Rem
Rem    DESCRIPTION
Rem      This script encapsulates the "post install" steps necessary
Rem      to upgrade the SERVER dictionary to the new patchset version.
Rem      It runs the new patchset versions of catalog.sql and catproc.sql
Rem      and calls the component patch scripts.
Rem
Rem    NOTES
Rem      Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      The database must be open for UPGRADE.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      07/06/14 - Backport apfwkr_blr_backport_17267114_11.2.0.4
Rem                           from st_rdbms_11.2.0
Rem    apfwkr      01/11/14 - Backport
Rem                           jerrede_blr_backport_17267114_11.2.0.3.21exadbbp
Rem                           from st_rdbms_11.2.0.3.0exadbbp
Rem    jovillag    05/09/13 - Backport jovillag_bug-16047985 from main
Rem    pknaggs     04/16/13 - Bug #16516022: full redaction uses space, not
Rem                           blank.
Rem    himagarw    04/08/13 - Backport himagarw_bug-16411833 from main
Rem    csantelm    02/26/13 - Bug 14377554
Rem    avangala    02/13/13 - lrg 8532726
Rem    schakkap    05/17/12 - #(13898075) Increase size of
Rem                           optstat_user_prefs$.valchar
Rem    shiyadav    01/28/13 - Backport shiyadav_bug-14125108 from main
Rem    anighosh    01/16/13 - Backport anighosh_bug-14296972 from MAIN
Rem    acakmak     12/13/12 - Backport acakmak_41376_optimizer_stats_hist_purge
Rem    cchiappa    12/10/12 - Backport
Rem                           cchiappa_bug-10332890_olap_full_transport
Rem                           (10332890 - OLAP / AW SUPPORT FOR FULL DATABASE
Rem                           TRANSPORTABLE EXPORT / IMPORT)
Rem    vpriyans    11/02/12 - Backport vpriyans_bug-12904308 from main
Rem    pstengar    11/13/12 - BP 14585239: change SELECT MINING MODEL to 299
Rem                           in STMT_AUDIT_OPTION_MAP
Rem    apfwkr      03/27/12 - Backport jmuller_bug-11720698 from main
Rem    huntran     05/03/12 - Add error_seq#/error_rba/error_index# for error
Rem                           table
Rem    elu         04/10/12 - add persistent apply tables
Rem    elu         03/20/12 - xin persistent table stats
Rem    tianli      03/12/12 - Add seq#/rba/index for error tables
Rem    jmuller     02/16/12 - Fix bug 11720698: clean up warning_settings$ on
Rem                           lu drop
Rem    gkulkarn    09/17/12 - BP:14527495: Fix setting of
Rem                           logmnr_session$.spare1
Rem    pknaggs     09/04/12 - Bug #14151458: Add table radm_fptm_lob$.
Rem    pknaggs     09/04/12 - Bug #14133343: Add radm_td$ and radm_cd$ tables.
Rem    huntran     09/02/12 - Backport huntran_bug-13471035 from
Rem    apfwkr      08/20/12 - Backport shiyadav_bug-14320459 from
Rem    vgerard     08/15/12 - set_by backport
Rem    apfwkr      08/10/12 - Backport vgerard_bug-14284283 from
Rem    apfwkr      07/03/12 - Backport shjoshi_rm_newtype from main
Rem    praghuna    07/01/12 - Backport praghuna_bug-13110976 from main
Rem    yujwang     06/12/12 - Backport
Rem                           apfwkr_blr_backport_13947480_11.2.0.3.2dbpsu from
Rem                           st_rdbms_11.2.0.3.0dbpsu
Rem    jkundu      06/04/12 - bp 13615340: always log group on seq
Rem    cchiappa    03/15/12 - Backport cchiappa_bug-12957533 from main
Rem    pknaggs     02/01/12 - proj #44284 (RADM): add radm$ and radm_fptm$
Rem    paestrad    01/17/12 - Removing SCHEDULER_UTIL
Rem    jerrede     10/11/13 - Fix bug 17267114 Convert Data backport
Rem    jomcdon     08/03/11 - lrg 5758311: fix resource manager upgrade
Rem    yurxu       07/18/11 - Backport yurxu_bug-12701917 from main
Rem    sanagara    07/13/11 - 12326358: add spare columns to sqlerror$
Rem    shiyadav    07/08/11 - Backport shiyadav_bug-12317689 from main
Rem    bhammers    07/01/11 - Backport bhammers_bug-12674093 from main
Rem    elu         06/06/11 - Backport elu_bug-12592488 from main
Rem    yurxu       05/04/11 - Backport yurxu_bug-12391440 from main
Rem    schakkap    12/23/10 - #(10410249) create col_group_usage$ as a non iot
Rem                           table
Rem    rramkiss    05/03/11 - Backport rramkiss_bug-12319196 from main
Rem    yurxu       04/12/11 - Backport yurxu_bug-11922716 from main
Rem    bpwang      04/14/11 - Backport bpwang_bug-11815316 from main
Rem    abrown      04/11/11 - Backport abrown_bug-11737200 from main
Rem    elu         03/23/11 - Backport elu_bug-9690366 from main
Rem    elu         03/03/11 - Backport elu_bug-11725453 from main
Rem    sdavidso    03/08/11 - add columns to metascript$ for full export
Rem    elu         02/19/11 - lcr changes
Rem    msakayed    02/18/11 - Bug #11787333: upsert STMT_AUDIT_OPTION_MAP 
Rem    gclaborn    02/17/11 - Add new flag defs in impcalloutreg$
Rem    elu         05/25/11 - remove xml schema
Rem    huntran     01/13/11 - conflict, error, and collision handlers
Rem    elu         01/12/11 - error queue
Rem    ilistvin    01/06/11 - Backport ilistvin_bug-10427840 from main
Rem    gclaborn    12/14/10 - add tgt_type to impcalloutreg$
Rem    gclaborn    09/15/10 - add impcalloutreg$
Rem    hosu        08/09/10 - lrg 4817143
Rem    elu         02/16/11 - modify eager_size
Rem    qiwang      06/04/10 - add logmnr integrated spill table
Rem                         - (gkulkarn) Set logmnr_session$.spare1 to zero
Rem                           on upgrade
Rem    nalamand    06/03/10 - Bug-9765326, 9747794: Add missing default 
Rem                           passwords
Rem    rangrish    06/02/10 - revoke grant on urifactory on upgrade
Rem    thoang      06/01/10 - handle lowercased user name
Rem    schakkap    05/23/10 - #(9577300) add table to record column group usage
Rem    hosu        05/10/10 - upgrade wri$_optstat_synopsis$
Rem    tbhosle     05/04/10 - 8670389: increase regid seq cache size, move 
Rem                           session key into reg$
Rem    thoang      04/27/10 - change Streams parameter names
Rem    hosu        04/09/10 - reduce subpartition number in wri$_optstat_synopsis$
Rem    hosu        03/30/10 - 4545922: disable partitioning check
Rem    bdagevil    03/14/10 - add px_flags column to
Rem                           WRH$_ACTIVE_SESSION_HISTORY
Rem    yurxu       03/05/10 - Bug-9469148: modify goldengate$_privileges
Rem    dongfwan    03/01/10 - Bug 9266913: add snap_timezone to wrm$_snapshot
Rem    apsrivas    01/12/10 - Bug 9148218, add def pwds for APR_USER and
Rem                           ARGUSUSER
Rem    jomcdon     02/10/10 - bug 9368895: add parallel_queue_timeout
Rem    hosu        02/15/10 - 9038395: wri$_optstat_synopsis$ schema change
Rem    jomcdon     02/10/10 - Bug 9207475: allow end_time to be null
Rem    sburanaw    02/04/10 - Add DB Replay callid to ASH
Rem    juyuan      02/03/10 - add lcr$_row_record.get_object_id
Rem    akociube    02/02/10 - Fix OLAP revoke order
Rem    sburanaw    01/08/10 - add filter_set to wrr$_replays
Rem                           add default_action to wrr$_replay_filter_set
Rem    juyuan      01/21/10 - remove all_streams_stmt_handlers and
Rem                           all_streams_stmts
Rem    jomcdon     12/31/09 - bug 9212250: add PQQ fields to AWR tables
Rem    juyuan      12/27/09 - create goldengate$_privileges
Rem    akociube    12/21/09 - Bug 9226807 revoke permissions
Rem    amadan      11/19/09 - Bug 9115881 Add new columns to PERSISTENT_QUEUES
Rem    arbalakr    11/12/09 - increase length of module and action columns
Rem    akruglik    11/18/09 - 31113 (SCHEMA SYNONYMS): adding support for 
Rem                           auditing CREATE/DROP SCHEMA SYNONYM
Rem    jomcdon     12/03/09 - project 24605: clear max_active_sess_target_p1
Rem    xingjin     11/14/09 - Bug 9086576: modify construct in lcr$_row_record
Rem    akruglik    11/10/09 - add/remove new audit_actions rows
Rem    gravipat    10/27/09 - Add sqlerror$ creation
Rem    hayu        10/01/09 - change the advisor/spa
Rem    msakayed    10/28/09 - Bug #5842629: direct path load auditing
Rem    praghun     11/03/09 - Added some spare columns to milestone table
Rem    thoang      10/13/09 - support uncommitted data mode
Rem    tianli      10/11/09 - add xstream$_parameters table
Rem    elu         10/06/09 - stmt lcr
Rem    praghuna    10/19/09 - Added start_scn_time, first_scn_time
Rem    msakayed    10/22/09 - Bug #8862486: AUDIT_ACTION for directory execute
Rem    lgalanis    10/20/09 - STS capture for DB Replay
Rem    achoi       09/21/09 - edition as a service attribute
Rem    shbose      09/18/09 - Bug 8764375: add destq column to aq$_schedules
Rem    cdilling    07/31/09 - Patch upgrade script for 11.2.0
Rem    cdilling    07/31/09 - Created
Rem

Rem *************************************************************************
Rem BEGIN c1102000.sql
Rem *************************************************************************

Rem *************************************************************************
Rem START Bug 17267114
Rem *************************************************************************

--
-- Guarantee that object types without super types
-- have a NULL super type object ID
--
update sys.type$ set supertoid=null where 
        supertoid='00000000000000000000000000000000';
commit;

Rem *************************************************************************
Rem END Bug 17267114
Rem *************************************************************************


Rem =======================================================================
Rem  Begin Changes for XStream
Rem =======================================================================

Rem
Rem Add some spare columns for apply optimization purpose
Rem
alter table streams$_apply_milestone add
(spare8 number, spare9 number, spare10 timestamp, spare11 timestamp);

alter type lcr$_row_record add member function
   is_statement_lcr return varchar2 cascade;

alter type lcr$_row_record add member procedure
   set_row_text(self in out nocopy lcr$_row_record,
                row_text           IN CLOB,
                variable_list IN sys.lcr$_row_list DEFAULT NULL,
                bind_by_position in varchar2 DEFAULT 'N') cascade;

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
     position                   in raw               DEFAULT NULL,
     statement                  in varchar2          DEFAULT NULL,
     bind_variables             in sys.lcr$_row_list DEFAULT NULL,
     bind_by_position           in varchar2          DEFAULT 'N'
   )  RETURN lcr$_row_record cascade;

alter type lcr$_row_record add member function
   get_base_object_id return number cascade;

alter type lcr$_row_record add member function
   get_object_id return number cascade;

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
     edition_name               in varchar2          DEFAULT NULL
   )
   RETURN lcr$_ddl_record cascade;

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

alter type lcr$_ddl_record add STATIC FUNCTION construct(
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

alter type lcr$_ddl_record add MEMBER FUNCTION get_current_user
   RETURN varchar2 cascade;

alter type lcr$_ddl_record add MEMBER PROCEDURE set_current_user
    (self in out nocopy lcr$_ddl_record, current_user IN VARCHAR2) cascade;

alter table sys.streams$_apply_milestone add
(
  eager_error_retry              number /* number of retries for eager error */
);

alter table sys.apply$_error add
(
  retry_count           number,         /* number of times to retry an error */
  flags                 number                                      /* flags */
);

alter table sys.apply$_error_txn add
(
  error_number         number,                      /* error number reported */
  error_message        varchar2(4000),               /* explanation of error */
  flags                number,                                      /* flags */
  spare1               number,
  spare2               number,
  spare3               varchar2(4000),
  spare4               varchar2(4000),
  spare5               raw(2000),
  spare6               timestamp
);

alter table sys.apply$_error_txn add
(
  source_object_owner  varchar2(30),         /* source database object owner */
  source_object_name   varchar2(30),          /* source database object name */
  dest_object_owner    varchar2(30),           /* dest database object owner */
  dest_object_name     varchar2(30),            /* dest database object name */
  primary_key          varchar2(4000),            /* primary key information */
  position             raw(64),                              /* LCR position */
  message_flags        number,                              /* knlqdqm flags */
  operation            varchar2(100)                        /* LCR operation */
);

--
-- Table to for ddl conflict handlers
--
create table xstream$_ddl_conflict_handler
(
  apply_name        varchar2(30) not null,                     /* apply name */
  conflict_type     varchar2(4000) not null,                /* conflict type */
  include           clob,                                /* inclusion clause */
  exclude           clob,                                /* exclusion clause */
  method            clob,                   /* method for resolving conflict */
  spare1            number,
  spare2            number,
  spare3            number,
  spare4            timestamp,
  spare5            varchar2(4000),
  spare6            varchar2(4000),
  spare7            clob,
  spare8            clob,
  spare9            raw(100)
)
/
create index i_xstream_ddl_conflict_hdlr1 on
  xstream$_ddl_conflict_handler(apply_name)
/

--
-- Table to for ddl conflict handlers
--
create table xstream$_map
(
  apply_name        varchar2(30) not null,                     /* apply name */
  src_obj_owner     varchar2(30),                      /*source object owner */
  src_obj_name      varchar2(100) not null,            /* source object name */
  tgt_obj_owner     varchar2(30),                     /* target object owner */
  tgt_obj_name      varchar2(100) not null,            /* target object name */
  colmap            clob,                       /* column mapping definition */
  sqlexec           clob,                              /* SQLEXEC definition */
  sequence          number,                      /* order of mapping clauses */
  spare1            number,
  spare2            number,
  spare3            number,
  spare4            timestamp,
  spare5            varchar2(4000),
  spare6            varchar2(4000),
  spare7            clob,
  spare8            clob,
  spare9            raw(100)
)
/
create index i_xstream_map1 on
  xstream$_map(apply_name)
/

Rem
Rem table for apply table stats
Rem
create table apply$_table_stats 
(
apply#                     number,                   /* apply process number */
server_id                  number,                /* apply server identifier */
save_time                  date,                /* when stats were persisted */
source_table_owner         varchar2(30),               /* source table owner */
source_table_name          varchar2(30),                /* source table name */
destination_table_owner    varchar2(30),          /* destination table owner */
destination_table_name     varchar2(30),           /* destination table name */
last_update                date,    /*last time stats for table were updated */
total_inserts              number,  /* total number of inserts for the table */
total_updates              number,  /* total number of updates for the table */
total_deletes              number,  /* total number of deletes for the table */
insert_collisions          number,    /* num insert collisions for the table */
update_collisions          number,    /* num update collisions for the table */
delete_collisions          number,   /* num delete collisionss for the table */
reperror_records           number,  /* num colls resolved by reperror record */
reperror_ignores           number,  /* num colls resolved by reperror ignore */
wait_dependencies          number,            /* number of wait dependencies */
cdr_insert_row_exists      number,  /* number of insert row exists conflicts */
cdr_update_row_exists      number,  /* number of update row exists conflicts */
cdr_update_row_missing     number, /* number of update row missing conflicts */
cdr_delete_row_exists      number,  /* number of delete row exists conflicts */
cdr_delete_row_missing     number, /* number of delete row missing conflicts */
cdr_successful_resolutions number,   /* number of successful CDR resolutions */
cdr_failed_resolutions     number,       /* number of failed CDR resolutions */
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    varchar2(4000),
spare12                    varchar2(4000),
spare13                    varchar2(4000),
spare14                    varchar2(4000),
spare15                    raw(1000),
spare16                    raw(1000),
spare17                    raw(1000),
spare18                    date,
spare19                    date,
spare20                    date
)
/
create index apply$_table_stats_i
  on apply$_table_stats (apply#, server_id, save_time)
/


rem XStream In persistent apply coodinator table 
create table apply$_coordinator_stats
(
apply#                     number,                   /* apply process number */
save_time                  date,                /* when stats were persisted */
apply_name                 varchar2(30),               /* apply process name */
state                      number,                      /* coordinator state */
total_applied              number,                           /* txns applied */
total_waitdeps             number,             /* WAIT_DEP messages received */
total_waitcommits          number,          /* WAIT_COMMIT messages received */
total_admin                number,                  /* admin requests issued */
total_assigned             number,                          /* txns assigned */
total_received             number,                           /* txn received */
total_ignored              number,                 /* number of txns ignored */
total_rollbacks            number,            /* number of rollback attempts */
total_errors               number,  /* number of txns which errored on apply */
unassigned_eager           number,        /* number of unassigned eager txns */
unassigned_complete        number,     /* number of unassigned complete txns */
auto_txnbufsize            number,      /* Auto adjusted value of txnbufsize */
startup_time               date,           /* SYSDATE when the apply started */
lwm_time                   date,                     /* time lwm was updated */
lwm_msg_num                number,                       /* lwm number (SCN) */
lwm_msg_time               date,             /* creation time of lwm message */
hwm_time                   date,                     /* time hwm was updated */
hwm_msg_num                number,                       /* hwm number (SCN) */
hwm_msg_time               date,             /* creation time of hwm message */
elapsed_schedule_time      number,       /* time elapsed scheduling messages */
elapsed_idle_time          number,                /* time elapsed being idle */
lwm_position               raw(64),         /* low watermark commit position */
hwm_position               raw(64),        /* high watermark commit position */
processed_msg_num          number,             /* processed msg number (SCN) */
flag                       number,                       /* coordinator flag */
flags_factoring            number,                           /* factor flags */
replname                   varchar2(30),     /* name of the replicat process */
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    varchar2(4000),
spare12                    varchar2(4000),
spare13                    varchar2(4000),
spare14                    varchar2(4000),
spare15                    raw(1000),
spare16                    raw(1000),
spare17                    raw(1000),
spare18                    date,
spare19                    date,
spare20                    date
);
create index apply$_coordinator_stats_i
  on apply$_coordinator_stats (apply#, save_time)
/

rem XStream In persistent apply server table 
create table apply$_server_stats
(
apply#                     number,                   /* apply process number */
server_id                  number,                /* apply server identifier */
save_time                  date,                /* when stats were persisted */
apply_name                 varchar2(30),               /* apply process name */
state                      number,                     /* apply server state */
startup_time               date,           /* SYSDATE when the apply started */
xid_usn                    number,   /* xid usn of transaction being applied */
xid_slt                    number,   /* xid slt of transaction being applied */
xid_sqn                    number,   /* xid sqn of transaction being applied */
cscn                       number,      /* commit scn of current transaction */
depxid_usn                 number,       /* xid usn of txn server depends on */
depxid_slt                 number,       /* xid slt of txn server depends on */
depxid_sqn                 number,       /* xid sqn of txn server depends on */
depcscn                    number,    /* commit scn of txn server depends on */
msg_num                    number,          /* current message being applied */
total_assigned             number,          /* total txns assigned to server */
total_admin                number,   /* total admin tasks assigned to server */
total_rollbacks            number,       /* total number of txns rolled back */
total_msg                  number,       /* total number of messages applied */
last_apply_time            date,            /* time last message was applied */
last_apply_msg_num         number,         /* number of last message applied */
last_apply_msg_time        date,    /* creation time of last applied message */
elapsed_apply_time         number,         /* time elapsed applying messages */
commit_position            raw(64),    /* commit position of the transaction */
dep_commit_position        raw(64),   /* commit pos of txn server depends on */
last_apply_pos             raw(64),      /* position of last message applied */
flag                       number,                                  /* flags */
nosxid                     varchar2(128),   /* txn id that slave is applying */
depnosxid                  varchar2(128),        /* txn id slave depends on  */
max_inst_scn               number,              /* maximum instantiation SCN */
total_waitdeps             number,      /* total number of wait dependencies */
total_lcrs_retried         number,           /* total number of lcrs retried */
total_txns_retried         number,           /* total number of txns retried */
txn_retry_iter             number,            /* current txn retry iteration */
lcr_retry_iter             number,            /* current lcr retry iteration */
total_txns_discarded       number,    /* txns handled by reperror RECORD_TXN */
flags_factoring            number,                        /* factoring flags */
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    varchar2(4000),
spare12                    varchar2(4000),
spare13                    varchar2(4000),
spare14                    varchar2(4000),
spare15                    raw(1000),
spare16                    raw(1000),
spare17                    raw(1000),
spare18                    date,
spare19                    date,
spare20                    date
);
create index apply$_server_stats_i
  on apply$_server_stats (apply#, server_id, save_time)
/

rem XStream In persistent apply reader table 
create table apply$_reader_stats
(
apply#                     number,                   /* apply process number */
save_time                  date,                /* when stats were persisted */
apply_name                 varchar2(30),               /* apply process name */
state                      number,                     /* apply reader state */
startup_time               date,           /* SYSDATE when the apply started */
msg_num                    number,          /* current message being applied */
total_msg                  number,       /* total number of messages applied */
total_spill_msg            number,   /* the total number of messages spilled */
last_rcv_time              date,           /* time last message was received */
last_rcv_msg_num           number,        /* number of last message received */
last_rcv_msg_time          date,           /* creation time of last received */
sga_used                   number,                        /* SGA memory used */
elapsed_dequeue_time       number,        /* time elapsed dequeuing messages */
elapsed_schedule_time      number,       /* time elapsed scheduling messages */
elapsed_spill_time         number,         /* time elapsed spilling messages */
last_browse_num            number,                        /* last browse SCN */
oldest_scn_num             number,                             /* oldest SCN */
last_browse_seq            number,            /* last browse sequence number */
last_deq_seq               number,           /* last dequeue sequence number */
oldest_xid_usn             number,                         /* oldest xid usn */
oldest_xid_slt             number,                         /* oldest xid slt */
oldest_xid_sqn             number,                         /* oldest xid sqn */
spill_lwm_scn              number,                /* spill low watermark SCN */
commit_position            raw(64),    /* commit position of the transaction */
last_rcv_pos               raw(64),             /* position of last received */
last_browse_pos            raw(64),                  /* last browse position */
oldest_pos                 raw(64),                       /* oldest position */
spill_lwm_pos              raw(64),          /* spill low watermark position */
flag                       number,                                  /* flags */
oldest_xidtxt              varchar2(128),           /* oldest transaction id */
num_deps                   number,                 /* number of dependencies */
num_dep_lcrs               number,            /* number of lcrs with txn dep */
num_wmdeps                 number             ,/* number of lcrs with WM dep */
num_in_memory_lcrs         number,           /* number of knallcrs in memory */
sga_allocated              number,  /* total sga allocated from streams pool */
total_lcrs_retried         number,           /* total number of lcrs retried */
total_txns_retried         number,           /* total number of txns retried */
txn_retry_iter             number,            /* current txn retry iteration */
lcr_retry_iter             number,            /* current lcr retry iteration */
total_txns_discarded       number,    /* txns handled by reperror RECORD_TXN */
flags_factoring            number,                        /* factoring flags */
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    varchar2(4000),
spare12                    varchar2(4000),
spare13                    varchar2(4000),
spare14                    varchar2(4000),
spare15                    raw(1000),
spare16                    raw(1000),
spare17                    raw(1000),
spare18                    date,
spare19                    date,
spare20                    date
);
create index apply$_reader_stats_i
  on apply$_reader_stats (apply#, save_time)
/

rem stores persistent batch sql statistics for the apply servers
create table apply$_batch_sql_stats
(
apply#                     number,                   /* apply process number */
save_time                  date,                /* when stats were persisted */
server_id                  number,                /* apply server identifier */
batch_opeations            number,
batches                    number,
batches_executed           number,
queues                     number,
batches_in_error           number,
normal_mode_ops            number,
immediate_flush_ops        number,
pk_collisions              number,
uk_collisions              number,
fk_collisions              number,
thread_batch_groups        number,
num_commits                number,
num_rollbacks              number,
queue_flush_calls          number,
ops_per_batch              number,
ops_per_batch_executed     number,
ops_per_queue              number,
parallel_batch_rate        number,
spare1                     number,
spare2                     number,
spare3                     number,
spare4                     number,
spare5                     number,
spare6                     number,
spare7                     number,
spare8                     number,
spare9                     number,
spare10                    number,
spare11                    number,
spare12                    number,
spare13                    number,
spare14                    number,
spare15                    number,
spare16                    varchar2(4000),
spare17                    varchar2(4000),
spare18                    varchar2(4000),
spare19                    varchar2(4000),
spare20                    raw(1000),
spare21                    raw(1000),
spare22                    raw(1000),
spare23                    date,
spare24                    date,
spare25                    date
);
create index apply$_batch_sql_stats_i
  on apply$_batch_sql_stats (apply#, server_id, save_time)
/

Rem
Rem Add time parameters for scn
Rem
ALTER TABLE streams$_capture_process ADD 
(
  start_scn_time      date , 
  first_scn_time      date 
);

Rem
Rem Table for xstream parameters 
Rem
create table xstream$_parameters
(
  server_name       varchar2(30) not null,            /* XStream server name */
  server_type       number not null,         /* 0 for outbond, 1 for inbound */
  position          number not null,    /* total ordering for the parameters */
  param_key         varchar2(100),               /* keyword in the parameter */
  schema_name       varchar2(30),                   /* optional, no wildcard */
  object_name       varchar2(30),               /* optional, can do wildcard */
  user_name         varchar2(30),                           /* creation user */
  creation_time     timestamp,                              /* creation time */
  modification_time timestamp,                          /* modification time */
  flags             number,                              /* unused right now */
  details           clob,                           /* the parameter details */
  spare1            number,
  spare2            number,
  spare3            number,
  spare4            timestamp,
  spare5            varchar2(4000),
  spare6            varchar2(4000),
  spare7            raw(64),
  spare8            date,
  spare9            clob
)
/
create unique index i_xstream_parameters on
  xstream$_parameters(server_name, server_type, position)
/


Rem
Rem Sequence for conflict handler id
Rem
create sequence conflict_handler_id_seq$     /* conflict handler id sequence */
  start with 1
  increment by 1
  minvalue 1
  maxvalue 4294967295                           /* max portable value of UB4 */
  nocycle
  nocache
/

Rem
Rem Table for xstream dml_conflict_handler
Rem
create table xstream$_dml_conflict_handler
(
  object_name            varchar2(30),                        /* object name */
  schema_name            varchar2(30),                        /* schema name */
  apply_name             varchar2(30),                         /* apply name */
  conflict_type          number,                 /* conflict type definition */
                                                             /* 1 row exists */
                                                            /* 2 row missing */
  user_error             number,                                   /* unused */
  opnum                  number,             /* 1 insert, 2 update, 3 delete */
  method_txt             clob,                                     /* unused */
  method_name            varchar2(4000),                           /* unused */
  old_object             varchar2(30),               /* original object name */
  old_schema             varchar2(30),               /* original schema name */
  method_num             number,           /* resolution method
                                            * 1 RECORD, 2 IGNORE, 3 OVERWRITE,
                                            * 4 MAXIMUM, 5 MINIMUM, 6 DELTA  */
  conflict_handler_name  varchar2(30),       /* Name of the conflict handler */
  resolution_column      varchar2(30),                 /* column to evaluate */
  conflict_handler_id    number,               /* ID of the conflict handler */
  spare1                 number,  
  spare2                 number, 
  spare3                 number, 
  spare4                 timestamp,  
  spare5                 varchar2(4000),
  spare6                 varchar2(4000),
  spare7                 raw(64),
  spare8                 date,
  spare9                 clob
)
/
Rem add new columns for 11.2.0.3
alter table xstream$_dml_conflict_handler
  add (
    method_num             number,         /* resolution method
                                            * 1 RECORD, 2 IGNORE, 3 OVERWRITE,
                                            * 4 MAXIMUM, 5 MINIMUM, 6 DELTA  */
    conflict_handler_name  varchar2(30),     /* Name of the conflict handler */
    resolution_column      varchar2(30),               /* column to evaluate */
    conflict_handler_id    number              /* ID of the conflict handler */
  )
/

Rem this index may exist for an old version of this table
drop index i_xstream_dml_conflict_handler
/
create index i_xstream_dml_conf_handler1 on
  xstream$_dml_conflict_handler(apply_name, schema_name, object_name,
                                old_schema, old_object, opnum, conflict_type,
                                method_num)
/
create unique index i_xstream_dml_conf_handler2 on
  xstream$_dml_conflict_handler(apply_name, conflict_handler_name)
/

Rem
Rem Table to store the conflict resolution group for
Rem xstream$_dml_conflict_handler
Rem
create table xstream$_dml_conflict_columns
(
  conflict_handler_id       number not null,                   /* handler id */
  column_name               varchar2(30) not null,                 /* column */
  spare1                    number,  
  spare2                    number, 
  spare3                    number, 
  spare4                    timestamp,  
  spare5                    varchar2(4000),
  spare6                    varchar2(4000),
  spare7                    raw(64),
  spare8                    date,
  spare9                    clob
)
/
create index i_xstream_dml_conflict_cols1 on
  xstream$_dml_conflict_columns(conflict_handler_id)
/

Rem
Rem table for reperror handlers
Rem
create table xstream$_reperror_handler
(
  apply_name          varchar2(30) not null,                   /* Apply name */
  schema_name         varchar2(30) not null,                  /* dest schema */
  table_name          varchar2(30) not null,                   /* dest table */
  source_schema_name  varchar2(30) not null,                   /* src schema */
  source_table_name   varchar2(30) not null,                    /* src table */
  error_number        number not null,                       /* error number */
  method              number not null, /* 1 ABEND, 2 RECORD,
                                        * 3 RECORD_TRANSACTION, 4 IGNORE,
                                        * 5 RETRY, 6 RETRY_TRANSACTION */
  max_retries         number,                                 /* max retries */
  delay_msecs         number,                     /* retry delay miliseconds */
  spare1              number,  
  spare2              number, 
  spare3              number, 
  spare4              timestamp,  
  spare5              varchar2(4000),
  spare6              varchar2(4000),
  spare7              raw(64),
  spare8              date,
  spare9              clob
)
/
create unique index i_xstream_reperror_handler1 on
  xstream$_reperror_handler(apply_name, schema_name, table_name,
                           source_schema_name, source_table_name, error_number)
/

Rem
Rem table for collision handlers
Rem
create table xstream$_handle_collisions
(
  apply_name          varchar2(30) not null,                   /* apply name */
  schema_name         varchar2(30) not null,                  /* dest schema */
  table_name          varchar2(30) not null,                   /* dest table */
  source_schema_name  varchar2(30) not null,                   /* src schema */
  source_table_name   varchar2(30) not null,                    /* src table */
  handle_collisions   varchar2(1) not null,        /* Handle collisions? Y/N */
  spare1              number,  
  spare2              number, 
  spare3              number, 
  spare4              timestamp,  
  spare5              varchar2(4000),
  spare6              varchar2(4000),
  spare7              raw(64),
  spare8              date,
  spare9              clob
)
/
create unique index i_xstream_handle_collisions1 on
  xstream$_handle_collisions(apply_name, schema_name, table_name,
                             source_schema_name, source_table_name)
/


alter table streams$_apply_process add
( spare4                  number,
  spare5                  number,
  spare6                  varchar2(4000),
  spare7                  varchar2(4000),
  spare8                  date,
  spare9                  date
);

alter table streams$_privileged_user add
( flags number,
  spare1 number,
  spare2 number,
  spare3 varchar2(1000),
  spare4 varchar2(1000)
);

alter table xstream$_server add
( status_change_time date        /* the time that the status column changed */
);

alter table xstream$_server add
(
  connect_user varchar2(30)
);

create table xstream$_server_connection
(
 outbound_server               varchar2(30) not null,
 inbound_server                varchar2(30) not null,
 inbound_server_dblink         varchar2(128),
 outbound_queue_owner          varchar2(30),
 outbound_queue_name           varchar2(30),
 inbound_queue_owner           varchar2(30),
 inbound_queue_name            varchar2(30),
 rule_set_owner                varchar2(30),
 rule_set_name                 varchar2(30),
 negative_rule_set_owner       varchar2(30),
 negative_rule_set_name        varchar2(30),
 flags                         number,
 status                        number,
 create_date                   date,
 error_message                 varchar2(4000),
 error_date                    date,
 acked_scn                     number,
 auto_merge_threshold          number,
 spare1                        number,
 spare2                        number,
 spare3                        varchar2(4000),
 spare4                        varchar2(4000),
 spare5                        varchar2(4000),
 spare6                        varchar2(4000),
 spare7                        date,
 spare8                        date,
 spare9                        raw(2000),
 spare10                       raw(2000)
)
/
create index i_xstream_server_connection1 on xstream$_server_connection
    (outbound_server, inbound_server, inbound_server_dblink)
/

create table goldengate$_privileges
( username        varchar2(30) not null,
  privilege_type  number not null,              /* 1: capture; 2: apply; 3:* */
  privilege_level number not null,           /* 0: NONE; 1: select privilege */
  create_time     timestamp,
  spare1          number,
  spare2          number,
  spare3          timestamp,
  spare4          varchar2(4000),
  spare5          varchar2(4000))
/
create unique index goldengate$_privileges_i on 
  goldengate$_privileges(username, privilege_type, privilege_level)
/

create table xstream$_privileges
( username        varchar2(300) not null,
  privilege_type  number not null,              /* 1: capture; 2: apply; 3:* */
  privilege_level number not null,              /* 1: administrator; 2: user */
  create_time     timestamp,
  spare1          number,
  spare2          number,
  spare3          timestamp,
  spare4          varchar2(4000),
  spare5          varchar2(4000))
/
create unique index i_xstream_privileges on 
  xstream$_privileges(username, privilege_type, privilege_level)
/

drop public synonym all_streams_stmt_handlers;
drop view all_streams_stmt_handlers;

drop public synonym all_streams_stmts;
drop view all_streams_stmts;

Rem Modify Streams parameter names 
update sys.streams$_process_params 
  set name = 'COMPARE_KEY_ONLY', internal_flag=0
  where name = '_CMPKEY_ONLY';

update sys.streams$_process_params 
  set name = 'IGNORE_TRANSACTION', internal_flag=0
  where name = '_IGNORE_TRANSACTION';

update sys.streams$_process_params 
  set name = 'IGNORE_UNSUPPORTED_TABLE', internal_flag=0
  where name = '_IGNORE_UNSUPERR_TABLE';

update sys.streams$_process_params 
  set name = 'MAX_PARALLELISM', internal_flag=0 
  where name = '_MAX_PARALLELISM';

update sys.streams$_process_params 
  set name = 'EAGER_SIZE', internal_flag=0 where name = '_EAGER_SIZE';

update sys.streams$_process_params 
  set value = '9500' 
  where name = 'EAGER_SIZE' 
  and user_changed_flag=0
  and value = '1000';
commit;

Rem Grant SELECT ANY TRANSACTION to all Streams admin users
DECLARE
  user_names       dbms_sql.varchar2s;
  i                PLS_INTEGER;
BEGIN
  -- grant select any transaction to username from dba_streams_administrator. 
  SELECT u.name
  BULK COLLECT INTO user_names FROM user$ u, sys.streams$_privileged_user pu
  WHERE u.user# = pu.user# AND pu.privs != 0 and
       (pu.flags IS NULL or pu.flags = 0 or (bitand(pu.flags, 1) = 1));
  FOR i IN 1 .. user_names.count 
  LOOP
    -- Don't uppercase username during enquote_name
    IF (user_names(i) <> 'SYS' AND user_names(i) <> 'SYSTEM') THEN
      EXECUTE IMMEDIATE 'GRANT SELECT ANY TRANSACTION TO ' || 
               dbms_assert.enquote_name(user_names(i), FALSE);
    END IF;
  END LOOP;
END;
/

rem =======================================================================
Rem  12.1 Changes for XStream
Rem =======================================================================
alter table sys.apply$_error add
(
  error_pos      raw(64)                                   /* error position */
);

Rem add set_by columns to apply handlers
ALTER TABLE apply$_dest_obj_ops ADD (set_by number default NULL);
ALTER TABLE xstream$_dml_conflict_handler ADD (set_by number default NULL);
ALTER TABLE xstream$_reperror_handler ADD (set_by number default NULL);
ALTER TABLE xstream$_handle_collisions ADD (set_by number default NULL);

alter table sys.apply$_error add
(
  start_seq#            number,          /* start seq# of the replicat trail */
  end_seq#              number,            /* end seq# of the replicat trail */
  start_rba             number,           /* start rba of the replicat trail */
  end_rba               number,             /* end rba of the replicat trail */
  error_seq#            number,   /* seq# of replicat trail for error record */
  error_rba             number,    /* rba of replicat trail for error record */
  error_index#          number,   /* replicat mapping index for error record */
  spare6                number,
  spare7                number,
  spare8                varchar2(4000),
  spare9                varchar2(4000),
  spare10               raw(1000),
  spare11               raw(1000),
  spare12               timestamp
);

alter table sys.apply$_error_txn add
(
  seq#                  number,                /* seq# of the replicat trail */
  rba                   number,                 /* rba of the replicat trail */
  index#                number,            /* index # of the replicat record */
  spare7                number,
  spare8                number,
  spare9                varchar2(4000),
  spare10               varchar2(4000),
  spare11               raw(1000),
  spare12               raw(1000)
);
Rem add columns to streams$_prepare_ddl
ALTER TABLE streams$_prepare_ddl ADD (allpdbs number default 0);
ALTER TABLE streams$_prepare_ddl ADD (c_invoker varchar2(30));

Rem add columns to xstream$_privileges
ALTER TABLE xstream$_privileges ADD (optional_priv varchar2(4000));
ALTER TABLE xstream$_privileges ADD (allpdbs number default 0);
ALTER TABLE xstream$_privileges ADD (c_invoker varchar2(30));

Rem add columns to goldengate$_privileges
ALTER TABLE goldengate$_privileges ADD (optional_priv varchar2(4000));
ALTER TABLE goldengate$_privileges ADD (allpdbs number default 0);
ALTER TABLE goldengate$_privileges ADD (c_invoker varchar2(30));

alter table streams$_apply_milestone add ( flags number);

declare
 newflag number;
 CURSOR all_apply IS 
   select apply#, flags from sys.streams$_apply_process;
begin
 FOR app IN all_apply 
 LOOP
   newflag := 0;
   /* Pass on used flag KNAPROCFPTOUSED -> KNALA_PTO_USED*/
   IF (bitand(app.flags, 8192) = 8192) THEN
     newflag := 1;
     /* Pass on recovered flag KNAPROCFPTRDONE -> KNALA_PTO_RECOVERED */
     IF (bitand(app.flags, 2048) = 2048) THEN
       newflag := 3;
     END IF;
   END IF;
   update sys.streams$_apply_milestone set flags = newflag 
   where apply# = app.apply#;
   /* Not clearing the streams$_apply_process flags for debugging purpose */
 END LOOP; 
 COMMIT;
  
end;
/


rem =======================================================================
Rem  End Changes for XStream
Rem =======================================================================

Rem =========================================================================
Rem BEGIN Replication changes (Repcat, Streams, XStream, OGG) 
Rem =========================================================================

-- Bug 16047985: Revoke execute grant from public on these packages; 
-- ignore the following errors:
-- -04042: Procedure, function, package, or package body does not exist 
-- -01927: Cannot REVOKE privileges you did not grant

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON dbms_checksum FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON lcr$_parameter_list FROM PUBLIC';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem =========================================================================
Rem END Replication changes (Repcat, Streams, XStream, OGG)  
Rem =========================================================================

Rem =======================================================================
Rem  Begin Changes for LogMiner
Rem =======================================================================

Rem Set system.logmnr_session$.spare1 to zero
update system.logmnr_session$
 set spare1 = 0
 where spare1 is null;
commit;

Rem logminer needs a log group to track seq$ for GG Integrated Capture
declare
  cnt number;
begin
  select count(1) into cnt
    from con$ co, cdef$ cd, obj$ o, user$ u
    where o.name = 'SEQ$'
      and u.name = 'SYS'
      and co.name = 'SEQ$_LOG_GRP'
      and cd.obj# = o.obj#
      and cd.con# = co.con#
      and u.user# = o.owner#;
  if cnt = 0 then
    execute immediate 'alter table sys.seq$
                          add supplemental log group 
                          seq$_log_grp (obj#) always';
  end if;
end;
/

CREATE TABLE SYSTEM.logmnr_integrated_spill$ (
                session#  number,
                xidusn          number,
                xidslt    number,
                xidsqn    number,
                chunk     number,
                flag                    number,
                ctime                   date,
                mtime                   date,
                spill_data  blob,
                spare1    number,
                spare2    number,
                spare3                  number, 
                spare4                  date,
                spare5                  date,
        CONSTRAINT LOGMNR_INTEG_SPILL$_PK PRIMARY KEY 
            (session#, xidusn, xidslt, xidsqn, chunk, flag)
     USING INDEX TABLESPACE SYSAUX LOGGING)
        LOB (spill_data) STORE AS (TABLESPACE SYSAUX CACHE PCTVERSION 0
     CHUNK 32k STORAGE (INITIAL 4M NEXT 2M))
        TABLESPACE SYSAUX LOGGING
/
--
-- For Logminer support of GG mining across a redo gap.
-- The tables LOGMNRGGC_GTLO and LOGMNRGGC_GTCS are are
-- identical to their counterparts LOGMNRC_GTLOG and  LOGMNRC_GTCS.
-- Though it would have been simpler to use designated paritions
-- of the original tables, this could have led to unacceptable locking
-- issues when the DDL trigger that maintains these tables fires.
--
CREATE TABLE SYSTEM.LOGMNRGGC_GTLO( 
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
                                            /* SCN at which existence begins */
                  DROP_SCN         NUMBER,  /* SCN at which existence ends   */
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
                    CONSTRAINT LOGMNRGGC_GTLO_PK
                    PRIMARY KEY(LOGMNR_UID, KEYOBJ#, BASEOBJV#)
                  ) TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNRGGC_I2GTLO 
    ON SYSTEM.LOGMNRGGC_GTLO (logmnr_uid, baseobj#, baseobjv#) 
    TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNRGGC_I3GTLO 
    ON SYSTEM.LOGMNRGGC_GTLO (logmnr_uid, drop_scn) 
    TABLESPACE SYSTEM LOGGING
/

CREATE TABLE SYSTEM.LOGMNRGGC_GTCS(
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
                     constraint logmnrggc_gtcs_pk
                     primary key(logmnr_uid, obj#, objv#,intcol#)
                  )  TABLESPACE SYSTEM LOGGING
/
CREATE INDEX SYSTEM.LOGMNRGGC_I2GTCS
    ON SYSTEM.LOGMNRGGC_GTCS (logmnr_uid, obj#, objv#, segcol#, intcol#)
    TABLESPACE SYSTEM LOGGING
/
Rem =======================================================================
Rem  End Changes for LogMiner
Rem =======================================================================


Rem 
Rem Add edition column for Service
Rem 
alter table SERVICE$ add (edition varchar2(30));

Rem =================
Rem Begin AQ changes
Rem =================

ALTER TABLE sys.aq$_schedules ADD (destq NUMBER);

alter table sys.reg$ add (session_key VARCHAR2(1024));

alter sequence invalidation_reg_id$
  cache 300
/

Rem =================
Rem End AQ changes
Rem =================

REM create a table to store the sql errors that occur during parsing so that
REM the next time the same bad sql is issued we can look up from this table
REM and throw the same error instead of doing a hard parse
create table sqlerror$
(
  sqlhash   varchar(32)  not null,
  error#    number       not null,
  errpos#   number       not null,
  flags     number       not null);

Rem =======================================================================
Rem  Bug 12326358: add spare columns to sqlerror$
Rem =======================================================================
Rem
alter table sqlerror$ add
(
  spare1 number default 0 not null
);
alter table sqlerror$ add
(
  spare2 number default 0 not null
);
alter table sqlerror$ add
(
  spare3 number default 0 not null
);
Rem =======================================================================
Rem  End of changes for bug 12326358
Rem =======================================================================

Rem =======================================================================
Rem  Bug #5842629 : direct path load and direct path export
Rem =======================================================================
Rem
Rem Bug #11787333: delete records first if they already exist.
Rem 
delete from STMT_AUDIT_OPTION_MAP where option# = 330;
delete from STMT_AUDIT_OPTION_MAP where option# = 331;
insert into STMT_AUDIT_OPTION_MAP values (330, 'DIRECT_PATH LOAD', 0);
insert into STMT_AUDIT_OPTION_MAP values (331, 'DIRECT_PATH UNLOAD', 0);
Rem =======================================================================
Rem  End Changes for Bug #5842629
Rem =======================================================================  



Rem =======================================================================
Rem  Begin Changes for Database Replay 
Rem =======================================================================
Rem
Rem add columns to WRR$_CAPTURES and WRR$_REPLAYS
Rem
Rem wrr$_captures
alter table WRR$_CAPTURES add (sqlset_owner varchar2(30));
alter table WRR$_CAPTURES add (sqlset_name varchar2(30));
Rem wrr$_replays
alter table WRR$_REPLAYS add (sqlset_owner varchar2(128));
alter table WRR$_REPLAYS add (sqlset_name varchar2(128));
alter table WRR$_REPLAYS add (sqlset_cap_interval number);
alter table WRR$_REPLAYS add (filter_set_name varchar2(1000));
alter table WRR$_REPLAYS add (schedule_name varchar2(128));
alter table WRR$_REPLAYS add (num_admins number);
alter table WRR$_REPLAY_SEQ_DATA add (schedule_cap_id number);
alter table WRR$_CONNECTION_MAP add (schedule_cap_id number);
alter table WRR$_REPLAY_DATA add (schedule_cap_id number);
alter table WRR$_REPLAY_DEP_GRAPH add (schedule_cap_id number);
alter table WRR$_REPLAY_COMMITS add (schedule_cap_id number);
alter table WRR$_REPLAY_REFERENCES add (schedule_cap_id number);
alter table WRR$_REPLAY_FILTER_SET add (default_action varchar2(20));
alter table WRR$_REPLAY_DIVERGENCE add (cap_file_id number);
alter table WRR$_REPLAY_SQL_BINDS add (cap_file_id number);

Rem We have moved some UPDATE calls for  tables WRR$_REPLAY_DIVERGENCE and
Rem WRR$_REPLAY_SQL_BINDS to file a1102000.sql to fix lrg problem 5759823.

Rem =======================================================================
Rem  End Changes for Database Replay 
Rem =======================================================================

Rem ==========================
Rem Begin Bug #8862486 changes
Rem ==========================

Rem Directory EXECUTE auditing (action #135)
Rem Bug #11787333: delete record first if it already exists.
Rem 
delete from audit_actions where action = 135;
insert into audit_actions values (135, 'DIRECTORY EXECUTE');

Rem ========================
Rem End Bug #8862486 changes
Rem ========================

Rem ============================================
Rem Begin Bug-14220065 RFI backport of #12904308
Rem ============================================
Rem Audit CREATE/DROP DIRECTORY actions by default

AUDIT DIRECTORY BY ACCESS;

Rem =========================================
Rem End Bug-14220065 RFI backport of #12904308
Rem ==========================================

Rem ===========================================================================
Rem add new columns to WRH$_PERSISTENT_QUEUES and WRH$_PERSISTENT_SUBSCRIBERS
Rem ===========================================================================

alter table WRH$_PERSISTENT_QUEUES add (browsed_msgs          number);
alter table WRH$_PERSISTENT_QUEUES add (enqueue_cpu_time      number);
alter table WRH$_PERSISTENT_QUEUES add (dequeue_cpu_time      number);
alter table WRH$_PERSISTENT_QUEUES add (avg_msg_age           number);
alter table WRH$_PERSISTENT_QUEUES add (dequeued_msg_latency  number);
alter table WRH$_PERSISTENT_QUEUES add (enqueue_transactions  number);
alter table WRH$_PERSISTENT_QUEUES add (dequeue_transactions  number);
alter table WRH$_PERSISTENT_QUEUES add (execution_count       number);

alter table WRH$_PERSISTENT_SUBSCRIBERS add (avg_msg_age           number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (browsed_msgs          number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (elapsed_dequeue_time  number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (dequeue_cpu_time      number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (dequeue_transactions  number);
alter table WRH$_PERSISTENT_SUBSCRIBERS add (execution_count       number);

Rem ===========================================================================
Rem End changes to WRH$_PERSISTENT_QUEUES and WRH$_PERSISTENT_SUBSCRIBERS 
Rem ===========================================================================

Rem ===========================================================================
Rem add new columns to WRH$_BUFFERED_QUEUES and WRH$_BUFFERED_SUBSCRIBERS
Rem ===========================================================================
alter table WRH$_BUFFERED_QUEUES add (expired_msgs                    number);
alter table WRH$_BUFFERED_QUEUES add (oldest_msgid                   raw(16));
alter table WRH$_BUFFERED_QUEUES add (oldest_msg_enqtm          timestamp(3));
alter table WRH$_BUFFERED_QUEUES add (queue_state               varchar2(25));
alter table WRH$_BUFFERED_QUEUES add (elapsed_enqueue_time            number);
alter table WRH$_BUFFERED_QUEUES add (elapsed_dequeue_time            number);
alter table WRH$_BUFFERED_QUEUES add (elapsed_transformation_time     number);
alter table WRH$_BUFFERED_QUEUES add (elapsed_rule_evaluation_time    number);
alter table WRH$_BUFFERED_QUEUES add (enqueue_cpu_time                number);
alter table WRH$_BUFFERED_QUEUES add (dequeue_cpu_time                number);
alter table WRH$_BUFFERED_QUEUES add (last_enqueue_time         timestamp(3));
alter table WRH$_BUFFERED_QUEUES add (last_dequeue_time         timestamp(3));

alter table WRH$_BUFFERED_SUBSCRIBERS add (last_browsed_seq           number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (last_browsed_num           number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (last_dequeued_seq          number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (last_dequeued_num          number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (current_enq_seq            number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (total_dequeued_msg         number); 
alter table WRH$_BUFFERED_SUBSCRIBERS add (expired_msgs               number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (message_lag                number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (elapsed_dequeue_time       number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (dequeue_cpu_time           number);
alter table WRH$_BUFFERED_SUBSCRIBERS add (last_dequeue_time    timestamp(3));
alter table WRH$_BUFFERED_SUBSCRIBERS add (oldest_msgid              raw(16));
alter table WRH$_BUFFERED_SUBSCRIBERS add (oldest_msg_enqtm     timestamp(3));
Rem ===========================================================================
Rem End changes to WRH$_BUFFERED_QUEUES and WRH$_BUFFERED_SUBSCRIBERS 
Rem ===========================================================================

Rem ==========================================================================
Rem Begin advisor framework / SPA changes
Rem ==========================================================================
Rem in 11.2, we added a new parameter EXECUTE_COUNT to control the
Rem execution count in the sql analyze when doing SPA.

BEGIN
  -- add new parameters to existing tasks. Note that the definition 
  -- of these two parameters will be added later during upgrade 
  -- when dbms_advisor.setup_repository is called. 
  EXECUTE IMMEDIATE 
    q'#INSERT INTO wri$_adv_parameters (task_id, name, value, datatype, flags)
       (SELECT t.id, 'EXECUTE_COUNT', 'UNUSED', 1,  8 
        FROM wri$_adv_tasks t
        WHERE t.advisor_name = 'SQL Performance Analyzer' AND 
              NOT EXISTS (SELECT 0 
                          FROM wri$_adv_parameters p
                          WHERE p.task_id = t.id and 
                                p.name = 'EXECUTE_COUNT'))#';    

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

Rem ==========================================================================
Rem End advisor framework / SPA changes 
Rem ==========================================================================

Rem *************************************************************************
Rem Resource Manager related changes - BEGIN
Rem *************************************************************************

DECLARE
  stmt VARCHAR2(200);
BEGIN
  -- if this column already exists, then the following updates are unnecessary
  stmt := 'alter table resource_plan_directive$ ' || 
          'add (parallel_queue_timeout number)';

  execute immediate stmt;

  update resource_plan_directive$ set
    max_active_sess_target_p1 = 4294967295;

  -- This part of the procedure relies on the success of the alter
  -- table above. Unless this is done as an execute immediate,
  -- the PL/SQL will not compile, as parallel_queue_timeout does
  -- not exist.
  stmt := 'update resource_plan_directive$ set ' ||
            'parallel_queue_timeout = 4294967295';

  execute immediate stmt;

  commit;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 
      THEN RETURN;
    ELSE
      RAISE;
    END IF;
END;
/

Rem Update WRH$_RSRC_CONSUMER_GROUP (basis for dba_hist_rsrc_consumer_group)
alter table WRH$_RSRC_CONSUMER_GROUP add (pqs_queued                number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pq_queued_time            number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pq_queue_time_outs        number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pqs_completed             number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pq_servers_used           number);
alter table WRH$_RSRC_CONSUMER_GROUP add (pq_active_time            number);

Rem Update WRH$_RSRC_PLAN (basis for dba_hist_rsrc_plan)
alter table WRH$_RSRC_PLAN add (parallel_execution_managed    varchar2(4));

Rem This is needed for bug #9207475 to allow AWR snapshots to include
Rem the currently active plan
alter table WRH$_RSRC_PLAN modify (end_time date null);

Rem *************************************************************************
Rem Resource Manager related changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Change the lengths of module and action
Rem *************************************************************************

alter table SQLOBJ$AUXDATA modify (module varchar2(64));
alter table SQLOBJ$AUXDATA modify (action varchar2(64));

alter table WRH$_ACTIVE_SESSION_HISTORY_BL modify (module varchar2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY_BL modify (action varchar2(64));

alter table WRH$_ACTIVE_SESSION_HISTORY modify (module varchar2(64));
alter table WRH$_ACTIVE_SESSION_HISTORY modify (action varchar2(64));

alter table WRI$_ADV_SQLT_STATISTICS modify (module varchar2(64));
alter table WRI$_ADV_SQLT_STATISTICS modify (action varchar2(64));

alter table WRI$_SQLSET_STATEMENTS modify (module varchar2(64));
alter table WRI$_SQLSET_STATEMENTS modify (action varchar2(64));

alter table WRR$_REPLAY_DIVERGENCE modify (module varchar2(64));
alter table WRR$_REPLAY_DIVERGENCE modify (action varchar2(64));

alter table WRH$_SQLSTAT modify (module varchar2(64));
alter table WRH$_SQLSTAT modify (action varchar2(64));

alter table WRH$_SQLSTAT_BL modify (module varchar2(64));
alter table WRH$_SQLSTAT_BL modify (action varchar2(64));

alter table STREAMS$_COMPONENT_EVENT_IN modify (module_name varchar2(64));
alter table STREAMS$_COMPONENT_EVENT_IN modify (action_name varchar2(64));

alter table STREAMS$_PATH_BOTTLENECK_OUT modify (module_name varchar2(64));
alter table STREAMS$_PATH_BOTTLENECK_OUT modify (action_name varchar2(64));

alter type SQLSET_ROW modify attribute module varchar2(64) cascade;
alter type SQLSET_ROW modify attribute action varchar2(64) cascade;
-- type alert_type is used for AQ messages
-- Turn ON the event to enable DDL on AQ tables
alter session set events '10851 trace name context forever, level 1';
alter type sys.alert_type
      modify attribute module_id varchar2(64) cascade;

-- Turn OFF the event to disable DDL on AQ tables
alter session set events '10851 trace name context off';

Rem *************************************************************************
Rem END Change the lengths of module and action
Rem *************************************************************************


Rem *************************************************************************
Rem WRH$_ACTIVE_SESSION_HISTORY changes
Rem   - Add columns to ASH
Rem *************************************************************************
alter table WRH$_ACTIVE_SESSION_HISTORY add (dbreplay_file_id NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (dbreplay_call_counter NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY add (px_flags NUMBER);

alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (dbreplay_file_id NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (dbreplay_call_counter NUMBER);
alter table WRH$_ACTIVE_SESSION_HISTORY_BL add (px_flags NUMBER);

Rem *************************************************************************
Rem END WRH$_ACTIVE_SESSION_HISTORY
Rem *************************************************************************

Rem *************************************************************************
Rem Bug 9766219 - BEGIN
Rem *************************************************************************

BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON SYS.URIFACTORY FROM PUBLIC';
  EXECUTE IMMEDIATE 'GRANT EXECUTE ON SYS.URIFACTORY TO PUBLIC';
EXCEPTION 
  WHEN OTHERS THEN
    IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
    ELSE RAISE;
    END IF;
END;
/

Rem *************************************************************************
Rem Bug 9766219 - END
Rem *************************************************************************


Rem *************************************************************************
Rem OLAP changes - BEGIN
Rem *************************************************************************

-- More limited grants will occur in olaptf.sql
BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_TABLE FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON CUBE_TABLE FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAPRC_TABLE FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_SRF_T FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_NUMBER_SRF FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_EXPRESSION FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_TEXT_SRF FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_EXPRESSION_TEXT FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_DATE_SRF FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_EXPRESSION_DATE FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_BOOL_SRF FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/

BEGIN
 EXECUTE IMMEDIATE 'REVOKE ALL ON OLAP_EXPRESSION_BOOL FROM PUBLIC';
EXCEPTION
 WHEN OTHERS THEN
   IF SQLCODE IN ( -04042, -1927, -942, -4045 ) THEN NULL;
   ELSE RAISE;
   END IF;
END;
/ 

Rem *************************************************************************
Rem Bug  12957533 - BEGIN
Rem *************************************************************************

-- Missing from 11.2 upgrade
create sequence awlogseq$ /* sequence for log id numbers */
  start with 1
  increment by 1
  cache 10
  maxvalue 18446744073709551615
/

Rem *************************************************************************
Rem Bug  12957533 - END
Rem *************************************************************************

-- In 12.1+, only system AWs remain in noexp$, user AWs are not
DELETE FROM sys.noexp$ WHERE (owner, name, obj_type) IN
  (SELECT u.name, 'AW$'||a.awname, 2
     FROM sys.aw$ a, sys.user$ u
    WHERE awseq# >= 1000 AND u.user#=a.owner#)
/

Rem *************************************************************************
Rem OLAP changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem WRM$_SNAPSHOT changes - BEGIN
Rem *************************************************************************

Rem add snap_timezone column to wrm$_snapshot
alter table WRM$_SNAPSHOT add (snap_timezone interval day(0) to second(0));

Rem *************************************************************************
Rem WRM$_SNAPSHOT changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Remove password from Remote Scheduler User - BEGIN
Rem *************************************************************************

UPDATE user$ set password=null,spare4=null where name='REMOTE_SCHEDULER_AGENT';

commit;

Rem *************************************************************************
Rem Remove password from Remote Scheduler User - END
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN: Insert users in default_pwd$
Rem *************************************************************************

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

exec insert_into_defpwd('ADLDEMO',  '147215F51929A6E8');
exec insert_into_defpwd('APR_USER',  '0E0840494721500A');
exec insert_into_defpwd('ARGUSUSER',  'AB1079A1727006AD');
exec insert_into_defpwd('AUDIOUSER',  'CB4F2CEC5A352488');
exec insert_into_defpwd('CATALOG',  '397129246919E8DA');
exec insert_into_defpwd('CDEMO82',  '7299A5E2A5A05820');
exec insert_into_defpwd('CDEMOCOR',  '3A34F0B26B951F3F');
exec insert_into_defpwd('CDEMORID',  'E39CEFE64B73B308');
exec insert_into_defpwd('CDEMOUCB',  'CEAE780F25D556F8');
exec insert_into_defpwd('CFLUENTDEV',  'D930962979E34C47');
exec insert_into_defpwd('COMPANY',  '402B659C15EAF6CB');
exec insert_into_defpwd('DEMO',  '4646116A123897CF');
exec insert_into_defpwd('EMP',  'B40C23C6E2B4EA3D');
exec insert_into_defpwd('EVENT',  '7CA0A42DA768F96D');
exec insert_into_defpwd('FINANCE',  '6CBBF17292A1B9AA');
exec insert_into_defpwd('FND',  '0C0832F8B6897321');
exec insert_into_defpwd('GPFD',  'BA787E988F8BC424');
exec insert_into_defpwd('GPLD',  '9D561E4D6585824B');
exec insert_into_defpwd('HLW',  '855296220C095810');
exec insert_into_defpwd('IMAGEUSER',  'E079BF5E433F0B89');
exec insert_into_defpwd('IMEDIA',  '8FB1DC9A6F8CE827');
exec insert_into_defpwd('JMUSER',  '063BA85BF749DF8E');
exec insert_into_defpwd('MGMT_VIEW',  '919E8A172B2AAB87');
exec insert_into_defpwd('MIGRATE',  '5A88CE52084E9700');
exec insert_into_defpwd('MILLER',  'D0EFCD03C95DF106');
exec insert_into_defpwd('MMO2',  'AE128772645F6709');
exec insert_into_defpwd('MODTEST',  'BBFF58334CDEF86D');
exec insert_into_defpwd('MOREAU',  'CF5A081E7585936B');
exec insert_into_defpwd('MTSSYS',  '6465913FF5FF1831');
exec insert_into_defpwd('MXAGENT',  'C5F0512A64EB0E7F');
exec insert_into_defpwd('NAMES',  '9B95D28A979CC5C4');
exec insert_into_defpwd('OCITEST',  'C09011CB0205B347');
exec insert_into_defpwd('OEMADM',  '9DCE98CCF541AAE6');
exec insert_into_defpwd('OLAPDBA',  '1AF71599EDACFB00');
exec insert_into_defpwd('OLAPSVR',  'AF52CFD036E8F425');
exec insert_into_defpwd('OWBSYS_AUDIT', 'FD8C3D14F6B60015');
exec insert_into_defpwd('PAS', 'D9F82FCE636766EA'); 
exec insert_into_defpwd('PASJMS', '20634D3199F83899');
exec insert_into_defpwd('PERFSTAT',  'AC98877DE1297365');
exec insert_into_defpwd('PO8',  '7E15FBACA7CDEBEC');
exec insert_into_defpwd('PORTAL30_ADMIN',  '7AF870D89CABF1C7');
exec insert_into_defpwd('PORTAL30_PS',  '333B8121593F96FB');
exec insert_into_defpwd('PORTAL30_SSO_ADMIN',  'BDE248D4CCCD015D');
exec insert_into_defpwd('POWERCARTUSER',  '2C5ECE3BEC35CE69');
exec insert_into_defpwd('PRIMARY',  '70C3248DFFB90152');
exec insert_into_defpwd('PUBSUB',  '80294AE45A46E77B');
exec insert_into_defpwd('RE',  '933B9A9475E882A6');
exec insert_into_defpwd('RMAIL',  'DA4435BBF8CAE54C');
exec insert_into_defpwd('SAMPLE',  'E74B15A3F7A19CA8');
exec insert_into_defpwd('SDOS_ICSAP',  'C789210ACC24DA16');
exec insert_into_defpwd('TAHITI',  'F339612C73D27861');
exec insert_into_defpwd('TSDEV',  '29268859446F5A8C');
exec insert_into_defpwd('TSUSER',  '90C4F894E2972F08');
exec insert_into_defpwd('USER0',  '8A0760E2710AB0B4');
exec insert_into_defpwd('USER1',  'BBE7786A584F9103');
exec insert_into_defpwd('USER2',  '1718E5DBB8F89784');
exec insert_into_defpwd('USER3',  '94152F9F5B35B103');
exec insert_into_defpwd('USER4',  '2907B1BFA9DA5091');
exec insert_into_defpwd('USER5',  '6E97FCEA92BAA4CB');
exec insert_into_defpwd('USER6',  'F73E1A76B1E57F3D');
exec insert_into_defpwd('USER7',  '3E9C94488C1A3908');
exec insert_into_defpwd('USER8',  'D148049C2780B869');
exec insert_into_defpwd('USER9',  '0487AFEE55ECEE66');
exec insert_into_defpwd('UTLBSTATU',  'C42D1FA3231AB025');
exec insert_into_defpwd('VIDEOUSER',  '29ECA1F239B0F7DF');
exec insert_into_defpwd('VIF_DEVELOPER',  '9A7DCB0C1D84C488');
exec insert_into_defpwd('VIRUSER',  '404B03707BF5CEA3');
exec insert_into_defpwd('VRR1',  '811C49394C921D66');
exec insert_into_defpwd('WKPROXY',  'B97545C4DD2ABE54');

commit;

drop procedure insert_into_defpwd;

Rem *************************************************************************
Rem END: Insert users in default_pwd$
Rem *************************************************************************
Rem *************************************************************************
Rem Optimizer changes - BEGIN
Rem *************************************************************************
-- lrg 4545922: Turn ON the event to disable the partition check
alter session set events  '14524 trace name context forever, level 1';

declare
  type numtab is table of number;
  tobjns numtab;
  tobjn  number;
  property number := 0;
  sqltxt varchar2(32767);
  tmp_created boolean := FALSE;
begin

-- check whether we are already in new schema
-- if we have upgraded it, this will throw 904 error that will be caught
  begin
    execute immediate 
    q'#select synopsis# 
      from wri$_optstat_synopsis$
      where rownum < 2 #';
  exception
    when others then
      if (sqlcode = -904) then 
        -- ORA-904 during reupgrde: "S"."SYNOPSIS#": invalid identifier 
        -- has been upgraded successfully before, do nothing
        return;
      elsif (sqlcode = -942) then
        -- ORA-00942: table or view does not exist
        -- wri$_optstat_synopsis$ does not exist. this may be caused by
        -- errors in last upgrade: wri$_optstat_synopsis$ is dropped but
        -- tmp_wri$_optstat_synopsis$ is failed to replace it.
        -- recreate wri$_optstat_synopsis$ (we might lose old data)
        execute immediate
        q'#create table wri$_optstat_synopsis$
          ( bo#           number not null,
            group#        number not null,
            intcol#       number not null,           
            hashvalue     number not null 
          ) partition by range(bo#) 
          subpartition by hash(group#) 
          subpartitions 32
          (
            partition p0 values less than (0)
          ) 
          tablespace sysaux
          pctfree 1
          enable row movement #';
        return;
      else
        raise;
      end if;
  end;

  -- there exists synopsis table in old schema
  execute immediate 
  q'#create table tmp_wri$_optstat_synopsis$
    ( bo#           number not null,
      group#        number not null,
      intcol#       number not null,           
      hashvalue     number not null 
    ) 
    partition by range(bo#) 
      subpartition by hash(group#) 
      subpartitions 32
    (
      partition p0 values less than (0)
    ) 
    tablespace sysaux
    pctfree 1
    enable row movement #';

  tmp_created := TRUE;

  -- get all the partitioned tables that have synopses
  -- must order by bo# because we are going to create partitions
  -- using "add partition" statement
  select distinct bo# bulk collect into tobjns
  from sys.wri$_optstat_synopsis_head$
  order by bo#;

  -- create range partition for each partitioned table
  for i in 1..tobjns.count loop
    tobjn := tobjns(i);

    -- check whethre low boundary has been created
    if (i = 1 or tobjns(i-1) <> tobjn - 1) then
      -- we haven't created a partition with highvalue tobjn yet

      -- check whether objn-1 is a partitioned table
      begin
        select bitand(t.property, 32) into property
        from sys.obj$ o,
             sys.tab$ t
        where o.obj# = tobjn-1 and
              o.type# = 2 and
              o.obj# = t.obj#; 
      exception
        when no_data_found then
          property := 0;
      end;

      if (property = 32) then
        -- tobjn-1 is a partitioned table
        sqltxt := 'alter table tmp_wri$_optstat_synopsis$' ||
                  ' add partition p_' || to_char(tobjn - 1) ||
                  ' values less than (' || to_char(tobjn) || ')';
      else
        sqltxt := 'alter table tmp_wri$_optstat_synopsis$' ||
                  ' add partition p_' || to_char(tobjn - 1) || 
                  ' values less than (' || to_char(tobjn) || ')' ||
                  ' subpartitions 1';
      end if;
      execute immediate sqltxt; 
    end if;
  
    -- high boundary
    sqltxt := 'alter table tmp_wri$_optstat_synopsis$' ||
              ' add partition p_' || tobjn || 
              ' values less than (' || to_char(tobjn + 1) || ')';
    execute immediate sqltxt; 
  end loop;

  execute immediate 
  q'#insert /*+ append */ 
     into tmp_wri$_optstat_synopsis$
     select /*+ full(h) full(s) leading(h s) use_hash(h s) */
       h.bo#,
       h.group#,
       h.intcol#,
       s.hashvalue
     from wri$_optstat_synopsis_head$ h,
          wri$_optstat_synopsis$ s
     where h.synopsis# = s.synopsis# #';

  execute immediate 
  q'# drop table wri$_optstat_synopsis$ #';

  execute immediate 
  q'# rename tmp_wri$_optstat_synopsis$ to wri$_optstat_synopsis$ #';

exception
  when others then
    if (tmp_created) then
      execute immediate 'drop table tmp_wri$_optstat_synopsis$';
    end if;
    raise;
end;
/
 
-- Turn OFF the event to disable the partition check 
alter session set events  '14524 trace name context off';

-- #(9577300) Column group usage
Rem #(10410249) create col_group_usage$ as a non iot table

variable found_iot number;

-- Check if col_group_usage$ is an iot
begin
  select count(*) into :found_iot
  from  user_tables 
  where table_name ='COL_GROUP_USAGE$' and iot_type = 'IOT';
end;
/

-- Save the contents if it is an iot
begin
  if (:found_iot != 0) then
    execute immediate
    q'# create table col_group_usage$_sav as select * from col_group_usage$ #';
  end if;
end;
/

-- Drop the iot
begin
  if (:found_iot != 0) then
    execute immediate
    q'# drop table col_group_usage$ purge #';
  end if;
end;
/

-- Create it as non iot. It may fail if it already exists and if it not an iot.
-- Upgrade ignores the error
create table col_group_usage$
(
  obj#              number,                                 /* object number */
  /*
   * We store intcol# separated by comma in the following column.
   * We allow upto 32 (CKYMAX) columns in the group. intcol# can be 
   * upto 1000 (or can be 64K in future or with some xml virtual columns?). 
   * Assume 5 digits for intcol# and one byte for comma. 
   * So max length would be 32 * (5+1) = 192
   */
  cols              varchar2(192 char),              /* columns in the group */
  timestamp         date,     /* timestamp of last time this row was changed */
  flags             number,                                 /* various flags */
  constraint        pk_col_group_usage$
  primary key       (obj#, cols))
  storage (initial 200K next 100k maxextents unlimited pctincrease 0)
/

-- Restore the contents. Fails if col_group_usage$ was not an iot
-- (col_group_usage$_sav will not be created in this case)
-- upgrade does not ignore 942 errors during insert and hence explicitly 
-- ignore it.
begin

  execute immediate
  q'# insert into col_group_usage$ select * from col_group_usage$_sav #';

exception
  when others then
    if (sqlcode = -942) then
      null;
    else
      raise;
    end if;
end;
/

-- Drop the staging table. Fails if col_group_usage$ was not an iot
drop table col_group_usage$_sav;

Rem *************************************************************************
Rem Optimizer changes - END
Rem *************************************************************************


Rem ===========================
Rem Begin Bug #11720698 changes
Rem ===========================

Rem Bug #11720698: delete old entries in warning_settings$ that correspond to
Rem dropped objects.  Break the delete into chunks of 100000 rows to avoid
Rem stressing undo.
Rem 

BEGIN
  LOOP
    DELETE FROM warning_settings$ WHERE rowid IN 
        (select rowid from warning_settings$ where obj# not in
            (select obj# from obj$) and rownum <= 100000);
    EXIT WHEN sql%ROWCOUNT = 0;
    COMMIT;
  END LOOP;
  COMMIT;
END;
/

Rem =========================
Rem End Bug #11720698 changes
Rem =========================


Rem
Rem Register import callouts for metadata tables and views
Rem
create table impcalloutreg$                      /* register import callouts */
( package      varchar2(30) not null,           /* pkg implementing callouts */
  schema       varchar2(30) not null,                 /* pkg's owning schema */
  tag          varchar2(30) not null,      /* mandatory component identifier */
  class        number not null,     /* 1=system,           3=object instance */
                                    /* (2=schema support deferred)           */
  level#       number default 1000 not null, /* determines calling order for */
                 /* multiple pkgs registered at same callout pt: lower first */
  flags        number not null,                    /* Only used when class=3 */
  /* See dbmsdp.sql for flags definitions                                    */
  /* 0x01: KU$_ICRFLAGS_IS_EXPR: tgt_object is an expression to be evaluated */
  /*       with LIKE operator. Only valid for tables (not views)             */
  /* 0x02: KU$_ICRFLAGS_EARLY_IMPORT: tgt_object will be imported and its    */
  /*       post-instance callout executed before import of user tables       */
  /* 0x04: KU$_ICRFLAGS_GET_DEPENDENTS: child dependents of tgt_object (eg,  */
  /*       indexes, grants, constraints, etc) will be fetched at export time */
  /*       Only valid for tables (not views)                                 */
  /* 0x08: KU$_ICRFLAGS_EXCLUDE: tgt_object should not be exported when it   */
  /*       matches a wildcard registration via flag KU$_ICRFLAGS_IS_EXPR     */
  /* 0x10: KU$_ICRFLAGS_XDB_NO_TTS: tgt_object is exported only if the XDB   */
  /*       tablespace is not transportable (xdb use only)                    */
  tgt_schema   varchar2(30),       /* for class 2/3, the target schema or    */
                                 /* schema of the target object respectively */
  tgt_object   varchar2(30),       /* for class 3, the name of the tgt obj.  */
  tgt_type     number,          /* type of obj as defined in KQD.H. Must be  */
                                /* table, view, type, pkg or proc            */
  cmnt         varchar2(2000) not null    /* mandatory component description */
)
/

Rem
Rem Metadata API changes
Rem
alter table metascript$   add (
  r1seq#        number,                 /* sequence number prerequisite step */
  r2seq#        number                  /* sequence number prerequisite step */
)
/

alter table WRI$_TRACING_ENABLED modify (qualifier_id1 VARCHAR2(64));
alter table WRI$_TRACING_ENABLED modify (qualifier_id2 VARCHAR2(64));

Rem *************************************************************************
Rem Increment  AWR version for 11.2.0.2
Rem *************************************************************************
Rem =======================================================
Rem ==  Update the SWRF_VERSION to the current version.  ==
Rem ==          (11gR202 = SWRF Version 5)               ==
Rem ==  This step must be the last step for the AWR      ==
Rem ==  upgrade changes.  Place all other AWR upgrade    ==
Rem ==  changes above this.                              ==
Rem =======================================================

BEGIN
  EXECUTE IMMEDIATE 'UPDATE wrm$_wr_control SET swrf_version = 5';
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
Rem End Increment AWR version
Rem *************************************************************************

Rem *************************************************************************
Rem BEGIN Changes to catsqlt for RAT Masking
Rem *************************************************************************

Rem Add new columns to the STS plans table
alter table wri$_sqlset_plans add (flags number, masked_binds_flag raw(1000));


Rem *************************************************************************
Rem END Changes to catsqlt for RAT Masking
Rem *************************************************************************

Rem *************************************************************************
Rem AWR report accessibility changes - BEGIN
Rem *************************************************************************

alter type AWRRPT_HTML_TYPE modify attribute output varchar2(8000 CHAR)
        cascade;

Rem *************************************************************************
Rem AWR report accessibility changes - END
Rem *************************************************************************


Rem *************************************************************************
Rem Removing SCHEDULER_UTIL - BEGIN 
Rem *************************************************************************

DROP PACKAGE SCHEDULER_UTIL;

Rem *************************************************************************
Rem Removing SCHEDULER_UTIL - BEGIN 
Rem *************************************************************************

Rem *************************************************************************
Rem RADM (Real-time Application-controlled Data Masking) changes - BEGIN
Rem Project 32006 - Data Redaction.
Rem These changes are for upgrade to 11.2.0.4.
Rem List of changes is as follows:
Rem
Rem  - Create the RADM dictionary tables radm$ and radm_fptm$.
Rem  - Insert the new EXEMPT REDACTION POLICY system privilege.
Rem
Rem Note: creation of the radm_mc$ table has been moved to i1102000.sql.
Rem *************************************************************************

create table radm$ /* Real-time Application-controlled Data Masking policies */
(
  obj#        NUMBER NOT NULL,                        /* table object number */
  pname       VARCHAR2(30) NOT NULL,                     /* RADM policy name */
  pexpr       VARCHAR2(4000) NOT NULL,             /* RADM Policy Expression */
  enable_flag NUMBER NOT NULL     /* Policy State: 0 = disabled, 1 = enabled */
)
/
create index i_radm1 on radm$(obj#)
/
create index i_radm2 on radm$(obj#, pname)
/

create table radm_fptm$ /* RADM Fixed PoinT Masking values */
(
  numbercol    NUMBER NOT NULL,
  binfloatcol  BINARY_FLOAT NOT NULL,
  bindoublecol BINARY_DOUBLE NOT NULL,
  charcol      CHAR(1),
  varcharcol   VARCHAR2(1),
  ncharcol     NCHAR(1),
  nvarcharcol  NVARCHAR2(1),
  datecol      DATE NOT NULL,
  ts_col       TIMESTAMP NOT NULL,
  tswtz_col    TIMESTAMP WITH TIME ZONE NOT NULL,
  fpver        NUMBER NOT NULL
)
/
create unique index i_radm_fptm on radm_fptm$(fpver)
/

BEGIN
  insert into radm_fptm$ values
  (
    0,
    0,
    0,
    ' ',
    ' ',
    N' ',
    N' ',
    TO_DATE('01-JAN-01','DD-MON-YY','NLS_DATE_LANGUAGE = AMERICAN'),
    TO_TIMESTAMP('01-JAN-2001 01.00.00.000000AM','DD-MON-YYYY HH.MI.SS.FF6AM','NLS_DATE_LANGUAGE = AMERICAN'),
    TO_TIMESTAMP_TZ('01-JAN-2001 01.00.00.000000AM +00:00','DD-MON-YYYY HH.MI.SS.FF6AM TZH:TZM','NLS_DATE_LANGUAGE = AMERICAN'),
    1
  );
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

create table radm_fptm_lob$ /* RADM Fixed PoinT Masking values for LOBs*/
(
  blobcol      BLOB,
  clobcol      CLOB,
  nclobcol     NCLOB,
  fpver        NUMBER NOT NULL
)
tablespace SYSAUX
/

create unique index i_radm_fptm_lob on radm_fptm_lob$(fpver)
tablespace SYSAUX
/

BEGIN
  insert into radm_fptm_lob$ values
  (
    NULL,
    NULL,
    NULL,
    0
  );
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

create table radm_td$
(
  obj#        NUMBER NOT NULL,             /* object number of table or view */
  pname       VARCHAR2(30) NOT NULL,                     /* RADM policy name */
  pdesc       VARCHAR2(4000)                      /* RADM policy description */
)
/
create index i_radm_td1 on radm_td$(obj#)
/
create index i_radm_td2 on radm_td$(obj#, pname)
/
create table radm_cd$
(
  obj#        NUMBER NOT NULL,             /* object number of table or view */
  intcol#     NUMBER NOT NULL,                              /* column number */
  pname       VARCHAR2(30) NOT NULL,                     /* RADM policy name */
  cdesc       VARCHAR2(4000)         /* column level RADM policy description */
)
/
create index i_radm_cd1 on radm_cd$(obj#)
/
create index i_radm_cd2 on radm_cd$(obj#, intcol#)
/
create index i_radm_cd3 on radm_cd$(obj#, intcol#, pname)
/

BEGIN
  insert into SYSTEM_PRIVILEGE_MAP values (-351, 'EXEMPT REDACTION POLICY', 0);  
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

BEGIN
  insert into STMT_AUDIT_OPTION_MAP values (351, 'EXEMPT REDACTION POLICY', 0);
EXCEPTION
  WHEN OTHERS THEN IF SQLCODE = -00001 THEN NULL; ELSE RAISE; END IF;
END;
/

Rem *************************************************************************
Rem RADM (Real-time Application-controlled Data Masking) changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem Oracle Data Mining changes - BEGIN
Rem *************************************************************************

delete from STMT_AUDIT_OPTION_MAP where NAME = 'SELECT MINING MODEL';
insert into STMT_AUDIT_OPTION_MAP values (299, 'SELECT MINING MODEL', 0);
commit;

Rem *************************************************************************
Rem Oracle Data Mining changes - END
Rem *************************************************************************

Rem ********************************************************
Rem BEGIN SYS.DBMS_PARALLEL_EXECUTE changes - bug 14296972
Rem ********************************************************

begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_TASK$ modify EDITION VARCHAR2(32)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/
begin
  execute immediate 'alter table DBMS_PARALLEL_EXECUTE_TASK$ modify APPLY_CROSSEDITION_TRIGGER VARCHAR2(32)';
exception when others then
  if sqlcode in (-904, -942) then null;
  else raise;
  end if;
end;
/

Rem ********************************************************
Rem End SYS.DBMS_PARALLEL_EXECUTE changes - bug 14296972
Rem ********************************************************

Rem *************************************************************************
Rem Stats history purging changes - BEGIN
Rem *************************************************************************

alter session set events  '14524 trace name context forever, level 1';

declare
  cnt        number := 0;  
  spare1_id  number := 0; 
  colname_id number := 0;
  compatible_val number := 0;
begin
  -- U1. Check if the upgrade has already taken place.
  select count(*) into cnt
    from all_part_tables
   where owner = 'SYS' and
         table_name = 'WRI$_OPTSTAT_HISTHEAD_HISTORY';

  if (cnt = 1) then
    -- upgrade has already taken place, do nothing.
    return;
  end if;

  -- make sure that compatibility is set to 11 or higher
  SELECT to_number(REGEXP_REPLACE(value || '.0.0.0', 
                        '^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9\.]*)', 
                        '\1\2\3\4')) into compatible_val
  FROM v$parameter 
  WHERE UPPER(name) = 'COMPATIBLE';

  if (compatible_val < 11000) then
    -- partitioning is not supported if compatible is less than 11.0.0.0
    return;
  end if;

  -- see if we are upgrading from 11g or 10g (column orders are different)  
  -- In 10g table definition, spare1 comes before colname.
  select column_id into spare1_id
    from dba_tab_columns
   where table_name = 'WRI$_OPTSTAT_HISTHEAD_HISTORY'
     and column_name = 'SPARE1';

  select column_id into colname_id
    from dba_tab_columns
   where table_name = 'WRI$_OPTSTAT_HISTHEAD_HISTORY'
     and column_name = 'COLNAME';

  -- U2. Add virtual column savtime_date into wri$_optstat_histhead_history
  execute immediate
   q'#alter table wri$_optstat_histhead_history 
      add savtime_date as (trunc(savtime)) #';
  
  execute immediate
    q'#drop index i_wri$_optstat_hh_obj_icol_st #';

  execute immediate
    q'#create unique index i_wri$_optstat_hh_obj_icol_st on
       wri$_optstat_histhead_history (obj#, intcol#, savtime, colname)
       tablespace sysaux #';

  -- U3. Create a new partitioned table wri$_optstat_histhead_history2 which
  -- has the same schema as wri$_optstat_histhead_history, and is interval 
  -- partitioned based on savtime_date column with two default partitions, 
  -- p_old and p_permanent, with boundary values (current timestamp) and 
  -- (current timestamp + 1 sec) respectively, where p_old is a place holder 
  -- to plugin the existing statistics history, while p_permanent will be 
  -- permanently  kept, as interval partitioning does not allow dropping the 
  -- newest range partition.

  -- Adapt schema accordingly depending on whether we are upgrading from
  -- 10g or 11g.
  if (spare1_id < colname_id) then -- upgrading from 10g  
   execute immediate
   q'#create table wri$_optstat_histhead_history2
      (obj#            number not null,
       intcol#         number not null,
       savtime         timestamp with time zone,
       flags           number, 
       null_cnt        number,
       minimum         number,
       maximum         number,
       distcnt         number,
       density         number,
       lowval          raw(32),
       hival           raw(32),
       avgcln          number,
       sample_distcnt  number,
       sample_size     number,
       timestamp#      date,         
       spare1          number,           
       spare2          number,
       spare3          number,            
       spare4          varchar2(1000),                        
       spare5          varchar2(1000),
       spare6          timestamp with time zone,
       expression      clob,  
       colname         varchar2(30),
       savtime_date as (trunc(savtime))
     ) 
     partition by range (savtime_date)
     interval (numtodsinterval(1,'day'))
     (partition p_old values less than (to_date('#' || 
        to_char(sysdate, 'dd-mm-yyyy hh:mi:ss') || q'#', 
                         'dd-mm-yyyy hh:mi:ss')),
      partition p_permanent values less than (to_date('#' || 
        to_char(sysdate+0.000012, 'dd-mm-yyyy hh:mi:ss') || q'#', 
                                  'dd-mm-yyyy hh:mi:ss')))
     tablespace sysaux
     pctfree 1
     enable row movement #';
  else -- upgrading from 11g
   execute immediate
   q'#create table wri$_optstat_histhead_history2
      (obj#            number not null,
       intcol#         number not null,
       savtime         timestamp with time zone,
       flags           number, 
       null_cnt        number,
       minimum         number,
       maximum         number,
       distcnt         number,
       density         number,
       lowval          raw(32),
       hival           raw(32),
       avgcln          number,
       sample_distcnt  number,
       sample_size     number,
       timestamp#      date,  
       expression      clob,  
       colname         varchar2(30),
       spare1          number,           
       spare2          number,
       spare3          number,            
       spare4          varchar2(1000),                        
       spare5          varchar2(1000),
       spare6          timestamp with time zone,
       savtime_date as (trunc(savtime))
     ) 
     partition by range (savtime_date)
     interval (numtodsinterval(1,'day'))
     (partition p_old values less than (to_date('#' || 
        to_char(sysdate, 'dd-mm-yyyy hh:mi:ss') || q'#', 
                         'dd-mm-yyyy hh:mi:ss')),
      partition p_permanent values less than (to_date('#' || 
        to_char(sysdate+0.000012, 'dd-mm-yyyy hh:mi:ss') || q'#', 
                                  'dd-mm-yyyy hh:mi:ss')))
     tablespace sysaux
     pctfree 1
     enable row movement #';
  end if; 

  -- U4. Transfer pending stats (if any) into the new table
  -- Insert pending stats (if any) into the new table
  execute immediate 
    q'#insert into wri$_optstat_histhead_history2(
         obj#, intcol#, savtime, flags,
         null_cnt, minimum, maximum, 
         distcnt, density, lowval,
         hival, avgcln, sample_distcnt, 
         sample_size, timestamp#,
         expression, colname, spare1, 
         spare2, spare3, spare4,
         spare5, spare6)
      select 
         obj#, intcol#, savtime, flags,
         null_cnt, minimum, maximum, 
         distcnt, density, lowval,
         hival, avgcln, sample_distcnt, 
         sample_size, timestamp#,
         expression, colname, spare1, 
         spare2, spare3, spare4,
         spare5, spare6
      from wri$_optstat_histhead_history 
      where savtime > sysdate #';

  commit;

  -- delete the pending stats (if any) from the old table
  execute immediate 
    'delete from wri$_optstat_histhead_history where savtime > sysdate';

  commit;

  -- U5. Plug-in wri$_optstat_histhead_history as a partition of 
  -- wri$_optstat_histhead_history2.
  execute immediate
    q'#alter table wri$_optstat_histhead_history2  exchange partition p_old 
       with table wri$_optstat_histhead_history without validation 
       update global indexes #';

  -- U6. Drop table wri$_optstat_histhead_history.
  execute immediate q'#drop table wri$_optstat_histhead_history#';

  -- U7. Rename wri$_optstat_histhead_history2 as wri$_optstat_histhead_history.
  execute immediate 
     q'#alter table wri$_optstat_histhead_history2 
        rename to wri$_optstat_histhead_history#';

  -- U8. Create the same indexes that wri$_optstat_histhead_history has for
  -- wri$_optstat_histhead_history2.
  execute immediate
    q'#create unique index i_wri$_optstat_hh_obj_icol_st on
       wri$_optstat_histhead_history (obj#, intcol#, savtime, colname)
       tablespace sysaux #';

  execute immediate
    q'#create index i_wri$_optstat_hh_st on
       wri$_optstat_histhead_history (savtime)
       tablespace sysaux #';
end;
/

-- 
-- Now perform the upgrade steps for histogram history table.
--
declare
  cnt        number := 0;
  spare1_id  number := 0; 
  colname_id number := 0;
  compatible_val number := 0;
begin  
  -- U1. Check if the upgrade has already taken place.
  select count(*) into cnt
    from all_part_tables
   where owner = 'SYS' and
         table_name = 'WRI$_OPTSTAT_HISTGRM_HISTORY';

  if (cnt = 1) then
    -- upgrade has already taken place, do nothing.
    return;
  end if;

  -- make sure that compatibility is set to 11 or higher
  SELECT to_number(REGEXP_REPLACE(value || '.0.0.0', 
                        '^([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9]+)\.([0-9\.]*)', 
                        '\1\2\3\4')) into compatible_val
  FROM v$parameter 
  WHERE UPPER(name) = 'COMPATIBLE';

  if (compatible_val < 11000) then
    -- partitioning is not supported if compatible is less than 11.0.0.0
    return;
  end if;

  -- U2. Add virtual column savtime_date into wri$_optstat_histgrm_history.
  execute immediate
   q'#alter table wri$_optstat_histgrm_history 
      add savtime_date as (trunc(savtime)) #';

  execute immediate
    q'#drop index i_wri$_optstat_h_obj#_icol#_st #';

  execute immediate
    q'#create index i_wri$_optstat_h_obj#_icol#_st on
       wri$_optstat_histgrm_history (obj#, intcol#, savtime, colname)
       tablespace sysaux #';

  -- see if we are upgrading from 11g or 10g (column orders are different)  
  -- In 10g table definition, spare1 comes before colname.
  select column_id into spare1_id
    from dba_tab_columns
   where table_name = 'WRI$_OPTSTAT_HISTGRM_HISTORY'
     and column_name = 'SPARE1';

  select column_id into colname_id
    from dba_tab_columns
   where table_name = 'WRI$_OPTSTAT_HISTGRM_HISTORY'
     and column_name = 'COLNAME';

  -- U3. Create a new partitioned table wri$_optstat_histgrm_history2 which
  -- has the same schema as wri$_optstat_histgrm_history, and is interval 
  -- partitioned based on savtime_date column with two default partitions.
 
  -- Adapt schema accordingly depending on whether we are upgrading from
  -- 10g or 11g.
  if (spare1_id < colname_id) then -- upgrading from 10g  
   execute immediate
   q'#create table wri$_optstat_histgrm_history2
      (obj#            number not null,
       intcol#         number not null,         
       savtime         timestamp with time zone,
       bucket          number not null,        
       endpoint        number not null,      
       epvalue         varchar2(1000),                       
       spare1          number,
       spare2          number,
       spare3          number,
       spare4          varchar2(1000),
       spare5          varchar2(1000),
       spare6          timestamp with time zone,
       colname         varchar2(30),              
       savtime_date as (trunc(savtime))
     ) 
     partition by range (savtime_date)
     interval (numtodsinterval(1,'day'))
     (partition p_old values less than (to_date('#' || 
        to_char(sysdate, 'dd-mm-yyyy hh:mi:ss') || q'#', 
                         'dd-mm-yyyy hh:mi:ss')),
      partition p_permanent values less than (to_date('#' || 
        to_char(sysdate+0.000012, 'dd-mm-yyyy hh:mi:ss') || q'#', 
                                  'dd-mm-yyyy hh:mi:ss')))
     tablespace sysaux
     pctfree 1
     enable row movement #';  
  else -- upgrading from 11g
   execute immediate
   q'#create table wri$_optstat_histgrm_history2
      (obj#            number not null,
       intcol#         number not null,         
       savtime         timestamp with time zone,
       bucket          number not null,        
       endpoint        number not null,      
       epvalue         varchar2(1000),       
       colname         varchar2(30),                       
       spare1          number,
       spare2          number,
       spare3          number,
       spare4          varchar2(1000),
       spare5          varchar2(1000),
       spare6          timestamp with time zone,
       savtime_date as (trunc(savtime))
     ) 
     partition by range (savtime_date)
     interval (numtodsinterval(1,'day'))
     (partition p_old values less than (to_date('#' || 
        to_char(sysdate, 'dd-mm-yyyy hh:mi:ss') || q'#', 
                         'dd-mm-yyyy hh:mi:ss')),
      partition p_permanent values less than (to_date('#' || 
        to_char(sysdate+0.000012, 'dd-mm-yyyy hh:mi:ss') || q'#', 
                                  'dd-mm-yyyy hh:mi:ss')))
     tablespace sysaux
     pctfree 1
     enable row movement #';  
  end if;


  -- U4. Transfer pending stats (if any) into the new table
  -- Insert pending stats (if any) into the new table
  execute immediate 
    q'#insert into wri$_optstat_histgrm_history2(
         obj#, intcol#, savtime,
         bucket, endpoint, epvalue, colname,
         spare1, spare2, spare3, spare4,
         spare5, spare6)
      select 
         obj#, intcol#, savtime,
         bucket, endpoint, epvalue,
         colname, spare1, 
         spare2, spare3, spare4,
         spare5, spare6
      from wri$_optstat_histgrm_history 
      where savtime > sysdate #';

  commit;

  -- delete the pending stats (if any) from the old table
  execute immediate 
    'delete from wri$_optstat_histgrm_history where savtime > sysdate';

  commit;

  -- U5. Plug-in wri$_optstat_histgrm_history as a partition of 
  -- wri$_optstat_histgrm_history2.
  execute immediate
    q'#alter table wri$_optstat_histgrm_history2  exchange partition p_old 
       with table wri$_optstat_histgrm_history without validation 
       update global indexes #';

  -- U6. Drop table wri$_optstat_histgrm_history.
  execute immediate q'#drop table wri$_optstat_histgrm_history#';

  -- U7. Rename wri$_optstat_histgrm_history2 as wri$_optstat_histgrm_history.
  execute immediate 
     q'#alter table wri$_optstat_histgrm_history2 
        rename to wri$_optstat_histgrm_history#';

  -- U8. Create the same indexes that wri$_optstat_histgrm_history has for
  -- wri$_optstat_histgrm_history2.
  execute immediate
    q'#create index i_wri$_optstat_h_obj#_icol#_st on
       wri$_optstat_histgrm_history (obj#, intcol#, savtime, colname)
       tablespace sysaux #';

  execute immediate
    q'#create index i_wri$_optstat_h_st on
       wri$_optstat_histgrm_history (savtime)
       tablespace sysaux #';

end;
/

alter session set events  '14524 trace name context off';

Rem *************************************************************************
Rem Stats history purging changes - END
Rem *************************************************************************

Rem *************************************************************************
Rem #(13898075) BEGIN
Rem *************************************************************************

-- Increase the size of valchar column
-- Note that there is no downgrade action as server code handles
-- this new length
alter table optstat_user_prefs$ modify valchar varchar2(4000);

Rem *************************************************************************
Rem #(13898075) END
Rem *************************************************************************

Rem *************************************************************************
Rem insert dbid in WRM$_BASELINE for imported database also
Rem *************************************************************************

BEGIN
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
    where not exists (select 1 from wrm$_baseline b where b.dbid = dbid and b.baseline_id = 0)';
  commit;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00001, -942 ) THEN
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

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
Rem END   c1102000.sql
Rem *************************************************************************
