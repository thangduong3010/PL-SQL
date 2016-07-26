Rem
Rem $Header: rule111.sql 19-mar-2008.06:24:28 ayalaman Exp $
Rem
Rem rule111.sql
Rem
Rem Copyright (c) 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rule111.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    03/19/08 - downgrade status
Rem    ayalaman    02/25/08 - downgrade to 11.1
Rem    ayalaman    02/25/08 - Created
Rem

REM
REM Downgrade of RUL from 11.2 to 11.1
REM
EXECUTE dbms_registry.downgrading('RUL');

-- Nothing to do

REM
REM Call the downgrade script for next version (none)
REM


EXECUTE dbms_registry.downgraded('RUL','11.1.0'); 

