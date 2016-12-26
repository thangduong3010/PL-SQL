Rem
Rem $Header: emll/admin/scripts/catocm.sql /st_emll_10.3.8/2 2012/12/24 22:12:39 jsutton Exp $
Rem
Rem catocm.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catocm.sql - Create and grant privileges to the OCM user.
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: emll/admin/scripts/catocm.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/catocm.sql
Rem SQL_PHASE: CATOCM
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/dbmsocm.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsutton     11/15/12 - bring cdb/pdb changes in
Rem    jsutton     03/21/12 - PDB support
Rem    jsutton     02/19/12 - grants modified per rdbms team
Rem    rpang       08/18/11 - Proj 32719: Grant/revoke inherit privileges
Rem    jsutton     07/06/11 - Grant create job privs
Rem    glavash     10/30/09 - remove set echo off bug 9073306
Rem    glavash     07/09/09 - remove 8222370 changes
Rem    glavash     05/28/09 - randomize password
Rem    glavash     05/28/09 - remove set echo on
Rem    glavash     08/19/08 - change password on account
Rem    dkapoor     08/03/07 - grant specific table acces
Rem    dkapoor     01/04/07 - remove drop of oracle_ocm user
Rem    dkapoor     07/26/06 - do not use define 
Rem    dkapoor     06/06/06 - move directory creation after installing the 
Rem                           packages 
Rem    dkapoor     05/23/06 - Created
Rem

create user ORACLE_OCM identified by "OCM_3XP1R3D" account lock password expire;

-- provide correct privileges
DECLARE
  l_vers   v$instance.version%TYPE;
  l_is_cdb VARCHAR2(4) := 'NO';
BEGIN
  execute immediate 'GRANT CREATE JOB TO ORACLE_OCM';

  -- privileges that are new to db 12.1, will fail in earlier db versions
  BEGIN
    select LPAD(version,10,'0') into l_vers from v$instance;
    IF l_vers >= '12.1.0.0.0' THEN
      execute immediate 'GRANT INHERIT ANY PRIVILEGES TO ORACLE_OCM';
      execute immediate 'GRANT INHERIT PRIVILEGES ON USER SYS TO ORACLE_OCM';
      execute immediate 'SELECT CDB FROM V$DATABASE' into l_is_cdb;
      IF (l_is_cdb = 'YES') THEN
        BEGIN
          execute immediate 'GRANT SET CONTAINER TO ORACLE_OCM CONTAINER=ALL';
          EXCEPTION
          WHEN OTHERS THEN
            -- ignore any exception
            null;
        END;
      END IF;
      BEGIN
        execute immediate 'REVOKE INHERIT PRIVILEGES ON USER ORACLE_OCM FROM PUBLIC';
        EXCEPTION
        WHEN OTHERS THEN
          -- ignore any exception
          null;
      END;
    END IF;
  END;

END;
/

