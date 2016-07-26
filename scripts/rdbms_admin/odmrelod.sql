Rem
Rem $Header: odmrelod.sql 01-dec-2005.06:23:47 xbarr Exp $ odmrelod.sql
Rem
Rem ##########################################################################
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      odmrelod.sql
Rem
Rem    DESCRIPTION
Rem      Script for loading Data Mining component after downgrade from 11g.
Rem      It loads 10.2.0.X patch release code to reload 10.2 version of ODM
Rem
Rem    RETURNS
Rem
Rem    NOTES
Rem      This script must be run while connected as SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    xbarr    01/12/05 - remove version
Rem    xbarr    05/20/05 - Updated for 10.2
Rem    xbarr    06/25/04 - xbarr_dm_rdbms_migration
Rem    amozes   06/23/04 - remove hard tabs
Rem    xbarr    04/23/04 - fix bug 3579342 & 3375197 for downgrade
Rem    xbarr    12/22/03 - 10g r1 downgrade
Rem    xbarr    06/27/03 - update registry
Rem    fcay     06/23/03 - Update copyright notice
Rem    xbarr    05/30/03 - updated for reloading ODM 9204 release after downgrade from 10.1
Rem    xbarr    02/14/03 - xbarr_txn106309
Rem    xbarr    02/12/03 - Creation
Rem
Rem #########################################################################


set serveroutput on;


ALTER SESSION SET CURRENT_SCHEMA = "DMSYS";

Rem Upgrade DMSYS schema objects (TBD post 10.2.0.1)
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

Rem DM validate proc
@@odmproc.sql

execute sys.dbms_registry.upgraded('ODM');

execute sys.validate_odm;
