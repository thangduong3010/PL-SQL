Rem
Rem $Header: rdbms/admin/catmacpost.sql /main/10 2009/05/16 11:13:02 jheng Exp $
Rem
Rem catmacpost.sql
Rem
Rem Copyright (c) 2007, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catmacpost.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jheng       05/11/09 - add handler for EXFSYS not exiting case
Rem    vigaur      03/26/09 - Bug 8372127. Remove os_authent_prefix
Rem    jheng       12/25/08 - add "alter system" to Fix Bug 7638934
Rem    ruparame    09/02/08 - Bug 7319691 Grant DV_MONITOR role to DBSNMP
Rem    clei        07/18/08 - use enable_dv_check instead of enabling DV event trigger
Rem    ruparame    06/01/07 - Remove redundant lock and disable connections
Rem                           comand
Rem    jibyun      05/29/07 - 6057128: gather statistics on dvsys after DV
Rem                           config
Rem    ruparame    05/18/07 - Make DV account manager role optional
Rem    ruparame    01/18/07 - Post installation DV/DBCA
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

SET VERIFY OFF
connect dvsys/"&5"

exec dbms_stats.gather_schema_stats('DVSYS');

-- update DV enforcement status
exec DVSYS.dbms_macadm.enable_dv_check;

-- Locks and disables connections in the DVSYS and DVF accounts

connect &6/"&7"
BEGIN
        EXECUTE IMMEDIATE 'REVOKE CONNECT FROM dvsys';
        EXECUTE IMMEDIATE 'REVOKE CONNECT FROM dvf';
        EXECUTE IMMEDIATE 'ALTER USER dvsys ACCOUNT LOCK';
        EXECUTE IMMEDIATE 'ALTER USER dvf ACCOUNT LOCK';
END;
/

connect &4/"&5"
--
-- Sync rules in the Rule Engine.
--

exec DVSYS.dbms_macadm.sync_rules;

--
-- Enables all command rules in row cache
--

BEGIN
  FOR command_rule_rec IN (SELECT * FROM dvsys.dba_dv_command_rule) LOOP
    dbms_macadm.update_command_rule(
      command =>       command_rule_rec.command,
      rule_set_name => command_rule_rec.rule_set_name,
      object_owner =>  command_rule_rec.object_owner,
      object_name =>   command_rule_rec.object_name,
      enabled =>       dbms_macutl.g_yes);
  END LOOP;
  COMMIT;
END;
/

-- Grant DV_MONITOR role to the Enterprise Manager agent (DBSNMP)
GRANT DV_MONITOR to DBSNMP;

--Re-enable OLS triggers

ALTER TRIGGER LBACSYS.lbac$after_drop    ENABLE;
ALTER TRIGGER LBACSYS.lbac$after_create  ENABLE;
ALTER TRIGGER LBACSYS.lbac$before_alter  ENABLE;

COMMIT;

--Bug 7638934:  change initialization parameters, which is included in 
--DVCA on 10g
connect sys/"&3" as sysdba
alter system set audit_sys_operations=TRUE scope=spfile; 
alter system set os_roles=FALSE scope=spfile; 
alter system set recyclebin='OFF' scope=spfile; 
alter system set remote_login_passwordfile='EXCLUSIVE' scope=spfile; 
alter system set sql92_security=TRUE scope=spfile; 
-- Bug 8372127. Removed os_authent_prefix

-- Authorize SYS to run jobs under EXFSYS schema, in order to bypass
-- the DV job auth for the two default background jobs under EXFSYS schema.
connect &4/"&5"
begin
  dbms_macadm.authorize_scheduler_user('SYS', 'EXFSYS');
exception when others then
  -- Ignore the error if EXFSYS is not created.
  if SQLCODE in (-47324, -47951) then 
    null;
  else 
    raise;
  end if;
end;
/

COMMIT;
