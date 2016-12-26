Rem
Rem $Header: catawrpd.sql4112 09-nov-2006.15:42:21 ilistvin Exp $
Rem
Rem catawrpd.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catawrpd.sql - AWR views with Package Dependencies
Rem
Rem    DESCRIPTION
Rem     AWR views that are defined using packages 
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ilistvin    11/09/06 - AWR views with package dependencies
Rem    ilistvin    11/09/06 - Created
Rem


/***************************************
 *        DBA_HIST_BASELINE
 ***************************************/

create or replace view DBA_HIST_BASELINE
  (dbid, baseline_id, baseline_name, baseline_type,
   start_snap_id, start_snap_time,
   end_snap_id, end_snap_time, moving_window_size, creation_time,
   expiration, template_name, last_time_computed)
as
select bl.dbid, bl.baseline_id, 
       bl.baseline_name, max(bl.baseline_type),
       min(bst.start_snap_id), min(bst.start_snap_time),
       max(bst.end_snap_id),   max(bst.end_snap_time),
       max(bl.moving_window_size), max(bl.creation_time),
       max(bl.expiration), max(bl.template_name),
       max(bl.last_time_computed)
from
  WRM$_BASELINE bl, WRM$_BASELINE_DETAILS bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id != 0 and
  bl.baseline_id = bst.baseline_id
group by bl.dbid, bl.baseline_id, baseline_name
union all
select bl.dbid, bl.baseline_id, 
       bl.baseline_name, max(bl.baseline_type),
       min(bst.start_snap_id), min(bst.start_snap_time),
       max(bst.end_snap_id),   max(bst.end_snap_time),
       max(bl.moving_window_size), max(bl.creation_time),
       max(bl.expiration), max(bl.template_name),
       max(bl.last_time_computed)
from
  WRM$_BASELINE bl,  /* Note: moving window stats only for local dbid */
  table(dbms_workload_repository.select_baseline_details(bl.baseline_id)) bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id = 0 and
  bl.baseline_id = bst.baseline_id
group by bl.dbid, bl.baseline_id, baseline_name
/
comment on table DBA_HIST_BASELINE is
'Baseline Metadata Information'
/
create or replace public synonym DBA_HIST_BASELINE 
    for DBA_HIST_BASELINE
/
grant select on DBA_HIST_BASELINE to SELECT_CATALOG_ROLE
/

/***************************************
 *     DBA_HIST_BASELINE_DETAILS
 ***************************************/

create or replace view DBA_HIST_BASELINE_DETAILS
  (dbid, instance_number, 
   baseline_id, baseline_name, baseline_type,
   start_snap_id, start_snap_time, 
   end_snap_id, end_snap_time,
   shutdown, error_count, pct_total_time, 
   last_time_computed,
   moving_window_size, creation_time, 
   expiration, template_name)
as
select bl.dbid, bst.instance_number,
       bl.baseline_id, bl.baseline_name, bl.baseline_type,
       bst.start_snap_id, bst.start_snap_time,
       bst.end_snap_id,   bst.end_snap_time,
       bst.shutdown, bst.error_count, bst.pct_total_time,
       bl.last_time_computed,
       bl.moving_window_size, bl.creation_time,
       bl.expiration, bl.template_name
from
  WRM$_BASELINE bl, WRM$_BASELINE_DETAILS bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id != 0 and
  bl.baseline_id = bst.baseline_id
union all
select bl.dbid, bst.instance_number,
       bl.baseline_id, bl.baseline_name, bl.baseline_type,
       bst.start_snap_id, bst.start_snap_time,
       bst.end_snap_id,   bst.end_snap_time,
       bst.shutdown, bst.error_count, bst.pct_total_time,
       bl.last_time_computed,
       bl.moving_window_size, bl.creation_time,
       bl.expiration, bl.template_name
from
  WRM$_BASELINE bl,  /* Note: moving window stats only for local dbid */
  table(dbms_workload_repository.select_baseline_details(bl.baseline_id)) bst
where
  bl.dbid = bst.dbid and
  bl.baseline_id = 0 and
  bl.baseline_id = bst.baseline_id
/
comment on table DBA_HIST_BASELINE_DETAILS is
'Baseline Stats on per Instance Level'
/
create or replace public synonym DBA_HIST_BASELINE_DETAILS
    for DBA_HIST_BASELINE_DETAILS
/
grant select on DBA_HIST_BASELINE_DETAILS to SELECT_CATALOG_ROLE
/

/***************************************
 *     DBA_HIST_SQLBIND
 ***************************************/

create or replace view DBA_HIST_SQLBIND
   (SNAP_ID, DBID, INSTANCE_NUMBER, 
    SQL_ID, NAME, POSITION, DUP_POSITION, DATATYPE, DATATYPE_STRING,
    CHARACTER_SID, PRECISION, SCALE, MAX_LENGTH, WAS_CAPTURED,
    LAST_CAPTURED, VALUE_STRING, VALUE_ANYDATA)
as 
select snap_id                                                 snap_id,
       dbid                                                    dbid,
       instance_number                                         instance_number,
       sql_id                                                  sql_id,
       name                                                    name, 
       position                                                position, 
       nvl2(cap_bv, v.cap_bv.dup_position, dup_position)       dup_position,
       nvl2(cap_bv, v.cap_bv.datatype, datatype)               datatype,
       nvl2(cap_bv, v.cap_bv.datatype_string, datatype_string) datatype_string,
       nvl2(cap_bv, v.cap_bv.character_sid, character_sid)     character_sid,
       nvl2(cap_bv, v.cap_bv.precision, precision)             precision,
       nvl2(cap_bv, v.cap_bv.scale, scale)                     scale,
       nvl2(cap_bv, v.cap_bv.max_length, max_length)           max_length,
       nvl2(cap_bv, 'YES', 'NO')                               was_captured,
       nvl2(cap_bv, v.cap_bv.last_captured, NULL)              last_captured,
       nvl2(cap_bv, v.cap_bv.value_string, NULL)               value_string,
       nvl2(cap_bv, v.cap_bv.value_anydata, NULL)              value_anydata
from
(select sql.snap_id, sql.dbid, sql.instance_number, sbm.sql_id,
        dbms_sqltune.extract_bind(sql.bind_data, sbm.position) cap_bv,
        sbm.name,
        sbm.position,
        sbm.dup_position,
        sbm.datatype,
        sbm.datatype_string,
        sbm.character_sid,
        sbm.precision,
        sbm.scale,
        sbm.max_length
 from   wrm$_snapshot sn, wrh$_sql_bind_metadata sbm, wrh$_sqlstat sql
 where      sn.snap_id         = sql.snap_id
        and sn.dbid            = sql.dbid
        and sn.instance_number = sql.instance_number
        and sbm.sql_id         = sql.sql_id
        and sn.status          = 0) v
/
comment on table DBA_HIST_SQLBIND is
'SQL Bind Information'
/
create or replace public synonym DBA_HIST_SQLBIND for DBA_HIST_SQLBIND
/
grant select on DBA_HIST_SQLBIND to SELECT_CATALOG_ROLE
/

