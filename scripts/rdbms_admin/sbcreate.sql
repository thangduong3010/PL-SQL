Rem
Rem sbcreate.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      sbcreate.sql - StandBy statspack CREATion  
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file which creates the STANDBY STATSPACK user, 
Rem      tables and package for the performance diagnostic tool STANDBY 
Rem      STATSPACK
Rem
Rem    NOTES
Rem      Note the script connects INTERNAL and so must be run from
Rem      an account which is able to connect internal (SYS).
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      03/07/07 - Create stdbyperf user
Rem    wlohwass    12/04/06 - Created
Rem

--
--  Create user and required privileges
@@sbcusr

connect stdbyperf/&&stdbyuser_password

--
--  Build the tables
@@sbctab


--
--  Add a standby database instance to the configuration
@@sbaddins

