Rem
Rem $Header: rdbms/admin/catlibc.sql /main/3 2009/12/08 18:04:23 arbalakr Exp $
Rem
Rem catlibc.sql
Rem
Rem Copyright (c) 2000, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catlibc.sql - header routines for compiling the library cache
Rem
Rem    DESCRIPTION
Rem      This package is the include file for the RDBMS package DBMS_LIBCACHE.
Rem      It provides the base definitions for a maintenance process to 
Rem	   compile cursors in the library cache in advance of the application 
Rem	   itself parsing them.
Rem    NOTES
Rem      This package is the include file for DBMS_LIBCACHE.
Rem
Rem    NOTES
Rem      Must be run from the SYS user. It is created before dbmslibc.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    arbalakr    11/23/09 - truncate module/action to max lengths in
Rem                           X$MODACT_LENGTH
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    sltam       02/07/01 - Merged sltam_dbmslibc_src
Rem    ccolrain    08/08/00 - created.         
Rem    ccolrain    09/26/00	- to offer access using db links
Rem    sltam       12/18/00 - Check-in
        
-----------------------------------------------------------------------

create or replace package dbms_libcache$def as
  ------------
  --  OVERVIEW
  --
  --  This package includes the data types and messages for the package 
  --  dbms_libcache which compiles cursors in the local library cache.

  ----------------------------
  --  ASSUMPTIONS
  --	1. The RDBMS package DBMS_SYS is loaded.

  ----------------------------
  --  EXAMPLE USAGE
  --  Data types may be included in applications that wish to call 
  --  dbms_libcache by using the  prefix dbms_libcache$def.  
  --  For example, to use the table of SQL statement the following declaration 
  --  is used:
  --  declare
  --		p_SQL_tab	dbms_libcache$def.SQL_tab;
  
-----------------------------------------------------------------------
  ------------
  -- version identification for dbms_libcache
  -- 
  -- DB_LINK_METHOD	the source instance is accessed using database links
  -- GLOBAL_METHOD	the source instance is accessed using global views
  
	DB_LINK_METHOD	constant	binary_integer := 1;
	GLOBAL_METHOD	constant	binary_integer := 2;
 	access_method	constant	binary_integer := DB_LINK_METHOD;
  
  ------------
  -- types for dbms_libcache package
  --
  type	dynamic_cursor is		ref cursor;
	cursor_id                	integer;
	cursor_addr		       	raw(8);
	db_link				varchar2(128);
	sql_stmt		       	varchar2(13767);

  ------------
  -- PL/SQL table containing the sql statement
  --
       tab_sql_statements      dbms_sql.varchar2s ;

  ------------
  -- Control record describing each cursor on the source instance 
  -- 
  type SQL_record             is record
	( inst_id			      integer
	, addr				cursor_addr%type	
	, hash_value			integer	
	, command_type			integer
	, optimizer_mode		      varchar2(10)
	, parsing_user_id		      integer
	, parsing_schema_id		integer
	);

  ------------
  -- Table of SQL records extracted from the source instance
  --
  type SQL_tab is table of SQL_record   index by binary_integer;
 
  ------------
  -- Control record containing the meta data record for a bind variable 
  --
  type SQL_bind_record         is record
	(   position			integer
	  , datatype			integer
	  , bind_name			varchar2(30)
	  , max_length			integer
	  , array_length		      integer 
	);

  ------------
  -- Table of SQL meta data descriptions extracted from the source instance
  --
  type SQL_bind_tab is table of SQL_bind_record   index by binary_integer;

  ------------
  -- status return codes for dbms_libcache
  --
	SUCCESS	constant 		binary_integer := 0;
	ERROR	      constant 		binary_integer := -1;
	WARNING	constant 		binary_integer := -2;

  ------------
  -- ERROR STACK for dbms_libcache
  --
	ERR_MSG			varchar2(100);	      -- application error message
	ERR_CODE			number;		      -- application error code

  ------------
  -- RUNTIME DEFINITIONS
  ------------
  --
  -- Number of parse errors tolerated before exiting (this value can be changed).
  	error_threshold constant       	binary_integer := 100;  
  -- Debug mode set to true displays detailed messages
   	debug						boolean := false; 
  -- Output buffer size used for dbms_output
 	output_buffer 	constant       	binary_integer := 50000;     
  -- Wild card username used when parsing is not restricted by username
 	all_users 		constant       	binary_integer := -1;     
 	
  ------------
  -- CONSTANT DEFINITIONS
  ------------
  ------------
  -- Internal Oracle command types -- refer octdef.h
  --
	c_ins 	constant                binary_integer := 2 ; --   insert 
	c_sel 	constant                binary_integer := 3 ; --   select
	c_upd 	constant                binary_integer := 6 ; --   update
	c_del 	constant                binary_integer := 7 ; --   delete 
	c_plsql     constant                binary_integer := 47 ; --  pl/sql 

  ------------
  -- External Oracle data types -- refer dtydef.h
  --
	c_nul constant          binary_integer := 0 ;  --   not bound 		
	c_str	constant		binary_integer := 1 ;  --   string, may be space padded 	
	c_num	constant		binary_integer := 2 ;  --   numeric	  
	c_int	constant		binary_integer := 3 ;  --   integer   		
	c_flt	constant		binary_integer := 4 ;  --   float point  			
	c_txt	constant		binary_integer := 5 ;  --   text, null terminated  	
	c_vnu	constant		binary_integer := 6 ;  --   NUM, length in 1st byte	
	c_pdn	constant		binary_integer := 7 ;  --   packed decimal		
	c_lng	constant		binary_integer := 8 ;  --   long			
	c_vcs	constant		binary_integer := 9 ;  --   variable char string	
	c_ti5	constant		binary_integer := 10;  --   table				
	c_rid	constant		binary_integer := 11;  --   row id.				
	c_dat	constant		binary_integer := 12;  --   date 				
	c_bin	constant		binary_integer := 23;  --   binary data (RAW) 	
	c_lbi	constant		binary_integer := 24;  --   binary data (long RAW) 	
	c_chr	constant		binary_integer := 96;  --   ANSI fixed character	

  -- record of values for each Oracle datatype, excluding tables
	
  type rec_data_values	     is record              
	( v_null                     	varchar2(1)		:= null 
	, v_str				varchar2(13767)	:= 'SAMPLE'
	, v_num				numeric		:= 0.0
	, v_int				integer	      := 0
	, v_flt				float 		:= 0.0
	, v_txt				varchar2(256)	:= 'SAMPLE'
	, v_vnu				number  		:= 0
	, v_pdn				decimal  		:= 0.0
	, v_lng				long			:= 'SAMPLE'
	, v_vcs				varchar2(13767)	:= 'SAMPLE'
	, v_rid				rowid     	--   set at initialization
	, v_dat				date			:= sysdate
    	, v_bin				raw(13767)		
    	, v_lbi				long raw		
	, v_chr				char(2000)		:= 'SAMPLE' 
	);	 

  ---------------------------------
  -- PL/SQL APPLICATION RROR CODES
  ---------------------------------
  -- 
  -- instance name for the source instance must be entered 
  	lc_err_null_instance_name	exception;
	lc_err_null_instance_code	constant	numeric	:= -20001 ;
	lc_err_null_instance_msg	constant	varchar2(256)
                                    := 'Instance name cannot be null.';
	pragma exception_init(lc_err_null_instance_name, -20001);

  -- instance name entered does not match an active instance, excluding the current 
  	lc_err_invalid_instance_name	exception;
	lc_err_invalid_instance_code	constant	numeric	:= -20002 ;
	lc_err_invalid_instance_msg	constant	varchar2(256)
                                    := 'Instance name is invalid:';
	pragma exception_init(lc_err_invalid_instance_name, -20002);

  -- multiple instances exist with the instance name entered
  	lc_err_multiple_instance_names	exception;
	lc_err_multiple_instance_code	constant	numeric	:= -20003 ;
	lc_err_multiple_instance_msg	constant	varchar2(256)
                              	:= 'Multiple instances with name:';
	pragma exception_init(lc_err_multiple_instance_names, -20003);

  -- no instance id. found with the given instance name (eg. it is now down)
  	lc_err_no_instance_found	exception;
	lc_err_no_instance_found_code	constant	numeric	:= -20004 ;
	lc_err_no_instance_found_msg	constant	varchar2(256)
                               	:= 'Instance  not found:';
	pragma exception_init(lc_err_no_instance_found, -20004);

  -- user name entered does not match known user 
  	lc_err_invalid_username		exception;
	lc_err_invalid_username_code	constant	numeric	:= -20005 ;
	lc_err_invalid_username_msg	constant	varchar2(256)
                              	:= 'User name is invalid:';
	pragma exception_init(lc_err_invalid_username, -20005);

  -- execution threshold should be greater than zero
  	lc_err_threshold_exec		exception;
	lc_err_threshold_exec_code 	constant	numeric	:= -20006 ;
	pragma exception_init(lc_err_threshold_exec, -20006);

  -- shared memory threshold should be greater than zero
  	lc_err_threshold_sharable_mem	exception;
	lc_err_threshold_shar_mem_code 	constant numeric	:= -20007 ;
	pragma exception_init(lc_err_threshold_sharable_mem, -20007);

   -- no SQL text address descriptors returned
  	lc_err_no_matching_SQL		exception;
	lc_err_no_matching_SQL_code	constant	numeric	:= -20008 ;
	lc_err_no_matching_SQL_msg	constant	varchar2(256)
                      	:= 'No SQL statements found matching the input criteria.';
	pragma exception_init(lc_err_no_matching_SQL, -20008);

   -- no SQL text returned for the address descriptor
  	lc_err_no_SQL_text		exception;
	lc_err_no_SQL_text_code		constant	numeric	:= -20009 ;
	lc_err_no_SQL_text_msg		constant	varchar2(256) := 'No SQL text found.';
	pragma exception_init(lc_err_no_SQL_text, -20009);

   -- Fatal error in compile from remote
  	lc_err_compile_cursors		exception;
	lc_err_compile_cursors_code	constant	numeric	:= -20100 ;
	lc_err_compile_cursors_msg	constant	varchar2(256)
				:= 'Exiting compile from remote';
	pragma exception_init(lc_err_compile_cursors, -20100);

   -- Non-fatal error in compile cursor job
  	lc_warn_compile_cursors		exception;
	lc_warn_compile_cursors_code	constant	numeric	:= -20111 ;
	lc_warn_compile_cursors_msg	constant	varchar2(256)
				:= 'Warning at cursor :';
	pragma exception_init(lc_warn_compile_cursors, -20111);
 
   -- Fatal error in compile cursor job
  	lc_error_count_exceeded		exception;
	lc_error_count_exceeded_code	constant	numeric	:= -20112 ;
	lc_error_count_exceeded_msg	constant	varchar2(256)
				:= 'Error threshold exceeded.';
	pragma exception_init(lc_error_count_exceeded, -20112);
 
   -- Warn of unsupported data types during binding
  	lc_warn_unsupported_type		exception;
	lc_warn_unsupported_type_code	constant	numeric	:= -20114 ;
	lc_warn_unsupported_type_msg	constant	varchar2(256)
				:= 'Warning - bind datatype is not supported.';
	pragma exception_init(lc_warn_unsupported_type, -20114);

   -- Raise an error if database link is null, db_access_method only
  	lc_err_null_db_link		exception;
	lc_err_null_db_link_code	constant	numeric	:= -20115 ;
	lc_err_null_db_link_msg	constant	varchar2(256)
                  	:= 'Database link is null.';
	pragma exception_init(lc_err_null_db_link, -20115);

  
   -- Raise an error if the database link is invalid, db_access_method only
  	lc_err_invalid_db_link		exception;
	lc_err_invalid_db_link_code	constant	numeric	:= -20116 ;
	lc_err_invalid_db_link_msg	constant	varchar2(256)	
                       := 'Database link is invalid, see error stack.';
	pragma exception_init(lc_err_invalid_db_link, -20116);

    -- Information cursor processed
	lc_cursor_done_msg	constant	varchar2(256)	:= 'Completed cursor :';
  
   -- Invalid schema name (parsing user is dropped)
  	lc_err_invalid_schema		exception;
	lc_err_invalid_schema_code	constant	numeric	:= -20118 ;
	lc_err_invalid_schema_msg	constant	varchar2(256)
				:= 'Parsing schema id no longer exists:';
	pragma exception_init(lc_err_invalid_schema, -20118);
  
    -- Information processing complete
	lc_compile_done_msg	constant	varchar2(256)	
				:= 'Total SQL statements compiled = ';

   -- Parsing user does not have access to the objects
  	lc_outside_security		exception;
	lc_outside_security_msg	constant	varchar2(256)
				:= 'Parsing user cannot access the objects.';
	pragma exception_init(lc_outside_security, -942);
 
end dbms_libcache$def;
/

 --
 -- skip errors due to dropping synonyms.

 whenever sqlerror continue;

 ---------------------------------

create or replace public synonym dbms_libcache$def for dbms_libcache$def
/
grant execute on dbms_libcache$def to public
/

-----------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------
Rem
Rem $Header: catlibc(1).sql 08-Aug-2000.01 ccolrain
Rem
Rem catlibc(1).sql 
Rem
Rem Copyright (c) 1998, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catlibc2.sql - views for selecting from the library cache
Rem
Rem    DESCRIPTION
Rem      The views in this file are used to view full data from the child cursors 
Rem      in the library cache.  This view is replaced by v$sql in oracle 9i.
Rem	 
Rem    RETURNS
Rem      This package is executed for the package DBMS_LIBCACHE.
Rem
Rem    NOTES
Rem	 The view must be created as the dictionary user SYS.
Rem
Rem
Rem    CREATED    
Rem    ccolrain    08/08/00 - created.         
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ccolrain             
-----------------------------------------------------------------------
 --
 -- skip errors due to dropping synonyms.

 whenever sqlerror continue;

 ---------------------------------
  -- VIEW DEFINITIONS
  --
  --	The following views are used pending enhancements to V$SQL and GV$SQL
  --	child address 	1376567 (fixed 9.0.0.0)
  --	object status	1425898
  --
  
  ---------------------------------

  --	v$sql2 is created from x$kglcursor to externalize the child cursor 

create or replace view v$sql2 as
 select
 userenv('instance')	INST_ID,
 kglnaobj		SQL_TEXT,
 kglobhs0+kglobhs1+kglobhs2+kglobhs3+kglobhs4+kglobhs5+kglobhs6+kglobt16 SHARABLE_MEM,
 kglobt08+kglobt11 	PERSISTENT_MEM,
 kglobt10		RUNTIME_MEM,
 kglobt01		SORTS,
 decode(kglobhs6,0,0,1)	LOADED_VERSIONS,
 decode(kglhdlmd,0,0,1)	OPEN_VERSIONS,
 kglhdlkc		USERS_OPENING,
 kglhdexc		EXECUTIONS,
 kglobpc6		USERS_EXECUTING,
 kglhdldc		LOADS,
 substr(to_char(kglnatim,'YYYY-MM-DD/HH24:MI:SS'),1,19)	FIRST_LOAD_TIME,
 decode(kglobsta, 1, 'VALID', 2, 'VALID_AUTH_ERROR'
  ,3 ,'VALID_COMPILE_ERROR', 4, 'VALID_UNAUTH', 5, 'INVALID_UNAUTH', 6, 'INVALID'
  , kglobsta)		OBJECT_STATUS,	
 kglhdivc		INVALIDATIONS,
 kglobt12		PARSE_CALLS,
 kglobt13		DISK_READS,
 kglobt14		BUFFER_GETS,
 kglobt15		ROWS_PROCESSED,
 kglobt02		COMMAND_TYPE,
 decode(kglobt32,
        0, 'NONE',
        1, 'ALL_ROWS',
        2, 'FIRST_ROWS',
        3, 'RULE',
        4, 'CHOOSE',
           'UNKNOWN')	OPTIMIZER_MODE,
 kglobtn0		OPTIMIZER_COST,
 kglobt17		PARSING_USER_ID,
 kglobt18		PARSING_SCHEMA_ID,
 kglhdkmk		KEPT_VERSIONS,
 kglhdpar		ADDRESS,
 kglhdadr		CHILD_ADDRESS,
 kglobtp0		TYPE_CHK_HEAP,
 kglnahsh		HASH_VALUE,
 kglobt09		CHILD_NUMBER,
 substrb(kglobts0,1,(select ksumodlen from x$modact_length))	MODULE,
 kglobt19		MODULE_HASH,
 substrb(kglobts1,1,(select ksuactlen from x$modact_length))	ACTION,
 kglobt20		ACTION_HASH,
 kglobt21		SERIALIZABLE_ABORTS,
 kglobts2		OUTLINE_CATEGORY
 from 		x$kglcursor
 where		kglobt02 != 0
 and		kglhdadr != kglhdpar
 ;

grant select on v$sql2 to public;
create or replace public synonym v$sql2 for v$sql2 ;

-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------
Rem
Rem $Header: catlibc(2).sql.sql 08-Aug-2000.01 ccolrain
Rem
Rem catlibc(2).sql
Rem
Rem Copyright (c) 1998, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catlibc1.sql - parsing user and links for parsing the library cache
Rem
Rem    DESCRIPTION
Rem      SQL*Plus command file to create user which has the right to compile 
Rem	   the library cache on the local instance.
Rem      
Rem	 
Rem    RETURNS
Rem      This package is executed at setup for the package dbms_libcache.
Rem
Rem    NOTES
Rem      Must be run from connected to SYS (or internal)
Rem	 A private link should be created for the parsing user. This may
Rem	 result in ora-2094 (bug 1282056). To work around this problem use a
Rem    public link and proxy username.
Rem
Rem
Rem    CREATED    
Rem    ccolrain    08/08/00 - created.         
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ccolrain    10/10/00	for bug 128056 private database links are not resolved.
-----------------------------------------------------------------------

  ---------------------------------
  -- 
  -- OVERVIEW
  -- This script creates the parsing user and a private database link.  It is executed
  -- from sys and grants the parsing user the right to create database links
  -- and to select from the system catalogue. Sites are encouraged to use a database 
  -- link with current_user and authentication through the LDAP directory service.
 
  -- skip over errors.

set echo off verify off showmode off;
whenever sqlerror continue;

drop user parser cascade ;

prompt ... Creating the parsing user and database link.
prompt
prompt  Below are the list of online tablespaces in this database.
prompt  Decide which tablespace you wish to use for the PARSER user.

select tablespace_name 
	from sys.dba_tablespaces 
	where tablespace_name <> 'SYSTEM'
	and status = 'ONLINE';

prompt  Please enter the parsing users password and tablespaces.
prompt

create user parser identified by &parser_password
  	default tablespace &default_tablespace
  	temporary tablespace &temporary_tablespace ;
  
grant create session
	, create database link
	, create public database link
	, drop public database link
	, alter session
	, select_catalog_role
	to parser;
  
connect parser / &&parser_password

Rem Replace with provate database links following fix to bug 1282056
rem drop database link on a repeated execution 
drop public database link libc_link ;

rem  LDAP authentication.
rem  create database link libc_link
rem  connect to current_user
rem  using '&connect_string' ;
 
prompt  Please enter the parsing users TNS connect string.
prompt
rem Basic authentication.
  create public database link libc_link
  connect to parser identified by &&parser_password
  using '&connect_string' ;

exit ;

