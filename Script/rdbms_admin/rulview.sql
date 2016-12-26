Rem
Rem $Header: rulview.sql 25-jan-2007.06:15:56 ayalaman Exp $
Rem
Rem rulview.sql
Rem
Rem Copyright (c) 2004, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rulview.sql - Rule Manager catalog views
Rem
Rem    DESCRIPTION
Rem      This script defines the catalog views for Rule Manager.
Rem
Rem    NOTES
Rem      See documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    01/25/07 - table alias fix
Rem    ayalaman    03/28/05 - aggregate predicates in rule conditions 
Rem    ayalaman    12/05/05 - incomplete event structure 
Rem    ayalaman    09/13/05 - shared conditions for table aliases 
Rem    ayalaman    07/18/05 - db change notification events 
Rem    ayalaman    03/24/05 - duration at the primitive event level 
Rem    ayalaman    01/26/05 - shared primitive rule conditions 
Rem    ayalaman    01/31/05 - rlm4j dictionary for aliases 
Rem    ayalaman    09/03/04 - view for scheduled action errors 
Rem    ayalaman    05/19/04 - fix names from rule set to rule class 
Rem    ayalaman    05/10/04 - rename rule set to rule class 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    04/02/04 - Created
Rem

REM
REM Rule Manager catalog views
REM 
prompt .. creating Rule Manager catalog views

/****************** [USER/ALL/ADM]_RLMGR_EVENT_STRUCTS *********************/
---
---                       USER_RLMGR_EVENT_STRUCTS
--- 
create or replace view user_rlmgr_event_structs
 (EVENT_STRUCTURE_NAME, HAS_TIMESTAMP, IS_PRIMITIVE, TABLE_ALIAS_OF,
  CONDITIONS_TABLE) as
  select es.evst_name, decode(bitand(es.evst_prop, 1), 1, 'YES','NO'),
         decode(bitand(es.evst_prop, 2), 2, 'YES','NO'),
         es.evst_prcttls, es.evst_prct
  from rlm$eventstruct es
  where es.evst_owner = sys_context('USERENV', 'CURRENT_USER') and 
        bitand(es.evst_prop, 128) = 0;

create or replace public synonym USER_RLMGR_EVENT_STRUCTS 
  for exfsys.user_rlmgr_event_structs;

grant select on user_rlmgr_event_structs to public;

COMMENT ON TABLE user_rlmgr_event_structs IS 
'List of all the event structures in the current schema';

COMMENT ON COLUMN user_rlmgr_event_structs.event_structure_name IS 
'Name of the event structure';

COMMENT ON COLUMN user_rlmgr_event_structs.has_timestamp IS 
'Event structure has the event creation timestamp - YES/NO';

COMMENT ON COLUMN user_rlmgr_event_structs.is_primitive IS 
'Event structure is strictly for primitive events - YES/NO';

COMMENT ON COLUMN user_rlmgr_event_structs.table_alias_of IS
'Table name for a table alias primitive event';

COMMENT ON COLUMN user_rlmgr_event_structs.conditions_table IS 
'Name of the table that stores the sharable conditions for this event structure';

---
---                       ALL_RLMGR_EVENT_STRUCTS
--- 
create or replace view all_rlmgr_event_structs
 (EVENT_STRUCTURE_OWNER, EVENT_STRUCTURE_NAME, HAS_TIMESTAMP, IS_PRIMITIVE,
  TABLE_ALIAS_OF, CONDITIONS_TABLE)
  as select evst_owner, evst_name, 
         decode(bitand(evst_prop, 1), 1, 'YES','NO'),
         decode(bitand(evst_prop, 2), 2, 'YES','NO'),
         es.evst_prcttls, es.evst_prct
  from rlm$eventstruct es,  all_types ao
   where ao.owner = es.evst_owner and ao.type_name = es.evst_name and
         bitand(es.evst_prop, 128) = 0;

create or replace public synonym ALL_RLMGR_EVENT_STRUCTS 
  for exfsys.all_rlmgr_event_structs;

grant select on all_rlmgr_event_structs to public;

COMMENT ON TABLE all_rlmgr_event_structs IS 
'List of all the event structures in the current schema';

COMMENT ON COLUMN all_rlmgr_event_structs.event_structure_owner IS 
'Owner of the event structure';

COMMENT ON COLUMN all_rlmgr_event_structs.event_structure_name IS 
'Name of the event structure';

COMMENT ON COLUMN all_rlmgr_event_structs.has_timestamp IS 
'Event structure has the event creation timestamp - YES/NO';

COMMENT ON COLUMN all_rlmgr_event_structs.is_primitive IS 
'Event structure is strictly for primitive events - YES/NO';

COMMENT ON COLUMN all_rlmgr_event_structs.table_alias_of IS
'Table name for a table alias primitive event';

COMMENT ON COLUMN all_rlmgr_event_structs.conditions_table IS 
'Name of the table that stores the sharable conditions for this event structure';

---
---                       ADM_RLMGR_EVENT_STRUCTS
--- 
create or replace view adm_rlmgr_event_structs
 (EVENT_STRUCTURE_OWNER, EVENT_STRUCTURE_NAME, HAS_TIMESTAMP, IS_PRIMITIVE,
   IS_INCOMPLETE, TABLE_ALIAS_OF, CONDITIONS_TABLE)
  as select evst_owner, evst_name, 
         decode(bitand(evst_prop, 1), 1, 'YES','NO'),
         decode(bitand(evst_prop, 2), 2, 'YES','NO'),
         decode(bitand(evst_prop, 128), 128, 'YES','NO'),
         es.evst_prcttls, evst_prct
  from rlm$eventstruct es;

/******************** [USER/ALL/ADM]_RLMGR_RULE_CLASSES ***********************/

---
---                        USER_RLMGR_RULE_CLASSES
---
create or replace view user_rlmgr_rule_classes 
 (RULE_CLASS_NAME, ACTION_CALLBACK, EVENT_STRUCTURE, RULE_CLASS_PACK,
   RCLS_RSLT_VIEW, IS_COMPOSITE, SEQUENCE_ENB, AUTOCOMMIT,
   CONSUMPTION, DURATION, ORDERING, EQUAL, DML_EVENTS, CNF_EVENTS)
   as select rset_name, action_cbk, rset_eventst, rset_pack,
      rset_rsltvw,
      decode(bitand(rset_prop, 4),4, 'YES', 'NO'),
      decode(bitand(rset_prop, 4),4, 
        decode(bitand(rset_prop, 8),8, 'YES', 'NO'), 'N/A'),        
      decode(bitand(rset_prop, 16),16, 'YES', 'NO'),
      decode(bitand(rset_prop, 32),32, 'EXCLUSIVE', 
             decode(bitand(rset_prop, 64),64, 'RULE','SHARED')),
      rset_durtcl, rset_ordrcl, rset_eqcls,
      decode(bitand(rset_prop, 128), 128, 'INS',
             decode(bitand(rset_prop, 256), 256, 'INS/UPD',
             decode(bitand(rset_prop, 512), 512, 'INS/UPD/DEL', 'N/A'))),
      decode(bitand(rset_prop, 1024), 1024, 'INS',
             decode(bitand(rset_prop, 2048), 2048, 'INS/UPD',
             decode(bitand(rset_prop, 4096), 4096, 'INS/UPD/DEL', 'N/A')))
    from rlm$ruleset where 
    rset_owner = sys_context('USERENV', 'CURRENT_USER');

create or replace public synonym USER_RLMGR_RULE_CLASSES 
  for exfsys.user_rlmgr_rule_classes;

grant select on USER_RLMGR_RULE_CLASSES to public;

COMMENT ON TABLE user_rlmgr_rule_classes IS 
'List of all the rule classes in the current schema';

COMMENT ON COLUMN user_rlmgr_rule_classes.rule_class_name IS 
'Name of the rule class';

COMMENT ON COLUMN user_rlmgr_rule_classes.action_callback IS 
'The procedure configured as action callback for the rule class';

COMMENT ON COLUMN user_rlmgr_rule_classes.event_structure IS 
'The event structure used for the rule class';

COMMENT ON COLUMN user_rlmgr_rule_classes.rule_class_pack IS 
'Name of the package implementing the rule class cursors (internal)';

COMMENT ON COLUMN user_rlmgr_rule_classes.rcls_rslt_view IS 
'View to display the matching events and rules for the current session';

COMMENT ON COLUMN user_rlmgr_rule_classes.is_composite IS
'YES if the rules class is configured for composite events';

COMMENT ON COLUMN user_rlmgr_rule_classes.sequence_enb IS
'YES if the rules class is enabled for rule conditions with sequencing';

COMMENT ON COLUMN user_rlmgr_rule_classes.autocommit IS
'YES if the rules class is configured for auto-commiting events and rules';

COMMENT ON COLUMN user_rlmgr_rule_classes.consumption IS 
'Default Consumption policy for the events in the rule class: EXCLUSIVE/SHARED';

COMMENT ON COLUMN user_rlmgr_rule_classes.duration IS 
'Default Duration policy of the primitive events';

COMMENT ON COLUMN user_rlmgr_rule_classes.ordering IS 
'Ordering clause used for conflict resolution among matching rules and
events'; 

COMMENT ON COLUMN user_rlmgr_rule_classes.dml_events IS 
'Types of DML operations enabled for event management';

COMMENT ON COLUMN user_rlmgr_rule_classes.cnf_events IS 
'Types of Change Notifications enabled for event management';

---
---                    ALL_RLMGR_RULE_CLASSES
--- (use the rule class privileges table to list all rule classes)
---
create or replace view all_rlmgr_rule_classes
 (RULE_CLASS_OWNER, RULE_CLASS_NAME, EVENT_STRUCTURE, ACTION_CALLBACK,
   RULE_CLASS_PACK, RCLS_RSLT_TABLE, RCLS_RSLT_VIEW, IS_COMPOSITE,
   SEQUENCE_ENB, AUTOCOMMIT, CONSUMPTION, DURATION, ORDERING, EQUAL,
   DML_EVENTS, CNF_EVENTS, PRIM_EXPR_TABLE, PRIM_EVENTS_TABLE, PRIM_RESULTS_TABLE) as
  select rset_owner, rset_name, rset_eventst, action_cbk, rset_pack, 
     rset_rslttab, rset_rsltvw,
     decode(bitand(rset_prop, 4),4, 'YES', 'NO'),
     decode(bitand(rset_prop, 4),4, 
        decode(bitand(rset_prop, 8),8, 'YES', 'NO'), 'N/A'),        
     decode(bitand(rset_prop, 16),16, 'YES', 'NO'),
     decode(bitand(rset_prop, 32),32, 'EXCLUSIVE', 
             decode(bitand(rset_prop, 64),64, 'RULE','SHARED')),
     rset_durtcl, rset_ordrcl, rset_eqcls, 
     decode(bitand(rset_prop, 128), 128, 'INS',
             decode(bitand(rset_prop, 256), 256, 'INS/UPD',
             decode(bitand(rset_prop, 512), 512, 'INS/UPD/DEL', 'N/A'))),
      decode(bitand(rset_prop, 1024), 1024, 'INS',
             decode(bitand(rset_prop, 2048), 2048, 'INS/UPD',
             decode(bitand(rset_prop, 4096), 4096, 'INS/UPD/DEL', 'N/A'))),
     rset_prmexpt, rset_prmobjt, rset_prmrslt
  from rlm$ruleset rs where rs.rset_owner = 
                           sys_context('USERENV', 'CURRENT_USER') or
    ((rs.rset_owner, rs.rset_name) IN 
     (select rsp.rset_owner, rsp.rset_name from rlm$rulesetprivs rsp
         where prv_grantee = sys_context('USERENV', 'CURRENT_USER'))) or
     exists (select 1 from user_role_privs where granted_role = 'DBA');

create or replace public synonym ALL_RLMGR_RULE_CLASSES 
    for exfsys.all_rlmgr_rule_classes;

grant select on ALL_RLMGR_RULE_CLASSES to public;

COMMENT ON TABLE all_rlmgr_rule_classes IS 
'List of all the rule classes accessible to the user';

COMMENT ON COLUMN all_rlmgr_rule_classes.rule_class_owner IS 
'Owner of the rule class';

COMMENT ON COLUMN all_rlmgr_rule_classes.rule_class_name IS 
'Name of the rule class';

COMMENT ON COLUMN all_rlmgr_rule_classes.action_callback IS 
'The procedure configured as action callback for the rule class';

COMMENT ON COLUMN all_rlmgr_rule_classes.event_structure IS 
'The event structure used for the rule class';

COMMENT ON COLUMN all_rlmgr_rule_classes.rule_class_pack IS 
'Name of the package implementing the rule class cursors (internal)';

COMMENT ON COLUMN all_rlmgr_rule_classes.is_composite IS
'YES if the rules class is configured for composite events';

COMMENT ON COLUMN all_rlmgr_rule_classes.rcls_rslt_table IS
'Temporary table storing the results from the current session';

COMMENT ON COLUMN all_rlmgr_rule_classes.rcls_rslt_view IS 
'View to display the matching events and rules for the current session';

COMMENT ON COLUMN all_rlmgr_rule_classes.sequence_enb IS
'YES if the rules class is enabled for rule conditions with sequencing';

COMMENT ON COLUMN all_rlmgr_rule_classes.autocommit IS
'YES if the rules class is configured for auto-commiting events and rules';

COMMENT ON COLUMN all_rlmgr_rule_classes.consumption IS 
'Default Consumption policy for the events in the rule class: EXCLUSIVE/SHARED';

COMMENT ON COLUMN all_rlmgr_rule_classes.duration IS 
'Default Duration policy of the primitive events';

COMMENT ON COLUMN all_rlmgr_rule_classes.ordering IS 
'Ordering clause used for conflict resolution among matching rules and
events'; 

COMMENT ON COLUMN all_rlmgr_rule_classes.prim_expr_table IS 
'Name of the table storing conditional expressions for primitive events';

COMMENT ON COLUMN all_rlmgr_rule_classes.prim_events_table IS 
'Name of the table storing primitive events';

COMMENT ON COLUMN all_rlmgr_rule_classes.prim_results_table IS 
'Name of the table storing incremental results';

COMMENT ON COLUMN all_rlmgr_rule_classes.dml_events IS 
'Types of DML operations enabled for event management';

COMMENT ON COLUMN all_rlmgr_rule_classes.cnf_events IS 
'Types of Change Notifications enabled for event management';

---
---                        ADM_RLMGR_RULE_CLASSES
---
create or replace view adm_rlmgr_rule_classes 
 (RULE_CLASS_OWNER, RULE_CLASS_NAME, EVENT_STRUCTURE, ACTION_CALLBACK,
  RULE_CLASS_PACK, IS_INDEXED, RCLS_RSLT_TABLE, RCLS_RSLT_VIEW, IS_COMPOSITE, 
  SEQUENCE_ENB, AUTOCOMMIT, CONSUMPTION, DURATION, ORDERING, EQUAL, 
  DML_EVENTS, CNF_EVENTS, STORAGE,  PRIM_EXPR_TABLE, PRIM_EVENTS_TABLE,
  PRIM_RESULTS_TABLE)
   as select rset_owner, rset_name, rset_eventst, action_cbk, rset_pack, 
    decode(bitand(rset_prop, 1),1, 'YES', 'NO'),
    rset_rslttab, rset_rsltvw, decode(bitand(rset_prop, 4),4, 'YES', 'NO'),
    decode(bitand(rset_prop, 4),4, 
        decode(bitand(rset_prop, 8),8, 'YES', 'NO'), 'N/A'),       
    decode(bitand(rset_prop, 16),16, 'YES', 'NO'),
    decode(bitand(rset_prop, 32),32, 'EXCLUSIVE', 
             decode(bitand(rset_prop, 64),64, 'RULE','SHARED')),
    rset_durtcl, rset_ordrcl, rset_eqcls,
    decode(bitand(rset_prop, 128), 128, 'INS',
             decode(bitand(rset_prop, 256), 256, 'INS/UPD',
             decode(bitand(rset_prop, 512), 512, 'INS/UPD/DEL', 'N/A'))),
      decode(bitand(rset_prop, 1024), 1024, 'INS',
             decode(bitand(rset_prop, 2048), 2048, 'INS/UPD',
             decode(bitand(rset_prop, 4096), 4096, 'INS/UPD/DEL', 'N/A'))),
    rset_stgcls, rset_prmexpt, rset_prmobjt, rset_prmrslt
 from  rlm$ruleset; 
/

/****************** [USER/ALL/ADM]_RLMGR_RULE_CLASS_STATUS *******************/
---
---                      USER_RLMGR_RULE_CLASS_STATUS
---
create or replace view USER_RLMGR_RULE_CLASS_STATUS
  (RULE_CLASS_NAME, STATUS, STATUS_CODE, NEXT_OPERATION) as
 select rs.rset_name, st.rset_stdesc, st.rset_stcode, st.rset_stnext
 from rlm$ruleset rs, rlm$rulesetstcode st where 
    rs.rset_owner = sys_context('USERENV', 'CURRENT_USER') and
    rs.rset_status = st.rset_stcode; 

create or replace public synonym USER_RLMGR_RULE_CLASS_STATUS
    for exfsys.user_rlmgr_rule_class_status;

grant select on USER_RLMGR_RULE_CLASS_STATUS to public;

COMMENT ON TABLE user_rlmgr_rule_class_status IS 
'View used to track the progress of rule class creation';

COMMENT ON COLUMN user_rlmgr_rule_class_status.rule_class_name IS 
'Name of the rule class';

COMMENT ON COLUMN user_rlmgr_rule_class_status.status IS 
'Current status of the rule class';

COMMENT ON COLUMN user_rlmgr_rule_class_status.status_code IS 
'Internal code for the status';

COMMENT ON COLUMN user_rlmgr_rule_class_status.next_operation IS 
'Next operation performed on the rule class';

---
---                      ALL_RLMGR_RULE_CLASS_STATUS
---
create or replace view ALL_RLMGR_RULE_CLASS_STATUS
  (RULE_CLASS_OWNER, RULE_CLASS_NAME, STATUS, NEXT_OPERATION) as
 select rs.rset_owner, rs.rset_name, st.rset_stdesc, st.rset_stnext
 from rlm$ruleset rs, rlm$rulesetstcode st where 
    rs.rset_status = st.rset_stcode and 
    (rs.rset_owner = sys_context('USERENV', 'CURRENT_USER') or
    ((rs.rset_owner, rs.rset_name) IN 
     (select rsp.rset_owner, rsp.rset_name from rlm$rulesetprivs rsp
         where prv_grantee = sys_context('USERENV', 'CURRENT_USER'))) or
     exists (select 1 from user_role_privs where granted_role = 'DBA'));

create or replace public synonym ALL_RLMGR_RULE_CLASS_STATUS
    for exfsys.all_rlmgr_rule_class_status;

grant select on ALL_RLMGR_RULE_CLASS_STATUS to public;

COMMENT ON TABLE all_rlmgr_rule_class_status IS 
'View used to track the progress of rule class creation';

COMMENT ON COLUMN all_rlmgr_rule_class_status.rule_class_owner IS 
'Owner of the rule class';

COMMENT ON COLUMN all_rlmgr_rule_class_status.rule_class_name IS 
'Name of the rule class';

COMMENT ON COLUMN all_rlmgr_rule_class_status.status IS 
'Current status of the rule class';

COMMENT ON COLUMN all_rlmgr_rule_class_status.next_operation IS 
'Next operation performed on the rule class';

---
---                      ADM_RLMGR_RULE_CLASS_STATUS
---
create or replace view ADM_RLMGR_RULE_CLASS_STATUS
  (RULE_CLASS_NAME, STATUS, STATUS_CODE, NEXT_OPERATION) as
 select rs.rset_name, st.rset_stdesc, st.rset_stcode, st.rset_stnext
 from rlm$ruleset rs, rlm$rulesetstcode st
 where rs.rset_status = st.rset_stcode; 

create or replace view ALL_RLMGR_RULE_CLASS_OPCODES
  (OP_CODE, COMPLETED_OP, NEXT_OPERATION) as 
select rset_stcode, rset_stdesc, rset_stnext from rlm$rulesetstcode; 

grant select on ALL_RLMGR_RULE_CLASS_OPCODES to public;

/******************** [USER/ALL/ADM]_RLMGR_PRIVILEGES **********************/
---
---                       USER_RLMGR_PRIVILEGES
---
create or replace view USER_RLMGR_PRIVILEGES
  (RULE_CLASS_OWNER, RULE_CLASS_NAME, GRANTEE, PRCS_RULE_PRIV, ADD_RULE_PRIV,
   DEL_RULE_PRIV) as
  select rset_owner, rset_name, prv_grantee, prv_prcrule, prv_addrule,
         prv_delrule
  from rlm$rulesetprivs where  prv_grantee = 'PUBLIC' or 
    prv_grantee = sys_context('USERENV', 'CURRENT_USER') or
    rset_owner = sys_context('USERENV', 'CURRENT_USER');

create or replace public synonym USER_RLMGR_PRIVILEGES for
        exfsys.USER_RLMGR_PRIVILEGES; 

grant select on USER_RLMGR_PRIVILEGES to public;

COMMENT ON TABLE user_rlmgr_privileges IS 
'Privileges for the Rule classes';

COMMENT ON COLUMN user_rlmgr_privileges.rule_class_owner IS 
'Owner of the rule class'; 

COMMENT ON COLUMN user_rlmgr_privileges.rule_class_name IS
'Name of the rule class';

COMMENT ON COLUMN user_rlmgr_privileges.grantee IS
'Grantee of the privilege. Current user of PUBLIC';

COMMENT ON COLUMN user_rlmgr_privileges.prcs_rule_priv IS 
'Current user''s privilege to execute/process rules';

COMMENT ON COLUMN user_rlmgr_privileges.add_rule_priv IS 
'Current user''s privilege to add new rules to the rule class';

COMMENT ON COLUMN user_rlmgr_privileges.del_rule_priv IS 
'Current user''s privilege to delete rules';

---
---                 ADM_RLMGR_PRIVILEGES
---
create or replace view ADM_RLMGR_PRIVILEGES
  (RULE_CLASS_OWNER, RULE_CLASS_NAME, GRANTEE, PRCS_RULE_PRIV, ADD_RULE_PRIV,
   DEL_RULE_PRIV) as
  select rset_owner, rset_name, prv_grantee, prv_prcrule, prv_addrule,
         prv_delrule 
  from rlm$rulesetprivs;

create or replace public synonym ADM_RLMGR_PRIVILEGES for
        exfsys.ADM_RLMGR_PRIVILEGES; 

grant select on ADM_RLMGR_PRIVILEGES to public;

COMMENT ON TABLE adm_rlmgr_privileges IS 
'Privileges for the Rule class';

COMMENT ON COLUMN adm_rlmgr_privileges.rule_class_owner IS 
'Owner of the rule class'; 

COMMENT ON COLUMN adm_rlmgr_privileges.rule_class_name IS
'Name of the rule class';

COMMENT ON COLUMN adm_rlmgr_privileges.grantee IS
'Grantee of the privilege';

COMMENT ON COLUMN adm_rlmgr_privileges.prcs_rule_priv IS 
'Grantee''s privilege to execute/process rules';

COMMENT ON COLUMN adm_rlmgr_privileges.add_rule_priv IS 
'Grantee''s privilege to add new rules to the rule class';

COMMENT ON COLUMN adm_rlmgr_privileges.del_rule_priv IS 
'Grantee''s privilege to delete rules';

/**************** [USER/ALL/ADM]_RLMGR_COMPRCLS_PROPERTIES *****************/
---
---            USER_RLMGR_COMPRCLS_PROPERTIES
---
create or replace view USER_RLMGR_COMPRCLS_PROPERTIES 
  (RULE_CLASS_NAME, PRIM_EVENT, 
   PRIM_EVENT_STRUCT, HAS_CRTTIME_ATTR, CONSUMPTION, TABLE_ALIAS_OF,
   DURATION, COLLECTION_ENB, GROUPBY_ATTRIBUTES)
as select crs.rset_name, crs.prim_attr, crs.prim_asetnm,
      decode(bitand(pem.prim_evttflgs, 1), 1, 'YES', 'NO'), 
      decode(bitand(pem.prim_evttflgs, 32),32, 'EXCLUSIVE','SHARED'),
      decode(pem.talstabonr, null, null, 
              '"'||pem.talstabonr||'"."'||pem.talstabnm||'"'),
      pem.prim_evdurcls,
      decode(bitand(pem.prim_evttflgs, 128), 128, 'YES','NO'), pem.grpbyattrs
 from rlm$rsprimevents crs, rlm$primevttypemap pem 
 where crs.rset_owner = sys_context('USERENV', 'CURRENT_USER') and 
       crs.rset_owner = pem.rset_owner and crs.rset_name = pem.rset_name 
       and crs.prim_asetnm = pem.prim_evntst; 

create or replace public synonym USER_RLMGR_COMPRCLS_PROPERTIES for 
       exfsys.USER_RLMGR_COMPRCLS_PROPERTIES;

grant select on USER_RLMGR_COMPRCLS_PROPERTIES to public;

COMMENT ON TABLE user_rlmgr_comprcls_properties IS 
'List of primitive events configured for a rule class and their properties';

COMMENT ON COLUMN user_rlmgr_comprcls_properties.rule_class_name IS 
'Name of the rule class configured for composite rules';

COMMENT ON COLUMN user_rlmgr_comprcls_properties.prim_event IS 
'Name of the primitive event in the composite event';

COMMENT ON COLUMN user_rlmgr_comprcls_properties.prim_event_struct IS 
'Name of the primitive event structure (object type)';

COMMENT ON COLUMN user_rlmgr_comprcls_properties.has_crttime_attr IS 
'YES if the primitive event structure has the RLM$CRTTIME attribute';

COMMENT ON COLUMN user_rlmgr_comprcls_properties.consumption IS 
'Consumption policy for the primitive event: EXCLUSIVE/SHARED';

COMMENT ON COLUMN user_rlmgr_comprcls_properties.table_alias_of IS 
'Table name for a table alias primitive event';

COMMENT ON COLUMN user_rlmgr_comprcls_properties.duration IS 
'Duration policy for the primitive event';

COMMENT ON COLUMN user_rlmgr_comprcls_properties.collection_enb IS 
'Is the primitive event enabled for collections?';

COMMENT ON COLUMN user_rlmgr_comprcls_properties.groupby_attributes IS 
'Event attributes that may be used for GROUPBY clauses';

---
---            ALL_RLMGR_COMPRCLS_PROPERTIES 
---
create or replace view ALL_RLMGR_COMPRCLS_PROPERTIES 
  (RULE_CLASS_OWNER, RULE_CLASS_NAME, PRIM_EVENT, 
   PRIM_EVENT_STRUCT, HAS_CRTTIME_ATTR, CONSUMPTION, TABLE_ALIAS_OF, 
   DURATION, COLLECTION_ENB, COLLECTION_TAB_NAME, GROUPBY_ATTRIBUTES)
 as select crs.rset_owner, crs.rset_name, crs.prim_attr, crs.prim_asetnm,
      decode(bitand(pem.prim_evttflgs, 1), 1, 'YES', 'NO'), 
      decode(bitand(pem.prim_evttflgs, 32),32, 'EXCLUSIVE','SHARED'),
      decode(pem.talstabonr, null, null, 
           '"'||pem.talstabonr||'"."'||pem.talstabnm||'"'),
     pem.prim_evdurcls, 
     decode(bitand(pem.prim_evttflgs, 128), 128, 'YES','NO'), 
     pem.collcttab, pem.grpbyattrs
 from rlm$rsprimevents crs, rlm$primevttypemap pem 
   where (crs.rset_owner = sys_context('USERENV', 'CURRENT_USER') or
       ((crs.rset_owner, crs.rset_name) IN 
       (select rsp.rset_owner, rsp.rset_name from rlm$rulesetprivs rsp
          where prv_grantee = sys_context('USERENV', 'CURRENT_USER'))) or
       exists (select 1 from user_role_privs where granted_role = 'DBA')) 
       and crs.rset_owner = pem.rset_owner and crs.rset_name = pem.rset_name 
       and crs.prim_asetnm = pem.prim_evntst;

create or replace public synonym ALL_RLMGR_COMPRCLS_PROPERTIES for 
       exfsys.ALL_RLMGR_COMPRCLS_PROPERTIES;

grant select on ALL_RLMGR_COMPRCLS_PROPERTIES to public;

COMMENT ON TABLE all_rlmgr_comprcls_properties IS 
'List of primitive events configured for a rule class and their properties';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.rule_class_owner IS 
'Owner of the rule class';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.rule_class_name IS 
'Name of the rule class configured for composite rules';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.prim_event IS 
'Name of the primitive event in the composite event';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.prim_event_struct IS 
'Name of the primitive event structure (object type)';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.has_crttime_attr IS 
'YES if the primitive event structure has the RLM$CRTTIME attribute';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.consumption IS 
'Consumption policy for the primitive event: EXCLUSIVE/SHARED';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.table_alias_of IS 
'Table name for the a table alias primitive event';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.duration IS 
'Duration policy for the primitive event';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.collection_enb IS 
'Is the primitive event enabled for collections?';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.collection_tab_name IS 
'Internal table storing the event collection information';

COMMENT ON COLUMN all_rlmgr_comprcls_properties.groupby_attributes IS 
'Event attributes that may be used for GROUPBY clauses';

---
---           ADM_RLMGR_COMPRCLS_PROPERTIES
---
create or replace view ADM_RLMGR_COMPRCLS_PROPERTIES 
  (RULE_CLASS_OWNER, RULE_CLASS_NAME, PRIM_EVENT, 
   PRIM_EVENT_STRUCT, HAS_CRTTIME_ATTR, CONSUMPTION, TABLE_ALIAS_OF,
   DURATION, COLLECTION_ENB, COLLECTION_TAB_NAME, GROUPBY_ATTRIBUTES)
 as select crs.rset_owner, crs.rset_name, crs.prim_attr, crs.prim_asetnm,
      decode(bitand(pem.prim_evttflgs, 1), 1, 'YES', 'NO'), 
      decode(bitand(pem.prim_evttflgs, 32),32, 'EXCLUSIVE','SHARED'),
      '"'||pem.talstabonr||'"."'||pem.talstabnm||'"',
      decode(pem.prim_durmin, -1, 'TRANSACTION', -2, 'SESSION', -3, 'CALL', 
             pem.prim_evdurcls),
      decode(bitand(pem.prim_evttflgs, 128), 128, 'YES','NO'),
        pem.collcttab, pem.grpbyattrs
 from rlm$rsprimevents crs, rlm$primevttypemap pem 
 where  crs.rset_owner = pem.rset_owner and crs.rset_name = pem.rset_name 
       and crs.prim_asetnm = pem.prim_evntst; 

---
---            USER_RLMGR_ACTION_ERRORS
---
create or replace view USER_RLMGR_ACTION_ERRORS 
  (RULE_CLASS_NAME, SCHEDULED_TIME, ORA_ERROR) as 
  select rset_name, actschat, oraerrcde from rlm$schacterrs
  where rset_owner = SYS_CONTEXT('USERENV', 'CURRENT_USER');

COMMENT ON TABLE user_rlmgr_action_errors IS 
'Table listing the errors encountered during action execution';

COMMENT ON COLUMN user_rlmgr_action_errors.rule_class_name IS 
'Name of the rule class producing the errors during action execution';

COMMENT ON COLUMN user_rlmgr_action_errors.scheduled_time IS 
'Time at which the action was scheduled to run.';

COMMENT ON COLUMN user_rlmgr_action_errors.ora_error IS 
'Code for the error encountered : ORA-XXXXX';

grant select on exfsys.USER_RLMGR_ACTION_ERRORS to public;

---
---            ALL_RLMGR_ACTION_ERRORS
---
create or replace view ALL_RLMGR_ACTION_ERRORS 
  (RULE_CLASS_OWNER, RULE_CLASS_NAME, SCHEDULED_TIME, ORA_ERROR) as
  select rset_owner, rset_name, actschat, oraerrcde from rlm$schacterrs rs
  where
    rs.rset_owner = sys_context('USERENV', 'CURRENT_USER') or
    exists (select 1 from user_role_privs where granted_role = 'DBA') or
    ((rs.rset_owner, rs.rset_name) IN
     (select rsp.rset_owner, rsp.rset_name from rlm$rulesetprivs rsp
         where prv_grantee = sys_context('USERENV', 'CURRENT_USER')));

COMMENT ON TABLE all_rlmgr_action_errors IS 
'Table listing the errors encountered during action execution';

COMMENT ON COLUMN all_rlmgr_action_errors.rule_class_owner IS 
'Owner of the rule class';

COMMENT ON COLUMN all_rlmgr_action_errors.rule_class_name IS 
'Name of the rule class producing the errors during action execution';

COMMENT ON COLUMN all_rlmgr_action_errors.scheduled_time IS 
'Time at which the action was scheduled to run.';

COMMENT ON COLUMN all_rlmgr_action_errors.ora_error IS 
'Code for the error encountered : ORA-XXXXX';

grant select on exfsys.ALL_RLMGR_ACTION_ERRORS to public;

---
---            ADM_RLMGR_ACTION_ERRORS
---
create or replace view ADM_RLMGR_ACTION_ERRORS
  (RULE_CLASS_OWNER, RULE_CLASS_NAME, SCHEDULED_TIME, ORA_ERROR) as
  select rset_owner, rset_name, actschat, oraerrcde from rlm$schacterrs; 

/***************************************************************************/
/***           RLM4J : Rule Manager for Java Catalog views               ***/ 
/***************************************************************************/

CREATE OR REPLACE VIEW user_rlm4j_evtst 
  (DB_OWNER, EVTST_NAME, JAVA_PACKAGE, JAVA_CLASS, IS_COMPOSITE)
  AS
  SELECT evt.dbowner, evt.dbesname, evt.javapck, evt.javacls,
         decode(evt.estflags, 1, 'YES','NO')
  FROM rlm4j$evtstructs evt
  where evt.dbowner = SYS_CONTEXT('USERENV', 'CURRENT_USER');

GRANT SELECT ON exfsys.user_rlm4j_evtst TO PUBLIC;

/**************** [USER/ALL/ADM]_RLM4J_EVENT_STRUCTS ***********************/
-- Currently only 'user' is considered

CREATE OR REPLACE PUBLIC SYNONYM USER_RLM4J_EVENT_STRUCTS
    for exfsys.user_rlm4j_evtst;

GRANT SELECT ON USER_RLM4J_EVENT_STRUCTS TO PUBLIC;

/******************* [USER/ALL/ADM]_RLM4J_RULE_CLASSES ************************/

CREATE OR REPLACE VIEW user_rlm4j_ruleclasses
  (DB_OWNER, RULECLASS_NAME, EVTST_NAME, JAVA_PACKAGE, JAVA_CLASS)
  AS
  SELECT rle.dbowner, rle.dbrsname, rle.dbevsnm, rle.javapck,
    rle.javacls
  FROM rlm4j$ruleset rle
  where rle.dbowner = SYS_CONTEXT('USERENV', 'CURRENT_USER');

GRANT SELECT ON exfsys.user_rlm4j_ruleclasses TO PUBLIC;

CREATE OR REPLACE PUBLIC SYNONYM USER_RLM4J_RULE_CLASSES
    FOR exfsys.user_rlm4j_ruleclasses; 

GRANT SELECT ON USER_RLM4J_RULE_CLASSES to public;

/******************** USER_RLM4J_ATTRIBUTE_ALIASES ****************************/

CREATE OR REPLACE VIEW user_rlm4j_attribute_aliases 
  (EVENT_STRUCT, ATTRIBUTE_ALIAS, ATTRIBUTE_EXPRESSION, ALIAS_TYPE) 
  AS
  SELECT esname, esattals, esattexp, 
          decode(bitand(aliastype, 1), 1, 'PREDICATE', 'LHS') 
  FROM  rlm4j$attraliases
  WHERE esowner =  SYS_CONTEXT('USERENV', 'CURRENT_USER');

GRANT SELECT ON exfsys.user_rlm4j_attribute_aliases TO PUBLIC;

-- synonym is not needed --

GRANT SELECT ON EXFSYS.USER_RLM4J_ATTRIBUTE_ALIASES to public;
