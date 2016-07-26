Rem
Rem $Header: dbmsdbv.sql 29-mar-2004.18:40:20 bemeng Exp $
Rem
Rem dbmsdbv.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsdbv.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bemeng      12/19/03 - make this a fixed package
Rem    bemeng      10/30/02 - bemeng_dbv_support_osm
Rem    amganesh    10/14/02 - 
Rem    amganesh    10/12/02 - Created
Rem

create or replace PACKAGE dbms_dbverify authid current_user IS

-- DE-HEAD     <- tell SED where to cut when generating fixed package

  PROCEDURE dbv2(fname       IN   varchar2
                ,start_blk   IN   binary_integer
                ,end_blk     IN   binary_integer
                ,blocksize   IN   binary_integer
                ,output      IN OUT  varchar2
                ,error       IN OUT  varchar2
                ,stats       IN OUT  varchar2);

  -- Verify blocks in datafile
  --
  --   Input parameters
  --     fname - Datafile to scan 
  --     start - Start block address
  --     end - End block address
  --     blocksize - Logical block size
  --     outout - Output message buffer
  --     error - Error message buffer
  --     stats - Stats message buffer

-------------------------------------------------------------------------------
  pragma TIMESTAMP('2004-03-29:18:43:00');
-------------------------------------------------------------------------------

END;

-- CUT_HERE    <- tell sed where to chop off the rest

/
