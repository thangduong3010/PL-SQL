create or replace package body debug
as
g_session_id varchar2(2000);
procedure who_called_me(
	o_owner out varchar2,
	o_object out varchar2,
	o_lineno out number)
is
	l_call_stack long default dbms_utility.format_call_stack;
	l_line varchar2(4000);
begin
	for i in 1..6 loop
		l_call_stack := substr(l_call_stack,
				instr(l_call_stack, chr(10)) + 1);
	end loop;
	l_line := ltrim(substr(l_call_stack, 1,
			instr(l_call_stack, chr(10)) - 1));
	l_line := ltrim(substr(l_line, instr(l_line, ' ')));
	o_lineno := to_number(substr(l_line, 1, instr(l_line, ' ')));
	l_line := ltrim(substr(l_line, instr(l_line, ' ')));
	l_line := ltrim(substr(l_line, instr(l_line, ' ')));
	if l_line like 'block%' or l_line like 'body%' then
		l_line := ltrim(substr(l_line, instr(l_line, ' ')));
	end if;
	o_owner := ltrim(rtrim(substr(l_line, 1,
				instr(l_line, '.') - 1)));
	o_object := ltrim(rtrim(substr(l_line,
				instr(l_line, '.') + 1)));
	if o_owner is null then
		o_owner := user;
		o_object := 'ANONYMOUS BLOCK';
	end if;
end who_called_me;
function build_it(
	p_debug_row in debugtab%rowtype,
	p_owner in varchar2,
	p_object in varchar2,
	p_lineno number) return varchar2
is
	l_header long := null;
begin
	if p_debug_row.session_id = 'YES' then
		l_header := g_session_id || ' - ';
	end if;
	if p_debug_row.show_date = 'YES' then
		l_header := l_header || to_char(sysdate,
			nvl(p_debug_row.date_format, 'MMDDYYYY HH24MISS'));
	end if;
	l_header := l_header || '(' ||
			lpad(substr(p_owner || '.' || p_object,
			greatest(1, length(p_owner || '.' || p_object) -
			least(p_debug_row.name_length, 61) + 1)),
			least(p_debug_row.name_length, 61)) ||
			lpad(p_lineno, 5) || ') ';
	return l_header;
end build_it;
function parse_it(
	p_message in varchar2,
	p_argv in argv,
	p_header_length in number) return varchar2
is
	l_message long := null;
	l_str long := p_message;
	l_idx number := 1;
	l_ptr number := 1;
begin
	if nvl(instr(p_message, '%'), 0) = 0 and
		nvl(instr(p_message, '\'), 0) = 0 then
		return p_message;
	end if;
	loop
		l_ptr := instr(l_str, '%');
		exit when l_ptr = 0 or l_ptr is null;
		l_message := l_message || substr(l_str, 1, l_ptr - 1);
		l_str := substr(l_str, l_ptr + 1);
		if substr(l_str, 1, 1) = 's' then
			l_message := l_message || p_argv(l_idx);
			l_idx := l_idx + 1;
			l_str := substr(l_str, 2);
		elsif substr(l_str, 1, 1) = '%' then
			l_message := l_message || '%';
			l_str := substr(l_str, 2);
		else
			l_message := l_message || '%';
		end if;
	end loop;
	l_str := l_message || l_str;
	l_message := null;
	loop
		l_ptr := instr(l_str, '\');
		exit when l_ptr = 0 or l_ptr is null;
		l_message := l_message || substr(l_str, 1, l_ptr - 1);
		l_str := substr(l_str, l_ptr + 1);
		if substr(l_str, 1, 1) = 'n' then
			l_message := l_message || chr(10) ||
				rpad(' ', p_header_length, ' ');
			l_str := substr(l_str, 2);
		elsif substr(l_str, 1, 1) = 't' then
			l_message := l_message || chr(9);
			l_str := substr(l_str, 2);
		elsif substr(l_str, 1, 1) = '\' then
			l_message := l_message || '\';
			l_str := substr(l_str, 2);
		else
			l_message := l_message || '\';
		end if;
	end loop;
	return l_message || l_str;
end parse_it;
function file_it(
	p_file in debugtab.filename%type,
	p_message in varchar2) return boolean
is
	l_handle utl_file.file_type;
	l_file long;
	l_location long;
begin
	l_file := substr(p_file,
			instr(replace(p_file, '\', '/'), '/', -1) + 1);
	l_location := substr(p_file, 1,
			instr(replace(p_file, '\', '/'), '/', -1) - 1);
	l_handle := utl_file.fopen(location => l_location,
					filename => l_file,
					open_mode => 'a',
					max_linesize => 32767);
	utl_file.put(l_handle, '');
	utl_file.put_line(l_handle, p_message);
	utl_file.fclose(l_handle);
	return true;
exception
	when others then
		if utl_file.is_open(l_handle) then
			utl_file.fclose(l_handle);
		end if;
		return false;
end file_it;
procedure debug_it(
	p_message in varchar2, p_argv in argv)
is
	l_message long := null;
	l_header long := null;
	call_who_called_me boolean := true;
	l_owner varchar2(255);
	l_object varchar2(255);
	l_lineno number;
	l_dummy boolean;
begin
	for c in (select * from debugtab where userid = user) loop
		if call_who_called_me then
			who_called_me(l_owner, l_object, l_lineno);
			call_who_called_me := false;
		end if;
	if instr(',' || c.modules || ',', ',' || l_object || ',') != 0 or c.modules = 'ALL' then
		l_header := build_it(c, l_owner, l_object, l_lineno);
		l_message := parse_it(p_message, p_argv, length(l_header));
		l_dummy := file_it(c.filename, l_header || l_message);
	end if;
	end loop;
end debug_it;
procedure init(
	p_modules in varchar2 default 'ALL',
	p_file in varchar2 default '/tmp/' || user || '.dbg',
	p_user in varchar2 default user,
	p_show_date in varchar2 default 'YES',
	p_date_format in varchar2 default 'MMDDYYYY HH24MISS',
	p_name_len in number default 30,
	p_show_sesid in varchar2 default 'NO')
is
	pragma autonomous_transaction;
	debugtab_rec debugtab%rowtype;
	l_message long;
begin
	delete from debugtab where userid = p_user and filename = p_file;
	insert into debugtab(userid, modules, filename, show_date,
				date_format, name_length, session_id)
		values(p_user, p_modules, p_file, p_show_date, p_date_format,
			p_name_len, p_show_sesid)
	returning
		userid, modules, filename, show_date, date_format, name_length,
			session_id
	into
		debugtab_rec.userid, debugtab_rec.modules, debugtab_rec.filename,
		debugtab_rec.show_date, debugtab_rec.date_format,
		debugtab_rec.name_length, debugtab_rec.session_id;
	l_message := chr(10) || 'Debug parameters initialized on ' ||
		to_char(sysdate, 'dd-MON-yyyy hh24:mi:ss') || chr(10);
	l_message := l_message || '		USER: ' ||
		debugtab_rec.userid || chr(10);
	l_message := l_message || ' 		MODULES: ' ||
		debugtab_rec.modules || chr(10);
	l_message := l_message || ' 		FILENAME: ' ||
		debugtab_rec.filename || chr(10);
	l_message := l_message || '		SHOW DATE: ' ||
		debugtab_rec.show_date || chr(10);
	l_message := l_message || '		DATE FORMAT: ' ||
		debugtab_rec.date_format || chr(10);
	l_message := l_message || '		NAME LENGTH: ' ||
		debugtab_rec.name_length || chr(10);
	l_message := l_message || 'SHOW SESSION ID: ' ||
		debugtab_rec.session_id || chr(10);
	if not file_it(debugtab_rec.filename, l_message) then
		rollback;
		raise_application_error(-20001,
				'Cannot open file "' || debugtab_rec.filename ||
				'"');
	end if;
	commit;
end init;
procedure f(
	p_message in varchar2,
	p_arg1 in varchar2 default null,
	p_arg2 in varchar2 default null,
	p_arg3 in varchar2 default null,
	p_arg4 in varchar2 default null,
	p_arg5 in varchar2 default null,
	p_arg6 in varchar2 default null,
	p_arg7 in varchar2 default null,
	p_arg8 in varchar2 default null,
	p_arg9 in varchar2 default null,
	p_arg10 in varchar2 default null)
is
begin
	debug_it(p_message, argv(substr(p_arg1, 1, 4000),
				substr(p_arg2, 1, 4000),
				substr(p_arg3, 1, 4000),
				substr(p_arg4, 1, 4000),
				substr(p_arg5, 1, 4000),
				substr(p_arg6, 1, 4000),
				substr(p_arg7, 1, 4000),
				substr(p_arg8, 1, 4000),
				substr(p_arg9, 1, 4000),
				substr(p_arg10, 1, 4000)));
end f;
procedure fa(
	p_message in varchar2,
	p_args in argv default emptyDebugArgv)
is
begin
	debug_it(p_message, p_args);
end fa;
procedure status(
	p_user in varchar2 default user,
	p_file in varchar2 default null)
is
	l_found boolean := false;
begin
	dbms_output.put_line(chr(10));
	dbms_output.put_line('Debug info for ' || p_user);
	for c in (select * from debugtab where userid = p_user
			and nvl(p_file, filename) = filename) loop
		dbms_output.put_line('-----------------' ||
			rpad('-', length(p_user), '-'));
		l_found := true;
		dbms_output.put_line('USER:		' ||
					c.userid);
		dbms_output.put_line('MODULES:		' ||
					c.modules);
		dbms_output.put_line('FILENAME:		' ||
					c.filename);
		dbms_output.put_line('SHOW DATE:	' ||
					c.show_date);
		dbms_output.put_line('DATE FORMAT:	' ||
					c.date_format);
		dbms_output.put_line('NAME LENGTH:	' ||
					c.name_length);
		dbms_output.put_line('SHOW SESSION ID:	' ||
					c.session_id);
		dbms_output.put_line(' ');
	end loop;
	if not l_found then
		dbms_output.put_line('No debug setup.');
	end if;
end status;
procedure clear(
	p_user in varchar2 default user,
	p_file in varchar2 default null)
is
	pragma autonomous_transaction;
begin
	delete from debugtab where userid = p_user
		and filename = nvl(p_file, filename);
	commit;
end clear;
begin
	g_session_id := userenv('SESSIONID');
end debug;
/
