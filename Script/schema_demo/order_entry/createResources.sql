Rem
Rem $Header: rdbms/demo/schema/order_entry/createResources.sql /main/2 2009/02/25 20:16:33 celsbern Exp $
Rem
Rem createResources.sql
Rem
Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      createResources.sql - Load example documents into the XDB repository
Rem
Rem    DESCRIPTION
Rem      .
Rem
Rem    NOTES
Rem      .
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    celsbern    02/24/09 - renamed XMLDIR to SS_OE_XMLDIR
Rem    cbauwens    09/23/04 - cbauwens_bug3031915
Rem    cbauwens    03/16/04 - add empdept 
Rem    cbauwens    03/14/04 - Created 


DECLARE
  res BOOLEAN;
BEGIN
  res := DBMS_XDB.createResource('/home/OE/purchaseOrder.xsd',
                                 bfilename('SS_OE_XMLDIR', 
                                  'purchaseOrder.xsd'),
                                 nls_charset_id('AL32UTF8'));
  res := DBMS_XDB.createResource('/home/OE/purchaseOrder.xsl',
                                 bfilename('SS_OE_XMLDIR', 
                                  'purchaseOrder.xsl'),
                                 nls_charset_id('AL32UTF8'));
                                 
                               
  res := DBMS_XDB.createResource('/home/OE/xsl/empdept.xsl',
                                 bfilename('SS_OE_XMLDIR', 'empdept.xsl'),
                                 nls_charset_id('AL32UTF8'));

END;
/
