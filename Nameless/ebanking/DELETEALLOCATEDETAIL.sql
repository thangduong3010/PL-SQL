CREATE OR REPLACE PROCEDURE DEMOEBANKING.DeleteAllocateDetail(p_centerId in varchar2,
                                                 p_ListId in number) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       DeleteAllocateDetail
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        10/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     DeleteAllocateDetail
      Sysdate:         10/12/2015
      Date and Time:   10/12/2015, 4:10:20 CH, and 10/12/2015 4:10:20 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   delete from XP_ALLOCATE_LIST_DETAIL xld where XLD.CENTER_ID = p_centerId and XLD.LIST_ID = p_ListId;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END DeleteAllocateDetail;
/