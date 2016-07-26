Rem
Rem $Header: catsqltk.sql 27-nov-2006.11:34:43 jklein Exp $
Rem
Rem catsqltk.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catsqltk.sql - SQL Toolkit for dictionary checkers
Rem
Rem    DESCRIPTION
Rem      Creates the schema for the sql toolkit for dictionary checks
Rem
Rem    NOTES
Rem      See the prvtsqlt.sql file for the interface to these tables
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jklein      09/15/06 - check useability improvements
Rem    jklein      05/04/06 - sql toolkit 
Rem    jklein      05/04/06 - sql toolkit 
Rem    jklein      05/04/06 - Created
Rem

drop sequence sql_tk_chk_id;
create sequence sql_tk_chk_id;

Rem %%%%%%%%%%%%%%%%%%
Rem SQL_TK_COLL_CHK$
Rem %%%%%%%%%%%%%%%%%%
Rem
Rem The sql_tk_coll_chk$ table stores information about multi column
rem checks.
Rem

drop table SQL_TK_COLL_CHK$;
create table SQL_TK_COLL_CHK$
( table_name            varchar2(30) not null,
  chk_id                number not null,
  col_list              varchar2(4000) not null,
  expr                  varchar2(4000) not null,
  check_description     varchar2(256) not null
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%
Rem SQL_TK_ROW_CHK$
Rem %%%%%%%%%%%%%%%
Rem
Rem The sql_tk_row_chk$ table stores information about row checks
Rem

drop table SQL_TK_ROW_CHK$;
create table SQL_TK_ROW_CHK$
( table_name            varchar2(30) not null,
  chk_id                number not null,
  col_list              varchar2(4000) not null,
  constraint_type       varchar2(30) not null,
  check_description     varchar2(256) not null
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%
Rem SQL_TK_REF_CHK$
Rem %%%%%%%%%%%%%%%
Rem
Rem The sql_tk_ref_chk$ table stores information about referential checks.
Rem

drop table SQL_TK_REF_CHK$;
create table SQL_TK_REF_CHK$
( table_name            varchar2(30) not null,
  chk_id                number not null,
  fk_col_list           varchar2(4000) not null,
  pk_table_name         varchar2(30) not null,
  pk_col_list           varchar2(4000) not null,
  fk_filter             varchar2(4000),
  check_description     varchar2(256) not null
) tablespace SYSAUX
/

Rem %%%%%%%%%%%%%%%
Rem SQL_TK_TAB_DESC$
Rem %%%%%%%%%%%%%%%
Rem
Rem The sql_tk_tab_desc$ table contains a query that can be executed to
Rem provide more detailed information about a failure for a given table.
Rem
drop table SQL_TK_TAB_DESC$;
create table SQL_TK_TAB_DESC$
( table_name            varchar2(30) not null,
  table_query           varchar2(4000) not null
) tablespace SYSAUX
/
