REM $Id: lopu.pks,v 1.1 2001/11/30 23:20:19 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 4

REM Spec of most package containing the most generic utilities used in the
REM book.  "lopu" = Learning Oracle PL/SQL Utilities.

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

   FUNCTION str_fits (what IN VARCHAR2,
      minlength IN NUMBER,
      maxlength IN NUMBER)
      RETURN BOOLEAN;

END lopu;
/

SHOW ERRORS

