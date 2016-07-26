Rem
Rem $Header: rdbms/admin/xdb1m102.sql /st_rdbms_11.2.0/3 2012/12/11 10:21:48 apfwkr Exp $
Rem
Rem xdb1m102.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdb1m102.sql - XML Database migrate from 10.2 
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      11/29/12 - Backport ckavoor_bug-13326101 from main
Rem    bhammers    03/07/12 - Backport bhammers_bug-12601205 from
Rem                           st_rdbms_11.2.0
Rem    spetride    01/11/11 - Backport badeoti_bug-10096889 from main
Rem    badeoti     07/23/09 - drop utility functions
Rem    rburns      11/11/07 - XbranchMerge rburns_bug-6446262 from
Rem                           st_rdbms_project-18813
Rem    rburns      11/08/07 - add select of INVALID old versions of types
Rem    mrafiq      01/08/07 - pass flag to register_dav_schema
Rem    abagrawa    11/20/06 - remove bootacl default insert
Rem    spetride    08/06/06 - enabled validation
Rem    mrafiq      04/07/06 - cleaning up 
Rem    bkhaladk    04/25/06 - add translations schemas 
Rem    abagrawa    03/28/06 - Use xdbuuc3 
Rem    abagrawa    03/26/06 - Pass in fixit function name to migratetable 
Rem    abagrawa    03/20/06 - Remove set echo on
Rem    abagrawa    03/17/06 - Handle 4043 
Rem    abagrawa    03/16/06 - Upgrade when xdb is partially available
Rem    abagrawa    03/16/06 - Created
Rem


-- This script runs in a state when XDB can be partially initialized
-- i.e. the resource schema and schema for schemas are available but 
-- the ACL and config schemas are not
-- It is invoked during upgrade at the end of schema upgrade, but before
-- full data upgrade
-- During downgrade we do the reverse i.e. downgrade data, then have a 
-- counterpart of this script that runs when XDB is partially available
-- and finally run downgrade for schema that does not need XDB at all

Rem Create dbms_metadata_hack
@@catxdbh

Rem Create migrate table procedure
@@xdbuuc2

create table xdb.xdb$xdb_ready (data clob);

exec dbms_metadata_hack.cre_dir;

delete from xdb.xdb$xdb_ready;
commit;

-- Make xdb$acl_t valid before continuing
-- If schema is in CSX, then the type may not exist
declare
  err_num NUMBER;
begin
  execute immediate 'alter type xdb.xdb$acl_t compile';
  EXCEPTION WHEN OTHERS THEN
    BEGIN
      err_num := SQLCODE;
      IF err_num != -4043 THEN
        RAISE;
      END IF;
    END;
end;
/

desc xdb.xdb$acl;

-- Delete dav schema as it depends on ACL schema
declare
  delete_option number := xdb.dbms_xmlschema.delete_cascade_force +
                          xdb.dbms_xmlschema.delete_migrate;
  davurl varchar2(100) := 'http://xmlns.oracle.com/xdb/dav.xsd';
begin
  delete_schema_if_exists(davurl, delete_option);
end;
/

-- Bug 6446262
-- List any old versions of types that are invalid
SELECT name, subname, owner#, status FROM obj$ 
       WHERE type#=13 AND subname IS NOT NULL AND status > 1;

-- Register the CSX xml.xsd
declare
  XMLNSXSD BFILE := dbms_metadata_hack.get_bfile('xmlcsx.xsd.11.0');
  XMLNSURL VARCHAR2(2000) := 'http://www.w3.org/2001/csx.xml.xsd';  
  c  number;
begin
  select count(*) into c from xdb.xdb$schema s 
   where s.xmldata.schema_url = XMLNSURL;

  if c > 0 then
    return;
  end if;
  xdb.dbms_xmlschema.registerSchema(XMLNSURL, XMLNSXSD, FALSE, FALSE, FALSE, 
		                    TRUE, FALSE, 'XDB', 
                                    options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);end;
/

declare
  TRXSD BFILE := dbms_metadata_hack.get_bfile('xmltr.xsd.11.0');
  TRURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/csx.xmltr.xsd';  
  c  number;
begin
  select count(*) into c from xdb.xdb$schema s 
   where s.xmldata.schema_url = TRURL;

  if c > 0 then
    return;
  end if;
  xdb.dbms_xmlschema.registerSchema(TRURL, TRXSD, FALSE, FALSE, FALSE, TRUE,
                                    FALSE, 'XDB', 
				    options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end;
/

-- create directory for picking up xml doc with default config
exec dbms_metadata_hack.cre_xml_dir;

-- the ACL index should not exist, but for the record we list the status
-- based on dba_indexes; in the event downgrade in run from an upgraded
-- database where ACL migration went wrong, we make sure this ACL migration
-- is done after cleaning a bad ACL index
select index_name, status from dba_indexes where table_name='XDB$ACL' and owner='XDB';

begin
  execute immediate 'drop index xdb.xdb$acl_xidx force';
  commit;
  exception
     when OTHERS then
        if (SQLCODE = - 1418) then
          NULL;
        end if;
end;
/
select index_name, status from dba_indexes where table_name='XDB$ACL' and owner='XDB';

set serveroutput on size unlimited
exec dbms_output.enable(null); 

declare
  aclxsd xmltype := xmltype(dbms_metadata_hack.get_bfile('acl.xsd.11.0'), 0);
begin
xdb$migratexmltable(xsd => aclxsd,
nmspc => 'http://xmlns.oracle.com/xdb/acl.xsd',
url => 'http://xmlns.oracle.com/xdb/acl.xsd',
tabname => 'XDB$ACL',
schemaowner => 'XDB', root => 'acl', 
absdir => '/sys/schemas/PUBLIC/xmlns.oracle.com/xdb',
absfile => 'acl.xsd',
csx => true, transformfn => 'xdb.dbms_xdbutil_int.fixacl',
need_2nd_fn => 1);
end;
/


declare
  configxsd xmltype := 
    xmltype(dbms_metadata_hack.get_bfile('xdbconfig.xsd.11.0'), 0);
begin
xdb$migratexmltable(xsd => configxsd,
nmspc => 'http://xmlns.oracle.com/xdb/xdbconfig.xsd',
url => 'http://xmlns.oracle.com/xdb/xdbconfig.xsd',
tabname => 'XDB$CONFIG',
schemaowner => 'XDB', root => 'xdbconfig', 
absdir => '/sys/schemas/PUBLIC/xmlns.oracle.com/xdb',
absfile => 'xdbconfig.xsd', csx=>true, 
defaultdoc => 'xdbconfig.xml.11.0');
end;
/

create or replace trigger xdb.xdbconfig_validate before insert or update
on xdb.XDB$CONFIG for each row
declare
  xdoc xmltype;  
begin
  xdoc := :new.sys_nc_rowinfo$;
  xmltype.schemaValidate(xdoc);
end;
/


@@xdbuuc3

-- Update xdbconfig's xmlref (only one row so this is ok)
call update_config_ref();

@@xdbuud2
@@xdbuud3

-- Clean up session/shared state 
exec xdb.dbms_xdbutil_int.flushsession;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

@@catxdav

-- Register DAV schema 
DECLARE
  c number;
BEGIN
  select count(*) into c 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url ='http://xmlns.oracle.com/xdb/dav.xsd';

  if c = 0 then
    dbms_output.put_line('creating dav schema');
    register_dav_schema('dav.xsd.11.0',FALSE);
  end if;
END;
/

@@catxdav2

exec xdb.dbms_xdbutil_int.flushsession;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

insert into xdb.xdb$xdb_ready values (null);
commit;

