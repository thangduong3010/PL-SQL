Rem
Rem $Header: dbmsrwid.sql 17-aug-2005.17:14:45 lvbcheng Exp $
Rem
Rem dbmsrwid.sql
Rem
Rem Copyright (c) 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsrwid.sql - DBMS_ROWID
Rem
Rem    DESCRIPTION
Rem    dbms_rowid              - rowid creation and interpretation
Rem
Rem    NOTES
Rem      DBMS_ROWID was originally located in dbmsutil.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    lvbcheng    08/17/05 - lvbcheng_split_dbms_util
Rem    lvbcheng    07/29/05 - moved here from dbmsutil.sql
Rem    bbaddepu    08/29/02 - ROWID changes for BFT support : ts_type param
Rem    atsukerm    08/02/96 - change DBMS_ROWID for DBA unification.
Rem    atsukerm    05/20/96 - add exceptions to DBMS_ROWID package.
Rem    atsukerm    03/07/96 - add ROWID migration function to DBMS_ROWID.
Rem    atsukerm    11/15/95 - new ROWID format - restricted/extended only
Rem    atsukerm    10/24/95 - new ROWID format - add DBMS_ROWID package.

Rem ********************************************************************
Rem THESE PACKAGES MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
Rem COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
Rem RDBMS.  SPECIFICALLY, THE PSD* AND EXECUTE_SQL ROUTINES MUST NOT BE
Rem CALLED DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
Rem ********************************************************************

create or replace package dbms_rowid is
  ------------
  --  OVERVIEW
  --
  --  This package provides procedures to create ROWIDs and to interpret
  --  their contents

  --  SECURITY
  --
  --  The execution privilege is granted to PUBLIC. Procedures in this
  --  package run under the caller security. 


  ----------------------------

  ----------------------------

  --  ROWID TYPES:
  --
  --   RESTRICTED - Restricted ROWID
  --
  --   EXTENDED   - Extended ROWID 
  --
  rowid_type_restricted constant integer := 0;
  rowid_type_extended   constant integer := 1;

  --  ROWID VERIFICATION RESULTS:
  --
  --   VALID   - Valid ROWID
  --
  --   INVALID - Invalid ROWID 
  --
  rowid_is_valid   constant integer := 0;
  rowid_is_invalid constant integer := 1;

  --  OBJECT TYPES:
  --
  --   UNDEFINED - Object Number not defined (for restricted ROWIDs)
  --
  rowid_object_undefined constant integer := 0;

  --  ROWID CONVERSION TYPES:
  --
  --   INTERNAL - convert to/from column of ROWID type
  --
  --   EXTERNAL - convert to/from string format
  --
  rowid_convert_internal constant integer := 0;
  rowid_convert_external constant integer := 1;

  --  EXCEPTIONS:
  --
  -- ROWID_INVALID  - invalid rowid format
  --
  -- ROWID_BAD_BLOCK - block is beyond end of file
  --
  ROWID_INVALID exception;
     pragma exception_init(ROWID_INVALID, -1410);
  ROWID_BAD_BLOCK exception;
     pragma exception_init(ROWID_BAD_BLOCK, -28516);

  --  PROCEDURES AND FUNCTIONS:
  --

  --
  -- ROWID_CREATE constructs a ROWID from its constituents:
  --
  -- rowid_type - type (restricted/extended) 
  -- object_number - data object number (rowid_object_undefined for restricted)
  -- relative_fno - relative file number
  -- block_number - block number in this file
  -- file_number - file number in this block
  --
  function rowid_create(rowid_type IN number, 
                        object_number IN number,
                        relative_fno IN number,
                        block_number IN number,
                        row_number IN number) 
                        return rowid;
  pragma RESTRICT_REFERENCES(rowid_create,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_INFO breaks ROWID into its components and returns them:
  --
  -- rowid_in - ROWID to be interpreted
  -- rowid_type - type (restricted/extended) 
  -- object_number - data object number (rowid_object_undefined for restricted)
  -- relative_fno - relative file number
  -- block_number - block number in this file
  -- file_number - file number in this block
  -- ts_type_in - type of tablespace which this row belongs to
  --              'BIGFILE' indicates Bigfile Tablespace 
  --              'SMALLFILE' indicates Smallfile (traditional pre-10i) TS.
  --              NOTE: These two are the only allowed values for this param
  --
  procedure rowid_info( rowid_in IN rowid,
                        rowid_type OUT number, 
                        object_number OUT number,
                        relative_fno OUT number,
                        block_number OUT number,
                        row_number OUT number,
                        ts_type_in IN varchar2 default 'SMALLFILE');
  pragma RESTRICT_REFERENCES(rowid_info,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_TYPE returns the type of a ROWID (restricted/extended_nopart,..)
  --
  -- row_id - ROWID to be interpreted
  --
  function rowid_type(row_id IN rowid) 
                        return number;
  pragma RESTRICT_REFERENCES(rowid_type,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_OBJECT extracts the data object number from a ROWID. 
  -- ROWID_OBJECT_UNDEFINED is returned for restricted rowids.
  --
  -- row_id - ROWID to be interpreted
  --
  function rowid_object(row_id IN rowid) 
                        return number;
  pragma RESTRICT_REFERENCES(rowid_object,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_RELATIVE_FNO extracts the relative file number from a ROWID. 
  --
  -- row_id - ROWID to be interpreted
  -- ts_type_in - type of tablespace which this row belongs to
  --
  function rowid_relative_fno(row_id IN rowid,
                              ts_type_in IN varchar2 default 'SMALLFILE')
                        return number;
  pragma RESTRICT_REFERENCES(rowid_relative_fno,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_BLOCK_NUMBER extracts the block number from a ROWID. 
  --
  -- row_id - ROWID to be interpreted
  -- ts_type_in - type of tablespace which this row belongs to
  --
  --
  function rowid_block_number(row_id IN rowid,
                              ts_type_in IN varchar2 default 'SMALLFILE') 
                        return number;
  pragma RESTRICT_REFERENCES(rowid_block_number,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_ROW_NUMBER extracts the row number from a ROWID. 
  --
  -- row_id - ROWID to be interpreted
  --
  function rowid_row_number(row_id IN rowid) 
                        return number;
  pragma RESTRICT_REFERENCES(rowid_row_number,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_TO_ABSOLUTE_FNO extracts the relative file number from a ROWID,
  -- which addresses a row in a given table
  --
  -- row_id - ROWID to be interpreted
  --
  -- schema_name - name of the schema which contains the table
  --
  -- object_name - table name 
  --
  function rowid_to_absolute_fno(row_id IN rowid,
                                 schema_name IN varchar2,
                                 object_name IN varchar2)
                        return number;
  pragma RESTRICT_REFERENCES(rowid_to_absolute_fno,WNDS,WNPS,RNPS);

  --
  -- ROWID_TO_EXTENDED translates the restricted ROWID which addresses
  -- a row in a given table to the extended format. Later, it may be removed
  -- from this package into a different place
  --
  -- old_rowid - ROWID to be converted
  --
  -- schema_name - name of the schema which contains the table (OPTIONAL)
  --
  -- object_name - table name (OPTIONAL)
  --
  -- conversion_type - rowid_convert_internal/external_convert_external
  --                   (whether old_rowid was stored in a column of ROWID
  --                    type, or the character string)
  --
  function rowid_to_extended(old_rowid IN rowid,
                             schema_name IN varchar2,
                             object_name IN varchar2,
                             conversion_type IN integer)
                        return rowid;
  pragma RESTRICT_REFERENCES(rowid_to_extended,WNDS,WNPS,RNPS);

  --
  -- ROWID_TO_RESTRICTED translates the extnded ROWID into a restricted format
  --
  -- old_rowid - ROWID to be converted
  --
  -- conversion_type - internal/external (IN)
  --
  -- conversion_type - rowid_convert_internal/external_convert_external
  --                   (whether returned rowid will be stored in a column of 
  --                    ROWID type, or the character string)
  --
  function rowid_to_restricted(old_rowid IN rowid,
                               conversion_type IN integer)
                        return rowid;
  pragma RESTRICT_REFERENCES(rowid_to_restricted,WNDS,RNDS,WNPS,RNPS);

  --
  -- ROWID_VERIFY verifies the ROWID. It returns rowid_valid or rowid_invalid
  -- value depending on whether a given ROWID is valid or not. 
  --
  -- rowid_in - ROWID to be verified
  --
  -- schema_name - name of the schema which contains the table
  --
  -- object_name - table name 
  --
  -- conversion_type - rowid_convert_internal/external_convert_external
  --                   (whether old_rowid was stored in a column of ROWID
  --                    type, or the character string)
  --
  function rowid_verify(rowid_in IN rowid,
                        schema_name IN varchar2,
                        object_name IN varchar2,
                        conversion_type IN integer)
                        return number;
  pragma RESTRICT_REFERENCES(rowid_verify,WNDS,WNPS,RNPS);

end;
/
create or replace public synonym dbms_rowid for sys.dbms_rowid
/
grant execute on dbms_rowid to public
/

