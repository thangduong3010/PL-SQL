CREATE OR REPLACE PROCEDURE BACKEND_DEV.Insert_Collateral_Document
IS
   tmpVar         NUMBER;

   CURSOR listCollateral
   IS
      SELECT *
        FROM COLLATERAL coll
       WHERE COLL.COLLATERAL_CODE IN ('AA 0551297',
                                      'STK AA0765684',
                                      'STK PG2',
                                      'STK PG1',
                                      '01QSH NHA - DAT',
                                      'CANHO',
                                      '8322/9268',
                                      'QSD DAT 0059/13');

   collaterlRow   listCollateral%ROWTYPE;

   CURSOR listDocument (
      coll_cat_id    COLLATERAL.COLL_CAT_ID%TYPE)
   IS
      SELECT *
        FROM DOCUMENT_CHECKLIST doc
       WHERE DOC.ID IN (SELECT CCD.DOC_ID
                          FROM COLL_CAT_DOCUMENT ccd
                         WHERE     CCD.COLL_CAT_ID = coll_cat_id
                               AND CCD.AMND_STATE = 'F');

   documentRow    listDocument%ROWTYPE;
/******************************************************************************
   NAME:       Insert_Collateral_Document
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/03/2016   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Insert_Collateral_Document
      Sysdate:         12/03/2016
      Date and Time:   12/03/2016, 4:43:11 CH, and 12/03/2016 4:43:11 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;

   OPEN listCollateral;

   LOOP
      FETCH listCollateral INTO collaterlRow;

      EXIT WHEN listCollateral%NOTFOUND;
       Delete from COLLATERAL_DOCUMENT collD where COLLD.COLLATERAL_ID = collaterlRow.ID;    
      OPEN listDocument (collaterlRow.COLL_CAT_ID);

      LOOP
         FETCH listDocument INTO documentRow;

         EXIT WHEN listDocument%NOTFOUND;
         
         INSERT INTO BACKEND_DEV.COLLATERAL_DOCUMENT (SYS_TRAN_ID,
                                                      UPD_SEQ,
                                                      AMND_STATE,
                                                      COLLATERAL_ID,
                                                      DOCUMENT_ID,
                                                      DOC_VAULT,
                                                      DOC_MANDATORY,
                                                      DOC_UPLOAD,
                                                      COMPLETION_STAGE_ID,
                                                      NEW_REQUIRED,
                                                      STATUS)
              VALUES (collaterlRow.SYS_TRAN_ID,
                      1,
                      'F',
                      collaterlRow.ID,
                      documentRow.ID,
                      documentRow.DOC_VAULT,
                      documentRow.DOC_MANDATORY,
                      documentRow.DOC_UPLOAD,
                      documentRow.COMPLETION_STAGE_ID,
                      0,
                      'A');
      END LOOP;

      CLOSE listDocument;
   END LOOP;

   CLOSE listCollateral;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      ROLLBACK;
      NULL;
   WHEN OTHERS
   THEN
      ROLLBACK;
      -- Consider logging the error and then re-raise
      RAISE;
END Insert_Collateral_Document;
/