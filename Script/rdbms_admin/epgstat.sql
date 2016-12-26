Rem
Rem $Header: epgstat.sql 27-nov-2006.10:22:51 rpang Exp $
Rem
Rem epgstat.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      epgstat.sql - Embedded PL/SQL Gateway Status
Rem
Rem    DESCRIPTION
Rem      This script shows various status of the embedded PL/SQL gateway and
Rem      the XDB HTTP listener.
Rem
Rem    NOTES
Rem      This script should be run by a user with XDBADMIN and DBA roles.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       11/22/06 - Show authentication schemes
Rem    rpang       10/31/06 - Created
Rem

set echo      off
set feedback  on
set numwidth  10
set linesize  80
set trimspool on
set tab       off
set pagesize  100

PROMPT +--------------------------------------+
PROMPT | XDB protocol ports:                  |
PROMPT |  XDB is listening for the protocol   |
PROMPT |  when the protocol port is non-zero. |
PROMPT +--------------------------------------+

COLUMN http_port FORMAT 99999 HEADING 'HTTP Port'
COLUMN ftp_port  FORMAT 99999 HEADING 'FTP Port'

select to_number(extractValue(value(c),'/protocolconfig/httpconfig/http-port',
         'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')) http_port,
       to_number(extractValue(value(c),'/protocolconfig/ftpconfig/ftp-port',
         'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')) ftp_port
  from xdb.xdb$config cfg,
       table(XMLSequence(extract(cfg.object_value,
             '/xdbconfig/sysconfig/protocolconfig',
             'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'))) c;

PROMPT +---------------------------+
PROMPT | DAD virtual-path mappings |
PROMPT +---------------------------+

COLUMN vpath    FORMAT a32 HEADING 'Virtual Path'
COLUMN dad_name FORMAT a32 HEADING 'DAD Name'

select extractValue(value(map), '/servlet-mapping/servlet-pattern',
         'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') vpath,
       extractValue(value(map), '/servlet-mapping/servlet-name',
         'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') dad_name
  from xdb.xdb$config cfg,
       table(XMLSequence(extract(cfg.object_value,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig'||
               '/webappconfig/servletconfig/servlet-mappings'||
               '/servlet-mapping'))) map,
       table(XMLSequence(extract(cfg.object_value,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig'||
               '/webappconfig/servletconfig/servlet-list'||
               '/servlet[servlet-language="PL/SQL"]',
             'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'))) dad
 where extractValue(value(map), '/servlet-mapping/servlet-name',
                    'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') =
       extractValue(value(dad), '/servlet/servlet-name',
                    'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
 order by vpath;

PROMPT +----------------+
PROMPT | DAD attributes |
PROMPT +----------------+

COLUMN dad_name    FORMAT a12 HEADING 'DAD Name'
COLUMN param_name  FORMAT a24 HEADING 'DAD Param'
COLUMN param_value FORMAT a40 HEADING 'DAD Value'
BREAK ON dad_name

select extractValue(value(dad), '/servlet/servlet-name',
         'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') dad_name,
       value(param).getRootElement() param_name,
       extractValue(value(param), '/*') param_value
  from xdb.xdb$config cfg,
       table(XMLSequence(extract(cfg.object_value,
             '/xdbconfig/sysconfig/protocolconfig/httpconfig'||
               '/webappconfig/servletconfig/servlet-list'||
               '/servlet[servlet-language="PL/SQL"]',
             'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'))) dad,
       table(XMLSequence(extract(value(dad),
             '/servlet/plsql/*',
             'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'))) param
 order by dad_name;

PROMPT +---------------------------------------------------+
PROMPT | DAD authorization:                                |
PROMPT |  To use static authentication of a user in a DAD, |
PROMPT |  the DAD must be authorized for the user.         |
PROMPT +---------------------------------------------------+

COLUMN dad_name FORMAT a32 HEADING 'DAD Name'
COLUMN username FORMAT a32 HEADING 'User Name'

select dad_name, username from dba_epg_dad_authorization order by dad_name;

PROMPT +----------------------------+
PROMPT | DAD authentication schemes |
PROMPT +----------------------------+

COLUMN dad_name FORMAT a20 HEADING 'DAD Name'
COLUMN username FORMAT a32 HEADING 'User Name'
COLUMN auth     FORMAT a18 HEADING 'Auth Scheme'

select cfg.dad_name, cfg.username,
       case when cfg.username = 'ANONYMOUS'      then 'Anonymous'
            when auth.username is null then
                 (case when cfg.username is null then 'Dynamic'
                       else                           'Dynamic Restricted' end)
            else                                      'Static' end auth
  from (select extractValue(value(dad), '/servlet/servlet-name',
                 'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') dad_name,
               extractValue(value(dad), '/servlet/plsql/database-username',
                 'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') username
          from xdb.xdb$config cfg,
               table(XMLSequence(extract(cfg.object_value,
               '/xdbconfig/sysconfig/protocolconfig/httpconfig'||
               '/webappconfig/servletconfig/servlet-list'||
               '/servlet[servlet-language="PL/SQL"]',
               'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'))) dad) cfg,
       dba_epg_dad_authorization auth
 where cfg.dad_name = auth.dad_name(+) and
       cfg.username = auth.username(+)
 order by cfg.dad_name;

PROMPT +--------------------------------------------------------+
PROMPT | ANONYMOUS user status:                                 |
PROMPT |  To use static or anonymous authentication in any DAD, |
PROMPT |  the ANONYMOUS account must be unlocked.               |
PROMPT +--------------------------------------------------------+

COLUMN username       FORMAT a15 HEADING 'Database User'
COLUMN account_status FORMAT a20 HEADING 'Status'

select username, account_status from dba_users
 where username = 'ANONYMOUS';

PROMPT +-------------------------------------------------------------------+
PROMPT | ANONYMOUS access to XDB repository:                               |
PROMPT |  To allow public access to XDB repository without authentication, |
PROMPT |  ANONYMOUS access to the repository must be allowed.              |
PROMPT +-------------------------------------------------------------------+

COLUMN anonymous_access FORMAT a34 HEADING 'Allow repository anonymous access?'

select nvl(extractValue(cfg.object_value,
         '/xdbconfig/sysconfig/protocolconfig/httpconfig/' ||
         'allow-repository-anonymous-access',
         'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"'), 'false')
         anonymous_access
  from xdb.xdb$config cfg;
