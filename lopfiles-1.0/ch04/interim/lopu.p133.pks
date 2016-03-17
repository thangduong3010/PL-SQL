REM $Id: lopu.p133.pks,v 1.1 2001/11/30 23:10:38 bill Exp $
REM From "Learning Oracle PL/SQL" page 133

REM Spec of first version of general-purpose utilities package

CREATE OR REPLACE PACKAGE lopu
AS

   FUNCTION is_number (what IN VARCHAR2)
   RETURN BOOLEAN;

END lopu;
/

SHOW ERRORS

