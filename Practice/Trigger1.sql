CREATE OR REPLACE TRIGGER security_time_check
   BEFORE DELETE OR UPDATE
   ON employee
DECLARE
   dy_of_week   CHAR (3);
   hh_of_day    NUMBER (2);
BEGIN
   dy_of_week := TO_CHAR (SYSDATE, 'DY');
   hh_of_day := TO_CHAR (SYSDATE, 'HH24');

   IF dy_of_week IN ('THU', 'SUN') OR hh_of_day NOT BETWEEN 8 AND 17
   THEN
      raise_application_error (-20600,
                               'Transaction rejected due to security reason');
   END IF;
END;