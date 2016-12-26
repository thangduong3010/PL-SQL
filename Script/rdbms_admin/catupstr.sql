Rem
Rem $Header: rdbms/admin/catupstr.sql /st_rdbms_11.2.0/5 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem catupstr.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catupstr.sql - CATalog UPgrade STaRt script
Rem
Rem    DESCRIPTION
Rem      This script performs the initial checks for upgrade
Rem      (open for UPGRADE, AS SYSDBA, etc.) and then runs
Rem      the "i" scripts, utlip.sql, and the "c" scripts
Rem      to complete the basic RDBMS upgrade
Rem
Rem    NOTES
Rem      Invoked from catupgrd.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/29/13 - bug_16816410_11204: combine settings into same
Rem                           errorlogging stmt
Rem    cdilling    02/06/12 - check instance is 11.2.0.4
Rem    cmlim       05/21/11 - Backport cmlim_bug-12363704 from main
Rem    cdilling    02/14/11 - bug 10373381: check instance is 11.2.0.3
Rem    cmlim       01/19/11 - Backport cmlim_bug-10400001 from st_rdbms_11.2.0
Rem                         - Check that 112 oracle has DV off prior to upgrade
Rem    cmlim       06/21/10 - update_tzv14: 11202 is now at time zone file v14
Rem    cmlim       04/26/10 - bug 9546509; suggest to force a checkpoint prior
Rem                           to shutdown abort in instructions
Rem    cdilling    03/12/10 - abort upgrade if invalid conditions for editions
Rem                           - bug 9454506
Rem    cmlim       02/01/10 - 11202 is now at time zone file version 13
Rem    cmlim       11/11/09 - change the timezone check from 8 to 11
Rem    cdilling    06/01/09 - check for supported upgrade versions
Rem    cdilling    05/26/09 - for PSU check only 5 digits for version
Rem    cmlim       01/16/09 - bug 7496789: update check on when DV needs to be
Rem                           relinked off
Rem    cmlim       12/19/08 - timezone_b7193417-c: rewrite timezone check
Rem    cmlim       12/12/08 - timezone_b7193417-b: if old OH has newer timezone
Rem                           version than 8, abort if new OH is not patched
Rem    rlong       09/25/08 - 
Rem    cmlim       07/24/08 - bug 7193417: support timezone file version
Rem                           changes in 11.2
Rem    awitkows    03/30/08 - DST. repl registry with props
Rem    rburns      11/11/07 - XbranchMerge rburns_bug-6446262 from
Rem                           st_rdbms_project-18813
Rem    rburns      11/08/07 - check for INVALID old versions of types
Rem    jciminsk    10/22/07 - Upgrade support for 11.2
Rem    cdilling    10/09/07 - update version to 11.2
Rem    cdilling    08/23/07 - check disabled indexes only
Rem    rburns      07/16/07 - add 11.1 patch upgrade
Rem    rburns      05/29/07 - add timezone version check
Rem    rburns      05/01/07 - reload dbms_assert
Rem    rburns      03/10/07 - add DV and OLS check
Rem    cdilling    02/19/07 - add sys.enabled$indexes table for bug 5530085
Rem    dvoss       02/19/07 - Check bootstrap migration status
Rem    rburns      10/23/06 - add session script
Rem    rburns      08/14/06 - add RDBMS identifier
Rem    cdilling    06/08/06 - add error logging table
Rem    gviswana    06/07/06 - Enable 4523571 fix 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

Rem =====================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =====================================================================

WHENEVER SQLERROR EXIT;        

DOC 
######################################################################
######################################################################
    The following statement will cause an "ORA-01722: invalid number"
    error if the user running this script is not SYS.  Disconnect
    and reconnect with AS SYSDBA.
######################################################################
######################################################################
#

SELECT TO_NUMBER('MUST_BE_AS_SYSDBA') FROM DUAL
WHERE USER != 'SYS';

DOC
######################################################################
######################################################################
    The following statement will cause an "ORA-01722: invalid number"
    error if the database server version is not correct for this script.
    Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT", and use
    a different script or a different server.
######################################################################
######################################################################
#

SELECT TO_NUMBER('MUST_BE_11_2_0_4') FROM v$instance
WHERE substr(version,1,8) != '11.2.0.4';

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if the database has not been opened for UPGRADE.  

   Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT",  and 
   restart using UPGRADE.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_BE_OPEN_UPGRADE') FROM v$instance
WHERE status != 'OPEN MIGRATE';

DOC
#######################################################################
#######################################################################
     The following statement will cause an "ORA-01722: invalid number"
     error if the Oracle Database Vault option is TRUE.  Upgrades cannot
     be run with the Oracle Database Vault option set to TRUE since
     AS SYSDBA connections are restricted.

     Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT", relink
     the server without the Database Vault option, and restart the server
     using UPGRADE mode.


#######################################################################
#######################################################################
#

SELECT TO_NUMBER('DATA_VAULT_OPTION_ON') FROM v$option
 WHERE
  value = 'TRUE' and parameter = 'Oracle Database Vault';


DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if Database Vault is installed in the database but the Oracle 
   Label Security option is FALSE.  To successfully upgrade Oracle 
   Database Vault, the Oracle Label Security option must be TRUE.

   Perform "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT",
   relink the server with the OLS option (but without the Oracle Database
   Vault option) and restart the server using UPGRADE.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('LABEL_SECURITY_OPTION_OFF') FROM v$option 
WHERE value = 'FALSE' and parameter =
      (SELECT 'Oracle Label Security' FROM user$ where name = 'DVSYS');

DOC
#######################################################################
#######################################################################
   The following statement will cause an "ORA-01722: invalid number"
   error if bootstrap migration is in progress and logminer clients
   require utlmmig.sql to be run next to support this redo stream.

   Run utlmmig.sql
   then (if needed) 
   restart the database using UPGRADE and
   rerun the upgrade script.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_RUN_UTLMMIG.SQL')
    FROM SYS.V$DATABASE V
    WHERE V.LOG_MODE = 'ARCHIVELOG' and
          V.SUPPLEMENTAL_LOG_DATA_MIN != 'NO' and
          exists (select 1 from sys.props$
                  where name = 'LOGMNR_BOOTSTRAP_UPGRADE_ERROR');


DOC
#######################################################################
#######################################################################
   The following error is generated if the pre-upgrade tool has not been
   run in the old ORACLE_HOME home prior to upgrading a pre-11.2 database: 

   SELECT TO_NUMBER('MUST_HAVE_RUN_PRE-UPGRADE_TOOL_FOR_TIMEZONE')
                       *
      ERROR at line 1:
      ORA-01722: invalid number

     o Action:
       Shutdown database ("alter system checkpoint" and then "shutdown abort").
       Revert to the original oracle home and start the database.
       Run pre-upgrade tool against the database.
       Review and take appropriate actions based on the pre-upgrade
       output before opening the datatabase in the new software version.
    
#######################################################################
#######################################################################
#

Rem Assure CHAR semantics are not used in the dictionary
ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

Rem To keep the check simple and avoid multiple errors - in upgrade mode,
Rem create registry$database and add tz_version in case the table
Rem and/or column do not exist.
CREATE TABLE registry$database
               (platform_id NUMBER, platform_name VARCHAR2(101),
                edition VARCHAR2(30), tz_version NUMBER);
ALTER TABLE registry$database add (tz_version number);

Rem Check if tz_version was populated if the db is pre-11.2
SELECT TO_NUMBER('MUST_HAVE_RUN_PRE-UPGRADE_TOOL_FOR_TIMEZONE')
   FROM sys.props$
   WHERE
     (
       (
        (0 = (select count(*) from registry$database))
        OR
        ((SELECT tz_version from registry$database) is null)
       )
       AND
       (
        ((SELECT substr(version,1,4) FROM registry$ where cid = 'CATPROC') =
          '9.2.') OR
        ((SELECT substr(version,1,4) FROM registry$ where cid = 'CATPROC') =
          '10.1') OR
        ((SELECT substr(version,1,4) FROM registry$ where cid = 'CATPROC') =
          '10.2') OR
        ((SELECT substr(version,1,4) FROM registry$ where cid = 'CATPROC') =
          '11.1')
       )
     );


DOC
#######################################################################
#######################################################################
   The following error is generated if the pre-upgrade tool has not been
   run in the old oracle home prior to upgrading a pre-11.2 database:

      SELECT TO_NUMBER('MUST_BE_SAME_TIMEZONE_FILE_VERSION')
                       *
      ERROR at line 1:
      ORA-01722: invalid number


     o Action:
       Shutdown database ("alter system checkpoint" and then "shutdown abort").
       Revert to the original ORACLE_HOME and start the database.
       Run pre-upgrade tool against the database.
       Review and take appropriate actions based on the pre-upgrade
       output before opening the datatabase in the new software version.

#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_BE_SAME_TIMEZONE_FILE_VERSION')
   FROM sys.props$
   WHERE
     (
      ((SELECT TO_NUMBER(value$) from sys.props$
         WHERE name = 'DST_PRIMARY_TT_VERSION') !=
       (SELECT tz_version from registry$database))
      AND
      (((SELECT substr(version,1,4) FROM registry$ where cid = 'CATPROC') =
         '9.2.') OR
       ((SELECT substr(version,1,4) FROM registry$ where cid = 'CATPROC') =
         '10.1') OR
       ((SELECT substr(version,1,4) FROM registry$ where cid = 'CATPROC') =
         '10.2') OR
       ((SELECT substr(version,1,4) FROM registry$ where cid = 'CATPROC') =
         '11.1'))
     );


DOC
#######################################################################
#######################################################################
   The following error is generated if (1) the old release uses a time
   zone file version newer than the one shipped with the new oracle
   release and (2) the new oracle home has not been patched yet:

      SELECT TO_NUMBER('MUST_PATCH_TIMEZONE_FILE_VERSION_ON_NEW_ORACLE_HOME')
                       *
      ERROR at line 1:
      ORA-01722: invalid number

     o Action:
       Shutdown database ("alter system checkpoint" and then "shutdown abort").
       Patch new ORACLE_HOME to the same time zone file version as used
       in the old ORACLE_HOME.

#######################################################################
#######################################################################
#

SELECT TO_NUMBER('MUST_PATCH_TIMEZONE_FILE_VERSION_ON_NEW_ORACLE_HOME')
   FROM sys.props$
   WHERE
     (
      (name = 'DST_PRIMARY_TT_VERSION' AND TO_NUMBER(value$) > 14)
      AND
      (0 = (select count(*) from v$timezone_file))
     );


DOC 
#######################################################################
#######################################################################
    The following statements will cause an "ORA-01722: invalid number"
    error if the SYSAUX tablespace does not exist or is not
    ONLINE for READ WRITE, PERMANENT, EXTENT MANAGEMENT LOCAL, and
    SEGMENT SPACE MANAGEMENT AUTO.
 
    The SYSAUX tablespace is used in 10.1 to consolidate data from
    a number of tablespaces that were separate in prior releases. 
    Consult the Oracle Database Upgrade Guide for sizing estimates.

    Create the SYSAUX tablespace, for example,

     create tablespace SYSAUX datafile 'sysaux01.dbf' 
         size 70M reuse 
         extent management local 
         segment space management auto 
         online;

    Then rerun the catupgrd.sql script.
#######################################################################
#######################################################################
#

SELECT TO_NUMBER('No SYSAUX tablespace') FROM dual 
WHERE 'SYSAUX' NOT IN (SELECT name from ts$);

SELECT TO_NUMBER('Not ONLINE for READ/WRITE') from ts$
WHERE name='SYSAUX' AND online$ !=1;

SELECT TO_NUMBER ('Not PERMANENT') from ts$
WHERE name='SYSAUX' AND 
      (contents$ !=0 or (contents$ = 0 AND bitand(flags, 16)= 16));

SELECT TO_NUMBER ('Not LOCAL extent management') from ts$
WHERE name='SYSAUX' AND bitmapped = 0;

SELECT TO_NUMBER ('Not AUTO segment space management') from ts$
WHERE name='SYSAUX' AND bitand(flags,32) != 32;

Rem =====================================================================
Rem Assure CHAR semantics are not used in the dictionary
Rem =====================================================================

ALTER SESSION SET NLS_LENGTH_SEMANTICS=BYTE;

Rem =====================================================================
Rem Continue even if there are SQL errors in remainder of script
Rem =====================================================================

WHENEVER SQLERROR CONTINUE;  

Rem
Rem Bug 5530085
Rem
Rem Poplulate sys.enabled_indexes table with the list of function-based 
Rem indexes that are currently not 'disabled'. This schema/index name list 
Rem will be later used in utlrp.sql to enable indexes in the list that may 
Rem have become disabled. 
Rem
CREATE TABLE sys.enabled$indexes( schemaname, indexname, objnum )
AS select u.name, o1.name, i.obj# from user$ u, obj$ o1, obj$ o2, ind$ i
    where
        u.user# = o1.owner# and o1.type# = 1 and o1.obj# = i.obj#
       and bitand(i.property, 16)= 16 and bitand(i.flags, 1024)=0
       and i.bo# = o2.obj# and bitand(o2.flags, 2)=0;



Rem
Rem Create error logging table
Rem
CREATE TABLE sys.registry$error(username   VARCHAR(256),
                                timestamp  TIMESTAMP,
                                script     VARCHAR(1024),
                                identifier VARCHAR(256),
                                message    CLOB,
                                statement  CLOB);
                                         
DELETE FROM sys.registry$error;

set errorlogging on table sys.registry$error identifier 'RDBMS';

commit;


Rem
Rem Pre-create log to record upgrade operations and errors
Rem

CREATE TABLE registry$log (
             cid         VARCHAR2(30),              /* component identifier */
             namespace   VARCHAR2(30),               /* component namespace */
             operation   NUMBER NOT NULL,              /* current operation */
             optime      TIMESTAMP,                  /* operation timestamp */
             errmsg      varchar2(1000)         /* ORA error message number */
             );
Rem Clear log entries if the table already exists
DELETE FROM registry$log;

Rem put timestamps into spool log and registry$log
INSERT INTO registry$log (cid, namespace, operation, optime)
       VALUES ('UPGRD_BGN','SERVER',-1,SYSTIMESTAMP);
COMMIT;
SELECT 'COMP_TIMESTAMP UPGRD__BGN ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ')  || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

Rem Run Session initialization script
Rem error logging table must exist
@@catupses.sql

Rem =====================================================================
Rem BEGIN STAGE 1: load dictionary changes for basic SQL processing
Rem =====================================================================

Rem run all of the "i" scripts from the earliest supported release
@@i0902000

Rem =====================================================================
Rem END STAGE 1: load dictionary changes for basic SQL processing
Rem =====================================================================

Rem =====================================================================
Rem BEGIN STAGE 2: invalidate all non-Java objects
Rem =====================================================================
 
-- This block of code sets up to run utlip.sql only if the release is
-- prior to 11.1 or there has been a platform change. 

-- It uses the existence of a 11.1 table to determine the need for 
-- utlip.sql.  MODEL$ is created in the upgrade to 11.1;
-- if it exists, then utlip.sql is not needed unless there is
-- a platform change.

DEFINE utlip_file = 'utlip.sql';
DEFINE utlip_tabcol = NULL;

COLUMN utlip_name NEW_VALUE utlip_file NOPRINT;
COLUMN utlip_tabcolumn NEW_VALUE utlip_tabcol NOPRINT;

SELECT 'nothing.sql' AS utlip_name FROM obj$ 
       WHERE name = 'MODEL$' and owner#=0;

SELECT platform_id AS utlip_tabcolumn FROM v$database;

SELECT 'SELECT platform_id FROM registry$database' AS utlip_tabcolumn FROM 
obj$ WHERE name = 'REGISTRY$DATABASE';

-- Set utlip_name if the platform identifer in v$database 
-- does not match platform identifier in registry$database
SELECT 'utlip.sql' AS utlip_name FROM v$database
    WHERE v$database.platform_id  
      NOT IN (&&utlip_tabcol);      
@@&utlip_file

-- Bug 6446262, check forINVALID old versions of types and update 
-- any with status = 6
SELECT name, subname, owner#, status FROM obj$
       WHERE type#=13 AND subname IS NOT NULL AND status > 1;
UPDATE obj$ SET status=1 
       WHERE type#=13 AND subname IS NOT NULL AND status=6;
COMMIT;
ALTER SYSTEM FLUSH SHARED_POOL;

-- Reload dbms_assert package for changed interfaces (used in "c" scripts)
@@dbmsasrt.sql
@@prvtasrt.plb

Rem =====================================================================
Rem END STAGE 2: invalidate all non-Java objects
Rem =====================================================================

Rem =====================================================================
Rem BEGIN STAGE 3: dictionary upgrade
Rem =====================================================================

WHENEVER SQLERROR EXIT

DOC
#######################################################################
#######################################################################
     The following check_edition_exists procedure may result in this error:

       ERROR at line 1:
	ORA-20000: Editioning view exists for non-edition enabled schema
	ORA-06512: at "SYS.CHECK_EDITION_EXISTS", line 21
	ORA-06512: at line 2

     if there exists non-edition enabled schemas that have editioning
     views. One of the following corrective actions must be taken before 
     the upgrade will proceed.

	1. Drop these editioning views.
	2. Edition enable the schemas using the alter user statement.
	3. Replace the editioning views with regular views.

     Perform a "ALTER SYSTEM CHECKPOINT" prior to "SHUTDOWN ABORT" and take
     a corrective action described above.

     Restriction is for:
     1) When source database is 11.2.0.1 and is being upgraded to 11.2.0.2.
     2) To identify the particular schema/views run the pre-upgrade script
        /rdbms/admin/utlu112i.sql in normal mode on the source database.
     
#######################################################################
#######################################################################
#

CREATE OR REPLACE PROCEDURE check_edition_exists
AS

  d_version      VARCHAR2(30);
  server_version VARCHAR2(30);
  ev_count       INTEGER;

BEGIN
  SELECT version INTO d_version FROM registry$ where cid='CATPROC';
  select version into server_version from v$instance;
  IF substr(d_version,1,8) = '11.2.0.1' AND
     substr(server_version,1,8)= '11.2.0.2'
  THEN
     EXECUTE IMMEDIATE 'SELECT count(*) FROM SYS.DBA_EDITIONING_VIEWS EV, 
                                             SYS.DBA_USERS US
                                        WHERE US.USERNAME = EV.OWNER AND
                                              US.EDITIONS_ENABLED <> ''Y'' AND
					      ROWNUM < 2'
     INTO ev_count;
      IF ev_count > 0 THEN     
        RAISE_APPLICATION_ERROR(-20000,
         'Editioning view exists for non-edition enabled schema' );
      END IF;
  END IF;

END check_edition_exists;
/


Rem check if an editioning view exists for a non edition enabled user
begin
check_edition_exists;
end;
/

drop procedure check_edition_exists;

Rem Determine original release and run the appropriate script
CREATE OR REPLACE FUNCTION version_script 
RETURN VARCHAR2 IS

  p_null         char(1);
  p_version      VARCHAR2(30);
  p_prv_version  VARCHAR2(30);
  server_version VARCHAR2(30);

BEGIN

-- For 11.2, direct uppgrades are supported from 9.2.0.8, 10.1.0.5,
-- 10.2.0.2 and above, and 11.1.0.6 and above
--
  SELECT version INTO p_version FROM registry$ where cid='CATPROC';
  IF substr(p_version,1,7) = '9.2.0.8' THEN
     RETURN '0902000';
  ELSIF substr(p_version,1,8) = '10.1.0.5' THEN
     RETURN '1001000';
  ELSIF substr(p_version,1,6) = '10.2.0' AND
        substr(p_version,1,8) != '10.2.0.1' THEN
     RETURN '1002000';
  ELSIF substr(p_version,1,6) = '11.1.0' THEN
     RETURN '1101000';
  ELSIF substr(p_version,1,6) = '11.2.0' THEN -- current version
     SELECT version INTO server_version FROM v$instance;
     IF substr(p_version,1,8) != substr(server_version,1,8) THEN --- run c1102000   
        RETURN '1102000';
     ELSE -- version is the same as instance, so rerun the previous upgrade
     -- rerun upgrade of previous release 
        EXECUTE IMMEDIATE
             'SELECT prv_version FROM registry$ where cid=''CATPROC'''
        INTO p_prv_version;
        IF substr(p_prv_version,1,5) = '9.2.0' THEN
           RETURN '0902000';
        ELSIF substr(p_prv_version,1,6) = '10.1.0' THEN
           RETURN '1001000';
        ELSIF substr(p_prv_version,1,6) = '10.2.0' THEN
           RETURN '1002000';
        ELSIF substr(p_prv_version,1,6) = '11.1.0' THEN
           RETURN '1101000';
        ELSIF substr(p_prv_version,1,6) = '11.2.0' OR
              p_prv_version IS NULL THEN  -- new database
           RETURN '1102000';
        ELSE
           RAISE_APPLICATION_ERROR(-20000,
          'Upgrade re-run not supported from version ' || p_prv_version );
        END IF;
      END IF;
  END IF;

  RAISE_APPLICATION_ERROR(-20000,
       'Upgrade not supported from version ' || p_version );

END version_script;
/

Rem get the correct script name into the "upgrade_file" variable
COLUMN file_name NEW_VALUE upgrade_file NOPRINT;
SELECT version_script AS file_name FROM DUAL;

WHENEVER SQLERROR CONTINUE

Rem run the selected "c" upgrade script
@@c&upgrade_file

Rem Remove entries from sys.duc$ - rebuilt for 11g by catalog and catproc
Rem Can cause errors on any DROP USER statements in upgrade scripts
truncate table duc$;

Rem =====================================================================
Rem END STAGE 3: dictionary upgrade
Rem =====================================================================

