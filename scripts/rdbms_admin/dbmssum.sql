-- 
-- $Header: dbmssum.sql 31-jan-2007.05:59:21 gssmith Exp $
-- 
-- dbmssum.sql
-- 
-- Copyright (c) 2007, Oracle. All rights reserved.  
-- 
--    NAME
--      dbmssum.sql - PUBLIC interface FOR SUMMARY refresh
-- 
--    DESCRIPTION
--      defines specifification FOR packages dbms_summary
--   
-- 
--    NOTES
--      <other useful comments, qualifications, etc.>
-- 
--    MODIFIED   (MM/DD/YY)
--    gssmith     01/31/07 - Security bug
--    mxiao       10/27/03 - change the argument in describe_dimension 
--    mxiao       01/14/03 - remove the incremental from validate_dimension
--    mxiao       12/13/02 - add dbms_dimension package
--    mxiao       07/25/02 - add describe_dimension to dbms_olap
--    gssmith     08/24/01 - Adjustments to filters
--    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
--    btao        03/23/01 - Remove old 9i interface.
--    gssmith     02/22/01 - MV to MVIEW
--    btao        03/02/01 - fix constants FILTER_NONE and WORKLOAD_NONE.
--    gssmith     01/02/01 - Bug 1488357.
--    gssmith     11/02/00 - Script bug.
--    gssmith     10/31/00 - Bug 1479115.
--    btao        10/26/00 - fix typo regarding ADVISOR_RPT_RECOMMEDATION.
--    gssmith     09/19/00 - Purge workload bug
--    gssmith     08/25/00 - Advisor call change
--    mthiyaga    09/12/00 - Move EXPLAIN_REWRITE to dbmssnap.sql
--    btao        07/19/00 - fix comments
--    btao        07/13/00 - add ADVISOR_WORKLOAD_OVERWRITE flag
--    btao        07/06/00 - update 8.2 interface to include collection_id
--    btao        06/20/00 - remove redundant refresh code
--    mthiyaga    03/29/00 - Add EXPLAIN_REWRITE interface
--    gssmith     04/10/00 - Fine tuning Advisor calls and constants
--    btao        01/07/00 - add 8.2 advisor interface
--    bpanchap    06/02/99 - Adding user info
--    btao        04/23/99 - Disable anchorness
--    wnorcott    10/14/98 - Enable anchorness
--    ncramesh    08/10/98 - change for sqlplus
--    wnorcott    08/19/98 - Logging and set on/off qsmkganc
--    qiwang      08/07/98 - Rename verify_dimension to validate_dimension
--    sramakri    06/30/98 - Replace CREATE LIBRARY dbms_sumadv_lib with 
--                           @@dbmssml.sql
--    wnorcott    06/16/98 - procedure set_logfile_name
--    wnorcott    06/16/98 - get rid of set echo
--    ato         06/18/98 - remove set echo off to allow debugging
--    wnorcott    06/02/98 - Add DBMS_OLAP synonym
--    qiwang      05/28/98 - Add interface for Verify Dimension
--    wnorcott    05/22/98 - change specification for compute_variance, compute
--    wnorcott    05/18/98 - Required changes to refresh interface
--    wnorcott    04/09/98 - Move private interfaces to prvtsum.sql
--    wnorcott    04/03/98 - set_session_longops changed without warning
--    wnorcott    04/22/98 - Add on/off switch for cleanup_sumdelta
--    sramakri    04/08/98 - Summary Advisor functions
--    wnorcott    04/07/98 - procedure for nullness in stat functions
--    wnorcott    04/03/98 - set_session_longops changed without warning
--    wnorcott    02/21/98 - add refresh_mask output to qsmkrfx
--    wnorcott    02/12/98 - Add Refresh_in_C
--    wnorcott    02/04/98 - Add 3gl for callout to kprb
--    wnorcott    01/28/98 - Move qsmkanc out of ICD vector
--    wnorcott    01/20/98 - New ICD to test for anchorness
--    wnorcott    12/31/97 - make anchorlist a package global
--    wnorcott    12/30/97 - rename a couple procedures for clarity
--    wnorcott    12/23/97 - Split refresh into 3 packages in the same file
--    wnorcott    11/17/97 - Add entry for qsmkscn
--    wnorcott    10/16/97 - PUBLIC interface for summary refresh.
--    wnorcott    10/16/97 - Created
-- 
CREATE OR REPLACE PACKAGE dbms_summary authid current_user                                       
  /*                                                                            
 || Program: dbms_summary                                                      
 ||  Author: William D. Norcott, Oracle Corportation
 ||    File: dbmssum.sql                                                  
 || Created: September 11, 1997 15:11:36                                       
 */                                                                            
IS                                                                            
-- Package global variables
dimensionnotfound EXCEPTION;

-- Package constant variables

-- Interface for private trace facility used by the advisor 
PROCEDURE set_logfile_name(filename IN VARCHAR2 );

--    PROCEDURE DBMS_SUMMARY.VALIDATE_DIMENSION 
--    PURPOSE: To verify that the relationships specified in a DIMENSION
--             are correct. Offending rowids are stored in advisor repository
--    PARAMETERS:
--         dimension_name: VARCHAR2
--            Name of the dimension to analyze
--
--         dimension_owner: VARCHAR2
--            Owner of the dimension
--
--         incremental: BOOLEAN (default: TRUE)
--            If TRUE, then tests are performed only for the rows specified
--            in the sumdelta$ table for tables of this dimension; if FALSE,
--            check all rows.
--
--         check_nulls: BOOLEAN (default: FALSE)
--            If TRUE, then all level columns are verified to be non-null;
--            If FALSE, this check is omitted. Specify FALSE when non-nullness
--            is guaranteed by other means, such as NOT NULL constraints.
--
--    EXCEPTIONS:
--             dimensionnotfound       The specified dimension was not found 
PROCEDURE validate_dimension
                (
                dimension_name          IN VARCHAR2,
                dimension_owner         IN VARCHAR2,
                incremental             IN BOOLEAN,
                check_nulls             IN BOOLEAN);


--    PROCEDURE DBMS_SUMMARY.ESTIMATE_MVIEW_SIZE
--    PURPOSE: Estimate materialized size in terms of rows and bytes
--    PARAMETERS:
--         stmt_id: NUMBER
--            User-specified id 
--         select_clause: VARCHAR@
--            SQL text for the defining query
--         num_row: NUMBER
--            Estimated number of rows 
--         num_col: NUMBER
--            Estimated number of bytes
--   COMMENTS:
--         This procedure requires that 'utlxplan.sql' be executed
PROCEDURE estimate_mview_size (
                                 stmt_id         IN VARCHAR2,
                                 select_clause   IN VARCHAR2,
                                 num_rows        OUT NUMBER,
                                 num_bytes       OUT NUMBER);
PROCEDURE enable_dependent (
                            detail_tables      IN  VARCHAR2);

PROCEDURE disable_dependent (
                             detail_tables      IN  VARCHAR2);

END dbms_summary;                                                             
/                                                                             
GRANT EXECUTE ON dbms_summary TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dbms_summary FOR dbms_summary;
CREATE OR REPLACE PUBLIC SYNONYM dbms_olap FOR dbms_summary;
Rem The following line:
Rem CREATE OR REPLACE LIBRARY dbms_sumadv_lib AS '/vobs/rdbms/lib/libqsmashr.so';
Rem now comes from dbmssml.sql, which is generated from osds/dbmssml.sbs
@@dbmssml.sql
/

-------------------------------------------------------------------------------
-- Package: dbms_dimension
-- Creator: Min Xiao, Oracle Corportation
--    File: dbmssum.sql                                                  
-- Created: Dec, 2002
--                                                                            
CREATE OR REPLACE PACKAGE dbms_dimension authid current_user                                       
IS 
   ----------------------------------------------------------------------------
   -- public constants
   ----------------------------------------------------------------------------
   dimensionnotfound EXCEPTION;
 
   ----------------------------------------------------------------------------
   -- public procedures:
   ----------------------------------------------------------------------------
   
   ----------------------------------------------------------------------------
   --    PROCEDURE DBMS_DIMENSION.DESCRIBE_DIMENSION
   --    PURPOSE: prints out the definition of the input dimension, including 
   --             dimension owner and name, levels, hierarchies, attributes. 
   --             It displays the output via dbms_output.
   --    PARAMETERS:
   --         dimension: VARCHAR2
   --            Name of the dimension, e.g. 'scott.dim1', 'scott.%', etc.
   --
   --    EXCEPTIONS:
   --             dimensionnotfound       The specified dimension was not found 
   PROCEDURE describe_dimension(dimension IN VARCHAR2);

   ----------------------------------------------------------------------------
   --    PROCEDURE DBMS_DIMENSION.VALIDATE_DIMENSION 
   --    PURPOSE: To verify that the relationships specified in a DIMENSION
   --             are correct. Offending rowids are stored in advisor repository
   --    PARAMETERS:
   --         dimension: VARCHAR2
   --            Owner and name of the dimension in the format of 'owner.name'.
   --
   --         incremental: BOOLEAN (default: TRUE)
   --            If TRUE, then tests are performed only for the rows specified
   --            in the sumdelta$ table for tables of this dimension; if FALSE,
   --            check all rows.
   --
   --         check_nulls: BOOLEAN (default: FALSE)
   --            If TRUE, then all level columns are verified to be non-null;
   --            If FALSE, this check is omitted. Specify FALSE when non-nullness
   --            is guaranteed by other means, such as NOT NULL constraints.
   --
   --         statement_id: VARCHAR2 (default: NULL)
   --            A client-supplied unique identifier to associate output rows 
   --            with specific invocations of the procedure.
   --
   --    EXCEPTIONS:
   --             dimensionnotfound       The specified dimension was not found 
   -- 
   --    NOTE: It is the 10i new interface. The 8.1 and 9i interfaces are deprecated,
   --          but they should still remain working in 10i and after.
   PROCEDURE validate_dimension
     (
      dimension               IN VARCHAR2,
      incremental             IN BOOLEAN := TRUE,
      check_nulls             IN BOOLEAN := FALSE,
      statement_id            IN VARCHAR2 := NULL );

   ----------------------------------------------------------------------------
   --    PROCEDURE DBMS_DIMENSION.VALIDATE_DIMENSION
   --    PURPOSE: To verify that the relationships specified in a DIMENSION
   --             are correct. Offending rowids are stored in advisor repository
   --    PARAMETERS:
   --         dimension: VARCHAR2
   --            Owner and name of the dimension in the format of 'owner.name'.
   --
   --         check_nulls: BOOLEAN (default: FALSE)
   --            If TRUE, then all level columns are verified to be non-null;
   --            If FALSE, this check is omitted. Specify FALSE when non-nullness
   --            is guaranteed by other means, such as NOT NULL constraints.
   --
   --         statement_id: VARCHAR2 (default: NULL)
   --            A client-supplied unique identifier to associate output rows
   --            with specific invocations of the procedure.
   --
   --    EXCEPTIONS:
   --             dimensionnotfound       The specified dimension was not found
   --
   --    NOTE: It is the 10i new interface. The 8.1 and 9i interfaces are deprecated,
   --          but they should still remain working in 10i and after.
   PROCEDURE validate_dimension
     (
      dimension               IN VARCHAR2,
      check_nulls             IN BOOLEAN := FALSE,
      statement_id            IN VARCHAR2 := NULL );

END dbms_dimension;
/
   
GRANT EXECUTE ON dbms_dimension TO PUBLIC
/ 
CREATE OR REPLACE PUBLIC SYNONYM dbms_dimension FOR sys.dbms_dimension
/ 

