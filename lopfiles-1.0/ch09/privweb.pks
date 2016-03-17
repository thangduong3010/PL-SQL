REM $Id: privweb.pks,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 342

REM Spec of body providing session id management and checking (supports 
REM web-based user interface programs)

CREATE OR REPLACE PACKAGE privweb
AS

   FUNCTION web_session_timeout_minutes RETURN PLS_INTEGER;

   FUNCTION new_session_id(username_in IN lib_users.username%TYPE,
      plaintext_password_in IN VARCHAR2)
   RETURN VARCHAR2;

   FUNCTION user_id (session_id_in IN web_sessions.id%TYPE)
   RETURN PLS_INTEGER;

   PROCEDURE assert_allowed(session_id IN web_sessions.id%TYPE,
      privilege_id IN lib_privileges.id%TYPE);

END privweb;
/

SHOW ERRORS

