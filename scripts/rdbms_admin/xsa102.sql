Rem
Rem $Header: xsa102.sql 04-oct-2007.14:31:45 rburns Exp $
Rem
Rem xsa102.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      xsa102.sql - XS After reload upgrade actions
Rem
Rem    DESCRIPTION
Rem      The script runs after xsrelod.sql to perform upgrade
Rem      actions requiring XS packages and views
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      10/04/07 - post reload upgrade actions
Rem    rburns      10/04/07 - Created
Rem


Rem =======================================================
Rem Stage 1: upgrade from 10.2
Rem =======================================================



Rem =======================================================
Rem Stage 1: upgrade from next release
Rem =======================================================

@@xsa111


