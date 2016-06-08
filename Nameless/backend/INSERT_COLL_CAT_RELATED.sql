CREATE OR REPLACE PROCEDURE BACKEND_DEV.Insert_Coll_Cat_Related
IS
   tmpVar        NUMBER;
   CC01ID        NUMBER;
   CC01SYS       NUMBER;
   CC10ID        NUMBER;
   CC10SYS       NUMBER;

   CURSOR listDocument
   IS
      SELECT *
        FROM DOCUMENT_CHECKLIST doc
       WHERE     DOC.AMND_STATE = 'F'
             AND DOC.DOC_CODE IN ('DOC160310010',
                                  'DOC160310011',
                                  'DOC160310012');

   documentRow   DOCUMENT_CHECKLIST%ROWTYPE;

   CURSOR listcondition
   IS
      SELECT *
        FROM LENDING_CONDITION ld
       WHERE     LD.AMND_STATE = 'F'
             AND LD.CONDITION_CODE IN ('CON201603104',
                                       'CON201603105',
                                       'CON201603107');

   condition     listcondition%ROWTYPE;
/******************************************************************************
   NAME:       Insert_Coll_Cat_Related
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/03/2016   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Insert_Coll_Cat_Related
      Sysdate:         13/03/2016
      Date and Time:   13/03/2016, 10:08:39 SA, and 13/03/2016 10:08:39 SA
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;

   SELECT ID, SYS_TRAN_ID
     INTO CC01ID, CC01SYS
     FROM COLL_CATEGORY cc
    WHERE CC.AMND_STATE = 'F' AND CC.COLL_CAT_CODE = 'CC01';

   SELECT ID, SYS_TRAN_ID
     INTO CC10ID, CC10SYS
     FROM COLL_CATEGORY cc
    WHERE CC.AMND_STATE = 'F' AND CC.COLL_CAT_CODE = 'CC010';

   /******** Coll-Cat CCO1****************/
   OPEN listDocument;

   LOOP
      FETCH listDocument INTO documentRow;

      EXIT WHEN listDocument%NOTFOUND;

      INSERT INTO BACKEND_DEV.COLL_CAT_CONDITION (SYS_TRAN_ID,
                                                  UPD_SEQ,
                                                  AMND_STATE,
                                                  COLL_CAT_ID,
                                                  CONDITION_ID,
                                                  CONDITION_WHEN,
                                                  CONDITION_MUST,
                                                  REVISION_CYCLE,
                                                  COMPLETION_STAGE_ID)
           VALUES (CC01SYS,
                   1,
                   'F',
                   CC01ID,
                   documentRow.ID,
                   NULL,
                   1,
                   6,
                   8);
   END LOOP;

   CLOSE listDocument;

   OPEN listcondition;

   LOOP
      FETCH listcondition INTO condition;

      EXIT WHEN listcondition%NOTFOUND;

      INSERT INTO BACKEND_DEV.COLL_CAT_DOCUMENT (SYS_TRAN_ID,
                                                 UPD_SEQ,
                                                 AMND_STATE,
                                                 COLL_CAT_ID,
                                                 DOC_ID,
                                                 DOC_VAULT,
                                                 DOC_MANDATORY,
                                                 DOC_UPLOAD,
                                                 REVISION_CYCLE,
                                                 COMPLETION_STAGE_ID)
           VALUES (CC01SYS,
                   1,
                   'F',
                   CC01ID,
                   condition.ID,
                   1,
                   1,
                   0,
                   6,
                   8);
   END LOOP;

   CLOSE listcondition;


   /*********Coll-Cat CCO10**************/
   INSERT INTO BACKEND_DEV.COLL_CAT_CONDITION (SYS_TRAN_ID,
                                               UPD_SEQ,
                                               AMND_STATE,
                                               COLL_CAT_ID,
                                               CONDITION_ID,
                                               CONDITION_WHEN,
                                               CONDITION_MUST,
                                               REVISION_CYCLE,
                                               COMPLETION_STAGE_ID)
           VALUES (
                     CC10SYS,
                     1,
                     'F',
                     CC10ID,
                     (SELECT ID
                        FROM LENDING_CONDITION ld
                       WHERE     LD.AMND_STATE = 'F'
                             AND LD.CONDITION_CODE = 'CON201603104'),
                     NULL,
                     1,
                     6,
                     8);

   INSERT INTO BACKEND_DEV.COLL_CAT_CONDITION (SYS_TRAN_ID,
                                               UPD_SEQ,
                                               AMND_STATE,
                                               COLL_CAT_ID,
                                               CONDITION_ID,
                                               CONDITION_WHEN,
                                               CONDITION_MUST,
                                               REVISION_CYCLE,
                                               COMPLETION_STAGE_ID)
           VALUES (
                     CC10SYS,
                     1,
                     'F',
                     CC10ID,
                     (SELECT ID
                        FROM LENDING_CONDITION ld
                       WHERE     LD.AMND_STATE = 'F'
                             AND LD.CONDITION_CODE = 'CON201603106'),
                     NULL,
                     0,
                     6,
                     8);


   INSERT INTO BACKEND_DEV.COLL_CAT_DOCUMENT (SYS_TRAN_ID,
                                              UPD_SEQ,
                                              AMND_STATE,
                                              COLL_CAT_ID,
                                              DOC_ID,
                                              DOC_VAULT,
                                              DOC_MANDATORY,
                                              DOC_UPLOAD,
                                              REVISION_CYCLE,
                                              COMPLETION_STAGE_ID)
           VALUES (
                     CC10SYS,
                     1,
                     'F',
                     CC10ID,
                     (SELECT ID
                        FROM DOCUMENT_CHECKLIST doc
                       WHERE     DOC.AMND_STATE = 'F'
                             AND DOC.DOC_CODE = 'DOC160310009'),
                     1,
                     1,
                     0,
                     6,
                     8);
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END Insert_Coll_Cat_Related;
/