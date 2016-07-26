Rem
Rem $Header: rdbms/admin/catjava.sql /main/13 2009/02/20 03:15:05 ssonawan Exp $
Rem
Rem catjava.sql
Rem
Rem Copyright (c) 2001, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catjava.sql - CATalog scripts for JAVA
Rem
Rem    DESCRIPTION
Rem      This script loads the java classes for RDBMS features; it
Rem      should be run after JAVA is loaded into the database.  The
Rem      CATNOJAV.SQL script should be used to remove these java 
Rem      classes prior to removing JAVA from the database.
Rem
Rem    NOTES
Rem      Use SQL*Plus when connected AS SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ssonawan    02/13/09 - Bug 6736417: Don't load appctx package
Rem    rgmani      04/02/08 - Load scheduler java package
Rem    gssmith     02/05/07 - Remove Summary Advisor Java component
Rem    nireland    06/09/05 - Increase buffer size. #4380942 
Rem    mkrishna    11/15/04 - add xquery jar by defaut 
Rem    rburns      09/09/03 - cleanup 
Rem    jwwarner    06/24/03 - add loading of catxdbj.sql here
Rem    rburns      04/26/03 - use serveroutput for diagnostics
Rem    rburns      06/13/02 - comments for catnojav.sql
Rem    rburns      04/05/02 - continue even if Jserver not valid
Rem    rburns      02/11/02 - add registry version
Rem    rburns      01/12/02 - Merged rburns_catjava
Rem    rburns      12/03/01 - Created
Rem

DOC
##########################################################################
##########################################################################
   If the following PL/SQL block fails, then JServer is not operational.
##########################################################################
##########################################################################
#

BEGIN
   IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) != 1 THEN
      RAISE_APPLICATION_ERROR(-20000,
           'JServer has not been correctly loaded into the database.');   
   END IF;
END;
/

BEGIN
   dbms_registry.loading('CATJAVA','Oracle Database Java Packages',
        'DBMS_REGISTRY_SYS.validate_catjava');
END;
/

VARIABLE initfile VARCHAR2(32)
COLUMN :initfile NEW_VALUE init_file NOPRINT;

Rem =====================================================================
Rem Change Data Capture
Rem =====================================================================

BEGIN
  IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
     :initfile := 'initcdc.sql';
  ELSE
     :initfile := 'nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@@&init_file

Rem =====================================================================
Rem SQLJTYPE
Rem =====================================================================

BEGIN
  IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
     :initfile := 'initsjty.sql';
  ELSE
     :initfile := 'nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@@&init_file

Rem =====================================================================
Rem AQ JMS
Rem =====================================================================

BEGIN
  IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
     :initfile := 'initjms.sql';
  ELSE
     :initfile := 'nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@@&init_file

Rem =====================================================================
Rem ODCI and Cartridge Services
Rem =====================================================================

BEGIN
  IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
     :initfile := 'initsoxx.sql';
  ELSE
     :initfile := 'nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@@&init_file

Rem =====================================================================
Rem XDB Java components if XDK is also loaded
Rem =====================================================================
BEGIN
  IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
     :initfile := dbms_registry.script('XML', '@catxdbj.sql');
  ELSE
     :initfile := '@nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@&init_file

Rem Load XQuery java classes ONLY if XDK java is loaded
BEGIN
  IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
     :initfile := dbms_registry.script('XML', '@initxqry.sql');
  ELSE
     :initfile := '@nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@&init_file

Rem =====================================================================
Rem Scheduler Java code
Rem =====================================================================

BEGIN
  IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
     :initfile := 'initscfw.sql';
  ELSE
     :initfile := 'nothing.sql';
  END IF;
END;
/
SELECT :initfile FROM DUAL;
@@&init_file

Rem =====================================================================
Rem Only set status to LOADED if JServer is loaded
Rem =====================================================================

Rem for invalid object diagnostic output
SET SERVEROUTPUT ON        

BEGIN
   IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
      dbms_registry.loaded('CATJAVA');
      dbms_registry_sys.validate_catjava;
   END IF;
END;
/
SET SERVEROUTPUT OFF

Rem *********************************************************************
Rem END CATJAVA.SQL 
Rem *********************************************************************
