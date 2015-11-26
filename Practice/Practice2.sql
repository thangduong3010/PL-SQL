SET SERVEROUTPUT ON

DECLARE
   v_locid       HR.LOCATIONS.COUNTRY_ID%TYPE;
   v_message     VARCHAR2 (50);
   v_mess        VARCHAR2 (60) := 'Ok, you can visit the following state:';
   v_counter     NUMBER (2);

   TYPE state_type_table IS TABLE OF HR.LOCATIONS.STATE_PROVINCE%TYPE
      INDEX BY PLS_INTEGER;

   state_visit   state_type_table;
BEGIN
   SELECT country_id
     INTO v_locid
     FROM hr.locations
    WHERE country_id = UPPER ('&enter_id') AND ROWNUM <= 1;



   -- CASE selector
   v_message :=
      CASE v_locid
         WHEN 'MX' THEN 'Mexico'
         WHEN 'BR' THEN 'Brazil'
         WHEN 'IN' THEN 'India'
         WHEN 'DE' THEN 'Germany'
         ELSE 'NULL'
      END;

   DBMS_OUTPUT.put_line ('Ok, so you want to go to ' || v_message || ', eh?');

     SELECT COUNT (*)
       INTO v_counter
       FROM hr.locations
   GROUP BY country_id
     HAVING country_id = v_locid;

   -- CASE search
   CASE
      WHEN v_message = 'Mexico'
      THEN
         GOTO state_choice;
      WHEN v_message = 'Brazil'
      THEN
         GOTO state_choice;
      WHEN v_message = 'India'
      THEN
         GOTO state_choice;
      WHEN v_message = 'Germany'
      THEN
         GOTO state_choice;
      ELSE
         DBMS_OUTPUT.put_line (
            'This country has a lot of states and I can''t handle it for now. And I''ll try to fix it');
         GOTO conclusion;
   END CASE;

  <<state_choice>>
   FOR i IN 1 .. v_counter
   LOOP
      SELECT state_province
        INTO state_visit (i)
        FROM HR.LOCATIONS
       WHERE country_id = v_locid;
   END LOOP;

   DBMS_OUTPUT.put_line (v_mess);

   FOR i IN 1 .. state_visit.COUNT ()
   LOOP
      DBMS_OUTPUT.put_line (state_visit (i));
   END LOOP;

  <<conclusion>>
   NULL;
END;