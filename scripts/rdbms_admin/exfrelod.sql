Rem
Rem $Header: exfrelod.sql 13-jun-2006.16:21:53 ayalaman Exp $
Rem
Rem exfrelod.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfrelod.sql - Reload Expression Filter packages, types and 
Rem                     Java implementations after a downgrade.
Rem
Rem    DESCRIPTION
Rem      The script reloads Expression Filter packages, types and
Rem      Java implementations after a downgrade.
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    06/13/06 - include indextype and operator compile 
Rem    ayalaman    10/15/04 - Use new validation script 
Rem    ayalaman    10/07/04 - new validation procedure in SYS 
Rem    ayalaman    03/24/04 - fix reload to include public package 
Rem    ayalaman    11/23/02 - ayalaman_exf_tests
Rem    ayalaman    11/19/02 - Created
Rem

WHENEVER SQLERROR EXIT
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

REM
REM Running as sysdba : set current schema to EXFSYS
REM
ALTER SESSION SET CURRENT_SCHEMA =EXFSYS;

begin 
  sys.dbms_registry.loading(comp_id=>'EXF', 
                            comp_name=>'Oracle Expression Filter', 
                            comp_proc=>'VALIDATE_EXF');
end;
/

REM
REM Create the Java library in EXFSYS schema
REM
prompt .. loading the Expression Filter Java library
@@initexf.sql

REM
REM Reload Public PL/SQL Package specifications
REM
@@exfpbs.sql

REM
REM Reload the view definitions
REM 

@@exfview.sql

REM
REM Create package/type implementations
REM
prompt .. creating Expression Filter package/type implementations
@@exfsppvs.plb

@@exfeapvs.plb

@@exfimpvs.plb

@@exfxppvs.plb

alter indextype expfilter compile;

alter operator evaluate compile;

EXECUTE sys.dbms_registry.loaded('EXF');

EXECUTE sys.validate_exf;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

