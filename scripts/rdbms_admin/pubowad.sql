Rem
Rem $Header: pubowad.sql 15-oct-2001.16:59:41 rdecker Exp $
Rem
Rem pubowad.sql
Rem
Rem Copyright (c) 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      pubowad.sql - OWA Debug package
Rem
Rem    DESCRIPTION
Rem      The OWA Debug package contains APIs which are used to 
Rem      control debugger execution for debugging plsql web 
Rem      applications.
Rem      This package is needed only if you plan to do SQL*Tracing or
Rem      Profiling or JDWP Debugging using mod_plsql
Rem      This package should be wrapped
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pkapasi     11/13/01 - Remove tabs
Rem    rdecker     10/05/01 - Merged rdecker_owa_debug_jdwp
Rem    rdecker     08/21/01 - Created
Rem

CREATE OR REPLACE PACKAGE owa_debug IS 

   -----------------------------------------------------------------------
   ----------------------- PACKAGE DESCRIPTION ---------------------------
   -----------------------------------------------------------------------
   --   The OWA Debug package contains APIs which are used to control
   --   debugger execution while debugging plsql web applications.
   --   The debugging paradigm described provides the application 
   --   developer/debugger a means of customizing the debugging process 
   --   in a way that is both secure and easy to use.
   --
   --   In order to debug a plsql web application, a user must first 
   --   create an OWA debug session, which is started at the beginning of
   --   the debug process and persists across multiple http requests to 
   --   the database, via a PL/SQL gateway such as mod_plsql, until it 
   --   either expires or is explicitly ended.  The session contains 
   --   "environment" type values (referred to as debug session values) 
   --   that are defined by the application, set by the user, and passed 
   --   into an application defined procedure with every http request.  
   --   These values can be used to perform security or validation checks
   --   with each request, and are discussed in more detail later.
   --
   --   An OWA debug session is initiated by calling create_debug_session,
   --   which will return an OWA Debug Session ID.  Using this ID, a user
   --   can call addto_debug_session with a correlated array of name and 
   --   value pairs to be used as debug session values and the name of a
   --   package where matching attach and detach procedures are located
   --   which can process the debug session values.
   --   The debug session ID should be saved in a browser cookie, with 
   --   the cookie name returned by get_cookie_name().  This debug session 
   --   ID identifies the http request to the database as belonging to the 
   --   given debug session.  An example of the code needed to begin an 
   --   OWA debug session is given in the OWA_DEBUG_DEMO package in 
   --   owaddemo.sql.
   --
   
   -----------------------------------------------------------------------
   ------------------------  CONSTANTS -----------------------------------
   -----------------------------------------------------------------------
   -- This is the max number of OWA Sessions that can be open at any one 
   -- time.
   open_sessions_limit CONSTANT pls_integer := 32767;

   -----------------------------------------------------------------------
   ------------------------  EXCEPTIONS ----------------------------------
   -----------------------------------------------------------------------
   -- Cause: Non-existant, invalid or expired OWA Debug Session or cookie.
   --        The debug session handle is invalid, or the session has 
   --        expired.
   -- Action: Recreate the sesssion.
   invalid_debug_session exception;
   PRAGMA exception_init(invalid_debug_session, -20001);

   -- Cause: Unrecognized Client IP Address.  Every http request to a 
   --        given OWA Debug Session must have the same client IP 
   --        address.  
   --        Therefore, if you are attempting to run your application 
   --        through a load balancing proxy, you may get this exception 
   --        since such configurations are not supported.
   -- Action: Make sure your browser can contact the PL/SQL Gateway 
   --         directly without having to use an http proxy.
   unrecognized_client_ip exception;
   pragma exception_init(unrecognized_client_ip, -20002);

   -- Cause: There are too many open OWA debug sessions.  The max number 
   --        of open OWA debug sessions allowed at any one time is 
   --        open_sessions_limit. 
   -- Action: Either close some debug sessions, or wait until others 
   --         close their sessions (or they expire).
   exceeded_session_limit EXCEPTION;
   PRAGMA exception_init(exceeded_session_limit, -20003);
   
   -- Cause: A PL/SQL Gateway, such as the one contained in mod_plsql, 
   --        must be used to run and debug PL/SQL applications.  
   --        This exception indicates that a PL/SQL Gateway was not 
   --        detected.
   -- Action: Use a PL/SQL Gateway such as mod_plsql.
   no_plsql_gateway EXCEPTION;
   PRAGMA exception_init(no_plsql_gateway, -20004);

   -- Cause: Illegal or Unmatched quotes found, or the size of the debug 
   --        session values exceeds the limit allowed.  All combined 
   --        values (including names) must be less than 32767 bytes.
   -- Action: Decrease the size or number of session values submitted to
   --         create_debug_session, and/or fix any quoting problems.
   improper_session_values EXCEPTION;
   PRAGMA exception_init(improper_session_values, -20005);
   
   
   -----------------------------------------------------------------------
   -------------------------  PUBLIC INTERFACES --------------------------
   -----------------------------------------------------------------------
   -- Name: GET_COOKIE_NAME
   -- 
   -- Description: Return the OWA debug session cookie name to use when
   --              creating a new cookie.
   -- Parameters:
   --       RETURNS           the cookie name for this session
   --
   FUNCTION get_cookie_name    RETURN VARCHAR2;
   
  
   -- Name: CREATE_DEBUG_SESSION
   --
   -- Description: 
   --      This function is used to create an OWA Debug Session.  The
   --      return value of this function should be stored in an http
   --      cookie, with the name returned by get_cookie_name.  An example 
   --      of its usage is given in the OWA_DEBUG_DEMO package, in 
   --      owaddemo.sql.
   --      NOTE: The user is strongly encouraged to use a secure http 
   --      connection (https/ssl) when submitting potentially sensitive 
   --      data (such as passwords) that will be used to validate a 
   --      debug session.
   -- Parameters:  
   --      RETURNS:     The OWA Debug Session ID
   --
   FUNCTION create_debug_session 
     RETURN VARCHAR2;
   
   -- Name: ADDTO_DEBUG_SESSION
   --
   -- Description: 
   --      This function adds name/value pairs and package information
   --      to the given session.  When the application is executed,
   --      the attach procedure in the given package will be called
   --      with the name/value pairs as parameters.
   --      This function can be called many times, so that all packages
   --      and name/values submitted will be called/used on each request.
   -- Parameters:  
   --      name_array:  The array of names of session data values.
   --      value_array: The array of session values, corresponding to 
   --                   name_array.
   --      package_name: name of the package which contains the attach
   --                    and detach entry points for these name/value pairs.
   --      idle_timeout: The number of minutes allowed to pass after a
   --                    user has disconnected from a debug session
   --                    before the session times out.
   --                    Defaults to 20 minutes.
   --
   PROCEDURE addto_debug_session (session_id      IN varchar2 default NULL,
                                  name_array      IN owa_util.vc_arr,
                                  value_array     IN owa_util.vc_arr,
                                  package_name    IN VARCHAR2,
                                  idle_timeout    IN pls_integer DEFAULT 20);

   
   -- Name: DROP_DEBUG_SESSION
   --
   -- Description:
   --      This procedure will effectively end the user's OWA debug 
   --      session.
   --      Whenever a debug session is ended, the cookie containing the
   --      session ID should be deleted since the session ID will become
   --      invalid.  An example of this usage is given in the 
   --      OWA_DEBUG_DEMO package in owaddemo.sql.
   --      
   -- Parameters:
   --      session_id     IN   The session id from create_debug_session.
   --                          If this is null, the session_id will be
   --                          retrieved from the OWA debug cookie.
   PROCEDURE drop_debug_session(session_id IN VARCHAR2 DEFAULT NULL);
   
   -- Name: ATTACH
   --
   -- Description: 
   --       ATTACH is the main API for validating an OWA debug
   --       session, and calling the attach procedures for each package
   --       submitted to addto_debug_session.  It is called internally 
   --       by the plsql gateway.
   --
   -- Parameters:
   --      session_id     IN   The session id from create_debug_session.
   --                          If this is null, the session_id will be
   --                          retrieved from the OWA debug cookie.
   --
   PROCEDURE attach(session_id IN VARCHAR2 DEFAULT NULL);
   
   -- Name: DETACH
   -- 
   -- Description:
   --       This procedure will detach the session from the debugger.
   --       It will be called internally from the plsql gateway.
   --
   -- Parameters:
   --      session_id     IN   The session id from create_debug_session.
   --                          If this is null, the session_id will be
   --                          retrieved from the OWA debug cookie.
   --
   PROCEDURE detach(session_id IN VARCHAR2 DEFAULT NULL);
   

END owa_debug;
/
SHOW ERRORS;

--------------------------------------------------------------------------
--------------------- PERMISSIONS AND SYNONYMS ---------------------------
--------------------------------------------------------------------------
GRANT EXECUTE ON owa_debug TO PUBLIC;

CREATE PUBLIC SYNONYM owa_debug FOR owa_debug;

