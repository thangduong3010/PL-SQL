Rem
Rem $Header: rdbms/admin/dvu111.sql /st_rdbms_11.2.0/1 2012/07/18 17:06:48 jibyun Exp $
Rem
Rem dvu111.sql
Rem
Rem Copyright (c) 2008, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dvu111.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jibyun      07/17/12 - Backport apfwkr_blr_backport_13962309_11.2.0.3.0
Rem                           from st_rdbms_11.2.0
Rem    jheng       05/13/09 - grant SYS job authorization on EXFSYS schema
Rem    ruparame    03/30/09 - Bug 8393717 Change the datapump rule set name to
Rem                           Allow Oracle Data Pump Operation
Rem    youyang     03/27/09 - Bug 8385541: to qualify session_roles
Rem    youyang     02/16/09 - Bug8212399: ignore unique constraint error
Rem    jheng       02/17/09 - add DV Job rule set
Rem    ruparame    02/05/09 - Bug 8211922 remove sync_rules
Rem    ruparame    01/20/09 - LRG 3772496
Rem    prramakr    01/15/09 - Bug7711393: create dvlang function and related
Rem                           views
Rem    srtata      12/29/08 - add ruleset view: static ruleset implmentation
Rem    jibyun      12/22/08 - Bug 7656640: Add DV_STREAMS_ADMIN role to
Rem                           Database Vault after creation
Rem    youyang     11/14/08 - remove DDL triggers and set owners of roles to "%"
Rem    clei        12/10/08 - DV_PATCH -> DV_PATCH_ADMIN
Rem    jibyun      10/23/08 - Bug 7550987: Add dv_streams_admin role
Rem    jibyun      10/20/08 - Bug 7489862: Add admin option to the grants of
Rem                           dv_admin, dv_secanalyst, and dv_public to
Rem                           dv_owner
Rem    ssonawan    10/14/08 - bug 6938843: Add rules for alter system command
Rem    jheng       10/06/08 - remove default command rules "GRANT" & "REVOKE"
Rem    ruparame    08/25/08 - Bug 7319691: Create DV_MONITOR role
Rem    clei        08/20/08 - bug 6435192: add DVSYS.CONFIG$ and dv_patch
Rem    pknaggs     07/29/08 - bug 6938028: Database Vault Protected Schema.
Rem    vigaur      04/16/08 - Created
Rem

Rem Please add any metadata upgrade changes below this point.
Rem Note: remember to alter the session to set the current schema 
Rem correctly, before adding any SQL commands.

ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

CREATE OR REPLACE LIBRARY DVSYS.KZV$RSRC_LIBT TRUSTED AS STATIC;
/

Rem Create table to store DV enforcement status

BEGIN
EXECUTE IMMEDIATE 'create table dvsys.config$ (status number unique)';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --object has already been created
     ELSE RAISE;
     END IF;

END;
/

DECLARE
NUM NUMBER;

BEGIN
SELECT COUNT(*) INTO NUM FROM DVSYS.CONFIG$;
IF NUM = 0 THEN
EXECUTE IMMEDIATE 'insert into dvsys.config$ (status) values (1)';
 END IF;
  EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

Rem create table to store DV Job Authrization metadata

CREATE TABLE DVSYS.DV_AUTH$
(
  GRANT_TYPE  VARCHAR2 (19) NOT NULL,
  GRANTEE VARCHAR2 (30) NOT NULL,
  OBJECT_OWNER VARCHAR2 (30),
  OBJECT_NAME VARCHAR2 (128),
  OBJECT_TYPE VARCHAR2 (19)
);

CREATE OR REPLACE VIEW DVSYS.dba_dv_job_auth
(
      grantee
    , schema
)
AS SELECT
    grantee
  , object_owner
FROM dvsys.dv_auth$
WHERE grant_type = 'JOB'
/

Rem Create DV_PATCH_ADMIN role
create role dv_patch_admin;
grant dv_patch_admin to dv_owner with admin option;

Rem Create DV_STREAMS_ADMIN role
create role dv_streams_admin;
grant dv_streams_admin to dv_owner with admin option;

Rem Grant dv_patch_admin to sys so it can access DV protected seeded schema
Rem for post upgrade actions. DV_OWNR should revoke this after migration.
grant dv_patch_admin to sys;

Rem Add DV_PATCH_ADMIN to realm_object$
BEGIN
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,object_name,object_type,version,created_by,create_date,updated_by,update_date)
 VALUES(65,2,'DVSYS','DV_PATCH_ADMIN','ROLE',1,USER,SYSDATE,USER,SYSDATE);
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
    ELSE RAISE;
    END IF;
END;
/

commit;

-- Bug 7489862
grant dv_admin to dv_owner with admin option;
grant dv_secanalyst to dv_owner with admin option;
grant dv_public to dv_owner with admin option;

---------------------------------------------------------------------------
-- The following are required for the DV_MONITOR 
-- This role is introduced in 11g for DV monitoring by the DBSNMP user
-- As part of DV Grid control.
---------------------------------------------------------------------------

Rem Create the view for DV_MONITOR grantees

create or replace view DVSYS.DV_MONITOR_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_MONITOR'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys.user$ where name = upper(grantee)),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_MONITOR'));
/

CREATE ROLE dv_monitor
/

Rem Grant the appropriate privileges to the DV_MONITOR role

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
GRANT SELECT ON dvsys.dba_dv_job_auth to dv_monitor;

Rem Grant the privilege to dv_secanalyst
GRANT SELECT ON dvsys.dba_dv_job_auth TO dv_secanalyst;

Rem Grant the privilege to dv_admin
GRANT SELECT ON dvsys.dv_auth$ to dv_admin;

Rem Grant the DV_MONITOR role to DBSNMP 

GRANT DV_MONITOR to DBSNMP;

Rem Grant the DV_MONITOR role to DV_OWNER

GRANT DV_MONITOR to DV_OWNER with admin option;

Rem Protect the DV_MONITOR role under the 'Oracle Database Vault' Realm 
Rem with hard-coded ID# 2

BEGIN
 INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,object_name,object_type,version,created_by,create_date,updated_by,update_date)
 VALUES(66,2,'DVSYS','DV_MONITOR','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

commit;

-- End of DV_MONITOR-related upgrade steps 
-------------------------------------------------------------------

Rem Bug 7656640: Add DV_STREAMS_ADMIN role to 'Oracle Database Vault' realm

BEGIN
  INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,object_name,object_type,version,created_by,create_date,updated_by,update_date)
 VALUES(67,2,'DVSYS','DV_STREAMS_ADMIN','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

commit;

------------------------------------------------------------------
-- Drop before and after DDL triggers.
------------------------------------------------------------------
drop trigger dvsys.dv_before_ddl_trg;
drop trigger dvsys.dv_after_ddl_trg;

------------------------------------------------------------------
-- Update roles' owners to % (not a wildcard) if they are protected in realm.
-- Roles do not have owners.
------------------------------------------------------------------
update DVSYS.realm_object$
set owner = '%'
where object_type = 'ROLE';

----------------------------------------------------------------------
-- Drop stand-alone procedures removed after DDL DV code is moved to C
----------------------------------------------------------------------
drop procedure dvsys.authorize_event;

------------------------------------------------------------------------------
-- bug 6938028: Database Vault Protected Schema.
------------------------------------------------------------------------------
-- UDT and object-view for the 'DVPS_IMPORT_STAGING_REALM' homogeneous type
-- (xmltag: 'DVPS_IMPORT_STAGING_REALM_T', XSLT: rdbms/xml/xsl/kudvsta.xsl),
-- as well as for the 'DVPS_DROP_IMPORT_STAGING_REALM' homogeneous type 
-- (xmltag: 'DVPS_DISR_T', XSLT: rdbms/xml/xsl/kudvstad.xsl).
create or replace type ku$_dv_isr_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1)                              /* UDT minor version # */
)
/

-- The ku$_dv_isr_view contains one row if any Database Vault
-- Realm-protected schema exists in the database, i.e. if any schema has
-- been passed as the object_owner in a call to ADD_OBJECT_TO_REALM.
-- The REALM_ID# sequence starts at 5000, so Realms with REALM_ID# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with realm_id# 5000 is a
-- "seeded" Realm, created by the Database Vault installation, and
-- should not be exported.
create or replace force view ku$_dv_isr_view
       of ku$_dv_isr_t
  with object identifier (vers_major) as
  select '0','0'
    from dual
   where (sys_context('USERENV','CURRENT_USERID') = 1279990
          or exists (select 1
                       from sys.session_roles
                      where role='DV_OWNER'))
     and exists (select 1
                   from dvsys.realm_object$ objects_in_realm
                  where objects_in_realm.REALM_ID# > 5000)
/

show errors;

-- UDT and object-view for 'DVPS_STAGING_REALM_MEMBERSHIP' homogeneous type,
-- (xmltag: 'DVPS_STAGING_REALM_MEMBERSHP_T', XSLT rdbms/xml/xsl/kudvstam.xsl)
-- corresponding to xmltag 'DVPS_STAGING_REALM_MEMBERSHP_T'.
create or replace type ku$_dv_isrm_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  schema_name   varchar2(30)     /* schema to be protected by Staging Realm */
)
/

-- The ku$_dv_isrm_view lists all of the schema names which have 
-- been passed as the object_owner in a call to ADD_OBJECT_TO_REALM.
-- These schemas will be added to a new Realm created as the first step
-- of Full Database Import with the name 'Datapump Import Staging 
-- Realm for Database Vault', using a wildcard for both object_name and 
-- object_type, so that any imported objects in these schemas 
-- will automatically be protected.
-- The REALM_ID# sequence starts at 5000, so Realms with REALM_ID# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with realm_id# 5000 is a
-- "seeded" Realm, created by the Database Vault installation, and
-- should not be exported.
create or replace force view ku$_dv_isrm_view
       of ku$_dv_isrm_t
  with object identifier (schema_name) as
  select '0','0',
         realm_objects.object_owner
    from (select distinct(objects_in_realm.owner) object_owner
            from dvsys.realm_object$ objects_in_realm
           where objects_in_realm.REALM_ID# > 5000) realm_objects
   where (sys_context('USERENV','CURRENT_USERID') = 1279990
          or exists (select 1 
                       from sys.session_roles
                      where role='DV_OWNER'))
/

show errors;

-- UDT and object-view for the 'DVPS_REALM' homogeneous type.
-- (xmltag: 'DVPS_REALM_T', XSLT: rdbms/xml/xsl/kudvrlm.xsl),
-- representing Database Vault Realms created using CREATE_REALM.
create or replace type ku$_dv_realm_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(90),               /* name of database vault realm */
  description   varchar2(1024),      /* description of database vault realm */
  language      varchar2(3),               /* language of realm description */
  enabled       varchar2(1),       /* enabled state of database vault realm */
  audit_options varchar2(78)       /* audit options of database vault realm */
)
/

-- The realm$.id# sequence starts at 5000, so Realms with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with id# 5000 is a "seeded" Realm, 
-- (created by the Database Vault installation), and should not be exported.
create or replace force view ku$_dv_realm_view
       of ku$_dv_realm_t
  with object identifier (name) as
  select '0','0',
          rlmt.name,
          rlmt.description,
          rlmt.language,
          rlm.enabled,
          decode(rlm.audit_options,
                 0,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_OFF',
                 1,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_FAIL',
                 2,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_SUCCESS',
                 3,'(DVSYS.DBMS_MACUTL.G_REALM_AUDIT_SUCCESS+'||
                    'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_FAIL)',
                 to_char(rlm.audit_options))
  from    dvsys.realm$        rlm,
          dvsys.realm_t$      rlmt
  where   rlm.id# = rlmt.id#
    and   rlm.id# > 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for the 'DVPS_REALM_MEMBERSHIP' homogeneous type,
-- (xmltag: 'DVPS_REALM_MEMBERSHIP_T', XSLT: rdbms/xml/xsl/kudvrlmm.xsl),
-- representing realm protections created using ADD_OBJECT_TO_REALM.
create or replace type ku$_dv_realm_member_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  name          varchar2(90),               /* name of database vault realm */
  object_owner  varchar2(30),    /* owner of object protected by this realm */
  object_name   varchar2(128),    /* name of object protected by this realm */
  object_type   varchar2(19)      /* type of object protected by this realm */
)
/

-- The realm$.id# sequence starts at 5000, so Realms with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with id# 5000 is a "seeded" Realm, 
-- (created by the Database Vault installation), and should not be exported.
create or replace force view ku$_dv_realm_member_view
       of ku$_dv_realm_member_t
  with object identifier (object_name, name) as
  select '0','0',
          rlmt.name,
          rlmo.owner,
          rlmo.object_name,
          rlmo.object_type
  from    dvsys.realm$        rlm,
          dvsys.realm_t$      rlmt,
          dvsys.realm_object$ rlmo
  where   rlm.id# = rlmt.id#
    and   rlmo.realm_id# = rlm.id#
    and   rlm.id# > 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_REALM_AUTHORIZATION' homogeneous type
-- (xmltag: 'DVPS_REALM_AUTHORIZATION_T', XSLT: rdbms/xml/xsl/kudvrlma.xsl),
-- representing Realm participants/owners added using ADD_AUTH_TO_REALM.
create or replace type ku$_dv_realm_auth_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  realm_name    varchar2(90),               /* name of database vault realm */
  grantee       varchar2(30),         /* owner of (or participant in) realm */
  rule_set_name varchar2(90),      /* rule set used to authorize (optional) */
  auth_options  varchar2(42)        /* authorization (participant or owner) */
)
/

-- The realm$.id# sequence starts at 5000, so Realms with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. The Realm with id# 5000 is a "seeded" Realm, 
-- (created by the Database Vault installation), and should not be exported.
create or replace force view ku$_dv_realm_auth_view
       of ku$_dv_realm_auth_t
  with object identifier (realm_name, grantee) as
  select '0','0',
          rlmt.name,
          rlma.grantee,
          rs.name,
          decode(rlma.auth_options,
                 0,'DVSYS.DBMS_MACUTL.G_REALM_AUTH_PARTICIPANT',
                 1,'DVSYS.DBMS_MACUTL.G_REALM_AUTH_OWNER',
                 to_char(rlma.auth_options))
  from    dvsys.realm$                   rlm,
          dvsys.realm_t$                 rlmt,
          dvsys.realm_auth$              rlma,
          (select m.id#,
                  d.name
             from dvsys.rule_set$   m,
                  dvsys.rule_set_t$ d
            where m.id# = d.id#)         rs
  where   rlm.id# = rlma.realm_id#
    and   rlm.id# = rlmt.id#
    and   rs.id# (+)= rlma.auth_rule_set_id#
    and   rlm.id# > 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_RULE' homogeneous type
-- (xmltag: 'DVPS_RULE_T', XSLT: rdbms/xml/xsl/kudvrul.xsl),
-- representing Rules added using CREATE_RULE.
-- This object-view is similar to the DVSYS.dv$rule view.
create or replace type ku$_dv_rule_t as object
(
  vers_major    char(1),                             /* UDT major version # */
  vers_minor    char(1),                             /* UDT minor version # */
  rule_name     varchar2(90),                               /* name of Rule */
  rule_expr     varchar2(1024),       /* PL/SQL boolean expression for Rule */
  language      varchar2(3)                        /* language of Rule name */
)
/

-- The rule$.id# sequence starts at 5000, so Rules with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported.
-- In addition, Rules which are members of the Rule Set with the name
-- 'Allow Oracle Data Pump Operation' (which has a rule_set_id# of 8) 
-- should not be exported, as they are system-managed Rules created 
-- by means of the dbms_macadm.authorize_datapump_user API.
-- Similar to 'Allow Datapump Operation' rules, add DV Job scheduler user rules.
create or replace force view ku$_dv_rule_view
       of ku$_dv_rule_t
  with object identifier (rule_name) as
  select '0','0',
          rult.name,
          rul.rule_expr,
          rult.language
  from    dvsys.rule$                   rul,
          dvsys.rule_t$                 rult
  where   rul.id# = rult.id#
    and   rul.id# >= 5000
    and   rul.id# not in (select rule_id#
                            from dvsys.rule_set_rule$
                           where rule_set_id# in (8, 10))
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_RULE_SET' homogeneous type
-- (xmltag: 'DVPS_RULE_SET_T', XSLT: rdbms/xml/xsl/kudvruls.xsl),
-- representing Rule Sets added using CREATE_RULE_SET.
-- This object-view is similar to the DVSYS.dba_dv_rule_set view.
create or replace type ku$_dv_rule_set_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  rule_set_name   varchar2(90),                         /* name of Rule Set */
  description     varchar2(1024),                /* description of Rule Set */
  language        varchar2(3),          /* language of Rule Set description */
  enabled         varchar2(1),      /* the Rule Set is enabled ('Y' or 'N') */
  eval_options    varchar2(36),                 /* evaluate all or any Rule */
  audit_options   varchar2(78),  /* auditing: off, on failure or on success */
  fail_options    varchar2(39),    /* show an error message, or stay silent */
  fail_message    varchar2(80),      /* error message to display on failure */
  fail_code       varchar2(10),   /* code to associate with failure message */
  handler_options varchar2(43),  /* error handler: off, on fail, on success */
  handler         varchar2(1024) /* PL/SQL routine for custom event handler */
)
/

-- The rule_set$.id# sequence starts at 5000, so Rule Sets with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. 
create or replace force view ku$_dv_rule_set_view
       of ku$_dv_rule_set_t
  with object identifier (rule_set_name) as
  select '0','0',
          rulst.name,
          rulst.description,
          rulst.language,
          ruls.enabled,
          decode(ruls.eval_options,
                 1,'DVSYS.DBMS_MACUTL.G_RULESET_EVAL_ALL',
                 2,'DVSYS.DBMS_MACUTL.G_RULESET_EVAL_ANY',
                 to_char(ruls.eval_options)),
          decode(ruls.audit_options,
                 0,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_OFF',
                 1,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_FAIL',
                 2,'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_SUCCESS',
                 3,'(DVSYS.DBMS_MACUTL.G_REALM_AUDIT_SUCCESS+'||
                    'DVSYS.DBMS_MACUTL.G_REALM_AUDIT_FAIL)',
                 to_char(ruls.audit_options)),
          decode(ruls.fail_options,
                 1,'DVSYS.DBMS_MACUTL.G_RULESET_FAIL_SHOW',
                 2,'DVSYS.DBMS_MACUTL.G_RULESET_FAIL_SILENT',
                 to_char(ruls.fail_options)),
          rulst.fail_message,
          ruls.fail_code,
          decode(ruls.handler_options,
                 0,'DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_OFF',
                 1,'DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_FAIL',
                 2,'DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_SUCCESS',
                 3,'(DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_FAIL+'||
                    'DVSYS.DBMS_MACUTL.G_RULESET_HANDLER_SUCCESS)',
                 to_char(ruls.handler_options)),
          ruls.handler
  from    dvsys.rule_set$               ruls,
          dvsys.rule_set_t$             rulst
  where   ruls.id# = rulst.id#
    and   ruls.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1 
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_RULE_SET_MEMBERSHIP' homogeneous type
-- (xmltag: 'DVPS_RULE_SET_MEMBERSHIP_T', XSLT: rdbms/xml/xsl/kudvrsm.xsl),
-- representing the Rules added to a Rule Set using ADD_RULE_TO_RULE_SET.
-- This object-view is similar to the DVSYS.dba_dv_rule_set_rule view.
create or replace type ku$_dv_rule_set_member_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  rule_set_name   varchar2(90),                         /* name of Rule Set */
  rule_name       varchar2(90),                             /* name of Rule */
  rule_order      number,                         /* unused in this release */
  enabled         varchar2(1)       /* the Rule Set is enabled ('Y' or 'N') */
)
/

-- The rule_set$.id# sequence starts at 5000, so Rule Sets with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported. 
create or replace force view ku$_dv_rule_set_member_view
       of ku$_dv_rule_set_member_t
  with object identifier (rule_set_name,rule_name) as
  select '0','0',
          rulst.name,
          rult.name,
          rsr.rule_order, 
          rsr.enabled
  from    dvsys.rule_set_rule$          rsr,
          dvsys.rule_set$               ruls,
          dvsys.rule_set_t$             rulst,
          dvsys.rule$                   rul,
          dvsys.rule_t$                 rult
  where   ruls.id# = rsr.rule_set_id#
    and   ruls.id# = rulst.id#
    and    rul.id# = rsr.rule_id#
    and    rul.id# = rult.id#
    and   ruls.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_COMMAND_RULE' homogeneous type
-- (xmltag: 'DVPS_COMMAND_RULE_T', XSLT: rdbms/xml/xsl/kudvcr.xsl),
-- representing the Command Rules created using CREATE_COMMAND_RULE.
-- This object-view selects directly from the DVSYS.dv$command_rule view.
create or replace type ku$_dv_command_rule_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  command         varchar2(30),                 /* SQL statement to protect */
  rule_set_name   varchar2(90),                         /* name of Rule Set */
  object_owner    varchar2(30),                             /* schema owner */
  object_name     varchar2(128),       /* object name (may be wildcard '%') */
  enabled         varchar2(1)   /* the Command Rule is enabled ('Y' or 'N') */
)
/

-- The command_rule$.id# sequence starts at 5000, so Command Rules with id# 
-- less than 5000 are reserved for internal use by Database Vault,
-- and should not be exported.
create or replace force view ku$_dv_command_rule_view
       of ku$_dv_command_rule_t
  with object identifier (rule_set_name) as
  select '0','0',
          command,
          rule_set_name,
          object_owner, 
          object_name,
          enabled
  from    dvsys.dv$command_rule         cvcr
  where   cvcr.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990
           or exists ( select 1
                         from sys.session_roles
                        where role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_ROLE' homogeneous type
-- (xmltag: 'DVPS_ROLE_T', XSLT: rdbms/xml/xsl/kudvrol.xsl),
-- representing the Roles created using CREATE_ROLE.
-- This object-view is based on the DVSYS.dba_dv_role view.
create or replace type ku$_dv_role_t as object
(
  vers_major         char(1),                        /* UDT major version # */
  vers_minor         char(1),                        /* UDT minor version # */
  role               varchar2(30),                             /* Role name */
  enabled            varchar2(1),                      /* Enabled? (Y or N) */
  rule_set_name      varchar2(90)                          /* Rule Set name */
)
/

-- The dvsys.role$_seq sequence for role$.id# starts at 5000,
-- so Roles with id# less than 5000 are reserved for internal use
-- by Database Vault, and should not be exported.
create or replace force view ku$_dv_role_view
       of ku$_dv_role_t
  with object identifier (role) as
  select '0','0',
         roles.role,
         roles.enabled,
         rulst.name
    from dvsys.role$         roles,
         dvsys.rule_set$     ruls,
         dvsys.rule_set_t$   rulst
   where roles.rule_set_id# = ruls.id#
     and ruls.id# = rulst.id#
     and roles.id# >= 5000
     and (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
          EXISTS ( SELECT * FROM sys.session_roles
                   WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_FACTOR' homogeneous type
-- (xmltag: 'DVPS_FACTOR_T', XSLT: rdbms/xml/xsl/kudvf.xsl),
-- representing the Factors created using CREATE_FACTOR.
-- This object-view is based on the DVSYS.dba_dv_factor view.
create or replace type ku$_dv_factor_t as object
(
  vers_major         char(1),                        /* UDT major version # */
  vers_minor         char(1),                        /* UDT minor version # */
  factor_name        varchar2(30),                           /* Factor name */
  factor_type_name   varchar2(90),                      /* Factor Type name */
  description        varchar2(4000),                         /* Description */
  language           varchar2(3),         /* language of Factor description */
  rule_set_name      varchar2(90),                         /* Rule Set name */
  get_expr           varchar2(1024),                      /* Get expression */
  validate_expr      varchar2(1024),                 /* Validate expression */
  identify_by        varchar2(40),                           /* Identify by */
  labeled_by         varchar2(40),                            /* Labeled by */
  eval_options       varchar2(40),                          /* Eval options */
  audit_options      varchar2(400),                        /* Audit options */
  fail_options       varchar2(37)                           /* Fail options */
)
/

-- The dvsys.factor$_seq sequence for factor$.id# starts at 5000,
-- so Factors with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
-- The use of substr removes the initial " || " from the audit_options string.
create or replace force view ku$_dv_factor_view
       of ku$_dv_factor_t
  with object identifier (factor_name) as
  select '0','0',
         m.name,
         dft.name,
         d.description,
         d.language,
         drs.name,
         m.get_expr,
         m.validate_expr,
         decode(m.identified_by,
                 0,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_CONSTANT', 
                 1,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_METHOD',
                 2,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_FACTOR',
                 3,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_CONTEXT',
                 4,'DVSYS.DBMS_MACUTL.G_IDENTIFY_BY_RULESET',
                 to_char(m.identified_by)),
         decode(m.labeled_by,
                 0,'DVSYS.DBMS_MACUTL.G_LABELED_BY_SELF', 
                 1,'DVSYS.DBMS_MACUTL.G_LABELED_BY_FACTORS',
                 to_char(m.labeled_by)),
         decode(m.eval_options,
                 0,'DVSYS.DBMS_MACUTL.G_EVAL_ON_SESSION', 
                 1,'DVSYS.DBMS_MACUTL.G_EVAL_ON_ACCESS',
                 2,'DVSYS.DBMS_MACUTL.G_EVAL_ON_STARTUP',
                 to_char(m.eval_options)),
         decode(m.audit_options,
                0,'DVSYS.DBMS_MACUTL.G_AUDIT_OFF', 
                substr(
                  decode(bitand(m.audit_options,power(2,0)),
                        power(2,0),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ALWAYS',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,1)),
                        power(2,1),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_GET_ERROR',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,2)),
                        power(2,2),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_GET_NULL',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,3)),
                        power(2,3),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_VALIDATE_ERROR',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,4)),
                        power(2,4),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_VALIDATE_FALSE',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,5)),
                        power(2,5),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_TRUST_LEVEL_NULL',
                        0,'') ||
                  decode(bitand(m.audit_options,power(2,6)),
                        power(2,6),
                          ' || DVSYS.DBMS_MACUTL.G_AUDIT_ON_TRUST_LEVEL_NEG',
                        0,''), 5)),
         decode(m.fail_options,
                 1,'DVSYS.DBMS_MACUTL.G_FAIL_WITH_MESSAGE', 
                 2,'DVSYS.DBMS_MACUTL.G_FAIL_SILENTLY',
                 to_char(m.fail_options))
   from dvsys.factor$         m,
        dvsys.factor_t$       d,
        dvsys.factor_type_t$  dft,
        dvsys.rule_set_t$     drs
  where m.id# = d.id#
    and dft.id# = m.factor_type_id#
    and drs.id#  (+)= m.assign_rule_set_id#
    and m.id# >= 5000
    and (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
         EXISTS ( SELECT * FROM sys.session_roles
                  WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_FACTOR_LINK' homogeneous type
-- (xmltag: 'DVPS_FACTOR_LINK_T', XSLT: rdbms/xml/xsl/kudvfl.xsl),
-- representing the Factor Links created using ADD_FACTOR_LINK.
-- This object-view is based on the DVSYS.dba_dv_factor_link view.
create or replace type ku$_dv_factor_link_t as object
(
  vers_major         char(1),                        /* UDT major version # */
  vers_minor         char(1),                        /* UDT minor version # */
  parent_factor_name varchar2(30),                    /* Parent Factor name */
  child_factor_name  varchar2(30),                     /* Child Factor name */
  label_indicator    varchar2(1) /* Contributes to label of parent (Y or N) */
)
/

-- The dvsys.factor_link$_seq sequence for factor_link$.id# starts at 5000,
-- so Factor Links with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
create or replace force view ku$_dv_factor_link_view
       of ku$_dv_factor_link_t
  with object identifier (parent_factor_name) as
  select '0','0',
          d1.name,
          d2.name,
          m.label_ind
  from    dvsys.factor_link$   m,
          dvsys.factor$        d1,
          dvsys.factor$        d2
  where   d1.id# = m.parent_factor_id#
    and   d2.id# = m.child_factor_id#
    and   m.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
           EXISTS ( SELECT * FROM sys.session_roles
                    WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_FACTOR_TYPE' homogeneous type
-- (xmltag: 'DVPS_FACTOR_TYPE_T', XSLT: rdbms/xml/xsl/kudvft.xsl),
-- representing the Factor Types created using CREATE_FACTOR_TYPE.
-- This object-view is based on the DVSYS.dba_dv_factor_type view.
create or replace type ku$_dv_factor_type_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  name            varchar2(90),                         /* Factor type name */
  description     varchar2(1024),  /* Description of purpose of Factor type */
  language        varchar2(3)        /* language of Factor type description */
)
/

-- The dvsys.factor_type$_seq sequence for factor_type$.id# starts at 5000,
-- so Factor Types with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
create or replace force view ku$_dv_factor_type_view
       of ku$_dv_factor_type_t
  with object identifier (name) as
  select '0','0',
          factt.name,
          factt.description,
          factt.language
  from    dvsys.factor_type$            fact,
          dvsys.factor_type_t$          factt
  where   fact.id# = factt.id#
    and   fact.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
           EXISTS ( SELECT * FROM sys.session_roles
                    WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_IDENTITY' homogeneous type
-- (xmltag: 'DVPS_IDENTITY_T', XSLT: rdbms/xml/xsl/kudvid.xsl),
-- representing the Identities created using CREATE_IDENTITY.
-- This object-view is based on the DVSYS.dba_dv_identity view.
create or replace type ku$_dv_identity_t as object
(
  vers_major      char(1),                           /* UDT major version # */
  vers_minor      char(1),                           /* UDT minor version # */
  factor_name     varchar2(30),                         /* Factor type name */
  value           varchar2(1024),  /* Description of purpose of Factor type */
  trust_level     number    /* Trust, relative to other ids for same Factor */
)
/

-- The dvsys.dvsys.identity$_seq sequence for identity$.id# starts at 5000,
-- so Identities  with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
create or replace force view ku$_dv_identity_view
       of ku$_dv_identity_t
  with object identifier (factor_name) as
  select '0','0',
          fac.name,
          iden.value,
          iden.trust_level
  from    dvsys.factor$                 fac,
          dvsys.identity$               iden
  where   fac.id# = iden.factor_id#
    and   fac.id# >= 5000
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
           EXISTS ( SELECT * FROM sys.session_roles
                    WHERE role='DV_OWNER' ))
/

show errors;

-- UDT and object-view for 'DVPS_IDENTITY_MAP' homogeneous type
-- (xmltag: 'DVPS_IDENTITY_MAP_T', XSLT: rdbms/xml/xsl/kudvidm.xsl),
-- representing the Identity Maps created using CREATE_IDENTITY_MAP.
-- This object-view is based on the DVSYS.dba_dv_identity_map view.
create or replace type ku$_dv_identity_map_t as object
(
  vers_major               char(1),                  /* UDT major version # */
  vers_minor               char(1),                  /* UDT minor version # */
  identity_factor_name     varchar2(30),           /* Factor the map is for */
  identity_factor_value    varchar2(1024),     /* Value the map will assume */
  parent_factor_name       varchar2(30),              /* parent Factor link */
  child_factor_name        varchar2(30),               /* child Factor link */
  operation                varchar2(30),             /* relational operator */
  operand1                 varchar2(30),                    /* left operand */
  operand2                 varchar2(30)                    /* right operand */
)
/

-- The dvsys.identity_map$_seq sequence for identity_map$.id# starts at 5000,
-- so Identity Maps  with id# less than 5000 are reserved for internal use 
-- by Database Vault, and should not be exported.
create or replace force view ku$_dv_identity_map_view
       of ku$_dv_identity_map_t
  with object identifier (identity_factor_name) as
  select '0','0',
          d6.name,
          d1.value,
          d4.name,
          d5.name,
          d2.code,
          m.operand1,
          m.operand2
  from    dvsys.identity_map$           m,
          dvsys.identity$               d1,
          dvsys.code$                   d2,
          dvsys.factor_link$            d3,
          dvsys.factor$                 d4,
          dvsys.factor$                 d5,
          dvsys.factor$                 d6
  where   d1.id# = m.identity_id#
    and   m.id# >= 5000
    and   d2.id# = m.operation_code_id#
    and   d2.code_group = 'OPERATORS'
    and   d3.id# (+)= m.factor_link_id#
    and   d4.id# (+)= d3.parent_factor_id#
    and   d5.id# (+)= d3.child_factor_id#
    and   d6.id# = d1.factor_id#
    and   (SYS_CONTEXT('USERENV','CURRENT_USERID') = 1279990 OR
           EXISTS ( SELECT * FROM sys.session_roles
                    WHERE role='DV_OWNER' ))
/

show errors;

------------------------------------------------------------------------------
-- bug 6938028: Database Vault Protected Schema.
-- The SELECT privilege on the Data Pump views needs to be granted
-- to the dv_owner, for macsys to be able to use Data Pump to export
-- the Protected Schema.
------------------------------------------------------------------------------
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

-- As some Streams APIs depend on Data Pump operations,
-- DV_STREAMS_ADMIN need to have access to thees views as well.
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

-- Create the seeded Rule Set "Allow Oracle Data Pump Operation", and the 
-- seeded Rule "False" which is a member of that Rule Set: the following 
-- inserts correspond to the changes made as part of txn 
-- ruparame_bug-5945647 to the files 
-- $SRCHOME/rdbms/src/server/security/dv/schema/seed/rule_set.dlf
-- and $SRCHOME/rdbms/admin/catmacd.sql. These inserts are required for 
-- the "dbms_macadm.authorize_datapump_user" API to work properly after
-- the upgrade.
BEGIN
insert into dvsys.rule_set$ (id#, enabled, eval_options, audit_options,
                             fail_options, fail_code, handler_options,
                             handler, version, created_by,
                             create_date, updated_by, update_date) values 
(8, 'Y', 2, 1,
 1, NULL, 0,
 NULL, 1, 'DVSYS', 
 SYSDATE, 'DVSYS', SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into dvsys.rule_set_rule$ (id#, rule_set_id#, rule_id#, rule_order,
                                  enabled, version, created_by, create_date,
                                  updated_by, update_date) values
(10, 8, 2, 1,
 'Y', 1, 'DVSYS', SYSDATE,
 'DVSYS', SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into dvsys.rule_set_t$ (id#, name,
                               description, 
                               fail_message, language) values 
(8, 'Allow Oracle Data Pump Operation',
 'Rule set that controls the objects that can be exported '||
 'or imported by the Oracle Data Pump user.',
 NULL, 'us');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

-- The Data Pump rule set is set to 'Allow Datapump Operation'
-- in the pre-11.2 patches for the data pump transaction.
-- On upgrade to 11.2, the name of the rule set should be 
-- changed to 'Allow Oracle Data Pump Operation'.

BEGIN
update dvsys.rule_set_t$ set name = 'Allow Oracle Data Pump Operation' 
where name = 'Allow Datapump Operation' and id# = 8;
  EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/


-- Add DV Job rule set
BEGIN
insert into dvsys.rule_set$ (id#, enabled, eval_options, audit_options,
                             fail_options, fail_code, handler_options,
                             handler, version, created_by,
                             create_date, updated_by, update_date) values
(10, 'Y', 2, 1,
 1, NULL, 0,
 NULL, 1, 'DVSYS',
 SYSDATE, 'DVSYS', SYSDATE);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
    ELSE RAISE;
    END IF;
END;
/

--create the rule to grant SYS job authorization on EXFSYS schema
BEGIN
INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,CREATED_BY,CREATE_DATE,
UPDATED_BY,UPDATE_DATE)
VALUES(101,
    '(dvsys.dv_job_invoker = ''SYS'') AND (dvsys.dv_job_owner = ''EXFSYS'')',
    1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
INSERT INTO DVSYS.rule_t$ (ID#,NAME, language)
VALUES(101,
    'Is this SYS to run jobs under EXFSYS schema', 'us');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
insert into dvsys.rule_set_rule$ (id#, rule_set_id#, rule_id#, rule_order,
                                  enabled, version, created_by, create_date,
                                  updated_by, update_date) values
(18, 10, 2, 1,
 'Y', 1, 'DVSYS', SYSDATE,
 'DVSYS', SYSDATE);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
    ELSE RAISE;
    END IF;
END;
/


-- Insert granting SYS authorization on EXFSYS rule to rule_set_rule$ table
BEGIN
insert into dvsys.rule_set_rule$ (id#, rule_set_id#, rule_id#, rule_order,
                                  enabled, version, created_by, create_date,
                                  updated_by, update_date) values
(19, 10, 101, 1,
 'Y', 1, 'DVSYS', SYSDATE,
 'DVSYS', SYSDATE);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
    ELSE RAISE;
    END IF;
END;
/

insert into dvsys.dv_auth$ values ('JOB', 'SYS', 'EXFSYS', NULL, NULL);

BEGIN
insert into dvsys.rule_set_t$ (id#, name,
                               description, 
                               fail_message, language) values
(10, 'Allow Scheduler Job',
 'Rule set that stores DV scheduler job authorized users.',
 NULL, 'us');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
    ELSE RAISE;
    END IF;
END;
/

-- Bug 7449805: remove VPD related command rules "grant" and "revoke"
delete from dvsys.command_rule$ where RULE_SET_ID# = 6 and (ID# = 8 or ID# = 9);

-- Bug 7711393: Add DVSYS.DVLANG function and redefine views that use it.

Rem
Rem
Rem
Rem    Create a function which will return the correct language that should 
Rem    be used by all the language dependent DV views created below
Rem
Rem
CREATE OR REPLACE FUNCTION dvsys.dvlang(lid IN NUMBER, langtab_no IN NUMBER)
RETURN VARCHAR2
AS
  l_lcnt NUMBER;
  l_lang VARCHAR2(3);
  l_tab  VARCHAR2(30);
BEGIN
  l_lang := LOWER(SYS_CONTEXT('USERENV','LANG'));
  l_tab :=
    CASE langtab_no
      WHEN 1 THEN 'CODE_T$'
      WHEN 2 THEN 'FACTOR_T$'
      WHEN 3 THEN 'FACTOR_TYPE_T$'
      WHEN 4 THEN 'RULE_T$'
      WHEN 5 THEN 'RULE_SET_T$'
      WHEN 6 THEN 'REALM_T$'
      WHEN 7 THEN 'MONITOR_RULE_T$'
    END;

  EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ' || l_tab || ' WHERE id# = ' ||
                     lid || ' and language = ''' || l_lang || '''' into l_lcnt;

  if (l_lcnt = 0) then
    return 'us';
  else
    return l_lang;
  end if;
END;
/

CREATE OR REPLACE VIEW DVSYS.dv$code
(
      ID#
    , CODE_GROUP
    , CODE
    , VALUE
    , LANGUAGE
    , DESCRIPTION
    , VERSION
    , CREATED_BY
    , CREATE_DATE
    , UPDATED_BY
    , UPDATE_DATE
)
AS SELECT
      m.ID#
    , m.CODE_GROUP
    , m.CODE
    , d.VALUE
    , d.LANGUAGE
    , d.DESCRIPTION
    , m.VERSION
    , m.CREATED_BY
    , m.CREATE_DATE
    , m.UPDATED_BY
    , m.UPDATE_DATE
FROM dvsys.code$ m, dvsys.code_t$ d
WHERE m.id# = d.id#
      AND d.language = DVSYS.dvlang(m.id#, 1)
/

CREATE OR REPLACE VIEW DVSYS.dv$factor_type
(
      ID#
    , NAME
    , DESCRIPTION
    , VERSION
    , CREATED_BY
    , CREATE_DATE
    , UPDATED_BY
    , UPDATE_DATE
)
AS SELECT
      m.ID#
    , d.NAME
    , d.DESCRIPTION
    , m.VERSION
    , m.CREATED_BY
    , m.CREATE_DATE
    , m.UPDATED_BY
    , m.UPDATE_DATE
FROM dvsys.factor_type$ m, dvsys.factor_type_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 3) 
/

CREATE OR REPLACE VIEW DVSYS.dv$rule_set
(
      id#
    , name
    , description
    , enabled
    , eval_options
    , eval_options_meaning
    , audit_options
    , fail_options
    , fail_options_meaning
    , fail_message
    , fail_code
    , handler_options
    , handler
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
    , is_static
)
AS SELECT
      m.id#
    , d.name
    , d.description
    , m.enabled
    , m.eval_options - DECODE(bitand(m.eval_options, 128) , 128, 128, 0)
    , deval.value
    , m.audit_options
    , m.fail_options
    , dfail.value
    , d.fail_message
    , m.fail_code
    , m.handler_options
    , m.handler
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
    , DECODE(bitand(m.eval_options, 128) , 128, 'TRUE', 'FALSE')
FROM dvsys.rule_set$ m
    , dvsys.rule_set_t$ d
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 5) 
    AND deval.code  = TO_CHAR(m.eval_options  -
                            DECODE(bitand(m.eval_options,128) , 128, 128, 0))
    AND deval.code_group = 'RULESET_EVALUATE'
    AND dfail.code  = TO_CHAR(m.fail_options)
    AND dfail.code_group = 'RULESET_FAIL'
/

CREATE OR REPLACE VIEW DVSYS.dv$rule
(
      id#
    , name
    , rule_expr
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , d.name
    , m.rule_expr
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.rule$ m, dvsys.rule_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 4) 
/

CREATE OR REPLACE VIEW DVSYS.dv$factor
(
      id#
    , name
    , description
    , factor_type_id#
    , factor_type_name
    , assign_rule_set_id#
    , assign_rule_set_name
    , get_expr
    , validate_expr
    , identified_by
    , identified_by_meaning
    , namespace
    , namespace_attribute
    , labeled_by
    , labeled_by_meaning
    , eval_options
    , eval_options_meaning
    , audit_options
    , fail_options
    , fail_options_meaning
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , m.name
    , d.description
    , m.factor_type_id#
    , dft.name
    , m.assign_rule_set_id#
    , drs.name
    , m.get_expr
    , m.validate_expr
    , m.identified_by
    , did.value
    , m.namespace
    , m.namespace_attribute
    , m.labeled_by
    , dlabel.value
    , m.eval_options
    , deval.value
    , m.audit_options
    , m.fail_options
    , dfail.value
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.factor$ m
    , dvsys.factor_t$ d
    , dvsys.dv$factor_type dft
    , dvsys.dv$rule_set drs
    , dvsys.dv$code did
    , dvsys.dv$code dlabel
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 2)
    AND dft.id# = m.factor_type_id#
    AND did.code    = TO_CHAR(m.identified_by)  and did.code_group = 'FACTOR_IDENTIFY'
    AND dlabel.code = TO_CHAR(m.labeled_by)  and dlabel.code_group = 'FACTOR_LABEL'
    AND deval.code  = TO_CHAR(m.eval_options) and deval.code_group = 'FACTOR_EVALUATE'
    AND dfail.code  = TO_CHAR(m.fail_options) and dfail.code_group = 'FACTOR_FAIL'
    AND drs.id#  (+)= m.assign_rule_set_id#
/

CREATE OR REPLACE VIEW DVSYS.dv$realm
(
      id#
    , name
    , description
    , audit_options
    , enabled
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , d.name
    , d.description
    , m.audit_options
    , m.enabled
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.realm$ m, dvsys.realm_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 6) 
/

CREATE OR REPLACE VIEW DVSYS.dv$monitor_rule
(
      id#
    , name
    , description
    , monitor_rule_set_id#
    , monitor_rule_set_name
    , restart_freq
    , enabled
    , version
    , created_by
    , create_date
    , updated_by
    , update_date
)
AS SELECT
      m.id#
    , d.name
    , d.description
    , m.monitor_rule_set_id#
    , drs.name
    , m.restart_freq
    , m.enabled
    , m.version
    , m.created_by
    , m.create_date
    , m.updated_by
    , m.update_date
FROM dvsys.monitor_rule$ m
    , dvsys.monitor_rule_t$ d
    , dvsys.dv$rule_set drs
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 7) 
    AND drs.id#  = m.monitor_rule_set_id#
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_code
(
     CODE_GROUP
    , CODE
    , VALUE
    , LANGUAGE
    , DESCRIPTION
)
AS SELECT
      m.CODE_GROUP
    , m.CODE
    , d.VALUE
    , d.LANGUAGE
    , d.DESCRIPTION
FROM dvsys.code$ m, dvsys.code_t$ d
WHERE m.id# = d.id#
      AND d.language = DVSYS.dvlang(m.id#, 1) 
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_factor
(
      name
    , description
    , factor_type_name
    , assign_rule_set_name
    , get_expr
    , validate_expr
    , identified_by
    , identified_by_meaning
    , namespace
    , namespace_attribute
    , labeled_by
    , labeled_by_meaning
    , eval_options
    , eval_options_meaning
    , audit_options
    , fail_options
    , fail_options_meaning
)
AS SELECT
      m.name
    , d.description
    , dft.name
    , drs.name
    , m.get_expr
    , m.validate_expr
    , m.identified_by
    , did.value
    , m.namespace
    , m.namespace_attribute
    , m.labeled_by
    , dlabel.value
    , m.eval_options
    , deval.value
    , m.audit_options
    , m.fail_options
    , dfail.value
FROM dvsys.factor$ m
    , dvsys.factor_t$ d
    , dvsys.dv$factor_type dft
    , dvsys.dv$rule_set drs
    , dvsys.dv$code did
    , dvsys.dv$code dlabel
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 2) 
    AND dft.id# = m.factor_type_id#
    AND did.code    = TO_CHAR(m.identified_by)  and did.code_group = 'FACTOR_IDENTIFY'
    AND dlabel.code = TO_CHAR(m.labeled_by)  and dlabel.code_group = 'FACTOR_LABEL'
    AND deval.code  = TO_CHAR(m.eval_options) and deval.code_group = 'FACTOR_EVALUATE'
    AND dfail.code  = TO_CHAR(m.fail_options) and dfail.code_group = 'FACTOR_FAIL'
    AND drs.id#  (+)= m.assign_rule_set_id#
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_factor_type
(
      NAME
    , DESCRIPTION
)
AS SELECT
      d.NAME
    , d.DESCRIPTION
FROM dvsys.factor_type$ m, dvsys.factor_type_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 3)
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_realm
(
      name
    , description
    , audit_options
    , enabled
)
AS SELECT
      d.name
    , d.description
    , m.audit_options
    , m.enabled
FROM dvsys.realm$ m, dvsys.realm_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 6)
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_rule
(
      name
    , rule_expr
)
AS SELECT
      d.name
    , m.rule_expr
FROM dvsys.rule$ m, dvsys.rule_t$ d
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 4)
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_monitor_rule
(
      name
    , description
    , monitor_rule_set_name
    , restart_freq
    , enabled
)
AS SELECT
      d.name
    , d.description
    , drs.name
    , m.restart_freq
    , m.enabled
FROM dvsys.monitor_rule$ m
    , dvsys.monitor_rule_t$ d
    , dvsys.dv$rule_set drs
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 7)
    AND drs.id#  = m.monitor_rule_set_id#
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_rule_set
(
      rule_set_name
    , description
    , enabled
    , eval_options_meaning
    , audit_options
    , fail_options_meaning
    , fail_message
    , fail_code
    , handler_options
    , handler
    , is_static
)
AS SELECT
      d.name
    , d.description
    , m.enabled
    , deval.value
    , m.audit_options
    , dfail.value
    , d.fail_message
    , m.fail_code
    , m.handler_options
    , m.handler
    , DECODE(bitand(m.eval_options, 128) , 128, 'TRUE', 'FALSE')
FROM dvsys.rule_set$ m
    , dvsys.rule_set_t$ d
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 5)
    AND deval.code  = TO_CHAR(m.eval_options -
                             DECODE(bitand(m.eval_options,128) , 128, 128, 0))
    AND deval.code_group = 'RULESET_EVALUATE'
    AND dfail.code  = TO_CHAR(m.fail_options)
    AND dfail.code_group = 'RULESET_FAIL'
/

ALTER SESSION SET CURRENT_SCHEMA = SYS;

------------------------------------------------------------------------------
-- bug 6938028: Database Vault Protected Schema.
-- Insert rows into metaview$ to register the real Data Pump types,
-- created above.
------------------------------------------------------------------------------

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_REALM',0,0,'ORACLE',1002000200,
  'DVPS_REALM_T',
  'KU$_DV_REALM_T','DVSYS','KU$_DV_REALM_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_REALM_MEMBERSHIP',0,0,'ORACLE',1002000200,
  'DVPS_REALM_MEMBERSHIP_T',
  'KU$_DV_REALM_MEMBER_T','DVSYS','KU$_DV_REALM_MEMBER_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_REALM_AUTHORIZATION',0,0,'ORACLE',1002000200,
  'DVPS_REALM_AUTHORIZATION_T',
  'KU$_DV_REALM_AUTH_T','DVSYS','KU$_DV_REALM_AUTH_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_IMPORT_STAGING_REALM',0,0,'ORACLE',1002000200,
  'DVPS_IMPORT_STAGING_REALM_T',
  'KU$_DV_ISR_T','DVSYS','KU$_DV_ISR_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_STAGING_REALM_MEMBERSHIP',0,0,'ORACLE',1002000200,
  'DVPS_STAGING_REALM_MEMBERSHP_T',
  'KU$_DV_ISRM_T','DVSYS','KU$_DV_ISRM_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DROP_IMPORT_STAGING_REALM',0,0,'ORACLE',1002000200,
  'DVPS_DISR_T',
  'KU$_DV_ISR_T','DVSYS','KU$_DV_ISR_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_RULE',0,0,'ORACLE',1002000200,
  'DVPS_RULE_T',
  'KU$_DV_RULE_T','DVSYS','KU$_DV_RULE_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_RULE_SET',0,0,'ORACLE',1002000200,
  'DVPS_RULE_SET_T',
  'KU$_DV_RULE_SET_T','DVSYS','KU$_DV_RULE_SET_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_RULE_SET_MEMBERSHIP',0,0,'ORACLE',1002000200,
  'DVPS_RULE_SET_MEMBERSHIP_T',
  'KU$_DV_RULE_SET_MEMBER_T','DVSYS','KU$_DV_RULE_SET_MEMBER_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_COMMAND_RULE',0,0,'ORACLE',1002000200,
  'DVPS_COMMAND_RULE_T',
  'KU$_DV_COMMAND_RULE_T','DVSYS','KU$_DV_COMMAND_RULE_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_ROLE',0,0,'ORACLE',1002000200,
  'DVPS_ROLE_T',
  'KU$_DV_ROLE_T','DVSYS','KU$_DV_ROLE_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_FACTOR',0,0,'ORACLE',1002000200,
  'DVPS_FACTOR_T',
  'KU$_DV_FACTOR_T','DVSYS','KU$_DV_FACTOR_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_FACTOR_LINK',0,0,'ORACLE',1002000200,
  'DVPS_FACTOR_LINK_T',
  'KU$_DV_FACTOR_LINK_T','DVSYS','KU$_DV_FACTOR_LINK_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_FACTOR_TYPE',0,0,'ORACLE',1002000200,
  'DVPS_FACTOR_TYPE_T',
  'KU$_DV_FACTOR_TYPE_T','DVSYS','KU$_DV_FACTOR_TYPE_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_IDENTITY',0,0,'ORACLE',1002000200,
  'DVPS_IDENTITY_T',
  'KU$_DV_IDENTITY_T','DVSYS','KU$_DV_IDENTITY_VIEW');

insert into metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_IDENTITY_MAP',0,0,'ORACLE',1002000200,
  'DVPS_IDENTITY_MAP_T',
  'KU$_DV_IDENTITY_MAP_T','DVSYS','KU$_DV_IDENTITY_MAP_VIEW');

-- Bug 6938843 : Add Rules for ALTER SYSTEM command

-- Insert the new rule set into the rule_set$ table and rule_set_t$ table
BEGIN
insert into dvsys.rule_set$ (id#, enabled, eval_options, audit_options,
                             fail_options, fail_code, handler_options,
                             handler, version, created_by,
                             create_date, updated_by, update_date) values 
(9, 'Y', 1, 1,
 1, NULL, 0,
 NULL, 1, 'DVSYS', 
 SYSDATE, 'DVSYS', SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into dvsys.rule_set_t$ (ID#, NAME, DESCRIPTION, FAIL_MESSAGE,
                             LANGUAGE ) values 
 (9, 'Allow Fine Grained Control of System Parameters', 
'Fine Grained Rule set to controls the ability to set system init parameters.', NULL, 'us');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.rule$ 
       (ID#,RULE_EXPR,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(15,'DVSYS.DBMS_MACADM.check_sys_sec_parm_varchar = ''Y''',1,
         USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.rule$
       (ID#,RULE_EXPR,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(16,'DVSYS.DBMS_MACADM.check_dump_dest_parm_varchar = ''Y''',1,
         USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.rule$ 
       (ID#,RULE_EXPR,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(17,'DVSYS.DBMS_MACADM.check_backup_parm_varchar = ''Y''',1,
         USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.rule$
       (ID#,RULE_EXPR,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(18,'DVSYS.DBMS_MACADM.check_db_file_parm_varchar = ''Y''',1,
         USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/
       
BEGIN
insert into DVSYS.rule$
       (ID#,RULE_EXPR,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(19,'DVSYS.DBMS_MACADM.check_optimizer_parm_varchar = ''Y''',1, 
         USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/
       
BEGIN
insert into DVSYS.rule$
       (ID#,RULE_EXPR,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(20,'DVSYS.DBMS_MACADM.check_plsql_parm_varchar = ''Y''',1,
         USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/
       
BEGIN
insert into DVSYS.rule$
       (ID#,RULE_EXPR,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(21,'DVSYS.DBMS_MACADM.check_security_parm_varchar = ''Y''',1, 
         USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.rule_t$(ID#, NAME, LANGUAGE)
       VALUES(15, 'Are System Security Parameters Allowed', 'us');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.rule_t$(ID#, NAME, LANGUAGE)
       VALUES(16, 'Are Dump or Dest Parameters Allowed', 'us');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.rule_t$(ID#, NAME, LANGUAGE)
       VALUES(17, 'Are Backup Restore Parameters Allowed', 'us');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/
       
BEGIN
insert into DVSYS.rule_t$(ID#, NAME, LANGUAGE)
       VALUES(18, 'Are Database File Parameters Allowed', 'us');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/
       
BEGIN
insert into DVSYS.rule_t$(ID#, NAME, LANGUAGE)
       VALUES(19, 'Are Optimizer Parameters Allowed', 'us');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/
       
BEGIN
insert into DVSYS.rule_t$(ID#, NAME, LANGUAGE)
       VALUES(20, 'Are PL-SQL Parameters Allowed', 'us');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/
       
BEGIN
insert into DVSYS.rule_t$(ID#, NAME, LANGUAGE)
       VALUES(21, 'Are Security Parameters Allowed', 'us');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/
       
BEGIN
insert into DVSYS.RULE_SET_RULE$
       (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,
        CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(11,9,15,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.RULE_SET_RULE$
       (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,
        CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(12,9,16,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.RULE_SET_RULE$
       (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,
        CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(13,9,17,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.RULE_SET_RULE$
       (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,
        CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(14,9,18,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.RULE_SET_RULE$
       (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,
        CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(15,9,19,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.RULE_SET_RULE$
       (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,
        CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(16,9,20,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into DVSYS.RULE_SET_RULE$
       (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,
        CREATE_DATE,UPDATED_BY,UPDATE_DATE)
       VALUES(17,9,21,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

create or replace view DVSYS.DV_AUDIT_CLEANUP_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_AUDIT_CLEANUP'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys.user$ where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_AUDIT_CLEANUP'));
/

-- Bug 7657506
-- Protect the ALTER SYSTEM command with the new rule set
-- 'Allow Fine Grained Control of System Parameters'
-- Retain all the old rules and rule set

update DVSYS.command_rule$ set RULE_SET_ID# = 9 where ID# = 10;

commit;
