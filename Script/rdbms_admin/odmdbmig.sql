Rem ##########################################################################
Rem 
Rem Copyright (c) 2001, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      odmdbmig.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for Data Mining Migration 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       xbarr    10/29/09 - add 11.1 upgrade script
Rem       mmcracke 10/04/05 - add 10.2 migration script
Rem       xbarr    06/25/04 - xbarr_dm_rdbms_migration
Rem       amozes   06/23/04 - remove hard tabs
Rem       xbarr    03/05/04 - fix bug 3088233 
Rem       fcay     06/23/03 - Update copyright notice
Rem       xbarr    12/17/02 - move registry to odmu920 
Rem       xbarr    12/16/02 - add dmsys account lock & expire 
Rem       xbarr    11/19/02 - add check server proc
Rem       xbarr    11/18/02 - update notation
Rem       xbarr    11/13/02 - update registry
Rem       xbarr    10/07/02 - update banner
Rem       xbarr    09/24/02 - replicate changes from 9202 branch
Rem       xbarr    06/06/02 - modified to call odmu901 & odmu920
Rem       xbarr    06/06/02 - relocate script location
Rem       xbarr    03/12/02 - add dmerrtbl_mig
Rem       xbarr    03/12/02 - add error table loading 
Rem       xbarr    03/08/02 - add registry information in dba_registry 
Rem       xbarr    03/07/02 - add error table loading
Rem       xbarr    03/07/02 - use separate sqlldr related file
Rem       xbarr    03/07/02 - remove odmupd line
Rem       xbarr    01/24/02 - add dmmig.sql for R2 privileges 
Rem       xbarr    01/21/02 - add PMML dataset addition 
Rem       xbarr    01/14/02 - commented out dmupd. Will be replaced by dmconfig
Rem       xbarr    01/14/02 - use .plb 
Rem       xbarr    12/10/01 - Merged xbarr_update_shipit
Rem       xbarr    12/04/01 - Merged xbarr_migration_scripts
Rem
Rem    xbarr    12/10/01 - Updated script name and location
Rem    xbarr    12/03/01 - Updated to be called by ODMA
Rem    xbarr    10/27/01 - Creation
Rem
Rem #########################################################################

Rem Check dba_registry to determine which migration version script to be called

ALTER SESSION SET CURRENT_SCHEMA = "SYS";

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem Setup ODM script filename variable

COLUMN :file_name NEW_VALUE comp_file NOPRINT
VARIABLE file_name VARCHAR2(50)

Rem Select relavant migration scripts to run
BEGIN
IF substr(dbms_registry.version('ODM'),1,5)='9.0.1' THEN
:file_name :=dbms_registry.nothing_script;
ELSIF substr(dbms_registry.version('ODM'),1,5)='9.2.0' THEN
:file_name :='@odmu920.sql';
ELSIF substr(dbms_registry.version('ODM'),1,6)='10.1.0' THEN
:file_name :='@odmu101.sql';
ELSIF substr(dbms_registry.version('ODM'),1,6)='10.2.0' THEN
:file_name :='@odmu102.sql';
ELSIF substr(dbms_registry.version('ODM'),1,6)='11.1.0' THEN
:file_name :='@odmu111.sql';
ELSE
:file_name :=dbms_registry.nothing_script;
END IF;
END;
/
select :file_name from dual;
@&comp_file

commit;

ALTER SESSION SET CURRENT_SCHEMA = "SYS";

commit;
