-- CASE Selector
SET SERVEROUTPUT ON

DECLARE
   v_grade       CHAR (1) := UPPER ('&grade');
   v_appraisal   VARCHAR2 (30);
   v_month       CHAR (3) := UPPER ('&enter_month');
BEGIN
	-- CASE expression - return a value
   v_appraisal :=
      CASE v_grade
         WHEN 'A' THEN 'Excellent'
         WHEN 'B' THEN 'Very Good'
         WHEN 'C' THEN 'Good'
         ELSE 'It must be really bad'
      END;

   DBMS_OUTPUT.put_line (
      'Grade: ' || v_grade || '. Appraisal: ' || v_appraisal);
	
   -- CASE statement - perform an action
   CASE v_month
      WHEN 'JAN'
      THEN
         DBMS_OUTPUT.put_line ('Thang mot');
      WHEN 'FEB'
      THEN
         DBMS_OUTPUT.put_line ('Thang hai');
      WHEN 'MAR'
      THEN
         DBMS_OUTPUT.put_line ('Thang ba');
      ELSE
         DBMS_OUTPUT.put_line ('Khong biet');
   END CASE;
END;