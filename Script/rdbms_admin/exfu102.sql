Rem
Rem $Header: exfu102.sql 25-feb-2008.11:34:41 ayalaman Exp $
Rem
Rem exfu102.sql
Rem
Rem Copyright (c) 2005, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfu102.sql - Upgrade script for Expression Filter 
Rem
Rem    DESCRIPTION
Rem      Upgrade script for Expression Filter from release 10.2
Rem
Rem    NOTES
Rem      Upgrades the Expression Filter objects and tables to 
Rem      accommodate the new functionality introduced after 10.2
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/25/08 - upgrade to 11.2
Rem    ayalaman    02/18/06 - bug 5030164 
Rem    ayalaman    02/23/06 - upgrade fix 
Rem    ayalaman    02/02/06 - extend the column size 
Rem    ayalaman    09/19/05 - ayalaman_exf_contains_oper
Rem    ayalaman    08/11/05 - Created
Rem

REM
REM Upgrade of EXF from 10.2.0 to 11.0
REM 

REM
REM Drop obsolete objects from 10.2
REM 


REM 
REM Create new tables and indexes
REM 

--
--- Support for CONTAINS operator in stored expressions
--

-- add CONTAINS as one of the valid operators --
declare 
  widvar VARCHAR2(40); 
begin
  select operstr into widvar from exfsys.exf$validioper where operstr = 'CONTAINS';
exception
  when no_data_found then
    insert into exf$validioper values ('CONTAINS');
end;
/

REM
REM ALTER tables to add/change columns and constraints for the new release
REM

--
--- Support for CONTAINS operator in stored expressions
--

-- add overflow segment 
-- to avoid OVERFLOW already exist error use exception handling --
begin
 EXECUTE IMMEDIATE 'alter table exf$attrlist add overflow';
exception 
 when others then 
   if (SQLCODE != -25197) then 
     raise;
   end if;
end;
/

alter table exf$attrlist including attrprop overflow; 

-- add the column to store text preferences --
alter table exf$attrlist add (attrtxtprf  VARCHAR2(1000)); 

BEGIN
  EXECUTE IMMEDIATE 'alter table exfsys.exf$attrlist modify (attrtptab VARCHAR2(75))';
EXCEPTION when others then
  null;
END;
/

REM
REM Modify static tables for the new release
REM

REM
REM UPDATE existing columns as needed to reflect new algorithms, etc.
REM

REM
REM Create new types for the release
REM

--
--- Support for CONTAINS operator in stored expressions
--

-- EXF$TEXT : Text datatype for CONTAINS operator 
create type exfsys.exf$text as object (
   preferences  VARCHAR2(1000)
);
/

create or replace public synonym exf$text for exfsys.exf$text;

grant execute on exf$text to public;



REM
REM ALTER existing types to add/change attributes and methods for the new release
REM

REM
REM Drop any onsolete packages/procedures
REM

REM
REM GRANT any additional privileges required by EXFSYS for the new release
REM

REM
REM Call the upgrade script for next release 
REM
@@exfu111.sql

