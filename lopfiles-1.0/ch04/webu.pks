REM $Id: webu.pks,v 1.1 2001/11/30 23:20:19 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 4

REM Final version of spec of general-purpose web utilities package as implied
REM by Chapter 4

CREATE OR REPLACE PACKAGE webu AS

   save_c CONSTANT CHAR(5) := 'Save';

   FUNCTION errfont (text IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION mon_option_list(selected_mon IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION dd_option_list(selected_dd IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

END webu;
/

SHOW ERRORS

