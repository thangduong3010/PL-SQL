Rem
Rem $Header: rdbms/admin/catupgrd.sql /st_rdbms_11.2.0/3 2011/05/18 15:07:25 cmlim Exp $
Rem
Rem catupgrd.sql
Rem
Rem Copyright (c) 1999, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catupgrd.sql - CATalog UPGraDe to the new release
Rem
Rem    DESCRIPTION
Rem     This script is to be used for upgrading a 9.2, 10.1 or 10.2 
Rem     database to the new release.  This script provides a direct 
Rem     upgrade path from these releases to the new Oracle release.
Rem
Rem      The upgrade is partitioned into the following 5 stages:
Rem        STAGE 1: call the "i" script for the oldest supported release:
Rem                 This loads all tables that are necessary
Rem                 to perform basic DDL commands for the new release
Rem        STAGE 2: call utlip.sql to invalidate PL/SQL objects
Rem        STAGE 3: Determine the original release and call the 
Rem                 c0x0x0x0.sql for the release.  This performs all 
Rem                 necessary dictionary upgrade actions to bring the 
Rem                 database from the original release to new release.
Rem
Rem    NOTES
Rem
Rem      * This script needs to be run in the new release environment
Rem        (after installing the release to which you want to upgrade).
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skabraha    05/16/11 - Backport skabraha_bug-11823179 from main
Rem    cmlim       05/12/11 - Backport cmlim_bug-12337546 from main
Rem    skabraha    07/29/10 - Backport skabraha_bug-9928461 from main
Rem    cdilling    03/29/07 - set error logging off - bug 5959958
Rem    rburns      12/11/06 - eliminate first phase
Rem    rburns      07/19/06 - fix log miner location 
Rem    rburns      05/22/06 - restructure for parallel upgrade 
Rem    rburns      02/15/06 - re-run message with expected errors
Rem    gviswana    03/09/06 - Add utlrdt 
Rem    rburns      02/10/06 - fix re-run logic for 11.1 
Rem    rburns      01/10/06 - release 11.1.0 
Rem    rburns      11/09/05 - version fixes
Rem    rburns      10/21/05 - remove 817 and 901 upgrades 
Rem    cdilling    09/28/05 - temporary version until db version updated
Rem    ssubrama    08/17/05 - bug 4523571 add note before utlip 
Rem    sagrawal    06/28/05 - invalidate PL/SQL objects for upgrade to 11 
Rem    rburns      03/14/05 - dbms_registry_sys timestamp 
Rem    rburns      02/27/05 - record action for history 
Rem    rburns      10/18/04 - remove catpatch.sql 
Rem    rburns      09/02/04 - remove dbms_output compile 
Rem    rburns      06/17/04 - use registry log and utlusts 
Rem    mvemulap    05/26/04 - grid mcode compatibility 
Rem    jstamos     05/20/04 - utlip workaround 
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      01/27/04 - Created
Rem

DOC
#######################################################################
#######################################################################

   The first time this script is run, there should be no error messages
   generated; all normal upgrade error messages are suppressed.

   If this script is being re-run after correcting some problem, then 
   expect the following error which is not automatically suppressed:

   ORA-00001: unique constraint (<constraint_name>) violated
              possibly in conjunction with
   ORA-06512: at "<procedure/function name>", line NN

   These errors will automatically be suppressed by the Database Upgrade
   Assistant (DBUA) when it re-runs an upgrade.

#######################################################################
#######################################################################
#

Rem Initial checks and RDBMS upgrade scripts
@@catupstr.sql

Rem catalog and catproc run with some multiprocess phases
@@catalog.sql --CATFILE -X
@@catproc.sql --CATFILE -X

--CATCTL -S
Rem Final RDBMS upgrade scripts
@@catupprc.sql

Rem Upgrade components with some multiprocess phases
@@cmpupgrd.sql --CATFILE -X

--CATCTL -S
Rem Final upgrade scripts
@@catupend.sql

Rem Set errorlogging off
SET ERRORLOGGING OFF;

REM END OF CATUPGRD.SQL

REM bug 12337546 - Exit current sqlplus session at end of catupgrd.sql.
REM                This forces user to start a new sqlplus session in order
REM                to connect to the upgraded db.
exit

Rem *********************************************************************
Rem END catupgrd.sql
Rem *********************************************************************
