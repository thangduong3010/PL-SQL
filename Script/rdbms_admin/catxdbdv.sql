Rem
Rem $Header: rdbms/admin/catxdbdv.sql /main/4 2008/10/19 03:00:28 badeoti Exp $
Rem
Rem catxdbdv.sql
Rem
Rem Copyright (c) 2003, 2008, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catxdbdv.sql - CATalog XDB Dummy Views
Rem
Rem    DESCRIPTION
Rem      Dummy XDB views for ALL_OBJECTS
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     10/09/08 - update all_xml_schemas def to 11.1
Rem    najain      12/08/03 - added package xml_schema_name_present
Rem    njalali     05/12/03 - added all_xml_schemas2
Rem    abagrawa    04/02/03 - abagrawa_catalog_view_schema_fixes
Rem    abagrawa    03/12/03 - Created
Rem

create or replace force view ALL_XML_SCHEMAS
 (OWNER, SCHEMA_URL, LOCAL, SCHEMA, INT_OBJNAME, QUAL_SCHEMA_URL, HIER_TYPE, BINARY, SCHEMA_ID, HIDDEN, DUMMY_DEFINITION) 
 as select null, null, null, null, null, null, null, null, null, null, null from dual where 1=0; 

Rem We want ALL_OBJECTS to depend on ALL_XML_SCHEMAS, but XMLTYPE is not
Rem available when ALL_OBJECTS is created.  For this reason, we create
Rem a version of ALL_XML_SCHEMAS we call ALL_XML_SCHEMAS2 that doesn't 
Rem require the presence of XMLTYPE.  Here we make a dummy version of
Rem the view, and later, after ALL_OBJECTS is created, we redefine the
Rem view in catxdbv.sql.  Since we don't want ALL_OBJECTS to become
Rem invalidated as a result of our recreating ALL_XML_SCHEMAS2, we
Rem cast all the "dummy" values to the final VARCHAR2 types that we get
Rem when the view is created for real.

create or replace force view ALL_XML_SCHEMAS2
 (OWNER, SCHEMA_URL, LOCAL, INT_OBJNAME, QUAL_SCHEMA_URL) 
 as select
    CAST('A' AS VARCHAR2(30)), 
    CAST('B' AS VARCHAR2(700)),
    CAST('C' AS VARCHAR2(3)),
    CAST('D' AS VARCHAR2(4000)),
    CAST('E' AS VARCHAR2(767)) from dual where 1=0; 


Rem ALL_OBJECTS depends on ALL_XML_SCHEMAS2, which gets recreated if XDB is
Rem installed. Remove this dependency, and redefine ALL_OBJECTS to depend
Rem on the function xml_schema_name_present instead. Note that once 3234025 
Rem is fixed, the package xml_schema_name_present can be removed. Also 
Rem while upgrading, xdb schema objects may be present, but xdb may not be
Rem installed. The reaon xml_schema_name_present is a function is that the 
Rem package body can be recreated without any invalidations.

create or replace package xml_schema_name_present as
function is_schema_present(objname in varchar2,
                           userno  in number) return number;
end xml_schema_name_present;
/

create or replace package body xml_schema_name_present as

function is_schema_present(objname in varchar2,
                           userno  in number) return number as
begin
  return 0;
end;

end xml_schema_name_present;
/


