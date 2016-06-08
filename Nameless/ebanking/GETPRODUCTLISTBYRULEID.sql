CREATE OR REPLACE PROCEDURE DEMOEBANKING.GetProductListByRuleID(ruleId in number,
                                                   product_List out varchar) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       GetProductListByRuleID
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     GetProductListByRuleID
      Sysdate:         30/12/2015
      Date and Time:   30/12/2015, 3:04:41 CH, and 30/12/2015 3:04:41 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   select XPR.PRODUCT_LIST into product_List from XP_RULE xpr where XPR.RULE_ID=ruleId;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END GetProductListByRuleID;
/