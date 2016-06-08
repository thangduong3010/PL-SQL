CREATE OR REPLACE PROCEDURE DEMOEBANKING.DemoTest(p_Votcde in varchar2, 
                                     p_progaramd in  varchar2,
                                     p_codename in varchar2,
                                     p_codedesc in varchar2) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       DemoTest
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        03/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     DemoTest
      Sysdate:         03/12/2015
      Date and Time:   03/12/2015, 5:14:29 CH, and 03/12/2015 5:14:29 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   INSERT INTO DEMOEBANKING.VOTING_LIST (VOTE_CODE, PROGRAM_ID, CODE_NAME, CODE_DESC) VALUES (p_Votcde,p_progaramd,p_codename,p_codedesc );
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END DemoTest;
/