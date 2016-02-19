CREATE OR REPLACE TRIGGER employeeIntegrityRow
   AFTER DELETE OR UPDATE OF ssn
   ON employee
   FOR EACH ROW
BEGIN
   supervisor.deleteIdx := supervisor.deleteIdx + 1;

   supervisor.deleteList (supervisor.deleteIdx) := :old.ssn;
END employeeIntegrityRow;
/

CREATE OR REPLACE TRIGGER employeeIntegrityStatement
   AFTER DELETE OR UPDATE OF ssn
   ON employee
BEGIN
   supervisor.replaceSupervisor;

   supervisor.deleteList := supervisor.emptyArray;
   supervisor.deleteIdx := 0;
END employeeIntegrityStatement;
/