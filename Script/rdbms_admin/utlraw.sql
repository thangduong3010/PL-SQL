rem 
rem $Header: utlraw.sql 15-jan-2003.18:08:30 mxyang Exp $ 
rem 
Rem Copyright (c) 1993, 2003, Oracle Corporation.  All rights reserved.  
Rem    NAME
Rem      utlraw.sql - PL/SQL Package of utility routines for raw datatypes
Rem                   Package spec of UTL_RAW
Rem
Rem    DESCRIPTION
Rem      Routines to manipulate raws.
Rem
Rem    RETURNS
Rem
Rem    NOTES
Rem      The procedural option is needed to use this facility.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     mxyang     01/15/03  - lfp coerce -0 to 0, NaN to canonical NaN
Rem     mxyang     11/01/02  - fix typos in comments
Rem     mxyang     08/08/02  - Add cast_to/from_binary_float,
Rem                             cast_to/from_binary_double
Rem     eehrsam    12/12/01  - Add machine_endian 
Rem     eehrsam    10/17/00 -  Add cast_to/from_number,
Rem                             cast_to/from_binary_integer
Rem     dbronnik   07/30/99 -  897373: add nchar support
Rem     rdasarat   10/04/96 -  Forward merge 377621
Rem     rhari      02/21/95 -  bug 257630 : assert purity of functions
Rem     rhari      10/29/94 -  merge changes from branch 1.1.720.1
Rem     rhari      10/27/94 -  merges from 7.1
Rem     rhari      09/28/94 -  Creation
Rem     cddavis    09/22/94 -  clarified all utl_raw function doc
Rem                            added defaults and error results.
Rem     cddavis    07/11/94 -  reversed CONVERT parameters
Rem     cddavis    06/27/94 -  split functions out into utl_pg package:
Rem                               RAW_TO_NUMBER
Rem                               NUMBER_TO_RAW
Rem                               RAW_TO_NUMBER_FORMAT
Rem                               NUMBER_TO_RAW_FORMAT
Rem                               MAKE_RAW_TO_NUMBER_FORMAT
Rem                               MAKE_NUMBER_TO_RAW_FORMAT
Rem                               WMSG
Rem                               WMSGCNT
Rem     cddavis    05/11/94 -  refined documentation of warning functions
Rem                         -  changed spool out to 'off'
Rem     png        04/15/94 -  added warning parms to n2r/r2n functions
Rem                         -  added wmsg and wmsgcnt functions
Rem     cddavis    01/26/94 -  corrected transliterate description
Rem     cddavis    01/06/94 -  combined spec & body into single package
Rem     cddavis    09/21/93 -  added nlslang to formatted r/n functions
Rem     cddavis    08/26/93 -  raw conversion formats
Rem     mmoore     08/12/93 -  Branch_for_the_patch
Rem   rkooi/mmoore 07/25/93 -  Creation
 
REM ********************************************************************
REM THE FUNCTIONS SUPPLIED BY THIS PACKAGE AND ITS EXTERNAL INTERFACE
REM ARE RESERVED BY ORACLE AND ARE SUBJECT TO CHANGE IN FUTURE RELEASES.
REM ********************************************************************
 
REM ********************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO
REM THIS PACKAGE MUST NOT BE    rhari      02/21/95 - bug 257630 : assert purit
REM COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
REM RDBMS.  SPECIFICALLY, THE PSD* ROUTINES MUST NOT BE CALLED
REM DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
REM ********************************************************************
 
CREATE OR REPLACE PACKAGE utl_raw IS
 
  ------------
  --  OVERVIEW
  --
  --     This package provides SQL functions for raws that concat,
  --     substr, etc. to/from raws.  This package is necessary
  --     because normal SQL functions do not operate on raws and
  --     PL/SQL does not allow overloading between a raw and a char
  --     datatype.  Also included are routines which convert various
  --     COBOL number formats to/from raws.
 
  --     UTL_RAW is not specific to the database environment and may
  --     actually be used in other environments as it exists here.
  --     For this reason, the prefix UTL has been given to the package
  --     instead of DBMS.
 
  -------
  -- USES
  --
  --     The are many possible uses for the raw functions.  The
  --     functionality allows a raw "record" to be composed
  --     of many elements.  By using the raw datatype, character
  --     set conversion will not be performed keeping the raw in
  --     its original format when being transferred via rpc.
  --     The raw functions also give the ability to manipulate
  --     binary data which was previously limited to the hextoraw
  --     and rawtohex functions.
 
  -------------
  --  CONSTANTS
  --
  -- Define constants to control endianess behavior, used by 
  -- cast_to_binary_integer and cast_from_binary_integer
  big_endian         CONSTANT PLS_INTEGER := 1;
  little_endian      CONSTANT PLS_INTEGER := 2;
  machine_endian     CONSTANT PLS_INTEGER := 3; 

  ---------------------------
  -- PROCEDURES AND FUNCTIONS
 
  /*----------------------------------------------------------------*/
  /*  CONCAT                                                        */
  /*----------------------------------------------------------------*/
  FUNCTION concat(r1  IN RAW DEFAULT NULL,
                  r2  IN RAW DEFAULT NULL,
                  r3  IN RAW DEFAULT NULL,
                  r4  IN RAW DEFAULT NULL,
                  r5  IN RAW DEFAULT NULL,
                  r6  IN RAW DEFAULT NULL,
                  r7  IN RAW DEFAULT NULL,
                  r8  IN RAW DEFAULT NULL,
                  r9  IN RAW DEFAULT NULL,
                  r10 IN RAW DEFAULT NULL,
                  r11 IN RAW DEFAULT NULL,
                  r12 IN RAW DEFAULT NULL) RETURN RAW;
    pragma RESTRICT_REFERENCES(concat, WNDS, RNDS, WNPS, RNPS); 

  --  Concatenate a set of 12 raws into a single raw.  If the
  --    concatenated size exceeds 32K, an error is returned.
 
  --  Input parameters:
  --    r1....r12 are the raw items to concatenate.
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    raw - containing the items concatenated.
 
  --  Errors:
  --    VALUE_ERROR exception raised (to be revised in a future release)
  --        If the sum of the lengths of the inputs exceeds the maximum
  --        allowable length for a RAW.
 
  /*----------------------------------------------------------------*/
  /*  CAST_TO_RAW                                                   */
  /*----------------------------------------------------------------*/
  FUNCTION cast_to_raw(c IN VARCHAR2 CHARACTER SET ANY_CS) RETURN RAW;
    pragma RESTRICT_REFERENCES(cast_to_raw, WNDS, RNDS, WNPS, RNPS); 

  --  Cast a varchar2 to a raw
  --    This function converts a varchar2 represented using N data bytes
  --    into a raw with N data bytes.
  --    The data is not modified in any way, only its datatype is recast
  --    to a RAW datatype.
 
  --  Input parameters:
  --    c - varchar2 or nvarchar2 to be changed to a raw
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    raw - containing the same data as the input varchar2 and
  --          equal byte length as the input varchar2 and without a
  --          leading length field.
  --    null - if c input parameter was null
 
  --  Errors:
  --     None
 
  /*----------------------------------------------------------------*/
  /*  CAST_TO_VARCHAR2                                              */
  /*----------------------------------------------------------------*/
  FUNCTION cast_to_varchar2(r IN RAW) RETURN VARCHAR2;
    pragma RESTRICT_REFERENCES(cast_to_varchar2, WNDS, RNDS, WNPS, RNPS); 

  --  Cast a raw to a varchar2
  --    This function converts a raw represented using N data bytes
  --    into varchar2 with N data bytes.
  --    NOTE: Once the value is cast to a varchar2, string 
  --          operations or server->client communication will assume 
  --          that the string is represented using the database's 
  --          character set.  "Garbage" results are likely if these 
  --          operations are applied to a string that is actually 
  --          represented using some other character set.
 
  --  Input parameters:
  --    r - raw (without leading length field) to be changed to a
  --             varchar2)
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    varchar2 - containing having the same data as the input raw
  --    null     - if r input parameter was null
 
  --  Errors:
  --     None

  /*----------------------------------------------------------------*/
  /*  CAST_TO_NVARCHAR2                                             */
  /*----------------------------------------------------------------*/
  FUNCTION cast_to_nvarchar2(r IN RAW) RETURN NVARCHAR2;
    pragma RESTRICT_REFERENCES(cast_to_nvarchar2, WNDS, RNDS, WNPS, RNPS); 

  --  Cast a raw to a nvarchar2
  --    This function converts a raw represented using N data bytes
  --    into nvarchar2 with N data bytes.
  --    NOTE: Once the value is cast to a nvarchar2, string
  --          operations or server->client communication will assume
  --          that the string is represented using the database's
  --          NCHAR character set.  "Garbage" results are likely if these
  --          operations are applied to a string that is actually
  --          represented using some other character set.
 
  --  Input parameters:
  --    r - raw (without leading length field) to be changed to a
  --             nvarchar2)
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    nvarchar2 - containing having the same data as the input raw
  --    null      - if r input parameter was null
 
  --  Errors:
  --     None
 
  /*----------------------------------------------------------------*/
  /*  LENGTH                                                        */
  /*----------------------------------------------------------------*/
  FUNCTION length(r IN RAW) RETURN NUMBER;
    pragma RESTRICT_REFERENCES(length, WNDS, RNDS, WNPS, RNPS); 

  --  Return the length in bytes of a raw r.
 
  --  Input parameters:
  --    r - the raw byte stream to be measured
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    number - equal to the current length of the raw.
 
  --  Errors:
  --     None
 
  /*----------------------------------------------------------------*/
  /*  SUBSTR                                                        */
  /*----------------------------------------------------------------*/
  FUNCTION substr(r   IN RAW,
                  pos IN BINARY_INTEGER,
                  len IN BINARY_INTEGER DEFAULT NULL) RETURN RAW;
    pragma RESTRICT_REFERENCES(substr, WNDS, RNDS, WNPS, RNPS); 

  --  Return a substring portion of raw r beginning at pos for len bytes.
  --    If pos is positive, substr counts from the beginning of r to find
  --    the first byte.  If pos is negative, substr counts backwards from the
  --    end of the r.  The value pos cannot be 0.  If len is omitted,
  --    substr returns all bytes to the end of r.  The value len cannot be
  --    less than 1.
 
  --  Input parameters:
  --    r    - the raw byte-string from which a portion is extracted.
  --    pos  - the byte pisition in r at which to begin extraction.
  --    len  - the number of bytes from pos to extract from r (optional).
 
  --  Defaults and optional parameters:
  --    len - position pos thru to the end of r
 
  --  Return value:
  --    Portion of r beginning at pos for len bytes long
  --    null - if r input parameter was null
 
  --  Errors:
  --    VALUE_ERROR exception raised (to be revised in a future release)
  --       when pos = 0
  --       when len < 0
 
  /*----------------------------------------------------------------*/
  /*  TRANSLATE                                                     */
  /*----------------------------------------------------------------*/
  FUNCTION translate(r        IN RAW,
                     from_set IN RAW,
                     to_set   IN RAW) RETURN RAW;
    pragma RESTRICT_REFERENCES(translate, WNDS, RNDS, WNPS, RNPS); 

  --  Translate the bytes in the input r raw according to the bytes
  --    in the translation raws, from_set and to_set.  If a byte
  --    in r has a matching byte in from_set, then it is replaced by the
  --    byte in the corresponding position in to_set, or deleted.
  --    Bytes in r but undefined in from_set are copied to the result.
  --    Only the first (leftmost) occurrence of a byte in from_set is
  --    used, subsequent duplicates are not scanned and are ignored.
  --    If to_set is shorter than from_set, the extra from_set bytes
  --    have no translation correspondence and any bytes in r matching
  --    such uncorresponded bytes are deleted from the result raw.
 
  --    Noted difference from TRANSLITERATE:
  --       translation raws have no defaults.
  --       r bytes undefined in the to_set translation raw are deleted.
  --       result raw may be shorter than input r raw.
 
  --  Input parameters:
  --    r        - raw source byte-string to be translated
  --    from_set - raw byte-codes to be translated, if present in r
  --    to_set   - raw byte-codes to which corresponding from_str bytes
  --               are translated
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    raw  - translated byte-string
 
  --  Errors:
  --    VALUE_ERROR exception raised (to be revised in a future release)
  --       when r        is null and/or has 0 length
  --       when from_set is null and/or has 0 length
  --       when to_set   is null and/or has 0 length
 
  /*----------------------------------------------------------------*/
  /*  TRANSLITERATE                                                 */
  /*----------------------------------------------------------------*/
  FUNCTION transliterate(r        IN RAW,
                         to_set   IN RAW DEFAULT NULL,
                         from_set IN RAW DEFAULT NULL,
                         pad      IN RAW DEFAULT NULL) RETURN RAW;
    pragma RESTRICT_REFERENCES(transliterate, WNDS, RNDS, WNPS, RNPS); 
 
  --  Transliterate the bytes in the input r raw according to the bytes
  --    in the transliteration raws, from_set and to_set.
  --    Successive bytes in r are looked-up in the from_set and, if not
  --    found, copied unaltered to the result raw, or if found, replaced
  --    in the result raw by either corresponding bytes in the to_set or
  --    the pad byte when no correspondence exists.
  --    Bytes in r but undefined in from_set are copied to the result.
  --    Only the first (leftmost) occurrence of a byte in from_set is
  --    used, subsequent duplicates are not scanned and are ignored.
  --    The result raw is always the same length as r.
  --    from_set and to_set may be of any length.
  --    If the to_set is shorter than the from_set, then the pad byte is
  --    placed in the result raw when a selected from_set byte has no
  --    corresponding to_set byte (as if the to_set were extended to the
  --    same length as the from_set with pad bytes).
 
  --    Noted difference from TRANSLATE:
  --       r bytes undefined in to_set are padded.
  --       result raw is always same length as input r raw.
 
  --  Input parameters:
  --    r        - raw input byte-string to be transliterated
  --    from_set - raw byte-codes to be translated ,if present in r
  --    to_set   - raw byte-codes to which corresponding from_set bytes
  --               are translated
  --    pad      - 1 byte used when to-set is shorter than the from_set
 
  --  Defaults and optional parameters:
  --    from_set - x'00 through x'ff.
  --    to_set   - to the null string and effectively extended
  --               with pad to the length of from_set as necessary.
  --    pad      - x'00'.
 
  --  Return value:
  --    raw  - transliterated byte-string
 
  --  Errors:
  --    VALUE_ERROR exception raised (to be revised in a future release)
  --       when r is null and/or has 0 length
 
  /*----------------------------------------------------------------*/
  /*  OVERLAY                                                       */
  /*----------------------------------------------------------------*/
  FUNCTION overlay(overlay_str IN RAW,
                   target      IN RAW,
                   pos         IN BINARY_INTEGER DEFAULT 1,
                   len         IN BINARY_INTEGER DEFAULT NULL,
                   pad         IN RAW            DEFAULT NULL) RETURN RAW;
    pragma RESTRICT_REFERENCES(overlay, WNDS, RNDS, WNPS, RNPS); 
 
  --  Overlay the specified portion of target raw with overlay raw,
  --    starting from byte position pos of target and proceding for len
  --    bytes.
  --    If overlay has less than len bytes, it is extended to len bytes
  --    using the pad byte.  If overlay exceeds len bytes, the extra
  --    bytes in overlay are ignored.
  --    If len bytes beginning at position pos of target exceeds the
  --    length of target, target will be extended to contain the entire
  --    length of overlay.
  --    len, if specified, must be => 0.
  --    pos, if specified, must be => 1.
  --    If pos exceeeds the length of target, target will be padded with
  --    pad bytes to position pos, and then target is further extended
  --    with overlay bytes.
 
  --  Input parameters:
  --    overlay_str - byte-string used to overlay target
  --    target  - byte-string which is to be overlayed
  --    pos     - position in target (numbered from 1) to start overlay
  --    len     - the number of target bytes to overlay
  --    pad     - pad byte used when overlay len exceeds overlay length
  --              or pos exceeds target length.
 
  --  Defaults and optional parameters:
  --    pos     - 1.
  --    len     - to the length of overlay.
  --    pad     - x'00'.
 
  --  Return value:
  --    raw  - The target byte_string overlayed as specified
 
  --  Errors:
  --    VALUE_ERROR exception raised (to be revised in a future release)
  --       when overlay is null and/or has 0 length
  --       when target  is missing or undefined
  --       when length of target exceeds maximum length of a raw
  --       when len < 0
  --       when pos < 1
 
  /*----------------------------------------------------------------*/
  /*  COPIES                                                        */
  /*----------------------------------------------------------------*/
  FUNCTION copies(r IN RAW,
                  n IN NUMBER) RETURN RAW;
    pragma RESTRICT_REFERENCES(copies, WNDS, RNDS, WNPS, RNPS); 

  --  Return n copies of r concatenated together.
 
  --  Input parameters:
  --    r - raw to be copied
  --    n - number of times to copy the raw (must be positive)
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    The raw copied n times.
 
  --  Errors:
  --    VALUE_ERROR exception raised (to be revised in a future release)
  --       r is missing, null and/or 0 length
  --       n < 1
  --       when length of result exceeds maximum length of a raw
 
  /*----------------------------------------------------------------*/
  /*  XRANGE                                                        */
  /*----------------------------------------------------------------*/
  FUNCTION xrange(start_byte IN RAW DEFAULT NULL,
                  end_byte   IN RAW DEFAULT NULL) RETURN RAW;
    pragma RESTRICT_REFERENCES(xrange, WNDS, RNDS, WNPS, RNPS); 

  --  Returns a raw containing all valid 1-byte encodings in succession
  --    beginning with the value start_byte and ending with the value
  --    end_byte.
  --    If start_byte is greater than end_byte, the succession of
  --    result bytes begin with start_byte, wrap thru 'FF'x to '00'x,
  --    and end at end_byte.
  --    If specified, start_byte and end_byte must be single byte raws.
 
  --  Input parameters:
  --    start_byte - beginning byte-code value of resulting sequence
  --    end_byte   - ending    byte-code value of resulting sequence
 
  --  Defaults and optional parameters:
  --    start_byte - x'00'
  --    end_byte   - x'FF'
 
  --  Return value:
  --    raw - containing succession of 1-byte hexadecimal encodings
 
  --  Errors:
  --     None
 
  /*----------------------------------------------------------------*/
  /*  REVERSE                                                       */
  /*----------------------------------------------------------------*/
  FUNCTION reverse(r IN RAW) RETURN RAW;
    pragma RESTRICT_REFERENCES(reverse, WNDS, RNDS, WNPS, RNPS); 

  --  Reverse a byte sequence in raw r from end to end.
  --    For example, x'0102F3' would be reversed into x'F30201' and
  --    'xyz' would be reversed into 'zyx'.
  --    The result length is the same as the input raw length.
 
  --  Input parameters:
  --    r - raw to reverse
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    raw - containing the "reverse" of r
 
  --  Errors:
  --    VALUE_ERROR exception raised (to be revised in a future release)
  --       when r is null and/or has 0 length
 
  /*----------------------------------------------------------------*/
  /*  COMPARE                                                       */
  /*----------------------------------------------------------------*/
  FUNCTION compare(r1  IN RAW,
                   r2  IN RAW,
                   pad IN RAW DEFAULT NULL)  RETURN NUMBER;
    pragma RESTRICT_REFERENCES(compare, WNDS, RNDS, WNPS, RNPS); 

  --  Compares raw r1 against raw r2.  Returns 0 if r1 and r2 are
  --    identical, otherwise, returns the position of the first byte
  --    from r1 that does not match r2.
  --    If r1 and r2 differ in length, the shorter raw is extended on
  --    the right with pad if necessary.
  --    right with pad if necessary.  The default pad byte is x'00'.
 
  --  Input parameters:
  --    r1  - 1st raw to be compared, may be null and/or 0 length
  --    r2  - 2nd raw to be compared, may be null and/or 0 length
  --    pad - byte to extend whichever of r1 or r2 is shorter
 
  --  Defaults and optional parameters:
  --    pad - x'00'
 
  --  Return value:
  --    number = 0 if raw byte strings are both null or identical; or,
  --           = position (numbered from 1) of first mismatched byte
 
  --  Errors:
  --     None
 
  /*----------------------------------------------------------------*/
  /*  CONVERT                                                       */
  /*----------------------------------------------------------------*/
  FUNCTION convert(r            IN RAW,
                   to_charset   IN VARCHAR2,
                   from_charset IN VARCHAR2) RETURN RAW;
    pragma RESTRICT_REFERENCES(convert, WNDS, RNDS, WNPS, RNPS); 

  --  Convert raw r from character set from_charset to character set
  --    to_charset and return the resulting raw.
  --    Both from_charset and to_charset must be supported character sets
  --    defined to the Oracle server.
 
  --  Input parameters:
  --    r            - raw byte-string to be converted.
  --    to_charset   - name of NLS character set to which r is converted.
  --    from_charset - name of NLS character set in which r is supplied.
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    raw - bytestring r converted according to the specified
  --          character sets.
 
  --  Errors:
  --    VALUE_ERROR exception raised (to be revised in a future release)
  --      r missing, null and/or 0 length
  --      from_charset or to_charset missing, null and/or 0 length
  --      from_charset or to_charset names invalid or unsupported
 
  /*----------------------------------------------------------------*/
  /*  BIT_AND                                                       */
  /*----------------------------------------------------------------*/
  FUNCTION bit_and(r1 IN RAW,
                   r2 IN RAW) RETURN RAW;
    pragma RESTRICT_REFERENCES(bit_and, WNDS, RNDS, WNPS, RNPS); 

  --  Perform bitwise logical "and" of the values in raw r1 with raw r2
  --    and return the "anded" result raw.
  --    If r1 and r2 differ in length, the "and" operation is terminated
  --    after the last byte of the shorter of the two raws, and the
  --    unprocessed portion of the longer raw is appended to the partial
  --    result.
  --    The result length equals the longer of the two input raws.
 
  --  Input parameters:
  --    r1 - raw to "and" with r2
  --    r2 - raw to "and" with r1
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    raw  - containing the "and" of r1 and r2
  --    null - if either r1 or r2 input parameter was null
 
  --  Errors:
  --    None
 
  /*----------------------------------------------------------------*/
  /*  BIT_OR                                                        */
  /*----------------------------------------------------------------*/
  FUNCTION bit_or(r1 IN RAW,
                  r2 IN RAW) RETURN RAW;
    pragma RESTRICT_REFERENCES(bit_or, WNDS, RNDS, WNPS, RNPS); 

  --  Perform bitwise logical "or" of the values in raw r1 with raw r2
  --    and return the "or'd" result raw.
  --    If r1 and r2 differ in length, the "or" operation is terminated
  --    after the last byte of the shorter of the two raws, and the
  --    unprocessed portion of the longer raw is appended to the partial
  --    result.
  --    The result length equals the longer of the two input raws.
 
  --  Input parameters:
  --    r1 - raw to "or" with r2
  --    r2 - raw to "or" with r1
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    raw  - containing the "or" of r1 and r2
  --    null - if either r1 or r2 input parameter was null
 
  --  Errors:
  --    None
 
  /*----------------------------------------------------------------*/
  /*  BIT_XOR                                                       */
  /*----------------------------------------------------------------*/
  FUNCTION bit_xor(r1 IN RAW,
                   r2 IN RAW) RETURN RAW;
    pragma RESTRICT_REFERENCES(bit_xor, WNDS, RNDS, WNPS, RNPS); 

  --  Perform bitwise logical "exclusive or" of the values in raw r1
  --    with raw r2 and return the "xor'd" result raw.
  --    If r1 and r2 differ in length, the "xor" operation is terminated
  --    after the last byte of the shorter of the two raws, and the
  --    unprocessed portion of the longer raw is appended to the partial
  --    result.
  --    The result length equals the longer of the two input raws.
 
  --  Input parameters:
  --    r1 - raw to "xor" with r2
  --    r2 - raw to "xor" with r1
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    raw  - containing the "xor" of r1 and r2
  --    null - if either r1 or r2 input parameter was null
 
  --  Errors:
  --    None
 
  /*----------------------------------------------------------------*/
  /*  BIT_COMPLEMENT                                                */
  /*----------------------------------------------------------------*/
  FUNCTION bit_complement(r IN RAW) RETURN RAW;
    pragma RESTRICT_REFERENCES(bit_complement, WNDS, RNDS, WNPS, RNPS); 

  --  Perform bitwise logical "complement" of the values in raw r
  --    and return the "complement'ed" result raw.
  --    The result length equals the input raw r length.
 
  --  Input parameters:
  --    r - raw to perform "complement" operation.
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    raw - which is the "complement" of r1
  --    null - if r input parameter was null
 
  --  Errors:
  --    None
    
  /*----------------------------------------------------------------*/
  /*  CAST_TO_NUMBER                                                */
  /*----------------------------------------------------------------*/
  FUNCTION cast_to_number(r IN RAW) RETURN NUMBER;
    pragma RESTRICT_REFERENCES(cast_to_number, WNDS, RNDS, WNPS, RNPS); 

  --  Perform a casting of the binary representation of the number (in RAW)
  --  into a NUMBER.
 
  --  Input parameters:
  --    r - RAW value to be cast as a NUMBER
 
  --  Return value:
  --    number
  --    null - if r input parameter was null
 
  --  Errors:
  --    None
    
  /*----------------------------------------------------------------*/
  /*  CAST_FROM_NUMBER                                              */
  /*----------------------------------------------------------------*/
  FUNCTION cast_from_number(n IN NUMBER) RETURN RAW;
    pragma RESTRICT_REFERENCES(cast_from_number, WNDS, RNDS, WNPS, RNPS); 


  --  Returns the binary representation of a NUMBER in RAW.
 
  --  Input parameters:
  --    n - NUMBER to be returned as RAW
 
  --  Return value:
  --    raw
  --    null - if n input parameter was null
 
  --  Errors:
  --    None
    
  /*----------------------------------------------------------------*/
  /*  CAST_TO_BINARY_INTEGER                                        */
  /*----------------------------------------------------------------*/
  FUNCTION cast_to_binary_integer(r IN RAW,
                                  endianess IN PLS_INTEGER
                                     DEFAULT 1)
                                  RETURN BINARY_INTEGER;
    pragma RESTRICT_REFERENCES(cast_to_binary_integer, WNDS, RNDS, WNPS, RNPS); 

  --  Perform a casting of the binary representation of the raw
  --  into a binary integer.  This function will handle PLS_INTEGER as well
  --  as binary integer.
  --  In the 4 byte, 2 byte, and 1 byte integer cases, here is how the
  --  bytes are mapped into a RAW depending on the endianess of the platform:
  --
  --                   4-byte raw    2-byte raw   1-byte raw
  --                     0 1 2 3          0 1           0
  --
  --     Big-endian      0 1 2 3      - - 0 1     - - - 0
  --
  --     Little-endian   3 2 1 0      - - 1 0     - - - 0
  --
  --  Machine-endian refers to the endianess of the database host and
  --  can be either big or little endian.  In this case, the bytes are
  --  copied straight across into the integer value without endianess
  --  handling.
  --
  --  Machine-endian-lze refers to treating the raw as an unsigned 
  --  quantity.  This applies only in the 1,2,3-byte cases, as the 
  --  4-byte case is forced to be signed by our binary_integer datatype.
  --  In the case of a 4-byte input and machine-endian-lze, we will treat
  --  this as a signed 4-byte quantity - the same as machine-endian.
  --
  --  Input parameters:
  --    r - RAW value to be cast to binary integer
  --    endianess - PLS_INTEGER representing endianess.  Valid values are
  --                big_endian,little_endian,machine_endian
  --                Default=big_endian. 
 
  --  Defaults and optional parameters: endianess defaults to big_endian
 
  --  Return value:
  --    binary_integer value
  --    null - if r input parameter was null
 
  --  Errors:
  --    None

  /*----------------------------------------------------------------*/
  /*  CAST_FROM_BINARY_INTEGER                                      */
  /*----------------------------------------------------------------*/
  FUNCTION cast_from_binary_integer(n         IN BINARY_INTEGER,
                                    endianess IN PLS_INTEGER
                                      DEFAULT 1)
                                    RETURN RAW;
    pragma RESTRICT_REFERENCES(cast_from_binary_integer,WNDS,RNDS,WNPS,RNPS); 

  --  Return the RAW representation of a binary_integer value.  This function
  --  will handle PLS_INTEGER as well as binary integer.  The mapping applies
  --  as follows for little and big-endian platforms:
  --
  --                    4-byte int
  --                     0 1 2 3
  --
  --     Big-endian      0 1 2 3
  --
  --     Little-endian   3 2 1 0
  --
 
  --  Input parameters:
  --    n - binary integer to be returned as RAW
  --    endianess - big or little endian PLS_INTEGER constant
 
  --  Defaults and optional parameters: endianess defaults to big_endian
 
  --  Return value:
  --    raw
  --    null - if n input parameter was null
 
  --  Errors:
  --    None

  /*----------------------------------------------------------------*/
  /*  CAST_FROM_BINARY_FLOAT                                        */
  /*----------------------------------------------------------------*/
  FUNCTION cast_from_binary_float(n         IN BINARY_FLOAT,
                                  endianess IN PLS_INTEGER
                                    DEFAULT 1)
                                  RETURN RAW;
    pragma RESTRICT_REFERENCES(cast_from_binary_float,WNDS,RNDS,WNPS,RNPS); 

  --  Return the RAW representation of a binary_float value. 
  --
  --  A 4-byte binary_float value maps to the the IEEE 754 single-precision
  --  format as follows:
  --    byte 0: bit 31 ~ bit 24
  --    byte 1: bit 23 ~ bit 16
  --    byte 2: bit 15 ~ bit  8
  --    byte 3: bit  7 ~ bit  0
  --
  --  The parameter endianess describes how the bytes of binary_float are
  --  mapped to the bytes of raw. In the following table, rb0 ~ rb3 refer
  --  to the bytes in raw and fb0 ~ fb3 refer to the bytes in binary_float.
  --
  --                     rb0   rb1   rb2   rb3
  --                    +----------------------+
  --     big_endian     |fb0 | fb1 | fb2 | fb3 |
  --                    |----------------------|
  --     little_endian  |fb3 | fb2 | fb1 | fb0 |
  --                    +----------------------+
  --
  --  In case of machine-endian, the 4 bytes of the binary_float argument
  --  are copied straight across into the raw return value. The effect is
  --  the same if the user has passed big_endian on a big endian machine,
  --  or little_endian on a little endian machine.
  --
  --  Input parameters:
  --    n - binary_float to be returned as RAW
  --    endianess - big, little or machine endian PLS_INTEGER constant
  -- 
  --  Defaults and optional parameters: endianess defaults to big_endian
  -- 
  --  Return value:
  --    raw
  --    null - if n input parameter was null
  -- 
  --  Errors:
  --    None


  /*----------------------------------------------------------------*/
  /*  CAST_TO_BINARY_FLOAT                                        */
  /*----------------------------------------------------------------*/
  FUNCTION cast_to_binary_float(r IN RAW,
                                endianess IN PLS_INTEGER
                                  DEFAULT 1)
                                RETURN BINARY_FLOAT;
    pragma RESTRICT_REFERENCES(cast_to_binary_float, WNDS, RNDS, WNPS, RNPS); 

  --  Perform a casting of the binary representation of the raw
  --  into a binary_float.
  --
  --  A 4-byte binary_float value maps to the the IEEE 754 single-precision
  --  format as follows:
  --    byte 0: bit 31 ~ bit 24
  --    byte 1: bit 23 ~ bit 16
  --    byte 2: bit 15 ~ bit  8
  --    byte 3: bit  7 ~ bit  0
  --
  --  The parameter endianess describes how the bytes of binary_float are
  --  mapped to the bytes of raw. In the following table, rb0 ~ rb3 refer
  --  to the bytes in raw and fb0 ~ fb3 refer to the bytes in binary_float.
  --
  --                     rb0   rb1   rb2   rb3
  --                    +----------------------+
  --     big_endian     |fb0 | fb1 | fb2 | fb3 |
  --                    |----------------------|
  --     little_endian  |fb3 | fb2 | fb1 | fb0 |
  --                    +----------------------+
  --
  --  In case of machine-endian, the 4 bytes of the raw argument
  --  are copied straight across into the binary_float return value.
  --  The effect is the same if the user has passed big_endian on a
  --  big endian machine, or little_endian on a little endian machine.
  --
  --  Input parameters:
  --    r - RAW value to be cast to binary_float
  --    endianess - big, little or machine endian PLS_INTEGER constant
  -- 
  --  Defaults and optional parameters: endianess defaults to big_endian
  -- 
  --  Note:
  --    If the RAW argument is more than 4 bytes, only the first 4
  --    bytes are used and the rest of the bytes are ignored. If the
  --    result is -0, +0 is returned. If the result is NaN, the value
  --    BINARY_FLOAT_NAN is returned.
  -- 
  --  Return value:
  --    binary_float value
  --    null - if r input parameter was null
  -- 
  --  Errors:
  --    If the RAW argument is less than 4 bytes, VALUE_ERROR exception
  --    is raised (to be revised in a future release).

  /*----------------------------------------------------------------*/
  /*  CAST_FROM_BINARY_DOUBLE                                        */
  /*----------------------------------------------------------------*/
  FUNCTION cast_from_binary_double(n         IN BINARY_DOUBLE,
                                   endianess IN PLS_INTEGER
                                     DEFAULT 1)
                                   RETURN RAW;
    pragma RESTRICT_REFERENCES(cast_from_binary_double,WNDS,RNDS,WNPS,RNPS); 

  --  Return the RAW representation of a binary_double value. 
  --
  --  An 8-byte binary_double value maps to the the IEEE 754 double-precision
  --  format as follows:
  --    byte 0: bit 63 ~ bit 56
  --    byte 1: bit 55 ~ bit 48
  --    byte 2: bit 47 ~ bit 40
  --    byte 3: bit 39 ~ bit 32
  --    byte 4: bit 31 ~ bit 24
  --    byte 5: bit 23 ~ bit 16
  --    byte 6: bit 15 ~ bit  8
  --    byte 7: bit  7 ~ bit  0
  --
  --  The parameter endianess describes how the bytes of binary_double are
  --  mapped to the bytes of raw. In the following table, rb0 ~ rb7 refer
  --  to the bytes in raw and db0 ~ db7 refer to the bytes in binary_double.
  --
  --                   rb0   rb1   rb2   rb3   rb4   rb5   rb6   rb7
  --                  +----------------------------------------------+
  --   big_endian     |db0 | db1 | db2 | db3 | db4 | db5 | db6 | db7 |
  --                  |----------------------------------------------|
  --   little_endian  |db7 | db6 | db5 | db4 | db3 | db2 | db1 | db0 |
  --                  +----------------------------------------------+
  --
  --  In case of machine-endian, the 8 bytes of the binary_double argument
  --  are copied straight across into the raw return value. The effect is
  --  the same if the user has passed big_endian on a big endian machine,
  --  or little_endian on a little endian machine.
  --
  --  Input parameters:
  --    n - binary_double to be returned as RAW
  --    endianess - big, little or machine endian PLS_INTEGER constant
  -- 
  --  Defaults and optional parameters: endianess defaults to big_endian
  -- 
  --  Return value:
  --    raw
  --    null - if n input parameter was null
  -- 
  --  Errors:
  --    None


  /*----------------------------------------------------------------*/
  /*  CAST_TO_BINARY_DOUBLE                                        */
  /*----------------------------------------------------------------*/
  FUNCTION cast_to_binary_double(r IN RAW,
                                 endianess IN PLS_INTEGER
                                   DEFAULT 1)
                                 RETURN BINARY_DOUBLE;
    pragma RESTRICT_REFERENCES(cast_to_binary_double, WNDS, RNDS, WNPS, RNPS); 

  --  Perform a casting of the binary representation of the raw
  --  into a binary_double.
  --
  --  An 8-byte binary_double value maps to the the IEEE 754 double-precision
  --  format as follows:
  --    byte 0: bit 63 ~ bit 56
  --    byte 1: bit 55 ~ bit 48
  --    byte 2: bit 47 ~ bit 40
  --    byte 3: bit 39 ~ bit 32
  --    byte 4: bit 31 ~ bit 24
  --    byte 5: bit 23 ~ bit 16
  --    byte 6: bit 15 ~ bit  8
  --    byte 7: bit  7 ~ bit  0
  --
  --  The parameter endianess describes how the bytes of binary_double are
  --  mapped to the bytes of raw. In the following table, rb0 ~ rb7 refer
  --  to the bytes in raw and db0 ~ db7 refer to the bytes in binary_double.
  --
  --                   rb0   rb1   rb2   rb3   rb4   rb5   rb6   rb7
  --                  +----------------------------------------------+
  --   big_endian     |db0 | db1 | db2 | db3 | db4 | db5 | db6 | db7 |
  --                  |----------------------------------------------|
  --   little_endian  |db7 | db6 | db5 | db4 | db3 | db2 | db1 | db0 |
  --                  +----------------------------------------------+
  --
  --  In case of machine-endian, the 8 bytes of the raw argument
  --  are copied straight across into the binary_double return value.
  --  The effect is the same if the user has passed big_endian on a
  --  big endian machine, or little_endian on a little endian machine.
  --
  --  Input parameters:
  --    r - RAW value to be cast to binary_double
  --    endianess - big, little or machine endian PLS_INTEGER constant
  -- 
  --  Defaults and optional parameters: endianess defaults to big_endian
  -- 
  --  Note:
  --    If the RAW argument is more than 8 bytes, only the first 8
  --    bytes are used and the rest of the bytes are ignored. If the
  --    result is -0, +0 is returned. If the result is NaN, the value
  --    BINARY_DOUBLE_NAN is returned.
  -- 
  --  Return value:
  --    binary_double value
  --    null - if r input parameter was null
  -- 
  --  Errors:
  --    If the RAW argument is less than 8 bytes, VALUE_ERROR exception
  --    is raised (to be revised in a future release).

  /*----------------------------------------------------------------*/

END UTL_RAW;
/
show errors
