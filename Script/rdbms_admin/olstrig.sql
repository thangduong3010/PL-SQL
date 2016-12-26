Rem
Rem $Header: rdbms/admin/olstrig.sql /main/3 2010/06/04 09:11:44 aramappa Exp $
Rem
Rem olstrig.sql
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      olstrig.sql - Disable and Enable policies on tables to 
Rem      recreate triggers. Should be run only when OLS is configured on DB.
Rem
Rem    DESCRIPTION
Rem      The script is run at the end of Database upgrade from releases
Rem      prior to 10.2 to current release. It recreates DML triggers
Rem      on tables which have Label Security policies applied.
Rem      
Rem      The script also needs to be run as a post downgrade step
Rem      when downgrading to releases prior to 10.2 ,namely 10.1 and 9.2.
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aramappa    04/28/10 - bug 9555367: use dbms_assert
Rem    srtata      04/16/09 - update description to indicate downgrade action
Rem    srtata      08/06/04 - srtata_bug-3803121
Rem    srtata      16/07/04 - Created
Rem

DECLARE
   sname varchar2(30);
   tname varchar2(30);
   pname varchar2(30);
   trunc_pname varchar2(30);
   prole VARCHAR2(30);
   CURSOR policy_role IS
     SELECT DISTINCT policy_name
       FROM lbacsys.dba_sa_policies p;

   CURSOR table_pol IS
     SELECT DISTINCT schema_name, table_name, policy_name
       FROM lbacsys.dba_sa_table_policies pt;

   pol_row table_pol%ROWTYPE;
   role_row policy_role%ROWTYPE;

BEGIN
   
   -- Grant policy_DBA role to SYS
   FOR role_row IN policy_role LOOP
     pname := role_row.policy_name;
     IF lengthb(pname) > 26 THEN
       trunc_pname := lbacsys.lbac_utl.nls_substrb(pname, 26);
     ELSE
       trunc_pname := pname;
     END IF;

     prole := upper(trunc_pname) || '_DBA';
     EXECUTE IMMEDIATE 'GRANT ' || dbms_assert.enquote_name(prole,FALSE) || ' TO SYS';
   END LOOP;

   FOR pol_row IN table_pol LOOP
      sname := pol_row.schema_name;
      tname := pol_row.table_name;
      pname := pol_row.policy_name;
      SA_POLICY_ADMIN.DISABLE_TABLE_POLICY(pname, sname, tname);
      SA_POLICY_ADMIN.ENABLE_TABLE_POLICY(pname, sname, tname);
   END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;

END;
/

show errors;
