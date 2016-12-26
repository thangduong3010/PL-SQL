Rem
Rem $Header: dbmsindx.sql 24-may-2001.15:07:46 gviswana Exp $
Rem
Rem dbmsindx.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmsindx.sql - DBMS extensible INDeXing packages and types.
Rem
Rem    DESCRIPTION
Rem      Contains specs. for packages and types used in DBMS extensibility
Rem      infrastructure (Indexing, optimizer etc.).
Rem
Rem    NOTES
Rem      None.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    rshaikh     03/08/99 - change for sqlplus
Rem    rxgovind    12/02/98 - use NOCOPY param passing
Rem    rdbmsint    08/06/98 - rm rowset for now; rvasired
Rem    nmantrav    05/11/98 - add RT_GetCount etc.
Rem    rxgovind    04/09/98 - packages and types for extensible indexing
Rem    rxgovind    04/09/98 - Created
Rem
REM  ***************************************
REM  THIS PACKAGE MUST BE CREATED UNDER SYS
REM  ***************************************

-- Create the trusted PL/SQL callout library.
CREATE OR REPLACE LIBRARY DBMS_INDEX_LIB TRUSTED AS STATIC;
/

-- Package defining constants, exceptions used by SYS.RowType and SYS.RowSet
CREATE OR REPLACE PACKAGE dbms_indexing AS

  TYPECODE_DATE        BINARY_INTEGER :=  12;
  TYPECODE_NUMBER      BINARY_INTEGER :=   2;
  TYPECODE_RAW         BINARY_INTEGER :=  95;
  TYPECODE_CHAR        BINARY_INTEGER :=  96;
  TYPECODE_VARCHAR2    BINARY_INTEGER :=   9;
  TYPECODE_VARCHAR     BINARY_INTEGER :=   1;
  TYPECODE_MLSLABEL    BINARY_INTEGER := 105;
  TYPECODE_BLOB        BINARY_INTEGER := 113;
  TYPECODE_BFILE       BINARY_INTEGER := 114;
  TYPECODE_CLOB        BINARY_INTEGER := 112;
  TYPECODE_CFILE       BINARY_INTEGER := 115;

  /* These typecodes are passed while calling RowType.RT_AddUserType() */
  TYPECODE_REF         BINARY_INTEGER := 110;
  TYPECODE_OBJECT      BINARY_INTEGER := 108;
  TYPECODE_VARRAY      BINARY_INTEGER := 247;
  TYPECODE_TABLE       BINARY_INTEGER := 248;

  /* Exceptions */
  invalid_parameters EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_parameters, -22369);

  incorrect_usage EXCEPTION;
  PRAGMA EXCEPTION_INIT(incorrect_usage, -22370);
       
END dbms_indexing;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_indexing FOR sys.dbms_indexing
/
GRANT EXECUTE ON dbms_indexing TO public
/
-- Type sys.RowType models the column types of a Row of data.
CREATE OR REPLACE TYPE RowType AS OPAQUE VARYING (*)
USING library DBMS_INDEX_LIB
(

  /* NAME
         RT_BeginCreation()
     DESCRIPTION
         Returns a new instance of RowType which can be used to Create the
         Row Description.
     EXCEPTIONS
         None.
  */
  STATIC FUNCTION RT_BeginCreation return RowType,

  /*
     NAME
         RT_AddBuiltinType
     DESCRIPTION
          This procedure Adds a Built-in Type's information to a RowType.
     PARAMETERS
          typecode - A Built-in Type Code from DBMS_INDEXING.
          prec, scale (OPTIONAL) - REQUIRED IF TYPECODE REPRESENTS A NUMBER.
                                   Give precision and scale. ignored otherwise.
          len (OPTIONAL) - REQUIRED IF TYPECODE REPRESENTS A RAW, CHAR,
                           VARCHAR, VARCHAR2 types. Gives length.
          csid, csfrm (OPTIONAL) -  REQUIRED IF TYPECODE REPRESENTS Types
                                    requiring character info. For eg: CHAR,
                                    VARCHAR, VARCHAR2, CFILE.
     EXCEPTIONS
          - DBMS_INDEXING.invalid_parameters
            Invalid Parameters (typecode, typeinfo)
          - DBMS_INDEXING.incorrect_usage
            incorrect usage (cannot call after calling RT_EndCreation() etc.)
  */
  MEMBER PROCEDURE RT_AddBuiltinType(self IN OUT NOCOPY RowType,
           typecode IN BINARY_INTEGER,
           prec IN BINARY_INTEGER, scale IN BINARY_INTEGER,
           len IN BINARY_INTEGER,
           csid IN BINARY_INTEGER, csfrm IN BINARY_INTEGER),
  
  /* 
     NAME
          RT_AddUserType
     DESCRIPTION
          This procedure Adds a User defined Type's info. to a RowType.
     PARAMETERS
          typecode - A User defined Type's Typecode.
                     Could be REF or an ObjectType or a VARRAY or a
                     Nested Table in 8.1.
          schema_name - Schema name of the type.
          type_name - Type name.
          version - Type version.
     EXCEPTIONS
          - DBMS_INDEXING.invalid_parameters
            Invalid Parameters (typecode, typeinfo)
          - DBMS_INDEXING.incorrect_usage
            incorrect usage (cannot call after calling RT_EndCreation() etc.)
  */
  MEMBER PROCEDURE RT_AddUserType(self IN OUT NOCOPY RowType,
                      typecode IN BINARY_INTEGER,
                      schema_name IN VARCHAR2,
                      type_name IN VARCHAR2, version IN varchar2),
                                  

  /*
     NAME
          RT_EndCreation
     DESCRIPTION
          Ends Creation of a RowType. Other creation functions cannot be
          called after this call.
  */
  MEMBER PROCEDURE RT_EndCreation(self IN OUT NOCOPY RowType),

/* RowType Accessor functions */

  /* 
     NAME
          RT_GetTypeCode
     DESCRIPTION
          Get the TypeCode of the column type at a given position
     PARAMETERS
          position - The column position (starting at 1).
     EXCEPTIONS
          - DBMS_INDEXING.invalid_parameters
            Invalid Parameters (position is beyond bounds or
                                the RowType is not properly Constructed).)
  */
  MEMBER FUNCTION RT_GetTypeCode (self IN RowType,
      position IN BINARY_INTEGER) return BINARY_INTEGER,

  /* 
     NAME
          RT_GetCount
     DESCRIPTION
          Get the total number of columns in the RowType.
     EXCEPTIONS
          - DBMS_INDEXING.incorrect_usage
            Incorrect Usage - called before Ending of construction.
  */
  MEMBER FUNCTION RT_GetCount(self IN RowType)
      return BINARY_INTEGER,

  /* 
     NAME
          RT_GetBuiltin
     DESCRIPTION
          Get Information on a builtin type at a given position
     PARAMETERS
          position - The column position (starting at 1).
          typeinfo - Will have builtin type information at the end of the
                     call. 
     EXCEPTIONS
          - DBMS_INDEXING.invalid_parameters
            Invalid Parameters (position is beyond bounds or
                                the RowType is not properly Constructed).
  */
  MEMBER PROCEDURE RT_GetBuiltin(self IN RowType,
          position IN BINARY_INTEGER,
          prec OUT BINARY_INTEGER, scale OUT BINARY_INTEGER,
          len OUT BINARY_INTEGER, csid OUT BINARY_INTEGER,
          csfrm OUT BINARY_INTEGER),

  /* 
     NAME
          RT_GetUserType
     DESCRIPTION
          Get Information on a User defined type at a given position
     PARAMETERS
          position - The column position (starting at 1).
          typeinfo - Will have user type information at the end of the
                     call. 
     EXCEPTIONS
          - DBMS_INDEXING.invalid_parameters
            Invalid Parameters (position is incorrect for a user type or
                                the RowType is not properly Constructed).)
  */
  MEMBER PROCEDURE RT_GetUserType(self IN RowType,
            position IN BINARY_INTEGER,
            schema_name OUT VARCHAR2, type_name OUT VARCHAR2,
            version OUT varchar2)

);
/
CREATE OR REPLACE PUBLIC SYNONYM RowType FOR sys.RowType
/
GRANT EXECUTE ON RowType TO public
/
