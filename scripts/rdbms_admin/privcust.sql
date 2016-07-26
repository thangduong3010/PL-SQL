Rem  Copyright (c) 1996, 1997 by Oracle Corp.  All Rights Reserved.
Rem
Rem   NAME
Rem     privcust.sql - Oracle Web Agent PL/SQL customization package.
Rem   PURPOSE
Rem     Set up some values to be used by Web Agent packages.
Rem   NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     mpal       07/09/97 -  Creation
Rem

create or replace package body OWA_CUSTOM is

        /*********************************************************************/
       /*  Global PLSQL Agent Authorization callback function -             */
      /*     It is used when PLSQL Agent's authorization scheme is set to  */
     /*      GLOBAL or CUSTOM when there is overriding OWA_CUSTOM package.*/ 
    /*       This is a default implementation. User should modify.       */
   /*********************************************************************/
   function authorize return boolean is
   begin
      owa_sec.set_protection_realm('To-be-defined realm');
      return FALSE;
   end;

begin /* OWA_CUSTOM package customization */

   /*******************************************************************/
   /* Set the PL/SQL Agent's authorization scheme --                  */
   /*   This should be modified to reflect the authorization need of  */
   /*   your PLSQL Agent                                              */
   /*******************************************************************/
   owa_sec.set_authorization(OWA_SEC.NO_CHECK);

end;
/
show errors
