CREATE OR REPLACE PROCEDURE BACKEND_DEV.sp_GetUserListForRouting (
   PRODUCT_ID        IN     NUMBER,
   DEPT_ID           IN     NUMBER,
   CUST_CAT_ID       IN     NUMBER,
   LIQUIDITY_LEVEL   IN     VARCHAR2,
   CREDIT_RATE       IN     VARCHAR2,
   SECURE_AMOUNT     IN     NUMBER,
   UNSECURE_AMOUNT   IN     NUMBER,
   CURRENT_PROCESS   IN     VARCHAR2,
   CURRENT_STAGE     IN     VARCHAR2,
   USER_LEVEL           OUT NUMBER,
   USER_LIST            OUT VARCHAR2,
   NEXT_STAGE           OUT VARCHAR2)
IS
   userId              NUMBER;
   entitySid           NUMBER;
   rights              VARCHAR2 (4000);
   l_PRODUCT_ID        NUMBER := NVL (PRODUCT_ID, 0);
   l_DEPT_ID           NUMBER := NVL (DEPT_ID, 0);
   l_CUST_CAT_ID       NUMBER := NVL (CUST_CAT_ID, 0);
   l_LIQUIDITY_LEVEL   VARCHAR2 (3) := NVL (LIQUIDITY_LEVEL, ' ');
   l_CREDIT_RATE       VARCHAR2 (10) := NVL (CREDIT_RATE, ' ');
   l_SECURE_AMOUNT     NUMBER := NVL (SECURE_AMOUNT, 0);
   l_UNSECURE_AMOUNT   NUMBER := NVL (UNSECURE_AMOUNT, 0);
   l_CURRENT_PROCESS   VARCHAR2 (100) := NVL (CURRENT_PROCESS, ' ');
   l_CURRENT_STAGE     VARCHAR2 (100) := NVL (CURRENT_STAGE, ' ');
   l_USER_LEVEL        NUMBER := 0;
   l_USER_LIST         VARCHAR2 (100);
   l_NEXT_STAGE        VARCHAR2 (100);
BEGIN
/*
   WITH GRPMEMBER
        AS (SELECT GRP.ID, GRP_MEMBER.MEMBER_ID, GRP.SID
              FROM SYS_USER USR
                   INNER JOIN SYS_GROUP_USER GRP_USR
                      ON     USR.ID = GRP_USR.USER_ID
                         AND USR.AMND_STATE = GRP_USR.AMND_STATE
                   INNER JOIN SYS_GROUP GRP
                      ON     GRP_USR.GROUP_ID = GRP.ID
                         AND GRP_USR.AMND_STATE = GRP.AMND_STATE
                   INNER JOIN SYS_GROUP_MEMBER GRP_MEMBER
                      ON     GRP.ID = GRP_MEMBER.GROUP_ID
                         AND GRP.AMND_STATE = GRP_MEMBER.AMND_STATE
             WHERE USR.AMND_STATE = 'F' AND USR.ID = userId) --SELECT * FROM GRPMEMBER;
                                                            ,
        MEMBERS
        AS (    SELECT DISTINCT (GRP.SID)
                  FROM GRPMEMBER
                       INNER JOIN SYS_GROUP GRP ON GRPMEMBER.MEMBER_ID = GRP.ID
                 WHERE GRP.AMND_STATE = 'F'
            CONNECT BY GRPMEMBER.ID = PRIOR GRPMEMBER.MEMBER_ID),
        SIDLIST
        AS (SELECT SID FROM MEMBERS
            UNION
            SELECT SID FROM GRPMEMBER
            UNION
            SELECT SID
              FROM SYS_USER
             WHERE ID = userId)                       --SELECT * FROM SIDLIST;
                               ,
        RESULTSET
        AS (SELECT R.ACL, 'group_value' GROUPBY
              FROM SYS_RIGHT R
                   INNER JOIN SIDLIST ON R.ASSIGNEE_ID = SIDLIST.SID
             WHERE R.AMND_STATE = 'F' AND R.OBJECT_ID = entitySid)
     SELECT LISTAGG (ACL, '') WITHIN GROUP (ORDER BY GROUPBY)
       INTO USER_LIST
       FROM RESULTSET
   GROUP BY GROUPBY;
;
*/
if (CURRENT_STAGE = 'NEW APPLICATION') then
NEXT_STAGE:='SUBMIT FORM';
USER_LIST:='test1';
elsif (CURRENT_STAGE = 'SUBMIT FORM') then
NEXT_STAGE:='SUBMIT FORM';
USER_LIST:='test2';
elsif (CURRENT_STAGE = 'REVIEW TC and DOCUMENT') then
NEXT_STAGE:='REVIEW TC and DOCUMENT';
USER_LIST:='RMLeader';
elsif (CURRENT_STAGE = 'APPROVE TO ESCALATE') then
NEXT_STAGE:='APPROVE TO ESCALATE';
USER_LIST:='BranchManager';
elsif (CURRENT_STAGE = 'APPRAISER REPORT') then
NEXT_STAGE:='APPROVE APPRAISER REPORT';
USER_LIST:='Appraiser';
elsif (CURRENT_STAGE = 'APPROVE APPRAISER REPORT') then
NEXT_STAGE:='AppraiseManager';
end if; 

   USER_LEVEL := l_USER_LEVEL;
   USER_LIST := l_USER_LIST;
   NEXT_STAGE := l_NEXT_STAGE;

   INSERT INTO GetUserListForRoutingLog (AUDIT_DATE,
                                         CURRENT_PROCESS,
                                         CURRENT_STAGE,
                                         PRODUCT_ID,
                                         DEPT_ID,
                                         CUST_CAT_ID,
                                         LIQUIDITY_LEVEL,
                                         CREDIT_RATE,
                                         SECURE_AMOUNT,
                                         UNSECURE_AMOUNT,
                                         USER_LEVEL,
                                         USER_LIST,
                                         NEXT_STAGE)
        VALUES (SYSDATE,
                l_CURRENT_PROCESS,
                l_CURRENT_STAGE,
                l_PRODUCT_ID,
                l_DEPT_ID,
                l_CUST_CAT_ID,
                l_LIQUIDITY_LEVEL,
                l_CREDIT_RATE,
                l_SECURE_AMOUNT,
                l_UNSECURE_AMOUNT,
                l_USER_LEVEL,
                l_USER_LIST,
                l_NEXT_STAGE);

   COMMIT;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      NULL;
   WHEN OTHERS
   THEN
      -- Consider logging the error and then re-raise
      RAISE;
END sp_GetUserListForRouting;
/