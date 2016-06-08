CREATE OR REPLACE PROCEDURE DEMOEBANKING.DeleteRuleMapingManual(ruleId in number) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       DeleteRuleMapingManual
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        30/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     DeleteRuleMapingManual
      Sysdate:         30/12/2015
      Date and Time:   30/12/2015, 5:08:31 CH, and 30/12/2015 5:08:31 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   Delete from XP_RULE_MAPPING xpm where XPM.RULE_ID=ruleId and XPM.ALLOCATE_TYPE='M';
   commit;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END DeleteRuleMapingManual;
/