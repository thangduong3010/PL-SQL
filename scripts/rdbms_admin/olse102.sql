Rem
Rem $Header: olse102.sql 11-apr-2006.05:18:07 nmanappa Exp $
Rem
Rem olse102.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      olse102.sql - Downgrade OLS from 11g to 10.2
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nmanappa    04/11/06 - Created
Rem

EXECUTE DBMS_REGISTRY.DOWNGRADING('OLS');

EXECUTE DBMS_REGISTRY.DOWNGRADED('OLS', '10.2.0');

