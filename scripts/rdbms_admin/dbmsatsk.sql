Rem
Rem $Header: dbmsatsk.sql 30-may-2007.12:48:38 ilistvin Exp $
Rem
Rem dbmsatsk.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsatsk.sql - Automated Maintenance Tasks Package Specifications
Rem
Rem    DESCRIPTION
Rem      Defines interfaces for Automated Maintenance Tasks
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ilistvin    05/30/07 - add gather_optimizer_stats API
Rem    ilistvin    04/30/07 - add downgrade proc
Rem    pbelknap    01/12/07 - add client status override functions
Rem    ilistvin    11/21/06 - grant dbms_auto_task to public
Rem    ilistvin    08/01/06 - add post-import callout
Rem    ilistvin    03/09/06 - Autotask public packages. 
Rem    ilistvin    03/09/06 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_auto_task AS

TYPE window_calendar_entry IS RECORD  (
   window_name   dba_scheduler_windows.window_name%TYPE,
   start_time    TIMESTAMP WITH TIME ZONE,
   duration      dba_scheduler_windows.duration%TYPE);

TYPE window_calendar_t IS TABLE OF window_calendar_entry;

TYPE winname_t IS RECORD (
    window_name dba_scheduler_windows.window_name%TYPE,
    start_date  TIMESTAMP WITH TIME ZONE,
    end_date    TIMESTAMP WITH TIME ZONE);

TYPE refcur_winname_t IS REF CURSOR RETURN winname_t;

FUNCTION WINDOW_CALENDAR(w  refcur_winname_t) RETURN window_calendar_t PIPELINED;

-- compute a list of  the task scheduled date provide the start and end dates.
-- taskname is the defined autotask name (used by EM)
PROCEDURE  get_schedule_date
   (taskname        IN  VARCHAR2, 
    start_date      IN  timestamp with time zone,  
    end_date        IN  timestamp with time zone,
    scheduled_list OUT  ket$_window_list);

--
-- combines supplied attribute flag sets into a single set of attribute
-- flags. Arguments listed in order of descending priority. I.e.
-- task_rep_attr settings, if any, override all of the other setings.
--
FUNCTION reconcile_attributes (
     cli_comp_attr  IN NUMBER DEFAULT 0, -- client compile-time attributes
     cli_rep_attr   IN NUMBER DEFAULT 0, -- client repository attributes
     op_comp_attr   IN NUMBER DEFAULT 0, -- operation compile-time attributes
     op_rep_attr    IN NUMBER DEFAULT 0, -- operation repository attributes
     task_comp_attr IN NUMBER DEFAULT 0, -- task client-defined attributes
     task_rep_attr  IN NUMBER DEFAULT 0  -- task repository override attributes
) RETURN NUMBER;

--
-- decode attribute flags into a string for display
--
FUNCTION decode_attributes (attr NUMBER DEFAULT 0) RETURN VARCHAR2;

--
-- determine if a given client's status should be overridden to DISABLED
-- even if it is ENABLED on disk (e.g. pack disabled, underscore parameter, etc).
-- A return value of 1 means such an override exists, 0 means it does not.
--
FUNCTION get_client_status_override(client_id IN PLS_INTEGER) RETURN PLS_INTEGER;

--
-- signal an error if the client is overridden to DISABLED even if it is 
-- enabled on disk (e.g. pack disabled, underscore parameter, etc).  Called to
-- validate an ENABLE operation.
--
PROCEDURE check_client_status_override(client_id IN PLS_INTEGER);

END dbms_auto_task;
/
-- create public synonym
CREATE OR REPLACE PUBLIC SYNONYM dbms_auto_task
FOR sys.dbms_auto_task
/
GRANT EXECUTE ON dbms_auto_task TO PUBLIC
/ 

CREATE OR REPLACE PACKAGE dbms_auto_task_admin AS
-- PUBLIC CONSTANTS
--
-- Option Flags
--
OPTFLG_DEFERRED  CONSTANT VARCHAR2(16) := 'DEFERRED';
OPTFLG_IMMEDIATE CONSTANT VARCHAR2(16) := 'IMMEDIATE';

--
-- Task Priority
--
PRIORITY_MEDIUM CONSTANT  VARCHAR2(6) := 'MEDIUM';
       -- Task with this priority should be executed as time permits.
PRIORITY_HIGH   CONSTANT  VARCHAR2(6) := 'HIGH';
       -- Task with this priority should be executed within 
       -- the current Maintenance Window.
PRIORITY_URGENT CONSTANT  VARCHAR2(6) := 'URGENT';
       -- Task with this is to be executed at the earliest opportunity.
PRIORITY_CLEAR  CONSTANT  VARCHAR2(6) := 'CLEAR';
       -- This isepcial priority is used to clear previous settings
--
-- Settable Attrributes 
--
-- The following two attributes are mutually exclusive
-- Setting either one will automatically unset the other
LIGHTWEIGHT          CONSTANT VARCHAR2(16) := 'LIGHTWEIGHT';
HEAVYWEIGHT          CONSTANT VARCHAR2(16) := 'HEAVYWEIGHT';

-- The following two attributes are mutually exclusive
-- Setting either one will automatically unset the other
VOLATILE             CONSTANT VARCHAR2(16) := 'VOLATILE';
STABLE               CONSTANT VARCHAR2(16) := 'STABLE';

-- The following two attributes are mutually exclusive
-- Setting either one will automatically unset the other
SAFE_TO_KILL         CONSTANT VARCHAR2(16) := 'SAFE_TO_KILL';
DO_NOT_KILL          CONSTANT VARCHAR2(16) := 'DO_NOT_KILL';

--
-- Attribute value flags
--
ATTRVAL_TRUE     CONSTANT VARCHAR2(5)  := 'TRUE';
ATTRVAL_FALSE    CONSTANT VARCHAR2(5)  := 'FALSE';

-- GET_P1_RESOURCES
--
-- This procedure returns percent of resources allocated to each 
-- AUTOTASK High Priority Consumer Group.
--
-- Values will add up to 100 (percent). 
PROCEDURE GET_P1_RESOURCES (
  STATS_GROUP_PCT   OUT      NUMBER,  -- %resources for Statistics Gathering
  SEG_GROUP_PCT     OUT      NUMBER,  -- %resources for Space Management
  TUNE_GROUP_PCT    OUT      NUMBER,  -- %resources for SQL Tuning
  HEALTH_GROUP_PCT  OUT      NUMBER   -- %resources for Health Checks
);

-- SET_P1_RESOURCES
--
-- This procedure sets percentage-based resource allocation for each 
-- High Priority Consumer Group used by AUTOTASK Clients.
--
-- Values must be integers in the range 0 to 100, and must add up to 100 
-- (percent), otherwise, an exception is raised.
--
PROCEDURE SET_P1_RESOURCES (
  STATS_GROUP_PCT    IN      NUMBER, -- %resources for Statistics Gathering
  SEG_GROUP_PCT      IN      NUMBER, -- %resources for Space Management
  TUNE_GROUP_PCT     IN      NUMBER, -- %resources for SQL Tuning
  HEALTH_GROUP_PCT   IN      NUMBER  -- %resources for Health Checks
);

-- SET_CLIENT_SERVICE API
--
-- This procedure associates an AUTOTASK Client with a specified Service. 
-- All work performed on behalf of the Client will take place only on 
-- instances where the service is enabled.
--
PROCEDURE SET_CLIENT_SERVICE (
  CLIENT_NAME      IN      VARCHAR2,  -- name of the client, as found in 
                                      -- DBA_AUTOTASK_CLIENT View.
  SERVICE_NAME     IN      VARCHAR2   -- Service name for client, may be NULL
);

--GET_CLIENT_ATTRIBUTES API
--
-- This procedure returns values of select client attributes.
--
PROCEDURE GET_CLIENT_ATTRIBUTES (
  CLIENT_NAME      IN      VARCHAR2, -- name of the client, as found in 
                                     -- DBA_AUTOTASK_CLIENT View.
  SERVICE_NAME    OUT      VARCHAR2, -- Service name for client, may be NULL
  WINDOW_GROUP    OUT      VARCHAR2  -- Name of the window group in which
                                     -- the client is active
);

--
-- DISABLE API
-- This interface prevents Autotask from executing any requests 
-- 

-- Disabling AUTOTASK
--
-- This version completely disables all AUTOTASK functionality. 
-- If "IMMEDIATE" is specified, all running AUTOTASK jobs will be stopped.
--
PROCEDURE DISABLE;


-- Disabling an AUTOTASK Client
--  (optionally, only affecting one maintenance window)
--  (optionally, disabling a specific Operation for a Client)
--
-- This version disables specified a client.
-- Either a specific operation or a maintenance window name, but
-- not both, are meaningful.
-- If an operation is disabled, tasks specifying this operation 
--  will not be performed. WINDOW_NAME is ignored for OPERATION.
-- 
-- If a window name is specified, client will be disabled in the
-- specified window.
--
PROCEDURE DISABLE (
  CLIENT_NAME        IN    VARCHAR2,  -- name of the client, as found in 
                                      -- DBA_AUTOTASK_CLIENT View.
  OPERATION          IN    VARCHAR2,  -- Name of the operation as specified in 
                                      -- DBA_AUTOTASK_OPERATION View
  WINDOW_NAME        IN    VARCHAR2   -- optional name of the window in which 
                                      -- client is to be disabled
);

-- ENABLE API
--
-- This interface allows a previously disabled client, operation, 
--

-- Re-Enabling AUTOTASK
PROCEDURE ENABLE;

--
-- Re-Enabling a Client
-- Optionally, re-enabling an Operation
-- Optionally, re-enabling a Client in a specific maintenance window
--
-- Either a specific operation or a maintenance window name, but
-- not both, may be specified.
--
PROCEDURE ENABLE (
  CLIENT_NAME      IN      VARCHAR2,  -- name of the client, as found in 
                                      -- DBA_AUTOTASK_CLIENT View.
  OPERATION        IN      VARCHAR2,  -- Name of the operation as specified in
                                      -- DBA_AUTOTASK_OPERATION View
  WINDOW_NAME      IN      VARCHAR2    -- optional name of the window in 
                                       -- which the client is to be enabled.
);


-- OVERRIDE_PRIORITY API
--
-- This API is used to manually override task priority. This can be done
-- at the client, operation or individual task level. This priority assignment
-- will be honored during the next maintenance window in which the named 
-- client is active. Specifically, setting the priority to Urgent will cause 
-- a high priority job to be generated at the start of the maintenance window.
--
-- The following priorities are defined:
-- PRIORITY_MEDIUM - 'time permitting'
-- PRIORITY_HIGH   - normal priority
-- PRIORITY_URGENT - 'ASAP'
--
-- Setting PRIORITY to PRIORITY_CLEAR removes the override.
--

-- Override Priority for a Client
PROCEDURE OVERRIDE_PRIORITY (
  CLIENT_NAME     IN      VARCHAR2, -- name of the client as found in 
                                    -- DBA_AUTOTASK_CLIENT View.
  PRIORITY        IN      VARCHAR2  -- See above.
);

-- Override Priority for an Operation
PROCEDURE OVERRIDE_PRIORITY (
  CLIENT_NAME  IN      VARCHAR2, -- name of the client as found in 
                                 -- DBA_AUTOTASK_CLIENT View.
  OPERATION    IN      VARCHAR2, -- Name of the operation as specified in 
                                 -- DBA_AUTOTASK_OPERATION View
  PRIORITY     IN      VARCHAR2  -- See above
);


-- SET_ATTRIBUTE API
--
-- This API is used to set boolean attributes for a Client, Operation, or Task.
-- The following attributes may be set:
--   LIGHTWEIGHT
--   HEAVYWEIGHT
--             - seting either of the above attributes ON, turns the other OFF
--   VOLATILE
--   STABLE
--             - seting either of the above attributes ON, turns the other OFF
--   SAFE_TO_KILL
--   DO_NOT_KILL
--             - seting either of the above attributes ON, turns the other OFF
-- 
-- Setting attributes for a Client
PROCEDURE SET_ATTRIBUTE (
  CLIENT_NAME        IN      VARCHAR2, -- Name of the client as found in 
                                       -- DBA_AUTOTASK_CLIENT View.
  ATTRIBUTE_NAME     IN      VARCHAR2, -- Attribute to be set
  ATTRIBUTE_VALUE    IN      VARCHAR2  -- Attribute value, "TRUE", "FALSE" 
);

-- Setting attributes for an Operation
PROCEDURE SET_ATTRIBUTE (
  CLIENT_NAME        IN      VARCHAR2, -- Name of the client as found in 
                                       -- DBA_AUTOTASK_CLIENT View.
  OPERATION          IN      VARCHAR2, -- Name of the operation as in 
                                       -- DBA_AUTOTASK_OPERATION View
  ATTRIBUTE_NAME     IN      VARCHAR2, -- Attribute to be set
  ATTRIBUTE_VALUE    IN      VARCHAR2  -- Attribute value, "TRUE", "FALSE"
);

end dbms_auto_task_admin;
/
-- create public synonym
CREATE OR REPLACE PUBLIC SYNONYM dbms_auto_task_admin
FOR sys.dbms_auto_task_admin
/
-- grant execute privilege to dba, old import and Data Pump import
GRANT EXECUTE ON dbms_auto_task_admin TO dba
/
GRANT EXECUTE ON dbms_auto_task_admin TO imp_full_database
/
GRANT EXECUTE ON dbms_auto_task_admin TO datapump_imp_full_database
/

CREATE OR REPLACE PACKAGE dbms_auto_task_immediate AS
  PROCEDURE GATHER_OPTIMIZER_STATS;
END dbms_auto_task_immediate;
/
-- create public synonym
CREATE OR REPLACE PUBLIC SYNONYM dbms_auto_task_immediate
FOR sys.dbms_auto_task_immediate
/
-- grant execute privilege to dba, old import and Data Pump import
GRANT EXECUTE ON dbms_auto_task_immediate TO dba
/
CREATE OR REPLACE PACKAGE dbms_auto_task_export AUTHID CURRENT_USER AS

-- Generate PL/SQL for procedural actions
 FUNCTION system_info_exp(prepost IN PLS_INTEGER,
                          connectstring OUT VARCHAR2,
                          version IN VARCHAR2,
                          new_block OUT PLS_INTEGER)
 RETURN VARCHAR2;

-- import callout for 10.x to 11.x upgrade
PROCEDURE POST_UPGRADE_FROM_10G;

-- downgrade from 11g
PROCEDURE DOWNGRADE_FROM_11G;

END dbms_auto_task_export;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_auto_task_export
   for sys.dbms_auto_task_export;

GRANT EXECUTE ON dbms_auto_task_export TO EXECUTE_CATALOG_ROLE;

GRANT EXECUTE ON dbms_auto_task_export TO EXP_FULL_DATABASE;

GRANT EXECUTE ON dbms_auto_task_export TO IMP_FULL_DATABASE;

