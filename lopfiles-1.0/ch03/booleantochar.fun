REM $Id: booleantochar.fun,v 1.1 2001/11/30 23:09:48 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 3

REM Simple utility to convert Boolean to strings in order to simplify
REM reuse of programs such as reporteq (see reporteqbool.p102.pro)

CREATE OR REPLACE FUNCTION booleantochar(is_true IN BOOLEAN) 
RETURN VARCHAR2
AS
BEGIN
   IF is_true
   THEN
      RETURN 'TRUE';
   ELSIF NOT is_true
   THEN
      RETURN 'FALSE';
   ELSE
      RETURN TO_CHAR(NULL);
   END IF;
END booleantochar;
/

SHOW ERRORS

