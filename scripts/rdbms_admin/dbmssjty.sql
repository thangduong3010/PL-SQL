Rem
Rem $Header: dbmssqljtype.sql 14-nov-2000.13:09:44 varora Exp $
Rem
Rem dbmssqljtype.sql
Rem
Rem  Copyright (c) Oracle Corporation 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmssqljtype.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mmorsi      02/21/01 - Adding the validation of the class name.
Rem    varora      11/14/00 - missing /
Rem    varora      09/27/00 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_sqljtype AS

  FUNCTION VALIDATETYPE(typeName varchar2, schemaName varchar2) return number;

  FUNCTION VALIDATECLASS(supertoid RAW, schemaName varchar2, className varchar2) return number;

END dbms_sqljtype;
/
