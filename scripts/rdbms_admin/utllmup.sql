Rem
Rem $Header: utllmup.sql 14-mar-2005.10:30:06 jnesheiw Exp $
Rem
Rem utllmup.sql
Rem
Rem Copyright (c) 2003, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utllmup.sql - Logminer Metadata Update
Rem
Rem    DESCRIPTION
Rem      This script should be run at the end of upgrade to write 
Rem      dictionary information to the redo stream for use by logminer
Rem      clients such as Streams.
Rem
Rem      Running an upgrade will automatically execute this script at
Rem      the very end of the ugprade process.
Rem
Rem      If a user manually re-executes portions of the upgrade script
Rem      after the main upgrade is complete, this script should also be
Rem      run to manually update the logminer metadata.
Rem
Rem    NOTES
Rem      This script will not do anything if minimal supplemental logging
Rem      and log archiving are not both enabled.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jnesheiw    02/22/05 - Remove constant 
Rem    dvoss       08/23/04 - incorrect check for sup log 
Rem    qiwang      01/18/03 - qiwang_logmnr_ckpt_conv
Rem    dvoss       01/14/03 - Created
Rem

declare
  rowcnt number;
begin
    SELECT COUNT(1) into rowcnt
    FROM SYS.V$DATABASE V
    WHERE V.LOG_MODE = 'ARCHIVELOG' and
          V.SUPPLEMENTAL_LOG_DATA_MIN != 'NO';
    IF 0 != rowcnt THEN
      dbms_logmnr_d.build(options=>4);
    END IF;
end;
/
