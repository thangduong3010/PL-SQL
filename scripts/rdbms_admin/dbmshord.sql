Rem Copyright (c) 2000, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmshord.sql - Online ReDefintion of Tables
Rem
Rem    DESCRIPTION
Rem      This files contains dbms_redefinition package which allows for an 
Rem      out-of-place, online redefintion of tables
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    prakumar    10/29/09 - Bug 6321275: Support of redef apis in USER mode
Rem    ajadams     12/03/08 - make procedures DDL like for replication
Rem    svivian     08/15/08 - add pragmas to dbms_redefinition
Rem    wesmith     04/12/06 - support online redefintion of tables with MV logs
Rem    xan         05/06/04 - modify copy_table_dependents 
Rem    masubram    05/04/04 - support redefinition of a partition 
Rem    masubram    10/01/02 - add clone_dependent_objects
Rem    masubram    09/29/02 - order by clause for online redef complete ref
Rem    masubram    09/24/02 - add register_dependent_object
Rem    masubram    01/25/02 - add constant keyword
Rem    masubram    01/11/02 - add paramater to can_redef_table
Rem    masubram    11/14/01 - add parameter to start_redef_table
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    masubram    05/15/00 - Created
Rem


CREATE OR REPLACE PACKAGE dbms_redefinition AUTHID CURRENT_USER IS
  ------------
  --  OVERVIEW
  --
  -- This package provides the API to perform an online, out-of-place
  -- redefinition of a table

  --- =========
  --- CONSTANTS
  --- =========
  -- Constants for the options_flag parameter of start_redef_table
  cons_use_pk    CONSTANT PLS_INTEGER := 1;
  cons_use_rowid CONSTANT PLS_INTEGER := 2;

  -- Constants used for the object types in the register_dependent_object
  cons_index      CONSTANT PLS_INTEGER := 2;
  cons_constraint CONSTANT PLS_INTEGER := 3;
  cons_trigger    CONSTANT PLS_INTEGER := 4;
  cons_mvlog      CONSTANT PLS_INTEGER := 10;

  -- constants used to specify the method of copying indexes
  cons_orig_params CONSTANT PLS_INTEGER := 1;

  PRAGMA SUPPLEMENTAL_LOG_DATA(default, AUTO_WITH_COMMIT);

  -- NAME:     can_redef_table - check if given table can be re-defined
  -- INPUTS:   uname        - table owner name
  --           tname        - table name
  --           options_flag - flag indicating user options to use
  --           part_name    - partition name
  PROCEDURE can_redef_table(uname        IN VARCHAR2,
                            tname        IN VARCHAR2,
                            options_flag IN PLS_INTEGER := 1,
                            part_name    IN VARCHAR2 := NULL);
  PRAGMA SUPPLEMENTAL_LOG_DATA(can_redef_table, NONE);

  -- NAME:     start_redef_table - start the online re-organization
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           col_mapping  - select list col mapping
  --           options_flag - flag indicating user options to use
  --           orderby_cols - comma separated list of order by columns
  --                          followed by the optional ascending/descending 
  --                          keyword
  --           part_name    - name of the partition to be redefined
  PROCEDURE start_redef_table(uname        IN VARCHAR2,
                              orig_table   IN VARCHAR2,
                              int_table    IN VARCHAR2,
                              col_mapping  IN VARCHAR2 := NULL,
                              options_flag IN BINARY_INTEGER := 1,
                              orderby_cols IN VARCHAR2 := NULL,
                              part_name    IN VARCHAR2 := NULL);

  -- NAME:     finish_redef_table - complete the online re-organization
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           part_name    - name of the partition being redefined
  PROCEDURE finish_redef_table(uname          IN VARCHAR2,
                               orig_table     IN VARCHAR2,
                               int_table      IN VARCHAR2,
                               part_name      IN VARCHAR2 := NULL);

  -- NAME:     abort_redef_table - clean up after errors or abort the 
  --                               online re-organization
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           part_name    - name of the partition being redefined
  PROCEDURE abort_redef_table(uname        IN VARCHAR2,
                              orig_table   IN VARCHAR2,
                              int_table    IN VARCHAR2,
                              part_name    IN VARCHAR2 := NULL);

  -- NAME:     sync_interim_table - synchronize interim table with the original
  --                                table
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           part_name    - name of the partition being redefined
  PROCEDURE sync_interim_table(uname       IN VARCHAR2,
                               orig_table  IN VARCHAR2,
                               int_table   IN VARCHAR2,
                               part_name   IN VARCHAR2 := NULL);

  -- NAME:     register_dependent_object - register dependent object
  --
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           dep_type     - type of the dependent object
  --           dep_owner    - name of the dependent object owner
  --           dep_orig_name- name of the dependent object defined on table
  --                          being re-organized
  --           dep_int_name - name of the corressponding dependent object on
  --                          the interim table
  PROCEDURE register_dependent_object(uname         IN VARCHAR2,
                                      orig_table    IN VARCHAR2,
                                      int_table     IN VARCHAR2,
                                      dep_type      IN PLS_INTEGER,
                                      dep_owner     IN VARCHAR2,
                                      dep_orig_name IN VARCHAR2,
                                      dep_int_name  IN VARCHAR2);

  -- NAME:     unregister_dependent_object - unregister dependent object
  --
  -- INPUTS:   uname        - schema name 
  --           orig_table   - name of table to be re-organized
  --           int_table    - name of interim table
  --           dep_type     - type of the dependent object
  --           dep_owner    - name of the dependent object owner
  --           dep_orig_name- name of the dependent object defined on table
  --                          being re-organized
  --           dep_int_name - name of the corressponding dependent object on
  --                          the interim table
  PROCEDURE unregister_dependent_object(uname         IN VARCHAR2,
                                        orig_table    IN VARCHAR2,
                                        int_table     IN VARCHAR2,
                                        dep_type      IN PLS_INTEGER,
                                        dep_owner     IN VARCHAR2,
                                        dep_orig_name IN VARCHAR2,
                                        dep_int_name  IN VARCHAR2);

  --  NAME:     copy_table_dependents
  --
  --  INPUTS:  uname             - schema name 
  --           orig_table        - name of table to be re-organized
  --           int_table         - name of interim table
  --           copy_indexes      - integer value indicating whether to 
  --                               copy indexes
  --                               0 - don't copy
  --                               1 - copy using storage params/tablespace
  --                                   of original index
  --           copy_triggers      - TRUE implies copy triggers, FALSE otherwise
  --           copy_constraints   - TRUE implies copy constraints, FALSE
  --                                otherwise
  --           copy_privileges    - TRUE implies copy privileges, FALSE 
  --                                otherwise
  --           ignore errors      - TRUE implies continue after errors, FALSE
  --                                otherwise
  --           num_errors         - number of errors that occurred while 
  --                                cloning ddl
  --           copy_statistics    - TRUE implies copy table statistics, FALSE
  --                                otherwise.
  --                                If copy_indexes is 1, copy index
  --                                related statistics, 0 otherwise.
  --           copy_mvlog         - TRUE implies copy table's MV log, FALSE
  --                                otherwise.
  PROCEDURE copy_table_dependents(uname              IN  VARCHAR2,
                                  orig_table         IN  VARCHAR2,
                                  int_table          IN  VARCHAR2,
                                  copy_indexes       IN  PLS_INTEGER := 1,
                                  copy_triggers      IN  BOOLEAN := TRUE,
                                  copy_constraints   IN  BOOLEAN := TRUE,
                                  copy_privileges    IN  BOOLEAN := TRUE,
                                  ignore_errors      IN  BOOLEAN := FALSE,
                                  num_errors         OUT PLS_INTEGER,
                                  copy_statistics    IN  BOOLEAN := FALSE,
                                  copy_mvlog         IN  BOOLEAN := FALSE);

END;
/
SHOW ERRORS;

GRANT EXECUTE ON dbms_redefinition TO execute_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_redefinition FOR dbms_redefinition
/
