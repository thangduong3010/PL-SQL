Rem
Rem $Header: dbmsxmls.sql 18-dec-2006.13:51:20 ataracha Exp $
Rem
Rem dbmsxmls.sql
Rem
Rem Copyright (c) 2005, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsxmls.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ataracha    12/18/06 - add isnull methods
Rem    smalde      04/24/06 - 
Rem    nkhandel    02/20/06 - DOM streaming API 
Rem    nkhandel    02/20/06 - DOM streaming API 
Rem    nitgupta    05/23/05 - Created
Rem

--------------------------------------------------------------------------
-- XMLBinaryInputStream is an extension of utl_BinaryInputStream and
-- is similar to java.io.InputStream: can only read bytes and close stream
--------------------------------------------------------------------------
create or replace type XMLBinaryInputStream under utl_BinaryInputStream 
(
  constructor function XMLBinaryInputStream (h in raw, n in raw)
  return self as result,
  overriding member function available (self in out nocopy XMLBinaryInputStream)
  return integer,
  ---- this function returns the number of characters that remain to be read.
  overriding member function read (self in out nocopy XMLBinaryInputStream,
                                   numBytes in integer default 1)
  return raw,
  ---- this function reads the number of bytes specified by numBytes 
  ---- (default is 1) and returns the bytes as a raw.If there are no remaining 
  ---- bytes a value of null is returned
  overriding member procedure read (self in out nocopy  XMLBinaryInputStream,
                                    bytes    in out nocopy raw,
                                    numBytes in out integer),
  ---- this procedure reads the number of bytes specified in numBytes into 
  ---- the parameter bytes. Additionally, the actual number of bytes read is 
  ---- returned in parameter numBytes. If this parameter
  ---- is set to 0 then there are no more bytes to be read.
  overriding member procedure read (self in out nocopy  XMLBinaryInputStream,
 		                    bytes  in out nocopy raw,
                                    offset in     integer,
                                    numBytes in out integer),
  ---- this procedure reads the number of bytes specified in numBytes into 
  ---- the parameter bytes,beginning at the offset specified by parameter offset. 
  ---- The actual number of bytes read is returned in parameter numBytes. If this 
  ---- value is 0, then there are no additional bytes to be read.
  overriding member procedure close (self in out nocopy XMLBinaryInputStream),
   ---- this procedure releases all resources held on the node to support the stream. 
  overriding member function isnull (self in out nocopy XMLBinaryInputStream)
                                        return boolean 
);
/

--------------------------------------------------------------------------
-- XMLBinaryOutputStream is an extension of utl_BinaryOutputStream and
-- is similar to java.io.OutputStream: can only write bytes, flush 
-- and close stream
-------------------------------------------------------------------------
create or replace type XMLBinaryOutputStream under utl_BinaryOutputStream 
(
  constructor function XMLBinaryOutputStream (h in raw, n in raw)
  return self as result,
  overriding member function write (self   in out nocopy XMLBinaryOutputStream,
                             	    bytes  in out nocopy raw,
                                    numBytes in integer default 1) 
  return integer,
  ---- this function writes the number of bytes specified by the parameter numBytes 
  ----(default is 1) from parameter bytes into the stream. The actual number of 
  ---- bytes written is returned.
  overriding member procedure write (self  in out nocopy XMLBinaryOutputStream,
                                     bytes in out nocopy raw,                  
      		                     numBytes in out integer),
   ---- this procedure writes the number of bytes specified in parameter numBytes 
   ---- from parameter bytes to the stream. The actual number of bytes written is 
   ---- returned in parameter numBytes.
   overriding member procedure write (self   in out nocopy XMLBinaryOutputStream,
                                      bytes  in out nocopy raw,
  	                              offset in integer,
                                      numBytes in out integer), 
  ---- this procedure the number of bytes specified by numBytes to the stream, 
  ---- beginning at the offset specified by parameter offset.
  ---- The actual number of bytes written is returned in parameter numBytes
  overriding member procedure flush (self in out nocopy XMLBinaryOutputStream),
  ---- this procedure insures that any buffered bytes are copied to the 
  ----node destination. 
  Overriding member procedure close (self in out nocopy XMLBinaryOutputStream),
  ---- this procedure frees all resources associated with the stream. 
  overriding member function isnull (self in out nocopy XMLBinaryOutputStream)
                                        return boolean
);
/

------------------------------------------------------------------------
-- XMLCharacterInputStream is an extension of sys.utl_CharacterInputStream and
-- is similar to java.io.Reader: can only read chars and close stream
-------------------------------------------------------------------------
create or replace type XMLCharacterInputStream under utl_CharacterInputStream 
(
  constructor function XMLCharacterInputStream (h in raw, n in raw)
  return self as result,

  overriding member function available (self in out nocopy XMLCharacterInputStream)
  return integer,
  ---- this function returns the number of characters remaining to be read.
  overriding member function read (self in out nocopy XMLCharacterInputStream,
                                   numChars in integer default 1,
                                   lineFeed in boolean default false) 
   return varchar2,
  ---- this function reads the number of characters specified by numChars 
  ---- (default is 1) and returns as a varchar2. If there are no remaining characters 
  ---- a value of null is returned. If the value of lineFeed is true 
  ---- (default is false) then the reading terminates if a linefeed character is
  ----- encountered.
  overriding member procedure read (self     in out nocopy  XMLCharacterInputStream,
                                    chars    in out nocopy varchar2,
                                    numChars in out integer,
                                    lineFeed in boolean default false),
  ---- this procedure reads the number of characters specified by parameter numChars 
  ---- into the parameter chars. Additionally, the actual number of characters read 
  ---- is returned in parameter numChars. If this value is 0, then there are no more 
  ---- characters to be read. If the value of lineFed is true (default is false), 
  ---- then reading is terminated if a linefeed character is found.
  overriding member procedure read (self   in out nocopy XMLCharacterInputStream,
                                    chars  in out nocopy varchar2,
                                    offset in     integer,
                                    numChars in out integer,
                                    lineFeed in boolean default false),
  ---- this procedure reads the number of characters specified by parameter numChars 
  ---- into the parameter specified by chars, beginning at the offset specified by 
  ---- offset. The actual number of characters read is returned in parameter 
  ---- numChars. If this value is 0, there are no more characters to be read. 
  ---- If the value of lineFeed is true (default is false), then
  ---- reading is terminated if a lineFeed character is found.
  overriding member procedure close (self in out XMLCharacterInputStream),
   ---- this procedre releases all resources held by the stream.
  overriding member function isnull (self in out nocopy XMLCharacterInputStream)
                                        return boolean 
);
/


--------------------------------------------------------------------------
-- XMLCharacterOutputStream is an extension of sys.utl_CharacterOutputStream and
-- is similar to java.io.Writer: can only write chars, flush and close stream
-------------------------------------------------------------------------
create or replace type XMLCharacterOutputStream under utl_CharacterOutputStream 
(
  constructor function XMLCharacterOutputStream (h in raw, n in raw)
  return self as result,
  overriding member function write (self in out nocopy XMLCharacterOutputStream,
                                    chars   in out nocopy varchar2,
                                    numChars in integer default 1,
                                    lineFeed in boolean default false) 
  return integer,
  ---- this function writes the number of characters specified by numChars 
  ---- (default is 1) to the stream and returns the actual number of characters 
  ---- written. If the value of lineFeed is true (default is false), then a lineFeed 
  ---- character is appended after the last character.
  overriding member procedure write (self  in out nocopy XMLCharacterOutputStream,
                                     chars in out nocopy varchar2,
                                     numChars in out integer,
                                     lineFeed in boolean default false),
  ---- this procedure writes the number of characters specified by parameter 
  ---- numChars, from parameter chars into the stream. The actual number of 
  ---- characters written is returned in parameter numChars. If the value of lineFeed 
  ---- is true (default is false) then a lineFeed character is appended after the 
  ---- last character.
  overriding member procedure write (self  in out nocopy    XMLCharacterOutputStream,
                                     chars    in  out nocopy   varchar2,
                                     offset   in     integer,
                                     numChars in out integer,
                                     lineFeed in boolean default false),
  ---- this procedure writes the number of characters specified by parameter numChars,
  ---- from parameter chars, beginning at offset specified by parameter offset. 
  ---- The actual number of characters written is returned in parameter numChars. 
  ---- If the value of lineFeed is true (default is true), then a linefeed character 
  ---- is appended after the last character.
  overriding member procedure flush (self in out nocopy XMLCharacterOutputStream),
  ---- this procedure copies all characters that may be contained within buffers 
  ---- to the node value.
  overriding member procedure close (self in out nocopy XMLCharacterOutputStream) ,
  ---- this procedure releases all resources associated with the stream. 
  overriding member function isnull (self in out nocopy XMLCharacterOutputStream)
                                        return boolean
);
/

grant execute on XMLBinaryInputStream to PUBLIC with grant option;
grant execute on XMLBinaryOutputStream to PUBLIC with grant option;
grant execute on XMLCharacterInputStream to PUBLIC with grant option;
grant execute on XMLCharacterOutputStream to PUBLIC with grant option;

create public synonym XMLBinaryInputStream for sys.XMLBinaryInputStream;
create public synonym XMLBinaryOutputStream for sys.XMLBinaryOutputStream;
create public synonym XMLCharacterInputStream for sys.XMLCharacterInputStream;
create public synonym XMLCharacterOutputStream for sys.XMLCharacterOutputStream;
