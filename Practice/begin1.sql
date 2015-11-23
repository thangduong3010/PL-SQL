SET serveroutput ON

DECLARE
	EmpLname EMPLOYEE.LNAME%TYPE;
    EmpFname EMPLOYEE.FNAME%TYPE;
    EmpFullName VARCHAR2(50);
    
BEGIN
	EmpLname := 'Thang';
    EmpFname := 'Duong';
    EmpFullName := EmpLname || ' ' || EmpFname;
    
    dbms_output.put_line('Full name: ' || EmpFullName);
    
    -- reverse
    EmpLname := 'Duong';
    EmpFname := 'Thang';
    EmpFullName := EmpLname || ' ' || EmpFname;
    
    dbms_output.put_line('Reverse: ' || EmpFullName);
    
END;