REM $Id: lopu.p136.pkb,v 1.1 2001/11/30 23:10:38 bill Exp $
REM From "Learning Oracle PL/SQL" page 135

REM Body for expanded version of lopu implied by page 135

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

