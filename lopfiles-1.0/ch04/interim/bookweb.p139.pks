REM $Id: bookweb.p139.pks,v 1.1 2001/11/30 23:10:38 bill Exp $
REM From "Learning Oracle PL/SQL" page 139

REM Spec of first version of bookweb package, which contains the support
REM logic behind the user interface

CREATE OR REPLACE PACKAGE bookweb
AS
   SUBTYPE msg_t IS VARCHAR2(128);

   TYPE bookrec_t IS RECORD (
      isbn books.isbn%TYPE,
      title books.title%TYPE,
      author books.author%TYPE,
      page_count books.page_count%TYPE,
      page_count_str VARCHAR2(40),
      summary books.summary%TYPE,
      date_published books.date_published%TYPE,
      date_published_str VARCHAR2(40),
      barcode_id VARCHAR2(40),
      isbn_msg msg_t,
      title_msg msg_t,
      author_msg msg_t,
      page_count_msg msg_t,
      summary_msg msg_t,
      date_published_msg msg_t,
      barcode_id_msg msg_t,
      action_msg msg_t,
      passes lopu.sqlboolean
   );

   FUNCTION process_edits (
      submit IN VARCHAR2,
      isbn IN VARCHAR2, 
      title IN VARCHAR2,
      author IN VARCHAR2,
      page_count IN VARCHAR2,
      summary IN VARCHAR2,
      date_published IN VARCHAR2,
      barcode_id IN VARCHAR2
      )
   RETURN bookrec_t;

END bookweb;
/

SHOW ERRORS

