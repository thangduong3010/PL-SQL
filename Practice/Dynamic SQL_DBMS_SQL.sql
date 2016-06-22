create or replace procedure create_table(
	p_table_name varchar2,
	p_col_specs varchar2)
is
begin
	execute immediate 'CREATE TABLE ' || p_table_name || ' (' || p_col_specs || ')';
end;
/

create or replace procedure add_column(
	p_table_name varchar2,
	p_col_specs varchar2)
is
	v_cmd varchar2(100) := 'ALTER TABLE ' || p_table_name || ' ADD ' || p_col_specs;
begin
	execute immediate v_cmd;
end;
/

create or replace function del_rows(p_table_name varchar2)
return number
is
begin
	execute immediate 'DELETE FROM ' || p_table_name;
	return sql%rowcount;
end;
/

create or replace procedure add_row(
	p_table_name varchar2,
	p_id number,
	p_name varchar2)
is
begin
	execute immediate 'INSERT INTO ' || p_table_name || ' VALUES (:1, :2)'
	using p_id, p_name;
end;
/

create or replace function get_emp(p_emp_id number)
return hr.employees%rowtype
is
	v_stmt varchar2(100);
	v_emprec hr.employees%rowtype;
begin
	v_stmt := 'SELECT * FROM hr.employees ' || ' WHERE employee_id = :p_emp_id';
	execute immediate v_stmt into v_emprec using p_emp_id;
	return v_emprec;
end;
/

create or replace function annual_sal(p_emp_id number)
return number
is
	v_plsql varchar2(200) := 'DECLARE ' ||
								' rec_emp hr.employees%rowtype; ' ||
								'BEGIN ' ||
								' rec_emp := get_emp(:empid); ' ||
								' :res := rec_emp.salary * 12; ' ||
								' END;';
	v_result number;
begin
	execute immediate v_plsql using in p_emp_id, out v_result;
	return v_result;
end;
/

create or replace function delete_all_rows(
	p_table_name varchar2)
return number
is
	v_cur_id number;
	v_rows_del number;
begin
	v_cur_id := dbms_sql.open_cursor; -- open a new cursor and return a cursor ID
	dbms_sql.parse(v_cur_id, 'DELETE FROM ' || p_table_name, dbms_sql.native); -- this is a must
	v_rows_del := dbms_sql.execute(v_cur_id); -- execute statement
	dbms_sql.close_cursor(v_cur_id); -- close cursor

	return v_rows_del;
end;
/


create or replace procedure insert_row(
	p_table_name varchar2,
	p_id varchar2,
	p_name varchar2,
	p_region number)
is
	v_cur_id number;
	v_stmt varchar2(200) := 'INSERT INTO ' || p_table_name || ' VALUES (:cid, :cname, :rid)';;
	v_rows_added number;
begin
	v_cur_id := dbms_sql.open_cursor;
	dbms_sql.parse(v_cur_id, v_stmt, dbms_sql.native);
	dbms_sql.bind_variable(v_cur_id, ':cid', p_id);
	dbms_sql.bind_variable(v_cur_id, ':cname', p_name);
	dbms_sql.bind_variable(v_cur_id, ':rid', p_region);

	v_rows_added :- dbms_sql.execute(v_cur_id);
	dbms_sql.close_cursor(v_cur_id);
	dbms_output.put_line(v_rows_added || ' rows added');
end;
/
	