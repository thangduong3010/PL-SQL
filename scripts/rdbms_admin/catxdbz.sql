Rem
Rem $Header: catxdbz.sql 28-jan-2008.16:28:00 thbaby Exp $
Rem
Rem catxdbz.sql
Rem
Rem Copyright (c) 2001, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbz.sql - xdb security initialization
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      01/28/08 - fix lrg 3280065
Rem    thbaby      12/06/07 - enable hierarchy on schema table
Rem    mrafiq      01/08/07 - pass flag to register_dav_schema
Rem    sidicula    01/13/07 - Restrict privileges on ACL tab
Rem    abagrawa    03/14/06 - Move dav schema to catxdav.sql 
Rem    abagrawa    03/11/06 - Invoke catxdbh 
Rem    thbaby      10/22/05 - put lock privilege back in 
Rem    thbaby      03/23/05 - remove lock privilege 
Rem    thbaby      01/17/05 - Add new privileges
Rem    mrafiq      09/20/05 - merging changes for upgrade/downgrade 
Rem    thoang      04/29/04 - define catxdbz0.sql 
Rem    ataracha    04/23/04 - add write-config
Rem    thbaby      01/17/05 - Add new privileges
Rem    fge         07/07/04 - set xdb$h_link child_acloid 
Rem    thbaby      02/16/05 - Remove all_xdbadmin_acl.xml
Rem    abagrawa    09/01/04 - Add all_xdbadmin_acl.xml 
Rem    nmontoya    01/13/03 - ADD collection AND principalformat TO acl schema
Rem    nmontoya    03/14/02 - change priv names TO link-to AND unlink-from
Rem    nmontoya    03/13/02 - USE dbms_xdbz0.initXDBSecurity
Rem    njalali     02/19/02 - granting all privs on ACL table to PUBLIC
Rem    rmurthy     02/14/02 - fix descriptions
Rem    nmontoya    02/21/02 - add link, unlink, linkto, unlinkfrom privileges
Rem    rmurthy     01/30/02 - make privilege a global element
Rem    rmurthy     01/18/02 - new ACL schema
Rem    rmurthy     12/28/01 - set elementForm to qualified
Rem    rmurthy     12/26/01 - change to 2001 xmlschema-instance namespace
Rem    spannala    12/27/01 - xdb setup should run as sys
Rem    najain      11/26/01 - use XDB instead of xdb
Rem    rmurthy     12/17/01 - fix ACL schema
Rem    nagarwal    11/12/01 - change ordering of packages
Rem    nmontoya    11/04/01 - indent acl schema, ADD system acls
Rem    nmontoya    10/29/01 - USE dbms_xdb.createresource
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    nmontoya    10/18/01 - disable hierarchy FROM xdb$schema 
Rem    nmontoya    10/12/01 - ADD xdbadmin TO bootstrap acl
Rem    rmurthy     08/31/01 - change to xml binary type
Rem    rmurthy     08/03/01 - change XDB namespace
Rem    bkhaladk    08/03/01 - fix acl xmls.
Rem    njalali     07/18/01 - More resource as XMLType
Rem    njalali     07/17/01 - Resource as XMLType
Rem    nmontoya    07/05/01 - bootstrap acl inserts using pl/sql wrappers
Rem    sichandr    05/30/01 - add temporary connect
Rem    spannala    05/18/01 - xmltype_p ->xmltype
Rem    rmurthy     05/09/01 - remove conn as sysdba, add SQL type names
Rem    bkhaladk    03/20/01 - add param to register schema.
Rem    nmontoya    03/18/01 - user privileges
Rem    nmontoya    03/14/01 - schoid and elnum for acl schema.
Rem    rmurthy     03/08/01 - changes for new xmlschema
Rem    nmontoya    02/02/01 - Created
Rem

-- User must be XDB  
  
BEGIN
   xdb.dbms_xdbz.enable_hierarchy ('XDB', 'XDB$SCHEMA');
   xdb.dbms_xdbz.disable_hierarchy('XDB', 'XDB$SCHEMA');
END;
/

Rem Create register schema package
@@catxdbh

Rem Register required system schemas before calling initXDBSecurity() to
Rem initialize the SGA & UGA cache
@@catxdbz0

call xdb.dbms_xdbz0.initXDBSecurity();

-- Enable XRLS hierarchy priv check for xdb$acl and xdb$schema tables
BEGIN
   xdb.dbms_xdbz.enable_hierarchy('XDB', 'XDB$ACL');
   -- xdb.dbms_xdbz.enable_hierarchy('XDB', 'XDB$SCHEMA');
END;
/

COMMIT;

Rem Make XDB$ACL writable by all users
grant select, insert, update, delete on XDB.XDB$ACL to public;
commit;

Rem Register the DAV schema
@@catxdav

exec register_dav_schema('dav.xsd.11.0',FALSE);

@@catxdav2
