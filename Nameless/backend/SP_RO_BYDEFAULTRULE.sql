CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_RO_ByDefaultRule(cus_id in number,sys_tran in number) AS
countGroupRelated NUMBER;
err_msg VARCHAR2(500);
BEGIN
    FOR Relacus in (
        SELECT RELATED_CUSTOMER_ID AS RCUSID,RELATIONSHIP 
        FROM CUSTOMER_RELATION 
        WHERE CUSTOMER_ID = cus_id AND SYS_TRAN_ID = sys_tran AND EXTERNAL_CUSTOMER = 0)
    LOOP
        IF Relacus.RELATIONSHIP = 'M' THEN
           FOR cusGroup in (
                SELECT CGM.CUSTOMER_GROUP_ID AS ID
                FROM CUSTOMER_GROUP_MEMBER CGM join CUSTOMER_RELATION CR ON CGM.MEMBER_ID = CR.CUSTOMER_ID
                WHERE CGM.MEMBER_TYPE = 'C' 
                    AND CR.CUSTOMER_ID <> cus_id AND CR.RELATIONSHIP = 'M' AND CR.RELATED_CUSTOMER_ID = Relacus.RCUSID)
            LOOP
                SELECT COUNT(ID) INTO countGroupRelated FROM RELATED_OBJECT WHERE AMND_STATE <> 'E' AND CUSTOMER_ID = cus_id AND GROUP_ID = cusGroup.ID;
                IF countGroupRelated = 0 THEN
                    INSERT INTO RELATED_OBJECT(SYS_TRAN_ID,AUDIT_DATE, UPD_SEQ, AMND_STATE,CUSTOMER_ID,GROUP_ID,MANAGER_ID,TYPE,SID,INHERIT_MENU_ACL)
                        VALUES (sys_tran,Sysdate,0,'F',cus_id,cusGroup.ID,Relacus.RCUSID,'M',SQ_SID.nextval,1);
                END IF;
            END LOOP;
        ELSIF Relacus.RELATIONSHIP = 'S' THEN
            FOR cusGroup in (
                SELECT CGM.CUSTOMER_GROUP_ID AS ID
                FROM CUSTOMER_GROUP_MEMBER CGM join CUSTOMER_RELATION CR ON CGM.MEMBER_ID = CR.CUSTOMER_ID
                WHERE CGM.MEMBER_TYPE = 'C' 
                    AND CR.CUSTOMER_ID <> cus_id AND CR.RELATIONSHIP = 'S' AND CR.RELATED_CUSTOMER_ID = Relacus.RCUSID)
            LOOP
                SELECT COUNT(ID) INTO countGroupRelated FROM RELATED_OBJECT WHERE AMND_STATE <> 'E' AND CUSTOMER_ID = cus_id AND GROUP_ID = cusGroup.ID;
                 IF countGroupRelated = 0 THEN
                    INSERT INTO RELATED_OBJECT(SYS_TRAN_ID,AUDIT_DATE, UPD_SEQ, AMND_STATE,CUSTOMER_ID,GROUP_ID,SHAREHOLDER_ID,TYPE,SID,INHERIT_MENU_ACL)
                        VALUES (sys_tran,Sysdate,0,'F',cus_id,cusGroup.ID,Relacus.RCUSID,'S',SQ_SID.nextval,1);
                END IF;
            END LOOP;
        END IF;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
    ROLLBACK;
    err_msg := SUBSTR(SQLERRM, 1, 200);
    DBMS_OUTPUT.PUT_LINE(err_msg);
    INSERT INTO RELATED_OBJECT_ERRORLOG(AUDIT_DATE,SP_NAME,CUSTOMER_ID,SYS_TRAN_ID,ERROR_DESC)
    VALUES
    (Sysdate,'SP_RO_ByDefaultRule',cus_id,sys_tran,err_msg);
    COMMIT;
END;
/