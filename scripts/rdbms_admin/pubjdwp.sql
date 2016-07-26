Rem
Rem $Header: pubjdwp.sql 23-oct-2001.12:23:19 rdecker Exp $
Rem
Rem pubjdwp.sql
Rem
Rem Copyright (c) 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      pubjdwp.sql - OWA Debug JDWP
Rem
Rem    DESCRIPTION
Rem      This is the default and sample implementation of the
REM      owa debug PACKAGE used FOR debugging plsql web applications.
REM      Note: This PACKAGE will only compile ON 9i+ AND the jdwp
REM            debugging interfaces will only work ON 9iR2+.  
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pkapasi     11/13/01 - Remove tabs
Rem    rdecker     10/05/01 - Merged rdecker_owa_debug_jdwp
Rem    rdecker     09/13/01 - Created
Rem

CREATE OR REPLACE PACKAGE owa_debug_jdwp AUTHID CURRENT_USER IS

  PROCEDURE attach(host varchar2,
                   port varchar2,
                   debug_role varchar2 := NULL,
                   debug_role_pwd varchar2 := NULL,
                   option_flags pls_integer := 0,
                   extensions_cmd_set pls_integer := 128);
  
  PROCEDURE detach(host varchar2,
                   port varchar2,
                   debug_role varchar2 := NULL,
                   debug_role_pwd varchar2 := NULL,
                   option_flags pls_integer := 0,
                   extensions_cmd_set pls_integer := 128);


END owa_debug_jdwp;
/
SHOW ERRORS;

CREATE OR REPLACE PACKAGE BODY owa_debug_jdwp
IS

   PROCEDURE attach(host varchar2,
                    port varchar2,
                    debug_role varchar2 := NULL,
                    debug_role_pwd varchar2 := NULL,
                    option_flags pls_integer := 0,
                    extensions_cmd_set pls_integer := 128)
   IS
   BEGIN
    -- Connects the database session to the debugger.
    --
    -- A programmer who wants to perform added security checks to decide 
    -- if the debug connection request is granted (for example, by 
    -- verifying that the debugger is running on a trusted host) may do 
    -- so with code like:
    --
    --   if (utl_inaddr.get_host_address(host) != '123.45.67.89') then
    --     raise_application_error(-20000,
    --        'debug connection to ' || host || ' not permitted');
    --   else
    --     dbms_debug_jdwp.connect_tcp(host => host,
    --                                 port => port,
    --                                 debug_role => debug_role,
    --                                 debug_role_pwd => debug_role_pwd,
    --                                 option_flags => option_flags,
    --                                 extensions_cmd_set => 
    --                                 extensions_cmd_set);
    --   end if;
    --
    dbms_debug_jdwp.connect_tcp(host => host,
                                port => port,
                                debug_role => debug_role,
                                debug_role_pwd => debug_role_pwd,
                                option_flags => option_flags,
                                extensions_cmd_set => extensions_cmd_set);

   END;
   
   PROCEDURE detach(host varchar2,
                    port varchar2,
                    debug_role varchar2 := NULL,
                    debug_role_pwd varchar2 := NULL,
                    option_flags pls_integer := 0,
                    extensions_cmd_set pls_integer := 128)
   IS
   BEGIN
    dbms_debug_jdwp.disconnect;
   END;
END owa_debug_jdwp;
/

SHOW ERRORS PACKAGE BODY owa_debug_jdwp

GRANT EXECUTE ON owa_debug_jdwp TO PUBLIC;

CREATE PUBLIC SYNONYM owa_debug_jdwp FOR owa_debug_jdwp;

