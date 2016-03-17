REM $Id: libuser.pkb,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 341

REM Body of package that manages user records in lib_users table

CREATE OR REPLACE PACKAGE BODY libuser
AS

   /* add this in when need to fetch
   | TYPE refcur_t IS REF CURSOR;
   */

   FUNCTION new_user_id(username IN VARCHAR2,
      plaintext_password IN VARCHAR2,
      email_address IN VARCHAR2,
      cardid IN VARCHAR2,
      requestor_id IN NUMBER)
   RETURN PLS_INTEGER
   IS
      l_user_id PLS_INTEGER;
   BEGIN
      priv.assert_allowed(requestor_id, priv.add_user_c);

      INSERT INTO lib_users (id, username,
         encrypted_password,
         account_creation_date, email_address, cardid)
      VALUES (libuser_seq.NEXTVAL, username,
         lopu.encrypted_password(username, plaintext_password),
         SYSDATE, email_address, cardid)
      RETURNING id INTO l_user_id;

      RETURN l_user_id;
   END new_user_id;


   PROCEDURE change(user_id IN VARCHAR2,
      username_in IN VARCHAR2,
      plaintext_password_in IN VARCHAR2,
      email_address_in IN VARCHAR2,
      cardid_in IN VARCHAR2,
      requestor_id IN NUMBER)
   IS
   BEGIN
      priv.assert_allowed(requestor_id, priv.edit_user_c);
      UPDATE lib_users
         SET encrypted_password =
                lopu.encrypted_password(username_in, plaintext_password_in),
             username = username_in,
             email_address = email_address_in,
             cardid = cardid_in
       WHERE id = user_id;
       IF SQL%NOTFOUND
       THEN
          RAISE NO_DATA_FOUND;
       END IF;
   END change;


   PROCEDURE remove(user_id IN NUMBER,
      requestor_id IN NUMBER)
   IS
   BEGIN
      priv.assert_allowed(requestor_id, priv.delete_user_c);
      lopu.assert_notnull(user_id);
      DELETE lib_users WHERE id = user_id;
      IF SQL%ROWCOUNT = 0
      THEN
         RAISE NO_DATA_FOUND;
      END IF;
   END remove;


   FUNCTION authenticated_user_id(username_in IN VARCHAR2,
      plaintext_password_in IN VARCHAR2)
   RETURN PLS_INTEGER
   IS
      CURSOR ucur
      IS
         SELECT id
           FROM lib_users
          WHERE UPPER(username) = UPPER(username_in)
            AND encrypted_password =
                lopu.encrypted_password(username_in, plaintext_password_in);
      urow ucur%ROWTYPE;

   BEGIN
      lopu.assert_notnull(username_in);
      lopu.assert_notnull(plaintext_password_in);

      /* If the userid and password generate an MD5 result that matches what's
      | stored in the system (see where clause in "ucur" above), then the
      | credentials "pass", and it's okay to return the user id
      */

      OPEN ucur;
      FETCH ucur INTO urow;
      IF ucur%NOTFOUND
      THEN
         CLOSE ucur;
         exc.myraise(exc.not_logged_in_cd);
      END IF;
      CLOSE ucur;

      RETURN urow.id;
   END authenticated_user_id;

/* add this in when need to fetch

   FUNCTION user_cur (pk IN VARCHAR2,
      param1 IN VARCHAR2,
      param2 IN VARCHAR2,
      startrec IN VARCHAR2 DEFAULT '1',
      rows_to_fetch IN VARCHAR2 DEFAULT 'ALL',
      orderby IN VARCHAR2 DEFAULT '1')
      RETURN refcur_t
   IS
     ...implement here...
   END;
*/

END libuser;
/

SHOW ERRORS
