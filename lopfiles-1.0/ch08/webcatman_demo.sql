REM $Id$
REM From "Learning Oracle PL/SQL" page Chapter 8

REM Illustration of calling webcatman.catdata procedure to retrieve LOC
REM catalog data about a particular book

DECLARE
   buf VARCHAR2(32767);
   eol PLS_INTEGER;
   i PLS_INTEGER := 0;
   quickref_isbn CONSTANT VARCHAR2(16) := '1565924576';
BEGIN
   buf := webcatman.catdata(quickref_isbn,5);
   LOOP
      i := i + 1;
      eol := INSTR(buf, CHR(10));
      DBMS_OUTPUT.PUT_LINE(SUBSTR(buf,1, LEAST(255,eol-1)));
      buf := SUBSTR(buf, eol+1);
      EXIT WHEN buf IS NULL OR i = 100;
   END LOOP;
END;
/

