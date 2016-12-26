Rem
Rem $Header: rdbms/demo/schema/order_entry/createUser.sql.sbs /st_rdbms_11.2.0/1 2012/03/28 22:32:42 bhammers Exp $
Rem
Rem coe_xml.sql.sbs
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      createUser.sql.sbs - Create a user, directory, and XDB folder
Rem
Rem    DESCRIPTION
Rem      .
Rem
Rem    NOTES
Rem      Instantiates createUser.sql. Sets s_oePath
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bhammers    03/27/12 - Backport bhammers_mdrakebugs from main
Rem    bhammers    02/24/11 - 11790077:do not delete home directory if existent
Rem    bhammers  01/24/11 - bug 11790009: consistent variable name for sys pwd 
Rem    celsbern    07/17/09 - added explicit revoke of execute on directory
Rem                           objects
Rem    celsbern    02/24/09 - renamed XMLDIR to SS_OE_XMLDIR
Rem    cbauwens    09/23/04 - cbauwens_bug3031915
Rem    cbauwens    03/16/04 - Created
            

DECLARE
  targetFolder VARCHAR2(256) := '/home';
  result boolean;
BEGIN
  IF (not DBMS_XDB.existsResource(targetFolder)) THEN
    result := DBMS_XDB.createFolder(targetFolder);
  END IF;

  targetFolder := targetFolder || '/OE';
  if (DBMS_XDB.existsResource(targetFolder)) then
    DBMS_XDB.deleteResource(targetFolder, DBMS_XDB.DELETE_RECURSIVE);
  end if;
  result := DBMS_XDB.createFolder(targetFolder);
  DBMS_XDB.setAcl(targetFolder, '/sys/acls/all_all_acl.xml');
  coe_utilities.createHomeFolder('OE');
END;
/ 

CONNECT OE/&pass_oe

--Create Oracle directory object
DROP DIRECTORY SS_OE_XMLDIR
/
CREATE DIRECTORY SS_OE_XMLDIR as '/u01/app/oracle/product/11.2.0/dbhome_1/demo/schema/order_entry/'
/
COMMIT
/

CONNECT sys/&&pass_sys AS SYSDBA;
 
revoke execute on directory SS_OE_XMLDIR from OE
/
CONNECT OE/&pass_oe


