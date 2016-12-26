Rem
Rem $Header: emll/admin/scripts/ocmupgrd.sql /main/4 2009/06/11 14:08:16 pparida Exp $
Rem
Rem ocmupgrd.sql
Rem
Rem Copyright (c) 2005, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ocmupgrd.sql - Oracle Configuration Manager UPGRaDe script
Rem
Rem    DESCRIPTION
Rem      This script drops previous OCM schema.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pparida     06/04/09 - 8268571: Check for compatible param too.
Rem    dkapoor     12/20/05 - don't set any exit flag 
Rem    dkapoor     10/10/05 - dkapoor_bug-4661425
Rem    dkapoor     10/10/05 - Created
Rem

DECLARE
  /*
  Procedure to drop user
  */
  PROCEDURE  drop_user( user  IN VARCHAR2,dir_name IN VARCHAR2)
  IS
    l_ll_user_exists       NUMBER;
    l_ll_pkg_exists       NUMBER;
    l_vers            v$instance.version%TYPE;
    l_compat_vers     v$parameter.value%TYPE;
    l_dirobj_cnt   NUMBER;
  BEGIN
   select count(*) into l_ll_user_exists from dba_users where username = user;
   IF l_ll_user_exists = 1 THEN
        SELECT count(*) into l_ll_pkg_exists FROM sys.user$ u, sys.obj$ o WHERE u.name = user AND o.name ='MGMT_DB_LL_METRICS' AND o.owner# = u.user# AND o.type# = 9 AND o.status LIKE '%' ;
        IF l_ll_pkg_exists = 1 THEN
                execute immediate 'drop user '|| user ||' cascade';
        END IF;
   END IF;
   select substr(version,1,5) into l_vers from v$instance;
   begin
     select substr(value,1,5) into l_compat_vers from v$parameter where lower(name) = 'compatible';
   exception
     WHEN NO_DATA_FOUND THEN
       l_compat_vers := l_vers;
   end;
   IF l_vers != '9.0.1' AND l_vers != '8.1.7' AND l_compat_vers != '8.1.7' THEN
   	select count(*) into l_dirobj_cnt from  dba_directories where DIRECTORY_NAME = dir_name ;
       	IF l_dirobj_cnt = 1 THEN
       		execute immediate 'DROP DIRECTORY ' || dir_name;
        END IF;
   END IF;
  END drop_user; 
BEGIN
  -- Drop previous OCM user
  drop_user('CCR','CCR_CONFIG_DIR'); 
END;
/

prompt
prompt   Drop of previous OCM schema complete. 
prompt

