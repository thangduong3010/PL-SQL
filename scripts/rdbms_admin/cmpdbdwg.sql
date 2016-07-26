Rem $Header: rdbms/admin/cmpdbdwg.sql /main/17 2010/05/10 17:57:07 vmedi Exp $
Rem
Rem cmpdbdwg.sql
Rem
Rem Copyright (c) 1999, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cmpdbdwg.sql - downgrade SERVER components to original release
Rem
Rem    DESCRIPTION
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     05/07/10 - disable xdk schema caching for inserts into csx
Rem                           tables during migrations
Rem    cdilling    12/23/09 - fix javavm downgrade status
Rem    cmlim       03/12/08 - support major release downgrade from 11.2 to 11.1
Rem    rburns      01/03/08 - temp remove component check 
Rem                         - and remove udjvmrm.sql for 11.1 downgrade only 
Rem    rburns      08/15/07 - move component check out of catdwgrd.sql
Rem    cdilling    05/21/07 - add support for apex downgrade scripts
Rem    cdilling    12/07/06 - add Data Vault
Rem    cdilling    12/22/06 - fix RAC downgrade version
Rem    rburns      11/17/05 - add RUL 
Rem    rburns      03/14/05 - use dbms_registry_sys
Rem    rburns      01/18/05 - comment out htmldb for 10.2 
Rem    rburns      11/11/04 - move CONTEXT 
Rem    rburns      11/08/04 - add HTMLDB 
Rem    rburns      07/01/04 - Fix RAC downgrade version 
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      02/04/04 - Created

Rem Setup component script filename variable
COLUMN dbdwg_name NEW_VALUE dbdwg_file NOPRINT;

-- set xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context forever, level 0x8000';

Rem ======================================================================
Rem Downgrade RUL
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('RUL') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('RUL') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade EM
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('EM') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('EM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade EXF
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('EXF') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('EXF') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade APEX
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('APEX') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('APEX') AS timestamp FROM DUAL;

Rem =====================================================================
Rem Downgrade DV
Rem =====================================================================

SELECT dbms_registry_sys.dbdwg_script('DV') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('DV') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLS
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('OLS') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('OLS') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Ultrasearch
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('WK') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('WK') AS timestamp FROM DUAL;
   
Rem ======================================================================
Rem Downgrade Spatial
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('SDO') AS dbdwg_name FROM DUAL;
@&dbdwg_file 
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Intermedia
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('ORDIM') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLAP API
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XOQ') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('XOQ') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLAP Catalog
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('AMD') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('AMD') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade OLAP Analytic Workspace
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('APS') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('APS') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Messaging Gateway
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('MGW') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('MGW') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Oracle Data Mining
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('ODM') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('ODM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Oracle Workspace Manager
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('OWM') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade RAC (no dictionary objects)
Rem ======================================================================

SET VERIFY OFF
BEGIN
   IF dbms_registry.status('RAC') NOT IN ('REMOVING','REMOVED') THEN
      IF '&downgrade_file' = '1001000' THEN
         dbms_registry.downgraded('RAC','10.1.0');
      ELSIF '&downgrade_file' = '1002000' THEN
         dbms_registry.downgraded('RAC','10.2.0');
      END IF;
   END IF;
END;
/
SELECT dbms_registry_sys.time_stamp('RAC') AS timestamp FROM DUAL;
SET VERIFY ON

Rem ======================================================================
Rem Downgrade XDB - XML Database 
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XDB') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Text
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('CONTEXT') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade RDBMS java classes (CATJAVA)
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('CATJAVA') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('CATJAVA') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade XDK for Java
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XML') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade JServer (Last)
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('JAVAVM') AS dbdwg_name FROM DUAL;
@&dbdwg_file

Rem Remove Java system classes after components have been downgraded.
SELECT dbms_registry.script('JAVAVM', dbms_registry.script_path('JAVAVM') 
        || 'udjvmrm.sql') 
AS dbdwg_name FROM DUAL;
@&dbdwg_file

SELECT dbms_registry_sys.time_stamp('JAVAVM') AS timestamp FROM DUAL;

column comp_name format a35
SELECT comp_name, status, substr(version,1,10) as version from dba_registry
WHERE comp_id NOT IN ('CATPROC','CATALOG');

-- clear xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context off';

DOC
#######################################################################
#######################################################################

 All components in the above query must have a status of DOWNGRADED.
 If not, the following check will get an ORA-39709 error, and the
 downgrade will be aborted. Consult the downgrade chapter of the 
 Oracle Database Upgrade Guide and correct the component problem,
 then re-run this script.

#######################################################################
#######################################################################
#

WHENEVER SQLERROR EXIT;
-- uncomment when all components have 11.2->11.1 downgrade scripts working
--EXECUTE dbms_registry_sys.check_component_downgrades;
WHENEVER SQLERROR CONTINUE;

Rem ***********************************************************************
Rem END cmpdbdwg.sql
Rem ***********************************************************************

