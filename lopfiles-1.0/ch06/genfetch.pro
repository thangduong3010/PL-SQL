REM $Id: genfetch.pro,v 1.1 2001/11/30 23:10:54 bill Exp $
REM From "Learning Oracle PL/SQL" page 213

REM Procedure that illustrates a simple code generator

REM Note: As of Oracle9i, DBMS_OUTPUT.PUT_LINE still ignores leading
REM spaces.  That is, it will print '     xyz' and 'xyz'.  So the
REM formatting of the generated strings below is strictly for each of
REM comprehending *this* file, not the generated file.

CREATE OR REPLACE PROCEDURE genfetch (
   tab_in IN VARCHAR2,
   col_in IN VARCHAR2,
   pkey_in IN VARCHAR2
)
IS
   v_tabcol VARCHAR2 (100) := LOWER (tab_in || '.' || col_in);
   v_tabpkey VARCHAR2 (100) := LOWER (tab_in || '.' || pkey_in);
   v_pkeyin VARCHAR2 (100) := LOWER (pkey_in || '_in');
BEGIN
   DBMS_OUTPUT.PUT_LINE ('CREATE OR REPLACE FUNCTION one_' || col_in || ' (');
   DBMS_OUTPUT.PUT_LINE (
      '   ' || v_pkeyin || ' IN ' || v_tabpkey || '%TYPE)');
   DBMS_OUTPUT.PUT_LINE ('   RETURN ' || v_tabcol || '%TYPE');
   DBMS_OUTPUT.PUT_LINE ('IS');
   DBMS_OUTPUT.PUT_LINE ('   retval ' || v_tabcol || '%TYPE;');
   DBMS_OUTPUT.PUT_LINE ('BEGIN');
   DBMS_OUTPUT.PUT_LINE ('   SELECT ' || col_in);
   DBMS_OUTPUT.PUT_LINE ('     INTO retval');
   DBMS_OUTPUT.PUT_LINE ('     FROM ' || tab_in);
   DBMS_OUTPUT.PUT_LINE ('    WHERE ' || pkey_in || ' = ' || v_pkeyin || ';');
   DBMS_OUTPUT.PUT_LINE ('   RETURN retval;');
   DBMS_OUTPUT.PUT_LINE ('EXCEPTION');
   DBMS_OUTPUT.PUT_LINE ('   WHEN NO_DATA_FOUND');
   DBMS_OUTPUT.PUT_LINE ('   THEN');
   DBMS_OUTPUT.PUT_LINE ('      RETURN NULL;');
   DBMS_OUTPUT.PUT_LINE ('END;');
   DBMS_OUTPUT.PUT_LINE ('/');
END;
/

SHOW ERRORS

