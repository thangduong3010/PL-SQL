Rem
Rem $Header: catbac.sql 10-apr-2007.14:45:35 mabhatta Exp $
Rem
Rem catbac.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catbac.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mabhatta    04/10/07 - Provide Character Representation of BackoutMode
Rem    mabhatta    02/15/06 - Flashback Transaction Backout 
Rem    mabhatta    02/15/06 - Created
Rem

-- input types to our package routines.
CREATE OR REPLACE TYPE XID_ARRAY AS VARRAY(100) OF RAW(8)
/
                                        
CREATE OR REPLACE TYPE TXNAME_ARRAY AS VARRAY(100) OF VARCHAR2(256)
/                 

-- For now we create a tablespace for this feature. Later we might want
-- to include this in sysaux or system tablespace.
-- CREATE TABLESPACE BACKOUT_TBS DATAFILE 'backout_tbs.dbf' SIZE 10M REUSE
--   AUTOEXTEND ON MAXSIZE UNLIMITED
-- /                 

-- This is the current state of a transaction. This will atomically
-- updated with the compensating transaction. Thus if a compensating
-- transaction is backed out, it will automatically back out the
-- changes done to this table.  You must be careful about deleting
-- rows from this table, as the system might compensate an already
-- compensated transaction if there is no record of the compensated
-- transaction in this table.
CREATE TABLE TRANSACTION_BACKOUT_STATE$ (
   COMPENSATING_XID RAW(8),                  /* the compensating transaction */
   XID              RAW(8),                     /* a compensated transaction */
   BACKOUT_MODE     NUMBER,          /* the mode in which xid was backed out */
   DEPENDENT_XID    RAW(8),                       /* a dependent xid for xid */
   USER#            NUMBER           /* user performing the compensating txn */
) TABLESPACE SYSTEM
/             

CREATE INDEX TXN_BACKOUT_STATE_IDX1$ on 
  TRANSACTION_BACKOUT_STATE$(COMPENSATING_XID)
/  

CREATE INDEX TXN_BACKOUT_STATE_IDX2$ on
  TRANSACTION_BACKOUT_STATE$(XID)
/

CREATE INDEX TXN_BACKOUT_STATE_IDX3$ on
  TRANSACTION_BACKOUT_STATE$(USER#)
/  

-- This is the detailed report based on the work done by the
-- compensating transaction. The updates to this table will be done in
-- an autonomous transaction. In this scenario, even if a compensating
-- transaction is backed out, it will have no effect on the changes to
-- this table.
CREATE TABLE TRANSACTION_BACKOUT_REPORT$ (
   COMPENSATING_XID      RAW(8) PRIMARY KEY,         /* the compensating txn */
   COMPENSATING_TXN_NAME VARCHAR2(256),      /* compensating txn name if any */
   COMMIT_TIME           DATE,             /* timestamp for compensating_xid */
   XID_REPORT            CLOB,                      /* backout report in XML */
   USER#                 NUMBER                    /* user doing the backout */
) TABLESPACE SYSAUX
/

GRANT EXECUTE ON XID_ARRAY to PUBLIC;
/

GRANT EXECUTE ON TXNAME_ARRAY to PUBLIC;
/

 
-- Create the views on top of the tables             
CREATE OR REPLACE VIEW DBA_FLASHBACK_TXN_STATE AS
  SELECT S.COMPENSATING_XID,
         S.XID,
         S.DEPENDENT_XID,
         decode(S.BACKOUT_MODE,
                1, 'NOCASCADE',
                2, 'NOCASCADE_FORCE',
                3, 'NONCONFLICT_ONLY',
                4, 'CASCADE') AS BACKOUT_MODE,
         U.NAME  as USERNAME 
  FROM TRANSACTION_BACKOUT_STATE$ S, USER$ U 
    WHERE S.USER# = U.USER#
/

CREATE OR REPLACE VIEW USER_FLASHBACK_TXN_STATE AS
  SELECT COMPENSATING_XID,
         XID,
         DEPENDENT_XID,
         decode(BACKOUT_MODE,
                1, 'NOCASCADE',
                2, 'NOCASCADE_FORCE',
                3, 'NONCONFLICT_ONLY',
                4, 'CASCADE') AS BACKOUT_MODE
    FROM TRANSACTION_BACKOUT_STATE$ 
    WHERE USER# = USERENV('SCHEMAID')
/ 

CREATE OR REPLACE VIEW DBA_FLASHBACK_TXN_REPORT AS
  SELECT S.COMPENSATING_XID,
         S.COMPENSATING_TXN_NAME,
         S.COMMIT_TIME,
         S.XID_REPORT,
         U.NAME AS USERNAME
  FROM TRANSACTION_BACKOUT_REPORT$ S, USER$ U
    WHERE S.USER# = U.USER#
/

CREATE OR REPLACE VIEW USER_FLASHBACK_TXN_REPORT AS
  SELECT COMPENSATING_XID, COMPENSATING_TXN_NAME, COMMIT_TIME, XID_REPORT
    FROM TRANSACTION_BACKOUT_REPORT$
    WHERE USER# = USERENV('SCHEMAID')
/

CREATE OR REPLACE PUBLIC SYNONYM USER_FLASHBACK_TXN_STATE 
  FOR SYS.USER_FLASHBACK_TXN_STATE
/  

CREATE OR REPLACE PUBLIC SYNONYM USER_FLASHBACK_TXN_REPORT 
  FOR SYS.USER_FLASHBACK_TXN_REPORT
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_FLASHBACK_TXN_STATE 
  FOR SYS.DBA_FLASHBACK_TXN_STATE
/  

CREATE OR REPLACE PUBLIC SYNONYM DBA_FLASHBACK_TXN_REPORT 
  FOR SYS.DBA_FLASHBACK_TXN_REPORT
/

GRANT SELECT ON SYS.USER_FLASHBACK_TXN_STATE TO PUBLIC WITH GRANT OPTION
/

GRANT SELECT ON SYS.USER_FLASHBACK_TXN_REPORT TO PUBLIC WITH GRANT OPTION
/

GRANT EXECUTE ON XID_ARRAY to PUBLIC;
/

GRANT EXECUTE ON TXNAME_ARRAY to PUBLIC;
/
