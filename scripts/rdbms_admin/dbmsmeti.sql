Rem 
Rem $Header: rdbms/admin/dbmsmeti.sql /st_rdbms_11.2.0/7 2013/04/24 03:03:54 gclaborn Exp $
Rem
Rem dbmsmeti.sql
Rem
Rem Copyright (c) 2001, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem     dbmsmeti.sql - Package header for DBMS_METADATA_INT.
Rem     NOTE - Package body is in:
Rem            rdbms/src/server/datapump/ddl/prvtmeti.sql
Rem    DESCRIPTION
Rem     This file contains the package header for DBMS_METADATA_INT,
Rem     a definers rights package that implements privileged functions.
Rem
Rem    PUBLIC FUNCTIONS / PROCEDURES
Rem     OPEN            - Establish object parameters 
Rem     SET_FILTER      - Specify filters.
Rem     SET_COUNT       - Specify object count.
Rem     SET_XMLFORMAT   - Specify formatting attributes for XML output.
Rem     GET_QUERY       - Get text of query (for debugging).
Rem     SET_PARSE_ITEM  - Enable output parsing 
Rem                       and specify an attribute to be parsed
Rem     ADD_TRANSFORM   - Specify transform.
Rem     SET_TRANSFORM_PARAM - Specify parameter to XSL stylesheet.
Rem     GET_VIEW_FILTER_INPUTS - Get inputs for pruning views
Rem     GET_XML_INPUTS  - Get inputs needed to invoke the XML renderer
Rem     NEXT_OBJECT     - Position to next object
Rem     SET_OBJECTS_FETCHED - Set the count of objects fetched
Rem     MODIFY_VAT      - For views_as_tables
Rem     DO_TRANSFORM    - Transform the XML doc with all added transforms
Rem     DO_PARSE_TRANSFORM - Transform the XML doc with the parse transform
Rem     GET_PARSE_DELIM - Get the parse delimiter
Rem     CLOSE           - Cleanup fetch context established by OPEN.
Rem     OPENW           - Establish object parameters for PUT or CONVERT
Rem     SET_DEBUG       - Set the internal debug switch.
Rem     PRINT_CTXS      - Print all active contexts
Rem     IS_ATTR_VALID_ON_10 - 
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gclaborn    03/25/13 - BP 16426769: Add CLEAR_XSL_CACHE
Rem    apfwkr      02/07/13 - Backport sdavidso_bug-11840083
Rem    lbarton     01/17/13 - Backport lbarton_bug-12780993 from
Rem    mjangir     07/25/12 - Backport tbhukya_bug-12731917 from
Rem    lbarton     03/21/11 - get_vat_xml
Rem    lbarton     01/07/11 - views-as-tables
Rem    lbarton     10/18/10 - backport 10185319 and 9791589 to 11.2.0.3
Rem    ebatbout    04/15/10 - bug 9491530: add routine, IS_ATTR_VALID_ON_10
Rem    sdavidso    03/04/10 - Bug 8847153: reduce resources for xmlschema
Rem                           export
Rem    lbarton     04/15/09 - bug 8354702: sql injection
Rem    rapayne     03/06/07 - add new set_debug signature to comply with standard
Rem                           datapump usage.
Rem    rapayne     03/06/07 - rework xdb not loaded error message
Rem    lbarton     01/05/07 - add message 39243
Rem    rapayne     03/01/06 - Add hooks for new COMPARE_xxx apis.
Rem    sdavidso    08/08/05 - Add numeric value overloaded set_transform_param 
Rem    lbarton     06/16/04 - Bug 3695154: 'XSL stylesheets not loaded' message 
Rem    lbarton     09/16/03 - Bug 3128559: Fix interface to openw 
Rem    gclaborn    05/02/03 - Add FETCH_OBJNUMS to public interface
Rem    gclaborn    04/04/03 - Add yet another out var to get_xml_inputs
Rem    lbarton     01/23/03 - sort types
Rem    lbarton     01/08/03 - cache obj numbers
Rem    lbarton     12/26/02 - Add SET_OBJECTS_FETCHED
Rem    gclaborn    11/27/02 - Add PRINT_CTXS
Rem    gclaborn    11/09/02 - Change get_xml_inputs prototype
Rem    lbarton     10/09/02 - return seqno from get_xml_inputs
Rem    lbarton     07/18/02 - change to get_xml_inputs
Rem    lbarton     06/07/02 - implement set_remap_param
Rem    lbarton     02/06/02 - new 10i infrastructure
Rem    lbarton     11/27/01 - better error messages
Rem    lbarton     09/10/01 - Merged lbarton_mdapi_reorg
Rem    lbarton     09/05/01 - Split off from dbmsmeta.sql

CREATE OR REPLACE PACKAGE dbms_metadata_int AUTHID DEFINER AS 
------------------------------------------------------------
-- Overview
-- This pkg implements the privileged functions of the mdAPI.
---------------------------------------------------------------------
-- SECURITY
-- This package is owned by SYS. It runs with definers, not invokers rights
-- because it needs to access dictionary tables.

-------------
-- EXCEPTIONS
--
  invalid_argval EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_argval, -31600);
    invalid_argval_num NUMBER := -31600;
-- "Invalid input value %s for parameter %s in function %s"
-- *Cause:  A NULL or invalid value was supplied for the parameter.
-- *Action: Correct the input value and try the call again.

  invalid_operation EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_operation, -31601);
    invalid_operation_num NUMBER := -31601;
-- "Function %s cannot be called now that fetch has begun"
-- *Cause:  The function was called after the first call to FETCH_xxx.
-- *Action: Correct the program.

  inconsistent_args EXCEPTION;
    PRAGMA EXCEPTION_INIT(inconsistent_args, -31602);
    inconsistent_args_num NUMBER := -31602;
-- "parameter %s value \"%s\" in function %s inconsistent with %s"
-- "Value \"%s\" for parameter %s in function %s is inconsistent with %s"
-- *Cause:  The parameter value is inconsistent with another value specified
--          by the program.  It may be not valid for the the object type
--          associated with the OPEN context, or it may be of the wrong
--          datatype: a boolean rather than a text string or vice versa.
-- *Action: Correct the program.

  object_not_found EXCEPTION;
    PRAGMA EXCEPTION_INIT(object_not_found, -31603);
    object_not_found_num NUMBER := -31603;
-- "object \"%s\" of type %s not found in schema \"%s\""
-- *Cause:  The specified object was not found in the database.
-- *Action: Correct the object specification and try the call again.

  invalid_object_param EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_object_param, -31604);
    invalid_object_param_num NUMBER := -31604;
-- "invalid %s parameter \"%s\" for object type %s in function %s"
-- *Cause:  The specified parameter value is not valid for this object type.
-- *Action: Correct the parameter and try the call again.

  inconsistent_operation EXCEPTION;
    PRAGMA EXCEPTION_INIT(inconsistent_operation, -31607);
    inconsistent_operation_num NUMBER := -31607;
-- "Function %s is inconsistent with transform."
-- *Cause:  Either (1) FETCH_XML was called when the "DDL" transform
--          was specified, or (2) FETCH_DDL was called when the
--          "DDL" transform was omitted.
-- *Action: Correct the program.

  object_not_found2 EXCEPTION;
    PRAGMA EXCEPTION_INIT(object_not_found2, -31608);
    object_not_found2_num NUMBER := -31608;
-- "specified object of type %s not found"
-- (Used by GET_DEPENDENT_xxx and GET_GRANTED_xxx.)
-- *Cause:  The specified object was not found in the database.
-- *Action: Correct the object specification and try the call again.

  stylesheet_load_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(stylesheet_load_error, -31609);
    stylesheet_load_error_num NUMBER := -31609;
-- "error loading file %s from file system directory \'%s\'"
-- *Cause:  The installation script initmeta.sql failed to load
--          the named file from the file system directory into the database.
-- *Action: Examine the directory and see if the file is present
--          and can be read.


  stylesheets_not_loaded EXCEPTION;
    PRAGMA EXCEPTION_INIT             (stylesheets_not_loaded, -39212);
    stylesheets_not_loaded_num NUMBER := -39212;
-- "installation error: XSL stylesheets not loaded correctly"
-- *Cause:  The XSL stylesheets used by the Data Pump Metadata API
--          were not loaded correctly into the Oracle dictionary table
--          "sys.metastylesheet". Either the stylesheets were not loaded
--          at all, or they were not converted to the database character
--          set.
-- *Action: Connect AS SYSDBA and execute dbms_metadata_util.load_stylesheets
--          to reload the stylesheets.

  xdb_not_loaded EXCEPTION;
    PRAGMA EXCEPTION_INIT             (xdb_not_loaded, -38500);
    xdb_not_loaded_num NUMBER := -38500;
-- "%s"
-- *Cause:    The operation requires XDB functionality which is not present in 
--            the database.
-- *Action:   Install the missing functionality and retry.

---------------------------
-- TYPES
--

-- type used in BULK COLLECT fetches and in SET_OBJECTS_FETCHED

  TYPE t_num_coll IS TABLE OF NUMBER         INDEX BY BINARY_INTEGER;

---------------------------
-- PROCEDURES AND FUNCTIONS
--
-- OPEN: Specifies the type of object whose metadata is to be retrieved.
-- PARAMETERS:
--      object_type     - Identifies the type of objects to be retrieved; i.e.,
--              TABLE, INDEX, etc. This determines which view is selected.
--      version         - The version of the objects' metadata to be fetched.
--              To be used in downgrade scenarios: Objects in the DB that are
--              incompatible with an older specified version are not returned.
--              Values can be 'COMPATIBLE' (default), 'LATEST' or a specific
--              version number.
--      model           - The view of the metadata, such as Oracle proprietary,
--              ANSI99, etc.  Currently only 'ORACLE' is supported.
--      public_func     - Name of the public function in DBMS_METADATA called
--              by the user; for error reporting.
--      current_user    - Current user name.
--
-- RETURNS:
--      A handle to be used in subsequent calls to SET_FILTER,
--      ADD_TRANSFORM, GET_QUERY, SET_PARSE_ITEM and CLOSE.
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.

  FUNCTION open (
                object_type     IN  VARCHAR2,
                version         IN  VARCHAR2,
                model           IN  VARCHAR2,
                public_func     IN  VARCHAR2,
                current_user    IN  VARCHAR2)
        RETURN NUMBER;


-- SET_FILTER: Specifies restrictions on the objects whose metadata 
--      is to be retrieved.
--      This function is overloaded: the filter value can be a varchar2
--      or a boolean.
-- PARAMETERS:
--      handle  - Context handle from previous OPEN call.
--      name    - Name of the filter.
--      value   - Value of the filter.
--      object_type     - Object type to which the filter applies.

  PROCEDURE set_filter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  VARCHAR2,
                object_type     IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE set_filter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  BOOLEAN DEFAULT TRUE,
                object_type     IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE set_filter (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                value           IN  NUMBER,
                object_type     IN  VARCHAR2 DEFAULT NULL);


-- SET_COUNT: Specifies the number of objects to be returned in a single
--      FETCH_xxx call.
-- PARAMETERS:
--      handle          - Context handle from previous OPEN call.
--      value           - Number of objects to retrieve.
--      object_type     - Object type to which the count applies.

  PROCEDURE set_count (
                handle          IN  NUMBER,
                value           IN  NUMBER,
                object_type     IN  VARCHAR2 DEFAULT NULL);


-- SET_XMLFORMAT: Specifies formatting attributes for XML output.
-- PARAMETERS:
--      handle          - Context handle from previous OPEN call.
--      name            - Attribute to set. (Only 'PRETTY' is supported.)
--      value           - Value of the attribute.

  PROCEDURE set_xmlformat (
                handle                  IN  NUMBER,
                name                    IN  VARCHAR2,
                value                   IN  BOOLEAN DEFAULT TRUE);

-- GET_QUERY:   Return the text of the query (or queries) that will be
--              used by FETCH_xxx.  This function is provided to aid
--              in debugging.
-- PARAMETERS:  handle  - Context handle from previous OPEN call.
-- RETURNS:     Text of the query.

  FUNCTION get_query (
                handle          IN  NUMBER)
        RETURN VARCHAR2;


-- SET_PARSE_ITEM: Enables output parsing and specifies an object attribute
--      to be parsed and returned
-- PARAMETERS:
--      handle  - Context handle from previous OPEN call.
--      name    - Attribute name.
--      object_type- Object type to which the transform applies.

  PROCEDURE set_parse_item (
                handle          IN  NUMBER,
                name            IN  VARCHAR2,
                object_type     IN  VARCHAR2 DEFAULT NULL);


-- ADD_TRANSFORM : Specify a transform to be applied to the XML representation
--              of objects returned by FETCH_xxx.
-- PARAMETERS:  handle  - Context handle from previous OPEN call.
--              name    - The name of the transform: Internal name (like 'DDL')
--                        or a URI to a stylesheet.
--              encoding- If name is a URI, encoding of the target stylesheet.
--              object_type - Object type to which the transform param applies.
-- RETURNS:     An opaque handle to the transform to be used in subsequent
--              calls to SET_TRANSFORM_PARAM.

  FUNCTION add_transform (
                handle          IN NUMBER,
                name            IN VARCHAR2,
                encoding        IN VARCHAR2 DEFAULT NULL,
                object_type     IN VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;


-- SET_TRANSFORM_PARAM: Specifies a value for a parameter to the XSL-T
--      stylesheet identified by handle.
--      This procedure is overloaded: the parameter value can be a varchar2,
--      number, or a boolean.
-- PARAMETERS:
--      transform_handle - Handle from previous ADD_TRANSFORM call.
--      name             - Name of the parameter.
--      value            - Value for the parameter.
--      object_type      - Object type to which the transform param applies.

  PROCEDURE set_transform_param (
                transform_handle        IN  NUMBER,
                name                    IN  VARCHAR2,
                value                   IN  VARCHAR2,
                object_type             IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE set_transform_param (
                transform_handle        IN  NUMBER,
                name                    IN  VARCHAR2,
                value                   IN  NUMBER,
                object_type             IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE set_transform_param (
                transform_handle        IN  NUMBER,
                name                    IN  VARCHAR2,
                value                   IN  BOOLEAN DEFAULT TRUE,
                object_type             IN  VARCHAR2 DEFAULT NULL);

-- SET_REMAP_PARAM: Specifies values for a remap parameter to the XSL-T
--      stylesheet identified by handle.
-- PARAMETERS:
--      transform_handle - Handle from previous ADD_TRANSFORM call.
--      name             - Name of the parameter.
--      old_value        - Old value for the remapping
--      new_value        - New value for the remapping
--      object_type      - Object type to which the transform param applies.

  PROCEDURE set_remap_param (
                transform_handle        IN  NUMBER,
                name                    IN  VARCHAR2,
                old_value               IN  VARCHAR2,
                new_value               IN  VARCHAR2,
                object_type             IN  VARCHAR2 DEFAULT NULL);

-- GET_OBJECT_TYPE_INFO
-- PARAMETERS:
--      handle               - Context handle from previous OPEN call.
--      heterogeneous        - (OUT) TRUE if heterogeneous type

  PROCEDURE get_object_type_info (
                handle                  IN  NUMBER,
                heterogeneous           OUT BOOLEAN );

-- GET_VIEW_FILTER_INPUTS: For some object types (TABLE, MView, etc.) 
--  we define multiple views for fetching the objects (e.g., separate
--  views for partitioned and non-partitioned tables).  We can improve
--  performance by avoiding querying views which don't match the
--  the user filters: cheap queries against ku$_tabprop_view, etc.
--  allow us to avoid expensive queries against the object views.
--  To avoid SQL injection, the cheap queries must be issued from
--  the invoker rights package rather than from this package.
--  This procedure returns filters for the caller to issue the query.
-- PARAMETERS:
--      handle               - Context handle from previous OPEN call.
--      obj_handle           - (OUT) handle of the current object
--      object_type          - (OUT) current object type
--      schema_filter        - (OUT) schema
--      name_filter          - (OUT) name
--      schema_expr_filter   - (OUT) schema expression
--      name_expr_filter     - (OUT) name expression
--      primary_filter       - (OUT) filter for primary objects
--      secondary_filter     - (OUT) filter for secondary objects
--      objnum_count         - (OUT) number of entries in object_numbers
--      object_numbers       - (OUT) table of object numbers
--      objnum_filter_attrname - (OUT) attrname of the objnum filter
--      object_type_path     - (OUT) full path name of object type
-- Output parameters are set to NULL if the corresponding filter was not
-- specified.

  PROCEDURE get_view_filter_inputs (
                handle                  IN  NUMBER,
                obj_handle              OUT NUMBER,
                object_type             OUT VARCHAR2,
                schema_filter           OUT VARCHAR2,
                name_filter             OUT VARCHAR2,
                schema_expr_filter      OUT VARCHAR2,
                name_expr_filter        OUT VARCHAR2,
                primary_filter          OUT BOOLEAN,
                secondary_filter        OUT BOOLEAN,
                objnum_count            OUT NUMBER,
                object_numbers          OUT t_num_coll,
                objnum_filter_attrname  OUT VARCHAR2,
                object_type_path        OUT VARCHAR2);


-- GET_XML_INPUTS: Get inputs needed to invoke the XML renderer
-- PARAMETERS:
--      handle          - Context handle from previous OPEN call.
--      objnum_function - text string containing invocation of a table
--                        function to return object numbers, e.g.,
--                        'DBMS_METADATA.FETCH_OBJNUMS(10001)'
--      sortobjnum_function - text string containing invocation of a table
--                        function to return a nested table of type
--                        sys.ku$_ObjNumPairList, e.g.,
--                        'DBMS_METADATA.FETCH_SORTED_OBJNUMS(10001)'
--      stmt            - SQL statement (NULL if no more stmts)
--      rowtag          - row tag
--      xmltag          - xmltag for XML object
--      object_count    - object count
--      object_type_path- full path name of object type
--      seqno           - seqno of object type in heterogeneous collection
--      callout         - 0 = normal xml fetch
--                        1 = callout
--                        2 = object number fetch, no xml
--                        3 = obj#, dependent obj# fetch
--                        4 = xmlschema special case - just fetch .xsd document
--                        5 = parent_obj#, object_name fetch
--                        6 = fetch ku$_objgrant_t UDTs
--      parsed_items    - Array of varchar with requested parse item names.
--                        Values retrieved from query execution in prvtmeta.
--      bind_vars       - table of bind variable values to be used in query
--      objnum_count    - number of entries in object_numbers
--      object_numbers  - table of object numbers
--      object_names         - (OUT) table of object names

  PROCEDURE GET_XML_INPUTS (
                handle                  IN  NUMBER,
                objnum_function         IN  VARCHAR2,
                sortobjnum_function     IN  VARCHAR2,
                stmt                    OUT VARCHAR2,
                rowtag                  OUT VARCHAR2,
                xmltag                  OUT VARCHAR2,
                object_count            OUT NUMBER,
                object_type_path        OUT VARCHAR2,
                seqno                   OUT NUMBER,
                callout                 OUT NUMBER,
                parsed_items            OUT dbms_sql.Varchar2_Table,
                bind_vars               OUT dbms_sql.Varchar2_Table,
                objnum_count            OUT NUMBER,
                object_numbers          OUT t_num_coll,
                object_names            OUT dbms_sql.Varchar2_Table);

-- NEXT_OBJECT: Set the dbms_metadata_int state to point to the 
--  next object type to be fetched.  (For homogeneous object types
--  this is a no-op.)
-- PARAMETERS:
--      handle          - Context handle from previous OPEN call.
--      skip_current    - Skip the current step
-- IMPLICIT OUTPUTS:
--      On the first call, the root heterogenous object is initialized
--      context_list(ctxind).cur_script - points to the next homogeneous
--        type to be queried.
--      If skip_current is TRUE, the current step is marked 'completed'
--        and cur_script moves to the next type.

  PROCEDURE next_object (
                handle                  IN  NUMBER,
                skip_current            IN  BOOLEAN DEFAULT FALSE );

-- SET_OBJECTS_FETCHED: Set the count of objects fetched and their objnums
-- PARAMETERS:
--      handle          - Context handle from previous OPEN call.
--      object_count    - object count
--      object_numbers  - table of objects numbers
--      dependent_objects       - table of dependent object numbers
--      object_names    - table of object names
--      object_schemas  - table of object schema names

  PROCEDURE SET_OBJECTS_FETCHED (
                handle                  IN  NUMBER,
                object_count            IN  NUMBER,
                object_numbers          IN  t_num_coll,
                dependent_objects       IN  t_num_coll);

  PROCEDURE SET_OBJECTS_FETCHED (
                handle                  IN  NUMBER,
                object_count            IN  NUMBER,
                object_numbers          IN  t_num_coll,
                dependent_objects       IN  t_num_coll,
                object_names            IN  dbms_sql.Varchar2_Table);

  PROCEDURE SET_OBJECTS_FETCHED (
                handle                  IN  NUMBER,
                object_count            IN  NUMBER,
                object_schemas          IN  dbms_sql.Varchar2_Table,
                object_names            IN  dbms_sql.Varchar2_Table,
                object_levels           IN  t_num_coll);

-- MODIFY_VAT: Do MODIFY/REMAP for VIEWS_AS_TABLES step
-- PARAMETERS:
--      handle       - Context handle from previous OPEN call.
--      ho_type      - heterogeneous object type (e.g., TABLE_EXPORT)
--      path         - path of step to modify
--      transform    - transform/remap param name
--      name1        - param value
--      name2        - param value

  PROCEDURE MODIFY_VAT(
                handle          IN  NUMBER,
                ho_type         IN  VARCHAR2,
                path            IN  VARCHAR2,
                transform       IN  VARCHAR2,
                name1           IN  VARCHAR2,
                name2           IN  VARCHAR2);

-- DO_TRANSFORM: Transform the XML doc using all added transforms
-- PARAMETERS:
--      handle      - Context handle from previous OPEN call.
--      xmldoc      - The XML document
--      doc         - returned document as a CLOB
--      do_parse    - TRUE = do parse transform

  PROCEDURE DO_TRANSFORM (
                handle          IN  NUMBER,
                xmldoc          IN  CLOB,
                doc             IN OUT NOCOPY CLOB,
                do_parse        IN  BOOLEAN DEFAULT FALSE);


-- DO_PARSE_TRANSFORM: Transform the XML doc with the parse transform
--      (used by FETCH_XML)
-- PARAMETERS:
--      handle      - Context handle from previous OPEN call.
--      xmldoc      - The XML document
--      doc         - returned document as a CLOB

  PROCEDURE DO_PARSE_TRANSFORM (
                handle          IN  NUMBER,
                xmldoc          IN  CLOB,
                doc             IN OUT NOCOPY CLOB);

-- GET_PARSE_DELIM: Get the parse delimiter
-- PARAMETERS:  handle  - Context handle from previous OPEN call.

  FUNCTION GET_PARSE_DELIM (handle IN NUMBER)
        RETURN VARCHAR2;

-- CLOSE:       Cleanup all context associated with handle.
-- PARAMETERS:  handle  - Context handle from previous OPEN call.

  PROCEDURE CLOSE (handle IN NUMBER);

-- CLEAR_CACHE: Cleanup xsl context associated with handle.
-- PARAMETERS:
--      ccache - TRUE  : Clear xsl context cache.
--               FALSE : Don't clear xsl context cache.

  PROCEDURE clear_cache(ccache IN BOOLEAN DEFAULT FALSE);

-- OPENC: Specifies the type of object whose metadata is to be compared.
-- PARAMETERS:
--      object_type     - Identifies the type of objects to be submitted; e.g.,
--                        TABLE, INDEX, etc. May not be a heterogeneous
--                        object type.
--      version         - The version of the objects' DDL to be created.
--                        Values can be 'COMPATIBLE' (default), 'LATEST' or 
--                        a specific version number.
-- RETURNS:
--      A handle to be used in subsequent calls to ADD_TRANSFORM, CONVERT,
--      PUT and CLOSE.
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.

  FUNCTION openc (
                object_type     IN  VARCHAR2,
                version         IN  VARCHAR2,
                model           IN  VARCHAR2,
                public_func     IN  VARCHAR2,
                current_user    IN  VARCHAR2)
        RETURN NUMBER;

-- OPENW: Specifies the type of object whose metadata is to be submitted.
-- PARAMETERS:
--      object_type     - Identifies the type of objects to be submitted; e.g.,
--                        TABLE, INDEX, etc. May not be a heterogeneous
--                        object type.
--      version         - The version of the objects' DDL to be created.
--              Values can be 'COMPATIBLE' (default), 'LATEST' or a specific
--              version number.
--      model           - The view of the metadata, such as Oracle proprietary,
--                        ANSI99, etc.  Currently only 'ORACLE' is supported.
--      public_func     - Name of the public function in DBMS_METADATA called
--              by the user; for error reporting.
--
-- RETURNS:
--      A handle to be used in subsequent calls to ADD_TRANSFORM, CONVERT,
--      PUT and CLOSE.
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.

  FUNCTION openw (
                object_type     IN  VARCHAR2,
                version         IN  VARCHAR2,
                model           IN  VARCHAR2,
                public_func     IN  VARCHAR2)
        RETURN NUMBER;

-- SET_DEBUG: Set the internal debug switch.
-- PARAMETERS:
--      on_off       - new switch state.
--	arg2	     - unused argument to force the overloading of 
--                     this procedure (i.e., overloaded version of this
--                     routine will match the common datapump interface.

  PROCEDURE set_debug(
                on_off          IN BOOLEAN,
                arg2            IN BOOLEAN DEFAULT TRUE);

-- SET_DEBUG: Enable Metadata tracing.
-- PARAMETERS:
--	debug_flags  - trace flag bitvector (see prvtkupc.sql for bit defs).
 PROCEDURE set_debug(
		debug_flags	IN BINARY_INTEGER);

-- PRINT_CTXS:  For debugging: Print all active contexts

  PROCEDURE print_ctxs;


-- compare:      Specifies the type of object whose metadata is to be compared.
-- PARAMETERS:
--     handle  - compare context handle
--     doc1    - first source document 
--     doc2    - second source document 
--     difdoc  - return diff document
--     diffs   - TRUE - diffs found
--               FALSE - doc1 == doc2
--
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.
  PROCEDURE compare (
                handle          IN  NUMBER,
                doc1            IN  CLOB,
                doc2            IN  CLOB,
                difdoc          IN  OUT NOCOPY CLOB,
                diffs           OUT BOOLEAN);

-- IS_ATTR_VALID_ON_10: 
--
-- PARAMETERS:
--      objnum         - obj# of table
--      intcol_num     - intcol# of column
 FUNCTION is_attr_valid_on_10(
                obj_num         IN  NUMBER,
                intcol_num      IN  NUMBER)
        RETURN NUMBER;

-- CLEAR_XSL_CACHE:     Release all stylesheets in the XSL cache.
-- PARAMETERS:          None

  PROCEDURE clear_xsl_cache;

END DBMS_METADATA_INT;
/
GRANT EXECUTE ON sys.dbms_metadata_int TO EXECUTE_CATALOG_ROLE;
