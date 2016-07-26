Rem
Rem $Header: rdbms/demo/schema/order_entry/xdb03usg.sql /st_rdbms_11.2.0/1 2012/03/28 22:32:42 bhammers Exp $
Rem
Rem coe_xml.sql
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdb03usg.sql - Create XML DB data for user OE
Rem
Rem    DESCRIPTION
Rem      .
Rem
Rem    NOTES
Rem      .
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bhammers    03/27/12 - Backport bhammers_mdrakebugs from main
Rem    celsbern    07/17/09 - added explicit revoke of execute on SUBDIR
Rem                           directory
Rem    celsbern    02/24/09 - renamed XMLDIR to SS_OE_XMLDIR
Rem    cbauwens    05/25/05 - rename nested tables 
Rem    cbauwens    09/23/04 - cbauwens_bug3031915
Rem    cbauwens    03/16/04 - Created

--
--
-- Create Repository Folder Hierarchy
--
@?/demo/schema/order_entry/createFolders.sql


--
-- Load example documents into the XDB repository
--
@?/demo/schema/order_entry/createResources.sql


--
--Register schema
--
BEGIN
  DBMS_XMLSCHEMA.registerSchema('http://localhost:8080/source/schemas/poSource/xsd/purchaseOrder.xsd',
                                XDBURIType('/home/OE/purchaseOrder.xsd').getClob(),
                                TRUE, 
                                TRUE, 
                                FALSE, 
                                TRUE);
END;
/

--
--Rename the cryptic nested tables
--
call coe_utilities.renameCollectionTable ('PURCHASEORDER','"XMLDATA"."LINEITEMS"."LINEITEM"','LINEITEM_TABLE')
/
call coe_utilities.renameCollectionTable ('PURCHASEORDER','"XMLDATA"."ACTIONS"."ACTION"','ACTION_TABLE')
/

--
-- Upload the Directory containing the sample documents
--
BEGIN
 COE_UTILITIES.uploadFiles('filelist.xml', 
                               'SS_OE_XMLDIR', 
                               '/home/OE/PurchaseOrders');
END;
/

-- revoke the grant of execute on the SUBDIR directory 
CONNECT sys/&&pass_sys AS SYSDBA;
 
revoke execute on directory SUBDIR from OE
/
CONNECT OE/&pass_oe
