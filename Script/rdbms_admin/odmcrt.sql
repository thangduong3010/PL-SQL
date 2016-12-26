Rem 
Rem $Header: odmcrt.sql 28-mar-2006.09:50:07 lburgess Exp $ template.tsc 
Rem 
Rem Copyright (c) 2001, 2006, Oracle. All rights reserved.  
Rem
Rem NAME
Rem    ODMCRT.SQL
Rem
Rem
Rem NOTES
Rem    This script sets up the Data Mining DMSYS account for 10i Release One 
Rem
Rem    Script to be run as SYS. 
Rem  
Rem    DMUSER_ROLE is to be granted to DM User account. 
Rem
Rem    CREATE LIBRARY to be revoked at the end of Installation
Rem
Rem   MODIFIED    (MM/DD/YY)  
REm   lburgess     03/28/06 - use lowercase for DMSYS password 
REm   mmcracke     03/27/06 - Fix lrg 2121248 
REm   mmcracke     04/01/05 - Move from DMSYS to SYS. 
REm   xbarr        10/25/04 - remove ctx_ddl privs 
REm   xbarr        09/09/04 - add ctx_ddl exec privileges 
REm   xbarr        07/23/04 - cleanup DMSYS privs 
REm   xbarr        06/25/04 - xbarr_dm_rdbms_migration
REm   xbarr        05/12/04 - add read privilege on dba_registry 
REm   svenkaya     03/10/04 - added create job privilege to dmsys
REm   xbarr        11/12/03 - fix bug 3253120 
REm   xbarr        10/28/03 - add drop role for DBCA to reconfigure DMSYS 
REm   xbarr        07/16/03 - fix bug 3053055 
REm   fcay         06/23/03 - Update copyright notice
REm   xbarr        06/02/03 - integrate PL/SQL api exp/imp privs 
REm   xbarr        03/24/03 - remove ctx privs and odm_user 
REm   xbarr        03/13/03 - Add ctx privs 
REm   xbarr        02/03/03 - grant dbms_registry priv 
REm   xbarr        01/07/03 - temp tbs as an input from DBCA 
REm   xbarr        11/19/02 - create dmuser role 
REm   xbarr        11/05/02 - pass sysaux as input parameter for DBCA
Rem   xbarr        11/05/02 - add dbms_sys_error priv
Rem   xbarr        10/10/02 - change quota on sysaux
Rem   xbarr        09/25/02 - xbarr_txn104463
Rem   xbarr        09/24/02 - Modified for 10i Migration
Rem   xbarr        04/22/02 - Creation
Rem
Rem ========================================================================================

drop user DMSYS cascade;

create user DMSYS identified by dmsys default tablespace &&1 temporary tablespace &&2 quota 200M on &&1;

grant
  CREATE SESSION,
  CREATE TRIGGER,
  CREATE PROCEDURE,
  CREATE SEQUENCE,
  CREATE VIEW,
  CREATE SYNONYM,
  QUERY REWRITE,
  CREATE TABLE,
  ALTER SESSION,
  CREATE TYPE,
  ALTER SYSTEM,
  CREATE PUBLIC SYNONYM,
  DROP PUBLIC SYNONYM,
  CREATE LIBRARY,
  CREATE JOB
to dmsys;

GRANT SELECT on dba_temp_files to DMSYS;
GRANT SELECT on dba_jobs_running to DMSYS;
GRANT SELECT on v_$session to DMSYS; 
GRANT SELECT on v_$parameter to DMSYS; 
GRANT SELECT on dba_tab_privs to DMSYS;
GRANT SELECT on dba_sys_privs to DMSYS;
GRANT SELECT on dba_registry to DMSYS;
GRANT EXECUTE on dbms_registry to DMSYS;
GRANT EXECUTE on dbms_sys_error to DMSYS;
GRANT EXECUTE on dbms_lock to DMSYS;

commit;

Rem PL/SQL API exp/imp privilegs

DELETE FROM exppkgact$
        WHERE SCHEMA='SYS'
          AND package='DBMS_DM_MODEL_EXP'
          AND class IN (2,3,6)
          AND level# IN (1000,2000,4000);

INSERT INTO exppkgact$ (package, schema, class, level#)
        VALUES ('DBMS_DM_MODEL_EXP', 'SYS', 2, 2000);
INSERT INTO exppkgact$ (package, schema, class, level#)
        VALUES ('DBMS_DM_MODEL_EXP', 'SYS', 3, 4000);
INSERT INTO exppkgact$ (package, schema, class, level#)
        VALUES ('DBMS_DM_MODEL_EXP', 'SYS', 6, 1000);
commit;

