Rem
Rem $Header: sbdusr.sql 07-jun-2007.21:38:09 shsong Exp $
Rem
Rem sbdusr.sql
Rem
Rem Copyright (c) 2007, Oracle.  All rights reserved.  
Rem
Rem    NAME
Rem      sbdusr.sql - StandBy statspack Drop USeR
Rem
Rem    DESCRIPTION
Rem      SQL*Plus command file to DROP user which contains the
Rem      standby statspack database objects.
Rem
Rem    NOTES
Rem      Must be run when connected to SYS (or internal)      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      04/23/07 - Created
Rem

set echo off;

spool sbdusr.lis

Rem
Rem  Drop STDBYPERF user cascade
Rem

drop user stdbyperf cascade;

prompt
prompt NOTE:
prompt   SBDUSR complete. Please check sbdusr.lis for any errors.
prompt

spool off;
set echo on;


