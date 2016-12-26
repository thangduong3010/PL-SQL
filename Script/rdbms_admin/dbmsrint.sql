Rem
Rem $Header: dbmsrint.sql 21-mar-2005.17:00:11 wesmith Exp $
Rem
Rem dbmsrint.sql
Rem
Rem Copyright (c) 1998, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsrint.sql - Package specification for dbms_repcat_instantiate
Rem
Rem    DESCRIPTION
Rem      The dbms_repcat_instantiate package contains public APIs for 
Rem      online and offline instantiation of deployment templates and
Rem      dropping the instantiation of a deployment template at a given
Rem      site.
Rem
Rem    NOTES
Rem      Must be run when connected to SYS or as INTERNAL.
Rem      A public synonym is created for this package and access
Rem      to this package is granted to public.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wesmith     03/21/05 - make dbms_repcat_instantiate invoker's rights pkg
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    arrajara    03/23/00 - offline_dirpath
Rem    jingliu     02/02/00 - add dest_dbversion
Rem    sbalaram    07/30/99 - Modify signature for instantiate_offline_repapi
Rem    narora      07/26/99 - remove charset from offline instt
Rem    narora      05/10/99 - ssl support                                      
Rem    wesmith     02/24/99 - Add public version of 
Rem                           dbms_repcat_rgt.instantiate_offline_repapi
Rem    hasun       12/24/98 - Support OSM project                              
Rem    celsbern    10/27/98 - added comments                                   
Rem    celsbern    10/23/98 - fixed typo                                       
Rem    celsbern    10/22/98 - Created
Rem
create or replace package dbms_repcat_instantiate AUTHID CURRENT_USER as 
  
  -------------------------
  -- OVERVIEW
  --
  -- This package provides routines to instantiate deployment templates
  -- and drop instantiations of a deployment template.

  ------------------------
  -- EXCEPTIONS
  
  miss_refresh_template exception;      
  pragma exception_init(miss_refresh_template, -23438);   
  miss_refresh_template_num NUMBER := -23438;

  miss_template_site exception;         
  pragma exception_init(miss_template_site, -23445);      
  miss_template_site_num NUMBER := -23445;

  dupl_template_site exception;         
  pragma exception_init(dupl_template_site, -23446);      
  dupl_template_site_num NUMBER := -23446;

  not_authorized exception;
  pragma exception_init(not_authorized, -23471);
  not_authorized_num NUMBER := -23471;

  ----------------------------------------
  -- CONSTANTS
  --

  -- For RepAPI offline instantiation
  -- NOTE: if you make any changes here, you must change the 
  --       corresponding constants in dbmsrgt.sql
  --
  NO_TRACE_DUMP       CONSTANT NUMBER := 0;
  RESULTSET_THRESHOLD CONSTANT NUMBER := 32768;
  LOB_THRESHOLD       CONSTANT NUMBER := 32768;

  -------------------------
  -- PUBLIC PROCEDURES
  -- 

  procedure drop_site_instantiation(REFRESH_TEMPLATE_NAME in VARCHAR2,
                                    SITE_NAME in VARCHAR2);        

  -- This procedure drops a previously instantiated deployment
  -- template at a given site.  
  -- 
  -- Note: this procedure does not physically remove the instantiated 
  -- template.  This procedure makes the snapshots in the template 
  -- unable to be refreshed.
  -- 
  -- Arguments:
  --   refresh_template_name: Name of the deployment template
  --   site_name: name of the site where the template was previously
  --     instantiated
  -- Exceptions:
  --   miss_refresh_template - deployment template does not exist
  --   miss_template_site - template is not instantiated for this 
  --     site and connected user.


  function  instantiate_online(refresh_template_name in varchar2,
                               site_name in varchar2,
                               runtime_parm_id in number default -1e-130,
                               next_date in date default sysdate,
                               interval in varchar2 default 'SYSDATE+1',
                               use_default_gowner in boolean default TRUE)
                               return number;

  -- The instantiate_online function creates the DDL required for 
  -- the online instantiation of a template.  The results are stored
  -- in the user_repcat_temp_output view.
  --
  -- Arguments:
  --   refresh_template_name: Name of the deployment template.
  --   site_name: id of runtime parameters associated with this
  --     instantiation (optional)
  --   next_date: next refresh date (optional)
  --   interval: refresh interval (optional)
  --   use_default_gowner: If true than the owner of any snapshot object
  --     groups created will be owned by the default user, PUBLIC. Otherwise
  --     the owner of snapshot object groups will be the user performing the 
  --     instantiation.
  --
  --   return value is a id used to access the generated template
  --   definition in the user_repcat_temp_output table.
  -- 
  -- Exceptions:
  --   miss_refresh_template - deployment template does not exist
  --   dupl_template_site - template already instantiated at site
  --   not_authorized - the connected user has not been authorized
  --     to instantiate the template.  Deployment templates can 
  --     only be instantiated by authorized user or as public
  --     templates.


  function instantiate_offline(refresh_template_name in varchar2,
                               site_name in varchar2,
                               runtime_parm_id in number default -1e-130,
                               next_date in date default sysdate,
                               interval in varchar2 default 'SYSDATE+1',
                               use_default_gowner in boolean default TRUE,
                               dest_dbversion in number default NULL)
                               return number;

  -- The instantiate_ofline function creates the DDL required for 
  -- the offline instantiation of a template.  The results are stored
  -- in the user_repcat_temp_output view.
  --
  -- Arguments:
  --   refresh_template_name: Name of the deployment template.
  --   site_name: id of runtime parameters associated with this
  --     instantiation (optional)
  --   next_date: next refresh date (optional)
  --   interval: refresh interval (optional)
  --   use_default_gowner: If true than the owner of any snapshot object
  --     groups created will be owned by the default user, PUBLIC. Otherwise
  --     the owner of snapshot object groups will be the user performing the 
  --     instantiation.
  --   dest_dbversion: database version of the site where template
  --                    will be instantiated. For example: 8.2, 8.1
  --                    default value of NULL indicates
  --                    that the local database compatibility will be used.
  --
  --   return value is a id used to access the generated template
  --   definition in the user_repcat_temp_output table.
  -- 
  -- Exceptions:
  --   miss_refresh_template - deployment template does not exist
  --   dupl_template_site - template already instantiated at site
  --   not_authorized - the connected user has not been authorized
  --     to instantiate the template.  Deployment templates can 
  --     only be instantiated by authorized user or as public
  --     templates.
  --  reftmplinvalidcomp - template can not be instantiate to database with
  --   compatiblity is 8.0-

  FUNCTION instantiate_offline_repapi(
   refresh_template_name IN VARCHAR2,
   offline_dirpath       IN VARCHAR2 DEFAULT NULL,
   site_id               IN VARCHAR2 DEFAULT NULL,
   master                IN VARCHAR2 DEFAULT NULL,
   url                   IN VARCHAR2 DEFAULT NULL,
   ssl                   IN NUMBER DEFAULT 0,
   trace_vector          IN NUMBER 
                         DEFAULT DBMS_REPCAT_INSTANTIATE.NO_TRACE_DUMP,
   resultset_threshold   IN NUMBER 
                         DEFAULT DBMS_REPCAT_INSTANTIATE.RESULTSET_THRESHOLD,
   lob_threshold         IN NUMBER 
                         DEFAULT DBMS_REPCAT_INSTANTIATE.LOB_THRESHOLD
  )
  RETURN NUMBER;

  -- The instantiate_offline_repapi function performs a server side 
  -- offline instantiation of a repapi based template.
  --
  -- Arguments:
  --   refresh_template_name - name of the template to offline instantiate
  --   offline_dirpath - The target directory to create offline file 
  --   site_id - repapi site_id of the site instantiating for
  --   master - an alias used for the URL by the JAVA REPAPI client
  --   url - service name with which the JAVA REPAPI server is published
  --   ssl - a boolean which determines whether SSL is to be used with the URL
  --   trace_vector - trace level for debugging 
  --   resultset_threshold - buffer size for outputing result sets
  --   lob_threshold - buffer size for outputing lob values
  
end dbms_repcat_instantiate;
/

create or replace public synonym dbms_repcat_instantiate for 
sys.dbms_repcat_instantiate;

grant execute on dbms_repcat_instantiate to public;

