CREATE OR REPLACE PROCEDURE BACKEND_DEV.SP_RUN_ACTION_EVENT_APP_DOCS (
   p_EVENT_ID              NUMBER,
   p_EVENT_EXECUTION_ID    NUMBER,
   p_OBJECT_ID             NUMBER,
   p_EVENT_OBJECT          CHAR,
   p_SYSTRAN_ID            NUMBER,
   p_SYSBATCH_REQ_ID       NUMBER)
   AS 
BEGIN
    -- BEGIN Automatic run EVENT_ACTION
   FOR EventActionDef IN (SELECT ID,
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
         vSPECIAL       EVENT_OBJECT_PROPS.PROPERTY_SPECIAL_SOURCE%TYPE;
         vSUMMARY       EVENT_ACTION_EXECUTION.SUMMARY%TYPE := '';
         vCONTENT       EVENT_ACTION_EXECUTION.CONTENT%TYPE := '';
         vDEADLINE      EVENT_ACTION_EXECUTION.DEADLINE%TYPE := NULL;
         vENTRY_DATE    EVENT_ACTION_EXECUTION.ENTRY_DATE%TYPE := SYSDATE;
         vAMND          VARCHAR2 (100);
      BEGIN
         -- Get dynamic content from EVENT_OBJECT_PROPS
         IF EventActionDef.TIME_FRAME IS NOT NULL
         THEN
            vDEADLINE := vENTRY_DATE + EventActionDef.TIME_FRAME;
         END IF;

         vSUMMARY := EventActionDef.ACTION_SUMMARY;
         vCONTENT := EventActionDef.ACTION_CONTENT;
          -- Car collateral Condtions
         FOR EventObj IN (SELECT OBJECT_PROPERTY,
                                 PROPERTY_SOURCE,
                                 PROPERTY_SOURCE_TABLE,
                                 PROPERTY_SOURCE_FILTER
                            FROM EVENT_OBJECT_PROPS
                           WHERE OBJECT_TYPE = p_EVENT_OBJECT  AND PROPERTY_SOURCE_TABLE = 'CAR_COLLATERAL_DOCUMENTS')
         LOOP
            DECLARE
               vDynamicSQL            VARCHAR2 (32767);
               vDynamicResult         VARCHAR2 (32767);
               vDocumentCode         VARCHAR2 (32767);
               vTemp                  VARCHAR2 (32767);
               vConditionID           NUMBER;
               vConditionIDResult     NUMBER;
               TYPE cur_typ IS REF CURSOR;

               c                          cur_typ;
            BEGIN
               vDynamicSQL :=
                     'SELECT '
                  || EventObj.PROPERTY_SOURCE
                  || ' FROM '
                  || EventObj.PROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (EventObj.PROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));

               OPEN c FOR vDynamicSQL;

               LOOP
                  FETCH c INTO vTemp;

                  EXIT WHEN c%NOTFOUND;
                  -- process row here
                         FOR documents IN (SELECT DOC_CODE
                                  FROM DOCUMENT_CHECKLIST
                                 WHERE ID = TO_NUMBER (vTemp))
                         LOOP
                            vDocumentCode := documents.DOC_CODE || ',' || vDocumentCode;
                         END LOOP;
               END LOOP;

               CLOSE c;

               vSUMMARY :=
                  REPLACE (vSUMMARY,
                           EventObj.OBJECT_PROPERTY,
                           vDocumentCode);
               vCONTENT :=
                  REPLACE (vCONTENT,
                           EventObj.OBJECT_PROPERTY,
                           vDocumentCode);
            END;
         END LOOP;
        -- Car customer condition
                 FOR EventObj IN (SELECT OBJECT_PROPERTY,
                                 PROPERTY_SOURCE,
                                 PROPERTY_SOURCE_TABLE,
                                 PROPERTY_SOURCE_FILTER
                            FROM EVENT_OBJECT_PROPS
                           WHERE OBJECT_TYPE = p_EVENT_OBJECT  AND PROPERTY_SOURCE_TABLE = 'CAR_CUSTOMER_DOCUMENTS')
         LOOP
            DECLARE
               vDynamicSQL            VARCHAR2 (32767);
               vDynamicResult         VARCHAR2 (32767);
               vDocumentCode         VARCHAR2 (32767);
               vTemp                  VARCHAR2 (32767);
               vConditionID           NUMBER;
               vConditionIDResult     NUMBER;
               TYPE cur_typ IS REF CURSOR;

               c                          cur_typ;
            BEGIN
               vDynamicSQL :=
                     'SELECT '
                  || EventObj.PROPERTY_SOURCE
                  || ' FROM '
                  || EventObj.PROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (EventObj.PROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));
               OPEN c FOR vDynamicSQL;

               LOOP
                  FETCH c INTO vTemp;

                  EXIT WHEN c%NOTFOUND;
                  -- process row here
                         FOR documents IN (SELECT DOC_CODE
                                  FROM DOCUMENT_CHECKLIST
                                 WHERE ID = TO_NUMBER (vTemp))
                         LOOP
                            vDocumentCode := documents.DOC_CODE || ',' || vDocumentCode;
                         END LOOP;
               END LOOP;

               CLOSE c;

               vSUMMARY :=
                  REPLACE (vSUMMARY,
                           EventObj.OBJECT_PROPERTY,
                           vDocumentCode);
               vCONTENT :=
                  REPLACE (vCONTENT,
                           EventObj.OBJECT_PROPERTY,
                           vDocumentCode);
            END;
         END LOOP;
         -- CAR APP Default/Additional Conditon
                          FOR EventObj IN (SELECT OBJECT_PROPERTY,
                                 PROPERTY_SOURCE,
                                 PROPERTY_SOURCE_TABLE,
                                 PROPERTY_SOURCE_FILTER
                            FROM EVENT_OBJECT_PROPS
                           WHERE OBJECT_TYPE = p_EVENT_OBJECT  AND PROPERTY_SOURCE_TABLE = 'CAR_APPLICATION_DOCUMENTS')
         LOOP
            DECLARE
               vDynamicSQL            VARCHAR2 (32767);
               vDynamicResult         VARCHAR2 (32767);
               vDocumentCode         VARCHAR2 (32767);
               vTemp                  VARCHAR2 (32767);
               vConditionID           NUMBER;
               vConditionIDResult     NUMBER;
               TYPE cur_typ IS REF CURSOR;

               c                          cur_typ;
            BEGIN
               vDynamicSQL :=
                     'SELECT '
                  || EventObj.PROPERTY_SOURCE
                  || ' FROM '
                  || EventObj.PROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (EventObj.PROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));
               OPEN c FOR vDynamicSQL;

               LOOP
                  FETCH c INTO vTemp;

                  EXIT WHEN c%NOTFOUND;
                  -- process row here
                         FOR documents IN (SELECT DOC_CODE
                                  FROM DOCUMENT_CHECKLIST
                                 WHERE ID = TO_NUMBER (vTemp))
                         LOOP
                            vDocumentCode := documents.DOC_CODE || ',' || vDocumentCode;
                         END LOOP;
               END LOOP;

               CLOSE c;

               vSUMMARY :=
                  REPLACE (vSUMMARY,
                           EventObj.OBJECT_PROPERTY,
                           vDocumentCode);
               vCONTENT :=
                  REPLACE (vCONTENT,
                           EventObj.OBJECT_PROPERTY,
                           vDocumentCode);
            END;
         END LOOP;
         -- Application Code
            FOR EventObj IN (SELECT OBJECT_PROPERTY,
                                 PROPERTY_SOURCE,
                                 PROPERTY_SOURCE_TABLE,
                                 PROPERTY_SOURCE_FILTER
                            FROM EVENT_OBJECT_PROPS
                           WHERE OBJECT_TYPE = p_EVENT_OBJECT AND PROPERTY_SOURCE_TABLE = 'CREDIT_APPLICATION_REQUEST')
         LOOP
            DECLARE
               vDynamicSQL      VARCHAR2 (300);
               vDynamicResult   VARCHAR2 (100);
            BEGIN
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

               EXECUTE IMMEDIATE vDynamicSQL INTO vDynamicResult;

               vSUMMARY :=
                  REPLACE (vSUMMARY,
                           EventObj.OBJECT_PROPERTY,
                           vDynamicResult);
               vCONTENT :=
                  REPLACE (vCONTENT,
                           EventObj.OBJECT_PROPERTY,
                           vDynamicResult);
            END;
         END LOOP;
     -- Application ID
         FOR EventObj IN (SELECT OBJECT_PROPERTY,
                             PROPERTY_SOURCE,
                             PROPERTY_SOURCE_TABLE,
                             PROPERTY_SOURCE_FILTER
                        FROM EVENT_OBJECT_PROPS
                       WHERE OBJECT_TYPE = p_EVENT_OBJECT AND PROPERTY_SPECIAL_SOURCE = 'DOCUMENTS_CONDITIONS')
         LOOP
            DECLARE
               vDynamicSQL      VARCHAR2 (300);
               vDynamicResult   VARCHAR2 (100);
            BEGIN
   
               vCONTENT :=
                  REPLACE (vCONTENT,
                           EventObj.OBJECT_PROPERTY,
                           p_OBJECT_ID);
            END;
         END LOOP;
         -- HOST
        FOR EventObj IN (SELECT OBJECT_PROPERTY,
                                 PROPERTY_SOURCE,
                                 PROPERTY_SOURCE_TABLE,
                                 PROPERTY_SOURCE_FILTER
                            FROM EVENT_OBJECT_PROPS
                           WHERE OBJECT_TYPE = p_EVENT_OBJECT AND PROPERTY_SOURCE_TABLE = 'SYS_CONFIG')
         LOOP
            DECLARE
               vDynamicSQL      VARCHAR2 (300);
               vDynamicResult   VARCHAR2 (100);
            BEGIN
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

               EXECUTE IMMEDIATE vDynamicSQL INTO vDynamicResult;

               vCONTENT :=
                  REPLACE (vCONTENT,
                           EventObj.OBJECT_PROPERTY,
                           vDynamicResult);
            END;
         END LOOP;
         -- Get Data For DESTINATION and Run Action
         DECLARE
            vOBJECT_PROPERTY           EVENT_OBJECT_PROPS.OBJECT_PROPERTY%TYPE;
            vPROPERTY_SOURCE           EVENT_OBJECT_PROPS.PROPERTY_SOURCE%TYPE;
            vPROPERTY_SOURCE_TABLE     EVENT_OBJECT_PROPS.PROPERTY_SOURCE_TABLE%TYPE;
            vPROPERTY_SOURCE_FILTER    EVENT_OBJECT_PROPS.PROPERTY_SOURCE_FILTER%TYPE;
            vPROPERTY_SPECIAL_SOURCE   EVENT_OBJECT_PROPS.PROPERTY_SPECIAL_SOURCE%TYPE;
            vDynamicSQL                VARCHAR2 (300);
            vTemp                      VARCHAR2 (100);
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
                      PROPERTY_SPECIAL_SOURCE
                 INTO vOBJECT_PROPERTY,
                      vPROPERTY_SOURCE,
                      vPROPERTY_SOURCE_TABLE,
                      vPROPERTY_SOURCE_FILTER,
                      vPROPERTY_SPECIAL_SOURCE
                 FROM EVENT_OBJECT_PROPS
                WHERE     OBJECT_TYPE = p_EVENT_OBJECT
                      AND OBJECT_PROPERTY = EventActionDef.EVENT_DESTINATION
                      AND ROWNUM = 1;

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
                  vDESTINATION := vDESTINATION || ',' || vTemp;
               END LOOP;

               CLOSE c;

               vDESTINATION := TRIM (LEADING ',' FROM vDESTINATION);

              /* vSPECIAL :=
                     'SELECT '
                  || vPROPERTY_SPECIAL_SOURCE
                  || ' FROM '
                  || vPROPERTY_SOURCE_TABLE
                  || ' '
                  || REPLACE (vPROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID));*/
                vSPECIAL :=
                     'SELECT '
                  || vPROPERTY_SPECIAL_SOURCE
                  || ' FROM '
                  || vPROPERTY_SOURCE_TABLE
                  || ' JOIN SYS_USER ON SYS_USER.ID = ' 
                  || vPROPERTY_SOURCE
                  || ' '
                  || REPLACE (vPROPERTY_SOURCE_FILTER,
                              '$OBJECT_ID',
                              TO_CHAR (p_OBJECT_ID))
                  || ' AND SYS_USER.AMND_STATE = CHR(70)';
            END IF;

            -- Create record for Action
            IF(EventActionDef.EVENT_ACTION = 'M')
            THEN
                DECLARE 
                    vACTIONEXECUTE             EVENT_ACTION_EXECUTION.ID%TYPE;
                BEGIN
              
                    DBMS_OUTPUT.PUT_LINE(EventActionDef.EVENT_ACTION);
                    -- Check record existed in table? 
                SELECT EA.ID INTO vACTIONEXECUTE  FROM EVENT_ACTION_EXECUTION EA
                        WHERE EA.EVENT_OBJECT = p_EVENT_OBJECT AND EA.OBJECT_ID = p_OBJECT_ID
                             AND EA.DEADLINE < SYSDATE AND ROWNUM = 1;
                    DBMS_OUTPUT.PUT_LINE(vACTIONEXECUTE);
                    IF(vACTIONEXECUTE = 0)
                    THEN
                    DBMS_OUTPUT.PUT_LINE('vao');
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
                  -- DBMS_OUTPUT.PUT_LINE(vBatchID);
           --  DBMS_OUTPUT.PUT_LINE ('-----------------');      
          --  DBMS_OUTPUT.PUT_LINE (vSUMMARY);
          --  DBMS_OUTPUT.PUT_LINE (vCONTENT);
           -- DBMS_OUTPUT.PUT_LINE (EventActionDef.EVENT_ACTION);
            -- Run action
            CASE EventActionDef.EVENT_ACTION
               WHEN 'E'
               THEN
                  -- DBMS_OUTPUT.PUT_LINE (vSPECIAL);
                  -- Email
                  OPEN c FOR vSPECIAL;

                  LOOP
                     FETCH c INTO vTemp;
                      
                     EXIT WHEN c%NOTFOUND;
                     -- process row here
                    -- SP_SEND_EMAIL (vTemp, vSUMMARY, vCONTENT);
                     --DBMS_OUTPUT.PUT_LINE (p_SYSTRAN_ID || ' ' || vTemp|| ' ' || vSUMMARY|| ' ' || vCONTENT|| ' ' || EventActionDef.EVENT_ACTION);
                     SP_PRESEND_EMAIL_SMS (p_SYSTRAN_ID,vTemp, vSUMMARY, vCONTENT,EventActionDef.EVENT_ACTION);
                  END LOOP;

                  CLOSE c;
               WHEN 'S'
               THEN
                  -- SMS
                  DBMS_OUTPUT.PUT_LINE ('Send SMS');
               -- Process here
               WHEN 'P'
               THEN
                  -- Run SQL Procedure
                  DBMS_OUTPUT.PUT_LINE ('Run SQL Procedure');
               -- Process here
               WHEN 'X'
               THEN
                  -- Execute command line
                  DBMS_OUTPUT.PUT_LINE ('Execute command line');
               -- Process here
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
      -- Consider logging the error and then re-raise
      DBMS_OUTPUT.PUT_LINE (
            'SP_RUN_ACTION_EVENT_APP_CONS: Exception when executing EVENTID: '
         || p_EVENT_EXECUTION_ID);
      RAISE;
END SP_RUN_ACTION_EVENT_APP_DOCS;
/