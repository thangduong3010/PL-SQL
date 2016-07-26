Rem
Rem $Header: dbmshsxp.sql 23-jun-2003.11:01:51 mramache Exp $
Rem
Rem dbmshsxp.sql
Rem
Rem Copyright (c) 2002, 2003, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmshsxp.sql - export action for SQL tuning base
Rem
Rem    DESCRIPTION
Rem      Implements export action which is automatically called by export
Rem      to export SQL tuning base. Generates Pl/SQL to create sql profiles,
Rem      which is stored by export in the export file, later to be invoked by 
Rem      import.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mramache    06/23/03 - sql profiles
Rem    aime        04/25/03 - aime_going_to_main
Rem    mramache    01/15/03 - mramache_5955_stb
Rem    mramache    01/13/03 - get rid of hard-tabs
Rem    atsukerm    12/23/02 - Created
Rem

CREATE OR REPLACE PACKAGE dbmshsxp AUTHID CURRENT_USER AS

-- Generate PL/SQL for procedural actions
 FUNCTION system_info_exp(prepost IN PLS_INTEGER,
                          connectstring OUT VARCHAR2,
                          version IN VARCHAR2,
                          new_block OUT PLS_INTEGER)
 RETURN VARCHAR2;

END dbmshsxp;
/
CREATE OR REPLACE PUBLIC SYNONYM dbmshsxp
   for sys.dbmshsxp
/
GRANT EXECUTE ON dbmshsxp TO EXECUTE_CATALOG_ROLE
/
