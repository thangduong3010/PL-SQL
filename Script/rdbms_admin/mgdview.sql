Rem
Rem $Header: rdbms/admin/mgdview.sql /main/4 2010/06/09 08:08:44 hgong Exp $
Rem
Rem mgdview.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      mgdview.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       05/21/10 - remove read only from view definition
Rem    hgong       06/29/06 - make category views read only 
Rem    hgong       05/31/06 - change scheme views to read only 
Rem    hgong       04/04/06 - rename oidcode.jar 
Rem    hgong       03/31/06 - create views 
Rem    hgong       03/31/06 - create views 
Rem    hgong       03/31/06 - Created
Rem

prompt .. Creating the mgd_id_category views

create or replace view mgd_id_category 
  (category_id, category_name, version, agency, URI
  )
  as select category_id, category_name, version, agency, URI 
     from mgd_id_category_tab
     where owner = 'MGDSYS' or
           owner = sys_context('userenv', 'CURRENT_USER') WITH READ ONLY;

COMMENT ON TABLE mgd_id_category IS
'Encoding categories defined by MGDSYS and the current user'
/
COMMENT ON COLUMN mgd_id_category.category_id IS
'Category ID'
/
COMMENT ON COLUMN mgd_id_category.category_name IS
'Category name'
/
COMMENT ON COLUMN mgd_id_category.version IS
'Category version'
/
COMMENT ON COLUMN mgd_id_category.agency IS
'Organization who defined the category'
/
COMMENT ON COLUMN mgd_id_category.URI IS
'URI that describes the category'
/

create or replace view user_mgd_id_category 
  (category_id, category_name, version, agency, URI
  )
  as select category_id, category_name, version, agency, URI 
     from mgd_id_category_tab
     where owner = sys_context('userenv', 'CURRENT_USER');

COMMENT ON TABLE user_mgd_id_category IS
'Encoding categories defined by the current user'
/
COMMENT ON COLUMN user_mgd_id_category.category_id IS
'Category ID'
/
COMMENT ON COLUMN user_mgd_id_category.category_name IS
'Category name'
/
COMMENT ON COLUMN user_mgd_id_category.version IS
'Category version'
/
COMMENT ON COLUMN user_mgd_id_category.agency IS
'Organization who defined the category'
/
COMMENT ON COLUMN user_mgd_id_category.URI IS
'URI that describes the category'
/

prompt .. Creating the mgd_id_scheme views
create or replace view mgd_id_scheme
  (category_id, type_name, tdt_xml, encodings, components)
  as select category_id, type_name, tdt_xml, encodings, components 
     from mgd_id_scheme_tab
     where owner = 'MGDSYS' or
           owner = sys_context('userenv', 'CURRENT_USER') WITH READ ONLY;

COMMENT ON TABLE mgd_id_scheme IS
'Encoding schemes defined by MGDSYS and the current user'
/
COMMENT ON COLUMN mgd_id_scheme.category_id IS
'Category ID'
/
COMMENT ON COLUMN mgd_id_scheme.type_name IS
'Encoding scheme name, e.g., SGTIN-96, GID-96, etc.'
/
COMMENT ON COLUMN mgd_id_scheme.tdt_xml IS
'Tag data translation xml for this encoding scheme'
/
COMMENT ON COLUMN mgd_id_scheme.encodings IS
'Encodings separated by '','', e.g., ''LEGACY,TAG_ENCODING,PURE_IDENTITY,BINARY'' for SGTIN-96'
/
COMMENT ON COLUMN mgd_id_scheme.components IS
'Relevant component names, extracted from each level and then combined. The component names are separated by '','', e.g., ''objectclass,generalmanager,serial'' for GID-96'
/

create or replace view user_mgd_id_scheme
  (category_id, type_name, tdt_xml, encodings, components)
  as select category_id, type_name, tdt_xml, encodings, components 
     from mgd_id_scheme_tab
     where owner = sys_context('userenv', 'CURRENT_USER');

COMMENT ON TABLE user_mgd_id_scheme IS
'Encoding schemes defined by the current user'
/
COMMENT ON COLUMN user_mgd_id_scheme.category_id IS
'Category ID'
/
COMMENT ON COLUMN user_mgd_id_scheme.type_name IS
'Encoding scheme name, e.g., SGTIN-96, GID-96, etc.'
/
COMMENT ON COLUMN user_mgd_id_scheme.tdt_xml IS
'Tag data translation xml for this encoding scheme'
/
COMMENT ON COLUMN user_mgd_id_scheme.encodings IS
'Encodings separated by '','', e.g., ''LEGACY,TAG_ENCODING,PURE_IDENTITY,BINARY'' for SGTIN-96'
/
COMMENT ON COLUMN user_mgd_id_scheme.components IS
'Relevant component names, extracted from each level and then combined. The component names are separated by '','', e.g., ''objectclass,generalmanager,serial'' for GID-96'
/
