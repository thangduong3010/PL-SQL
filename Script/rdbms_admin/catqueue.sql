Rem
Rem $Header: rdbms/admin/catqueue.sql /st_rdbms_11.2.0/2 2012/12/21 02:12:18 tbhosle Exp $
Rem
Rem catqueue.sql
Rem
Rem Copyright (c) 1996, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catqueue.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This file contains the queue dictionary information which is created
Rem      in the SYSTEM schema.  There are three main tables:
Rem             aq$_queue_tables     - stores information about all the queue
Rem                                    tables
Rem             aq$_queues           - stores information about all the queues
Rem             aq$_schedules        - stores information about all the 
Rem                                    schedules
Rem      In the SYS schema
Rem             aq$_queue_statistics   - stores inforamtion about statistics
Rem                                      this inforamtion is only for OPS
Rem             aq$_message_types      - Type Identifiers (TOIDs) of queues
Rem                                      that are targets of propagation.
Rem             aq$_propagation_status - Status of propagation to a destination
Rem                                      from a given source queue
Rem             aq$_pending_messages   - Messages that have been sent in the
Rem                                    - latest unit of work.
Rem      Sequence in the SYS schema
Rem             aq$_propagation_sequence - sequence number generator to stamp
Rem                                        each transaction of propagator
Rem             aq$_rule_set_sequence    - sequence number for publisher/sub
Rem                                        rule sets            
Rem             aq$_rule_sequence        - sequence number for rule names
Rem
Rem      The Standard AQ types are created to be used in the enqueue call
Rem      as well as the admin subscribe and unsubscribe calls. The types are:
Rem             aq$_agent - Uniquely identifies a producer or consumer of 
Rem                         a message. These can be users,queues, programs etc.
Rem                         Currently we only support agents that are queues or
Rem                         programs. This type is used in 
Rem                         dbms_aqadm.subscribe and dbms_aqadm.unsubscribe.
Rem             aq$_dequeue_history - History of dequeuers for the particular 
Rem                                   message.
Rem             aq$_history - A varying array of aq$_dequeue_history
Rem
Rem      In the SYS schema there is also a new queue table aq$_prop_table
Rem      for use internally in propagation scheduling.
Rem
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rtati       04/12/11 - Backport rtati_bug-10065474 from main
Rem    tbhosle     02/25/10 - 8670389: add sess key to reg$ & reg$_idx
Rem    shbose      09/18/09 - Bug 8764375: Add destq to sys.aq$_schedules
Rem    xingjin     03/25/09 - bug 8368685: add check to ensure package owner is SYS
Rem    swshekha    03/20/09 - changed definition of gv$aq and v$aq
Rem    shbose      02/24/09 - bug 7530052: create new view for dequeue by
Rem                           condition
Rem    absaxena    08/16/08 - add DBMS_AQ_EXP_DEQUEUELOG_TABLES
Rem    nbhatt      08/14/08 - add aq$_queue_tables flags comment for dequeuelog
Rem    shbose      04/10/08 - Add index to aq$_queue_table_affinities
Rem    sjanardh    03/20/08 - add client_session_guid column to aq$_subscriber_table
Rem    asohi       03/10/08 - Add enable-disable status flag to reg$
Rem    jhan        02/19/08 - Add regz$ for session keys
Rem    gagarg      10/02/07 - add attribute RULE_NAME in aq$_SUBSCRIBER type
Rem    asamanta    06/18/07 - LRG 3018059 deleting the row before insert 
Rem    swshekha    05/16/07 - Bugfix: 5303237 add a row in aq$_subscriber_table
Rem    absaxena    06/05/07 - remove aq$_regid_sequence
Rem    absaxena    03/13/07 - add reg_id to aq$_srvntfn_message
Rem    absaxena    02/16/07 - add grouping_inst_id to reg$
Rem    swshekha    01/22/07 - Removed comment 'NOT_USED' from total_time of 
Rem                           aq$_schedules 
Rem    sjanardh    08/28/06 - add AQ$_SUBSCRIBER_TABLE
Rem    jawilson    05/05/06 - add AQ$_PROPAGATION_PROGRAM 
Rem    absaxena    07/18/06 - change reg_id in reg$ from varchar2 to number 
Rem    rburns      05/19/06 - restructure for parallel upgrade 
Rem    absaxena    05/24/06 - add DBA|USER_SUBSCR_REGISTRATIONS views
Rem    absaxena    05/23/06 - add aq$_ntfn_msgid_array
Rem    absaxena    05/22/06 - enhance aq$_descriptor for grouping ntfns 
Rem    absaxena    04/18/06 - add ntfn grouping attributes to aq$_reg_info
Rem    absaxena    04/06/06 - add sequence aq$_regid_sequence   
Rem    absaxena    04/05/06 - add columns reg_id, reg_time, 
Rem                           ntfn_grouping_class|value|type|start_time|
Rem                           repeat_count, and status_change_time to reg$ 
Rem    rvenkate    05/03/05 - expose network_name 
Rem    ksurlake    04/21/05 - 4322733: add constructor
Rem    jciminsk    03/14/05 - 4163031: aq$_reg_info constructor -- check nulls 
Rem    weiwang     02/14/05 - move the grant on dba_queue_subscribers later 
Rem    weiwang     01/24/05 - add all_queue_subscribers 
Rem    ksurlake    01/04/05 - 4094605: Support larger payload for ntfn
Rem    kmeiyyap    10/13/04 - grant execute privileges to dbms_aq_inv 
Rem    weiwang     10/14/04 - add view ALL_DEQUEUE_QUEUES 
Rem    aramacha    09/09/04 - Fix 3797337.
Rem    rbhyrava    08/12/04 - 
Rem    kmeiyyap    08/04/04 - add 10.0.0 to dba_queue_tables view 
Rem    htran       06/07/04 - queue table views: commit time sort order
Rem    nbhatt      06/27/04 - refresh
Rem    nbhatt      06/11/04 - add delivery mode to message_properties_t 
Rem    nbhatt      06/08/04 - fix user_queue_schedules 
Rem    nbhatt      05/25/04 - flow control disable 
Rem    sbalaram    04/29/04 - modify DBA_QUEUE_SCHEDULES to show schedule for
Rem                           BUFFERED msgs
Rem    ksurlake    06/01/04 - evolve reg$ and related types
Rem    rvenkate    05/24/04 - add defer ddl bit 
Rem    jciminsk    02/06/04 - merge from RDBMS_MAIN_SOLARIS_040203 
Rem    jciminsk    12/12/03 - merge from RDBMS_MAIN_SOLARIS_031209 
Rem    ksurlake    08/26/03 - modify primary key for aq$_propagation_status
Rem    jciminsk    08/19/03 - branch merge 
Rem    rvenkate    08/13/03 - increase network_name size
Rem    rvenkate    07/16/03 - add services
Rem    elu         12/09/03 - add comment for rebuild indexes
Rem    wesmith     11/12/03 - add comment for new queue table flags bit 
Rem    ksurlake    11/05/03 - Move reg$ and loc$ creation
Rem    ksurlake    11/03/03 - Add ANYDATA context to aq$_reg_info
Rem    ksurlake    10/14/03 - Add ANYDATA context to aq$_srvntfn_message
Rem    jawilson    07/28/03 - Add timezone column to aq$_queue_tables
Rem    rvenkate    08/13/03 - increase network_name size
Rem    rvenkate    07/16/03 - add services
Rem    ksurlake    07/19/03 - Add ack column to aq$_replay_info
Rem    ksurlake    07/17/03 - include destqueue_id in propagatio_status key
Rem    weiwang     06/17/03 - add aq$_internal_agents to noexp$
Rem    htran       05/12/03 - new table flag to indicate use of 10.0 names
Rem    weiwang     04/15/03 - add new queue table flags
Rem    jawilson    02/03/03 - remove dba/user_buffered_queues
Rem    weiwang     01/31/03 - remove grants for imp/exp packages
Rem    ksurlake    01/17/03 - Add spilled tables and iots
Rem    htran       12/20/02 - don't drop internet_agent tables
Rem    jawilson    10/23/02 - Changes to buffered queue views
Rem    jawilson    10/02/02 - Add buffered queue views
Rem    nbhatt      08/09/02 - queue export level to 1004
Rem    qialiu      06/06/02 - add calling prvtaqal.plb.
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    weiwang     01/23/02 - change dbms_aqjms to dbms_aqjms_internal
Rem    nbhatt      11/15/01 - remove index rule_sub_map
Rem    najain      11/01/01 - add aq$_replay_info
Rem    weiwang     11/06/01 - use spare1 in aq$_schedules to store HTTP 
Rem                           propagation batch size
Rem    skmishra    10/19/01 - merge LOG into MAIN
Rem    bnainani    10/10/01 - add secure col to dba/user/all_queue_tables views
Rem    bnainani    10/04/01 - add dba_aq_agents, dba/user_aq_agent_privs views
Rem    bnainani    10/04/01 - add secure flag to create_queue_table
Rem    weiwang     09/17/01 - grant execute on rules engine import/export 
Rem                           packages to aq_administrator_role
Rem    nbhatt      09/26/01 - comments in aq$_publisher
Rem    ksurlake    09/06/01 - comments in aq$_queue_tables 
Rem    nbhatt      08/01/01 - ruleset & rule name sequence
Rem    nbhatt      07/13/01 - publisher table
Rem    najain      07/11/01 - queue enhancements for replication
Rem    weiwang     05/15/01 - don't create global_aq_user_role if std edition
Rem    rburns      10/28/01 - wrap create queue to remove errors
Rem    druthven    07/20/01 - 
Rem    kmeiyyap    07/03/01 - fix aq$_pending_messages index creation.
Rem    weiwang     05/15/01 - don't create global_aq_user_role if std edition
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    rkambo      01/17/01 - bugfix 1588636
Rem    nbhatt      11/28/00 - add transformation to the constraint of aq_message_types
Rem    najain      11/20/00 - scale server notification
Rem    kmeiyyap    11/02/00 - 1099084: add index to aq$_pending_messages.
Rem    rkambo      11/06/00 - watermark and xml presentation
Rem    najain      10/12/00 - grant execute on msg_prop_t to public
Rem    bnainani    11/15/00 - specify compatible=8.0 for queue table
Rem    weiwang     09/19/00 - create global_aq_user_role
Rem    weiwang     09/28/00 - reserve toid for aq$_sig_prop
Rem    nbhatt      11/07/00 - grant execute on sys.aq_midarray to public
Rem    rkambo      07/21/00 - notification presentation support
Rem    skmishra    08/15/00 -  move internet_users privs after create role
Rem    bnainani    08/10/00 -  change aqinternet_users synonym
Rem    bnainani    08/01/00 -  move aq$_internet_users view to sys
Rem    bnainani    07/31/00 -  fix merge error
Rem    nbhatt      07/31/00 -  add aq_midarray
Rem    aahluwal    07/26/00 - Adjusting SYSTEM.AQ$Internet_Users col size
Rem    aahluwal    07/24/00 - Changing definition of aq_internet_agents view
Rem    nbhatt      08/23/00 - add transformation to sys.message_types
Rem    najain      04/26/00 - support AQ signature
Rem    aahluwal    07/20/00 - add authorization tables/views
Rem    rkambo      06/06/00 - pubsub enhancement
Rem    weiwang     03/23/00 - add DBMS_AQ_LDAP_LIB
Rem    rbhyrava    04/13/00 - add prvtaqem.plb
Rem    nbhatt      04/06/00 - add the transformations table
Rem    najain      03/22/00 - update aq$reg_info
Rem    najain      03/16/00 - support for email notification
Rem    najain      02/10/00 - support for plsql post
Rem    rkambo      01/31/00 - plsql notification for non-persistent queues
Rem    najain      12/27/99 - support for  plsql notification
Rem    kmeiyyap    08/13/99 - bug 954417 - add sequence for trans. grouping tid
Rem    bnainani    07/30/99 - Bug 915265 - change file names to 8 chars
Rem    bnainani    07/29/99 - grant execute on aq packages to execute_catalog_r
Rem    bnainani    07/01/99 - grant execute on dbms_aqjms to aquser/aqadmin
Rem    bnainani    06/03/99 - add prvtaqjms.plb
Rem    nbhatt      03/12/99 - hide total consumers from v$aq
Rem    nbhatt      03/15/99 - bug:810412 move affinity table before aq_schedules
Rem    kmeiyyap    01/07/99 - make catqueue.sql sqlplus compatible
Rem    ato         12/12/98 - add dbms_aqadm to imp_full_database
Rem    ryaseen     11/20/98 - splitting dbms_aqadm
Rem    ato         11/02/98 - filter duplication types in queue_tables views  
Rem    mkamath     10/22/98 - Adding ENQUEUE/DEQUEUE ANY privilege to SYS
Rem    ato         10/21/98 - set order in exppkgact$
Rem    ato         10/12/98 - exp/imp procedural objects support               
Rem    ato         09/30/98 - add prvtaqin.sql                                 
Rem    ato         09/15/98 - create all_queue_tables view                   
Rem    mkamath     08/31/98 - making type sys.aq$_notify_msg public
Rem    schandra    08/06/98 - move prvtaqdi ahead of other packages
Rem    ncramesh    08/07/98 - change fro sqlplus
Rem    schandra    07/31/98 - defer delete from pending_messages
Rem    ato         07/16/98 - remove events 10931
Rem    ato         07/13/98 - bug672378-use intcol# in queue table views
Rem    schandra    06/25/98 - add spare fields in propagation tables
Rem    ato         06/25/98 - grant options for execute rights                 
Rem    nbhatt      06/18/98 -  add NONPERSISTENT queue to ALL_QUEUES
Rem    ryaseen     06/29/98 - update queue table flags comment
Rem    schandra    06/05/98 - queue table upgrade/downgrade
Rem    ato         06/04/98 - grant execute rights to roles  
Rem    mkamath     06/02/98 - Adding session serial# to schedules table     
Rem    ato         06/01/98 - grant select on propagation_status to aq_administ
Rem    mkamath     06/03/98 - add comment related to SCHEDULES table
Rem    ato         05/16/98 - remove catq8003.sql
Rem    ato         05/15/98 - grant select on v_$aq and gv_$aq to aq_admin_role
Rem    ato         05/14/98 - add ALL_QUEUES and QUEUE_PRIVILEGES views
Rem    ato         05/12/98 - grant all system types to PUBLIC
Rem    ato         05/08/98 - grant dba view to AQ_ADMINISTRATOR_ROLE
Rem    ato         05/08/98 - move role creations in catqueue.sql
Rem    ato         05/05/98 - reverse the index key order in aq$_queues_check
Rem    mkamath     05/31/98 - modifying user_queue_schedules
Rem    mkamath     05/28/98 - Changing view user_queue_schedules
Rem    schandra    05/05/98 - add COMPATIBLE column to DBA_QUEUE_TABLES and USE
Rem    mkamath     05/12/98 - Adding fields to the schedules table
Rem    arsaxena    04/30/98 - chnage views to decode non_persistent queue type
Rem    mkamath     04/23/98 - Moving notify_msg definition ahead of package loa
Rem    mkamath     04/26/98 - Enhancing propagation notify queue payload
Rem    ryaseen     04/13/98 - load package dbms_prvtaqis
Rem    mkamath     04/16/98 - Adding USER_QUEUE_SCHEDULES view
Rem    ato         04/22/98 - add prvtaqdi.plb (Admin Internal)
Rem    ato         04/09/98 - add AQ admin library
Rem    schandra    03/25/98 - create recovery tables for propagation
Rem    ryaseen     04/10/98 - Move subscriber, rule tables to user schema
Rem    ryaseen     04/07/98 - Add sys.aq$_rules
Rem    nireland    03/17/98 - Add synonym for DBA_QUEUES. #605559
Rem    ryaseen     02/20/98 - Add sys.aq$_queue_subscribers
Rem    schandra    01/27/98 - add comment for new queue tables
Rem    nbhatt      03/17/98 - add new table for queue affinities
Rem    nbhatt      02/23/98 - add dictionary table for instance affinity 
Rem    mkamath     02/28/98 - changing aq$_schedules adding aq$_prop_table
Rem    ato         11/13/97 - patch bug fix 572136
Rem    ato         11/13/97 - remove double quote
Rem    arsaxena    10/16/97 - increase number of recipients to 1024
Rem    nbhatt      09/15/97 - add gv$aq and v$aq views
Rem    arsaxena    09/12/97 - address 90->1024
Rem    nbhatt      08/14/97 - remove owner_inst and incarn_num
Rem    nbhatt      08/12/97 - add incarn_num to aq$_queues
Rem    nbhatt      08/06/97 - add column for statistics in system.aq_queues
Rem    schandra    08/15/97 - 524213: sqlplus is sensitive to blank lines
Rem    arsaxena    07/22/97 - add scheduling table/view for propagation
Rem    schandra    05/13/97 - address - 30->90
Rem    ato         05/07/97 - bug#489741:don't replace aq$ types
Rem    ato         05/05/97 - remove internal package
Rem    schandra    05/01/97 - Bug# 486530: fix retention time handling
Rem    schandra    04/30/97 - add types for displaying dequeue history
Rem    nbhatt      04/24/97 - add loading of catq8003.sql
Rem    schandra    04/24/97 - add field to denote how app was specified in dequ
Rem    nbhatt      04/23/97 - chnage EXCPT to EXCEPTION_QUEUE
Rem    nbhatt      04/22/97 - destination->address in AQ agent
Rem    nbhatt      04/21/97 - compile the dbms_aqin package
Rem    nbhatt      04/21/97 - change views
Rem    esoyleme    04/22/97 - bit for iot imp/exp in queue_tables
Rem    schandra    04/12/97 - create AQ types with fixed OIDs
Rem    jbellemo    04/12/97 - add with grant option
Rem    ato         03/29/97 - raw payload support
Rem    schandra    03/25/97 - support grouping by transaction
Rem    schandra    03/18/97 - increase size of varray to 100000
Rem    schandra    03/11/97 - string for queue & appname in history
Rem    schandra    02/18/97 - create AQ types
Rem    nbhatt      03/31/97 - update RETENTION field
Rem    ato         03/18/97 - fix view bug
Rem    asurpur     01/03/97 - Grant DBA views to SELECT_CATALOG_ROLE
Rem    ato         11/08/96 - ADT => object_type
Rem    ato         11/06/96 - insert aq$ tables into noexp$
Rem    ato         11/06/96 - do not drop aq$ tables
Rem    ato         10/22/96 - modify event level of 10931
Rem    ato         10/25/96 - fix view bug
Rem    ato         10/22/96 - change name of midseq to chainseq
Rem    ato         10/21/96 - add fields to DBA_QUEUES
Rem    ato         10/15/96 - fix user views
Rem    pshah       10/15/96 - Changing the load pathname of the dbms_aq 
Rem                           package specification and body
Rem    ato         10/09/96 - load AQ admin package
Rem    pshah       10/08/96 - Incorporating changes due to AQ packages 
Rem                           becoming non-fixed
Rem    pshah       09/27/96 - Remove AQLIB creation
Rem    pshah       09/25/96 - Creating AQLIB
Rem    pshah       09/25/96 - Creating a public synonym for the x$dbmsaq 
Rem                           package
Rem    pshah       09/23/96 - Modifying queue dictionary column names
Rem    pshah       08/26/96 - Adding the 'ret_time' column to system.aq$_queues
Rem    ato         08/26/96 - fix view user_queue_tables
Rem    ato         08/22/96 - remove toid from aq$_queues
Rem    ato         08/15/96 - modify for typed queues
Rem    ato         08/07/96 - change queue_type usage
Rem    pshah       08/02/96 - Removing data_obj_no from queue table dictionary
Rem    pshah       08/01/96 - Adding data_obj_no column to the queue tables dic
Rem    ato         07/31/96 - ALL_QUEUES -> DBA_QUEUES
Rem    ato         07/29/96 - queue_tid -> qtoid
Rem    ato         07/28/96 - fixed typos
Rem    pshah       07/23/96 - q_userdata_type => q_udata_type
Rem    ato         07/22/96 - Fixed-type vs variant-type queue
Rem    pshah       06/06/96 - Adding a column to queues data dictionary
Rem    pshah       05/30/96 - Queue Data Dictionary
Rem    pshah       05/30/96 - Created
Rem

-- Granting priveleges to SYS
grant select any table to sys with admin option
/
grant insert any table to sys
/
grant update any table to sys
/
grant delete any table to sys
/
grant select any sequence to sys
/
grant execute any type to sys
/

create sequence invalidation_reg_id$          /* registration sequence number */
  start with 1
  increment by 1
  minvalue 1
  nomaxvalue
  cache 300
  order 
  nocycle
/

create table sys.reg$
( reg_id                     number,
  subscription_name          varchar2(128) not null,
  location_name              varchar2(256) not null,
  user#                      number not null,
  user_context               raw(128),
  context_size               number,
  namespace                  number,
  presentation               number,
  version                    number,
  status                     number,
 -- status_change_time         timestamp with time zone,
  any_context                sys.anydata,
  context_type               number DEFAULT 0,
  qosflags                   number DEFAULT 0,
  payload_callback           varchar2(4000),
  timeout                    timestamp,
  reg_time                   timestamp with time zone,
  ntfn_grouping_class        number,
  ntfn_grouping_value        number,
  ntfn_grouping_type         number,
  ntfn_grouping_start_time   timestamp with time zone,
  ntfn_grouping_repeat_count number,
  grouping_inst_id           number,
  state                      number,
  session_key                varchar2(1024))
/

create index reg$_idx on reg$ (subscription_name, namespace, location_name, reg_id);

Rem During upgrade we cannot add SYS.ANYDATA columns in c0902000.sql
Rem because it might not have been created then. a0902000.sql would
Rem be too late since the scheduler registers for notification in
Rem between (prvtdsch.sql). Hence we modify reg$ here.

BEGIN
EXECUTE IMMEDIATE
'ALTER TABLE sys.reg$
 MODIFY (user_context raw(128) NULL, context_size number NULL)
 ADD (any_context SYS.ANYDATA, context_type NUMBER DEFAULT 0)';
EXCEPTION
 WHEN OTHERS THEN
  NULL;
END;
/

DECLARE
 COLUMN_EXISTS exception;
 PRAGMA EXCEPTION_INIT(COLUMN_EXISTS, -1430);
BEGIN
EXECUTE IMMEDIATE
'ALTER TABLE sys.reg$
 ADD (qosflags number DEFAULT 0, payload_callback varchar2(4000),
      timeout timestamp)';
EXCEPTION
 WHEN COLUMN_EXISTS THEN
  NULL;
END;
/

DECLARE
 COLUMN_EXISTS exception;
 PRAGMA EXCEPTION_INIT(COLUMN_EXISTS, -1430);
BEGIN
EXECUTE IMMEDIATE
'ALTER TABLE sys.reg$
 ADD (reg_id number, reg_time timestamp with time zone,
      ntfn_grouping_class number, ntfn_grouping_value number, 
      ntfn_grouping_type number, 
      ntfn_grouping_start_time timestamp with time zone, 
      ntfn_grouping_repeat_count number, grouping_inst_id number)';
EXCEPTION
 WHEN COLUMN_EXISTS THEN
  NULL;
END;
/

create index sys.reg$_t on sys.reg$ (timeout)
/

create table sys.loc$
( location_name     varchar2(256) not null,
  emon#             number,
  connection#       number)
/

create or replace view DBA_SUBSCR_REGISTRATIONS
as 
select reg_id, subscription_name, location_name, user#, user_context, 
  context_size, decode(namespace, 0, 'ANONYMOUS', 1, 'AQ', 2, 'DBCHANGE') 
  NAMESPACE, decode(presentation, 0, 'DEFAULT', 1, 'XML') PRESENTATION, 
  decode(version, 1, '8.1.6', 2, '10.2', 3, '11.1', 4, '11.2', 5, '11.2.0.2',
         6, '12.1.0.0')
  VERSION, decode(status, 0, 'DB REG', 1, 'LDAP REG') STATUS, any_context, 
  context_type, decode(qosflags, 1,'RELIABLE', 2, 'PAYLOAD', 16, 'PURGE_ON_NTFN') QOSFLAGS, payload_callback, 
  timeout, reg_time, decode(ntfn_grouping_class, 1, 'TIME')NTFN_GROUPING_CLASS,
  ntfn_grouping_value, decode(ntfn_grouping_type, 1, 'SUMMARY', 2, 'LAST') 
  NTFN_GROUPING_TYPE, ntfn_grouping_start_time, 
  decode(ntfn_grouping_repeat_count, -1, 'FOREVER', ntfn_grouping_repeat_count)   NTFN_GROUPING_REPEAT_COUNT 
from reg$
/
comment on table DBA_SUBSCR_REGISTRATIONS is
'All subscription registrations created in the database'
/
comment on column DBA_SUBSCR_REGISTRATIONS.NAMESPACE is
'Subscription namespace'
/
comment on column DBA_SUBSCR_REGISTRATIONS.PRESENTATION is
'Presentation of notification'
/
comment on column DBA_SUBSCR_REGISTRATIONS.VERSION is
'Version'
/
comment on column DBA_SUBSCR_REGISTRATIONS.STATUS is
'Status of registration'
/
comment on column DBA_SUBSCR_REGISTRATIONS.QOSFLAGS is
'Quality of service of registration'
/
comment on column DBA_SUBSCR_REGISTRATIONS.NTFN_GROUPING_CLASS is
'Grouping class'
/
comment on column DBA_SUBSCR_REGISTRATIONS.NTFN_GROUPING_VALUE is
'Grouping value'
/
comment on column DBA_SUBSCR_REGISTRATIONS.NTFN_GROUPING_TYPE is
'Grouping type'
/
comment on column DBA_SUBSCR_REGISTRATIONS.NTFN_GROUPING_START_TIME is
'Grouping start time'
/
comment on column DBA_SUBSCR_REGISTRATIONS.NTFN_GROUPING_REPEAT_COUNT is
'Grouping repeat count'
/
create or replace public synonym DBA_SUBSCR_REGISTRATIONS for SYS.DBA_SUBSCR_REGISTRATIONS
/
grant select on DBA_SUBSCR_REGISTRATIONS to SELECT_CATALOG_ROLE
/

create or replace view USER_SUBSCR_REGISTRATIONS
as 
select r.reg_id, r.subscription_name, r.location_name, r.user#, r.user_context,
  r.context_size, decode(r.namespace, 0, 'ANONYMOUS', 1, 'AQ', 2, 'DBCHANGE') 
  NAMESPACE, decode(r.presentation, 0, 'DEFAULT', 1, 'XML') PRESENTATION, 
  decode(r.version, 1, '8.1.6', 2, '10.2', 3, '11.1', 4, '11.2', 5, '11.2.0.2',
      6, '12.1.0.0')
  VERSION, decode(r.status, 0, 'DB REG', 1, 'LDAP REG') STATUS, r.any_context, 
  r.context_type, decode(r.qosflags, 1, 'RELIABLE', 2, 'PAYLOAD', 16, 
  'PURGE_ON_NTFN') QOSFLAGS, r.payload_callback, r.timeout, r.reg_time, 
  decode(r.ntfn_grouping_class, 1, 'TIME') NTFN_GROUPING_CLASS,
  r.ntfn_grouping_value, decode(r.ntfn_grouping_type, 1, 'SUMMARY', 2, 'LAST') 
  NTFN_GROUPING_TYPE, r.ntfn_grouping_start_time, 
  decode(r.ntfn_grouping_repeat_count, -1, 'FOREVER', r.ntfn_grouping_repeat_count) 
  NTFN_GROUPING_REPEAT_COUNT 
from reg$ r, sys.user$ cu
where r.user# = cu.user# 
and cu.user# = userenv('SCHEMAID')
/
comment on table USER_SUBSCR_REGISTRATIONS is
'All subscription registrations created by the user'
/
comment on column USER_SUBSCR_REGISTRATIONS.NAMESPACE is
'Subscription namespace'
/
comment on column USER_SUBSCR_REGISTRATIONS.PRESENTATION is
'Presentation of notification'
/
comment on column USER_SUBSCR_REGISTRATIONS.VERSION is
'Version'
/
comment on column USER_SUBSCR_REGISTRATIONS.STATUS is
'Status of registration'
/
comment on column USER_SUBSCR_REGISTRATIONS.QOSFLAGS is
'Quality of service of registration'
/
comment on column USER_SUBSCR_REGISTRATIONS.NTFN_GROUPING_CLASS is
'Grouping class'
/
comment on column USER_SUBSCR_REGISTRATIONS.NTFN_GROUPING_VALUE is
'Grouping value'
/
comment on column USER_SUBSCR_REGISTRATIONS.NTFN_GROUPING_TYPE is
'Grouping type'
/
comment on column USER_SUBSCR_REGISTRATIONS.NTFN_GROUPING_START_TIME is
'Grouping start time'
/
comment on column USER_SUBSCR_REGISTRATIONS.NTFN_GROUPING_REPEAT_COUNT is
'Grouping repeat count'
/
create or replace public synonym USER_SUBSCR_REGISTRATIONS for SYS.USER_SUBSCR_REGISTRATIONS
/
grant select on USER_SUBSCR_REGISTRATIONS to PUBLIC with grant option
/

-- Create AQ types 

-- NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
-- These types are used in oltp/qs/kwqi*.[ch]. If the type is changed make
-- sure the references to the type in the code is also changed.
-- The internal structure that represents aq$_agent is kwqia defined in kwqi.h
-- Similarly kwqidh represents the aq$_dequeue_history type.
-- NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 

CREATE TYPE sys.aq$_agent 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020000'
AS OBJECT
( name          varchar2(30), -- M_IDEN, name of a message producer or consumer
  address       varchar2(1024),           -- address where message must be sent
  protocol      number)                -- protocol for communication, must be 0
/

CREATE TYPE sys.aq$_dequeue_history 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020001'
AS OBJECT
( consumer              varchar2(30),                    -- identifies dequeuer
  transaction_id        varchar2(22),     -- M_LTID, transaction id of dequeuer
  deq_time              date,                                -- time of dequeue
  deq_user              number,         -- user id of client performing dequeue
  remote_apps           varchar2(4000),        -- string repn. of remote agents
  agent_naming          number,            -- how was the message sent to agent
  propagated_msgid      raw(16))                  -- message id in remote queue
/

-- TODO. Ideally the collection types below should be unbounded. We can use 
 -- nested tables for this purpose but nested tables are stored out-of-line and 
-- may hence cause a performance hit. If the limit for the collections below
-- is an issue and nested tables is not an acceptable solution we may have
-- to use a LONG datatype for storing this information and parse it ourselves.
-- It is possible, however, that unbounded varrays may be supported in 8.1

CREATE TYPE sys.aq$_subscribers 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020002'
AS VARRAY(1024) OF sys.aq$_agent 
/

CREATE TYPE sys.aq$_recipients 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020003'
AS VARRAY(1024) OF sys.aq$_agent 
/
       
CREATE TYPE sys.aq$_history 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020004'
AS VARRAY(1024) OF sys.aq$_dequeue_history 
/

CREATE TYPE sys.aq$_dequeue_history_t 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000020005'
AS TABLE of sys.aq$_dequeue_history 
/

-- create type for propagation notify queue
CREATE TYPE sys.aq$_notify_msg AS OBJECT (
        opcode INTEGER, qid RAW(16), dest VARCHAR2(128))
/

--  Signature properties contain the signature for non-repudiation
--  It has just the signature for now
CREATE TYPE sys.aq$_sig_prop
TIMESTAMP '2000-09-28:12:59:00' OID '00000000000000000000000000020006'
 AS OBJECT 
  (signature         RAW(2000),
   canalgo           varchar2(2000),
   digalgo           varchar2(2000),
   sigalgo           varchar2(2000),
   certificate       varchar2(2000),
   digval            RAW(2000))
/


-- Array of message ids
create TYPE aq$_midarray as varray(1024) of VARCHAR2(32);
/

-- TODO: For some reason, must grant execute on these types to system as well
grant execute on sys.aq$_agent to PUBLIC with grant option
/
grant execute on sys.aq$_dequeue_history to PUBLIC with grant option
/
grant execute on sys.aq$_subscribers to PUBLIC with grant option
/
grant execute on sys.aq$_recipients to PUBLIC with grant option
/
grant execute on sys.aq$_history to PUBLIC with grant option
/
grant execute on sys.aq$_notify_msg to PUBLIC with grant option
/
grant execute on sys.aq$_sig_prop to PUBLIC with grant option
/
grant execute on sys.aq$_midarray to PUBLIC with grant option
/

-- Create the table with information about all the queue tables in the system
CREATE TABLE system.aq$_queue_tables(
        schema          VARCHAR2(30)     --     name of the schema the queue 
                        NOT NULL,        --     table belongs to
        name            VARCHAR2(30)     --     name of the queue table
                        NOT NULL,
        udata_type      NUMBER           --     userdata type: 1 for OBJECT
                        NOT NULL,        --                    2 for VARIANT
        objno           NUMBER NOT NULL, --     object number
        flags           NUMBER NOT NULL, --     queue table properties
                                         --     1 for multiple dequeues
                                         --     2 for transactional grouping
                                         --     4 for table exported but
                                         --       dequeue iot not patched.
                                         --     8 for 8.1 multi-consumer qtable
                                         --    16 for table exported but
                                         --       history iot not patched.
                                         --    32 for table exported but
                                         --       timemanager iot not imported
                                         --    64 for table exported but
                                         --       subscribers not imported
                                         --   128 for upgrade in progress
                                         --   256 for downgrade in progress
                                         --   512  for non-repupiate_sender q
                                         --  1024  for non repudiating both
                                         --        the sender and the reciever
                                         --  2048  table exported but signature
                                         --        iot not patched
                                         --  4096 secure queue table
                                         --       user/agent mapping enforced
                                         --  8192 10i style queue table
                                         --  16384 use 10.0 name format
                                         --  32768 do post-TTS steps
                                         --  65536 post-TTS rebuild indexes
                                         --  131072 buffered tables, defer ddl
                                         --  2097152 table exported but commit
                                         --          time iot not patched.
                                         --  8388608 dequeue log not patched
        sort_cols       NUMBER NOT NULL, --     sort order for dequeue
                                         --     1 sort by priority
                                         --     2 sort by enq_time
                                         --     3 sort by priority, enq_time
                                         --     4 sort by commit_time
                                         --     5 sort by priority, commit_time
                                         --     7 sort by enq_time, prioirty
        timezone        VARCHAR2(64),    --     queue table timezone
        table_comment   VARCHAR2(2000),  --     user comment
CONSTRAINT aq$_queue_tables_primary PRIMARY KEY (objno))
/

create index system.i1_queue_tables on system.aq$_queue_tables (objno,
               schema, flags); 

-- Contains information on all the queues in the system
CREATE TABLE system.aq$_queues( 
        oid             RAW(16),                -- queue identifier which is
                                                -- globally used to identify
                                                -- a queue
        eventid         NUMBER NOT NULL,        -- queue id used as event id
        name            VARCHAR2(30) NOT NULL,  -- name of a queue
        table_objno     NUMBER NOT NULL,        -- object no. of the queue 
                                                -- table
        usage           NUMBER NOT NULL,        -- usage of the queue:
                                                -- 0 for normal queue
                                                -- 1 for exception queue
                                                -- 2 for non_persistent queues
        enable_flag     NUMBER NOT NULL,        -- queue enabled?
                                                -- 0x01 enqueue enabled
                                                -- 0x02 dequeue enabled
                                                -- 0x04 flow control off
        max_retries     NUMBER,                 -- maximum number of retries
        retry_delay     NUMBER,                 -- delay before retrying (secs)
        properties      NUMBER,                 -- various properties of
                                                -- queues
                                                -- 0x0001 tracking on
                                                -- 0x0002 multiple dequeues
                                                -- 0x0004 deq by bundling txn
                                                -- 0x0008 new style 8.1q
                                                -- 0x0010 qtable is unusable
                                                -- 0x0020 non-repudiate sender
                                                -- 0x0040 non-rep sender/rcver
                                                -- 0x0080 exception queue
                                                -- 0x0100 q metadata incomp.
                                                -- 0x0200 buffered queue
        ret_time        NUMBER,                 -- retention time (in seconds)
        queue_comment   VARCHAR2(2000),         -- user comment
        subscribers     sys.aq$_subscribers,    -- varray of aq$_agents
        memory_threshold NUMBER,                -- memory threshold 
        service_name    VARCHAR2(64),           -- short service name
        network_name    VARCHAR2(256),          -- network name appended to 
                                                -- db_name.db_domain
CONSTRAINT aq$_queues_check UNIQUE(name, table_objno),
CONSTRAINT aq$_queues_primary PRIMARY KEY (oid))
/

create index system.i1_queues on system.aq$_queues(name, eventid, table_objno);


-- Contains information about acknowledged messages for buffered messages
CREATE TABLE sys.aq$_replay_info( 
        eventid         NUMBER NOT NULL,        -- queue id used as event id
        agent           sys.aq$_agent NOT NULL, -- sender agent
        correlationid   varchar2(128),           -- correlation id.
        ack             NUMBER                  -- ack for propagation
)
/

-- contains information about queue table affinities (for OPS)
--
CREATE TABLE sys.aq$_queue_table_affinities(
       table_objno        NUMBER   NOT NULL,  -- table object number 
       primary_instance   NUMBER   NOT NULL,  --  primary owner instance-id
       secondary_instance NUMBER   NOT NULL,  --  secondary owner instance-id
       owner_instance     NUMBER   NOT NULL,  --  current owner instance-id
CONSTRAINT aq$_qtable_affinities_pk PRIMARY KEY (table_objno))
/

-- index for better faster queue table repartitioning
CREATE INDEX sys.i1_queue_table_affinities on sys.aq$_queue_table_affinities(
       owner_instance, table_objno);

-- Create AQ$_SUBSCRIBER_TABLE
-- contains rows of "removed subscribers" in the system; used in cleanup of
-- "orphaned messages of these subscribers" and also these subscriber rows
-- from schema subscriber table.
CREATE TABLE sys.aq$_subscriber_table(
        schema          VARCHAR2(30) NOT NULL, --  name of the schema the queue
                                               --              table belongs to
        table_name      VARCHAR2(30) NOT NULL, --       name of the queue table
        table_objno     NUMBER NOT NULL,       --     queue table object number
        queue_id        NUMBER NOT NULL,       --     queue id used as event id
        subscriber_id   NUMBER NOT NULL,       --          subsriber identifier
        queue_name      VARCHAR2(30) NOT NULL, --               name of a queue
        name            VARCHAR2(30) DEFAULT NULL, --            subsriber name
        address         VARCHAR2(1024) DEFAULT NULL, --      subscriber address
        protocol        NUMBER,                --           subscriber protocol 
        subscriber_type NUMBER,                --          status of subscriber
        rule_name       VARCHAR2(30),          --          subscriber rule name
        trans_name      VARCHAR2(65),          --           transformation name
        ruleset_name    VARCHAR2(65),          --      subscriber rule set name 
        negative_ruleset_name VARCHAR2(65),    --        negative rule set name
        creation_time   TIMESTAMP WITH TIME ZONE, --   subscriber creation time 
        modification_time TIMESTAMP WITH TIME ZONE, --    alter subscriber time
        deletion_time     TIMESTAMP WITH TIME ZONE,  --   subscriber removal time 
        scn_at_remove     NUMBER,                --     SCN at subscriber removal
        scn_at_add        NUMBER,                --         SCN at add subscriber
        client_session_guid  VARCHAR2(36),          --  conn_guid passed from client
        instance_id       NUMBER,              --  instance that added subscriber
CONSTRAINT aq$_subscriber_table_primary PRIMARY KEY (table_objno,subscriber_id)
)
/

CREATE INDEX sys.aq$_subscriber_table_i ON sys.aq$_subscriber_table(subscriber_type)
/

DELETE FROM sys.aq$_subscriber_table WHERE subscriber_id = 0;
/

INSERT INTO sys.aq$_subscriber_table (schema, table_name, table_objno, queue_id, subscriber_id, queue_name) VALUES('0','0', 0, 0, 0, '0')
/

--Create a Global context to maintain a JM session to DB session relation
--for AQJMS non-durable subscribers
CREATE OR REPLACE CONTEXT global_aqclntdb_ctx USING dbms_aqjms ACCESSED GLOBALLY
/

-- NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
-- Please do not add tables needed by the time manager after aq$_schedules.
-- Reason: Time manager checks for the existence of aq$_schedules before 
-- starting.
-- NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
 
-- Contains information on all the schedules in the system
CREATE TABLE system.aq$_schedules( 
        oid             RAW(16),                -- queue identifier which is
                                                -- globally used to identify
                                                -- a queue
        destination     VARCHAR2(128) NOT NULL, -- dblink, for now 
        start_time      DATE,                   -- seconds since midnight 
                                                -- to start propagating
        duration        VARCHAR2(8),            -- propagation window in
                                                -- seconds
        next_time       VARCHAR2(128),          -- function to compute next
                                                -- window wrt to end of 
                                                -- current window
        latency         VARCHAR2(8),            -- maximum delay in seconds
                                                -- to propagate a message
                                                -- after it is enqueued
        last_time       DATE,                   -- last time that messages were 
                                                -- propagated successfully 
        jobno           NUMBER,                 -- job number in the job queue
                                                -- that will propagate the 
                                                -- messages
CONSTRAINT aq$_schedules_check UNIQUE(jobno),
CONSTRAINT aq$_schedules_primary PRIMARY KEY (oid, destination))
/

-- To avoid import export problems, from 8.1 onwares the schedules information
-- is stored in the sys schema 
CREATE TABLE sys.aq$_schedules( 
        oid             RAW(16),                -- queue identifier which is
                                                -- globally used to identify
                                                -- a queue
        destination     VARCHAR2(128) NOT NULL, -- dblink, for now 
        start_time      DATE,                   -- !!! NOT USED !!!
                                                -- dba_scheduler_job.
                                                -- start_Date
        duration        VARCHAR2(8),            -- propagation window in  
                                                -- seconds
        next_time       VARCHAR2(200),          --   !!!!NOT USED!!!
                                                -- dba_scheduler_job.
                                                -- Repeat_Interval
                                                -- 
        latency         VARCHAR2(8),            -- maximum delay in seconds
                                                -- to propagate a message
                                                -- after it is enqueued
        last_run        DATE,                   --   !!!!NOT USED!!!
                                                --  dba_scheduler_job.
                                                --  LAST_START_DATE
                                                -- 
        jobno           NUMBER,                 --   !!!!NOT USED!!!
                                                --     --NULL--
        failures        NUMBER,                 --   !!!!NOT USED!!!
                                                --  dba_scheduler_job.
                                                --  failure_count
        disabled        VARCHAR2(1),            --   !!!!NOT USED!!!
                                                --  dba_scheduler_job.state
                                                -- 
        error_time      DATE,                   -- date and time of last 
                                                -- unsuccessful execution
                                                --
        last_error_msg  VARCHAR2(4000),         -- error message text
                                                --
        cur_start_time  DATE,                   --  !!! NOT USED !!!
                                                --  dba_scheduler_job_run_deta
                                                -- ilsa.ctual_start_date 
                                                --  
        next_run        DATE,                   -- !!!!NOT USED!!!
                                                --  dba_Scheduler_job.
                                                --  next_run_date
                                                --
        process_name    VARCHAR2(8),            -- !!!!NOT USED!!!
                                                -- dba_scheduler_job_run.detai
                                                -- ls.slave_pid join with
                                                -- v$process
        sid             NUMBER,                 -- !!!!NOT USED!!!
                                                --  dba_scheduler_job_run.detai
                                                --  session_id
                                                --
        serial          NUMBER,                 -- !!!!NOT USED!!!
                                                --   -- null - 
        total_time      NUMBER,                 --
                                                -- dba_Scheduler_job_run_
                                                -- details.elapsed_time
                                                -- 
        total_msgs      NUMBER,                 -- total number of messages
                                                -- transferred in this 
                                                -- schedule
        total_bytes     NUMBER,                 -- total number of bytes in 
                                                -- all messages transferred
                                                -- in this schedule
        total_windows   NUMBER,                 -- total number of windows
                                                -- for this schedule
        win_msgs        NUMBER,                 -- number of messages thus 
                                                -- far in this window
        win_bytes       NUMBER,                 -- number of bytes thus 
                                                -- far in this window
        max_num_per_win NUMBER,                 -- max. number of messages
                                                -- propagated in a window
        max_size        NUMBER,                 -- max. size of a propagated
                                                -- message (bytes) in this 
                                                -- schedule
        instance        NUMBER,                 -- !!!!NOT USED!!!
        spare1          NUMBER,                 -- HTTP propagation batch size
        spare2          VARCHAR2(1024),         -- possible address - unused
        job_name        VARCHAR2(30),           -- name of the scheduler job
        destq           NUMBER,                 -- boolean value specifying
                                                -- whether destination_queue
                                                -- is specified in 
                                                -- schedule_propagation
CONSTRAINT aq$_schedules_primary PRIMARY KEY (oid, destination))
/

-- NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
-- Please do not add tables needed by the time manager after aq$_schedules.
-- Reason: Time manager checks for the existence of aq$_schedules before 
-- starting.
-- NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
-- Contains information on all the message types for propagation

CREATE TABLE sys.aq$_message_types(
        queue_oid       RAW(16) NOT NULL,       -- object id of the source 
                                                -- queue
        schema_name     VARCHAR(30) NOT NULL,   -- schema name at destination
        queue_name      VARCHAR(30) NOT NULL,   -- queue name at destination
        trans_name      VARCHAR2(61),           -- transformation applied to
                                                -- the queue
        destination     VARCHAR2(128) NOT NULL, -- dblink, for now
        toid            RAW(16),                -- msg toid at destination 
        version         NUMBER,
        verified        VARCHAR(1),             -- 'T' if types are equal
                                                -- 'F' otherwise 
        properties      NUMBER,                 -- 0x01 nonrepudiate the sender
                                                -- 0x02 dest is RAC
        network_name    VARCHAR2(256),          -- network name of dest queue
CONSTRAINT aq$_msgtypes_unique  UNIQUE (queue_oid, schema_name, 
                                          queue_name, destination, trans_name))
/

-- aq$_propagation_status contains status information about propagation.
-- Sender:
--      queue_id        - Event id of source queue
--      destination     - dblink address that is target of propagation
--      sequence        - Sequence # of messages that have been sent
--      status          - one of 1 (sent) or 3 (prepared)
-- Receiver:
--      queue_id        - Event id of source queue
--      destination     - dblink address that is source of propagation
--      sequence        - Sequence # of messages that have been received
--      status          - 2 (received)
-- Unused fields:
--      txnid           - Transaction id used by sender for a batch
--      destqueue_id    - Target queue's identifier
--      flags           - type of entry in this table

CREATE TABLE sys.aq$_propagation_status(
        queue_id        NUMBER,                     -- Event id of source queue
        destination     VARCHAR2(128),                        -- dblink address
        sequence        NUMBER,   -- sequence # of messages that have been sent
        status          NUMBER,                               -- one of kwqppst
        txnid           VARCHAR2(22),                                 -- unused
        destqueue_id    NUMBER,                                       -- unused
        flags           NUMBER,                                       -- unused
CONSTRAINT aq$_propagation_status_primary PRIMARY KEY (queue_id, destination,destqueue_id))
/

-- aq$_pending_messages contains message ids and rowids of messages that
-- have been prepared to be sent. This table is only used in the sender side.
-- Enrties are inserted into this table either when a) sender goes to the
-- prepared state or b) sender needs to flush entries to the table when
-- the transaction size is larger than the stream size. A message in 
-- aq$_pending_messages may be propagated to several queues in the remote
-- database (i.e there could be duplicate msgids for the same sequence #). 
-- The copy column in aq$_pending_messages uniquely identifies which remote 
-- queue generated the pmsgid message id on enqueue. If there are n copies for
-- msgid m, the ith copy's pmsgid column is the propagated msgid for the ith 
-- unique address that received this message at the specified destination and 
-- had a type match with the local queue. The copy columns are 1-based. Note
-- that propagator may not send messages even if the type matches if the
-- expiration time has passed. This is OK because we only require that the
-- copy column be in the same order as message sends to a destination. If
-- expiration causes propagation not to send a message to one queue it will
-- not send the message to all subsequent queues.

-- Entries are inserted into sys.aq$_pending_messages during propagation before
-- sending a commit command to the remote database. However, entries are
-- deleted from this table in a deferred fashion (currently it is done
-- as part of updating the schedule) to reduce amount of work to be done
-- during every propagation batch. We must be careful to delete only those
-- entries that are no longer required. Entries are required only when
-- the status column for the corresponding sequence# in aq$_propagation_status
-- is in the prepared state (note that this covers the case where message ids
-- are flushed to disk when propagating a large transaction group). To
-- avoid a join in the purge of the table below we delete all entries whose 
-- sequence# is < minimum of all sequence#s in aq$_propagation_status.

CREATE TABLE sys.aq$_pending_messages(
        sequence        NUMBER,    -- sequence #of messages that have been sent
        msgid           RAW(16),         -- message id sent with above sequence
        copy            NUMBER,                         -- copy# of above msgid
        pmsgid          RAW(16),                       -- propagated message id
        txnid           VARCHAR2(22),                                 -- unused
        flags           NUMBER)                                       -- unused
/

-- This index is used during purging of aq$_pending_messages table
CREATE INDEX sys.aq$_pending_messages_i 
ON sys.aq$_pending_messages(sequence)
/

-- sequence for generating montonically increasing values for each batch of
-- messages. Note that we do not use the ORDER clause because we assume that
-- the propagation scheduler will schedule propagation for a given source queue
-- from the same instance.
CREATE SEQUENCE sys.aq$_propagation_sequence START WITH 1
/

-- contains information about owner instances and their
-- incarnation number (for statistics in OPS) 

CREATE TABLE sys.aq$_queue_statistics(
        eventid        NUMBER,                -- the eventid of the queue
                                              -- unique in a database
        owner_inst     NUMBER,                -- instance number of the owner
                                              -- instance
        incarn_num     NUMBER,                -- incarnation number of the 
                                              -- instance
CONSTRAINT aq$_queue_statitics_pk PRIMARY KEY (eventid))
/

-- NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 
-- Please do not add tables needed by the time manager after aq$_schedules.
-- Reason: Time manager checks for the existence of aq$_schedules before 
-- starting.
-- NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE NOTE 

--
-- CREATE the table for all publishers
--
create table aq$_publisher(
                pub_id            NUMBER NOT NULL,  -- publisher id
                queue_id          NUMBER NOT NULL,  -- queue object id
                p_name            VARCHAR2(30),     -- publisher name
                p_address         VARCHAR2(1024),   -- publisher address
                p_protocol        NUMBER,           -- publisher protocol
                p_rule_name       VARCHAR2(61),     -- publisher rule name
                p_rule            VARCHAR2(2000),   -- rule text
                p_ruleset         VARCHAR2(61),     -- ruleset name
                p_transformation  VARCHAR2(61))     -- transformation name
/

-- Add aq$ tables to noexp$
delete from noexp$ where name like 'AQ$_%'
/
insert into noexp$ (owner, name, obj_type) 
values('SYSTEM', 'AQ$_QUEUE_TABLES', 2)
/
insert into noexp$ (owner, name, obj_type) 
values('SYSTEM', 'AQ$_QUEUES', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'AQ$_SCHEDULES', 2)
/
insert into noexp$(owner, name, obj_type)
values('SYSTEM', 'AQ$_INTERNET_AGENTS', 2)
/
insert into noexp$(owner, name, obj_type)
values('SYSTEM', 'AQ$_INTERNET_AGENT_PRIVS', 2)
/
commit
/

-- Create entries to provide EXP/IMP procedural object support for AQ
delete from sys.exppkgact$ 
where package = 'DBMS_AQ_EXP_QUEUE_TABLES'
or package = 'DBMS_AQ_EXP_INDEX_TABLES'
or package = 'DBMS_AQ_EXP_TIMEMGR_TABLES'
or package = 'DBMS_AQ_EXP_HISTORY_TABLES'
or package = 'DBMS_AQ_EXP_DEQUEUELOG_TABLES'
or package = 'DBMS_AQ_EXP_SUBSCRIBER_TABLES'
or package = 'DBMS_AQ_EXP_SIGNATURE_TABLES'
or package = 'DBMS_AQ_EXP_CMT_TIME_TABLES'
/
delete from sys.exppkgobj$ where package = 'DBMS_AQ_EXP_QUEUES'
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_AQ_EXP_QUEUE_TABLES', 'SYS', 3, 1000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_AQ_EXP_QUEUE_TABLES', 'SYS', 2, 1000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_AQ_EXP_INDEX_TABLES', 'SYS', 3, 2000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_AQ_EXP_TIMEMGR_TABLES', 'SYS', 3, 2000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_AQ_EXP_HISTORY_TABLES', 'SYS', 3, 2000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_AQ_EXP_DEQUEUELOG_TABLES', 'SYS', 3, 2000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_AQ_EXP_SUBSCRIBER_TABLES', 'SYS', 3, 2000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_AQ_EXP_SIGNATURE_TABLES', 'SYS', 3, 2000)
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMS_AQ_EXP_CMT_TIME_TABLES', 'SYS', 3, 2000)
/
insert into sys.exppkgobj$(package, schema, class, type#, prepost, level#) 
values('DBMS_AQ_EXP_QUEUES', 'SYS', 3, 24, 1, 1004)
/
commit
/

-- Create the view DBA_QUEUE_TABLES
create or replace view DBA_QUEUE_TABLES
as 
select t.schema OWNER, t.name QUEUE_TABLE, 
     decode(t.udata_type, 1 , 'OBJECT', 2, 'VARIANT', 3, 'RAW') TYPE,
     u.name || '.' || o.name OBJECT_TYPE,
     decode(t.sort_cols, 0, 'NONE', 1, 'PRIORITY', 2, 'ENQUEUE_TIME',
                               3, 'PRIORITY, ENQUEUE_TIME',
                               4, 'COMMIT_TIME',
                               5, 'PRIORITY, COMMIT_TIME',
                               7, 'ENQUEUE_TIME, PRIORITY') SORT_ORDER,
     decode(bitand(t.flags, 1), 1, 'MULTIPLE', 0, 'SINGLE') RECIPIENTS,
     decode(bitand(t.flags, 2), 2, 'TRANSACTIONAL', 0, 'NONE')MESSAGE_GROUPING,
     decode(bitand(t.flags, 8192+8), 8192+8, '10.0.0', 8, '8.1.3', 0, '8.0.3')COMPATIBLE,
     aft.primary_instance PRIMARY_INSTANCE,
     aft.secondary_instance SECONDARY_INSTANCE,
     aft.owner_instance OWNER_INSTANCE,
     substr(t.table_comment, 1, 50) USER_COMMENT,
     decode(bitand(t.flags, 4096), 4096, 'YES', 0, 'NO') SECURE 
from system.aq$_queue_tables t, sys.col$ c, sys.coltype$ ct, sys.obj$ o,
sys.user$ u, sys.aq$_queue_table_affinities aft
where c.intcol# = ct.intcol# 
and c.obj# = ct.obj# 
and c.name = 'USER_DATA' 
and t.objno = c.obj# 
and o.oid$ = ct.toid
and o.type# = 13
and o.owner# = u.user#
and t.objno = aft.table_objno
union
select t.schema OWNER, t.name QUEUE_TABLE, 
     decode(t.udata_type, 1 , 'OBJECT', 2, 'VARIANT', 3, 'RAW') TYPE, 
     null OBJECT_TYPE,
     decode(t.sort_cols, 0, 'NONE', 1, 'PRIORITY', 2, 'ENQUEUE_TIME',
                               3, 'PRIORITY, ENQUEUE_TIME', 
                               4, 'COMMIT_TIME',
                               5, 'PRIORITY, COMMIT_TIME',
                               7, 'ENQUEUE_TIME, PRIORITY') SORT_ORDER,
     decode(bitand(t.flags, 1), 1, 'MULTIPLE', 0, 'SINGLE') RECIPIENTS,
     decode(bitand(t.flags, 2), 2, 'TRANSACTIONAL', 0, 'NONE')MESSAGE_GROUPING,
     decode(bitand(t.flags, 8192+8), 8192+8, '10.0.0', 8, '8.1.3', 0, '8.0.3')COMPATIBLE,
     aft.primary_instance PRIMARY_INSTANCE,
     aft.secondary_instance SECONDARY_INSTANCE,
     aft.owner_instance OWNER_INSTANCE,
     substr(t.table_comment, 1, 50) USER_COMMENT,
     decode(bitand(t.flags, 4096), 4096, 'YES', 0, 'NO') SECURE 
from system.aq$_queue_tables t, sys.aq$_queue_table_affinities aft
where (t.udata_type = 2
or t.udata_type = 3) 
and t.objno = aft.table_objno 
/
comment on table DBA_QUEUE_TABLES is
'All queue tables created in the database'
/
comment on column DBA_QUEUE_TABLES.OWNER is
'Owner of the queue table'
/
comment on column DBA_QUEUE_TABLES.QUEUE_TABLE is
'Name of the queue table'
/
comment on column DBA_QUEUE_TABLES.TYPE is
'Name of the payload type'
/
comment on column DBA_QUEUE_TABLES.OBJECT_TYPE is
'Name of the payload type for object type payload'
/
comment on column DBA_QUEUE_TABLES.SORT_ORDER is
'Sort order for the queue table'
/
comment on column DBA_QUEUE_TABLES.RECIPIENTS is
'Mulitple or single recipient queue'
/
comment on column DBA_QUEUE_TABLES.MESSAGE_GROUPING is
'Transaction grouping'
/
comment on column DBA_QUEUE_TABLES.COMPATIBLE is
'Compatibility version of the queue table'
/
comment on column DBA_QUEUE_TABLES.PRIMARY_INSTANCE is
'Instance assigned as the primary owner of the queue table'
/
comment on column DBA_QUEUE_TABLES.SECONDARY_INSTANCE is
'Instance assigned as the secondary owner of the queue table'
/
comment on column DBA_QUEUE_TABLES.OWNER_INSTANCE is
'Instance which owns the queue table currently'
/
comment on column DBA_QUEUE_TABLES.USER_COMMENT is 
'User specified comment'
/
comment on column DBA_QUEUE_TABLES.SECURE is 
'Secure queue table'
/
create or replace public synonym DBA_QUEUE_TABLES for SYS.DBA_QUEUE_TABLES
/
grant select on DBA_QUEUE_TABLES to SELECT_CATALOG_ROLE
/


-- Create the view ALL_QUEUE_TABLES
create or replace view ALL_QUEUE_TABLES
as 
select t.schema OWNER, t.name QUEUE_TABLE, 
     decode(t.udata_type, 1 , 'OBJECT', 2, 'VARIANT', 3, 'RAW') TYPE,
     u.name || '.' || o.name OBJECT_TYPE,
     decode(t.sort_cols, 0, 'NONE', 1, 'PRIORITY', 2, 'ENQUEUE_TIME',
                               3, 'PRIORITY, ENQUEUE_TIME', 
                               4, 'COMMIT_TIME',
                               5, 'PRIORITY, COMMIT_TIME',
                               7, 'ENQUEUE_TIME, PRIORITY') SORT_ORDER,
     decode(bitand(t.flags, 1), 1, 'MULTIPLE', 0, 'SINGLE') RECIPIENTS,
     decode(bitand(t.flags, 2), 2, 'TRANSACTIONAL', 0, 'NONE')MESSAGE_GROUPING,
     decode(bitand(t.flags, 8192+8), 8192+8, '10.0.0', 8, '8.1.3', 0, '8.0.3')COMPATIBLE,
     aft.primary_instance PRIMARY_INSTANCE,
     aft.secondary_instance SECONDARY_INSTANCE,
     aft.owner_instance OWNER_INSTANCE,
     substr(t.table_comment, 1, 50) USER_COMMENT,
     decode(bitand(t.flags, 4096), 4096, 'YES', 0, 'NO') SECURE          
from system.aq$_queue_tables t, sys.col$ c, sys.coltype$ ct, sys.obj$ o,
sys.user$ u, sys.aq$_queue_table_affinities aft
where c.intcol# = ct.intcol# 
and c.obj# = ct.obj# 
and c.name = 'USER_DATA' 
and t.objno = c.obj#
and o.oid$ = ct.toid
and o.type# = 13
and o.owner# = u.user#
and t.objno = aft.table_objno
and t.objno in
(select q.table_objno
 from system.aq$_queues q, sys.obj$ ro
 where ro.obj# = q.eventid
 and (ro.owner# = userenv('SCHEMAID')
      or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro))
      or exists (select null from v$enabledprivs
                 where priv_number in (-218 /* MANAGE ANY QUEUE */,
                                       -219 /* ENQUEUE ANY QUEUE */,
                                       -220 /* DEQUEUE ANY QUEUE */))
      or ro.obj# in
           (select q.eventid from system.aq$_queues q, 
                                  system.aq$_queue_tables t
              where q.table_objno = t.objno
              and bitand(t.flags, 8) = 0
              and exists (select null from sys.objauth$ oa, sys.obj$ o
                          where oa.obj# = o.obj#
                          and (o.name = 'DBMS_AQ' or o.name = 'DBMS_AQADM')
                          and o.owner# = 0
                          and o.type# = 9
                          and oa.grantee# = userenv('SCHEMAID')))
     )
)
union
select t.schema OWNER, t.name QUEUE_TABLE, 
     decode(t.udata_type, 1 , 'OBJECT', 2, 'VARIANT', 3, 'RAW') TYPE, 
     null OBJECT_TYPE,
     decode(t.sort_cols, 0, 'NONE', 1, 'PRIORITY', 2, 'ENQUEUE_TIME',
                               3, 'PRIORITY, ENQUEUE_TIME', 
                               4, 'COMMIT_TIME',
                               5, 'PRIORITY, COMMIT_TIME',
                               7, 'ENQUEUE_TIME, PRIORITY') SORT_ORDER,
     decode(bitand(t.flags, 1), 1, 'MULTIPLE', 0, 'SINGLE') RECIPIENTS,
     decode(bitand(t.flags, 2), 2, 'TRANSACTIONAL', 0, 'NONE')MESSAGE_GROUPING,
     decode(bitand(t.flags, 8192+8), 8192+8, '10.0.0', 8, '8.1.3', 0, '8.0.3')COMPATIBLE,
     aft.primary_instance PRIMARY_INSTANCE,
     aft.secondary_instance SECONDARY_INSTANCE,
     aft.owner_instance OWNER_INSTANCE,
     substr(t.table_comment, 1, 50) USER_COMMENT,
     decode(bitand(t.flags, 4096), 4096, 'YES', 0, 'NO') SECURE    
from system.aq$_queue_tables t, sys.aq$_queue_table_affinities aft
where (t.udata_type = 2
or t.udata_type = 3) 
and t.objno = aft.table_objno
and t.objno in
(select q.table_objno
 from system.aq$_queues q, sys.obj$ ro
 where ro.obj# = q.eventid
 and (ro.owner# = userenv('SCHEMAID')
      or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro))
      or exists (select null from v$enabledprivs
                 where priv_number in (-218 /* MANAGE ANY QUEUE */,
                                       -219 /* ENQUEUE ANY QUEUE */,
                                       -220 /* DEQUEUE ANY QUEUE */))
      or ro.obj# in
           (select q.eventid from system.aq$_queues q, 
                                  system.aq$_queue_tables t
              where q.table_objno = t.objno
              and bitand(t.flags, 8) = 0
              and exists (select null from sys.objauth$ oa, sys.obj$ o
                          where oa.obj# = o.obj#
                          and (o.name = 'DBMS_AQ' or o.name = 'DBMS_AQADM')
                          and o.owner# = 0
                          and o.type# = 9
                          and oa.grantee# = userenv('SCHEMAID')))
     )
)
/
comment on table ALL_QUEUE_TABLES is
'All queue tables accessible to the user'
/
comment on column ALL_QUEUE_TABLES.OWNER is
'Owner of the queue table'
/
comment on column ALL_QUEUE_TABLES.QUEUE_TABLE is
'Name of the queue table'
/
comment on column ALL_QUEUE_TABLES.TYPE is
'Name of the payload type'
/
comment on column ALL_QUEUE_TABLES.OBJECT_TYPE is
'Name of the payload type for object type payload'
/
comment on column ALL_QUEUE_TABLES.SORT_ORDER is
'Sort order for the queue table'
/
comment on column ALL_QUEUE_TABLES.RECIPIENTS is
'Mulitple or single recipient queue'
/
comment on column ALL_QUEUE_TABLES.MESSAGE_GROUPING is
'Transaction grouping'
/
comment on column ALL_QUEUE_TABLES.COMPATIBLE is
'Compatibility version of the queue table'
/
comment on column ALL_QUEUE_TABLES.PRIMARY_INSTANCE is
'Instance assigned as the primary owner of the queue table'
/
comment on column ALL_QUEUE_TABLES.SECONDARY_INSTANCE is
'Instance assigned as the secondary owner of the queue table'
/
comment on column ALL_QUEUE_TABLES.OWNER_INSTANCE is
'Instance which owns the queue table currently'
/
comment on column ALL_QUEUE_TABLES.USER_COMMENT is 
'User specified comment'
/
comment on column ALL_QUEUE_TABLES.SECURE is 
'Secure queue table'
/
create or replace public synonym ALL_QUEUE_TABLES for SYS.ALL_QUEUE_TABLES
/
grant select on ALL_QUEUE_TABLES to PUBLIC with grant option
/

-- Create the view USER_QUEUE_TABLES
create or replace view USER_QUEUE_TABLES
as 
select t.name QUEUE_TABLE, 
     decode(t.udata_type, 1 , 'OBJECT', 2, 'VARIANT', 3, 'RAW') TYPE,
     tc.name || '.' || o.name OBJECT_TYPE,
     decode(t.sort_cols, 0, 'NONE', 1, 'PRIORITY', 2, 'ENQUEUE_TIME',
                               3, 'PRIORITY, ENQUEUE_TIME', 
                               4, 'COMMIT_TIME',
                               5, 'PRIORITY, COMMIT_TIME',
                               7, 'ENQUEUE_TIME, PRIORITY') SORT_ORDER,
     decode(bitand(t.flags, 1), 1, 'MULTIPLE', 0, 'SINGLE') RECIPIENTS,
     decode(bitand(t.flags, 2), 2, 'TRANSACTIONAL', 0, 'NONE')MESSAGE_GROUPING,
     decode(bitand(t.flags, 8192+8), 8192+8, '10.0.0', 8, '8.1.3', 0, '8.0.3')COMPATIBLE,
     aft.primary_instance PRIMARY_INSTANCE,
     aft.secondary_instance SECONDARY_INSTANCE,
     aft.owner_instance OWNER_INSTANCE,
     substr(t.table_comment, 1, 50) USER_COMMENT,
     decode(bitand(t.flags, 4096), 4096, 'YES', 0, 'NO') SECURE    
from system.aq$_queue_tables t, sys.col$ c, sys.coltype$ ct, sys.obj$ o,
sys.user$ tc, sys.user$ qc, sys.aq$_queue_table_affinities aft
where c.intcol# = ct.intcol# 
and c.obj# = ct.obj# 
and c.name = 'USER_DATA' 
and t.objno = c.obj# 
and o.oid$ = ct.toid
and o.type# = 13
and o.owner# = tc.user#
and qc.user# = USERENV('SCHEMAID')
and qc.name = t.schema
and t.objno = aft.table_objno
union
select t.name QUEUE_TABLE, 
     decode(t.udata_type, 1 , 'OBJECT', 2, 'VARIANT', 3, 'RAW') TYPE, 
     null OBJECT_TYPE,
     decode(t.sort_cols, 0, 'NONE', 1, 'PRIORITY', 2, 'ENQUEUE_TIME',
                               3, 'PRIORITY, ENQUEUE_TIME', 
                               4, 'COMMIT_TIME',
                               5, 'PRIORITY, COMMIT_TIME',
                               7, 'ENQUEUE_TIME, PRIORITY') SORT_ORDER,
     decode(bitand(t.flags, 1), 1, 'MULTIPLE', 0, 'SINGLE') RECIPIENTS,
     decode(bitand(t.flags, 2), 2, 'TRANSACTIONAL', 0, 'NONE')MESSAGE_GROUPING,
     decode(bitand(t.flags, 8192+8), 8192+8, '10.0.0', 8, '8.1.3', 0, '8.0.3')COMPATIBLE,
     aft.primary_instance PRIMARY_INSTANCE,
     aft.secondary_instance SECONDARY_INSTANCE,
     aft.owner_instance OWNER_INSTANCE,
     substr(t.table_comment, 1, 50) USER_COMMENT,
     decode(bitand(t.flags, 4096), 4096, 'YES', 0, 'NO') SECURE    
from system.aq$_queue_tables t, sys.user$ qc,
     sys.aq$_queue_table_affinities aft 
where (t.udata_type = 2
or t.udata_type = 3)
and qc.user# = USERENV('SCHEMAID')
and qc.name  = t.schema
and t.objno = aft.table_objno
/
comment on table USER_QUEUE_TABLES is
'All queue tables created by the user'
/
comment on column USER_QUEUE_TABLES.QUEUE_TABLE is
'Name of the queue table'
/
comment on column USER_QUEUE_TABLES.TYPE is
'Name of the payload type'
/
comment on column USER_QUEUE_TABLES.OBJECT_TYPE is
'Name of the payload type for object type payload'
/
comment on column USER_QUEUE_TABLES.SORT_ORDER is
'Sort order for the queue table'
/
comment on column USER_QUEUE_TABLES.RECIPIENTS is
'Mulitple or single recipient queue'
/
comment on column USER_QUEUE_TABLES.MESSAGE_GROUPING is
'Transaction grouping'
/
comment on column USER_QUEUE_TABLES.COMPATIBLE is
'Compatibility version of the queue table'
/
comment on column USER_QUEUE_TABLES.PRIMARY_INSTANCE is
'Instance assigned as the primary owner of the queue table'
/
comment on column USER_QUEUE_TABLES.SECONDARY_INSTANCE is
'Instance assigned as the secondary owner of the queue table'
/
comment on column USER_QUEUE_TABLES.OWNER_INSTANCE is
'Instance which owns the queue table currently'
/
comment on column USER_QUEUE_TABLES.USER_COMMENT is 
'User specified comment'
/
comment on column USER_QUEUE_TABLES.SECURE is 
'Secure queue table'
/
-- Create a synonym for the USER_QUEUE_TABLES view
create or replace public synonym USER_QUEUE_TABLES for SYS.USER_QUEUE_TABLES
/
grant select on USER_QUEUE_TABLES to PUBLIC with grant option
/

--
-- Create the view DBA_QUEUES 
--
create or replace view DBA_QUEUES
as
select u.name OWNER, q.name NAME, t.name QUEUE_TABLE, q.eventid QID,
       decode(q.usage, 1, 'EXCEPTION_QUEUE', 2, 'NON_PERSISTENT_QUEUE', 
              'NORMAL_QUEUE') QUEUE_TYPE,
       q.max_retries MAX_RETRIES, q.retry_delay RETRY_DELAY,
       decode(bitand(q.enable_flag, 1), 1 , '  YES  ', '  NO  ')ENQUEUE_ENABLED,
       decode(bitand(q.enable_flag, 2), 2 , '  YES  ', '  NO  ')DEQUEUE_ENABLED,
       decode(q.ret_time, -1, ' FOREVER', q.ret_time) RETENTION,
       substr(q.queue_comment, 1, 50) USER_COMMENT,
       s.network_name NETWORK_NAME
from system.aq$_queues q, system.aq$_queue_tables t, sys.user$ u, 
dba_services s
where u.name  = t.schema
and   q.table_objno = t.objno
and   q.service_name = s.name (+)
/
comment on table DBA_QUEUES is
'All database queues'
/
comment on column DBA_QUEUES.OWNER is
'Owner of the queue'
/
comment on column DBA_QUEUES.NAME is
'Name of the queue'
/
comment on column DBA_QUEUES.QUEUE_TABLE is
'Name of the table the queue data resides in'
/
comment on column DBA_QUEUES.QID is
'Object number of the queue'
/
comment on column DBA_QUEUES.QUEUE_TYPE is
'Type of the queue'
/
comment on column DBA_QUEUES.MAX_RETRIES is
'Maximum number of retries allowed when dequeuing from the queue'
/
comment on column DBA_QUEUES.RETRY_DELAY is
'Time interval between retries'
/
comment on column DBA_QUEUES.ENQUEUE_ENABLED is
'Queue is enabled for enqueue'
/
comment on column DBA_QUEUES.DEQUEUE_ENABLED is
'Queue is enabled for dequeue'
/
comment on column DBA_QUEUES.RETENTION is
'Time interval processed messages retained in the queue'
/
comment on column DBA_QUEUES.USER_COMMENT is 
'User specified comment'
/
comment on column DBA_QUEUES.NETWORK_NAME is 
'Network name of queue service'
/
create or replace public synonym DBA_QUEUES for DBA_QUEUES
/
grant select on DBA_QUEUES to SELECT_CATALOG_ROLE
/

-- Create the view ALL_QUEUES 
-- This view displays all queues that the user has either ENQUEUE or
-- DEQUEUE privilege on.  If the user has any AQ system privileges,
-- like ENQUEUE_ANY, DEQUEUE_ANY or MANAGE_ANY, all the queues in
-- the system will be displayed by this view.
create or replace view ALL_QUEUES
as
select u.name OWNER, q.name NAME, t.name QUEUE_TABLE, q.eventid QID,
       decode(q.usage, 1, 'EXCEPTION_QUEUE', 2, 'NON_PERSISTENT_QUEUE', 
              'NORMAL_QUEUE') QUEUE_TYPE,
       q.max_retries MAX_RETRIES, q.retry_delay RETRY_DELAY,
       decode(bitand(q.enable_flag, 1), 1 , '  YES  ', '  NO  ')ENQUEUE_ENABLED,
       decode(bitand(q.enable_flag, 2), 2 , '  YES  ', '  NO  ')DEQUEUE_ENABLED,
       decode(q.ret_time, -1, ' FOREVER', q.ret_time) RETENTION,
       substr(q.queue_comment, 1, 50) USER_COMMENT,
       s.network_name NETWORK_NAME
from system.aq$_queues q, system.aq$_queue_tables t, sys.user$ u, sys.obj$ ro,
dba_services s
where u.name  = t.schema
and   q.table_objno = t.objno
and   ro.owner# = u.user#
and   ro.obj# = q.eventid
and  (ro.owner# = userenv('SCHEMAID')
      or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where grantee# in (select kzsrorol from x$kzsro))
      or exists (select null from v$enabledprivs
                 where priv_number in (-218 /* MANAGE ANY QUEUE */,
                                       -219 /* ENQUEUE ANY QUEUE */,
                                       -220 /* DEQUEUE ANY QUEUE */))
      or ro.obj# in
           (select q.eventid from system.aq$_queues q, 
                                  system.aq$_queue_tables t
              where q.table_objno = t.objno
              and bitand(t.flags, 8) = 0
              and exists (select null from sys.objauth$ oa, sys.obj$ o
                          where oa.obj# = o.obj#
                          and (o.name = 'DBMS_AQ' or o.name = 'DBMS_AQADM')
                          and o.owner# = 0 
                          and o.type# = 9
                          and oa.grantee# = userenv('SCHEMAID')))          
     )
and   q.service_name = s.name (+)
/
comment on table ALL_QUEUES is
'All queues accessible to the user'
/
comment on column ALL_QUEUES.OWNER is
'Owner of the queue'
/
comment on column ALL_QUEUES.NAME is
'Name of the queue'
/
comment on column ALL_QUEUES.QUEUE_TABLE is
'Name of the table the queue data resides in'
/
comment on column ALL_QUEUES.QID is
'Object number of the queue'
/
comment on column ALL_QUEUES.QUEUE_TYPE is
'Type of the queue'
/
comment on column ALL_QUEUES.MAX_RETRIES is
'Maximum number of retries allowed when dequeuing from the queue'
/
comment on column ALL_QUEUES.RETRY_DELAY is
'Time interval between retries'
/
comment on column ALL_QUEUES.ENQUEUE_ENABLED is
'Queue is enabled for enqueue'
/
comment on column ALL_QUEUES.DEQUEUE_ENABLED is
'Queue is enabled for dequeue'
/
comment on column ALL_QUEUES.RETENTION is
'Time interval processed messages retained in the queue'
/
comment on column ALL_QUEUES.USER_COMMENT is 
'User specified comment'
/
comment on column ALL_QUEUES.NETWORK_NAME is 
'Network name of queue service'
/
create or replace public synonym ALL_QUEUES for ALL_QUEUES
/
grant select on ALL_QUEUES to PUBLIC with grant option
/

-- Create the view ALL_DEQUEUE_QUEUES 
-- This view displays all queues that the user has DEQUEUE privilege on.  
-- If the user has system privileges DEQUEUE_ANY or MANAGE_ANY,
-- all the queues in the system will be displayed by this view.
create or replace view ALL_DEQUEUE_QUEUES
as
select u.name OWNER, q.name NAME, t.name QUEUE_TABLE, q.eventid QID,
       decode(q.usage, 1, 'EXCEPTION_QUEUE', 2, 'NON_PERSISTENT_QUEUE', 
              'NORMAL_QUEUE') QUEUE_TYPE,
       q.max_retries MAX_RETRIES, q.retry_delay RETRY_DELAY,
       decode(bitand(q.enable_flag, 1), 1 , '  YES  ', '  NO  ')ENQUEUE_ENABLED,
       decode(bitand(q.enable_flag, 2), 2 , '  YES  ', '  NO  ')DEQUEUE_ENABLED,
       decode(q.ret_time, -1, ' FOREVER', q.ret_time) RETENTION,
       substr(q.queue_comment, 1, 50) USER_COMMENT,
       s.network_name NETWORK_NAME
from system.aq$_queues q, system.aq$_queue_tables t, sys.user$ u, sys.obj$ ro,
dba_services s
where u.name  = t.schema
and   q.table_objno = t.objno
and   ro.owner# = u.user#
and   ro.obj# = q.eventid
and  (ro.owner# = userenv('SCHEMAID')
      or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where oa.privilege# in (21, 41) and 
                  grantee# in (select kzsrorol from x$kzsro))
      or exists (select null from v$enabledprivs
                 where priv_number in (-218 /* MANAGE ANY QUEUE */,
                                       -220 /* DEQUEUE ANY QUEUE */))
      or ro.obj# in
           (select q.eventid from system.aq$_queues q, 
                                  system.aq$_queue_tables t
              where q.table_objno = t.objno
              and bitand(t.flags, 8) = 0
              and exists (select null from sys.objauth$ oa, sys.obj$ o
                          where oa.obj# = o.obj#
                          and (o.name = 'DBMS_AQ' or o.name = 'DBMS_AQADM')
                          and o.owner# = 0
                          and o.type# = 9
                          and oa.grantee# = userenv('SCHEMAID')))          
     )
and   q.service_name = s.name (+)
/
comment on table ALL_DEQUEUE_QUEUES is
'All queues accessible to the user'
/
comment on column ALL_DEQUEUE_QUEUES.OWNER is
'Owner of the queue'
/
comment on column ALL_DEQUEUE_QUEUES.NAME is
'Name of the queue'
/
comment on column ALL_DEQUEUE_QUEUES.QUEUE_TABLE is
'Name of the table the queue data resides in'
/
comment on column ALL_DEQUEUE_QUEUES.QID is
'Object number of the queue'
/
comment on column ALL_DEQUEUE_QUEUES.QUEUE_TYPE is
'Type of the queue'
/
comment on column ALL_DEQUEUE_QUEUES.MAX_RETRIES is
'Maximum number of retries allowed when dequeuing from the queue'
/
comment on column ALL_DEQUEUE_QUEUES.RETRY_DELAY is
'Time interval between retries'
/
comment on column ALL_DEQUEUE_QUEUES.ENQUEUE_ENABLED is
'Queue is enabled for enqueue'
/
comment on column ALL_DEQUEUE_QUEUES.DEQUEUE_ENABLED is
'Queue is enabled for dequeue'
/
comment on column ALL_DEQUEUE_QUEUES.RETENTION is
'Time interval processed messages retained in the queue'
/
comment on column ALL_DEQUEUE_QUEUES.USER_COMMENT is 
'User specified comment'
/
comment on column ALL_DEQUEUE_QUEUES.NETWORK_NAME is 
'Network name of queue service'
/
create or replace public synonym ALL_DEQUEUE_QUEUES for ALL_DEQUEUE_QUEUES
/
grant select on ALL_DEQUEUE_QUEUES to PUBLIC with grant option
/

create or replace view ALL_INT_DEQUEUE_QUEUES
as
select /*+ ORDERED NO_USE_MERGE(ro) */
      t.schema OWNER, q.name NAME, q.eventid QID
from system.aq$_queues q, system.aq$_queue_tables t,sys.obj$ ro
where q.table_objno = t.objno
and   ro.obj# = q.eventid
and  (ro.owner# = userenv('SCHEMAID')
      or ro.obj# in
           (select oa.obj#
            from sys.objauth$ oa
            where oa.privilege# = 21 and
                  grantee# in (select kzsrorol from x$kzsro))
      or exists (select null from v$enabledprivs
                 where priv_number in (-218 /* MANAGE ANY QUEUE */,
                                       -220 /* DEQUEUE ANY QUEUE */))
      or (bitand(t.flags, 8) = 0
          and (exists (select null from sys.objauth$ oa, sys.obj$ o
                      where oa.obj# = o.obj#
                      and o.owner# = 0
                      and (o.name = 'DBMS_AQ' or  o.name = 'DBMS_AQADM')
                      and o.type# = 9
                      and oa.grantee# = userenv('SCHEMAID'))))
     )
/

comment on table ALL_INT_DEQUEUE_QUEUES is
'All queues accessible to the user'
/
comment on column ALL_INT_DEQUEUE_QUEUES.OWNER is
'Owner of the queue'
/
comment on column ALL_INT_DEQUEUE_QUEUES.NAME is
'Name of the queue'
/
comment on column ALL_INT_DEQUEUE_QUEUES.QID is
'Object number of the queue'
/
create or replace public synonym ALL_INT_DEQUEUE_QUEUES for ALL_INT_DEQUEUE_QUEUES
/
grant select on ALL_INT_DEQUEUE_QUEUES  to PUBLIC with grant option
/


--
-- Create the view USER_QUEUES
--
create or replace view USER_QUEUES
as
select q.name NAME, t.name QUEUE_TABLE, q.eventid QID,
       decode(q.usage, 1, 'EXCEPTION_QUEUE', 2, 'NON_PERSISTENT_QUEUE', 
              'NORMAL_QUEUE') QUEUE_TYPE,
       q.max_retries MAX_RETRIES, q.retry_delay RETRY_DELAY,
       decode(bitand(q.enable_flag, 1), 1 , '  YES  ', '  NO  ')ENQUEUE_ENABLED,
       decode(bitand(q.enable_flag, 2), 2 , '  YES  ', '  NO  ')DEQUEUE_ENABLED,
       decode(q.ret_time, -1, ' FOREVER', q.ret_time) RETENTION,
       substr(q.queue_comment, 1, 50) USER_COMMENT,
       s.network_name NETWORK_NAME
from system.aq$_queues q, system.aq$_queue_tables t, sys.user$ u, 
dba_services s
where u.user# = USERENV('SCHEMAID')
and   u.name  = t.schema
and   q.table_objno = t.objno
and   q.service_name = s.name (+)
/
comment on table USER_QUEUES is
'All queues owned by the user'
/
comment on column USER_QUEUES.NAME is
'Name of the queue'
/
comment on column USER_QUEUES.QUEUE_TABLE is
'Name of the table the queue data resides in'
/
comment on column USER_QUEUES.QID is
'Object number of the queue'
/
comment on column USER_QUEUES.QUEUE_TYPE is
'Type of the queue'
/
comment on column USER_QUEUES.MAX_RETRIES is
'Maximum number of retries allowed when dequeuing from the queue'
/
comment on column USER_QUEUES.RETRY_DELAY is
'Time interval between retries'
/
comment on column USER_QUEUES.ENQUEUE_ENABLED is
'Queue is enabled for enqueue'
/
comment on column USER_QUEUES.DEQUEUE_ENABLED is
'Queue is enabled for dequeue'
/
comment on column USER_QUEUES.RETENTION is
'Time interval processed messages retained in the queue'
/
comment on column USER_QUEUES.USER_COMMENT is 
'User specified comment'
/
comment on column USER_QUEUES.NETWORK_NAME is 
'Network name of queue service'
/
create or replace public synonym USER_QUEUES for USER_QUEUES
/
grant select on USER_QUEUES to PUBLIC with grant option
/

-- Create the view DBA_QUEUE_PUBLISHERS
create or replace view DBA_QUEUE_PUBLISHERS
as
 select t.schema QUEUE_OWNER, q.name QUEUE_NAME,
        p.p_name PUBLISHER_NAME, p.p_address PUBLISHER_ADDRESS,
        p.p_protocol PUBLISHER_PROTOCOL, p.p_rule PUBLISHER_RULE,
        p.p_rule_name PUBLISHER_RULE_NAME, p.p_ruleset PUBLISHER_RULESET,
        p.p_transformation PUBLISHER_TRANSFORMATION     
from 
 system.aq$_queue_tables t,  system.aq$_queues q,
 sys.aq$_publisher p, sys.user$ u
where 
 q.table_objno = t.objno and q.eventid = p.queue_id 
 and u.name  = t.schema
/


create or replace public synonym DBA_QUEUE_PUBLISHERS for DBA_QUEUE_PUBLISHERS
/
grant select on DBA_QUEUE_PUBLISHERS to SELECT_CATALOG_ROLE
/


create or replace view ALL_QUEUE_PUBLISHERS
as
 select t.schema QUEUE_OWNER, q.name QUEUE_NAME,
        p.p_name PUBLISHER_NAME, p.p_address PUBLISHER_ADDRESS,
        p.p_protocol PUBLISHER_PROTOCOL, p.p_rule PUBLISHER_RULE,
        p.p_rule_name PUBLISHER_RULE_NAME, p.p_ruleset PUBLISHER_RULESET,
        p.p_transformation PUBLISHER_TRANSFORMATION     
from 
 system.aq$_queue_tables t,  system.aq$_queues q,
 sys.aq$_publisher p, sys.user$ u
where 
 u.user# = USERENV('SCHEMAID') and
 u.name = t.schema and q.table_objno = t.objno
 and q.eventid = p.queue_id
/

create or replace public synonym ALL_QUEUE_PUBLISHERS for ALL_QUEUE_PUBLISHERS
/
grant select on ALL_QUEUE_PUBLISHERS to PUBLIC with grant option
/


create or replace view USER_QUEUE_PUBLISHERS
as
 select q.name QUEUE_NAME,
        p.p_name PUBLISHER_NAME, p.p_address PUBLISHER_ADDRESS,
        p.p_protocol PUBLISHER_PROTOCOL, p.p_rule PUBLISHER_RULE,
        p.p_rule_name PUBLISHER_RULE_NAME, p.p_ruleset PUBLISHER_RULESET,
        p.p_transformation PUBLISHER_TRANSFORMATION     
from 
 system.aq$_queue_tables t,  system.aq$_queues q,
 sys.aq$_publisher p, sys.user$ u
where 
 u.user# = USERENV('SCHEMAID') and
 u.name = t.schema and q.table_objno = t.objno
 and q.eventid = p.queue_id
/

create or replace public synonym USER_QUEUE_PUBLISHERS for USER_QUEUE_PUBLISHERS
/
grant select on USER_QUEUE_PUBLISHERS to PUBLIC with grant option
/

-- Create the view QUEUE_PRIVILEGES
-- This view displays all AQ object level privileges granted to or
-- granted by the user.

create or replace view QUEUE_PRIVILEGES
as 
select ue.name GRANTEE, u.name OWNER, o.name NAME, ur.name GRANTOR,
decode(sum(privilege#), 20, 1, 41, 1, 0) ENQUEUE_PRIVILEGE, 
decode(sum(oa.privilege#), 21, 1, 41, 1, 0) DEQUEUE_PRIVILEGE
from sys.objauth$ oa, sys.obj$ o, sys.user$ ue, sys.user$ ur, sys.user$ u
where oa.obj# = o.obj#
  and o.type# = 24
  and oa.grantor# = ur.user#
  and oa.grantee# = ue.user#
  and u.user# = o.owner#
  and (oa.grantor# = userenv('SCHEMAID') or
       oa.grantee# in (select kzsrorol from x$kzsro) or
       o.owner# = userenv('SCHEMAID'))
group by u.name, o.name, ur.name, ue.name
/
comment on table QUEUE_PRIVILEGES is
'Grants on queues for which the user is the grantor, grantee, owner, 
 or an enabled role or PUBLIC is the grantee'
/
comment on column QUEUE_PRIVILEGES.GRANTEE is
'Name of the user to whom access was granted'
/
comment on column QUEUE_PRIVILEGES.OWNER is
'Owner of the object'
/
comment on column QUEUE_PRIVILEGES.NAME is
'Name of the object'
/
comment on column QUEUE_PRIVILEGES.GRANTOR is
'Name of the user who performed the grant'
/
comment on column QUEUE_PRIVILEGES.ENQUEUE_PRIVILEGE is
'Permission to ENQUEUE to the queue'
/
comment on column QUEUE_PRIVILEGES.DEQUEUE_PRIVILEGE is
'Permission to DEQUEUE from the queue'
/
create or replace public synonym QUEUE_PRIVILEGES for QUEUE_PRIVILEGES
/
grant select on QUEUE_PRIVILEGES to PUBLIC with grant option
/
 
-- Create GV$AQ and V$AQ views for AQ statistics

create or replace view v_$aq as
  select QID, WAITING, READY, EXPIRED, AVERAGE_MSG_AGE, 
         TOTAL_WAIT, AVERAGE_WAIT from v$aq1
/ 
create or replace public synonym v$aq for v_$aq
/
grant select on v_$aq to select_catalog_role
/

create or replace view gv_$aq as
 select qid, sum(WAITING) waiting, sum(READY) ready, sum(EXPIRED) expired,
   decode(sum(WAITING+READY+EXPIRED),0,0,max(average_msg_age)) average_msg_age,
   decode(sum(TOTAL_CONSUMERS),0,0,max(TOTAL_WAIT)) total_wait,
   decode(sum(TOTAL_CONSUMERS), 
          0, 0, TRUNC(max(TOTAL_WAIT)/max(TOTAL_CONSUMERS))) average_wait
 from   gv$aq1 group by qid
/
create or replace public synonym gv$aq for gv_$aq
/
grant select on gv_$aq to select_catalog_role
/

-- create a table that stores agent names - for AQ internet access
-- also contains protocol (spare1 column is for possible later use
-- to store authentication information)

CREATE TABLE SYSTEM.AQ$_Internet_Agents (
       agent_name       VARCHAR2(30) NOT NULL ENABLE PRIMARY KEY, 
       protocol         INTEGER NOT NULL, 
       spare1           VARCHAR2(128)
);

-- the table that stores the agent name to database user mapping
-- note that the foreign key constraint means any agent_name in
-- this table must first be in SYSTEM.AQ$_Internet_Agents


CREATE TABLE SYSTEM.AQ$_Internet_Agent_Privs (
       agent_name    VARCHAR2(30) NOT NULL,
       db_username   VARCHAR2(30) NOT NULL,
       CONSTRAINT agent_must_be_created FOREIGN KEY (agent_name) REFERENCES SYSTEM.AQ$_Internet_Agents ON DELETE CASCADE,
       CONSTRAINT unq_pairs UNIQUE (agent_name, db_username)
);


-- a view which shows the db usernames associated with an agent name
-- and their protocol - first sub query gets those agent names that have
-- rows in SYSTEM.AQ$_Internet_Agent_Privs, the second subquery gets those
-- agent names that are not
CREATE OR REPLACE VIEW AQ$Internet_Users AS (SELECT t.agent_name, t.db_username, decode(bitand(u.protocol, 1), 0, 'NO  ', 1, 'YES ') http_enabled, decode(bitand(u.protocol, 2), 0, 'NO  ', 2, 'YES ') smtp_enabled, decode(bitand(u.protocol, 4), 0, 'NO  ', 4, 'YES ') ftp_enabled FROM SYSTEM.AQ$_Internet_Agent_Privs t, SYSTEM.AQ$_Internet_Agents u WHERE t.agent_name = u.agent_name UNION (SELECT x.agent_name, NULL, decode(bitand(x.protocol, 1), 0, 'NO  ', 1, 'YES ') http_enabled, decode(bitand(x.protocol, 2), 0, 'NO  ', 2, 'YES ') smtp_enabled, decode(bitand(x.protocol, 4), 0, 'NO  ', 4, 'YES ') ftp_enabled FROM SYSTEM.AQ$_Internet_Agents x WHERE (x.agent_name NOT IN (SELECT y.agent_name FROM SYSTEM.AQ$_Internet_Agent_Privs y))));

create or replace public synonym AQ$Internet_Users for SYS.AQ$Internet_Users
/

-- create a view of registered AQ agents
create or replace view DBA_AQ_AGENTS as SELECT u.agent_name, decode(bitand(u.protocol, 1), 0, 'NO  ', 1, 'YES ') http_enabled, decode(bitand(u.protocol, 2), 0, 'NO  ', 2, 'YES ') smtp_enabled FROM SYSTEM.AQ$_Internet_Agents u;

create or replace public synonym DBA_AQ_AGENTS for DBA_AQ_AGENTS
/
grant select on DBA_AQ_AGENTS to SELECT_CATALOG_ROLE
/

-- view of registered AQ agents and their mapping to db users
create or replace view DBA_AQ_AGENT_PRIVS as (SELECT u.agent_name, t.db_username, decode(bitand(u.protocol, 1), 0, 'NO  ', 1, 'YES ') http_enabled, decode(bitand(u.protocol, 2), 0, 'NO  ', 2, 'YES ') smtp_enabled FROM SYSTEM.AQ$_Internet_Agent_Privs t RIGHT OUTER JOIN  SYSTEM.AQ$_Internet_Agents u ON t.agent_name = u.agent_name);

create or replace public synonym DBA_AQ_AGENT_PRIVS for DBA_AQ_AGENT_PRIVS
/
grant select on DBA_AQ_AGENT_PRIVS to SELECT_CATALOG_ROLE
/

-- view of registered AQ agents mapped to a particular db user
create or replace view USER_AQ_AGENT_PRIVS as SELECT u.agent_name, decode(bitand(u.protocol, 1), 0, 'NO  ', 1, 'YES ') http_enabled, decode(bitand(u.protocol, 2), 0, 'NO  ', 2, 'YES ') smtp_enabled FROM SYSTEM.AQ$_Internet_Agent_Privs t, SYSTEM.AQ$_Internet_Agents u, sys.user$ usr where u.agent_name = t.agent_name and usr.user# = USERENV('SCHEMAID') and usr.name = t.db_username;

create or replace public synonym USER_AQ_AGENT_PRIVS for USER_AQ_AGENT_PRIVS
/
grant select on USER_AQ_AGENT_PRIVS to PUBLIC with GRANT option
/


-- Creating a sequence for generating message identifiers for messages
CREATE SEQUENCE sys.aq$_chainseq START WITH 1
/

-- Creating a sequence for  iot enqueue transaction id
CREATE SEQUENCE sys.aq$_iotenqtxid START WITH 1 CACHE 1000
/
 
-- Creating a sequence for naming publisher subscriber rule sets
CREATE SEQUENCE sys.aq$_rule_set_sequence START WITH 1 CACHE 1000
/

-- Creating a sequence for name publisher, subscriber rules
CREATE SEQUENCE sys.aq$_rule_sequence START WITH 1 CACHE 1000
/


-- Creating a sequence for name publisher, subscriber rules
CREATE SEQUENCE sys.aq$_publisher_sequence START WITH 1 CACHE 1000
/

-- Creating a sequence for non-durable subscriber names
CREATE SEQUENCE sys.aq$_nondursub_sequence INCREMENT BY 1 START WITH 1
/

-- Create the library where 3GL callouts will reside
CREATE OR REPLACE LIBRARY dbms_aq_lib trusted as static
/

-- Create the library where 3GL callouts will reside
CREATE OR REPLACE LIBRARY dbms_aqadm_lib trusted as static
/

-- Create the library where 3GL callouts will reside
CREATE OR REPLACE LIBRARY dbms_aq_ldap_lib trusted as static
/

-- Create the library where email notifications are mad
CREATE OR REPLACE LIBRARY dbms_aqelm_lib trusted as static
/

-- create type for storing the message properties
-- The only reason for creaing this new type (which is a replica of the
-- pl/sql  record message_properties_t) is that we cannot have a record 
-- field inside a ADT
CREATE or replace TYPE sys.msg_prop_t AS OBJECT (
       priority          number,
       delay             number,
       expiration        number,
       correlation       varchar2(128),
       attempts          number,
       exception_queue   varchar2(51),
       enqueue_time      date,
       state             number,
       sender_id         aq$_agent,
       original_msgid    raw(16),
       delivery_mode     number);
/


-- create type for storing generic ntfn descriptor for plsql notification
CREATE or replace TYPE sys.aq$_ntfn_descriptor AS OBJECT (
        ntfn_flags         number)                     -- flags
/

-- create type for storing grouping ntfn data for AQ namespace, value 2^30
-- or 2G which is the max varray size
CREATE or replace TYPE sys.aq$_ntfn_msgid_array 
AS VARRAY(1073741824) OF raw(16);
/

-- create type for storing aq descriptor for plsql notification
CREATE or replace TYPE sys.aq$_descriptor AS OBJECT (
        queue_name       VARCHAR2(65),                -- name of the queue
        consumer_name    VARCHAR2(30),                -- name of the consumer
        msg_id           RAW(16),                     -- message identifier
        msg_prop         msg_prop_t,                  -- message properties
        gen_desc         sys.aq$_ntfn_descriptor,     -- generic descriptor
        msgid_array      sys.aq$_ntfn_msgid_array,    -- grp ntfn msgid list 
        ntfnsRecdInGrp   NUMBER)                      -- ntfns recd in grp
/


-- create type for storing registration information
CREATE  or replace TYPE sys.aq$_reg_info AS OBJECT (
        name                  VARCHAR2(128),  -- name of the subscription
        namespace             NUMBER,         -- namespace of the subscription
        callback              VARCHAR2(4000), -- callback function
        context               RAW(2000),      -- context for the callback func.
        anyctx                SYS.ANYDATA,    -- anydata ctx for callback func
        ctxtype               NUMBER,         -- raw/anydata context
        qosflags              NUMBER,         -- QOS flags
        payloadcbk            VARCHAR2(4000), -- payload callback
        timeout               NUMBER,         -- registration expiration
        ntfn_grouping_class        NUMBER,    -- ntfn grouping class
        ntfn_grouping_value        NUMBER,    -- ntfn grouping value
        ntfn_grouping_type         NUMBER,    -- ntfn grouping type
        ntfn_grouping_start_time   TIMESTAMP WITH TIME ZONE, -- grp start time
        ntfn_grouping_repeat_count NUMBER,    -- ntfn grp repeat count
        CONSTRUCTOR FUNCTION aq$_reg_info(
          name             VARCHAR2,
          namespace        NUMBER,
          callback         VARCHAR2,
          context          RAW)
        RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION aq$_reg_info(
          name             VARCHAR2,
          namespace        NUMBER,
          callback         VARCHAR2,
          context          RAW,
          anyctx           SYS.ANYDATA,
          ctxtype          NUMBER)
        RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION aq$_reg_info(
          name             VARCHAR2,
          namespace        NUMBER,
          callback         VARCHAR2,
          context          RAW,
          qosflags         NUMBER,
          timeout          NUMBER)
        RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION aq$_reg_info(
          name             VARCHAR2,
          namespace        NUMBER,
          callback         VARCHAR2,
          context          RAW,
          anyctx           SYS.ANYDATA,
          ctxtype          NUMBER,
          qosflags         NUMBER,
          payloadcbk       VARCHAR2,
          timeout          NUMBER)
        RETURN SELF AS RESULT,
        CONSTRUCTOR FUNCTION aq$_reg_info(
          name                       VARCHAR2,
          namespace                  NUMBER,
          callback                   VARCHAR2,
          context                    RAW,
          qosflags                   NUMBER,
          timeout                    NUMBER,
          ntfn_grouping_class        NUMBER,
          ntfn_grouping_value        NUMBER,
          ntfn_grouping_type         NUMBER,
          ntfn_grouping_start_time   TIMESTAMP WITH TIME ZONE,
          ntfn_grouping_repeat_count NUMBER)
        RETURN SELF AS RESULT
        );
/

-- create type for storing post information
CREATE  or replace TYPE sys.aq$_post_info AS OBJECT (
        name             VARCHAR2(128),       -- name of the subscription
        namespace        NUMBER,              -- namespace of the subscription
        payload          RAW(32767))          -- payload
/

CREATE or replace TYPE sys.aq$_reg_info_list 
AS VARRAY(1024) OF sys.aq$_reg_info
/

CREATE or replace TYPE sys.aq$_post_info_list 
AS VARRAY(1024) OF sys.aq$_post_info
/

-- type for message that will be stored in aq$_event_table queue table
CREATE OR REPLACE TYPE sys.aq$_event_message
AS OBJECT (
       sub_name            VARCHAR2(128),        -- name of the subscription
       sub_namespace       NUMBER,              -- namespace of the subscription
       payloadt            NUMBER,              -- payload type
       payload             RAW(2000),           -- message payload
       queue_name          VARCHAR2(65),        -- name of the queue
       msg_id              RAW(16),             -- message identifier
       consumer_name       VARCHAR2(30),        -- name of the consumer
       priority            NUMBER,              -- priority
       delay               NUMBER,              -- delay
       expiration          NUMBER,              -- expiration
       attempts            NUMBER,              -- number of attempts
       enqueue_time        DATE,                -- time of enqueue
       state               NUMBER,              -- state
       exception_queue     VARCHAR2(51),        -- exception queue
       correlation         VARCHAR2(128),       -- correlation
       original_msgid      RAW(16),             -- original message id
       agent_name          VARCHAR2(30),        -- sender name
       agent_address       VARCHAR2(1024),      -- sender address
       agent_protocol      NUMBER,              -- sender protocol
       recipient_list      SYS.AQ$_RECIPIENTS,  -- recipient list
       xmlpayload          VARCHAR2(4000),      -- payload in xml, if reqd.
       pblob               BLOB)                -- blob for storing raw payload
                                                -- for 11.0 compatible
/

CREATE OR REPLACE TYPE aq$_srvntfn_message AS OBJECT (
       queue_name        VARCHAR2(65),        -- name of the queue
       consumer_name     VARCHAR2(30),        -- name of the consumer
       msg_id            RAW(16),             -- message identifier
       priority          number,
       delay             number,
       expiration        number,
       correlation       varchar2(128),
       attempts          number,
       exception_queue   varchar2(51),
       enqueue_time      date,
       state             number,
       agent_name        varchar2(30),
       agent_address     varchar2(1024),
       agent_protocol    number,
       original_msgid    raw(16),
       sub_name          VARCHAR2(128),       -- name of the subscription
       sub_namespace     NUMBER,              -- namespace of the subscription
       sub_callback      VARCHAR2(4000),      -- callback function
       sub_context       RAW(2000),           -- context for the callback func.
       user_id           number,              -- user identifier
       payload           RAW(2000),
       payloadl          number,
       xmlpayload        VARCHAR2(4000),      -- payload in xml, if reqd.
       payloadt          number,              -- payload type, xml/default
       anysub_context    SYS.ANYDATA,         -- anydata context
       context_type      number,              -- RAW or ANYDATA context     
       delivery_mode     number,              -- delivery mode 
       ntfn_flags        number,              -- generic ntfn flags
       msgid_array       sys.aq$_ntfn_msgid_array,-- grp ntfn msg id array
       ntfnsRecdInGrp    number,                  -- ntfns recd in grp
       pblob             BLOB, -- for storing raw payload in 11 compatible mode
       reg_id            number)              -- registration id
/

-- create type for table function used in xxx_queue_subscribers
CREATE OR REPLACE TYPE sys.aq$_subscriber 
AS OBJECT (
  name          VARCHAR2(30), -- M_IDEN, name of a message producer or consumer
  address       VARCHAR2(1024),           -- address where message must be sent
  protocol      NUMBER,                -- protocol for communication, must be 0
  trans_name    VARCHAR2(61),                             -- tranformation name
  sub_type      NUMBER,                                      -- subscriber type
  rule_name     VARCHAR2(30)                                        --rule name
 );
/
CREATE OR REPLACE TYPE sys.aq$_subscriber_t AS TABLE OF aq$_subscriber;
/

GRANT execute ON sys.aq$_subscriber TO PUBLIC
/
GRANT execute ON sys.aq$_subscriber_t TO PUBLIC
/

-- This aq$_dummy_t should be created after dbms_aq specification is 
-- defined but before dbms_aq body is created.  This will allow
-- aq$_dummy_t to be recreated without invalidating the package.

-- This aq$_dummy_t is needed for sharing the dequeue interface between
-- raw type and object type, should be removed when raw queue gets its
-- own internal interface.

CREATE OR REPLACE TYPE sys.aq$_dummy_t AS OBJECT (data CHAR(1));
/
GRANT EXECUTE ON sys.aq$_dummy_t TO PUBLIC;

-- Create the AQ administrator role
--
CREATE ROLE aq_administrator_role
/

--
--  Grant AQ_ADMINSTRATOR_ROLE to SYSTEM
--
GRANT aq_administrator_role TO system WITH ADMIN OPTION
/

--
-- Create the AQ user role (obsoleted, kept here mainly for 8.0 compatibility)
--
CREATE ROLE aq_user_role
/
