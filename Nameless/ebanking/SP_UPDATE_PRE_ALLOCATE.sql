CREATE OR REPLACE PROCEDURE DEMOEBANKING.SP_UPDATE_PRE_ALLOCATE(in_sid IN NUMBER,
                                                   in_date IN varchar,
                                                   in_product IN varchar,
                                                   in_amount IN number,
                                                   in_Branch IN varchar,
                                                   update_result OUT varchar)
is
begin
 UPDATE XP_PREPARE_ALLOCATE SET AC_BRANCH = in_Branch,
                                TRN_DT = TO_DATE(in_date,'dd/mm/yyyy'),
                                VALUE_DT = TO_DATE(in_date,'dd/mm/yyyy'),
                                PRODUCT = in_product,
                                LCY_AMOUNT = in_amount
                            WHERE SID = in_sid;                      
 update_result := 'sucess';
 COMMIT;
 EXCEPTION
 WHEN OTHERS THEN 
 update_result:= SUBSTR(SQLERRM, 1, 200);
 DBMS_OUTPUT.PUT_LINE(SUBSTR(SQLERRM, 1, 200));
 ROLLBACK;
end SP_UPDATE_PRE_ALLOCATE;
/