Rem Copyright (c) 2002, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      dbmsupgin.sql - DBMS UPGrade INterpreted
Rem
Rem    DESCRIPTION
Rem      This script provides a compact way to convert all PL/SQL in the
Rem      database to use interpreted mode.
Rem
Rem    USAGE
Rem      To use this script, execute the following sequence of actions:
Rem      1. Shut down the database and restart in UPGRADE mode
Rem         (using STARTUP UPGRADE or ALTER DATABASE OPEN UPGRADE)
Rem      2. Run this script
Rem      3. Shut down the database and restart in normal mode
Rem      4. Run utlrp.sql to recompile invalid objects. This script does
Rem         not automatically recompile invalid objects.
Rem
Rem    NOTES
Rem    * This script creates a significant change to the database so
Rem      users should not be logged on when this script is run.
Rem    * This script expects the following files to be available in the
Rem      current directory:
Rem      standard.sql
Rem      dbmsstdx.sql
Rem    * There should be no other DDL on the database while running the
Rem        script.  Not following this recommendation may lead 
Rem        to deadlocks.
Rem    * This script prepares the database for interpreted recompilation.
Rem      To prepare the database for native recompilation, see
Rem      dbmsupgnv.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    traney      09/02/08 - adding doc comment
Rem    gviswana    03/09/06 - Add utlrdt 
Rem    jmuller     11/19/04 - Fix bug 3958988: protect against failed 
Rem                           compilation of dbmsncdb 
Rem    lvbcheng    04/14/05 - Add package spec parameterization 
Rem    gviswana    12/09/03 - 3302294: UPGRADE mode 
Rem    rpang       04/23/03 - Use plsql_code_type flag
Rem    lvbcheng    07/18/02 - lvbcheng_bug-2188517
Rem    lvbcheng    04/11/02 - Change to setup call
Rem    lvbcheng    04/01/02 - Restricted session
Rem    lvbcheng    03/08/02 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

WHENEVER SQLERROR EXIT;

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if there the database was not opened in UPGRADE mode

   If you encounter this error, execute "SHUTDOWN", "STARTUP UPGRADE" 
   and re-execute dbmsupgin.sql
#######################################################################
#######################################################################
#
SELECT TO_NUMBER('MUST_BE_OPEN_UPGRADE') FROM v$instance
WHERE status != 'OPEN MIGRATE';

Rem We set plsql_code_type so that from here on out,
Rem everything gets recompiled interpreted including standard.
alter system set plsql_code_type = INTERPRETED;

Rem Load the native comp package
Rem Ensure short-circuit compilation doesn't come into play.
WHENEVER SQLERROR CONTINUE;
drop package body sys.dbmsncdb; 
drop package sys.dbmsncdb; 
WHENEVER SQLERROR EXIT;
@@dbmsncdb
@@prvtncdb.plb

WHENEVER SQLERROR EXIT;
Rem Ensure the package was created cleanly
select to_number('MUST BE VALID') from dba_objects 
where owner = 'SYS' and object_name = 'DBMSNCDB'
and OBJECT_TYPE IN ('PACKAGE', 'PACKAGE BODY') 
and status != 'VALID'; 

select to_number('MUST BE INTERPRETED') from dba_stored_settings
where owner = 'SYS' and object_name = 'DBMSNCDB' 
and param_name = 'plsql_code_type' and param_value != 'INTERPRETED'; 

Rem Set everything to be compiled interpreted.
begin
  dbmsncdb.setup_for_interpreted_compile;
end;
/
ALTER SYSTEM FLUSH SHARED_POOL;

@@utlrdt

DOC
#######################################################################
#######################################################################
   dbmsupgin.sql completed successfully. All PL/SQL procedures, 
   functions, type bodies, triggers, and type bodies objects in the 
   database have been invalidated and their settings set to interpreted.

   Shut down and restart the database in normal mode and 
   run utlrp.sql to recompile invalid objects.
#######################################################################
#######################################################################
#
