rem 
rem $Header: rdbms/admin/catdefrt.sql /main/27 2009/03/31 09:20:27 juyuan Exp $ 
rem 
Rem Copyright (c) 1992, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      catdefrt.sql - CATalog DEFeRred rpc Tables
Rem    DESCRIPTION
Rem      create deferred rpc tables
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This is called from catdefer.sql
Rem    MODIFIED   (MM/DD/YY)
Rem     juyuan     03/19/09  - drop temp$lob
Rem     elu        11/03/06  - modify for parallel upgrade
Rem     rburns     07/27/06  - separate queues 
Rem     ksurlake   01/29/02  - Dont create queues if already exist
Rem     rburns     10/28/01  - wrap drops/created to remove errors
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     arithikr   12/13/00  - 1489592: expect ORA-955 for defaultdest
Rem     bnainani   11/29/00  - specify compatible=8.0 for create_queue_table
Rem     liwong     10/20/00  - add def$_destination.flag
Rem     bnainani   11/15/00  - specify compatible=8.0 for queue table
Rem     narora     09/13/00  - add comment on new def$_destination columns
Rem     liwong     09/01/00  - add master w/o quiesce: fixes
Rem     liwong     07/12/00  - add total_prop_time_lat
Rem     liwong     06/29/00  - add total_txn_count, total_prop_time
Rem     liwong     05/17/00  - add_master_db w/o quiesce
Rem     jstamos    05/17/00  - add_master_db w/o quiesce
Rem     elu        01/24/00  - add column apply_init to def$_destination
Rem     alakshmi   12/02/99  - Bug 979398: Before-row insert trigger on 
Rem                            def$_propagator
Rem     wesmith    10/31/98 -  change shape of table def$_pushed_transactions  
Rem     jnath      02/23/98 -  bug 601972: split anonymous pl/sql blocks
Rem     wesmith    01/21/98 -  create def$_pushed_transactions table for 
Rem                            server-side RepAPI
Rem     nbhatt     07/27/97 -  change create_queuetable -> create_queue_table
Rem     nbhatt     04/21/97 -  change 'TRACKING' in CREATE_QUEUE to 'DEPENDENCY
Rem     nbhatt     04/21/97 -  change syntax of create_queue
Rem     liwong     04/16/97 -  Alter view system.AQ$DEF$_AQ{CALL,ERROR}
Rem     liwong     04/11/97 -  Fixing defaultdest_primary typo
Rem     jstamos    04/10/97 -  remove unneeded indexes
Rem     nbhatt     04/08/97 -  change create_qtable to create_queuetable
Rem     jstamos    04/04/97 -  tighter AQ integration
Rem     liwong     04/02/97 -  Add schema_name, package_name in def$_calldest
Rem     ato        03/31/97 -  create_qtable interface change
Rem     liwong     03/25/97 -  remove batch_no from def$_tranorder
Rem     liwong     02/24/97 -  pctversion --> 0 for def$_aqcall, def$_aqerror
Rem     liwong     02/22/97 -  Remove dropping view aq$def$_aqcall
Rem     ademers    02/07/97 -  Remove constraint def$_calldest_call
Rem     liwong     01/11/97 -  drop and create aq$def$_aqcall (temporary)
Rem     liwong     01/10/97 -  Alter view aq$def$_aqcall
Rem     liwong     01/07/97 -  Alter default value for batch_no
Rem     jstamos    12/23/96 -  change temp$nclob col
Rem     jstamos    11/21/96 -  nchar support
Rem     sjain      11/11/96 -  Remove dummy buffer # comment
Rem     asgoel     11/05/96 -  Disable misc_tracking in def$_aqerror
Rem     sjain      11/06/96 -  deferror changes
Rem     vkrishna   10/28/96 -  change STORED IN to STORE AS for lob
Rem     sjain      10/02/96 -  Aq conversion
Rem     sbalaram   09/24/96 -  ARPC performance - add foreign key index
Rem     jstamos    09/06/96 -  rename temp$lob and temporarily change nclob
Rem     sjain      09/03/96 -  AQ converson
Rem     ademers    08/02/96 -  queue_batch default in def_destination
Rem     ademers    07/29/96 -  queue_batch default in def_call
Rem     ademers    07/29/96 -  queue_batch default
Rem     jstamos    07/24/96 -  add system.temp$lob
Rem     sbalaram   07/22/96 -  create def$_aqcall and def$_aqerror tables
Rem     jstamos    06/12/96 -  LOB support for deferred RPCs
Rem     ldoo       06/28/96 -  Comment out queue_table from def_tranorder
Rem     ademers    05/30/96 -  create def_origin
Rem     ademers    05/28/96 -  fix def_destination col names
Rem     ldoo       05/09/96 -  New security model
Rem     sjain      05/01/96 -  add seq col to def_destination
Rem     ademers    04/29/96 -  add batch_no, dep_scn to def_call
Rem     jstamos    12/04/95 -  324303: use index to avoid sorting the queue
Rem     jstamos    08/17/95 -  code review changes
Rem     jstamos    08/16/95 -  add comments to tables
Rem     wmaimone   01/04/96 -  7.3 merge
Rem     hasun      01/31/95 -  Modify tables for Rep3 - Object Groups
Rem     hasun      01/31/95 -  merge changes from branch 1.1.720.2
Rem     hasun      01/11/95 -  Add fix to resolve duplicate SCNs
Rem     dsdaniel   12/08/94 -  add def _destinaton constraint
Rem     dsdaniel   12/08/94 -  name defcall primary
Rem     dsdaniel   11/25/94 -  eliminate deftrandest, ect
Rem     dsdaniel   11/25/94 -  Branch_for_patch
Rem     dsdaniel   11/22/94 -  Creation

-- Sys is granted privileges through roles, which don't apply to
-- packages owned by sys.  Explicitly grant permissions.
grant select any table to sys with admin option
/
grant insert any table to sys
/
grant update any table to sys
/
grant delete any table to sys
/
grant analyze any to sys
/
rem drop existing synonyms from sys -system

DROP SYNONYM def$_tran
/
DROP SYNONYM def$_call
/
DROP SYNONYM def$_defaultdest
/

--  create the table where the exceptions get logged. One row for each
--  transactionXorigin_node when the execution of the transaction at 
--  this  node encountered  an error.  The transaction is always re-executed
--  in the security context of the original receiver.
CREATE TABLE system.def$_error(
  enq_tid          VARCHAR2(22),   -- Tid of error creation txn
     CONSTRAINT def$_error_primary
        PRIMARY KEY(enq_tid),
  origin_tran_db   VARCHAR2(128),  -- node which originated this txn
  origin_enq_tid   VARCHAR2(22),   -- original tid of the txn
  destination      VARCHAR2(128),  -- dblink transaction destined to
  step_no          NUMBER,         -- UID of call
  receiver         NUMBER,         -- User ID of the original receiver
  enq_time         DATE,           -- time at which transaction enqueued
  error_number     NUMBER,         -- error number reported
  error_msg        VARCHAR2(2000)) -- error message
/

comment on table SYSTEM.DEF$_ERROR is
'Information about all deferred transactions that caused an error'
/
comment on column SYSTEM.DEF$_ERROR.ENQ_TID is
'The ID of the transaction that created the error'
/
comment on column SYSTEM.DEF$_ERROR.ORIGIN_TRAN_DB is
'The database originating the deferred transaction'
/
comment on column SYSTEM.DEF$_ERROR.ORIGIN_ENQ_TID is
'The original ID of the transaction'
/
comment on column SYSTEM.DEF$_ERROR.DESTINATION is
'Database link used to address destination'
/
comment on column SYSTEM.DEF$_ERROR.STEP_NO is
'Unique ID of call that caused an error'
/
comment on column SYSTEM.DEF$_ERROR.RECEIVER is
'User ID of the original receiver'
/
comment on column SYSTEM.DEF$_ERROR.ENQ_TIME is
'Time original transaction enqueued'
/
comment on column SYSTEM.DEF$_ERROR.ERROR_NUMBER is
'Oracle error number'
/
comment on column SYSTEM.DEF$_ERROR.ERROR_MSG is
'Error message text'
/


CREATE TABLE system.def$_destination(
  dblink             VARCHAR2(128), -- queue name
  last_delivered     NUMBER         -- scn(from deliver_order column of 
                                    -- def$_call)
                         DEFAULT 0 NOT NULL,
  last_enq_tid       VARCHAR2(22),   -- transaction id last delivered
  last_seq           NUMBER,         -- last delivered txn seq, 0 on clean 
                                     -- termination
  disabled           CHAR(1),        -- T = propogation to dest disabled 
                                     -- F = enabled 
  job                NUMBER,         -- number of job which does the push
  last_txn_count     NUMBER,         -- number of transactions executed last
                                     -- push
  last_error_number  NUMBER,         -- sqlcode from last push
  last_error_message VARCHAR2(2000), -- error message from last push
  apply_init         VARCHAR2(4000),-- Reserved for internal use only
  catchup            RAW(16) DEFAULT '00',   -- used to break transactions
  alternate          CHAR(1) DEFAULT 'F',    -- used to break transactions
                                     -- T = break transactions
                                     -- F = propagate lower link only
  total_txn_count    NUMBER DEFAULT 0,   -- total txn propagated
  -- total time to propagate txns, for measuring throughput
  total_prop_time_throughput       NUMBER DEFAULT 0,
  -- total time to propagate txns, for measuring latency
  total_prop_time_latency          NUMBER DEFAULT 0,
  to_communication_size            NUMBER DEFAULT 0, -- # of bytes sent to
  from_communication_size          NUMBER DEFAULT 0, -- # of bytes recved from
  flag                             RAW(4) default '00000000',
  spare1                           NUMBER DEFAULT 0, -- # of round trips
  spare2                           NUMBER DEFAULT 0, -- # of admin requests
  spare3                           NUMBER DEFAULT 0, -- # of error txns
  spare4                           NUMBER DEFAULT 0, -- total sleep time
        CONSTRAINT def$_destination_primary PRIMARY KEY(dblink, catchup))
/

comment on table SYSTEM.DEF$_DESTINATION is
'Information about propagation to different destinations'
/
comment on column SYSTEM.DEF$_DESTINATION.DBLINK is
'Destination'
/
comment on column SYSTEM.DEF$_DESTINATION.LAST_DELIVERED is
'Value of delivery_order of last transaction propagated'
/
comment on column SYSTEM.DEF$_DESTINATION.LAST_ENQ_TID is
'Transaction ID of last transaction propagated'
/
comment on column SYSTEM.DEF$_DESTINATION.LAST_SEQ is
'Parallel prop seq number of last transaction propagated'
/
comment on column SYSTEM.DEF$_DESTINATION.DISABLED is
'Is propagation to destination disabled'
/
comment on column SYSTEM.DEF$_DESTINATION.JOB is
'Number of job that pushes queue'
/
comment on column SYSTEM.DEF$_DESTINATION.LAST_TXN_COUNT is
'Number of transactions pushed during last attempt'
/
comment on column SYSTEM.DEF$_DESTINATION.LAST_ERROR_NUMBER is
'Oracle error number from last push'
/
comment on column SYSTEM.DEF$_DESTINATION.LAST_ERROR_MESSAGE is
'Error message from last push'
/
comment on column SYSTEM.DEF$_DESTINATION.CATCHUP is
'Used to break transaction into pieces'
/
comment on column SYSTEM.DEF$_DESTINATION.ALTERNATE is
'Used to break transaction into pieces'
/
comment on column SYSTEM.DEF$_DESTINATION.TOTAL_TXN_COUNT is
'Total number of transactions pushed'
/
comment on column SYSTEM.DEF$_DESTINATION.TOTAL_PROP_TIME_THROUGHPUT is
'Total propagation time in seconds for measuring throughput'
/
comment on column SYSTEM.DEF$_DESTINATION.TOTAL_PROP_TIME_LATENCY is
'Total propagation time in seconds for measuring latency'
/
comment on column SYSTEM.DEF$_DESTINATION.to_communication_size is
'Total number of bytes sent to this dblink'
/
comment on column SYSTEM.DEF$_DESTINATION.from_communication_size is
'Total number of bytes received from this dblink'
/
comment on column SYSTEM.DEF$_DESTINATION.spare1 is
'Total number of round trips for this dblink'
/
comment on column SYSTEM.DEF$_DESTINATION.spare2 is
'Total number of administrative requests'
/
comment on column SYSTEM.DEF$_DESTINATION.spare3 is
'Total number of error transactions pushed'
/
comment on column SYSTEM.DEF$_DESTINATION.spare4 is
'Total time in seconds spent sleeping during push'
/

--  create the  table that identifies a call to be executed	
--  at a remote node. One row for each callsXnode when the 
--  destination_list is D
CREATE TABLE system.def$_calldest(
  enq_tid          VARCHAR2(22),  -- deferred transaction id
  step_no          NUMBER,        -- call id 
  dblink           VARCHAR2(128), -- dblink to destination
    CONSTRAINT def$_calldest_primary 
      PRIMARY KEY(enq_tid, dblink, step_no),
  schema_name      VARCHAR2(30),
  package_name     VARCHAR2(30),
  catchup          RAW(16) DEFAULT '00',
    CONSTRAINT def$_call_destination  -- Destination table must have a row
      FOREIGN KEY(dblink, catchup)
      REFERENCES system.def$_destination(dblink, catchup)
  )
/

comment on table SYSTEM.DEF$_CALLDEST is
'Information about call destinations for D-type and error transactions'
/
comment on column SYSTEM.DEF$_CALLDEST.ENQ_TID is
'Transaction ID'
/
comment on column SYSTEM.DEF$_CALLDEST.STEP_NO is
'Unique ID of call within transaction'
/
comment on column SYSTEM.DEF$_CALLDEST.DBLINK is
'The destination database'
/
comment on column SYSTEM.DEF$_CALLDEST.SCHEMA_NAME is
'The schema of the deferred remote procedure call'
/
comment on column SYSTEM.DEF$_CALLDEST.PACKAGE_NAME is
'The package of the deferred remote procedure call'
/
comment on column SYSTEM.DEF$_CALLDEST.CATCHUP is
'Dummy column for foreign key'
/

-- make inserting rows into def$_calldest faster
CREATE INDEX system.def$_calldest_n2 ON system.def$_calldest(
  dblink, catchup)
/

-- ORA-00955 is expected for table def$_defaultdest if this script is run
-- as part of the migration and the table was created in the previous release.
CREATE TABLE system.def$_defaultdest (
  dblink VARCHAR2(128)  -- dblink 
    CONSTRAINT def$_defaultdest_primary
    PRIMARY KEY)
/

comment on table SYSTEM.DEF$_DEFAULTDEST is
'Default destinations for deferred remote procedure calls'
/
comment on column SYSTEM.DEF$_DEFAULTDEST.DBLINK is
'Default destination'
/
COMMIT
/

CREATE TABLE system.def$_lob(
  id RAW(16) CONSTRAINT def$_lob_primary PRIMARY KEY,
  enq_tid    VARCHAR2(22), -- transaction id
  blob_col   BLOB, -- either BLOB, CLOB, or NCLOB is meaningful
  clob_col   CLOB,
  nclob_col  NCLOB)
  lob (blob_col, clob_col, nclob_col) store as (pctversion 0)
/

comment on table SYSTEM.DEF$_LOB is
'Storage for LOB parameters to deferred RPCs'
/
comment on column SYSTEM.DEF$_LOB.ID is
'Identifier of LOB parameter'
/
comment on column SYSTEM.DEF$_LOB.ENQ_TID is
'Transaction identifier for deferred RPC with this LOB parameter'
/
comment on column SYSTEM.DEF$_LOB.BLOB_COL is
'Binary LOB parameter'
/
comment on column SYSTEM.DEF$_LOB.CLOB_COL is
'Character LOB parameter'
/
comment on column SYSTEM.DEF$_LOB.NCLOB_COL is
'National Character LOB parameter'
/

-- make deletes fast
CREATE INDEX system.def$_lob_n1 ON system.def$_lob(
  enq_tid)
/

CREATE TABLE system.def$_propagator(
  userid        NUMBER           -- User ID of the propagator
    CONSTRAINT def$_propagator_primary PRIMARY KEY,
  username      VARCHAR2(30)     -- Name of the propagator
    NOT NULL,
  created       DATE             -- the time when the propagator is registered
    DEFAULT SYSDATE NOT NULL)
/

comment on table SYSTEM.DEF$_PROPAGATOR is
'The propagator for deferred remote procedure calls'
/
comment on column SYSTEM.DEF$_PROPAGATOR.USERID is
'User ID of the propagator'
/
comment on column SYSTEM.DEF$_PROPAGATOR.USERNAME is
'User name of the propagator'
/
comment on column SYSTEM.DEF$_PROPAGATOR.CREATED is
'The time when the propagator is registered'
/

rem create base tables

-- Create table of transactions that have been applied at destination site.
-- One row per applied transaction, committed with the transaction.
-- This allows us to stream deferred transactions w/o 2PC and still do
-- failure recovery.

CREATE TABLE system.def$_origin(
  origin_db      VARCHAR2(128),         -- global name of pushing site
  origin_dblink  VARCHAR2(128),        -- dblink: pushing site -> here
  inusr          NUMBER,                   -- receiving connected user
  -- data to identify committed txns during recovery:
  cscn           NUMBER,                    -- origin site prepare scn
  enq_tid        VARCHAR2(22),           -- origin site transaction id
  reco_seq_no    NUMBER,      -- transaction seq number when committed
  catchup        RAW(16) DEFAULT '00')     -- used to break transactions
/

comment on table SYSTEM.DEF$_ORIGIN is
'Information about deferred transactions pushed to this site'
/
comment on column SYSTEM.DEF$_ORIGIN.ORIGIN_DB is
'Originating database for the deferred transaction'
/
comment on column SYSTEM.DEF$_ORIGIN.ORIGIN_DBLINK is
'Database link from deferred transaction origin to this site'
/
comment on column SYSTEM.DEF$_ORIGIN.INUSR is
'Connected user receiving the deferred transaction'
/
comment on column SYSTEM.DEF$_ORIGIN.CSCN is
'Prepare SCN assigned at origin site'
/
comment on column SYSTEM.DEF$_ORIGIN.ENQ_TID is
'Transaction id assigned at origin site'
/
comment on column SYSTEM.DEF$_ORIGIN.RECO_SEQ_NO is
'Deferred transaction sequence number for recovery'
/
comment on column SYSTEM.DEF$_ORIGIN.CATCHUP is
'Used to break transaction into pieces'
/

CREATE TABLE system.def$_pushed_transactions
(
  source_site_id NUMBER,                                       -- sending site
    CONSTRAINT def$_pushed_tran_primary 
      PRIMARY KEY(source_site_id),
  last_tran_id   NUMBER DEFAULT 0,               -- last committed transaction
  disabled       VARCHAR2(1) DEFAULT 'F',               -- disable propagation
    CHECK (disabled IN ('T', 'F')),
  source_site    VARCHAR2(128)                                     -- OBSOLETE
)
/
comment on table SYSTEM.DEF$_PUSHED_TRANSACTIONS is
'Information about deferred transactions pushed to this site by RepAPI clients'
/
comment on column SYSTEM.DEF$_PUSHED_TRANSACTIONS.SOURCE_SITE_ID is
'Originating database identifier for the deferred transaction'
/
comment on column SYSTEM.DEF$_PUSHED_TRANSACTIONS.LAST_TRAN_ID is
'Last committed transaction'
/
comment on column SYSTEM.DEF$_PUSHED_TRANSACTIONS.DISABLED is
'Disable propagation'
/
comment on column SYSTEM.DEF$_PUSHED_TRANSACTIONS.SOURCE_SITE is
'Obsolete - do not use'
/

COMMIT
/

------------------------------------------------------------------------------
--
-- Create dummy tables for def$_aqcall and def$_aqerror table .
-- These tables are created by AQ procedure create_queue_table,
-- called in catdefer.sql. The dummy tables are needed for compiling
-- views and package bodies that depend on the def$_aqcall and def$_aqerror.
--
CREATE TABLE "SYSTEM"."DEF$_AQCALL"
("Q_NAME" VARCHAR2(30),
  "MSGID" RAW(16),
  "CORRID" VARCHAR2(128),
  "PRIORITY" NUMBER,
  "STATE" NUMBER,
  "DELAY" TIMESTAMP (6),
  "EXPIRATION" NUMBER,
  "TIME_MANAGER_INFO" TIMESTAMP (6),
  "LOCAL_ORDER_NO" NUMBER,
  "CHAIN_NO" NUMBER,
  "CSCN" NUMBER,
  "DSCN" NUMBER,
  "ENQ_TIME" TIMESTAMP (6),
  "ENQ_UID" NUMBER,
  "ENQ_TID" VARCHAR2(30),
  "DEQ_TIME" TIMESTAMP (6),
  "DEQ_UID" NUMBER,
  "DEQ_TID" VARCHAR2(30),
  "RETRY_COUNT" NUMBER,
  "EXCEPTION_QSCHEMA" VARCHAR2(30),
  "EXCEPTION_QUEUE" VARCHAR2(30),
  "STEP_NO" NUMBER,
  "RECIPIENT_KEY" NUMBER,
  "DEQUEUE_MSGID" RAW(16),
  "USER_DATA" BLOB,
  PRIMARY KEY ("ENQ_TID", "STEP_NO")
)
/

CREATE TABLE "SYSTEM"."DEF$_AQERROR"
("Q_NAME" VARCHAR2(30),
  "MSGID" RAW(16),
  "CORRID" VARCHAR2(128),
  "PRIORITY" NUMBER,
  "STATE" NUMBER,
  "DELAY" TIMESTAMP (6),
  "EXPIRATION" NUMBER,
  "TIME_MANAGER_INFO" TIMESTAMP (6),
  "LOCAL_ORDER_NO" NUMBER,
  "CHAIN_NO" NUMBER,
  "CSCN" NUMBER,
  "DSCN" NUMBER,
  "ENQ_TIME" TIMESTAMP (6),
  "ENQ_UID" NUMBER,
  "ENQ_TID" VARCHAR2(30),
  "DEQ_TIME" TIMESTAMP (6),
  "DEQ_UID" NUMBER,
  "DEQ_TID" VARCHAR2(30),
  "RETRY_COUNT" NUMBER,
  "EXCEPTION_QSCHEMA" VARCHAR2(30),
  "EXCEPTION_QUEUE" VARCHAR2(30),
  "STEP_NO" NUMBER,
  "RECIPIENT_KEY" NUMBER,
  "DEQUEUE_MSGID" RAW(16),
  "USER_DATA" BLOB,
  PRIMARY KEY ("ENQ_TID", "STEP_NO")
) 
/

------------------------------------------------------------------------------

--
--
-- Create a synonym for the new deferred queue table.
-- Note columns in def$_aqcall are different from the old def$_call
CREATE OR REPLACE SYNONYM def$_aqcall FOR system.def$_aqcall
/
 
CREATE OR REPLACE SYNONYM def$_calldest FOR system.def$_calldest
/
CREATE OR REPLACE SYNONYM def$_schedule FOR system.def$_schedule
/
CREATE OR REPLACE SYNONYM def$_error FOR system.def$_error
/

-- This view is for internal use only and may change without notice.
-- PROPAGATION_WAS_ENABLED is only meaningful if DISABLED_INTERNALLY_SET
-- is 'Y'.
CREATE OR REPLACE VIEW "_DEFSCHEDULE"  AS
  SELECT s.dblink, s.job, j.interval# interval, next_date, 
         j.last_date, s.disabled, s.last_txn_count, s.last_error_number, 
         s.last_error_message, s.catchup,
         s.total_txn_count,
         to_number(decode(s.total_prop_time_throughput, 0, NULL, 
         s.total_txn_count/s.total_prop_time_throughput)) avg_throughput,
         to_number(decode(s.total_txn_count, 0, NULL,
         s.total_prop_time_latency/s.total_txn_count)) avg_latency,
         s.to_communication_size total_bytes_sent,
         s.from_communication_size total_bytes_received,
         s.spare1 total_round_trips,
         s.spare2 total_admin_count,
         s.spare3 total_error_count,
         s.spare4 total_sleep_time,
         DECODE(utl_raw.bit_and(utl_raw.substr(s.flag, 1, 1), '02'),
               '00', 'N', 'Y') disabled_internally_set,
         DECODE(utl_raw.bit_and(utl_raw.substr(s.flag, 1, 1), '01'),
               '00', 'N', 'Y') propagation_was_enabled
    FROM system.def$_destination s, sys.job$ j where s.job = j.job(+)
/

CREATE OR REPLACE VIEW defschedule  AS
  SELECT dblink, job, interval, next_date,
         last_date, disabled, last_txn_count, last_error_number,
         last_error_message, catchup,
         total_txn_count,
         avg_throughput,
         avg_latency,
         total_bytes_sent,
         total_bytes_received,
         total_round_trips,
         total_admin_count,
         total_error_count,
         total_sleep_time,
         disabled_internally_set
    FROM sys."_DEFSCHEDULE"
/

grant select on defschedule to select_catalog_role
/

comment on table DEFSCHEDULE is
'Information about propagation to different destinations'
/
comment on column DEFSCHEDULE.DBLINK is
'Destination'
/
comment on column DEFSCHEDULE.JOB is
'Number of job that pushes queue'
/
comment on column DEFSCHEDULE.INTERVAL is
'Function used to calculate the next time to push the queue to destination'
/
comment on column DEFSCHEDULE.NEXT_DATE is
'Next date that job is scheduled to be executed'
/
comment on column DEFSCHEDULE.LAST_DATE is
'Last time queue was (attempted to be) pushed to destination'
/
comment on column DEFSCHEDULE.DISABLED is
'Is propagation to destination disabled'
/
comment on column DEFSCHEDULE.LAST_TXN_COUNT is
'Number of transactions pushed during last attempt'
/
comment on column DEFSCHEDULE.LAST_ERROR_NUMBER is
'Oracle error number from last push'
/
comment on column DEFSCHEDULE.LAST_ERROR_MESSAGE is
'Error message from last push'
/
comment on column DEFSCHEDULE.CATCHUP is
'Used to break transaction into pieces'
/
comment on column DEFSCHEDULE.DISABLED_INTERNALLY_SET is
'disabled was set internally for propagation synchronization'
/
comment on column DEFSCHEDULE.TOTAL_TXN_COUNT is
'Total number of transactions propagated (including error transactions)'
/
comment on column DEFSCHEDULE.AVG_THROUGHPUT is
'Average number of transactions (including errors) propagated per second'
/
comment on column DEFSCHEDULE.AVG_LATENCY is
'Average time in seconds since start of transaction to remote commit'
/
comment on column DEFSCHEDULE.TOTAL_BYTES_SENT is
'Total number of bytes sent over SQL*Net during propagation'
/
comment on column DEFSCHEDULE.TOTAL_BYTES_RECEIVED is
'Total number of bytes received over SQL*Net during propagation'
/
comment on column DEFSCHEDULE.TOTAL_ROUND_TRIPS is
'Total number of SQL*Net round trips during propagation'
/
comment on column DEFSCHEDULE.TOTAL_ADMIN_COUNT is
'Total number of administrative requests'
/
comment on column DEFSCHEDULE.TOTAL_ERROR_COUNT is
'Total number of error transactions propagated'
/
comment on column DEFSCHEDULE.TOTAL_SLEEP_TIME is
'Total time in seconds spent sleeping during propagation'
/

CREATE OR REPLACE PUBLIC SYNONYM defschedule FOR defschedule
/

CREATE OR REPLACE VIEW deferror AS SELECT
   e.enq_tid deferred_tran_id,
   e.origin_tran_db,
   e.origin_enq_tid origin_tran_id,
   e.step_no callno,
   e.destination, 
   e.enq_time start_time, e.error_number, e.error_msg, u.name receiver 
    FROM system.def$_error e, sys.user$ u
    WHERE e.receiver = u.user# (+)
/
grant select on deferror to select_catalog_role
/

comment on table DEFERROR is
'Information about all deferred transactions that caused an error'
/
comment on column DEFERROR.DEFERRED_TRAN_ID is
'The ID of the transaction that created the error'
/
comment on column DEFERROR.ORIGIN_TRAN_DB is
'The database originating the deferred transaction'
/
comment on column DEFERROR.ORIGIN_TRAN_ID is
'The original ID of the transaction'
/
comment on column DEFERROR.CALLNO is
'Unique ID of call that caused an error'
/
comment on column DEFERROR.DESTINATION is
'Database link used to address destination'
/
comment on column DEFERROR.START_TIME is
'Time original transaction enqueued'
/
comment on column DEFERROR.ERROR_NUMBER is
'Oracle error number'
/
comment on column DEFERROR.ERROR_MSG is
'Error message text'
/
comment on column DEFERROR.RECEIVER is
'The original receiver of the deferred transaction'
/

CREATE OR REPLACE PUBLIC SYNONYM deferror for deferror
/

CREATE OR REPLACE VIEW deferrcount AS
  SELECT count(1) errcount, destination 
    FROM deferror GROUP BY destination
/
grant select on deferrcount to select_catalog_role
/

comment on table DEFERRCOUNT is
'Summary information about deferred transactions that caused an error'
/
comment on column DEFERRCOUNT.ERRCOUNT is
'Number of existing transactions that caused an error for given destination'
/
comment on column DEFERRCOUNT.DESTINATION is
'Database link used to address destination'
/

CREATE OR REPLACE PUBLIC SYNONYM deferrcount for deferrcount
/
GRANT SELECT ON deferrcount TO PUBLIC
/

CREATE OR REPLACE VIEW deftran AS SELECT 
  enq_tid deferred_tran_id, 
  cscn delivery_order, 
  decode(recipient_key, 0, 'D', 'R') destination_list,
  enq_time start_time 
  FROM system.def$_aqcall t 
  WHERE cscn is NOT NULL 
UNION ALL 
SELECT enq_tid deferred_tran_id, 
  cscn delivery_order, 
  'D' destination_list, 
  enq_time start_time 
  FROM system.def$_aqerror t 
  WHERE cscn is NOT NULL 
/
grant select on deftran to select_catalog_role
/

comment on table DEFTRAN is
'Information about all deferred transactions'
/
comment on column DEFTRAN.DEFERRED_TRAN_ID is
'The transaction that enqueued the calls'
/
comment on column DEFTRAN.DELIVERY_ORDER is
'Total ordering on transactions'
/
comment on column DEFTRAN.DESTINATION_LIST is
'Determine destinations from deftrandest (D) or repcat (R)'
/
comment on column DEFTRAN.START_TIME is
'Time original transaction enqueued'
/

CREATE OR REPLACE PUBLIC SYNONYM deftran FOR deftran
/

--- just select from def$_calldest (D-type txn). We need repcat$_repprop
--- to determine destination for R-type txn. We can't remove this one
--- because dbms_snapshot needs it
create or replace view deftrandest as SELECT 
C.enq_tid deferred_tran_id, 
C.cscn delivery_order, 
D.dblink 
from system.def$_aqcall C, system.def$_destination D 
where C.cscn IS NOT NULL 
AND C.cscn >= D.last_delivered 
AND 
  (C.cscn > D.last_delivered 
  OR 
   (C.cscn = D.last_delivered AND (C.enq_tid > D.last_enq_tid))) 
AND EXISTS ( 
 select /*+ index(def$_calldest_primary) */ NULL 
 from system.def$_calldest CD 
 where CD.enq_tid = C.enq_tid 
   AND CD.dblink = D.dblink
   AND CD.catchup = D.catchup)
/
 
Rem The deftrandest view defined above is replaced in catrepc.
grant select on deftrandest to select_catalog_role
/

comment on table DEFTRANDEST is
'Information about destinations for deferred transactions'
/
comment on column DEFTRANDEST.DEFERRED_TRAN_ID is
'Transaction ID'
/
comment on column DEFTRANDEST.DELIVERY_ORDER is
'Total ordering of transactions: second element in the tuple'
/
comment on column DEFTRANDEST.DBLINK is
'The destination database'
/
CREATE OR REPLACE PUBLIC SYNONYM deftrandest FOR deftrandest
/

--  Create table of default nodes for replication targets
--  this table is managed by calls in dbms_defer_sys

CREATE SYNONYM def$_defaultdest FOR system.def$_defaultdest
/
CREATE OR REPLACE VIEW defdefaultdest AS
  SELECT * from system.def$_defaultdest
/
grant select on defdefaultdest to select_catalog_role
/

comment on table DEFDEFAULTDEST is
'Default destinations for deferred remote procedure calls'
/
comment on column DEFDEFAULTDEST.DBLINK is
'Default destination'
/

CREATE OR REPLACE PUBLIC SYNONYM defdefaultdest for defdefaultdest
/

CREATE OR REPLACE SYNONYM def$_lob FOR system.def$_lob
/

CREATE OR REPLACE VIEW DefLOB 
  (id, deferred_tran_id, blob_col, clob_col, nclob_col)
  AS SELECT
     d.id,
     d.enq_tid,
     d.blob_col,
     d.clob_col,
     d.nclob_col
  FROM sys.def$_lob d
/

grant select on deflob to select_catalog_role
/

comment on table DEFLOB is
'Storage for LOB parameters to deferred RPCs'
/
comment on column DEFLOB.ID is
'Identifier of LOB parameter'
/
comment on column DEFLOB.DEFERRED_TRAN_ID is
'Transaction identifier for deferred RPC with this LOB parameter'
/
comment on column DEFLOB.BLOB_COL is
'Binary LOB parameter'
/
comment on column DEFLOB.CLOB_COL is
'Character LOB parameter'
/
comment on column DEFLOB.NCLOB_COL is
'National Character LOB parameter'
/

CREATE OR REPLACE PUBLIC SYNONYM DefLOB for DefLOB
/

CREATE OR REPLACE VIEW defpropagator
  (username, userid, status, created)
  AS SELECT
       p.username,
       p.userid,
       DECODE(u.name, NULL, 'INVALID', 'VALID'),
       p.created
     FROM system.def$_propagator p, sys.user$ u
     WHERE p.userid = u.user# (+)
/
grant select on defpropagator to select_catalog_role
/

comment on table DEFPROPAGATOR is
'Information about the propagator for all deferred remote procedure calls'
/
comment on column DEFPROPAGATOR.USERNAME is
'Username of the propagator'
/
comment on column DEFPROPAGATOR.USERID is
'User ID of the propagator'
/
comment on column DEFPROPAGATOR.STATUS is
'Status of the propagator'
/
comment on column DEFPROPAGATOR.CREATED is
'Time when the propagator is registered'
/

CREATE OR REPLACE PUBLIC SYNONYM defpropagator FOR defpropagator
/

