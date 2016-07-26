Rem
Rem $Header: rdbms/admin/catnacl.sql /st_rdbms_11.2.0/3 2012/01/11 10:48:13 rpang Exp $
Rem
Rem catnacl.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnacl.sql - Network ACL
Rem
Rem    DESCRIPTION
Rem      This script creates the tables and views required to define the
Rem      access control list (ACL) for PL/SQL network-related utility packages.
Rem
Rem    NOTES
Rem      This script should be run as "SYS".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       01/06/12 - Backport rpang_bug-11877463 from main
Rem    rpang       06/14/11 - Show privilege fullname
Rem    rpang       03/16/11 - 11878452: same CMNT in impcalloutreg$ for same TAG
Rem    rpang       02/08/11 - Add export support
Rem    rpang       03/04/09 - Use standard XML operators
Rem    rpang       02/15/08 - Add wallet ACL
Rem    rpang       06/27/07 - Commit netaclsc.xml changes
Rem    rpang       05/03/07 - Relocate resource config creation
Rem    rpang       04/06/07 - DBA_NETWORK_ACL_PRIVILEGES query against XDS_ACE
Rem    rpang       03/13/07 - Use ACLID
Rem    rpang       01/04/07 - Remove timestamp cast
Rem    rpang       09/21/06 - Handle ACE start_date and end_date
Rem    rpang       08/16/06 - Updated
Rem    rpang       06/13/06 - Created
Rem

Rem
Rem ACL host assignments storage
Rem

create table NET$_ACL
(
  HOST               varchar2(1000) not null,                /* network host */
  LOWER_PORT         number(5),                 /* lower bound of port range */
  UPPER_PORT         number(5),                 /* upper bound of port range */
  ACLID              raw(16) not null                       /* ACL object ID */
)
/

Rem
Rem ACL wallet assignments storage
Rem

create table WALLET$_ACL
(
  WALLET_PATH        varchar2(1000) not null,                 /* wallet path */
  ACLID              raw(16) not null                       /* ACL object ID */
)
/

Rem
Rem DBA network ACL assignments view
Rem

create or replace view DBA_NETWORK_ACLS
(HOST, LOWER_PORT, UPPER_PORT, ACL, ACLID)
as
select a.host, a.lower_port, a.upper_port, r.any_path, a.aclid
  from net$_acl a, resource_view r
 where sys_op_r2o(XMLCast(XMLQuery(
         'declare default element namespace "http://xmlns.oracle.com/xdb/XDBResource.xsd"; fn:data(/Resource/XMLRef)'
         passing r.res returning content) as ref XMLType)) = a.aclid
/
create or replace public synonym DBA_NETWORK_ACLS for DBA_NETWORK_ACLS
/
grant select on DBA_NETWORK_ACLS to select_catalog_role
/
comment on table DBA_NETWORK_ACLS is
'Access control lists assigned to restrict access to network hosts through PL/SQL network utility packages'
/
comment on column DBA_NETWORK_ACLS.HOST is
'Network host'
/
comment on column DBA_NETWORK_ACLS.LOWER_PORT is
'Lower bound of the port range'
/
comment on column DBA_NETWORK_ACLS.UPPER_PORT is
'Upper bound of the port range'
/
comment on column DBA_NETWORK_ACLS.ACL is
'The path of the access control list'
/
comment on column DBA_NETWORK_ACLS.ACLID is
'The object ID of the access control list'
/

Rem
Rem DBA network ACL privileges view
Rem

create or replace view DBA_NETWORK_ACL_PRIVILEGES
(ACL, ACLID, PRINCIPAL, PRIVILEGE, IS_GRANT, INVERT, START_DATE, END_DATE)
as
select r.any_path, x.aclid, x.principal, p.privilege, x.is_grant,
       x.invert, x.start_date, x.end_date
  from resource_view r, xds_ace x,
       xmltable(xmlnamespaces('http://xmlns.oracle.com/xdb/acl.xsd' as "a"),
                '/a:privilege/*' passing x.privilege
                columns privilege varchar2(23) path 'fn:local-name(.)') p
 where x.aclid = sys_op_r2o(XMLCast(XMLQuery(
                   'declare default element namespace "http://xmlns.oracle.com/xdb/XDBResource.xsd"; fn:data(/Resource/XMLRef)'
                   passing r.res returning content) as ref XMLType)) and
       x.aclid in (select aclid from net$_acl)
/
create or replace public synonym DBA_NETWORK_ACL_PRIVILEGES
for DBA_NETWORK_ACL_PRIVILEGES
/
grant select on DBA_NETWORK_ACL_PRIVILEGES to select_catalog_role
/
comment on table DBA_NETWORK_ACL_PRIVILEGES is
'Privileges defined in network access control lists'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.ACL is
'The path of the access control list'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.ACLID is
'The object ID of the access control list'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.PRINCIPAL is
'Principal the privilege is applied to'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.PRIVILEGE is
'Privilege'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.IS_GRANT is
'Is the privilege granted or denied'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.INVERT is
'true if the access control entry contains invert principal, false otherwise'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.START_DATE is
'Start-date of the access control entry'
/
comment on column DBA_NETWORK_ACL_PRIVILEGES.END_DATE is
'End-date of the access control entry'
/


Rem
Rem DBA wallet ACL assignments view
Rem

create or replace view DBA_WALLET_ACLS
(WALLET_PATH, ACL, ACLID)
as
select a.wallet_path, r.any_path, a.aclid
  from wallet$_acl a, resource_view r
 where sys_op_r2o(extractValue(r.res, '/Resource/XMLRef')) = a.aclid
/
create or replace public synonym DBA_WALLET_ACLS for DBA_WALLET_ACLS
/
grant select on DBA_WALLET_ACLS to select_catalog_role
/
comment on table DBA_WALLET_ACLS is
'Access control lists assigned to restrict access to wallets through PL/SQL network utility packages'
/
comment on column DBA_WALLET_ACLS.WALLET_PATH is
'Wallet path'
/
comment on column DBA_WALLET_ACLS.ACL is
'The path of the access control list'
/
comment on column DBA_WALLET_ACLS.ACLID is
'The object ID of the access control list'
/

Rem Create network ACL security class

DECLARE
  b BOOLEAN;

  procedure add_privilege(priv in varchar2, title in varchar2) is
    XDBRES_NS   constant varchar2(80) :=
                       'xmlns:r="http://xmlns.oracle.com/xdb/XDBResource.xsd"';
    XS_NS       constant varchar2(80) :=
                       'xmlns:xs="http://xmlns.oracle.com/xs"';
  begin
    update resource_view r
       set r.res =
             appendChildXML(r.res, '/r:Resource/r:Contents/xs:securityClass',
               XMLType('<xs:privilege name="'||priv||'" '||XS_NS||'>
                          <xs:title>'||title||'</xs:title>    
                        </xs:privilege>'),
               XDBRES_NS||' '||XS_NS)
     where equals_path(r.res, '/sys/apps/plsql/xs/netaclsc.xml') = 1 and
           not XMLExists(
         'declare namespace r  = "http://xmlns.oracle.com/xdb/XDBResource.xsd";
          declare namespace xs = "http://xmlns.oracle.com/xs";
          /r:Resource/r:Contents/xs:securityClass/xs:privilege[@name=$priv]'
         passing res, priv as "priv");
  end;

BEGIN

  if (NOT DBMS_XDB.existsResource('/sys/apps/plsql')) then
    b := dbms_xdb.createFolder('/sys/apps/plsql');
  end if;
  if (NOT DBMS_XDB.existsResource('/sys/apps/plsql/xs')) then
    b := dbms_xdb.createFolder('/sys/apps/plsql/xs');
  end if;

  if (NOT DBMS_XDB.existsResource('/sys/apps/plsql/xs/netaclsc.xml')) then
    b := DBMS_XDB.createResource(
      '/sys/apps/plsql/xs/netaclsc.xml',
      '<securityClass xmlns="http://xmlns.oracle.com/xs"
                      xmlns:dav="DAV:"
                      xmlns:plsql="http://xmlns.oracle.com/plsql"
                      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.oracle.com/xs
                             http://xmlns.oracle.com/xs/securityclass.xsd"
         targetNamespace="http://xmlns.oracle.com/plsql" name="network">
         <title>
           PL/SQL Network ACL Privileges
         </title>
         <inherits-from>dav:dav</inherits-from>
         <privilege name="connect">
           <title>
             Connect host privilege
           </title>
         </privilege>
         <privilege name="resolve">
           <title>
             Resolve host name and IP address privilege
           </title>
         </privilege>
         <privilege name="use-client-certificates">
           <title>
             Use client certificates in wallets
           </title>    
         </privilege>
         <privilege name="use-passwords">
           <title>
             Use password credentials in wallets
           </title>    
         </privilege>
       </securityClass>');
  else
    add_privilege('use-client-certificates',
                  'Use client certificates in wallets');
    add_privilege('use-passwords',
                  'Use password credentials in wallets');
  end if;

END;
/

Rem Register ACL registration tables for export

delete from sys.impcalloutreg$ where tgt_schema = 'SYS' and
                                     tgt_object = 'NET$_ACL' and
                                     tgt_type   = 2
/
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
  values ('DBMS_NETWORK_ACL_ADMIN', 'SYS', 'NETWORK_ACL', 3, 1000, 0,
          'SYS', 'NET$_ACL', 2, 'Network ACL registrations')
/

delete from sys.impcalloutreg$ where tgt_schema = 'SYS' and
                                     tgt_object = 'WALLET$_ACL' and
                                     tgt_type   = 2
/
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
  values ('DBMS_NETWORK_ACL_ADMIN', 'SYS', 'NETWORK_ACL', 3, 1000, 0,
          'SYS', 'WALLET$_ACL', 2, 'Network ACL registrations')
/

commit;
