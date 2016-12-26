Rem
Rem $Header: rdbms/admin/cmpupnjv.sql /st_rdbms_11.2.0/1 2013/06/02 21:59:01 cmlim Exp $
Rem
Rem cmpupnjv.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpupnjv.sql - CoMPonent UPgrade Non-JaVa dependent components
Rem
Rem    DESCRIPTION
Rem      Upgrade RAC, OWM, MGW, OLAP
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cmlim       05/29/13 - bug_16816410_11204: add table name to errorlogging
Rem                           syntax
Rem    sanagara    02/17/09 - move OWM to cmpupmsc.sql
Rem    rburns      01/16/08 - add reset package
Rem    cdilling    12/07/06 - Data Vault
Rem    rburns      07/19/06 - XOQ Java dependency 
Rem    cdilling    06/08/06 - add error logging support 
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

-- clear package state before running component script
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
Rem Upgrade Real Application Clusters
Rem =====================================================================

Rem Set identifier to RAC for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'RAC';

SELECT dbms_registry_sys.dbupg_script('RAC') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Messaging Gateway
Rem =====================================================================

Rem Set identifier to MGW for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'MGW';

SELECT dbms_registry_sys.dbupg_script('MGW') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade OLAP Analytic Workspace
Rem =====================================================================

Rem Set identifier to APS for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'APS';

SELECT dbms_registry_sys.dbupg_script('APS') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade OLAP Catalog 
Rem =====================================================================

Rem Set identifier to AMD for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'AMD';

SELECT dbms_registry_sys.dbupg_script('AMD') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('AMD') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Oracle Label Security 
Rem =====================================================================

Rem Set identifier to OLS for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'OLS';


SELECT dbms_registry_sys.dbupg_script('OLS') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Oracle Data Vault
Rem =====================================================================

Rem Set identifier to DV for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'DV';


SELECT dbms_registry_sys.dbupg_script('DV') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('DV') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Upgrade Enterprise Manager Repository 
Rem =====================================================================

Rem Set identifier to EM for errorlogging
SET ERRORLOGGING ON TABLE SYS.REGISTRY$ERROR IDENTIFIER 'EM';

SELECT dbms_registry_sys.dbupg_script('EM') AS dbmig_name FROM DUAL;
@&dbmig_file
SELECT dbms_registry_sys.time_stamp('EM') AS timestamp FROM DUAL;

