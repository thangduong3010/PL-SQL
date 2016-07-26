Rem
Rem $Header: rdbms/admin/dve112.sql /st_rdbms_11.2.0/15 2013/04/03 22:03:53 sanbhara Exp $
Rem
Rem dve112.sql
Rem
Rem Copyright (c) 2010, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dve112.sql - Downgrade DV from 11.2 to 11.1
Rem
Rem    DESCRIPTION
Rem      - This script will be called by cmpdwpth.sql for patch downgrades
Rem      - Also invoked by dve111.sql for version downgrades
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sanbhara    03/29/13 - Bug 16571121 - need to skip many statements
Rem                           when downgrading to 11.2.0.3.
Rem    kaizhuan    02/18/13 - Backport kaizhuan_bug-13887685 from main
Rem    apfwkr      11/27/12 - Backport youyang_bug-14757586 from main
Rem    sanbhara    08/07/12 - Bug 13913653 - backport of bug fix 13333301.
Rem    apfwkr      07/02/12 - Backport jibyun_bug-7118790 from main
Rem    sanbhara    06/14/12 - Bug 13781732 - delete dba_dv_patch_admin_audit
Rem                           view
Rem    jibyun      05/16/12 - Backport jibyun_bug-5918695 from main
Rem    cchui       07/22/11 - Remove unnecessary alter table
Rem    youyang     06/16/11 - backport 12395489
Rem    jibyun      05/03/11 - Backport jibyun_bug-12356827 from main
Rem    sanbhara    03/01/11 - Backport sanbhara_bug-10225918 from main
Rem    jibyun      03/02/11 - Backport jibyun_bug-11662436 from main
Rem    dvekaria    03/02/11 - Backport dvekaria_bug-9068994_1 from main
Rem    jheng       01/24/11 - Backport jheng_bug-7137958 from main
Rem    jheng       01/20/11 - Backport jheng_bug-8501924 from main
Rem    vigaur      06/02/10 - Create dve112.sql script
Rem    vigaur      06/02/10 - Created
Rem

EXECUTE DBMS_REGISTRY.DOWNGRADING('DV');

delete from dvsys.dv_auth$ where grant_type = 'DVPATCHAUDIT';

drop view dvsys.dba_dv_patch_admin_audit;

--Bug 16571121 - should execute following statements only if downgrading to version lower than 11.2.0.3.
-------------------------------------------------------------------------------------
variable previous_version varchar2(30);
begin
   SELECT prv_version INTO :previous_version FROM registry$
   WHERE  cid = 'CATPROC';
end;
/



-- Bug 6503742
BEGIN
  IF :previous_version < '11.2.0.3.0' THEN
    update DVSYS.FACTOR$ SET GET_EXPR = 'UTL_INADDR.GET_HOST_ADDRESS(DVSYS.DBMS_MACADM.GET_INSTANCE_INFO(''HOST_NAME''))' where name='Database_IP';
  END IF;
END;
/


drop view dvsys.dba_dv_datapump_auth;

-- "Allow Oracle Data Pump Operation" rule set
BEGIN
IF :previous_version < '11.2.0.3.0' THEN
  INSERT INTO DVSYS.RULE_SET$ (ID#,ENABLED,EVAL_OPTIONS,AUDIT_OPTIONS,FAIL_OPTIONS,HANDLER_OPTIONS,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
  VALUES(8,'Y',2,1,1,0,1,USER,SYSDATE,USER,SYSDATE);
END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
   
END;
/

--- "Allow Scheduler Job" rule set
BEGIN
IF :previous_version < '11.2.0.3.0' THEN
  INSERT INTO DVSYS.RULE_SET$ (ID#,ENABLED,EVAL_OPTIONS,AUDIT_OPTIONS,FAIL_OPTIONS,HANDLER_OPTIONS,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) 
  VALUES (10,'Y',2,1,1,0,1,USER,SYSDATE,USER,SYSDATE);
END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN 
IF :previous_version < '11.2.0.3.0' THEN
  INSERT INTO DVSYS.RULE_SET_RULE$ (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
  VALUES(10,8,2,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
IF :previous_version < '11.2.0.3.0' THEN
  INSERT INTO DVSYS.RULE_SET_RULE$ (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
  VALUES(18,10,2,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
IF :previous_version < '11.2.0.3.0' THEN
  INSERt INTO DVSYS.rule_set_t$(id#, language, name, description) values
  (8, 'us', 'Allow Oracle Data Pump Operation', 'Rule set that controls the objects that can be exported or imported by the Oracle Data Pump user.');
END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
IF :previous_version < '11.2.0.3.0' THEN
  INSERt INTO DVSYS.rule_set_t$(id#, language, name, description) values
  (10, 'us', 'Allow Scheduler Job', 'Rule set that stores DV scheduler job authorized users.');
END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/


-- insert datapump and job auth from dvsys.dv_auth$ to their rule sets
DECLARE
  cursor cur is select grant_type, grantee, object_owner, object_name 
                from dvsys.dv_auth$;
  l_rule_name dvsys.dv$rule.name%TYPE;
  l_seq  NUMBER;
  l_grantee VARCHAR2(130);
  l_object_owner VARCHAR(130);
  l_object_name VARCHAR(130);
BEGIN
IF :previous_version < '11.2.0.3.0' THEN
  FOR ee IN cur LOOP
    IF ee.grantee IS NOT NULL THEN
      l_grantee := Dbms_Assert.Enquote_Literal(
                     replace(ee.grantee,'''',''''''));
      l_object_owner := Dbms_Assert.Enquote_Literal(
                          replace(ee.object_owner,'''',''''''));
      l_object_name := Dbms_Assert.Enquote_Literal(
                         replace(ee.object_name, '''', ''''''));

      IF ee.grant_type = 'JOB' THEN
        SELECT dvsys.rule$_seq.nextval INTO l_seq FROM DUAL;
        l_rule_name := 'DV$' || TO_CHAR(l_seq);

        IF (ee.object_owner IS NOT NULL) AND (ee.object_owner != '%') THEN
          INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,
                                   CREATED_BY,CREATE_DATE,
                                   UPDATED_BY,UPDATE_DATE)
          VALUES
          (l_seq, '(dvsys.dv_job_invoker = ' || l_grantee  || 
                  ') AND (dvsys.dv_job_owner = ' || l_object_owner || ')', 
           1,USER,SYSDATE,USER,SYSDATE);
        ELSE
          INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION, 
                                   CREATED_BY,CREATE_DATE,
                                   UPDATED_BY,UPDATE_DATE) 
          VALUES
          (l_seq, 'dvsys.dv_job_invoker = ' || l_grantee, 1,
           USER,SYSDATE,USER,SYSDATE);
        END IF;
        INSERT INTO DVSYS.rule_t$(id#, name, language) VALUES
        (l_seq, l_rule_name, 'us');
        INSERT INTO DVSYS.RULE_SET_RULE$ (ID#,RULE_SET_ID#,RULE_ID#,
                                          RULE_ORDER,ENABLED,VERSION,
                                          CREATED_BY,CREATE_DATE,
                                          UPDATED_BY,UPDATE_DATE)
        VALUES(dvsys.rule_set_rule$_seq.NEXTVAL, 10, l_seq, 1,'Y',1,USER,
               SYSDATE,USER,SYSDATE);    
 
      ELSIF ee.grant_type = 'DATAPUMP' THEN
        SELECT dvsys.rule$_seq.nextval INTO l_seq FROM DUAL;
        l_rule_name := 'DVDP$' || TO_CHAR(l_seq);

        IF (ee.object_name IS NOT NULL) AND (ee.object_name != '%') THEN
          INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,
                                   CREATED_BY,CREATE_DATE,
                                   UPDATED_BY,UPDATE_DATE)
          VALUES
          (l_seq, '(dvsys.dv_login_user = ' || l_grantee ||
                  ') AND (dvsys.dv_dict_obj_owner = ' || l_object_owner ||
                  ') AND (dvsys.dv_dict_obj_name = ' || l_object_name || ')', 
           1,USER,SYSDATE,USER,SYSDATE);

        ELSIF (ee.object_owner IS NOT NULL) AND (ee.object_owner != '%') THEN
          INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,
                                   CREATED_BY,CREATE_DATE,
                                   UPDATED_BY,UPDATE_DATE)
          VALUES
          (l_seq, '(dvsys.dv_login_user = ' || l_grantee ||
                  ') AND (dvsys.dv_dict_obj_owner = ' || l_object_owner || ')',
           1,USER,SYSDATE,USER,SYSDATE);
        ELSE
          INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,
                                   CREATED_BY,CREATE_DATE,
                                   UPDATED_BY,UPDATE_DATE)
          VALUES
          (l_seq, 'dvsys.dv_login_user = ' || l_grantee, 1,
           USER,SYSDATE,USER,SYSDATE);
        END IF;

        INSERT INTO DVSYS.rule_t$(id#, name, language) VALUES
        (l_seq, l_rule_name, 'us');

        INSERT INTO DVSYS.RULE_SET_RULE$ (ID#,RULE_SET_ID#,RULE_ID#,
                                          RULE_ORDER,ENABLED,VERSION,
                                          CREATED_BY,CREATE_DATE,
                                          UPDATED_BY,UPDATE_DATE)

        VALUES(dvsys.rule_set_rule$_seq.NEXTVAL, 8, l_seq, 1,'Y',1,USER,
               SYSDATE,USER,SYSDATE);
      END IF;
    END IF;
  END LOOP;
END IF;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
/

BEGIN
IF :previous_version < '11.2.0.3.0' THEN -- these can be in single block since dont expect failures individually
  update dvsys.rule$ set rule_expr = 'UPPER(dvsys.dv_login_user) = UPPER(dvsys.dv_dict_obj_name)' where id#=10;
  update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ACCTMGR'',dvsys.dv_login_user) = ''Y''' where id#=3;
  update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DBA'',dvsys.dv_login_user) = ''Y''' where id#=4;
  update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ADMIN'',dvsys.dv_login_user) = ''Y''' where id#=5;
  update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_OWNER'',dvsys.dv_login_user) = ''Y''' where id#=6;
  update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''LBAC_DBA'',dvsys.dv_login_user) = ''Y''' where id#=7;
  update dvsys.rule$ set rule_expr = '(DVSYS.DBMS_MACUTL.USER_HAS_SYSTEM_PRIV_VARCHAR(''EXEMPT ACCESS POLICY'',dvsys.dv_login_user) = ''N'') OR USER = ''SYS''' where id#=9;
  update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACADM.IS_ALTER_USER_ALLOW_VARCHAR(dvsys.dv_login_user) = ''Y''' where id#=14;
  update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACADM.IS_DROP_USER_ALLOW_VARCHAR(dvsys.dv_login_user) = ''Y''' where id#=22;
END IF;
END;
/

-- Bug 9068994 Handle downgrade of Drop User
BEGIN
IF :previous_version < '11.2.0.3.0' THEN 
  UPDATE DVSYS.RULE_SET$ SET EVAL_OPTIONS = 2 WHERE ID# =3;
END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
IF :previous_version < '11.2.0.3.0' THEN 
  DELETE FROM DVSYS.RULE_SET_RULE$
  WHERE ID# = 19
  AND   RULE_SET_ID# = 3
  AND   RULE_ID# = 22;
END IF;
END;
/


BEGIN
IF :previous_version < '11.2.0.3.0' THEN 
  DELETE FROM DVSYS.rule$ WHERE ID# = 22;
  DELETE FROM DVSYS.rule_t$ WHERE ID# = 22;
-- Need to sync DATAPUMP and JOB ruleset, otherwise, dropping these rule sets
-- in dve111.sql cannot find them.
  dvsys.dbms_macadm.sync_rules;
END IF;
END;
/



--Bug Fix 10225918 - drop directory object.
BEGIN
IF :previous_version < '11.2.0.3.0' THEN 
  execute immediate 'drop directory DV_ADMIN_DIR';
END IF;
END;
/

BEGIN
IF :previous_version < '11.2.0.3.0' THEN 
-- Remove DV_GOLDENGATE_ADMIN role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_GOLDENGATE_ADMIN');

-- Remove the realm protection for DV_GOLDENGATE_ADMIN.
delete from DVSYS.realm_object$ where
  object_name = 'DV_GOLDENGATE_ADMIN' and object_type = 'ROLE';

-- Remove DV_XSTREAM_ADMIN role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_XSTREAM_ADMIN');

-- Remove the realm protection for DV_XSTREAM_ADMIN.
delete from DVSYS.realm_object$ where
  object_name = 'DV_XSTREAM_ADMIN' and object_type = 'ROLE';

-- Remove DV_GOLDENGATE_REDO_ACCESS role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_GOLDENGATE_REDO_ACCESS');

-- Remove the realm protection for DV_GOLDENGATE_REDO_ACCESS.
delete from DVSYS.realm_object$ where
  object_name = 'DV_GOLDENGATE_REDO_ACCESS' and object_type = 'ROLE';
END IF;
END;
/

-- Revoke execute on utl_file from DVSYS
BEGIN
IF :previous_version < '11.2.0.3.0' THEN 
  execute immediate 'revoke execute on utl_file from dvsys';
END IF;
END;
/

-------------------------------------------------------------------------------------
-- Bug 7118790
drop view dvsys.dba_dv_oradebug;


-- Remove DV_AUDIT_CLEANUP role grants.
delete from sys.sysauth$ where privilege# =
  (select user# from user$ where name = 'DV_AUDIT_CLEANUP');

-- Revoke privileges from DV_AUDIT_CLEANUP.
revoke SELECT ON dvsys.audit_trail$ from DV_AUDIT_CLEANUP;
revoke DELETE ON dvsys.audit_trail$ from DV_AUDIT_CLEANUP;

-- Remove the realm protection for DV_AUDIT_CLEANUP.
delete from DVSYS.realm_object$ where
  object_name = 'DV_AUDIT_CLEANUP' and object_type = 'ROLE';

-- Bug 7118790: delete ORADEBUG row from DV_AUTH$
BEGIN
  DELETE FROM DVSYS.DV_AUTH$ WHERE GRANT_TYPE = 'ORADEBUG';
    EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

drop package dvsys.dbms_macdvutl;

--Bug14757586
delete from dvsys.code$ where id#=42;
delete from dvsys.code_t$ where id#=42;

EXECUTE DBMS_REGISTRY.DOWNGRADED('DV', '11.2.0');
