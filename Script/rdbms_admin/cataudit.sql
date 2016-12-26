rem 
rem $Header: rdbms/admin/cataudit.sql /st_rdbms_11.2.0/1 2011/01/06 01:52:12 mjgreave Exp $ audit.sql 
rem 
Rem Copyright (c) 1990, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem Copyright (c) 1990, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem NAME
Rem    cataudit.sql
Rem FUNCTION
Rem    Creates data dictionary views for auditing. 
Rem NOTES
Rem    Must be run while connected to SYS or INTERNAL.
Rem MODIFIED
Rem     mjgreave   12/16/10  - Backport mjgreave_bug-10206268 from main
Rem     mjgreave   10/18/10  - add audit_actions for ALTER VIEW. #10206268
Rem     akruglik   11/02/09  - 31113 (ALTER USER RENAME): get rid of 
Rem                            audit_actions rows for ALTER SCHEMA [SYNONYM]
Rem     msakayed   10/28/09  - Bug #5842629: audit_actions for direct path load
Rem     msakayed   10/22/09  - Bug 8862486: audit_actions for DIRECTORY EXECUTE
Rem     apsrivas   11/25/08  - Bug 6755639 : Add DBID to DBA_AUDIT_TRAIL and
Rem                            USER_AUDIT_TRAIL
Rem     nkgopal    05/08/08  - Bug 6830207: Add Action names for ALTER DATABASE
Rem                            LINK
Rem     msakayed   04/03/08  - fix directory privs for *_obj_audit_opts
Rem     akruglik   03/16/08  - 31113 (RENAME SCHEMA): add audit_actions rows 
Rem                            for ALTER SCHEMA RENAME, CREATE/ALTER/DROP 
Rem                            SCHEMA SYNONYM
Rem     mjgreave   11/14/07  - add audit_actions for ALTER SYNONYM. #5647235
Rem     sfeinste   04/09/07  - rename olap_build_processes$ to
Rem                            olap_cube_build_processes$
Rem     wechen     02/17/07  - rename olap_primary_dimensions$ and
Rem                            olap_interactions$ to olap_cube_dimensions$
Rem                            and olap_build_processes$
Rem     pstengar   12/01/06  - bug 5586631: add MINING MODEL entries to
Rem                                         AUDIT_ACTIONS
Rem     achoi      09/27/06  - bug5508217: Change name in *_AUDIT_TRAIL to
Rem                                        OBJ_EDITION_NAME
Rem     ciyer      08/04/06  - audit support for edition objects
Rem     wechen     07/04/06  - add OLAP API support
Rem     gviswana   07/09/06  - Edition name support 
Rem     ssonawan   06/21/06  - bug5346555: add AUDIT_ACTIONS 166
Rem                            ALTER INDEXTYPE
Rem     liaguo     06/26/06  - Project 17991 - flashback archive
Rem     pstengar   05/30/06  - audit mining model objects
Rem     ssonawan   06/01/06  - BUG 5138541: DBA_AUDIT_TRAIL(LOGOFF$TIME) in 
Rem                                         session timezone format 
Rem     achoi      05/09/06  - support application edition 
Rem     rdecker    03/27/06  - Add assembly support
Rem     vmarwah    06/23/05  - PURGE TABLESPACE typo fix 
Rem     mxiao      03/17/05  - audit rewrite equivalence, bug 4276578
Rem     dsirmuka   12/18/04  - bug 4055382. Comment change.
Rem     gmulagun   12/08/04  - bug 4054898 add REA for ALL_DEF_AUDIT_OPTS
Rem     gtarora    11/12/04  - bug 3984527 
Rem     gmulagun   08/30/04  - bug 3629208 set execution contextid 
Rem     jnarasin   07/30/04  - EUS Proxy auditing changes 
Rem     xuhuali    04/13/04  - audit java
Rem     nmanappa   06/24/04  - 3633725 - select only audit set objects in 
Rem                            dba_obj_audit_opts and user_obj_audit_opts
Rem     ahwang     05/08/04  - add create and drop restore point 
Rem     gmulagun   04/04/03  - bug 2822534: rename tran_id to xid
Rem     nireland   02/25/03  - Add Become User/Create Session. #2798933
Rem     gmulagun   03/12/03  - bug 2817508
Rem     mxiao      01/29/03  - change SNAPSHOT to MATERIALIZED VIEW
Rem     gmulagun   12/27/02  - Add dummy REF column
Rem     nmanappa   10/11/02  - Adding FLASHBACK to audit_actions, and reusing 
Rem                            REFerence pos for FBK to store flashback option
Rem     gmulagun   09/23/02  - correct extended_timestamp column
Rem     gmulagun   09/16/02  - enhance audit trail
Rem     mjstewar   09/12/02  - Flashback Database: Insert auditing information. 
Rem     vmarwah    05/24/02  - Undrop Tables: Insert auditing information.
Rem     desinha    04/29/02  - #2303866: change user => userenv('SCHEMAID')
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     htseng     04/12/01  - eliminate execute twice (remove ;).
Rem     rvissapr   08/30/00  - add client_id in audit views
Rem     dmwong     12/09/98  - add missing entries into audit_action           
Rem     sbodagal   12/23/98 -  Make entries in audit_actions to audit outlines
Rem     rguzman    09/25/98 -  Add dimensions to audit_actions
Rem     rwessman   07/01/98  - Corrected comments in audit trail views.
Rem     rwessman   06/29/98  - Fixed bug in dba_stmt_audit_opts view where prox
Rem     rwessman   04/08/98 -  Added support for N-tier auditing
Rem     cozbutun   01/12/98 -  remove object_label session_label from views
Rem     nlewis     03/10/97 -  #376745: remove duplicate DROP PROC entry (#58)
Rem     rshaikh    08/08/96 -  add directory to user_obj_audit_opts
Rem     tanguyen   07/02/96 -  change EXECUTE TYPE from 84 to 123
Rem     tanguyen   06/25/96 -  add EXECUTE TYPE to audit_actions table
Rem     jwijaya    06/17/96 -  check for EXECUTE ANY TYPE
Rem     skaluska   06/13/96 -  Add auditing on libraries
Rem     jwijaya    06/19/96 -  remove USAGE
Rem     mmonajje   05/20/96 -  Replace timestamp col name with timestamp#
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     rshaikh    04/01/96 -  add DIRECTORY to audit_actions
Rem     rshaikh    12/01/95 -  add object support to user_obj_audit_opts and au
Rem     jwijaya    11/07/95 -  type privilege fix
Rem     jwijaya    08/28/95 -  add ADTs/objects
Rem     wmaimone   05/26/94 -  #186155 add public synoyms for dba_
Rem     jbellemo   04/10/95 -  NETAUDIT: add NETWORK
Rem     jbellemo   12/17/93 -  merge changes from branch 1.5.710.1
Rem     jbellemo   11/09/93 -  #170173: change uid to userenv schemaid
Rem     wmaimone   11/23/92 -  wrap rawtolab around labels 
Rem     dleary     11/12/92 -  add OER(2024) not exists error 
Rem     tpystyne   11/07/92 -  use create or replace view 
Rem     vraghuna   10/28/92 -  bug 130560 - move map tables in sql.bsq 
Rem     glumpkin   10/14/92 -  renamed from audit.sql
Rem     rlim       09/25/92 -  #128468 - remove dba synonyms already
Rem                            defined in dba_syn.sql 
Rem     ajasuja    06/02/92 -  new auditing codes 
Rem     ajasuja    02/12/92 -  add ses$label, obj$label columns 
Rem     ajasuja    12/31/91 -  fix dba_audit_trail view 
Rem     ajasuja    12/30/91 -  audit EXISTS 
Rem     ajasuja    11/27/91 -  add system privilege auditing 
Rem     smcadams   10/19/91 -  tweak audit_action table 
Rem     rlim       07/30/91 -         moved dba synonyms to dba_synonyms.sql 
Rem     smcadams   06/09/91 -         sync with catalog.sql 
Rem     smcadams   05/07/91 -         re-sync audit action decoding table with 
Rem     jwijaya    04/12/91 -         remove LINKNAME IS NULL 
Rem     smcadams   04/08/91 -         remove 'ANY' from audit option descriptio
Rem     smcadams   04/02/91 -         add action to audit_actions 
Rem     smcadams   04/02/91 -         add a couple more stmt_audit_opts 
Rem     rkooi      04/01/91 -         add 'o.linkname IS NULL' clause 
Rem   Chaudhr    04/30/90 - Add procedure and trigger stuff
Rem                       - Rename the following objects:
Rem                       -  audit_option_map    -> stmt_audit_option_map
Rem                       -  dba_sys_audit_opts  -> dba_stmt_audit_opts
Rem                       -  dba_tab_audit_opts  -> dba_obj_audit_opts
Rem                       -  user_tab_audit_opts -> user_obj_audit_opts
Rem   Chaudhr    03/09/90 - Creation
Rem

remark
remark AUDITING VIEWS
remark
remark  The auditing views can be dropped by running catnoaud.sql, and 
remark  recreated by running cataudit.sql.
remark
remark  STMT_AUDIT_OPTION_MAP now in sql.bsq
remark
remark  AUDIT_ACTIONS maps an action number to the action name.
remark  The table is accessible to public.
remark

drop table AUDIT_ACTIONS
/
create table AUDIT_ACTIONS(
  action number not null, name varchar2(28) not null)
/
comment on table AUDIT_ACTIONS is
'Description table for audit trail action type codes.  Maps action type numbers to action type names'
/
comment on column AUDIT_ACTIONS.ACTION is
'Numeric audit trail action type code'
/
comment on column AUDIT_ACTIONS.NAME is
'Name of the type of audit trail action'
/
insert into audit_actions values (0, 'UNKNOWN');
insert into audit_actions values (1, 'CREATE TABLE');
insert into audit_actions values (2, 'INSERT');
insert into audit_actions values (3, 'SELECT');
insert into audit_actions values (4, 'CREATE CLUSTER');
insert into audit_actions values (5, 'ALTER CLUSTER');
insert into audit_actions values (6, 'UPDATE');
insert into audit_actions values (7, 'DELETE');
insert into audit_actions values (8, 'DROP CLUSTER');
insert into audit_actions values (9, 'CREATE INDEX');
insert into audit_actions values (10, 'DROP INDEX');
insert into audit_actions values (11, 'ALTER INDEX');
insert into audit_actions values (12, 'DROP TABLE');
insert into audit_actions values (13, 'CREATE SEQUENCE');
insert into audit_actions values (14, 'ALTER SEQUENCE');
insert into audit_actions values (15, 'ALTER TABLE');
insert into audit_actions values (16, 'DROP SEQUENCE');
insert into audit_actions values (17, 'GRANT OBJECT');
insert into audit_actions values (18, 'REVOKE OBJECT');
insert into audit_actions values (19, 'CREATE SYNONYM');
insert into audit_actions values (20, 'DROP SYNONYM');
insert into audit_actions values (21, 'CREATE VIEW');
insert into audit_actions values (22, 'DROP VIEW');
insert into audit_actions values (23, 'VALIDATE INDEX');
insert into audit_actions values (24, 'CREATE PROCEDURE');
insert into audit_actions values (25, 'ALTER PROCEDURE');
insert into audit_actions values (26, 'LOCK');
insert into audit_actions values (27, 'NO-OP');
insert into audit_actions values (28, 'RENAME');
insert into audit_actions values (29, 'COMMENT');
insert into audit_actions values (30, 'AUDIT OBJECT');
insert into audit_actions values (31, 'NOAUDIT OBJECT');
insert into audit_actions values (32, 'CREATE DATABASE LINK');
insert into audit_actions values (33, 'DROP DATABASE LINK');
insert into audit_actions values (34, 'CREATE DATABASE');
insert into audit_actions values (35, 'ALTER DATABASE');
insert into audit_actions values (36, 'CREATE ROLLBACK SEG');
insert into audit_actions values (37, 'ALTER ROLLBACK SEG');
insert into audit_actions values (38, 'DROP ROLLBACK SEG');
insert into audit_actions values (39, 'CREATE TABLESPACE');
insert into audit_actions values (40, 'ALTER TABLESPACE');
insert into audit_actions values (41, 'DROP TABLESPACE');
insert into audit_actions values (42, 'ALTER SESSION');
insert into audit_actions values (43, 'ALTER USER');
insert into audit_actions values (44, 'COMMIT');
insert into audit_actions values (45, 'ROLLBACK');
insert into audit_actions values (46, 'SAVEPOINT');
insert into audit_actions values (47, 'PL/SQL EXECUTE');
insert into audit_actions values (48, 'SET TRANSACTION');
insert into audit_actions values (49, 'ALTER SYSTEM');
insert into audit_actions values (50, 'EXPLAIN');
insert into audit_actions values (51, 'CREATE USER');
insert into audit_actions values (52, 'CREATE ROLE');
insert into audit_actions values (53, 'DROP USER');
insert into audit_actions values (54, 'DROP ROLE');
insert into audit_actions values (55, 'SET ROLE');
insert into audit_actions values (56, 'CREATE SCHEMA');
insert into audit_actions values (57, 'CREATE CONTROL FILE');
insert into audit_actions values (59, 'CREATE TRIGGER');
insert into audit_actions values (60, 'ALTER TRIGGER');
insert into audit_actions values (61, 'DROP TRIGGER');
insert into audit_actions values (62, 'ANALYZE TABLE');
insert into audit_actions values (63, 'ANALYZE INDEX');
insert into audit_actions values (64, 'ANALYZE CLUSTER');
insert into audit_actions values (65, 'CREATE PROFILE');
insert into audit_actions values (66, 'DROP PROFILE');
insert into audit_actions values (67, 'ALTER PROFILE');
insert into audit_actions values (68, 'DROP PROCEDURE');
insert into audit_actions values (70, 'ALTER RESOURCE COST');
insert into audit_actions values (71, 'CREATE MATERIALIZED VIEW LOG');
insert into audit_actions values (72, 'ALTER MATERIALIZED VIEW LOG');
insert into audit_actions values (73, 'DROP MATERIALIZED VIEW LOG');
insert into audit_actions values (74, 'CREATE MATERIALIZED VIEW');
insert into audit_actions values (75, 'ALTER MATERIALIZED VIEW');
insert into audit_actions values (76, 'DROP MATERIALIZED VIEW');
insert into audit_actions values (77, 'CREATE TYPE');
insert into audit_actions values (78, 'DROP TYPE');
insert into audit_actions values (79, 'ALTER ROLE');
insert into audit_actions values (80, 'ALTER TYPE');
insert into audit_actions values (81, 'CREATE TYPE BODY');
insert into audit_actions values (82, 'ALTER TYPE BODY');
insert into audit_actions values (83, 'DROP TYPE BODY');
insert into audit_actions values (84, 'DROP LIBRARY');
insert into audit_actions values (85, 'TRUNCATE TABLE');
insert into audit_actions values (86, 'TRUNCATE CLUSTER');
insert into audit_actions values (88, 'ALTER VIEW');
insert into audit_actions values (91, 'CREATE FUNCTION');
insert into audit_actions values (92, 'ALTER FUNCTION');
insert into audit_actions values (93, 'DROP FUNCTION');
insert into audit_actions values (94, 'CREATE PACKAGE');
insert into audit_actions values (95, 'ALTER PACKAGE');
insert into audit_actions values (96, 'DROP PACKAGE');
insert into audit_actions values (97, 'CREATE PACKAGE BODY');
insert into audit_actions values (98, 'ALTER PACKAGE BODY');
insert into audit_actions values (99, 'DROP PACKAGE BODY');
insert into audit_actions values (100, 'LOGON');
insert into audit_actions values (101, 'LOGOFF');
insert into audit_actions values (102, 'LOGOFF BY CLEANUP');
insert into audit_actions values (103, 'SESSION REC');
insert into audit_actions values (104, 'SYSTEM AUDIT');
insert into audit_actions values (105, 'SYSTEM NOAUDIT');
insert into audit_actions values (106, 'AUDIT DEFAULT');
insert into audit_actions values (107, 'NOAUDIT DEFAULT');
insert into audit_actions values (108, 'SYSTEM GRANT');
insert into audit_actions values (109, 'SYSTEM REVOKE');
insert into audit_actions values (110, 'CREATE PUBLIC SYNONYM');
insert into audit_actions values (111, 'DROP PUBLIC SYNONYM');
insert into audit_actions values (112, 'CREATE PUBLIC DATABASE LINK');
insert into audit_actions values (113, 'DROP PUBLIC DATABASE LINK');
insert into audit_actions values (114, 'GRANT ROLE');
insert into audit_actions values (115, 'REVOKE ROLE');
insert into audit_actions values (116, 'EXECUTE PROCEDURE');
insert into audit_actions values (117, 'USER COMMENT');
insert into audit_actions values (118, 'ENABLE TRIGGER');
insert into audit_actions values (119, 'DISABLE TRIGGER');
insert into audit_actions values (120, 'ENABLE ALL TRIGGERS');
insert into audit_actions values (121, 'DISABLE ALL TRIGGERS');
insert into audit_actions values (122, 'NETWORK ERROR');
insert into audit_actions values (123, 'EXECUTE TYPE');
insert into audit_actions values (128, 'FLASHBACK');
insert into audit_actions values (129, 'CREATE SESSION');
insert into audit_actions values (130, 'ALTER MINING MODEL');
insert into audit_actions values (131, 'SELECT MINING MODEL');
insert into audit_actions values (133, 'CREATE MINING MODEL');
insert into audit_actions values (134, 'ALTER PUBLIC SYNONYM');
insert into audit_actions values (135, 'DIRECTORY EXECUTE');
insert into audit_actions values (136, 'SQL*LOADER DIRECT PATH LOAD');
insert into audit_actions values (137, 'DATAPUMP DIRECT PATH UNLOAD');

insert into audit_actions values (157, 'CREATE DIRECTORY');
insert into audit_actions values (158, 'DROP DIRECTORY');
insert into audit_actions values (159, 'CREATE LIBRARY');
insert into audit_actions values (160, 'CREATE JAVA');
insert into audit_actions values (161, 'ALTER JAVA');
insert into audit_actions values (162, 'DROP JAVA');
insert into audit_actions values (163, 'CREATE OPERATOR');
insert into audit_actions values (164, 'CREATE INDEXTYPE');
insert into audit_actions values (165, 'DROP INDEXTYPE');
insert into audit_actions values (166, 'ALTER INDEXTYPE');
insert into audit_actions values (167, 'DROP OPERATOR');
insert into audit_actions values (168, 'ASSOCIATE STATISTICS');
insert into audit_actions values (169, 'DISASSOCIATE STATISTICS');

insert into audit_actions values (170, 'CALL METHOD');
insert into audit_actions values (171, 'CREATE SUMMARY');
insert into audit_actions values (172, 'ALTER SUMMARY');
insert into audit_actions values (173, 'DROP SUMMARY');
insert into audit_actions values (174, 'CREATE DIMENSION');
insert into audit_actions values (175, 'ALTER DIMENSION');
insert into audit_actions values (176, 'DROP DIMENSION');
insert into audit_actions values (177, 'CREATE CONTEXT');
insert into audit_actions values (178, 'DROP CONTEXT');
insert into audit_actions values (179, 'ALTER OUTLINE');

insert into audit_actions values (180, 'CREATE OUTLINE');
insert into audit_actions values (181, 'DROP OUTLINE');
insert into audit_actions values (182, 'UPDATE INDEXES');
insert into audit_actions values (183, 'ALTER OPERATOR');

insert into audit_actions values (192, 'ALTER SYNONYM');

insert into audit_actions values (197, 'PURGE USER_RECYCLEBIN');
insert into audit_actions values (198, 'PURGE DBA_RECYCLEBIN');
insert into audit_actions values (199, 'PURGE TABLESPACE');
insert into audit_actions values (200, 'PURGE TABLE');
insert into audit_actions values (201, 'PURGE INDEX');
insert into audit_actions values (202, 'UNDROP OBJECT');
insert into audit_actions values (204, 'FLASHBACK DATABASE');
insert into audit_actions values (205, 'FLASHBACK TABLE');
insert into audit_actions values (206, 'CREATE RESTORE POINT');
insert into audit_actions values (207, 'DROP RESTORE POINT');

insert into audit_actions values (208, 'PROXY AUTHENTICATION ONLY') ;
insert into audit_actions values (209, 'DECLARE REWRITE EQUIVALENCE') ;
insert into audit_actions values (210, 'ALTER REWRITE EQUIVALENCE') ;
insert into audit_actions values (211, 'DROP REWRITE EQUIVALENCE') ;

insert into audit_actions values (212, 'CREATE EDITION');
insert into audit_actions values (213, 'ALTER EDITION');
insert into audit_actions values (214, 'DROP EDITION');

insert into audit_actions values (215, 'DROP ASSEMBLY');
insert into audit_actions values (216, 'CREATE ASSEMBLY');
insert into audit_actions values (217, 'ALTER ASSEMBLY');

insert into audit_actions values (218, 'CREATE FLASHBACK ARCHIVE');
insert into audit_actions values (219, 'ALTER FLASHBACK ARCHIVE');
insert into audit_actions values (220, 'DROP FLASHBACK ARCHIVE');

/* SCHEMA SYNONYMS will be added in 12g */
-- insert into audit_actions values (222, 'CREATE SCHEMA SYNONYM');
-- insert into audit_actions values (224, 'DROP SCHEMA SYNONYM');

insert into audit_actions values (225, 'ALTER DATABASE LINK');
insert into audit_actions values (305, 'ALTER PUBLIC DATABASE LINK');

commit;
create unique index I_AUDIT_ACTIONS on audit_actions(action,name) nocompress
/
create or replace public synonym AUDIT_ACTIONS for AUDIT_ACTIONS
/
grant select on AUDIT_ACTIONS to public
/

remark
remark  FAMILY "DEF_AUDIT_OPTS"
remark  Single row view indicating the default auditing options
remark  for newly created objects.
remark  This family has an ALL member only, since the default is
remark  system-wide and applies to all accessible objects.
remark
create or replace view ALL_DEF_AUDIT_OPTS
    (ALT,
     AUD,
     COM,
     DEL,
     GRA,
     IND,
     INS,
     LOC,
     REN,
     SEL,
     UPD,
     REF,
     EXE,
     FBK,
     REA)
as
select substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1)
from sys.obj$ o, sys.tab$ t
where o.obj# = t.obj#
  and o.owner# = 0
  and o.name = '_default_auditing_options_'
/
comment on table ALL_DEF_AUDIT_OPTS is
'Auditing options for newly created objects'
/
comment on column ALL_DEF_AUDIT_OPTS.ALT is
'Auditing ALTER WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.AUD is
'Auditing AUDIT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.COM is
'Auditing COMMENT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.DEL is
'Auditing DELETE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.GRA is
'Auditing GRANT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.IND is
'Auditing INDEX WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.INS is
'Auditing INSERT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.LOC is
'Auditing LOCK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.REN is
'Auditing RENAME WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.SEL is
'Auditing SELECT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.UPD is
'Auditing UPDATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.REF is
'Dummy REF column. Maintained for backward compatibility of the view'
/
comment on column ALL_DEF_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.FBK is
'Auditing FLASHBACK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column ALL_DEF_AUDIT_OPTS.REA is
'Auditing READ WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
create or replace public synonym ALL_DEF_AUDIT_OPTS for ALL_DEF_AUDIT_OPTS
/
grant select on ALL_DEF_AUDIT_OPTS to PUBLIC
/


remark
remark  FAMILY "OBJ_AUDIT_OPTS"
remark  Auditing options on objects.  Only "user_" and "dba_" members.
remark  A user is not allowed to see audit options for other people's objects.
remark
remark  These views indicate what kind of audit trail entries (none,
remark  session-level, or access-level) are generated by the success or failure
remark  of each possible operation on a table or view (e.g., select, alter).
remark
remark  The values in the columns ALT through UPD are three character
remark  strings like 'A/S', 'A/-'.  The letters 'A', 'S', and '-' correspond to
remark  different levels of detail called Access, Session and None.  The
remark  character before the slash determines the auditing level if the action
remark  is successful.  The character after the slash determines auditing level
remark  if the operation fails for any reason.
remark
remark  This compressed three character format has been chosen to make all
remark  the information fit on a single line.  The column names are
remark  three chars long for the same reason.  The alternative is to use long
remark  column names to improve readability, but
remark  serious users can get further documentation using the describe
remark  column statement.  I do not expect novice users to be looking at audit
remark  information.  Another alternative is to have separate columns for the
remark  success and failure settings.  This would eliminate the need to
remark  use the substr function in views built on top of these views,
remark  but the advantage to users of making information fit on one line
remark  overrides the hassle to view-implementors of using the substr function.
remark
create or replace view USER_OBJ_AUDIT_OPTS 
        (OBJECT_NAME, 
         OBJECT_TYPE, 
         ALT,
         AUD,
         COM,
         DEL,
         GRA,
         IND,
         INS,
         LOC,
         REN,
         SEL,
         UPD,
         REF,
         EXE,
         CRE,
         REA,
         WRI,
         FBK)
as
select o.name, 'TABLE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.tab$ t
where o.type# = 2
  and not (o.owner# = 0 and o.name = '_default_auditing_options_')
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'VIEW',
       substr(v.audit$, 1, 1) || '/' || substr(v.audit$, 2, 1),
       substr(v.audit$, 3, 1) || '/' || substr(v.audit$, 4, 1),
       substr(v.audit$, 5, 1) || '/' || substr(v.audit$, 6, 1),
       substr(v.audit$, 7, 1) || '/' || substr(v.audit$, 8, 1),
       substr(v.audit$, 9, 1) || '/' || substr(v.audit$, 10, 1),
       substr(v.audit$, 11, 1) || '/' || substr(v.audit$, 12, 1),
       substr(v.audit$, 13, 1) || '/' || substr(v.audit$, 14, 1),
       substr(v.audit$, 15, 1) || '/' || substr(v.audit$, 16, 1),
       substr(v.audit$, 17, 1) || '/' || substr(v.audit$, 18, 1),
       substr(v.audit$, 19, 1) || '/' || substr(v.audit$, 20, 1),
       substr(v.audit$, 21, 1) || '/' || substr(v.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(v.audit$, 25, 1) || '/' || substr(v.audit$, 26, 1),
       substr(v.audit$, 27, 1) || '/' || substr(v.audit$, 28, 1),
       substr(v.audit$, 29, 1) || '/' || substr(v.audit$, 30, 1),
       substr(v.audit$, 31, 1) || '/' || substr(v.audit$, 32, 1),
       substr(v.audit$, 23, 1) || '/' || substr(v.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.view$ v
where o.type# = 4
  and (instrb(v.audit$,'S') != 0  or instrb(v.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = v.obj#
union all
select o.name, 'SEQUENCE',
       substr(s.audit$, 1, 1) || '/' || substr(s.audit$, 2, 1),
       substr(s.audit$, 3, 1) || '/' || substr(s.audit$, 4, 1),
       substr(s.audit$, 5, 1) || '/' || substr(s.audit$, 6, 1),
       substr(s.audit$, 7, 1) || '/' || substr(s.audit$, 8, 1),
       substr(s.audit$, 9, 1) || '/' || substr(s.audit$, 10, 1),
       substr(s.audit$, 11, 1) || '/' || substr(s.audit$, 12, 1),
       substr(s.audit$, 13, 1) || '/' || substr(s.audit$, 14, 1),
       substr(s.audit$, 15, 1) || '/' || substr(s.audit$, 16, 1),
       substr(s.audit$, 17, 1) || '/' || substr(s.audit$, 18, 1),
       substr(s.audit$, 19, 1) || '/' || substr(s.audit$, 20, 1),
       substr(s.audit$, 21, 1) || '/' || substr(s.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(s.audit$, 25, 1) || '/' || substr(s.audit$, 26, 1),
       substr(s.audit$, 27, 1) || '/' || substr(s.audit$, 28, 1),
       substr(s.audit$, 29, 1) || '/' || substr(s.audit$, 30, 1),
       substr(s.audit$, 31, 1) || '/' || substr(s.audit$, 32, 1),
       substr(s.audit$, 23, 1) || '/' || substr(s.audit$, 24, 1)
from sys.obj$ o, sys.seq$ s
where o.type# = 6
  and (instrb(s.audit$,'S') != 0  or instrb(s.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = s.obj#
union all
select o.name, 'PROCEDURE',
       substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1),
       substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1),
       substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1),
       substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1),
       substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1),
       substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1),
       substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1),
       substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1),
       substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1),
       substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1),
       substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1),
       substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1),
       substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1),
       substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1),
       substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.library$ p
where o.type# = 22
  and (instrb(p.audit$,'S') != 0  or instrb(p.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = p.obj#
union all
select o.name, 'PROCEDURE',
       substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1),
       substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1),
       substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1),
       substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1),
       substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1),
       substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1),
       substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1),
       substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1),
       substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1),
       substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1),
       substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1),
       substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1),
       substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1),
       substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1),
       substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.procedure$ p
where o.type# >= 7 and o.type# <= 9
  and (instrb(p.audit$,'S') != 0  or instrb(p.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = p.obj#
union all
select o.name, 'TYPE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.type_misc$ t
where o.type# = 13
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'DIRECTORY',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 35, 1) || '/' || substr(t.audit$, 36, 1),
       substr(t.audit$, 37, 1) || '/' || substr(t.audit$, 38, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.dir$ t
where o.type# = 23
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 
       decode(o.type#, 28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       'ILLEGAL JAVA TYPE'),
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.javaobj$ t
where (o.type# = 28 or o.type# = 29 or o.type# = 30)
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'MINING MODEL',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.model$ t
where o.type# = 82
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'EDITION',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.edition$ t
where o.type# = 57
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'OLAP CUBE DIMENSION',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.olap_cube_dimensions$ t
where o.type# = 92
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'OLAP CUBE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.olap_cubes$ t
where o.type# = 93
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'OLAP MEASURE FOLDER',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.olap_measure_folders$ t
where o.type# = 94
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
union all
select o.name, 'OLAP CUBE BUILD PROCESS',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.olap_cube_build_processes$ t
where o.type# = 95
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = userenv('SCHEMAID')
  and o.obj# = t.obj#
/
comment on table USER_OBJ_AUDIT_OPTS is
'Auditing options for user''s own tables and views with atleast one option set'
/
comment on column USER_OBJ_AUDIT_OPTS.OBJECT_NAME is
'Name of the object'
/
comment on column USER_OBJ_AUDIT_OPTS.OBJECT_TYPE is
'Type of the object:  "TABLE" or "VIEW"'
/
comment on column USER_OBJ_AUDIT_OPTS.ALT is
'Auditing ALTER WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.AUD is
'Auditing AUDIT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.COM is
'Auditing COMMENT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.DEL is
'Auditing DELETE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.GRA is
'Auditing GRANT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.IND is
'Auditing INDEX WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.INS is
'Auditing INSERT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.LOC is
'Auditing LOCK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.REN is
'Auditing RENAME WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.SEL is
'Auditing SELECT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.UPD is
'Auditing UPDATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.REF is
'Dummy REF column. Maintained for backward compatibility of the view'
/
comment on column USER_OBJ_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.CRE is
'Auditing CREATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.REA is
'Auditing READ WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.WRI is
'Auditing WRITE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column USER_OBJ_AUDIT_OPTS.FBK is
'Auditing FLASHBACK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
create or replace public synonym USER_OBJ_AUDIT_OPTS for USER_OBJ_AUDIT_OPTS
/
grant select on USER_OBJ_AUDIT_OPTS to PUBLIC
/
create or replace view DBA_OBJ_AUDIT_OPTS 
        (OWNER,
         OBJECT_NAME, 
         OBJECT_TYPE, 
         ALT,
         AUD,
         COM,
         DEL,
         GRA,
         IND,
         INS,
         LOC,
         REN,
         SEL,
         UPD,
         REF,
         EXE,
         CRE,
         REA,
         WRI,
         FBK)
as
select u.name, o.name, 'TABLE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.tab$ t
where o.type# = 2
  and not (o.owner# = 0 and o.name = '_default_auditing_options_')
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = u.user#
  and o.obj# = t.obj#
union all
select u.name, o.name, 'VIEW',
       substr(v.audit$, 1, 1) || '/' || substr(v.audit$, 2, 1),
       substr(v.audit$, 3, 1) || '/' || substr(v.audit$, 4, 1),
       substr(v.audit$, 5, 1) || '/' || substr(v.audit$, 6, 1),
       substr(v.audit$, 7, 1) || '/' || substr(v.audit$, 8, 1),
       substr(v.audit$, 9, 1) || '/' || substr(v.audit$, 10, 1),
       substr(v.audit$, 11, 1) || '/' || substr(v.audit$, 12, 1),
       substr(v.audit$, 13, 1) || '/' || substr(v.audit$, 14, 1),
       substr(v.audit$, 15, 1) || '/' || substr(v.audit$, 16, 1),
       substr(v.audit$, 17, 1) || '/' || substr(v.audit$, 18, 1),
       substr(v.audit$, 19, 1) || '/' || substr(v.audit$, 20, 1),
       substr(v.audit$, 21, 1) || '/' || substr(v.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(v.audit$, 25, 1) || '/' || substr(v.audit$, 26, 1),
       substr(v.audit$, 27, 1) || '/' || substr(v.audit$, 28, 1),
       substr(v.audit$, 29, 1) || '/' || substr(v.audit$, 30, 1),
       substr(v.audit$, 31, 1) || '/' || substr(v.audit$, 32, 1),
       substr(v.audit$, 23, 1) || '/' || substr(v.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.view$ v
where o.type# = 4
  and o.owner# = u.user#
  and (instrb(v.audit$,'S') != 0  or instrb(v.audit$,'A') != 0)
  and o.obj# = v.obj#
union all
select u.name, o.name, 'SEQUENCE',
       substr(s.audit$, 1, 1) || '/' || substr(s.audit$, 2, 1),
       substr(s.audit$, 3, 1) || '/' || substr(s.audit$, 4, 1),
       substr(s.audit$, 5, 1) || '/' || substr(s.audit$, 6, 1),
       substr(s.audit$, 7, 1) || '/' || substr(s.audit$, 8, 1),
       substr(s.audit$, 9, 1) || '/' || substr(s.audit$, 10, 1),
       substr(s.audit$, 11, 1) || '/' || substr(s.audit$, 12, 1),
       substr(s.audit$, 13, 1) || '/' || substr(s.audit$, 14, 1),
       substr(s.audit$, 15, 1) || '/' || substr(s.audit$, 16, 1),
       substr(s.audit$, 17, 1) || '/' || substr(s.audit$, 18, 1),
       substr(s.audit$, 19, 1) || '/' || substr(s.audit$, 20, 1),
       substr(s.audit$, 21, 1) || '/' || substr(s.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(s.audit$, 25, 1) || '/' || substr(s.audit$, 26, 1),
       substr(s.audit$, 27, 1) || '/' || substr(s.audit$, 28, 1),
       substr(s.audit$, 29, 1) || '/' || substr(s.audit$, 30, 1),
       substr(s.audit$, 31, 1) || '/' || substr(s.audit$, 32, 1),
       substr(s.audit$, 23, 1) || '/' || substr(s.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.seq$ s
where o.type# = 6
  and o.owner# = u.user#
  and (instrb(s.audit$,'S') != 0  or instrb(s.audit$,'A') != 0)
  and o.obj# = s.obj#
union all
select u.name, o.name, 'PROCEDURE',
       substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1),
       substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1),
       substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1),
       substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1),
       substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1),
       substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1),
       substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1),
       substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1),
       substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1),
       substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1),
       substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1),
       substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1),
       substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1),
       substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1),
       substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.library$ p
where o.type# = 22
  and o.owner# = u.user#
  and (instrb(p.audit$,'S') != 0  or instrb(p.audit$,'A') != 0)
  and o.obj# = p.obj#
union all
select u.name, o.name, 'PROCEDURE',
       substr(p.audit$, 1, 1) || '/' || substr(p.audit$, 2, 1),
       substr(p.audit$, 3, 1) || '/' || substr(p.audit$, 4, 1),
       substr(p.audit$, 5, 1) || '/' || substr(p.audit$, 6, 1),
       substr(p.audit$, 7, 1) || '/' || substr(p.audit$, 8, 1),
       substr(p.audit$, 9, 1) || '/' || substr(p.audit$, 10, 1),
       substr(p.audit$, 11, 1) || '/' || substr(p.audit$, 12, 1),
       substr(p.audit$, 13, 1) || '/' || substr(p.audit$, 14, 1),
       substr(p.audit$, 15, 1) || '/' || substr(p.audit$, 16, 1),
       substr(p.audit$, 17, 1) || '/' || substr(p.audit$, 18, 1),
       substr(p.audit$, 19, 1) || '/' || substr(p.audit$, 20, 1),
       substr(p.audit$, 21, 1) || '/' || substr(p.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(p.audit$, 25, 1) || '/' || substr(p.audit$, 26, 1),
       substr(p.audit$, 27, 1) || '/' || substr(p.audit$, 28, 1),
       substr(p.audit$, 29, 1) || '/' || substr(p.audit$, 30, 1),
       substr(p.audit$, 31, 1) || '/' || substr(p.audit$, 32, 1),
       substr(p.audit$, 23, 1) || '/' || substr(p.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.procedure$ p
where o.type# >= 7 and o.type# <= 9
  and o.owner# = u.user#
  and (instrb(p.audit$,'S') != 0  or instrb(p.audit$,'A') != 0)
  and o.obj# = p.obj#
union all
select u.name, o.name, 'TYPE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys."_CURRENT_EDITION_OBJ" o, sys.user$ u, sys.type_misc$ t
where o.type# = 13
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'DIRECTORY',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 35, 1) || '/' || substr(t.audit$, 36, 1),
       substr(t.audit$, 37, 1) || '/' || substr(t.audit$, 38, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.dir$ t
where o.type# = 23
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = u.user#
  and o.obj# = t.obj#
union all
select u.name, o.name, 
       decode(o.type#, 28, 'JAVA SOURCE',
                       29, 'JAVA CLASS',
                       30, 'JAVA RESOURCE',
                       'ILLEGAL JAVA TYPE'),
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.javaobj$ t
where (o.type# = 28 or o.type# = 29 or o.type# = 30)
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'MINING MODEL',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.model$ t
where o.type# = 82
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.owner# = u.user#
  and o.obj# = t.obj#
union all
select u.name, o.name, 'EDITION',
       substr(e.audit$, 1, 1) || '/' || substr(e.audit$, 2, 1),
       substr(e.audit$, 3, 1) || '/' || substr(e.audit$, 4, 1),
       substr(e.audit$, 5, 1) || '/' || substr(e.audit$, 6, 1),
       substr(e.audit$, 7, 1) || '/' || substr(e.audit$, 8, 1),
       substr(e.audit$, 9, 1) || '/' || substr(e.audit$, 10, 1),
       substr(e.audit$, 11, 1) || '/' || substr(e.audit$, 12, 1),
       substr(e.audit$, 13, 1) || '/' || substr(e.audit$, 14, 1),
       substr(e.audit$, 15, 1) || '/' || substr(e.audit$, 16, 1),
       substr(e.audit$, 17, 1) || '/' || substr(e.audit$, 18, 1),
       substr(e.audit$, 19, 1) || '/' || substr(e.audit$, 20, 1),
       substr(e.audit$, 21, 1) || '/' || substr(e.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(e.audit$, 25, 1) || '/' || substr(e.audit$, 26, 1),
       substr(e.audit$, 27, 1) || '/' || substr(e.audit$, 28, 1),
       substr(e.audit$, 29, 1) || '/' || substr(e.audit$, 30, 1),
       substr(e.audit$, 31, 1) || '/' || substr(e.audit$, 32, 1),
       substr(e.audit$, 23, 1) || '/' || substr(e.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.edition$ e
where o.type# = 57
  and o.owner# = u.user#
  and (instrb(e.audit$,'S') != 0  or instrb(e.audit$,'A') != 0)
  and o.obj# = e.obj#
union all
select u.name, o.name, 'OLAP CUBE DIMENSION',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.olap_cube_dimensions$ t
where o.type# = 92
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'OLAP CUBE',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.olap_cubes$ t
where o.type# = 93
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'OLAP MEASURE FOLDER',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.olap_measure_folders$ t
where o.type# = 94
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
union all
select u.name, o.name, 'OLAP CUBE BUILD PROCESS',
       substr(t.audit$, 1, 1) || '/' || substr(t.audit$, 2, 1),
       substr(t.audit$, 3, 1) || '/' || substr(t.audit$, 4, 1),
       substr(t.audit$, 5, 1) || '/' || substr(t.audit$, 6, 1),
       substr(t.audit$, 7, 1) || '/' || substr(t.audit$, 8, 1),
       substr(t.audit$, 9, 1) || '/' || substr(t.audit$, 10, 1),
       substr(t.audit$, 11, 1) || '/' || substr(t.audit$, 12, 1),
       substr(t.audit$, 13, 1) || '/' || substr(t.audit$, 14, 1),
       substr(t.audit$, 15, 1) || '/' || substr(t.audit$, 16, 1),
       substr(t.audit$, 17, 1) || '/' || substr(t.audit$, 18, 1),
       substr(t.audit$, 19, 1) || '/' || substr(t.audit$, 20, 1),
       substr(t.audit$, 21, 1) || '/' || substr(t.audit$, 22, 1),
       '-/-',                                            /* dummy REF column */
       substr(t.audit$, 25, 1) || '/' || substr(t.audit$, 26, 1),
       substr(t.audit$, 27, 1) || '/' || substr(t.audit$, 28, 1),
       substr(t.audit$, 29, 1) || '/' || substr(t.audit$, 30, 1),
       substr(t.audit$, 31, 1) || '/' || substr(t.audit$, 32, 1),
       substr(t.audit$, 23, 1) || '/' || substr(t.audit$, 24, 1)
from sys.obj$ o, sys.user$ u, sys.olap_cube_build_processes$ t
where o.type# = 95
  and o.owner# = u.user#
  and (instrb(t.audit$,'S') != 0  or instrb(t.audit$,'A') != 0)
  and o.obj# = t.obj#
/
create or replace public synonym DBA_OBJ_AUDIT_OPTS for DBA_OBJ_AUDIT_OPTS
/
grant select on DBA_OBJ_AUDIT_OPTS to select_catalog_role
/
comment on table DBA_OBJ_AUDIT_OPTS is
'Auditing options for all tables and views with atleast one option set'
/
comment on column DBA_OBJ_AUDIT_OPTS.OWNER is
'Owner of the object'
/
comment on column DBA_OBJ_AUDIT_OPTS.OBJECT_NAME is
'Name of the object'
/
comment on column DBA_OBJ_AUDIT_OPTS.OBJECT_TYPE is
'Type of the object'
/
comment on column DBA_OBJ_AUDIT_OPTS.ALT is
'Auditing ALTER WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.AUD is
'Auditing AUDIT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.COM is
'Auditing COMMENT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.DEL is
'Auditing DELETE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.GRA is
'Auditing GRANT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.IND is
'Auditing INDEX WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.INS is
'Auditing INSERT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.LOC is
'Auditing LOCK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.REN is
'Auditing RENAME WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.SEL is
'Auditing SELECT WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.UPD is
'Auditing UPDATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.REF is
'Dummy REF column. Maintained for backward compatibility of the view'
/
comment on column DBA_OBJ_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.CRE is
'Auditing CREATE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.REA is
'Auditing READ WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.WRI is
'Auditing WRITE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.EXE is
'Auditing EXECUTE WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
comment on column DBA_OBJ_AUDIT_OPTS.FBK is
'Auditing FLASHBACK WHENEVER SUCCESSFUL / UNSUCCESSFUL'
/
remark
remark  FAMILY "STMT_AUDIT_OPTS"
remark  This view is only accessible to DBAs.
remark  One row is kept for each system auditing option set system wide, or
remark  for a particular user.
create or replace view DBA_STMT_AUDIT_OPTS
        (USER_NAME, 
        PROXY_NAME,
        AUDIT_OPTION, 
        SUCCESS, 
        FAILURE)
as
select decode(aud.user#, 0 /* client operations through proxy */, 'ANY CLIENT',
                         1 /* System wide auditing*/, null,
                         client.name)
                        /* USER_NAME */,
       proxy.name       /* PROXY_NAME */,
       aom.name         /* AUDIT_OPTION */,
       decode(aud.success, 1, 'BY SESSION', 2, 'BY ACCESS', 'NOT SET')
                        /* SUCCESS */,
       decode(aud.failure, 1, 'BY SESSION', 2, 'BY ACCESS', 'NOT SET')
                        /* FAILURE */
from sys.user$ client, sys.user$ proxy, STMT_AUDIT_OPTION_MAP aom,
     sys.audit$ aud
where aud.option# = aom.option#
  and aud.user# = client.user#
  and aud.proxy# = proxy.user#(+)
/
create or replace public synonym DBA_STMT_AUDIT_OPTS for DBA_STMT_AUDIT_OPTS
/
grant select on DBA_STMT_AUDIT_OPTS to select_catalog_role
/
comment on table DBA_STMT_AUDIT_OPTS is
'Describes current system auditing options across the system and by user'
/
comment on column DBA_STMT_AUDIT_OPTS.USER_NAME is
'User name if by user auditing.
 "ANY CLIENT" if access by a proxy on behalf of any client is being audited.
 NULL system wide auditing is being done'
/
comment on column DBA_STMT_AUDIT_OPTS.PROXY_NAME is
'Name of the proxy user if auditing is being done for operations being done on
behalf of a client. Null if auditing is being done for operations done by the
client directly'
/
comment on column DBA_STMT_AUDIT_OPTS.AUDIT_OPTION is
'Name of the system auditing option'
/
comment on column DBA_STMT_AUDIT_OPTS.SUCCESS is
'Mode for WHENEVER SUCCESSFUL system auditing'
/
comment on column DBA_STMT_AUDIT_OPTS.FAILURE is
'Mode for WHENEVER NOT SUCCESSFUL system auditing'
/
remark
remark  FAMILY "PRIV_AUDIT_OPTS"
remark  This view is only accessible to DBAs.
remark  One row is kept for each system privilegeauditing option set 
remark  system wide, or for a particular user.
create or replace view DBA_PRIV_AUDIT_OPTS
        (USER_NAME, 
        PROXY_NAME,
        PRIVILEGE, 
        SUCCESS, 
        FAILURE)
as
select decode(aud.user#, 0 /* client operations through proxy */, 'ANY CLIENT',
                         1 /* System wide auditing*/, null,
                         client.name) /* USER_NAME */,
       proxy.name       /* PROXY_NAME */,
       prv.name         /* PRIVILEGE */,
       decode(aud.success, 1, 'BY SESSION', 2, 'BY ACCESS', 'NOT SET')
                        /* SUCCESS */,
       decode(aud.failure, 1, 'BY SESSION', 2, 'BY ACCESS', 'NOT SET')
                        /* FAILURE */
from sys.user$ client, sys.user$ proxy, system_privilege_map prv,
     sys.audit$ aud
where aud.option# = -prv.privilege
  and aud.user# = client.user#
  and aud.proxy# = proxy.user#(+)
/
create or replace public synonym DBA_PRIV_AUDIT_OPTS for DBA_PRIV_AUDIT_OPTS
/
grant select on DBA_PRIV_AUDIT_OPTS to select_catalog_role
/
comment on table DBA_PRIV_AUDIT_OPTS is
'Describes current system privileges being audited across the system and by user'
/
comment on column DBA_PRIV_AUDIT_OPTS.USER_NAME is
'User name if by user auditing.
 "ANY CLIENT" if access by a proxy on behalf of any client is being audited.
 NULL system wide auditing is being done'
/
comment on column DBA_PRIV_AUDIT_OPTS.PROXY_NAME is
'Name of the proxy user if auditing is being done for operations being done on
behalf of a client. Null if auditing is being done for operations done by the
client directly'
/
comment on column DBA_PRIV_AUDIT_OPTS.PRIVILEGE is
'Name of the system privilege being audited'
/
comment on column DBA_PRIV_AUDIT_OPTS.SUCCESS is
'Mode for WHENEVER SUCCESSFUL system auditing'
/
comment on column DBA_PRIV_AUDIT_OPTS.FAILURE is
'Mode for WHENEVER NOT SUCCESSFUL system auditing'
/

remark
remark  FAMILY "AUDIT_TRAIL"
remark  DBA_AUDIT_TRAIL 
remark  The raw audit trail of all audit trail records in the system. Some
remark  columns are only filled in by certain statements. This view isis 
remark  accessible only to dba's.
remark
remark  USER_AUDIT_TRAIL
remark  The raw audit trail of all information related to the user
remark  or the objects owned by the user.  Some columns are only filled
remark  in by certain statements. This view is created by selecting from
remark  the DBA_AUDIT_TRAIL view, and retricting the rows.
remark '
create or replace view DBA_AUDIT_TRAIL
        (
         OS_USERNAME, 
         USERNAME,
         USERHOST,
         TERMINAL,
         TIMESTAMP,
         OWNER,
         OBJ_NAME,
         ACTION,
         ACTION_NAME,
         NEW_OWNER,
         NEW_NAME,
         OBJ_PRIVILEGE,
         SYS_PRIVILEGE,
         ADMIN_OPTION,
         GRANTEE,
         AUDIT_OPTION,
         SES_ACTIONS,
         LOGOFF_TIME,
         LOGOFF_LREAD,
         LOGOFF_PREAD,
         LOGOFF_LWRITE,
         LOGOFF_DLOCK,
         COMMENT_TEXT,
         SESSIONID,
         ENTRYID,
         STATEMENTID,
         RETURNCODE,
         PRIV_USED,
         CLIENT_ID,
         ECONTEXT_ID,
         SESSION_CPU,
         EXTENDED_TIMESTAMP,
         PROXY_SESSIONID,
         GLOBAL_UID,
         INSTANCE_NUMBER,
         OS_PROCESS, 
         TRANSACTIONID,
         SCN,
         SQL_BIND,
         SQL_TEXT,
         OBJ_EDITION_NAME,
         DBID
        )
as
select spare1           /* OS_USERNAME */,
       userid           /* USERNAME */,
       userhost         /* USERHOST */,
       terminal         /* TERMINAL */,
       cast (           /* TIMESTAMP */
           (from_tz(ntimestamp#,'00:00') at local) as date),
       obj$creator      /* OWNER */,
       obj$name         /* OBJECT_NAME */,
       aud.action#      /* ACTION */,
       act.name         /* ACTION_NAME */,
       new$owner        /* NEW_OWNER */,
       new$name         /* NEW_NAME */,
       decode(aud.action#, 
              108 /* grant  sys_priv */, null, 
              109 /* revoke sys_priv */, null, 
              114 /* grant  role */, null, 
              115 /* revoke role */, null,
              auth$privileges)  
                        /* OBJ_PRIVILEGE */,
       decode(aud.action#, 
              108 /* grant  sys_priv */, spm.name, 
              109 /* revoke sys_priv */, spm.name, 
              null)
                        /* SYS_PRIVILEGE */,
       decode(aud.action#, 
              108 /* grant  sys_priv */, substr(auth$privileges,1,1), 
              109 /* revoke sys_priv */, substr(auth$privileges,1,1), 
              114 /* grant  role */, substr(auth$privileges,1,1),
              115 /* revoke role */, substr(auth$privileges,1,1), 
              null)
                        /* ADMIN_OPTION */,
       auth$grantee     /* GRANTEE */,
       decode(aud.action#,
              104 /* audit   */, aom.name,
              105 /* noaudit */, aom.name,
              null)
                        /* AUDIT_OPTION  */,
       ses$actions      /* SES_ACTIONS   */,
       cast((from_tz(cast(logoff$time as timestamp),'00:00') at local) as date)
                        /* LOGOFF_TIME   */,
       logoff$lread     /* LOGOFF_LREAD  */,
       logoff$pread     /* LOGOFF_PREAD  */,
       logoff$lwrite    /* LOGOFF_LWRITE */,
       decode(aud.action#,
              104 /* audit   */, null,
              105 /* noaudit */, null,
              108 /* grant  sys_priv */, null, 
              109 /* revoke sys_priv */, null,
              114 /* grant  role */, null,
              115 /* revoke role */, null,
              aud.logoff$dead)
                         /* LOGOFF_DLOCK */,
       comment$text      /* COMMENT_TEXT */,
       sessionid         /* SESSIONID */,
       entryid           /* ENTRYID */,
       statement         /* STATEMENTID */,
       returncode        /* RETURNCODE */,
       spx.name          /* PRIVILEGE */,
       clientid          /* CLIENT_ID */,
       auditid           /* ECONTEXT_ID */,
       sessioncpu        /* SESSION_CPU */,
       from_tz(ntimestamp#,'00:00') at local,
                                   /* EXTENDED_TIMESTAMP */
       proxy$sid                      /* PROXY_SESSIONID */,
       user$guid                           /* GLOBAL_UID */,
       instance#                      /* INSTANCE_NUMBER */,
       process#                            /* OS_PROCESS */,
       xid                              /* TRANSACTIONID */,
       scn                                        /* SCN */,
       to_nchar(substr(sqlbind,1,2000))      /* SQL_BIND */,
       to_nchar(substr(sqltext,1,2000))      /* SQL_TEXT */,
       obj$edition                   /* OBJ_EDITION_NAME */,
       dbid                                      /* DBID */
from sys.aud$ aud, system_privilege_map spm, system_privilege_map spx,
     STMT_AUDIT_OPTION_MAP aom, audit_actions act
where   aud.action#     = act.action    (+)
  and - aud.logoff$dead = spm.privilege (+)
  and   aud.logoff$dead = aom.option#   (+)
  and - aud.priv$used   = spx.privilege (+)
/
create or replace public synonym DBA_AUDIT_TRAIL for DBA_AUDIT_TRAIL
/
grant select on DBA_AUDIT_TRAIL  to select_catalog_role
/
comment on table DBA_AUDIT_TRAIL is
'All audit trail entries'
/
comment on column DBA_AUDIT_TRAIL.OS_USERNAME is
'Operating System logon user name of the user whose actions were audited'
/
comment on column DBA_AUDIT_TRAIL.USERNAME is
'Name (not ID number) of the user whose actions were audited'
/
comment on column DBA_AUDIT_TRAIL.USERHOST is
'Client host machine name'
/
comment on column DBA_AUDIT_TRAIL.TERMINAL is
'Identifier for the user''s terminal'
/
comment on column DBA_AUDIT_TRAIL.TIMESTAMP is
'Date/Time of the creation of the audit trail entry (Date/Time of the user''s logon for entries created by AUDIT SESSION) in session''s time zone'
/
comment on column DBA_AUDIT_TRAIL.OWNER is
'Creator of object affected by the action'
/
comment on column DBA_AUDIT_TRAIL.OBJ_NAME is
'Name of the object affected by the action'
/
comment on column DBA_AUDIT_TRAIL.ACTION is
'Numeric action type code.  The corresponding name of the action type (CREATE TABLE, INSERT, etc.) is in the column ACTION_NAME'
/
comment on column DBA_AUDIT_TRAIL.ACTION_NAME is
'Name of the action type corresponding to the numeric code in ACTION'
/
comment on column DBA_AUDIT_TRAIL.NEW_OWNER is
'The owner of the object named in the NEW_NAME column'
/
comment on column DBA_AUDIT_TRAIL.NEW_NAME is
'New name of object after RENAME, or name of underlying object (e.g. CREATE INDEX owner.obj_name ON new_owner.new_name)'
/
comment on column DBA_AUDIT_TRAIL.OBJ_PRIVILEGE is
'Object privileges granted/revoked by a GRANT/REVOKE statement'
/
remark  There is one audit entry for each system privilege

comment on column DBA_AUDIT_TRAIL.SYS_PRIVILEGE is
'System privileges granted/revoked by a GRANT/REVOKE statement'
/
comment on column DBA_AUDIT_TRAIL.ADMIN_OPTION is
'If role/sys_priv was granted WITH ADMIN OPTON, A/-'
/
remark  There is one audit entry for each grantee.

comment on column DBA_AUDIT_TRAIL.GRANTEE is
'The name of the grantee specified in a GRANT/REVOKE statement'
/
remark  There is one audit entry for each system audit option

comment on column DBA_AUDIT_TRAIL.AUDIT_OPTION is
'Auditing option set with the audit statement'
/
comment on column DBA_AUDIT_TRAIL.SES_ACTIONS is
'Session summary.  A string of 12 characters, one for each action type, in thisorder: Alter, Audit, Comment, Delete, Grant, Index, Insert, Lock, Rename, Select, Update, Flashback.  Values:  "-" = None, "S" = Success, "F" = Failure, "B" = Both'
/
remark  A single audit entry describes both the logon and logoff.
remark  The logoff_* columns are null while a user is logged in.

comment on column DBA_AUDIT_TRAIL.LOGOFF_TIME is
'Timestamp for user logoff'
/
comment on column DBA_AUDIT_TRAIL.LOGOFF_LREAD is
'Logical reads for the session'
/
comment on column DBA_AUDIT_TRAIL.LOGOFF_PREAD is
'Physical reads for the session'
/
comment on column DBA_AUDIT_TRAIL.LOGOFF_LWRITE is
'Logical writes for the session'
/
comment on column DBA_AUDIT_TRAIL.LOGOFF_DLOCK is
'Deadlocks detected during the session'
/
comment on column DBA_AUDIT_TRAIL.COMMENT_TEXT is
'Text comment on the audit trail entry.
Also indicates how the user was authenticated. The method can be one of the
following:
1. "DATABASE" - authentication was done by password.
2. "NETWORK"  - authentication was done by Net8 or the Advanced Networking
   Option.
3. "PROXY"    - the client was authenticated by another user. The name of the
   proxy user follows the method type.'
/
comment on column DBA_AUDIT_TRAIL.SESSIONID is
'Numeric ID for each Oracle session'
/
comment on column DBA_AUDIT_TRAIL.ENTRYID is
'Numeric ID for each audit trail entry in the session'
/
comment on column DBA_AUDIT_TRAIL.STATEMENTID is
'Numeric ID for each statement run (a statement may cause many actions)'
/
comment on column DBA_AUDIT_TRAIL.RETURNCODE is
'Oracle error code generated by the action.  Zero if the action succeeded'
/
comment on column DBA_AUDIT_TRAIL.PRIV_USED is
'System privilege used to execute the action'
/
comment on column DBA_AUDIT_TRAIL.CLIENT_ID is
'Client identifier in each Oracle session'
/
comment on column DBA_AUDIT_TRAIL.ECONTEXT_ID is
'Execution Context Identifier for each action'
/
comment on column DBA_AUDIT_TRAIL.SESSION_CPU is
'Amount of cpu time used by each Oracle session'
/
comment on column DBA_AUDIT_TRAIL.EXTENDED_TIMESTAMP is
'Timestamp of the creation of audit trail entry (Timestamp of the user''s logon for entries created by AUDIT SESSION) in session''s time zone'
/
comment on column DBA_AUDIT_TRAIL.PROXY_SESSIONID is
'Proxy session serial number, if enterprise user has logged through proxy mechanism'
/
comment on column DBA_AUDIT_TRAIL.GLOBAL_UID is
'Global user identifier for the user, if the user had logged in as enterprise user'
/
comment on column DBA_AUDIT_TRAIL.INSTANCE_NUMBER is
'Instance number as specified in the initialization parameter file ''init.ora'''
/
comment on column DBA_AUDIT_TRAIL.OS_PROCESS is
'Operating System process identifier of the Oracle server process'
/
comment on column DBA_AUDIT_TRAIL.TRANSACTIONID is
'Transaction identifier of the transaction in which the object is accessed or modified'
/
comment on column DBA_AUDIT_TRAIL.SCN is
'SCN (System Change Number) of the query'
/
comment on column DBA_AUDIT_TRAIL.SQL_BIND is
'Bind variable data of the query'
/
comment on column DBA_AUDIT_TRAIL.SQL_TEXT is
'SQL text of the query'
/
comment on column DBA_AUDIT_TRAIL.OBJ_EDITION_NAME is
'Edition containing audited object'
/
comment on column DBA_AUDIT_TRAIL.DBID is
'Database Identifier of the audited database'
/
create or replace view USER_AUDIT_TRAIL 
        (
         OS_USERNAME, 
         USERNAME,
         USERHOST,
         TERMINAL,
         TIMESTAMP,
         OWNER,
         OBJ_NAME,
         ACTION,
         ACTION_NAME,
         NEW_OWNER,
         NEW_NAME,
         OBJ_PRIVILEGE,
         SYS_PRIVILEGE,
         ADMIN_OPTION,
         GRANTEE,
         AUDIT_OPTION,
         SES_ACTIONS,
         LOGOFF_TIME,
         LOGOFF_LREAD,
         LOGOFF_PREAD,
         LOGOFF_LWRITE,
         LOGOFF_DLOCK,
         COMMENT_TEXT,
         SESSIONID,
         ENTRYID,
         STATEMENTID,
         RETURNCODE,
         PRIV_USED,
         CLIENT_ID,
         ECONTEXT_ID,
         SESSION_CPU,
         EXTENDED_TIMESTAMP,
         PROXY_SESSIONID,
         GLOBAL_UID,
         INSTANCE_NUMBER,
         OS_PROCESS,
         TRANSACTIONID,
         SCN,
         SQL_BIND,
         SQL_TEXT,
         OBJ_EDITION_NAME,
         DBID
        )
as
select d.* from dba_audit_trail d, sys.user$ u
where ((d.owner = u.name and u.user# = USERENV('SCHEMAID'))
or (d.owner is null and d.username = u.name and u.user# = USERENV('SCHEMAID'))) 
/
comment on table USER_AUDIT_TRAIL is
'Audit trail entries relevant to the user'
/
comment on column USER_AUDIT_TRAIL.OS_USERNAME is
'Operating System logon user name of the user whose actions were audited'
/
comment on column USER_AUDIT_TRAIL.USERNAME is
'Name (not ID number) of the user whose actions were audited'
/
comment on column USER_AUDIT_TRAIL.USERHOST is
'Numeric instance ID for the Oracle instance from which the user is accessing the database.  Used only in environments with distributed file systems and shared database files (e.g., clustered Oracle on DEC VAX/VMS clusters)'
/
comment on column USER_AUDIT_TRAIL.TERMINAL is
'Identifier for the user''s terminal'
/
comment on column USER_AUDIT_TRAIL.TIMESTAMP is
'Date/Time of the creation of the audit trail entry (Date/Time of the user''s logon for entries created by AUDIT SESSION) in session''s time zone'
/
comment on column USER_AUDIT_TRAIL.OWNER is
'Creator of object affected by the action'
/
comment on column USER_AUDIT_TRAIL.OBJ_NAME is
'Name of the object affected by the action'
/
comment on column USER_AUDIT_TRAIL.ACTION is
'Numeric action type code.  The corresponding name of the action type (CREATE TABLE, INSERT, etc.) is in the column ACTION_NAME'
/
comment on column USER_AUDIT_TRAIL.ACTION_NAME is
'Name of the action type corresponding to the numeric code in ACTION'
/
comment on column USER_AUDIT_TRAIL.NEW_OWNER is
'The owner of the object named in the NEW_NAME column'
/
comment on column USER_AUDIT_TRAIL.NEW_NAME is
'New name of object after RENAME, or name of underlying object (e.g. CREATE INDEX owner.obj_name ON new_owner.new_name)'
/
comment on column USER_AUDIT_TRAIL.OBJ_PRIVILEGE is
'Object privileges granted/revoked by a GRANT/REVOKE statement'
/
remark  There is one audit entry for each system privilege

comment on column USER_AUDIT_TRAIL.SYS_PRIVILEGE is
'System privileges granted/revoked by a GRANT/REVOKE statement'
/
comment on column USER_AUDIT_TRAIL.ADMIN_OPTION is
'If role/sys_priv was granted WITH ADMIN OPTON, A/-'
/
remark  There is one audit entry for each grantee.

comment on column USER_AUDIT_TRAIL.GRANTEE is
'The name of the grantee specified in a GRANT/REVOKE statement'
/
remark  There is one audit entry for each system audit option

comment on column USER_AUDIT_TRAIL.AUDIT_OPTION is
'Auditing option set with the audit statement'
/
comment on column USER_AUDIT_TRAIL.SES_ACTIONS is
'Session summary.  A string of 12 characters, one for each action type, in thisorder: Alter, Audit, Comment, Delete, Grant, Index, Insert, Lock, Rename, Select, Update, Flashback.  Values:  "-" = None, "S" = Success, "F" = Failure, "B" = Both'
/
remark  A single audit entry describes both the logon and logoff.
remark  The logoff_* columns are null while a user is logged in.

comment on column USER_AUDIT_TRAIL.LOGOFF_TIME is
'Timestamp for user logoff'
/
comment on column USER_AUDIT_TRAIL.LOGOFF_LREAD is
'Logical reads for the session'
/
comment on column USER_AUDIT_TRAIL.LOGOFF_PREAD is
'Physical reads for the session'
/
comment on column USER_AUDIT_TRAIL.LOGOFF_LWRITE is
'Logical writes for the session'
/
comment on column USER_AUDIT_TRAIL.LOGOFF_DLOCK is
'Deadlocks detected during the session'
/
comment on column USER_AUDIT_TRAIL.COMMENT_TEXT is
'Text comment on the audit trail entry.
Also indicates how the user was authenticated. The method can be one of the
following:
1. "DATABASE" - authentication was done by password.
2. "NETWORK"  - authentication was done by Net8 or the Advanced Networking
   Option.
3. "PROXY"    - the client was authenticated by another user. The name of the
   proxy user follows the method type.'
/
comment on column USER_AUDIT_TRAIL.SESSIONID is
'Numeric ID for each Oracle session'
/
comment on column USER_AUDIT_TRAIL.ENTRYID is
'Numeric ID for each audit trail entry in the session'
/
comment on column USER_AUDIT_TRAIL.STATEMENTID is
'Numeric ID for each statement run (a statement may cause many actions)'
/
comment on column USER_AUDIT_TRAIL.RETURNCODE is
'Oracle error code generated by the action.  Zero if the action succeeded'
/
comment on column USER_AUDIT_TRAIL.PRIV_USED is
'System privilege used to execute the action'
/
comment on column USER_AUDIT_TRAIL.CLIENT_ID is
'Client identifier in each Oracle session'
/
comment on column USER_AUDIT_TRAIL.ECONTEXT_ID is
'Execution Context Identifier for each action'
/
comment on column USER_AUDIT_TRAIL.SESSION_CPU is
'Amount of cpu time used by each Oracle session'
/
comment on column USER_AUDIT_TRAIL.EXTENDED_TIMESTAMP is
'Timestamp of the creation of audit trail entry (Timestamp of the user''s logon for entries created by AUDIT SESSION) in session''s time zone'
/
comment on column USER_AUDIT_TRAIL.PROXY_SESSIONID is
'Proxy session serial number, if enterprise user has logged through proxy mechanism'
/
comment on column USER_AUDIT_TRAIL.GLOBAL_UID is
'Global user identifier for the user, if the user had logged in as enterprise user'
/
comment on column USER_AUDIT_TRAIL.INSTANCE_NUMBER is
'Instance number as specified in the initialization parameter file ''init.ora'''
/
comment on column USER_AUDIT_TRAIL.OS_PROCESS is
'Operating System process identifier of the Oracle server process'
/
comment on column USER_AUDIT_TRAIL.TRANSACTIONID is
'Transaction identifier of the transaction in which the object is accessed or modified'
/
comment on column USER_AUDIT_TRAIL.SCN is
'SCN (System Change Number) of the query'
/
comment on column USER_AUDIT_TRAIL.SQL_BIND is
'Bind variable data of the query'
/
comment on column USER_AUDIT_TRAIL.SQL_TEXT is
'SQL text of the query'
/
comment on column USER_AUDIT_TRAIL.OBJ_EDITION_NAME is
'Edition containing audited object'
/
comment on column USER_AUDIT_TRAIL.DBID is
'Database Identifier of the audited database'
/
create or replace public synonym USER_AUDIT_TRAIL for USER_AUDIT_TRAIL
/
grant select on USER_AUDIT_TRAIL to public
/
remark 
remark  FAMILY "AUDIT_SESSION"
remark
remark  DBA_AUDIT_SESSION
remark  All audit trail records concerning connect and disconnect, based
remark  DBA_AUDIT_TRAIL.
remark
remark  USER_AUDIT_SESSION
remark  All audit trail records concerning connect and disconnect, based
remark  USER_AUDIT_TRAIL.
remark


create or replace view DBA_AUDIT_SESSION
as
select os_username,  username, userhost, terminal, timestamp, action_name, 
       logoff_time, logoff_lread, logoff_pread, logoff_lwrite, logoff_dlock, 
       sessionid, returncode, client_id, session_cpu, extended_timestamp,
       proxy_sessionid, global_uid, instance_number, os_process
from dba_audit_trail
where action between 100 and 102
/
create or replace public synonym DBA_AUDIT_SESSION for DBA_AUDIT_SESSION
/
grant select on DBA_AUDIT_SESSION to select_catalog_role
/
comment on table DBA_AUDIT_SESSION is
'All audit trail records concerning CONNECT and DISCONNECT'
/

create or replace view USER_AUDIT_SESSION
as
select os_username,  username, userhost, terminal, timestamp, action_name, 
       logoff_time, logoff_lread, logoff_pread, logoff_lwrite, logoff_dlock, 
       sessionid, returncode, client_id, session_cpu, extended_timestamp,
       proxy_sessionid, global_uid, instance_number, os_process
from user_audit_trail 
where action between 100 and 102
/
create or replace public synonym USER_AUDIT_SESSION for USER_AUDIT_SESSION
/
grant select on USER_AUDIT_SESSION to public
/
comment on table USER_AUDIT_SESSION is
'All audit trail records concerning CONNECT and DISCONNECT'
/

remark
remark  FAMILY "AUDIT_STATEMENT"
remark
remark  DBA_AUDIT_STATEMENT
remark  All audit trail records concerning the following statements:
remark  grant, revoke, audit, noaudit and alter system.
remark  Based on DBA_AUDIT_TRAIL.
remark  
remark  USER_AUDIT_STATEMENT
remark  Same as the DBA version, except it is based on USER_AUDIT_TRAIL.
remark

create or replace view DBA_AUDIT_STATEMENT
as
select OS_USERNAME, USERNAME, USERHOST, TERMINAL, TIMESTAMP, 
       OWNER, OBJ_NAME, ACTION_NAME, NEW_NAME, 
       OBJ_PRIVILEGE, SYS_PRIVILEGE, ADMIN_OPTION, GRANTEE, AUDIT_OPTION,
       SES_ACTIONS, COMMENT_TEXT,  SESSIONID, ENTRYID, STATEMENTID, 
       RETURNCODE, PRIV_USED, CLIENT_ID, ECONTEXT_ID, SESSION_CPU, 
       EXTENDED_TIMESTAMP, PROXY_SESSIONID, GLOBAL_UID, INSTANCE_NUMBER, 
       OS_PROCESS, TRANSACTIONID, SCN, SQL_BIND, SQL_TEXT, OBJ_EDITION_NAME
from dba_audit_trail
where action in (        17 /* GRANT OBJECT  */, 
                         18 /* REVOKE OBJECT */, 
                         30 /* AUDIT OBJECT */,
                         31 /* NOAUDIT OBJECT */,
                         49 /* ALTER SYSTEM */,
                        104 /* SYSTEM AUDIT */,
                        105 /* SYSTEM NOAUDIT */,
                        106 /* AUDIT DEFAULT */,
                        107 /* NOAUDIT DEFAULT */,
                        108 /* SYSTEM GRANT */,
                        109 /* SYSTEM REVOKE */,
                        114 /* GRANT ROLE */,
                        115 /* REVOKE ROLE */ ) 
/
create or replace public synonym DBA_AUDIT_STATEMENT for DBA_AUDIT_STATEMENT
/
grant select on DBA_AUDIT_STATEMENT  to select_catalog_role
/
comment on table DBA_AUDIT_STATEMENT is
'Audit trail records concerning  grant, revoke, audit, noaudit and alter system'
/

create or replace view USER_AUDIT_STATEMENT
as
select OS_USERNAME, USERNAME, USERHOST, TERMINAL, TIMESTAMP, 
       OWNER, OBJ_NAME, ACTION_NAME, NEW_NAME, 
       OBJ_PRIVILEGE, SYS_PRIVILEGE, ADMIN_OPTION, GRANTEE, AUDIT_OPTION,
       SES_ACTIONS, COMMENT_TEXT,  SESSIONID, ENTRYID, STATEMENTID, 
       RETURNCODE, PRIV_USED, CLIENT_ID, ECONTEXT_ID, SESSION_CPU, 
       EXTENDED_TIMESTAMP, PROXY_SESSIONID, GLOBAL_UID, INSTANCE_NUMBER, 
       OS_PROCESS, TRANSACTIONID, SCN, SQL_BIND, SQL_TEXT, OBJ_EDITION_NAME
from user_audit_trail
where action in (        17 /* GRANT OBJECT  */, 
                         18 /* REVOKE OBJECT */, 
                         30 /* AUDIT OBJECT */,
                         31 /* NOAUDIT OBJECT */,
                         49 /* ALTER SYSTEM */,
                        104 /* SYSTEM AUDIT */,
                        105 /* SYSTEM NOAUDIT */,
                        106 /* AUDIT DEFAULT */,
                        107 /* NOAUDIT DEFAULT */,
                        108 /* SYSTEM GRANT*/,
                        109 /* SYSTEM REVOKE */,
                        114 /* GRANT ROLE */,
                        115 /* REVOKE ROLE */ ) 
/
comment on table USER_AUDIT_STATEMENT is
'Audit trail records concerning  grant, revoke, audit, noaudit and alter system'
/
create or replace public synonym USER_AUDIT_STATEMENT for USER_AUDIT_STATEMENT
/
grant select on USER_AUDIT_STATEMENT to public
/

remark
remark  FAMILY "AUDIT_OBJECT"
remark
remark  DBA_AUDIT_OBJECT
remark  Audit trail records for statements concerning objects, 
remark  specifically: table, cluster, view, index, sequence, 
remark  [public] database link, [public] synonym, procedure, trigger,
remark  rollback segment, tablespace, role, user. The audit trail 
remark  records for audit/noaudit and grant/revoke operations on these 
remark  objects can be seen through the dba_audit_statement view.
remark
remark  USER_AUDIT_OBJECT
remark  Same as DBA_AUDIT_OBJECT, except this is based on 
remark  DBA_AUDIT_TRAIL.
remark

create or replace view DBA_AUDIT_OBJECT
as
select OS_USERNAME, USERNAME, USERHOST, TERMINAL, TIMESTAMP, 
       OWNER, OBJ_NAME, ACTION_NAME, NEW_OWNER, NEW_NAME, 
       SES_ACTIONS, COMMENT_TEXT, SESSIONID, ENTRYID, STATEMENTID, 
       RETURNCODE, PRIV_USED, CLIENT_ID, ECONTEXT_ID, SESSION_CPU,
       EXTENDED_TIMESTAMP, PROXY_SESSIONID, GLOBAL_UID, INSTANCE_NUMBER, 
       OS_PROCESS, TRANSACTIONID, SCN, SQL_BIND, SQL_TEXT, OBJ_EDITION_NAME
from dba_audit_trail
where (action between 1 and 16)
   or (action between 19 and 29)
   or (action between 32 and 41)
   or (action = 43)
   or (action between 51 and 99)
   or (action = 103)
   or (action between 110 and 113)
   or (action between 116 and 121)
   or (action between 123 and 128)
   or (action between 160 and 162)
/
create or replace public synonym DBA_AUDIT_OBJECT for DBA_AUDIT_OBJECT
/
grant select on DBA_AUDIT_OBJECT to select_catalog_role
/
comment on table DBA_AUDIT_OBJECT is 
'Audit trail records for statements concerning objects, specifically: table, cluster, view, index, sequence,  [public] database link, [public] synonym, procedure, trigger, rollback segment, tablespace, role, user'
/

create or replace view USER_AUDIT_OBJECT
as
select OS_USERNAME, USERNAME, USERHOST, TERMINAL, TIMESTAMP, 
       OWNER, OBJ_NAME, ACTION_NAME, NEW_OWNER, NEW_NAME, 
       SES_ACTIONS, COMMENT_TEXT, SESSIONID, ENTRYID, STATEMENTID, 
       RETURNCODE, PRIV_USED, CLIENT_ID, ECONTEXT_ID, SESSION_CPU,
       EXTENDED_TIMESTAMP, PROXY_SESSIONID, GLOBAL_UID, INSTANCE_NUMBER, 
       OS_PROCESS, TRANSACTIONID, SCN, SQL_BIND, SQL_TEXT, OBJ_EDITION_NAME
from user_audit_trail
where (action between 1 and 16)
   or (action between 19 and 29)
   or (action between 32 and 41)
   or (action = 43)
   or (action between 51 and 99)
   or (action = 103)
   or (action between 110 and 113)
   or (action between 116 and 121)
   or (action between 123 and 128)
   or (action between 160 and 162)
/
comment on table USER_AUDIT_OBJECT is 
'Audit trail records for statements concerning objects, specifically: table, cluster, view, index, sequence,  [public] database link, [public] synonym, procedure, trigger, rollback segment, tablespace, role, user'
/
create or replace public synonym USER_AUDIT_OBJECT for USER_AUDIT_OBJECT
/
grant select on USER_AUDIT_OBJECT to public
/

remark
remark  DBA_AUDIT_EXISTS
remark  Only dba's can see audit info about objects that do not exist.
remark
remark  Lists audit trail entries produced by AUDIT EXISTS/NOT EXISTS.
remark  This is all audit trail entries with return codes of
remark  942, 943, 959, 1418, 1432, 1434, 1435, 1534, 1917, 1918, 1919,
remark  2019, 2024 and 2289 and for Trusted ORACLE 1, 951, 955, 957, 1430,
remark  1433, 1452, 1471, 1535, 1543, 1758, 1920, 1921, 1922, 2239, 2264,
remark  2266, 2273, 2292, 2297, 2378, 2379, 2382, 4081, 12006, 12325.
remark  This view is accessible to DBAs only.
remark
create or replace view DBA_AUDIT_EXISTS
as
  select os_username, username, userhost, terminal, timestamp, 
         owner, obj_name, 
         action_name, 
         new_owner, 
         new_name,
         obj_privilege, sys_privilege, grantee, 
         sessionid, entryid, statementid, returncode, client_id, 
         econtext_id, session_cpu, 
         extended_timestamp, proxy_sessionid, global_uid, instance_number, 
         os_process, transactionid, scn, sql_bind, sql_text, obj_edition_name
  from dba_audit_trail
  where returncode in
  (942, 943, 959, 1418, 1432, 1434, 1435, 1534, 1917, 1918, 1919, 2019, 
   2024, 2289,
   4042, 4043, 4080, 1, 951, 955, 957, 1430, 1433, 1452, 1471, 1535, 1543,
   1758, 1920, 1921, 1922, 2239, 2264, 2266, 2273, 2292, 2297, 2378, 2379,
   2382, 4081, 12006, 12325)
/
create or replace public synonym DBA_AUDIT_EXISTS for DBA_AUDIT_EXISTS
/
grant select on DBA_AUDIT_EXISTS to select_catalog_role
/
comment on table DBA_AUDIT_EXISTS is
'Lists audit trail entries produced by AUDIT NOT EXISTS and AUDIT EXISTS'
/
