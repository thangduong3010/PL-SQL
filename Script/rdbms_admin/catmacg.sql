Rem Copyright (c) 2004, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      catmacg.sql
Rem    DESCRIPTION
Rem      data vault support script
Rem    NOTES
Rem      Must be compiled after dbms_output package.
Rem      Found on asktom.oracle.com
Rem    MODIFIED (MM/DD/YY)
Rem    apfwkr    09/13/12 - Backport jibyun_bug-14015928 from
Rem    apfwkr    07/02/12 - Backport jibyun_bug-7118790 from main
Rem    sanbhara  06/15/12 - Bug 13781732 - adding grants for
Rem                         dba_dv_patch_admin_audit view.
Rem    jibyun    05/16/12 - Backport jibyun_bug-5918695 from main
Rem    jibyun    05/03/11 - Backport jibyun_bug-12356827 from main
Rem    jibyun    03/02/11 - Backport jibyun_bug-11662436 from main
Rem    jheng     01/24/11 - Backport jheng_bug-7137958 from main
Rem    jheng     02/18/09 - Grant select on dba_dv_job_auth to dv_secanalyst
Rem    clei      12/10/08 - DV_PATCH -> DV_PATCH_ADMIN
Rem    jibyun    05/09/08 - Bug 7550987: Create DV_STREAMS_ADMIN role
Rem    jibyun    10/18/08 - Bug 7489862: Add admin option to the grants of
Rem                         dv_admin, dv_secanalyst, dv_public to dv_owner
Rem    jsamuel   10/28/08 - remove error messages
Rem    ruparame  08/18/08 - Bug 7319691: Create DV_MONITOR role
Rem    clei      08/28/08 - bug 6435192: add dv_patch role
Rem    pknaggs   07/07/08 - bug 6938028: add Factor and Role support for DVPS.
Rem    youyang   05/22/08 - Bug fix:7022650, update dv_secanalyst role to read
Rem                         the dvsys.audit_trail$ table
Rem    pknaggs   04/11/08 - bug 6938028: Database Vault protected schema.
Rem    jibyun    10/31/07 - To fix Bug 6441524
Rem    jciminsk  05/02/06 - cleanup embedded file boilerplate 
Rem    jciminsk  05/02/06 - created admin/catmacg.sql 
Rem    sgaetjen  08/11/05 - sgaetjen_dvschema
Rem    sgaetjen  08/05/05 - Merge into ADE with Protected Schema 
Rem    sgaetjen  07/28/05 - dos2unix
Rem    raustin   01/31/05 - Created spec



CREATE OR REPLACE VIEW DVSYS.dv$out
AS
SELECT ROWNUM lineno, dbms_macout.get_line( ROWNUM ) text
   FROM all_objects
  WHERE ROWNUM < ( SELECT dbms_macout.get_line_count FROM dual );



Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates DV roles 
Rem
Rem
Rem
Rem
Rem

BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_secanalyst';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_monitor';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/

BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_owner';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_acctmgr';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_public';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_patch_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN    
EXECUTE IMMEDIATE 'CREATE ROLE dv_streams_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE; 
     END IF;
END;   
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_goldengate_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_xstream_admin';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_goldengate_redo_access';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/
BEGIN
EXECUTE IMMEDIATE 'CREATE ROLE dv_audit_cleanup';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -1921) THEN NULL; --role already created
     ELSE RAISE;
     END IF;
END;
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Grants to DV_PUBLIC for DVSYS functions
Rem
Rem
Rem
Rem

-- procedures and functions
GRANT EXECUTE ON dvsys.get_factor TO DV_PUBLIC
/
GRANT EXECUTE ON dvsys.get_factor_label TO DV_PUBLIC
/
GRANT EXECUTE ON dvsys.set_factor TO DV_PUBLIC
/
GRANT EXECUTE ON dvsys.get_trust_level TO DV_PUBLIC
/
GRANT EXECUTE ON dvsys.get_trust_level_for_identity TO DV_PUBLIC
/
GRANT EXECUTE ON dvsys.role_is_enabled TO DV_PUBLIC
/
GRANT EXECUTE ON dvsys.predicate_true TO DV_PUBLIC
/
GRANT EXECUTE ON dvsys.is_rls_authorized_by_realm TO DV_PUBLIC
/
GRANT EXECUTE ON dvsys.is_secure_application_role TO DV_PUBLIC
/
-- packages
GRANT EXECUTE ON dvsys.dbms_macsec_roles TO DV_PUBLIC
/
GRANT EXECUTE ON dvsys.dbms_macols_session TO DV_PUBLIC
/

GRANT DV_PUBLIC TO PUBLIC
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates  PUBLIC synonyms for DVSYS objects
Rem
Rem
Rem
Rem

-- packages
CREATE OR REPLACE PUBLIC SYNONYM dbms_macadm FOR dvsys.dbms_macadm
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_macsec_roles FOR dvsys.dbms_macsec_roles
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_macutl FOR dvsys.dbms_macutl
/

-- procedures and functions
CREATE OR REPLACE PUBLIC SYNONYM get_factor FOR dvsys.get_factor
/

CREATE OR REPLACE PUBLIC SYNONYM get_factor_label FOR dvsys.get_factor_label
/

CREATE OR REPLACE PUBLIC SYNONYM set_factor FOR dvsys.set_factor
/

CREATE OR REPLACE PUBLIC SYNONYM get_trust_level FOR dvsys.get_trust_level
/

CREATE OR REPLACE PUBLIC SYNONYM get_trust_level_for_identity FOR dvsys.get_trust_level_for_identity
/

CREATE OR REPLACE PUBLIC SYNONYM role_is_enabled FOR dvsys.role_is_enabled
/

CREATE OR REPLACE PUBLIC SYNONYM is_secure_application_role FOR dvsys.is_secure_application_role
/

-- the statement above will be invalidated by the change in public synonym here
ALTER PACKAGE dvsys.dbms_macols COMPILE BODY
/

ALTER PACKAGE dvsys.dbms_macols_session COMPILE BODY
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Creates roles and grants for DVSYS Administration role (DV_ADMIN)
Rem
Rem
Rem
Rem
Rem

-- give the manager table and view access
GRANT dv_secanalyst TO dv_admin
/

-- packages
-- we only want them to be able to use the API for CRUD
-- the triggers use the rest of these packages
-- the dbms_macsec_roles is granted to public
GRANT EXECUTE ON dvsys.dbms_macadm TO dv_admin
/

GRANT EXECUTE ON dvsys.dbms_macout TO dv_admin
/
GRANT EXECUTE ON dvsys.dbms_macutl TO dv_admin
/
GRANT SELECT ON dvsys.dv$out TO dv_admin
/

-- tables need to remove dep. in UI for views and can remove these
GRANT SELECT ON dvsys.audit_trail$ TO dv_admin;
GRANT SELECT ON dvsys.code$ TO dv_admin;
GRANT SELECT ON dvsys.code_t$ TO dv_admin;
GRANT SELECT ON dvsys.command_rule$ TO dv_admin;
GRANT SELECT ON dvsys.document$ TO dv_admin;
GRANT SELECT ON dvsys.factor$ TO dv_admin;
GRANT SELECT ON dvsys.factor_t$ TO dv_admin;
GRANT SELECT ON dvsys.factor_link$ TO dv_admin;
GRANT SELECT ON dvsys.factor_scope$ TO dv_admin;
GRANT SELECT ON dvsys.factor_type$ TO dv_admin;
GRANT SELECT ON dvsys.factor_type_t$ TO dv_admin;
GRANT SELECT ON dvsys.identity$ TO dv_admin;
GRANT SELECT ON dvsys.identity_map$ TO dv_admin;
GRANT SELECT ON dvsys.mac_policy$ TO dv_admin;
GRANT SELECT ON dvsys.mac_policy_factor$ TO dv_admin;
GRANT SELECT ON dvsys.policy_label$ TO dv_admin;
GRANT SELECT ON dvsys.realm$ TO dv_admin;
GRANT SELECT ON dvsys.realm_t$ TO dv_admin;
GRANT SELECT ON dvsys.realm_auth$ TO dv_admin;
GRANT SELECT ON dvsys.realm_object$ TO dv_admin;
GRANT SELECT ON dvsys.realm_command_rule$ TO dv_admin;
GRANT SELECT ON dvsys.role$ TO dv_admin;
GRANT SELECT ON dvsys.rule$ TO dv_admin;
GRANT SELECT ON dvsys.rule_t$ TO dv_admin;
GRANT SELECT ON dvsys.rule_set$ TO dv_admin;
GRANT SELECT ON dvsys.rule_set_t$ TO dv_admin;
GRANT SELECT ON dvsys.monitor_rule$ TO dv_admin;
GRANT SELECT ON dvsys.monitor_rule_t$ TO dv_admin;
GRANT SELECT ON dvsys.rule_set_rule$ TO dv_admin;
GRANT SELECT ON dvsys.dv_auth$ to dv_admin;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Grants for DV roles (DV_OWNER,DV_SECANALYST) on DV objects
Rem
Rem
Rem
Rem
Rem

-- DV_MONITOR
GRANT SELECT ON dvsys.audit_trail$ TO dv_monitor;
GRANT SELECT ON dvsys.dv$realm_auth TO dv_monitor;
GRANT SELECT ON dvsys.dv$rule_set TO dv_monitor;
GRANT SELECT ON dvsys.dv$rule_set_rule TO dv_monitor;
GRANT SELECT ON dvsys.dv$realm_object TO dv_monitor;
GRANT SELECT ON dvsys.dv$sys_grantee TO dv_monitor;
GRANT SELECT ON dvsys.dv$sys_object_owner TO dv_monitor;
GRANT SELECT ON dvsys.dv$command_rule TO dv_monitor;
GRANT SELECT ON dvsys.dba_dv_code TO dv_monitor;
GRANT SELECT ON dvsys.dba_dv_command_rule TO dv_monitor;
GRANT SELECT ON dvsys.audit_trail$ to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_job_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_datapump_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_patch_admin_audit to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_oradebug to dv_monitor;

-- DV_SECANALYST
GRANT SELECT ON dvsys.dba_dv_job_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_datapump_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_oradebug to dv_secanalyst;
GRANT SELECT ON dvsys.audit_trail$ TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_code TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_command_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_document TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_factor TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_factor_link TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_factor_scope TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_factor_type TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_identity TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_identity_map TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_mac_policy TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_mac_policy_factor TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_monitor_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_policy_label TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_realm TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_realm_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_realm_object TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_realm_command_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_role TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_rule_set TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_rule_set_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_user_privs TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_pub_privs TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_user_privs_all TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$code TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$command_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$document TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$factor TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$factor_link TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$factor_scope TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$factor_type TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$identity TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$identity_map TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$mac_policy TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$mac_policy_factor TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$monitor_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$ols_policy TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$ols_policy_label TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$policy_label TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$realm TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$realm_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$realm_object TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$realm_command_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$role TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$rule_set TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$rule_set_rule TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$sys_grantee TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$sys_object TO dv_secanalyst;
GRANT SELECT ON dvsys.dv$sys_object_owner TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_patch_admin_audit to dv_secanalyst;

-- DV_AUDIT_CLEANUP
GRANT SELECT ON dvsys.audit_trail$ TO dv_audit_cleanup;
GRANT DELETE ON dvsys.audit_trail$ TO dv_audit_cleanup;

-- DV_OWNER
-- give the manager table and view access and execute privs that the DV administrator role has
GRANT dv_admin TO dv_owner with admin option;
GRANT dv_patch_admin to dv_owner with admin option;
GRANT dv_streams_admin to dv_owner with admin option;
GRANT dv_secanalyst TO dv_owner with admin option;
GRANT dv_public TO dv_owner with admin option;
GRANT dv_monitor to dv_owner with admin option;
GRANT dv_goldengate_admin to dv_owner with admin option;
GRANT dv_xstream_admin to dv_owner with admin option;
GRANT dv_goldengate_redo_access to dv_owner with admin option;
GRANT dv_audit_cleanup to dv_owner with admin option;

-- The SELECT privilege on the Datapump views needs to be granted 
-- to the dv_owner, for macsys to be able to use Datapump to export 
-- the Protected Schema.
--
grant SELECT on dvsys.ku$_dv_realm_view           to dv_owner;
grant SELECT on dvsys.ku$_dv_realm_member_view    to dv_owner;
grant SELECT on dvsys.ku$_dv_realm_auth_view      to dv_owner;
grant SELECT on dvsys.ku$_dv_isr_view             to dv_owner;
grant SELECT on dvsys.ku$_dv_isrm_view            to dv_owner;
grant SELECT on dvsys.ku$_dv_rule_view            to dv_owner;
grant SELECT on dvsys.ku$_dv_rule_set_view        to dv_owner;
grant SELECT on dvsys.ku$_dv_rule_set_member_view to dv_owner;
grant SELECT on dvsys.ku$_dv_command_rule_view    to dv_owner;
grant SELECT on dvsys.ku$_dv_role_view            to dv_owner;
grant SELECT on dvsys.ku$_dv_factor_view          to dv_owner;
grant SELECT on dvsys.ku$_dv_factor_link_view     to dv_owner;
grant SELECT on dvsys.ku$_dv_factor_type_view     to dv_owner;
grant SELECT on dvsys.ku$_dv_identity_view        to dv_owner;
grant SELECT on dvsys.ku$_dv_identity_map_view    to dv_owner;

-- As Streams APIs (MAINTAIN_*) use Datapump during instantiation,
-- DV_STREAMS_ADMIN need to have access to these views.
grant SELECT on dvsys.ku$_dv_realm_view           to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_realm_member_view    to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_realm_auth_view      to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_isr_view             to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_isrm_view            to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_rule_view            to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_rule_set_view        to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_rule_set_member_view to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_command_rule_view    to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_role_view            to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_factor_view          to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_factor_link_view     to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_factor_type_view     to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_identity_view        to dv_streams_admin;
grant SELECT on dvsys.ku$_dv_identity_map_view    to dv_streams_admin;
