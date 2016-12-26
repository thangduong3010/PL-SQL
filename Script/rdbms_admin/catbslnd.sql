Rem
Rem $Header: catbslnd.sql 17-oct-2006.10:31:12 jsoule Exp $
Rem
Rem catbslnd.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catbslnd.sql - BaSeLiNe Dml for database
Rem
Rem    DESCRIPTION
Rem      Seeds metadata tables for Oracle 11g deployments
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsoule      10/17/06 - add new preferred metrics
Rem    jsoule      08/02/06 - protect against primary key violations
Rem    jsoule      05/02/06 - created
Rem

Rem
Rem  Seed bsln_metric_defaults
Rem

declare

  procedure add_metric_defaults(metric_id_in in number
                               ,status_in    in varchar2
                               ,category_in  in varchar2)
  is
  begin
    insert into bsln_metric_defaults
      (metric_id,   status,   category)
    values
      (metric_id_in,status_in,category_in);
  exception when DUP_VAL_ON_INDEX then
    null;
  end;

begin

  add_metric_defaults(2106,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_PERFORMANCE);
  add_metric_defaults(2109,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_PERFORMANCE);
  add_metric_defaults(2147,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_PERFORMANCE);
  add_metric_defaults(2144,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_PERFORMANCE);
  add_metric_defaults(2005,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2017,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2031,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2045,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2066,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2072,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2145,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2003,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2026,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2004,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2006,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2016,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2018,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2058,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2121,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2146,bsln.K_STATUS_PREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2032,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_PERFORMANCE);
  add_metric_defaults(2036,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_PERFORMANCE);
  add_metric_defaults(2052,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_PERFORMANCE);
  add_metric_defaults(2098,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_PERFORMANCE);
  add_metric_defaults(2099,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_PERFORMANCE);
  add_metric_defaults(2103,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2104,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2030,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2022,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2046,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2028,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2044,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2038,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2024,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_DEMAND);
  add_metric_defaults(2076,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2025,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2019,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2087,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2088,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2089,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2091,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2007,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2029,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2035,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2053,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2037,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2039,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2023,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);
  add_metric_defaults(2027,bsln.K_STATUS_NONPREFERRED,bsln.K_CATEGORY_SHAPE);

  commit;

end;
/

Rem
Rem  Seed bsln_timegroups
Rem
Rem  Notes:
Rem    Hours (of the week) begin on Monday morning, 12AM.
Rem    Daytime hours are from 7am to 7pm.
Rem    Weekend days are Saturday and Sunday.
Rem

begin

  for h in 0..167
  loop
    begin
      insert into bsln_timegroups
       (hour
       ,intraday
       ,extraday
       )
      values
       (h
       ,case when mod(h, 24) < 7 or mod(h, 24) > 18
             then bsln.K_TIMEGROUP_FIELD_NT
             else bsln.K_TIMEGROUP_FIELD_DY end
       ,case when h < 2*24
             then bsln.K_TIMEGROUP_FIELD_WE
             else bsln.K_TIMEGROUP_FIELD_WD end
       );
    exception 
      -------------------------------
      -- ignore duplicates
      -------------------------------
      when DUP_VAL_ON_INDEX
      then null;
    end;
  end loop;

  commit;

end;
/

