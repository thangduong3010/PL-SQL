Rem
Rem $Header: rdbms/admin/catwrrvwc.sql /main/7 2010/02/03 10:34:52 sburanaw Exp $
Rem
Rem catwrrvwc.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catwrrvwc.sql - Catalog script for
Rem                      the Workload Capture views 
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary views for the
Rem      Workload Capture infra-structure.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sburanaw    01/11/10 - add info from wrr$_replay_filter_set to
Rem                           dba_workload_filters, dba_workload_filter_set
Rem    lgalanis    04/01/09 - support for SQL tuning set capture during
Rem                           workload capture or replay
Rem    veeve       04/12/06 - made FILTERS.STATUS [NEW|IN USE|USED]
Rem    veeve       12/18/06 - add dbversion, parallel, _total s 
Rem                           to dba_workload_captures
Rem    yujwang     08/08/06 - remove unsupported_calls
Rem    veeve       08/03/06 - added dbid, dbname, last_prep_version
Rem    veeve       07/13/06 - added capture_size
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       01/25/06 - Created
Rem

Rem =========================================================
Rem Creating the Common Infrastructure Views
Rem =========================================================
Rem

create or replace view dba_workload_filters
(TYPE,
 ID, 
 STATUS, 
 SET_NAME, NAME, ATTRIBUTE, VALUE)
as
select
 f.filter_type,
 decode(f.wrr_id, 0, NULL, f.wrr_id), 
 (case when c.status = 'IN PROGRESS'
       then 'IN USE'
       when f.wrr_id = 0
       then 'NEW'
       else 'USED'
  end) as status,
 NULL, f.name, f.attribute, f.value
from
 wrr$_filters  f, 
 wrr$_captures c
where f.wrr_id = c.id(+)
  and f.filter_type = 'CAPTURE'
UNION ALL
select
 f.filter_type,
 decode(f.wrr_id, 0, NULL, f.wrr_id), 
 (case when r.status = 'IN PROGRESS' 
         or r.status = 'INITIALIZED' 
         or r.status = 'PREPARE'
       then 'IN USE'
       when f.wrr_id = 0
       then 'NEW'
       else 'USED'
  end) as status,
 r.filter_set_name, f.name, f.attribute, f.value
from
 wrr$_filters  f, 
 wrr$_replays r
where f.filter_type = 'REPLAY'
  and f.wrr_id = r.id(+)
UNION ALL
select
 'REPLAY' as filter_type,
 NULL as wrr_id,
 'IN SET' as status,
 set_name, filter_name, attribute, value
from wrr$_replay_filter_set rfs
where NOT EXISTS 
  (SELECT 1
   FROM   WRR$_REPLAYS r
   WHERE  r.filter_set_name = rfs.set_name
   AND    r.capture_id = rfs.capture_id)
/

create or replace view dba_workload_replay_filter_set
(CAPTURE_ID,
 SET_NAME,
 FILTER_NAME, ATTRIBUTE, VALUE,
 DEFAULT_ACTION)
as
select capture_id, set_name, filter_name, attribute, value, default_action
from wrr$_replay_filter_set rfs
UNION ALL
select NULL, NULL, name, attribute, value, NULL
from wrr$_filters
where wrr_id = 0
and   filter_type = 'REPLAY'
/

create or replace public synonym dba_workload_filters
   for sys.dba_workload_filters;
grant select on dba_workload_filters to select_catalog_role;


Rem =========================================================
Rem Creating the Workload Capture Views
Rem =========================================================
Rem

create or replace view dba_workload_captures
(ID, NAME, 
 DBID, DBNAME, DBVERSION,
 PARALLEL,
 DIRECTORY,
 STATUS,
 START_TIME, END_TIME, 
 DURATION_SECS,
 START_SCN, END_SCN,
 DEFAULT_ACTION, FILTERS_USED,
 CAPTURE_SIZE, 
 DBTIME, DBTIME_TOTAL,
 USER_CALLS, USER_CALLS_TOTAL, USER_CALLS_UNREPLAYABLE,
 TRANSACTIONS, TRANSACTIONS_TOTAL,
 CONNECTS, CONNECTS_TOTAL,
 ERRORS, 
 AWR_DBID, AWR_BEGIN_SNAP, AWR_END_SNAP, 
 AWR_EXPORTED,
 ERROR_CODE, ERROR_MESSAGE,
 DIR_PATH,
 DIR_PATH_SHARED,
 LAST_PROCESSED_VERSION,
 SQLSET_OWNER,
 SQLSET_NAME)
as
select 
 r.id, r.name
 , r.dbid, r.dbname, r.dbversion
 , (case when rs.parallel > 0 then 'YES' else 'NO' end)
 , r.directory
 , r.status
 , r.start_time, r.end_time
 , round((r.end_time - r.start_time) * 86400)
 , r.start_scn, r.end_scn
 , r.default_action, nvl(f.cnt,0)
 , rs.capture_size
 , rs.dbtime, greatest(rs.dbtime_total, rs.dbtime)
 , rs.user_calls, greatest(rs.user_calls_total, rs.user_calls)
 , rs.user_calls_empty
 , rs.txns, greatest(rs.txns_total, rs.txns)
 , rs.connects, greatest(rs.connects_total, rs.connects)
 , rs.errors
 , r.awr_dbid, r.awr_begin_snap, r.awr_end_snap
 , decode(r.awr_exported, 1, 'YES', 0, 'NO', 'NOT POSSIBLE')
 , r.error_code, r.error_msg
 , r.dir_path
 , r.dir_path_shared
 , r.last_prep_version
 , r.sqlset_owner
 , r.sqlset_name
from
 wrr$_captures r
 , (select wrr_id, count(*) as cnt
    from   wrr$_filters
    where  filter_type = 'CAPTURE'
    group  by wrr_id) f
 , (select id, 
           sum(decode(parallel,'YES',1,0)) as parallel,
           sum(capture_size) as capture_size,
           sum(dbtime) as dbtime,
           sum(dbtime_tend - dbtime_tstart) as dbtime_total,
           sum(user_calls) as user_calls, 
           sum(user_calls_tend - user_calls_tstart) as user_calls_total,
           sum(user_calls_empty) as user_calls_empty, 
           sum(txns) as txns, 
           sum(txns_tend - txns_tstart) as txns_total,
           sum(connects) as connects, 
           sum(connects_tend - connects_tstart) as connects_total, 
           sum(errors) as errors
    from   wrr$_capture_stats
    group by id) rs
where r.id = f.wrr_id(+)
  and r.id = rs.id(+)
/

create or replace public synonym  dba_workload_captures
   for sys.dba_workload_captures;
grant select on dba_workload_captures to select_catalog_role;
