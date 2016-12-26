Rem
Rem $Header: rdbms/admin/dbmsrgt.sql /main/25 2010/05/13 08:12:00 rrudd Exp $
Rem
Rem dbmsrgt.sql
Rem
Rem Copyright (c) 1998, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsrgt.sql - Refresh Group Templates public APIs.
Rem
Rem    DESCRIPTION
Rem      This package specification contains the public APIs and 
Rem      declarations for the dbms_repcat_rgt package.  This is the 
Rem      package that controls the maintenance and definition
Rem      of refresh group templates.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rrudd       03/15/10 - Fix bug 9445994
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    celsbern    03/01/01 - updated comments for bug 1667213.
Rem    jingliu     02/13/01 - add error 23533
Rem    jingliu     12/11/00 - add new error number
Rem    celsbern    11/15/00 - implementing IAS catalog changes
Rem    arrajara    06/28/00 - Fix offline_dirpath
Rem    jingliu     06/02/00 - modify vc2_from_clob
Rem    arrajara    03/24/00 - add missing_offline_dirpath
Rem    jingliu     02/02/00 - add param dest_dbversion
Rem    narora      08/12/99 - add param PROCESS_REPAPI_SITE to 
Rem                         - drop_site_instantiation()
Rem    sbalaram    07/30/99 - Modify signature for instantiate_offline_repapi
Rem    narora      07/26/99 - remove charset from offline instt
Rem    schandar    07/06/99 - Modify script to work in SQL*Plus
Rem    narora      05/10/99 - ssl support                                      
Rem    wesmith     02/23/99 - Modify signature of instantiate_offline_repapi()
Rem    hasun       12/24/98 - Support OSM project                              
Rem    celsbern    11/09/98 - updated instantiate_offline_repapi comments.
Rem    celsbern    10/29/98 - changed drop_site_instantiation                  
Rem    celsbern    10/30/98 - added comments                                   
Rem    celsbern    10/15/98 - removed id based apis.
Rem    celsbern    09/22/98 - added drop_site_instantiation api.
Rem    celsbern    09/21/98 - made site_name req'd parm for instantiation.
Rem    wesmith     09/16/98 - Add additional parameters to
Rem                           instantiate_offline_repapi()
Rem    celsbern    09/03/98 - added read_clob function.                        
Rem    celsbern    08/25/98 - add instantiation api                            
Rem    celsbern    08/24/98 - fixed locking procedures                         
Rem    celsbern    08/21/98 - added codes for ddl validation.                  
Rem    wesmith     08/04/98 - Rename instantiate_offline() for RepAPI snapshots
Rem    wesmith     07/30/98 - Code review fixes                                
Rem    wesmith     07/23/98 - Overload dbms_repcat_rgt.instantiate_offline()
Rem                           for RepAPI.
Rem    celsbern    06/30/98 - added object_name parameter to create_object_from
Rem    celsbern    06/24/98 - added vc2_from_clob and clob_from_vc2 functions. 
Rem    celsbern    06/16/98 - more offline instantiation                       
Rem    celsbern    06/15/98 - added offline instantiation                      
Rem    celsbern    05/18/98 - removed parameter tables.                        
Rem    celsbern    05/14/98 - changed LONGs to CLOBs for rgt tables            
Rem    celsbern    05/06/98 - fixing up error messages                         
Rem    celsbern    04/29/98 - removed dbms_repcat_rgt synonym before creating p
Rem    celsbern    04/23/98 - more online instantiation                        
Rem    celsbern    04/21/98 - added support for drop_all_templates             
Rem    celsbern    04/14/98 - added name based api for alter_template_parm     
Rem    celsbern    04/07/98 - added online instantiation.                      
Rem    celsbern    04/01/98 - Created id and name based support for alter proce
Rem    celsbern    03/30/98 - Created
Rem

drop synonym dbms_repcat_rgt;

create or replace package "SYS"."DBMS_REPCAT_RGT" as   
  ----------------------------------------
  -- Types
  -- 
  type octtype is table of number index by binary_integer;  


  ----------------------------------------
  -- Exceptions
  -- 

  miss_user_authorization exception;         
  pragma exception_init(miss_user_authorization, -23436);    
  miss_user_authorization_num NUMBER := -23436;
  
  dupl_user_authorization exception;         
  pragma exception_init(dupl_user_authorization, -23437);      
  dupl_user_authorization_num NUMBER := -23437;  

  miss_refresh_template exception;      
  pragma exception_init(miss_refresh_template, -23438);   
  miss_refresh_template_num NUMBER := -23438;

  dupl_refresh_template exception;      
  pragma exception_init(dupl_refresh_template, -23439);   
  dupl_refresh_template_num NUMBER := -23439;

  bad_public_template exception;        
  pragma exception_init(bad_public_template, -23440);     
  bad_public_template_num NUMBER := -23440;

  miss_template_object exception;       
  pragma exception_init(miss_template_object, -23441);    
  miss_template_object_num NUMBER := -23441;

  dupl_template_object exception;       
  pragma exception_init(dupl_template_object, -23442);    
  dupl_template_object_num NUMBER := -23442;

  bad_object_type exception;            
  pragma exception_init(bad_object_type, -23319);         
  bad_object_type_num NUMBER := -23319;

  miss_template_parm exception;         
  pragma exception_init(miss_template_parm, -23443);      
  miss_template_parm_num NUMBER := -23443;  

  dupl_template_parm exception;         
  pragma exception_init(dupl_template_parm, -23444);      
  dupl_template_parm_num NUMBER := -23444;

  miss_template_site exception;         
  pragma exception_init(miss_template_site, -23445);      
  miss_template_site_num NUMBER := -23445;

  dupl_template_site exception;         
  pragma exception_init(dupl_template_site, -23446);      
  dupl_template_site_num NUMBER := -23446;

  bad_status exception; 
  pragma exception_init(bad_status, -23470);              
  bad_status_num NUMBER := -23470;

  miss_user_parm_value exception;             
  pragma exception_init(miss_user_parm_value, -23447);          
  miss_user_parm_value_num NUMBER := -23447;

  dupl_user_parm_value exception;             
  pragma exception_init(dupl_user_parm_value, -23448);          
  dupl_user_parm_value_num NUMBER := -23448;

  miss_user exception;
  pragma exception_init(miss_user, -23449);
  miss_user_num NUMBER := -23449;

  miss_object exception;
  pragma exception_init(miss_object, -23468);
  miss_object_num NUMBER := -23468;

  diff_object exception;
  pragma exception_init(diff_object, -23469);
  diff_object_num NUMBER := -23469;

  not_authorized exception;
  pragma exception_init(not_authorized, -23471);
  not_authorized_num NUMBER := -23471;

  bad_ddl exception;
  pragma exception_init(bad_ddl, -23474);
  bad_ddl_num NUMBER := 23474;

  missing_offline_dirpath exception;
  pragma exception_init(missing_offline_dirpath, -23502);
  missing_offline_dirpath_num NUMBER := -23502;

  duplicated_siteowner exception;
  pragma exception_init(duplicated_siteowner, -23531);
  duplicated_siteowner_num NUMBER := -23531;

  not_cacheable_obj exception;
  pragma exception_init(not_cacheable_obj, -23533);
  not_cacheable_obj_num NUMBER := -23533;
  
  ----------------------------------------
  -- constants
  --
  -- constants used for defining object_types
  DBLINK_RGT CONSTANT NUMBER   := -5;
  SNAPSHOT_RGT CONSTANT NUMBER := -1;
  INDEX_RGT CONSTANT NUMBER :=     1;
  TABLE_RGT CONSTANT NUMBER :=     2;
  VIEW_RGT CONSTANT NUMBER :=      4;
  SYNONYM_RGT CONSTANT NUMBER :=   5;
  SEQUENCE_RGT CONSTANT NUMBER :=  6;
  PROCEDURE_RGT CONSTANT NUMBER := 7;
  FUNCTION_RGT CONSTANT NUMBER :=  8;
  PACKAGE_RGT CONSTANT NUMBER :=   9;
  PACKAGE_BODY_RGT CONSTANT NUMBER := 10;
  TRIGGER_RGT CONSTANT NUMBER := 12;

  -- constants used for SQL validatation.
  dblink_oct_rgt CONSTANT NUMBER :=  32;
  snapshot_oct_rgt CONSTANT NUMBER :=  74;
  index_oct_rgt CONSTANT NUMBER :=  9;
  table_oct_rgt CONSTANT NUMBER :=  1;
  view_oct_rgt CONSTANT NUMBER :=  21;
  synonym_oct_rgt CONSTANT NUMBER :=  19;
  sequence_oct_rgt CONSTANT NUMBER :=  13;
  procedure_oct_rgt  CONSTANT NUMBER :=  24;
  function_oct_rgt  CONSTANT NUMBER :=  91;
  package_oct_rgt  CONSTANT NUMBER :=  94;
  package_body_oct_rgt  CONSTANT NUMBER :=  97;
  trigger_oct_rgt  CONSTANT NUMBER :=  59; 

  -- constants for template_type flags
  template_type_rgt_templates CONSTANT NUMBER := 1;
  template_type_ias_templates CONSTANT NUMBER := 2;

  -- constants for object_type flags
  object_type_rgt_templates CONSTANT NUMBER := 1;
  object_type_ias_templates CONSTANT NUMBER := 2;

  -- constants for template_sites table
  INSTALLING_STATUS CONSTANT NUMBER := 0;
  INSTALLED_STATUS CONSTANT NUMBER := 1;

  -- constants for communicating with snapshot callout
  INSERT_LINE CONSTANT NUMBER := 1;
  REFRESH_LINE CONSTANT NUMBER := 0;

  -- size of lob chunk to write during offline instantiation
  LOB_WRITE_SIZE CONSTANT NUMBER := 900;

  -- For RepAPI offline instantiation
  -- NOTE: if you make any changes here, you must change the
  --       corresponding constants in dbmsrint.sql
  --
  NO_TRACE_DUMP       CONSTANT NUMBER := 0;
  RESULTSET_THRESHOLD CONSTANT NUMBER := 32768;
  LOB_THRESHOLD       CONSTANT NUMBER := 32768;

  -- ------------------------------------
  -- package variables
  -- 

  ----------------------------------------
  -- Public procedures/functions
  -- 

  function create_user_authorization( 
    USER_NAME in VARCHAR2,  
    REFRESH_TEMPLATE_NAME in VARCHAR2) return number;       

  -- This function creates a user authorization granting access to a 
  -- private template.
  -- 
  -- Arguments: 
  --   user_name - database user receiving access to the template
  --   refresh_template_name - name of the deployment template
  -- 
  -- Return value: the user_authorization_id of the new user_authorization
  -- 
  -- Exceptions:
  --   dupl_user_authorization - user already authorized for this template
  --   miss_user - user is not defined in database
  --   miss_refresh_template - refresh template is not defined

  function create_refresh_template(     
    OWNER in VARCHAR2,
    REFRESH_GROUP_NAME in VARCHAR2,     
    REFRESH_TEMPLATE_NAME in VARCHAR2,  
    TEMPLATE_COMMENT in VARCHAR2 := null, 
    PUBLIC_TEMPLATE in VARCHAR2 := null,
    LAST_MODIFIED in DATE := sysdate,      
    MODIFIED_BY in VARCHAR2 := user,      
    CREATION_DATE in DATE := sysdate,      
    CREATED_BY in VARCHAR2 := user) return number;          

  -- This function creates a deplpyment template.
  -- 
  -- Arguments:
  --   owner - the database user owning the template
  --   refresh_group_name - the name of the refresh group to use when 
  --     instantiating the template.
  --   refresh_template_name - the name of the template.
  --   template_comment - an optional comment for describing the template
  --   public_template - public template flag.  Must be 'Y, N or NULL'.  A
  --     NULL value is interpreted as a 'N'.  A 'Y' value indicates 
  --     this is a public template which can be instantiated by any 
  --     user able to connect to the database.
  --   last_modified - date the template was last modified defaults to 
  --     sysdate.
  --   modified_by - database user that last modified the template
  --     defaults to connected user.
  --   creation_date - date the template was created.  defaults to 
  --     sysdate.
  --   created_by - user that created the template.  Defaults to 
  --     connected database user.
  -- 
  -- Return value: returns the refresh_template_id of the newly created
  --   template.
  -- 
  -- Exceptions:
  --   dupl_refresh_template - a template with the same name already 
  --     exists.
  --   miss_user - the specified owner does not exist as a database user.

  function create_template_object(                 
    REFRESH_TEMPLATE_NAME in VARCHAR2,                                        
    OBJECT_NAME in VARCHAR2,                                                  
    OBJECT_TYPE in VARCHAR2,
    DDL_TEXT in clob,                                                 
    MASTER_ROLLBACK_SEG in VARCHAR2 := null,                                  
    FLAVOR_ID in NUMBER := -1e-130) return number; 

  -- This function creates a new object in a deployment template.
  --
  -- Arguments: 
  --   refresh_template_name - name of the template to contain the new 
  --     object.
  --   object_name - name of the object
  --   object_type - type of object being created.  Must be one of 
  --     'INDEX', 'TABLE','VIEW','SYNONYM','SEQUENCE','PROCEDURE','FUNCTION',
  --     'PACKAGE','PACKAGE BODY','TRIGGER','SNAPSHOT','DATABASE LINK',
  --     or 'MATERIALIZED VIEW'.
  --   ddl_text - ddl text to create the object.
  --   master_rollback_seg - name of the rollback segment to use for 
  --     snapshots
  --   flavor_id - id of the flavor for this object.  only required if
  --     using schema evolution.  defaults to null
  --
  -- Return value:
  --   The returned value is the template_object_id of the newly created
  --     object.
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   dupl_template_object - an object of the same type and name already
  --     exists for this template.
  --   bad_object_type - object type is invalid.
  -- 

  function create_template_parm(        
    REFRESH_TEMPLATE_NAME in VARCHAR2,      
    PARAMETER_NAME in VARCHAR2,         
    DEFAULT_PARM_VALUE in clob := null, 
    PROMPT_STRING in VARCHAR2 := null,
    USER_OVERRIDE in VARCHAR2 := null) return number;     

  -- The create_template_parm function is used to create a parameter for 
  -- a template.
  --
  -- Arguments:
  --   refresh_template_name - the template to contain the new parameter
  --   parameter_name - name of the new parameter
  --   default_parm_value - the default value for the parameter
  --   prompt_string - the string to use when prompting for the parameter 
  --     value.
  --   user_override - a Y/N flag, defaults to 'N'.  If set to 'Y', the 
  --     dba cannot override the default value for this parameter.
  -- 
  -- Return value:
  --   The create_template_parm function returns the template_parameter_id
  --   of the new row in the repcat$_template_parameters table.
  -- 
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   dupl_template_parm - the parameter already exists for the template

  function create_user_parm_value(            
    REFRESH_TEMPLATE_NAME IN VARCHAR2,
    PARAMETER_NAME IN VARCHAR2,
    USER_NAME IN VARCHAR2,
    PARM_VALUE in clob := null) return number;            

  -- The create_user_parm_value function creates a value for a parameter for 
  -- a parameter for a user.
  -- 
  -- Arguments:
  --   refresh_template_name - the template to contain the new parameter value
  --   parameter_name - the parameter name of creating a new value for.
  --   user_name - the name of the user creating a new value for
  --   parm_value - the parameter value
  -- 
  -- Return value:
  --   The return value is the user_parameter_id of the new row in the 
  --   repcat$_user_parm_values table.
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   miss_template_parm - the specified template parameter does not exist.
  --   miss_user - the specified owner does not exist as a database user.
  --   dupl_user_parm_value - a value already exists for the template,
  --     parameter, and user.
 
  procedure drop_user_authorization(         
    refresh_template_name in varchar2,
    user_name in varchar2);        

  -- The drop_user_authorization procedure deletes a specified 
  -- user_authorization from the database.
  --
  -- Arguments:
  --   refresh_template_name - the name of the template authorized for 
  --   the user.
  --   user_name - the database user authorized for the template.
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   miss_user - the specified owner does not exist as a database user.
  --   miss_user_authorization - the user_authorization does not exist.
  --   

  procedure drop_refresh_template(
    refresh_template_name in varchar2);

  -- The drop_refresh_template deletes a template and all of its objects,
  -- parameters, authorizations and user_parm_values from the database
  --
  -- Arguments:
  --   refresh_template_name - the template to be deleted.
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
 
  procedure drop_template_object(       
    refresh_template_name in VARCHAR2,
    object_name in VARCHAR2,
    object_type in VARCHAR2);      

  -- The drop_template_object procedure is used to drop an object from 
  -- a template.
  --
  -- Arguments:
  --   refresh_template_name - name of the deployment template
  --   object_name - the name of the object to be deleted
  --   object_type - the type of the object to be deleted Must be one of 
  --     'INDEX', 'TABLE','VIEW','SYNONYM','SEQUENCE','PROCEDURE','FUNCTION',
  --     'PACKAGE','PACKAGE BODY','TRIGGER','SNAPSHOT','DATABASE LINK',
  --     or 'MATERIALIZED VIEW'.
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   miss_template_object - the specified object does not exist.
  --   bad_object_type - the object type is invalid.
  -- 

  procedure drop_template_parm(
    refresh_template_name in VARCHAR2,
    parameter_name in varchar2);

  -- The drop_template_parm procedure drops a template parameter from 
  -- a template.
  -- 
  -- Arguments:
  --   refresh_template_name - name of the deployment template
  --   prameter_name - name of parameter to be dropped
  -- 
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   miss_template_parm - the specified parameter does not exist.

  procedure drop_user_parm_value(
    refresh_template_name in varchar2,
    parameter_name in varchar2,
    user_name in varchar2);

  -- The drop_user_parm_value procedure deletes a user_parm_value
  -- from a template.
  -- 
  -- Arguments:
  --   refresh_template_name - name of the deployment template
  --   parameter_name - name of the parameter
  --   user_name - name of user 
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   miss_template_parm - the specified parameter does not exist.
  --   miss_user - the specified user does not exist in the database
  -- 

  procedure alter_user_authorization(        
    USER_NAME in VARCHAR2,
    REFRESH_TEMPLATE_NAME in VARCHAR2,         
    new_USER_NAME in VARCHAR2 := '-',   
    new_REFRESH_TEMPLATE_NAME in VARCHAR2 := '-');        

  -- The alter_user_authorization procedure changes the attributes
  -- of an existing user_authorization.
  --
  -- Arguments:
  --   user_name - database user name of the authorization.
  --   refresh_template_name - name of the refresh_template
  --   new_user_name - changed user_name
  --   new_refresh_template_name - changed template name
  -- 
  -- Exceptions:
  --   miss_refresh_template - the specified or new template is missing.
  --   miss_user - the sepecified user_name or new_user_name does not exist
  --   dupl_user_authorization - the changed user_authorization already 
  --     exists.

  procedure alter_refresh_template(     
    REFRESH_TEMPLATE_NAME in VARCHAR2,      
    new_OWNER in VARCHAR2 := '-',       
    new_REFRESH_GROUP_NAME in VARCHAR2 := '-',            
    new_REFRESH_TEMPLATE_NAME in VARCHAR2 := '-',         
    new_TEMPLATE_COMMENT in VARCHAR2 := '-',              
    new_PUBLIC_TEMPLATE in VARCHAR2 := '-',               
    new_LAST_MODIFIED in DATE := to_date('1', 'J'),       
    new_MODIFIED_BY in NUMBER := -1e-130);

  -- The alter_refresh_template procedure changes the attributes 
  -- of an existing deployment template.
  -- 
  -- Arguments: 
  --   refresh_template_name - name of the template to change
  --   new_owner - new owner of the template
  --   new_refresh_group_name - new refresh group name of the template
  --   new_refresh_template_name - new template_name
  --   new_public_template - new public template flag
  --   new_last_modified - new last modified date
  --   new_modified_by - new modified by user id
  -- 
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist
  --   bad_user - the new_owner does not exist as a database user
  --   bad_public_template - the public template flag is not 'Y','N' or NULL
  --   dupl_refresh_template - the new_refresh_template_name already exists

  procedure alter_template_object(      
    REFRESH_TEMPLATE_NAME in VARCHAR2,
    OBJECT_NAME in VARCHAR2,
    OBJECT_TYPE in VARCHAR2,
    new_REFRESH_TEMPLATE_NAME in VARCHAR2 := '-',         
    new_OBJECT_NAME in VARCHAR2 := '-', 
    new_OBJECT_TYPE in VARCHAR2 := '-', 
    new_DDL_TEXT in clob := null,       
    new_MASTER_ROLLBACK_SEG in VARCHAR2 := '-',           
    new_FLAVOR_ID in NUMBER := -1e-130);

  -- The alter_template_object procedure changes the attributes of 
  -- a template object.
  --
  -- Arguments:
  --   refresh_template_name - name of the deployment template
  --   object_name - name of the object to be modified.
  --   object_type - type of the object to be modified.
  --   new_refresh_template_name - name of the new deployment template
  --   new_object_name - name the object will be renamed to
  --   new_object_type - new object type to rename the object to
  --   new_ddl_text - updated ddl text
  --   new_master_rollback_seg - new rollback segment name
  --   new_flavor_id - updated flavor_id
  -- 
  -- Exceptions:
  --   miss_refresh_template - missing deployment template name or new
  --     template_name
  --   miss_template_object - the object does not exist in the template
  --   bad_object_type - the object type is not valid or the new object
  --     type is not valid.
  --   dupl_template_object - an object of the new name and type 
  --     already exists for the template.
 
  procedure alter_template_parm(        
    REFRESH_TEMPLATE_NAME in VARCHAR2,
    PARAMETER_NAME in VARCHAR2,
    new_REFRESH_TEMPLATE_NAME in VARCHAR2 := '-',         
    new_PARAMETER_NAME in VARCHAR2 := '-',
    new_DEFAULT_PARM_VALUE in clob := null,               
    new_PROMPT_STRING in VARCHAR2 := '-',
    new_USER_OVERRIDE in VARCHAR2 := '-');

  -- The alter_template_parm procedure changes the attributes of a 
  -- template parameter
  -- 
  -- Arguments:
  --   refresh_template_name - name of the deployment template 
  --     containing the parameter
  --   parameter_name - name of the parameter being changed
  --   new_refresh_template_name - name of the new template that 
  --     the parameter is being assigned to
  --   new_parameter_name - new parameter_name
  --   new default_parm_value - new default value for the parameter
  --   new_prompt_string - new prompt string for the parameter
  --   new_user_override - new value for the user_orverride flag.
  -- 
  -- Exceptions:
  --   miss_refresh_template -  missing deployment template name or new
  --     template_name
  --   miss_template_parm - the parameter is not defined for the template
  --   dupl_template_parm - the new_parameter already exists for the template.
  --  

  procedure alter_user_parm_value(            
    REFRESH_TEMPLATE_NAME in VARCHAR2,
    PARAMETER_NAME in VARCHAR2,
    USER_NAME in VARCHAR2,
    new_REFRESH_TEMPLATE_NAME in VARCHAR2 := '-',
    new_PARAMETER_NAME  in VARCHAR2 := '-',
    new_USER_NAME  in VARCHAR2 := '-',
    new_PARM_VALUE in clob := null);    

  -- The alter_user_parm_value procedure is used to change the 
  -- attributes of a user parameter value.
  --
  -- Arguments:
  --   refresh_template_name - name of the template containing the 
  --     user parm value
  --   parameter_name - name of the parameter
  --   user_name - database user name 
  --   new_refresh_template_name - new template name containing the 
  --     user parm value
  --   new_parameter_name - new parameter_name for the value
  --   new_user_name - new user name for the parameter value
  --   new_parm_value - new value for the parameter.
  -- 
  -- Exceptions:
  --  miss_refresh_template - missing deployment template for template_name
  --    or new_refresh_template_name
  --  miss_template_parm - the parameter is not defined for the template
  --    or new_parameter_name
  --  miss_user - the user name is not defined for the user_name or 
  --    new_user_name
  --  dupl_user_parm - the new user_parm_value already exists.


  function copy_template(
    old_refresh_template_name in varchar2,
    new_refresh_template_name in varchar2,
    copy_user_authorizations in varchar2,
    dblink in varchar2 default null) return number;

  -- The copy_template function is used to create a new template from 
  -- an existing template.  Copy_template copies the entire template
  -- including the object, parameters, user parameter values and,
  -- optionally, the user authorizations associated with a template.
  -- The copy_template function will also copy a template from another
  -- database if a database link is supplied.
  --
  -- Arguments:
  --   old_refresh_template_name - name of the template to copy from
  --   new_refresh_template_name - name of the template to copy to
  --   copy_user_authorizations - a 'Y' or 'N' flag used to specify
  --     the copying of the user_authorizations associated with 
  --     the existing template
  --   dblink - the database link to use when copying from another 
  --     database.  If not supplied, a local copy will be performed.
  -- 
  -- Exceptions:
  --   miss_refresh_template - the copy from template does not exist
  --   dupl_refresh_template - the copy to template already exists
  
  procedure drop_all_objects(refresh_template_name in varchar2,
                             object_type in varchar2 default NULL);

  -- The drop_all_objects procedure drops all of the objects 
  -- associated with a template or, optionally, all of the objects
  -- of a particular type in a template.
  -- 
  -- Arguments:
  --   refresh_template_name - the name of the template containing the 
  --     objects
  --   object_type - optional parameter specifying the object types to 
  --     delete.
  --
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist
  --   bad_object_type - the specified object_type is invalid
    
  procedure drop_all_user_parm_values(refresh_template_name in varchar2,
                                user_name in varchar2 default NULL,
                                parameter_name in varchar2 default NULL);

  -- The drop_all_user_parm_values procedure drops all of the 
  -- user_parm_values in a template, or, optionally, all the 
  -- user_parm_values for a particular user or with a particular 
  -- parameter_name
  -- 
  -- Arguments:
  --   refresh_template_name - name of the template.
  --   user_name - optional name of the user to delete user_parm_values for
  --   parameter_name - optional parameter_name to delete
  --     user_parm_values for.
  -- 
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.
  --   miss_user - the specified user does not exist.
  --   miss_template_parameter - the template_parameter specified 
  --     by parameter_name does not exist

  procedure drop_all_template_parms(refresh_template_name in varchar2,
                                    drop_objects in varchar2 default 'N');

  -- The drop_all_template_parms procedure drops all of the template
  -- parameters for a specified template.  Optionally, all of the 
  -- objects referencing the parameters may also be dropped.
  -- 
  -- Arguments:
  --   refresh_template_name - the name of the template.
  --   drop_objects - a 'Y' or 'N' flag specifying whether or not 
  --     to drop the associated objects.
  -- 
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.

  procedure drop_all_user_authorizations(refresh_template_name in varchar2);

  -- The drop_all_user_authorizations procedure drops all of the user
  -- authorizations for a specified template.
  --
  -- Arguments:
  --   refresh_template_name - the name of the template.
  --   
  -- Exceptions:
  --   miss_refresh_template - the specified template does not exist.

  procedure drop_all_templates;

  -- The drop_all_templates procedure drops all of the templates in a 
  -- database.  NOTE: THIS WILL DELETE ALL TEMPLATES.  

  function  instantiate_online(refresh_template_name in varchar2,
                               site_name in varchar2,
                               user_name in varchar2 default NULL,
                               runtime_parm_id in number default -1e-130,
                               next_date in date default sysdate,
                               interval in varchar2 default 'SYSDATE+1',
                               use_default_gowner in boolean default TRUE)
                               return number;

  -- The instantiate_online procedure is used to generate the ddl 
  -- required for an online instantiation.
  --
  -- Arguments:
  --   refresh_template_name - name of the template
  --   site_name - name of the site doing the instantiation
  --   user_name - name of the user doing the instantiation.  This is 
  --     and optional parameter, and if not supplied, defaults to 
  --     the connected user.
  --   runtime_parm_id - runtime parameter id. This is an optional parameter.
  --   next_date - next scheduled refresh date.  This is optional.
  --   interval - the refresh interval.  Also optional.
  --   use_default_gowner - If true than the owner of any snapshot object
  --     groups created will be owned by the default user, PUBLIC. Otherwise
  --     the owner of snapshot object groups will be the user performing the 
  --     instantiation.
  -- 
  -- Return Values:
  --   The return value of this function is an output_id.  This is 
  --   the primary key to the system.repcat$_temp_output table.  This is
  --   where the generated DDL for the online instantiation.
  --
  -- Exceptions:
  --   miss_refresh_template - the template is missing.
  --   miss_user - the user specified by user_id is missing.

  FUNCTION instantiate_offline_java(
        refresh_template_name IN VARCHAR2,
        site_id               IN VARCHAR2,
        user_name             IN VARCHAR2,
        master                IN VARCHAR2,
        url                   IN VARCHAR2,
        ssl                   IN NUMBER,
        offline_dirpath       IN VARCHAR2,
        file_name             IN VARCHAR2,
        trace_vector          IN NUMBER, 
        resultset_threshold   IN NUMBER,
        lob_threshold         IN NUMBER) RETURN NUMBER;

  function instantiate_offline(refresh_template_name in varchar2,
                               site_name in varchar2,
                               user_name in varchar2 default NULL,
                               runtime_parm_id in number default -1e-130,
                               next_date in date default sysdate,
                               interval in varchar2 default 'SYSDATE+1',
                               use_default_gowner in boolean default TRUE,
                               dest_dbversion in number default NULL)
                               return number;

  -- The instantiate_offline procedure is used to generate the ddl 
  -- required for an offline instantiation for server snapshots.
  --
  -- Arguments:
  --   refresh_template_name - name of the template
  --   site_name - name of the site doing the instantiation
  --   user_name - name of the user doing the instantiation.  This is 
  --     and optional parameter, and if not supplied, defaults to 
  --     the connected user.
  --   runtime_parm_id - runtime parameter id. This is an optional parameter.
  --   next_date - next scheduled refresh date.  This is optional.
  --   interval - the refresh interval.  Also optional.
  --   use_default_gowner - If true than the owner of any snapshot object
  --     groups created will be owned by the default user, PUBLIC. Otherwise
  --     the owner of snapshot object groups will be the user performing the 
  --     instantiation.
  --   dest_dbversion: database version of the site where template
  --                    will be instantiated. For example: 8.2, 8.1
  --                    default value of NULL indicates
  --                    that the local database compatibility will be used.
  -- Return Values:
  --   The return value of this function is an output_id.  This is 
  --   the primary key to the system.repcat$_temp_output table.  This is
  --   where the generated DDL for the offline instantiation.
  --
  -- Exceptions:
  --   miss_refresh_template - the template is missing.
  --   miss_user - the user specified by user_id is missing.
  --  reftmplinvalidcomp - template can not be instantiate to database with
  --   compatiblity is 8.0-
  FUNCTION instantiate_offline_repapi(
   refresh_template_name IN VARCHAR2,
   site_id               IN VARCHAR2 DEFAULT NULL,
   user_name             IN VARCHAR2 DEFAULT USER,
   master                IN VARCHAR2 DEFAULT NULL,
   url                   IN VARCHAR2 DEFAULT NULL,
   ssl                   IN NUMBER   DEFAULT 0,
   offline_dirpath       IN VARCHAR2 DEFAULT NULL,
   trace_vector          IN NUMBER DEFAULT DBMS_REPCAT_RGT.NO_TRACE_DUMP,
   resultset_threshold   IN NUMBER DEFAULT DBMS_REPCAT_RGT.RESULTSET_THRESHOLD,
   lob_threshold         IN NUMBER DEFAULT DBMS_REPCAT_RGT.LOB_THRESHOLD
  )
  RETURN NUMBER;

  -- The instantiate_offline_repapi function performs a server side 
  -- offline instantiation of a repapi based template.
  --
  -- Arguments:
  --   refresh_template_name - name of the template to offline instantiate
  --   site_id - repapi site_id of the site instantiating for
  --   user_name - the user who will own the refresh group.  This is 
  --     and optional parameter, and if not supplied, defaults to 
  --     the logon user.
  --   master - an alias used for the URL by the JAVA REPAPI client
  --   url - service name with which the JAVA REPAPI server is published
  --   ssl - a boolean which determines whether SSL is to be used with the URL
  --   offline_dirpath - directory path for the offline file
  --   trace_vector - trace level for debugging 
  --   resultset_threshold - buffer size for outputing result sets
  --   lob_threshold - buffer size for outputing lob values
  
  
  function create_object_from_existing(refresh_template_name in varchar2,
                                       object_name in varchar2,
                                       sname in varchar2,
                                       oname in varchar2,
                                       otype in varchar2) return number;

  -- The create_object_from_existing creates a template object from 
  -- an existing object in the database.  
  --  
  -- Arguments:
  --   refresh_template_name - name of the template
  --   object_name - name of the new object
  --   sname - schema name of the schema containing the existing object
  --   oname - name of the existing object
  --   otype - object type of the existing object.
  --
  -- Return values: 
  --   The return value of this function is the id of the new object.
  --
  -- Exceptions:
  --   miss_refresh_template - the template is missing.
  --   dupl_template_object - the object specified by the object_name
  --     already exists.
  --   bad_object - the object specified by sname, oname and otype 
  --     does not exist or is invalid.

  function get_runtime_parm_id return number;

  -- The get_runtime_parm_id function gets a runtime parameter id.
  -- This is used to insert runtime parameters prior to 
  -- instantiation.
  --
  -- Arguments:
  --   none.
  -- 
  -- Exceptions:
  --   none.

  procedure insert_runtime_parms(runtime_parm_id in number,
                                 parameter_name in varchar2,
                                 parameter_value in clob);

  -- The insert_runtime_parms procedure is used to insert values
  -- into the runtime parameters table.  Prior to calling this procedure
  -- a call should have been made to get_runtime_parm_id.  All of the
  -- parameters for an instantiation should have the sane runtime_parm_id.
  --
  -- Arguments:
  --   runtime_parm_id - unique_id obtained from get_runtime_parm_id call.
  --   parameter_name - name of the parameter for the value.
  --   parameter_value - value of the parameter.
  -- 
  -- Exceptions:
  --   none.

  procedure delete_runtime_parms(runtime_parm_id in number,
                                 parameter_name in varchar2);

  -- The delete_runtime_parms procedure is used to delete 
  -- previously inserted runtime parameters.
  -- 
  -- Arguments:
  --   runtime_parm_id - id of the rows to be deleted.
  --   parameter_name - name of the parameter to delete.
  --
  -- Exceptions:
  --   none.

  procedure lock_template_shared;

  -- The lock_template_shared procedure is used to prevent changes to 
  -- a template during the instantiation of the template.  This should
  -- be called prior to instantiate_online or instantiate_offline.  The
  -- lock is cleared by performing a commit or rollback.
  --
  -- Arguments:
  --   none.
  -- 
  -- Exceptions:
  --   none.

 
  procedure lock_template_exclusive; 

  -- The lock_template_exclusive procedure is used to prevent instantiation 
  -- a template while changes are being made to a template.  This should
  -- be called prior to making any changes to the template.  The lock is 
  -- cleared by performing a commit or rollback.
  --
  -- Arguments:
  --   none.
  -- 
  -- Exceptions:
  --   none.
  
  function compare_templates(source_template_name in varchar2,
                             compare_template_name in varchar2)
                             return number;
  
  -- The compare_templates procedure is used to compare two templates.
  -- The results of the comparison are placed in the the 
  -- system.repcat$_temp_output table.  If there are no differences, 
  -- no rows are written to the table.
  -- 
  -- Arguments:
  --   source_template_name - name of the first template.
  --   compare_template_name - name of the second template.
  -- 
  -- Return value: 
  --   The return value is the output_id key of the repcat$_temp_output table.
  -- 
  -- Exceptions:
  --   miss_refresh_template - either the source_template_name does not 
  --     exist, or the compare_template_name does not exist, or both.
  
  
  procedure drop_site_instantiation(
    REFRESH_TEMPLATE_NAME in VARCHAR2,
    USER_NAME in VARCHAR2,
    SITE_NAME in VARCHAR2,
    REPAPI_SITE_ID in NUMBER DEFAULT -1e-130,
    PROCESS_REPAPI_SITE in VARCHAR2 DEFAULT 'N'
  );

  -- The drop_site_instantiation procedure is used to drop the instantiation
  -- of a template.  This alters the snapshot so that is cannot be
  -- refreshed.  This is used for both server and repapi snapshots.
  -- 
  -- Arguments: 
  --   refresh_template_name - name of the template.
  --   user_name - name of the user that instantiated the template.
  --   site_name - site where the template was instantiated.
  --   repapi_site_id - the numeric  id of repapi sites. If this is non-NULL 
  --     then it is assumed to be a repapi site. The site_name may or may not 
  --     be provided. If the site_name is also provided then the site_name
  --     must be a valid repapi site whose id is repapi_site_id.
  --   process_repapi_site - if this flag is 'Y' then the site_name is assumed
  --      to be a repapi site_name. The default value is 'N'. This flag has no
  --      relevance if repapi_site_id is non-NULL.
  --
  -- Exceptions:
  --   miss_refresh_template - template does not exist.
  --   miss_user - user_name does not exist in the database.
  --   miss_template_site - template has not been instantiated for 
  --     user and site.


  ---------------------------------------------------------------------------
  ---
  --- #######################################################################
  --- #######################################################################
  ---                        INTERNAL PROCEDURES
  ---
  --- The following procedures provide internal functionality and should
  --- not be called directly. Invoking these procedures may corrupt your
  --- replication environment.
  ---
  --- #######################################################################
  --- #######################################################################

  function vc2_from_clob(lobstring in clob, 
                         len       in number default 32767) return varchar2;
  pragma restrict_references(vc2_from_clob,WNDS); 
  
  function clob_from_vc2(vc2string in varchar2) return clob;

  function check_ddl_text(ddl_text in clob,
                          object_type in varchar2,
                          user_name in varchar2) return number;


  function read_clob(clobval  in clob,
                     vcval    in out varchar2,
                     readsize in number,
                     offset   in number) return number;

  procedure substitute_parameters(
    refresh_template_name in varchar2,
    object_name in varchar2,
    object_type in varchar2,
    user_name in varchar2,
    ddl_string out clob);

  procedure substitute_parameters(
    refresh_template_id in number,
    template_object_id in number,
    user_id in number,
    ddl_string out clob);
 

end "DBMS_REPCAT_RGT";
/

create or replace public synonym dbms_repcat_rgt for sys.dbms_repcat_rgt;

