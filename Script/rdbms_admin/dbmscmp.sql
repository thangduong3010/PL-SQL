Rem
Rem $Header: dbmscmp.sql 15-nov-2006.10:29:44 juyuan Exp $
Rem
Rem dbmscmp.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmscmp.sql - package for data CoMParison
Rem
Rem    DESCRIPTION
Rem      Package for data comparison
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    juyuan      11/15/06 - bug-5646059: add parameters index_schema_name
Rem                           and index_name for create_comparison
Rem    rvenkate    01/26/06 - Created
Rem

--
-- External package for comparison administration
--
CREATE OR REPLACE PACKAGE dbms_comparison AUTHID CURRENT_USER AS


/****************************************************************************/
/*                          Defines For Constants. 
/****************************************************************************/

--
-- Compare Mode:
--
  CMP_COMPARE_MODE_OBJECT      CONSTANT VARCHAR2(30) := 'OBJECT';


-- 
-- Scan Mode:
-- 
  CMP_SCAN_MODE_FULL           CONSTANT VARCHAR2(30) := 'FULL';
  CMP_SCAN_MODE_RANDOM         CONSTANT VARCHAR2(30) := 'RANDOM';
  CMP_SCAN_MODE_CYCLIC         CONSTANT VARCHAR2(30) := 'CYCLIC';
  CMP_SCAN_MODE_CUSTOM         CONSTANT VARCHAR2(30) := 'CUSTOM';


--
-- dml options
--
  CMP_CONVERGE_LOCAL_WINS      CONSTANT VARCHAR2(30) := 'LOCAL';
  CMP_CONVERGE_REMOTE_WINS     CONSTANT VARCHAR2(30) := 'REMOTE';


-- Null value's substitution value
  CMP_NULL_VALUE_DEF           CONSTANT VARCHAR2(100) := 'ORA$STREAMS$NV';

-- Other Default values
CMP_MAX_NUM_BUCKETS    CONSTANT PLS_INTEGER  := 1000;
CMP_MIN_ROWS_IN_BUCKET CONSTANT PLS_INTEGER  := 10000;

/****************************************************************************/
/*                           Public APIs below.
/****************************************************************************/


/*
 * 
 * create_comparison: Create a comparison.
 *
 * NOTE:
 *   Objects on different databases have to be of the same shape.
 *   The object must have an index on a number column, preferably the PK.
 * 
 *
 * PARAMETERS:
 *  comparison_name    : Identifier for the comparison.
 *  schema_name        : Name of the schema to compare.
 *                       Must be same schema name on both databases.
 *  object_name        : Name of the object to compare.
 *  remote_schema_name : Name of the schema to compare.
 *                       (OPTIONAL)
 *  remote_object_name : Name of the object to compare.
 *                       (OPTIONAL)
 *  dblink_name        : Database link to the remote database.
 *  index_schema_name  : Name of index schema.
 *  index_name         : Name of index.
 *  comparison_mode    : CMP_COMPARE_MODE_OBJECT. In future, there will be 
                         more modes.
 *  column_list        : '*'   : include ALL columns in comparison (default)
 *                       Other : Comma-separate list of columns to check.
 *                               Must include the column that has been chosen 
 *                               as the index column for comparison.
 *                     
 *                               Column names can be quoted.
 *                     
 *  scan_mode          : CMP_SCAN_MODE_FULL, CMP_SCAN_MODE_RANDOM, 
 *                       CMP_SCAN_MODE_CYCLIC, CMP_SCAN_MODE_CUSTOM
 *  scan_percent       : The percent of table to scan. Applicable when 
 *                       scan_mode IN (CMP_SCAN_MODE_RANDOM, 
 *                                     CMP_SCAN_MODE_CYCLIC)
 *  null_value         : The value to substitute null column values.
 *                       (OPTIONAL)
 *  local_converge_tag : The local streams tag to set before performing 
 *                       any dmls to converge the data.
 *                       (OPTIONAL)
 *  remote_converge_tag: The remote streams tag to set before performing 
 *                       any dmls to converge the data.
 *                       (OPTIONAL)
 *  num_buckets        : Suggested number of buckets to divide a scan into.
 *                       (OPTIONAL)
 *  num_rows_in_bucket : Suggested number of rows in a bucket.
 *                       (OPTIONAL)
 *
 */

PROCEDURE create_comparison(
  comparison_name        VARCHAR2,
  schema_name            VARCHAR2,
  object_name            VARCHAR2,
  dblink_name            VARCHAR2,
  index_schema_name      VARCHAR2    DEFAULT NULL,
  index_name             VARCHAR2    DEFAULT NULL,               
  remote_schema_name     VARCHAR2    DEFAULT NULL,
  remote_object_name     VARCHAR2    DEFAULT NULL,
  comparison_mode        VARCHAR2    DEFAULT CMP_COMPARE_MODE_OBJECT,
  column_list            VARCHAR2    DEFAULT '*',          
  scan_mode              VARCHAR2    DEFAULT CMP_SCAN_MODE_FULL,
  scan_percent           NUMBER      DEFAULT NULL,
  null_value             VARCHAR2    DEFAULT CMP_NULL_VALUE_DEF,
  local_converge_tag     RAW         DEFAULT NULL,
  remote_converge_tag    RAW         DEFAULT NULL,
  max_num_buckets        NUMBER      DEFAULT CMP_MAX_NUM_BUCKETS,
  min_rows_in_bucket     NUMBER      DEFAULT CMP_MIN_ROWS_IN_BUCKET
);


TYPE comparison_type IS RECORD (
  scan_id            NUMBER,
  loc_rows_merged    NUMBER,  -- local rows upserted
  rmt_rows_merged    NUMBER,  -- remote rows upserted
  loc_rows_deleted   NUMBER,
  rmt_rows_deleted   NUMBER
);


/*
 * compare: Perform a comparison identified by comparison name.
 *
 * PARAMETERS:
 *  comparison_name : Identifier for the comparison.
 *  scan_info       : Information returned about the scan.
 *  perform_row_dif : When TRUE, performs individual row level difs.
 *                    When FALSE, will stop at the bucket level.
 *  min_value       : When scan_mode for the comparison is CMP_SCAN_MODE_CUSTOM
 *                    then a minimum index column value must be specified.
 *  max_value       : Maximum index column value and similar to min_value.
 *
 * RETURN:
 * 
 *  TRUE            : When no difs are found.
 *  FALSE           : When difs are found.
 */

FUNCTION compare(
  comparison_name      IN     VARCHAR2,
  scan_info            OUT    comparison_type,
  min_value            IN     VARCHAR2    DEFAULT NULL,
  max_value            IN     VARCHAR2    DEFAULT NULL,
  perform_row_dif      IN     BOOLEAN     DEFAULT FALSE
) RETURN BOOLEAN;



/*
 * recheck: Recheck a specified scan.
 *
 * PARAMETERS:
 *  comparison_name: Identifier for the comparison.
 *  scan_id        : The scan id to be rechecked. It need not be a top-level
 *                   scan.               
 *  perform_row_dif: When TRUE, performs individual row level difs.
 *                   When FALSE, will stop at the bucket level.
 *
 * RETURN:
 * 
 *  TRUE           : When no difs are found.
 *  FALSE          : When difs are found.
 *
 */
FUNCTION recheck(
  comparison_name      IN     VARCHAR2,
  scan_id              IN     NUMBER,
  perform_row_dif      IN     BOOLEAN     DEFAULT FALSE
) RETURN BOOLEAN;


/*
 * converge: Execute compensating dmls to get the two objects to converge.
 *
 * PARAMETERS:
 *  comparison_name : Identifier for the comparison.
 *  scan_id         : The scan id for which dmls need to be executed.
 *                    It need not be a top-level scan.
 *  converge_options: This decides whether the local object wins or the 
 *                    remote object wins.
 *  perform_commit  : Whether to perform a Commit after executing the dmls.
 *  local_converge_tag : The local streams tag to set before performing 
 *                    any dmls to converge the data. This will override 
 *                    the local tag set through create_comparison() API.
 *  remote_converge_tag : The remote streams tag to set before performing 
 *                    any dmls to converge the data. This will override 
 *                    the remote tag set through create_comparison() API.
 *
 */
PROCEDURE converge(
  comparison_name      IN     VARCHAR2,
  scan_id              IN     NUMBER,
  scan_info            OUT    comparison_type,
  converge_options     IN     VARCHAR2    DEFAULT CMP_CONVERGE_LOCAL_WINS,
  perform_commit       IN     BOOLEAN     DEFAULT TRUE,
  local_converge_tag   IN     RAW         DEFAULT NULL,
  remote_converge_tag  IN     RAW         DEFAULT NULL
);


/*
 * purge_comparison: Purge a comparison's results or a subset of it.
 *
 * PARAMETERS:
 *  comparison_name : Identifier for the comparison.
 *  scan_id         : The scan id whose results need to be purged.
 *                    It has to be a top-level scan, else an error is raised.
 *                    (Optional)
 *  purge_date      : The date before which results can be purged.
 *                    (Optional)
 *
 */

PROCEDURE purge_comparison(
  comparison_name      IN     VARCHAR2,
  scan_id              IN     NUMBER    DEFAULT NULL,
  purge_time           IN     TIMESTAMP DEFAULT NULL
);


/*
 * drop_comparison: Drop a comparison.
 *
 * PARAMETERS:
 *  comparison_name: Identifier for the comparison.
 *
 */

PROCEDURE drop_comparison(
  comparison_name      IN     VARCHAR2
);




end dbms_comparison;
/
show errors

GRANT EXECUTE ON dbms_comparison TO execute_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_comparison FOR dbms_comparison
/
