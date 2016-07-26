Rem
Rem $Header: rdbms/admin/cmpupnxb.sql /st_rdbms_11.2.0/1 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem cmpupnxb.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupnxb.sql - CoMPonent UPgrade Non-XDB dependent components
Rem
Rem    DESCRIPTION
Rem       Upgrade CATJAVA
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/29/13 - bug_16816410_11204: add table name to errorlogging
Rem                           syntax
Rem    cdilling    12/18/06 - XOQ XDB dependency
Rem    rburns      07/19/06 - XOQ Java dependency 
Rem    cdilling    06/08/06 - add support for errorlogging 
Rem    rburns      05/23/06 - parallel upgrade 
Rem    rburns      05/23/06 - Created
Rem

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
Rem Java Supplied Packages
Rem =====================================================================

Rem Set identifier to CATJAVA for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'CATJAVA';

SELECT dbms_registry_sys.dbupg_script('CATJAVA') AS dbmig_name FROM DUAL;
@&dbmig_file

Rem If JAVAVM install for dependencies no CATJAVA, load it
BEGIN
  IF dbms_registry.is_loaded('CATJAVA') IS NULL AND
     dbms_registry.is_loaded('JAVAVM') IS NOT NULL THEN
     :dbinst_name := dbms_registry_server.CATJAVA_path || 'catjava.sql';
     INSERT INTO sys.registry$log -- indicate start time
                (cid, namespace, operation, optime) 
            VALUES ('CATJAVA', SYS_CONTEXT('REGISTRY$CTX','NAMESPACE'), 
                       -1, SYSTIMESTAMP);
     COMMIT;
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;

