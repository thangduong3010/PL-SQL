REM $Id: priv.pks,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 337

REM Spec of package that will manage library system privileges

CREATE OR REPLACE PACKAGE priv
AS

   add_user_c CONSTANT PLS_INTEGER := 100;
   edit_user_c CONSTANT PLS_INTEGER := 101;
   delete_user_c CONSTANT PLS_INTEGER := 102;
   grant_privilege_c CONSTANT PLS_INTEGER := 103;
   revoke_privilege_c CONSTANT PLS_INTEGER := 104;
   read_user_c CONSTANT PLS_INTEGER := 105;

   edit_book_c CONSTANT PLS_INTEGER := 106;
   edit_book_copy_c CONSTANT PLS_INTEGER := 107;
   weed_book_c CONSTANT PLS_INTEGER := 108;
   delete_book_copy_c CONSTANT PLS_INTEGER := 109;

   use_bookform_c CONSTANT PLS_INTEGER := 110;

   PROCEDURE assert_allowed (user_id_in IN NUMBER, privilege_id_in IN NUMBER);
   
   PROCEDURE grant_priv (privilege_id_in IN NUMBER,
      user_id_in IN NUMBER, requestor_id IN NUMBER);

   PROCEDURE revoke_priv (privilege_id_in IN NUMBER,
      user_id_in IN NUMBER, requestor_id IN NUMBER);

END;
/

SHOW ERRORS

