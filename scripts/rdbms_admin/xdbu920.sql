Rem
Rem $Header: rdbms/admin/xdbu920.sql /main/12 2009/04/06 20:28:12 badeoti Exp $
Rem
Rem xdbu920.sql
Rem
Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbu920.sql - XDB Upgrade from 9.2.0.1 to 9.2.0.2.
Rem
Rem    DESCRIPTION
Rem      Upgrades XML DB from the 9.2.0.1 release to 9.2.0.2.
Rem
Rem    NOTES
Rem      This file was xdbpatch.sql in the 9.2.0.2 release.  It 
Rem      performs extensive data changes to schema-based XMLType tables,
Rem      such as reformatting positional desciptors and extras columns,
Rem      and making modifications to built-in XML schemas.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     03/19/09 - Migrate*From9201 procs moved
Rem    spannala    09/24/04 - remove exception blocks from upgrade and 
Rem                           downgrade scripts 
Rem    spannala    05/09/04 - prevent repeat execution of xdbs920.sql 
Rem    spannala    08/26/03 - move LCR upgrade to use copy evolve 
Rem    spannala    08/24/03 - xdbptrl1.sql will be called by xdbs at the right 
Rem    spannala    06/24/03 - remove enable_hierarchy
Rem    spannala    06/10/03 - call disable hierachy on the config table
Rem    spannala    06/09/03 - dont call xdbptrl2.sql before 9202 upgd
Rem    njalali     03/28/03 - compiling invalid stuff after upgrade in xdbrelod
Rem    njalali     03/27/03 - adding prvtxsch.plb
Rem    nmontoya    02/27/03 - bug# 2818136: update contype via xdb$resource
Rem    njalali     02/11/03 - cleaning up schema upgrade
Rem    nmontoya    02/14/03 - SET attributes TO null IN schema FOR schemas
Rem    nmontoya    02/14/03 - drop public synonym XMLConcat 
Rem    nmontoya    02/11/03 - move xdb$patchupdeleteschema compile TO xdbrelod
Rem    nmontoya    02/11/03 - GRANT ALL privileges ON xdb$config TO xdbadmin
Rem    nmontoya    02/11/03 - SET NEW DEFAULT contentype TO 9201 folders 
Rem    njalali     01/23/03 - schema changes for 10i
Rem    njalali     11/21/02 - njalali_migscripts_10i
Rem    njalali     11/14/02 - copied from 9.2.0.2's xdbpatch.sql
Rem


-- Some implementations have these operators defined, and some don't.
-- Regardless, they are unused in 9.2.0.2 and should be dropped.
drop indextype xdb.path_index;
drop operator xdb.xdbpi_noop;

-- Create the table that keeps track of how far along we are in the migration
begin
  execute immediate 'select count(*) from xdb.migr9202status';
exception
  when others then
    execute immediate 'create table xdb.migr9202status (n integer)';
    execute immediate 'insert into xdb.migr9202status values (1)';
    commit;
end;
/

-- First upgrade the schemas, if necessary
COLUMN :sch920_name NEW_VALUE comp920_file NOPRINT
VARIABLE sch920_name VARCHAR2(50)

DECLARE
  a number;
BEGIN
  select n into a from xdb.migr9202status;
  if a < 400 then
    :sch920_name  := '@xdbs920.sql';
  else
    :sch920_name := '@nothing.sql';
  end if;
end;
/


Rem Upgrade the default schemas
select :sch920_name from dual;
@&comp920_file;

update xdb.xdb$complex_type c set c.xmldata.attributes = null 
  where c.xmldata.name = 'annotation';

Rem Reload the schema registration/compilation module
@@prvtxsch.plb

-- Patch positional descriptors.  This operation is repeatable.

declare
 a   xdb.xdb$raw_list_t;
begin 
-- In 9.2.0.1 installations, there is a null PD for the 'charset-mappings'
-- varray of the xdb.xdb$config table.  
-- Since in 9.2.0.2 databases that PD is non-null, we want to patch it,
-- but we must do so after migrating other PDs, because if 
-- the migration code sees even one 9.2.0.2 PD, it will abort migration of
-- that row.  
-- As an aside, it is possible for the the migration driver to throw an
-- error--such as being out of shared memory--that causes us to go on and
-- patch the XDB.XDB$CONFIG row before it is migrated. 
-- For that reason, we revert that
-- row to its 9.2.0.1 status before calling the PD migration driver.

-- Revert the XDB.XDB$CONFIG PD to its 9.2.0.1 form if the user never 
-- changed it (i.e. if it was NULL before the first attempt at migration).
  select e.xmldata."sysconfig"."protocolconfig"."common".
    "extension-mappings"."charset-mappings".sys_xdbpd$ into a
     from xdb.xdb$config e;
   if ((a is not null) AND (a.last = 1) AND (a(1) = '13000000')) then
  dbms_xdbz.disable_hierarchy('XDB', 'XDB$CONFIG');
     update xdb.xdb$config e set 
       e.xmldata."sysconfig"."protocolconfig"."common".
       "extension-mappings"."charset-mappings".sys_xdbpd$ = null;
   end if;

-- Migrate all PDs
  xdb.dbms_xdbutil_int.migrateallxmlfrom9201();

-- Patch the null XDB.XDB$CONFIG PD to look like its 9.2.0.2 counterpart.
  dbms_xdbz.disable_hierarchy('XDB', 'XDB$CONFIG');
  update xdb.xdb$config e set 
     e.xmldata."sysconfig"."protocolconfig"."common".
     "extension-mappings"."charset-mappings".sys_xdbpd$
        = xdb.XDB$RAW_LIST_T('13000000') where 
           e.xmldata."sysconfig"."protocolconfig"."common".
           "extension-mappings"."charset-mappings".sys_xdbpd$ is null;
  commit;
end;
/

grant all on xdb.xdb$config to xdbadmin;

update xdb.xdb$resource r 
  set r.xmldata.contype = 'application/octet-stream'
  where r.xmldata.contype = 'text/plain' AND
  (r.xmldata.dispname = 'log' or
   r.xmldata.dispname = 'xdb' or
   r.xmldata.dispname = 'xmlns.oracle.com' or
   r.xmldata.dispname = 'PUBLIC' or
   r.xmldata.dispname = 'schemas' or
   r.xmldata.dispname = 'sys' or
   r.xmldata.dispname = '2001' or
   r.xmldata.dispname = 'www.w3.org' or
   r.xmldata.dispname = 'acls' or
   r.xmldata.dispname = 'public');

drop public synonym XMLConcat;

Rem Lastly, invoke the upgrade script from 9.2.0.2 to 10.0.0.
@@xdbu9202.sql
