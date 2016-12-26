Rem
Rem $Header: rstrconn.sql 10-aug-2004.14:24:52 pthornto Exp $
Rem
Rem rstrconn.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem    rstrconn.sql - SQL*Plus script to grant all the
Rem                   pre-10gR2 privielges back to CONNECT Role.
Rem
Rem    DESCRIPTION
Rem    This script should be run by a user who is a SYSDBA or has the
Rem    DBA role granted to them.
Rem
Rem    NOTES
Rem    By default, 10gR2 and higher only grants CREATE SESSION
Rem    to CONNECT. This script can be used to restore
Rem    pre-10GR2 CONNECT privileges
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pthornto    08/10/04 - pthornto_sqlbsq_connect_deprecate
Rem    pthornto    08/10/04 - Created
Rem

GRANT create session, create table, create view, create synonym,
  create database link, create cluster, create sequence, alter session
  TO CONNECT;
commit;

