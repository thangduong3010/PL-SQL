Rem
Rem $Header: catrul.sql 13-may-2005.09:35:37 ayalaman Exp $
Rem
Rem catrul.sql
Rem
Rem Copyright (c) 2004, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catrul.sql - Top level script to load Rules Manager
Rem
Rem    DESCRIPTION
Rem      The Rules Manager stores, manages, and enforces Event-Condition-
Rem      Action rules in the database. This relies on the Expression 
Rem      Filter functionality and the Expression Filter should be
Rem      installed prior to installing Rules Manager
Rem
Rem    NOTES
Rem      The 'XDB' component ('Oracle XML Database') should be installed
Rem      proir to the Rules Manager implementation (use catqm.sql to install
Rem      XDB).
Rem      See Documentation for additional notes 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    05/13/05 - add new packaged implementation 
Rem    ayalaman    10/13/05 - grant change notification privs 
Rem    ayalaman    09/30/04 - Rule to Rules 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    04/16/04 - xdb dependency 
Rem    ayalaman    04/02/04 - Created
Rem


REM 
REM Rules Manager depends on XDB functionality for parsing 
REM the rule conditions and rule set properties. Make sure 
REM that XDB is installed 
REM 
WHENEVER SQLERROR EXIT;
begin
  IF (dbms_registry.version('XDB') is null) THEN 
    raise_application_error(-20000, 'XDB component not found. '||
        'XDB should be installed prior to Rules Manager installation.');
  END IF;
end;
/
WHENEVER SQLERROR CONTINUE;

REM 
REM Rules Manager depends on the Expression Filter functionality. 
REM Install the expression filter if it is not already installed.
REM We will not check the status/version of Expression Filter if 
REM it is already installed.
REM 

COLUMN :script_name NEW_VALUE comp_file NOPRINT
VARIABLE script_name VARCHAR2(50)

BEGIN
  IF (dbms_registry.version('EXF') is null) THEN
    :script_name := '@catexf.sql';
  ELSE
    :script_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :script_name FROM DUAL;
@&comp_file

GRANT execute on dbms_lock to EXFSYS;

REM 
REM This component uses the Expression Filter schema 
REM Running as sysdba : set current schema to EXFSYS.
REM 
ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

begin
  sys.dbms_registry.loading('RUL', 'Oracle Rules Manager',
      'validate_rul','EXFSYS');
end;
/
REM 
REM Java Implementations required are part of Expression Filter installation. 
REM As long as the Expression Filter and Rules Manager are for the same 
REM DB version, we do not need to reload the Java implementations 
REM @@initexf.sql

REM
REM The rules manager APIs need additional privs to be granted for EXFSYS.
REM
grant execute on dbms_change_notification to exfsys;

REM
REM Create required schema objects in the EXFSYS Schema
REM 
--- Create object types required for the Rules Manager
@@rultyp.sql

--- Create Rules Manager Dictionary/Static tables
@@rultab.sql

--- Create Rules Manager Public PL/SQL package specification 
@@rulpbs.sql

--- Create Rules Manager Catalog views 
@@rulview.sql

REM
REM Create package implementations
REM 
prompt .. installing Rules Manager Packages
@@rulimpvs.plb

@@rulpkpvs.plb

--- rule set export import support 
@@ruleipvs.plb

REM
REM Validate Rules Manager installation
REM 
EXECUTE sys.dbms_registry.loaded('RUL');

REM 
REM Validation for Rules Manager and Expression Filter is same.
REM 
EXECUTE sys.validate_rul;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

