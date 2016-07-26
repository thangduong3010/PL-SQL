Rem
Rem $Header: utlexpt1.sql 24-jun-99.07:59:18 echong Exp $
Rem
Rem utlexpt1.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem      utlexpt1.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    echong      06/24/99 - rename
Rem    echong      06/05/98 - exceptions table with urowid type
Rem    echong      06/05/98 - Created
Rem

create table exceptions(row_id urowid,
	                owner varchar2(30),
	                table_name varchar2(30),
		        constraint varchar2(30));

