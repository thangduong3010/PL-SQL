set serveroutput on

declare
	EmpLname EMPLOYEE.LNAME%TYPE;
    EmpFname EMPLOYEE.FNAME%TYPE;
    EmpFullName varchar2(50);
    
begin
	EmpLname := 'Thang';
    EmpFname := 'Duong';
    EmpFullName := EmpLname || ' ' || EmpFname;
    
    dbms_output.put_line('Full name: ' || EmpFullName);
    
    -- reverse
    EmpLname := 'Duong';
    EmpFname := 'Thang';
    EmpFullName := EmpLname || ' ' || EmpFname;
    
    dbms_output.put_line('Reverse: ' || EmpFullName);
    
end;