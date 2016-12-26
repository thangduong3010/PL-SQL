Rem
Rem $Header: rdbms/admin/dbmscr.sql /st_rdbms_11.2.0/4 2013/04/08 09:59:24 surman Exp $
Rem
Rem dbmscr.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmscr.sql - DBMS_Registry package specs and views
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jerrede     11/05/12 - Add Exadata Bundle support
Rem    jerrede     06/21/12 - Backport jerrede_bug-13719893 from main
Rem    cdilling    02/03/12 - update version to 11.2.0.4
Rem    cdilling    11/23/10 - version to 11.2.0.3
Rem    cdilling    07/15/09 - version to 11.2.0.2.0
Rem    cdilling    04/27/09 - version to 11.2.0.1.0
Rem    cdilling    12/16/08 - version to 11.2.0.2
Rem    rlong       08/07/08 - 
Rem    cdilling    07/17/08 - version to 11.2.0.0.1
Rem    jciminsk    10/22/07 - Upgrade support for 11.2
Rem    jciminsk    10/08/07 - version to 11.2.0.0.0
Rem    jciminsk    08/03/07 - version to 11.1.0.7.0
Rem    emendez     12/14/06 - solve merge conflict
Rem    rburns      06/06/07 - update version to production
Rem    cdilling    04/18/07 - version for beta5
Rem    rburns      02/14/07 - version for BETA5
Rem    rburns      12/07/06 - move gather_stats
Rem    cdilling    12/07/06 - add populate_102
Rem    cdilling    11/13/06 - add support for registry$database
Rem    cdilling    10/06/06 - beta4 version
Rem    cdilling    10/06/06 - beta3 version
Rem    pbagal      08/03/06 - make this work for TB
Rem    rburns      09/14/06 - beta2 version
Rem    cdilling    07/31/06 - overload component dependency procedures
Rem    cdilling    06/06/06 - add comp dependency package specs and views
Rem    cdilling    05/25/06 - add progress package specs and views
Rem    rburns      05/26/06 - update log view 
Rem    cdilling    05/25/06 - add progress package specs and views
Rem    rburns      05/05/06 - registry package specs 
Rem    rburns      05/05/06 - Created
Rem
Rem -------------------------------------------------------------------------
Rem DBMS REGISTRY PACKAGE
Rem -------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_registry AS

-- CONSTANTS
release_version       CONSTANT registry$.version%type := '11.2.0.4.0';
release_status        CONSTANT VARCHAR2(30) := 'Development';

-- Component Hierarchy Type and CONSTANTS
TYPE comp_list_t      IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
IMD_COMPS             CONSTANT NUMBER :=1;  /* immediate subcomponents */
TRM_COMPS             CONSTANT NUMBER :=2;  /* terminal subcomponents */
ALL_COMPS             CONSTANT NUMBER :=3;  /* all subcomponents */

-- Schema List Parameter
TYPE schema_list_t    IS TABLE OF VARCHAR2(30);

-- Component dependency Type - table of component IDs
TYPE comp_depend_list_t IS TABLE OF VARCHAR2(30);

-- Component dependency Type - table of component IDs and associated namespaces
TYPE comp_depend_record_t IS RECORD(
    cid VARCHAR2(30), -- component id
    cnamespace VARCHAR2(30) -- component namespace
    );

TYPE comp_depend_rec IS TABLE OF comp_depend_record_t INDEX BY BINARY_INTEGER;

PROCEDURE set_session_namespace (namespace IN VARCHAR2);

PROCEDURE set_comp_namespace (comp_id IN VARCHAR2, 
                              namespace IN VARCHAR2);

PROCEDURE invalid     (comp_id      IN VARCHAR2);

PROCEDURE valid       (comp_id      IN VARCHAR2);

PROCEDURE loading     (comp_id      IN VARCHAR2,
                       comp_name    IN VARCHAR2,
                       comp_proc    IN VARCHAR2 DEFAULT NULL,
                       comp_schema  IN VARCHAR2 DEFAULT NULL,
                       comp_parent  IN VARCHAR2 DEFAULT NULL);

PROCEDURE loading     (comp_id      IN VARCHAR2,
                       comp_name    IN VARCHAR2,
                       comp_proc    IN VARCHAR2,
                       comp_schema  IN VARCHAR2,
                       comp_schemas IN schema_list_t,
                       comp_parent  IN VARCHAR2 DEFAULT NULL);

PROCEDURE loaded      (comp_id      IN VARCHAR2,
                       comp_version IN VARCHAR2 DEFAULT NULL,
                       comp_banner  IN VARCHAR2 DEFAULT NULL);

PROCEDURE upgrading   (comp_id      IN VARCHAR2,
                       new_name     IN VARCHAR2 DEFAULT NULL,
                       new_proc     IN VARCHAR2 DEFAULT NULL,
                       new_schema   IN VARCHAR2 DEFAULT NULL,
                       new_parent   IN VARCHAR2 DEFAULT NULL);

PROCEDURE upgrading   (comp_id      IN VARCHAR2,
                       new_name     IN VARCHAR2,
                       new_proc     IN VARCHAR2,
                       new_schema   IN VARCHAR2,
                       new_schemas  IN schema_list_t,
                       new_parent   IN VARCHAR2 DEFAULT NULL);

PROCEDURE upgraded     (comp_id      IN VARCHAR2,
                       new_version   IN VARCHAR2 DEFAULT NULL,
                       new_banner    IN VARCHAR2 DEFAULT NULL);

PROCEDURE downgrading (comp_id      IN VARCHAR2,
                       old_name     IN VARCHAR2 DEFAULT NULL,
                       old_proc     IN VARCHAR2 DEFAULT NULL,
                       old_schema   IN VARCHAR2 DEFAULT NULL,
                       old_parent   IN VARCHAR2 DEFAULT NULL);

PROCEDURE downgraded  (comp_id      IN VARCHAR2,
                       old_version  IN VARCHAR2);

PROCEDURE removing    (comp_id      IN VARCHAR2);

PROCEDURE removed     (comp_id      IN VARCHAR2);

PROCEDURE startup_required (comp_id IN VARCHAR2);

PROCEDURE startup_complete (comp_id IN VARCHAR2);

PROCEDURE reset_version (comp_id      IN VARCHAR2);

PROCEDURE update_schema_list     
                      (comp_id      IN VARCHAR2,
                       comp_schemas IN schema_list_t);

FUNCTION  status_name  (status NUMBER) RETURN VARCHAR2;

FUNCTION  status      (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  version     (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  prev_version (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  schema      (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  schema_list (comp_id IN VARCHAR2) RETURN schema_list_t;

FUNCTION  schema_list_string  (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  subcomponents (comp_id IN VARCHAR2, 
                         comp_option IN NUMBER DEFAULT 1) 
                         RETURN comp_list_t;

FUNCTION  comp_name   (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  session_namespace RETURN VARCHAR2;

FUNCTION  script      (comp_id IN VARCHAR2, 
                       script_name IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  script_path  (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  script_prefix  (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  nothing_script RETURN VARCHAR2;

FUNCTION  is_loaded   (comp_id IN VARCHAR2, 
                       version IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION  is_valid   (comp_id IN VARCHAR2, 
                       version IN VARCHAR2 DEFAULT NULL) RETURN NUMBER;

FUNCTION  is_startup_required (comp_id IN VARCHAR2) RETURN NUMBER;

FUNCTION  is_component (comp_id VARCHAR2) RETURN BOOLEAN;

FUNCTION  is_in_registry (comp_id IN VARCHAR2) RETURN BOOLEAN;

FUNCTION  num_of_exadata_cells RETURN NUMBER;

PROCEDURE check_server_instance;

PROCEDURE set_progress_action (comp_id IN VARCHAR2, 
                               action  IN VARCHAR2, 
                               value   IN VARCHAR2 DEFAULT NULL,
                               step    IN NUMBER DEFAULT NULL);

PROCEDURE delete_progress_action (comp_id IN VARCHAR2,
                                  action  IN VARCHAR2);

PROCEDURE set_progress_value (comp_id IN VARCHAR2, 
                              action  IN VARCHAR2, 
                              value   IN VARCHAR2);

PROCEDURE set_progress_step (comp_id IN VARCHAR2, 
                             action  IN VARCHAR2, 
                             step    IN NUMBER);

FUNCTION get_progress_value (comp_id IN VARCHAR2, 
                             action  IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_progress_step (comp_id IN VARCHAR2, 
                            action  IN VARCHAR2) RETURN NUMBER;

PROCEDURE set_required_comps (comp_id IN VARCHAR2, 
                              comp_depend_list IN comp_depend_list_t );

PROCEDURE set_required_comps (comp_id IN VARCHAR2, 
                              comp_depend_list IN comp_depend_rec );

FUNCTION get_required_comps (comp_id IN VARCHAR2) RETURN comp_depend_list_t;

FUNCTION get_required_comps_rec (comp_id IN VARCHAR2) RETURN comp_depend_rec;

FUNCTION get_dependent_comps (comp_id IN VARCHAR2) RETURN comp_depend_list_t;

FUNCTION get_dependent_comps_rec (comp_id IN VARCHAR2) RETURN comp_depend_rec;

END dbms_registry;
/

show errors

CREATE OR REPLACE PUBLIC SYNONYM dbms_registry FOR dbms_registry;

--------------------------------------------------------------------
--  Internal functions used by SYS during upgrade/downgrade
--------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_registry_sys
AS

PROCEDURE drop_user  (username IN VARCHAR2);
 
PROCEDURE validate_catalog;

PROCEDURE validate_catproc;

PROCEDURE validate_catjava;

PROCEDURE validate_components;

FUNCTION  time_stamp   (comp_id IN VARCHAR2) RETURN VARCHAR2; 

FUNCTION  time_stamp_display (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  time_stamp_comp_display (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  dbupg_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  dbdwg_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  patch_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  relod_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  cpu_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

FUNCTION  removal_script (comp_id IN VARCHAR2) RETURN VARCHAR2;

PROCEDURE check_component_downgrades;

PROCEDURE record_action (action    IN VARCHAR2, 
                         action_id IN NUMBER,
                         comments  IN VARCHAR2);

FUNCTION diagnostics RETURN NUMBER;

PROCEDURE gather_stats (comp_id IN VARCHAR2);

PROCEDURE populate;

PROCEDURE populate_92;

PROCEDURE populate_101;

PROCEDURE populate_102;

PROCEDURE set_registry_context (ctx_variable IN VARCHAR2,
                                ctx_value    IN VARCHAR2);

END dbms_registry_sys;
/

show errors

Rem -------------------------------------------------------------------------
Rem DBA_REGISTRY view
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry (
            comp_id, comp_name, version, status,
            modified, namespace, control, schema, procedure,
            startup, parent_id, other_schemas)
AS
SELECT r.cid, r.cname, r.version,
       SUBSTR(dbms_registry.status_name(r.status),1,11),
       TO_CHAR(r.modified,'DD-MON-YYYY HH24:MI:SS'), 
       r.namespace, i.name, s.name, r.vproc,
       DECODE(bitand(r.flags,1),1,'REQUIRED',NULL), r.pid,
       dbms_registry.schema_list_string(r.cid)
FROM registry$ r, user$ s, user$ i
WHERE r.schema# = s.user# AND r.invoker#=i.user#;
         
CREATE OR REPLACE PUBLIC SYNONYM dba_registry FOR dba_registry;
GRANT SELECT ON dba_registry TO SELECT_CATALOG_ROLE;

Rem -------------------------------------------------------------------------
Rem DBA_SERVER_REGISTRY view
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_server_registry (
            comp_id, comp_name, version, status,
            modified, control, schema, procedure,
            startup, parent_id, other_schemas)
AS 
SELECT comp_id, comp_name, version, status,
       modified, control, schema, procedure,
       startup, parent_id, other_schemas
FROM dba_registry 
WHERE namespace='SERVER';

CREATE OR REPLACE PUBLIC SYNONYM dba_server_registry FOR dba_server_registry;
GRANT SELECT ON dba_server_registry TO SELECT_CATALOG_ROLE;

Rem -------------------------------------------------------------------------
Rem USER_REGISTRY view
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW user_registry (
            comp_id, comp_name, version, status,
            modified, namespace, control, schema, procedure,
            startup, parent_id, other_schemas)
AS
SELECT r.cid, r.cname, r.version,
       SUBSTR(dbms_registry.status_name(r.status),1,11),
       TO_CHAR(r.modified,'DD-MON-YYYY HH24:MI:SS'), 
       r.namespace, i.name, s.name, r.vproc,
       DECODE(bitand(r.flags,1),1,'REQUIRED',NULL), r.pid,
       dbms_registry.schema_list_string(r.cid)
FROM registry$ r, user$ s, user$ i
WHERE (r.schema# = USERENV('SCHEMAID') OR r.invoker# = USERENV('SCHEMAID'))
      AND r.schema# = s.user# AND r.invoker#=i.user#;

CREATE OR REPLACE PUBLIC SYNONYM user_registry FOR user_registry;
GRANT SELECT ON user_registry TO PUBLIC;

Rem -------------------------------------------------------------------------
Rem DBA_REGISTRY_HIERARCHY view
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_hierarchy (
            namespace, comp_id, version, status, modified)
AS
SELECT namespace, LPAD(' ',2*(LEVEL-1)) || LEVEL || ' ' || cid, version,
       SUBSTR(dbms_registry.status_name(status),1,11),
       TO_CHAR(modified,'DD-MON-YYYY HH24:MI:SS')
FROM registry$ 
START WITH pid IS NULL
CONNECT BY PRIOR cid = pid and PRIOR namespace = namespace;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_hierarchy 
                  FOR dba_registry_hierarchy;
GRANT SELECT ON dba_registry_hierarchy TO SELECT_CATALOG_ROLE;

Rem -------------------------------------------------------------------------
Rem ALL_REGISTRY_BANNERS view
Rem    Public view of valid components in the database
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW all_registry_banners 
AS
SELECT banner FROM registry$
WHERE status = 1; 

CREATE OR REPLACE PUBLIC SYNONYM all_registry_banners
                  FOR all_registry_banners;
GRANT SELECT ON all_registry_banners TO PUBLIC;

Rem -------------------------------------------------------------------------
Rem  CREATE log view 
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_log (
            optime, namespace, comp_id, operation, message)
AS
SELECT optime,
       namespace, cid,
       DECODE(operation,-1, 'START',
                         0, 'INVALID',
                         1, 'VALID',
                         2, 'LOADING',
                         3, 'LOADED',
                         4, 'UPGRADING',
                         5, 'UPGRADED',
                         6, 'DOWNGRADING',
                         7, 'DOWNGRADED',
                         8, 'REMOVING',
                         9, 'OPTION OFF',
                         10, 'NO SCRIPT',
                         99, 'REMOVED',
                         100, 'ERROR',
                         NULL),
       errmsg
FROM registry$log;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_log
                  FOR dba_registry_log;
GRANT SELECT ON dba_registry_log TO SELECT_CATALOG_ROLE;

Rem -------------------------------------------------------------------------
Rem CREATE history VIEW
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_history (
            action_time, action, namespace, version, id, comments)
AS
SELECT action_time, action, namespace, version, id, comments
FROM registry$history;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_history FOR dba_registry_history;
GRANT SELECT ON dba_registry_history TO SELECT_CATALOG_ROLE;


Rem -------------------------------------------------------------------------
Rem CREATE progress VIEW
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_progress (
            comp_id, namespace, action, value, step, action_time)
AS
SELECT  cid, namespace, action, value, step, action_time
FROM registry$progress;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_progress 
                  FOR dba_registry_progress;
GRANT SELECT ON dba_registry_progress TO SELECT_CATALOG_ROLE;

Rem -------------------------------------------------------------------------
Rem CREATE dependencies VIEW
Rem -------------------------------------------------------------------------

CREATE OR REPLACE VIEW dba_registry_dependencies (
            comp_id, namespace, req_comp_id, req_namespace)
AS
SELECT  cid, namespace, req_cid, req_namespace
FROM registry$dependencies;

CREATE OR REPLACE PUBLIC SYNONYM dba_registry_dependencies 
                  FOR dba_registry_dependencies;
GRANT SELECT ON dba_registry_dependencies TO SELECT_CATALOG_ROLE;

Rem -------------------------------------------------------------------------
Rem CREATE database VIEW
Rem -------------------------------------------------------------------------
 
CREATE OR REPLACE VIEW dba_registry_database (
            platform_id, platform_name, edition)
AS
SELECT  platform_id, platform_name, edition
FROM registry$database;
 
CREATE OR REPLACE PUBLIC SYNONYM dba_registry_database
                   FOR dba_registry_database;
GRANT SELECT ON dba_registry_database TO SELECT_CATALOG_ROLE;
