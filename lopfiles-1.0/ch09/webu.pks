REM $Id: webu.pks,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 9

REM Spec of ch09's version of web utilities (webu), which adds security
REM features

CREATE OR REPLACE PACKAGE webu AS

   empty_ident_arr owa_util.ident_arr;

   save_c CONSTANT CHAR(5) := 'Save';
   delete_c CONSTANT CHAR(6) := 'Delete';
   add_c CONSTANT CHAR(3) := 'Add';
   edit_c CONSTANT CHAR(7) := 'Edit...';
   view_c CONSTANT CHAR(7) := 'View...';
   qnew_c CONSTANT CHAR(12) := 'Query new...';
   new_search_c CONSTANT CHAR(13) := 'New Search...';

   FUNCTION mon_option_list(selected_mon IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION dd_option_list(selected_dd IN VARCHAR2 DEFAULT NULL)
      RETURN VARCHAR2;

   FUNCTION esc_text(text IN VARCHAR2)
      RETURN VARCHAR2;

   FUNCTION errfont (text IN VARCHAR2)
      RETURN VARCHAR2;

   PROCEDURE printerr(text IN VARCHAR2);

   PROCEDURE printinfo(text IN VARCHAR2);

   PROCEDURE redirect (url_in IN VARCHAR2 DEFAULT NULL);

   PROCEDURE refresh (url_in IN VARCHAR2,
      body_text IN VARCHAR2,
      delay_seconds IN PLS_INTEGER DEFAULT 5);

END;
/

SHOW ERRORS

