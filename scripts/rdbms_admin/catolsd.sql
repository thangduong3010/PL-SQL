Rem
Rem $Header: rdbms/admin/catolsd.sql /main/5 2009/03/26 12:19:06 srtata Exp $
Rem
Rem catolsd.sql
Rem
Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catolsd.sql - Install OLS packages with OID support
Rem
Rem    DESCRIPTION
Rem      This is the main rdbms/admin install script for installing
Rem      Oracle Label Security which implement Label Based access
Rem      controls on rows of data.  In addition, it enables OID support.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srtata      02/16/09 - remove logon trigger
Rem    cchui       10/08/04 - 3936531: use validate_ols 
Rem    srtata      04/10/03 - remove compatible check
Rem    shwong      01/17/03 - add prvtsad.sql
Rem    shwong      11/04/02 - shwong_bug-2640184
Rem    shwong      10/24/02 - Created

WHENEVER SQLERROR CONTINUE;
-------------------------------------------------------------------------

-- Disable all OLS database triggers so the script can be re-run,
-- if desired.
ALTER TRIGGER LBACSYS.lbac$before_alter DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_create DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_drop   DISABLE;
-- Create the LBACSYS account
@@catlbacs
-- add OLS to the registry
EXECUTE DBMS_REGISTRY.LOADING('OLS', 'Oracle Label Security', 'validate_ols', 'LBACSYS');

-- Load underlying LBACSYS tables, etc.
@@catlbac

-- Disable OLS triggers created by catlbac for install performance.
ALTER TRIGGER LBACSYS.lbac$before_alter DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_create DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_drop   DISABLE;

-- Load SA policy packages.
@@catsa
@@catlabel 

-- Install logon trigger to be used with OID
@@prvtlbd.plb
@@prvtsad.plb

-- Enable OLS database triggers and restart the database, so users,
-- including SYS can logon to the server after this point.
ALTER TRIGGER LBACSYS.lbac$after_create ENABLE;
ALTER TRIGGER LBACSYS.lbac$after_drop   ENABLE;
ALTER TRIGGER LBACSYS.lbac$before_alter ENABLE;

BEGIN
  dbms_registry.loaded('OLS', dbms_registry.release_version, 
            'Oracle Label Security Release ' || 
            dbms_registry.release_version    ||
            ' - ' || dbms_registry.release_status); 
  SYS.validate_ols;
END;
/
commit;

shutdown immediate

