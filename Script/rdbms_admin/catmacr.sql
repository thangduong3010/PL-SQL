Rem
Rem
Rem Copyright (c) 2004, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem Copyright (c) 2004, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem    NAME
Rem      catmacr.sql
Rem
Rem    DESCRIPTION
Rem      Creates roles and grants for realm owners that need ANY
Rem         object privileges at schema level (DV_REALM_OWNER)
Rem         user resource privilege role (DV_REALM_RESOURCE)
Rem
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    jsamuel    10/28/08 - remove error messages anonymous block
Rem    ruparame   08/18/08 - Grant access on dba_audit_trail to DV_MONITOR
Rem    ayalaman   08/07/06 - hardening
Rem    jciminsk   05/02/06 - cleanup embedded file boilerplate 
Rem    jciminsk   05/02/06 - created admin/catmacr.sql 
Rem    sgaetjen   08/11/05 - sgaetjen_dvschema
Rem    sgaetjen   08/06/05 - Remove drop 
Rem    sgaetjen   07/30/05 - clean up comments 
Rem    sgaetjen   07/28/05 - dos2unix
Rem    sgaetjen   07/25/05 - ADE and merge with product roles
Rem    sgaetjen   12/20/04 - Created
Rem
Rem
Rem

------------------------------------------------
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_realm_resource';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_realm_owner';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/

------------------------------------------------

GRANT CREATE CLUSTER            TO dv_realm_resource
/

--GRANT CREATE DATABASE LINK      TO dv_realm_resource
--/

GRANT CREATE INDEXTYPE          TO dv_realm_resource
/
GRANT CREATE OPERATOR           TO dv_realm_resource
/
GRANT CREATE PROCEDURE          TO dv_realm_resource
/
GRANT CREATE SEQUENCE           TO dv_realm_resource
/
GRANT CREATE SYNONYM            TO dv_realm_resource
/
GRANT CREATE TABLE              TO dv_realm_resource
/
GRANT CREATE TRIGGER            TO dv_realm_resource
/
GRANT CREATE TYPE               TO dv_realm_resource
/
GRANT CREATE VIEW               TO dv_realm_resource
/

--GRANT UNLIMITED TABLESPACE      TO dv_realm_resource
--/

----------------------------------------------------------
-- dv_realm_owner
-- role and privileges are protected by the realm
GRANT CREATE ROLE                  TO dv_realm_owner;
GRANT ALTER ANY ROLE               TO dv_realm_owner;
GRANT DROP  ANY ROLE               TO dv_realm_owner;

GRANT GRANT ANY ROLE               TO dv_realm_owner;
GRANT GRANT ANY PRIVILEGE          TO dv_realm_owner;
GRANT GRANT ANY OBJECT PRIVILEGE   TO dv_realm_owner;

-- advanced queuing
---GRANT AQ_ADMINISTRATOR_ROLE        TO dv_realm_owner;
GRANT COMMENT ANY TABLE            TO dv_realm_owner;

-- create any objects
GRANT CREATE ANY CLUSTER           TO dv_realm_owner;
GRANT CREATE ANY CONTEXT           TO dv_realm_OWNER;
GRANT CREATE ANY DIMENSION         TO dv_realm_owner;
-- directory's are owned by SYS
-- GRANT CREATE ANY DIRECTORY         TO dv_realm_owner;
GRANT CREATE ANY INDEX             TO dv_realm_owner;
GRANT CREATE ANY INDEXTYPE         TO dv_realm_owner;
GRANT CREATE ANY MATERIALIZED VIEW TO dv_realm_owner;
GRANT CREATE ANY OPERATOR          TO dv_realm_owner;
GRANT CREATE ANY OUTLINE           TO dv_realm_owner;
GRANT CREATE ANY PROCEDURE         TO dv_realm_owner;
GRANT CREATE ANY SEQUENCE          TO dv_realm_owner;
GRANT CREATE ANY SNAPSHOT          TO dv_realm_owner;
GRANT CREATE ANY SYNONYM           TO dv_realm_owner;
GRANT CREATE ANY TABLE             TO dv_realm_owner;
GRANT CREATE ANY TRIGGER           TO dv_realm_owner;
GRANT CREATE ANY TYPE              TO dv_realm_owner;
GRANT CREATE ANY VIEW              TO dv_realm_owner;

-- alter any object
GRANT ALTER ANY CLUSTER            TO dv_realm_owner;
GRANT ALTER ANY DIMENSION          TO dv_realm_owner;
GRANT ALTER ANY INDEX              TO dv_realm_owner;
GRANT ALTER ANY INDEXTYPE          TO dv_realm_owner;
GRANT ALTER ANY MATERIALIZED VIEW  TO dv_realm_owner;
GRANT ALTER ANY OPERATOR           TO dv_realm_owner;
GRANT ALTER ANY OUTLINE            TO dv_realm_owner;
GRANT ALTER ANY PROCEDURE          TO dv_realm_owner;
GRANT ALTER ANY SEQUENCE           TO dv_realm_owner;
GRANT ALTER ANY SNAPSHOT           TO dv_realm_owner;
GRANT ALTER ANY TABLE              TO dv_realm_owner;
GRANT ALTER ANY TRIGGER            TO dv_realm_owner;
GRANT ALTER ANY TYPE               TO dv_realm_owner;

-- drop any object
GRANT DROP ANY CLUSTER             TO dv_realm_owner;
GRANT DROP ANY DIMENSION           TO dv_realm_owner;
GRANT DROP ANY INDEX               TO dv_realm_owner;
GRANT DROP ANY INDEXTYPE           TO dv_realm_owner;
GRANT DROP ANY MATERIALIZED VIEW   TO dv_realm_owner;
GRANT DROP ANY OPERATOR            TO dv_realm_owner;
GRANT DROP ANY OUTLINE             TO dv_realm_owner;
GRANT DROP ANY PROCEDURE           TO dv_realm_owner;
GRANT DROP ANY SEQUENCE            TO dv_realm_owner;
GRANT DROP ANY SNAPSHOT            TO dv_realm_owner;
GRANT DROP ANY SYNONYM             TO dv_realm_owner;
GRANT DROP ANY TABLE               TO dv_realm_owner;
GRANT DROP ANY TRIGGER             TO dv_realm_owner;
GRANT DROP ANY TYPE                TO dv_realm_owner;
GRANT DROP ANY VIEW                TO dv_realm_owner;

-- SELECT and DML on ANY
GRANT SELECT  ANY  TABLE     TO dv_realm_owner;
GRANT SELECT  ANY  SEQUENCE  TO dv_realm_owner;
GRANT UPDATE  ANY  TABLE     TO dv_realm_owner;
GRANT DELETE  ANY  TABLE     TO dv_realm_owner;
GRANT INSERT  ANY  TABLE     TO dv_realm_owner;

-- EXECUTE ANY privileges
GRANT EXECUTE ANY INDEXTYPE TO dv_realm_owner;
GRANT EXECUTE ANY OPERATOR  TO dv_realm_owner;
GRANT EXECUTE ANY PROCEDURE TO dv_realm_owner;
GRANT EXECUTE ANY TYPE      TO dv_realm_owner;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates roles and grants for Database User Manager (DV_ACCTMGR)
Rem
Rem
Rem
Rem
Rem

GRANT CREATE USER TO dv_acctmgr
/
GRANT ALTER USER TO dv_acctmgr
/
GRANT DROP USER TO dv_acctmgr
/
GRANT CREATE PROFILE TO dv_acctmgr
/
GRANT ALTER PROFILE TO dv_acctmgr
/
GRANT DROP PROFILE TO dv_acctmgr
/
GRANT CREATE SESSION TO dv_acctmgr WITH ADMIN OPTION
/
GRANT CONNECT TO dv_acctmgr WITH ADMIN OPTION
/

GRANT SELECT ON sys.dba_users TO dv_acctmgr
/
GRANT SELECT ON sys.dba_profiles TO dv_acctmgr
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates roles and grants for DVSYS Reporting role (DV_SECANALYST)
Rem
Rem
Rem
Rem
Rem

-- auditing
GRANT SELECT ON sys.dba_audit_trail TO dv_secanalyst
/
GRANT SELECT ON sys.dba_audit_trail TO dv_monitor
/

/*
-- does not exist until OLS installed
GRANT SELECT ON system.aud$ TO dv_secanalyst
/
*/

-- SYS
GRANT SELECT ON sys.dba_users TO dv_secanalyst
/

GRANT SELECT ON sys.dba_roles TO dv_secanalyst
/

GRANT SELECT ON sys.dba_role_privs TO dv_secanalyst
/

GRANT SELECT ON sys.dba_tab_privs TO dv_secanalyst
/

GRANT SELECT ON sys.dba_col_privs TO dv_secanalyst
/

GRANT SELECT ON sys.dba_tables TO dv_secanalyst
/

GRANT SELECT ON sys.dba_views TO dv_secanalyst
/

GRANT SELECT ON sys.dba_clusters TO dv_secanalyst
/

GRANT SELECT ON sys.dba_indexes TO dv_secanalyst
/

GRANT SELECT ON sys.dba_tab_columns TO dv_secanalyst
/

GRANT SELECT ON sys.dba_objects TO dv_secanalyst
/

GRANT SELECT ON sys.dba_sys_privs TO dv_secanalyst
/

GRANT SELECT ON sys.dba_policies TO dv_secanalyst
/

GRANT SELECT ON sys.dba_java_policy TO dv_secanalyst
/

GRANT SELECT ON sys.dba_triggers TO dv_secanalyst
/

GRANT SELECT ON sys.gv_$session TO dv_secanalyst
/

GRANT SELECT ON sys.v_$instance TO dv_secanalyst
/

GRANT SELECT ON sys.gv_$instance TO dv_secanalyst
/

GRANT SELECT ON sys.v_$session TO dv_secanalyst
/

GRANT SELECT ON sys.v_$database TO dv_secanalyst
/

GRANT SELECT ON sys.v_$parameter TO dv_secanalyst
/

GRANT SELECT ON sys.exu9rls TO dv_secanalyst
/

GRANT SELECT ON sys.dba_profiles TO dv_secanalyst
/

GRANT SELECT ON sys.objauth$ TO dv_secanalyst
/

GRANT SELECT ON sys.sysauth$ TO dv_secanalyst
/

GRANT SELECT ON sys.obj$ TO dv_secanalyst
/

-- GRANT SELECT ON sys.col$ TO dv_secanalyst
-- /

GRANT SELECT ON sys.tab$ TO dv_secanalyst
/

GRANT SELECT ON sys.user$ TO dv_secanalyst
/

GRANT SELECT ON sys.table_privilege_map TO dv_secanalyst
/

GRANT SELECT ON sys.system_privilege_map TO dv_secanalyst
/

GRANT SELECT ON sys.v_$pwfile_users TO dv_secanalyst
/

GRANT SELECT ON sys.all_source TO dv_secanalyst
/

GRANT SELECT ON sys.dba_dependencies TO dv_secanalyst
/

GRANT SELECT ON sys.dba_directories TO dv_secanalyst
/

GRANT SELECT ON sys.dba_ts_quotas TO dv_secanalyst
/

GRANT SELECT ON sys.link$ TO dv_secanalyst
/

GRANT SELECT ON sys.v_$parameter TO dv_secanalyst
/

GRANT SELECT ON sys.v_$resource_limit TO dv_secanalyst
/

-- SYSMAN
/*
GRANT SELECT ON sysman.mgmt$db_dbninstanceinfo   TO dv_secanalyst
/
GRANT SELECT ON sysman.em$ecm_composite_os_count TO dv_secanalyst
/
GRANT SELECT ON sysman.em$ecm_host_home_info     TO dv_secanalyst
/
GRANT SELECT ON sysman.ecm$fs_mount_details      TO dv_secanalyst
/
GRANT SELECT ON sysman.ecm$iocard_details        TO dv_secanalyst
/
GRANT SELECT ON sysman.ecm$nic_details           TO dv_secanalyst
/
GRANT SELECT ON sysman.ecm$os_components         TO dv_secanalyst
/
GRANT SELECT ON sysman.ecm$os_patches            TO dv_secanalyst
/
GRANT SELECT ON sysman.ecm$os_properties         TO dv_secanalyst
/
GRANT SELECT ON sysman.ecm$os_registered_sw      TO dv_secanalyst
/
GRANT SELECT ON sysman.ecm$os_summary            TO dv_secanalyst
/
GRANT SELECT ON mgmt$ecm_visible_snapshots       TO dv_secanalyst
/
GRANT SELECT ON mgmt$ecm_current_snapshots       TO dv_secanalyst
/
*/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates roles and grants for DVSYS Owner Administrator role (DV_OWNER)
Rem
Rem
Rem
Rem
Rem

-- give the manager the ability to be the realm owner , 
-- ANY object privs, Role/priv privs, role privs
--GRANT dv_realm_owner TO dv_owner
--/

GRANT GRANT ANY ROLE TO dv_owner
/

GRANT ADMINISTER DATABASE TRIGGER TO dv_owner
/

GRANT ALTER ANY TRIGGER TO dv_owner
/

GRANT EXECUTE ON SYS.DBMS_RLS TO dv_owner
/
