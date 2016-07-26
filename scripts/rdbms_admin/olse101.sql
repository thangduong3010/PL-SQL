Rem
Rem $Header: olse101.sql 04-may-2006.13:52:38 fjlee Exp $
Rem
Rem olse101.sql
Rem
Rem Copyright (c) 2004, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      olse101.sql - downgrade from 10.2 to 10.1
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    fjlee       05/04/06 - 
Rem    cchui       10/11/04 - 3936531: Drop validate_ols procedure 
Rem    cchui       06/22/04 - revoke privileges 
Rem    cchui       05/13/04 - Downgrade for RAC enable OLS 
Rem    srtata      03/26/04 - srtata_bug-3440113 
Rem    srtata      02/12/04 - Created
Rem

EXECUTE DBMS_REGISTRY.DOWNGRADING('OLS');

DROP FUNCTION LBACSYS.OID_ENABLED;

DROP PROCEDURE LBACSYS.sessinfo_cleanup;

DROP PROCEDURE SYS.validate_ols;

DROP PROCEDURE LBACSYS.ols_init_session;

TRUNCATE TABLE LBACSYS.sessinfo;

REVOKE SELECT ON GV_$INSTANCE FROM LBACSYS;
REVOKE SELECT ON V_$INSTANCE FROM LBACSYS;
REVOKE SELECT ON GV_$SESSION FROM LBACSYS;

EXECUTE DBMS_REGISTRY.DOWNGRADED('OLS', '10.1.0');

