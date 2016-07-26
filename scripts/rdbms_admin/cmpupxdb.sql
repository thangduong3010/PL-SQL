Rem
Rem $Header: rdbms/admin/cmpupxdb.sql /st_rdbms_11.2.0/1 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem cmpupxdb.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupxdb.sql - CoMPonent UPgrade XDB
Rem
Rem    DESCRIPTION
Rem      Upgrade XML, CONTEXT, and XDB
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/29/13 - bug_16816410_11204: add table name to errorlogging
Rem                           syntax
Rem    spetride    04/29/08 - add secure_file option for catqm
Rem    cdilling    12/18/06 - add registry log start for xdb install
Rem    rburns      07/19/06 - include XML 
Rem    cdilling    06/08/06 - add support for error logging 
Rem    tcruanes    06/10/06 - reset package state to avoid ORA-04068 
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
Rem Upgrade Text
Rem =====================================================================

Rem Set identifier to CONTEXT for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'CONTEXT';

SELECT dbms_registry_sys.dbupg_script('CONTEXT') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Oracle XML Database
Rem =====================================================================

Rem If XDB install was incomplete (status still LOADING),
Rem uninstall first and then re-install. 

BEGIN
  IF dbms_registry.status('XDB') = 'LOADING'  THEN 
    :dbinst_name := dbms_registry_server.XDB_path || 'catnoqm.sql';
  ELSE
     :dbinst_name := dbms_registry.nothing_script;
  END IF;
END;
/ 
SELECT :dbinst_name FROM DUAL;
@&dbinst_file

Rem If XML, Intermedia or Spatial upgrade, first install XDB if it is
Rem not loaded. Otherwise, if XDB is in the database, run the XDB
Rem upgrade script

DECLARE
  temp_ts  VARCHAR2(30);
BEGIN
  IF dbms_registry.is_loaded('XDB') IS NULL AND
      (dbms_registry.is_loaded('XML') IS NOT NULL OR
       dbms_registry.is_loaded('SDO') IS NOT NULL OR
       dbms_registry.is_loaded('ORDIM') IS NOT NULL) THEN
     SELECT temporary_tablespace INTO temp_ts FROM dba_users
            WHERE username='SYS'; -- use SYS temporary tablespace
     :dbinst_name := dbms_registry_server.XDB_path || 
                     'catqm.sql XDB SYSAUX ' || temp_ts || ' YES'; 
     INSERT INTO sys.registry$log -- indicate start time
                (cid, namespace, operation, optime) 
            VALUES ('XDB', SYS_CONTEXT('REGISTRY$CTX','NAMESPACE'), 
                       -1, SYSTIMESTAMP);
     COMMIT;
  ELSE
     :dbinst_name := dbms_registry_sys.dbupg_script('XDB');
  END IF;
END;
/
Rem Set identifier for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'XDB';

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

Rem DBMS_STATS now depends on xml stuff (xmltype, extract ...)
Rem Some of the DDLs in XDB upgrade invalidates dbms_stats.
Rem The following clears the package state and avoids ORA-4068.
execute dbms_session.reset_package;

