Rem
Rem $Header: rdbms/admin/catxdbst.sql /main/22 2009/04/06 20:28:13 badeoti Exp $
Rem
Rem catxdbstd.sql
Rem
Rem Copyright (c) 2001, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbstd.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     03/20/09 - remove public synonyms for XDB internal packages
Rem    spetride    10/22/08 - add app users and groups virtual folders
Rem    rmurthy     01/17/05 - add path for symbolic links 
Rem    rmurthy     01/10/05 - add link type 
Rem    bkhaladk    04/24/06 - add clob version of xmltr.xsd 
Rem    thbaby      08/30/05 - add version virtual folder
Rem    thbaby      04/21/05 - 
Rem    pnath       12/01/04 - prvtxdb.sql needs prvtxmld.sql to be compiled 
Rem    rmurthy     10/29/03 - enable asm folder 
Rem    rmurthy     08/28/03 - uncomment oid folder 
Rem    sichandr    04/06/03 - add folder listing schema
Rem    spannala    12/19/02 - fixing bug#2702653
Rem    rmurthy     01/13/03 - create OSM virtual folder
Rem    rmurthy     10/07/02 - create system virtual folders
Rem    rmurthy     03/26/02 - add XML Namespace schema
Rem    rmurthy     12/28/01 - set elementForm to qualified
Rem    rmurthy     12/17/01 - TEMP: change dateTime to date
Rem    rmurthy     12/17/01 - fix schemas
Rem    spannala    12/27/01 - xdb setup should run as sys
Rem    tsingh      11/26/01 - use .plb for prvtxmld, prvtxmlp, prvtxslp
Rem    nagarwal    11/05/01 - correct names for path view
Rem    nagarwal    10/31/01 - move path view schema def into standard
Rem    sidicula    10/02/01 - XDB Logging
Rem    nmontoya    08/30/01 - ADD pl/sql dom, xml parser, AND xsl processor
Rem    rmurthy     09/03/01 - change XDB namespace
Rem    esedlar     08/13/01 - Merged esedlar_http
Rem    esedlar     08/09/01 - Created
Rem
  
declare
 STDURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/XDBStandard.xsd';  
 XLURL VARCHAR2(2000) :=
  'http://xmlns.oracle.com/xdb/log/xdblog.xsd';
 FLURL VARCHAR2(2000) :=
  'http://xmlns.oracle.com/xdb/log/ftplog.xsd';
 HLURL VARCHAR2(2000) :=
  'http://xmlns.oracle.com/xdb/log/httplog.xsd';

 STDXSD VARCHAR2(4000) :=
'<schema xmlns="http://www.w3.org/2001/XMLSchema"       
        targetNamespace="http://xmlns.oracle.com/xdb/XDBStandard"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
        version="1.0" elementFormDefault="qualified">

  <element name="servlet" xdb:SQLType="SERVLET_T" xdb:defaultTable="SERVLET">
    <complexType>
      <sequence>
        <element name="icon" type="string" minOccurs="0"/>
        <element name="servlet-name" type="string"/>
        <element name="servlet-language">
          <simpleType>
            <restriction base="string">
              <enumeration value="C"/>
              <enumeration value="Java"/>
              <enumeration value="PL/SQL"/>
            </restriction>
          </simpleType>
        </element>
        <element name="display-name" type="string" minOccurs="0"/>
        <element name="description" type="string" minOccurs="0"/>
        <choice>
          <element name="servlet-class" type="string"/>
          <element name="jsp-file" type="string"/>
        </choice>
        <element name="servlet-schema" type="string" minOccurs="0"/>
        <element name="load-on-startup" type="string" minOccurs="0"/>
        <element name="security-role-ref" minOccurs="0" maxOccurs="65535">
          <complexType>
            <sequence>
              <element name="description" type="string" minOccurs="0"/>
              <element name="role-name" type="string"/>
              <element name="role-link" type="string"/>
            </sequence>
          </complexType>
        </element>
      </sequence>
    </complexType>
  </element>

  <element name = "LINK" xdb:SQLType="XDB_LINK_TYPE" xdb:SQLSchema="XDB" xdb:defaultTable="">
   <complexType>
    <sequence>
     <element name="ParentName">
       <simpleType>
         <restriction base = "string">
           <length value = "256"/>
         </restriction>
       </simpleType>
     </element>
     <element name="ChildName">
       <simpleType>
         <restriction base = "string">
           <length value = "1024"/>
         </restriction>
       </simpleType> 
     </element>
     <element name= "Name">
       <simpleType>
         <restriction base = "string">
           <length value = "256"/>
         </restriction>
       </simpleType>
     </element>
     <element name= "Flags">
       <simpleType>
         <restriction base = "base64Binary">
           <length value = "4"/>
         </restriction>
       </simpleType>
     </element>
     <element name="ParentOid">
       <simpleType>
         <restriction base = "base64Binary">
           <length value = "16"/>
         </restriction>
       </simpleType>
     </element>
     <element name="ChildOid">
       <simpleType>
         <restriction base = "base64Binary">
           <length value = "16"/>
         </restriction>
       </simpleType>
    </element>
    <element name="LinkType">
      <simpleType>
        <restriction base="string">
          <enumeration value="Hard"/>
          <enumeration value="Weak"/>
          <enumeration value="Symbolic"/>
        </restriction>
      </simpleType>
    </element>
    </sequence>
   </complexType>
  </element>

</schema>';

 XLXSD VARCHAR2(4000) :=
'<schema
targetNamespace="http://xmlns.oracle.com/xdb/log"
     xmlns="http://www.w3.org/2001/XMLSchema"
     xmlns:xdb="http://xmlns.oracle.com/xdb"
     xmlns:xl="http://xmlns.oracle.com/xdb/log"
     version="1.0" elementFormDefault="qualified">

<complexType name="xdb-log-entry-type">
  <sequence>
    <!-- TODO: Need to change to enumerated types -->
    <!-- TEMP : change date to dateTime -->
    <element name="Date-and-Time" type="date"/>
    <element name="Module" type="string"/> <!-- XDBCORE, FTP or HTTP -->
    <element name="Description" type="string"/>
    <element name="User-ID" type="string"/> <!-- eg., SCOTT -->
    <element name="Type" type="string"/> <!-- ERROR, WARNING, INFO or DEBUG -->
  </sequence>
</complexType>

<element name="xdb-log">
<complexType>
  <sequence>
    <element name="xdb-log-entry" type="xl:xdb-log-entry-type" 
             maxOccurs="unbounded"/>
  </sequence>
</complexType>
</element>

</schema>';

FLXSD VARCHAR2(4000) :=
 '<schema
 targetNamespace="http://xmlns.oracle.com/xdb/log"
     xmlns="http://www.w3.org/2001/XMLSchema"
     xmlns:xdb="http://xmlns.oracle.com/xdb"
     xmlns:xl="http://xmlns.oracle.com/xdb/log"
     version="1.0" elementFormDefault="qualified">

<complexType name="ftp-log-entry-type">
  <sequence>      
      <!-- TODO: Need to change to enumerated types -->
      <element name="Date-and-Time" type="date"/>
      <element name="Module" type="string"/> <!-- XDBCORE, FTP or HTTP -->
      <element name="Description" type="string"/>
      <element name="User-ID" type="string"/> <!-- eg., SCOTT -->
      <element name="Type" type="string"/> <!-- ERROR, WARNING, INFO or 
                                                DEBUG -->
      <element name="Client-IP" type="string"/>
      <element name="Request-Command" type="string"/>
      <element name="Response">
        <complexType> <sequence>
          <element name="Code" type="string"/> <!-- eg., "200" -->
          <element name="Message" type="string"/> <!-- eg., "PORT command 
                                                            successful" -->
        </sequence> </complexType>
      </element>
  </sequence>
</complexType>

<element name="ftp-log">
<complexType>
  <sequence>
    <element name="ftp-log-entry" type="xl:ftp-log-entry-type" 
             maxOccurs="unbounded"/>
  </sequence>
</complexType>
</element>

</schema>';

HLXSD VARCHAR2(4000) :=
 '<schema
targetNamespace="http://xmlns.oracle.com/xdb/log"
     xmlns="http://www.w3.org/2001/XMLSchema"
     xmlns:xdb="http://xmlns.oracle.com/xdb"
     xmlns:xl="http://xmlns.oracle.com/xdb/log"
     version="1.0" elementFormDefault="qualified">

<complexType name="http-log-entry-type">
    <sequence>
      <!-- TODO: Need to change to enumerated types -->
      <element name="Date-and-Time" type="date"/>
      <element name="Module" type="string"/> <!-- XDBCORE, FTP or HTTP -->
      <element name="Description" type="string"/>
      <element name="User-ID" type="string"/> <!-- eg., SCOTT -->
      <element name="Type" type="string"/> <!-- ERROR, WARNING, INFO or 
                                                DEBUG -->
      <element name="Client-IP" type="string"/>
      <element name="Request">
        <complexType> <sequence>
          <element name="Method" type="string"/> <!-- eg., "GET" -->
          <element name="Resource-Path" type="string"/> <!-- eg., "/file1" -->
          <element name="Version" type="string"/> <!-- 1.0 or 1.1 -->
          <element name="Headers" type="string"/>
          <element name="Body" type="base64Binary"/>
        </sequence> </complexType>
      </element>
      <element name="Response">
        <complexType> <sequence>
          <element name="Code" type="string"/> <!-- eg., "404" -->
          <element name="Message" type="string"/> <!-- eg., "Not found" -->
          <element name="Headers" type="string"/>
          <element name="Body" type="base64Binary"/>
        </sequence> </complexType>
      </element>
    </sequence>
</complexType>

<element name="http-log">
<complexType>
  <sequence>
    <element name="http-log-entry" type="xl:http-log-entry-type" 
             maxOccurs="unbounded"/>
  </sequence>
</complexType>
</element>

</schema>';

begin

xdb.dbms_xmlschema.registerSchema(STDURL, STDXSD, FALSE, TRUE, FALSE, TRUE, FALSE, 'XDB');
xdb.dbms_xmlschema.registerSchema(XLURL, XLXSD, FALSE, TRUE, FALSE, TRUE, FALSE, 'XDB');
xdb.dbms_xmlschema.registerSchema(FLURL, FLXSD, FALSE, TRUE, FALSE, TRUE, FALSE, 'XDB');
xdb.dbms_xmlschema.registerSchema(HLURL, HLXSD, FALSE, TRUE, FALSE, TRUE, FALSE, 'XDB');

end;
/


Rem Register XML Namespace schema 
declare
  XMLNSXSD VARCHAR2(31000) :=
'<?xml version="1.0"?>
<xs:schema targetNamespace="http://www.w3.org/XML/1998/namespace" 
           xmlns:xs="http://www.w3.org/2001/XMLSchema" xml:lang="en">
   <xs:annotation>
      <xs:documentation>
          See http://www.w3.org/XML/1998/namespace.html and
          http://www.w3.org/TR/REC-xml for information about this namespace.
      </xs:documentation>
   </xs:annotation>

   <xs:annotation>
      <xs:documentation>
          This schema defines attributes and an attribute group
          suitable for use by schemas wishing to allow xml:base, 
          xml:lang or xml:space attributes on elements they define.
          To enable this, such a schema must import this schema
          for the XML namespace.
          import namespace="http://www.w3.org/XML/1998/namespace"
                 schemaLocation="http://www.w3.org/2001/xml.xsd"
          Subsequently, qualified reference to any of the attributes
          or the group defined below will have the desired effect.
      </xs:documentation>
   </xs:annotation>

   <xs:attribute name="lang" type="xs:language">
       <xs:annotation>
           <xs:documentation>
               In due course, we should install the relevant ISO 
               2- and 3-letter codes as the enumerated possible values...
           </xs:documentation>
       </xs:annotation>
    </xs:attribute>
        
    <xs:attribute name="space" default="preserve">
       <xs:simpleType>
          <xs:restriction base="xs:NCName"> 
             <xs:enumeration value="default"/>
             <xs:enumeration value="preserve"/>
          </xs:restriction>
        </xs:simpleType>
    </xs:attribute>
        
    <xs:attribute name="base" type="xs:anyURI">
       <xs:annotation>
          <xs:documentation>
               See http://www.w3.org/TR/xmlbase/ for information about this attribute.
          </xs:documentation>
       </xs:annotation>
    </xs:attribute>
        
    <xs:attributeGroup name="specialAttrs">
        <xs:attribute ref="xml:base"/>
        <xs:attribute ref="xml:lang"/>
        <xs:attribute ref="xml:space"/>
    </xs:attributeGroup>
</xs:schema>';

  XMLNSURL VARCHAR2(2000) := 'http://www.w3.org/2001/xml.xsd';

begin

xdb.dbms_xmlschema.registerSchema(XMLNSURL, XMLNSXSD, FALSE, TRUE, FALSE, TRUE,
                                  FALSE, 'XDB');

end;
/

declare
  TRXSD BFILE := dbms_metadata_hack.get_bfile('xmltr.xsd.11.0');
  TRURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/xmltr.xsd';  
begin
  xdb.dbms_xmlschema.registerSchema(TRURL, TRXSD, FALSE, FALSE, FALSE, FALSE,
                                    FALSE, 'XDB');
end;
/

-- create OID virtual folder 
declare
ret boolean;
begin
  ret := xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/oid');
  if ret then
    dbms_xdb.setacl('/sys/oid', '/sys/acls/bootstrap_acl.xml');
  end if;
end;
/
commit;

-- Create the folder /sys/apps
DECLARE
  retval BOOLEAN;
BEGIN
  retval := DBMS_XDB.CREATEFOLDER('/sys/apps');
  IF retval THEN
   DBMS_XDB.SETACL('/sys/apps', '/sys/acls/bootstrap_acl.xml');
  END IF;
END;
/
commit;

Rem create ASM virtual folder
declare
ret boolean;
begin
 ret := xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/asm');
 if ret then
   dbms_xdb.setACL('/sys/asm', '/sys/acls/all_owner_acl.xml');
 end if;
end;
/
commit;

Rem create all folders associated with users and groups
declare
ret boolean;
begin
  ret := dbms_xdb.createFolder('/sys/principals');
  if ret then
    dbms_xdb.setACL('/sys/principals', '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := dbms_xdb.createFolder('/sys/principals/users');
  if ret then
    dbms_xdb.setACL('/sys/principals/users', '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := dbms_xdb.createFolder('/sys/principals/groups');
  if ret then
    dbms_xdb.setACL('/sys/principals/groups', '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/users/db');
  if ret then
    dbms_xdb.setACL('/sys/principals/users/db', '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/users/ldap');
  if ret then
    dbms_xdb.setACL('/sys/principals/users/ldap', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/users/application');
  if ret then
    dbms_xdb.setACL('/sys/principals/users/application', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/groups/db');
  if ret then
    dbms_xdb.setACL('/sys/principals/groups/db', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/groups/ldap');
  if ret then
    dbms_xdb.setACL('/sys/principals/groups/ldap', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;

  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/principals/groups/application');
  if ret then
    dbms_xdb.setACL('/sys/principals/groups/application', 
                    '/sys/acls/bootstrap_acl.xml');
  end if;
end;
/
commit;

Rem Create virtual folder for acl oids
declare
ret boolean;
begin
  ret := 
    xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/acloids');
  if ret then
    dbms_xdb.setACL('/sys/acloids', '/sys/acls/bootstrap_acl.xml');
 end if;
end;
/
commit;

Rem create version virtual folder
declare
ret boolean;
begin
 ret := xdb.dbms_xdbutil_int.createSystemVirtualFolder('/sys/version');
 if ret then
   dbms_xdb.setACL('/sys/version', '/sys/acls/bootstrap_acl.xml');
 end if;
end;
/
commit;

Rem Create the schema for folder listings. This is used for representing
Rem folder listings with name and size of each entry. Its not intended
Rem as a schema for folders - merely as a simple schema for listings.

declare
  FLXSD VARCHAR2(4000) :=
  '<schema 
     targetNamespace="http://xmlns.oracle.com/xdb/XDBFolderListing.xsd"
     xmlns="http://www.w3.org/2001/XMLSchema"
     xmlns:xdb="http://xmlns.oracle.com/xdb"
     xmlns:l="http://xmlns.oracle.com/xdb/XDBFolderListing.xsd"
     version="1.0" elementFormDefault="qualified">

    <complexType name="ListingTyp">
      <sequence>
        <element name="ChildName" type="string" maxOccurs="unbounded"/>
      </sequence>
      <attribute name="name" type="string"/>
      <attribute name="size" type="integer"/>
    </complexType>

    <element name="Folder" type="l:ListingTyp"/>

   </schema>';

  FLURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/XDBFolderListing.xsd';

begin

xdb.dbms_xmlschema.registerSchema(FLURL, FLXSD, FALSE, TRUE, FALSE, TRUE, FALSE, 'XDB');

end;
/

