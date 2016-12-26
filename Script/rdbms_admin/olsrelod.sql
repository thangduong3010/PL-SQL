Rem
Rem $Header: olsrelod.sql 13-oct-2004.12:08:20 cchui Exp $
Rem
Rem olsrelod.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      olsrelod.sql - Oracle Label Security RELOaD script.
Rem
Rem    DESCRIPTION
Rem      This script is used to reload OLS packages after a downgrade. 
Rem      The dictionary objects are reset to the old release by the "e" script,
Rem      this reload script processes the "old" scripts to reload the 
Rem      "old" version of the component using the "old" server.
Rem
Rem    NOTES
Rem      Called from catrelod.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cchui       10/13/04 - 3936531: use validate_ols 
Rem    srtata      03/31/04 - check if OID enabled OLS 
Rem    vpesati     11/25/02 - add server instance check
Rem    srtata      10/18/02 - srtata_bug-2625076
Rem    srtata      10/16/02 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

-- add OLS to the registry
EXECUTE DBMS_REGISTRY.LOADING('OLS', 'Oracle Label Security', 'validate_ols','LBACSYS');

COLUMN :file_name1 NEW_VALUE comp_file1 NOPRINT
VARIABLE file_name1 VARCHAR2(12)

COLUMN :file_name2 NEW_VALUE comp_file2 NOPRINT
VARIABLE file_name2 VARCHAR2(12)

DECLARE
oid_status NUMBER;

BEGIN
  SELECT COUNT(*) INTO oid_status FROM lbacsys.lbac$props
                  WHERE name='OID_STATUS_FLAG' AND value$=1;
  IF oid_status = 1 THEN
    :file_name1 := 'prvtlbd.plb';
    :file_name2 := 'prvtsad.plb';
  ELSE
    :file_name1 := 'nothing.sql';
    :file_name2 := 'nothing.sql';
  END IF;
END;
/

-- Load LBAC framework packages.
@@catlbac

-- Load SA policy packages.
@@catsa
@@catlabel

-- Install logon trigger to be used with OID
SELECT :file_name1 FROM DUAL;
@@&comp_file1

-- Replace all_sa views to be used with OID 
SELECT :file_name2 FROM DUAL;
@@&comp_file2

BEGIN
  dbms_registry.loaded('OLS', dbms_registry.release_version,
            'Oracle Label Security Release ' ||
            dbms_registry.release_version    ||
            ' - ' || dbms_registry.release_status);
  SYS.validate_ols;
END;
/
commit;

