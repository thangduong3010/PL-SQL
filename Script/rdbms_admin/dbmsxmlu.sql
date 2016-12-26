Rem
Rem $Header: rdbms/admin/dbmsxmlu.sql /main/3 2009/05/05 15:39:27 bkhaladk Exp $
Rem
Rem dbmsxmlu.sql
Rem
Rem Copyright (c) 2005, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxmlu.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bkhaladk    04/02/09 - remove under privilege on types
Rem    ataracha    12/18/06 - add isnull method
Rem    smalde      04/24/06 - 
Rem    nkhandel    02/20/06 - DOM streaming API 
Rem    nkhandel    02/20/06 - DOM streaming API 
Rem    nkhandel    01/18/06 - 
Rem    nitgupta    05/23/05 - Created
Rem



--------------------------------------------------------------------------
-- Utl_BinaryInputStream is similar to java.io.InputStream: can only read
-- and close stream
--------------------------------------------------------------------------
create or replace type utl_BinaryInputStream authid current_user as object 
(
  handle raw(12),
  member function available (self in out nocopy Utl_BinaryInputStream) 
  return integer,
  -- this function returns the number of bytes available to be read
  member function read (self in out nocopy Utl_BinaryInputStream,
                        numBytes in integer default 1)  
  return raw,
  ---- this function reads the number of bytes specified by numBytes 
  ---- (default is 1) and returns the bytes as a raw. If there are no remaining
  ---- bytes a value of null is returned.
  member procedure read (self     in  out   nocopy Utl_BinaryInputStream, 
   	                 bytes   in out nocopy raw, 
                       	 numBytes in out integer),
  ---- this procedure reads the number of bytes specified in numBytes into 
  ---- the parameter bytes. Additionally, the actual number of bytes read 
  ---- is returned in parameter numBytes. If this parameter
  ---- is set to 0 then there are no more bytes to be read.
  member procedure read (self     in    out  nocopy Utl_BinaryInputStream, 
                         bytes   in out nocopy raw,
                         offset   in integer, 
                         numBytes  in out integer),
   ---- this procedure reads the number of bytes specified in numBytes into 
   ---- the parameter bytes, beginning at the offset specified by parameter 
   ---- offset. The actual number of bytes read is returned in parameter 
   ---- numBytes. If this value is 0, then there are no additional bytes to
   ---- be read.
   member procedure close (self in out nocopy Utl_BinaryInputStream),
   ---- this function releases all resources held on the node to support 
   ---- the stream. 
   member function isnull (self in out nocopy Utl_BinaryInputStream)
                                        return boolean 
) NOT INSTANTIABLE NOT FINAL;
/


--------------------------------------------------------------------------
-- Utl_BinaryOutputStream is similar to java.io.OutputStream: can only write
-- bytes and close stream
--------------------------------------------------------------------------
create or replace type utl_BinaryOutputStream authid current_user as object 
(
  handle raw(12),
  member function write (self in out nocopy utl_BinaryOutputStream, 
                         bytes   in out nocopy raw,
                         numBytes in integer default 1) 
  return integer,
  ---- this function writes the number of bytes specified by numBytes  
  ---- (default is 1) from raw
  ---- into the stream. The actual number of bytes written is returned.
  member procedure write (self  in out nocopy utl_BinaryOutputStream,  
                          bytes in out nocopy raw,
               	          numBytes in out integer),
   ---- this procedure writes the number of bytes specified in parameter 
   ---- numBytes from parameter bytes to the stream. The actual number of 
   ---- bytes written is returned in parameter numBytes.
  member procedure write (self   in out nocopy utl_BinaryOutputStream, 
                          bytes  in out nocopy raw, 
                          offset in integer,
                          numBytes in out integer),
  ---- this procedure writes the number of bytes specified by numBytes to the 
  ---- stream, beginning at the offset specified by parameter offset.
  ---- The actual number of bytes written is returned in parameter numBytes.
  member procedure flush (self in out nocopy utl_BinaryOutputStream),
  ---- this procedure insures that any buffered bytes are copied to the node 
  ---- destination. 
  member procedure close (self in out nocopy utl_BinaryOutputStream),
   ---- this procedure frees all resources associated with the stream. 
  member function isnull (self in out nocopy Utl_BinaryOutputStream)
                                        return boolean
) NOT INSTANTIABLE NOT FINAL;
/


-------------------------------------------------------------------------
-- utl_CharacterInputStream is similar to java.io.Reader: can only read
-- chars and close stream
--------------------------------------------------------------------------
create or replace type utl_CharacterInputStream authid current_user as object 
(
  handle raw(12),
  member function available (self in out nocopy utl_CharacterInputStream) 
                             return integer,
   ---- this function returns the number of characters remaining to be read.
  member function read (self in out nocopy utl_CharacterInputStream,
                        numChars in integer default 1,
                        lineFeed in boolean default false) 
  return varchar2,
   ---- This function reads the number of characters specified by numChars 
   ---- (default value is 1) and returns the characters as a varchar2. If the 
   ---- value of lineFeed is true (default value is false) then the reading 
   ---- stops if a linefeed character is found.  If there are no remaining 
   ----characters a value of null is returned.
  member procedure read (self     in  out nocopy utl_CharacterInputStream, 
                         chars    in out nocopy varchar2, 
                         numChars in out integer,
                         lineFeed in boolean default false),
   ---- this procedure reads the number of characters specified by parameter 
   ---- numChars into the parameter chars. Additionally, the actual number of 
   ---- characters read is returned in parameter numChars. If this value is 0, 
   ---- then there are no more characters to be read.
   ---- If the value of lineFeed is true (default is false), then reading stops
   ---- if a linefeed character is encountered. 
  member procedure read (self   in  out nocopy    utl_CharacterInputStream, 
                         chars  in out nocopy varchar2, 
                         offset in     integer, 
                         numChars in out integer,
                         lineFeed in boolean default false),
   ---- this procedure reads the number of characters specified by parameter 
   ---- numChars into the parameter specified by chars, beginning at the offset
   ---- specified by offset. The actual number of characters read is returned 
   ---- in parameter numChars. If this value is 0, there are no more characters
   ---- to be read. If the value of lineFeed is true (default is false) then
   ---- reading stops if a lineFeed character is read.
  member procedure close (self in out nocopy utl_CharacterInputStream),
   ---- this procedure releases all resources held by the stream.
  member function isnull (self in out nocopy Utl_CharacterInputStream)
                                        return boolean
) NOT INSTANTIABLE NOT FINAL;
/

--------------------------------------------------------------------------
-- utl_CharacterOutputStream is similar to java.io.Writer: can only write
-- chars, flush and close stream
--------------------------------------------------------------------------
create or replace type utl_CharacterOutputStream authid current_user as object 
(
  handle raw(12),
  member function write (self in out nocopy  utl_CharacterOutputStream, 
                         chars in out nocopy varchar2,
                         numChars in integer default 1,
                         lineFeed in boolean default false) 
  return integer,
  ---- this function writes the number of characters specified by numChars 
  ----(default is 1) from parameter chars into the stream and returns the 
  ---- actual number of characters written. If the value of lineFeed is
  ---- true (default is false) a lineFeed character is inserted after the 
  ---- last character.
  member procedure write (self  in out nocopy utl_CharacterOutputStream,  
                          chars in out nocopy varchar2,
                          numChars in out integer,
                          lineFeed in boolean default false),
  ----- this procedure writes the number of characters specified by parameter 
  ----- numChars, from parameter chars into the stream. The actual number 
  ----- of characters written is returned in parameter numChars. If the value
  ----- of lineFeed is true (default is false) a lineFeed character is 
  ----- inserted after the last character.
  member procedure write (self     in out nocopy    utl_CharacterOutputStream, 
                  	  chars    in out nocopy    varchar2,
                          offset   in     integer, 
                          numChars in out integer,
                          lineFeed in boolean default false),
  ---- this function writes the number of characters specified by parameter 
  ---- numChars, from parameter chars, beginning at offset specified by 
  ---- parameter offset. The actual number of characters written is returned 
  ---- in parameter numChars. If the value of lineFeed is true (default is 
  ---- false) a lineFeed character is  inserted after the last character 
  member procedure flush (self in out nocopy utl_CharacterOutputStream), 
  ---- this procedure copies all characters that may be contained within 
  ----buffers to the node value.
  member procedure close (self in out nocopy utl_CharacterOutputStream),
   ---- this procedure releases all resources associated with the stream. 
  member function isnull (self in out nocopy Utl_CharacterOutputStream)
                                        return boolean 
) NOT INSTANTIABLE NOT FINAL;
/


grant execute on utl_BinaryInputStream to PUBLIC with grant option;
grant execute on utl_BinaryOutputStream to PUBLIC with grant option;
grant execute on utl_CharacterInputStream to PUBLIC with grant option;
grant execute on utl_CharacterOutputStream to PUBLIC with grant option;

create public synonym utl_BinaryInputStream for sys.utl_BinaryInputStream;
create public synonym utl_BinaryOutputStream for sys.utl_BinaryOutputStream;
create public synonym utl_CharacterInputStream for sys.utl_CharacterInputStream;
create public synonym utl_CharacterOutputStream for sys.utl_CharacterOutputStream;
