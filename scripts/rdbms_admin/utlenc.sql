REM
REM $Header: utlenc.sql 25-nov-2002.13:03:05 eehrsam Exp $
REM
REM utlenc.sql
REM
REM Copyright (c) 2000, 2002, Oracle Corporation.  All rights reserved.  
REM
REM    NAME
REM      utlenc.sql - PL/SQL Package for ENCODE (UTL_ENCODE)
REM
REM    DESCRIPTION
REM      PL/SQL package to encode RAW data strings
REM
REM    NOTES
REM      None.
REM
REM    MODIFIED   (MM/DD/YY)
REM    eehrsam     11/25/02 - 
REM    eehrsam     07/24/02 - Add text_encode/decode 
REM                           and mimeheader_encode/decode
REM    gviswana    05/25/01 - CREATE OR REPLACE SYNONYM
REM    eehrsam     01/15/01 - new UTL_ENCODE package
REM

CREATE OR REPLACE PACKAGE utl_encode IS

  -------------
  --  CONSTANTS
  --
  -- Define constants for use by uuencode's 2nd file type parameter
  complete         CONSTANT PLS_INTEGER := 1; -- includes header and footer
  header_piece     CONSTANT PLS_INTEGER := 2; -- includes header text
  middle_piece     CONSTANT PLS_INTEGER := 3; -- body text only
  end_piece        CONSTANT PLS_INTEGER := 4; -- includes footer text
  
  -- Define constants for use by text_encode/decode and mimeheader_encode
  -- in the 'encoding' parameter
  base64           CONSTANT PLS_INTEGER := 1;
  quoted_printable CONSTANT PLS_INTEGER := 2;

  /*----------------------------------------------------------------*/
  /* BASE64_ENCODE                                                  */
  /*----------------------------------------------------------------*/
  function base64_encode(r in raw) return raw;

  /*----------------------------------------------------------------*/
  /* BASE64_DECODE                                                  */
  /*----------------------------------------------------------------*/
  function base64_decode(r in raw) return raw;

  /*----------------------------------------------------------------*/
  /* UUENCODE                                                       */
  /*----------------------------------------------------------------*/
  function uuencode(r          in raw,
                    type       in pls_integer default complete,
                    filename   in varchar2 default 'uuencode.txt',
                    permission in varchar2 default '0') return raw;

  /*----------------------------------------------------------------*/
  /* UUDECODE                                                       */
  /*----------------------------------------------------------------*/
  function uudecode(r in raw) return raw;

  /*----------------------------------------------------------------*/
  /* QUOTED_PRINTABLE_ENCODE                                        */
  /*----------------------------------------------------------------*/
  function quoted_printable_encode(r in raw) return raw;

  /*----------------------------------------------------------------*/
  /* QUOTED_PRINTABLE_DECODE                                        */
  /*----------------------------------------------------------------*/
  function quoted_printable_decode(r in raw) return raw;

  /*----------------------------------------------------------------*/
  /* TEXT_ENCODE                                                    */
  /*----------------------------------------------------------------*/
  function text_encode(buf            in varchar2 character set any_cs,
                       encode_charset in varchar2 default null,
                       encoding       in pls_integer default null)
  return varchar2 character set buf%charset;

  /*----------------------------------------------------------------*/
  /* TEXT_DECODE                                                    */
  /*----------------------------------------------------------------*/
  function text_decode(buf            in varchar2 character set any_cs,
                       encode_charset in varchar2 default null,
                       encoding       in pls_integer default null)
  return varchar2 character set buf%charset;

  /*----------------------------------------------------------------*/
  /* MIMEHEADER_ENCODE                                              */
  /*----------------------------------------------------------------*/
  function mimeheader_encode(buf in varchar2 character set any_cs,
                             encode_charset in varchar2 default null,
                             encoding       in pls_integer default null)
  return varchar2 character set buf%charset;

  /*----------------------------------------------------------------*/
  /* MIMEHEADER_DECODE                                              */
  /*----------------------------------------------------------------*/
  function mimeheader_decode(buf in varchar2 character set any_cs)
  return varchar2 character set buf%charset;

END UTL_ENCODE;
/
show errors;

GRANT EXECUTE ON utl_encode TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_encode FOR sys.utl_encode;
