set echo off
Rem
Rem $Header: utlsxszd.sql 19-dec-2003.10:51:04 mlfeng Exp $
Rem
Rem utlsxszd.sql
Rem
Rem Copyright (c) 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      utlsxszd.sql - Utility script for SYSAUX Size (Default Configuration)
Rem
Rem    DESCRIPTION
Rem      This script will estimate the amount of space required for the 
Rem      SYSAUX tablespace.  We will estimate based on the number
Rem      of active sessions, files, tables, indexes, etc.  Running
Rem      this script will pick all the default values.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfeng      12/19/03 - mlfeng_space_estimate 
Rem    mlfeng      12/15/03 - 
Rem    mlfeng      12/15/03 - Created
Rem

/* define all the default values to NULL */
define active_sessions = '';
define interval = '';
define retention = '';
define num_instances = '';

define number_of_tables = '';
define number_of_partitions = '';
define dml_activity = '';
define stats_retention = '';

@@utlsyxsz

-- End of File
