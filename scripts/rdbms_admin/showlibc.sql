Rem
Rem $Header: showlibc.sql 07-feb-2001.11:06:02 sltam Exp $
Rem
Rem showlibc.sql
Rem
Rem  Copyright (c) Oracle Corporation 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      showlibc.sql - SQL to display the parent/child/bind tree
Rem
Rem    DESCRIPTION
Rem      This simple SQL uses new views for oracle8i to display the
rem	 the sharing tree in the library cache
Rem	 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sltam       02/07/01 - Merged sltam_dbmslibc_src
Rem    sltam       12/18/00 - Check-in
rem
rem    USAGE	
Rem	 Enter a fragment of the SQL to display the sharing tree.
rem	 Press return to report the tree for all SQL in the library cache.
rem 
rem    NOTES
rem    V$SQL2 is created by catlibc.sql to allow navigation to bind variables

spool showlibc
set pages 60 lines 72 echo off verify off feedback 4

col sql_text    format   a40 wrap  heading 'SQL text'
col hash_value  format   9999999999 heading 'hash value'
col address     format   99999999   heading 'parent'
col child_address format 99999999   heading 'child'
col optimizer_mode format a10       heading 'optimizer'
col executions  format   99999999   heading 'execution'
col object_status format a10 trunc  heading 'SQL status'
col parsing_user_id  format   9999  heading 'user id'
col parsing_schema_id  format 9999  heading 'schema id'
col datatype    format   a10	    heading 'data type'
col max_length  format   999999	    heading 'bind length'

break on sql_text on hash_value on address on child_address on optimizer_mode on object_status on executions on parsing_user_id on parsing_schema_id 
break on sql_text on hash_value on address on child_address skip 1

select 
  s.sql_text
, s.hash_value
, s.address
, s.child_address
, s.optimizer_mode
, s.object_status
, s.executions
, s.parsing_user_id
, s.parsing_schema_id
, decode(b.datatype
	,1, 'string'	
	,2, 'numeric'	  
	,3, 'integer'   		
	,4, 'float' 			
	,5, 'text' 	
	,6, 'number'	
	,7, 'decimal'		
	,8, 'long'			
	,9, 'string'	
	,10,'table'				
	,11,'row id'				
	,12,'date' 				
	,23,'RAW'	
	,24,'long RAW' 	
	,96,'fixed char'
	,b.datatype)datatype
, b.max_length
from v$sql2 s
,    v$sql_bind_metadata b
where 
s.sql_text like '%&SQL_TEXT_FRAGMENT%'
and s.child_address = b.address (+)
and s.sql_text not like '%decode(b.datatype%'
group by
  s.sql_text
, s.hash_value
, s.address
, s.child_address
, s.optimizer_mode
, s.object_status
, s.executions
, s.parsing_user_id
, s.parsing_schema_id
, decode(b.datatype
	,1, 'string'	
	,2, 'numeric'	  
	,3, 'integer'   		
	,4, 'float' 			
	,5, 'text' 	
	,6, 'number'	
	,7, 'decimal'		
	,8, 'long'			
	,9, 'string'	
	,10,'table'				
	,11,'row id'				
	,12,'date' 				
	,23,'RAW'	
	,24,'long RAW' 	
	,96,'fixed char'
	,b.datatype)
, b.max_length
order by
  s.sql_text
, s.hash_value
, s.address
, s.child_address
/
spool off

