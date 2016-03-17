REM $Id: webu.pkb,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 9

REM Body of ch09's version of web utilities (webu), which adds security
REM features

SET DEFINE OFF
CREATE OR REPLACE PACKAGE BODY webu AS

   FUNCTION mon_option_list(selected_mon IN VARCHAR2)
      RETURN VARCHAR2
   IS
      seltext VARCHAR2(10);
      list VARCHAR2(512) := '<OPTION value="">(Mon)';
      selected_month_index PLS_INTEGER;
      mon VARCHAR2(3);
   BEGIN

      BEGIN
         selected_month_index :=
            TO_CHAR(TO_DATE(UPPER(selected_mon), 'MON'), 'MM');
      EXCEPTION
      WHEN OTHERS THEN
         selected_month_index := 1;
      END;
 
      FOR mo_num IN 1..12
      LOOP
         IF selected_month_index = mo_num
         THEN
            seltext := ' SELECTED ';
         ELSE
            seltext := ' ';
         END IF;
         mon := TO_CHAR(TO_DATE(mo_num, 'MM'),'MON');
         list := list || '<OPTION' || seltext || 'value="' || mon
            || '">' || INITCAP(mon) || lopu.linefeed;
      END LOOP;

      RETURN list;
   END;
      
   FUNCTION dd_option_list(selected_dd IN VARCHAR2)
      RETURN VARCHAR2
   IS
      seltext VARCHAR2(10);
      list VARCHAR2(768) := '<OPTION value="">(day)';
      selected_integer PLS_INTEGER;
   BEGIN

      BEGIN
         selected_integer := TO_NUMBER(selected_dd);
      EXCEPTION
         WHEN OTHERS
         THEN
            selected_integer := 1;
      END;

      FOR dd_num IN 1..31
      LOOP
         IF selected_integer = dd_num
         THEN
            seltext := ' SELECTED ';
         ELSE
            seltext := ' ';
         END IF;
         list := list || '<OPTION' || seltext || 'value="' ||
            TO_CHAR(dd_num, 'FM09') || '">' || TO_CHAR(dd_num) || lopu.linefeed;
      END LOOP;

      RETURN list;
   END;

   FUNCTION esc_text(text IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN REPLACE(REPLACE(text, CHR(10), '<BR>'),' ','&nbsp;');
   END;

   FUNCTION errfont(text IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN ('<FONT color="red">' || text || '</FONT>');
   END;

   PROCEDURE printerr(text IN VARCHAR2)
   IS
   BEGIN
      HTP.P('<P>' || errfont(HTF.ESCAPE_SC(text)) || '</P>');
   END;

   PROCEDURE printinfo(text IN VARCHAR2)
   IS
   BEGIN
      HTP.P('<P><I><FONT color="green">'
            || HTF.ESCAPE_SC(text)
            || '</FONT></I></P>');
   END;

   PROCEDURE redirect (url_in IN VARCHAR2)
   IS
      token VARCHAR2(1);
   BEGIN
      IF url_in IS NULL
      THEN
         RETURN;
      ELSE
         OWA_UTIL.REDIRECT_URL(url_in);

         /* Alternate method -- potentially less secure?
         | HTP.INIT;
         | EXECUTE IMMEDIATE 'BEGIN ' 
         |  || destination_ ');'
         |  || 'END;';
         */
      END IF;
   END redirect;

   PROCEDURE refresh (url_in IN VARCHAR2,
      body_text IN VARCHAR2,
      delay_seconds IN PLS_INTEGER DEFAULT 5)
   IS
   BEGIN
      HTP.INIT;
      HTP.P('<HTML>
         <HEAD>
            <META http-equiv="refresh" content="'
               || delay_seconds
               || ';URL=' || url_in || '">' || '
            <TITLE>Sorry</TITLE>
         </HEAD>
      <BODY>');
      HTP.P(body_text);
      HTP.P('</BODY>
         </HTML>
         ');
   END refresh;

END;
/

SHOW ERRORS
SET DEFINE ON

