Rem
Rem $Header: dbmsncdb.sql 27-may-2005.13:30:02 lvbcheng Exp $
Rem
Rem dbmsncdb.sql
Rem
Rem Copyright (c) 2002, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsncdb.sql - DBMS setup package for Natively Compiling a Database
Rem                      and the reverse.
Rem    DESCRIPTION
Rem      This package provides setup routines for compiling a database
Rem    native and back to interpreted.
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * This package is to be used in conjunction with dbmsupgnv.sql
Rem        and dbmsupgin.sql and not on its own. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lvbcheng    05/17/05 - Comments
Rem    lvbcheng    04/14/05 - Add package spec parameterization 
Rem    lvbcheng    07/18/02 - lvbcheng_bug-2188517
Rem    lvbcheng    04/05/02 - Add invoker rights
Rem    lvbcheng    02/05/02 - Created
Rem

create or replace package sys.dbmsncdb authid current_user is

  /* 
     DESCRIPTION:
     Database is not open for migration. 

     If you encounter this exception, execute "SHUTDOWN", "STARTUP UPGRADE" 
     and re-execute the setup call (setup_for_native_compile or 
     setup_for_interpreted_compile)

   */
  procedure setup_for_native_compile(bodyOnly boolean default TRUE);
  /* 
     DESCRIPTION:
     Setup database for native compile. By default (bodyOnly set to TRUE),
     only the following kinds of objects will be setup for native compile:
       PROCEDURE
       FUNCTION
       TRIGGER
       PACKAGE BODY
       TYPE BODY
     That is, PACKAGE specifications and TYPE specifications are excluded.
     If bodyOnly is FALSE then PACKAGE specifications are included in the
     list of objects setup for native compilation while TYPE specifications
     continue to be excluded. 

     A TYPE specification contains no executable code, so compiling it 
     native does not provide any performance benefits.
   */
  procedure setup_for_interpreted_compile;
  /* 
     DESCRIPTION:
     Setup database for interpreted compile. All code units, that is:
       PROCEDURE
       FUNCTION
       TRIGGER
       PACKAGE
       PACKAGE BODY
       TYPE
       TYPE BODY
     will be setup for INTERPRETED compile. Note that PACKAGE specifications
     and TYPE specifications are also affected.
   */

end dbmsncdb;
/
show errors;
