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
drop view v_$diag_ADR_CONTROL;
drop public synonym v$diag_ADR_CONTROL;

drop view v_$diag_ADR_INVALIDATION;
drop public synonym v$diag_ADR_INVALIDATION;

drop view v_$diag_INCIDENT;
drop public synonym v$diag_INCIDENT;

drop view v_$diag_PROBLEM;
drop public synonym v$diag_PROBLEM;

drop view v_$diag_INCCKEY;
drop public synonym v$diag_INCCKEY;

drop view v_$diag_INCIDENT_FILE;
drop public synonym v$diag_INCIDENT_FILE;

drop view v_$diag_SWEEPERR;
drop public synonym v$diag_SWEEPERR;

drop view v_$diag_PICKLEERR;
drop public synonym v$diag_PICKLEERR;

drop view v_$diag_VIEW;
drop public synonym v$diag_VIEW;

drop view v_$diag_VIEWCOL;
drop public synonym v$diag_VIEWCOL;

drop view v_$diag_HM_RUN;
drop public synonym v$diag_HM_RUN;

drop view v_$diag_HM_FINDING;
drop public synonym v$diag_HM_FINDING;

drop view v_$diag_HM_RECOMMENDATION;
drop public synonym v$diag_HM_RECOMMENDATION;

drop view v_$diag_HM_FDG_SET;
drop public synonym v$diag_HM_FDG_SET;

drop view v_$diag_HM_INFO;
drop public synonym v$diag_HM_INFO;

drop view v_$diag_HM_MESSAGE;
drop public synonym v$diag_HM_MESSAGE;

drop view v_$diag_DDE_USER_ACTION_DEF;
drop public synonym v$diag_DDE_USER_ACTION_DEF;

drop view v_$diag_DDE_USR_ACT_PARAM_DEF;
drop public synonym v$diag_DDE_USR_ACT_PARAM_DEF;

drop view v_$diag_DDE_USER_ACTION;
drop public synonym v$diag_DDE_USER_ACTION;

drop view v_$diag_DDE_USR_ACT_PARAM;
drop public synonym v$diag_DDE_USR_ACT_PARAM;

drop view v_$diag_DDE_USR_INC_TYPE;
drop public synonym v$diag_DDE_USR_INC_TYPE;

drop view v_$diag_DDE_USR_INC_ACT_MAP;
drop public synonym v$diag_DDE_USR_INC_ACT_MAP;

drop view v_$diag_IPS_PACKAGE;
drop public synonym v$diag_IPS_PACKAGE;

drop view v_$diag_IPS_PACKAGE_INCIDENT;
drop public synonym v$diag_IPS_PACKAGE_INCIDENT;

drop view v_$diag_IPS_PACKAGE_FILE;
drop public synonym v$diag_IPS_PACKAGE_FILE;

drop view v_$diag_IPS_FILE_METADATA;
drop public synonym v$diag_IPS_FILE_METADATA;

drop view v_$diag_IPS_FILE_COPY_LOG;
drop public synonym v$diag_IPS_FILE_COPY_LOG;

drop view v_$diag_IPS_PACKAGE_HISTORY;
drop public synonym v$diag_IPS_PACKAGE_HISTORY;

drop view v_$diag_IPS_PKG_UNPACK_HIST;
drop public synonym v$diag_IPS_PKG_UNPACK_HIST;

drop view v_$diag_IPS_REMOTE_PACKAGE;
drop public synonym v$diag_IPS_REMOTE_PACKAGE;

drop view v_$diag_IPS_CONFIGURATION;
drop public synonym v$diag_IPS_CONFIGURATION;

drop view v_$diag_IPS_PROGRESS_LOG;
drop public synonym v$diag_IPS_PROGRESS_LOG;

drop view v_$diag_INC_METER_SUMMARY;
drop public synonym v$diag_INC_METER_SUMMARY;

drop view v_$diag_INC_METER_INFO;
drop public synonym v$diag_INC_METER_INFO;

drop view v_$diag_INC_METER_CONFIG;
drop public synonym v$diag_INC_METER_CONFIG;

drop view v_$diag_INC_METER_IMPT_DEF;
drop public synonym v$diag_INC_METER_IMPT_DEF;

drop view v_$diag_INC_METER_PK_IMPTS;
drop public synonym v$diag_INC_METER_PK_IMPTS;

drop view v_$diag_DIR_EXT;
drop public synonym v$diag_DIR_EXT;

drop view v_$diag_ALERT_EXT;
drop public synonym v$diag_ALERT_EXT;

drop view v_$diag_RELMD_EXT;
drop public synonym v$diag_RELMD_EXT;

drop view v_$diag_EM_USER_ACTIVITY;
drop public synonym v$diag_EM_USER_ACTIVITY;

drop view v_$diag_EM_DIAG_JOB;
drop public synonym v$diag_EM_DIAG_JOB;

drop view v_$diag_EM_TARGET_INFO;
drop public synonym v$diag_EM_TARGET_INFO;

drop view v_$diag_AMS_XACTION;
drop public synonym v$diag_AMS_XACTION;

drop view v_$diag_DFW_CONFIG_CAPTURE;
drop public synonym v$diag_DFW_CONFIG_CAPTURE;

drop view v_$diag_DFW_CONFIG_ITEM;
drop public synonym v$diag_DFW_CONFIG_ITEM;

drop view v_$diag_VSHOWINCB;
drop public synonym v$diag_VSHOWINCB;

drop view v_$diag_VSHOWINCB_I;
drop public synonym v$diag_VSHOWINCB_I;

drop view v_$diag_V_INCFCOUNT;
drop public synonym v$diag_V_INCFCOUNT;

drop view v_$diag_V_NFCINC;
drop public synonym v$diag_V_NFCINC;

drop view v_$diag_VSHOWCATVIEW;
drop public synonym v$diag_VSHOWCATVIEW;

drop view v_$diag_VINCIDENT;
drop public synonym v$diag_VINCIDENT;

drop view v_$diag_VINC_METER_INFO;
drop public synonym v$diag_VINC_METER_INFO;

drop view v_$diag_VIPS_FILE_METADATA;
drop public synonym v$diag_VIPS_FILE_METADATA;

drop view v_$diag_VIPS_PKG_FILE;
drop public synonym v$diag_VIPS_PKG_FILE;

drop view v_$diag_VIPS_PACKAGE_FILE;
drop public synonym v$diag_VIPS_PACKAGE_FILE;

drop view v_$diag_VIPS_PACKAGE_HISTORY;
drop public synonym v$diag_VIPS_PACKAGE_HISTORY;

drop view v_$diag_VIPS_FILE_COPY_LOG;
drop public synonym v$diag_VIPS_FILE_COPY_LOG;

drop view v_$diag_VIPS_PACKAGE_SIZE;
drop public synonym v$diag_VIPS_PACKAGE_SIZE;

drop view v_$diag_VIPS_PKG_INC_DTL1;
drop public synonym v$diag_VIPS_PKG_INC_DTL1;

drop view v_$diag_VIPS_PKG_INC_DTL;
drop public synonym v$diag_VIPS_PKG_INC_DTL;

drop view v_$diag_VINCIDENT_FILE;
drop public synonym v$diag_VINCIDENT_FILE;

drop view v_$diag_V_INCCOUNT;
drop public synonym v$diag_V_INCCOUNT;

drop view v_$diag_V_IPSPRBCNT1;
drop public synonym v$diag_V_IPSPRBCNT1;

drop view v_$diag_V_IPSPRBCNT;
drop public synonym v$diag_V_IPSPRBCNT;

drop view v_$diag_VPROBLEM_LASTINC;
drop public synonym v$diag_VPROBLEM_LASTINC;

drop view v_$diag_VPROBLEM_INT;
drop public synonym v$diag_VPROBLEM_INT;

drop view v_$diag_VEM_USER_ACTLOG;
drop public synonym v$diag_VEM_USER_ACTLOG;

drop view v_$diag_VEM_USER_ACTLOG1;
drop public synonym v$diag_VEM_USER_ACTLOG1;

drop view v_$diag_VPROBLEM1;
drop public synonym v$diag_VPROBLEM1;

drop view v_$diag_VPROBLEM2;
drop public synonym v$diag_VPROBLEM2;

drop view v_$diag_V_INC_METER_INFO_PROB;
drop public synonym v$diag_V_INC_METER_INFO_PROB;

drop view v_$diag_VPROBLEM;
drop public synonym v$diag_VPROBLEM;

drop view v_$diag_VPROBLEM_BUCKET1;
drop public synonym v$diag_VPROBLEM_BUCKET1;

drop view v_$diag_VPROBLEM_BUCKET;
drop public synonym v$diag_VPROBLEM_BUCKET;

drop view v_$diag_VPROBLEM_BUCKET_COUNT;
drop public synonym v$diag_VPROBLEM_BUCKET_COUNT;

drop view v_$diag_VHM_RUN;
drop public synonym v$diag_VHM_RUN;

drop view v_$diag_DIAGV_INCIDENT;
drop public synonym v$diag_DIAGV_INCIDENT;

drop view v_$diag_VIPS_PACKAGE_MAIN_INT;
drop public synonym v$diag_VIPS_PACKAGE_MAIN_INT;

drop view v_$diag_VIPS_PKG_MAIN_PROBLEM;
drop public synonym v$diag_VIPS_PKG_MAIN_PROBLEM;

drop view v_$diag_V_ACTINC;
drop public synonym v$diag_V_ACTINC;

drop view v_$diag_V_ACTPROB;
drop public synonym v$diag_V_ACTPROB;

drop view v_$diag_V_SWPERRCOUNT;
drop public synonym v$diag_V_SWPERRCOUNT;

drop view v_$diag_VIPS_PKG_INC_CAND;
drop public synonym v$diag_VIPS_PKG_INC_CAND;

drop view v_$diag_VNOT_EXIST_INCIDENT;
drop public synonym v$diag_VNOT_EXIST_INCIDENT;

drop view v_$diag_VTEST_EXISTS;
drop public synonym v$diag_VTEST_EXISTS;

