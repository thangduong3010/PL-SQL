Rem
Rem $Header: catstrm.sql 11-nov-2006.15:42:25 jinwu Exp $
Rem
Rem catstrm.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catstrm.sql - STReams Message catalog views
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jinwu       11/09/06 - add Streams Message catalog views
Rem    jinwu       11/09/06 - Created
Rem

-------------------------------------------------------------------------------
-- Views on streams message consumers
-------------------------------------------------------------------------------

-- Private view select to all columns from streams$_message_consumers.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_STREAMS_MESSAGE_CONSUMERS"
as select * from sys.streams$_message_consumers
/
grant select on "_DBA_STREAMS_MESSAGE_CONSUMERS" to exp_full_database
/

-- Private view to list information about message notifications associated
-- with Streams message consumers. This view is used by export.
create or replace view "_DBA_STREAMS_MSG_NOTIFICATIONS"
  (STREAMS_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME, RULE_SET_OWNER,
   NEGATIVE_RULE_SET_NAME, NEGATIVE_RULE_SET_OWNER, NOTIFICATION_TYPE,
   NOTIFICATION_ACTION, USER_CONTEXT, CONTEXT_SIZE, ANY_CONTEXT, CONTEXT_TYPE)
as
select c.streams_name, c.queue_name, c.queue_owner, c.rset_name, c.rset_owner,
       c.neg_rset_name, c.neg_rset_owner,
       decode(UPPER(substr(r.location_name,1,instr(r.location_name,'://') -1)),
              'PLSQL', 'PROCEDURE',
              'MAILTO', 'MAIL',
              'HTTP', 'HTTP'),
       substr(r.location_name, instr(r.location_name, '://') + 3),
       r.user_context, r.context_size, r.any_context, r.context_type
  from sys."_DBA_STREAMS_MESSAGE_CONSUMERS" c, sys.reg$ r
 where '"' ||c.queue_owner||'"."'||c.queue_name||'":"'||c.streams_name || '"'
       = r.subscription_name (+) 
   and NVL(r.namespace, 1) = 1
/
grant select on  "_DBA_STREAMS_MSG_NOTIFICATIONS" to exp_full_database
/

create or replace view DBA_STREAMS_MESSAGE_CONSUMERS
  (STREAMS_NAME, QUEUE_NAME, QUEUE_OWNER, RULE_SET_NAME, RULE_SET_OWNER,
   NEGATIVE_RULE_SET_NAME, NEGATIVE_RULE_SET_OWNER, NOTIFICATION_TYPE,
   NOTIFICATION_ACTION, NOTIFICATION_CONTEXT)
as
select streams_name, queue_name, queue_owner, rule_set_name, rule_set_owner,
       negative_rule_set_name, negative_rule_set_owner, notification_type,
       notification_action,
       decode(context_type,
              0, sys.anydata.ConvertRaw(user_context),
              1, any_context)
  from sys."_DBA_STREAMS_MSG_NOTIFICATIONS"
/

comment on table DBA_STREAMS_MESSAGE_CONSUMERS is
'Streams messaging consumers'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.STREAMS_NAME is
'Name of the consumer'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.QUEUE_NAME is
'Name of the queue'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.QUEUE_OWNER is
'Owner of the queue'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.RULE_SET_NAME is
'Name of the rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NEGATIVE_RULE_SET_NAME is
'Name of the negative rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_TYPE is
'Type of notification action: plsql/mailto/http'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_ACTION is
'Notification action'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_CONTEXT is
'Context for the notification action'
/
create or replace public synonym DBA_STREAMS_MESSAGE_CONSUMERS
  for DBA_STREAMS_MESSAGE_CONSUMERS
/
grant select on DBA_STREAMS_MESSAGE_CONSUMERS to select_catalog_role
/

----------------------------------------------------------------------------

-- View of streams message consumers
create or replace view ALL_STREAMS_MESSAGE_CONSUMERS
as
select c.*
  from dba_streams_message_consumers c, all_queues q
 where c.queue_name = q.name
   and c.queue_owner = q.owner
   and ((c.rule_set_owner is null and c.rule_set_name is null) or
        ((c.rule_set_owner, c.rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name
             from all_rule_sets r)))
   and ((c.negative_rule_set_owner is null and 
         c.negative_rule_set_name is null) or
        ((c.negative_rule_set_owner, c.negative_rule_set_name) in 
          (select r.rule_set_owner, r.rule_set_name 
             from all_rule_sets r)))
/

comment on table ALL_STREAMS_MESSAGE_CONSUMERS is
'Streams messaging consumers visible to the current user'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.STREAMS_NAME is
'Name of the consumer'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.QUEUE_NAME is
'Name of the queue'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.QUEUE_OWNER is
'Owner of the queue'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.RULE_SET_NAME is
'Name of the rule set'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.NEGATIVE_RULE_SET_NAME is
'Name of the negative rule set'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column DBA_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_TYPE is
'Type of notification action: plsql/mailto/http'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_ACTION is
'Notification action'
/
comment on column ALL_STREAMS_MESSAGE_CONSUMERS.NOTIFICATION_CONTEXT is
'Context for the notification action'
/
create or replace public synonym ALL_STREAMS_MESSAGE_CONSUMERS
  for ALL_STREAMS_MESSAGE_CONSUMERS
/
grant select on ALL_STREAMS_MESSAGE_CONSUMERS to public with grant option
/
