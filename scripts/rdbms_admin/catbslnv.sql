Rem
Rem $Header: catbslnv.sql 27-jun-2006.12:57:13 jsoule Exp $
Rem
Rem catbslnv.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catbslnv.sql - CATalog BaSeLiNe Views.
Rem
Rem    DESCRIPTION
Rem      This script defines the views to create for metric baseline support.
Rem      These views are the 10.2 and 11.1 APIs to stored data.
Rem
Rem    NOTES
Rem      There are two views for each table exposed.  The 10.2 views are not
Rem      deprecated and only used for 10.2 clients.  The 11.1 views are the
Rem      forward-looking API that will remain in 11.2, for example.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsoule      06/27/06 - react to dba_hist_baseline reversion 
Rem    jsoule      05/02/06 - created
Rem

Rem
Rem mgmt_bsln_metrics
Rem

create or replace view mgmt_bsln_metrics
  (metric_uid
  ,tail_estimator
  ,threshold_method_default
  ,num_occurrences_default
  ,warning_param_default
  ,critical_param_default
  )
as
select bsln.metric_uid(bmd.metric_id)
      ,'EXPTAIL'
      ,'SIGLVL'
      ,1
      ,.999
      ,.9999
  from bsln_metric_defaults bmd
 where bmd.status = 'PREFERRED'
/
comment on table mgmt_bsln_metrics is
'Metrics Eligible for Baselines (10.2)'
/
grant select on mgmt_bsln_metrics to oem_monitor
/

Rem
Rem mgmt_bsln_datasources
Rem

create or replace view mgmt_bsln_datasources
  (datasource_guid
  ,source_type
  ,target_uid
  ,metric_uid
  ,target_guid
  ,metric_guid
  ,key_value
  ,dbid
  ,instance_num
  ,instance_name
  ,metric_id
  )
as
select bsln.datasource_guid(bsln.target_uid(d.dbid, i.instance_number),
                            bsln.metric_uid(bmd.metric_id))
      ,'DB'
      ,bsln.target_uid(d.dbid, i.instance_number)
      ,bsln.metric_uid(bmd.metric_id)
      ,null
      ,null
      ,null
      ,d.dbid
      ,i.instance_number
      ,i.instance_name
      ,bmd.metric_id
  from gv$database d, gv$instance i, bsln_metric_defaults bmd
/
comment on table mgmt_bsln_datasources is
'Registered Metric Baseline Datasources (10.2)'
/
grant select on mgmt_bsln_datasources to oem_monitor
/

Rem
Rem mgmt_bsln_baselines
Rem

create or replace view mgmt_bsln_baselines
  (bsln_guid
  ,target_uid
  ,name
  ,type
  ,subinterval_key
  ,status
  )
as
select bb.bsln_guid
      ,bsln.target_uid(bb.dbid, i.instance_number)
      ,ab.baseline_name
      ,DECODE(ab.baseline_type,
              'MOVING_WINDOW', 'R',
                               'S')
      ,bb.timegrouping
      ,bb.status
  from bsln_baselines bb, dba_hist_baseline_metadata ab, gv$instance i
 where ab.dbid = bb.dbid
   and ab.baseline_id = bb.baseline_id
   and bb.instance_name = i.instance_name
   and ab.baseline_type in ('MOVING_WINDOW', 'STATIC', 'GENERATED')
/
comment on table mgmt_bsln_baselines is
'Database Metric Baselines (10.2)'
/
grant select on mgmt_bsln_baselines to oem_monitor
/

Rem
Rem mgmt_bsln_intervals
Rem

create or replace view mgmt_bsln_intervals
  (bsln_guid
  ,interval_begin
  ,interval_end
  ,interval_days
  )
as
select bb.bsln_guid
      ,case ab.baseline_type when 'MOVING_WINDOW' then NULL
                             else ab.start_snap_time end
      ,case ab.baseline_type when 'MOVING_WINDOW' then NULL
                             else ab.end_snap_time end
      ,case ab.baseline_type when 'MOVING_WINDOW' then ab.moving_window_size
                             else NULL end
  from bsln_baselines bb, dba_hist_baseline ab, gv$instance i
 where ab.dbid = bb.dbid
   and ab.baseline_id = bb.baseline_id
   and i.instance_name = bb.instance_name
   and ab.baseline_type in ('MOVING_WINDOW', 'STATIC', 'GENERATED')
/
comment on table mgmt_bsln_intervals is
'Database Metric Baseline Intervals (10.2)'
/
grant select on mgmt_bsln_intervals to oem_monitor
/

Rem
Rem mgmt_bsln_threshold_parms
Rem

create or replace view mgmt_bsln_threshold_parms
  (bsln_guid
  ,datasource_guid
  ,threshold_method
  ,num_occurrences
  ,warning_param
  ,critical_param
  ,fail_action
  )
as
select btp.bsln_guid
      ,bsln.datasource_guid(bsln.target_uid(bb.dbid, i.instance_number),
                            bsln.metric_uid(btp.metric_id))
      ,btp.threshold_method
      ,btp.num_occurrences
      ,btp.warning_param
      ,btp.critical_param
      ,btp.fail_action
  from bsln_threshold_params btp, bsln_baselines bb, gv$instance i
 where btp.bsln_guid = bb.bsln_guid
   and bb.instance_name = i.instance_name
/
comment on table mgmt_bsln_threshold_parms is
'Database Metric Baseline Thresholds (10.2)'
/
grant select on mgmt_bsln_threshold_parms to oem_monitor
/

Rem
Rem mgmt_bsln_statistics
Rem

create or replace view mgmt_bsln_statistics
  (bsln_guid
  ,datasource_guid
  ,compute_date
  ,subinterval_code
  ,sample_count
  ,average
  ,minimum
  ,maximum
  ,sdev
  ,pctile_25
  ,pctile_50
  ,pctile_75
  ,pctile_90
  ,pctile_95
  ,est_sample_count
  ,est_slope
  ,est_intercept
  ,est_fit_quality
  ,est_pctile_99
  ,est_pctile_999
  ,est_pctile_9999
  )
as
select bs.bsln_guid
      ,bsln.datasource_guid(bsln.target_uid(bb.dbid, i.instance_number),
                            bsln.metric_uid(bs.metric_id))
      ,bs.compute_date
      ,bs.timegroup
      ,bs.sample_count
      ,bs.average
      ,bs.minimum
      ,bs.maximum
      ,bs.sdev
      ,bs.pctile_25
      ,bs.pctile_50
      ,bs.pctile_75
      ,bs.pctile_90
      ,bs.pctile_95
      ,bs.est_sample_count
      ,bs.est_slope
      ,bs.est_intercept
      ,bs.est_fit_quality
      ,bs.pctile_99
      ,bs.est_pctile_999
      ,bs.est_pctile_9999
  from bsln_statistics bs, bsln_baselines bb, gv$instance i
 where bs.bsln_guid = bb.bsln_guid
   and bb.instance_name = i.instance_name
   and bs.timegrouping = bb.timegrouping
/
comment on table mgmt_bsln_statistics is
'Database Metric Baseline Statistics (10.2)'
/
grant select on mgmt_bsln_statistics to oem_monitor
/


