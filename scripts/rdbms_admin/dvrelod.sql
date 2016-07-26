Rem
Rem $Header: rdbms/admin/dvrelod.sql /st_rdbms_11.2.0/1 2012/04/30 11:22:19 sanbhara Exp $
Rem
Rem dvrelod.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dvrelod.sql - Oracle Database Vault Reload Script
Rem
Rem    DESCRIPTION
Rem      This script is used to reload DV packages after a downgrade.
Rem    The dictionary objects are reset to the old release by the "e" script,
Rem    this reload script processes the "old" scripts to reload the "old"
Rem    version of the component using the "old" server.
Rem
Rem    NOTES
Rem     Called from Catrelod.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sanbhara    02/29/12 - Removing call to catmacd.sql since the DV
Rem                           metadata has been downgraded already through the
Rem                           dvexxx scripts so there is no need to reload the
Rem                           data using catmacd.sql.
Rem    ruparame    12/18/08 - Bug 7657506
Rem    ssonawan    12/02/08 - lrg 3706796: move sync_rules from dve111.sql
Rem    jheng       10/17/08 - invoking catmacd.sql for bug 7449805
Rem    mxu         01/26/07 - Fix error
Rem    rvissapr    12/01/06 - Database Vault Reload Script
Rem    rvissapr    12/01/06 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

--
-- Add Database Vault to the registry
--

Begin
 DBMS_REGISTRY.LOADING(comp_id     =>  'DV', 
                       comp_name   =>  'Oracle Database Vault', 
                       comp_proc   =>  'VALIDATE_DV', 
                       comp_schema =>  'DVSYS',
                       comp_schemas =>  dbms_registry.schema_list_t('DVF'));
End;
/


--
-- Reload all the packages, functions and procedures from previous release
--


ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

@@dvmacfnc.plb

@@catmacp.sql

@@prvtmacp.plb

@@catmact.sql

--
-- Done Loading DV. Now Validate 
--

-- Execute dbms_macadm.sync_rules after downgrade
-- This is required because the ALTER SYSTEM rule set has been changed
exec dvsys.dbms_macadm.sync_rules;


Begin
 dbms_registry.loaded('DV');
                      
 sys.validate_dv;
End;
/
   
ALTER SESSION SET CURRENT_SCHEMA = SYS;

COMMIT;
