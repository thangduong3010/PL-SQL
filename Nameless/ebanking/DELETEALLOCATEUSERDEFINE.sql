CREATE OR REPLACE PROCEDURE DEMOEBANKING.DeleteAllocateUserDefine (AllocateID in number) IS 
tmpVar NUMBER;
/******************************************************************************
   NAME:       DeleteAllocateUserDefine
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        22/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     DeleteAllocateUserDefine
      Sysdate:         22/12/2015
      Date and Time:   22/12/2015, 5:59:18 CH, and 22/12/2015 5:59:18 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   delete from XP_ALLOCATE_LIST_DETAIL xld where XLD.LIST_ID=  AllocateID;
   delete from XP_ALLOCATE_LIST xpl where XPL.LIST_ID = AllocateID;
   commit;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END DeleteAllocateUserDefine;
/