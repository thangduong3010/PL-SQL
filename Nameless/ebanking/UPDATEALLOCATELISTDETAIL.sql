CREATE OR REPLACE PROCEDURE DEMOEBANKING.UpdateAllocateListDetail(rate in number,minval in number,maxval in number,fixed in number,newcenter in varchar2,listId in number,oldcenter in varchar2) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       UpdateAllocateListDetail
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     UpdateAllocateListDetail
      Sysdate:         08/12/2015
      Date and Time:   08/12/2015, 5:00:07 CH, and 08/12/2015 5:00:07 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   UPDATE XP_ALLOCATE_LIST_DETAIL
    SET    RATE      = rate,
           MIN       = minval,
           MAX       = maxval,
           FIXED     = fixed,
           CENTER_ID = newcenter
WHERE  LIST_ID   = listId
AND    CENTER_ID = oldcenter;
EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END UpdateAllocateListDetail;
/