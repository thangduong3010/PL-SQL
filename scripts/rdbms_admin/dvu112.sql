Rem
Rem $Header: rdbms/admin/dvu112.sql /st_rdbms_11.2.0/18 2013/03/04 11:03:33 sanbhara Exp $
Rem
Rem dvu112.sql
Rem
Rem Copyright (c) 2010, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dvu112.sql - DV Upgrade Script from 11.2.0.1 to 12g
Rem
Rem    DESCRIPTION
Rem      Upgrade Database Vault in Oracle 11.2.0.1 to 12g
Rem
Rem    NOTES
Rem      This file is currently used by dvpatch.sql for patchset from 11.2.0.1 
Rem      to 11.2.0.2. After the patchset is released, this file will be used 
Rem      as upgrade script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      11/27/12 - Backport youyang_bug-14757586 from main
Rem    jibyun      09/13/12 - Backport jibyun_bug-14015928 from MAIN
Rem    apfwkr      07/17/12 - Backport apfwkr_blr_backport_13962309_11.2.0.3.0
Rem                           from st_rdbms_11.2.0
Rem    apfwkr      07/02/12 - Backport jibyun_bug-7118790 from main
Rem    sanbhara    06/14/12 - Bug 13781732 - adding dba_dv_patch_admin_audit
Rem                           view
Rem    jibyun      05/17/12 - Backport jibyun_bug-5918695 from main
Rem    cchui       07/22/11 - grant execute on utl_file and remove unnecessary
Rem                           alter table
Rem    youyang     06/16/11 - Backport youyang_bug-12395489 from main
Rem    jheng       06/01/11 - lrg 5609292
Rem    jibyun      05/03/11 - Backport jibyun_bug-12356827 from main
Rem    dvekaria    03/02/11 - Backport dvekaria_bug-9068994_1 from main
Rem    jibyun      03/02/11 - Backport jibyun_bug-11662436 from main
Rem    sanbhara    03/01/11 - Backport sanbhara_bug-10225918 from main
Rem    jheng       01/24/11 - Backport jheng_bug-7137958 from main
Rem    jheng       01/20/11 - Backport jheng_bug-8501924 from main
Rem    sanbhara    11/02/10 - Backport sanbhara_bug-9871112 from main
Rem    youyang     07/26/10 - Backport youyang_bug-9671705 from main
Rem    vigaur      06/22/10 - Create file
Rem    vigaur      06/22/10 - Created
Rem

GRANT EXECUTE ON UTL_FILE TO DVSYS;

-- Since DV datapump object types in metaview$ are deleted during DB patchset 
-- upgrade, we need to re-insert these types into metaview$ in patchset upgrade.
@@catmacdd.sql

--
-- Reload all the packages, functions and procedures from previous release
--

ALTER SESSION SET CURRENT_SCHEMA = DVSYS;

-- Add the new Rule Set Row Cache library
CREATE OR REPLACE LIBRARY DVSYS.KZV$RSRC_LIBT TRUSTED AS STATIC
/

-- bug 7137958: extract datapump auth from ruleset and put it into 
-- DVSYS.DV_AUTH$ table; delete datapump rules and ruleset
Declare
  cursor cur is  select r1.name, r.rule_expr, r.id#
                 from dvsys.rule$ r, dvsys.rule_t$ r1,
                      dvsys.rule_set_rule$ rs,
                      dvsys.rule_set_t$ rt
                 where rt.name = 'Allow Oracle Data Pump Operation' and
                       rs.RULE_SET_ID# = 8 and rt.id#=rs.RULE_SET_ID# and
                       rs.rule_id# = r.id# and r1.id# = r.id#;
  l_parse_rule  VARCHAR2(4000);
  l_grantee     VARCHAR2(30);
  l_schema      VARCHAR2(30) := '%';
  l_object      VARCHAR2(30) := '%';
  l_start       number;
  l_end         number;
BEGIN
  FOR ee IN cur LOOP
    delete from dvsys.rule_set_rule$ 
    where rule_set_id#=8 and rule_id#=ee.id#;

    IF ee.name != 'False' THEN
      l_schema := '%';
      l_object := '%';

      l_parse_rule := TRIM(ee.rule_expr);
      l_start := INSTR(l_parse_rule, 'dv_login_user = ');

      IF l_start != 0 THEN
        -- extract grantee
        l_start := l_start + length('dv_login_user = ');
        l_end := INSTR(l_parse_rule, ')', l_start);
        IF l_end = 0 THEN
          l_end := length(l_parse_rule)+1;
        END IF;
        l_grantee := SUBSTR(l_parse_rule, l_start+1, l_end-l_start-2);
        --- extract schema
        l_start := INSTR(l_parse_rule, 'dv_dict_obj_owner = ');
        IF l_start != 0 THEN
          l_start := l_start + length('dv_dict_obj_owner = ');
          l_end := INSTR(l_parse_rule, ')', l_start, 1)-1;
          l_schema := SUBSTR(l_parse_rule, l_start+1, l_end-l_start-1);

          -- extract object name
          l_start := INSTR(l_parse_rule, 'dv_dict_obj_name = ');
          IF l_start!= 0 THEN
            l_start := l_start + length('dv_dict_obj_name = ');
            l_end := INSTR(l_parse_rule, ')', l_start, 1)-1;
            l_object := SUBSTR(l_parse_rule, l_start+1, l_end-l_start-1);
          END IF; --end of extracting object name
        END IF; -- end of extracing schema 
      END IF; -- end of extracing grantee

      INSERT INTO DVSYS.DV_AUTH$(grant_type, grantee, object_owner,                                  object_name, object_type)
      VALUES ('DATAPUMP', l_grantee, l_schema, l_object, NULL);

      delete from dvsys.rule$ where id#=ee.id#;
      delete from dvsys.rule_t$ where id#=ee.id#;
    END IF; -- end of parsing no FALSE rule
  END LOOP;
  delete from dvsys.rule_set_rule$ where rule_set_id#=8;
  delete from dvsys.rule_set$ where id#=8;
  delete from dvsys.rule_set_t$ where id#=8;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
/

--delete job rules and ruleset
Declare
  cursor cur is  select r.name, r.id#
                 from dvsys.rule_t$ r,
                      dvsys.rule_set_rule$ rs,
                      dvsys.rule_set_t$ rt
                 where rt.name = 'Allow Scheduler Job' and
                       rs.RULE_SET_ID# = 10 and rt.id#=rs.RULE_SET_ID# and
                       rs.rule_id# = r.id#;
BEGIN
  FOR ee in cur LOOP
    delete from dvsys.rule_set_rule$ 
    where rule_set_id#=10 and rule_id#=ee.id#;
    IF (ee.name != 'False') THEN
      delete from dvsys.rule$ where id#=ee.id#;
      delete from dvsys.rule_t$ where id#=ee.id#;
    END IF;
  END LOOP;
  delete from dvsys.rule_set_rule$ where rule_set_id#=10;
  delete from dvsys.rule_set$ where id#=10;
  delete from dvsys.rule_set_t$ where id#=10;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;
/

-- update dv_auth$ null object name to '%'
BEGIN
UPDATE DVSYS.DV_AUTH$ SET object_name='%' where grant_type='JOB';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

UPDATE DVSYS.DV_AUTH$ SET OBJECT_TYPE='%' WHERE OBJECT_TYPE IS NULL;

--bug 7137958: add dba_dv_datapump_auth view
CREATE OR REPLACE VIEW DVSYS.dba_dv_datapump_auth
(
      grantee
    , schema
    , object
)
AS SELECT
    grantee
  , object_owner
  , object_name
FROM dvsys.dv_auth$
WHERE grant_type = 'DATAPUMP'
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_oradebug
(
    state
)
AS
SELECT DECODE(cnt, 0, 'DISABLED', 'ENABLED')
FROM (SELECT COUNT(*) cnt FROM DVSYS.DV_AUTH$ WHERE GRANT_TYPE = 'ORADEBUG')
/

GRANT SELECT ON dvsys.dba_dv_datapump_auth to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_datapump_auth TO dv_secanalyst;
GRANT SELECT ON dvsys.dba_dv_oradebug TO dv_monitor;
GRANT SELECT ON dvsys.dba_dv_oradebug TO dv_secanalyst;

--bug8635726: Add a command rule for changing password, and this should be added to upgrade script dvu112.sql.
BEGIN
  INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(190,'SQL_CMDS','CHANGE PASSWORD',1,USER,SYSDATE,USER,SYSDATE);
  EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;
END;
/

BEGIN
  INSERT INTO DVSYS.CODE_T$ (ID#, VALUE, DESCRIPTION, LANGUAGE) VALUES(190, 'CHANGE PASSWORD', '', 'us');
  EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
INSERT INTO DVSYS.COMMAND_RULE$ (ID#,CODE_ID#,RULE_SET_ID#,OBJECT_OWNER,OBJECT_NAME,ENABLED,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
SELECT 11,c.id#,4,'%','%','Y',1,USER,SYSDATE,USER,SYSDATE
FROM dvsys.code$ c WHERE c.code_group = 'SQL_CMDS' AND c.code = 'CHANGE PASSWORD';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

/* Bug 9092184: insert the following missing records.  These inserts should be
 * added to upgrade script dvu112.sql later.
 */
BEGIN
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(534,'FACTOR_IDENTIFY','3',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(535,'FACTOR_EVALUATE','2',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(536,'RULESET_AUDIT','3',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(537,'RULESET_EVENT','3',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(538,'REALM_AUDIT','3',1,USER,SYSDATE,USER,SYSDATE);
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
    ELSE RAISE;
    END IF;
END;
/


BEGIN
INSERT INTO DVSYS.CODE_T$ (ID#, VALUE, DESCRIPTION, LANGUAGE) VALUES(534,'By Context', '', 'us');
INSERT INTO DVSYS.CODE_T$ (ID#, VALUE, DESCRIPTION, LANGUAGE) VALUES(535,'On Startup', '', 'us');
INSERT INTO DVSYS.CODE_T$ (ID#, VALUE, DESCRIPTION, LANGUAGE) VALUES(536,'Always', '', 'us');
INSERT INTO DVSYS.CODE_T$ (ID#, VALUE, DESCRIPTION, LANGUAGE) VALUES(537,'Always', '', 'us');
INSERT INTO DVSYS.CODE_T$ (ID#, VALUE, DESCRIPTION, LANGUAGE) VALUES(538,'Always', '', 'us');
  EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
    ELSE RAISE;
    END IF;
END;
/


-- Bug 8706788 - Remove WKSYS and WKUSER from ODD
-- Drop these users from the realm authorization list
delete from DVSYS.realm_auth$ where grantee = 'WKSYS' and realm_id#=1;
delete from DVSYS.realm_auth$ where grantee = 'WKUSER' and realm_id#=1;

-- Bug 6503742. Update database IP factor to use the new SERVER_HOST_IP sys_context
update DVSYS.FACTOR$ SET GET_EXPR = 'UPPER(SYS_CONTEXT(''USERENV'',''SERVER_HOST_IP''))' where name='Database_IP';

-- Bug 9671705 change definition of dba_dv_user_privs and dba_dv_user_privs_all
CREATE OR REPLACE VIEW DVSYS.dba_dv_user_privs
(
    USERNAME
    ,ACCESS_TYPE
    ,PRIVILEGE
    ,OWNER
    ,OBJECT_NAME
)
AS SELECT
    dbu.name
    ,   decode(ue.name,dbu.name,'DIRECT',ue.name)
    ,   tpm.name
    ,   u.name
    ,   o.name
FROM sys.objauth$ oa,
    sys.obj$ o,
    sys.user$ u,
    sys.user$ ue,
    sys.user$ dbu,
    sys.table_privilege_map tpm
WHERE oa.obj# = o.obj#
  AND oa.col# IS NULL
  AND oa.privilege# = tpm.privilege
  AND u.user# = o.owner#
  AND oa.grantee# = ue.user#
  AND dbu.type# = 1
  AND (oa.grantee# = dbu.user#
        or
       oa.grantee# in (SELECT /*+ connect_by_filtering */ DISTINCT privilege#
                        FROM (select * from sys.sysauth$ where privilege#>0)
                        CONNECT BY grantee#=prior privilege#
                        START WITH grantee#=dbu.user#))
/

CREATE OR REPLACE VIEW DVSYS.dba_dv_user_privs_all
(
    USERNAME
    ,ACCESS_TYPE
    ,PRIVILEGE
    ,OWNER
    ,OBJECT_NAME
)
AS SELECT
    dbu.name
       , decode(ue.name,dbu.name,'DIRECT',ue.name)
       , tpm.name
       , u.name
       , o.name
FROM sys.objauth$ oa,
    sys.obj$ o,
    sys.user$ u,
    sys.user$ ue,
    sys.user$ dbu,
    table_privilege_map tpm
WHERE oa.obj# = o.obj#
  AND oa.col# IS NULL
  AND oa.privilege# = tpm.privilege
  AND u.user# = o.owner#
  AND oa.grantee# = ue.user#
  AND dbu.type# = 1
  AND (oa.grantee# = dbu.user#
        or
       oa.grantee#  in (SELECT /*+ connect_by_filtering */ DISTINCT privilege#
                        FROM (select * from sys.sysauth$ where privilege#>0)
                        CONNECT BY grantee#=prior privilege#
                        START WITH grantee#=dbu.user#))
UNION ALL
SELECT dbu.name
       ,DECODE(ue.name,dbu.name,'DIRECT',ue.name)
       ,spm.name
       ,DECODE (INSTR(spm.name,' ANY '),0, NULL, '%')
       ,DECODE (INSTR(spm.name,' ANY '),0, NULL, '%')
FROM sys.sysauth$ oa,
     sys.user$ ue,
     sys.user$ dbu,
     system_privilege_map spm
WHERE
      oa.privilege# = spm.privilege
  AND oa.grantee# = ue.user#
  AND oa.privilege# < 0
  AND dbu.type# = 1
  AND (oa.grantee# = dbu.user#
        or
       oa.grantee#  in (SELECT /*+ connect_by_filtering */ DISTINCT privilege#
                        FROM (select * from sys.sysauth$ where privilege#>0)
                        CONNECT BY grantee#=prior privilege#
                        START WITH grantee#=dbu.user#))
/

-- Bug 9871112. Update the case sensitive factors to not use UPPER

update DVSYS.FACTOR$ SET GET_EXPR = 'SYS_CONTEXT(''USERENV'',''ENTERPRISE_IDENTITY'')' where name='Enterprise_Identity';

update DVSYS.FACTOR$ SET GET_EXPR = 'SYS_CONTEXT(''USERENV'',''PROXY_ENTERPRISE_IDENTITY'')'  where name='Proxy_Enterprise_Identity';

update DVSYS.FACTOR$ SET GET_EXPR = 'SYS_CONTEXT(''USERENV'',''SESSION_USER'')' where name='Session_User';

update DVSYS.FACTOR$ SET GET_EXPR = 'SYS_CONTEXT(''USERENV'',''PROXY_USER'')' where name='Proxy_User';

-- Bug 9068994. Handle upgrade for Drop User.
BEGIN
UPDATE DVSYS.RULE_SET$ SET EVAL_OPTIONS = 1 WHERE ID# =3;
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN 
INSERT INTO DVSYS.rule_t$ (ID#,LANGUAGE,NAME)
VALUES(22,'us','Is Drop User Allowed');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN 
INSERT INTO DVSYS.rule$ (ID#,RULE_EXPR,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
VALUES(22,'DVSYS.DBMS_MACADM.IS_DROP_USER_ALLOW_VARCHAR(dvsys.dv_login_user) = ''Y''',1,
       USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN 
INSERT INTO DVSYS.RULE_SET_RULE$ (ID#,RULE_SET_ID#,RULE_ID#,RULE_ORDER,ENABLED,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE)
VALUES(19,3,22,1,'Y',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

-- Bug 11662436: Create DV_GOLDENGATE_ADMIN role for Golden Gate Extract.
create role dv_goldengate_admin;
grant dv_goldengate_admin to dv_owner with admin option;

-- Protect DV_GOLDENGATE_ADMIN with Oracle Database Vault realm
BEGIN
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,object_name,object_type,version,created_by,create_date,updated_by,update_date)
 VALUES(68,2,'%','DV_GOLDENGATE_ADMIN','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

-- Bug 11662436: Create DV_XSTREAM_ADMIN role for XSTREAM capture.
create role dv_xstream_admin;
grant dv_xstream_admin to dv_owner with admin option;

-- Protect DV_XSTREAM_ADMIN with Oracle Database Vault realm
BEGIN
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,object_name,object_type,version,created_by,create_date,updated_by,update_date)
 VALUES(69,2,'%','DV_XSTREAM_ADMIN','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

-- Bug 12356827: Create DV_GOLDENGATE_REDO_ACCESS role for Golden Gate OCI API.
create role dv_goldengate_redo_access;
grant dv_goldengate_redo_access to dv_owner with admin option;

-- Protect DV_GOLDENGATE_REDO_ACCESS with Oracle Database Vault realm
BEGIN
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,object_name,object_type,version,created_by,create_date,updated_by,update_date)
 VALUES(70,2,'%','DV_GOLDENGATE_REDO_ACCESS','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

-- Bug 13728213: introduce DV_AUDIT_CLEANUP role
create role dv_audit_cleanup;
GRANT SELECT ON dvsys.audit_trail$ TO dv_audit_cleanup;
GRANT DELETE ON dvsys.audit_trail$ TO dv_audit_cleanup;
grant dv_audit_cleanup to dv_owner with admin option;

-- Protect DV_AUDIT_CLEANUP with Oracle Database Vault realm
BEGIN
INSERT INTO DVSYS.realm_object$(id#,realm_id#,owner,object_name,object_type,version,created_by,create_date,updated_by,update_date)
 VALUES(71,2,'%','DV_AUDIT_CLEANUP','ROLE',1,USER,SYSDATE,USER,SYSDATE);
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

-- Bug 12395489: replace dvsys roles grantees views
create or replace view DVSYS.DV_OWNER_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_OWNER'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys.user$ where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_OWNER'));
/

create or replace view DVSYS.DV_ADMIN_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_ADMIN'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys.user$ where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_ADMIN'));
/

create or replace view DVSYS.DV_SECANALYST_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_SECANALYST'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys.user$ where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_SECANALYST'));
/

create or replace view DVSYS.DV_MONITOR_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_MONITOR'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys.user$ where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_MONITOR'));
/

update dvsys.rule$ set rule_expr = 'dvsys.dv_login_user = dvsys.dv_dict_obj_name' where id#=10;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ACCTMGR'', ''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=3;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DBA'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=4;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_ADMIN'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=5;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''DV_OWNER'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=6;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACUTL.USER_HAS_ROLE_VARCHAR(''LBAC_DBA'',''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=7;
update dvsys.rule$ set rule_expr = '(DVSYS.DBMS_MACUTL.USER_HAS_SYSTEM_PRIV_VARCHAR(''EXEMPT ACCESS POLICY'',''"''||dvsys.dv_login_user||''"'') = ''N'') OR USER = ''SYS''' where id#=9;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACADM.IS_ALTER_USER_ALLOW_VARCHAR(''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=14;
update dvsys.rule$ set rule_expr = 'DVSYS.DBMS_MACADM.IS_DROP_USER_ALLOW_VARCHAR(''"''||dvsys.dv_login_user||''"'') = ''Y''' where id#=22;

create or replace view DVSYS.DV_AUDIT_CLEANUP_GRANTEES
(GRANTEE, PATH_OF_CONNECT_ROLE_GRANT, ADMIN_OPT)
as
select grantee, connect_path, admin_option
from (select grantee,
             'DV_AUDIT_CLEANUP'||SYS_CONNECT_BY_PATH(grantee, '/') connect_path,
             granted_role, admin_option
      from   sys.dba_role_privs
      where decode((select type# from sys.user$ where name = grantee),
               0, 'ROLE',
               1, 'USER') = 'USER'
      connect by nocycle granted_role = prior grantee
      start with granted_role = upper('DV_AUDIT_CLEANUP'));
/

@@dvmacfnc.plb

@@catmacp.sql

@@prvtmacp.plb

@@catmact.sql

-- LRG 3392573. Re-sync command rules
exec DVSYS.dbms_macadm.sync_rules;

-- Bug Fix 10225918 - create Directory Object required by new DBMS_MACADM procedure
-- ADD_NLS_DATA() 

DECLARE
 v_OH_path varchar2(255);
 v_dlf_path    varchar2(255);
 v_pfid number;
 PLATFORM_WINDOWS32    CONSTANT BINARY_INTEGER := 7;
 PLATFORM_WINDOWS64    CONSTANT BINARY_INTEGER := 8;

 begin
  sys.dbms_system.get_env('ORACLE_HOME',v_OH_path);
  SELECT platform_id INTO v_pfid FROM v$database;

  IF v_pfid = PLATFORM_WINDOWS32 OR v_pfid = PLATFORM_WINDOWS64
  THEN 
    v_dlf_path := v_OH_path||'\dv\admin\';
  ELSE
    v_dlf_path := v_OH_path||'/dv/admin/';
  END IF;

  EXECUTE IMMEDIATE 'create or replace directory DV_ADMIN_DIR AS'''|| v_dlf_path || '''';
 end;
/

-- Bug 7118790: Insert ORADEBUG row to DV_AUTH$ so that ORADEBUG is enabled 
-- by default.
BEGIN
EXECUTE IMMEDIATE 'INSERT INTO DVSYS.DV_AUTH$ (GRANT_TYPE, GRANTEE)
                     SELECT ''ORADEBUG'', ''%'' FROM DUAL
                     WHERE NOT EXISTS (SELECT 1 FROM DVSYS.DV_AUTH$
                                       WHERE GRANT_TYPE = ''ORADEBUG'')';
END;
/

Rem
Rem    DESCRIPTION
Rem      Creates a DBA view for the state (enabled or disabled) of 
Rem      DV_PATCH_ADMIN audit from DV_AUTH$.
Rem
CREATE OR REPLACE VIEW DVSYS.dba_dv_patch_admin_audit
(
    state
)
AS 
SELECT DECODE(cnt, 0, 'DISABLED', 'ENABLED') 
FROM (SELECT COUNT(*) cnt FROM DVSYS.DV_AUTH$ WHERE GRANT_TYPE = 'DVPATCHAUDIT')
/

GRANT SELECT ON dvsys.dba_dv_patch_admin_audit to dv_monitor;
GRANT SELECT ON dvsys.dba_dv_patch_admin_audit TO dv_secanalyst;

grant read on directory DV_ADMIN_DIR to dvsys;

-- Bug 14015928: grant EXECUTE on dbms_macutl to DV_ADMIN, not DV_PUBLIC.
GRANT EXECUTE ON dvsys.dbms_macutl TO dv_admin
/
-- Revoke EXECUTE on dbms_macutl from dv_public.
BEGIN
  EXECUTE IMMEDIATE 'REVOKE EXECUTE ON dvsys.dbms_macutl FROM dv_public';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-1927) THEN NULL; -- already revoked.
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  delete from SYS.db_profile_dict$;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-942) THEN NULL; -- table has been dropped.
    ELSE RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP FUNCTION SYS.db_profile_function';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE IN (-4043) THEN NULL; -- already dropped.
    ELSE RAISE;
    END IF;
END;
/

--Bug14757586
INSERT INTO DVSYS.CODE$ (ID#,CODE_GROUP,CODE,VERSION,CREATED_BY,CREATE_DATE,UPDATED_BY,UPDATE_DATE) VALUES(42,'SQL_CMDS','ALTER SESSION',1,USER,SYSDATE,USER,SYSDATE);
INSERT INTO dvsys.code_t$(id#, value, description, language) VALUES(42,'ALTER SESSION','','us') ;

-- Bug 16291881
CREATE OR REPLACE FUNCTION dvsys.dvlang(lid IN NUMBER, langtab_no IN NUMBER)
RETURN VARCHAR2
AS
  l_lcnt NUMBER default 0;
  l_lang VARCHAR2(3);
  l_tab  VARCHAR2(30);
  l_stmt VARCHAR2(256);
  l_cursor    int;
  l_status    int;
BEGIN
  l_lang := LOWER(SYS_CONTEXT('USERENV','LANG'));
  l_tab :=
    CASE langtab_no
      WHEN 1 THEN 'CODE_T$'
      WHEN 2 THEN 'FACTOR_T$'
      WHEN 3 THEN 'FACTOR_TYPE_T$'
      WHEN 4 THEN 'RULE_T$'
      WHEN 5 THEN 'RULE_SET_T$'
      WHEN 6 THEN 'REALM_T$'
      WHEN 7 THEN 'MONITOR_RULE_T$'
    END;

  l_stmt := 'SELECT COUNT(*) FROM ' || l_tab || ' WHERE id# = :id AND language = :lang';
  l_cursor := sys.dbms_sql.open_cursor;
  sys.dbms_sql.parse( l_cursor, l_stmt, dbms_sql.native );
  sys.dbms_sql.bind_variable( l_cursor, ':id', lid );
  sys.dbms_sql.bind_variable( l_cursor, ':lang', l_lang );
  sys.dbms_sql.define_column( l_cursor, 1, l_lcnt );
  l_status := sys.dbms_sql.execute( l_cursor );
  if ( sys.dbms_sql.fetch_rows(l_cursor) > 0 )
    then
        sys.dbms_sql.column_value( l_cursor, 1, l_lcnt );
  end if;
  sys.dbms_sql.close_cursor(l_cursor);

  if (l_lcnt = 0) then
    return 'us';
  else
    return l_lang;
  end if;
END;
/

commit;
