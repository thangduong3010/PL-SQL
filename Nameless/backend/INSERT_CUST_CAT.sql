CREATE OR REPLACE PROCEDURE BACKEND_DEV.Insert_Cust_Cat
IS
   tmpVar        NUMBER;
   CUC008ID      NUMBER;
   CUC008SYS     NUMBER;

   CUC2011ID     NUMBER;
   CUC2011SYS    NUMBER;
   CUC1189ID     NUMBER;
   CUC1189SYS    NUMBER;

   CURSOR listCondition
   IS
      SELECT *
        FROM LENDING_CONDITION ld
       WHERE     LD.AMND_STATE = 'F'
             AND LD.CONDITION_CODE IN ('CON201603101',
                                       'CON201603102',
                                       'CON201603103');

   condition     listCondition%ROWTYPE;

   CURSOR listDocument
   IS
      SELECT *
        FROM DOCUMENT_CHECKLIST doc
       WHERE     DOC.AMND_STATE = 'F'
             AND DOC.DOC_CODE IN ('DOC160310001',
                                  'DOC160310002',
                                  'DOC160310003',
                                  'DOC160310004',
                                  'DOC160310005');

   documentRow   listDocument%ROWTYPE;
/******************************************************************************
   NAME:       Insert_Cust_Cat
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/03/2016   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Insert_Cust_Cat
      Sysdate:         13/03/2016
      Date and Time:   13/03/2016, 9:36:03 SA, and 13/03/2016 9:36:03 SA
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;

   SELECT ID, CUSTCAT.SYS_TRAN_ID
     INTO CUC008ID, CUC008SYS
     FROM CUST_CATEGORY custcat
    WHERE CUSTCAT.CUST_CAT_CODE = 'CUC008' AND CUSTCAT.AMND_STATE = 'F';

   SELECT ID, CUSTCAT.SYS_TRAN_ID
     INTO CUC2011ID, CUC2011SYS
     FROM CUST_CATEGORY custcat
    WHERE CUSTCAT.CUST_CAT_CODE = 'CUC2011' AND CUSTCAT.AMND_STATE = 'F';

   SELECT ID, CUSTCAT.SYS_TRAN_ID
     INTO CUC1189ID, CUC1189SYS
     FROM CUST_CATEGORY custcat
    WHERE CUSTCAT.CUST_CAT_CODE = 'CUC1189' AND CUSTCAT.AMND_STATE = 'F';

   OPEN listCondition;
   Delete from CUST_CAT_CONDITION ccon where CCON.CUST_CAT_ID in (CUC008ID,CUC2011ID,CUC1189ID);
   LOOP
      FETCH listCondition INTO condition;

      EXIT WHEN listCondition%NOTFOUND;

      INSERT INTO BACKEND_DEV.CUST_CAT_CONDITION (SYS_TRAN_ID,
                                                  UPD_SEQ,
                                                  AMND_STATE,
                                                  CUST_CAT_ID,
                                                  CONDITION_ID,
                                                  CONDITION_WHEN,
                                                  CONDITION_MUST,
                                                  REVISION_CYCLE,
                                                  COMPLETION_STAGE_ID)
           VALUES (CUC008SYS,
                   1,
                   'F',
                   CUC008ID,
                   condition.ID,
                   NULL,
                   1,
                   6,
                   1);

      INSERT INTO BACKEND_DEV.CUST_CAT_CONDITION (SYS_TRAN_ID,
                                                  UPD_SEQ,
                                                  AMND_STATE,
                                                  CUST_CAT_ID,
                                                  CONDITION_ID,
                                                  CONDITION_WHEN,
                                                  CONDITION_MUST,
                                                  REVISION_CYCLE,
                                                  COMPLETION_STAGE_ID)
           VALUES (CUC2011SYS,
                   1,
                   'F',
                   CUC2011ID,
                   condition.ID,
                   NULL,
                   1,
                   6,
                   1);

      INSERT INTO BACKEND_DEV.CUST_CAT_CONDITION (SYS_TRAN_ID,
                                                  UPD_SEQ,
                                                  AMND_STATE,
                                                  CUST_CAT_ID,
                                                  CONDITION_ID,
                                                  CONDITION_WHEN,
                                                  CONDITION_MUST,
                                                  REVISION_CYCLE,
                                                  COMPLETION_STAGE_ID)
           VALUES (CUC1189SYS,
                   1,
                   'F',
                   CUC1189ID,
                   condition.ID,
                   null,
                   1,
                   6,
                   1);
   END LOOP;

   CLOSE listCondition;

Delete from CUST_CAT_DOCUMENT ccdoc where ccdoc.CUST_CAT_ID in (CUC008ID,CUC2011ID,CUC1189ID);

   OPEN listDocument;

   LOOP
      FETCH listDocument INTO documentRow;

      EXIT WHEN listDocument%NOTFOUND;

      INSERT INTO BACKEND_DEV.CUST_CAT_DOCUMENT (SYS_TRAN_ID,
                                                 UPD_SEQ,
                                                 AMND_STATE,
                                                 CUST_CAT_ID,
                                                 DOC_ID,
                                                 DOC_VAULT,
                                                 DOC_MANDATORY,
                                                 DOC_UPLOAD,
                                                 REVISION_CYCLE,
                                                 COMPLETION_STAGE_ID)
           VALUES (CUC008SYS,
                   1,
                   'F',
                   CUC008ID,
                   documentRow.ID,
                   1,
                   1,
                   0,
                   6,
                   8);

      INSERT INTO BACKEND_DEV.CUST_CAT_DOCUMENT (SYS_TRAN_ID,
                                                 UPD_SEQ,
                                                 AMND_STATE,
                                                 CUST_CAT_ID,
                                                 DOC_ID,
                                                 DOC_VAULT,
                                                 DOC_MANDATORY,
                                                 DOC_UPLOAD,
                                                 REVISION_CYCLE,
                                                 COMPLETION_STAGE_ID)
           VALUES (CUC2011SYS,
                   1,
                   'F',
                   CUC2011ID,
                   documentRow.ID,
                   1,
                   1,
                   0,
                   6,
                   8);

      INSERT INTO BACKEND_DEV.CUST_CAT_DOCUMENT (SYS_TRAN_ID,
                                                 UPD_SEQ,
                                                 AMND_STATE,
                                                 CUST_CAT_ID,
                                                 DOC_ID,
                                                 DOC_VAULT,
                                                 DOC_MANDATORY,
                                                 DOC_UPLOAD,
                                                 REVISION_CYCLE,
                                                 COMPLETION_STAGE_ID)
           VALUES (CUC1189SYS,
                   1,
                   'F',
                   CUC1189ID,
                   documentRow.ID,
                   1,
                   1,
                   0,
                   6,
                   8);
   END LOOP;

   CLOSE listDocument;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
      ROLLBACK;
   WHEN OTHERS
   THEN
      ROLLBACK;
      -- Consider logging the error and then re-raise
      RAISE;
END Insert_Cust_Cat;
/