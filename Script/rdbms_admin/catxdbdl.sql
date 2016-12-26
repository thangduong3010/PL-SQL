Rem
Rem $Header: rdbms/admin/catxdbdl.sql /st_rdbms_11.2.0/1 2012/03/20 12:46:16 dmelinge Exp $
Rem
Rem catxdbdl.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbdl.sql - Setup script for document links support
Rem
Rem    DESCRIPTION
Rem          - Register xlink.xsd and XInclude.xsd
Rem          - Create DOCUMENT_LINKS view
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dmelinge    03/19/12 - Dont give PUBLIC more than select privs
Rem    badeoti     12/15/08 - avoid any_path like select from rv
Rem    mrafiq      06/29/07 - making it rerunnable
Rem    rmurthy     06/22/06 - register csx forms of xlink and xinclude schemas 
Rem    pnath       02/15/06 - remove link_props from document_links view 
Rem    rmurthy     02/06/06 - add document_links view 
Rem    rmurthy     06/02/06 - Created
Rem

Rem Register XLINK schema 
declare
  c number;
  schema_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_exists,-31085);
  XLINKXSD VARCHAR2(31000) :=
'<?xml version="1.0"?> 

<schema targetNamespace="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/2001/XMLSchema" xmlns:xlink="http://www.w3.org/1999/xlink" elementFormDefault="qualified">

  <attribute name="type">    
    <simpleType>       
      <restriction base="string">      

       <enumeration value="simple" />       
       <enumeration value="extended" />       
       <enumeration value="locator" />
       <enumeration value="arc" />
       <enumeration value="resource" />
       <enumeration value="title" />
       <enumeration value="none" />
      </restriction>
    </simpleType>
  </attribute>

  <attribute name="href" type="anyURI" />

  <attribute name="role" type="string" />

  <attribute name="arcrole" type="string" />

  <attribute name="title" type="string" />

  <attribute name="show">
    <simpleType>
      <restriction base="string">
       <enumeration value="new" />
       <enumeration value="replace" />
       <enumeration value="embed" />
       <enumeration value="other" />
       <enumeration value="none" />
      </restriction>
    </simpleType>
  </attribute>

  <attribute name="actuate">
   <simpleType>
    <restriction base="string">
     <enumeration value="onLoad" />
     <enumeration value="onRequest" />
     <enumeration value="other" />
     <enumeration value="none" />
    </restriction>
   </simpleType>
  </attribute>

  <attribute name="label" type="string" />

  <attribute name="from" type="string" />

  <attribute name="to" type="string" />
</schema>';

  XLINKURL VARCHAR2(2000) := 'http://www.w3.org/1999/xlink.xsd';
  CSX_XLINKURL VARCHAR2(2000) := 'http://www.w3.org/1999/csx.xlink.xsd';

begin

select count(*) into c 
from resource_view 
where equals_path(RES, '/sys/schemas/PUBLIC/www.w3.org/1999/xlink.xsd')=1; 

if c = 0 then
  xdb.dbms_xmlschema.registerSchema(XLINKURL, XLINKXSD, FALSE, TRUE, FALSE, TRUE,FALSE, 'XDB');
end if;

select count(*) into c 
from resource_view 
where equals_path(RES, '/sys/schemas/PUBLIC/www.w3.org/1999/csx.xlink.xsd')=1;

if c = 0 then
  xdb.dbms_xmlschema.registerSchema(CSX_XLINKURL, XLINKXSD, FALSE, FALSE, FALSE, TRUE,FALSE, 'XDB', options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end if;

exception
  when schema_exists then
    NULL;
end;
/

Rem Register XINCLUDE schema 
declare
  c number;
  schema_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(schema_exists,-31085);
  XINCLUDEXSD VARCHAR2(31000) :=
'<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude" targetNamespace="http://www.w3.org/2001/XInclude" finalDefault="extension">

  <xs:element name="include" type="xi:includeType" />

  <xs:complexType name="includeType" mixed="true">
    <xs:choice minOccurs="0" maxOccurs="unbounded" >
      <xs:element ref="xi:fallback" />
      <xs:any namespace="##other" processContents="lax" />
      <xs:any namespace="##local" processContents="lax" />
    </xs:choice>

    <xs:attribute name="href" use="optional" type="xs:anyURI"/>
    <xs:attribute name="parse" use="optional" default="xml" type="xi:parseType" />
    <xs:attribute name="xpointer" use="optional" type="xs:string"/>
    <xs:attribute name="encoding" use="optional" type="xs:string"/>
    <xs:attribute name="accept" use="optional" type="xs:string"/>
    <xs:attribute name="accept-language" use="optional" type="xs:string"/>
    <xs:anyAttribute namespace="##other" processContents="lax"/>
  </xs:complexType>

  <xs:simpleType name="parseType">
    <xs:restriction base="xs:token">
      <xs:enumeration value="xml"/>
      <xs:enumeration value="text"/>
    </xs:restriction>
  </xs:simpleType>

  <xs:element name="fallback" type="xi:fallbackType" />

  <xs:complexType name="fallbackType" mixed="true">
    <xs:choice minOccurs="0" maxOccurs="unbounded">
      <xs:element ref="xi:include"/>
      <xs:any namespace="##other" processContents="lax"/>
      <xs:any namespace="##local" processContents="lax"/>
    </xs:choice>
    <xs:anyAttribute namespace="##other" processContents="lax" />
  </xs:complexType>

</xs:schema>';

  XINCLUDEURL VARCHAR2(2000) := 'http://www.w3.org/2001/XInclude.xsd'; 
  CSX_XINCLUDEURL VARCHAR2(2000) := 'http://www.w3.org/2001/csx.XInclude.xsd'; 

begin

select count(*) into c 
from resource_view 
where equals_path(RES, '/sys/schemas/PUBLIC/www.w3.org/2001/XInclude.xsd')=1;

if c = 0 then 
  xdb.dbms_xmlschema.registerSchema(XINCLUDEURL, XINCLUDEXSD, FALSE, TRUE, FALSE, TRUE,FALSE, 'XDB');
end if;

select count(*) into c 
from resource_view 
where equals_path(RES, '/sys/schemas/PUBLIC/www.w3.org/2001/csx.XInclude.xsd')=1;

if c = 0 then
  xdb.dbms_xmlschema.registerSchema(CSX_XINCLUDEURL, XINCLUDEXSD, FALSE, FALSE, FALSE, TRUE, FALSE, 'XDB', options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end if;

exception
  when schema_exists then
    NULL;
end;
/


Rem DOCUMENT_LINKS VIEW
create or replace view XDB.DOCUMENT_LINKS 
(source_id, 
target_id, 
target_path, 
link_type, 
link_form, 
source_type) as 
SELECT 
dl.source_id, 
dl.target_id, 
dl.target_path, 
decode(bitand(sys_op_rawtonum(dl.flags),1),1, 'Weak', 
       decode(bitand(sys_op_rawtonum(dl.flags),2),2,'Symbolic','Hard')),
decode(bitand(sys_op_rawtonum(dl.flags),4),4, 'XInclude', 'XLink'),
decode(bitand(sys_op_rawtonum(dl.flags),8),8, 'Resource Metadata', 
       'Resource Content')
from xdb.xdb$d_link dl, xdb.xdb$resource r
where dl.source_id = r.object_id 
and sys_checkacl(r.xmldata.acloid, r.xmldata.ownerid, 
xmltype('<privilege
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd
                          http://xmlns.oracle.com/xdb/acl.xsd
                          DAV: http://xmlns.oracle.com/xdb/dav.xsd">
      <read-properties/>
      <read-contents/>
 </privilege>')) = 1;

show errors;

create or replace public synonym document_links for xdb.document_links;
grant select on xdb.document_links to public ; 

