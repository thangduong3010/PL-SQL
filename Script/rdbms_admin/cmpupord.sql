Rem
Rem $Header: rdbms/admin/cmpupord.sql /st_rdbms_11.2.0/1 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem cmpupord.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupord.sql - CoMPonent UPgrade ORD components
Rem
Rem    DESCRIPTION
Rem      Upgrade interMedia and Spatial
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/29/13 - bug_16816410_11204: add table name to errorlogging
Rem                           syntax
Rem    cdilling    12/14/06 - remove extra sdo timestamp
Rem    cdilling    10/05/06 - for XE upgrade locator instead of SDO
Rem    cdilling    06/08/06 - add support for error logging 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
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
Rem Upgrade Intermedia
Rem =====================================================================

Rem Set identifier to ORDIM for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'ORDIM';

SELECT dbms_registry_sys.dbupg_script('ORDIM') AS dbmig_name FROM DUAL;
@&dbmig_file

Rem If Spatial upgrade,
Rem    first install ORDIM if it is not loaded
BEGIN
  IF dbms_registry.is_loaded('ORDIM') IS NULL AND
     dbms_registry.is_loaded('SDO') IS NOT NULL THEN
     :dbinst_name := dbms_registry_server.ORDIM_path || 'imupins.sql';
     EXECUTE IMMEDIATE 
          'CREATE USER si_informtn_schema IDENTIFIED BY ordsys ' ||
          'ACCOUNT LOCK PASSWORD EXPIRE ' ||
          'DEFAULT TABLESPACE SYSAUX';
     INSERT INTO sys.registry$log -- indicate start time
                (cid, namespace, operation, optime) 
            VALUES ('ORDIM', SYS_CONTEXT('REGISTRY$CTX','NAMESPACE'), 
                       -1, SYSTIMESTAMP);
     COMMIT;
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Spatial
Rem =====================================================================

Rem Set identifier to SDO for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'SDO';


SELECT dbms_registry_sys.dbupg_script('SDO') AS dbmig_name FROM DUAL;
@&dbmig_file

Rem First check if SDO is not loaded and an XE database
Rem where the MDSYS schema exists.
Rem If all these are true, then call locdbmig.sql
Rem to invoke locator upgrade script
VARIABLE loc_name VARCHAR2(30);
DECLARE
   p_name VARCHAR(128);
   p_edition VARCHAR2 (128);
BEGIN
   :loc_name := '@nothing.sql';
   IF dbms_registry.is_loaded('SDO') IS NOT NULL THEN
      RETURN;
   END IF;
   EXECUTE IMMEDIATE
      'SELECT edition FROM registry$ WHERE cid=''CATPROC'''
   INTO p_edition;
   BEGIN  -- is XE, check for MDSYS schema
      SELECT name INTO p_name FROM user$ WHERE name='MDSYS';
      :loc_name := '?/md/admin/locdbmig.sql';
   EXCEPTION WHEN NO_DATA_FOUND THEN NULL;  -- no MDSYS with XE;
   END;
EXCEPTION WHEN OTHERS THEN NULL;  -- error selecting edition column
END;
/
SELECT :loc_name AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;
