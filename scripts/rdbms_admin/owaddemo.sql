Rem
Rem $Header: owaddemo.sql 15-oct-2001.17:20:28 rdecker Exp $
Rem
Rem owaddemo.sql
Rem
Rem Copyright (c) 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      owaddemo.sql - OWA Debug Demo
Rem
Rem    DESCRIPTION
Rem      This package provides code to demostrate how a plsql web
Rem      application developer might use the OWA_DEBUG package
Rem      to debug their application.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pkapasi     10/18/02 - Add some doc item
Rem    pkapasi     01/24/02 - Fix bug#2176216 (cookie scoping incorrect)
Rem    pkapasi     11/13/01 - Remove tabs
Rem    rdecker     10/05/01 - Merged rdecker_owa_debug_jdwp
Rem    rdecker     09/13/01 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

------------------------------------------------------------------------
----------------  OWA_DEBUG_DEMO PACKAGE DESCRIPTION -------------------
------------------------------------------------------------------------
-- The OWA_DEBUG_DEMO package contains code to demonstrate how a 
-- plsql web application developer should use the OWA_DEBUG package 
-- to debug their application.
--
-- The package contains 3 entrypoints:
-- main_form: to display an html form to be used for submitting debug
--     session values or for dropping a debug session.
-- create_debug_session: to act as the action procedure for main_form,
--     and create the OWA Debug Session.
-- drop_debug_session: to drop the OWA Debug Session
-- Of these 3 entry points, it will only be necessary to call main_form
-- from the browser to create or drop a debug session.  
-- 
-- Steps to run the demo:
-- 1. Load this file (containing the owa_debug_demo and owa_debug_demo_app
--    packages) into a demo schema.  
-- 2. Configure a mod_plsql DAD to use this schema and enable OWA Debug
--        Set PlsqlOWADebugEnable On
-- 3. Due to security reasons, mod_plsql will disallow calling of any
--    procedure name which has "owa_*" in it. Disable this behaviour with
--    the following directive (not to be done for production sites)
--        Set PlsqlExclusionList  "#None#"
-- 4. In your web browser, type:
--    http://<host>:<port>/pls/<DAD>/owa_debug_demo.main_form
--    where <host>:<port> describe the host and port where the database
--    TNS listener is running.
-- 5. In the html form that is displayed, you can enable JDWP debugging
--    (available only on 9iR2+), sql tracing or plsql profiling.
  
CREATE OR replace PACKAGE owa_debug_demo IS
   -- These are the Oracle supplied debug packages
   jdwp_debug_package     CONSTANT VARCHAR2(15) := 'OWA_DEBUG_JDWP';
   trace_debug_package    CONSTANT VARCHAR2(16) := 'OWA_DEBUG_TRACE';
   profiler_debug_package CONSTANT VARCHAR2(19) := 'OWA_DEBUG_PROFILER';
   
   -- Name: main_form
   -- Description: Show the form used to create and drop the debug session.
   -- Parameters:
   --       msg   IN   an optional message to be displayed on the form page
   PROCEDURE main_form(msg IN VARCHAR2 DEFAULT NULL);

   -- Name: create_debug_session
   -- Description: Create an OWA Debug Session.  The interface of this
   --              procedure is designed such that it can be called using
   --              the Flexible Parameters feature of the PL/SQL Gateway.
   -- Parameters:
   --       name_array  IN OUT  array containing the name part of name/values
   --       value_array IN OUT  array containing the value part of name/values
   PROCEDURE create_debug_session(name_array  IN owa_util.vc_arr,
                                  value_array IN owa_util.vc_arr);

   -- Name: drop_debug_session
   -- Description: Drop the OWA Debug Session.
   -- Parameters:  none.
   PROCEDURE drop_debug_session;
END owa_debug_demo;
/
show errors;

CREATE OR replace PACKAGE BODY owa_debug_demo is
   PROCEDURE main_form(msg IN VARCHAR2 DEFAULT NULL) IS
      show_msg VARCHAR2(200);
   BEGIN
      htp.htmlopen;
      htp.headopen;

      -- Alert the user that they are about to submit potentially 
      -- sensitive information.    
      htp.script('
         function check_protocol()
         {
            if (location.protocol != "https:")
                return confirm("You are about to submit potentially sensitive information over an unsecure protocol.  Do you wish to continue?");
            else
                return true;
         }
         ',
         'JavaScript');

      htp.headclose;
      
      -- Display a message
      IF (msg IS NULL) THEN
         show_msg := 'Welcome to the OWA Debug Demo!';
      ELSE
         show_msg := msg;
      END IF;
      
      htp.center('<H4>'||show_msg||'</H4>');
 
      -- Call create_debug_session using the Flexible Parameters feature 
      -- of the PL/SQL Gateway.
      htp.formOpen(curl=>'!owa_debug_demo.create_debug_session',
                   cattributes=>'onSubmit="return check_protocol()"');

      -- Now create the text fields 
      htp.print('<H5> Enable JDWP Debugging');
      htp.formcheckbox(cname=>'enable_jdwp');
      
      htp.print('<H5> JDWP Debugger Host: ');
      htp.formText(cname=>'host');

      htp.print('<H5> JDWP Debugger Port: ');
      htp.formText(cname=>'port');
      
      htp.print('<H5> JDWP Debug Role: ');
      htp.formText(cname=>'debug_role');
      
      htp.print('<H5> JDWP Debug Role Password: ');
      htp.formPassword(cname=>'debug_role_pwd');
      htp.line;
      
      htp.print('<H5> Enable SQL Tracing ');
      htp.formcheckbox(cname=>'enable_trace');
      htp.line;
      
      htp.print('<H5> Enable Profiler ');
      htp.formcheckbox(cname=>'enable_profiler');
      
      htp.print(' Run Comments: ');
      htp.formtext(cname=>'run_comment');
      htp.line; 
      
      htp.print('<H5> Debug Cookie Path: ');
      htp.formText(cname=>'cookie_path',
                   cvalue=>owa_util.get_cgi_env('SCRIPT_NAME'));
      
      htp.print('<H5> Idle Timeout (in minutes): ');
      htp.formText(cname=>'idle_timeout', cvalue=>'20');
      htp.nl; htp.nl;
      
      htp.formsubmit(cvalue=>'Create Debug Session');
      
      htp.formClose;
      htp.line;
      
      htp.formOpen(curl=>'owa_debug_demo.drop_debug_session');
      htp.formsubmit(cvalue=>'Drop Debug Session');
      htp.formclose;

      htp.htmlclose;
    END main_form;
 
   -- Name: get_value (private function)
   -- Description: This function will retrieve a value from the value
   --              array given the correlated name.
   -- Parameters: 
   --        name          IN         the name to be removed from the arrays
   --                                 and whose value we wish to retrieve
   --        name_array    IN         array containing the names
   --        value_array   IN         array containing the values
   --        RETURNS                  the value corresponding to the name
   --
   FUNCTION get_value(name IN VARCHAR2, 
                      name_array IN owa_util.vc_arr,  
                      value_array IN owa_util.vc_arr) 
            RETURN varchar2
    IS
    BEGIN
       -- Get the array index for a given name
       FOR i IN 1..name_array.last LOOP
          IF (name_array(i) = name) THEN
             RETURN value_array(i);
          END IF;
       END LOOP;
       
       RETURN NULL;
    END get_value;

   
   PROCEDURE create_debug_session (name_array  IN owa_util.vc_arr,
                                   value_array IN owa_util.vc_arr)
   IS
      cookie_path   VARCHAR2(32767);
      idle_timeout  pls_integer;
      debug_session varchar2(64);
      call_name_array owa_util.vc_arr;
      call_value_array owa_util.vc_arr;
      null_array   owa_util.vc_arr;
      send_cookie BOOLEAN := false;
   BEGIN
      owa_util.mime_header('text/html', false);

      -- Get the cookie_path out of the name/value arrays.  The cookie
      -- path can be used to scope debug sessions so that we can do things
      -- like attach the debugger to DAD 'A', which we want to debug
      -- but not DAD 'B', which we don't want to debug.
      cookie_path := get_value('cookie_path', name_array, value_array); 
 
      -- Get the idle_timeout from the name/value arrays; the idle
      -- timeout refers to the period between the time we finish
      -- debugging one page and disconnect the debugger to the time
      -- we connect again to the same debug session and begin debugging
      -- the next page.
      idle_timeout := get_value('idle_timeout', name_array, value_array);
         
      BEGIN
         debug_session := owa_debug.create_debug_session;
      EXCEPTION
         -- Watch out for exceptions thrown from create_debug_session
         WHEN owa_debug.exceeded_session_limit THEN
           -- Too many open sessions!
           owa_util.http_header_close;
           htp.center('<H3>There are too many open debug sessions!</H3>');
           htp.nl;
           htp.center('<H3>Please close some debug sessions and run the demo again!</H3>');
           RETURN;
         WHEN OTHERS THEN
           RETURN;
      END;
      
      IF (get_value('enable_jdwp', name_array, value_array) = 'on')
      THEN
         send_cookie := true;
    
         call_name_array(1) := 'host';
         call_value_array(1) := get_value('host', name_array, value_array);
    
         call_name_array(2) := 'port';
         call_value_array(2) := get_value('port', name_array, value_array);
    
         call_name_array(3) := 'debug_role';
         call_value_array(3) := get_value('debug_role', name_array, 
           value_array);
    
         call_name_array(4) := 'debug_role_pwd';
         call_value_array(4) := get_value('debug_role_pwd', name_array, 
           value_array);
    
         owa_debug.addto_debug_session(debug_session,
           call_name_array, call_value_array, jdwp_debug_package, 
           idle_timeout);
      END IF;
 
      IF (get_value('enable_trace', name_array, value_array) = 'on') THEN
         send_cookie := true;

         call_name_array := null_array;
         call_value_array := null_array;
         owa_debug.addto_debug_session(debug_session,
           call_name_array, call_value_array, trace_debug_package,
           idle_timeout);
      END IF;
 
      IF (get_value('enable_profiler', name_array, value_array) = 'on')
      THEN
         send_cookie := true;

         call_name_array := null_array;
         call_value_array := null_array;
    
         call_name_array(1) := 'run_comment';
         call_value_array(1) := get_value('run_comment', name_array, 
           value_array);
         owa_debug.addto_debug_session(debug_session,
           call_name_array, call_value_array, profiler_debug_package,
           idle_timeout);
      END IF;
 
      IF (send_cookie = true)
      THEN
         owa_cookie.send(name=>owa_debug.get_cookie_name,
           value=>debug_session, path=>cookie_path);
      END IF;

      owa_util.http_header_close;
      
      htp.center('<H3>Debug Session has been created</H3>'); htp.nl;
      htp.p('<H4>To continue:'); htp.nl;
      htp.p('Click ');
      htp.anchor('owa_debug_demo_app.page_one', 'here');
      htp.p(' to run the OWA debug demo application OR'); htp.nl;
      htp.p('   Begin running your own application');
   END;

   PROCEDURE drop_debug_session IS
      cookie_names owa_cookie.vc_arr;
   BEGIN
      -- First drop the debug session
      owa_debug.drop_debug_session;

      -- Now remove the debug session ID cookie
      owa_util.mime_header('text/html', false);
      owa_cookie.remove(owa_debug.get_cookie_name, NULL);
      owa_util.redirect_url('owa_debug_demo.main_form?msg=%3CH3%3EThe%20session%20has%20been%20dropped.');
   END;
END owa_debug_demo;
/
show errors;


--------------------------------------------------------------------------
----------------- OWA_DEBUG_DEMO_APP PACKAGE DESCRIPTION ---------------
--------------------------------------------------------------------------
-- The OWA_DEBUG_DEMO_APP is used to demonstrate the
-- OWA_DEBUG_DEMO package.
--
CREATE OR replace PACKAGE owa_debug_demo_app IS
  PROCEDURE page_one;
  PROCEDURE page_two;
END owa_debug_demo_app;
/
show errors;

CREATE OR replace PACKAGE BODY owa_debug_demo_app IS
   
   PROCEDURE page_one
   IS
   BEGIN
      FOR i IN 1..3 loop
         htp.center('<H'||i||'>This is the first page of the OWA debug demo app</H'||i||'>');
      END LOOP;
      
      htp.nl;
      htp.p('<H4>Click ');
      htp.anchor('owa_debug_demo_app.page_two', 'here');
      htp.p(' to view page 2 or ');
      htp.anchor('owa_debug_demo.drop_debug_session', 'here');
      htp.p(' to drop the debug session.');
   END;

   PROCEDURE page_two
   IS
   BEGIN
      FOR i IN 1..3 loop
         htp.center('<H'||i||'>This is the second page of the OWA debug demo app</H'||i||'>');
      END LOOP;

      htp.nl;
      htp.p('<H4>Click ');
      htp.anchor('owa_debug_demo_app.page_one', 'here');
      htp.p(' to view page 1 or ');
      htp.anchor('owa_debug_demo.drop_debug_session', 'here');
      htp.p(' to drop the debug session.');
   END;
END owa_debug_demo_app;
/
show errors;

