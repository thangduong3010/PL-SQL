Rem
Rem $Header: rdbms/admin/catwrrtbp.sql /st_rdbms_11.2.0/2 2013/03/11 01:24:27 yujwang Exp $
Rem
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catwrrtbp.sql - Catalog script for 
Rem                      the Workload RePlay tables
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary tables for the 
Rem      Workload Replay infra-structure.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem      Almost all DML on the tables defined in 
Rem      this script comes from DBMS_WORKLOAD_REPLAY.
Rem
Rem      Assumes that the COMMON schema (all objects shared
Rem      between both the Capture and the Replay infra-structure)
Rem      have already been created by catwrrtbc.sql
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/catwrrtbp.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catwrrtbp.sql
Rem SQL_PHASE: CATWRRTBP
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catwrrtb.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hpoduri     09/20/12 - add capture/replay specialization to ash compare
Rem                           period
Rem    hpoduri     07/18/12 - Create a Type to Represent a ASH Time Period.
Rem    surman      04/12/12 - 13615447: Add SQL patching tags
Rem    lgalanis    12/21/11 - add the user map
Rem    spapadom    11/10/11 - add WRR$_ASREPLAY_DATA table
Rem    yujwang     10/15/11 - add columns to wrr$_schedule_captures
Rem    yujwang     08/17/11 - add schedule_name to wrr$_replays
Rem    kmorfoni    05/09/11 - Add cap_file_id to WRR$_REPLAY_DIVERGENCE and
Rem                           WRR$_REPLAY_SQL_BINDS
Rem    kmorfoni    04/12/11 - add WRR$_FILE_ID_MAP for consolidated replay
Rem    yujwang     04/07/11 - add wrr$_replay_directories
Rem    yujwang     02/08/11 - workload consolidation
Rem    traney      03/31/11 - 35209: long identifiers dictionary upgrade
Rem    lgalanis    05/27/10 - add seqeunces per bug 9564700
Rem    sburanaw    01/08/10 - add filter_set to wrr$_replays
Rem    lgalanis    01/04/10 - add AWR sequences in the exceptions
Rem    arbalakr    11/12/09 - increase length of module and action columns
Rem    lgalanis    03/24/09 - add support for STS capture with Capture and
Rem                           Replay
Rem    yujwang     03/06/09 - fix bug 8265167 by skipping sequence IDGENi$
Rem    rcolle      03/04/09 - ade divergence_details_status in wrr$_replays
Rem    rcolle      02/12/09 - add new columns for AS Replay
Rem    rcolle      01/23/09 - bug 7441901: remove NOT NULL constraint for
Rem                           WRR$_REPLAY_SCN_ORDER
Rem    rcolle      10/31/08 - add WRR$_REPLAY_CALL_FILTER
Rem    yujwang     10/03/08 - add scale_up_multiplier to wrr$_replays
Rem    rcolle      10/08/08 - change SQL text to CLOB in WRR$_REPLAY_SQL_TEXT
Rem    yujwang     10/03/08 - add scale_up_multiplier to wrr$_replays
Rem    rcolle      09/09/08 - add table for new synchronization (dep_graph,
Rem                           commits and references)
Rem    sburanaw    05/12/08 - add rep_dir_id
Rem    sburanaw    03/24/08 - add wrr$_replay_data
Rem    rcolle      08/28/08 - add time_paused to WRR$_REPLAY_STATS
Rem    lgalanis    08/07/08 - table of ignorable sequences
Rem    rcolle      07/08/08 - add WRR$_REPLAY_SQL_TEXT and
Rem                           WRR$_REPLAY_SQL_BINDS
Rem    rcolle      07/02/08 - add sql_phase and sql_exec_call_ctr to 
Rem                           WRR$_REPLAY_DIVERGENCE
Rem    rcolle      05/08/08 - add WRR$_REPLAY_UC_GRAPH
Rem    rcolle      07/05/07 - add call_time in SCN_ORDER table
Rem    veeve       06/12/07 - remove new/mutated error stats
Rem    rcolle      05/17/07 - add preprocessing id to wrr$_replays
Rem    lgalanis    05/10/07 - re-org WRR$_REPLAY_SEQ_DATA
Rem    lgalanis    04/26/07 - remove non-null constraint for replay connection
Rem    veeve       04/05/07 - added dbversion, parallel to wrr$_replays
Rem    veeve       02/14/07 - added awr_ cols to wrr$_replays
Rem    yujwang     08/05/06 - create wrr$_replay_stats
Rem    veeve       07/25/06 - added dbid, dbname
Rem    veeve       06/07/06 - more attrs to WRR$_REPLAY_DIVERGENCE
Rem    lgalanis    06/03/06 - connection information 
Rem    veeve       06/01/06 - add replay divergence, scn_order, seqdata
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       04/11/06 - add num_clients, num_clients_done
Rem    veeve       04/11/06 - add REPLAY dict
Rem

Rem ===============================================================
Rem      ##################################################
Rem      CREATING THE WORKLOAD REPLAY INFRASTRUCTURE SCHEMA
Rem      ##################################################
Rem ===============================================================


Rem =========================================================
Rem Creating the Database Property that remembers if the 
Rem database is in the Replay mode.
Rem
Rem  Set to PREPARE : By DBMS_WORKLOAD_REPLAY.PREPARE_REPLAY
Rem  Set to REPLAY  : By DBMS_WORKLOAD_REPLAY.START_REPLAY
Rem  Reset to NULL  : Upon replay completion and
Rem                   By DBMS_WORKLOAD_REPLAY.CANCEL_REPLAY
Rem =========================================================
Rem
Rem NOTE: This property name is duplicated in KECR_DBPROPERTY_NAME
Rem
insert into PROPS$
        select  'WORKLOAD_REPLAY_MODE', NULL, 
                'PREPARE implies external replay clients can connect; '
                || 'REPLAY implies workload replay is in progress'
        from    sys.dual
        where   not exists (select  'x'
                            from    PROPS$
                            where   name = 'WORKLOAD_REPLAY_MODE')
/
update PROPS$ 
set    value$ = NULL
where  name = 'WORKLOAD_REPLAY_MODE'
/
commit
/


Rem =================================================================
Rem Creating the tables used by the Workload Replay infrastructure
Rem =================================================================
Rem

Rem %%%%%%%%%%%%
Rem WRR$_REPLAYS
Rem %%%%%%%%%%%%
Rem
Rem Table that stores information about the current workload replay
Rem

create table WRR$_REPLAYS
( id                        number          not null
 ,name                      varchar2(128)   not null
 ,dbid                      number          not null
 ,dbname                    varchar2(10)    not null
 ,dbversion                 varchar2(128)    not null
 ,directory                 varchar2(128)    not null
 ,dir_path                  varchar2(4000)  not null
 ,capture_id                number
 ,status                    varchar2(40)    not null
 ,prepare_time              date
 ,start_time                date
 ,end_time                  date
 ,num_clients               number          not null
 ,num_clients_done          number          not null
 ,default_action            varchar2(30)    not null
 ,synchronization           number          not null
 ,connect_time_scale        number          not null
 ,think_time_scale          number          not null
 ,think_time_auto_correct   number          not null
 ,scale_up_multiplier       number          default 1 not null
 ,awr_dbid                  number
 ,awr_begin_snap            number
 ,awr_end_snap              number
 ,awr_exported              number
 ,error_code                number
 ,error_msg                 varchar2(300)
 ,comments                  varchar2(4000)
 ,preprocessing_id          number
 ,replay_dir_number         number
 ,replay_type               varchar2(10)
 ,divergence_details_status varchar2(40)
 ,sqlset_owner              varchar2(128)
 ,sqlset_name               varchar2(128)
 ,sqlset_cap_interval       number
 ,filter_set_name           varchar2(1000)
 ,schedule_name             varchar2(128)
 ,num_admins                number
 ,constraint WRR$_REPLAYS_PK primary key
    (id)
) tablespace SYSTEM
/

comment on column WRR$_REPLAYS.STATUS is
'One of "PREPARE", "IN PROGRESS", "COMPLETED", "CANCELLED" or "FAILED"'
/

comment on column WRR$_REPLAYS.DEFAULT_ACTION is
'One of "INCLUDE" or "EXCLUDE"'
/

Rem %%%%%%%%%%%%%%
Rem WRR$_REPLAY_ID
Rem %%%%%%%%%%%%%%
Rem
Rem Sequence to generate WRR$_REPLAYS.ID
Rem
create sequence WRR$_REPLAY_ID
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  nocycle
  cache 10
/

Rem %%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_STATS
Rem %%%%%%%%%%%%%%%%%
Rem
Rem Table that stores statistic information about workload replay
Rem such as overall database time, network time, think time,
Rem time deficit, and number of user calls
Rem

create table WRR$_REPLAY_STATS
( id                        number
 ,instance_number           number
 ,startup_time              date
 ,host_name                 varchar2(64)
 ,parallel                  varchar2(3)
 ,user_calls                number
 ,dbtime                    number
 ,network_time              number
 ,think_time                number
 ,time_gain                 number
 ,time_loss                 number
 ,time_paused               number
 ,constraint WRR$_REPLAY_STATS_PK primary key
    (id,instance_number,startup_time)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_DIVERGENCE
Rem %%%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information about the data divergence that was
Rem encountered during workload replay.
Rem

create table WRR$_REPLAY_DIVERGENCE
( id                        number          not null
 ,time                      timestamp(6) with time zone
 ,type                      number          not null
 ,exp_num_rows              number
 ,obs_num_rows              number
 ,exp_error                 number
 ,obs_error                 number
 ,file_id                   number          not null
 ,call_counter              number          not null
 ,cap_file_id               number
 ,sql_id                    varchar2(13)
 ,session_id                number          not null
 ,session_serial#           number          not null
 ,service                   varchar2(64)
 ,module                    varchar2(64)
 ,action                    varchar2(64)
 ,sql_phase                 number
 ,sql_exec_call_ctr         number
 ,constraint WRR$_REPLAY_DIVERGENCE_PK primary key
    (id, file_id, call_counter)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_UC_GRAPH
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores the user calls metric history for the exported replays.
Rem

create table WRR$_REPLAY_UC_GRAPH
( id                        number
 ,time                      date
 ,user_calls                number
 ,flags                     number
) tablespace SYSAUX
/

Rem =================================================================
Rem Various work tables used by the Workload Replay infrastructure
Rem These tables are generally truncated and loaded up by 
Rem REPLAY.PREPARE().
Rem =================================================================
Rem

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_SCN_ORDER
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information about all the workload replay clock tickers.
Rem Used for replay synchronization.
Rem

create table WRR$_REPLAY_SCN_ORDER
( call_id                   number          not null
 ,call_time                 number
 ,post_commit_scn           number          not null
 ,stream_id                 number          not null
 ,module                    varchar2(100)
 ,action                    varchar2(100)
 ,ecid                      varchar2(100)
 ,ecid_hash                 number
 ,valid                     char(1)
 ,constraint WRR$_REPLAY_SCN_ORDER_PK primary key 
    (post_commit_scn, stream_id)
) organization index
  tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_SEQ_DATA
Rem %%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information the sequences values that need to be
Rem 'virtualized' during replay.
Rem

create table WRR$_REPLAY_SEQ_DATA
( schedule_cap_id  number           default 0 not null
 ,file_id          number           not null
 ,call_ctr         number           not null
 ,rank             number           not null
 ,seq_name         varchar2(128)    not null
 ,seq_bnm          varchar2(128)    not null
 ,seq_bow          varchar2(128)    not null
 ,first_value      number           not null
 ,last_value       number
 ,change           number
 ,num_values       number
 ,constraint WRR$_REPLAY_SEQ_DATA_PK primary key
    (schedule_cap_id, file_id, call_ctr, rank, seq_name, seq_bnm, seq_bow)
) organization index
  tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_DATA
Rem %%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information the values that need to be
Rem 'virtualized' during replay.
Rem

create table WRR$_REPLAY_DATA
( schedule_cap_id  number           default 0 not null
 ,file_id          number           not null
 ,call_ctr         number           not null
 ,rank             number           not null
 ,data_type        number           not null
 ,value            raw(255)
 ,constraint WRR$_REPLAY_DATA_PK primary key
    (schedule_cap_id, file_id, call_ctr, rank, data_type)
) organization index
  tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%
Rem WRR$_CONNECTION_MAP
Rem %%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information about the mapping between recorded
Rem connections and their replay time counterparts
Rem
create table WRR$_CONNECTION_MAP
( replay_id        number         not null
 ,conn_id          number         not null
 ,schedule_cap_id  number 
 ,capture_conn     varchar2(4000) not null
 ,replay_conn      varchar2(4000)
 ,constraint    WRR$_CONNECTION_MAP_PK primary key (replay_id, conn_id)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%
Rem WRR$_USER_MAP
Rem %%%%%%%%%%%%%
Rem
Rem Table that stores information about the mapping between recorded
Rem users and the new users to be used during replay
Rem
create table WRR$_USER_MAP
( replay_id        number
 ,schedule_cap_id  number 
 ,capture_user     varchar2(4000) not null
 ,replay_user      varchar2(4000)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_SQL_TEXT
Rem %%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores SQL ID and SQL text for calls populated by 'GetCallInfo'
Rem
create table WRR$_REPLAY_SQL_TEXT
( sql_id        varchar2(13)   not null
 ,sql_text      varchar2(4000)
 ,full_sql_text CLOB
 ,constraint  WRR$_REPLAY_SQL_TEXT_PK primary key
    (sql_id)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_SQL_BINDS
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores bind metadata and values for calls populated by 
Rem 'GetCallInfo'
Rem
create table WRR$_REPLAY_SQL_BINDS
( capture_id     number          not null
 ,file_id        number          not null
 ,call_counter   number          not null
 ,cap_file_id    number          not null
 ,iteration      number          not null
 ,bind_pos       number          not null
 ,bind_varname   varchar2(1000)
 ,bind_value     varchar2(4000)
 ,constraint  WRR$_REPLAY_SQL_BINDS_PK primary key
    (capture_id, file_id, call_counter, iteration, bind_pos)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%%%%
Rem WRR$_SEQUENCE_EXCEPTIONS
Rem %%%%%%%%%%%%%%%%%%%%%%%%
Rem 
Rem This table holds sequences that we should ignore during replay such as
Rem certain system sequences.
Rem
create table WRR$_SEQUENCE_EXCEPTIONS
( sequence_owner  varchar2(128) not null
 ,sequence_name   varchar2(128) not null
) tablespace SYSAUX
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'SQLLOG$_SEQ')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN1$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN2$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN3$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN4$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN5$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN6$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN7$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN8$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN9$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS 
values ('SYS', 'IDGEN10$')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values ('SYS', 'AQ$_IOTENQTXID')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ADV_SEQ_DIR')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ADV_SEQ_DIR_INST')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ADV_SEQ_EXEC')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ADV_SEQ_JOURNAL')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ADV_SEQ_MSGGROUP')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ADV_SEQ_SQLW_QUERY')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ADV_SEQ_TASK')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ADV_SQLT_PLAN_SEQ')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ALERT_SEQUENCE')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_ALERT_THRSLOG_SEQUENCE')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_REPT_COMP_ID_SEQ')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_REPT_FILE_ID_SEQ')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_REPT_FORMAT_ID_SEQ')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_REPT_REPT_ID_SEQ')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_SQLSET_ID_SEQ')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_SQLSET_REF_ID_SEQ')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_SQLSET_STMT_ID_SEQ')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', 'WRI$_SQLSET_WORKSPACE_PLAN_SEQ')
/

Rem bug 9564700
insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', '_NEXT_OBJECT')
/

insert into WRR$_SEQUENCE_EXCEPTIONS
values('SYS', '_NEXT_USER')
/

Rem =================================================================
Rem Various tables used by the Workload Replay filters infrastructure
Rem =================================================================
Rem

Rem %%%%%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_CALL_FILTER
Rem %%%%%%%%%%%%%%%%%%%%%%%%
Rem 
Rem 
Rem
create table WRR$_REPLAY_CALL_FILTER
( file_id              number
 ,call_counter_begin   number
 ,call_counter_end     number 
) tablespace SYSAUX
/
grant select on WRR$_REPLAY_CALL_FILTER to public;

Rem %%%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_FILTER_SET
Rem %%%%%%%%%%%%%%%%%%%%%%
Rem 
Rem 
Rem
create table WRR$_REPLAY_FILTER_SET
( capture_id   number          not null
 ,set_name     varchar2(1000)  not null
 ,filter_name  varchar2(100)   not null
 ,attribute    varchar2(100)   not null
 ,value        varchar2(4000)  not null
 ,default_action varchar2(20)
 ,constraint WRR$_REPLAY_FILTER_SET_PK primary key
    (capture_id, set_name, filter_name)
) tablespace SYSAUX
/

commit
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_DEP_GRAPH
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information about real dependenies between 
Rem captures process.
Rem
create table WRR$_REPLAY_DEP_GRAPH
( schedule_cap_id  number default 0 not null
 ,file_id          number
 ,call_ctr         number
 ,file_id_dep      number
 ,call_ctr_dep     number
 ,sync_point       number
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_COMMITS
Rem %%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores information about DB commit, ie database-wide 
Rem dependencies.
Rem
create table WRR$_REPLAY_COMMITS
( schedule_cap_id  number default 0 not null
 ,file_id          number
 ,call_ctr         number
 ,db_seq           number
 ,valid            VARCHAR2(1)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_REFERENCES
Rem %%%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores the number of times a process is referenced as a commit
Rem or a DB commit..
Rem
create table WRR$_REPLAY_REFERENCES
( schedule_cap_id  number default 0 not null
 ,file_id          number
 ,refs             number
) tablespace SYSAUX
/

REM %%%%%%%%%%%%%%%%%%%%%%%%
REM WRR$_WORKLOAD_ATTRIBUTES
REM %%%%%%%%%%%%%%%%%%%%%%%%
REM 
REM Workload attributes 
REM 
create table WRR$_WORKLOAD_ATTRIBUTES
( capture_id  number not null
 ,replay_id   number not null
 ,name        varchar2(50)
 ,value       varchar2(400)
 ,constraint WRR$_WORKLOAD_ATTRIBUTES_PK 
             PRIMARY KEY (capture_id, replay_id, name)
) organization index tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_DIRECTORY
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores the current replay directory
Rem
create table WRR$_REPLAY_DIRECTORY
( directory        varchar2(128)   not null
 ,dir_path         varchar2(4000)  not null
 ,status           varchar2(128)
 ,constraint WRR$_REPLAY_DIRS_PK primary key (directory)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%
Rem WRR$_REPLAY_SCHEDULES
Rem %%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores schedule names used for consolidated replays
Rem
create table WRR$_REPLAY_SCHEDULES
( schedule_name    varchar2(128)   not null
 ,directory        varchar2(128)   not null
 ,status           varchar2(128)
 ,constraint WRR$_REPLAY_SCHEDULES_PK primary key (schedule_name)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%%
Rem WRR$_SCHEDULE_CAPTURES
Rem %%%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores the captures that are part of a replay schedule
Rem
create table WRR$_SCHEDULE_CAPTURES
( schedule_name            varchar2(128)   not null
 ,schedule_cap_id          number          not null
 ,capture_id               number          not null
 ,capture_dir              varchar2(128)   not null
 ,os_subdir                varchar2(4000)  not null
 ,max_concurrent_sessions  number
 ,num_clients_assigned     number
 ,num_clients              number
 ,num_clients_done         number
 ,stop_replay              varchar2(1)     default 'N' not null
 ,take_begin_snapshot      varchar2(1)     default 'N' not null
 ,take_end_snapshot        varchar2(1)     default 'N' not null
 ,query_only               varchar2(1)     default 'N' not null
 ,start_delay_secs         number          default 0
 ,dependent_level          number
 ,start_time               date
 ,end_time                 date
 ,awr_dbid                 number
 ,awr_begin_snap           number
 ,awr_end_snap             number
 ,status                   varchar2(128)
 ,constraint WRR$_SCHEDULE_CAPTURES_PK primary key 
    (schedule_name, schedule_cap_id)
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%%
Rem WRR$_SCHEDULE_ORDERING
Rem %%%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores the schedule dependency to specify the wait-for
Rem order between two participated captures
Rem
create table WRR$_SCHEDULE_ORDERING
( schedule_name         varchar2(128)   not null
 ,schedule_cap_id       number          not null
 ,waitfor_cap_id        number          not null
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%%%%%%%%%%%
Rem WRR$_FILE_ID_MAP
Rem %%%%%%%%%%%%%%%%%%%%%%%%%
Rem
Rem Table that stores the mapping between capture file ids and replay file ids.
Rem Note that we have introduced replay file ids for replay consolidation.
Rem
create table WRR$_FILE_ID_MAP
( cap_file_id           number          not null
 ,schedule_cap_id       number          not null
 ,file_count            number          
 ,rep_file_id           number          default 0
 ,constraint WRR$_FILE_ID_MAP_PK primary key 
    (cap_file_id, schedule_cap_id)
) tablespace SYSAUX
/
Rem %%%%%%%%%%%%%%%%%%%%%%%%%%%
Rem WRR$_ASH_TIME_PERIOD
Rem %%%%%%%%%%%%%%%%%%%%%%%%%%%

Rem
Rem Object type to store Ash Time Period details.
Rem

create type WRR$_ASH_TIME_PERIOD AUTHID CURRENT_USER AS OBJECT
(
  m_db_id           INTEGER,
  m_begin_time TIMESTAMP(3),
  m_end_time   TIMESTAMP(3),
  m_begin_snap_id   INTEGER,
  m_end_snap_id     INTEGER,
  m_ash_disk_filter INTEGER,
  m_ash_sample_rate INTEGER,
  m_id         VARCHAR2(30),
  m_time_period_type VARCHAR2(30),
  m_filter_condition VARCHAR2(512),
  m_desc       VARCHAR2(256),
  FINAL INSTANTIABLE CONSTRUCTOR FUNCTION 
           wrr$_ash_time_period( p_db_id IN INTEGER,
                        p_begin_time IN TIMESTAMP,
                        p_end_time  IN  TIMESTAMP,
                        p_begin_snap_id IN INTEGER,
                        p_end_snap_id IN INTEGER,
                        p_id IN VARCHAR2 )
  RETURN SELF AS RESULT
) FINAL INSTANTIABLE ;
/

grant EXECUTE ON wrr$_ASH_TIME_PERIOD to PUBLIC;
/
  
create or replace type body WRR$_ASH_TIME_PERIOD 
  AS
  FINAL INSTANTIABLE CONSTRUCTOR FUNCTION
    wrr$_ash_time_period( p_db_id INTEGER,
                        p_begin_time TIMESTAMP,
                        p_end_time   TIMESTAMP,
                        p_begin_snap_id INTEGER,
                        p_end_snap_id INTEGER,
                        p_id IN VARCHAR2 )
    RETURN SELF AS RESULT
  IS
    l_db_id INTEGER;  
  BEGIN
    m_db_id         := p_db_id;
    m_begin_time    := p_begin_time;
    m_end_time      := p_end_time;
    m_begin_snap_id := p_begin_snap_id;
    m_end_snap_id   := p_end_snap_id;
    m_id            := p_id;
    m_time_period_type  := NULL;
    m_filter_condition  := NULL;
    m_desc              := NULL;
    RETURN;
  END;

END;
/
