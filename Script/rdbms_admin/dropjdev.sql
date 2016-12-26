Rem
Rem $Header: rdbms/admin/dropjdev.sql /st_rdbms_11.2.0.4.0dbpsu/1 2016/02/09 20:07:00 mlfallon Exp $
Rem
Rem dropjdev.sql
Rem
Rem Copyright (c) 2014, 2016, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dropjdev.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dropjdev.sql 
Rem    SQL_SHIPPED_FILE: rdbms/admin/dropjdev.sql
Rem    SQL_PHASE: PATCH 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mlfallon    10/07/14 - Drop DBMS_JAVA_DEV and restore Java Grants.
Rem    mlfallon    10/07/14 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

declare
  package_missing exception;
  pragma exception_init(package_missing, -6550);
begin
  execute immediate 'begin sys.dbms_java_dev.enable; end;';
exception
  when package_missing then
    null;
end;
/

declare
  role_exists exception;
  pragma exception_init(role_exists, -1919);
begin
  execute immediate 'drop role oracle_java_dev';
exception
  when role_exists then
    null;
end;
/

declare
  synonym_exists exception;
  pragma exception_init(synonym_exists, -1432);
begin
  execute immediate 'drop public synonym java_dev_status';
exception
  when synonym_exists then
    null;
end;
/

declare
  view_exists exception;
  pragma exception_init(view_exists, -942);
begin
  execute immediate 'drop view sys.java_dev_status';
exception
  when view_exists then
    null;
end;
/

declare
  trigger_exists exception;
  pragma exception_init(trigger_exists, -4080);
begin
  execute immediate 'drop trigger sys.dbms_java_dev_trg';
exception
  when trigger_exists then
    null;
end;
/

declare
  package_exists exception;
  pragma exception_init(package_exists, -4043);
begin 
  execute immediate 'drop package sys.dbms_java_dev';
exception
  when package_exists then
    null;
end;
/

declare
  constraint_exists exception;
  pragma exception_init(constraint_exists, -2443);
begin 
  execute immediate 'alter table sys.procedurejava$ drop constraint 
                     java_dev_disabled';
exception
  when constraint_exists then
    null;
end;
/

declare
  constraint_exists exception;
  pragma exception_init(constraint_exists, -2443);
begin
  execute immediate 'alter table sys.javajar$ drop constraint 
                     java_dev_jars_disabled';
exception
  when constraint_exists then
    null;
end;
/

