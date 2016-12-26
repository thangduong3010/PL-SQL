Rem
Rem $Header: xdbuud.sql 12-nov-2007.16:03:02 yifeng Exp $
Rem
Rem xdbuud.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xdbuud.sql - XDB Upgrade Utility functions Drop
Rem
Rem    DESCRIPTION
Rem      Drop procedures/functions created in xdbuuc.sql
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yifeng      11/12/07 - Drop element_exists_complextype
Rem    rpang       12/02/04 - Drop type_name, find_element, find_child...
Rem    spannala    08/24/04 - adding drop_schema_chg_status 
Rem    abagrawa    05/10/04 - Drop xdb$insertElement 
Rem    thbaby      04/26/04 - thbaby_https
Rem    spannala    03/03/04 - adding alt_type_drop_attribute 
Rem    spannala    01/30/04 - Created
Rem
drop procedure element_type;
drop procedure alt_type_add_attribute;
drop procedure alt_type_drop_attribute;
drop function get_upgrade_status;
drop procedure set_upgrade_status;
drop function xdb.xdb$insertElement;
DROP PROCEDURE drop_schema_chg_status;
drop procedure exec_stmt_chg_status;
drop procedure delete_elem_by_ref;
drop function find_child;
drop function find_child_with_model;
drop function find_element;
drop function type_name;
drop function element_exists_complextype;
