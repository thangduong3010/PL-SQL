Rem
Rem $Header: rdbms/admin/depsaq.sql /main/7 2009/04/10 14:22:09 xingjin Exp $
Rem
Rem depsaq.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      depsaq.sql - DEPendent objectS for AQ 
Rem
Rem    DESCRIPTION
Rem      
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    xingjin     03/25/09 - bug 8368685: add check to ensure package owner is SYS
Rem    sjanardh    04/03/08 - dba_queue_subscribers to show nondurable ones
Rem    gagarg      09/28/07 - Add rule column in xxx_queue_subscriber views
Rem    jawilson    11/29/06 - add kwqa_3gl_SetRegistrationName
Rem    jhan        10/12/06 - Move back the declaration of dbms_aqadm_syscalls
Rem    sjanardh    06/07/06 - Add modification timestamp parameter in 3gl 
Rem                           procedures 
Rem    rburns      05/19/06 - for dependent AQ functions and views 
Rem    rburns      05/19/06 - Created
Rem

 /* Bug 6488226: For 8.0 style queues, rule_name is NULL as they have no rule
 * condition. For newstyle queues, get rule_name from _S table */
CREATE OR REPLACE FUNCTION aq$_get_subscribers (
  queue_schema   IN  VARCHAR2,
  queue_name     IN  VARCHAR2,
  queue_table    IN  VARCHAR2,
  deq_user       IN  VARCHAR2,
  queue_id       IN  BINARY_INTEGER,
  qtab_flags     IN  BINARY_INTEGER) RETURN sys.aq$_subscriber_t PIPELINED IS

  sub80          aq$_subscribers;
  sel_txt        VARCHAR2(1000);
  type rt is	 REF CURSOR;
  sqlrc		 rt;		  	 	-- ref cursor for sql statement
  sub_name       VARCHAR2(30);
  sub_addr       VARCHAR2(1024);
  sub_proto      NUMBER;
  sub_trans      VARCHAR2(61);
  sub_type       NUMBER;
  sub_rule       VARCHAR2(30); /*bug 648822: add rule_name for the subscriber*/
BEGIN
  IF bitand(qtab_flags, 8) = 0 THEN 
    -- 8.0 style queue, return all subscribers in aq$_queues
    select subscribers INTO sub80 FROM system.aq$_queues 
    where  eventid = queue_id;

    IF sub80 IS NOT NULL and sub80.count > 0 THEN
      FOR i IN sub80.first .. sub80.last LOOP
       PIPE ROW (aq$_subscriber(sub80(i).name, sub80(i).address, 
                 sub80(i).protocol, null, 65, null)); 
      END LOOP;
    END  IF;
  ElSIF bitand(qtab_flags, 4096) = 4096 and deq_user IS NOT NULL THEN
    -- 8.1 style secure queue, join with agent mapping table
    sel_txt := 'select qs.name, qs.address, qs.protocol, qs.trans_name, '
               || ' qs.subscriber_type,  qs.rule_name from '
               || 'dba_aq_agent_privs dp, ' 
               || dbms_assert.enquote_name('"'||queue_schema||'"') || '.' 
               || dbms_assert.enquote_name('"AQ$_' || queue_table || '_S"') 
               || ' qs where dp.db_username = :1 and ' ||
               'dp.agent_name = qs.name and bitand(qs.subscriber_type, 1)=1'
               || ' and qs.queue_name = :2';
    OPEN sqlrc FOR sel_txt using deq_user, queue_name;
    LOOP
      FETCH sqlrc INTO sub_name, sub_addr, sub_proto,sub_trans, sub_type, sub_rule;
      EXIT WHEN sqlrc%NOTFOUND;
      PIPE ROW (aq$_subscriber(sub_name, sub_addr, sub_proto, sub_trans,
                               sub_type, sub_rule));
    END LOOP; 
  ELSE
    -- 8.1 style normal queue, return all subscribers
    sel_txt := 'select name, address, protocol, trans_name, ' ||
               'subscriber_type, rule_name from ' || 
               dbms_assert.enquote_name('"'||queue_schema||'"') || '.' || 
               dbms_assert.enquote_name('"AQ$_' || queue_table || '_S"') || 
               ' where ' ||
               'bitand(subscriber_type, 1)=1 and queue_name = :1';
    OPEN sqlrc FOR sel_txt using queue_name;
    LOOP
      FETCH sqlrc INTO sub_name, sub_addr, sub_proto, sub_trans, sub_type, sub_rule;
      EXIT WHEN sqlrc%NOTFOUND;
      PIPE ROW (aq$_subscriber(sub_name, sub_addr, sub_proto, sub_trans,  sub_type, sub_rule));
    END LOOP; 
  END IF;
  RETURN;
END;
/



-- CAUTION: the table function used in [USER_|ALL_|DBA_]QUEUE_SUBSCRIBERS
-- is defined in prvtaqds.plb. Therefore, the following view definition
-- must appear after prvtaqds.plb, and it is not suitable to use these
-- views in AQ packages.
/* Bug 6488226: To add rule condition for a subscriber,  outer join of 
 * existing view is done with user_rules view.
 Join condition is on rule_name subscriber
 */

-- Create view USER_QUEUE_SUBSCRIBERS
create or replace view user_queue_subscribers
as
select q.name QUEUE_NAME, t.name QUEUE_TABLE, 
       s.name CONSUMER_NAME, s.address ADDRESS, s.protocol PROTOCOL, 
       s.trans_name TRANSFORMATION, r.rule_condition RULE, 
       decode(bitand(s.sub_type, 192), 64, 'PERSISTENT',
                                       128, 'BUFFERED',
                                       192, 'PERSISTENT_OR_BUFFERED',
                                       'NONE') DELIVERY_MODE,
       decode(bitand(s.sub_type, 32960), 32960, 'YES       ','NO        ') 
                                       NONDURABLE,
       decode(bitand(s.sub_type, 512), 512, 'TRUE', 'FALSE') QUEUE_TO_QUEUE
FROM   system.aq$_queues q, system.aq$_queue_tables t, sys.user$ cu,
        sys.user_rules r,
       TABLE(aq$_get_subscribers(cu.name, q.name, t.name, 
                                 cu.name, q.eventid, t.flags)) s
where cu.user# = userenv('SCHEMAID')
and   cu.name  = t.schema
and   q.table_objno = t.objno
and   bitand(t.flags, 1) = 1 and q.usage!=1
and   s.rule_name = r.rule_name(+)
/
COMMENT ON TABLE USER_QUEUE_SUBSCRIBERS is
'queue subscribers under a user''schema'
/
COMMENT ON COLUMN USER_QUEUE_SUBSCRIBERS.QUEUE_NAME IS
'name of the queue'
/
COMMENT ON COLUMN USER_QUEUE_SUBSCRIBERS.QUEUE_TABLE IS
'name of the queue table'
/
COMMENT ON COLUMN USER_QUEUE_SUBSCRIBERS.CONSUMER_NAME IS
'name of the subscriber'
/
COMMENT ON COLUMN USER_QUEUE_SUBSCRIBERS.ADDRESS IS
'address of the subscriber'
/
COMMENT ON COLUMN USER_QUEUE_SUBSCRIBERS.PROTOCOL IS
'protocol of the subscriber'
/
COMMENT ON COLUMN USER_QUEUE_SUBSCRIBERS.TRANSFORMATION IS
'transformation for the subscriber'
/
COMMENT ON COLUMN USER_QUEUE_SUBSCRIBERS.RULE IS
'rule condition for the subscriber'
/
COMMENT ON COLUMN USER_QUEUE_SUBSCRIBERS.DELIVERY_MODE IS
'message delivery mode for the subscriber'
/
COMMENT ON COLUMN USER_QUEUE_SUBSCRIBERS.QUEUE_TO_QUEUE IS
'whether the subscriber is a queue to queue subscriber'
/

CREATE OR REPLACE PUBLIC SYNONYM user_queue_subscribers FOR 
user_queue_subscribers
/
GRANT select ON USER_QUEUE_SUBSCRIBERS TO PUBLIC
/

-- Create view ALL_QUEUE_SUBSCRIBERS
-- This view displays all subscribers that the user has dequeue privilege on
 /* Bug 6488226: To add rule condition for a subscriber, inline outer join of 
 * existing view is done with dba_rules view.
 Join condition is on rule_name and schema of subscriber
 */
create or replace view ALL_QUEUE_SUBSCRIBERS
as
select su.owner OWNER, su.queue_name QUEUE_NAME, su.queue_table QUEUE_TABLE,
       su.consumer_name CONSUMER_NAME, su.address ADDRESS,
       su.protocol PROTOCOL, su.transformation TRANSFORMATION, 
       r.rule_condition RULE,
       decode(bitand(su.sub_type, 192), 64, 'PERSISTENT',
                                         128, 'BUFFERED',
                                         192, 'PERSISTENT_OR_BUFFERED',
                                         'NONE') DELIVERY_MODE,
       decode(bitand(su.sub_type, 32960), 32960, 'YES                     ',
                                       'NO') IF_NONDURABLE_SUBSCRIBER,
       decode(bitand(su.sub_type, 512), 512, 'TRUE', 'FALSE') QUEUE_TO_QUEUE
FROM   ( select  u.name OWNER, q.name QUEUE_NAME, t.name QUEUE_TABLE,
                 s.name CONSUMER_NAME, s.address ADDRESS, s.protocol PROTOCOL,
                 s.trans_name TRANSFORMATION, s.sub_type SUB_TYPE,
                 s.rule_name RULE_NAME
         FROM    system.aq$_queues q, system.aq$_queue_tables t, sys.user$ u,
                 sys.obj$ ro, sys.user$ cu,
                 TABLE(aq$_get_subscribers(u.name, q.name, t.name,
                                           cu.name, q.eventid, t.flags)) s
         where u.name  = t.schema
         and   q.table_objno = t.objno
         and   bitand(t.flags, 1) = 1 and q.usage!=1
         and   ro.owner# = u.user#
         and   ro.obj# = q.eventid
         and   cu.user# = userenv('SCHEMAID')
         and  (ro.owner# = userenv('SCHEMAID')
               or ro.obj# in
                    (select oa.obj#
                     from sys.objauth$ oa
                     where oa.privilege# in (21, 41) and
                           grantee# in (select kzsrorol from x$kzsro))
               or exists (select null from v$enabledprivs
                          where priv_number = -220)
               or ro.obj# in
                    (select q.eventid from system.aq$_queues q,
                                           system.aq$_queue_tables t
                     where q.table_objno = t.objno
                     and bitand(t.flags, 8) = 0
                     and exists (select null from sys.objauth$ oa, sys.obj$ o
                                 where oa.obj# = o.obj#
                                 and (o.name = 'DBMS_AQ' 
                                      or o.name = 'DBMS_AQADM')
                                 and o.owner# = 0
                                 and o.type# = 9
                                 and oa.grantee# = userenv('SCHEMAID')))
              )
       ) su, sys.dba_rules r
where su.rule_name = r.rule_name(+)
and   su.owner = r.rule_owner(+)
/

CREATE OR REPLACE PUBLIC SYNONYM all_queue_subscribers FOR
all_queue_subscribers
/
GRANT select ON ALL_QUEUE_SUBSCRIBERS TO PUBLIC
/
COMMENT ON TABLE ALL_QUEUE_SUBSCRIBERS is
'All queue subscribers accessible to user'
/

COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.OWNER IS
'owner of the queue'
/
COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.QUEUE_NAME IS
'name of the queue'
/
COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.QUEUE_TABLE IS
'name of the queue table'
/
COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.CONSUMER_NAME IS
'name of the subscriber'
/
COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.ADDRESS IS
'address of the subscriber'
/
COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.PROTOCOL IS
'protocol of the subscriber'
/
COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.TRANSFORMATION IS
'transformation for the subscriber'
/
COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.RULE IS
'rule condition for the subscriber'
/
COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.DELIVERY_MODE IS
'message delivery mode for the subscriber'
/
COMMENT ON COLUMN ALL_QUEUE_SUBSCRIBERS.QUEUE_TO_QUEUE IS
'whether the subscriber is a queue to queue subscriber'
/

CREATE OR REPLACE PUBLIC SYNONYM all_queue_subscribers FOR 
all_queue_subscribers
/
GRANT select ON ALL_QUEUE_SUBSCRIBERS TO PUBLIC
/

-- Create view DBA_QUEUE_SUBSCRIBERS
-- This view displays all subscribers that the user has dequeue privilege on
/* Bug 6488226: To add rule condition for a subscriber, inline outer join of 
 * existing view is done with dba_rules view.
 Join condition is on rule_name and schema of subscriber
 */

create or replace view DBA_QUEUE_SUBSCRIBERS
as
select su.owner OWNER, su.queue_name QUEUE_NAME, su.queue_table QUEUE_TABLE,
       su.consumer_name CONSUMER_NAME, su.address ADDRESS,
       su.protocol PROTOCOL, su.transformation TRANSFORMATION,
       r.rule_condition RULE,
       decode(bitand(su.sub_type, 192), 64, 'PERSISTENT',
                                       128, 'BUFFERED',
                                       192, 'PERSISTENT_OR_BUFFERED',
                                       'NONE') DELIVERY_MODE,
       decode(bitand(su.sub_type, 32960), 32960, 'YES                     ', 
                                       'NO') IF_NONDURABLE_SUBSCRIBER,
       decode(bitand(su.sub_type, 512), 512, 'TRUE', 'FALSE') QUEUE_TO_QUEUE
FROM   ( select t.schema OWNER, q.name QUEUE_NAME, t.name QUEUE_TABLE,
                s.name CONSUMER_NAME, s.address ADDRESS, s.protocol PROTOCOL,
                s.trans_name TRANSFORMATION, s.rule_name RULE_NAME,
                s.sub_type SUB_TYPE
         FROM   system.aq$_queues q, system.aq$_queue_tables t,
         TABLE(aq$_get_subscribers(t.schema, q.name, t.name,
                                   NULL, q.eventid, t.flags)) s
         where q.table_objno = t.objno
         and   bitand(t.flags, 1) = 1 and q.usage!=1
         ) su, dba_rules r
where  su.rule_name = r.rule_name(+)
and    su.owner = r.rule_owner(+)
/
COMMENT ON TABLE DBA_QUEUE_SUBSCRIBERS is
'queue subscribers in the database'
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.OWNER IS
'owner of the queue'
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.QUEUE_NAME IS
'name of the queue'
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.QUEUE_TABLE IS
'name of the queue table'
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.CONSUMER_NAME IS
'name of the subscriber'
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.ADDRESS IS
'address of the subscriber'
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.PROTOCOL IS
'protocol of the subscriber'
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.TRANSFORMATION IS
'transformation for the subscriber'
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.RULE IS
'rule condition for the subscriber' 
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.DELIVERY_MODE IS
'message delivery mode for the subscriber'
/
COMMENT ON COLUMN DBA_QUEUE_SUBSCRIBERS.QUEUE_TO_QUEUE IS
'whether the subscriber is a queue to queue subscriber'
/

CREATE OR REPLACE PUBLIC SYNONYM dba_queue_subscribers FOR 
dba_queue_subscribers
/
GRANT select ON DBA_QUEUE_SUBSCRIBERS TO SELECT_CATALOG_ROLE
/
@@prvtaqji.plb

-- load dbms_aqadm_sys
@@dbmsaqds.plb


