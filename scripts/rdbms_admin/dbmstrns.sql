Rem
Rem $Header: dbmstrns.sql 17-aug-2005.17:14:45 lvbcheng Exp $
Rem
Rem dbmstrns.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmstrns.sql - DBMS_TRANSACTION
Rem
Rem    DESCRIPTION
Rem    DBMS_TRANSACTION - transaction commands
Rem
Rem    NOTES
Rem    DBMS_TRANSACTION was originally located in dbmsutil.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lvbcheng    08/17/05 - lvbcheng_split_dbms_util
Rem    lvbcheng    07/29/05 - moved here from dbmsutil.sql
Rem     ghallmar   11/03/92 -  add dbms_transaction.purge_mixed 
Rem

Rem ********************************************************************
Rem THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
Rem COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
Rem RDBMS.  SPECIFICALLY, THE PSD* AND EXECUTE_SQL ROUTINES MUST NOT BE
Rem CALLED DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
Rem ********************************************************************

create or replace package dbms_transaction AUTHID CURRENT_USER is

  ------------
  --  OVERVIEW
  --
  --  This package provides access to SQL transaction statements from
  --  stored procedures.
  --  It also provids functions for monitoring transaction activities
  --  (transaction ids and ordering of steps of transactions )

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure read_only;
  --  Equivalent to SQL "SET TRANSACTION READ ONLY"
  procedure read_write;
  --  Equivalent to SQL "SET TRANSACTION READ WRITE"
  procedure advise_rollback;
  --  Equivalent to SQL "ALTER SESSION ADVISE ROLLBACK"
  procedure advise_nothing;
  --  Equivalent to SQL "ALTER SESSION ADVISE NOTHING"
  procedure advise_commit;
  --  Equivalent to SQL "ALTER SESSION ADVISE COMMIT"
  procedure use_rollback_segment(rb_name varchar2);
  --  Equivalent to SQL "SET TRANSACTION USE ROLLBACK SEGMENT <rb_seg_name>"
  --  Input arguments:
  --    rb_name
  --      Name of rollback segment to use.
  procedure commit_comment(cmnt varchar2);
  --  Equivalent to SQL "COMMIT COMMENT <text>"
  --  Input arguments:
  --    cmnt
  --      Comment to assoicate with this comment.
  procedure commit_force(xid varchar2, scn varchar2 default null);
  --  Equivalent to SQL "COMMIT FORCE <text>, <number>"
  --  Input arguments:
  --    xid
  --      Local or global transaction id.
  --    scn
  --      System change number.
  procedure commit;
    pragma interface (C, commit);                          -- 1 (see psdicd.c)
  --  Equivalent to SQL "COMMIT".  Here for completeness.  This is
  --    already implemented as part of PL/SQL.
  procedure savepoint(savept varchar2);
    pragma interface (C, savepoint);                       -- 2 (see psdicd.c)
  --  Equivalent to SQL "SAVEPOINT <savepoint_name>".  Here for
  --    completeness. This is already implemented as part of PL/SQL.
  --  Input arguments:
  --    savept
  --      Savepoint identifier.
  procedure rollback;
    pragma interface (C, rollback);                        -- 3 (see psdicd.c)
  --  Equivalent to SQL "ROLLBACK".  Here for completeness. This is 
  --    already implemented as part of PL/SQL.
  procedure rollback_savepoint(savept varchar2);
    pragma interface (C, rollback_savepoint);              -- 4 (see psdicd.c)
  --  Equivalent to SQL "ROLLBACK TO SAVEPOINT <savepoint_name>".  Here for
  --    completeness. This is already implemented as part of PL/SQL.
  --  Input arguments:
  --    savept
  --      Savepoint identifier.
  procedure rollback_force(xid varchar2);
  --  Equivalent to SQL "ROLLBACK FORCE <text>"
  --  Input arguments:
  --    xid
  --      Local or global transaction id.
  procedure begin_discrete_transaction;
    pragma interface (C, begin_discrete_transaction);      -- 5 (see psdicd.c)
  --  Set "discrete transaction mode" for this transaction.
  --  Exceptions:
  --    ORA-08175 will be generated if a transaction attempts an operation 
  --      which cannot be performed as a discrete transaction.  If this 
  --      exception is encountered, rollback and retry the transaction.

  --    ORA-08176 will be generated if a transaction encounters data changed 
  --      by an operation that does not generate rollback data : create index,
  --      direct load or discrete transaction.  If this exception is
  --      encountered, retry the operation that received the exception.
  --    
  DISCRETE_TRANSACTION_FAILED exception;
    pragma exception_init(DISCRETE_TRANSACTION_FAILED, -8175);

  CONSISTENT_READ_FAILURE exception;
    pragma exception_init(CONSISTENT_READ_FAILURE, -8176);

  procedure purge_mixed(xid varchar2);
  --  When indoubt transactions are forced to commit or rollback (instead of
  --    letting automatic recovery resolve their outcomes), there is a
  --    possibility that a transaction can have a mixed outcome: some sites
  --    commit, and others rollback.  Such inconsistency cannot be resolved
  --    automatically by ORACLE; however, ORACLE will flag entries in
  --    DBA_2PC_PENDING by setting the MIXED column to a value of 'yes'.
  --    ORACLE will never automatically delete information about a mixed
  --    outcome transaction.  When the application or DBA is sure all
  --    inconsistencies that might have arisen as a result of the mixed
  --    transaction have been resolved, this procedure can be used to
  --    delete the information about a given mixed outcome transaction.
  --  Input arguments:
  --    xid
  --      This must be set to the value of the LOCAL_TRAN_ID column in 
  --      the DBA_2PC_PENDING table.

  procedure purge_lost_db_entry(xid varchar2);
  --  When a failure occurs during commit processing, automatic recovery will
  --    consistently resolve the results at all sites involved in the 
  --    transaction.  However, if the remote database is destroyed or 
  --    recreated before recovery completes, then the entries used to 
  --    control recovery in DBA_2PC_PENDING and associated tables will never
  --    be removed, and recovery will periodically retry.  Procedure 
  --    purge_lost_db_entry allows removal of such transactions from the 
  --    local site.

  --  WARNING: purge_lost_db_entry should ONLY be used when the other
  --  database is lost or has been recreated.  Any other use may leave the
  --  other database in an unrecoverable or inconsistent state.

  --    Before automatic recovery runs, the transaction may show 
  --    up in DBA_2PC_PENDING as state "collecting", "committed", or
  --    "prepared".  If the DBA has forced an in-doubt transaction to have
  --    a particular result by using "commit force" or "rollback force",
  --    then states "forced commit" or "forced rollback" may also appear.  
  --    Automatic recovery will normally delete entries in any of these 
  --    states.  The only exception is when recovery finds a forced
  --    transaction which is in a state inconsistent with other sites in the 
  --    transaction;  in this case, the entry will be left in the table
  --    and the MIXED column will have a value 'yes'.

  --    However, under certain conditions, it may not be possible for 
  --    automatic recovery to run.  For example, a remote database may have 
  --    been permanently lost.  Even if it is recreated, it will get a new 
  --    database id, so that recovery cannot identify it (a possible symptom 
  --    is ORA-02062).  In this case, the DBA may use the procedure 
  --    purge_lost_db_entry to clean up the entries in any state other 
  --    than "prepared".  The DBA does not need to be in any particular 
  --    hurry to resolve these entries, since they will not be holding any 
  --    database resources.
  
  --    The following table indicates what the various states indicate about
  --    the transaction and what the DBA actions should be:

  --    State       State of     State of     Normal Alternative
  --    Column      Global       Local        DBA    DBA 
  --                Transaction  Transaction  Action Action
  --    ----------  ------------ ------------ ------ ---------------
  --    collecting  rolled back  rolled back  none   purge_lost_db_entry (1)
  --    committed   committed    committed    none   purge_lost_db_entry (1)
  --    prepared    unknown      prepared     none   force commit or rollback
  --    forced      unknown      committed    none   purge_lost_db_entry (1)
  --      commit
  --    forced      unknown      rolled back  none   purge_lost_db_entry (1)
  --      rollback
  --    forced      mixed        committed    (2)
  --      commit
  --      (mixed)                              
  --    forced      mixed        rolled back  (2)
  --      rollback
  --      (mixed)                             
   
  --    Note 1: Use only if significant reconfiguration has occurred so that
  --      automatic recovery cannot resolve the transaction.  Examples are
  --      total loss of the remote database, reconfiguration in software
  --      resulting in loss of two-phase commit capability, or loss of 
  --      information from an external transaction coordinator such as a TP
  --      Monitor.
  --    Note 2: Examine and take any manual action to remove inconsistencies, 
  --      then use the procedure purge_mixed.
  --  Input arguments:
  --    xid
  --      This must be set to the value of the LOCAL_TRAN_ID column in
  --      the DBA_2PC_PENDING table.

  FUNCTION local_transaction_id(create_transaction BOOLEAN := FALSE)
    RETURN VARCHAR2;
  --  Return local (to instance) unique identfier for current transaction
  --  Return null if there is no current transction.
  --  Input parameters:
  --     create_transaction 
  --       If true , start a transaciton if one is not currently 
  --       active.
  --
  FUNCTION step_id RETURN NUMBER;
  --  Return local (to local transaction ) unique positive integer that orders
  --  The DML operations of a transaction.
  --  Input parmaeters:

end;
/
create or replace public synonym dbms_transaction for sys.dbms_transaction
/
grant execute on dbms_transaction to public
/
