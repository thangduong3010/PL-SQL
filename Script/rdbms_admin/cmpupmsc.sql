Rem
Rem $Header: rdbms/admin/cmpupmsc.sql /st_rdbms_11.2.0/2 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem cmpupmsc.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupmsc.sql - CoMPonent UPgrade MiSC components
Rem
Rem    DESCRIPTION
Rem      Upgrade other components dependent on both XDB and Java
Rem      Ultrasearch, Expression Filter, Rule Manager
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/29/13 - bug_16816410_11204: add table name to
Rem                           errorlogging syntax
Rem    jerrede     04/02/12 - Fix Lrg 6789157 xdb invalidated XMLTYPE
Rem    sanagara    02/17/09 - move OWM here from cmpupnjv.sql
Rem    cdilling    07/30/08 - remove ultrasearch is not "used" 
Rem    rburns      02/17/07 - rework apex script
Rem    cdilling    12/18/06 - XOQ XDB dependency
Rem    rburns      09/20/06 - add APEX upgrade
Rem    cdilling    06/08/06 - add support for error logging 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem


Rem clear package state before running component scripts
Rem DBMS_STATS now depends on xml stuff (xmltype, extract ...)
Rem Some of the DDLs in XDB upgrade invalidates dbms_stats.
Rem The following clears the package state and avoids ORA-4068.
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
Rem Upgrade Oracle Workspace Manager
Rem =====================================================================

Rem Set identifier to OWM for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'OWM';

SELECT dbms_registry_sys.dbupg_script('OWM') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Oracle Data Mining
Rem =====================================================================

Rem Set identifier to ODM for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'ODM';

SELECT dbms_registry_sys.dbupg_script('ODM') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('ODM') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Remove Ultra Search as it is no longer supported in 11.2
Rem =====================================================================

Rem If Ultra Search user exists but Ultra Search is not "used" then
Rem automatically invoke wkremov.sql script to clean up Ultra Search.
Rem
Rem If Ultra Search user exists but Ultra Search is "used" then
Rem write a WARNING message to the Oracle_Server.log telling the user
Rem to backup the database and run the /rdbms/admin/wkremov.sql script.
Rem
Rem Ultra Search is not used when three conditions are satisfied:
Rem
Rem Condition 1) Index is empty
Rem
Rem  SQL> select count(1) from wk_test.dade difr$wk$doc_path_idx$i;
Rem
Rem COUNT(1)
Rem ----------
Rem     0
Rem
Rem Condition 2) wk_test.wk$url table is empty
Rem
Rem  SQL> select count(1) from wk_test.wk$url;
Rem
Rem  COUNT(1)
Rem  ----------
Rem     0
Rem
Rem  Condition 3) No custom data source created
Rem
Rem SQL> select count(1) from wksys.wk$_data_source
Rem   2> where DS_NAME not in ('Email Source','calendar','files','mail','web');
Rem
Rem   COUNT(1)
Rem  ----------
Rem     0 

DECLARE
  n number := 0;
  index_count number := 0;
  table_count number := 0;
  data_count number  := 0;

BEGIN
  -- Determine if WKSYS user exists
  SELECT count(*) INTO n FROM all_users WHERE username = 'WKSYS';
  BEGIN   
    -- The WKSYS user does not exist so there is no script to invoke
    IF (n = 0) THEN
     :dbinst_name := dbms_registry.nothing_script;        
    ELSE
       -- WKSYS User does exist 
       :dbinst_name := dbms_registry_server.WK_path || 'wkremov.sql';
       -- Check if index is empty        
       EXECUTE IMMEDIATE 
          'select count(1) into index_count from wk_test.dr$wk$doc_path_idx$i';
       -- Check if table is empty
       EXECUTE IMMEDIATE
          'select count(1) into table_count from wk_test.wk$url';
       -- Check if no custom data source created
       EXECUTE IMMEDIATE
          'select count(1) into data_count from wksys.wk$_data_source
            where DS_NAME 
            not in (''Email Source'',''calendar'',''files'',''mail'',''web'')';
       -- When all the conditions are met, then ultra search is used
       IF (index_count = 0) or (table_count = 0) or (data_count = 0)
       THEN
          :dbinst_name := dbms_registry.nothing_script;   
          dbms_system.ksdwrt(dbms_system.alert_file + dbms_system.trace_file,
  'WARNING: Ultra Search is not supported in 11.2 and must be removed by 
  running /rdbms/admin/wkremov.sql. If you need to preserve Ultra Search data, 
  please perform a manual cold backup prior to upgrade.');
       END IF;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END;
END;
/
Rem Set identifier to WK for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'WK';

SELECT :dbinst_name FROM DUAL;
@&dbinst_file

SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Expression Filter
Rem =====================================================================

Rem Set identifier to EXF for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'EXF';

SELECT dbms_registry_sys.dbupg_script('EXF') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Rule Manager
Rem =====================================================================

Rem Set identifier to RUL for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'RUL';

SELECT dbms_registry_sys.dbupg_script('RUL') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('RUL') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Application Express
Rem =====================================================================

Rem Set identifier to APEX for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'APEX';

SELECT dbms_registry_sys.dbupg_script('APEX') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('APEX') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade OLAP API
Rem =====================================================================

Rem Set identifier to XOQ for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'XOQ';

SELECT dbms_registry_sys.dbupg_script('XOQ') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;
