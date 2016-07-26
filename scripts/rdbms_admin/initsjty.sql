Rem
Rem $Header: initsqljtype.sql 28-sep-2000.11:58:14 varora Exp $
Rem
Rem initsqljtype.sql
Rem
Rem  Copyright (c) Oracle Corporation 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      initsqljtype.sql - initialization for sqlj types
Rem
Rem    DESCRIPTION
Rem      load java classes required for sqljtype validation 
Rem      and generation of helper classes.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    varora      09/01/00 - Created
Rem

call sys.dbms_java.loadjava('-v -r rdbms/jlib/sqljtype.jar');

