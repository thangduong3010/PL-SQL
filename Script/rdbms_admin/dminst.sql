Rem Copyright (c) 2001, 2006, Oracle. All rights reserved.  
Rem    NAME
Rem      dminst.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for the Data Mining option installation
Rem
Rem    RETURNS
Rem
Rem    NOTES
Rem     This script must be run while connected as SYS account
Rem
Rem     odmcrt.sql creates DMSYS schemas
Rem
Rem     catodm.sql calls all scripts which create ODM repository objects
Rem
Rem     input parameters  
Rem
Rem         &&1 -- SYSAUX tbs
Rem         &&2 -- temporary tbs name
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       mmcracke 03/08/06 - move catodm.sql to catproc.sql 
Rem       mmcracke 09/29/05 - Change DMSYS to SYS 
Rem       xbarr    11/05/04 - 
Rem       xbarr    07/23/04 - dbca lrgi fix 
Rem       xbarr    06/25/04 - xbarr_dm_rdbms_migration
Rem       xbarr    06/19/04 - update dbms_registry.loading 
Rem       xbarr    06/07/04 - remove PMML DTD 
Rem       xbarr    10/20/03 - add directory for loading PMML DTD
Rem       xbarr    07/17/03 - add validation invocation 
Rem       fcay     06/23/03 - Update copyright notice
Rem       xbarr    02/03/03 - add validate_odm call
Rem       xbarr    01/07/03 - add temp tbs as input parameter 
Rem       xbarr    01/06/03 - add sqlldr logfile as input parameter 
Rem       xbarr    12/23/02 - update loaded registry 
Rem       xbarr    11/06/02 - accept sysaux input
Rem       xbarr    10/10/02 - updated for 10i ODM installation   
Rem       xbarr    03/12/02 - update the order of registry 
Rem       xbarr    03/08/02 - add registry information in dba_registry
Rem       xbarr    03/07/02 - use @?/dm/admin for accepting sqlldr logdir 
Rem       xbarr    02/26/02 - accept log directory for sqlldr using &&3 
Rem       xbarr    01/23/02 - reverse to use .sql for dmcrt 
Rem       xbarr    01/14/02 - use .plb for dmcrt 
Rem       xbarr    11/20/01 - Merged xbarr_update_installer
Rem
Rem       xbarr    10/31/01 - Creation
Rem
Rem    


@@odmcrt.sql &&1 &&2 

execute sys.dbms_registry.loading('ODM','Oracle Data Mining','validate_odm','SYS',NULL,NULL);

@@odmproc.sql

alter session set current_schema = "SYS";

Rem @@catodm.sql

execute sys.dbms_registry.loaded('ODM');

execute sys.validate_odm;
