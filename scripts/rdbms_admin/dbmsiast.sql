Rem
Rem $Header: dbmsiast.sql 24-may-2001.15:07:41 gviswana Exp $
Rem
Rem dbmsiast.sql
Rem
Rem  Copyright (c) Oracle Corporation 1900, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmsiast.sql - Public APIs for DBMS_IAS_TEMPLATE package
Rem
Rem    DESCRIPTION
Rem      Public APIS for creating and maintaining IAS template definitions.
Rem
Rem    NOTES
Rem      none.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    arrajara    04/18/01 - async_updatable_table is not supported
Rem    celsbern    03/15/01 - removing vc2_from_clob calls from views.
Rem    jingliu     02/13/01 - add constant TYPE
Rem    celsbern    12/14/00 - fixed dba_ias_gen_stmts view.
Rem    celsbern    11/16/00 - fixing object type constants
Rem    celsbern    11/15/00 - implemented IAS catalog changes
Rem    jingliu     08/01/00 - add view dba_ias_gen_stmts_exp
Rem    jingliu     06/06/00 - grant execute on dbms_ias_template to 
Rem                           execute_catalog_role
Rem    jingliu     06/02/00 - sql_txt of dba_ias_gen_stmt has 4k prefix
Rem    sbalaram    06/02/00 - Fix dba_ias_[pre,post]gen_stmts views
Rem    jingliu     05/29/00 - create pre & post gen stmt view
Rem    jingliu     05/23/00 - overload create_ias_object
Rem    masubram    04/28/00 - modify dba_ias_gen_stmts view
Rem    masubram    04/20/00 - add temporary tables
Rem    masubram    04/12/00 - modify create_ias_site and drop_ias_site
Rem    celsbern    04/07/00 - fixed comments for create_ias_object
Rem    masubram    04/05/00 - add new constants
Rem    masubram    03/29/00 - add new IAS object types
Rem    celsbern    03/29/00 - more changes to support ias
Rem    celsbern    03/28/00 - adde template_site apis.
Rem    celsbern    03/27/00 - created.
Rem

create or replace package sys.dbms_ias_template as

-- constants for use with IAS object types

-- These constants refer to objects that the user can explicitly specify to 
-- be  cached at the IAS sites

IAS_USER_DTYPE        CONSTANT NUMBER := -1001;
IAS_SITEOWNER         CONSTANT NUMBER := -1002;
READONLY_TABLE        CONSTANT NUMBER := -1003;
SYNC_UPDATABLE_TABLE  CONSTANT NUMBER := -1005;
PLSQL_PACKAGE         CONSTANT NUMBER := 9;
PLSQL_PROCEDURE       CONSTANT NUMBER := 7;
PLSQL_FUNCTION        CONSTANT NUMBER := 8;
USER_SEQUENCE         CONSTANT NUMBER := 6;
USER_VIEW             CONSTANT NUMBER := 4;
TEMP_TABLE            CONSTANT NUMBER := -1011;
-- reserved for future use when object is supported
ASYNC_UPDATABLE_TABLE CONSTANT NUMBER := -1004;
TYPE_OBJECT           CONSTANT NUMBER := 13;

-- NOTE: If you change the value of generated_ddl from -1017 then change
--       the dbms_ias_gen_stmts view
-- These constants refer to IAS objects created as part of the IAS 
-- instantiation process
ASYNC_MASTER_REPGROUP CONSTANT NUMBER := -1012;
SYNC_MASTER_REPGROUP  CONSTANT NUMBER := -1013;
REFRESH_GROUP         CONSTANT NUMBER := -1014;
UPDATABLE_MV_LOG      CONSTANT NUMBER := -1015;
DUMMY_SNAPSHOT        CONSTANT NUMBER := -1016;
GENERATED_DDL         CONSTANT NUMBER := -1017;


-- constant for use with site status
IAS_STATUS CONSTANT NUMBER := -100;

  function create_ias_template(     
    OWNER in VARCHAR2,
    REFRESH_GROUP_NAME in VARCHAR2,
    IAS_TEMPLATE_NAME in VARCHAR2,  
    TEMPLATE_COMMENT in VARCHAR2 := null) return number;          

  -- This function creates a deployment template for IAS
  -- 
  -- Arguments:
  --   owner - the database user owning the template
  --   refresh_group_name - the name of the refresh group to use when 
  --     instantiating the template.
  --   refresh_template_name - the name of the template.
  --   template_comment - an optional comment for describing the template

  function create_ias_object(                 
    IAS_TEMPLATE_NAME in VARCHAR2,
    OBJECT_NAME in VARCHAR2,                                                  
    OBJECT_TYPE in VARCHAR2,
    SCHEMA_NAME in VARCHAR2 default NULL,
    DERIVED_FROM_SNAME in VARCHAR2 default NULL,
    DERIVED_FROM_ONAME in VARCHAR2 default NULL,
    DDL_TEXT in VARCHAR2 default NULL) return number; 

  function create_ias_object(                 
    IAS_TEMPLATE_NAME in VARCHAR2,
    OBJECT_NAME in VARCHAR2,                                                  
    OBJECT_TYPE in NUMBER,
    SCHEMA_NAME in VARCHAR2 default NULL,
    DERIVED_FROM_SNAME in VARCHAR2 default NULL,
    DERIVED_FROM_ONAME in VARCHAR2 default NULL,
    DDL_TEXT in VARCHAR2 default NULL) return number; 

  function create_ias_object(                 
    IAS_TEMPLATE_NAME in VARCHAR2,
    OBJECT_NAME in VARCHAR2,                                                  
    OBJECT_TYPE in NUMBER,
    SCHEMA_NAME in VARCHAR2 default NULL,
    DERIVED_FROM_SNAME in VARCHAR2 default NULL,
    DERIVED_FROM_ONAME in VARCHAR2 default NULL,
    DDL_TEXT in CLOB) return number; 

  -- This function creates a new object in a deployment template.
  --
  -- Arguments: 
  --   refresh_template_name - name of the template to contain the new 
  --     object.
  --   object_name - name of the object
  --   object_type - type of object being created.  Must be one of 
  --     -1001 = 'IAS USER' 
  --     -1002 = 'IAS SITEOWNER'
  --     -1003 = 'READ ONLY TABLE'
  --     -1005 = 'SYNC UPDATABLE TABLE'
  --         9 = 'PACKAGE'
  --         7 = 'PROCEDURE'
  --         8 = 'FUNCTION'
  --         6 = 'SEQUENCE'
  --         4 = 'VIEW'
  --     -1011 = 'TEMP TABLE'
  --     -1012 = 'ASYNCHRONOUS MASTER REPGROUP'
  --     -1013 = 'SYNCHRONOUS MASTER REPGROUP'
  --     -1014 = 'REFRESH GROUP'
  --     -1015 = 'DUMMY SNAPSHOT'
  --     -1016 = 'UPDATABLE MV LOG'
  --     -1017 = 'GENERATED DDL'
  --
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   dupl_template_object - an object of the same type and name already
  --     exists for this template.
  --   bad_object_type - object type is invalid.
  -- 
  procedure drop_ias_template(
    ias_template_name in varchar2);

  -- The drop_refresh_template deletes a template and all of its objects,
  -- parameters, authorizations and user_parm_values from the database
  --
  -- Arguments:
  --   refresh_template_name - the template to be deleted.
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
 
  procedure drop_ias_object(       
    ias_template_name in VARCHAR2,
    object_name in VARCHAR2,
    object_type in number,
    schema_name in varchar2 default null);      

  procedure drop_ias_object(       
    ias_template_name in VARCHAR2,
    object_name in VARCHAR2,
    object_type in VARCHAR2,
    schema_name in varchar2 default null);      

  -- The drop_template_object procedure is used to drop an object from 
  -- a template.
  --
  -- Arguments:
  --   IAS_template_name - name of the deployment template
  --   object_name - the name of the object to be deleted
  --   object_type - the type of the object to be deleted Must be one of 
  --     'IAS USER','IAS SITEOWNER', 
  --     'READ ONLY TABLE', 'ASYNC UPDATABLE TABLE', 'SYNC UPDATABLE TABLE',
  --     'DUMMY SNAPSHOT','ASYNCHRONOUS MASTER REPGROUP', 'REFRESH GROUP',
  --     'UPDATABLE MV LOG','PLSQL  PACKAGE','PLSQL PROCEDURE',
  --     'PLSQL FUNCTION', 'USER SEQUENCE', 'USER VIEW', 'TEMP TABLE' 
  --     'GENERATED DDL', or  'SYNCHRONOUS MASTER REPGROUP'
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   miss_template_object - the specified object does not exist.
  --   bad_object_type - the object type is invalid.
  -- 

end dbms_ias_template;
/
create or replace public synonym dbms_ias_template for dbms_ias_template
/
grant execute on dbms_ias_template to execute_catalog_role
/

