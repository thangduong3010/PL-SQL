Rem
Rem sbdelins.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      sbdelins.sql - StandBy statistics collection DELete INStance
Rem
Rem    DESCRIPTION
Rem	 SQL*PLUS command file which removes a standby database instance
Rem      for performance data collection
Rem
Rem    NOTES
Rem      Must be run as standby statspack user, stdbyperf.
Rem      Please purge all associated snapshots before deleting instance. 
Rem      Once a instance is deleted, we cannot purge its snapshots.   
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem    shsong      01/28/10 - add error reporting
Rem    shsong      08/18/09 - add db_unique_name
Rem    shsong      03/04/07 - Fix bug
Rem    wlohwass    12/06/06 - Created
Rem

--
--  List configured standby instances
@@sblisins

whenever sqlerror exit;

prompt
prompt
prompt Enter the DATABASE UNIQUE NAME of the standby database to remove
prompt -------------------------------------------------------------------

prompt You entered: &&dbuname

prompt
prompt
prompt Enter the INSTANCE NAME of the standby database instance to remove
prompt -------------------------------------------------------------------

prompt You entered: &&ins_name


--
--  Set up the binds for db_unique_name and instance_name

variable db_unique_name varchar2(30);
variable inst_name      varchar2(16);
begin
  :db_unique_name := trim('&dbuname');
  :inst_name      := trim('&ins_name');
end;
/



--
--  Error reporting

whenever sqlerror exit;
declare

  cursor cidnum is
     select 'X'
       from stats$standby_config 
      where inst_name        = :inst_name
        and db_unique_name   = :db_unique_name;

  vx     char(1);

begin

  -- Check Database Unique Name/Instance Name is a valid pair
  open cidnum;
  fetch cidnum into vx;
  if cidnum%notfound then
    raise_application_error(-20200,
      'Database/Instance '||:db_unique_name||'/'||:inst_name||' does not exist in STATS$STANDBY_CONFIG');
  end if;
  close cidnum;

end;
/

column db_link      heading "DB Link"  new_value db_link      format a32;
column package_name heading "Package"  new_value package_name format a46;

select db_link db_link
     , package_name package_name
  from stats$standby_config
 where inst_name = :inst_name
   and db_unique_name = :db_unique_name;


prompt
prompt INSTANCE &&dbuname/&&ins_name WILL BE REMOVED FROM THE CONFIGURATION
prompt
prompt DROPPING DATABASE LINK: &&db_link
prompt DROPPING PACKAGE      : &&package_name
prompt
prompt Do you want to continue (y/n) ?
prompt You entered: &&key

begin
  if upper('&&key') <> 'Y' then
    raise_application_error(-20101, 'Install failed - Aborted by user');
  end if;
end;
/

whenever sqlerror continue;

prompt
prompt ... Dropping database link

drop database link &&db_link; 


prompt
prompt
prompt ... Dropping package
prompt

drop package &&package_name;


--
-- remove configuration
delete from stats$standby_config
 where inst_name = :inst_name
   and db_unique_name = :db_unique_name;

commit;

undefine dbuname key ins_name db_unique_name inst_name db_link package_name

