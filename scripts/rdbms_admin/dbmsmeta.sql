rem
rem $Header: rdbms/admin/dbmsmeta.sql /st_rdbms_11.2.0/12 2013/03/14 09:48:25 sdavidso Exp $
rem 
Rem dbmsmeta.sql
Rem
Rem Copyright (c) 2001, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem     dbmsmeta.sql - Package header for DBMS_METADATA.
Rem     NOTE - Package body is in:
Rem            /vobs/rdbms/src/server/datapump/ddl/prvtmeta.sql
Rem    DESCRIPTION
Rem     This file contains the public interface for the Metadata API.
Rem     The package body is to be released only in PL/SQL binary form.
Rem
Rem    PUBLIC FUNCTIONS / PROCEDURES
Rem       (the retrieval interface)
Rem     ADD_DOCUMENT    - specifies an (S)XML document to be compared. 
Rem     OPEN            - Establish object parameters 
Rem     SET_FILTER      - Specify filters.
Rem     SET_COUNT       - Specify object count.
Rem     SET_XMLFORMAT   - Specify formatting attributes for XML output.
Rem     GET_QUERY       - Get text of query (for debugging).
Rem     SET_PARAMETER   - Specify fetch parameters.
Rem     SET_PARSE_ITEM  - Enable output parsing 
Rem                       and specify an attribute to be parsed
Rem     ADD_TRANSFORM   - Specify transform.
Rem     SET_TRANSFORM_PARAM - Specify parameter to XSL stylesheet.
Rem     FETCH_XML       - Fetch selected DB objects as XML docs.
Rem     FETCH_DDL       - Fetch selected DB objects as DDL.
Rem                     ***** TEMPORARY API FOR LOGICAL STANDBY *****
Rem     FETCH_DDL_TEXT  - Fetch selected DB objects as DDL in a VARCHAR2
Rem                     ***** TEMPORARY API FOR LOGICAL STANDBY *****
Rem     FETCH_CLOB      - Fetch selected DB objects as CLOBs.
Rem     PROCEDURE FETCH_XML_CLOB - Same as above, but with IN/OUT NOCOPY
Rem                             for perf.
Rem     CLOSE           - Cleanup fetch context established by OPEN.
Rem       (the browsing interface)
Rem     GET_XML         - Simple 1-step method for retrieving a single
Rem                       named object as an XML doc.
Rem     GET_SXML        - Simple 1-step method for retrieving a single
Rem                       named object as an SXML doc.
Rem	GET_SXML_DDL    - Simple 1-step method for retrieving a single
Rem			  DB object, converting to SXML, then to DDL.
Rem     GET_DDL         - Simple 1-step method for retrieving DDL for a single
Rem                       named object.
Rem     GET_DEPENDENT_XML- Simple 1-step method for retrieving objects
Rem                       dependent on a base object as an XML doc.
Rem     GET_DEPENDENT_SXML-Simple 1-step method for retrieving objects
Rem                       dependent on a base object as an SXML doc.
Rem     GET_DEPENDENT_DDL- Simple 1-step method for retrieving DDL for
Rem                       objects dependent on a base object.
Rem     GET_GRANTED_XML - Simple 1-step method for retrieving objects
Rem                       granted to a grantee.
Rem     GET_GRANTED_DDL - Simple 1-step method for retrieving DDL for
Rem                       objects granted to a grantee.
Rem     GET_DPSTRM_MD   - Get stream metadata for table (for use by
Rem                       DataPump data layer only)
Rem
Rem     -------- (internal APIs) ------
Rem     SET_DEBUG       - Set the internal debug switch.
Rem     NET_SET_DEBUG   - Set the internal debug switch on remote node
Rem     NETWORK_OPEN    - Do OPEN over network, negotiate protocol version.
Rem     NETWORK_CALLOUTS- Execute callouts (used by network mode)
Rem     NETWORK_FETCH_CLOB - Fetch selected DB objects in a VARCHAR2
Rem                     (used by network mode)
Rem     NETWORK_FETCH_PARSE - Return serialized parse items in a VARCHAR2
Rem                     (used by network mode)
Rem     FREE_CONTEXT_ENTRY - To be called *ONLY* by the definers rights
Rem                       pkg. (dbms_metadata_int) error handling.
Rem     FETCH_OBJNUMS   - Table function to return object numbers.
Rem                     (used to speed up heterogeneous fetch)
Rem     GET_DOMIDX_METADATA - Get PLSQL code from the ODCIIndexGetMetadata
Rem                       method of a domain index implementation type.
Rem     OKTOEXP_2NDARY_TABLE - Should a secondary object of a domain index
Rem                       be exported?
Rem     PATCH_TYPEID    - For transportable import, modify a type typeid.
Rem     CHECK_TYPE      - For transportable import, check a type definition
Rem                       and typeid.
Rem     GET_HASHCODE    - Get type hashcode.
Rem     GET_SYSPRIVS    - Get the export string from call grant_sysprivs_exp 
Rem                       and audit_sysprivs_exp function of a package in
Rem                       exppkgobj$
Rem     GET_PROCOBJ     - Get the export string from create_exp or audit_exp
Rem                       function of package in exppkobj$
Rem     GET_PROCOBJ_GRANT
Rem                     - Get the export string from call grant_exp function 
Rem                       of package in exppkobj$
Rem     GET_ACTION_SYS  - Get the export string from call system_info_exp 
Rem                       function of package in exppkgact$
Rem     GET_ACTION_SCHEMA 
Rem                     - Get the export string from call schema_info_exp
Rem                       function of package in exppkgact$
Rem     GET_ACTION_INSTANCE
Rem                     - Get the export string from call instance_info_exp 
Rem                       and instance_extended_info_exp function of package 
Rem                       in exppkgact$ 
Rem     GET_PLUGTS_BLK  - Get the export string from dbms_plugts.
Rem     GET_JAVA_METADATA - Return java info from DBMS_JAVA.EXPORT
Rem     GET_CANONICAL_VSN - Convert VERSION param to canonical form.
Rem     CONVERT_TO_CANONICAL - Convert specified VERSION param to canonical 
Rem                       form.
Rem     GET_INDEX_INTCOL - Get intcol# in table of column on which index is
Rem                        defined (need special handling for xmltype cols)
Rem
Rem     -----  (APIs unique to the submit interface) -----
Rem     OPENW           - Open a write context
Rem     CONVERT         - Convert an XML document to DDL
Rem     PUT             - Submit an XML document to the database
Rem       (the submit interface also uses ADD_TRANSFORM, SET_TRANSFORM_PARAM
Rem        and SET_PARSE_ITEM.)
Rem
Rem     -------- (more internal APIs) ------
Rem     CHECK_MATCH_TEMPLATE - check if sub-partitions were created via table
Rem                            subpartition template clause
Rem     CHECK_MATCH_TEMPLATE_PAR
Rem                          - check if sub-partitions were created via table
Rem                            subpartition template clause
Rem     CHECK_MATCH_TEMPLATE_LOB  
Rem                          - check if sub-partitions lob were created via 
Rem     GET_EDITION     - get edition of interest for current MDAPI context
Rem     GET_EDITION_ID  - get edition ID of interest for current MDAPI context
Rem     GET_VERSION     - retrieve target metadata version, in canonical form
Rem     PARSE_CONDITION - Return a check condition as XML
Rem     PARSE_DEFAULT   - Return the default value of a virt col as XML
Rem     PARSE_QUERY     - Return a query as XML
Rem     GET_CHECK_CONSTRAINT_NAME - Return the constraint name given the
Rem                       condition. (Useful if name is system-generated.)
Rem     OPEN_GET_FK_CONSTRAINT_NAME - This and the following 2 apis return
Rem                       the name of a foreign key constraint given its
Rem                       definition. (Useful if name is system-generated.)
Rem     SET_FK_CONSTRAINT_COL_PAIR
Rem     GET_FK_CONSTRAINT_NAME
Rem     IS_ATTR_VALID_ON_10 - 
Rem     IS_XDB_TRANS     - return 1 if XDB repository is in a tablespace which
Rem                        will be moved via TTS
Rem     IN_TSNUM         - return 1 if TS# is in the selected set
Rem     GET_INDPART_TS   - get a ts# for an index (sub)partition
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     apfwkr     03/06/13  - Backport sdavidso_bug-16051676 from main
Rem     dgagne     01/30/13  - fix bug for authpwdx
Rem     sdavidso   02/05/13  - Backport sdavidso_bug-14192178
Rem     apfwkr     01/23/13  - Backport sdavidso_bug14490576-2 from
Rem                            st_rdbms_12.1.0.1
Rem     sdavidso   11/09/12  - bug15837887 preserve disable table lock
Rem     lbarton    01/02/13  - Backport lbarton_bug-10186633 from
Rem     dgagne     10/18/12  - bug12866600
Rem     bwright    10/22/12  - Backport bwright_bug-14679947 from main
Rem     dgagne     02/10/12  - Backport dgagne_bug-10384616 from main
Rem     sdavidso   04/11/11  - add marker for KU\$_ICRPP_EARLY
Rem     lbarton    03/31/11  - Backport lbarton_bug-10363497 from main
Rem     lbarton    03/21/11  - get_vat_xml
Rem     sdavidso   03/10/11  - declare is_xdb_trans deterministic
Rem     sdavidso   03/02/11  - add in_tsnum function
Rem     sdavidso   02/14/11  - proj 37216: EXCLUDE and XDB_TABLESPACE for
Rem                            options
Rem     sdavidso   12/23/10  - Extend full exp for options
Rem     ebatbout   04/15/10  - bug 9491530: Add routine, IS_ATTR_VALID_ON_10
Rem     sdavidso   03/09/10  - Bug 8847153: reduce resources for xmlschema
Rem                            export
Rem     tbhukya    12/04/09  - Bug 8307012: Add support for domain index whose
Rem                                         support interface is 1
Rem     dgagne     07/30/09 - add parseitem connect_type
Rem     lbarton    03/23/09 - bug 8347514: parse read-only view query
Rem     lbarton    10/20/08 - SESSION_HANDLE, GET_SXML_DDL
Rem     lbarton    07/03/08 - bug 5709159: get_constraint_name apis
Rem     sdavidso   06/09/08 - bug 6910214: mv log in transportable
Rem     rapayne    05/16/08  - 
Rem     lbarton    04/22/08  - bug 6730161: move get_hashcode from dbmsmetu
Rem     lbarton    04/14/08  - bug 6969874: move compare APIs to their own
Rem                            package
Rem     lbarton    02/05/08  - Bug 6029076: query parsing -
Rem                              SET_PARSING -> SET_PARAMETER
Rem                              Add parse_query, _default, _condition
Rem     lbarton    10/31/07  - bug 6051635: domain index on xmltype col
Rem     dgagne     09/20/07  - add function to return new system generated
Rem                            column name
Rem     lbarton    11/21/06  - get_dependent_sxml
Rem     sdavidso   10/18/06  - allow xml version based on metadata version
Rem     sdavidso   09/07/06  - Editions support
Rem     lbarton    06/28/06  - SET_PARSING
Rem     lbarton    10/05/05  - bug 4516042: xmlschemas and SB tables in Data 
Rem                            Pump 
Rem     rapayne    03/01/06  - add COMPARE_* interfaces.
Rem     rapayne    10/24/05  - Bug 4675928: Wrapper for convert_to_canonical
Rem     emagrath   10/10/05  - Rework set_debug args
Rem     lbarton    01/10/05  - Bug 3880999: lob params to fetch_clob function 
Rem     rpfau      10/15/04  - bug 3599656 - public ineterface for check_type. 
Rem     rapayne    10/15/04  - add force_no_encrypt to get_dpstrm_md args
Rem     cmlim      06/21/04  - lbarton: Wrapper for get_canonical_vsn
Rem     htseng     04/02/04  - bug 3464376: add check_match_template  
Rem     lbarton    04/14/04  - Bug 3546038: CONVERT procedure 
Rem     lbarton    01/07/04  - Bug 3358912: force lob big endian 
Rem     lbarton    11/04/03  - network debug 
Rem     lbarton    10/02/03  - Bug 3167541: run domain index metadata code as 
Rem                            cur user 
Rem     lbarton    09/16/03  - Bug 3121396: run procobj code as cur user 
Rem     lbarton    09/16/03  - Bug 3128559: Fix interface to openw 
Rem     dgagne     09/08/03  - add patchtablemetadata to offsets 
Rem     lbarton    08/13/03  - Bug 3082230: define useful constants 
Rem     lbarton    07/28/03  - Bug 3045926: add grantor to offset type
Rem     lbarton    07/03/03  - Bug 3016951: add patch_typeid
Rem     lbarton    06/06/03  - Bug 2849559: report errors from procedural
Rem                            actions
Rem     lbarton    05/12/03  - add network_link param to get_dpstrm_md
Rem     lbarton    04/25/03  - Bug 2924995: remote fetch may not have parse
Rem                            items
Rem     lbarton    04/01/03  - bug 2875448: 2ndary table fix
Rem     lbarton    02/14/03  - fix callouts over dblink
Rem     lbarton    01/23/03  - sort types
Rem     lbarton    01/08/03  - cache obj numbers
Rem     lbarton    12/27/02  - add SET_XMLFORMAT
Rem     gclaborn   01/02/03  - Add new CONVERT and assoc. collection defs.
Rem     gclaborn   12/20/02  - Replace parse_xml_text with network_fetch_parse
Rem     gclaborn   11/10/02  - Change all ku$_parsed_items to IN OUT NOCOPY
Rem     lbarton    10/09/02  - define ku$_multi_ddls
Rem     dgagne     08/28/02  - add support for jdeveloper
Rem     lbarton    09/04/02  - change message number
Rem     lbarton    07/26/02  - new error message
Rem     lbarton    05/24/02  - network mode (3)
Rem     lbarton    05/23/02  - network mode (2)
Rem     lbarton    05/21/02  - network mode
Rem     lbarton    05/17/02  - remove pname param from get_dpstrm_md
Rem     lbarton    04/10/02  - add DPSTREAM_TABLE object
Rem     lbarton    02/06/02  - new 10i infrastructure
Rem     lbarton    11/27/01  - better error messages
Rem     lbarton    10/29/01  - rename ku$_parsed_item.'parent' to 'object_row'
Rem     lbarton    09/05/01  - split pkgs into separate files
Rem     gclaborn   12/20/00  - Add encoding param to ADD_TRANSFORM
Rem     lbarton    11/10/00  - add long2vcnt
Rem     lbarton    09/13/00 -  new exception; disable FETCH_XML variant
Rem     lbarton    08/16/00 -  make dbms_metadata invokers rights
Rem     jdavison   07/25/00 -  Uncomment use of XMLType.
Rem     lbarton    06/12/00 -  facility name change
Rem     lbarton    06/01/00 -  more api changes
Rem     gclaborn   05/23/00 -  Comment out ref. to XMLType until compatible
Rem                            issues fixed.
Rem     gclaborn   05/12/00 -  Reinstate functions returning XMLType since the
Rem                            real one is now checked in.
Rem     lbarton    04/28/00 -  new api
Rem     gclaborn   04/24/00 -  Remove global XMLType definition
Rem     lbarton    03/31/00 -  Add SET_XSL_BASE_DIR
Rem     gclaborn   03/22/00 -  Add procedure interfaces for fetch_xxx
Rem     lbarton    03/09/00 -  Error handling
Rem     lbarton    03/01/00 -  new functions, API changes
Rem     lbarton    12/03/99 -  combine into one package
Rem     gclaborn / lbarton  11/18/99 -  Creation
Rem

-- Types used by the mdAPI interface:
-------------------------------------
-- SET_PARSE_ITEM specifies that an attribute of an object be parsed from
-- the output and returned separately by FETCH_XML, FETCH_DDL or CONVERT.
-- Since multiple items can be parsed, they are returned in a nested table,
-- ku$_parsed_items.

CREATE TYPE sys.ku$_parsed_item AS OBJECT
        (       item            VARCHAR2(30),   -- item to be parsed
                value           VARCHAR2(4000), -- item's value
                object_row      NUMBER          -- object row of item
        )
/
GRANT EXECUTE ON sys.ku$_parsed_item TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_parsed_item FOR sys.ku$_parsed_item;

CREATE TYPE sys.ku$_parsed_items IS TABLE OF sys.ku$_parsed_item;
/
GRANT EXECUTE ON sys.ku$_parsed_items TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_parsed_items FOR sys.ku$_parsed_items;

-- The FETCH_DDL function returns creation DDL for an object.
-- Some database objects require multiple creation DDL statements, e.g.,
-- full types and packages (a header and a body) and tables (create plus alters
-- for constraints). ku$_ddl contains a single DDL statement.
-- ku$_ddls contains all the DDL statements returned by a call to FETCH_DDL.
-- Most object types will have only one row.
-- Each row of ku$_ddls itself contains a ku$_parsed_items nested table
-- for parsed items for that DDL statement.

CREATE TYPE sys.ku$_ddl AS OBJECT
        (       ddltext         CLOB,                   -- The DDL text
                parsedItems     sys.ku$_parsed_items    -- the parsed items
        )
/
GRANT EXECUTE ON sys.ku$_ddl TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ddl FOR sys.ku$_ddl;

CREATE TYPE sys.ku$_ddls IS TABLE OF sys.ku$_ddl;
/
GRANT EXECUTE ON sys.ku$_ddls TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ddls FOR sys.ku$_ddls;

CREATE TYPE sys.ku$_multi_ddl AS OBJECT
        (       object_row      NUMBER,         -- object row of object
                ddls            sys.ku$_ddls    -- 1-N DDLs for the object
        )
/
GRANT EXECUTE ON sys.ku$_multi_ddl TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_multi_ddl FOR sys.ku$_ddl;

CREATE TYPE sys.ku$_multi_ddls IS TABLE OF sys.ku$_multi_ddl;
/
GRANT EXECUTE ON sys.ku$_multi_ddls TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_multi_ddls FOR sys.ku$_multi_ddls;


-- types used by the OPENW/CONVERT/PUT interface

CREATE TYPE sys.ku$_ErrorLine AS OBJECT 
        (       errorNumber     NUMBER,
                errorText       VARCHAR2(2000) )
/
GRANT EXECUTE ON sys.ku$_ErrorLine TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ErrorLine FOR sys.ku$_ErrorLine;
CREATE TYPE sys.ku$_ErrorLines AS TABLE OF sys.ku$_ErrorLine
/
GRANT EXECUTE ON sys.ku$_ErrorLines TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ErrorLines FOR sys.ku$_ErrorLines;
-- Submit result will have the DDL text, error msgs and parsed items so it's
-- easy to see which object had a problem.
CREATE TYPE sys.ku$_SubmitResult AS OBJECT
        (       ddl             sys.ku$_ddl,
                errorLines      sys.ku$_ErrorLines )
/
GRANT EXECUTE ON sys.ku$_SubmitResult TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_SubmitResult FOR sys.ku$_SubmitResult;
CREATE TYPE sys.ku$_SubmitResults AS TABLE OF sys.ku$_SubmitResult
/
GRANT EXECUTE ON sys.ku$_SubmitResults TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_SubmitResults FOR sys.ku$_SubmitResults;

-- ku$_vcnt (vcnt = VarChar2 Nested Table) is used to hold
--  large amounts of text data.
-- It is used for the PLSQL code returned by GET_DOMIDX_METADATA
-- and for LONG values whose length > 4000
-- ku$_vcntbig is the same except each element is 32k. Used in network fetches

CREATE TYPE sys.ku$_vcnt AS TABLE OF VARCHAR2(4000)
/
GRANT EXECUTE ON sys.ku$_vcnt TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_vcnt FOR sys.ku$_vcnt;

CREATE TYPE ku$_ObjNumSet  IS TABLE OF NUMBER;
/
GRANT EXECUTE ON sys.ku$_ObjNumSet TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumSet FOR sys.ku$_ObjNumSet;

CREATE TYPE ku$_ObjNumNam as
 object (obj_num NUMBER,name VARCHAR2(30));
/
GRANT EXECUTE ON sys.ku$_ObjNumNam TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumNam FOR sys.ku$_ObjNumNam;

CREATE TYPE ku$_ObjNumNamSet  IS TABLE OF  ku$_ObjNumNam;
/
GRANT EXECUTE ON sys.ku$_ObjNumNamSet TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumNamSet FOR sys.ku$_ObjNumNamSet;

CREATE TYPE ku$_ObjNumPair  AS OBJECT (
  num1          NUMBER,
  num2          NUMBER
)
/
GRANT EXECUTE ON sys.ku$_ObjNumPair TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumPair FOR sys.ku$_ObjNumPair;
CREATE TYPE ku$_ObjNumPairList  IS TABLE OF ku$_ObjNumPair
/
GRANT EXECUTE ON sys.ku$_ObjNumPairList TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_ObjNumPairList
 FOR sys.ku$_ObjNumPairList;

-- UDTs for procedural objects/actions
-- sys.ku$_procobj_loc:
--  newblock    -  0 = line_of_code continues the current block
--                -2 = append line_of_code to previous line
--                 1 = end previous PL/SQL block, start a new block
--  line_of_code-  A line of PL/SQL code
-- sys.ku$_procobj_locs:
--  a nested table of the above
-- sys.ku$_procobj_line (name retained for historical reasons):
--  locs        -  a sys.ku$_procobj_locs object containing some lines of
--                  PLSQL code; these constitute a single anonymous PLSQL
--                  block; a COMMIT will be inserted at the end
--  grantor     -  non-null: the user to connect to before executing
--                  the PLSQL block
-- sys.ku$_procobj_lines:
--  a nested table of the above

CREATE TYPE sys.ku$_procobj_loc AS OBJECT
        (       newblock        NUMBER,
                line_of_code    VARCHAR2(32767) )
/
GRANT EXECUTE ON sys.ku$_procobj_loc TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_procobj_loc FOR sys.ku$_procobj_loc;

CREATE TYPE sys.ku$_procobj_locs AS TABLE OF sys.ku$_procobj_loc
/
GRANT EXECUTE ON sys.ku$_procobj_locs TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_procobj_locs FOR sys.ku$_procobj_locs;

CREATE TYPE sys.ku$_procobj_line AS OBJECT
        (       grantor         VARCHAR2(30),
                locs            sys.ku$_procobj_locs )
/
GRANT EXECUTE ON sys.ku$_procobj_line TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_procobj_line FOR sys.ku$_procobj_line;

CREATE TYPE sys.ku$_procobj_lines AS TABLE OF sys.ku$_procobj_line
/
GRANT EXECUTE ON sys.ku$_procobj_lines TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_procobj_lines FOR sys.ku$_procobj_lines;

-- UDTs for Java

CREATE TYPE sys.ku$_chunk_t AS OBJECT
(
  text  varchar2(4000),
  length        number
)
/
GRANT EXECUTE ON sys.ku$_chunk_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_chunk_t FOR sys.ku$_chunk_t;

CREATE TYPE sys.ku$_chunk_list_t IS TABLE OF sys.ku$_chunk_t
/ 
GRANT EXECUTE ON sys.ku$_chunk_list_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_chunk_list_t FOR sys.ku$_chunk_list_t;

CREATE TYPE sys.ku$_java_t AS OBJECT
(
  type_num              number,
  flags                 number,
  properties            number,
  raw_chunk_count       number,
  total_raw_byte_count  number, 
  text_chunk_count      number,
  total_text_byte_count number,
  raw_chunk             sys.ku$_chunk_list_t,
  text_chunk            sys.ku$_chunk_list_t
)
/
GRANT EXECUTE ON sys.ku$_java_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_java_t FOR sys.ku$_java_t;

-- UDTs for pre/post-table action code

CREATE TYPE sys.ku$_taction_t AS OBJECT
(
  text  varchar2(4000)
)
/
GRANT EXECUTE ON sys.ku$_taction_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_taction_t FOR sys.ku$_taction_t;

CREATE TYPE sys.ku$_taction_list_t IS TABLE OF sys.ku$_taction_t
/ 
GRANT EXECUTE ON sys.ku$_taction_list_t TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM ku$_taction_list_t FOR sys.ku$_taction_list_t;

CREATE OR REPLACE PACKAGE dbms_metadata AUTHID CURRENT_USER AS 
---------------------------------------------------------------------
-- Overview
-- This pkg implements the mdAPI, a means to retrieve the aggregated
-- definitions of database objects as either XML docs. or their creation DDL,
-- or to submit the XML documents to execute the DDL.
---------------------------------------------------------------------
-- SECURITY
-- This package is owned by SYS with execute access granted to PUBLIC.
-- It runs with invokers rights, i.e., with the security profile of
-- the caller.  It calls DBMS_METADATA_INT to perform privileged
-- functions.
-- The object views defined in catmeta.sql implement the package's security
-- policy via the WHERE clause on the public views which include syntax to
-- control user access to metadata: if the current user is SYS or has
-- SELECT_CATALOG_ROLE, then all objects are visible; otherwise, only
-- objects in the schema of the current user are visible.

--------------------
--  PUBLIC CONSTANTS
--
  SESSION_TRANSFORM     CONSTANT BINARY_INTEGER := -1;
  SESSION_HANDLE        CONSTANT BINARY_INTEGER := -1;

  MAX_PROCOBJ_RETLEN    CONSTANT BINARY_INTEGER := 32767;
  NEWBLOCK_CONTINUE     CONSTANT NUMBER         := 0;
  NEWBLOCK_BEGIN        CONSTANT NUMBER         := 1;
  NEWBLOCK_APPEND       CONSTANT NUMBER         := -2;

  MARKER_PRE_SYSTEM     CONSTANT NUMBER         := 1;
  MARKER_PRE_SCHEMA     CONSTANT NUMBER         := 2;
  MARKER_PRE_INSTANCE   CONSTANT NUMBER         := 3;
  MARKER_POST_SYSTEM    CONSTANT NUMBER         := 4;
  MARKER_POST_SCHEMA    CONSTANT NUMBER         := 5;
  MARKER_EARLY_POST_INSTANCE  
                        CONSTANT NUMBER         := 6;
  MARKER_NORMAL_POST_INSTANCE  
                        CONSTANT NUMBER         := 8;
  MARKER_POST_INSTANCE  CONSTANT NUMBER         := 7;
  MARKER_FINAL_POST_INSTANCE  
                        CONSTANT NUMBER         := 7;

-- The following types are used in the 'fast convert' interface that returns
-- a single CLOB and collection consisting of a pointer/length for the DDL
-- returning a fixed set of parse items for each. (as opposed to the
-- interface which returns N CLOBs... less efficient). There is a parallel
-- between these PL/SQL types and the ku$_ddl* / _multi_ddl* types defined
-- above; except thie improves performance, atthe cost of flexibility.

-- 
-- This is only intended for use by datapump (worker).

--------------------
--  PUBLIC PL/SQL TYPE DEFINITIONS
--
TYPE offset IS RECORD
        (       pos                     PLS_INTEGER,-- of DDL in the returned clob
                len                     PLS_INTEGER,
                grantor                 VARCHAR2(30),-- grantor parse item for procedural grants
                bind_pattern            VARCHAR2(30),
                alt_connect_type        VARCHAR2(4),
                has_virtual_columns     VARCHAR2(30),
                has_tstz_cols           VARCHAR2(30),
                type_alter_type_cnt     VARCHAR2(30),
                dblpwx                  VARCHAR2(256),
                dblapwx                  VARCHAR2(256),
                no_table_lock    VARCHAR2(30)          -- 'Y' if table locks should be disabled
         );

TYPE objddl IS TABLE OF offset INDEX BY BINARY_INTEGER;

TYPE T_VAR_COLL IS TABLE OF VARCHAR2(60) INDEX BY BINARY_INTEGER;

TYPE multiobjects IS TABLE OF objddl INDEX BY BINARY_INTEGER;

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

  sql_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(sql_error, -31642);
    sql_error_num NUMBER := -31642;
-- "the following SQL statement failed: %s"
-- *Cause:  An internal error was generated from package DBMS_METADATA.
-- *Action: Call Oracle Support.

  dbmsjava_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(dbmsjava_error, -39128);
    dbmsjava_error_num NUMBER := -39128;
-- "Unexpected DbmsJava error %d from statement %s"
-- *Cause:  The error was returned from a call to a DbmsJava procedure.
-- *Action: Record the accompanying messages and report this as a Data Pump
--          internal error to customer support. 

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
--      network_link    - The name of a database link to the database
--              whose data is to be retrieved.  If NULL (default), metadata
--              is retrieved from the database on which the caller is running.
--
-- RETURNS:
--      A handle to be used in subsequent calls to SET_FILTER, SET_COUNT,
--      ADD_TRANSFORM, GET_QUERY, SET_PARSE_ITEM, FETCH_xxx and CLOSE.
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.

  FUNCTION open (
                object_type     IN  VARCHAR2,
                version         IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model           IN  VARCHAR2 DEFAULT 'ORACLE',
                network_link    IN  VARCHAR2 DEFAULT NULL)
        RETURN NUMBER;

-- SET_FILTER: Specifies restrictions on the objects whose metadata 
--      is to be retrieved.
--      This function is overloaded: the filter value can be a varchar2,
--      number or boolean.
-- PARAMETERS:
--      handle          - Context handle from previous OPEN call.
--      name            - Name of the filter.
--      value           - Value of the filter.
--      object_type_path- Path name of object types to which
--                        the filter applies.

  PROCEDURE set_filter (
                handle                  IN  NUMBER,
                name                    IN  VARCHAR2,
                value                   IN  VARCHAR2,
                object_type_path        IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE set_filter (
                handle                  IN  NUMBER,
                name                    IN  VARCHAR2,
                value                   IN  BOOLEAN DEFAULT TRUE,
                object_type_path        IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE set_filter (
                handle                  IN  NUMBER,
                name                    IN  VARCHAR2,
                value                   IN  NUMBER,
                object_type_path        IN  VARCHAR2 DEFAULT NULL);


-- SET_COUNT: Specifies the number of objects to be returned in a single
--      FETCH_xxx call.
-- PARAMETERS:
--      handle          - Context handle from previous OPEN call.
--      value           - Number of objects to retrieve.
--      object_type_path- Path name of object types to which
--                        the count applies.

  PROCEDURE set_count (
                handle                  IN  NUMBER,
                value                   IN  NUMBER,
                object_type_path        IN  VARCHAR2 DEFAULT NULL);


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


-- SET_PARAMETER: Specify parameter values which affect the operation.
-- PARAMETERS:
--      handle          - Context handle from previous OPEN call.
--      name            - Name of the parameter.
--      value           - Value of the parameter.

  PROCEDURE set_parameter (
                handle                  IN  NUMBER,
                name                    IN  VARCHAR2,
                value                   IN  BOOLEAN DEFAULT TRUE);


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
--              of objects processed by FETCH_xxx, CONVERT or PUT.
-- PARAMETERS:  handle  - Context handle from previous OPEN or OPENW call.
--              name    - The name of the transform: Can be 'DDL' to generate
--                        creation DDL or a URI pointing to a stylesheet,
--                        either external or internal to the DB (the latter
--                        being an Xpath spec. starting with '/oradb').
--              encoding- If name is a URI, this specifies the encoding of the
--                        target stylesheet. If left NULL, then if uri starts
--                        with  '/oradb', then the database char. set is used;
--                        otherwise, 'UTF-8'. Use 'US-ASCII' for better perf.
--                        if you can. May be any valid NLS char. set name.
--                        Ignored if name is an internal transform name (like
--                        DDL), not a URI.
--              object_type- Object type to which the transform applies.
--
-- NOTE: If name is an intra-DB uri (ie, /oradb) that points to an NCLOB
--       column or a CLOB with an encoding different from the database charset,
--       you must explicitly specify the encoding.
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
--      a number or a boolean.
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
                value                   IN  BOOLEAN DEFAULT TRUE,
                object_type             IN  VARCHAR2 DEFAULT NULL);

  PROCEDURE set_transform_param (
                transform_handle        IN  NUMBER,
                name                    IN  VARCHAR2,
                value                   IN  NUMBER,
                object_type             IN  VARCHAR2 DEFAULT NULL);

-- SET_REMAP_PARAM: Specifies a value for a parameter to the XSL-T
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

-- FETCH_XML:   Return metadata for objects as XML documents. This version
--              can return multiple objects per call (when the SET_COUNT
--              'value' parameter > 1).
-- PARAMETERS:  handle  - Context handle from previous OPEN call.
-- RETURNS:     XML metadata for the objects as an XMLType, or NULL if all
--              objects have been fetched.
-- EXCEPTIONS:  Throws an exception if DDL transform has been added

  FUNCTION fetch_xml (handle    IN NUMBER)
        RETURN sys.XMLType;


-- FETCH_DDL:   Return metadata as DDL.
--              More than one DDL statement may be returned.
-- RETURNS:     Metadata for the objects as one or more DDL statements
-- PARAMETERS:  handle  - Context handle from previous OPEN call.
-- EXCEPTIONS:  Throws an exception if DDL transform was not added.

  FUNCTION fetch_ddl (
                handle  IN NUMBER)
        RETURN sys.ku$_ddls;


--************* TEMPORARY ************************
-- FETCH_DDL_TEXT: Return DDL metadata as VARCHAR2.
--              NOTE: This is a temporary API for logical standby.
--              It is needed because LOBs and objects cannot
--              currently (8.2) be returned over dblinks.
-- RETURNS:     Metadata for the object as one DDL statement
-- PARAMETERS:  handle  - Context handle from previous OPEN call.
--              partial - set to 1 if the statement was too long
--                      to fit in the VARCHAR2; the next call will
--                      return the next piece of the metadata.
-- EXCEPTIONS:  Throws an exception if DDL transform was not added.

  FUNCTION fetch_ddl_text (
                handle  IN  NUMBER,
                partial OUT NUMBER)
        RETURN VARCHAR2;
--************* TEMPORARY ************************


-- FETCH_CLOB:  Return metadata for object (transformed or not) as a CLOB.
-- PARAMETERS:  handle  - Context handle from previous OPEN call.
--              cache_lob - TRUE = read LOB into buffer cache
--              lob_duration - either DBMS_LOB.SESSION (default)
--                or DBMS_LOB.CALL, the duration for the termporary lob
-- RETURNS:     XML metadata for the objects as a CLOB, or NULL if all
--              objects have been fetched.

  FUNCTION fetch_clob (handle       IN NUMBER,
                       cache_lob    IN BOOLEAN DEFAULT TRUE,
                       lob_duration IN PLS_INTEGER DEFAULT DBMS_LOB.SESSION)
        RETURN CLOB;


-- PROCEDURE FETCH_CLOB: Same as above but with IN/OUT NOCOPY CLOB. CLOB
--              must be pre-created prior to call.
-- PARAMETERS:	handle- (IN) Context handle from previous OPENC call.
--              xmldoc - (IN OUT) previously allocated CLOB to hold the
--                       returned diff document.

  PROCEDURE fetch_clob (
                handle  IN NUMBER,
                xmldoc  IN OUT NOCOPY CLOB);

-- NETWORK_OPEN: Do OPEN over network; negotiate protocol version
--               This function is called by the local server and
--               runs in the remote server.
-- PARAMETERS:
--      object_type     - See 'OPEN'
--      version         - See 'OPEN'
--      model           - See 'OPEN'
--      client_version  - The highest protocol version understood by
--                        the caller.
--      protocol_version- The protocol version to be used in this session.
--                        NETWORK_OPEN picks the highest protocol version
--                        understood by both itself and the caller.
--
-- RETURNS:
--      A handle to be used in subsequent calls to SET_FILTER, SET_COUNT,
--      ADD_TRANSFORM, GET_QUERY, SET_PARSE_ITEM, FETCH_xxx and CLOSE.
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.

  FUNCTION network_open (
                object_type      IN  VARCHAR2,
                version          IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model            IN  VARCHAR2 DEFAULT 'ORACLE',
                client_version   IN  NUMBER,
                protocol_version OUT NUMBER)
        RETURN NUMBER;

-- NETWORK_CALLOUTS: Execute callouts on remote instance
--    (These can't execute in the context of a remote function.)
-- PARAMETERS:  handle       - Context handle from previous OPEN call.

  PROCEDURE network_callouts (
                handle          IN  NUMBER );

-- NETWORK_FETCH_CLOB: Return metadata as VARCHAR2.
-- RETURNS:     Metadata for the object
-- PARAMETERS:  handle       - Context handle from previous OPEN call.
--              do_xsl_parse - 1 = do parse the XSL way
--              partial      - set to 1 if the statement was too long
--                      to fit in the VARCHAR2; the next call will
--                      return the next piece of the metadata.
--              parse_delim  - the parse delimiter
--              do_callout   - set to 1 if the next action is a callout
--                             0 otherwise
--              have_errors  - set to 1 if procedural object/action code
--                             raised an exception that should be fetched
--                             0 otherwise

  FUNCTION network_fetch_clob (
                handle          IN  NUMBER,
                do_xsl_parse    IN  NUMBER,
                partial         OUT NUMBER,
                parse_delim     OUT VARCHAR2,
                do_callout      OUT NUMBER,
                have_errors     OUT NUMBER)
        RETURN VARCHAR2;

-- NETWORK_FETCH_ERRORS: Serializes a ku$_vcnt into a VARCHAR2 for
--              network operations. (modeled on NETWORK_FETCH_PARSE, below)
-- RETURNS:     VARCHAR2: A delimited series of error string
-- PARAMETERS:  handle   - Context handle from previous OPEN call.
--              cnt      - Number of errors returned this iteration
--              partial  - set to 1 if there's more to come
--              seqno    - Seq. number for current member of heterogeneous obj.
--              path     - Path for current member of heterogeneous obj.
--
-- IMPLICIT INPUTS: pkg-scoped parse_pattern established by network_fetch_clob

  FUNCTION network_fetch_errors (
                handle          IN  NUMBER,
                cnt             OUT NUMBER,
                partial         OUT NUMBER,
                seqno           OUT NUMBER,
                path            OUT VARCHAR2)
        RETURN VARCHAR2;

-- NETWORK_FETCH_PARSE: Serializes a ku$_parsed_items into a VARCHAR2 for
--              network operations.
-- RETURNS:     varchar2 is a delimited series of ku$_parsed_item attributes
-- PARAMETERS:  handle   - Context handle from previous OPEN call.
--              cnt      - Number of parse items returned this iteration
--              partial  - set to 1 if there's more to come
--              seqno    - Seq. number for current member of heterogeneous obj.
--              path     - Path for current member of heterogeneous obj.

  FUNCTION network_fetch_parse (
                handle          IN  NUMBER,
                cnt             OUT NUMBER,
                partial         OUT NUMBER,
                seqno           OUT NUMBER,
                path            OUT VARCHAR2)
        RETURN VARCHAR2;

---------------------------------------------------------------------
-- FETCH_XML_CLOB:      Procedure variant with IN/OUT NOCOPY CLOB.
--              Also returns nested table of parsed items, object type path.
-- PARAMETERS:  handle  - Context handle from previous OPEN call.
--              doc - XML metadata for the objects or NULL if all
--                objects have been fetched.
--              parsed_items - Table of parsed items.
--              object_type_path - for heterogeneous object types the full
--                path name of the object type for the object(s) returned;
--                NULL if handle is for a homogeneous object type
--              seqno - for heterogeneous object types the sequence
--                number of the object type in the heterogeneous collection;
--                NULL if handle is for a homogeneous object type
--              procobj_errors - nested table of varchar2 - each entry
--                contains an exception raised by procedural action code.
--                NULL if no exceptions raised
-- EXCEPTIONS:  Throws an exception if DDL transform has been added.

  PROCEDURE fetch_xml_clob (
                handle                  IN  NUMBER,
                doc                     IN OUT NOCOPY CLOB,
                parsed_items            IN OUT NOCOPY sys.ku$_parsed_items,
                object_type_path        OUT VARCHAR2);

  PROCEDURE fetch_xml_clob (
                handle                  IN  NUMBER,
                doc                     IN OUT NOCOPY CLOB,
                parsed_items            IN OUT NOCOPY sys.ku$_parsed_items,
                object_type_path        OUT VARCHAR2,
                seqno                   OUT NUMBER,
                procobj_errors          OUT sys.ku$_vcnt);

-- CLOSE:       Cleanup all context associated with handle.
-- PARAMETERS:  handle  - Context handle from previous OPEN call.

  PROCEDURE CLOSE (handle IN NUMBER);


-- GET_XML:     Return the metadata for a single object as XML.
--      This interface is meant for casual browsing (e.g., from SQLPlus)
--      vs. the programmatic OPEN / FETCH / CLOSE interfaces above.
-- PARAMETERS:
--      object_type     - The type of object to be retrieved.
--      name            - Name of the object.
--      schema          - Schema containing the object.  Defaults to
--                        the caller's schema.
--      version         - The version of the objects' metadata.
--      model           - The object model for the metadata.
--      transform       - XSL-T transform to be applied.
-- RETURNS:     Metadata for the object as an NCLOB.

  FUNCTION get_xml (
                object_type     IN  VARCHAR2,
                name            IN  VARCHAR2,
                schema          IN  VARCHAR2 DEFAULT NULL,
                version         IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model           IN  VARCHAR2 DEFAULT 'ORACLE',
                transform       IN  VARCHAR2 DEFAULT NULL)
        RETURN CLOB;


-- GET_SXML:     Return the metadata for a single object as SXML.
--      This interface is meant for casual browsing (e.g., from SQLPlus)
--      vs. the programmatic OPEN / FETCH / CLOSE interfaces above.
-- PARAMETERS:
--      object_type     - The type of object to be retrieved.
--      name            - Name of the object.
--      schema          - Schema containing the object.  Defaults to
--                        the caller's schema.
--      version         - The version of the objects' metadata.
--      model           - The object model for the metadata.
--      transform       - XSL-T transform to be applied.
-- RETURNS:     Metadata for the object transformed to SXML as a CLOB.

  FUNCTION get_sxml (
                object_type     IN  VARCHAR2,
                name            IN  VARCHAR2,
                schema          IN  VARCHAR2 DEFAULT NULL,
                version         IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model           IN  VARCHAR2 DEFAULT 'ORACLE',
                transform       IN  VARCHAR2 DEFAULT 'SXML')
        RETURN CLOB;

-- GET_SXML_DDL:     Return the metadata for a single object, convert it
--      to SXML, then convert the SXML to DDL.
--      Used for testing the SXML and SXMLDDL transforms.
-- PARAMETERS:
--      object_type     - The type of object to be retrieved.
--      name            - Name of the object.
--      schema          - Schema containing the object.  Defaults to
--                        the caller's schema.
--      version         - The version of the objects' metadata.
--      model           - The object model for the metadata.
--      transform       - XSL-T transform to be applied.
-- RETURNS:     Metadata for the object transformed to SXML, then DDL,
--               as a CLOB.

  FUNCTION get_sxml_ddl (
                object_type     IN  VARCHAR2,
                name            IN  VARCHAR2,
                schema          IN  VARCHAR2 DEFAULT NULL,
                version         IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model           IN  VARCHAR2 DEFAULT 'ORACLE',
                transform       IN  VARCHAR2 DEFAULT 'SXMLDDL')
        RETURN CLOB;

-- GET_DDL:     Return the metadata for a single object as DDL.
--      This interface is meant for casual browsing (e.g., from SQLPlus)
--      vs. the programmatic OPEN / FETCH / CLOSE interfaces above.
-- PARAMETERS:
--      object_type     - The type of object to be retrieved.
--      name            - Name of the object.
--      schema          - Schema containing the object.  Defaults to
--                        the caller's schema.
--      version         - The version of the objects' metadata.
--      model           - The object model for the metadata.
--      transform       - XSL-T transform to be applied.
-- RETURNS:     Metadata for the object transformed to DDL as a CLOB.

  FUNCTION get_ddl (
                object_type     IN  VARCHAR2,
                name            IN  VARCHAR2,
                schema          IN  VARCHAR2 DEFAULT NULL,
                version         IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model           IN  VARCHAR2 DEFAULT 'ORACLE',
                transform       IN  VARCHAR2 DEFAULT 'DDL')
        RETURN CLOB;

-- GET_DEPENDENT_XML:   Return the metadata for objects dependent on a
--      base object as XML.
--      This interface is meant for casual browsing (e.g., from SQLPlus)
--      vs. the programmatic OPEN / FETCH / CLOSE interfaces above.
-- PARAMETERS:
--      object_type     - The type of object to be retrieved.
--      base_object_name- Name of the base object.
--      base_object_schema- Schema containing the base object.  Defaults to
--                        the caller's schema.
--      version         - The version of the objects' metadata.
--      model           - The object model for the metadata.
--      transform       - XSL-T transform to be applied.
--      object_count    - maximum number of objects to return
-- RETURNS:     Metadata for the object as a CLOB.

  FUNCTION get_dependent_xml (
                object_type             IN  VARCHAR2,
                base_object_name        IN  VARCHAR2,
                base_object_schema      IN  VARCHAR2 DEFAULT NULL,
                version                 IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model                   IN  VARCHAR2 DEFAULT 'ORACLE',
                transform               IN  VARCHAR2 DEFAULT NULL,
                object_count            IN  NUMBER   DEFAULT 10000)
        RETURN CLOB;

-- GET_DEPENDENT_SXML:   Return the metadata for objects dependent on a
--      base object as XML.
--      This interface is meant for casual browsing (e.g., from SQLPlus)
--      vs. the programmatic OPEN / FETCH / CLOSE interfaces above.
-- PARAMETERS:
--      object_type     - The type of object to be retrieved.
--      base_object_name- Name of the base object.
--      base_object_schema- Schema containing the base object.  Defaults to
--                        the caller's schema.
--      version         - The version of the objects' metadata.
--      model           - The object model for the metadata.
--      transform       - XSL-T transform to be applied.
--      object_count    - maximum number of objects to return
-- RETURNS:     Metadata for the object as a CLOB.

  FUNCTION get_dependent_sxml (
                object_type             IN  VARCHAR2,
                base_object_name        IN  VARCHAR2,
                base_object_schema      IN  VARCHAR2 DEFAULT NULL,
                version                 IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model                   IN  VARCHAR2 DEFAULT 'ORACLE',
                transform               IN  VARCHAR2 DEFAULT 'SXML',
                object_count            IN  NUMBER   DEFAULT 10000)
        RETURN CLOB;

-- GET_DEPENDENT_DDL:   Return the metadata for objects dependent on a
--      base object as DDL.
--      This interface is meant for casual browsing (e.g., from SQLPlus)
--      vs. the programmatic OPEN / FETCH / CLOSE interfaces above.
-- PARAMETERS:
--      object_type     - The type of object to be retrieved.
--      base_object_name- Name of the base object.
--      base_object_schema- Schema containing the base object.  Defaults to
--                        the caller's schema.
--      version         - The version of the objects' metadata.
--      model           - The object model for the metadata.
--      transform       - XSL-T transform to be applied.
--      object_count    - maximum number of objects to return
-- RETURNS:     Metadata for the object as a CLOB.

  FUNCTION get_dependent_ddl (
                object_type             IN  VARCHAR2,
                base_object_name        IN  VARCHAR2,
                base_object_schema      IN  VARCHAR2 DEFAULT NULL,
                version                 IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model                   IN  VARCHAR2 DEFAULT 'ORACLE',
                transform               IN  VARCHAR2 DEFAULT 'DDL',
                object_count            IN  NUMBER   DEFAULT 10000)
        RETURN CLOB;

-- GET_GRANTED_XML:     Return the metadata for objects granted to a
--      grantee as XML.
--      This interface is meant for casual browsing (e.g., from SQLPlus)
--      vs. the programmatic OPEN / FETCH / CLOSE interfaces above.
-- PARAMETERS:
--      object_type     - The type of object to be retrieved.
--      grantee         - Name of the grantee.
--      version         - The version of the objects' metadata.
--      model           - The object model for the metadata.
--      transform       - XSL-T transform to be applied.
--      object_count    - maximum number of objects to return
-- RETURNS:     Metadata for the object as a CLOB.

  FUNCTION get_granted_xml (
                object_type     IN  VARCHAR2,
                grantee         IN  VARCHAR2 DEFAULT NULL,
                version         IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model           IN  VARCHAR2 DEFAULT 'ORACLE',
                transform       IN  VARCHAR2 DEFAULT NULL,
                object_count    IN  NUMBER   DEFAULT 10000)
        RETURN CLOB;

-- GET_GRANTED_DDL:     Return the metadata for objects granted to a
--      grantee as DDL.
--      This interface is meant for casual browsing (e.g., from SQLPlus)
--      vs. the programmatic OPEN / FETCH / CLOSE interfaces above.
-- PARAMETERS:
--      object_type     - The type of object to be retrieved.
--      grantee         - Name of the grantee.
--      version         - The version of the objects' metadata.
--      model           - The object model for the metadata.
--      transform       - XSL-T transform to be applied.
--      object_count    - maximum number of objects to return
-- RETURNS:     Metadata for the object as a CLOB.

  FUNCTION get_granted_ddl (
                object_type     IN  VARCHAR2,
                grantee         IN  VARCHAR2 DEFAULT NULL,
                version         IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model           IN  VARCHAR2 DEFAULT 'ORACLE',
                transform       IN  VARCHAR2 DEFAULT 'DDL',
                object_count    IN  NUMBER   DEFAULT 10000)
        RETURN CLOB;

-- GET_DPSTRM_MD: Retrieve stream (i.e., table) metadata 
--      for DataPump data layer.
-- PARAMETERS:
--      schema - the table's schema
--      name   - the table's name
--      mdversion - the version of metadata to be extracted, one of
--                      - COMPATIBLE (default) - version of metadata
--                              corresponds to database compatibility level
--                      - LATEST - corresponds to database version
--                      - a specific database version
--      dpapiversion - the direct path API version (this value is stored
--                      in the returned XML document)
--      doc    - An XML document containing the stream metadata
--               for the table/partition.
--      network_link    - The name of a database link to the database
--              whose data is to be retrieved.  If NULL (default), metadata
--              is retrieved from the database on which the caller is running.
--      force_lob_be - if TRUE, clear bit 0x0200 of 
--              COL_LIST/COL_LIST_ITEM/LOB_PROPERTY, i.e., force the metadata
--              to make the lob appear big endian.
--      force_no_encrypt - if TRUE, clear encryption bits in col$ properties:
--              0x04000000 =  67108864 = Column is encrypted
--              0x20000000 = 536870912 = Column is encrypted without salt 
--              This is necessary when users do not specify an 
--              encryption_password and the data is written to the dumpfile 
--              in clear text although the col properity retains the 
--              encrypt property.
  PROCEDURE get_dpstrm_md (
                schema          IN VARCHAR2,
                name            IN VARCHAR2,
                mdversion       IN VARCHAR2 DEFAULT 'COMPATIBLE',
                dpapiversion    IN NUMBER DEFAULT 3,
                doc             IN OUT NOCOPY CLOB,
                network_link    IN VARCHAR2 DEFAULT NULL,
                force_lob_be    IN BOOLEAN DEFAULT FALSE,
                force_no_encrypt IN BOOLEAN DEFAULT FALSE);

-- GET_VAT_TABLE_NAME
-- PARAMETERS:
--	schema - the view schema
--	name   - the view name
--      network_link    - The name of a database link to the database
--              whose data is to be retrieved.  If NULL (default), metadata
--              is retrieved from the database on which the caller is running.
-- RETURNS
--      table name

  FUNCTION get_vat_table_name (
		schema		IN VARCHAR2,
		name		IN VARCHAR2,
		network_link	IN VARCHAR2 DEFAULT NULL ) 
	RETURN VARCHAR2;

-- SET_VAT_TABLE_NAME
-- PARAMETERS:
--	schema - the view schema
--	vname  - the view name
--	tname  - the template table name

  PROCEDURE set_vat_table_name (
		schema		IN VARCHAR2,
		vname		IN VARCHAR2,
		tname		IN VARCHAR2 );

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

-- NET_SET_DEBUG: Set the internal debug switch on a remote node.
--   This function is called by the local server and runs on the
--   remote server.
-- PARAMETERS:
--      on_off          - new switch state: 0 = OFF, non-0 = ON.

  PROCEDURE net_set_debug(
                on_off          IN NUMBER);

-- FREE_CONTEXT_ENTRY: free the entry in context_list corresponding to 'ind'
--              Should only be called by pkg. dbms_metadata_int.
-- PARAMETERS:
--      ind             - index of entry to free

  PROCEDURE free_context_entry (
                ind             IN  NUMBER );


-- FETCH_OBJNUMS: Table function to return object numbers
-- PARAMETERS:
--      handle          - handle returned from open
--      table_type      - one of 'T' (return objnums for base tables),
--                         'N' (for nested tables), 'X' (for nested tables
--                         that are part of OR storage for XMLType)

  FUNCTION FETCH_OBJNUMS (
                handle                  IN  NUMBER )
        RETURN sys.ku$_ObjNumSet pipelined;

  FUNCTION FETCH_OBJNUMS
        RETURN sys.ku$_ObjNumSet pipelined;

  FUNCTION FETCH_OBJNUMS (
                table_type               IN  VARCHAR2 )
        RETURN sys.ku$_ObjNumSet pipelined;

-- FETCH_OBJNUMS_NAMES: Table function to return object numbers and names
-- IMPLICIT PARAMETER: <current handle>

  FUNCTION FETCH_OBJNUMS_NAMES
        RETURN sys.ku$_ObjNumNamSet pipelined;

-- FETCH_SORTED_OBJNUMS: Table function to return nested table of
--       obj#-order pairs
-- PARAMETERS:
--      handle          - handle returned from open

  FUNCTION FETCH_SORTED_OBJNUMS (
                handle                  IN  NUMBER )
        RETURN sys.ku$_ObjNumPairList;


-- GET_DOMIDX_METADATA: Get PLSQL code from the ODCIIndexGetMetadata
-- method of a domain index's implementation type.
-- PARAMETERS:
--      index_name      - name of the domain index
--      index_schema    - schema of the domain index
--      type_name       - name of the index's implementation type
--      type_schema     - schema of the index's implementation type
--      ts_num          - tablespace where index resides
--                      may be 1 of several, but closure should assure
--                      all tablespaces are transprotable (or not)
--      itinter_version - Interface version of the index's implementation type
--      flags           - flags
-- RETURNS:     Collection of VARCHAR2 containing a PL/SQL block
--      that creates the index metadata.

  FUNCTION get_domidx_metadata(
                index_name      IN  VARCHAR2,
                index_schema    IN  VARCHAR2,
                type_name       IN  VARCHAR2,
                type_schema     IN  VARCHAR2,
                ts_num          IN  NUMBER,
                itinter_version IN  NUMBER,
                flags           IN  NUMBER)
        RETURN sys.ku$_procobj_lines;

-- OKTOEXP_2NDARY_TABLE: Should a secondary object of a domain index
-- be exported?
-- PARAMETERS:
--      tab_obj_num     - object number of the secondary table
-- RETURNS:     TRUE = yes, export it

  FUNCTION oktoexp_2ndary_table (
                tab_obj_num     IN  NUMBER)
        RETURN PLS_INTEGER;

-- PATCH_TYPEID: For transportable import, modify a type's typeid.
-- PARAMETERS:
--      schema   - the type's schema
--      name     - the type's name
--      typeid   - the type's typeid
--      hashcode - the type's hashcode

  PROCEDURE patch_typeid (
                schema          IN VARCHAR2,
                name            IN VARCHAR2,
                typeid          IN VARCHAR2,
                hashcode        IN VARCHAR2);

-- CHECK_TYPE: For transportable import, check a type's defintion and
--             typeid for a match against the one from the export source.
-- PARAMS:
--      schema     - schema of type
--      type_name  - type name
--      version    - internal stored verson of type
--      hashcode   - hashcode of the type defn
--      typeid     - subtype typeid ('' if no subtypes)
-- RETURNS: Nothing, returns if the hashcode and version match. Raises an
--          nnn exception if the type does not exist in the db or if the
--          type exists but the hash code and/or the version number does 
--          not match.
--          
PROCEDURE check_type    (schema     IN VARCHAR2,
                         type_name  IN VARCHAR2,
                         version    IN VARCHAR2,
                         hashcode   IN VARCHAR2,
		         typeid     IN VARCHAR2);


-- GET_HASHCODE: Upgrade from 817 corrupts the hashcode in type$,
--   so we have to get it by calling kotgHashCode.
--   This function calls utl_cxml.getHashCode which calls into kux.c.
-- PARAMS:
--      schema          - type schema
--      typename        - type name
-- RETURNS:
--      hashcode        - returned hashcode

 FUNCTION get_hashcode (schema   IN  VARCHAR2,
                       typename IN  VARCHAR2) RETURN RAW;


-- GET_SYSPRIVS   
--      Get the export string from call grant_sysprivs_exp 
--      and audit_sysprivs_exp function of a package in exppkgobj$
-- PARAMETERS:   
--      package     -- package name 
--      pkg_schema  -- schema of package
--      function    -- function name(audit_sysprivs_exp or grant_sysprivs_exp) 
-- RETURNS:     system_info export string 

  FUNCTION get_sysprivs( 
                package         IN  VARCHAR2,
                pkg_schema      IN  VARCHAR2,
                function        IN  VARCHAR2)
        RETURN sys.ku$_procobj_lines;

-----------------------------------------------------------------------
-- GET_PROCOBJ  
--   Get the export string from call create_exp or audit_exp or grant_exp
--   function of package in exppkobj$
-- PARAMETERS:   
--      package     -- package name 
--      pkg_schema  -- schema of package
--      function    -- function name (create_exp or audit_exp or grant_exp) 
--      objid       -- object number
--      isdba       -- 1: is dba
-- RETURNS:     create/audit/grant export string 

  FUNCTION get_procobj( 
                package         IN  VARCHAR2,
                pkg_schema      IN  VARCHAR2,
                function        IN  VARCHAR2,
                objid           IN  NUMBER,
                isdba           IN  PLS_INTEGER
                )
        RETURN sys.ku$_procobj_lines;
-----------------------------------------------------------------------
-- GET_PROCOBJ_GRANT    
--   Get the export string from call grant_exp function of package in exppkobj$
-- PARAMETERS:   
--      package     -- package name 
--      pkg_schema  -- schema of package
--      function    -- function name (grant_exp) 
--      objid       -- object number
--      isdba       -- 1: is dba
-- RETURNS:     create/audit/grant export string 

  FUNCTION get_procobj_grant( 
                package         IN  VARCHAR2,
                pkg_schema      IN  VARCHAR2,
                function        IN  VARCHAR2,
                objid           IN   NUMBER,
                isdba           IN   PLS_INTEGER
                )
        RETURN sys.ku$_procobj_lines;

-----------------------------------------------------------------------
-- GET_ACTION_INSTANCE
--  Get the export string from call instance_info_exp and
--  instance_extented_info_exp function of package in exppkgact$ 
-- PARAMETERS:
--      package     -- package name 
--      pkg_schema  -- schema of package
--      function    -- function name (instance_info_exp 
--                      or instance_extended_info_exp)
--      name        -- instance name
--      schema      -- instance schema
--      namespace   --
--      objtype     --
--      prepost     -- 0: pre-action, 1:post_action
--      isdba       -- 1: is dba
-- RETURNS: 
--      instance info  export_string

  FUNCTION get_action_instance( 
         package        IN  VARCHAR2,
         pkg_schema     IN  VARCHAR2,
         function       IN  VARCHAR2,
         name           IN  VARCHAR2,
         schema         IN  VARCHAR2,
         namespace      IN  number,
         objtype        IN  number,
         prepost        IN  number,
         isdba          IN  number)                              
        RETURN sys.ku$_procobj_lines;

-----------------------------------------------------------------------
-- GET_ACTION_SYS
--    Get the export string from call system_info_exp function of package 
--    in exppkgact$
-- PARAMETERS:
--      package    -- package name 
--      pkg_schema -- schema of package
--      function   -- function name (system_info_exp)
--      prepost    -- 0 :pre-action, 1: post-action
-- RETURNS: 
--      system info  export_string

  FUNCTION get_action_sys( 
                package         IN  VARCHAR2,
                pkg_schema      IN  VARCHAR2,
                function        IN  VARCHAR2,
                prepost         IN NUMBER)
        RETURN sys.ku$_procobj_lines;

-----------------------------------------------------------------------
-- GET_ACTION_SCHEMA 
--      Get the export string from call schema_info_exp
--      function of package in exppkgact$
-- PARAMETERS:
--      package    -- package name 
--      pkg_schema -- schema of package
--      function   -- function name (schema_info_exp)
--      schema     -- each user 
--      prepost    -- 0 :pre-action, 1: post-action
--      isdba      -- 1: is dba
-- RETURNS: 
--      schema info  export_string

  FUNCTION get_action_schema( 
                package         IN  VARCHAR2,
                pkg_schema      IN  VARCHAR2,
                function        IN  VARCHAR2,
                schema          IN  VARCHAR2,
                prepost         IN NUMBER,
                isdba           IN NUMBER)
        RETURN sys.ku$_procobj_lines;

-----------------------------------------------------------------------
-- GET_PLUGTS_BLK : Get PLSQL code from dbms_plugts.selectBlock and getLine.
--      This generates the pre-import and post-import anonymous blocks
--      for transportable.
-- PARAMETERS:
--      blockID         - 0 = pre-import; non-0 = post-import

  FUNCTION get_plugts_blk (
                blockID         IN NUMBER )
        RETURN sys.ku$_procobj_lines;

-- GET_JAVA_METADATA: Return java class, source, resource info 
-- PARAMETERS:
--      java_name       - java class or resource or source name
--      schema_name     - schema name
--      type_num        - object type
-- RETURNS: nested table of java info 

 FUNCTION get_java_metadata(
                java_name       IN  VARCHAR2,
                java_schema     IN  VARCHAR2,
                type_num        IN  NUMBER)
        RETURN sys.ku$_java_t;


-- GET_PREPOST_TABLE_ACT
--    Get the export string for pre-table action 
--            from call sys.dbms_export_extension.pre_table
--    Get the export string for post-table action 
--            from call sys.dbms_export_extension.post_tables
-- PARAMETERS:
--      prepost   -- 1 is pre-table action, 2 is post-table action
--      schema    -- schema name 
--      tname     -- table name 
-- RETURNS: 
--      table pre/post table action string

  FUNCTION get_prepost_table_act(
                prepost IN  NUMBER,       
                schema  IN  VARCHAR2,
                tname   IN  VARCHAR2)
        RETURN sys.ku$_taction_list_t;

-- GET_CANONICAL_VSN: convert the user's VERSION param to a string
--       in the format vv.vv.vv.vv.vv, e.g., '08.01.03.00.00'
-- PARAMETERS:
--      version         - The version from DBMS_METADATA.OPEN.
--              Values can be 'COMPATIBLE' (default), 'LATEST' or a specific
--              version number.

  FUNCTION get_canonical_vsn(version IN VARCHAR2)
        RETURN VARCHAR2;

---------------------------------------------------------------------
-- CONVERT_TO_CANONICAL: Convert string to canonical form
--       vv.vv.vv.vv.vv, e.g., '08.01.03.00.00'
-- PARAMETERS:
--      version         - version string (e.g., 10.2.0.2)

  FUNCTION convert_to_canonical(version IN VARCHAR2)
        RETURN VARCHAR2;

---------------------------------------------------------------------
-- GET_INDEX_INTCOL - Get intcol# in table of column on which index is
--                    defined (need special handling for xmltype cols)
-- PARAMETERS:
--      obj_num         - base table object #
--      intcol_num      - intcol# from icol$
--
-- This is a wrapper function around dbms_metadata_util.get_index_intcol.


  FUNCTION get_index_intcol(obj_num IN NUMBER,
                            intcol_num in NUMBER)
        RETURN NUMBER;

---------------------------------------------------------------------
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
--
-- RETURNS:
--      A handle to be used in subsequent calls to ADD_TRANSFORM, CONVERT,
--      PUT and CLOSE.
-- EXCEPTIONS:
--      INVALID_ARGVAL  - a NULL or invalid value was supplied for an input
--              parameter.

  FUNCTION openw (
                object_type     IN  VARCHAR2,
                version         IN  VARCHAR2 DEFAULT 'COMPATIBLE',
                model           IN  VARCHAR2 DEFAULT 'ORACLE')
        RETURN NUMBER;


-- CONVERT:     Convert an input XML document into creation DDL.
--              More than one DDL statement may be returned.
-- RETURNS:     Metadata for the objects as one or more DDL statements
-- PARAMETERS:  handle   - Context handle from previous OPENW call.
--              document - XML document containing object metadata of
--                         the type of the OPENW handle.
-- EXCEPTIONS:  Throws an exception if DDL transform was not added.

  FUNCTION convert (
                handle          IN NUMBER,
                document        IN sys.XMLType)
        RETURN sys.ku$_multi_ddls;

  FUNCTION convert (
                handle          IN NUMBER,
                document        IN CLOB)
        RETURN sys.ku$_multi_ddls;


-- CONVERT:     This is an alternate, higher-performing but less flexible form
--              of CONVERT that returns only a single (but multi-object) CLOB 
--              with a collection providing offsets into this CLOB to locate
--              each individual DDL. Parse items per DDL are NOT returned with
--              this version.
-- RETURNS:     CLOB containing multiple DDL statements.
-- PARAMETERS:  handle   - Context handle from previous OPENW call.
--              document - CLOB containing the XML to be converted to DDL
--              offsets  - Collection of pointers/lengths into returned CLOB
-- EXCEPTIONS:  Throws an exception if DDL transform was not added.

  FUNCTION convert (
                handle          IN NUMBER,
                document        IN CLOB,
                offsets         OUT NOCOPY multiobjects)
        RETURN CLOB;


-- CONVERT:     Procedure variants to convert an input XML document as
--              specified by user transforms.
-- PARAMETERS:  handle   - Context handle from previous OPENW call.
--              document - XML document containing object metadata of
--                         the type of the OPENW handle.
--              result   - the converted document.
-- EXCEPTIONS:  Throws an exception if no transform was added.

  PROCEDURE convert (
                handle          IN NUMBER,
                document        IN sys.XMLType,
                result          IN OUT NOCOPY CLOB );

  PROCEDURE convert (
                handle          IN NUMBER,
                document        IN CLOB,
                result          IN OUT NOCOPY CLOB );


-- PUT:         Convert an input XML document into creation DDL
--              and submit the resultant DDL to the database. Two forms are
--              provided: One that accepts XML as a CLOB, the other as XMLType.
-- RETURNS:     A BOOLEAN indicating if something went wrong. If TRUE,
--              everything went OK and results doesn't necessarily have to be
--              parsed.
-- PARAMETERS:  handle   - Context handle from previous OPENW call.
--              document - XML document containing object metadata of
--                         the type of the OPENW handle.
--              flags    - Various TBD policy flags
--              results  - A ku$_SubmitResults object passed by reference that
--                         contains detailed results of the operation. Each
--                         object's DDL text, parsed items and associated
--                         error msgs are included.
-- EXCEPTIONS:  Throws an exception if DDL transform was not added or an
--              error occurs during XSL transformation.

  FUNCTION put (
                handle          IN NUMBER,
                document        IN sys.XMLType,
                flags           IN NUMBER,
                results         IN OUT NOCOPY sys.ku$_SubmitResults)
        RETURN BOOLEAN;

  FUNCTION put (
                handle          IN NUMBER,
                document        IN CLOB,
                flags           IN NUMBER,
                results         IN OUT NOCOPY sys.ku$_SubmitResults)
        RETURN BOOLEAN;

   FUNCTION check_match_template (
                pobjno          IN  NUMBER,
                spcnt           IN  NUMBER)
        RETURN  NUMBER;

   FUNCTION check_match_template_par (
                pobjno          IN  NUMBER,
                spcnt           IN  NUMBER)
        RETURN  NUMBER;

   FUNCTION check_match_template_lob (
                pobjno          IN  NUMBER,
                spcnt           IN  NUMBER)
        RETURN  NUMBER;

-----------------------------------------------------------------------
-- GET_EDITION:
--        This function returns the edition of interest for the current MDAPI
--        function. (this is either specified as the 'edition' filter, or
--        the session current edition.
-- RETURNS:     
--        VARCHAR2 containing edition name.
-- PARAMETERS:
--        none
-- EXCEPTIONS:  none

  FUNCTION GET_EDITION RETURN VARCHAR2;

-- GET_EDITION_ID:
--        This function returns the edition of interest for the current MDAPI
--        function. (this is either specified as the 'edition' filter, or
--        the session current edition.
-- RETURNS:     
--        NUMBER containing edition ID.
-- PARAMETERS:
--        none
-- EXCEPTIONS:  none

  FUNCTION GET_EDITION_ID RETURN NUMBER;

-- GET_VERSION:
--        This function returns the version of interest for the current MDAPI
--        context. Comes from the version parameter in open.
-- RETURNS:     
--        NUMBER containing version.
-- PARAMETERS:
--        none
-- EXCEPTIONS:  none

  FUNCTION GET_VERSION
   RETURN VARCHAR2;

-- GET_STAT_COLNAME
--        This function returns a column name for restoring statistics.
-- RETURNS:     
--        VARCHAR2 containing the column name
-- PARAMETERS:
--        OWNER_NAME    - schema name that owns the table
--        TABLENAME     - table name where column exists
--        DEFAULT_VAL   - value or null from col$.default$
--        ATTR_COLNAME  - value or null from attrcol$.name
--        NESTED_TABLE  - 1 if nested table, 0 otherwise
-- EXCEPTIONS:  none
--
-- RETURNS:             - COLUMN NAME
  FUNCTION GET_STAT_COLNAME(
          OWNER_NAME   in varchar2,
          TABLENAME    in varchar2,
          DEFAULT_VAL  in long,
          ATTR_COLNAME in varchar2,
          NESTED_TABLE in number)
   RETURN VARCHAR2;

-- GET_STAT_INDNAME
--        This procedure returns an index_owner and index name for restoring
--        statistics.
-- PARAMETERS:
--        TABLE_OWNER  - schema name that owns the table
--        TABLE_NAME   - name of table that index is on
--        COLNAME_LIST - varray of columns that index is on
--        COL_COUNT    - number of columns that index is on
-- RETURNS:
--        IND_OWNER    - owner of index
--        IND_NAME     - name of index
-- EXCEPTIONS:  none
  PROCEDURE GET_STAT_INDNAME(
          TABLE_OWNER  IN  VARCHAR2,
          TABLE_NAME   IN  VARCHAR2,
          COLNAMES     IN  T_VAR_COLL,
          COL_COUNT    IN  NUMBER,
          IND_OWNER    OUT VARCHAR2,
          IND_NAME     OUT VARCHAR2);

-- The following 3 PARSE_ functions are jackets around calls to
-- similar routines in dbms_metadata_util.  If the user has
-- set the PARSE_EXPRESSIONS parameter TRUE, they call the 
-- appropriate functions in dbms_metadata_util; otherwise they return NULL.

-- PARSE_CONDITION: Parse a check constraint condition on a table
--   and return it as XML
-- PARAMETERS:
--      schema          - schema
--      tab             - table name
--      length          - length of the constraint
--      row             - rowid of the row in CDEF$
-- RETURNS:     XMLType containing parsed condition as XML
--                 if length is not NULL
--              otherwise NULL

  FUNCTION parse_condition(
                schema          IN  VARCHAR2,
                tab             IN  VARCHAR2,
                length          IN  NUMBER,
                row             IN  ROWID)
        RETURN SYS.XMLTYPE;

-- PARSE_DEFAULT: Parse the default value of a virtual column
--   (which contains an arithmetic expression for a functional index)
--   and return it as XML
-- PARAMETERS:
--      schema          - schema
--      tab             - table name
--      length          - length of the default
--      row             - rowid of the row in COL$
-- RETURNS:     XMLType containing parsed expression as XML
--                 if length is not NULL
--              otherwise NULL

  FUNCTION parse_default(
                schema          IN  VARCHAR2,
                tab             IN  VARCHAR2,
                length          IN  NUMBER,
                row             IN  ROWID)
        RETURN SYS.XMLTYPE;

-- PARSE_QUERY: Parse a query stored in a long column (e.g., view query).
--   and return it as XML
-- PARAMETERS:
--      schema          - schema
--      length          - length of the LONG
--      tab             - table name
--      col             - column name
--      row             - rowid of the row
--      read_only       - non-0 = query has 'with read only'
--      check_option    - non-0 = query has 'with check option'
-- RETURNS:     XMLType containing parsed query as XML
--                 if length is not NULL
--              otherwise NULL

  FUNCTION parse_query(
                schema          IN  VARCHAR2,
                length          IN  NUMBER,
                tab             IN  VARCHAR2,
                col             IN  VARCHAR2,
                row             IN  ROWID,
                read_only       IN  NUMBER DEFAULT 0,
                check_option    IN  NUMBER DEFAULT 0)
        RETURN SYS.XMLTYPE;

-- GET_CHECK_CONSTRAINT_NAME - Return the constraint name given the
--                   condition. (Useful if name is system-generated.)
-- PARAMETERS:
--      object_type     - object type of base object
--      schema          - Schema containing the base object.
--      name            - Name of the base object.
--      condition       - condition (parsed or unparsed)
--      parsed_condition- boolean; TRUE = condition is parsed
-- RETURNS:     Constraint name or NULL if not found

  FUNCTION get_check_constraint_name(
                object_type     IN  VARCHAR2,
                schema          IN  VARCHAR2,
                name            IN  VARCHAR2,
                condition       IN  CLOB,
                parsed_condition IN  BOOLEAN DEFAULT FALSE)
        RETURN VARCHAR2;

-- OPEN_GET_FK_CONSTRAINT_NAME - This and the following 2 apis return
--                   the name of a foreign key constraint given its
--                   definition. (Useful if name is system-generated.)
-- PARAMETERS:
--      object_type     - object type of base object
--      schema          - Schema containing the base object.
--      name            - Name of the base object.
--      ref_schema      - Schema containing the referenced object.
--      ref_name        - Name of the referenced object.
-- RETURNS:     Handle to be used in subsequent calls.

  FUNCTION open_get_fk_constraint_name(
                object_type     IN  VARCHAR2,
                schema          IN  VARCHAR2,
                name            IN  VARCHAR2,
                ref_schema      IN  VARCHAR2,
                ref_name        IN  VARCHAR2)
        RETURN NUMBER;

-- SET_FK_CONSTRAINT_COL_PAIR - After calling OPEN_GET_FK_CONSTRAINT_NAME,
--   the program calls this for each pair of corresponding columns.
--   The order of calls defines the order of columns in the constraint.
-- PARAMETERS:
--      handle          - handle returned by OPEN_GET_FK_CONSTRAINT_NAME
--      src_col         - name of column in base table
--      tgt_col         - name of corresponding column in ref table

  PROCEDURE set_fk_constraint_col_pair(
                handle          IN  NUMBER,
                src_col         IN  VARCHAR2,
                tgt_col         IN  VARCHAR2);


-- GET_FK_CONSTRAINT_NAME 
-- PARAMETERS:
--      handle          - handle returned by OPEN_GET_FK_CONSTRAINT_NAME
-- RETURNS:     Constraint name or NULL if not found

  FUNCTION get_fk_constraint_name(
                handle          IN  NUMBER)
        RETURN VARCHAR2;


---------------------------------------------------------------------
-- IS_ATTR_VALID_ON_10 - 
--                    
-- PARAMETERS:
--      obj_num         - base table object #
--      intcol_num      - intcol# from icol$
--
-- This is a wrapper function around dbms_metadata_int.is_attr_valid_on_10.


  FUNCTION is_attr_valid_on_10(obj_num IN NUMBER,
                               intcol_num in NUMBER)
        RETURN NUMBER;

---------------------------------------------------------------------
-- IS_XDB_TRANS    - test for XDB/transportable
--
-- PARAMETERS: none
--
-- return 1 if XDB repository is in a tablespace which
--                        will be moved via TTS

  FUNCTION is_xdb_trans
        RETURN NUMBER;

---------------------------------------------------------------------
-- IN_TSNUM         - return 1 if TS# is in the selected set
--
-- PARAMETERS: 
--      TS_SET - 1 for transprotable TS
--               2 for early TS
--      TS_NUM - tablespace number to test
--
-- return 1 if TS# is in the selected set


  FUNCTION in_tsnum ( 
                TS_SET  IN NUMBER,
                TS_NUM  IN NUMBER )
        RETURN NUMBER DETERMINISTIC;

---------------------------------------------------------------------
-- GET_PARTN         - "relative fragment number" for the partition.
--
-- PARAMETERS: 
--      PARTYPE - 1 - tabpart
--                2 - tabcompart
--                3 - tabsubpart
--                4 - indpart
--                5 - indcompart
--                6 - indsubpart
--                7 - lobfrag
--                8 - lobcomppart
--      BOBJ_NUM - object number of which this is a partition
--      PART_NUM - partition number (as stored in dictionary)
--
-- return "relative fragment number" for the partition.

  FUNCTION get_partn ( 
                PARTYPE  IN NUMBER,
                BOBJ_NUM IN NUMBER,
                PART_NUM IN NUMBER  )
        RETURN NUMBER DETERMINISTIC;

---------------------------------------------------------------------
-- GET_INDPART_TS - get a ts# for an index (sub)partition
--   (used by ku$_index_view
-- PARAMETERS:
--    obj_num    - obj# for table

  FUNCTION get_indpart_ts ( 
                OBJ_NUM  IN NUMBER )
        RETURN NUMBER;

END DBMS_METADATA;

/
GRANT EXECUTE ON sys.dbms_metadata TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM dbms_metadata FOR sys.dbms_metadata;

