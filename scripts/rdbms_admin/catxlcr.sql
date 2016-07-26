Rem
Rem $Header: catxlcr.sql 21-aug-2003.12:59:56 spannala Exp $
Rem
Rem catxlcr.sql
Rem
Rem Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catxlcr.sql - XML schema definition for LCRs
Rem
Rem    DESCRIPTION
Rem      This script registers the LCR schema
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spannala    08/21/03 - using package variables to register the lcr 
Rem    htran       06/26/03 - add long_information
Rem    alakshmi    01/21/03 - remove lines for testing
Rem    liwong      09/09/02 - extra attributes
Rem    alakshmi    08/22/02 - lrg 102518
Rem    rvenkate    02/14/02 - varchar is not supported
Rem    alakshmi    02/04/02 - Lob support
Rem    alakshmi    01/30/02 - minOccurs=0 for object_type
Rem    alakshmi    01/23/02 - SQLType:CHAR=>VARCHAR2
Rem    alakshmi    01/15/02 - Merged alakshmi_xml_supp
Rem    alakshmi    01/15/02 - targetNamespace changes
Rem    alakshmi    01/07/02 - DDL LCR
Rem    alakshmi    12/10/01 - Created
Rem

@@catxlcr1.sql

begin
  dbms_xmlschema.registerSchema(schemaURL => lcr$_xml_schema.CONFIGURL, 
                                schemaDoc => lcr$_xml_schema.CONFIGXSD_10101,
                                local => FALSE,
                                genTypes => TRUE,
                                genBean => FALSE,
                                genTables => FALSE,
                                force => FALSE);
end;
/

                           
