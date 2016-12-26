Rem
Rem $Header: rdbms/admin/mgdtab.sql /main/4 2010/06/09 08:08:44 hgong Exp $
Rem
Rem mgdtab.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      mgdtab.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       06/29/06 - add comments 
Rem    hgong       04/04/06 - rename oidcode.jar 
Rem    hgong       03/31/06 - create metadata tables 
Rem    hgong       03/31/06 - create metadata tables 
Rem    hgong       03/31/06 - Created
Rem

prompt .. Creating mgd_id_xml_validator table
create table mgd_id_xml_validator(
   xsd_schema           clob                   -- xml validator 
);
COMMENT ON TABLE mgd_id_xml_validator IS
'Oracle tag data translation schema table. This is a single column, single row table that stores the CLOB of Oracle TDT schema.'
/
COMMENT ON COLUMN mgd_id_xml_validator.xsd_schema IS
'Oracle tag data translation schema'
/

prompt .. Creating the mgd_id_category_tab table
create table mgd_id_category_tab(
  owner         VARCHAR2(64)
        default sys_context('userenv', 'CURRENT_USER'),
  category_id   number(4),
  category_name varchar2(256) not null,
  version    varchar2(256),
  agency     varchar2(256),  
  URI        varchar2(256),
  constraint mgd_id_category_tab$pk primary key (owner,category_id),
  constraint mgd_id_category_tab$uq unique (owner, category_name, version)
);
COMMENT ON TABLE mgd_id_category_tab IS
'Encoding category table'
/
COMMENT ON COLUMN mgd_id_category_tab.owner IS
'Database user who created the category'
/
COMMENT ON COLUMN mgd_id_category_tab.category_id IS
'Category ID'
/
COMMENT ON COLUMN mgd_id_category_tab.category_name IS
'Category name'
/
COMMENT ON COLUMN mgd_id_category_tab.version IS
'Category version'
/
COMMENT ON COLUMN mgd_id_category_tab.agency IS
'Organization who defined the category'
/
COMMENT ON COLUMN mgd_id_category_tab.URI IS
'URI that describes the category'
/

/* Should we store XML as CLOB or XML type?
   http://www.oracle.com/technology/oramag/oracle/03-jul/o43xml.html#t1
   If we preload into the JAVA objects, we only read the XML once, so there is no
   requiremend for good data manipulation language (DML) performance - might as well
   store as CLOB. */
prompt .. Creating mgd_id_scheme_tab table
           create table mgd_id_scheme_tab(
   owner             varchar2(64)
        default sys_context('userenv', 'CURRENT_USER'),
   category_id       number(4), 
   type_name         varchar2(256) not null,
   tdt_xml           clob,          
   encodings         varchar2(256), 
   components        varchar2(1024),
   CONSTRAINT mgd_id_scheme_tab$pk primary key (owner, category_id, type_name),
   CONSTRAINT mgd_id_scheme_tab$fk FOREIGN KEY (owner, category_id) 
      REFERENCES mgd_id_category_tab(owner, category_id) ON DELETE CASCADE
);

COMMENT ON TABLE mgd_id_scheme_tab IS
'Encoding scheme table'
/
COMMENT ON COLUMN mgd_id_scheme_tab.owner IS
'Database user who created the scheme'
/
COMMENT ON COLUMN mgd_id_scheme_tab.category_id IS
'Category ID'
/
COMMENT ON COLUMN mgd_id_scheme_tab.type_name IS
'Encoding scheme name, e.g., SGTIN-96, GID-96, etc.'
/
COMMENT ON COLUMN mgd_id_scheme_tab.tdt_xml IS
'Tag data translation xml for this encoding scheme'
/
COMMENT ON COLUMN mgd_id_scheme_tab.encodings IS
'Encodings separated by '','', e.g., ''LEGACY,TAG_ENCODING,PURE_IDENTITY,BINARY'' for SGTIN-96'
/
COMMENT ON COLUMN mgd_id_scheme_tab.components IS
'Relevant component names, extracted from each level and then combined. The component names are separated by '','', e.g., ''objectclass,generalmanager,serial'' for GID-96'
/

create sequence mgd$sequence_category;

