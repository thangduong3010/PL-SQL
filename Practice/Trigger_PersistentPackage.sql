CREATE OR REPLACE PACKAGE supervisor
AS
   TYPE ssnArray IS TABLE OF employee.ssn%TYPE
      INDEX BY PLS_INTEGER;

   deleteList   ssnArray;
   emptyArray   ssnArray;
   deleteIdx    PLS_INTEGER := 0;

   PROCEDURE replaceSupervisor;
END supervisor;
/

CREATE OR REPLACE PACKAGE BODY supervisor
AS
   PROCEDURE replaceSupervisor
   IS
   BEGIN
      FOR i IN supervisor.deleteList.FIRST .. supervisor.deleteList.LAST
      LOOP
         UPDATE employee
            SET superssn =
                   (SELECT DISTINCT ssn
                      FROM employee
                     WHERE superssn IS NULL)
          WHERE superssn = supervisor.deleteList (i);
      END LOOP;
   END replaceSupervisor;
END supervisor;
/