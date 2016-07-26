Rem
Rem $Header: rdbms/admin/xdbeo101.sql /main/2 2010/01/07 06:14:56 badeoti Exp $
Rem
Rem xdbeo101.sql
Rem
Rem Copyright (c) 2007, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbeo101.sql - XDB downgradE Drop objects for downgrade to 10.1
Rem
Rem    DESCRIPTION
Rem      This script drops objects and performs other downgrade actions
Rem      that would invalidate other objects used during the XDB
Rem      downgrade processing.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    badeoti     12/18/09 - fix config table access privs
Rem    rburns      11/11/07 - move object downgrade actions
Rem    rburns      11/08/07 - drop objects for XDB
Rem    rburns      11/08/07 - Created
Rem

Rem ================================================================
Rem BEGIN XDB Object downgrade to 10.2.0
Rem ================================================================

@@xdbeo102.sql

Rem ================================================================
Rem END XDB Object downgrade to 10.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Object downgrade to 10.1.0
Rem ================================================================


-- drop embedded PL/SQL gateway objects
drop package dbms_epg;
drop public synonym dbms_epg;
drop public synonym user_epg_dad_authorization;
drop view user_epg_dad_authorization;
drop public synonym dba_epg_dad_authorization;
drop view dba_epg_dad_authorization;
drop table epg$_auth;

-- to downgrade for XMLIndex
drop view DBA_XML_INDEXES;
drop view USER_XML_INDEXES;
drop view ALL_XML_INDEXES;

drop table xdb.xdb$dxptab;
drop table xdb.xdb$dxpath;
drop indextype xdb.xmlindex;

drop table xdb.xdb$nmspc_id;
drop table xdb.xdb$qname_id;
drop table xdb.xdb$path_id;

drop package xdb.dbms_xmlschema_int;
drop package sys.DBMS_REGXDB;
drop package xdb.DBMS_XMLINDEX;
drop package xdb.XDB$BOOTSTRAP;
drop package xdb.XDB$BOOTSTRAPRES;


-- Remove WS roles
declare
  dropped_role EXCEPTION;
  PRAGMA EXCEPTION_INIT(dropped_role, -01919);
begin
  execute immediate 'drop role XDBWEBSERVICES';
  execute immediate 'drop role XDBWEBSERVICESWITHPUBLIC';
  execute immediate 'drop role XDBWEBSERVICESOVERHTTP';
exception when dropped_role then
  NULL;
end;
/

-- Grant XDBADMIN privileges on xdbconfig
-- Revoke PUBLIC access to xdbconfig
-- Ensure that public has limited privileges on acl table
--  even though PUBLIC in 10.1.0.5 release has all privs granted on acl table
--   and select granted on config table (see bugs 3824417 and 9223714)
revoke all on XDB.XDB$CONFIG from public;
grant  all on XDB.XDB$CONFIG to xdbadmin;
revoke all on XDB.XDB$ACL from public;
grant  select, insert, update, delete on XDB.XDB$ACL to public;
commit;

Rem ================================================================
Rem BEGIN XDB Object downgrade to 10.1.0
Rem ================================================================
