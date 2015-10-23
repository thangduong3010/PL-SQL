set serveroutput on;

DECLARE

	vFname MEMBERS.FIRSTNAME%TYPE;
    vLname MEMBERS.LASTNAME%TYPE;
    vSalary MEMBERS.SALARY%TYPE;

BEGIN
	-- initialise variable
    SELECT firstname, lastname, salary
    INTO vFname, vLname, vSalary
    FROM members
    WHERE memberid = 503;
    
    -- print output
    DBMS_OUTPUT.PUT_LINE('Full name: ' || vFname || ' ' || vLname);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || vSalary || '$');
END;