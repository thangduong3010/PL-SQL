SET SERVEROUTPUT ON

DECLARE
   TextRecord   VARCHAR2 (2000);
   TextFile     UTL_FILE.file_type;

   CURSOR EmployeeList
   IS
        SELECT lname,
               fname,
               salary,
               dname
          FROM employee e INNER JOIN department d ON d.dnumber = e.dno
      ORDER BY dname;

   TYPE EmployeeRecType IS RECORD
   (
      EmpLast     employee.lname%TYPE,
      EmpFirst    employee.fname%TYPE,
      EmpSalary   employee.salary%TYPE,
      DeptName    department.dname%TYPE
   );

   EmpRec       EmployeeRecType;
BEGIN
   OPEN EmployeeList;

   TextFile := UTL_FILE.fopen ('MY_DIR', 'Employees.csv', 'w');

   LOOP
      FETCH EmployeeList INTO EmpRec;

      EXIT WHEN EmployeeList%NOTFOUND;

      TextRecord :=
            EmpRec.DeptName
         || ','
         || EmpRec.EmpLast
         || ','
         || EmpRec.EmpFirst
         || ',$'
         || EmpRec.EmpSalary;

      UTL_FILE.PUT_line (TextFile, TextRecord);
   END LOOP;

   CLOSE EmployeeList;

   UTL_FILE.fclose (TextFile);
EXCEPTION
   WHEN OTHERS
   THEN
      DBMS_OUTPUT.put_line (SQLCODE);
      DBMS_OUTPUT.put_line (SQLERRM);
END;