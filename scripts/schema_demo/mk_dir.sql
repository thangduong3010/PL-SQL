Rem
Rem $Header: mk_dir.sql.sbs 15-aug-2006.07:55:56 dkapoor Exp $
Rem
Rem mk_dir.sql
Rem
Rem Copyright (c) 2001, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      mk_dir.sql - Overwrites seed database directory objects
Rem
Rem    DESCRIPTION
Rem      The location of the Sample Schema directories are specific to
Rem      your Oracle installation. This script connects the directory
Rem      objects inside your demo database with the appropriate paths
Rem      in your file system.
Rem
Rem    NOTES
Rem      Run this script as SYS - directories are owned by SYS
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dkapoor     08/15/06 - call recreation of path for OCM dir object
Rem    tbgraves    05/21/04 - data_pump_dir added 
Rem    hyeh        08/29/02 - hyeh_mv_comschema_to_rdbms
Rem    ahunold     04/30/02 - no grants to public
Rem    ahunold     04/18/02 - create as SYS
Rem    ahunold     04/03/02 - bug 2290347
Rem    ahunold     08/28/01 - Merged ahunold_mk_dir
Rem    ahunold     08/28/01 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CREATE OR REPLACE DIRECTORY data_file_dir AS '/u01/app/oracle/product/11.2.0/dbhome_1/demo/schema/sales_history/'; 
CREATE OR REPLACE DIRECTORY log_file_dir  AS '/u01/app/oracle/product/11.2.0/dbhome_1/demo/schema/log/'; 
CREATE OR REPLACE DIRECTORY media_dir     AS '/u01/app/oracle/product/11.2.0/dbhome_1/demo/schema/product_media/';

GRANT READ ON DIRECTORY media_dir      TO pm;
GRANT READ ON DIRECTORY log_file_dir   TO sh;
GRANT READ ON DIRECTORY data_file_dir  TO sh;  
GRANT WRITE ON DIRECTORY log_file_dir  TO sh;
EXECUTE DBMS_DATAPUMP_UTL.REPLACE_DEFAULT_DIR;
EXECUTE ORACLE_OCM.MGMT_CONFIG_UTL.create_replace_dir_obj;
