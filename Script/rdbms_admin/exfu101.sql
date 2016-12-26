Rem
Rem $Header: exfu101.sql 11-nov-2006.11:25:07 ayalaman Exp $
Rem
Rem exfu101.sql
Rem
Rem Copyright (c) 2004, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfu101.sql - Upgrade script for Expression Filter 
Rem
Rem    DESCRIPTION
Rem      Upgrade script for Expression Filter component from release 
Rem      10.1.0. 
Rem
Rem    NOTES
Rem      Expression Filter is first introduced in 10.1.0. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    11/08/06 - exception handling
Rem    ayalaman    11/16/05 - insert new line at the end 
Rem    ayalaman    08/11/05 - add upgrade script from 10.2 
Rem    ayalaman    05/07/05 - spatial operators in stored expressions 
Rem    ayalaman    03/10/05 - revoke privs on indextype and oper impl. 
Rem    ayalaman    11/01/04 - validation script into sys 
Rem    ayalaman    07/23/04 - recreate xml_tag type body 
Rem    ayalaman    04/30/04 - extensible optim support 
Rem    ayalaman    04/30/04 - namespace support in xpath expressions 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    03/24/04 - Created
Rem


REM
REM Upgrade of EXF from 10.1.0 to 10.2
REM

REM 
REM Drop obsolete objects from 10.1.0 
REM 
--- Will be created as a temporary table ---
drop table exf$javamsg;

REM 
REM Create new tables and indexes
REM 

--- add sdo_widist as one of the valid operators ---
declare 
  widvar VARCHAR2(40); 
begin
  select operstr into widvar from exfsys.exf$validioper where operstr = 'SDO_WIDIST';
exception
  when no_data_found then
    insert into exf$validioper values ('SDO_WIDIST');
end;
/


--- Temporary table for returning errors from Java implementation.
create global temporary table exf$javamsg
(
  code       VARCHAR2(15),
  message    VARCHAR2(500)
) on commit preserve rows;

--- extensible optimizer support ---
create table exf$parameter
(num         NUMBER, 
 name        VARCHAR2(64), 
 valtype     NUMBER,            --- 1 for number; 2 for varchar
 value       VARCHAR2(512),
 constraint dup_parameter primary key (num));

truncate table exf$parameter;

insert into exf$parameter (num, name, valtype, value) values 
       (1, 'dynamic_query_cpu_cost', 1, 1000000);
insert into exf$parameter (num, name, valtype, value) values 
       (2, 'pred_eval_cpu_cost', 1, 100000);

create index exf$expsetidx on exf$idxsecobj(idxesettab, idxesetcol);

--- plan table for the extensible optimizer ---
@@utlxplan

alter table plan_table rename to exf$plan_table;

begin
  execute immediate 'alter table exf$plan_table add constraint
        plan_stmt_id primary key (statement_id, id)';
exception
  when others then 
    if (SQLCODE != -2260) then
      raise; 
    end if; 
end;
/


REM
REM Alter tables to add/change columns and constraints  
REM

--- attribute set with default values attributes ---
alter table exf$attrlist add(attrdefvl   VARCHAR2(100));


--- extensible optimizer support ---
alter table exf$idxsecobj add (optfccpuct  NUMBER,     -- func based cpu cost/expr
                               optfcioct   NUMBER,     -- func based i/o cost/expr
                               optixselvt  NUMBER,     -- index selectivity %
                               optixcpuct  NUMBER,     -- index based cpu cost 
                               optixioct   NUMBER,     -- index based i/o cost    
                               optptfscct  NUMBER,     -- pred tab FFS cost 
                               idxpquery   CLOB);       

--- the current ordering of columns is not perfect (owing to ADD columns)
--- But lets set an INCLUDING column with the hopes of using it ---
alter table exf$idxsecobj including optptfscct overflow;

--- namespace support for xpath expressions
alter table exf$defidxparam add(xmlnselp  NUMBER default null);
alter table exf$esetidxparam add(xmlnselp  NUMBER default null);
alter table exf$predattrmap add(xmlnselp  NUMBER default null);

REM
REM Modify static tables for the new release (None)
REM

REM
REM UPDATE existing columns as needed to reflect new algorithms. (None)
REM
        
REM
REM Create new types for the release (None)
REM

REM
REM ALTER existing types to add/change attributes and methods (None)
REM 

--- namespace support for xpath expressions
alter type exf$xpath_tag modify attribute (tag_name VARCHAR2(350)) cascade;

create or replace type body exf$xpath_tag as
  constructor function exf$xpath_tag(tag_name varchar2)
    return self as result is
  begin
    self.tag_name := tag_name;
    self.tag_indexed := null;
    self.tag_type := null;
    return;
  end;
end;
/

REM
REM Drop any obsolete packages/procedures
REM

drop package dbms_expfil_reg;

REM
REM GRANT any additional privileges required by EXFSYS (None) 
REM 
/*** Revoke privileges on indextype and operator implementation in 10.2 ***/
---bug 4114159 ---
begin
  execute immediate 'revoke execute on ExpressionIndexMethods from public';
exception
  when others then 
    if (SQLCODE != -1927) then 
      raise;
    end if; 
end;
/

begin
  execute immediate 'revoke execute on ExpressionIndexStats from public';
exception
  when others then 
    if (SQLCODE != -1927) then 
      raise;
    end if; 
end;
/

begin
  execute immediate 'revoke execute on exfsys.EVALUATE_VV from public';
exception
  when others then 
    if (SQLCODE != -1927) then 
      raise;
    end if; 
end;
/

begin
  execute immediate 'revoke execute on exfsys.EVALUATE_VA from public';
exception
  when others then 
    if (SQLCODE != -1927) then 
      raise;
    end if; 
end;
/

begin
  execute immediate 'revoke execute on exfsys.EVALUATE_CV from public';
exception
  when others then 
    if (SQLCODE != -1927) then 
      raise;
    end if; 
end;
/

begin
  execute immediate 'revoke execute on exfsys.EVALUATE_CA from public';
exception
  when others then 
    if (SQLCODE != -1927) then 
      raise;
    end if; 
end;
/



REM
REM  Call the upgrade script for next release
REM 

@@exfu102

