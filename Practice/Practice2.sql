/* Finally fixed */
SET SERVEROUTPUT ON

DECLARE
   v_locid       HR.LOCATIONS.COUNTRY_ID%TYPE;
   v_message     VARCHAR2 (50);
   v_mess        VARCHAR2 (60)
                    := 'Ok, you can visit the following states/provinces:';
   v_counter     NUMBER (2);

   TYPE state_type_table IS TABLE OF HR.LOCATIONS.STATE_PROVINCE%TYPE
      INDEX BY PLS_INTEGER;

   state_visit   state_type_table;

   CURSOR state_cursor
   IS
      SELECT state_province
        FROM HR.LOCATIONS
       WHERE country_id = v_locid;
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
         WHEN 'US' THEN 'The United States'
         WHEN 'CA' THEN 'Canada'
         WHEN 'CH' THEN 'Switzerland'
         WHEN 'UK' THEN 'The United Kingdom'
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
      WHEN v_message = 'The United States'
      THEN
         GOTO state_choice;
      WHEN v_message = 'Canada'
      THEN
         GOTO state_choice;
      WHEN v_message = 'Switzerland'
      THEN
         GOTO state_choice;
      WHEN v_message = 'The United Kingdom'
      THEN
         GOTO state_choice;
   END CASE;

  <<state_choice>>
   OPEN state_cursor;

   FOR i IN 1 .. v_counter
   LOOP
      FETCH state_cursor INTO state_visit (i);
   END LOOP;

   CLOSE state_cursor;

   DBMS_OUTPUT.put_line (v_mess);

   FOR i IN 1 .. state_visit.COUNT ()
   LOOP
      DBMS_OUTPUT.put_line (state_visit (i));
   END LOOP;

  <<conclusion>>
   NULL;
EXCEPTION
   WHEN case_not_found
   THEN
      DBMS_OUTPUT.put_line ('Nothing to do here');
END;