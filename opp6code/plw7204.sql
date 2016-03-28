ALTER SESSION SET PLSQL_WARNINGS = 'ENABLE:ALL'
/
CREATE OR REPLACE FUNCTION plw7204
   RETURN PLS_INTEGER
AS
   l_count PLS_INTEGER;
BEGIN
   SELECT COUNT(*) INTO l_count
     FROM employees
	WHERE salary = '10000';
   RETURN l_count;	
END plw7204;
/

SHOW ERRORS FUNCTION plw7204