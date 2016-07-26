Rem
Rem $Header: catxlcr1.sql 20-nov-2003.09:08:16 alakshmi Exp $
Rem
Rem catxlcr1.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catxlcr1.sql - XML schema definition for LCRs
Rem
Rem    DESCRIPTION
Rem      This script declares the LCR schema
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    alakshmi    10/16/03 - Bug 3197273 
Rem    bpwang      11/07/03 - Bug 3240955: Store rowid extra attr as urowid
Rem    spannala    08/29/03 - spannala_upglrg_2 
Rem    sichandr    07/28/03 - add LCR Schema
Rem    sichandr    07/28/03 - Created
Rem

create or replace package lcr$_xml_schema as

  CONFIGURL VARCHAR2(2000) := 
             'http://xmlns.oracle.com/streams/schemas/lcr/streamslcr.xsd';
  CONFIGXSD_10101 VARCHAR2(20000) := 
'<schema xmlns="http://www.w3.org/2001/XMLSchema" 
        targetNamespace="http://xmlns.oracle.com/streams/schemas/lcr" 
        xmlns:lcr="http://xmlns.oracle.com/streams/schemas/lcr"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
          version="1.0"
        elementFormDefault="qualified">

  <simpleType name = "short_name">
    <restriction base = "string">
      <maxLength value="30"/>
    </restriction>
  </simpleType>

  <simpleType name = "long_name">
    <restriction base = "string">
      <maxLength value="4000"/>
    </restriction>
  </simpleType>

  <simpleType name = "db_name">
    <restriction base = "string">
      <maxLength value="128"/>
    </restriction>
  </simpleType>

  <!-- Default session parameter is used if format is not specified -->
  <complexType name="datetime_format">
    <sequence>
      <element name = "value" type = "string" nillable="true"/>
      <element name = "format" type = "string" minOccurs="0" nillable="true"/>
    </sequence>
  </complexType>

  <complexType name="anydata">
    <choice>
      <element name="varchar2" type = "string" xdb:SQLType="CLOB" 
                                                        nillable="true"/>

      <!-- Represent char as varchar2. xdb:CHAR blank pads upto 2000 bytes! -->
      <element name="char" type = "string" xdb:SQLType="CLOB"
                                                        nillable="true"/>
      <element name="nchar" type = "string" xdb:SQLType="NCLOB"
                                                        nillable="true"/>

      <element name="nvarchar2" type = "string" xdb:SQLType="NCLOB"
                                                        nillable="true"/>
      <element name="number" type = "double" xdb:SQLType="NUMBER"
                                                        nillable="true"/>
      <element name="raw" type = "hexBinary" xdb:SQLType="BLOB" 
                                                        nillable="true"/>
      <element name="date" type = "lcr:datetime_format"/>
      <element name="timestamp" type = "lcr:datetime_format"/>
      <element name="timestamp_tz" type = "lcr:datetime_format"/>
      <element name="timestamp_ltz" type = "lcr:datetime_format"/>

      <!-- Interval YM should be as per format allowed by SQL -->
      <element name="interval_ym" type = "string" nillable="true"/>

      <!-- Interval DS should be as per format allowed by SQL -->
      <element name="interval_ds" type = "string" nillable="true"/>

      <element name="urowid" type = "string" xdb:SQLType="VARCHAR2"
                                                        nillable="true"/>
    </choice>
  </complexType>

  <complexType name="column_value">
    <sequence>
      <element name = "column_name" type = "lcr:long_name" nillable="false"/>
      <element name = "data" type = "lcr:anydata" nillable="false"/>
      <element name = "lob_information" type = "string" minOccurs="0"
                                                           nillable="true"/>
      <element name = "lob_offset" type = "nonNegativeInteger" minOccurs="0"
                                                           nillable="true"/>
      <element name = "lob_operation_size" type = "nonNegativeInteger" 
                                             minOccurs="0" nillable="true"/>
      <element name = "long_information" type = "string" minOccurs="0"
                                                           nillable="true"/>
    </sequence>
  </complexType>

  <complexType name="extra_attribute">
    <sequence>
      <element name = "attribute_name" type = "lcr:short_name"/>
      <element name = "attribute_value" type = "lcr:anydata"/>
    </sequence>
  </complexType>

  <element name = "ROW_LCR" xdb:defaultTable="">
    <complexType>
      <sequence>
        <element name = "source_database_name" type = "lcr:db_name" 
                                                            nillable="false"/>
        <element name = "command_type" type = "string" nillable="false"/>
        <element name = "object_owner" type = "lcr:short_name" 
                                                            nillable="false"/>
        <element name = "object_name" type = "lcr:short_name"
                                                            nillable="false"/>
        <element name = "tag" type = "hexBinary" xdb:SQLType="RAW" 
                                               minOccurs="0" nillable="true"/>
        <element name = "transaction_id" type = "string" minOccurs="0" 
                                                             nillable="true"/>
        <element name = "scn" type = "double" xdb:SQLType="NUMBER" 
                                               minOccurs="0" nillable="true"/>
        <element name = "old_values" minOccurs = "0">
          <complexType>
            <sequence>
              <element name = "old_value" type="lcr:column_value" 
                                                    maxOccurs = "unbounded"/>
            </sequence>
          </complexType>
        </element>
        <element name = "new_values" minOccurs = "0">
          <complexType>
            <sequence>
              <element name = "new_value" type="lcr:column_value" 
                                                    maxOccurs = "unbounded"/>
            </sequence>
          </complexType>
        </element>
        <element name = "extra_attribute_values" minOccurs = "0">
          <complexType>
            <sequence>
              <element name = "extra_attribute_value"
                       type="lcr:extra_attribute"
                       maxOccurs = "unbounded"/>
            </sequence>
          </complexType>
        </element>
      </sequence>
    </complexType>
  </element>

  <element name = "DDL_LCR" xdb:defaultTable="">
    <complexType>
      <sequence>
        <element name = "source_database_name" type = "lcr:db_name" 
                                                        nillable="false"/>
        <element name = "command_type" type = "string" nillable="false"/>
        <element name = "current_schema" type = "lcr:short_name"
                                                        nillable="false"/>
        <element name = "ddl_text" type = "string" xdb:SQLType="CLOB"
                                                        nillable="false"/>
        <element name = "object_type" type = "string"
                                        minOccurs = "0" nillable="true"/>
        <element name = "object_owner" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "object_name" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "logon_user" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "base_table_owner" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "base_table_name" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "tag" type = "hexBinary" xdb:SQLType="RAW"
                                        minOccurs = "0" nillable="true"/>
        <element name = "transaction_id" type = "string"
                                        minOccurs = "0" nillable="true"/>
        <element name = "scn" type = "double" xdb:SQLType="NUMBER"
                                        minOccurs = "0" nillable="true"/>
        <element name = "extra_attribute_values" minOccurs = "0">
          <complexType>
            <sequence>
              <element name = "extra_attribute_value"
                       type="lcr:extra_attribute"
                       maxOccurs = "unbounded"/>
            </sequence>
          </complexType>
        </element>
      </sequence>
    </complexType>
  </element>
</schema>';

  CONFIGXSD_9204 VARCHAR2(20000) := 
'<schema xmlns="http://www.w3.org/2001/XMLSchema" 
        targetNamespace="http://xmlns.oracle.com/streams/schemas/lcr" 
        xmlns:lcr="http://xmlns.oracle.com/streams/schemas/lcr"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
          version="1.0"
        elementFormDefault="qualified">

  <simpleType name = "short_name">
    <restriction base = "string">
      <maxLength value="30"/>
    </restriction>
  </simpleType>

  <simpleType name = "long_name">
    <restriction base = "string">
      <maxLength value="4000"/>
    </restriction>
  </simpleType>

  <simpleType name = "db_name">
    <restriction base = "string">
      <maxLength value="128"/>
    </restriction>
  </simpleType>

  <!-- Default session parameter is used if format is not specified -->
  <complexType name="datetime_format">
    <sequence>
      <element name = "value" type = "string" nillable="true"/>
      <element name = "format" type = "string" minOccurs="0" nillable="true"/>
    </sequence>
  </complexType>

  <complexType name="anydata">
    <choice>
      <element name="varchar2" type = "string" xdb:SQLType="VARCHAR2" 
                                                        nillable="true"/>

      <!-- Represent char as varchar2. xdb:CHAR blank pads upto 2000 bytes! -->
      <element name="char" type = "string" xdb:SQLType="VARCHAR2"
                                                        nillable="true"/>
      <element name="nchar" type = "string" xdb:SQLType="NVARCHAR2"
                                                        nillable="true"/>

      <element name="nvarchar2" type = "string" xdb:SQLType="NVARCHAR2"
                                                        nillable="true"/>
      <element name="number" type = "double" xdb:SQLType="NUMBER"
                                                        nillable="true"/>
      <element name="raw" type = "hexBinary" xdb:SQLType="RAW" 
                                                        nillable="true"/>
      <element name="date" type = "lcr:datetime_format"/>
      <element name="timestamp" type = "lcr:datetime_format"/>
      <element name="timestamp_tz" type = "lcr:datetime_format"/>
      <element name="timestamp_ltz" type = "lcr:datetime_format"/>

      <!-- Interval YM should be as per format allowed by SQL -->
      <element name="interval_ym" type = "string" nillable="true"/>

      <!-- Interval DS should be as per format allowed by SQL -->
      <element name="interval_ds" type = "string" nillable="true"/>

    </choice>
  </complexType>

  <complexType name="column_value">
    <sequence>
      <element name = "column_name" type = "lcr:long_name" nillable="false"/>
      <element name = "data" type = "lcr:anydata" nillable="false"/>
      <element name = "lob_information" type = "string" minOccurs="0"
                                                           nillable="true"/>
      <element name = "lob_offset" type = "nonNegativeInteger" minOccurs="0"
                                                           nillable="true"/>
      <element name = "lob_operation_size" type = "nonNegativeInteger" 
                                             minOccurs="0" nillable="true"/>
    </sequence>
  </complexType>

  <element name = "ROW_LCR">
    <complexType>
      <sequence>
        <element name = "source_database_name" type = "lcr:db_name" 
                                                            nillable="false"/>
        <element name = "command_type" type = "string" nillable="false"/>
        <element name = "object_owner" type = "lcr:short_name" 
                                                            nillable="false"/>
        <element name = "object_name" type = "lcr:short_name"
                                                            nillable="false"/>
        <element name = "tag" type = "hexBinary" xdb:SQLType="RAW" 
                                               minOccurs="0" nillable="true"/>
        <element name = "transaction_id" type = "string" minOccurs="0" 
                                                             nillable="true"/>
        <element name = "scn" type = "double" xdb:SQLType="NUMBER" 
                                               minOccurs="0" nillable="true"/>
        <element name = "old_values" minOccurs = "0">
          <complexType>
            <sequence>
              <element name = "old_value" type="lcr:column_value" 
                                                    maxOccurs = "unbounded"/>
            </sequence>
          </complexType>
        </element>
        <element name = "new_values" minOccurs = "0">
          <complexType>
            <sequence>
              <element name = "new_value" type="lcr:column_value" 
                                                    maxOccurs = "unbounded"/>
            </sequence>
          </complexType>
        </element>
      </sequence>
    </complexType>
  </element>

  <element name = "DDL_LCR">
    <complexType>
      <sequence>
        <element name = "source_database_name" type = "lcr:db_name" 
                                                        nillable="false"/>
        <element name = "command_type" type = "string" nillable="false"/>
        <element name = "current_schema" type = "lcr:short_name"
                                                        nillable="false"/>
        <element name = "ddl_text" type = "string" nillable="false"/>
        <element name = "object_type" type = "string"
                                        minOccurs = "0" nillable="true"/>
        <element name = "object_owner" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "object_name" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "logon_user" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "base_table_owner" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "base_table_name" type = "lcr:short_name"
                                        minOccurs = "0" nillable="true"/>
        <element name = "tag" type = "hexBinary" xdb:SQLType="RAW"
                                        minOccurs = "0" nillable="true"/>
        <element name = "transaction_id" type = "string"
                                        minOccurs = "0" nillable="true"/>
        <element name = "scn" type = "double" xdb:SQLType="NUMBER"
                                        minOccurs = "0" nillable="true"/>
      </sequence>
    </complexType>
  </element>
</schema>';
end;
/

