Rem
Rem $Header: rdbms/admin/catredact.sql /st_rdbms_11.2.0/3 2013/06/26 08:28:58 pknaggs Exp $
Rem
Rem catredact.sql
Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catredact.sql - catalog views for Data Redaction policies
Rem
Rem    DESCRIPTION
Rem      This file defines catalog views for the Data Redaction policies.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pknaggs     06/21/13 - Backport pknaggs_bug-16993230 from main
Rem    pknaggs     06/20/13 - Bug# 16993230: intcol# in REDACTION_COLUMNS.
Rem    cslink      07/25/12 - Bug #14285251: LOB redaction defaults
Rem    cslink      06/07/12 - Bug #14151458: Add view for radm_fptm$
Rem    cslink      05/30/12 - Bug #14133343: Update views to include desc
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    pknaggs     10/07/11 - Add Regular Expression support.
Rem    cslink      09/14/11 - Fix comments
Rem    cslink      09/14/11 - Change parameters to function_parameters
Rem    cslink      09/13/11 - Change names in catalog views from radm to redact
Rem    cslink      09/13/11 - Created
Rem

Rem Note: (+) is shorthand for left outer join which is necessary since
Rem the rows in radm_td$ and radm_cd$ might not exist

create or replace view REDACTION_POLICIES
  (OBJECT_OWNER
  ,OBJECT_NAME
  ,POLICY_NAME
  ,EXPRESSION
  ,ENABLE
  ,POLICY_DESCRIPTION ) as
select u.name                               object_owner,
       o.name                               object_name,
       r.pname                              policy_name,
       r.pexpr                              policy_expression,
       DECODE(r.enable_flag, 0, 'NO     ',
                                'YES    ')  enable,
       d.pdesc                              policy_description
from   radm$    r,
       obj$     o,
       user$    u,
       radm_td$ d
where  r.obj#   = o.obj#
   and o.owner# = u.user#
   and r.obj#   = d.obj#(+) 
   and r.pname  = d.pname(+)
  ;
/
create or replace public synonym REDACTION_POLICIES for REDACTION_POLICIES;
/
grant SELECT on REDACTION_POLICIES to SELECT_CATALOG_ROLE;
/
comment on table REDACTION_POLICIES is
'All Redaction Policies in the database'
/
comment on column REDACTION_POLICIES.OBJECT_OWNER is
'Owner of the table, or view'
/
comment on column REDACTION_POLICIES.OBJECT_NAME is
'Name of the table, or view'
/
comment on column REDACTION_POLICIES.POLICY_NAME is
'Name of the policy'
/
comment on column REDACTION_POLICIES.EXPRESSION is
'Expression defined for this policy'
/
comment on column REDACTION_POLICIES.ENABLE is
'If YES, redaction policy is enforced on this object'
/
comment on column REDACTION_POLICIES.POLICY_DESCRIPTION is
'Description of this policy'
/

create or replace view REDACTION_COLUMNS
  (OBJECT_OWNER
  ,OBJECT_NAME
  ,COLUMN_NAME
  ,FUNCTION_TYPE
  ,FUNCTION_PARAMETERS
  ,REGEXP_PATTERN
  ,REGEXP_REPLACE_STRING
  ,REGEXP_POSITION
  ,REGEXP_OCCURRENCE
  ,REGEXP_MATCH_PARAMETER
  ,COLUMN_DESCRIPTION) as
select u.name                                           object_owner,
       o.name                                           object_name,
       c.name                                           column_name,
       DECODE(rc.MFUNC, 0, 'NO REDACTION',
                        1, 'FULL REDACTION',
                        2, 'PARTIAL REDACTION',
                        3, 'FORMAT PRESERVING REDACTION',
                        4, 'RANDOM REDACTION',
                        5, 'REGEXP REDACTION',
                           'UNSUPPORTED REDACTION')     function_type,
       rc.mparams                                       function_parameters,
       rc.regexp_pattern                                regexp_pattern,
       rc.regexp_replace_string                         regexp_replace_string,
       rc.regexp_position                               regexp_position,
       rc.regexp_occurrence                             regexp_occurrence,
       rc.regexp_match_parameter                        regexp_match_parameter,
       rd.cdesc                                         column_description
  from radm$    r,
       radm_mc$ rc,
       radm_cd$ rd,
       obj$     o,
       user$    u,
       col$     c
 where r.obj#     = o.obj#
   and o.owner#   = u.user#
   and rc.intcol# = c.intcol#
   and rc.obj#    = r.obj#
   and c.obj#     = o.obj#
   and rc.obj#    = rd.obj#(+)
   and rc.intcol# = rd.intcol#(+)
/
create or replace public synonym REDACTION_COLUMNS for REDACTION_COLUMNS;
/
grant SELECT on REDACTION_COLUMNS to SELECT_CATALOG_ROLE;
/
comment on table REDACTION_COLUMNS is
'All Redacted Columns in the database'
/
comment on column REDACTION_COLUMNS.OBJECT_OWNER is
'Owner of the table, or view'
/
comment on column REDACTION_COLUMNS.OBJECT_NAME is
'Name of the table, or view'
/
comment on column REDACTION_COLUMNS.COLUMN_NAME is
'Name of the column'
/
comment on column REDACTION_COLUMNS.FUNCTION_TYPE is
'Redaction function type defined for this column'
/
comment on column REDACTION_COLUMNS.FUNCTION_PARAMETERS is
'Redaction function parameters defined for this column'
/
comment on column REDACTION_COLUMNS.REGEXP_PATTERN is
'Parameter for any Regular Expression based Redaction defined for this column'
/
comment on column REDACTION_COLUMNS.REGEXP_REPLACE_STRING is
'Parameter for any Regular Expression based Redaction defined for this column'
/
comment on column REDACTION_COLUMNS.REGEXP_POSITION is
'Parameter for any Regular Expression based Redaction defined for this column'
/
comment on column REDACTION_COLUMNS.REGEXP_OCCURRENCE is
'Parameter for any Regular Expression based Redaction defined for this column'
/
comment on column REDACTION_COLUMNS.REGEXP_MATCH_PARAMETER is
'Parameter for any Regular Expression based Redaction defined for this column'
/
comment on column REDACTION_COLUMNS.COLUMN_DESCRIPTION is
'Description of the redaction policy on this column'
/


create or replace view REDACTION_VALUES_FOR_TYPE_FULL
  (NUMBER_VALUE
  ,BINARY_FLOAT_VALUE
  ,BINARY_DOUBLE_VALUE
  ,CHAR_VALUE
  ,VARCHAR_VALUE
  ,NCHAR_VALUE
  ,NVARCHAR_VALUE
  ,DATE_VALUE
  ,TIMESTAMP_VALUE
  ,TIMESTAMP_WITH_TIME_ZONE_VALUE
  ,BLOB_VALUE
  ,CLOB_VALUE
  ,NCLOB_VALUE) as
select 
  f.numbercol    number_value, 
  f.binfloatcol  binary_float_value,
  f.bindoublecol binary_double_value,
  f.charcol      char_value,
  f.varcharcol   varchar_value,
  f.ncharcol     nchar_value,
  f.nvarcharcol  nvarchar_value,
  f.datecol      date_value,
  f.ts_col       timestamp_value,
  f.tswtz_col    timestamp_with_time_zone_value,
  l.blobcol      blob_value,
  l.clobcol      clob_value,
  l.nclobcol     nclob_value
  from 
  (select * from radm_fptm$ order by fpver desc) f,
  (select * from radm_fptm_lob$ order by fpver desc) l
  where rownum=1;
/
create or replace public synonym REDACTION_VALUES_FOR_TYPE_FULL 
for REDACTION_VALUES_FOR_TYPE_FULL;
/
grant SELECT on REDACTION_VALUES_FOR_TYPE_FULL to SELECT_CATALOG_ROLE;
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.NUMBER_VALUE is
'Redaction result for full redaction on NUMBER columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.BINARY_FLOAT_VALUE is
'Redaction result for full redaction on BINARY_FLOAT columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.BINARY_DOUBLE_VALUE is
'Redaction result for full redaction on BINARY_DOUBLE columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.CHAR_VALUE is
'Redaction result for full redaction on CHAR columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.VARCHAR_VALUE is
'Redaction result for full redaction on VARCHAR2 columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.NCHAR_VALUE is
'Redaction result for full redaction on NCHAR columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.NVARCHAR_VALUE is
'Redaction result for full redaction on NVARCHAR2 columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.DATE_VALUE is
'Redaction result for full redaction on DATE columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.TIMESTAMP_VALUE is
'Redaction result for full redaction on TIMESTAMP columns'
/
comment on column 
REDACTION_VALUES_FOR_TYPE_FULL.TIMESTAMP_WITH_TIME_ZONE_VALUE is
'Redaction result for full redaction on TIMESTAMP WITH TIME ZONE columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.BLOB_VALUE is
'Redaction result for full redaction on BLOB columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.CLOB_VALUE is
'Redaction result for full redaction on CLOB columns'
/
comment on column REDACTION_VALUES_FOR_TYPE_FULL.NCLOB_VALUE is
'Redaction result for full redaction on NCLOB columns'
/
