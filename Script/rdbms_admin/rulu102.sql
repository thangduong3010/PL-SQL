Rem
Rem $Header: rulu102.sql 25-feb-2008.11:34:42 ayalaman Exp $
Rem
Rem rulu102.sql
Rem
Rem Copyright (c) 2005, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rulu102.sql - Upgrade script for Rules Manager
Rem
Rem    DESCRIPTION
Rem      UPgrade script for Rules Manager feature from release 10.2
Rem
Rem    NOTES
Rem      Upgrade the Rules Manager objects and tables to
Rem      accommodate the new functionality introduced after 10.2
Rem      Rules Manager was first introduced in 10.2 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/25/08 - upgrade to 11.2
Rem    ayalaman    03/19/07 - fix lrg 2898891
Rem    ayalaman    03/06/07 - duplicate collections
Rem    ayalaman    03/07/07 - restrict func index key length
Rem    ayalaman    06/12/06 - upgrade for aggregate events 
Rem    ayalaman    02/02/06 - shared primitive conditions table 
Rem    ayalaman    02/01/06 - upgrade bug with rul and change notification 
Rem    ayalaman    10/13/05 - privs for change notification 
Rem    ayalaman    09/19/05 - ayalaman_exf_contains_oper
Rem    ayalaman    08/19/05 - change notification support 
Rem    ayalaman    08/11/05 - Created
Rem

REM
REM Upgrade of RUL from 10.2.0 to 11.0
REM 

REM
REM Drop obsolete objects from 10.2
REM 

REM
REM ALTER tables to add/change columns and constraints for the new release
REM
--
--- Change notification events support
--
alter table rlm$dmlevttrigs add (dbcnfregid   NUMBER);
alter table rlm$dmlevttrigs add (dbcnfcbkprc  VARCHAR2(75)); 

--
--- Shared primitive rule conditions table support
--
alter table rlm$eventstruct add (evst_prct VARCHAR2(32)); 
alter table rlm$eventstruct add (evst_prcttls VARCHAR2(75)); 

--
--- aggregate events support
--
alter table rlm$primevttypemap add (havngattrs    VARCHAR2(4000)); 
alter table rlm$primevttypemap add (collcttab     VARCHAR2(32)); 
alter table rlm$primevttypemap add (grpbyattrs    VARCHAR2(1000)); 

REM 
REM Create new tables and indexes
REM 

--
--- aggregate events support
--
create table rlm$collgrpbyspec
(
  rset_owner   VARCHAR2(32), 
  rset_name    VARCHAR2(32), 
  primevttp    VARCHAR2(32),  -- dictionary name --
  grpattidx    NUMBER,
  attrname     VARCHAR2(100), -- quoted(if necc) name for the grp exprn
  evtattr      VARCHAR2(32), 
  CONSTRAINT rlm$grpbyspecpk PRIMARY KEY (rset_owner, rset_name, 
                                             primevttp, attrname), 
  CONSTRAINT rlm$grpbyspecfk FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name)  on delete cascade 
       initially deferred
) organization index overflow; 

drop table rlm$parsedcond; 

create global temporary table rlm$parsedcond 
(
  tagname     VARCHAR2(32),
  peseqpos    NUMBER, 
  tagvalue    VARCHAR2(4000)
);


create or replace function rlm$uniquetag(tag varchar2, pos int) return varchar2
  deterministic is
begin
  if (instr(tag, 'RLM$RCND_COLL') > 0) then
    return tag||pos;
  else
    return tag;
  end if;
end;
/

create unique index rlm$unqcondtag on  rlm$parsedcond(
                              substr(rlm$uniquetag(tagname, peseqpos),1,40));

grant select on exfsys.rlm$parsedcond to public;

--
--- Shared primitive rule conditions table support
--
create index rlm$evtstprctab on rlm$eventstruct (evst_owner, evst_prct);

REM
REM Modify static tables for the new release
REM

REM
REM UPDATE existing columns as needed to reflect new algorithms, etc.
REM
--
--- populate the evst_prcttls field
--
update rlm$eventstruct es set es.evst_prcttls =
  (select '"'||pem.talstabonr||'"."'||pem.talstabnm||'"' 
   from rlm$primevttypemap pem 
   where pem.rset_owner = es.evst_owner and 
        pem.prim_evntst = es.evst_name and rownum < 2) 
 where es.evst_name like 'RLM$TAA%';
   

REM
REM Create new types for the release
REM
--- accommodates upto 32 aggregate computations per rule ---
create or replace type rlm$apnumblst is VARRAY(32) of NUMBER;
/

grant execute on rlm$apnumblst to public;

create or replace type rlm$apvarclst is VARRAY(32) of VARCHAR2(100); 
/

grant execute on rlm$apvarclst to public;

create or replace type rlm$apmultvcl is table of rlm$apvarclst; 
/

grant execute on rlm$apmultvcl to public;

-- type representing an event in the collection --
create or replace type exfsys.rlm$collevent is object 
  (rlm$cetmstp timestamp, rlm$ceref VARCHAR(38), rlm$ceattvals EXFSYS.RLM$APVARCLST);
/

grant execute on exfsys.rlm$collevent to public;

create or replace type exfsys.rlm$collevents is table of exfsys.rlm$collevent; 
/

grant execute on exfsys.rlm$collevents to public;

--- Type used to capture the aggregate predicates for a collection of events ---
create or replace type exfsys.rlm$collpreds as object 
 (rlm$grpbyrep  NUMBER, 
  rlm$wndiwspc  NUMBER, 
  rlm$hvgpred   VARCHAR2(4000), 
  rlm$prdslhs   EXFSYS.RLM$APNUMBLST, 
  rlm$prdsrhs   EXFSYS.RLM$APVARCLST,
  constructor function rlm$collpreds return self as result);
/

create or replace type body  exfsys.rlm$collpreds as 
  constructor function rlm$collpreds return self as result is 
  begin
    null;
    return;
  end; 
end;
/


grant execute on exfsys.rlm$collpreds to public;


REM
REM ALTER existing types to add/change attributes and methods for the new release
REM

REM
REM Drop any onsolete packages/procedures
REM

REM
REM GRANT any additional privileges required by EXFSYS for the new release
REM
--
--- Change notification events support
--
grant execute on dbms_change_notification to exfsys;

grant execute on dbms_job to exfsys;
grant execute on dbms_scheduler to exfsys;

REM
REM  Call the upgrade script for next release 
REM
@@rulu111.sql


