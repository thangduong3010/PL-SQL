rem 
rem $Header: rdbms/admin/dbmslock.sql /st_rdbms_11.2.0/1 2011/07/11 11:11:06 celsbern Exp $ 
rem 
Rem  Copyright (c) 1991, 1996 by Oracle Corporation 
Rem    NAME
Rem      dbmslock.sql - locking routines provided by Oracle
Rem    DESCRIPTION
Rem      See below
Rem    RETURNS
Rem
Rem    NOTES
Rem     The procedural option is needed to use this facility.
Rem
Rem     Lockids from 2000000000 to 2147483647 are reserved for products
Rem     supplied by Oracle:
Rem
Rem       Package                     Lock id range
Rem       =================================================
Rem       dbms_alert                  2000000000-2000002041
Rem       dbms_alert                  2000002042-2000003063
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     celsbern   07/05/11  - Backport celsbern_bug-12584760 from
Rem                            st_rdbms_11.2.0
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     asurpur    04/09/96 -  Dictionary Protection Implementation
Rem     adowning   03/29/94 -  merge changes from branch 1.10.710.1
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     rkooi      12/03/92 -  change comments 
Rem     rkooi      11/25/92 -  return 5 instead of 6 per spec 
Rem     rkooi      11/24/92 -  check for nulls 
Rem     rkooi      11/18/92 -  add comments 
Rem     rkooi      08/20/92 -  comments and cleanup 
Rem     rkooi      06/29/92 -  add some comments 
Rem     rkooi      05/30/92 -  fix timeout problems 
Rem     rkooi      04/30/92 -  add some comments 
Rem     rkooi      04/25/92 -  misc change 
Rem     rkooi      04/12/92 -  Creation 

Rem This script must be run as user SYS

REM ************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
REM COULD CAUSE INTERNAL ERRORS AND CORRUPTIONS IN THE RDBMS.
REM FOR INSTANCE, THE PSD* ROUTINES MUST NOT BE CALLED DIRECTLY
REM BY ANY CLIENT AND MUST REMAIN PRIVATE TO THIS PACKAGE.
REM ************************************************************

create or replace package dbms_lock is



  ------------
  --  OVERVIEW
  --
  --  These routines allow the user to request, convert and release locks.
  --  The locks are managed by the rdbms lock management services.  All
  --  lock ids are prepended with the 'UL' prefix so that they cannot
  --  conflict with DBMS locks.  These locks will show up in the SQL*DBA
  --  lock monitor screen and in the appropriate fixed views.
  --
  --  Deadlock detection is performed on these locks.
  --
  --  Locks are automatically released when the session terminates.
  --  It is up to the clients to agree on the use of these locks.  The
  --  lock identifier is a number in the range of 0 to 1073741823.  
  --
  --  The allocate_unique call can be used to allocate a unique lockid
  --  (in the range of 1073741824 to 1999999999) given a lock name.  This is
  --  provided since it may be easier for applications to coordinate
  --  their use of locks based on lock names rather than lock numbers.
  --  The first session to call allocate_unique with a new lock name will
  --  cause a unique lockid to be generated and stored in the
  --  dbms_lock_allocated table.  Subsequent calls (usually by other
  --  sessions) will return the lockid previously generated.  A lock name
  --  will be associated with the returned lockid for at least
  --  'expiration_secs' (defaults to 10 days) past the last call to
  --  allocate_unique with the given lock name.  After this time, the row
  --  in the dbms_lock_allocated table for this lock name may be deleted
  --  in order to recover space.  Allocate_unique performs a commit.
  --
  --  A sleep procedure is also provided which causes the caller to sleep
  --  for the given interval.


  ------------------------------------------------
  --  SUMMARY OF SERVICES PROVIDED BY THIS PACKAGE
  --
  --  allocate_unique - allocate a unique lock given a name
  --  request	      - request a lock of given mode
  --  convert	      - convert lock from one mode to another
  --  releas          - release the lock
  --  sleep	      - sleep for the specified time


  ---------------
  --  LIMITATIONS
  --
  --  The implementation does not support large numbers of locks efficiently.
  --  A few hundred locks per session should be the limit.


  ------------
  --  SECURITY
  --
  --  There may be OS-specific limits on the maximum number of total
  --  locks available.  You will need to consider this when using locks,
  --  or making this package available to users.  You may wish to only
  --  grant execute to those users or roles that you trust.  An
  --  alternative is to create a cover package for this package which
  --  limits those locks used.  Then, instead of granting execute on this
  --  package to public, grant execute on the cover package
  --  only to specific users.  A cover package might look like this:
  --
  --  create package lock_100_to_200 is
  --    nl_mode  constant integer := 1;
  --    ss_mode  constant integer := 2;
  --    sx_mode  constant integer := 3;
  --    s_mode   constant integer := 4;
  --    ssx_mode constant integer := 5;
  --    x_mode   constant integer := 6;
  --    maxwait  constant integer := 32767;
  --    function request(id in integer,
  --                     lockmode in integer default x_mode, 
  --                     timeout in integer default maxwait,
  --                     release_on_commit in boolean default FALSE)
  --      return integer;
  --    function convert(id in integer;
  --                     lockmode in integer, 
  --                     timeout in number default maxwait)
  --      return integer;
  --    function release(id in integer) return integer;
  --  end;
  --  create package body lock_100_to_200 is
  --  begin
  --    function  request(id in integer,
  --                     lockmode in integer default x_mode, 
  --                     timeout in integer default maxwait,
  --                     release_on_commit in boolean default FALSE)
  --      return integer is
  --    begin
  --      if id < 100 or id > 200 then
  --        raise_application_error(-20000,'Lock id out of range');
  --      endif;
  --      return dbms_lock.request(id, lockmode, timeout, release_on_commit);
  --    end;
  --    function convert(id in integer,
  --                     lockmode in integer, 
  --                     timeout in number default maxwait)
  --      return integer is
  --    begin
  --      if id < 100 or id > 200 then
  --        raise_application_error(-20000,'Lock id out of range');
  --      endif;
  --      return dbms_lock.convert(id, lockmode, timeout);
  --    end;
  --    function release(id in integer) return integer is
  --    begin
  --      if id < 100 or id > 200 then
  --        raise_application_error(-20000,'Lock id out of range');
  --      endif;
  --      return dbms_lock.release(id);
  --    end;
  --  end;
  --  
  --  Grant execute on the lock_100_to_200 package to those users who
  --  are allowed to use locks in the 100-200 range.  Don't grant execute
  --  on package dbms_lock to anyone.  The lock_100_200 package
  --  should be created as sys.
  --
  --  The "dbms_session.is_role_enabled" procedure could also be used
  --  in a cover package to enforce security.

  ---------------------
  --  SPECIAL CONSTANTS
  --
  nl_mode  constant integer := 1;
  ss_mode  constant integer := 2;	-- Also called 'Intended Share'
  sx_mode  constant integer := 3;	-- Also called 'Intended Exclusive'
  s_mode   constant integer := 4;
  ssx_mode constant integer := 5;
  x_mode   constant integer := 6;
  --  These are the various lock modes (nl -> "NuLl", ss -> "Sub Shared",
  --  sx -> "Sub eXclusive", s -> "Shared", ssx -> "Shared Sub eXclusive",
  --  x -> "eXclusive").
  --
  --  A sub-share lock can be used on an aggregate object to indicate that 
  --  share locks are being aquired on sub-parts of the object.  Similarly, a
  --  sub-exclusive lock can be used on an aggregate object to indicate
  --  that exclusive locks are being aquired on sub-parts of the object.  A
  --  share-sub-exclusive lock indicates that the entire aggregate object
  --  has a share lock, but some of the sub-parts may additionally have
  --  exclusive locks.
  --
  --  Lock Compatibility Rules:
  --  When another process holds "held", an attempt to get "get" does
  --  the following:
  --
  --  held  get->  NL   SS   SX   S    SSX  X
  --  NL           SUCC SUCC SUCC SUCC SUCC SUCC
  --  SS           SUCC SUCC SUCC SUCC SUCC fail
  --  SX           SUCC SUCC SUCC fail fail fail
  --  S            SUCC SUCC fail SUCC fail fail
  --  SSX          SUCC SUCC fail fail fail fail
  --  X            SUCC fail fail fail fail fail
  --
  maxwait  constant integer := 32767;
  -- maxwait means to wait forever

  ----------------------------
  -- EXCEPTIONS
  --
 
  badseconds_num NUMBER := -38148;

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure allocate_unique(lockname in varchar2, 
			    lockhandle out varchar2,
			    expiration_secs in integer default 864000);
  --  Given a name, generate a unique lockid for this lock.  This procedure
  --    always performs a 'commit'.
  --  Input parameters:
  --    lockname    
  --      name of lock to generate unique lockid for.  If this name already
  --      has been assigned a lockid, then return a handle to that lockid.
  --      Otherwise generate a new lockid and return a handle to it.
  --      WARNING: Do not use locknames beginning with 'ORA$'; these names
  --      are reserved for products supplied by Oracle Corporation.  The
  --      name can be up to 128 bytes, and is case-sensitive.
  --    expiration_secs
  --      number of seconds after an 'allocate_unique' is last performed on
  --      this lock name that this lock is subject to cleanup (i.e.,
  --      deleting from the dbms_lock_allocated table).  Defaults to 10
  --      days.
  --  Output parameters:
  --    lockhandle
  --      The actual lockid is not returned, rather a handle to it is
  --      returned.  Use this handle in subsequent calls to request,
  --      convert and release. Up to 128 bytes are returned.  A handle
  --      is used to reduce the chance that a programming error can
  --      accidentally create an incorrect but valid lockid.  This will
  --      provide better isolation between different applications that are
  --      using this package.
  --
  --      All sessions using a lockhandle returned by a call to
  --      allocate_unique using the same name will be referring to the same
  --      lock.  Different sessions may have different lockhandles for the
  --      same lock, so lockhandles should not be passed from one session
  --      to another.
  --
  --      The lockid's generated by allocate_unique are between 1073741824
  --      and 1999999999, inclusive.
  --
  --      This routine will always do a commit.
  --
  --  Errors raised:
  --    -20000, ORU-10003: Unable to find or insert lock <lockname>
  --        into catalog dbms_lock_allocated.
  
  function  request(id in integer,
                    lockmode in integer default x_mode, 
                    timeout in integer default maxwait,
                    release_on_commit in boolean default FALSE)
    return integer;
  function  request(lockhandle in varchar2,
                    lockmode in integer default x_mode, 
                    timeout in integer default maxwait,
                    release_on_commit in boolean default FALSE)
    return integer;
  --  Request a lock with the given mode. Note that this routine is
  --    overloaded based on the type of its first argument.  The
  --    appropriate routine is used based on how it is called.
  --    If a deadlock is detected, then an arbitrary session is
  --    chosen to receive deadlock status.
  --    ***NOTE*** When running both multi-threaded server (dispatcher) AND
  --    parallel server, a multi-threaded "shared server" will be
  --    bound to a session during the time that any locks are held.
  --    Therefore the "shared server" will not be shareable during this time.
  --  Input parameters:
  --    id
  --      From 0 to 1073741823.  All sessions that use the same number will
  --      be referring to the same lock. Lockids from 2000000000 to
  --      2147483647 are accepted by this routine.  Do not use these as 
  --      they are reserved for products supplied by Oracle Corporation.
  --    lockhandle
  --      Handle returned by call to allocate_unique.
  --    lockmode
  --      See lockmodes and lock compatibility table above
  --    timeout
  --      Timeout in seconds.  If the lock cannot be granted within this
  --      time period then the call returns a value of 1.  Deadlock
  --      detection is performed for all "non-small" values of timeout.
  --    release_on_commit 
  --      If TRUE, then release on commit or rollback, otherwise keep until
  --      explicitly released or until end-of-session.  If a transaction
  --      has not been started, it will be.
  --  Return value:
  --    0 - success
  --    1 - timeout
  --    2 - deadlock
  --    3 - parameter error
  --    4 - already own lock specified by 'id' or 'lockhandle'
  --    5 - illegal lockhandle
  --
  function convert(id in integer, 
                   lockmode in integer, 
                   timeout in number default maxwait)
    return integer;
  function convert(lockhandle in varchar2, 
                   lockmode in integer, 
                   timeout in number default maxwait)
    return integer;
  --  Convert a lock from one mode to another. Note that this routine is
  --    overloaded based on the type of its first argument.  The
  --    appropriate routine is used based on how it is called.
  --    If a deadlock is detected, then an arbitrary session is
  --    chosen to receive deadlock status.
  --  Input parameters:
  --    id
  --      From 0 to 1073741823.
  --    lockhandle
  --      Handle returned by call to allocate_unique.
  --    lockmode
  --      See lockmodes and lock compatibility table above.
  --    timeout
  --      Timeout in seconds.  If the lock cannot be converted within this
  --      time period then the call returns a value of 1.  Deadlock
  --      detection is performed for all "non-small" values of timeout.
  --  Return value:
  --    0 - success
  --    1 - timeout
  --    2 - deadlock
  --    3 - parameter error
  --    4 - don't own lock specified by 'id' or 'lockhandle'
  --    5 - illegal lockhandle
  --
  function release(id in integer) return integer;
  function release(lockhandle in varchar2) return integer;
  --  Release a lock previously aquired by 'request'. Note that this routine
  --    is overloaded based on the type of its argument.  The
  --    appropriate routine is used based on how it is called.
  --  Input parameters:
  --    id
  --      From 0 to 1073741823.
  --  Return value:
  --    0 - success
  --    3 - parameter error
  --    4 - don't own lock specified by 'id' or 'lockhandle'
  --    5 - illegal lockhandle
  --
  procedure sleep(seconds in number);
  --  Suspend the session for the specified period of time.
  --  Input parameters:
  --    seconds
  --      In seconds, currently the maximum resolution is in hundreths of 
  --      a second (e.g., 1.00, 1.01, .99 are all legal and distinct values).

end;
/

create or replace public synonym dbms_lock for sys.dbms_lock
/
grant execute on dbms_lock to execute_catalog_role
/
