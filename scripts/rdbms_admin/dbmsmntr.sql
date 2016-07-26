Rem
Rem $Header: dbmsmntr.sql 26-apr-2007.16:04:56 rcolle Exp $
Rem
Rem dbmsmntr.sql
Rem
Rem Copyright (c) 2002, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsmntr.sql - DBMS_MONITOR package
Rem
Rem    DESCRIPTION
Rem      Package to monitor certain aspects of database performance. The
Rem      initial functionality includes turning on SQL trace and on-demand
Rem      aggregation
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rcolle      04/26/07 - changed plan_stat argument position for backward
Rem                           compatibilty
Rem    rcolle      04/05/07 - add plan_stat argument
Rem    atsukerm    04/21/04 - add database-level trace procedures 
Rem    atsukerm    10/06/03 - change defaults for session_trace_enable 
Rem    aime        04/25/03 - aime_going_to_main
Rem    atsukerm    12/05/02 - atsukerm_e2etr
Rem    atsukerm    10/24/02 - continue work after refresh
Rem    atsukerm    10/10/02 - more work after refresh
Rem    atsukerm    09/23/02 - Created
Rem

create or replace package dbms_monitor is
  ------------
  --  OVERVIEW
  --
  --  This package provides database monitoring functionality, initially
  --  in the area of statistics aggregation and SQL tracing

  --  SECURITY
  --
  --  runs with SYS privileges. 

  --  CONSTANTS to be used as OPTIONS for various procedures
  --  refer comments with procedure(s) for more detail

  all_modules                    CONSTANT VARCHAR2(14) := '###ALL_MODULES';
  all_actions                    CONSTANT VARCHAR2(14) := '###ALL_ACTIONS';

  -- Indicates that tracing/aggregation for a given module should be enabled
  -- for all actions

  ----------------------------

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  PROCEDURE client_id_stat_enable(
    client_id IN VARCHAR2);

  --  Enables statistics aggregation for the given Client ID
  --  Input arguments:
  --   client_id           - Client Identifier for which the statistics
  --                         colection is enabled

  PROCEDURE client_id_stat_disable(
    client_id IN VARCHAR2);

  --  Disables statistics aggregation for the given Client ID
  --  Input arguments:
  --   client_id           - Client Identifier for which the statistics
  --                         colection is disabled

  PROCEDURE serv_mod_act_stat_enable(
    service_name IN VARCHAR2,
    module_name IN VARCHAR2,
    action_name IN VARCHAR2 DEFAULT ALL_ACTIONS);

  --  Enables statistics aggregation for the given service/module/action
  --  Input arguments:
  --   service_name        - Service Name for which the statistics
  --                         colection is enabled
  --   module_name         - Module Name for which the statistics
  --                         colection is enabled
  --   action_name         - Action Name for which the statistics
  --                         colection is enabled. The name is optional.
  --                         if omitted, statistic aggregation is enabled
  --                         for all actions in a given module

  PROCEDURE serv_mod_act_stat_disable(
    service_name IN VARCHAR2,
    module_name IN VARCHAR2,
    action_name IN VARCHAR2 DEFAULT ALL_ACTIONS);

  --  Disables statistics aggregation for the given service/module/action
  --  Input arguments:
  --   service_name        - Service Name for which the statistics
  --                         colection is disabled
  --   module_name         - Module Name for which the statistics
  --                         colection is disabled
  --   action_name         - Action Name for which the statistics
  --                         colection is disabled. The name is optional.
  --                         if omitted, statistic aggregation is disabled
  --                         for all actions in a given module

  PROCEDURE client_id_trace_enable(
    client_id IN VARCHAR2,
    waits IN BOOLEAN DEFAULT TRUE,
    binds IN BOOLEAN DEFAULT FALSE,
    plan_stat IN VARCHAR2 DEFAULT NULL);

  --  Enables SQL for the given Client ID
  --  Input arguments:
  --   client_id           - Client Identifier for which SQL trace
  --                         is enabled
  --   waits               - If TRUE, wait information will be present in the
  --                         the trace
  --   binds               - If TRUE, bind information will be present in the
  --                         the trace
  --   plan_stat           - Frequency at which we dump row source statistics.
  --                         Value should be 'never', 'first_execution'
  --                         (equivalent to NULL) or 'all_executions'.

  PROCEDURE client_id_trace_disable(
    client_id IN VARCHAR2);

  --  Disables SQL trace for the given Client ID
  --  Input arguments:
  --   client_id           - Client Identifier for which SQL trace
  --                         is disabled

  PROCEDURE serv_mod_act_trace_enable(
    service_name IN VARCHAR2,
    module_name IN VARCHAR2 DEFAULT ALL_MODULES,
    action_name IN VARCHAR2 DEFAULT ALL_ACTIONS,
    waits IN BOOLEAN DEFAULT TRUE,
    binds IN BOOLEAN DEFAULT FALSE,
    instance_name IN VARCHAR2 DEFAULT NULL,
    plan_stat IN VARCHAR2 DEFAULT NULL);

  --  Enables SQL trace for the given service/module/action
  --  Input arguments:
  --   service_name        - Service Name for which SQL trace
  --                         is enabled
  --   module_name         - Module Name for which SQL trace
  --                         is enabled. The name is optional.
  --                         if omitted, SQL trace is enabled
  --                         for all modules and actions actions in a given 
  --                         service
  --   action_name         - Action Name for which SQL trace
  --                         is enabled. The name is optional.
  --                         if omitted, SQL trace is enabled
  --                         for all actions in a given module
  --   waits               - If TRUE, wait information will be present in the
  --                         the trace
  --   binds               - If TRUE, bind information will be present in the
  --                         the trace
  --   instance_name       - if set, restricts tracing to the named instance
  --   plan_stat           - Frequency at which we dump row source statistics.
  --                         Value should be 'never', 'first_execution'
  --                         (equivalent to NULL) or 'all_executions'.

  PROCEDURE serv_mod_act_trace_disable(
    service_name IN VARCHAR2,
    module_name IN VARCHAR2 DEFAULT ALL_MODULES,
    action_name IN VARCHAR2 DEFAULT ALL_ACTIONS,
    instance_name IN VARCHAR2 DEFAULT NULL);

  --  Disables SQL trace for the given service/module/action
  --  Input arguments:
  --   service_name        - Service Name for which SQL trace
  --                         is disabled
  --   module_name         - Module Name for which SQL trace
  --                         is disabled. The name is optional.
  --                         if omitted, SQL trace is disabled
  --                         for all modules and actions actions in a given 
  --   action_name         - Action Name for which SQL trace
  --                         is disabled. The name is optional.
  --                         if omitted, SQL trace is disabled
  --                         for all actions in a given module
  --                         the trace
  --   instance_name       - if set, restricts disabling to the named instance

  PROCEDURE session_trace_enable(
    session_id IN BINARY_INTEGER DEFAULT NULL,
    serial_num IN BINARY_INTEGER DEFAULT NULL,
    waits IN BOOLEAN DEFAULT TRUE,
    binds IN BOOLEAN DEFAULT FALSE,
    plan_stat  IN VARCHAR2 DEFAULT NULL);

  --  Enables SQL trace for the given Session ID
  --  Input arguments:
  --   session_id          - Session Identifier for which SQL trace
  --                         is enabled. If omitted (or NULL), the
  --                         user's own session is assumed
  --   serial_num          - Session serial number for which SQL trace
  --                         is enabled. If omitted (or NULL), only
  --                         the session ID is used to determine a session
  --   waits               - If TRUE, wait information will be present in the
  --                         the trace
  --   binds               - If TRUE, bind information will be present in the
  --                         the trace
  --   plan_stat           - Frequency at which we dump row source statistics.
  --                         Value should be 'never', 'first_execution'
  --                         (equivalent to NULL) or 'all_executions'.

  PROCEDURE session_trace_disable(
    session_id IN BINARY_INTEGER DEFAULT NULL,
    serial_num IN BINARY_INTEGER DEFAULT NULL);

  --  Disables SQL trace for the given Session ID
  --  Input arguments:
  --   session_id          - Session Identifier for which SQL trace
  --                         is disabled
  --   serial_num          - Session serial number for which SQL trace
  --                         is disabled

  PROCEDURE database_trace_enable(
    waits IN BOOLEAN DEFAULT TRUE,
    binds IN BOOLEAN DEFAULT FALSE,
    instance_name IN VARCHAR2 DEFAULT NULL,
    plan_stat IN VARCHAR2 DEFAULT NULL);

  --  Enables SQL trace for the whole database or given instance
  --  Input arguments:
  --   waits               - If TRUE, wait information will be present in the
  --                         the trace
  --   binds               - If TRUE, bind information will be present in the
  --                         the trace
  --   instance_name       - if set, restricts tracing to the named instance
  --   plan_stat           - Frequency at which we dump row source statistics.
  --                         Value should be 'never', 'first_execution'
  --                         (equivalent to NULL) or 'all_executions'.


  PROCEDURE database_trace_disable(
    instance_name IN VARCHAR2 DEFAULT NULL);

  --  Disables SQL trace for the whole database or given instance
  --  Input arguments:
  --   instance_name       - if set, restricts disabling to the named instance
end;
/

create or replace public synonym dbms_monitor for sys.dbms_monitor
/
grant execute on dbms_monitor to dba;
/
-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_MONITOR_LIB TRUSTED AS STATIC;
/

