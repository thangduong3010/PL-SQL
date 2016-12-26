rem
rem
Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      pubowa.sql - package of procedures called directly from OWA
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
Rem     pkapasi    10/18/06 - Enhancement Request#5610575: add reset_get_page
Rem     pkapasi    07/25/02 - Use NOCOPY for performance (bug#2482024)
Rem     pkapasi    08/21/01 - Fix bug#1930471
Rem     skwong     07/20/01 - Add RAW support to GET_PAGE interfaces
Rem     pkapasi    06/17/01 - Add support for EBCDIC databases(bug#1778693)
Rem     pkapasi    06/12/01 - Merge OAS specific helper functions
Rem     ehlee      10/06/00 - Increase vc_arr varchar2 size from 2000 to 32000
Rem     ehlee      06/01/00 - Remove bug fix #1291321 as it causes problems
Rem     pkapasi    05/08/00 - Fix bug#1291321
Rem     rdasarat   01/22/98 - Overload init_cgi_env procedure
Rem     rpang      01/27/97 - Restored PRAGMA RESTRICT_REFERENCES (bug#439474)
Rem     rpang      01/27/97 - Added initialize procedure
Rem     rpang      07/03/96 - Added package variables for authorization
Rem     mbookman   03/04/96 - Asserted the purity of the OWA initialization
Rem     mbookman   03/04/96 - Added package variable num_cgi_vars (314403)
Rem     mbookman   07/09/95 - Creation

REM Creating OWA package...
create or replace package OWA is
   PRAGMA RESTRICT_REFERENCES(owa, WNDS, RNDS, WNPS, RNPS);

   type vc_arr is table of varchar2(32000) index by binary_integer;
   type nc_arr is table of nvarchar2(16000) index by binary_integer;
   type raw_arr is table of raw(32000) index by binary_integer;

   cgi_var_name vc_arr;
   cgi_var_val  vc_arr;
   num_cgi_vars number;

   NL_CHAR constant varchar2(1) := owa_cx.nl_char; 
   SP_CHAR constant varchar2(1) := owa_cx.sp_char; 
   BS_CHAR constant varchar2(1) := owa_cx.bs_char; 
   HT_CHAR constant varchar2(1) := owa_cx.ht_char; 
   XP_CHAR constant varchar2(1) := owa_cx.xp_char; 

   auth_scheme       integer;
   protection_realm  varchar2(255);
   user_id           varchar2(255);
   password          varchar2(255);
   ip_address        owa_util.ip_address;
   hostname          varchar2(255);

       /*******************************************************************/
      /* Initialize function -                                           */
     /*    This function is called when a DCD is invoked for the first  */
    /*   time when PL/SQL Agent starts up.                             */
   /*******************************************************************/
   function initialize return integer;

     /********************************************/
    /* Initialize the CGI environment variables */
   /********************************************/
   procedure init_cgi_env (param_val  in vc_arr);
   procedure init_cgi_env (num_params in number,
                           param_name in vc_arr,
                           param_val  in vc_arr);

     /*****************************************/
    /* Get the output from the user's PL/SQL */
   /*****************************************/
   function  get_line (irows out integer) return varchar2;
   procedure get_page (thepage     out NOCOPY htp.htbuf_arr,
                       irows    in out integer );
   /* Start of OAS specific helper procedures */
   procedure get_page_charset_convert (thepage     out NOCOPY htp.htbuf_arr,
                       irows    in out integer ,
                       charset in varchar2 );
   /* End of OAS specific helper procedures */

   /* The raw interface to match HTP */
   procedure get_page_raw (thepage out NOCOPY htp.htraw_arr,
                       irows in out integer);

   procedure reset_get_page;

   /* Set package globals without crashing */
   procedure set_user_id(usr in varchar2);
   procedure set_password(pwd in varchar2);

   /* Enable raw transfer mode */
   procedure set_transfer_mode(tmode in varchar2);
end;
/
show errors package OWA

