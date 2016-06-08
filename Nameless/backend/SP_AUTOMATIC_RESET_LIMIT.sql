CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_AUTOMATIC_RESET_LIMIT(
   p_SYSTRAN_ID         NUMBER,
   p_SYSBATCH_REQ_ID    NUMBER,
   p_ENTRY_DATE           DATE)
IS

/******************************************************************************
   NAME:       SP_AUTOMATIC_RESET_LIMIT
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        11/11/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_AUTOMATIC_RESET_LIMIT
      Sysdate:         11/11/2015
      Date and Time:   11/11/2015, 1:39:44 PM, and 11/11/2015 1:39:44 PM
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
    DECLARE MANUAL_RESET_LIMIT_EVENT_ID NUMBER := 8;
    vEVENT_CODE                EVENT_DEF.EVENT_CODE%TYPE;
      vEVENT_DESC                EVENT_DEF.EVENT_DESC%TYPE;
      vEVENT_OBJECT              EVENT_DEF.EVENT_OBJECT%TYPE;
      vEVENT_EXECUTION_ID        NUMBER;
BEGIN
     SELECT EVENT_CODE, EVENT_DESC, EVENT_OBJECT
        INTO vEVENT_CODE, vEVENT_DESC, vEVENT_OBJECT
        FROM EVENT_DEF
       WHERE ID = MANUAL_RESET_LIMIT_EVENT_ID;
   FOR resetLimit IN (SELECT ID FROM LIMIT 
                    WHERE AMND_STATE = 'F' AND END_DATE <= p_ENTRY_DATE
                    AND BLOCK_AMOUNT <= 0 AND RECYCLE_METHOD_NEW = 'A')
   LOOP
     BEGIN
  
       INSERT INTO EVENT_EXECUTION (SYS_TRAN_ID,
                                      AUDIT_DATE,
                                      AUDIT_OPERATION,
                                      APPROVAL_STATUS,
                                      UPD_SEQ,
                                      AMND_STATE,
                                      BATCH_REQ_ID,
                                      EVENT_ID,
                                      EVENT_CODE,
                                      EVENT_DESC,
                                      EVENT_OBJECT,
                                      OBJECT_ID,
                                      TIMESTAMP,
                                      ERROR_CODE,
                                      INHERIT_MENU_ACL,
                                      SID)
              VALUES (                                       /* SYS_TRAN_ID */
                      p_SYSTRAN_ID,
                      /* AUDIT_DATE */
                      SYSDATE,
                      /* AUDIT_OPERATION */
                      'I',
                      /* APPROVAL_STATUS */
                      'A',
                      /* UPD_SEQ */
                      1,
                      /* AMND_STATE */
                      'F',
                      /* BATCH_REQ_ID */
                      p_SYSBATCH_REQ_ID,
                      /* EVENT_ID */
                      MANUAL_RESET_LIMIT_EVENT_ID,
                      /* EVENT_CODE */
                      vEVENT_CODE,
                      /* EVENT_DESC */
                      vEVENT_DESC,
                      /* EVENT_OBJECT */
                      vEVENT_OBJECT,
                      /* OBJECT_ID */
                      resetLimit.ID,
                      /* TIMESTAMP */
                      SYSDATE,
                      /* ERROR_CODE */
                      'E',
                      /* INHERIT_MENU_ACL */
                      1,
                      /* SID */
                      SQ_SID.NEXTVAL)
           RETURNING ID
                INTO vEVENT_EXECUTION_ID;
         SP_RUN_ACTION_EVENT (MANUAL_RESET_LIMIT_EVENT_ID,
                              vEVENT_EXECUTION_ID,
                              resetLimit.ID,
                              vEVENT_OBJECT,
                              p_SYSTRAN_ID,
                              p_SYSBATCH_REQ_ID,
                              null);

         UPDATE EVENT_EXECUTION
            SET ERROR_CODE = 'F'
          WHERE ID = vEVENT_EXECUTION_ID;
          
      DBMS_OUTPUT.PUT_LINE (resetLimit.ID);
        UPDATE LIMIT SET CURRENT_VALUE = SETUP_VALUE,
                LAST_CURRENT_VALUE = p_ENTRY_DATE,
                BLOCK_AMOUNT = 0,
                LAST_BLOCKING_AMOUNT = p_ENTRY_DATE,
                LAST_RECYCLE = EFFECTIVE_DATE,
                EFFECTIVE_DATE = p_ENTRY_DATE,
                END_DATE = ADD_MONTHS(EFFECTIVE_DATE,RECYCLE_PERIOD),
                AUDIT_OPERATION = 'U'
                WHERE ID = resetLimit.ID;
     END;
   END LOOP;
    END;
   EXCEPTION
     WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      DBMS_OUTPUT.PUT_LINE (
            'SP_AUTOMATIC_RESET_LIMIT: Exception when executing BatchReqID: '
         || p_SYSBATCH_REQ_ID);
      RAISE;
END SP_AUTOMATIC_RESET_LIMIT;
/