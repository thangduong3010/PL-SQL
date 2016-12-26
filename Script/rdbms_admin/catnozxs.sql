Rem
Rem $Header: rdbms/admin/catnozxs.sql /main/2 2010/06/06 21:49:30 snadhika Exp $
Rem
Rem catnozxs.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnozxs.sql - for removing (NO) XS
Rem
Rem    DESCRIPTION
Rem      This script is invoked at the beginning of catnoqm.sql
Rem
Rem    NOTES
Rem      Schema tables are deleted in catnoqm.sql. All objects are under 'SYS'
Rem      unless qualified with a different schema.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    snadhika    04/14/10 - Remove PREDICATE xmlindex
Rem    yiru        03/25/09 - Created
Rem


Rem =================================================================
Rem Drop all index
Rem =================================================================
-- Drop xml index for xs$securityclass
--drop index xdb.sc_xidx;

-- Drop index on xs$principals
--drop index xdb.prin_xidx;

Rem =================================================================
Rem Drop all XS public syonyms 
Rem =================================================================

-- tables' synonym
 --* in catzxs.sql
drop public synonym XS$CACHE_DELETE;
drop public synonym XS$CACHE_ACTIONS;

-- views' synonym
  -- *in catnacl.sql invoked by catzxs
drop public synonym DBA_NETWORK_ACLS;
drop public synonym DBA_NETWORK_ACL_PRIVILEGES;
drop public synonym DBA_WALLET_ACLS;

  -- *in xsrelod.sql invoked by catzxs
drop public synonym DBA_XDS_OBJECTS;
drop public synonym ALL_XDS_OBJECTS;
drop public synonym USER_XDS_OBJECTS;
drop public synonym DBA_XDS_INSTANCE_SETS;
drop public synonym ALL_XDS_INSTANCE_SETS;
drop public synonym USER_XDS_INSTANCE_SETS;
drop public synonym DBA_XDS_ATTRIBUTE_SECS;
drop public synonym ALL_XDS_ATTRIBUTE_SECS;
drop public synonym USER_XDS_ATTRIBUTE_SECS;
drop public synonym DOCUMENT_LINKS2;
drop public synonym ALL_XSC_SECURITY_CLASS;
drop public synonym ALL_XSC_SECURITY_CLASS_STATUS;
drop public synonym ALL_XSC_SECURITY_CLASS_DEP;
drop public synonym ALL_XSC_PRIVILEGE;
drop public synonym ALL_XSC_AGGREGATE_PRIVILEGE;
drop public synonym XS_SESSION_ROLES;
drop public synonym V$XS_SESSION;
drop public synonym V$XS_SESSION_ROLE;
drop public synonym V$XS_SESSION_ATTRIBUTE;

 -- *in dbmsnacl.sql invoked by xsrelod
drop public synonym USER_NETWORK_ACL_PRIVILEGES;

-- packages' synonym
 -- *in dbmsnacl.sql invoked by xsrelod
drop public synonym dbms_network_acl_utility;
drop public synonym dbms_network_acl_admin;

 -- *in prvtkzxh.sql 
drop public synonym DBMS_XS_MTCACHE;

 -- *in prvtkzxv.sql 
drop public synonym DBMS_XS_UTIL;

Rem =================================================================
Rem Drop all XS views
Rem =================================================================
-- in catnacl.sql invoked by catzxs
drop view DBA_NETWORK_ACLS;
drop view DBA_NETWORK_ACL_PRIVILEGES;
drop view DBA_WALLET_ACLS;

-- in xsrelod.sql invoked by catzxs
drop view DBA_XDS_OBJECTS;
drop view ALL_XDS_OBJECTS;
drop view USER_XDS_OBJECTS;
drop view DBA_XDS_INSTANCE_SETS;
drop view ALL_XDS_INSTANCE_SETS;
drop view USER_XDS_INSTANCE_SETS;
drop view DBA_XDS_ATTRIBUTE_SECS;
drop view ALL_XDS_ATTRIBUTE_SECS;
drop view USER_XDS_ATTRIBUTE_SECS;
drop view XDB.DOCUMENT_LINKS2;
drop view ALL_XSC_SECURITY_CLASS;
drop view ALL_XSC_SECURITY_CLASS_STATUS;
drop view ALL_XSC_SECURITY_CLASS_DEP;

drop view ALL_XSC_PRIVILEGE;
drop view ALL_XSC_AGGREGATE_PRIVILEGE;
drop view V$XS_SESSION;
drop view V$XS_SESSION_ROLE;
drop view V$XS_SESSION_ATTRIBUTE;

--in dbmsnacl.sql invoked by xsrelod
drop view USER_NETWORK_ACL_PRIVILEGES;

Rem =================================================================
Rem Drop all XS tables
Rem =================================================================
-- in catzxs.sql
drop table XDB.XS$CACHE_ACTIONS;
drop table XDB.XS$CACHE_DELETE;

-- in catnacl.sql invoked by catzxs
drop table NET$_ACL;
drop table WALLET$_ACL;

Rem =================================================================
Rem Drop all XS packages
Rem =================================================================
-- in xsrelod.sql
drop package XS$CATVIEW_UTIL;

-- in prvtkzxu.sql invoked by xsrelod
drop package DBMS_XS_PRINCIPALS;
drop package DBMS_XS_PRINCIPALS_INT;

-- in prvtkzxevents.sql invoked by xsrelod
drop package DBMS_XS_ROLESET_EVENTS_INT;
drop package DBMS_XS_PRINCIPAL_EVENTS_INT;
drop package DBMS_XS_DATA_SECURITY_EVENTS;
drop package DBMS_XS_SECCLASS_EVENTS;

-- in prvtkzxh.sql invoked by xsrelod
drop package DBMS_XS_MTCACHE;
drop package DBMS_XS_MTCACHE_FFI;

-- in prvtkzxv.sql invoked by xsrelod
drop package XS_UTIL;

-- in dbmsacl.sql invoked by xsrelod
drop package dbms_network_acl_admin;
drop package dbms_network_acl_utility;

Rem =================================================================
Rem Drop all XS users
Rem =================================================================
drop user XS$NULL cascade;
