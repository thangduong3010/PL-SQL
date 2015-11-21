/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

DECLARE 
  TextRecord   VARCHAR2(255);
  TextFile     utl_file.FILE_TYPE;

  CURSOR EmployeeList IS
     SELECT LName, FName, Salary, DName
     FROM employee
     INNER JOIN department ON department.dnumber = employee.dno
     ORDER BY DName;

  TYPE EmployeeRecordType IS RECORD
     (EmpLast   employee.LName%TYPE,
      EmpFirst  employee.FName%TYPE,
      EmpSalary employee.Salary%TYPE,
      DeptName  department.DName%TYPE);

  EmployeeRecord   EmployeeRecordType;

BEGIN 
  OPEN EmployeeList;
  TextFile := utl_file.fopen (UPPER('TextDirectory'), 'Employees.csv', 'w', 32767);

  LOOP
    FETCH EmployeeList INTO EmployeeRecord;
    EXIT WHEN EmployeeList%NOTFOUND;

    TextRecord := EmployeeRecord.DeptName || ',' ||
                  EmployeeRecord.EmpLast  || ',' ||
                  EmployeeRecord.EmpFirst || ',' ||
                  EmployeeRecord.EmpSalary;
    utl_file.put (TextFile, TextRecord);
    utl_file.new_line (TextFile);
   END LOOP;

  CLOSE EmployeeList;
  utl_file.fclose (TextFile);

EXCEPTION
 when others then
    dbms_output.put_line (sqlcode);
    dbms_output.put_line (sqlerrm);
END; 
/

