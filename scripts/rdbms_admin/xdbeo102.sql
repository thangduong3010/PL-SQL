Rem
Rem $Header: rdbms/admin/xdbeo102.sql /main/2 2009/12/14 15:40:04 spetride Exp $
Rem
Rem xdbeo102.sql
Rem
Rem Copyright (c) 2007, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbeo102.sql - XDB downgradE Drop objects for downgrade to 10.2
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
Rem    spetride    12/07/09 - 9065059: xml indexes should be dropped before migrate
Rem    rburns      12/20/07 - move new actions to xdbeo102.sql
Rem    rburns      11/08/07 - drop objects for XDB
Rem    rburns      11/08/07 - Created
Rem

Rem ================================================================
Rem BEGIN XDB Object downgrade to 11.1.0
Rem ================================================================

@@xdbeo111.sql

Rem ================================================================
Rem END XDB Object downgrade to 11.1.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Object downgrade to 10.2.0
Rem ================================================================

-- downgrade for xmlindex
drop function sys.stragg;
drop type sys.string_agg_type;

Rem The indextype needs to be recreated
drop indextype XDB.XMLIndex force;
drop operator XDB.xmlindex_noop force;
drop package XDB.XMLIndex_FUNCIMPL;
drop type xdb.XMLIndexMethods force;
drop indextype SYS.XMLTableIndex force;
drop type SYS.XMLTABLEINDEXMETHODS force;
drop package SYS.XMLTABLEINDEX_FUNCIMPL;
drop operator SYS.XMLTABLEINDEX_GETNODES force;

Rem Drop index xdb$idxptab
drop index xdb.xdb$idxptab;

Rem Drop table xdb$dxptab. This table and its index xdb.xdb$idxptab are
Rem recreated in 10.2 when catxidx.sql is run during reload.
drop table xdb.xdb$dxptab;

Rem drop table used by xmlindex exp/imp
drop table xdb.xdb$xidx_imp_t;

revoke select on xdb.xdb$rclist_v from public;

drop view xdb.xdb$rclist_v;

--remove rclist column from root_info table
alter table xdb.xdb$root_info drop column rclist;
--remove protocol columns from root_info table
alter table xdb.xdb$root_info drop column ftp_port;
alter table xdb.xdb$root_info drop column ftp_protocol;
alter table xdb.xdb$root_info drop column http_port;
alter table xdb.xdb$root_info drop column http_protocol;
alter table xdb.xdb$root_info drop column http_host;
alter table xdb.xdb$root_info drop column http2_port;
alter table xdb.xdb$root_info drop column http2_protocol;
alter table xdb.xdb$root_info drop column http2_host;
alter table xdb.xdb$root_info drop column nfs_port;
alter table xdb.xdb$root_info drop column nfs_protocol;

--downgrade for dbmsxres.sql
revoke execute on xdb.dbms_xdbresource from public;
drop public synonym dbms_xdbresource;
drop package xdb.dbms_xdbresource;

--downgrade for dbmsxrc.sql
revoke execute on xdb.dbms_resconfig from public;
drop public synonym dbms_resconfig;
drop package xdb.dbms_resconfig;

--downgrade for dbmsxev.sql
revoke execute on xdb.dbms_XEvent from public;
drop public synonym DBMS_XEvent;
drop package xdb.dbms_XEvent;
revoke execute on xdb.xdb_privileges from public;

--downgrade for dbmsxdba.sql
revoke execute on xdb.dbms_xdb_admin from DBA;
drop public synonym DBMS_XDB_ADMIN;
drop package xdb.dbms_xdb_admin;

--downgrade for xdbinstd.sql
drop table XDB.XDB$NONCEKEY; 

--downgrade for dbmsxmls.sql
drop public synonym XMLBinaryInputStream;
drop public synonym XMLBinaryOutputStream;
drop public synonym XMLCharacterInputStream;
drop public synonym XMLCharacterOutputStream;

drop type XMLBinaryInputStream;
drop type XMLBinaryOutputStream;
drop type XMLCharacterInputStream;
drop type XMLCharacterOutputStream;

-- The fix for 4931915, which went into 11g, modified setmodflg (defined in 
-- prvtxdbz.sql) and moved it from the xdb schema to the sys schema. Hence, 
-- drop procedure in sys schema during downgrade. 
drop procedure sys.setmodflg;

drop procedure sys.get_table_name;

drop function sys.is_vpd_enabled;


drop type xdb.xdb$LockTokenListType;

-------------------------------------------------------------------------------
-- H_index related changes
-------------------------------------------------------------------------------
-- change xdb.xdb$h_link from regular table to IOT
drop table xdb.xdb$h_link_tmp;

create table xdb.xdb$h_link_tmp 
as select parent_oid, child_oid, name, flags, link_sn
from xdb.xdb$h_link;

drop table xdb.xdb$h_link;
drop type xdb.xdb$link_t;

create type xdb.xdb$link_t OID '00000000000000000000000000020151' AS OBJECT
(
    parent_oid    raw(16),
    child_oid     raw(16),
    name          varchar2(256),
    flags         raw(4),
    link_sn       raw(16)
);
/

create table xdb.xdb$h_link of xdb.xdb$link_t
(
    constraint xdb_pk_h_link primary key (parent_oid, name)
) organization index
as select * from xdb.xdb$h_link_tmp;

--downgrade for prvtxdbdl.sql
revoke execute on xdb.XDB_DLTRIG_PKG from public;
drop package xdb.XDB_DLTRIG_PKG;

create index xdb.xdb_h_link_child_oid on xdb.xdb$h_link(child_oid);
drop table xdb.xdb$h_link_tmp;
drop package xdb.dbms_xdbadmin;


-- XDB no longer needs execute on dbms_streams_control_adm
revoke execute on dbms_streams_control_adm from xdb;

-- drop csx packages, revoke corresponding rights
revoke execute on xdb.dbms_csx_int from public;
drop public synonym dbms_csx_int;
drop package xdb.dbms_csx_int;

revoke execute on xdb.dbms_csx_admin from DBA;
drop public synonym dbms_csx_admin;
drop package xdb.dbms_csx_admin;

--token tables downgrade 

declare
  xdb10   number;
  guid    raw(16);
  suf     varchar2(26);
  stmt    varchar2(2000);
  bsz     number;
  nmspc_tok_chars  number;
  qname_tok_chars  number;
begin
 xdb10 :=0;
 stmt := 'select count(*) from dba_tables where (owner = ''' || 'XDB' || ''') and  (table_name = ''' || 'XDB$QNAME_ID' || ''')';
 execute immediate stmt into xdb10;

 if (xdb10 = 0) then  
   stmt := 'select toksuf from XDB.XDB$TTSET where (flags = 0)';
   execute immediate stmt into suf;

   stmt := 'alter index  xdb.x$nn' || suf || ' rename to xdb$nmspc_id_nmspcuri';
   execute immediate stmt;
   stmt := 'alter index  xdb.x$ni' || suf || ' rename to xdb$nmspc_id_id';
   execute immediate stmt;
 
   stmt := 'alter index xdb.x$qs' || suf || ' rename to xdb$qname_id_nmspcid';
   execute immediate stmt;
   stmt := 'alter index xdb.x$qq' || suf || ' rename to xdb$qname_id_qname';
   execute immediate stmt;
   stmt := 'alter index xdb.x$qi' || suf || ' rename to xdb$qname_id_id';
   execute immediate stmt;

   stmt := 'alter index xdb.x$pp' || suf || ' rename to xdb$path_id_path';
   execute immediate stmt;
   stmt := 'alter index xdb.x$pi' || suf || ' rename to xdb$path_id_id';
   execute immediate stmt;
   stmt := 'alter index xdb.x$pr' || suf || ' rename to xdb$path_id_revpath';
   execute immediate stmt; 

   stmt := 'alter table xdb.x$qn' || suf || ' rename to xdb$qname_id';
   execute immediate stmt;
   stmt := 'alter table xdb.x$nm' || suf || ' rename to xdb$nmspc_id';
   execute immediate stmt;
   stmt := 'alter table xdb.x$pt' || suf || ' rename to xdb$path_id';
   execute immediate stmt;

   -- change token tables from varchar2 back to nvarchar2
   select t.block_size into bsz from user_tablespaces t, user_users u
      where u.default_tablespace = t.tablespace_name;

   if bsz < 4096 then
      nmspc_tok_chars := 464;
      qname_tok_chars := 460;
   elsif bsz < 8192 then
      nmspc_tok_chars := 984;
      qname_tok_chars := 979;
   else
      nmspc_tok_chars := 2000;
      qname_tok_chars := 2000;
   end if;
   stmt := 'alter table xdb.xdb$qname_id modify  ' ||
           ' localname nvarchar2( ' || qname_tok_chars || ')';
   execute immediate stmt;
   stmt := 'alter table xdb.xdb$nmspc_id modify ' ||
           ' nmspcuri nvarchar2( ' || nmspc_tok_chars || ')';
   execute immediate stmt;   


   execute immediate 'drop table xdb.xdb$ttset';

   stmt := 'delete from sys.exppkgact$ where (package = ''' || 'DBMS_CSX_ADMIN' || ''' )';
   execute immediate stmt;
   stmt := 'delete from sys.expdepact$ where (schema = ''' || 'XDB' || ''' )';
   execute immediate stmt;
 end if;
   exception
     when OTHERS then
       if sqlcode != -942 then 
          raise;
       else 
          return;
       end if;
end;
/

commit;


drop view sys.XDS_ACL;
drop view sys.XDS_ACE;

--downgrade for dbmsxtr.sql
revoke execute on xdb.dbms_xmltranslations from public;
drop public synonym dbms_xmltranslations;
drop package xdb.dbms_xmltranslations;


-- downgrade for document links
-- drop all $dl triggers on xmltype tables (which process document links)
declare
  trgnm    VARCHAR2(30);
  owner    VARCHAR2(30);
  sql_txt  VARCHAR2(100);
  cursor crsr is
    select owner, trigger_name from all_triggers where trigger_name like '%$dl%';
begin
  open crsr;
  loop
    fetch crsr into owner, trgnm;
    exit when crsr%NOTFOUND;
    sql_txt := 'drop trigger "' || owner || '"."' || trgnm || '"';
    execute immediate sql_txt;
  end loop;
  close crsr;
end;
/

drop public synonym DOCUMENT_LINKS;

drop view XDB.DOCUMENT_LINKS;


drop table xdb.xdb$d_link;

-- downgrade for acl index (prvtxdz2.plb)
drop package xdb.xdb$acl_pkg_int;
-- by now, we should have already dropped this index
begin
  execute immediate 'drop index xdb.xdb$acl_xidx force';
  commit;
  exception
     when OTHERS then
        if (SQLCODE = - 1418) then
          NULL;
        end if;
end;
/

-- Every XDB-owned XML indexes should be dropped before this line
-- Dropped in xdbes102.sql but dba_xml_indexes invalid by now (ORA-04063)
-- So commenting out this check.
Rem Raise error if there are any XDB-owned XML indexes
--DECLARE
--   cnt                 NUMBER;
--   xix_downgrade_error exception;
--   PRAGMA EXCEPTION_INIT(xix_downgrade_error, -30957);
--   missing exception;
--   PRAGMA EXCEPTION_INIT(missing, -942);
--BEGIN
--   execute immediate 'select count(*) from dba_xml_indexes xi
--    where xi.index_owner = ''XDB''' into cnt;
--   IF cnt != 0 THEN
--     RAISE xix_downgrade_error;
--   END IF;
--exception
--   when missing then NULL;
--   when OTHERS then RAISE;
--END;
--/

--remove New WS roles
declare
  dropped_role EXCEPTION;
  PRAGMA EXCEPTION_INIT(dropped_role, -01919);
begin
  execute immediate 'drop role XDB_WEBSERVICES';
  execute immediate 'drop role XDB_WEBSERVICES_WITH_PUBLIC';
  execute immediate 'drop role XDB_WEBSERVICES_OVER_HTTP';
exception when dropped_role then
  NULL;
end;
/

--add old WS roles
declare
  role_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(role_exists, -01921);
begin
  execute immediate 'create role XDBWEBSERVICES';
  execute immediate 'create role XDBWEBSERVICESWITHPUBLIC';
  execute immediate 'create role XDBWEBSERVICESOVERHTTP';
exception when role_exists then
  NULL;
end;
/

Rem ================================================================
Rem END XDB Object downgrade to 10.2.0
Rem ================================================================
