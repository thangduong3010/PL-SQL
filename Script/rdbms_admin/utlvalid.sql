rem 
Rem Copyright (c) 1990, 1995, 1996, 1998 by Oracle Corporation
Rem NAME
REM    UTLVALID.SQL
Rem  FUNCTION
Rem    Creates the default table for storing the output of the
Rem    analyze validate command on a partitioned table
Rem  NOTES
Rem  MODIFIED
Rem     syeung     06/17/98 - add subpartition_name                            
Rem     mmonajje   05/21/96 - Replace timestamp col name with analyze_timestamp
Rem     sbasu      05/07/96 - Remove echo setting
Rem     ssamu      01/09/96 - new file utlvalid.sql
Rem

create table INVALID_ROWS (
  owner_name         varchar2(30),
  table_name         varchar2(30),
  partition_name     varchar2(30),
  subpartition_name  varchar2(30),
  head_rowid         rowid,
  analyze_timestamp  date
);

