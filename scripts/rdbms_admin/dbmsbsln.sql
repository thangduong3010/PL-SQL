Rem
Rem $Header: dbmsbsln.sql 16-may-2007.12:12:29 jsoule Exp $
Rem
Rem dbmsbsln.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsbsln.sql - BaSeLiNe package (creation).
Rem
Rem    DESCRIPTION
Rem      This script defines the packaged procedures and functions required
Rem      for metric baseline support.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsoule      05/16/07 - restore backward-compatibility of deprecated API
Rem    jsoule      10/24/06 - change default num occurs
Rem    jsoule      05/02/06 - created/relocated from EMDB
Rem

create or replace
package bsln 
as
  ----------------------------------------------------------------------------
  --
  --    package subtypes
  --
  ----------------------------------------------------------------------------

  subtype guid_t             is bsln_baselines.bsln_guid%TYPE;
  subtype timegroup_field_t  is bsln_timegroups.intraday%TYPE;
  subtype timegroup_t        is bsln_statistics.timegroup%TYPE;
  subtype timegrouping_t     is bsln_statistics.timegrouping%TYPE;
  subtype fail_action_t      is bsln_threshold_params.fail_action%TYPE;
  subtype threshold_method_t is bsln_threshold_params.threshold_method%TYPE;
  subtype param_value_t      is bsln_threshold_params.critical_param%TYPE;
  subtype preferred_status_t is bsln_metric_defaults.status%TYPE;

  ----------------------------------------------------------------------------
  --
  --    externally visible constants and subtypes
  --
  ----------------------------------------------------------------------------

  K_TIMEGROUPING_FIELD_X constant varchar2(1) := 'X';
  K_TIMEGROUPING_FIELD_N constant varchar2(1) := 'N';
  K_TIMEGROUPING_FIELD_H constant varchar2(1) := 'H';
  K_TIMEGROUPING_FIELD_W constant varchar2(1) := 'W';
  K_TIMEGROUPING_FIELD_D constant varchar2(1) := 'D';

  K_TIMEGROUPING_XX constant timegrouping_t :=
    K_TIMEGROUPING_FIELD_X||K_TIMEGROUPING_FIELD_X;
  K_TIMEGROUPING_HX constant timegrouping_t :=
    K_TIMEGROUPING_FIELD_H||K_TIMEGROUPING_FIELD_X;
  K_TIMEGROUPING_XD constant timegrouping_t :=
    K_TIMEGROUPING_FIELD_X||K_TIMEGROUPING_FIELD_D;
  K_TIMEGROUPING_HD constant timegrouping_t :=
    K_TIMEGROUPING_FIELD_H||K_TIMEGROUPING_FIELD_D;
  K_TIMEGROUPING_XW constant timegrouping_t :=
    K_TIMEGROUPING_FIELD_X||K_TIMEGROUPING_FIELD_W;
  K_TIMEGROUPING_HW constant timegrouping_t :=
    K_TIMEGROUPING_FIELD_H||K_TIMEGROUPING_FIELD_W;
  K_TIMEGROUPING_NW constant timegrouping_t :=
    K_TIMEGROUPING_FIELD_N||K_TIMEGROUPING_FIELD_W;
  K_TIMEGROUPING_ND constant timegrouping_t :=
    K_TIMEGROUPING_FIELD_N||K_TIMEGROUPING_FIELD_D;
  K_TIMEGROUPING_NX constant timegrouping_t :=
    K_TIMEGROUPING_FIELD_N||K_TIMEGROUPING_FIELD_X;

  K_TIMEGROUP_FIELD_XX constant timegroup_field_t := 'XX';
  K_TIMEGROUP_FIELD_DY constant timegroup_field_t := 'DY';
  K_TIMEGROUP_FIELD_NT constant timegroup_field_t := 'NT';
  K_TIMEGROUP_FIELD_WD constant timegroup_field_t := 'WD';
  K_TIMEGROUP_FIELD_WE constant timegroup_field_t := 'WE';

  K_DEFAULT_NUM_OCCURS constant number := 2;

  K_FAIL_ACTION_UNSET    constant fail_action_t := 'UNSET';
  K_FAIL_ACTION_PRESERVE constant fail_action_t := 'PRESERVE';

  K_METHOD_SIGLVL constant threshold_method_t := 'SIGLVL';
  K_METHOD_PCTMAX constant threshold_method_t := 'PCTMAX';

  K_SIGLVL_95   constant param_value_t := 0.95;
  K_SIGLVL_99   constant param_value_t := 0.99;
  K_SIGLVL_999  constant param_value_t := 0.999;
  K_SIGLVL_9999 constant param_value_t := 0.9999;

  K_TRUE  constant integer := 1;
  K_FALSE constant integer := 0;
  K_YES   constant varchar2(1) := 'Y';
  K_NO    constant varchar2(1) := 'N';

  K_STATUS_ACTIVE   constant bsln_baselines.status%TYPE := 'ACTIVE';
  K_STATUS_INACTIVE constant bsln_baselines.status%TYPE := 'INACTIVE';

  K_STATUS_PREFERRED    constant preferred_status_t := 'PREFERRED';
  K_STATUS_NONPREFERRED constant preferred_status_t := 'NONPREFERRED';

  K_CATEGORY_PERFORMANCE constant bsln_metric_defaults.category%TYPE :=
            'PERFORMANCE';
  K_CATEGORY_DEMAND      constant bsln_metric_defaults.category%TYPE :=
            'DEMAND';
  K_CATEGORY_SHAPE       constant bsln_metric_defaults.category%TYPE :=
            'SHAPE';

  K_SCORE_MAXIMUM   constant number := 10.0;
  K_SCORE_HIGHINC   constant number := 5.0;
  K_SCORE_MEDIUMEXC constant number := 0.0;

  ----------------------------------------------------------------------------
  --
  --    package exception declarations
  --
  ----------------------------------------------------------------------------

  X_INVALID_BASELINE         constant number := -20101;
  X_INVALID_INTERVAL         constant number := -20102;
  -- X_DATASOURCE_NOT_FOUND  constant number := -20103;           -- DEPRECATED
  X_INVALID_THRESHOLD_METHOD constant number := -20104;
  X_INVALID_METRIC           constant number := -20105;
  X_BASELINE_NOT_FOUND       constant number := -20106;
  -- X_SOURCE_CONFLICT       constant number := -20107;           -- DEPRECATED
  X_NOT_SUPPORTED            constant number := -20108;
  X_BSLNTHR_ERROR            constant number := -20109;
  X_DEPRECATION_ERROR        constant number := -20110;
  X_INVALID_TIMEGROUPING     constant number := -20111;

  INVALID_BASELINE         exception;
  INVALID_INTERVAL         exception;
  -- DATASOURCE_NOT_FOUND  exception;                             -- DEPRECATED
  INVALID_THRESHOLD_METHOD exception;
  INVALID_METRIC           exception;
  BASELINE_NOT_FOUND       exception;
  -- SOURCE_CONFLICT       exception;                             -- DEPRECATED
  NOT_SUPPORTED            exception;
  BSLNTHR_ERROR            exception;
  DEPRECATION_ERROR        exception;
  INVALID_TIMEGROUPING     exception;

  PRAGMA EXCEPTION_INIT(INVALID_BASELINE, -20101);
  PRAGMA EXCEPTION_INIT(INVALID_INTERVAL, -20102);
  -- PRAGMA EXCEPTION_INIT(DATASOURCE_NOT_FOUND, -20103);         -- DEPRECATED
  PRAGMA EXCEPTION_INIT(INVALID_THRESHOLD_METHOD, -20104);
  PRAGMA EXCEPTION_INIT(INVALID_METRIC, -20105);
  PRAGMA EXCEPTION_INIT(BASELINE_NOT_FOUND, -20106);
  -- PRAGMA EXCEPTION_INIT(SOURCE_CONFLICT, -20107);              -- DEPRECATED
  PRAGMA EXCEPTION_INIT(NOT_SUPPORTED, -20108);
  PRAGMA EXCEPTION_INIT(BSLNTHR_ERROR, -20109);
  PRAGMA EXCEPTION_INIT(DEPRECATION_ERROR, -20110);
  PRAGMA EXCEPTION_INIT(INVALID_TIMEGROUPING, -20111);

  ----------------------------------------------------------------------------
  --
  --    utility routines
  --
  ----------------------------------------------------------------------------

  function target_uid(dbid_in         in number
                     ,instance_num_in in number)
  return guid_t;

  function this_target_uid
  return guid_t;

  function target_uid(dbid_in          in number
                     ,instance_name_in in varchar2)
  return guid_t
  DETERMINISTIC;

  function metric_uid(metric_id_in in number)
  return guid_t
  DETERMINISTIC;

  function datasource_guid(target_uid_in in guid_t                -- DEPRECATED
                          ,metric_uid_in in guid_t                -- DEPRECATED
                          ,key_value_in  in varchar2 := ' ')      -- DEPRECATED
  return guid_t                                                   -- DEPRECATED
  DETERMINISTIC;                                                  -- DEPRECATED

  function baseline_guid
    (baseline_id_in   in number
    ,instance_name_in in varchar2 := NULL
    ,dbid_in          in number := NULL)
  return guid_t;

  function moving_window_baseline_guid
    (instance_name_in in varchar2 := NULL
    ,dbid_in          in number := NULL)
  return guid_t;

  function timegroup(timegrouping_in in timegrouping_t
                    ,time_in         in date)
  return timegroup_t;

  function subinterval_code(subinterval_key_in in timegrouping_t  -- DEPRECATED
                           ,time_in            in date)           -- DEPRECATED
  return timegroup_t;                                             -- DEPRECATED

  function timegroup(timegrouping_in in timegrouping_t
                    ,hour_of_week_in in binary_integer)
  return timegroup_t;

  ----------------------------------------------------------------------------
  --
  --    administration routines
  --
  ----------------------------------------------------------------------------

  procedure update_moving_window                                  -- DEPRECATED
    (interval_days_in   in number                                 -- DEPRECATED
    ,subinterval_key_in in timegrouping_t                         -- DEPRECATED
    ,target_uid_in      in guid_t := NULL);                       -- DEPRECATED

  procedure create_baseline_static                                -- DEPRECATED
    (name_in            in varchar2                               -- DEPRECATED
    ,interval_begin_in  in date                                   -- DEPRECATED
    ,interval_end_in    in date                                   -- DEPRECATED
    ,subinterval_key_in in timegrouping_t                         -- DEPRECATED
    ,target_uid_in      in guid_t := NULL);                       -- DEPRECATED

  procedure drop_baseline                                         -- DEPRECATED
    (name_in       in varchar2                                    -- DEPRECATED
    ,target_uid_in in guid_t := NULL);                            -- DEPRECATED

  procedure register_datasource                                   -- DEPRECATED
    (dbid_in         in number                                    -- DEPRECATED
    ,instance_num_in in number                                    -- DEPRECATED
    ,metric_id_in    in number);                                  -- DEPRECATED

  procedure deregister_datasource                                 -- DEPRECATED
    (dbid_in         in number                                    -- DEPRECATED
    ,instance_num_in in number                                    -- DEPRECATED
    ,metric_id_in    in number);                                  -- DEPRECATED

  procedure set_default_timegrouping
    (timegrouping_in  in timegrouping_t
    ,instance_name_in in varchar2 := NULL
    ,dbid_in          in number := NULL);

  procedure activate_baseline                                     -- DEPRECATED
    (name_in       in varchar2                                    -- DEPRECATED
    ,target_uid_in in guid_t := NULL);                            -- DEPRECATED

  procedure deactivate_baseline                                   -- DEPRECATED
    (name_in       in varchar2                                    -- DEPRECATED
    ,target_uid_in in guid_t := NULL);                            -- DEPRECATED

  procedure set_threshold_parameters
    (bsln_guid_in        in guid_t
    ,metric_id_in        in number
    ,threshold_method_in in threshold_method_t
    ,warning_param_in    in param_value_t
    ,critical_param_in   in param_value_t
    ,num_occurs_in       in integer := K_DEFAULT_NUM_OCCURS
    ,fail_action_in      in fail_action_t := K_FAIL_ACTION_UNSET);

  procedure set_threshold_parameters                              -- DEPRECATED
    (bsln_guid_in        in guid_t                                -- DEPRECATED
    ,ds_guid_in          in guid_t                                -- DEPRECATED
    ,threshold_method_in in threshold_method_t                    -- DEPRECATED
    ,warning_param_in    in param_value_t                         -- DEPRECATED
    ,critical_param_in   in param_value_t                         -- DEPRECATED
    ,num_occurs_in       in integer := K_DEFAULT_NUM_OCCURS       -- DEPRECATED
    ,fail_action_in      in fail_action_t := K_FAIL_ACTION_UNSET);-- DEPRECATED

  procedure unset_threshold_parameters
    (bsln_guid_in in guid_t
    ,metric_id_in in number);

  ----------------------------------------------------------------------------
  -- enable/disable API, deprecated in 11.1
  ----------------------------------------------------------------------------
  procedure enable;                                               -- DEPRECATED
  procedure disable;                                              -- DEPRECATED
  function is_enabled return integer;                             -- DEPRECATED

  procedure delete_bsln_jobs;                                     -- DEPRECATED

  -----------------------------------------------------------------------------
  --
  --    operational routines
  --
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- automation hooks, deprecated in 11.1
  -----------------------------------------------------------------------------
  procedure set_all_thresholds;                                   -- DEPRECATED
  procedure compute_all_statistics;                               -- DEPRECATED

  -----------------------------------------------------------------------------
  -- statistics computation and quality (of extrapolation)
  -----------------------------------------------------------------------------
  function compute_statistics                                     -- DEPRECATED
    (bsln_name_in       in varchar2                               -- DEPRECATED
    ,interval_begin_in  in date                                   -- DEPRECATED
    ,interval_end_in    in date                                   -- DEPRECATED
    ,subinterval_key_in in timegrouping_t                         -- DEPRECATED
    ,target_uid_in      in guid_t := NULL)                        -- DEPRECATED
  return bsln_statistics_set;                                     -- DEPRECATED

  function data_and_model_OK
    (threshold_method_in in threshold_method_t
    ,threshold_param_in  in param_value_t
    ,sample_count_in     in number
    ,fit_quality_in      in number)
  return integer;

  ----------------------------------------------------------------------------
  -- metric quality as signal
  ----------------------------------------------------------------------------

  type signal_rectype is record
    (bsln_guid guid_t
    ,metric_id number
    ,quality   number);

  type signal_cvtype is ref cursor return signal_rectype;

  function metric_signal_qualities
    (bsln_guid_in      in guid_t
    ,metric_ids_in     in bsln_metric_set := NULL
    ,reference_time_in in date)
  return signal_cvtype;

  ----------------------------------------------------------------------------
  --
  --    SLPA declarations for Design by Contract support
  --
  ----------------------------------------------------------------------------
  ASSERTFAIL     EXCEPTION;
  ASSERTFAIL_C   CONSTANT INTEGER := -20999;
  PRAGMA EXCEPTION_INIT(ASSERTFAIL, -20999);
  PKGNAME_C      CONSTANT VARCHAR2(20) := 'BSLN';
  ----------------------------------------------------------------------------
end bsln;
/

create or replace synonym mgmt_bsln
for bsln
/

grant execute on bsln to oem_monitor
/

