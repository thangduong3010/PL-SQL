Rem
Rem $Header: dbmstrig.sql 24-may-2001.10:32:48 gviswana Exp $
Rem
Rem dbmstrig.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmstrig.sql - DBMS TRIGger function
Rem
Rem    DESCRIPTION
Rem      A group of system event attribute functions: use inside system trigger
Rem      body
Rem
Rem    NOTES
Rem      to be created in the schema of SYS
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    htseng      04/12/01 - eliminate execute twice (remove ;).
Rem    kquinn      09/16/00 - 1200228: privileg_list -> privilege_list
Rem    weiwang     05/02/00 - add error functions
Rem    najain      04/25/00 - add partition_pos function
Rem    najain      04/14/00 - add sqltext attr. func
Rem    weiwang     02/28/00 - fix bug 1209532
Rem    weiwang     08/02/99 - change name_list_t to ora_name_list_t
Rem    weiwang     07/13/99 - add public synonyms to event attribute functions
Rem    weiwang     02/09/99 - add new attribute functions
Rem    weiwang     11/13/98 - Created
Rem

Rem returns the system event that invokes the system trigger
create or replace function sysevent return varchar2 is
begin
  return dbms_standard.sysevent;
end;
/
grant execute on sysevent to public
/
create or replace public synonym ora_sysevent for sysevent
/

Rem returns the object type on which the DDL statement is being done
create or replace function dictionary_obj_type return varchar2 is
begin
return dbms_standard.dictionary_obj_type;
end;
/
grant execute on dictionary_obj_type to public
/
create or replace public synonym ora_dict_obj_type for dictionary_obj_type
/

Rem returns the object owner on which the DDL statement is being done
create or replace function dictionary_obj_owner return varchar2 is
begin
return dbms_standard.dictionary_obj_owner;
end;
/
grant execute on dictionary_obj_owner to public
/
create or replace public synonym ora_dict_obj_owner for dictionary_obj_owner
/

Rem returns the object name on which the DDL statement is being done
create or replace function dictionary_obj_name return varchar2 is
begin
return dbms_standard.dictionary_obj_name;
end;
/
grant execute on dictionary_obj_name to public
/
create or replace public synonym ora_dict_obj_name for dictionary_obj_name
/

Rem returns the current database name
create or replace function database_name return varchar2 is
begin
return dbms_standard.database_name;
end;
/
grant execute on database_name to public
/
create or replace public synonym ora_database_name for database_name
/

Rem returns the current instance number
create or replace function instance_num return binary_integer is
begin
return dbms_standard.instance_num;
end;
/
grant execute on instance_num to public
/
create or replace public synonym ora_instance_num for instance_num
/

Rem returns the current login user
create or replace function login_user return varchar2 is
begin
return dbms_standard.login_user;
end;
/
grant execute on login_user to public
/
create or replace public synonym ora_login_user for login_user
/

Rem whether the specified error number (errno) is in the error stack
create or replace function is_servererror (errno binary_integer)
return boolean is
begin
return dbms_standard.is_servererror(errno);
end;
/
grant execute on is_servererror to public
/
create or replace public synonym ora_is_servererror for is_servererror
/

Rem returns the error in the specified position of the error stack
create or replace function server_error (position binary_integer)
return binary_integer is
begin
return dbms_standard.server_error(position);
end;
/
grant execute on server_error to public
/
create or replace public synonym ora_server_error for server_error
/

Rem returns the DES encrypted password of the user being created or altered
create or replace function des_encrypted_password (user varchar2 default NULL)
return varchar2 is
begin
return dbms_standard.des_encrypted_password(user);
end;
/
grant execute on des_encrypted_password to public
/
create or replace public synonym ora_des_encrypted_password
   for des_encrypted_password
/

Rem whether the specified column is altered in the statement
create or replace function is_alter_column (column_name varchar2)
return boolean is
begin
return dbms_standard.is_alter_column(column_name);
end;
/
grant execute on is_alter_column to public
/
create or replace public synonym ora_is_alter_column for is_alter_column
/

Rem whether the specified column is dropped in the statement
create or replace function is_drop_column (column_name varchar2)
return boolean is
begin
return dbms_standard.is_drop_column(column_name);
end;
/
grant execute on is_drop_column to public
/
create or replace public synonym ora_is_drop_column for is_drop_column
/

create or replace function grantee (user_list out ora_name_list_t) 
return binary_integer is
begin
return dbms_standard.grantee(user_list);
end;
/
grant execute on grantee to public
/
create or replace public synonym ora_grantee for grantee
/

create or replace function revokee (user_list out ora_name_list_t)
return binary_integer is
begin
return dbms_standard.revokee(user_list);
end;
/
grant execute on revokee to public
/
create or replace public synonym ora_revokee for revokee
/

create or replace function privilege_list (priv_list out ora_name_list_t) 
return binary_integer is
begin
return dbms_standard.privilege_list(priv_list);
end;
/
grant execute on privilege_list to public
/
create or replace public synonym ora_privilege_list for privilege_list
/

create or replace function with_grant_option return boolean is
begin
return dbms_standard.with_grant_option;
end;
/
grant execute on with_grant_option to public
/
create or replace public synonym ora_with_grant_option for with_grant_option
/

create or replace function dictionary_obj_owner_list
(owner_list out ora_name_list_t)
return binary_integer is
begin
return dbms_standard.dictionary_obj_owner_list(owner_list);
end;
/
grant execute on dictionary_obj_owner_list to public
/
create or replace public synonym ora_dict_obj_owner_list
   for dictionary_obj_owner_list
/

create or replace function dictionary_obj_name_list 
(object_list out ora_name_list_t)
return binary_integer is
begin
return dbms_standard.dictionary_obj_name_list(object_list);
end;
/
grant execute on dictionary_obj_name_list to public
/
create or replace public synonym ora_dict_obj_name_list
   for dictionary_obj_name_list
/


create or replace function is_creating_nested_table
return boolean is
begin
return dbms_standard.is_creating_nested_table;
end;
/
grant execute on is_creating_nested_table to public
/
create or replace public synonym ora_is_creating_nested_table
   for is_creating_nested_table
/

create or replace function client_ip_address 
return varchar2 is
begin
return dbms_standard.client_ip_address;
end;
/
grant execute on client_ip_address to public
/
create or replace public synonym ora_client_ip_address for client_ip_address
/
create or replace function sql_txt (sql_text out ora_name_list_t) 
return binary_integer is
begin
return dbms_standard.sql_txt(sql_text);
end;
/
grant execute on sql_txt to public
/
create or replace public synonym ora_sql_txt for sql_txt
/

create or replace function server_error_msg (position in binary_integer)
return varchar2 is
begin
return dbms_standard.server_error_msg(position);
end;
/
grant execute on server_error_msg to public
/
create or replace public synonym ora_server_error_msg for server_error_msg
/

create or replace function server_error_depth
return binary_integer is
begin
return dbms_standard.server_error_depth;
end;
/
grant execute on server_error_depth to public
/
create or replace public synonym ora_server_error_depth for server_error_depth
/

create or replace function server_error_num_params (position in binary_integer)
return binary_integer is
begin
return dbms_standard.server_error_num_params(position);
end;
/
grant execute on server_error_num_params to public
/
create or replace public synonym ora_server_error_num_params
   for server_error_num_params
/

create or replace function partition_pos
return binary_integer is
begin
return dbms_standard.partition_pos;
end;
/
grant execute on partition_pos to public
/
create or replace public synonym ora_partition_pos for partition_pos
/

create or replace function server_error_param (position in binary_integer,
                                               param in binary_integer)
return varchar2 is
begin
return dbms_standard.server_error_param(position, param);
end;
/
grant execute on server_error_param to public
/
create or replace public synonym ora_server_error_param for server_error_param
/


