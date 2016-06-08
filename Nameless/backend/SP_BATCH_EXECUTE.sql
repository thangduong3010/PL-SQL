CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_BATCH_EXECUTE (
   ENTRY_DATE        IN DATE,
   ENTRY_COMMENT     VARCHAR,
   EXECUTE_USER_ID      NUMBER)
IS
   nSysTranId      NUMBER;
   nBatchReqId     NUMBER;
   nSystemStatus   NUMBER;
/******************************************************************************
   NAME:       SP_BATCH_EXECUTE
   PURPOSE:    Run when user start batch.

******************************************************************************/

BEGIN
   -- If SYSTEM_STATUS is not in ACTIVE, return
   SELECT COUNT (1)
     INTO nSystemStatus
     FROM CONSTANTS
    WHERE CONSTANT_TYPE = 'SYSTEM_STATUS' AND CONSTANT_VALUE = 'A';

   IF (nSystemStatus != 1)
   THEN
      RETURN;
   END IF;

   -- Create SYS_TRANSACTION record and get SYS_TRAN_ID
   INSERT INTO SYS_TRANSACTION (USER_ID,
                                TRAN_START,
                                TRAN_CODE,
                                TRAN_ACTION,
                                TRAN_STATUS,
                                COMMENTS)
        VALUES (EXECUTE_USER_ID                                  /* USER_ID */
                               ,
                SYSDATE                                       /* TRAN_START */
                       ,
                'BATCH-01'                                     /* TRAN_CODE */
                          ,
                'B'                                          /* TRAN_ACTION */
                   ,
                'C'                                          /* TRAN_STATUS */
                   ,
                'Batch Running'                                 /* COMMENTS */
                               )
     RETURNING SYS_TRAN_ID
          INTO nSysTranId;
    DBMS_OUTPUT.PUT_LINE(nSysTranId);
   INSERT INTO SYS_BATCH_REQ (SYS_TRAN_ID,
                              AUDIT_DATE,
                              AUDIT_OPERATION,
                              APPROVAL_STATUS,
                              UPD_SEQ,
                              AMND_STATE,
                              BATCH_REQ_NO,
                              USER_ID,
                              ENTRY_DATE,
                              BATCH_DATE,
                              START_AT,
                              STATUS,
                              COMMENTS,
                              INHERIT_MENU_ACL,
                              SID)
        VALUES (nSysTranId                                   /* SYS_TRAN_ID */
                          ,
                SYSDATE                                       /* AUDIT_DATE */
                       ,
                'I'                                      /* AUDIT_OPERATION */
                   ,
                'A'                                      /* APPROVAL_STATUS */
                   ,
                0                                                /* UPD_SEQ */
                 ,
                'F'                                           /* AMND_STATE */
                   ,
                SEQ_BATCH_REQ_NO.NEXTVAL                    /* BATCH_REQ_NO */
                                        ,
                EXECUTE_USER_ID                                  /* USER_ID */
                               ,
                ENTRY_DATE                                    /* ENTRY_DATE */
                          ,
                ENTRY_DATE                                    /* BATCH_DATE */
                          ,
                SYSDATE                                         /* START_AT */
                       ,
                'P'                                               /* STATUS */
                   ,
                   ENTRY_COMMENT,
                1,                                        /*INHERIT_MENU_ACL*/
                SQ_SID.NEXTVAL                                       /* SID */
                              )
     RETURNING ID
          INTO nBatchReqId;
DBMS_OUTPUT.PUT_LINE(nBatchReqId);
   -- Update SYSTEM_STATUS to 'Batch Started'
   UPDATE CONSTANTS
      SET CONSTANT_VALUE = 'S'
    WHERE CONSTANT_TYPE = 'SYSTEM_STATUS';

   -- Begin executing Batching for each Event.

   -- Event: CUSTOMER_REVIEW
   -- EventID: 3
   SP_EXECEVENT_CUSTOMER_REVIEW (nSysTranId, nBatchReqId, ENTRY_DATE);
    DBMS_OUTPUT.PUT_LINE('CUSTOMER_REVIEW');
    COMMIT;
   -- Event: COLLATERAL_INSURANCE
   -- EventID:4
   SP_COLLATERAL_INSURANCE (nSysTranId, nBatchReqId, ENTRY_DATE);
   COMMIT;
    DBMS_OUTPUT.PUT_LINE('SECTOR');
   -- Event: BUSINESS_SECTOR_REPORT
   -- EventID: 5
   SP_BUSINESS_SECTOR_REPORT (nSysTranId, nBatchReqId, ENTRY_DATE);
DBMS_OUTPUT.PUT_LINE('MANUAL_REVALUATION');
COMMIT;
   -- Event: MANUAL_REVALUATION
   -- EventID: 6
   SP_EXECEVENT_MANUAL_REVAL (nSysTranId, nBatchReqId, ENTRY_DATE);
   COMMIT;
DBMS_OUTPUT.PUT_LINE('RESET_LIMIT');
   -- Event: MANUAL_RESET_LIMIT
   -- EventID: 7
   SP_MANUAL_RESET_LIMIT (nSysTranId, nBatchReqId, ENTRY_DATE);
   COMMIT;
   DBMS_OUTPUT.PUT_LINE('VALUE_REVALUATION');
   -- Event: COLLATERAL_VALUE_REVALUATION
   -- EventID: 10
   SP_COLLATERAL_VALUE_DECREASE (nSysTranId, nBatchReqId, ENTRY_DATE);
   COMMIT;
   -- Event: AUTOMATIC_RESET_LIMIT
   -- EventID: 8
   SP_AUTOMATIC_RESET_LIMIT (nSysTranId, nBatchReqId, ENTRY_DATE);
   COMMIT;
   -- Event: AUTOMATIC_REVALUATION
   -- EventID: 9
   SP_AUTO_REVALUATION (nSysTranId, nBatchReqId, ENTRY_DATE);
   COMMIT;
   -- Event: APPLICATION_DOCUMENT_REVIEW
   -- EventID: 11
   SP_APP_DOCUMENT_REVIEW (nSysTranId, nBatchReqId, ENTRY_DATE);
   COMMIT;
      -- Event: APPLICATION_CONDITION_REVIEW
   -- EventID: 11
   SP_APP_CONDITION_REVIEW (nSysTranId, nBatchReqId, ENTRY_DATE);
   COMMIT;
   -- End executing ....
   -- End executing Batching for each Event.

   -- Update Batch Status to Finished
   UPDATE SYS_BATCH_REQ
      SET FINISH_AT = SYSDATE, STATUS = 'F'
    WHERE ID = nBatchReqId;

   -- Update SYSTEM_STATUS to 'Active'
   UPDATE CONSTANTS
      SET CONSTANT_VALUE = 'A'
    WHERE CONSTANT_TYPE = 'SYSTEM_STATUS';

   COMMIT;
   DBMS_OUTPUT.PUT_LINE ('End SP_BATCH_EXECUTE ' || nBatchReqId);
EXCEPTION
    
   WHEN OTHERS
   THEN
      UPDATE SYS_BATCH_REQ
         SET FINISH_AT = SYSDATE, STATUS = 'E'
       WHERE ID = nBatchReqId;

      UPDATE CONSTANTS
         SET CONSTANT_VALUE = 'A'
       WHERE CONSTANT_TYPE = 'SYSTEM_STATUS';

      COMMIT;
      -- Consider logging the error
      DBMS_OUTPUT.PUT_LINE ('Error in SP_BATCH_EXECUTE: ' || nBatchReqId);
END SP_BATCH_EXECUTE;
/