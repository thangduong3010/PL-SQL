Rem Copyright (c) 2002, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      dbmsupgnv.sql - DBMS UPGrade NatiVe
Rem
Rem    DESCRIPTION
Rem      This script provides a compact way to convert all PL/SQL in the
Rem      database to use native compilation (NCOMP).
Rem
Rem      By default, this script will not recompile package and type specs
Rem      since package generally do not have substantial amounts of code 
Rem      that benefit from native compilation while type specs do not 
Rem      allow for initialization code.
Rem
Rem    USAGE
Rem      To use this script, execute the following sequence of actions:
Rem      1. Shut down the database and restart in UPGRADE mode
Rem         (using STARTUP UPGRADE or ALTER DATABASE OPEN UPGRADE)
Rem      2. Run this script: @dbmsupgnv TRUE. If compilation of
Rem         package specs is desired, invoke @dbmsupgnv FALSE
Rem      3. Shut down the database and restart in normal mode
Rem      4. Run utlrp.sql to recompile invalid objects. 
Rem
Rem    NOTES
Rem    * This script creates a significant change to the database so
Rem      users should not be logged on when this script is run.
Rem    * This script expects the following files to be available in the
Rem      current directory:
Rem      standard.sql
Rem      dbmsstdx.sql
Rem    * There should be no other DDL on the database while running the
Rem      script.  Not following this recommendation may lead to deadlocks.
Rem    * This script does not automatically recompile invalid objects.
Rem    * This script does not invalidate type specs.
Rem    * This script prepares the database for native recompilation.
Rem      To prepare the database for interpreted recompilation, see
Rem      dbmsupgin.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    traney      09/02/08 - removing redundant drop pkg
Rem    gviswana    03/09/06 - Add utlrdt 
Rem    lvbcheng    06/24/05 - message defining default value for setup call
Rem    jmuller     11/18/04 - Fix bug 3958988: protect against failed 
Rem                           compilation of dbmsncdb 
Rem    lvbcheng    04/14/05 - Add package spec parameterization 
Rem    gviswana    12/09/03 - 3302294: UPGRADE mode 
Rem    gviswana    08/11/03 - Use utlirp.sql 
Rem    rpang       04/23/03 - Use plsql_code_type flag
Rem    lvbcheng    07/18/02 - lvbcheng_bug-2188517
Rem    lvbcheng    04/11/02 - Change to setup call
Rem    lvbcheng    04/01/02 - Restricted session
Rem    lvbcheng    03/13/02 - restrict further logins
Rem    lvbcheng    03/08/02 - Add system change
Rem    lvbcheng    02/08/02 - Created
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

   If you encounter this error, execute "SHUTDOWN", "STARTUP UPGRADE" and
   re-execute dbmsupgnv.sql
#######################################################################
#######################################################################
#
SELECT TO_NUMBER('MUST_BE_OPEN_UPGRADE') FROM v$instance
WHERE status != 'OPEN MIGRATE';

Rem We set plsql_code_type so that from here on out,
Rem everything gets recompiled native including standard.
alter session set plsql_code_type = NATIVE;

drop package body sys.dbmsncdb;
drop package sys.dbmsncdb;

WHENEVER SQLERROR EXIT;

DOC

#######################################################################
#######################################################################
  Failure when loading the DBMSNCDB package would indicate an 
  environment issue. Please fix the problem and rerun this script.
#######################################################################
#######################################################################
#

Rem Load the native comp package.  
Rem Ensure short-circuit compilation doesn't come into play.
@@dbmsncdb
@@prvtncdb.plb

WHENEVER SQLERROR EXIT;
Rem Ensure the package was created cleanly
select to_number('MUST BE VALID') from dba_objects
where owner = 'SYS' and object_name = 'DBMSNCDB' 
and OBJECT_TYPE IN ('PACKAGE', 'PACKAGE BODY') 
and status != 'VALID'; 

select to_number('MUST BE NATIVE') from dba_stored_settings
where owner = 'SYS' and object_name = 'DBMSNCDB' 
and param_name = 'plsql_code_type' and param_value != 'NATIVE'; 

DOC

#######################################################################
#######################################################################
  Call dbmsncdb.setup_for_native_compile(TRUE) for bodyOnly setup.
  Call dbmsncdb.setup_for_native_compile(FALSE) to set up package specs
  as well.
#######################################################################
#######################################################################
#

Rem Set all functions, procedures, package bodies, triggers and 
Rem type bodies to be compiled native.
prompt "Enter TRUE to obtain default behavior."
prompt "See this file for documentation."
begin
    dbmsncdb.setup_for_native_compile(&1);
end;
/

ALTER SYSTEM FLUSH SHARED_POOL;

@@utlrdt

DOC
#######################################################################
#######################################################################
   dbmsupgnv.sql completed successfully. All PL/SQL procedures, 
   functions, type bodies, triggers, and type bodies objects in the 
   database have been invalidated and their settings set to native.

   Shut down and restart the database in normal mode and 
   run utlrp.sql to recompile invalid objects.
#######################################################################
#######################################################################
#

