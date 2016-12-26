Rem
Rem $Header: rdbms/admin/dvdbmig.sql /main/10 2010/06/25 11:02:34 vigaur Exp $
Rem
Rem dvdbmig.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dvdbmig.sql - DV Database Migration script
Rem
Rem    DESCRIPTION
Rem      This performs upgrade of DV component from all prior
Rem    releases supported (for dv it starts in 10.2.0.2).
Rem    It first runs the "u" script to upgrade the tables and
Rem    types for DV and then runs the scripts to load in the new
Rem    PLSQL objects
Rem
Rem   Ugrading DV requires relinking of the executable among other steps
Rem   Please see documentation for more details.
Rem
Rem    NOTES
Rem       It is called from catdbmig.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vigaur      06/22/10 - Add dvpatch invocation
Rem    ruparame    12/18/08 - Bug 7657506
Rem    youyang     11/17/08 - remove alter ddl triggers
Rem    ssonawan    11/06/08 - bug 6938843: add sync_rules() 
Rem    vigaur      04/16/08 - Add 11.1->11.2 migrate script
Rem    ruparame    06/25/07 - Validate invalid objects during DB upgrade
Rem    mxu         04/26/07 - Fix bug 5935104
Rem    mxu         03/06/07 - Fix invalid objects
Rem    rburns      02/20/07 - fix substr compare
Rem    cdilling    01/25/07 - set session back to SYS
Rem    mxu         12/19/06 - Fix errors
Rem    rvissapr    12/01/06 - Migration script
Rem    rvissapr    12/01/06 - Created
Rem


WHENEVER SQLERROR EXIT;
GRANT EXECUTE ON dbms_registry to DVSYS;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Begin
 dbms_registry.upgrading(comp_id =>  'DV', 
                         new_name   =>  'Oracle Database Vault', 
                         new_proc   =>  'VALIDATE_DV');
End;
/


COLUMN :file_name NEW_VALUE comp_file NOPRINT
VARIABLE file_name VARCHAR2(12)

BEGIN
 IF substr(dbms_registry.version('DV'),1,6)='10.2.0' THEN
  :file_name := 'dvu102.sql';
 ELSIF substr(dbms_registry.version('DV'),1,6)='11.1.0' THEN
  :file_name := 'dvu111.sql';
 ELSE
  :file_name := 'nothing.sql';
 END IF;
END;
/

SELECT :file_name FROM DUAL;
@@&comp_file

--
-- Reload all the packages, functions and procedures from previous release
--
ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

@@dvmacfnc.plb

@@catmacp.sql

@@prvtmacp.plb

-- Execute dbms_macadm.sync_rules to sync the newy added
--  rules and rulesets 

exec dvsys.dbms_macadm.sync_rules ;

GRANT EXECUTE ON DVSYS.GET_FACTOR to DVF;

@@catmact.sql

DECLARE
    num number;
    cursor dv_dba_invalid_objects is
      select o.object_id from dba_objects o
       where status = 'INVALID'
         and owner IN ('DVSYS', 'DVF');
BEGIN
    dbms_registry.upgraded('DV');

    -- Validate all invalid objects during upgrade 
    FOR row IN dv_dba_invalid_objects LOOP
       dbms_utility.validate(row.object_id);
    END LOOP;
END;
/
commit;

--
-- Invoke dvpatch to ensure patch changes are also added
--
@@dvpatch.sql

ALTER SESSION SET CURRENT_SCHEMA = SYS;
