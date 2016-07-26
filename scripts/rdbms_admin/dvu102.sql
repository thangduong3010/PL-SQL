Rem
Rem $Header: rdbms/admin/dvu102.sql /main/7 2008/08/10 22:13:20 pknaggs Exp $
Rem
Rem dvu102.sql
Rem
Rem Copyright (c) 2006, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      dvu102.sql - DV Upgrade Script from 10.2.0.3 to 11g
Rem
Rem    DESCRIPTION
Rem      Upgrade Database Vault in Oracle 10.2.0.3 tp 11g
Rem
Rem    NOTES
Rem      Must be Run as SYSDBA with the Oracle executable relink with DV 
Rem    Turned Off.
Rem
Rem    *** PLEASE SEE The document for the exact steps for DV upgrade/downgrade*****
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pknaggs     08/06/08 - DBMS_REGISTRY must only be done from dvdbmig.sql
Rem    vigaur      05/22/08 - LRG 3408867
Rem    vigaur      04/16/08 - Call 11.1->11.2 migrate script
Rem    jibyun      09/05/07 - Bug 6068504: add a library for rule set row cache
Rem    ifitzger    03/09/07 - bug fix 5924617: clean up DV-related VPD policies
Rem                           during upgrade
Rem    mxu         03/07/07 - Drop invalid objects
Rem    rvissapr    12/04/06 - Create ugrade script for DV from 10.2.0.3 to 11g
Rem    rvissapr    12/04/06 - Created
Rem

Rem Put Upgrade metadata changes here. Please SET  the current schema correctly
Rem Before putting in any SQL commands.

ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

DROP FUNCTION DVSYS.REALM_SDML_AUTHORIZED;
DROP PROCEDURE DVSYS.SYNCHRONIZE_POLICY_FOR_OBJECT;

Rem End of DV Component Upgrade

ALTER SESSION SET CURRENT_SCHEMA = SYS;

DECLARE
   CURSOR stmt IS
     select u.name, o.name, r.pname
            from user$ u, obj$ o, rls$ r
            where u.user# = o.owner#
            and r.obj# = o.obj#
            and bitand(r.stmt_type,65536) > 0; 
   object_schema VARCHAR2(32) := NULL;
   object_name VARCHAR2(32) := NULL;
   policy_name VARCHAR2(32) := NULL;

BEGIN
  OPEN stmt;
  LOOP
    FETCH stmt INTO object_schema, object_name, policy_name;
    EXIT WHEN stmt%NOTFOUND;
    dbms_rls.drop_policy('"'||object_schema||'"',
                         '"'||object_name||'"',
                         '"'||policy_name||'"');
  END LOOP;
  Close stmt;
END;
/

CREATE OR REPLACE LIBRARY DVSYS.KZV$RSRC_LIBT TRUSTED AS STATIC
/

@@dvu111.sql
