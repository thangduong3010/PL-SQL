REM $Id: lopu.p133.pkb,v 1.1 2001/11/30 23:10:38 bill Exp $
REM From "Learning Oracle PL/SQL" page 133

REM Body of first version of general utilities package

CREATE OR REPLACE PACKAGE BODY lopu
AS
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

END lopu;
/

SHOW ERRORS

