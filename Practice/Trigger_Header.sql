CREATE OR REPLACE TRIGGER DepartmentIntegrity
   BEFORE UPDATE OF mgrssn
   ON department
   FOR EACH ROW
CALL check_promotion (:new.mgrssn, :new.dnumber);