REM $Id: libuser.pks,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 339

REM Spec of package that manages user records in lib_users table

CREATE OR REPLACE PACKAGE libuser
AS

   /* Add this in when need to fetch
   TYPE refcur_t IS REF CURSOR;
   */


   FUNCTION new_user_id(username IN VARCHAR2,
      plaintext_password IN VARCHAR2,
      email_address IN VARCHAR2,
      cardid IN VARCHAR2,
      requestor_id IN NUMBER)
   RETURN PLS_INTEGER;

   PROCEDURE change(user_id IN VARCHAR2,
      username_in IN VARCHAR2,
      plaintext_password_in IN VARCHAR2,
      email_address_in IN VARCHAR2,
      cardid_in IN VARCHAR2,
      requestor_id IN NUMBER);

   PROCEDURE remove(user_id IN NUMBER,
      requestor_id IN NUMBER);

   FUNCTION authenticated_user_id(username_in IN VARCHAR2,
      plaintext_password_in IN VARCHAR2)
   RETURN PLS_INTEGER;

   /* Add this in when need to fetch
   FUNCTION user_cur (pk IN VARCHAR2,
      param1 IN VARCHAR2,
      param2 IN VARCHAR2,
      startrec IN VARCHAR2 DEFAULT '1',
      rows_to_fetch IN VARCHAR2 DEFAULT 'ALL',
      orderby IN VARCHAR2 DEFAULT '1')
      RETURN refcur_t;
   */

END libuser;
/

SHOW ERRORS

