Rem
Rem $Header: rdbms/admin/catmacpre.sql /main/5 2008/10/30 10:18:39 jsamuel Exp $
Rem
Rem catmacpre.sql
Rem
Rem Copyright (c) 2007, 2008, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catmacpre.sql - Creates DV Account Manager Account
Rem
Rem    DESCRIPTION
Rem      This script is called at the end of catmac script and creates the
Rem       DV account manager.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA and requires that passwords be specified for
Rem      SYSDBA, DV_OWNER and DV_ACCOUNT_MANAGER
Rem
Rem        Parameter 1 = account default tablespace
Rem        Parameter 2 = account temp tablespace
Rem        Parameter 3 = SYS password
Rem        Parameter 4 = DV_OWNER_USERNAME
Rem        Parameter 5 = DV_OWNER_PASSWORD
Rem        Parameter 6 = DV_ACCOUNT_MANAGER_USERNAME
Rem        Parameter 7 = DV_ACCOUNT_MANAGER_PASSWORD
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsamuel     09/24/08 - passwordless patching
Rem    pknaggs     06/20/07 - 6141884: backout fix for bug 5716741.
Rem    pknaggs     05/31/07 - 5716741: sysdba can't do account management.
Rem    ruparame    05/18/07 - Make DV account manager optional
Rem    ruparame    01/13/07 - DV/DBCA Integration
Rem    ruparame    01/10/07 - DV/DBCA Integration
Rem    ruparame    01/10/07 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100


connect sys/"&3" as sysdba 

SET VERIFY OFF

ALTER USER dvsys IDENTIFIED BY "&5"
/
ALTER USER dvf IDENTIFIED BY "&5"
/


--Create  DV_OWNER account

CREATE USER &4 IDENTIFIED BY "&5"
DEFAULT TABLESPACE &1
TEMPORARY TABLESPACE &2
/

--Create  DV_ACCTMGR account, if specified by the user
BEGIN
  IF '&6' <> '&4'  THEN
      EXECUTE IMMEDIATE
      ' CREATE USER '             || '&6'
      || ' IDENTIFIED BY '        || '"&7"'
      || ' DEFAULT TABLESPACE '   || '&1'
      || ' TEMPORARY TABLESPACE ' || '&2' ;
  END IF;
END;
/

GRANT CONNECT TO &4
/

GRANT ADMINISTER DATABASE TRIGGER TO &4
/

GRANT ALTER ANY TRIGGER TO &4
/

BEGIN
    IF '&6' <> '&4'  THEN
        EXECUTE IMMEDIATE 'GRANT CONNECT TO ' || '&6';
    END IF;
END;
/

-- Grant Data Vault roles and privileges to installation accounts
connect dvsys/"&5"

GRANT dv_owner TO &4 WITH ADMIN OPTION
/
GRANT EXECUTE ON sys.dbms_rls TO &4 WITH GRANT OPTION
/

BEGIN
    IF '&6' <> '&4'  THEN
        EXECUTE IMMEDIATE 'GRANT dv_acctmgr TO ' || '&6 WITH ADMIN OPTION';
    ELSE
        EXECUTE IMMEDIATE 'GRANT dv_acctmgr TO ' || '&4 WITH ADMIN OPTION';
    END IF;
END;
/

connect sys/"&3" as sysdba 

DECLARE
    num number;
BEGIN
    dbms_registry.loaded('DV');
    SYS.validate_dv;
END;
/
commit;
