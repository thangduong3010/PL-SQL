REM $Id: priv.pkb,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 338

REM Body of package that will manage library system privileges

CREATE OR REPLACE PACKAGE BODY priv
AS
   PROCEDURE assert_allowed (user_id_in IN NUMBER, privilege_id_in IN NUMBER)
   IS
      CURSOR pcur
      IS
         SELECT NULL
           FROM lib_user_privileges
          WHERE user_id = user_id_in
            AND privilege_id = privilege_id_in;
         prow pcur%ROWTYPE;
   BEGIN
      lopu.assert_notnull(user_id_in);
      lopu.assert_notnull(privilege_id_in);

      OPEN pcur;
      FETCH pcur INTO prow;
      IF pcur%NOTFOUND
      THEN
         CLOSE pcur;
         exc.myraise(exc.authorization_required_cd);
      END IF;
      CLOSE pcur;
   END;

   PROCEDURE grant_priv (privilege_id_in IN NUMBER,
      user_id_in IN NUMBER, requestor_id IN NUMBER)
   IS
   BEGIN
      assert_allowed(requestor_id, priv.grant_privilege_c);
      INSERT INTO lib_user_privileges (user_id, privilege_id)
      VALUES (user_id_in, privilege_id_in);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX
      THEN
         NULL;
   END;

   PROCEDURE revoke_priv (privilege_id_in IN NUMBER,
      user_id_in IN NUMBER, requestor_id IN NUMBER)
   IS
   BEGIN
      assert_allowed(requestor_id, priv.revoke_privilege_c);
      DELETE lib_user_privileges
       WHERE user_id = user_id_in
         AND privilege_id = privilege_id_in;
   END;

END;
/

SHOW ERRORS

