Rem
Rem $Header: rdbms/admin/xdbe1m102.sql /st_rdbms_11.2.0/2 2012/12/11 10:21:50 apfwkr Exp $
Rem
Rem xdb1em102.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdb1em102.sql - <one-line expansion of the name>
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
Rem    spetride    12/07/09 - 9065059: xml indexes should be dropped before migrate
Rem    rburns      11/11/07 - 
Rem    mrafiq      01/08/07 - pass flag to register_dav_schema
Rem    spetride    07/21/06 - moved token table downgrade from xdbeu102.sql
Rem    rmurthy     06/02/06 - remove xlink, documentlinks deletion 
Rem    bkhaladk    04/25/06 - drop the csx xml.xsd and xmltr schema 
Rem    mrafiq      04/26/06 - call xdbuud3.sql 
Rem    mrafiq      04/07/06 - cleaning up 
Rem    abagrawa    03/28/06 - Use xdbuuc3 
Rem    abagrawa    03/26/06 - Pass in fixit function name to migratetable 
Rem    abagrawa    03/20/06 - Remove set echo on 
Rem    mrafiq      03/16/06 - Created
Rem


@@catxdbh
@@xdbuuc2

exec dbms_metadata_hack.cre_dir;

delete from xdb.xdb$xdb_ready;
commit;

-- Delete dav schema as it depends on ACL schema
declare
  delete_option number := xdb.dbms_xmlschema.delete_cascade_force +
                          xdb.dbms_xmlschema.delete_migrate;
  davurl varchar2(100) := 'http://xmlns.oracle.com/xdb/dav.xsd';
begin
  delete_schema_if_exists(davurl, delete_option);
end;
/

commit;

select index_name, status from dba_indexes where table_name='XDB$ACL';
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
select index_name, status from dba_indexes where table_name='XDB$ACL';

set serveroutput on size unlimited
exec dbms_output.enable(null);

declare
  aclxsd xmltype := xmltype(dbms_metadata_hack.get_bfile('acl.xsd.10.2'), 0);
begin
xdb$migratexmltable(xsd => aclxsd,
nmspc => 'http://xmlns.oracle.com/xdb/acl.xsd',
url => 'http://xmlns.oracle.com/xdb/acl.xsd',
tabname => 'XDB$ACL',
schemaowner => 'XDB', root => 'acl', 
absdir => '/sys/schemas/PUBLIC/xmlns.oracle.com/xdb',
absfile => 'acl.xsd',
csx => false, transformfn => 'xdb.dbms_xdbutil_int.fixacl_downgrade');
end;
/

set serveroutput off

-- drop the csx xml.xsd and xmltr schemas;
declare
  delete_option number := xdb.dbms_xmlschema.delete_cascade_force +
                          xdb.dbms_xmlschema.delete_migrate;
  davurl varchar2(100) := 'http://xmlns.oracle.com/xdb/csx.xmltr.xsd';
begin
  delete_schema_if_exists(davurl, delete_option);
end;
/

declare
  delete_option number := xdb.dbms_xmlschema.delete_cascade_force +
                          xdb.dbms_xmlschema.delete_migrate;
  davurl varchar2(100) := 'http://xmlns.oracle.com/xdb/csx.xml.xsd';
begin
  delete_schema_if_exists(davurl, delete_option);
end;
/

set serveroutput on

declare
  configxsd xmltype := 
    xmltype(dbms_metadata_hack.get_bfile('xdbconfig.xsd.10.2'), 0);
begin
xdb$migratexmltable(xsd => configxsd,
nmspc => 'http://xmlns.oracle.com/xdb/xdbconfig.xsd',
url => 'http://xmlns.oracle.com/xdb/xdbconfig.xsd',
tabname => 'XDB$CONFIG',
schemaowner => 'XDB', root => 'xdbconfig', 
absdir => '/sys/schemas/PUBLIC/xmlns.oracle.com/xdb',
absfile => 'xdbconfig.xsd', csx=>false);
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

set serveroutput off

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
    register_dav_schema('dav.xsd.10.2', TRUE);
  end if;
END;
/

@@catxdav2

--downgrade for catxev.sql
revoke XDB_SET_INVOKER from DBA;
drop role XDB_SET_INVOKER;
revoke all on xdb.xdb$resconfig from public;

DECLARE
 c  number;
 schurl varchar2(100);
BEGIN

  schurl := 'http://xmlns.oracle.com/xdb/XDBResConfig.xsd';

  select count(*) into c
  from xdb.xdb$schema s 
  where s.xmldata.schema_url = schurl;

  if c > 0 then
    dbms_xmlschema.deleteschema(schurl, dbms_xmlschema.delete_cascade_force);
  end if;
END;
/
show errors;

insert into xdb.xdb$xdb_ready values (null);
commit;

