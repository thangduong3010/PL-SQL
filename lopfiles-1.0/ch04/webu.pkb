REM $Id: webu.pkb,v 1.1 2001/11/30 23:20:19 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 4

REM Final version of body of general-purpose web utilities package as implied
REM by Chapter 4

CREATE OR REPLACE PACKAGE BODY webu AS

   FUNCTION errfont(text IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN ('<FONT color="red">' || text || '</FONT>');
   END;

   FUNCTION mon_option_list(selected_mon IN VARCHAR2)
      RETURN VARCHAR2
   IS
      seltext VARCHAR2(10);
      list VARCHAR2(512) := '<OPTION value="">(Mon)' || lopu.linefeed;
      selected_month_index PLS_INTEGER;
      mon VARCHAR2(3);
   BEGIN

      BEGIN
         selected_month_index :=
            TO_CHAR(TO_DATE(UPPER(selected_mon), 'MON'), 'MM');
      EXCEPTION
      WHEN OTHERS THEN
         NULL;
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

END webu;
/

SHOW ERRORS

