Rem
Rem $Header: utli18n.sql 14-may-2004.11:34:23 xji Exp $
Rem $Header: utli18n.sql 01-jun-2004.16:12:51 stakeda Exp $
Rem
Rem utli18n.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utli18n.sql - Oracle Globalization Service
Rem
Rem    DESCRIPTION
Rem      Routines for Oracle Globalization Service
Rem
Rem    NOTES
Rem      The procedural option is needed to use this package.
Rem      This package must be created under SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    xji         05/14/04 - transliteration
Rem    stakeda     06/01/04 - add GET_TRANSLATION 
Rem    stakeda     05/14/04 - remove ANY_CS 
Rem    stakeda     04/07/04 - 10gR2 add common lists and translations
Rem    xji         05/30/03 - add two more functions for project marvel
Rem    ywu         09/18/02 - add more functions
Rem    ywu         09/06/02 - ywu_plsqli18n
Rem    ywu         08/28/02 - Created
Rem

CREATE OR REPLACE PACKAGE utl_i18n AS

  /* GDK (Globalization Development Kit) is a set of services that can help
   * monolingual application developers to create similar multilingual
   * application with minimal knowledge about internationalization issues.
   * Oracle globalization services provide developers a set of consistent,
   * high performance and easy to use tools.
   */
 
  /* Convert function constant */
  SHIFT_IN         CONSTANT PLS_INTEGER  :=0;
  SHIFT_OUT        CONSTANT PLS_INTEGER  :=1;  

  /* Miscellaneous flags used by the locale-mapping API */
  ORACLE_TO_IANA    CONSTANT PLS_INTEGER := 0;
  IANA_TO_ORACLE    CONSTANT PLS_INTEGER := 1;
   
  MAIL_GENERIC      CONSTANT PLS_INTEGER := 0;
  MAIL_WINDOWS      CONSTANT PLS_INTEGER := 1;

  GENERIC_CONTEXT   CONSTANT PLS_INTEGER := 0;
  MAIL_CONTEXT      CONSTANT PLS_INTEGER := 1; 

  /* ENCODE_SQL_XML function constant */
  XMLTAG_TO_SQLNAME   CONSTANT PLS_INTEGER :=0;
  SQLNAME_TO_XMLTAG   CONSTANT PLS_INTEGER :=1;

  /* for transliteration */
  KANA_FWKATAKANA  CONSTANT VARCHAR2(30) := 'kana_fwkatakana';
  KANA_HWKATAKANA  CONSTANT VARCHAR2(30) := 'kana_hwkatakana';
  KANA_HIRAGANA    CONSTANT VARCHAR2(30) := 'kana_hiragana' ; 
  FWKATAKANA_HWKATAKANA  CONSTANT VARCHAR2(30) := 'fwkatakana_hwkatakana' ; 
  FWKATAKANA_HIRAGANA    CONSTANT VARCHAR2(30) := 'fwkatakana_hiragana' ;
  HWKATAKANA_FWKATAKANA  CONSTANT VARCHAR2(30) := 'hwkatakana_fwkatakana';
  HWKATAKANA_HIRAGANA    CONSTANT VARCHAR2(30) := 'hwkatakana_hiragana' ;
  HIRAGANA_FWKATAKANA    CONSTANT VARCHAR2(30) := 'hiragana_fwkatakana';
  HIRAGANA_HWKATAKANA    CONSTANT VARCHAR2(30) := 'hiragana_hwkatakana';
    
  /* pre-defined exceptions */
  UNSUPPORTED_TRANSLITERATION  EXCEPTION;
  PRAGMA EXCEPTION_INIT(UNSUPPORTED_TRANSLITERATION, -3001);

  -- translation flag for GET_TRANSLATION --
  LANGUAGE_TRANS           CONSTANT PLS_INTEGER :=0;
  TERRITORY_TRANS          CONSTANT PLS_INTEGER :=1;
  LANGUAGE_TERRITORY_TRANS CONSTANT PLS_INTEGER :=2;

  /* List of String data type */
  TYPE string_array IS TABLE of VARCHAR2(32767)
    INDEX BY BINARY_INTEGER;

  /**
   * Convert a VARCHAR2/NVARCHAR2 string to another charset
   *  return the result in RAW variable 
   * 
   * For example, utl_i18n.string_to_raw('abcde'||chr(170), 'utf8') 
   * will return a raw of hex value '616263646566C2AA'.
   * If user inputs an invalid character set or an empty input string, 
   * an empty string will be returned. 
   *
   * PARAMETERS
   *   data        The input VARCHAR2/NVARCHAR to convert.
   *   dst_charset The destination charset to be converted to.
   *             
   * RETURN
   *   The byte string after conversion in raw format 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  FUNCTION string_to_raw(data IN VARCHAR2 CHARACTER SET ANY_CS,
                          dst_charset IN VARCHAR2 DEFAULT NULL)
                          RETURN RAW;

  /**
   * Convert a raw buffer which is encode in another charset
   * back to VARCHAR2 string. 
   *   
   * For example, utl_i18n.raw_to_char(hextoraw('616263646566C2AA', 'utf8') 
   * will return a string (encoded in database charset) 'abcde'||chr(170).
   * If user inputs an invalid character set or an empty raw buffer, 
   * an empty string will be returned. 
   *
   * PARAMETERS
   *   data        The input byte arrays in raw.
   *   src_charset The source charset raw data is converted from.
   *             
   * RETURN
   *   The string converted back into database charset encoding. 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  FUNCTION raw_to_char(data IN RAW,
                       src_charset IN VARCHAR2 DEFAULT NULL)
                       RETURN VARCHAR2;
 
 /**
   * Convert a raw buffer which is encode in another charset
   * back to NVARCHAR2 string. 
   *   
   * For example, utl_i18n.raw_to_nchar(hextoraw('616263646566C2AA', 'utf8') 
   * will return a string (encoded in nation charset) 'abcde'||chr(170).
   * If user inputs an invalid character set or an empty raw buffer, 
   * an empty string will be returned. 
   *
   * PARAMETERS
   *   data        The input byte arrays in raw.
   *   src_charset The source charset raw data is converted from.
   *             
   * RETURN
   *   The string converted back into national charset encoding. 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  FUNCTION raw_to_nchar(data IN RAW,
                        src_charset IN VARCHAR2 DEFAULT NULL)
                        RETURN NVARCHAR2;

 /**
   * Convert a raw buffer which is encode in another charset
   * back to NVARCHAR2 string and return the shift status and 
   * scanned length for the input. Those information can be used
   * into piece wise conversion. 
   *   
   * For example, utl_i18n.raw_to_char(hextoraw('616263646566C2AA', 
   *  'utf8', shf, slen) will return a string 'abcde'||chr(170) and
   * set shf=8, slen = SHIFT_IN.
   * If user inputs an invalid character set or an empty raw buffer, 
   * an empty string will be returned. 
   *
   * PARAMETERS
   *   data           The input byte arrays in raw. 
   *   src_charset    The source charset raw data is converted from.
   *   scanned_length The scanned byte of input raw data. (OUT)
   *   shift_status   The shift status at the end of this scan. (IN/OUT)
   *                  User must set this variable to be SHIFT_IN the first  
   *                  time it is called in piece wise cnversion.
   * RETURN
   *   The string converted back into database charset encoding. 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  Function raw_to_char(data IN RAW,
                       src_charset IN VARCHAR2 DEFAULT NULL,
                       scanned_length OUT PLS_INTEGER,
                       shift_status IN OUT PLS_INTEGER)
                       RETURN VARCHAR2;

 /**
   * Convert a raw buffer which is encode in another charset
   * back to VARCHAR2 string and return the shift status and 
   * scanned length for the input. Those information can be used
   * into piece wise conversion. 
   *   
   * For example, utl_i18n.raw_to_nchar(hextoraw('616263646566C2AA', 
   *  'utf8', shf, slen) will return a string 'abcde'||chr(170) and
   * set shf=8, slen = SHIFT_IN.
   * If user inputs an invalid character set or an empty raw buffer, 
   * an empty string will be returned. 
   *
   * PARAMETERS
   *   data           The input byte arrays in raw. 
   *   src_charset    The source charset raw data is converted from.
   *   scanned_length The scanned byte of input raw data. (OUT)
   *   shift_status   The shift status at the end of this scan. (IN/OUT)
   *                  User must set this variable to be SHIFT_IN the first  
   *                  time it is called in piece wise cnversion.
   * RETURN
   *   The string converted back into national charset encoding. 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  Function raw_to_nchar(data IN RAW,
                        src_charset IN VARCHAR2 DEFAULT NULL,
                        scanned_length OUT PLS_INTEGER,
                        shift_status IN OUT PLS_INTEGER)
                        RETURN NVARCHAR2;

 /**
   * Escape a VARCHAR2/NVARCHAR2 to a character reference represenation
   * Two kinds of characters will be converted
   *   (1) The predefined character which has special meaning
   *       For example,  &, <, > etc.
   *   (2) Multibyte character which can not be converted to 
   *       web page character set
   *   
   * For example, utl_i18n.escape_reference('ab'||chr(170), 'us7ascii')
   *  will return a string 'ab&#xaa;'.
   * If user inputs an invalid character set or an empty string, 
   * an empty string will be returned. 
   *
   * PARAMETERS
   *   str            The input string to escape. 
   *   page_cs_name   The name of webpage encoding character set.
   * RETURN
   *   The string escaped to character reference representation. 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  Function escape_reference(str IN VARCHAR2 CHARACTER SET ANY_CS,
                            page_cs_name IN VARCHAR2 DEFAULT NULL) 
                            RETURN VARCHAR2 CHARACTER SET str%CHARSET;
  

 /**
   * Unescape a VARCHAR2/NVARCHAR2 from character reference represenation
   *   
   * For example, utl_i18n.escape_unreference('ab&#xaa') 
   *  will return a string 'ab'||chr(170).
   * If input is an empty string, an empty string will be returned. 
   *
   * PARAMETERS
   *   str            The input string to unescape. 
   * RETURN
   *   The string unescaped from character reference representation. 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  Function unescape_reference(str IN VARCHAR2 CHARACTER SET ANY_CS)
                             RETURN VARCHAR2 CHARACTER SET str%CHARSET;  
   
  /**
   * Map ORACLE character set name to IANA name and vice versa or map 
   * a generic character set to a MAIL character set. For example,
   * utl_i18n.charset_map('iso-8859-p1',utl_i18n.GENERIC_CONTEXT, 
   * utl_i18n.IANA_TO_ORACLE) will return 'WE8ISO8859P1'. If user 
   * inputs an invalid character set or invalid flag name, an empty
   * string will be returned. If user does not specify the flag, 
   * we will use "ORACLE_TO_IANA" as the default flag. For example,
   * if user does not specify the conversion direction, we will always assume
   * that the current string uses Oracle standard.
   *
   * PARAMETERS
   *   charset  The character set name to map. The mapping is
   *             case-insensitive.
   *   context   GENERIC_CONTEXT - map bewteen ORACLE and IANA
   *             MAIL_CONTEXT    - map bewteen generic character set to  
   *                                 MAIL character set
   *   flag      ORACLE_TO_IANA  - map from ORACLE name to IANA name.
   *             IANA_TO_ORACLE  - map from IANA name to ORACLE name.
   * RETURN
   *   The mapped character set name if a match is found. NULL if no match
   *   is found or the flag is invalid.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  FUNCTION map_charset(charset  IN VARCHAR2,
                       context  IN PLS_INTEGER DEFAULT GENERIC_CONTEXT, 
                       flag     IN PLS_INTEGER DEFAULT ORACLE_TO_IANA)
                    RETURN VARCHAR2;

 /**
   * Get ORACLE langugage name from an isolocale 
   * 
   * For example, utl_i18n.map_language_from_iso('en_US') will return 
   * 'American'.
   * If user inputs an invalid locale string, an empty string will be 
   * returned. 
   *
   * PARAMETERS
   *   isolocale  The iso locale string to map. The mapping is
   *             case-insensitive.
   *             
   * RETURN
   *   The mapped language name if found. NULL if locale is invalid 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
   Function map_language_from_iso(isolocale IN VARCHAR2)
                    RETURN VARCHAR2;
 
 /**
   * Get ORACLE territory name from an isolocale 
   * 
   * For example, utl_i18n.map_territory_from_iso('en_US') will return 
   * 'America'.
   * If user inputs an invalid locale string, an empty string will be 
   * returned. 
   *
   * PARAMETERS
   *   isolocale  The iso locale string to map. The mapping is
   *             case-insensitive.
   *             
   * RETURN
   *   The mapped territory name if found. NULL if locale is invalid 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  Function map_territory_from_iso(isolocale IN VARCHAR2)
                    RETURN VARCHAR2;

 /**
   * Get ISO locale from an oracle language and an oracle territory 
   * 
   * For example, utl_i18n.map_territory_from_iso('American', 'America') 
   * will return 'en_US'.
   * If user inputs an invalid string, an empty string will be returned. 
   *
   * PARAMETERS
   *   ora_language  The ORACLE language string. It is case-insensitive.
   *   ora_territory The ORACLE territory string. It is case-insensitive.
   *             
   * RETURN
   *   The mapped iso locale string if success. NULL if language or 
   *   territory is invalid 
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  Function map_locale_to_iso(ora_language  IN VARCHAR2,
                             ora_territory IN VARCHAR2)
                    RETURN VARCHAR2;

  /**
   * Get default ORACLE character set name from a language for general 
   * cases or only for MAIL application. 
   * 
   * For example, utl_i18n.get_default_charset('French', 
   * utl_i18n.GENERIC_CONTEXT, FALSE) will return 'WE8ISO8859P1'.
   * If user inputs an invalid character set or invalid flag name, 
   * an empty string will be returned. 
   *
   * PARAMETERS
   *   language  The language name to map. The mapping is
   *             case-insensitive.
   *   context   GENERIC_CONTEXT - get default charset for general cases
   *             MAIL_CONTEXT    - get default charset used in MAIL 
   *                               application   
   *   iswindow  When MAIL_CONTEXT is set, the MAIL charset used is different 
   *             in windows platform and other platform. 
   *             If GENERIC_CONTEXT is set, this variable has no effect 
   *             
   * RETURN
   *   The default character set name if a match is found. NULL if no match
   *   is found or the flag is invalid.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  Function get_default_charset(language  IN VARCHAR2,
                               context   IN PLS_INTEGER DEFAULT GENERIC_CONTEXT,
                               iswindows IN BOOLEAN DEFAULT FALSE)
                    RETURN VARCHAR2;


  /**
   * validate oracle object name 
   *
   * PARAMETERS
   *   name  the oracle object name to be validated
   *             
   * RETURN
   *   the index of first invalid character. 
   *   returns 0 if it is a valid SQL name
   * EXCEPTIONS
   *   none
   */

Function VALIDATE_SQLNAME(name VARCHAR2 CHARACTER SET ANY_CS) 
         RETURN PLS_INTEGER;



  /**
   * convert between XML name and SQL identifier.
   * conversion rules are as following:
   *  SQLNAME_TO_XMLTAG:   SQL identifier -> XML name
   *
   *                        A character can be escaped into _xHHHH_ or
   *                        _xHHHHHHHH_, where HHHH is the uppercase hexadecimal
   *                        UCS2 representation of the character if it is in
   *                        the UCS2 range, and HHHHHHHH is the uppercase
   *                        hexadecimal UCS4 representation of the character 
   *                        if it is out of UCS2 range but in UCS4 range.
   *
   *                        The encoding is based on following rules,
   *                        (XML standard 1.0, Second Edition,
   *                         SQL/XML candidate base document, 09-FEB-2001)
   *
   *                        (1) If the 1st character of the SQL identifier is
   *                            not a valid 1st character of XML names, escape 
   *                            it into _xHHHH_ or _xHHHHHHHH_ 
   *                        (2) If the leading three characters are x or X, 
   *                            m or M, l or L, add a leading _xFFFF_ before 
   *                            these three characters
   *                        (3) If a character is ':', escape it to _x003A_
   *                        (4) If it is a '_' followed by a 'x', escape the '_'
   *                            to _x005F_
   *                        (5) If a character is not the 1st character of the
   *                            SQL identifier and it is not a valid XML name
   *                            character, escape it to _xHHHH_ or _xHHHHHHHH_
   *
   * XMLTAG_TO_SQLNAME:   XML name -> SQL identifier
   *
   *                        (1) If the XML name has a leading _xFFFF_, skip it
   *                        (2) convert those escaped characters, which are in
   *                            a format of _xHHHH_ or _xHHHHHHHH_, back into
   *                            its corresponding character encode in the give
   *                            character set
   *
   *
   * PARAMETERS
   *   name    the name to be converted;  
   *   flag    which way the conversion goes
   *           XMLTAG_TO_SQLNAME -- from xml name to sql identifier 
   *           SQLNAME_TO_XMLTAG -- from sql identifier to xml name
   *             
   * RETURN
   *   the converted name       
   * EXCEPTIONS
   *   27102 --  out of memory
   *   1722  --  invalid number, 
   *             cause: during XMLTAG_TO_SQLNAME
   *             the escaping format is invalid
   *             either the number format after _x is not a valid number
   *             or there is no "_" appended after _xHHHH
   */

Function ENCODE_SQL_XML(name VARCHAR2 CHARACTER SET ANY_CS, 
                        flag PLS_INTEGER default XMLTAG_TO_SQLNAME) 
         RETURN VARCHAR2 CHARACTER SET name%CHARSET;





  /**
   *  This function is to perform script transliteration. 
   *  In 10GR2, only supports conversions between 
   *  Japanese Hiragana and Katakana characters 
   *
   * PARAMETERS
   *  data:  the data to be converted. Either CHAR or NCHAR data type 
   *  name:  the transliteration name 
   *
   * RETURNS   
   *  The converted string.
   *
   * EXCEPTIONS
   *  3001:  unsupported feature, 
   *         means the specified transliteration is not supported
   *  27102: out of memory
   */
 

Function  TRANSLITERATE (
  data IN VARCHAR2 CHARACTER SET ANY_CS,  
  name IN VARCHAR2)
RETURN VARCHAR2 CHARACTER SET data%CHARSET;
 


  /**
   * returns the default linguistic sorting name for the specified language
   *
   * PARAMETERS
   *   language the Oracle language name. Case-insensitive
   *
   * RETURN
   *   the default linguistic sorting name. NULL if the given language
   *   is invalid.
   *
   * EXCEPTIONS
   *   none
   */
Function GET_DEFAULT_LINGUISTIC_SORT(
  language IN VARCHAR2 )
RETURN VARCHAR2;

  /**
   * returns the default ISO 4217 currency code for the specified territory
   *
   * PARAMETERS
   *   territory the Oracle territory name. Case-insensitive
   *
   * RETURN
   *   the default ISO 4217 currency code. NULL if the given territory
   *   is invalid.
   *
   * EXCEPTIONS
   *   none
   */
Function GET_DEFAULT_ISO_CURRENCY(
  territory IN VARCHAR2 )
RETURN VARCHAR2;

  /**
   * returns the local linguistic sorting names for the specified language
   *
   * PARAMETERS
   *   language the Oracle language name. Case-insensitive
   *
   * RETURN
   *   the list of local linguistic sorting names. NULL if the given language
   *   is invalid.
   *
   * EXCEPTIONS
   *   none
   */
Function GET_LOCAL_LINGUISTIC_SORTS(
  language IN VARCHAR2 )
RETURN string_array;

  /**
   * returns the local time zone names for the specified territory
   *
   * PARAMETERS
   *   territory the Oracle territory name. Case-insensitive.
   *
   * RETURN
   *   the list of local time zone names. NULL if the given territory
   *   is invalid.
   *
   * EXCEPTIONS
   *   none
   */
Function GET_LOCAL_TIME_ZONES(
  territory IN VARCHAR2 )
RETURN string_array;

  /**
   * returns the common time zone names
   *
   * RETURN
   *   the list of common time zone names
   *
   * EXCEPTIONS
   *   none
   */
Function GET_COMMON_TIME_ZONES
RETURN string_array;

  /**
   * returns the local territory names for the specified language
   *
   * PARAMETERS
   *   language the Oracle language name. Case-insensitive
   *
   * RETURN
   *   the list of local territory names. NULL if the given language is 
   *   invalid.
   *
   * EXCEPTIONS
   *   none
   */
Function GET_LOCAL_TERRITORIES(
  language IN VARCHAR2 )
RETURN string_array;

  /**
   * returns the local language names for the specified territory
   *
   * PARAMETERS
   *   territory the Oracle territory name. Case-insensitive
   *
   * RETURN
   *   the list of local language names. NULL if the given territory is 
   *   invalid.
   *
   * EXCEPTIONS
   *   none
   */
Function GET_LOCAL_LANGUAGES(
  territory IN VARCHAR2 )
RETURN string_array;


  /**
   * maps an Oracle full language name to short language name
   *
   * PARAMETERS
   *   language an Oracle full language name
   *
   * RETURN
   *   the corresponding Oracle short language name
   */
Function MAP_TO_SHORT_LANGUAGE(
  language IN VARCHAR2)
RETURN VARCHAR2;

  /**
   * maps an Oracle short language name and full language name
   *
   * PARAMETERS
   *   language the Oracle short language name
   *
   * RETURN
   *   The corresponding Oracle full language name
   */
Function MAP_FROM_SHORT_LANGUAGE(
  language IN VARCHAR2)
RETURN VARCHAR2;

  /**
   * returns the translation of the language and territory name in the 
   * translation language
   *
   * PARAMETERS
   *   param1    a valid language name, territory name, or combined string
   *             in the form of '<language>_<territory>'. Case-insensitive.
   *   trans_language a translation language name, e.g., ITALIAN for the
   *             Italian translation. The default translation is 'AMERICAN'.
   *   flag      a translation type:
   *           - LANGUAGE_TRANS  - the language translation
   *           - TERRITORY_TRANS - the territory translation
   *           - LANGUAGE_TERRITORY_TRANS - the language and territory
   *                                        translation
   *             the default translation type is LANGUAGE_TRANS
   *
   * RETURN
   *   The translation
   */
Function GET_TRANSLATION(
  param1         IN VARCHAR2 CHARACTER SET ANY_CS,
  trans_language IN VARCHAR2 DEFAULT 'AMERICAN',
  flag           IN PLS_INTEGER DEFAULT LANGUAGE_TRANS)
RETURN VARCHAR2 CHARACTER SET param1%CHARSET;

END utl_i18n;
/
GRANT EXECUTE ON sys.utl_i18n TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_i18n FOR sys.utl_i18n;
