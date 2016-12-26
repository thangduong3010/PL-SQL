Rem
Rem $Header: catrms.sql 14-sep-2001.13:05:02 kpeyetti Exp $
Rem
Rem catrms.sql
Rem
Rem Copyright (c) 2001, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      catrms.sql - CATalog script for transparent gateway for RMS
Rem
Rem    DESCRIPTION
Rem      Create utility package to be used in combination with Transparent
Rem      Gateway for RMS
Rem
Rem      Objects created by this script are:
Rem          dbms_tg4rms      Package containing prototypes for utility procs
Rem          dbms_tg4rms      Package body containing implementation
Rem          dbms_tg4rms      Public synonym for package
Rem                                    
Rem    NOTES
Rem      This script must be run while connected as SYS
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kpeyetti    09/14/01 - Merged kpeyetti_dbms_hs_errors
Rem    kpeyetti    09/11/01 - Created
Rem

-- 
--############################################################################# 
-- 
--############################################################################# 
--  

-- Install the dbms_tg4rms.package

@@dbmsrms
@@prvtrms.plb

commit;
