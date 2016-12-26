REM
REM $Header: utlurl.sql 07-jan-2008.18:29:46 rpang Exp $
REM
REM utlurl.sql
REM
REM Copyright (c) 2000, 2002, Oracle Corporation.  All rights reserved.  
REM
REM    NAME
REM      utlurl.sql - PL/SQL Package for URL (UTL_URL)
REM
REM    DESCRIPTION
REM      PL/SQL package to escape/unescape URLs.
REM
REM    NOTES
REM      None.
REM
REM    MODIFIED   (MM/DD/YY)
REM    rpang       01/07/08 - Changed reserved characters definition for IPv6
REM    sylin       12/11/02 - 2351330: Add NCAHR support
REM    rpang       03/04/02 - 1765013: correct x-www-form-urlencoded example
REM    gviswana    05/25/01 - CREATE OR REPLACE SYNONYM
REM    rpang       04/12/01 - Added x-www-form-urlencoded example
REM    rpang       09/01/00 - Created
REM

CREATE OR REPLACE PACKAGE utl_url AS

  /*********************************************************************

  A Uniform Resource Locator (URL) is a string that identifies a resource
  (such as a Web page or a picture) on the Web that can be accessed usually
  via the HyperText Transfer Protocol (HTTP).  For example, the URL of the
  front-page of Oracle's Web site is "http://www.oracle.com/".

  Normally, a URL contains English alphabets, digits, and some punctuation
  characters.  They are called the unreserved characters.  Any other
  characters (including multi-byte characters) or binary octet codes in a
  URL must be escaped in order that it can be safely handled by a
  Web browser or a Web server.  Some punctuation characters, such as
  "$", "?", ":", and "=", are reserved as delimiters in a URL.
  They are called the reserved characters.  If such characters are to be
  taken literally instead of being treated as delimiters, they must be
  escaped as well.

  The unreserved characters consist of:
    - "A" - "Z", "a" - "z",
    - "0" - "9",
    - "-", "_", ".", "!", "~", "*", "'", "(", and ")"

  The reserved characters consist of:
    - ";", "/", "?", ":". "@", "&", "=". "+", "$", ",", "[", "]"

  This package provides two functions that escape and unescape characters
  in a URL.  The escape function should be used to escape a URL before the URL
  is used fetch a Web page via the UTL_HTTP package.  The unescape function
  should be used to unescape an escaped URL before information is extracted
  from the URL.

  For more information, refer to the Request For Comments (RFC) document
  RFC2396. Note that this URL escape and unescape mechanism is different from
  the x-www-form-urlencoded encoding mechanism described in the HTML
  specification:

    http://www.w3.org/TR/html

  You can implement the x-www-form-urlencoded encoding using the
  UTL_URL.ESCAPE function as follows:

    CREATE OR REPLACE FUNCTION form_url_encode(
      data    IN VARCHAR2,
      charset IN VARCHAR2) RETURN VARCHAR2 AS
    BEGIN
      RETURN utl_url.escape(data, TRUE, charset); -- note use of TURE
    END;

  Notice that this form_url_encode function encodes space characters in "%HH"
  hex code format instead of "+" as stipulated by the form-URL-encode scheme.
  However, this function will cause no noticeable difference to applications
  that depend on the form-URL-encode scheme to submit data to a Web server in
  most cases. Most Web servers will be able to decode the submitted data
  correctly. If the user's Web server does not accept space characters encoded
  in "%HH" hex code format, the user will have to modify the form_url_encode
  function to selectively encode space characters as "+" and encode the
  remaining characters using the UTL_URL.ESCAPE function.

  For decoding data encoded with the form-URL-encode scheme, the following
  function implements the decording scheme:

    CREATE OR REPLACE FUNCTION form_url_decode(
      data    IN VARCHAR2,
      charset IN VARCHAR2) RETURN VARCHAR2 AS
    BEGIN
      RETURN utl_url.unescape(replace(data, '+', ' '), charset);
    END;

  *********************************************************************/

  -- Exceptions
  bad_url                  EXCEPTION; -- URL contains badly formed escape code
  bad_fixed_width_charset  EXCEPTION; -- Fixed-width multibyte character set
                                      -- not allowed for a URL
  PRAGMA EXCEPTION_INIT(bad_url,                 -29262);
  PRAGMA EXCEPTION_INIT(bad_fixed_width_charset, -29274);

  /**
   * Returns the URL with illegal characters (and optionally reserved
   * characters) escaped using "%2-digit-hex-code" format.
   *
   * PARAMETERS
   *   url                    The URL to escape
   *   escape_reserved_chars  Escape the reserved characters as well or not?
   *   url_charset            When escaping a URL, what is the character
   *                          set that URL should be converted to before
   *                          the URL is escaped in %hex-code format?
   *                          If url_charset is NULL, the database
   *                          charset is assumed and no character set
   *                          conversion will occur.  The default value is
   *                          the current default body character set of the
   *                          UTL_HTTP package, whose default value is
   *                          "ISO-8859-1".  The character set can be named
   *                          in Internet Assigned Numbers Authority (IANA) or
   *                          Oracle naming convention.
   * EXCEPTIONS
   *   bad_fixed_width_charset  when the url_charset is a fixed-width
   *                            multibyte character set that is not allowed as
   *                            an encoding of a URL as the character set
   *                            does not contain the "%" or other single-byte
   *                            characters.
   *   + plus miscellaneous runtime exceptions.
   * NOTES
   *   Normally, a user will escape the whole URL, which contains the
   * reserved characters (delimiters) that should not be escaped.
   * For example,
   *
   *   utl_url.escape('http://www.acme.com/a url with space.html')
   *
   * will return
   *
   *   'http://foo.com/a%20url%20with%20space.html'
   *
   *   In other situations, a user may want to send a query string with a
   * value that contains reserved characters.  In that case, he should escape
   * just the value fully (with escape_reserved_chars set to TRUE) and then
   * concatenate it with the rest of the URL.  For example,
   *
   *   url := 'http://www.acme.com/search?check=' ||
   *             utl_url.escape('Is the use of the "$" sign okay?', TRUE);
   *
   * That will escape the "?", "$", and space characters in
   * 'Is the use of the "$" sign okay?' but not the "?" after "search" in the
   * URL that denotes the use of a query string.
   *
   *   Note that the Web server that a user intends to fetch Web pages from
   * may use a character set that is different from that of the user's
   * database.  In that case, the user must specify the url_charset
   * as the Web server's character set so that the characters that need
   * to be escaped are escaped in the URL character set.  For example,
   * a user of an EBCDIC database who wants to access an ASCII Web server
   * should escape the URL using "US7ASCII" so that a space is escaped
   * as "%20" (hex code of a space in ASCII) instead of "%40" (hex code
   * of a space in EBCDIC).  When the url_charset is specified, the
   * escape function will convert the URL to the URL character set,
   * escape the URL, and convert the escaped URL from the URL character set
   * back to the database character set.
   *
   *   This function does not validate a URL for the proper URL format.
   */
  FUNCTION escape(url                   IN VARCHAR2 CHARACTER SET ANY_CS,
                  escape_reserved_chars IN BOOLEAN  DEFAULT FALSE,
                  url_charset           IN VARCHAR2 DEFAULT
                                                    utl_http.get_body_charset)
                  RETURN VARCHAR2 CHARACTER SET url%CHARSET;

  /**
   * Unescapes the escape character sequences to their original form in an URL,
   * namely to convert "%XX" escape character sequences to the original
   * characters.
   *
   * PARAMETERS
   *   url              The URL to unescape
   *   url_charset      When unescaping a URL, what is the character
   *                    set that URL should be converted to before
   *                    the URL is unescaped from %hex-code format?
   *                    If url_charset is NULL, the database
   *                    charset is assumed and no character set
   *                    conversion will occur.  The default value is
   *                    the current default body character set of the
   *                    UTL_HTTP package, whose default value is
   *                    "ISO-8859-1".  The character set can be named
   *                    in Internet Assigned Numbers Authority (IANA) or
   *                    Oracle naming convention.
   *
   * EXCEPTIONS
   *   bad_url                  when the URL contains badly-formed
   *                            escape codes.
   *   bad_fixed_width_charset  when the url_charset is a fixed-width
   *                            multibyte character set that is not allowed as
   *                            an encoding of a URL as the character set
   *                            does not contain the "%" or other single-byte
   *                            characters.
   *   + plus miscellaneous runtime exceptions.
   * NOTES
   *   Note that the Web server that a user receives the URL from
   * may use a character set that is different from that of the user's
   * database.  In that case, the user must specify the url_charset
   * as the Web server's character set so that the characters that need
   * to be unescaped are unescaped in the URL character set.  For example,
   * user of an EBCDIC database who receives a URL from an ASCII Web server
   * should unescape the URL using "US7ASCII" so that "%20" is unescaped as
   * a space (0x20 is the hex code of a space in ASCII) instead of a "?"
   * (because 0x20 is not a valid character in EBCDIC).  When the
   * url_charset is specified, the unescape function converts the URL to
   * the URL character set, unescape the URL, and convert the unescaped URL
   * from the URL character set back to the database character set.
   *
   *   This function does not validate a URL for the proper URL format.
   */
  FUNCTION unescape(url         IN VARCHAR2 CHARACTER SET ANY_CS,
                    url_charset IN VARCHAR2 DEFAULT
                                            utl_http.get_body_charset)
                    RETURN VARCHAR2 CHARACTER SET url%CHARSET;

END;
/

GRANT EXECUTE ON utl_url TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_url FOR sys.utl_url;
