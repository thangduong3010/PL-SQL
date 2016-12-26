Rem
Rem $Header: catxdav.sql 08-jan-2007.17:47:53 mrafiq Exp $
Rem
Rem catxdav.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdav.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mrafiq      01/08/07 - bug 5726607: register DAV schema as Binary XML
Rem    mrafiq      04/07/06 - cleaning up 
Rem    petam       03/17/06 - 
Rem    abagrawa    03/14/06 - Register DAV schema 
Rem    abagrawa    03/14/06 - Register DAV schema 
Rem    abagrawa    03/14/06 - Created
Rem


@@catxdbh

create or replace procedure register_dav_schema(dav_filename in varchar2, 
	                                        IsDowngrade in boolean) is
  DAVXSD BFILE := dbms_metadata_hack.get_bfile(dav_filename);
  DAVURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/dav.xsd';  
begin

 if IsDowngrade then
   xdb.dbms_xmlschema.registerSchema(DAVURL, DAVXSD, FALSE, TRUE, FALSE, TRUE,
                                     FALSE, 'XDB');
 else
   xdb.dbms_xmlschema.registerSchema(DAVURL, DAVXSD, FALSE, FALSE, FALSE, TRUE,
                                     FALSE, 'XDB', options => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
 end if;
end;
/


