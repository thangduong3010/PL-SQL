Rem ##########################################################################
Rem 
Rem Copyright (c) 2004, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      odmu101.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for Data Mining 10gR2 upgrade 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS   
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       xbarr    10/16/06 - update regsitry
Rem       xbarr    04/21/06 - remove dmsys upgrade code for 11g
Rem       xbarr    04/20/06 - fix lrg_2168526, remove odm from dba registry
Rem       xbarr    04/13/05 - bug#4260574 
Rem       xbarr    03/16/05 - bug#4238290
Rem       xbarr    03/14.05 - fix lrg_1836016
Rem       xbarr    01/09/05 - fix lrg_1816016 
Rem       xbarr    12/09/04 - fix Cluster TYPEs 
Rem       xbarr    12/01/04 - fix bug-4037586
Rem       xbarr    11/03/04 - add type for OCluster
Rem       xbarr    10/29/04 - fix bug-3936558, move validation proc to SYS 
Rem       xbarr    09/13/04 - fix bug-3878879 
Rem       pstengar 08/24/04 - add prvtdmpa.plb 
Rem       xbarr    08/03/04 - update dm 10.2 packages 
Rem       amozes   06/23/04 - remove hard tabs
Rem       xbarr    05/13/04 - xbarr_txn111447
Rem
Rem    xbarr    05/11/04 - Creation
Rem
Rem #########################################################################


ALTER SESSION SET CURRENT_SCHEMA = "SYS";

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem   PL/SQL API model upgrades (to be run as SYS only)
Rem
exec dmp_sys.upgrade_models('10.2.0');
/
commit;

Rem   Clean up sys.model$ if any rows prior to 11g upgrade
truncate table sys.model$;

Rem   Invoke 102 upgrade script to current release
@@odmu102

commit;
