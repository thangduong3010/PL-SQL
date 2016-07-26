Rem
Rem $Header: rdbms/admin/olsu111.sql /st_rdbms_11.2.0/3 2013/04/23 22:42:12 aramappa Exp $
Rem
Rem olsu111.sql
Rem
Rem Copyright (c) 2009, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      olsu111.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    aramappa    04/17/13 - Backport aramappa_bug-16593494 from MAIN
Rem    srtata      05/23/12 - bug 14033506: grant execute on dbms_sql to
Rem                           lbacsys
Rem    jkati       06/21/11 - grant execute on sys.dbms_zhelp to lbacsys
Rem    srtata      02/13/09 - script to upgrade from 11.1
Rem    srtata      02/13/09 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

GRANT EXECUTE ON SYS.DBMS_ZHELP TO LBACSYS;
GRANT EXECUTE ON SYS.DBMS_SQL TO LBACSYS;
DROP TRIGGER LBACSYS.LBAC$LOGON;

-- Bug# 16593494,16593502,16593597,16593628 grant only necessary
-- privileges on EXPDEPACT$
REVOKE ALL ON SYS.EXPPKGACT$ FROM LBACSYS;
REVOKE ALL ON SYS.EXPDEPACT$ FROM LBACSYS;
GRANT SELECT,INSERT,DELETE ON SYS.EXPDEPACT$ TO LBACSYS;
