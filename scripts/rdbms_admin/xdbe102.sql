Rem
Rem $Header: rdbms/admin/xdbe102.sql /st_rdbms_11.2.0/1 2012/12/28 10:05:22 apfwkr Exp $
Rem
Rem xdbe102.sql
Rem
Rem Copyright (c) 2004, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbe102.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      12/27/12 - Backport mkandarp_bug-13683089 from main
Rem    rburns      11/05/07 - more downgrade for 11.1.0
Rem    rburns      08/22/07 - add 11g XDB up/down scripts
Rem    pthornto    10/09/06 - add call to zxse102.sql for XS downgrade
Rem    smalde      05/15/06 - 
Rem    abagrawa    03/14/06 - Add xdbuud2 
Rem    sidicula    06/29/05 - sidicula_le
Rem    fge         12/15/04 - Created
Rem

Rem ================================================================
Rem BEGIN XS downgrade to 10.2.0
Rem ================================================================

@@xse102.sql

Rem ================================================================
Rem END XS downgrade to 10.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB downgrade to 10.2.0
Rem ================================================================

-- Load utilities. Call xdbuuc4 because element_t has two extra
-- translation attrs.
@@xdbuuc4.sql

-- Set status correctly, use the same trick as upgrade to set
-- status here.
-- Note that this means that none of the xdbes* scripts should use status.
BEGIN
  IF dbms_registry.status('XDB') = 'VALID' THEN
    -- This will get commited along with the 'downgrading' call below
    update xdb.migr9202status set n = 1000;
  END IF;
END;
/

-- Set the status to downgrading.
EXECUTE DBMS_REGISTRY.DOWNGRADING('XDB');

update resource_view r set r.res = deletexml(r.res, '/r:Resource//r:Contents//c:nfsconfig','xmlns:r="http://xmlns.oracle.com/xdb/XDBResource.xsd" xmlns:c="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') where equals_path(r.res,'/xdbconfig.xml')=1;
commit;

-- call common downgrade
@@xdbeall.sql

-- Downgrade XDB User data
@@xdbeu102.sql

-- Downgrade XDB Schemas
@@xdbes102.sql

-- Downgrade XDB Objects
@@xdbeo102.sql

select n from xdb.migr9202status;

-- downgrade the config schema
@@xdbuud.sql
@@xdbuud2.sql

EXECUTE dbms_registry.downgraded('XDB','10.2.0');

Rem ================================================================
Rem END XDB downgrade to 10.2.0
Rem ================================================================

