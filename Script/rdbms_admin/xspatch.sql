Rem
Rem $Header: rdbms/admin/xspatch.sql /main/1 2010/06/25 21:39:33 yiru Exp $
Rem
Rem xspatch.sql
Rem
Rem Copyright (c) 2010, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      xspatch.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yiru        06/17/10 - Created
Rem

-- fix for lrg 4720543
-- Remove PREDICATE index
begin
  execute immediate 'drop index xdb.prin_xidx';
exception
  when others then
  NULL;
end;
/

begin
  execute immediate 'drop index xdb.sc_xidx';
exception
  when others then
  NULL;
end;
/

