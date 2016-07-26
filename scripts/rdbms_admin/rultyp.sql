Rem
Rem $Header: rdbms/admin/rultyp.sql /st_rdbms_11.2.0/1 2013/02/08 05:44:54 sdas Exp $
Rem
Rem rultyp.sql
Rem
Rem Copyright (c) 2004, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      rultyp.sql - Rule Manager object types 
Rem
Rem    DESCRIPTION
Rem      This script defines the object types that are used for the 
Rem      Rule manager implementation/APIs
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdas        01/22/13 - Backport sdas_bug-16038193 from st_rdbms_12.1.0.1
Rem    ayalaman    03/06/07 - duplicate collection events
Rem    ayalaman    05/16/05 - new types for aggregate predicates support 
Rem    ayalaman    04/06/05 - collection predicates type 
Rem    ayalaman    03/28/05 - aggregate predicates in rule conditions 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    04/15/04 - synonym for rlm_table_alias 
Rem    ayalaman    04/02/04 - Created
Rem

REM 
REM Rule Manager Object Types
REM 
prompt .. creating Rule Manager object types
/***************************************************************************/
/***                      Public Object Types                            ***/
/***************************************************************************/
---- RLM$EVENTIDS : Defined as a synonym for RLM$ROWIDTAB, used to pass
---- list of event identifiers to CONSUME_EVENTS API. 
create or replace public synonym rlm$eventids for exfsys.rlm$rowidtab; 

/***************************************************************************/
/***     Private Object Types  (Used in the generated packages)          ***/
/***************************************************************************/

create or replace type exfsys.rlm$equalattr as VARRAY(32) of VARCHAR2(32);
/

grant execute on rlm$equalattr to public;


create or replace type exfsys.rlm$keyval is table of VARCHAR2(1000);
/

grant execute on exfsys.rlm$keyval to public;


create or replace type exfsys.rlm$dateval is table of timestamp;
/

grant execute on exfsys.rlm$dateval to public;


create or replace type exfsys.rlm$numval is table of number;
/

grant execute on exfsys.rlm$numval to public;

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

  

/***************************************************************************/
/*** RLM$TABLE_ALIAS : Used to create event structures with table aliases **/
/***************************************************************************/
create or replace public synonym rlm$table_alias for exfsys.exf$table_alias;


