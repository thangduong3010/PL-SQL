Rem
Rem $Header: exfe101.sql 14-may-2007.07:25:46 ayalaman Exp $
Rem
Rem exfe101.sql
Rem
Rem Copyright (c) 2004, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfe101.sql - Downgrade script for Expression Filter
Rem
Rem    DESCRIPTION
Rem      Downgrade script for Expression Filter to 10.1 
Rem
Rem    NOTES
Rem      Expression Filter was first introduced in 10.1
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    05/14/07 - drop java implementation
Rem    ayalaman    11/15/05 - fix registry call 
Rem    ayalaman    08/11/05 - add downgrade script for 10.2 
Rem    ayalaman    05/07/05 - spatial operators in stored expressions 
Rem    ayalaman    03/10/05 - grant privs on indextype and operator 
Rem                           implementation in 10.1 
Rem    ayalaman    02/17/05 - lrg 1831813 load package specs while downgrade 
Rem    ayalaman    09/02/04 - drop views during downgrade 
Rem    ayalaman    04/30/04 - extensible optim support 
Rem    ayalaman    04/30/04 - namespace support in xpath expressions 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    03/24/04 - Created
Rem

REM
REM Downgrade of EXF from 10.2 to 10.1 
REM

REM
REM Call the downgrade script for 10.2  
REM
@@exfe102.sql

ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

EXECUTE dbms_registry.downgrading('EXF');

REM 
REM Drop packages, views and classes that were added in the new release. 
REM 

drop view ALL_EXPFIL_PREDTAB_PLAN; 

drop view USER_EXPFIL_PREDTAB_PLAN; 

REM
REM Drop Java stored procedure implementations that are 11.1 specific
REM

execute sys.dbms_java.dropjava('-schema exfsys rdbms/jlib/ExprFilter.jar');

REM 
REM Drop force any new types, operators and indextypes;
REM (None)

REM
REM Alter types for existing types to their prior release definitions.
REM 

REM
REM Alter operator and indextype back to their prior release. 
REM

REM
REM Update new columns to values appropriate for the old release
REM

--- support for default valued attributes introduced in 10.2 ---
alter table exf$attrlist drop (attrdefvl);

--- extensible optimizer support introduced in 10.2 ---
alter table exf$idxsecobj drop (optfccpuct, optfcioct, optixselvt,
                                optixcpuct, optixioct, optptfscct, 
                                idxpquery);

--- namespace support for xpath expressions introduced in 10.2 --
alter table exf$defidxparam drop(xmlnselp);
alter table exf$esetidxparam drop(xmlnselp);
alter table exf$predattrmap drop(xmlnselp);

REM
REM Undo any modifications that were made to user objects during the upgrade
REM 

REM
REM Truncate / Drop the new tables
REM 

--- extensible optimizer support introduced in 10.2 ---
drop table exf$parameter;

drop table exf$plan_table;

--- delete the spatial operator from indexed list ---
delete from exf$validioper where operstr = 'SDO_WIDIST';

REM 
REM Create the public package specifications for 10.1 release
REM 
/*******************************  PACKAGE  *********************************/
/*** DBMS_EXPFIL : Package to manage the Expression Engine               ***/
/***               All procedures are defined with invoker rights        ***/
/*** This could have been avoided if exfpbs.sql file was included in the ***/
/*** exfrelod.sql file. In the absence of this, we will recreate the old ***/
/*** public specification.                                               ***/
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
              attr_type  IN   VARCHAR2);   --- attr type

  procedure add_elementary_attribute (
              attr_set   IN   VARCHAR2,    --- attr set name
              attr_name  IN   VARCHAR2,    --- table alias (name)
              tab_alias  IN   exf$table_alias);  -- table alias for

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

end;
/

show errors;

create or replace public synonym dbms_expfil for exfsys.dbms_expfil;

grant execute on dbms_expfil to public;

/*** Install 10.1 version of the package spec during download. Workaround **/
/*** for not including exfpbs.sql in exfreload.sql of 10.1 release. Fixed **/
/*** it 10.2 release on wards                                            ***/
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

/*** Grant privileges on indextype and operator implementation in  10.1 ***/
---bug 4114159 ---
grant execute on ExpressionIndexMethods to public;
grant execute on ExpressionIndexStats to public;
grant execute on exfsys.EVALUATE_VV to public;
grant execute on exfsys.EVALUATE_VA to public;
grant execute on exfsys.EVALUATE_CV to public;
grant execute on exfsys.EVALUATE_CA to public;

EXECUTE dbms_registry.downgraded('EXF','10.1.0');

ALTER SESSION SET CURRENT_SCHEMA = SYS;

