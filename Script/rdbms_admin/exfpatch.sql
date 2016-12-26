Rem
Rem $Header: rdbms/admin/exfpatch.sql /st_rdbms_11.2.0/1 2013/05/31 06:30:31 sdas Exp $
Rem
Rem exfpatch.sql
Rem
Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      exfpatch.sql - Script to patch Expression Filter implementations.
Rem
Rem    DESCRIPTION
Rem      This script patches the Expression filter implementations.
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdas        05/30/13 - bug 16816166: define EXFSYS.RLM$ROWIDTAB if
Rem                           INVALID or absent
Rem    ayalaman    10/11/05 - include pbs script 
Rem    ayalaman    10/15/04 - Use new validation script 
Rem    ayalaman    10/07/04 - new validation procedure in SYS 
Rem    ayalaman    07/23/04 - forward merge: compile invalid objects 
Rem    ayalaman    11/23/02 - ayalaman_exf_tests
Rem    ayalaman    11/19/02 - Created
Rem

WHENEVER SQLERROR EXIT
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;
          
ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;
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

--- ensure EXFSYS.RLM$ROWIDTAB Type is VALID: required for Expression Filter
declare
  cnt number;
begin
  select count(*) into cnt 
    from all_objects 
   where owner='EXFSYS' and object_name='RLM$ROWIDTAB' and object_type='TYPE'
     and status='VALID';

  if (cnt = 0) then
  begin
    execute immediate 
      'create or replace type exfsys.rlm$rowidtab is table of VARCHAR2(38)';
    execute immediate 'grant execute on exfsys.rlm$rowidtab to public';
    exception when others then
      sys.dbms_output.put_line('EXFSYS.RLM$ROWIDTAB create, replace or grant execute FAILED. Conitnuing ...');
  end;
  end if;
end;
/

REM
REM Reload the view definitions
REM
@@exfview.sql

REM
REM Create package specifications
REM
@@exfpbs.sql

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
