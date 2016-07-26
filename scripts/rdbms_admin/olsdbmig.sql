Rem
Rem $Header: rdbms/admin/olsdbmig.sql /main/11 2009/03/26 12:19:07 srtata Exp $
Rem
Rem olsdbmig.sql
Rem
Rem Copyright (c) 2001, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      olsdbmig.sql - OLS Data Base MIGration script.
Rem
Rem    DESCRIPTION
Rem      olsdbmig.sql performs the upgrade of the OLS component from all 
Rem      prior releases supported for upgrade (817, 901, and 920 for 10i). 
Rem      It first runs the "u" script to upgrade the tables and types
Rem      for OLS and then runs the scripts to load in the new package 
Rem      specifications, views, and package and type bodies,
Rem
Rem    NOTES
Rem      It is called from cmpdbmig.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srtata      03/02/09 - add olsu102 and olsu111
Rem    srtata      10/30/08 - use upgraded instead of loaded
Rem    srtata      10/15/08 - put back olstrig.sql to postupgrade as certain
Rem                           functionsin the script ned OLS cache to be
Rem                           initialized and DB in a normal mode
Rem    srtata      02/26/08 - move olstrig.sql from catuppst.sql
Rem    cchui       10/08/04 - 3936531: use validate_ols 
Rem    srtata      03/31/04 - check if OID enabled OLS 
Rem    srtata      02/13/04 - add olsu101.sql 
Rem    vpesati     11/25/02 - add server instance check
Rem    srtata      10/16/02 - add olsu920.sql
Rem    rburns      10/31/01 - fix syntax
Rem    shwong      10/26/01 - Merged shwong_upgdng
Rem    shwong      10/26/01 - Created
Rem

WHENEVER SQLERROR EXIT;
GRANT EXECUTE ON dbms_registry to LBACSYS;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

-- indicate the upgrade process has begun
EXECUTE dbms_registry.upgrading('OLS', 'Oracle Label Security', 'validate_ols');

COLUMN :file_name NEW_VALUE comp_file NOPRINT
VARIABLE file_name VARCHAR2(12)

BEGIN
  IF substr(dbms_registry.version('OLS'),1,5)='8.1.7' THEN
    :file_name := 'olsu817.sql';
  ELSIF substr(dbms_registry.version('OLS'),1,5)='9.0.1' THEN
    :file_name := 'olsu901.sql';
  ELSIF substr(dbms_registry.version('OLS'),1,5)='9.2.0' THEN
    :file_name := 'olsu920.sql';
  ELSIF substr(dbms_registry.version('OLS'),1,6)='10.1.0' THEN
    :file_name := 'olsu101.sql';
  ELSIF substr(dbms_registry.version('OLS'),1,6)='10.2.0' OR
        substr(dbms_registry.version('OLS'),1,6)='11.1.0' THEN
    :file_name := 'olsu111.sql';
  ELSE
    :file_name := 'nothing.sql';
  END IF;
END;
/

SELECT :file_name FROM DUAL;
@@&comp_file

COLUMN :file_name1 NEW_VALUE comp_file1 NOPRINT
VARIABLE file_name1 VARCHAR2(12)

COLUMN :file_name2 NEW_VALUE comp_file2 NOPRINT
VARIABLE file_name2 VARCHAR2(12)

DECLARE
oid_status NUMBER;

BEGIN
  SELECT COUNT(*) INTO oid_status FROM lbacsys.lbac$props
                  WHERE name='OID_STATUS_FLAG' AND value$=1;
  IF oid_status = 1 THEN
    :file_name1 := 'prvtlbd.plb';
    :file_name2 := 'prvtsad.plb';
  ELSE
    :file_name1 := 'nothing.sql';
    :file_name2 := 'nothing.sql';
  END IF;
END;
/

-- Load LBAC framework packages.
@@catlbac

-- Load SA policy packages.
@@catsa
@@catlabel

-- Install logon trigger to be used with OID
SELECT :file_name1 FROM DUAL;
@@&comp_file1

-- Replace all_sa views to be used with OID
SELECT :file_name2 FROM DUAL;
@@&comp_file2

BEGIN
  IF substr(dbms_registry.version('OLS'),1,5)='9.2.0' THEN
    :file_name1 := 'olsdap.sql';
  ELSE
    :file_name1 := 'nothing.sql';
  END IF;
END;
/

-- olsdap.sql will drop and reapply RLS policies on tables with
-- read_control ,check_control policy options (fix for bug#2499257).
SELECT :file_name1 FROM DUAL;
@@&comp_file1

DECLARE
    num number;
BEGIN
    dbms_registry.upgraded('OLS');
    SYS.validate_ols;
END;
/
commit;
