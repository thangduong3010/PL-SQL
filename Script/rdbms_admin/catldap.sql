Rem
Rem $Header: catldap.sql 07-jan-2000.19:15:20 akolli Exp $
Rem
Rem catldap.sql
Rem
Rem  Copyright (c) Oracle Corporation 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      catldap.sql - CATalog for LDAP pl/sql API
Rem
Rem    DESCRIPTION
Rem      Contains scripts needed to use the PL/SQL LDAP API
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem       akolli   01/07/00 - PL/SQL LDAP API catalog
Rem                01/07/00 - Created
Rem

Rem 
Rem LDAP API header 
Rem 
@@prvtldh.plb

Rem
Rem LDAP API package declaration
Rem
@@dbmsldap.sql

Rem
Rem LDAP API package body
Rem
@@prvtldap.plb

