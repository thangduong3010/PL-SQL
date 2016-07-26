Rem
Rem $Header: rdbms/admin/dbfs_create_filesystem.sql /main/4 2010/06/01 11:01:01 nmukherj Exp $
Rem
Rem dbfs_create_filesystem.sql
Rem
Rem Copyright (c) 2009, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbfs_create_filesystem.sql - DBFS create filesystem
Rem
Rem    DESCRIPTION
Rem      DBFS create filesystem script
Rem      Usage: sqlplus <dbfs_user> @dbfs_create_filesystem.sql  
Rem             <tablespace_name> <filesystem_name> 
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nmukherj    05/30/10 - changing default to non-partitioned SF segment
Rem    weizhang    03/11/10 - bug 9220947: tidy up
Rem    weizhang    04/06/09 - Created
Rem

SET ECHO OFF
SET VERIFY OFF
SET FEEDBACK OFF
SET TAB OFF
SET SERVEROUTPUT ON

define ts_name      = &1
define fs_name      = &2

@@dbfs_create_filesystem_advanced.sql &ts_name &fs_name nocompress nodeduplicate noencrypt non-partition

undefine ts_name
undefine fs_name

