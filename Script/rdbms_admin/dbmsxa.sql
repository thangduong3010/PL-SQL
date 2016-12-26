Rem
Rem $Header: dbmsxa.sql 30-mar-2007.21:24:30 jarnett Exp $
Rem
Rem dbmsxa.sql
Rem
Rem Copyright (c) 2005, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxa.sql - RDBMS XA Interface in PL/SQL 
Rem
Rem    DESCRIPTION
Rem      Package for XA Interface in PL/SQL 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jarnett     03/30/07 - 5945463 - put dist_txn_sync in dbms_xa
Rem    yohu        11/16/05 - yohu_xa_plsql
Rem    yohu        10/05/05 - Created
Rem

CREATE or REPLACE TYPE DBMS_XA_XID as OBJECT (
  FORMATID NUMBER,
  GTRID RAW(64),  
  BQUAL RAW(64),
  constructor function DBMS_XA_XID(GTRID in NUMBER)
    return self as result,
  constructor function DBMS_XA_XID(GTRID in RAW, BQUAL in RAW)
    return self as result,
  constructor function DBMS_XA_XID(
      FORMATID in NUMBER, 
      GTRID in RAW, 
      BQUAL in RAW default HEXTORAW('00000000000000000000000000000001'))
    return self as result
)
/

CREATE or REPLACE TYPE DBMS_XA_XID_ARRAY as TABLE of DBMS_XA_XID
/

CREATE or REPLACE PACKAGE dbms_xa AUTHID CURRENT_USER as


/*
********************************************************************************
*   The following defines the XA APIs (see X/Open CAE Standard) in PL/SQL      *
********************************************************************************
*/
FUNCTION XA_START(xid IN DBMS_XA_XID, flag IN PLS_INTEGER)  RETURN PLS_INTEGER;
FUNCTION XA_END(xid IN DBMS_XA_XID, flag IN PLS_INTEGER)  RETURN PLS_INTEGER;
FUNCTION XA_PREPARE(xid IN DBMS_XA_XID)  RETURN PLS_INTEGER;
FUNCTION XA_COMMIT(xid IN DBMS_XA_XID, onePhase IN BOOLEAN)  RETURN PLS_INTEGER;
FUNCTION XA_ROLLBACK(xid IN DBMS_XA_XID)  RETURN PLS_INTEGER;
FUNCTION XA_FORGET(xid IN DBMS_XA_XID)  RETURN PLS_INTEGER;
FUNCTION XA_RECOVER RETURN DBMS_XA_XID_ARRAY;
FUNCTION XA_SETTIMEOUT(seconds IN PLS_INTEGER) RETURN PLS_INTEGER;
FUNCTION XA_GETLASTOER RETURN PLS_INTEGER;


/*
********************************************************************************
*   The following procedure is used for recovery sync in RAC                   *
********************************************************************************
*/
PROCEDURE dist_txn_sync;


/*
********************************************************************************
*   The following constants are defined for use in the flag field for          *
*   XA_START() and XA_END() functions:                                         *
********************************************************************************
*/

/* use TMNOFLAGS to indicate no flag value is selected */
TMNOFLAGS CONSTANT PLS_INTEGER := 00000000; 

/* dissociate caller from transaction branch */
TMSUCCESS  CONSTANT PLS_INTEGER := utl_raw.cast_to_binary_integer('04000000');

/* caller is joining existing transaction branch */
TMJOIN CONSTANT PLS_INTEGER := utl_raw.cast_to_binary_integer('00200000');

/* caller is suspending, not ending, association */
TMSUSPEND  CONSTANT PLS_INTEGER := utl_raw.cast_to_binary_integer('02000000');

/* caller is resuming association with suspended transaction branch */
TMRESUME  CONSTANT PLS_INTEGER := utl_raw.cast_to_binary_integer('08000000');

/*
********************************************************************************
*   The following constants are defined for possible return value of           *
*   DBMS_XA functions:                                                         *
********************************************************************************
*/

/* The inclusive lower bound of the rollback codes */
XA_RBBASE   CONSTANT PLS_INTEGER := 100;

/* The rollback was caused by an unspecified reason */
XA_RBROLLBACK CONSTANT PLS_INTEGER := XA_RBBASE;  
                                           
/* The rollback was caused by a communication failure */
XA_RBCOMMFAIL  CONSTANT PLS_INTEGER :=  XA_RBBASE+1;

/* A deadlock was detected*/
XA_RBDEADLOCK CONSTANT PLS_INTEGER := XA_RBBASE+2;

/* A condition that violates the integrity of the resources was detected */
XA_RBINTEGRITY  CONSTANT PLS_INTEGER := XA_RBBASE+3;

/* The resource manager rolled back the transaction for a reason not on
   this list */
XA_RBOTHER  CONSTANT PLS_INTEGER := XA_RBBASE+4;

/* A protocol error occurred in the resource manager */
XA_RBPROTO CONSTANT PLS_INTEGER := XA_RBBASE+5;

/* A transaction branch took long */
XA_RBTIMEOUT  CONSTANT PLS_INTEGER := XA_RBBASE+6;

/* May retry the transaction branch */
XA_RBTRANSIENT CONSTANT PLS_INTEGER :=  XA_RBBASE+7;

/* The inclusive upper bound of the rollback codes */
XA_RBEND  CONSTANT PLS_INTEGER := XA_RBTRANSIENT;

/* resumption must occur where suspension occurred */
XA_NOMIGRATE   CONSTANT PLS_INTEGER :=  9;

/* the transaction branch may have been heuristically completed */
XA_HEURHAZ CONSTANT PLS_INTEGER := 8; 

/* the transaction branch has been heuristically committed */
XA_HEURCOM CONSTANT PLS_INTEGER := 7;

/* the transaction branch has been heuristically rolled back */
XA_HEURRB  CONSTANT PLS_INTEGER :=  6;

/* some of the transaction branches has been heuristically committed,
   others have been rolled back */
XA_HEURMIX  CONSTANT PLS_INTEGER :=  5;

/* routine returned with no effect and may be re-issued */
XA_RETRY  CONSTANT PLS_INTEGER := 4;

/* the transaction was read-only and has been committed */
XA_RDONLY  CONSTANT PLS_INTEGER := 3;
                                           
/* normal execution */
XA_OK   CONSTANT PLS_INTEGER := 0;

/* asynchronous operation already outstanding */
XAER_ASYNC  CONSTANT PLS_INTEGER :=  -2;

/* a resource manager error occurred in the transaction branch */
XAER_RMERR CONSTANT PLS_INTEGER :=  -3; 

/* the XID is not valid */
XAER_NOTA CONSTANT PLS_INTEGER := -4;

/* invalid arguments were given */
XAER_INVAL CONSTANT PLS_INTEGER := -5;   

/* routine invoked in an improper context */
XAER_PROTO CONSTANT PLS_INTEGER := -6;

/* resource manager unavailable */
XAER_RMFAIL CONSTANT PLS_INTEGER :=  -7;

/* the XID already exists */
XAER_DUPID CONSTANT PLS_INTEGER :=  -8;              

/* resource manager doing work outside global transaction*/
XAER_OUTSIDE CONSTANT PLS_INTEGER :=  -9;

END dbms_xa;
/

CREATE OR REPLACE LIBRARY dbms_xa_lib TRUSTED AS STATIC
/

CREATE or REPLACE PUBLIC SYNONYM dbms_xa FOR sys.dbms_xa
/

CREATE or REPLACE PUBLIC SYNONYM dbms_xa_xid FOR sys.dbms_xa_xid
/

CREATE or REPLACE PUBLIC SYNONYM dbms_xa_xid_array FOR sys.dbms_xa_xid_array
/

GRANT EXECUTE on DBMS_XA to PUBLIC;
GRANT EXECUTE on DBMS_XA_XID to PUBLIC;
GRANT EXECUTE on DBMS_XA_XID_ARRAY to PUBLIC;
