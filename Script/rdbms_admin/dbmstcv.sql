Rem
Rem $Header: dbmstcv.sql 04-dec-2006.18:12:03 ilam Exp $
Rem
Rem dbmstcv.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmstcv.sql - DBMS Trace ConVersion package for adminstrators
Rem
Rem    DESCRIPTION
Rem      Trace Conversion Package
Rem      This package is not supported for external use and should be
Rem      limited to use by only DDR and internal development.
Rem
Rem    NOTES
Rem      Package will include procedures that make Trusted Callouts
Rem      to the kernel
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ilam        12/04/06 - Update documentation for this script
Rem    ilam        10/15/02 - ilam_kst_formatcb_plsql
Rem    ilam        09/25/02 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_server_trace AS

  -- convert_binary_trace_file
  -- This procedure converts all trace data for the specified
  -- input file from binary to text format and output to
  -- a specified output file
  --
  -- Input arguments:
  --   infile  - input file with binary trace data
  --   outfile - output file for converted text traces
  --   fmode   - TRUE for default format, FALSE for user-defined format

  PROCEDURE convert_binary_trace_file(infile  IN VARCHAR2,
                                      outfile IN VARCHAR2,
                                      fmode   IN BOOLEAN
                                     );

END;
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_server_trace
FOR sys.dbms_server_trace
/

GRANT EXECUTE ON dbms_server_trace TO dba
/

-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_SERVER_TRACE_LIB TRUSTED AS STATIC;
/
