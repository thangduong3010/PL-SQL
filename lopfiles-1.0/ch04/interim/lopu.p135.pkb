REM $Id: lopu.p135.pkb,v 1.1 2001/11/30 23:10:38 bill Exp $
REM From "Learning Oracle PL/SQL" page 135

REM Body for expanded version of lopu implied by page 135

CREATE OR REPLACE PACKAGE BODY lopu
AS
   dflt_date_format_private VARCHAR2(30) := 'DD-MON-YYYY';

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

END lopu;
/

SHOW ERRORS

