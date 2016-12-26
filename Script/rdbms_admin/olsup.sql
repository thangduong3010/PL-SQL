Rem
Rem $Header: olsup.sql 31-oct-2001.13:21:34 shwong Exp $
Rem
Rem olsup.sql
Rem
Rem Copyright (c) 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      olsup.sql - OLS UPgrade main driver script.
Rem
Rem    DESCRIPTION
Rem      This is the script which ODMA calls to determine if OLS needs
Rem      to be upgraded.  It uses OLS version information to determine
Rem      which upgrade scripts to call.
Rem
Rem    NOTES
Rem      Run by Oacle Database Migration Assistant.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shwong      10/31/01 - changes for ODMA directives
Rem    gmurphy     04/17/01 - Merged gmurphy_olsadd_odma_script
Rem    gmurphy     04/16/01 - Created
Rem

SET SERVEROUTPUT ON

DECLARE
  found BINARY_INTEGER := 0;
  vers varchar2(12);


BEGIN
  -- Check that schema.table exists
  SELECT 1 INTO found
  FROM sys.dba_objects
  WHERE owner = 'LBACSYS'
  AND object_name = 'LBAC$INSTALLATIONS'
  AND object_type = 'TABLE';

  -- Check that OLS requires upgrade
  EXECUTE IMMEDIATE 'BEGIN select substr(version,1,5) into :vers
       from LBACSYS.lbac$installations
       where component=''LBAC''; END;' 
  USING
     OUT vers;

   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:CONNECT_AS_SYSDBA_USER:');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:00955');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:02303');
   DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:ORA:IGNORE:02304');

   IF vers = '8.1.7' THEN
     DBMS_OUTPUT.PUT_LINE
       ('ODMA_DIRECTIVE:SCRIPT:UPGRADE:rdbms/admin/olsu817.sql');
   ELSIF vers = '9.0.1' THEN
     DBMS_OUTPUT.PUT_LINE
       ('ODMA_DIRECTIVE:SCRIPT:UPGRADE:rdbms/admin/olsu901.sql');
   END IF;
 
  EXCEPTION
    -- lbacsys or lbacsys.lbac$installations does not exist
    -- or OLS does not require upgrade.
    WHEN others THEN
       DBMS_OUTPUT.PUT_LINE('ODMA_DIRECTIVE:EXIT:NOT_INSTALLED:');

END;
/
