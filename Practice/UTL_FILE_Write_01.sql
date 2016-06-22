create or replace procedure sal_status(
	p_dir in varchar2,
	p_filename in varchar2)
is
	f_file utl_file.file_type;

	cursor c_emp is
		select last_name, salary, deparment_id from hr.employees
		order by deparment_id;

	v_old_deptno hr.employees.deparment_id%type := 0;
begin
	f_file := utl_file.fopen(p_dir, p_filename, 'w');
	utl_file.put_line(f_file, 'REPORT: GENERATED ON ' || sysdate);
	utl_file.new_line(f_file);

	for emp_rec in c_emp loop
		if emp_rec.deparment_id != v_old_deptno then
			utl_file.put_line(f_file, 'DEPARTMENT: ' || emp_rec.deparment_id);
			utl_file.new_line(f_file);
		end if;

		utl_file.put_line(f_file, 'EMPLOYEE: ' || emp_rec.last_name || ' earns: ' || emp_rec.salary);
		v_old_deptno := emp_rec.deparment_id;
		utl_file.new_line(f_file);
	end loop;

	utl_file.put_line(f_file, '*** End of Report ***');
	utl_file.fclose(f_file);
exception
	when utl_file.invalid_filehandle then
		raise_application_error(-20001, 'Invalid file.');
	when utl_file.write_error then
		raise_application_error(-20002, 'Unable to write to file');
end sal_status;
/