REM $Id: show_time.p122.pro,v 1.1 2001/11/30 23:10:38 bill Exp $
REM From "Learning Oracle PL/SQL" page 122

REM Another ugly way to generate HTML from PL/SQL

CREATE OR REPLACE PROCEDURE show_time
AS
   the_title VARCHAR2(30) := 'What time is it on the server?';
   the_time VARCHAR2(20) := TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI');
   html VARCHAR2(200);
BEGIN
   /* construct the HTML in a variable
   */
   html := 
'<HTML>
   <HEAD>
      <TITLE>' || the_title || '</TITLE>
   </HEAD>
   <BODY>
      It is now: ' || the_time ||
   '</BODY>
</HTML>';

   /* output to the browser
   */
   HTP.PRINT(html);
END;
/

SHOW ERRORS

