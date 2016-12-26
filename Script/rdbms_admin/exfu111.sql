Rem
Rem $Header: rdbms/admin/exfu111.sql /st_rdbms_11.2.0/1 2013/02/12 13:38:21 sdas Exp $
Rem
Rem exfu111.sql
Rem
Rem Copyright (c) 2008, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      exfu111.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdas        02/11/13 - upgrade must create RLM$ROWIDTAB if absent
Rem    ayalaman    07/22/08 - compiled sparse
Rem    ayalaman    02/25/08 - component upgrade to 11.2
Rem    ayalaman    02/25/08 - Created
Rem

REM
REM Upgrade of EXF from 11.1.0 to 11.2
REM

grant select on dba_tab_columns to exfsys; 

create or replace type exfsys.exf$csicode as object (code int, arg varchar2(1000)); 
/

grant execute on exfsys.exf$csicode to public; 

create or replace type exfsys.exf$csiset as varray (1000) of exf$csicode; 
/
 
grant execute on exfsys.exf$csiset to public; 

---- RLM$ROWIDTAB : Used to represent a list of rowids 
create or replace type exfsys.rlm$rowidtab is table of VARCHAR2(38);
/

grant execute on exfsys.rlm$rowidtab to public;

-- iterate over all existing predicate tables and add the columns -- 
declare
  CURSOR predtabs IS 
    select idxowner, idxpredtab from exfsys.exf$idxsecobj; 
begin
  for plst in predtabs loop
  begin
    execute immediate 'alter table '||
      dbms_assert.enquote_name(plst.idxowner, false)||'.'||
      dbms_assert.enquote_name(plst.idxpredtab, false)||
            ' add (exf$cmplsprs exfsys.exf$csiset)'; 
  exception 
    when others then 
      if (SQLCODE != -01430) then 
        raise; 
      end if; 
  end; 
  end loop; 
end;
/
    
