Rem
Rem $Header: rdbms/admin/exfsys.sql /main/5 2009/01/08 11:05:06 ayalaman Exp $
Rem
Rem exfsys.sql
Rem
Rem Copyright (c) 2002, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      exfsys.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    09/02/08 - grant select on dba_tab_colums
Rem    ayalaman    02/08/07 - revoke connect priv
Rem    ayalaman    05/19/06 - add execute privs on dbms_jobs 
Rem    ayalaman    01/24/03 - grant permissions for dbms_sys_error
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/24/02 - lock exfsys user and expire password
Rem    ayalaman    09/06/02 - 
Rem    ayalaman    09/06/02 - Created
Rem



REM
REM Create the EXFSYS user to hold the dictionary, APIs for the 
REM Expression Filter
REM
REM prompt Enter password for user EXFSYS
REM define password = &1;
REM prompt Enter default tablespace for the user
REM define default_tablespace = &2;

prompt .. creating EXFSYS user

REM create user exfsys identified by &password default tablespace
REM   &default_tablespace; 
create user exfsys identified by exfsysss default tablespace sysaux;
alter user exfsys password expire;
alter user exfsys account lock;

grant create session to exfsys;
grant resource to exfsys;
grant create operator to exfsys;
grant create indextype to exfsys;
grant create library to exfsys;
grant execute on dbms_registry to exfsys;
grant execute on dbms_sys_error to exfsys;
grant execute on dbms_job to exfsys;
grant execute on dbms_scheduler to exfsys;

REM
REM Grant Trigger privileges for the EXFSYS user to maintain system 
REM triggers 
REM 
grant create any trigger to exfsys;
grant administer database trigger to exfsys;
grant select on dba_tab_columns to exfsys; 

