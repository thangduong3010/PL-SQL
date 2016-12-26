Rem
Rem $Header: rdbms/admin/bug19289642.sql /st_rdbms_11.2.0.4.0dbpsu/1 2014/11/05 08:10:46 nkandalu Exp $
Rem
Rem bug19289642.sql
Rem
Rem Copyright (c) 2014, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      bug19289642.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This is a POST-INSTALL script that revalidates package dbms_java
Rem      which is made invalid (more precisely, unauthorized) by the revoke,
Rem      and is not otherwise revalidated in a patch context,
Rem      as it would be during upgrade.
Rem
Rem    NOTES
Rem      This script must be run as SYS.
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/bug19289642.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nkandalu    10/24/14 - revalidate objects depend on dbms_java_test
Rem    nkandalu    10/24/14 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

begin
  execute immediate
 'declare objn number;begin select obj# into objn from obj$ where name =''DBMS_JAVA'' and type#=11;dbms_utility.validate(objn);end;';
exception when others
  then null;
end;
/

