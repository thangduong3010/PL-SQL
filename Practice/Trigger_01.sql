create or replace trigger secure_emp
	before insert on hr.employees
begin
	if ((to_char(sysdate, 'DY') in ('SAT', 'SUN')) or (to_char(sysdate, 'hh24:mi') not between '08:00' and '18:00')) then
		raise_application_error(-20500, 'You may insert ' || ' into EMPLOYEES table only during normal business hours.');
	end if;
end;
/


create or replace trigger secure_emp
	before insert or update or delete on hr.employees
begin
	if ((to_char(sysdate, 'DY') in ('SAT', 'SUN')) or (to_char(sysdate, 'hh24:mi') not between '08:00' and '18:00')) then
		if deleting then 
			raise_application_error(-20502, 'You are not authorised to delete!');
		elsif inserting then
			raise_application_error(-20503, 'You may insert into EMPLOYEES table only during normal business hours.');
		else
			raise_application_error(-20504, 'You may update EMPLOYEES table only during normal business hours.');
		end if;
	end if;
end;
/


create or replace trigger restrict_salary
	before insert or update of salary on hr.employees
	for each row
begin
	if not (:new.job_id in ('AD_PRES', 'AD_VP')) and :new.salary > 15000 then
		raise_application_error(-20505, 'Employee cannot earn more than $15,000');
	end if;
end;
/


create or replace trigger audit_emp_values
	after delete or insert or update on hr.employees
	for each row
begin
	insert into audit_emp(user_name, time_stamp, id, old_last_name, new_last_name, old_title, new_title, old_salary, new_salary)
		values (user, sysdate, :old.employee_id, :old.last_name, :new.last_name, :old.job_id, :new.job_id, :old.salary, :new.salary);
end;
/


create or replace trigger derive_commission_pct
	before insert or update of salary on hr.employees
	for each row
	when (new.job_id = 'SA_REP') -- no need to use : here because it's outside PL/SQL block
begin
	if inserting then
		:new.commission_pct := 0;
	elsif :old.commission_pct is null then
		:new.commission_pct := 0;
	else
		:new.commission_pct := :old.commission_pct + 0.05;
	end if;
end;
/


-- INSTEAD OF Trigger
create or replace trigger new_emp_dept
	instead of insert or update or delete on emp_details
	for each row
begin
	if inserting then
		insert into new_emps values (:new.employee_id, :new.last_name, :new.salary, :new.department_id);

		update new_depts
			set dept_sal = dept_sal + :new.salary;
		where department_id = :new.department_id;
	elsif deleting then
		delete from new_emps
			where employee_id = :old.employee_id;

		update new_depts
			set dept_sal = dept_sal - :old.salary
			where department_id = :old.department_id;
	elsif updating ('salary') then
		update new_emps
			set salary = :new.salary
			where employee_id = :old.employee_id;

		update new_depts
			set dept_sal = dept_sal + (:new.salary - :old.salary)
			where department_id = :old.department_id;
	elsif updating ('department_id') then
		update new_emps
			set department_id = :new.department_id
			where employee_id = :old.employee_id;

		update new_depts
			set dept_sal = dept_sal - :old.salary
			where department_id = :old.department_id;

		update new_depts
			set dept_sal = dept_sal + :new.salary
			where department_id = :new.department_id;
	end if;
end;
/




-- COMPOUND TRIGGER
create or replace trigger check_salary
	for insert or update of salary, job_id
	on employees
	when (new.job_id != 'AD_PRES')
	compound trigger

	type salaries_t is table of hr.employees.salary%type;
	min_salaries salaries_t;
	max_salaries salaries_t;

	type department_ids_t is table of hr.employees.department_id%type;
	department_ids department_ids_t;

	type department_salaries_t is table of hr.employees.salary%type
		index by varchar2(80);
	department_min_salaries	department_salaries_t;
	department_max_salaries department_salaries_t;

	before statement is
		begin
			select min(salary), max(salary), nvl(department_id, -1)
				bulk collect into min_salaries, max_salaries, department_ids
			from hr.employees
			group by department_id;

			for i in 1..department_ids.count() loop
				department_min_salaries(department_ids(i)) := min_salaries(i);
				department_max_salaries(department_ids(i)) := max_salaries(i);
			end loop;
	end before statement;

	after each row is
		begin
			if :new.salary < department_min_salaries(:new.department_id) or :new.salary > department_max_salaries(:new.department_id) then
				raise_application_error(-20001, 'New salary is out of acceptable range');
			end if;
	end after each row;
end check_salary;
/


create or replace trigger logon_trig
	after logon on schema -- on database for all user
begin
	insert into log_trig_table(user_id, log_date, action)
		values (user, sysdate, 'Logging on');
end;
/

create or replace trigger logoff_trig
	before logoff on schema
begin
	insert into log_trig_table(user_id, log_date, action)
		values (user, sysdate, 'Logging off');
end;
/