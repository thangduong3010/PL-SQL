Rem
Rem $Header: rdbms/admin/xdbu9202.sql /st_rdbms_11.2.0/1 2012/03/02 13:15:08 stirmizi Exp $
Rem
Rem xdbu9202.sql
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbu9202.sql - XDB Upgrade from 9.2.0.2 to 10.0.0.
Rem
Rem    DESCRIPTION
Rem      Upgrades XDB from the 9.2.0.2 release to 10.0.0.
Rem
Rem    NOTES
Rem      None.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    stirmizi    03/01/12 - Backport stirmizi_bug-5233285 from main:
Rem                           fixing /sys/asm directory for 10.1.x
Rem                           to 10.2 upgrade
Rem    badeoti     03/19/09 - clean up 11.2 packages
Rem    mrafiq      06/29/07 - making it rerunnable
Rem    mrafiq      05/22/06 - making the revoke sql statement rerunnable 
Rem    vkapoor     02/08/05 - bug 4169607 
Rem    spannala    09/24/04 - remove exception blocks from upgrade and 
Rem                           downgrade scripts 
Rem    spannala    05/07/04 - prevent execution of xdbs9202 repetedly 
Rem    spannala    04/12/04 - revoke select any table from xdb 
Rem    thbaby      04/21/04 - add 10g upgrade 
Rem    rmurthy     01/17/04 - add asm folder 
Rem    spannala    12/29/03 - fix bug 3335998: create resource_oid_index 
Rem    alakshmi    11/06/03 - Fix XML LCR schema upgrade 
Rem    rmurthy     10/16/03 - temp fix for timefacet 
Rem    rmurthy     11/10/03 - fix table alias 
Rem    spannala    11/10/03 - bug#3237862 
Rem    rmurthy     10/16/03 - temp fix for timefacet 
Rem    rmurthy     09/16/03 - add oid virtual folder 
Rem    fge         08/06/03 - create index xdb.xdb_h_link_child_oid
Rem    spannala    08/25/03 - moving xdbptrl1 to the end of xdbs script.
Rem    spannala    08/22/03 - force removal of all schemas 
Rem    spannala    08/21/03 - moving lcr upgrade from xdbs9202 to xdbu9202 
Rem    spannala    08/21/03 - prvtxdb depends on dbmsxdbt 
Rem    spannala    06/24/03 - only load necessary pkgs before cleansga
Rem    spannala    06/16/03 - load xdbptrl1.sql so that new package defns are found
Rem    spannala    06/12/03 - call migrate correctly
Rem    spannala    06/12/03 - add call to revalidate all path index triggers
Rem    spannala    06/11/03 - adding call to cleansga
Rem    njalali     03/28/03 - dropping unneeded objects
Rem    njalali     02/11/03 - moving schema upgrades into xdbs9202.sql
Rem    nmontoya    02/14/03 - SET attributes TO null IN schema FOR schemas
Rem    njalali     01/23/03 - commenting out alter type temporarily
Rem    njalali     01/16/03 - add text type to schema for schemas
Rem    abagrawa    01/22/03 - Remove abstract, add final to simpletype
Rem    ataracha    12/02/02 - Add opqtype$ flag for out-of-line tables
Rem    abagrawa    12/16/02 - Alter xdb.xdb$facet_list_t to size 65535
Rem    spannala    12/19/02 - fixing bug#2702653
Rem    njalali     11/21/02 - njalali_migscripts_10i
Rem    njalali     11/18/02 - Created
Rem

update xdb.xdb$complex_type c set c.xmldata.attributes = null 
  where c.xmldata.name = 'annotation';

update xdb.xdb$attribute a
set a.xmldata.typename.name = 'dateTime'
where a.xmldata.prop_number = 2;

-- Can be repeated, does not need status
create or replace public synonym xdb$string_list_t for xdb.xdb$string_list_t;
grant execute on xdb.xdb$string_list_t to public with grant option;

--making this rerunnable
create or replace procedure revoke_privileges as
  priv_not_granted EXCEPTION;
  PRAGMA EXCEPTION_INIT(priv_not_granted, -1952);
begin
  execute immediate 'revoke select any table from xdb';
exception
  when priv_not_granted then
    NULL;
end;
/
show errors;

call revoke_privileges();

Rem Do the necessary bootstrap schema upgrades first
COLUMN :sch9202_name NEW_VALUE comp9202_file NOPRINT
VARIABLE sch9202_name VARCHAR2(50)

DECLARE
  a number;
BEGIN
  select n into a from xdb.migr9202status;
  if a < 750 then
    :sch9202_name  := '@xdbs9202.sql';
  else
    :sch9202_name := '@nothing.sql';
  end if;
end;
/
select :sch9202_name from dual;
@&comp9202_file;


Rem Drop unneeded 9.2.0 objects
drop package xdb.xdb$bootstrap;
drop package xdb.xdb$bootstrapres;
drop function xdb.xdb$insertcomplex;
drop procedure xdb.rootschemamigrate;
drop function xdb.xdb$insertChoice;

Rem create secondary index on xdb$h_link.child_oid
declare
  m integer;
begin
  select n into m from xdb.migr9202status for update;
  if m < 760 then
    update xdb.migr9202status set n = 760;
    execute immediate
      'create index xdb.xdb_h_link_child_oid on xdb.xdb$h_link(child_oid)';
  end if;
end;
/

Rem create resource oid index
declare
  m integer;
begin
  select n into m from xdb.migr9202status for update;
  if m < 800 then
    update xdb.migr9202status set n = 800;
    execute immediate
      'create unique index xdb.xdb$resource_oid_index on XDB.XDB$RESOURCE e' ||
  ' (sys_op_r2o(e.xmldata.xmlref))';
  end if;
end;
/

Rem Now clean up sga so that normal XDB operations to work
Rem This clean out the main XDB SGA structure
call xdb.dbms_xdbutil_int.CleanSGAForUpgrade();

Rem This cleans out the schemas out the schema cache
alter system flush shared_pool;

Rem Now we can call normal XDB operations like creation of folders
Rem First create the /sys/apps folder
Rem repeatable, does not use status
DECLARE
  retval BOOLEAN := FALSE;
  ct     NUMBER;
BEGIN

  if (NOT DBMS_XDB.existsResource('/sys/apps')) then
    retval := DBMS_XDB.CREATEFOLDER('/sys/apps');
  end if;

  IF retval THEN
   DBMS_XDB.SETACL('/sys/apps', '/sys/acls/bootstrap_acl.xml');
  END IF;
END;
/
commit;

Rem Create OID virtual folder
Rem This step is repeatable.
declare
ret boolean;
begin
  ret := xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/oid');
  if ret then
    dbms_xdb.setacl('/sys/oid', '/sys/acls/bootstrap_acl.xml');
  end if;
exception
  when others then
    ret := FALSE;
end;
/
commit;

Rem Now migrate all tables to the new version of the path index trigger
Rem This operation is repeatable, though expensive
call xdb.dbms_xdbz0.migrate_pitrig();

Rem enable hierarchy on the xdb$config table, if not already enabled.
Rem Repeatable, does not use status.
begin
  IF NOT xdb.dbms_xdbz0.is_hierarchy_enabled_trig('XDB', 'XDB$CONFIG') THEN
    dbms_xdbz.enable_hierarchy('XDB', 'XDB$CONFIG');
  END IF;
end;
/


/* Upgrade LCR schema. This is strictly not a XDB bootstrap schema but
 * since we supply it in most cases, let's upgrade it.
 * The changes are as follows:
 *
 *  A new global complexType has been added.
 *
 *      <complexType name="extra_attribute">
 *        <sequence>
 *         <element name = "attribute_name" type = "lcr:short_name"/>
 *         <element name = "attribute_value" type = "lcr:anydata"/>
 *        </sequence>
 *      </complexType>
 *
 *  The element "extra_attribute_values" has been added to element "ROW_LCR"
 *
 *  The element "extra_attribute_values" has been added to element "DDL_LCR"
 *
 *   A new element "long_information" has been added to
 *    complexType "column_value"
 */

-- This function returns true if the upgrade is necessary, false otherwise.
create or replace function lcr_extval_needupg(schema_url IN VARCHAR2)
  return boolean as
  m integer;
begin
  select count(*) into m from xdb.xdb$element e, xdb.xdb$schema s where
   s.xmldata.schema_url = schema_url
   and ref(s) = e.xmldata.property.parent_schema
   and e.xmldata.property.name = 'extra_attribute_values';
 
  if m > 0 then
    return FALSE;
  else 
    return TRUE;
  end if;
end;
/


Rem Load catxlcr1.sql
@@catxlcr1.sql

create or replace procedure upgrade_lcr as
  lcr_schema_url  varchar2(60);
  cnt             integer;
begin

  lcr_schema_url := lcr$_xml_schema.CONFIGURL;
  select count(*) into cnt from xdb.xdb$schema s
  where s.xmldata.schema_url = lcr_schema_url;

  if cnt > 0 and lcr_extval_needupg(lcr_schema_url) then

    -- Drop the existing schema. This is going to fail if there are
    -- dependent tables/schemas in which case users have to upgrade using
    -- CopyEvolve.
    dbms_xmlschema.DeleteSchema(lcr$_xml_schema.CONFIGURL,
                                dbms_xmlschema.DELETE_RESTRICT);

    -- Register new schema
    dbms_xmlschema.registerSchema(schemaURL => lcr$_xml_schema.CONFIGURL, 
                                  schemaDoc => lcr$_xml_schema.CONFIGXSD_10101,
                                  local => FALSE,
                                  genTypes => TRUE,
                                  genBean => FALSE,
                                  genTables => FALSE,
                                  force => FALSE);


  end if;
end;
/

call upgrade_lcr();
-- drop the upgrade procedures
drop function lcr_extval_needupg;
drop procedure upgrade_lcr;

-- Call 10.1 Upgrade
@@xdbu101.sql
