REM $Id: privweb.pkb,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 343

REM Body of body providing session id management and checking (supports 
REM web-based user interface programs)

CREATE OR REPLACE PACKAGE BODY privweb
AS

   timeout_minutes_private PLS_INTEGER := 120;

   FUNCTION web_session_timeout_minutes RETURN PLS_INTEGER
   IS
   BEGIN
      RETURN timeout_minutes_private;
   END;

   FUNCTION new_session_id(username_in IN lib_users.username%TYPE,
      plaintext_password_in IN VARCHAR2)
   RETURN VARCHAR2
   IS
      CURSOR idcur (which_id VARCHAR2)
      IS
         SELECT NULL
           FROM web_sessions
          WHERE id = which_id;
      idrow idcur%ROWTYPE;

      l_session_id web_sessions.id%TYPE;
      l_user_id lib_users.id%TYPE;
      id_exists BOOLEAN;

   BEGIN

      /* not-null assertions established in authenticated_user_id
      | function call
      */
      l_user_id :=
         libuser.authenticated_user_id(username_in, plaintext_password_in);

      /* Search in a loop so we're sure that the session id is unique.
      |  A collision is very unlikely but ya never know...
      */

      WHILE id_exists IS NULL OR id_exists 
      LOOP
         l_session_id := lopu.randomstr;
         OPEN idcur(l_session_id);
         FETCH idcur INTO idrow;
         IF idcur%FOUND
         THEN
            id_exists := TRUE;
         ELSE
            id_exists := FALSE;
         END IF;
         CLOSE idcur;
      END LOOP;

      INSERT INTO web_sessions(id, user_id,
                  expiration_date)
      VALUES (l_session_id, l_user_id,
                  SYSDATE + (web_session_timeout_minutes/1440));
      RETURN l_session_id;

   END new_session_id;

   FUNCTION user_id (session_id_in IN web_sessions.id%TYPE)
      RETURN PLS_INTEGER
   IS
      CURSOR scur
      IS
         SELECT user_id, expiration_date
           FROM web_sessions
          WHERE id = session_id_in;
      srow scur%ROWTYPE;
   BEGIN

      IF session_id_in IS NULL
      THEN
         exc.myraise(exc.not_logged_in_cd);
      END IF;

      OPEN scur;
      FETCH scur INTO srow;
      IF scur%NOTFOUND
      THEN
         CLOSE scur;
         exc.myraise(exc.not_logged_in_cd);
      END IF;
      CLOSE scur;

      IF srow.expiration_date < SYSDATE
      THEN
         exc.myraise(exc.session_timed_out_cd);
      END IF;

      RETURN srow.user_id;

   END user_id;

   PROCEDURE assert_allowed (session_id IN web_sessions.id%TYPE,
         privilege_id IN lib_privileges.id%TYPE)
   IS
   BEGIN
      /* not-null assertions established in next statement */
      priv.assert_allowed(user_id(session_id), privilege_id);
   END assert_allowed;

END privweb;
/

SHOW ERRORS

