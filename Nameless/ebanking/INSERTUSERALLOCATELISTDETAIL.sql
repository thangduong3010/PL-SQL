CREATE OR REPLACE PROCEDURE DEMOEBANKING.InsertUserAllocateListDetail(p_listid in number,
                                                         p_centerId in varchar2,
                                                         p_rate in number,
                                                         p_fixed in number,
                                                         p_min in number,
                                                         p_max in number) 
                                                         IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       InsertUserAllocateListDetail
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     InsertUserAllocateListDetail
      Sysdate:         08/12/2015
      Date and Time:   08/12/2015, 11:20:50 SA, and 08/12/2015 11:20:50 SA
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   INSERT INTO DEMOEBANKING.XP_ALLOCATE_LIST_DETAIL (RATE, MIN, MAX, LIST_ID, FIXED, CENTER_ID) VALUES (p_rate,p_min,p_max,p_listid,p_fixed,p_centerId );
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END InsertUserAllocateListDetail;
/