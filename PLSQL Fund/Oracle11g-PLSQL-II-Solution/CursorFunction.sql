/* 
Copyright (c) 2010 Sideris Courseware Corporation. All Rights Reserved.
Each instructor or student with access to this file must have purchased
a license to the corresponding Sideris Courseware textbook to which 
these files apply. All other use, broadcast, webcast, duplication or distribution
is prohibited and illegal.
*/

DECLARE
   TYPE WorkCursorType IS REF CURSOR;
   WorkCursor WorkCursorType;

   EmpLName   employee.LName%TYPE;
   EmpSalary  employee.Salary%TYPE;
   EmpPName   project.PName%TYPE;
   EmpHours   works_on.Hours%TYPE;

   CURSOR EmpWork IS
      SELECT LName, Salary, CURSOR(SELECT PName, Hours
                                   FROM works_on w
                                   INNER JOIN project p ON p.pnumber = w.pno
                                   WHERE w.essn = e.ssn) AS Work
      FROM employee e
      ORDER BY Lname;
BEGIN
  OPEN EmpWork;

    LOOP
      FETCH EmpWork INTO EmpLname, EmpSalary, WorkCursor;
      EXIT WHEN EmpWork%NOTFOUND;
      dbms_output.put_line ('Processing here for ' || EmpLname);

      LOOP
        FETCH WorkCursor INTO EmpPName, EmpHours;
        EXIT WHEN WorkCursor%NOTFOUND;
      dbms_output.put_line ('Processing here for '||EmpLname ||
                            ' and for project '|| EmpPname);
      END LOOP;

    END LOOP;

  CLOSE EmpWork;
END;
/

 