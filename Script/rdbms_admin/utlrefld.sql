Rem
Rem $Header: utlrefld.sql 20-aug-97.18:42:10 sabburi Exp $
Rem
Rem utlrefld.sql
Rem
Rem  Copyright (c) Oracle Corporation 1997, 1998. All Rights Reserved.
Rem
Rem    NAME
Rem      utlrefld.sql - Load UTL_REF package on the server
Rem
Rem    DESCRIPTION
Rem      Installs the utl_ref package on the rdbms.
Rem
Rem    NOTES
Rem      Must be executed as SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rxgovind    03/25/98 - merge from 8.0.5
Rem    sabburi     08/20/97 - installation of utl_ref package
Rem    sabburi     08/20/97 - Created
Rem

create or replace library DBMS_UTL_REF_LIB TRUSTED as STATIC;
/
@@utlref.plb
@@prvtref.plb
