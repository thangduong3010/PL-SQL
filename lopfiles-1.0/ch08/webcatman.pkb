REM $Id$
REM From "Learning Oracle PL/SQL" page 291

REM Body of package that will fetch data from Library of Congress

REM Supposedly SET SCAN OFF is deprecated, we are supposed to use SET DEFINE OFF
REM instead

SET DEFINE OFF

CREATE OR REPLACE PACKAGE BODY webcatman
AS
   session_id_l VARCHAR2(64);
   cannot_get_session_id EXCEPTION;

   FUNCTION session_id
   RETURN VARCHAR2
   IS
      page_pieces UTL_HTTP.HTML_PIECES;
      components OWA_TEXT.VC_ARR;
      bigpage VARCHAR2(32767);
   BEGIN
      IF session_id_l IS NULL
      THEN
         page_pieces := UTL_HTTP.REQUEST_PIECES(webcatman.url_to_init);

         FOR piecenum IN page_pieces.FIRST..page_pieces.LAST
         LOOP
            bigpage := SUBSTR(bigpage || page_pieces(piecenum), 1, 32767);
         END LOOP;

         IF OWA_PATTERN.MATCH(bigpage, 'NAME="SESSION_ID" VALUE="(\d*)"',
                              components)
         THEN
            session_id_l := components(1);
         ELSE
            RAISE cannot_get_session_id;
         END IF;
      END IF;

      RETURN session_id_l;
   END session_id;

   FUNCTION catdata (isbn IN VARCHAR2, retries IN PLS_INTEGER)
   RETURN VARCHAR2
   IS
      buf VARCHAR2(2000);
      session_has_expired EXCEPTION;
   BEGIN
      buf := UTL_HTTP.REQUEST(url_frag_for_fetch || '&TERM_1='
                || isbn || '&SESSION_ID=' || session_id());

      IF INSTR(buf, 'Your session has expired') > 0
      THEN
         RAISE session_has_expired;
      END IF;

      RETURN buf;

   EXCEPTION
      WHEN cannot_get_session_id
           OR session_has_expired
      THEN
         IF retries > 0
         THEN
            RETURN catdata(isbn, retries - 1);
         ELSE
            exc.myraise(exc.cannot_retrieve_remote_url_cd);
         END IF;
   END catdata;
END;
/

SHOW ERRORS

