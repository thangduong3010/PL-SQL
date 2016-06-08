CREATE OR REPLACE PROCEDURE BACKEND_DEV.Insert_Customer_Document
IS
   tmpVar        NUMBER;

   CURSOR listdoc
   IS
      SELECT b.*
        FROM CR_MODEL_CRITERIA a, CR_CRITERIA b
       WHERE     A.CR_MODEL_ID = 115
             AND A.AMND_STATE = 'F'
             AND B.CRITERIA_TYPE = 'R'
             AND A.CRITERIA_ID = B.ID;

   documentRow   CR_CRITERIA%ROWTYPE;
/******************************************************************************
   NAME:       Insert_Customer_Document
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/03/2016   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Insert_Customer_Document
      Sysdate:         12/03/2016
      Date and Time:   12/03/2016, 4:02:42 CH, and 12/03/2016 4:02:42 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;

   OPEN listdoc;

   LOOP
      FETCH listdoc INTO documentRow;

      EXIT WHEN listdoc%NOTFOUND;

      INSERT
        INTO BACKEND_DEV.CR_CONDITION_CRITERIA_SCORE (SYS_TRAN_ID,AUDIT_DATE,
                                                      UPD_SEQ,
                                                      AMND_STATE,
                                                      RATING_CONDITION_ID,
                                                      CRITERIA_ID,
                                                      SCORE)
      VALUES (2000,
              SYSDATE,
              1,
              'F',
              65,
              documentRow.ID,
              30);

      INSERT
        INTO BACKEND_DEV.CR_CONDITION_CRITERIA_RATIO (SYS_TRAN_ID,
                                                      AUDIT_DATE,
                                                      UPD_SEQ,
                                                      AMND_STATE,
                                                      RATING_CONDITION_ID,
                                                      CRITERIA_ID,
                                                      RATIO)
      VALUES (2000,
              SYSDATE,
              1,
              'F',
              65,
              documentRow.ID,
              0.12);
   END LOOP;
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
END Insert_Customer_Document;
/