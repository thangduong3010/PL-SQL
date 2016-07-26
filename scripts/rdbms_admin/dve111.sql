Rem
Rem $Header: rdbms/admin/dve111.sql /main/18 2010/06/10 11:08:03 vigaur Exp $
Rem
Rem dve111.sql
Rem
Rem Copyright (c) 2008, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dve111.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vigaur      06/02/10 - Add call to dve112
Rem    ruparame    03/30/09 - Bug 8393717 Change the datapump rule set name to
Rem                           Allow Oracle Data Pump Operation
Rem    jheng       02/16/09 - remove DV/Job related rule set
Rem    ruparame    02/05/09 - Bug 8211922 drop the ALTERSYSTEM rules before
Rem                           downgrade
Rem    prramakr    02/04/09 - lrg3785648: fix compilation issue regarding
Rem                           dvlang function.
Rem    srtata      12/29/08 - add ruleset view: static ruleset implmentation
Rem    prramakr    01/15/09 - Bug7711393: Remove dvlang function and
Rem                           redefine views that use it
Rem    jibyun      12/23/08 - Drop DV_STREAMS_ADMIN role from Database Vault
Rem                           realm
Rem    youyang     11/14/08 - Add before and after triggers, add role owners
Rem    clei        12/10/08 - DV_PATCH -> DV_PATCH_ADMIN
Rem    ssonawan    12/02/08 - lrg 3706796: move sync_rules to dvrelod.sql
Rem    ssonawan    10/14/08 - bug 6938843: Delete rules for alter system command
Rem    jibyun      10/31/08 - LRG 3679678: Drop is_secure_application_role
Rem                           function and its synonym
Rem    ruparame    08/25/08 - Bug 7319691: Create DV_MONITOR role
Rem    clei        09/10/08 - Bug 6435192: dv_off link option and migration mode
Rem    pknaggs     07/29/08 - bug 6938028: Database Vault Protected Schema.
Rem    vigaur      04/16/08 - Created
Rem

EXECUTE dbms_registry.downgrading('DV');

@@dve112.sql
-----------------------------------------------------------------------------
-- Restore owners of roles in DVSYS.realm_object$
----------------------------------------------------------------------------
update DVSYS.realm_object$
set owner = 'SYS'
where object_type = 'ROLE';

update DVSYS.realm_object$
set owner = 'DVSYS'
where object_type = 'ROLE' and object_name in ('DV_OWNER', 'DV_ADMIN', 'DV_SECANALYST',
		 'DV_PUBLIC', 'DV_PATCH_ADMIN', 'DV_MONITOR', 'CONNECT', 'DV_ACCTMGR',
                 'DV_STREAMS_ADMIN');

update DVSYS.realm_object$
set owner = 'LBACSYS'
where object_type = 'ROLE' and object_name = 'LBAC_DBA';

update DVSYS.realm_object$
set owner = 'OLAPSYS'
where object_type = 'ROLE' and object_name in ('OLAP_DBA', 'OLAP_USER');

update DVSYS.realm_object$
set owner = 'CTXSYS'
where object_type = 'ROLE' and object_name = 'CTXAPP';

update DVSYS.realm_object$
set owner = 'DBSNMP'
where object_type = 'ROLE' and object_name = 'OEM_MONITOR';

update DVSYS.realm_object$
set owner = 'SYSMAN'
where object_type = 'ROLE' and object_name in ('MGMT_USER', 'MGMT_VIEW');

------------------------------------------------------------------------------
-- Bug 6435192: Keep DV protection for dv_off link option and migration mode
------------------------------------------------------------------------------
-- Clear DV enforcement status because we cannot drop DVSYS owned tables;
delete from DVSYS.config$;

delete from dvsys.dv_auth$;

drop view DVSYS.dba_dv_job_auth;

-- Remove DV_PATCH_ADMIN grants because we cannot drop DV protected roles
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_PATCH_ADMIN');

-- Remove DV_PATCH_ADMIN from DVSYS.realm_object$
delete from DVSYS.realm_object$ where
  owner = 'DVSYS' and object_name = 'DV_PATCH_ADMIN' and
  object_type = 'ROLE' and version = 1;

commit;
------------------------------------------------------------------------------
-- Bug 7319691: Delete the DV_MONITOR grants and the realm protection for the 
-- DV_MONITOR role as this role does not exist in older releases
------------------------------------------------------------------------------

drop view DVSYS.DV_MONITOR_GRANTEES;

-- Remove DV_MONNITOR grants
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_MONITOR');

-- Remove the realm protection for DV_MONITOR
delete from DVSYS.realm_object$ where
  owner = 'DVSYS' and object_name = 'DV_MONITOR' and
  object_type = 'ROLE' and version = 1;

-- Revoke the object privileges that has been granted to DV_MONITOR role
REVOKE SELECT ON dvsys.audit_trail$ FROM dv_monitor;
REVOKE SELECT ON dvsys.dv$realm_auth FROM dv_monitor;
REVOKE SELECT ON dvsys.dv$rule_set FROM dv_monitor;
REVOKE SELECT ON dvsys.dv$rule_set_rule FROM dv_monitor;
REVOKE SELECT ON dvsys.dv$realm_object FROM dv_monitor;
REVOKE SELECT ON dvsys.dv$sys_grantee FROM dv_monitor;
REVOKE SELECT ON dvsys.dv$sys_object_owner FROM dv_monitor;
REVOKE SELECT ON dvsys.dv$command_rule FROM dv_monitor;
REVOKE SELECT ON dvsys.dba_dv_code FROM dv_monitor;
REVOKE SELECT ON dvsys.dba_dv_command_rule FROM dv_monitor;

commit;
------------------------------------------------------------------------------
-- End of downgrade for the DV_MONITOR role
------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Bug 7656640: Delete the DV_STREAMS_ADMIN grants and its realm protection.
------------------------------------------------------------------------------
-- Remove DV_STREAMS_ADMIN grants
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_STREAMS_ADMIN');

-- Remove the realm protection for DV_STREAMS_ADMIN
delete from DVSYS.realm_object$ where
  owner = 'DVSYS' and object_name = 'DV_STREAMS_ADMIN' and
  object_type = 'ROLE' and version = 1;

commit;

------------------------------------------------------------------------------
--    bug 6938028: Database Vault Protected Schema.
--    Drop the Data Pump Metadata API object views
--    defined to support Data Pump export/import of the Database Vault
--    Protected Schema metadata objects (Realms, Command Rules, etc.).
------------------------------------------------------------------------------
drop view dvsys.ku$_dv_isr_view;
drop view dvsys.ku$_dv_isrm_view;
drop view dvsys.ku$_dv_realm_view;
drop view dvsys.ku$_dv_realm_member_view;
drop view dvsys.ku$_dv_realm_auth_view;
drop view dvsys.ku$_dv_rule_view;
drop view dvsys.ku$_dv_rule_set_view;
drop view dvsys.ku$_dv_rule_set_member_view;
drop view dvsys.ku$_dv_command_rule_view;
drop view dvsys.ku$_dv_role_view;
drop view dvsys.ku$_dv_factor_view;
drop view dvsys.ku$_dv_factor_link_view;
drop view dvsys.ku$_dv_factor_type_view;
drop view dvsys.ku$_dv_identity_view;
drop view dvsys.ku$_dv_identity_map_view;


------------------------------------------------------------------------------
--    bug 6938028: Database Vault Protected Schema.
--    Drop the Data Pump Metadata API user-defined types (UDTs)
--    defined to support Data Pump export/import of the Database Vault
--    Protected Schema metadata objects (Realms, Command Rules, etc.).
------------------------------------------------------------------------------
drop type dvsys.ku$_dv_isr_t;
drop type dvsys.ku$_dv_isrm_t;
drop type dvsys.ku$_dv_realm_t;
drop type dvsys.ku$_dv_realm_member_t;
drop type dvsys.ku$_dv_realm_auth_t;
drop type dvsys.ku$_dv_rule_t;
drop type dvsys.ku$_dv_rule_set_t;
drop type dvsys.ku$_dv_rule_set_member_t;
drop type dvsys.ku$_dv_command_rule_t;
drop type dvsys.ku$_dv_role_t;
drop type dvsys.ku$_dv_factor_t;
drop type dvsys.ku$_dv_factor_link_t;
drop type dvsys.ku$_dv_factor_type_t;
drop type dvsys.ku$_dv_identity_t;
drop type dvsys.ku$_dv_identity_map_t;

------------------------------------------------------------------------------
-- bug 6938028: Database Vault Protected Schema.
-- Delete rows from metaview$ to remove the registrations of
-- the real Data Pump types, which were dropped just above.
------------------------------------------------------------------------------

delete from metaview$ 
 where type       = 'DVPS_REALM'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_REALM_T'
   and udt        = 'KU$_DV_REALM_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_REALM_VIEW';

delete from metaview$ 
 where type       = 'DVPS_REALM_MEMBERSHIP'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_REALM_MEMBERSHIP_T'
   and udt        = 'KU$_DV_REALM_MEMBER_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_REALM_MEMBER_VIEW';

delete from metaview$ 
 where type       = 'DVPS_REALM_AUTHORIZATION'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_REALM_AUTHORIZATION_T'
   and udt        = 'KU$_DV_REALM_AUTH_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_REALM_AUTH_VIEW';

delete from metaview$ 
 where type       = 'DVPS_IMPORT_STAGING_REALM'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_IMPORT_STAGING_REALM_T'
   and udt        = 'KU$_DV_ISR_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_ISR_VIEW';

delete from metaview$ 
 where type       = 'DVPS_STAGING_REALM_MEMBERSHIP'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_STAGING_REALM_MEMBERSHP_T'
   and udt        = 'KU$_DV_ISRM_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_ISRM_VIEW';

delete from metaview$ 
 where type       = 'DVPS_DROP_IMPORT_STAGING_REALM'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_DISR_T'
   and udt        = 'KU$_DV_ISR_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_ISR_VIEW';

delete from metaview$ 
 where type       = 'DVPS_RULE'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_RULE_T'
   and udt        = 'KU$_DV_RULE_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_RULE_VIEW';

delete from metaview$ 
 where type       = 'DVPS_RULE_SET'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_RULE_SET_T'
   and udt        = 'KU$_DV_RULE_SET_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_RULE_SET_VIEW';

delete from metaview$ 
 where type       = 'DVPS_RULE_SET_MEMBERSHIP'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_RULE_SET_MEMBERSHIP_T'
   and udt        = 'KU$_DV_RULE_SET_MEMBER_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_RULE_SET_MEMBER_VIEW';

delete from metaview$ 
 where type       = 'DVPS_COMMAND_RULE'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_COMMAND_RULE_T'
   and udt        = 'KU$_DV_COMMAND_RULE_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_COMMAND_RULE_VIEW';

delete from metaview$ 
 where type       = 'DVPS_ROLE'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_ROLE_T'
   and udt        = 'KU$_DV_ROLE_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_ROLE_VIEW';

delete from metaview$ 
 where type       = 'DVPS_FACTOR'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_FACTOR_T'
   and udt        = 'KU$_DV_FACTOR_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_FACTOR_VIEW';

delete from metaview$ 
 where type       = 'DVPS_FACTOR_LINK'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_FACTOR_LINK_T'
   and udt        = 'KU$_DV_FACTOR_LINK_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_FACTOR_LINK_VIEW';

delete from metaview$ 
 where type       = 'DVPS_FACTOR_TYPE'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_FACTOR_TYPE_T'
   and udt        = 'KU$_DV_FACTOR_TYPE_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_FACTOR_TYPE_VIEW';

delete from metaview$ 
 where type       = 'DVPS_IDENTITY'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_IDENTITY_T'
   and udt        = 'KU$_DV_IDENTITY_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_IDENTITY_VIEW';

delete from metaview$ 
 where type       = 'DVPS_IDENTITY_MAP'
   and flags      = 0 
   and properties = 0
   and model      = 'ORACLE'
   and version    = 1002000200
   and xmltag     = 'DVPS_IDENTITY_MAP_T'
   and udt        = 'KU$_DV_IDENTITY_MAP_T'
   and schema     = 'DVSYS'
   and viewname   = 'KU$_DV_IDENTITY_MAP_VIEW';

------------------------------------------------------------------------------
-- bug 6938028: Database Vault Protected Schema.
-- Cascade delete of the 'Allow Oracle Data Pump Operation' Rule Set.
------------------------------------------------------------------------------

-- First, delete any Data Pump Authorization Rules from Rule and Rule Set
-- tables. Such Rules are added using the DBMS_MACADM.AUTHORIZE_DATAPUMP_USER
-- API, and always have names starting with the string 'DVDP$'.

declare
cursor rcur is
  select r.id# from dvsys.rule$ r,
                    dvsys.rule_set_rule$ rsr
               where rsr.id# <> 10
               and rsr.rule_set_id# = 8
               and rsr.rule_id# <> 2
               and rsr.rule_id# = r.id#;
begin
  for iter in rcur loop
    delete from dvsys.rule_set_rule$ where rule_id# = iter.id#;
    delete from dvsys.rule$ where id# = iter.id#;
    dbms_rule_adm.drop_rule('DVSYS.DV$' || iter.id#, true);
  end loop;
end;
/
 
-- Next, we remove the 'False' Rule entry (which always has id# 10) of
-- the 'Allow Oracle Data Pump Operation' Rule Set (which has id# 8) from
-- the Rule Set table. We don't delete the Rule itself from the Rule
-- table (as 'False' is a seeded rule that needs to be kept).

delete from dvsys.rule_set_rule$
 where id# = 10
   and rule_set_id# = 8
   and rule_id# = 2;

-- Finally, we delete the 'Allow Oracle Data Pump Operation' Rule Set 
-- along with its description:

delete from dvsys.rule_set$
 where id# = 8;

delete from dvsys.rule_set_t$
 where id# = 8;

-- Delete the rules tied to the rule set 
-- 'Allow Fine Grained Control of System Parameters'

delete from dvsys.rule_set_rule$ 
        where rule_set_id# = 9;

delete from dvsys.rule$
  where id# in (15, 16, 17, 18, 19, 20, 21);
 
delete from dvsys.rule_t$
  where id# in (15, 16, 17, 18, 19, 20, 21);

-- Delete the corresponding rule entries from the SYS.rule$ 
-- Table as well. 

 declare
    iter NUMBER;
    begin
      for iter in 15 .. 21 loop
        dbms_rule_adm.drop_rule('DVSYS.DV$' || iter, true);
      end loop;
    end;
/

update DVSYS.command_rule$ set RULE_SET_ID# = 7 where ID# = 10;

commit;

delete from dvsys.rule_set$
 where id# = 9;

delete from dvsys.rule_set_t$
 where id# = 9;

-- The dbms_macadm.delete_rule_set API deletes
-- The rule set from the sys.rule_set$ table in addition to the 
-- DVSYS.rule_set$ table.
-- The rule set entry should be deleted from the sys.rule_set$.

-- Delete rule set entry for the data pump authorization rule set 
-- Allow Oracle Data Pump Operation.

exec  dbms_rule_adm.drop_rule_set('DVSYS.DV$8',false);

-- Delete rule set entry for the ALTER SYSTEM rule set
-- Allow Fine Grained Control of System parameters 

exec  dbms_rule_adm.drop_rule_set('DVSYS.DV$9',false);

-- Invoke the "sync_rules" to remove the DVSYS.DV$8 Rule Set using the
-- Rules engine (it exists as a first-class KGL object, see obj$).
-- LRG 3706796 : sync_rules is moved to dvrelod.sql

-------------------------------------------------------------------------------
--- bug 7209325: remove DV Job related rule set "Allow Scheduler Job" and rules
-------------------------------------------------------------------------------
declare
cursor cur is 
select r.id# from dvsys.rule$  r, 
                  dvsys.rule_set_rule$  rsr
             where rsr.id# <> 18
               and rsr.rule_set_id# = 10
               and rsr.rule_id# <> 2
               and rsr.rule_id# = r.id#;
begin
  for iter in cur loop
    delete from dvsys.rule_set_rule$ where rule_id# = iter.id#;
    delete from dvsys.rule$ where id# = iter.id#;
    dbms_rule_adm.drop_rule('DVSYS.DV$' || iter.id#, true);
  end loop;
end;
/

delete from dvsys.rule_set_rule$
       where id# = 18
         and rule_set_id# = 10
         and rule_id# = 2;

delete from dvsys.rule_set$ 
  where id# = 10;

delete from dvsys.rule_set_t$
  where id# = 10;

exec  dbms_rule_adm.drop_rule_set('DVSYS.DV$10',false);

drop function dvsys.DV_JOB_OWNER;
drop function dvsys.DV_JOB_INVOKER;

-- Bug 7657506
-- Protect the ALTER SYSTEM command with the old rule set
-- 'Allow System Parameters'
-- Retain all the newly created rules and rule set


-- LRG 3679678
DROP PUBLIC SYNONYM is_secure_application_role;
DROP FUNCTION DVSYS.is_secure_application_role;

-- Bug 7711393: Remove DVSYS.DVLANG function and redefine views that use it.
-- Remove this function only if downgrading to version less than 11.1.0.7.
DECLARE
  p_version SYS.registry$.version%type;
BEGIN
  EXECUTE IMMEDIATE 'select prv_version from registry$
                     where cid = ''DV'''
                     into p_version;

  if (substr(p_version, 1, 8) = '11.1.0.6') then

    EXECUTE IMMEDIATE 'DROP FUNCTION DVSYS.DVLANG';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$code
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
      AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) or
            (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM dvsys.code_t$
                                             WHERE id# = d.id# AND
                                             language =
                                             LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
            )
          )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$factor_type
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM 
               dvsys.factor_type_t$ WHERE id# = d.id# AND 
                language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$rule_set
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
    )
    AS SELECT
          m.id#
        , d.name
        , d.description
        , m.enabled
        , m.eval_options
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
    FROM dvsys.rule_set$ m
        , dvsys.rule_set_t$ d
        , dvsys.dv$code deval
        , dvsys.dv$code dfail
    WHERE
        m.id# = d.id#
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) or
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM dvsys.rule_set_t$
              WHERE id# = d.id# AND
                    language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )
        AND deval.code  = TO_CHAR(m.eval_options)
        AND deval.code_group = ''RULESET_EVALUATE''
        AND dfail.code  = TO_CHAR(m.fail_options)
        AND dfail.code_group = ''RULESET_FAIL''';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$rule
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM dvsys.rule_t$
               WHERE id# = d.id# AND
                     language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$factor
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM dvsys.factor_t$
               WHERE id# = d.id# AND
                     language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )
        AND dft.id# = m.factor_type_id#
        AND did.code    = TO_CHAR(m.identified_by)  and did.code_group = ''FACTOR_IDENTIFY''
        AND dlabel.code = TO_CHAR(m.labeled_by)  and dlabel.code_group = ''FACTOR_LABEL''
        AND deval.code  = TO_CHAR(m.eval_options) and deval.code_group = ''FACTOR_EVALUATE''
        AND dfail.code  = TO_CHAR(m.fail_options) and dfail.code_group = ''FACTOR_FAIL''
        AND drs.id#  (+)= m.assign_rule_set_id#';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$realm
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM dvsys.realm_t$
               WHERE id# = d.id# AND
                     language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$monitor_rule
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM
               dvsys.monitor_rule_t$ WHERE id# = d.id# AND
                language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )
        AND drs.id#  = m.monitor_rule_set_id#';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dba_dv_code
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
          AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
               (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM dvsys.code_t$
                 WHERE id# = d.id# AND
                       language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
               )
              )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dba_dv_factor
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM dvsys.factor_t$
               WHERE id# = d.id# AND
                     language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )
        AND dft.id# = m.factor_type_id#
        AND did.code    = TO_CHAR(m.identified_by)  and did.code_group = ''FACTOR_IDENTIFY''
        AND dlabel.code = TO_CHAR(m.labeled_by)  and dlabel.code_group = ''FACTOR_LABEL''
        AND deval.code  = TO_CHAR(m.eval_options) and deval.code_group = ''FACTOR_EVALUATE''
        AND dfail.code  = TO_CHAR(m.fail_options) and dfail.code_group = ''FACTOR_FAIL''
        AND drs.id#  (+)= m.assign_rule_set_id#';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dba_dv_factor_type
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM
               dvsys.factor_type_t$ WHERE id# = d.id# AND
               language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dba_dv_realm
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM dvsys.realm_t$
               WHERE id# = d.id# AND
                     language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dba_dv_rule
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM dvsys.rule_t$
               WHERE id# = d.id# AND
                     language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dba_dv_monitor_rule
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
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM
              dvsys.monitor_rule_t$ WHERE id# = d.id# AND
              language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )
        AND drs.id#  = m.monitor_rule_set_id#';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dba_dv_rule_set
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
    FROM dvsys.rule_set$ m
        , dvsys.rule_set_t$ d
        , dvsys.dv$code deval
        , dvsys.dv$code dfail
    WHERE
        m.id# = d.id#
        AND (d.language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')) OR
             (d.language = ''us'' AND NOT EXISTS (SELECT id# FROM
              dvsys.rule_set_t$ WHERE id# = d.id# AND
              language = LOWER(SYS_CONTEXT(''USERENV'',''LANG'')))
             )
            )
        AND deval.code  = TO_CHAR(m.eval_options)
        AND deval.code_group = ''RULESET_EVALUATE''
        AND dfail.code  = TO_CHAR(m.fail_options)
        AND dfail.code_group = ''RULESET_FAIL''';

  elsif (substr(p_version, 1, 8) = '11.1.0.7') then
   EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dv$rule_set
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
   )
   AS SELECT
      m.id#
    , d.name
    , d.description
    , m.enabled
    , m.eval_options
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
   FROM dvsys.rule_set$ m
    , dvsys.rule_set_t$ d
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
   WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 5)
    AND deval.code  = TO_CHAR(m.eval_options)
    AND deval.code_group = ''RULESET_EVALUATE''
    AND dfail.code  = TO_CHAR(m.fail_options)
    AND dfail.code_group = ''RULESET_FAIL''';

    EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW DVSYS.dba_dv_rule_set
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
    FROM dvsys.rule_set$ m
    , dvsys.rule_set_t$ d
    , dvsys.dv$code deval
    , dvsys.dv$code dfail
    WHERE
    m.id# = d.id#
    AND d.language = DVSYS.dvlang(m.id#, 5)
    AND deval.code  = TO_CHAR(m.eval_options)
    AND deval.code_group = ''RULESET_EVALUATE''
    AND dfail.code  = TO_CHAR(m.fail_options)
    AND dfail.code_group = ''RULESET_FAIL''';
  end if;
END;
/
    

-- static rule sets should be made to the original state as in 11.1

update DVSYS.rule_set$ set eval_options = eval_options
             - DECODE(bitand(eval_options,128) , 128, 128, 0);

REM
REM Call the downgrade script for next version (none)
REM

EXECUTE dbms_registry.downgraded('DV','11.1.0');
