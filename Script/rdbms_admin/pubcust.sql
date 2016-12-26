Rem  Copyright (c) 1995, 1996, 1997 by Oracle Corp.  All Rights Reserved.  
Rem
Rem   NAME
Rem     pubcust.sql - Oracle Web Agent PL/SQL customization package.
Rem   PURPOSE
Rem     Set up some values to be used by Web Agent packages.
Rem   NOTES
Rem
Rem   HISTORY
Rem     mpal   07/09/97 -  Creation
Rem

create or replace package OWA_CUSTOM is

   -- If your timezone is not in the list of standard timezones,
   -- then use dbms_server_gmtdiff to give the number of hours
   -- that your database server is ahead (or negative if behind)
   -- Greenwich Mean Time
   dbms_server_timezone constant varchar2(3) := 'PST';
   dbms_server_gmtdiff  constant number      := NULL;

       /************************************************************************/
      /*  Global PLSQL Agent Authorization callback function -                */
     /*     it is used when PLSQL Agent's authorization scheme is set to     */ 
    /*      GLOBAL or CUSTOM when there is no overriding OWA_CUSTOM package */
   /************************************************************************/
   function authorize return boolean;

end;
/
show errors
