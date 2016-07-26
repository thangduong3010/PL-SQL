Rem
Rem $Header: rdbms/admin/olspatch.sql /st_rdbms_11.2.0/2 2013/04/23 22:42:12 aramappa Exp $
Rem
Rem olspatch.sql
Rem
Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olspatch.sql - Oracle Label Security patch script
Rem
Rem    DESCRIPTION
Rem      This script is used to apply bugfixes to the OLS component.It is run 
Rem      in the context of catpatch.sql, after the RDBMS catalog.sql and 
Rem      catproc.sql scripts are run. It is run with a special EVENT set which
Rem      causes CREATE OR REPLACE statements to only recompile objects if the 
Rem      new source is different than the source stored in the database.
Rem      Tables, types, and public interfaces should not be changed here.
Rem
Rem    NOTES
Rem      Called from catpatch.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aramappa    04/18/13 - Backport aramappa_bug-16593494 from MAIN
Rem    jkati       06/21/11 - grant execute on dbms_zhelp to lbacsys
Rem    mjgreave    05/05/08 - Add support for OID enabled OLS.
Rem    srtata      02/26/08 - remove olsdap.sql as now it is 11.1.0 version and
Rem                           this script was intending to patch 92 DB
Rem    cchui       10/08/04 - 3936531: use validate_ols 
Rem    vpesati     11/25/02 - add server instance check
Rem    srtata      10/17/02 - call olsdap.sql
Rem    srtata      07/22/02 - srtata_bug-2434758_main
Rem    srtata      06/26/02 - Created
Rem

WHENEVER SQLERROR EXIT;
GRANT EXECUTE ON SYS.DBMS_ZHELP TO LBACSYS;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

-- add OLS to the registry
EXECUTE DBMS_REGISTRY.LOADING('OLS', 'Oracle Label Security', 'validate_ols', 'LBACSYS');


--  Check if we need to run OID specific scripts later
COLUMN prvtlbd NEW_VALUE prvtlbd_script NOPRINT;
COLUMN prvtsad NEW_VALUE prvtsad_script NOPRINT;

select
  decode(count(*), 1, 'prvtlbd.plb', 'nothing.sql') as prvtlbd,
  decode(count(*), 1, 'prvtsad.plb', 'nothing.sql') as prvtsad
  from lbacsys.lbac$props where name = 'OID_STATUS_FLAG'and value$ = 1;

-- Bug# 16593494,16593502,16593597,16593628 grant only necessary
-- privileges on EXPDEPACT$
REVOKE ALL ON SYS.EXPPKGACT$ FROM LBACSYS;
REVOKE ALL ON SYS.EXPDEPACT$ FROM LBACSYS;
GRANT SELECT,INSERT,DELETE ON SYS.EXPDEPACT$ TO LBACSYS;

-- Load LBAC framework packages.
@@catlbac

-- Load SA policy packages.
@@catsa
@@catlabel

-- Run OID specific scripts - these may be null scripts if not OID enabled
@@&prvtlbd_script
@@&prvtsad_script

BEGIN
  dbms_registry.loaded('OLS');
  SYS.validate_ols;
END;
/
commit;

