REM $Id: create_demouser_account.sql,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 9

REM Create a library user with username demouser and password swordfish,
REM then grant all available privileges to that user

DECLARE
   l_id lib_users.id%TYPE;
   uname lib_users.username%TYPE := 'demouser';
   plainpass VARCHAR2(64) := 'swordfish';
BEGIN

   INSERT INTO lib_users (id, username,
         encrypted_password,
         account_creation_date)
      VALUES (libuser_seq.NEXTVAL, uname,
         lopu.encrypted_password(uname, plainpass),
         SYSDATE);

   /* intentional cartesion product; gives "demo" user all privs */
   INSERT INTO lib_user_privileges (user_id, privilege_id)
   SELECT u.id, p.id
     FROM lib_privileges p, lib_users u;
END;
/

