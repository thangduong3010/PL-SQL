rem
rem $Header: rdbms/admin/dbmspipe.sql /st_rdbms_11.2.0/1 2011/06/03 10:44:32 gravipat Exp $
rem
Rem  Copyright (c) 1991, 2000 by Oracle Corporation
Rem    NAME
Rem      dbmspipe.sql - send and receive from dbms "pipes"
Rem    DESCRIPTION
Rem      Allow sessions to pass information between them through
Rem      named SGA memory "pipes"
Rem    RETURNS
Rem
Rem    NOTES
Rem      The procedural option is needed to use this facility.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     swerthei   06/09/00  - make dbms_pipe a fixed package
Rem     rtaranto   03/18/97 -  Add nchar support
Rem     mmonajje   09/16/96 -  Fixing bug 244014; Adding RESTRICT_REFERENCES pr
Rem     asurpur    04/09/96 -  Dictionary Protection Implementation
Rem     ajasuja    06/21/94 -  change purge back to procedure
Rem     ajasuja    06/09/94 -  secure pipes
Rem     adowning   03/29/94 -  merge changes from branch 1.6.710.1
Rem     adowning   02/02/94 -  split file into public / private binary files
Rem     dsdaniel   07/09/93 -  dbms_defer longifaction for async rep
Rem     rkooi      10/18/92 -  better comments
Rem     rkooi      08/20/92 -  comments and cleanup
Rem     rkooi      05/18/92 -  change comment
Rem     rkooi      04/28/92 -  change put to pack, etc.
Rem     rkooi      04/25/92 -  Creation

REM ********************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
REM COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
REM RDBMS.  SPECIFICALLY, THE PSD ROUTINES IN KKXP MUST NOT BE CALLED
REM DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
REM ********************************************************************

create or replace package dbms_pipe is

-- DE-HEAD     <- tell SED where to cut when generating fixed package

  ------------
  --  OVERVIEW
  --
  --  This package provides a DBMS "pipe" service which allows messages
  --  to be sent between sessions.
  --
  --  The metaphor is similar to UNIX pipes:  you can do
  --    dbms_pipe.send_message(<pipename>)
  --    dbms_pipe.receive_message(<pipename>)
  --  which will cause a message to be sent or received.  You do
  --    dbms_pipe.pack_message(<varchar2>|<number>|<date>)
  --  to pack an item into a static buffer (which will then be sent with
  --  the "send_message" call), and
  --    dbms_pipe.unpack_message(<varchar2>|<number>|<date>)
  --  to get an item out of the static buffer (which is filled by the
  --  "receive_message" call).
  --  Pipes can be private to a user-id - which only allows session connected
  --  under the same user-id or stored procedure owned by the user-id to read
  --  write to the pipe.  Pipes could be public - and all database users with
  --  execute privilege on dbms_pipe and knowledge of the pipe can read or
  --  write to the pipe.
  --
  --  Pipes operate independently of transactions.  They also operate
  --  asynchronously.  There can be multiple readers and writers of the
  --  same pipe.
  --
  --  Pipes only operate between sessions in the same instance.
  --
  --  Pipes can be explicitly created using
  --    dbms_pipe.create_pipe(<pipename>)
  --  and removed using
  --    dbms_pipe.remove_pipe(<pipename>)
  --  A pipe created using the explicit create command should be removed
  --  using the remove function.  A pipe can also be created implicitly.
  --  Pipes automatically come into existence the first time they are
  --  referenced.  They effectively disappear when they contain no more
  --  data (some overhead remains in the SGA until it gets aged out).
  --  Pipes take up space in the SGA (see "maxpipesize" parameter to
  --  "send_message").


  --------
  --  USES
  --
  --  The pipe functionality has several potential applications:
  --
  --    o External service interface.  You can provide the ability to
  --      communicate with (user-written) services that are external to the
  --      RDBMS.  This can be done in a (effectively) multi-threaded manner
  --      so that several instances of the service can be executing
  --      simultaneously. Additionally, the services are available
  --      asynchronously - the requestor of the service need not block
  --      awaiting a reply.  The requestor can check (with or without
  --      timeout) at a later time.  The service can be written in any
  --      of the 3GL languages that ORACLE supports, not just C.  See
  --      example below.
  --    o Independent transactions.  The pipe can be used to communicate
  --      to a separate session which can perform an operation in an
  --      independent transaction (such as logging an attempted security
  --      violation detected by a trigger).
  --    o Alerters (non-transactional).  You can post another process
  --      without requiring the waiting process to poll.  If an "after-row"
  --      or "after-statement" trigger were to alert an application, then
  --      the application would treat this alert as an indication that
  --      the data probably changed.  The application would then go read
  --      the data to get the current value.  Since this is an "after"
  --      trigger, the application would want to do a "select for update"
  --      to make sure it read the correct data.
  --    o Debugging.  Triggers and/or stored procedures can send debugging
  --      information to a pipe.  Another session can keep reading out
  --      of the pipe and displaying it on the screen or writing it
  --      out to a file.
  --    o Concentrator. Useful for multiplexing large numbers of users
  --      over a fewer number of network connections, or improving
  --      performance by concentrating several user-transactions into
  --      one dbms-transaction.


  ------------
  --  SECURITY
  --
  --  Security can be achieved by use of 'grant execute' on the dbms_pipe
  --  package, by creating a pipe using the 'private' parameter in the create
  --  function and by writing cover packages that only expose particular
  --  features or pipenames to particular users or roles.


  ------------
  --  EXAMPLES
  --
  --  External service interface
  ------------------------------
  --
  --  Put the user-written 3GL code into an OCI or Precompiler program.
  --  The program connects to the database and executes PL/SQL code to read
  --  its request from the pipe, computes the result, and then executes
  --  PL/SQL code to send the result on a pipe back to the requestor.
  --  Below is an example of a stock service request.
  --
  --  The recommended sequence for the arguments to pass on the pipe
  --  for all service requests is
  --
  --      protocol_version      varchar2        - '1', 10 bytes or less
  --      returnpipe            varchar2        - 30 bytes or less
  --      service               varchar2        - 30 bytes or less
  --      arg1                  varchar2/number/date
  --         ...
  --      argn                  varchar2/number/date
  --
  --  The recommended format for returning the result is
  --
  --      success               varchar2        - 'SUCCESS' if OK,
  --                                              otherwise error message
  --      arg1                  varchar2/number/date
  --         ...
  --      argn                  varchar2/number/date
  --
  --
  --  The "stock price request server" would do, using OCI or PRO* (in
  --  pseudo-code):
  --
  --    <loop forever>
  --      begin dbms_stock_server.get_request(:stocksymbol); end;
  --      <figure out price based on stocksymbol (probably from some radio
  --            signal), set error if can't find such a stock>
  --      begin dbms_stock_server.return_price(:error, :price); end;
  --
  --  A client would do:
  --
  --    begin :price := stock_request('YOURCOMPANY'); end;
  --
  --  The stored procedure, dbms_stock_server, which is called by the
  --  "stock price request server" above is:
  --
  --    create or replace package dbms_stock_server is
  --      procedure get_request(symbol out varchar2);
  --      procedure return_price(errormsg in varchar2, price in varchar2);
  --    end;
  --
  --    create  or replace package body dbms_stock_server is
  --      returnpipe    varchar2(30);
  --
  --      procedure returnerror(reason varchar2) is
  --        s integer;
  --      begin
  --        dbms_pipe.pack_message(reason);
  --        s := dbms_pipe.send_message(returnpipe);
  --        if s <> 0 then
  --          raise_application_error(-20000, 'Error:' || to_char(s) ||
  --            ' sending on pipe');
  --        end if;
  --      end;
  --
  --      procedure get_request(symbol out varchar2) is
  --        protocol_version varchar2(10);
  --        s                  integer;
  --        service            varchar2(30);
  --      begin
  --        s := dbms_pipe.receive_message('stock_service');
  --        if s <> 0 then
  --          raise_application_error(-20000, 'Error:' || to_char(s) ||
  --            'reading pipe');
  --        end if;
  --        dbms_pipe.unpack_message(protocol_version);
  --        if protocol_version <> '1' then
  --          raise_application_error(-20000, 'Bad protocol: ' ||
  --            protocol_version);
  --        end if;
  --        dbms_pipe.unpack_message(returnpipe);
  --        dbms_pipe.unpack_message(service);
  --        if service != 'getprice' then
  --          returnerror('Service ' || service || ' not supported');
  --        end if;
  --        dbms_pipe.unpack_message(symbol);
  --      end;
  --
  --      procedure return_price(errormsg in varchar2, price in varchar2) is
  --        s integer;
  --      begin
  --        if errormsg is null then
  --          dbms_pipe.pack_message('SUCCESS');
  --          dbms_pipe.pack_message(price);
  --        else
  --          dbms_pipe.pack_message(errormsg);
  --        end if;
  --        s := dbms_pipe.send_message(returnpipe);
  --        if s <> 0 then
  --          raise_application_error(-20000, 'Error:'||to_char(s)||
  --            ' sending on pipe');
  --        end if;
  --      end;
  --    end;
  --
  --
  --  The procedure called by the client is:
  --
  --    create or replace function stock_request (symbol varchar2)
  --        return varchar2 is
  --      s        integer;
  --      price    varchar2(20);
  --      errormsg varchar2(512);
  --    begin
  --      dbms_pipe.pack_message('1');  -- protocol version
  --      dbms_pipe.pack_message(dbms_pipe.unique_session_name); -- return pipe
  --      dbms_pipe.pack_message('getprice');
  --      dbms_pipe.pack_message(symbol);
  --      s := dbms_pipe.send_message('stock_service');
  --      if s <> 0 then
  --        raise_application_error(-20000, 'Error:'||to_char(s)||
  --          ' sending on pipe');
  --      end if;
  --      s := dbms_pipe.receive_message(dbms_pipe.unique_session_name);
  --      if s <> 0 then
  --        raise_application_error(-20000, 'Error:'||to_char(s)||
  --          ' receiving on pipe');
  --      end if;
  --      dbms_pipe.unpack_message(errormsg);
  --      if errormsg <> 'SUCCESS' then
  --        raise_application_error(-20000, errormsg);
  --      end if;
  --      dbms_pipe.unpack_message(price);
  --      return price;
  --    end;
  --
  --  You would typically only grant execute on 'dbms_stock_service' to
  --  the stock service application server, and would only grant execute
  --  on 'stock_request' to those users allowed to use the service.


  ---------------------
  --  SPECIAL CONSTANTS
  --
  maxwait   constant integer := 86400000; /* 1000 days */
  --  The maximum time to wait attempting to send or receive a message


  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure pack_message(item in varchar2 character set any_cs);
  pragma restrict_references(pack_message,WNDS,RNDS);
  procedure pack_message(item in number);
  pragma restrict_references(pack_message,WNDS,RNDS);
  procedure pack_message(item in date);
  pragma restrict_references(pack_message,WNDS,RNDS);
  procedure pack_message_raw(item in raw);
  pragma restrict_references(pack_message_raw,WNDS,RNDS);
  procedure pack_message_rowid(item in rowid);
  pragma restrict_references(pack_message_rowid,WNDS,RNDS);
  --  Pack an item into the message buffer
  --  Input parameters:
  --    item
  --      Item to pack into the local message buffer.
  --  Exceptions:
  --    ORA-06558 generated if message buffer overflows (currently 4096
  --    bytes).  Each item in the buffer takes one byte for the type,
  --    two bytes for the length, plus the actual data.  There is also one
  --    byte needed to terminate the message.
  --
  procedure unpack_message(item out varchar2 character set any_cs);
  pragma restrict_references(unpack_message,WNDS,RNDS);
  procedure unpack_message(item out number);
  pragma restrict_references(unpack_message,WNDS,RNDS);
  procedure unpack_message(item out date);
  pragma restrict_references(unpack_message,WNDS,RNDS);
  procedure unpack_message_raw(item out raw);
  pragma restrict_references(unpack_message_raw,WNDS,RNDS);
  procedure unpack_message_rowid(item out rowid);
  pragma restrict_references(unpack_message_rowid,WNDS,RNDS);
  --  Unpack an item from the local message buffer
  --  Output parameters:
  --    item
  --      The argument to receive the next unpacked item from the local
  --      message buffer.
  --  Exceptions:
  --    ORA-06556 or 06559 are generated if the buffer contains
  --    no more items, or if the item is not of the same type as that
  --    requested (see 'next_item_type' below).
  --
  function next_item_type return integer;
  pragma restrict_references(next_item_type,WNDS,RNDS);
  --  Get the type of the next item in the local message buffer
  --  Return value:
  --    Type of next item in buffer:
  --        0    no more items
  --        9    varchar2
  --        6    number
  --       11    rowid
  --       12    date
  --       23    raw
  --
  function create_pipe(pipename in varchar2,
                  maxpipesize in integer default 8192,
                  private in boolean default TRUE,
                  global in boolean default FALSE)
    return integer;
  pragma restrict_references(create_pipe,WNDS,RNDS);
  --  Create an empty pipe with the given name.
  --  Input parameters:
  --    pipename
  --      Name of pipe to be created.  WARNING: Do not use pipe names
  --      beginning with 'ORA$'.  These are reserved for use by procedures
  --      provided by Oracle Corporation.  Pipename should not be longer than
  --      128 bytes, and is case_insensitive.  At this time, the name cannot
  --      contain NLS characters.
  --    maxpipesize
  --      Maximum allowed size for the pipe.  The total size of all the
  --      messages on the pipe cannot exceed this amount.  The maxpipesize
  --      for a pipe becomes part of the pipe and persists for the lifetime
  --      of the pipe.  Callers of send_message with larger values will
  --      cause the maxpipesize to be increased.  Callers with a smaller
  --      value will just use the larger value.  The specification of
  --      maxpipesize here allows us to avoid its use in future send_message
  --      calls.
  --    private
  --      Boolean indicating whether the pipe will be private - and for the
  --      use of the creating user-id, or public.  A private pipe can be used
  --      directly through calls to this package by sessions connected to the
  --      database as the same user as the one that created the pipe.  It can
  --      also be used via stored procedures owned by the user that created
  --      the pipe.  The procedure may be executed by anyone with execute
  --      privilege on it.  A public pipe can be accessed by anyone who has
  --      knowledge of it and execute privilege on dbms_pipe.
  --  Return values:
  --    0 - Success.  This is returned even if the pipe had been created in
  --        mode that permits its use by the user executing the create call.
  --        If a pipe already existed, it is not emptied.
  --  Exceptions:
  --    Null pipe name.
  --    Permission error.  Pipe with the same name already exists and
  --      you are not allowed to use it.
  --
  function remove_pipe(pipename in varchar2)
    return integer;
  pragma restrict_references(remove_pipe,WNDS,RNDS);
  --  Remove the named pipe.
  --  Input Parameters:
  --    pipename
  --      Name of pipe to remove.
  --  Return value:
  --    0 - Success. Calling remove on a pipe that does not exist returns 0.
  --  Exceptions:
  --    Null pipe name.
  --    Permission error.  Insufficient privilege to remove pipe.  The
  --      pipe was created and is owned by someone else.
  --
  function send_message(pipename in varchar2,
                        timeout in integer default maxwait,
                        maxpipesize in integer default 8192)
    return integer;
  pragma restrict_references(send_message,WNDS,RNDS);
  --  Send a message on the named pipe.  The message is contained in the
  --    local message buffer which was filled with calls to 'pack_message'.
  --    A pipe could have been created explicitly using 'create_pipe', or
  --    it will be created implicitly.
  --  Input parameters:
  --    pipename
  --      Name of pipe to place the message on.  The message is copied
  --      from the local buffer which can be filled by the "pack_message"
  --      routine.  WARNING:  Do not use pipe names beginning with 'ORA$'.
  --      These names are reserved for use by procedures provided by
  --      Oracle Corporation.  Pipename should not be longer than 128 bytes,
  --      and is case_insensitive.  At this time, the name cannot
  --      contain NLS characters.
  --    timeout
  --      Time to wait while attempting to place a message on a pipe, in
  --      seconds (see return codes below).
  --    maxpipesize
  --      Maximum allowed size for the pipe.  The total size of all the
  --      messages on the pipe cannot exceed this amount.  If this message
  --      would exceed this amount the call will block.  The maxpipesize
  --      for a pipe becomes part of the pipe and persists for the lifetime
  --      of the pipe.  Callers of send_message with larger values will
  --      cause the maxpipesize to be increased.  Callers with a smaller
  --      value will just use the larger value.  The specification of
  --      maxpipesize here allows us to avoid the use of a "open_pipe" call.
  --  Return value:
  --    0 - Success
  --    1 - Timed out (either because can't get lock on pipe or pipe stays
  --        too full)
  --    3 - Interrupted
  --  Exceptions:
  --    Null pipe name.
  --    Permission error.  Insufficient privilege to write to the pipe.
  --      The pipe is private and owned by someone else.
  function receive_message(pipename in varchar2,
                           timeout in integer default maxwait)
    return integer;
  pragma restrict_references(receive_message,WNDS,RNDS);
  --  Receive a message from the named pipe.  Copy the message into the
  --    local message buffer.  Use 'unpack_message' to access the
  --    individual items in the message.  The pipe can be created explicitly
  --    using the 'create_pipe' function or it will be created implicitly.
  --  Input parameters:
  --    pipename
  --      Name of pipe from which to retrieve a message.  The message is
  --      copied into a local buffer which can be accessed by the
  --      "unpack_message" routine.  WARNING:  Do not use pipe names
  --      beginning with 'ORA$'.  These names are reserved for use by
  --      procedures provided by Oracle Corporation. Pipename should not be
  --      longer than 128 bytes, and is case-insensitive.  At this time,
  --      the name cannot contain NLS characters.
  --    timeout
  --      Time to wait for a message.  A timeout of 0 allows you to read
  --      without blocking.
  --  Return value:
  --    0 - Success
  --    1 - Timed out
  --    2 - Record in pipe too big for buffer (should not happen).
  --    3 - Interrupted
  --  Exceptions:
  --    Null pipe name.
  --    Permission error.  Insufficient privilege to remove the record
  --      from the pipe.  The pipe is owned by someone else.
  procedure reset_buffer;
  pragma restrict_references(reset_buffer,WNDS,RNDS);
  --  Reset pack and unpack positioning indicators to 0.  Generally this
  --    routine is not needed.
  --
  procedure purge(pipename in varchar2);
  pragma restrict_references(purge,WNDS,RNDS);
  --  Empty out the named pipe.  An empty pipe is a candidate for LRU
  --    removal from the SGA, therefore 'purge' can be used to free all
  --    memory associated with a pipe.
  --  Input Parameters:
  --    pipename
  --      Name of pipe from which to remove all messages.  The local
  --      buffer may be overwritten with messages as they are discarded.
  --      Pipename should not be longer than 128 bytes, and is
  --      case-insensitive.
  --  Exceptions:
  --    Permission error if pipe belongs to another user.
  --
  function unique_session_name return varchar2;
  pragma restrict_references(unique_session_name,WNDS,RNDS,WNPS);
  --  Get a name that is unique among all sessions currently connected
  --    to this database.  Multiple calls to this routine from the same
  --    session will always return the same value.
  --  Return value:
  --    A unique name.  The returned name can be up to 30 bytes.
  --

  pragma TIMESTAMP('2000-06-09:14:30:00');

end;

-- CUT_HERE    <- tell sed where to chop off the rest

/

create or replace public synonym dbms_pipe for sys.dbms_pipe
/
grant execute on dbms_pipe to execute_catalog_role
/
