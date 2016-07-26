Rem ##########################################################################
Rem 
Rem Copyright (c) 2001, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      odmu920.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for Data Mining Migration from 920 to 10i 
Rem      Script to be called by ?/dm/admin/odmdbmig.sql
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       xbarr    03/06/07 - fix bug-5919695, mark odm as valid
Rem       xbarr    04/20/06 - fix lrg2168526, remove odm from dba registry
Rem       xbarr    10/29/04 - fix bug-3936558, moving validation code into SYS 
Rem       xbarr    08/18/04 - update registry 
Rem       xbarr    08/05/04 - remove NULL in registry 
Rem       xbarr    07/23/04 - updated for DM 10gR2 upgrade 
Rem       xbarr    06/25/04 - xbarr_dm_rdbms_migration
Rem       amozes   06/23/04 - remove hard tabs
Rem       xbarr    05/12/04 - add 10gR2 upgrade script 
Rem       xbarr    03/05/04 - fix bug 3088233 
Rem       xbarr    07/17/03 - add validation once upgrade completes 
Rem       fcay     06/23/03 - Update copyright notice
Rem       xbarr    06/16/03 - exclude dmuserld, to be run separately 
Rem       xbarr    06/02/03 - update DM User dataset loading, remove dmpsysup 
Rem       xbarr    03/10/03 - add dmcl.plb loading 
Rem       xbarr    03/08/03 - remove error table loading 
Rem       xbarr    02/03/03 - add validate proc 
Rem       xbarr    01/27/03 - change order of registry 
Rem       xbarr    01/13/03 - update schema registration 
Rem       xbarr    12/17/02 - change ODM to DMSYS in registry 
Rem       xbarr    11/18/02 - change notation to @@
Rem       xbarr    11/13/02 - update grant  
Rem       xbarr    09/25/02 - xbarr_txn104463
Rem       xbarr    09/24/02 - updated for 10i upgrade 
Rem       xbarr    09/24/02 - replicated from 9202 branch
Rem       xbarr    08/02/02 - xbarr_txn102957
Rem       xbarr    06/06/02 - relocate odmdbmig script to in dm/admin/odmu901.sql
Rem       xbarr    03/12/02 - add dmerrtbl_mig 
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

ALTER SESSION SET CURRENT_SCHEMA = "SYS";

execute sys.dbms_registry.upgraded('ODM');

update sys.registry$ set vproc=NULL where cid = 'ODM' and cname = 'Oracle Data Mining';

execute sys.dbms_registry.valid('ODM');

commit;
