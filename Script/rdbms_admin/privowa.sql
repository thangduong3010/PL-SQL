rem
rem
Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      owa.sql - package of procedures called directly from OWA
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa     - These procedures are interface procedures for
Rem                     the Oracle Web Agent.  These procedures should
Rem                     not be called by an end-user.
Rem
Rem    NOTES
Rem      The Oracle Web Agent is needed to use these facilities.
Rem      The package htp is needed to use these facilities.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     pkapasi    10/18/06 - Enhancement Request#5610575(add reset_get_page)
Rem     pkapasi    07/25/02 - Use NOCOPY for performance (bug#2482024)
Rem     ehlee      10/12/01 - Add 32k cookie support (bug#1936565) 
Rem     skwong     07/20/01 - Add RAW support to GET_PAGE interfaces
Rem     pkapasi    06/12/01 - Merge OAS specific helper functions
Rem     rdasarat   01/22/98 - Overload init_cgi_env procedure
Rem     rdasarat   10/31/97 - Moving version to 4.0
Rem     rdasarat   08/09/97 - Replaced OWA_INIT with OWA_CUSTOM
Rem     mpal       07/09/97 - Replaced OWA_INIT with OWA_CUSTOM
Rem     mpal       04/23/97 - Changed Minor Version to 1 (Fixing bug# 482019)
Rem     rpang      01/27/97 - Restored PRAGMA RESTRICT_REFERENCES (bug#439474)
Rem     rpang      01/27/97 - Added initialize procedure
Rem     rpang      07/03/96 - Added initialzation section to touch OWA_INIT
Rem     mbookman   07/09/95 - Creation

REM Creating OWA package body...
create or replace package body OWA is

     /********************************************/
    /* Initialize the CGI environment variables */
   /********************************************/
   procedure init_cgi_env (param_val in vc_arr) is
      num_params number := param_val.count;
      ix         number;
      nameIx     number;
      var_name   vc_arr;
   begin
      /* Initialize cgi names */
      /* Keep this list in the same order as in ndwoa.h file */
      var_name(1) := 'SERVER_SOFTWARE';
      var_name(2) := 'SERVER_NAME';
      var_name(3) := 'GATEWAY_INTERFACE';
      var_name(4) := 'REMOTE_HOST';
      var_name(5) := 'REMOTE_ADDR';
      var_name(6) := 'AUTH_TYPE';
      var_name(7) := 'REMOTE_USER';
      var_name(8) := 'REMOTE_IDENT';
      var_name(9) := 'HTTP_ACCEPT';
      var_name(10) := 'HTTP_USER_AGENT';
      var_name(11) := 'SERVER_PROTOCOL';
      var_name(12) := 'SERVER_PORT';
      var_name(13) := 'SCRIPT_NAME';
      var_name(14) := 'PATH_INFO';
      var_name(15) := 'PATH_TRANSLATED';
      var_name(16) := 'HTTP_REFERER';
      var_name(17) := 'HTTP_COOKIE';

      nameIx := 0;
      ix := 0;
      for i in 1..num_params
      loop
         nameIx := nameIx + 1;
         if (param_val(i) is NOT NULL)
         then
            ix := ix + 1;
            cgi_var_name(ix)  := var_name(nameIx);
            cgi_var_val(ix)  := param_val(i);
         end if;
      end loop;
      num_cgi_vars := ix;
   end;

   procedure init_cgi_env (num_params in number,
                           param_name in vc_arr,
                           param_val  in vc_arr) is
      j      number := 0;
      cookie varchar2(32000) := ''; 
      found  boolean := FALSE;
   begin

      for i in 1..num_params
      loop
         if (param_name(i) = 'HTTP_COOKIE')
         then
            found := TRUE;
            cookie := cookie || param_val(i);
         else
            j := j + 1;
            cgi_var_name(j) := param_name(i);
            cgi_var_val(j)  := param_val(i);
         end if;
      end loop;

      if (found)
      then 
         j := j + 1;
         cgi_var_name(j) := 'HTTP_COOKIE';
         cgi_var_val(j) := cookie;
      end if;
 
      num_cgi_vars := j;
   end;

     /*****************************************/
    /* Get the output from the user's PL/SQL */
   /*****************************************/
   function get_line (irows out integer) return varchar2 is
   begin
      return(htp.get_line(irows));
   end;

   procedure get_page (thepage     out NOCOPY htp.htbuf_arr,
                       irows    in out integer ) is
   begin
      htp.get_page(thepage, irows);
   end;

   /* Start of OAS specific helper procedure */
   procedure get_page_charset_convert (thepage     out NOCOPY htp.htbuf_arr,
                       irows    in out integer,
                       charset  in     varchar2 ) is
   begin
      htp.get_page_charset_convert(thepage, irows, charset);
   end;
   /* End of OAS specific helper procedure */

   /* Add here to match the new HTP.GET_PAGE_RAW interface */
   procedure get_page_raw (thepage     out NOCOPY htp.htraw_arr,
                           irows    in out integer ) is
   begin
      htp.get_page_raw(thepage, irows);
   end;

   procedure reset_get_page is
   begin
      htp.reset_get_page;
   end;

   /* Added to set package global safely */
   procedure set_user_id(usr in varchar2) is
   begin
      user_id := usr;
   end set_user_id;

   /* Added to set package global safely */
   procedure set_password(pwd in varchar2) is
   begin
      password := pwd;
   end set_password;

   /* Added to set package global safely */
   procedure set_transfer_mode (tmode in varchar2) is
   begin
      HTP.set_transfer_mode(tmode);
   end set_transfer_mode;

       /*******************************************************************/
      /* Initialize function -                                           */
     /*    This function is called when a DCD is invoked for the first  */
    /*   time when PL/SQL Agent starts up.                             */
   /*******************************************************************/
   function initialize return integer is
     dummy number;
     majVersion number;
     minVersion number;
   begin

     -- Please ensure you update major, minor versions for every release
     majVersion := 4;
     minVersion := 0;

     auth_scheme := OWA_SEC.NO_CHECK;
     dummy := owa_custom.dbms_server_gmtdiff;

     return (majVersion*256+minVersion);
   end;
end;
/
show errors package body OWA

