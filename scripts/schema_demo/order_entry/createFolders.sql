Rem
Rem $Header: createFolders.sql 23-sep-2004.13:45:32 cbauwens Exp $
Rem
Rem createFolders.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      createFolders.sql - Create Repository Folder Hierarchy
Rem
Rem    DESCRIPTION
Rem      .
Rem
Rem    NOTES
Rem      .
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cbauwens    09/23/04 - cbauwens_bug3031915
Rem    cbauwens    03/16/04 - Created 

DECLARE
  res BOOLEAN;
BEGIN
  res := DBMS_XDB.createFolder('/home/OE/xsd');
  res := DBMS_XDB.createFolder('/home/OE/xsl');
  res := DBMS_XDB.createFolder('/home/OE/PurchaseOrders');
END;
/
