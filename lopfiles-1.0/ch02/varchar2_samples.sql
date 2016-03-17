REM $Id: varchar2_samples.sql,v 1.1 2001/11/30 23:08:30 bill Exp $
REM From "Learning Oracle PL/SQL" page 31

REM Illustrate that VARCHAR2 "equality" does not depend on
REM the declared length of the variables being compared

SET SERVEROUTPUT ON SIZE 1000000
DECLARE
   small_string VARCHAR2(4);
   line_of_text VARCHAR2(2000);
   biggest_string_allowed VARCHAR2(32767);
BEGIN
   biggest_string_allowed := 'Tiny';
   line_of_text := 'Tiny';

   IF biggest_string_allowed = line_of_text
   THEN
      DBMS_OUTPUT.PUT_LINE ('They match!');
   END IF;
END;
/

