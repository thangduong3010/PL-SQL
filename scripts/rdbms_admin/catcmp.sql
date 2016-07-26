Rem
Rem $Header: rdbms/admin/catcmp.sql /st_rdbms_11.2.0/1 2011/04/25 15:10:19 yurxu Exp $
Rem
Rem catcmp.sql
Rem
Rem Copyright (c) 2006, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catcmp.sql - data CoMParison catalog views
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      dba_comparison
Rem      dba_comparison_columns
Rem      dba_comparison_scan
Rem      dba_comparison_scan_summary
Rem      dba_comparison_scan_values
Rem      dba_comparison_row_dif
Rem
Rem      user_comparison
Rem      user_comparison_columns
Rem      user_comparison_scan
Rem      user_comparison_scan_summary
Rem      user_comparison_scan_values
Rem      user_comparison_row_dif
Rem
Rem      "_DBA_COMPARISON_SCAN"
Rem      "_USER_COMPARISON_ROW_DIF"
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yurxu       04/12/11 - Backport yurxu_bug-11922716 from main
Rem    rmao        09/02/08 - redefinition of dba_comparison_scan_summary view
Rem    juyuan      11/28/06 - bug-5683618
Rem    jinwu       11/03/06 - Created
Rem


----------------------------------------------------------------------------
-- DBA_COMPARISON
----------------------------------------------------------------------------
CREATE OR REPLACE VIEW dba_comparison 
  (owner, comparison_name, comparison_mode, 
   schema_name, object_name, object_type,
   remote_schema_name, remote_object_name, remote_object_type, dblink_name,
   scan_mode, scan_percent, 
   cyclic_index_value, null_value, local_converge_tag, remote_converge_tag,
   max_num_buckets, min_rows_in_bucket, last_update_time)
AS 
SELECT 
  u.name,
  comparison_name, 
  decode(comparison_mode, 1, 'TABLE') comparison_mode,
  schema_name, object_name, 
  decode(object_type, 2, 'TABLE', 4, 'VIEW', 5, 'SYNONYM', 
         42, 'MATERIALIZED VIEW', 
         'UNDEFINED') object_type,
  rmt_schema_name, rmt_object_name, 
  decode(rmt_object_type, 2, 'TABLE', 4, 'VIEW', 5, 'SYNONYM', 
         42, 'MATERIALIZED VIEW', 
         'UNDEFINED') remote_object_type,
  dblink_name,
  decode(scan_mode, 1, 'FULL', 2, 'RANDOM', 3, 'CYCLIC', 4, 'CUSTOM', 
         'UNDEFINED') scan_mode,
  scan_percent,
  cyl_idx_val cyclic_index_value,
  null_value, 
  loc_converge_tag,
  rmt_converge_tag,
  max_num_buckets,
  min_rows_in_bucket,
  last_update_time
FROM comparison$ c, user$ u
where c.user# = u.user#
/
comment on table DBA_COMPARISON is
'Details about the comparison object'
/
comment on column DBA_COMPARISON.OWNER is
'Owner of comparison'
/
comment on column DBA_COMPARISON.COMPARISON_NAME is
'Name of comparison'
/
comment on column DBA_COMPARISON.COMPARISON_MODE is
'Mode of comparison: TABLE'
/
comment on column DBA_COMPARISON.SCHEMA_NAME is
'Schema name of local object'
/
comment on column DBA_COMPARISON.OBJECT_NAME  is
'Name of local object'
/
comment on column DBA_COMPARISON.OBJECT_TYPE  is
'Type of local object'
/
comment on column DBA_COMPARISON.REMOTE_SCHEMA_NAME is
'Schema name of remote object'
/
comment on column DBA_COMPARISON.REMOTE_OBJECT_NAME  is
'Name of remote object'
/
comment on column DBA_COMPARISON.REMOTE_OBJECT_TYPE  is
'Type of remote object'
/
comment on column DBA_COMPARISON.DBLINK_NAME is
'Database link name to remote database'
/
comment on column DBA_COMPARISON.SCAN_MODE is
'Scan mode of comparison: FULL'
/
comment on column DBA_COMPARISON.SCAN_PERCENT is
'Scan percent of comparison: Applicable to Random and Cyclic modes'
/
comment on column DBA_COMPARISON.CYCLIC_INDEX_VALUE is
'Last index column value used in a cyclic scan'
/
comment on column DBA_COMPARISON.NULL_VALUE is
'Value to use for null column values'
/
comment on column DBA_COMPARISON.LOCAL_CONVERGE_TAG is
'The local streams tag used while performing converge dmls'
/
comment on column DBA_COMPARISON.REMOTE_CONVERGE_TAG is
'The remote streams tag used while performing converge dmls'
/
comment on column DBA_COMPARISON.MAX_NUM_BUCKETS is
'Suggested maximum number of buckets in a scan'
/
comment on column DBA_COMPARISON.MIN_ROWS_IN_BUCKET is
'Suggested minimum number of rows in a bucket'
/
comment on column DBA_COMPARISON.LAST_UPDATE_TIME is
'The time that this row was updated'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_comparison
  FOR dba_comparison
/
GRANT SELECT ON dba_comparison TO select_catalog_role
/

----------------------------------------------------------------------------
-- USER_COMPARISON
----------------------------------------------------------------------------

CREATE OR REPLACE VIEW user_comparison AS 
SELECT comparison_name, comparison_mode, 
   schema_name, object_name, object_type,
   remote_schema_name, remote_object_name, remote_object_type, dblink_name,
   scan_mode, scan_percent, 
   cyclic_index_value, null_value, local_converge_tag, remote_converge_tag,
   max_num_buckets, min_rows_in_bucket, last_update_time
FROM dba_comparison
WHERE owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_COMPARISON is
'Details about the user''s comparison objects'
/
comment on column USER_COMPARISON.COMPARISON_NAME is
'Name of comparison'
/
comment on column USER_COMPARISON.COMPARISON_MODE is
'Mode of comparison: TABLE'
/
comment on column USER_COMPARISON.SCHEMA_NAME is
'Schema name of local object'
/
comment on column USER_COMPARISON.OBJECT_NAME  is
'Name of local object'
/
comment on column USER_COMPARISON.OBJECT_TYPE  is
'Type of local object'
/
comment on column USER_COMPARISON.REMOTE_SCHEMA_NAME is
'Schema name of remote object'
/
comment on column USER_COMPARISON.REMOTE_OBJECT_NAME  is
'Name of remote object'
/
comment on column USER_COMPARISON.REMOTE_OBJECT_TYPE  is
'Type of remote object'
/
comment on column USER_COMPARISON.DBLINK_NAME is
'Database link name to remote database'
/
comment on column USER_COMPARISON.SCAN_MODE is
'Scan mode of comparison: FULL'
/
comment on column USER_COMPARISON.SCAN_PERCENT is
'Scan percent of comparison: Applicable to Random and Cyclic modes'
/
comment on column USER_COMPARISON.CYCLIC_INDEX_VALUE is
'Last index column value used in a cyclic scan'
/
comment on column USER_COMPARISON.NULL_VALUE is
'Value to use for null column values'
/
comment on column USER_COMPARISON.LOCAL_CONVERGE_TAG is
'The local streams tag used while performing converge dmls'
/
comment on column USER_COMPARISON.REMOTE_CONVERGE_TAG is
'The remote streams tag used while performing converge dmls'
/
comment on column USER_COMPARISON.MAX_NUM_BUCKETS is
'Suggested number of buckets in a scan'
/
comment on column USER_COMPARISON.MIN_ROWS_IN_BUCKET is
'Suggested number of rows in a bucket'
/
comment on column USER_COMPARISON.LAST_UPDATE_TIME is
'The time that this row was updated'
/

CREATE OR REPLACE PUBLIC SYNONYM user_comparison
  FOR user_comparison
/
GRANT SELECT ON user_comparison TO public with GRANT OPTION
/


----------------------------------------------------------------------------
-- DBA_COMPARISON_COLUMNS
----------------------------------------------------------------------------
CREATE OR REPLACE VIEW dba_comparison_columns
  (owner, comparison_name, column_position, column_name, index_column) 
AS 
SELECT 
  u.name,
  c.comparison_name, 
  cc.col_position,
  cc.col_name, 
  decode(bitand(cc.flags, 1), 1, 'Y', 'N') index_column
FROM comparison_col$ cc, comparison$ c, user$ u
WHERE 
    cc.comparison_id = c.comparison_id
AND c.user# = u.user#
/
comment on table DBA_COMPARISON_COLUMNS is
'Details about the comparison object''s columns'
/
comment on column DBA_COMPARISON_COLUMNS.OWNER is
'Owner of comparison'
/
comment on column DBA_COMPARISON_COLUMNS.COMPARISON_NAME is
'Name of comparison'
/
comment on column DBA_COMPARISON_COLUMNS.COLUMN_POSITION is
'Column position'
/
comment on column DBA_COMPARISON_COLUMNS.COLUMN_NAME is
'Name of column'
/
comment on column DBA_COMPARISON_COLUMNS.INDEX_COLUMN  is
'Whether the column is an index column'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_comparison_columns
  FOR dba_comparison_columns
/
GRANT SELECT ON dba_comparison_columns TO select_catalog_role
/


----------------------------------------------------------------------------
-- USER_COMPARISON_COLUMNS
----------------------------------------------------------------------------
CREATE OR REPLACE VIEW user_comparison_columns
  (comparison_name, column_position, column_name, index_column) 
AS 
SELECT comparison_name, column_position, column_name, index_column
FROM dba_comparison_columns
WHERE owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_COMPARISON_COLUMNS is
'Details about the comparison object''s columns'
/
comment on column USER_COMPARISON_COLUMNS.COMPARISON_NAME is
'Name of comparison'
/
comment on column USER_COMPARISON_COLUMNS.COLUMN_POSITION is
'Column position'
/
comment on column USER_COMPARISON_COLUMNS.COLUMN_NAME is
'Name of column'
/
comment on column DBA_COMPARISON_COLUMNS.INDEX_COLUMN  is
'Whether the column is an index column'
/

CREATE OR REPLACE PUBLIC SYNONYM user_comparison_columns
  FOR user_comparison_columns
/
GRANT SELECT ON user_comparison_columns TO public with GRANT OPTION
/

----------------------------------------------------------------------------
-- DBA_COMPARISON_SCAN
----------------------------------------------------------------------------

-- a helper view
CREATE OR REPLACE VIEW "_DBA_COMPARISON_SCAN"
(
  comparison_id, owner, comparison_name, scan_id, parent_scan_id, status, 
  current_dif_count, initial_dif_count, root_scan_id,
  count_rows, scan_nulls, last_update_time
)
AS 
SELECT
  r.comparison_id              comparison_id,
  u.name                       owner,
  r.comparison_name            comparison_name, 
  s.scan_id                    scan_id, 
  s.parent_scan_id             parent_scan_id,
  s.status                     status,
  s.spare1                     current_dif_count,
  s.spare2                     initial_dif_count,
  s.spare3                     root_scan_id,
  s.num_rows                   count_rows, 
  decode(bitand(s.flags, 1), 1, 'Y', 'N') scan_nulls,
  s.last_update_time           last_update_time
FROM comparison_scan$ s, comparison$ r, user$ u
WHERE 
    s.comparison_id = r.comparison_id
AND r.user# = u.user# 
/

CREATE OR REPLACE VIEW dba_comparison_scan
(
  owner, comparison_name, scan_id, parent_scan_id, root_scan_id, status,
  current_dif_count, initial_dif_count, count_rows, 
  scan_nulls, last_update_time
)
AS 
SELECT owner, comparison_name, scan_id, parent_scan_id, root_scan_id,
       decode(status, 1, 'SUC', 
                      2, 'BUCKET DIF',
                      3, 'FINAL BUCKET DIF', 
                      4, 'ROW DIF'),
       current_dif_count, initial_dif_count,
       count_rows, scan_nulls, last_update_time
FROM "_DBA_COMPARISON_SCAN"
/
comment on table DBA_COMPARISON_SCAN is
'Details about a comparison scan'
/
comment on column DBA_COMPARISON_SCAN.OWNER is
'Owner of comparison'
/
comment on column DBA_COMPARISON_SCAN.COMPARISON_NAME is
'Name of comparison'
/
comment on column DBA_COMPARISON_SCAN.SCAN_ID is
'Scan id of scan'
/
comment on column DBA_COMPARISON_SCAN.PARENT_SCAN_ID is
'Immediate parent scan''s scan id'
/
comment on column DBA_COMPARISON_SCAN.ROOT_SCAN_ID is
'Scan_id of the root (top-most) parent'
/
comment on column DBA_COMPARISON_SCAN.STATUS is
'Status of scan: SUC, BUCKET DIF, FINAL BUCKET DIF, ROW DIF'
/
comment on column DBA_COMPARISON_SCAN.CURRENT_DIF_COUNT is
'Current cumulative (incl children) dif count of scan'
/
comment on column DBA_COMPARISON_SCAN.INITIAL_DIF_COUNT is
'Initial cumulative (incl children) dif count of scan'
/
comment on column DBA_COMPARISON_SCAN.COUNT_ROWS is
'Number of rows in the scan'
/
comment on column DBA_COMPARISON_SCAN.SCAN_NULLS is
'Whether NULLs are part of this scan'
/
comment on column DBA_COMPARISON_SCAN.LAST_UPDATE_TIME is
'The time that this row was updated'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_comparison_scan
  FOR dba_comparison_scan
/
GRANT SELECT ON dba_comparison_scan TO select_catalog_role
/

----------------------------------------------------------------------------
-- DBA_COMPARISON_SCAN_SUMMARY
----------------------------------------------------------------------------
CREATE OR REPLACE VIEW dba_comparison_scan_summary
(
  owner, comparison_name, scan_id, parent_scan_id, root_scan_id, status, 
  current_dif_count, initial_dif_count, count_rows, 
  scan_nulls, last_update_time
)
AS 
SELECT
  u.name                       owner,
  r.comparison_name            comparison_name, 
  s.scan_id                    scan_id, 
  s.parent_scan_id             parent_scan_id,
  s.spare3                     root_scan_id,
  decode(s.status, 1, 'SUC', 
                   2, 'BUCKET DIF',
                   3, 'FINAL BUCKET DIF', 
                   4, 'ROW DIF') status,
  s.spare1                     current_dif_count,
  s.spare2                     initial_dif_count,
  s.num_rows                   count_rows, 
  decode(bitand(s.flags, 1), 1, 'Y', 'N') scan_nulls,
  s.last_update_time           last_update_time
FROM comparison_scan$ s, comparison$ r, user$ u
WHERE 
    s.comparison_id = r.comparison_id
AND r.user# = u.user#
/

comment on table DBA_COMPARISON_SCAN_SUMMARY is
'Details about a comparison scan'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.OWNER is
'Owner of comparison'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.COMPARISON_NAME is
'Name of comparison'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.SCAN_ID is
'Scan id of scan'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.PARENT_SCAN_ID is
'Immediate parent scan''s scan id'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.ROOT_SCAN_ID is
'Scan_id of the root (top-most) parent'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.STATUS is
'Status of scan: SUC, BUCKET DIF, FINAL BUCKET DIF, ROW DIF'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.CURRENT_DIF_COUNT is
'Current cumulative (incl children) dif count of scan'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.INITIAL_DIF_COUNT is
'Initial cumulative (incl children) dif count of scan'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.COUNT_ROWS is
'Number of rows in the scan'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.SCAN_NULLS is
'Whether NULLs are part of this scan'
/
comment on column DBA_COMPARISON_SCAN_SUMMARY.LAST_UPDATE_TIME is
'The time that this row was updated'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_comparison_scan_summary
  FOR dba_comparison_scan_summary
/
GRANT SELECT ON dba_comparison_scan_summary TO select_catalog_role
/

----------------------------------------------------------------------------
-- ALL_COMPARISON_SCAN_SUMMARY
----------------------------------------------------------------------------
CREATE OR REPLACE VIEW all_comparison_scan_summary AS 
SELECT css.*
FROM dba_comparison_scan_summary css, ALL_APPLY aa, ALL_CAPTURE ca
  where (aa.apply_user = css.owner) or (ca.capture_user = css.owner)
/

comment on table ALL_COMPARISON_SCAN_SUMMARY is
'Details about a comparison scan for the user'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.OWNER is
'Owner of comparison'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.COMPARISON_NAME is
'Name of comparison'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.SCAN_ID is
'Scan id of scan'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.PARENT_SCAN_ID is
'Immediate parent scan''s scan id'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.ROOT_SCAN_ID is
'Scan_id of the root (top-most) parent'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.STATUS is
'Status of scan: SUC, BUCKET DIF, FINAL BUCKET DIF, ROW DIF'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.CURRENT_DIF_COUNT is
'Current cumulative (incl children) dif count of scan'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.INITIAL_DIF_COUNT is
'Initial cumulative (incl children) dif count of scan'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.COUNT_ROWS is
'Number of rows in the scan'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.SCAN_NULLS is
'Whether NULLs are part of this scan'
/
comment on column ALL_COMPARISON_SCAN_SUMMARY.LAST_UPDATE_TIME is
'The time that this row was updated'
/
CREATE OR REPLACE PUBLIC SYNONYM all_comparison_scan_summary
  FOR all_comparison_scan_summary
/
GRANT SELECT ON all_comparison_scan_summary TO select_catalog_role
/

----------------------------------------------------------------------------
-- USER_COMPARISON_SCAN
----------------------------------------------------------------------------
CREATE OR REPLACE VIEW user_comparison_scan
(
  comparison_name, scan_id, parent_scan_id, root_scan_id, status, 
  current_dif_count, initial_dif_count, count_rows, 
  scan_nulls, last_update_time
)
AS SELECT comparison_name, scan_id, parent_scan_id, root_scan_id, status,
          current_dif_count, initial_dif_count, count_rows,
          scan_nulls, last_update_time
FROM dba_comparison_scan
WHERE owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_COMPARISON_SCAN is
'Details about a comparison scan'
/
comment on column USER_COMPARISON_SCAN.COMPARISON_NAME is
'Name of comparison'
/
comment on column USER_COMPARISON_SCAN.SCAN_ID is
'Scan id of scan'
/
comment on column USER_COMPARISON_SCAN.PARENT_SCAN_ID is
'Immediate parent scan''s scan id'
/
comment on column USER_COMPARISON_SCAN.ROOT_SCAN_ID is
'Scan_id of the root (top-most) parent'
/
comment on column USER_COMPARISON_SCAN.STATUS is
'Status of scan: SUC, BUCKET DIF, FINAL BUCKET DIF, ROW DIF'
/
comment on column USER_COMPARISON_SCAN.CURRENT_DIF_COUNT is
'Current cumulative (incl children) dif count of scan'
/
comment on column USER_COMPARISON_SCAN.INITIAL_DIF_COUNT is
'Initial cumulative (incl children) dif count of scan'
/
comment on column USER_COMPARISON_SCAN.COUNT_ROWS is
'Number of rows in the scan'
/
comment on column USER_COMPARISON_SCAN.SCAN_NULLS is
'Whether NULLs are part of this scan'
/
comment on column USER_COMPARISON_SCAN.LAST_UPDATE_TIME is
'The time that this row was updated'
/

CREATE OR REPLACE PUBLIC SYNONYM user_comparison_scan
  FOR user_comparison_scan
/
GRANT SELECT ON user_comparison_scan TO public with GRANT OPTION
/


----------------------------------------------------------------------------
-- USER_COMPARISON_SCAN_SUMMARY
----------------------------------------------------------------------------


CREATE OR REPLACE VIEW user_comparison_scan_summary
(
  comparison_name, scan_id, parent_scan_id, root_scan_id, status, 
  current_dif_count, initial_dif_count, count_rows, 
  scan_nulls, last_update_time
)
AS SELECT comparison_name, scan_id, parent_scan_id, root_scan_id, status, 
  current_dif_count, initial_dif_count, count_rows, 
  scan_nulls, last_update_time
FROM dba_comparison_scan_summary
WHERE owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_COMPARISON_SCAN_SUMMARY is
'Details about a comparison scan'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.COMPARISON_NAME is
'Name of comparison'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.SCAN_ID is
'Scan id of scan'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.PARENT_SCAN_ID is
'Immediate parent scan''s scan id'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.ROOT_SCAN_ID is
'Scan_id of the root (top-most) parent'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.STATUS is
'Status of scan: SUC, BUCKET DIF, FINAL BUCKET DIF, ROW DIF'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.CURRENT_DIF_COUNT is
'Current cumulative (incl children) dif count of scan'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.INITIAL_DIF_COUNT is
'Initial cumulative (incl children) dif count of scan'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.COUNT_ROWS is
'Number of rows in the scan'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.SCAN_NULLS is
'Whether NULLs are part of this scan'
/
comment on column USER_COMPARISON_SCAN_SUMMARY.LAST_UPDATE_TIME is
'The time that this row was updated'
/

CREATE OR REPLACE PUBLIC SYNONYM user_comparison_scan_summary
  FOR user_comparison_scan_summary
/
GRANT SELECT ON user_comparison_scan_summary TO public with GRANT OPTION
/


----------------------------------------------------------------------------
-- DBA_COMPARISON_SCAN_VALUES
----------------------------------------------------------------------------
CREATE OR REPLACE VIEW dba_comparison_scan_values
(
  owner, comparison_name, scan_id, column_position, 
  min_value, max_value, last_update_time
)
AS 
SELECT 
  u.name              owner,
  r.comparison_name   comparison_name, 
  v.scan_id           scan_id, 
  v.column_position   column_position,
  v.min_val           min_value, 
  v.max_val           max_value, 
  v.last_update_time
FROM 
  comparison$ r, user$ u, comparison_scan_val$ v
WHERE
    v.comparison_id = r.comparison_id
AND r.user# = u.user#
/
comment on table DBA_COMPARISON_SCAN_VALUES is
'Details about a comparison scan''s values'
/
comment on column DBA_COMPARISON_SCAN_VALUES.OWNER is
'Owner of comparison'
/
comment on column DBA_COMPARISON_SCAN_VALUES.COMPARISON_NAME is
'Name of comparison'
/
comment on column DBA_COMPARISON_SCAN_VALUES.SCAN_ID is
'Scan id of scan'
/
comment on column DBA_COMPARISON_SCAN_VALUES.COLUMN_POSITION is
'Column position as in dba_comparison_columns'
/
comment on column DBA_COMPARISON_SCAN_VALUES.MIN_VALUE is
'Minimum value of scan'
/
comment on column DBA_COMPARISON_SCAN_VALUES.MAX_VALUE is
'Maximum value of scan'
/
comment on column DBA_COMPARISON_SCAN_VALUES.LAST_UPDATE_TIME is
'The time that this row was updated'
/


CREATE OR REPLACE PUBLIC SYNONYM dba_comparison_scan_values
  FOR dba_comparison_scan_values
/
GRANT SELECT ON dba_comparison_scan_values TO select_catalog_role
/

----------------------------------------------------------------------------
-- USER_COMPARISON_SCAN_VALUES
----------------------------------------------------------------------------
CREATE OR REPLACE VIEW user_comparison_scan_values
(
  comparison_name, scan_id, column_position, 
  min_value, max_value, last_update_time
)
AS SELECT comparison_name, scan_id, column_position, 
          min_value, max_value, last_update_time
FROM dba_comparison_scan_values
WHERE owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_COMPARISON_SCAN_VALUES is
'Details about a comparison scan''s values'
/
comment on column USER_COMPARISON_SCAN_VALUES.COMPARISON_NAME is
'Name of comparison'
/
comment on column USER_COMPARISON_SCAN_VALUES.SCAN_ID is
'Scan id of scan'
/
comment on column USER_COMPARISON_SCAN_VALUES.COLUMN_POSITION is
'Column position as in user_comparison_columns'
/
comment on column USER_COMPARISON_SCAN_VALUES.MIN_VALUE is
'Minimum value of scan'
/
comment on column USER_COMPARISON_SCAN_VALUES.MAX_VALUE is
'Maximum value of scan'
/
comment on column USER_COMPARISON_SCAN_VALUES.LAST_UPDATE_TIME is
'The time that this row was updated'
/


CREATE OR REPLACE PUBLIC SYNONYM user_comparison_scan_values
  FOR user_comparison_scan_values
/
GRANT SELECT ON user_comparison_scan_values TO public with GRANT OPTION
/

----------------------------------------------------------------------------
-- DBA_COMPARISON_ROW_DIF
----------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_comparison_row_dif
  (owner, comparison_name, scan_id, local_rowid, remote_rowid, index_value, 
   status, last_update_time) AS
SELECT 
  u.name, r.comparison_name, d.scan_id, d.loc_rowid, d.rmt_rowid, d.idx_val, 
  decode(d.status, 1, 'SUC', 2, 'DIF') status,
  d.last_update_time
FROM comparison_row_dif$ d, comparison$ r, user$ u
WHERE d.comparison_id = r.comparison_id
AND   r.user# = u.user#
/
comment on table DBA_COMPARISON_ROW_DIF is
'Details about the differing rows in a comparison scan'
/
comment on column DBA_COMPARISON_ROW_DIF.OWNER is
'Owner of comparison'
/
comment on column DBA_COMPARISON_ROW_DIF.COMPARISON_NAME is
'Name of comparison'
/
comment on column DBA_COMPARISON_ROW_DIF.SCAN_ID is
'Scan id of scan'
/
comment on column DBA_COMPARISON_ROW_DIF.LOCAL_ROWID is
'Local rowid of differing row'
/
comment on column DBA_COMPARISON_ROW_DIF.REMOTE_ROWID is
'Remote rowid of differing row'
/
comment on column DBA_COMPARISON_ROW_DIF.INDEX_VALUE is
'Index column value of differing row'
/
comment on column DBA_COMPARISON_ROW_DIF.STATUS is
'Status of differing row: SUC or DIF'
/
comment on column DBA_COMPARISON_ROW_DIF.LAST_UPDATE_TIME is
'The time that this row was updated'
/


CREATE OR REPLACE PUBLIC SYNONYM dba_comparison_row_dif
  FOR dba_comparison_row_dif
/
GRANT SELECT ON dba_comparison_row_dif TO select_catalog_role
/


----------------------------------------------------------------------------
-- USER_COMPARISON_ROW_DIF
----------------------------------------------------------------------------

CREATE OR REPLACE VIEW user_comparison_row_dif
  (comparison_name, scan_id, local_rowid, remote_rowid, index_value, 
   status, last_update_time) AS
SELECT 
  comparison_name, scan_id, local_rowid, remote_rowid, index_value, 
  status, last_update_time
FROM dba_comparison_row_dif
WHERE owner = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_COMPARISON_ROW_DIF is
'Details about the differing rows in a comparison scan'
/
comment on column USER_COMPARISON_ROW_DIF.COMPARISON_NAME is
'Name of comparison'
/
comment on column USER_COMPARISON_ROW_DIF.SCAN_ID is
'Scan id of scan'
/
comment on column USER_COMPARISON_ROW_DIF.LOCAL_ROWID is
'Local rowid of differing row'
/
comment on column USER_COMPARISON_ROW_DIF.REMOTE_ROWID is
'Remote rowid of differing row'
/
comment on column USER_COMPARISON_ROW_DIF.INDEX_VALUE is
'Index column value of differing row'
/
comment on column USER_COMPARISON_ROW_DIF.STATUS is
'Status of differing row: SUC or DIF'
/
comment on column USER_COMPARISON_ROW_DIF.LAST_UPDATE_TIME is
'The time that this row was updated'
/

CREATE OR REPLACE PUBLIC SYNONYM user_comparison_row_dif
  FOR user_comparison_row_dif
/
GRANT SELECT ON user_comparison_row_dif TO public with GRANT OPTION
/

----------------------------------------------------------------------------
-- _USER_COMPARISON_ROW_DIF
-- This is used by comparison code, and not intended for the user.
----------------------------------------------------------------------------

CREATE OR REPLACE VIEW "_USER_COMPARISON_ROW_DIF" AS 
SELECT d.* FROM comparison_row_dif$ d, comparison$ c
WHERE d.comparison_id = c.comparison_id
AND user# = uid;

CREATE OR REPLACE PUBLIC SYNONYM "_USER_COMPARISON_ROW_DIF"
  FOR "_USER_COMPARISON_ROW_DIF"
/

GRANT SELECT ON "_USER_COMPARISON_ROW_DIF" TO public with GRANT OPTION
/
