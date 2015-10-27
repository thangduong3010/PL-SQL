set serveroutput on;

DECLARE
	-- using %TYPE
	vFname MEMBERS.FIRSTNAME%TYPE;
    vLname MEMBERS.LASTNAME%TYPE;
    vSalary MEMBERS.SALARY%TYPE;
    
    -- using %ROWTYPE
    x_cust customers%ROWTYPE;

BEGIN
	-- initialise variable
    SELECT firstname, lastname, salary
    INTO vFname, vLname, vSalary
    FROM members
    WHERE memberid = 503;
    
    SELECT type, name, address
    INTO x_cust.type, x_cust.name, x_cust.address
    FROM customers
    WHERE customerid = 102;
    
    -- print output
    DBMS_OUTPUT.PUT_LINE('Full name: ' || vFname || ' ' || vLname);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || vSalary || '$');
    DBMS_OUTPUT.PUT_LINE(x_cust.type || ' named ' || x_cust.name || ' is located at ' || x_cust.address);
    
END;