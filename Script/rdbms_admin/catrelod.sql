Rem
Rem $Header: rdbms/admin/catrelod.sql /st_rdbms_11.2.0/4 2012/03/21 14:55:04 bmccarth Exp $
Rem
Rem catrelod.sql
Rem
Rem Copyright (c) 2001, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catrelod.sql - Script to apply CATalog RELOaD scripts to a database
Rem
Rem    DESCRIPTION
Rem      This script encapsulates the "post downgrade" steps necessary
Rem      to reload the PL/SQL and Java packages, types, and classes.
Rem      It runs the "old" versions of catalog.sql and catproc.sql
Rem      and calls the component reload scripts.
Rem
Rem    NOTES
Rem      Use SQLPLUS and connect AS SYSDBA to run this script.
Rem      The database must be open for MIGRATE
Rem      
Rem    MODIFIED   (MM/DD/YY)
Rem    bmccarth    03/06/12 - 11.2.0.4
Rem    cdilling    02/24/11 - add support for 11.2.0.3
Rem    skabraha    07/29/10 - Backport skabraha_bug-9928461 from main
Rem    cmlim       07/27/10 - Backport cmlim_bug-9803834 from main
Rem    cmlim       04/26/10 - bug 9546509: suggest to force a checkpoint prior
Rem                           to shutdown abort
Rem    cdilling    05/21/09 - check for 8 digits for prv_version
Rem    jciminsk    10/22/07 - Upgrade support for 11.2
Rem    jciminsk    10/10/07 - fix typo
Rem    cdilling    10/09/07 - update version to 11.2.0.0.0
Rem    cdilling    12/07/06 - add DV support
Rem    rburns      04/15/06 - remove ODM 
Rem    rburns      01/10/06 - release 11.1.0 
Rem    rburns      10/28/05 - no utlip for patch downgrade 
Rem    rburns      02/27/05 - record action for history 
Rem    rburns      01/18/05 - comment out htmldb for 10.2 
Rem    rburns      11/11/04 - move CONTEXT 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      10/11/04 - add RUL 
Rem    rburns      04/16/04 - change version to 10.2 
Rem    rburns      02/23/04 - add EM 
Rem    rburns      04/25/03 - use timestamp
Rem    rburns      04/08/03 - use function for script names
Rem    rburns      01/18/03 - use 10.1 release, add EXF, reorder OLAP
Rem    rburns      01/16/03 - fix @@ and use server registry
Rem    dvoss       01/14/03 - add utllmup.sql
Rem    srtata      10/16/02 - add olsrelod.sql
Rem    rburns      08/27/02 - Add Ultra Search, remove ORDVIR
Rem    rburns      06/12/02 - remove pl/sql usage
Rem    rburns      04/16/02 - rburns_catpatch_920
Rem    rburns      04/03/02 - Created
Rem

Rem *************************************************************************
Rem BEGIN catrelod.sql
Rem *************************************************************************

SELECT 'COMP_TIMESTAMP RELOD__BGN ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

Rem =======================================================================
Rem Verify server version and MIGRATE status (PL/SQL not available yet)
Rem =======================================================================

WHENEVER SQLERROR EXIT;

DOC
#######################################################################
#######################################################################
  The following statement will cause an "ORA-01722: invalid number"
  error if the database server version is not 11.2.0.
  Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT", and use a
  different script or a different server.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_BE_11_2') FROM v$instance
WHERE substr(version,1,6) != '11.2.0';

DOC
#######################################################################
#######################################################################
  The following statement will cause an "ORA-01722: invalid number"
  error if the database has not been opened for MIGRATE.  

  Perform 'ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT", and 
  restart using MIGRATE.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER(status) FROM v$instance
WHERE status != 'OPEN MIGRATE';

DOC
#######################################################################
#######################################################################
  The following query will cause:
  - An "ORA-01722: invalid number"
    if the old Oracle release is expecting a time zone file version
    that does not exist.
    Note that 11.2.0.3 ships with time zone file version 14.

  o Action:
    Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT", and
    patch old ORACLE_HOME to the same time zone file version as used
    in the new ORACLE_HOME.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_BE_SAME_TIMEZONE_FILE_VERSION')
  FROM sys.props$
  WHERE
    (
      (name = 'DST_PRIMARY_TT_VERSION' AND TO_NUMBER(value$) > 14)
      AND
      (0 = (select count(*) from v$timezone_file))
    );

Rem =======================================================================
Rem SET nls_length_semantics at session level (bug 1488174)
Rem =======================================================================

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

Rem =======================================================================
Rem Set event to avoid unnecessary re-compilations
Rem =======================================================================

ALTER SESSION SET EVENTS '10520 TRACE NAME CONTEXT FOREVER, LEVEL 10'; 

Rem =======================================================================
Rem Invalidate all PL/SQL packages and types for major release downgrade
Rem =======================================================================

Rem If CATPROC status is not DOWNGRADED, don't run utlip.sql to invalidate
DEFINE utlip_file = nothing.sql
COLUMN utlip_name NEW_VALUE utlip_file NOPRINT;
SELECT 'utlip.sql' AS utlip_name FROM sys.registry$
       WHERE cid = 'CATPROC' AND namespace = 'SERVER' AND status = 7;   
@@&utlip_file

Rem =======================================================================
Rem Confirm that the previous release was a 11.2.0.4 release
Rem =======================================================================

DECLARE
  p_version sys.registry$.prv_version%type;
BEGIN
  SELECT prv_version INTO p_version 
  FROM registry$ WHERE cid = 'CATPROC' AND namespace = 'SERVER';
  IF p_version IS NOT NULL AND SUBSTR(p_version,1,8) != '11.2.0.4' THEN
     RAISE_APPLICATION_ERROR (-20000,
        'Upgrade from version ' || p_version || 
        ' cannot be downgraded to version 11.2.0.4');
  END IF;
END;
/


WHENEVER SQLERROR CONTINUE;

Rem =======================================================================
Rem Run catalog.sql and catproc.sql
Rem =======================================================================

Rem Remove any existing rows that would fire on DROP USER statements
delete from duc$;

@@catalog.sql
@@catproc.sql 
SELECT dbms_registry_sys.time_stamp('CATPROC') AS timestamp FROM DUAL;

Rem =======================================================================
Rem Reset all old version types to valid
Rem =======================================================================

Rem Compilation of standard might end up invalidating all object types,
Rem including older versions. This will cause problems if we have data
Rem depending on these versions, as they cannot be revalidated. Older
Rem versions are only used for data conversion, so we only need the 
Rem information in type dictionary tables which are unaffected by
Rem changes to standard. Reset obj$ status of these versions to valid
Rem so we can get to the type dictionary metadata.
Rem We need to make this a trusted C callout so that we can bypass the
Rem security check. Otherwise we run intp 1031 when DV is already linked in.

CREATE OR REPLACE LIBRARY UPGRADE_LIB TRUSTED AS STATIC
/
CREATE OR REPLACE PROCEDURE validate_old_typeversions IS
LANGUAGE C
NAME "VALIDATE_OLD_VERSIONS"
LIBRARY UPGRADE_LIB;
/
execute validate_old_typeversions();
commit;
alter system flush shared_pool;
drop procedure validate_old_typeversions;

Rem *************************************************************************
Rem START Component Reloads 
Rem *************************************************************************

Rem Setup component script filename variable
COLUMN relod_name NEW_VALUE relod_file NOPRINT;

Rem JServer
SELECT dbms_registry_sys.relod_script('JAVAVM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;

Rem XDK for Java
SELECT dbms_registry_sys.relod_script('XML') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

Rem Java Supplied Packages
SELECT dbms_registry_sys.relod_script('CATJAVA') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;

Rem Text
SELECT dbms_registry_sys.relod_script('CONTEXT') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem Oracle XML Database
SELECT dbms_registry_sys.relod_script('XDB') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

Rem Real Application Clusters
SELECT dbms_registry_sys.relod_script('RAC') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;

Rem Oracle Workspace Manager
SELECT dbms_registry_sys.relod_script('OWM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem Messaging Gateway
SELECT dbms_registry_sys.relod_script('MGW') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem OLAP Analytic Workspace
SELECT dbms_registry_sys.relod_script('APS') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem OLAP Catalog 
SELECT dbms_registry_sys.relod_script('AMD') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('AMD') AS timestamp FROM DUAL;

Rem OLAP API
SELECT dbms_registry_sys.relod_script('XOQ') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;

Rem Intermedia
SELECT dbms_registry_sys.relod_script('ORDIM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem Spatial
SELECT dbms_registry_sys.relod_script('SDO') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem Ultrasearch
SELECT dbms_registry_sys.relod_script('WK') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;

Rem Oracle Label Security
SELECT dbms_registry_sys.relod_script('OLS') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem Expression Filter
SELECT dbms_registry_sys.relod_script('EXF') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem Enterprise Manager Repository
SELECT dbms_registry_sys.relod_script('EM') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('EM') AS timestamp FROM DUAL;

Rem Rule Manager
SELECT dbms_registry_sys.relod_script('RUL') AS relod_name FROM DUAL;
@&relod_file     
SELECT dbms_registry_sys.time_stamp('RUL') AS timestamp FROM DUAL;

Rem Database Vault 
SELECT dbms_registry_sys.relod_script('DV') AS relod_name FROM DUAL;
@&relod_file
SELECT dbms_registry_sys.time_stamp('DV') AS timestamp FROM DUAL;

Rem Application Express
SELECT dbms_registry_sys.relod_script('APEX') AS relod_name FROM DUAL;
@&relod_file     
SELECT dbms_registry_sys.time_stamp('APEX') AS timestamp FROM DUAL;

set serveroutput off

Rem **********************************************************************
Rem END Component Reloads 
Rem **********************************************************************

Rem =======================================================================
Rem Update Logminer Metadata in Redo Stream
Rem =======================================================================
@@utllmup.sql

Rem =====================================================================
Rem Record Reload Completion
Rem =====================================================================

BEGIN  
   dbms_registry_sys.record_action('RELOAD',NULL,
             'Reloaded after downgrade from ' || 
              dbms_registry.prev_version('CATPROC'));
END;
/

SELECT dbms_registry_sys.time_stamp('relod_end') AS timestamp FROM DUAL;

Rem =======================================================================
Rem Display new versions and status
Rem =======================================================================

column comp_name format a35
SELECT comp_name, status, substr(version,1,10) as version 
from dba_server_registry order by modified;

DOC
#######################################################################
#######################################################################

   The above query lists the SERVER components now loaded in the
   database, along with their current version and status. 

   Please review the status and version columns and look for
   any errors in the spool log file.  If there are errors in the spool
   file, or any components are not VALID or not the correct 10.1.0
   patch version, consult the downgrade chapter of the current release
   Database Upgrade book.

   Next shutdown immediate, restart for normal operation, and then
   run utlrp.sql to recompile any invalid application objects.

#######################################################################
#######################################################################
#  

Rem *******************************************************************
Rem END catrelod.sql 
Rem *******************************************************************
