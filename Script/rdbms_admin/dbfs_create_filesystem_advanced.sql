Rem
Rem $Header: rdbms/admin/dbfs_create_filesystem_advanced.sql /st_rdbms_11.2.0/1 2012/10/29 10:22:03 weizhang Exp $
Rem
Rem dbfs_create_filesystem.sql
Rem
Rem Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbfs_create_filesystem_advanced.sql - DBFS create filesystem
Rem
Rem    DESCRIPTION
Rem      DBFS create filesystem script
Rem      Usage: sqlplus @dbfs_create_filesystem_advanced.sql  
Rem             <tablespace_name> <filesystem_name> 
Rem             <compress-high | compress-medium  | nocompress> 
Rem             <deduplicate | nodeduplicate> <encrypt | noencrypt>
Rem             <non-partition | partition | partition-by-itemname | 
Rem              partition-by-guid, partition-by-path>
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      10/21/12 - Backport weizhang_bug-14666696 from main
Rem    weizhang    03/11/10 - bug 9220947: tidy up
Rem    weizhang    06/12/09 - Package name change
Rem    weizhang    04/06/09 - Created
Rem

SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF
SET SERVEROUTPUT ON

define ts_name      = &1
define fs_name      = &2
define fs_compress  = &3
define fs_dedup     = &4
define fs_encrypt   = &5
define fs_partition = &6

--------------------------------------------------
-- Create DBFS file system help procedure
--------------------------------------------------

create or replace function fsEnqName (v in varchar2)
  return varchar2
is
  ret     varchar2(1024);
begin
  ret := dbms_assert.enquote_literal(replace(v, '''', ''''''));
  return ret;
end;
/

create or replace procedure fsCreate (
  tsname        in  varchar2,
  volName       in  varchar2,
  do_partition  in  varchar2  default 'true',
  partition_key in  number    default 1,
  do_compress   in  varchar2  default 'false',
  compression   in  varchar2  default '',
  do_dedup      in  varchar2  default 'false',
  do_encrypt    in  varchar2  default 'false'
  )
authid current_user
IS
  fsname  varchar2(100);
  tabname varchar2(100);
  mntdir  varchar2(100);
  stmt    varchar2(32000);
  mntmode integer := 16895;
BEGIN
  fsname  := upper('FS_' || to_char(volName));
  tabname := upper('T_'  || to_char(volName));
  mntdir  := volName;

  -- create file store
  stmt := 'begin dbms_dbfs_sfs.createFilesystem(' ||
          'store_name => '      || fsEnqName(fsname) ||
          ', tbl_name => '      || fsEnqName(tabname) ||
          ', tbl_tbs => '       || fsEnqName(tsname) ||
          ', lob_tbs => '       || fsEnqName(tsname) || 
          ', do_partition => '  || do_partition || 
          ', partition_key => ' || partition_key || 
          ', do_compress => '   || do_compress ||
          ', compression => '   || fsEnqName(compression) ||
          ', do_dedup => '      || do_dedup ||
          ', do_encrypt => '    || do_encrypt ||
          '); end;' ;
  dbms_output.put_line('--------');
  dbms_output.put_line('CREATE STORE: ');
  dbms_output.put_line(stmt);
  execute immediate stmt;

  stmt := 'begin dbms_dbfs_content.registerStore(' ||
          'store_name=> ' || fsEnqName(fsname) ||
          ', provider_name => ''sample1''' ||
          ', provider_package => ''dbms_dbfs_sfs''); end;';
  dbms_output.put_line('--------');
  dbms_output.put_line('REGISTER STORE: ');
  dbms_output.put_line(stmt);
  execute immediate stmt;

  stmt := 'begin dbms_dbfs_content.mountStore(' ||
          'store_name=>'    || fsEnqName(fsname) ||
          ', store_mount=>' || fsEnqName(mntdir) ||
          '); end;';
  dbms_output.put_line('--------');
  dbms_output.put_line('MOUNT STORE: ');
  dbms_output.put_line(stmt);
  execute immediate stmt;

  commit;

  stmt := 'declare m integer; begin m := dbms_fuse.fs_chmod(' ||
          fsEnqName('/' || mntdir) || 
          ', ' || to_char(mntmode) || '); end;';
  dbms_output.put_line('--------');
  dbms_output.put_line('CHMOD STORE: ');
  dbms_output.put_line(stmt);
  execute immediate stmt;

  commit;
END;
/
show errors;

--------------------------------------------------
-- Main entry
--------------------------------------------------

declare
  do_compress   varchar2(32);
  do_dedup      varchar2(32);
  do_encrypt    varchar2(32);
  do_partition  varchar2(32);
  compression   varchar2(32);
  partition_key number;
begin
  select decode(lower('&fs_compress'), 
                'compress', 'true',
                'compress-high', 'true',
                'compress-medium', 'true',
                'compress-low', 'true',
                'nocompress', 'false',
                'false')
      into do_compress from dual;
      
  select decode(lower('&fs_compress'), 
                'compress', dbms_dbfs_sfs.compression_default, 
                'compress-high', dbms_dbfs_sfs.compression_high, 
                'compress-medium', dbms_dbfs_sfs.compression_medium,
                'compress-low', dbms_dbfs_sfs.compression_low,
                dbms_dbfs_sfs.compression_default) 
      into compression from dual;
      
  select decode(lower('&fs_dedup'), 
                'deduplicate', 'true', 
                'nodeduplicate', 'false', 
                'false') 
      into do_dedup from dual;
      
  select decode(lower('&fs_encrypt'), 
                'encrypt', 'true', 
                'noencrypt', 'false', 
                'false') 
      into do_encrypt from dual;
      
  select decode(lower('&fs_partition'), 
                'partition', 'true', 
                'partition-by-itemname', 'true', 
                'partition-by-path', 'true', 
                'partition-by-guid', 'true', 
                'non-partition', 'false', 
                'false') 
      into do_partition from dual;
      
  select decode(lower('&fs_partition'), 
                'partition', dbms_dbfs_sfs.partition_by_item, 
                'partition-by-itemname', dbms_dbfs_sfs.partition_by_item, 
                'partition-by-path', dbms_dbfs_sfs.partition_by_path, 
                'partition-by-guid', dbms_dbfs_sfs.partition_by_guid, 
                dbms_dbfs_sfs.partition_by_item) 
      into partition_key from dual;
      
  fsCreate('&ts_name', '&fs_name', 
           do_partition, partition_key,
           do_compress, compression, 
           do_dedup, do_encrypt);
exception
  when others then
    rollback;
    dbms_output.put_line('ERROR: ' || sqlcode || ' msg: ' || sqlerrm);
    raise;
end;
/
show errors;

commit;

drop procedure fsCreate;
drop function fsEnqName;

undefine ts_name
undefine fs_name
undefine fs_compress
undefine fs_dedup
undefine fs_encrypt
undefine fs_partition

