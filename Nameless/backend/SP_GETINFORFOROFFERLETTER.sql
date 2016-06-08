CREATE OR REPLACE PROCEDURE BACKEND_DEV.sp_GetInforForOfferLetter (
   ID       IN     NUMBER,
   RESULT      OUT NVARCHAR2)
IS
   tmpVar   NUMBER;
/******************************************************************************
   NAME:       sp_GetInforForGenerateDocument
   PURPOSE:

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        5/5/2015   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     sp_GetInforForGenerateDocument
      Sysdate:         5/5/2015
      Date and Time:   5/5/2015, 5:30:55 PM, and 5/5/2015 5:30:55 PM
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := ID;      
   
   SELECT XMLSERIALIZE (
             CONTENT XMLELEMENT (
                        "Items",
                        XMLELEMENT ("PARENTDEPTNAME", PD.DEPT_NAME),
                        XMLELEMENT ("DEPTNAME", D.DEPT_NAME),
                        XMLELEMENT ("CUSTOMERNAME", CUS.CUSTOMER_NAME),
                        XMLELEMENT ("SUBMITAMOUNT", CAR.SUBMIT_AMOUNT),
                        XMLELEMENT ("APPLICATIONCODE", CAR.APPLICATION_CODE),
                        XMLELEMENT ("RMNAME", SU.USER_NAME),
                        XMLELEMENT ("APPROVALDATE", CAR.APPROVAL_DATE),
                        XMLELEMENT("TableInsert", 
                        XMLELEMENT ("TableName", 'Collateral'),                        
                        (SELECT XMLAGG (
                                  XMLELEMENT ("TableRow", 
                                        XMLELEMENT ("TableCell", COLLATERAL_DESC),
                                        XMLELEMENT ("TableCell", EVALUATION_VALUE),
                                        XMLELEMENT ("TableCell", CONTRIBUTE_AMOUNT)
                                   ))
                           FROM CAR_COLLATERAL CC
                                INNER JOIN COLLATERAL C
                                   ON CC.COLLATERAL_ID = C.ID
                                INNER JOIN COLLATERAL_PRICING CP
                                   ON C.ID = CP.COLLATERAL_ID
                                INNER JOIN PRICING_LINE PL
                                   ON CP.PRICING_LINE_ID = PL.ID
                          WHERE     CC.APPLICATION_ID = tmpVar
                                AND PL.IS_PRIMARY = 1))))
     INTO RESULT
     FROM CREDIT_APPLICATION_REQUEST CAR
          INNER JOIN DEPARTMENT D ON CAR.DEPT_ID = D.ID
          LEFT JOIN DEPARTMENT PD ON D.PARENT_ID = PD.ID
          INNER JOIN CUSTOMER CUS ON CAR.CUSTOMER_ID = CUS.ID
          INNER JOIN SYS_USER SU ON CAR.RELATIONSHIP_MANAGER_ID = SU.ID
    WHERE CAR.ID = tmpVar;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END sp_GetInforForOfferLetter;
/