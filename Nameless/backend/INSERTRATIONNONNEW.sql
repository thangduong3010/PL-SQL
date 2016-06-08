CREATE OR REPLACE PROCEDURE BACKEND_DEV.InsertRationNonNew IS
tmpVar NUMBER;
parentID number;
hiepath varchar2(20);
/******************************************************************************
   NAME:       InsertRationNonNew
   PURPOSE:    

   REVISIONS:
   Ver        Date        Author           Description
   ---------  ----------  ---------------  ------------------------------------
   1.0        12/03/2016   Administrator       1. Created this procedure.

   NOTES:

   Automatically available Auto Replace Keywords:
      Object Name:     InsertRationNonNew
      Sysdate:         12/03/2016
      Date and Time:   12/03/2016, 8:53:44 SA, and 12/03/2016 8:53:44 SA
      Username:        Administrator (set in TOAD Options, Procedure Editor)
      Table Name:       (set in the "New PL/SQL Object" dialog)

******************************************************************************/
BEGIN
   tmpVar := 0;
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR100', 'Ðánh giá kh? nang tr? n? c?a khách hàng', null, 'N', 'Ðánh giá kh? nang tr? n? c?a khách hàng', 'A', 'M', 'N', 'N', 1, 0, '#' );
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR200', 'Thông tin các ch? tiêu khác', null, 'N', 'Thông tin các ch? tiêu khác', 'A', 'M', 'N', 'N', 1, 0,'#' );
/******Con cua NR100********/
Select ID into parentID from CR_RATIO cr where CR.RATIO_CODE = 'NR100' and CR.AMND_STATE='F';
hiepath := '#' || to_char(parentID) || '#';
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR101', 'Tri?n v?ng phát tri?n c?a co quan ngu?i tham gia tr? n? dang công tác ho?c tri?n v?ng phát tri?n c?a ho?t d?ng kinh doanh, lao d?ng mà ngu?i tham gia tr? n? dang th?c hi?n', parentID, 'N', 'Tri?n v?ng phát tri?n c?a co quan ngu?i tham gia tr? n? dang công tác ho?c tri?n v?ng phát tri?n c?a ho?t d?ng kinh doanh, lao d?ng mà ngu?i tham gia tr? n? dang th?c hi?n', 'A', 'M', 'N', 'N', 1, 0, hiepath );
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR102', 'Hình th?c tr? luong ho?c chuy?n thu nh?p khác', parentID, 'N', 'Hình th?c tr? luong ho?c chuy?n thu nh?p khác', 'A', 'M', 'N', 'N', 1, 0, hiepath );
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR103', 'Hình th?c h?p d?ng lao d?ng', parentID, 'N', 'Hình th?c h?p d?ng lao d?ng', 'A', 'M', 'N', 'N', 1, 0, hiepath );
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR104', 'T?ng thu nh?p hàng tháng c?a ngu?i tham gia tr? n?', parentID, 'N', 'T?ng thu nh?p hàng tháng c?a ngu?i tham gia tr? n?', 'A', 'M', 'N', 'N', 1, 0, hiepath );
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR105', 'M?c thu nh?p ròng ?n d?nh hàng tháng c?a nh?ng ngu?i tham gia tr? n?', parentID, 'N', 'M?c thu nh?p ròng ?n d?nh hàng tháng c?a nh?ng ngu?i tham gia tr? n?', 'A', 'M', 'N', 'N', 1, 0, hiepath );
/********Con cua NR200*****/
Select ID into parentID from CR_RATIO cr where CR.RATIO_CODE = 'NR200' and CR.AMND_STATE='F';
hiepath := '#' || to_char(parentID) || '#';
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR201', 'Lo?i hình co quan dang công tác', parentID, 'N', 'Lo?i hình co quan dang công tác', 'A', 'M', 'N', 'N', 1, 0, hiepath );
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR202', 'Th?i gian làm trong linh v?c chuyên môn hi?n t?i', parentID, 'N', 'Th?i gian làm trong linh v?c chuyên môn hi?n t?i', 'A', 'M', 'N', 'N', 1, 0, hiepath );
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR203', 'Th?i gian công tác t?i co quan hi?n t?i', parentID, 'N', 'Th?i gian công tác t?i co quan hi?n t?i', 'A', 'M', 'N', 'N', 1, 0, hiepath );
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR204', 'R?i ro ngh? nghi?p (th?t nghi?p, tai n?n ngh? nghi?p, nhân m?ng,...)', parentID, 'N', 'R?i ro ngh? nghi?p (th?t nghi?p, tai n?n ngh? nghi?p, nhân m?ng,...)', 'A', 'M', 'N', 'N', 1, 0, hiepath );
INSERT INTO CR_RATIO ( SYS_TRAN_ID,UPD_SEQ, AMND_STATE, SID, INHERIT_MENU_ACL, RATIO_CODE, RATIO_NAME, PARENT_ID, RATIO_TYPE, DESCRIPTION,STATUS, INPUT_TYPE, VALUE_TYPE,MANUAL_INPUT_TYPE, RATIO_INDEX, INHERIT_PARENT_ACL, HIERARCHY_PATH)VALUES ( SQ_SYS_TRANSACTION_ID.nextval, 1, 'F', SQ_SID.nextval, 1,'NR205', 'V? trí công tác', parentID, 'N', 'V? trí công tác', 'A', 'M', 'N', 'N', 1, 0, hiepath );

   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
     WHEN OTHERS THEN
       -- Consider logging the error and then re-raise
       RAISE;
END InsertRationNonNew;
/