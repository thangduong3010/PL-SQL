REM
REM $Header: utlcomp.sql 30-sep-2003.11:08:24 sylin Exp $
REM
REM utlcomp.sql
REM
REM Copyright (c) 2001, 2003, Oracle Corporation.  All rights reserved.  
REM
REM    NAME
REM      utlcomp.sql - PL/SQL Package for COMPRESSION (UTL_COMPRESS)
REM
REM    DESCRIPTION
REM      PL/SQL package to compress and uncompress RAW data strings.
REM
REM    NOTES
REM
REM    1. It is the caller's responsibility to free the temporary lob returned
REM       by the lz* functions with dbms_lob.freetemporary() call.
REM
REM    2. BFILE passed into lz_compress* or lz_uncompress* has to be opened
REM       by dbms_lob.fileopen().
REM
REM    3. Compression is does not always result in smaller output. 
REM       For certain data, the size of compressed output be even 
REM       larger than original data because the input data is already
REM       compressed. 
REM
REM    4. As a corollary of 3, the compression ratio could stay the same 
REM       regardless of the level of quality specified, especially
REM       when the data provided is already compressed.
REM
REM    5. The output of the utl_compress compressed data is compatible with
REM       gzip(with -n option)/gunzip on a single file.
REM
REM    MODIFIED   (MM/DD/YY)
REM    sylin       09/30/03 - Add more notes 
REM    lvbcheng    09/09/03 - Remove second arg from example 
REM    sylin       08/27/03 - Remove ratio from lz_compress
REM    sylin       07/16/03 - Add BLOB piecewise uncompress support
REM    sylin       07/08/03 - Add BFILE support
REM    sylin       06/16/03 - Add BLOB piecewise compress support
REM    sylin       06/12/03 - Add blob overloads
REM    sylin       04/29/03 - BLOB support
REM    sylin       05/08/03 - Change error 29258 to 29297
REM    eehrsam     09/06/02 - eehrsam_new_utl_compress_pkg
REM    eehrsam     12/03/01 - Created
REM
CREATE OR REPLACE PACKAGE utl_compress AS

  /* Define max number of handles for piecewise operations */
  UTLCOMP_MAX_HANDLE   CONSTANT  PLS_INTEGER := 5;

  /*
  ** Exceptions
  */
  invalid_handle       EXCEPTION;
  invalid_argument     EXCEPTION;
  buffer_too_small     EXCEPTION;
  data_error           EXCEPTION;
  stream_error         EXCEPTION;

  invalid_argument_errcode    CONSTANT PLS_INTEGER:= -29261;
  buffer_too_small_errcode    CONSTANT PLS_INTEGER:= -29297;
  data_error_errcode          CONSTANT PLS_INTEGER:= -29294;
  stream_error_errcode        CONSTANT PLS_INTEGER:= -29293;
  invalid_handle_errcode      CONSTANT PLS_INTEGER:= -29299;

  PRAGMA EXCEPTION_INIT(invalid_argument, -29261);
  PRAGMA EXCEPTION_INIT(buffer_too_small, -29297);
  PRAGMA EXCEPTION_INIT(data_error,       -29294);
  PRAGMA EXCEPTION_INIT(stream_error,     -29293);
  PRAGMA EXCEPTION_INIT(invalid_handle,   -29299);

  /*----------------------------------------------------------------*/
  /* LZ_COMPRESS                                                    */
  /*----------------------------------------------------------------*/

  /* LZ_COMPRESS - compress data 
  **
  **   This compression utility uses a basic form of the Lempel-Ziv
  **   compression algorithm.
  **
  ** PARAMETERS
  **    src       - the input data to be compressed
  **    quality   - speed versus efficiency of resulting compressed output.  
  **                Valid values are the range 1..9, with a default value of 6.
  **                1=fastest compression, 9=slowest compression and best
  **                compressed file size.
  **
  ** RETURN
  **    the compressed data
  **
  */

  function lz_compress(src     in  raw,
                       quality in  binary_integer default 6) return raw;
                       
  /* This lz_compress overload will return a temporary BLOB for the
   * compressed data.
   */ 
  function lz_compress(src     in  blob,
                       quality in  binary_integer default 6) return blob;
                       
  /* This lz_compress overload will return the compressed data into the
   * existing BLOB, dst.  Original data will be overwritten.
   */ 
  procedure lz_compress(src     in  blob,
                        dst     in out nocopy blob,
                        quality in  binary_integer default 6);
                       
 
  /* This lz_compress overload will return a temporary BLOB for the
   * compressed data.
   */
  function lz_compress(src     in  bfile,
                       quality in  binary_integer default 6) return blob;

  /* This lz_compress overload will return the compressed data into the
   * existing BLOB, dst.  Original data will be overwritten.
   */
  procedure lz_compress(src     in  bfile,
                        dst     in out nocopy blob,
                        quality in  binary_integer default 6);

  /*----------------------------------------------------------------*/
  /* LZ_UNCOMPRESS                                                  */
  /*----------------------------------------------------------------*/

  /* LZ_UNCOMPRESS - uncompress data
  **
  **   This compression utility uses a basic form of the Lempel-Ziv
  **   compression algorithm.
  **
  ** PARAMETERS
  **    src         - the input compressed data
  **
  ** RETURN
  **    the uncompressed data
  **
  */

  function lz_uncompress(src in raw) return raw;

  /* This lz_uncompress overload will return a temporary BLOB for the
   * uncompressed data.
   */
  function lz_uncompress(src in blob) return blob;

  /* This lz_uncompress overload will return the uncompressed data into the
   * existing BLOB, dst.  Original dst data will be overwritten.
   */
  procedure lz_uncompress(src in blob, dst in out nocopy blob);


  /* This lz_uncompress overload will return a temporary BLOB for the
   * uncompressed data.
   */
  function lz_uncompress(src in bfile) return blob;

  /* This lz_uncompress overload will return the uncompressed data into the
   * existing BLOB, dst.  Original dst data will be overwritten.
   */
  procedure lz_uncompress(src in bfile, dst in out nocopy blob);



  /* PIECEWISE COMPRESS */

  /*
  ** lz_compress_open - Initialize a piecewise context that maintains the
  **                    compress state and data.
  **
  ** PARAMETERS
  **    dst       - user supplied LOB to store compressed data.
  **    quality   - speed versus efficiency of resulting compressed output.
  **                Valid values are the range 1..9, with a default value of 6.
  **                1=fastest compression, 9=slowest compression and best
  **                compressed file size.
  **   
  ** RETURN
  **    A handle to an initialized piecewise compress context.
  **
  ** EXCEPTIONS
  **   invalid_handle     - invalid handle, too many open handles.
  **   invalid_argument   - NULL dst or invalid quality specified.
  **
  ** NOTES
  **   Make sure to close the opened handle with lz_compress_close once
  **   the piecewise compress is done and in the event of an exception in
  **   the middle of process, since lack of doing so will cause these
  **   handles to leak.
  **
  */
  function lz_compress_open(dst     in out nocopy blob,
                            quality in binary_integer default 6)
    return binary_integer;


  /*
  ** lz_compress_add - add a piece of compressed data.
  **
  ** PARAMETERS
  **    handle    - handle to a piecewise compress context.
  **    dst       - opened LOB from lz_compress_open to store compressed data.
  **    src       - input data to be compressed.
  **
  ** EXCEPTIONS
  **   invalid_handle     - out of range invalid or unopened handle
  **   invalid_argument   - NULL handle, src, dst, or invalid dst.
  **
  */
  procedure lz_compress_add(handle in binary_integer,
                            dst    in out nocopy blob,
                            src    in raw);

  /*
  ** lz_compress_close - close and finish piecewise compress.
  **
  ** PARAMETERS
  **    handle  - handle to a piecewise compress context.
  **    dst     - opened LOB from lz_compress_open to store compressed data.
  **    
  ** EXCEPTIONS
  **   invalid_handle     - out of range invalid or uninitialized handle.
  **   invalid_argument   - NULL handle, dst, or invalid dst.
  **
  */
  procedure lz_compress_close(handle in binary_integer,
                              dst    in out nocopy blob);

  /* PIECEWISE Uncompress */

  /*
  ** lz_uncompress_open - Initialize a piecewise context that maintains the
  **                      uncompress state and data.
  **
  ** PARAMETERS
  **    src            - input data to be uncompressed.
  **
  ** RETURN
  **    A handle to an initialized piecewise uncompress context.
  **
  ** EXCEPTIONS
  **   invalid_handle     - invalid handle, too many open handles.
  **   invalid_argument   - NULL src.
  **
  ** NOTES
  **   Make sure to close the opened handle with lz_uncompress_close once
  **   the piecewise uncompress is done and in the event of an exception in
  **   the middle of process, since lack of doing so will cause these
  **   handles to leak.
  **
  */
  function lz_uncompress_open(src in blob) return binary_integer;

  /*
  ** lz_uncompress_extract - extract a piece of uncompressed data.
  **
  ** PARAMETERS
  **    handle    - handle to a piecewise uncompress context.
  **    dst       - uncompressed data.
  **
  ** EXCEPTIONS
  **   no_data_found      - finished uncompress.
  **   invalid_handle     - out of range invalid or uninitialized handle.
  **   invalid_argument   - NULL handle.
  */
  procedure lz_uncompress_extract(handle in binary_integer,
                                  dst    out nocopy raw);


  /*
  ** lz_uncompress_close - close and finish piecewise uncompress.
  **
  ** PARAMETERS
  **    handle    - handle to a piecewise uncompress context.
  **
  ** EXCEPTIONS
  **   invalid_handle     - out of range invalid or uninitialized handle.
  **   invalid_argument   - NULL handle.
  **
  */
  procedure lz_uncompress_close(handle in binary_integer);

  /*
  ** isopen - Checks to see if the handle to a piecewise (un)compress context
  **          was opened or closed.
  **
  ** PARAMETERS
  **    handle    - handle to a piecewise (un)compress context.
  **
  ** RETURN
  **    TRUE, if the given piecewise handle is opened, otherwise FALSE.
  **
  ** Example
  **   if (utl_compress.isopen(myhandle) = TRUE) then
  **     utl_compress.lz_compress_close(myhandle, lob_1);
  **   end if;
  **
  ** or
  **
  **   if (utl_compress.isopen(myhandle) = TRUE) then
  **     utl_compress.lz_uncompress_close(myhandle);
  **   end if;
  ** 
  */
  function isopen(handle in binary_integer) return boolean;

END;
/
GRANT EXECUTE ON utl_compress TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_compress FOR sys.utl_compress;


