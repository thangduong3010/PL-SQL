REM $Id$
REM From "Learning Oracle PL/SQL" page 290

REM Simple illustration of using OWA_PATTERN.MATCH

DECLARE
   text VARCHAR2(2000) := '<INPUT NAME="SESSION_ID" VALUE="191786"';
   components OWA_TEXT.VC_ARR;
   pattern VARCHAR2(64) := 'NAME="SESSION_ID" VALUE="(\d*)"';
BEGIN
   IF OWA_PATTERN.MATCH(line => text, pat => pattern, backrefs => components)
   THEN
      DBMS_OUTPUT.PUT_LINE('session id is ' || components(1));
   ELSE
      DBMS_OUTPUT.PUT_LINE('no session id found');
   END IF;
END;
/

