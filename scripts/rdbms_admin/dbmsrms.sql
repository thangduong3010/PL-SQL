Rem
Rem $Header: dbmsrms.sql 29-jan-2002.17:05:57 gviswana Exp $
Rem
Rem dbmsrms.sql
Rem
Rem Copyright (c) 2001, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsrms.sql -  Utility package for transparent gateway for RMS
Rem
Rem    DESCRIPTION
Rem
Rem      Defines the utility package to be used in combination with Transparent
Rem      Gateway for RMS
Rem
Rem    NOTES
Rem      This script must be run while connected as SYS. It must not be
Rem      invoked directly. Instead catrms.sql must be invoked.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    kpeyetti    09/14/01 - Merged kpeyetti_dbms_hs_errors
Rem    kpeyetti    09/11/01 - Created
Rem
REM  ***********************************************************************
REM  THESE PACKAGES AND PACKAGE BODIES MUST NOT BE MODIFIED BY THE CUSTOMER.
REM  DOING SO COULD CAUSE INTERNAL ERRORS AND CORRUPTIONS IN THE RDBMS.
REM  ***********************************************************************
 
REM  ************************************************************
REM  THESE PACKAGES AND PACKAGE BODIES MUST BE CREATED UNDER SYS.
REM  ************************************************************

create or replace package "DBMS_TG4RMS" AUTHID CURRENT_USER as

  -- no exceptions

  -- Public procedures

  procedure addl_to_add(
    FILENAME in VARCHAR2,
    DBLINK in VARCHAR2 default 'rms');

  procedure add_to_addl(
    RMS_RECORD in VARCHAR2,
    FILENAME in VARCHAR2,
    DBLINK in VARCHAR2 default 'rms');

  procedure update_statistics(
    RMS_RECORD in VARCHAR2,
    OPTION_STRING in VARCHAR2 default NULL,
    DBLINK in VARCHAR2 default 'rms');

end "DBMS_TG4RMS";
/

grant execute on dbms_tg4rms to public;

create or replace public synonym dbms_tg4rms for dbms_tg4rms;
