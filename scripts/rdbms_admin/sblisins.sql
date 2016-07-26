Rem
Rem sblisins.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      sblisins.sql - Standby Database List Instance 
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file which lists standby database instances
Rem      configured for performance data collection
Rem
Rem    NOTES
Rem      Must be run from standby statspack owner, stdbyperf
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      08/18/09 - add db_unique_name
Rem    shsong      03/04/06 - Created
Rem

--
--

set echo off verify off showmode off feedback off;
whenever sqlerror exit sql.sqlcode

prompt
prompt The following standby instances (TNS_NAME alias) have been configured 
prompt for data collection

col DATABASE  format a30
col INSTANCE  format a12
col "DB LINK" format a30
col PACKAGE   format a46

select db_unique_name "DATABASE"
     , inst_name "INSTANCE" 
     , db_link "DB LINK"
     , package_name "PACKAGE"
  from stats$standby_config;

prompt
prompt === END OF LIST ===
prompt

