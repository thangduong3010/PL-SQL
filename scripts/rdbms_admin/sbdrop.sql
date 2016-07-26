Rem
Rem $Header: sbdrop.sql 07-jun-2007.21:45:37 shsong Exp $
Rem
Rem sbdrop.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sbdrop.sql - StandBy statspack DROP user and tables
Rem
Rem    DESCRIPTION
Rem      SQL*PLUS command file drop user and tables for readable standby
Rem      performance diagnostic tool STANDBY STATSPACK
Rem
Rem    NOTES
Rem      Note the script connects INTERNAL and so must be run from
Rem      an account which is able to connect internal.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      04/24/07 - Created
Rem

--
--  Drop Standby Statspack's tables and indexes

@@sbdtab


--
--  Drop STDBYPERF user

@@sbdusr

