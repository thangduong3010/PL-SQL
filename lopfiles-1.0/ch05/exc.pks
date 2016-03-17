REM $Id: exc.pks,v 1.1 2001/11/30 23:19:50 bill Exp $
REM From "Learning Oracle PL/SQL" page 319

REM Spec of exception support package first used by body of "book"
REM package in Chapter 5

CREATE OR REPLACE PACKAGE exc
AS
   authorization_required EXCEPTION;
   authorization_required_cd CONSTANT PLS_INTEGER := -20501;
   PRAGMA EXCEPTION_INIT(authorization_required, -20501);

   unimplemented_feature EXCEPTION;
   unimplemented_feature_cd CONSTANT PLS_INTEGER := -20502;
   PRAGMA EXCEPTION_INIT(unimplemented_feature, -20502);

   missing_value EXCEPTION;
   missing_value_cd CONSTANT PLS_INTEGER := -20503;
   PRAGMA EXCEPTION_INIT(missing_value, -20503);

   not_logged_in EXCEPTION;
   not_logged_in_cd CONSTANT PLS_INTEGER := -20504;
   PRAGMA EXCEPTION_INIT(not_logged_in, -20504);

   session_timed_out EXCEPTION;
   session_timed_out_cd CONSTANT PLS_INTEGER := -20505;
   PRAGMA EXCEPTION_INIT(session_timed_out, -20505);

   data_format_error EXCEPTION;
   data_format_error_cd CONSTANT PLS_INTEGER := -20506;
   PRAGMA EXCEPTION_INIT(data_format_error, -20506);

   cannot_change_unique_id EXCEPTION;
   cannot_change_unique_id_cd CONSTANT PLS_INTEGER := -20507;
   PRAGMA EXCEPTION_INIT(cannot_change_unique_id, -20507);

   prob_with_sending_mail EXCEPTION;
   prob_with_sending_mail_cd CONSTANT PLS_INTEGER := -20508;
   PRAGMA EXCEPTION_INIT(prob_with_sending_mail, -20508);

   cannot_retrieve_remote_url EXCEPTION;
   cannot_retrieve_remote_url_cd CONSTANT PLS_INTEGER := -20509;
   PRAGMA EXCEPTION_INIT(cannot_retrieve_remote_url, -20509);

   PROCEDURE myraise (exc_no IN PLS_INTEGER, text IN VARCHAR2 DEFAULT NULL);
END;
/

SHOW ERRORS

