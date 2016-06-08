CREATE OR REPLACE PROCEDURE DEMOEBANKING.SelectTranAfferAllocate (ruleId in number,
                                                     p_out out SYS_REFCURSOR)
IS 
/******************************************************************************
   NAME:       SelectTranAfferAllocate
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        15/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SelectTranAfferAllocate
      Sysdate:         15/12/2015
      Date and Time:   15/12/2015, 4:25:56 CH, and 15/12/2015 4:25:56 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   open p_out for select XP.TRAN_DATE,XP.TRAN_REF_NO,XP.CONTRACT_NO,XP.AMOUNT,xp.CENTER_ID from XP_TRANSACTION xp
   where 
   XP.RULE_ID = ruleId and xp.AMOUNT > 0
   and to_date(xp.TRAN_DATE,'DD/MM/YYYY') = to_date(sysdate,'DD/MM/YYYY');
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END SelectTranAfferAllocate;
/