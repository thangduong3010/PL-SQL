CREATE OR REPLACE PROCEDURE BACKEND_DEV.InsertApprovalMatrix IS
tmpVar NUMBER;
deptID number;
productID number;
CustCatId number;
systran number;
/******************************************************************************
   NAME:       InsertApprovalMatrix
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/03/2016   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     InsertApprovalMatrix
      Sysdate:         12/03/2016
      Date and Time:   12/03/2016, 3:02:44 CH, and 12/03/2016 3:02:44 CH
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
   select ID into deptID from DEPARTMENT dept where DEPT.DEPT_ID='DEPT0001' and DEPT.AMND_STATE='F';
   select ID into productID from PRODUCT pr where PR.PRODUCT_CODE='RBCVTD_DEMO' and PR.AMND_STATE='F';
   select ID into CustCatId from CUST_CATEGORY custcat where CUSTCAT.CUST_CAT_CODE ='CUC003' and CUSTCAT.AMND_STATE='F';
   select SQ_SYS_TRANSACTION_ID.nextval into systran from dual;
INSERT INTO BACKEND_DEV.APPROVAL_MATRIX (SYS_TRAN_ID, UPD_SEQ, AMND_STATE, PRODUCT_ID, DEPT_ID, CUST_CAT_ID, USER_LEVEL, LIQUIDITY_LEVEL, CREDIT_RATE, SECURE_AMOUNT, UNSECURE_AMOUNT, SID, INHERIT_MENU_ACL) VALUES ( systran, 1, 'F', productID, deptID,CustCatId,1, 'H', 'A', 1000000000, 1000000000, SQ_SID.nextval, 1 );
INSERT INTO BACKEND_DEV.APPROVAL_MATRIX (SYS_TRAN_ID, UPD_SEQ, AMND_STATE, PRODUCT_ID, DEPT_ID, CUST_CAT_ID, USER_LEVEL, LIQUIDITY_LEVEL, CREDIT_RATE, SECURE_AMOUNT, UNSECURE_AMOUNT, SID, INHERIT_MENU_ACL) VALUES ( systran, 1, 'F', productID, deptID,CustCatId,2, 'H', 'A', 5000000000, 5000000000, SQ_SID.nextval, 1 );
INSERT INTO BACKEND_DEV.APPROVAL_MATRIX (SYS_TRAN_ID, UPD_SEQ, AMND_STATE, PRODUCT_ID, DEPT_ID, CUST_CAT_ID, USER_LEVEL, LIQUIDITY_LEVEL, CREDIT_RATE, SECURE_AMOUNT, UNSECURE_AMOUNT, SID, INHERIT_MENU_ACL) VALUES ( systran, 1, 'F', productID, deptID,CustCatId,3, 'H', 'A', 10000000000, 10000000000, SQ_SID.nextval, 1 );
INSERT INTO BACKEND_DEV.APPROVAL_MATRIX (SYS_TRAN_ID, UPD_SEQ, AMND_STATE, PRODUCT_ID, DEPT_ID, CUST_CAT_ID, USER_LEVEL, LIQUIDITY_LEVEL, CREDIT_RATE, SECURE_AMOUNT, UNSECURE_AMOUNT, SID, INHERIT_MENU_ACL) VALUES ( systran, 1, 'F', productID, deptID,CustCatId,4, 'H', 'A', 15000000000, 15000000000, SQ_SID.nextval, 1 );
INSERT INTO BACKEND_DEV.APPROVAL_MATRIX (SYS_TRAN_ID, UPD_SEQ, AMND_STATE, PRODUCT_ID, DEPT_ID, CUST_CAT_ID, USER_LEVEL, LIQUIDITY_LEVEL, CREDIT_RATE, SECURE_AMOUNT, UNSECURE_AMOUNT, SID, INHERIT_MENU_ACL) VALUES ( systran, 1, 'F', productID, deptID,CustCatId,5, 'H', 'A', 20000000000, 20000000000, SQ_SID.nextval, 1 );
INSERT INTO BACKEND_DEV.APPROVAL_MATRIX (SYS_TRAN_ID, UPD_SEQ, AMND_STATE, PRODUCT_ID, DEPT_ID, CUST_CAT_ID, USER_LEVEL, LIQUIDITY_LEVEL, CREDIT_RATE, SECURE_AMOUNT, UNSECURE_AMOUNT, SID, INHERIT_MENU_ACL) VALUES ( systran, 1, 'F', productID, deptID,CustCatId,6, 'H', 'A', 99000000000, 99000000000, SQ_SID.nextval, 1 );
    Commit;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
        ROLLBACK;
       NULL;
     WHEN OTHERS THEN
        ROLLBACK;
       -- Consider logging the error and then re-raise
       RAISE;
END InsertApprovalMatrix;
/