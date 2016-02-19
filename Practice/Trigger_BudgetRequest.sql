CREATE OR REPLACE TRIGGER budget_event
   AFTER INSERT OR UPDATE OF salary
   ON employee
   FOR EACH ROW
BEGIN
   IF UPDATING AND :new.salary != :old.salary
   THEN
      INSERT INTO budget_request (account_no, amount, description)
           VALUES (101, :new.salary - :old.salary, case when :new.salary - :old.salary > 0 then 'Employee raised' else 'Employee cut' end);
   ELSE
      INSERT INTO budget_request (account_no, amount, description)
           VALUES (101, :new.salary, 'New employee');
   END IF;
END;