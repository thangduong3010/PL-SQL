Rem
Rem $Header: catwrr.sql 25-may-2006.15:15:26 kdias Exp $
Rem
Rem catwrr.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catwrr.sql - Catalog script for Workload Capture
Rem                   and Replay
Rem
Rem    DESCRIPTION
Rem      Creates tables, views, package for Workload Capture
Rem      and Replay
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       02/01/06 - Created
Rem

Rem 
Rem Create all the dictionary tables
@@catwrrtb.sql

Rem
Rem Create all the dictionary views
@@catwrrvw.sql

Rem
Rem Create the DBA_WORKLOAD_ package definitions
@@dbmswrr.sql

Rem
Rem Create the DBA_WORKLOAD_ package bodys
@@prvtwrr.plb

