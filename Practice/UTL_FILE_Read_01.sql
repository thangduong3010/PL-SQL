create or replace procedure read_file(
	p_dir varchar2,
	p_filename varchar2)
is
	f_file utl_file.file_type;
	v_buffer varchar2(200);
	v_lines pls_integer := 0;
begin
	dbms_output.put_line(' Start ');
	if not utl_file.is_open(f_file) then
		dbms_output.put_line(' Open ');
		f_file := utl_file.fopen(p_dir, p_filename, 'R');
		dbms_output.put_line(' Opened ');

		begin
			loop
				utl_file.get_line(f_file, v_buffer);
				v_lines := v_lines + 1;
				dbms_output.put_line(to_char(v_lines, '099') || ' ' || v_buffer);
			end loop;
		exception
			when no_data_found then
				dbms_output.put_line(' ** End of File **');
		end; -- end inner block

		dbms_output.put_line(v_lines || ' lines read from file');
		utl_file.fclose(f_file);
	end if;
end read_file;
/