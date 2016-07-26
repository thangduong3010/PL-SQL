Rem
Rem $Header: rdbms/admin/sbcusr.sql /st_rdbms_11.2.0/1 2012/02/08 01:08:58 ineall Exp $
Rem
Rem sbcusr.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      sbcusr.sql - StandBy statspack Create USeR
Rem
Rem    DESCRIPTION
Rem      SQL*Plus command file to create user which will contain the
Rem      STANDBY STATSPACK database objects.
Rem
Rem    NOTES
Rem      Must be run from connected to SYS (or internal)
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ineall      02/06/12 - Backport ineall_bug-11899453 from main
Rem    shsong      04/23/07 - Fix bug 
Rem    wlohwass    12/04/06 - Created, based on spcusr.sql
Rem

set echo off verify off showmode off feedback off;
whenever sqlerror exit sql.sqlcode

prompt
prompt Choose the STDBYPERF user's password
prompt ------------------------------------  

prompt Not specifying a password will result in the installation FAILING
prompt
prompt &&stdbyuser_password

Rem Begin spooling after password has been entered
spool sbcusr.lis

begin
  if '&&stdbyuser_password' is null then
    raise_application_error(-20101, 'Install failed - No password specified for STDBYPERF user');
  end if;
end;
/


Rem
Rem  Set up user's temporary and default tablespaces
Rem

prompt
prompt
prompt Choose the Default tablespace for the STDBYPERF user
prompt ----------------------------------------------------

prompt Below is the list of online tablespaces in this database which can
prompt store user data.  Specifying the SYSTEM tablespace for the user's 
prompt default tablespace will result in the installation FAILING, as 
prompt using SYSTEM for performance data is not supported.
prompt
prompt Choose the STDBYPERF users's default tablespace.  This is the tablespace
prompt in which the STATSPACK tables and indexes will be created.

column db_default format a28 heading 'STATSPACK DEFAULT TABLESPACE'
select tablespace_name, contents
     , decode(tablespace_name,'SYSAUX','*') db_default
  from sys.dba_tablespaces 
 where tablespace_name <> 'SYSTEM'
   and contents = 'PERMANENT'
   and status = 'ONLINE'
 order by tablespace_name;

prompt
prompt Pressing <return> will result in STATSPACK's recommended default
prompt tablespace (identified by *) being used.
prompt

set heading off
col default_tablespace new_value default_tablespace noprint
select 'Using tablespace '||
       upper(nvl('&&default_tablespace','SYSAUX'))||
       ' as STDBYPERF default tablespace.'
     , nvl('&default_tablespace','SYSAUX') default_tablespace
  from sys.dual;
set heading on

begin
  if upper('&&default_tablespace') = 'SYSTEM' then
    raise_application_error(-20101, 'Install failed - SYSTEM tablespace specified for DEFAULT tablespace');
  end if;
end;
/


prompt
prompt
prompt Choose the Temporary tablespace for the STDBYPERF user
prompt ------------------------------------------------------

prompt Below is the list of online tablespaces in this database which can
prompt store temporary data (e.g. for sort workareas).  Specifying the SYSTEM 
prompt tablespace for the user's temporary tablespace will result in the 
prompt installation FAILING, as using SYSTEM for workareas is not supported.

prompt
prompt Choose the STDBYPERF user's Temporary tablespace.

column db_default format a26 heading 'DB DEFAULT TEMP TABLESPACE'
select t.tablespace_name, t.contents
     , decode(dp.property_name,'DEFAULT_TEMP_TABLESPACE','*') db_default
  from sys.dba_tablespaces t
     , sys.database_properties dp
 where t.contents           = 'TEMPORARY'
   and t.status             = 'ONLINE'
   and dp.property_name(+)  = 'DEFAULT_TEMP_TABLESPACE'
   and dp.property_value(+) = t.tablespace_name
 order by tablespace_name;

prompt
prompt Pressing <return> will result in the database's default Temporary 
prompt tablespace (identified by *) being used.
prompt

set heading off
col temporary_tablespace new_value temporary_tablespace noprint
select 'Using tablespace '||
       nvl('&&temporary_tablespace',property_value)||
       ' as STDBYPERF temporary tablespace.'
     , nvl('&&temporary_tablespace',property_value) temporary_tablespace
  from database_properties
 where property_name='DEFAULT_TEMP_TABLESPACE';
set heading on

begin
  if upper('&&temporary_tablespace') = 'SYSTEM' then
    raise_application_error(-20101, 'Install failed - SYSTEM tablespace specified for TEMPORARY tablespace');
  end if;
end;
/


prompt
prompt
prompt ... Creating STDBYPERF user

create user stdbyperf
  identified by &&stdbyuser_password
  default tablespace &&default_tablespace
  temporary tablespace &&temporary_tablespace;

alter user STDBYPERF quota unlimited on &&default_tablespace;

create trigger stdbyperf.stdbyperf_logon after logon on stdbyperf.schema
begin
  execute immediate 'ALTER SESSION SET GLOBAL_NAMES=FALSE';
end;
/


prompt
prompt
prompt ... Installing required packages

Rem
Rem  Install required packages
Rem

@@dbmspool

prompt
prompt
prompt ... Granting privileges

Rem
Rem  Grant privileges
Rem

/*  System privileges  */
grant create session              to STDBYPERF;
grant alter  session              to STDBYPERF;
grant create table                to STDBYPERF;
grant create view                 to STDBYPERF;
grant create procedure            to STDBYPERF;
grant create sequence             to STDBYPERF;
grant create database link        to STDBYPERF;
grant create public synonym       to STDBYPERF;
grant drop   public synonym       to STDBYPERF;

/*  Packages  */
grant execute on DBMS_SHARED_POOL to STDBYPERF;
grant execute on DBMS_JOB         to STDBYPERF;



prompt
prompt NOTE:
prompt   SBCUSR complete. Please check sbcusr.lis for any errors.
prompt

spool off;
whenever sqlerror continue;
set echo on feedback on;
