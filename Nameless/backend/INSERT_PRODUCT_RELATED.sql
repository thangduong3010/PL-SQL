CREATE OR REPLACE PROCEDURE BACKEND_DEV.Insert_Product_Related IS
tmpVar NUMBER;
productID number;
productSYS number;
cursor listcondition is select * from LENDING_CONDITION ld where LD.AMND_STATE='F' and LD.CONDITION_CODE in ('C00000001', 'C00000002', 'C00000003', 'C00000054', 'C00000056',  'C00000058');
condition listcondition%ROWTYPE;

cursor listdocument is select * from DOCUMENT_CHECKLIST doc where DOC.AMND_STATE='F' and DOC.DOC_CODE in ('DOC160310006', 'DOC160310007', 'DOC160310008', 'DOC160310013', 'DOC160310014', 'DOC160310015', 'DOC160310016', 'DOC160310017');
documentRow listdocument%ROWTYPE;
/******************************************************************************
   NAME:       Insert_Product
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        13/03/2016   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     Insert_Product
      Sysdate:         13/03/2016
      Date and Time:   13/03/2016, 9:56:37 SA, and 13/03/2016 9:56:37 SA
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   Update LENDING_CONDITION LD set LD.AMND_STATE='E' where LD.ID = 207;
   select ID,SYS_TRAN_ID into productID,productSYS  from PRODUCT pro where PRO.AMND_STATE='F' and PRO.PRODUCT_CODE='RBCVTD_DEMO';
   open listcondition;
   loop
     fetch listcondition into condition;
     exit when listcondition%NOTFOUND;
     INSERT INTO BACKEND_DEV.PRODUCT_CONDITION ( SYS_TRAN_ID, UPD_SEQ, AMND_STATE, PRODUCT_ID, CONDITION_ID, CONDITION_WHEN, CONDITION_MUST, REVISION_CYCLE, COMPLETION_STAGE_ID) VALUES ( productSYS, 1, 'F', productID,condition.ID, Null,0, 6,8 );   
  
   end loop;
   close listcondition;
   
   
   open listdocument;
   loop
    fetch listdocument into documentRow;
    exit when listdocument%NOTFOUND;
    INSERT INTO BACKEND_DEV.PRODUCT_DOCUMENT (SYS_TRAN_ID, UPD_SEQ, AMND_STATE,PRODUCT_ID,DOC_ID,DOC_VAULT,DOC_MANDATORY,DOC_UPLOAD,REVISION_CYCLE, COMPLETION_STAGE_ID) VALUES (productSYS, 1, 'F', productID,documentRow.ID, 1, 1, 0, 6, 1 );
   
   end loop;
   
   close listdocument;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END Insert_Product_Related;
/