Rem ##########################################################################
Rem 
Rem Copyright (c) 2004, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      odmu102.sql
Rem
Rem    DESCRIPTION
Rem      Run Data Mining 10.2 to 11g model upgrade 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    xbarr       01/29/09 - update ODM in registry
Rem    xbarr       12/20/06 - update ODM as VALID (bug#5615187)
Rem    xbarr       10/11/06 - delete ODM entry from registry$
Rem    xbarr       03/28/06 - remove ODM from registry
Rem    xbarr       03/09/06 - move dmsys upgrade to c1002000.sql
Rem    mmcracke    10/04/05 - Creation
Rem
Rem #########################################################################


ALTER SESSION SET CURRENT_SCHEMA = "SYS";

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem   PL/SQL API model upgrades (to be run as SYS only)
Rem
Rem   Migrate dmsys metadata and dmuser model to 11g 
exec dmp_sys.upgrade_models('11.0.0');
/
commit;

Rem =====================================================================================
Rem Update ODM entry in DBA_REGISTRY for downgrade purpose
Rem
Rem In 11g, ODM component has been migrated from DMSYS to SYS. ODM is no longer a component.
Rem Once a user decides there is no need to perform a rdbms downgrade, DMSYS schema can be 
Rem dropped from the upgraded database.  ODM entry will be removed from dba registry once 
Rem DMSYS is dropped.
Rem =====================================================================================

execute sys.dbms_registry.upgraded('ODM');

update sys.registry$ set vproc=NULL where cid = 'ODM' and cname = 'Oracle Data Mining';

execute sys.dbms_registry.valid('ODM');

commit;

@@odmu111.sql

commit;
