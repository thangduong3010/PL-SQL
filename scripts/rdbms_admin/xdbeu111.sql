Rem
Rem $Header: rdbms/admin/xdbeu111.sql /st_rdbms_11.2.0/1 2011/07/31 10:32:40 juding Exp $
Rem
Rem xdbeu111.sql
Rem
Rem Copyright (c) 2007, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbeu111.sql - XDB User data downgrade
Rem
Rem    DESCRIPTION
Rem      This script downgrades XDB User Data to 11.1.0
Rem
Rem    NOTES
Rem      It is invoked from the top-level XDB downgrade script (xdbe111.sql)
Rem      and from the 10.2 data downgrade script (xdbeu102.sql)
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bhammers    11/19/09 - 8760324, clear 'Unstructured Present' flag
Rem                           when downgrading XIDX from 11.2.0.2 to 11.1.0.7
Rem    spetride    07/29/09 - more custom authentication and trust data 
Rem                           downgrade
Rem    spetride    02/16/09 - remove all Expire mappings in xdbconfig
Rem    atabar      02/06/09 - xdbconfig default-type-mappings downgrade
Rem    spetride    08/07/08 - remove allow-mechanism:custom and 
Rem                           allow-authentication-trust
Rem                         - downgrade for app users and roles
Rem    rburns      11/06/07 - 11.1 data downgrade
Rem    rburns      11/06/07 - Created
Rem

set echo on serveroutput on

Rem ================================================================
Rem BEGIN XDB Data downgrade to 11.2.0
Rem ================================================================

-- uncomment for next release
--@@xdbeu121.sql

@@xdbeu112.sql

Rem ================================================================
Rem END XDB Data downgrade to 11.2.0
Rem ================================================================

Rem ================================================================
Rem BEGIN XDB Data downgrade to 11.1.0
Rem ================================================================

-- downgrade for Application user and roles support
declare
  stmt    varchar2(4000);
  cnt     number := 0;
begin
  stmt := 'select count(*) from dba_tables where (owner = ''' || 'XDB' ||
          ''') and (table_name = ''' || 'APP_USERS_AND_ROLES' || ''') '; 
  execute immediate stmt into cnt;
  if (cnt > 0) then
    execute immediate 'drop table XDB.APP_USERS_AND_ROLES';
  end if;
  stmt := 'select count(*) from dba_tables where (owner = ''' || 'XDB' ||
          ''') and (table_name = ''' || 'APP_ROLE_MEMBERSHIP' || ''') '; 
  execute immediate stmt into cnt;
  if (cnt > 0) then
    execute immediate 'drop table XDB.APP_ROLE_MEMBERSHIP';
  end if;
end;
/

-- XDB CONFIG Data downgrade
create or replace procedure xdbConfigDataDowngrade(path varchar2) as
  new_cfg         XMLTYPE;      
  cexists         NUMBER := 0;
begin
  select existsNode(dbms_xdb.cfg_get(), path, 
                    'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"') 
    into cexists from dual;  
  if (cexists > 0) then
    select deletexml(dbms_xdb.cfg_get(), path,
                     'xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd"')
    into new_cfg from dual;

    dbms_xdb.cfg_update(new_cfg);  
    commit;   
  end if;
end xdbConfigDataDowngrade;
/

show errors;

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/protocolconfig/httpconfig/authentication/allow-mechanism[text()="custom"]');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/allow-authentication-trust');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/default-type-mappings');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/protocolconfig/httpconfig/expire');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/protocolconfig/httpconfig/custom-authentication');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/custom-authentication-trust');

exec xdbConfigDataDowngrade('/xdbconfig/sysconfig/localApplicationGroupStore');

drop procedure xdbConfigDataDowngrade;


begin
-- clear 'UNSTRUCTURED PRESENT' flag for all XML indexes 
execute immediate 'UPDATE xdb.xdb$dxptab 
                   SET flags = flags - 268435456 
                   WHERE bitand(flags, 268435456) = 268435456';
exception
  when others then dbms_output.put_line('XDBNB: flag update failed');
end;
/
commit;

Rem ================================================================
Rem END XDB Data downgrade to 11.1.0
Rem ================================================================


