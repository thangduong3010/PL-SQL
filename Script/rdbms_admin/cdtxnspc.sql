Rem
Rem $Header: cdtxnspc.sql 09-may-2006.13:58:27 cdilling Exp $
Rem
Rem cdtxnspc.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cdtxnspc.sql - Catalog DTXNSPC.bsq views
Rem
Rem    DESCRIPTION
Rem      two phase commit objects
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in dtxnspc.bsq. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    05/04/06 - Created
Rem

rem     **********************************************************************
rem             DBA TWO PHASE COMMIT DECISION / DAMAGE ASSESSMENT TABLES
rem     **********************************************************************
rem     PSS1$: used to add user name column to pending_sub_sessions$
create or replace view pss1$ as
select  pss.*, u.name owner_name
from    sys.pending_sub_sessions$ pss, sys.user$ u
where   pss.link_owner = u.user#;
grant select on pss1$ to select_catalog_role;

rem     PS1$: used to add user name column to pending_sessions$
create or replace view ps1$ ( local_tran_id, session_id, branch_id,
        interface, type, parent_dbid, parent_db, db_userid, db_user) as
select  ps.*, u.name db_user
from    sys.pending_sessions$ ps, sys.user$ u
where   ps.db_userid = u.user#;
grant select on ps1$ to select_catalog_role;

rem     DBA_2PC_PENDING
rem     use this view to find info about pending (i.e. incomplete) distributed
rem     transactions at this DB.  Use os_user and db_userid to help track down
rem     a responsible party.  Use DBA_2PC_NEIGHBORS to find the commit point.
rem     Or take the advice, if offered.

create or replace view DBA_2PC_PENDING
    (local_tran_id, global_tran_id, state, mixed,
     advice, tran_comment, fail_time, force_time,
     retry_time, os_user, os_terminal, host, db_user, commit#) as
select  local_tran_id,
        nvl(global_oracle_id, global_tran_fmt||'.'||global_foreign_id),
        state, decode(status,'D','yes','no'), heuristic_dflt, tran_comment,
        fail_time, heuristic_time, reco_time,
        top_os_user, top_os_terminal, top_os_host, top_db_user, global_commit#
from    sys.pending_trans$;
create or replace public synonym DBA_2PC_PENDING for DBA_2PC_PENDING;
grant select on DBA_2PC_PENDING to select_catalog_role;
comment on table DBA_2PC_PENDING is
  'info about distributed transactions awaiting recovery';
comment on column DBA_2PC_PENDING.local_tran_id is
  'string of form: n.n.n, n a number';
comment on column DBA_2PC_PENDING.global_tran_id is
  'globally unique transaction id';
comment on column DBA_2PC_PENDING.state is
  'collecting, prepared, committed, forced commit, or forced rollback';
comment on column DBA_2PC_PENDING.mixed is
  'yes => part of the transaction committed and part rolled back (commit or rollback with the FORCE option was used)';
comment on column DBA_2PC_PENDING.advice is
  'C for commit, R for rollback, else null';
comment on column DBA_2PC_PENDING.tran_comment is
  'text for "commit work comment <text>"';
comment on column DBA_2PC_PENDING.fail_time is
  'value of SYSDATE when the row was inserted (tx or system recovery)';
comment on column DBA_2PC_PENDING.force_time is
 'time of manual force decision (null if not forced locally)';
comment on column DBA_2PC_PENDING.retry_time is
 'time automatic recovery (RECO) last tried to recover the transaction';
comment on column DBA_2PC_PENDING.os_user is
  'operating system specific name for the end-user';
comment on column DBA_2PC_PENDING.os_terminal is
  'operating system specific name for the end-user terminal';
comment on column DBA_2PC_PENDING.host is
  'name of the host machine for the end-user';
comment on column DBA_2PC_PENDING.db_user is
  'Oracle user name of the end-user at the topmost database';
comment on column DBA_2PC_PENDING.commit# is
  'global commit number for committed transactions';

rem     DBA_2PC_NEIGHBORS: use this view to obtain info about incoming and
rem       outgoing connections for a particular transaction.  It is suggested
rem       that it be queried using:
rem         select * from dba_2pc_neighbors where local_tran_id = <id>
rem          order by sess#, "IN_OUT";
rem       This will group sessions, with outgoing connections following the
rem       incoming connection for each session.
rem   columns:
rem     IN_OUT: 'in' for incoming connections, 'out' for outgoing
rem     DATABASE: if 'in', the name of the client database, else name of
rem       outgoing db link
rem     DBUSER_OWNER: if 'in', name of local user, else owner of db link
rem     INTERFACE: 'C' hold commit, else 'N'.  For incoming links, 'C'
rem       means that we or a DB at the other end of one of our outgoing links
rem       is the commit point (and must not forget until told by the client).
rem       For outgoing links, 'C' means that the child at the other end is the
rem       commit point, and will know whether the tran should commit or abort.
rem       If we are indoubt and do not find a 'C' on an outgoing link, then
rem       the top level user/DB, or the client, should be able to locate the
rem       commit point.
rem     DBID: the database id at the other end of the connection
rem     SESS#: session number at this database of the connection.  Sessions are
rem       numbered consecutively from 1; there is always at least 1 session,
rem       and exactly 1 incoming connection per session.
rem     BRANCH_ID: transaction branch.  An incoming branch is a two byte
rem       hexadecimal number.  The first byte is the session_id of the
rem       remote parent session.  The second byte is the branch_id of the
rem       remote parent session.  If the remote parent session is not Oracle,
rem       the branch_id can be up to 64 bytes.

create or replace view DBA_2PC_NEIGHBORS(local_tran_id, in_out, database,
                               dbuser_owner, interface, dbid,
                               sess#, branch) as
select  local_tran_id, 'in', parent_db, db_user, interface, parent_dbid,
        session_id, rawtohex(branch_id)
from    sys.ps1$
union all
select  local_tran_id, 'out', dblink, owner_name, interface, dbid,
        session_id, to_char(sub_session_id)
from    sys.pss1$;
create or replace public synonym DBA_2PC_NEIGHBORS for DBA_2PC_NEIGHBORS;
grant select on DBA_2PC_NEIGHBORS to select_catalog_role;
comment on table DBA_2PC_NEIGHBORS is
  'information about incoming and outgoing connections for pending transactions';
comment on column DBA_2PC_NEIGHBORS.in_out is
  '"in" for incoming connections, "out" for outgoing';
comment on column DBA_2PC_NEIGHBORS.database is
  'in: client database name; out: outgoing db link';
comment on column DBA_2PC_NEIGHBORS.dbuser_owner is
  'in: name of local user; out: owner of db link';
comment on column DBA_2PC_NEIGHBORS.interface is
  '"C" for request commit, else "N" for prepare or request readonly commit';
comment on column DBA_2PC_NEIGHBORS.dbid is
  'the database id at the other end of the connection';
comment on column DBA_2PC_NEIGHBORS.sess# is
  'session number at this database of the connection';
comment on column DBA_2PC_NEIGHBORS.branch is
  'transaction branch ID at this database of the connection'
/
