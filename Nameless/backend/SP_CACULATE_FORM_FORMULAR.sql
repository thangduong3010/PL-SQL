CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_CACULATE_FORM_FORMULAR (FORMULAR IN  VARCHAR2, COLL_PRICE_ID IN NUMBER, RESULT OUT NUMBER)
IS
   
    cmd varchar(2000) := 'SELECT ' || FORMULAR ||' FROM COLLATERAL_PRICING cp '||
    'join collateral c on cp.Collateral_id = c.id '||
    'where CP.AMND_STATE =''F'' AND cp.id = '||COLL_PRICE_ID||' ';
BEGIN
    DECLARE
    temp number :=0;
        begin
        DBMS_OUTPUT.PUT_LINE('Dang tinh gia tri cua coll price: '||COLL_PRICE_ID);
        DBMS_OUTPUT.PUT_LINE(cmd);
        EXECUTE IMMEDIATE cmd into result ;
        
        /*Tinh toan so chu so sau dau thap phan*/
        temp := (length(to_char(trunc( result,0))) ); 
        if 14 -temp >= 0 then
            result := trunc(result, 14-temp);
        else
            result := trunc(result,0);
        end if;
        
        end;
END SP_CACULATE_FORM_FORMULAR;
/