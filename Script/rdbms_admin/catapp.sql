Rem
Rem $Header: rdbms/admin/catapp.sql /st_rdbms_11.2.0/16 2013/03/28 08:14:46 myuin Exp $
Rem
Rem catapp.sql
Rem
Rem Copyright (c) 2001, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catapp.sql - streams apply views
Rem
Rem    DESCRIPTION
Rem      This file contains all the streams apply views
Rem
Rem    NOTES
Rem
Rem    The order of the from clause listed from left to right
Rem    should be from highest cardinality to lowest cardinality for better
Rem    performance.  The optimizer choses driving tables from right to left
Rem    and using smaller tables first will eliminate more rows early on.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    myuin       03/14/13 - Backport myuin_bug-16006038 from main
Rem    huntran     01/21/13 - Backport huntran_bug-14338486 from main
Rem    fergutie    09/26/12 - Backport fergutie_bug-14312761 from main
Rem    huntran     09/02/12 - Backport huntran_bug-13471035 from
Rem    apfwkr      08/10/12 - Backport vgerard_bug-14284283 from
Rem    huntran     08/04/12 - Backport huntran_bug-14115292 from
Rem    yurxu       05/26/11 - lrg-5519739
Rem    yurxu       05/04/11 - Backport yurxu_bug-12391440 from main
Rem    huntran     05/03/12 - add replicat trail position for error record
Rem    elu         04/10/12 - add persistent apply tables
Rem    elu         03/20/12 - xin persistent table stats
Rem    tianli      03/20/12 - add seq#/rba/index to apply error tables
Rem    thoang      05/01/11 - add message column to dba_apply_error_messages
Rem    yurxu       04/12/11 - Backport yurxu_bug-11922716 from main
Rem    thoang      02/07/11 - Modify dba/all_apply_error_messages
Rem    huntran     02/08/11 - Backport huntran_bug-11678106 from main
Rem    huntran     12/10/10 - XStream table stats
Rem    huntran     01/04/11 - DBA/ALL_APPLY_DML_CONF_HANDLERS
Rem                           DBA/ALL_APPLY_DML_CONF_COLUMNS
Rem                           DBA/ALL_APPLY_HANDLE_COLLISIONS
Rem                           DBA/ALL_APPLY_REPERROR_HANDLERS
Rem                           USER_APPLY_ERROR
Rem    thoang      11/23/10 - Backport thoang_bug-10071998 from main
Rem    rmao        08/18/10 - fix dba_xstream_outbound.queue_name after
Rem                           altering apply queue
Rem    thoang      07/28/10 - Bug 9951551: fixed dba_xstream_outbound status
Rem    rmao        05/17/10 - bug 9716742: change dba_apply.purpose
Rem    rmao        04/27/10 - add "XStream Streams" to dba_apply.purpose
Rem    elu         04/06/10 - modify dba_apply_error
Rem    thoang      03/10/10 - fix status field in dba_xstream_* view
Rem    elu         03/29/10 - change eager to immedate
Rem    thoang      01/25/10 - fix dba_xstream_outbound view
Rem    elu         01/25/10 - fix views
Rem    juyuan      01/14/10 - bug-8719816L: remove ALL_STREAMS_STMT_HANDLERS
Rem                           and ALL_STREAMS_STMTS
Rem    yurxu       11/11/09 - add start_time, start_scn and capture_name in
Rem                           dba_xstream_outbound view 
Rem    thoang      10/04/09 - add committed_data mode
Rem    haxu        10/26/09 - add DBA/ALL_APPLY_DML_CONF_HANDLERS view
Rem    tianli      10/13/09 - add _dba_xstream_parameters view
Rem    elu         10/07/09 - error queue
Rem    thoang      07/06/09 - remove processed_low_create_time & transaction id
Rem    thoang      02/08/09 - add xout_processed_time to milestone table
Rem    juyuan      12/29/08 - add dba_streams_stmt_handlers and
Rem                           dba_streams_stmts view
Rem    juyuan      12/29/08 - dba_apply_change_handlers
Rem    thoang      12/15/08 - Add '/' 
Rem    thoang      12/02/08 - modify dba_xstream_inbound_progress 
Rem    elu         10/16/08 - remove commit pos
Rem    elu         03/31/08 - add lcr id
Rem    elu         02/28/08 - add apply spill fields
Rem    thoang      02/14/08 - add purpose to dba_apply 
Rem    jinwu       02/12/07 - change MESSAGE_DELIVERY_MODE from BUFFERED to
Rem                           CAPTURED for apply
Rem    liwong      06/07/06 - Fix message_delivery_mode 
Rem    liwong      05/29/06 - external position 
Rem    elu         03/09/05 - move apply spilling to catapp.sql 
Rem    lkaplan     06/09/04 - add assemble_lobs to all_apply_dml_handlers 
Rem    liwong      06/08/04 - Add oldest_transaction_id 
Rem    dcassine    05/27/04 - added UA_NOTIFICATION_HANDLER to _DBA_APPLY 
Rem    lkaplan     02/22/04 - generic lob assembly 
Rem    dcassine    05/13/04 - add DBA_APPLY_VALUE_DEPENDENCIES
Rem    dcassine    05/13/04 - add DBA_APPLY_OBJECT_DEPENDENCIES
Rem    bpwang      01/08/04 - add error creation time in dba_apply_error 
Rem    sbalaram    02/02/04 - Add _DBA_APPLY_ERROR_TXN
Rem    sbalaram    09/18/03 - Fix DBA_APPLY_TABLE_COLUMNS view for remote apply
Rem    sbalaram    08/26/03 - Fix DBA_APPLY_TABLE_COLUMNS view
Rem    wesmith     07/29/03 - view DBA_APPLY: remove join to AQ tables
Rem    alakshmi    07/10/03 - facilitate apply name generation
Rem    htran       06/30/03 - optimize some views
Rem    liwong      06/19/03 - Modify dba_apply_dml_handlers
Rem    nshodhan    06/04/03 - grabtrans 'lkaplan_assemble_dml1'
Rem    lkaplan     06/04/03 - assemble lobs
Rem    liwong      05/30/03 - Support virtual constraints
Rem    sbalaram    05/21/03 - add views for streams$_dest_ops,
Rem                           streams$_dest_obj_cols
Rem    elu         05/19/03 - add start_scn to milestone table
Rem    elu         04/23/03 - modify all_apply
Rem    htran       12/31/02 - all_apply_enqueue: add double quotes
Rem    htran       12/11/02 - move dictionary changes to sql.bsq
Rem    htran       11/11/02 - increase size of procedure columns
Rem                           streams$_apply_process table
Rem    liwong      10/23/02 - Add status_changed_date
Rem    dcassine    10/07/02 - added start & end date the _DBA_APPLY view
Rem    elu         09/26/02 - add negative rulesets
Rem    htran       08/19/02 - DBA_APPLY_ENQUEUE, ALL_APPLY_ENQUEUE,
Rem                           DBA_APPLY_EXECUTE, and ALL_APPLY_EXECUTE
Rem    apadmana    08/22/02 - add view dba_apply_instantiated_schemas
Rem    alakshmi    07/26/02 - restrict max value for inittrans
Rem    sbalaram    06/17/02 - Fix bug 2395423
Rem    elu         06/14/02 - modify all_apply_error
Rem    elu         06/13/02 - add index on apply# to apply$_error
Rem    dcassine    07/01/02 - added precommit_handler to apply views
Rem    alakshmi    05/06/02 - Bug 2265160: set inittrans, freelists, pctfree 
Rem                           for apply_progress
Rem    sbalaram    01/24/02 - Fix view dba_apply_instantiated_objects
Rem    wesmith     01/09/02 - Streams export/import support
Rem    rgmani      01/19/02 - Code review comments
Rem    elu         12/28/01 - modify dba_apply_error
Rem    rgmani      01/10/02 - Add apply dblink to several views
Rem    sbalaram    12/10/01 - use create or replace synonym
Rem    sbalaram    12/04/01 - ALL_APPLY_PARAMETERS - join with all_apply
Rem    wesmith     11/19/01 - dba_apply: apply_user renamed to apply_userid
Rem    sbalaram    11/16/01 - Fix comments on some views
Rem    alakshmi    11/08/01 - Merged alakshmi_apicleanup
Rem    narora      11/02/01 - rename apply_slave
Rem    nshodhan    11/01/01 - Change apply$_error
Rem    nshodhan    11/01/01 - Change apply$_error
Rem    sbalaram    10/29/01 - add views
Rem    lkaplan     10/29/01 - API - dml hdlr, lcr.execute, set key options 
Rem    apadmana    10/26/01 - Created
Rem

Rem This cannot be placed in sql.bsq because of a sys.anydata column
rem apply spilling message information
rem NOTE: the shape of streams$_apply_spill_messages should be the
rem       same as that of streams$_apply_spill_msgs_part below.
create table streams$_apply_spill_messages
(
  txnkey           number NOT NULL,      /* key that maps to apply_name, xid */
  sequence         number NOT NULL,       /* sequence within the transaction */
  scn              number,                                 /* scn of the lcr */
  scnseq           number,                                   /* scn sequence */
  capinst          number,                        /* capture instance number */
  flags            number,                                  /* knallcr flags */
  flags2           number,                                  /* knlqdqm flags */
  message          sys.AnyData,                           /* spilled message */
  destqueue        varchar2(66),             /* destination queue owner.name */
  ubaafn           number,
  ubaobj           number,
  ubadba           number,
  ubaslt           number,
  ubarci           number,
  ubafsc           number,
  spare1           number,                                /* sequence number */
  spare2           number,
  spare3           number,
  spare4           varchar2(4000),
  spare5           varchar2(4000),
  spare6           varchar2(4000),
  position         raw(64),                      /* LCR position for XStream */
  spare7           date,
  spare8           timestamp,
  spare9           raw(100)                             /* previous position */
)
tablespace SYSAUX
/
create unique index i_streams_apply_spill_mesgs1 on
  streams$_apply_spill_messages(txnkey, sequence)
tablespace SYSAUX
/

alter session set events  '14524 trace name context forever, level 1';
rem partitioned apply spilling message information
rem NOTE: the shape of streams$_apply_spill_msgs_part should be the
rem       same as that of streams$_apply_spill_messages above.
rem A partitioned version of the table for spilled messages has
rem been added to speed up clean up after the transaction is
rem applied. Each transaction is stored in a separate partition,
rem which can be truncated during clean up (instead of deleting the
rem rows for the transaction).
create table streams$_apply_spill_msgs_part
(
  txnkey           number NOT NULL,/* partition key, maps to apply_name, xid */
  sequence         number NOT NULL,       /* sequence within the transaction */
  scn              number,                                 /* scn of the lcr */
  scnseq           number,                                   /* scn sequence */
  capinst          number,                        /* capture instance number */
  flags            number,                                  /* knallcr flags */
  flags2           number,                                  /* knlqdqm flags */
  message          sys.AnyData,                           /* spilled message */
  destqueue        varchar2(66),             /* destination queue owner.name */
  ubaafn           number,
  ubaobj           number,
  ubadba           number,
  ubaslt           number,
  ubarci           number,
  ubafsc           number,
  spare1           number,                                /* sequence number */
  spare2           number,
  spare3           number,
  spare4           varchar2(4000),
  spare5           varchar2(4000),
  spare6           varchar2(4000),
  position         raw(64),                      /* LCR position for XStream */
  spare7           date,
  spare8           timestamp,
  spare9           raw(100)                             /* previous position */
)
PARTITION BY LIST(txnkey)
(
  partition p0 values (0)
)
tablespace SYSAUX
/
create unique index i_streams_apply_spill_msgs_pt1 on
  streams$_apply_spill_msgs_part(sequence, txnkey)
local
tablespace SYSAUX
/
alter session set events  '14524 trace name context off'; 

-- apply spill txnkey sequence
BEGIN
  execute immediate
    'CREATE SEQUENCE streams$_apply_spill_txnkey_s
     MINVALUE 1 MAXVALUE 4294967295 START WITH 1 NOCACHE CYCLE';
EXCEPTION WHEN others THEN
  -- ok if the object exists
  IF sqlcode = -955 THEN
    NULL;
  ELSE
    RAISE;
  END IF;
END;
/

-- add anydata message column for apply$_error_txn
BEGIN
  execute immediate 
    'alter table sys.apply$_error_txn add (message sys.anydata)';
EXCEPTION WHEN others THEN
  -- OK if the column already exists
  IF sqlcode = -1430 THEN 
    NULL;
  ELSE
    RAISE;
  END IF;
END;
/

----------------------------------------------------------------------------
-- view to get the apply process details
----------------------------------------------------------------------------

-- Private view select to all columns from streams$_apply_process.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY"
as select 
  apply#, apply_name, queue_oid, queue_owner, queue_name, status, flags,
  ruleset_owner, ruleset_name, message_handler, ddl_handler, precommit_handler,
  apply_userid, apply_dblink, apply_tag, start_date, end_date, 
  negative_ruleset_owner, negative_ruleset_name, spare1, spare2, spare3,
  status_change_time, error_number, error_message, ua_notification_handler,
  ua_ruleset_owner, ua_ruleset_name  
from sys.streams$_apply_process
/
grant select on "_DBA_APPLY" to exp_full_database
/

-- Note: DBA_APPLY cannot select from dba_* view. It must select from sys 
-- tables; otherwise, will run into some diffs in lrgzsdv (Data Vault lrg)
-- due to insufficient privs during dbms_apply_adm_internal.
-- recalculate_max_inst_scn procedure. Dava Vault is using OLS (Oracle Label
-- security), and row level security is not checked for sys tables.
-- 
create or replace view DBA_APPLY
  (APPLY_NAME, QUEUE_NAME, QUEUE_OWNER, APPLY_CAPTURED, 
   RULE_SET_NAME,   RULE_SET_OWNER, APPLY_USER, APPLY_DATABASE_LINK, 
   APPLY_TAG, DDL_HANDLER, PRECOMMIT_HANDLER, MESSAGE_HANDLER, STATUS, 
   MAX_APPLIED_MESSAGE_NUMBER, NEGATIVE_RULE_SET_NAME, 
   NEGATIVE_RULE_SET_OWNER, STATUS_CHANGE_TIME,
   ERROR_NUMBER, ERROR_MESSAGE, MESSAGE_DELIVERY_MODE, PURPOSE)
as
select ap.apply_name, ap.queue_name, ap.queue_owner, 
       decode(bitand(ap.flags, 1), 1, 'YES',
                                   0, 'NO'),
       ap.ruleset_name, ap.ruleset_owner,
       u.name, ap.apply_dblink, ap.apply_tag, ap.ddl_handler,
       ap.precommit_handler, ap.message_handler,
       -- if uncommitted XOut show capture's status else show apply status
       case when (bitand(ap.flags, 1280) = 1280)
         then (select decode(cp.status, 1, 'DISABLED',
                         2, 'ENABLED',
                         4, 'ABORTED', 'UNKNOWN') 
               from sys.streams$_capture_process cp, sys.xstream$_server xs
                 where ap.apply_name = xs.server_name and
                       xs.queue_owner = cp.queue_owner and
                       xs.queue_name = cp.queue_name)
         else decode(ap.status,
                         1, 'DISABLED',
                         2, 'ENABLED',
                         4, 'ABORTED', 'UNKNOWN') end,
       ap.spare1,
       ap.negative_ruleset_name, ap.negative_ruleset_owner,
       ap.status_change_time, ap.error_number, ap.error_message,
       decode(bitand(ap.flags, 1), 1, 'CAPTURED',
              decode(bitand(ap.flags, 128), 128, 'CAPTURED',
                                              0, 'PERSISTENT')),
       -- if uncommitted XOut, purpose can only be 'GoldenGate'
       (case
          when (bitand(ap.flags, 1280)     = 1280)  then 'GoldenGate Capture'
          when (bitand(ap.flags, 16)       = 16)    then 'CHANGE DATA CAPTURE'
          when (bitand(ap.flags, 32)       = 32)    then 'AUDIT VAULT'
          when (bitand(ap.flags, 16384)    = 16384) then
            (case
               when (bitand(ap.flags, 256) = 256)   then 'GoldenGate Capture'
               when (bitand(ap.flags, 512) = 512)   then 'GoldenGate Apply'
             end)
          when (bitand(ap.flags, 256)      = 256)   then 'XStream Out'
          when (bitand(ap.flags, 512)      = 512)   then 'XStream In'
          else
             ( select 'XStream Streams' from dual where exists
                (select 1 from sys.props$
                  where name = 'GG_XSTREAM_FOR_STREAMS' and value$ = 'T')
               union
               select 'Streams' from dual where NOT exists
                (select 1 from sys.props$
                  where name = 'GG_XSTREAM_FOR_STREAMS' and value$ = 'T'))
       end)
  from "_DBA_APPLY" ap, sys.user$ u
 where  ap.apply_userid = u.user# (+)
/

comment on table DBA_APPLY is
'Details about the apply process'
/
comment on column DBA_APPLY.APPLY_NAME is
'Name of the apply process'
/
comment on column DBA_APPLY.QUEUE_NAME is
'Name of the queue the apply process dequeues from'
/
comment on column DBA_APPLY.QUEUE_OWNER is
'Owner of the queue the apply process dequeues from'
/
comment on column DBA_APPLY.APPLY_CAPTURED is
'Yes, if applying captured messages; No, if applying enqueued messages'
/
comment on column DBA_APPLY.RULE_SET_NAME is
'Rule set used by apply process for filtering'
/
comment on column DBA_APPLY.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column DBA_APPLY.APPLY_USER is
'Current user who is applying the messages'
/
comment on column DBA_APPLY.APPLY_DATABASE_LINK is
'For remote objects, the database link pointing to the remote database'
/
comment on column DBA_APPLY.APPLY_TAG is
'Tag associated with DDL and DML change records that will be applied'
/
comment on column DBA_APPLY.DDL_HANDLER is
'Name of the user specified ddl handler'
/
comment on column DBA_APPLY.PRECOMMIT_HANDLER is
'Name of the user specified precommit handler'
/
comment on column DBA_APPLY.MESSAGE_HANDLER is
'User specified procedure to handle messages other than DDL and DML messages'
/
comment on column DBA_APPLY.STATUS is
'Status of the apply process: DISABLED, ENABLED, ABORTED'
/
comment on column DBA_APPLY.MAX_APPLIED_MESSAGE_NUMBER is
'Maximum value of message that has been applied'
/
comment on column DBA_APPLY.STATUS_CHANGE_TIME is
'The time that STATUS of the apply process was changed'
/
comment on column DBA_APPLY.ERROR_NUMBER is
'Error number if the apply process was aborted'
/
comment on column DBA_APPLY.ERROR_MESSAGE is
'Error message if the apply process was aborted'
/
create or replace public synonym DBA_APPLY for DBA_APPLY
/
grant select on DBA_APPLY to select_catalog_role
/
comment on column DBA_APPLY.NEGATIVE_RULE_SET_NAME is
'Negative rule set used by apply process for filtering'
/
comment on column DBA_APPLY.RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column DBA_APPLY.PURPOSE is
'Purpose of this apply process '
/

----------------------------------------------------------------------------

-- View of apply processes
create or replace view ALL_APPLY
as
select a.*
  from dba_apply a
 where a.apply_user in
         (select u.name
            from sys.user$ u, dba_role_privs rp
           where u.user# = userenv('SCHEMAID'))
    or userenv('SCHEMAID') in
         (select u.user#
            from sys.user$ u, dba_role_privs rp 
           where (u.name = rp.grantee)
             and (rp.granted_role = 'SELECT_CATALOG_ROLE' or
                  rp.granted_role = 'DBA'))
/

comment on table ALL_APPLY is
'Details about each apply process that dequeues from the queue visible to the current user'
/
comment on column ALL_APPLY.APPLY_NAME is
'Name of the apply process'
/
comment on column ALL_APPLY.QUEUE_NAME is
'Name of the queue the apply process dequeues from'
/
comment on column ALL_APPLY.QUEUE_OWNER is
'Owner of the queue the apply process dequeues from'
/
comment on column ALL_APPLY.APPLY_CAPTURED is
'Yes, if applying captured messages; No, if applying enqueued messages'
/
comment on column ALL_APPLY.RULE_SET_NAME is
'Rule set used by apply process for filtering'
/
comment on column ALL_APPLY.RULE_SET_OWNER is
'Owner of the rule set'
/
comment on column ALL_APPLY.APPLY_USER is
'Current user who is applying the messages'
/
comment on column ALL_APPLY.APPLY_DATABASE_LINK is
'For remote objects, the database link pointing to the remote database'
/
comment on column ALL_APPLY.APPLY_TAG is
'Tag associated with DDL and DML change records that will be applied'
/
comment on column ALL_APPLY.DDL_HANDLER is
'Name of the user specified ddl handler'
/
comment on column ALL_APPLY.PRECOMMIT_HANDLER is
'Name of the user specified precommit handler'
/
comment on column ALL_APPLY.MESSAGE_HANDLER is
'User specified procedure to handle messages other than DDL and DML messages'
/
comment on column ALL_APPLY.STATUS is
'Status of the apply process: DISABLED, ENABLED, ABORTED'
/
comment on column ALL_APPLY.STATUS_CHANGE_TIME is
'The time that STATUS of the apply process was changed'
/
comment on column ALL_APPLY.ERROR_NUMBER is
'Error number if the apply process was aborted'
/
comment on column ALL_APPLY.ERROR_MESSAGE is
'Error message if the apply process was aborted'
/
comment on column ALL_APPLY.NEGATIVE_RULE_SET_NAME is
'Negative rule set used by apply process for filtering'
/
comment on column ALL_APPLY.NEGATIVE_RULE_SET_OWNER is
'Owner of the negative rule set'
/
comment on column ALL_APPLY.MAX_APPLIED_MESSAGE_NUMBER is
'Maximum value of message that has been applied'
/
comment on column ALL_APPLY.PURPOSE is
'Purpose of this apply process '
/
create or replace public synonym ALL_APPLY for ALL_APPLY
/
grant select on ALL_APPLY to public with grant option
/

----------------------------------------------------------------------------
-- view to get apply process parameters
--
-- Note: process_type = 1 corresponds to the package variable
--       dbms_streams_adm_utl.proc_type_apply (prvtbsdm.sql)
--       and the macro KNLU_APPLY_PROC (knlu.h). This *must* be
--        kept in sync with both of these.
----------------------------------------------------------------------------
create or replace view DBA_APPLY_PARAMETERS
  (APPLY_NAME, PARAMETER, VALUE, SET_BY_USER)
as
select ap.apply_name, pp.name, pp.value,
       decode(pp.user_changed_flag, 1, 'YES', 'NO')
  from sys.streams$_process_params pp, sys.streams$_apply_process ap
 where pp.process_type = 1
   and pp.process# = ap.apply#
   and /* display internal parameters if the user changed them */
       (pp.internal_flag = 0
        or
        (pp.internal_flag = 1 and pp.user_changed_flag = 1)
       )
/

comment on table DBA_APPLY_PARAMETERS is
'All parameters for apply process'
/
comment on column DBA_APPLY_PARAMETERS.APPLY_NAME is
'Name of the apply process'
/
comment on column DBA_APPLY_PARAMETERS.PARAMETER is
'Name of the parameter'
/
comment on column DBA_APPLY_PARAMETERS.VALUE is
'Either the default value or the value set by the user for the parameter'
/
comment on column DBA_APPLY_PARAMETERS.SET_BY_USER is
'YES if the value is set by the user, NO otherwise'
/
create or replace public synonym DBA_APPLY_PARAMETERS
  for DBA_APPLY_PARAMETERS
/
grant select on DBA_APPLY_PARAMETERS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_PARAMETERS
  (APPLY_NAME, PARAMETER, VALUE, SET_BY_USER)
as
select pa.apply_name, pa.parameter, pa.value, pa.set_by_user
  from dba_apply_parameters pa, all_apply aa
 where pa.apply_name = aa.apply_name
/

comment on table ALL_APPLY_PARAMETERS is
'Details about parameters of each apply process that dequeues from the queue visible to the current user'
/
comment on column ALL_APPLY_PARAMETERS.APPLY_NAME is
'Name of the apply process'
/
comment on column ALL_APPLY_PARAMETERS.PARAMETER is
'Name of the parameter'
/
comment on column ALL_APPLY_PARAMETERS.VALUE is
'Either the default value or the value set by the user for the parameter'
/
comment on column ALL_APPLY_PARAMETERS.SET_BY_USER is
'YES if the value is set by the user, NO otherwise'
/
create or replace public synonym ALL_APPLY_PARAMETERS
  for ALL_APPLY_PARAMETERS
/
grant select on ALL_APPLY_PARAMETERS to public with grant option
/

----------------------------------------------------------------------------
-- view to get apply instantiated objects
----------------------------------------------------------------------------

-- Private view select to all columns from apply$_source_schema.
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_SOURCE_SCHEMA"
as select 
  source_db_name, global_flag, name, dblink, inst_scn, spare1,
  inst_external_pos, spare2, spare3
from sys.apply$_source_schema
/
grant select on "_DBA_APPLY_SOURCE_SCHEMA" to exp_full_database
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_source_obj
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_SOURCE_OBJ"
as select 
  id, owner, name, decode(type, 2, 'TABLE', 'UNSUPPORTED') type,
  source_db_name, dblink, inst_scn, ignore_scn,
  spare1, inst_external_pos, spare2, spare3
from sys.apply$_source_obj
/
grant select on "_DBA_APPLY_SOURCE_OBJ" to exp_full_database
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_INSTANTIATED_OBJECTS
  (SOURCE_DATABASE, SOURCE_OBJECT_OWNER, SOURCE_OBJECT_NAME,
   SOURCE_OBJECT_TYPE, INSTANTIATION_SCN, IGNORE_SCN, APPLY_DATABASE_LINK)
as
select source_db_name, owner, name,
       type, inst_scn, ignore_scn, dblink
  from "_DBA_APPLY_SOURCE_OBJ"
/

comment on table DBA_APPLY_INSTANTIATED_OBJECTS is
'Details about objects instantiated'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.SOURCE_DATABASE is
'Name of the database where the objects originated'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.SOURCE_OBJECT_OWNER is
'Owner of the object at the source database'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.SOURCE_OBJECT_NAME is
'Name of the object at source'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.SOURCE_OBJECT_TYPE is
'Type of the object at source'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.INSTANTIATION_SCN is
'Point in time when the object was instantiated at source'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.IGNORE_SCN is
'SCN lower bound for messages that will be considered for apply'
/
comment on column DBA_APPLY_INSTANTIATED_OBJECTS.APPLY_DATABASE_LINK is
'For remote objects, the database link pointing to the remote database'
/
create or replace public synonym DBA_APPLY_INSTANTIATED_OBJECTS
  for DBA_APPLY_INSTANTIATED_OBJECTS
/
grant select on DBA_APPLY_INSTANTIATED_OBJECTS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_INSTANTIATED_OBJECTS as
select aio.*
  from DBA_APPLY_INSTANTIATED_OBJECTS aio, ALL_APPLY aa
  where aa.apply_database_link = aio.apply_database_link
/

comment on table ALL_APPLY_INSTANTIATED_OBJECTS is
'Details about objects instantiated for the user'
/
comment on column ALL_APPLY_INSTANTIATED_OBJECTS.SOURCE_DATABASE is
'Name of the database where the objects originated'
/
comment on column ALL_APPLY_INSTANTIATED_OBJECTS.SOURCE_OBJECT_OWNER is
'Owner of the object at the source database'
/
comment on column ALL_APPLY_INSTANTIATED_OBJECTS.SOURCE_OBJECT_NAME is
'Name of the object at source'
/
comment on column ALL_APPLY_INSTANTIATED_OBJECTS.SOURCE_OBJECT_TYPE is
'Type of the object at source'
/
comment on column ALL_APPLY_INSTANTIATED_OBJECTS.INSTANTIATION_SCN is
'Point in time when the object was instantiated at source'
/
comment on column ALL_APPLY_INSTANTIATED_OBJECTS.IGNORE_SCN is
'SCN lower bound for messages that will be considered for apply'
/
comment on column ALL_APPLY_INSTANTIATED_OBJECTS.APPLY_DATABASE_LINK is
'For remote objects, the database link pointing to the remote database'
/
create or replace public synonym ALL_APPLY_INSTANTIATED_OBJECTS
  for ALL_APPLY_INSTANTIATED_OBJECTS
/
grant select on ALL_APPLY_INSTANTIATED_OBJECTS to select_catalog_role
/

---------------------------------------------------------------------
-- internal view for external position (stream position) for applying
-- user buffered messages.
---------------------------------------------------------------------
create or replace view "_DBA_APPLY_INST_OBJECTS"
  (SOURCE_DATABASE, SOURCE_OBJECT_OWNER, SOURCE_OBJECT_NAME,
   SOURCE_OBJECT_TYPE, INSTANTIATION_EXTERNAL_POS)
as
select source_db_name, owner, name,
       type, inst_external_pos
  from "_DBA_APPLY_SOURCE_OBJ"
/

comment on table "_DBA_APPLY_INST_OBJECTS" is
'Details about objects instantiated'
/
comment on column "_DBA_APPLY_INST_OBJECTS".SOURCE_DATABASE is
'Name of the database where the objects originated'
/
comment on column "_DBA_APPLY_INST_OBJECTS".SOURCE_OBJECT_OWNER is
'Owner of the object at the source database'
/
comment on column "_DBA_APPLY_INST_OBJECTS".SOURCE_OBJECT_NAME is
'Name of the object at source'
/
comment on column "_DBA_APPLY_INST_OBJECTS".SOURCE_OBJECT_TYPE is
'Type of the object at source'
/
comment on column "_DBA_APPLY_INST_OBJECTS".INSTANTIATION_EXTERNAL_POS is
'Point in time when the object was instantiated at source'
/
create or replace public synonym "_DBA_APPLY_INST_OBJECTS"
  for "_DBA_APPLY_INST_OBJECTS"
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_INSTANTIATED_SCHEMAS
  (SOURCE_DATABASE, SOURCE_SCHEMA, INSTANTIATION_SCN, APPLY_DATABASE_LINK)
as
select source_db_name, name, inst_scn, dblink
  from "_DBA_APPLY_SOURCE_SCHEMA"
 where global_flag = 0
/

comment on table DBA_APPLY_INSTANTIATED_SCHEMAS is
'Details about schemas instantiated'
/
comment on column DBA_APPLY_INSTANTIATED_SCHEMAS.SOURCE_DATABASE is
'Name of the database where the schemas originated'
/
comment on column DBA_APPLY_INSTANTIATED_SCHEMAS.INSTANTIATION_SCN is
'Point in time when the schema was instantiated at source'
/
comment on column DBA_APPLY_INSTANTIATED_SCHEMAS.APPLY_DATABASE_LINK is
'For remote schemas, the database link pointing to the remote database'
/
create or replace public synonym DBA_APPLY_INSTANTIATED_SCHEMAS
  for DBA_APPLY_INSTANTIATED_SCHEMAS
/
grant select on DBA_APPLY_INSTANTIATED_SCHEMAS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_INSTANTIATED_SCHEMAS as
select ais.*
  from DBA_APPLY_INSTANTIATED_SCHEMAS ais, ALL_APPLY aa
  where aa.apply_database_link = ais.apply_database_link
/

comment on table ALL_APPLY_INSTANTIATED_SCHEMAS is
'Details about schemas instantiated for the user'
/
comment on column ALL_APPLY_INSTANTIATED_SCHEMAS.SOURCE_DATABASE is
'Name of the database where the schemas originated'
/
comment on column ALL_APPLY_INSTANTIATED_SCHEMAS.INSTANTIATION_SCN is
'Point in time when the schema was instantiated at source'
/
comment on column ALL_APPLY_INSTANTIATED_SCHEMAS.APPLY_DATABASE_LINK is
'For remote schemas, the database link pointing to the remote database'
/
create or replace public synonym ALL_APPLY_INSTANTIATED_SCHEMAS
  for ALL_APPLY_INSTANTIATED_SCHEMAS
/
grant select on ALL_APPLY_INSTANTIATED_SCHEMAS to select_catalog_role
/

---------------------------------------------------------------------
-- internal view for external position (stream position) for applying
-- user buffered messages.
---------------------------------------------------------------------
create or replace view "_DBA_APPLY_INST_SCHEMAS"
  (SOURCE_DATABASE, SOURCE_SCHEMA, INSTANTIATION_EXTERNAL_POS)
as
select source_db_name, name, inst_external_pos
  from "_DBA_APPLY_SOURCE_SCHEMA"
 where global_flag = 0
/

comment on table "_DBA_APPLY_INST_SCHEMAS" is
'Details about schemas instantiated'
/
comment on column "_DBA_APPLY_INST_SCHEMAS".SOURCE_DATABASE is
'Name of the database where the schemas originated'
/
comment on column "_DBA_APPLY_INST_SCHEMAS".SOURCE_SCHEMA is
'Name of the schemas'
/
comment on column "_DBA_APPLY_INST_SCHEMAS".INSTANTIATION_EXTERNAL_POS is
'Point in time when the schema was instantiated at source'
/
create or replace public synonym "_DBA_APPLY_INST_SCHEMAS"
  for "_DBA_APPLY_INST_SCHEMAS"
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_INSTANTIATED_GLOBAL
  (SOURCE_DATABASE, INSTANTIATION_SCN, APPLY_DATABASE_LINK)
as
select source_db_name, inst_scn, dblink
  from "_DBA_APPLY_SOURCE_SCHEMA"
 where global_flag = 1
/

comment on table DBA_APPLY_INSTANTIATED_GLOBAL is
'Details about database instantiated'
/
comment on column DBA_APPLY_INSTANTIATED_GLOBAL.SOURCE_DATABASE is
'Name of the database that was instantiated'
/
comment on column DBA_APPLY_INSTANTIATED_GLOBAL.INSTANTIATION_SCN is
'Point in time when the database was instantiated at source'
/
comment on column DBA_APPLY_INSTANTIATED_GLOBAL.APPLY_DATABASE_LINK is
'For a remote database, the database link pointing to the remote database'
/
create or replace public synonym DBA_APPLY_INSTANTIATED_GLOBAL
  for DBA_APPLY_INSTANTIATED_GLOBAL
/
grant select on DBA_APPLY_INSTANTIATED_GLOBAL to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_INSTANTIATED_GLOBAL as
select aig.*
  from DBA_APPLY_INSTANTIATED_GLOBAL aig, ALL_APPLY aa
  where aa.apply_database_link = aig.apply_database_link
/

comment on table ALL_APPLY_INSTANTIATED_GLOBAL is
'Details about database instantiated for the user'
/
comment on column ALL_APPLY_INSTANTIATED_GLOBAL.SOURCE_DATABASE is
'Name of the database that was instantiated'
/
comment on column ALL_APPLY_INSTANTIATED_GLOBAL.INSTANTIATION_SCN is
'Point in time when the database was instantiated at source'
/
comment on column ALL_APPLY_INSTANTIATED_GLOBAL.APPLY_DATABASE_LINK is
'For a remote database, the database link pointing to the remote database'
/
create or replace public synonym ALL_APPLY_INSTANTIATED_GLOBAL
  for ALL_APPLY_INSTANTIATED_GLOBAL
/
grant select on ALL_APPLY_INSTANTIATED_GLOBAL to select_catalog_role
/

---------------------------------------------------------------------
-- internal view for external position (stream position) for applying
-- user buffered messages.
---------------------------------------------------------------------
create or replace view "_DBA_APPLY_INST_GLOBAL"
  (SOURCE_DATABASE, INSTANTIATION_EXTERNAL_POS)
as
select source_db_name, inst_external_pos
  from "_DBA_APPLY_SOURCE_SCHEMA"
 where global_flag = 1
/

comment on table "_DBA_APPLY_INST_GLOBAL" is
'Details about database instantiated'
/
comment on column "_DBA_APPLY_INST_GLOBAL".SOURCE_DATABASE is
'Name of the database that was instantiated'
/
comment on column "_DBA_APPLY_INST_GLOBAL".INSTANTIATION_EXTERNAL_POS is
'Point in time when the database was instantiated at source'
/
create or replace public synonym "_DBA_APPLY_INST_GLOBAL"
  for "_DBA_APPLY_INST_GLOBAL"
/

----------------------------------------------------------------------------

create or replace view "_DBA_APPLY_CONSTRAINT_COLUMNS"
as
select constraint_name dependency_name, owner object_owner, name object_name,
       cname column_name, cpos column_position
  from sys.apply$_constraint_columns
/

grant select on "_DBA_APPLY_CONSTRAINT_COLUMNS" to select_catalog_role
/

create or replace public synonym DBA_APPLY_VALUE_DEPENDENCIES
  for "_DBA_APPLY_CONSTRAINT_COLUMNS"
/

grant select on DBA_APPLY_VALUE_DEPENDENCIES to select_catalog_role
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.DEPENDENCY_NAME is
'Dependency name'
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.OBJECT_OWNER is
'Schema of owning object'
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.OBJECT_NAME is
'Owning object'
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.COLUMN_NAME is
'Dependency column name'
/

comment on column DBA_APPLY_VALUE_DEPENDENCIES.COLUMN_POSITION is
'Dependency column position'
/

----------------------------------------------------------------------------

create or replace view "_DBA_APPLY_OBJECT_CONSTRAINTS"
as
select owner object_owner, name object_name,
       powner parent_object_owner, pname parent_object_name
  from sys.apply$_virtual_obj_cons
/

grant select on "_DBA_APPLY_OBJECT_CONSTRAINTS" to select_catalog_role
/


create or replace public synonym DBA_APPLY_OBJECT_DEPENDENCIES
  for "_DBA_APPLY_OBJECT_CONSTRAINTS"
/

grant select on DBA_APPLY_OBJECT_DEPENDENCIES to select_catalog_role
/

comment on column DBA_APPLY_OBJECT_DEPENDENCIES.OBJECT_OWNER is
'Schema of the object'
/

comment on column DBA_APPLY_OBJECT_DEPENDENCIES.OBJECT_NAME is
'Object name'
/

comment on column DBA_APPLY_OBJECT_DEPENDENCIES.PARENT_OBJECT_OWNER is
'Schema of the parent object'
/

comment on column DBA_APPLY_OBJECT_DEPENDENCIES.PARENT_OBJECT_NAME is
'Parent object name'
/
 

----------------------------------------------------------------------------
-- view to get apply key columns
-- TODO: Use long_cname when user-defined type is supported
----------------------------------------------------------------------------
create or replace view DBA_APPLY_KEY_COLUMNS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, APPLY_DATABASE_LINK)
as
select sname, oname, cname, dblink
  from sys.streams$_key_columns
/

comment on table DBA_APPLY_KEY_COLUMNS is
'alternative key columns for a table for STREAMS'
/
comment on column DBA_APPLY_KEY_COLUMNS.OBJECT_OWNER is
'Owner of the object'
/
comment on column DBA_APPLY_KEY_COLUMNS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_APPLY_KEY_COLUMNS.COLUMN_NAME is
'Column name of the object'
/
comment on column DBA_APPLY_KEY_COLUMNS.APPLY_DATABASE_LINK is
'Remote database link to which changes will be aplied'
/
create or replace public synonym DBA_APPLY_KEY_COLUMNS
  for DBA_APPLY_KEY_COLUMNS
/
grant select on DBA_APPLY_KEY_COLUMNS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_KEY_COLUMNS
  (OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, APPLY_DATABASE_LINK)
as
select k.object_owner, k.object_name, k.column_name, k.apply_database_link
  from all_tab_columns a, dba_apply_key_columns k
 where k.object_owner = a.owner
   and k.object_name = a.table_name
   and k.column_name = a.column_name
/

comment on table ALL_APPLY_KEY_COLUMNS is
'Alternative key columns for a STREAMS table visible to the current user'
/
comment on column ALL_APPLY_KEY_COLUMNS.OBJECT_OWNER is
'Owner of the object'
/
comment on column ALL_APPLY_KEY_COLUMNS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_APPLY_KEY_COLUMNS.COLUMN_NAME is
'Column name of the object'
/
comment on column ALL_APPLY_KEY_COLUMNS.APPLY_DATABASE_LINK is
'Remote database link to which changes will be aplied'
/
create or replace public synonym ALL_APPLY_KEY_COLUMNS
  for ALL_APPLY_KEY_COLUMNS
/
grant select on ALL_APPLY_KEY_COLUMNS to PUBLIC with grant option
/

----------------------------------------------------------------------------
-- view to get conflict/error handling information during apply
----------------------------------------------------------------------------

-- Private view select to all columns from apply$_error_handler
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_ERROR_HANDLER"
as select 
  eh.object_number, eh.method_name, eh.resolution_column, eh.resolution_id, 
  eh.spare1, o.linkname
from sys.obj$ o, sys.apply$_error_handler eh
where eh.object_number = o.obj#
/
grant select on "_DBA_APPLY_ERROR_HANDLER" to exp_full_database
/

-- Create an index on apply# for apply$_error
-- TO DO: move this to sql.bsq
create index streams$_apply_error_idx_2
 on apply$_error(apply#)
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_conf_hdlr_columns
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_CONF_HDLR_COLUMNS"
as select 
  object_number, resolution_id, column_name, spare1
from sys.apply$_conf_hdlr_columns
/
grant select on "_DBA_APPLY_CONF_HDLR_COLUMNS" to exp_full_database
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_table_stats
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_TABLE_STATS"
as 
select apply#, server_id, save_time, source_table_owner, source_table_name, 
       destination_table_owner, destination_table_name, last_update,
       total_inserts, total_updates, total_deletes, insert_collisions,
       update_collisions, delete_collisions, reperror_records, 
       reperror_ignores, wait_dependencies, cdr_insert_row_exists,
       cdr_update_row_exists, cdr_update_row_missing, cdr_delete_row_exists,
       cdr_delete_row_missing, cdr_successful_resolutions, 
       cdr_failed_resolutions, spare1, spare2, spare3, spare4, spare5, spare6,
       spare7, spare8, spare9, spare10, spare11, spare12, spare13, spare14,
       spare15, spare16, spare17, spare18, spare19, spare20
from sys.apply$_table_stats
/
grant select on "_DBA_APPLY_TABLE_STATS" to exp_full_database
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_coordinator_stats
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_COORDINATOR_STATS"
as 
select apply#, save_time, apply_name, state, total_applied, total_waitdeps, 
       total_waitcommits, total_admin, total_assigned, total_received,
       total_ignored, total_rollbacks, total_errors, unassigned_eager,
       unassigned_complete, auto_txnbufsize, startup_time, lwm_time,
       lwm_msg_num, lwm_msg_time, hwm_time, hwm_msg_num, hwm_msg_time,
       elapsed_schedule_time, elapsed_idle_time, lwm_position, hwm_position,
       processed_msg_num, flag, flags_factoring, replname,
       spare1, spare2, spare3, spare4, spare5, spare6,
       spare7, spare8, spare9, spare10, spare11, spare12, spare13, spare14,
       spare15, spare16, spare17, spare18, spare19, spare20
from sys.apply$_coordinator_stats
/
grant select on "_DBA_APPLY_COORDINATOR_STATS" to exp_full_database
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_server_stats
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_SERVER_STATS"
as 
select apply#, server_id, save_time, apply_name, state, startup_time,
       xid_usn, xid_slt, xid_sqn, cscn, depxid_usn, depxid_slt, depxid_sqn,
       depcscn, msg_num, total_assigned, total_admin, total_rollbacks,
       total_msg, last_apply_time, last_apply_msg_num, last_apply_msg_time,
       elapsed_apply_time, commit_position, dep_commit_position, 
       last_apply_pos, flag, nosxid, depnosxid, max_inst_scn, total_waitdeps,
       total_lcrs_retried, total_txns_retried, txn_retry_iter, lcr_retry_iter,
       total_txns_discarded, flags_factoring,
       spare1, spare2, spare3, spare4, spare5, spare6,
       spare7, spare8, spare9, spare10, spare11, spare12, spare13, spare14,
       spare15, spare16, spare17, spare18, spare19, spare20
from sys.apply$_server_stats
/
grant select on "_DBA_APPLY_SERVER_STATS" to exp_full_database
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_reader_stats
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_READER_STATS"
as 
select apply#, save_time, apply_name, state, startup_time, msg_num, total_msg,
       total_spill_msg, last_rcv_time, last_rcv_msg_num, last_rcv_msg_time, 
       sga_used, elapsed_dequeue_time, elapsed_schedule_time, 
       elapsed_spill_time, last_browse_num, oldest_scn_num, last_browse_seq,
       last_deq_seq, oldest_xid_usn, oldest_xid_slt, oldest_xid_sqn, 
       spill_lwm_scn, commit_position, last_rcv_pos, last_browse_pos, 
       oldest_pos, spill_lwm_pos, flag, oldest_xidtxt, num_deps, num_dep_lcrs,
       num_wmdeps, num_in_memory_lcrs, sga_allocated, total_lcrs_retried,
       total_txns_retried, txn_retry_iter, lcr_retry_iter, 
       total_txns_discarded, flags_factoring,
       spare1, spare2, spare3, spare4, spare5, spare6,
       spare7, spare8, spare9, spare10, spare11, spare12, spare13, spare14,
       spare15, spare16, spare17, spare18, spare19, spare20
from sys.apply$_reader_stats
/
grant select on "_DBA_APPLY_READER_STATS" to exp_full_database
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_batch_sql_stats
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_BATCH_SQL_STATS"
as 
select apply#, save_time, server_id, batch_opeations, batches, 
       batches_executed, queues, batches_in_error, normal_mode_ops, 
       immediate_flush_ops, pk_collisions, uk_collisions, fk_collisions, 
       thread_batch_groups, num_commits, num_rollbacks, queue_flush_calls,
       ops_per_batch, ops_per_batch_executed, ops_per_queue, 
       parallel_batch_rate, spare1, spare2, spare3, spare4, spare5, spare6,
       spare7, spare8, spare9, spare10, spare11, spare12, spare13, spare14,
       spare15, spare16, spare17, spare18, spare19, spare20, spare21,
       spare22, spare23, spare24, spare25
from sys.apply$_batch_sql_stats
/
grant select on "_DBA_APPLY_BATCH_SQL_STATS" to exp_full_database
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_CONFLICT_COLUMNS
  (OBJECT_OWNER, OBJECT_NAME, METHOD_NAME, RESOLUTION_COLUMN, COLUMN_NAME,
   APPLY_DATABASE_LINK)
as
select u.username, o.name, eh.method_name, eh.resolution_column,
       ac.column_name, NULL
  from sys.obj$ o, "_DBA_APPLY_CONF_HDLR_COLUMNS" ac, 
       "_DBA_APPLY_ERROR_HANDLER" eh, dba_users u
 where o.obj# = ac.object_number
   and o.obj# = eh.object_number
   and ac.resolution_id = eh.resolution_id
   and u.user_id = o.owner#
   and o.remoteowner is NULL
union
select o.remoteowner, o.name, eh.method_name, eh.resolution_column,
       ac.column_name, o.linkname
  from sys.obj$ o, apply$_conf_hdlr_columns ac, apply$_error_handler eh
 where o.obj# = ac.object_number
   and o.obj# = eh.object_number
   and ac.resolution_id = eh.resolution_id
   and o.remoteowner is not NULL
/

comment on table DBA_APPLY_CONFLICT_COLUMNS is
'Details about conflict resolution'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.OBJECT_OWNER is
'Owner of the object'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.METHOD_NAME is
'Name of the method used to resolve conflict'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.RESOLUTION_COLUMN is
'Name of the column used to resolve conflict'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.COLUMN_NAME is
'Name of the column that is to be considered as part of a group to resolve conflict'
/
comment on column DBA_APPLY_CONFLICT_COLUMNS.APPLY_DATABASE_LINK is
'For remote objects, name of database link pointing to remote database'
/
create or replace public synonym DBA_APPLY_CONFLICT_COLUMNS
  for DBA_APPLY_CONFLICT_COLUMNS
/
grant select on DBA_APPLY_CONFLICT_COLUMNS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_CONFLICT_COLUMNS
  (OBJECT_OWNER, OBJECT_NAME, METHOD_NAME, RESOLUTION_COLUMN, COLUMN_NAME,
   APPLY_DATABASE_LINK)
as
select c.object_owner, c.object_name, c.method_name,
       c.resolution_column, c.column_name, c.apply_database_link
  from all_tab_columns o, dba_apply_conflict_columns c
 where c.object_owner = o.owner
   and c.object_name = o.table_name
   and c.column_name = o.column_name
/

comment on table ALL_APPLY_CONFLICT_COLUMNS is
'Details about conflict resolution on tables visible to the current user'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.OBJECT_OWNER is
'Owner of the object'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.METHOD_NAME is
'Name of the method used to resolve conflict'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.RESOLUTION_COLUMN is
'Name of the column used to resolve conflict'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.COLUMN_NAME is
'Name of the column that is to be considered as part of a group to resolve conflict'
/
comment on column ALL_APPLY_CONFLICT_COLUMNS.APPLY_DATABASE_LINK is
'For remote objects, name of database link pointing to remote database'
/
create or replace public synonym ALL_APPLY_CONFLICT_COLUMNS
  for ALL_APPLY_CONFLICT_COLUMNS
/
grant select on ALL_APPLY_CONFLICT_COLUMNS to public with grant option
/

----------------------------------------------------------------------------
-- Private helper view to select all the columns from streams$_dest_objs
create or replace view "_DBA_APPLY_OBJECTS"
(OBJECT_OWNER, OBJECT_NAME, PROPERTY, APPLY_DATABASE_LINK, SPARE1, SPARE2,
 SPARE3, SPARE4)
as select
u.name, o.name, do.property, do.dblink, do.spare1, do.spare2,
do.spare3, do.spare4
from sys.streams$_dest_objs do, sys.obj$ o, sys.user$ u
  where o.obj# = do.object_number
   and o.owner# = u.user#
/
----------------------------------------------------------------------------

-- Private view to select all columns from streams$_dest_obj_cols
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_TABLE_COLUMNS"
as select
  object_number, column_name, flag, dblink, spare1, spare2
from sys.streams$_dest_obj_cols
/
----------------------------------------------------------------------------

-- Private helper view to create the view dba_apply_table_columns.
-- TODO: does not handle column name for objects. Need to revisit
-- when we support objects.
-- This view selects all the non-key columns in the table which
-- have not been explicitly specified a "compare" action.
create or replace view "_DBA_APPLY_TABLE_COLUMNS_H"
(OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME, APPLY_DATABASE_LINK) as
-- select all the columns in the table
(select u.name, o.name, c.name, do.dblink
  from sys.user$ u, sys.obj$ o, sys.col$ c, sys.streams$_dest_objs do
 where do.object_number = o.obj#
   and o.obj# = c.obj#
   and o.owner# = u.user#
   and ((do.dblink = o.linkname) or (do.dblink is null and o.linkname is null))
minus
-- omit the pk constraint columns from the list of columns
select u.name, o.name, decode(ac.name, null, col.name, ac.name), do.dblink
  from sys.user$ u, sys.con$ c, sys.col$ col, sys.ccol$ cc, sys.cdef$ cd,
       sys.obj$ o, sys.attrcol$ ac, sys.streams$_dest_objs do
 where c.owner# = u.user#
   and o.obj# = do.object_number
   and c.con# = cd.con#
   and cd.type# = 2
   and cd.con# = cc.con#
   and cc.obj# = col.obj#
   and cc.intcol# = col.intcol#
   and cc.obj# = o.obj#
   and col.obj# = ac.obj#(+)
   and col.intcol# = ac.intcol#(+)
   and ((do.dblink = o.linkname) or (do.dblink is null and o.linkname is null))
minus
-- omit columns designated as key columns
select kc.sname, kc.oname, kc.cname, do.dblink
  from sys.streams$_key_columns kc, sys.streams$_dest_objs do,
       sys.obj$ o, sys.user$ u
 where kc.sname = u.name
   and u.user# = o.owner#
   and o.name = kc.oname
   and o.obj# = do.object_number
   and ((kc.dblink = do.dblink) or (kc.dblink is null and do.dblink is null))
   and ((do.dblink = o.linkname) or (do.dblink is null and o.linkname is null))
minus
-- omit the columns which are in sys.streams$_dest_obj_cols
-- These may have a different setting than the one mentioned in
-- streams$_dest_objs. These columns will be included seperately later.
select u.name, o.name, doc.column_name, do.dblink
  from sys.streams$_dest_objs do, sys.streams$_dest_obj_cols doc,
       sys.obj$ o, sys.user$ u
 where do.object_number = doc.object_number
   and doc.object_number = o.obj#
   and ((do.dblink = doc.dblink) or (do.dblink is null and doc.dblink is null))
   and ((do.dblink = o.linkname) or (do.dblink is null and o.linkname is null))
   and o.owner# = u.user#)
/

----------------------------------------------------------------------------

create or replace view DBA_APPLY_TABLE_COLUMNS
(OBJECT_OWNER, OBJECT_NAME, COLUMN_NAME,
 COMPARE_OLD_ON_DELETE, COMPARE_OLD_ON_UPDATE, APPLY_DATABASE_LINK) as
(select daoc.object_owner, daoc.object_name, daoc.column_name,
       decode(bitand(ac.property, 1), 1, 'NO', 0, 'YES'),
       decode(bitand(ac.property, 2), 2, 'NO', 0, 'YES'),
       daoc.apply_database_link
  from "_DBA_APPLY_TABLE_COLUMNS_H" daoc, "_DBA_APPLY_OBJECTS" ac
 where daoc.object_owner = ac.object_owner
   and daoc.object_name  = ac.object_name
union
select u.name, o.name, doc.column_name,
       decode(bitand(doc.flag, 1), 1, 'NO', 0, 'YES'),
       decode(bitand(doc.flag, 2), 2, 'NO', 0, 'YES'),
       null
  from sys.streams$_dest_obj_cols doc, sys.obj$ o, sys.user$ u
 where o.obj# = doc.object_number
   and o.owner# = u.user#
   and o.linkname is null
   and doc.dblink is null
   and o.remoteowner is null
union
select o.remoteowner, o.name, doc.column_name,
       decode(bitand(doc.flag, 1), 1, 'NO', 0, 'YES'),
       decode(bitand(doc.flag, 2), 2, 'NO', 0, 'YES'),
       doc.dblink
  from sys.streams$_dest_obj_cols doc, sys.obj$ o
 where o.obj# = doc.object_number
   and o.linkname = doc.dblink
   and o.remoteowner is not null)
/

comment on table DBA_APPLY_TABLE_COLUMNS is
'Details about the destination table columns'
/
comment on column DBA_APPLY_TABLE_COLUMNS.OBJECT_OWNER is
'Owner of the table'
/
comment on column DBA_APPLY_TABLE_COLUMNS.OBJECT_NAME is
'Name of the table'
/
comment on column DBA_APPLY_TABLE_COLUMNS.COLUMN_NAME is
'Name of column'
/
comment on column DBA_APPLY_TABLE_COLUMNS.COMPARE_OLD_ON_DELETE is
'Compare old value of column on deletes'
/
comment on column DBA_APPLY_TABLE_COLUMNS.COMPARE_OLD_ON_UPDATE is
'Compare old value of column on updates'
/
comment on column DBA_APPLY_TABLE_COLUMNS.APPLY_DATABASE_LINK is
'For remote table, name of database link pointing to remote database'
/
create or replace public synonym DBA_APPLY_TABLE_COLUMNS
  for DBA_APPLY_TABLE_COLUMNS
/
grant select on DBA_APPLY_TABLE_COLUMNS to select_catalog_role
/
----------------------------------------------------------------------------

create or replace view ALL_APPLY_TABLE_COLUMNS
as
select do.*
  from all_tab_columns a, dba_apply_table_columns do
 where do.object_owner = a.owner
   and do.object_name = a.table_name
   and do.column_name = a.column_name
/
comment on table ALL_APPLY_TABLE_COLUMNS is
'Details about the columns of destination table object visible to the user'
/
comment on column ALL_APPLY_TABLE_COLUMNS.OBJECT_OWNER is
'Owner of the table'
/
comment on column ALL_APPLY_TABLE_COLUMNS.OBJECT_NAME is
'Name of the table'
/
comment on column ALL_APPLY_TABLE_COLUMNS.COLUMN_NAME is
'Name of column'
/
comment on column ALL_APPLY_TABLE_COLUMNS.COMPARE_OLD_ON_DELETE is
'Compare old value of column on deletes'
/
comment on column ALL_APPLY_TABLE_COLUMNS.COMPARE_OLD_ON_UPDATE is
'Compare old value of column on updates'
/
comment on column ALL_APPLY_TABLE_COLUMNS.APPLY_DATABASE_LINK is
'For remote tables, name of database link pointing to remote database'
/
create or replace public synonym ALL_APPLY_TABLE_COLUMNS
  for ALL_APPLY_TABLE_COLUMNS
/
grant select on ALL_APPLY_TABLE_COLUMNS to PUBLIC with grant option
/

----------------------------------------------------------------------------
-- view to get user procedure/error handling information during apply
----------------------------------------------------------------------------
create or replace view DBA_APPLY_DML_HANDLERS
  (OBJECT_OWNER, OBJECT_NAME, OPERATION_NAME,
   USER_PROCEDURE, ERROR_HANDLER, APPLY_DATABASE_LINK, APPLY_NAME,
   ASSEMBLE_LOBS, HANDLER_NAME, HANDLER_TYPE, SET_BY)
as
select sname, oname,
       decode(do.apply_operation, 0, 'DEFAULT',
                                  1, 'INSERT',
                                  2, 'UPDATE',
                                  3, 'DELETE',
                                  4, 'LOB_UPDATE',
                                  5, 'ASSEMBLE_LOBS', 'UNKNOWN'),
       do.user_apply_procedure,
       do.error_handler, o.linkname, do.apply_name, do.assemble_lobs,
       do.handler_name,
       case when user_apply_procedure is null and handler_name is not null
            then 'STMT HANDLER'
            when user_apply_procedure is not null and handler_name is null
            then decode(do.error_handler, 'Y', 'ERROR HANDLER', 'PROCEDURE HANDLER')
            else 'UNKNOWN'
       end,
       decode(do.set_by,           NULL,'USER',
                                      1,'GOLDENGATE')
  from sys.obj$ o, apply$_dest_obj_ops do
 where do.object_number = o.obj# (+)
/

comment on table DBA_APPLY_DML_HANDLERS is
'Details about the dml handler'
/
comment on column DBA_APPLY_DML_HANDLERS.OBJECT_OWNER is
'Owner of the object'
/
comment on column DBA_APPLY_DML_HANDLERS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_APPLY_DML_HANDLERS.OPERATION_NAME is
'Name of the DML operation'
/
comment on column DBA_APPLY_DML_HANDLERS.USER_PROCEDURE is
'Name of the DML handler specified by the user'
/
comment on column DBA_APPLY_DML_HANDLERS.ERROR_HANDLER is
'Y if the user procedure is the error handler, N if it is the DML handler'
/
comment on column DBA_APPLY_DML_HANDLERS.APPLY_DATABASE_LINK is
'For remote objects, name of database link pointing to remote database'
/
comment on column DBA_APPLY_DML_HANDLERS.APPLY_NAME is
'Name of the apply process for the given object'
/
comment on column DBA_APPLY_DML_HANDLERS.ASSEMBLE_LOBS is
'Y if LOBs should be assembled in DML or error handler'
/
comment on column DBA_APPLY_DML_HANDLERS.HANDLER_NAME is
'Name of the apply dml handler, NULL for the ERROR and PROCEDURE handler'
/
comment on column DBA_APPLY_DML_HANDLERS.HANDLER_TYPE is
'Type of the apply dml handler'
/
comment on column DBA_APPLY_DML_HANDLERS.SET_BY is
'Entity that set up the handler: USER, GOLDENGATE'
/
create or replace public synonym DBA_APPLY_DML_HANDLERS
  for DBA_APPLY_DML_HANDLERS
/
grant select on DBA_APPLY_DML_HANDLERS to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view ALL_APPLY_DML_HANDLERS
  (OBJECT_OWNER, OBJECT_NAME, OPERATION_NAME,
   USER_PROCEDURE, ERROR_HANDLER, APPLY_DATABASE_LINK, APPLY_NAME,
   ASSEMBLE_LOBS, SET_BY)
as
select h.object_owner, h.object_name, h.operation_name,
       h.user_procedure, h.error_handler, h.apply_database_link, h.apply_name,
       h.assemble_lobs, h.set_by
  from all_tables o, dba_apply_dml_handlers h
 where h.object_owner = o.owner
   and h.object_name = o.table_name
/

comment on table ALL_APPLY_DML_HANDLERS is
'Details about the dml handler on tables visible to the current user'
/
comment on column ALL_APPLY_DML_HANDLERS.OBJECT_OWNER is
'Owner of the object'
/
comment on column ALL_APPLY_DML_HANDLERS.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_APPLY_DML_HANDLERS.OPERATION_NAME is
'Name of the DML operation'
/
comment on column ALL_APPLY_DML_HANDLERS.USER_PROCEDURE is
'Name of the DML handler specified by the user'
/
comment on column ALL_APPLY_DML_HANDLERS.ERROR_HANDLER is
'Y if the user procedure is the error handler, N if it is the DML handler'
/
comment on column ALL_APPLY_DML_HANDLERS.APPLY_DATABASE_LINK is
'For remote objects, name of database link pointing to remote database'
/
comment on column ALL_APPLY_DML_HANDLERS.APPLY_NAME is
'Name of the apply process for the given object'
/
comment on column ALL_APPLY_DML_HANDLERS.ASSEMBLE_LOBS is
'Y if LOBs should be assembled in DML or error handler'
/
comment on column ALL_APPLY_DML_HANDLERS.SET_BY is
'Entity that set up the handler: USER, GOLDENGATE'
/
create or replace public synonym ALL_APPLY_DML_HANDLERS
  for ALL_APPLY_DML_HANDLERS
/
grant select on ALL_APPLY_DML_HANDLERS to public with grant option
/

----------------------------------------------------------------------------

-- Private view select to all columns from streams$_apply_milestone
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_MILESTONE"
as select 
  apply#, source_db_name, oldest_scn, commit_scn, synch_scn, epoch,
  processed_scn, apply_time, applied_message_create_time, spare1, start_scn,
  oldest_transaction_id, spill_lwm_scn, lwm_external_pos,
  spare2, spare3, oldest_position, spill_lwm_position, processed_position, 
  xout_processed_position, xout_processed_create_time, xout_processed_tid, 
  xout_processed_time, applied_high_position, oldest_create_time, 
  spill_lwm_create_time,
  spare4, spare5, spare6, spare7, flags
from sys.streams$_apply_milestone
/
grant select on "_DBA_APPLY_MILESTONE" to exp_full_database
/

-- Private view select to all columns from streams$_apply_progress
-- Used by export. Respective catalog views will select from this view.
create or replace view "_DBA_APPLY_PROGRESS"
as select 
  apply#, source_db_name, xidusn, xidslt, xidsqn, commit_scn, spare1,
  commit_position, transaction_id
from sys.streams$_apply_progress
/
grant select on "_DBA_APPLY_PROGRESS" to exp_full_database
/

create or replace view DBA_APPLY_PROGRESS
  (APPLY_NAME, SOURCE_DATABASE, APPLIED_MESSAGE_NUMBER, OLDEST_MESSAGE_NUMBER,
   APPLY_TIME, APPLIED_MESSAGE_CREATE_TIME, OLDEST_TRANSACTION_ID,
   SPILL_MESSAGE_NUMBER)
as
select ap.apply_name, am.source_db_name, 
       am.commit_scn, 
       am.oldest_scn, 
       apply_time, 
       am.applied_message_create_time, 
       oldest_transaction_id,
       spill_lwm_scn
  from streams$_apply_process ap, "_DBA_APPLY_MILESTONE" am,
        sys.xstream$_server xs
 where ap.apply# = am.apply#
   and ap.apply_name = xs.server_name (+)
/

comment on table DBA_APPLY_PROGRESS is
'Information about the progress made by apply process'
/
comment on column DBA_APPLY_PROGRESS.APPLY_NAME is
'Name of the apply process'
/
comment on column DBA_APPLY_PROGRESS.SOURCE_DATABASE is
'Applying messages originating from this database'
/
comment on column DBA_APPLY_PROGRESS.APPLIED_MESSAGE_NUMBER is
'All messages before this number have been successfully applied'
/
comment on column DBA_APPLY_PROGRESS.OLDEST_MESSAGE_NUMBER is
'Earliest commit number of the transactions currently being applied'
/
comment on column DBA_APPLY_PROGRESS.APPLY_TIME is
'Time at which the message was applied'
/
comment on column DBA_APPLY_PROGRESS.APPLIED_MESSAGE_CREATE_TIME is
'Time at which the message to be applied was created'
/
comment on column DBA_APPLY_PROGRESS.OLDEST_TRANSACTION_ID is
'Earliest transaction id currently being applied'
/
comment on column DBA_APPLY_PROGRESS.SPILL_MESSAGE_NUMBER is
'Spill low water mark SCN'
/
create or replace public synonym DBA_APPLY_PROGRESS for DBA_APPLY_PROGRESS
/
grant select on DBA_APPLY_PROGRESS to select_catalog_role
/

----------------------------------------------------------------------------
create or replace view ALL_APPLY_PROGRESS
  (APPLY_NAME, SOURCE_DATABASE, APPLIED_MESSAGE_NUMBER, OLDEST_MESSAGE_NUMBER,
   APPLY_TIME, APPLIED_MESSAGE_CREATE_TIME, OLDEST_TRANSACTION_ID, 
   SPILL_MESSAGE_NUMBER)
as
select ap.apply_name, ap.source_database, ap.applied_message_number, 
       ap.oldest_message_number, ap.apply_time, ap.applied_message_create_time,
       ap.oldest_transaction_id, ap.spill_message_number
  from dba_apply_progress ap, all_apply a
 where ap.apply_name = a.apply_name
/

comment on table ALL_APPLY_PROGRESS is
'Information about the progress made by the apply process that dequeues from the queue visible to the current user'
/
comment on column ALL_APPLY_PROGRESS.APPLY_NAME is
'Name of the apply process'
/
comment on column ALL_APPLY_PROGRESS.SOURCE_DATABASE is
'Applying messages originating from this database'
/
comment on column ALL_APPLY_PROGRESS.APPLIED_MESSAGE_NUMBER is
'All messages before this number have been successfully applied'
/
comment on column ALL_APPLY_PROGRESS.OLDEST_MESSAGE_NUMBER is
'Earliest commit number of the transactions currently being applied'
/
comment on column ALL_APPLY_PROGRESS.APPLY_TIME is
'Time at which the message was applied'
/
comment on column ALL_APPLY_PROGRESS.APPLIED_MESSAGE_CREATE_TIME is
'Time at which the message to be applied was created'
/
comment on column ALL_APPLY_PROGRESS.OLDEST_TRANSACTION_ID is
'Earliest transaction id currently being applied'
/
comment on column ALL_APPLY_PROGRESS.SPILL_MESSAGE_NUMBER is
'Spill low water mark SCN'
/
create or replace public synonym ALL_APPLY_PROGRESS for ALL_APPLY_PROGRESS
/
grant select on ALL_APPLY_PROGRESS to public with grant option
/

----------------------------------------------------------------------------

-- Private view select to all columns from apply$_error
-- Used by export. Respective catalog views will select from this view.
-- also used by integrated replicat. 
create or replace view "_DBA_APPLY_ERROR"
as select 
  local_transaction_id, source_transaction_id, source_database,
  queue_owner, queue_name, apply#, message_number, message_count,
  min_step_no, recipient_id, recipient_name, source_commit_scn,
  error_number, error_message, aq_transaction_id, error_creation_time,
  spare1, spare2, spare3, external_source_pos, spare4, spare5,
  commit_time, xidusn, xidslt, xidsqn, retry_count, flags, error_pos,
  start_seq#, end_seq#, start_rba, end_rba, error_seq#, error_rba, error_index#
from sys.apply$_error
/
grant select on "_DBA_APPLY_ERROR" to exp_full_database
/

create or replace view DBA_APPLY_ERROR
  (APPLY_NAME, QUEUE_NAME, QUEUE_OWNER, LOCAL_TRANSACTION_ID,
   SOURCE_DATABASE, SOURCE_TRANSACTION_ID,
   SOURCE_COMMIT_SCN, MESSAGE_NUMBER, ERROR_NUMBER,
   ERROR_MESSAGE, RECIPIENT_ID, RECIPIENT_NAME, MESSAGE_COUNT,
   ERROR_CREATION_TIME, SOURCE_COMMIT_POSITION, ERROR_TYPE, ERROR_POSITION)
as
select p.apply_name, e.queue_name, e.queue_owner, e.local_transaction_id,
       e.source_database, e.source_transaction_id,
       e.source_commit_scn, e.message_number, e.error_number,
       e.error_message, e.recipient_id, e.recipient_name, e.message_count,
       e.error_creation_time, e.external_source_pos,
       (case
          when (bitand(e.flags, 1) = 1) then 'EAGER ERROR'
          when (bitand(e.flags, 8) = 8) then
            (case
               when (bitand(e.flags, 2) = 2) then 'RECORD LCR'
               when (bitand(e.flags, 16) = 16) then 'RECORD TXN NO LCRS'
               else 'RECORD TXN WITH LCRS'
             end)
          when (bitand(e.flags, 16) = 16) then 'UNHANDLED ERROR NO LCRS'
          else NULL
       end), e.error_pos
  from "_DBA_APPLY_ERROR" e, sys.streams$_apply_process p 
 where e.apply# = p.apply#(+)
/

comment on table DBA_APPLY_ERROR is
'Error transactions'
/
comment on column DBA_APPLY_ERROR.APPLY_NAME iS
'Name of the apply process at the local site which processed the transaction'
/
comment on column DBA_APPLY_ERROR.QUEUE_NAME is
'Name of the queue at the local site where the transaction came from'
/
comment on column DBA_APPLY_ERROR.QUEUE_OWNER is
'Owner of the queue at the local site where the transaction came from'
/
comment on column DBA_APPLY_ERROR.LOCAL_TRANSACTION_ID is
'Local transaction ID for the error creation transaction'
/
comment on column DBA_APPLY_ERROR.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column DBA_APPLY_ERROR.SOURCE_TRANSACTION_ID is
'Original transaction ID at the source database'
/
comment on column DBA_APPLY_ERROR.SOURCE_COMMIT_SCN is
'Original commit SCN for the transaction at the source database'
/
comment on column DBA_APPLY_ERROR.MESSAGE_NUMBER is
'Identifier for the message in the transaction that raised an error'
/
comment on column DBA_APPLY_ERROR.ERROR_NUMBER is
'Error number'
/
comment on column DBA_APPLY_ERROR.ERROR_MESSAGE is
'Error message'
/
comment on column DBA_APPLY_ERROR.RECIPIENT_ID is
'User ID of the original recipient'
/
comment on column DBA_APPLY_ERROR.RECIPIENT_NAME is
'Name of the original recipient'
/
comment on column DBA_APPLY_ERROR.MESSAGE_COUNT is
'Total number of messages inside the error transaction'
/
comment on column DBA_APPLY_ERROR.ERROR_CREATION_TIME is
'The time that this error was created'
/
comment on column DBA_APPLY_ERROR.SOURCE_COMMIT_POSITION is
'Original commit position for the transaction'
/
comment on column DBA_APPLY_ERROR.ERROR_TYPE is
'The type of the error transaction'
/
comment on column DBA_APPLY_ERROR.ERROR_POSITION is
'Position of the LCR that encountered the error'
/
create or replace public synonym DBA_APPLY_ERROR for DBA_APPLY_ERROR
/
grant select on DBA_APPLY_ERROR to select_catalog_role
/

----------------------------------------------------------------------------
create or replace view ALL_APPLY_ERROR
  (APPLY_NAME, QUEUE_NAME, QUEUE_OWNER, LOCAL_TRANSACTION_ID,
   SOURCE_DATABASE, SOURCE_TRANSACTION_ID,
   SOURCE_COMMIT_SCN, MESSAGE_NUMBER, ERROR_NUMBER,
   ERROR_MESSAGE, RECIPIENT_ID, RECIPIENT_NAME, MESSAGE_COUNT, 
   ERROR_CREATION_TIME, SOURCE_COMMIT_POSITION, ERROR_TYPE, ERROR_POSITION)
as (
select e.apply_name, e.queue_name, e.queue_owner, e.local_transaction_id,
       e.source_database, e.source_transaction_id,
       e.source_commit_scn, e.message_number, e.error_number,
       e.error_message, e.recipient_id, e.recipient_name, e.message_count,
       e.error_creation_time, e.source_commit_position, 
       e.error_type, e.error_position
  from dba_apply_error e, all_users u, all_queues q
 where e.recipient_id = u.user_id
   and q.name = e.queue_name
   and q.owner = e.queue_owner
union all
select e.apply_name, e.queue_name, e.queue_owner, e.local_transaction_id,
       e.source_database, e.source_transaction_id,
       e.source_commit_scn, e.message_number, e.error_number,
       e.error_message, e.recipient_id, e.recipient_name, e.message_count,
       e.error_creation_time, e.source_commit_position, 
       e.error_type, e.error_position
  from dba_apply_error e
 where e.recipient_id NOT IN (select user_id from dba_users))
/  

comment on table ALL_APPLY_ERROR is
'Error transactions that were generated after dequeuing from the queue visible to the current user'
/
comment on column ALL_APPLY_ERROR.APPLY_NAME iS
'Name of the apply process at the local site which processed the transaction'
/
comment on column ALL_APPLY_ERROR.QUEUE_NAME is
'Name of the queue at the local site where the transaction came from'
/
comment on column ALL_APPLY_ERROR.QUEUE_OWNER is
'Owner of the queue at the local site where the transaction came from'
/
comment on column ALL_APPLY_ERROR.LOCAL_TRANSACTION_ID is
'Local transaction ID for the error creation transaction'
/
comment on column ALL_APPLY_ERROR.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column ALL_APPLY_ERROR.SOURCE_TRANSACTION_ID is
'Original transaction ID at the source database'
/
comment on column ALL_APPLY_ERROR.SOURCE_COMMIT_SCN is
'Original commit SCN for the transaction at the source database'
/
comment on column ALL_APPLY_ERROR.MESSAGE_NUMBER is
'Identifier for the message in the transaction that raised an error'
/
comment on column ALL_APPLY_ERROR.ERROR_NUMBER is
'Error number'
/
comment on column ALL_APPLY_ERROR.ERROR_MESSAGE is
'Error message'
/
comment on column ALL_APPLY_ERROR.RECIPIENT_ID is
'User ID of the original recipient'
/
comment on column ALL_APPLY_ERROR.RECIPIENT_NAME is
'Name of the original recipient'
/
comment on column ALL_APPLY_ERROR.MESSAGE_COUNT is
'Total number of messages inside the error transaction'
/
comment on column ALL_APPLY_ERROR.ERROR_CREATION_TIME is
'The time that this error occurred'
/
comment on column ALL_APPLY_ERROR.SOURCE_COMMIT_POSITION is
'Original commit position for the transaction'
/
comment on column ALL_APPLY_ERROR.ERROR_TYPE is
'The type of the error transaction'
/
comment on column ALL_APPLY_ERROR.ERROR_POSITION is
'Position of the LCR that encountered the error'
/
create or replace public synonym ALL_APPLY_ERROR for ALL_APPLY_ERROR
/
grant select on ALL_APPLY_ERROR to public with grant option
/

create or replace view USER_APPLY_ERROR
  (APPLY_NAME, QUEUE_NAME, QUEUE_OWNER, LOCAL_TRANSACTION_ID,
   SOURCE_DATABASE, SOURCE_TRANSACTION_ID,
   SOURCE_COMMIT_SCN, MESSAGE_NUMBER, ERROR_NUMBER,
   ERROR_MESSAGE, RECIPIENT_ID, RECIPIENT_NAME, MESSAGE_COUNT,
   ERROR_CREATION_TIME, SOURCE_COMMIT_POSITION, ERROR_TYPE,
   ERROR_POSITION)
as
select p.apply_name, e.queue_name, e.queue_owner, e.local_transaction_id,
       e.source_database, e.source_transaction_id,
       e.source_commit_scn, e.message_number, e.error_number,
       e.error_message, e.recipient_id, e.recipient_name, e.message_count,
       e.error_creation_time, e.source_commit_position, e.error_type,
       e.error_position
  from DBA_APPLY_ERROR e, sys.streams$_apply_process p, sys.user$ u
  where e.apply_name = p.apply_name and p.apply_userid = u.user#
        and u.name = sys_context('USERENV', 'CURRENT_USER')
/

comment on table USER_APPLY_ERROR is
'Error transactions owned by an apply visible to the current user'
/
comment on column USER_APPLY_ERROR.APPLY_NAME iS
'Name of the apply process at the local site which processed the transaction'
/
comment on column USER_APPLY_ERROR.QUEUE_NAME is
'Name of the queue at the local site where the transaction came from'
/
comment on column USER_APPLY_ERROR.QUEUE_OWNER is
'Owner of the queue at the local site where the transaction came from'
/
comment on column USER_APPLY_ERROR.LOCAL_TRANSACTION_ID is
'Local transaction ID for the error creation transaction'
/
comment on column USER_APPLY_ERROR.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column USER_APPLY_ERROR.SOURCE_TRANSACTION_ID is
'Original transaction ID at the source database'
/
comment on column USER_APPLY_ERROR.SOURCE_COMMIT_SCN is
'Original commit SCN for the transaction at the source database'
/
comment on column USER_APPLY_ERROR.MESSAGE_NUMBER is
'Identifier for the message in the transaction that raised an error'
/
comment on column USER_APPLY_ERROR.ERROR_NUMBER is
'Error number'
/
comment on column USER_APPLY_ERROR.ERROR_MESSAGE is
'Error message'
/
comment on column USER_APPLY_ERROR.RECIPIENT_ID is
'User ID of the original recipient'
/
comment on column USER_APPLY_ERROR.RECIPIENT_NAME is
'Name of the original recipient'
/
comment on column USER_APPLY_ERROR.MESSAGE_COUNT is
'Total number of messages inside the error transaction'
/
comment on column USER_APPLY_ERROR.ERROR_CREATION_TIME is
'The time that this error was created'
/
comment on column USER_APPLY_ERROR.SOURCE_COMMIT_POSITION is
'Original commit position for the transaction'
/
comment on column USER_APPLY_ERROR.ERROR_TYPE is
'The type of the error transaction'
/
comment on column USER_APPLY_ERROR.ERROR_POSITION is
'Position of the LCR that encountered the error'
/
create or replace public synonym USER_APPLY_ERROR for USER_APPLY_ERROR
/
grant select on USER_APPLY_ERROR to public with grant option
/

----------------------------------------------------------------------------
-- Private view select to all columns from apply$_error_txn
-- Used by export. Also used by integrated replicat. 
create or replace view "_DBA_APPLY_ERROR_TXN"
as select 
  local_transaction_id, txn_message_number, msg_id, error_number, 
  error_message, flags, spare1, spare2, spare3, spare4, spare5, spare6,
  message, source_object_owner, source_object_name, dest_object_owner,
  dest_object_name, primary_key, position, message_flags, operation,
  seq#, rba, index#
from sys.apply$_error_txn
/

grant select on "_DBA_APPLY_ERROR_TXN" to exp_full_database
/

----------------------------------------------------------------------------
-- view to information about individual messages in an error transaction
----------------------------------------------------------------------------

create or replace view DBA_APPLY_ERROR_MESSAGES 
(MESSAGE_ID, LOCAL_TRANSACTION_ID, TRANSACTION_MESSAGE_NUMBER, 
 ERROR_NUMBER, ERROR_MESSAGE, SOURCE_OBJECT_OWNER, SOURCE_OBJECT_NAME,
 OBJECT_OWNER, OBJECT_NAME, PRIMARY_KEY, POSITION, OPERATION, MESSAGE) as 
select msg_id, local_transaction_id, txn_message_number+1, 
       error_number, error_message, nvl(source_object_owner,dest_object_owner),
       nvl(source_object_name, dest_object_name),
       dest_object_owner, dest_object_name, primary_key, position, operation,
       dbms_streams_lcr_int.get_lcr_content(
         dbms_apply_adm.get_error_message(txn_message_number+1, 
                                          local_transaction_id), '*')
from sys.apply$_error_txn;

comment on table DBA_APPLY_ERROR_MESSAGES is
'Details about individual messages in an error transaction'
/
comment on column DBA_APPLY_ERROR_MESSAGES.MESSAGE_ID is
'AQ message ID for a message stored in the AQ exception queue'
/
comment on column DBA_APPLY_ERROR_MESSAGES.LOCAL_TRANSACTION_ID is
'Local transaction ID for the error creation transaction'
/
comment on column DBA_APPLY_ERROR_MESSAGES.TRANSACTION_MESSAGE_NUMBER is
'Identifier for the message in the transaction that raised an error'
/
comment on column DBA_APPLY_ERROR_MESSAGES.ERROR_NUMBER is
'Error number'
/
comment on column DBA_APPLY_ERROR_MESSAGES.ERROR_MESSAGE is
'Error message'
/
comment on column DBA_APPLY_ERROR_MESSAGES.SOURCE_OBJECT_OWNER is
'Owner of the object at the source database'
/
comment on column DBA_APPLY_ERROR_MESSAGES.SOURCE_OBJECT_NAME is
'Name of the object at the source database'
/
comment on column DBA_APPLY_ERROR_MESSAGES.OBJECT_OWNER is
'Owner of the object'
/
comment on column DBA_APPLY_ERROR_MESSAGES.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_APPLY_ERROR_MESSAGES.PRIMARY_KEY is
'Primary key information'
/
comment on column DBA_APPLY_ERROR_MESSAGES.POSITION is
'Position information'
/
comment on column DBA_APPLY_ERROR_MESSAGES.OPERATION is
'Message operation'
/
comment on column DBA_APPLY_ERROR_MESSAGES.MESSAGE is
'Message content'
/
create or replace public synonym DBA_APPLY_ERROR_MESSAGES 
for DBA_APPLY_ERROR_MESSAGES
/
grant select on DBA_APPLY_ERROR_MESSAGES to select_catalog_role
/

create or replace view ALL_APPLY_ERROR_MESSAGES 
(MESSAGE_ID, LOCAL_TRANSACTION_ID, TRANSACTION_MESSAGE_NUMBER, 
 ERROR_NUMBER, ERROR_MESSAGE, SOURCE_OBJECT_OWNER, SOURCE_OBJECT_NAME,
 OBJECT_OWNER, OBJECT_NAME, PRIMARY_KEY, POSITION, OPERATION, MESSAGE) as 
select t.msg_id, t.local_transaction_id, t.txn_message_number+1, 
       t.error_number, t.error_message, 
       nvl(t.source_object_owner, t.dest_object_owner),
       nvl(t.source_object_name, t.dest_object_name), 
       t.dest_object_owner, t.dest_object_name,
       t.primary_key, t.position, t.operation,
       dbms_streams_lcr_int.get_lcr_content(
         dbms_apply_adm.get_error_message(t.txn_message_number+1,
                                          t.local_transaction_id), '*')
from sys.apply$_error_txn t, all_apply_error e
where t.local_transaction_id = e.local_transaction_id ;

comment on table ALL_APPLY_ERROR_MESSAGES is
'Details about individual messages in an error transaction'
/
comment on column ALL_APPLY_ERROR_MESSAGES.MESSAGE_ID is
'AQ message ID for a message stored in the AQ exception queue'
/
comment on column ALL_APPLY_ERROR_MESSAGES.LOCAL_TRANSACTION_ID is
'Local transaction ID for the error creation transaction'
/
comment on column ALL_APPLY_ERROR_MESSAGES.TRANSACTION_MESSAGE_NUMBER is
'Identifier for the message in the transaction that raised an error'
/
comment on column ALL_APPLY_ERROR_MESSAGES.ERROR_NUMBER is
'Error number'
/
comment on column ALL_APPLY_ERROR_MESSAGES.ERROR_MESSAGE is
'Error message'
/
comment on column ALL_APPLY_ERROR_MESSAGES.SOURCE_OBJECT_OWNER is
'Owner of the object at the source database'
/
comment on column ALL_APPLY_ERROR_MESSAGES.SOURCE_OBJECT_NAME is
'Name of the object at the source database'
/
comment on column ALL_APPLY_ERROR_MESSAGES.OBJECT_OWNER is
'Owner of the object'
/
comment on column ALL_APPLY_ERROR_MESSAGES.OBJECT_NAME is
'Name of the object'
/
comment on column ALL_APPLY_ERROR_MESSAGES.PRIMARY_KEY is
'Primary key information'
/
comment on column ALL_APPLY_ERROR_MESSAGES.POSITION is
'Position information'
/
comment on column ALL_APPLY_ERROR_MESSAGES.OPERATION is
'Message operation'
/
comment on column ALL_APPLY_ERROR_MESSAGES.MESSAGE is
'Message content'
/
create or replace public synonym ALL_APPLY_ERROR_MESSAGES 
for ALL_APPLY_ERROR_MESSAGES
/
grant select on ALL_APPLY_ERROR_MESSAGES to public with grant option
/

----------------------------------------------------------------------------
-- view to show where events satisfying the corresponding rules in the apply
-- rule set will be enqueued.
----------------------------------------------------------------------------

create or replace view DBA_APPLY_ENQUEUE
(RULE_OWNER, RULE_NAME, DESTINATION_QUEUE_NAME) as
select r.rule_owner, r.rule_name, sys.anydata.AccessVarchar2(ctx.nvn_value)
from DBA_RULES r, table(r.rule_action_context.actx_list) ctx
where ctx.nvn_name = 'APPLY$_ENQUEUE';

comment on table DBA_APPLY_ENQUEUE is
'Details about the apply enqueue action'
/
comment on column DBA_APPLY_ENQUEUE.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_APPLY_ENQUEUE.RULE_NAME is
'Name of the rule'
/
comment on column DBA_APPLY_ENQUEUE.DESTINATION_QUEUE_NAME is
'Name of the queue where events satisfying the rule will be enqueued'
/
create or replace public synonym DBA_APPLY_ENQUEUE for DBA_APPLY_ENQUEUE
/
grant select on DBA_APPLY_ENQUEUE to select_catalog_role
/

create or replace view ALL_APPLY_ENQUEUE as
select e.*
from dba_apply_enqueue e, ALL_RULES r, ALL_QUEUES aq
where e.rule_owner = r.rule_owner and e.rule_name = r.rule_name
  and e.destination_queue_name = '"'||aq.owner||'"' ||'.'|| '"'||aq.name||'"';

comment on table ALL_APPLY_ENQUEUE is
'Details about the apply enqueue action for user accessible rules where the destination queue exists and is visible to the user'
/
comment on column ALL_APPLY_ENQUEUE.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_APPLY_ENQUEUE.RULE_NAME is
'Name of the rule'
/
comment on column ALL_APPLY_ENQUEUE.DESTINATION_QUEUE_NAME is
'Name of the queue where events satisfying the rule will be enqueued'
/
create or replace public synonym ALL_APPLY_ENQUEUE for ALL_APPLY_ENQUEUE
/
grant select on ALL_APPLY_ENQUEUE to public with grant option
/

----------------------------------------------------------------------------
-- view to show rules with a value for APPLY$_EXECUTE in the action context.
----------------------------------------------------------------------------

create or replace view DBA_APPLY_EXECUTE
(RULE_OWNER, RULE_NAME, EXECUTE_EVENT) as
select r.rule_owner, r.rule_name,
  decode(sys.anydata.AccessVarchar2(ctx.nvn_value), 'NO', 'NO', NULL)
from DBA_RULES r, table(r.rule_action_context.actx_list) ctx
where ctx.nvn_name = 'APPLY$_EXECUTE';

comment on table DBA_APPLY_EXECUTE is
'Details about the apply execute action'
/
comment on column DBA_APPLY_EXECUTE.RULE_OWNER is
'Owner of the rule'
/
comment on column DBA_APPLY_EXECUTE.RULE_NAME is
'Name of the rule'
/
comment on column DBA_APPLY_EXECUTE.EXECUTE_EVENT is
'Whether the event satisfying the rule is executed'
/
create or replace public synonym DBA_APPLY_EXECUTE for DBA_APPLY_EXECUTE
/
grant select on DBA_APPLY_EXECUTE to select_catalog_role
/

create or replace view ALL_APPLY_EXECUTE as
select e.*
from dba_apply_execute e, ALL_RULES r
where e.rule_owner = r.rule_owner and e.rule_name = r.rule_name;

comment on table ALL_APPLY_EXECUTE is
'Details about the apply execute action for all rules visible to the user'
/
comment on column ALL_APPLY_EXECUTE.RULE_OWNER is
'Owner of the rule'
/
comment on column ALL_APPLY_EXECUTE.RULE_NAME is
'Name of the rule'
/
comment on column ALL_APPLY_EXECUTE.EXECUTE_EVENT is
'Whether the event satisfying the rule is executed'
/
create or replace public synonym ALL_APPLY_EXECUTE for ALL_APPLY_EXECUTE
/
grant select on ALL_APPLY_EXECUTE to public with grant option
/


-------------------------------------------
-- apply spilling views
-------------------------------------------

-- internal streams apply spilled transactions view
create or replace view "_DBA_APPLY_SPILL_TXN"
  (APPLY_NAME, XIDUSN, XIDSLT, XIDSQN, FIRST_SCN, MESSAGE_COUNT,
   FIRST_MESSAGE_CREATE_TIME, SPILL_CREATION_TIME, SPILL_FLAGS,
   FIRST_POSITION, TRANSACTION_ID)
as
select applyname, xidusn, xidslt, xidsqn, first_scn, spillcount,
       first_message_create_time, spill_creation_time, spill_flags,
       first_position, transaction_id
  from sys.streams$_apply_spill_txn
/
grant select on "_DBA_APPLY_SPILL_TXN" to exp_full_database
/

-- streams apply spilled transactions view
create or replace view DBA_APPLY_SPILL_TXN
  (APPLY_NAME, XIDUSN, XIDSLT, XIDSQN, FIRST_SCN, MESSAGE_COUNT,
   FIRST_MESSAGE_CREATE_TIME, SPILL_CREATION_TIME, FIRST_POSITION,
   TRANSACTION_ID)
as
select apply_name, xidusn, xidslt, xidsqn, first_scn, message_count,
       first_message_create_time, spill_creation_time, first_position,
       transaction_id
  from "_DBA_APPLY_SPILL_TXN"
  where bitand(spill_flags, 4) = 0
/

comment on table DBA_APPLY_SPILL_TXN is
'Streams apply spilled transactions info'
/
comment on column DBA_APPLY_SPILL_TXN.APPLY_NAME is
'Name of the apply that spilled the message'
/
comment on column DBA_APPLY_SPILL_TXN.XIDUSN is
'Transaction ID undo segment number'
/
comment on column DBA_APPLY_SPILL_TXN.XIDSLT is
'Transaction ID slot number'
/
comment on column DBA_APPLY_SPILL_TXN.XIDSQN is
'Transaction ID sequence number'
/
comment on column DBA_APPLY_SPILL_TXN.FIRST_SCN is
'SCN of first message in this transaction'
/
comment on column DBA_APPLY_SPILL_TXN.MESSAGE_COUNT is
'Number of messages spilled for this transaction'
/
comment on column DBA_APPLY_SPILL_TXN.FIRST_MESSAGE_CREATE_TIME is
'Source creation time of the first message in this transaction'
/
comment on column DBA_APPLY_SPILL_TXN.SPILL_CREATION_TIME is
'Time first message was spilled'
/
comment on column DBA_APPLY_SPILL_TXN.SPILL_CREATION_TIME is
'Time first message was spilled'
/
comment on column DBA_APPLY_SPILL_TXN.FIRST_POSITION is
'Position of first message in this transaction'
/
comment on column DBA_APPLY_SPILL_TXN.TRANSACTION_ID is
'Transaction ID of the spilled transaction'
/
create or replace public synonym DBA_APPLY_SPILL_TXN
  for DBA_APPLY_SPILL_TXN
/
grant select on DBA_APPLY_SPILL_TXN to select_catalog_role
/

----------------------------------------------------------------------------
-- streams apply spilled transactions view
create or replace view ALL_APPLY_SPILL_TXN as
select ast.*
  from DBA_APPLY_SPILL_TXN ast, ALL_APPLY aa
  where aa.apply_name = ast.apply_name
/

comment on table ALL_APPLY_SPILL_TXN is
'Streams apply spilled transactions info to the user'
/
comment on column ALL_APPLY_SPILL_TXN.APPLY_NAME is
'Name of the apply that spilled the message'
/
comment on column ALL_APPLY_SPILL_TXN.XIDUSN is
'Transaction ID undo segment number'
/
comment on column ALL_APPLY_SPILL_TXN.XIDSLT is
'Transaction ID slot number'
/
comment on column ALL_APPLY_SPILL_TXN.XIDSQN is
'Transaction ID sequence number'
/
comment on column ALL_APPLY_SPILL_TXN.FIRST_SCN is
'SCN of first message in this transaction'
/
comment on column ALL_APPLY_SPILL_TXN.MESSAGE_COUNT is
'Number of messages spilled for this transaction'
/
comment on column ALL_APPLY_SPILL_TXN.FIRST_MESSAGE_CREATE_TIME is
'Source creation time of the first message in this transaction'
/

comment on column ALL_APPLY_SPILL_TXN.SPILL_CREATION_TIME is
'Time first message was spilled'
/
comment on column ALL_APPLY_SPILL_TXN.SPILL_CREATION_TIME is
'Time first message was spilled'
/
comment on column ALL_APPLY_SPILL_TXN.FIRST_POSITION is
'Position of first message in this transaction'
/
comment on column ALL_APPLY_SPILL_TXN.TRANSACTION_ID is
'Transaction ID of the spilled transaction'
/
create or replace public synonym ALL_APPLY_SPILL_TXN
  for ALL_APPLY_SPILL_TXN
/
grant select on ALL_APPLY_SPILL_TXN to select_catalog_role
/

----------------------------------------------------------------------------

create or replace view GV_$STREAMS_APPLY_COORDINATOR
as
select * from gv$streams_apply_coordinator;
create or replace public synonym GV$STREAMS_APPLY_COORDINATOR 
  for gv_$streams_apply_coordinator;
grant select on GV_$STREAMS_APPLY_COORDINATOR to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$STREAMS_APPLY_COORDINATOR
as
select * from v$streams_apply_coordinator;
create or replace public synonym V$STREAMS_APPLY_COORDINATOR 
  for v_$streams_apply_coordinator;
grant select on V_$STREAMS_APPLY_COORDINATOR to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$STREAMS_APPLY_SERVER
as
select * from gv$streams_apply_server;
create or replace public synonym GV$STREAMS_APPLY_SERVER 
  for gv_$streams_apply_server;
grant select on GV_$STREAMS_APPLY_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$STREAMS_APPLY_SERVER
as
select * from v$streams_apply_server;
create or replace public synonym V$STREAMS_APPLY_SERVER 
  for v_$streams_apply_server;
grant select on V_$STREAMS_APPLY_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$STREAMS_APPLY_READER
as
select * from gv$streams_apply_reader;
create or replace public synonym GV$STREAMS_APPLY_READER 
  for gv_$streams_apply_reader;
grant select on GV_$STREAMS_APPLY_READER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$STREAMS_APPLY_READER
as
select * from v$streams_apply_reader;
create or replace public synonym V$STREAMS_APPLY_READER 
  for v_$streams_apply_reader;
grant select on V_$STREAMS_APPLY_READER to select_catalog_role;

create or replace view GV_$XSTREAM_APPLY_COORDINATOR
as
select * from gv$xstream_apply_coordinator;
create or replace public synonym GV$XSTREAM_APPLY_COORDINATOR
  for gv_$xstream_apply_coordinator;
grant select on GV_$XSTREAM_APPLY_COORDINATOR to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$XSTREAM_APPLY_COORDINATOR
as
select * from v$xstream_apply_coordinator;
create or replace public synonym V$XSTREAM_APPLY_COORDINATOR
  for v_$xstream_apply_coordinator;
grant select on V_$XSTREAM_APPLY_COORDINATOR to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$XSTREAM_APPLY_SERVER
as
select * from gv$xstream_apply_server;
create or replace public synonym GV$XSTREAM_APPLY_SERVER
  for gv_$xstream_apply_server;
grant select on GV_$XSTREAM_APPLY_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$XSTREAM_APPLY_SERVER
as
select * from v$xstream_apply_server;
create or replace public synonym V$XSTREAM_APPLY_SERVER
  for v_$xstream_apply_server;
grant select on V_$XSTREAM_APPLY_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$XSTREAM_APPLY_READER
as
select * from gv$xstream_apply_reader;
create or replace public synonym GV$XSTREAM_APPLY_READER
  for gv_$xstream_apply_reader;
grant select on GV_$XSTREAM_APPLY_READER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$XSTREAM_APPLY_READER
as
select * from v$xstream_apply_reader;
create or replace public synonym V$XSTREAM_APPLY_READER
  for v_$xstream_apply_reader;
grant select on V_$XSTREAM_APPLY_READER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$GG_APPLY_COORDINATOR
as
select * from gv$gg_apply_coordinator;
create or replace public synonym GV$GG_APPLY_COORDINATOR
  for gv_$gg_apply_coordinator;
grant select on GV_$GG_APPLY_COORDINATOR to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$GG_APPLY_COORDINATOR
as
select * from v$gg_apply_coordinator;
create or replace public synonym V$GG_APPLY_COORDINATOR
  for v_$gg_apply_coordinator;
grant select on V_$GG_APPLY_COORDINATOR to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$GG_APPLY_SERVER
as
select * from gv$gg_apply_server;
create or replace public synonym GV$GG_APPLY_SERVER
  for gv_$gg_apply_server;
grant select on GV_$GG_APPLY_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$GG_APPLY_SERVER
as
select * from v$gg_apply_server;
create or replace public synonym V$GG_APPLY_SERVER
  for v_$gg_apply_server;
grant select on V_$GG_APPLY_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$GG_APPLY_READER
as
select * from gv$gg_apply_reader;
create or replace public synonym GV$GG_APPLY_READER
  for gv_$gg_apply_reader;
grant select on GV_$GG_APPLY_READER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$GG_APPLY_READER
as
select * from v$gg_apply_reader;
create or replace public synonym V$GG_APPLY_READER
  for v_$gg_apply_reader;
grant select on V_$GG_APPLY_READER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$XSTREAM_OUTBOUND_SERVER
as
select * from gv$xstream_outbound_server;
create or replace public synonym GV$XSTREAM_OUTBOUND_SERVER
  for gv_$xstream_outbound_server;
grant select on GV_$XSTREAM_OUTBOUND_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$XSTREAM_OUTBOUND_SERVER
as
select * from v$xstream_outbound_server;
create or replace public synonym V$XSTREAM_OUTBOUND_SERVER
  for v_$xstream_outbound_server;
grant select on V_$XSTREAM_OUTBOUND_SERVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$XSTREAM_TABLE_STATS
as
select * from gv$xstream_table_stats;
create or replace public synonym GV$XSTREAM_TABLE_STATS
  for gv_$xstream_table_stats;
grant select on GV_$XSTREAM_TABLE_STATS to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$XSTREAM_TABLE_STATS
as
select * from v$xstream_table_stats;
create or replace public synonym V$XSTREAM_TABLE_STATS
  for v_$xstream_table_stats;
grant select on V_$XSTREAM_TABLE_STATS to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$GG_APPLY_RECEIVER
as
select * from gv$gg_apply_receiver;
create or replace public synonym GV$GG_APPLY_RECEIVER
  for gv_$gg_apply_receiver;
grant select on GV_$GG_APPLY_RECEIVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$GG_APPLY_RECEIVER
as
select * from v$gg_apply_receiver;
create or replace public synonym V$GG_APPLY_RECEIVER
  for v_$gg_apply_receiver;
grant select on V_$GG_APPLY_RECEIVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view GV_$XSTREAM_APPLY_RECEIVER
as
select * from gv$xstream_apply_receiver;
create or replace public synonym GV$XSTREAM_APPLY_RECEIVER
  for gv_$xstream_apply_receiver;
grant select on GV_$XSTREAM_APPLY_RECEIVER to select_catalog_role;

----------------------------------------------------------------------------

create or replace view V_$XSTREAM_APPLY_RECEIVER
as
select * from v$xstream_apply_receiver;
create or replace public synonym V$XSTREAM_APPLY_RECEIVER
  for v_$xstream_apply_receiver;
grant select on V_$XSTREAM_APPLY_RECEIVER to select_catalog_role;

-- ------------------------------------------------------------------------
-- Bug 2265160: Alter initrans, pctfree, freelists values for the 
-- streams$_apply_progress table. 
-- ------------------------------------------------------------------------
DECLARE
  block_size   INTEGER;
  free_lists   INTEGER;
  initrans     INTEGER;
  atb_stmt     VARCHAR2(500);
  done         BOOLEAN      := FALSE;
BEGIN

  SELECT tbs.block_size INTO block_size
  FROM dba_tables tbl, dba_tablespaces tbs
  WHERE tbl.owner = 'SYS' AND
        tbl.table_name = 'STREAMS$_APPLY_PROGRESS' AND
        tbl.tablespace_name = tbs.tablespace_name;

  -- Compute freelists
  -- Formula for computing freelists = 0.25*blocksize/25
  -- 25 is the overhead of each freelist. Using a quarter of (blocksize/25) 
  -- is a good and conservative estimate. 
  free_lists := 0.25*block_size/25;

  -- Since we allow only inserts into this table, set initrans to the number
  -- of rows that could be inserted into a block. Based on some analysis, this
  -- value turned out to be around 30 for a 2k block size. 
  initrans := 30*block_size/2048;

  -- Restrict max value of initrans to 128
  IF initrans > 128 THEN
    initrans := 128;
  END IF;

  -- PCTFREE = 0 since there are no updates to this table.
  WHILE NOT done LOOP
    BEGIN
      atb_stmt := 'ALTER TABLE sys.streams$_apply_progress INITRANS ' || 
                   initrans || ' PCTFREE 0 STORAGE (FREELISTS ' || 
                   free_lists || ')';
      EXECUTE IMMEDIATE atb_stmt;
      done := TRUE;
    EXCEPTION WHEN OTHERS THEN
      IF sqlcode = -1590 THEN
        IF free_lists < 20 THEN
          done := TRUE;
        ELSE
          free_lists := free_lists-2;
        END IF;
      ELSE
        RAISE;
      END IF;
    END;
  END LOOP;

EXCEPTION WHEN OTHERS THEN
  -- Do not raise exceptions in CAT files
  NULL;
END;
/

----------------------------------------------------------------------------
--  DBA_XSTREAM_* and ALL_XSTREAM_* VIEWS
----------------------------------------------------------------------------
create or replace view dba_xstream_outbound
  (server_name, connect_user, capture_name, source_database, capture_user,
   queue_owner, queue_name, user_comment, create_date, status,
   committed_data_only, start_scn, start_time)
as select server_name, xs.connect_user,
   cap.capture_name, source_database, cap.capture_user, app.queue_owner,
   app.queue_name, user_comment, create_date, 
   case when (bitand(xs.flags, 4) = 4) 
     then                                                /* uncommitted mode */
       decode(cap.status, 'ENABLED',
              decode ((select count(*) from gv$xstream_outbound_server
                         where server_name = xs.server_name),
                      0, 'DETACHED', 'ATTACHED'), cap.status)
     else                                                /*   committed mode */
       decode(app.status, 'ENABLED',
               decode ((select count(*) from gv$xstream_outbound_server
                          where server_name = xs.server_name),
                        0, 'DETACHED', 'ATTACHED'), app.status) end,
   decode(bitand(xs.flags, 4), 4, 'NO', 0, 'YES'),
   cap.start_scn, cap.start_time
   from sys.xstream$_server xs, dba_apply app, dba_capture cap
   where app.apply_name = xs.server_name and
         cap.queue_owner(+) = app.queue_owner and
         cap.queue_name(+) = app.queue_name and
         bitand(xs.flags, 1) = 1                      /* XStream Out process */
/
comment on table DBA_XSTREAM_OUTBOUND is 
'Details about the XStream outbound server'
/
comment on column DBA_XSTREAM_OUTBOUND.SERVER_NAME is
'Name of the outbound server'
/ 
comment on column DBA_XSTREAM_OUTBOUND.CONNECT_USER is
'Name of the user who can process the outbound LCR stream'
/ 
comment on column DBA_XSTREAM_OUTBOUND.CAPTURE_NAME is
'Name of the STREAMS capture process'
/
comment on column DBA_XSTREAM_OUTBOUND.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column DBA_XSTREAM_OUTBOUND.CAPTURE_USER is
'Current user who is enqueuing captured messages'
/
comment on column DBA_XSTREAM_OUTBOUND.QUEUE_OWNER is
'Owner of the queue associated with the outbound server'
/
comment on column DBA_XSTREAM_OUTBOUND.QUEUE_NAME is
'Name of the queue associated with the outbound server'
/
comment on column DBA_XSTREAM_OUTBOUND.USER_COMMENT is
'User comment'
/
comment on column DBA_XSTREAM_OUTBOUND.CREATE_DATE is
'Date when outbound server was created'
/
comment on column DBA_XSTREAM_OUTBOUND.STATUS is
'Status of the apply process: DISABLED, ABORTED, DETACHED, ATTACHED'
/
comment on column DBA_XSTREAM_OUTBOUND.COMMITTED_DATA_ONLY is
'Is outbound server sending committed data only?'
/
comment on column DBA_XSTREAM_OUTBOUND.START_SCN is
'Start SCN of the associated co-located capture process'
/
comment on column DBA_XSTREAM_OUTBOUND.START_TIME is
'Start time of the associated co-located capture process'
/
create or replace public synonym dba_xstream_outbound
  for dba_xstream_outbound
/
grant select on dba_xstream_outbound to select_catalog_role
/

create or replace view all_xstream_outbound 
as select ob.*
   from dba_xstream_outbound ob, all_apply app
   where app.apply_name = ob.server_name
/
comment on table ALL_XSTREAM_OUTBOUND is 
'Details about the XStream outbound server visible to user'
/
comment on column ALL_XSTREAM_OUTBOUND.SERVER_NAME is
'Name of the outbound server'
/ 
comment on column ALL_XSTREAM_OUTBOUND.CONNECT_USER is
'Name of the user who can process the outbound LCR stream'
/ 
comment on column ALL_XSTREAM_OUTBOUND.CAPTURE_NAME is
'Name of the STREAMS capture process'
/
comment on column ALL_XSTREAM_OUTBOUND.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column ALL_XSTREAM_OUTBOUND.CAPTURE_USER is
'Current user who is enqueuing captured messages'
/
comment on column ALL_XSTREAM_OUTBOUND.QUEUE_OWNER is
'Owner of the queue associated with the outbound server'
/
comment on column ALL_XSTREAM_OUTBOUND.QUEUE_NAME is
'Name of the queue associated with the outbound server'
/
comment on column ALL_XSTREAM_OUTBOUND.USER_COMMENT is
'User comment'
/
comment on column ALL_XSTREAM_OUTBOUND.CREATE_DATE is
'Date when outbound server was created'
/
comment on column ALL_XSTREAM_OUTBOUND.STATUS is
'Status of the apply process: DISABLED, ABORTED, DETACHED, ATTACHED'
/
comment on column ALL_XSTREAM_OUTBOUND.COMMITTED_DATA_ONLY is
'Is outbound server sending committed data only?'
/
comment on column ALL_XSTREAM_OUTBOUND.START_SCN is
'Start SCN of the associated co-located capture process'
/
comment on column ALL_XSTREAM_OUTBOUND.START_TIME is
'Start time of the associated co-located capture process'
/
create or replace public synonym all_xstream_outbound
  for all_xstream_outbound
/
grant select on all_xstream_outbound to select_catalog_role
/

create or replace view dba_xstream_outbound_progress
  (server_name, source_database, processed_low_position, 
   processed_low_time, oldest_position)
as select xs.server_name, xs.source_database, 
          am.xout_processed_position, am.xout_processed_time,
          oldest_position 
from  streams$_apply_process ap, "_DBA_APPLY_MILESTONE" am, 
      dba_xstream_outbound xs
 where ap.apply# = am.apply#
   and ap.apply_name = xs.server_name
/
comment on column DBA_XSTREAM_OUTBOUND_PROGRESS.SERVER_NAME is
'Name of the outbound server'
/ 
comment on column DBA_XSTREAM_OUTBOUND_PROGRESS.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column DBA_XSTREAM_OUTBOUND_PROGRESS.PROCESSED_LOW_POSITION is
'Position of low watermark transaction processed by client'
/
comment on column DBA_XSTREAM_OUTBOUND_PROGRESS.PROCESSED_LOW_TIME is
'Time which the processed low position was last updated'
/
comment on column DBA_XSTREAM_OUTBOUND_PROGRESS.OLDEST_POSITION is
'Earliest position of the transactions currently being applied'
/
create or replace public synonym dba_xstream_outbound_progress
  for dba_xstream_outbound_progress
/
grant select on dba_xstream_outbound_progress to select_catalog_role
/
 
create or replace view all_xstream_outbound_progress
as select xp.*
from dba_xstream_outbound_progress xp, all_apply a
 where a.apply_name = xp.server_name
/
comment on column ALL_XSTREAM_OUTBOUND_PROGRESS.SERVER_NAME is
'Name of the outbound server'
/ 
comment on column ALL_XSTREAM_OUTBOUND_PROGRESS.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column ALL_XSTREAM_OUTBOUND_PROGRESS.PROCESSED_LOW_POSITION is
'Position of low watermark transaction processed by client'
/
comment on column ALL_XSTREAM_OUTBOUND_PROGRESS.PROCESSED_LOW_TIME is
'Time which the processed low position was last updated'
/
comment on column DBA_XSTREAM_OUTBOUND_PROGRESS.OLDEST_POSITION is
'Earliest position of the transactions currently being applied'
/
create or replace public synonym all_xstream_outbound_progress
  for all_xstream_outbound_progress
/
grant select on all_xstream_outbound_progress to select_catalog_role
/
 
create or replace view dba_xstream_inbound
  (server_name, queue_owner, queue_name, apply_user, 
   user_comment, create_date, status, committed_data_only)
as select server_name, xs.queue_owner, xs.queue_name, app.apply_user,
   user_comment, create_date, 
   decode(app.status, 'ENABLED',
              decode ((select count(*) from gv$propagation_receiver
                         where dst_queue_schema = xs.queue_owner and
                               dst_queue_name = xs.queue_name),
                      0, 'DETACHED', 'ATTACHED'), app.status),
   decode(bitand(xs.flags, 4), 4, 'NO', 0, 'YES')
   from sys.xstream$_server xs, dba_apply app
   where app.apply_name = xs.server_name and
         bitand(xs.flags, 2) = 2                      /* XStream In  process */
/
comment on table DBA_XSTREAM_INBOUND is
'Details about the XStream inbound server'
/
comment on column DBA_XSTREAM_INBOUND.SERVER_NAME is
'Name of the inbound server'
/
comment on column DBA_XSTREAM_INBOUND.QUEUE_OWNER is
'Owner of the queue associated with the inbound server'
/
comment on column DBA_XSTREAM_INBOUND.QUEUE_NAME is
'Name of the queue associated with the inbound server'
/
comment on column DBA_XSTREAM_INBOUND.APPLY_USER is
'Name of the user who is applying the messages'
/
comment on column DBA_XSTREAM_INBOUND.USER_COMMENT is
'User comment'
/
comment on column DBA_XSTREAM_INBOUND.CREATE_DATE is
'Date when inbound server was created'
/
comment on column DBA_XSTREAM_INBOUND.STATUS is
'Status of the apply process: DISABLED, ABORTED, DETACHED, ATTACHED'
/
comment on column DBA_XSTREAM_INBOUND.COMMITTED_DATA_ONLY is
'Is inbound server receiving committed data only?'
/
create or replace public synonym dba_xstream_inbound
  for dba_xstream_inbound
/
grant select on dba_xstream_inbound to select_catalog_role
/

create or replace view all_xstream_inbound
as select ib.*
from dba_xstream_inbound ib, all_apply a
   where a.apply_name = ib.server_name 
/
comment on table ALL_XSTREAM_INBOUND is
'Details about the XStream inbound server visible to user'
/
comment on column ALL_XSTREAM_INBOUND.SERVER_NAME is
'Name of the inbound server'
/
comment on column ALL_XSTREAM_INBOUND.QUEUE_OWNER is
'Owner of the queue associated with the inbound server'
/
comment on column ALL_XSTREAM_INBOUND.QUEUE_NAME is
'Name of the queue associated with the inbound server'
/
comment on column ALL_XSTREAM_INBOUND.APPLY_USER is
'Name of the user who is applying the messages'
/
comment on column ALL_XSTREAM_INBOUND.USER_COMMENT is
'User comment'
/
comment on column ALL_XSTREAM_INBOUND.CREATE_DATE is
'Date when inbound server was created'
/
comment on column ALL_XSTREAM_INBOUND.STATUS is
'Status of the apply process: DISABLED, ABORTED, ATTACHED, DETACHED'
/
comment on column ALL_XSTREAM_INBOUND.COMMITTED_DATA_ONLY is
'Is inbound server receiving committed data only?'
/
create or replace public synonym all_xstream_inbound
  for all_xstream_inbound
/
grant select on all_xstream_inbound to select_catalog_role
/

create or replace view dba_xstream_inbound_progress
  (server_name, processed_low_position,
   applied_low_position, applied_high_position, spill_position,
   oldest_position, oldest_message_number, applied_message_number,
   applied_time, applied_message_create_time,
   spill_message_number, source_database)
as select xs.server_name,
          case
          when (nvl(am.spill_lwm_position, '00') <
                                             nvl(am.lwm_external_pos, '00'))
            then am.lwm_external_pos
          else am.spill_lwm_position
          end,
          am.lwm_external_pos, am.applied_high_position,
          am.spill_lwm_position, am.oldest_position,
          am.oldest_scn, am.commit_scn,
          am.apply_time, am.applied_message_create_time,
          am.spill_lwm_scn, am.source_db_name
from  sys.xstream$_server xs, streams$_apply_process ap,
      "_DBA_APPLY_MILESTONE" am
 where ap.apply# = am.apply#
   and ap.apply_name = xs.server_name
   and bitand(xs.flags, 2) = 2                        /* XStream In  process */
/

comment on column DBA_XSTREAM_INBOUND_PROGRESS.SERVER_NAME is
'Name of the outbound server'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.PROCESSED_LOW_POSITION is
'Position of processed low transaction'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.APPLIED_LOW_POSITION is
'All messages with commit position less than this value have been applied'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.APPLIED_HIGH_POSITION is
'Highest commit position of a transaction that has been applied'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.SPILL_POSITION is
'Position of the spill low watermark'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.OLDEST_POSITION is
'Earliest position of the transactions currently being applied'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.OLDEST_MESSAGE_NUMBER is
'Earliest message number of the transactions currently being applied'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.APPLIED_MESSAGE_NUMBER is
'All messages below this number have been successfully applied'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.APPLIED_TIME is
'Time at which the APPLIED_MESSAGE_NUMBER message was applied'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.APPLIED_MESSAGE_CREATE_TIME is
'Time at which the APPLIED_MESSAGE_NUMBER message was created'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.SPILL_MESSAGE_NUMBER is
'Spill low water mark SCN'
/
comment on column DBA_XSTREAM_INBOUND_PROGRESS.SOURCE_DATABASE is
'Database where the transaction originated'
/

create or replace public synonym dba_xstream_inbound_progress
  for dba_xstream_inbound_progress
/
grant select on dba_xstream_inbound_progress to select_catalog_role
/

create or replace view all_xstream_inbound_progress
as select xp.*
  from dba_xstream_inbound_progress xp, all_apply ap
    where ap.apply_name = xp.server_name;
comment on column ALL_XSTREAM_INBOUND_PROGRESS.SERVER_NAME is
'Name of the outbound server'
/ 
comment on column ALL_XSTREAM_INBOUND_PROGRESS.PROCESSED_LOW_POSITION is
'Position of processed low transaction'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.APPLIED_LOW_POSITION is
'All messages with commit position less than this value have been applied'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.APPLIED_HIGH_POSITION is
'Highest commit position of a transaction that has been applied'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.SPILL_POSITION is
'Position of the spill low watermark'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.OLDEST_POSITION is
'Earliest position of the transactions currently being applied'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.OLDEST_MESSAGE_NUMBER is
'Earliest message number of the transactions currently being applied'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.APPLIED_MESSAGE_NUMBER is
'All messages below this number have been successfully applied'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.APPLIED_TIME is
'Time at which the APPLIED_MESSAGE_NUMBER message was applied'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.APPLIED_MESSAGE_CREATE_TIME is
'Time at which the APPLIED_MESSAGE_NUMBER message was created'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.SPILL_MESSAGE_NUMBER is
'Spill low water mark SCN'
/
comment on column ALL_XSTREAM_INBOUND_PROGRESS.SOURCE_DATABASE is
'Database where the transaction originated'
/
create or replace public synonym all_xstream_inbound_progress
  for all_xstream_inbound_progress
/
grant select on all_xstream_inbound_progress to select_catalog_role
/

create or replace view dba_goldengate_inbound
  (replicat_name, server_name, apply_user, user_comment, 
   create_date, status)
as select substr(xs.user_comment, 1, instr(xs.user_comment, ' ') - 1),
   server_name, app.apply_user, user_comment, create_date, 
   decode(app.status, 'ENABLED',
              decode ((select count(*) from gv$propagation_receiver
                         where dst_queue_schema = xs.queue_owner and
                               dst_queue_name = xs.queue_name),
                      0, 'DETACHED', 'ATTACHED'), app.status) 
   from sys.xstream$_server xs, dba_apply app
   where app.apply_name = xs.server_name and
         app.purpose = 'GoldenGate Apply' and         /* GoldenGate */
         bitand(xs.flags, 2) = 2                      /* XStream In  process */
/
comment on table DBA_GOLDENGATE_INBOUND is
'Details about the XStream inbound server'
/
comment on column DBA_GOLDENGATE_INBOUND.SERVER_NAME is
'Name of the inbound server'
/
comment on column DBA_GOLDENGATE_INBOUND.APPLY_USER is
'Name of the user who is applying the messages'
/
comment on column DBA_GOLDENGATE_INBOUND.USER_COMMENT is
'User comment'
/
comment on column DBA_GOLDENGATE_INBOUND.CREATE_DATE is
'Date when inbound server was created'
/
comment on column DBA_GOLDENGATE_INBOUND.STATUS is
'Status of the apply process: DISABLED, ABORTED, DETACHED, ATTACHED'
/
create or replace public synonym dba_goldengate_inbound
  for dba_goldengate_inbound
/
grant select on dba_goldengate_inbound to select_catalog_role
/

create or replace view all_goldengate_inbound
as select ib.*
from dba_goldengate_inbound ib, all_apply a
   where a.apply_name = ib.server_name
/
comment on table ALL_GOLDENGATE_INBOUND is
'Details about the XStream inbound server visible to user'
/
comment on column ALL_GOLDENGATE_INBOUND.SERVER_NAME is
'Name of the inbound server'
/
comment on column ALL_GOLDENGATE_INBOUND.APPLY_USER is
'Name of the user who is applying the messages'
/
comment on column ALL_GOLDENGATE_INBOUND.USER_COMMENT is
'User comment'
/
comment on column ALL_GOLDENGATE_INBOUND.CREATE_DATE is
'Date when inbound server was created'
/
comment on column ALL_GOLDENGATE_INBOUND.STATUS is
'Status of the apply process: DISABLED, ABORTED, ATTACHED, DETACHED'
/
create or replace public synonym all_goldengate_inbound
  for all_goldengate_inbound
/
grant select on all_goldengate_inbound to select_catalog_role
/

create or replace view dba_gg_inbound_progress
  (server_name, processed_low_position,
   applied_low_position, applied_high_position, spill_position,
   oldest_position, applied_low_scn,
   applied_time, applied_message_create_time,
   source_database, logbsn)
as select xs.server_name,
          case
          when (nvl(am.spill_lwm_position, '00') <
                                             nvl(am.lwm_external_pos, '00'))
            then utl_raw.cast_to_varchar2(am.lwm_external_pos)
          else utl_raw.cast_to_varchar2(am.spill_lwm_position)
          end,
          utl_raw.cast_to_varchar2(am.lwm_external_pos),
          utl_raw.cast_to_varchar2(am.applied_high_position),
          utl_raw.cast_to_varchar2(am.spill_lwm_position),
          utl_raw.cast_to_varchar2(am.oldest_position),
          am.commit_scn,
          am.apply_time, am.applied_message_create_time,
          am.source_db_name,
          utl_raw.cast_to_varchar2(am.spare5)
from  sys.xstream$_server xs, streams$_apply_process ap,
      "_DBA_APPLY_MILESTONE" am
 where ap.apply# = am.apply#
   and ap.apply_name = xs.server_name
   and bitand(ap.flags, 16384) = 16384                /* GoldenGate */
   and bitand(xs.flags, 2) = 2                        /* XStream In  process */
/

comment on column DBA_GG_INBOUND_PROGRESS.SERVER_NAME is
'Name of the outbound server'
/
comment on column DBA_GG_INBOUND_PROGRESS.PROCESSED_LOW_POSITION is
'Position of processed low transaction'
/
comment on column DBA_GG_INBOUND_PROGRESS.APPLIED_LOW_POSITION is
'All messages with commit position less than this value have been applied'
/
comment on column DBA_GG_INBOUND_PROGRESS.APPLIED_HIGH_POSITION is
'Highest commit position of a transaction that has been applied'
/
comment on column DBA_GG_INBOUND_PROGRESS.SPILL_POSITION is
'Position of the spill low watermark'
/
comment on column DBA_GG_INBOUND_PROGRESS.OLDEST_POSITION is
'Earliest position of the transactions currently being applied'
/
comment on column DBA_GG_INBOUND_PROGRESS.APPLIED_LOW_SCN is
'All SCN below this number have been successfully applied'
/
comment on column DBA_GG_INBOUND_PROGRESS.APPLIED_TIME is
'Time at which the APPLIED_MESSAGE_NUMBER message was applied'
/
comment on column DBA_GG_INBOUND_PROGRESS.APPLIED_MESSAGE_CREATE_TIME is
'Time at which the APPLIED_MESSAGE_NUMBER message was created'
/
comment on column DBA_GG_INBOUND_PROGRESS.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column DBA_GG_INBOUND_PROGRESS.LOGBSN is
'Log BSN value from the GoldenGate trail file'
/

create or replace public synonym dba_gg_inbound_progress
  for dba_gg_inbound_progress
/
grant select on dba_gg_inbound_progress to select_catalog_role
/

create or replace view all_gg_inbound_progress
as select xp.*
  from dba_gg_inbound_progress xp, all_apply ap
    where ap.apply_name = xp.server_name;
comment on column ALL_GG_INBOUND_PROGRESS.SERVER_NAME is
'Name of the outbound server'
/
comment on column ALL_GG_INBOUND_PROGRESS.PROCESSED_LOW_POSITION is
'Position of processed low transaction'
/
comment on column ALL_GG_INBOUND_PROGRESS.APPLIED_LOW_POSITION is
'All messages with commit position less than this value have been applied'
/
comment on column ALL_GG_INBOUND_PROGRESS.APPLIED_HIGH_POSITION is
'Highest commit position of a transaction that has been applied'
/
comment on column ALL_GG_INBOUND_PROGRESS.SPILL_POSITION is
'Position of the spill low watermark'
/
comment on column ALL_GG_INBOUND_PROGRESS.OLDEST_POSITION is
'Earliest position of the transactions currently being applied'
/
comment on column ALL_GG_INBOUND_PROGRESS.APPLIED_LOW_SCN is
'All SCN below this number have been successfully applied'
/
comment on column ALL_GG_INBOUND_PROGRESS.APPLIED_TIME is
'Time at which the APPLIED_MESSAGE_NUMBER message was applied'
/
comment on column ALL_GG_INBOUND_PROGRESS.APPLIED_MESSAGE_CREATE_TIME is
'Time at which the APPLIED_MESSAGE_NUMBER message was created'
/
comment on column ALL_GG_INBOUND_PROGRESS.SOURCE_DATABASE is
'Database where the transaction originated'
/
comment on column ALL_GG_INBOUND_PROGRESS.LOGBSN is
'Log BSN value from the GoldenGate trail file'
/
create or replace public synonym all_gg_inbound_progress
  for all_gg_inbound_progress
/
grant select on all_gg_inbound_progress to select_catalog_role
/

create or replace view "_DBA_XSTREAM_OUTBOUND"
as select
  ob.server_name outbound_server, ob.committed_data_only,
  cp.capture_name, cp.status capture_status,
  cp.first_scn, cp.captured_scn, cp.last_enqueued_scn,
  cp.source_database, cp.rule_set_owner capture_ruleset_owner,
  cp.rule_set_name capture_ruleset_name,
  cp.negative_rule_set_owner capture_neg_ruleset_owner, 
  cp.negative_rule_set_name capture_neg_ruleset_name, ob.capture_user,
  cp.queue_owner capture_queue_owner, cp.queue_name capture_queue_name,
  ob.status outbound_server_status, ob.connect_user, 
  nvl(xc.rule_set_owner, app.ruleset_owner) outbound_ruleset_owner, 
  nvl(xc.rule_set_name, app.ruleset_name) outbound_ruleset_name, 
  nvl(xc.negative_rule_set_owner, app.negative_ruleset_owner) 
    outbound_neg_ruleset_owner, 
  nvl(xc.negative_rule_set_name, app.negative_ruleset_name)
     outbound_neg_ruleset_name, cp2.spare5 oldest_scn, 
  cp.applied_scn, 
  app.spare1, app.spare2, app.spare3
from dba_xstream_outbound ob, dba_capture cp, sys."_DBA_APPLY" app, 
  sys.xstream$_server_connection xc, sys."_DBA_CAPTURE" cp2 where
  ob.server_name = app.apply_name and
  ob.capture_name = cp.capture_name (+) and
  cp.capture_name = cp2.capture_name and
  ob.server_name = xc.outbound_server (+)
/
grant select on "_DBA_XSTREAM_OUTBOUND" to exp_full_database
/

create or replace view "_DBA_XSTREAM_CONNECTION"
as select 
  xs.server_name outbound_server, xs.cap_src_database outbound_source_db, 
  c.inbound_server, c.inbound_server_dblink,
  c.outbound_queue_owner, c.outbound_queue_name, c.inbound_queue_owner,
  c.inbound_queue_name, c.rule_set_owner, c.rule_set_name,
  c.negative_rule_set_owner, c.negative_rule_set_name, c.flags, c.status,
  c.create_date, c.error_message, c.error_date, c.acked_scn
from sys.xstream$_server_connection c, sys.xstream$_server xs where 
  c.outbound_server = xs.server_name 
/
grant select on "_DBA_XSTREAM_CONNECTION" to exp_full_database
/

create or replace view "_DBA_STREAMS_STMT_HANDLERS"
(HANDLER_NAME, HANDLER_COMMENT, CREATION_TIME, MODIFICATION_TIME)
AS 
  select handler_name, handler_comment, creation_time, modification_time
  from sys.streams$_stmt_handlers
/

create or replace view DBA_STREAMS_STMT_HANDLERS
(HANDLER_NAME, HANDLER_COMMENT, CREATION_TIME, MODIFICATION_TIME)
as 
  select handler_name, handler_comment, creation_time, modification_time
  from "_DBA_STREAMS_STMT_HANDLERS"
/

comment on column DBA_STREAMS_STMT_HANDLERS.HANDLER_NAME is
'Name of the stmt handler'
/
comment on column DBA_STREAMS_STMT_HANDLERS.HANDLER_COMMENT is
'Comment of the stmt handler'
/
comment on column DBA_STREAMS_STMT_HANDLERS.CREATION_TIME is
'timestamp for script creation'
/
comment on column DBA_STREAMS_STMT_HANDLERS.MODIFICATION_TIME is
'timestamp for script modification'
/
create or replace public synonym DBA_STREAMS_STMT_HANDLERS
  for DBA_STREAMS_STMT_HANDLERS
/
grant select on DBA_STREAMS_STMT_HANDLERS to select_catalog_role
/

create or replace view "_DBA_STREAMS_STMTS"
(HANDLER_NAME, EXECUTION_SEQUENCE,
 STATEMENT, CREATION_TIME, MODIFICATION_TIME)
AS 
  select H.handler_name, S.execution_sequence,
         S.statement, S.creation_time, S.modification_time
  from sys.streams$_stmt_handler_stmts S, sys.streams$_stmt_handlers H
  where S.handler_id = H.handler_id
/

grant select on "_DBA_STREAMS_STMTS" to exp_full_database
/

create or replace view DBA_STREAMS_STMTS
(HANDLER_NAME, EXECUTION_SEQUENCE,
 STATEMENT, CREATION_TIME, MODIFICATION_TIME)
as 
  select handler_name, execution_sequence,
         statement, creation_time, modification_time
  from "_DBA_STREAMS_STMTS"
/

comment on column DBA_STREAMS_STMTS.HANDLER_NAME is
'Name of the stmt handler'
/
comment on column DBA_STREAMS_STMTS.EXECUTION_SEQUENCE is
'Execution sequence of the statement'
/
comment on column DBA_STREAMS_STMTS.STATEMENT is
'text of the statement'
/
comment on column DBA_STREAMS_STMTS.CREATION_TIME is
'timestamp for statement creation'
/
comment on column DBA_STREAMS_STMTS.MODIFICATION_TIME is
'timestamp for statement modification'
/
create or replace public synonym DBA_STREAMS_STMTS 
  for DBA_STREAMS_STMTS
/
grant select on DBA_STREAMS_STMTS to select_catalog_role
/

create or replace view "_DBA_APPLY_CHANGE_HANDLERS"
(CHANGE_TABLE_OWNER, CHANGE_TABLE_NAME, SOURCE_TABLE_OWNER, SOURCE_TABLE_NAME,
 HANDLER_NAME, CAPTURE_VALUES, APPLY_NAME, OPERATION_NAME, CREATION_TIME,
 MODIFICATION_TIME)
as 
  select change_table_owner, change_table_name, source_table_owner,
         source_table_name, handler_name, capture_values,
         apply_name, operation, creation_time, modification_time
  from   apply$_change_handlers
/
grant select on "_DBA_APPLY_CHANGE_HANDLERS" to exp_full_database
/

create or replace view DBA_APPLY_CHANGE_HANDLERS
(CHANGE_TABLE_OWNER, CHANGE_TABLE_NAME, SOURCE_TABLE_OWNER, SOURCE_TABLE_NAME,
 HANDLER_NAME, CAPTURE_VALUES, APPLY_NAME, OPERATION_NAME,  CREATION_TIME,
 MODIFICATION_TIME)
as
  select c.change_table_owner, c.change_table_name, c.source_table_owner,
         c.source_table_name, c.handler_name, 
         decode(c.capture_values, 1, 'OLD',
                                  2, 'NEW',
                                  3, '*'),
         c.apply_name,
         decode(c.operation_name, 0, 'DEFAULT',
                                  1, 'INSERT',
                                  2, 'UPDATE',
                                  3, 'DELETE',
                                  4, 'LOB_UPDATE'),
         c.creation_time, c.modification_time
  from "_DBA_APPLY_CHANGE_HANDLERS" c, dba_apply a
  where a.apply_name = c.apply_name
/

comment on table DBA_APPLY_CHANGE_HANDLERS is
'Details about apply change handler'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.CHANGE_TABLE_OWNER is
'Owner of change table'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.CHANGE_TABLE_NAME is
'Name of change table'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.SOURCE_TABLE_OWNER is
'Owner of source table'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.SOURCE_TABLE_NAME is
'Name of source table'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.HANDLER_NAME is
'Name of statement-based change handler'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.CAPTURE_VALUES is
'Type of value to capture'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.APPLY_NAME is
'Name of apply process'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.OPERATION_NAME is
'Name of DML operation to which the DML handler is set'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.CREATION_TIME is
'Chang handler creation time'
/
comment on column DBA_APPLY_CHANGE_HANDLERS.MODIFICATION_TIME is
'Chang handler modification time'
/
create or replace public synonym DBA_APPLY_CHANGE_HANDLERS 
  for DBA_APPLY_CHANGE_HANDLERS
/
grant select on DBA_APPLY_CHANGE_HANDLERS to select_catalog_role
/

create or replace view ALL_APPLY_CHANGE_HANDLERS
as
  select c.*
  from DBA_APPLY_CHANGE_HANDLERS c, all_apply a
  where c.apply_name = a.apply_name
/
comment on table ALL_APPLY_CHANGE_HANDLERS is
'Details about apply change handler'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.CHANGE_TABLE_OWNER is
'Owner of change table'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.CHANGE_TABLE_NAME is
'Name of change table'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.SOURCE_TABLE_OWNER is
'Owner of source table'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.SOURCE_TABLE_NAME is
'Name of source table'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.HANDLER_NAME is
'Name of statement-based change handler'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.CAPTURE_VALUES is
'Type of value to capture'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.APPLY_NAME is
'Name of apply process'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.OPERATION_NAME is
'Name of DML operation to which the DML handler is set'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.CREATION_TIME is
'Chang handler creation time'
/
comment on column ALL_APPLY_CHANGE_HANDLERS.MODIFICATION_TIME is
'Chang handler modification time'
/
create or replace public synonym ALL_APPLY_CHANGE_HANDLERS 
  for ALL_APPLY_CHANGE_HANDLERS
/
grant select on ALL_APPLY_CHANGE_HANDLERS to select_catalog_role
/

-- Private view select to all columns from xstreams$_parameters.
create or replace view "_DBA_XSTREAM_PARAMETERS"
as 
  select server_name, server_type, position, param_key, schema_name, 
         object_name, user_name, creation_time, modification_time, 
         flags, details, spare1, spare2, spare3, spare4, spare5,
         spare6, spare7, spare8, spare9
  from sys.xstream$_parameters
/
grant select on "_DBA_XSTREAM_PARAMETERS" to exp_full_database
/

create or replace view "_DBA_APPLY_DML_CONF_HANDLERS"
as select
  apply_name, conflict_handler_name, schema_name, object_name, old_schema,
  old_object, conflict_type,opnum, method_num, resolution_column,
  conflict_handler_id, set_by
from sys.xstream$_dml_conflict_handler
/
grant select on "_DBA_APPLY_DML_CONF_HANDLERS" to exp_full_database
/

create or replace view DBA_APPLY_DML_CONF_HANDLERS
  (apply_name, object_owner, object_name, source_object_owner,
   source_object_name, command_type, conflict_type, method_name,
   conflict_handler_name, resolution_column, set_by)
as
select
  apply_name, schema_name, object_name, old_schema, old_object,
  decode(opnum, 1, 'INSERT',
                2, 'UPDATE',
                3, 'DELETE'),
  decode(conflict_type, 1, 'ROW_EXISTS',
                        2, 'ROW_MISSING'),
  decode(method_num, 1, 'IGNORE',
                     2, 'RECORD',
                     3, 'DELTA',
                     4, 'OVERWRITE',
                     5, 'MAXIMUM',
                     6, 'MINIMUM'),
  conflict_handler_name, resolution_column,
  decode(set_by,  NULL,'USER',
                     1,'GOLDENGATE')
from sys."_DBA_APPLY_DML_CONF_HANDLERS"
/

comment on table DBA_APPLY_DML_CONF_HANDLERS is
'Details about DML conflict handlers'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.apply_name is
'Name of the apply process'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.object_owner is
'Owner of the target object'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.object_name is
'Name of the target object'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.source_object_owner is
'Owner of the source object'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.source_object_name is
'Name of the source object'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.command_type is
'Type of the DML operation'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.conflict_type is
'Description of the conflict'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.method_name is
'Description of the conflict handling method'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.conflict_handler_name is
'Name of the conflict handler'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.resolution_column is
'Name of the resolution column'
/
comment on column DBA_APPLY_DML_CONF_HANDLERS.set_by is
'Entity that set up the handler: USER, GOLDENGATE'
/
create or replace public synonym DBA_APPLY_DML_CONF_HANDLERS
  for DBA_APPLY_DML_CONF_HANDLERS
/
grant select on DBA_APPLY_DML_CONF_HANDLERS to select_catalog_role
/


create or replace view ALL_APPLY_DML_CONF_HANDLERS
as select h.*
from all_tables o, all_apply a, DBA_APPLY_DML_CONF_HANDLERS h
where h.object_owner = o.owner and h.object_name = o.table_name and
      a.apply_name = h.apply_name
/

comment on table ALL_APPLY_DML_CONF_HANDLERS is
'Details about dml conflict handlers on objects visible to the current user'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.apply_name is
'Name of the apply process'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.object_owner is
'Owner of the target object'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.object_name is
'Name of the target object'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.source_object_owner is
'Owner of the source object'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.source_object_name is
'Name of the source object'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.command_type is
'Type of the DML operation'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.conflict_type is
'Description of the conflict'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.method_name is
'Description of the conflict handling method'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.conflict_handler_name is
'Name of the conflict handler'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.resolution_column is
'Name of the resolution column'
/
comment on column ALL_APPLY_DML_CONF_HANDLERS.set_by is
'Entity that set up the handler: USER, GOLDENGATE'
/

create or replace public synonym ALL_APPLY_DML_CONF_HANDLERS
  for ALL_APPLY_DML_CONF_HANDLERS
/
grant select on ALL_APPLY_DML_CONF_HANDLERS to public with grant option
/

create or replace view "_DBA_APPLY_DML_CONF_COLUMNS"
as select
  conflict_handler_id, column_name
from sys.xstream$_dml_conflict_columns
/
grant select on "_DBA_APPLY_DML_CONF_COLUMNS" to exp_full_database
/

create or replace view DBA_APPLY_DML_CONF_COLUMNS
  (apply_name, conflict_handler_name, column_name)
as
select
  h.apply_name, h.conflict_handler_name, c.column_name
from sys."_DBA_APPLY_DML_CONF_COLUMNS" c, sys."_DBA_APPLY_DML_CONF_HANDLERS" h
where c.conflict_handler_id = h.conflict_handler_id
/

comment on table DBA_APPLY_DML_CONF_COLUMNS is
'Details about DML conflict handler column groups'
/
comment on column DBA_APPLY_DML_CONF_COLUMNS.apply_name is
'Name of the apply process'
/
comment on column DBA_APPLY_DML_CONF_COLUMNS.conflict_handler_name is
'Name of the conflict handler'
/
comment on column DBA_APPLY_DML_CONF_COLUMNS.column_name is
'Name of the column'
/

create or replace public synonym DBA_APPLY_DML_CONF_COLUMNS
  for DBA_APPLY_DML_CONF_COLUMNS
/
grant select on DBA_APPLY_DML_CONF_COLUMNS to select_catalog_role
/

create or replace view ALL_APPLY_DML_CONF_COLUMNS
as select c.*
from ALL_APPLY_DML_CONF_HANDLERS h, DBA_APPLY_DML_CONF_COLUMNS c
where c.apply_name = h.apply_name
      and c.conflict_handler_name = h.conflict_handler_name
/

comment on table ALL_APPLY_DML_CONF_COLUMNS is
'Details about dml conflict handler column groups on objects visible to the current user'
/
comment on column ALL_APPLY_DML_CONF_COLUMNS.apply_name is
'Name of the apply process'
/
comment on column ALL_APPLY_DML_CONF_COLUMNS.conflict_handler_name is
'Name of the conflict handler'
/
comment on column ALL_APPLY_DML_CONF_COLUMNS.column_name is
'Name of the column'
/

create or replace public synonym ALL_APPLY_DML_CONF_COLUMNS
  for ALL_APPLY_DML_CONF_COLUMNS
/
grant select on ALL_APPLY_DML_CONF_COLUMNS to public with grant option
/

create or replace view "_DBA_APPLY_HANDLE_COLLISIONS"
as select
  apply_name, schema_name, table_name, source_schema_name, source_table_name,
  handle_collisions, set_by
from sys.xstream$_handle_collisions
/
grant select on "_DBA_APPLY_HANDLE_COLLISIONS" to exp_full_database
/

create or replace view DBA_APPLY_HANDLE_COLLISIONS
  (apply_name, object_owner, object_name, source_object_owner,
   source_object_name, enabled, set_by)
as
select
  apply_name, schema_name, table_name, source_schema_name, source_table_name,
  handle_collisions,
  decode(set_by, NULL,'USER',
                 1   ,'GOLDENGATE')
from sys."_DBA_APPLY_HANDLE_COLLISIONS"
/

comment on table DBA_APPLY_HANDLE_COLLISIONS is
'Details about apply collision handlers'
/
comment on column DBA_APPLY_HANDLE_COLLISIONS.apply_name is
'Name of the apply process'
/
comment on column DBA_APPLY_HANDLE_COLLISIONS.object_owner is
'Owner of the target object'
/
comment on column DBA_APPLY_HANDLE_COLLISIONS.object_name is
'Name of the target object'
/
comment on column DBA_APPLY_HANDLE_COLLISIONS.source_object_owner is
'Owner of the source object'
/
comment on column DBA_APPLY_HANDLE_COLLISIONS.source_object_name is
'Name of the source object'
/
comment on column DBA_APPLY_HANDLE_COLLISIONS.enabled is
'State of the collision handlers'
/
comment on column DBA_APPLY_HANDLE_COLLISIONS.set_by is
'Entity that set up the handler: USER, GOLDENGATE'
/
create or replace public synonym DBA_APPLY_HANDLE_COLLISIONS
  for DBA_APPLY_HANDLE_COLLISIONS
/
grant select on DBA_APPLY_HANDLE_COLLISIONS to select_catalog_role
/


create or replace view ALL_APPLY_HANDLE_COLLISIONS
as select hc.*
from DBA_APPLY_HANDLE_COLLISIONS hc, ALL_APPLY a, all_tables t
where hc.apply_name = a.apply_name and hc.object_owner = t.owner
      and hc.object_name = t.table_name
/

comment on table ALL_APPLY_HANDLE_COLLISIONS is
'Details about apply collision handlers on objects visible to the user'
/
comment on column ALL_APPLY_HANDLE_COLLISIONS.apply_name is
'Name of the apply process'
/
comment on column ALL_APPLY_HANDLE_COLLISIONS.object_owner is
'Owner of the target object'
/
comment on column ALL_APPLY_HANDLE_COLLISIONS.object_name is
'Name of the target object'
/
comment on column ALL_APPLY_HANDLE_COLLISIONS.source_object_owner is
'Owner of the source object'
/
comment on column ALL_APPLY_HANDLE_COLLISIONS.source_object_name is
'Name of the source object'
/
comment on column ALL_APPLY_HANDLE_COLLISIONS.enabled is
'State of the collision handlers'
/
comment on column ALL_APPLY_HANDLE_COLLISIONS.set_by is
'Entity that set up the handler: USER, GOLDENGATE'
/

create or replace public synonym ALL_APPLY_HANDLE_COLLISIONS
  for ALL_APPLY_HANDLE_COLLISIONS
/
grant select on ALL_APPLY_HANDLE_COLLISIONS to public with grant option
/



create or replace view "_DBA_APPLY_REPERROR_HANDLERS"
as select
  apply_name, schema_name, table_name, source_schema_name, source_table_name,
  error_number, method, max_retries, delay_msecs, set_by
from sys.xstream$_reperror_handler
/
grant select on "_DBA_APPLY_REPERROR_HANDLERS" to exp_full_database
/

create or replace view DBA_APPLY_REPERROR_HANDLERS
  (apply_name, object_owner, object_name, source_object_owner,
   source_object_name, error_number, method, max_retries, delay_csecs, set_by)
as
select
  apply_name, schema_name, table_name, source_schema_name, source_table_name,
  error_number,
  decode(method, 1, 'ABEND',
                 2, 'RECORD',
                 3, 'RECORD TRANSACTION',
                 4, 'IGNORE',
                 5, 'RETRY',
                 6, 'RETRY TRANSACTION'),
  max_retries, delay_msecs/10,
  decode(set_by, NULL,'USER',
                    1,'GOLDENGATE')
from sys."_DBA_APPLY_REPERROR_HANDLERS"
/

comment on table DBA_APPLY_REPERROR_HANDLERS is
'Details about apply reperror handlers'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.apply_name is
'Name of the apply process'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.object_owner is
'Owner of the target object'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.object_name is
'Name of the target object'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.source_object_owner is
'Owner of the source object'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.source_object_name is
'Name of the source object'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.error_number is
'Error number for the handler'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.method is
'Error handling method'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.max_retries is
'Number of times to retry'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.delay_csecs is
'Centiseconds to wait between retries'
/
comment on column DBA_APPLY_REPERROR_HANDLERS.set_by is
'Entity that set up the handler: USER, GOLDENGATE'
/
create or replace public synonym DBA_APPLY_REPERROR_HANDLERS
  for DBA_APPLY_REPERROR_HANDLERS
/
grant select on DBA_APPLY_REPERROR_HANDLERS to select_catalog_role
/

create or replace view ALL_APPLY_REPERROR_HANDLERS
as select rh.*
from DBA_APPLY_REPERROR_HANDLERS rh, ALL_APPLY a, all_tables t
where rh.apply_name = a.apply_name and rh.object_owner = t.owner
      and rh.object_name = t.table_name
/

comment on table ALL_APPLY_REPERROR_HANDLERS is
'Details about apply reperror handlers on objects visible to the user'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.apply_name is
'Name of the apply process'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.object_owner is
'Owner of the target object'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.object_name is
'Name of the target object'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.source_object_owner is
'Owner of the source object'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.source_object_name is
'Name of the source object'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.error_number is
'Error number for the handler'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.method is
'Error handling method'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.max_retries is
'Number of times to retry'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.delay_csecs is
'Centiseconds to wait between retries'
/
comment on column ALL_APPLY_REPERROR_HANDLERS.set_by is
'Entity that set up the handler: USER, GOLDENGATE'
/

create or replace public synonym ALL_APPLY_REPERROR_HANDLERS
  for ALL_APPLY_REPERROR_HANDLERS
/
grant select on ALL_APPLY_REPERROR_HANDLERS to public with grant option
/
