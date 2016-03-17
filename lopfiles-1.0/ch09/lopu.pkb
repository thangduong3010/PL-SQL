REM $Id: lopu.pkb,v 1.1 2001/11/30 23:24:55 bill Exp $
REM From "Learning Oracle PL/SQL" page 334

REM Body of lopu package that adds random value generator (for use with
REM Oracle9i; see also the file lopu.8i.pkb) and password support

CREATE OR REPLACE PACKAGE BODY lopu
AS
   linefeed CONSTANT VARCHAR2(1) := CHR(10);
   dflt_date_format_private nls_session_parameters.value%TYPE;

   PROCEDURE set_dflt_date_format(date_format IN VARCHAR2)
   IS
   BEGIN
      dflt_date_format_private := date_format;
   END;

   FUNCTION dflt_date_format
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN dflt_date_format_private;
   END;

   FUNCTION is_string (what IN VARCHAR2)
      RETURN BOOLEAN
   IS
   BEGIN
      RETURN TRUE;
   END;

   FUNCTION is_number (what IN VARCHAR2)
      RETURN BOOLEAN
   IS
      numtester NUMBER;
   BEGIN
      numtester := TO_NUMBER(what);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   FUNCTION is_date (what IN VARCHAR2,
      date_format IN VARCHAR2 DEFAULT dflt_date_format)
      RETURN BOOLEAN
   IS
      datetester DATE;
   BEGIN
      datetester := TO_DATE(what, date_format);
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN FALSE;
   END;

   PROCEDURE assert (
      condition_in IN BOOLEAN,
      message_in IN VARCHAR2,
      exception_in IN PLS_INTEGER)
   IS
   BEGIN
      IF NOT condition_in
         OR condition_in IS NULL
      THEN
         exc.myraise(exception_in, message_in);
      END IF;
   END assert;

   PROCEDURE assert (
      condition_in IN BOOLEAN,
      message_in IN VARCHAR2,
      exception_in IN VARCHAR2)
   IS
   BEGIN
      IF NOT condition_in
         OR condition_in IS NULL
      THEN
         EXECUTE IMMEDIATE 
           'BEGIN RAISE ' || exception_in || '; END;';
      END IF;
   END assert;

   PROCEDURE assert_notnull (tested_variable IN VARCHAR2,
      error_msg IN VARCHAR2)
   IS
   BEGIN
      IF tested_variable IS NULL
      THEN
         exc.myraise(exc.missing_value_cd, error_msg);
      END IF;
   END assert_notnull;

   PROCEDURE assert_notnull (tested_variable IN DATE,
      error_msg IN VARCHAR2)
   IS
   BEGIN
      assert_notnull(TO_CHAR(tested_variable, error_msg));
   END;

   PROCEDURE assert_notnull (tested_variable IN NUMBER,
      error_msg IN VARCHAR2)
   IS
   BEGIN
      assert_notnull(TO_CHAR(tested_variable, lopu.dflt_date_format),
         error_msg);
   END;

   FUNCTION str_fits (what IN VARCHAR2,
      minlength IN NUMBER,
      maxlength IN NUMBER)
      RETURN BOOLEAN
   IS
      lenwhat NUMBER := LENGTH(what);
   BEGIN
      IF (what IS NULL AND minlength = 0)
         OR
            (lenwhat >= minlength
            AND
            lenwhat <= maxlength)
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;
   END str_fits;

   PROCEDURE makewhere (where_clause IN OUT VARCHAR2,
      column_name IN VARCHAR2, column_value IN VARCHAR2,
      datatype IN VARCHAR2,
      dataformat IN VARCHAR2,
      rewrite_op IN BOOLEAN)
   IS
      operator_l VARCHAR2(7);
      rhs VARCHAR2(1024) := column_value;
   BEGIN
      /* must have both column name and value */
      IF column_name IS NULL OR column_value IS NULL
      THEN
         RETURN;
      END IF;

      IF rewrite_op
      THEN
         operator_l := '=';
      END IF;

      IF where_clause IS NULL
      THEN
         where_clause := 'WHERE ';
      ELSE
         where_clause := where_clause || ' AND ';
      END IF;

      IF datatype = 'STRING'
      THEN
         rhs := esc(column_value);

         IF rewrite_op AND INSTR(column_value, '%') != 0
         THEN
            operator_l := ' LIKE ';
         END IF;

      ELSIF datatype = 'DATE'
      THEN
         rhs := 'TO_DATE(' || esc(column_value) || ','
                           || esc(NVL(dataformat, dflt_date_format))
                    || ')';
      END IF;

      where_clause := where_clause || column_name || operator_l || rhs;
   END;

   FUNCTION esc (text IN VARCHAR2)
      RETURN VARCHAR2
   AS
   BEGIN
      RETURN '''' || REPLACE(text, '''', '''''') || '''';
   END;

   FUNCTION encrypted_password(username IN VARCHAR2,
      plaintext_password IN VARCHAR2)
   RETURN RAW
   IS
      string_for_md5 VARCHAR2(120);
   BEGIN
      assert_notnull(username);
      assert_notnull(plaintext_password);
      string_for_md5 := UPPER(username) || UPPER(plaintext_password);
      RETURN DBMS_OBFUSCATION_TOOLKIT.MD5(
         INPUT=>UTL_RAW.CAST_TO_RAW(string_for_md5));
   END;

   FUNCTION randomstr
   RETURN VARCHAR2
   IS
      seedval RAW(80) := HEXTORAW('26AB07A980928EF806F17D49EB5B0D9C03901170'
       || '17881F46920215CDFFFBD59403F52DAA480A3DFAC6BFE15CC0EA16478BEF5CE0'
       || 'E9E5E85DFE0FA459CF0D0631691A5C919C546F63F285485A4723EFD5');
   BEGIN
      RETURN RAWTOHEX(DBMS_OBFUSCATION_TOOLKIT.DES3GETKEY(seed => seedval));
   END;

   PROCEDURE send_mail
      (sender_email IN VARCHAR2, 
      recipient_email IN VARCHAR2, 
      message IN VARCHAR2,
      subject IN VARCHAR2,
      sender_name IN VARCHAR2,
      recipient_name IN VARCHAR2,
      mailhost IN VARCHAR2)
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

BEGIN

   /* This section of a package will get executed automatically the very
   || first time that any part of the package is invoked.  So you can use
   || it for initializing variables.  (See page 321.)
   */

   SELECT VALUE INTO dflt_date_format_private
     FROM NLS_SESSION_PARAMETERS
    WHERE PARAMETER = 'NLS_DATE_FORMAT';

EXCEPTION
   WHEN OTHERS
   THEN NULL;

END lopu;
/

SHOW ERRORS

