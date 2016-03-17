REM $Id: lopu.pks,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 

REM Spec of version of lopu package that adds programs from ch05.

CREATE OR REPLACE PACKAGE lopu
AS
   linefeed CONSTANT VARCHAR2(1) := CHR(10);

   SUBTYPE sqlboolean IS VARCHAR2(1);
   sqltrue CONSTANT sqlboolean := 'T';
   sqlfalse CONSTANT sqlboolean := 'F';

   PROCEDURE set_dflt_date_format(date_format IN VARCHAR2);

   FUNCTION dflt_date_format
      RETURN VARCHAR2;

   FUNCTION is_string (what IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION is_number (what IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION is_date (what IN VARCHAR2,
      date_format IN VARCHAR2 DEFAULT dflt_date_format)
      RETURN BOOLEAN;

   PROCEDURE assert (
      condition_in IN BOOLEAN,
      message_in IN VARCHAR2,
      exception_in IN PLS_INTEGER);

   PROCEDURE assert (
      condition_in IN BOOLEAN,
      message_in IN VARCHAR2,
      exception_in IN VARCHAR2 DEFAULT 'VALUE_ERROR');

   PROCEDURE assert_notnull (tested_variable IN VARCHAR2,
      error_msg IN VARCHAR2 DEFAULT NULL);
   PROCEDURE assert_notnull (tested_variable IN NUMBER,
      error_msg IN VARCHAR2 DEFAULT NULL);
   PROCEDURE assert_notnull (tested_variable IN DATE,
      error_msg IN VARCHAR2 DEFAULT NULL);

   FUNCTION str_fits (what IN VARCHAR2,
      minlength IN NUMBER,
      maxlength IN NUMBER)
      RETURN BOOLEAN;

   PROCEDURE makewhere (where_clause IN OUT VARCHAR2,
      column_name IN VARCHAR2, column_value IN VARCHAR2,
      datatype IN VARCHAR2 DEFAULT 'STRING',
      dataformat IN VARCHAR2 DEFAULT NULL,
      rewrite_op IN BOOLEAN DEFAULT TRUE);

   FUNCTION esc (text IN VARCHAR2)
      RETURN VARCHAR2;

END lopu;
/

SHOW ERRORS

