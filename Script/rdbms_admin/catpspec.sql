Rem
Rem $Header: rdbms/admin/catpspec.sql /st_rdbms_11.2.0/4 2013/06/22 10:12:01 davili Exp $
Rem
Rem catpspec.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catpspec.sql - CATPROC Package Specs
Rem
Rem    DESCRIPTION
Rem      Single-threaded script to create package specifications that are 
Rem      referenced in other package specs (in catpdbms.sql)
Rem
Rem    NOTES
Rem       
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    davili      06/19/13 - Move the packages to support emll
Rem    arbalakr    02/01/13 - Add prvs_awr_data.plb
Rem    elu         02/28/13 - add dbmsobj.sql
Rem    skabraha    01/12/12 - move utlrcmp here
Rem    ilistvin    11/15/06 - create specs for packages used by other pakage
Rem                           specs
Rem    ilistvin    11/15/06 - Created
Rem

Rem advisor framework
@@dbmsadv

Rem pl/sql packages used for rdbms functionality
@@catodci.sql

Rem Scheduler dependent views
Rem Scheduler packages - depend on ODCI
@@dbmssch.sql
@@catschv.sql
@@prvthsch.plb

@@utlrcmp

-- general objects utilities
@@dbmsobj.sql

Rem Compare Period type definitions
@@prvs_awr_data.plb
