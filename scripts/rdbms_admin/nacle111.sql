Rem
Rem $Header: rdbms/admin/nacle111.sql /main/1 2009/03/31 12:16:05 rpang Exp $
Rem
Rem nacle111.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      nacle111.sql - Downgrade script for PL/SQL network security
Rem
Rem    DESCRIPTION
Rem      Downgrade script for PL/SQL network security
Rem
Rem    NOTES
Rem      None
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       03/30/09 - Created
Rem

Rem Restore old XDB operators in network ACL views
create or replace view DBA_NETWORK_ACLS
(HOST, LOWER_PORT, UPPER_PORT, ACL, ACLID)
as
select a.host, a.lower_port, a.upper_port, r.any_path, a.aclid
  from net$_acl a, resource_view r
 where sys_op_r2o(extractValue(r.res, '/Resource/XMLRef')) = a.aclid
/

create or replace view DBA_NETWORK_ACL_PRIVILEGES
(ACL, ACLID, PRINCIPAL, PRIVILEGE, IS_GRANT, INVERT, START_DATE, END_DATE)
as
select r.any_path, x.aclid, x.principal, p.privilege, x.is_grant,
       x.invert, x.start_date, x.end_date
  from resource_view r, xds_ace x,
       xmltable(xmlnamespaces('http://xmlns.oracle.com/xdb/acl.xsd' as "a"),
                '/a:privilege/*' passing x.privilege
                columns privilege varchar2(7) path 'fn:local-name(.)') p
 where x.aclid = sys_op_r2o(extractValue(r.res, '/Resource/XMLRef')) and
       x.aclid in (select aclid from net$_acl)
/
