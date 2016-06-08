CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_APP_DOCUMENT_REVIEW
(
  P_SYSTRAN_ID IN NUMBER 
, P_SYSBATCH_REQ_ID IN NUMBER 
, P_ENTRY_DATE IN DATE 
) AS 
BEGIN
  DECLARE
      APP_DOCUMENT_REVIEW_ID   NUMBER := 11;
      vEVENT_CODE                EVENT_DEF.EVENT_CODE%TYPE;
      vEVENT_DESC                EVENT_DEF.EVENT_DESC%TYPE;
      vEVENT_OBJECT              EVENT_DEF.EVENT_OBJECT%TYPE;
      vEVENT_EXECUTION_ID        NUMBER;
      CHECK_COUNT                NUMBER;
   BEGIN
      SELECT EVENT_CODE, EVENT_DESC, EVENT_OBJECT
        INTO vEVENT_CODE, vEVENT_DESC, vEVENT_OBJECT
        FROM EVENT_DEF
       WHERE ID = APP_DOCUMENT_REVIEW_ID;
      /* CAR APP CONDITION */
      FOR car IN (SELECT ID
                       FROM CREDIT_APPLICATION_REQUEST
                       WHERE STATUS = 'A'
                       AND AMND_STATE = 'F')
      LOOP
        SELECT COUNT(ID)  INTO CHECK_COUNT 
                            FROM CAR_APPLICATION_DOCUMENTS
                            WHERE APPLICATION_ID = car.ID
                            AND AMND_STATE = 'F'
                            AND NEXT_REVISION_DATE IS NOT NULL
                            AND NEXT_REVISION_DATE < SYSDATE;
        IF CHECK_COUNT <= 0
        THEN
            SELECT COUNT(ID)  INTO CHECK_COUNT 
                            FROM CAR_COLLATERAL_DOCUMENTS
                            WHERE APPLICATION_ID = car.ID
                            AND AMND_STATE = 'F'
                            AND NEXT_REVISION_DATE IS NOT NULL
                            AND NEXT_REVISION_DATE < SYSDATE;
        END IF;
        IF CHECK_COUNT <= 0
        THEN
            SELECT COUNT(ID)  INTO CHECK_COUNT 
                            FROM CAR_CUSTOMER_DOCUMENTS
                            WHERE APPLICATION_ID = car.ID
                            AND AMND_STATE = 'F'
                            AND NEXT_REVISION_DATE IS NOT NULL
                            AND NEXT_REVISION_DATE < SYSDATE;
        END IF;
        IF  CHECK_COUNT > 0
        THEN
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
                      0,
                      /* AMND_STATE */
                      'F',
                      /* BATCH_REQ_ID */
                      p_SYSBATCH_REQ_ID,
                      /* EVENT_ID */
                      APP_DOCUMENT_REVIEW_ID,
                      /* EVENT_CODE */
                      vEVENT_CODE,
                      /* EVENT_DESC */
                      vEVENT_DESC,
                      /* EVENT_OBJECT */
                      vEVENT_OBJECT,
                      /* OBJECT_ID */
                      car.ID,
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
                
          UPDATE EVENT_EXECUTION
                        SET ERROR_CODE = 'F'
                        WHERE ID = vEVENT_EXECUTION_ID;
        /* RUN ACTION*/
           DBMS_OUTPUT.PUT_LINE('START ACTION');
            SP_RUN_ACTION_EVENT ( APP_DOCUMENT_REVIEW_ID,
                                vEVENT_EXECUTION_ID,
                                car.ID,
                                vEVENT_OBJECT,
                                p_SYSTRAN_ID,
                                p_SYSBATCH_REQ_ID,
                                car.ID);
      END IF;
      END LOOP;
   END;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      DBMS_OUTPUT.PUT_LINE (
            'SP_APP_DOCUMENT_REVIEW: Exception when executing BatchReqID: '
         || p_SYSBATCH_REQ_ID);
      RAISE;
END SP_APP_DOCUMENT_REVIEW;
/