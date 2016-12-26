Rem
Rem $Header: rdbms/admin/catbundle.sql /st_rdbms_11.2.0.4.0dbpsu/3 2014/12/07 21:49:37 surman Exp $
Rem
Rem catbundle.sql
Rem
Rem Copyright (c) 2008, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catbundle.sql - Patch bundle installation script
Rem
Rem    DESCRIPTION
Rem      This script is used to load the necessary SQL files for a bundled
Rem      patch installation into the database.  It is meant to be run after
Rem      opatch has finished updating the ORACLE_HOME with the new SQL files
Rem      and binaries, and the database has been started.
Rem
Rem      There are two parameters, both of which are mandatory:
Rem      @catbundle <bundle series> <patch mode>
Rem      where <bundle series> is the name of the bundle (i.e. CPU or WINDOWS)
Rem      and <patch mode> is either apply or rollback.
Rem      The arguments are not case sensitive.
Rem
Rem      You must be connected as sys before running this script.
Rem
Rem      catbundle.sql will look in $ORACLE_HOME/rdbms/admin for an input XML
Rem      file named bundledata_<bundle series>.xml (i.e. bundledata_CPU.xml)
Rem      for information about which patches in the bundle contain which SQL
Rem      files.
Rem
Rem      When invoked in apply mode, catbundle will do the following:
Rem      * Spool output to $ORACLE_BASE/cfgtoollogs/catbundle.  If 
Rem        $ORACLE_BASE is not defined, then spool output to 
Rem        $ORACLE_HOME/cfgtoollogs/catbundle/.  The directory will be created
Rem        if it does not already exist.
Rem      * Dynamically generate an apply SQL script based on the current
Rem        state of the database.  This script will be named 
Rem        catbundle_<bundle series>_<database SID>_APPLY_<timestamp>.sql
Rem        and will be generated to the $ORACLE_HOME/rdbms/admin directory.
Rem        It will contain only the files necessary to bring the database
Rem        to the highest patch level specified in bundledata.xml.
Rem      * Dynamically generate a rollback SQL script based on bundledata.xml.
Rem        This script will be named
Rem        catbundle_<bundle series>_<database SID>_ROLLBACK.sql and will
Rem        also be generated to $ORACLE_HOME/rdbms/admin.  It will contain
Rem        the files necessary to rollback the database back to a previous
Rem        state after an opatch -rollback.
Rem      * Automatically invoke the generated apply script.
Rem
Rem     When invoked in rollback mode, catbundle will simply call the 
Rem     existing generated rollback script.  The rollback script can also
Rem     be called directly from a SQL*Plus session.
Rem
Rem     The scripts catcpu.sql and catcpu_rollback.sql are now wrappers to
Rem     this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    surman      12/06/14 - Backport surman_bug-20074391 from
Rem                           st_rdbms_11.2.0.4.0dbpsu
Rem    surman      12/04/14 - 20074391: Increase serveroutput limit
Rem    surman      10/03/14 - 19727057: Always call jvmpsu.sql if it exists
Rem    surman      10/28/13 - Backport surman_bug-13866822 from main
Rem    surman      10/22/13 - Backport surman_bug-17343514 from main
Rem    apfwkr      10/14/13 - Backport surman_bug-13866822 from main
Rem    surman      08/22/13 - 17343514: Remove java
Rem    surman      06/21/13 - 13866822: Call apply after rollback
Rem    surman      07/18/11 - 12766056: Always create CatbundleCreateDir
Rem    surman      05/31/11 - 11937509: Create log directory in java
Rem    surman      05/17/11 - 10413872: Filename priority
Rem    surman      05/16/11 - 10413872: Bundledata version
Rem    surman      07/27/10 - 9938689: Create log directory using ORACLE_BASE
Rem    surman      05/08/09 - 8498426: Set namespace
Rem    surman      03/30/09 - 8358067: Specify nls_language
Rem    surman      03/04/09 - 7710405: Correct INSTR platform checks
Rem    rvadraha    09/03/13 - 7658224: Check mount points using _kolfuseslf
Rem    surman      09/10/08 - 7391049: Invalid dba_registry_history synonym
Rem    surman      06/13/08 - Use proper action in registry update
Rem    surman      06/10/08 - Change logging behavior
Rem    surman      06/09/08 - Still more comments
Rem    surman      06/06/08 - Determine directory names in catbundle
Rem    surman      06/05/08 - Generate rollback script at apply time
Rem    surman      06/05/08 - Remove bundle_script and spool commands
Rem    surman      05/28/08 - More comments
Rem    surman      05/21/08 - Generic bundle names
Rem    surman      05/20/08 - Change to catbundle from catbp
Rem    surman      05/20/08 - Support rollback
Rem    surman      05/19/08 - catcpu.sql replacement project
Rem    surman      05/19/08 - Created
Rem

SET TERMOUT on
SET ECHO off
SET NUMWIDTH 10
SET LINESIZE 200
SET TRIMSPOOL off
SET TAB OFF
SET SERVEROUTPUT on size unlimited
SET VERIFY off

DEFINE bundle_series = &1
DEFINE patch_mode = &2

VARIABLE rdbmsAdminDir      VARCHAR2(500);
VARIABLE rdbmsLogDir        VARCHAR2(500);
VARIABLE catbundleLogDir    VARCHAR2(500);
VARIABLE javavmInstallDir   VARCHAR2(500);
VARIABLE createDirCmd       VARCHAR2(600);
VARIABLE applyScriptFile    VARCHAR2(500);
VARIABLE rollbackScriptFile VARCHAR2(500);
VARIABLE scriptFile         VARCHAR2(500);
VARIABLE kolfuseslf         VARCHAR2(50);

REM Init the variable to its default value
BEGIN :kolfuseslf := 'FALSE'; END;
/

-- Returns TRUE if the specified directory exists and is writable.
-- If there are any errors encountered while opening the directory and writing
-- a test file (using utl_file) then false is returned.
-- Note that only one session should call this at a time because the directory
-- is not session specific.
-- Added for bug 17343514.
CREATE OR REPLACE FUNCTION dir_exists_and_is_writable(dirname IN VARCHAR2)
  RETURN BOOLEAN
IS
PRAGMA AUTONOMOUS_TRANSACTION;  -- executes DDL

  fp UTL_FILE.FILE_TYPE;

BEGIN
  -- Try to create directory object
  BEGIN
    EXECUTE IMMEDIATE
      'CREATE OR REPLACE DIRECTORY dbms_registry_testdir AS ' ||
       dbms_assert.enquote_literal(dirname);
  EXCEPTION
    WHEN OTHERS THEN
      -- We want to just quit here since the directory object can't be created
      RETURN FALSE;
  END;

  -- Attempt to open a file, close it, and then delete it.
  fp := UTL_FILE.FOPEN('DBMS_REGISTRY_TESTDIR',
                       'dbms_registry_testfile.txt', 'a');
  UTL_FILE.FCLOSE(fp);
  UTL_FILE.FREMOVE('DBMS_REGISTRY_TESTDIR', 'dbms_registry_testfile.txt');

  EXECUTE IMMEDIATE 'DROP DIRECTORY dbms_registry_testdir';

  -- If we get here we're good
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    -- Try to drop the directory first
    BEGIN
      EXECUTE IMMEDIATE 'DROP DIRECTORY dbms_registry_testdir';
    EXCEPTION
      WHEN OTHERS THEN null;
    END;

    -- And return FALSE.  We don't care what the error was.
    RETURN FALSE;
END dir_exists_and_is_writable;
/

-- Returns TRUE if the specified file exists.
-- If there are any errors encountered while opening the directory and file
-- (using utl_file) then false is returned.
-- Note that only one session should call this at a time because the directory
-- is not session specific.
-- Added for bug 19727057.
CREATE OR REPLACE FUNCTION file_exists(dirname IN VARCHAR2, filename IN VARCHAR2)
   RETURN BOOLEAN IS
PRAGMA AUTONOMOUS_TRANSACTION;  -- executes DDL 

  fp UTL_FILE.FILE_TYPE;

BEGIN
  -- Try to create directory object
  BEGIN
    EXECUTE IMMEDIATE 
      'CREATE OR REPLACE DIRECTORY catbundle_testdir AS ' ||
       dbms_assert.enquote_literal(dirname);
  EXCEPTION
    WHEN OTHERS THEN
      -- We want to just quit here since the directory object can't be created
      RETURN FALSE;
  END;

  -- Attempt to open the file and  close it.
  fp := UTL_FILE.FOPEN('CATBUNDLE_TESTDIR', filename, 'r');
  UTL_FILE.FCLOSE(fp);

  EXECUTE IMMEDIATE 'DROP DIRECTORY catbundle_testdir';

  -- If we get here we're good
  RETURN TRUE;
EXCEPTION
  WHEN OTHERS THEN
    -- Try to drop the directory first
    BEGIN
      EXECUTE IMMEDIATE 'DROP DIRECTORY catbundle_testdir';
    EXCEPTION
      WHEN OTHERS THEN null;
    END;

    -- And return FALSE.  We don't care what the error was.
    RETURN FALSE;
END file_exists;
/

REM Determine the names of interesting directories and create them if
REM necessary.
DECLARE
  platform v$database.platform_name%TYPE;
  homeDir  VARCHAR2(500);
  baseDir  VARCHAR2(500);
  useDir   VARCHAR2(500);
  bundleSeries VARCHAR2(50) := NLS_UPPER('&bundle_series');

BEGIN
  -- Determine ORACLE_HOME value and admin dir
  SELECT NLS_UPPER(platform_name)
    INTO platform
    FROM v$database;

  -- 9938689: Default to $ORACLE_BASE/cfgtoollogs/catbundle; if $ORACLE_BASE
  -- is not defined then use $ORACLE_HOME/cfgtoollogs/catbundle; if 
  -- $ORACLE_HOME is not defined then error
  DBMS_SYSTEM.GET_ENV('ORACLE_BASE', baseDir);
  DBMS_SYSTEM.GET_ENV('ORACLE_HOME', homeDir);

  IF homeDir IS NULL THEN
    RAISE_APPLICATION_ERROR(-20000, 'ORACLE_HOME is not defined');
  END IF;

  IF baseDir IS NOT NULL THEN
    useDir := baseDir;
  ELSE
    useDir := homeDir;
  END IF;

  IF INSTR(platform, 'WINDOWS') != 0 THEN
    -- Windows, use '\'
    useDir := RTRIM(useDir, '\');  -- Remove any trailing slashes
    :catbundleLogDir := useDir || '\cfgtoollogs\catbundle\';
    :createDirCmd := 'mkdir ' || :catbundleLogDir;
    :rdbmsAdminDir := homeDir || '\rdbms\admin\';
    :rdbmsLogDir := homeDir || '\rdbms\log\';
    :javavmInstallDir := homeDir || '\javavm\install\';
  ELSIF INSTR(platform, 'VMS') != 0 THEN
    -- VMS, use [] and .
    :catbundleLogDir := REPLACE(useDir || '[cfgtoollogs.catbundle]', '][', '.');
    :createDirCmd := 'CREATE/DIR ' || :catbundleLogDir;
    :rdbmsAdminDir := REPLACE(homeDir || '[rdbms.admin]', '][', '.');
    :rdbmsLogDir := REPLACE(homeDir || '[rdbms.log]', '][', '.');
    :javavmInstallDir := REPLACE(homeDir || '[javavm.install]', '][', '.');
  ELSE 
    -- Unix and z/OS, '/'
    useDir := RTRIM(useDir, '/');  -- Remove any trailing slashes
    :catbundleLogDir := useDir || '/cfgtoollogs/catbundle/';
    :createDirCmd := 'mkdir -p ' || :catbundlelogDir;
    :rdbmsAdminDir := homeDir || '/rdbms/admin/';
    :rdbmsLogDir := homeDir || '/rdbms/log/';
    :javavmInstallDir := homeDir || '/javavm/install/';
  END IF;

  SELECT :rdbmsAdminDir || 'catbundle_' || bundleSeries || '_' ||
         name || '_APPLY.sql'
    INTO :applyScriptFile
    FROM v$database;

  SELECT :rdbmsAdminDir || 'catbundle_' || bundleSeries || '_' ||
         name || '_ROLLBACK.sql'
    INTO :rollbackScriptFile
    FROM v$database;

  IF dir_exists_and_is_writable(:catbundleLogDir) THEN
    -- Log directory already exists, we don't need to create it
    :createDirCmd := 'exit';
  END IF;
END;
/

REM 17343514: Create the directory if necessary using a HOST command
COLUMN create_cmd NEW_VALUE create_cmd NOPRINT
SELECT :createDirCmd AS create_cmd FROM dual;
HOST &create_cmd

REM 17343514: Verify that the directory now exists
BEGIN
  IF NOT dir_exists_and_is_writable(:catbundleLogDir) THEN
    :catbundleLogDir := :rdbmsLogDir;
  END IF;
END;
/

REM Turn spooling on for the generate phase
COLUMN generate_logfile NEW_VALUE generate_logfile NOPRINT
SELECT :catbundleLogDir || 'catbundle_' || NLS_UPPER('&bundle_series') || '_' ||
       name || '_GENERATE_' ||
       TO_CHAR(SYSDATE, 'YYYYMonDD_hh24_mi_ss',
                        'NLS_DATE_LANGUAGE=''AMERICAN''') ||
       '.log'
  AS generate_logfile
  FROM v$database;
SPOOL &generate_logfile

PROMPT Generating apply and rollback scripts...
PROMPT Check the following file for errors:
PROMPT &generate_logfile

SET TERMOUT off
SET ECHO on

REM Add new column to registry$history and dba_registry_history if needed
BEGIN
  EXECUTE IMMEDIATE 
    'ALTER TABLE registry$history ADD (bundle_series VARCHAR2(30))';
  -- 7391049: Recompile dbms_registry_sys so there are no more invalid objects
  EXECUTE IMMEDIATE
    'ALTER PACKAGE sys.dbms_registry_sys COMPILE BODY';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 THEN
      -- Column already exists in table, just ignore the error
      NULL;
    ELSE
      RAISE;
    END IF;
END;
/

CREATE OR REPLACE VIEW dba_registry_history (
  action_time, action, namespace, version, id, bundle_series, comments)
AS
  SELECT action_time, action, namespace, version, id, bundle_series, comments
    FROM registry$history;

REM 7391049: Recreate synonym so there are no more invalid objects
CREATE OR REPLACE PUBLIC SYNONYM 
  dba_registry_history FOR dba_registry_history;

REM Create temporary table
CREATE GLOBAL TEMPORARY TABLE bundle_component_files
  (cid           VARCHAR2(25),
   fname         VARCHAR2(100),
   seq           NUMBER,
   priority      NUMBER,
   rollback_only CHAR(1),
   UNIQUE(cid, fname))
  ON COMMIT PRESERVE ROWS;

REM Disable Symlink/Mountpoint checks (required for windows platform)
DECLARE
  kolfuseslf_cnt      NUMBER := 0;
  stmt                VARCHAR2(1000);
BEGIN
  -- alter session: enable use of symbolic links
  -- first get the current value of _kolfuseslf (default FALSE)
  stmt := 'SELECT COUNT(*) FROM V$PARAMETER WHERE NAME=''_kolfuseslf''';
  EXECUTE IMMEDIATE stmt INTO kolfuseslf_cnt;
  IF kolfuseslf_cnt != 0 THEN
    stmt := 'SELECT VALUE INTO :kolfuseslf FROM V$PARAMETER WHERE NAME=''_kolfuseslf''';
    EXECUTE IMMEDIATE stmt;
  END IF;
  stmt := 'ALTER SESSION SET "_kolfuseslf" = TRUE';
  EXECUTE IMMEDIATE stmt;
END;
/

REM And go for it
DECLARE
  bundledata XMLType;
  bundle     XMLType;
  component  XMLType;

  bundledataVersion          VARCHAR2(50);
  xmlFilename                VARCHAR2(50);
  bundleID                   NUMBER;
  bundleDescription          VARCHAR2(100);
  installedBundle            NUMBER;
  installedBundleDescription VARCHAR2(100);
  patchMode                  VARCHAR2(50) := NLS_UPPER('&patch_mode');
  bundleSeries               VARCHAR2(50) := NLS_UPPER('&bundle_series');
  startingBundle             NUMBER;
  currentDBVersion           VARCHAR2(20);
  rollbackOnly               CHAR(1);
  spoolCommand               VARCHAR2(500);

  filename    VARCHAR2(100);
  priority    NUMBER;
  componentID VARCHAR2(30);

  filenameSeq BINARY_INTEGER := 1;

  compHeaderWritten BOOLEAN := TRUE;

  fileopenFailed EXCEPTION;
  PRAGMA EXCEPTION_INIT(fileopenFailed, -22288);
  invalidMode    EXCEPTION;

  applyScriptFilePtr    UTL_FILE.FILE_TYPE;
  rollbackScriptFilePtr UTL_FILE.FILE_TYPE;

  platform v$database.platform_name%TYPE;

  CURSOR reverseBundleIDsCur(x XMLType) IS
    SELECT extract(column_value, '/bundle/@id').getNumberVal() bundleID
      FROM XMLTable('/bundledata/bundle' PASSING x)
      ORDER BY bundleID DESC;

  CURSOR bundleCur(x XMLType) IS
    SELECT column_value,
           extract(column_value, '/bundle/@id').getNumberVal() bundleID,
           extract(column_value, '/bundle/@description').getStringVal() bundleDesc
      FROM XMLTable('/bundledata/bundle' PASSING x)
      ORDER BY bundleID;

  CURSOR componentCur(x XMLType) IS
    SELECT column_value,
           extract(column_value, '/component/@id').getStringVal()
      FROM XMLTable('/bundle/component' PASSING x);

  -- 10413872: Add priority
  CURSOR fileCur(x XMLType) IS
    SELECT c."Filename", extract(column_value, '/file/@priority').getNumberVal() priority
       FROM XMLTable('/component/file'
                     PASSING x
                     COLUMNS "Filename" VARCHAR2(100) PATH '/file') c;

  CURSOR componentInfoCur (x XMLType) IS
    SELECT DISTINCT
           extract(column_value, '/component/@id').getStringVal() compID,
           extract(column_value, '/component/@name').getStringVal() compName,
           extract(column_value, '/component/@schema').getStringVal() compSchema
      FROM XMLTable('/bundledata/bundle/component' PASSING x)
      ORDER BY compSchema;

  CURSOR bundleComponentFilesCur (compID VARCHAR2) IS
    SELECT fname, rollback_only
      FROM bundle_component_files
      WHERE cid = compID
      ORDER BY priority, seq;

  PROCEDURE openScriptFiles(apply_file_name IN VARCHAR2,
                            rollback_file_name IN VARCHAR2) IS
  BEGIN
    applyScriptFilePtr := UTL_FILE.FOPEN('ADMIN_DIR', apply_file_name, 'w');
    rollbackScriptFilePtr :=
      UTL_FILE.FOPEN('ADMIN_DIR', rollback_file_name, 'w');
  EXCEPTION
    WHEN UTL_FILE.INVALID_PATH THEN
      RAISE_APPLICATION_ERROR(-20000, 'INVALID_PATH during openScriptFile');
    WHEN UTL_FILE.INVALID_MODE THEN
      RAISE_APPLICATION_ERROR(-20000, 'INVALID_MODE during openScriptFile');
    WHEN UTL_FILE.INVALID_OPERATION THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'INVALID_OPERATION during openScriptFile');
    WHEN UTL_FILE.INVALID_MAXLINESIZE THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'INVALID_MAXLINESIZE during openScriptFile');
  END openScriptFiles;

  -- If script is 'A', then input_line will be written to the apply script.
  -- If script is 'R', then input_line will be written to the rollback script.
  -- If script is 'B', then input_line will be written to both scripts.
  PROCEDURE insertScriptFile(script IN CHAR,
                             input_line IN VARCHAR2) IS
  BEGIN
    IF script = 'A' OR script = 'B' THEN
      UTL_FILE.PUT_LINE(applyScriptFilePtr, input_line);
    END IF;
    IF script = 'R' OR script = 'B' THEN
      UTL_FILE.PUT_LINE(rollbackScriptFilePtr, input_line);
    END IF;
  EXCEPTION
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'INVALID_FILEHANDLE during insertScriptFile');
    WHEN UTL_FILE.INVALID_OPERATION THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'INVALID_OPERATION during insertScriptFile');
    WHEN UTL_FILE.WRITE_ERROR THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'WRITE_ERROR during insertScriptFile');
  END insertScriptFile;

  PROCEDURE closeScriptFiles IS
  BEGIN
    UTL_FILE.FCLOSE(applyScriptFilePtr);
    UTL_FILE.FCLOSE(rollbackScriptFilePtr);
  EXCEPTION
    WHEN UTL_FILE.INVALID_FILEHANDLE THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'INVALID_FILEHANDLE during closeScriptFile');
    WHEN UTL_FILE.WRITE_ERROR THEN
      RAISE_APPLICATION_ERROR(-20000,
                              'WRITE_ERROR during closeScriptFile');
  END closeScriptFiles;

  -- Returns the first 4 digits of a version (i.e. '10.2.0.4' is returned
  -- from the input string '10.2.0.4.3')
  FUNCTION versionTrim(version IN VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(version, 1, INSTR(version, '.', 1, 4) - 1);
  END versionTrim;

  FUNCTION componentOK(component IN VARCHAR2)
    RETURN BOOLEAN IS
  
  BEGIN
    -- This is modeled off of dbms_registry_sys.cpu_script().
    IF sys.dbms_registry.is_in_registry(component) AND
       sys.dbms_registry.status(component) NOT IN ('REMOVING', 'REMOVED') AND
       versionTrim(sys.dbms_registry.version(component)) = currentDBVersion THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;
  END componentOK;

BEGIN
  EXECUTE IMMEDIATE 
    'CREATE OR REPLACE DIRECTORY admin_dir AS ''' || :rdbmsAdminDir || '''';

  xmlFilename := 'bundledata_' || bundleSeries || '.xml';

  -- 8498426: Set namespace
  sys.dbms_registry.set_session_namespace('SERVER');

  -- Load XML data file
  bundledata :=
    XMLType(bfilename('ADMIN_DIR', xmlFilename), nls_charset_id('US7ASCII'));

  -- 10413872: Get version of bundledata.xml so we know what fields to
  -- look for
  BEGIN
    SELECT extract(column_value, '/bundledata/@version').getNumberVal() 
      INTO bundledataVersion
      FROM XMLTable('/bundledata' PASSING bundledata);
  EXCEPTION
    WHEN OTHERS THEN
      IF sqlcode = -1722 THEN
        -- Invalid number, version is not valid so assume 0
        bundledataVersion := 0;
      ELSE
        RAISE;
      END IF;
  END;

  -- Set :scriptFile to the right value.  When this block completes, we will
  -- run :scriptFile after cleaning up the temporary objects
  IF patchMode = 'ROLLBACK' THEN
    :scriptFile := :rollbackScriptFile;
    RETURN;  -- No need to actually generate anything
  ELSIF patchMode = 'APPLY' THEN
    :scriptFile := :applyScriptFile;
  ELSIF patchMode != 'APPLY' THEN 
    RAISE invalidMode;
  END IF;

  -- Get database version.  We only want the first 4 digits (i.e. 10.2.0.4).
  SELECT version
    INTO currentDBVersion
    FROM v$instance;
  currentDBVersion := versionTrim(currentDBVersion);

  -- Determine current bundle installed.
  DECLARE
    historyRec registry$history%ROWTYPE;
  BEGIN
    SELECT *
      INTO historyRec
      FROM registry$history
      WHERE action_time =
        (SELECT MAX(action_time)
           FROM registry$history
           WHERE namespace = 'SERVER'
           AND bundle_series = bundleSeries
           AND version = currentDBVersion);

    IF historyRec.action = 'ROLLBACK' THEN
      -- Latest entry is bundle rollback, therefore no bundle applied
      installedBundle := 0;
      installedBundleDescription := 'None';
    ELSIF historyRec.action  = 'APPLY' THEN
      -- Latest entry is a bundle apply, return it
      installedBundle := historyRec.id;
      installedBundleDescription := historyRec.comments;
    ELSE
      -- Latest entry is something else, therefore assume no bundle applied
      installedBundle := 0;
      installedBundleDescription := 'None';
    END IF;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- No entries, therefore no bundle applied
      installedBundle := 0;
      installedBundleDescription := 'None';
  END;

  DBMS_OUTPUT.PUT_LINE('Current bundle installed: (' || installedBundle ||
                       ') - ' || installedBundleDescription);

  -- Determine which bundle to start with in the current install.
  FOR bundleRec IN reverseBundleIDsCur(bundledata) LOOP
    -- If there is no bundle installed, assign to starting_bundle.  Since this
    -- loop is in descending order, we will end up with starting_bundle = 
    -- the earliest bundle ID in the data file.
    IF installedBundle IS NULL THEN
      startingBundle := bundleRec.bundleID;
    ELSE
      -- Ensure that the latest bundle will at least be installed.  This covers
      -- the case where we are re-installing the latest bundle again.
      IF startingBundle IS NULL THEN
         startingBundle := bundleRec.bundleID;
      END IF;

      -- If the fetched bundle ID > installed bundle ID, we need to install
      -- the fetched bundle ID.
      IF bundleRec.bundleID > installedBundle THEN
        startingBundle := bundleRec.bundleID;
      END IF;
    END IF;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('Starting bundle ID: ' || startingBundle);

  -- For each bundle:
  OPEN bundleCur(bundledata);
  LOOP
    FETCH bundleCur INTO bundle, bundleID, bundleDescription;
    EXIT WHEN bundleCur%NOTFOUND;

    -- Check against currently installed bundle ID.  We will include this
    -- bundle if there are no currently installed bundles, or if the
    -- currently installed bundle ID <= this bundle ID.
    -- If the patch mode is rollback, then we will include all bundles.
    DBMS_OUTPUT.PUT_LINE('Processing components and files for bundle ' ||
                         bundleID || ': ' || bundleDescription);

    IF bundleID >= startingBundle THEN
      rollbackOnly := 'N';
    ELSE
      rollbackOnly := 'Y';
    END If;

    -- For each component within that bundle:
    OPEN componentCur(bundle);
    LOOP
      FETCH componentCur INTO component, componentID;
      EXIT WHEN componentCur%NOTFOUND;

      -- For each file within that component:
      OPEN fileCur(component);
      LOOP
        FETCH fileCur INTO filename, priority;
        EXIT WHEN fileCur%NOTFOUND;

        -- Insert into bundle_component_files to trap duplicates
        -- 10413872: Add priority
        BEGIN
          INSERT INTO bundle_component_files
              (cid, fname, seq, priority, rollback_only)
            VALUES
              (componentID, filename, filenameSeq, priority, rollbackOnly);
          filenameSeq := filenameSeq + 1;
        EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            -- File is already present for this component, just update 
            -- rollback_only if needed
            IF rollbackOnly = 'N' THEN
              UPDATE bundle_component_files
                SET rollback_only = 'N'
                WHERE cid = componentID
                AND fname = filename;
            END IF;
        END;

      END LOOP;
      CLOSE fileCur;

    END LOOP;
    CLOSE componentCur;

  END LOOP;
  CLOSE bundleCur;

  -- Now bundle_component_files has the (unique) list of files for each
  -- component.  The next step is to generate the output scripts.
  openScriptFiles(:applyScriptFile, :rollbackScriptFile);

  insertScriptFile('A', 'REM This script is ' || :applyScriptFile);
  insertScriptFile('R', 'REM This script is ' || :rollbackScriptFile);
  insertScriptFile('B', 'REM It was generated by catbundle.sql on ' || 
                        TO_CHAR(SYSDATE, 'YYYYMonDD_hh24_mi_ss',
                                'NLS_DATE_LANGUAGE=''AMERICAN'''));

  insertScriptFile('B', 'SET echo on');
  
  -- Generate spool commands
  insertScriptFile('B', 'COLUMN spool_file NEW_VALUE spool_file NOPRINT');

  spoolCommand := 
    'SELECT ''' || :catbundleLogDir || ''' || ''catbundle_' || bundleSeries || 
    '_'' || name || ''_APPLY_'' || ' ||
    'TO_CHAR(SYSDATE, ''YYYYMonDD_hh24_mi_ss'', ' ||
                      '''NLS_DATE_LANGUAGE=''''AMERICAN'''''') || ' ||
    '''.log''' ||
    ' AS spool_file FROM v$database;';
  insertScriptFile('A', spoolCommand);


  spoolCommand := 
    'SELECT ''' || :catbundleLogDir || ''' || ''catbundle_' || bundleSeries || 
    '_'' || name || ''_ROLLBACK_'' || ' ||
    'TO_CHAR(SYSDATE, ''YYYYMonDD_hh24_mi_ss'', ' ||
                      '''NLS_DATE_LANGUAGE=''''AMERICAN'''''') || ' ||
    '''.log''' || 
    ' AS spool_file FROM v$database;';
  insertScriptFile('R', spoolCommand);
  insertScriptFile('B', 'SPOOL &' || 'spool_file');

  -- 8498426: Set namespace
  insertScriptFile('B', 'exec sys.dbms_registry.set_session_namespace(''SERVER'')');

  -- 19727057: If javavm/install/jvmpsu.sql exists, execute it first.
  IF file_exists(:javavmInstallDir, 'jvmpsu.sql') THEN
    insertScriptFile('B', 'PROMPT Calling jvmpsu.sql to initialize Java...');
    insertScriptFile('B', '@?/javavm/install/jvmpsu.sql');
  END IF;

  FOR componentInfoRec IN componentInfoCur(bundledata) LOOP
    compHeaderWritten := TRUE;

    IF componentOK(componentInfoRec.compID) THEN
      OPEN bundleComponentFilesCur(componentInfoRec.compID);
      LOOP
        FETCH bundleComponentFilesCur INTO filename, rollbackOnly;
        EXIT WHEN bundleComponentFilesCur%NOTFOUND;

        -- Ensure that we switch schemas only if the component has files to
        -- process.
        IF compHeaderWritten THEN
          insertScriptFile('R',
            'PROMPT Processing ' || componentInfoRec.compName || '...');
          insertScriptFile('R',
            'ALTER SESSION SET current_schema = ' ||
             componentInfoRec.compSchema || ';');
          -- If any of the files are marked rollback_only = 'N' then
          -- output to the apply file
          DECLARE
            rollback_count NUMBER;
          BEGIN
            SELECT COUNT(*)
              INTO rollback_count
              FROM bundle_component_files
              WHERE cid = componentInfoRec.compID
              AND rollback_only = 'N';
            IF rollback_count > 0 THEN
              insertScriptFile('A',
                'PROMPT Processing ' || componentInfoRec.compName || '...');
              insertScriptFile('A',
                'ALTER SESSION SET current_schema = ' ||
                 componentInfoRec.compSchema || ';');
            END IF;
          END;
          compHeaderWritten := FALSE;
        END IF;

        insertScriptFile('R', '@' || filename);
        IF rollbackOnly = 'N' THEN
          insertScriptFile('A', '@' || filename);
        END IF;
      END LOOP;
      CLOSE bundleComponentFilesCur;
    ELSE
      insertScriptFile('B', 
        'PROMPT Skipping ' || componentInfoRec.compName || 
        ' because it is not installed or versions mismatch...');
    END IF;
  END LOOP;

  -- Switch user back to SYS
  insertScriptFile('B', 'ALTER SESSION SET current_schema = SYS;');

  -- Update the registry if we've actually done something.
  IF (bundleID IS NOT NULL) THEN
    insertScriptFile('B', 'PROMPT Updating registry...');
    insertScriptFile('B', 'INSERT INTO registry$history ');
    insertScriptFile('B', '  (action_time, action,');
    insertScriptFile('B', '   namespace, version, id, ');
    insertScriptFile('B', '   bundle_series, comments)');
    insertScriptFile('B', 'VALUES');
    insertScriptFile('A', '  (SYSTIMESTAMP, ''APPLY'', ');
    insertScriptFile('R', '  (SYSTIMESTAMP, ''ROLLBACK'', ');
    insertScriptFile('B', '   SYS_CONTEXT(''REGISTRY$CTX'',''NAMESPACE''), ');
    insertScriptFile('B', '   ''' || currentDBVersion || ''', ');
    insertScriptFile('B', '   ' || bundleID || ', ');
    insertScriptFile('B', '   ''' || bundleSeries || ''',');
    insertScriptFile('B', '   ''' || bundleDescription || ''');');
  END IF;

  insertScriptFile('B', 'COMMIT;');
  insertScriptFile('B', 'SPOOL off');
  insertScriptFile('B', 'SET echo off');
  insertScriptFile('B', 'PROMPT Check the following log file for errors:');
  insertScriptFile('B', 'PROMPT &' || 'spool_file');

  -- 13866822: Add call to apply in the rollback script.  The idea is that
  -- a rollback will roll back all the way to bundle 0, but the binary 
  -- level may not be bundle 0.  So we need to regenerate and run the apply
  -- script.
  insertScriptFile('R', '@@?/rdbms/admin/catbundle.sql &bundle_series apply');
  closeScriptFiles;

  DBMS_OUTPUT.PUT_LINE('Apply SQL file: ' || :applyScriptFile);
  DBMS_OUTPUT.PUT_LINE('Rollback SQL file: ' || :rollbackScriptFile);

EXCEPTION
  WHEN fileopenFailed THEN
    DBMS_OUTPUT.PUT_LINE(
      'Error reading ' || xmlFilename || ' - patch NOT installed');
    DBMS_OUTPUT.PUT_LINE('Ensure that the file exists in ' || :rdbmsAdminDir);
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    :scriptFile := :rdbmsAdminDir || 'nothing.sql';  -- We need to run something
  WHEN invalidMode THEN
    DBMS_OUTPUT.PUT_LINE(
      'Invalid mode ' || patchMode || ' - patch NOT installed');
    DBMS_OUTPUT.PUT_LINE('Mode must be either apply or rollback');
    :scriptFile := :rdbmsAdminDir || 'nothing.sql';  -- We need to run something
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Exception - patch NOT installed');
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
    :scriptFile := :rdbmsAdminDir || 'nothing.sql';  -- We need to run something
END;
/

REM Enable Symlink/Mountpoint checks (required for windows platform)
DECLARE
  stmt                VARCHAR2(1000);
BEGIN
  -- alter session: disable use of symbolic links
  -- (restore the variable to its prior value)
  stmt := 'ALTER SESSION SET "_kolfuseslf" = ' || :kolfuseslf;
  EXECUTE IMMEDIATE stmt;
END;
/

PROMPT Dropping temporary objects...
TRUNCATE TABLE bundle_component_files;
DROP TABLE bundle_component_files;
DROP DIRECTORY admin_dir;
DROP FUNCTION dir_exists_and_is_writable;
DROP FUNCTION file_exists;


SET ECHO off
SET TERMOUT on
BEGIN
  DBMS_OUTPUT.PUT_LINE('Apply script: ' || :applyScriptFile);
  DBMS_OUTPUT.PUT_LINE('Rollback script: ' || :rollbackScriptFile);
END;
/

PROMPT Executing script file...
SPOOL off

COLUMN script_file NEW_VALUE sf NOPRINT;
SELECT :scriptFile AS script_file FROM dual;
@&sf



