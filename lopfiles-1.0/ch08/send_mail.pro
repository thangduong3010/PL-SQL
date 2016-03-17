REM $Id$
REM From "Learning Oracle PL/SQL" page 269

REM This is the send_mail procedure that also lives in the lopu package,
REM extracted only for convenience

CREATE OR REPLACE PROCEDURE send_mail
   (sender_email IN VARCHAR2, 
   recipient_email IN VARCHAR2, 
   message IN VARCHAR2,
   subject IN VARCHAR2 DEFAULT NULL,
   sender_name IN VARCHAR2 DEFAULT NULL,
   recipient_name IN VARCHAR2 DEFAULT NULL,
   mailhost IN VARCHAR2 DEFAULT 'mailhost')
IS
   mail_conn  UTL_SMTP.CONNECTION;
   result UTL_SMTP.REPLY;
   smtp_tcpip_port CONSTANT PLS_INTEGER := 25;
   crlf CONSTANT VARCHAR2(2) := CHR(13) || CHR(10);
   okay_c CONSTANT PLS_INTEGER := 250;
   closed_c CONSTANT PLS_INTEGER := 221;
   ready_for_data_c CONSTANT PLS_INTEGER := 354;

   PROCEDURE ckreply (result IN UTL_SMTP.REPLY, expected_code IN PLS_INTEGER)
   IS
   BEGIN
      lopu.assert(condition_in => result.CODE = expected_code,
                  message_in => result.CODE || ' ' || result.TEXT,
                  exception_in => exc.prob_with_sending_mail_cd);
   END;

BEGIN
   mail_conn := UTL_SMTP.OPEN_CONNECTION(mailhost, smtp_tcpip_port);

   ckreply( UTL_SMTP.HELO(mail_conn, mailhost), okay_c);
   ckreply( UTL_SMTP.MAIL(mail_conn, sender_email), okay_c);
   ckreply( UTL_SMTP.RCPT(mail_conn, recipient_email), okay_c);
   ckreply( UTL_SMTP.OPEN_DATA(mail_conn), ready_for_data_c);

   UTL_SMTP.WRITE_DATA(mail_conn,
      'Date: '
         || TO_CHAR(CURRENT_TIMESTAMP, 'Dy, dd Mon YYYY HH24:MI:SS TZHTZM')
         || crlf);
   UTL_SMTP.WRITE_DATA(mail_conn,
       'From: ' || sender_name || ' <' || sender_email || '>' || crlf);
   UTL_SMTP.WRITE_DATA(mail_conn,
       'Subject: ' || subject || crlf);
   UTL_SMTP.WRITE_DATA(mail_conn,
       'To: ' || recipient_name || ' <' || recipient_email || '>' || crlf);
   UTL_SMTP.WRITE_DATA(mail_conn, message);

   ckreply( UTL_SMTP.CLOSE_DATA(mail_conn), okay_c);
   ckreply( UTL_SMTP.QUIT(mail_conn), closed_c);

EXCEPTION
   WHEN OTHERS
   THEN
      exc.myraise(exc.prob_with_sending_mail_cd, SQLERRM);
END;
/

