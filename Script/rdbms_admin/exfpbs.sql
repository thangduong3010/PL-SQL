Rem
Rem $Header: exfpbs.sql 23-feb-2006.10:23:52 ayalaman Exp $
Rem
Rem exfpbs.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfpbs.sql - EXpression Filter PuBlic PL/SQL packages and 
Rem                   functions.
Rem
Rem    DESCRIPTION
Rem      Expression Filter PL/SQL APIs to manage expression sets and
Rem      their metadata.
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/23/06 - validation routine for EXF 
Rem    ayalaman    10/11/05 - modify validate script for EXF component 
Rem    ayalaman    08/07/05 - api for synchronizing text indexes 
Rem    ayalaman    07/29/05 - contains operator in stored expressions 
Rem    ayalaman    01/27/05 - truncate table maint. for rule class 
Rem    ayalaman    10/07/04 - new validation procedures in SYS 
Rem    ayalaman    04/19/04 - rule manager registry 
Rem    ayalaman    07/23/03 - attribute set with default valued attributes
Rem    ayalaman    01/20/03 - xpath filter apis
Rem    ayalaman    12/05/02 - validate expfil
Rem    ayalaman    10/21/02 - fix argument names
Rem    ayalaman    10/04/02 - defrag_index api
Rem    ayalaman    09/26/02 - package variables
Rem    ayalaman    09/25/02 - validate expressions API
Rem    ayalaman    09/24/02 - add build_exceptions_table API
Rem    ayalaman    09/06/02 - Created
Rem


prompt .. creating Expression Filter PL/SQL Package Specifications

/*******************************  PACKAGE  *********************************/
/*** DBMS_EXPFIL : Package to manage the Expression Engine               ***/
/***               All procedures are defined with invoker rights        ***/
/***************************************************************************/
create or replace package dbms_expfil AUTHID CURRENT_USER AS
  
  procedure copy_attribute_set (
              from_set   IN   VARCHAR2,    --- name of an existing att set
              to_set     IN   VARCHAR2);   --- new set name

  procedure create_attribute_set (
              attr_set   IN   VARCHAR2,    --- attr set name
              from_type  IN   VARCHAR2     --- ADT for attributes
                         default 'NO');

  procedure assign_attribute_set (
              attr_set   IN   VARCHAR2,    --- attr set name
              expr_tab   IN   VARCHAR2,    --- name of the table
              expr_col   IN   VARCHAR2,    --- exp column in the table 
              force      IN   VARCHAR2     --- to use existing expressions
                         default 'FALSE');                       

  procedure add_elementary_attribute (
              attr_set   IN   VARCHAR2,    --- attr set name
              attr_name  IN   VARCHAR2,    --- attr name
              attr_type  IN   VARCHAR2,    --- attr type
              attr_defvl IN   VARCHAR2     --- default value for attr
                         default NULL);

  procedure add_elementary_attribute (
              attr_set   IN   VARCHAR2,    --- attr set name
              attr_name  IN   VARCHAR2,    --- table alias (name)
              tab_alias  IN   exf$table_alias);  -- table alias for

  procedure add_elementary_attribute (
              attr_set   IN   VARCHAR2,    --- attr set name
              attr_name  IN   VARCHAR2,    --- attr name
              attr_type  IN   VARCHAR2,    --- attr type
              text_pref  IN   exf$text);   --- text data type pref

  procedure add_functions (
              attr_set   IN   VARCHAR2,    --- attr set name 
              funcs_name IN   VARCHAR2);   --- function/package/type name

  procedure unassign_attribute_set (
              expr_tab   IN   VARCHAR2,    --- table with expr. column
              expr_col   IN   VARCHAR2);   --- column storing expr. set

  procedure drop_attribute_set (
              attr_set   IN   VARCHAR2);   --- attr set name

  procedure modify_operator_list (
              attr_set   IN   VARCHAR2,    --- attr set name
              attr_name  IN   VARCHAR2,    --- attribute to be modified
              attr_oper  IN   EXF$INDEXOPER);  --- list of new operators

  procedure default_index_parameters (
              attr_set   IN   VARCHAR2,    --- attribute set name
              attr_list  IN   EXF$ATTRIBUTE_LIST,
                                           --- stored and indexed attrs
              operation  IN   VARCHAR2     --- to ADD or DROP
                               default 'ADD');

  procedure index_parameters(
              expr_tab   IN   VARCHAR2,    --- expression set table
              expr_col   IN   VARCHAR2,    --- expression set column
              attr_list  IN   EXF$ATTRIBUTE_LIST default null,
              operation  IN   VARCHAR2     --- DEFAULT/ADD/DROP/CLEAR
                               default 'ADD');

  procedure default_xpindex_parameters (
              attr_set   IN   VARCHAR2,    --- attribute set 
              xmlt_attr  IN   VARCHAR2,    --- XMLType attribute name
              xptag_list IN   EXF$XPATH_TAGS, --- common elements/attributes
                                              --- in xpath expressions
              operation  IN   VARCHAR2     --- to ADD/DROP
                                default 'ADD'); 

  procedure xpindex_parameters(
              expr_tab   IN   VARCHAR2,    --- expression set table 
              expr_col   IN   VARCHAR2,    --- expression set column
              xmlt_attr  IN   VARCHAR2,    --- XMLType attribute name
              xptag_list IN   EXF$XPATH_TAGS, --- common elements/attributes
                                              --- in xpath expressions
              operation  IN   VARCHAR2     --- to ADD/DROP
                                default 'ADD');

  procedure get_exprset_stats (
              expr_tab   IN   VARCHAR2,    --- table storing expression set
              expr_col   IN   VARCHAR2);   --- column in the table with set
     
  procedure clear_exprset_stats (
              expr_tab   IN   VARCHAR2,    --- table storing expression set
              expr_col   IN   VARCHAR2);   --- column in the table with set

  procedure grant_privilege (
              expr_tab   IN  VARCHAR2,     --- table w/ the expr column
              expr_col   IN  VARCHAR2,     --- column storing the expressions
              priv_type  IN  VARCHAR2,     --- type of priv to be granted
              to_user    IN  VARCHAR2);    --- user to which the priv is
                                           ---   granted
  procedure revoke_privilege (
              expr_tab   IN  VARCHAR2,     --- table with the expr column
              expr_col   IN  VARCHAR2,     --- column storing the expressions
              priv_type  IN  VARCHAR2,     --- type of privilege to be granted
              from_user  IN  VARCHAR2);    --- user from which the priv is
                                           ---   revoked

  procedure build_exceptions_table (
              exception_tab IN VARCHAR2);  -- exception table to be created --

  procedure validate_expressions (
              expr_tab      IN  VARCHAR2,  --- expressions table 
              expr_col      IN  VARCHAR2,  --- column storing expressions
              exception_tab IN  VARCHAR2   --- exception table
                    default null);

  procedure defrag_index (
              idx_name   IN  VARCHAR2);    --- expfil index to defrag 

  procedure sync_text_indexes (
              expr_tab      IN  VARCHAR2);  --- sync text indexes 
end;
/

show errors;

create or replace public synonym dbms_expfil for exfsys.dbms_expfil;

grant execute on dbms_expfil to public;

/****************************** PROCEDURES *********************************/
/*** VALIDATION Procedures for Expression Filter and Rules Manager       ***/
/***************************************************************************/
create or replace procedure sys.validate_exf as
  retnum  NUMBER;
begin
 -- ensure that the expression filter objects are all valid --
 -- ignore any rules manager objects in this schema --
 select 1 into retnum from all_objects where
   owner = 'EXFSYS' and status != 'VALID' and
      (object_name like 'EXF$%' or object_name like '%EXPFIL%') and
     rownum < 2;

 sys.dbms_registry.invalid('EXF');
exception 
  when no_data_found then 
    sys.dbms_registry.valid('EXF');
end;
/

create or replace  procedure sys.validate_rul as
  retnum  NUMBER;
begin
 -- make sure all the objects in EXFSYS schema are valid --
 select 1 into retnum from all_objects where
   owner = 'EXFSYS' and status != 'VALID' and rownum < 2;

 sys.dbms_registry.invalid('RUL');
exception
  when no_data_found then
    sys.dbms_registry.valid('RUL');
end;
/

/*******************************  PACKAGE  *********************************/
/***  Package to manage the system triggers in the EXPFIL schema as a    ***/
/***  set. Appropriate triggers can be created by invoking the corr.     ***/
/***  APIs. Only EXFSYS or DBA user has execute privileges to this       ***/
/***************************************************************************/
create or replace package adm_expfil_systrig as

  /*************************************************************************/
  /*** CREATE_SYSTRIG_DROPOBJ : System trigger to manage meta-data after ***/
  /*** the drop of expression table and user with attributes sets. Also  ***/
  /*** restricts the user from dropping the ADT associated with an       ***/
  /*** Attribute set. Name of the trigger created : EXPFIL_DROPOBJ_MAINT ***/
  /*************************************************************************/
  procedure create_systrig_dropobj;

  /*************************************************************************/
  /*** CREATE_SYSTRIG_TRUNCRULCLS : Trigger to perform the necessary     ***/
  /*** maintenance for TRUNCATE of a rule class table                    ***/
  /*************************************************************************/
  procedure create_systrig_truncrulcls; 

  /*************************************************************************/
  /*** CREATE_SYSTRIG_TYPEEVOLVE : System trigger to restrict ALTER and  ***/
  /*** CREATE or REPLACE operations on the ADT associated with an        ***/
  /*** Attribute set. Name of trig created : EXPFIL_RESTRICT_TYPEEVOLVE  ***/
  /*************************************************************************/
  procedure create_systrig_typeevolve;

  /*************************************************************************/
  /*** CREATE_SYSTRIG_ALTEREXPTAB : System trigger to manage meta-data   ***/
  /*** after a drop of expression column from the user table or a rename ***/
  /*** of the expression table. Name of trig : EXPFIL_ALTEREXPTAB_MAINT  ***/
  /*************************************************************************/
  procedure create_systrig_alterexptab;

  /*************************************************************************/
  /*** DISABLE_ALL : Api to disable all the system triggers in the EXPFIL***/
  /*** schema temporarily. They can be re-enabled using ENABLE_ALL API   ***/
  /*************************************************************************/
  procedure disable_all;

  /*************************************************************************/
  /*** ENABLE_ALL : Api to enable all the system triggers in the EXPFIL  ***/
  /*** schema. The triggers should exist in a valid state for this to    ***/
  /*** succeed. See CREATE_SYSTRIG_* APIs to create the triggers         ***/
  /*************************************************************************/
  procedure enable_all;

end;
/

/****************  VARRAR2STR used in view definitions *********************/
create or replace function varray2str (ioper exf$indexoper, 
                                       wquote VARCHAR2 default 'FALSE')
    return varchar2 is
  ret  varchar2(300);
  CURSOR c1 (va exf$indexoper) IS
     SELECT column_value from TABLE (cast(va as exf$indexoper));
begin
  ret := null;

  IF (upper(wquote) = 'TRUE') THEN 
    FOR cur IN c1(ioper) LOOP
      IF (ret is null) THEN
        ret := ''''||cur.column_value||'''';
      ELSE
        ret := ret ||','''||cur.column_value||'''';
      END IF;
    END LOOP;
  ELSE 
    FOR cur IN c1(ioper) LOOP
      IF (ret is null) THEN
        ret := cur.column_value;
      ELSE
        ret := ret ||','||cur.column_value;
      END IF;
    END LOOP;
  END IF;

  return ret;
end;
/


create or replace function arrhasvalue(ioper exf$indexoper, val varchar2) 
  return number is
  retval number := 0;
begin
  select count(*) into retval from table (cast(ioper as exf$indexoper))
    where upper(column_value) = upper(val);
  return retval;
end;
/

create or replace function exf$text2exprid (ptname VARCHAR2, ptrowd VARCHAR2)
  return VARCHAR2 AUTHID CURRENT_USER is 
begin
  return null;
end;
/

