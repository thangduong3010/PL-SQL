CREATE OR REPLACE PROCEDURE BACKEND_DEV.CreateUser IS
 type  array_t is varray(18) of varchar2(50);
 arrayt array_t:= array_t('RelationshipManager','RMLeader','BranchAppraiser','BranchAppraiserMnger','BranchDirector','BranchCreditCouncil','Appraiser','AppraiserManager','DirectorCredit','CEO','CreditCouncil','BoardDirector','Appraiser','AppraiserLeader','AppraiserManager','creditsuppotter','HODisburSupporter');
 existed number;
 deptId number;
begin
    select DEPT.ID into deptId from DEPARTMENT dept where DEPT.DEPT_ID = 'DEPT0001' and DEPT.AMND_STATE='F';

    /*for userid in (select 'RelationshipManager','RMLeader','BranchAppraiser','BranchAppraiserManager','BranchDirector','BranchCreditCommittee','Appraiser','AppraiserManager','DirectorCredit','CEO','CreditCommittee','BoardDirector','AssetAppraiser','AssetAppraiserLeader','AssetAppraiserManager','creditsupporter','HODisburementSupporter' from dual)
    loop
        select count(1) into existed from SYS_USER sysu where SYSU.AMND_STATE='F' and SYSU.USER_ID = userid;
       
    end loop;*/
    for userid in 1..arrayt.count
    loop
        select count(1) into existed from SYS_USER sysu where SYSU.AMND_STATE='F' and UPPER(SYSU.USER_ID) = UPPER(arrayt(userid));
        if existed=0 then
            INSERT INTO SYS_USER (AMND_STATE, AUDIT_DATE,AUTO_AUTHORIZED,DEPT_ID, EFFECTIVE, ID, INHERIT_MENU_ACL, MAX_CONNECTIONS, PASS_CODE, SID,STATUS, SYS_TRAN_ID, TRY_COUNT,UPD_SEQ, USER_ID, USER_LEVEL,USER_NAME)VALUES ( 'F', sysdate, 0,deptId, sysdate, SQ_SYS_USER_ID.nextval, 1, 3, 'P@ssw0rds', SID_SEQ.nextval, 'A', 2000, 100, 1,LOWER(arrayt(userid)),'4',LOWER(arrayt(userid)) );
        end if;
    end loop;

END CreateUser;
/