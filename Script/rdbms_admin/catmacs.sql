Rem
Rem Copyright (c) 2004, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catmacs.sql
Rem
Rem    DESCRIPTION
Rem       Creates the Data Vault accounts for DVSYS, DVF
Rem       and grants the basic privileges 
Rem
Rem    NOTES
Rem      Run as SYSDBA
Rem        Parameter 1 = account default TS
Rem        Parameter 2 = account temp TS
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sanbhara    07/05/11 - Bug 12719185 - grant exec on UTL_FILE to DVSYS.
Rem    jsamuel     10/01/08 - simplfy patching
Rem    pknaggs     04/11/08 - bug 6938028: Database Vault protected schema.
Rem    pknaggs     06/20/07 - 6141884: backout fix for bug 5716741.
Rem    pknaggs     05/31/07 - 5716741: sysdba can't do account management.
Rem    ruparame    01/10/07 - DV/DBCA Integration
Rem    rvissapr    12/01/06 - move PLSQL out of catmacs.sql into dvmacfnc.sql
Rem    jciminsk    05/02/06 - cleanup embedded file boilerplate 
Rem    jciminsk    05/02/06 - created admin/catmacs.sql 
Rem    sgaetjen    08/16/05 - Quote installer passwords, remove install accounts
Rem    sgaetjen    08/11/05 - sgaetjen_dvschema
Rem    sgaetjen    08/11/05 - Incorrect parameter placement 
Rem    sgaetjen    08/10/05 - Alter OLS account password 
Rem    sgaetjen    08/03/05 - Correct comments 
Rem    sgaetjen    08/03/05 - add commands to change system accounts using 
Rem                           installed password 
Rem    sgaetjen    08/01/05 - remove lock statement for DVSYS/DVF 
Rem    sgaetjen    07/30/05 - need to unlock account for install 
Rem    sgaetjen    07/28/05 - dos2unix
Rem    sgaetjen    07/25/05 - Created


SET VERIFY OFF

CREATE USER dvsys IDENTIFIED BY "&3"
DEFAULT TABLESPACE &1
TEMPORARY TABLESPACE &2
/

ALTER USER dvsys ACCOUNT UNLOCK
/

CREATE USER dvf IDENTIFIED BY "&3"
DEFAULT TABLESPACE &1
TEMPORARY TABLESPACE &2
/

GRANT CONNECT, RESOURCE TO dvsys
/

GRANT CREATE VIEW TO dvsys
/

Rem The "CREATE ANY TYPE" privilege (KZSXTY) is needed to create the
Rem view ku$_database_vault_realm_view in $SRCHOME/rdbms/admin/catmacc.sql,
Rem required by Datapump for export/import of the Protected Schema metadata.
Rem This privilege will be revoked during $SRCHOME/rdbms/admin/catmach.sql 
Rem (the "hardening" step), as it is no longer needed after the view has 
Rem been created.
GRANT CREATE ANY TYPE TO dvsys
/

GRANT CREATE SYNONYM TO dvsys
/

GRANT CONNECT TO dvf
/

GRANT CREATE PROCEDURE TO dvf
/

SET VERIFY ON
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Grants for Data Vault DVSYS user account
Rem
Rem
Rem
Rem

GRANT CONNECT TO dvsys
/
GRANT RESOURCE TO dvsys
/
GRANT CREATE VIEW TO dvsys
/
GRANT CREATE SYNONYM TO dvsys
/
GRANT CREATE LIBRARY TO dvsys
/
GRANT EXECUTE ON sys.dbms_session TO dvsys
/
GRANT EXECUTE ON sys.dbms_crypto TO dvsys
/
GRANT EXECUTE ON sys.utl_file TO dvsys
/


------------------------- OLS --------------------
-- these OLS grants need to be moved to an alternate script
-- that is selectively run based on configuration

GRANT SELECT ON lbacsys.lbac$pol TO dvsys WITH GRANT OPTION
/
GRANT SELECT ON lbacsys.lbac$polt TO dvsys 
/
GRANT SELECT ON lbacsys.lbac$lab TO dvsys  WITH GRANT OPTION
/
GRANT SELECT ON lbacsys.sa$levels TO dvsys
/
GRANT EXECUTE ON lbacsys.sa_session TO DVSYS
/
GRANT SELECT ON LBACSYS.lbac$props TO DVSYS
/
GRANT EXECUTE ON LBACSYS.ols_init_session TO DVSYS
/

------------------------- VPD -----------------------------------
GRANT EXECUTE ON sys.dbms_rls TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.exu9rls TO dvsys
/

GRANT SELECT ON sys.dba_policies TO dvsys
/

------------------------- SYSMAN --------------------------------
/*
GRANT SELECT ON sysman.mgmt$db_dbninstanceinfo TO dvsys
/
GRANT SELECT ON sysman.em$ecm_composite_os_count TO dvsys
/
GRANT SELECT ON sysman.em$ecm_host_home_info     TO dvsys
/
GRANT SELECT ON sysman.ecm$fs_mount_details      TO dvsys
/
GRANT SELECT ON sysman.ecm$iocard_details        TO dvsys
/
GRANT SELECT ON sysman.ecm$nic_details           TO dvsys
/
GRANT SELECT ON sysman.ecm$os_components         TO dvsys
/
GRANT SELECT ON sysman.ecm$os_patches            TO dvsys
/
GRANT SELECT ON sysman.ecm$os_properties         TO dvsys
/
GRANT SELECT ON sysman.ecm$os_registered_sw      TO dvsys
/
GRANT SELECT ON sysman.ecm$os_summary            TO dvsys
/
GRANT SELECT ON mgmt$ecm_visible_snapshots       TO dvsys
/
GRANT SELECT ON mgmt$ecm_current_snapshots       TO dvsys
/
*/
------------------------- ORACLE SYS SCHEMA  --------------------

GRANT SELECT ON sys.v_$instance TO dvsys
/

GRANT SELECT ON sys.gv_$instance TO dvsys
/

GRANT SELECT ON sys.gv_$session TO dvsys
/

GRANT SELECT ON sys.v_$session TO dvsys
/

GRANT SELECT ON sys.v_$database TO dvsys
/

GRANT SELECT ON sys.v_$parameter TO dvsys
/

GRANT SELECT ON sys.dba_roles TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.dba_role_privs TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.dba_sys_privs  TO dvsys
/

GRANT SELECT ON sys.dba_tab_privs  TO dvsys
/

GRANT SELECT ON sys.dba_synonyms TO dvsys
/

GRANT SELECT ON sys.dba_application_roles TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.proxy_roles TO dvsys  WITH GRANT OPTION
/

GRANT SELECT ON sys.dba_users TO dvsys  WITH GRANT OPTION
/

GRANT SELECT ON sys.dba_objects TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.dba_nested_tables TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.dba_context TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.objauth$ TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.sysauth$ TO dvsys  WITH GRANT OPTION
/

GRANT SELECT ON sys.obj$ TO dvsys  WITH GRANT OPTION
/

GRANT SELECT ON sys.tab$ TO dvsys  WITH GRANT OPTION
/

GRANT SELECT ON sys.user$ TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.table_privilege_map TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.system_privilege_map TO dvsys WITH GRANT OPTION
/

GRANT SELECT ON sys.dba_recyclebin TO dvsys
/

-- required to store MAC Secure and MAC OLS data
GRANT CREATE ANY CONTEXT TO dvsys
/

GRANT DROP ANY CONTEXT TO dvsys
/

-- required to create database triggers
-- we need to protect this by realm
GRANT ADMINISTER DATABASE TRIGGER TO dvsys
/

-- for secure application roles
GRANT CREATE ROLE TO dvsys
/


-- for granting access to DV objects during install
GRANT CREATE PUBLIC SYNONYM TO dvsys
/
GRANT DROP PUBLIC SYNONYM TO dvsys
/

GRANT CREATE ANY PROCEDURE TO dvsys
/


--
--- AQ Privileges for Rules support
--
exec dbms_rule_adm.grant_system_privilege(dbms_rule_adm.CREATE_RULE_SET_OBJ, 'DVSYS', TRUE);
exec dbms_rule_adm.grant_system_privilege(dbms_rule_adm.CREATE_RULE_OBJ, 'DVSYS', TRUE);
exec dbms_rule_adm.grant_system_privilege(dbms_rule_adm.CREATE_EVALUATION_CONTEXT_OBJ, 'DVSYS', TRUE);


GRANT EXECUTE ON SYS.DBMS_REGISTRY TO DVSYS
/

-- add DV to the registry must be done after DVSYS and DVF account are created
-- Register DVF as an ancillary schema
Begin
 DBMS_REGISTRY.LOADING(comp_id     =>  'DV', 
                       comp_name   =>  'Oracle Database Vault', 
                       comp_proc   =>  'VALIDATE_DV', 
                       comp_schema =>  'DVSYS',
                       comp_schemas =>  dbms_registry.schema_list_t('DVF'));
End;
/

-- LRG 2864624 fix
-- Granting Network Access privileges to DVSYS
begin
  begin
     dbms_network_acl_admin.create_acl('dvsys-network-privileges.xml', 'DVSYS Privilege ACL','DVSYS', true,'resolve');
   exception
     when dbms_network_acl_admin.ace_already_exists then 
   null;
  end;  
    dbms_network_acl_admin.assign_acl('dvsys-network-privileges.xml', '*');
end;
/
commit;
