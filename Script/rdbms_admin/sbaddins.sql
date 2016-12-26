Rem
Rem sbaddins.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      sbaddins.sql - Standby Database Statistics Collection Add Instance
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file which adds a standby database instance
Rem      for performance data collection
Rem
Rem    NOTES
Rem      Must be run from standby perfstat owner, STDBYPERF
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      01/28/10 - remove v$lock_type
Rem    shsong      08/18/09 - add db_unique_name to stats$standby_config
Rem    shsong      03/04/07 - fix bug
Rem    wlohwass    12/04/06 - Created
Rem

set echo off;
whenever sqlerror exit;

--
--  List configured standby instances
@@sblisins

prompt
prompt
prompt THE INSTANCE YOU ARE GOING TO ADD MUST BE ACCESSIBLE AND OPEN READ ONLY
prompt
prompt Do you want to continue (y/n) ?
prompt You entered: &&key

begin
  if upper('&&key') <> 'Y' then
    raise_application_error(-20101, 'Install failed - Aborted by user');
  end if;
end;
/

prompt
prompt
prompt Enter the TNS ALIAS that connects to the standby database instance
prompt ------------------------------------------------------------------

prompt Make sure the alias connects to only one instance (without load balancing).
prompt You entered: &&tns_alias

prompt
prompt
prompt Enter the PERFSTAT user's password of the standby database
prompt ----------------------------------------------------------

prompt Performance data will be fetched from the standby database via 
prompt database link. We will connect to user PERFSTAT.
prompt You entered: &&perfstat_password

prompt
prompt ... Creating database link

create database link stdby_link_&&tns_alias 
connect to perfstat identified by &&perfstat_password
using '&&tns_alias';


column db_unique_name heading "Database"  new_value db_unique_name format a30;

prompt
prompt ... Selecting database unique name

select i.db_unique_name   db_unique_name
from v$database@stdby_link_&&tns_alias i;


column inst_name heading "Instance"  new_value inst_name format a12;

prompt
prompt ... Selecting instance name

select i.instance_name   inst_name
from v$instance@stdby_link_&&tns_alias i;

insert into stats$standby_config
values ('&&db_unique_name'
      , '&&inst_name'
      , 'STDBY_LINK_'||'&&tns_alias'
      , 'STATSPACK_'||'&&db_unique_name'||'_'||'&&inst_name');

commit;

-- get the package name 
column pkg_name new_value pkg_name noprint;
select package_name   pkg_name
  from stats$standby_config
 where db_unique_name = '&db_unique_name'
   and inst_name = '&inst_name';

prompt
prompt
prompt ... Creating package
prompt

--
-- Create statspack package
@@sbcpkg

undefine key tns_alias inst_name perfstat_password pkg_name db_unique_name


