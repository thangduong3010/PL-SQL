Rem
Rem $Header: rdbms/admin/dbmsasrt.sql /st_rdbms_11.2.0/1 2013/05/17 19:43:21 lvbcheng Exp $
Rem
Rem dbmsasrt.sql
Rem
Rem Copyright (c) 2005, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsasrt.sql - DBMS_ASSERT
Rem
Rem    DESCRIPTION
Rem      String value checking package
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr     05/10/13 - Backport lvbcheng_bug-16172466 from main
Rem    lvbcheng   03/08/05 - lvbcheng_noop_enhancement
Rem    lvbcheng   03/01/05 - Split DBMS_ASSERT into its own file and add NOOP 
Rem                          enhancement 
Rem    lvbcheng   02/18/05 - Add syntax def for DBMS_ASSERT.SIMPLE_SQL_NAME
Rem                          and QUALIFIED_SQL_NAME
Rem    lvbcheng   02/14/05 - capitalization option: DBMS_ASSERT.ENQUOTE_NAME
Rem    lvbcheng   02/02/05 - Add error message support to DBMS_ASSERT 
Rem    dbronnik   01/24/05 - Fix comments in dbms_assert
Rem    dbronnik   12/02/04 - Add dbms_assert
Rem

--
-- Package DBMS_ASSERT
--
-- This package provides functions which assert various properties
-- of the input value.  If the condition which determines the property
-- asserted in a function is not met then a value error is raised.
-- Otherwise the input value is returned via return value.
-- Most functions return the value unchanged, however, several functions
-- modify the value.
--

create or replace package DBMS_ASSERT AUTHID CURRENT_USER is

  -- Predefined exceptions

  INVALID_SCHEMA_NAME exception;
    pragma EXCEPTION_INIT(INVALID_SCHEMA_NAME, -44001);
  INVALID_OBJECT_NAME exception;
    pragma EXCEPTION_INIT(INVALID_OBJECT_NAME, -44002);
  INVALID_SQL_NAME exception;
    pragma EXCEPTION_INIT(INVALID_SQL_NAME, -44003);
  INVALID_QUALIFIED_SQL_NAME exception;
    pragma EXCEPTION_INIT(INVALID_QUALIFIED_SQL_NAME, -44004);

  --
  -- NOOP.
  --
  -- This function returns the value without any checking.
  --

  function NOOP(Str varchar2 CHARACTER SET ANY_CS)
           return varchar2 CHARACTER SET Str%CHARSET;

  function NOOP(Str clob CHARACTER SET ANY_CS)
           return clob CHARACTER SET Str%CHARSET;

  --
  -- SIMPLE_SQL_NAME
  --
  -- Verify that the input string is a simple SQL name:
  -- 1. The name must begin with an alphabetic character.
  -- 2. It may contain alphanumeric characters as well as 
  --    the characters _, $, and # in the second and subsequent
  --    character positions. 
  -- 3. Quoted SQL names are also allowed.
  -- 4. Quoted names must be enclosed in double quotes.
  -- 5. Quoted names allow any characters between the quotes.
  -- 6. Quotes inside the name are represented by two quote
  --    characters in a row, e.g. "a name with "" inside"
  --    is a valid quoted name.
  -- 7. The input parameter may have any number of leading 
  --    and/or trailing white space characters.
  --
  -- Note: The length of the name is not checked.
  --
  -- EXCEPTIONS:
  -- ORA-44003: string is not a simple SQL name

  function SIMPLE_SQL_NAME(Str varchar2 CHARACTER SET ANY_CS)
           return varchar2 CHARACTER SET Str%CHARSET;

  --
  -- QUALIFIED_SQL_NAME
  --
  -- Verify that the input string is a qualified SQL name.
  -- A qualified SQL name <qualified name> can be expressed by the 
  -- following grammar:
  --
  -- <local qualified name> ::= <simple name> {'.' <simple name>}
  -- <database link name> ::= <local qualified name> ['@' <connection string>]
  -- <connection string> ::= <simple name>
  -- <qualified name> ::= <local qualified name> ['@' <database link name>] 

  --
  -- EXCEPTIONS:
  -- ORA-44004: string is not a qualified SQL name

  function QUALIFIED_SQL_NAME(Str varchar2 CHARACTER SET ANY_CS)
           return varchar2 CHARACTER SET Str%CHARSET;

  --
  -- SCHEMA_NAME
  --
  -- This function verifies that the input string is an existing
  -- schema name.
  -- Note:
  -- Please be aware that by definition, a schema name need not
  -- be just a simple sql name. For example, "FIRST LAST" is a valid
  -- schema name. As a consequence, care must be taken to quote the
  -- output of schema name before concatenating it with SQL text.
  --
  -- EXCEPTIONS:
  -- ORA-44001: Invalid schema name

  function SCHEMA_NAME(Str varchar2 CHARACTER SET ANY_CS)
           return varchar2 CHARACTER SET Str%CHARSET;

  --
  -- SQL_OBJECT_NAME
  --
  -- This function verifies that the input parameter string
  -- is a qualified SQL identifier of an existing SQL object.
  --
  -- EXCEPTIONS:
  -- ORA-44002: Invalid object name

  function SQL_OBJECT_NAME(Str varchar2 CHARACTER SET ANY_CS)
           return varchar2 CHARACTER SET Str%CHARSET;

  --
  -- ENQUOTE_NAME
  --
  -- This function encloses a name in double quotes.  No additional
  -- quotes are added if the name was already in quotes. Verify that
  -- the resulting quoted identifier is a legal quoted identifier
  -- as defined by SQL.
  -- Str        (IN) - string to enquote
  -- capitalize (IN) - if true or defaulted, alphabetic characters of 
  --                   Str which were not in quotes are translated to 
  --                   upper case.

  function ENQUOTE_NAME(Str varchar2, capitalize boolean default TRUE)
           return varchar2;

  --
  -- ENQUOTE_LITERAL
  --
  -- Enquote a string literal.  Add leading and trailing single quotes
  -- to a string literal.  Verify that all single quotes except leading
  -- and trailing characters are paired with adjacent single quotes.

  function ENQUOTE_LITERAL(Str varchar2)
           return varchar2;

end DBMS_ASSERT;
/
show errors;
create or replace public synonym DBMS_ASSERT for SYS.DBMS_ASSERT;
grant execute on DBMS_ASSERT to public;
