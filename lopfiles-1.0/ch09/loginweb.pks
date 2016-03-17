REM $Id: loginweb.pks,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 345

REM Spec of package that handles user interface aspects of logging in to the
REM web-based system

CREATE OR REPLACE PACKAGE loginweb
AS

   PROCEDURE process_login(username_ IN VARCHAR2 DEFAULT NULL,
      plaintext_password_ IN VARCHAR2 DEFAULT NULL,
      destination_ IN VARCHAR2 DEFAULT NULL,
      submit IN VARCHAR2 DEFAULT NULL);

   PROCEDURE logout (session_id_ IN web_sessions.id%TYPE DEFAULT NULL,
      destination_ IN VARCHAR2 DEFAULT '/');

END loginweb;
/

SHOW ERRORS

