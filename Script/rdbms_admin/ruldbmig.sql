Rem
Rem $Header: ruldbmig.sql 25-feb-2008.11:30:20 ayalaman Exp $
Rem
Rem ruldbmig.sql
Rem
Rem Copyright (c) 2005, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      ruldbmig.sql - Migration script for Rules Manager (RUL)
Rem
Rem    DESCRIPTION
Rem      Migration script for the Rules Manager(RUL) component. 
Rem      This component was first introduced in 10.2
Rem
Rem    NOTES
Rem      None.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/25/08 - upgrade to 11.2
Rem    ayalaman    06/12/06 - add new packaged implementation 
Rem    ayalaman    10/06/05 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

REM Indicate that the upgrade of EXF has begun
EXECUTE dbms_registry.upgrading(comp_id=>'RUL', new_proc=>'VALIDATE_RUL');

REM Set current schema to EXFSYS
ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

REM Get the appropriate file name for upgrade
COLUMN :script_name NEW_VALUE comp_file NOPRINT
VARIABLE script_name VARCHAR2(12)

DECLARE 
  rulextver VARCHAR2(10) := substr(dbms_registry.version('RUL'),1,6);
BEGIN
  IF (rulextver='10.2.0') THEN
    :script_name := '@rulu102.sql';
  ELSIF (rulextver='11.1.0') THEN 
    :script_name := '@rulu111.sql'; 
  ELSE
    :script_name := dbms_registry.nothing_script;
  END IF;
END;
/

SELECT :script_name FROM DUAL;
@&comp_file

REM
REM Recreate the Java library in EXFSYS schema. 
REM (This is not optional for Expression Filter.)
REM
@@initexf.sql

REM
REM Recreate Public PL/SQL Package specifications
REM
@@rulpbs.sql

REM
REM Recreate the view definitions
REM
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
REM End of Upgrade (use the RDBMS release version number)
REM
EXECUTE dbms_registry.upgraded('RUL');

EXECUTE sys.validate_rul;

ALTER SESSION SET CURRENT_SCHEMA = SYS;


