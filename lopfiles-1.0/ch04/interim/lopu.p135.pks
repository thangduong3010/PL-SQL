REM $Id: lopu.p135.pks,v 1.1 2001/11/30 23:10:38 bill Exp $
REM From "Learning Oracle PL/SQL" page 135

REM Spec for expanded version of lopu implied by page 135

CREATE OR REPLACE PACKAGE lopu
AS

   PROCEDURE set_dflt_date_format(date_format IN VARCHAR2);

   FUNCTION dflt_date_format
      RETURN VARCHAR2;

   FUNCTION is_number (what IN VARCHAR2)
      RETURN BOOLEAN;

   FUNCTION is_date (what IN VARCHAR2,
      date_format IN VARCHAR2 DEFAULT dflt_date_format)
      RETURN BOOLEAN;


END lopu;
/

SHOW ERRORS

