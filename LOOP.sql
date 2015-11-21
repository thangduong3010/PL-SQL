SET SERVEROUTPUT ON

BEGIN
   -- fixed loop
   FOR i IN 1 .. 10
   LOOP
      DBMS_OUTPUT.put_line ('Value no.' || i || ': ' || TO_NUMBER (11 - i));
   END LOOP;

   -- fixed reverse loop
   FOR i IN REVERSE 1 .. 10
   LOOP
      DBMS_OUTPUT.put_line ('Value no.' || i || ': ' || TO_NUMBER (11 - i));
   END LOOP;
END;