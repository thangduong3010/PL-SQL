Rem
Rem $Header: dbmsjdwp.sql 31-jan-2002.14:40:45 dalpern Exp $
Rem
Rem dbmsjdwp.sql
Rem
Rem Copyright (c) 2000, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsjdwp.sql
Rem
Rem    DESCRIPTION
Rem      package to connect/disconnect debug using jdwp protocol
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dalpern     01/31/02 - minor cleanups
Rem    rpang       10/05/01 - Added get_nls_parameter/set_nls_parameter
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    dalpern     12/05/00 - privileges for kga debugger
Rem    rpang       11/22/00 - Added process_connect_string
Rem    dalpern     09/30/00 - f.s. commentary edit
Rem    dalpern     05/23/00 - kga development
Rem                01/02/00 - Created
Rem

create or replace package dbms_debug_jdwp authid current_user is

   
  -- DBMS_DEBUG_JDWP.CONNECT_TCP:

  -- Connect the specified session to the debugger waiting at host:port.
  --
  -- To connect the current session to a debugger, you can pass NULL to
  -- both the session_id and session_serial parameters.
  --
  -- To connect a different session, you need to find out its id and
  -- serial.  These are available in the v$session and v_$session views,
  -- although in general only users with dba-like privileges can select
  -- from those.  Oracle Enterprise Manager's Instance Manager is one
  -- example of a user interface that will display these values to
  -- users with sufficient privileges.  You can also find the values of
  -- these for your own session using the current_session_id and
  -- current_session_serial functions declared below.
  --
  -- An ORA-30677 indicates that the requested session is already
  -- being debugged.  It is suggested in this case that the user be
  -- asked to confirm that (s)he desires to steal the session from
  -- the existing connection, and then either an explicit disconnect
  -- call or the use of the connect_force_connect option bit
  -- can be used to allow the connection to succeed on a second attempt.
  -- Note that using the connect_force_connect bit will avoid
  -- the session being allowed to run freely if it is currently suspended
  -- through the debugger - in other words, this bit lets you steal a
  -- session from one debugger to another without actually disturbing the
  -- state of the session at all.
  --
  -- The debug_role and debug_role_pwd arguments allow the user to name
  -- any role as the "debug role", which will be available to privilege
  -- checking when checking for permissions to connect the session and
  -- when checking permissions available on objects within the debugged
  -- session.  Both the role and its password are passed here as strings
  -- and not as identifiers, so double quotes should not be used but
  -- case matters -- if the original role name wasn't double-quoted,
  -- it should be specified here in upper case.
  --
  -- Likely errors to encounter here are ORA-00022, ORA-01031, ORA-30677,
  -- ORA-30681, ORA-30682, and ORA-30683.
  --
  -- NOTE:  Only a subset of our desired functionality is implemented in this
  -- release:
  --
  --   - A session cannot yet connect another session to a debugger; it
  --     can only connect itself.  ORA-00022 will be raised on attempts
  --     to cause other sessions to connect to a debugger.
  --
  --   - The per-object DEBUG privilege is not yet meaningful.  Attempts
  --     to connect to a debugger will only succeed at all if the session's
  --     current effective user and roles unioned with the debug_role carry
  --     both the DEBUG CONNECT SESSION and DEBUG ANY PROCEDURE privileges.
  --     ORA-01031 will be raised otherwise.
  --
  --   - The session's effective user at the time of the call must be the
  --     same as the login user of the session.  This call will not succeed
  --     if invoked from a definer's rights function running as a different
  --     user; in such a case an ORA-01031 will be raised.
  -- 
  procedure connect_tcp(host varchar2,
                        port varchar2,
                        session_id pls_integer := NULL,
                        session_serial pls_integer := NULL,
                        debug_role varchar2 := NULL,
                        debug_role_pwd varchar2 := NULL,
                        option_flags pls_integer := 0,
                        extensions_cmd_set pls_integer := 128);

  -- Values for option_flags argument:
  --   These may be added together to select multiple option choices.

  --   Don't actually suspend the program until the next client/server
  --   request begins.  This can be used to hide the startup sequence
  --   itself from end users, who likely really only want to see their
  --   own code.
     connect_defer_suspension constant pls_integer := 1;

  --   Force the connection even if the session appears to already be
  --   connected to a debugger.  This should best only be specified
  --   after some human-interaction confirmation step has occurred; i.e.,
  --   if an attempt without this option raised ORA-30677, then if the user
  --   confirms, retry with this bit set.
     connect_force_connect constant pls_integer := 2;



  -- DBMS_DEBUG_JDWP.DISCONNECT:

  -- Disconnect the specified session from any debugger that it is connected
  -- with.  The session will be allowed to run freely after disconnecting the
  -- debugger.  The same rights are required for this call as for
  -- connect.
  --
  -- An ORA-00022 exception may be raised here.
  --
  -- NOTE:  Only a subset of our desired functionality is implemented in this
  -- release:
  --
  --   - A session cannot yet disconnect another session from a debugger; it
  --     can only connect or disconnect itself.  ORA-00022 will be raised on
  --     attempts to cause other sessions to disconnect from a debugger.
  -- 
  procedure disconnect(session_id pls_integer := NULL,
                       session_serial pls_integer := NULL);



  -- DBMS_DEBUG_JDWP.CURRENT_SESSION_ID:

  -- Get the current session's session id.
  --
  -- No special rights are required and no errors are possible.
  --
  function current_session_id return pls_integer;



  -- DBMS_DEBUG_JDWP.CURRENT_SESSION_SERIAL:

  -- Get the current session's session serial number.
  --
  -- No special rights are required and no errors are possible.
  --
  function current_session_serial return pls_integer;



  -- DBMS_DEBUG_JDWP.PROCESS_CONNECT_STRING:

  -- To make it easy to connect a session to a debugger without having to
  -- directly modify an application's code, we provide mechanisms allowing a
  -- session to connect to a debugger through the use of either the
  -- ORA_DEBUG_JDWP operating system environment variable when running
  -- an OCI program, or a web browser "cookie" called OWA_DEBUG_<dad>
  -- set when running an application through the PL/SQL Web Gateway.
  --
  -- Such connections to a debugger route through this function to have
  -- the environment variable or cookie value parsed and the next layer
  -- of processing dispatched.
  --
  -- Alternative PL/SQL web cartridge/gateway products are free to use
  -- this API to establish debugging connections.
  --
  -- All errors discussed under DBMS_DEBUG_JDWP.CONNECT_TCP may be raised
  -- by this call.  ORA-30689 may also be raised.  Additionally, this call
  -- can route through "custom" routines implemented by the application to
  -- do additional filtering on which debugger connections to allow; errors
  -- may also be raised from such "custom" code.
  --
  procedure process_connect_string(connect_string varchar2,
                                   connect_string_type pls_integer);

  -- Values for connect_string_type argument:
     
  --   After parsing, invoke DBMS_DEBUG_JDWP_CUSTOM.CONNECT_DEBUGGER
     connect_string_environment_var constant pls_integer := 1;

  --   After parsing, invoke OWA_DEBUG_JDWP_CUSTOM.CONNECT_DEBUGGER
     connect_string_cookie constant pls_integer := 2;



  -- DBMS_DEBUG_JDWP.GET_NLS_PARAMETER, SET_NLS_PARAMETER:

  -- Gets or sets the value of the specified NLS parameter affecting the
  -- format in which NUMBER, DATE, TIME (WITH TIME ZONE) and TIMESTAMP (WITH
  -- TIME ZONE) runtime values of PL/SQL programs are converted to strings
  -- as they are presented through JDWP.  These values are private to the
  -- current session, but further are private to the debugger mechanisms,
  -- separate from the values used to convert values within the debugged
  -- program itself.
  -- 
  -- When any variable value is read or assigned through JDWP, or when one
  -- of these get_nls_parameter or set_nls_parameter APIs are first invoked
  -- in a session, the debugger mechanisms make a private copy of the
  -- then-current  NLS_LANGUAGE, NLS_TERRITORY, NLS_CALENDAR,
  -- NLS_DATE_LANGUAGE, NLS_NUMERIC_CHARACTERS, NLS_TIMESTAMP_FORMAT,
  -- NLS_TIMESTAMP_TZ_FORMAT, NLS_TIME_FOMAT and NLS_TIME_TZ_FORMAT values.
  -- These private copies may be read using this get_nls_parameter call and
  -- changed using the following set_nls_parameter call.
  --
  -- Once the debugger's private copy of the NLS parameters is established,
  -- changes made to the NLS parameters in the current session using the
  -- "ALTER SESSION" statement will have no effect on the formatting of
  -- values as seen through JDWP.  To modify the NLS parameters used for
  -- JDWP, one must use this set_nls_parameter procedure.
  --
  -- Vice versa, changes made to the debugger's private copy of the NLS
  -- parameters using this set_nls_parameter procedure will have no effect
  -- on the debugged program itself.
  --
  -- Date values are always formatted for JDWP use using the
  -- NLS_TIMESTAMP_FORMAT.  The default format for DATE (NLS_DATE_FORMAT)
  -- used in a session most often does not show the time information that
  -- is in fact present in the value, and for debugging purposes it seems
  -- beneficial to always display that information.
  --
  function get_nls_parameter(name varchar2) return varchar2;

  procedure set_nls_parameter(name varchar2, value varchar2);

end;
/
create or replace public synonym dbms_debug_jdwp for sys.dbms_debug_jdwp
/
grant execute on dbms_debug_jdwp to public
/
