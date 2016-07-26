Rem
Rem $Header: rdbms/admin/xdbdbmig.sql /st_rdbms_11.2.0/2 2011/01/18 07:53:36 spetride Exp $
Rem
Rem xdbdbmig.sql
Rem
Rem Copyright (c) 2002, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbdbmig.sql - Xml DB DataBase MIGrate
Rem
Rem    DESCRIPTION
Rem      Upgrade script for XDB from all supported prior releases.
Rem
Rem    NOTES
Rem      None
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    01/11/11 - Backport badeoti_bug-10096889 from main
Rem    sidicula    01/06/11 - Backport sidicula_bug-10368698 from main
Rem    vmedi       05/06/10 - revert 9144511 changes
Rem    badeoti     04/30/10 - bug 9672801: remove echo off
Rem    spetride    12/09/09 - print acl index status
Rem    spetride    12/02/09 - 9144511: disable sch validation for XS
Rem    rburns      09/30/07 - add 11.1 upgrade
Rem    mrafiq      06/29/07 - fix for lrg 3019679
Rem    pthornto    10/04/06 - add call to xsdbmig.sql for eXtensible Security
Rem                           pkgs
Rem    spetride    10/13/06 - not mark XDB invalid, recovery checks
Rem                           run if invalid config/acl rows anyway
Rem    spetride    08/04/06 - enable validate during upgrade
Rem    vmedi       06/19/06 - tempfix: disable validate during upgrade 
Rem    mrafiq      05/23/06 - fixing status and version numbers 
Rem    petam       04/10/06 - upgrade Fusion Security after XDB fully upgraded
Rem    abagrawa    03/14/06 - 
Rem    vkapoor     01/25/05 - Adding 102 upgrade script 
Rem    mrafiq      02/23/06 - fix for lrg 2070764: default value for 
Rem                           script_name 
Rem    mrafiq      10/04/05 - adding 102 upgrade script 
Rem    fge         10/27/04 - add 10gr2 upgrade script 
Rem    vkapoor     02/15/05 - LRG 1830972. xdbreload needs to be called if upgrade
Rem                           is rerun.
Rem    pnath       01/19/05 - call xdbinst.sql instead of xdbinstlltab.sql 
Rem    vkapoor     12/16/04 - A new script for upgrade reload 
Rem    pnath       11/22/04 - delete all objects introduced in xdb 
Rem                           installation 
Rem    pnath       10/25/04 - Make SYS the owner of DBMS_REGXDB package 
Rem    spannala    05/04/04 - drop xdbhi_idx and recreate later
Rem    thbaby      01/30/04 - adding 10GR1 upgrade 
Rem    spannala    10/20/03 - migrate status at the beginning of upgrade 
Rem                           should be set correctly as per release
Rem    spannala    06/18/03 - making xdbreload generic enough for all upgrades
Rem    spannala    06/09/03 - in 9201 upgd, call xdbptrl2 at the end
Rem    njalali     04/16/03 - removing ?/ notation
Rem    njalali     04/02/03 - not calling xdbrelod twice on 9.2.0.1 upgrade
Rem    njalali     03/27/03 - dropping xdb$patchupschema
Rem    njalali     02/10/03 - enabling upgrade from 9.2.0.3 to 10i
Rem    njalali     01/16/03 - bug 2744444
Rem    njalali     11/21/02 - njalali_migscripts_10i
Rem    njalali     11/21/02 - Incorporated review comments
Rem    njalali     11/14/02 - Created
Rem

Rem ===============================================================
Rem BEGIN XDB Upgrade
Rem ===============================================================

Rem Clean up any shared memory taken by JavaVM or anyone else
alter system flush shared_pool;
alter system flush shared_pool;
alter system flush shared_pool;

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem Note that a trigger needs to be added in future releases
Rem so that all objects created during upgrade is added
Rem to the table xdb_installation_tab, and the dropping
Rem of these objects are to be handled in catnoqm.sql


Rem Create the table xdb_installation_tab if it does not exist
Rem This table ensures that all objects are deleted 
Rem during the time of XDB un-installation, which were
Rem created as a part of XDB installation.
@@xdbinst

-- Create the table that keeps track of how far along we are in the migration
begin
  execute immediate 'select count(*) from xdb.migr9202status';
exception
  when others then
    execute immediate 'create table xdb.migr9202status (n integer)';
    execute immediate 'insert into xdb.migr9202status values (400)';
    commit;
end;
/

Rem XDB$PATCHUPSCHEMA will have errors
drop procedure xdb$patchupschema;

Rem display start status
select * from  xdb.migr9202status;

Rem Setup component script filename variable
COLUMN :relo_name NEW_VALUE relo_file NOPRINT
VARIABLE relo_name VARCHAR2(50)
COLUMN :script_name NEW_VALUE comp_file NOPRINT
VARIABLE script_name VARCHAR2(50)

-- DROP package xdb.dbms_regxdb
drop package xdb.dbms_regxdb;

-- Create the registry package and the validation procedure
@@dbmsxreg

-- Load package sys.dbms_regxdb
@@prvtxreg.plb

set echo on serveroutput on

Rem We must run xdbrelod.sql at the end of the upgrade
Rem in order to reload the XML DB packages.
Rem
DECLARE
  start_status integer := 100000;
  version      varchar2(60);
BEGIN
  :relo_name := '@xdbrelod.sql';
  :script_name := '@nothing.sql';
  select dbms_registry.version('XDB') into version from dual;
  IF substr(version, 1, 5) = '9.2.0'   THEN
    -- The upgrade script for all other 92 versions
    :script_name := '@xdbu9202.sql';
    :relo_name := '@xdbrlu.sql';
    start_status := 400;
  ELSIF substr(version, 1, 6) = '10.1.0'   THEN
    :script_name := '@xdbu101.sql';
    :relo_name := '@xdbrlu.sql';
    start_status := 500;
  ELSIF substr(version, 1, 6) = '10.2.0'   THEN
    :script_name := '@xdbu102.sql';
    :relo_name := '@xdbrlu.sql';
    start_status := 700;
  ELSIF substr(version, 1, 6) = '11.1.0'   THEN
    :script_name := '@xdbu111.sql';
    :relo_name := '@xdbrlu.sql';
  END IF;

  dbms_output.put_line('version = ' || version || ' start_status = ' || to_char(start_status));
  -- Set the start status correctly if this script is being run for the
  -- first time.
  IF dbms_registry.status('XDB') = 'VALID' THEN
    -- This change will get committed along with the dbms_registry.upgrading
    -- commit below.
    IF start_status != 100000 THEN
      update xdb.migr9202status set n = start_status;
    END IF;
    dbms_output.put_line('xdb was valid');
  ELSE
    :relo_name := '@xdbrelod.sql'; 
    dbms_output.put_line('xdb was NOT valid');
  END IF;

END;
/

Rem ===============================================================
Rem Upgrade XDB 
Rem ===============================================================

-- This sets the stauts to upgrading and commits the above change 
-- to migr9202status, if any
EXECUTE dbms_registry.upgrading('XDB', 'Oracle XML Database', 'DBMS_REGXDB.VALIDATEXDB');

-- Drop the xdbhi_idx index This will get recreated later in the upgrade
declare
 ct number;
begin
  select count(*) into ct from dba_indexes where owner = 'XDB' and 
    index_name = 'XDBHI_IDX';
    if ct > 0 then
      dbms_output.put_line('dissociating statistics');
      execute immediate 'disassociate statistics from ' ||
                        'indextypes xdb.xdbhi_idxtyp force';
      execute immediate 'disassociate statistics from ' ||
                        'packages xdb.xdb_funcimpl force';
      execute immediate 'drop index xdb.xdbhi_idx';
    end if;
end;
/

SELECT :script_name FROM DUAL;
@&comp_file
SELECT :relo_name FROM DUAL;
@&relo_file

execute dbms_session.reset_package;

-- Gather stats on xdb$resource so that further component upgrades 
-- that are based on resource_view will run fast
begin
 DBMS_STATS.GATHER_TABLE_STATS (ownname => 'XDB', tabname => 'XDB$RESOURCE', estimate_percent => NULL);
end;
/

EXECUTE dbms_registry.upgraded('XDB');

-- drops error tables if  error tables for XDB$ACL or XDB$CONFIG empty
declare
  aclnoinv    number := 0;
  resnoinv    number := 0;
  stmtchk     varchar2(2000);
  stmtdrop    varchar2(2000);
begin
  begin
    stmtchk := 'select count(*) from XDB.INVALID_XDB$CONFIG';
    dbms_output.put_line(stmtchk);
    execute immediate stmtchk into resnoinv;
    if (resnoinv = 0) then
      stmtdrop := 'drop table XDB.INVALID_XDB$CONFIG'; 
      dbms_output.put_line(stmtdrop);     
      execute immediate stmtdrop;
      commit;
    end if;
  exception
    when others then
      -- table already dropped
      NULL;
  end;
  begin
    stmtchk := 'select count(*) from XDB.INVALID_XDB$ACL';
    dbms_output.put_line(stmtchk);
    execute immediate stmtchk into aclnoinv;
    if (aclnoinv = 0) then
      stmtdrop := 'drop table XDB.INVALID_XDB$ACL';   
      dbms_output.put_line(stmtdrop);
      execute immediate stmtdrop;
      commit;
    end if;
  exception
    when others then
      -- table already dropped
      NULL;
  end;
end;
/

Rem EXECUTE sys.dbms_regxdb.validatexdb();
Rem Set XDB to a valid state.
Rem We cannot use sys.dbms_regxdb.validatexdb() because
Rem resource_view is unusable until the DB is restarted.
execute sys.dbms_registry.valid('XDB');

Rem Upgrade Fusion Security after XDB is fully upgraded
@@xsdbmig.sql

-- check the ACL index status
select index_name, status from dba_indexes where table_name='XDB$ACL' and owner='XDB';

set serveroutput on
-- check status of xdb schema cache event
declare
  lev     BINARY_INTEGER;
  newlvls varchar2(20);
BEGIN
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
  -- set level 0x8000 
  newlvls := '0x' ||
      ltrim(to_char(rawtohex(utl_raw.bit_or(
                                utl_raw.cast_from_binary_integer(lev),
                                utl_raw.cast_from_binary_integer(32768)))), '0');
  -- make sure event is set
  execute immediate
    'alter session set events ''31150 trace name context forever, level ' ||
    newlvls || ''' ';
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
end;
/

-- additionally, trace any further lxs-0002x errors 
alter session set events '31061 trace name errorstack level 3, forever';

set serveroutput off
