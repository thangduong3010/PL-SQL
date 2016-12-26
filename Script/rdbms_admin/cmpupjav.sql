Rem
Rem $Header: rdbms/admin/cmpupjav.sql /st_rdbms_11.2.0/1 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem cmpupjav.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupjav.sql - CoMPonent UPgrade JAVa
Rem
Rem    DESCRIPTION
Rem      Upgrade Java
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/29/13 - bug_16816410_11204: add table name to errorlogging
Rem                           syntax
Rem    ssonawan    01/27/10 - Bug 9315778: use 'execute immediate'
Rem    ssonawan    08/13/09 - Bug 8746395: check JAVAVM before dropping appctx
Rem    ssonawan    07/16/09 - Bug 8687981: drop appctx package
Rem    rburns      01/16/08 - add reset package
Rem    cdilling    12/18/06 - add log entry on java install
Rem    rburns      07/19/06 - include XML 
Rem    cdilling    06/08/06 - add errorlogging support 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

-- clear package state before running component scripts
EXECUTE dbms_session.reset_package;

Rem =========================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =========================================================================

WHENEVER SQLERROR EXIT;

Rem check instance version and status; set session attributes
EXECUTE dbms_registry.check_server_instance;

Rem =========================================================================
Rem Continue even if there are SQL errors in remainder of script 
Rem =========================================================================

WHENEVER SQLERROR CONTINUE;

Rem Setup component script filename variables
COLUMN dbmig_name NEW_VALUE dbmig_file NOPRINT;
VARIABLE dbinst_name VARCHAR2(256)                   
COLUMN :dbinst_name NEW_VALUE dbinst_file NOPRINT

set serveroutput off

Rem =====================================================================
Rem Upgrade JServer
Rem =====================================================================

Rem Set identifier to JAVAVM for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'JAVAVM';

SELECT dbms_registry_sys.dbupg_script('JAVAVM') AS dbmig_name FROM DUAL;

@&dbmig_file
Rem If Intermedia, Ultrasearch, Spatial, Data Mining upgrade, 
Rem    first install JAVAVM if it is not loaded

BEGIN
  IF dbms_registry.is_loaded('JAVAVM') IS NULL AND
     (dbms_registry.is_loaded('ORDIM') IS NOT NULL OR
      dbms_registry.is_loaded('WK') IS NOT NULL OR
      dbms_registry.is_loaded('SDO') IS NOT NULL OR
      dbms_registry.is_loaded('EXF') IS NOT NULL OR
      dbms_registry.is_loaded('ODM') IS NOT NULL) THEN
     :dbinst_name := dbms_registry_server.JAVAVM_path || 'initjvm.sql';
     INSERT INTO sys.registry$log -- indicate start time
                (cid, namespace, operation, optime) 
            VALUES ('JAVAVM', SYS_CONTEXT('REGISTRY$CTX','NAMESPACE'), 
                       -1, SYSTIMESTAMP);
     COMMIT;  
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem BEGIN: Bug 8687981: drop appctx package
Rem =====================================================================

BEGIN
  IF dbms_registry.is_valid('JAVAVM',dbms_registry.release_version) = 1 THEN
    execute immediate 
       'call sys.dbms_java.dropjava(''-s rdbms/jlib/appctxapi.jar'')';
  END IF;
END;
/
 
Rem =====================================================================
Rem END: Bug 8687981: drop appctx package
Rem =====================================================================

Rem =====================================================================
Rem Upgrade XDK for Java
Rem =====================================================================

Rem Set identifier to XML for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'XML';

SELECT dbms_registry_sys.dbupg_script('XML') AS dbmig_name FROM DUAL;
@&dbmig_file

Rem If Intermedia upgrade, first install XML if it is not loaded
BEGIN
   IF dbms_registry.is_loaded('XML') IS NULL AND
      (dbms_registry.is_loaded('ORDIM') IS NOT NULL OR
       dbms_registry.is_loaded('SDO') IS NOT NULL) THEN
     :dbinst_name := dbms_registry_server.XML_path || 'initxml.sql';
     INSERT INTO sys.registry$log -- indicate start time
                (cid, namespace, operation, optime) 
            VALUES ('XML', SYS_CONTEXT('REGISTRY$CTX','NAMESPACE'), 
                       -1, SYSTIMESTAMP);
     COMMIT;  
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

