SET SERVEROUTPUT ON

DECLARE
   TYPE location_type IS TABLE OF hr.locations.city%TYPE;

   offices   location_type;
BEGIN
   offices :=
      location_type ('Bombay',
                     'Tokyo',
                     'Singapore',
                     'Oxford');

   FOR i IN 1 .. offices.COUNT ()
   LOOP
      DBMS_OUTPUT.put_line (offices (i));
   END LOOP;
END;