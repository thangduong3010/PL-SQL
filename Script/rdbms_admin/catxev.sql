Rem
Rem $Header: catxev.sql 14-nov-2007.11:55:17 yifeng Exp $
Rem
Rem catxev.sql
Rem
Rem Copyright (c) 2005, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxev.sql - script to register XDBResConfig.xsd schema
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    yifeng      11/13/07 - call catxdbh to create dbms_metadata_hack
Rem    thbaby      11/07/07 - use bfile for resconfig schema registration
Rem    jwwarner    08/13/07 - enhance link entry to include pre-condition
Rem    smalde      03/21/07 - Enable hierarchy on XDB$RESCONFIG
Rem    sidicula    01/13/07 - Restrict privileges on ResConfig tab
Rem    vkapoor     12/20/06 - Making Resconfig schema binary
Rem    rmurthy     08/04/06 - add contentformat
Rem    rmurthy     03/13/06 - add SectionConfig 
Rem    thbaby      03/12/06 - disable hierarchy to avoid deadlocks 
Rem    pnath       02/25/06 - add XLink, XInclude resconfig elements 
Rem    mrafiq      09/28/05 - merging changes for upgrade/downgrade
Rem    thoang      09/23/03 - Created

set pages 0
set echo on

-- User must be XDB


Rem Create dbms_metadata_hack
@@catxdbh

Rem Register XDBResConfig.xsd Schema

declare
  XMLNSXSD BFILE := dbms_metadata_hack.get_bfile('rescfg.xsd.11.2');
  XMLNSURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/XDBResConfig.xsd';
begin
  xdb.dbms_xmlschema.registerSchema(XMLNSURL, XMLNSXSD, FALSE, FALSE, FALSE, 
		                    TRUE, FALSE, 'XDB', 
                                   options=>DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end;
/


grant select, insert, update, delete on xdb.xdb$resconfig to public;

-- Add refcount to xdb$resconfig table 
alter session set events='12498 trace name context level 2, forever';
alter table xdb.xdb$resconfig add (refcount number default 0);
alter session set events='12498 trace name context off';

-- The XDB_SET_INVOKER is needed to define an invoker-rights handler in
-- a resource resconfig. 
create role XDB_SET_INVOKER;
grant XDB_SET_INVOKER to DBA;


