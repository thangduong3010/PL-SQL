CREATE OR REPLACE PROCEDURE BACKEND_DEV.Inser_New_Document_Related IS
tmpVar NUMBER;
productID number;
docID number;
systran number;
/******************************************************************************
   NAME:       Inser_New_Document_Related
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/03/2016   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Inser_New_Document_Related
      Sysdate:         12/03/2016
      Date and Time:   12/03/2016, 3:39:47 CH, and 12/03/2016 3:39:47 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   INSERT INTO BACKEND_DEV.DOCUMENT_CHECKLIST (
      SYS_TRAN_ID, UPD_SEQ, 
       AMND_STATE, DOC_CODE, DOC_NAME, 
       DOC_CATEGORY, DOC_ORG, DOC_VAULT, 
       DOC_MANDATORY, DOC_UPLOAD, DOC_FOR_LENDER, 
       DOC_FOR_OWNER, DOC_STATUS, INHERIT_MENU_ACL, 
       SID, COMPLETION_STAGE_ID) 
        VALUES (
         SQ_SYS_TRANSACTION_ID.nextval,
         1,
         'F',
         'DOC160310018',
         'Báo cáo th?m d?nh',
         'S',
         'C',
         1,
         1,
         0,
         0,
         1,
         'A',
         '1',
         SQ_SID.nextval,
         8);
    Select ID,PR.SYS_TRAN_ID into productID,systran from PRODUCT pr where PR.PRODUCT_CODE ='RBCVTD_DEMO' and PR.AMND_STATE='F';
    select ID into docID from DOCUMENT_CHECKLIST doc where DOC.DOC_CODE='DOC160310018' and DOC.AMND_STATE='F';
    
    INSERT INTO BACKEND_DEV.PRODUCT_DOCUMENT (SYS_TRAN_ID, UPD_SEQ, AMND_STATE,PRODUCT_ID,DOC_ID,DOC_VAULT,DOC_MANDATORY,DOC_UPLOAD,REVISION_CYCLE, COMPLETION_STAGE_ID) VALUES (systran, 1, 'F', productID,docID, 1, 1, 0, 6, 8 );
     
     Commit;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       ROllBACK;
       NULL;
     WHEN OTHERS THEN
        ROLLBACK;
       -- Consider logging the error and then re-raise
       RAISE;
END Inser_New_Document_Related;
/