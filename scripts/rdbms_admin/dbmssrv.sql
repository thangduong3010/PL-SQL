Rem
Rem $Header: rdbms/admin/dbmssrv.sql /main/17 2009/10/09 15:38:03 achoi Exp $
Rem
Rem dbmssrv.sql
Rem
Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmssrv.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achoi       09/21/09 - edition as service attribute
Rem    bnnguyen    05/09/08 - bug6665906
Rem    rburns      05/06/06 - split package body 
Rem    sltam       04/19/06 - Fix bug 5171189: pass option to disconnect_session
Rem    dsemler     04/19/05 - correct error handling 
Rem    dsemler     01/19/05 - add handling for db readonly 
Rem    sourghos    12/30/04 - Fix bug 4043119 
Rem    dsemler     06/03/04 - add taf and ha aq attributes to create and 
Rem                           modify 
Rem    dsemler     06/03/04 - update header for the ability to start/stop all 
Rem                           service members 
Rem    dsemler     05/14/04 - add dtp support, 
Rem    dsemler     04/30/04 - remove goodness goal, add none 
Rem    dsemler     04/13/04 - change create_service, add goal arg, create 
Rem    dsemler     04/19/04 - remove default NULL on create_service 
Rem                           network_name argument 
Rem    sltam       07/21/03 - Fix bug 3013804, db_domain will not be appended
Rem                           to service_name in disconnect_session()
Rem    sltam       04/30/03 - bug2935173: Remove SET statements
Rem    dsemler     02/03/03 - 
Rem    dsemler     12/06/02 - 
Rem    dsemler     11/22/02 - create, delete, start and stop added
Rem    sltam       01/16/03 - fix bug 2754447
Rem    sltam       10/14/02 - sltam_rdbms10i_dbmssrv
Rem    sltam       10/11/02 - 
Rem    sltam       10/04/02 - Created
Rem

CREATE OR REPLACE LIBRARY dbms_service_lib trusted is static;
/

CREATE OR REPLACE PACKAGE dbms_service as

 ------------
 --  OVERVIEW
 --
 --  This package allows an application to manage services and sessions
 --  connected with a specific service name.
 --
 --  Oracle Real Application Cluster (RAC) has a functionality to manage
 --  service names across instances. This package allows the creation, deletion,
 --  starting and stopping of services in both RAC and single instance. 
 --  Additionally it provides the ability to disconnect all sessions which 
 --  connect to the instance with a service name when RAC removes that 
 --  service name from the instance.

 ----------------
 --  INSTALLATION
 --
 --  This package should be installed under SYS schema.
 --
 --  SQL> @dbmssrv
 --
 -----------
 --  EXAMPLE
 --
 --  Disconnect all sessions in the local instance which connected
 --  using service name foo.us.oracle.com.
 --
 --    dbms_service.disconnect_session('foo.us.oracle.com');
 --
 --  dbms_service.disconnect_session() does not return until all
 --  corresponding sessions disconnected. Therefore, dbms_job package or
 --  put the SQL session in background if the caller does not want to
 --  wait for all corresponding sessions disconnected.
 --
 --  An option can be passed to disconnect_session(). If option is
 --  dbms_service.disconnect_session_immediate, sessions will be 
 --  disconnected immediately.
 --
 --    dbms_service.disconnect_session('foo.us.oracle.com', 
 --                                      dbms_service.immediate);
 --

 --------------------------
 --  IMPLEMENTATION DETAILS
 --
 --  dbms_service.disconnect_session() calls SQL statement
 --
 --    ALTER SYSTEM DISCONNECT SESSION sid, serial option
 --
 --  The default value of option is POST_TRANSCATION.
 -- 
 --  
 ------------
 --  SECURITY
 --
 --  The execute privilage of the package is granted to DBA role only.

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --

  -- Options for disconnect session
  post_transaction constant number := 0;
  immediate        constant number := 1;

  procedure disconnect_session(service_name in varchar2,
                               disconnect_option in number default
                               post_transaction);
  --  Disconnect sessions which connect to the local instance with
  --  the specified service name.
  --  Input parameter(s):
  --    service_name
  --      service name of the sessions to be disconnected. 
  --    disconnect_option
  --      option to be passed to 'alter system disconnect session'.
  --      its value can be dbms_service.post_transaction
  --      or dbms_service.immediate
  --      default value is dbms_service.post_transaction

  procedure create_service(service_name        in varchar2, 
                           network_name        in varchar2,
                           goal                in number default NULL,
                           dtp                 in boolean default NULL,
                           aq_ha_notifications in boolean default NULL,
                           failover_method     in varchar2 default NULL,
                           failover_type       in varchar2 default NULL,
                           failover_retries    in number default NULL,
                           failover_delay      in number default NULL,
                           clb_goal            in number default NULL,
                           edition             in varchar2 default NULL);
  --  Creates a new service$ entry for this service name
  --  Input parameter(s):
  --    service_name
  --      The service's short name. Limited to 64 characters.
  --    net_name
  --      the full network name for the service. This will usually be the same
  --      as the service_name.
  --    goal
  --      the workload management goal directive for the service. Valid values
  --      are : DBMS_SERVICE.GOAL_SERVICE_TIME,
  --            DBMS_SERVICE.GOAL_THROUGHPUT,
  --            DBMS_SERVICE.GOAL_NONE.
  --    dtp 
  --      declares the service to be for DTP or distributed transactions.
  --    aq_ha_notifications
  --      determines whether HA events are sent via AQ for this service.
  --    failover_method
  --      the TAF failover method for the service
  --    failover_type
  --      the TAF failover type for the service
  --    failover_retries
  --      the TAF failover retries for the service
  --    failover_delay
  --      the TAF failover delay for the service
  --    edition
  --      the initial session edition


  procedure modify_service(service_name        in varchar2,
                           goal                in number default NULL,
                           dtp                 in boolean default NULL,
                           aq_ha_notifications in boolean default NULL,
                           failover_method     in varchar2 default NULL,
                           failover_type       in varchar2 default NULL,
                           failover_retries    in number default NULL,
                           failover_delay      in number default NULL,
                           clb_goal            in number default NULL,
                           edition             in varchar2 default NULL,
                           modify_edition      in boolean default FALSE);
  --  Modifies an existing service
  --  Input parameter(s):
  --    service_name
  --      The service's short name. Limited to 64 characters.
  --    goal
  --      the workload management goal directive for the service. Valid values
  --      defined under create_service above.
  --    dtp 
  --      declares the service to be for DTP or distributed transactions.
  --    aq_ha_notifications
  --      determines whether HA events are sent via AQ for this service.
  --    failover_method
  --      the TAF failover method for the service
  --    failover_type
  --      the TAF failover type for the service
  --    failover_retries
  --      the TAF failover retries for the service
  --    failover_delay
  --      the TAF failover delay for the service
  --    edition
  --      the initial session edition
  --    modify_edition
  --      true if edition is to be modified

  procedure delete_service(service_name in varchar2);
  --  Marks a service$ entry as deleted.
  --  Input parameter(s):
  --    service_name
  --      The services short name. Limited to 64 characters.

  procedure start_service(service_name in varchar2,
                          instance_name in varchar2 default NULL);
  --  In single instance exclusive alters the service_name IOP to contain
  --  this service_name. In RAC will optionally on the instance specified.
  --  Input parameter(s):
  --    service_name
  --      The services short name. Limited to 64 characters.
  --    instance_name 
  --      The instance on which to start the service. NULL results in starting
  --      of the service on the local instance.
  --      In single instance this can only be the current 
  --      instance or NULL.
  --      Specify DBMS_SERVICE.ALL_INSTANCES to start the service on all
  --      configured instances.

  procedure stop_service(service_name in varchar2, 
                         instance_name in varchar2 default NULL);
  --  In single instance exclusive alters the service_name IOP to remove
  --  this service_name. In RAC will call out to CRS to stop the service
  --  optionally on the instance specified. Calls clscrs_stop_resource.
  --  Input parameter(s):
  --    service_name
  --      The services short name. Limited to 64 characters.
  --    instance_name 
  --      The instance on which to stop the service. NULL results in stopping
  --      of the service locally.
  --      In single instance this can only be the current 
  --      instance or NULL. The default in RAC and exclusive case is NULL.
  --      Specify DBMS_SERVICE.ALL_INSTANCES to start the service on all
  --      configured instances.

  -------------
  --  CONSTANTS
  --
  --  Constants for use in calling arguments.

  goal_none         constant number := 0;
  goal_service_time constant number := 1;
  goal_throughput   constant number := 2;

  all_instances     constant varchar2(2) := '*';

  -- Connection Balancing Goal arguments

  clb_goal_short    constant number := 1;
  clb_goal_long     constant number := 2;

  -- TAF failover attribute arguments

  failover_method_none  constant varchar2(5) := 'NONE';
  failover_method_basic constant varchar2(6) := 'BASIC';

  failover_type_none    constant varchar2(5) := 'NONE';
  failover_type_session constant varchar2(8) := 'SESSION';
  failover_type_select  constant varchar2(7) := 'SELECT';

  -------------------------
  --  ERRORS AND EXCEPTIONS
  --
  --  When adding errors remember to add a corresponding exception below.

  err_null_service_name       constant number := -44301;
  err_null_network_name       constant number := -44302;
  err_service_exists          constant number := -44303;
  err_service_does_not_exist  constant number := -44304;
  err_service_in_use          constant number := -44305;
  err_service_name_too_long   constant number := -44306;
  err_network_prefix_too_long constant number := -44307;
  err_not_initialized         constant number := -44308;
  err_general_failure         constant number := -44309;
  err_max_services_exceeded   constant number := -44310;
  err_service_not_running     constant number := -44311;
  err_database_closed         constant number := -44312;
  err_invalid_instance        constant number := -44313;
  err_network_exists          constant number := -44314;
  err_null_attributes         constant number := -44315;
  err_invalid_argument        constant number := -44316;
  err_database_readonly       constant number := -44317;
  err_max_sn_length           constant number := -44318;
  err_aq_service              constant number := -44319;

  null_service_name        EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_service_name, -44301);
  null_network_name        EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_network_name, -44302);
  service_exists           EXCEPTION;
  PRAGMA EXCEPTION_INIT(service_exists, -44303);
  service_does_not_exist   EXCEPTION;
  PRAGMA EXCEPTION_INIT(service_does_not_exist, -44304);
  service_in_use           EXCEPTION;
  PRAGMA EXCEPTION_INIT(service_in_use, -44305);
  service_name_too_long    EXCEPTION;
  PRAGMA EXCEPTION_INIT(service_name_too_long, -44306);
  network_prefix_too_long  EXCEPTION;
  PRAGMA EXCEPTION_INIT(network_prefix_too_long, -44307);
  not_initialized          EXCEPTION;
  PRAGMA EXCEPTION_INIT(not_initialized, -44308);
  general_failure          EXCEPTION;
  PRAGMA EXCEPTION_INIT(general_failure, -44309);
  max_services_exceeded    EXCEPTION;
  PRAGMA EXCEPTION_INIT(max_services_exceeded, -44310);
  service_not_running      EXCEPTION;
  PRAGMA EXCEPTION_INIT(service_not_running, -44311);
  database_closed          EXCEPTION;
  PRAGMA EXCEPTION_INIT(database_closed, -44312);
  invalid_instance         EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_instance, -44313);
  network_exists           EXCEPTION;
  PRAGMA EXCEPTION_INIT(network_exists, -44314);
  null_attributes          EXCEPTION;
  PRAGMA EXCEPTION_INIT(null_attributes, -44315);
  invalid_argument         EXCEPTION;
  PRAGMA EXCEPTION_INIT(invalid_argument, -44316);
  database_readonly        EXCEPTION;
  PRAGMA EXCEPTION_INIT(database_readonly, -44317);
  max_sn_length            EXCEPTION;
  PRAGMA EXCEPTION_INIT(max_sn_length, -44318);
  aq_service               EXCEPTION;
  PRAGMA EXCEPTION_INIT(aq_service, -44319);

end dbms_service;
/

create or replace public synonym dbms_service for dbms_service
/
 ---------------------------------
 --
 -- Grant only to DBA role
 --

grant execute on dbms_service to dba
/

