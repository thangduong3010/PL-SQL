CREATE OR REPLACE PROCEDURE send_mail (
										p_to        IN VARCHAR2,
										p_from      IN VARCHAR2,
										p_subject   IN VARCHAR2,
										p_message   IN VARCHAR2,
										p_smtp_host IN VARCHAR2,
										p_smtp_port IN NUMBER DEFAULT 465)
AS
  l_mail_conn   UTL_SMTP.connection;
BEGIN
	l_mail_conn := UTL_SMTP.open_connection(p_smtp_host, p_smtp_port);
  
  UTL_SMTP.helo(l_mail_conn, p_smtp_host);
  utl_smtp.command( l_mail_conn, 'AUTH LOGIN'); 
  utl_smtp.command( l_mail_conn, utl_raw.cast_to_varchar2( utl_encode.base64_encode( utl_raw.cast_to_raw('username')))); 
  utl_smtp.command( l_mail_conn, utl_raw.cast_to_varchar2( utl_encode.base64_encode( utl_raw.cast_to_raw('password')))); 
 
	UTL_SMTP.mail(l_mail_conn, p_from);
	UTL_SMTP.rcpt(l_mail_conn, p_to);

  UTL_SMTP.open_data(l_mail_conn);  
  UTL_SMTP.write_data(l_mail_conn, 'Date: ' || TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'To: ' || p_to || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'From: ' || p_from || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Subject: ' || p_subject || UTL_TCP.crlf);
  UTL_SMTP.write_data(l_mail_conn, 'Reply-To: ' || p_from || UTL_TCP.crlf || UTL_TCP.crlf);
   UTL_SMTP.write_data(l_mail_conn, p_message || UTL_TCP.crlf || UTL_TCP.crlf);
   UTL_SMTP.write_data(l_mail_conn, 'abcdef' || UTL_TCP.crlf || UTL_TCP.crlf);
   UTL_SMTP.write_data(l_mail_conn, '123456' || UTL_TCP.crlf || UTL_TCP.crlf);
  UTL_SMTP.close_data(l_mail_conn);

  UTL_SMTP.quit(l_mail_conn);
END;