Rem Copyright (c) 2009, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      dbmsadr.sql - Administrative interface for Auto. Diag. Repository
Rem
Rem    DESCRIPTION
Rem      Declares the dbms_adr package (src/server/diagfw/adr/ami/prvtadr.sql)
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mfallen     04/12/09 - bug 6976775: add downgrade
Rem    mfallen     04/12/09 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_adr AS

  --
  -- migrate_schema()
  --   This routine migrates the ADR home to the current version
  --
  -- Input arguments:
  --   none
  -- 
  PROCEDURE migrate_schema;

  --
  -- downgrade_schema()
  --   This routine downgrades the ADR home by restoring files
  --
  -- Input arguments:
  --   none
  -- 
  PROCEDURE downgrade_schema;

  --
  -- recover_schema()
  --   This routine tries to bring the ADR home to a consistent state
  --   after a failed migrate or downgrade operation.
  --
  -- Input arguments:
  --   none
  -- 
  PROCEDURE recover_schema;

  --
  -- cleanout_schema()
  --   This routine recreates the ADR home, without any diagnostic contents
  --
  -- Input arguments:
  --   none
  -- 
  PROCEDURE cleanout_schema;

END dbms_adr;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_adr 
FOR sys.dbms_adr
/
GRANT EXECUTE ON dbms_adr TO dba
/
-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_ADR_LIB TRUSTED AS STATIC;
/
