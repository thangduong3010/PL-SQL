rem 
rem $Header: utlexcpt.sql,v 1.1 1992/10/20 11:57:02 GLUMPKIN Stab $ 
rem 
Rem  Copyright (c) 1991 by Oracle Corporation 
Rem    NAME
Rem      except.sql - <one-line expansion of the name>
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem    RETURNS
Rem 
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem    MODIFIED   (MM/DD/YY)
Rem     glumpkin   10/20/92 -  Renamed from EXCEPT.SQL 
Rem     epeeler    07/22/91 -         add comma 
Rem     epeeler    04/30/91 -         Creation 

create table exceptions(row_id rowid,
	                owner varchar2(30),
	                table_name varchar2(30),
		        constraint varchar2(30));
