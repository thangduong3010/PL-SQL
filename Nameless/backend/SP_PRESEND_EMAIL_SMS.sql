CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_PRESEND_EMAIL_SMS (v_systran NUMBER,
                                                       p_to         VARCHAR2,
                                                       p_subject    VARCHAR2,
                                                       p_content    VARCHAR2,
                                                       p_type       EVENT_ACTION_CONTENT.TYPE%TYPE)
IS
  
/******************************************************************************
   NAME:       SP_PRESEND_EMAIL_SMS
   PURPOSE:    Use for send email or sms

******************************************************************************/
BEGIN
   IF p_to = ''
   THEN
      RETURN;
   END IF;
   INSERT INTO BACKEND_DEV.EVENT_ACTION_CONTENT (
   AUDIT_DATE, TO_ADDRESS, 
   SUBJECT, TYPE, CONTENT, 
   STATUS, SYS_TRAN_ID,SID) 
VALUES (
 /* AUDIT_DATE */
 SYSDATE,
 /* TO_ADDRESS */
 p_to,
 /* SUBJECT */
 p_subject,
 /* TYPE */
 p_type,
 /* CONTENT */
 p_content,
 /* STATUS */
 'S',
 /* SYS_TRAN_ID */ 
 v_systran,
 /* SID */
 SQ_SID.NEXTVAL);
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      DBMS_OUTPUT.PUT_LINE (
            'SP_PRESEND_EMAIL_SMS: Exception when sending email to '
         || p_to
         || ' with Subject: '
         || p_subject);
      RAISE;
END SP_PRESEND_EMAIL_SMS;
/