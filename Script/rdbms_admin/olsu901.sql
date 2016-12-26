Rem
Rem $Header: olsu901.sql 27-jun-2003.16:11:44 srtata Exp $
Rem
Rem olsu901.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      olsu901.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This is the upgrade script for OLS from 9.0.1 to 9.2.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA.
Rem
Rem      Immediately after this script you must run $ORACLE_HOME/admin/utlrp
Rem      as SYSDBA to validate invalid OLS objects. Then you must shutdown
Rem      and restart the database instance. 
Rem
Rem      Do not shutdown and restart the instance before running utlrp.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srtata      06/27/03 - drop lbacrls_libt
Rem    srtata      10/24/02 - move scripts that reload packages to olsdbmig.sql
Rem    shwong      01/14/02 - grant execute on dbms_registry to lbacsys.
Rem    rburns      10/31/01 - add dbms_registry call
Rem    shwong      10/26/01 - Merged shwong_upgdng
Rem    shwong      10/26/01 - Created
Rem

DROP LIBRARY LBACSYS.LBAC$RLS_LIBT;

-- Call 92 upgrade script

@@olsu920.sql

