rem 
rem $Header: utlchain.sql 07-may-96.19:40:01 sbasu Exp $ 
rem 
Rem Copyright (c) 1990, 1995, 1996, 1998 by Oracle Corporation
Rem NAME
REM    UTLCHAIN.SQL
Rem  FUNCTION
Rem    Creates the default table for storing the output of the
Rem    analyze list chained rows command
Rem  NOTES
Rem  MODIFIED
Rem     syeung     06/17/98  - add subpartition_name                           
Rem     mmonajje   05/21/96 -  Replace timestamp col name with analyze_timestam
Rem     sbasu      05/07/96 -  Remove echo setting
Rem     ssamu      08/14/95 -  merge PTI with Objects
Rem     ssamu      07/24/95 -  add field for partition name
Rem     glumpkin   10/19/92 -  Renamed from CHAINROW.SQL 
Rem     ggatlin    03/09/92 -  add set echo on 
Rem     rlim       04/29/91 -         change char to varchar2 
Rem   Klein      01/10/91 - add owner name for chained rows
Rem   Klein      12/04/90 - Creation
Rem

create table CHAINED_ROWS (
  owner_name         varchar2(30),
  table_name         varchar2(30),
  cluster_name       varchar2(30),
  partition_name     varchar2(30),
  subpartition_name  varchar2(30),
  head_rowid         rowid,
  analyze_timestamp  date
);

