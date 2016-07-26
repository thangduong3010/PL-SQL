rem 
rem $Header: rdbms/admin/dbmspexp.sql /main/26 2010/01/18 02:41:06 mjangir Exp $ 
rem 
Rem Copyright (c) 1992, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      dbmspexp.sql - Package spec. for procedural extensions to export
Rem           NOTE - Package body is in: .../exp/prvtpexp.sql
Rem    DESCRIPTION
Rem      This file defines a pl/sql package containing 
Rem      functions that are called by export to dynamically link in 
Rem      pl/sql logic in the export process.
Rem      The package body is to be released only in PL/SQL binary form.
Rem    PUBLIC FUNCTION(S)
Rem     pre_table  - Get actions to be executed before tgt table is imported.
Rem     post_table - Get actions to be executed after tgt table is imported.
Rem     get_domain_index_metadata - Intermediary procedure between export and
Rem          the ODCIIndexGetMetadata method on a domain index's 
Rem          implementation type
Rem     begin_import_domain_index - begin to import to domain index' secobj
Rem     insert_secobj - insert an entry (index, secobj) into secobj$
Rem     get_domain_index_tables - Intermediary procedure between export and 
Rem          the ODCIIndexUtilGetTableNames method on a domain index
Rem          (returns the names of secondary objects to be exported)
Rem     get_v2_domain_index_tables - Intermediary procedure between export and 
Rem          the ODCIIndexUtilGetTableNames method on a post V2 
Rem          domain index implementation.  Returns TRUE if the domain indexes
Rem          secondary objects should be exported.
Rem     check_match_template - Return's 1 if a table partition subpartitions 
Rem          were created using the  table template partition
Rem     get_object_comment - Returns string used to generate operator or 
Rem          indextype comment statement.  
Rem    nulltochr0  - Replace \0 with CHR(0) in varchar
Rem    func_index_default
Rem                - get default$ from col$ for a func index, convert it to
Rem                  varchar2 from long and call function nulltochr0
Rem    RETURNS
Rem 
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem    MODIFIED   (MM/DD/YY)
Rem     mjangir    01/06/10 - Bug 9247416: add procedure to set hakan event
Rem     tbhukya    09/29/08 - Use NUMBER datatype in func_index_default
Rem     mjangir    05/07/08  - bug 7007411: remove procedure set_traceon rom
Rem                            package body.
Rem     tbhukya    04/16/08  - Bug 6904527: remove procedure 
Rem                            set_imp_flush_shared_pool from package.
Rem     kamble     03/13/07  - bug 5664206
Rem     kamble     09/24/04  - bug 3591564: func_index_default and  nulltochr0
Rem     jgalanes   08/10/04  - lrg 1725399 CONNECT role changes 
Rem     tchorma    04/08/04  - 3503807:func to generate comment for oper,idxtyp
Rem     bmccarth   02/13/04  - Add function to verify subpart. created using 
Rem                            table subpartition template
Rem     bmccarth   12/14/00  - pass gmflags to  get_v2_domain_index_tables 
Rem     bmccarth   11/06/00  - domain index v2 secondary object check
Rem     bmccarth   07/14/00 -  domain index V2 work
Rem     yhu        06/08/00 -  add two procedures for transpotable tablespace i
Rem     cyyip      07/07/99 -  replace '&' with 'and'
Rem     nvishnub   03/26/99 -  E/I support for fast rebuild of domain indexes.
Rem     ncramesh   08/07/98 -  change for sqlplus
Rem     gclaborn   07/02/98 -  Add version string to getmetadata prototype
Rem     nagarwal   06/08/98 -  add extidx_imp_lib
Rem     nagarwal   06/04/98 -  add routines for operators
Rem     gclaborn   05/04/98 -  Adjust for changes to ODCI interface
Rem     gclaborn   04/13/98 -  Change sense of multiblock param
Rem     gclaborn   04/07/98 -  Add Domain Index routines
Rem     ixhu       04/11/96 -  AQ support: table object only
Rem     dsdaniel   04/07/94 -  merge changes from branch 1.1.710.1
Rem     adowning   03/29/94 -  merge changes from branch 1.1.710.2
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     dsdaniel   01/31/94 -  Branch_for_patch
Rem     dsdaniel   01/31/94 -  Branch_for_patch
Rem     dsdaniel   12/29/93 -  Creation

CREATE OR REPLACE PACKAGE DBMS_EXPORT_EXTENSION AS 
------------------------------------------------------------
-- Overview
--
-- This package implements PL/SQL extensions to Export.
-- ...
---------------------------------------------------------------------
-- SECURITY
-- This package is owned by SYS,  and is  granted to PUBLIC.
-- The procedures dynamically called by the package are called using
-- The parse_as_user option
------------------------------------------------------------------------------
-- EXCEPTIONS
-- 
   unExecutedActions EXCEPTION;
-- A function was not called with the same parameters until it returned NULL.
-- This indicates an internal error in EXPORT.
-- CONSTANTS
-- 
--   Function codes for the expact$ table.
-- 
  func_pre_table   CONSTANT NUMBER := 1;     /* execute before loading table */
  func_post_tables CONSTANT NUMBER := 2; /* execute after loading all tables */
  func_pre_row     CONSTANT NUMBER := 3;       /* execute before loading row */
  func_post_row    CONSTANT NUMBER := 4;        /* execute after loading row */
  func_row         CONSTANT NUMBER := 5;   /* execute in lieu of loading row */
------------------------------------------------------------------------------
-- PROCEDURES AND FUNCTIONS
  FUNCTION pre_table(obj_schema IN VARCHAR2,
                     obj_name   IN VARCHAR2)
    RETURN VARCHAR2;
-- execute pre_table functions from the expact$ table, for a specific object 
-- Input Parameters:
--   obj_schema 
--     The schema of the object being exported.
--   obj_name
--     The name for the object being exported.
-- Result:
--   A string containg a procedure invocation to be put in the export stream.
--   If non-null, this procedure should be called again (immediately) for the
--   same object.  If NULL, there are no additional pre_table calls to 
--   be exported to the stream for this object and function.
-- Exceptions:
--   unExecutedActions
--   Any error encountered during executing of the action

  FUNCTION post_tables(obj_schema IN VARCHAR2,
                       obj_name   IN VARCHAR2)
    RETURN VARCHAR2;
-- execute post_tables functions from the expact$ table, for a specific object 
-- Input Parameters:
--   obj_schema 
--     The schema of the object being exported.
--   obj_name
--     The name for the object being exported.
-- Result:
--   A string containing a procedure invocation to be put in the export stream.
--   If non-null, this procedure should be called again (immediately) for the
--   same object.  
--  If NULL, there are no additional post_tables calls to be exported to the
--   stream for this object.
-- Exceptions:
--   unExecutedActions
--   Any error encountered during executing of the action
----------------------------------------------------------------------------
-- ROW FUNCTIONS WILL BE ADDED IN THE FUTURE
----------------------------------------------------------------------------

  FUNCTION get_domain_index_metadata (
        index_name      IN  VARCHAR2,
        index_schema    IN  VARCHAR2,
        type_name       IN  VARCHAR2,
        type_schema     IN  VARCHAR2,
        version         IN  VARCHAR2,
        newblock        OUT PLS_INTEGER,
        gmflags         IN  NUMBER DEFAULT -1 )         -- Post-v1 DI only
        RETURN VARCHAR2;

-- Acts as intermediary between export and the ODCIIndexGetMetadata method on
-- a domain index's implementation type. This allows the index to return
-- PL/SQL-based "metadata" such as policy info. Strings are returned
-- representing pieces of PL/SQL blocks to execute at import time. Multiple
-- PL/SQL blocks can be built
-- 
-- PARAMETERS:
--   index_name, index_schema   - Identifies current index
--   type_name, type_schema     - Identifies index's implementation type
--   exp_version  - Export's version; e.g, '08.01.03.00.00'
--   newblock - Allows callee to write multiple blocks of PL/SQL code.
--      non-zero: Return string starts a new block,
--      zero: Return string continues current block.
--   gmflags  - Only for post-V1 getindexmetadata call.  The default
--              value is -1 due to a bug in the use of NULL for NUMBER
--              datatypes.
--              See catodci.sql for description of the flags
-- RETURNS:
-- A piece of a PL/SQL block to be executed at import time. The BEGIN/END;
-- surrounding each block should not be returned as export will add these.
-- This routine will be repeatedly called until an empty string is returned.
--
  FUNCTION get_object_source (
           objid     IN  NUMBER,
           objtype   IN  NUMBER)
           RETURN VARCHAR2;

-- This function is used to get the source string for CREATE OPERATOR and 
-- CREATE INDEXTYPE. The function is passed the object number and the 
-- object type and the string returned is the SQL statement needed to 
-- create the operator or the index type. 
-- PARAMTERS: 
--   objid   - object number of the operator or indextype 
--   objtype - object type (32 for indextype, 33 for operators)
-- RETURNS: 
-- The SQL string that can be used to create the operator or the indextype 
-- specified by the object id 


-- get_domain_index_tables
-- for post V1 domain index implementations, see the _v2_ version below
--------------------------

  FUNCTION get_domain_index_tables (
        index_name      IN  VARCHAR2,
        index_schema    IN  VARCHAR2,
        type_name       IN  VARCHAR2,
        type_schema     IN  VARCHAR2,
        read_only       IN  PLS_INTEGER,
        version         IN  VARCHAR2,
        get_tables      IN  PLS_INTEGER)
        RETURN VARCHAR2;

-- Acts as intermediary between export and the ODCIIndexUtilGetTableNames 
-- method on a domain index's implementation type. This allows the index to 
-- return list of secondary tablenames (seperated by comma) which are to be 
-- exported and imported to speed up rebuild of domain indexes during import.
-- PARAMETERS:
--   index_name, index_schema   - Identifies current index
--   type_name, type_schema     - Identifies index's implementation type
--   version    - Export's version; e.g, '08.01.03.00.00'
--   read_only  - Is this a read-only transaction ?  True for Export if
--                CONSISTENT=y.  Note: some types may not be able to exploit
--                fast rebuild in a read-only environment.
--                1 => read_only. 
--   get_tables - Export will first call this function with get_tables=1. 
--   In this case, the function will instantiate both an instance of the 
--   implementation type as defined by  type_name and type_schema, and an 
--   object of type ODCIIndexInfo using parameters index_name and index_schema.
--   It will then call ODCIIndexUtilGetTableNames method on the implementation 
--   type using the ODCIIndexInfo object just constructed. The routine will
--   also maintain in a PL/SQL variable of session scope the context returned 
--   from ODCIIndexUtilGetTableNames to be handed back upon its second call.
--
--   After export writes all the tables returned on the first call to its 
--   dump file, it will call get_domain_index_tables again with parameter 
--   get_tables=0. In this case, this function will then call the 
--   ODCIIndexCleanup method on the ODCIIndexInfo object constructed in the
--   first call handing in the internally stored context. When this returns, 
--   it will clean up its state and return a NULL string to export.


-- get_v2_domain_index_tables
-- v1 domain index implementations use the above routine.
--------------------------

  FUNCTION get_v2_domain_index_tables (
        index_name      IN  VARCHAR2,
        index_schema    IN  VARCHAR2,
        type_name       IN  VARCHAR2,
        type_schema     IN  VARCHAR2,
        read_only       IN  PLS_INTEGER,
        version         IN  VARCHAR2,
        get_tables      IN  PLS_INTEGER,
        gmflags         IN  NUMBER)
        RETURN INTEGER;

-- Acts as intermediary between export and the ODCIIndexUtilGetTableNames 
-- method on a domain index's implementation type. 
-- Unlike the initial (v1) impelementation, the _v2_ 0/1
-- value which export will use to determine if all the secondary objects
-- associated with a domain index should be exported (1) or not (0)
--
-- PARAMETERS:
--   index_name, index_schema   - Identifies current index
--   type_name, type_schema     - Identifies index's implementation type
--   version    - Export's version; e.g, '08.01.03.00.00'
--   read_only  - Is this a read-only transaction ?  True for Export if
--                CONSISTENT=y.  Note: some types may not be able to exploit
--                fast rebuild in a read-only environment.
--                1 => read_only. 
--   get_tables - Ignored. 
--   gmflags   - Flags for domain index.  May have TransTblspc set if 
--               in transportable mode.

-- begin_import_domain_index
--------------------------

  PROCEDURE begin_import_domain_index (
        idxschema      IN  VARCHAR2,
        idxname        IN  VARCHAR2);

-- truncates the table odci_secobj$, and set up index schema and name 
-- PARAMETERS:
--   idxschema, idxname   - Identifies current index

-- insert_secobj
--------------------------

  PROCEDURE insert_secobj (
        secobjschema     IN  VARCHAR2,
        secobjname       IN  VARCHAR2);

-- insert an entry into the table odci_secobj$,
-- PARAMETERS:
--   secobjschema, secobjname   - Identifies current secondary table

--
-- Checks to see if a partition has made use of a template partition clause
--  
  FUNCTION check_match_template (
        pobjno          IN  INTEGER
      ) RETURN INTEGER;

-- get_object_comment
---------------------------

  FUNCTION get_object_comment (
        objid IN NUMBER,
        objtype IN NUMBER)
        RETURN VARCHAR2;
-- This function is used to get the source string for COMMENT OPERATOR and 
-- COMMENT INDEXTYPE. The function is passed the object number, and the type
-- of object (indextype or operator).  The string returned is the SQL 
-- statement needed to comment the operator or the indextype.  If there is no
-- comment registered for this operator or indextype, the return string is 
-- empty.
-- PARAMETERS: 
--   objid   - object number of the operator or indextype 
--   objtype - object type (32 for indextype, 33 for operators)
-- RETURNS: 
-- The SQL string that can be used to comment the operator or the indextype 
-- specified by the object id.  If there is no comment registered, the string
-- is empty.

  PROCEDURE set_imp_events; 
  PROCEDURE set_hakan_event;
  PROCEDURE set_secondaryobj_event;
  PROCEDURE reset_secondaryobj_event;
  PROCEDURE set_iot_event;
  PROCEDURE set_exp_opq_typ_event;
  PROCEDURE reset_exp_opq_typ_event;
  PROCEDURE set_no_outlines;
  PROCEDURE set_nls_numeric_char;
  PROCEDURE reset_nls_numeric_char;
  PROCEDURE set_exp_timezone;
  PROCEDURE set_exp_sortsize;
  PROCEDURE set_statson;
  PROCEDURE set_resum;
  PROCEDURE set_resumnam (
                name                    IN VARCHAR2);
  PROCEDURE set_resumtim (
                time                    IN INTEGER);
  PROCEDURE set_resumnamtim (
                name                    IN VARCHAR2,
                time                    IN INTEGER);
  PROCEDURE set_imp_timezone( 
                timezone                IN VARCHAR2);
  PROCEDURE set_imp_skip_indexes_on;
  PROCEDURE set_imp_skip_indexes_off;

-- NULLTOCHR0 - Replace \0 with CHR(0) in varchar
-- PARAMETERS:
--      value           - varchar value
-- RETURNS: varchar value with substitutions made

FUNCTION nulltochr0(value IN  VARCHAR2)
        RETURN VARCHAR2 ;

-- FUNC_INDEX_DEFAULT  - get default$ from col$ for a func index 
--                       and convert it to varchar2 from long
-- PARAMETERS:
--      tabobj           - binary_integer value
--      colname          - varchar2 value
-- RETURNS: clob value converted from long
-- ERROR: if value > 32000 bytes, then pl/sql will raise error ORA-6502
-- The error should be fine as the default$ contains the expression for
-- a functional index which is unlikely to exceed 32000 bytes

FUNCTION func_index_default
    (tabobj  IN  NUMBER, 
     colname IN  VARCHAR2) RETURN CLOB;

END DBMS_EXPORT_EXTENSION;
/

GRANT execute ON sys.dbms_export_extension to public; 

create or replace library extidx_imp_lib trusted as static;
/


