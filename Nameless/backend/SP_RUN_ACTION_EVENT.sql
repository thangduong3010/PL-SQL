CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_RUN_ACTION_EVENT (
   p_EVENT_ID              NUMBER,
   p_EVENT_EXECUTION_ID    NUMBER,
   p_OBJECT_ID             NUMBER,
   p_EVENT_OBJECT          CHAR,
   p_SYSTRAN_ID            NUMBER,
   p_SYSBATCH_REQ_ID       NUMBER,
   p_CAR_COLL_ID           NUMBER)
IS
/******************************************************************************
   NAME:       SP_RUN_ACTION_EVENT
   PURPOSE:    From EVENT_EXECUTION -> RUN ALL ACTION
******************************************************************************/
BEGIN
   -- BEGIN Automatic run EVENT_ACTION
   FOR EventActionDef IN (SELECT ID,
                                 EVENT_ID,
                                 EVENT_ACTION,
                                 TIME_FRAME,
                                 EVENT_DESTINATION,
                                 ACTION_SUMMARY,
                                 ACTION_CONTENT
                            FROM EVENT_ACTION_DEF
                           WHERE EVENT_ID = p_EVENT_ID)
   LOOP
      DECLARE
         vDESTINATION   EVENT_ACTION_EXECUTION.DESTINATION%TYPE := '';
         vDESTINATION2   EVENT_ACTION_EXECUTION.DESTINATION%TYPE := '';
         vSPECIAL       EVENT_OBJECT_PROPS.PROPERTY_SPECIAL_SOURCE%TYPE;
         vSUMMARY       EVENT_ACTION_EXECUTION.SUMMARY%TYPE := '';
         vCONTENT       EVENT_ACTION_EXECUTION.CONTENT%TYPE := '';
         vDEADLINE      EVENT_ACTION_EXECUTION.DEADLINE%TYPE := NULL;
         vENTRY_DATE    EVENT_ACTION_EXECUTION.ENTRY_DATE%TYPE := SYSDATE;
      BEGIN
        
         -- Get dynamic content from EVENT_OBJECT_PROPS
         IF EventActionDef.TIME_FRAME IS NOT NULL
         THEN
            vDEADLINE := vENTRY_DATE + EventActionDef.TIME_FRAME;
         END IF;

         vSUMMARY := EventActionDef.ACTION_SUMMARY;
         vCONTENT := EventActionDef.ACTION_CONTENT;
         DBMS_OUTPUT.PUT_LINE('1-------------------');
         FOR EventObj IN (SELECT OBJECT_PROPERTY,
                                 PROPERTY_SOURCE,
                                 PROPERTY_SOURCE_TABLE,
                                 PROPERTY_SOURCE_FILTER
                            FROM EVENT_OBJECT_PROPS
                           WHERE OBJECT_TYPE = p_EVENT_OBJECT)
         LOOP
            DECLARE
               vDynamicSQL            VARCHAR2 (32767);
               vDynamicResult         VARCHAR2 (32767);
               vConditionCode         VARCHAR2 (32767);
               vTemp                  VARCHAR2 (32767);
               vConditionID           NUMBER;
               vConditionIDResult     NUMBER;
               TYPE cur_typ IS REF CURSOR;

               c                          cur_typ;
            BEGIN
            DBMS_OUTPUT.PUT_LINE('Bang:');
            DBMS_OUTPUT.PUT_LINE(EventObj.PROPERTY_SOURCE_TABLE);
            IF(EventObj.PROPERTY_SOURCE_TABLE <> 'CREDIT_APPLICATION_REQUEST'
             AND EventObj.PROPERTY_SOURCE_TABLE <> 'CAR_CUSTOMER_CONDITIONS'
             AND EventObj.PROPERTY_SOURCE_TABLE <> 'CAR_APPLICATION_CONDITIONS'
             AND EventObj.PROPERTY_SOURCE_TABLE <> 'CAR_COLLATERAL_CONDITIONS'
             AND EventObj.PROPERTY_SOURCE_TABLE <> 'CAR_CUSTOMER_DOCUMENTS'
             AND EventObj.PROPERTY_SOURCE_TABLE <> 'CAR_COLLATERAL_DOCUMENTS'
             AND EventObj.PROPERTY_SOURCE_TABLE <> 'CAR_APPLICATION_DOCUMENTS'
             AND EventActionDef.EVENT_ID <> 11 
             AND EventActionDef.EVENT_ID <> 12 )
             THEN
             DBMS_OUTPUT.PUT_LINE('Quet cac bang ko phai Condition/Document');
             DBMS_OUTPUT.PUT_LINE(vSUMMARY);
             DBMS_OUTPUT.PUT_LINE(vCONTENT);
               vDynamicSQL :=
                     'SELECT '
                  || EventObj.PROPERTY_SOURCE
                  || ' FROM '
                  || EventObj.PROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (EventObj.PROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));
               vDynamicSQL := vDynamicSQL || ' AND ROWNUM = 1';
               DBMS_OUTPUT.PUT_LINE(vDynamicSQL);
               EXECUTE IMMEDIATE vDynamicSQL INTO vDynamicResult;
               DBMS_OUTPUT.PUT_LINE('2.5--------------------');
               DBMS_OUTPUT.PUT_LINE(vDynamicResult);
               vSUMMARY :=
                  REPLACE (vSUMMARY,
                           EventObj.OBJECT_PROPERTY,
                           vDynamicResult);
               vCONTENT :=
                  REPLACE (vCONTENT,
                           EventObj.OBJECT_PROPERTY,
                           vDynamicResult);
                           DBMS_OUTPUT.PUT_LINE(vSUMMARY);
             DBMS_OUTPUT.PUT_LINE(vCONTENT);
                
              END IF;      
              IF(EventObj.PROPERTY_SOURCE_TABLE = 'CREDIT_APPLICATION_REQUEST')
             THEN
                vDynamicSQL :=
                     'SELECT '
                  || EventObj.PROPERTY_SOURCE
                  || ' FROM '
                  || EventObj.PROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (EventObj.PROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_CAR_COLL_ID));
               vDynamicSQL := vDynamicSQL || ' AND ROWNUM = 1';
                
               EXECUTE IMMEDIATE vDynamicSQL INTO vDynamicResult;

               vSUMMARY :=
                  REPLACE (vSUMMARY,
                           EventObj.OBJECT_PROPERTY,
                           vDynamicResult);
               vCONTENT :=
                  REPLACE (vCONTENT,
                           EventObj.OBJECT_PROPERTY,
                           vDynamicResult);
                
             END IF;
             IF (EventObj.PROPERTY_SOURCE_TABLE = 'CAR_COLLATERAL_CONDITIONS'
                OR EventObj.PROPERTY_SOURCE_TABLE = 'CAR_CUSTOMER_CONDITIONS'
                OR EventObj.PROPERTY_SOURCE_TABLE = 'CAR_APPLICATION_CONDITIONS'
                OR EventObj.PROPERTY_SOURCE_TABLE = 'CAR_COLLATERAL_DOCUMENTS'
                OR EventObj.PROPERTY_SOURCE_TABLE = 'CAR_CUSTOMER_DOCUMENTS'
                OR EventObj.PROPERTY_SOURCE_TABLE = 'CAR_APPLICATION_DOCUMENTS')
                THEN
                
            BEGIN
                DBMS_OUTPUT.PUT_LINE('2-------------------');
                
               vDynamicSQL :=
                     'SELECT '
                  || EventObj.PROPERTY_SOURCE
                  || ' FROM '
                  || EventObj.PROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (EventObj.PROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));
                DBMS_OUTPUT.PUT_LINE(vDynamicSQL);
               OPEN c FOR vDynamicSQL;

               LOOP
                  FETCH c INTO vTemp;
                    
                  EXIT WHEN c%NOTFOUND;
                          IF (EventObj.PROPERTY_SOURCE_TABLE = 'CAR_COLLATERAL_CONDITIONS'
                            OR EventObj.PROPERTY_SOURCE_TABLE = 'CAR_CUSTOMER_CONDITIONS'
                            OR EventObj.PROPERTY_SOURCE_TABLE = 'CAR_APPLICATION_CONDITIONS')
                            THEN
                          -- process row here
                                 FOR Condition IN (SELECT CONDITION_CODE
                                          FROM LENDING_CONDITION
                                         WHERE ID = TO_NUMBER (vTemp))
                                 LOOP
                                    vConditionCode := Condition.CONDITION_CODE || ',' || vConditionCode;
                                 END LOOP;
                         END IF;
                        IF (EventObj.PROPERTY_SOURCE_TABLE = 'CAR_COLLATERAL_DOCUMENTS'
                            OR EventObj.PROPERTY_SOURCE_TABLE = 'CAR_CUSTOMER_DOCUMENTS'
                            OR EventObj.PROPERTY_SOURCE_TABLE = 'CAR_APPLICATION_DOCUMENTS')
                            THEN
                          -- process row here
                                FOR documents IN (SELECT DOC_CODE
                                          FROM DOCUMENT_CHECKLIST
                                         WHERE ID = TO_NUMBER (vTemp))
                                 LOOP
                                    vConditionCode := documents.DOC_CODE || ',' || vConditionCode;
                                 END LOOP;
                        END IF;
               END LOOP;
               CLOSE c;

               vSUMMARY :=
                  REPLACE (vSUMMARY,
                           EventObj.OBJECT_PROPERTY,
                           vConditionCode);
               vCONTENT :=
                  REPLACE (vCONTENT,
                           EventObj.OBJECT_PROPERTY,
                           vConditionCode);
                 DBMS_OUTPUT.PUT_LINE('3------------------');          
               DBMS_OUTPUT.PUT_LINE(vSUMMARY);
         DBMS_OUTPUT.PUT_LINE(vCONTENT);
            END;
             END IF;
            END;
         END LOOP;
         -- Get Data For DESTINATION and Run Action
         DECLARE
            vOBJECT_PROPERTY           EVENT_OBJECT_PROPS.OBJECT_PROPERTY%TYPE;
            vPROPERTY_SOURCE           EVENT_OBJECT_PROPS.PROPERTY_SOURCE%TYPE;
            vPROPERTY_SOURCE_TABLE     EVENT_OBJECT_PROPS.PROPERTY_SOURCE_TABLE%TYPE;
            vPROPERTY_SOURCE_FILTER    EVENT_OBJECT_PROPS.PROPERTY_SOURCE_FILTER%TYPE;
            vPROPERTY_SPECIAL_SOURCE   EVENT_OBJECT_PROPS.PROPERTY_SPECIAL_SOURCE%TYPE;
            vPROPERTY_SPECIAL_FILTER    EVENT_OBJECT_PROPS.PROPERTY_SPECIAL_FILTER%TYPE;
            vPROPERTY_SPECIAL_TABLE   EVENT_OBJECT_PROPS.PROPERTY_SPECIAL_TABLE%TYPE;
            vSPECIAL_JOIN_CONDITION    EVENT_OBJECT_PROPS.SPECIAL_JOIN_CONDITION%TYPE;
            vDynamicSQL                VARCHAR2 (300);
            vTemp                      VARCHAR2 (100);
            vTemp2                      VARCHAR2 (100);
            nCount                     NUMBER;
            vBatchID                   NUMBER;
            

            TYPE cur_typ IS REF CURSOR;

            c                          cur_typ;
         BEGIN
            SELECT COUNT (1)
              INTO nCount
              FROM EVENT_OBJECT_PROPS
             WHERE     OBJECT_TYPE = p_EVENT_OBJECT
                   AND OBJECT_PROPERTY = EventActionDef.EVENT_DESTINATION
                   AND ROWNUM = 1;

            IF (nCount = 1)
            THEN
               SELECT OBJECT_PROPERTY,
                      PROPERTY_SOURCE,
                      PROPERTY_SOURCE_TABLE,
                      PROPERTY_SOURCE_FILTER,
                      PROPERTY_SPECIAL_SOURCE,
                      PROPERTY_SPECIAL_FILTER,
                      PROPERTY_SPECIAL_TABLE,
                      SPECIAL_JOIN_CONDITION
                 INTO vOBJECT_PROPERTY,
                      vPROPERTY_SOURCE,
                      vPROPERTY_SOURCE_TABLE,
                      vPROPERTY_SOURCE_FILTER,
                      vPROPERTY_SPECIAL_SOURCE,
                      vPROPERTY_SPECIAL_FILTER,
                      vPROPERTY_SPECIAL_TABLE,
                      vSPECIAL_JOIN_CONDITION
                 FROM EVENT_OBJECT_PROPS
                WHERE     OBJECT_TYPE = p_EVENT_OBJECT
                      AND OBJECT_PROPERTY = EventActionDef.EVENT_DESTINATION
                      AND ROWNUM = 1;
                IF(p_EVENT_ID <> 10)
                THEN
               vDynamicSQL :=
                     'SELECT '
                  || vPROPERTY_SOURCE
                  || ' FROM '
                  || vPROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (vPROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));
                    
                   OPEN c FOR vDynamicSQL;
                   LOOP
                      FETCH c INTO vTemp;
                      
                      EXIT WHEN c%NOTFOUND;
                      -- process row here
                      vDESTINATION := vDESTINATION || ',' || vTemp ;
                   END LOOP;
                   vDESTINATION := vDESTINATION || ',';
                   CLOSE c;
               END IF;
               
               IF(p_EVENT_ID = 10)
                THEN
               vDynamicSQL :=
                     'SELECT '
                  || vPROPERTY_SOURCE
                  || ' FROM '
                  || vPROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (vPROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_CAR_COLL_ID));
                    
                   OPEN c FOR vDynamicSQL;
                   LOOP
                      FETCH c INTO vTemp;
                      
                      EXIT WHEN c%NOTFOUND;
                      -- process row here
                      vDESTINATION := vDESTINATION || ',' || vTemp ;
                   END LOOP;
                   vDESTINATION := vDESTINATION || ',';
                   CLOSE c;
               END IF;
               /*vDESTINATION := TRIM (LEADING ',' FROM vDESTINATION);*/
               DBMS_OUTPUT.PUT_LINE('4---------------');
               DBMS_OUTPUT.PUT_LINE(vDESTINATION);
               IF(vPROPERTY_SPECIAL_TABLE IS NULL)
               THEN
                vSPECIAL :=
                     'SELECT '
                  || vPROPERTY_SPECIAL_SOURCE
                  || ' FROM '
                  || vPROPERTY_SOURCE_TABLE
                  || ' JOIN '
                  || vPROPERTY_SPECIAL_TABLE
                  || ' '
                  || vSPECIAL_JOIN_CONDITION
                  || ' '
                  || REPLACE (vPROPERTY_SPECIAL_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_CAR_COLL_ID));
               END IF;
               IF(vPROPERTY_SPECIAL_TABLE IS NOT NULL AND vPROPERTY_SOURCE_TABLE = 'CREDIT_APPLICATION_REQUEST')
               THEN
                vSPECIAL :=
                     'SELECT '
                  || vPROPERTY_SPECIAL_SOURCE
                  || ' FROM '
                  || vPROPERTY_SOURCE_TABLE
                  || ' JOIN '
                  || vPROPERTY_SPECIAL_TABLE
                  || ' '
                  || vSPECIAL_JOIN_CONDITION
                  || ' '
                  || REPLACE (vPROPERTY_SPECIAL_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_CAR_COLL_ID));
               END IF;
               IF(vPROPERTY_SPECIAL_TABLE IS NOT NULL AND vPROPERTY_SOURCE_TABLE = 'CUSTOMER')
               THEN
                vSPECIAL :=
                     'SELECT '
                  || vPROPERTY_SPECIAL_SOURCE
                  || ' FROM '
                  || vPROPERTY_SOURCE_TABLE
                  || ' JOIN '
                  || vPROPERTY_SPECIAL_TABLE
                  || ' '
                  || vSPECIAL_JOIN_CONDITION
                  || ' '
                  || REPLACE (vPROPERTY_SPECIAL_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));
               END IF;
               IF(vPROPERTY_SPECIAL_TABLE IS NULL)
               THEN
               vSPECIAL :=
                     'SELECT '
                  || vPROPERTY_SPECIAL_SOURCE
                  || ' FROM '
                  || vPROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (vPROPERTY_SPECIAL_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));
                    
                END IF;
               IF(vPROPERTY_SOURCE_TABLE = 'COLLATERAL')
               THEN
               IF(vDESTINATION IS NOT NULL)
               THEN
               vDESTINATION2 := TRIM (LEADING ',' FROM vDESTINATION);
               vDESTINATION2 := TRIM(TRAILING ',' FROM vDESTINATION2);
               DBMS_OUTPUT.PUT_LINE(vDESTINATION2||',');
                IF(vDESTINATION2 IS NOT NULL)
                   THEN
                    vSPECIAL :=
                     'SELECT '
                  || vPROPERTY_SPECIAL_SOURCE
                  || ' FROM '
                  || vPROPERTY_SOURCE_TABLE
                  || ' JOIN '
                  || vPROPERTY_SPECIAL_TABLE
                  || ' '
                  || REPLACE(vSPECIAL_JOIN_CONDITION,'$MANAGE_BY',
                                TO_CHAR(vDESTINATION2))
                  || ' '
                  || REPLACE (vPROPERTY_SPECIAL_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));
                  
                    END IF;
                 END IF; 
               
              END IF;
             DBMS_OUTPUT.PUT_LINE(vSPECIAL);
            END IF;
            
            IF(EventActionDef.EVENT_ACTION = 'M')
            THEN
                DECLARE 
                    vACTIONEXECUTE             EVENT_ACTION_EXECUTION.ID%TYPE;
                    vCountAction               NUMBER;
                BEGIN
                    -- Check record existed in table? 
                SELECT COUNT(EA.ID) INTO vCountAction FROM EVENT_ACTION_EXECUTION EA
                        WHERE EA.EVENT_OBJECT = p_EVENT_OBJECT AND EA.OBJECT_ID = p_OBJECT_ID
                             AND EA.DEADLINE < SYSDATE AND ROWNUM = 1;
                    IF(vCountAction >= 1)
                    THEN
                    -- Create record for Action
                    INSERT INTO EVENT_ACTION_EXECUTION (SYS_TRAN_ID,
                                                        AUDIT_DATE,
                                                        AUDIT_OPERATION,
                                                        APPROVAL_STATUS,
                                                        UPD_SEQ,
                                                        AMND_STATE,
                                                        ACTION_CODE,
                                                        SOURCE_TRAN_ID,
                                                        BATCH_REQ_ID,
                                                        EVENT_ID,
                                                        EVENT_ACTION_ID,
                                                        EVENT_OBJECT,
                                                        OBJECT_ID,
                                                        ACTION,
                                                        DESTINATION,
                                                        SUMMARY,
                                                        CONTENT,
                                                        ENTRY_DATE,
                                                        DEADLINE,
                                                        ACTION_DATE,
                                                        STATUS,
                                                        TIMESTAMP,
                                                        ERROR_CODE,
                                                        INHERIT_MENU_ACL,
                                                        SID)
                         VALUES (                                    /* SYS_TRAN_ID */
                                 p_SYSTRAN_ID,
                                 /* AUDIT_DATE */
                                 SYSDATE,
                                 /* AUDIT_OPERATION */
                                 'I',
                                 /* APPROVAL_STATUS */
                                 'A',
                                 /* UPD_SEQ */
                                 0,
                                 /* AMND_STATE */
                                 'F',
                                 /* ACTION_CODE */
                                 'R',
                                 /* SOURCE_TRAN_ID */
                                 p_SYSTRAN_ID,
                                 /* BATCH_REQ_ID */
                                 p_SYSBATCH_REQ_ID,
                                 /* EVENT_ID */
                                 p_EVENT_EXECUTION_ID,
                                 /* EVENT_ACTION_ID */
                                 EventActionDef.ID,
                                 /* EVENT_OBJECT */
                                 p_EVENT_OBJECT,
                                 /* OBJECT_ID */
                                 p_OBJECT_ID,
                                 /* ACTION */
                                 EventActionDef.EVENT_ACTION,
                                 /* DESTINATION */
                                 vDESTINATION,
                                 /* SUMMARY */
                                 vSUMMARY,
                                 /* CONTENT */
                                 vCONTENT,
                                 /* ENTRY_DATE */
                                 vENTRY_DATE,
                                 /* DEADLINE */
                                 vDEADLINE,
                                 /* ACTION_DATE */
                                 SYSDATE,
                                 /* STATUS */
                                 'U',
                                 /* TIMESTAMP */
                                 SYSDATE,
                                 /* ERROR_CODE */
                                 'R',
                                 /* INHERIT_MENU_ACL */
                                 1,
                                 /* SID */
                                 SQ_SID.NEXTVAL)
                         RETURN ID
                           INTO vBatchID;
                    END IF;
                 END;
             END IF;
             IF(EventActionDef.EVENT_ACTION != 'M')
            THEN
                INSERT INTO EVENT_ACTION_EXECUTION (SYS_TRAN_ID,
                                                        AUDIT_DATE,
                                                        AUDIT_OPERATION,
                                                        APPROVAL_STATUS,
                                                        UPD_SEQ,
                                                        AMND_STATE,
                                                        ACTION_CODE,
                                                        SOURCE_TRAN_ID,
                                                        BATCH_REQ_ID,
                                                        EVENT_ID,
                                                        EVENT_ACTION_ID,
                                                        EVENT_OBJECT,
                                                        OBJECT_ID,
                                                        ACTION,
                                                        DESTINATION,
                                                        SUMMARY,
                                                        CONTENT,
                                                        ENTRY_DATE,
                                                        DEADLINE,
                                                        ACTION_DATE,
                                                        STATUS,
                                                        TIMESTAMP,
                                                        ERROR_CODE,
                                                        INHERIT_MENU_ACL,
                                                        SID)
                         VALUES (                                    /* SYS_TRAN_ID */
                                 p_SYSTRAN_ID,
                                 /* AUDIT_DATE */
                                 SYSDATE,
                                 /* AUDIT_OPERATION */
                                 'I',
                                 /* APPROVAL_STATUS */
                                 'A',
                                 /* UPD_SEQ */
                                 0,
                                 /* AMND_STATE */
                                 'F',
                                 /* ACTION_CODE */
                                 'R',
                                 /* SOURCE_TRAN_ID */
                                 p_SYSTRAN_ID,
                                 /* BATCH_REQ_ID */
                                 p_SYSBATCH_REQ_ID,
                                 /* EVENT_ID */
                                 p_EVENT_EXECUTION_ID,
                                 /* EVENT_ACTION_ID */
                                 EventActionDef.ID,
                                 /* EVENT_OBJECT */
                                 p_EVENT_OBJECT,
                                 /* OBJECT_ID */
                                 p_OBJECT_ID,
                                 /* ACTION */
                                 EventActionDef.EVENT_ACTION,
                                 /* DESTINATION */
                                 vDESTINATION,
                                 /* SUMMARY */
                                 vSUMMARY,
                                 /* CONTENT */
                                 vCONTENT,
                                 /* ENTRY_DATE */
                                 vENTRY_DATE,
                                 /* DEADLINE */
                                 vDEADLINE,
                                 /* ACTION_DATE */
                                 SYSDATE,
                                 /* STATUS */
                                 'U',
                                 /* TIMESTAMP */
                                 SYSDATE,
                                 /* ERROR_CODE */
                                 'R',
                                 /* INHERIT_MENU_ACL */
                                 1,
                                 /* SID */
                                 SQ_SID.NEXTVAL)
                         RETURN ID
                           INTO vBatchID;
            END IF;
            -- Run action
                    CASE EventActionDef.EVENT_ACTION
                       WHEN 'E'
                       THEN
                          -- Email
                          
                          OPEN c FOR vSPECIAL;

                          LOOP
                             FETCH c INTO vTemp;

                             EXIT WHEN c%NOTFOUND;
                             -- process row here
                             SP_PRESEND_EMAIL_SMS (p_SYSTRAN_ID,vTemp, vSUMMARY, vCONTENT,EventActionDef.EVENT_ACTION);
                          END LOOP;

                          CLOSE c;
                          
                          DBMS_OUTPUT.PUT_LINE ('Send Email');
                          
                       WHEN 'S'
                       THEN
                          -- SMS
                          
                          DBMS_OUTPUT.PUT_LINE ('Send SMS');
                       OPEN c FOR vSPECIAL;

                          LOOP
                             FETCH c INTO vTemp;

                             EXIT WHEN c%NOTFOUND;
                             -- process row here
                             SP_PRESEND_EMAIL_SMS (p_SYSTRAN_ID,vTemp, vSUMMARY, vCONTENT,EventActionDef.EVENT_ACTION);
                          END LOOP;

                          CLOSE c;
                       WHEN 'P'
                       THEN
                          -- Run SQL Procedure
                          SP_RUN_PROC (vCONTENT);
                          DBMS_OUTPUT.PUT_LINE ('Run SQL Procedure');
                       -- Process here
                       WHEN 'X'
                       THEN
                          -- Execute command line
                          DBMS_OUTPUT.PUT_LINE ('Execute command line');
                       -- Process here
                          SP_RUN_CMD(vCONTENT);
                       WHEN 'M'
                       THEN
                          --Manual maintaince
                          DBMS_OUTPUT.PUT_LINE ('Manual maintaince');
                    -- Process here
                    END CASE;
            
            
            
            -- Update record for Action
            UPDATE EVENT_ACTION_EXECUTION
               SET STATUS = 'C'
             WHERE ID = vBatchID AND ACTION <> 'M';
         END;
      END;
   END LOOP;
-- END Automatic run EVENT_ACTION
EXCEPTION
   WHEN OTHERS
   THEN
    DBMS_OUTPUT.PUT_LINE(SUBSTR(SQLERRM, 1, 200));
      -- Consider logging the error and then re-raise
      DBMS_OUTPUT.PUT_LINE (
            'SP_RUN_ACTION_EVENT: Exception when executing EVENTID: '
         || p_EVENT_EXECUTION_ID);
      RAISE;
END SP_RUN_ACTION_EVENT;
/