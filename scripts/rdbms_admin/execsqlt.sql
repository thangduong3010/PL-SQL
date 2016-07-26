Rem
Rem $Header: execsqlt.sql 26-may-2006.09:54:51 pbelknap Exp $
Rem
Rem execsqlt.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      execsqlt.sql - EXECutable code for SQL Tuning to run during catproc
Rem
Rem    DESCRIPTION
Rem      This script contains some procedural logic we run during catproc.
Rem
Rem    NOTES
Rem      This must be called AFTER prvtsqlt is loaded.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pbelknap    05/26/06 - Created
Rem

Rem Create the automatic SQL Tuning task
Rem   If the task already exists (catproc is being re-run), do not error.
begin
  sys.dbms_sqltune_internal.i_create_auto_tuning_task;
exception
  when others then
    if (sqlcode = -13607) then   -- task already exists
      null;
    else
      raise;
    end if;
end;
/

Rem Create our scheduler program
Rem   If the prog already exists (catproc is being re-run), do not error.
begin
  dbms_scheduler.create_program(
    program_name => 'AUTO_SQL_TUNING_PROG',
    program_type => 'PLSQL_BLOCK',
    program_action => 
      'DECLARE 
         ename VARCHAR2(30);
       BEGIN
         ename := dbms_sqltune.execute_tuning_task(
                    ''SYS_AUTO_SQL_TUNING_TASK'');
       END;',
    number_of_arguments => 0,
    enabled => TRUE,
    comments => 'Program to run automatic sql tuning task, see dbmssqlt.sql');
exception
  when others then
    if (sqlcode = -27477) then   -- program already exists
      null;
    else
      raise;
    end if;
end;
/
