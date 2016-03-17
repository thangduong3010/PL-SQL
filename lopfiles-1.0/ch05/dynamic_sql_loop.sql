REM $Id: dynamic_sql_loop.sql,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" page 172

REM Simple example of retrieving table data using dynamic SQL

DECLARE
   TYPE cur_t IS REF CURSOR;
   cur cur_t;
   brec books%ROWTYPE;
BEGIN
   OPEN cur FOR 'SELECT * FROM books';
   LOOP
      FETCH cur INTO brec;
      EXIT WHEN cur%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE('Processing ISBN ' || brec.isbn);
   END LOOP;
   CLOSE cur;
END;
/

