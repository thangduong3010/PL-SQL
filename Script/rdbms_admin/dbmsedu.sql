Rem
Rem $Header: dbmsedu.sql 06-oct-2006.18:33:24 achoi Exp $
Rem
Rem dbmsedu.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsedu.sql - Package header for DBMS_EDITION
Rem
Rem    DESCRIPTION
Rem     This file contains the public interface for the Edition API.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achoi       08/09/06 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_editions_utilities AUTHID CURRENT_USER AS 
---------------------------------------------------------------------
-- Overview
-- This pkg implements the Edition API, which provides helper function
-- for edition related operations
---------------------------------------------------------------------
-- SECURITY
-- This package is owned by SYS with execute access granted to PUBLIC.
-- It runs with invokers rights, i.e., with the security profile of
-- the caller.
--------------------

-- EXCEPTION
  insuf_priv exception;
  pragma exception_init(insuf_priv, -38817);

  missing_tab exception;
  pragma exception_init(missing_tab, -942);


-- PUBLIC FUNCTION

  /* Given the table name, set the all the Editioning views in all editions
     to read-only or read write.

     NOTE:
       User must have the following privileges:
         1. owner of the table or has ALTER ANY TABLE system privileges
         2. "USE" object privilege on all the editions which the views are
            definied.       

     PARAMETERS:
       table_name - the base table of the editioning views
       owner      - the base table schema. The default (or null) is the current
                    schema.
       read_only  - true if set the views to read-only; false (or null) will
                    set the views to read/write. Default is true.

     EXCEPTIONS:
       INSUF_PRIV exception will be raised if the user doesn't have the above
       privileges.
  */
  PROCEDURE set_editioning_views_read_only(
                 table_name IN VARCHAR2,
                 owner      IN VARCHAR2 DEFAULT NULL,
                 read_only  IN BOOLEAN  DEFAULT TRUE);

END dbms_editions_utilities;
/
GRANT EXECUTE ON sys.dbms_editions_utilities TO PUBLIC; 
CREATE OR REPLACE PUBLIC SYNONYM dbms_editions_utilities
  FOR sys.dbms_editions_utilities;
