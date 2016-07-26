Rem
Rem $Header: rdbms/admin/f1102000.sql /st_rdbms_11.2.0/1 2012/08/25 00:06:32 pknaggs Exp $
Rem
Rem f1102000.sql
Rem
Rem Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      f1102000.sql - Use PL/SQL packages for downgrade 
Rem                     from 11.2.0 patch release
Rem
Rem    DESCRIPTION
Rem
Rem      This scripts is run from catdwgrd.sql to perform any actions
Rem      using PL/SQL packages needed to downgrade from the current 
Rem      11.2 patch release to prior 11.2 patch releases
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       pknaggs  08/15/12 - Proj 44284: Data Redaction downgrd from 11.2.0.4
Rem       qiwang   06/13/10 - LRG 4717421: LSBY downgrade to 11.2.0.1 from
Rem                           11.2.0.2
Rem       sbasu    06/02/10 - fix APPQOS Plan
Rem       sursridh 12/28/09 - Rename materialize_deferred_segments.
Rem       gngai    09/15/09 - bug 6976775: downgrade adr
Rem       sursridh 11/10/09 - Project 31043 downgrade path.
Rem      cdilling 8/03/09   Created

Rem *************************************************************************
Rem BEGIN f1102000.sql
Rem *************************************************************************

Rem=========================================================================
Rem BEGIN ADR downgrade items
Rem=========================================================================
Rem
Rem Downgrade ADR from 11.2 format to 11.1 format
Rem

begin
  sys.dbms_adr.downgrade_schema;
end;
/

Rem=========================================================================
Rem End ADR downgrade items
Rem=========================================================================

Rem=========================================================================
Rem BEGIN Proj 31043: Deferred Segment Creation for Partitioned Objects
Rem       Materialize segments for partitioned objects on downgrade
Rem=========================================================================

DECLARE
previous_version varchar2(30);

BEGIN
 SELECT prv_version INTO previous_version FROM registry$
 WHERE  cid = 'CATPROC';

 -- Call the materialize segments procedure only if the previous version was
 -- 11.2.0.1
 IF previous_version LIKE '11.2.0.1%' THEN 

   BEGIN
       sys.dbms_space_admin.materialize_deferred_with_opt(partitioned_only=>true);
   END;

 END IF;

END;
/


Rem=========================================================================
Rem END Proj 31043: Deferred Segment Creation for Partitioned Objects
Rem=========================================================================

Rem=========================================================================
Rem BEGIN WLM Downgrade
Rem=========================================================================
Rem
Rem Downgrade APPQOS Plan
Rem
update resource_plan_directive$ set mandatory = 0 
       where plan = 'APPQOS_PLAN' and 
            group_or_subplan in ('SYS_GROUP', 'OTHER_GROUPS',
                                  'ORA$DIAGNOSTICS', 'ORA$AUTOTASK_SUB_PLAN');
 
commit;

execute dbms_resource_manager.create_pending_area;
execute dbms_resource_manager.update_plan_directive(plan => 'APPQOS_PLAN', group_or_subplan => 'SYS_GROUP', new_mgmt_p1 => -1);
execute dbms_resource_manager.update_plan_directive(plan => 'APPQOS_PLAN', group_or_subplan => 'OTHER_GROUPS', new_mgmt_p3 => -1, new_mgmt_p1 => 90);
execute dbms_resource_manager.update_plan_directive(plan => 'APPQOS_PLAN', group_or_subplan => 'ORA$DIAGNOSTICS', new_mgmt_p3 => -1, new_mgmt_p1 => 5);
execute dbms_resource_manager.update_plan_directive(plan => 'APPQOS_PLAN', group_or_subplan => 'ORA$AUTOTASK_SUB_PLAN', new_mgmt_p3 => -1, new_mgmt_p1 => 5);
execute dbms_resource_manager.submit_pending_area;
update resource_plan_directive$ set mandatory = 1 
       where plan = 'APPQOS_PLAN' and 
             group_or_subplan in ('SYS_GROUP', 'OTHER_GROUPS',
                                  'ORA$DIAGNOSTICS', 'ORA$AUTOTASK_SUB_PLAN');
 
commit;

Rem=========================================================================
Rem BEGIN Logical Standby downgrade items
Rem=========================================================================
Rem
Rem LRG 4717421
Rem Convert Logical Standby Ckpt data from 11.2.0.2 format to 11.2.0.1 format
Rem

begin
  sys.dbms_logmnr_internal.agespill_11202to112;
end;
/

Rem=========================================================================
Rem End Logical Standby downgrade items
Rem=========================================================================

Rem=========================================================================
Rem BEGIN Data Redaction downgrade from 11.2.0.4 patch release
Rem=========================================================================

Rem Need to use the following PL/SQL loop to drop all Data Redaction policies,
Rem otherwise the "high" bits of the col$.property flags would remain behind,
Rem causing a mess in the lower release when any such column was referenced,
Rem since in the lower release the KGL callback support for reading in any
Rem such 64-bit col$.property flag values doesn't exist.  The col$.property
Rem flags are used by Data Redaction to speed up the search for redacted
Rem columns within the SQL, during the Semantic Analysis hard-parse phase.

BEGIN
  FOR data_redaction_policy IN
    (SELECT object_owner schema_name,
            object_name  object_name,
            policy_name  policy_name
       FROM redaction_policies)
  LOOP
    DBMS_REDACT.DROP_POLICY(
      OBJECT_SCHEMA => data_redaction_policy.schema_name
     ,OBJECT_NAME   => data_redaction_policy.object_name
     ,POLICY_NAME   => data_redaction_policy.policy_name);
  END LOOP;
END;
/

Rem=========================================================================
Rem END Data Redaction downgrade from 11.2.0.4 patch release
Rem=========================================================================

Rem *************************************************************************
Rem END f1102000.sql
Rem *************************************************************************
