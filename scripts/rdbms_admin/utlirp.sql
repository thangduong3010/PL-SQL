Rem Copyright (c) 1998, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem   NAME
Rem     utlirp.sql - UTiLity script to Invalidate Pl/sql modules
Rem
Rem   DESCRIPTION
Rem     This script can be used to invalidate and all pl/sql modules
Rem     (procedures, functions, packages, types, triggers, views)
Rem     in a database.
Rem
Rem     This script must be run when it is necessary to regenerate the
Rem     compiled code because the PL/SQL code format is inconsistent with
Rem     the Oracle executable (e.g., when migrating a 32 bit database to
Rem      a 64 bit database or vice-versa).
Rem
Rem     Please note that this script does not recompile invalid objects
Rem     automatically. You must restart the database and explicitly invoke
Rem     utlrp.sql to recompile invalid objects.
Rem
Rem   USAGE
Rem     To use this script, execute the following sequence of actions:
Rem     1. Shut down the database and restart in UPGRADE mode
Rem        (using STARTUP UPGRADE or ALTER DATABASE OPEN UPGRADE)
Rem     2. Run this script
Rem     3. Shut down the database and restart in normal mode
Rem     4. Run utlrp.sql to recompile invalid objects. This script does
Rem        not automatically recompile invalid objects.
Rem
Rem   NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * This script expects the following files to be available in the
Rem        current directory:
Rem          standard.sql
Rem          dbmsstdx.sql
Rem      * There should be no other DDL on the database while running the
Rem        script.  Not following this recommendation may lead to deadlocks.
Rem
Rem   MODIFIED   (MM/DD/YY)
Rem    anighosh    02/26/09 - #(8264899): No need to record object number of
Rem                           function based indexes
Rem    gviswana    03/02/06 - Validate DDL triggers 
Rem    gviswana    12/08/03 - 33002294: Use UPGRADE mode
Rem    gviswana    08/08/03 - Re-enable functional indexes 
Rem    gviswana    04/16/03 - Move system parameter handling to utlirp.sql
Rem    rdecker     01/17/02 - Remove comment re: alter library compile support
Rem    jdavison    04/11/00 - Modify usage notes for 8.2 changes.
Rem    ncramesh    08/04/98 - change for sqlplus
Rem    usundara    06/03/98 - merge from 8.0.5:
Rem                           * change name utlrpls.sql --> utlirp.sql;
Rem                           * split out utlip.sql and utlrp.sql and call them
Rem    kmuthukk    04/07/98 - merge from 8.0.5
Rem    kmuthukk    03/09/98 - script to recompile pl/sql modules
Rem    kmuthukk    03/09/98 - Created
Rem
Rem    === (old history; merged from cat8004s.sql) ===
Rem     MODIFIED   (MM/DD/YY)
Rem     gviswana    02/25/98 - 632376: Do not remove idl_ rows for libraries
Rem     kmuthukk    02/05/98 - bug621356 (truncate idl tables)
Rem     kmuthukk    01/09/98 - merge from kmuthukk_plsql_32_64_upgrade
Rem     mramache    12/30/97 - code to revalidate PL/SQL objs.
Rem     kmuthukk    12/30/97 - migration script from 8.0.4 to 8.0.4S
Rem     kmuthukk    12/30/97 - Created
Rem    === (end of old history) ===
Rem

SET ECHO ON;

WHENEVER SQLERROR EXIT;

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if there the database was not opened in UPGRADE mode

   If you encounter this error, execute "SHUTDOWN", "STARTUP UPGRADE" and
   re-execute utlirp.sql
#######################################################################
#######################################################################
#
SELECT TO_NUMBER('MUST_BE_OPEN_UPGRADE') FROM v$instance
WHERE status != 'OPEN MIGRATE';

Rem #(8264899): The former code here to store object numbers of all valid
Rem PL/SQL-based functional indexes, is no longer needed.

Rem invalidate all pl/sql modules and recompile standard and dbms_standard
@@utlip

Rem Recompile all DDL triggers
@@utlrdt

DOC
#######################################################################
#######################################################################
   utlirp.sql completed successfully. All PL/SQL objects in the 
   database have been invalidated.

   Shut down and restart the database in normal mode and run utlrp.sql to
   recompile invalid objects.
#######################################################################
#######################################################################
#
