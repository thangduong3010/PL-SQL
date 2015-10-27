set serveroutput on;

DECLARE
	-- using TYPE..TABLE
    TYPE EmpSSNarray
    	IS TABLE of EMPLOYEE.ssn%TYPE
        INDEX BY SIMPLE_INTEGER;
    
    ManagementList EmpSSNarray;    
    WorkerList EmpSSNarray;

BEGIN
	SELECT superssn
    INTO ManagementList(1)
    FROM employee
    WHERE superssn IS NOT NULL
    AND ROWNUM <= 1;
    
    SELECT superssn
    INTO ManagementList(2)
    FROM employee
    WHERE superssn IS NOT NULL
    AND ROWNUM <= 1
    AND superssn <> ManagementList(1);
    
    SELECT essn
    INTO WorkerList(1)
    FROM works_on
    WHERE hours IS NOT NULL
    AND ROWNUM <= 1
    AND essn NOT IN (ManagementList(1), ManagementList(2));
    
    SELECT essn
    INTO WorkerList(2)
    FROM works_on
    WHERE hours IS NOT NULL
    AND ROWNUM <= 1
    AND essn NOT IN (ManagementList(1), ManagementList(2), WorkerList(1));
    
    -- print output
    DBMS_OUTPUT.PUT_LINE('Manager 1: ' || ManagementList(1));
    DBMS_OUTPUT.PUT_LINE('Manager 2: ' || ManagementList(2));
    DBMS_OUTPUT.PUT_LINE('Worker 1: ' || WorkerList(1));
	DBMS_OUTPUT.PUT_LINE('Worker 2: ' || WorkerList(2));
    
   
END; 
    