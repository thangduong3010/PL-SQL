Rem
Rem $Header: rdbms/admin/exftyp.sql /st_rdbms_11.2.0/1 2013/02/08 05:44:54 sdas Exp $
Rem
Rem exftyp.sql
Rem
Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      exftyp.sql - EXpression Filter TYPe definitions.
Rem
Rem    DESCRIPTION
Rem      Types used by the Expression Filter APIs to pass Expression 
Rem      set metadata and index preferences.
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sdas        01/22/13 - Backport sdas_bug-16038193 from st_rdbms_12.1.0.1
Rem    ayalaman    07/22/08 - compiled sparse
Rem    ayalaman    07/29/05 - contains operator in stored expressions 
Rem    ayalaman    03/10/05 - privs on indextype and operator not required in 
Rem                           10.2 
Rem    ayalaman    01/20/04 - support XPath namespaces 
Rem    ayalaman    08/25/03 - provide a constructor for exf$xpath_tag 
Rem    ayalaman    03/17/03 - remove pragma directives
Rem    ayalaman    03/13/03 - ext optimizer support
Rem    ayalaman    11/19/02 - move indextype specification here
Rem    ayalaman    10/10/02 - add multiple constructors to exf_attribute
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/06/02 - Created
Rem


REM 
REM Expression Filter types
REM 

/***************************************************************************/
/*** EXF$INDEXOPER - List of indexable predicate operators               ***/
/***************************************************************************/
create or replace type exfsys.exf$indexoper as VARRAY(20) of VARCHAR2(15);
/

create or replace public synonym exf$indexoper for exfsys.exf$indexoper;

grant execute on exf$indexoper to public;

/***************************************************************************/
/*** EXF$ATTRIBUTE and EXF$ATTRIBUTE_LIST:Used to create attribute lists ***/
/***   for an attribute set's index parameters                           ***/
/***************************************************************************/
create or replace type exf$attribute as object (
  attr_name     VARCHAR2(350), 
  attr_oper     EXF$INDEXOPER, 
  attr_indexed  VARCHAR2(5),
  constructor function exf$attribute(attr_name varchar2)
    return self as result,
  constructor function exf$attribute(attr_name varchar2,
                                     attr_indexed varchar2)
    return self as result,
  constructor function exf$attribute(attr_name varchar2,
                                     attr_oper exf$indexoper,
                                     attr_indexed varchar2 default 'FALSE')
    return self as result
);
/

show errors;

create or replace type body exf$attribute as
  constructor function exf$attribute(attr_name varchar2)
    return self as result is 
  begin 
    self.attr_name := attr_name;
    self.attr_oper := exf$indexoper('all');
    self.attr_indexed := 'FALSE';
    return;
  end;

  constructor function exf$attribute(attr_name varchar2, 
                                     attr_indexed varchar2)
    return self as result is 
  begin 
    self.attr_name := attr_name;
    self.attr_oper := exf$indexoper('all');
    self.attr_indexed := attr_indexed;
    return;
  end;

  constructor function exf$attribute(attr_name varchar2, 
                                     attr_oper exf$indexoper,
                                     attr_indexed varchar2 default 'FALSE')
    return self as result is 
  begin 
    self.attr_name := attr_name;
    self.attr_oper := attr_oper;
    self.attr_indexed := attr_indexed;
    return;
  end;
end;
/

show errors;

create or replace type exf$attribute_list as VARRAY(490) of exf$attribute; 
/

create or replace public synonym exf$attribute for exfsys.exf$attribute;

grant execute on exf$attribute to public;

create or replace public synonym exf$attribute_list for
   exfsys.exf$attribute_list;

grant execute on exf$attribute_list to public;

/***************************************************************************/
/*** EXF$TABLE_ALIAS - type to create table alias as one of the          ***/
/***  elementary attribute in an attribute set                           ***/
/***************************************************************************/
create type exfsys.exf$table_alias as object (
   table_name  VARCHAR2(70)
);
/

create or replace public synonym exf$table_alias for exfsys.exf$table_alias;

grant execute on exf$table_alias to public;

/***************************************************************************/
/*** EXF$XPATH_TAGS - List of common elements and attributes in an XPath ***/
/***                 expression set.                                     ***/
/*** Both common elements and attributes expected in the XPath expr. set ***/
/*** are configured using the exf$xpath_tag API. In the case of elements,***/
/*** the TAG_NAME is a name with out a @ extension.                      ***/
/***************************************************************************/
create or replace type exf$xpath_tag as object (
  tag_name     VARCHAR2(350), -- <ns:name> / <ns:name>@<name2> 
  tag_indexed  VARCHAR2(5),  -- default 'TRUE' for positional filter and 
                             -- 'FALSE' for value filter 
  tag_type     VARCHAR2(30), -- Xschema types mapped to DB types
                             -- null value implies a positional filter for 
                             -- tag. Otherwise a value filter.
  constructor function exf$xpath_tag(tag_name varchar2)
    return self as result
);
/

show errors;

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

show errors;

create or replace type exf$xpath_tags as VARRAY(490) of exf$xpath_tag; 
/

grant execute on exf$xpath_tag to public;
grant execute on exf$xpath_tags to public;

create or replace public synonym exf$xpath_tag for exfsys.exf$xpath_tag;
create or replace public synonym exf$xpath_tags for exfsys.exf$xpath_tags;

REM 
REM  Type for configuring a text data type column that can be used to 
REM  process predicates with CONTAINS operator 
REM 
/***************************************************************************/
/*** EXF$TEXT : Text datatype for CONTAINS operator                      ***/
/***************************************************************************/
create type exfsys.exf$text as object (
   preferences  VARCHAR2(1000)
);
/

create or replace public synonym exf$text for exfsys.exf$text;

grant execute on exf$text to public;

create or replace type exf$csicode as object (code int, arg varchar2(1000)); 
/

grant execute on exfsys.exf$csicode to public; 

create or replace type exf$csiset as varray (1000) of exf$csicode; 
/
 
grant execute on exfsys.exf$csiset to public; 

REM
REM Indextype and Statistics type specifications
REM 
/*********************** ExpFilter Indextype Interface *********************/
/*** EXPRESSIONINDEXMETHODS : Interfaces to Indextype implementation     ***/
/***************************************************************************/
create or replace type ExpressionIndexMethods AUTHID CURRENT_USER AS object
(
  -- cursor set by IndexStart and used in IndexFetch
  scanctx RAW(4),
    
  static function ODCIGetInterfaces(ifcList OUT sys.ODCIObjectList)
    return NUMBER,

  --- DDL ---
  static function ODCIIndexCreate (idxinfo   sys.ODCIIndexInfo,
                                   idxparms  VARCHAR2,
                                   idxenv    sys.ODCIEnv)
    return NUMBER,
  static function ODCIIndexDrop (idxinfo  sys.ODCIIndexInfo,
                                 idxenv   sys.ODCIEnv)
    return NUMBER,
  static function ODCIIndexAlter (idxinfo          sys.ODCIIndexInfo, 
                                  idxparms  IN OUT VARCHAR2,
                                  altopt           NUMBER,
                                  idxenv           sys.ODCIEnv)
    return NUMBER,
  static function ODCIIndexTruncate (idxinfo  sys.ODCIIndexInfo,
                                     idxenv   sys.ODCIEnv)
    return NUMBER,

  --- DML ---
  static function ODCIIndexInsert (idxinfo  sys.ODCIIndexInfo,
                                   rid      VARCHAR2,
                                   newval   VARCHAR2,
                                   idxenv   sys.ODCIEnv)
    return NUMBER,
  static function ODCIIndexDelete (idxinfo  sys.ODCIIndexInfo,
                                   rid      VARCHAR2,
                                   oldval   VARCHAR2,
                                   idxenv   sys.ODCIEnv)
    return NUMBER,
  static function ODCIIndexUpdate (idxinfo  sys.ODCIIndexInfo,
                                   rid      VARCHAR2,
                                   oldval   VARCHAR2,
                                   newval   VARCHAR2,
                                   idxenv   sys.ODCIEnv)
    return NUMBER,

  --- Query ---
  static function ODCIIndexStart (ictx    IN OUT ExpressionIndexMethods,
                                  idxinfo        sys.ODCIIndexInfo,
                                  opi            sys.ODCIPredInfo, 
                                  oqi            sys.ODCIQueryInfo,
                                  strt           NUMBER,
                                  stop           NUMBER,
                                  ditem          VARCHAR2,
                                  idxenv         sys.ODCIEnv)
   return NUMBER,

  static function ODCIIndexStart (ictx    IN OUT ExpressionIndexMethods,
                                  idxinfo        sys.ODCIIndexInfo,
                                  opi            sys.ODCIPredInfo, 
                                  oqi            sys.ODCIQueryInfo,
                                  strt           NUMBER,
                                  stop           NUMBER,
                                  ditem          sys.AnyData,
                                  idxenv         sys.ODCIEnv)
   return NUMBER,

  member function ODCIIndexFetch (nrows          NUMBER,
                                  rids     OUT   sys.ODCIRidList,
                                  idxenv         sys.ODCIEnv)
    return  NUMBER IS LANGUAGE C 
     name "EXF_IFETCH"
     library EXFTLIB
    with context
    parameters (
     context,
     self,
     self INDICATOR STRUCT,
     nrows,
     nrows INDICATOR,
     rids,
     rids INDICATOR,
     idxenv, 
     idxenv INDICATOR STRUCT,
     return OCINumber
   ),

  member function ODCIIndexClose (idxenv        sys.ODCIEnv)
    return NUMBER IS LANGUAGE C
     name "EXF_ICLOSE"
     library EXFTLIB
   with context
   parameters (
     context,
     self,
     self INDICATOR STRUCT,
     idxenv, 
     idxenv INDICATOR STRUCT,
     return OCINumber
   ),

  static function ODCIIndexGetMetadata (
                                  idxinfo  IN    sys.ODCIIndexInfo,
                                  expver   IN    VARCHAR2,
                                  newblock OUT   PLS_INTEGER, 
                                  idxenv   IN    sys.ODCIEnv)
     return VARCHAR2,
 
  static function ODCIIndexUtilGetTableNames (
                                  idxinfo  IN    sys.ODCIIndexInfo, 
                                  readonly IN    PLS_INTEGER, 
                                  version  IN    VARCHAR2, 
                                  context  OUT   PLS_INTEGER) 
     return BOOLEAN,

  static procedure ODCIIndexUtilCleanup (
                                  context  IN    PLS_INTEGER),
 
  static function pvtcreate_expfil_instance (
                                  idxinfo        sys.ODCIIndexInfo,
                                  idxparms       VARCHAR2, 
                                  asname         VARCHAR2, 
                                  esetcol        VARCHAR2) 
     return NUMBER 
);
/

show errors;

/************************* EXPRESSION INDEX STATS **************************/
/***  EXPRESSIONINDEXSTATS : Statistics for query plans                  ***/
/***************************************************************************/
create or replace type ExpressionIndexStats AUTHID CURRENT_USER AS object
(
  dummy number(6),
  static function ODCIGetInterfaces(ifclist OUT sys.ODCIObjectList)
    return number,

  static function ODCIStatsCollect(col sys.ODCIColInfo,
    options sys.ODCIStatsOptions, stats OUT RAW, env sys.ODCIEnv)
    return number,

  static function ODCIStatsCollect(idx sys.ODCIIndexInfo,
    options sys.ODCIStatsOptions, stats OUT RAW, env sys.ODCIEnv)
    return number,

  static function ODCIStatsDelete(col sys.ODCIColInfo,
    stats OUT RAW, env sys.ODCIEnv) return number,

  static function ODCIStatsDelete(idx sys.ODCIIndexInfo,
    stats OUT RAW, env sys.ODCIEnv) return number,

  static function ODCIStatsSelectivity(pred sys.ODCIPredInfo,
    sel OUT number, args sys.ODCIArgDescList, strt number,
    stop number, expr VARCHAR2, datai VARCHAR2,
    env sys.ODCIEnv) return number,

  static function ODCIStatsFunctionCost(func sys.ODCIFuncInfo,
    cost OUT sys.ODCICost, args sys.ODCIArgDescList,
    expr VARCHAR2, datai VARCHAR2, env sys.ODCIEnv) return number,

  static function ODCIStatsIndexCost(idx sys.ODCIIndexInfo,
    sel number, cost OUT sys.ODCICost, qi sys.ODCIQueryInfo,
    pred sys.ODCIPredInfo, args sys.ODCIArgDescList,
    strt number, stop number, datai varchar2, env sys.ODCIEnv)
    return number 

  /*** AnyData : Ext-Optimizer Arg overloading problem ***
  static function ODCIStatsSelectivity(pred sys.ODCIPredInfo,
    sel OUT number, args sys.ODCIArgDescList, strt number,
    stop number, expr VARCHAR2, datai sys.AnyData,
    env sys.ODCIEnv) return number,

  static function ODCIStatsFunctionCost(func sys.ODCIFuncInfo,
    cost OUT sys.ODCICost, args sys.ODCIArgDescList,
    expr VARCHAR2, datai sys.AnyData, env sys.ODCIEnv) return number,

  static function ODCIStatsIndexCost(idx sys.ODCIIndexInfo,
    sel number, cost OUT sys.ODCICost, qi sys.ODCIQueryInfo,
    pred sys.ODCIPredInfo, args sys.ODCIArgDescList,
    strt number, stop number, datai sys.AnyData, env sys.ODCIEnv)
    return number
  */
);
/

show errors;

/******************* OPERATOR FUNCTIONAL IMPLEMENTATIONS *******************/
/*** Functional implementations for different operator bindings          ***/
/***************************************************************************/
create function evaluate_vv(col   VARCHAR2,
                            value VARCHAR2, 
                            ictx  SYS.ODCIINDEXCTX,
                            sctx  IN OUT ExpressionIndexMethods,
                            sflg  NUMBER, 
                            colctx SYS.ODCIFuncCallInfo)
   return number AUTHID CURRENT_USER as
begin
  return 2;
end;
/

create function evaluate_va(col   VARCHAR2,
                            value SYS.ANYDATA,
                            ictx  SYS.ODCIINDEXCTX,
                            sctx  IN OUT ExpressionIndexMethods,
                            sflg  NUMBER, 
                            colctx SYS.ODCIFuncCallInfo)
   return number  AUTHID CURRENT_USER  as
begin
  return 2;
end;
/

create function evaluate_cv(col   CLOB,
                            value VARCHAR2, 
                            ictx  SYS.ODCIINDEXCTX,
                            sctx  IN OUT ExpressionIndexMethods,
                            sflg  NUMBER,
                            colctx SYS.ODCIFuncCallInfo)
   return number AUTHID CURRENT_USER  as
begin  
  return 2;
end;
/

create function evaluate_ca(col   CLOB,
                            value SYS.ANYDATA, 
                            ictx  SYS.ODCIINDEXCTX,
                            sctx  IN OUT ExpressionIndexMethods,
                            sflg  NUMBER,
                            colctx SYS.ODCIFuncCallInfo)
   return number  AUTHID CURRENT_USER  as
begin
  return 2;
end;
/

/************************* EVALUATE Operator *******************************/
/*** The EVALAUTE Operator and its various bindings                      ***/
/***************************************************************************/
--- create EVALUATE operators --
create or replace operator EVALUATE binding
  (VARCHAR2, VARCHAR2) return NUMBER
    WITH INDEX CONTEXT, SCAN CONTEXT ExpressionIndexMethods 
    WITH COLUMN CONTEXT
    USING  evaluate_vv, 
  (VARCHAR2, SYS.ANYDATA) return NUMBER
    WITH INDEX CONTEXT, SCAN CONTEXT ExpressionIndexMethods 
    WITH COLUMN CONTEXT
    USING evaluate_va, 
  (CLOB, VARCHAR2) return NUMBER
    WITH INDEX CONTEXT, SCAN CONTEXT ExpressionIndexMethods 
    WITH COLUMN CONTEXT
    USING evaluate_cv,
  (CLOB, SYS.ANYDATA) return NUMBER
    WITH INDEX CONTEXT, SCAN CONTEXT ExpressionIndexMethods 
    WITH COLUMN CONTEXT
    USING evaluate_ca;
/


create or replace public synonym EVALUATE for exfsys.EVALUATE; 

grant execute on EVALUATE to public;

/***************************************************************************/
/***                      Public Object Types                            ***/
/***************************************************************************/
---- RLM$ROWIDTAB : Used to represent a list of rowids 
create or replace type exfsys.rlm$rowidtab is table of VARCHAR2(38);
/

grant execute on exfsys.rlm$rowidtab to public;


