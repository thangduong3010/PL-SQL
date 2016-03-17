REM $Id: show_time.p119.pro,v 1.1 2001/11/30 23:10:38 bill Exp $
REM From "Learning Oracle PL/SQL" page 119

REM One ugly way to generate HTML from PL/SQL: assemble in a long string

CREATE OR REPLACE PROCEDURE show_time
AS
   the_title VARCHAR2(30) := 'What time is it on the server?';
   the_time VARCHAR2(20) := TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI');
   html VARCHAR2(200);
BEGIN
   /* construct the begining of a string containing the page's HTML */
   html := '<HTML><HEAD><TITLE>'
      || the_title
      || '</TITLE></HEAD><BODY>';

   /* append the HTML string with the date and time */
   html := html || 'It is now: ' || the_time;

   /* append the HTML string with closing tags */
   html := html || '</BODY></HTML>';

   /* output the HTML string through the web server */
   HTP.PRINT(html);

END;
/

SHOW ERRORS

