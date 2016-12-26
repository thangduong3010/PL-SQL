Rem
Rem $Header: rdbms/admin/dbmsjdev.sql /st_rdbms_11.2.0.4.0dbpsu/1 2016/02/09 20:07:00 mlfallon Exp $
Rem
Rem dbmsjdev.sql
Rem
Rem Copyright (c) 2014, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsjdev.sql - Create the DBMS_JAVA_DEV package 
Rem
Rem    DESCRIPTION
Rem      DBMS_JAVA_DEV package can to used to enable or disable the grants 
Rem      on Java classes to PUBLIC. A new role ORACLE_JAVA_DEV is introduced.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsjdev.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dbmsjdev.sql
Rem    SQL_PHASE: PATCH 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfallon    10/07/14 - Add Grants for dependencies
Rem    mlfallon    10/04/14 - Add PDB support
Rem    mlfallon    10/02/14 - Add JVMRJBCINV
Rem    mlfallon    09/16/14 - Block PL/SQL Wrapper creation.
Rem    mlfallon    09/15/14 - Package to lock down Java grants to public
Rem    mlfallon    09/15/14 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

declare
  role_exists exception;
  pragma exception_init(role_exists, -1921);
begin
  execute immediate 'create role oracle_java_dev';
exception
  when role_exists then
    null;
end;
/

create or replace trigger sys.dbms_java_dev_trg before create 
on database disable
begin
  if (ora_dict_obj_type='JAVA')
  then
    raise_application_error(-20031,'Java Development Disabled');
  end if;
end;
/

create or replace view sys.java_dev_status as 
select decode(status,'ENABLED','NO','YES') JAVA_DEV_ALLOWED
from dba_triggers
where trigger_name='DBMS_JAVA_DEV_TRG'
  and owner='SYS';


create or replace public synonym java_dev_status for sys.java_dev_status;
grant select on java_dev_status to public;

declare
  constraint_exists exception;
  pragma exception_init(constraint_exists, -2264);
begin
  execute immediate 'alter table sys.procedurejava$ add constraint 
                     java_dev_disabled check (obj# = 0) disable';
exception
  when constraint_exists then
    null;
end;
/

declare
  constraint_exists exception;
  pragma exception_init(constraint_exists, -2264);
begin
  execute immediate 'alter table sys.javajar$ add constraint 
                     java_dev_jars_disabled check (owner# = -1) disable';
exception
  when constraint_exists then
    null;
end;
/


create or replace package sys.dbms_java_dev authid definer is

  procedure disable;
  
  procedure enable;

end dbms_java_dev;
/

create or replace package body sys.dbms_java_dev is

  procedure disable is
    type grant_collection is table of sys.dba_tab_privs.table_name%type;
    jdev_grants grant_collection;
    type grantee_collection is table of sys.dba_tab_privs.grantee%type;
    jdev_grantees grantee_collection;
    pkg_name sys.dba_tab_privs.table_name%type;
    grantee varchar2(130);
    stmt varchar2(2000);
    stmt2 varchar2(2000);
  begin

    select distinct owner, referenced_name bulk collect 
    into jdev_grantees, jdev_grants
    from sys.dba_dependencies 
    where referenced_owner in ('SYS','PUBLIC') and owner != 'PUBLIC'
      and owner != referenced_owner
      and referenced_name in ('DBMS_JAVA','DBMS_JAVA_TEST','SQLJUTL',
                              'SQLJUTL2','JVMRJBCINV','DBMS_JAVA_MISC');

    for i in 1..jdev_grants.count loop
      pkg_name := dbms_assert.simple_sql_name(jdev_grants(i));
      grantee := dbms_assert.enquote_name(jdev_grantees(i),FALSE);
      stmt := 'grant execute on sys.' || pkg_name || ' to ' || grantee;
      execute immediate stmt;
    end loop;

    select table_name bulk collect into jdev_grants from sys.dba_tab_privs 
    where grantee='PUBLIC' and owner='SYS' and privilege='EXECUTE' 
      and table_name in ('DBMS_JAVA','DBMS_JAVA_TEST','SQLJUTL','SQLJUTL2',
                         'JVMRJBCINV','DBMS_JAVA_MISC');

    for i in 1..jdev_grants.count loop 
      pkg_name := dbms_assert.simple_sql_name(jdev_grants(i));
      stmt := 'revoke execute on sys.' || pkg_name || ' from public';
      stmt2 := 'grant execute on sys.' || pkg_name || ' to oracle_java_dev';
      execute immediate stmt;
      execute immediate stmt2;
    end loop;

    execute immediate 'alter trigger sys.dbms_java_dev_trg enable';

    execute immediate 'alter table sys.procedurejava$ enable novalidate 
                       constraint java_dev_disabled';
    execute immediate 'alter table sys.javajar$ enable novalidate 
                       constraint java_dev_jars_disabled';

  end disable;

  procedure enable is
    type grant_collection is table of sys.dba_tab_privs.table_name%type;
    jdev_grants grant_collection;
    pkg_name sys.dba_tab_privs.table_name%type;
    stmt varchar2(2000);
    stmt2 varchar2(2000);
  begin
 
    execute immediate 'alter trigger sys.dbms_java_dev_trg disable';

    execute immediate 'alter table sys.procedurejava$ disable constraint 
                       java_dev_disabled';
    execute immediate 'alter table sys.javajar$ disable constraint 
                       java_dev_jars_disabled';

    select table_name bulk collect into jdev_grants from sys.dba_tab_privs  
    where grantee='ORACLE_JAVA_DEV' and privilege='EXECUTE' and owner='SYS' 
      and table_name in ('DBMS_JAVA','DBMS_JAVA_TEST','SQLJUTL','SQLJUTL2',
                         'JVMRJBCINV','DBMS_JAVA_MISC');

    for i in 1..jdev_grants.count loop
      pkg_name := dbms_assert.simple_sql_name(jdev_grants(i));
      stmt := 'grant execute on sys.' || pkg_name || ' to public';
      stmt2 := 'revoke execute on sys.' || pkg_name || ' from oracle_java_dev';
      execute immediate stmt;
      execute immediate stmt2;
    end loop;

  end enable;
end dbms_java_dev;
/

