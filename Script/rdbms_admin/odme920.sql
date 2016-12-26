Rem ##########################################################################
Rem 
Rem Copyright (c) 2001, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      odme920.sql
Rem
Rem    DESCRIPTION
Rem      Run all sql scripts for Data Mining Downgrade from 10i to 920 
Rem
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This script must be run while connected as SYS   
Rem
Rem      The script can not be used if odmclean.sql has run
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       xbarr    08/03/04 - update registry 
Rem       xbarr    06/25/04 - xbarr_dm_rdbms_migration
Rem       amozes   06/23/04 - remove hard tabs
Rem       xbarr    03/05/04 - downgrade to 9.2.0.4 
Rem       fcay     06/23/03 - Update copyright notice
Rem       xbarr    01/20/03 - update registry for down grading 
Rem       xbarr    11/05/02 - cleanup 10i objects in ODM after downgrade
Rem       xbarr    09/26/02 - update privs
Rem       xbarr    09/25/02 - xbarr_txn104463
Rem       xbarr    09/24/02 - updated for 10i downgrade 
Rem       xbarr    09/24/02 - replicated from 9202 branch
Rem       xbarr    08/02/02 - xbarr_txn102957
Rem
Rem #########################################################################

ALTER SESSION SET CURRENT_SCHEMA = "SYS";

execute dbms_registry.downgrading('ODM',NULL,NULL,'ODM',NULL);

Rem Grant required privileges back to ODM
grant
  SELECT_CATALOG_ROLE,
  AQ_ADMINISTRATOR_ROLE,
  AQ_USER_ROLE,
  ALTER SYSTEM,
  CREATE ANY TABLE,
  DROP ANY TABLE,
  CREATE ANY VIEW,
  DROP ANY VIEW,
  INSERT ANY TABLE,
  SELECT ANY TABLE,
  UPDATE ANY TABLE,
  CREATE ANY INDEX
to ODM;


ALTER SESSION SET CURRENT_SCHEMA = "ODM";

Rem Remove Migration JSP from ODM
drop package dmt_odm_migr;

Rem Remove DM metadata resided in DM User schema after downgrade
drop table dm$apply_content_item;
drop table dm$apply_content_setting;
drop table dm$apply_content_setting_array;
drop table dm$attribute;
drop table dm$attribute_property;
drop table dm$category;
drop table dm$category_ex;
drop table dm$category_set;
drop table dm$category_matrix_entry;
drop table dm$prior_probability_entry;
drop table dm$lift_result_entry;
drop table dm$model_property;
drop table dm$model_property_array;
drop table dm$setting;
drop table dm$setting_array;
drop table dm$settings_map;

ALTER SESSION SET CURRENT_SCHEMA = "SYS";
execute sys.dbms_registry.downgraded('ODM','9.2.0.5');

Rem  remove 10i DMSYS schema
drop user DMSYS cascade;
