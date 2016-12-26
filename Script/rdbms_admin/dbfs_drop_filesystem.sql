Rem
Rem $Header: rdbms/admin/dbfs_drop_filesystem.sql /st_rdbms_11.2.0/1 2012/10/29 10:22:03 weizhang Exp $
Rem
Rem dbfs_drop_filesystem.sql
Rem
Rem Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbfs_drop_filesystem.sql - DBFS drop filesystem
Rem
Rem    DESCRIPTION
Rem      DBFS drop filesystem script
Rem      Usage: sqlplus <dbfs_user> @dbfs_drop_filesystem.sql <fs_name>
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      10/21/12 - Backport weizhang_bug-14666696 from main
Rem    weizhang    03/11/10 - bug 9220947: tidy up
Rem    weizhang    11/19/09 - Support default fsDrop FORCE
Rem    weizhang    06/12/09 - Package name change
Rem    weizhang    04/06/09 - Created
Rem

SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF
SET SERVEROUTPUT ON

define fs_name = &1

--------------------------------------------------
-- Drop DBFS file system helper procedure
--------------------------------------------------
create or replace function fsEnqName (v in varchar2)
  return varchar2
is
  ret     varchar2(1024);
begin
  ret := dbms_assert.enquote_literal(replace(v, '''', ''''''));
  return ret;
end;


create or replace procedure fsDrop (
  volName       in  varchar2,
  force         in  boolean
  )
authid current_user
IS
  fsname  varchar2(100);
  tabname varchar2(100);
  mntdir  varchar2(100);
  stmt    varchar2(32000);
BEGIN
  fsname  := upper('FS_' || to_char(volName));
  tabname := upper('T_'  || to_char(volName));
  mntdir  := volName;

  -- unmount the store
  stmt := 'begin dbms_dbfs_content.unmountStore(' ||
          'store_name=>'    || fsEnqName(fsname) ||
          ', store_mount=>' || fsEnqName(mntdir) || 
          '); end;';
  dbms_output.put_line('--------');
  dbms_output.put_line('UNMOUNT STORE: ');
  dbms_output.put_line(stmt);
  begin
    execute immediate stmt;
  exception
    when others then
      -- if FORCE is set, then ignore ORA-64008 (invalid_mount)
      if (force = true) and (sqlcode = -64008) then
        dbms_output.put_line('ignore ' || sqlerrm);
        rollback;
      else
        raise;
      end if;
  end;

  -- unregister the store
  stmt := 'begin dbms_dbfs_content.unregisterStore(' ||
          'store_name=> ' || fsEnqName(fsname) ||
          '); end;';
  dbms_output.put_line('--------');
  dbms_output.put_line('UNREGISTER STORE: ');
  dbms_output.put_line(stmt);
  begin
    execute immediate stmt;
  exception
    when others then
      -- if FORCE is set, then ignore ORA-64007 (invalid_store)
      if (force = true) and (sqlcode = -64007) then
        dbms_output.put_line('Ignore ' || sqlerrm);
        rollback;
      else
        raise;
      end if;
  end;

  -- drop file system
  stmt := 'begin dbms_dbfs_sfs.dropFilesystem(' ||
          'store_name => ' || fsEnqName(fsname) ||
          '); end;' ;
  dbms_output.put_line('--------');
  dbms_output.put_line('DROP STORE: ');
  dbms_output.put_line(stmt);
  execute immediate stmt;

  commit;
END;
/
show errors;

--------------------------------------------------
-- Main entry
--------------------------------------------------

begin
  fsDrop('&fs_name', true);
exception
  when others then
    rollback;
    dbms_output.put_line('ERROR: ' || sqlcode || ' msg: ' || sqlerrm);
    raise;
end;
/
show errors;

drop procedure fsDrop;
drop function fsEnqName;

undefine fs_name

