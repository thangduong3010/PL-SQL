Rem
Rem $Header: plsql/admin/utlident.sql /main/4 2009/09/28 10:43:12 sylin Exp $
Rem
Rem utlident.sql
Rem
Rem Copyright (c) 2007, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utlident.sql - PL/SQL Package for IDENTification information
Rem
Rem    DESCRIPTION
Rem      The package utl_ident specifies which Database or client PL/SQL is
Rem      running in. 
Rem
Rem    NOTES
Rem      This package is meant for use to conditional compilation of PL/SQL
Rem      packages that are supported by Oracle, TimesTen Database, and
Rem      possibly other clients like Oracle Forms.  This does not forbid other
Rem      uses but additions/changes to this package must be carefully
Rem      considered.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sylin       09/25/09 - add is_oracle_forms
Rem    sylin       02/26/08 - rename is_timesten_server to is_timesten
Rem    sylin       08/13/07 - Created
Rem

create or replace package utl_ident is

  /* A typical usage of these boolean constants is

         $if utl_ident.is_oracle_server $then
           code supported for Oracle Database
         $elsif utl_ident.is_timesten $then
           code supported for TimesTen Database
         $end
   */

  is_oracle_server     constant boolean := TRUE;
  is_oracle_client     constant boolean := FALSE;
  is_timesten          constant boolean := FALSE;
  is_oracle_forms      constant boolean := FALSE;

end utl_ident;
/

create or replace public synonym utl_ident for utl_ident
/
grant execute on utl_ident to public
/
