Rem
Rem $Header: cattsmcr.sql 16-nov-2004.11:05:41 mbastawa Exp $
Rem
Rem cattsmcr.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cattsmcr.sql - Transparent Session Migration CursoR component 
Rem                     Catalog creation
Rem
Rem    DESCRIPTION
Rem      This file defines the catalog views related to TSM 
Rem      Cursor component.
Rem
Rem    NOTES
Rem      There is TSMSYS schema if needed for containing TSM objects. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mbastawa    11/16/04 - mbastawa_tsmsch
Rem    mbastawa    10/28/04 - add SRS$ table, SRSIDX index
Rem    mbastawa    10/28/04 - Created
Rem

-- TABLE SRS$ : suspend result sets during TSM
create table TSMSYS.srs$        
(
  CURSOR int not null,            
  LOGICALSESSID raw(256) not null, 
  RESULTSET  blob,                 
  LOBROFF number(38),              
  LOBSIZE number(38),              
  CLIENTROWS int,                  
  LOBROWS int
)                    
  lob(resultset)     
  store as (disable storage in row pctversion 0 cache freepools 4)
  initrans 16
  storage (freelist groups 4 freelists 16) 
  tablespace sysaux
/

CREATE INDEX TSMSYS.SRSIDX ON TSMSYS.SRS$ (CURSOR, LOGICALSESSID) 
     nologging tablespace sysaux
/

COMMENT ON TABLE TSMSYS.SRS$ IS
'Internal table for transparent cursor result-set migration workspace for Suspending Result-Sets. Each row corresponds to a cursor in fetch during Transparent Session Migration. Note persistent columns values may not be always current as those in memory. Disabling LOB versioning since result-set caching duration is temporary. There can be many concurrent transactions (DMLs) per block of SRS$ rows. SYSAUX is now ASSM managed but it may not be upgrading from earlier versions hence storage clauses.'
/


COMMENT ON COLUMN TSMSYS.SRS$.CURSOR IS
'Cursor number (internal) of the result set'
/
COMMENT ON COLUMN TSMSYS.SRS$.LOGICALSESSID IS
'Client Logical Session ID (internally generated) that is same across all its server sessions'
/
COMMENT ON COLUMN TSMSYS.SRS$.RESULTSET IS
'Suspended result-set in a BLOB. Close or cancel on cursor deletes this row'
/
COMMENT ON COLUMN TSMSYS.SRS$.LOBROFF IS
'Offset (internal) for next read in the LOB '
/
COMMENT ON COLUMN TSMSYS.SRS$.LOBSIZE IS
'Current size of the LOB'
/
COMMENT ON COLUMN TSMSYS.SRS$.CLIENTROWS IS
'Current client row count (internal)'
/
COMMENT ON COLUMN TSMSYS.SRS$.LOBROWS IS
'Number (internal) of rows not yet sent by server to client'
/
