Rem
Rem $Header: catawrtv.sql 09-nov-2006.11:08:45 ilistvin Exp $
Rem
Rem catawrtv.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catawrtv.sql - Catalog script for Automatic Workload Repository
Rem                   (AWR) Tables and Views
Rem
Rem    DESCRIPTION
Rem      Creates tables, views
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem      The newly created tables should be TRUNCATE in the downgrade script.
Rem      Any new views and their synonyms should be dropped in the downgrade
Rem      script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ilistvin    06/11/22 - Created
Rem

Rem The following script will create the WR tables
@@catawrtb

Rem The following script will create the DBA_HIST views for the 
Rem Workload Repository, except those that depend on packages
@@catawrvw

