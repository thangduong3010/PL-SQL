Rem
Rem $Header: exfcpu.sql 06-apr-2005.17:53:05 ayalaman Exp $
Rem
Rem exfcpu.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      exfcpu.sql - Expression filter critical patch update
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      See Documentation.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    04/06/05 - ayalaman_bug-4285078
Rem    ayalaman    04/06/05 - Created
Rem

ALTER SESSION SET CURRENT_SCHEMA = EXFSYS;

EXECUTE dbms_registry.upgradeing(`EXF');

-- insert script invocations required to apply the CPU to the component

EXECUTE dbms_registry.upgraded(`EXF');

ALTER SESSION SET CURRENT_SCHEMA = SYS;

