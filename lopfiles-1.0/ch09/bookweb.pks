REM $Id: bookweb.pks,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page Chapter 9

REM Spec of ch09's version bookweb package which adds security features
REM to the version in ch04

CREATE OR REPLACE PACKAGE bookweb
AS
   msg VARCHAR2(128);

   TYPE flatbook_t IS RECORD (
      isbn books.isbn%TYPE,
      title books.title%TYPE,
      author books.author%TYPE,
      page_count books.page_count%TYPE,
      page_count_str VARCHAR2(40),
      summary books.summary%TYPE,
      date_published books.date_published%TYPE,
      yyyy_published VARCHAR2(4),
      mon_published VARCHAR2(3),
      dd_published VARCHAR2(2),
      isbn_msg msg%TYPE,
      title_msg msg%TYPE,
      author_msg msg%TYPE,
      page_count_msg msg%TYPE,
      summary_msg msg%TYPE,
      date_published_msg msg%TYPE,
      action_msg msg%TYPE,
      passes lopu.sqlboolean
   );

   FUNCTION process_edits (
      session_id IN VARCHAR2,
      skip IN VARCHAR2 DEFAULT NULL,
      submit IN VARCHAR2,
      isbn IN VARCHAR2, 
      title IN VARCHAR2,
      author IN VARCHAR2,
      page_count IN VARCHAR2,
      summary IN VARCHAR2,
      yyyy_published IN VARCHAR2,
      mon_published IN VARCHAR2,
      dd_published IN VARCHAR2,
      new_barcodes_arr IN OWA_UTIL.IDENT_ARR,
      delete_copies_arr IN OWA_UTIL.IDENT_ARR
      )
   RETURN flatbook_t;

END bookweb;
/

SHOW ERRORS

