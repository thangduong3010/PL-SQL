REM $Id: tut.pks,v 1.1 2001/11/30 23:09:49 bill Exp $
REM From "Learning Oracle PL/SQL" page 103

REM Package specification for "testing utilities" (tut)

CREATE OR REPLACE PACKAGE tut AS
   PROCEDURE reporteq (description IN VARCHAR2,
      expected_value IN VARCHAR2, actual_value IN VARCHAR2);

   PROCEDURE reporteq (description IN VARCHAR2,
      expected_value IN NUMBER, actual_value IN NUMBER);

   PROCEDURE reporteq (description IN VARCHAR2,
      expected_value IN DATE, actual_value IN DATE);

END;
/

SHOW ERRORS

