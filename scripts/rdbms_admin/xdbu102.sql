Rem
Rem $Header: rdbms/admin/xdbu102.sql /st_rdbms_11.2.0/1 2011/06/07 12:30:50 juding Exp $
Rem
Rem xdbu102.sql
Rem
Rem Copyright (c) 2004, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbu102.sql - xdb upgrade from 10.2 release to main.
Rem
Rem    DESCRIPTION
Rem	 XDB upgrade for 102 release
Rem
Rem    NOTES
Rem	 XDB Upgrade document
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    juding      05/26/11 - Backport badeoti_bug-10168805 from main
Rem    vhosur      02/15/10 - Fix for bug 9034494
Rem    badeoti     12/21/09 - ensure limited acl table access privs for public
Rem    spetride    12/09/09 - print acl index status
Rem    badeoti     11/20/09 - load new package defns after xdbs102
Rem    badeoti     03/20/09 - remove public synonyms for XDB internal packages
Rem    badeoti     12/15/08 - avoid any_path-conditioned selects from rv
Rem    sidicula    01/10/08 - Grants to dba, system
Rem    yifeng      11/12/07 - move creation of XDBResConfig schema to xdbs102
Rem    rburns      08/22/07 - add 11g XDB up/down scripts
Rem    rangrish    07/10/07 - WS roles added/removed 
Rem    mrafiq      05/08/07 - fix for bug 5900481
Rem    vkapoor     05/09/07 - bug 5769835
Rem    vkapoor     04/27/07 - lrg 2941734
Rem    vkapoor     04/16/07 - bug 5640175
Rem    mrafiq      04/10/07 - adding XDS_ACE and XDS_ACL
Rem    rpang       12/01/06 - anonymousServletRole for static/anonymous DADs
Rem    mrafiq      11/08/06 - grant all to xdbadmin on xdb$config
Rem    spetride    11/12/06 - check if xmltr.xsd.1.0 already registered
Rem    vmedi       08/16/06 - reset disable-validation event
Rem    vkapoor     07/25/06 - Bug 5371725
Rem    thbaby      07/10/06 - revoke execute on dbms_sys_sql 
Rem    rmurthy     06/12/06 - add prvtxdz2.plb 
Rem    pnath       05/17/06 - document links upgrade 
Rem    pnath       04/13/06 - add document link trigger to all hierarchy 
Rem                           enable xmltype tables 
Rem    petam       05/25/06 - remove digest allow-mechanism from upgrade 
Rem    bkhaladk    04/25/06 - add the translation schema 
Rem    pbelknap    03/26/06 - report framework servlet upgrade
Rem    petam       04/07/06 - fix XS upgrade to go after ResConfig 
Rem    pknaggs     03/24/06 - add Extensible Security Class Catalog Views.
Rem    abagrawa    03/16/06 - Move token manager upgrade to xdbs102 
Rem    taahmed     02/27/06 - security classes for system, dav, and security 
Rem                           class 
Rem    thbaby      02/21/06 - Add NFS info into root_info
Rem    vkapoor     01/25/05 - NFS upgrade changes
Rem    nitgupta    02/07/06 - Drop Token MGR tables and recreate
Rem    sidicula    01/18/06 - Adding protocol info into rootinfo 
Rem    smalde      12/19/05 - Contentsize upgrade/downgrade 
Rem    taahmed     01/27/06 - downgrade XS schemas 
Rem    taahmed     01/18/06 - Upgrade for extensible security 
Rem    thbaby      01/06/06 - drop procedure xdb.setmodflg 
Rem    mrafiq      10/10/05 - creating xdbresconfig schema for upgrade 
Rem    sidicula    06/29/05 - sidicula_le
Rem    fge         10/27/04 - Created
Rem

-- First upgrade the schemas, if necessary
COLUMN :sch102_name NEW_VALUE comp102_file NOPRINT
VARIABLE sch102_name VARCHAR2(50)

DECLARE
  a number;
BEGIN
  select n into a from xdb.migr9202status;
  if a < 750 then
    :sch102_name  := '@xdbs102.sql';
  else
    :sch102_name := '@nothing.sql';
  end if;
end;
/
select :sch102_name from dual;
@&comp102_file;

Rem 8440074: reload packages
@@xdbptrl1.sql

grant all on xdb.xdb$config to xdbadmin;
grant select, insert, update, delete on XDB.XDB$ACL to public;
commit;

Rem TODO - We should do the XDBCONFIG Upgrade here

Rem Add new servlets
declare
  cfg_data XMLTYPE;
begin
  cfg_data := dbms_xdb.cfg_get();

  -- Report framework servlet
  SELECT appendchildxml(
           cfg_data, 
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
             '/servletconfig/servlet-mappings', 
           xmltype(
            '<servlet-mapping xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">
               <servlet-pattern>/orarep/*</servlet-pattern>
               <servlet-name>ReportFmwkServlet</servlet-name>
             </servlet-mapping>'))
  INTO   cfg_data
  FROM   dual;

  SELECT appendchildxml(
           cfg_data,
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
             '/servletconfig/servlet-list',
           xmltype(
             '<servlet xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">
                <servlet-name>ReportFmwkServlet</servlet-name>
                <servlet-language>C</servlet-language>
                <display-name>REPT</display-name>
                <description>Servlet for accessing reports</description>
                <security-role-ref>
                  <role-name>authenticatedUser</role-name>
                  <role-link>authenticatedUser</role-link>
                </security-role-ref>
              </servlet>'))
  INTO   cfg_data
  FROM   dual;

  -- Set anonymousServletRole security-role-ref for PL/SQL servlets using
  -- static or anonymous authentication, which have database-username set.
  SELECT appendchildxml(
           deletexml(
             cfg_data,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
               '/servletconfig/servlet-list/servlet[plsql/database-username]'||
               '/security-role-ref'),
           '/xdbconfig/sysconfig/protocolconfig/httpconfig/webappconfig' ||
             '/servletconfig/servlet-list/servlet[plsql/database-username]',
           xmltype(
             '<security-role-ref xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd">
                <role-name>anonymousServletRole</role-name>
                <role-link>anonymousServletRole</role-link>
              </security-role-ref>'))
  INTO   cfg_data
  FROM   dual;

  dbms_xdb.cfg_update(cfg_data);
end;
/


Rem Update ROOT_INFO with protocol info
-- A simple select first to check the values
select extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-port'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-protocol'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-port'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-protocol'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-host'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-port'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-protocol'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-host'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/nfsconfig/nfs-port'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/nfsconfig/nfs-protocol')
 from xdb.xdb$config e;

update xdb.xdb$root_info set 
(ftp_port, ftp_protocol, http_port, http_protocol, http_host, http2_port, http2_protocol, http2_host, nfs_port, nfs_protocol) 
= 
(select extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-port'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-protocol'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-port'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-protocol'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-host'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-port'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-protocol'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-host'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/nfsconfig/nfs-port'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/nfsconfig/nfs-protocol')
 from xdb.xdb$config e);

commit;

-- Set inline trigger flag on hierarchically enabled tables for
-- content size.
-- Set table dependant flags on hierarchically enabled tables
declare
        cursor mycur is
        SELECT object_name, object_owner, function
        FROM   dba_policies v
        WHERE  (policy_name LIKE '%xdbrls%' OR policy_name LIKE '%$xd_%');
begin
        for myrec in mycur
        loop
           if myrec.function = 'CHECKPRIVRLS_SELECTPF' then 
                xdb.dbms_xdbz0.set_delta_calc_inline_trigflag (
                myrec.object_name, myrec.object_owner, TRUE, FALSE );
                xdb.dbms_xdbz0.update_table_dependant_flags (
                myrec.object_name, myrec.object_owner, 0);
           elsif myrec.function = 'CHECKPRIVRLS_SELECTPROPF' then
                xdb.dbms_xdbz0.update_table_dependant_flags (
                myrec.object_name, myrec.object_owner, 0);
           end if; 
        end loop;
end;
/
-- Upgrading from 10.2 OR VCR flags with 700.
-- This is done for version controlled resources.
-- Bug 9034494
update xdb.xdb$resource t
set t.xmldata.flags = utl_raw.bit_or('700',t.xmldata.flags)
where t.xmldata.versionid is not NULL;

Rem Initialize document links support
@@catxdbdl.sql

drop package xdb.xdb$bootstrap;
drop package xdb.xdb$bootstrapres;

-- The fix for 4931915, which went into 11g, modified setmodflg (defined in 
-- prvtxdbz.sql) and moved it from the xdb schema to the sys schema. Hence, 
-- drop procedure in xdb schema during upgrade. 
drop procedure xdb.setmodflg;

-- dbms_sys_sql is not needed by xdb
create or replace procedure revoke_priv as
  priv_not_granted EXCEPTION;
  PRAGMA EXCEPTION_INIT(priv_not_granted, -1952);
begin
  execute immediate 'revoke execute on sys.dbms_sys_sql from xdb';
exception
  when priv_not_granted then
    NULL;
end;
/
show errors;

Rem Create dbms_metadata_hack
@@catxdbh

-- add the translation schema for clob
declare
  TRXSD BFILE := dbms_metadata_hack.get_bfile('xmltr.xsd.11.0');
  TRURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/xmltr.xsd'; 
  isreg NUMBER; 
begin
  select count(*) into isreg from xdb.xdb$schema s
    where s.xmldata.schema_url = TRURL;

  if (isreg > 0) then
    return;
  end if;
  xdb.dbms_xmlschema.registerSchema(TRURL, TRXSD, FALSE, FALSE, FALSE, FALSE,
                                    FALSE, 'XDB');
end;
/

drop package dbms_metadata_hack;

-- acl index setup
@@prvtxdz2.plb
-- check the ACL index status
select index_name, status from dba_indexes where table_name='XDB$ACL' and owner='XDB';

/*
 * Updates for XDB DEFAULT CONFIG
 */

-- (Re-)Insert the authentication element into xdbconfig.xml
declare
  auth_count      INTEGER := 0;
  auth_frag xmltype;
  cfg xmltype;
begin
   cfg := dbms_xdb.cfg_get();
   begin
   select 1 into auth_count from dual
    where XMLExists(
       'declare namespace c = "http://xmlns.oracle.com/xdb/xdbconfig.xsd";
        /c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig/c:authentication'
        PASSING cfg);
   exception 
     when no_data_found then null;
   end;
 
   -- enable INSERTXMLBEFORE, APPENDCHILDXML, DELETEXML(4)
   -- Turn on rewrite for updxml/delxml/insertxml over collections(128)
   execute immediate 
     'alter session set events ''19027 trace name context forever, level 132'' ';

   if auth_count = 0 then
     auth_frag := xmltype('<authentication xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"><allow-mechanism>basic</allow-mechanism><digest-auth><nonce-timeout>300</nonce-timeout></digest-auth></authentication>');
   else
     -- extract authentication fragment for later re-insertion
     dbms_output.put_line('authentication fragment existed, deleting');
     auth_frag := cfg.extract('/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication');
     select deletexml (cfg,
        '/c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig/c:authentication',
        'xmlns:c="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
     into cfg from dual;
   end if;

   dbms_output.put_line('inserting authentication fragment');
   select insertchildxml (cfg,
       '/c:xdbconfig/c:sysconfig/c:protocolconfig/c:httpconfig',
       'authentication',
       auth_frag,
       'xmlns:c="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
   into cfg from dual;
   dbms_output.put_line('updating xdbconfig doc');
   dbms_xdb.cfg_update(cfg); 
  end;
/
commit;

create or replace view XDS_ACL
  (ACLID, SHARED, DESCRIPTION, SECURITY_CLASS_NS, 
   SECURITY_CLASS_NAME, PARENT_ACL_PATH, INHERITANCE_TYPE)
as 
select a.object_id, 
       substr(extractvalue(a.object_value, '/acl/@shared', 
                           'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
              1, 5), 
       extractvalue(a.object_value, '/acl/@description', 
                    'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
       xmlquery('declare namespace a="http://xmlns.oracle.com/xdb/acl.xsd"; fn:namespace-uri-from-QName(fn:data(/a:acl/a:security-class))' PASSING OBJECT_VALUE returning content),
       xmlquery('declare namespace a="http://xmlns.oracle.com/xdb/acl.xsd"; fn:local-name-from-QName(fn:data(/a:acl/a:security-class))' PASSING OBJECT_VALUE returning content),
       CASE existsNode(a.object_value, '/acl/extends-from', 
                       'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN extractvalue(a.object_value, '/acl/extends-from/@href', 
                         'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
       ELSE (CASE existsNode(a.object_value, '/acl/constrained-with', 
                             'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') 
             WHEN 1 
             THEN extractvalue(a.object_value, '/acl/constrained-with/@href', 
                               'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
             ELSE NULL END) END, 
       CASE existsNode(a.object_value, '/acl/extends-from', 
                       'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN 'extends-from'
       ELSE (CASE existsNode(a.object_value, '/acl/constrained-with', 
                             'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') 
             WHEN 1 
             THEN 'constrained-with'
             ELSE NULL END) END 
FROM XDB.XDB$ACL a;

create or replace public synonym XDS_ACL for XDS_ACL;

grant select on XDS_ACL to PUBLIC;

comment on table XDS_ACL is
'All ACLs that are visible to the current user in the database'
/

comment on column XDS_ACL.ACLID is
'The ACL ID of an ACL'
/
comment on column XDS_ACL.SHARED is
'Whether this ACL is shared or not'
/

comment on column XDS_ACL.DESCRIPTION is
'The ACL description'
/

comment on column XDS_ACL.SECURITY_CLASS_NS is
'The namespace of the Security Class'
/

comment on column XDS_ACL.SECURITY_CLASS_NAME is
'The name of the Security Class'
/

comment on column XDS_ACL.PARENT_ACL_PATH is
'The path of its parent ACL'
/

comment on column XDS_ACL.INHERITANCE_TYPE is
'The inhertance type, i.e. constrained-with or extends-from'
/

create or replace view XDS_ACE
  (ACLID, START_DATE, END_DATE, IS_GRANT, 
   INVERT, PRINCIPAL, PRIVILEGE)
as 
select a.object_id, 
       extractvalue(value(b), '/ace/@start_date', 
                    'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
       extractvalue(value(b), '/ace/@end_date', 
                    'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
       substr(extractvalue(value(b), '/ace/grant', 
                           'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"'), 
              1, 5), 
       CASE existsNode(value(b), '/ace/invert', 
                      'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN 'true'
       ELSE 'false' END, 
       CASE existsNode(value(b), '/ace/invert', 
                       'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') WHEN 1 
       THEN extractvalue(value(b), '/ace/invert/principal', 
                         'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
       ELSE extractvalue(value(b), '/ace/principal', 
                         'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"') END, 
       extract(value(b), '/ace/privilege', 
               'xmlns="http://xmlns.oracle.com/xdb/acl.xsd"')
from xdb.xdb$acl a, 
     table(XMLSequence(extract(a.object_value, '/acl/ace'))) b;

create or replace public synonym XDS_ACE for XDS_ACE;

grant select on XDS_ACE to PUBLIC; 

comment on table XDS_ACE is
'All ACEs in ACLs that are visible to the current user in the database'
/

comment on column XDS_ACE.ACLID is
'The ACL ID of an ACL'
/

comment on column XDS_ACE.START_DATE is
'The start_date attribute of the ACE'
/

comment on column XDS_ACE.END_DATE is
'The end_date attribute of the ACE'
/

comment on column XDS_ACE.IS_GRANT is
'true if this is a grant ACE, false otherwise'
/

comment on column XDS_ACE.INVERT is
'true if this ACE contains invert principal, false otherwise'
/

comment on column XDS_ACE.PRINCIPAL is
'The principal in this ACE'
/

comment on column XDS_ACE.PRIVILEGE is
'The privileges in this ACE'
/

DECLARE
  c number;
BEGIN  
  select count(*) into c
  from ALL_SCHEDULER_JOB_CLASSES
  where JOB_CLASS_NAME = 'XMLDB_NFS_JOBCLASS';

  if c = 0 then
    dbms_scheduler.create_job_class(
      job_class_name  => 'SYS.XMLDB_NFS_JOBCLASS',
      logging_level   => DBMS_SCHEDULER.LOGGING_FAILED_RUNS);
  end if;

  select count(*) into c
  from ALL_SCHEDULER_JOBS
  where JOB_NAME = 'XMLDB_NFS_CLEANUP_JOB';

  if c = 0 then
    dbms_scheduler.create_job(
        job_name => 'SYS.XMLDB_NFS_CLEANUP_JOB' ,
        job_type=>'STORED_PROCEDURE',  
        job_action=>'xdb.dbms_xdbutil_int.cleanup_expired_nfsclients',
        job_class=>'SYS.XMLDB_NFS_JOBCLASS',
        repeat_interval=>'Freq=minutely;interval=5');
  end if;
  execute immediate 'delete from noexp$ where name = :1' using 'XMLDB_NFS_JOBCLASS';
  execute immediate 'insert into noexp$ (owner, name, obj_type) values(:1, :2, :3)' using 'SYS', 'XMLDB_NFS_JOBCLASS', '68';
end;   
/

-- Remove old roles
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

-- Add new roles
declare
  role_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(role_exists, -01921);
begin
  execute immediate 'create role XDB_WEBSERVICES';
  execute immediate 'create role XDB_WEBSERVICES_WITH_PUBLIC';
  execute immediate 'create role XDB_WEBSERVICES_OVER_HTTP';
exception when role_exists then
  NULL;
end;
/

-- Explicit grants to DBA,System; "any" privileges are no more applicable for 
-- XDB tables. Listing these specifically since there are certain tables
-- for which we dont grant full access by default even to DBA & System.
-- (eg, purely-dictionary tables like XDB$SCHEMA, XDB$TTSET etc.)
grant all on XDB.XDB$RESOURCE to dba;
grant all on XDB.XDB$RESOURCE to system with grant option;
grant all on XDB.XDB$H_INDEX to dba;
grant all on XDB.XDB$H_INDEX to system with grant option;
grant all on XDB.XDB$H_LINK to dba;
grant all on XDB.XDB$H_LINK to system with grant option;
grant all on XDB.XDB$D_LINK to dba;
grant all on XDB.XDB$D_LINK to system with grant option;
grant all on XDB.XDB$NLOCKS to dba;
grant all on XDB.XDB$NLOCKS to system with grant option;
grant all on XDB.XDB$WORKSPACE to dba;
grant all on XDB.XDB$WORKSPACE to system with grant option;
grant all on XDB.XDB$CHECKOUTS to dba;
grant all on XDB.XDB$CHECKOUTS to system with grant option;
grant all on XDB.XDB$ACL to dba;
grant all on XDB.XDB$ACL to system with grant option;
grant all on XDB.XDB$CONFIG to dba;
grant all on XDB.XDB$CONFIG to system with grant option;
grant all on XDB.XDB$RESCONFIG to dba;
grant all on XDB.XDB$RESCONFIG to system with grant option;

-- ensure that public has limited privileges on acl table
revoke all on XDB.XDB$ACL from public;
grant select, insert, update, delete on XDB.XDB$ACL to public;
commit;

declare
  suf  varchar2(26);
  stmt varchar2(2000);
begin
  select toksuf into suf from xdb.xdb$ttset where flags = 0;
  stmt := 'grant all on XDB.X$PT' || suf || ' to DBA';
  execute immediate stmt;
  stmt := 'grant all on XDB.X$PT' || suf || ' to SYSTEM WITH GRANT OPTION';
  execute immediate stmt;
end;
/

commit;

-- Invoke upgrade to subsequent releases
@@xdbu111.sql

-- check the ACL index status
select index_name, status from dba_indexes where table_name='XDB$ACL' and owner='XDB';
