CREATE OR REPLACE PROCEDURE DEMOEBANKING.SP_UPDATE_ALLOCATE_USER (listID in number,listName in varchar2) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       SP_UPDATE_ALLOCATE_USER
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        23/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     SP_UPDATE_ALLOCATE_USER
      Sysdate:         23/12/2015
      Date and Time:   23/12/2015, 10:47:36 SA, and 23/12/2015 10:47:36 SA
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   update XP_ALLOCATE_LIST xpl set XPL.LIST_NAME = listName where XPL.LIST_ID=listID;
   commit;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END SP_UPDATE_ALLOCATE_USER;
/