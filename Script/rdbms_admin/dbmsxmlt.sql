Rem
Rem $Header: rdbms/admin/dbmsxmlt.sql /main/62 2009/04/30 22:21:32 qyu Exp $
Rem
Rem dbmsxmlt.sql
Rem
Rem Copyright (c) 1900, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxmlt.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    qyu         04/23/09 - reverse yi's change
Rem    yifeng      03/27/09 - add xmlQuery and xmlExists
Rem    thbaby      03/19/09 - parallel enable all versions of getclobval
Rem                           and getblobval
Rem    bhammers    06/25/08 - 7197944, remove grant option for XML functions
Rem    zliu        08/30/06 - XbranchMerge zliu_window-cxqry from main
Rem    zliu        08/10/06 - add outvars in xquery window func
Rem    zliu        08/09/06 - add xquery window func
Rem    ayoaz       10/09/07 - bug 6433402 (reserved toid for xmlseq imp types)
Rem    srirkris    08/16/07 - bug 6215620: public exec for xml imp types.
Rem    ataracha    07/25/07 - parallel enabled getclobval
Rem    ayoaz       06/08/07 - remove myXML attr from AggXMLImp (bug 5883585)
Rem    zliu        11/29/06 - add xquery poly agg operators
Rem    zliu        11/28/06 - add xquery user defined aggregator
Rem    rburns      05/18/06 - move xmlsequence 
Rem    sichandr    03/20/06 - add getSchemaId() method 
Rem    ataracha    02/23/06 - add createXMLFromBinary
Rem    mture       01/17/05 - Mv XMLAGG to prvtxmlt.sql, remove AggXMLInputType
Rem    nitgupta    10/11/04 - 
Rem    amanikut    07/29/03 - grant execute on AggXMLImp with grant option
Rem    ayoaz       03/20/03 - add in/out opn args to XMLAGG init callout
Rem    zliu        03/06/03 - fix 2798283, no pq for getclob() etc
Rem    jwwarner    01/27/03 - change creation of xmlgenformattype
Rem    njalali     01/16/03 - bug 2744444
Rem    amanikut    11/15/02 - Add insertXML, appendChildXML, deleteXML
Rem    zliu        11/12/02 - pq for xmltype
Rem    mkrishna    11/15/02 - add deterministic to xmlgenformattype
Rem    mkrishna    11/14/02 - add arguments to XMLGenfOrmattype
Rem    thoang      10/15/02 - Add createXML for BLOB and BFILE input 
Rem    jwwarner    10/14/02 - add xmltype constructor from anydata
Rem    abagrawa    09/18/02 - Add BLOB constructor
Rem    ayoaz       05/15/02 - change key to raw(8) in AggXMLImp.
Rem    amanikut    02/02/02 - switch wellformed, validated flags
Rem    amanikut    01/30/02 - change ctors to return deterministic
Rem    amanikut    01/18/02 - add wellformed flag
Rem    spannala    01/14/02 - changing OID of the XMLSequenceType
Rem    spannala    01/11/02 - making all systems types have standard TOIDs
Rem    amanikut    12/06/01 - LRG 82051 : fix constructor signature
Rem    amanikut    11/26/01 - make NOT VALIDATED as default
Rem    jwwarner    11/01/01 - fix upgrade issues
Rem    vnimani     10/11/01 - rename isValid to validate; create new isValid
Rem    vnimani     10/01/01 - add setValid
Rem    smuralid    10/24/01 - change ALTER TYPE REPLACE to CREATE
Rem    jwwarner    10/18/01 - Change to alter type replace
Rem    jwwarner    10/15/01 - upgrade/downgrade changes
Rem    amanikut    09/28/01 - add validated flag
Rem    amanikut    09/28/01 - add XMLType constructors taking schema
Rem    amanikut    09/25/01 - add cons_XMLType_.*
Rem    amanikut    09/05/01 - add XMLType constructors
Rem    mkrishna    10/01/01 - update\040constructors,\040static\040functions
Rem    mkrishna    09/14/01 - add synonym for xmltype & xmlgenformat
Rem    amanikut    08/27/01 - add XMLAGG
Rem    mkrishna    08/29/01 - remove  EXISTSNODE, EXTRACT operators
Rem    jwwarner    08/16/01 - XMLSequence -> XMLSequenceType
Rem    amanikut    08/10/01 - modify toObject()
Rem    mkrishna    07/29/01 - move catalog views to catxdbv.sql
Rem    amanikut    08/03/01 - add toObject()
Rem    bkhaladk    07/18/01 - add NS support to extract.
Rem    jwwarner    07/27/01 - XML table functions changes
Rem    mkrishna    07/02/01 - use rowtype of XMLType for catalog views
Rem    jwwarner    07/11/01 - add XMLTable function
Rem    amanikut    07/26/01 - add createXML(REF CURSOR)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    bkhaladk    06/08/01 - add xslt transform function.
Rem    rmurthy     06/04/01 - add schema related functions
Rem    mkrishna    05/10/01 - Add xmltype tables and views
Rem    njalali     04/30/01 - added second VARRAY to XMLTypeExtra
Rem    nmontoya    04/17/01 - 
Rem    njalali     04/16/01 - added second top-level extras
Rem    mkrishna    02/26/01 - disable parallel clause for SYS_XMLAGG
Rem    mkrishna    02/15/01 - add wrap context for SYS_XMLAGG
Rem    mkrishna    12/06/00 - change TOIDs for XML, uri types
Rem    mkrishna    11/15/00 - add TOID for replication
Rem    mkrishna    11/04/00 - add deterministic keyword
Rem    mkrishna    10/23/00 - change boolean in existsnode to number
Rem    mkrishna    09/20/00 - change to operators
Rem    mkrishna    09/19/00 - fix ctx rewrite
Rem    mkrishna    11/08/00 - fix varray column
Rem    mkrishna    11/04/00 - add varray of varchar
Rem    mkrishna    09/15/00 - change ops to functions
Rem    mkrishna    08/12/00 - add xmlgenformattype
Rem    mkrishna    07/21/00 - add flags to Terminate
Rem    mkrishna    07/17/00 - change AGG_XML to SYS_XMLAGG
Rem    mkrishna    06/30/00 - add TO_AGG_XML 
Rem    mkrishna    04/11/00 - change to boolean
Rem    mkrishna    03/09/00 - XMLType definition
Rem    mkrishna    01/00/00 - Created
Rem

create library xmltype_lib trusted as static
/

Rem ************************** XMLType Definition ***************************
Rem ** IMPORTANT: The create or replace XMLType is FROZEN as of 9.0.1.1.0.
Rem ** All new additions to XMLType must be placed in the ALTER TYPE REPLACE
Rem ** following the create or replace type.
Rem *************************************************************************
create or replace type XMLType OID '00000000000000000000000000020100'
  authid current_user as opaque varying (*) 
 using library xmltype_lib 
( 
  -- creates the XML data 
  static function createXML (xmlData IN clob) return sys.XMLType deterministic,
  static function createXML (xmlData IN varchar2) return sys.XMLType deterministic,

  -- extract function
  member function extract(xpath IN varchar2) return sys.XMLType deterministic,

  -- existsNode function
  member function existsNode(xpath IN varchar2) return number deterministic,
  
  -- is it a fragment? 
  member function isFragment return number deterministic,

  -- extraction functions..!  
  -- do we want the encoding to be specified in the result or not ..? 
  member function getClobVal return CLOB deterministic,
  member function getStringVal return varchar2 deterministic,
  member function getNumberVal return number deterministic

)
/
show errors

Rem *************************************************************************

Rem *********************** ADDITIONS TO XMLTYPE ****************************
Rem ** All additions to XMLType must be put as an ALTER TYPE add here.
Rem *************************************************************************
alter type sys.XMLType replace
  authid current_user as opaque varying (*) 
  using library xmltype_lib 
(
  -- creates the XML data 
  static function createXML (xmlData IN clob) return sys.XMLType deterministic parallel_enable,
  static function createXML (xmlData IN varchar2) return sys.XMLType deterministic parallel_enable,
  -- extract function
  member function extract(xpath IN varchar2) return sys.XMLType deterministic parallel_enable,
  -- existsNode function
  member function existsNode(xpath IN varchar2) return number deterministic parallel_enable,
  -- is it a fragment? 
  member function isFragment return number deterministic parallel_enable,
  -- extraction functions..!  
  -- do we want the encoding to be specified in the result or not ..? 
  member function getClobVal return CLOB deterministic parallel_enable,
  member function getBlobVal(csid IN number) return BLOB deterministic ,
  member function getStringVal return varchar2 deterministic parallel_enable,
  member function getNumberVal return number deterministic parallel_enable,
  -- FUNCTIONS NEW IN 9iR2
  -- new versions of createxml
  STATIC FUNCTION createXML (xmlData IN clob, schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0) 
                 return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN blob, csid IN number,
                 schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0) 
                 return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN bfile, csid IN number,
                 schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0)
                 return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN varchar2, schema IN varchar2,
                 validated IN number := 0, wellformed IN number := 0) 
                 return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN "<ADT_1>",
                 schema IN varchar2 := NULL, element IN varchar2 := NULL,
                 validated IN NUMBER := 0)
    return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN SYS_REFCURSOR,
                 schema in varchar2 := NULL, element in varchar2 := NULL, 
                 validated in number := 0) 
     return sys.XMLType deterministic parallel_enable,
  STATIC FUNCTION createXML (xmlData IN AnyData,
                 schema in varchar2 := NULL, element in varchar2 := NULL, 
                 validated in number := 0) 
     return sys.XMLType deterministic parallel_enable,
  -- new versions of extract and existsnode with nsmap
  MEMBER FUNCTION extract(xpath IN varchar2, nsmap IN VARCHAR2)
    return sys.XMLType deterministic parallel_enable,
  MEMBER FUNCTION existsNode(xpath in varchar2, nsmap in varchar2)
    return number deterministic parallel_enable,
  -- transform function
  member function transform(xsl IN sys.XMLType,
                                parammap in varchar2 := NULL)
    return sys.XMLType deterministic parallel_enable,
  ---New Print Configuration Functions  
  member function getClobVal(pflag IN number, indent IN number) return CLOB deterministic parallel_enable,
  member function getBlobVal(csid IN number, pflag IN number, indent IN number) return BLOB deterministic parallel_enable,
  member function getStringVal(pflag IN number, indent IN number) return varchar2 deterministic parallel_enable,
  -- conversion functions
  MEMBER PROCEDURE toObject(SELF in sys.XMLType, object OUT "<ADT_1>",
                                schema in varchar2 := NULL,
                                element in varchar2 := NULL),
  -- schema related functions
  MEMBER FUNCTION isSchemaBased return number deterministic parallel_enable,
  MEMBER FUNCTION getSchemaURL return varchar2 deterministic parallel_enable,
  MEMBER FUNCTION getSchemaId return raw deterministic parallel_enable,
  MEMBER FUNCTION getRootElement return varchar2 deterministic parallel_enable,
  -- create schema and nonschema based
  MEMBER FUNCTION createSchemaBasedXML(schema IN varchar2 := NULL)
     return sys.XMLType deterministic parallel_enable,
  -- creates a non schema based document from self
  MEMBER FUNCTION createNonSchemaBasedXML return sys.XMLType deterministic parallel_enable,
  member function getNamespace return varchar2 deterministic parallel_enable,
  -- validates schema based document if VALIDATED flag is false
  member procedure schemaValidate(self IN OUT NOCOPY XMLType),
  -- returns the value of the VALIDATED flag of the document; tells if
  -- a schema based doc. has been actually validated against its schema.
  member function isSchemaValidated return NUMBER deterministic parallel_enable,
  -- sets the VALIDATED flag to user desired value
  member procedure setSchemaValidated(self IN OUT NOCOPY XMLType, 
                                      flag IN BINARY_INTEGER := 1),
  -- checks if doc is conformant to a specified schema; non mutating
  member function isSchemaValid(schurl IN VARCHAR2 := NULL, 
                         elem IN VARCHAR2 := NULL) return NUMBER 
                         deterministic parallel_enable,
  member function insertXMLBefore(xpath IN VARCHAR2, value_expr IN XMLType, 
           namespace IN VARCHAR2 := NULL) return XMLType 
           deterministic parallel_enable,
  member function appendChildXML(xpath IN VARCHAR2, value_expr IN XMLType, 
         namespace IN VARCHAR2 := NULL) return XMLType 
         deterministic parallel_enable,
  member function deleteXML(xpath IN VARCHAR2, namespace IN VARCHAR2 := NULL)
         return XMLType deterministic parallel_enable,
  -- constructors
  constructor function XMLType(xmlData IN clob, schema IN varchar2 := NULL,
                validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType(xmlData IN blob, csid IN number, 
                               schema IN varchar2 := NULL,
                validated IN number := 0, wellformed IN number := 0)
    return self as result deterministic parallel_enable,
  constructor function XMLType(xmlData IN bfile, csid IN number, 
                               schema IN varchar2 := NULL,
                validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType(xmlData IN varchar2, schema IN varchar2 := NULL
                , validated IN number := 0, wellformed IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType (xmlData IN "<ADT_1>",
                schema IN varchar2 := NULL, element IN varchar2 := NULL,
                validated IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType (xmlData IN AnyData,
                schema IN varchar2 := NULL, element IN varchar2 := NULL,
                validated IN number := 0) 
    return self as result deterministic parallel_enable,
  constructor function XMLType(xmlData IN SYS_REFCURSOR,
                schema in varchar2 := NULL, element in varchar2 := NULL, 
                validated in number := 0) 
    return self as result deterministic parallel_enable,
  STATIC FUNCTION createXMLFromBinary (xmlData IN blob)
                 return sys.XMLType deterministic parallel_enable
  --, PRAGMA RESTRICT_REFERENCES(DEFAULT, WNPS, RNPS)
);

show errors;

Rem ********************** END OF XMLTYPE ADDITIONS **************************

GRANT EXECUTE ON XmlType TO PUBLIC with grant option
/
create public synoNYM XMLType for sys.xmltype;


Rem ********************* XMLGenFormatType Definition ***********************
Rem ** IMPORTANT: When adding new attributes or functions to xmlgenformattype
Rem **  you MUST also drop these methods in the downgrade (e***.sql) and
Rem **  do an alter type add of them in the upgrade (c***.sql).
Rem *************************************************************************

create or replace type XMLGenFormatType OID '00000000000000000000000000020102'
  as object
(
  enclTag varchar2(4000),   -- the name for the enclosing tag
  schemaType varchar2(100), -- one of 'NO_SCHEMA', 'GEN_SCHEMA_INLINE',
                            -- 'GEN_SCHEMA_OUTOFLINE', 'USE_GIVEN_SCHEMA'
  schemaName      varchar2(4000), -- the schema name (if USE_GIVEN_SCHEMA)
  targetNameSpace varchar2(4000), -- the target name space (default NULL)
  dbUrlPrefix   varchar2(4000),  -- the url prefix to use for outofline schemas
  processingIns varchar2(4000),-- processing instructions to add, if any,A
  controlflag raw(4),
  STATIC FUNCTION createFormat(
     enclTag IN varchar2 := 'ROWSET',
     schemaType IN varchar2 := 'NO_SCHEMA',
     schemaName IN varchar2 := null,
     targetNameSpace IN varchar2 := null,
     dburlPrefix IN varchar2 := null, 
     processingIns IN varchar2 := null) RETURN XMLGenFormatType
       deterministic parallel_enable,
  MEMBER PROCEDURE genSchema (spec IN varchar2),
  MEMBER PROCEDURE setSchemaName(schemaName IN varchar2),
  MEMBER PROCEDURE setTargetNameSpace(targetNameSpace IN varchar2),
  MEMBER PROCEDURE setEnclosingElementName(enclTag IN varchar2), 
  MEMBER PROCEDURE setDbUrlPrefix(prefix IN varchar2),
  MEMBER PROCEDURE setProcessingIns(pi IN varchar2),
  CONSTRUCTOR FUNCTION XMLGenFormatType (
     enclTag IN varchar2 := 'ROWSET',
     schemaType IN varchar2 := 'NO_SCHEMA',
     schemaName IN varchar2 := null,
     targetNameSpace IN varchar2 := null,
     dbUrlPrefix IN varchar2 := null, 
     processingIns IN varchar2 := null) RETURN SELF AS RESULT
      deterministic parallel_enable,
  STATIC function createFormat2(
      enclTag in varchar2 := 'ROWSET',
      flags in raw) return sys.xmlgenformattype 
      deterministic parallel_enable
);
/

show errors;
Rem *************************************************************************

grant execute on XMLGenFormatType to public with grant option;
create public synonym xmlformat for sys.xmlgenformattype;


Rem varray of varchars to allow processing instructions, comments,
Rem namespaces, prefixes, etc...!
Rem drop type XMLTypeExtra;
Rem drop type XMLTypePI;
create type XMLTypePI OID '0000000000000000000000000002014F' as
varray(2147483647) of RAW(2000);
/
create type XMLTypeExtra OID '00000000000000000000000000020150' as object
(
  namespaces  XMLTypePI,
  extraData   XMLTypePI
); 
/
grant execute on XMLTypePI to public with grant option;
grant execute on XMLTypeExtra to public with grant option;


create or replace type XMLSequenceType OID '00000000000000000000000000020153'
as varray(2147483647) of XMLType;
/
show errors;

Grant execute on XMLSequenceType to public with grant option;

create or replace public synonym XMLSequenceType for sys.XMLSequenceType;

-- SET UP FOR C IMP OF XMLSEQUENCE TABLE FUNCTION

-- drop types for imp of table function
drop public synonym XMLSequence;
drop operator XMLSequence;
drop function XMLSequenceFromXMLType;
drop function XMLSequenceFromRefCursor;
drop function XMLSequenceFromRefCursor2;
drop type XMLSeq_Imp_t;
drop type XQSeq_Imp_t;
drop type XMLSeqCur_Imp_t;
drop type XMLSeqCur2_Imp_t;

create or replace type XMLSeq_Imp_t OID '00000000000000000000000000020161'
authid current_user as object
(
  key RAW(8),
  static function ODCITableStart(sctx OUT XMLSeq_Imp_t,
                                 rws_ptr IN RAW,
                                 doc in XMLType)
                  return PLS_INTEGER
    is
    language C
    library XMLtype_lib
    name "XMLSeqStartStub"
    with context
    parameters (
      context,
      sctx,
      sctx INDICATOR STRUCT,
      rws_ptr OCIRAW,
      doc,
      doc INDICATOR sb4,
      return INT
    ),
  
  member function ODCITableFetch(self IN OUT XMLSeq_Imp_t, nrows IN Number, 
                               xmlseq OUT XMLSequenceType) return PLS_INTEGER
    as language C
    library XMLtype_lib
    name "XMLSeqFetchStub"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      nrows,
      xmlseq OCIColl,
      xmlseq INDICATOR sb2,
      xmlseq DURATION OCIDuration,
      return INT
    ),

  member function ODCITableClose(self IN XMLSeq_Imp_t) return PLS_INTEGER
    as language C
    library XMLtype_lib
    name "XMLSeqCloseStub"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      return INT
    )
);
/
show errors

create or replace type XQSeq_Imp_t OID '00000000000000000000000000020162'
authid current_user as object
(
  key RAW(8),
  static function ODCITableStart(sctx OUT XQSeq_Imp_t,
                                 rws_ptr IN RAW,
                                 doc in XMLType)
                  return PLS_INTEGER
    is
    language C
    library XMLtype_lib
    name "XQSeqStartStub"
    with context
    parameters (
      context,
      sctx,
      sctx INDICATOR STRUCT,
      rws_ptr OCIRAW,
      doc,
      doc INDICATOR sb4,
      return INT
    ),
  
  member function ODCITableFetch(self IN OUT XQSeq_Imp_t, nrows IN Number, 
                               xmlseq OUT XMLSequenceType) return PLS_INTEGER
    as language C
    library XMLtype_lib
    name "XQSeqFetchStub"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      nrows,
      xmlseq OCIColl,
      xmlseq INDICATOR sb2,
      xmlseq DURATION OCIDuration,
      return INT
    ),

  member function ODCITableClose(self IN XQSeq_Imp_t) return PLS_INTEGER
    as language C
    library XMLtype_lib
    name "XQSeqCloseStub"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      return INT
    )
);
/

create or replace function XMLSequenceFromXMLType(doc in sys.XMLType)
       return sys.XMLSequenceType authid current_user
pipelined using XMLSeq_Imp_t;
/

create or replace function XQSequenceFromXMLType(doc in sys.XMLType)
       return sys.XMLSequenceType authid current_user
pipelined using XQSeq_Imp_t;
/

show errors;


-- Ref Cursor version of XMLSequence with format

create or replace type XMLSeqCur_Imp_t OID '00000000000000000000000000020163'
authid current_user as object
(
  key RAW(8),
  static function ODCITableStart(sctx OUT XMLSeqCur_Imp_t,
                                 data SYS_REFCURSOR,
                                 format IN XMLFormat)
                  return PLS_INTEGER
    is
    language C
    library XMLtype_lib
    name "XMLSeqCurStartStub"
    with context
    parameters (
      context,
      sctx,
      sctx INDICATOR STRUCT,
      data,
      data INDICATOR sb4,
      format,
      format INDICATOR STRUCT,
      return INT
    ),
  
  member function ODCITableFetch(self IN OUT XMLSeqCur_Imp_t, nrows IN Number, 
                                 xmlseq OUT XMLSequenceType) return PLS_INTEGER
    as language C
    library XMLtype_lib
    name "XMLSeqCurFetchStub"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      nrows,
      xmlseq OCIColl,
      xmlseq INDICATOR sb2,
      xmlseq DURATION OCIDuration,
      return INT
    ),

  member function ODCITableClose(self IN XMLSeqCur_Imp_t) return PLS_INTEGER
    as language C
    library XMLtype_lib
    name "XMLSeqCurCloseStub"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      return INT
    )
 
);
/
show errors


-- Ref Cursor version of XMLSequence without format

create or replace type XMLSeqCur2_Imp_t OID '00000000000000000000000000020164'
authid current_user as object
(
  key RAW(8),
  static function ODCITableStart(sctx OUT XMLSeqCur2_Imp_t,
                                 data SYS_REFCURSOR)
                  return PLS_INTEGER
    is
    language C
    library XMLtype_lib
    name "XMLSeqCurStartStub2"
    with context
    parameters (
      context,
      sctx,
      sctx INDICATOR STRUCT,
      data,
      data INDICATOR sb4,
      return INT
    ),
  
  member function ODCITableFetch(self IN OUT XMLSeqCur2_Imp_t, nrows IN Number,
                                 xmlseq OUT XMLSequenceType) return PLS_INTEGER
    as language C
    library XMLtype_lib
    name "XMLSeqCurFetchStub"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      nrows,
      xmlseq OCIColl,
      xmlseq INDICATOR sb2,
      xmlseq DURATION OCIDuration,
      return INT
    ),

  member function ODCITableClose(self IN XMLSeqCur2_Imp_t) return PLS_INTEGER
    as language C
    library XMLtype_lib
    name "XMLSeqCurCloseStub"
    with context
    parameters (
      context,
      self,
      self INDICATOR STRUCT,
      return INT
    )
);
/
show errors;

create or replace function XMLSequenceFromRefCursor(data SYS_REFCURSOR,
                            format IN XMLFormat := NULL)
       return sys.XMLSequenceType authid current_user
pipelined using XMLSeqCur_Imp_t;
/
show errors;

create or replace function XMLSequenceFromRefCursor2( data SYS_REFCURSOR )
       return sys.XMLSequenceType authid current_user
pipelined using XMLSeqCur2_Imp_t;
/
show errors;

grant execute on XMLSequenceFromRefCursor to public;

grant execute on XMLSequenceFromRefCursor2 to public;

grant execute on XMLSequenceFromXMLType to public;

create or replace operator XMLSequence
  binding
  (sys.xmltype) return sys.XMLSequenceType
    using sys.XMLSequenceFromXMLType,
  (standard.SYS_REFCURSOR, XMLGenFormatType) return sys.XMLSequenceType
    using sys.XMLSequenceFromRefCursor,
  (standard.SYS_REFCURSOR) return sys.XMLSequenceType
    using sys.XMLSequenceFromRefCursor2;

grant execute on XQSequenceFromXMLType to public;

create or replace operator XQSequence
  binding
  (sys.xmltype) return sys.XMLSequenceType
    using sys.XQSequenceFromXMLType;

grant execute on XMLSequence to public with grant option;
grant execute on XQSequence to public with grant option;


create or replace public synonym XMLSequence for XMLSequence;
create or replace public synonym XQSequence for XQSequence;

drop type AggXMLImp;

-- create Aggregate XML implementation
create or replace type AggXMLImp OID '00000000000000000000000000020101'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT AggXMLImp, outopn IN RAW, 
                                          inpopn IN RAW ) return pls_integer
    is language c
    name "AggInitialize"
    library XMLtype_lib
    with context
    parameters (
      context,
      sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
      outopn OCIRaw,
      inpopn OCIRaw,
      return INT
    ),

  member function ODCIAggregateIterate(self IN OUT NOCOPY AggXMLImp,
                                       value IN sys.xmltype) return pls_integer
    is language c
    name "AggIterate"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      value, value INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateTerminate(self IN OUT NOCOPY AggXMLImp,
                                         returnValue OUT sys.XMLType,
                                         flags IN number)
                  return pls_integer
    is language c
    name "AggTerminate"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      returnValue, returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
      flags, flags INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateMerge(self IN OUT NOCOPY AggXMLImp,
                                     valueB IN AggXMLImp) return pls_integer
    is language c
    name "AggMerge"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      valueB, valueB INDICATOR STRUCT,
      return INT
    ),

  member function ODCIAggregateWrapContext(self IN OUT NOCOPY AggXMLImp)
                  return pls_integer
    is language c
    name "AggWrap"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      return INT
    )
);
/
show errors;

drop type AggXQImp;

-- Add new XQuery Agg operator
-- create Aggregate XQuery implementation
create or replace type AggXQImp OID '0000000000000000000000000002015F'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT AggXQImp, outopn IN RAW, 
                                          inpopn IN RAW ) return pls_integer
    is language c
    name "XQAggInitialize"
    library XMLtype_lib
    with context
    parameters(
      context,
      sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
      outopn OCIRaw,
      inpopn OCIRaw,
      return INT
    ),

  member function ODCIAggregateIterate(self IN OUT NOCOPY AggXQImp,
                                       value IN sys.xmltype) return pls_integer
    is language c
    name "XQAggIterate"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      value, value INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateTerminate(self IN OUT NOCOPY AggXQImp,
                                         returnValue OUT sys.XMLType,
                                         flags IN number)
                  return pls_integer
    is language c
    name "XQAggTerminate"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      returnValue, returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
      flags, flags INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateMerge(self IN OUT NOCOPY AggXQImp,
                                     valueB IN AggXQImp) return pls_integer
    is language c
    name "XQAggMerge"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      valueB, valueB INDICATOR STRUCT,
      return INT
    ),

  member function ODCIAggregateWrapContext(self IN OUT NOCOPY AggXQImp)
                  return pls_integer
    is language c
    name "XQAggWrap"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      return INT
    )
);
/
show errors;

create or replace function SYS_IXMLAGG(input sys.xmltype) return sys.xmltype
aggregate using AggXMLImp;
/

create or replace function 
  SYS_XMLAGG(input sys.xmltype, format sys.XMLGenFormatType := null) 
  return sys.xmltype as
 begin
   null;
 end;
/

create or replace function SYS_IXQAGG(input sys.xmltype) return sys.xmltype
aggregate using AggXQImp;
/

grant execute on SYS_XMLAGG to public;
grant execute on SYS_IXMLAGG to public;
grant execute on SYS_IXQAGG to public;

create or replace public synonym SYS_XMLAGG for SYS_XMLAGG;

create or replace public synonym XMLAGG     for SYS_IXMLAGG;

create or replace public synonym SYS_IXQAGG for SYS_IXQAGG;


-- XQuery Window Sequence support
-- xqwindow sequence
drop type XQWindowSeq_Imp_t;
-- drop types for imp of table function
drop public synonym XQWindowSequence;
drop operator XQWindowSequence;
drop function XQWindowSequenceFromXMLType;

-- XQWindowSeq implementation Type  XQWindowSeq_Imp_t
create or replace type XQWindowSeq_Imp_t authid current_user as object
(
   key RAW(8),
   static function ODCITableStart(sctx OUT XQWindowSeq_Imp_t,
                                  rws_ptr IN RAW,
                                  doc in XMLType,
                                  flag in number,
                                  startExpr in varchar2,
                                  endExpr in varchar2,
                                  curItem in XMLType,
                                  prevItem in XMLType,
                                  nextItem in XMLType,
                                  position in XMLType,
                                  ecurItem in XMLType,
                                  eprevItem in XMLType,
                                  enextItem in XMLType,
                                  eposition in XMLType
                           )
                   return PLS_INTEGER
     is
     language C
     library XMLtype_lib
     name "XQWindowSeqStartStub"
     with context
     parameters (
       context,
       sctx,
       sctx INDICATOR STRUCT,
       rws_ptr OCIRAW,
       doc, -- input source XMLType(Sequence) to window function
       doc INDICATOR sb4,
       flag, -- input flags for window parameters
       flag INDICATOR sb4,
       startExpr, -- window startExpression
       startExpr INDICATOR sb4,
       endExpr, -- window endExpression
       endExpr INDICATOR sb4,
       curItem, -- window curItem
       curItem INDICATOR sb4,
       prevItem, -- window prevItem
       prevItem INDICATOR sb4,
       nextItem, -- window nextItem
       nextItem INDICATOR sb4,
       position, -- window item position
       position INDICATOR sb4,
       ecurItem, -- window curItem
       ecurItem INDICATOR sb4,
       eprevItem, -- window prevItem
       eprevItem INDICATOR sb4,
       enextItem, -- window nextItem
       enextItem INDICATOR sb4,
       eposition, -- window item position
       eposition INDICATOR sb4,
       return INT
     ),
   
   member function ODCITableFetch(self IN OUT XQWindowSeq_Imp_t, nrows IN Number, 
                                xmlseq OUT XMLSequenceType) return PLS_INTEGER
     as language C
     library XMLtype_lib
     name "XQWindowSeqFetchStub"
     with context
     parameters (
       context,
       self,
       self INDICATOR STRUCT,
       nrows,
       xmlseq OCIColl,
       xmlseq INDICATOR sb2,
       xmlseq DURATION OCIDuration,
       return INT
     ),
 
   member function ODCITableClose(self IN XQWindowSeq_Imp_t) return PLS_INTEGER
     as language C
     library XMLtype_lib
     name "XQWindowSeqCloseStub"
     with context
     parameters (
       context,
       self,
       self INDICATOR STRUCT,
       return INT
     )
)
/
 
show errors;
-- XQWindowSeq function
-- The doc represents the input XMLType(Sequence).
-- Window function flag field tracks what type of window with various
-- flags. The startexpr and endexpr are xquery expressions that
-- return 1 (true) or 0(false)  for window boundaries.
create or replace function XQWindowSequenceFromXMLType(doc in sys.XMLType,
        flag in number, startexpr in varchar2, endexpr in varchar2,
        curItem in sys.XMLType, prevItem in sys.XMLType,
        nextItem in sys.XMLType, position in sys.XMLType,
        ecurItem in sys.XMLType, eprevItem in sys.XMLType,
        enextItem in sys.XMLType, eposition in sys.XMLType
        )
        return sys.XMLSequenceType authid current_user
 pipelined using XQWindowSeq_Imp_t;
/
show errors;
 
grant execute on XQWindowSequenceFromXMLType to public;
 
-- XQWindowSequence operator
create or replace operator XQWindowSequence
   binding
   (sys.xmltype, number, varchar2, varchar2, 
    sys.xmltype, sys.xmltype, sys.xmltype, sys.xmltype,
    sys.xmltype, sys.xmltype, sys.xmltype, sys.xmltype)
    return sys.XMLSequenceType
     using sys.XQWindowSequenceFromXMLType;
show errors;
 
grant execute on XQWindowSequence to public with grant option;
create or replace public synonym XQWindowSequence for XQWindowSequence;
show errors;



-- Add new XQuery sum() Agg operator
-- create Aggregate XQuery sum() implementation
create or replace type AggXQSumImp OID '0000000000000000000000000002016F'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT AggXQSumImp, outopn IN RAW, 
                                          inpopn IN RAW ) return pls_integer
    is language c
    name "XQAggSumInitialize"
    library XMLtype_lib
    with context
    parameters(
      context,
      sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
      outopn OCIRaw,
      inpopn OCIRaw,
      return INT
    ),

  member function ODCIAggregateIterate(self IN OUT NOCOPY AggXQSumImp,
                                       value IN sys.xmltype) return pls_integer
    is language c
    name "XQAggSumIterate"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      value, value INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateTerminate(self IN OUT NOCOPY AggXQSumImp,
                                         returnValue OUT sys.XMLType,
                                         flags IN number)
                  return pls_integer
    is language c
    name "XQAggSumTerminate"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      returnValue, returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
      flags, flags INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateMerge(self IN OUT NOCOPY AggXQSumImp,
                                     valueB IN AggXQSumImp) return pls_integer
    is language c
    name "XQAggSumMerge"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      valueB, valueB INDICATOR STRUCT,
      return INT
    ),

  member function ODCIAggregateWrapContext(self IN OUT NOCOPY AggXQSumImp)
                  return pls_integer
    is language c
    name "XQAggSumWrap"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      return INT
    )
);
/
show errors;


create or replace function SYS_IXQAGGSUM(input sys.xmltype) return sys.xmltype
aggregate using AggXQSumImp;
/
show errors;

grant execute on SYS_IXQAGGSUM to public;
show errors;
    

create or replace public synonym SYS_IXQAGGSUM for SYS_IXQAGGSUM;
show errors;
    

-- Add new XQuery avg() Agg operator
-- create Aggregate XQuery avg() implementation
create or replace type AggXQAvgImp OID '0000000000000000000000000002017F'
   authid current_user as object
(
  key RAW(8),

  static function ODCIAggregateInitialize(sctx OUT AggXQAvgImp, outopn IN RAW, 
                                          inpopn IN RAW ) return pls_integer
    is language c
    name "XQAggAvgInitialize"
    library XMLtype_lib
    with context
    parameters(
      context,
      sctx, sctx INDICATOR STRUCT, sctx DURATION OCIDuration,
      outopn OCIRaw,
      inpopn OCIRaw,
      return INT
    ),

  member function ODCIAggregateIterate(self IN OUT NOCOPY AggXQAvgImp,
                                       value IN sys.xmltype) return pls_integer
    is language c
    name "XQAggAvgIterate"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      value, value INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateTerminate(self IN OUT NOCOPY AggXQAvgImp,
                                         returnValue OUT sys.XMLType,
                                         flags IN number)
                  return pls_integer
    is language c
    name "XQAggAvgTerminate"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT,
      returnValue, returnValue INDICATOR sb2, returnValue DURATION OCIDuration,
      flags, flags INDICATOR sb2,
      return INT
    ),

  member function ODCIAggregateMerge(self IN OUT NOCOPY AggXQAvgImp,
                                     valueB IN AggXQAvgImp) return pls_integer
    is language c
    name "XQAggAvgMerge"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      valueB, valueB INDICATOR STRUCT,
      return INT
    ),

  member function ODCIAggregateWrapContext(self IN OUT NOCOPY AggXQAvgImp)
                  return pls_integer
    is language c
    name "XQAggAvgWrap"
    library xmltype_lib
    with context
    parameters (
      context,
      self, self INDICATOR STRUCT, self DURATION OCIDuration,
      return INT
    )
);
/

show errors;

create or replace function SYS_IXQAGGAVG(input sys.xmltype) return sys.xmltype
aggregate using AggXQAvgImp;
/
show errors;

grant execute on SYS_IXQAGGAVG to public;
show errors;


create or replace public synonym SYS_IXQAGGAVG for SYS_IXQAGGAVG;
show errors;

