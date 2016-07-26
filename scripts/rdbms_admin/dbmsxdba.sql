Rem
Rem $Header: rdbms/admin/dbmsxdba.sql /st_rdbms_11.2.0/2 2011/04/18 10:00:46 spetride Exp $
Rem
Rem dbmsxdba.sql
Rem
Rem Copyright (c) 2005, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxdba.sql - The Spec for the PL/SQL package DBMS_XDB_ADMIN
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    04/12/11 - Backport spetride_bug-12317504 from main
Rem    spetride    03/17/11 - move movexdb_tablespace from dbms_xdb
Rem                         - add trace for movexdb_tablespace
Rem    attran      10/30/09 - 8533638: ClearRepositoryXMLIndex
Rem    badeoti     03/21/09 - 
Rem                           dbms_csx_admin.updateMasterTable,guidto32,guidfrom32
Rem                           moved to dbms_csx_int
Rem    badeoti     03/19/09 - move dbms_xdb_admin.createnoncekey to dbms_xdbz
Rem    thbaby      10/27/07 - add dbms_csx_admin.GatherTokenTableStats
Rem    spetride    11/01/07 - dbms_csx_admin: cleanup
Rem    spetride    09/05/06 - apis for default token table names
Rem    spetride    03/24/06 - added dbms_csx_admin
Rem    thbaby      06/21/06 - add DropRepositoryXMLIndex
Rem    thbaby      05/03/06 - repository index - add/remove path
Rem    petam       01/10/05 - Created
Rem

CREATE OR REPLACE PACKAGE xdb.dbms_xdb_admin AUTHID CURRENT_USER IS 
--------
-- Procedure to create an XML Index on the repository
procedure CreateRepositoryXMLIndex;

-- Procedure to index resource at path 'path' or all resources in 
-- the subtree rooted at 'path'. 
procedure XMLIndexAddPath(path      IN VARCHAR2, 
                          recurse   IN boolean := TRUE);

-- Procedure to remove resource at path 'path' from the Repository
-- XML Index or to remove all resources in the subtree rooted at
-- 'path' from the Repository XML Index.
procedure XMLIndexRemovePath(path        IN VARCHAR2, 
                             recurse     IN boolean := TRUE);

-- Procedure to drop an XML Index on the repository
procedure DropRepositoryXMLIndex;

-- Procedure to unmark the indexed flags of the XML Index on the repository
procedure ClearRepositoryXMLIndex;

---------------------------------------------
-- PROCEDURE - movexdb_tablespace
--     Moves xdb in the specified tablespace. The move waits for all
--     concurrent XDB sessions to exit.
-- PARAMETERS - name of the tablespace where xdb is to be moved.
--            - trace: if TRUE, use set serveroutput on to display
--                     progress status information; default FALSE
--
---------------------------------------------
PROCEDURE movexdb_tablespace(new_tablespace IN VARCHAR2, 
                             trace IN BOOLEAN := FALSE);

---------------------------------------------
-- PROCEDURE - RebuildHierarchicalIndex
--     Rebuilds the hierarchical Index; Used after
--     imp/exp since we do cannot export data from
--     xdb$h_index table since it contains rowids
-- PARAMETERS -
--
---------------------------------------------
PROCEDURE RebuildHierarchicalIndex;

end dbms_xdb_admin;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_XDB_ADMIN FOR xdb.dbms_xdb_admin
/
GRANT EXECUTE ON xdb.dbms_xdb_admin TO DBA
/
show errors;



CREATE OR REPLACE PACKAGE xdb.dbms_csx_admin AUTHID CURRENT_USER IS

 DEFAULT_LEVEL  CONSTANT BINARY_INTEGER := 0;
 TAB_LEVEL      CONSTANT BINARY_INTEGER := 1;
 TBS_LEVEL      CONSTANT BINARY_INTEGER := 2;
 NOREG_LEVEL    CONSTANT BINARY_INTEGER := 3;

 NO_CREATE      CONSTANT BINARY_INTEGER := 0;
 NO_INDEXES     CONSTANT BINARY_INTEGER := 1;
 WITH_INDEXES   CONSTANT BINARY_INTEGER := 2;

 DEFAULT_TOKS   CONSTANT BINARY_INTEGER := 0;
 NO_DEFAULT_TOKS  CONSTANT BINARY_INTEGER := 1;      

---------------------------------------------
-- TTS support: multiple token repositories
----------------------------------------------
-- PROCEDURE RegisterTokenTableSet 
--     Registers a token table set: adds an entry in XDB$TTSET corresponding
--     to the new token table set, and creates (if required) the token tables
--     (with the corresponding indexes).
-- PARAMETERS
--  tstabno  - tablespace/table number of the tablespace/table using 
--           - the set of token table we register
--  guid     - globally unique identifier of the token table set
--           - if NULL, a new identifier is created, provided the user is SYS
--  flags    - TAB_LEVEL for table level, 
--           - TBS_LEVEL for tablespace level
--           - NOREG_LEVEL if the TTSET table needs not be updated
--  tocreate - NO_CREATE if no token tables are created
--           - NO_INDEXES if token tables are created, but no indexes
--           - WITH_INDEXES if token tables and corresponding indexes are created 
--  defaulttoks - if DEFAULT_TOKS, insert default token mappings 
-- NOTE
--     It is an error if flags = DEFAULT_LEVEL since the default token table set
--     already exists if XDB is installed.
----------------------------------------------
 procedure RegisterTokenTableSet(tstabno IN NUMBER DEFAULT NULL,
                                 guid IN RAW DEFAULT NULL, 
                                 flags IN NUMBER DEFAULT TBS_LEVEL, 
                                 tocreate IN NUMBER DEFAULT WITH_INDEXES,
                                 defaulttoks IN NUMBER DEFAULT DEFAULT_TOKS);

 procedure CopyDefaultTokenTableSet(tsno IN NUMBER,
                                    qnametable OUT VARCHAR2,
                                    nmspctable OUT VARCHAR2,
                                    pttable OUT VARCHAR2);


-------------------------------------------------
-- PROCEDURE  GetTokenTableInfo
--           Given the table name and the owner, returns the guid of the 
--           token table set where token mappings for this table can be found.
--           Returns also the names of the token tables, and whether the token
--           table set is the default one. 
-- NOTE
--       It should be called only for CSX tables; otherwise, it will not return an
--       error, just the default guid and token table names.
--       Returns error if there is no default token table set.
--  Needs SYS privileges.
-------------------------------------------------
 procedure GetTokenTableInfo(ownername IN VARCHAR2, tablename IN VARCHAR2,
                             guid OUT RAW, qnametable OUT VARCHAR2, nmspctable OUT VARCHAR2,
                             level OUT NUMBER, tabno OUT NUMBER);

 function GetTokenTableInfo(tabno IN NUMBER, guid OUT RAW) return BOOLEAN;


---------------------------------------------------------------
-- PROCEDURE GetTokenTableInfoByTablespace
--     Given a tablespace number, returns the guid and the token
--     table names for this tablespace. If there is no entry
--     in XDB$TTSET for this tablespace, it assumes the default 
--     guid is isued, and returns TRUE in isdefault.
--     containTokTabs is set to TRUE if the token tables for guid
--     are actually in this tablespace. (This is needed for procedural actions
--     for TTS.)
-- NOTE
--   Requires SYS privileges.
---------------------------------------------------------------

 procedure GetTokenTableInfoByTablespace(tsname IN VARCHAR2, tablespaceno IN NUMBER,
                                         guid OUT RAW, qnametable OUT VARCHAR2, 
                                         nmspctable OUT VARCHAR2,
                                         isdefault OUT BOOLEAN,
                                         containTokTab OUT BOOLEAN);

  FUNCTION instance_info_exp(name       IN  VARCHAR2,
                             schema     IN  VARCHAR2,
                             prepost    IN  PLS_INTEGER,
                             isdba      IN  PLS_INTEGER,
                             version    IN  VARCHAR2,
                             new_block  OUT PLS_INTEGER) RETURN VARCHAR2;

-- returns default path-id token table
  function PathIdTable return varchar2;
-- returns default qname-id token table
  function QnameIdTable return varchar2;
-- returns default namespace-id token table
  function NamespaceIdTable return varchar2;
-- procedure to gather stats on default token tables
  procedure GatherTokenTableStats;
END dbms_csx_admin;
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM DBMS_CSX_ADMIN FOR xdb.dbms_csx_admin
/
GRANT EXECUTE ON xdb.dbms_csx_admin TO DBA
/
show errors;
