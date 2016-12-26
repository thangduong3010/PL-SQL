Rem
Rem $Header: rdbms/admin/catxdbz0.sql /main/9 2009/02/05 15:23:57 spetride Exp $
Rem
Rem catxdbz0.sql
Rem
Rem Copyright (c) 2005, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbz0.sql - xdb security initialization
Rem
Rem    DESCRIPTION
Rem      This script registers all required system schemas before 
Rem      initXDBSecurity() can be called.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    06/11/08 - 11.2 acl schema
Rem    thbaby      12/06/07 - set acl on schemas created pre-security
Rem    vkapoor     05/08/07 - bug 5769835
Rem    sidicula    12/19/06 - Avoid xmltable in xds_acl view
Rem    bkhaladk    04/24/06 - add CSX xml.xsd and xmltr.xsd schema 
Rem    petam       04/14/06 - fix xds_acl and xds_ace views 
Rem    petam       04/07/06 - separate out the install of ResConfig 
Rem    abagrawa    03/11/06 - Use acl.xsd in registerschema 
Rem    thbaby      03/12/06 - csx fix - principal not transient 
Rem    petam       02/08/06 - add ACL and ACE views 
Rem    petam       12/07/05 - acl enhancement for fusion security 
Rem    mrafiq      09/22/05 - merging changes for upgrade/downgrade
Rem    thoang      03/01/05 - Created
Rem

Rem Register ACL Schema

-- Create directory for picking up schemas
exec dbms_metadata_hack.cre_dir;

-- Register the CSX xml.xsd
declare
  XMLNSXSD BFILE := dbms_metadata_hack.get_bfile('xmlcsx.xsd.11.0');
  XMLNSURL VARCHAR2(2000) := 'http://www.w3.org/2001/csx.xml.xsd';  
begin
  xdb.dbms_xmlschema.registerSchema(XMLNSURL, XMLNSXSD, FALSE, FALSE, FALSE, 
		                    TRUE, FALSE, 'XDB', 
                                   options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end;
/

declare
  TRXSD BFILE := dbms_metadata_hack.get_bfile('xmltr.xsd.11.0');
  TRURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/csx.xmltr.xsd';  
begin
  xdb.dbms_xmlschema.registerSchema(TRURL, TRXSD, FALSE, FALSE, FALSE, TRUE,
                                    FALSE, 'XDB', 
                                 options => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end;
/

declare
  ACLXSD BFILE := dbms_metadata_hack.get_bfile('acl.xsd.11.2');
  ACLURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/acl.xsd';  
begin
xdb.dbms_xmlschema.registerSchema(ACLURL, ACLXSD, FALSE, FALSE, FALSE, TRUE,
                                  FALSE, 'XDB', 
                                 options => DBMS_XMLSCHEMA.REGISTER_BINARYXML);

end;
/

-- Disable XRLS hierarchy priv check for xdb$acl and xdb$schema tables
BEGIN
   xdb.dbms_xdbz.disable_hierarchy('XDB', 'XDB$ACL');
   xdb.dbms_xdbz.disable_hierarchy('XDB', 'XDB$SCHEMA');
END;
/
  
-- INSERT bootstrap AND root acl's   
DECLARE 
  b_abspath          VARCHAR2(200);
  b_data             VARCHAR2(2000);
  r_abspath          VARCHAR2(200);
  r_data             VARCHAR2(2000);
  o_abspath          VARCHAR2(200);
  o_data             VARCHAR2(2000);
  ro_abspath         VARCHAR2(200);
  ro_data            VARCHAR2(2000);
  retbool            BOOLEAN;
BEGIN
   b_abspath := '/sys/acls/bootstrap_acl.xml';
   b_data := 
'<acl description="Protected:Readable by PUBLIC and all privileges to OWNER"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" xmlns:dav="DAV:"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd 
                          http://xmlns.oracle.com/xdb/acl.xsd">
  <ace> 
    <grant>true</grant>
    <principal>dav:owner</principal>
    <privilege>
      <all/>
    </privilege>
  </ace> 
  <ace> 
    <grant>true</grant>
    <principal>XDBADMIN</principal>
    <privilege>
      <all/>
    </privilege>
  </ace> 
  <ace> 
    <grant>true</grant>
    <principal>PUBLIC</principal>
    <privilege>
      <read-properties/>
      <read-contents/>
      <read-acl/>
      <resolve/>
    </privilege>
  </ace>
</acl>';
   
   r_abspath := '/sys/acls/all_all_acl.xml';
   r_data := 
'<acl description="Public:All privileges to PUBLIC"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd  
                          http://xmlns.oracle.com/xdb/acl.xsd"> 
  <ace> 
    <grant>true</grant>
    <principal>PUBLIC</principal>
    <privilege>
      <all/>
    </privilege>
  </ace>
</acl>';
   
   o_abspath := '/sys/acls/all_owner_acl.xml';
   o_data := 
'<acl description="Private:All privileges to OWNER only and not accessible to others"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" xmlns:dav="DAV:"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd 
                          http://xmlns.oracle.com/xdb/acl.xsd"> 
  <ace> 
    <grant>true</grant>
    <principal>dav:owner</principal>
    <privilege>
      <all/>
    </privilege>
  </ace>
</acl>';
   
   ro_abspath := '/sys/acls/ro_all_acl.xml';
   ro_data := 
'<acl description="Read-Only:Readable by all and writeable by none"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd  
                          http://xmlns.oracle.com/xdb/acl.xsd">
  <ace> 
    <grant>true</grant>
    <principal>PUBLIC</principal>
    <privilege>
      <read-properties/>
      <read-contents/>
      <read-acl/>
      <resolve/>
    </privilege>
  </ace>
</acl>';
   
   retbool := dbms_xdb.createresource(b_abspath, b_data);
   retbool := dbms_xdb.createresource(r_abspath, r_data);
   retbool := dbms_xdb.createresource(o_abspath, o_data);
   retbool := dbms_xdb.createresource(ro_abspath, ro_data);
END;
/
  
declare 
   tablename     varchar2(2000);
   sqlstatement  varchar2(2000);
begin
   select e.xmldata.default_table into tablename from xdb.xdb$element e where e.xmldata.property.parent_schema = ( select ref(s) from xdb.xdb$schema s where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/acl.xsd') and e.xmldata.property.name = 'acl';

   tablename := 'xdb.' || '"' || tablename || '"';

   sqlstatement := 'update xdb.xdb$resource r set r.xmldata.acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$acl set acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$schema set acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$h_index set acl_id = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$h_link set child_acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where extractvalue(e.object_value, ''/acl/@description'') like ''Protected%'')';
   execute immediate sqlstatement;
end;
/

commit;

-- Insert a row into xdbready to indicate ACLs are available
insert into xdb.xdb$xdb_ready values (null);
commit;

create or replace view XDS_ACL
  (ACLID, SHARED, DESCRIPTION, SECURITY_CLASS_NS, 
   SECURITY_CLASS_NAME, PARENT_ACL_PATH, INHERITANCE_TYPE)
as 
select a.object_id, 
       substr(extractvalue(a.object_value, '/acl/@shared', 
                           'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
              1, 5), 
       extractvalue(a.object_value, '/acl/@description', 
                    'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
       xmlquery('declare namespace a="http://xmlns.oracle.com/xdb/acl.xsd"; fn:namespace-uri-from-QName(fn:data(/a:acl/a:security-class))' PASSING OBJECT_VALUE returning content),
       xmlquery('declare namespace a="http://xmlns.oracle.com/xdb/acl.xsd"; fn:local-name-from-QName(fn:data(/a:acl/a:security-class))' PASSING OBJECT_VALUE returning content),
       CASE existsNode(a.object_value, '/acl/extends-from', 
                       'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN extractvalue(a.object_value, '/acl/extends-from/@href', 
                         'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
       ELSE (CASE existsNode(a.object_value, '/acl/constrained-with', 
                             'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') 
             WHEN 1 
             THEN extractvalue(a.object_value, '/acl/constrained-with/@href', 
                               'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
             ELSE NULL END) END, 
       CASE existsNode(a.object_value, '/acl/extends-from', 
                       'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN 'extends-from'
       ELSE (CASE existsNode(a.object_value, '/acl/constrained-with', 
                             'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') 
             WHEN 1 
             THEN 'constrained-with'
             ELSE NULL END) END 
FROM XDB.XDB$ACL a;

create or replace public synonym XDS_ACL for XDS_ACL;

grant select on XDS_ACL to PUBLIC;

comment on table XDS_ACL is
'All ACLs that are visible to the current user in the database'
/

comment on column XDS_ACL.ACLID is
'The ACL ID of an ACL'
/
comment on column XDS_ACL.SHARED is
'Whether this ACL is shared or not'
/

comment on column XDS_ACL.DESCRIPTION is
'The ACL description'
/

comment on column XDS_ACL.SECURITY_CLASS_NS is
'The namespace of the Security Class'
/

comment on column XDS_ACL.SECURITY_CLASS_NAME is
'The name of the Security Class'
/

comment on column XDS_ACL.PARENT_ACL_PATH is
'The path of its parent ACL'
/

comment on column XDS_ACL.INHERITANCE_TYPE is
'The inhertance type, i.e. constrained-with or extends-from'
/

create or replace view XDS_ACE
  (ACLID, START_DATE, END_DATE, IS_GRANT, 
   INVERT, PRINCIPAL, PRIVILEGE)
as 
select a.object_id, 
       extractvalue(value(b), '/ace/@start_date', 
                    'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
       extractvalue(value(b), '/ace/@end_date', 
                    'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
       substr(extractvalue(value(b), '/ace/grant', 
                           'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
              1, 5), 
       CASE existsNode(value(b), '/ace/invert', 
                      'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN 'true'
       ELSE 'false' END, 
       CASE existsNode(value(b), '/ace/invert', 
                       'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN extractvalue(value(b), '/ace/invert/principal', 
                         'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
       ELSE extractvalue(value(b), '/ace/principal', 
                         'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') END, 
       extract(value(b), '/ace/privilege', 
               'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
from xdb.xdb$acl a, 
     table(XMLSequence(extract(a.object_value, '/acl/ace'))) b;

create or replace public synonym XDS_ACE for XDS_ACE;

grant select on XDS_ACE to PUBLIC; 

comment on table XDS_ACE is
'All ACEs in ACLs that are visible to the current user in the database'
/

comment on column XDS_ACE.ACLID is
'The ACL ID of an ACL'
/

comment on column XDS_ACE.START_DATE is
'The start_date attribute of the ACE'
/

comment on column XDS_ACE.END_DATE is
'The end_date attribute of the ACE'
/

comment on column XDS_ACE.IS_GRANT is
'true if this is a grant ACE, false otherwise'
/

comment on column XDS_ACE.INVERT is
'true if this ACE contains invert principal, false otherwise'
/

comment on column XDS_ACE.PRINCIPAL is
'The principal in this ACE'
/

comment on column XDS_ACE.PRIVILEGE is
'The privileges in this ACE'
/

commit;
