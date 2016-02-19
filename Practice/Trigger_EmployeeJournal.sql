CREATE OR REPLACE TRIGGER employee_journal
   AFTER INSERT OR UPDATE OF salary
   ON employee
   FOR EACH ROW
   WHEN (new.salary > 70000)
BEGIN
   INSERT INTO audit_entry (entry_date,
                            entry_user,
                            entry_text,
                            old_value,
                            new_value)
        VALUES (SYSDATE,
                USER,
                'Salary > 70000 for ' || :new.lname,
                :old.salary,
                :new.salary);
END;