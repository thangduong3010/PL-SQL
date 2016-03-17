REM $Id: populate_lib_privileges.sql,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" Chapter 9

REM Populate lib_privileges reference data

BEGIN

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.add_user_c, 'ADD USER');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.edit_user_c, 'EDIT USER');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.delete_user_c, 'DELETE USER');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.grant_privilege_c, 'GRANT PRIVILEGE');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.revoke_privilege_c, 'REVOKE PRIVILEGE');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.read_user_c, 'READ PRIVILEGE');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.edit_book_c, 'EDIT BOOK');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.edit_book_copy_c, 'EDIT BOOK COPY');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.weed_book_c, 'WEED BOOK');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.delete_book_copy_c, 'DELETE BOOK COPY');

   INSERT INTO lib_privileges (id, name)
   VALUES (priv.use_bookform_c, 'USE BOOKFORM');

END;
/

