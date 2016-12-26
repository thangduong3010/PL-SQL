Rem
Rem $Header: rdbms/admin/exfview.sql /main/11 2009/01/08 11:05:03 ayalaman Exp $
Rem
Rem exfview.sql
Rem
Rem Copyright (c) 2002, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      exfview.sql - EXpression Filter VIEW definitions.
Rem
Rem    DESCRIPTION
Rem      Catalog views to obtain information about expression sets,
Rem      their metadata and the expression filter indexes. 
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    07/23/08 - compiled sparse preds
Rem    ayalaman    10/30/07 - bug 6596055
Rem    ayalaman    09/02/05 - text index errors 
Rem    ayalaman    07/31/05 - contains operator in stored expressions 
Rem    ayalaman    07/23/03 - attribute set with default valued attributes
Rem    ayalaman    03/03/03 - predicate table plans
Rem    ayalaman    01/20/03 - xpath filter views
Rem    ayalaman    11/07/02 - define sch_expfil_indexes view
Rem    ayalaman    10/21/02 - modify priv name
Rem    ayalaman    10/15/02 - all_.* views for export/import
Rem    ayalaman    10/09/02 - define def_index_parameters view
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/06/02 - Created
Rem


REM 
REM Create Expression Filter catalog views
REM 
prompt .. creating Expression Filter catalog views

/***************  [USER/ALL/ADM]_EXPFIL_ATTRIBUTE_SETS *********************/
--
-- USER_EXPFIL_ATTRIBUTE_SETS
--
create or replace view USER_EXPFIL_ATTRIBUTE_SETS
  (ATTRIBUTE_SET_NAME)
  as
  select atsname from exf$attrset
  where atsowner = (select user from dual);

create or replace public synonym  USER_EXPFIL_ATTRIBUTE_SETS 
  for exfsys.USER_EXPFIL_ATTRIBUTE_SETS;

grant select on USER_EXPFIL_ATTRIBUTE_SETS to public;

COMMENT ON TABLE  user_expfil_attribute_sets IS
'List of all the attribute sets in the current schema';

COMMENT ON COLUMN user_expfil_attribute_sets.attribute_set_name  IS
'Name of the attribute set';

---
---                ALL_EXPFIL_ATTRIBUTE_SETS   
---           (use privs of the associated ADT)
create or replace view ALL_EXPFIL_ATTRIBUTE_SETS 
  (OWNER, ATTRIBUTE_SET_NAME) 
 as 
   select atsowner, atsname from exf$attrset ast, all_types ao
   where ao.owner = ast.atsowner and ao.type_name = ast.atsname;

create or replace public synonym ALL_EXPFIL_ATTRIBUTE_SETS 
  for exfsys.ALL_EXPFIL_ATTRIBUTE_SETS;

grant select on ALL_EXPFIL_ATTRIBUTE_SETS to public;

COMMENT ON TABLE  all_expfil_attribute_sets IS
'List of all the attribute sets accessible to the user';

COMMENT ON COLUMN all_expfil_attribute_sets.owner  IS
'Owner of the attribute set';

COMMENT ON COLUMN all_expfil_attribute_sets.attribute_set_name  IS
'Name of the attribute set';

---
---                ADM_EXPFIL_ATTRIBUTE_SETS   
---   
create or replace view ADM_EXPFIL_ATTRIBUTE_SETS
  (OWNER, ATTRIBUTE_SET_NAME)
  as
  select atsowner, atsname from exf$attrset;

COMMENT ON TABLE  adm_expfil_attribute_sets IS
'List of all the attribute sets in the current instance';

COMMENT ON COLUMN adm_expfil_attribute_sets.owner  IS
'Owner of the attribute set';

COMMENT ON COLUMN adm_expfil_attribute_sets.attribute_set_name IS
'Name of the attribute set';


/********************* [USER/ALL]_EXPFIL_ATTRIBUTES ************************/
--- NOTE : Order by clause for this view is important for the correctness
---    of the expeng implementation. Atleast ordering should be 
---    maintained among elementary attributes (same order as they appear 
---    in the corresponding type definition). This order by is used to 
---    generate the APIs in the type and access function that ensure the
---    arguments  in the correct order 
---
---               USER_EXPFIL_ATTRIBUTES
---
create or replace view USER_EXPFIL_ATTRIBUTES 
  (ATTRIBUTE_SET_NAME, ATTRIBUTE, DATA_TYPE, ASSOCIATED_TABLE, DEFAULT_VALUE, TEXT_PREFERENCES)
  as select atsname, attrname, attrtype, 
        decode (bitand(attrprop, 16), 16, attrtptab, null), attrdefvl, 
        decode (bitand(attrprop, 32), 32, attrtxtprf, 'N/A')
 from exf$attrlist where  atsowner = (select user from dual) 
  order by atsowner, atsname, elattrid;

create or replace public synonym USER_EXPFIL_ATTRIBUTES for
                                        exfsys.USER_EXPFIL_ATTRIBUTES;

grant select on USER_EXPFIL_ATTRIBUTES to public;

COMMENT ON TABLE  user_expfil_attributes IS 
'List of all the elementary attributes in the current schema';

COMMENT ON COLUMN user_expfil_attributes.attribute_set_name IS 
'Name of the attribute set this attribute belongs to';

COMMENT ON COLUMN user_expfil_attributes.attribute IS 
'Name of the attribute';

COMMENT ON COLUMN user_expfil_attributes.data_type IS 
'Datatype of the attribute';

COMMENT ON COLUMN user_expfil_attributes.associated_table IS 
'Table associated with table alias attribute';

COMMENT ON COLUMN user_expfil_attributes.default_value IS 
'String representation of the default value for the attribute'; 

COMMENT ON COLUMN user_expfil_attributes.text_preferences IS
'Preferences for an attribute configured for text predicates';

---
---                      ALL_EXPFIL_ATTRIBUTES    
---            (use the privs of the associated ADT)
create or replace view ALL_EXPFIL_ATTRIBUTES 
  (OWNER, ATTRIBUTE_SET_NAME, ATTRIBUTE, DATA_TYPE, ASSOCIATED_TABLE, 
   DEFAULT_VALUE, TEXT_PREFERENCES) as
 select atsowner, atsname, attrname, attrtype, 
        decode (bitand(attrprop, 16), 16, attrtptab, null), attrdefvl, 
        decode (bitand(attrprop, 32), 32, attrtxtprf, 'N/A')
 from exf$attrlist, all_types ao where
   atsowner = ao.owner and atsname = ao.type_name  
 order by atsowner, atsname, elattrid;

create or replace public synonym ALL_EXPFIL_ATTRIBUTES
  for exfsys.ALL_EXPFIL_ATTRIBUTES;

grant select on ALL_EXPFIL_ATTRIBUTES to public;

COMMENT ON TABLE  all_expfil_attributes IS 
'List of all the elementary attributes accessible to the user';

COMMENT ON COLUMN all_expfil_attributes.owner IS 
'Owner of the attribute set';

COMMENT ON COLUMN all_expfil_attributes.attribute_set_name IS 
'Name of the attribute set this attribute belongs to';

COMMENT ON COLUMN all_expfil_attributes.attribute IS 
'Name of the attribute';

COMMENT ON COLUMN all_expfil_attributes.data_type IS 
'Datatype of the attribute';

COMMENT ON COLUMN all_expfil_attributes.associated_table IS 
'Table associated with table alias attribute';

COMMENT ON COLUMN all_expfil_attributes.default_value IS 
'String representation of the default value for the attribute'; 

COMMENT ON COLUMN all_expfil_attributes.text_preferences IS
'Preferences for an attribute configured for text predicates';

/******************* [USER/ALL]_EXPFIL_DEF_INDEX_PARAMS  *******************/
-- NOTE : This view lists all the attributes that are configired as 
-- stored attributes. These attributes may additionally have INDEXED 
-- property set (implying bitmap index on the attribute) and have 
-- operator list set. Note that XPath parameters(attributes) are  
-- also listed in this view. Additional info about XPath tags can be 
-- obtained from USER_EXPFIL_XPATH_TAGS view.
---
---                      USER_EXPFIL_DEF_INDEX_PARAMS    
--- 
create or replace view USER_EXPFIL_DEF_INDEX_PARAMS
  (ATTRIBUTE_SET_NAME, ATTRIBUTE, DATA_TYPE, ELEMENTARY, INDEXED, 
   OPERATOR_LIST, XMLTYPE_ATTR) as
  select atsname, attrsexp, attrtype,
         decode (bitand(attrprop, 1), 1, 'YES','NO'),
         decode (bitand(attrprop, 8), 8, 'YES','NO'),
         varray2str(attroper), xmltattr
  from exf$defidxparam
  where  atsowner = (select user from dual);

create or replace public synonym USER_EXPFIL_DEF_INDEX_PARAMS for
                             exfsys.USER_EXPFIL_DEF_INDEX_PARAMS;

grant select on USER_EXPFIL_DEF_INDEX_PARAMS to public;

COMMENT ON TABLE  user_expfil_def_index_params IS 
'List of all the stored attributes in the current schema';

COMMENT ON COLUMN user_expfil_def_index_params.attribute_set_name IS 
'Name of the attribute set this attribute belongs to';

COMMENT ON COLUMN user_expfil_def_index_params.attribute IS 
'Name of the attribute';

COMMENT ON COLUMN user_expfil_def_index_params.data_type IS 
'Datatype of the attribute';

COMMENT ON COLUMN user_expfil_def_index_params.elementary IS 
'Field to indicate if the attribute is elementary';

COMMENT ON COLUMN user_expfil_def_index_params.indexed IS 
'Field to indicate if the attribute is indexed in the predicate table';

COMMENT ON COLUMN user_expfil_def_index_params.operator_list IS 
'List of common operators for the attribute';

COMMENT ON COLUMN user_expfil_def_index_params.xmltype_attr IS 
'The XMLType attribute for which the current XPath attribute is defined';

---
---                        ALL_EXPFIL_DEF_INDEX_PARAMS  
---
create or replace view ALL_EXPFIL_DEF_INDEX_PARAMS
  (OWNER, ATTRIBUTE_SET_NAME, ATTRIBUTE, DATA_TYPE, ELEMENTARY, INDEXED, 
   OPERATOR_LIST, XMLTYPE_ATTR) as
  select atsowner, atsname, attrsexp, attrtype,
         decode (bitand(attrprop, 1), 1, 'YES','NO'),
         decode (bitand(attrprop, 8), 8, 'YES','NO'),
         varray2str(attroper), xmltattr
  from exf$defidxparam, all_types ao
  where  atsowner = ao.owner and atsname = ao.type_name;

create or replace public synonym ALL_EXPFIL_DEF_INDEX_PARAMS
  for exfsys.ALL_EXPFIL_DEF_INDEX_PARAMS;

grant select on ALL_EXPFIL_DEF_INDEX_PARAMS to public;

COMMENT ON TABLE  all_expfil_def_index_params IS 
'List of all the stored attributes accessible to the user';

COMMENT ON COLUMN all_expfil_def_index_params.owner IS 
'Owner of the attribute set';

COMMENT ON COLUMN all_expfil_def_index_params.attribute_set_name IS 
'Name of the attribute set this attribute belongs to';

COMMENT ON COLUMN all_expfil_def_index_params.attribute IS 
'Name of the attribute';

COMMENT ON COLUMN all_expfil_def_index_params.data_type IS 
'Datatype of the attribute';

COMMENT ON COLUMN all_expfil_def_index_params.elementary IS 
'Field to indicate if the attribute is elementary';

COMMENT ON COLUMN all_expfil_def_index_params.indexed IS 
'Field to indicate if the attribute is indexed in the predicate table';

COMMENT ON COLUMN all_expfil_def_index_params.operator_list IS 
'List of common operators for the attribute';

COMMENT ON COLUMN all_expfil_def_index_params.xmltype_attr IS 
'The XMLType attribute for which the current XPath attribute is defined';

/************************** ADM_EXPFIL_ATTRIBUTES **************************/
-- This view is a union of the USER_EXPFIL_ATTRIBUTES and 
-- USER_EXPFIL_DEF_INDEX_PARAMS views. This is used by the java 
-- implementation during index maintenance --
--
create or replace view ADM_EXPFIL_ATTRIBUTES
  (OWNER, ATTRIBUTE_SET_NAME, ATTRIBUTE,
   DATA_TYPE, ELEMENTARY, COMPLEX,
   STORED, INDEXED, TABLE_ALIAS,
   OPERATOR_LIST, XMLTYPE_ATTR,  ASSOCIATED_TABLE, DEFAULT_VALUE) as
( select atsowner, atsname, attrname, 
         attrtype, 'YES', 'NO',
        'NO', 'NO', decode (bitand(attrprop, 16), 16, 'YES', 'NO'),
         null, null, attrtptab, attrdefvl
   from exf$attrlist eal where attrname not in (select attrsexp from
    exf$defidxparam dip where eal.atsowner = dip.atsowner and
    eal.atsname = dip.atsname)
  UNION ALL
  select atsowner, atsname, attrsexp,
         attrtype, decode (bitand(attrprop, 1), 1, 'YES','NO'),
                              decode (bitand(attrprop, 1), 1, 'NO','YES'),
         'YES', decode (bitand(attrprop, 8), 8, 'YES','NO'), 'NO',
         varray2str(attroper), xmltattr, null, null
  from exf$defidxparam
  where bitand(attrprop, 4) = 4
);

COMMENT ON TABLE  adm_expfil_attributes IS 
'List of all the attributes in the current instance';

COMMENT ON COLUMN adm_expfil_attributes.owner IS 
'Owner of the attribute set';

COMMENT ON COLUMN adm_expfil_attributes.attribute_set_name IS 
'Name of the attribute set this attribute belongs to';

COMMENT ON COLUMN adm_expfil_attributes.attribute IS 
'Name of the attribute';

COMMENT ON COLUMN adm_expfil_attributes.data_type IS 
'Datatype of the attribute';

COMMENT ON COLUMN adm_expfil_attributes.elementary IS 
'Field to indicate if the attribute is elementary';

COMMENT ON COLUMN adm_expfil_attributes.complex IS 
'Field to indicate if the attribute is complex';

COMMENT ON COLUMN adm_expfil_attributes.stored IS 
'Field to indicate if the attribute is stored in the predicate table';

COMMENT ON COLUMN adm_expfil_attributes.indexed IS 
'Field to indicate if the attribute is indexed in the predicate table';

COMMENT ON COLUMN adm_expfil_attributes.table_alias IS 
'Field to indicate if the elementary attribute is a table alias';

COMMENT ON COLUMN adm_expfil_attributes.operator_list IS 
'List of common operators for the attribute';

COMMENT ON COLUMN adm_expfil_attributes.xmltype_attr IS 
'The XMLType attribute for which the current XPath attribute is defined';

COMMENT ON COLUMN adm_expfil_attributes.associated_table IS 
'Table associated with the embedded ADT / table aliases';

COMMENT ON COLUMN adm_expfil_attributes.default_value IS 
'String representation of the default value for the attribute'; 

/***************** [USER/ALL/ADM]_EXPFIL_INDEX_PARAMS **********************/
-- Unlike the DEFAULT index params which are associated with the attr set, 
-- these are the parameter for an instance of expression set (for the index)
--
--                USER_EXPFIL_INDEX_PARAMS
-- 
create or replace view USER_EXPFIL_INDEX_PARAMS
  (EXPSET_TABLE, EXPSET_COLUMN, ATTRIBUTE, DATA_TYPE, ELEMENTARY,
   INDEXED, OPERATOR_LIST, XMLTYPE_ATTR) as
  select esettabn, esetcoln, attrsexp, attrtype,
         decode (bitand(attrprop, 1), 1, 'YES','NO'),
         decode (bitand(attrprop, 8), 8, 'YES','NO'),
         varray2str(attroper), xmltattr
  from exf$esetidxparam
  where  esetowner = (select user from dual);

create or replace public synonym USER_EXPFIL_INDEX_PARAMS for
                             exfsys.USER_EXPFIL_INDEX_PARAMS;

grant select on USER_EXPFIL_INDEX_PARAMS to public;

COMMENT ON TABLE  user_expfil_index_params IS 
'List of all the stored attributes for index instances in the schema';

COMMENT ON COLUMN user_expfil_index_params.expset_table IS 
'Name of the table storing the expressions';

COMMENT ON COLUMN user_expfil_index_params.expset_column IS 
'Name of the column storing the expressions';

COMMENT ON COLUMN user_expfil_index_params.attribute IS 
'Name of the attribute';

COMMENT ON COLUMN user_expfil_index_params.data_type IS 
'Datatype of the attribute';

COMMENT ON COLUMN user_expfil_index_params.elementary IS 
'Field to indicate if the attribute is elementary';

COMMENT ON COLUMN user_expfil_index_params.indexed IS 
'Field to indicate if the attribute is indexed in the predicate table';

COMMENT ON COLUMN user_expfil_index_params.operator_list IS 
'List of common operators for the attribute';

COMMENT ON COLUMN user_expfil_index_params.xmltype_attr IS 
'The XMLType attribute for which the current XPath attribute is defined';

---
---                        ALL_EXPFIL_INDEX_PARAMS  
---        (using the privs of the table storing expressions)
create or replace view ALL_EXPFIL_INDEX_PARAMS
  (OWNER, EXPSET_TABLE, EXPSET_COLUMN, ATTRIBUTE, DATA_TYPE, ELEMENTARY,
   INDEXED, OPERATOR_LIST, XMLTYPE_ATTR) as
  select esetowner, esettabn, esetcoln, attrsexp, attrtype,
         decode (bitand(attrprop, 1), 1, 'YES','NO'),
         decode (bitand(attrprop, 8), 8, 'YES','NO'),
         varray2str(attroper), xmltattr
  from exf$esetidxparam, all_tables ao
  where  esetowner = ao.owner and esettabn = ao.table_name;

create or replace public synonym ALL_EXPFIL_INDEX_PARAMS
  for exfsys.ALL_EXPFIL_INDEX_PARAMS;

grant select on ALL_EXPFIL_INDEX_PARAMS to public;

COMMENT ON TABLE  all_expfil_index_params IS 
'List of all the stored attributes for index instances accessible to the user';

COMMENT ON COLUMN all_expfil_index_params.owner IS 
'Owner of the Expression Set';

COMMENT ON COLUMN all_expfil_index_params.expset_table IS 
'Name of the table storing the expressions';

COMMENT ON COLUMN all_expfil_index_params.expset_column IS 
'Name of the column storing the expressions';

COMMENT ON COLUMN all_expfil_index_params.attribute IS 
'Name of the attribute';

COMMENT ON COLUMN all_expfil_index_params.data_type IS 
'Datatype of the attribute';

COMMENT ON COLUMN all_expfil_index_params.elementary IS 
'Field to indicate if the attribute is elementary';

COMMENT ON COLUMN all_expfil_index_params.indexed IS 
'Field to indicate if the attribute is indexed in the predicate table';

COMMENT ON COLUMN all_expfil_index_params.operator_list IS 
'List of common operators for the attribute';

COMMENT ON COLUMN all_expfil_index_params.xmltype_attr IS 
'The XMLType attribute for which the current XPath attribute is defined';


---
---                        ADM_EXPFIL_INDEX_PARAMS  
---
create or replace view ADM_EXPFIL_INDEX_PARAMS
  (OWNER, EXPSET_TABLE, EXPSET_COLUMN, ATTRIBUTE, DATA_TYPE, ELEMENTARY,
   INDEXED, OPERATOR_LIST, XMLTYPE_ATTR) as
  select esetowner, esettabn, esetcoln, attrsexp, attrtype,
         decode (bitand(attrprop, 1), 1, 'YES','NO'),
         decode (bitand(attrprop, 8), 8, 'YES','NO'),
         varray2str(attroper), xmltattr
  from exf$esetidxparam;

COMMENT ON TABLE  adm_expfil_index_params IS 
'List of all the stored attributes for all index instances';

COMMENT ON COLUMN adm_expfil_index_params.owner IS 
'Owner of the Expression Set';

COMMENT ON COLUMN adm_expfil_index_params.expset_table IS 
'Name of the table storing the expressions';

COMMENT ON COLUMN adm_expfil_index_params.expset_column IS 
'Name of the column storing the expressions';

COMMENT ON COLUMN adm_expfil_index_params.attribute IS 
'Name of the attribute';

COMMENT ON COLUMN adm_expfil_index_params.data_type IS 
'Datatype of the attribute';

COMMENT ON COLUMN adm_expfil_index_params.elementary IS 
'Field to indicate if the attribute is elementary';

COMMENT ON COLUMN adm_expfil_index_params.indexed IS 
'Field to indicate if the attribute is indexed in the predicate table';

COMMENT ON COLUMN adm_expfil_index_params.operator_list IS 
'List of common operators for the attribute';

COMMENT ON COLUMN adm_expfil_index_params.xmltype_attr IS 
'The XMLType attribute for which the current XPath attribute is defined';


/****************** [USER/ALL/ADM]_EXPFIL_ASET_FUNCTIONS *******************/
--
--                   USER_EXPFIL_ASET_FUNCTIONS
-- 
create or replace view USER_EXPFIL_ASET_FUNCTIONS 
  (ATTRIBUTE_SET_NAME, UDF_NAME, OBJECT_OWNER, OBJECT_NAME, OBJECT_TYPE)
  as
select udfasname, udfname, udfobjown, udfobjnm, udftype from 
   exf$asudflist where udfasoner = (select user from dual);

create or replace public synonym USER_EXPFIL_ASET_FUNCTIONS for 
                                 exfsys.USER_EXPFIL_ASET_FUNCTIONS;

grant select on USER_EXPFIL_ASET_FUNCTIONS to public;

COMMENT ON TABLE USER_EXPFIL_ASET_FUNCTIONS IS 
'List of approved user-defined functions for the attribute sets';

COMMENT ON COLUMN user_expfil_aset_functions.attribute_set_name IS 
'Name of the attribute set';

COMMENT ON COLUMN user_expfil_aset_functions.udf_name IS 
'Name of the user-defined FUNCTION/PACKAGE/TYPE';

COMMENT ON COLUMN user_expfil_aset_functions.object_owner IS 
'Owner of the object';

COMMENT ON COLUMN user_expfil_aset_functions.object_name IS 
'Name of the object';

COMMENT ON COLUMN user_expfil_aset_functions.object_type IS 
'Type of the object - FUNCTION/PACKAGE/TYPE';

---
---             ALL_EXPFIL_ASET_FUNCTIONS
---    (use privs of the associated attribute set type)
create or replace view ALL_EXPFIL_ASET_FUNCTIONS 
  (OWNER, ATTRIBUTE_SET_NAME, UDF_NAME, OBJECT_OWNER, 
   OBJECT_NAME, OBJECT_TYPE)
  as
select udfasoner, udfasname, udfname, udfobjown, udfobjnm, udftype from 
   exf$asudflist, all_types ao where 
   udfasoner = ao.owner and udfasname = ao.type_name;

create or replace public synonym ALL_EXPFIL_ASET_FUNCTIONS
  for exfsys.ALL_EXPFIL_ASET_FUNCTIONS;

grant select on ALL_EXPFIL_ASET_FUNCTIONS to public;

COMMENT ON TABLE ALL_EXPFIL_ASET_FUNCTIONS IS 
'List of approved user-defined functions for the attribute sets accessible
 to the user';

COMMENT ON COLUMN all_expfil_aset_functions.owner IS 
'Owner of the attribute set';

COMMENT ON COLUMN all_expfil_aset_functions.attribute_set_name IS 
'Name of the attribute set';

COMMENT ON COLUMN all_expfil_aset_functions.udf_name IS 
'Name of the user-defined FUNCTION/PACKAGE/TYPE';

COMMENT ON COLUMN all_expfil_aset_functions.object_owner IS 
'Owner of the object';

COMMENT ON COLUMN all_expfil_aset_functions.object_name IS 
'Name of the object';

COMMENT ON COLUMN all_expfil_aset_functions.object_type IS 
'Type of the object - FUNCTION/PACKAGE/TYPE';

---
---             ADM_EXPFIL_ASET_FUNCTIONS
---
create or replace view ADM_EXPFIL_ASET_FUNCTIONS 
  (OWNER, ATTRIBUTE_SET_NAME, UDF_NAME, OBJECT_OWNER, 
   OBJECT_NAME, OBJECT_TYPE)
  as
select udfasoner, udfasname, udfname, udfobjown, udfobjnm, udftype from 
   exf$asudflist;

COMMENT ON TABLE ADM_EXPFIL_ASET_FUNCTIONS IS 
'List of approved user-defined functions for the attribute sets';

COMMENT ON COLUMN adm_expfil_aset_functions.owner IS 
'Owner of the attribute set';

COMMENT ON COLUMN adm_expfil_aset_functions.attribute_set_name IS 
'Name of the attribute set';

COMMENT ON COLUMN adm_expfil_aset_functions.udf_name IS 
'Name of the user-defined FUNCTION/PACKAGE/TYPE';

COMMENT ON COLUMN adm_expfil_aset_functions.object_owner IS 
'Owner of the object';

COMMENT ON COLUMN adm_expfil_aset_functions.object_name IS 
'Name of the object';

COMMENT ON COLUMN adm_expfil_aset_functions.object_type IS 
'Type of the object - FUNCTION/PACKAGE/TYPE';
   
/*******************  [USER/ALL/ADM]_EXPFIL_XPATH_TAGS *********************/
---
---                   USER_EXPFIL_XPATH_TAGS
---
create or replace view USER_EXPFIL_XPATH_TAGS 
  (ATTRIBUTE_SET_NAME, XMLTYPE_ATTRIBUTE, XPATH_TAG, DATA_TYPE, TAG_TYPE,
   FILTER_TYPE) as
  select atsname, xmltattr, attrsexp, attrtype, 
     decode(bitand(attrprop, 32), 32, 'XML ELEMENT', 
            decode(bitand(attrprop, 64), 64, 'XML ATTRIBUTE', null)), 
     decode(bitand(attrprop, 128), 128, 'POSITIONAL',
            decode(bitand(attrprop, 256), 256, 'VALUE BASED', null))
   from exf$defidxparam where xmltattr is not null and 
        atsowner = (select user from dual);

--
--create or replace public synonym USER_EXPFIL_XPATH_TAGS for
--                                        exfsys.USER_EXPFIL_XPATH_TAGS;

grant select on USER_EXPFIL_XPATH_TAGS to public;

COMMENT ON TABLE user_expfil_xpath_tags IS 
'List of all the XPath Tags in the attribute sets';

COMMENT ON COLUMN user_expfil_xpath_tags.attribute_set_name IS 
'Name of the attribute set a XPath Tag belongs';

COMMENT ON COLUMN user_expfil_xpath_tags.xmltype_attribute IS
'Name of the XMLType attribute for which this XPath Tag is defined';

COMMENT ON COLUMN user_expfil_xpath_tags.xpath_tag IS 
'Name of the XPath Tag';

COMMENT ON COLUMN user_expfil_xpath_tags.data_type IS 
'Datatype of the values for the XPath tag';

COMMENT ON COLUMN user_expfil_xpath_tags.tag_type IS 
'Type of the Tag - XML ELEMENT or XML ATTRIBUTE';

COMMENT ON COLUMN user_expfil_xpath_tags.filter_type IS 
'Type of filter for the XPath tag - POSITIONAL/ VALUE BASED';

---
---               ALL_EXPFIL_XPATH_TAGS
---     (use privs of the associated attribute set type)
create or replace view ALL_EXPFIL_XPATH_TAGS 
  (OWNER, ATTRIBUTE_SET_NAME, XMLTYPE_ATTRIBUTE, XPATH_TAG, DATA_TYPE,
   TAG_TYPE, FILTER_TYPE) as
  select atsowner, atsname, xmltattr, attrsexp, attrtype, 
     decode(bitand(attrprop, 32), 32, 'XML ELEMENT', 
            decode(bitand(attrprop, 64), 64, 'XML ATTRIBUTE', null)), 
     decode(bitand(attrprop, 128), 128, 'POSITIONAL',
            decode(bitand(attrprop, 256), 256, 'VALUE BASED', null))
   from exf$defidxparam, all_types ao where
  atsowner = ao.owner and atsname = ao.type_name and xmltattr is not null;

--
--create or replace public synonym ALL_EXPFIL_ASET_FUNCTIONS
--  for exfsys.ALL_EXPFIL_ASET_FUNCTIONS;
--
grant select on ALL_EXPFIL_ASET_FUNCTIONS to public;

COMMENT ON TABLE all_expfil_xpath_tags IS 
'List of all the XPath Tags in the attribute sets accessible to the user';

COMMENT ON COLUMN all_expfil_xpath_tags.owner IS 
'Schema owning the attribute set with the XPath tags';

COMMENT ON COLUMN all_expfil_xpath_tags.attribute_set_name IS 
'Name of the attribute set a XPath Tag belongs';

COMMENT ON COLUMN all_expfil_xpath_tags.xmltype_attribute IS
'Name of the XMLType attribute for which this XPath Tag is defined';

COMMENT ON COLUMN all_expfil_xpath_tags.xpath_tag IS 
'Name of the XPath Tag';

COMMENT ON COLUMN all_expfil_xpath_tags.data_type IS 
'Datatype of the values for the XPath tag';

COMMENT ON COLUMN all_expfil_xpath_tags.tag_type IS 
'Type of the Tag - XML ELEMENT or XML ATTRIBUTE';

COMMENT ON COLUMN all_expfil_xpath_tags.filter_type IS 
'Type of filter for the XPath tag - POSITIONAL/ VALUE BASED';

---
---                    ADM_EXPFIL_XPATH_TAGS
---
create or replace view ADM_EXPFIL_XPATH_TAGS 
  (OWNER, ATTRIBUTE_SET_NAME, XMLTYPE_ATTRIBUTE, XPATH_TAG, DATA_TYPE,
   TAG_TYPE, FILTER_TYPE) as
  select atsowner, atsname, xmltattr, attrsexp, attrtype, 
     decode(bitand(attrprop, 32), 32, 'XML ELEMENT', 
            decode(bitand(attrprop, 64), 64, 'XML ATTRIBUTE', null)), 
     decode(bitand(attrprop, 128), 128, 'POSITIONAL',
            decode(bitand(attrprop, 256), 256, 'VALUE BASED', null))
   from exf$defidxparam where xmltattr is not null;

COMMENT ON TABLE adm_expfil_xpath_tags IS 
'List of all the XPath Tags in the attribute sets';

COMMENT ON COLUMN adm_expfil_xpath_tags.owner IS 
'Schema owning the attribute set with the XPath tags';

COMMENT ON COLUMN adm_expfil_xpath_tags.attribute_set_name IS 
'Name of the attribute set a XPath Tag belongs';

COMMENT ON COLUMN adm_expfil_xpath_tags.xmltype_attribute IS
'Name of the XMLType attribute for which this XPath Tag is defined';

COMMENT ON COLUMN adm_expfil_xpath_tags.xpath_tag IS 
'Name of the XPath Tag';

COMMENT ON COLUMN adm_expfil_xpath_tags.data_type IS 
'Datatype of the values for the XPath tag';

COMMENT ON COLUMN adm_expfil_xpath_tags.tag_type IS 
'Type of the Tag - XML ELEMENT or XML ATTRIBUTE';

COMMENT ON COLUMN adm_expfil_xpath_tags.filter_type IS 
'Type of filter for the XPath tag - POSITIONAL/ VALUE BASED';

/***************** [USER/SCH/ALL/ADM]_EXPFIL_INDEXES ***********************/
---
---                    USER_EXPFIL_INDEXES
---
create or replace view USER_EXPFIL_INDEXES 
  (INDEX_NAME, PREDICATE_TABLE, ACCESS_FUNC_PACKAGE, ATTRIBUTE_SET, 
   EXPRESSION_TABLE, EXPRESSION_COLUMN, STATUS, FUNC_CPU_COST, 
   FUNC_IO_COST, INDEX_SELECTIVITY, INDEX_CPU_COST, INDEX_IO_COST)
  as
  select io.idxname, io.idxpredtab, io.idxaccfunc, io.idxattrset, 
         io.idxesettab, idxesetcol, io.idxstatus, io.optfccpuct, 
         io.optfcioct, io.optixselvt, io.optixcpuct, io.optixioct
  from exf$idxsecobj io
  where io.idxowner = (select user from dual);

create or replace public synonym USER_EXPFIL_INDEXES for
                                        exfsys.USER_EXPFIL_INDEXES;

grant select on USER_EXPFIL_INDEXES to public;

COMMENT ON TABLE user_expfil_indexes IS 
'List of all the expression filter indexes in this schema';

COMMENT ON COLUMN user_expfil_indexes.index_name IS 
'Name of the index';

COMMENT ON COLUMN user_expfil_indexes.predicate_table IS
'Predicate table associated with the index';

COMMENT ON COLUMN user_expfil_indexes.access_func_package IS 
'System generated package that implements the index''s access function';
 
COMMENT ON COLUMN user_expfil_indexes.attribute_set IS 
'Name of the attribute set used for this index';

COMMENT ON COLUMN user_expfil_indexes.expression_table IS 
'The table storing the expression set corresponding to this index';

COMMENT ON COLUMN user_expfil_indexes.expression_column IS
'The column storing the expression set corresponding to this index';
 
COMMENT ON COLUMN user_expfil_indexes.status IS
'The current status of the index : VALID, FAILED [IMP], INPROGRESS';

COMMENT ON COLUMN user_expfil_indexes.func_cpu_cost IS 
'Estimated CPU cost for function based evaluation of each expression';

COMMENT ON COLUMN user_expfil_indexes.func_io_cost IS 
'Estimated I/O cost for function based evaluation of each expression';

COMMENT ON COLUMN user_expfil_indexes.index_selectivity IS 
'Estimated selectivity of the index';

COMMENT ON COLUMN user_expfil_indexes.index_cpu_cost IS 
'Estimated CPU cost for the index based evaluation of expressions';

COMMENT ON COLUMN user_expfil_indexes.index_io_cost IS 
'Estimated I/O cost for the index based evaluation of expressions'; 

---
---                    SCH_EXPFIL_INDEXES
--- This view is used by the IndexStart implementation and is not 
--- required by the end user. This view performs better than the 
--- ALL_EXPFIL_INDEXES as it does not need priviledge info.
--- The user query already goes through privilege checks for the 
--- table and the ind$ index entry. 
--- 
create or replace view SCH_EXPFIL_INDEXES 
  (INDEX_NAME, PREDICATE_TABLE, ACCESS_FUNC_PACKAGE, ATTRIBUTE_SET, 
   EXPRESSION_TABLE, EXPRESSION_COLUMN, FUNC_CPU_COST, FUNC_IO_COST,
   INDEX_SELECTIVITY, INDEX_CPU_COST, INDEX_IO_COST, PTAB_FULLIO_COST)
  as
  select io.idxname, io.idxpredtab, io.idxaccfunc, io.idxattrset,
         io.idxesettab, idxesetcol, io.optfccpuct, io.optfcioct, 
         io.optixselvt, io.optixcpuct, io.optixioct, io.optptfscct
  from exf$idxsecobj io
  where io.idxowner = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');

grant select on exfsys.SCH_EXPFIL_INDEXES to public;

---
---                    ALL_EXPFIL_INDEXES
---                (use privs of the index)
create or replace view ALL_EXPFIL_INDEXES
  (OWNER, INDEX_NAME, PREDICATE_TABLE, ACCESS_FUNC_PACKAGE, ATTRIBUTE_SET,
   EXPRESSION_TABLE, EXPRESSION_COLUMN, STATUS, FUNC_CPU_COST,
   FUNC_IO_COST, INDEX_SELECTIVITY, INDEX_CPU_COST, INDEX_IO_COST)
  as
  select io.idxowner, io.idxname, io.idxpredtab, io.idxaccfunc,
         io.idxattrset, io.idxesettab, idxesetcol, io.idxstatus,
         io.optfccpuct, io.optfcioct, io.optixselvt, io.optixcpuct, 
         io.optixioct
  from exf$idxsecobj io, all_indexes ai
  where io.idxowner = ai.owner and io.idxname = ai.index_name;

create or replace public synonym ALL_EXPFIL_INDEXES
  for exfsys.ALL_EXPFIL_INDEXES;

grant select on ALL_EXPFIL_INDEXES to public;

COMMENT ON TABLE all_expfil_indexes IS 
'List of all the expression filter indexes in this instance';

COMMENT ON COLUMN all_expfil_indexes.owner IS 
'Owner of the index';

COMMENT ON COLUMN all_expfil_indexes.index_name IS 
'Name of the index';

COMMENT ON COLUMN all_expfil_indexes.predicate_table IS
'Predicate table associated with the index';

COMMENT ON COLUMN all_expfil_indexes.access_func_package IS 
'System generated package that implements the index''s access function';
 
COMMENT ON COLUMN all_expfil_indexes.attribute_set IS 
'Name of the attribute set used for this index';

COMMENT ON COLUMN all_expfil_indexes.expression_table IS 
'The table storing the expression set corresponding to this index';

COMMENT ON COLUMN all_expfil_indexes.expression_column IS
'The column storing the expression set corresponding to this index';
 
COMMENT ON COLUMN all_expfil_indexes.status IS
'The current status of the index : VALID, FAILED [IMP], INPROGRESS';

COMMENT ON COLUMN all_expfil_indexes.func_cpu_cost IS 
'Estimated CPU cost for function based evaluation of each expression'; 

COMMENT ON COLUMN all_expfil_indexes.func_io_cost IS 
'Estimated I/O cost for function based evaluation of each expression';

COMMENT ON COLUMN all_expfil_indexes.index_selectivity IS 
'Estimated selectivity of the index';

COMMENT ON COLUMN all_expfil_indexes.index_cpu_cost IS 
'Estimated CPU cost for the index based evaluation of expressions';

COMMENT ON COLUMN all_expfil_indexes.index_io_cost IS 
'Estimated I/O cost for the index based evaluation of expressions';
 
---
---                    ADM_EXPFIL_INDEXES
---                
create or replace view ADM_EXPFIL_INDEXES 
  (OWNER, INDEX_NAME, PREDICATE_TABLE, ACCESS_FUNC_PACKAGE, ATTRIBUTE_SET, 
   EXPRESSION_TABLE, EXPRESSION_COLUMN, STATUS)
  as
  select io.idxowner, io.idxname, io.idxpredtab, io.idxaccfunc,
         io.idxattrset, io.idxesettab, idxesetcol, io.idxstatus
  from exf$idxsecobj io;

COMMENT ON TABLE adm_expfil_indexes IS 
'List of all the expression filter indexes in this instance';

COMMENT ON COLUMN adm_expfil_indexes.owner IS 
'Owner of the index';

COMMENT ON COLUMN adm_expfil_indexes.index_name IS 
'Name of the index';

COMMENT ON COLUMN adm_expfil_indexes.predicate_table IS
'Predicate table associated with the index';

COMMENT ON COLUMN adm_expfil_indexes.access_func_package IS 
'System generated package that implements the index''s access function';
 
COMMENT ON COLUMN adm_expfil_indexes.attribute_set IS 
'Name of the attribute set used for this index';

COMMENT ON COLUMN adm_expfil_indexes.expression_table IS 
'The table storing the expression set corresponding to this index';

COMMENT ON COLUMN adm_expfil_indexes.expression_column IS
'The column storing the expression set corresponding to this index';
 
COMMENT ON COLUMN adm_expfil_indexes.status IS
'The current status of the index : VALID, FAILED [IMP], INPROGRESS';
 
/***************** [USER/ALL/ADM]_EXPFIL_PREDTAB_ATTRIBUTES ****************/
---
---                    USER_EXPFIL_PREDTAB_ATTRIBUTES
--- 
create or replace view USER_EXPFIL_PREDTAB_ATTRIBUTES
  (INDEX_NAME, ATTRIBUTE_ID, ATTRIBUTE_ALIAS, SUBEXPRESSION, DATA_TYPE,
  STORED, INDEXED, OPERATOR_LIST, XMLTYPE_ATTR, XPTAG_TYPE, XPFILTER_TYPE) 
  as select io.idxname, pc.ptattrid, pc.ptattralias, pc.ptattrsexp,
  pc.ptattrtype, decode (bitand(pc.ptattrprop, 1), 1, 'YES','NO'), 
  decode (bitand(pc.ptattrprop, 2), 2, 'YES','NO'), varray2str(ptattroper), 
  pc.xmltattr, decode(bitand(ptattrprop, 8), 8, 'XML ELEMENT', 
              decode(bitand(ptattrprop, 16), 16, 'XML ATTRIBUTE', null)), 
  decode(bitand(ptattrprop, 32), 32, 'POSITIONAL',
         decode(bitand(ptattrprop, 128), 128, 'CHAR VALUE', 
           decode(bitand(ptattrprop, 256), 256, 'INT VALUE',
             decode(bitand(ptattrprop, 512), 512, 'DATE VALUE', null))))
  from exf$predattrmap pc, exf$idxsecobj io
  where io.idxobj# = pc.ptidxobj# and io.idxowner = (select user from dual)
        and bitand(ptattrprop, 1024) = 0;

create or replace public synonym USER_EXPFIL_PREDTAB_ATTRIBUTES for
                                    exfsys.USER_EXPFIL_PREDTAB_ATTRIBUTES;

grant select on USER_EXPFIL_PREDTAB_ATTRIBUTES to public;

COMMENT ON TABLE user_expfil_predtab_attributes IS
'List of all the predicate table attributes in this schema';

COMMENT ON COLUMN user_expfil_predtab_attributes.index_name IS 
'Name of the index associated with the predicate table';

COMMENT ON COLUMN user_expfil_predtab_attributes.attribute_id IS 
'Identifier for the predicate table attribute';

COMMENT ON COLUMN user_expfil_predtab_attributes.attribute_alias IS 
'Alias for the predicate table attribute';

COMMENT ON COLUMN user_expfil_predtab_attributes.subexpression IS 
'Sub-expression representing the complex or elementary attribute';

COMMENT ON COLUMN user_expfil_predtab_attributes.data_type IS
'Resulting datatype of the sub-expression';

COMMENT ON COLUMN user_expfil_predtab_attributes.stored IS
'Field to indicate if the attribute is stored in the predicate table';

COMMENT ON COLUMN user_expfil_predtab_attributes.indexed IS
'Field to indicate if the attribute is indexed in the predicate table';

COMMENT ON COLUMN user_expfil_predtab_attributes.operator_list IS 
'List of common operators for the attribute';

COMMENT ON COLUMN user_expfil_predtab_attributes.xmltype_attr IS 
'The XMLType attribute for which the current XPath attribute is defined';

COMMENT ON COLUMN user_expfil_predtab_attributes.xptag_type IS 
'Type of the Tag - XML ELEMENT or XML ATTRIBUTE';

COMMENT ON COLUMN user_expfil_predtab_attributes.xpfilter_type IS 
'Type of filter for the XPath tag - POSITIONAL/ [CHAR|INT|DATE] VALUE ';

---
---                    ALL_EXPFIL_PREDTAB_ATTRIBUTES
---                 (use privs of the index object)
create or replace view ALL_EXPFIL_PREDTAB_ATTRIBUTES
  (OWNER, INDEX_NAME, ATTRIBUTE_ID, ATTRIBUTE_ALIAS, SUBEXPRESSION, DATA_TYPE,
  STORED, INDEXED, OPERATOR_LIST, XMLTYPE_ATTR, XPTAG_TYPE, XPFILTER_TYPE)
  as select io.idxowner, io.idxName, pc.ptattrid, pc.ptattralias,
  pc.ptattrsexp, pc.ptattrtype, 
  decode (bitand(pc.ptattrprop, 1), 1, 'YES','NO'),
  decode (bitand(pc.ptattrprop, 2), 2, 'YES','NO'), varray2str(ptattroper), 
  pc.xmltattr, decode(bitand(ptattrprop, 8), 8, 'XML ELEMENT', 
              decode(bitand(ptattrprop, 16), 16, 'XML ATTRIBUTE', null)), 
  decode(bitand(ptattrprop, 32), 32, 'POSITIONAL',
         decode(bitand(ptattrprop, 128), 128, 'CHAR VALUE', 
           decode(bitand(ptattrprop, 256), 256, 'INT VALUE',
             decode(bitand(ptattrprop, 512), 512, 'DATE VALUE', null))))
  from exf$predattrmap pc, exf$idxsecobj io, all_indexes ai
  where io.idxobj# = pc.ptidxobj# and io.idxowner = ai.owner
  and io.idxname = ai.index_name;

create or replace public synonym ALL_EXPFIL_PREDTAB_ATTRIBUTES for
                                    exfsys.ALL_EXPFIL_PREDTAB_ATTRIBUTES;

grant select on ALL_EXPFIL_PREDTAB_ATTRIBUTES to public;

COMMENT ON TABLE all_expfil_predtab_attributes IS
'List of all the predicate table attributes';

COMMENT ON COLUMN all_expfil_predtab_attributes.owner IS 
'Owner of the index';

COMMENT ON COLUMN all_expfil_predtab_attributes.index_name IS 
'Name of the index associated with the predicate table';

COMMENT ON COLUMN all_expfil_predtab_attributes.attribute_id IS 
'Identifier for the predicate table attribute';

COMMENT ON COLUMN all_expfil_predtab_attributes.attribute_alias IS 
'Alias for the predicate table attribute';

COMMENT ON COLUMN all_expfil_predtab_attributes.subexpression IS 
'Sub-expression representing the complex or elementary attribute';

COMMENT ON COLUMN all_expfil_predtab_attributes.data_type IS
'Resulting datatype of the sub-expression';

COMMENT ON COLUMN all_expfil_predtab_attributes.stored IS
'Field to indicate if the attribute is stored in the predicate table';

COMMENT ON COLUMN all_expfil_predtab_attributes.indexed IS
'Field to indicate if the attribute is indexed in the predicate table';

COMMENT ON COLUMN all_expfil_predtab_attributes.operator_list IS 
'List of common operators for the attribute';

COMMENT ON COLUMN all_expfil_predtab_attributes.xmltype_attr IS 
'The XMLType attribute for which the current XPath attribute is defined';

COMMENT ON COLUMN all_expfil_predtab_attributes.xptag_type IS 
'Type of the Tag - XML ELEMENT or XML ATTRIBUTE';

COMMENT ON COLUMN all_expfil_predtab_attributes.xpfilter_type IS 
'Type of filter for the XPath tag - POSITIONAL/ [CHAR|INT|DATE] VALUE ';

---
---                    ADM_EXPFIL_PREDTAB_ATTRIBUTES
---
create or replace view ADM_EXPFIL_PREDTAB_ATTRIBUTES
  (OWNER, INDEX_NAME, ATTRIBUTE_ID, ATTRIBUTE_ALIAS, SUBEXPRESSION, DATA_TYPE,
  STORED, INDEXED, OPERATOR_LIST, XMLTYPE_ATTR, XPTAG_TYPE, XPFILTER_TYPE) 
  as select io.idxowner, io.idxName, pc.ptattrid, pc.ptattralias,
  pc.ptattrsexp, pc.ptattrtype, 
  decode (bitand(pc.ptattrprop, 1), 1, 'YES','NO'),
  decode (bitand(pc.ptattrprop, 2), 2, 'YES','NO'), varray2str(ptattroper), 
  pc.xmltattr, decode(bitand(ptattrprop, 8), 8, 'XML ELEMENT', 
         decode(bitand(ptattrprop, 16), 16, 'XML ATTRIBUTE', null)), 
  decode(bitand(ptattrprop, 32), 32, 'POSITIONAL',
         decode(bitand(ptattrprop, 128), 128, 'CHAR VALUE', 
           decode(bitand(ptattrprop, 256), 256, 'INT VALUE',
             decode(bitand(ptattrprop, 512), 512, 'DATE VALUE', null))))
  from exf$predattrmap pc, exf$idxsecobj io
  where io.idxobj# = pc.ptidxobj#;

COMMENT ON TABLE adm_expfil_predtab_attributes IS
'List of all the predicate table attributes';

COMMENT ON COLUMN adm_expfil_predtab_attributes.owner IS 
'Owner of the index';

COMMENT ON COLUMN adm_expfil_predtab_attributes.index_name IS 
'Name of the index associated with the predicate table';

COMMENT ON COLUMN adm_expfil_predtab_attributes.attribute_id IS 
'Identifier for the predicate table attribute';

COMMENT ON COLUMN adm_expfil_predtab_attributes.attribute_alias IS 
'Alias for the predicate table attribute';

COMMENT ON COLUMN adm_expfil_predtab_attributes.subexpression IS 
'Sub-expression representing the complex or elementary attribute';

COMMENT ON COLUMN adm_expfil_predtab_attributes.data_type IS
'Resulting datatype of the sub-expression';

COMMENT ON COLUMN adm_expfil_predtab_attributes.stored IS
'Field to indicate if the attribute is stored in the predicate table';

COMMENT ON COLUMN adm_expfil_predtab_attributes.indexed IS
'Field to indicate if the attribute is indexed in the predicate table';

COMMENT ON COLUMN adm_expfil_predtab_attributes.operator_list IS 
'List of common operators for the attribute';

COMMENT ON COLUMN adm_expfil_predtab_attributes.xmltype_attr IS 
'The XMLType attribute for which the current XPath attribute is defined';

COMMENT ON COLUMN adm_expfil_predtab_attributes.xptag_type IS 
'Type of the Tag - XML ELEMENT or XML ATTRIBUTE';

COMMENT ON COLUMN adm_expfil_predtab_attributes.xpfilter_type IS 
'Type of filter for the XPath tag - POSITIONAL/ [CHAR|INT|DATE] VALUE ';

/***************** [USER/ALL/ADM]_EXPFIL_EXPRESSION_SETS *******************/
---
---                USER_EXPFIL_EXPRESSION_SETS
---
create or replace view USER_EXPFIL_EXPRESSION_SETS 
  (EXPR_TABLE, EXPR_COLUMN, ATTRIBUTE_SET, LAST_ANALYZED,
   NUM_EXPRESSIONS, PREDS_PER_EXPR, NUM_SPARSE_PREDS)
  as select exstabnm, exscolnm, exsatsnm, exsetlanl, exsetnexp,
            avgprpexp, exsetsprp from exf$exprset
  where exsowner = (select user from dual);
        

create or replace public synonym USER_EXPFIL_EXPRESSION_SETS for
                                    exfsys.USER_EXPFIL_EXPRESSION_SETS;

grant select on USER_EXPFIL_EXPRESSION_SETS to public;

COMMENT ON TABLE user_expfil_expression_sets IS
'List of expression sets in the current schema';

COMMENT ON COLUMN user_expfil_expression_sets.expr_table IS
'The table storing the expression set in the current schema';

COMMENT ON COLUMN user_expfil_expression_sets.expr_column IS
'The column storing the expression set';

COMMENT ON COLUMN user_expfil_expression_sets.attribute_set IS 
'Attribute set used for the expression set';

COMMENT ON COLUMN user_expfil_expression_sets.last_analyzed IS 
'The date of the most recent time the expression set is analyzed';

COMMENT ON COLUMN user_expfil_expression_sets.num_expressions IS 
'Number of expressions (disjunctions) in the expression set';

COMMENT ON COLUMN user_expfil_expression_sets.preds_per_expr IS
'Average number of conjunctive predicates per expressions';

COMMENT ON COLUMN user_expfil_expression_sets.num_sparse_preds IS
'Number of sparse predicates in the expression set';

---
---                ALL_EXPFIL_EXPRESSION_SETS
---      (use privs of the table storing expressions)
create or replace view ALL_EXPFIL_EXPRESSION_SETS 
  (OWNER, EXPR_TABLE, EXPR_COLUMN, ATTRIBUTE_SET,
   LAST_ANALYZED, NUM_EXPRESSIONS, PREDS_PER_EXPR, NUM_SPARSE_PREDS)
  as select exsowner, exstabnm, exscolnm, exsatsnm, 
            exsetlanl, exsetnexp, avgprpexp, exsetsprp 
  from exf$exprset, all_tables at
  where at.owner = exsowner and at.table_name = exstabnm;

create or replace public synonym ALL_EXPFIL_EXPRESSION_SETS for
                                    exfsys.ALL_EXPFIL_EXPRESSION_SETS;

grant select on ALL_EXPFIL_EXPRESSION_SETS to public;

COMMENT ON TABLE all_expfil_expression_sets IS
'List of expression sets accessible to the current user';

COMMENT ON COLUMN all_expfil_expression_sets.owner IS
'Owner of the expression set';

COMMENT ON COLUMN all_expfil_expression_sets.expr_table IS
'The table storing the expression set in the owner''s schema';

COMMENT ON COLUMN all_expfil_expression_sets.expr_column IS
'The column storing the expression set';

COMMENT ON COLUMN all_expfil_expression_sets.attribute_set IS 
'Attribute set used for the expression set';

COMMENT ON COLUMN all_expfil_expression_sets.last_analyzed IS 
'The date of the most recent time the expression set is analyzed';

COMMENT ON COLUMN all_expfil_expression_sets.num_expressions IS 
'Number of expressions (disjunctions) in the expression set';

COMMENT ON COLUMN all_expfil_expression_sets.preds_per_expr IS
'Average number of conjunctive predicates per expressions';

COMMENT ON COLUMN all_expfil_expression_sets.num_sparse_preds IS
'Number of sparse predicates in the expression set';

---
---                ADM_EXPFIL_EXPRESSION_SETS
---
create or replace view ADM_EXPFIL_EXPRESSION_SETS 
  (OWNER, EXPR_TABLE, EXPR_COLUMN, ATTRIBUTE_SET, PRIVILEGE_TRIGGER,
   LAST_ANALYZED, NUM_EXPRESSIONS, PREDS_PER_EXPR, NUM_SPARSE_PREDS)
  as select exsowner, exstabnm, exscolnm, exsatsnm, exsprvtrig, 
            exsetlanl, exsetnexp, avgprpexp, exsetsprp from exf$exprset;

COMMENT ON TABLE adm_expfil_expression_sets IS
'List of expression sets';

COMMENT ON COLUMN adm_expfil_expression_sets.owner IS
'Owner of the expression set';

COMMENT ON COLUMN adm_expfil_expression_sets.expr_table IS
'The table storing the expression set in the owner''s schema';

COMMENT ON COLUMN adm_expfil_expression_sets.expr_column IS
'The column storing the expression set';

COMMENT ON COLUMN adm_expfil_expression_sets.attribute_set IS 
'Attribute set used for the expression set';

COMMENT ON COLUMN adm_expfil_expression_sets.privilege_trigger IS 
'Trigger used to enforce the privileges for the expression set';

COMMENT ON COLUMN adm_expfil_expression_sets.last_analyzed IS 
'The date of the most recent time the expression set is analyzed';

COMMENT ON COLUMN adm_expfil_expression_sets.num_expressions IS 
'Number of expressions (disjunctions) in the expression set';

COMMENT ON COLUMN adm_expfil_expression_sets.preds_per_expr IS
'Average number of conjunctive predicates per expressions';

COMMENT ON COLUMN adm_expfil_expression_sets.num_sparse_preds IS
'Number of sparse predicates in the expression set';

/************************ [USER/ADM]_EXPFIL_PRIVELEGES *********************/
---
---                   USER_EXPFIL_PRIVILEGES
---
create or replace view USER_EXPFIL_PRIVILEGES 
 (EXPSET_OWNER, EXPSET_TABLE, EXPSET_COLUMN, GRANTEE, INSERT_PRIV, 
  UPDATE_PRIV) as
 select esowner, esexptab, esexpcol, esgrantee, escrtpriv, esupdpriv from
   exf$expsetprivs where esgrantee = 'PUBLIC' or
    esgrantee = (select user from dual) or
    esowner = (select user from dual);

create or replace public synonym USER_EXPFIL_PRIVILEGES for
                                    exfsys.USER_EXPFIL_PRIVILEGES;

grant select on USER_EXPFIL_PRIVILEGES to public;

COMMENT ON TABLE user_expfil_privileges IS 
'Privileges for Expression set modifications';

COMMENT ON COLUMN user_expfil_privileges.expset_owner IS
'Owner of the table storing the expression set. Also the grantor';

COMMENT ON COLUMN user_expfil_privileges.expset_table IS
'The table storing the expression set in the owner''s schema';

COMMENT ON COLUMN user_expfil_privileges.expset_column IS
'The column storing the expression set';

COMMENT ON COLUMN user_expfil_privileges.grantee IS
'Grantee of the privilege. PUBLIC or the current user';

COMMENT ON COLUMN user_expfil_privileges.insert_priv IS
'Current user''s privilege to create new expressions in the set';

COMMENT ON COLUMN user_expfil_privileges.update_priv IS
'Current user''s privilege to modify existing expressions in the set';

---
---                   ADM_EXPFIL_PRIVELEGES
---
create or replace view ADM_EXPFIL_PRIVILEGES 
 (EXPSET_OWNER, EXPSET_TABLE, EXPSET_COLUMN, GRANTEE, INSERT_PRIV, 
  UPDATE_PRIV) as
 select esowner, esexptab, esexpcol, esgrantee, escrtpriv, esupdpriv from
   exf$expsetprivs;

COMMENT ON TABLE adm_expfil_privileges IS 
'Privileges for Expression set modifications';

COMMENT ON COLUMN adm_expfil_privileges.expset_owner IS
'Owner of the table storing the expression set. Also the grantor';

COMMENT ON COLUMN adm_expfil_privileges.expset_table IS
'The table storing the expression set in the owner''s schema';

COMMENT ON COLUMN adm_expfil_privileges.expset_column IS
'The column storing the expression set';

COMMENT ON COLUMN adm_expfil_privileges.grantee IS
'Grantee of the privilege. PUBLIC implies any user';

COMMENT ON COLUMN user_expfil_privileges.insert_priv IS
'Grantee''s privilege to create new expressions in the set';

COMMENT ON COLUMN user_expfil_privileges.update_priv IS
'Grantee''s privilege to modify existing expressions in the set';

/******************* [USER/ALL/ADM]_EXPFIL_EXPRSET_STATS *******************/
---
---                   USER_EXPFIL_EXPRSET_STATS
---
create or replace view USER_EXPFIL_EXPRSET_STATS 
  (EXPR_TABLE, EXPR_COLUMN, ATTRIBUTE_EXP, PCT_OCCURRENCE, 
   PCT_EQ_OPER, PCT_LT_OPER, PCT_GT_OPER, PCT_LTEQ_OPER, PCT_GTEQ_OPER, 
   PCT_NEQ_OPER, PCT_NUL_OPER, PCT_NNUL_OPER, PCT_BETW_OPER, PCT_NVL_OPER, 
   PCT_LIKE_OPER)
  as 
 select e.ESETTABLE, e.ESETCOLUMN, e.PREDLHS, (((NOEQPREDS+NOLTPREDS+NOGTPREDS
  +NOLTEQPRS+NOGTEQPRS+NONEQPRS+NOISNLPRS+NOISNNLPRS+NOBETPREDS+NONVLPREDS
  +NOLIKEPRS)*100)/EXSETNEXP),
   NOEQPREDS*100/EXSETNEXP, NOLTPREDS*100/EXSETNEXP, NOGTPREDS*100/EXSETNEXP,
   NOLTEQPRS*100/EXSETNEXP, NOGTEQPRS*100/EXSETNEXP, NONEQPRS*100/EXSETNEXP,
   NOISNLPRS*100/EXSETNEXP, NOISNNLPRS*100/EXSETNEXP, NOBETPREDS*
    100/EXSETNEXP, NONVLPREDS*100/EXSETNEXP, NOLIKEPRS*100/EXSETNEXP
 from exf$expsetstats e, exf$exprset es
 where e.esetowner = es.exsowner and e.esettable = es.exstabnm and 
       e.esetcolumn = es.exscolnm and e.esetowner = (select user from dual);

create or replace public synonym USER_EXPFIL_EXPRSET_STATS for
                                    exfsys.USER_EXPFIL_EXPRSET_STATS;

grant select on USER_EXPFIL_EXPRSET_STATS to public;

COMMENT ON TABLE user_expfil_exprset_stats IS
'Predicate statistics for the expression sets in the current schema';

COMMENT ON COLUMN user_expfil_exprset_stats.expr_table IS
'The table storing the expression set in the current schema';

COMMENT ON COLUMN user_expfil_exprset_stats.expr_column IS
'The column storing the expression set';

COMMENT ON COLUMN user_expfil_exprset_stats.attribute_exp IS 
'Sub-expression representing the complex or elementary attribute. Also 
 the left-hand-side of predicates';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_occurrence IS 
'Percentage occurrence of the attribute in the expression set';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_eq_oper IS
'Percentage of predicates (of the attribute) with ''='' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_lt_oper IS
'Percentage of predicates (of the attribute) with ''<'' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_gt_oper IS
'Percentage of predicates (of the attribute) with ''>'' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_lteq_oper IS
'Percentage of predicates (of the attribute) with ''<='' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_gteq_oper IS
'Percentage of predicates (of the attribute) with ''>='' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_neq_oper IS
'Percentage of predicates (of the attribute) with ''!='' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_nul_oper IS
'Percentage of predicates (of the attribute) with ''IS NULL'' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_nnul_oper IS
'Percentage of predicates (of the attribute) with ''IS NOT NULL'' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_betw_oper IS
'Percentage of predicates (of the attribute) with ''BETWEEN'' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_nvl_oper IS
'Percentage of predicates (of the attribute) with ''NVL'' operator';

COMMENT ON COLUMN user_expfil_exprset_stats.pct_like_oper IS
'Percentage of predicates (of the attribute) with ''LIKE'' operator';

---
---                   ALL_EXPFIL_EXPRSET_STATS
---      (using the privs of the expression set table)
create or replace view ALL_EXPFIL_EXPRSET_STATS
  (OWNER, EXPR_TABLE, EXPR_COLUMN, ATTRIBUTE_EXP, PCT_OCCURRENCE,
   PCT_EQ_OPER, PCT_LT_OPER, PCT_GT_OPER, PCT_LTEQ_OPER, PCT_GTEQ_OPER,
   PCT_NEQ_OPER, PCT_NUL_OPER, PCT_NNUL_OPER, PCT_BETW_OPER, PCT_NVL_OPER,
   PCT_LIKE_OPER)
  as
 select e.ESETOWNER, e.ESETTABLE, e.ESETCOLUMN, e.PREDLHS,
   (((NOEQPREDS+NOLTPREDS+NOGTPREDS+NOLTEQPRS+NOGTEQPRS+NONEQPRS+NOISNLPRS+
      NOISNNLPRS+NOBETPREDS+NONVLPREDS+NOLIKEPRS)*100)/EXSETNEXP),
   NOEQPREDS*100/EXSETNEXP, NOLTPREDS*100/EXSETNEXP, NOGTPREDS*100/EXSETNEXP,
   NOLTEQPRS*100/EXSETNEXP, NOGTEQPRS*100/EXSETNEXP, NONEQPRS*100/EXSETNEXP,
   NOISNLPRS*100/EXSETNEXP, NOISNNLPRS*100/EXSETNEXP, NOBETPREDS*
    100/EXSETNEXP, NONVLPREDS*100/EXSETNEXP,  NOLIKEPRS*100/EXSETNEXP
 from exf$expsetstats e, exf$exprset es, all_tables ao
 where e.esetowner = ao.owner and e.esettable = ao.table_name and 
       e.esetowner = es.exsowner and e.esettable = es.exstabnm and
       e.esetcolumn = es.exscolnm ;

create or replace public synonym ALL_EXPFIL_EXPRSET_STATS for
                                    exfsys.ALL_EXPFIL_EXPRSET_STATS;

grant select on ALL_EXPFIL_EXPRSET_STATS to public;

COMMENT ON TABLE all_expfil_exprset_stats IS
'Predicate statistics for the expression sets in the current schema';

COMMENT ON COLUMN all_expfil_exprset_stats.owner IS
'Owner of the table storing expressions';

COMMENT ON COLUMN all_expfil_exprset_stats.expr_table IS
'The table storing the expression set';

COMMENT ON COLUMN all_expfil_exprset_stats.expr_column IS
'The column storing the expression set';

COMMENT ON COLUMN all_expfil_exprset_stats.attribute_exp IS 
'Sub-expression representing the complex or elementary attribute. Also 
 the left-hand-side of predicates';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_occurrence IS 
'Percentage occurrence of the attribute in the expression set';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_eq_oper IS
'Percentage of predicates (of the attribute) with ''='' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_lt_oper IS
'Percentage of predicates (of the attribute) with ''<'' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_gt_oper IS
'Percentage of predicates (of the attribute) with ''>'' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_lteq_oper IS
'Percentage of predicates (of the attribute) with ''<='' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_gteq_oper IS
'Percentage of predicates (of the attribute) with ''>='' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_neq_oper IS
'Percentage of predicates (of the attribute) with ''!='' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_nul_oper IS
'Percentage of predicates (of the attribute) with ''IS NULL'' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_nnul_oper IS
'Percentage of predicates (of the attribute) with ''IS NOT NULL'' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_betw_oper IS
'Percentage of predicates (of the attribute) with ''BETWEEN'' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_nvl_oper IS
'Percentage of predicates (of the attribute) with ''NVL'' operator';

COMMENT ON COLUMN all_expfil_exprset_stats.pct_like_oper IS
'Percentage of predicates (of the attribute) with ''LIKE'' operator';

---
---                   ADM_EXPFIL_EXPRSET_STATS
---
create or replace view ADM_EXPFIL_EXPRSET_STATS 
  (OWNER, EXPR_TABLE, EXPR_COLUMN, ATTRIBUTE_EXP, PCT_OCCURRENCE, 
   PCT_EQ_OPER, PCT_LT_OPER, PCT_GT_OPER, PCT_LTEQ_OPER, PCT_GTEQ_OPER, 
   PCT_NEQ_OPER, PCT_NUL_OPER, PCT_NNUL_OPER, PCT_BETW_OPER, PCT_NVL_OPER,
   PCT_LIKE_OPER)
  as 
 select e.ESETOWNER, e.ESETTABLE, e.ESETCOLUMN, e.PREDLHS,
   (((NOEQPREDS+NOLTPREDS+NOGTPREDS+NOLTEQPRS+NOGTEQPRS+NONEQPRS+NOISNLPRS+
      NOISNNLPRS+NOBETPREDS+NONVLPREDS+NOLIKEPRS)*100)/EXSETNEXP),
   NOEQPREDS*100/EXSETNEXP, NOLTPREDS*100/EXSETNEXP, NOGTPREDS*100/EXSETNEXP,
   NOLTEQPRS*100/EXSETNEXP, NOGTEQPRS*100/EXSETNEXP, NONEQPRS*100/EXSETNEXP,
   NOISNLPRS*100/EXSETNEXP, NOISNNLPRS*100/EXSETNEXP, NOBETPREDS*
    100/EXSETNEXP, NONVLPREDS*100/EXSETNEXP,  NOLIKEPRS*100/EXSETNEXP
 from exf$expsetstats e, exf$exprset es
 where e.esetowner = es.exsowner and e.esettable = es.exstabnm and 
       e.esetcolumn = es.exscolnm ;

COMMENT ON TABLE adm_expfil_exprset_stats IS
'Predicate statistics for the expression sets in the current schema';

COMMENT ON COLUMN adm_expfil_exprset_stats.owner IS
'Owner of the table storing expressions';

COMMENT ON COLUMN adm_expfil_exprset_stats.expr_table IS
'The table storing the expression set';

COMMENT ON COLUMN adm_expfil_exprset_stats.expr_column IS
'The column storing the expression set';

COMMENT ON COLUMN adm_expfil_exprset_stats.attribute_exp IS 
'Sub-expression representing the complex or elementary attribute. Also 
 the left-hand-side of predicates';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_occurrence IS 
'Percentage occurrence of the attribute in the expression set';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_eq_oper IS
'Percentage of predicates (of the attribute) with ''='' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_lt_oper IS
'Percentage of predicates (of the attribute) with ''<'' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_gt_oper IS
'Percentage of predicates (of the attribute) with ''>'' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_lteq_oper IS
'Percentage of predicates (of the attribute) with ''<='' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_gteq_oper IS
'Percentage of predicates (of the attribute) with ''>='' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_neq_oper IS
'Percentage of predicates (of the attribute) with ''!='' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_nul_oper IS
'Percentage of predicates (of the attribute) with ''IS NULL'' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_nnul_oper IS
'Percentage of predicates (of the attribute) with ''IS NOT NULL'' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_betw_oper IS
'Percentage of predicates (of the attribute) with ''BETWEEN'' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_nvl_oper IS
'Percentage of predicates (of the attribute) with ''NVL'' operator';

COMMENT ON COLUMN adm_expfil_exprset_stats.pct_like_oper IS
'Percentage of predicates (of the attribute) with ''LIKE'' operator';

--
--                    USER_EXPFIL_PREDTAB_PLAN
--                       (undocumented)
-- This is similat to plan_table except for the index_name. The user 
-- is expected to use connect by clause while querying from this view. 
create or replace view USER_EXPFIL_PREDTAB_PLAN 
 as select i.idxname INDEX_NAME, p.*
 from exf$plan_table p, exf$idxsecobj i
 where p.statement_id = i.idxobj# and i.idxowner =
        (select user from dual);

grant select on user_expfil_predtab_plan to public;

create or replace view ALL_EXPFIL_PREDTAB_PLAN
 as select i.idxowner OWNER, i.idxname INDEX_NAME, p.*
 from exf$plan_table p, exf$idxsecobj i
 where p.statement_id = i.idxobj#;

grant select on all_expfil_predtab_plan to public;


/********************* USER_EXPFIL_TEXT_INDEX_ERRORS ********************/

--
-- This view maps any errors with the text indexes to the expression
-- column values in which the error exists
--
-- The text component may not be installed. create this view
-- conditionally --
declare 
 txtviewexts NUMBER; 
begin
  begin
    execute immediate 'drop public synonym USER_EXPFIL_TEXT_INDEX_ERRORS';
    execute immediate 'drop view exfsys.USER_EXPFIL_TEXT_INDEX_ERRORS'; 
  exception 
    when others then null; 
  end; 

  select count(*) into txtviewexts from dba_views where 
    owner = 'CTXSYS' and view_name = 'CTX_USER_INDEX_ERRORS'; 

  if (txtviewexts != 0) then 
    execute immediate 'create or replace view USER_EXPFIL_TEXT_INDEX_ERRORS 
     (expression_table, expression_column, err_timestamp, err_exprkey, 
      err_text) as
    select uei.expression_table, uei.expression_column, cie.err_timestamp,
         exf$text2exprid(ui.table_name, cie.err_textkey), cie.err_text
      from user_indexes ui, user_expfil_indexes uei,
              ctxsys.ctx_user_index_errors cie
      where ui.index_name = cie.err_index_name and uei.predicate_table =
            ui.table_name'; 

    execute immediate
      'COMMENT ON TABLE user_expfil_text_index_errors IS
      ''Errors for the text predicates stored in the expressions columns'''; 

    execute immediate
      'COMMENT ON COLUMN user_expfil_text_index_errors.expression_table IS
      ''Table with the expression column''';

    execute immediate 
      'COMMENT ON COLUMN user_expfil_text_index_errors.expression_column IS
       ''Name of the column storing expressions''';
    
    execute immediate 
      'COMMENT ON COLUMN user_expfil_text_index_errors.err_timestamp IS
        ''Time at which the error was noticed''';

    execute immediate 
      'COMMENT ON COLUMN user_expfil_text_index_errors.err_exprkey IS
        ''Key to the expression with the text predicate''';

    execute immediate 
      'COMMENT ON COLUMN user_expfil_text_index_errors.err_text IS 
        ''Description of the text predicate error''';

    execute immediate 
      'grant select on user_expfil_text_index_errors to public';
 
    execute immediate
      'create or replace public synonym USER_EXPFIL_TEXT_INDEX_ERRORS for
                                    exfsys.USER_EXPFIL_TEXT_INDEX_ERRORS';
  end if; 
exception when others then 
  if (SQLCODE = -942) then null; 
  else raise; 
  end if; 
end;
/

