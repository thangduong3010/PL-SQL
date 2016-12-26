Rem
Rem $Header: olsdap.sql 31-oct-2002.11:40:49 srtata Exp $
Rem
Rem olsdap.sql
Rem
Rem Copyright (c) 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      olsdap.sql - Drop and Add rls Policies on certain tables with OLS.
Rem
Rem    DESCRIPTION
Rem      This script is needed as part of the fix for bug#2499257. It is
Rem      called by olspatch.sql which in turn is called in the context
Rem      of catpatch.sql
Rem
Rem    NOTES
Rem      Must be run as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srtata      10/31/02 - srtata_bug-2625108
Rem    srtata      10/17/02 - Created
Rem

DECLARE
   sname varchar2(30);
   tname  varchar2(30);
   CURSOR table_pol IS
     SELECT DISTINCT schema_name, table_name
       FROM lbacsys.dba_sa_table_policies pt
       WHERE table_options LIKE '%READ_CONTROL%'
             AND table_options LIKE '%CHECK_CONTROL%'
             AND NOT EXISTS (SELECT * FROM sys.dba_policies p
                             WHERE pt.schema_name = p.object_owner
                                   AND pt.table_name = p.object_name
                                   AND p.policy_name = 'LBAC_RLSRCLC2');

   pol_row table_pol%ROWTYPE;

BEGIN

   FOR pol_row IN table_pol LOOP
      sname := pol_row.schema_name;
      tname := pol_row.table_name;
      SYS.DBMS_RLS.DROP_POLICY(sname, tname ,'LBAC_RLSRCLC');
      SYS.DBMS_RLS.ADD_POLICY(sname, tname, 'LBAC_RLSRCLC',
                              'LBACSYS', 'LBAC_RLS.READCHECK_FILTER',
                              'SELECT', TRUE);
      SYS.DBMS_RLS.ADD_POLICY(sname, tname, 'LBAC_RLSRCLC2',
                              'LBACSYS', 'LBAC_RLS.READCHECK_FILTER2',
                              'INSERT,UPDATE,DELETE', TRUE);
   END LOOP;

END;
/

