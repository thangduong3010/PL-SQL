Rem
Rem Copyright (c) 1996, 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem
Rem    NAME
Rem      pbload.sql - Load ProBe (PL/SQL debugger) server-side packages.
Rem
Rem    DESCRIPTION
Rem      Installs the Probe packages that enable server-side debugging.
Rem      (These packages are usually loaded by default by catproc.sql).
Rem
Rem    NOTES
Rem      * Must be executed as SYS.
Rem      * To deinstall Probe, use pbunload.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jmallory    12/18/01 - Set serveroutput off at end
Rem    ciyer       10/13/98 - raise exception on version mismatch
Rem    jmallory    07/22/98 - Add dbmspb.sql

@@dbmspb.sql
@@prvtpb.plb

-- Now that we've installed Probe, run an internal version check, to
-- make sure that the version we've installed is in sync with the
-- rdbms.  If it fails, deinstall Probe immediately.
--
-- DONT do this from catproc.sql, since in the worst case the internal
-- version check may crash the oracle process and halt catproc.

set serveroutput on

DECLARE

   probe_version_mismatch exception;
   pragma exception_init(probe_version_mismatch, -6516);

   ---------------------------- deinstall_probe ----------------------------
   -- Drop the Probe packages and synonyms.  This is identical to what
   -- pbunload.sql does...
   --
   PROCEDURE deinstall_probe IS
      victims  dbms_sql.varchar2s;
      curse    INTEGER := dbms_sql.open_cursor;
      discard  INTEGER;
      each     PLS_INTEGER;
   BEGIN
      victims(1) := 'DROP PACKAGE DBMS_DEBUG';
      victims(2) := 'DROP PACKAGE PBSDE';
      victims(3) := 'DROP PACKAGE PBRPH';
      victims(4) := 'DROP PACKAGE PBREAK';
      victims(5) := 'DROP PACKAGE PBUTL';
      victims(6) := 'DROP PUBLIC SYNONYM DBMS_DEBUG';
      victims(7) := 'DROP PUBLIC SYNONYM PBSDE';
      victims(8) := 'DROP PUBLIC SYNONYM PBRPH';
   
      each := victims.FIRST;
      WHILE (each IS NOT NULL) LOOP
         dbms_output.put_line('   Probe rollback: ' || victims(each));
         dbms_sql.parse(curse, victims(each), dbms_sql.native);
         discard := dbms_sql.execute(curse);
         each := victims.NEXT(each);
      END LOOP;
      dbms_sql.close_cursor(curse);

   EXCEPTION
      WHEN OTHERS THEN
         IF dbms_sql.is_open(curse) THEN 
            dbms_sql.close_cursor(curse); 
         END IF;
   END deinstall_probe;


   ------------------------- probe_version_status -------------------------
   -- Test the Probe version.  
   --
   -- The test is run via dbms_sql so that if it fails no locks or pins are
   -- left on dbms_debug.  (Otherwise we'd deadlock when trying to drop the
   -- packages.)
   --
   -- Returns
   --   0 for success
   --   1 for version failure (deinstallation recommended)
   --   2 for other failure
   --
   FUNCTION probe_version_status RETURN pls_integer IS
      stmt    dbms_sql.varchar2s;
      curse   INTEGER := dbms_sql.open_cursor;
      result  NUMBER;
      discard INTEGER;
   BEGIN
      stmt(1)  := 'DECLARE';
      stmt(2)  := '   failure EXCEPTION;';
      stmt(3)  := '   pragma exception_init(failure, -6516);';
      stmt(4)  := 'BEGIN';
      stmt(5)  := '   SYS.DBMS_DEBUG.self_check;';
      stmt(6)  := '   :result := 0;';
      stmt(7)  := 'EXCEPTION';
      stmt(8)  := '   WHEN failure THEN :result := 1;';
      stmt(9)  := '   WHEN OTHERS THEN :result := 2;';
      stmt(10) := 'END;';
      
      dbms_sql.parse(curse, stmt, stmt.FIRST, stmt.LAST, TRUE, dbms_sql.native);
      dbms_sql.bind_variable(curse, ':result', 666);
      discard := dbms_sql.execute(curse);
      dbms_sql.variable_value(curse, ':result', result);

      RETURN result;
   EXCEPTION
      WHEN OTHERS THEN RETURN 2;
   END probe_version_status;


   ----------------------------- check_package -----------------------------
   PROCEDURE check_package(package_name VARCHAR2,
                           check_body    BOOLEAN,
                           check_synonym BOOLEAN) IS
      number_of_objects PLS_INTEGER;
      success           BOOLEAN := TRUE;
      padded_name       VARCHAR2(15) := rpad(package_name, 10);
   BEGIN
      IF (check_synonym) THEN
         SELECT count(*) INTO number_of_objects
           FROM all_synonyms
          WHERE synonym_name = package_name
            AND owner = 'PUBLIC'
            AND table_owner = 'SYS';

         IF (number_of_objects <> 1) THEN
            dbms_output.put_line(padded_name || 
                                 ' - missing or invalid synonym.');
            success := FALSE;
         END IF;
      END IF;

      -- Check the spec
      SELECT count(*) INTO number_of_objects
        FROM all_objects
       WHERE object_name = package_name
         AND status = 'VALID'
         AND object_type = 'PACKAGE';

      IF (number_of_objects <> 1) THEN
         dbms_output.put_line(padded_name || 
                              ' - missing or invalid package spec.');
         success := false;
      END IF;

      IF (check_body) THEN
         -- Check the body
         SELECT count(*) INTO number_of_objects
           FROM all_objects
          WHERE object_name = package_name
            AND status = 'VALID'
            AND object_type = 'PACKAGE BODY';

         IF (number_of_objects <> 1) THEN
            dbms_output.put_line(padded_name || 
                                 ' - missing or invalid package body.');
            success := FALSE;
         END IF;
      END IF;
     
      IF (success) THEN
         dbms_output.put_line(padded_name || ' successfully loaded.');
      END IF;

   END check_package;


   ---------------------------- check_packages ----------------------------
   -- Check that the correct packages and synonyms exist.
   PROCEDURE check_packages IS
   BEGIN
      check_package('DBMS_DEBUG', check_body => true,  check_synonym => true);
      check_package('PBUTL',      check_body => false, check_synonym => false);
      check_package('PBRPH',      check_body => true,  check_synonym => true);
      check_package('PBSDE',      check_body => true,  check_synonym => true);
      check_package('PBREAK',     check_body => true,  check_synonym => false);
   END check_packages;

BEGIN
   IF (probe_version_status = 1) THEN
      -- found a version mismatch, deinstall Probe.
      deinstall_probe;
      RAISE probe_version_mismatch;
   ELSE
      -- Probe version is OK (unless a fluke exception occurred).  Now
      -- test to see that the packages and synonyms were created without
      -- errors.
      check_packages;
   END IF;
END;
/

set serveroutput off
