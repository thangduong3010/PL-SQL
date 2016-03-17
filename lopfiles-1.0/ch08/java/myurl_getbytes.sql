REM $Id: myurl_getbytes.sql,v 1.1 2001/11/30 23:25:42 bill Exp $
REM From "Learning Oracle PL/SQL" page 298

REM Create PL/SQL "cover" procedure for a Java program

CREATE OR REPLACE PROCEDURE myurl_getbytes (url IN VARCHAR2,
   maxbytes IN NUMBER, bytesout OUT RAW, bytecount OUT NUMBER)
AS LANGUAGE JAVA
   NAME 'myURL.getBytes(java.lang.String, int, byte[][], int[])';
/

SHOW ERRORS

