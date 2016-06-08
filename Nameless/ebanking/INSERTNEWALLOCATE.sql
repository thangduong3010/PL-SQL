CREATE OR REPLACE PROCEDURE DEMOEBANKING.InsertNewAllocate(p_ListName in varchar,
                                              p_maker in varchar,
                                              listId out number) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       InsertNewAllocate
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        08/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     InsertNewAllocate
      Sysdate:         08/12/2015
      Date and Time:   08/12/2015, 3:32:42 CH, and 08/12/2015 3:32:42 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := seq_xp_allocate_list.NEXTVAL;
 
   INSERT INTO DEMOEBANKING.XP_ALLOCATE_LIST (
   RECORD_STAT, PROC_ID, MOD_NO, 
   MAKER_TIME, MAKER, LIST_NAME, 
   LIST_ID, DEFINE_TYPE, AUTH_STAT) 
VALUES ( 'O',
   Null,
   0,
    SYSDATE,
    p_maker,
    p_ListName,
    tmpVar,
    'U',
    'A' );
    listId := tmpVar;
    commit;               
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END InsertNewAllocate;
/