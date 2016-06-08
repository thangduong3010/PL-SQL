CREATE OR REPLACE PROCEDURE DEMOEBANKING.UpdateRule (RULENAME in varchar2,
                                        CEN_ID in number,
                                        INC in number,
                                        EXC in number,
                                        REC in number,
                                        RULE_TYPE in char,
                                        CREDIT in varchar2,
                                        DEBIT in varchar2,
                                        SCHEDULE_START in char,
                                        SCHEINTERVAL in number,
                                        SCHEDULE_TYPE in char,
                                        RULEALLOCATE in number,
                                        PROFIT in char,
                                        PRODUCTLIST in varchar,
                                        RULEID in number ) IS
tmpVar NUMBER;
/******************************************************************************
   NAME:       UpdateRule
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        28/12/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     UpdateRule
      Sysdate:         28/12/2015
      Date and Time:   28/12/2015, 5:36:59 CH, and 28/12/2015 5:36:59 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   UPDATE XP_RULE SET RULE_NAME=RULENAME, CENTER_ID =CEN_ID, INC_LIST_ID = INC, EXC_LIST_ID=EXC,
                    RECURSIVE_LEVEL = REC,RULE_TYPE=RULE_TYPE, GL_CREDIT=CREDIT, GL_DEBIT =DEBIT,
                    SCHEDULE_START_DATE =To_Date(SCHEDULE_START,'DD/MM/YYYY'), SCHEDULE_INTERVAL = SCHEINTERVAL, SCHEDULE_TYPE =SCHEDULE_TYPE,
                    ALLOCATE_LIST_ID = RULEALLOCATE, PROFIT_COST = PROFIT,PRODUCT_LIST=PRODUCTLIST WHERE RULE_ID =RULEID;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END UpdateRule;
/