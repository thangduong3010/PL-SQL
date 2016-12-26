Rem Copyright (c) 2000, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxsch.sql - XML Schema Package
Rem
Rem    DESCRIPTION
Rem      Contains package to register XML schemas with XDB.
Rem
Rem    NOTES
Rem      Must be run connected as XDB
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    06/09/09 - add schemoid to registerSchema (CLOB) for expdp
Rem    thbaby      02/13/09 - remove REGISTER_AUTO_OOL
Rem    ajadams     11/07/08 - add with_commit to supplemental_log pragma
Rem    sichandr    11/05/08 - remove WITH GRANT OPTION
Rem    thbaby      05/17/07 - rename flags
Rem    jwwarner    04/06/07 - add option for automatically moving elements
Rem                           out-of-line
Rem    thbaby      04/27/07 - add evolve_trace_only flag for InPlaceEvolve
Rem    schakrab    02/07/07 - add REGISTER_NT_AS_IOT option to registerschema 
Rem    qiwang      01/05/07 - pragma newly-added procedure InPlaceEvolve
Rem    qiwang      09/07/06 - progma DBMS_XMLSCHEMA for logmnr PLSQL support
Rem    sidicula    06/15/06 - Add flags to CopyEvolve 
Rem    pnath       05/24/06 - add ENABLE_LINKS hierarchy type 
Rem    sidicula    06/15/06 - Add flags to CopyEvolve 
Rem    pnath       05/24/06 - add ENABLE_LINKS hierarchy type 
Rem    thbaby      06/04/06 - coalesce versioning-related constants 
Rem    abagrawa    04/04/06 - Add purgeSchema 
Rem    abagrawa    03/14/06 - Add new deleteschema option 
Rem    thbaby      12/29/05 - add new modes for enabling hierarchy
Rem    abagrawa    08/30/05 - Add binaryxml option to registerschema 
Rem    sidicula    04/05/05 - Fix bug 4285311
Rem    thbaby      03/28/05 - add InPlaceEvolve 
Rem    abagrawa    05/17/04 - Merge csid signaures of registerschema 
Rem    abagrawa    04/13/04 - Add enable hierarchy parameter to reg schema 
Rem    abagrawa    05/09/04 - Add options argument to registerSchema 
Rem    rmurthy     09/23/03 - helper routines for type conversion 
Rem    abagrawa    03/09/03 - Separate dbmsxsch and prvtxsch
Rem    thoang      11/07/02 - required csid for blob and bfile 
Rem    sidicula    10/04/02 - Prototype change for CopyEvolve
Rem    sidicula    09/13/02 - Schema Evolution Support
Rem    thoang      07/18/02 - add csid parameter to registerSchema 
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    jwwarner    01/29/02 - make generateschema(s) embedcoll by default
Rem    spannala    12/27/01 - not switching users in xdb install
Rem    rmurthy     11/19/01 - invoke wrapped implementation
Rem    sichandr    11/20/01 - optional user name for register
Rem    sichandr    10/15/01 - add FORCE flag for register
Rem    rmurthy     10/01/01 - add genTables as separate flag
Rem    rmurthy     09/12/01 - add register schema based on URI
Rem    jwwarner    09/10/01 - Add schema location hint to generateSchemas
Rem    sichandr    10/03/01 - add compileSchema
Rem    jwwarner    08/09/01 - Add generateSchema
Rem    rmurthy     08/03/01 - add register from xmltype, uritype
Rem    tsingh      06/30/01 - XDB: XML Database merge
Rem    rmurthy     05/18/01 - add invalidate option for schema deletion
Rem    rmurthy     05/09/01 - make registration always invokers rights
Rem    bkhaladk    03/07/01 - update register schema calls..
Rem    rmurthy     02/09/01 - change functions to procedures
Rem    rmurthy     02/07/01 - add invokers rights entry points
Rem    rmurthy     01/02/01 - add register functions for clobs, bfiles
Rem    rmurthy     12/01/00 - Created
Rem



create or replace package xdb.dbms_xmlschema authid current_user is
  ---------------------------------------------
  --  OVERVIEW
  --
  --  This package provides procedures to
  --  (*) register an XML schema
  --  (*) delete a previously registered XML schema
  --  (*) re-compile a previously registered XML schema
  --  (*) generate an XML schema
  --
  ---------------------------------------------

  ------------
  -- CONSTANTS
  --
  ------------
  DELETE_RESTRICT CONSTANT NUMBER := 1;
  DELETE_INVALIDATE CONSTANT NUMBER := 2;
  DELETE_CASCADE  CONSTANT NUMBER := 3;
  DELETE_CASCADE_FORCE CONSTANT NUMBER := 4;
  DELETE_MIGRATE CONSTANT NUMBER := 8;

  ENABLE_HIERARCHY_NONE CONSTANT PLS_INTEGER        := 1;
  ENABLE_HIERARCHY_CONTENTS CONSTANT PLS_INTEGER    := 2;
  ENABLE_HIERARCHY_RESMETADATA CONSTANT PLS_INTEGER := 3;
  ENABLE_HIERARCHY_VERSION  CONSTANT PLS_INTEGER    := 4;
  ENABLE_HIERARCHY_LINKS  CONSTANT PLS_INTEGER      := 8;

  REGISTER_NODOCID   CONSTANT NUMBER := 1;
  REGISTER_BINARYXML CONSTANT NUMBER := 2;
  REGISTER_NT_AS_IOT CONSTANT NUMBER := 4;

  REGISTER_CSID_NULL CONSTANT NUMBER := -1;

  COPYEVOLVE_BINARY_XML CONSTANT NUMBER := 1;

  INPLACE_EVOLVE CONSTANT NUMBER := 1;
  INPLACE_TRACE  CONSTANT NUMBER := 2;

  PRESERVE_PROP_NUMBERS CONSTANT NUMBER := 1;

  ------------
  -- TYPES
  ------------
  TYPE URLARR is VARRAY(1000) of VARCHAR2(1000);
  TYPE XMLARR is VARRAY(1000) of XMLType;
  TYPE UNAME_ARR is VARRAY(1000) of VARCHAR2(100);

  ---------------------------------------------
  -- PROCEDURE - registerSchema
  -- PARAMETERS - 
  --  schemaURL 
  --     A name that uniquely identifies the schema document. 
  --  schemaDoc 
  --     a valid XML schema document
  --  local 
  --     Is this a local or global schema ? By default, all schemas 
  --     are registered as local schemas i.e. under 
  --       /sys/schemas/<username>/...
  --     If a schema is registered as global, it is added under 
  --       /sys/schemas/PUBLIC/...
  --     You need write privileges on the above directory to be 
  --     able to register a schema as global.
  --  genTypes 
  --     Should the schema compiler generate object types ? 
  --  genbean 
  --     Should the schema compiler generate Java beans ? 
  --  genTables 
  --     Should the schema compiler generate default tables ? 
  --  force
  --     Should the schema be created/stored even with errors?
  --       Setting this to TRUE will register the schema in the
  --       hierarchy even if there were compilation errors, but
  --       the schema cannot be used until it is made valid.
  --  csid
  --     Character set id of the input blob or bfile.
  --     The value REGISTER_CSID_NULL indicates that the CSID was
  --     not passed in. If users pass in REGISTER_CSID_NULL as the value
  --     of the csid parameter, then the behavior will be the same as
  --     when csid was not passed in.
  --  options
  --     Additional options to specify how the schema should be 
  --     registered. The various options are represented as bits
  --     of an integer and the options parameter should be 
  --     constructed by doing a bitor of the desired bits.
  --     The possible bits for this are:
  --       REGISTER_NODOCID :: this will suppress the creation  
  --       of the DOCID column for out of line tables. This is a   
  --       storage optimization which might be desirable when 
  --       we do not need to join back to the document table (for example
  --       if we do not care about rewriting certain queries that could
  --       be rewritten by making use of the DOCID column)
  --       REGISTER_BINARYXML :: this scema is used for CSX
  --      REGISTER_NT_AS_IOT  :: this will store the 
  --       nested tables as IOTs instead of heap (which is the default storage)
  --  enableHierarchy
  --     Specifies how the tables generated during schema registration
  --     should be hierarchically enabled. It must be one of the following:
  --     ENABLE_HIERARCHY_NONE : none of the tables will have hierarchy 
  --     enabled on them
  --     ENABLE_HIERARCHY_CONTENTS : enables hierarchy for contents i.e.
  --     the tables can be used to store contents of resources
  --     ENABLE_HIERARCHY_RESMETADATA : enables hierarchy for resource metadata
  --     i.e. the tables can be used to store resource metadata
  --     ENABLE_HIERARCHY_VERSION : version-enable all table created during
  --     registration. Must be combined with either ENABLE_HIERARCHY_CONTENTS
  --     or ENABLE_HIERARCHY_RESMETADATA. 
  --     ENABLE_HIERARCHY_LINKS : enable hierarchy and enable link processing on 
  --     the table. Must be combined with ENABLE_HIERARCHY_CONTENTS
  --   
  -- EXCEPTIONS
  --   ORA-31001: Invalid resource handle or path name
  --   todo
  ---------------------------------------------
  procedure registerSchema(schemaURL IN varchar2,
                           schemaDoc IN VARCHAR2,
                           local IN BOOLEAN := TRUE,
                           genTypes IN BOOLEAN := TRUE,
                           genbean IN BOOLEAN := FALSE,
                           genTables IN BOOLEAN := TRUE,
                           force IN BOOLEAN := FALSE,
                           owner IN VARCHAR2 := '',
                           enableHierarchy IN pls_integer := 
                           ENABLE_HIERARCHY_CONTENTS,
                           options IN pls_integer := 0);
  PRAGMA SUPPLEMENTAL_LOG_DATA(registerSchema, UNSUPPORTED_WITH_COMMIT);

  procedure registerSchema(schemaURL IN varchar2,
                           schemaDoc IN CLOB,
                           local IN BOOLEAN := TRUE,
                           genTypes IN BOOLEAN := TRUE,
                           genbean IN BOOLEAN := FALSE,
                           genTables IN BOOLEAN := TRUE,
                           force IN BOOLEAN := FALSE,
                           owner IN VARCHAR2 := '',
                           enableHierarchy IN pls_integer := 
                           ENABLE_HIERARCHY_CONTENTS,
                           options IN pls_integer := 0,
                           schemaoid IN RAW := NULL,
                           import_options IN pls_integer := 0);
  PRAGMA SUPPLEMENTAL_LOG_DATA(registerSchema, UNSUPPORTED_WITH_COMMIT);

  procedure registerSchema(schemaURL IN varchar2,
                           schemaDoc IN BLOB,
                           local IN BOOLEAN := TRUE,
                           genTypes IN BOOLEAN := TRUE,
                           genbean IN BOOLEAN := FALSE,
                           genTables IN BOOLEAN := TRUE,
                           force IN BOOLEAN := FALSE,
                           owner IN VARCHAR2 := '',
                           csid IN NUMBER := REGISTER_CSID_NULL,
                           enableHierarchy IN pls_integer := 
                           ENABLE_HIERARCHY_CONTENTS,
                           options IN pls_integer := 0);
  PRAGMA SUPPLEMENTAL_LOG_DATA(registerSchema, UNSUPPORTED_WITH_COMMIT);

  procedure registerSchema(schemaURL IN varchar2,
                           schemaDoc IN BFILE,
                           local IN BOOLEAN := TRUE,
                           genTypes IN BOOLEAN := TRUE,
                           genbean IN BOOLEAN := FALSE,
                           genTables IN BOOLEAN := TRUE,
                           force IN BOOLEAN := FALSE,
                           owner IN VARCHAR2 := '',
                           csid IN NUMBER := REGISTER_CSID_NULL,
                           enableHierarchy IN pls_integer := 
                           ENABLE_HIERARCHY_CONTENTS,
                           options IN pls_integer := 0);
  PRAGMA SUPPLEMENTAL_LOG_DATA(registerSchema, UNSUPPORTED_WITH_COMMIT);

  procedure registerSchema(schemaURL IN varchar2,
                           schemaDoc IN sys.XMLType,
                           local IN BOOLEAN := TRUE,
                           genTypes IN BOOLEAN := TRUE,
                           genbean IN BOOLEAN := FALSE,
                           genTables IN BOOLEAN := TRUE,
                           force IN BOOLEAN := FALSE,
                           owner IN VARCHAR2 := '',
                           enableHierarchy IN pls_integer := 
                           ENABLE_HIERARCHY_CONTENTS,
                           options IN pls_integer := 0);
  PRAGMA SUPPLEMENTAL_LOG_DATA(registerSchema, UNSUPPORTED_WITH_COMMIT);

  procedure registerSchema(schemaURL IN varchar2,
                           schemaDoc IN sys.UriType,
                           local IN BOOLEAN := TRUE,
                           genTypes IN BOOLEAN := TRUE,
                           genbean IN BOOLEAN := FALSE,
                           genTables IN BOOLEAN := TRUE,
                           force IN BOOLEAN := FALSE,
                           owner IN VARCHAR2 := '',
                           enableHierarchy IN pls_integer := 
                           ENABLE_HIERARCHY_CONTENTS,
                           options IN pls_integer := 0);
  PRAGMA SUPPLEMENTAL_LOG_DATA(registerSchema, UNSUPPORTED_WITH_COMMIT);

  ---------------------------------------------
  -- PROCEDURE - registerURI
  -- PARAMETERS - 
  --  schemaURL 
  --     A name that uniquely identifies the schema document. 
  --  schemaDocURI
  --     A pathname (URI) corresponding to the physical location of the 
  --     schema document. The URI path could be based on HTTP, FTP, DB or XDB 
  --     protocols. This function constructs a URIType instance using 
  --     the URIFactory - and invokes the regiserSchema function above.
  --  <all other paramaters> Same as above
  ---------------------------------------------
  procedure registerURI(schemaURL IN varchar2,
                        schemaDocURI IN varchar2,
                        local IN BOOLEAN := TRUE,
                        genTypes IN BOOLEAN := TRUE,
                        genbean IN BOOLEAN := FALSE,
                        genTables IN BOOLEAN := TRUE,
                        force IN BOOLEAN := FALSE,
                        owner IN VARCHAR2 := '',
                        enableHierarchy IN pls_integer := 
                        ENABLE_HIERARCHY_CONTENTS,
                        options IN pls_integer := 0);
  PRAGMA SUPPLEMENTAL_LOG_DATA(registerURI, UNSUPPORTED_WITH_COMMIT);        

  ---------------------------------------------
  -- PROCEDURE - deleteSchema
  -- PARAMETERS - 
  --  schemaURL : Name identifying the schema to be deleted
  --  option : one of the following 
  --    DELETE_RESTRICT ::
  --      Schema deletion fails if there are any tables or schemas that 
  --      depend on this schema.
  --    DELETE_INVALIDATE : 
  --      Schema deletion does not fail if there are any dependencies. 
  --      Instead, it simply invalidates all dependent objects.
  --    DELETE_CASCADE ::
  --      Schema deletion will also drop all default SQL types and 
  --      default tables. However the deletion fails if there are 
  --      any stored instances conforming to this schema.
  --    DELETE_CASCADE_FORCE :: 
  --      Similar to CASCADE except that it does not check for any stored 
  --      instances conforming to this schema. Also it ignores any errors.
  --    DELETE_MIGRATE
  --      This delete is happening during migrate mode.
  --
  -- EXCEPTIONS
  --   ORA-31001: Invalid resource handle or path name
  --   todo
  ---------------------------------------------
  procedure deleteSchema(schemaURL IN varchar2, 
                         delete_option IN pls_integer := DELETE_RESTRICT);
  PRAGMA SUPPLEMENTAL_LOG_DATA(deleteSchema, UNSUPPORTED_WITH_COMMIT);

  ---------------------------------------------
  -- PROCEDURE - purgeSchema
  --  Purges a schema that was previously marked delete with hide mode
  -- PARAMETERS - 
  --  schemaURL : Name identifying the schema to be purge
  --
  -- EXCEPTIONS
  --   ORA-31001: Invalid resource handle or path name
  --   todo
  ---------------------------------------------
  procedure purgeSchema(schema_id IN raw);
  PRAGMA SUPPLEMENTAL_LOG_DATA(purgeSchema, UNSUPPORTED_WITH_COMMIT);

  ---------------------------------------------
  -- PROCEDURE - generateBean
  --  This procedure can be used to generate the Java bean code 
  --  corresponding to a registered XML schema.
  --  Note that there is also an option to generate the beans 
  --  as part of the registration procedure itself.
  -- PARAMETERS - 
  --  schemaURL : Name identifying a registered XML schema.
  -- EXCEPTIONS
  --   ORA-31001: Invalid resource handle or path name
  --   todo
  ---------------------------------------------
  procedure generateBean(schemaURL IN varchar2);

  ---------------------------------------------
  -- PROCEDURE - compileSchema
  --  This procedure can be used to re-compile an already registered XML
  --  schema. This is useful for bringing a schema in an invalid
  --  state to a valid state.
  -- PARAMETERS - 
  --  schemaURL : URL identifying the schema 
  -- EXCEPTIONS
  --   ORA-31001: Invalid resource handle or path name
  ---------------------------------------------
  procedure compileSchema(schemaURL IN varchar2);
  PRAGMA SUPPLEMENTAL_LOG_DATA(compileSchema, UNSUPPORTED_WITH_COMMIT);

  ---------------------------------------------
  -- FUNCTION - generateSchema(s)
  --  These functions generate XML schema(s) from
  --  an oracle type name.  generateSchemas returns a collection
  --  of XMLTypes, one XMLSchema document for each database schema.
  --  generateSchema inlines them all in one schema (XMLType).
  -- PARAMETERS - 
  --  schemaName  : the name of the database schema containing the type
  --  typeName    : the name of the oracle type
  --  elementName : the name of the toplevel element in the XMLSchema
  --                defaults to typeName
  --  schemaURL   : specifies base URL where schemas will be stored,
  --                needed by top level schema for import statement
  --  recurse     : whether or not to also generate schema for all types
  --                referred to by the type specified
  --  annotate    : whether or not to put the SQL annotations in the XMLSchema
  --  embedColl   : whether you want collections embedded in the type which
  --                refers to them or you want them to have a complexType
  --                created, can not be false with annotations true
  -- EXCEPTIONS
  --  TBD
  ---------------------------------------------
  function generateSchemas( schemaName IN varchar2, typeName IN varchar2,
                            elementName IN varchar2 := NULL,
                            schemaURL IN varchar2 := NULL,
                            annotate IN BOOLEAN := TRUE,
                            embedColl IN BOOLEAN := TRUE )
    return sys.XMLSequenceType;

  function generateSchema( schemaName IN varchar2, typeName IN varchar2,
                           elementName IN varchar2 := NULL,
                           recurse IN BOOLEAN := TRUE,
                           annotate IN BOOLEAN := TRUE,
                           embedColl IN BOOLEAN := TRUE ) return sys.XMLType;

  procedure CopyEvolve(schemaURLs         IN XDB$STRING_LIST_T,
                       newSchemas         IN XMLSequenceType,
                       transforms         IN XMLSequenceType := NULL,
                       preserveOldDocs    IN BOOLEAN := FALSE,
                       mapTabName         IN VARCHAR2 := NULL,
                       generateTables     IN BOOLEAN := TRUE,
                       force              IN BOOLEAN := FALSE,
                       schemaOwners       IN XDB$STRING_LIST_T := NULL,
                       parallelDegree     IN PLS_INTEGER := 0,
                       options            IN PLS_INTEGER := 0);
  PRAGMA SUPPLEMENTAL_LOG_DATA(CopyEvolve, UNSUPPORTED_WITH_COMMIT);

  procedure InPlaceEvolve(schemaURL       IN VARCHAR2,
                          diffXML         IN SYS.XMLTYPE,
                          flags           IN NUMBER := 1);
  PRAGMA SUPPLEMENTAL_LOG_DATA(InPlaceEvolve, UNSUPPORTED_WITH_COMMIT);

  ---------------------------------------------
  -- FUNCTION - convertToDate
  --  This function converts the string representation of the following
  --  specified XML Schema types into the Oracle DATE representation
  --  using a default reference date and format mask.
  -- PARAMETERS - 
  --  strval : string representation of valid value (per XML Schema) 
  --  xmltypename : Name of the XML Schema datatype.
  --                Has to be one of the following:
  --                 * gDay
  --                 * gMonth
  --                 * gYear
  --                 * gYearMonth
  --                 * gMonthDay
  --                 * date
  ---------------------------------------------
  function convertToDate(strval varchar2, xmltypename varchar2)
  return DATE deterministic parallel_enable;

  ---------------------------------------------
  -- FUNCTION - convertToTS
  --  This function converts the string representation of the following
  --  specified XML Schema types into the Oracle TIMESTAMP representation
  --  using a default reference date and format mask.
  -- PARAMETERS - 
  --  strval : string representation of valid value (per XML Schema) 
  --  xmltypename : Name of the XML Schema datatype.
  --                Has to be one of the following:
  --                 * dateTime
  --                 * time
  ---------------------------------------------
  function convertToTS(strval varchar2, xmltypename varchar2)
  return TIMESTAMP deterministic parallel_enable;

  ---------------------------------------------
  -- FUNCTION - convertToTSWithTZ
  --  This function converts the string representation of the following
  --  specified XML Schema types into the Oracle
  --  TIMESTAMP WITH TIMEZONE representation using a default reference
  --  date and format mask.
  -- PARAMETERS - 
  --  strval : string representation of valid value (per XML Schema) 
  --  xmltypename : Name of the XML Schema datatype.
  --                Has to be one of the following:
  --                 * gDay
  --                 * gMonth
  --                 * gYear
  --                 * gYearMonth
  --                 * gMonthDay
  --                 * date
  --                 * dateTime
  --                 * time
  ---------------------------------------------
  function convertToTSWithTZ(strval varchar2, xmltypename varchar2)
  return TIMESTAMP WITH TIME ZONE deterministic parallel_enable;

end dbms_xmlschema;
/
show errors

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XMLSCHEMA FOR xdb.DBMS_XMLSCHEMA;

GRANT EXECUTE ON DBMS_XMLSCHEMA TO PUBLIC;

