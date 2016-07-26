rem
rem $Header: rdbms/admin/userlock.sql /st_rdbms_11.2.0/1 2011/07/11 11:11:06 celsbern Exp $ 
rem
rem Copyright (c) 1991 by Oracle Corporation 
rem  NAME
rem    userlock.sql - locking routines available for user-side client use
rem  DESCRIPTION
rem    These routines allow the user to request, convert and release locks.
rem    The locks are managed by the rdbms lock management services.  All
rem    lock ids are prepended with the 'UL' prefix so that they cannot
rem    conflict with DBMS locks.
rem  RETURNS
rem
rem  NOTES
rem    It is up to the clients to agree on the use of these locks.  The lock
rem    identifier is a number in the range of 1 to approx. 2 billion.  
rem    Locks persist for the session and any outstanding locks are released
rem    when the session terminates.
rem
rem  MODIFIED   (MM/DD/YY)
Rem     celsbern   07/05/11  - Backport celsbern_bug-12584760 from
Rem                            st_rdbms_11.2.0
Rem     gviswana   05/25/01  - CREATE OR REPLACE SYNONYM
Rem     mmoore     10/02/92 -  change pls_integer to binary_integer 
Rem     jwijaya    06/26/92 -  fix psdlgt call
Rem     tpystyne   06/02/92 -  create public synonym 
Rem     rkooi      05/30/92 -  fix maxwait 
rem   rkooi      05/06/91 - change name to user_lock 
rem   rkooi      04/29/91 - don't externalize 'maxholders' arg yet 
rem   mmoore     04/23/91 - Creation 

drop package user_lock
/

create package user_lock is

  --  DESCRIPTION
  --    These routines allow the user to request, convert and release locks.
  --    The locks are managed by the rdbms lock management services.  All
  --    lock ids are prepended with the 'UL' prefix so that they cannot
  --    conflict with DBMS locks.  A sleep procedure is also provided which
  --    causes the caller to sleep for the given interval (expressed in
  --    tens of milliseconds.
  --
  --  NOTES
  --    It is up to the clients to agree on the use of these locks.  The lock
  --    identifier is a number in the range of 1 to approx. 2 billion.  
  --    Locks persist for the session and any outstanding locks are released
  --    when the session terminates.

  ----------------------------
  -- EXCEPTIONS
  --
 
  badseconds_num NUMBER := -38148;


  function  request(id number, lockmode number, timeout number, global number)
            return number;
  -- Returns:
  --    0 success
  --    1 timeout
  --    2 deadlock
  --    3 parameter error

  function convert(id number, lockmode number, timeout number) return number;
  -- Returns:
  --    0 success
  --    1 timeout
  --    2 deadlock
  --    3 parameter error
  --    4 don't own lock 'id'

  function release(id number) return number;
  -- Returns:
  --    0 success
  --    4 don't own lock 'id'

  procedure sleep(tens_of_millisecs number);

  -- PARAMETERS:

  -- lockid - this can be in the range of 0 to about 2 billion

  -- lockmodes
  nl_mode  constant number := 1;
  ss_mode  constant number := 2;
  sx_mode  constant number := 3;
  s_mode   constant number := 4;
  ssx_mode constant number := 5;
  x_mode   constant number := 6;

  --  LOCK COMPATIBILITY RULES:
  --
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

  -- global means multi-instance (parallel server)
  local    constant number := 0;
  global   constant number := 1;

  -- maxwait means wait forever
  maxwait  constant number := 32767;
end;
/

create package body user_lock is

  procedure psdlgt(id binary_integer, lockmode binary_integer, 
                   maxholders binary_integer, timeout binary_integer, 
                   rel_on_commit binary_integer, global binary_integer,
                   status in out binary_integer);
    pragma interface (C, psdlgt);
  procedure psdlcv(id binary_integer, lockmode binary_integer,
	  	   maxholders binary_integer, timeout binary_integer,
		   status in out binary_integer);
    pragma interface (C, psdlcv);
  procedure psdlrl(id binary_integer, status in out binary_integer);
    pragma interface (C, psdlrl);
  procedure psdwat(tens_of_millisecs binary_integer);
    pragma interface (C, psdwat);

  function  request(id number, lockmode number, timeout number, global number)
	    return number is
  arg1    binary_integer;
  arg2    binary_integer;
  arg3    binary_integer;
  arg4    binary_integer;
  arg5    binary_integer;
  status  binary_integer;
  begin
    arg1 := id;
    arg2 := lockmode;
    arg3 := 0;
    arg4 := timeout;
    arg5 := global;
    /* this package does not support release_on_commit - so just enter 0 */
    psdlgt(arg1, arg2, arg3, arg4, 0, arg5, status);
    return(status);
  end;

  function convert(id number, lockmode number, timeout number) return number is
    arg1   binary_integer;
    arg2   binary_integer;
    arg3   binary_integer;
    arg4   binary_integer;
    status binary_integer;
  begin
    arg1 := id;
    arg2 := lockmode;
    arg3 := 0;
    arg4 := timeout;
    psdlcv(arg1, arg2, arg3, arg4, status);
    return (status);
  end;

  function release(id number) return number is
    arg1   binary_integer;
    status binary_integer;
  begin
    arg1 := id;
    psdlrl(arg1, status);
    return (status);
  end;

  procedure sleep(tens_of_millisecs number) is
    arg1   binary_integer;
  begin
    arg1 := tens_of_millisecs;
    /*the wait time needs to be positive - raise error if it is not*/
    if arg1 < 0 then 
       dbms_sys_error.raise_system_error(user_lock.badseconds_num);
    else psdwat(arg1);
    end if;
  end;

end;
/

create or replace public synonym user_lock for sys.user_lock
/
grant execute on user_lock to public
/
