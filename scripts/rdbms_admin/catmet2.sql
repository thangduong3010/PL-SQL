Rem
Rem $Header: rdbms/admin/catmet2.sql /st_rdbms_11.2.0/3 2013/01/14 21:10:09 mjangir Exp $
Rem
Rem catmet2.sql
Rem
Rem Copyright (c) 2004, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catmet2.sql - Creates heterogeneous types for Data Pump's mdapi
Rem
Rem    DESCRIPTION
Rem      Creates heterogeneous type definitions for
Rem        TABLE_EXPORT
Rem        SCHEMA_EXPORT
Rem        DATABASE_EXPORT
Rem        TRANSPORTABLE_EXPORT
Rem      Also loads xsl stylesheets
Rem      All this must be delayed until the packages have been built.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mjangir     01/10/13 - lrg 7341681: enable diffing code 
Rem    apfwkr      10/17/12 - Backport mjangir_bug-14658090 from main
Rem    lbarton     06/22/04 - Bug 3695154: obsolete initmeta.sql 
Rem    lbarton     04/27/04 - lbarton_bug-3334702
Rem    lbarton     01/28/04 - Created
Rem

-- create the types

exec dbms_metadata_build.set_debug(false);
exec DBMS_METADATA_DPBUILD.create_table_export;
exec DBMS_METADATA_DPBUILD.create_schema_export;
exec DBMS_METADATA_DPBUILD.create_database_export;
exec DBMS_METADATA_DPBUILD.create_transportable_export;

-- load XSL stylesheets

exec SYS.DBMS_METADATA_UTIL.LOAD_STYLESHEETS;

-- Bug 14658090/lrg 7341681: enable the diffing code 
DECLARE
  xdb_version registry$.version%type;
  catalog_version registry$.version%type;
BEGIN
  select version into catalog_version from registry$ where cid = 'CATALOG';
  select version into xdb_version from registry$ where cid='XDB';
  IF xdb_version = catalog_version THEN
    -- recompile dbms_metadata_int to enable the diffing code
    execute immediate 'alter package dbms_metadata_int compile plsql_ccflags = ''ku$xml_enabled:true'''; 
    -- recompile dbms_metadata_util to enable the xmlschema load code
    execute immediate 'alter package dbms_metadata_util compile plsql_ccflags = ''ku$xml_enabled:true'''; 
  END IF;
EXCEPTION
  WHEN no_data_found THEN NULL;  --  XDB not loaded
END;
/

