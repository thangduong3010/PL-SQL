Rem $Header: rdbms/admin/dbmslob.sql /main/28 2010/05/18 11:58:17 sylin Exp $
Rem
Rem dbmslob.sql
Rem 
Rem Copyright (c) 1995, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmslob.sql - DBMS package specification for Oracle8 Large Objects
Rem
Rem    DESCRIPTION
Rem      This package provides routines for operations on BLOB and CLOB
Rem      datatypes.
Rem
Rem    NOTES
Rem      The procedural option is needed to use this package. This package
Rem      must be created under SYS (connect internal). Operations provided 
Rem      by this package are performed under the current calling user, not
Rem      under the package owner SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sylin       05/12/10 - getchunksize and get_storage_limit support for
Rem                           TimesTen
Rem    sylin       11/23/09 - TimesTen support
Rem    slynn       06/12/09 - Move to DBFS naming.
Rem    slynn       01/20/09 - Change AM to use CAPI.
Rem    slynn       04/14/08 - Merge SECUREFILE only errors (43854 & 43856) into
Rem                           one.
Rem    amullick    02/11/08 - add Set/GetContentType APIs
Rem    slynn       12/07/07 - SecureFile Archive API
Rem    slynn       04/05/07 - Add ISSECUREFILE API
Rem    shvenugo    10/13/06 - Mark deterministic functions
Rem    shwang      10/25/06 - delta update API change; do not expose mark
Rem    slynn       07/27/06 - Move to new 11g LOB terminology. 
Rem    slynn       05/26/06 - Add GetSharedRegions 
Rem    slynn       05/22/06 - Add New NG Lob Functionality 
Rem    dbronnik    06/02/06 - Mark deterministic functions
Rem    shwang      04/05/06 - delta update API 
Rem    thchang     09/24/02 - add get_storage_limit
Rem    abagrawa    09/19/02 - Add convertToBlob
Rem    ssubrama    08/28/02 - bug 2495123 parameter name change loadfromfile
Rem    smuralid    01/04/02 - add convertToClob
Rem    ycao        11/12/01 - rename parameters in load*fromfile, add const.
Rem    ycao        08/06/01 - add loadblobfromfile and loadclobfromfile
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    nmallava    07/30/98 - writeappend use NOCOPY
Rem    nmallava    07/08/98 - default for duration
Rem    nmallava    07/07/98 - set default duration
Rem    nmallava    03/30/98 - change dbmslob to use by ref
Rem    skotsovo    04/10/98 - add getchunksize
Rem    skotsovo    04/09/98 - add writeappend
Rem    nmallava    03/17/98 - islobopen and islobtemporary to isopen and istemp
Rem    nmallava    03/02/98 - add istemporary
Rem    nmallava    02/13/98 - add temporary LOBs apis
Rem    nmallava    01/06/98 - open/close internal lobs
Rem    skotsovo    04/18/97 - lob amount for copy/write is in-only
Rem    rpark       04/15/97 - bug 475633: fix loadfromfile argument amount to b
Rem    ramkrish    03/27/97 - Disable LOB buffering support for 8.0
Rem    ramkrish    03/26/97 - flushbuffers -> flushbuffer
Rem    skotsovo    03/20/97 - add exception for error 22280
Rem    rpark       03/13/97 - add support for bfile to lob copy
Rem    ramkrish    02/18/97 - Add LBS calls
Rem    ramkrish    12/26/96 - cosmetic - remove implmn. notes/modify comments
Rem    ramkrish    11/21/96 - GETNAME -> FILEGETNAME: interface change
Rem    ramkrish    11/06/96 - map named exceptions to 21560, 22925
Rem    ramkrish    11/05/96 - documentation+misc cleanup
Rem    ramkrish    11/04/96 - File routine interface changes (w.r.t OCI)
Rem    ramkrish    09/30/96 - Move 24280 - 99 to 22280 - 99
Rem    mchien      08/14/96 - grant to public
Rem    ramkrish    08/09/96 - Change offsets and appr. amounts to INTEGER type
Rem    ramkrish    07/15/96 - Add BFILE Read-Only extensions
Rem    ramkrish    06/20/96 - modify error messages for exceptions
Rem    ramkrish    06/03/96 - remove synonym
Rem    ramkrish    05/30/96 - Dictionary Protection Implementation
Rem    ramkrish    04/26/96 - Code with actual LOB variables
Rem    ramkrish    03/13/96 - Move error handlers for functions into ICDs
Rem    ramkrish    03/09/96 - READ and WRITE with IN offset params
Rem    ramkrish    11/14/95 - Creation.
Rem

REM ********************************************************************
REM THE FUNCTIONS SUPPLIED BY THIS PACKAGE AND ITS EXTERNAL INTERFACE
REM ARE RESERVED BY ORACLE AND ARE SUBJECT TO CHANGE IN FUTURE RELEASES.
REM ********************************************************************

REM ********************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO COULD
REM CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE RDBMS.
REM ********************************************************************

REM ********************************************************************
REM THIS PACKAGE MUST BE CREATED UNDER SYS.
REM ********************************************************************

CREATE OR REPLACE PACKAGE dbms_lob IS
$if utl_ident.is_oracle_server <> TRUE and
    utl_ident.is_timesten <> TRUE $then
  $error 'dbms_lob is not supported in this environment' $end
$end

  ------------
  --  OVERVIEW
  --
  --     This package provides general purpose routines for operations
  --     on Oracle Large OBject (LOBs) datatypes - BLOB, CLOB (read-write)
  --     and BFILEs (read-only).
  --     
  --     Oracle 8.0 SQL supports the definition, creation, deletion, and
  --     complete updates of LOBs. The main bulk of the LOB operations
  --     are provided by this package.
  --

  ------------------------
  -- RULES AND LIMITATIONS
  --
  --     The following rules apply in the specification of functions and 
  --     procedures in this package.
  --
  --     LENGTH and OFFSET parameters for routines operating on BLOBs and
  --     BFILEs are to be specified in terms of bytes.
  --     LENGTH and OFFSET parameters for routines operating on CLOBs
  --     are to be specified in terms of characters.
  --     
  --     A function/procedure will raise an INVALID_ARGVAL exception if the
  --     the following restrictions are not followed in specifying values
  --     for parameters (unless otherwise specified):
  --
  --     1. Only positive, absolute OFFSETs from the beginning of LOB data
  --        are allowed. Negative offsets from the tail of the LOB are not
  --        allowed.
  --     2. Only positive, non-zero values are allowed for the parameters
  --        that represent size and positional quantities such as AMOUNT,
  --        OFFSET, NEWLEN, NTH etc.
  --     3. The value of OFFSET, AMOUNT, NEWLEN, NTH must not exceed the
  --        value lobmaxsize (which is (4GB-1) in Oracle 8.0) in any DBMS_LOB
  --        procedure or function.
  --     4. For CLOBs consisting of fixed-width multi-byte characters, the
  --        maximum value for these parameters must not exceed
  --              (lobmaxsize/character_width_in_bytes) characters
  --        For example, if the CLOB consists of 2-byte characters such as
  --        JA16SJISFIXED, then the maximum amount value should not exceed
  --              4294967295/2 = 2147483647 characters
  --
  --     PL/SQL language specifications stipulate an upper limit of 32767
  --     bytes (not characters) for RAW and VARCHAR2 parameters used in
  --     DBMS_LOB routines.
  --     
  --     If the value of AMOUNT+OFFSET exceeds 4GB (i.e. lobmaxsize+1) for
  --     BLOBs and BFILEs, and (lobmaxsize/character_width_in_bytes)+1 for
  --     CLOBs in calls to update routines - i.e. APPEND, COPY, TRIM, and
  --     WRITE routines, access exceptions will be raised. Under these input
  --     conditions, read routines such as READ, COMPARE, INSTR, SUBSTR, will
  --     read till End of Lob/File is reached.
  --     For example, for a READ operation on a BLOB or BFILE, if the user
  --     specifies offset value of 3GB, and an amount value of 2 GB, READ
  --     will read only ((4GB-1) - 3GB) bytes.
  --
  --     Functions with NULL or invalid input values for parameters will
  --     return a NULL. Procedures with NULL values for destination LOB 
  --     parameters will raise exceptions.  
  --
  --     Operations involving patterns as parameters, such as COMPARE, INSTR,
  --     and SUBSTR do not support regular expressions or special matching 
  --     characters (such as % in the LIKE operator in SQL) in the PATTERN 
  --     parameter or substrings.
  --
  --     The End Of LOB condition is indicated by the READ procedure using
  --     a NO_DATA_FOUND exception. This exception is raised only upon an
  --     attempt by the user to read beyond the end of the LOB/FILE. The
  --     READ buffer for the last read will contain 0 bytes.
  --       
  --     For consistent LOB updates, the user is responsible for locking
  --     the row containing the destination LOB before making a call to
  --     any of the procedures (mutators) that modify LOB data.
  --     
  --     For BFILEs, the routines COMPARE, INSTR, READ, SUBSTR, will raise
  --     exceptions if the file is not already opened using FILEOPEN.
  --

  -----------
  -- SECURITY
  -- 
  --     Privileges are associated with the the caller of the procedures/
  --     functions in this package as follows:
  --     If the caller is an anonymous PL/SQL block, the procedures/functions
  --     are run with the privilege of the current user. 
  --     If the caller is a stored procedure, the procedures/functions are run
  --     using the privileges of the owner of the stored procedure.
  --

  ------------
  -- CONSTANTS
  --
  file_readonly CONSTANT BINARY_INTEGER := 0;
  lob_readonly  CONSTANT BINARY_INTEGER := 0;
  lob_readwrite CONSTANT BINARY_INTEGER := 1;
  lobmaxsize    CONSTANT INTEGER        := 18446744073709551615;
  call          CONSTANT PLS_INTEGER    := 12;
  transaction   CONSTANT PLS_INTEGER    := 11;
  session       CONSTANT PLS_INTEGER    := 10;
  warn_inconvertible_char    CONSTANT INTEGER    := 1;
  default_csid  CONSTANT INTEGER        := 0; 
  default_lang_ctx   CONSTANT INTEGER   := 0;
  no_warning         CONSTANT INTEGER   := 0;
   
    -- Option Types
  opt_compress    CONSTANT PLS_INTEGER    := 1;
  opt_encrypt     CONSTANT PLS_INTEGER    := 2;
  opt_deduplicate CONSTANT PLS_INTEGER    := 4;
  -- 16 is reserved for ContentType (also referred to as MimeType)
  -- 
  
  -- Option Values
  compress_off    CONSTANT PLS_INTEGER    := 0;
  compress_on     CONSTANT PLS_INTEGER    := opt_compress;
  encrypt_off     CONSTANT PLS_INTEGER    := 0;
  encrypt_on      CONSTANT PLS_INTEGER    := opt_encrypt;
  deduplicate_off CONSTANT PLS_INTEGER    := 0;
  deduplicate_on  CONSTANT PLS_INTEGER    := opt_deduplicate;

$if utl_ident.is_oracle_server $then
  -- DBFS Link State Values
  dbfs_link_never	CONSTANT PLS_INTEGER    := 0;
  dbfs_link_yes         CONSTANT PLS_INTEGER    := 1;
  dbfs_link_no          CONSTANT PLS_INTEGER    := 2;

  -- DBFS Link flags
  -- These need to align with flags in SecureFile header
  dbfs_link_nocache   CONSTANT PLS_INTEGER    := 0;
  dbfs_link_cache     CONSTANT PLS_INTEGER    := 1;

  -- maximum length of DBFS Link pathname
  dbfs_link_path_max_size  CONSTANT PLS_INTEGER  := 1024;

  -- maximum length of contenttype string
  -- The assumption is that the ContentType is in ASCII 
  -- (i.e. 1-byte/7-bit UTF8).
  contenttype_max_size   CONSTANT PLS_INTEGER  := 128;
$else
  /* DBFS features not supported in this environment */
$end

-------------
  

  -------------
  -- STRUCTURES
  --
  TYPE blob_deduplicate_region IS RECORD (
    lob_offset          INTEGER, 
    len                 INTEGER,
    primary_lob         BLOB,
    primary_lob_offset  NUMBER,
    mime_type           VARCHAR2(80));

  TYPE blob_deduplicate_region_tab IS TABLE OF blob_deduplicate_region 
       INDEX BY PLS_INTEGER;

  TYPE clob_deduplicate_region IS RECORD (
    lob_offset          INTEGER, 
    len                 INTEGER,
    primary_lob         CLOB,
    primary_lob_offset  NUMBER,
    mime_type           VARCHAR2(80));

  TYPE clob_deduplicate_region_tab IS TABLE OF clob_deduplicate_region 
       INDEX BY PLS_INTEGER;

  -------------
  -- EXCEPTIONS
  --
  invalid_argval EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_argval, -21560);
    invalid_argval_num NUMBER := 21560;
  -- *Mesg: "argument %s is null, invalid, or out of range"
  -- *Cause: The argument is expecting a non-null, valid value but the
  --         argument value passed in is null, invalid, or out of range.
  --         Examples include when the LOB/FILE positional or size
  --         argument has a value outside the range 1 through (4GB - 1),
  --         or when an invalid open mode is used to open a file, etc.
  -- *Action: Check your program and correct the caller of the routine
  --          to not pass a null, invalid or out-of-range argument value.

  access_error EXCEPTION;
    PRAGMA EXCEPTION_INIT(access_error, -22925);
    eccess_error_num NUMBER := 22925;
  -- *Mesg: "operation would exceed maximum size allowed for a lob"
  -- *Cause: Trying to write too much data to the lob.  Lob size is limited
  --         to 4 gigabytes.
  -- *Action: Either start writing at a smaller lob offset or write less data
  --          to the lob.

  noexist_directory EXCEPTION;
    PRAGMA EXCEPTION_INIT(noexist_directory, -22285);
    noexist_directory_num NUMBER := 22285;
  -- *Mesg: "%s failed - directory does not exist"
  -- *Cause: The directory leading to the file does not exist.
  -- *Action: Ensure that a system object corresponding to the specified
  --          directory exists in the database dictionary.

  nopriv_directory EXCEPTION;
    PRAGMA EXCEPTION_INIT(nopriv_directory, -22286);
    nopriv_directory_num NUMBER := 22286;
  -- *Mesg: "%s failed - insufficient privileges on directory"
  -- *Cause: The user does not have the necessary access privileges on the
  --         directory alias and/or the file for the operation.
  -- *Action: Ask the database/system administrator to grant the required
  --          privileges on the directory alias and/or the file.

  invalid_directory EXCEPTION;
    PRAGMA EXCEPTION_INIT(invalid_directory, -22287);
    invalid_directory_num NUMBER := 22287;
  -- *Mesg: "%s failed - invalid or modified directory"
  -- *Cause: The directory alias used for the current operation is not valid
  --         if being accessed for the first time, or has been modified by
  --         the DBA since the last access.
  -- *Action: If you are accessing this directory for the first time, provide
  --          a valid directory name. If you have been already successful in
  --          opening a file under this directory before this error occured,
  --          then first close the file, then retry the operation with a valid
  --          directory alias as modified by your DBA. Oracle strongly
  --          recommends that any changes to directories and/or their
  --          privileges should be done only during quiescent periods of
  --          database operation.

  operation_failed EXCEPTION;
    PRAGMA EXCEPTION_INIT(operation_failed, -22288);
    operation_failed_num NUMBER := 22288;
  -- *Mesg: "file operation %s failed\n%s"
  -- *Cause: The operation attempted on the file failed.
  -- *Action: See the next error message for more detailed information.  Also,
  --          verify that the file exists and that the necessary privileges
  --          are set for the specified operation.  If the error
  --          still persists, report the error to the DBA.

  unopened_file EXCEPTION;
    PRAGMA EXCEPTION_INIT(unopened_file, -22289);
    unopened_file_num NUMBER := 22289;
  -- *Mesg: "cannot perform %s operation on an unopened file"
  -- *Cause: The file is not open for the required operation to be performed.
  -- *Action: Check that the current operation is preceded by a successful
  --          file open operation.

  open_toomany EXCEPTION;
    PRAGMA EXCEPTION_INIT(open_toomany, -22290);
    open_toomany_num NUMBER := 22290;
  -- *Mesg: "%s failed - max limit reached on number of open files"
  -- *Cause: The number of open files has reached the maximum limit.
  -- *Action: Close some of your open files, and retry the operation for your
  --          current session. To increase the database wide limit on number
  --          of open files allowed per session, contact your DBA.

  securefile_badlob EXCEPTION;
    PRAGMA EXCEPTION_INIT(securefile_badlob, -43856);
    securefile_badlob_num NUMBER := 43856;
  -- *Mesg: "%s failed - A non-SecureFile LOB type was used in a SecureFile only call"
  -- *Cause: The locator passed was for a BFILE, TEMP, ABSTRACT or BasicFile LOB
  --         when we expected a SecureFile LOB.
  -- *Action: Be sure a SecureFile is being used before calling this
  --          function or procedure.  You can use issecurefile for this.

  securefile_badparam EXCEPTION;
    PRAGMA EXCEPTION_INIT(securefile_badparam, -43857);
    securefile_badparam_num NUMBER := 43857;
  -- *Mesg: "%s failed - An invalid argument was passed to a SecureFile function or procedure"
  -- *Cause: One of the parameters passed was invalid
  -- *Action: Check all the parameters to be sure they are valid.

  securefile_markerased EXCEPTION;
    PRAGMA EXCEPTION_INIT(securefile_markerased, -43861);
    securefile_markerased_num NUMBER := 43861;
  -- *Mesg: "%s failed - The mark provided to a Fragment function has been deleted."
  -- *Cause: The given mark had been erased before the call.
  -- *Action: Perform a mark reset and check the application for consistency.

  securefile_outofbounds EXCEPTION;
    PRAGMA EXCEPTION_INIT(securefile_outofbounds, -43883);
    securefile_outofbounds_num NUMBER := 43883;
  -- *Mesg: "%s failed - Attempted to perform a Fragment operation past LOB end"
  -- *Cause: The given offset was past the end of the LOB.
  -- *Action: Make sure the offsets given are valid at the time of the call.
  
  contenttype_toolong EXCEPTION;
    PRAGMA EXCEPTION_INIT(contenttype_toolong, -43859);
    contenttype_toolong_num NUMBER := 43859;
  -- *Mesg: "CONTENTTYPE string too long"
  -- *Cause: Length of CONTENTTYPE string exceeds defined maximum
  -- *Action: Modify length of CONTENTTYPE string and retry operation
  
  contenttypebuf_wrong EXCEPTION;
    PRAGMA EXCEPTION_INIT(contenttypebuf_wrong, -43862);
    contenttypebuf_wrong_num NUMBER := 43862;
  -- *Mesg: "CONTENTTYPE buffer length incorrect"
  -- *Cause: Length of CONTENTTYPE buffer less than defined constant.
  -- *Action: Modify length of CONTENTTYPE buffer and retry operation

  ---------------------------
  -- PROCEDURES AND FUNCTIONS
  --
  PROCEDURE append(dest_lob IN OUT NOCOPY BLOB,
                   src_lob  IN            BLOB);

  PROCEDURE append(dest_lob IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
                   src_lob  IN            CLOB CHARACTER SET dest_lob%CHARSET);

  FUNCTION compare(lob_1    IN BLOB,
                   lob_2    IN BLOB,
                   amount   IN INTEGER := 18446744073709551615,
                   offset_1 IN INTEGER := 1,
                   offset_2 IN INTEGER := 1)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(compare, WNDS, RNDS, WNPS, RNPS);

  PROCEDURE close(lob_loc IN OUT NOCOPY BLOB);

  PROCEDURE close(lob_loc IN OUT NOCOPY CLOB CHARACTER SET ANY_CS);

$if utl_ident.is_oracle_server $then
  PROCEDURE close(file_loc IN OUT NOCOPY BFILE);
$else
  /* BFILE overloads are not supported */
$end

  FUNCTION compare(lob_1    IN CLOB CHARACTER SET ANY_CS,
                   lob_2    IN CLOB CHARACTER SET lob_1%CHARSET,
                   amount   IN INTEGER := 18446744073709551615,
                   offset_1 IN INTEGER := 1, 
                   offset_2 IN INTEGER := 1)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(compare, WNDS, RNDS, WNPS, RNPS);

$if utl_ident.is_oracle_server $then
  FUNCTION compare(file_1   IN BFILE,
                   file_2   IN BFILE,
                   amount   IN INTEGER,
                   offset_1 IN INTEGER := 1,
                   offset_2 IN INTEGER := 1)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(compare, WNDS, RNDS, WNPS, RNPS);
$else
  /* BFILE overloads are not supported */
$end

  PROCEDURE copy(dest_lob    IN OUT NOCOPY BLOB,
                 src_lob     IN            BLOB,
                 amount      IN            INTEGER,
                 dest_offset IN            INTEGER := 1, 
                 src_offset  IN            INTEGER := 1);

  PROCEDURE copy(dest_lob    IN OUT NOCOPY  CLOB CHARACTER SET ANY_CS,
                 src_lob     IN            CLOB CHARACTER SET dest_lob%CHARSET,
                 amount      IN            INTEGER,
                 dest_offset IN            INTEGER := 1, 
                 src_offset  IN            INTEGER := 1);

  PROCEDURE createtemporary(lob_loc IN OUT NOCOPY  BLOB,
                            cache   IN            BOOLEAN,
                            dur     IN            PLS_INTEGER := 10);
  
  PROCEDURE createtemporary(lob_loc IN OUT NOCOPY  CLOB CHARACTER SET ANY_CS,
                            cache   IN            BOOLEAN,
                            dur     IN            PLS_INTEGER := 10);
  
  PROCEDURE erase(lob_loc IN OUT NOCOPY  BLOB,
                  amount  IN OUT NOCOPY  INTEGER,
                  offset  IN      INTEGER := 1);

  PROCEDURE erase(lob_loc IN OUT NOCOPY  CLOB CHARACTER SET ANY_CS,
                  amount  IN OUT NOCOPY  INTEGER,
                  offset  IN            INTEGER := 1);

$if utl_ident.is_oracle_server $then
  PROCEDURE fileclose(file_loc IN OUT NOCOPY  BFILE);

  PROCEDURE filecloseall;

  FUNCTION fileexists(file_loc IN BFILE)
    RETURN INTEGER;
    PRAGMA RESTRICT_REFERENCES(fileexists, WNDS, RNDS, WNPS, RNPS);

  PROCEDURE filegetname(file_loc  IN  BFILE,
                        dir_alias OUT VARCHAR2,
                        filename  OUT VARCHAR2);

  FUNCTION fileisopen(file_loc IN BFILE)
    RETURN INTEGER;
    PRAGMA RESTRICT_REFERENCES(fileisopen, WNDS, RNDS, WNPS, RNPS);

  PROCEDURE fileopen(file_loc  IN OUT NOCOPY  BFILE,
                     open_mode IN      BINARY_INTEGER := file_readonly);
$else
  /* BFILE overloads are not supported */
$end
  
  PROCEDURE freetemporary(lob_loc IN OUT NOCOPY  BLOB);

  PROCEDURE freetemporary(lob_loc IN OUT NOCOPY  CLOB CHARACTER SET ANY_CS);

  FUNCTION getchunksize(lob_loc IN BLOB)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(getchunksize, WNDS, RNDS, WNPS, RNPS);

  FUNCTION getchunksize(lob_loc IN CLOB CHARACTER SET ANY_CS)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(getchunksize, WNDS, RNDS, WNPS, RNPS);

  FUNCTION getlength(lob_loc IN BLOB)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(getlength, WNDS, RNDS, WNPS, RNPS);

  FUNCTION getlength(lob_loc IN CLOB CHARACTER SET ANY_CS)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(getlength, WNDS, RNDS, WNPS, RNPS);

$if utl_ident.is_oracle_server $then
  FUNCTION getlength(file_loc IN BFILE)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(getlength, WNDS, RNDS, WNPS, RNPS);
$else
  /* BFILE overloads are not supported */
$end

  FUNCTION get_storage_limit(lob_loc IN CLOB CHARACTER SET ANY_CS)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(get_storage_limit, WNDS, RNDS, WNPS, RNPS);

  FUNCTION get_storage_limit(lob_loc IN BLOB)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(get_storage_limit, WNDS, RNDS, WNPS, RNPS);

  FUNCTION  istemporary(lob_loc IN BLOB)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(istemporary, WNDS, RNDS, WNPS, RNPS);
 
  FUNCTION istemporary(lob_loc IN CLOB CHARACTER SET ANY_CS)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(istemporary, WNDS, RNDS, WNPS, RNPS);

  function isopen(lob_loc in blob)
    RETURN INTEGER;
    PRAGMA RESTRICT_REFERENCES(isopen, WNDS, RNDS, WNPS, RNPS);

  function isopen(lob_loc in clob character set any_cs)
    RETURN INTEGER;
    PRAGMA RESTRICT_REFERENCES(isopen, WNDS, RNDS, WNPS, RNPS);

$if utl_ident.is_oracle_server $then
  function isopen(file_loc in bfile)
    RETURN INTEGER;
    PRAGMA RESTRICT_REFERENCES(isopen, WNDS, RNDS, WNPS, RNPS);


  PROCEDURE loadfromfile(dest_lob    IN OUT NOCOPY  BLOB,
                         src_lob     IN            BFILE,
                         amount      IN            INTEGER,
                         dest_offset IN            INTEGER := 1,
                         src_offset  IN            INTEGER := 1);
 
  PROCEDURE loadfromfile(dest_lob    IN OUT NOCOPY  CLOB CHARACTER SET ANY_CS,
                         src_lob     IN            BFILE,
                         amount      IN            INTEGER,
                         dest_offset IN            INTEGER := 1,
                         src_offset  IN            INTEGER := 1);

  PROCEDURE loadblobfromfile(dest_lob    IN OUT NOCOPY  BLOB,
                             src_bfile   IN             BFILE,
                             amount      IN             INTEGER,
                             dest_offset IN OUT         INTEGER,
                             src_offset  IN OUT         INTEGER);
 
  PROCEDURE loadclobfromfile(dest_lob IN OUT NOCOPY  CLOB CHARACTER SET ANY_CS,
                             src_bfile      IN             BFILE,
                             amount         IN             INTEGER,
                             dest_offset    IN OUT         INTEGER,
                             src_offset     IN OUT         INTEGER, 
                             bfile_csid     IN             NUMBER,
                             lang_context   IN OUT         INTEGER,
                             warning        OUT            INTEGER);
$else
  /* BFILE overloads are not supported */
$end

$if utl_ident.is_oracle_server $then
  PROCEDURE convertToClob(dest_lob IN OUT NOCOPY  CLOB CHARACTER SET ANY_CS,
                          src_blob       IN             BLOB,
                          amount         IN             INTEGER,
                          dest_offset    IN OUT         INTEGER,
                          src_offset     IN OUT         INTEGER, 
                          blob_csid      IN             NUMBER,
                          lang_context   IN OUT         INTEGER,
                          warning        OUT            INTEGER);

  PROCEDURE convertToBlob(dest_lob IN OUT NOCOPY  BLOB,
                          src_clob       IN        CLOB CHARACTER SET ANY_CS,
                          amount         IN             INTEGER,
                          dest_offset    IN OUT         INTEGER,
                          src_offset     IN OUT         INTEGER, 
                          blob_csid      IN             NUMBER,
                          lang_context   IN OUT         INTEGER,
                          warning        OUT            INTEGER); 
$else
  /* Conversion features not supported in this environment */
$end

  PROCEDURE open(lob_loc   IN OUT NOCOPY BLOB,
                 open_mode IN     BINARY_INTEGER);

  PROCEDURE open(lob_loc   IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
                 open_mode IN     BINARY_INTEGER);

$if utl_ident.is_oracle_server $then
  PROCEDURE open(file_loc  IN OUT NOCOPY BFILE,
                 open_mode IN     BINARY_INTEGER := file_readonly);
$else
  /* BFILE overloads are not supported */
$end

  FUNCTION instr(lob_loc IN BLOB,
                 pattern IN RAW,
                 offset  IN INTEGER := 1,
                 nth     IN INTEGER := 1)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(instr, WNDS, RNDS, WNPS, RNPS);

  FUNCTION instr(lob_loc IN CLOB     CHARACTER SET ANY_CS,
                 pattern IN VARCHAR2 CHARACTER SET lob_loc%CHARSET,
                 offset  IN INTEGER := 1,
                 nth     IN INTEGER := 1)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(instr, WNDS, RNDS, WNPS, RNPS);

$if utl_ident.is_oracle_server $then
  FUNCTION instr(file_loc IN BFILE,
                 pattern  IN RAW,
                 offset   IN INTEGER := 1,
                 nth      IN INTEGER := 1)
    RETURN INTEGER DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(instr, WNDS, RNDS, WNPS, RNPS);
$else
  /* BFILE overloads are not supported */
$end


  PROCEDURE read(lob_loc IN            BLOB,
                 amount  IN OUT NOCOPY INTEGER,
                 offset  IN            INTEGER,
                 buffer  OUT           RAW);

  PROCEDURE read(lob_loc IN            CLOB     CHARACTER SET ANY_CS,
                 amount  IN OUT NOCOPY INTEGER,
                 offset  IN            INTEGER,
                 buffer  OUT           VARCHAR2 CHARACTER SET lob_loc%CHARSET);

$if utl_ident.is_oracle_server $then
  PROCEDURE read(file_loc IN             BFILE,
                 amount   IN OUT NOCOPY  INTEGER,
                 offset   IN             INTEGER,
                 buffer   OUT            RAW);
$else
  /* BFILE overloads are not supported */
$end

  FUNCTION substr(lob_loc IN BLOB,
                  amount  IN INTEGER := 32767,
                  offset  IN INTEGER := 1)
    RETURN RAW DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(substr, WNDS, RNDS, WNPS, RNPS);

  FUNCTION substr(lob_loc IN CLOB CHARACTER SET ANY_CS,
                  amount  IN INTEGER := 32767,
                  offset  IN INTEGER := 1) 
    RETURN VARCHAR2 CHARACTER SET lob_loc%CHARSET DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(substr, WNDS, RNDS, WNPS, RNPS);

$if utl_ident.is_oracle_server $then
  FUNCTION substr(file_loc IN BFILE,
                  amount   IN INTEGER := 32767,
                  offset   IN INTEGER := 1)
    RETURN RAW DETERMINISTIC;
    PRAGMA RESTRICT_REFERENCES(substr, WNDS, RNDS, WNPS, RNPS);
$else
  /* BFILE overloads are not supported */
$end

  PROCEDURE trim(lob_loc IN OUT NOCOPY  BLOB,
                 newlen  IN            INTEGER);

  PROCEDURE trim(lob_loc IN OUT NOCOPY  CLOB CHARACTER SET ANY_CS,
                 newlen  IN            INTEGER);

  PROCEDURE write(lob_loc IN OUT NOCOPY  BLOB,
                  amount  IN            INTEGER,
                  offset  IN            INTEGER,
                  buffer  IN            RAW);

  PROCEDURE write(lob_loc IN OUT NOCOPY  CLOB     CHARACTER SET ANY_CS,
                  amount  IN           INTEGER,
                  offset  IN           INTEGER,
                  buffer  IN           VARCHAR2 CHARACTER SET lob_loc%CHARSET);

  PROCEDURE writeappend(lob_loc IN OUT NOCOPY  BLOB,
                        amount  IN     INTEGER,
                        buffer  IN     RAW);

  PROCEDURE writeappend(lob_loc IN OUT NOCOPY CLOB     CHARACTER SET ANY_CS,
                        amount  IN            INTEGER,
                        buffer  IN     VARCHAR2 CHARACTER SET lob_loc%CHARSET);

$if utl_ident.is_oracle_server $then
-- fragment update API

  PROCEDURE fragment_insert(
    lob_loc     IN OUT NOCOPY BLOB,
    amount      IN            INTEGER,
    offset      IN            INTEGER,
    buffer      IN            RAW
  );

  PROCEDURE fragment_insert(
    lob_loc     IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
    amount      IN            INTEGER,
    offset      IN            INTEGER,
    buffer      IN            VARCHAR2 CHARACTER SET lob_loc%CHARSET
  );

  PROCEDURE fragment_delete(
    lob_loc     IN OUT NOCOPY BLOB,
    amount      IN            INTEGER,
    offset      IN            INTEGER
  );

  PROCEDURE fragment_delete(
    lob_loc     IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
    amount      IN            INTEGER,
    offset      IN            INTEGER
  );

  PROCEDURE fragment_move(
    lob_loc             IN OUT NOCOPY BLOB,
    amount              IN            INTEGER,
    src_offset          IN            INTEGER,
    dest_offset         IN            INTEGER
  );

  PROCEDURE fragment_move(
    lob_loc             IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
    amount              IN            INTEGER,
    src_offset          IN            INTEGER,
    dest_offset         IN            INTEGER
  );

  PROCEDURE fragment_replace(
    lob_loc             IN OUT NOCOPY BLOB,
    old_amount          IN            INTEGER,
    new_amount          IN            INTEGER,
    offset              IN            INTEGER,
    buffer              IN            RAW
  );

  PROCEDURE fragment_replace(
    lob_loc             IN OUT NOCOPY CLOB      CHARACTER SET ANY_CS,
    old_amount          IN            INTEGER,
    new_amount          IN            INTEGER,
    offset              IN            INTEGER,
    buffer              IN            VARCHAR2 CHARACTER SET lob_loc%CHARSET
  );
$else
  /* fragment operations are not supported */
$end

$if utl_ident.is_oracle_server $then
  FUNCTION getoptions(
    lob_loc             IN     BLOB,
    option_types        IN     PLS_INTEGER
  ) RETURN PLS_INTEGER;
    PRAGMA RESTRICT_REFERENCES(getoptions, WNDS, RNDS, WNPS, RNPS);

  FUNCTION getoptions(
    lob_loc             IN     CLOB CHARACTER SET ANY_CS,
    option_types        IN     PLS_INTEGER
  ) RETURN PLS_INTEGER;
    PRAGMA RESTRICT_REFERENCES(getoptions, WNDS, RNDS, WNPS, RNPS);

  PROCEDURE setoptions(
    lob_loc             IN OUT NOCOPY BLOB,
    option_types        IN            PLS_INTEGER,
    options             IN            PLS_INTEGER
  );

  PROCEDURE setoptions(
    lob_loc             IN OUT NOCOPY CLOB CHARACTER SET ANY_CS,
    option_types        IN            PLS_INTEGER,
    options             IN            PLS_INTEGER
  );
$else
  /* get and  set options feature not supported in this environment */
$end

$if utl_ident.is_oracle_server $then
  PROCEDURE get_deduplicate_regions(
    lob_loc      IN            BLOB,
    region_table IN OUT NOCOPY BLOB_DEDUPLICATE_REGION_TAB
  );

  PROCEDURE get_deduplicate_regions(
    lob_loc      IN            CLOB CHARACTER SET ANY_CS,
    region_table IN OUT NOCOPY CLOB_DEDUPLICATE_REGION_TAB
  );

  FUNCTION issecurefile(
    lob_loc    IN      BLOB
  ) RETURN BOOLEAN;
    PRAGMA RESTRICT_REFERENCES(issecurefile, WNDS, RNDS, WNPS, RNPS);
    
  FUNCTION issecurefile(
    lob_loc    IN      CLOB CHARACTER SET ANY_CS
  ) RETURN BOOLEAN;
    PRAGMA RESTRICT_REFERENCES(issecurefile, WNDS, RNDS, WNPS, RNPS);

-- DBFS Link Functionality
  PROCEDURE copy_from_dbfs_link(
    lob_loc       IN OUT BLOB
  );

  PROCEDURE copy_from_dbfs_link(
    lob_loc       IN OUT CLOB CHARACTER SET ANY_CS
  );
 
  PROCEDURE move_to_dbfs_link(
    lob_loc       IN OUT BLOB,
    storage_path  IN     VARCHAR2,
    flags         IN     BINARY_INTEGER := DBFS_LINK_NOCACHE
  );

  PROCEDURE move_to_dbfs_link(
    lob_loc       IN OUT CLOB CHARACTER SET ANY_CS,
    storage_path  IN     VARCHAR2,
    flags         IN     BINARY_INTEGER := DBFS_LINK_NOCACHE
  );
 
  FUNCTION get_dbfs_link(
    lob_loc      IN     BLOB
  ) RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(get_dbfs_link, WNDS, RNDS, WNPS, RNPS);

  FUNCTION get_dbfs_link(
    lob_loc      IN     CLOB CHARACTER SET ANY_CS
  ) RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(get_dbfs_link, WNDS, RNDS, WNPS, RNPS);

  PROCEDURE set_dbfs_link(
    lob_loc         IN OUT BLOB,
    storage_path    IN     VARCHAR2
  );

  PROCEDURE set_dbfs_link(
    lob_loc         IN OUT CLOB CHARACTER SET ANY_CS,
    storage_path    IN     VARCHAR2
  );

  PROCEDURE copy_dbfs_link(
    dest_lob        IN OUT BLOB,
    src_lob         IN     BLOB,
    options         IN     PLS_INTEGER
  );

  PROCEDURE copy_dbfs_link(
    dest_lob        IN OUT CLOB CHARACTER SET ANY_CS,
    src_lob         IN     CLOB CHARACTER SET ANY_CS,
    options         IN     PLS_INTEGER
  );

  PROCEDURE get_dbfs_link_state(
    lob_loc       IN     BLOB,
    storage_path     OUT VARCHAR2,
    state            OUT PLS_INTEGER,
    cached           OUT BOOLEAN
  );

  PROCEDURE get_dbfs_link_state(
    lob_loc       IN     CLOB CHARACTER SET ANY_CS,
    storage_path     OUT VARCHAR2,
    state            OUT PLS_INTEGER,
    cached           OUT BOOLEAN
  );
  
--  PROCEDURE dbfs_link_purge_cache(
--    lob_loc       IN OUT BLOB
--  );
--  PROCEDURE dbfs_link_purge_cache(
--    lob_loc       IN OUT CLOB CHARACTER SET ANY_CS
--  );

  FUNCTION dbfs_link_generate_path(
    lob_loc       IN     BLOB,
    storage_dir   IN     VARCHAR2
  ) RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(dbfs_link_generate_path,
                               WNDS, RNDS, WNPS, RNPS);

  FUNCTION dbfs_link_generate_path(
    lob_loc       IN     CLOB CHARACTER SET ANY_CS,
    storage_dir   IN     VARCHAR2
  ) RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(dbfs_link_generate_path,
                               WNDS, RNDS, WNPS, RNPS);

    FUNCTION getcontenttype(
    lob_loc             IN     BLOB
  ) RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(getcontenttype, WNDS, RNDS, WNPS, RNPS);

  FUNCTION getcontenttype(
    lob_loc             IN     CLOB      CHARACTER SET ANY_CS
  ) RETURN VARCHAR2;
    PRAGMA RESTRICT_REFERENCES(getcontenttype, WNDS, RNDS, WNPS, RNPS);

  PROCEDURE setcontenttype(
    lob_loc             IN OUT NOCOPY BLOB,
    contenttype            IN VARCHAR2
  );

  PROCEDURE setcontenttype(
    lob_loc             IN OUT NOCOPY CLOB      CHARACTER SET ANY_CS,
    contenttype            IN VARCHAR2
  );
$else
  /* DBFS features not supported in this environment */
$end
    
END dbms_lob;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_lob FOR sys.dbms_lob
/
GRANT EXECUTE ON dbms_lob TO PUBLIC
/
SHOW ERRORS
