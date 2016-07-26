Rem
Rem $Header: rdbms/admin/dbmsany.sql /main/16 2009/02/17 16:49:09 skabraha Exp $
Rem
Rem dbmsany.sql
Rem
Rem Copyright (c) 2000, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsany.sql - Package DBMS_TYPES and types SYS.AnyData etc.
Rem
Rem    DESCRIPTION
Rem      This file has the specification of the types SYS.AnyData, SYS.AnyType
Rem      and SYS.AnyDataSet that allow modeling of self-descriptive data in
Rem      the DBMS.
Rem
Rem    NOTES
Rem      This script should be run while connected as "SYS".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skabraha    02/09/09 - bug #7446912: anytype.getinfo parameter
Rem    atomar      09/28/06 - bug 5350076
Rem    atomar      09/20/06 - bug 5350076
Rem    rxgovind    10/13/02 - update
Rem    rxgovind    10/06/02 - add support for Float, Double etc
Rem    rxgovind    01/21/02 - use deterministic etc. for fn. indexes
Rem    rxgovind    01/14/02 - bug:2167560 - use create library
Rem    rxgovind    11/07/01 - use alter type replace for new methods
Rem    celsbern    10/19/01 - merge LOG to MAIN
Rem    rxgovind    10/16/01 - update typecodes
Rem    rxgovind    10/11/01 - add TYPECODE_NCHAR etc
Rem    rxgovind    10/03/01 - update for nchar functions
Rem    rxgovind    09/28/01 - add new anydata functions
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    rxgovind    04/20/01 - add GetTvoid
Rem    sursrini    01/17/01 - 1379531:Fixed and hence changing IN OUT to OUT in
Rem                           GetRef.
Rem    rxgovind    12/04/00 - use OID clause
Rem    rxgovind    10/26/00 - workaround problems with REF OUT params
Rem    rxgovind    09/13/00 - update
Rem    jdavison    07/27/00 - Remove unnecessary semicolons.
Rem    rxgovind    07/20/00 - update
Rem    rxgovind    07/19/00 - update
Rem    rxgovind    06/19/00 - update
Rem    rxgovind    06/01/00 - update
Rem    rxgovind    05/22/00 - Created
Rem

-- Create the trusted PL/SQL callout library.
CREATE LIBRARY DBMS_ANYTYPE_LIB TRUSTED AS STATIC
/

CREATE LIBRARY DBMS_ANYDATA_LIB TRUSTED AS STATIC
/

CREATE LIBRARY DBMS_ANYDATASET_LIB TRUSTED AS STATIC
/

CREATE OR REPLACE PACKAGE dbms_types AS
  TYPECODE_DATE            PLS_INTEGER :=  12;
  TYPECODE_NUMBER          PLS_INTEGER :=   2;
  TYPECODE_RAW             PLS_INTEGER :=  95;
  TYPECODE_CHAR            PLS_INTEGER :=  96;
  TYPECODE_VARCHAR2        PLS_INTEGER :=   9;
  TYPECODE_VARCHAR         PLS_INTEGER :=   1;
  TYPECODE_MLSLABEL        PLS_INTEGER := 105;
  TYPECODE_BLOB            PLS_INTEGER := 113;
  TYPECODE_BFILE           PLS_INTEGER := 114;
  TYPECODE_CLOB            PLS_INTEGER := 112;
  TYPECODE_CFILE           PLS_INTEGER := 115;
  TYPECODE_TIMESTAMP       PLS_INTEGER := 187;
  TYPECODE_TIMESTAMP_TZ    PLS_INTEGER := 188;
  TYPECODE_TIMESTAMP_LTZ   PLS_INTEGER := 232;
  TYPECODE_INTERVAL_YM     PLS_INTEGER := 189;
  TYPECODE_INTERVAL_DS     PLS_INTEGER := 190;

  TYPECODE_REF             PLS_INTEGER := 110;
  TYPECODE_OBJECT          PLS_INTEGER := 108;
  TYPECODE_VARRAY          PLS_INTEGER := 247;            /* COLLECTION TYPE */
  TYPECODE_TABLE           PLS_INTEGER := 248;            /* COLLECTION TYPE */
  TYPECODE_NAMEDCOLLECTION PLS_INTEGER := 122;
  TYPECODE_OPAQUE          PLS_INTEGER := 58;                 /* OPAQUE TYPE */

  /* NOTE: These typecodes are for use in AnyData api only and are short forms
     for the corresponding char typecodes with a charset form of SQLCS_NCHAR.
  */
  TYPECODE_NCHAR           PLS_INTEGER := 286;
  TYPECODE_NVARCHAR2       PLS_INTEGER := 287;
  TYPECODE_NCLOB           PLS_INTEGER := 288;

  /* Typecodes for Binary Float, Binary Double and Urowid. */
  TYPECODE_BFLOAT          PLS_INTEGER := 100;
  TYPECODE_BDOUBLE         PLS_INTEGER := 101;
  TYPECODE_UROWID          PLS_INTEGER := 104;

  SUCCESS                  PLS_INTEGER := 0;
  NO_DATA                  PLS_INTEGER := 100;
  
  /* Exceptions */
  invalid_parameters EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_parameters, -22369);

  incorrect_usage EXCEPTION;
  PRAGMA EXCEPTION_INIT(incorrect_usage, -22370);
       
  type_mismatch EXCEPTION;
  PRAGMA EXCEPTION_INIT(type_mismatch, -22626);

END dbms_types;
/
show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_types FOR sys.dbms_types
/
GRANT EXECUTE ON dbms_types TO public
/

-- Type SYS.AnyType.
CREATE OR REPLACE TYPE ANYTYPE OID '00000000000000000000000000020010'
AS OPAQUE VARYING (*)
USING library DBMS_ANYTYPE_LIB
(

  /* NAME
         BeginCreate()
     DESCRIPTION
         Creates a new instance of ANYTYPE which can be used to create a
         transient type Description.
     PARAMETERS
         typecode - Use a constant from DBMS_TYPES package.
                    Typecodes for  user-defined type:
                     can be  DBMS_TYPES.TYPECODE_OBJECT
                             DBMS_TYPES.TYPECODE_VARRAY or
                             DBMS_TYPES.TYPECODE_TABLE
                    Typecodes for builtin types:
                             DBMS_TYPES.TYPECODE_NUMBER etc.
         atype - AnyType for a transient-type.
          
     EXCEPTIONS
  */
  STATIC PROCEDURE BeginCreate(typecode IN PLS_INTEGER,
                               atype OUT NOCOPY AnyType),

  /*
     NAME
         SetInfo
     DESCRIPTION
          This procedure sets any additional information required for
          constructing a COLLECTION or builtin type.
          NOTE: It is an error to call this function on an ANYTYPE that
                represents a persistent user defined type.
     PARAMETERS
          self     - The transient ANYTYPE that is being constructed.

          prec, scale (OPTIONAL) - REQUIRED IF TYPECODE REPRESENTS A NUMBER.
                                   Give precision and scale. ignored otherwise.

          len (OPTIONAL) - REQUIRED IF TYPECODE REPRESENTS A RAW, CHAR,
                           VARCHAR, VARCHAR2 types. Gives length.

          csid, csfrm (OPTIONAL) -  REQUIRED IF TYPECODE REPRESENTS Types
                                    requiring character info. For eg: CHAR,
                                    VARCHAR, VARCHAR2, CFILE.
   
          atype (OPTIONAL)     - REQUIRED IF collection element TYPECODE IS
                                 a user-defined type like TYPECODE_OBJECT
                                 etc. It is also required for a built-in type
                                 that needs user-defined type information
                                 such as TYPECODE_REF. This parameter is not
                                 needed otherwise.

          The following parameters are required for Collection types:

          elem_tc (OPTIONAL)   - Must be of the collection element's typecode
                                 (from DBMS_TYPES package).
          elem_count (OPTIONAL) - Pass 0 for elem_count if the self represents
                                  a nested table (TYPECODE_TABLE). Otherwise
                                  pass the collection count if self represents
                                  a VARRAY.
     EXCEPTIONS
          - DBMS_TYPES.invalid_parameters
            Invalid Parameters (typecode, typeinfo)
          - DBMS_TYPES.incorrect_usage
            incorrect usage (cannot call after calling EndCreate()
                             etc.)
  */
  MEMBER PROCEDURE SetInfo(self IN OUT NOCOPY AnyType,
           prec IN PLS_INTEGER, scale IN PLS_INTEGER,
           len IN PLS_INTEGER,
           csid IN PLS_INTEGER, csfrm IN PLS_INTEGER,
           atype IN ANYTYPE DEFAULT NULL,
           elem_tc IN PLS_INTEGER DEFAULT NULL,
           elem_count IN PLS_INTEGER DEFAULT 0),
  
  /* 
     NAME
          AddAttr
     DESCRIPTION
          This procedure Adds an attribute to an AnyType (of typecode
          DBMS_TYPES.TYPECODE_OBJECT)
     PARAMETERS
          self     - The transient ANYTYPE that is being constructed.
                     Must be of Type DBMS_TYPES.TYPECODE_OBJECT.

          aname (OPTIONAL) - Attribute's name. Could be null.

          typecode - Attribute's typecode. Can be builtin or user-defined.
                     typecode (from DBMS_TYPES package).

          prec, scale (OPTIONAL) - REQUIRED IF TYPECODE REPRESENTS A NUMBER.
                                   Give precision and scale. ignored otherwise.

          len (OPTIONAL) - REQUIRED IF TYPECODE REPRESENTS A RAW, CHAR,
                           VARCHAR, VARCHAR2 types. Gives length.

          csid, csfrm (OPTIONAL) -  REQUIRED IF TYPECODE REPRESENTS Types
                                    requiring character info. For eg: CHAR,
                                    VARCHAR, VARCHAR2, CFILE.

          attr_type (OPTIONAL) - AnyType corresponding to a User defined Type.
                                 This parameter is required if the attribute is
                                 a user defined type.
       EXCEPTIONS
          - DBMS_TYPES.invalid_parameters
            Invalid Parameters (typecode, typeinfo)
          - DBMS_TYPES.incorrect_usage
            incorrect usage (cannot call after calling EndCreate()
                             etc.)
  */
  MEMBER PROCEDURE AddAttr(self IN OUT NOCOPY AnyType,
           aname IN VARCHAR2,
           typecode IN PLS_INTEGER,
           prec IN PLS_INTEGER, scale IN PLS_INTEGER,
           len IN PLS_INTEGER,
           csid IN PLS_INTEGER, csfrm IN PLS_INTEGER,
           attr_type IN ANYTYPE DEFAULT NULL),
                                  

  /*
     NAME
          EndCreate
     DESCRIPTION
          Ends Creation of a transient AnyType. Other creation functions cannot
          be called after this call.
  */
  MEMBER PROCEDURE EndCreate(self IN OUT NOCOPY AnyType),

  /* NAME
         GetPersistent()
     DESCRIPTION
         Returns an ANYTYPE corresponding to a persistent type created
         earlier using the CREATE TYPE SQL statement.
     PARAMETERS
          schema_name - Schema name of the type.
          type_name - Type name.
          version - Type version.
      EXCEPTIONS
  */
  STATIC FUNCTION GetPersistent(schema_name IN VARCHAR2,
                      type_name IN VARCHAR2,
                      version IN varchar2 DEFAULT NULL) return AnyType,

/* ANYTYPE ACCESSOR FUNCTIONS */

  /* 
     NAME
          GetInfo
     DESCRIPTION
          Get the Type Information for the ANYTYPE

     PARAMETERS
          prec, scale  - IF TYPECODE REPRESENTS A NUMBER.
                         Give precision and scale. ignored otherwise.

          len  - IF TYPECODE REPRESENTS A RAW, CHAR,
                 VARCHAR, VARCHAR2 types. Gives length.

          csid, csfrm -  IF TYPECODE REPRESENTS Types
                         requiring character info. For eg: CHAR,
                         VARCHAR, VARCHAR2, CFILE.
          schema_name, type_name, version - Type's schema (if persistent),
                                            typename and version.

          numelems - if self is a VARRAY, this gives the varray count.
                  if self is of TYPECODE_OBJECT, this gives the number of
                  attributes.

     RETURNS
          The typecode of self.

     EXCEPTIONS
          - DBMS_TYPES.invalid_parameters
            Invalid Parameters (position is beyond bounds or
                                the AnyType is not properly Constructed).)
  */
  MEMBER FUNCTION GetInfo (self IN AnyType,
       prec OUT PLS_INTEGER, scale OUT PLS_INTEGER,
       len OUT PLS_INTEGER, csid OUT PLS_INTEGER,
       csfrm OUT PLS_INTEGER,
       schema_name OUT VARCHAR2, type_name OUT VARCHAR2, version OUT varchar2,
       numelems OUT PLS_INTEGER)
                 return PLS_INTEGER,


  /* 
     NAME
          GetAttrElemInfo
     DESCRIPTION
          Gets the Type Information for an attribute of the
          type (if it is of TYPECODE_OBJECT)
          Gets the Type Information for a collection's element type if the
          self parameter is of a collection type.
     PARAMETERS
          position  - If self is of TYPECODE_OBJECT, this gives the attribute
                      position (starting at 1). It is ignored otherwise.

          prec, scale  - IF attribute/collection element TYPECODE
                         REPRESENTS A NUMBER. gives precision and scale.
                         ignored otherwise.

          len  - IF attribute/collection element TYPECODE REPRESENTS A RAW,
                 CHAR, VARCHAR, VARCHAR2 types. Gives length.

          csid, csfrm -  IF attribute/collection element TYPECODE REPRESENTS
                         Types requiring character info. For eg: CHAR,
                         VARCHAR, VARCHAR2, CFILE, gives charset id etc.

          attr_elt_type - IF attribute/collection element TYPECODE REPRESENTS
                         a user-defined type, this returns the ANYTYPE
                         corresponding to it. User can subsequently describe
                         the attr_elt_type.
          aname  - Attribute name (if it is an attribute of an object type.
                   NULL otherwise.

     RETURNS
          The typecode of the attribute or collection element.

     EXCEPTIONS
          - DBMS_TYPES.invalid_parameters
            Invalid Parameters (position is beyond bounds or
                                the AnyType is not properly Constructed).)
  */
  MEMBER FUNCTION GetAttrElemInfo (self IN AnyType, pos IN PLS_INTEGER,
       prec OUT PLS_INTEGER, scale OUT PLS_INTEGER,
       len OUT PLS_INTEGER, csid OUT PLS_INTEGER, csfrm OUT PLS_INTEGER,
       attr_elt_type OUT ANYTYPE, aname OUT VARCHAR2) return PLS_INTEGER

);
/
show errors

GRANT EXECUTE ON AnyType TO public WITH GRANT OPTION
/

CREATE OR REPLACE PUBLIC SYNONYM AnyType for SYS.AnyType
/

Rem ************************** AnyData Definition ***************************
Rem ** IMPORTANT: The create or replace AnyData is FROZEN as of 9.0.1.1.0.
Rem ** All new additions to AnyData must be placed in the ALTER TYPE REPLACE
Rem ** following the create or replace type.
Rem *************************************************************************

-- Type SYS.AnyData - SQL type corresponding to OCIAnyData
CREATE OR REPLACE TYPE AnyData OID '00000000000000000000000000020011'
as OPAQUE VARYING (*)
USING library DBMS_ANYDATA_LIB
(
  /* CONSTRUCTION */
  /* There are 2 ways to construct an AnyData. The Convert*() calls
     enable construction of the AnyData in its entirity with a single call.
     They serve as explicit CAST functions from any type in the Oracle ORDBMS
     to SYS.AnyData.
  */
  STATIC FUNCTION ConvertNumber(num IN NUMBER) return AnyData,
  STATIC FUNCTION ConvertDate(dat IN DATE) return AnyData,
  STATIC FUNCTION ConvertChar(c IN CHAR) return AnyData,
  STATIC FUNCTION ConvertVarchar(c IN VARCHAR) return AnyData,
  STATIC FUNCTION ConvertVarchar2(c IN VARCHAR2) return AnyData,
  STATIC FUNCTION ConvertRaw(r IN RAW) return AnyData,
  STATIC FUNCTION ConvertBlob(b IN BLOB) return AnyData,
  STATIC FUNCTION ConvertClob(c IN CLOB) return AnyData,
  STATIC FUNCTION ConvertBfile(b IN BFILE) return AnyData,
  STATIC FUNCTION ConvertObject(obj IN "<ADT_1>") return AnyData,
  STATIC FUNCTION ConvertObject(obj IN "<OPAQUE_1>") return AnyData,
  STATIC FUNCTION ConvertRef(rf IN REF "<ADT_1>") return AnyData,
  STATIC FUNCTION ConvertCollection(col IN "<COLLECTION_1>") return AnyData,

  /* The 2nd way to construct an AnyData is a piece by piece approach. The 
     BeginCreate() call begins the construction process and
     EndCreate() call finishes the construction process..
     In between these 2 calls, the individual attributes of an Object Type or
     the elements of a Collection can be set using Set*()calls.
     For piece by piece access of the attributes of Objects and elements of
     Collections, the PieceWise() call should be invoked prior to
     Get*() calls.
     Note: The AnyData has to be constructed or accessed sequentially starting
     from its first attribute(or collection element).
     The BeginCreate() call automatically begins the construction in a
     piece-wise mode. There is no need to call PieceWise() immediately
     after BeginCreate().
     EndCreate should be called to finish the construction
     process (before which no access calls can be made).
  */
 
  /* NAME
         BeginCreate
     DESCRIPTION
         Begins creation process on a new AnyData.
     PARAMETERS
         dtype - The Type of the AnyData. (should correspond to
                                           OCI_TYPECODE_OBJECT or
                                           a Collection typecode.)
         adata - AnyData being constructed.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           dtype is invalid (not fully constructed etc.).
     NOTE
         There is NO NEED to call PieceWise() immediately after this
     call. Automatically the construction process begins in a piece-wise
     manner.
  */
  STATIC PROCEDURE BeginCreate(dtype IN OUT NOCOPY AnyType,
                               adata OUT NOCOPY AnyData),

  /* NAME
         PieceWise.
     DESCRIPTION
         This call sets the MODE of access of the current data value to
         be an attribute at a time (if the data value is of TYPECODE_OBJECT).
         It sets the MODE of access of the data value to be a
         collection element at a time (if the data value is of
         collection TYPE). Once this call has been made, subsequent
         Set*'s and Get*'s will sequentially obtain
         individual attributes or collection elements.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
         - DBMS_TYPES.incorrect_usage
           On incorrect usage.
     NOTE
         The current data value must be of an OBJECT or COLLECTION type before
         this call can be made.
         Piece-wise construction and access of nested attributes that are of
         object or collection types is not supported. 
  */
  MEMBER PROCEDURE PieceWise(self IN OUT NOCOPY AnyData),

  /* NAME
         SetNumber, SetDate etc.
     DESCRIPTION
         Sets the current data value.
         This is a list of procedures that should be called depending on the
         type of the current data value.
         The type of the data value should be the type of the attribute at the
         current position during the piece-wise construction process.
         NOTE - When BeginCreate() is called, construction has already
                begun in a piece-wise fashion. Subsequent calls to
                Set*() will set the successive attribute values.
                If the AnyData is a standalone collection, the
                Set*() call will set the successive collection
                elements.
     PARAMETERS
         num - The Number that needs to be set. etc.

         last_elem - This parameter is relevant only if AnyData represents a
                     a collection.
                     Set to TRUE if it is the last element of the collection,
                     FALSE otherwise.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           Invalid Parameters (if it is not appropriate to add a number
                               at this point in the creation process).
         - DBMS_TYPES.incorrect_usage
           Incorrect usage
         - DBMS_TYPES.type_mismatch
           When the expected type is different from the passed in type.
     NOTE
         Sets the current data value.
  */
  MEMBER PROCEDURE SetNumber(self IN OUT NOCOPY AnyData, num IN NUMBER,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetDate(self IN OUT NOCOPY AnyData, dat IN DATE,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetChar(self IN OUT NOCOPY AnyData, c IN CHAR,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetVarchar(self IN OUT NOCOPY AnyData, c IN VARCHAR,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetVarchar2(self IN OUT NOCOPY AnyData,
                    c IN VARCHAR2, last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetRaw(self IN OUT NOCOPY AnyData, r IN RAW,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBlob(self IN OUT NOCOPY AnyData, b IN BLOB,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetClob(self IN OUT NOCOPY AnyData, c IN CLOB,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBfile(self IN OUT NOCOPY AnyData, b IN BFILE,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetObject(self IN OUT NOCOPY AnyData,
                    obj IN "<ADT_1>", last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetObject(self IN OUT NOCOPY AnyData,
                    obj IN "<OPAQUE_1>", last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetRef(self IN OUT NOCOPY AnyData,
                    rf IN REF "<ADT_1>", last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetCollection(self IN OUT NOCOPY AnyData,
                    col IN "<COLLECTION_1>", last_elem IN boolean DEFAULT FALSE),

  /*
     NAME
          EndCreate
     DESCRIPTION
          Ends Creation of a AnyData. Other creation functions cannot be
          called after this call.
  */
  MEMBER PROCEDURE EndCreate(self IN OUT NOCOPY AnyData),


  /* ----------------------------------------------------------------------- */
  /* ACCESSORS */
  /* ----------------------------------------------------------------------- */
  /* 
     NAME
          GetTypeName
     DESCRIPTION
          Get the fully qualified Type Name for the AnyData.
          If the AnyData is based on a builtin, this function will return
          NUMBER etc.
          If it is based on a user defined type, this function will return 
          <schema_name>.<type_name>. e.g. SCOTT.FOO.
          If it is based on a transient anonymous type, this function will
          return NULL.     
     RETURNS
          Type name of the AnyData.
  */
  MEMBER FUNCTION GetTypeName(self IN AnyData) return VARCHAR2,

  /* NAME
         GetType
     DESCRIPTION
         Gets the Type of the AnyData.
     PARAMETERS
         typ (OUT) - The AnyType corresponding to the AnyData. May be NULL
                     if it does not represent a user-defined type.
     RETURNS
         The typecode corresponding to the type of the AnyData.

     EXCEPTIONS
  */
  MEMBER FUNCTION GetType(self IN AnyData, typ OUT NOCOPY AnyType)
      return PLS_INTEGER,

  /* NAME
         Get*()
     DESCRIPTION
         Gets the current data value (which should be of appropriate type)
         The type of the current data value depends on the MODE with which
         we are accessing (Depending on whether we have invoked the
         PieceWise() call).
         If PieceWise() has NOT been called, we are accessing the
         AnyData in its entirety and the type of the data value should match
         the type of the AnyData.
         If PieceWise() has been called, we are accessing the
         AnyData piece wise. The type of the data value should match the type
         of the attribute (or collection element) at the current position.
     PARAMETERS
         num - The Number that needs to be got. etc.
     RETURNS
         DBMS_TYPES.SUCCESS or DBMS_TYPES.NO_DATA
         The return value is relevant only if PieceWise
         has been already called (for a collection). In such a case,
         DBMS_TYPES.NO_DATA signifies the end of the collection when all
         elements have been accessed.
     EXCEPTIONS
         - DBMS_TYPES.type_mismatch
           When the expected type is different from the passed in type.
         - DBMS_TYPES.invalid_parameters
           Invalid Parameters (if it is not appropriate to add a number
                               at this point in the creation process).
         - DBMS_TYPES.incorrect_usage
           Incorrect usage.
  */
  MEMBER FUNCTION GetNumber(self IN AnyData, num OUT NOCOPY NUMBER)
              return PLS_INTEGER,
  MEMBER FUNCTION GetDate(self IN AnyData, dat OUT NOCOPY DATE)
              return PLS_INTEGER,
  MEMBER FUNCTION GetChar(self IN AnyData, c OUT NOCOPY CHAR)
              return PLS_INTEGER,
  MEMBER FUNCTION GetVarchar(self IN AnyData, c OUT NOCOPY VARCHAR)
              return PLS_INTEGER,
  MEMBER FUNCTION GetVarchar2(self IN AnyData, c OUT NOCOPY VARCHAR2)
              return PLS_INTEGER,
  MEMBER FUNCTION GetRaw(self IN AnyData, r OUT NOCOPY RAW)
              return PLS_INTEGER,
  MEMBER FUNCTION GetBlob(self IN AnyData, b OUT NOCOPY BLOB)
              return PLS_INTEGER,
  MEMBER FUNCTION GetClob(self IN AnyData, c OUT NOCOPY CLOB)
              return PLS_INTEGER,
  MEMBER FUNCTION GetBfile(self IN AnyData, b OUT NOCOPY BFILE)
              return PLS_INTEGER,
  MEMBER FUNCTION GetObject(self IN AnyData, obj OUT NOCOPY "<ADT_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetObject(self IN AnyData, obj OUT NOCOPY "<OPAQUE_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetRef(self IN AnyData, rf OUT NOCOPY REF "<ADT_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetCollection(self IN AnyData,
                                col OUT NOCOPY "<COLLECTION_1>") 
                                return PLS_INTEGER
);
/
show errors

Rem *********************** ADDITIONS TO ANYDATA ****************************
Rem ** All additions to ANYDATA must be put here.
Rem *************************************************************************

ALTER TYPE SYS.AnyData REPLACE
as OPAQUE VARYING (*)
USING library DBMS_ANYDATA_LIB
(
  /* CONSTRUCTION */
  /* There are 2 ways to construct an AnyData. The Convert*() calls
     enable construction of the AnyData in its entirity with a single call.
     They serve as explicit CAST functions from any type in the Oracle ORDBMS
     to SYS.AnyData.
  */
  STATIC FUNCTION ConvertNumber(num IN NUMBER) return AnyData,
  STATIC FUNCTION ConvertDate(dat IN DATE) return AnyData,
  STATIC FUNCTION ConvertChar(c IN CHAR) return AnyData,
  STATIC FUNCTION ConvertVarchar(c IN VARCHAR) return AnyData,
  STATIC FUNCTION ConvertVarchar2(c IN VARCHAR2) return AnyData,
  STATIC FUNCTION ConvertRaw(r IN RAW) return AnyData,
  STATIC FUNCTION ConvertBlob(b IN BLOB) return AnyData,
  STATIC FUNCTION ConvertClob(c IN CLOB) return AnyData,
  STATIC FUNCTION ConvertBfile(b IN BFILE) return AnyData,
  STATIC FUNCTION ConvertObject(obj IN "<ADT_1>") return AnyData,
  STATIC FUNCTION ConvertObject(obj IN "<OPAQUE_1>") return AnyData,
  STATIC FUNCTION ConvertRef(rf IN REF "<ADT_1>") return AnyData,
  STATIC FUNCTION ConvertCollection(col IN "<COLLECTION_1>") return AnyData,
  /* The 2nd way to construct an AnyData is a piece by piece approach. The 
     BeginCreate() call begins the construction process and
     EndCreate() call finishes the construction process..
     In between these 2 calls, the individual attributes of an Object Type or
     the elements of a Collection can be set using Set*()calls.
     For piece by piece access of the attributes of Objects and elements of
     Collections, the PieceWise() call should be invoked prior to
     Get*() calls.
     Note: The AnyData has to be constructed or accessed sequentially starting
     from its first attribute(or collection element).
     The BeginCreate() call automatically begins the construction in a
     piece-wise mode. There is no need to call PieceWise() immediately
     after BeginCreate().
     EndCreate should be called to finish the construction
     process (before which no access calls can be made).
  */
  /* NAME
         BeginCreate
     DESCRIPTION
         Begins creation process on a new AnyData.
     PARAMETERS
         dtype - The Type of the AnyData. (should correspond to
                                           OCI_TYPECODE_OBJECT or
                                           a Collection typecode.)
         adata - AnyData being constructed.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           dtype is invalid (not fully constructed etc.).
     NOTE
         There is NO NEED to call PieceWise() immediately after this
     call. Automatically the construction process begins in a piece-wise
     manner.
  */
  STATIC PROCEDURE BeginCreate(dtype IN OUT NOCOPY AnyType,
                               adata OUT NOCOPY AnyData),
  /* NAME
         PieceWise.
     DESCRIPTION
         This call sets the MODE of access of the current data value to
         be an attribute at a time (if the data value is of TYPECODE_OBJECT).
         It sets the MODE of access of the data value to be a
         collection element at a time (if the data value is of
         collection TYPE). Once this call has been made, subsequent
         Set*'s and Get*'s will sequentially obtain
         individual attributes or collection elements.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
         - DBMS_TYPES.incorrect_usage
           On incorrect usage.
     NOTE
         The current data value must be of an OBJECT or COLLECTION type before
         this call can be made.
         Piece-wise construction and access of nested attributes that are of
         object or collection types is not supported. 
  */
  MEMBER PROCEDURE PieceWise(self IN OUT NOCOPY AnyData),
  /* NAME
         SetNumber, SetDate etc.
     DESCRIPTION
         Sets the current data value.
         This is a list of procedures that should be called depending on the
         type of the current data value.
         The type of the data value should be the type of the attribute at the
         current position during the piece-wise construction process.
         NOTE - When BeginCreate() is called, construction has already
                begun in a piece-wise fashion. Subsequent calls to
                Set*() will set the successive attribute values.
                If the AnyData is a standalone collection, the
                Set*() call will set the successive collection
                elements.
     PARAMETERS
         num - The Number that needs to be set. etc.
         last_elem - This parameter is relevant only if AnyData represents a
                     a collection.
                     Set to TRUE if it is the last element of the collection,
                     FALSE otherwise.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           Invalid Parameters (if it is not appropriate to add a number
                               at this point in the creation process).
         - DBMS_TYPES.incorrect_usage
           Incorrect usage
         - DBMS_TYPES.type_mismatch
           When the expected type is different from the passed in type.
     NOTE
         Sets the current data value.
  */
  MEMBER PROCEDURE SetNumber(self IN OUT NOCOPY AnyData, num IN NUMBER,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetDate(self IN OUT NOCOPY AnyData, dat IN DATE,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetChar(self IN OUT NOCOPY AnyData, c IN CHAR,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetVarchar(self IN OUT NOCOPY AnyData, c IN VARCHAR,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetVarchar2(self IN OUT NOCOPY AnyData,
                    c IN VARCHAR2, last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetRaw(self IN OUT NOCOPY AnyData, r IN RAW,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBlob(self IN OUT NOCOPY AnyData, b IN BLOB,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetClob(self IN OUT NOCOPY AnyData, c IN CLOB,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBfile(self IN OUT NOCOPY AnyData, b IN BFILE,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetObject(self IN OUT NOCOPY AnyData,
                    obj IN "<ADT_1>", last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetObject(self IN OUT NOCOPY AnyData,
                    obj IN "<OPAQUE_1>", last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetRef(self IN OUT NOCOPY AnyData,
                    rf IN REF "<ADT_1>", last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetCollection(self IN OUT NOCOPY AnyData,
                  col IN "<COLLECTION_1>", last_elem IN boolean DEFAULT FALSE),
  /*
     NAME
          EndCreate
     DESCRIPTION
          Ends Creation of a AnyData. Other creation functions cannot be
          called after this call.
  */
  MEMBER PROCEDURE EndCreate(self IN OUT NOCOPY AnyData),
  /* ----------------------------------------------------------------------- */
  /* ACCESSORS */
  /* ----------------------------------------------------------------------- */
  /* 
     NAME
          GetTypeName
     DESCRIPTION
          Get the fully qualified Type Name for the AnyData.
          If the AnyData is based on a builtin, this function will return
          NUMBER etc.
          If it is based on a user defined type, this function will return 
          <schema_name>.<type_name>. e.g. SCOTT.FOO.
          If it is based on a transient anonymous type, this function will
          return NULL.     
     RETURNS
          Type name of the AnyData.
  */
  MEMBER FUNCTION GetTypeName(self IN AnyData) return VARCHAR2 DETERMINISTIC,
  /* NAME
         GetType
     DESCRIPTION
         Gets the Type of the AnyData.
     PARAMETERS
         typ (OUT) - The AnyType corresponding to the AnyData. May be NULL
                     if it does not represent a user-defined type.
     RETURNS
         The typecode corresponding to the type of the AnyData.
     EXCEPTIONS
  */
  MEMBER FUNCTION GetType(self IN AnyData, typ OUT NOCOPY AnyType)
      return PLS_INTEGER,
  /* NAME
         Get*()
     DESCRIPTION
         Gets the current data value (which should be of appropriate type)
         The type of the current data value depends on the MODE with which
         we are accessing (Depending on whether we have invoked the
         PieceWise() call).
         If PieceWise() has NOT been called, we are accessing the
         AnyData in its entirety and the type of the data value should match
         the type of the AnyData.
         If PieceWise() has been called, we are accessing the
         AnyData piece wise. The type of the data value should match the type
         of the attribute (or collection element) at the current position.
     PARAMETERS
         num - The Number that needs to be got. etc.
     RETURNS
         DBMS_TYPES.SUCCESS or DBMS_TYPES.NO_DATA
         The return value is relevant only if PieceWise
         has been already called (for a collection). In such a case,
         DBMS_TYPES.NO_DATA signifies the end of the collection when all
         elements have been accessed.
     EXCEPTIONS
         - DBMS_TYPES.type_mismatch
           When the expected type is different from the passed in type.
         - DBMS_TYPES.invalid_parameters
           Invalid Parameters (if it is not appropriate to add a number
                               at this point in the creation process).
         - DBMS_TYPES.incorrect_usage
           Incorrect usage.
  */
  MEMBER FUNCTION GetNumber(self IN AnyData, num OUT NOCOPY NUMBER)
              return PLS_INTEGER,
  MEMBER FUNCTION GetDate(self IN AnyData, dat OUT NOCOPY DATE)
              return PLS_INTEGER,
  MEMBER FUNCTION GetChar(self IN AnyData, c OUT NOCOPY CHAR)
              return PLS_INTEGER,
  MEMBER FUNCTION GetVarchar(self IN AnyData, c OUT NOCOPY VARCHAR)
              return PLS_INTEGER,
  MEMBER FUNCTION GetVarchar2(self IN AnyData, c OUT NOCOPY VARCHAR2)
              return PLS_INTEGER,
  MEMBER FUNCTION GetRaw(self IN AnyData, r OUT NOCOPY RAW)
              return PLS_INTEGER,
  MEMBER FUNCTION GetBlob(self IN AnyData, b OUT NOCOPY BLOB)
              return PLS_INTEGER,
  MEMBER FUNCTION GetClob(self IN AnyData, c OUT NOCOPY CLOB)
              return PLS_INTEGER,
  MEMBER FUNCTION GetBfile(self IN AnyData, b OUT NOCOPY BFILE)
              return PLS_INTEGER,
  MEMBER FUNCTION GetObject(self IN AnyData, obj OUT NOCOPY "<ADT_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetObject(self IN AnyData, obj OUT NOCOPY "<OPAQUE_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetRef(self IN AnyData, rf OUT NOCOPY REF "<ADT_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetCollection(self IN AnyData,
                                col OUT NOCOPY "<COLLECTION_1>") 
                                return PLS_INTEGER,
  /***************************************************************************/
  /* NEWLY ADDED FUNCTIONS IN 9iR2 */
  /***************************************************************************/
  /* Convert calls for Datetime and Nchar types. */
  STATIC FUNCTION ConvertTimestamp(ts IN TIMESTAMP_UNCONSTRAINED) return AnyData,
  STATIC FUNCTION ConvertTimestampTZ(ts IN TIMESTAMP_TZ_UNCONSTRAINED)
        return AnyData,
  STATIC FUNCTION ConvertTimestampLTZ(ts IN TIMESTAMP_LTZ_UNCONSTRAINED)
        return AnyData,
  STATIC FUNCTION ConvertIntervalYM(inv IN YMINTERVAL_UNCONSTRAINED)
        return AnyData,
  STATIC FUNCTION ConvertIntervalDS(inv IN DSINTERVAL_UNCONSTRAINED)
        return AnyData,
  STATIC FUNCTION ConvertNchar(nc IN NCHAR) return AnyData,
  STATIC FUNCTION ConvertNVarchar2(nc IN NVARCHAR2) return AnyData,
  STATIC FUNCTION ConvertNClob(nc IN NCLOB) return AnyData,
  /* Set calls for Datetime and Nchar types. */
  MEMBER PROCEDURE SetTimestamp(self IN OUT NOCOPY AnyData, ts IN TIMESTAMP_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetTimestampTZ(self IN OUT NOCOPY AnyData, 
                    ts IN TIMESTAMP_TZ_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetTimestampLTZ(self IN OUT NOCOPY AnyData,
                    ts IN TIMESTAMP_LTZ_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetIntervalYM(self IN OUT NOCOPY AnyData,
                    inv IN YMINTERVAL_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetIntervalDS(self IN OUT NOCOPY AnyData,
                    inv IN DSINTERVAL_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetNchar(self IN OUT NOCOPY AnyData,
                    nc IN NCHAR, last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetNVarchar2(self IN OUT NOCOPY AnyData,
                    nc IN NVarchar2, last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetNClob(self IN OUT NOCOPY AnyData,
                    nc IN NClob, last_elem IN boolean DEFAULT FALSE),
  /* Get calls for Datetime and Nchar types. */
  MEMBER FUNCTION GetTimestamp(self IN AnyData, ts OUT NOCOPY TIMESTAMP_UNCONSTRAINED)
       return PLS_INTEGER,
  MEMBER FUNCTION GetTimestampTZ(self IN AnyData, 
       ts OUT NOCOPY TIMESTAMP_TZ_UNCONSTRAINED) return PLS_INTEGER,
  MEMBER FUNCTION GetTimestampLTZ(self IN AnyData,
       ts OUT NOCOPY TIMESTAMP_LTZ_UNCONSTRAINED) return PLS_INTEGER,
  MEMBER FUNCTION GetIntervalYM(self IN AnyData,
       inv IN OUT NOCOPY YMINTERVAL_UNCONSTRAINED) return PLS_INTEGER,
  MEMBER FUNCTION GetIntervalDS(self IN AnyData,
       inv IN OUT NOCOPY DSINTERVAL_UNCONSTRAINED) return PLS_INTEGER,
  MEMBER FUNCTION GetNchar(self IN AnyData, nc OUT NOCOPY NCHAR)
       return PLS_INTEGER,
  MEMBER FUNCTION GetNVarchar2(self IN AnyData, nc OUT NOCOPY NVARCHAR2)
       return PLS_INTEGER,
  MEMBER FUNCTION GetNClob(self IN AnyData, nc OUT NOCOPY NCLOB)
       return PLS_INTEGER,
  /*
     NAME
         AccessNumber, AccessDate etc.
     DESCRIPTION
         Access functions for AnyData based on Built-ins are provided for
         SQL queriability.
         These functions do not throw exceptions on type-mismatch.
         Instead, they return NULL if the type of the AnyData does not
         correspond to the type of Access so that it is SQL friendly.
         If users want only those AnyData's of the appropriate Types returned
         in a Query, they should use a WHERE clause which uses
         GetTypeName() and choose the type they are interested in
         (say "SYS.NUMBER" etc.)
  */
  MEMBER FUNCTION AccessNumber(self IN AnyData) return NUMBER DETERMINISTIC,
  MEMBER FUNCTION AccessDate(self IN AnyData) return DATE DETERMINISTIC,
  MEMBER FUNCTION AccessChar(self IN AnyData) return CHAR DETERMINISTIC,
  MEMBER FUNCTION AccessVarchar(self IN AnyData) return VARCHAR DETERMINISTIC,
  MEMBER FUNCTION AccessVarchar2(self IN AnyData) return VARCHAR2
                          DETERMINISTIC,
  MEMBER FUNCTION AccessRaw(self IN AnyData) return RAW DETERMINISTIC,
  MEMBER FUNCTION AccessBlob(self IN AnyData) return BLOB DETERMINISTIC,
  MEMBER FUNCTION AccessClob(self IN AnyData) return CLOB DETERMINISTIC,
  MEMBER FUNCTION AccessBfile(self IN AnyData) return BFILE DETERMINISTIC,
  MEMBER FUNCTION AccessTimestamp(self IN AnyData) return TIMESTAMP_UNCONSTRAINED
                           DETERMINISTIC,
  MEMBER FUNCTION AccessTimestampTZ(self IN AnyData)
         REturn TIMESTAMP_TZ_UNCONSTRAINED DETERMINISTIC,
  MEMBER FUNCTION AccessTimestampLTZ(self IN AnyData)
         return TIMESTAMP_LTZ_UNCONSTRAINED DETERMINISTIC,
  MEMBER FUNCTION AccessIntervalYM(self IN AnyData)
         return YMINTERVAL_UNCONSTRAINED DETERMINISTIC,
  MEMBER FUNCTION AccessIntervalDS(self IN AnyData)
         return DSINTERVAL_UNCONSTRAINED DETERMINISTIC,
  MEMBER FUNCTION AccessNchar(self IN AnyData) return NCHAR DETERMINISTIC,
  MEMBER FUNCTION AccessNVarchar2(self IN AnyData) return NVARCHAR2
                                  DETERMINISTIC,
  MEMBER fuNCTION AccessNClob(self IN AnyData) return NCLOB DETERMINISTIC,
  /***************************************************************************/
  /* NEWLY ADDED FUNCTIONS IN 10iR1 */
  /***************************************************************************/
  /* Convert calls for BFloat, BDouble, URowid */
  STATIC FUNCTION ConvertBFloat(fl IN BINARY_FLOAT) return AnyData,
  STATIC FUNCTION ConvertBDouble(dbl IN BINARY_DOUBLE) return AnyData,
  STATIC FUNCTION ConvertURowid(rid IN UROWID) return AnyData,
  /* Set calls for Float, Double */
  MEMBER PROCEDURE SetBFloat(self IN OUT NOCOPY AnyData, fl IN BINARY_FLOAT,
                            last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBDouble(self IN OUT NOCOPY AnyData, dbl IN BINARY_DOUBLE,
                             last_elem IN boolean DEFAULT FALSE),
  /* Get calls for Float, Double */
  MEMBER FUNCTION GetBFloat(self IN AnyData, fl OUT NOCOPY BINARY_FLOAT)
      return PLS_INTEGER,
  MEMBER FUNCTION GetBDouble(self IN AnyData, dbl OUT NOCOPY BINARY_DOUBLE)
      return PLS_INTEGER,
  /* Access calls for Float, Double, Rowid */
  MEMBER FUNCTION AccessBFloat(self IN AnyData) return BINARY_FLOAT
          DETERMINISTIC,
  MEMBER FUNCTION AccessBDouble(self IN AnyData) return BINARY_DOUBLE
          DETERMINISTIC,
  MEMBER FUNCTION AccessURowid(self IN AnyData) return UROWID DETERMINISTIC
);
show errors

Rem ********************** END OF AnyData ADDITIONS **************************

GRANT EXECUTE ON AnyData TO public WITH GRANT OPTION
/

CREATE OR REPLACE PUBLIC SYNONYM AnyData for SYS.AnyData
/

Rem ************************* AnyDataSet Definition *************************
Rem ** IMPORTANT: The create or replace AnyDataSet is FROZEN as of 9.0.1.1.0.
Rem ** All new additions to AnyDataSet must be placed in the ALTER TYPE REPLACE
Rem ** following the create or replace type.
Rem *************************************************************************

-- Type SYS.AnyDataSet - SQL Type corresponding to OCIAnyDataSet
CREATE OR REPLACE TYPE AnyDataSet OID '00000000000000000000000000020012'
as OPAQUE VARYING (*)
USING library DBMS_ANYDATASET_LIB
(
/* CONSTRUCTION */

  /* NOTE - The AnyDataSet needs to be contructed value by value sequentially. 
            For each data instance (of the type of the AnyDataSet),
            the AddInstance() function need to be invoked.
            This adds a new data instance to the AnyDataSet.
            Subsequently, Set*() can be called to set each value
            in its entirety.

            The MODE of construction/access can be changed to attribute/
            collection element wise by making calls to PieceWise()
             - If the type of the AnyDataSet is TYPECODE_OBJECT,
               individual attributes will be set with subsequent
               Set*() calls. Likewise on access.
             - If the type of the current data value is a collection type
               individual collection elements will be set with subsequent
               Set*() calls. Likewise on access.
            This call is very similar to AnyData.PieceWise() call defined for
            the type SYS.AnyData.
            NOTE - There is no support for piecewise construction and access
                   of nested (not top level) attributes that are of object
                   types or collection types.

            EndCreate should be called to finish the construction
            process (before which no access calls can be made).
  */

  /* NAME
         BeginCreate
     DESCRIPTION
         Creates a new AnyDataSet which can be used to create a Set of data
         values of the given ANYTYPE.
     PARAMETERS
         typecode - the typecode for the type of the AnyDataSet
         dtype - The Type of the data values. This parameter is a must for
                 user-defined types like TYPECODE_OBJECT, Collection typecodes
                 etc.
         aset - The AnyDataSet being constructed.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           dtype is invalid (not fully constructed etc.).
  */
  STATIC PROCEDURE BeginCreate(typecode IN PLS_INTEGER,
           rtype IN OUT NOCOPY AnyType, aset OUT NOCOPY AnyDataSet),

  /* NAME
         AddInstance.
     DESCRIPTION
         Add a new data instance to a AnyDataSet.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
         - DBMS_TYPES.incorrect_usage
           On incorrect usage.
     NOTE
         The data instances have to be added sequentially. The previous data
         instance must be fully constructed (or set to null) before a new one
         can be added.
         This call DOES NOT automatically set the mode of construction to be
         piece-wise. The user has to explicitly call PieceWise() if a
         piece-wise construction of the instance is intended.
  */
  MEMBER PROCEDURE AddInstance(self IN OUT NOCOPY AnyDataSet),

  /* NAME
         PieceWise.
     DESCRIPTION
         This call sets the MODE of construction, access of the data value to
         be an attribute at a time (if the data value is of TYPECODE_OBJECT).
         It sets the MODE of construction, access of the data value to be a
         collection element at a time (if the data value is of
         collection TYPE). Once this call has been made, subsequent
         Set*'s and Get* will sequentially obtain
         individual attributes or collection elements.
    EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
         - DBMS_TYPES.incorrect_usage
           On incorrect usage.
    NOTE
         The current data value must be of an OBJECT or COLLECTION type before
         this call can be made. There is no support for piece-wise
         construction or access of embedded object type attributes (or nested
         collections).
  */
  MEMBER PROCEDURE PieceWise(self IN OUT NOCOPY AnyDataSet),

  /* NAME
         Set*.
     DESCRIPTION
         Sets the current data value.
         The type of the current data value depends on the MODE with which
         we are constructing (Depending on how we have invoked the
         PieceWise() call).
         The type of the current data should be the type of the
         AnyDataSet if PieceWise() has NOT been called. The type
         should be the type of the attribute at the current position if
         PieceWise() has been called.
     PARAMETERS
         num - The Number that needs to be set. etc.

         last_elem - This parameter is relevant only if PieceWise()
                     has been already called (for a collection).
                     Set to TRUE if it is the last element of the collection,
                     FALSE otherwise.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           Invalid Parameters (if it is not appropriate to add a number
                               at this point in the creation process).
         - DBMS_TYPES.incorrect_usage
           Incorrect usage.
         - DBMS_TYPES.type_mismatch
           When the expected type is different from the passed in type.
     NOTE
         Sets the current data value.
  */
  MEMBER PROCEDURE SetNumber(self IN OUT NOCOPY AnyDataSet,
             num IN NUMBER, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetDate(self IN OUT NOCOPY AnyDataSet,
             dat IN DATE, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetChar(self IN OUT NOCOPY AnyDataSet, c IN CHAR,
             last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetVarchar(self IN OUT NOCOPY AnyDataSet,
             c IN VARCHAR, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetVarchar2(self IN OUT NOCOPY AnyDataSet,
             c IN VARCHAR2, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetRaw(self IN OUT NOCOPY AnyDataSet, r IN RAW,
             last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBlob(self IN OUT NOCOPY AnyDataSet, b IN BLOB,
             last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetClob(self IN OUT NOCOPY AnyDataSet, c IN CLOB,
             last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBfile(self IN OUT NOCOPY AnyDataSet,
             b IN BFILE, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetObject(self IN OUT NOCOPY AnyDataSet,
             obj IN "<ADT_1>", last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetObject(self IN OUT NOCOPY AnyDataSet,
             obj IN "<OPAQUE_1>", last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetRef(self IN OUT NOCOPY AnyDataSet,
             rf IN REF "<ADT_1>", last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetCollection(self IN OUT NOCOPY AnyDataSet,
             col IN "<COLLECTION_1>", last_elem boolean DEFAULT FALSE),

  /*
     NAME
          EndCreate
     DESCRIPTION
          Ends Creation of a AnyDataSet. Other creation functions cannot be
          called after this call.
  */
  MEMBER PROCEDURE EndCreate(self IN OUT NOCOPY AnyDataSet),

  /* ----------------------------------------------------------------------- */
  /* ACCESSORS */
  /* ----------------------------------------------------------------------- */

  /* 
     NAME
          GetTypeName
     DESCRIPTION
          Get the fully qualified Type Name for the AnyDataSet.
          If the AnyDataSet is based on a builtin, this function will return
          NUMBER etc.
          If it is based on a user defined type, this function will return 
          <schema_name>.<type_name>. e.g. SCOTT.FOO.
          If it is based on a transient anonymous type, this function will
          return NULL.
     RETURNS
          Type name of the AnyDataSet.
  */
  MEMBER FUNCTION GetTypeName(self IN AnyDataSet) return VARCHAR2,
  /* NAME
         GetType
     DESCRIPTION
         Gets the AnyType describing the type of the data instances in an
         AnyDataSet.
     PARAMETER
         typ (OUT) - The AnyType corresponding to the AnyData. May be NULL
                     if it does not represent a user-defined type.
     RETURNS
         The typecode corresponding to the type of the AnyData. 
     EXCEPTIONS
  */
  MEMBER FUNCTION GetType(self IN AnyDataSet, typ OUT NOCOPY AnyType)
           return PLS_INTEGER,

  /* NAME
         GetInstance
     DESCRIPTION
         Get's the next instance in an AnyDataSet. Only sequential access to
         the instances in an AnyDataSet is allowed. After this function has
         been called, the Get*() functions can be invoked on the
         AnyDataSet to access the current instance. If PieceWise() is called
         before doing the Get*() calls, the individual attributes
         (or collection elements) can be accessed. It is an error to invoke
          this function before the AnyDataSet is fully created.
     PARAMETERS
         self (IN OUT )   - The AnyDataSet being accessed.
         return          - DBMS_TYPES.SUCCESS or DBMS_TYPES.NO_DATA. 
                           DBMS_TYPES.NO_DATA signifies the end of the
                           AnyDataSet when all instances have been accessed.
     NOTE
         This function should be called even before accessing the 1st
         instance.
  */
  MEMBER FUNCTION GetInstance(self IN OUT NOCOPY AnyDataSet)
            return PLS_INTEGER,

  /* NAME
         Get*.
     DESCRIPTION
         Gets the current data value (which should be of appropriate type)
         The type of the current data value depends on the MODE with which
         we are accessing (Depending on how we have invoked the
         PieceWise() call).
         If PieceWise() has NOT been called, we are accessing the
         instance in its entirety and the type of the data value should match
         the type of the AnyDataSet.
         If PieceWise() has been called, we are accessing the
         instance piece wise. The type of the data value should match the type
         of the attribute (or collection element) at the current position.

     PARAMETERS
         num - The Number that needs to be got. etc.
     RETURNS
         DBMS_TYPES.SUCCESS or DBMS_TYPES.NO_DATA
         The return value is relevant only if PieceWise
         has been already called (for a collection). In such a case,
         DBMS_TYPES.NO_DATA signifies the end of the collection when all
         elements have been accessed.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           Invalid Parameters (if it is not appropriate to add a number
                               at this point in the creation process).
         - DBMS_TYPES.incorrect_usage
           Incorrect usage.
         - DBMS_TYPES.type_mismatch
           When the expected type is different from the passed in type.
  */
  MEMBER FUNCTION GetNumber(self IN AnyDataSet, num OUT NOCOPY NUMBER)
              return PLS_INTEGER,
  MEMBER FUNCTION GetDate(self IN AnyDataSet, dat OUT NOCOPY DATE)
              return PLS_INTEGER,
  MEMBER FUNCTION GetChar(self IN AnyDataSet, c OUT NOCOPY CHAR)
              return PLS_INTEGER,
  MEMBER FUNCTION GetVarchar(self IN AnyDataSet, c OUT NOCOPY VARCHAR)
              return PLS_INTEGER,
  MEMBER FUNCTION GetVarchar2(self IN AnyDataSet, c OUT NOCOPY VARCHAR2)
              return PLS_INTEGER,
  MEMBER FUNCTION GetRaw(self IN AnyDataSet, r OUT NOCOPY RAW)
              return PLS_INTEGER,
  MEMBER FUNCTION GetBlob(self IN AnyDataSet, b OUT NOCOPY BLOB)
              return PLS_INTEGER,
  MEMBER FUNCTION GetClob(self IN AnyDataSet, c OUT NOCOPY CLOB)
              return PLS_INTEGER,
  MEMBER FUNCTION GetBfile(self IN AnyDataSet, b OUT NOCOPY BFILE)
              return PLS_INTEGER,
  MEMBER FUNCTION GetObject(self IN AnyDataSet, obj OUT NOCOPY "<ADT_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetObject(self IN AnyDataSet, obj OUT NOCOPY "<OPAQUE_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetRef(self IN AnyDataSet, rf OUT NOCOPY REF "<ADT_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetCollection(self IN AnyDataSet,
              col OUT NOCOPY "<COLLECTION_1>") return PLS_INTEGER,

  /* NAME
         GetCount
     DESCRIPTION
         Gets the number of data instances in a AnyDataSet.
     PARAMETERS
     EXCEPTIONS
         None.
  */
  MEMBER FUNCTION GetCount(self IN AnyDataSet) return PLS_INTEGER
);
/
show errors

Rem ********************* ADDITIONS TO ANYDATASET ***************************
Rem ** All additions to ANYDATASET must be put here.
Rem *************************************************************************

ALTER TYPE SYS.AnyDataSet REPLACE
as OPAQUE VARYING (*)
USING library DBMS_ANYDATASET_LIB
(
/* CONSTRUCTION */
  /* NOTE - The AnyDataSet needs to be contructed value by value sequentially. 
            For each data instance (of the type of the AnyDataSet),
            the AddInstance() function need to be invoked.
            This adds a new data instance to the AnyDataSet.
            Subsequently, Set*() can be called to set each value
            in its entirety.
            The MODE of construction/access can be changed to attribute/
            collection element wise by making calls to PieceWise()
             - If the type of the AnyDataSet is TYPECODE_OBJECT,
               individual attributes will be set with subsequent
               Set*() calls. Likewise on access.
             - If the type of the current data value is a collection type
               individual collection elements will be set with subsequent
               Set*() calls. Likewise on access.
            This call is very similar to AnyData.PieceWise() call defined for
            the type SYS.AnyData.
            NOTE - There is no support for piecewise construction and access
                   of nested (not top level) attributes that are of object
                   types or collection types.
            EndCreate should be called to finish the construction
            process (before which no access calls can be made).
  */
  /* NAME
         BeginCreate
     DESCRIPTION
         Creates a new AnyDataSet which can be used to create a Set of data
         values of the given ANYTYPE.
     PARAMETERS
         typecode - the typecode for the type of the AnyDataSet
         dtype - The Type of the data values. This parameter is a must for
                 user-defined types like TYPECODE_OBJECT, Collection typecodes
                 etc.
         aset - The AnyDataSet being constructed.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           dtype is invalid (not fully constructed etc.).
  */
  STATIC PROCEDURE BeginCreate(typecode IN PLS_INTEGER,
           rtype IN OUT NOCOPY AnyType, aset OUT NOCOPY AnyDataSet),
  /* NAME
         AddInstance.
     DESCRIPTION
         Add a new data instance to a AnyDataSet.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
         - DBMS_TYPES.incorrect_usage
           On incorrect usage.
     NOTE
         The data instances have to be added sequentially. The previous data
         instance must be fully constructed (or set to null) before a new one
         can be added.
         This call DOES NOT automatically set the mode of construction to be
         piece-wise. The user has to explicitly call PieceWise() if a
         piece-wise construction of the instance is intended.
  */
  MEMBER PROCEDURE AddInstance(self IN OUT NOCOPY AnyDataSet),
  /* NAME
         PieceWise.
     DESCRIPTION
         This call sets the MODE of construction, access of the data value to
         be an attribute at a time (if the data value is of TYPECODE_OBJECT).
         It sets the MODE of construction, access of the data value to be a
         collection element at a time (if the data value is of
         collection TYPE). Once this call has been made, subsequent
         Set*'s and Get* will sequentially obtain
         individual attributes or collection elements.
    EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
         - DBMS_TYPES.incorrect_usage
           On incorrect usage.
    NOTE
         The current data value must be of an OBJECT or COLLECTION type before
         this call can be made. There is no support for piece-wise
         construction or access of embedded object type attributes (or nested
         collections).
  */
  MEMBER PROCEDURE PieceWise(self IN OUT NOCOPY AnyDataSet),
  /* NAME
         Set*.
     DESCRIPTION
         Sets the current data value.
         The type of the current data value depends on the MODE with which
         we are constructing (Depending on how we have invoked the
         PieceWise() call).
         The type of the current data should be the type of the
         AnyDataSet if PieceWise() has NOT been called. The type
         should be the type of the attribute at the current position if
         PieceWise() has been called.
     PARAMETERS
         num - The Number that needs to be set. etc.
         last_elem - This parameter is relevant only if PieceWise()
                     has been already called (for a collection).
                     Set to TRUE if it is the last element of the collection,
                     FALSE otherwise.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           Invalid Parameters (if it is not appropriate to add a number
                               at this point in the creation process).
         - DBMS_TYPES.incorrect_usage
           Incorrect usage.
         - DBMS_TYPES.type_mismatch
           When the expected type is different from the passed in type.
     NOTE
         Sets the current data value.
  */
  MEMBER PROCEDURE SetNumber(self IN OUT NOCOPY AnyDataSet,
             num IN NUMBER, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetDate(self IN OUT NOCOPY AnyDataSet,
             dat IN DATE, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetChar(self IN OUT NOCOPY AnyDataSet, c IN CHAR,
             last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetVarchar(self IN OUT NOCOPY AnyDataSet,
             c IN VARCHAR, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetVarchar2(self IN OUT NOCOPY AnyDataSet,
             c IN VARCHAR2, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetRaw(self IN OUT NOCOPY AnyDataSet, r IN RAW,
             last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBlob(self IN OUT NOCOPY AnyDataSet, b IN BLOB,
             last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetClob(self IN OUT NOCOPY AnyDataSet, c IN CLOB,
             last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBfile(self IN OUT NOCOPY AnyDataSet,
             b IN BFILE, last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetObject(self IN OUT NOCOPY AnyDataSet,
             obj IN "<ADT_1>", last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetObject(self IN OUT NOCOPY AnyDataSet,
             obj IN "<OPAQUE_1>", last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetRef(self IN OUT NOCOPY AnyDataSet,
             rf IN REF "<ADT_1>", last_elem boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetCollection(self IN OUT NOCOPY AnyDataSet,
             col IN "<COLLECTION_1>", last_elem boolean DEFAULT FALSE),
  /*
     NAME
          EndCreate
     DESCRIPTION
          Ends Creation of a AnyDataSet. Other creation functions cannot be
          called after this call.
  */
  MEMBER PROCEDURE EndCreate(self IN OUT NOCOPY AnyDataSet),
  /* ----------------------------------------------------------------------- */
  /* ACCESSORS */
  /* ----------------------------------------------------------------------- */
  /* 
     NAME
          GetTypeName
     DESCRIPTION
          Get the fully qualified Type Name for the AnyDataSet.
          If the AnyDataSet is based on a builtin, this function will return
          NUMBER etc.
          If it is based on a user defined type, this function will return 
          <schema_name>.<type_name>. e.g. SCOTT.FOO.
          If it is based on a transient anonymous type, this function will
          return NULL.
     RETURNS
          Type name of the AnyDataSet.
  */
  MEMBER FUNCTION GetTypeName(self IN AnyDataSet) return VARCHAR2
                       DETERMINISTIC,
  /* NAME
         GetType
     DESCRIPTION
         Gets the AnyType describing the type of the data instances in an
         AnyDataSet.
     PARAMETER
         typ (OUT) - The AnyType corresponding to the AnyData. May be NULL
                     if it does not represent a user-defined type.
     RETURNS
         The typecode corresponding to the type of the AnyData. 
     EXCEPTIONS
  */
  MEMBER FUNCTION GetType(self IN AnyDataSet, typ OUT NOCOPY AnyType)
           return PLS_INTEGER,
  /* NAME
         GetInstance
     DESCRIPTION
         Get's the next instance in an AnyDataSet. Only sequential access to
         the instances in an AnyDataSet is allowed. After this function has
         been called, the Get*() functions can be invoked on the
         AnyDataSet to access the current instance. If PieceWise() is called
         before doing the Get*() calls, the individual attributes
         (or collection elements) can be accessed. It is an error to invoke
          this function before the AnyDataSet is fully created.
     PARAMETERS
         self (IN OUT )   - The AnyDataSet being accessed.
         return          - DBMS_TYPES.SUCCESS or DBMS_TYPES.NO_DATA. 
                           DBMS_TYPES.NO_DATA signifies the end of the
                           AnyDataSet when all instances have been accessed.
     NOTE
         This function should be called even before accessing the 1st
         instance.
  */
  MEMBER FUNCTION GetInstance(self IN OUT NOCOPY AnyDataSet)
            return PLS_INTEGER,
  /* NAME
         Get*.
     DESCRIPTION
         Gets the current data value (which should be of appropriate type)
         The type of the current data value depends on the MODE with which
         we are accessing (Depending on how we have invoked the
         PieceWise() call).
         If PieceWise() has NOT been called, we are accessing the
         instance in its entirety and the type of the data value should match
         the type of the AnyDataSet.
         If PieceWise() has been called, we are accessing the
         instance piece wise. The type of the data value should match the type
         of the attribute (or collection element) at the current position.
     PARAMETERS
         num - The Number that needs to be got. etc.
     RETURNS
         DBMS_TYPES.SUCCESS or DBMS_TYPES.NO_DATA
         The return value is relevant only if PieceWise
         has been already called (for a collection). In such a case,
         DBMS_TYPES.NO_DATA signifies the end of the collection when all
         elements have been accessed.
     EXCEPTIONS
         - DBMS_TYPES.invalid_parameters
           Invalid Parameters (if it is not appropriate to add a number
                               at this point in the creation process).
         - DBMS_TYPES.incorrect_usage
           Incorrect usage.
         - DBMS_TYPES.type_mismatch
           When the expected type is different from the passed in type.
  */
  MEMBER FUNCTION GetNumber(self IN AnyDataSet, num OUT NOCOPY NUMBER)
              return PLS_INTEGER,
  MEMBER FUNCTION GetDate(self IN AnyDataSet, dat OUT NOCOPY DATE)
              return PLS_INTEGER,
  MEMBER FUNCTION GetChar(self IN AnyDataSet, c OUT NOCOPY CHAR)
              return PLS_INTEGER,
  MEMBER FUNCTION GetVarchar(self IN AnyDataSet, c OUT NOCOPY VARCHAR)
              return PLS_INTEGER,
  MEMBER FUNCTION GetVarchar2(self IN AnyDataSet, c OUT NOCOPY VARCHAR2)
              return PLS_INTEGER,
  MEMBER FUNCTION GetRaw(self IN AnyDataSet, r OUT NOCOPY RAW)
              return PLS_INTEGER,
  MEMBER FUNCTION GetBlob(self IN AnyDataSet, b OUT NOCOPY BLOB)
              return PLS_INTEGER,
  MEMBER FUNCTION GetClob(self IN AnyDataSet, c OUT NOCOPY CLOB)
              return PLS_INTEGER,
  MEMBER FUNCTION GetBfile(self IN AnyDataSet, b OUT NOCOPY BFILE)
              return PLS_INTEGER,
  MEMBER FUNCTION GetObject(self IN AnyDataSet, obj OUT NOCOPY "<ADT_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetObject(self IN AnyDataSet, obj OUT NOCOPY "<OPAQUE_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetRef(self IN AnyDataSet, rf OUT NOCOPY REF "<ADT_1>")
              return PLS_INTEGER,
  MEMBER FUNCTION GetCollection(self IN AnyDataSet,
              col OUT NOCOPY "<COLLECTION_1>") return PLS_INTEGER,
  /* NAME
         GetCount
     DESCRIPTION
         Gets the number of data instances in a AnyDataSet.
     PARAMETERS
     EXCEPTIONS
         None.
  */
  MEMBER FUNCTION GetCount(self IN AnyDataSet) return PLS_INTEGER,
  /***************************************************************************/
  /* NEWLY ADDED FUNCTIONS IN 9iR2 */
  /***************************************************************************/
  /* Set Functions for Datetime and NCHAR types. */
  MEMBER PROCEDURE SetTimestamp(self IN OUT NOCOPY AnyDataSet, ts IN TIMESTAMP_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetTimestampTZ(self IN OUT NOCOPY AnyDataSet, 
                    ts IN TIMESTAMP_TZ_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetTimestampLTZ(self IN OUT NOCOPY AnyDataSet,
                    ts IN TIMESTAMP_LTZ_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetIntervalYM(self IN OUT NOCOPY AnyDataSet,
                    inv IN YMINTERVAL_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetIntervalDS(self IN OUT NOCOPY AnyDataSet,
                    inv IN DSINTERVAL_UNCONSTRAINED,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetNchar(self IN OUT NOCOPY AnyDataSet,
                    nc IN NCHAR, last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetNVarchar2(self IN OUT NOCOPY AnyDataSet,
                    nc IN NVarchar2, last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetNClob(self IN OUT NOCOPY AnyDataSet,
                    nc IN NClob, last_elem IN boolean DEFAULT FALSE),
  /* Get Functions for Datetime and NCHAR types. */
  MEMBER FUNCTION GetTimestamp(self IN AnyDataSet, ts OUT NOCOPY TIMESTAMP_UNCONSTRAINED)
       return PLS_INTEGER,
  MEMBER FUNCTION GetTimestampTZ(self IN AnyDataSet, 
       ts OUT NOCOPY TIMESTAMP_TZ_UNCONSTRAINED) return PLS_INTEGER,
  MEMBER FUNCTION GetTimestampLTZ(self IN AnyDataSet,
       ts OUT NOCOPY TIMESTAMP_LTZ_UNCONSTRAINED) return PLS_INTEGER,
  MEMBER FUNCTION GetIntervalYM(self IN AnyDataSet,
       inv IN OUT NOCOPY YMINTERVAL_UNCONSTRAINED) return PLS_INTEGER,
  MEMBER FUNCTION GetIntervalDS(self IN AnyDataSet,
       inv IN OUT NOCOPY DSINTERVAL_UNCONSTRAINED) return PLS_INTEGER,
  MEMBER FUNCTION GetNchar(self IN AnyDataSet, nc OUT NOCOPY NCHAR)
       return PLS_INTEGER,
  MEMBER FUNCTION GetNVarchar2(self IN AnyDataSet, nc OUT NOCOPY NVARCHAR2)
       return PLS_INTEGER,
  MEMBER FUNCTION GetNClob(self IN AnyDataSet, nc OUT NOCOPY NCLOB)
       return PLS_INTEGER,
  /***************************************************************************/
  /* NEWLY ADDED FUNCTIONS IN 10iR1 */
  /***************************************************************************/
  /* Set functions for BFloat, BDouble and UROWID. */
  MEMBER PROCEDURE SetBFloat(self IN OUT NOCOPY AnyDataSet, fl IN BINARY_FLOAT,
                    last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetBDouble(self IN OUT NOCOPY AnyDataSet,
                    dbl IN BINARY_DOUBLE, last_elem IN boolean DEFAULT FALSE),
  MEMBER PROCEDURE SetURowid(self IN OUT NOCOPY AnyDataSet, rid IN UROWID,
                    last_elem IN boolean DEFAULT FALSE),
  /* Get functions for Float, Double and UROWID. */
  MEMBER FUNCTION GetBFloat(self IN AnyDataSet, fl OUT NOCOPY BINARY_FLOAT)
       return PLS_INTEGER,
  MEMBER FUNCTION GetBDouble(self IN AnyDataSet, dbl OUT NOCOPY BINARY_DOUBLE)
       return PLS_INTEGER,
  MEMBER FUNCTION GetURowid(self IN AnyDataSet, rid OUT NOCOPY UROWID)
       return PLS_INTEGER
);
show errors

GRANT EXECUTE ON AnyDataSet TO public WITH GRANT OPTION
/

CREATE OR REPLACE PUBLIC SYNONYM AnyDataSet for SYS.AnyDataSet
/

CREATE OR REPLACE Function GetTvoid(type_oid IN RAW, vsn IN PLS_INTEGER) return
                    RAW AS
 tv_oid RAW(16);
begin
 select tvoid into tv_oid from type$ where toid = type_oid and
   version# = vsn;
 return (tv_oid);
end;
/

GRANT EXECUTE ON GetTvoid TO public
/
