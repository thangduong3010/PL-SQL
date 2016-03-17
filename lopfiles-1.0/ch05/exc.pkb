REM $Id: exc.pkb,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" page 319

REM Body of exception support package first used by body of "book"
REM package in Chapter 5

CREATE OR REPLACE PACKAGE BODY exc
AS

   TYPE error_text_t IS TABLE OF VARCHAR2(512) INDEX BY BINARY_INTEGER;
   error_texts error_text_t;

   PROCEDURE myraise (exc_no IN PLS_INTEGER, text IN VARCHAR2)
   IS
   BEGIN
      lopu.assert_notnull(exc_no,
         'programmer error: exc.myraise called with null exc_no');
      IF text IS NULL AND error_texts.EXISTS(exc_no)
      THEN
         RAISE_APPLICATION_ERROR(exc_no,
            'Error: ' || error_texts(exc_no));
      ELSE
         RAISE_APPLICATION_ERROR(exc_no, text);
      END IF;
   END;

BEGIN

   /* Default error messages. */

   error_texts(authorization_required_cd) :=
      'No privilege for requested operation.';

   error_texts(unimplemented_feature_cd) :=
      'Unimplemented feature.  Increase programmer gruel rations.';

   error_texts(missing_value_cd) :=
      'Missing value.  Please fill in all fields.';

   error_texts(session_timed_out_cd) :=
      'Session timed out.  Please log in again.';

   error_texts(not_logged_in_cd) :=
      'Supply a valid username and password to proceed.';

   error_texts(data_format_error_cd) :=
      'User supplied data that is not in the expected format.';

   error_texts(cannot_change_unique_id_cd) :=
      'Changing the unique identifier is not legal in this application.';

   error_texts( prob_with_sending_mail_cd) :=
      'Some problem occurred while attempting to send email.';

   error_texts(cannot_retrieve_remote_url_cd) :=
      'Attempt to retrieve remote web page failed.';
END;
/

SHOW ERRORS

