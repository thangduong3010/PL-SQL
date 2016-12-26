Rem
Rem $Header: dbmspclx.sql 17-aug-2005.17:14:45 lvbcheng Exp $
Rem
Rem dbmspclx.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmspclx.sql - DBMS_PCLXUTIL
Rem
Rem    DESCRIPTION
Rem    dbms_pclxutil         - intra-partition parallelism for creating 
Rem                            partition-wise local index.
Rem
Rem    NOTES
Rem      DBMS_PCXLUTIL was originally located in dbmsutil.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lvbcheng    08/17/05 - lvbcheng_split_dbms_util
Rem    lvbcheng    07/29/05 - moved here from dbmsutil.sql
Rem    pamor       12/04/02 - pclxutil: remove private interfaces from public
Rem    rsujitha    10/15/98 -  Add dbms_pclxutil package
Rem

Rem ********************************************************************
Rem THESE PACKAGES MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
Rem COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
Rem RDBMS.  SPECIFICALLY, THE PSD* AND EXECUTE_SQL ROUTINES MUST NOT BE
Rem CALLED DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
Rem ********************************************************************

create or replace package dbms_pclxutil as 
  ------------
  --  OVERVIEW
  --  
  --  a package that provides intra-partition parallelism for creating 
  --  partition-wise local index.
  --
  --  SECURITY
  --
  --  The execution privilege is granted to PUBLIC. The procedure
  --  build_part_index in this package run under the caller security. 
  --

  ----------------------------

  ----------------------------

  type JobList is table of number;

  procedure build_part_index (
     jobs_per_batch in number default 1,
     procs_per_job  in number default 1,
     tab_name       in varchar2 default null,
     idx_name       in varchar2 default null,
     force_opt      in boolean default FALSE); 
  --
  -- jobs_per_batch: #jobs to be created (1 <= job_count <= #partitions)
  --
  -- procs_per_job:  #slaves per job (1 <= degree <= max_slaves)
  --
  -- tab_name:       name of the partitioned table (an exception is 
  --                 raised if the table does not exist or not 
  --                 partitioned)
  --
  -- idx_name:       name given to the local index (an exception is 
  --                 raised if a local index is not created on the 
  --                 table tab_name)
  --
  -- force_opt:      if TRUE force rebuild of all partitioned indices; 
  --                 otherwise rebuild only the partitions marked 
  --                 'UNUSABLE'
  --

end dbms_pclxutil;
/
create or replace public synonym dbms_pclxutil for sys.dbms_pclxutil
/
grant execute on dbms_pclxutil to public
/

