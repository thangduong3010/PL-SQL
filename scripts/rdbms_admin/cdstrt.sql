Rem
Rem $Header: rdbms/admin/cdstrt.sql /st_rdbms_11.2.0/1 2010/08/03 16:53:57 skabraha Exp $
Rem
Rem cdstrt.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cdstrt.sql - Catalog STaRT actions
Rem
Rem    DESCRIPTION
Rem      Set up environment for running Catalog sql scripts.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    skabraha    07/29/10 - Backport skabraha_bug-9928461 from main
Rem    skabraha    06/10/10 - reset older ver types to valid after standard
Rem    badeoti     10/09/08 - 7394500: reset XDB views to dummy def only when
Rem                           necessary
Rem    rburns      10/23/06 - add session script
Rem    rburns      10/25/06 - add BYTE semantics
Rem    cdilling    08/04/06 - add utlraw
Rem    rburns      05/22/06 - add timestamp 
Rem    rburns      05/18/06 - add xdb dummy views 
Rem    cdilling    05/04/06 - Created
Rem

WHENEVER SQLERROR EXIT;         
 
DOC 
###################################################################### 
###################################################################### 
    The following statement will cause an "ORA-01722: invalid number" 
    error and terminate the SQLPLUS session if the user is not SYS.  
    Disconnect and reconnect with AS SYSDBA. 
###################################################################### 
###################################################################### 
# 
 
SELECT TO_NUMBER('MUST_BE_AS_SYSDBA') FROM DUAL 
WHERE USER != 'SYS'; 

Rem Run CATALOG and CATPROC session initialization script
@@catpses.sql

WHENEVER SQLERROR CONTINUE;

SELECT 'COMP_TIMESTAMP CATALG_BGN ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ') ||
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

rem Load PL/SQL Package STANDARD first, so views can depend upon it
@@standard
@@dbmsstdx

Rem Load registry so catalog component can be defined
@@catcr

BEGIN
   dbms_registry.loading('CATALOG', 'Oracle Database Catalog Views',
        'dbms_registry_sys.validate_catalog');
END;
/

Rem Dummy XDB views for all_objects
Rem (bug 7394500) if necessary
Rem Use a trial query for last column added to all_xml_schemas or all_xml_schemas2

VARIABLE dbdummy_name VARCHAR2(256)
COLUMN :dbdummy_name NEW_VALUE dbdummy_file NOPRINT

DECLARE
  dummied varchar2(4000);
  xdb_version registry$.version%type;
  catalog_version registry$.version%type;
BEGIN
  :dbdummy_name := dbms_registry_server.XDB_path || 'nothing.sql';
  
  EXECUTE IMMEDIATE 'select hidden from ALL_XML_SCHEMAS where rownum<= 1'
  into dummied ;

  EXECUTE IMMEDIATE 'SELECT version FROM sys.registry$ where cid=''XDB'''
  into xdb_version ;
 
  EXECUTE IMMEDIATE 'SELECT version FROM sys.registry$ where cid=''CATALOG'''
  into catalog_version ;
  
  IF xdb_version IS NULL or xdb_version != catalog_version THEN
    :dbdummy_name := dbms_registry_server.XDB_path || 'catxdbdv.sql';
  ELSE
    :dbdummy_name := dbms_registry_server.XDB_path || 'nothing.sql';
  END IF;

EXCEPTION
  WHEN others THEN
    :dbdummy_name := dbms_registry_server.XDB_path || 'catxdbdv.sql';
END;
/

SELECT :dbdummy_name FROM DUAL;
@&dbdummy_file

desc all_xml_schemas

Rem End bug 7394500 fixes

Rem  Define UTL_RAW package/functions needed by catexp
@@utlraw
