Rem
Rem $Header: mgdmeta.sql 18-jul-2006.06:53:24 hgong Exp $
Rem
Rem mgdmeta.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      mgdmeta.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       07/12/06 - add version and uri info to EPC category 
Rem    hgong       05/15/06 - move tag data translation schema and xml file 
Rem                           contents to mgdmeta.sql 
Rem    hgong       05/12/06 - fix load metadata to work for all platforms and 
Rem                           ade 
Rem    hgong       04/04/06 - changed xml directory 
Rem    hgong       03/31/06 - load metadata 
Rem    hgong       03/31/06 - load metadata 
Rem    hgong       03/31/06 - Created
Rem


DECLARE
  amt          NUMBER;
  buf          VARCHAR2(32767);
  pos          NUMBER;
  seq          BINARY_INTEGER;
  tdt_xml      CLOB;

BEGIN
  --store tdt schema into a one column, one row table 
  DELETE FROM mgd_id_xml_validator;

  INSERT INTO mgd_id_xml_validator VALUES(empty_clob())
    RETURNING xsd_schema into tdt_xml;

   DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
   buf := '<?xml version="1.0" encoding="UTF-8"?>
<xsd:schema targetNamespace="oracle.mgd.idcode"
            xmlns:xsd="http://www.w3.org/2001/XMLSchema"
            xmlns:tdt="oracle.mgd.idcode" elementFormDefault="unqualified"
            attributeFormDefault="unqualified" version="1.0">
  <xsd:annotation>
    <xsd:documentation>
      <![CDATA[
<epcglobal:copyright>Copyright ?2004 Epcglobal Inc., All Rights
Reserved.</epcglobal:copyright>
<epcglobal:disclaimer>EPCglobal Inc., its members, officers, directors,
employees, or agents shall not be liable for any injury, loss, damages,
financial or otherwise, arising from, related to, or caused by the use of this
document. The use of said document shall constitute your express consent to
the foregoing exculpation.</epcglobal:disclaimer>
<epcglobal:specification>Tag Data Translation (TDT) version
1.0</epcglobal:specification>
]]>
    </xsd:documentation>
  </xsd:annotation>
  <xsd:simpleType name="LevelTypeList">
    <xsd:restriction base="xsd:string">
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="TagLengthList">
    <xsd:restriction base="xsd:string">
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="SchemeNameList">
    <xsd:restriction base="xsd:string">
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="InputFormatList">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="BINARY"/>
      <xsd:enumeration value="STRING"/>
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="ModeList">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="EXTRACT"/>
      <xsd:enumeration value="FORMAT"/>
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="CompactionMethodList">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="32-bit"/>
      <xsd:enumeration value="16-bit"/>
      <xsd:enumeration value="8-bit"/>
      <xsd:enumeration value="7-bit"/>
      <xsd:enumeration value="6-bit"/>
      <xsd:enumeration value="5-bit"/>
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:simpleType name="PadDirectionList">
    <xsd:restriction base="xsd:string">
      <xsd:enumeration value="LEFT"/>
      <xsd:enumeration value="RIGHT"/>
    </xsd:restriction>
  </xsd:simpleType>
  <xsd:complexType name="Field">
    <xsd:attribute name="seq" type="xsd:integer" use="required"/>
    <xsd:attribute name="name" type="xsd:string" use="required"/>
    <xsd:attribute name="bitLength" type="xsd:integer"/>
    <xsd:attribute name="characterSet" type="xsd:string" use="required"/>
    <xsd:attribute name="compaction" type="tdt:CompactionMethodList"/>
    <xsd:attribute name="compression" type="xsd:string"/>
    <xsd:attribute name="padChar" type="xsd:string"/>
    <xsd:attribute name="padDir" type="tdt:PadDirectionList"/>
    <xsd:attribute name="decimalMinimum" type="xsd:long"/>
    <xsd:attribute name="decimalMaximum" type="xsd:long"/>
    <xsd:attribute name="length" type="xsd:integer"/>
  </xsd:complexType>
  <xsd:complexType name="Option">
    <xsd:sequence>
      <xsd:element name="field" type="tdt:Field" maxOccurs="unbounded"/>
    </xsd:sequence>
    <xsd:attribute name="optionKey" type="xsd:string" use="required"/>
    <xsd:attribute name="pattern" type="xsd:string"/>
    <xsd:attribute name="grammar" type="xsd:string" use="required"/>
  </xsd:complexType>
  <xsd:complexType name="Rule">
    <xsd:attribute name="type" type="tdt:ModeList" use="required"/>
    <xsd:attribute name="inputFormat" type="tdt:InputFormatList"
                   use="required"/>
    <xsd:attribute name="seq" type="xsd:integer" use="required"/>
    <xsd:attribute name="newFieldName" type="xsd:string" use="required"/>
    <xsd:attribute name="characterSet" type="xsd:string" use="required"/>
    <xsd:attribute name="padChar" type="xsd:string"/>
    <xsd:attribute name="padDir" type="tdt:PadDirectionList"/>
    <xsd:attribute name="decimalMinimum" type="xsd:long"/>
    <xsd:attribute name="decimalMaximum" type="xsd:long"/>
    <xsd:attribute name="length" type="xsd:string"/>
    <xsd:attribute name="function" type="xsd:string" use="required"/>
    <xsd:attribute name="tableURI" type="xsd:string"/>
    <xsd:attribute name="tableParams" type="xsd:string"/>
    <xsd:attribute name="tableXPath" type="xsd:string"/>
    <xsd:attribute name="tableSQL" type="xsd:string"/>
  </xsd:complexType>
  <xsd:complexType name="Level">
    <xsd:sequence>
      <xsd:element name="option" type="tdt:Option" minOccurs="1"
                   maxOccurs="unbounded"/>
      <xsd:element name="rule" type="tdt:Rule" minOccurs="0"
                   maxOccurs="unbounded"/>
    </xsd:sequence>
    <xsd:attribute name="type" type="tdt:LevelTypeList" use="required"/>
    <xsd:attribute name="prefixMatch" type="xsd:string" use="optional"/>
    <xsd:attribute name="requiredParsingParameters" type="xsd:string"/>
    <xsd:attribute name="requiredFormattingParameters" type="xsd:string"/>
  </xsd:complexType>
  <xsd:complexType name="Scheme">
    <xsd:sequence>
      <xsd:element name="level" type="tdt:Level" minOccurs="1" maxOccurs="5"/>
    </xsd:sequence>
    <xsd:attribute name="name" type="tdt:SchemeNameList" use="required"/>
    <xsd:attribute name="optionKey" type="xsd:string" use="required"/>
    <xsd:attribute name="tagLength" type="tdt:TagLengthList" use="optional"/>
  </xsd:complexType>
  <xsd:complexType name="TagDataTranslation">
    <xsd:sequence>
      <xsd:element name="scheme" type="tdt:Scheme" maxOccurs="unbounded"/>
    </xsd:sequence>
    <xsd:attribute name="version" type="xsd:string" use="required"/>
    <xsd:attribute name="date" type="xsd:dateTime" use="required"/>
  </xsd:complexType>
  <xsd:element name="TagDataTranslation" type="tdt:TagDataTranslation"/>
</xsd:schema>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);

  COMMIT;

  --create EPC category 
  SELECT mgd$sequence_category.nextval INTO seq FROM DUAL;
  INSERT INTO mgd_id_category_tab(owner, category_id, category_name, version, agency, uri) VALUES('MGDSYS', seq, 'EPC', '1.0', 'EPCGlobal', 'http://www.epcglobalinc.org');
  COMMIT;

  --add schemes for EPC category

  --GID-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode">
  <scheme name="GID-96" optionKey="1" xmlns="">
    <level type="BINARY" prefixMatch="00110101" requiredFormattingParameters="">
      <option optionKey="1" pattern="00110101([01]{28})([01]{24})([01]{36})" grammar="''00110101'' generalmanager objectclass serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="268435455" characterSet="[01]*" bitLength="28" name="generalmanager"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[01]*" bitLength="24" name="objectclass"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[01]*" bitLength="36" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:gid-96" requiredFormattingParameters="">
      <option optionKey="1" pattern="urn:epc:tag:gid-96:([0-9]*)\.([0-9]*)\.([0-9]*)" grammar="''urn:epc:tag:gid-96:'' generalmanager ''.'' objectclass ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="268435455" characterSet="[0-9]*" name="generalmanager"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="objectclass"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:gid">
      <option optionKey="1" pattern="urn:epc:id:gid:([0-9]*)\.([0-9]*)\.([0-9]*)" grammar="''urn:epc:id:gid:'' generalmanager ''.'' objectclass ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="268435455" characterSet="[0-9]*" name="generalmanager"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="objectclass"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="generalmanager=">
      <option optionKey="1" pattern="generalmanager=([0-9]*);objectclass=([0-9]*);serial=([0-9]*)" grammar="''generalmanager=''generalmanager'';objectclass=''objectclass '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="268435455" characterSet="[0-9]*" name="generalmanager"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="objectclass"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
  </scheme>
</TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --GIAI-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="GIAI-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00001011" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="00001011([01]{3})([01]{14})([01]{39})" grammar="''00001011'' filter companyprefixindex indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[01]*" bitLength="39" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:giai-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{12})\.([0-9]{12})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{11})\.([0-9]{13})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{10})\.([0-9]{14})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{9})\.([0-9]{15})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{8})\.([0-9]{16})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{7})\.([0-9]{17})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:giai-64:([0-7]{1})\.([0-9]{6})\.([0-9]{18})" grammar="''urn:epc:tag:giai-64:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="549755813887" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:giai">
      <option optionKey="12" pattern="urn:epc:id:giai:([0-9]{12})\.([0-9]{12})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:giai:([0-9]{11})\.([0-9]{13})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:giai:([0-9]{10})\.([0-9]{14})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:giai:([0-9]{9})\.([0-9]{15})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999999" characterSet="[0-9]*" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:giai:([0-9]{8})\.([0-9]{16})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999999999" characterSet="[0-9]*" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:giai:([0-9]{7})\.([0-9]{17})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999999999" characterSet="[0-9]*" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:giai:([0-9]{6})\.([0-9]{18})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="giai=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="giai=([0-9]{13,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="11" pattern="giai=([0-9]{12,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="10" pattern="giai=([0-9]{11,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="9" pattern="giai=([0-9]{10,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="8" pattern="giai=([0-9]{9,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="7" pattern="giai=([0-9]{8,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="6" pattern="giai=([0-9]{7,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="indassetref" characterSet="[0-9]*" function="SUBSTR(giai,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(giai,0,companyprefixlength)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --GIAI-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="GIAI-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110100" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110100([01]{3})000([01]{40})([01]{42})" grammar="''00110100'' filter ''000'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="42" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="00110100([01]{3})001([01]{37})([01]{45})" grammar="''00110100'' filter ''001'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[01]*" bitLength="45" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="00110100([01]{3})010([01]{34})([01]{48})" grammar="''00110100'' filter ''010'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[01]*" bitLength="48" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="00110100([01]{3})011([01]{30})([01]{52})" grammar="''00110100'' filter ''011'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999999" characterSet="[01]*" bitLength="52" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="00110100([01]{3})100([01]{27})([01]{55})" grammar="''00110100'' filter ''100'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999999999" characterSet="[01]*" bitLength="55" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="00110100([01]{3})101([01]{24})([01]{58})" grammar="''00110100'' filter ''101'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999999999" characterSet="[01]*" bitLength="58" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="00110100([01]{3})110([01]{20})([01]{62})" grammar="''00110100'' filter ''110'' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[01]*" bitLength="62" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:giai-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{12})\.([0-9]{12})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{11})\.([0-9]{13})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{10})\.([0-9]{14})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{9})\.([0-9]{15})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999999" characterSet="[0-9]*" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{8})\.([0-9]{16})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999999999" characterSet="[0-9]*" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{7})\.([0-9]{17})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999999999" characterSet="[0-9]*" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:giai-96:([0-7]{1})\.([0-9]{6})\.([0-9]{18})" grammar="''urn:epc:tag:giai-96:'' filter ''.'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:giai">
      <option optionKey="12" pattern="urn:epc:id:giai:([0-9]{12})\.([0-9]{12})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:giai:([0-9]{11})\.([0-9]{13})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:giai:([0-9]{10})\.([0-9]{14})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:giai:([0-9]{9})\.([0-9]{15})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999999" characterSet="[0-9]*" length="15" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:giai:([0-9]{8})\.([0-9]{16})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999999999" characterSet="[0-9]*" length="16" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:giai:([0-9]{7})\.([0-9]{17})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999999999" characterSet="[0-9]*" length="17" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:giai:([0-9]{6})\.([0-9]{18})" grammar="''urn:epc:id:giai:'' companyprefix ''.'' indassetref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="indassetref"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="giai=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="giai=([0-9]{13,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="11" pattern="giai=([0-9]{12,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="10" pattern="giai=([0-9]{11,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="9" pattern="giai=([0-9]{10,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="8" pattern="giai=([0-9]{9,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="7" pattern="giai=([0-9]{8,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <option optionKey="6" pattern="giai=([0-9]{7,30})" grammar="''giai='' companyprefix indassetref">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="giai"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="indassetref" characterSet="[0-9]*" function="SUBSTR(giai,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(giai,0,companyprefixlength)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --GRAI-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="GRAI-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00001010" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" characterSet="[01]*" bitLength="20" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="11" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="20" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="10" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="20" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="9" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="20" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="8" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="20" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="7" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="20" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="6" pattern="00001010([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001010'' filter companyprefixindex assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:grai-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:grai-64:([0-7]{1})\.([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:grai-64:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:grai">
      <option optionKey="12" pattern="urn:epc:id:grai:([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:grai:([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:grai:([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:grai:([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:grai:([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:grai:([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:grai:([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="grai=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="11" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="10" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="9" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="8" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="7" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="6" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="graiprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(grai,1,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="assettype" characterSet="[0-9]*" function="SUBSTR(graiprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="serial" characterSet="[0-9]*" function="SUBSTR(grai,14)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(graiprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="graiprefix" characterSet="[0-9]*" length="13" function="CONCAT(0,companyprefix,assettype)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(graiprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --GRAI-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="GRAI-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110011" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110011([01]{3})000([01]{40})([01]{4})([01]{38})" grammar="''00110011'' filter ''000'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" characterSet="[01]*" bitLength="4" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="11" pattern="00110011([01]{3})001([01]{37})([01]{7})([01]{38})" grammar="''00110011'' filter ''001'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="7" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="10" pattern="00110011([01]{3})010([01]{34})([01]{10})([01]{38})" grammar="''00110011'' filter ''010'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="10" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="9" pattern="00110011([01]{3})011([01]{30})([01]{14})([01]{38})" grammar="''00110011'' filter ''011'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="14" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="8" pattern="00110011([01]{3})100([01]{27})([01]{17})([01]{38})" grammar="''00110011'' filter ''100'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="17" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="7" pattern="00110011([01]{3})101([01]{24})([01]{20})([01]{38})" grammar="''00110011'' filter ''101'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="20" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="6" pattern="00110011([01]{3})110([01]{20})([01]{24})([01]{38})" grammar="''00110011'' filter ''110'' companyprefix assettype serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="24" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:grai-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:grai-96:([0-7]{1})\.([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:grai-96:'' filter ''.'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:grai">
      <option optionKey="12" pattern="urn:epc:id:grai:([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:grai:([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:grai:([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:grai:([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:grai:([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:grai:([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:grai:([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:grai:'' companyprefix ''.'' assettype ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="assettype"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="grai=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="11" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="10" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="9" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="8" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="7" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <option optionKey="6" pattern="grai=([0-9]{15,30})" grammar="''grai='' ''0'' companyprefix assettype checkdigit serial">
        <field seq="1" decimalMinimum="0" characterSet="[0-9]*" name="grai"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="graiprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(grai,1,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="assettype" characterSet="[0-9]*" function="SUBSTR(graiprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="serial" characterSet="[0-9]*" function="SUBSTR(grai,14)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(graiprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="graiprefix" characterSet="[0-9]*" length="13" function="CONCAT(0,companyprefix,assettype)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(graiprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --SGLN-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SGLN-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00001001" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="11" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="10" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="9" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="8" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="7" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <option optionKey="6" pattern="00001001([01]{3})([01]{14})([01]{20})([01]{19})" grammar="''00001001'' filter companyprefixindex locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[01]*" bitLength="19" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sgln-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sgln-64:([0-7]{1})\.([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:sgln-64:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sgln">
      <option optionKey="12" pattern="urn:epc:id:sgln:([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="1" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sgln:([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sgln:([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sgln:([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sgln:([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sgln:([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sgln:([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="gln=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="524287" characterSet="[0-9]*" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="glnprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(gln,0,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="locationref" characterSet="[0-9]*" function="SUBSTR(glnprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(glnprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="glnprefix" characterSet="[0-9]*" length="12" function="CONCAT(companyprefix,locationref)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(glnprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --SGLN-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SGLN-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110010" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110010([01]{3})000([01]{40})([01]{1})([01]{41})" grammar="''00110010'' filter ''000'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" characterSet="[01]*" bitLength="1" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="11" pattern="00110010([01]{3})001([01]{37})([01]{4})([01]{41})" grammar="''00110010'' filter ''001'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="4" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="10" pattern="00110010([01]{3})010([01]{34})([01]{7})([01]{41})" grammar="''00110010'' filter ''010'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="7" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="9" pattern="00110010([01]{3})011([01]{30})([01]{11})([01]{41})" grammar="''00110010'' filter ''011'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="11" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="8" pattern="00110010([01]{3})100([01]{27})([01]{14})([01]{41})" grammar="''00110010'' filter ''100'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="14" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="7" pattern="00110010([01]{3})101([01]{24})([01]{17})([01]{41})" grammar="''00110010'' filter ''101'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="17" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
      <option optionKey="6" pattern="00110010([01]{3})110([01]{20})([01]{21})([01]{41})" grammar="''00110010'' filter ''110'' companyprefix locationref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="21" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[01]*" bitLength="41" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sgln-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sgln-96:([0-7]{1})\.([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:sgln-96:'' filter ''.'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sgln">
      <option optionKey="12" pattern="urn:epc:id:sgln:([0-9]{12})\.([0-9]{0})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="1" characterSet="[0-9]*" length="0" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sgln:([0-9]{11})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sgln:([0-9]{10})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sgln:([0-9]{9})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sgln:([0-9]{8})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sgln:([0-9]{7})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sgln:([0-9]{6})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:sgln:'' companyprefix ''.'' locationref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="locationref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="gln=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' gln '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="gln=([0-9]{13});serial=([0-9]*)" grammar="''gln='' companyprefix locationref checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999999" characterSet="[0-9]*" length="13" padChar="0" padDir="LEFT" name="gln"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="2199023255551" characterSet="[0-9]*" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="glnprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(gln,0,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="locationref" characterSet="[0-9]*" function="SUBSTR(glnprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(glnprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="glnprefix" characterSet="[0-9]*" length="12" function="CONCAT(companyprefix,locationref)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(glnprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --SGTIN-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SGTIN-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="10" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="20" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="11" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="20" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="10" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="20" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="9" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="20" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="8" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="20" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="7" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <option optionKey="6" pattern="10([01]{3})([01]{14})([01]{20})([01]{25})" grammar="''10'' filter companyprefixindex itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[01]*" bitLength="20" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[01]*" bitLength="25" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sgtin-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{12})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{11})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{10})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{9})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{8})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{7})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sgtin-64:([0-7]{1})\.([0-9]{6})\.([0-9]{7})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-64:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="1048575" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sgtin">
      <option optionKey="12" pattern="urn:epc:id:sgtin:([0-9]{12})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sgtin:([0-9]{11})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sgtin:([0-9]{10})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sgtin:([0-9]{9})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sgtin:([0-9]{8})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sgtin:([0-9]{7})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sgtin:([0-9]{6})\.([0-9]{7})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="1048575" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="gtin=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="33554431" characterSet="[0-9]*" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="gtinprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(gtin,1,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="indicatordigit" characterSet="[0-9]*" length="1" function="SUBSTR(gtin,0,1)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="itemrefremainder" characterSet="[0-9]*" function="SUBSTR(gtinprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="itemref" characterSet="[0-9]*" function="CONCAT(indicatordigit,itemrefremainder)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="5" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(gtinprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="indicatordigit" characterSet="[0-9]*" length="1" function="SUBSTR(itemref,0,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="itemrefremainder" characterSet="[0-9]*" function="SUBSTR(itemref,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="3" newFieldName="gtinprefix" characterSet="[0-9]*" length="13" function="CONCAT(indicatordigit,companyprefix,itemrefremainder)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="4" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(gtinprefix)"/>
    </level>
    <level type="ONS_HOSTNAME">
      <option optionKey="12" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="11" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="10" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="9" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="8" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="7" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="6" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --SGTIN-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SGTIN-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110000" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110000([01]{3})000([01]{40})([01]{4})([01]{38})" grammar="''00110000'' filter ''000'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[01]*" bitLength="4" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="11" pattern="00110000([01]{3})001([01]{37})([01]{7})([01]{38})" grammar="''00110000'' filter ''001'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[01]*" bitLength="7" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="10" pattern="00110000([01]{3})010([01]{34})([01]{10})([01]{38})" grammar="''00110000'' filter ''010'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[01]*" bitLength="10" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="9" pattern="00110000([01]{3})011([01]{30})([01]{14})([01]{38})" grammar="''00110000'' filter ''011'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[01]*" bitLength="14" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="8" pattern="00110000([01]{3})100([01]{27})([01]{17})([01]{38})" grammar="''00110000'' filter ''100'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="17" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="7" pattern="00110000([01]{3})101([01]{24})([01]{20})([01]{38})" grammar="''00110000'' filter ''101'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
      <option optionKey="6" pattern="00110000([01]{3})110([01]{20})([01]{24})([01]{38})" grammar="''00110000'' filter ''110'' companyprefix itemref serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[01]*" bitLength="38" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sgtin-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{12})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{11})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{10})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{9})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{8})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{7})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sgtin-96:([0-7]{1})\.([0-9]{6})\.([0-9]{7})\.([0-9]*)" grammar="''urn:epc:tag:sgtin-96:'' filter ''.'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="4" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sgtin">
      <option optionKey="12" pattern="urn:epc:id:sgtin:([0-9]{12})\.([0-9]{1})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sgtin:([0-9]{11})\.([0-9]{2})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sgtin:([0-9]{10})\.([0-9]{3})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sgtin:([0-9]{9})\.([0-9]{4})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sgtin:([0-9]{8})\.([0-9]{5})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sgtin:([0-9]{7})\.([0-9]{6})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sgtin:([0-9]{6})\.([0-9]{7})\.([0-9]*)" grammar="''urn:epc:id:sgtin:'' companyprefix ''.'' itemref ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="gtin=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="11" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="10" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="9" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="8" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="7" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <option optionKey="6" pattern="gtin=([0-9]{14});serial=([0-9]*)" grammar="''gtin='' indicatordigit companyprefix itemrefremainder checkdigit '';serial='' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999999" characterSet="[0-9]*" length="14" padChar="0" padDir="LEFT" name="gtin"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="274877906943" characterSet="[0-9]*" name="serial"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="gtinprefixremainder" characterSet="[0-9]*" length="12" function="SUBSTR(gtin,1,12)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="indicatordigit" characterSet="[0-9]*" length="1" function="SUBSTR(gtin,0,1)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="itemrefremainder" characterSet="[0-9]*" function="SUBSTR(gtinprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="itemref" characterSet="[0-9]*" function="CONCAT(indicatordigit,itemrefremainder)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="5" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(gtinprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="indicatordigit" characterSet="[0-9]*" length="1" function="SUBSTR(itemref,0,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="itemrefremainder" characterSet="[0-9]*" function="SUBSTR(itemref,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="3" newFieldName="gtinprefix" characterSet="[0-9]*" length="13" function="CONCAT(indicatordigit,companyprefix,itemrefremainder)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="4" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(gtinprefix)"/>
    </level>
    <level type="ONS_HOSTNAME">
      <option optionKey="12" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9" characterSet="[0-9]*" length="1" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="11" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="99" characterSet="[0-9]*" length="2" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="10" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="999" characterSet="[0-9]*" length="3" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="9" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999" characterSet="[0-9]*" length="4" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="8" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="7" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
      <option optionKey="6" grammar="itemref ''.'' companyprefix ''.sgtin.id.onsepc.com''">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="itemref"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
      </option>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --SSCC-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SSCC-64" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00001000" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="39" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="39" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="39" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="39" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="39" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="39" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="00001000([01]{3})([01]{14})([01]{39})" grammar="''00001000'' filter companyprefixindex serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16383" characterSet="[01]*" bitLength="14" name="companyprefixindex"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="39" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="companyprefix" characterSet="[0-9]*" function="TABLELOOKUP(companyprefixindex,tdt64bitcpi,companyprefixindex,companyprefix)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@index=''$1'']/@companyPrefix" tableParams="companyprefixindex"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="companyprefixlength" characterSet="[0-9]*" function="LENGTH(companyprefix)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="companyprefixindex" characterSet="[0-9]*" function="TABLELOOKUP(companyprefix,tdt64bitcpi,companyprefix,companyprefixindex)" tableURI="http://www.onsepc.com/ManagerTranslation.xml" tableXPath="/GEPC64Table/entry[@companyPrefix=''$1'']/@index" tableParams="companyprefix"/>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sscc-64" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{12})\.([0-9]{5})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{11})\.([0-9]{6})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{10})\.([0-9]{7})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{9})\.([0-9]{8})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{8})\.([0-9]{9})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{7})\.([0-9]{10})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sscc-64:([0-7]{1})\.([0-9]{6})\.([0-9]{11})" grammar="''urn:epc:tag:sscc-64:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sscc">
      <option optionKey="12" pattern="urn:epc:id:sscc:([0-9]{12})\.([0-9]{5})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sscc:([0-9]{11})\.([0-9]{6})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sscc:([0-9]{10})\.([0-9]{7})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sscc:([0-9]{9})\.([0-9]{8})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sscc:([0-9]{8})\.([0-9]{9})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sscc:([0-9]{7})\.([0-9]{10})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sscc:([0-9]{6})\.([0-9]{11})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="sscc=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="11" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="10" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="9" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="8" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="7" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="6" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="ssccprefixremainder" characterSet="[0-9]*" length="16" function="SUBSTR(sscc,1,16)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="extensiondigit" characterSet="[0-9]*" length="1" function="SUBSTR(sscc,0,1)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="serialrefremainder" characterSet="[0-9]*" function="SUBSTR(ssccprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="serialref" characterSet="[0-9]*" function="CONCAT(extensiondigit,serialrefremainder)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="5" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(ssccprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="extensiondigit" characterSet="[0-9]*" length="1" function="SUBSTR(serialref,0,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="serialrefremainder" characterSet="[0-9]*" function="SUBSTR(serialref,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="3" newFieldName="ssccprefix" characterSet="[0-9]*" length="17" function="CONCAT(extensiondigit,companyprefix,serialrefremainder)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="4" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(ssccprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --SSCC-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="SSCC-96" optionKey="companyprefixlength" xmlns="">
    <level type="BINARY" prefixMatch="00110001" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="00110001([01]{3})000([01]{40})([01]{18})000000000000000000000000" grammar="''00110001'' filter ''000'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[01]*" bitLength="40" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[01]*" bitLength="18" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="00110001([01]{3})001([01]{37})([01]{21})000000000000000000000000" grammar="''00110001'' filter ''001'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="37" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="21" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="00110001([01]{3})010([01]{34})([01]{24})000000000000000000000000" grammar="''00110001'' filter ''010'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="00110001([01]{3})011([01]{30})([01]{28})000000000000000000000000" grammar="''00110001'' filter ''011'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="30" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="28" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="00110001([01]{3})100([01]{27})([01]{31})000000000000000000000000" grammar="''00110001'' filter ''100'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[01]*" bitLength="27" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999" characterSet="[01]*" bitLength="31" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="00110001([01]{3})101([01]{24})([01]{34})000000000000000000000000" grammar="''00110001'' filter ''101'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[01]*" bitLength="24" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[01]*" bitLength="34" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="00110001([01]{3})110([01]{20})([01]{38})000000000000000000000000" grammar="''00110001'' filter ''110'' companyprefix serialref ''000000000000000000000000''">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[01]*" bitLength="3" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[01]*" bitLength="20" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[01]*" bitLength="38" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:sscc-96" requiredFormattingParameters="filter">
      <option optionKey="12" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{12})\.([0-9]{5})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{11})\.([0-9]{6})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{10})\.([0-9]{7})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{9})\.([0-9]{8})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{8})\.([0-9]{9})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{7})\.([0-9]{10})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:tag:sscc-96:([0-7]{1})\.([0-9]{6})\.([0-9]{11})" grammar="''urn:epc:tag:sscc-96:'' filter ''.'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="7" characterSet="[0-7]*" length="1" padChar="0" padDir="LEFT" name="filter"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:sscc">
      <option optionKey="12" pattern="urn:epc:id:sscc:([0-9]{12})\.([0-9]{5})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999" characterSet="[0-9]*" length="12" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999" characterSet="[0-9]*" length="5" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="11" pattern="urn:epc:id:sscc:([0-9]{11})\.([0-9]{6})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="10" pattern="urn:epc:id:sscc:([0-9]{10})\.([0-9]{7})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="9" pattern="urn:epc:id:sscc:([0-9]{9})\.([0-9]{8})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="8" pattern="urn:epc:id:sscc:([0-9]{8})\.([0-9]{9})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="99999999" characterSet="[0-9]*" length="8" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="999999999" characterSet="[0-9]*" length="9" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="7" pattern="urn:epc:id:sscc:([0-9]{7})\.([0-9]{10})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="9999999" characterSet="[0-9]*" length="7" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="9999999999" characterSet="[0-9]*" length="10" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
      <option optionKey="6" pattern="urn:epc:id:sscc:([0-9]{6})\.([0-9]{11})" grammar="''urn:epc:id:sscc:'' companyprefix ''.'' serialref">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999" characterSet="[0-9]*" length="6" padChar="0" padDir="LEFT" name="companyprefix"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="99999999999" characterSet="[0-9]*" length="11" padChar="0" padDir="LEFT" name="serialref"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="sscc=" requiredParsingParameters="companyprefixlength">
      <option optionKey="12" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="11" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="10" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="9" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="8" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="7" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <option optionKey="6" pattern="sscc=([0-9]{18})" grammar="''sscc='' extensiondigit companyprefix serialrefremainder checkdigit">
        <field seq="1" decimalMinimum="0" decimalMaximum="999999999999999999" characterSet="[0-9]*" length="18" padChar="0" padDir="LEFT" name="sscc"/>
      </option>
      <rule type="EXTRACT" inputFormat="STRING" seq="1" newFieldName="ssccprefixremainder" characterSet="[0-9]*" length="16" function="SUBSTR(sscc,1,16)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="2" newFieldName="extensiondigit" characterSet="[0-9]*" length="1" function="SUBSTR(sscc,0,1)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="3" newFieldName="serialrefremainder" characterSet="[0-9]*" function="SUBSTR(ssccprefixremainder,companyprefixlength)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="4" newFieldName="serialref" characterSet="[0-9]*" function="CONCAT(extensiondigit,serialrefremainder)"/>
      <rule type="EXTRACT" inputFormat="STRING" seq="5" newFieldName="companyprefix" characterSet="[0-9]*" function="SUBSTR(ssccprefixremainder,0,companyprefixlength)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="1" newFieldName="extensiondigit" characterSet="[0-9]*" length="1" function="SUBSTR(serialref,0,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="2" newFieldName="serialrefremainder" characterSet="[0-9]*" function="SUBSTR(serialref,1)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="3" newFieldName="ssccprefix" characterSet="[0-9]*" length="17" function="CONCAT(extensiondigit,companyprefix,serialrefremainder)"/>
      <rule type="FORMAT" inputFormat="STRING" seq="4" newFieldName="checkdigit" characterSet="[0-9]*" length="1" function="GS1CHECKSUM(ssccprefix)"/>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --USDOD-64
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="USDOD-64" optionKey="1" xmlns="">
    <level type="BINARY" prefixMatch="11001110" requiredFormattingParameters="">
      <option optionKey="1" pattern="11001110([01]{2})([01]{30})([01]{24})" grammar="''11001110'' filter cageordodaac serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="3" characterSet="[01]*" bitLength="2" name="filter"/>
        <field seq="2" characterSet="[01]*" compaction="6-bit" length="5" padChar=" " padDir="LEFT" bitLength="30" name="cageordodaac"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="16777215" characterSet="[01]*" bitLength="24" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:usdod-64" requiredFormattingParameters="">
      <option optionKey="1" pattern="urn:epc:tag:usdod-64:([0-9])\.([0-9 A-HJ-NP4469 Z]{5})\.([0-9]+)" grammar="''urn:epc:tag:usdod-64:'' filter ''.'' cageordodaac ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="3" characterSet="[0-3]*" name="filter"/>
        <field seq="2" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:usdod">
      <option optionKey="1" pattern="urn:epc:id:usdod:([0-9 A-HJ-NP-Z]{5})\.([0-9]+)" grammar="''urn:epc:id:usdod:'' cageordodaac ''.'' serial">
        <field seq="1" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="cageordodaac=">
      <option optionKey="1" pattern="cageordodaac=([0-9 A-HJ-NP-Z]{5});serial=([0-9]+)" grammar="''cageordodaac='' cageordodaac '';serial='' serial">
        <field seq="1" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="16777215" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

  --USDOD-96
  DBMS_LOB.CREATETEMPORARY(tdt_xml, true);
  DBMS_LOB.OPEN(tdt_xml, DBMS_LOB.LOB_READWRITE);
 
  buf := '<?xml version = ''1.0'' encoding = "UTF-8"?>
<TagDataTranslation version="0.04" date="2005-04-18T16:05:00Z" xmlns:xsi="http://www.w3.org/2001/XMLSchema" xmlns="oracle.mgd.idcode"><scheme name="USDOD-96" optionKey="1" xmlns="">
    <level type="BINARY" prefixMatch="00101111" requiredFormattingParameters="">
      <option optionKey="1" pattern="00101111([01]{4})([01]{48})([01]{36})" grammar="''00101111'' filter cageordodaac serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="15" characterSet="[01]*" bitLength="4" name="filter"/>
        <field seq="2" characterSet="[01]*" compaction="8-bit" padChar=" " padDir="LEFT" length="6" bitLength="48" name="cageordodaac"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[01]*" bitLength="36" name="serial"/>
      </option>
    </level>
    <level type="TAG_ENCODING" prefixMatch="urn:epc:tag:usdod-96" requiredFormattingParameters="">
      <option optionKey="1" pattern="urn:epc:tag:usdod-96:([0-9])\.([0-9 A-HJ-NP4517 Z]{5,6})\.([0-9]*)" grammar="''urn:epc:tag:usdod-96:'' filter ''.'' cageordodaac ''.'' serial">
        <field seq="1" decimalMinimum="0" decimalMaximum="15" characterSet="[0-9]*" name="filter"/>
        <field seq="2" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="3" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="PURE_IDENTITY" prefixMatch="urn:epc:id:usdod">
      <option optionKey="1" pattern="urn:epc:id:usdod:([0-9 A-HJ-NP-Z]{5,6})\.([0-9]+)" grammar="''urn:epc:id:usdod:'' cageordodaac ''.'' serial">
        <field seq="1" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
    <level type="LEGACY" prefixMatch="cageordodaac=">
      <option optionKey="1" pattern="cageordodaac=([0-9 A-HJ-NP-Z]{5,6});serial=([0-9]+)" grammar="''cageordodaac='' cageordodaac '';serial='' serial">
        <field seq="1" characterSet="[0-9 A-HJ-NP-Z]*" name="cageordodaac"/>
        <field seq="2" decimalMinimum="0" decimalMaximum="68719476735" characterSet="[0-9]*" name="serial"/>
      </option>
    </level>
  </scheme></TagDataTranslation>';

  amt := length(buf);
  pos := 1;
  DBMS_LOB.WRITE(tdt_xml, amt, pos, buf);
  DBMS_LOB.CLOSE(tdt_xml);
  INSERT INTO mgd_id_scheme_tab(category_id, tdt_xml, owner) values(seq, tdt_xml, 'MGDSYS');
  DBMS_MGD_ID_UTL.refresh_category(to_char(seq));
  COMMIT;

END;
/
SHOW ERRORS;

call dbms_output.put_line('Make sure these values look OK:');
col category_name format a10;
col type_name format a10;
col encodings format a22;
select dbms_lob.getlength(xsd_schema) as XML_VALIDATOR_CHAR_LENGTH from mgd_id_xml_validator;
select category_name, category_id from mgd_id_category;
select category_id, type_name, encodings, dbms_lob.getlength(tdt_xml) XML_TDTs_CHAR_LENGTH  from mgd_id_scheme;
