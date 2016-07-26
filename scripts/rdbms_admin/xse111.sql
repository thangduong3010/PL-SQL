Rem
Rem $Header: rdbms/admin/xse111.sql /main/3 2010/06/06 21:49:30 snadhika Exp $
Rem
Rem xse111.sql
Rem
Rem Copyright (c) 2007, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem     xse111.sql - XS downgrade to 11.1
Rem
Rem    DESCRIPTION
Rem      This script is invoked from the XDB top-level downgrade script
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    snadhika    04/14/10 - remove PREDICATE xmlindex
Rem    rpang       03/30/09 - downgrade PL/SQL network ACL security objects
Rem    rburns      01/03/08 - drop more packages
Rem    sichandr    01/07/08 - drop xmlindex for security class
Rem    jsamuel     12/27/07 - xml index on xsprincipals
Rem    rburns      11/06/07 - add 11.1 XS downgrade
Rem    taahmed     10/11/07 - downgrade DAV::dav security class
Rem    snadhika    10/11/07 - Drop ALL_XSC_SECURITY_CLASS_STATUS view and
Rem                           sys.xs$catview_util
Rem    asurpur     10/10/07 - Upgrade XS$cache_actions and xs$cache_delete
Rem    jnarasin    03/29/07 - Remove dbms_auth, dbms_passwd, midtier_auth
Rem                           dynamic roles
Rem    jnarasin    05/03/07 - Fix Bug 6020435
Rem    asurpur     03/20/07 - Fix bug 5885811 - uid change for xspublic
Rem    asurpur     03/20/07 - Fix bug 5885813 - add xsauthenticated to xspublic
Rem    taahmed     03/18/07 - remove space from resolve privilege
Rem    jsamuel     01/25/07 - downgrade script for XS project branch
Rem    jsamuel     01/25/07 - Created
Rem

Rem ===================================================================
Rem BEGIN XS Downgrade from Current Release to 11.2
Rem ===================================================================

-- uncomment for next release
--@@xse112.sql

Rem ===================================================================
Rem END XS Downgrade from Current Release to 11.2
Rem ===================================================================

Rem ===================================================================
Rem BEGIN XS Downgrade from Current Release to 11.1
Rem ===================================================================

@@nacle111.sql

-- Drop xml index for xs$securityclass
--drop index XDB.SC_XIDX;

-- Drop index on xs$principals
--drop index xdb.prin_xidx;


/* Downgrade DAV::dav security class.
*/

execute dbms_xdb.deleteresource('/sys/xs/securityclasses/dav.xml');

DECLARE
  b BOOLEAN;
BEGIN
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
END;
/

/* Security classes that are modified need to deleted first and then recreated 
   to the orginal version (11.0)
   These xml files should be moved to separate location in the future as well.
*/
execute dbms_xdb.deleteresource('/sys/xs/securityclasses/principalsc.xml');
execute dbms_xdb.deleteresource('/sys/xs/securityclasses/xssystemsc.xml');

/* Recreating the Principal Security Class to the original version (11.0)*/
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

begin
  dbms_xdb.deleteresource('/sys/xs/roles/xspublic.xml',
                          DBMS_XDB.DELETE_RECURSIVE_FORCE);
end;
/

declare
tmp boolean := false;
begin
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
end;
/

begin
  dbms_xdb.deleteresource('/sys/xs/users/xsguest.xml',
                          DBMS_XDB.DELETE_RECURSIVE_FORCE);
end;
/

Rem Add the xsguest user
declare
tmp boolean := false;
begin
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
end;
/

Rem delete the xsauthenticated user
begin
  dbms_xdb.deleteresource('/sys/xs/roles/xsauthenticated.xml',
                          DBMS_XDB.DELETE_RECURSIVE_FORCE);
end;
/

Rem Add the xsauthenticated role
declare
tmp boolean := false;
begin
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
end;
/

Rem delete the dbms_auth role
begin
  dbms_xdb.deleteresource('/sys/xs/roles/dbms_auth.xml',
                          DBMS_XDB.DELETE_RECURSIVE_FORCE);
end;
/

Rem delete the dbms_passwd role
begin
  dbms_xdb.deleteresource('/sys/xs/roles/dbms_passwd.xml',
                          DBMS_XDB.DELETE_RECURSIVE_FORCE);
end;
/

Rem delete the midtier_auth role
begin
  dbms_xdb.deleteresource('/sys/xs/roles/midtier_auth.xml',
                          DBMS_XDB.DELETE_RECURSIVE_FORCE);
end;
/

/*
Schema changes cannot be downgraded yet until we have CopyEvolve to work and 
modify the exisiting user documents to conform to the old schema.
The schema will be downgraded to the original version of the .xsd file.  The
following way of downgrading the schema can be done if there won't be any
associated xml documents.  */

/*
@@catxdbh
exec dbms_metadata_hack.cre_dir;


begin
  dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/principal.xsd',
                              dbms_xmlschema.delete_cascade_force);
end;
/

Rem Register principal schema
declare
  PRINCIPALXSD BFILE := dbms_metadata_hack.get_bfile('xsprin.xsd');
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

*/

delete from XDB.XS$CACHE_ACTIONS;


Rem add seed values for this table
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (1, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (2, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (3, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (4, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (9, systimestamp);


-- since the contents do not matter, drop and recreate
drop table XDB.XS$CACHE_DELETE;

Rem now create the Delete table
create table XDB.XS$CACHE_DELETE
  (
   ACLOID VARCHAR(32),
   SECCLS_QNAME VARCHAR2(4000),
   DEL_DATE TIMESTAMP NOT NULL
  );
comment on table XDB.XS$CACHE_DELETE is
'Table to retain deleted ACLOIDs and SecurityClass TokenIDs'
/
comment on column XDB.XS$CACHE_DELETE.ACLOID is
'Column to store deleted ACLOIDs for a certain window of time'
/
comment on column XDB.XS$CACHE_DELETE.SECCLS_QNAME is
'Column to store deleted SecurityClass QNames'
/
comment on column XDB.XS$CACHE_DELETE.DEL_DATE is
'Column to store the dates of the deleted objects'
/
create or replace public synonym XS$CACHE_DELETE for XDB.XS$CACHE_DELETE;
grant select on XS$CACHE_DELETE to public;
/

Rem =================================================================
Rem Drop all new packages, views, and public syonyms at the end
Rem =================================================================

drop public synonym ALL_XSC_SECURITY_CLASS_STATUS;
drop view sys.ALL_XSC_SECURITY_CLASS_STATUS;
drop package sys.xs$catview_util;

drop public synonym DBMS_XS_UTIL;
drop view V$XS_SESSION;
drop public synonym V$XS_SESSION;

Rem ===================================================================
Rem END XS Downgrade from Current Release to 11.1
Rem ===================================================================

