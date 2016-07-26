Rem
Rem $Header: rdbms/admin/xsu102.sql /main/22 2009/01/29 11:22:18 yiru Exp $
Rem
Rem xsu102.sql
Rem
Rem Copyright (c) 2006, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xsu102.sql - Upgrade script for Fusion Security 
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yiru        12/10/08 - Fixup: create xs$principals table after the new
Rem                           the new schema is registered and misc. fixups
Rem    sidicula    01/10/08 - Grants to dba, system
Rem    rburns      11/05/07 - fixup re-run errors
Rem    rburns      10/02/07 - add 11g upgrade
Rem    jsamuel     01/25/07 - Call xszxsu102 for changes on XS project branch
Rem    mhho        02/28/07 - remove extra space from resolve privilege
Rem    pknaggs     11/07/06 - Remove principal targetNamespace (bug 5632273)
Rem    taahmed     10/30/06 - bug-5479794
Rem    pthornto    10/09/06 - move VIEW creations to xsrelod.sql
Rem    pthornto    09/19/06 - use flat files for schema defns
Rem    pknaggs     09/26/06 - Register securityClass as CSX (bug 5404947)
Rem    taahmed     09/13/06 - 
Rem    pknaggs     09/08/06 - Add [ALL|USER|DBA]_XDS_ATTRIBUTE_SECS views
Rem    pknaggs     09/05/06 - Remove DSD attribute_mask element
Rem    pknaggs     08/02/06 - Make DSD baseSecurityClass optional
Rem    pknaggs     07/19/06 - Change DSD to use CSX
Rem    mhho        08/31/06 - create xs$null user
Rem    jnarasin    08/31/06 - Privilege and proxy user changes
Rem    srirasub    08/27/06 - bug-5487336 - binary xml principal schema
Rem    taahmed     08/14/06 - xsguest user and xsauthenticated role
Rem    mhho        08/18/06 - add apps_feature to global_var namespace
Rem    mxu         08/03/06 - Remove grant_type
Rem    taahmed     06/22/06 - added title, description, and any for datasec doc
Rem    rpang       06/27/06 - add PL/SQL network ACL security objects
Rem    mhho        06/15/06 - modify to include new views 
Rem    rmurthy     05/30/06 - removed xlink.xsd, rename document_links
Rem    pthornto    05/11/06 - mid tier cache stuff 
Rem    petam       04/10/06 - Created
Rem

Rem ======================================================================
Rem BEGIN XS upgrade from 10.2.0
Rem ======================================================================

Rem Create resources if they do not exist
DECLARE
  result BOOLEAN;
BEGIN
  if (NOT DBMS_XDB.existsResource('/sys/xs')) then
    result := dbms_xdb.createFolder('/sys/xs');
  end if;
  if (NOT DBMS_XDB.existsResource('/sys/xs/securityclasses')) then
    result := dbms_xdb.createFolder('/sys/xs/securityclasses');
  end if;
  if (NOT DBMS_XDB.existsResource('/sys/xs/roles')) then
    result := dbms_xdb.createFolder('/sys/xs/roles');
  end if;
  if (NOT DBMS_XDB.existsResource('/sys/xs/users')) then
    result := dbms_xdb.createFolder('/sys/xs/users');
  end if;
END;
/


Rem Register Data Security Documents schema
declare
  DSDURL  varchar2(100) := 'http://xmlns.oracle.com/xs/dataSecurity.xsd';
  c number;
  DSDXSD BFILE := dbms_metadata_hack.get_bfile('xsdatasec.xsd');

begin
 select count(*) into c 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url =DSDURL;

  if c = 0 then
    dbms_xmlschema.registerSchema(
      schemaurl => DSDURL,
      schemadoc => DSDXSD, 
      local     => FALSE,
      GENTYPES  => FALSE,
      GENTABLES => TRUE,
      owner     => 'XDB',
      options   => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
  end if;
end;
/

Rem Register sys_acloid column schema
declare
  AIDURL  varchar2(100) := 'http://xmlns.oracle.com/xs/aclids.xsd';
  c number;
  AIDXSD  BFILE := dbms_metadata_hack.get_bfile('xsaclids.xsd');

begin
  select count(*) into c 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url =AIDURL;

  if c = 0 then
  xdb.dbms_xmlschema.registerSchema(AIDURL, AIDXSD, FALSE, FALSE, FALSE, FALSE,
                                    FALSE, 'XDB');
  end if;
end;
/

Rem Register principal schema
declare
  c number;
  PRINCIPALXSD BFILE := dbms_metadata_hack.get_bfile('xsprin.xsd');
  stmt    varchar2(2000);
begin
select count(*) into c 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url ='http://xmlns.oracle.com/xs/principal.xsd';

  if c = 0 then
  dbms_xmlschema.registerSchema('http://xmlns.oracle.com/xs/principal.xsd',
                              PRINCIPALXSD,owner=>'XDB',
                              local=>FALSE,GENTYPES=>FALSE,GENTABLES=>FALSE, OPTIONS=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
 stmt := ' create table XDB.XS$PRINCIPALS of XMLType XMLType xmlschema "http://xmlns.oracle.com/xs/principal.xsd" element "principal"';
 execute immediate stmt;
end if;
end;
/

--select count(*) from xdb.xs$principals;
--create table XDB.XS$PRINCIPALS of XMLType XMLType xmlschema "http://xmlns.oracle.com/xs/principal.xsd" element "principal";
--sanity check
--SELECT t.prin_path, r.any_path acl_path, t.acloid, t.uuid
--    FROM
--      (SELECT r.any_path prin_path, extractValue(r.res,'/Resource/ACLOID') acloid, extractValue(value(p),'/*/UID') uuid
--       FROM xdb.xs$principals p, resource_view r
--       WHERE ref(p) = extractvalue(r.RES, '/Resource/XMLRef')
--      ) t, resource_view r
--WHERE  t.acloid = sys_op_r2o(extractValue(r.res, '/Resource/XMLRef'));

declare
  c number;
  ROLESETXSD BFILE := dbms_metadata_hack.get_bfile('xsroleset.xsd');

begin
  select count(*) into c 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url ='http://xmlns.oracle.com/xs/roleset.xsd';

  if c = 0 then
  dbms_xmlschema.registerSchema('http://xmlns.oracle.com/xs/roleset.xsd',
                              ROLESETXSD,owner=>'XDB',
                              local=>FALSE,GENTYPES=>TRUE,GENTABLES=>TRUE);
end if;
end;
/

DECLARE
  c number;
  SECLASSXSD BFILE := dbms_metadata_hack.get_bfile('xsseccls.xsd');
  SECLASSURL  varchar2(100) := 'http://xmlns.oracle.com/xs/securityclass.xsd';

BEGIN
 select count(*) into c 
  from xdb.xdb$schema s 
  where s.xmldata.schema_url ='http://xmlns.oracle.com/xs/securityclass.xsd';

  if c = 0 then
  DBMS_XMLSCHEMA.registerSchema(
    schemaurl => SECLASSURL,
    schemadoc => SECLASSXSD,
    owner =>'XDB',
    local => FALSE,
    options => DBMS_XMLSCHEMA.REGISTER_BINARYXML,
    GENTYPES => FALSE, 
    GENTABLES => TRUE);
end if;
END;
/


DECLARE
  b BOOLEAN;
BEGIN
  if (NOT DBMS_XDB.existsResource('/sys/xs/securityclasses/securityclass.xml')) then
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/securityclass.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:dav="DAV:"
               xmlns:xdb="http://xmlns.oracle.com/xdb/acl.xsd"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
targetNamespace="http://xmlns.oracle.com/xs"
               name="securityclass">
    <title>
        SecurityClass
    </title>
    <inherits-from>dav:dav</inherits-from>
    <privilege name="extend">
        <title>
            extend
        </title>
    </privilege>
</securityClass>');
end if;
END;
/

DECLARE
  b BOOLEAN;
BEGIN
  if (NOT DBMS_XDB.existsResource('/sys/xs/securityclasses/baseSystemPrivileges.xml')) then
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/baseSystemPrivileges.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:xdb="http://xmlns.oracle.com/xdb/acl.xsd"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
targetNamespace="http://xmlns.oracle.com/xdb/acl.xsd"
               name="baseSystemPrivileges">
  <title>
     Base System Privileges
  </title>

  <privilege name = "read-properties"/>
  <privilege name = "read-contents"/>
  <privilege name = "write-config"/>
  <privilege name = "link"/>
  <privilege name = "unlink"/>
  <privilege name = "read-acl"/>
  <privilege name = "write-acl-ref"/>
  <privilege name = "update-acl"/>
  <privilege name = "resolve"/>
  <privilege name = "link-to"/>
  <privilege name = "unlink-from"/>
</securityClass>');
end if;
END;
/

DECLARE
  b BOOLEAN;
BEGIN
  if (NOT DBMS_XDB.existsResource('/sys/xs/securityclasses/baseDavPrivileges.xml')) then
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/baseDavPrivileges.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:dav="DAV:"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
targetNamespace="DAV:"
               name="baseDav">
    <title>
       Base DAV Privileges
    </title>

    <privilege name = "lock"/> 
    <privilege name = "unlock"/> 
    <privilege name = "write-properties"/> 
    <privilege name = "write-content"/> 
    <privilege name = "execute"/> 
    <privilege name = "take-ownership"/> 
    <privilege name = "read-current-user-privilege-set"/> 
</securityClass>');
end if;
END;
/

DECLARE
  b BOOLEAN;
BEGIN
  if (NOT DBMS_XDB.existsResource('/sys/xs/securityclasses/systemPrivileges.xml')) then
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/systemPrivileges.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:dav="DAV:"
               xmlns:xdb="http://xmlns.oracle.com/xdb/acl.xsd"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
targetNamespace="http://xmlns.oracle.com/xdb/acl.xsd"
               name="systemPrivileges"
               mutable="false">

  <title>
     System Privileges
  </title>

  <inherits-from>xdb:baseSystemPrivileges</inherits-from>
  <inherits-from>dav:baseDav</inherits-from>

  <aggregatePrivilege name="update">
     <privilegeRef name="dav:write-properties"/>
     <privilegeRef name="dav:write-content"/>
  </aggregatePrivilege>

  <aggregatePrivilege name="all">
    <privilegeRef name = "xdb:read-properties"/>
    <privilegeRef name = "xdb:read-contents"/>
    <privilegeRef name = "xdb:write-config"/>
    <privilegeRef name = "xdb:link"/>
    <privilegeRef name = "xdb:unlink"/>
    <privilegeRef name = "xdb:read-acl"/>
    <privilegeRef name = "xdb:write-acl-ref"/>
    <privilegeRef name = "xdb:update-acl"/>
    <privilegeRef name = "xdb:resolve"/>
    <privilegeRef name = "xdb:link-to"/>
    <privilegeRef name = "xdb:unlink-from"/>
    <privilegeRef name = "dav:lock"/> 
    <privilegeRef name = "dav:unlock"/> 
    <privilegeRef name = "dav:write-properties"/> 
    <privilegeRef name = "dav:write-content"/> 
    <privilegeRef name = "dav:execute"/> 
    <privilegeRef name = "dav:take-ownership"/> 
    <privilegeRef name = "dav:read-current-user-privilege-set"/> 
  </aggregatePrivilege>
</securityClass>');
end if;
END;
/

DECLARE
  b BOOLEAN;
BEGIN
  if (NOT DBMS_XDB.existsResource('/sys/xs/securityclasses/dav.xml')) then
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/dav.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:xdb="http://xmlns.oracle.com/xdb/acl.xsd"
               xmlns:dav="DAV:"
               xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
targetNamespace="DAV:"
               name="dav"
               mutable="false">
    <title>
       DAV privileges
    </title>

    <inherits-from>xdb:systemPrivileges</inherits-from>

    <aggregatePrivilege name="bind">
      <privilegeRef name="xdb:link"/>
    </aggregatePrivilege>

    <aggregatePrivilege name="unbind">
      <privilegeRef name="xdb:unlink"/>
    </aggregatePrivilege>

    <aggregatePrivilege name="read">
      <privilegeRef name="xdb:read-properties"/>
      <privilegeRef name="xdb:read-contents"/>
      <privilegeRef name="xdb:resolve"/>
    </aggregatePrivilege>

    <aggregatePrivilege name="write">
      <privilegeRef name = "dav:write-properties"/> 
      <privilegeRef name = "dav:write-content"/> 
      <privilegeRef name="xdb:link"/>
      <privilegeRef name="xdb:unlink"/>
      <privilegeRef name="xdb:unlink-from"/>
    </aggregatePrivilege>

    <aggregatePrivilege name="read-acl">
      <privilegeRef name="xdb:read-acl"/>
    </aggregatePrivilege>

    <aggregatePrivilege name="write-acl">
      <privilegeRef name="xdb:write-acl-ref"/>
      <privilegeRef name="xdb:update-acl"/>
    </aggregatePrivilege>

    <aggregatePrivilege name="all">
      <privilegeRef name = "xdb:read-properties"/>
      <privilegeRef name = "xdb:read-contents"/>
      <privilegeRef name = "xdb:write-config"/>
      <privilegeRef name = "xdb:link"/>
      <privilegeRef name = "xdb:unlink"/>
      <privilegeRef name = "xdb:read-acl"/>
      <privilegeRef name = "xdb:write-acl-ref"/>
      <privilegeRef name = "xdb:update-acl"/>
      <privilegeRef name = "xdb:resolve"/>
      <privilegeRef name = "xdb:unlink-from"/>
      <privilegeRef name = "dav:lock"/> 
      <privilegeRef name = "dav:unlock"/> 
      <privilegeRef name = "dav:write-properties"/> 
      <privilegeRef name = "dav:write-content"/> 
      <privilegeRef name = "dav:execute"/> 
      <privilegeRef name = "dav:take-ownership"/> 
      <privilegeRef name = "dav:read-current-user-privilege-set"/> 
    </aggregatePrivilege>
</securityClass>');
end if;
END;
/

declare
tmp boolean := false;
begin
  if (NOT DBMS_XDB.existsResource('/sys/xs/securityclasses/principalsc.xml'))
then
  tmp := DBMS_XDB.CreateResource('/sys/xs/securityclasses/principalsc.xml',
'<securityClass xmlns="http://xmlns.oracle.com/xs"
   xmlns:dav="DAV:"
   xmlns:xdb="http://xmlns.oracle.com/xdb/acl.xsd"
   xmlns:sxs="http://xmlns.oracle.com/xs"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
  targetNamespace="http://xmlns.oracle.com/xs"
  name="PrincipalSecurityClass">
  <title>PrincipalSecurityClass</title> 
  <inherits-from>dav:dav</inherits-from>
  <privilege name="createUser" /> 
  <privilege name="proxyTo" /> 
  <privilege name="createRole" /> 
  <privilege name="enable" /> 
  <privilege name="addtoSet" />
  <privilege name="createRoleSet"/>
  <aggregatePrivilege name="viewUser">
    <privilegeRef name="xdb:read-contents" /> 
    <privilegeRef name="xdb:resolve" />
  </aggregatePrivilege>
  <aggregatePrivilege name="grant">
    <privilegeRef name="xdb:link-to" /> 
    <privilegeRef name="xdb:unlink-from" /> 
    <privilegeRef name="xdb:read-contents" /> 
    <privilegeRef name="xdb:resolve" />
  </aggregatePrivilege>
  <aggregatePrivilege name="grantTo">
    <privilegeRef name="xdb:link" /> 
    <privilegeRef name="xdb:unlink" /> 
    <privilegeRef name="xdb:update" /> 
    <privilegeRef name="xdb:read-contents" /> 
  </aggregatePrivilege>
  <aggregatePrivilege name="viewRole">
    <privilegeRef name="xdb:read-contents" /> 
    <privilegeRef name="xdb:resolve" />
  </aggregatePrivilege>
  <aggregatePrivilege name="viewRoleset">
    <privilegeRef name="xdb:read-contents" /> 
  </aggregatePrivilege>
  <aggregatePrivilege name="admin">
    <privilegeRef name="xdb:read-properties" /> 
    <privilegeRef name="xdb:read-contents" /> 
    <privilegeRef name="xdb:update" /> 
    <privilegeRef name="xdb:link" /> 
    <privilegeRef name="xdb:unlink" /> 
    <privilegeRef name="xdb:link-to" /> 
    <privilegeRef name="xdb:unlink-from" /> 
    <privilegeRef name="xdb:read-acl" /> 
    <privilegeRef name="xdb:write-acl-ref" /> 
    <privilegeRef name="xdb:update-acl" /> 
    <privilegeRef name="xdb:resolve" /> 
  </aggregatePrivilege>

  <privilege name = "createSession">
    <title>
      Create a Light Weight User Session
    </title>
  </privilege>
  <privilege name="termSession">
    <title>
      Terminate a Light Weight User Session
    </title>
  </privilege>

  <aggregatePrivilege name="createTermSession">
    <privilegeRef name="sxs:createSession" /> 
    <privilegeRef name="sxs:termSession" /> 
  </aggregatePrivilege>

  <privilege name="attachToSession">
    <title>
      Attach to a Light Weight User Session
    </title>
  </privilege>
  <privilege name="modifySession">
    <title>
      Modify contents of a Light Weight User Session
    </title>
  </privilege>
  <privilege name="switchUser">
    <title>
      Switch User of a Light Weight User Session
    </title>
  </privilege>
  <privilege name="assignUser">
    <title>
      Assign User to an anonymous Light Weight User Session
    </title>
  </privilege>
  <privilege name="administerNamespace">
    <title>
      Create/Delete/Change properties of Namespaces.
    </title>
  </privilege>

  <aggregatePrivilege name="administerSession">
    <privilegeRef name="sxs:createTermSession" /> 
    <privilegeRef name="sxs:attachToSession" /> 
    <privilegeRef name="sxs:modifySession" /> 
    <privilegeRef name="sxs:switchUser" /> 
    <privilegeRef name="sxs:assignUser" /> 
    <privilegeRef name="sxs:administerNamespace" /> 
  </aggregatePrivilege>

  <privilege name="setAttribute">
    <title>
      Set a Light Weight User Session Attribute
    </title>
  </privilege>
  <privilege name="readAttribute">
    <title>
      Read value of a Light Weight User Session Attribute
    </title>
  </privilege>

  <aggregatePrivilege name="administerAttributes">
    <privilegeRef name="sxs:setAttribute" /> 
    <privilegeRef name="sxs:readAttribute" /> 
  </aggregatePrivilege>

  </securityClass>');
end if;
end;
/

Rem Add the xspublic role
declare
tmp boolean := false;
begin
  if (NOT DBMS_XDB.existsResource('/sys/xs/roles/xspublic.xml'))
then
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/xspublic.xml',
'<role xmlns="http://xmlns.oracle.com/xs"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/principal.xsd"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      enable="true">
  <UID>2147483649</UID>
  <GUID>4B0F192BF5214F9BBF058025E8E23B89</GUID>
  <name>xspublic</name>
</role>');
end if;
end;
/

Rem Add the xsauthenticated role
declare
tmp boolean := false;
begin
  if (NOT DBMS_XDB.existsResource('/sys/xs/roles/xsauthenticated.xml'))
then
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/xsauthenticated.xml',
'<dynamicRole xmlns="http://xmlns.oracle.com/xs"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/principal.xsd"
      xmlns:xlink="http://www.w3.org/1999/xlink"
      enable="false">
  <UID>2147483650</UID>
  <GUID>82B7C3CCBF794F2EBFAA4E8ED7A9AF30</GUID>
  <name>xsauthenticated</name>
</dynamicRole>');
end if;
end;
/

Rem Add the xsguest user
declare
tmp boolean := false;
begin
  if (NOT DBMS_XDB.existsResource('/sys/xs/users/xsguest.xml'))
then
  tmp := DBMS_XDB.CreateResource('/sys/xs/users/xsguest.xml',
'<user xmlns="http://xmlns.oracle.com/xs"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/principal.xsd"
      xmlns:xlink="http://www.w3.org/1999/xlink">
  <UID>2147483651</UID>
  <GUID>3ACB6B1172E54FF9BF70497B70C7B733</GUID>
  <roleGrant xlink:type="simple" xlink:href="/sys/xs/roles/xspublic.xml" />
  <userName>xsguest</userName> 
</user>');
end if;
end;
/

-- XS$CACHE_ACTIONS used by Mid-Tier Cache
create table XDB.XS$CACHE_ACTIONS
  (
   ROW_KEY NUMBER(1) UNIQUE,
   TIME_VAL TIMESTAMP(9) NOT NULL
  );
comment on table XDB.XS$CACHE_ACTIONS is
'Timestamps used for Mid-Tier-Cache object invalidation'
/
comment on column XDB.XS$CACHE_ACTIONS.ROW_KEY is
'Type of the TimeStamp value.'
/
comment on column XDB.XS$CACHE_ACTIONS.TIME_VAL is
'Timestamp associated with this key'
/
create or replace public synonym XS$CACHE_ACTIONS for XDB.XS$CACHE_ACTIONS;
grant select on XS$CACHE_ACTIONS to public;

Rem add seed values for this table
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (1, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (2, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (3, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (4, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (9, systimestamp);

Rem now create the Delete table
create table XDB.XS$CACHE_DELETE
  (
   ACLOID VARCHAR(32),
   SECCLS_QNAME VARCHAR2(4000),
   DEL_DATE TIMESTAMP NOT NULL
  );

create or replace public synonym XS$CACHE_DELETE for XDB.XS$CACHE_DELETE;
grant select on XS$CACHE_DELETE to public;
/

Rem Create PL/SQL network ACL security tables, views
-- dbmsnacl and prvtnacl.plb was moved to xsrelod.sql
@@catnacl

drop user XS$NULL cascade
/
create user XS$NULL identified by NO_PASSWORD
/

-- Explicit grants to DBA,System; "any" privileges arent enough for XDB tables.
grant all on XDB.XS$DATA_SECURITY to dba;
grant all on XDB.XS$PRINCIPALS to dba;
grant all on XDB.XS$ROLESETS to dba;
grant all on XDB.XS$SECURITYCLASS to dba;
grant all on XDB.XS$DATA_SECURITY to system with grant option;
grant all on XDB.XS$PRINCIPALS to system with grant option;
grant all on XDB.XS$ROLESETS to system with grant option;
grant all on XDB.XS$SECURITYCLASS to system with grant option;

Rem ======================================================================
Rem END XS upgrade from 10.2.0
Rem ======================================================================

Rem ======================================================================
Rem BEGIN XS upgrade from subsequent releases
Rem ======================================================================

@@xsu111.sql

Rem ======================================================================
Rem END XS upgrade from subsequent releases
Rem ======================================================================
