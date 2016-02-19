CREATE OR REPLACE TRIGGER EmployeeIntegrity FOR
   DELETE OR UPDATE OF ssn
   ON employee
   COMPOUND TRIGGER
   TYPE ssnArray IS TABLE OF employee.ssn%TYPE
      INDEX BY PLS_INTEGER;

   deleteList   ssnArray;
   deleteIdx    PLS_INTEGER := 0;
   AFTER EACH ROW
   IS
   BEGIN
      deleteIdx := deleteIdx + 1;
      deleteList (deleteIdx) := :old.ssn;
   END
   AFTER EACH ROW;

   AFTER STATEMENT
   IS
   BEGIN
      FOR i IN deleteList.FIRST .. deleteList.LAST
      LOOP
         UPDATE employee
            SET superssn =
                   (SELECT ssn
                      FROM employee
                     WHERE superssn IS NULL)
          WHERE superssn = deleteList (i);
      END LOOP;
   END
   AFTER STATEMENT;

END EmployeeIntegrity;