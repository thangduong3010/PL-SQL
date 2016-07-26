Rem
Rem $Header: rdbms/admin/xsu111.sql /st_rdbms_11.2.0/1 2012/11/02 16:49:06 mkandarp Exp $
Rem
Rem xsu111.sql
Rem
Rem Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xsu111.sql - XS Upgrade from 11.1
Rem
Rem    DESCRIPTION
Rem      This script upgrades XS from 11.1 to the current release
Rem
Rem    NOTES
Rem      Invoked from xsdbmig.sql and xsu102.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      10/21/12 - Backport mkandarp_bug-13683150 from
Rem    snadhika    04/14/10 - Remove PREDICATE xmlindex
Rem    yiru        04/13/09 - Create and lock XS$NULL user
Rem    yiru        03/25/09 - Remove alter system flush shared_pool
Rem    yiru        02/20/09 - Fix bug 7331368: change timestamp literal when 
Rem                           inserting values into xs$cache_actions
Rem    sichandr    02/05/09 - add namespace mapping
Rem    yiru        12/02/08 - set ACL after upgrade and clean-up
Rem    jsamuel     09/11/08 - fix lrg 3599584 ignore upgrade error
Rem    srtata      03/03/08 - remove grants on cache_actions table
Rem    jsamuel     12/27/07 - xml index on xsprincipals
Rem    taahmed     11/27/07 - xml index for security class
Rem    jsamuel     11/06/07 - multiple handlers project
Rem    rburns      11/05/07 - add exception handling
Rem    mrafiq      10/31/07 - add dav security class
Rem    rbhatti     11/02/07 - Remove elements from xs$principals as part of the schema change (no effective dates in role, no duration in dynamic role, none in function role)
Rem    rburns      10/28/07 - rename xszxsu102.sql to xsu111.sql
Rem    spetride    10/10/07 - cleanup session state before principal.xsd reg.
Rem    snadhika    10/02/07 - Removed ALL_XSC_SECURITY_CLASS, as it is defined
Rem                           in xsrelod.sql
Rem    asurpur     10/10/07 - Upgrade XS$cache_actions and xs$cache_delete
Rem    taahmed     06/28/07 - bug 6061975
Rem    jnarasin    03/29/07 - Add dbms_auth, dbms_passwd, midtier_auth dynamic
Rem                           roles
Rem    jnarasin    05/03/07 - Fix Bug 6020435
Rem    asurpur     03/21/07 - ade co xszxse102.sql
Rem    asurpur     03/20/07 - Fix bug 5885811 - uid change for xspublic
Rem    asurpur     03/20/07 - Fix bug 5885813 - add xsauthenticated to xspublic
Rem    taahmed     03/19/07 - remove space from "resolve" priv name
Rem    taahmed     03/12/07 - bug 5753381
Rem    taahmed     03/12/07 - version 11.1 for xsseccls.xsd xsdatasec.xsd
Rem    jsamuel     01/24/07 - temporary upgrade file for XS project branch
Rem    jsamuel     01/24/07 - Created
Rem

Rem ====================================================================== 
Rem BEGIN XS upgrade from 11.1.0
Rem ======================================================================
----------------------------------------------------------------------
REM 1. packages needed
----------------------------------------------------------------------
-- These are added in xsdbmig.sql. So they are not needed here. 
-- @@catxdbh
-- exec dbms_metadata_hack.cre_dir;
-- exec dbms_metadata_hack.cre_xml_dir;

----------------------------------------------------------------------
REM 2. principal schema upgrades
----------------------------------------------------------------------

----------------------------------------------------------------------
REM 2.1 Update the documents per the new schema changes
REM     1) Remove duration from all role documents
REM     2) Remove effective dates from all dynamicRole documents
REM     3) Remove both from all functionRole documents
----------------------------------------------------------------------
Rem Remove duration from role documents
DECLARE
   CURSOR p_cursor IS
     select /*+ index ( r XDB$RESOURCE_OID_INDEX ) */
            r.any_path from resource_view r, xdb.xs$principals p 
     where existsNode(value(p), '/role') = 1 and 
           ref(p) = extractvalue(r.RES, '/Resource/XMLRef'); 

path resource_view.any_path%TYPE;

BEGIN
  OPEN p_cursor;
  LOOP
    FETCH p_cursor INTO path;

 --  FOR path IN p_cursor LOOP;
   
    EXIT WHEN p_cursor%NOTFOUND;

    dbms_output.put_line(path);

    UPDATE resource_view r
    SET r.res = deleteXML(r.RES, '/r:Resource/r:Contents/a:role/a:duration',
                       'xmlns:r="http://xmlns.oracle.com/xdb/XDBResource.xsd" 
                        xmlns:a="http://xmlns.oracle.com/xs"')
    WHERE equals_path(r.RES, path) = 1;
  END LOOP;
  CLOSE p_cursor;
END;
/

Rem Remove effective dates from all dynamicRole documents
DECLARE
   CURSOR p_cursor IS
    select /*+ index ( r XDB$RESOURCE_OID_INDEX ) */
           r.any_path from resource_view r, xdb.xs$principals p 
    where existsNode(value(p), '/dynamicRole') = 1 and 
    ref(p) = extractvalue(r.RES, '/Resource/XMLRef'); 

path resource_view.any_path%TYPE;

BEGIN
  OPEN p_cursor;
  LOOP
    FETCH p_cursor INTO path;

 --  FOR path IN p_cursor LOOP;
   
    EXIT WHEN p_cursor%NOTFOUND;

    dbms_output.put_line(path);

    UPDATE resource_view r
    SET r.res = deleteXML(r.RES, 
                       '/r:Resource/r:Contents/a:dynamicRole/a:effectiveDates',
                       'xmlns:r="http://xmlns.oracle.com/xdb/XDBResource.xsd" 
                        xmlns:a="http://xmlns.oracle.com/xs"')
    WHERE equals_path(r.RES, path) = 1;
  END LOOP;
  CLOSE p_cursor;
END;
/

Rem Remove duration and effective dates from all functionRole documents
DECLARE
  CURSOR p_cursor IS
    select r.any_path from resource_view r, xdb.xs$principals p 
    where existsNode(value(p), '/functionRole') = 1 and 
    ref(p) = extractvalue(r.RES, '/Resource/XMLRef'); 

  path resource_view.any_path%TYPE;

BEGIN
  OPEN p_cursor;
  LOOP
    FETCH p_cursor INTO path;

 --  FOR path IN p_cursor LOOP;
   
    EXIT WHEN p_cursor%NOTFOUND;

    dbms_output.put_line(path);

    UPDATE resource_view r
    SET r.res = deleteXML(r.RES, 
                      '/r:Resource/r:Contents/a:functionRole/a:effectiveDates',
                      'xmlns:r="http://xmlns.oracle.com/xdb/XDBResource.xsd" 
                       xmlns:a="http://xmlns.oracle.com/xs"')
    WHERE equals_path(r.RES, path) = 1;

    UPDATE resource_view r
    SET r.res = deleteXML(r.RES, 
                      '/r:Resource/r:Contents/a:functionRole/a:duration',
                      'xmlns:r="http://xmlns.oracle.com/xdb/XDBResource.xsd" 
                       xmlns:a="http://xmlns.oracle.com/xs"')
    WHERE equals_path(r.RES, path) = 1;

   END LOOP;
  CLOSE p_cursor;
END;
/

----------------------------------------------------------------------
REM 2.2 Backup table and Cleanup
REM     1) Drop index
REM     2) Backup table, relations between principals and ACLs
REM     3) Purge recyclebin of xdb and drop the xdb.xs$principals table
REM     4) Delete the old schema
REM     5) Clean up session/shared state  
----------------------------------------------------------------------
-- Create backup table
CREATE TABLE upgradeacl(
  prin_path  varchar2(4000),
  acl_path varchar2(4000));

INSERT INTO upgradeacl
SELECT /*+ index ( r XDB$RESOURCE_OID_INDEX ) */
t.prin_path, r.any_path acl_path
FROM
  (SELECT /*+ index ( r XDB$RESOURCE_OID_INDEX ) */
          r.any_path prin_path, extractValue(r.res,'/Resource/ACLOID') acloid 
   FROM xdb.xs$principals p, resource_view r 
   WHERE ref(p) = extractvalue(r.RES, '/Resource/XMLRef')
  ) t, resource_view r 
WHERE  t.acloid = sys_op_r2o(extractValue(r.res, '/Resource/XMLRef'));

--select * from upgradeacl;

CREATE TABLE upgradexs(
  any_path  varchar2(4000),
  prnc_data XMLTYPE)
XMLTYPE column prnc_data STORE AS CLOB ;

-- Take backup of all data from xs$principals
INSERT INTO upgradexs select /*+ index ( r XDB$RESOURCE_OID_INDEX ) */
r.any_path, p.SYS_NC_ROWINFO$ 
FROM resource_view r, xdb.xs$principals p
WHERE ref(p) = extractvalue(r.RES, '/Resource/XMLRef');

--sanity check
--SELECT t.prin_path, r.any_path acl_path, t.acloid, t.uuid
--FROM
--   (SELECT r.any_path prin_path, extractValue(r.res,'/Resource/ACLOID') acloid, extractValue(value(p),'/*/UID') uuid
--    FROM xdb.xs$principals p, resource_view r
--    WHERE ref(p) = extractvalue(r.RES, '/Resource/XMLRef')
--   ) t, resource_view r
--WHERE t.acloid = sys_op_r2o(extractValue(r.res, '/Resource/XMLRef'));

-- Delete documents from resource_view
DECLARE
  CURSOR c1 IS
    select /*+ index ( r XDB$RESOURCE_OID_INDEX ) */
           r.any_path path
    from resource_view r, xdb.xs$principals p
    where  ref(p) = extractvalue(r.RES, '/Resource/XMLRef');
BEGIN
  FOR r1 IN c1 LOOP
    dbms_xdb.deleteresource(r1.path);
  END LOOP;
END;
/

-- Drop index, xs$principals table and purge recyclebin of xdb
--begin
  --execute immediate 'drop index xdb.prin_xidx';
  --exception 
  --when others then
    --NULL;
--end;
--/

begin
  execute immediate 'purge tablespace xdb user xdb';
  exception 
  when others then
    NULL;
end;
/

begin
  execute immediate 'drop table XDB.XS$PRINCIPALS purge';
  exception 
  when others then
    NULL;
end;
/

-- Delete old principal schema
begin
  dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/principal.xsd',
                              dbms_xmlschema.delete_cascade_force);
end;
/

-- Clean up session/shared state 
-- This is needed to clear the SGA cached schema OID for principal.xsd
-- This could be removed after fix in atabar_bug-7279686
--exec xdb.dbms_xdbutil_int.flushsession;
--alter system flush shared_pool;
--alter system flush shared_pool;
--alter system flush shared_pool;
--alter system flush shared_pool;

----------------------------------------------------------------------
REM 2.3 Register the new principal schema and create xdb.xs$principals table
----------------------------------------------------------------------
-- Register new schema
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

-- Create new xs$principals table
create table XDB.XS$PRINCIPALS of XMLType XMLType xmlschema "http://xmlns.oracle.com/xs/principal.xsd" element "principal" ;

----------------------------------------------------------------------
REM 2.4 Post-upgrade
REM     1) Copy back the data to xdb.xs$principals table 
REM     2) Update the seed principal documents
REM     3) Set ACLs for all principal documents 
----------------------------------------------------------------------
-- Copy data back to xs$principals table
DECLARE
  tmp boolean := false;

  CURSOR c1 IS
    select u.any_path p, u.prnc_data r
    from upgradexs u;
BEGIN
  FOR r1 IN c1 LOOP
    tmp := dbms_xdb.createresource(r1.p, r1.r) ;
  END LOOP;
END;
/

-- Drop backup table
drop table upgradexs ;

-- Update xspublic.xml. We update this document rather than delete and 
-- recreate for two reasons:
-- 1. xspublic.xml has been granted all the old dynamic roles. We need to keep 
--    them.
-- 2. During Upgrade, the event handler is not fired, so the dynamic roles 
--    will not be added into the newly created xspublic.xml
UPDATE xdb.xs$principals p 
SET OBJECT_VALUE= 
insertchildXML( OBJECT_VALUE,'/role','roleGrant',xmltype('<roleGrant xmlns="http://xmlns.oracle.com/xs" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/principal.xsd" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="/sys/xs/roles/xsauthenticated.xml"/>'), 'xmlns="http://xmlns.oracle.com/xs"') 
WHERE extractvalue(value(p), '/role/name') ='xspublic' AND
  NOT existsNode(OBJECT_VALUE, '/role/roleGrant[@xlink:href="/sys/xs/roles/xsauthenticated.xml"]','xmlns="http://xmlns.oracle.com/xs xmlns:xlink="http://www.w3.org/1999/xlink"' ) = 1;


UPDATE xdb.xs$principals p 
SET OBJECT_VALUE= 
insertchildXML( OBJECT_VALUE,'/role','roleGrant',xmltype('<roleGrant xmlns="http://xmlns.oracle.com/xs" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/principal.xsd" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="/sys/xs/roles/dbms_auth.xml"/>'), 'xmlns="http://xmlns.oracle.com/xs"') 
WHERE extractvalue(value(p), '/role/name') ='xspublic' AND
  NOT existsNode(OBJECT_VALUE, '/role/roleGrant[@xlink:href="/sys/xs/roles/dbms_auth.xml"]','xmlns="http://xmlns.oracle.com/xs xmlns:xlink="http://www.w3.org/1999/xlink"' ) = 1;

UPDATE xdb.xs$principals p 
SET OBJECT_VALUE= 
insertchildXML( OBJECT_VALUE,'/role','roleGrant',xmltype('<roleGrant xmlns="http://xmlns.oracle.com/xs" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/principal.xsd" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="/sys/xs/roles/dbms_passwd.xml"/>'), 'xmlns="http://xmlns.oracle.com/xs"') 
WHERE extractvalue(value(p), '/role/name') ='xspublic' AND
  NOT existsNode(OBJECT_VALUE, '/role/roleGrant[@xlink:href="/sys/xs/roles/dbms_passwd.xml"]','xmlns="http://xmlns.oracle.com/xs xmlns:xlink="http://www.w3.org/1999/xlink"' ) = 1;

UPDATE xdb.xs$principals p 
SET OBJECT_VALUE= 
insertchildXML( OBJECT_VALUE,'/role','roleGrant',xmltype('<roleGrant xmlns="http://xmlns.oracle.com/xs" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://xmlns.oracle.com/xs http://xmlns.oracle.com/xs/principal.xsd" xmlns:xlink="http://www.w3.org/1999/xlink" xlink:type="simple" xlink:href="/sys/xs/roles/midtier_auth.xml"/>'), 'xmlns="http://xmlns.oracle.com/xs"') 
WHERE extractvalue(value(p), '/role/name') ='xspublic' AND
  NOT existsNode(OBJECT_VALUE, '/role/roleGrant[@xlink:href="/sys/xs/roles/midtier_auth.xml"]','xmlns="http://xmlns.oracle.com/xs xmlns:xlink="http://www.w3.org/1999/xlink"' ) = 1;

-- update the UID to 2147484637 (in 10.2, it is 2147483649)
 UPDATE xdb.xs$principals p 
SET OBJECT_VALUE= 
updateXML( OBJECT_VALUE,'/role/UID/text()', 2147484637, 'xmlns="http://xmlns.oracle.com/xs"')
WHERE extractvalue(value(p), '/role/name') ='xspublic' AND
  existsNode(OBJECT_VALUE, '/role/UID' ) = 1;


Rem delete the xsguest user
begin
  dbms_xdb.deleteresource('/sys/xs/users/xsguest.xml',
                          DBMS_XDB.DELETE_RECURSIVE_FORCE);
end;
/

Rem Add the xsguest user
declare
tmp boolean := false;
XSGUESTXML BFILE := dbms_metadata_hack.get_xml_bfile('xsguest.xml.11.1');
XSGUESTXSD XMLTYPE := XMLTYPE(XSGUESTXML, 0);
begin
  tmp := DBMS_XDB.CreateResource('/sys/xs/users/xsguest.xml',XSGUESTXSD);
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
  if (NOT DBMS_XDB.existsResource('/sys/xs/roles/dbms_auth.xml'))
then
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/dbms_auth.xml',XSAUTHXSD);
end if;
end;
/

Rem Add the dbms_passwd role - uid set to KUSRMAX+995
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('dbms_passwd.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  if (NOT DBMS_XDB.existsResource('/sys/xs/roles/dbms_passwd.xml'))
then
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/dbms_passwd.xml',XSAUTHXSD);
end if;
end;
/

Rem Add the midtier_auth role - uid set to KUSRMAX+994
declare
tmp boolean := false;
XSAUTHXML BFILE := dbms_metadata_hack.get_xml_bfile('midtier_auth.xml.11.1');
XSAUTHXSD XMLTYPE := XMLTYPE(XSAUTHXML, 0);
begin
  if (NOT DBMS_XDB.existsResource('/sys/xs/roles/midtier_auth.xml'))
then
  tmp := DBMS_XDB.CreateResource('/sys/xs/roles/midtier_auth.xml',XSAUTHXSD);
end if;
end;
/

--set acl back
DECLARE
  tmp boolean := false;

  CURSOR c1 IS
   select u.prin_path p, u.acl_path a
   from upgradeacl u;
BEGIN
  FOR r1 IN c1 LOOP   
   DBMS_XDB.setACL(r1.p, r1.a);
  END LOOP;
END;
/

-- sanity check
--SELECT t.prin_path, r.any_path acl_path
--FROM
-- (SELECT r.any_path prin_path, extractValue(r.res,'/Resource/ACLOID') acloid   
--  FROM xdb.xs$principals p,resource_view r 
--  WHERE ref(p) = extractvalue(r.RES, '/Resource/XMLRef')) t, resource_view r 
--WHERE t.acloid = sys_op_r2o(extractValue(r.res, '/Resource/XMLRef'));

drop table upgradeacl;

commit;   
----------------------------------------------------------------------
REM 3. security class schema upgrades
----------------------------------------------------------------------

----------------------------------------------------------------------
REM 3.1 Backup table and Cleanup
REM     1) Delete old system securityclass doc
REM     2) Backup xdb.xs$securityclass table and drop index
REM     3) Purge recyclebin of xdb and drop the xdb.xs$securityclass table
REM     4) Delete the old schema
----------------------------------------------------------------------
execute dbms_xdb.deleteresource('/sys/xs/securityclasses/dav.xml');
execute dbms_xdb.deleteresource('/sys/xs/securityclasses/principalsc.xml');

create table upgradexs(
  any_path  varchar2(4000),
  sec_data XMLTYPE) 
XMLTYPE column sec_data store as CLOB;

-- Take backup of all data from XS$SECURITYCLASS
insert into upgradexs select r.any_path, p.SYS_NC_ROWINFO$ 
from resource_view r, xdb.XS$SECURITYCLASS p
where  ref(p) = extractvalue(r.RES, '/Resource/XMLRef');

-- Delete all security class documents from resource_view
DECLARE
  CURSOR c1 IS
    select /*+ index ( r XDB$RESOURCE_OID_INDEX ) */
           r.any_path p
    from resource_view r, xdb.XS$SECURITYCLASS p
    where  ref(p) = extractvalue(r.RES, '/Resource/XMLRef');
BEGIN
  FOR r1 IN c1 LOOP
    dbms_xdb.deleteresource(r1.p) ;
  END LOOP;
END;
/

-- Drop index, xs$securityclass table and purge recyclebin of xdb
--begin
  --execute immediate 'drop index xdb.sc_xidx';
  --exception 
  --when others then
    --NULL;
--end;
--/

begin
  execute immediate 'purge tablespace xdb user xdb';
  exception 
  when others then
    NULL;
end;
/

begin
  execute immediate 'drop table XDB.XS$SECURITYCLASS purge';
  exception 
  when others then
    NULL;
end;
/

-- Delete old security class schema
begin
  dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/securityclass.xsd',
                              dbms_xmlschema.delete_cascade_force);
end;
/

----------------------------------------------------------------------
REM 3.2 Register the new security class schema
----------------------------------------------------------------------
-- Register new schema
Rem Register security class schema
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

----------------------------------------------------------------------
REM 3.3 Post-upgrade
REM     1) Copy back the data to xdb.xs$securityclass table 
REM     2) Update the system security class documents
----------------------------------------------------------------------
-- Copy data back to XS$SECURITYCLASS table
DECLARE
  tmp boolean := false;

  CURSOR c1 IS
    select u.any_path p, u.sec_data r
    from upgradexs u;
BEGIN
  FOR r1 IN c1 LOOP
    tmp := dbms_xdb.createresource(r1.p, r1.r) ;
  END LOOP;
END;
/

-- Drop backup table
drop table upgradexs ;

--Recreate System Security Classes and move to separate files later.
Rem DAV::dav security class
declare
tmp boolean := false;
DAVXML BFILE := dbms_metadata_hack.get_xml_bfile('dav.xml.11.1');
DAVXSD XMLTYPE := XMLTYPE(DAVXML, 0);
begin 
  tmp := DBMS_XDB.CreateResource('/sys/xs/securityclasses/dav.xml',DAVXSD);
end;
/

declare
  tmp boolean := false;
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

/* New System Security Class */
Rem Add System Security Class
declare
tmp boolean := false;
SSCXML BFILE := dbms_metadata_hack.get_xml_bfile('xssystemsc.xml.11.1');
SSCXSD XMLTYPE := XMLTYPE(SSCXML, 0);
begin
  if (NOT DBMS_XDB.existsResource('/sys/xs/securityclasses/xssystemsc.xml')) then
  tmp := DBMS_XDB.CreateResource('/sys/xs/securityclasses/xssystemsc.xml',SSCXSD);
  end if;
end;
/

commit;
----------------------------------------------------------------------
REM 4. data security schema upgrades
----------------------------------------------------------------------
----------------------------------------------------------------------
REM 4.1. Backup the data security table to XDB.XS$DATA_SECURITY_11_1
----------------------------------------------------------------------
-- Drop backup table
-- drop table  XDB.XS$DATA_SECURITY_11_1;

-- Create backup table
--create table XDB.XS$DATA_SECURITY_11_1(
--  any_path  varchar2(4000),
--  ds_data XMLTYPE) ;

-- Take backup of all data from XS$DATA_SECURITY
--insert into XDB.XS$DATA_SECURITY_11_1 select r.any_path, p.SYS_NC_ROWINFO$
--from resource_view r, xdb.XS$DATA_SECURITY p
--where  ref(p) = extractvalue(r.RES, '/Resource/XMLRef');
----------------------------------------------------------------------
REM 4.2 cleanup: delete all data security documents and delete the old schema
----------------------------------------------------------------------
-- Data security schema has big changes. So we don't support the corresponding
-- document updates from the old DB. 
-- We don't keep the data security documents during upgrades and all data 
-- security documents have to be recreated by the customers according to the 
-- new schema.

-- Delete data from XS$DATA_SECURITY
DECLARE
  CURSOR c1 IS
    select r.any_path p
    from resource_view r, xdb.XS$DATA_SECURITY p
    where  ref(p) = extractvalue(r.RES, '/Resource/XMLRef');
BEGIN
  FOR r1 IN c1 LOOP
    dbms_xdb.deleteresource(r1.p) ;
  END LOOP;
END;
/

-- Delete old data security schema
begin
  dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xs/dataSecurity.xsd',
                              dbms_xmlschema.delete_cascade_force);
end;
/

----------------------------------------------------------------------
REM 4.3 Register the new data security schema
----------------------------------------------------------------------
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

commit;

----------------------------------------------------------------------
REM 5. Index creation for XS tables and misc.
----------------------------------------------------------------------
--Index creation for XS tables
--@@xsindex

delete from XDB.XS$CACHE_ACTIONS;

Rem add seed values for this table
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (1, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (2, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (3, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (4, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (5, systimestamp);
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) values (6, systimestamp);
-- The frasec field is used as retension  time. Set to 1 week 
insert into XDB.XS$CACHE_ACTIONS(ROW_KEY, TIME_VAL) 
                         values (9, TIMESTAMP '2007-10-04 13:02:43.000010080');
--ignore certain errors during upgrade for revoke lrg 3599584
BEGIN
   EXECUTE IMMEDIATE 'revoke select on XDB.XS$CACHE_ACTIONS from public';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -04042, -1927, -00942 ) THEN NULL;
     ELSE RAISE;
     END IF;
END;
/

drop public synonym XS$CACHE_ACTIONS;
-- we do not need the table contents; so drop and recreate
drop table XDB.XS$CACHE_DELETE;

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

-- Create and lock the XS$NULL user.
drop user XS$NULL cascade
/
create user XS$NULL identified by NO_PWD account lock password expire
/


