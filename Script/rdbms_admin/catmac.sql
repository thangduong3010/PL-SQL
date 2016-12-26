Rem
Rem Copyright (c) 2004, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catmac.sql - Install mandatory access control configuration schema and packages.
Rem
Rem    DESCRIPTION
Rem      This is the main install script for installing the database objects
Rem      required for Oracle Database vault.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA and requires that passwords be specified for
Rem      SYSDBA, DV_OWNER and DV_ACCOUNT_MANAGER
Rem
Rem        Parameter 1 = account default tablespace
Rem        Parameter 2 = account temp tablespace
Rem        Parameter 3 = SYS password
Rem        Parameter 4 = DV_OWNER_USERNAME
Rem        Parameter 5 = DV_OWNER_PASSWORD
Rem        Parameter 6 = DV_ACCOUNT_MANAGER_USERNAME
Rem        Parameter 7 = DV_ACCOUNT_MANAGER_PASSWORD
Rem

Rem    MODIFIED   (MM/DD/YY)
Rem    sanbhara   03/01/11 - Backport sanbhara_bug-10225918 from main
Rem    srtata     03/17/09 - removed OLS logon trigger
Rem    jsamuel    01/12/09 - call catmaca audit statements for DV
Rem    jsamuel    09/30/08 - passwordless patching and simplify catmac
Rem    youyang    09/18/08 - Bug 6739582: DBCA failes when use dot for
Rem                          dvowner's password
Rem    pknaggs    04/20/08 - bug 6938028: Database Vault Protected Schema.
Rem    pknaggs    06/20/07 - 6141884: backout fix for bug 5716741.
Rem    pknaggs    05/29/07 - 5716741: sysdba can't do account management.
Rem    ruparame   02/22/07 - Adding Network IP privileges to DVSYS
Rem    ruparame   02/20/07 - 
Rem    ruparame   01/20/07 - DV/ DBCA Integration
Rem    ruparame   01/13/07 - DV/DBCA Integration
Rem    ruparame   01/10/07 - DV/DBCA Integration
Rem    mxu        01/26/07 - Fix error
Rem    rvissapr   12/01/06 - add validate_dv
Rem    jciminsk   05/02/06 - catmacp.plb to prvtmacp.plb, to cleanup naming 
Rem    jciminsk   05/02/06 - created admin/catmac.sql 
Rem    jciminsk   05/02/06 - created admin/catmac.sql 
Rem    tchorma    02/04/06 - Disable LBACSYS triggers before performing 
Rem                          installation 
Rem    sgaetjen   11/10/05 - add exit to end of script for options install 
Rem    sgaetjen   08/19/05 - Comment out OLS recompile 
Rem    sgaetjen   08/18/05 - Refactor for OUI 
Rem    sgaetjen   08/11/05 - sgaetjen_dvschema
Rem    sgaetjen   08/10/05 - OLS init check 
Rem    sgaetjen   08/03/05 - correct comments 
Rem    sgaetjen   08/03/05 - corrected parameter for sys password 
Rem    sgaetjen   08/03/05 - need to supply password for SYS now 
Rem    sgaetjen   08/02/05 - add DVF package body compile 
Rem    sgaetjen   07/30/05 - separate DVSYS and SYS commands 
Rem    sgaetjen   07/28/05 - dos2unix
Rem    sgaetjen   07/25/05 - Created.

connect sys/"&3" as sysdba

WHENEVER SQLERROR CONTINUE;

-- Disable the rest of the OLS triggers before DV install
ALTER TRIGGER LBACSYS.lbac$before_alter DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_create DISABLE;
ALTER TRIGGER LBACSYS.lbac$after_drop   DISABLE;

-- bug 6938028: Database Vault Protected Schema.
-- Insert the rows into metaview$ for the real Data Pump types.
@@catmacdd.sql

-- Create the DV accounts
@@catmacs.sql &1 &2 "&5"

-- Load MACSEC Factor Convenience Functions
@@dvmacfnc.plb

connect dvsys/"&5"

-- Load underlying DVSYS objects
@@catmacc.sql

-- Load MAC packages.
@@catmacp.sql
@@prvtmacp.plb

-- tracing view
-- grants on DV objects to DV roles
-- create public synonyms for DV objects
@@catmacg.sql

connect sys/"&3" as sysdba
-- Load MAC roles.
@@catmacr.sql

-- Load MAC seed data. Load NLS seed data from catmacd.sql - Bug Fix 10225918.
connect sys/"&3" as sysdba

DECLARE
 v_OH_path varchar2(255);
 v_dlf_path    varchar2(255);
 v_pfid number;
 PLATFORM_WINDOWS32    CONSTANT BINARY_INTEGER := 7;
 PLATFORM_WINDOWS64    CONSTANT BINARY_INTEGER := 8;

 begin
  sys.dbms_system.get_env('ORACLE_HOME',v_OH_path);
  SELECT platform_id INTO v_pfid FROM v$database;

  IF v_pfid = PLATFORM_WINDOWS32 OR v_pfid = PLATFORM_WINDOWS64
  THEN 
    v_dlf_path := v_OH_path||'\dv\admin\';
  ELSE
    v_dlf_path := v_OH_path||'/dv/admin/';
  END IF;

  EXECUTE IMMEDIATE 'create or replace directory DV_ADMIN_DIR AS'''|| v_dlf_path || '''';
 end;
/

grant read on directory DV_ADMIN_DIR to dvsys;


connect dvsys/"&5"
@@catmacd.sql

-- create the DV login 
@@catmact.sql

-- establish DV audit policy
@@catmaca.sql

connect sys/"&3" as sysdba
--Removes privleges from the DVSYS and DVF accounts
--used during the install
@@catmach.sql

-- Other installation steps
-- Create DV owner and DV account manager accounts 
@@catmacpre.sql &1 &2 "&3" &4 "&5" &6 "&7"

commit;
