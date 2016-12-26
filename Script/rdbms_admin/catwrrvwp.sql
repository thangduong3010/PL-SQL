Rem
Rem $Header: rdbms/admin/catwrrvwp.sql /st_rdbms_11.2.0/2 2012/08/01 16:35:42 shjoshi Exp $
Rem
Rem catwrrvwp.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catwrrvwp.sql - Catalog script for
Rem                      the Workload Replay views 
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary views for the
Rem      Workload Replay infra-structure.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      07/03/12 - Backport shjoshi_rm_newtype from main
Rem    yujwang     06/12/12 - Backport
Rem                           apfwkr_blr_backport_13947480_11.2.0.3.2dbpsu from
Rem                           st_rdbms_11.2.0.3.0dbpsu
Rem    sburanaw    01/09/10 - add filter_set to dba_workload_replays
Rem    arbalakr    11/13/09 - truncate module/action to the maximum lengths
Rem                           in X$MODACT_LENGTH
Rem    lgalanis    04/01/09 - support for SQL tuning set capture during
Rem                           workload capture or replay
Rem    rcolle      02/12/09 - only show DB Replays in views
Rem    rcolle      01/09/09 - add error message in divergence view
Rem    rcolle      12/04/08 - add dba_workload_replay_filter_set
Rem    yujwang     10/03/08 - add scale_up_multiplier to dba_workload_replays
Rem    rcolle      10/01/08 - change synchronization column in
Rem                           dba_workload_replays
Rem    rcolle      09/03/08 - add pause_time to dba_workload_replays
Rem    sburanaw    06/02/08 - add replay_dir_number to dba_workload_replays
Rem    veeve       06/12/07 - remove new/mutated error stats
Rem    veeve       02/14/07 - add awr_ cols to dba_workload_replays
Rem    lgalanis    09/14/06 - add replay id to dba_workload_connection_map view
Rem    yujwang     09/07/06 - add columns for divergence type to
Rem                           dba_workload_replay_divergence
Rem    veeve       09/05/06 - add capture_id
Rem    yujwang     08/05/06 - add replay stats to dba_workload_replays
Rem    veeve       07/25/06 - added dbid, dbname
Rem    veeve       06/14/06 - add DBA_WORKOAD_REPLAY_DIVERGENCE
Rem    lgalanis    06/07/06 - public synonyms for dba views 
Rem    lgalanis    06/05/06 - connection information view 
Rem    veeve       04/11/06 - add REPLAY dict
Rem

Rem =========================================================
Rem Creating the Workload Replay Views
Rem =========================================================
Rem

create or replace view DBA_WORKLOAD_REPLAYS
(ID, NAME, 
 DBID, DBNAME, DBVERSION,
 PARALLEL,
 DIRECTORY,
 CAPTURE_ID,
 STATUS,
 PREPARE_TIME, START_TIME, END_TIME, 
 DURATION_SECS,
 NUM_CLIENTS,
 NUM_CLIENTS_DONE,
 FILTER_SET_NAME,
 DEFAULT_ACTION,
 SYNCHRONIZATION, 
 CONNECT_TIME_SCALE,
 THINK_TIME_SCALE,
 THINK_TIME_AUTO_CORRECT,
 SCALE_UP_MULTIPLIER,
 USER_CALLS, DBTIME, NETWORK_TIME, THINK_TIME, PAUSE_TIME,
 ELAPSED_TIME_DIFF,
 AWR_DBID, AWR_BEGIN_SNAP, AWR_END_SNAP,
 AWR_EXPORTED,
 ERROR_CODE, ERROR_MESSAGE,
 DIR_PATH,
 REPLAY_DIR_NUMBER,
 SQLSET_OWNER,
 SQLSET_NAME,
 SCHEDULE_NAME)
as
select 
 r.id, r.name
 , r.dbid, r.dbname, r.dbversion
 , (case when rs.parallel > 0 then 'YES' else 'NO' end)
 , r.directory
 , r.capture_id
 , r.status
 , r.prepare_time, r.start_time, r.end_time
 , round((r.end_time - r.start_time) * 86400)
 , r.num_clients
 , r.num_clients_done
 , r.filter_set_name
 , r.default_action
 , decode(r.synchronization, 1, 'SCN', 2, 'OBJECT_ID', 'FALSE')
 , r.connect_time_scale
 , r.think_time_scale
 , decode(r.think_time_auto_correct, 1, 'TRUE', 'FALSE')
 , r.scale_up_multiplier
 , rs.user_calls, rs.dbtime, rs.network_time, rs.think_time, rs.time_paused
 , (rs.time_gain - rs.time_loss)
 , r.awr_dbid, r.awr_begin_snap, r.awr_end_snap
 , decode(r.awr_exported, 1, 'YES', 0, 'NO', 'NOT POSSIBLE')
 , r.error_code, r.error_msg
 , r.dir_path
 , r.replay_dir_number
 , r.sqlset_owner
 , r.sqlset_name
 , r.schedule_name
from
 wrr$_replays r
 , (select id,
           sum(decode(parallel,'YES',1,0)) as parallel,
           sum(user_calls) as user_calls,
           sum(dbtime) as dbtime,
           sum(network_time) as network_time,
           sum(think_time) as think_time,
           sum(time_gain) as time_gain,
           sum(time_loss) as time_loss,
           sum(time_paused) as time_paused
    from   wrr$_replay_stats
    group by id) rs
where r.id = rs.id(+)
and   nvl(r.replay_type, 'DB') = 'DB'
/

create or replace public synonym dba_workload_replays
   for sys.dba_workload_replays;
grant select on dba_workload_replays to select_catalog_role;

Rem
Rem Workload replay divergence information
Rem
create or replace view DBA_WORKLOAD_REPLAY_DIVERGENCE
(REPLAY_ID,
 TIMESTAMP,
 DIVERGENCE_TYPE,
 IS_QUERY_DATA_DIVERGENCE,
 IS_DML_DATA_DIVERGENCE,
 IS_ERROR_DIVERGENCE,
 IS_THREAD_FAILURE,
 IS_DATA_MASKED,
 EXPECTED_ROW_COUNT,
 OBSERVED_ROW_COUNT,
 EXPECTED_ERROR#,
 EXPECTED_ERROR_MESSAGE,
 OBSERVED_ERROR#,
 OBSERVED_ERROR_MESSAGE,
 STREAM_ID,
 CALL_COUNTER,
 CAPTURE_STREAM_ID,
 SQL_ID,
 SESSION_ID,
 SESSION_SERIAL#,
 SERVICE,
 MODULE,
 ACTION)
as
select 
 rd.id
 , rd.time
 , rd.type
 , decode(bitand(rd.type, 1), 0, 'N','Y') as IS_QUERY_DATA_DIVERGENCE
 , decode(bitand(rd.type, 2), 0, 'N','Y') as IS_DML_DATA_DIVERGENCE
 , decode(bitand(rd.type, 4), 0, 'N','Y') as IS_ERROR_DIVERGENCE
 , decode(bitand(rd.type,16), 0, 'N','Y') as IS_THREAD_FAILURE
 , decode(bitand(rd.type,64), 0, 'N','Y') as IS_DATA_MASKED
 , rd.exp_num_rows
 , rd.obs_num_rows
 , rd.exp_error
 , decode(rd.exp_error, 0, NULL, dbms_advisor.format_message(rd.exp_error))
 , rd.obs_error
 , decode(rd.obs_error, 0, NULL, dbms_advisor.format_message(rd.obs_error))
 , rd.file_id
 , rd.call_counter
 , rd.cap_file_id
 , rd.sql_id
 , rd.session_id
 , rd.session_serial#
 , rd.service
 , substrb(rd.module,1,(select ksumodlen from x$modact_length)) module
 , substrb(rd.action,1,(select ksuactlen from x$modact_length)) action
 from  WRR$_REPLAY_DIVERGENCE rd, WRR$_REPLAYS r
 where r.id = rd.id
 and   nvl(r.replay_type, 'DB') = 'DB';
/ 

create or replace public synonym dba_workload_replay_divergence
   for sys.dba_workload_replay_divergence;
grant select on dba_workload_replay_divergence to select_catalog_role;


Rem
Rem connection mapping information
Rem
create or replace view DBA_WORKLOAD_CONNECTION_MAP
(replay_id,
 conn_id, 
 schedule_cap_id,
 capture_conn, 
 replay_conn)
as
 select replay_id, conn_id, schedule_cap_id, capture_conn, replay_conn
 from WRR$_CONNECTION_MAP
/ 

create or replace public synonym dba_workload_connection_map
   for sys.dba_workload_connection_map;
grant select on dba_workload_connection_map to select_catalog_role;

Rem
Rem user mapping information
Rem
create or replace view DBA_WORKLOAD_USER_MAP
(replay_id,
 schedule_cap_id,
 capture_user, 
 replay_user)
as
 select replay_id, schedule_cap_id, capture_user, replay_user
 from WRR$_USER_MAP
/ 

Rem
Rem active user mappings to take effect for the current or next replay
Rem
create or replace view DBA_WORKLOAD_ACTIVE_USER_MAP
(schedule_cap_id,
 capture_user,
 replay_user)
as 
  select schedule_cap_id, capture_user, replay_user
  from WRR$_USER_MAP m, WRR$_REPLAYS r
  where m.replay_id = r.id and 
        (r.status = 'INITIALIZED' 
         or r.status = 'IN PROGRESS'
         or r.status = 'PREPARE')
/

create or replace public synonym dba_workload_user_map
   for sys.dba_workload_user_map;
grant select on dba_workload_user_map to select_catalog_role;

create or replace public synonym dba_workload_active_user_map
   for sys.dba_workload_active_user_map;
grant select on dba_workload_active_user_map to select_catalog_role;

Rem
Rem replay filter sets
Rem
create or replace view DBA_WORKLOAD_REPLAY_FILTER_SET
(capture_id,
 set_name,
 filter_name,
 attribute, 
 value)
as
 select capture_id, set_name, filter_name, attribute, value
 from WRR$_REPLAY_FILTER_SET
/ 

create or replace public synonym dba_workload_replay_filter_set
   for sys.dba_workload_replay_filter_set;
grant select on dba_workload_replay_filter_set to select_catalog_role;

Rem
Rem Replay schedules
Rem
create or replace view DBA_WORKLOAD_REPLAY_SCHEDULES
(schedule_name,
 directory,
 status)
as 
 select schedule_name, directory, status
 from   WRR$_REPLAY_SCHEDULES;
/

create or replace public synonym dba_workload_replay_schedules
   for sys.dba_workload_replay_schedules;
grant select on dba_workload_replay_schedules to select_catalog_role;

---
--- create view DBA_WORKLOAD_SCHEDULE_CAPTURES
--- 
create or replace view DBA_WORKLOAD_SCHEDULE_CAPTURES
( schedule_name                                      /* replay schedule name */
 ,schedule_cap_id             /* schedule capture ID returned by add_capture */
 ,capture_id                        /* capture ID from dba_workload_captures */
 ,capture_dir                                    /* capture directory object */
 ,os_subdir                           /* OS subdirectory name of the capture */
 ,max_concurrent_sessions   /* max concurrent sessions computed by calibrate */
 ,num_clients_assigned        /* number of wrc assigned before replay starts */
 ,num_clients                                 /* number of wrc during replay */
 ,num_clients_done                /* number of wrc that are done with replay */
 ,stop_replay               /* 'Y' to stop the whole replay, 'N' to continue */
 ,take_begin_snapshot
              /* 'Y': take a snapshot when the replay of this capture starts */
 ,take_end_snapshot 
            /* 'Y': take a snapshot when the replay of this capture finishes */
 ,query_only          /* 'Y': replay the read-only queries from this capture */
 ,start_delay_secs    /* wait time in seconds when capture is ready to start */
 ,start_time                    /* start time for the replay of this capture */
 ,end_time                      /* finish time of the replay of this capture */
 ,awr_dbid                                        /* AWR DB ID of the replay */
 ,awr_begin_snap                   /* AWR snapshot ID when the replay starts */
 ,awr_end_snap                   /* AWR snapshot ID when the replay finishes */
)
as 
 select schedule_name, schedule_cap_id, capture_id, 
        capture_dir, os_subdir, max_concurrent_sessions, 
        num_clients_assigned, num_clients,
        num_clients_done, stop_replay, take_begin_snapshot,
        take_end_snapshot, query_only, start_delay_secs,
        start_time,end_time,awr_dbid,awr_begin_snap,awr_end_snap        
 from   WRR$_SCHEDULE_CAPTURES
/

create or replace public synonym dba_workload_schedule_captures
   for sys.dba_workload_schedule_captures;
grant select on dba_workload_schedule_captures to select_catalog_role;

create or replace view DBA_WORKLOAD_SCHEDULE_ORDERING
( schedule_name
 ,schedule_cap_id
 ,waitfor_cap_id
)
as 
 select schedule_name, schedule_cap_id, waitfor_cap_id
 from   WRR$_SCHEDULE_ORDERING
/

create or replace public synonym dba_workload_schedule_ordering
   for sys.dba_workload_schedule_ordering;
grant select on dba_workload_schedule_ordering 
   to select_catalog_role;
