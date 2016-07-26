Rem
Rem $Header: rdbms/admin/dbmssess.sql /st_rdbms_11.2.0/1 2012/02/23 15:01:00 jmuller Exp $
Rem
Rem dbmssess.sql
Rem
Rem Copyright (c) 2005, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmssess.sql - DBMS_SESSION
Rem
Rem    DESCRIPTION
Rem    DBMS_SESSION - alter session commands
Rem
Rem    NOTES
Rem    DBMS_SESSION - this package was originally located in dbmsutil.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jmuller     02/14/12 - Backport jmuller_bug-11664193 from main
Rem    jmuller     06/06/11 - Fix bug 11664193: support
Rem                           package_memory_utilization > 2G
Rem    achoi       12/16/08 - bug7576540
Rem    dbronnik    02/13/08 - ER 6805576: psd_get_package_memory_utilization
Rem    rcolle      04/16/07 - change session_trace_enable to accept plan_stat
Rem    dalpern     10/23/06 - dbms_session.set_edition
Rem    achoi       10/28/05 - performance related comment
Rem    lvbcheng    08/17/05 - lvbcheng_split_dbms_util
Rem    lvbcheng    07/29/05 - moved here from dbmsutil.sql
Rem    gviswana    10/24/01 - dbms_ddl, dbms_session: AUTHID CURRENT_USER
Rem    kmuthukk    03/19/01 - add dbms_session.modify_package_state
Rem

Rem ********************************************************************
Rem THESE PACKAGES MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
Rem COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
Rem RDBMS.  SPECIFICALLY, THE PSD* AND EXECUTE_SQL ROUTINES MUST NOT BE
Rem CALLED DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
Rem ********************************************************************

create or replace package dbms_session AUTHID CURRENT_USER is
  ------------
  --  OVERVIEW
  --
  --  This package provides access to SQL "alter session" statements, and
  --  other session information from, stored procedures.
  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure set_role(role_cmd varchar2);
  --  Equivalent to SQL "SET ROLE ...".
  --  Input arguments:
  --    role_cmd
  --      This text is appended to "set role " and then executed as SQL.
  procedure set_sql_trace(sql_trace boolean);
  --  Equivalent to SQL "ALTER SESSION SET SQL_TRACE ..."
  --  Note:
  --   Using "execute immediate 'alter session'" has better performance
  --   than using dbms_session.set_sql_trace.
  --  Input arguments:
  --    sql_trace
  --      TRUE or FALSE.  Turns tracing on or off.
  procedure set_nls(param varchar2, value varchar2);
  --  Equivalent to SQL "ALTER SESSION SET <nls_parameter> = <value>"
  --  Note:
  --   Using "execute immediate 'alter session'" has better performance
  --   than using dbms_session.set_nls. Further, when setting multiple 
  --   parameters, EXEC IMMEDIATE allows user to set all of them in one 
  --   statement, which is much more efficient than calling 
  --   dbms_session.set_nls in multiple statements.
  --  Input arguments:
  --    param
  --      The NLS parameter. The parameter name must begin with 'NLS'.
  --    value
  --      The value to set the parameter to.  If the parameter is a
  --      text literal then it will need embedded single-quotes.  For
  --      example "set_nls('nls_date_format','''DD-MON-YY''')"
  procedure close_database_link(dblink varchar2);
  --  Equivalent to SQL "ALTER SESSION CLOSE DATABASE LINK <name>"
  --  Input arguments:
  --    name
  --      The name of the database link to close.
  procedure reset_package;
  --  Deinstantiate all packages in this session.  In other words, free
  --    all package state.  This is the situation at the beginning of
  --    a session.

  --------------------------------------------------------------------
  --  action_flags (bit flags) for MODIFY_PACKAGE_STATE  procedure ---
  --------------------------------------------------------------------
  FREE_ALL_RESOURCES   constant PLS_INTEGER := 1;
  REINITIALIZE         constant PLS_INTEGER := 2;
  
  procedure modify_package_state(action_flags IN PLS_INTEGER);
  --  The MODIFY_PACKAGE_STATE procedure can be used to perform
  --  various actions (as specified by the 'action_flags' parameter)
  --  on the session state of ALL PL/SQL program units active in the
  --  session. This takes effect only after the PL/SQL call that
  --  made the current invokation finishes running.
  --
  --  Parameter(s):
  --   action_flags:
  --     Determines what action is taken on the program units.
  --     The following action_flags are supported:
  --
  --     * DBMS_SESSION.FREE_ALL_RESOURCES:
  --         This frees all the memory associated with each of the
  --         previously run PL/SQL programs from the session, and,
  --         consequently, clears the current values of any package
  --         globals and closes any cached cursors. On subsequent use,
  --         the PL/SQL program units are re-instantiated and package
  --         globals are reinitialized. This is essentially the
  --         same as DBMS_SESSION.RESET_PACKAGE() interface.
  --
  --     * DBMS_SESSION.REINITIALIZE:
  --         In terms of program semantics, the DBMS_SESSION.REINITIALIZE
  --         flag is similar to the DBMS_SESSION.FREE_ALL_RESOURCES flag
  --         in that both have the effect of re-initializing all packages.
  --
  --         However, DBMS_SESSION.REINITIALIZE should exhibit much better
  --         performance than the DBMS_SESSION.FREE_ALL_RESOURCES option
  --         because:
  -- 
  --           - packages are reinitialized without actually being freed
  --           and recreated from scratch. Instead the package memory gets
  --           reused.
  --
  --           - any open cursors are closed, semantically speaking. However,
  --           the cursor resource is not actually freed. It is simply
  --           returned to the PL/SQL cursor cache. And more importantly,
  --           the cursor cache is not flushed. Hence, cursors
  --           corresponding to frequently accessed static SQL in PL/SQL
  --           will remain cached in the PL/SQL cursor cache and the
  --           application will not incur the overhead of opening, parsing
  --           and closing a new cursor for those statements on subsequent use.
  --
  --           - the session memory for PL/SQL modules without global state
  --           (such as types, stored-procedures) will not be freed and
  --           recreated.
  --
  --
  --  Usage Example:
  --    begin
  --      dbms_session.modify_package_state(DBMS_SESSION.REINITIALIZE);
  --    end;
  --
  
  function unique_session_id return varchar2;
  pragma restrict_references(unique_session_id,WNDS,RNDS,WNPS);
  --  Return an identifier that is unique for all sessions currently
  --    connected to this database.  Multiple calls to this function 
  --    during the same session will always return the same result.
  --  Output arguments:
  --    unique_session_id
  --      can return up to 24 bytes.
  function is_role_enabled(rolename varchar2) return boolean;
  --  Determine if the named role is enabled for this session.
  --  Input arguments:
  --    rolename
  --      Name of the role.
  --  Output arguments:
  --    is_role_enabled
  --      TRUE or FALSE depending on whether the role is enabled.
  function is_session_alive(uniqueid varchar2) return boolean;
  --  Determine if the specified session is alive.
  --  Input arguments:
  --    uniqueid
  --      Uniqueid of the session.
  --  Output arguments:
  --    is_session_alive
  --      TRUE or FALSE depending on whether the session is alive.
  procedure set_close_cached_open_cursors(close_cursors boolean);
  --  Equivalent to SQL "ALTER SESSION SET CLOSE_CACHED_OPEN_CURSORS ..."
  --  Input arguments:
  --    close_cursors
  --      TRUE or FALSE.  Turns close_cached_open_cursors on or off.
  procedure free_unused_user_memory;
  --  Procedure for users to reclaim unused memory after performing operations
  --  requiring large amounts of memory (where large is >100K).  Note that 
  --  this procedure should only be used in cases where memory is at a 
  --  premium.  
  --
  --  Examples operations using lots of memory are:
  -- 
  --     o  large sorts where entire sort_area_size is used and
  --        sort_area_size is hundreds of KB
  --     o  compiling large PL/SQL packages/procedures/functions
  --     o  storing hundreds of KB of data within PL/SQL indexed tables
  --
  --  One can monitor user memory by tracking the statistics 
  --  "session uga memory" and "session pga memory" in the 
  --  v$sesstat/v$statname fixed views.  Monitoring these statistics will
  --  also show how much memory this procedure has freed.
  --
  --  The behavior of this procedure depends upon the configuration of the 
  --  server operating on behalf of the client:
  --  
  --     o  dedicated server - returns unused PGA memory and session memory
  --          to the OS (session memory is allocated from the PGA in this 
  --          configuration)
  --     o  MTS server       - returns unused session memory to the
  --          shared_pool (session memory is allocated from the shared_pool
  --          in this configuration)
  --  
  --  In order to free memory using this procedure, the memory must 
  --  not be in use.  
  -- 
  --  Once an operation allocates memory, only the same type of operation can 
  --  reuse the allocated memory.  For example, once memory is allocated 
  --  for sort, even if the sort is complete and the memory is no longer 
  --  in use, only another sort can reuse the sort-allocated memory.  For
  --  both sort and compilation, after the operation is complete, the memory
  --  is no longer in use and the user can invoke this procedure to free the
  --  unused memory. 
  --
  --  An indexed table implicitly allocates memory to store values assigned
  --  to the indexed table's elements.  Thus, the more elements in an indexed 
  --  table, the more memory the RDBMS allocates to the indexed table.  As 
  --  long as there are elements within the indexed table, the memory
  --  associated with an indexed table is in use. 
  -- 
  --  The scope of indexed tables determines how long their memory is in use. 
  --  Indexed tables declared globally are indexed tables declared in packages
  --  or package bodies.  They allocate memory from session memory.  For an
  --  indexed table declared globally, the memory will remain in use
  --  for the lifetime of a user's login (lifetime of a user's session),
  --  and is freed after the user disconnects from ORACLE.
  --     
  --  Indexed tables declared locally are indexed tables declared within
  --  functions, procedures, or anonymous blocks.  These indexed tables
  --  allocate memory from PGA memory.  For an indexed table declared 
  --  locally, the memory will remain in use for as long as the user is still
  --  executing the procedure, function, or anonymous block in which the 
  --  indexed table is declared.  After the procedure, function, or anonymous
  --  block is finished executing, the memory is then available for other 
  --  locally declared indexed tables to use (i.e., the memory is no longer
  --  in use).
  --  
  --  Assigning an uninitialized, "empty," indexed table to an existing index
  --  table is a method to explicitly re-initialize the indexed table and the
  --  memory associated with the indexed table.  After this operation,
  --  the memory associated with the indexed table will no longer be in use, 
  --  making it available to be freed by calling this procedure.  This method
  --  is particularly useful on indexed tables declared globally which can grow
  --  during the lifetime of a user's session, as long as the user no 
  --  longer needs the contents of the indexed table.  
  --  
  --  The memory rules associated with an indexed table's scope still apply; 
  --  this method and this procedure, however, allow users to 
  --  intervene and to explictly free the memory associated with an
  --  indexed table. 
  -- 
  --  The PL/SQL fragment below illustrates the method and the use 
  --  of procedure free_unused_user_memory.
  --
  --  create package foobar
  --     type number_idx_tbl is table of number indexed by binary_integer;
  -- 
  --     store1_table  number_idx_tbl;     --  PL/SQL indexed table
  --     store2_table  number_idx_tbl;     --  PL/SQL indexed table
  --     store3_table  number_idx_tbl;     --  PL/SQL indexed table
  --     ...
  --  end;            --  end of foobar
  --
  --  declare
  --     ...
  --     empty_table   number_idx_tbl;     --  uninitialized ("empty") version
  --  
  --  begin
  --     for i in 1..1000000 loop
  --       store1_table(i) := i;           --  load data
  --     end loop;
  --     ...
  --     store1_table := empty_table;      --  "truncate" the indexed table
  --     ... 
  --     -
  --     dbms_session.free_unused_user_memory;  -- give memory back to system
  --  
  --     store1_table(1) := 100;           --  index tables still declared;
  --     store2_table(2) := 200;           --  but truncated.
  --     ...
  --  end;
  -- 
  --  Performance Implication: 
  --     This routine should be used infrequently and judiciously.
  --       
  --  Input arguments:
  --     n/a
  procedure set_context(namespace varchar2, attribute varchar2, value varchar2,
                        username varchar2 default null, 
                        client_id varchar2 default null);
  --  Input arguments:
  --    namespace
  --      Name of the namespace to use for the application context
  --    attribute
  --      Name of the attribute to be set
  --    value
  --      Value to be set
  --    username
  --      username attribute for application context . default value is null. 
  --    client_id
  --      client identifier that identifies a user session for which we need
  --      to set this context.
  --
  --
  procedure set_identifier(client_id varchar2);
  --    Input parameters: 
  --    client_id
  --      client identifier being set for this session .
  --
  --
  procedure clear_context(namespace varchar2, client_id varchar2 default null, 
                          attribute varchar2 default null);
  -- Input parameters:
  --   namespace
  --     namespace where the application context is to be cleared 
  --   client_id 
  --      all ns contexts associated with this client id are cleared.
  --   attribute
  --     attribute to clear . 
  
  procedure clear_all_context(namespace varchar2);
  --
  -- Input parameters:
  --    namespace
  --      namespace where the application context is to be cleared
  --
  procedure clear_identifier;
  -- Input parameters:
  --   none
  --
  TYPE AppCtxRecTyp IS RECORD ( namespace varchar2(30), attribute varchar2(30),
      value varchar2(4000));
  TYPE AppCtxTabTyp IS TABLE OF AppCtxRecTyp INDEX BY BINARY_INTEGER;
  procedure list_context(list OUT AppCtxTabTyp, lsize OUT number);
  --  Input arguments:
  --    list
  --      buffer to store a list of application context set in current
  --      session
  --  Output arguments:
  --    list
  --      contains a list of of (namespace,attribute,values) set in current
  --      session
  --    size
  --      returns the number of entries in the buffer returned
  procedure switch_current_consumer_group(new_consumer_group IN VARCHAR2,
                                          old_consumer_group OUT VARCHAR2,
                                          initial_group_on_error IN BOOLEAN);
  -- Input arguments:
  -- new_consumer_group
  --    name of consumer group to switch to
  -- old_consumer_group
  --    name of the consumer group just switched out from
  -- initial_group_on_error
  --   If TRUE, sets the current consumer group of the invoker to his/her 
  --   initial consumer group in the event of an error.
  -- 
  procedure session_trace_enable(waits IN BOOLEAN DEFAULT TRUE,
                                 binds IN BOOLEAN DEFAULT FALSE,
                                 plan_stat IN VARCHAR2 DEFAULT NULL);
  --  Enables SQL trace for the session. Supports waits and binds
  --  specifications, which makes it more general than set_sql_trace. Using 
  --  this procedure is a preferred way in the future.
  --  Input parameters:
  --    waits
  --      If TRUE, wait information will be present in the trace
  --    binds
  --      If TRUE, bind information will be present in the trace
  --    plan_stat 
  --      Frequency at which we dump row source statistics.
  --      Value should be 'never', 'first_execution'
  --      (equivalent to NULL) or 'all_executions'.
  procedure session_trace_disable;
  --  Disables SQL trace for the session, which has been enabled by the
  --  session_trace_enable procedure
  -- Input parameters:
  --   none
  --
  procedure set_edition_deferred(edition varchar2);
  -- Requests a switch to the specified edition.  The switch takes
  -- effect at the end of the current client call.
  --
  -- Input parameters:
  --   edition
  --     The name of the edition to switch to.  The contents of the
  --     string are processed as a SQL identifier; double-quotes must
  --     surround the remainder of the string if special characters or
  --     lower case characters are present in the edition's actual
  --     name, and if double-quotes are not used the contents will be
  --     uppercased.  The caller must have USE privilege on the named
  --     edition.  

  type lname_array   IS table of VARCHAR2(4000) index by BINARY_INTEGER;
  type integer_array IS table of BINARY_INTEGER index by BINARY_INTEGER;
  procedure get_package_memory_utilization(
              owner_names   OUT NOCOPY lname_array,
              unit_names    OUT NOCOPY lname_array,
              unit_types    OUT NOCOPY integer_array,
              used_amounts  OUT NOCOPY integer_array,
              free_amounts  OUT NOCOPY integer_array);

  -- Supported info_kinds:
  used_memory CONSTANT BINARY_INTEGER := 1;
  free_memory CONSTANT BINARY_INTEGER := 2;

  type big_integer_array IS table of INTEGER index by BINARY_INTEGER;
  type big_integer_matrix IS table of big_integer_array 
                             index by BINARY_INTEGER;
  procedure get_package_memory_utilization(
              desired_info  IN         integer_array,
              owner_names   OUT NOCOPY lname_array,
              unit_names    OUT NOCOPY lname_array,
              unit_types    OUT NOCOPY integer_array,
              amounts       OUT NOCOPY big_integer_matrix);

  -- These procedures describe static package memory usage.
  -- The output collections describe memory usage
  -- in each instantiated package.  Each package is
  -- described by its owner name, package name, type,
  -- and memory statistics.
  -- The amount of unused memory is greater than zero
  -- because of memory fragmentation and also because 
  -- once used free memory chunks initially go to a free
  -- list owned by the package memory heap.  They are
  -- released back to the parent heap only when
  -- free_unused_user_memory is invoked.
  --
  --    Two overloadings are provided.  
  --    The first measures memory usage up to 2**31-1 (the maximum for
  -- BINARY_INTEGER).  It only measures used and free memory.
  --    The second measures up to 10**38 (the maximum for INTEGER (which is
  -- NUMBER(38,0).)  This overloading takes an IN 'desired_info' array
  -- specifying which kinds of information are desired.  Currently the options
  -- are the same as for the first overloading; but in the future, additional
  -- kinds of information may be supported.  The OUT 'amounts' array is indexed
  -- by info_kind values specified in 'desired_info' to yield arrays which are
  -- indexed in turn by the same integer used to index the other OUT arrays to
  -- yield the requested kinds of information.

end;
/

create or replace public synonym dbms_session for sys.dbms_session
/
grant execute on dbms_session to public
/

