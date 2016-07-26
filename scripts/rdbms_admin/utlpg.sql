Rem  Copyright (c) 1993, 2007, Oracle.  All rights reserved.
Rem  
Rem    NAME
Rem      utlpg.sql  - PL/SQL Package of utility routines for Procedural
Rem                   Gateway. Package UTL_PG
Rem
Rem    DESCRIPTION
Rem      Procedural Gateway specific routines to manipulate raws.
Rem
Rem    RETURNS
Rem
Rem    NOTES
Rem      The procedural option is needed to use this facility.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     jmuller    03/29/07  - Fix bug 5921029: exception if non-defaulted
Rem                            nlslang, not SIGN SEPARATE, and signed value
Rem     dbronnik   12/08/97 -  bug 555733: add pragma restrict_references
Rem     rdasarat   10/04/96 -  Forward merge 377621
Rem     rhari      02/08/95 -  PDP-NDE
Rem     rhari      02/08/95 -  merge changes from branch 1.1.720.2
Rem     rhari      10/29/94 -  merge changes from branch 1.1.720.1
Rem     rhari      10/27/94 -  merge changes from branch 1.1.710.2
Rem     rhari      10/04/94 -  remove spool
Rem     rhari      09/29/94 -  Branch_for_patch
Rem     rhari      09/28/94 -  Creation
Rem     cddavis    09/23/94 -  added defaults and error results.
Rem     cddavis    06/27/94 -  split from utlraw.sql package
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
REM COULD CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE
REM RDBMS.  SPECIFICALLY, THE PSD* ROUTINES MUST NOT BE CALLED
REM DIRECTLY BY ANY CLIENT AND MUST REMAIN PRIVATE TO THE PACKAGE BODY.
REM ********************************************************************
 
CREATE OR REPLACE PACKAGE UTL_PG IS
 
  ------------
  --  OVERVIEW
  --
  --     This package provides SQL functions for raws which convert
  --     various non-Oracle number formats to/from raws.
  --     Included is conversion support for:
  --        IBM/370 VS COBOL II
 
  --     UTL_PG is not specific to the database environment and may
  --     actually be used in other environments as it exists here.
  --     For this reason, the prefix UTL has been given to the package
  --     instead of DBMS.
 
  --     UTL_PG is, however, complementary to facilities provided in
  --     the Oracle Procedural Gateway for APPC, and is supported only
  --     in conjunction with that product.
 
  -------
  -- USES
  --
  --     The raw functions convert foreign data exchanged with remote
  --     host systems as Oracle RAW's to/from Oracle NUMBER datatypes.
 
  ---------------------------
  -- PROCEDURES AND FUNCTIONS
 
  /*----------------------------------------------------------------*/
  /*  RAW_TO_NUMBER                                                 */
  /*----------------------------------------------------------------*/
  FUNCTION raw_to_number(r        IN RAW,
                         mask     IN VARCHAR2,
                         maskopts IN VARCHAR2,
                         envrnmnt IN VARCHAR2,
                         compname IN VARCHAR2,
                         compopts IN VARCHAR2,
                         nlslang  IN VARCHAR2,
                         wind     IN BOOLEAN,
                         wmsgbsiz IN BINARY_INTEGER,
                         wmsgblk  OUT RAW) RETURN NUMBER;
  pragma restrict_references (raw_to_number,WNDS,RNDS,WNPS,RNPS);
 
  --  Convert a raw byte-string from the remote host internal format
  --    specified by mask, maskopts, envrnmnt, compname, and compopts
  --    into an Oracle number.
  --    Warnings are issued, if enabled, when the conversion specified
  --    conflicts with the conversion implied by the data, or when
  --    conflicting format specifications are supplied.
 
  --  Input parameters:
  --    r        - the remote host data which is to be converted
  --    mask     - compiler-datatype mask
  --               The datatype to be converted, specified in the source
  --               language of the named compiler (compname).  mask
  --               implies the internal format of the data as encoded
  --               according to the compiler and host platform.
  --    maskopts - compiler-datatype mask options, or NULL
  --               Additional options associated with the mask, as may be
  --               allowed or required, and is specified in the source
  --               language of compname.  maskopts may further qualify
  --               the type of conversion needed.
  --    envrnmnt - compiler environment clause or NULL
  --               Additional options associated with the environment in
  --               which the remote data resides, as may be allowed or
  --               required, and is specified in the source language of
  --               compname.  envrnmnt typically supplies aspects of
  --               data conversion dictated by customer standards, such
  --               as decimal point or currency symbols if applicable.
  --    compname - compiler name, supported values are:
  --                     "IBMVSCOBOLII"
  --    compopts - compiler options or NULL
  --    nlslang  - zoned-dec codepage    in Oracle NLS form:
  --                                        language_territory.charset
  --                                     or defaults to:
  --                                     'AMERICAN_AMERICA.WE8EBCDIC37C'
  --    wind     - warning indicator.
  --               A boolean indicator which controls whether conversion
  --               warning messages are to be returned in the wmsgblk out
  --               parameter.
  --               FALSE  will suppress all warnings, but errors (if any)
  --                      will still be returned as ORA-nnnnn errors.
  --               TRUE   will cause warnings (if any) to be returned in
  --                      wmsgblk.
  --    wmsgbsiz - warning message block declared size in bytes.
  --               A binary_integer set to the byte length of wmgsblk.
  --               The warning message block must be at least 512 and
  --               not more than 8192 bytes in length.  When declaring
  --               wmsgblk, plan on approximately 512 bytes per warning
  --               returned, depending on the nature of the conversion
  --               requested.
 
  --  Output parameters:
  --    wmsgblk  - warning message block.
  --               A raw which may contain multiple warnings in both
  --               full message and substituted parameter formats, if
  --               and only if wind was TRUE, in which case wmsgblk
  --               should be passed to the wmsgcnt function to test if
  --               warnings were issued and to wmsg to extract any
  --               warnings which may be present.
  --               If wind was TRUE and no warnings were issued or if
  --               wind was FALSE, then the length of wmsgblk is 0.
  --               wmsgblk does not need to be reset prior to each use.
  --               The warning message is documented in the Oracle
  --               Messages and Codes for the RDBMS.
  --               wmsgblk MUST be allocated and passed as a parameter
  --               in all cases, regardless of wind value.
  --
  --    NOTE: Refer to PGA supported UTL_PG compiler datatypes for
  --          allowed values of mask, maskopts, envrnmnt, compname, and
  --          compopts.
  --
 
  --  Defaults and optional parameters:
  --    maskopts - null allowed, no default value
  --    envrnmnt - null allowed, no default value
  --    compopts - null allowed, no default value
 
  --  Return value:
  --    An Oracle number corresponding in value to r
 
  --  Errors:
  --    ORA-8401 invalid compiler name
  --    ORA-8414 error encounterred
  --    ORA-8429 raw data has invalid digit in display type data
  --    ORA-8430 raw data missing leading sign
  --    ORA-8431 raw data missing zero as defined in picture
  --    ORA-8433 invalid picture type in convert raw to number
  --    ORA-8434 raw data has invalid trailing sign
  --    ORA-8435 picture mask missing leading sign
  --    ORA-8436 raw data has invalid sign digit
  --    ORA-8437 invalid picture type in picture mask
  --    ORA-8441 closed parenthesis is missing in picture mask
  --    ORA-8443 syntax error in BLANK WHEN ZERO clause in mask options
  --    ORA-8444 syntax error in JUSTIFIED       clause in mask options
  --    ORA-8445 syntax error in SIGN            clause in mask options
  --    ORA-8446 syntax error in SYNCHRONIZED    clause in mask options
  --    ORA-8447 syntax error in USAGE           clause in mask options
  --    ORA-8448 syntax error in DECIMAL-POINT   environment clause
  --    ORA-8449 invalid numeric symbol found in picture mask
  --    ORA-8450 invalid specification of CR in picture mask
  --    ORA-8451 invalid specification of DB in picture mask
  --    ORA-8452 specification of E in picture mask unsupported
  --    ORA-8453 more than one V symbol specified in picture mask
  --    ORA-8454 more than one S symbol specified in picture mask
  --    ORA-8455 syntax error in CURRENCY SIGN environment clause
  --    ORA-8456 no sign in picture mask but SIGN clause in mask options
  --    ORA-8457 syntax error in SEPARATE CHARACTER option of SIGN clause
  --    ORA-8460 invalid environment clause in environment parameter
  --    ORA-8462 raw buffer contains invalid decimal data
  --    ORA-8463 overflow converting decimal number to Oracle number
  --    ORA-8464 input raw decimal data contains more than 42 digits
  --    ORA-8466 raw buffer length <len> to short for <type>
  --    ORA-8468 mask option <option> is not supported
  --    ORA-8469 must use the SIGN IS SEPARATE clause in mask options
 
  --  Warnings, if enabled:
  --    ORA-8498 picture mask overrides mask option USAGE ... to DISPLAY
  --    ORA-8499 picture mask options ignored by UTL_PG
 
  /*----------------------------------------------------------------*/
  /*  NUMBER_TO_RAW                                                 */
  /*----------------------------------------------------------------*/
  FUNCTION number_to_raw(n        IN NUMBER,
                         mask     IN VARCHAR2,
                         maskopts IN VARCHAR2,
                         envrnmnt IN VARCHAR2,
                         compname IN VARCHAR2,
                         compopts IN VARCHAR2,
                         nlslang  IN VARCHAR2,
                         wind     IN BOOLEAN,
                         wmsgbsiz IN BINARY_INTEGER,
                         wmsgblk  OUT RAW) RETURN RAW;
  pragma restrict_references (number_to_raw,WNDS,RNDS,WNPS,RNPS);
 
  --  Convert an Oracle number of declared precision and scale to
  --    a raw byte-string in the remote host internal format specified
  --    by mask, maskopts, envrnmnt, compname, and compopts.
  --    Warnings are issued, if enabled, when the conversion specified
  --    conflicts with the conversion implied by the data, or when
  --    conflicting format specifications are supplied.
 
  --  Input parameters:
  --    n        - the Oracle number which is to be converted
  --    mask     - compiler-datatype mask
  --               The datatype to be converted, specified in the source
  --               language of the named compiler (compname).  mask
  --               implies the internal format of the data as encoded
  --               according to the compiler and host platform.
  --    maskopts - compiler-datatype mask options, or NULL
  --               Additional options associated with the mask, as may be
  --               allowed or required, and is specified in the source
  --               language of compname.  maskopts may further qualify
  --               the type of conversion needed.
  --    envrnmnt - compiler environment clause or NULL
  --               Additional options associated with the environment in
  --               which the remote data resides, as may be allowed or
  --               required, and is specified in the source language of
  --               compname.  envrnmnt typically supplies aspects of
  --               data conversion dictated by customer standards, such
  --               as decimal point or currency symbols if applicable.
  --    compname - compiler name, supported values are:
  --                     "IBMVSCOBOLII"
  --    compopts - compiler options or NULL
  --    nlslang  - zoned-dec codepage    in Oracle NLS form:
  --                                        language_territory.charset
  --                                     or defaults to:
  --                                     'AMERICAN_AMERICA.WE8EBCDIC37C'
  --    wind     - warning indicator.
  --               A boolean indicator which controls whether conversion
  --               warning messages are to be returned in the wmsgblk out
  --               parameter.
  --               FALSE  will suppress all warnings, but errors (if any)
  --                      will still be returned as ORA-nnnnn errors.
  --               TRUE   will cause warnings (if any) to be returned in
  --                      wmsgblk.
  --    wmsgbsiz - warning message block declared size in bytes.
  --               A binary_integer set to the byte length of wmgsblk.
  --               The warning message block must be at least 512 and
  --               not more than 8192 bytes in length.  When declaring
  --               wmsgblk, plan on approximately 512 bytes per warning
  --               returned, depending on the nature of the conversion
  --               requested.
 
  --  Output parameters:
  --    wmsgblk  - warning message block.
  --               A raw which may contain multiple warnings in both
  --               full message and substituted parameter formats, if
  --               and only if wind was TRUE, in which case wmsgblk
  --               should be passed to the wmsgcnt function to test if
  --               warnings were issued and to wmsg to extract any
  --               warnings which may be present.
  --               If wind was TRUE and no warnings were issued or if
  --               wind was FALSE, then the length of wmsgblk is 0.
  --               wmsgblk does not need to be reset prior to each use.
  --               The warning message is documented in the Oracle
  --               Messages and Codes for the RDBMS.
  --               wmsgblk MUST be allocated and passed as a parameter
  --               in all cases, regardless of wind value.
  --
  --    NOTE: Refer to PGA supported UTL_PG compiler datatypes for
  --          allowed values of mask, maskopts, envrnmnt, compname, and
  --          compopts.
 
  --  Defaults and optional parameters:
  --    maskopts - null allowed, no default value
  --    envrnmnt - null allowed, no default value
  --    compopts - null allowed, no default value
 
  --  Return value:
  --    A raw corresponding in value to n.
 
  --  Errors:
  --    ORA-8401 invalid compiler name
  --    ORA-8414 error encounterred
  --    ORA-8437 invalid picture type in picture mask
  --    ORA-8441 closed parenthesis is missing in picture mask
  --    ORA-8443 syntax error in BLANK WHEN ZERO clause in mask options
  --    ORA-8444 syntax error in JUSTIFIED       clause in mask options
  --    ORA-8445 syntax error in SIGN            clause in mask options
  --    ORA-8446 syntax error in SYNCHRONIZED    clause in mask options
  --    ORA-8447 syntax error in USAGE           clause in mask options
  --    ORA-8448 syntax error in DECIMAL-POINT   environment clause
  --    ORA-8449 invalid numeric symbol found in picture mask
  --    ORA-8450 invalid specification of CR in picture mask
  --    ORA-8451 invalid specification of DB in picture mask
  --    ORA-8452 specification of E in picture mask unsupported
  --    ORA-8453 more than one V symbol specified in picture mask
  --    ORA-8454 more than one S symbol specified in picture mask
  --    ORA-8455 syntax error in CURRENCY SIGN environment clause
  --    ORA-8456 no sign in picture mask but SIGN clause in mask options
  --    ORA-8457 syntax error in SEPARATE CHARACTER option of SIGN clause
  --    ORA-8460 invalid environment clause in environment parameter
  --    ORA-8466 raw buffer length <len> to short for <type>
  --    ORA-8467 error encountered converting Oracle number to <type>
  --    ORA-8468 mask option <option> is not supported
 
  --  Warnings, if enabled:
  --    ORA-8498 picture mask overrides mask option USAGE ... to DISPLAY
  --    ORA-8499 picture mask options ignored by UTL_PG
 
  /*----------------------------------------------------------------*/
  /*  MAKE_RAW_TO_NUMBER_FORMAT                                     */
  /*----------------------------------------------------------------*/
  FUNCTION make_raw_to_number_format(mask     IN VARCHAR2,
                                     maskopts IN VARCHAR2,
                                     envrnmnt IN VARCHAR2,
                                     compname IN VARCHAR2,
                                     compopts IN VARCHAR2,
                                     nlslang  IN VARCHAR2,
                                     wind     IN BOOLEAN,
                                     wmsgbsiz IN BINARY_INTEGER,
                                     wmsgblk  OUT RAW) RETURN RAW;
  pragma restrict_references (make_raw_to_number_format,WNDS,RNDS,WNPS,RNPS);
 
  --  Make a raw_to_number format conversion specification used to
  --    convert a raw byte-string from the remote host internal format
  --    specified by mask, maskopts, envrnmnt, compname, and compopts
  --    into an Oracle number of comparable precision and scale.
  --    Warnings are issued, if enabled, when the conversion specified
  --    conflicts with the conversion implied by the data, or when
  --    conflicting format specifications are supplied.
  --    This function returns a raw containing the conversion format
  --    which can be passed to UTL_PG.RAW_TO_NUMBER_FORMAT.
 
  --  Input parameters:
  --    mask     - compiler-datatype mask
  --               The datatype to be converted, specified in the source
  --               language of the named compiler (compname).  mask
  --               implies the internal format of the data as encoded
  --               according to the compiler and host platform.
  --    maskopts - compiler-datatype mask options, or NULL
  --               Additional options associated with the mask, as may be
  --               allowed or required, and is specified in the source
  --               language of compname.  maskopts may further qualify
  --               the type of conversion needed.
  --    envrnmnt - compiler environment clause or NULL
  --               Additional options associated with the environment in
  --               which the remote data resides, as may be allowed or
  --               required, and is specified in the source language of
  --               compname.  envrnmnt typically supplies aspects of
  --               data conversion dictated by customer standards, such
  --               as decimal point or currency symbols if applicable.
  --    compname - compiler name, supported values are:
  --                     "IBMVSCOBOLII"
  --    compopts - compiler options or NULL
  --    nlslang  - zoned-dec codepage    in Oracle NLS form:
  --                                        language_territory.charset
  --                                     or defaults to:
  --                                     'AMERICAN_AMERICA.WE8EBCDIC37C'
  --    wind     - warning indicator.
  --               A boolean indicator which controls whether conversion
  --               warning messages are to be returned in the wmsgblk out
  --               parameter.
  --               FALSE  will suppress all warnings, but errors (if any)
  --                      will still be returned as ORA-nnnnn errors.
  --               TRUE   will cause warnings (if any) to be returned in
  --                      wmsgblk.
  --    wmsgbsiz - warning message block declared size in bytes.
  --               A binary_integer set to the byte length of wmgsblk.
  --               The warning message block must be at least 512 and
  --               not more than 8192 bytes in length.  When declaring
  --               wmsgblk, plan on approximately 512 bytes per warning
  --               returned, depending on the nature of the conversion
  --               requested.
 
  --  Output parameters:
  --    wmsgblk  - warning message block.
  --               A raw which may contain multiple warnings in both
  --               full message and substituted parameter formats, if
  --               and only if wind was TRUE, in which case wmsgblk
  --               should be passed to the wmsgcnt function to test if
  --               warnings were issued and to wmsg to extract any
  --               warnings which may be present.
  --               If wind was TRUE and no warnings were issued or if
  --               wind was FALSE, then the length of wmsgblk is 0.
  --               wmsgblk does not need to be reset prior to each use.
  --               The warning message is documented in the Oracle
  --               Messages and Codes for the RDBMS.
  --               wmsgblk MUST be allocated and passed as a parameter
  --               in all cases, regardless of wind value.
  --
  --    NOTE: Refer to PGA supported UTL_PG compiler datatypes for
  --          allowed values of mask, maskopts, envrnmnt, compname, and
  --          compopts.
 
  --  Defaults and optional parameters:
  --    maskopts - null allowed, no default value
  --    envrnmnt - null allowed, no default value
  --    compopts - null allowed, no default value
 
  --  Return value:
  --     A 2K raw format conversion specification for raw_to_number.
 
  --  Errors:
  --    ORA-8401 invalid compiler name
  --    ORA-8414 error encounterred
  --    ORA-8433 invalid picture type in convert raw to number
  --    ORA-8437 invalid picture type in picture mask
  --    ORA-8441 closed parenthesis is missing in picture mask
  --    ORA-8443 syntax error in BLANK WHEN ZERO clause in mask options
  --    ORA-8444 syntax error in JUSTIFIED       clause in mask options
  --    ORA-8445 syntax error in SIGN            clause in mask options
  --    ORA-8446 syntax error in SYNCHRONIZED    clause in mask options
  --    ORA-8447 syntax error in USAGE           clause in mask options
  --    ORA-8448 syntax error in DECIMAL-POINT   environment clause
  --    ORA-8449 invalid numeric symbol found in picture mask
  --    ORA-8450 invalid specification of CR in picture mask
  --    ORA-8451 invalid specification of DB in picture mask
  --    ORA-8452 specification of E in picture mask unsupported
  --    ORA-8453 more than one V symbol specified in picture mask
  --    ORA-8454 more than one S symbol specified in picture mask
  --    ORA-8455 syntax error in CURRENCY SIGN environment clause
  --    ORA-8456 no sign in picture mask but SIGN clause in mask options
  --    ORA-8457 syntax error in SEPARATE CHARACTER option of SIGN clause
  --    ORA-8458 invalid format parameter
  --    ORA-8459 invalid format parameter length
  --    ORA-8460 invalid environment clause in environment parameter
  --    ORA-8467 error encountered converting Oracle number to <type>
  --    ORA-8468 mask option <option> is not supported
 
  --  Warnings, if enabled:
  --    ORA-8498 picture mask overrides mask option USAGE ... to DISPLAY
  --    ORA-8499 picture mask options ignored by UTL_PG
 
  /*----------------------------------------------------------------*/
  /*  MAKE_NUMBER_TO_RAW_FORMAT                                     */
  /*----------------------------------------------------------------*/
  FUNCTION make_number_to_raw_format(mask IN VARCHAR2,
                                     maskopts IN VARCHAR2,
                                     envrnmnt IN VARCHAR2,
                                     compname IN VARCHAR2,
                                     compopts IN VARCHAR2,
                                     nlslang  IN VARCHAR2,
                                     wind     IN BOOLEAN,
                                     wmsgbsiz IN BINARY_INTEGER,
                                     wmsgblk  OUT RAW) RETURN RAW;
  pragma restrict_references (make_number_to_raw_format,WNDS,RNDS,WNPS,RNPS);
 
  --  Make a number_to_raw format conversion specification used to
  --    convert an Oracle number of declared precision and scale to
  --    a raw byte-string in the remote host internal format specified
  --    by mask, maskopts, envrnmnt, compname, and compopts.
  --    Warnings are issued, if enabled, when the conversion specified
  --    conflicts with the conversion implied by the data, or when
  --    conflicting format specifications are supplied.
  --    This function returns a raw containing the conversion format
  --    which can be passed to UTL_PG.NUMBER_TO_RAW_FORMAT.
  --    The implementation length of the result format raw is 2048 bytes.
 
  --  Input parameters:
  --    mask     - compiler-datatype mask
  --               The datatype to be converted, specified in the source
  --               language of the named compiler (compname).  mask
  --               implies the internal format of the data as encoded
  --               according to the compiler and host platform.
  --    maskopts - compiler-datatype mask options, or NULL
  --               Additional options associated with the mask, as may be
  --               allowed or required, and is specified in the source
  --               language of compname.  maskopts may further qualify
  --               the type of conversion needed.
  --    envrnmnt - compiler environment clause or NULL
  --               Additional options associated with the environment in
  --               which the remote data resides, as may be allowed or
  --               required, and is specified in the source language of
  --               compname.  envrnmnt typically supplies aspects of
  --               data conversion dictated by customer standards, such
  --               as decimal point or currency symbols if applicable.
  --    compname - compiler name, supported values are:
  --                     "IBMVSCOBOLII"
  --    compopts - compiler options or NULL
  --    nlslang  - zoned-dec codepage    in Oracle NLS form:
  --                                        language_territory.charset
  --                                     or defaults to:
  --                                     'AMERICAN_AMERICA.WE8EBCDIC37C'
  --    wind     - warning indicator.
  --               A boolean indicator which controls whether conversion
  --               warning messages are to be returned in the wmsgblk out
  --               parameter.
  --               FALSE  will suppress all warnings, but errors (if any)
  --                      will still be returned as ORA-nnnnn errors.
  --               TRUE   will cause warnings (if any) to be returned in
  --                      wmsgblk.
  --    wmsgbsiz - warning message block declared size in bytes.
  --               A binary_integer set to the byte length of wmgsblk.
  --               The warning message block must be at least 512 and
  --               not more than 8192 bytes in length.  When declaring
  --               wmsgblk, plan on approximately 512 bytes per warning
  --               returned, depending on the nature of the conversion
  --               requested.
 
  --  Output parameters:
  --    wmsgblk  - warning message block.
  --               A raw which may contain multiple warnings in both
  --               full message and substituted parameter formats, if
  --               and only if wind was TRUE, in which case wmsgblk
  --               should be passed to the wmsgcnt function to test if
  --               warnings were issued and to wmsg to extract any
  --               warnings which may be present.
  --               If wind was TRUE and no warnings were issued or if
  --               wind was FALSE, then the length of wmsgblk is 0.
  --               wmsgblk does not need to be reset prior to each use.
  --               The warning message is documented in the Oracle
  --               Messages and Codes for the RDBMS.
  --               wmsgblk MUST be allocated and passed as a parameter
  --               in all cases, regardless of wind value.
  --
  --    NOTE: Refer to PGA supported UTL_PG compiler datatypes for
  --          allowed values of mask, maskopts, envrnmnt, compname, and
  --          compopts.
 
  --  Defaults and optional parameters:
  --    maskopts - null allowed, no default value
  --    envrnmnt - null allowed, no default value
  --    compopts - null allowed, no default value
 
  --  Return value:
  --     A 2K raw format conversion specification for number_to_raw.
 
  --  Errors:
  --    ORA-8401 invalid compiler name
  --    ORA-8414 error encounterred
  --    ORA-8437 invalid picture type in picture mask
  --    ORA-8441 closed parenthesis is missing in picture mask
  --    ORA-8443 syntax error in BLANK WHEN ZERO clause in mask options
  --    ORA-8444 syntax error in JUSTIFIED       clause in mask options
  --    ORA-8445 syntax error in SIGN            clause in mask options
  --    ORA-8446 syntax error in SYNCHRONIZED    clause in mask options
  --    ORA-8447 syntax error in USAGE           clause in mask options
  --    ORA-8448 syntax error in DECIMAL-POINT   environment clause
  --    ORA-8449 invalid numeric symbol found in picture mask
  --    ORA-8450 invalid specification of CR in picture mask
  --    ORA-8451 invalid specification of DB in picture mask
  --    ORA-8452 specification of E in picture mask unsupported
  --    ORA-8453 more than one V symbol specified in picture mask
  --    ORA-8454 more than one S symbol specified in picture mask
  --    ORA-8455 syntax error in CURRENCY SIGN environment clause
  --    ORA-8456 no sign in picture mask but SIGN clause in mask options
  --    ORA-8457 syntax error in SEPARATE CHARACTER option of SIGN clause
  --    ORA-8458 invalid format parameter
  --    ORA-8459 invalid format parameter length
  --    ORA-8460 invalid environment clause in environment parameter
  --    ORA-8467 error encountered converting Oracle number to <type>
  --    ORA-8468 mask option <option> is not supported
 
  --  Warnings, if enabled:
  --    ORA-8498 picture mask overrides mask option USAGE ... to DISPLAY
  --    ORA-8499 picture mask options ignored by UTL_PG
 
  /*----------------------------------------------------------------*/
  /*  RAW_TO_NUMBER_FORMAT                                          */
  /*----------------------------------------------------------------*/
  FUNCTION raw_to_number_format(rawval IN RAW,
                                r2nfmt IN RAW) RETURN NUMBER;
  pragma restrict_references (raw_to_number_format,WNDS,RNDS,WNPS,RNPS);
 
  --  Convert, according to the raw_to_number conversion format r2nfmt,
  --    a raw byte-string rawval in the remote host internal format
  --    to an Oracle number.
 
  --  Input parameters:
  --    rawval   - the remote host data which is to be converted
  --    r2nfmt   - a 2K raw format specification returned from
  --               make_raw_to_number_format
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    An Oracle number corresponding in value to r
 
  --  Errors:
  --    ORA-8414 error encounterred
  --    ORA-8429 raw data has invalid digit in display type data
  --    ORA-8430 raw data missing leading sign
  --    ORA-8431 raw data missing zero as defined in picture
  --    ORA-8434 raw data has invalid trailing sign
  --    ORA-8436 raw data has invalid sign digit
  --    ORA-8458 invalid format parameter
  --    ORA-8459 invalid format parameter length
  --    ORA-8462 raw buffer contains invalid decimal data
  --    ORA-8463 overflow converting decimal number to Oracle number
  --    ORA-8464 input raw decimal data contains more than 42 digits
  --    ORA-8466 raw buffer length <len> to short for <type>
  --    ORA-8467 error encountered converting Oracle number to <type>
 
  /*----------------------------------------------------------------*/
  /*  NUMBER_TO_RAW_FORMAT                                          */
  /*----------------------------------------------------------------*/
  FUNCTION number_to_raw_format(numval IN NUMBER,
                                n2rfmt IN RAW) RETURN RAW;
  pragma restrict_references (number_to_raw_format,WNDS,RNDS,WNPS,RNPS);
 
  --  Convert, according to the number_to_raw conversion format n2rfmt,
  --    an Oracle number numval of declared precision and scale to a
  --    raw byte-string in the remote host internal format.
 
  --  Input parameters:
  --    numval   - the Oracle number which is to be converted
  --    n2rfmt   - a 2K raw format specification returned from
  --               make_number_to_raw_format
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    A raw corresponding in value to n.
 
  --  Errors:
  --    ORA-8414 error encounterred
  --    ORA-8458 invalid format parameter
  --    ORA-8459 invalid format parameter length
  --    ORA-8467 error encountered converting Oracle number to <type>
 
  /*----------------------------------------------------------------*/
  /*  WMSGCNT                                                       */
  /*----------------------------------------------------------------*/
  FUNCTION wmsgcnt(wmsgblk IN RAW) RETURN BINARY_INTEGER;
  pragma restrict_references (wmsgcnt,WNDS,RNDS,WNPS,RNPS);
 
  --  Tests a wmsgblk to determine how many warnings (if any) may
  --    be present.
 
  --  Input parameters:
  --    wmsgblk  - warning message block returned from:
  --                 number_to_raw
  --                 raw_to_number
  --                 make_raw_to_number_format
  --                 make_number_to_raw_format
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    A binary_integer equal to the count of warnings present in the
  --    wmsgblk raw.
  --      Possible returned values are:
  --      >0    - positive count of warnings present in wmsgblk.
  --       0    - no warnings present in wmsgblk.
 
  --  Errors:
  --    Return value:
  --      Possible return values are:
  --      -2    - invalid message block.
 
  /*----------------------------------------------------------------*/
  /*  WMSG                                                          */
  /*----------------------------------------------------------------*/
  FUNCTION wmsg(wmsgblk  IN  RAW,
                wmsgitem IN  BINARY_INTEGER,
                wmsgno   OUT BINARY_INTEGER,
                wmsgtext OUT VARCHAR2,
                wmsgfill OUT VARCHAR2) RETURN BINARY_INTEGER;
  pragma restrict_references (wmsg,WNDS,RNDS,WNPS,RNPS);
 
  --  Extract a warning message specified by wmsgitem from wmsgblk.
 
  --  Input parameters:
  --    wmsgblk  - A raw, the warning message block returned from:
  --                 number_to_raw
  --                 raw_to_number
  --                 make_raw_to_number_format
  --                 make_number_to_raw_format
  --    wmsgitem - A binary_integer specifying which warning message
  --               to extract, numbered from 0 as the first warning
  --               through n-1 for the Nth warning.
 
  --  Output parameters:
  --    wmsgno   - A binary_integer (hexadecimal) value of the
  --               warning number.  This value, after conversion to
  --               decimal, is documented in the Oracle Messages and
  --               Codes for the RDBMS.
  --    wmsgtext - A varchar2 containing the fully formated warning
  --               message in the format:
  --                  ORA-nnnnn warning message text
  --               where nnnnn is the decimal warning number documented
  --               in the Oracle Messages and Codes for the RDBMS.
  --    wmsgfill - A varchar2 containing the list of warning message
  --               parameters to be substituted into a warning message
  --               in the format:
  --                  warnparm1;;warnparm2;;...;;warnparmN
  --               where each warning parameter is delimited by a
  --               double semi-colon ';;'.
 
  --  Defaults and optional parameters: None
 
  --  Return value:
  --    A binary_integer containing a status return code.
  --       0    - wmsgno, wmsgtext, and wmsgfill are assigned and valid.
 
  --  Errors:
  --    Return value:
  --      Possible return values are:
  --      -1    - warning specified by wmsgitem not found in wmsgblk.
  --      -2    - invalid message block.
  --      -3    - wmsgblk is too small to contain the warning associated
  --              with wmsgitem.  Only a partial or possibly no warning
  --              message may be present for this particular wmsgitem.
  --      -4    - too many substituted warning parameters.
 
END UTL_PG;
/
show errors
