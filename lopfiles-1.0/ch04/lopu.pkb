REM $Id: lopu.pkb,v 1.1 2001/11/30 23:20:19 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 4

REM Body of most package containing the most generic utilities used in the
REM book.  "lopu" = Learning Oracle PL/SQL Utilities.

CREATE OR REPLACE PACKAGE BODY lopu
AS

   dflt_date_format_private nls_session_parameters.value%TYPE;

   PROCEDURE set_dflt_date_format(date_format IN VARCHAR2)
   IS
   BEGIN
      dflt_date_format_private := date_format;
   END;

   FUNCTION dflt_date_format
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN dflt_date_format_private;
   END;

   FUNCTION is_string (what IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN TRUE;
   END;

   FUNCTION is_number (what IN VARCHAR2)
      RETURN BOOLEAN
   IS
      numtester NUMBER;
   BEGIN
      numtester := TO_NUMBER(what);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   FUNCTION is_date (what IN VARCHAR2,
      date_format IN VARCHAR2 DEFAULT dflt_date_format)
      RETURN BOOLEAN
   IS
      datetester DATE;
   BEGIN
      datetester := TO_DATE(what, date_format);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   FUNCTION str_fits (what IN VARCHAR2,
      minlength IN NUMBER,
      maxlength IN NUMBER)
      RETURN BOOLEAN
   IS
      lenwhat NUMBER := LENGTH(what);
   BEGIN
      IF (what IS NULL AND minlength = 0)
         OR
            (lenwhat >= minlength
            AND
            lenwhat <= maxlength)
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END str_fits;

BEGIN

   /* This section of a package will get executed automatically the very
   || first time that any part of the package is invoked.  So you can use
   || it for initializing variables.  (See page 321.)
   */

   SELECT VALUE INTO dflt_date_format_private
     FROM NLS_SESSION_PARAMETERS
    WHERE PARAMETER = 'NLS_DATE_FORMAT';

EXCEPTION
   WHEN OTHERS
   THEN NULL;

END lopu;
/

SHOW ERRORS

