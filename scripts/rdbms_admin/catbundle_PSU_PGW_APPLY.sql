REM This script is /u01/app/oracle/product/11.2.0/dbhome_1/rdbms/admin/catbundle_PSU_PGW_APPLY.sql
REM It was generated by catbundle.sql on 2016Jul14_13_43_56
SET echo on
COLUMN spool_file NEW_VALUE spool_file NOPRINT
SELECT '/u01/app/oracle/cfgtoollogs/catbundle/' || 'catbundle_PSU_' || name || '_APPLY_' || TO_CHAR(SYSDATE, 'YYYYMonDD_hh24_mi_ss', 'NLS_DATE_LANGUAGE=''AMERICAN''') || '.log' AS spool_file FROM v$database;
SPOOL &spool_file
exec sys.dbms_registry.set_session_namespace('SERVER')
PROMPT Processing OLAP Analytic Workspace...
ALTER SESSION SET current_schema = sys;
@?/rdbms/admin/bug20558005.sql
@?/rdbms/admin/bug20596234.sql
PROMPT Processing Oracle Database Packages and Types...
ALTER SESSION SET current_schema = sys;
@?/rdbms/admin/prvtdadv.plb
@?/rdbms/admin/prvtadv.plb
@?/patch/scripts/bug17381384.sql
@?/rdbms/admin/prvtredacta.plb
@?/rdbms/admin/prvtpckl.plb
@?/patch/scripts/bug16595641.sql
@?/patch/scripts/bug19289642.sql
@?/rdbms/admin/prvthstr.plb
@?/rdbms/admin/prvtbstr.plb
@?/rdbms/admin/prvtlmd.plb
@?/rdbms/admin/prvtutil.plb
@?/rdbms/admin/prvthsmt.plb
@?/rdbms/admin/prvtbsmt.plb
@?/rdbms/admin/prvthapp.plb
@?/rdbms/admin/prvtbapp.plb
@?/rdbms/admin/prvthsdp.plb
@?/rdbms/admin/prvtbsdp.plb
@?/rdbms/admin/prvthlin.plb
@?/rdbms/admin/prvtblin.plb
@?/rdbms/admin/prvthxstr.plb
@?/rdbms/admin/prvtbxstr.plb
@?/rdbms/admin/prvtbsts.plb
@?/rdbms/admin/dbmsrman.sql
@?/rdbms/admin/prvtrmns.plb
@?/rdbms/admin/prvtlmcb.plb
@?/rdbms/admin/prvtaqxe.plb
@?/rdbms/admin/prvtbsrp.plb
@?/rdbms/admin/prvtaqme.plb
@?/rdbms/admin/prvtaqds.plb
@?/rdbms/admin/bug20876312_apply.sql
@?/rdbms/admin/prvtawrs.plb
PROMPT Processing Oracle Workspace Manager...
ALTER SESSION SET current_schema = sys;
@?/rdbms/admin/owmadms.plb
@?/rdbms/admin/owmadmb.plb
@?/rdbms/admin/owmdtrgb.plb
@?/rdbms/admin/owmmigb.plb
@?/rdbms/admin/owmltb.plb
@?/rdbms/admin/owmreplb.plb
@?/rdbms/admin/owmricb.plb
@?/rdbms/admin/owmutrgb.plb
PROMPT Processing Spatial...
ALTER SESSION SET current_schema = sys;
@?/patch/scripts/bug17088068.sql
ALTER SESSION SET current_schema = SYS;
PROMPT Updating registry...
INSERT INTO registry$history 
  (action_time, action,
   namespace, version, id, 
   bundle_series, comments)
VALUES
  (SYSTIMESTAMP, 'APPLY', 
   SYS_CONTEXT('REGISTRY$CTX','NAMESPACE'), 
   '11.2.0.4', 
   160419, 
   'PSU',
   'PSU 11.2.0.4.160419');
COMMIT;
SPOOL off
SET echo off
PROMPT Check the following log file for errors:
PROMPT &spool_file
