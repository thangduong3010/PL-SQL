Rem
Rem $Header: rulcpu.sql 06-apr-2005.17:53:05 ayalaman Exp $
Rem
Rem rulcpu.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rulcpu.sql - Rules manager critical patch update
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

EXECUTE dbms_registry.upgradeing(`RUL');

-- insert script invocations required to apply the CPU to the component

EXECUTE dbms_registry.upgraded(`RUL');

ALTER SESSION SET CURRENT_SCHEMA = SYS;

