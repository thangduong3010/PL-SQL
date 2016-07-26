Rem
Rem $Header: rdbms/admin/catsum.sql /main/47 2010/03/15 11:23:04 alexsanc Exp $  
Rem
Rem catsum.sql
Rem
Rem Copyright (c) 1997, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catsum.sql
Rem
Rem    DESCRIPTION
Rem      Creates the data dictionary views for summary management
Rem
Rem    NOTES
Rem      Must be run while connectd as SYS or INTERNAL
Rem    MODIFIED   (MM/DD/YY)
Rem    alexsanc    03/02/10 - Bug 6061992
Rem    zqiu        11/15/07 - hide 2nd cube mv pct refresh metadata
Rem    mthiyaga    02/07/07 - Fix bug 5857623
Rem    zqiu        01/10/07 - handle primary CUBE MVs
Rem    sramakri    12/08/05 - add pct info to xxx_MVIEW_DETAIL_RELATIONS;
Rem                           create xxx_MVIEW_DETAIL_PARTITION and _SUBPARTITION
Rem    desingh     09/27/04 - bug#3780685: create index on 
Rem                           mview_adv_basetable.queryid# 
Rem    sbodagal    05/24/04 - fix bug# 3646793
Rem    mxiao       05/13/04 - change *_DIM_CHILD_OF
Rem    sbodagal    05/13/04 - add CHILD_JOIN_TABLE in *_DIM_JOIN_KEY
Rem    sbodagal    04/13/04 - add a column to *_DIM_LEVELS views
Rem    tfyu        06/11/03 - add export package for rewrite equivalences
Rem    gssmith     07/14/03 - Extend APPLICATION column for advisor
Rem    twtong      06/10/03 - bug-2999427
Rem    mxiao       11/01/02 - grant ALL/USER_MVIEW_comments TO public
Rem    twtong      01/10/03 - fix bug-2677089
Rem    tfyu        01/13/03 - remove hard tabs
Rem    tfyu        11/12/02 - showing info in catalog views for set-op mviews
Rem    twtong      08/13/02 - add DBA/ALL/USER_REWRITE_EQUIVALENCES 
Rem    mxiao       05/15/02 - add DBA/ALL/USER_MVIEW_COMMENTS
Rem    desinha     04/29/02 - #2303866: change user => userenv('SCHEMAID')
Rem    twtong      02/13/02 - add attribute name to *_DIM_ATTRIBUTES
Rem    twtong      09/12/01 - code review comment
Rem    sramakri    08/17/01 - add scalability parameters
Rem    twtong      08/09/01 - suppress rows from setop mv
Rem    btao        08/13/01 - add table mview$_adv_info 
Rem    gviswana    05/24/01 - CREATE AND REPLACE SYNONYM
Rem    gssmith     04/05/01 - Extend column size in MVIEW$_ADV_WORKLOAD
Rem    mxiao       03/27/01 - add COMPILE_STATE to *_DIMENSIONS
Rem    twtong      03/27/01 - correct typo and comment
Rem    btao        03/28/01 - remove collectionid from MVIEW_WORKLOAD.
Rem    gssmith     02/22/01 - Name bu
Rem    gssmith     01/05/01 - 1488357
Rem    ayoaz       08/30/00 - Add user-aggregates support for materialized views.
Rem    btao        10/04/00 - modify date format for qsma.datetime_mask
Rem    gssmith     09/15/00 - Bug 1402299
Rem    sramakri    09/06/00 - check output_type in mview_recommendations and ev
Rem    btao        08/24/00 - remove redundant semi-colons
Rem    btao        08/23/00 - modify primary key for mview$_adv_eligible
Rem    btao        08/21/00 - remove grant select statements
Rem    sramakri    08/14/00 - remove MVIEW$_ADV_PROC_AUTH
Rem    btao        07/28/00 - modify filterinstance table
Rem    btao        07/05/00 - modify some parameters
Rem    btao        07/05/00 - add filter instance table and view
Rem    btao        05/11/00 - Update trace level
Rem    gssmith     04/12/00 - Adding new views for Advisor
Rem    btao        01/12/00 - add tables and views for advisor metadata
Rem    bpanchap    08/06/99 - Fixing Bug 955953
Rem    rshaikh     05/24/99 - remove comments so *summary* views dont show in d
Rem    bpanchap    05/19/99 - Fixing the comparison mask for inc_refreshable
Rem    jraitto     03/30/99 - fix INC_REFRESHABLE, RESTRICTED_SYNTAX & SUMMARY
Rem    masubram    11/17/98 - modify all_refresh_dependencies view             
Rem    jraitto     11/17/98 - add REWRITE_ENABLED column to *_MVIEW_ANALYSIS
Rem    qiwang      10/15/98 - use distinct intcol# instead of col#
Rem    jfeenan     10/26/98 - Add DBA_ synonymns
Rem    jfinnert    08/20/98 - Change NONE to NEVER in xxx_mview_analysis
Rem    qiwang      06/12/98 - Change privilege numbers
Rem    awitkows    06/03/98 - add mview views
Rem    jfinnert    06/02/98 - Change summaries views
Rem    rguzman     05/28/98 - Fix ALL_SUMMARIES view, with respect to refresh s
Rem    qiwang      04/06/98 - Change sa.expression to sa.aggtext in SUMMARY_AGG
Rem    qiwang      04/03/98 - Convert 0 to NULL in DIM_CHILD_OF views
Rem    qiwang      04/03/98 - Add even more missing views.
Rem    jfinnert    03/24/98 - Updating object number after refreshview
Rem    qiwang      03/24/98 - Create public synonyms for ALL_ and USER_ views.
Rem    qiwang      03/23/98 - Fix a bug in DBA_DIM_CHILD_OF
Rem    jfinnert    03/21/98 - Change GRANTs to only allow selection from the ca
Rem    qiwang      03/20/98 - Add DBA_ view definitions related to summary obj.
Rem    qiwang      02/17/98 - Drop the synonyms created for the set of DBA_ vie
Rem    qiwang      02/12/98 - Fix bugs in DBA_DIM_JOIN_KEYS view
Rem    qiwang      02/10/98 - Fix some comments
Rem    qiwang      02/10/98 - Add DBA_ view definitions related to dimension ob
Rem    rguzman     02/05/98 - Update ALL_SUMMARIES view with the new summary pr
Rem    wnorcott    01/14/98 - object-type # for summaries changes from 29 to 38
Rem    jfeenan     12/16/97 - Add comment for future priv change
Rem    jfeenan     12/15/97 - Change ALL_SUMMARY_DETAIL_TABLES table type to 1
Rem    jfeenan     11/12/97 - Temp hack for initial Beta1 testing make view loo
Rem    jfeenan     11/10/97 - Break out of pflags and mflags from flags
Rem    jfeenan     11/07/97 - Fix up ALL_SUMMARY_DETAIL_TABLES
Rem    jfeenan     11/06/97 - Add ALL_SUMMARIES, ALL_SUMMARY_DETAIL_TABLES and
Rem    jfeenan     11/06/97 - Catalog views for summary management
Rem    jfeenan     11/06/97 - Created
Rem


rem
rem The following are the view definitions for the 8.1 summary 
rem management project.
rem
rem For Beta 1 this will include only the information for summaries
rem dimensions will be added at a later time.
rem

rem
rem DIMENSIONS
rem

create or replace view DBA_DIMENSIONS
        (OWNER,
         DIMENSION_NAME,
         INVALID,
         COMPILE_STATE,
         REVISION)
as
select u.name, o.name,
       decode(o.status, 5, 'Y', 'N'),
       decode(o.status, 1, 'VALID', 5, 'NEEDS_COMPILE', 'ERROR'),
       1                  /* Metadata revision number */
from sys.dim$ d, sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.obj# = d.obj#
/
comment on table DBA_DIMENSIONS is
'Description of the dimension objects accessible to the DBA'
/
comment on column DBA_DIMENSIONS.OWNER is
'Owner of the dimension'
/
comment on column DBA_DIMENSIONS.DIMENSION_NAME is
'Name of the dimension'
/
comment on column DBA_DIMENSIONS.INVALID is
'Invalidity of the dimension, Y = INVALID, N = VALID.
 The column is deprecated, please use COMPILE_STATE instead.'
/
comment on column DBA_DIMENSIONS.COMPILE_STATE is
'Compile status of the dimension, VALID/NEEDS_COMPILE/ERROR'
/
comment on column DBA_DIMENSIONS.REVISION is
'Revision levle of the dimension'
/
create or replace public synonym DBA_DIMENSIONS for DBA_DIMENSIONS
/
grant select on DBA_DIMENSIONS to select_catalog_role
/

create or replace view ALL_DIMENSIONS
        (OWNER,
         DIMENSION_NAME,
         INVALID,
         COMPILE_STATE,
         REVISION)
as
select u.name, o.name,
       decode(o.status, 5, 'Y', 'N'),
       decode(o.status, 1, 'VALID', 5, 'NEEDS_COMPILE', 'ERROR'),
       1                  /* Metadata revision number */
from sys.dim$ d, sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.obj# = d.obj#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-215 /* CREATE ANY DIMENSION */,
                                       -216 /* ALTER ANY DIMENSION */,
                                       -217 /* DROP ANY DIMENSION */)
                 )
      ) 
/ 
comment on table ALL_DIMENSIONS is
'Description of the dimension objects accessible to the DBA'
/
comment on column ALL_DIMENSIONS.OWNER is
'Owner of the dimension'
/
comment on column ALL_DIMENSIONS.DIMENSION_NAME is
'Name of the dimension'
/
comment on column ALL_DIMENSIONS.INVALID is
'Invalidity of the dimension, Y = INVALID, N = VALID.
 The column is deprecated, please use COMPILE_STATE instead.'
/
comment on column ALL_DIMENSIONS.COMPILE_STATE is
'Compile status of the dimension, VALID/NEEDS_COMPILE/ERROR'
/
comment on column ALL_DIMENSIONS.REVISION is
'Revision levle of the dimension'
/
create or replace public synonym ALL_DIMENSIONS for ALL_DIMENSIONS
/
grant select on ALL_DIMENSIONS to PUBLIC with grant option
/

create or replace view USER_DIMENSIONS
        (OWNER,
         DIMENSION_NAME,
         INVALID,
         COMPILE_STATE,
         REVISION)
as
select u.name, o.name,
       decode(o.status, 5, 'Y', 'N'),
       decode(o.status, 1, 'VALID', 5, 'NEEDS_COMPILE', 'ERROR'),
       1                  /* Metadata revision number */
from sys.dim$ d, sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and o.obj# = d.obj# 
  and o.owner# = userenv('SCHEMAID')  
/ 
comment on table USER_DIMENSIONS is
'Description of the dimension objects accessible to the DBA'
/
comment on column USER_DIMENSIONS.OWNER is
'Owner of the dimension'
/
comment on column USER_DIMENSIONS.DIMENSION_NAME is
'Name of the dimension'
/
comment on column USER_DIMENSIONS.INVALID is
'Invalidity of the dimension, Y = INVALID, N = VALID.
 The column is deprecated, please use COMPILE_STATE instead.'
/
comment on column USER_DIMENSIONS.COMPILE_STATE is
'Compile status of the dimension, VALID/NEEDS_COMPILE/ERROR'
/
comment on column USER_DIMENSIONS.REVISION is
'Revision levle of the dimension'
/
create or replace public synonym USER_DIMENSIONS for USER_DIMENSIONS
/
grant select on USER_DIMENSIONS to PUBLIC with grant option
/

rem
rem DIM_LEVELS
rem

create or replace view DBA_DIM_LEVELS
   (OWNER, DIMENSION_NAME, LEVEL_NAME, NUM_COLUMNS,
    DETAILOBJ_OWNER, DETAILOBJ_NAME, SKIP_WHEN_NULL)
as
select u.name, o.name, dl.levelname, 
       temp.num_col,
       u1.name, o1.name, decode (dl.flags, 1, 'Y', 'N')  
from (select dlk.dimobj#, dlk.levelid#, dlk.detailobj#, 
             COUNT(*) as num_col
      from sys.dimlevelkey$ dlk
      group by dlk.dimobj#, dlk.levelid#, dlk.detailobj#) temp,
      sys.dimlevel$ dl, sys.obj$ o, sys.user$ u,
      sys.obj$ o1, sys.user$ u1
where dl.dimobj# = o.obj#   and
      o.owner# = u.user#    and
      dl.dimobj# = temp.dimobj# and 
      dl.levelid# = temp.levelid# and
      temp.detailobj# = o1.obj# and 
      o1.owner# = u1.user#
/
comment on table DBA_DIM_LEVELS is
'Description of dimension levels visible to DBA'
/
comment on column  DBA_DIM_LEVELS.OWNER is
'Owner of the dimension'
/
comment on column  DBA_DIM_LEVELS.DIMENSION_NAME is
'Name of the dimension'
/
comment on column  DBA_DIM_LEVELS.LEVEL_NAME is
'Name of the dimension level (unique within a dimension)'
/
comment on column  DBA_DIM_LEVELS.NUM_COLUMNS is
'Number of columns in the level definition'
/
comment on column  DBA_DIM_LEVELS.DETAILOBJ_OWNER is
'Owner of the detail object that the keys of this level come from'
/
comment on column  DBA_DIM_LEVELS.DETAILOBJ_NAME is
'Name of the table that the keys of this level come from'
/
comment on column DBA_DIM_LEVELS.SKIP_WHEN_NULL is
'Is the level declared with SKIP WHEN NULL clause? (Y/N)'

create or replace public synonym DBA_DIM_LEVELS for DBA_DIM_LEVELS
/
grant select on DBA_DIM_LEVELS to select_catalog_role
/

create or replace view ALL_DIM_LEVELS
   (OWNER, DIMENSION_NAME, LEVEL_NAME, NUM_COLUMNS,
    DETAILOBJ_OWNER, DETAILOBJ_NAME, SKIP_WHEN_NULL)
as
select u.name, o.name, dl.levelname, 
       temp.num_col,
       u1.name, o1.name, decode (dl.flags, 1, 'Y', 'N')  
from (select dlk.dimobj#, dlk.levelid#, dlk.detailobj#, 
             COUNT(*) as num_col
      from sys.dimlevelkey$ dlk
      group by dlk.dimobj#, dlk.levelid#, dlk.detailobj#) temp,
      sys.dimlevel$ dl, sys.obj$ o, sys.user$ u,
      sys.obj$ o1, sys.user$ u1
where dl.dimobj# = o.obj#   and
      o.owner# = u.user#    and
      dl.dimobj# = temp.dimobj# and 
      dl.levelid# = temp.levelid# and
      temp.detailobj# = o1.obj# and 
      o1.owner# = u1.user# and
      (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-215 /* CREATE ANY DIMENSION */,
                                       -216 /* ALTER ANY DIMENSION */,
                                       -217 /* DROP ANY DIMENSION */)
                 )
      ) 
/
comment on table ALL_DIM_LEVELS is
'Description of dimension levels visible to DBA'
/
comment on column  ALL_DIM_LEVELS.OWNER is
'Owner of the dimension'
/
comment on column  ALL_DIM_LEVELS.DIMENSION_NAME is
'Name of the dimension'
/
comment on column  ALL_DIM_LEVELS.LEVEL_NAME is
'Name of the dimension level (unique within a dimension)'
/
comment on column  ALL_DIM_LEVELS.NUM_COLUMNS is
'Number of columns in the level definition'
/
comment on column  ALL_DIM_LEVELS.DETAILOBJ_OWNER is
'Owner of the detail object that the keys of this level come from'
/
comment on column  ALL_DIM_LEVELS.DETAILOBJ_NAME is
'Name of the table that the keys of this level come from'
/
comment on column ALL_DIM_LEVELS.SKIP_WHEN_NULL is
'Is the level declared with SKIP WHEN NULL clause? (Y/N)'
/

create or replace public synonym ALL_DIM_LEVELS for ALL_DIM_LEVELS
/
grant select on ALL_DIM_LEVELS to PUBLIC with grant option
/

create or replace view USER_DIM_LEVELS
   (OWNER, DIMENSION_NAME, LEVEL_NAME, NUM_COLUMNS,
    DETAILOBJ_OWNER, DETAILOBJ_NAME, SKIP_WHEN_NULL)
as
select u.name, o.name, dl.levelname, 
       temp.num_col,
       u1.name, o1.name, decode (dl.flags, 1, 'Y', 'N')
from (select dlk.dimobj#, dlk.levelid#, dlk.detailobj#, 
             COUNT(*) as num_col
      from sys.dimlevelkey$ dlk
      group by dlk.dimobj#, dlk.levelid#, dlk.detailobj#) temp,
      sys.dimlevel$ dl, sys.obj$ o, sys.user$ u,
      sys.obj$ o1, sys.user$ u1
where dl.dimobj# = o.obj#   and
      o.owner# = u.user#    and
      dl.dimobj# = temp.dimobj# and 
      dl.levelid# = temp.levelid# and
      temp.detailobj# = o1.obj# and 
      o1.owner# = u1.user# and
      o.owner# = userenv('SCHEMAID')
/
comment on table USER_DIM_LEVELS is
'Description of dimension levels visible to DBA'
/
comment on column  USER_DIM_LEVELS.OWNER is
'Owner of the dimension'
/
comment on column  USER_DIM_LEVELS.DIMENSION_NAME is
'Name of the dimension'
/
comment on column  USER_DIM_LEVELS.LEVEL_NAME is
'Name of the dimension level (unique within a dimension)'
/
comment on column  USER_DIM_LEVELS.NUM_COLUMNS is
'Number of columns in the level definition'
/
comment on column  USER_DIM_LEVELS.DETAILOBJ_OWNER is
'Owner of the detail object that the keys of this level come from'
/
comment on column  USER_DIM_LEVELS.DETAILOBJ_NAME is
'Name of the table that the keys of this level come from'
/
comment on column  USER_DIM_LEVELS.SKIP_WHEN_NULL is
'Is the level declared with SKIP WHEN NULL clause? (Y/N)'
/
create or replace public synonym USER_DIM_LEVELS for USER_DIM_LEVELS
/
grant select on USER_DIM_LEVELS to PUBLIC with grant option
/
 
REM
REM  DBA_DIM_LEVEL_KEY
REM

create or replace view DBA_DIM_LEVEL_KEY
   (OWNER, DIMENSION_NAME, LEVEL_NAME, KEY_POSITION, COLUMN_NAME)
as
select u.name, o.name, dl.levelname, dlk.keypos#, c.name
from sys.dimlevelkey$ dlk, sys.obj$ o, sys.user$ u, sys.dimlevel$ dl, 
     sys.col$ c
where dlk.dimobj# = o.obj#
  and o.owner# = u.user#
  and dlk.dimobj# = dl.dimobj#
  and dlk.levelid# = dl.levelid#
  and dlk.detailobj# = c.obj#
  and dlk.col# = c.intcol#

/
comment on table DBA_DIM_LEVEL_KEY is
'Representations of columns of a dimension level'
/
comment on column DBA_DIM_LEVEL_KEY.OWNER is
'Owner of the dimension'
/
comment on column DBA_DIM_LEVEL_KEY.DIMENSION_NAME is
'Name of the dimension'
/
comment on column DBA_DIM_LEVEL_KEY.LEVEL_NAME is
'Name of the hierarchy level'
/
comment on column DBA_DIM_LEVEL_KEY.KEY_POSITION is
'Ordinal position of the key column within the level'
/
comment on column DBA_DIM_LEVEL_KEY.COLUMN_NAME is
'Name of the key column'
/
create or replace public synonym DBA_DIM_LEVEL_KEY for DBA_DIM_LEVEL_KEY
/
grant select on DBA_DIM_LEVEL_KEY to select_catalog_role
/

create or replace view ALL_DIM_LEVEL_KEY
   (OWNER, DIMENSION_NAME, LEVEL_NAME, KEY_POSITION, COLUMN_NAME)
as
select u.name, o.name, dl.levelname, dlk.keypos#, c.name
from sys.dimlevelkey$ dlk, sys.obj$ o, sys.user$ u, sys.dimlevel$ dl, 
     sys.col$ c
where dlk.dimobj# = o.obj#
  and o.owner# = u.user#
  and dlk.dimobj# = dl.dimobj#
  and dlk.levelid# = dl.levelid#
  and dlk.detailobj# = c.obj#
  and dlk.col# = c.intcol#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-215 /* CREATE ANY DIMENSION */,
                                       -216 /* ALTER ANY DIMENSION */,
                                       -217 /* DROP ANY DIMENSION */)
                 )
      ) 
/
comment on table ALL_DIM_LEVEL_KEY is
'Representations of columns of a dimension level'
/
comment on column ALL_DIM_LEVEL_KEY.OWNER is
'Owner of the dimension'
/
comment on column ALL_DIM_LEVEL_KEY.DIMENSION_NAME is
'Name of the dimension'
/
comment on column ALL_DIM_LEVEL_KEY.LEVEL_NAME is
'Name of the hierarchy level'
/
comment on column ALL_DIM_LEVEL_KEY.KEY_POSITION is
'Ordinal position of the key column within the level'
/
comment on column ALL_DIM_LEVEL_KEY.COLUMN_NAME is
'Name of the key column'
/
create or replace public synonym ALL_DIM_LEVEL_KEY for ALL_DIM_LEVEL_KEY
/
grant select on ALL_DIM_LEVEL_KEY to PUBLIC with grant option
/

create or replace view USER_DIM_LEVEL_KEY
   (OWNER, DIMENSION_NAME, LEVEL_NAME, KEY_POSITION, COLUMN_NAME)
as
select u.name, o.name, dl.levelname, dlk.keypos#, c.name
from sys.dimlevelkey$ dlk, sys.obj$ o, sys.user$ u, sys.dimlevel$ dl, 
     sys.col$ c
where dlk.dimobj# = o.obj#
  and o.owner# = u.user#
  and dlk.dimobj# = dl.dimobj#
  and dlk.levelid# = dl.levelid#
  and dlk.detailobj# = c.obj#
  and dlk.col# = c.intcol#
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_DIM_LEVEL_KEY is
'Representations of columns of a dimension level'
/
comment on column USER_DIM_LEVEL_KEY.OWNER is
'Owner of the dimension'
/
comment on column USER_DIM_LEVEL_KEY.DIMENSION_NAME is
'Name of the dimension'
/
comment on column USER_DIM_LEVEL_KEY.LEVEL_NAME is
'Name of the hierarchy level'
/
comment on column USER_DIM_LEVEL_KEY.KEY_POSITION is
'Ordinal position of the key column within the level'
/
comment on column USER_DIM_LEVEL_KEY.COLUMN_NAME is
'Name of the key column'
/
create or replace public synonym USER_DIM_LEVEL_KEY for USER_DIM_LEVEL_KEY
/
grant select on USER_DIM_LEVEL_KEY to PUBLIC with grant option
/

REM
REM DBA_DIM_ATTRIBUTES
REM

create or replace view DBA_DIM_ATTRIBUTES
    (OWNER, DIMENSION_NAME, ATTRIBUTE_NAME, LEVEL_NAME, COLUMN_NAME, INFERRED)
as
select u.name, o.name, da.attname, dl.levelname, c.name, 'N'
from sys.dimattr$ da, sys.obj$ o, sys.user$ u, sys.dimlevel$ dl, sys.col$ c 
where da.dimobj# = o.obj#
  and o.owner# = u.user#
  and da.dimobj# = dl.dimobj#
  and da.levelid# = dl.levelid#
  and da.detailobj# = c.obj#
  and da.col# = c.intcol#

/
comment on table DBA_DIM_ATTRIBUTES is
'Representation of the relationship between a dimension level and
 a functionally dependent column'
/
comment on column DBA_DIM_ATTRIBUTES.OWNER is
'Owner of the dimentsion'
/
comment on column DBA_DIM_ATTRIBUTES.DIMENSION_NAME is
'Name of the dimension'
/
comment on column DBA_DIM_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the attribute'
/
comment on column DBA_DIM_ATTRIBUTES.LEVEL_NAME is
'Name of the hierarchy level'
/
comment on column DBA_DIM_ATTRIBUTES.COLUMN_NAME is
'Name of the dependent column'
/
comment on column DBA_DIM_ATTRIBUTES.INFERRED is
'Whether this attribute is inferred from a JOIN KEY specification'
/
create or replace public synonym DBA_DIM_ATTRIBUTES for DBA_DIM_ATTRIBUTES
/
grant select on DBA_DIM_ATTRIBUTES  to select_catalog_role
/

create or replace view ALL_DIM_ATTRIBUTES
    (OWNER, DIMENSION_NAME, ATTRIBUTE_NAME, LEVEL_NAME, COLUMN_NAME, INFERRED)
as
select u.name, o.name, da.attname, dl.levelname, c.name, 'N'
from sys.dimattr$ da, sys.obj$ o, sys.user$ u, sys.dimlevel$ dl, sys.col$ c 
where da.dimobj# = o.obj#
  and o.owner# = u.user#
  and da.dimobj# = dl.dimobj#
  and da.levelid# = dl.levelid#
  and da.detailobj# = c.obj#
  and da.col# = c.intcol#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-215 /* CREATE ANY DIMENSION */,
                                       -216 /* ALTER ANY DIMENSION */,
                                       -217 /* DROP ANY DIMENSION */)
                 )
      ) 
/
comment on table ALL_DIM_ATTRIBUTES is
'Representation of the relationship between a dimension level and
 a functionally dependent column'
/
comment on column ALL_DIM_ATTRIBUTES.OWNER is
'Owner of the dimentsion'
/
comment on column ALL_DIM_ATTRIBUTES.DIMENSION_NAME is
'Name of the dimension'
/
comment on column ALL_DIM_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the attribute'
/
comment on column ALL_DIM_ATTRIBUTES.LEVEL_NAME is
'Name of the hierarchy level'
/
comment on column ALL_DIM_ATTRIBUTES.COLUMN_NAME is
'Name of the dependent column'
/
comment on column ALL_DIM_ATTRIBUTES.INFERRED is
'Whether this attribute is inferred from a JOIN KEY specification'
/

create or replace public synonym ALL_DIM_ATTRIBUTES for ALL_DIM_ATTRIBUTES
/
grant select on ALL_DIM_ATTRIBUTES to PUBLIC with grant option
/

create or replace view USER_DIM_ATTRIBUTES
    (OWNER, DIMENSION_NAME, ATTRIBUTE_NAME, LEVEL_NAME, COLUMN_NAME, INFERRED)
as
select u.name, o.name, da.attname, dl.levelname, c.name, 'N'
from sys.dimattr$ da, sys.obj$ o, sys.user$ u, sys.dimlevel$ dl, sys.col$ c 
where da.dimobj# = o.obj#
  and o.owner# = u.user#
  and da.dimobj# = dl.dimobj#
  and da.levelid# = dl.levelid#
  and da.detailobj# = c.obj#
  and da.col# = c.intcol#
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_DIM_ATTRIBUTES is
'Representation of the relationship between a dimension level and
 a functionally dependent column'
/
comment on column USER_DIM_ATTRIBUTES.OWNER is
'Owner of the dimentsion'
/
comment on column USER_DIM_ATTRIBUTES.DIMENSION_NAME is
'Name of the dimension'
/
comment on column USER_DIM_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the attribute'
/
comment on column USER_DIM_ATTRIBUTES.LEVEL_NAME is
'Name of the hierarchy level'
/
comment on column USER_DIM_ATTRIBUTES.COLUMN_NAME is
'Name of the dependent column'
/
comment on column USER_DIM_ATTRIBUTES.INFERRED is
'Whether this attribute is inferred from a JOIN KEY specification'
/
create or replace public synonym USER_DIM_ATTRIBUTES for USER_DIM_ATTRIBUTES
/
grant select on USER_DIM_ATTRIBUTES to PUBLIC with grant option
/

REM
REM DBA_DIM_HIERARCHIES
REM

create or replace view DBA_DIM_HIERARCHIES
    (OWNER, DIMENSION_NAME, HIERARCHY_NAME)
as
select u.name, o.name, h.hiername
from sys.hier$ h, sys.obj$ o, sys.user$ u
where h.dimobj# = o.obj#
  and o.owner# = u.user#

/
comment on table DBA_DIM_HIERARCHIES is
'Representation of a dimension hierarchy'
/
comment on column DBA_DIM_HIERARCHIES.OWNER is
'Owner of the dimension'
/
comment on column DBA_DIM_HIERARCHIES.DIMENSION_NAME is
'Name of the dimension'
/
comment on column DBA_DIM_HIERARCHIES.HIERARCHY_NAME is
'Name of the hierarchy'
/
create or replace public synonym DBA_DIM_HIERARCHIES for DBA_DIM_HIERARCHIES
/
grant select on DBA_DIM_HIERARCHIES  to select_catalog_role
/

create or replace view ALL_DIM_HIERARCHIES
    (OWNER, DIMENSION_NAME, HIERARCHY_NAME)
as
select u.name, o.name, h.hiername
from sys.hier$ h, sys.obj$ o, sys.user$ u
where h.dimobj# = o.obj#
  and o.owner# = u.user#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-215 /* CREATE ANY DIMENSION */,
                                       -216 /* ALTER ANY DIMENSION */,
                                       -217 /* DROP ANY DIMENSION */)
                 )
      ) 
/
comment on table ALL_DIM_HIERARCHIES is
'Representation of a dimension hierarchy'
/
comment on column ALL_DIM_HIERARCHIES.OWNER is
'Owner of the dimension'
/
comment on column ALL_DIM_HIERARCHIES.DIMENSION_NAME is
'Name of the dimension'
/
comment on column ALL_DIM_HIERARCHIES.HIERARCHY_NAME is
'Name of the hierarchy'
/
create or replace public synonym ALL_DIM_HIERARCHIES for ALL_DIM_HIERARCHIES
/
grant select on ALL_DIM_HIERARCHIES to PUBLIC with grant option
/

create or replace view USER_DIM_HIERARCHIES
    (OWNER, DIMENSION_NAME, HIERARCHY_NAME)
as
select u.name, o.name, h.hiername
from sys.hier$ h, sys.obj$ o, sys.user$ u
where h.dimobj# = o.obj#
  and o.owner# = u.user#
  and o.owner# = userenv('SCHEMAID')
/
comment on table USER_DIM_HIERARCHIES is
'Representation of a dimension hierarchy'
/
comment on column USER_DIM_HIERARCHIES.OWNER is
'Owner of the dimension'
/
comment on column USER_DIM_HIERARCHIES.DIMENSION_NAME is
'Name of the dimension'
/
comment on column USER_DIM_HIERARCHIES.HIERARCHY_NAME is
'Name of the hierarchy'
/
create or replace public synonym USER_DIM_HIERARCHIES for USER_DIM_HIERARCHIES
/
grant select on USER_DIM_HIERARCHIES to PUBLIC with grant option
/

REM
REM DBA_DIM_CHILD_OF
REM
REM Since 10R2, we allow two levels reference the same parent
REM if one of the two child levels is defined as 'SKIP WHEN NULL'.
REM So in the catalog view, a level is excluded if its child
REM level in dimjoinkey$ is not an immediate child.
REM In the way, one and only one level and its join key id is
REM shown in the catalog view.
create or replace view DBA_DIM_CHILD_OF 
   (OWNER, DIMENSION_NAME, HIERARCHY_NAME, POSITION,
    CHILD_LEVEL_NAME, JOIN_KEY_ID, PARENT_LEVEL_NAME)
as
select u.name, o.name, h.hiername, chl.pos#,
       cdl.levelname, 
       decode(phl.joinkeyid#, 0, NULL, phl.joinkeyid#),
       pdl.levelname
from sys.obj$ o, sys.user$ u, sys.hier$ h,
     sys.hierlevel$ phl, sys.hierlevel$ chl,
     sys.dimlevel$ pdl,  sys.dimlevel$ cdl
where phl.dimobj# = o.obj#
  and o.owner# = u.user#
  and phl.dimobj# = h.dimobj#
  and phl.hierid# = h.hierid#
  and phl.dimobj# = pdl.dimobj#
  and phl.levelid# = pdl.levelid#
  and phl.dimobj# = chl.dimobj#
  and phl.hierid# = chl.hierid#
  and phl.pos# = chl.pos# + 1
  and chl.dimobj# = cdl.dimobj#
  and chl.levelid# = cdl.levelid#
  AND (phl.joinkeyid# = 0 
       OR (phl.joinkeyid# NOT IN 
             (SELECT DISTINCT d.joinkeyid#        
                FROM sys.dimjoinkey$ d 
                WHERE phl.dimobj# = d.dimobj# AND phl.joinkeyid# = d.joinkeyid# 
                      AND d.chdlevid# != chl.levelid#
             )
          )
      )
/  
 
comment on table DBA_DIM_CHILD_OF is
'Representaion of a 1:n hierarchical relationship between a pair of levels in 
 a dimension'
/
comment on column DBA_DIM_CHILD_OF.OWNER is
'Owner of the dimension'
/
comment on column DBA_DIM_CHILD_OF.DIMENSION_NAME is
'Name of the dimension'
/
comment on column DBA_DIM_CHILD_OF.HIERARCHY_NAME is
'Name of the hierarchy'
/
comment on column DBA_DIM_CHILD_OF.POSITION is
'Hierarchical position within this hierarchy, position 1 being
 the most detailed'
/
comment on column DBA_DIM_CHILD_OF.CHILD_LEVEL_NAME is
'Name of the child-side level of this 1:n relationship'
/
comment on column DBA_DIM_CHILD_OF.JOIN_KEY_ID is
'Keys that join child to the parent'
/
comment on column DBA_DIM_CHILD_OF.PARENT_LEVEL_NAME is
'Name of the parent-side level of this 1:n relationship'
/
create or replace public synonym DBA_DIM_CHILD_OF for DBA_DIM_CHILD_OF
/
grant select on DBA_DIM_CHILD_OF  to select_catalog_role
/

create or replace view ALL_DIM_CHILD_OF 
as
select d.* from dba_dim_child_of d, sys.obj$ o, sys.user$ u
where o.owner#         = u.user#
  and d.dimension_name = o.name
  and d.owner          = u.name
  and o.type#          = 43                     /* dimension */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-215 /* CREATE ANY DIMENSION */,
                                       -216 /* ALTER ANY DIMENSION */,
                                       -217 /* DROP ANY DIMENSION */)
                 )
      ) 
/
comment on table ALL_DIM_CHILD_OF is
'Representaion of a 1:n hierarchical relationship between a pair of levels in 
 a dimension'
/
comment on column ALL_DIM_CHILD_OF.OWNER is
'Owner of the dimension'
/
comment on column ALL_DIM_CHILD_OF.DIMENSION_NAME is
'Name of the dimension'
/
comment on column ALL_DIM_CHILD_OF.HIERARCHY_NAME is
'Name of the hierarchy'
/
comment on column ALL_DIM_CHILD_OF.POSITION is
'Hierarchical position within this hierarchy, position 1 being
 the most detailed'
/
comment on column ALL_DIM_CHILD_OF.CHILD_LEVEL_NAME is
'Name of the child-side level of this 1:n relationship'
/
comment on column ALL_DIM_CHILD_OF.JOIN_KEY_ID is
'Keys that join child to the parent'
/
comment on column ALL_DIM_CHILD_OF.PARENT_LEVEL_NAME is
'Name of the parent-side level of this 1:n relationship'
/
create or replace public synonym ALL_DIM_CHILD_OF for ALL_DIM_CHILD_OF
/
grant select on ALL_DIM_CHILD_OF to PUBLIC with grant option
/

create or replace view USER_DIM_CHILD_OF 
as
select d.* FROM dba_dim_child_of d, sys.user$ u
where u.user# = userenv('SCHEMAID')
  and d.owner = u.name
/
comment on table USER_DIM_CHILD_OF is
'Representaion of a 1:n hierarchical relationship between a pair of levels in 
 a dimension'
/
comment on column USER_DIM_CHILD_OF.OWNER is
'Owner of the dimension'
/
comment on column USER_DIM_CHILD_OF.DIMENSION_NAME is
'Name of the dimension'
/
comment on column USER_DIM_CHILD_OF.HIERARCHY_NAME is
'Name of the hierarchy'
/
comment on column USER_DIM_CHILD_OF.POSITION is
'Hierarchical position within this hierarchy, position 1 being
 the most detailed'
/
comment on column USER_DIM_CHILD_OF.CHILD_LEVEL_NAME is
'Name of the child-side level of this 1:n relationship'
/
comment on column USER_DIM_CHILD_OF.JOIN_KEY_ID is
'Keys that join child to the parent'
/
comment on column USER_DIM_CHILD_OF.PARENT_LEVEL_NAME is
'Name of the parent-side level of this 1:n relationship'
/
create or replace public synonym USER_DIM_CHILD_OF for USER_DIM_CHILD_OF
/
grant select on USER_DIM_CHILD_OF to PUBLIC with grant option
/

REM
REM DBA_DIM_JOIN_KEY
REM

create or replace view DBA_DIM_JOIN_KEY
   (OWNER, DIMENSION_NAME, DIM_KEY_ID, LEVEL_NAME,
    KEY_POSITION, HIERARCHY_NAME, CHILD_JOIN_OWNER, CHILD_JOIN_TABLE, 
    CHILD_JOIN_COLUMN, CHILD_LEVEL_NAME)
as
select u.name, o.name, djk.joinkeyid#, dl.levelname,
       djk.keypos#, h.hiername, u1.name, o1.name, c.name, dl2.levelname
from sys.dimjoinkey$ djk, sys.obj$ o, sys.user$ u,
     sys.dimlevel$ dl, sys.hier$ h, sys.col$ c, sys.obj$ o1, sys.user$ u1,
     sys.dimlevel$ dl2
where djk.dimobj# = o.obj#
  and o.owner# = u.user#
  and djk.dimobj# = dl.dimobj#
  and djk.levelid# = dl.levelid#
  and djk.dimobj# = h.dimobj#
  and djk.hierid# = h.hierid#
  and djk.detailobj# = c.obj#
  and djk.col# = c.intcol#
  AND djk.detailobj# = o1.obj#
  AND o1.owner# = u1.user#
  AND djk.dimobj# = dl2.dimobj#
  AND djk.chdlevid# = dl2.levelid#
/
comment on table DBA_DIM_JOIN_KEY is
'Representation of a join between two dimension tables. '
/
comment on column DBA_DIM_JOIN_KEY.OWNER is
'Owner of the dimension'
/
comment on column DBA_DIM_JOIN_KEY.DIMENSION_NAME is
'Name of the dimension'
/
comment on column DBA_DIM_JOIN_KEY.DIM_KEY_ID is
'Join key ID (unique within a dimension)'
/
comment on column DBA_DIM_JOIN_KEY.LEVEL_NAME is
'Name of the hierarchy level'
/
comment on column DBA_DIM_JOIN_KEY.KEY_POSITION is
'Position of the key column within the level'
/
comment on column DBA_DIM_JOIN_KEY.HIERARCHY_NAME is
'Name of the hierarchy'
/
comment on column DBA_DIM_JOIN_KEY.CHILD_JOIN_OWNER IS
'Owner of the join column table'
/
comment on column DBA_DIM_JOIN_KEY.CHILD_JOIN_TABLE IS
'Name of the join column table'
/
comment on column DBA_DIM_JOIN_KEY.CHILD_JOIN_COLUMN is
'Name of the join column'
/
comment ON column DBA_DIM_JOIN_KEY.CHILD_LEVEL_NAME is
'Name of the child hierarchy level of the join key'
/
create or replace public synonym DBA_DIM_JOIN_KEY for DBA_DIM_JOIN_KEY
/
grant select on DBA_DIM_JOIN_KEY  to select_catalog_role
/

create or replace view ALL_DIM_JOIN_KEY
as
select d.* from dba_dim_join_key d, sys.obj$ o, sys.user$ u
where o.owner#         = u.user#
  and d.dimension_name = o.name
  and d.owner          = u.name
  and o.type#          = 43                     /* dimension */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-215 /* CREATE ANY DIMENSION */,
                                       -216 /* ALTER ANY DIMENSION */,
                                       -217 /* DROP ANY DIMENSION */)
                 )
      ) 
/
comment on table ALL_DIM_JOIN_KEY is
'Representation of a join between two dimension tables. '
/
comment on column ALL_DIM_JOIN_KEY.OWNER is
'Owner of the dimension'
/
comment on column ALL_DIM_JOIN_KEY.DIMENSION_NAME is
'Name of the dimension'
/
comment on column ALL_DIM_JOIN_KEY.DIM_KEY_ID is
'Join key ID (unique within a dimension)'
/
comment on column ALL_DIM_JOIN_KEY.LEVEL_NAME is
'Name of the hierarchy level'
/
comment on column ALL_DIM_JOIN_KEY.KEY_POSITION is
'Position of the key column within the level'
/
comment on column ALL_DIM_JOIN_KEY.HIERARCHY_NAME is
'Name of the hierarchy'
/
comment on column ALL_DIM_JOIN_KEY.CHILD_JOIN_OWNER IS
'Owner of the join column table'
/
comment on column ALL_DIM_JOIN_KEY.CHILD_JOIN_TABLE IS
'Name of the join column table'
/
comment on column ALL_DIM_JOIN_KEY.CHILD_JOIN_COLUMN is
'Name of the join column'
/  
comment ON column ALL_DIM_JOIN_KEY.CHILD_LEVEL_NAME is 
'Name of the child hierarchy level of the join key'
/
create or replace public synonym ALL_DIM_JOIN_KEY for ALL_DIM_JOIN_KEY
/
grant select on ALL_DIM_JOIN_KEY  to PUBLIC with grant option
/

create or replace view USER_DIM_JOIN_KEY
as
select d.* FROM dba_dim_join_key d, sys.user$ u
where u.user# = userenv('SCHEMAID')
  and d.owner = u.name
/
comment on table USER_DIM_JOIN_KEY is
'Representation of a join between two dimension tables. '
/
comment on column USER_DIM_JOIN_KEY.OWNER is
'Owner of the dimension'
/
comment on column USER_DIM_JOIN_KEY.DIMENSION_NAME is
'Name of the dimension'
/
comment on column USER_DIM_JOIN_KEY.DIM_KEY_ID is
'Join key ID (unique within a dimension)'
/
comment on column USER_DIM_JOIN_KEY.LEVEL_NAME is
'Name of the hierarchy level'
/
comment on column USER_DIM_JOIN_KEY.KEY_POSITION is
'Position of the key column within the level'
/
comment on column USER_DIM_JOIN_KEY.HIERARCHY_NAME is
'Name of the hierarchy'
/
comment on column USER_DIM_JOIN_KEY.CHILD_JOIN_OWNER IS
'Owner of the join column table'
/
comment on column USER_DIM_JOIN_KEY.CHILD_JOIN_TABLE IS
'Name of the join column table'
/
comment on column USER_DIM_JOIN_KEY.CHILD_JOIN_COLUMN is
'Name of the join column'
/  
comment on column USER_DIM_JOIN_KEY.CHILD_LEVEL_NAME is 
'Name of the child hierarchy level of the join key'
/
create or replace public synonym USER_DIM_JOIN_KEY for USER_DIM_JOIN_KEY
/
grant select on USER_DIM_JOIN_KEY  to PUBLIC with grant option
/

rem The pflags field referenced from sum$ is highly dependent on the 
rem bit combinations of QSMKSUM.
rem **jjf** the privs have to be summary based not tables when implemented

rem
rem Familiy of SUMMARIES views
rem

rem ALL_SUMMARIES

create or replace view ALL_SUMMARIES
    (OWNER, SUMMARY_NAME, CONTAINER_OWNER, CONTAINER_NAME, 
     LAST_REFRESH_SCN, LAST_REFRESH_DATE, REFRESH_METHOD, SUMMARY,
     FULLREFRESHTIM, INCREFRESHTIM,
     CONTAINS_VIEWS, UNUSABLE, RESTRICTED_SYNTAX, INC_REFRESHABLE,
     KNOWN_STALE, QUERY_LEN, QUERY)
as
select u.name, o.name, u.name, s.containernam,
       s.lastrefreshscn, s.lastrefreshdate,
       decode (s.refreshmode, 0, 'NONE', 1, 'ANY', 2, 'INCREMENTAL', 3,'FULL'),
       decode(bitand(s.pflags, 25165824), 25165824, 'N', 'Y'),
       s.fullrefreshtim, s.increfreshtim,
       decode(bitand(s.pflags, 48), 0, 'N', 'Y'),
       decode(bitand(s.mflags, 64), 0, 'N', 'Y'), /* QSMQSUM_UNUSABLE */ 
       decode(bitand(s.pflags, 1294319), 0, 'Y', 'N'), 
       decode(bitand((select n.flag2 from sys.snap$ n 
                      where n.vname=s.containernam and n.sowner=u.name), 67108864), 
                     67108864,  /* primary CUBE mv? */
                     decode(bitand((select n2.flag from sys.snap$ n2
                            where n2.parent_sowner=u.name and n2.parent_vname=s.containernam), 256), 
                            256, 'N', 'Y'), /* Its child mv's properties determin INC_REFRESHABLE */
                     decode(bitand(s.pflags, 236879743), 0, 'Y', 'N')), 
       decode(bitand(s.mflags, 1), 0, 'N', 'Y'), /* QSMQSUM_KNOWNSTL */
       s.sumtextlen,s.sumtext
from sys.user$ u, sys.sum$ s, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = s.obj#
  and bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
/


comment on table ALL_SUMMARIES is
'Description of the summaries accessible to the user'
/
comment on column ALL_SUMMARIES.OWNER is
'Owner of the summary'
/
comment on column ALL_SUMMARIES.SUMMARY_NAME is
'Name of the summary'
/
comment on column ALL_SUMMARIES.CONTAINER_OWNER is
'Owner of the container table'
/
comment on column ALL_SUMMARIES.CONTAINER_NAME is
'Name of the container table for this summary'
/
comment on column ALL_SUMMARIES.LAST_REFRESH_SCN is
'The SCN of the last transaction to refresh the summary'
/
comment on column ALL_SUMMARIES.LAST_REFRESH_DATE is
'The date of the last refresh of the summary'
/
comment on column ALL_SUMMARIES.REFRESH_METHOD is
'User declared method of refresh for the summary'
/
comment on column ALL_SUMMARIES.FULLREFRESHTIM is
'The time that it took to fully refresh the summary'
/
comment on column ALL_SUMMARIES.INCREFRESHTIM is
'The time that it took to incrementally refresh the summary'
/
comment on column ALL_SUMMARIES.CONTAINS_VIEWS is
'This summary contains views in the FROM clause'
/
comment on column ALL_SUMMARIES.UNUSABLE is
'This summary is unusable, the build was deferred'
/
comment on column ALL_SUMMARIES.RESTRICTED_SYNTAX is
'This summary contains restrictive syntax'
/
comment on column ALL_SUMMARIES.INC_REFRESHABLE is
'This summary is not restricted from being incrementally refreshed'
/
comment on column ALL_SUMMARIES.KNOWN_STALE is
'This summary is directly stale'
/
comment on column ALL_SUMMARIES.SUMMARY is
'Indicates the presence of either aggregation or a GROUP BY'
/
create or replace public synonym ALL_SUMMARIES for ALL_SUMMARIES
/
grant select on ALL_SUMMARIES to PUBLIC with grant option
/

rem USER_SUMMARIES

create or replace view USER_SUMMARIES
    (OWNER, SUMMARY_NAME, CONTAINER_OWNER, CONTAINER_NAME, 
     LAST_REFRESH_SCN, LAST_REFRESH_DATE, REFRESH_METHOD, SUMMARY,
     FULLREFRESHTIM, INCREFRESHTIM,
     CONTAINS_VIEWS, UNUSABLE, RESTRICTED_SYNTAX, INC_REFRESHABLE,
     KNOWN_STALE, QUERY_LEN, QUERY)
as
select u.name, o.name, u.name, s.containernam,
       s.lastrefreshscn, s.lastrefreshdate,
       decode (s.refreshmode, 0, 'NONE', 1, 'ANY', 2, 'INCREMENTAL', 3,'FULL'),
       decode(bitand(s.pflags, 25165824), 25165824, 'N', 'Y'),
       s.fullrefreshtim, s.increfreshtim,
       decode(bitand(s.pflags, 48), 0, 'N', 'Y'),
       decode(bitand(s.mflags, 64), 0, 'N', 'Y'), /* QSMQSUM_UNUSABLE */ 
       decode(bitand(s.pflags, 1294319), 0, 'Y', 'N'), 
       decode(bitand((select n.flag2 from sys.snap$ n 
                      where n.vname=s.containernam and n.sowner=u.name), 67108864), 
                     67108864,  /* primary CUBE mv? */
                     decode(bitand((select n2.flag from sys.snap$ n2
                            where n2.parent_sowner=u.name and n2.parent_vname=s.containernam), 256), 
                            256, 'N', 'Y'), /* Its child mv's properties determin INC_REFRESHABLE */
                     decode(bitand(s.pflags, 236879743), 0, 'Y', 'N')), 
       decode(bitand(s.mflags, 1), 0, 'N', 'Y'), /* QSMQSUM_KNOWNSTL */
       s.sumtextlen,s.sumtext
from sys.user$ u, sys.sum$ s, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = s.obj#
  and bitand(s.xpflags, 8388608) = 0  /* NOT REWRITE EQUIVALENCE SUMMARY */ 
  and o.owner# = userenv('SCHEMAID')

/
comment on table USER_SUMMARIES is
'Description of the summaries created by the user'
/
comment on column USER_SUMMARIES.OWNER is
'Owner of the summary'
/
comment on column USER_SUMMARIES.SUMMARY_NAME is
'Name of the summary'
/
comment on column USER_SUMMARIES.CONTAINER_OWNER is
'Owner of the container table'
/
comment on column USER_SUMMARIES.CONTAINER_NAME is
'Name of the container table for this summary'
/
comment on column USER_SUMMARIES.LAST_REFRESH_SCN is
'The SCN of the last transaction to refresh the summary'
/
comment on column USER_SUMMARIES.LAST_REFRESH_DATE is
'The date of the last refresh of the summary'
/
comment on column USER_SUMMARIES.REFRESH_METHOD is
'User declared method of refresh for the summary'
/
comment on column USER_SUMMARIES.FULLREFRESHTIM is
'The time that it took to fully refresh the summary'
/
comment on column USER_SUMMARIES.INCREFRESHTIM is
'The time that it took to incrementally refresh the summary'
/
comment on column USER_SUMMARIES.CONTAINS_VIEWS is
'This summary contains views in the FROM clause'
/
comment on column USER_SUMMARIES.UNUSABLE is
'This summary is unusable, the build was deferred'
/
comment on column USER_SUMMARIES.RESTRICTED_SYNTAX is
'This summary contains restrictive syntax'
/
comment on column USER_SUMMARIES.INC_REFRESHABLE is
'This summary is not restricted from being incrementally refreshed'
/
comment on column USER_SUMMARIES.KNOWN_STALE is
'This summary is directly stale'
/
comment on column USER_SUMMARIES.SUMMARY is
'Indicates the presence of either aggregation or a GROUP BY'
/
create or replace public synonym USER_SUMMARIES for USER_SUMMARIES
/
grant select on USER_SUMMARIES to PUBLIC with grant option
/


rem DBA_SUMMARIES

create or replace view DBA_SUMMARIES
    (OWNER, SUMMARY_NAME, CONTAINER_OWNER, CONTAINER_NAME, 
     LAST_REFRESH_SCN, LAST_REFRESH_DATE, REFRESH_METHOD, SUMMARY,
     FULLREFRESHTIM, INCREFRESHTIM,
     CONTAINS_VIEWS, UNUSABLE, RESTRICTED_SYNTAX, INC_REFRESHABLE,
     KNOWN_STALE, QUERY_LEN, QUERY)
as
select u.name, o.name, u.name, s.containernam,
       s.lastrefreshscn, s.lastrefreshdate,
       decode (s.refreshmode, 0, 'NONE', 1, 'ANY', 2, 'INCREMENTAL', 3,'FULL'),
       decode(bitand(s.pflags, 25165824), 25165824, 'N', 'Y'),
       s.fullrefreshtim, s.increfreshtim,
       decode(bitand(s.pflags, 48), 0, 'N', 'Y'),
       decode(bitand(s.mflags, 64), 0, 'N', 'Y'), /* QSMQSUM_UNUSABLE */ 
       decode(bitand(s.pflags, 1294319), 0, 'Y', 'N'), 
       decode(bitand((select n.flag2 from sys.snap$ n 
                      where n.vname=s.containernam and n.sowner=u.name), 67108864), 
                     67108864,  /* primary CUBE mv? */
                     decode(bitand((select n2.flag from sys.snap$ n2
                            where n2.parent_sowner=u.name and n2.parent_vname=s.containernam), 256), 
                            256, 'N', 'Y'), /* Its child mv's properties determin INC_REFRESHABLE */
                     decode(bitand(s.pflags, 236879743), 0, 'Y', 'N')), 
       decode(bitand(s.mflags, 1), 0, 'N', 'Y'), /* QSMQSUM_KNOWNSTL */
       s.sumtextlen,s.sumtext
from sys.user$ u, sys.sum$ s, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = s.obj#
  and bitand(s.xpflags, 8388608) = 0  /* NOT REWRITE EQUIVALENCE SUMMARY */
/

comment on table DBA_SUMMARIES is
'Description of the summaries accessible to dba'
/
comment on column DBA_SUMMARIES.OWNER is
'Owner of the summary'
/
comment on column DBA_SUMMARIES.SUMMARY_NAME is
'Name of the summary'
/
comment on column DBA_SUMMARIES.CONTAINER_OWNER is
'Owner of the container table'
/
comment on column DBA_SUMMARIES.CONTAINER_NAME is
'Name of the container table for this summary'
/
comment on column DBA_SUMMARIES.LAST_REFRESH_SCN is
'The SCN of the last transaction to refresh the summary'
/
comment on column DBA_SUMMARIES.LAST_REFRESH_DATE is
'The date of the last refresh of the summary'
/
comment on column DBA_SUMMARIES.REFRESH_METHOD is
'User declared method of refresh for the summary'
/
comment on column DBA_SUMMARIES.FULLREFRESHTIM is
'The time that it took to fully refresh the summary'
/
comment on column DBA_SUMMARIES.INCREFRESHTIM is
'The time that it took to incrementally refresh the summary'
/
comment on column DBA_SUMMARIES.CONTAINS_VIEWS is
'This summary contains views in the FROM clause'
/
comment on column DBA_SUMMARIES.UNUSABLE is
'This summary is unusable, the build was deferred'
/
comment on column DBA_SUMMARIES.RESTRICTED_SYNTAX is
'This summary contains restrictive syntax'
/
comment on column DBA_SUMMARIES.INC_REFRESHABLE is
'This summary is not restricted from being incrementally refreshed'
/
comment on column DBA_SUMMARIES.KNOWN_STALE is
'This summary is directly stale'
/
comment on column DBA_SUMMARIES.SUMMARY is
'Indicates the presence of either aggregation or a GROUP BY'
/
create or replace public synonym DBA_SUMMARIES for DBA_SUMMARIES
/
grant select on DBA_SUMMARIES  to select_catalog_role
/

rem
rem Family of SUMMARY_AGGREGATES
rem
rem Note: Do not output summary aggregate info when there is
rem       set operator at the highest level 

rem DBA_SUMMARY_AGGREGATES

create or replace view DBA_SUMMARY_AGGREGATES
  (OWNER, SUMMARY_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   AGG_FUNCTION, DISTINCTFLAG, MEASURE)
as
select u.name, o.name, sa.sumcolpos#, c.name,
       decode(sa.aggfunction, 15, 'AVG', 16, 'SUM', 17, 'COUNT',
                              18, 'MIN', 19, 'MAX',
                              97, 'VARIANCE', 98, 'STDDEV',
                              440, 'USER'),
       decode(sa.flags, 0, 'N', 'Y'),
       sa.aggtext
from sys.sumagg$ sa, sys.obj$ o, sys.user$ u, sys.sum$ s, sys.col$ c
where sa.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sa.sumobj# = s.obj# 
  AND c.obj# = s.containerobj#
  AND c.col# = sa.containercol#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
REM comment on table DBA_SUMMARY_AGGREGATES is
REM 'Description of the summary aggregates accessible to dba'
REM /
comment on column DBA_SUMMARY_AGGREGATES.OWNER is
'Owner of the summary'
/
comment on column DBA_SUMMARY_AGGREGATES.SUMMARY_NAME is
'Name of the summary'
/
comment on column DBA_SUMMARY_AGGREGATES.POSITION_IN_SELECT is
'Position of this aggregated measure with the SELECT list'
/
comment on column DBA_SUMMARY_AGGREGATES.CONTAINER_COLUMN is
'Name of this column in the container table'
/
comment on column DBA_SUMMARY_AGGREGATES.AGG_FUNCTION is
'Name of the aggregation function, one of the following:
COUNT, SUM, MIN, MAX, AVG, VARIANCE, STDDEV'
/
comment on column DBA_SUMMARY_AGGREGATES.DISTINCTFLAG is
'Set to Y is this is a DISTINCT aggregation'
/
comment on column DBA_SUMMARY_AGGREGATES.MEASURE is
'The SQL text of the measure, excluding the aggregation function'
/
create or replace public synonym DBA_SUMMARY_AGGREGATES for DBA_SUMMARY_AGGREGATES
/
grant select on DBA_SUMMARY_AGGREGATES  to select_catalog_role
/

rem USER_SUMMARY_AGGREGATES

create or replace view USER_SUMMARY_AGGREGATES
  (OWNER, SUMMARY_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   AGG_FUNCTION, DISTINCTFLAG, MEASURE)
as
select u.name, o.name, sa.sumcolpos#, c.name,
       decode(sa.aggfunction, 15, 'AVG', 16, 'SUM', 17, 'COUNT',
                              18, 'MIN', 19, 'MAX',
                              97, 'VARIANCE', 98, 'STDDEV',
                              440, 'USER'),
       decode(sa.flags, 0, 'N', 'Y'),
       sa.aggtext
from sys.sumagg$ sa, sys.obj$ o, sys.user$ u, sys.sum$ s, sys.col$ c
where sa.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sa.sumobj# = s.obj# 
  AND c.obj# = s.containerobj#
  AND c.col# = sa.containercol#
  AND o.owner# = userenv('SCHEMAID')
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
REM comment on table USER_SUMMARY_AGGREGATES is
REM 'Description of the summary aggregates created by the user'
REM /
comment on column USER_SUMMARY_AGGREGATES.OWNER is
'Owner of the summary'
/
comment on column USER_SUMMARY_AGGREGATES.SUMMARY_NAME is
'Name of the summary'
/
comment on column USER_SUMMARY_AGGREGATES.POSITION_IN_SELECT is
'Position of this aggregated measure with the SELECT list'
/
comment on column USER_SUMMARY_AGGREGATES.CONTAINER_COLUMN is
'Name of this column in the container table'
/
comment on column USER_SUMMARY_AGGREGATES.AGG_FUNCTION is
'Name of the aggregation function, one of the following:
COUNT, SUM, MIN, MAX, AVG, VARIANCE, STDDEV'
/
comment on column USER_SUMMARY_AGGREGATES.DISTINCTFLAG is
'Set to Y is this is a DISTINCT aggregation'
/
comment on column USER_SUMMARY_AGGREGATES.MEASURE is
'The SQL text of the measure, excluding the aggregation function'
/
create or replace public synonym USER_SUMMARY_AGGREGATES for USER_SUMMARY_AGGREGATES
/
grant select on USER_SUMMARY_AGGREGATES  to PUBLIC with grant option 
/


rem ALL_SUMMARY_AGGREGATES

create or replace view ALL_SUMMARY_AGGREGATES
  (OWNER, SUMMARY_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   AGG_FUNCTION, DISTINCTFLAG, MEASURE)
as
select u.name, o.name, sa.sumcolpos#, c.name,
       decode(sa.aggfunction, 15, 'AVG', 16, 'SUM', 17, 'COUNT',
                              18, 'MIN', 19, 'MAX',
                              97, 'VARIANCE', 98, 'STDDEV',
                              440, 'USER'),
       decode(sa.flags, 0, 'N', 'Y'),
       sa.aggtext
from sys.sumagg$ sa, sys.obj$ o, sys.user$ u, sys.sum$ s, sys.col$ c
where sa.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sa.sumobj# = s.obj# 
  AND c.obj# = s.containerobj#
  AND c.col# = sa.containercol#
  AND (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */          
/

REM comment on table ALL_SUMMARY_AGGREGATES is
REM 'Description of the summary aggregates accessible to the user'
REM /
comment on column ALL_SUMMARY_AGGREGATES.OWNER is
'Owner of the summary'
/
comment on column ALL_SUMMARY_AGGREGATES.SUMMARY_NAME is
'Name of the summary'
/
comment on column ALL_SUMMARY_AGGREGATES.POSITION_IN_SELECT is
'Position of this aggregated measure with the SELECT list'
/
comment on column ALL_SUMMARY_AGGREGATES.CONTAINER_COLUMN is
'Name of this column in the container table'
/
comment on column ALL_SUMMARY_AGGREGATES.AGG_FUNCTION is
'Name of the aggregation function, one of the following:
COUNT, SUM, MIN, MAX, AVG, VARIANCE, STDDEV'
/
comment on column ALL_SUMMARY_AGGREGATES.DISTINCTFLAG is
'Set to Y is this is a DISTINCT aggregation'
/
comment on column ALL_SUMMARY_AGGREGATES.MEASURE is
'The SQL text of the measure, excluding the aggregation function'
/
create or replace public synonym ALL_SUMMARY_AGGREGATES for ALL_SUMMARY_AGGREGATES
/
grant select on ALL_SUMMARY_AGGREGATES  to PUBLIC with grant option 
/


rem
rem Family of SUMMARY_DETAIL_TABLES
rem Note: Do not output summary detail table info when
rem       there is a set operator at the highest level

rem ALL_SUMMARY_DETAIL_TABLES

create or replace view ALL_SUMMARY_DETAIL_TABLES
    (OWNER, SUMMARY_NAME, DETAIL_OWNER, DETAIL_RELATION, DETAIL_TYPE, 
     DETAIL_ALIAS)
as
select u.name, o.name, du.name,  do.name,
       decode (sd.detailobjtype, 1, 'TABLE', 2, 'VIEW',
                                3, 'SNAPSHOT', 4, 'CONTAINER', 'UNDEFINED'),
       sd.detailalias
from sys.user$ u, sys.sumdetail$ sd, sys.obj$ o, sys.obj$ do, 
sys.user$ du, sys.sum$ s
where o.owner# = u.user#
  and o.obj# = sd.sumobj#
  and do.obj# = sd.detailobj#
  and do.owner# = du.user#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  and s.obj# = sd.sumobj#
  and bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */  
  and bitand(sd.detaileut, 2147483648) = 0  /* NOT 2nd cube mv pct metadata */
/
REM comment on table ALL_SUMMARY_DETAIL_TABLES is
REM 'Description of the summary detail tables accessible to the user'
REM /
comment on column ALL_SUMMARY_DETAIL_TABLES.OWNER is
'Owner of the summary'
/
comment on column ALL_SUMMARY_DETAIL_TABLES.SUMMARY_NAME is
'Name of the summary'
/
comment on column ALL_SUMMARY_DETAIL_TABLES.DETAIL_OWNER is
'Owner of the detail relation'
/
comment on column ALL_SUMMARY_DETAIL_TABLES.DETAIL_RELATION is
'Name of the summary detail table'
/
comment on column ALL_SUMMARY_DETAIL_TABLES.DETAIL_TYPE is
'Type of summary detail table type'
/
comment on column ALL_SUMMARY_DETAIL_TABLES.DETAIL_ALIAS is
'Alias of the detail relation if used'

/
create or replace public synonym ALL_SUMMARY_DETAIL_TABLES for
    ALL_SUMMARY_DETAIL_TABLES
/
grant select on ALL_SUMMARY_DETAIL_TABLES to PUBLIC with grant option
/

rem USER_SUMMARY_DETAIL_TABLES

create or replace view USER_SUMMARY_DETAIL_TABLES
    (OWNER, SUMMARY_NAME, DETAIL_OWNER, DETAIL_RELATION, DETAIL_TYPE, 
     DETAIL_ALIAS)
as
select u.name, o.name, du.name,  do.name,
       decode (sd.detailobjtype, 1, 'TABLE', 2, 'VIEW',
                                3, 'SNAPSHOT', 4, 'CONTAINER', 'UNDEFINED'),
       sd.detailalias
from sys.user$ u, sys.sumdetail$ sd, sys.obj$ o, sys.obj$ do, 
sys.user$ du, sys.sum$ s
where o.owner# = u.user#
  and o.obj# = sd.sumobj#
  and do.obj# = sd.detailobj#
  and do.owner# = du.user#
  and o.owner# = userenv('SCHEMAID')
  and s.obj# = sd.sumobj#
  and bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */    
  and bitand(sd.detaileut, 2147483648) = 0  /* NOT 2nd cube mv pct metadata */
/
REM comment on table USER_SUMMARY_DETAIL_TABLES is
REM 'Description of the summary detail tables of the summaries created by the user'
REM /
comment on column USER_SUMMARY_DETAIL_TABLES.OWNER is
'Owner of the summary'
/
comment on column USER_SUMMARY_DETAIL_TABLES.SUMMARY_NAME is
'Name of the summary'
/
comment on column USER_SUMMARY_DETAIL_TABLES.DETAIL_OWNER is
'Owner of the detail relation'
/
comment on column USER_SUMMARY_DETAIL_TABLES.DETAIL_RELATION is
'Name of the summary detail table'
/
comment on column USER_SUMMARY_DETAIL_TABLES.DETAIL_TYPE is
'Type of summary detail table type'
/
comment on column USER_SUMMARY_DETAIL_TABLES.DETAIL_ALIAS is
'Alias of the detail relation if used'

/
create or replace public synonym USER_SUMMARY_DETAIL_TABLES for
    USER_SUMMARY_DETAIL_TABLES
/
grant select on USER_SUMMARY_DETAIL_TABLES to PUBLIC with grant option
/

rem DBA_SUMMARY_DETAIL_TABLES

create or replace view DBA_SUMMARY_DETAIL_TABLES
    (OWNER, SUMMARY_NAME, DETAIL_OWNER, DETAIL_RELATION, DETAIL_TYPE, 
     DETAIL_ALIAS)
as
select u.name, o.name, du.name,  do.name,
       decode (sd.detailobjtype, 1, 'TABLE', 2, 'VIEW',
                                3, 'SNAPSHOT', 4, 'CONTAINER', 'UNDEFINED'),
       sd.detailalias
from sys.user$ u, sys.sumdetail$ sd, sys.obj$ o, sys.obj$ do, 
     sys.user$ du, sys.sum$ s
where o.owner# = u.user#
  and o.obj# = sd.sumobj#
  and do.obj# = sd.detailobj#
  and do.owner# = du.user#
  and s.obj# = sd.sumobj#
  and bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */  
  and bitand(sd.detaileut, 2147483648) = 0  /* NOT 2nd cube mv pct metadata */
/
REM comment on table DBA_SUMMARY_DETAIL_TABLES is
REM 'Description of the summary detail tables accessible to dba'
REM /
comment on column DBA_SUMMARY_DETAIL_TABLES.OWNER is
'Owner of the summary'
/
comment on column DBA_SUMMARY_DETAIL_TABLES.SUMMARY_NAME is
'Name of the summary'
/
comment on column DBA_SUMMARY_DETAIL_TABLES.DETAIL_OWNER is
'Owner of the detail relation'
/
comment on column DBA_SUMMARY_DETAIL_TABLES.DETAIL_RELATION is
'Name of the summary detail table'
/
comment on column DBA_SUMMARY_DETAIL_TABLES.DETAIL_TYPE is
'Type of summary detail table type'
/
comment on column DBA_SUMMARY_DETAIL_TABLES.DETAIL_ALIAS is
'Alias of the detail relation if used'
/
create or replace public synonym DBA_SUMMARY_DETAIL_TABLES for DBA_SUMMARY_DETAIL_TABLES
/
grant select on DBA_SUMMARY_DETAIL_TABLES  to select_catalog_role
/

rem
rem FAMILY of SUMMARY_KEYS
rem Note: Do not output summary key info when there is
rem       a set operator at the highest level

rem DBA_SUMMARY_KEYS

create or replace view DBA_SUMMARY_KEYS
  (OWNER, SUMMARY_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   DETAILOBJ_OWNER, DETAILOBJ_NAME, DETAILOBJ_ALIAS,
   DETAILOBJ_TYPE, DETAILOBJ_COLUMN)
as 
select u1.name, o1.name, sk.sumcolpos#, c1.name,
       u2.name, o2.name, sd.detailalias,
       decode(sk.detailobjtype, 1, 'TABLE', 2, 'VIEW'), c2.name
from sys.sumkey$ sk, sys.obj$ o1, sys.user$ u1, sys.col$ c1, sys.sum$ s, 
     sys.sumdetail$ sd, sys.obj$ o2, sys.user$ u2, sys.col$ c2
where sk.sumobj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sk.sumobj# = s.obj#
  AND s.containerobj# = c1.obj#
  AND c1.col# = sk.containercol#
  AND sk.detailobj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sk.sumobj# = sd.sumobj#
  AND sk.detailobj# = sd.detailobj#
  AND sk.detailobj# = c2.obj#
  AND sk.detailcol# = c2.intcol#
  AND sk.instance# = sd.instance#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
  AND bitand(sk.detailcolfunction, 2147483648) = 0  /* NOT 2nd cube mv pct metadata */
/
REM comment on table DBA_SUMMARY_KEYS is
REM 'Description of the columns that appear in the GROUP BY
REM list of a summary accessible to dba'
REM /
comment on column DBA_SUMMARY_KEYS.OWNER is
'Owner of the summary'
/
comment on column DBA_SUMMARY_KEYS.SUMMARY_NAME is
'Name of the summary'
/
comment on column DBA_SUMMARY_KEYS.POSITION_IN_SELECT is
'Position of this key within the SELECT list'
/
comment on column DBA_SUMMARY_KEYS.CONTAINER_COLUMN is
'Name of the column in the container table'
/
comment on column DBA_SUMMARY_KEYS.DETAILOBJ_OWNER is
'Owner of the detail object'
/
comment on column DBA_SUMMARY_KEYS.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column DBA_SUMMARY_KEYS.DETAILOBJ_ALIAS is
'Alias of the detail object'
/
comment on column DBA_SUMMARY_KEYS.DETAILOBJ_TYPE is
'Type of the detail object: VIEW or TABLE'
/
comment on column DBA_SUMMARY_KEYS.DETAILOBJ_COLUMN is
'Name of the detail object column'

/
create or replace public synonym DBA_SUMMARY_KEYS for DBA_SUMMARY_KEYS
/
grant select on DBA_SUMMARY_KEYS to select_catalog_role
/

rem ALL_SUMMARY_KEYS

create or replace view ALL_SUMMARY_KEYS
  (OWNER, SUMMARY_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   DETAILOBJ_OWNER, DETAILOBJ_NAME, DETAILOBJ_ALIAS,
   DETAILOBJ_TYPE, DETAILOBJ_COLUMN)
as 
select u1.name, o1.name, sk.sumcolpos#, c1.name,
       u2.name, o2.name, sd.detailalias,
       decode(sk.detailobjtype, 1, 'TABLE', 2, 'VIEW'), c2.name
from sys.sumkey$ sk, sys.obj$ o1, sys.user$ u1, sys.col$ c1, sys.sum$ s, 
     sys.sumdetail$ sd, sys.obj$ o2, sys.user$ u2, sys.col$ c2
where sk.sumobj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sk.sumobj# = s.obj#
  AND s.containerobj# = c1.obj#
  AND c1.col# = sk.containercol#
  AND sk.detailobj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sk.sumobj# = sd.sumobj#
  AND sk.detailobj# = sd.detailobj#
  AND sk.detailobj# = c2.obj#
  AND sk.detailcol# = c2.intcol#
  AND sk.instance# = sd.instance#
  AND (o1.owner# = userenv('SCHEMAID')
       or o1.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
  AND bitand(sk.detailcolfunction, 2147483648) = 0  /* NOT 2nd cube mv pct metadata */
/
REM comment on table ALL_SUMMARY_KEYS is
REM 'Description of the columns that appear in the GROUP BY
REM list of a summary accessible to the user'
REM /
comment on column ALL_SUMMARY_KEYS.OWNER is
'Owner of the summary'
/
comment on column ALL_SUMMARY_KEYS.SUMMARY_NAME is
'Name of the summary'
/
comment on column ALL_SUMMARY_KEYS.POSITION_IN_SELECT is
'Position of this key within the SELECT list'
/
comment on column ALL_SUMMARY_KEYS.CONTAINER_COLUMN is
'Name of the column in the container table'
/
comment on column ALL_SUMMARY_KEYS.DETAILOBJ_OWNER is
'Owner of the detail object'
/
comment on column ALL_SUMMARY_KEYS.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column ALL_SUMMARY_KEYS.DETAILOBJ_ALIAS is
'Alias of the detail object'
/
comment on column ALL_SUMMARY_KEYS.DETAILOBJ_TYPE is
'Type of the detail object: VIEW or TABLE'
/
comment on column ALL_SUMMARY_KEYS.DETAILOBJ_COLUMN is
'Name of the detail object column'

/
create or replace public synonym ALL_SUMMARY_KEYS for ALL_SUMMARY_KEYS
/
grant select on ALL_SUMMARY_KEYS to PUBLIC with grant option
/

rem USER_SUMMARY_KEYS

create or replace view USER_SUMMARY_KEYS
  (OWNER, SUMMARY_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   DETAILOBJ_OWNER, DETAILOBJ_NAME, DETAILOBJ_ALIAS,
   DETAILOBJ_TYPE, DETAILOBJ_COLUMN)
as 
select u1.name, o1.name, sk.sumcolpos#, c1.name,
       u2.name, o2.name, sd.detailalias,
       decode(sk.detailobjtype, 1, 'TABLE', 2, 'VIEW'), c2.name
from sys.sumkey$ sk, sys.obj$ o1, sys.user$ u1, sys.col$ c1, sys.sum$ s, 
     sys.sumdetail$ sd, sys.obj$ o2, sys.user$ u2, sys.col$ c2
where sk.sumobj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sk.sumobj# = s.obj#
  AND s.containerobj# = c1.obj#
  AND c1.col# = sk.containercol#
  AND sk.detailobj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sk.sumobj# = sd.sumobj#
  AND sk.detailobj# = sd.detailobj#
  AND sk.detailobj# = c2.obj#
  AND sk.detailcol# = c2.intcol#
  AND sk.instance# = sd.instance#
  AND o1.owner# = userenv('SCHEMAID')
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
  AND bitand(sk.detailcolfunction, 2147483648) = 0  /* NOT 2nd cube mv pct metadata */
/
REM comment on table USER_SUMMARY_KEYS is
REM 'Description of the columns that appear in the GROUP BY
REM list of a summary  created by the user'
REM /
comment on column USER_SUMMARY_KEYS.OWNER is
'Owner of the summary'
/
comment on column USER_SUMMARY_KEYS.SUMMARY_NAME is
'Name of the summary'
/
comment on column USER_SUMMARY_KEYS.POSITION_IN_SELECT is
'Position of this key within the SELECT list'
/
comment on column USER_SUMMARY_KEYS.CONTAINER_COLUMN is
'Name of the column in the container table'
/
comment on column USER_SUMMARY_KEYS.DETAILOBJ_OWNER is
'Owner of the detail object'
/
comment on column USER_SUMMARY_KEYS.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column USER_SUMMARY_KEYS.DETAILOBJ_ALIAS is
'Alias of the detail object'
/
comment on column USER_SUMMARY_KEYS.DETAILOBJ_TYPE is
'Type of the detail object: VIEW or TABLE'
/
comment on column USER_SUMMARY_KEYS.DETAILOBJ_COLUMN is
'Name of the detail object column'

/
create or replace public synonym USER_SUMMARY_KEYS for USER_SUMMARY_KEYS
/
grant select on USER_SUMMARY_KEYS to PUBLIC with grant option
/


rem
rem FAMILY of SUMMARY_JOINS
rem Note: Do not output summary join info when there
rem       is a set operator at the highest level

rem DBA_SUMMARY_JOINS

create or replace view DBA_SUMMARY_JOINS
  (OWNER, SUMMARY_NAME, 
  DETAILOBJ1_OWNER, DETAILOBJ1_RELATION, DETAILOBJ1_COLUMN, OPERATOR,
  DETAILOBJ2_OWNER, DETAILOBJ2_RELATION, DETAILOBJ2_COLUMN)
as
select u.name, o.name, 
       u1.name, o1.name, c1.name, '=',
       u2.name, o2.name, c2.name
from sys.sumjoin$ sj, sys.obj$ o, sys.user$ u,
     sys.obj$ o1, sys.user$ u1, sys.col$ c1,
     sys.obj$ o2, sys.user$ u2, sys.col$ c2,
     sys.sum$ s
where sj.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sj.tab1obj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sj.tab1obj# = c1.obj#
  AND sj.tab1col# = c1.intcol#
  AND sj.tab2obj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sj.tab2obj# = c2.obj#
  AND sj.tab2col# = c2.intcol#
  AND s.obj# = sj.sumobj#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
REM comment on table DBA_SUMMARY_JOINS is
REM 'Description of a join between two columns in the
REM WHERE clause of a summary accessible to dba'
REM /
comment on column DBA_SUMMARY_JOINS.OWNER is
'Owner of the summary'
/
comment on column DBA_SUMMARY_JOINS.SUMMARY_NAME is
'Name of the summary'
/
comment on column DBA_SUMMARY_JOINS.DETAILOBJ1_OWNER is
'Owner of the 1st detail object'
/
comment on column DBA_SUMMARY_JOINS.DETAILOBJ1_RELATION is
'Name of the 1st detail object'
/
comment on column DBA_SUMMARY_JOINS. DETAILOBJ1_COLUMN is
'Name of the 1st detail object column'
/
comment on column DBA_SUMMARY_JOINS.OPERATOR is
'Name of the join operator. Currently only = is defined'
/
comment on column DBA_SUMMARY_JOINS.DETAILOBJ2_OWNER is
'Owner of the 2nd detail object'
/
comment on column DBA_SUMMARY_JOINS.DETAILOBJ2_RELATION is
'Name of the 2nd detail object'
/
comment on column DBA_SUMMARY_JOINS.DETAILOBJ2_COLUMN is
'Name of the 2nd detail object column'
/
create or replace public synonym DBA_SUMMARY_JOINS for DBA_SUMMARY_JOINS
/
grant select on DBA_SUMMARY_JOINS to select_catalog_role
/

rem ALL_SUMMARY_JOINS

create or replace view ALL_SUMMARY_JOINS
  (OWNER, SUMMARY_NAME, 
  DETAILOBJ1_OWNER, DETAILOBJ1_RELATION, DETAILOBJ1_COLUMN, OPERATOR,
  DETAILOBJ2_OWNER, DETAILOBJ2_RELATION, DETAILOBJ2_COLUMN)
as
select u.name, o.name, 
       u1.name, o1.name, c1.name, '=',
       u2.name, o2.name, c2.name
from sys.sumjoin$ sj, sys.obj$ o, sys.user$ u,
     sys.obj$ o1, sys.user$ u1, sys.col$ c1,
     sys.obj$ o2, sys.user$ u2, sys.col$ c2,
     sys.sum$ s
where sj.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sj.tab1obj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sj.tab1obj# = c1.obj#
  AND sj.tab1col# = c1.intcol#
  AND sj.tab2obj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sj.tab2obj# = c2.obj#
  AND sj.tab2col# = c2.intcol#
  AND (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  AND s.obj# = sj.sumobj#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
REM comment on table ALL_SUMMARY_JOINS is
REM 'Description of a join between two columns in the
REM WHERE clause of a summary accessible to the user'
REM /
comment on column ALL_SUMMARY_JOINS.OWNER is
'Owner of the summary'
/
comment on column ALL_SUMMARY_JOINS.SUMMARY_NAME is
'Name of the summary'
/
comment on column ALL_SUMMARY_JOINS.DETAILOBJ1_OWNER is
'Owner of the 1st detail object'
/
comment on column ALL_SUMMARY_JOINS.DETAILOBJ1_RELATION is
'Name of the 1st detail object'
/
comment on column ALL_SUMMARY_JOINS. DETAILOBJ1_COLUMN is
'Name of the 1st detail object column'
/
comment on column ALL_SUMMARY_JOINS.OPERATOR is
'Name of the join operator. Currently only = is defined'
/
comment on column ALL_SUMMARY_JOINS.DETAILOBJ2_OWNER is
'Owner of the 2nd detail object'
/
comment on column ALL_SUMMARY_JOINS.DETAILOBJ2_RELATION is
'Name of the 2nd detail object'
/
comment on column ALL_SUMMARY_JOINS.DETAILOBJ2_COLUMN is
'Name of the 2nd detail object column'
/
create or replace public synonym ALL_SUMMARY_JOINS for ALL_SUMMARY_JOINS
/
grant select on ALL_SUMMARY_JOINS to PUBLIC with grant option
/


rem USER_SUMMARY_JOINS

create or replace view USER_SUMMARY_JOINS
  (OWNER, SUMMARY_NAME, 
  DETAILOBJ1_OWNER, DETAILOBJ1_RELATION, DETAILOBJ1_COLUMN, OPERATOR,
  DETAILOBJ2_OWNER, DETAILOBJ2_RELATION, DETAILOBJ2_COLUMN)
as
select u.name, o.name, 
       u1.name, o1.name, c1.name, '=',
       u2.name, o2.name, c2.name
from sys.sumjoin$ sj, sys.obj$ o, sys.user$ u,
     sys.obj$ o1, sys.user$ u1, sys.col$ c1,
     sys.obj$ o2, sys.user$ u2, sys.col$ c2,
     sys.sum$ s
where sj.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sj.tab1obj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sj.tab1obj# = c1.obj#
  AND sj.tab1col# = c1.intcol#
  AND sj.tab2obj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sj.tab2obj# = c2.obj#
  AND sj.tab2col# = c2.intcol#
  AND o.owner# = userenv('SCHEMAID')
  AND s.obj# = sj.sumobj#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
REM comment on table USER_SUMMARY_JOINS is
REM 'Description of a join between two columns in the
REM WHERE clause of a summary created by the user'
REM /
comment on column USER_SUMMARY_JOINS.OWNER is
'Owner of the summary'
/
comment on column USER_SUMMARY_JOINS.SUMMARY_NAME is
'Name of the summary'
/
comment on column USER_SUMMARY_JOINS.DETAILOBJ1_OWNER is
'Owner of the 1st detail object'
/
comment on column USER_SUMMARY_JOINS.DETAILOBJ1_RELATION is
'Name of the 1st detail object'
/
comment on column USER_SUMMARY_JOINS. DETAILOBJ1_COLUMN is
'Name of the 1st detail object column'
/
comment on column USER_SUMMARY_JOINS.OPERATOR is
'Name of the join operator. Currently only = is defined'
/
comment on column USER_SUMMARY_JOINS.DETAILOBJ2_OWNER is
'Owner of the 2nd detail object'
/
comment on column USER_SUMMARY_JOINS.DETAILOBJ2_RELATION is
'Name of the 2nd detail object'
/
comment on column USER_SUMMARY_JOINS.DETAILOBJ2_COLUMN is
'Name of the 2nd detail object column'
/
create or replace public synonym USER_SUMMARY_JOINS for USER_SUMMARY_JOINS
/
grant select on USER_SUMMARY_JOINS to PUBLIC with grant option
/

rem aw1>

rem
rem Familiy of MVIEW_ANALYSIS views
rem

rem ALL_MVIEW_ANALYSIS

create or replace view ALL_MVIEW_ANALYSIS
    (OWNER, MVIEW_NAME, MVIEW_TABLE_OWNER, CONTAINER_NAME, 
     LAST_REFRESH_SCN, LAST_REFRESH_DATE, REFRESH_METHOD, SUMMARY,
     FULLREFRESHTIM, INCREFRESHTIM,
     CONTAINS_VIEWS, UNUSABLE, RESTRICTED_SYNTAX, INC_REFRESHABLE,
     KNOWN_STALE, INVALID, REWRITE_ENABLED, QUERY_LEN, QUERY, REVISION)
as
select u.name, o.name, u.name, s.containernam,
       s.lastrefreshscn, s.lastrefreshdate,
       decode (s.refreshmode, 0, 'NEVER', 1, 'FORCE', 2, 'FAST', 3,'COMPLETE'),
       decode(bitand(s.pflags, 25165824), 25165824, 'N', 'Y'),
       s.fullrefreshtim, s.increfreshtim,
       decode(bitand(s.pflags, 48), 0, 'N', 'Y'),
       decode(bitand(s.mflags, 64), 0, 'N', 'Y'), /* QSMQSUM_UNUSABLE */ 
       decode(bitand(s.pflags, 1294319), 0, 'Y', 'N'), 
       decode(bitand((select n.flag2 from sys.snap$ n 
                      where n.vname=s.containernam and n.sowner=u.name), 67108864), 
                     67108864,  /* primary CUBE mv? */
                     decode(bitand((select n2.flag from sys.snap$ n2
                            where n2.parent_sowner=u.name and n2.parent_vname=s.containernam), 256), 
                            256, 'N', 'Y'), /* Its child mv's properties determin INC_REFRESHABLE */
                     decode(bitand(s.pflags, 236879743), 0, 'Y', 'N')), 
       decode(bitand(s.mflags, 1), 0, 'N', 'Y'), /* QSMQSUM_KNOWNSTL */
       decode(o.status, 5, 'Y', 'N'),
       decode(bitand(s.mflags, 4), 0, 'Y', 'N'), /* QSMQSUM_DISABLED */
       s.sumtextlen,s.sumtext,
       s.metaversion/* Metadata revision number */
from sys.user$ u, sys.sum$ s, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = s.obj#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  and bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/


comment on table ALL_MVIEW_ANALYSIS is
'Description of the materialized views accessible to the user'
/
comment on column ALL_MVIEW_ANALYSIS.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.MVIEW_TABLE_OWNER is
'Owner of the container table'
/
comment on column ALL_MVIEW_ANALYSIS.CONTAINER_NAME is
'Name of the container table for this materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.LAST_REFRESH_SCN is
'The SCN of the last transaction to refresh the materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.LAST_REFRESH_DATE is
'The date of the last refresh of the materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.REFRESH_METHOD is
'User declared method of refresh for the materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.SUMMARY is
'Indicates if the materialized view includes the GROUP BY clause'
/
comment on column ALL_MVIEW_ANALYSIS.FULLREFRESHTIM is
'The time that it took to fully refresh the materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.INCREFRESHTIM is
'The time that it took to incrementally refresh the materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.CONTAINS_VIEWS is
'This materialized view contains views in the FROM clause'
/
comment on column ALL_MVIEW_ANALYSIS.UNUSABLE is
'This materialized view is unusable, the build was deferred'
/
comment on column ALL_MVIEW_ANALYSIS.RESTRICTED_SYNTAX is
'This materialized view contains restrictive syntax'
/
comment on column ALL_MVIEW_ANALYSIS.INC_REFRESHABLE is
'This materialized view is not restricted from being incrementally refreshed'
/
comment on column ALL_MVIEW_ANALYSIS.KNOWN_STALE is
'This materialized view is directly stale'
/
comment on column ALL_MVIEW_ANALYSIS.INVALID is
'Invalidity of the materialized view, Y = INVALID, N = VALID'
/
comment on column ALL_MVIEW_ANALYSIS.REWRITE_ENABLED is
'This materialized view is enabled for query rewrite'
/
comment on column ALL_MVIEW_ANALYSIS.QUERY is
'SELECT expression of the materialized view definition'
/
comment on column ALL_MVIEW_ANALYSIS.QUERY_LEN is
'The length (in bytes) of the query field'
/
comment on column ALL_MVIEW_ANALYSIS.REVISION is
'Reserved for internal use'
/
create or replace public synonym ALL_MVIEW_ANALYSIS for ALL_MVIEW_ANALYSIS
/
grant select on ALL_MVIEW_ANALYSIS to PUBLIC with grant option
/

rem USER_MVIEW_ANALYSIS

create or replace view USER_MVIEW_ANALYSIS
    (OWNER, MVIEW_NAME, MVIEW_TABLE_OWNER, CONTAINER_NAME, 
     LAST_REFRESH_SCN, LAST_REFRESH_DATE, REFRESH_METHOD, SUMMARY,
     FULLREFRESHTIM, INCREFRESHTIM,
     CONTAINS_VIEWS, UNUSABLE, RESTRICTED_SYNTAX, INC_REFRESHABLE,
     KNOWN_STALE,  INVALID, REWRITE_ENABLED, QUERY_LEN, QUERY, REVISION)
as
select u.name, o.name, u.name, s.containernam,
       s.lastrefreshscn, s.lastrefreshdate,
       decode (s.refreshmode, 0, 'NEVER', 1, 'FORCE', 2, 'FAST', 3,'COMPLETE'),
       decode(bitand(s.pflags, 25165824), 25165824, 'N', 'Y'),
       s.fullrefreshtim, s.increfreshtim,
       decode(bitand(s.pflags, 48), 0, 'N', 'Y'),
       decode(bitand(s.mflags, 64), 0, 'N', 'Y'), /* QSMQSUM_UNUSABLE */ 
       decode(bitand(s.pflags, 1294319), 0, 'Y', 'N'), 
       decode(bitand((select n.flag2 from sys.snap$ n 
                      where n.vname=s.containernam and n.sowner=u.name), 67108864), 
                     67108864,  /* primary CUBE mv? */
                     decode(bitand((select n2.flag from sys.snap$ n2
                            where n2.parent_sowner=u.name and n2.parent_vname=s.containernam), 256), 
                            256, 'N', 'Y'), /* Its child mv's properties determin INC_REFRESHABLE */
                     decode(bitand(s.pflags, 236879743), 0, 'Y', 'N')), 
       decode(bitand(s.mflags, 1), 0, 'N', 'Y'), /* QSMQSUM_KNOWNSTL */
       decode(o.status, 5, 'Y', 'N'),
       decode(bitand(s.mflags, 4), 0, 'Y', 'N'), /* QSMQSUM_DISABLED */
       s.sumtextlen,s.sumtext,
       s.metaversion/* Metadata revision number */
from sys.user$ u, sys.sum$ s, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = s.obj#
  and o.owner# = userenv('SCHEMAID')
  and bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
comment on table USER_MVIEW_ANALYSIS is
'Description of the materialized views created by the user'
/
comment on column USER_MVIEW_ANALYSIS.OWNER is
'Owner of the materialized view'
/
comment on column USER_MVIEW_ANALYSIS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column USER_MVIEW_ANALYSIS.MVIEW_TABLE_OWNER is
'Owner of the container table'
/
comment on column USER_MVIEW_ANALYSIS.CONTAINER_NAME is
'Name of the container table for this materialized view'
/
comment on column USER_MVIEW_ANALYSIS.LAST_REFRESH_SCN is
'The SCN of the last transaction to refresh the materialized view'
/
comment on column USER_MVIEW_ANALYSIS.LAST_REFRESH_DATE is
'The date of the last refresh of the materialized view'
/
comment on column USER_MVIEW_ANALYSIS.REFRESH_METHOD is
'User declared method of refresh for the materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.SUMMARY is
'Indicates if the materialized view includes the GROUP BY clause'
/
comment on column USER_MVIEW_ANALYSIS.FULLREFRESHTIM is
'The time that it took to fully refresh the materialized view'
/
comment on column USER_MVIEW_ANALYSIS.INCREFRESHTIM is
'The time that it took to incrementally refresh the materialized view'
/
comment on column USER_MVIEW_ANALYSIS.CONTAINS_VIEWS is
'This materialized view contains views in the FROM clause'
/
comment on column USER_MVIEW_ANALYSIS.UNUSABLE is
'This materialized view is unusable, the build was deferred'
/
comment on column USER_MVIEW_ANALYSIS.RESTRICTED_SYNTAX is
'This materialized view contains restrictive syntax'
/
comment on column USER_MVIEW_ANALYSIS.INC_REFRESHABLE is
'This materialized view is not restricted from being incrementally refreshed'
/
comment on column USER_MVIEW_ANALYSIS.KNOWN_STALE is
'This materialized view is directly stale'
/
comment on column USER_MVIEW_ANALYSIS.INVALID is
'Invalidity of the materialized view, Y = INVALID, N = VALID'
/
comment on column USER_MVIEW_ANALYSIS.REWRITE_ENABLED is
'This materialized view is enabled for query rewrite'
/
comment on column USER_MVIEW_ANALYSIS.QUERY is
'SELECT expression of the materialized view definition'
/
comment on column USER_MVIEW_ANALYSIS.QUERY_LEN is
'The length (in bytes) of the query field'
/
comment on column USER_MVIEW_ANALYSIS.REVISION is
'Reserved for internal use'
/
create or replace public synonym USER_MVIEW_ANALYSIS for USER_MVIEW_ANALYSIS
/
grant select on USER_MVIEW_ANALYSIS to PUBLIC with grant option
/


rem DBA_MVIEW_ANALYSIS

create or replace view DBA_MVIEW_ANALYSIS
    (OWNER, MVIEW_NAME, MVIEW_TABLE_OWNER, CONTAINER_NAME, 
     LAST_REFRESH_SCN, LAST_REFRESH_DATE, REFRESH_METHOD, SUMMARY,
     FULLREFRESHTIM, INCREFRESHTIM,
     CONTAINS_VIEWS, UNUSABLE, RESTRICTED_SYNTAX, INC_REFRESHABLE,
     KNOWN_STALE, INVALID, REWRITE_ENABLED, QUERY_LEN, QUERY, REVISION)
as
select u.name, o.name, u.name, s.containernam,
       s.lastrefreshscn, s.lastrefreshdate,
       decode (s.refreshmode, 0, 'NEVER', 1, 'FORCE', 2, 'FAST', 3,'COMPLETE'),
       decode(bitand(s.pflags, 25165824), 25165824, 'N', 'Y'),
       s.fullrefreshtim, s.increfreshtim,
       decode(bitand(s.pflags, 48), 0, 'N', 'Y'),
       decode(bitand(s.mflags, 64), 0, 'N', 'Y'), /* QSMQSUM_UNUSABLE */ 
       decode(bitand(s.pflags, 1294319), 0, 'Y', 'N'), 
       decode(bitand((select n.flag2 from sys.snap$ n 
                      where n.vname=s.containernam and n.sowner=u.name), 67108864), 
                     67108864,  /* primary CUBE mv? */
                     decode(bitand((select n2.flag from sys.snap$ n2
                            where n2.parent_sowner=u.name and n2.parent_vname=s.containernam), 256), 
                            256, 'N', 'Y'), /* Its child mv's properties determin INC_REFRESHABLE */
                     decode(bitand(s.pflags, 236879743), 0, 'Y', 'N')), 
       decode(bitand(s.mflags, 1), 0, 'N', 'Y'), /* QSMQSUM_KNOWNSTL */
       decode(o.status, 5, 'Y', 'N'),
       decode(bitand(s.mflags, 4), 0, 'Y', 'N'), /* QSMQSUM_DISABLED */
       s.sumtextlen,s.sumtext,
       s.metaversion/* Metadata revision number */
from sys.user$ u, sys.sum$ s, sys.obj$ o
where o.owner# = u.user#
  and o.obj# = s.obj#
  and bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */  
/

comment on table DBA_MVIEW_ANALYSIS is
'Description of the materialized views accessible to dba'
/
comment on column DBA_MVIEW_ANALYSIS.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEW_ANALYSIS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column DBA_MVIEW_ANALYSIS.MVIEW_TABLE_OWNER is
'Owner of the container table'
/
comment on column DBA_MVIEW_ANALYSIS.CONTAINER_NAME is
'Name of the container table for this materialized view'
/
comment on column DBA_MVIEW_ANALYSIS.LAST_REFRESH_SCN is
'The SCN of the last transaction to refresh the materialized view'
/
comment on column DBA_MVIEW_ANALYSIS.LAST_REFRESH_DATE is
'The date of the last refresh of the materialized view'
/
comment on column DBA_MVIEW_ANALYSIS.REFRESH_METHOD is
'User declared method of refresh for the materialized view'
/
comment on column ALL_MVIEW_ANALYSIS.SUMMARY is
'Indicates if the materialized view includes the GROUP BY clause'
/
comment on column DBA_MVIEW_ANALYSIS.FULLREFRESHTIM is
'The time that it took to fully refresh the materialized view'
/
comment on column DBA_MVIEW_ANALYSIS.INCREFRESHTIM is
'The time that it took to incrementally refresh the materialized view'
/
comment on column DBA_MVIEW_ANALYSIS.CONTAINS_VIEWS is
'This materialized view contains views in the FROM clause'
/
comment on column DBA_MVIEW_ANALYSIS.UNUSABLE is
'This materialized view is unusable, the build was deferred'
/
comment on column DBA_MVIEW_ANALYSIS.RESTRICTED_SYNTAX is
'This materialized view contains restrictive syntax'
/
comment on column DBA_MVIEW_ANALYSIS.INC_REFRESHABLE is
'This materialized view is not restricted from being incrementally refreshed'
/
comment on column DBA_MVIEW_ANALYSIS.KNOWN_STALE is
'This materialized view is directly stale'
/
comment on column DBA_MVIEW_ANALYSIS.INVALID is
'Invalidity of the materialized view, Y = INVALID, N = VALID'
/
comment on column DBA_MVIEW_ANALYSIS.REWRITE_ENABLED is
'This materialized view is enabled for query rewrite'
/
comment on column DBA_MVIEW_ANALYSIS.QUERY is
'SELECT expression of the materialized view definition'
/
comment on column DBA_MVIEW_ANALYSIS.QUERY_LEN is
'The length (in bytes) of the query field'
/
comment on column DBA_MVIEW_ANALYSIS.REVISION is
'Reserved for internal use'
/
create or replace public synonym DBA_MVIEW_ANALYSIS for DBA_MVIEW_ANALYSIS
/ 
grant select on DBA_MVIEW_ANALYSIS to select_catalog_role
/

rem
rem Family of MVIEW_AGGREGATES
rem Note: Do not output materialized view aggregate info
rem       when there is a set operator at the highest level

rem DBA_MVIEW_AGGREGATES

create or replace view DBA_MVIEW_AGGREGATES
  (OWNER, MVIEW_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   AGG_FUNCTION, DISTINCTFLAG, MEASURE)
as
select u.name, o.name, sa.sumcolpos#, c.name,
       decode(sa.aggfunction, 15, 'AVG', 16, 'SUM', 17, 'COUNT',
                              18, 'MIN', 19, 'MAX',
                              97, 'VARIANCE', 98, 'STDDEV',
                              440, 'USER'),
       decode(sa.flags, 0, 'N', 'Y'),
       sa.aggtext
from sys.sumagg$ sa, sys.obj$ o, sys.user$ u, sys.sum$ s, sys.col$ c
where sa.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sa.sumobj# = s.obj# 
  AND c.obj# = s.containerobj#
  AND c.col# = sa.containercol#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
comment on table DBA_MVIEW_AGGREGATES is
'Description of the materialized view aggregates accessible to dba'
/
comment on column DBA_MVIEW_AGGREGATES.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEW_AGGREGATES.MVIEW_NAME is
'Name of the materialized view'
/
comment on column DBA_MVIEW_AGGREGATES.POSITION_IN_SELECT is
'Position of this aggregated measure with the SELECT list'
/
comment on column DBA_MVIEW_AGGREGATES.CONTAINER_COLUMN is
'Name of this column in the container table'
/
comment on column DBA_MVIEW_AGGREGATES.AGG_FUNCTION is
'Name of the aggregation function, one of the following:
COUNT, SUM, MIN, MAX, AVG, VARIANCE, STDDEV'
/
comment on column DBA_MVIEW_AGGREGATES.DISTINCTFLAG is
'Set to Y is this is a DISTINCT aggregation'
/
comment on column DBA_MVIEW_AGGREGATES.MEASURE is
'The SQL text of the measure, excluding the aggregation function'
/
create or replace public synonym DBA_MVIEW_AGGREGATES for DBA_MVIEW_AGGREGATES
/
grant select on DBA_MVIEW_AGGREGATES  to select_catalog_role
/

rem USER_MVIEW_AGGREGATES

create or replace view USER_MVIEW_AGGREGATES
  (OWNER, MVIEW_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   AGG_FUNCTION, DISTINCTFLAG, MEASURE)
as
select u.name, o.name, sa.sumcolpos#, c.name,
       decode(sa.aggfunction, 15, 'AVG', 16, 'SUM', 17, 'COUNT',
                              18, 'MIN', 19, 'MAX',
                              97, 'VARIANCE', 98, 'STDDEV',
                              440, 'USER'),
       decode(sa.flags, 0, 'N', 'Y'),
       sa.aggtext
from sys.sumagg$ sa, sys.obj$ o, sys.user$ u, sys.sum$ s, sys.col$ c
where sa.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sa.sumobj# = s.obj# 
  AND c.obj# = s.containerobj#
  AND c.col# = sa.containercol#
  AND o.owner# = userenv('SCHEMAID')
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
comment on table USER_MVIEW_AGGREGATES is
'Description of the materialized view aggregates created by the user'
/
comment on column USER_MVIEW_AGGREGATES.OWNER is
'Owner of the materialized view'
/
comment on column USER_MVIEW_AGGREGATES.MVIEW_NAME is
'Name of the materialized view'
/
comment on column USER_MVIEW_AGGREGATES.POSITION_IN_SELECT is
'Position of this aggregated measure with the SELECT list'
/
comment on column USER_MVIEW_AGGREGATES.CONTAINER_COLUMN is
'Name of this column in the container table'
/
comment on column USER_MVIEW_AGGREGATES.AGG_FUNCTION is
'Name of the aggregation function, one of the following:
COUNT, SUM, MIN, MAX, AVG, VARIANCE, STDDEV'
/
comment on column USER_MVIEW_AGGREGATES.DISTINCTFLAG is
'Set to Y is this is a DISTINCT aggregation'
/
comment on column USER_MVIEW_AGGREGATES.MEASURE is
'The SQL text of the measure, excluding the aggregation function'
/
create or replace public synonym USER_MVIEW_AGGREGATES for USER_MVIEW_AGGREGATES
/
grant select on USER_MVIEW_AGGREGATES  to PUBLIC with grant option 
/


rem ALL_MVIEW_AGGREGATES

create or replace view ALL_MVIEW_AGGREGATES
  (OWNER, MVIEW_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   AGG_FUNCTION, DISTINCTFLAG, MEASURE)
as
select u.name, o.name, sa.sumcolpos#, c.name,
       decode(sa.aggfunction, 15, 'AVG', 16, 'SUM', 17, 'COUNT',
                              18, 'MIN', 19, 'MAX',
                              97, 'VARIANCE', 98, 'STDDEV',
                              440, 'USER'),
       decode(sa.flags, 0, 'N', 'Y'),
       sa.aggtext
from sys.sumagg$ sa, sys.obj$ o, sys.user$ u, sys.sum$ s, sys.col$ c
where sa.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sa.sumobj# = s.obj# 
  AND c.obj# = s.containerobj#
  AND c.col# = sa.containercol#
  AND (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */                 
/

comment on table ALL_MVIEW_AGGREGATES is
'Description of the materialized view aggregates accessible to the user'
/
comment on column ALL_MVIEW_AGGREGATES.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEW_AGGREGATES.MVIEW_NAME is
'Name of the materialized view'
/
comment on column ALL_MVIEW_AGGREGATES.POSITION_IN_SELECT is
'Position of this aggregated measure with the SELECT list'
/
comment on column ALL_MVIEW_AGGREGATES.CONTAINER_COLUMN is
'Name of this column in the container table'
/
comment on column ALL_MVIEW_AGGREGATES.AGG_FUNCTION is
'Name of the aggregation function, one of the following:
COUNT, SUM, MIN, MAX, AVG, VARIANCE, STDDEV'
/
comment on column ALL_MVIEW_AGGREGATES.DISTINCTFLAG is
'Set to Y is this is a DISTINCT aggregation'
/
comment on column ALL_MVIEW_AGGREGATES.MEASURE is
'The SQL text of the measure, excluding the aggregation function'
/
create or replace public synonym ALL_MVIEW_AGGREGATES for ALL_MVIEW_AGGREGATES
/
grant select on ALL_MVIEW_AGGREGATES  to PUBLIC with grant option 
/


rem
rem Family of MVIEW_DETAIL_RELATIONS
rem Note: Do not output materialized view detail relation
rem       info when there is a set operator at the highest
rem       level

rem ALL_MVIEW_DETAIL_RELATIONS

create or replace view ALL_MVIEW_DETAIL_RELATIONS
    (OWNER, MVIEW_NAME, DETAILOBJ_OWNER, DETAILOBJ_NAME, DETAILOBJ_TYPE, 
     DETAILOBJ_ALIAS, DETAILOBJ_PCT, NUM_FRESH_PCT_PARTITIONS, 
     NUM_STALE_PCT_PARTITIONS)
as
select u.name, o.name, du.name,  do.name,
       decode (sd.detailobjtype, 1, 'TABLE', 2, 'VIEW',
                                3, 'SNAPSHOT', 4, 'CONTAINER', 'UNDEFINED'),
       sd.detailalias,
           /* whether this is a PCT refresh enabled primary CUBE MV */
       (decode(bitand(s.xpflags, 8589934592), 0, 
                (decode(sd.detaileut, 0, 'N', 'Y')), 
               /* If there's a qualifying secondary cube mv row for this detailtab,
                  it's pct refreshable, otherwise, no. */
                (decode((select count(*) 
                          from  sumdetail$ sd2 
                          where sd.sumobj#=sd2.sumobj# and sd.detailobj#=sd2.detailobj# 
                            and sd2.detaileut > 268435456), 
                        0, 'N', 'Y')))
       ) as DETAILOBJ_PCT,
     (select num_fresh_partns from
       (select sumobj#, detailobj#,
               sum(num_fresh_partitions) as num_fresh_partns,
               sum(num_stale_partitions) as num_stale_partns
       from
        (select sumobj#, detailobj#,
                decode(partn_state, 'FRESH', partn_count, 0) 
                as num_fresh_partitions,
                decode(partn_state, 'STALE', partn_count, 0) 
                as num_stale_partitions
         from 
          (select sumobj#, detailobj#, partn_state, count(*) as partn_count from 
            (select sumobj#, detailobj#, 
                    (case when partn_scn is NULL then 'FRESH' 
                     when partn_scn < mv_scn
                     then 'FRESH' else 'STALE' end) partn_state
             from
              (select s.obj# as sumobj#, sd.detailobj#, 
                      s.lastrefreshscn as mv_scn, 
                      t.obj# pobj#, t.obj# as sub_pobj#, t.spare1 as partn_scn
               from sys.sum$ s, sys.sumdetail$ sd, sys.tabpart$ t 
               where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
               union 
               select s.sumobj#, s.detailobj#, s.mv_scn, 
                      s.pobj# pobj#, t.obj# as sub_pobj#,t.spare1 as partn_scn
               from  tabsubpart$ t, 
               (select s.obj# as sumobj#, sd.detailobj# as detailobj#, 
                       s.lastrefreshscn as mv_scn, 
                       t.obj# pobj#, t.spare1 as partn_scn 
                from sys.sum$ s, sys.sumdetail$ sd, sys.tabcompart$ t, 
                     sys.obj$ o
                where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#) s 
             where t.pobj# = s.pobj#))
           group by sumobj#,detailobj#,partn_state)) 
         group by sumobj#,detailobj#) nfsp 
         where nfsp.sumobj# = s.obj# and nfsp.detailobj# = sd.detailobj#) 
         as NUM_FRESH_PCT_PARTNS,
     (select num_stale_partns from
       (select sumobj#, detailobj#,
               sum(num_fresh_partitions) as num_fresh_partns,
               sum(num_stale_partitions) as num_stale_partns
       from
        (select sumobj#, detailobj#,
                decode(partn_state, 'FRESH', partn_count, 0) 
                as num_fresh_partitions,
                decode(partn_state, 'STALE', partn_count, 0) 
                as num_stale_partitions
         from 
          (select sumobj#, detailobj#, partn_state, count(*) as partn_count from 
            (select sumobj#, detailobj#, 
                    (case when partn_scn is NULL then 'FRESH' 
                     when partn_scn < mv_scn
                     then 'FRESH' else 'STALE' end) partn_state
             from
              (select s.obj# as sumobj#, sd.detailobj#, 
                      s.lastrefreshscn as mv_scn, 
                      t.obj# pobj#, t.obj# as sub_pobj#, t.spare1 as partn_scn
               from sys.sum$ s, sys.sumdetail$ sd, sys.tabpart$ t 
               where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
               union 
               select s.sumobj#, s.detailobj#, s.mv_scn, 
                      s.pobj# pobj#, t.obj# as sub_pobj#,t.spare1 as partn_scn
               from  tabsubpart$ t, 
               (select s.obj# as sumobj#, sd.detailobj# as detailobj#, 
                       s.lastrefreshscn as mv_scn, 
                       t.obj# pobj#, t.spare1 as partn_scn 
                from sys.sum$ s, sys.sumdetail$ sd, sys.tabcompart$ t, 
                     sys.obj$ o
                where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#) s 
             where t.pobj# = s.pobj#))
           group by sumobj#,detailobj#,partn_state)) 
         group by sumobj#,detailobj#) nfsp 
         where nfsp.sumobj# = s.obj# and nfsp.detailobj# = sd.detailobj#) 
         as NUM_STALE_PCT_PARTNS         
from sys.user$ u, sys.sumdetail$ sd, sys.obj$ o, sys.obj$ do, 
sys.user$ du, sys.sum$ s
where o.owner# = u.user#
  and o.obj# = sd.sumobj#
  and do.obj# = sd.detailobj#
  and do.owner# = du.user#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               )
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  AND s.obj# = sd.sumobj#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
  AND bitand(sd.detaileut, 2147483648) = 0  /* NO secondary CUBE MV rows */ 
/
comment on table ALL_MVIEW_DETAIL_RELATIONS is
'Description of the materialized view detail tables accessible to the user'
/
comment on column ALL_MVIEW_DETAIL_RELATIONS.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEW_DETAIL_RELATIONS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column ALL_MVIEW_DETAIL_RELATIONS.DETAILOBJ_OWNER is
'Owner of the detail relation'
/
comment on column ALL_MVIEW_DETAIL_RELATIONS.DETAILOBJ_NAME is
'Name of the materialized view detail table'
/
comment on column ALL_MVIEW_DETAIL_RELATIONS.DETAILOBJ_TYPE is
'Type of materialized view detail table type'
/
comment on column ALL_MVIEW_DETAIL_RELATIONS.DETAILOBJ_ALIAS is
'Alias of the detail relation if used'

/
create or replace public synonym ALL_MVIEW_DETAIL_RELATIONS for
    ALL_MVIEW_DETAIL_RELATIONS
/
grant select on ALL_MVIEW_DETAIL_RELATIONS to PUBLIC with grant option
/

rem USER_MVIEW_DETAIL_RELATIONS

create or replace view USER_MVIEW_DETAIL_RELATIONS
    (OWNER, MVIEW_NAME, DETAILOBJ_OWNER, DETAILOBJ_NAME, DETAILOBJ_TYPE, 
     DETAILOBJ_ALIAS, DETAILOBJ_PCT, NUM_FRESH_PCT_PARTITIONS, 
     NUM_STALE_PCT_PARTITIONS)
as
select u.name, o.name, du.name,  do.name,
       decode (sd.detailobjtype, 1, 'TABLE', 2, 'VIEW',
                                3, 'SNAPSHOT', 4, 'CONTAINER', 'UNDEFINED'),
       sd.detailalias,
           /* whether this is a PCT refresh enabled primary CUBE MV */
       (decode(bitand(s.xpflags, 8589934592), 0, 
                (decode(sd.detaileut, 0, 'N', 'Y')), 
               /* If there's a qualifying secondary cube mv row for this detailtab,
                  it's pct refreshable, otherwise, no. */
                (decode((select count(*) 
                          from  sumdetail$ sd2 
                          where sd.sumobj#=sd2.sumobj# and sd.detailobj#=sd2.detailobj# 
                            and sd2.detaileut > 268435456), 
                        0, 'N', 'Y')))
       ) as DETAILOBJ_PCT,
     (select num_fresh_partns from
       (select sumobj#, detailobj#,
               sum(num_fresh_partitions) as num_fresh_partns,
               sum(num_stale_partitions) as num_stale_partns
       from
        (select sumobj#, detailobj#,
                decode(partn_state, 'FRESH', partn_count, 0) 
                as num_fresh_partitions,
                decode(partn_state, 'STALE', partn_count, 0) 
                as num_stale_partitions
         from 
          (select sumobj#, detailobj#, partn_state, count(*) as partn_count from 
            (select sumobj#, detailobj#, 
                    (case when partn_scn is NULL then 'FRESH' 
                     when partn_scn < mv_scn
                     then 'FRESH' else 'STALE' end) partn_state
             from
              (select s.obj# as sumobj#, sd.detailobj#, 
                      s.lastrefreshscn as mv_scn, 
                      t.obj# pobj#, t.obj# as sub_pobj#, t.spare1 as partn_scn
               from sys.sum$ s, sys.sumdetail$ sd, sys.tabpart$ t 
               where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
               union 
               select s.sumobj#, s.detailobj#, s.mv_scn, 
                      s.pobj# pobj#, t.obj# as sub_pobj#,t.spare1 as partn_scn
               from  tabsubpart$ t, 
               (select s.obj# as sumobj#, sd.detailobj# as detailobj#, 
                       s.lastrefreshscn as mv_scn, 
                       t.obj# pobj#, t.spare1 as partn_scn 
                from sys.sum$ s, sys.sumdetail$ sd, sys.tabcompart$ t, 
                     sys.obj$ o
                where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#) s 
             where t.pobj# = s.pobj#))
           group by sumobj#,detailobj#,partn_state)) 
         group by sumobj#,detailobj#) nfsp 
         where nfsp.sumobj# = s.obj# and nfsp.detailobj# = sd.detailobj#) 
         as NUM_FRESH_PCT_PARTNS,
     (select num_stale_partns from
       (select sumobj#, detailobj#,
               sum(num_fresh_partitions) as num_fresh_partns,
               sum(num_stale_partitions) as num_stale_partns
       from
        (select sumobj#, detailobj#,
                decode(partn_state, 'FRESH', partn_count, 0) 
                as num_fresh_partitions,
                decode(partn_state, 'STALE', partn_count, 0) 
                as num_stale_partitions
         from 
          (select sumobj#, detailobj#, partn_state, count(*) as partn_count from 
            (select sumobj#, detailobj#, 
                    (case when partn_scn is NULL then 'FRESH' 
                     when partn_scn < mv_scn
                     then 'FRESH' else 'STALE' end) partn_state
             from
              (select s.obj# as sumobj#, sd.detailobj#, 
                      s.lastrefreshscn as mv_scn, 
                      t.obj# pobj#, t.obj# as sub_pobj#, t.spare1 as partn_scn
               from sys.sum$ s, sys.sumdetail$ sd, sys.tabpart$ t 
               where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
               union 
               select s.sumobj#, s.detailobj#, s.mv_scn, 
                      s.pobj# pobj#, t.obj# as sub_pobj#,t.spare1 as partn_scn
               from  tabsubpart$ t, 
               (select s.obj# as sumobj#, sd.detailobj# as detailobj#, 
                       s.lastrefreshscn as mv_scn, 
                       t.obj# pobj#, t.spare1 as partn_scn 
                from sys.sum$ s, sys.sumdetail$ sd, sys.tabcompart$ t, 
                     sys.obj$ o
                where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#) s 
             where t.pobj# = s.pobj#))
           group by sumobj#,detailobj#,partn_state)) 
         group by sumobj#,detailobj#) nfsp 
         where nfsp.sumobj# = s.obj# and nfsp.detailobj# = sd.detailobj#) 
         as NUM_STALE_PCT_PARTNS         
from sys.user$ u, sys.sumdetail$ sd, sys.obj$ o, sys.obj$ do, 
sys.user$ du, sys.sum$ s
where o.owner# = u.user#
  and o.obj# = sd.sumobj#
  and do.obj# = sd.detailobj#
  and do.owner# = du.user#
  and o.owner# = userenv('SCHEMAID')
  and s.obj# = sd.sumobj#
  and bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */  
  and bitand(sd.detaileut, 2147483648) = 0  /* NO secondary CUBE MV rows */ 
/
comment on table USER_MVIEW_DETAIL_RELATIONS is
'Description of the materialized view detail tables of the materialized 
views created by the user'
/
comment on column USER_MVIEW_DETAIL_RELATIONS.OWNER is
'Owner of the materialized view'
/
comment on column USER_MVIEW_DETAIL_RELATIONS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column USER_MVIEW_DETAIL_RELATIONS.DETAILOBJ_OWNER is
'Owner of the detail relation'
/
comment on column USER_MVIEW_DETAIL_RELATIONS.DETAILOBJ_NAME is
'Name of the materialized view detail table'
/
comment on column USER_MVIEW_DETAIL_RELATIONS.DETAILOBJ_TYPE is
'Type of materialized view detail table type'
/
comment on column USER_MVIEW_DETAIL_RELATIONS.DETAILOBJ_ALIAS is
'Alias of the detail relation if used'

/
create or replace public synonym USER_MVIEW_DETAIL_RELATIONS for
    USER_MVIEW_DETAIL_RELATIONS
/
grant select on USER_MVIEW_DETAIL_RELATIONS to PUBLIC with grant option
/

rem DBA_MVIEW_DETAIL_RELATIONS

create or replace view DBA_MVIEW_DETAIL_RELATIONS
    (OWNER, MVIEW_NAME, DETAILOBJ_OWNER, DETAILOBJ_NAME, DETAILOBJ_TYPE, 
     DETAILOBJ_ALIAS, DETAILOBJ_PCT, NUM_FRESH_PCT_PARTITIONS, 
     NUM_STALE_PCT_PARTITIONS)
as
select u.name, o.name, du.name,  do.name,
       decode (sd.detailobjtype, 1, 'TABLE', 2, 'VIEW',
                                3, 'SNAPSHOT', 4, 'CONTAINER', 'UNDEFINED'),
       sd.detailalias,
           /* whether this is a PCT refresh enabled primary CUBE MV */
       (decode(bitand(s.xpflags, 8589934592), 0, 
                (decode(sd.detaileut, 0, 'N', 'Y')), 
               /* If there's a qualifying secondary cube mv row for this detailtab,
                  it's pct refreshable, otherwise, no. */
                (decode((select count(*) 
                          from  sumdetail$ sd2 
                          where sd.sumobj#=sd2.sumobj# and sd.detailobj#=sd2.detailobj# 
                            and sd2.detaileut > 268435456), 
                        0, 'N', 'Y')))
       ) as DETAILOBJ_PCT,
     (select num_fresh_partns from
       (select sumobj#, detailobj#,
               sum(num_fresh_partitions) as num_fresh_partns,
               sum(num_stale_partitions) as num_stale_partns
       from
        (select sumobj#, detailobj#,
                decode(partn_state, 'FRESH', partn_count, 0) 
                as num_fresh_partitions,
                decode(partn_state, 'STALE', partn_count, 0) 
                as num_stale_partitions
         from 
          (select sumobj#, detailobj#, partn_state, count(*) as partn_count from 
            (select sumobj#, detailobj#, 
                    (case when partn_scn is NULL then 'FRESH' 
                     when partn_scn < mv_scn
                     then 'FRESH' else 'STALE' end) partn_state
             from
              (select s.obj# as sumobj#, sd.detailobj#, 
                      s.lastrefreshscn as mv_scn, 
                      t.obj# pobj#, t.obj# as sub_pobj#, t.spare1 as partn_scn
               from sys.sum$ s, sys.sumdetail$ sd, sys.tabpart$ t 
               where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
               union 
               select s.sumobj#, s.detailobj#, s.mv_scn, 
                      s.pobj# pobj#, t.obj# as sub_pobj#,t.spare1 as partn_scn
               from  tabsubpart$ t, 
               (select s.obj# as sumobj#, sd.detailobj# as detailobj#, 
                       s.lastrefreshscn as mv_scn, 
                       t.obj# pobj#, t.spare1 as partn_scn 
                from sys.sum$ s, sys.sumdetail$ sd, sys.tabcompart$ t, 
                     sys.obj$ o
                where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#) s 
             where t.pobj# = s.pobj#))
           group by sumobj#,detailobj#,partn_state)) 
         group by sumobj#,detailobj#) nfsp 
         where nfsp.sumobj# = s.obj# and nfsp.detailobj# = sd.detailobj#) 
         as NUM_FRESH_PCT_PARTNS,
     (select num_stale_partns from
       (select sumobj#, detailobj#,
               sum(num_fresh_partitions) as num_fresh_partns,
               sum(num_stale_partitions) as num_stale_partns
       from
        (select sumobj#, detailobj#,
                decode(partn_state, 'FRESH', partn_count, 0) 
                as num_fresh_partitions,
                decode(partn_state, 'STALE', partn_count, 0) 
                as num_stale_partitions
         from 
          (select sumobj#, detailobj#, partn_state, count(*) as partn_count from 
            (select sumobj#, detailobj#, 
                    (case when partn_scn is NULL then 'FRESH' 
                     when partn_scn < mv_scn
                     then 'FRESH' else 'STALE' end) partn_state
             from
              (select s.obj# as sumobj#, sd.detailobj#, 
                      s.lastrefreshscn as mv_scn, 
                      t.obj# pobj#, t.obj# as sub_pobj#, t.spare1 as partn_scn
               from sys.sum$ s, sys.sumdetail$ sd, sys.tabpart$ t 
               where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#
               union 
               select s.sumobj#, s.detailobj#, s.mv_scn, 
                      s.pobj# pobj#, t.obj# as sub_pobj#,t.spare1 as partn_scn
               from  tabsubpart$ t, 
               (select s.obj# as sumobj#, sd.detailobj# as detailobj#, 
                       s.lastrefreshscn as mv_scn, 
                       t.obj# pobj#, t.spare1 as partn_scn 
                from sys.sum$ s, sys.sumdetail$ sd, sys.tabcompart$ t, 
                     sys.obj$ o
                where s.obj# = sd.sumobj# and sd.detailobj# = t.bo#) s 
             where t.pobj# = s.pobj#))
           group by sumobj#,detailobj#,partn_state)) 
         group by sumobj#,detailobj#) nfsp 
         where nfsp.sumobj# = s.obj# and nfsp.detailobj# = sd.detailobj#) 
         as NUM_STALE_PCT_PARTNS         
from sys.user$ u, sys.sumdetail$ sd, sys.obj$ o, sys.obj$ do, 
     sys.user$ du, sys.sum$ s
where o.owner# = u.user#
  and o.obj# = sd.sumobj#
  and do.obj# = sd.detailobj#
  and do.owner# = du.user#
  and s.obj# = sd.sumobj#
  and bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */    
  and bitand(sd.detaileut, 2147483648) = 0  /* NO secondary CUBE MV rows */ 
/
comment on table DBA_MVIEW_DETAIL_RELATIONS is
'Description of the materialized view detail tables accessible to dba'
/
comment on column DBA_MVIEW_DETAIL_RELATIONS.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEW_DETAIL_RELATIONS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column DBA_MVIEW_DETAIL_RELATIONS.DETAILOBJ_OWNER is
'Owner of the detail relation'
/
comment on column DBA_MVIEW_DETAIL_RELATIONS.DETAILOBJ_NAME is
'Name of the materialized view detail table'
/
comment on column DBA_MVIEW_DETAIL_RELATIONS.DETAILOBJ_TYPE is
'Type of materialized detail table type'
/
comment on column DBA_MVIEW_DETAIL_RELATIONS.DETAILOBJ_ALIAS is
'Alias of the detail relation if used'

/
create or replace public synonym DBA_MVIEW_DETAIL_RELATIONS for DBA_MVIEW_DETAIL_RELATIONS
/
grant select on DBA_MVIEW_DETAIL_RELATIONS  to select_catalog_role
/

rem
rem FAMILY of MVIEW_KEYS
rem Note: Do not output materialized view key info when there
rem       is a set operator at the highest level

rem DBA_MVIEW_KEYS

create or replace view DBA_MVIEW_KEYS
  (OWNER, MVIEW_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   DETAILOBJ_OWNER, DETAILOBJ_NAME, DETAILOBJ_ALIAS,
   DETAILOBJ_TYPE, DETAILOBJ_COLUMN)
as 
select distinct u1.name, o1.name, sk.sumcolpos#, c1.name,
       u2.name, o2.name, sd.detailalias,
       decode(sk.detailobjtype, 1, 'TABLE', 2, 'VIEW'), c2.name
from sys.sumkey$ sk, sys.obj$ o1, sys.user$ u1, sys.col$ c1, sys.sum$ s, 
     sys.sumdetail$ sd, sys.obj$ o2, sys.user$ u2, sys.col$ c2
where sk.sumobj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sk.sumobj# = s.obj#
  AND s.containerobj# = c1.obj#
  AND c1.col# = sk.containercol#
  AND sk.detailobj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sk.sumobj# = sd.sumobj#
  AND sk.detailobj# = sd.detailobj#
  AND sk.detailobj# = c2.obj#
  AND sk.detailcol# = c2.intcol#
  AND sk.instance# = sd.instance#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */   
  AND bitand(sk.detailcolfunction, 2147483648) = 0 
  AND bitand(sd.detaileut, 2147483648) = 0  /* NOT 2nd cube mv pct metadata */
/
comment on table DBA_MVIEW_KEYS is
'Description of the columns that appear in the GROUP BY
list of a materialized view accessible to dba'
/
comment on column DBA_MVIEW_KEYS.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEW_KEYS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column DBA_MVIEW_KEYS.POSITION_IN_SELECT is
'Position of this key within the SELECT list'
/
comment on column DBA_MVIEW_KEYS.CONTAINER_COLUMN is
'Name of the column in the container table'
/
comment on column DBA_MVIEW_KEYS.DETAILOBJ_OWNER is
'Owner of the detail object'
/
comment on column DBA_MVIEW_KEYS.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column DBA_MVIEW_KEYS.DETAILOBJ_ALIAS is
'Alias of the detail object'
/
comment on column DBA_MVIEW_KEYS.DETAILOBJ_TYPE is
'Type of the detail object: VIEW or TABLE'
/
comment on column DBA_MVIEW_KEYS.DETAILOBJ_COLUMN is
'Name of the detail object column'

/
create or replace public synonym DBA_MVIEW_KEYS for DBA_MVIEW_KEYS
/
grant select on DBA_MVIEW_KEYS to select_catalog_role
/

rem ALL_MVIEW_KEYS

create or replace view ALL_MVIEW_KEYS
  (OWNER, MVIEW_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   DETAILOBJ_OWNER, DETAILOBJ_NAME, DETAILOBJ_ALIAS,
   DETAILOBJ_TYPE, DETAILOBJ_COLUMN)
as 
select distinct u1.name, o1.name, sk.sumcolpos#, c1.name,
       u2.name, o2.name, sd.detailalias,
       decode(sk.detailobjtype, 1, 'TABLE', 2, 'VIEW'), c2.name
from sys.sumkey$ sk, sys.obj$ o1, sys.user$ u1, sys.col$ c1, sys.sum$ s, 
     sys.sumdetail$ sd, sys.obj$ o2, sys.user$ u2, sys.col$ c2
where sk.sumobj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sk.sumobj# = s.obj#
  AND s.containerobj# = c1.obj#
  AND c1.col# = sk.containercol#
  AND sk.detailobj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sk.sumobj# = sd.sumobj#
  AND sk.detailobj# = sd.detailobj#
  AND sk.detailobj# = c2.obj#
  AND sk.detailcol# = c2.intcol#
  AND sk.instance# = sd.instance#
  AND (o1.owner# = userenv('SCHEMAID')
       or o1.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
  AND bitand(sk.detailcolfunction, 2147483648) = 0 
  AND bitand(sd.detaileut, 2147483648) = 0  /* NOT 2nd cube mv pct metadata */
/
comment on table ALL_MVIEW_KEYS is
'Description of the columns that appear in the GROUP BY
list of a materialized view accessible to the user'
/
comment on column ALL_MVIEW_KEYS.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEW_KEYS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column ALL_MVIEW_KEYS.POSITION_IN_SELECT is
'Position of this key within the SELECT list'
/
comment on column ALL_MVIEW_KEYS.CONTAINER_COLUMN is
'Name of the column in the container table'
/
comment on column ALL_MVIEW_KEYS.DETAILOBJ_OWNER is
'Owner of the detail object'
/
comment on column ALL_MVIEW_KEYS.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column ALL_MVIEW_KEYS.DETAILOBJ_ALIAS is
'Alias of the detail object'
/
comment on column ALL_MVIEW_KEYS.DETAILOBJ_TYPE is
'Type of the detail object: VIEW or TABLE'
/
comment on column ALL_MVIEW_KEYS.DETAILOBJ_COLUMN is
'Name of the detail object column'

/
create or replace public synonym ALL_MVIEW_KEYS for ALL_MVIEW_KEYS
/
grant select on ALL_MVIEW_KEYS to PUBLIC with grant option
/

rem USER_MVIEW_KEYS

create or replace view USER_MVIEW_KEYS
  (OWNER, MVIEW_NAME, POSITION_IN_SELECT, CONTAINER_COLUMN,
   DETAILOBJ_OWNER, DETAILOBJ_NAME, DETAILOBJ_ALIAS,
   DETAILOBJ_TYPE, DETAILOBJ_COLUMN)
as 
select distinct u1.name, o1.name, sk.sumcolpos#, c1.name,
       u2.name, o2.name, sd.detailalias,
       decode(sk.detailobjtype, 1, 'TABLE', 2, 'VIEW'), c2.name
from sys.sumkey$ sk, sys.obj$ o1, sys.user$ u1, sys.col$ c1, sys.sum$ s, 
     sys.sumdetail$ sd, sys.obj$ o2, sys.user$ u2, sys.col$ c2
where sk.sumobj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sk.sumobj# = s.obj#
  AND s.containerobj# = c1.obj#
  AND c1.col# = sk.containercol#
  AND sk.detailobj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sk.sumobj# = sd.sumobj#
  AND sk.detailobj# = sd.detailobj#
  AND sk.detailobj# = c2.obj#
  AND sk.detailcol# = c2.intcol#
  AND sk.instance# = sd.instance#
  AND o1.owner# = userenv('SCHEMAID')
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
  AND bitand(sk.detailcolfunction, 2147483648) = 0 
  AND bitand(sd.detaileut, 2147483648) = 0  /* NOT 2nd cube mv pct metadata */
/
comment on table USER_MVIEW_KEYS is
'Description of the columns that appear in the GROUP BY
list of a materialized view  created by the user'
/
comment on column USER_MVIEW_KEYS.OWNER is
'Owner of the materialized view'
/
comment on column USER_MVIEW_KEYS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column USER_MVIEW_KEYS.POSITION_IN_SELECT is
'Position of this key within the SELECT list'
/
comment on column USER_MVIEW_KEYS.CONTAINER_COLUMN is
'Name of the column in the container table'
/
comment on column USER_MVIEW_KEYS.DETAILOBJ_OWNER is
'Owner of the detail object'
/
comment on column USER_MVIEW_KEYS.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column USER_MVIEW_KEYS.DETAILOBJ_ALIAS is
'Alias of the detail object'
/
comment on column USER_MVIEW_KEYS.DETAILOBJ_TYPE is
'Type of the detail object: VIEW or TABLE'
/
comment on column USER_MVIEW_KEYS.DETAILOBJ_COLUMN is
'Name of the detail object column'

/
create or replace public synonym USER_MVIEW_KEYS for USER_MVIEW_KEYS
/
grant select on USER_MVIEW_KEYS to PUBLIC with grant option
/


rem
rem FAMILY of MVIEW_JOINS
rem Note: Do not output materialized view join info when
rem       there is a set operator at the highest level

rem DBA_MVIEW_JOINS

create or replace view DBA_MVIEW_JOINS
  (OWNER, MVIEW_NAME, 
  DETAILOBJ1_OWNER, DETAILOBJ1_RELATION, DETAILOBJ1_COLUMN, OPERATOR,
  OPERATOR_TYPE, DETAILOBJ2_OWNER, DETAILOBJ2_RELATION, DETAILOBJ2_COLUMN)
as
select u.name, o.name, 
       u1.name, o1.name, c1.name, '=',
       decode(sj.flags, 0, 'I', 1, 'L', 2, 'R'),
       u2.name, o2.name, c2.name
from sys.sumjoin$ sj, sys.obj$ o, sys.user$ u,
     sys.obj$ o1, sys.user$ u1, sys.col$ c1,
     sys.obj$ o2, sys.user$ u2, sys.col$ c2,
     sys.sum$ s
where sj.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sj.tab1obj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sj.tab1obj# = c1.obj#
  AND sj.tab1col# = c1.intcol#
  AND sj.tab2obj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sj.tab2obj# = c2.obj#
  AND sj.tab2col# = c2.intcol#
  AND s.obj# = sj.sumobj#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
comment on table DBA_MVIEW_JOINS is
'Description of a join between two columns in the
WHERE clause of a materialized view accessible to dba'
/
comment on column DBA_MVIEW_JOINS.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEW_JOINS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column DBA_MVIEW_JOINS.DETAILOBJ1_OWNER is
'Owner of the 1st detail object'
/
comment on column DBA_MVIEW_JOINS.DETAILOBJ1_RELATION is
'Name of the 1st detail object'
/
comment on column DBA_MVIEW_JOINS.DETAILOBJ1_COLUMN is
'Name of the 1st detail object column'
/
comment on column DBA_MVIEW_JOINS.OPERATOR is
'Name of the join operator. Currently only = is defined'
/
comment on column DBA_MVIEW_JOINS.OPERATOR_TYPE is
'Indicates inner or outer join. I = inner join, L = DETAILOBJ1 table
is the left side of an outer join'
/
comment on column DBA_MVIEW_JOINS.DETAILOBJ2_OWNER is
'Owner of the 2nd detail object'
/
comment on column DBA_MVIEW_JOINS.DETAILOBJ2_RELATION is
'Name of the 2nd detail object'
/
comment on column DBA_MVIEW_JOINS.DETAILOBJ2_COLUMN is
'Name of the 2nd detail object column'
/

create or replace public synonym DBA_MVIEW_JOINS for DBA_MVIEW_JOINS
/
grant select on DBA_MVIEW_JOINS to select_catalog_role
/

rem ALL_MVIEW_JOINS

create or replace view ALL_MVIEW_JOINS
  (OWNER, MVIEW_NAME, 
  DETAILOBJ1_OWNER, DETAILOBJ1_RELATION, DETAILOBJ1_COLUMN, OPERATOR,
  OPERATOR_TYPE, DETAILOBJ2_OWNER, DETAILOBJ2_RELATION, DETAILOBJ2_COLUMN)
as
select u.name, o.name, 
       u1.name, o1.name, c1.name, '=',
       decode(sj.flags, 0, 'I', 1, 'L', 2, 'R'),
       u2.name, o2.name, c2.name
from sys.sumjoin$ sj, sys.obj$ o, sys.user$ u,
     sys.obj$ o1, sys.user$ u1, sys.col$ c1,
     sys.obj$ o2, sys.user$ u2, sys.col$ c2,
     sys.sum$ s
where sj.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sj.tab1obj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sj.tab1obj# = c1.obj#
  AND sj.tab1col# = c1.intcol#
  AND sj.tab2obj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sj.tab2obj# = c2.obj#
  AND sj.tab2col# = c2.intcol#
  AND (o.owner# = userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where grantee# in ( select kzsrorol
                                 from x$kzsro
                               ) 
            )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )
      )
  AND s.obj# = sj.sumobj#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
comment on table ALL_MVIEW_JOINS is
'Description of a join between two columns in the
WHERE clause of a materialized view accessible to the user'
/
comment on column ALL_MVIEW_JOINS.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEW_JOINS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column ALL_MVIEW_JOINS.DETAILOBJ1_OWNER is
'Owner of the 1st detail object'
/
comment on column ALL_MVIEW_JOINS.DETAILOBJ1_RELATION is
'Name of the 1st detail object'
/
comment on column ALL_MVIEW_JOINS.DETAILOBJ1_COLUMN is
'Name of the 1st detail object column'
/
comment on column ALL_MVIEW_JOINS.OPERATOR is
'Name of the join operator. Currently only = is defined'
/
comment on column DBA_MVIEW_JOINS.OPERATOR_TYPE is
'Indicates inner or outer join. I = inner join, L = DETAILOBJ1 table
is the left side of an outer join'
/
comment on column ALL_MVIEW_JOINS.DETAILOBJ2_OWNER is
'Owner of the 2nd detail object'
/
comment on column ALL_MVIEW_JOINS.DETAILOBJ2_RELATION is
'Name of the 2nd detail object'
/
comment on column ALL_MVIEW_JOINS.DETAILOBJ2_COLUMN is
'Name of the 2nd detail object column'
/
create or replace public synonym ALL_MVIEW_JOINS for ALL_MVIEW_JOINS
/
grant select on ALL_MVIEW_JOINS to PUBLIC with grant option
/


rem USER_MVIEW_JOINS

create or replace view USER_MVIEW_JOINS
  (OWNER, MVIEW_NAME, 
  DETAILOBJ1_OWNER, DETAILOBJ1_RELATION, DETAILOBJ1_COLUMN, OPERATOR,
  OPERATOR_TYPE, DETAILOBJ2_OWNER, DETAILOBJ2_RELATION, DETAILOBJ2_COLUMN)
as
select u.name, o.name, 
       u1.name, o1.name, c1.name, '=',
       decode(sj.flags, 0, 'I', 1, 'L', 2, 'R'),
       u2.name, o2.name, c2.name
from sys.sumjoin$ sj, sys.obj$ o, sys.user$ u,
     sys.obj$ o1, sys.user$ u1, sys.col$ c1,
     sys.obj$ o2, sys.user$ u2, sys.col$ c2,
     sys.sum$ s  
where sj.sumobj# = o.obj#
  AND o.owner# = u.user#
  AND sj.tab1obj# = o1.obj#
  AND o1.owner# = u1.user#
  AND sj.tab1obj# = c1.obj#
  AND sj.tab1col# = c1.intcol#
  AND sj.tab2obj# = o2.obj#
  AND o2.owner# = u2.user#
  AND sj.tab2obj# = c2.obj#
  AND sj.tab2col# = c2.intcol#
  AND o.owner# = userenv('SCHEMAID')
  AND s.obj# = sj.sumobj#
  AND bitand(s.xpflags, 8388608) = 0 /* NOT REWRITE EQUIVALENCE SUMMARY */
/
comment on table USER_MVIEW_JOINS is
'Description of a join between two columns in the
WHERE clause of a materialized view created by the user'
/
comment on column USER_MVIEW_JOINS.OWNER is
'Owner of the materialized view'
/
comment on column USER_MVIEW_JOINS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column USER_MVIEW_JOINS.DETAILOBJ1_OWNER is
'Owner of the 1st detail object'
/
comment on column USER_MVIEW_JOINS.DETAILOBJ1_RELATION is
'Name of the 1st detail object'
/
comment on column USER_MVIEW_JOINS.DETAILOBJ1_COLUMN is
'Name of the 1st detail object column'
/
comment on column USER_MVIEW_JOINS.OPERATOR is
'Name of the join operator. Currently only = is defined'
/
comment on column DBA_MVIEW_JOINS.OPERATOR_TYPE is
'Indicates inner or outer join. I = inner join, L = DETAILOBJ1 table
is the left side of an outer join, R = DETAILOBJ2 table is the right
side of an outer join'
/
comment on column USER_MVIEW_JOINS.DETAILOBJ2_OWNER is
'Owner of the 2nd detail object'
/
comment on column USER_MVIEW_JOINS.DETAILOBJ2_RELATION is
'Name of the 2nd detail object'
/
comment on column USER_MVIEW_JOINS.DETAILOBJ2_COLUMN is
'Name of the 2nd detail object column'
/
create or replace public synonym USER_MVIEW_JOINS for USER_MVIEW_JOINS
/
grant select on USER_MVIEW_JOINS to PUBLIC with grant option
/


REM
REM DBA_MVIEW_COMMENTS
REM   
  
create or replace view DBA_MVIEW_COMMENTS
    (OWNER, MVIEW_NAME, COMMENTS)
as
select u.name, o.name, c.comment$
from sys.obj$ o, sys.user$ u, sys.com$ c, sys.tab$ t
  where o.owner# = u.user# AND o.type# = 2 
  and (bitand(t.property, 67108864) = 67108864)         /*mv container table */
  and o.obj# = c.obj#(+)
  and c.col#(+) is NULL
  and o.obj# = t.obj#
/
  
create or replace public synonym DBA_MVIEW_COMMENTS for DBA_MVIEW_COMMENTS
/
grant select on DBA_MVIEW_COMMENTS to select_catalog_role
/ 

comment on table DBA_MVIEW_COMMENTS is
'Comments on all materialized views in the database'
/
comment on column DBA_MVIEW_COMMENTS.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEW_COMMENTS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column DBA_MVIEW_COMMENTS.COMMENTS is
'Comment on the materialized view'
/


REM
REM ALL_MVIEW_COMMENTS
REM   
  
create or replace view ALL_MVIEW_COMMENTS
    (OWNER, MVIEW_NAME, COMMENTS)
as
select u.name, o.name, c.comment$
from sys.obj$ o, sys.user$ u, sys.com$ c, sys.tab$ t
  where o.owner# = u.user# AND o.type# = 2 
  and (bitand(t.property, 67108864) = 67108864)         /*mv container table */
  and o.obj# = c.obj#(+)
  and c.col#(+) is NULL
  and o.obj# = t.obj#
  and (o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                         from x$kzsro
                                       )
                  )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-173 /* CREATE ANY MV */,
                                        -174 /* ALTER ANY MV */,
                                        -175 /* DROP ANY MV */)
                  )
      )
/
  
create or replace public synonym ALL_MVIEW_COMMENTS for ALL_MVIEW_COMMENTS
/
grant select on ALL_MVIEW_COMMENTS to PUBLIC with grant option
/

comment on table ALL_MVIEW_COMMENTS is
'Comments on materialized views accessible to the user'
/
comment on column ALL_MVIEW_COMMENTS.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEW_COMMENTS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column ALL_MVIEW_COMMENTS.COMMENTS is
'Comment on the materialized view'
/

REM
REM USER_MVIEW_COMMENTS
REM   
  
create or replace view USER_MVIEW_COMMENTS
    (MVIEW_NAME, COMMENTS)
as
select o.name, c.comment$
from sys.obj$ o, sys.com$ c, sys.tab$ t
  where o.owner# = userenv('SCHEMAID')
  and o.type# = 2 
  and (bitand(t.property, 67108864) = 67108864)         /*mv container table */
  and o.obj# = c.obj#(+)
  and c.col#(+) is NULL
  and o.obj# = t.obj#
/
  
create or replace public synonym USER_MVIEW_COMMENTS for USER_MVIEW_COMMENTS
/
grant select on USER_MVIEW_COMMENTS to PUBLIC with grant option
/ 

comment on table USER_MVIEW_COMMENTS is
'Comments on materialized views owned by the user'
/
comment on column USER_MVIEW_COMMENTS.MVIEW_NAME is
'Name of the materialized view'
/
comment on column USER_MVIEW_COMMENTS.COMMENTS is
'Comment on the materialized view'
/

rem aw1<

  

rem
rem FAMILY of REFRESH_DEPENDENCIES
rem
rem Note: Must be in sync with literals AOPIXCS... and KGLTSUMM
rem
create or replace view ALL_REFRESH_DEPENDENCIES
  (OWNER,TABLE_NAME,PARENT_OBJECT_TYPE,OLDEST_REFRESH_SCN,OLDEST_REFRESH_DATE)
as 
select u.name, o.name, 'MATERIALIZED VIEW', dep.lastrefreshscn, 
       dep.lastrefreshdate 
from (select dt.obj#, 
             min(dt.lastrefreshscn) as lastrefreshscn, 
             min(dt.lastrefreshdate) as lastrefreshdate
      from
           (select d.p_obj# as obj#, s.lastrefreshscn, s.lastrefreshdate
            from sumdep$ d, sum$ s, obj$ do
            where d.sumobj# = s.obj#
              and d.sumobj# = do.obj#
              and do.type# IN (4, 42)
            union  
            select sl.tableobj# as obj#, 
                   decode(0, 1, 2, NULL) as lastrefreshscn, 
                   sl.oldest  as lastrefreshdate
            from snap_loadertime$ sl) dt
      group by dt.obj#) dep, obj$ o, user$ u
where o.obj# = dep.obj#
  and o.owner# = u.user#
  and (o.owner# = userenv('SCHEMAID')
       or o.obj# in (select oa.obj# from sys.objauth$ oa
                     where grantee# in (select kzsrorol from x$kzsro)
                    )
       or /* user has system privileges */
         exists (select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
                 )                     
       )
/
comment on table ALL_REFRESH_DEPENDENCIES is
'Description of the detail tables that materialized views depend on for
refresh'
/
comment on column ALL_REFRESH_DEPENDENCIES.OWNER is
'Owner of the dependent table'
/
comment on column ALL_REFRESH_DEPENDENCIES.TABLE_NAME is
'Name of the dependent table'
/
comment on column ALL_REFRESH_DEPENDENCIES.PARENT_OBJECT_TYPE is
'Materialized View'
/
comment on column ALL_REFRESH_DEPENDENCIES.OLDEST_REFRESH_SCN is
'The oldest scn of a dependent materialized view'
/
comment on column ALL_REFRESH_DEPENDENCIES.OLDEST_REFRESH_DATE is
'The oldest date scn of a dependent materialized view'
/
create or replace public synonym ALL_REFRESH_DEPENDENCIES for
    ALL_REFRESH_DEPENDENCIES
/
grant select on ALL_REFRESH_DEPENDENCIES to PUBLIC with grant option
/
create table system.mview$_adv_workload
  (
  queryid#              number not null,        /* primary key */
  collectionid#         number not null,        /* collection id */
  collecttime           date not null,          /* collect time */
  application           varchar(64),            /* application name */
  cardinality           number,                 /* sum card of base tables */
  resultsize            number,                 /* result size in bytes */
  uname                 varchar(30) not null,   /* user submitting the query */
  qdate                 date,                   /* lastuse date of the query */
  priority              number,                 /* priority of the query */
  exec_time             number,                 /* query response time */
  sql_text              long not null,          /* full sql text */
  sql_textlen           number not null,        /* sql text size */ 
  sql_hash              number,                 /* server generated hash */
  sql_addr              raw(16),                /* lib-cache address */
  frequency             number,                 /* query frequency */
  constraint mview$_adv_workload_pk primary key(queryid#)
  )  
/
  
comment on table system.mview$_adv_workload is
  'Shared workload repository for DBA users of summary advisor'
/  

create index system.mview$_adv_workload_idx_01
   on system.mview$_adv_workload (collectionid#, queryid#)
/

create table system.mview$_adv_basetable
  (
  collectionid#         number not null,        /* Collection id number */
  queryid#              number not null,        /* Current query id number */
  owner                 varchar(30),            /* Owner of referenced table */
  table_name            varchar(30),            /* Referenced table or view */
  table_type            number,                 /* 0 = Table,  1 = View */
  constraint mview$_adv_basetable_fk foreign key (queryid#)
  references system.mview$_adv_workload(queryid#)
  )
/
comment on table system.mview$_adv_basetable is
  'Base tables refered by a query'
/

create index system.mview$_adv_basetable_idx_01
   on system.mview$_adv_basetable (queryid#)
/

create table system.mview$_adv_sqldepend
   (
   collectionid#     number,                    /* workload collection id */
   inst_id           number,                    /* server instance id */
   from_address      raw(16),
   from_hash         number,
   to_owner          varchar2(64),
   to_name           varchar2(1000),
   to_type           number,
   cardinality       number
   )
/

create index system.mview$_adv_sqldepend_idx_01
   on system.mview$_adv_sqldepend
   (collectionid#,from_address,from_hash,inst_id)
/

comment on table system.mview$_adv_sqldepend is
  'Temporary table for workload collections'
/

create table system.mview$_adv_pretty
   (
   queryid#          number,                    /* User-defined query id */
   sql_text          long                       /* Pretty-printed text */
   )
/

create index system.mview$_adv_pretty_idx_01
   on system.mview$_adv_pretty
   (queryid#)
/

comment on table system.mview$_adv_pretty is
  'Table for sql parsing'
/


create table system.mview$_adv_temp
   (
      id#          number,                    /* Unique id*/
      seq#         NUMBER,                    /* Relative sequence number */
      text         LONG                       /* Text */
   )
/

create index system.mview$_adv_temp_idx_01
   on system.mview$_adv_temp
   (id#,seq#)
/

comment on table system.mview$_adv_temp is
  'Table for temporary data'
/


create table system.mview$_adv_filter
  (
  filterid#             number not null,        /* filter id */
  subfilternum#         number not null,        /* sub-filter number */
  subfiltertype         number not null,        /* sub-filter type */
  str_value             varchar2(1028),         /* string paramter */
  num_value1            number,                 /* numerical lower bound */
  num_value2            number,                 /* numerical upper bound */
  date_value1           date,                   /* lower date */
  date_value2           date,                   /* upper date */
  constraint mview$_adv_filter_pk primary key(filterid#, subfilternum#)
  )
/
comment on table system.mview$_adv_filter is
  'Table for workload filter definition'
/  

create table system.mview$_adv_log
  (
  runid#                number,                 /* run id */
  filterid#             number,                 /* filter id */
  run_begin             date,                   /* begin time of current run */
  run_end               date,                   /* end time of current run */
  run_type              number,                 /* type of calls */
  uname                 varchar2(30),           /* calling user */
  status                number not null,        /* current operation state */
  message               varchar2(2000),         /* progress message */
  completed             number,                 /* # of operations completed */
  total                 number,                 /* total # of operations */
  error_code            varchar2(20),           /* Error status code */
  constraint mview$_adv_log_pk primary key(runid#)
  )
/
comment on table system.mview$_adv_log is
  'Log all calls to summary advisory functions'
/     

create table system.mview$_adv_filterinstance
  (
  runid#                number not null,        /* run id */
  filterid#             number,                 /* filter id */
  subfilternum#         number,                 /* sub-filter number */
  subfiltertype         number,                 /* sub-filter type */
  str_value             varchar2(1028),         /* string paramter */
  num_value1            number,                 /* numerical lower bound */
  num_value2            number,                 /* numerical upper bound */
  date_value1           date,                   /* lower date */
  date_value2           date,                   /* upper date */
  constraint mview$_adv_filterinstance_fk foreign key(runid#) 
  references system.mview$_adv_log(runid#)
  )
/
comment on table system.mview$_adv_filterinstance is
  'Table for workload filter instance definition'
/  

create table system.mview$_adv_level 
  (
  runid#                number not null,        /* runid */
  levelid#              number not null,        /* leve id */
  dimobj#               number,                 /* iff level is from dim */
  flags                 number not null,        /* level flag */    
  tblobj#               number not null,        /* table object number */    
  columnlist            raw(70) not null,       /* canonical form */
  levelname             varchar2(30),           /* iff level is from dim */
  constraint mview$_adv_level_pk primary key(runid#, levelid#),
  constraint mview$_adv_level_fk foreign key(runid#) 
  references system.mview$_adv_log(runid#)
  )
/
comment on table system.mview$_adv_level is
  'Level definition'
/     
  
create table system.mview$_adv_rollup
  (
  runid#                number not null,        /* run id */
  clevelid#             number not null,        /* child-side levelid */
  plevelid#             number not null,        /* parent-side levelid */
  flags                 number not null,        /* FD: intra, JK: joinkey */
  constraint mview$_adv_rollup_pk primary key (runid#, clevelid#, plevelid#),
  constraint mview$_adv_rollup_fk foreign key (runid#)
  references system.mview$_adv_log(runid#),
  constraint mview$_adv_rollup_cfk foreign key (runid#, clevelid#)
  references system.mview$_adv_level(runid#, levelid#),
  constraint mview$_adv_rollup_pfk foreign key (runid#, plevelid#)
  references system.mview$_adv_level(runid#, levelid#)
  )
/

comment on table system.mview$_adv_rollup is
  'Each row repesents either a functional dependency or join-key relationship'
/

create table system.mview$_adv_ajg
  (
  ajgid#                number not null,        /* primary key */
  runid#                number not null,        /* run id */
  ajgdeslen             number not null,        /* AJG descriptor length */
  ajgdes                long raw not null,      /* AJG joins */
  hashvalue             number not null,        /* hash value for descriptor */
  frequency             number,                 /* frequency */
  constraint mview$_adv_ajg_pk primary key (ajgid#),
  constraint mview$_adv_ajg_fk foreign key (runid#)
  references system.mview$_adv_log(runid#)
  )
/
comment on table system.mview$_adv_ajg is
  'Anchor-join graph representation'
/  

create table system.mview$_adv_fjg
  (
  fjgid#                number not null,        /* primary key */
  ajgid#                number not null,        /* identify AJG it belongs */
  fjgdeslen             number not null,        /* FJG descriptor length */
  fjgdes                long raw not null,      /* FJG joins */
  hashvalue             number not null,        /* hash value for descriptor */
  frequency             number,                 /* frequency */
  constraint mview$_adv_fjg_pk primary key (fjgid#),
  constraint mview$_adv_fjg_fk foreign key (ajgid#)
  references system.mview$_adv_ajg(ajgid#) 
  )
/
comment on table system.mview$_adv_fjg is
  'Representation for query join sub-graph not in AJG '
/     
  
create table system.mview$_adv_gc
  (
  gcid#                 number not null,        /* primary key */
  fjgid#                number not null,        /* identify FJG it belongs */
  gcdeslen              number not null,        /* GC descriptor length */
  gcdes                 long raw not null,      /* grouping columns */
  hashvalue             number not null,        /* hash value for descriptor */
  frequency             number,                 /* frequency */
  constraint mview$_adv_gc_pk primary key (gcid#),
  constraint mview$_adv_gc_fk foreign key (fjgid#)
  references system.mview$_adv_fjg(fjgid#) 
  )
/
comment on table system.mview$_adv_gc is
  'Group-by columns of a query'
/

create table system.mview$_adv_clique
  (
  cliqueid#             number not null,        /* primary key */
  runid#                number not null,        /* run id */
  cliquedeslen          number not null,        /* clique descriptor length */
  cliquedes             long raw not null,      /* clique descriptor */
  hashvalue             number not null,        /* hash value for descriptor */
  frequency             number not null,        /* frequency */
  bytecost              number not null,        /* cost of computing the query*/
  rowsize               number not null,        /* average row size */
  numrows               number not null,        /* number of rows */
  constraint mview$_adv_clique_pk primary key (cliqueid#),
  constraint mview$_adv_clique_fk foreign key (runid#)
  references system.mview$_adv_log(runid#) 
  )
/
comment on table system.mview$_adv_clique is
  'Table for storing canonical form of Clique queries'
/  

create table system.mview$_adv_eligible
  (
  sumobjn#              number not null,        /* summary object number */
  runid#                number not null,        /* run id */
  bytecost              number not null,        /* cost of matched tables */
  flags                 number not null,        /* roll up status */
  frequency             number not null,        /* frequency of the query */
  constraint mview$_adv_eligible_pk primary key(sumobjn#, runid#),
  constraint mview$_adv_eligible_fk foreign key (runid#)
  references system.mview$_adv_log(runid#)
  )
/
comment on table system.mview$_adv_eligible is
  'Summary management rewrite eligibility information'
/     
  
create table system.mview$_adv_output
  (
  runid#                number not null,        /* run id */
  output_type           number not null,        /* 0: recommend, 1: eval */
  rank#                 number,                 /* ranking */
  action_type           varchar2(6),             /* retain/create/drop */
  summary_owner         varchar2(30),           /* owner of the summary */
  summary_name          varchar2(30),           /* summary name */
  group_by_columns      varchar2(2000),         /* group by columns */
  where_clause          varchar2(2000),         /* where clause */
  from_clause           varchar2(2000),         /* from clause */
  measures_list         varchar2(2000),         /* measure list */
  fact_tables           varchar2(1000),         /* list of fact tables */
  grouping_levels       varchar2(2000),         /* grouping levels */
  querylen              number,                 /* length of the query text */
  query_text            long,                   /* query text */
  storage_in_bytes      number,                 /* storage */
  pct_performance_gain  number,                 /* performance gain */
  frequency             number,                 /* frequency */
  cumulative_benefit    number,                 /* cumulative benefit */
  benefit_to_cost_ratio number not null,        /* benefit / cost */
  validated             number,                 /* validated or not */
  constraint mview$_adv_output_pk primary key(runid#, rank#),
  constraint mview$_adv_output_fk foreign key (runid#) 
  references system.mview$_adv_log(runid#)
  )
/
comment on table system.mview$_adv_output is
  'Output table for summary recommendations and evaluations'
/

create table system.mview$_adv_exceptions
  (
  runid#                number,                 /* run id */
  owner                 varchar2(30),           /* name of offending tables */
  table_name            varchar2(30),           /* offending table */
  dimension_name        varchar2(30),           /* offending dimension name */
  relationship          varchar2(11),           /* violated relation name */
  bad_rowid             rowid,                  /* bad row id */
  constraint mview$_adv_exception_fk foreign key (runid#)
  references system.mview$_adv_log(runid#)
  )
/
comment on table system.mview$_adv_exceptions is
  'Output table for dimension validations'
/  
  
create table system.mview$_adv_parameters 
  (
  parameter_name        varchar2(30),           /* primary key */
  parameter_type        number not null,        /* number/string/date */
  string_value          varchar2(30),           /* string value */
  date_value            date,                   /* date value */
  numerical_value       number,                 /* numerical value */
  constraint mview$_adv_parameters_pk primary key (parameter_name)
  )
/
comment on table system.mview$_adv_parameters is
  'Summary advisor tuning parameters'
/  

create table system.mview$_adv_info
  (
  runid#                number not null,        /* run id */
  seq#                  number not null,        /* event sequence number */
  type                  number not null,        /* information type */
  infolen               number not null,        /* length of the info col */
  info                  long raw,               /* information content */
  status                number,                 /* status */
  flag                  number,                 /* reserved flag field */
  constraint mview$_adv_info_pk primary key (runid#, seq#),
  constraint mview$_adv_info_fk foreign key (runid#)
  references system.mview$_adv_log(runid#)
  )
/
comment on table system.mview$_adv_info is
  'Internal table for passing information from the SQL analyzer'
/  

create table system.mview$_adv_journal 
  (
  runid#                number not null,        /* run id */
  seq#                  number not null,        /* event sequence number */
  timestamp             date not null,          /* time stamp for this entry */
  flags                 number not null,        /* type of journal entry */
  num                   number,                 /* optional number field */
  text                  long,                   /* contents */
  textlen               number,                 /* # of bytes in text */
  constraint mview$_adv_journal_pk primary key (runid#, seq#),
  constraint mview$_adv_journal_fk foreign key (runid#)
  references system.mview$_adv_log(runid#)
  )
/
comment on table system.mview$_adv_journal is
  'Summary advisor journal table for debugging and information'
/ 


create table system.mview$_adv_plan (
  statement_id    varchar2(30),
  timestamp       date,
  remarks         varchar2(80),
  operation       varchar2(30),
  options         varchar2(255),
  object_node     varchar2(128),
  object_owner    varchar2(30),
  object_name     varchar2(30),
  object_instance numeric,
  object_type     varchar2(30),
  optimizer       varchar2(255),
  search_columns  number,
  id              numeric,
  parent_id       numeric,
  position        numeric,
  cost            numeric,
  cardinality     numeric,
  bytes           numeric,
  other_tag       varchar2(255),
  partition_start varchar2(255),
  partition_stop  varchar2(255),
  partition_id    numeric,
  other           long,
  distribution    varchar2(30),
  cpu_cost        numeric,
  io_cost         numeric,
  temp_space      numeric)
  /

comment on table system.mview$_adv_plan is
  'Private plan table for estimate_mview_size operations'
/ 


create sequence system.mview$_advseq_generic    /* snapshot Site ID sequence */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295                           /* max portable value of UB4 */
  nocycle
  cache 50
/
  
create sequence system.mview$_advseq_id         /* snapshot Site ID sequence */
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295                           /* max portable value of UB4 */
  nocycle
/
  
delete from system.mview$_adv_parameters
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_EXACT_DELETE', 0, 0.02, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_EXACT_BUCKETS', 0, 1000, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_PARTIAL_DELETE', 0, 0.02, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_PARTIAL_BUCKETS', 0, 1000, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_AJG_DELETE', 0, 0.02, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_AJG_BUCKETS', 0, 100, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_FJG_DELETE', 0, 0.02, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_GC_DELETE', 0, 0.02, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_MEA_DELETE', 0, 0.05, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_TRACE_LEVEL', 0, 0, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMSS_REWRITE_NRF', 0, 10, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('qsma.console_output',1,0,'True','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.wip_interval',0,250,'','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.commit_interval',0,100,'','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.sql_exclusions',1,0,'SYSTEM.%','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.pretty',1,0,'True','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.lcase_names',1,0,'True','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.lcase_keywords',1,0,'False','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.add_alias',1,0,'False','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.ignore_ambig',1,0,'True','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.fixup_alias',1,0,'False','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.optimize',1,0,'True','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.ignore_columns',1,0,'True','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.fixup_schema',1,0,'False','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.remove_optional_keywords',1,0,'False','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.dump_tree',1,0,'True','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.debug_flags',1,0,'','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.datetime_mask',1,0,'dd/MM/yyyy HH:mm','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMAE_MIN_CLQ_MF_RATIO', 0, 0.05, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMAE_MIN_SUM_BC_RATIO', 0, 0.05, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMAE_MAX_GCS', 0, 1000, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMAE_PCT_COMPL_POLL_INTL', 0, 10, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMAE_TRACE_LEVEL', 0, 0, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMAE_AEP_MAX_LAT_SIZE', 0, 1024, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value,string_value,date_value)
  values ('QSMAE_AEP_MAX_FACT_TABLES', 0, 10, NULL, NULL)
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.report.color1',1,0,'#FFFFDE','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.report.color2',1,0,'#336699','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.report.color3',1,0,'#FFCC60','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.report.color4',1,0,'white','')
/
insert into system.mview$_adv_parameters
   (parameter_name,parameter_type,numerical_value, string_value,date_value)
  values ('qsma.report.include_unused',1,0,'False','')
/

create or replace view SYSTEM.MVIEW_WORKLOAD
as 
select 
  a.collectionid# as workloadid,
  a.collecttime as import_time,
  a.queryid# as queryid,
  a.application,
  a.cardinality,
  a.resultsize,
  a.qdate as lastuse,
  a.frequency,
  a.uname as owner,
  a.priority,
  a.sql_text as query,
  a.exec_time as responsetime
from SYSTEM.MVIEW$_ADV_WORKLOAD A, SYSTEM.MVIEW$_ADV_LOG B, ALL_USERS D
WHERE a.collectionid# = b.runid# 
AND b.uname = d.username
AND d.user_id = userenv('SCHEMAID')
/
comment on table SYSTEM.MVIEW_WORKLOAD is
'This view gives DBA access to shared workload'
/

create or replace view system.mview_filter
as
select
      a.filterid# as filterid,
      a.subfilternum# as subfilternum,
      decode(a.subfiltertype,1,'APPLICATION',2,'CARDINALITY',3,'LASTUSE',
                             4,'FREQUENCY',5,'USER',6,'PRIORITY',7,'BASETABLE',
                             8,'RESPONSETIME',9,'COLLECTIONID',10,'TRACENAME',
                             11,'SCHEMA','UNKNOWN') AS subfiltertype,
      a.str_value,
      to_number(decode(a.num_value1,-999,NULL,a.num_value1)) AS num_value1,
      to_number(decode(a.num_value2,-999,NULL,a.num_value2)) AS num_value2,
      a.date_value1,
      a.date_value2
   from system.mview$_adv_filter a, system.mview$_adv_log b, ALL_USERS u
   WHERE a.filterid# = b.runid# 
   AND b.uname = u.username
   AND u.user_id = userenv('SCHEMAID')
/
comment on table system.mview_filter is
 'Workload filter records'
/

create or replace view system.mview_log
as
select
      m.runid# as id,
      m.filterid# as filterid,
      m.run_begin,
      m.run_end,
      decode(m.run_type,1,'EVALUATE',2,'EVALUATE_W',3,'RECOMMEND',
                      4,'RECOMMEND_W',5,'VALIDATE',6,'WORKLOAD',
                      7,'FILTER','UNKNOWN') AS type,
      decode(m.status,0,'UNUSED',1,'CANCELLED',2,'IN_PROGRESS',3,'COMPLETED',
                    4,'ERROR','UNKNOWN') AS status,
      m.message,
      m.completed,
      m.total,
      m.error_code
   from system.mview$_adv_log m, all_users u
   where m.uname = u.username
   and   u.user_id = userenv('SCHEMAID')
/
comment on table system.mview_log is
 'Advisor session log'
/

create or replace view system.mview_filterinstance
as
select
      a.runid# as runid,
      a.filterid# as filterid,
      a.subfilternum# as subfilternum,
      decode(a.subfiltertype,1,'APPLICATION',2,'CARDINALITY',3,'LASTUSE',
                             4,'FREQUENCY',5,'USER',6,'PRIORITY',7,'BASETABLE',
                             8,'RESPONSETIME',9,'COLLECTIONID',10,'TRACENAME',
                             11,'SCHEMA','UNKNOWN') AS subfiltertype,
      a.str_value,
      to_number(decode(a.num_value1,-999,NULL,a.num_value1)) AS num_value1,
      to_number(decode(a.num_value2,-999,NULL,a.num_value2)) AS num_value2,
      a.date_value1,
      a.date_value2
   from system.mview$_adv_filterinstance a
/
comment on table system.mview_filterinstance is
 'Workload filter instance records'
/

create or replace view SYSTEM.MVIEW_RECOMMENDATIONS
as 
select 
  t1.runid# as runid,
  t1.from_clause as all_tables,
  fact_tables,
  grouping_levels,
  query_text,
  rank# as recommendation_number,
  action_type as recommended_action,
  summary_owner as mview_owner,
  summary_name as mview_name,
  storage_in_bytes,
  pct_performance_gain,
  benefit_to_cost_ratio
from SYSTEM.MVIEW$_ADV_OUTPUT t1, SYSTEM.MVIEW$_ADV_LOG t2, ALL_USERS u
where 
  t1.runid# = t2.runid# and
  u.username = t2.uname and 
  u.user_id = userenv('SCHEMAID') and
  t1.output_type = 0
order by t1.rank#
/
comment on table SYSTEM.MVIEW_RECOMMENDATIONS is
'This view gives DBA access to summary recommendations'
/

create or replace view SYSTEM.MVIEW_EVALUATIONS
as 
select 
  t1.runid# as runid,
  summary_owner AS mview_owner,
  summary_name AS mview_name,
  rank# as rank,
  storage_in_bytes,
  frequency,
  cumulative_benefit,
  benefit_to_cost_ratio
from SYSTEM.MVIEW$_ADV_OUTPUT t1, SYSTEM.MVIEW$_ADV_LOG t2, ALL_USERS u
where 
  t1.runid# = t2.runid# and
  u.username = t2.uname and
  u.user_id = userenv('SCHEMAID') and
  t1.output_type = 1
order by t1.rank#
/
comment on table SYSTEM.MVIEW_EVALUATIONS is
'This view gives DBA access to summary evaluation output'
/

create or replace view SYSTEM.MVIEW_EXCEPTIONS
as
select
  t1.runid# as runid,
  owner,
  table_name,
  dimension_name,
  relationship,
  bad_rowid
from SYSTEM.MVIEW$_ADV_EXCEPTIONS t1, SYSTEM.MVIEW$_ADV_LOG t2, ALL_USERS u
where 
  t1.runid# = t2.runid# and
  u.username = t2.uname and
  u.user_id = userenv('SCHEMAID')
/
comment on table SYSTEM.MVIEW_EXCEPTIONS is
'This view gives DBA access to dimension validation results'
/

Rem Add mview$ tables to noexp$
delete from noexp$ where name like 'MVIEW$_%'
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_WORKLOAD', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_BASETABLE', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_SQLDEPEND', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_PRETTY', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_TEMP', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_FILTER', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_LOG', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_FILTERINSTANCE', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_LEVEL', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_ROLLUP', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_AJG', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_FJG', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_GC', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_CLIQUE', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_ELIGIBLE', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_OUTPUT', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_EXCEPTIONS', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_PARAMETERS', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_INFO', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_JOURNAL', 2)
/
insert into noexp$ (owner, name, obj_type)
values('SYSTEM', 'MVIEW$_ADV_PLAN', 2)
/
commit
/

REM
REM DBA_REWRITE_EQUIVALENCES
REM

create or replace view DBA_REWRITE_EQUIVALENCES
(OWNER, NAME, SOURCE_STMT, DESTINATION_STMT, REWRITE_MODE)
as
select u.name, o.name, s.src_stmt, s.dest_stmt,
       decode(s.rw_mode, 0, 'DISABLED',
                         1, 'TEXT_MATCH',
                         2, 'GENERAL',
                         3, 'RECURSIVE',
                         4, 'TUNE_MVIEW',
                         'UNDEFINED')
from sum$ s, obj$ o, user$ u
  where o.obj# = s.obj# and 
  bitand(s.xpflags, 8388608) > 0 and  /* REWRITE EQUIVALENCE SUMMARY */  
  o.owner# = u.user#
/
comment on table DBA_REWRITE_EQUIVALENCES is 
'Description of rewrite equivalence accessible to DBA'
/
comment on column DBA_REWRITE_EQUIVALENCES.OWNER is
'Owner of the rewrite equivalence'
/
comment on column DBA_REWRITE_EQUIVALENCES.NAME is
'Name of the rewrite equivalence'
/
comment on column DBA_REWRITE_EQUIVALENCES.SOURCE_STMT is 
'Source statement of the rewrite equivalence'
/
comment on column DBA_REWRITE_EQUIVALENCES.DESTINATION_STMT is
'Destination of the rewrite equivalence'
/
comment on column DBA_REWRITE_EQUIVALENCES.REWRITE_MODE is
'Rewrite mode of the rewrite equivalence'
/
create or replace public synonym DBA_REWRITE_EQUIVALENCES for DBA_REWRITE_EQUIVALENCES
/
grant select on DBA_REWRITE_EQUIVALENCES to select_catalog_role
/

REM
REM ALL_REWRITE_EQUIVALENCES
REM

create or replace view ALL_REWRITE_EQUIVALENCES
as select m.* from dba_rewrite_equivalences m, sys.obj$ o, sys.user$ u
where o.owner# = u.user#
  and m.name   = o.name
  and u.name   = m.owner
  and ( o.owner# = userenv('SCHEMAID')
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                  )
        or /* user has system privileges */
        exists ( select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
               )
      )
/
comment on table ALL_REWRITE_EQUIVALENCES is 
'Description of all rewrite equivalence accessible to the user'
/
comment on column ALL_REWRITE_EQUIVALENCES.OWNER is
'Owner of the rewrite equivalence'
/
comment on column ALL_REWRITE_EQUIVALENCES.NAME is
'Name of the rewrite equivalence'
/
comment on column ALL_REWRITE_EQUIVALENCES.SOURCE_STMT is 
'Source statement of the rewrite equivalence'
/
comment on column ALL_REWRITE_EQUIVALENCES.DESTINATION_STMT is
'Destination of the rewrite equivalence'
/
comment on column ALL_REWRITE_EQUIVALENCES.REWRITE_MODE is
'Rewrite mode of the rewrite equivalence'
/
create or replace public synonym ALL_REWRITE_EQUIVALENCES for ALL_REWRITE_EQUIVALENCES
/
grant select on ALL_REWRITE_EQUIVALENCES to public with grant option
/

REM
REM USER_REWRITE_EQUIVALENCES
REM

create or replace view USER_REWRITE_EQUIVALENCES
as select m.* from dba_rewrite_equivalences m, sys.user$ u
where u.name = m.owner
  and u.user# = userenv('SCHEMAID')
/
comment on table USER_REWRITE_EQUIVALENCES is 
'Description of all rewrite equivalence owned by the user'
/
comment on column USER_REWRITE_EQUIVALENCES.OWNER is
'Owner of the rewrite equivalence'
/
comment on column USER_REWRITE_EQUIVALENCES.NAME is
'Name of the rewrite equivalence'
/
comment on column USER_REWRITE_EQUIVALENCES.SOURCE_STMT is 
'Source statement of the rewrite equivalence'
/
comment on column USER_REWRITE_EQUIVALENCES.DESTINATION_STMT is
'Destination of the rewrite equivalence'
/
comment on column USER_REWRITE_EQUIVALENCES.REWRITE_MODE is
'Rewrite mode of the rewrite equivalence'
/
create or replace public synonym USER_REWRITE_EQUIVALENCES for USER_REWRITE_EQUIVALENCES
/
grant select on USER_REWRITE_EQUIVALENCES to public with grant option 
/

/* Register procedural objects for export */
DELETE FROM sys.exppkgobj$ WHERE package LIKE 'DBMS_SUM_%'
/
INSERT INTO sys.exppkgobj$ (package,schema,class,type#,prepost,level#)
  VALUES ('DBMS_SUM_RWEQ_EXPORT','SYS',2,42,1, 0)
/
commit
/

rem  DBA_MVIEW_DETAIL_PARTITION

create or replace view DBA_MVIEW_DETAIL_PARTITION
( OWNER,                    /* owner name                                   */
  MVIEW_NAME,               /* materialized view name                       */
  DETAILOBJ_OWNER,          /* detail object owner's name                   */
  DETAILOBJ_NAME,           /* detail object name                           */
  DETAIL_PARTITION_NAME,    /* detail object partition name                 */
  DETAIL_PARTITION_POSITION,/* detail object partition position             */
  FRESHNESS                 /* freshness state (FRESH, STALE, UNKNOWN, NA)  */
)
as
select u1.name owner, o1.name mview_name, 
       u2.name detailobj_owner, o2.name detailobj_name, 
       o3.subname detail_partition_name, 
       tv.part# detail_partition_position, 
       (case when t.spare1 is NULL then 'FRESH' 
             when t.spare1 < w.lastrefreshscn then 'FRESH' 
             else 'STALE' end) freshness 
from sys.obj$ o1, sys.sum$ w, sys.sumdetail$ sd, sys.obj$ o2, sys.tabpart$ t, 
     sys.obj$ o3, sys.tabpartv$ tv, sys.user$ u1, sys.user$ u2  
where w.obj# = o1.obj# 
  and w.obj# = sd.sumobj# 
  and sd.detailobj# = o2.obj# 
  and sd.detailobj# = t.bo#
  and t.obj# = o3.obj#(+) 
  and t.obj# = tv.obj#(+) 
  and o1.owner# = u1.user# 
  and o2.owner# = u2.user#
  and bitand(sd.detaileut, 2147483648) = 0 /* NOT 2nd cube mv pct metadata */;
/

create or replace public synonym DBA_MVIEW_DETAIL_PARTITION for 
DBA_MVIEW_DETAIL_PARTITION
/
comment on table DBA_MVIEW_DETAIL_PARTITION is
'Freshness information of all PCT materialized views in the database'
/
comment on column DBA_MVIEW_DETAIL_PARTITION.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEW_DETAIL_PARTITION.MVIEW_NAME is
'Name of the materialized view'
/
comment on column DBA_MVIEW_DETAIL_PARTITION.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column DBA_MVIEW_DETAIL_PARTITION.DETAIL_PARTITION_NAME is
'Name of the detail object partition'
/
comment on column DBA_MVIEW_DETAIL_PARTITION.DETAIL_PARTITION_POSITION is
'Position of the detail object partition'
/
comment on column DBA_MVIEW_DETAIL_PARTITION.FRESHNESS is
'Freshness of the detail object partition'
/
grant select on DBA_MVIEW_DETAIL_PARTITION to select_catalog_role
/

rem  ALL_MVIEW_DETAIL_PARTITION

create or replace view ALL_MVIEW_DETAIL_PARTITION
as select m.* from dba_mview_detail_partition m, sys.obj$ o, sys.user$ u
where o.owner#     = u.user#
  and m.mview_name = o.name
  and u.name       = m.owner
  and o.type#      = 2                     /* table */
  and ( u.user# in (userenv('SCHEMAID'), 1)
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                  )
        or /* user has system privileges */
        exists ( select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
               )
      )
/

create or replace public synonym ALL_MVIEW_DETAIL_PARTITION for 
ALL_MVIEW_DETAIL_PARTITION
/
comment on table ALL_MVIEW_DETAIL_PARTITION is
'Freshness information of all PCT materialized views in the database'
/
comment on column ALL_MVIEW_DETAIL_PARTITION.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEW_DETAIL_PARTITION.MVIEW_NAME is
'Name of the materialized view'
/
comment on column ALL_MVIEW_DETAIL_PARTITION.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column ALL_MVIEW_DETAIL_PARTITION.DETAIL_PARTITION_NAME is
'Name of the detail object partition'
/
comment on column ALL_MVIEW_DETAIL_PARTITION.DETAIL_PARTITION_POSITION is
'Position of the detail object partition'
/
comment on column ALL_MVIEW_DETAIL_PARTITION.FRESHNESS is
'Freshness of the detail object partition'
/
grant select on  ALL_MVIEW_DETAIL_PARTITION to public with grant option
/

rem  USER_MVIEW_DETAIL_PARTITION

create or replace view USER_MVIEW_DETAIL_PARTITION
as select m.* from dba_mview_detail_partition m, sys.user$ u
where u.user# = userenv('SCHEMAID')
  and m.owner = u.name
/

create or replace public synonym USER_MVIEW_DETAIL_PARTITION for 
USER_MVIEW_DETAIL_PARTITION
/
comment on table USER_MVIEW_DETAIL_PARTITION is
'Freshness information of all PCT materialized views in the database'
/
comment on column USER_MVIEW_DETAIL_PARTITION.OWNER is
'Owner of the materialized view'
/
comment on column USER_MVIEW_DETAIL_PARTITION.MVIEW_NAME is
'Name of the materialized view'
/
comment on column USER_MVIEW_DETAIL_PARTITION.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column USER_MVIEW_DETAIL_PARTITION.DETAIL_PARTITION_NAME is
'Name of the detail object partition'
/
comment on column USER_MVIEW_DETAIL_PARTITION.DETAIL_PARTITION_POSITION is
'Position of the detail object partition'
/
comment on column USER_MVIEW_DETAIL_PARTITION.FRESHNESS is
'Freshness of the detail object partition'
/
grant select on  USER_MVIEW_DETAIL_PARTITION to public with grant option
/


rem DBA_MVIEW_DETAIL_SUBPARTITION

create or replace view dba_mview_detail_subpartition
( OWNER,                    /* owner name                                   */
  MVIEW_NAME,               /* materialized view name                       */
  DETAILOBJ_OWNER,          /* detail object owner's name                   */
  DETAILOBJ_NAME,           /* detail object name                           */
  DETAIL_PARTITION_NAME,    /* detail object partition name                 */
  DETAIL_SUBPARTITION_NAME,    /* detail object subpartition name           */
  DETAIL_SUBPARTITION_POSITION,/* detail object subpartition position       */
  FRESHNESS                 /* freshness state (FRESH, STALE, UNKNOWN, NA)  */
)
as
  select u1.name owner, s.o1n mview_name , u2.name detailobj_owner, 
         s.o2n detailobj_name,
         s.o3n  detail_partition_name,
         o5.subname detail_subpartition_name,
         tsv.subpart# detail_subpartition_position, 
         (case when t.spare1 is NULL then 'FRESH' 
               when t.spare1 < s.mv_scn then 'FRESH' 
               else 'STALE' end) freshness
  from  sys.tabsubpart$ t, 
  (select o1.owner# o1owner#, o1.name o1n,  o2.owner# o2owner#, 
          o2.name o2n, o3.subname o3n,    
          w.lastrefreshscn mv_scn,  o1.obj# as sumobj#, t.obj# as pobj#
   from sys.obj$ o1, sys.sum$ w, sys.sumdetail$ sd, sys.obj$ o2, 
        sys.tabcompart$ t, sys.obj$ o3 
   where w.obj# = o1.obj# and w.obj# = sd.sumobj# 
         and sd.detailobj# = o2.obj# and sd.detailobj# = t.bo# 
         and t.obj# = o3.obj#(+)
         and bitand(sd.detaileut, 2147483648) = 0/* NO secondary CUBE MV rows */) s, 
  sys.tabsubpartv$ tsv, sys.user$ u1, sys.user$ u2, sys.obj$ o5
  where t.pobj# = s.pobj# 
     and tsv.obj# = t.obj# and s.o1owner# = u1.user# and s.o2owner# = u2.user#
        and o5.obj# = t.obj#;
/

create or replace public synonym DBA_MVIEW_DETAIL_SUBPARTITION for 
DBA_MVIEW_DETAIL_SUBPARTITION
/
comment on table DBA_MVIEW_DETAIL_SUBPARTITION is
'Freshness information of all PCT materialized views in the database'
/
comment on column DBA_MVIEW_DETAIL_SUBPARTITION.OWNER is
'Owner of the materialized view'
/
comment on column DBA_MVIEW_DETAIL_SUBPARTITION.MVIEW_NAME is
'Name of the materialized view'
/
comment on column DBA_MVIEW_DETAIL_SUBPARTITION.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column DBA_MVIEW_DETAIL_SUBPARTITION.DETAIL_PARTITION_NAME is
'Name of the detail object partition'
/
comment on column DBA_MVIEW_DETAIL_SUBPARTITION.DETAIL_SUBPARTITION_NAME is
'Name of the detail object subpartition'
/
comment on column DBA_MVIEW_DETAIL_SUBPARTITION.DETAIL_SUBPARTITION_POSITION is
'Position of the detail object subpartition'
/
comment on column DBA_MVIEW_DETAIL_SUBPARTITION.FRESHNESS is
'Freshness of the detail object partition'
/
grant select on DBA_MVIEW_DETAIL_SUBPARTITION to select_catalog_role
/

rem ALL_MVIEW_DETAIL_SUBPARTITION

create or replace view ALL_MVIEW_DETAIL_SUBPARTITION
as select m.* from dba_mview_detail_subpartition m, sys.obj$ o, sys.user$ u
where o.owner#     = u.user#
  and m.mview_name = o.name
  and u.name       = m.owner
  and o.type#      = 2                     /* table */
  and ( u.user# in (userenv('SCHEMAID'), 1)
        or
        o.obj# in ( select obj#
                    from sys.objauth$
                    where grantee# in ( select kzsrorol
                                        from x$kzsro
                                      )
                  )
        or /* user has system privileges */
        exists ( select null from v$enabledprivs
                 where priv_number in (-45 /* LOCK ANY TABLE */,
                                       -47 /* SELECT ANY TABLE */,
                                       -48 /* INSERT ANY TABLE */,
                                       -49 /* UPDATE ANY TABLE */,
                                       -50 /* DELETE ANY TABLE */)
               )
      )
/

create or replace public synonym ALL_MVIEW_DETAIL_SUBPARTITION for 
ALL_MVIEW_DETAIL_SUBPARTITION
/
comment on table ALL_MVIEW_DETAIL_SUBPARTITION is
'Freshness information of all PCT materialized views in the database'
/
comment on column ALL_MVIEW_DETAIL_SUBPARTITION.OWNER is
'Owner of the materialized view'
/
comment on column ALL_MVIEW_DETAIL_SUBPARTITION.MVIEW_NAME is
'Name of the materialized view'
/
comment on column ALL_MVIEW_DETAIL_SUBPARTITION.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column ALL_MVIEW_DETAIL_SUBPARTITION.DETAIL_PARTITION_NAME is
'Name of the detail object partition'
/
comment on column ALL_MVIEW_DETAIL_SUBPARTITION.DETAIL_SUBPARTITION_NAME is
'Name of the detail object subpartition'
/
comment on column ALL_MVIEW_DETAIL_SUBPARTITION.DETAIL_SUBPARTITION_POSITION is
'Position of the detail object subpartition'
/
comment on column ALL_MVIEW_DETAIL_SUBPARTITION.FRESHNESS is
'Freshness of the detail object partition'
/
grant select on  ALL_MVIEW_DETAIL_SUBPARTITION to public with grant option
/

rem USER_MVIEW_DETAIL_SUBPARTITION

create or replace view USER_MVIEW_DETAIL_SUBPARTITION
as select m.* from dba_mview_detail_subpartition m, sys.user$ u
where u.user# = userenv('SCHEMAID')
  and m.owner = u.name
/

create or replace public synonym USER_MVIEW_DETAIL_SUBPARTITION for 
USER_MVIEW_DETAIL_SUBPARTITION
/
comment on table USER_MVIEW_DETAIL_SUBPARTITION is
'Freshness information of all PCT materialized views in the database'
/
comment on column USER_MVIEW_DETAIL_SUBPARTITION.OWNER is
'Owner of the materialized view'
/
comment on column USER_MVIEW_DETAIL_SUBPARTITION.MVIEW_NAME is
'Name of the materialized view'
/
comment on column USER_MVIEW_DETAIL_SUBPARTITION.DETAILOBJ_NAME is
'Name of the detail object'
/
comment on column USER_MVIEW_DETAIL_SUBPARTITION.DETAIL_PARTITION_NAME is
'Name of the detail object partition'
/
comment on column USER_MVIEW_DETAIL_SUBPARTITION.DETAIL_SUBPARTITION_NAME is
'Name of the detail object subpartition'
/
comment on column USER_MVIEW_DETAIL_SUBPARTITION.DETAIL_SUBPARTITION_POSITION is
'Position of the detail object subpartition'
/
comment on column USER_MVIEW_DETAIL_SUBPARTITION.FRESHNESS is
'Freshness of the detail object partition'
/
grant select on  USER_MVIEW_DETAIL_SUBPARTITION to public with grant option
/

Rem End of File
