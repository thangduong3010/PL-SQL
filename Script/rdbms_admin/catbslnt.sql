Rem
Rem $Header: catbslnt.sql 03-jul-2006.15:46:48 jsoule Exp $
Rem
Rem catbslnt.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catbslnt.sql - CATalog BaSeLiNe Tables.
Rem
Rem    DESCRIPTION
Rem      This script defines the tables to create for metric baseline support.
Rem      These tables are not the published API to stored data.  For the ex-
Rem      ternal interface, see bsln_views.sql.
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsoule      06/15/06 - restore compute_date on baselines
Rem    jsoule      05/02/06 - created
Rem



Rem
Rem  Table:
Rem    bsln_metric_defaults
Rem
Rem  Description:
Rem    This table lists the set of 'eligible' metrics for baselining.  Metrics
Rem    absent from this list cannot contribute to baselines.  Default, or
Rem    suggested, parameter settings for eligible metrics are found here as
Rem    well.
Rem
Rem  Columns:
Rem    metric_id - database metric identifier
Rem    status    - whether this metric is preferred or not
Rem    category  - the category of change this metric indicates
Rem
    
create table bsln_metric_defaults
   (metric_id number       NOT NULL
   ,status    varchar2(16) NOT NULL
   ,category  varchar2(16) NOT NULL
   ,CONSTRAINT bsln_metric_defaults_pk PRIMARY KEY (metric_id)
   )
/
comment on table bsln_metric_defaults is
'Default Attributes of Baselineable Metrics'
/
grant select on bsln_metric_defaults to oem_monitor
/


Rem
Rem  Table:
Rem    bsln_timegroups
Rem
Rem  Description:
Rem    This table defines the day/night and weekday/weekend boundaries
Rem    for timegroups.
Rem
Rem  Columns:
Rem    hour     - the hour of the week (0-167)
Rem    intraday - the value of this hour within the day/night
Rem    extraday - the value of this hour within the weekday/weekend
Rem
    
create table bsln_timegroups
   (hour     number      NOT NULL
   ,intraday varchar2(2) NOT NULL
   ,extraday varchar2(2) NOT NULL
   ,CONSTRAINT bsln_timegroups_pk PRIMARY KEY (hour)
   )
   ORGANIZATION INDEX
/
comment on table bsln_timegroups is
'Weekday/Weeknight and Day/Night Timegroup Definitions'
/
grant select on bsln_timegroups to oem_monitor
/

Rem
Rem  Table:
Rem    bsln_baselines
Rem
Rem  Description:
Rem    This table records the set of existing baselines.
Rem
Rem  Columns:
Rem    dbid          - database identifier
Rem    instance_name - instance name
Rem    baseline_id   - baseline identifier
Rem    bsln_guid     - globally unique baseline identifier
Rem    timegrouping  - key identifying the timegrouping scheme
Rem    status        - current status (active vs. inactive)
Rem

create table bsln_baselines
   (dbid              number       NOT NULL
   ,instance_name     varchar2(16) NOT NULL
   ,baseline_id       number       NOT NULL
   ,bsln_guid         raw(16)      NOT NULL
   ,timegrouping      varchar2(2)
   ,auto_timegroup    varchar2(1)  NOT NULL
   ,status            varchar2(16) NOT NULL
   ,last_compute_date date
   ,CONSTRAINT bsln_baselines_pk2 PRIMARY KEY (bsln_guid)
   ,CONSTRAINT bsln_baselines_uk2 UNIQUE (dbid, instance_name, baseline_id)
   )
/
comment on table bsln_baselines is
'Baselines Designated for Metric Statistics Calculation'
/
grant select on bsln_baselines to oem_monitor
/


Rem
Rem  Table:
Rem    bsln_statistics
Rem
Rem  Description:
Rem    This table records daily statistical aggregates over subintervals of a
Rem    baselined datasource.
Rem
Rem  Columns:
Rem    bsln_guid        - globally unique identifier for the baseline
Rem    metric_id        - unique identifier for the metric
Rem    compute_date     - day for which statistics were computed
Rem    timegrouping     - the way the baseline is subdivided into intervals
Rem    timegroup        - encoding of the subinterval of a baseline
Rem    sample_count     - number of data points in the baseline's subinterval
Rem    average          - average                  ||
Rem    minimum          - minimum                  ||
Rem    maximum          - maximum                  ||
Rem    sdev             - standard deviation       ||
Rem    pctile_25        - value at 25th percentile ||
Rem    pctile_50        - value at 50th percentile ||
Rem    pctile_75        - value at 75th percentile ||
Rem    pctile_90        - value at 90th percentile ||
Rem    pctile_95        - value at 95th percentile ||
Rem    est_sample_count - number of data points in the tail of the baseline's
Rem                       subinterval (used by the estimator)
Rem    est_slope        - slope of the linear regression of the tail       ||
Rem    est_intercept    - y-intercept of the linear regression of the tail ||
Rem    est_fit_quality  - fit quality of the linear function to the tail   ||
Rem    est_pctile_99    - estimated value at 99th percentile
Rem    est_pctile_999   - estimated value at 99.9th percentile
Rem    est_pctile_9999  - estimated value at 99.99th percentile
Rem

create table bsln_statistics
   (bsln_guid         raw(16)     NOT NULL
   ,metric_id         number      NOT NULL
   ,compute_date      date        NOT NULL
   ,timegrouping      varchar2(2) NOT NULL
   ,timegroup         varchar2(5) NOT NULL
   ,sample_count      number      NOT NULL
   ,average           number
   ,minimum           number
   ,maximum           number
   ,sdev              number
   ,pctile_25         number
   ,pctile_50         number
   ,pctile_75         number
   ,pctile_90         number
   ,pctile_95         number
   ,pctile_99         number
   ,est_sample_count  number
   ,est_slope         number
   ,est_intercept     number
   ,est_fit_quality   number
   ,est_pctile_999    number
   ,est_pctile_9999   number
   ,CONSTRAINT bsln_statistics_pk1 PRIMARY KEY 
         (metric_id, compute_date, timegroup, bsln_guid)
   ,CONSTRAINT bsln_statistics_fk FOREIGN KEY (bsln_guid)
         REFERENCES bsln_baselines (bsln_guid)
         ON DELETE CASCADE
   )
/
comment on table bsln_statistics is
'Metric Statistics for Baselines'
/
grant select on bsln_statistics to oem_monitor
/


Rem
Rem  Table:
Rem    bsln_threshold_params
Rem
Rem  Description:
Rem    This table keeps the current threshold parameter settings for dynamic
Rem    thresholds.
Rem
Rem  Columns:
Rem    bsln_guid        - globally unique identifier for the baseline
Rem    metric_id        - database metric identifier
Rem    threshold_method - method used to generate thresholds
Rem    num_occurrences  - number of occurrences
Rem    warning_param    - warning parameter
Rem    critical_param   - critical parameter
Rem    fail_action      - set threshold action for inadequate data or fit
Rem    adaptive         - is this threshold parameter adaptive (Y or N)
Rem    last_set_date    - time thresholds were last set under these conditions
Rem    in_effect        - are these thresholds in effect currently (Y or N)
Rem

create table bsln_threshold_params
   (bsln_guid        raw(16)      NOT NULL
   ,metric_id        number       NOT NULL
   ,threshold_method varchar2(16) NOT NULL
   ,num_occurrences  number       NOT NULL
   ,warning_param    number 
   ,critical_param   number
   ,fail_action      varchar2(16)
   ,adaptive         varchar2(1)  NOT NULL
   ,last_set_date    date
   ,in_effect        varchar2(1)  NOT NULL
   ,CONSTRAINT bsln_thresholds_pk1 PRIMARY KEY (bsln_guid, metric_id)
   ,CONSTRAINT bsln_thresholds_fk FOREIGN KEY (bsln_guid)
         REFERENCES bsln_baselines (bsln_guid)
         ON DELETE CASCADE
   )
/
comment on table bsln_threshold_params is
'Baseline Metric Threshold Parameters'
/
grant select on bsln_threshold_params to oem_monitor
/

