Rem
Rem $Header: dbmsmetd.sql 27-apr-2004.15:32:41 lbarton Exp $
Rem
Rem dbmsmetd.sql
Rem
Rem Copyright (c) 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem     dbmsmetd.sql - Package header for DBMS_METADATA_DPBUILD.
Rem     NOTE - Package body is in:
Rem            rdbms/src/server/datapump/ddl/prvtmetd.sql
Rem    DESCRIPTION
Rem     This file contains the package header for DBMS_METADATA_DPBUILD,
Rem     an invoker's rights package that creates the data pump 
Rem     heterogeneous object types
Rem
Rem    FUNCTIONS / PROCEDURES
Rem 
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lbarton     04/27/04 - lbarton_bug-3334702
Rem    lbarton     01/28/04 - Created
Rem

CREATE OR REPLACE PACKAGE DBMS_METADATA_DPBUILD AUTHID CURRENT_USER AS

---------------------------
-- PROCEDURES AND FUNCTIONS
--

 PROCEDURE create_table_export;

 PROCEDURE create_schema_export;

 PROCEDURE create_database_export;

 PROCEDURE create_transportable_export;

END DBMS_METADATA_DPBUILD;
/
GRANT EXECUTE ON sys.dbms_metadata_dpbuild TO EXECUTE_CATALOG_ROLE; 
CREATE OR REPLACE PUBLIC SYNONYM dbms_metadata_dpbuild
 FOR sys.dbms_metadata_dpbuild;


