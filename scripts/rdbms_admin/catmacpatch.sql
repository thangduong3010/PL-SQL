Rem
Rem
Rem catmacpatch.sql
Rem
Rem Copyright (c) 2008, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catmacpatch.sql - Patches mandatory access control configuration schema and packages.
Rem
Rem    DESCRIPTION
Rem      This is the main patching script for patching the database objects
Rem      in Oracle Database vault.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA, no other passwords are needed for this
Rem      patching script.
Rem      This runs a subset of the scripts called by catmac (install driver)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sanbhara    03/01/11 - Backport sanbhara_bug-10225918 from main
Rem    jsamuel     02/03/09 - remove set echo
Rem    jsamuel     09/26/08 - DV patching script
Rem    jsamuel     09/26/08 - Created
Rem

WHENEVER SQLERROR CONTINUE;

-- bug 6938028: Database Vault Protected Schema.
-- Insert the rows into metaview$ for the real Data Pump types.
@@catmacdd.sql

-- Load MACSEC Factor Convenience Functions
@@dvmacfnc.plb

-- Load underlying DVSYS objects
@@catmacc.sql

-- Load MAC packages.
@@catmacp.sql
@@prvtmacp.plb

-- tracing view
-- grants on DV objects to DV roles
-- create public synonyms for DV objects
@@catmacg.sql

-- Load MAC roles.
@@catmacr.sql

--Bug 10225918 - removed call to catmacd.sql.


-- create the DV login and DDL triggers
-- establish DV audit policy
@@catmact.sql

commit;
