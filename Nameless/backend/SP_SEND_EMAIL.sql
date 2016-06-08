CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_SEND_EMAIL (p_to         VARCHAR2,
                                                       p_subject    VARCHAR2,
                                                       p_content    VARCHAR2)
IS
   vConnection   UTL_SMTP.connection;
   vHost         VARCHAR2 (50);
   vFrom         VARCHAR2 (50);
   vPass         VARCHAR2 (50);
/******************************************************************************
   NAME:       SP_SEND_EMAIL
   PURPOSE:    Use for sending email

******************************************************************************/
BEGIN
   IF p_to = ''
   THEN
      RETURN;
   END IF;

   vHost := 'smtp.gmail.com';
   vFrom := 'ilosmail.noreply@gmail.com';
   vPass := 'admin@123!';
   vConnection :=
      UTL_SMTP.open_connection (
         HOST                            => vHost,
         port                            => 587,
         wallet_path                     => 'file:$ORACLE_HOME/owm/wallets/oracle/',
         wallet_password                 => '123456a@',
         secure_connection_before_smtp   => FALSE);

   UTL_SMTP.helo (vConnection, vHost);
   UTL_SMTP.starttls (vConnection);

   UTL_SMTP.command (vConnection, 'AUTH LOGIN');
   UTL_SMTP.command (
      vConnection,
      UTL_RAW.cast_to_varchar2 (
         UTL_ENCODE.base64_encode (UTL_RAW.cast_to_raw (vFrom))));
   UTL_SMTP.command (
      vConnection,
      UTL_RAW.cast_to_varchar2 (
         UTL_ENCODE.base64_encode (UTL_RAW.cast_to_raw (vPass))));

   UTL_SMTP.mail (vConnection, vFrom);
   UTL_SMTP.rcpt (vConnection, p_to);
   UTL_SMTP.open_data (vConnection);

   UTL_SMTP.write_data (vConnection,
                        'Subject: ' || p_subject || UTL_TCP.crlf);
   UTL_SMTP.WRITE_DATA (vConnection, 'MIME-version: 1.0' || UTL_TCP.CRLF);
   UTL_SMTP.WRITE_DATA (
      vConnection,
      'Content-Type: text/html;charset=utf-8' || UTL_TCP.CRLF);
   UTL_SMTP.WRITE_DATA (
      vConnection,
      'Content-Transfer-Encoding: quoted-printable ' || UTL_TCP.CRLF);
   UTL_SMTP.write_data (vConnection, 'To: ' || p_to || UTL_TCP.crlf);

   UTL_SMTP.WRITE_DATA (vConnection, UTL_TCP.CRLF);
   UTL_SMTP.WRITE_RAW_DATA (
      vConnection,
      UTL_ENCODE.QUOTED_PRINTABLE_ENCODE (UTL_RAW.CAST_TO_RAW (p_content)));
   UTL_SMTP.WRITE_DATA (vConnection, UTL_TCP.CRLF);

   UTL_SMTP.close_data (vConnection);

   UTL_SMTP.quit (vConnection);
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      DBMS_OUTPUT.PUT_LINE (
            'SP_SEND_EMAIL: Exception when sending email to '
         || p_to
         || ' with Subject: '
         || p_subject);
      UTL_SMTP.QUIT (vConnection);
      RAISE;
END SP_SEND_EMAIL;
/