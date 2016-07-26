-- $Header: rdbms/src/server/security/ols/lbac/lbacsys.sql /st_rdbms_11.2.0/3 2013/04/23 22:42:12 aramappa Exp $
--
-- lbacsys.sql
--
-- Copyright (c) 2008, 2013, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      lbacsys.sql
--
--    DESCRIPTION
--       Creates the LBACSYS user and grants the necessary privileges
--
--    NOTES
--      Run as SYS      
--      The compatible init parm must be set to 8.1.0 (does not default
--          in the NDE test environment
--
--    MODIFIED   (MM/DD/YY)
--    aramappa    04/17/13 - Backport aramappa_bug-16593494 from MAIN
--    srtata      05/16/12 - bug 14033506: grant execute on dbms_sql to lbacsys
--    jkati       06/17/11 - register system procedure callout
--    sarchak     04/14/08 - Bug 6925041,Creating aud$ in correct tablespace.
--    nkgopal     01/23/08 - I_AUD1 index is dropped in this release
--    mjgreave    08/24/04 - use system tablespace for lbacsys #(3838614)
--    srtata      07/22/04 - remove connect role for lbacsys 
--    cchui       05/04/04 - grant select on v_$instance to lbacsys 
--    shwong      11/30/01 - grant dbms_registry to lbacsys
--    gmurphy     04/08/01 - add 2001 to copyright
--    gmurphy     04/06/01 - add index to system.aud$ table
--    gmurphy     04/02/01 - LBAC_DBA to lbacsys.sql
--    gmurphy     02/26/01 - qualify objects for install as SYSDBA
--    gmurphy     02/13/01 - change for upgrade script
--    gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
--    rsripada    09/29/00 - move aud$ to system
--    cchui       08/21/00 - give lbacsys GRANT OPTION on dba_role_privs
--    rsripada    05/12/00 - add PL/SQL block to drop all contexts,roles
--    cchui       05/01/00 - drop all triggers
--    rsripada    03/02/00 - remove DATATYPE variable
--    rsripada    02/24/00 - grant drop role to lbacsys
--    rsripada    02/21/00 - define DATATYPE
--    rburns      02/16/00 - add select on v_tcsh 6.05.00 (Cornell) 94/19/06 (s
--    rsripada    02/02/00 - add grants on selects to sys dd tables
--    rsripada    01/19/00 - add aud$ related statements from other sql scripts
--    rsripada    01/13/00 - drop lbac_ctx context
--    rsripada    12/22/99 - add grant  select on dba_role_privs  to lbacsys
--    rsripada    12/07/99 - Grant create role to lbacsys
--    cchui       11/19/99 - update exppkgact$ for import/export
--    cchui       10/21/99 - drop synonym for aud$
--    rsripada    10/12/99 - grant some more privileges to LBACSYS
--    kraghura    10/06/99 - adding echo
--    cchui       09/15/99 - grant create any table to lbacsys
--    rsripada    08/25/99 - invalidate after_drop trigger
--    rsripada    08/20/99 - grant select on v_$parameter,copy aud$
--    rsripada    08/16/99 - grant select on v_$session
--    rburns      07/28/99 - removed grants on SYS tables 
--    vpesati     07/27/99 - add EXECUTE ANY PROCEDURE priv
--    vpesati     07/23/99 - grant privs on sys dd tables
--    vpesati     07/12/99 - add grant on DBMS_RLS
--    rburns      07/06/99 - Add privileges for public synonyms
--    vpesati     07/02/99 - add user cascade
--    rburns      06/24/99 - Add privileges for MLS
--    rburns      06/02/99 - Created
--

CREATE USER LBACSYS IDENTIFIED BY LBACSYS DEFAULT TABLESPACE SYSTEM;

GRANT  RESOURCE TO LBACSYS;

GRANT CREATE SESSION TO LBACSYS;

GRANT CREATE LIBRARY TO LBACSYS;
GRANT CREATE ANY TRIGGER TO LBACSYS;
GRANT ADMINISTER DATABASE TRIGGER TO LBACSYS;
GRANT CREATE ANY CONTEXT TO LBACSYS;
GRANT DROP ANY CONTEXT TO LBACSYS;
GRANT CREATE PUBLIC SYNONYM TO LBACSYS;
GRANT DROP PUBLIC SYNONYM TO LBACSYS;
GRANT EXECUTE ON DBMS_RLS TO LBACSYS;
GRANT EXECUTE ON DBMS_REGISTRY TO LBACSYS;
GRANT SELECT ANY TABLE TO LBACSYS WITH ADMIN OPTION;
GRANT DELETE ANY TABLE TO LBACSYS;
GRANT INSERT ANY TABLE TO LBACSYS;
GRANT ALTER ANY TABLE TO LBACSYS;
GRANT ALTER ANY TRIGGER TO LBACSYS;
GRANT EXECUTE ANY PROCEDURE TO LBACSYS;
GRANT SELECT ON V_$SESSION TO LBACSYS;
GRANT SELECT ON GV_$SESSION TO LBACSYS;
GRANT SELECT ON V_$PARAMETER TO LBACSYS;
GRANT SELECT ON V_$INSTANCE TO LBACSYS;
GRANT SELECT ON GV_$INSTANCE TO LBACSYS;
GRANT CREATE ANY TABLE TO LBACSYS;
GRANT CREATE VIEW  TO LBACSYS;
GRANT SELECT ON AUDIT_ACTIONS TO LBACSYS WITH GRANT OPTION;
GRANT SELECT ON STMT_AUDIT_OPTION_MAP TO LBACSYS WITH GRANT OPTION;
GRANT SELECT ON V_$VERSION TO LBACSYS WITH GRANT OPTION;
GRANT SELECT ON V_$CONTEXT TO LBACSYS WITH GRANT OPTION;
GRANT SELECT ON DBA_TAB_COMMENTS TO LBACSYS WITH GRANT OPTION;
GRANT SELECT ON DBA_ROLE_PRIVS TO LBACSYS WITH GRANT OPTION;
GRANT SELECT ON OBJ$ TO LBACSYS;
GRANT SELECT ON COL$ TO LBACSYS;
GRANT SELECT ON USER$ TO LBACSYS;
GRANT SELECT ON COLTYPE$ TO LBACSYS;
GRANT SELECT,INSERT,DELETE ON SYS.EXPDEPACT$ TO LBACSYS;
GRANT CREATE ROLE TO LBACSYS;
GRANT DROP ANY ROLE TO LBACSYS;

-- create LBAC_DBA role and grant it to LBACSYS
CREATE ROLE LBAC_DBA;
GRANT LBAC_DBA to LBACSYS WITH ADMIN OPTION;

-- Bug 14033506: This is required as PUBLIC may not have this privilege.
GRANT EXECUTE ON SYS.DBMS_SQL to LBACSYS;

-- create aud$ table in system schema, drop the aud$ table in sys
-- schema and create a private synonym under sys for aud$.


DECLARE
  tbs_name    VARCHAR2(30);
BEGIN
    select TABLESPACE_NAME INTO tbs_name FROM dba_tables where TABLE_NAME='AUD$';
    EXECUTE IMMEDIATE 'CREATE TABLE SYSTEM.aud$ tablespace '||dbms_assert.simple_sql_name(tbs_name) ||' AS SELECT * FROM aud$';
    EXECUTE IMMEDIATE 'DROP TABLE aud$';
    EXECUTE IMMEDIATE 'CREATE SYNONYM aud$ FOR SYSTEM.aud$';
END;
/

-- For import/export
GRANT EXECUTE ON SYS.DBMS_ZHELP TO LBACSYS;
DELETE FROM exppkgact$ WHERE PACKAGE = 'LBAC_UTL';
INSERT INTO exppkgact$ VALUES ('LBAC_UTL','LBACSYS',1,1000);
INSERT INTO exppkgact$ VALUES ('LBAC_UTL','LBACSYS',2,2000);
INSERT INTO exppkgact$ VALUES ('LBAC_UTL','LBACSYS',3,3000);
