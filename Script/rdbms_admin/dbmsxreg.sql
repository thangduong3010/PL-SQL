Rem
Rem $Header: rdbms/admin/dbmsxreg.sql /main/3 2008/10/16 13:07:48 badeoti Exp $
Rem
Rem dbmsxreg.sql
Rem
Rem Copyright (c) 2002, 2008, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      dbmsxreg.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Package definiton of the registry package.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     04/08/08 - add object validation
Rem    pnath       10/25/04 - Make SYS the owner of DBMS_REGXDB package 
Rem    spannala    01/09/02 - Merged spannala_upg
Rem    spannala    01/03/02 - Created
Rem

create or replace package sys.DBMS_REGXDB authid current_user as
  procedure validatexdb;
  procedure validatexdb_objs;
end dbms_regxdb;
/


