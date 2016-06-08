CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_BUSINESS_SECTOR_REPORT 
(
  P_SYSTRAN_ID IN NUMBER 
, P_SYSBATCH_REQ_ID IN NUMBER 
, P_ENTRY_DATE IN DATE 
) AS 
BEGIN
    DECLARE
      BUSINESS_SECTOR_REPORT_ID   NUMBER := 5;
      vEVENT_CODE                EVENT_DEF.EVENT_CODE%TYPE;
      vEVENT_DESC                EVENT_DEF.EVENT_DESC%TYPE;
      vEVENT_OBJECT              EVENT_DEF.EVENT_OBJECT%TYPE;
      vEVENT_EXECUTION_ID        NUMBER;
   BEGIN
      SELECT EVENT_CODE, EVENT_DESC, EVENT_OBJECT
        INTO vEVENT_CODE, vEVENT_DESC, vEVENT_OBJECT
        FROM EVENT_DEF
       WHERE ID = BUSINESS_SECTOR_REPORT_ID;

      FOR cusbiz IN (SELECT ID
                       FROM CUST_BIZ_GROUP
                       WHERE REPORT_REVIEW_CYCLE <> 0
                       AND REPORT_REVIEW_CYCLE IS NOT NULL
                       AND REPORT_LAST_UPDATE IS NOT NULL
                       AND AMND_STATE = 'F'
                       AND (ADD_MONTHS(REPORT_LAST_UPDATE,REPORT_REVIEW_CYCLE) <= SYSDATE))
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
                      BUSINESS_SECTOR_REPORT_ID,
                      /* EVENT_CODE */
                      vEVENT_CODE,
                      /* EVENT_DESC */
                      vEVENT_DESC,
                      /* EVENT_OBJECT */
                      vEVENT_OBJECT,
                      /* OBJECT_ID */
                      cusbiz.ID,
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

         SP_RUN_ACTION_EVENT (BUSINESS_SECTOR_REPORT_ID,
                              vEVENT_EXECUTION_ID,
                              cusbiz.ID,
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
            'SP_BUSINESS_SECTOR_REPORT: Exception when executing BatchReqID: '
         || p_SYSBATCH_REQ_ID);
      RAISE;
END SP_BUSINESS_SECTOR_REPORT;
/