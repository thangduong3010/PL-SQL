Rem
Rem $Header: rdbms/admin/catzxs.sql /st_rdbms_11.2.0/1 2013/04/24 13:57:42 yanlili Exp $
Rem
Rem catzxs.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catzxs.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yanlili     04/19/13 - Backport minx_bug-16369584 from main
Rem    snadhika    04/14/10 - Remove PREDICATE xmlindex
Rem    yiru        03/06/09 - lock XS$NULL
Rem    yiru        02/20/09 - Fix bug 7331368: change timestamp literal when 
Rem                           inserting values into xs$cache_actions
Rem    samane      04/22/08 - fixed bug 6820989: undo changes of srtata 02/13/08 
Rem    srtata      03/03/08 - cleanup cache_actions grants
Rem    srtata      02/13/08 - create xspublic, xsguest after seed roles
Rem    jsamuel     12/27/07 - xml index on xsprincipals
Rem    chliang     11/15/07 - make xs tables hierarchy_enabled
Rem    taahmed     10/11/07 - remove dav::all from DAV::dav sec class
Rem    asurpur     10/04/07 - use fixed time for retension in xs$cache_actions
Rem    asurpur     09/27/07 - Extend mid-tier cache to support role
Rem                           invalidation
Rem    jsamuel     09/19/07 - add xsCallback privilege
Rem    pknaggs     08/24/07 - DSD schema: aclids to aclFiles or aclDirectory.
Rem    taahmed     06/28/07 - bug 6061975
Rem    jnarasin    03/29/07 - Add dbms_auth, dbms_passwd, midtier_auth dynamic
Rem                           roles
Rem    jnarasin    05/03/07 - Fix Bug 6020435
Rem    asurpur     03/20/07 - Fix bug 5885811 - change xspublic uid
Rem    asurpur     03/20/07 - Fix bug 5885813 - add xsauthenticated to xspublic
Rem    taahmed     03/12/07 - version 11.1 for xsseccls.xsd xsdatasec.xsd
Rem    jsamuel     01/25/07 - new version of xsprin.xsd
Rem    jnarasin    11/21/06 - Fix SC path
Rem    jsamuel     11/19/06 - added system security class
Rem    pknaggs     11/07/06 - Remove principal targetNamespace (bug 5632273)
Rem    taahmed     10/30/06 - mutable security class
Rem    pthornto    09/18/06 - move *.xsd definitions to flat files
Rem    pknaggs     09/14/06 - Register securityClass as CSX (bug 5404947)
Rem    taahmed     09/13/06 - 
Rem    pknaggs     09/05/06 - Remove DSD attribute_mask element
Rem    pknaggs     08/02/06 - Make DSD baseSecurityClass optional
Rem    pknaggs     07/21/06 - Change DBA_XDS_ATTRIBUTE_SECS for privilege
Rem    pknaggs     07/19/06 - Change DSD to use CSX 
Rem    mhho        08/31/06 - create XS$NULL
Rem    jnarasin    08/31/06 - Proxy user maxoccurs to be unbounded
Rem    jnarasin    08/22/06 - Session Privilege changes
Rem    srirasub    08/23/06 - principal document - convert to binary xml
Rem    taahmed     08/14/06 - xsguest user and xsauthenticated role seed
Rem                           document
Rem    mhho        08/18/06 - add apps_feature to global_var namespace
Rem    mxu         07/24/06 - Remove grant_type 
Rem    taahmed     06/15/06 - added title, description, and any for datasec doc
Rem    rpang       06/27/06 - add PL/SQL network ACL security objects
Rem    clei        06/15/06 - add column level data security dic views
Rem    srtata      06/09/06 - add default schema, duration to principal.xsd 
Rem    mhho        06/08/06 - ade views for lightweight user session 
Rem    rmurthy     05/25/06 - remove xlink schema
Rem    pthornto    03/22/06 - add tables for Mid-Tier cache 
Rem    mhho        03/27/06 - add lws privileges 
Rem    pknaggs     03/26/06 - XSC catalog views
Rem    cchui       03/22/06 - fix principal security class 
Rem    petam       03/11/06 - make DAV:dav the bottom sec class 
Rem    thbaby      03/09/06 - handle dav-xdb security class cyclic dependency 
Rem    taahmed     02/26/06 - system and dav privileges 
Rem    taahmed     02/11/06 - security class xml doc 
Rem    cchui       02/22/06 - add folder for xs repository event 
Rem                           configurations 
Rem    taahmed     02/26/06 - system and dav privileges 
Rem    taahmed     02/11/06 - security class xml doc 
Rem    cchui       02/14/06 - update principal schema 
Rem    taahmed     01/25/06 - add XML schemas for extensible security 
Rem    taahmed     01/18/06 - Initialize Extensible Security 
Rem    taahmed     01/18/06 - Initialize Extensible Security 
Rem    taahmed     01/18/06 - Created
Rem

DECLARE
  result BOOLEAN;
BEGIN
  result := dbms_xdb.createFolder('/sys/xs');
  result := dbms_xdb.createFolder('/sys/xs/securityclasses');
  result := dbms_xdb.createFolder('/sys/xs/roles');
  result := dbms_xdb.createFolder('/sys/xs/users');
END;
/

-- need this package to load the schema inforamtion from flat files.
-- First create a directory (db) to load the docs. Load Schemas then
-- drop the package after
@@catxdbh

exec dbms_metadata_hack.cre_dir;

Rem Register Data Security Documents schema
declare
  DSDXSD BFILE := dbms_metadata_hack.get_bfile('xsdatasec.xsd.11.1');
  DSDURL  varchar2(100) := 'http://xmlns.oracle.com/xs/dataSecurity.xsd';

begin
  dbms_xmlschema.registerSchema(
    schemaurl => DSDURL, 
    schemadoc => DSDXSD, 
    local     => FALSE,
    GENTYPES  => FALSE,
    GENTABLES => TRUE,
    owner     => 'XDB',
    options   => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end;
/

Rem Register sys_acloid column schema
declare
  AIDXSD  BFILE := dbms_metadata_hack.get_bfile('xsaclids.xsd');
  AIDURL  varchar2(100) := 'http://xmlns.oracle.com/xs/aclids.xsd';

begin
  xdb.dbms_xmlschema.registerSchema(AIDURL, AIDXSD, FALSE, FALSE, FALSE, FALSE,
                                    FALSE, 'XDB');
end;
/

Rem Register principal schema
declare
  PRINCIPALXSD BFILE := dbms_metadata_hack.get_bfile('xsprin.xsd.11.1');
  DSDURL  varchar2(100) := 'http://xmlns.oracle.com/xs/principal.xsd';

begin
dbms_xmlschema.registerSchema(DSDURL, PRINCIPALXSD,
                              owner=>'XDB',
                              local=>FALSE,
                              GENTYPES=>FALSE,
                              GENTABLES=>FALSE,
                              OPTIONS=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end;
/

create table XDB.XS$PRINCIPALS of XMLType XMLType xmlschema "http://xmlns.oracle.com/xs/principal.xsd" element "principal";

declare
  ROLESETXSD BFILE := dbms_metadata_hack.get_bfile('xsroleset.xsd');
  ROLESETURL  varchar2(100) := 'http://xmlns.oracle.com/xs/roleset.xsd';

begin
dbms_xmlschema.registerSchema(ROLESETURL, ROLESETXSD,owner=>'XDB',
                              local=>FALSE,GENTYPES=>TRUE,GENTABLES=>TRUE);
end;
/


declare
  SECLASSXSD BFILE := dbms_metadata_hack.get_bfile('xsseccls.xsd.11.1');
  SECLASSURL  varchar2(100) := 'http://xmlns.oracle.com/xs/securityclass.xsd';

BEGIN
  DBMS_XMLSCHEMA.registerSchema(
    schemaurl => SECLASSURL,
    schemadoc =>  SECLASSXSD,
    owner =>'XDB',
    local => FALSE,
    options => DBMS_XMLSCHEMA.REGISTER_BINARYXML,
    GENTYPES => FALSE, 
    GENTABLES => TRUE);
END;
/

-- create xml directory
exec dbms_metadata_hack.cre_xml_dir;

DECLARE
  b BOOLEAN;
BEGIN
  b := DBMS_XDB.createResource(
         '/sys/xs/securityclasses/securityclass.xml', 
         '<securityClass xmlns="http://xmlns.oracle.com/xs"
               xmlns:dav="DAV:"
               xmlns:xdb="http://xmlns.oracle.com/xdb"
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
END;
/

-- Base privileges in XDB namespace
DECLARE
  b BOOLEAN;
BEGIN
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
END;
/

-- Base privileges in DAV namespace
DECLARE
  b BOOLEAN;
BEGIN
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
END;
/

DECLARE
  b BOOLEAN;
BEGIN
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
END;
/


Rem DAV::dav security class
declare
tmp boolean := false;
DAVXML BFILE := dbms_metadata_hack.get_xml_bfile('dav.xml.11.1');
DAVXSD XMLTYPE := XMLTYPE(DAVXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/securityclasses/dav.xml',DAVXSD);
end;
/

Rem Add the xspublic role - uid set to KUSRMAX+999
declare
tmp boolean := false;
XSPUBLICXML BFILE := dbms_metadata_hack.get_xml_bfile('xspublic.xml.11.1');
XSPUBLICXSD XMLTYPE := XMLTYPE(XSPUBLICXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/xspublic.xml',XSPUBLICXSD);
end;
/

Rem Add the xsguest user - uid set to KUSRMAX+998 
declare
tmp boolean := false;
XSGUESTXML BFILE := dbms_metadata_hack.get_xml_bfile('xsguest.xml.11.1');
XSGUESTXSD XMLTYPE := XMLTYPE(XSGUESTXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/users/xsguest.xml',XSGUESTXSD);
end;
/

Rem Add the xsauthenticated role - uid set to KUSRMAX+997
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('xsauthenticated.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/xsauthenticated.xml',XSAUTHXSD);
end;
/

Rem Add the dbms_auth role - uid set to KUSRMAX+996
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('dbms_auth.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/dbms_auth.xml',XSAUTHXSD);
end;
/

Rem Add the dbms_passwd role - uid set to KUSRMAX+995
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('dbms_passwd.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/dbms_passwd.xml',XSAUTHXSD);
end;
/

Rem Add the midtier_auth role - uid set to KUSRMAX+994
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('midtier_auth.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/midtier_auth.xml',XSAUTHXSD);
end;
/

declare
  tmp boolean;
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/securityclasses/principalsc.xml',
'<securityClass xmlns="http://xmlns.oracle.com/xs"
   xmlns:dav="DAV:"
   xmlns:xdb="http://xmlns.oracle.com/xdb/acl.xsd"
   xmlns:sxs="http://xmlns.oracle.com/xs"
   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
   xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/securityclass.xsd" 
  targetNamespace="http://xmlns.oracle.com/xs"
  name="PrincipalSecurityClass"
  mutable="false">
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

  <privilege name = "changeUserPassword">
    <title>
        Change Password for users in Fusion Database.
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
end;
/

Rem Add System Security Class
declare
tmp boolean := false;
SSCXML BFILE := dbms_metadata_hack.get_xml_bfile('xssystemsc.xml.11.1');
SSCXSD XMLTYPE := XMLTYPE(SSCXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/securityclasses/xssystemsc.xml',SSCXSD);
end;
/


-- end of dbms_metadata_hack use drop the package
exec dbms_metadata_hack.drop_dir;

drop package dbms_metadata_hack;

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

Rem add seed values for this table
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (1, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (2, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (3, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (4, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (5, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (6, systimestamp);
-- The frasec field is used as retension  time. Set to 1 week 
-- Fix bug 7331368
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) 
                         values (9, TIMESTAMP '2007-10-04 13:02:43.000010080');

Rem now create the Delete table
Rem OBJ_TYPE  will reflect one of the above values
Rem check kzxh.h, KZXHACLMOD, etc for ObJ_TYPE values
create table XDB.XS$CACHE_DELETE
  (
   OBJ_TYPE   NUMBER(2),
   NAME VARCHAR2(4000),
   DEL_DATE TIMESTAMP NOT NULL
  );
comment on table XDB.XS$CACHE_DELETE is
'Table to retain deleted ACLOIDs, SecurityClasses, roles etc'
/
comment on column XDB.XS$CACHE_DELETE.OBJ_TYPE is
'Column to store type of the object deleted'
/
comment on column XDB.XS$CACHE_DELETE.NAME is
'Column to store deleted QName or ID'
/
comment on column XDB.XS$CACHE_DELETE.DEL_DATE is
'Column to store the dates of the deleted objects'
/
create or replace public synonym XS$CACHE_DELETE for XDB.XS$CACHE_DELETE;
/

Rem Create network ACL security tables, views
-- moved dbmsnacl.sql and prvtnacl.plb to xsrelod.sql(all package stuff)
@@catnacl

Rem
Rem Create the XS$NULL user. This user represents the state where DB UID
Rem is invalid but the schema ID is valid. Currently used by Fusion since 11gR1
Rem
create user XS$NULL identified by values
'S:000000000000000000000000000000000000000000000000000000000000'
account lock password expire
/


--Index creation for XS tables
--@@xsindex

-- Always keep this at the end. Runs all packages and creates all views
@@xsrelod

