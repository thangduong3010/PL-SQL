Rem
Rem $Header: dbmslink.sql 12-oct-2004.14:19:25 rvissapr Exp $
Rem
Rem dbmslink.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmslink.sql - Package declaration for DBMS_DBLINK encoding.
Rem
Rem    DESCRIPTION
Rem      This file contains the declaration of the package DBMS_DBLINK that 
Rem    is a definers right package and by default can be executed only by a SYSDBA.     
Rem
Rem    NOTES
Rem      Project 5523
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rvissapr    10/12/04 - bug 3802440 - cleanup 
Rem    rvissapr    06/24/04 - remove echo 
Rem    rvissapr    06/04/04 - rvissapr_dblink_obfuscate_phase_1
Rem    rvissapr    04/14/04 - Created
Rem


CREATE OR REPLACE PACKAGE dbms_dblink AS
 
 ---- NAME
 --    PROCEDURE upgrade
 --
 -- DESCRIPTION 
 --    upgrades all database links, this will simply execute the DDL
 -- as the owner of the database link. This needs to be in the migrate mode
 -- and the current user executing this should be SYSDBA user.
 PROCEDURE upgrade;
 
END;
/
SHOW ERRORS

CREATE OR REPLACE PUBLIC SYNONYM dbms_dblink FOR sys.dbms_dblink
/

GRANT EXECUTE ON sys.dbms_dblink TO execute_catalog_role
/