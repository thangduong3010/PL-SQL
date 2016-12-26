Rem
Rem $Header: rdbms/admin/dbmsscnc.sql /st_rdbms_11.2.0/1 2013/04/18 23:05:40 vgokhale Exp $
Rem
Rem dbmsscn.sql
Rem
Rem Copyright (c) 2012, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsscnc.sql - dbms_scn package definition
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mtiwary     05/26/12 - Declarations and definitions related to DBMS_SCN
Rem                           package.
Rem    mtiwary     05/26/12 - Created
Rem

Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/admin/dbmsscn.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

CREATE OR REPLACE LIBRARY DBMS_SCN_LIB TRUSTED AS STATIC;
/

CREATE OR REPLACE PACKAGE DBMS_SCN AUTHID CURRENT_USER IS

DBMS_SCN_API_MAJOR_VERSION  CONSTANT NUMBER := 1; 
DBMS_SCN_API_MINOR_VERSION  CONSTANT NUMBER := 0;

PROCEDURE GetCurrentSCNParams(
                rsl      OUT number,
                headroom_in_scn OUT number,
                headroom_in_sec OUT number,
                cur_scn_compat OUT number,
                max_scn_compat OUT number);

--      Currently no exceptions are thrown.
--      rsl             - Reasonable SCN Limit as of 'now'
--      headroom_in_scn - Difference between current SCN and RSL
--      headroom_in_sec - number of seconds it would take to reach RSL
--                        assuming a constant SCN consumption rate associated
--                        with current SCN compatibility level
--      cur_scn_compat  - current value of SCN compatibility
--      max_scn_compat  - max value of SCN compatibility this database
--                        understands

FUNCTION GetSCNParamsByCompat(
                compat IN number,
                rsl           OUT number,
                headroom_in_scn OUT number,
                headroom_in_sec OUT number
         ) RETURN boolean;

--     compat           -- SCN compatibility value
--     rsl              -- Reasonable SCN Limit
--     headroom_in_scn  -- Difference between current SCN and RSL
--     headroom_in_sec  -- number of seconds it would take to reach RSL
--                         assuming a constant SCN consumption rate associated
--                         with specified database SCN compatibility
--
--     Returns False if 'compat' parameter value is invalid, and OUT parameters
--     are not updated.

PROCEDURE GetSCNAutoRolloverParams(
                effective_auto_rollover_ts OUT DATE,
                target_compat OUT number,
                is_enabled OUT boolean);

--      effective_auto_rollover_ts  - timestamp at which rollover becomes
--                                    effective
--      target_compat               - SCN compatibility value this database
--                                    will move to, as a result of
--                                    auto-rollover
--      is_enabled                  - TRUE if auto-rollover feature is
--                                    currently enabled

PROCEDURE EnableAutoRollover;

PROCEDURE DisableAutoRollover;

END DBMS_SCN;
/

