Rem
Rem $Header: dbmserlg.sql 17-aug-2005.17:14:44 lvbcheng Exp $
Rem
Rem dbmserlg.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmserlg.sql - DBMS_ERRLOG
Rem
Rem    DESCRIPTION
Rem    DBMS_ERRLOG - DML Error logging
Rem
Rem    NOTES
Rem      DBMS_ERRLOG - originally located in dbmsutil.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lvbcheng    08/17/05 - lvbcheng_split_dbms_util
Rem    lvbcheng    07/29/05 - Transferred here from dbmsutil.sql
Rem      abrumm    03/17/04 - DML Error Logging: add dbms_errlog 
Rem

Rem ********************************************************************
Rem THESE PACKAGES MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
Rem COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
Rem RDBMS.  SPECIFICALLY, THE PSD* AND EXECUTE_SQL ROUTINES MUST NOT BE
Rem CALLED DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
Rem ********************************************************************

  --------------------
create or replace package dbms_errlog AUTHID CURRENT_USER is
  --------------------
  -- OVERVIEW
  --
  -- This package is provided to ease the creation of a DML error
  -- logging table based on the shape of a table which DML operations
  -- are to be done on.
  --
  --------------------
  -- PROCEDURES AND FUNCTIONS
  --
  procedure create_error_log(dml_table_name      varchar2,
                             err_log_table_name  varchar2 default NULL,
                             err_log_table_owner varchar2 default NULL,
                             err_log_table_space varchar2 default NULL,
                             skip_unsupported    boolean  default FALSE);
  -- Input arguments:
  --   dml_table_name
  --     Name of the DML table to use to base the shape of error logging
  --     table on.  Name can be fully qualified
  --     (e.g. 'emp', 'scott.emp', '"EMP"', '"SCOTT"."EMP"')
  --     If a name component is enclosed in double quotes, it will not
  --     be upper cased.
  --     DEFAULT: None, mandatory argument.
  --   err_log_table_name
  --     Name of the error logging table to create.
  --     DEFAULT: First 25 characters in the name of the DML table prefixed
  --              with 'ERR$_'.
  --              Example: dml_table_name: 'EMP',
  --                       err_log_table_name: 'ERR$_EMP'
  --              Example: dml_table_name: '"Emp2"',
  --                       err_log_table_name: 'ERR$_Emp2'
  --   err_log_table_owner
  --     Name of the owner of the error table.
  --     DEFAULT: If owner specified in dml_table_name, then default
  --              is owner specified in dml_table_name.
  --              Otherwise, uses schema of current connected user.
  --   err_log_table_space
  --     Tablespace to create the error logging table in.
  --     DEFAULT:  Creating users default tablespace.
  --   skip_unsupported
  --     When skip_unsupported is TRUE, column types which are not
  --     supported by DML Error logging will be skipped over and not
  --     added to the error logging table.
  --     When skip_unsupported is FALSE, an unsupported column type will
  --     cause the procedure to terminate.
  --     DEFAULT: FALSE.
  --
end;
/

create or replace public synonym dbms_errlog for sys.dbms_errlog
/

grant execute on dbms_errlog to public
/


