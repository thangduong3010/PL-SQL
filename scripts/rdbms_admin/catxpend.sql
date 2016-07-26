Rem
Rem $Header: catxpend.sql 19-oct-2001.17:09:05 somichi Exp $
Rem
Rem catxpend.sql
Rem
Rem Copyright (c) 1999, 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catxpend.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Create view necessary for XA recovery.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    somichi     10/19/01 - #(2050582) eliminate unprepared txn
Rem    gviswana    05/24/01 - CREATE AND REPLACE SYNONYM
Rem    rburns      11/09/00 - remove echo
Rem    varora      09/28/00 - remove set echo off
Rem    jarnett     09/24/99 - bug 951528 - fix dba_pending_transactions
Rem    jarnett     09/24/99 - Created
Rem
Rem	DBA_PENDING_TRANSACTIONS
Rem	This view gives information about unresolved transactions (either
Rem	due to failure or co-ordinator has not sent a commit/rollback).
Rem	The view selects information from the pending_trans$ dictionary table
Rem	and the in-memory tables in all instances provided by
Rem	gv$global_transactions. A join is required between pending_trans$
Rem	and pending_sessions$ because the branch_id is stored in 
Rem	pending_sessions$. Since Oracle's lock manager is session based we
Rem	will never have multiple sessions for a given transaction that are in
Rem	the prepared state (although this is possible when transaction is
Rem	in collecting state). Hence, the funny BITAND condition is probably
Rem	not required (tran.state != collecting ==> only one branch left ?)
Rem	Secondly, the view is not just a simple Union of the fixed view
Rem	and the dictionary tables information in order to eliminate the window
Rem	where SMON writes information into the dictionary table after we select
Rem	it from the in-memory table (not having the MINUS may result in
Rem	duplicates in this view).
Rem	DBAs are not required to select this view. Currently, only XA uses this
Rem	view

create or replace view DBA_PENDING_TRANSACTIONS(formatid, globalid, branchid)
as
(((select formatid, globalid, branchid
   from   gv$global_transaction
   where  preparecount > 0 and refcount = preparecount)
 minus
  (select global_tran_fmt, global_foreign_id, branch_id
   from   sys.pending_trans$ tran, sys.pending_sessions$ sess
   where  tran.local_tran_id = sess.local_tran_id
     and  tran.state != 'collecting'
     and  dbms_utility.is_bit_set(tran.session_vector, sess.session_id)=1)
 )
 union
  (select global_tran_fmt, global_foreign_id, branch_id
   from   sys.pending_trans$ tran, sys.pending_sessions$ sess
   where  tran.local_tran_id = sess.local_tran_id
     and  tran.state != 'collecting'
     and  dbms_utility.is_bit_set(tran.session_vector, sess.session_id)=1)
);
create or replace public synonym DBA_PENDING_TRANSACTIONS
   for DBA_PENDING_TRANSACTIONS;
grant select on DBA_PENDING_TRANSACTIONS to select_catalog_role;
comment on table DBA_PENDING_TRANSACTIONS is
  'information about unresolved global transactions';
comment on column DBA_PENDING_TRANSACTIONS.formatid is
  'format identifier of the transaction identifier';
comment on column DBA_PENDING_TRANSACTIONS.globalid is
  'global part (gtrid) of the transaction identifier';
comment on column DBA_PENDING_TRANSACTIONS.branchid is
  'branch qualifier (bqual) of the transaction identifier';
