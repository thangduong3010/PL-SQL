Rem
Rem $Header: catbslny.sql 03-jul-2006.17:35:40 jsoule Exp $
Rem
Rem catbslny.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catbslny.sql - CATalog BaSeLiNe tYpes.
Rem
Rem    DESCRIPTION
Rem      This script defines the types to create for metric baseline support.
Rem      These are the most fundamental composite types, used in function and
Rem      procedure APIs.
Rem
Rem    NOTES
Rem      None.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsoule      05/02/06 - created
Rem

Rem
Rem  Type:
Rem    bsln_metric_set
Rem
Rem  Description:
Rem    This is a set of metrics supported by baselines.
Rem

Rem
Rem  Type:
Rem    bsln_metric_t
Rem
Rem  Description:
Rem    A metric (metadata) relation
Rem
Rem  Fields:
Rem    metric_id - metric observed
Rem    status    - status of the metric (e.g., preferred)
Rem

drop type bsln_metric_set;

create or replace type bsln_metric_t as object
  (metric_id number
  ,status    varchar2(16)
  );
/

grant execute on bsln_metric_t to oem_monitor
/

Rem
Rem  Type:
Rem    bsln_metric_set
Rem
Rem  Description:
Rem    This is a set of metrics.
Rem

create type bsln_metric_set as table of bsln_metric_t;
/

grant execute on bsln_metric_set to oem_monitor
/

Rem
Rem  Type:
Rem    bsln_variance_t
Rem
Rem  Description:
Rem    The variance measure for a metric in a baseline within a time-group of
Rem    a specific timegrouping.
Rem
Rem  Fields:
Rem    metric_id          - the metric's identifier
Rem    bsln_guid          - the baseline's globally unique ID
Rem    timegrouping       - the timegrouping used to generate this timegroup
Rem    timegroup_hours    - the number of hours (from canonical week)
Rem                         within this timegroup
Rem    timegroup_cardinality - the number of datapoints that contributed
Rem    timegroup_variance - the variance measure of the timegroup
Rem

drop type bsln_variance_set;

create or replace type bsln_variance_t as object
  (metric_id             number
  ,bsln_guid             raw(16)
  ,timegrouping          varchar2(2)
  ,timegroup_hours       number
  ,timegroup_cardinality number
  ,timegroup_variance    number
  );
/

grant execute on bsln_variance_t to oem_monitor
/

Rem
Rem  Type:
Rem    bsln_variance_set;
Rem
Rem  Description:
Rem    This is a set of baseline metric variances.
Rem

create type bsln_variance_set as table of bsln_variance_t;
/

grant execute on bsln_variance_set to oem_monitor
/

Rem
Rem  Type:
Rem    bsln_observation_t
Rem
Rem  Description:
Rem    This relation is an observation of a data source.
Rem
Rem  Fields:
Rem    metric_id - metric observed
Rem    bsln_guid - unique baseline identifier
Rem    timegroup - encoding of the subinterval of a baseline
Rem    obs_time  - time of observation
Rem    obs_value - value observed

drop type bsln_observation_set;

create or replace type bsln_observation_t as object
  (metric_id number
  ,bsln_guid raw(16)
  ,timegroup varchar2(5)
  ,obs_time  date
  ,obs_value number
  );
/

grant execute on bsln_observation_t to oem_monitor
/

Rem
Rem  Type:
Rem    bsln_observation_set
Rem
Rem  Description:
Rem    This is a set of observations of data sources.
Rem

create type bsln_observation_set as table of bsln_observation_t;
/

grant execute on bsln_observation_set to oem_monitor
/

Rem
Rem  Type:
Rem    bsln_statistics_t
Rem
Rem  Description:
Rem    An object attribute-column matched to mgmt_bsln_statistics
Rem

drop type bsln_statistics_set;

create or replace type bsln_statistics_t as object
  (bsln_guid        raw(16)
  ,metric_id        number
  ,compute_date     date
  ,timegrouping     varchar2(2)
  ,timegroup        varchar2(5)
  ,sample_count     number 
  ,average          number
  ,minimum          number
  ,maximum          number
  ,sdev             number
  ,pctile_25        number
  ,pctile_50        number
  ,pctile_75        number
  ,pctile_90        number
  ,pctile_95        number
  ,pctile_99        number
  ,est_sample_count number
  ,est_slope        number
  ,est_intercept    number
  ,est_fit_quality  number
  ,est_pctile_999   number
  ,est_pctile_9999  number
  );
/

grant execute on bsln_statistics_t to oem_monitor
/

Rem
Rem  Type:
Rem    bsln_statistics_set
Rem
Rem  Description:
Rem    A set of statistics objects
Rem

create type bsln_statistics_set as table of bsln_statistics_t;
/

grant execute on bsln_statistics_set to oem_monitor
/
