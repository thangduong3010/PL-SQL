REM $Id: loginweb.pkb,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 345

REM Body of package that handles user interface aspects of logging in to the
REM web-based system

CREATE OR REPLACE PACKAGE BODY loginweb
AS

   PROCEDURE process_login(username_ IN VARCHAR2,
      plaintext_password_ IN VARCHAR2,
      destination_ IN VARCHAR2,
      submit IN VARCHAR2)
   IS
      sessid web_sessions.id%TYPE;
      token VARCHAR2(1) := '&';
   BEGIN
      /* not-null assertions established in new_session_id function call */
      sessid := 
         privweb.new_session_id(username_, plaintext_password_);

      IF destination_ IS NULL
      THEN
         HTP.INIT;
         booksearch;
      ELSE
         IF INSTR(destination_, '?') = 0
         THEN
            token := '?';
         END IF;
         webu.redirect(destination_ || token || 'session_id_=' || sessid);
      END IF;

   END process_login;


   PROCEDURE logout (session_id_ web_sessions.id%TYPE,
      destination_ IN VARCHAR2)
   IS
   BEGIN
      IF session_id_ IS NOT NULL
      THEN
         DELETE web_sessions WHERE id = session_id_;
      END IF;
      webu.redirect(destination_);
   END logout;

END loginweb;
/

SHOW ERRORS

