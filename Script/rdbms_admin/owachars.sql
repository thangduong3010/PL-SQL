Rem
Rem $Header: owachars.sql 17-jun-2001.15:46:58 pkapasi Exp $
Rem
Rem owachars.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      owachars.sql - OWA chars installation script
Rem
Rem    DESCRIPTION
Rem      This file allows OWA packages to support EBCDIC character set 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pkapasi     08/21/01 - Fix bug#1930471
Rem    pkapasi     06/17/01 - Created (as per bug#1778693)
Rem

 
DECLARE
 l_ret    INTEGER;
 l_csr    INTEGER;
 l_nlsc   v$nls_parameters.value%type;
 l_str    VARCHAR2(32000);
 
BEGIN
 
  SELECT value INTO l_nlsc FROM v$nls_parameters
   WHERE parameter = 'NLS_CHARACTERSET';
 
  IF l_nlsc LIKE '%EBCDIC%' THEN
    l_str := 'CREATE OR REPLACE PACKAGE owa_cx IS ';
    l_str := l_str || ' NL_CHAR CONSTANT varchar2(1) := chr(21); ';
    l_str := l_str || ' SP_CHAR CONSTANT varchar2(1) := chr(64); ';
    l_str := l_str || ' BS_CHAR CONSTANT varchar2(1) := chr(22); ';
    l_str := l_str || ' HT_CHAR CONSTANT varchar2(1) := chr(5); ';
    l_str := l_str || ' XP_CHAR CONSTANT varchar2(1) := chr(90); ';
    l_str := l_str || ' END owa_cx;';
  ELSE
    l_str := 'CREATE OR REPLACE PACKAGE owa_cx IS ';
    l_str := l_str || ' NL_CHAR CONSTANT varchar2(1) := chr(10); ';
    l_str := l_str || ' SP_CHAR CONSTANT varchar2(1) := chr(32); ';
    l_str := l_str || ' BS_CHAR CONSTANT varchar2(1) := chr(8); ';
    l_str := l_str || ' HT_CHAR CONSTANT varchar2(1) := chr(9); ';
    l_str := l_str || ' XP_CHAR CONSTANT varchar2(1) := chr(33); ';
    l_str := l_str || ' end owa_cx;';
  END IF;
 
  l_csr := dbms_sql.open_cursor;
  dbms_sql.parse(l_csr, l_str, dbms_sql.native);
  l_ret := dbms_sql.execute(l_csr);
  dbms_sql.close_cursor(l_csr);
 
END;
/
SHOW ERRORS;

