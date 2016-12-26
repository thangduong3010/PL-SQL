Rem
Rem $Header: dbmslibc.sql 24-may-2001.15:08:17 gviswana Exp $
Rem
Rem dbmslibc.sql
Rem
Rem  Copyright (c) Oracle Corporation 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmslibc.sql - routines for compiling the library cache
Rem
Rem    DESCRIPTION
Rem      This package provides a mechanism for applications to view
Rem      and compile cursors in the local library cache.
Rem	 
Rem    RETURNS
Rem	 Success	- PL/SQL completes successfully
Rem	 Errors	- displays the standard Oracle error stack
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    sltam       02/07/01 - Merged sltam_dbmslibc_src
Rem    ccolrain    08/08/00 - created.         
Rem    ccolrain    09/26/00 - modified for Oracle 8i to allow database links.
Rem    sltam       12/18/00 - Check-in
         
-----------------------------------------------------------------------
CREATE OR REPLACE PACKAGE dbms_libcache as

  ------------
  --  OVERVIEW
  --
  --  These routines allow an application to compile cursors in the local library 
  --  using cursors selected from the library cache on a remote instance.

  ------------------------------------------------
  --  SUMMARY OF SERVICES PROVIDED BY THIS PACKAGE
  --
  --  COMPILE_FROM_REMOTE
  --  Compile cursors is a PL/SQL procedure that provides the driving routine for 
  --  the parse processes.  This routine fetches descriptors for all SQL statements 
  --  that match the selection criteria.  It then compilation jobs to complete the 
  --  parsing.

  --  COMPILE_FROM_REMOTE_JOB
  --  Compile cursors job is a PL/SQL procedure that is initiated as a standalone
  --  job by compile_cursors.  The procedure builds SQL cursors for the following
  --  statement types.
  --  SELECT	- SQL cursors are completed, including type def. and execution plan
  --	DML		- SQL cursors are parsed.
  --	PL/SQL	- SQL cursors are parsed, loading all heaps except MCode.

  ----------------------------
  --  REQUIREMENTS
  --	1. The session executing the procedure has the role SELECT_CATALOG_ROLE
  --	2. The session executing the procedure has the authority to ALTER SCHEMA.
  --	3. The session executing the procedure has a valid database link to the same user
  --     in the source instance.

  ----------------------------
  --  EXAMPLE SETUP
  --	1. Connect to the SYS user.
  --	2. Execute the definition package 		@catlibc.sql
  --     Create a new view on the shared pool   
  --     Create the parsing user			
  --	3. Create this package header			@dbmslibc.sql
  --	   Create the package body			

  ----------------------------
  --  GENERAL USAGE RULES
  --
  --  The package is intended for (but not limited) use with Oracle Parallel Server.
  --  The public function, compile_from_remote, should be executed as follows:
  --  1) on the target instance, immediately before sessions are switched over to this
  --     instance.
  --  2) on a scheduled basis on the target instance, in advance of an unplanned
  --     failover to this instance.
  --     The scheduled execution should start after the primary instances' library
  --     cache is stable. ie. The v$sysstat statistic "hard parses" is not increasing.

  ----------------------------
  --  EXAMPLE USAGE
  --  
  --  Example 1:  Compile all cursors extracted from the primary instance.
  --   Compile all cursors locally, extracted from the instance at link PARSE_LINK.
  --   This routine may be executed as a regular job or immediately preceding switchover.
  --        connect PARSER/PARSER's password
  --        set serveroutput on;
  --        execute sys.dbms_libcache.compile_from_remote('LIBC_LINK');

  --  Example 2:  Compile all cursors for the GL application.
  --  Cursors are compiled locally from the instance at link PARSE_LINK for the parsing
  --  user GL.  Since the first parsing user is APPS, the procedure is executed twice, 
  --  once for APPS and once for GL:

  --		connect PARSER/PARSER's password
  --        set serveroutput on;
  --        execute sys.dbms_libcache.compile_from_remote('LIBC_LINK', 'APPS');
  --        execute sys.dbms_libcache.compile_from_remote('LIBC_LINK', 'GL');

  --  Example 3:  Repeated calls to compile cursors.
  --  Executing compile cursors is non-destructive. Once the cursor has been built 
  --  subsequent executions result in soft parse calls only. It is recommended to 
  --  wrapper calls with a check on the parse statistics.  When stable, the total parse 
  --  calls increases and hard parses are static.   This can be seen by selecting parse 
  --  values from V$SYSSTAT or V$MYSTAT before and after execution, as follows -
  --              select name, value from V$SYSSTAT where name like '%parse%' ;
  --  For example, the following is a sample run file.  When executing this script, note in the parse count where DBMS_LibCache also compiles recursive SQL in advance.

  --              set serveroutput on;
  --              spool parse.lis
  --              col name format a30 trunc
  --              select c.name, m.value
  --              from v$mystat m, v$statname c
  --              where c.name like '%parse%'
  --              and m.statistic# = c.statistic# ;

  --              execute sys.dbms_libcache.compile_from_remote('LIBC_LINK') ;

  --              select c.name, m.value
  --              from v$mystat m, v$statname c
  --              where c.name like '%parse%'
  --              and m.statistic# = c.statistic# ;
  --              spool off

  ----------------------------
  --  
  --  PROCEDURES AND FUNCTIONS
  --  
  ----------------------------
  -- ------------------------------------------------------------------------
  -- COMPILE FROM REMOTE
  -- ------------------------------------------------------------------------
  -- USAGE
  -- This procedure should be call when the library cache on the source 
  -- instance is stable, and whenever the target library cache is restarted.
  -- 

  procedure compile_from_remote
	( p_db_link				in	dbms_libcache$def.db_link%type	
	, p_username			in	varchar2	default	null
	, p_threshold_executions	in	natural		default	3
	, p_threshold_sharable_mem	in	natural		default 1000
	, p_parallel_degree		in	natural		default 1
	);

  --  -----------------------------------------------------------------------
  --
  -- Input arguments:
  --    p_db_link   			Database link to the source name (mandatory)
  --    p_instance_name   		Source instance name (reserved for future use)
  --    p_username        		Source username (default is all users)
  --    p_threshold_executions  	Lower bound on number of executions  
  --    p_threshold_shared_memory	Lower bound on shared memory size
  --    p_parallel_degree		Number of parallel jobs 

  --  P_DB_LINK 
  --   The database link pointing to the instance that will be used for
  --	 extracting the SQL statements. The user must have the role select_on_catalog
  --   at the source instance.  T\For improved security, the connection may use a password
  --   file or LDAP authentication. The database link is mandatory only for releases with 
  --   dbms_libcache$def.ACCESS_METHOD = DB_LINK_METHOD
  --  P_INSTANCE_NAME (reserved for future use) 
  --     The name of the instance that will be used for extracting the SQL
  --	 statements.  The instance name must be unique for all instances
  --	 excluding the local instance. The name is not case sensitive..
  --  P_USERNAME 
  --     The name of the username that will be used for extracting the SQL
  --	 statements.  The username is an optional parameter that is used
  --	 to ensure the parsing user id is the same as that on the source
  --	 instance.  For an application where users connect as a single userid, for
  --   example APPS, APPS is the parsing user_id that is recorded in the shared pool.
  --   To select only SQL statements parsed by APPS, enter the string 'APPS'
  --   in this field.  To also select statements executed by batch, repeat the
  --   executing the procedure with the schem ownner, for example GL.
  --   If the username is supplied it must be valid. The name is not case sensitive.
  --  P_THRESHOLD_EXECUTIONS 
  --     The lower bound for the number of executions, below which a SQL
  --	 statement will not be selected for parsing. This parameter is optional.  It
  --	 It allows the application to extract and compile statements with executions
  --	 for example, greater than 3.  The default value is one.  This means
  --	 SQL statements that have never executed, including invalid SQL 
  --	 statements, will not be extracted.  
  --  P_THRESHOLD_SHARABLE_MEM 
  --   The lower bound for the size of the shared memory consumed by the 
  --	 cursors on the source instance.  Below this value a SQL
  --	 statement will not be selected for parsing. This parameter is optional. It
  --	 It allows the application to extract and compile statements with 
  --	 shared memory for example, greater than 10000 bytes. 
  --  P_PARALLEL_DEGREE 
  --   The number of parallel jobs that execute to complete the parse operation.
  --	 These tasks are spawned as parallel jobs against a sub-range of the SQL 
  --	 statements selected for parsing.
  --	 This parameter is reserved for parallel compile jobs (release 2).

  -- ------------------------------------------------------------------------
  -- COMPILE FROM REMOTE JOB
  -- ------------------------------------------------------------------------
  -- USAGE
  -- Compile curors job is called as a standalone job.  This allows for
  -- parallel execution of the comilation task.  A number of optimizations
  -- are possible for the parallel execution, including by command type, by 
  -- parsing user-id, and by serving the SQL descriptors to parallel slaves.
  -- Parsing by user-id and range partitioning are provided in the first release.

  procedure compile_from_remote_job
	( p_db_link		in		dbms_libcache$def.db_link%type
	, p_SQL_tab		in out		dbms_libcache$def.SQL_tab
	, p_lower_bound         in	   	binary_integer
	, p_upper_bound         in	   	binary_integer
	);

  --  -----------------------------------------------------------------------
  --
  -- Input arguments:
  --    p_db_link   	Database link to the source name (mandatory)
  --    p_SQL_tab	SQL descriptors addressing the SQL statements to be parsed
  --    p_upper_bound   Upper address of the SQL descriptors, 1.. p_upper_bound   

  --  P_DB_LINK 
  --     The database link pointing to the instance that will be used for
  --	 extracting the SQL statements. The database link is mandatory only 
  --     for releases with dbms_libcache$def.ACCESS_METHOD = DB_LINK_METHOD
  --  P_SQL_TAB 
  --     A table of descriptive records addressing each of the SQL statements to
  --	 be parsed.  This table is constructed in the driver procedure, compile_cursors.
  --	 The record descriptor is maintianed in the include package, dbms_libcache$def.
  --  P_LOWER_BOUND
  --     A binary index that marks the lower element of the table, P_SQL_TAB. The
  --     elements are addressed from lower.. upper bound.
  --  P_UPPER_BOUND
  --     A binary index that marks the upper element of the table, P_SQL_TAB. The
  --     elements are addressed from lower bound.. upper bound.

end dbms_libcache;
/

 ---------------------------------
 --
 -- skip errors due to dropping synonyms.

 whenever sqlerror continue;

create or replace public synonym dbms_libcache for dbms_libcache
/
grant execute on dbms_libcache to public
/

grant execute on dbms_libcache to execute_catalog_role
/

 ---------------------------------
 --
 -- create the package body

@prvtlibc.plb
