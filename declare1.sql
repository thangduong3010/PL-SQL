set serveroutput on;

DECLARE
	
	-- declare constant
    cPhoneNumber CONSTANT VARCHAR2(12) := '01646651080';	

	-- declare variables
    vLname VARCHAR2(15) NOT NULL := 'Duong';
    vFname VARCHAR2(15) := 'Thang';
    vDoB DATE := '30-Oct-93';
    vSalary VARCHAR2(7) := '50000';
    --vMarriageStatus BOOLEAN := FALSE;
    
BEGIN
	DBMS_OUTPUT.PUT_LINE('Hello Mr.'|| vLname || '. Here is your information');
    DBMS_OUTPUT.PUT_LINE('Full name: ' || vFname || ' ' || vLname);
    DBMS_OUTPUT.PUT_LINE('Birthday: ' || vDoB);
    DBMS_OUTPUT.PUT_LINE('Phone: ' || cPhoneNumber);
    --DBMS_OUTPUT.PUT_LINE('Your marriage status: ' || vMarriageStatus);
    DBMS_OUTPUT.PUT_LINE('Salary: $' || vSalary);
    
END;
    