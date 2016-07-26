Rem
Rem $Header: rdbms/admin/catnoexf.sql /st_rdbms_11.2.0/1 2013/02/12 13:38:21 sdas Exp $
Rem
Rem catnoexf.sql
Rem
Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnoexf.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jerrede     01/02/13 - Add the Removal of Rules Manager
Rem    ayalaman    02/25/08 - cleanup public synonyms
Rem    ayalaman    04/19/04 - cleanup export dependeny actions 
Rem    ayalaman    11/19/02 - registry entries
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/06/02 - 
Rem    ayalaman    09/06/02 - Created
Rem

REM
REM Drop Rules Manager if present.  Rules Manager must be
REM done first before we drop Expression Filter.
REM
COLUMN  :rul_name NEW_VALUE rul_file NOPRINT;
VARIABLE rul_name VARCHAR2(30)
BEGIN

   IF (dbms_registry.is_loaded('RUL') IS NOT NULL) THEN
       :rul_name := '@catnorul.sql';                -- RUL exists in DB
   ELSE
       :rul_name := dbms_registry.nothing_script;   -- No RUL
   END IF;

END;
/

SELECT :rul_name FROM DUAL;
@&rul_file 


REM 
REM Drop the Expression Filter user with cascade option 
REM 
EXECUTE dbms_registry.removing('EXF');
drop user exfsys cascade;
drop package sys.exf$dbms_expfil_syspack;
begin
  -- since this is a fresh install, delete any actions left behind --
  -- from past installations --
  delete from sys.expdepact$ where schema = 'EXFSYS'
    and package = 'DBMS_EXPFIL_DEPASEXP';
  delete from sys.exppkgact$ where package = 'DBMS_EXPFIL_DEPASEXP'
    and schema = 'EXFSYS';
end;
/

-- drop public synonyms -- 
declare
  cursor cur1 is select synonym_name from all_synonyms where owner = 'PUBLIC' and table_owner = 'EXFSYS'; 
begin
  for c1 in cur1 loop
     EXECUTE IMMEDIATE 'drop public synonym '||dbms_assert.enquote_name(c1.synonym_name, false);
  end loop; 
end;
/

execute sys.dbms_java.dropjava('-s rdbms/jlib/ExprFilter.jar');

begin
  dbms_registry.removed('EXF');
exception 
  when others then null;
end;
/

