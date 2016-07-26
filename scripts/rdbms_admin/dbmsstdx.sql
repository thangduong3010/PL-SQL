rem 
rem $Header: rdbms/admin/dbmsstdx.sql /main/23 2009/03/31 12:59:00 dalpern Exp $ 
rem 
Rem Copyright (c) 1991, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      stdext.sql - Kernel extensions to package standard
Rem    DESCRIPTION
Rem      Routines in this package do not need to be qualified by the
Rem      owner or package name, similar to the behaviour of package
Rem      'standard'.  This package mostly contains utility routines for
Rem      triggers.
Rem    RETURNS
Rem 
Rem    NOTES
Rem      
Rem    MODIFIED   (MM/DD/YY)
Rem     dalpern    03/17/09  - bug 7646876: applying_crossedition_trigger
Rem     sagrawal   05/15/06  - sys_GetTriggerState
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     ykunitom   04/04/01  - fix bug 1473966
Rem     weiwang    05/02/00  - add error functions
Rem     najain     04/25/00  - add partition_pos function
Rem     najain     04/14/00  - add sqltext attr. func
Rem     weiwang    02/28/00 -  fix bug 1209532
Rem     weiwang    08/02/99 -  change name_list_t to ora_name_list_t
Rem     weiwang    02/09/99 -  add isdropcolumn, isaltercolumn
Rem     weiwang    09/15/98 -  add function des_encrypted_password
Rem     weiwang    06/11/98 -  add function dictionary_obj_owner
Rem     jkrishna   05/05/98 -  support for error events
Rem     jkrishna   04/01/98 -  adding system event callouts
Rem     cbarclay   11/06/96 -  remove kkxl*em
Rem     mmonajje   09/16/96 -  Fixing bug 244014; Adding RESTRICT_REFERENCES pr
Rem     ramkrish   06/28/96 -  Add EMPTY_BLOB, EMPTY_CLOB routines
Rem     hjakobss   10/16/94 -  bug 151485 - remove sql_ddl
Rem     jwijaya    04/05/93 -  merge changes from branch 1.3.312.1 
Rem     jwijaya    03/26/93 -  bug 157348 
Rem     rkooi      11/28/92 -  add 'keep' option to raise_application_error 
Rem     rkooi      10/25/92 -  deal with null arg to rae 
Rem     glumpkin   10/21/92 -  Renamed from STDEXT.SQL 
Rem     mmoore     09/24/92 - #(130568) add callback for commit comment 
Rem     rkooi      09/02/92 -  change pls_integer to binary_integer 
Rem     mmoore     08/12/92 -  override the savepoint command in standard
Rem     rkooi      06/10/92 -  add 'do not change' comment 
Rem     mmoore     04/14/92 -  move begin_oltp to package transaction 
Rem     rkooi      04/06/92 -  merge changes from branch 1.7.300.1 
Rem     rkooi      04/02/92 -  split dbms_standard into separate pkgs 
Rem     maporter   03/25/92 -  renumber 8200 to 8175
Rem     rbamford   03/07/92 -  add BEGIN_OLTP_TRANSACTION 
Rem     mroberts   02/21/92 -  delete extra rollback_sv procedure 
Rem     rkooi      02/17/92 -  add set_role and related procedures 
Rem     mroberts   02/14/92 -  add execute_ddl internal 
Rem     mmoore     02/06/92 -  change name of package 
Rem     mmoore     01/14/92 -  add rollback_nr 
Rem     mmoore     01/09/92 -  speed up 
Rem      rkooi      11/24/91 -  rename to stdext.sql from stdext.pls
Rem      rkooi      08/26/91 -  get rid of stack_application_error 
Rem      rkooi      05/08/91 -  change name to standard_extension 
Rem      rkooi      05/02/91 -  forgot skip_row procedure 
Rem      mmoore     05/02/91 -  move trigger icds to psd, use varchar2 in
Rem                             rae/sae
Rem      rkooi      04/23/91 -  add 'skip_row' procedure, commit etc.
Rem                             procedures. 
Rem      Moore      04/02/91 -  fix typo
Rem      Moore      03/28/91 -  add boolean trigger functions 
Rem      Kooi       03/17/91 -  Creation
Rem      Kooi       03/12/91 -  change name to standard_utilities
Rem      Kooi       02/26/91 -  get rid of raise now that psdkse does it
Rem      Kooi       02/26/91 -  Creation
------------------------------------------------------------------------------

REM *****************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
REM COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE RDBMS.
REM *****************************************************************

create or replace package dbms_standard is
  -- types
   type ora_name_list_t is table of varchar2(64);

  -- Trigger Operations
  procedure raise_application_error(num binary_integer, msg varchar2,
      keeperrorstack boolean default FALSE);
    pragma interface (C, raise_application_error);         -- 1 (see psdicd.c)
    pragma restrict_references (raise_application_error, WNPS, RNPS, WNDS, RNDS);
  function inserting return boolean;
    pragma interface (C, inserting);                       -- 2 
    pragma restrict_references (inserting, WNPS, RNPS, WNDS);
  function deleting  return boolean;
    pragma interface (C, deleting);                        -- 3 
    pragma restrict_references (deleting, WNPS, RNPS, WNDS);
  function updating  return boolean;
    pragma interface (C, updating);                        -- 4 
    pragma restrict_references (updating, WNPS, RNPS, WNDS);
  function updating (colnam varchar2) return boolean;
    pragma interface (C, updating);                        -- 5 
    pragma restrict_references (updating, WNPS, RNPS, WNDS);

  -- Transaction Commands
  procedure commit;
    pragma interface (C, commit);                          -- 6 
  procedure commit_cm(vc varchar2);
    pragma interface (C, commit_cm);                       -- 7
  procedure rollback_nr;
    pragma interface (C, rollback_nr);                     -- 8 
  procedure rollback_sv(save_point varchar2);
    pragma interface (C, rollback_sv);                     -- 9 
  procedure savepoint(save_point varchar2);
    pragma interface (C, savepoint);                       -- 10
  procedure set_transaction_use(vc varchar2);   
    pragma interface (C, set_transaction_use);             -- 11
  

  -- Functions supported for system events
  -- Null or zero will be returned if called in inappropriate occasions
  -- error functions only search for the top 5 errors in the error stack
 
  function sysevent return varchar2 ;                      -- 12
    pragma interface (C, sysevent);   
    pragma restrict_references (sysevent, WNPS, RNPS, WNDS);
  function dictionary_obj_type return varchar2 ;           -- 13
    pragma interface (C, dictionary_obj_type);   
    pragma restrict_references (dictionary_obj_type, WNPS, RNPS, WNDS);
   function dictionary_obj_owner return varchar2 ;           -- 14
    pragma interface (C, dictionary_obj_owner);   
    pragma restrict_references (dictionary_obj_owner, WNPS, RNPS, WNDS);
  function dictionary_obj_name return varchar2 ;           -- 15
    pragma interface (C, dictionary_obj_name);   
    pragma restrict_references (dictionary_obj_name, WNPS, RNPS, WNDS);
  function database_name return varchar2 ;                 -- 16
    pragma interface (C, database_name);   
    pragma restrict_references (database_name, WNPS, RNPS, WNDS);
  function instance_num return binary_integer ;            -- 17
    pragma interface (C, instance_num);   
    pragma restrict_references (instance_num, WNPS, RNPS, WNDS);
  function login_user return varchar2 ;                    -- 18
    pragma interface (C, login_user);   
    pragma restrict_references (login_user, WNPS, RNPS, WNDS);
  function is_servererror (errno binary_integer)
		return boolean ; 	                   -- 19
    pragma interface (C, is_servererror);   
    pragma restrict_references (is_servererror, WNPS, RNPS, WNDS);
    
  function server_error(position binary_integer) 
			return binary_integer ;           -- 20
    pragma interface (C, server_error);   
    pragma restrict_references (server_error, WNPS, RNPS, WNDS);
  function des_encrypted_password(user varchar2 default null) return varchar2; -- 21
    pragma interface (C, des_encrypted_password);   
    pragma restrict_references (des_encrypted_password, WNPS, RNPS, WNDS);
  function is_alter_column (column_name varchar2)
		return boolean ; 	                   -- 22
    pragma interface (C, is_alter_column);   
    pragma restrict_references (is_alter_column, WNPS, RNPS, WNDS);
  function is_drop_column (column_name varchar2)
		return boolean ; 	                   -- 23
    pragma interface (C, is_drop_column);   
    pragma restrict_references (is_drop_column, WNPS, RNPS, WNDS);  
  function grantee (user_list out ora_name_list_t) return binary_integer ;   -- 24
    pragma interface (C, grantee);   
    pragma restrict_references (grantee, WNPS, RNPS, WNDS);
  function revokee (user_list out ora_name_list_t) return binary_integer ;   -- 25
    pragma interface (C, revokee);   
    pragma restrict_references (revokee, WNPS, RNPS, WNDS);
  function privilege_list (priv_list out ora_name_list_t) 
                return binary_integer ;                    -- 26
    pragma interface (C, privilege_list);   
    pragma restrict_references (privilege_list, WNPS, RNPS, WNDS);
  function with_grant_option return boolean ;                    -- 27
    pragma interface (C, with_grant_option);   
    pragma restrict_references (with_grant_option, WNPS, RNPS, WNDS);
  function dictionary_obj_owner_list (owner_list out ora_name_list_t) 
                return binary_integer;                           -- 28
    pragma interface (C, dictionary_obj_owner_list);
    pragma restrict_references (dictionary_obj_owner_list, WNPS, RNPS, WNDS);
  function dictionary_obj_name_list (object_list out ora_name_list_t)
                return binary_integer;                           -- 29
    pragma interface (C, dictionary_obj_name_list);
    pragma restrict_references (dictionary_obj_name_list, WNPS, RNPS, WNDS);
  function is_creating_nested_table return boolean; 	         -- 30
    pragma interface (C, is_creating_nested_table); 
    pragma restrict_references (is_creating_nested_table, WNPS, RNPS, WNDS);
  function client_ip_address return varchar2; 	                 -- 31
    pragma interface (C, client_ip_address);
    pragma restrict_references (client_ip_address, WNPS, RNPS, WNDS);
  function sql_txt (sql_text out ora_name_list_t) return binary_integer; -- 32
    pragma interface (C, sql_txt);
    pragma restrict_references (sql_txt, WNPS, RNPS, WNDS);
  function server_error_msg (position binary_integer) return varchar2; -- 33
    pragma interface (C, server_error_msg);
    pragma restrict_references (server_error_msg, WNPS, RNPS, WNDS);
  function server_error_depth return binary_integer;              -- 34
    pragma interface (C, server_error_depth);
    pragma restrict_references (server_error_depth, WNPS, RNPS, WNDS);
  function server_error_num_params (position binary_integer) 
                                   return binary_integer;         -- 35
    pragma interface (C, server_error_num_params);
    pragma restrict_references (server_error_num_params, WNPS, RNPS, WNDS);
  function server_error_param(position binary_integer, param binary_integer)
                              return varchar2;                    -- 36
    pragma interface (C, server_error_param);
    pragma restrict_references (server_error_param, WNPS, RNPS, WNDS);
  function partition_pos return binary_integer;                  -- 37
    pragma interface (C, partition_pos);   
    pragma restrict_references (partition_pos, WNPS, RNPS, WNDS);
    
  function sys_GetTriggerState  return pls_integer;
    pragma interface (C, Sys_GetTriggerState);                        -- 38 
    pragma restrict_references (Sys_GetTriggerState,  wnds, RNDS);
  function applying_crossedition_trigger return boolean;
    pragma interface (C, applying_crossedition_trigger);              -- 39
    pragma restrict_references (applying_crossedition_trigger, WNPS,RNPS,WNDS);
end;
/

create or replace public synonym dbms_standard for sys.dbms_standard
/
grant execute on dbms_standard to public
/
