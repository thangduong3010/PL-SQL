Rem
Rem $Header: dbmsslxp.sql 31-may-2003.09:13:18 jxchen Exp $
Rem
Rem dbmsslxp.sql
Rem
Rem Copyright (c) 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsslxp.sql - export action for Server aLert threshold
Rem
Rem    DESCRIPTION
Rem      Implements export action which is automatically called by export
Rem      to export server alert threshold.  Generate Pl/SQL blocks to 
Rem      define thresholds, which are stored by export in the export file,
Rem      later to be invoked by import.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jxchen      05/31/03 - jxchen_alrt8
Rem    jxchen      05/14/03 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_server_alert_export AUTHID CURRENT_USER AS

-- Generate PL/SQL for procedural actions
 FUNCTION system_info_exp(prepost IN PLS_INTEGER,
                          connectstring OUT VARCHAR2,
                          version IN VARCHAR2,
                          new_block OUT PLS_INTEGER)
 RETURN VARCHAR2;

END dbms_server_alert_export;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_server_alert_export
   for sys.dbms_server_alert_export
/
GRANT EXECUTE ON dbms_server_alert_export TO EXECUTE_CATALOG_ROLE
/
