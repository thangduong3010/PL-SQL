Rem
Rem $Header: rdbms/admin/catqos.sql /st_rdbms_11.2.0/1 2011/03/15 11:26:01 alui Exp $
Rem
Rem catqos.sql
Rem
Rem Copyright (c) 2008, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catqos.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      Create Quality of Service Management Schema in the datbase
Rem
Rem    NOTES
Rem      This script must run after catsnmp so that the DBSNMP user is
Rem      already in place when the grants are done.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    alui        03/10/11 - Backport alui_bug-11668542 from main
Rem    sbasu       06/05/10 - add privilege to APPQOSSYS user for RLB|CLB info
Rem    alui        10/26/09 - add tables for pushing alerts
Rem    dsemler     03/10/09 - add EM access to WLM_CLASSIFIER_PLAN
Rem    dsemler     02/24/09 - remove psm column, add negative_interval column
Rem                           to wlm_metrics_stream
Rem    dsemler     11/26/08 - correct privileges assigned to appqossys
Rem    alui        08/15/08 - change Max classifier list string from 2048 to
Rem                           4000
Rem    alui        06/11/08 - add classifier table
Rem    dsemler     03/26/08 - add required permissions to the APPQOSSYS user
Rem    dsemler     01/10/08 - Created
Rem

create user APPQOSSYS identified by "APPQOSSYS"
  default tablespace sysaux
  quota unlimited on sysaux
  account lock password expire;

Rem Grants required for APPQOSSYS
grant CREATE SESSION to APPQOSSYS;
grant SELECT on sys.v_$wlm_pcmetric to APPQOSSYS;
grant SELECT on DBA_RSRC_CONSUMER_GROUPS to APPQOSSYS;
grant SELECT on DBA_RSRC_GROUP_MAPPINGS to APPQOSSYS;
grant SELECT on V_$SESSION to APPQOSSYS;
grant SELECT on V_$PROCESS to APPQOSSYS;
grant SELECT on V_$LICENSE to APPQOSSYS;
grant SELECT on V_$OSSTAT to APPQOSSYS;
grant SELECT on ALL_SERVICES to APPQOSSYS;
grant ALTER SESSION to APPQOSSYS;
grant execute on WLM_CAPABILITY_OBJECT to APPQOSSYS;
grant execute on WLM_CAPABILITY_ARRAY to APPQOSSYS;

Rem Execute on DBMS_WLM permits DBWLM to upload classifiers used in tagging
grant execute on dbms_wlm to appqossys;

Rem Grant Resource Manager Admin privilege, so DBWLM can alter consumer
Rem   group mappings.
begin
dbms_resource_manager_privs.grant_system_privilege(
  grantee_name => 'APPQOSSYS',
  privilege_name => 'ADMINISTER_RESOURCE_MANAGER',
  admin_option => FALSE);
end;
/

ALTER SESSION SET CURRENT_SCHEMA = APPQOSSYS;

CREATE TABLE wlm_metrics_stream
(
   timestamp          DATE,
   pc                 VARCHAR2(31),
   negative_interval  NUMBER
)
/

CREATE TABLE wlm_classifier_plan
(
   oper               NUMBER,
   nclsrs             NUMBER,
   clpcstr            VARCHAR2(4000),
   active             CHAR,
   seqno              NUMBER,
   timestamp          DATE,
   chksum             NUMBER
)
/

CREATE TABLE wlm_mpa_stream
(
   name               VARCHAR2(4000),
   serverorpool       VARCHAR2(8),
   risklevel          NUMBER
)
/

CREATE TABLE wlm_violation_stream
(
   timestamp         DATE,
   serverpool        VARCHAR2(4000),
   violation         VARCHAR2(4000)
)
/

Rem Allow the EM Agent access to this table for PSM alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_METRICS_STREAM
  FOR APPQOSSYS.WLM_METRICS_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_metrics_stream TO DBSNMP;

Rem Allow the EM Agent access to WLM_CLASSIFIER_PLAN
CREATE OR REPLACE PUBLIC SYNONYM WLM_CLASSIFIER_PLAN
  FOR APPQOSSYS.WLM_CLASSIFIER_PLAN;
GRANT SELECT ON APPQOSSYS.wlm_classifier_plan TO DBSNMP;

Rem Allow the EM Agent access to this table for alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_MPA_STREAM
  FOR APPQOSSYS.WLM_MPA_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_mpa_stream TO DBSNMP;

Rem Allow the EM Agent access to this table for alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_VIOLATION_STREAM
  FOR APPQOSSYS.WLM_VIOLATION_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_violation_stream TO DBSNMP;

CREATE SYNONYM DBMS_WLM FOR SYS.DBMS_WLM;

ALTER SESSION SET CURRENT_SCHEMA = SYS;
