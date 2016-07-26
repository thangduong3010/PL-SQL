Rem
Rem $Header: catwrrtb.sql 25-may-2006.15:15:27 kdias Exp $
Rem
Rem catwrrtb.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catwrrtb.sql - Catalog script for 
Rem                     the Workload Capture and Replay tables
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary tables for the 
Rem      Workload Capture and Replay infra-structure.
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem      Almost all DML on the tables defined in 
Rem      this script comes from DBMS_WORKLOAD_CAPTURE.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kdias       05/25/06 - rename record to capture 
Rem    veeve       04/11/06 - add REPLAY dict
Rem    veeve       01/25/06 - Created
Rem

Rem
Rem Create the common (shared by Capture and Replay) schema 
Rem and the Capture infrastructure tables 
@@catwrrtbc.sql

Rem
Rem Create the Replay infrastructure tables 
@@catwrrtbp.sql
