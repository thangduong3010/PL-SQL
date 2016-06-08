CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_RO_ByDynamicRule(cus_id in number,sys_tran in number) AS
dynamic_sql RELATED_OBJECT_RULE.SQL_CODE%TYPE;
countGroupRelated NUMBER;
groupID CUSTOMER_GROUP.ID%TYPE;
err_msg VARCHAR2(500);
TYPE cur_typ IS REF CURSOR;

            cusor                          cur_typ;
BEGIN
    FOR RelatedRule in (SELECT SQL_CODE 
                    FROM RELATED_OBJECT_RULE 
                    WHERE AMND_STATE = 'F')
    LOOP
    dynamic_sql := REPLACE(RelatedRule.SQL_CODE,'@CUSTOMERID',cus_id);
        dynamic_sql := REPLACE(dynamic_sql,'@SYSTRANID',sys_tran);
        OPEN cusor for dynamic_sql;
            LOOP
            FETCH cusor INTO groupID;
            
            EXIT WHEN cusor%NOTFOUND;
                SELECT COUNT(ID) INTO countGroupRelated FROM RELATED_OBJECT WHERE AMND_STATE <> 'E' AND CUSTOMER_ID = cus_id AND GROUP_ID = groupID;
                    IF countGroupRelated = 0 THEN
                        INSERT INTO RELATED_OBJECT(SYS_TRAN_ID,AUDIT_DATE, UPD_SEQ, AMND_STATE,CUSTOMER_ID,GROUP_ID,TYPE,SID,INHERIT_MENU_ACL)
                            VALUES (sys_tran,sysdate,0,'F',cus_id,groupID,'O',SQ_SID.nextval,1);
                    END IF;
            END LOOP;
        CLOSE cusor;
    END LOOP;
    EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    err_msg := SUBSTR(SQLERRM, 1, 200);
    DBMS_OUTPUT.PUT_LINE(err_msg);
    INSERT INTO RELATED_OBJECT_ERRORLOG(AUDIT_DATE,SP_NAME,CUSTOMER_ID,SYS_TRAN_ID,ERROR_DESC)
    VALUES
    (Sysdate,'SP_RO_ByDynamicRule',cus_id,sys_tran,err_msg);
    COMMIT;
END;
/