REM $Id: demo.sql,v 1.1 2001/11/30 23:25:42 bill Exp $
REM From "Learning Oracle PL/SQL" page 298

REM Simple demo of how to call PL/SQL "cover" of the Java method myURL.getBytes

PROMPT Attempting to retrieve a small gif image from the author's web site...

DECLARE
   x RAW(32767);
   l NUMBER;
BEGIN
   myurl_getbytes(url => 'http://www.datacraft.com/images/DataCraft-word.gif',
                       maxbytes => 32767,
                       bytesout => x,
                       bytecount => l);
   DBMS_OUTPUT.PUT_LINE('Length returned is ' || l);
END;
/

