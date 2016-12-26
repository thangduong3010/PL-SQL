Rem
Rem $Header: utlgdk.sql 26-jan-2002.11:44:18 rpang Exp $
Rem
Rem utlgdk.sql
Rem
Rem Copyright (c) 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      utlgdk.sql - Globalization Development Kit
Rem
Rem    DESCRIPTION
Rem      Routines for Globalization
Rem
Rem    NOTES
Rem      The procedural option is needed to use this package.
Rem      This package must be created under SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       01/26/02 - Merged rpang_bug-1367542
Rem    rpang       01/12/02 - Created
Rem

CREATE OR REPLACE PACKAGE utl_gdk AS

  /* GDK (Globalization Developer's Kit) is a set of services that can help
   * monolingual application developer to create similar multilingual
   * application with minimal knowledge about internationalization issues.
   * GDK includes two major components, internet globalization services and
   * Oracle globalization services. Internet global services can hide the
   * complexity of globalization to support multi-user with different locale.
   * Oracle globalization services provide developer a set of consistent,
   * high performance and easy to use tools in middle-tier as database client.
   */

  /* Miscellaneous flags used by the locale-mapping API */
  ORACLE_TO_IANA    CONSTANT PLS_INTEGER := 1;
  IANA_TO_ORACLE    CONSTANT PLS_INTEGER := 2;
  ORACLE_TO_ISO     CONSTANT PLS_INTEGER := 3;
  ISO_TO_ORACLE     CONSTANT PLS_INTEGER := 4;
  ORACLE_TO_ISO_A3  CONSTANT PLS_INTEGER := 5;
  ISO_A3_TO_ORACLE  CONSTANT PLS_INTEGER := 6;

  /**
   * Map ORACLE character set name to IANA name and vice versa. For example,
   * utl_gdk.charset_map('iso-8859-p1', utl_gdk.IANA_TO_ORACLE) will return
   * 'WE8ISO8859P1'. If user inputs an invalid character set or invalid flag
   * name, an empty string will be returned. If user does not specify the
   * flag, we will use "ORACLE_TO_IANA" as the default flag. For example,
   * if user does not specify the conversion direction, we will always assume
   * that the current string uses Oracle standard.
   *
   * PARAMETERS
   *   charset   The character set name to map. The mapping is
   *             case-insensitive.
   *   flag      ORACLE_TO_IANA - map from ORACLE name to IANA name.
   *             IANA_TO_ORACLE - map from IANA name to ORACLE name.
   * RETURN
   *   The mapped character set name if a match is found. NULL if no match
   *   is found or the flag is invalid.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  FUNCTION charset_map(charset IN VARCHAR2,
                       flag    IN PLS_INTEGER DEFAULT ORACLE_TO_IANA)
                       RETURN VARCHAR2;

  /**
   * Map between ORACLE language name and ISO language name. For example,
   * utl_gdk.language_map('english', utl_gdk.ORACLE_TO_ISO) will return "en".
   * If user input is invalid, a null string will be returned. If user does
   * not give any flag, ORACLE_TO_ISO will be the default flag.
   *
   * PARAMETERS
   *   language  The language name to map. The mapping is case-insensitive.
   *   flag      ORACLE_TO_ISO - map from ORACLE name to ISO name.
   *             ISO_TO_ORACLE - map from ISO name to ORACLE name.
   * RETURN
   *   The mapped language name if a match is found. NULL if no match
   *   is found or the flag is invalid.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  FUNCTION language_map(language IN VARCHAR2,
                        flag     IN PLS_INTEGER DEFAULT ORACLE_TO_ISO)
                        RETURN VARCHAR2;

  /**
   * Map between ORACLE territory name and ISO A-2 or A-3 territory name.
   * The difference of ISO A-2 and A-3 is that the later uses 3 characters to
   * represent a territory instead of 2 characters. For example,
   * utl_gdk.territory_map('US', utl_gdk.ISO_TO_ORACLE) will return "America"
   * and utl_gdk.territory_map('usa', ISO_A3_TO_ORACLE) will return "America"
   * as well. If user input is invalid, a null string will be returned.
   * If user does not give any flag, ORACLE_TO_ISO will be the default flag.
   *
   * PARAMETERS
   *   territory The territory name to map. The mapping is case-insensitive.
   *   flag      ORACLE_TO_ISO    - map from ORACLE name to ISO A-2 name.
   *             ISO_TO_ORACLE    - map from ISO A-2 name to ORACLE name.
   *             ORACLE_TO_ISO_A3 - map from ORACLE name to ISO A-3 name.
   *             ISO_A3_TO_ORACLE - map from ISO A-3 name to ORACLE name.
   * RETURN
   *   The mapped territory name if a match is found. NULL if no match
   *   is found or the flag is invalid.
   * EXCEPTIONS
   *   miscellaneous runtime exceptions.
   */
  FUNCTION territory_map(territory IN VARCHAR2,
                         flag      IN PLS_INTEGER DEFAULT ORACLE_TO_ISO)
                         RETURN VARCHAR2;

END utl_gdk;
/
GRANT EXECUTE ON sys.utl_gdk TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM utl_gdk FOR sys.utl_gdk;
