CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_EXECEVENT_MANUAL_REVAL (
   p_SYSTRAN_ID         NUMBER,
   p_SYSBATCH_REQ_ID    NUMBER,
   p_ENTRY_DATE           DATE)
IS
/******************************************************************************
   NAME:       SP_EXECEVENT_MANUAL_REVALUATION
   PURPOSE:    Execute event MANUAL_REVALUATION

******************************************************************************/
BEGIN
   DECLARE
        COLLATERAL_REVIEW_EVENT_ID   NUMBER := 6;
        vEVENT_CODE                EVENT_DEF.EVENT_CODE%TYPE;
        vEVENT_DESC                EVENT_DEF.EVENT_DESC%TYPE;
        vEVENT_OBJECT              EVENT_DEF.EVENT_OBJECT%TYPE;
      vEVENT_EXECUTION_ID        NUMBER;
   BEGIN
      SELECT EVENT_CODE, EVENT_DESC, EVENT_OBJECT
        INTO vEVENT_CODE, vEVENT_DESC, vEVENT_OBJECT
        FROM EVENT_DEF
       WHERE ID = COLLATERAL_REVIEW_EVENT_ID;

      FOR coll IN (SELECT C.ID FROM COLLATERAL C
                        JOIN COLL_CATEGORY CC ON C.COLL_CAT_ID = CC.ID
                        JOIN COLL_CAT_PRICING CCP ON CC.ID = CCP.COLL_CAT_ID
                        JOIN COLLATERAL_PRICING CP ON C.ID = CP.COLLATERAL_ID
                    WHERE C.AMND_STATE = 'F'
                        AND CCP.REVALUATION_METHOD = 'A' 
                        AND CP.NEXT_EVALUATION_DATE <= p_ENTRY_DATE)
      LOOP
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
                      COLLATERAL_REVIEW_EVENT_ID,
                      /* EVENT_CODE */
                      vEVENT_CODE,
                      /* EVENT_DESC */
                      vEVENT_DESC,
                      /* EVENT_OBJECT */
                      vEVENT_OBJECT,
                      /* OBJECT_ID */
                      coll.ID,
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

         SP_RUN_ACTION_EVENT (COLLATERAL_REVIEW_EVENT_ID,
                              vEVENT_EXECUTION_ID,
                              coll.ID,
                              vEVENT_OBJECT,
                              p_SYSTRAN_ID,
                              p_SYSBATCH_REQ_ID,
                              
                              null);

         UPDATE EVENT_EXECUTION
            SET ERROR_CODE = 'F'
          WHERE ID = vEVENT_EXECUTION_ID;
      END LOOP;
   END;
EXCEPTION
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      DBMS_OUTPUT.PUT_LINE (
            'SP_EXECEVENT_MANUAL_REVALUATION: Exception when executing BatchReqID: '
         || p_SYSBATCH_REQ_ID);
      RAISE;
END SP_EXECEVENT_MANUAL_REVAL;
/