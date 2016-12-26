Rem
Rem $Header: 


Rem catadrvw.sql
Rem
Rem Copyright (c) 2008, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catadrvw.sql - Catalog ADR Views
Rem
Rem    DESCRIPTION
Rem      The adr x$/v$ public views
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jklein      02/29/08 - Created
Rem
create or replace view 
	v_$diag_ADR_CONTROL as select * from x$diag_ADR_CONTROL;
create or replace public synonym 
	v$diag_ADR_CONTROL for v_$diag_ADR_CONTROL;
grant select on v_$diag_ADR_CONTROL to dba;

create or replace view 
	v_$diag_ADR_INVALIDATION as select * from x$diag_ADR_INVALIDATION;
create or replace public synonym 
	v$diag_ADR_INVALIDATION for v_$diag_ADR_INVALIDATION;
grant select on v_$diag_ADR_INVALIDATION to dba;

create or replace view 
	v_$diag_INCIDENT as select * from x$diag_INCIDENT;
create or replace public synonym 
	v$diag_INCIDENT for v_$diag_INCIDENT;
grant select on v_$diag_INCIDENT to dba;

create or replace view 
	v_$diag_PROBLEM as select * from x$diag_PROBLEM;
create or replace public synonym 
	v$diag_PROBLEM for v_$diag_PROBLEM;
grant select on v_$diag_PROBLEM to dba;

create or replace view 
	v_$diag_INCCKEY as select * from x$diag_INCCKEY;
create or replace public synonym 
	v$diag_INCCKEY for v_$diag_INCCKEY;
grant select on v_$diag_INCCKEY to dba;

create or replace view 
	v_$diag_INCIDENT_FILE as select * from x$diag_INCIDENT_FILE;
create or replace public synonym 
	v$diag_INCIDENT_FILE for v_$diag_INCIDENT_FILE;
grant select on v_$diag_INCIDENT_FILE to dba;

create or replace view 
	v_$diag_SWEEPERR as select * from x$diag_SWEEPERR;
create or replace public synonym 
	v$diag_SWEEPERR for v_$diag_SWEEPERR;
grant select on v_$diag_SWEEPERR to dba;

create or replace view 
	v_$diag_PICKLEERR as select * from x$diag_PICKLEERR;
create or replace public synonym 
	v$diag_PICKLEERR for v_$diag_PICKLEERR;
grant select on v_$diag_PICKLEERR to dba;

create or replace view 
	v_$diag_VIEW as select * from x$diag_VIEW;
create or replace public synonym 
	v$diag_VIEW for v_$diag_VIEW;
grant select on v_$diag_VIEW to dba;

create or replace view 
	v_$diag_VIEWCOL as select * from x$diag_VIEWCOL;
create or replace public synonym 
	v$diag_VIEWCOL for v_$diag_VIEWCOL;
grant select on v_$diag_VIEWCOL to dba;

create or replace view 
	v_$diag_HM_RUN as select * from x$diag_HM_RUN;
create or replace public synonym 
	v$diag_HM_RUN for v_$diag_HM_RUN;
grant select on v_$diag_HM_RUN to dba;

create or replace view 
	v_$diag_HM_FINDING as select * from x$diag_HM_FINDING;
create or replace public synonym 
	v$diag_HM_FINDING for v_$diag_HM_FINDING;
grant select on v_$diag_HM_FINDING to dba;

create or replace view 
	v_$diag_HM_RECOMMENDATION as select * from x$diag_HM_RECOMMENDATION;
create or replace public synonym 
	v$diag_HM_RECOMMENDATION for v_$diag_HM_RECOMMENDATION;
grant select on v_$diag_HM_RECOMMENDATION to dba;

create or replace view 
	v_$diag_HM_FDG_SET as select * from x$diag_HM_FDG_SET;
create or replace public synonym 
	v$diag_HM_FDG_SET for v_$diag_HM_FDG_SET;
grant select on v_$diag_HM_FDG_SET to dba;

create or replace view 
	v_$diag_HM_INFO as select * from x$diag_HM_INFO;
create or replace public synonym 
	v$diag_HM_INFO for v_$diag_HM_INFO;
grant select on v_$diag_HM_INFO to dba;

create or replace view 
	v_$diag_HM_MESSAGE as select * from x$diag_HM_MESSAGE;
create or replace public synonym 
	v$diag_HM_MESSAGE for v_$diag_HM_MESSAGE;
grant select on v_$diag_HM_MESSAGE to dba;

create or replace view 
	v_$diag_DDE_USER_ACTION_DEF as select * from x$diag_DDE_USER_ACTION_DEF;
create or replace public synonym 
	v$diag_DDE_USER_ACTION_DEF for v_$diag_DDE_USER_ACTION_DEF;
grant select on v_$diag_DDE_USER_ACTION_DEF to dba;

create or replace view 
	v_$diag_DDE_USR_ACT_PARAM_DEF as select * from x$diag_DDE_USR_ACT_PARAM_DEF;
create or replace public synonym 
	v$diag_DDE_USR_ACT_PARAM_DEF for v_$diag_DDE_USR_ACT_PARAM_DEF;
grant select on v_$diag_DDE_USR_ACT_PARAM_DEF to dba;

create or replace view 
	v_$diag_DDE_USER_ACTION as select * from x$diag_DDE_USER_ACTION;
create or replace public synonym 
	v$diag_DDE_USER_ACTION for v_$diag_DDE_USER_ACTION;
grant select on v_$diag_DDE_USER_ACTION to dba;

create or replace view 
	v_$diag_DDE_USR_ACT_PARAM as select * from x$diag_DDE_USR_ACT_PARAM;
create or replace public synonym 
	v$diag_DDE_USR_ACT_PARAM for v_$diag_DDE_USR_ACT_PARAM;
grant select on v_$diag_DDE_USR_ACT_PARAM to dba;

create or replace view 
	v_$diag_DDE_USR_INC_TYPE as select * from x$diag_DDE_USR_INC_TYPE;
create or replace public synonym 
	v$diag_DDE_USR_INC_TYPE for v_$diag_DDE_USR_INC_TYPE;
grant select on v_$diag_DDE_USR_INC_TYPE to dba;

create or replace view 
	v_$diag_DDE_USR_INC_ACT_MAP as select * from x$diag_DDE_USR_INC_ACT_MAP;
create or replace public synonym 
	v$diag_DDE_USR_INC_ACT_MAP for v_$diag_DDE_USR_INC_ACT_MAP;
grant select on v_$diag_DDE_USR_INC_ACT_MAP to dba;

create or replace view 
	v_$diag_IPS_PACKAGE as select * from x$diag_IPS_PACKAGE;
create or replace public synonym 
	v$diag_IPS_PACKAGE for v_$diag_IPS_PACKAGE;
grant select on v_$diag_IPS_PACKAGE to dba;

create or replace view 
	v_$diag_IPS_PACKAGE_INCIDENT as select * from x$diag_IPS_PACKAGE_INCIDENT;
create or replace public synonym 
	v$diag_IPS_PACKAGE_INCIDENT for v_$diag_IPS_PACKAGE_INCIDENT;
grant select on v_$diag_IPS_PACKAGE_INCIDENT to dba;

create or replace view 
	v_$diag_IPS_PACKAGE_FILE as select * from x$diag_IPS_PACKAGE_FILE;
create or replace public synonym 
	v$diag_IPS_PACKAGE_FILE for v_$diag_IPS_PACKAGE_FILE;
grant select on v_$diag_IPS_PACKAGE_FILE to dba;

create or replace view 
	v_$diag_IPS_FILE_METADATA as select * from x$diag_IPS_FILE_METADATA;
create or replace public synonym 
	v$diag_IPS_FILE_METADATA for v_$diag_IPS_FILE_METADATA;
grant select on v_$diag_IPS_FILE_METADATA to dba;

create or replace view 
	v_$diag_IPS_FILE_COPY_LOG as select * from x$diag_IPS_FILE_COPY_LOG;
create or replace public synonym 
	v$diag_IPS_FILE_COPY_LOG for v_$diag_IPS_FILE_COPY_LOG;
grant select on v_$diag_IPS_FILE_COPY_LOG to dba;

create or replace view 
	v_$diag_IPS_PACKAGE_HISTORY as select * from x$diag_IPS_PACKAGE_HISTORY;
create or replace public synonym 
	v$diag_IPS_PACKAGE_HISTORY for v_$diag_IPS_PACKAGE_HISTORY;
grant select on v_$diag_IPS_PACKAGE_HISTORY to dba;

create or replace view 
	v_$diag_IPS_PKG_UNPACK_HIST as select * from x$diag_IPS_PKG_UNPACK_HIST;
create or replace public synonym 
	v$diag_IPS_PKG_UNPACK_HIST for v_$diag_IPS_PKG_UNPACK_HIST;
grant select on v_$diag_IPS_PKG_UNPACK_HIST to dba;

create or replace view 
	v_$diag_IPS_REMOTE_PACKAGE as select * from x$diag_IPS_REMOTE_PACKAGE;
create or replace public synonym 
	v$diag_IPS_REMOTE_PACKAGE for v_$diag_IPS_REMOTE_PACKAGE;
grant select on v_$diag_IPS_REMOTE_PACKAGE to dba;

create or replace view 
	v_$diag_IPS_CONFIGURATION as select * from x$diag_IPS_CONFIGURATION;
create or replace public synonym 
	v$diag_IPS_CONFIGURATION for v_$diag_IPS_CONFIGURATION;
grant select on v_$diag_IPS_CONFIGURATION to dba;

create or replace view 
	v_$diag_IPS_PROGRESS_LOG as select * from x$diag_IPS_PROGRESS_LOG;
create or replace public synonym 
	v$diag_IPS_PROGRESS_LOG for v_$diag_IPS_PROGRESS_LOG;
grant select on v_$diag_IPS_PROGRESS_LOG to dba;

create or replace view 
	v_$diag_INC_METER_SUMMARY as select * from x$diag_INC_METER_SUMMARY;
create or replace public synonym 
	v$diag_INC_METER_SUMMARY for v_$diag_INC_METER_SUMMARY;
grant select on v_$diag_INC_METER_SUMMARY to dba;

create or replace view 
	v_$diag_INC_METER_INFO as select * from x$diag_INC_METER_INFO;
create or replace public synonym 
	v$diag_INC_METER_INFO for v_$diag_INC_METER_INFO;
grant select on v_$diag_INC_METER_INFO to dba;

create or replace view 
	v_$diag_INC_METER_CONFIG as select * from x$diag_INC_METER_CONFIG;
create or replace public synonym 
	v$diag_INC_METER_CONFIG for v_$diag_INC_METER_CONFIG;
grant select on v_$diag_INC_METER_CONFIG to dba;

create or replace view 
	v_$diag_INC_METER_IMPT_DEF as select * from x$diag_INC_METER_IMPT_DEF;
create or replace public synonym 
	v$diag_INC_METER_IMPT_DEF for v_$diag_INC_METER_IMPT_DEF;
grant select on v_$diag_INC_METER_IMPT_DEF to dba;

create or replace view 
	v_$diag_INC_METER_PK_IMPTS as select * from x$diag_INC_METER_PK_IMPTS;
create or replace public synonym 
	v$diag_INC_METER_PK_IMPTS for v_$diag_INC_METER_PK_IMPTS;
grant select on v_$diag_INC_METER_PK_IMPTS to dba;

create or replace view 
	v_$diag_DIR_EXT as select * from x$diag_DIR_EXT;
create or replace public synonym 
	v$diag_DIR_EXT for v_$diag_DIR_EXT;
grant select on v_$diag_DIR_EXT to dba;

create or replace view 
	v_$diag_ALERT_EXT as select * from x$diag_ALERT_EXT;
create or replace public synonym 
	v$diag_ALERT_EXT for v_$diag_ALERT_EXT;
grant select on v_$diag_ALERT_EXT to dba;

create or replace view 
	v_$diag_RELMD_EXT as select * from x$diag_RELMD_EXT;
create or replace public synonym 
	v$diag_RELMD_EXT for v_$diag_RELMD_EXT;
grant select on v_$diag_RELMD_EXT to dba;

create or replace view 
	v_$diag_EM_USER_ACTIVITY as select * from x$diag_EM_USER_ACTIVITY;
create or replace public synonym 
	v$diag_EM_USER_ACTIVITY for v_$diag_EM_USER_ACTIVITY;
grant select on v_$diag_EM_USER_ACTIVITY to dba;

create or replace view 
	v_$diag_EM_DIAG_JOB as select * from x$diag_EM_DIAG_JOB;
create or replace public synonym 
	v$diag_EM_DIAG_JOB for v_$diag_EM_DIAG_JOB;
grant select on v_$diag_EM_DIAG_JOB to dba;

create or replace view 
	v_$diag_EM_TARGET_INFO as select * from x$diag_EM_TARGET_INFO;
create or replace public synonym 
	v$diag_EM_TARGET_INFO for v_$diag_EM_TARGET_INFO;
grant select on v_$diag_EM_TARGET_INFO to dba;

create or replace view 
	v_$diag_AMS_XACTION as select * from x$diag_AMS_XACTION;
create or replace public synonym 
	v$diag_AMS_XACTION for v_$diag_AMS_XACTION;
grant select on v_$diag_AMS_XACTION to dba;

create or replace view 
	v_$diag_DFW_CONFIG_CAPTURE as select * from x$diag_DFW_CONFIG_CAPTURE;
create or replace public synonym 
	v$diag_DFW_CONFIG_CAPTURE for v_$diag_DFW_CONFIG_CAPTURE;
grant select on v_$diag_DFW_CONFIG_CAPTURE to dba;

create or replace view 
	v_$diag_DFW_CONFIG_ITEM as select * from x$diag_DFW_CONFIG_ITEM;
create or replace public synonym 
	v$diag_DFW_CONFIG_ITEM for v_$diag_DFW_CONFIG_ITEM;
grant select on v_$diag_DFW_CONFIG_ITEM to dba;

create or replace view 
	v_$diag_VSHOWINCB as select * from x$diag_VSHOWINCB;
create or replace public synonym 
	v$diag_VSHOWINCB for v_$diag_VSHOWINCB;
grant select on v_$diag_VSHOWINCB to dba;

create or replace view 
	v_$diag_VSHOWINCB_I as select * from x$diag_VSHOWINCB_I;
create or replace public synonym 
	v$diag_VSHOWINCB_I for v_$diag_VSHOWINCB_I;
grant select on v_$diag_VSHOWINCB_I to dba;

create or replace view 
	v_$diag_V_INCFCOUNT as select * from x$diag_V_INCFCOUNT;
create or replace public synonym 
	v$diag_V_INCFCOUNT for v_$diag_V_INCFCOUNT;
grant select on v_$diag_V_INCFCOUNT to dba;

create or replace view 
	v_$diag_V_NFCINC as select * from x$diag_V_NFCINC;
create or replace public synonym 
	v$diag_V_NFCINC for v_$diag_V_NFCINC;
grant select on v_$diag_V_NFCINC to dba;

create or replace view 
	v_$diag_VSHOWCATVIEW as select * from x$diag_VSHOWCATVIEW;
create or replace public synonym 
	v$diag_VSHOWCATVIEW for v_$diag_VSHOWCATVIEW;
grant select on v_$diag_VSHOWCATVIEW to dba;

create or replace view 
	v_$diag_VINCIDENT as select * from x$diag_VINCIDENT;
create or replace public synonym 
	v$diag_VINCIDENT for v_$diag_VINCIDENT;
grant select on v_$diag_VINCIDENT to dba;

create or replace view 
	v_$diag_VINC_METER_INFO as select * from x$diag_VINC_METER_INFO;
create or replace public synonym 
	v$diag_VINC_METER_INFO for v_$diag_VINC_METER_INFO;
grant select on v_$diag_VINC_METER_INFO to dba;

create or replace view 
	v_$diag_VIPS_FILE_METADATA as select * from x$diag_VIPS_FILE_METADATA;
create or replace public synonym 
	v$diag_VIPS_FILE_METADATA for v_$diag_VIPS_FILE_METADATA;
grant select on v_$diag_VIPS_FILE_METADATA to dba;

create or replace view 
	v_$diag_VIPS_PKG_FILE as select * from x$diag_VIPS_PKG_FILE;
create or replace public synonym 
	v$diag_VIPS_PKG_FILE for v_$diag_VIPS_PKG_FILE;
grant select on v_$diag_VIPS_PKG_FILE to dba;

create or replace view 
	v_$diag_VIPS_PACKAGE_FILE as select * from x$diag_VIPS_PACKAGE_FILE;
create or replace public synonym 
	v$diag_VIPS_PACKAGE_FILE for v_$diag_VIPS_PACKAGE_FILE;
grant select on v_$diag_VIPS_PACKAGE_FILE to dba;

create or replace view 
	v_$diag_VIPS_PACKAGE_HISTORY as select * from x$diag_VIPS_PACKAGE_HISTORY;
create or replace public synonym 
	v$diag_VIPS_PACKAGE_HISTORY for v_$diag_VIPS_PACKAGE_HISTORY;
grant select on v_$diag_VIPS_PACKAGE_HISTORY to dba;

create or replace view 
	v_$diag_VIPS_FILE_COPY_LOG as select * from x$diag_VIPS_FILE_COPY_LOG;
create or replace public synonym 
	v$diag_VIPS_FILE_COPY_LOG for v_$diag_VIPS_FILE_COPY_LOG;
grant select on v_$diag_VIPS_FILE_COPY_LOG to dba;

create or replace view 
	v_$diag_VIPS_PACKAGE_SIZE as select * from x$diag_VIPS_PACKAGE_SIZE;
create or replace public synonym 
	v$diag_VIPS_PACKAGE_SIZE for v_$diag_VIPS_PACKAGE_SIZE;
grant select on v_$diag_VIPS_PACKAGE_SIZE to dba;

create or replace view 
	v_$diag_VIPS_PKG_INC_DTL1 as select * from x$diag_VIPS_PKG_INC_DTL1;
create or replace public synonym 
	v$diag_VIPS_PKG_INC_DTL1 for v_$diag_VIPS_PKG_INC_DTL1;
grant select on v_$diag_VIPS_PKG_INC_DTL1 to dba;

create or replace view 
	v_$diag_VIPS_PKG_INC_DTL as select * from x$diag_VIPS_PKG_INC_DTL;
create or replace public synonym 
	v$diag_VIPS_PKG_INC_DTL for v_$diag_VIPS_PKG_INC_DTL;
grant select on v_$diag_VIPS_PKG_INC_DTL to dba;

create or replace view 
	v_$diag_VINCIDENT_FILE as select * from x$diag_VINCIDENT_FILE;
create or replace public synonym 
	v$diag_VINCIDENT_FILE for v_$diag_VINCIDENT_FILE;
grant select on v_$diag_VINCIDENT_FILE to dba;

create or replace view 
	v_$diag_V_INCCOUNT as select * from x$diag_V_INCCOUNT;
create or replace public synonym 
	v$diag_V_INCCOUNT for v_$diag_V_INCCOUNT;
grant select on v_$diag_V_INCCOUNT to dba;

create or replace view 
	v_$diag_V_IPSPRBCNT1 as select * from x$diag_V_IPSPRBCNT1;
create or replace public synonym 
	v$diag_V_IPSPRBCNT1 for v_$diag_V_IPSPRBCNT1;
grant select on v_$diag_V_IPSPRBCNT1 to dba;

create or replace view 
	v_$diag_V_IPSPRBCNT as select * from x$diag_V_IPSPRBCNT;
create or replace public synonym 
	v$diag_V_IPSPRBCNT for v_$diag_V_IPSPRBCNT;
grant select on v_$diag_V_IPSPRBCNT to dba;

create or replace view 
	v_$diag_VPROBLEM_LASTINC as select * from x$diag_VPROBLEM_LASTINC;
create or replace public synonym 
	v$diag_VPROBLEM_LASTINC for v_$diag_VPROBLEM_LASTINC;
grant select on v_$diag_VPROBLEM_LASTINC to dba;

create or replace view 
	v_$diag_VPROBLEM_INT as select * from x$diag_VPROBLEM_INT;
create or replace public synonym 
	v$diag_VPROBLEM_INT for v_$diag_VPROBLEM_INT;
grant select on v_$diag_VPROBLEM_INT to dba;

create or replace view 
	v_$diag_VEM_USER_ACTLOG as select * from x$diag_VEM_USER_ACTLOG;
create or replace public synonym 
	v$diag_VEM_USER_ACTLOG for v_$diag_VEM_USER_ACTLOG;
grant select on v_$diag_VEM_USER_ACTLOG to dba;

create or replace view 
	v_$diag_VEM_USER_ACTLOG1 as select * from x$diag_VEM_USER_ACTLOG1;
create or replace public synonym 
	v$diag_VEM_USER_ACTLOG1 for v_$diag_VEM_USER_ACTLOG1;
grant select on v_$diag_VEM_USER_ACTLOG1 to dba;

create or replace view 
	v_$diag_VPROBLEM1 as select * from x$diag_VPROBLEM1;
create or replace public synonym 
	v$diag_VPROBLEM1 for v_$diag_VPROBLEM1;
grant select on v_$diag_VPROBLEM1 to dba;

create or replace view 
	v_$diag_VPROBLEM2 as select * from x$diag_VPROBLEM2;
create or replace public synonym 
	v$diag_VPROBLEM2 for v_$diag_VPROBLEM2;
grant select on v_$diag_VPROBLEM2 to dba;

create or replace view 
	v_$diag_V_INC_METER_INFO_PROB as select * from x$diag_V_INC_METER_INFO_PROB;
create or replace public synonym 
	v$diag_V_INC_METER_INFO_PROB for v_$diag_V_INC_METER_INFO_PROB;
grant select on v_$diag_V_INC_METER_INFO_PROB to dba;

create or replace view 
	v_$diag_VPROBLEM as select * from x$diag_VPROBLEM;
create or replace public synonym 
	v$diag_VPROBLEM for v_$diag_VPROBLEM;
grant select on v_$diag_VPROBLEM to dba;

create or replace view 
	v_$diag_VPROBLEM_BUCKET1 as select * from x$diag_VPROBLEM_BUCKET1;
create or replace public synonym 
	v$diag_VPROBLEM_BUCKET1 for v_$diag_VPROBLEM_BUCKET1;
grant select on v_$diag_VPROBLEM_BUCKET1 to dba;

create or replace view 
	v_$diag_VPROBLEM_BUCKET as select * from x$diag_VPROBLEM_BUCKET;
create or replace public synonym 
	v$diag_VPROBLEM_BUCKET for v_$diag_VPROBLEM_BUCKET;
grant select on v_$diag_VPROBLEM_BUCKET to dba;

create or replace view 
	v_$diag_VPROBLEM_BUCKET_COUNT as select * from x$diag_VPROBLEM_BUCKET_COUNT;
create or replace public synonym 
	v$diag_VPROBLEM_BUCKET_COUNT for v_$diag_VPROBLEM_BUCKET_COUNT;
grant select on v_$diag_VPROBLEM_BUCKET_COUNT to dba;

create or replace view 
	v_$diag_VHM_RUN as select * from x$diag_VHM_RUN;
create or replace public synonym 
	v$diag_VHM_RUN for v_$diag_VHM_RUN;
grant select on v_$diag_VHM_RUN to dba;

create or replace view 
	v_$diag_DIAGV_INCIDENT as select * from x$diag_DIAGV_INCIDENT;
create or replace public synonym 
	v$diag_DIAGV_INCIDENT for v_$diag_DIAGV_INCIDENT;
grant select on v_$diag_DIAGV_INCIDENT to dba;

create or replace view 
	v_$diag_VIPS_PACKAGE_MAIN_INT as select * from x$diag_VIPS_PACKAGE_MAIN_INT;
create or replace public synonym 
	v$diag_VIPS_PACKAGE_MAIN_INT for v_$diag_VIPS_PACKAGE_MAIN_INT;
grant select on v_$diag_VIPS_PACKAGE_MAIN_INT to dba;

create or replace view 
	v_$diag_VIPS_PKG_MAIN_PROBLEM as select * from x$diag_VIPS_PKG_MAIN_PROBLEM;
create or replace public synonym 
	v$diag_VIPS_PKG_MAIN_PROBLEM for v_$diag_VIPS_PKG_MAIN_PROBLEM;
grant select on v_$diag_VIPS_PKG_MAIN_PROBLEM to dba;

create or replace view 
	v_$diag_V_ACTINC as select * from x$diag_V_ACTINC;
create or replace public synonym 
	v$diag_V_ACTINC for v_$diag_V_ACTINC;
grant select on v_$diag_V_ACTINC to dba;

create or replace view 
	v_$diag_V_ACTPROB as select * from x$diag_V_ACTPROB;
create or replace public synonym 
	v$diag_V_ACTPROB for v_$diag_V_ACTPROB;
grant select on v_$diag_V_ACTPROB to dba;

create or replace view 
	v_$diag_V_SWPERRCOUNT as select * from x$diag_V_SWPERRCOUNT;
create or replace public synonym 
	v$diag_V_SWPERRCOUNT for v_$diag_V_SWPERRCOUNT;
grant select on v_$diag_V_SWPERRCOUNT to dba;

create or replace view 
	v_$diag_VIPS_PKG_INC_CAND as select * from x$diag_VIPS_PKG_INC_CAND;
create or replace public synonym 
	v$diag_VIPS_PKG_INC_CAND for v_$diag_VIPS_PKG_INC_CAND;
grant select on v_$diag_VIPS_PKG_INC_CAND to dba;

create or replace view 
	v_$diag_VNOT_EXIST_INCIDENT as select * from x$diag_VNOT_EXIST_INCIDENT;
create or replace public synonym 
	v$diag_VNOT_EXIST_INCIDENT for v_$diag_VNOT_EXIST_INCIDENT;
grant select on v_$diag_VNOT_EXIST_INCIDENT to dba;

create or replace view 
	v_$diag_VTEST_EXISTS as select * from x$diag_VTEST_EXISTS;
create or replace public synonym 
	v$diag_VTEST_EXISTS for v_$diag_VTEST_EXISTS;
grant select on v_$diag_VTEST_EXISTS to dba;

