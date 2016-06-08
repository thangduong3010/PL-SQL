CREATE OR REPLACE PROCEDURE BACKEND_DEV.GetPreviousTranByTranId 
 (TRANID IN NUMBER ,
    RESULT out SYS_REFCURSOR  )
AS
BEGIN
   open RESULT for
   select *
   from SYS_TRANSACTION Tran
   start with Tran.sys_tran_id = TRANID
   connect by prior TRAN.SYS_TRAN_ID = TRAN.PREV_SYS_TRAN_ID;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;   
End GetPreviousTranByTranId;
/