Rem ##########################################################################
Rem 
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      odmcpu.sql
Rem
Rem    DESCRIPTION
Rem      Script for Data Mining bundle patch loading 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS. After running the script, 
Rem      ODM should be at 10.2.0.X patch release level inline with rdbms quarterly
Rem      bundle patch release   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    xbarr    01/12/05 - update version
Rem    xbarr    04/22/05 - xbarr_add_102_patch_file
Rem    xbarr    04/13/05 - Creation
Rem
Rem #########################################################################


set serveroutput on;


ALTER SESSION SET CURRENT_SCHEMA = "DMSYS";

Rem Upgrade DMSYS schema objects (TBD depends on bundle patch contents)
Rem @@dmsyssch_patch.sql

Rem Upgrade DMSYS packages
@@dmproc.sql

Rem Upgrade Trusted Code BLAST
@@dbmsdmbl.sql

Rem Upgrade ODM Predictive package
@@dbmsdmpa.sql
@@prvtdmpa.plb

Rem Upgrade OJDM internal package
@@prvtdmj.plb


ALTER SESSION SET CURRENT_SCHEMA = "SYS";

execute sys.dbms_registry.upgraded('ODM');

Rem DM validate proc
@@odmproc.sql

execute sys.validate_odm;
