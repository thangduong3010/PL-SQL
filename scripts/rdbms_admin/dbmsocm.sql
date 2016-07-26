Rem
Rem $Header: emll/admin/scripts/dbmsocm.sql /main/2 2012/04/12 06:33:18 ameshram Exp $
Rem
Rem dbmsocm.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsocm.sql - Packages for MGMT_DB_LL_METRICS and MGMT_CONFIG
Rem
Rem    DESCRIPTION
Rem      These packages are use to create the database configuration
Rem      file for use by Oracle Configuration Manager (OCM).
Rem      MGMT_DB_LL_METRICS : Database configuration collection package
Rem      MGMT_CONFIG : The package for the job scheduling of the configuration
Rem                   collection.
Rem      Create User to the packages.
Rem    NOTES
Rem      This script should be run while connected as "SYS".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dkapoor     06/06/06 - move directory creation after installing the 
Rem                           packages 
Rem    dkapoor     05/23/06 - Created
Rem

Rem Create the user 
@@catocm.sql
Rem Grant table access to user
@@grntocmtabaccess.sql
Rem Define the packages
@@ocmdbd.sql
@@ocmjd10.sql
