rem
rem
Rem  Copyright (c) 1996, 1997 by Oracle Corporation. All rights reserved.
Rem    NAME
Rem      pubsec.sql
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_sec - Utitility procedures/functions to provide security
Rem                     to procedures accessed via the PL/SQL Agent.
Rem
Rem    NOTES
Rem      This package allows the developer to access the Web client's
Rem      authentication information to perform authorization check before
Rem      a stored procedure is invoked by the PL/SQL Agent.
Rem
Rem      Though these procedures and functions are intended to be used by
Rem      the authorization callback procedures, they can be called by the
Rem      execution procedures as well.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     mpal       05/12/97 -  Add Custom authentication
Rem     rpang      06/29/96 -  Creation
Rem

create or replace package OWA_SEC is

     /*******************************************************************/
    /* PL/SQL Agent's authorization schemes                            */
   /*******************************************************************/
   NO_CHECK    constant integer := 1; /* no authorization check             */
   GLOBAL      constant integer := 2; /* global check by a single procedure */
   PER_PACKAGE constant integer := 3; /* use auth procedure in each package */
   CUSTOM      constant integer := 4; /* use custom auth procedure          */
                                      /*              owa_custom.authorize  */

     /*******************************************************************/
    /* Procedure to specify the PL/SQL Agent's authorization scheme    */
   /*******************************************************************/
   procedure set_authorization(scheme in integer);

     /*******************************************************************/
    /* Functions to obtain the Web client's authentication information */
   /*******************************************************************/
   function get_user_id         return varchar2;
   function get_password        return varchar2;
   function get_client_ip       return owa_util.ip_address;
   function get_client_hostname return varchar2;

     /*******************************************************************/
    /* Procedure to specify the dynamic page's protection realm        */
   /*******************************************************************/
   procedure set_protection_realm(realm in varchar2);

end;
/
show errors

