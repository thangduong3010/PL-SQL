Rem
Rem $Header: catwrrtv.sql 25-may-2006.15:15:26 kdias Exp $
Rem
Rem catwrrtv.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catwrrtv.sql - Catalog script for Workload Capture
Rem                     and Replay
Rem
Rem    DESCRIPTION
Rem      Creates Workload Capture and Replays tables and views.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    veeve       06/14/06 - Created
Rem

Rem 
Rem Create all the dictionary tables
@@catwrrtb.sql

Rem
Rem Create all the dictionary views
@@catwrrvw.sql

