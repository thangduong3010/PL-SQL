Rem
Rem dbmsodm.sql
Rem
Rem Copyright (c) 1998, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsodm.sql - DBMS Data Mining Definitions
Rem
Rem    DESCRIPTION
Rem      This script compiles PL/SQL header files for Data Mining
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY) 
Rem    xbarr       03/14/06 - Update dbmsdmxf  
Rem    mmcracke    03/10/06 - Creation 
Rem

Rem set feedback off
Rem set echo off

Rem DBMS_DATA_MINING_TRANSFORM
@@dbmsdmxf.sql

Rem DBMS Data Mining
@@dbmsdm.sql

Rem Load Trusted Code BLAST
@@dbmsdmbl.sql

Rem Load ODM Predictive package
@@dbmsdmpa.sql

SHOW ERRORS
