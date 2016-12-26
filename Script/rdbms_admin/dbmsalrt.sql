rem 
rem $Header: rdbms/admin/dbmsalrt.sql /main/11 2010/04/13 00:38:39 kquinn Exp $ 
rem 
Rem  Copyright (c) 1991, 1996, 2000 by Oracle Corporation 
Rem    NAME
Rem     dbmsalrt.sql - Blocking implementation of DBMS "alerts"
Rem    DESCRIPTION
Rem     Routines to wait-for, and signal, a named event.  The waiting
Rem     session will block in the database until the event occurs, or until
Rem     a timeout expires.  The implementation avoids polling except when
Rem     running in parallel server mode.
Rem    RETURNS
Rem 
Rem    NOTES
Rem      The procedural option is needed to use this facility.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     kquinn     04/08/10  - 9437010: amend register
Rem     ywu        08/01/00 -  plsql package
Rem     asurpur    04/09/96 -  Dictionary Protection Implementation
Rem     adowning   03/29/94 -  merge changes from branch 1.7.710.1
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     mmoore     03/17/93 -  merge changes from branch 1.6.312.1 
Rem     mmoore     03/11/92 - #(153818) fix looping in signal upon cleanup
Rem     rkooi      12/03/92 - #141803, improve some comments 
Rem     rkooi      11/25/92 -  allow signalling and waiting in same session 
Rem     rkooi      11/17/92 -  pipe cleanup bug 
Rem     rkooi      11/12/92 -  don't call removeall from signal
Rem     rkooi      08/12/92 -  surface removeall function 
Rem     rkooi      06/05/92 -  Creation 
REM 

create or replace package dbms_alert is

  ------------
  --  OVERVIEW
  --
  --  This package provides support for the asynchronous (as opposed to
  --  polling) notification of database events.  By appropriate use of
  --  this package and database triggers, an application can cause itself
  --  to be notified whenever values of interest in the database are
  --  changed.  
  --
  --  For example, suppose a graphics tool is displaying a graph of some
  --  data from a database table.  The graphics tool can, after reading and
  --  graphing the data, wait on a database alert ('dbms_alert.waitone')
  --  covering the data just read.  The tool will automatically wake up when
  --  the data is changed by any other user.  All that is required is that a
  --  trigger be placed on the database table which then performs a signal
  --  ('dbms_alert.signal') whenever the trigger is fired.
  --
  --  Alerts are transaction based.  This means that the waiting session
  --  does not get alerted until the transaction signalling the alert commits.
  --
  --  There can be any number of concurrent signallers of a given alert, and
  --  there can be any number of concurrent waiters on a given alert.
  --
  --  A waiting application will be blocked in the database and cannot do
  --  any other work.
  --  
  --  Most of the calls in the package, except for 'signal', do commits.
  --

  -----------
  --  EXAMPLE
  --
  --  Suppose the application wishes to graph average salaries, say by
  --  department, for all employees.  So the application needs to know
  --  whenever 'emp' is changed.  The application would look like this:
  --
  --      dbms_alert.register('emp_table_alert');  
  --    readagain:
  --      <read the emp table and graph it>
  --      dbms_alert.waitone('emp_table_alert', :message, :status);
  --      if status = 0 then goto readagain; else <error condition>
  --
  --  The 'emp' table would have a trigger similar to the following:
  --
  --    create trigger emptrig after insert or update or delete on emp
  --    begin
  --      dbms_alert.signal('emp_table_alert', 'message_text');
  --    end;
  --
  --  When the application is no longer interested in the alert, it does
  --    dbms_alert.remove('emp_table_alert');
  --  This is important since it reduces the amount of work required by
  --  the alert signaller.
  --
  --  If a session exits (or dies) while there exist registered alerts,
  --  they will eventually be cleaned up by future users of this package.
  --
  --  The above example guarantees that the application will always see
  --  the latest data, although it may not see every intermediate value.


  --------------
  --  VARIATIONS
  --
  --  The application can register for multiple events and can then wait for
  --  any of them to occur using the 'waitany' call.
  --
  --  An application can also supply an optional 'timeout' parameter to the
  --  'waitone' or 'waitany' calls.  A 'timeout' of 0 returns immediately
  --  if there is no pending alert.
  --
  --  The signalling session can optionally pass a message which will be
  --  received by the waiting session.
  --
  --  Alerts may be signalled more often than the corresponding application
  --  'wait' calls.  In such cases the older alerts are discaded.  The 
  --  application always gets the latest alert (based on transaction commit 
  --  times).
  -- 
  --  If the application does not require transaction based alerts, then the 
  --  'dbms_pipe' package may provide a useful alternative
  --
  --  If the transaction is rolled back after the call to 'dbms_alert.signal',
  --  no alert will occur.
  -- 
  --  It is possible to receive an alert, read the data, and find that no
  --  data has changed.  This is because the data changed after the *prior*
  --  alert, but before the data was read for that *prior* alert.


  --------------------------
  --  IMPLEMENTATION DETAILS
  --
  --  In most cases the implementation is event-driven, i.e., there are no
  --  polling loops.  There are two cases where polling loops can occur:
  --
  --    1) Parallel mode.  If your database is running parallel mode then
  --       a polling loop is required to check for alerts from another
  --       instance.  The polling loop defaults to one second and is settable
  --       by the 'set_defaults' call.
  --    2) Waitany call.  If you use the 'waitany' call, and a signalling 
  --       session does a signal but does not commit within one second of the
  --       signal, then a polling loop is required so that this uncommitted
  --       alert does not camouflage other alerts.  The polling loop begins
  --       at a one second interval and exponentially backs off to 30 second
  --       intervals.
  --  
  --  This package uses the dbms_lock package (for synchronization between
  --  signallers and waiters) and the dbms_pipe package (for asynchronous
  --  event dispatching).

  -------------------------------------------------------
  --  INTERACTION WITH MULTI-THREADED AND PARALLEL SERVER
  --
  --  When running with the parallel server AND multi-threaded server, a
  --  multi-threaded (dispatcher) "shared server" will be bound to a
  --  session (and therefore not shareable) during the time a session has
  --  any alerts "registered", OR from the time a session "signals" an
  --  alert until the time the session commits.  Therefore, applications
  --  which register for alerts should use "dedicated servers" rather than
  --  connecting through the dispatcher (to a "shared server") since
  --  registration typically lasts for a long time, and applications which
  --  cause "signals" should have relatively short transactions so as not
  --  to tie up "shared servers" for too long.

  ------------
  --  SECURITY
  --
  --  Security on this package may be controlled by granting execute on 
  --  this package to just those users or roles that you trust.  You may
  --  wish to write a cover package on top of this one which restricts
  --  the alertnames used.  Execute privilege on this cover package can
  --  then be granted rather than on this package.	


  -------------
  --  RESOURCES
  --
  --  This package uses one database pipe and two locks for each alert a 
  --  session has registered.


  ---------------------
  --  SPECIAL CONSTANTS
  --
  maxwait constant integer :=  86400000; -- 1000 days 
  --  The maximum time to wait for an alert (essentially forever).


  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure set_defaults(sensitivity in number);
  --  Set various defaults for this package.
  --  Input parameters:
  --    sensitivity
  --      In case a polling loop is required (see "Implementation Details"
  --      above), this is the time to sleep between polls.  Deafult is 5 sec.
  --
  procedure register(name in varchar2, cleanup in boolean default TRUE);
  --  Register interest in an alert.  A session may register interest in
  --    an unlimited number of alerts.  Alerts should be de-registered when
  --    the session no longer has any interest (see 'remove').  This call
  --    always performs a 'commit'.
  --  Input parameters:
  --    name
  --      The name of the alert in which this session is interested.
  --      WARNING:  Alert names beginning with 'ORA$' are reserved for use for
  --      products provided by Oracle Corporation.  Name must be 30 bytes
  --      or less.  The name is case-insensitive.
  --    cleanup
  --      This specifies whether we should perform cleanup of any orphaned 
  --      pipes that may exist and are used by the dbms_alert package. This
  --      cleanup is only performed on the first call to "register" for each
  --      package instantiation. The default for the parameter is TRUE.
  --
  procedure remove(name in varchar2);
  --  Remove alert from registration list.  Do this when the session is no
  --    longer interested in an alert.  Removing an alert is important
  --    since it will reduce the amount of work done by signalers of the alert.
  --    If a session dies without removing the alert, that alert will
  --    eventually (but not immediately) be cleaned up.  This call always
  --    performs a commit.
  --  Input parameters:
  --    name
  --      The name of the alert to be removed from registration list. The
  --      name is case-insensitive.
  --
  procedure removeall;
  --  Remove all alerts for this session from registration list.  Do this 
  --    when the session is no longer interested in any alerts.  Removing 
  --    alerts is important since it will reduce the amount of work done 
  --    by signalers of the alert.  If a session dies without removing all
  --    of its alerts, the alerts will eventually (but not immediately)
  --    be cleaned up.  This call always performs a commit.
  --
  --    This procedure is called automatically upon first reference to this
  --    package during a session.  Therefore no alerts from prior sessions
  --    which may have terminated abnormally can affect this session.
  procedure waitany(name out varchar2, 
                    message out varchar2, 
                    status out integer,
                    timeout in number default maxwait);
  --  Wait for an alert to occur for any of the alerts for which this
  --    session is registered.  Although probably unusual, the same session
  --    that waits for the alert may also first signal the alert.  In this
  --    case remember to commit after the signal and prior to the wait.  
  --    Otherwise a lock request exception (status 4) will occur.  This
  --    call always performs a commit.
  --  Input parameters:
  --    timeout
  --      The maximum time to wait for an alert.  If no alert occurs before
  --      timeout seconds, then this call will return with status of 1.
  --  Output parameters:
  --    name
  --      The name of the alert that occurred, in uppercase.
  --    message
  --      The message associated with the alert.  This is the message
  --      provided by the 'signal' call.  Note that if multiple signals
  --      on this alert occurred before the waitany call, then the message
  --      will correspond to the most recent signal call.  Messages from
  --      prior signal calls will be discarded.
  --    status
  --      0 - alert occurred
  --      1 - timeout occurred
  --  Errors raised:
  --    -20000, ORU-10024: there are no alerts registered.
  --       Cause: You must register an alert before waiting.
  --
  procedure waitone(name in varchar2, 
                    message out varchar2, 
                    status out integer,
                    timeout in number default maxwait);
  --  Wait for specified alert to occur. If the alert was signalled since
  --    the register or last waitone/waitany, then this call will return
  --    immediately.  The same session that waits for the alert may also
  --    first signal the alert.  In this case remember to commit after the
  --    signal and prior to the wait.  Otherwise a lock request exception
  --    (status 4) will occur.  This call always performs a commit.
  --  Input parameters:
  --    name
  --      The name of the alert to wait for. The name is case-insensitive.
  --    timeout
  --      The maximum time to wait for this alert.  If no alert occurs before
  --      timeout seconds, then this call will return with status of 1.
  --      If the named alert has not been registered then the this call
  --      will return after the timeout period expires.
  --  Output parameters:
  --    message
  --      The message associated with the alert.  This is the message
  --      provided by the 'signal' call.  Note that if multiple signals
  --      on this alert occurred before the waitone call, then the message
  --      will correspond to the most recent signal call.  Messages from
  --      prior signal calls will be discarded.  The message may be up to
  --      1800 bytes.
  --    status
  --      0 - alert occurred
  --      1 - timeout occurred
  --
  procedure signal(name in varchar2, 
                   message in varchar2);
  --  Signal an alert.
  --  Input parameters:
  --    name
  --      Name of the alert to signal.  The effect of the signal call only
  --      occurs when the transaction in which it is made commits.  If the
  --      transaction rolls back, then the effect of the signal call is as
  --      if it had never occurred.  All sessions that have registered
  --      interest in this alert will be notified.  If the interested sessions
  --      are currently waiting, they will be awakened.  If the interested
  --      sessions are not currently waiting, then they will be notified the
  --      next time they do a wait call.  Multiple sessions may concurrently
  --      perform signals on the same alert.  However the first session
  --      will block concurrent sessions until the first session commits.
  --      Name must be 30 bytes or less. It is case-insensitive.  This call
  --      does not perform a commit.
  --    message
  --      Message to associate with this alert.  This will be passed to
  --      the waiting session.  The waiting session may be able to avoid
  --      reading the database after the alert occurs by using the
  --      information in this message.  The message must be 1800 bytes or less.

end;
/
grant execute on dbms_alert to execute_catalog_role
/

