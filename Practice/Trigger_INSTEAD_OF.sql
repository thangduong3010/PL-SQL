CREATE OR REPLACE TRIGGER manage_delete
   INSTEAD OF DELETE
   ON employee_department_info
BEGIN
   DELETE FROM employee
         WHERE ssn = :old.employee_ssn;
END;