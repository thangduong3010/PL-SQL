Rem
Rem $Header: rdbms/admin/dvpatch.sql /main/9 2010/06/25 11:02:34 vigaur Exp $
Rem
Rem dvpatch.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dvpatch.sql - Oracle Database Vault Patch Script
Rem
Rem    DESCRIPTION
Rem       This script is used to apply bugfixes to the DV component.It is run 
Rem      in the context of catpatch.sql, after the RDBMS catalog.sql and 
Rem      catproc.sql scripts are run. It is run with a special EVENT set which
Rem      causes CREATE OR REPLACE statements to only recompile objects if the 
Rem      new source is different than the source stored in the database.
Rem      Tables, types, and public interfaces should not be changed here.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vigaur      06/22/10 - Handle patch changes during release upgrade
Rem    vigaur      06/01/10 - Bug 6503742
Rem    jheng       04/05/10 - fix bug 9481210: insert DV datapump types in
Rem                           metaview$
Rem    vigaur      12/17/09 - Bug 8706788 - Remove WKSYS and WKUSER from ODD
Rem    jheng       12/01/09 - fix bug 9092184: insert into dvsys.code$
Rem    youyang     10/05/09 - bug8635726: add command rule for changing
Rem                           password
Rem    vigaur      11/21/08 - XbranchMerge vigaur_lrg-3392573 from
Rem                           st_rdbms_11.1.0
Rem    vigaur      01/09/08 - LRG 3205969 
Rem    mxu         01/26/07 - Fix errors
Rem    rvissapr    12/01/06 - DV patch
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
-- Moved changes from dvpatch to dvu112. When a new release
-- is created, we'll move this invocation into dvdbmig as needed.
-- Call the dvu112 script for changes specific to 112
--
@@dvu112.sql

--
-- Done Loading DV. Now Validate 
--

Begin
 dbms_registry.loaded( 'DV');
 sys.validate_dv;
End;
/
   
ALTER SESSION SET CURRENT_SCHEMA = SYS;

COMMIT;

