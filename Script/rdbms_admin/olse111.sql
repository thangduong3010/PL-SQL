Rem
Rem $Header: rdbms/admin/olse111.sql /st_rdbms_11.2.0/1 2011/06/24 13:29:44 jkati Exp $
Rem
Rem olse111.sql
Rem
Rem Copyright (c) 2008, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      olse111.sql - Downgrade OLS from 11.2 to 11.1
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jkati       06/22/11 - revoke execute on sys.dbms_zhelp to lbacsys
Rem    srtata      03/08/09 - logon trigger removal: add init_ols_session
Rem    srtata      10/05/08 - downgrade from 11.2 to 11.1
Rem    srtata      10/05/08 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

EXECUTE DBMS_REGISTRY.DOWNGRADING('OLS');

DROP PROCEDURE LBACSYS.init_ols_session;

REVOKE EXECUTE ON SYS.DBMS_ZHELP FROM LBACSYS;

EXECUTE DBMS_REGISTRY.DOWNGRADED('OLS', '11.1.0');


