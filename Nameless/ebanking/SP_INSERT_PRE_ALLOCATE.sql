CREATE OR REPLACE PROCEDURE DEMOEBANKING.SP_INSERT_PRE_ALLOCATE(in_date IN varchar,
                                                   in_product IN varchar,
                                                   in_amount IN number,
                                                   in_Branch IN varchar,
                                                   inser_result OUT number,
                                                   refno_result out number)
is
refno   VARCHAR2 (35);
tempsid NUMBER;
begin
refno:= lpad(FAKENUMBERTRANSACTION.nextval,6,'0');
tempsid:= XPPA_SIDSEQ.Nextval;
 INSERT INTO XP_PREPARE_ALLOCATE(MODULE,
                                 TRN_REF_NO,
                                 AC_BRANCH,AC_NO,
                                 AC_CCY,EVENT,TRN_CODE,
                                 AMOUNT_TAG,
                                 FCY_AMOUNT,
                                 LCY_AMOUNT,
                                 TRN_DT,
                                 VALUE_DT,
                                 PRODUCT,
                                 ENTRY_SEQ_NO,
                                 SOURCE,
                                 INPUT_TIME,
                                 STATUS,SID)
                          VALUES('XP',refno,in_Branch,'748000001','VND','XPMT','XPA','XP_AMT_PAID',0,in_amount,TO_DATE(in_date,'dd/mm/yyyy'),TO_DATE(in_date,'dd/mm/yyyy'),in_product,1,'CORE',SYSDATE,'A',tempsid);                                
 inser_result :=tempsid;
 refno_result :=refno;
 COMMIT;
 EXCEPTION
 WHEN OTHERS THEN 
 inser_result:= SUBSTR(SQLERRM, 1, 200);
 DBMS_OUTPUT.PUT_LINE(SUBSTR(SQLERRM, 1, 200));
 ROLLBACK;
end SP_INSERT_PRE_ALLOCATE;
/