Rem
Rem $Header: oraolap/admin/catxs.sql /st_rdbms_11.2.0/3 2012/11/02 13:55:38 glyon Exp $
Rem
Rem catxs.sql
Rem
Rem Copyright (c) 2001, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxs.sql - eXpreSs Catalog creation
Rem
Rem    DESCRIPTION
Rem      This loads the catalog for the analytic workspaces
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    glyon       10/29/12 - Backport glyon_bug-14752361 from main
Rem    cchiappa    03/03/11 - Backport cchiappa_bug-11804916 from main
Rem    cchiappa    03/01/11 - Move drop trigger to prvtaw.sql
Rem    sfeinste    02/24/11 - Backport sfeinste_bug-11791349 from main
Rem    glyon       03/27/09 - bug 8391053 - fix ALL_MEASURE_FOLDERS view
Rem    cvenezia    02/18/09 - Do not allow user with CREATE ALL to see objects
Rem    jhartsin    02/03/09 - Got rid of extra join in all_cube_measures
Rem    hyechung    11/24/08 - v11.2 support
Rem    mstasiew    03/27/08 - ET_ATTR_PREFIX 5921859
Rem    ckearney    11/01/07 - update message when Olap objects present
Rem    cvenezia    08/30/07 - Add Dim requirement to privs in ALL_CUBE* views
Rem    mstasiew    08/14/07 - START_DATE
Rem    sfeinste    05/31/07 - Fix for bug 6085568
Rem    ckearney    05/22/07 - use olap_* tables instead of obj$ in drp trigger
Rem    sfeinste    05/10/07 - Fix for bug 6042471
Rem    cvenezia    05/09/07 - Correct privileges in ALL_*_VIEWS
Rem    sfeinste    04/30/07 - Dict renames and modifications (and undo hack)
Rem    ckearney    04/18/07 - add cube & cube dimension check
Rem    sfeinste    04/20/07 - Hack to prepare for dict changes
Rem    mstasiew    03/16/07 - 5837465
Rem    wechen      01/26/07 - rename olap kgl types, step 3
Rem    wechen      01/26/07 - rename olap kgl types, step 1
Rem    sfeinste    11/27/06 - Add interaction views
Rem    rsamuels    10/30/06 - Skip hidden measures in ALL/DBA/USER_MEASURES
Rem    cchiappa    09/21/06 - Trigger deletes sequence from noexp$
Rem    sfeinste    09/12/06 - modify olap_ views to do outer join
Rem    smesropi    06/14/06 - added views to olap_* data dictionary tables
Rem    jcarey      07/27/06 - revert drop trig before/after 
Rem    jcarey      07/17/06 - Add aw_version to user_aws 
Rem    cchiappa    07/12/06 - Disallow dropping table with COT 
Rem    jcarey      06/12/06 - remove truncate trigger 
Rem    jcarey      06/07/06 - v11 support 
Rem    jcarey      06/09/06 - Temp back out truncate trigger 
Rem    jcarey      05/22/06 - drop trigger before 
Rem    zqiu        06/09/05 - more checks in aw drop trigger 
Rem    zqiu        07/15/04 - more truthful ps{gen,num} count
Rem    cchiappa    06/16/04 - Drop trigger deletes from expdepact$
Rem    dbardwel    05/21/04 - Support for 10.2 aw_version
Rem    dbardwel    03/26/04 - Add missing join to ALL_AWS and ALL_AW_PS
Rem    ckearney    03/17/04 - add AW_VERSION to DBA_AWS & ALL_AWS
Rem    zqiu        10/16/03 - delete from noexp in trigger
Rem    zqiu        10/01/03 - fix redundancy in all_ views
Rem    zqiu        09/23/03 - strip DML priv to public
Rem    zqiu        12/05/02 - remove temp columns in aw_prop$
Rem    zqiu        11/21/02 - modify trigger to delete from aw_*$ table
Rem    zqiu        09/17/02 - bypass select from user_table in aw_drop_proc
Rem    zqiu        09/09/02 - add view all_aws
Rem    zqiu        07/25/02 - use dynamic sql for aw_drop_trigger
Rem    zqiu        06/18/02 - trigger to clean aw$/ps$ when user table dropped
Rem    jcarey      10/18/01 - remove lobtab from aw$
Rem    esoyleme    09/13/01 - views in spec..
Rem    esoyleme    09/10/01 - creation

--create views on aw$

create or replace view DBA_AWS
(OWNER, AW_NUMBER, AW_NAME, AW_VERSION, PAGESPACES, GENERATIONS, FROZEN)
as
SELECT u.name, a.awseq#, a.awname,
       DECODE(a.version, 0, '9.1', 1, '10.1', 2, '10.2', 3, '11.1', 4, '11.2', NULL), 
        n.num, g.gen, f.frozen
FROM aw$ a, user$ u,
     (SELECT awseq#, COUNT(psgen) gen FROM ps$ WHERE psnumber IS NULL GROUP BY awseq#) g,
     (SELECT awseq#, COUNT(UNIQUE(psnumber)) num FROM ps$ WHERE psnumber IS NOT NULL GROUP BY awseq#) n ,
     (SELECT max(awseq#) awmax, decode(max(mapoffset), 1, 'Frozen', 
         2, 'NoThaw', NULL) frozen from ps$ where psnumber is NULL
         group by awseq#) f
WHERE   a.owner#=u.user# and a.awseq#=g.awseq# and a.awseq#=n.awseq# and
        a.awseq# = f.awmax
/

comment on table DBA_AWS is
'Analytic Workspaces in the database'
/
comment on column DBA_AWS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column DBA_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column DBA_AWS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column DBA_AWS.PAGESPACES is
'Number of pagespaces in the Analytic Workspace'
/
comment on column DBA_AWS.GENERATIONS is
'Number of active generations in the Analytic Workspace'
/
comment on column DBA_AWS.FROZEN is
'Freeze state of the Analytic Workspace'
/
comment on column DBA_AWS.AW_VERSION is
'Format version of the Analytic Workspace'
/
create or replace view USER_AWS
(AW_NUMBER, AW_NAME, AW_VERSION, PAGESPACES, GENERATIONS, FROZEN)
as
SELECT a.awseq#, a.awname, 
       DECODE(a.version, 0, '9.1', 1, '10.1', 2, '10.2', 3, '11.1', 4, '11.2', NULL), 
       n.num, g.gen, f.frozen
FROM aw$ a,
     (SELECT awseq#, COUNT(psgen) gen FROM ps$ WHERE psnumber IS NULL GROUP BY awseq#) g,
     (SELECT awseq#, COUNT(UNIQUE(psnumber)) num FROM ps$ WHERE psnumber IS NOT NULL GROUP BY awseq#) n ,
     (SELECT max(awseq#) awmax, decode(max(mapoffset), 1, 'Frozen', 
         2, 'NoThaw', NULL) frozen from ps$ where psnumber is NULL
         group by awseq#) f
WHERE   a.owner#=USERENV('SCHEMAID') and a.awseq#=g.awseq# and a.awseq#=n.awseq# 
        and a.awseq# = f.awmax
/

comment on table USER_AWS is
'Analytic Workspaces owned by the user'
/
comment on column USER_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column USER_AWS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column USER_AWS.PAGESPACES is
'Number of pagespaces in the Analytic Workspace'
/
comment on column USER_AWS.GENERATIONS is
'Number of active generations in the Analytic Workspace'
/
comment on column USER_AWS.FROZEN is
'Freeze state of the Analytic Workspace'
/
comment on column USER_AWS.AW_VERSION is
'Format version of the Analytic Workspace'
/
create or replace view ALL_AWS
(OWNER, AW_NUMBER, AW_NAME, AW_VERSION, PAGESPACES, GENERATIONS, FROZEN)
as
SELECT u.name, a.awseq#, a.awname,
       decode(a.version, 0, '9.1', 1, '10.1', 2, '10.2', 3, '11.1', 4, '11.2', NULL), 
        n.num, g.gen, f.frozen
FROM aw$ a, sys.obj$ o, sys.user$ u,
     (SELECT awseq#, COUNT(psgen) gen FROM ps$ WHERE psnumber IS NULL GROUP BY awseq#) g,
     (SELECT awseq#, COUNT(UNIQUE(psnumber)) num FROM ps$ WHERE psnumber IS NOT NULL GROUP BY awseq#) n ,
     (SELECT max(awseq#) awmax, decode(max(mapoffset), 1, 'Frozen', 
         2, 'NoThaw', NULL) frozen from ps$ where psnumber is NULL
         group by awseq#) f
WHERE  a.owner#=u.user#
       and o.owner# = a.owner#
       and o.name = 'AW$' || a.awname and o.type#= 2 /* type for table */
       and a.awseq#=g.awseq# and a.awseq#=n.awseq# and a.awseq# = f.awmax
       and (a.owner# in (userenv('SCHEMAID'), 1)   /* public objects */
            or
            o.obj# in ( select obj#  /* directly granted privileges */
                        from sys.objauth$
                        where grantee# in ( select kzsrorol from x$kzsro )
                      )
            or   /* user has system privileges */
              ( exists (select null from v$enabledprivs
                        where priv_number in (-45 /* LOCK ANY TABLE */,
                                              -47 /* SELECT ANY TABLE */,
                                              -48 /* INSERT ANY TABLE */,
                                              -49 /* UPDATE ANY TABLE */,
                                              -50 /* DELETE ANY TABLE */)
                        )
              )
            )
/

comment on table ALL_AWS is
'Analytic Workspaces accessible to the user'
/
comment on column ALL_AWS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column ALL_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column ALL_AWS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column ALL_AWS.PAGESPACES is
'Number of pagespaces in the Analytic Workspace'
/
comment on column ALL_AWS.GENERATIONS is
'Number of active generations in the Analytic Workspace'
/
comment on column ALL_AWS.FROZEN is
'Freeze state of the Analytic Workspace'
/
comment on column ALL_AWS.AW_VERSION is
'Format version of the Analytic Workspace'
/
--create views on ps$

create or replace view DBA_AW_PS
(OWNER, AW_NUMBER, AW_NAME, PSNUMBER, GENERATIONS, MAXPAGES)
as
SELECT u.name, a.awseq#, a.awname, p.psnumber, count(unique(p.psgen)), max(p.maxpages)
FROM aw$ a, ps$ p, user$ u
WHERE   a.owner#=u.user# and a.awseq#=p.awseq#
group by a.awseq#, a.awname, u.name, p.psnumber
/

comment on table DBA_AW_PS is
'Pagespaces in Analytic Workspaces owned by the user'
/
comment on column DBA_AW_PS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column DBA_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column DBA_AW_PS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column DBA_AW_PS.PSNUMBER is
'Number of the pagespace'
/
comment on column DBA_AW_PS.GENERATIONS is
'Number of active generations in the pagespace'
/
comment on column DBA_AW_PS.MAXPAGES is
'Maximum pages allocated in the pagespace'
/

create or replace view USER_AW_PS
(AW_NUMBER, AW_NAME, PSNUMBER, GENERATIONS, MAXPAGES)
as
SELECT a.awseq#, a.awname, p.psnumber, count(unique(p.psgen)), max(p.maxpages)
FROM aw$ a, ps$ p
WHERE   a.owner#=USERENV('SCHEMAID') and a.awseq#=p.awseq#
group by a.awseq#, a.awname, p.psnumber
/

comment on table USER_AW_PS is
'Pagespaces in Analytic Workspaces owned by the user'
/
comment on column USER_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column USER_AW_PS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column USER_AW_PS.PSNUMBER is
'Number of the pagespace'
/
comment on column USER_AW_PS.GENERATIONS is
'Number of active generations in the pagespace'
/
comment on column USER_AW_PS.MAXPAGES is
'Maximum pages allocated in the pagespace'
/

create or replace view ALL_AW_PS
(OWNER, AW_NUMBER, AW_NAME, PSNUMBER, GENERATIONS, MAXPAGES)
as
SELECT u.name, a.awseq#, a.awname, p.psnumber, count(unique(p.psgen)), max(p.maxpages)
FROM aw$ a, ps$ p, user$ u, sys.obj$ o
WHERE  a.owner#=u.user#
       and o.owner# = a.owner#
       and o.name = 'AW$' || a.awname and o.type#= 2 /* type for table */
       and a.awseq#=p.awseq#
       and (a.owner# in (userenv('SCHEMAID'), 1)   /* public objects */
            or
            o.obj# in ( select obj#  /* directly granted privileges */
                        from sys.objauth$
                        where grantee# in ( select kzsrorol from x$kzsro )
                      )
            or   /* user has system privileges */
              ( exists (select null from v$enabledprivs
                        where priv_number in (-45 /* LOCK ANY TABLE */,
                                              -47 /* SELECT ANY TABLE */,
                                              -48 /* INSERT ANY TABLE */,
                                              -49 /* UPDATE ANY TABLE */,
                                              -50 /* DELETE ANY TABLE */)
                        )
              )
            )
group by a.awseq#, a.awname, u.name, p.psnumber
/

comment on table ALL_AW_PS is
'Pagespaces in Analytic Workspaces accessible to the user'
/
comment on column ALL_AW_PS.OWNER is
'Owner of the Analytic Workspace'
/
comment on column ALL_AWS.AW_NUMBER is
'Number of the Analytic Workspace'
/
comment on column ALL_AW_PS.AW_NAME is
'Name of the Analytic Workspace'
/
comment on column ALL_AW_PS.PSNUMBER is
'Number of the pagespace'
/
comment on column ALL_AW_PS.GENERATIONS is
'Number of active generations in the pagespace'
/
comment on column ALL_AW_PS.MAXPAGES is
'Maximum pages allocated in the pagespace'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_AWS FOR SYS.DBA_AWS
/
GRANT SELECT ON DBA_AWS to select_catalog_role
/
CREATE OR REPLACE PUBLIC SYNONYM DBA_AW_PS FOR SYS.DBA_AW_PS
/
GRANT SELECT ON DBA_AW_PS to select_catalog_role
/

CREATE OR REPLACE PUBLIC SYNONYM USER_AWS FOR SYS.USER_AWS
/
GRANT SELECT ON USER_AWS to public
/
CREATE OR REPLACE PUBLIC SYNONYM USER_AW_PS FOR SYS.USER_AW_PS
/
GRANT SELECT ON USER_AW_PS to public
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_AWS FOR SYS.ALL_AWS
/
GRANT SELECT ON ALL_AWS to public
/
CREATE OR REPLACE PUBLIC SYNONYM ALL_AW_PS FOR SYS.ALL_AW_PS
/
GRANT SELECT ON ALL_AW_PS to public
/

-- OLAP_CUBES DATA DICTIONARY TABLES --

create or replace view DBA_CUBES
AS
SELECT 
  u.name OWNER, 
  o.name CUBE_NAME, 
  a.awname AW_NAME,
  syn.syntax_clob CONSISTENT_SOLVE_SPEC,
  d.description_value DESCRIPTION,
  io.option_value SPARSE_TYPE,
  syn2.syntax_clob PRECOMPUTE_CONDITION,
  io2.option_num_value PRECOMPUTE_PERCENT,
  io3.option_num_value PRECOMPUTE_PERCENT_TOP,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME
FROM  
  olap_cubes$ c, 
  user$ u, 
  aw$ a, 
  obj$ o, 
  olap_syntax$ syn,
  olap_syntax$ syn2,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 1 --CUBE
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_impl_options$ io4,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 	
  o.obj#=c.obj#
  AND o.owner#=u.user#
  AND c.awseq#=a.awseq#(+)
  AND c.obj#=d.owning_object_id(+)
  AND syn.owner_id(+)=c.obj#
  AND syn.owner_type(+)=1
  AND syn.ref_role(+)=16 -- consistent solve spec 
  AND syn2.owner_id(+)=c.obj#
  AND syn2.owner_type(+)=1
  AND syn2.ref_role(+)=20 -- precompute condition 
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1
  AND io.option_type(+)=7 -- sparse type 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1
  AND io2.option_type(+)=24 -- precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1
  AND io3.option_type(+)=25 -- precompute percent top 
  AND io4.owning_objectid(+)=c.obj#
  AND io4.object_type(+)=1
  AND io4.option_type(+)=9 -- partition level 
  AND io4.option_num_value=hl.hierarchy_level_id(+)
  AND hl.hierarchy_id=h.hierarchy_id(+)
  AND hl.dim_level_id=dl.level_id(+)
  AND h.dim_obj#=od.obj#(+)
/

comment on table DBA_CUBES is
'OLAP Cubes in the database'
/
comment on column DBA_CUBES.OWNER is
'Owner of the OLAP Cube'
/
comment on column DBA_CUBES.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column DBA_CUBES.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube'
/
comment on column DBA_CUBES.CONSISTENT_SOLVE_SPEC is
'The Consistent Solve Specification for the OLAP Cube'
/
comment on column DBA_CUBES.DESCRIPTION is
'Long Description of the OLAP Cube'
/
comment on column DBA_CUBES.SPARSE_TYPE is
'Text value indicating type of sparsity for the OLAP Cube'
/
comment on column DBA_CUBES.PRECOMPUTE_CONDITION is
'Condition syntax representing precompute condition of the OLAP Cube'
/
comment on column DBA_CUBES.PRECOMPUTE_PERCENT is
'Precompute percent of the OLAP Cube'
/
comment on column DBA_CUBES.PRECOMPUTE_PERCENT_TOP is
'Top precompute percent of the OLAP Cube'
/
comment on column DBA_CUBES.PARTITION_DIMENSION_NAME is
'Name of the Cube Dimension for which there is a partition on the OLAP Cube'
/
comment on column DBA_CUBES.PARTITION_HIERARCHY_NAME is
'Name of the Hierarchy for which there is a partition on the OLAP Cube'
/
comment on column DBA_CUBES.PARTITION_LEVEL_NAME is
'Name of the HierarchyLevel for which there is a partition on the OLAP Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBES FOR SYS.DBA_CUBES
/
GRANT SELECT ON DBA_CUBES to select_catalog_role
/

create or replace view ALL_CUBES
as
SELECT 
  u.name OWNER, 
  o.name CUBE_NAME,
  a.awname AW_NAME,
  syn.syntax_clob CONSISTENT_SOLVE_SPEC,
  d.description_value DESCRIPTION,
  io.option_value SPARSE_TYPE,
  syn2.syntax_clob PRECOMPUTE_CONDITION,
  io2.option_num_value PRECOMPUTE_PERCENT,
  io3.option_num_value PRECOMPUTE_PERCENT_TOP,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME
FROM  
  olap_cubes$ c, 
  user$ u,
  aw$ a, 
  obj$ o, 
  olap_syntax$ syn,
  olap_syntax$ syn2,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 1 --CUBE
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_impl_options$ io4,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od,
  (SELECT
    obj#,
   MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ( exists (select null from v$enabledprivs
                          where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION
                                                -304, -- DELETE ANY PRIMARY DIMENSION
                                                -305, -- DROP ANY PRIMARY DIMENSION
                                                -306, -- INSERT ANY PRIMARY DIMENSION
                                                -307) -- SELECT ANY PRIMARY DIMENSION
                          )
                )
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE
  o.obj#=c.obj#
  AND c.obj#=da.obj#(+)
  AND o.owner#=u.user#(+)
  AND c.awseq#=a.awseq#(+)
  AND c.obj#=d.owning_object_id(+)
  AND syn.owner_id(+)=c.obj#
  AND syn.owner_type(+)=1
  AND syn.ref_role(+)=16 -- consistent solve spec 
  AND syn2.owner_id(+)=c.obj#
  AND syn2.owner_type(+)=1
  AND syn2.ref_role(+)=20 -- precompute condition 
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1
  AND io.option_type(+)=7 -- sparse type 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1
  AND io2.option_type(+)=24 -- precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1
  AND io3.option_type(+)=25 -- precompute percent top 
  AND io4.owning_objectid(+)=c.obj#
  AND io4.object_type(+)=1
  AND io4.option_type(+)=9 -- partition level 
  AND io4.option_num_value=hl.hierarchy_level_id(+)
  AND hl.hierarchy_id=h.hierarchy_id(+)
  AND hl.dim_level_id=dl.level_id(+)
  AND h.dim_obj#=od.obj#(+)
  and (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBES is
'OLAP Cubes in the database accessible to the user'
/
comment on column ALL_CUBES.OWNER is
'Owner of the OLAP Cube'
/
comment on column ALL_CUBES.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column ALL_CUBES.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube'
/
comment on column ALL_CUBES.CONSISTENT_SOLVE_SPEC is
'The Consistent Solve Specification for the OLAP Cube'
/
comment on column ALL_CUBES.DESCRIPTION is
'Long Description of the OLAP Cube'
/
comment on column ALL_CUBES.SPARSE_TYPE is
'Text value indicating type of sparsity for the OLAP Cube'
/
comment on column ALL_CUBES.PRECOMPUTE_CONDITION is
'Condition syntax representing precompute condition of the OLAP Cube'
/
comment on column ALL_CUBES.PRECOMPUTE_PERCENT is
'Precompute percent of the OLAP Cube'
/
comment on column ALL_CUBES.PRECOMPUTE_PERCENT_TOP is
'Top precompute percent of the OLAP Cube'
/
comment on column ALL_CUBES.PARTITION_DIMENSION_NAME is
'Name of the Cube Dimension for which there is a partition on the OLAP Cube'
/
comment on column ALL_CUBES.PARTITION_HIERARCHY_NAME is
'Name of the Hierarchy for which there is a partition on the OLAP Cube'
/
comment on column ALL_CUBES.PARTITION_LEVEL_NAME is
'Name of the HierarchyLevel for which there is a partition on the OLAP Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBES FOR SYS.ALL_CUBES
/
GRANT SELECT ON ALL_CUBES to public
/

create or replace view USER_CUBES
as
SELECT 
  o.name CUBE_NAME,
  a.awname AW_NAME, 
  syn.syntax_clob CONSISTENT_SOLVE_SPEC,
  d.description_value DESCRIPTION,
  io.option_value SPARSE_TYPE,
  syn2.syntax_clob PRECOMPUTE_CONDITION,
  io2.option_num_value PRECOMPUTE_PERCENT,
  io3.option_num_value PRECOMPUTE_PERCENT_TOP,
  od.name PARTITION_DIMENSION_NAME,
  h.hierarchy_name PARTITION_HIERARCHY_NAME,
  dl.level_name PARTITION_LEVEL_NAME
FROM  
  olap_cubes$ c, 
  aw$ a, 
  obj$ o, 
  olap_syntax$ syn,
  olap_syntax$ syn2,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 1 --CUBE
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2,
  olap_impl_options$ io3,
  olap_impl_options$ io4,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_hierarchies$ h,
  obj$ od  
WHERE 
  o.obj#=c.obj#
  AND o.owner#=USERENV('SCHEMAID') 
  AND c.awseq#=a.awseq#(+)
  AND c.obj#=d.owning_object_id(+)
  AND syn.owner_id(+)=c.obj#
  AND syn.owner_type(+)=1
  AND syn.ref_role(+)=16 -- consistent solve spec 
  AND syn2.owner_id(+)=c.obj#
  AND syn2.owner_type(+)=1
  AND syn2.ref_role(+)=20 -- precompute condition 
  AND io.owning_objectid(+)=c.obj#
  AND io.object_type(+)=1
  AND io.option_type(+)=7 -- sparse type 
  AND io2.owning_objectid(+)=c.obj#
  AND io2.object_type(+)=1
  AND io2.option_type(+)=24 -- precompute percent 
  AND io3.owning_objectid(+)=c.obj#
  AND io3.object_type(+)=1
  AND io3.option_type(+)=25 -- precompute percent top 
  AND io4.owning_objectid(+)=c.obj#
  AND io4.object_type(+)=1
  AND io4.option_type(+)=9 -- partition level 
  AND io4.option_num_value=hl.hierarchy_level_id(+)
  AND hl.hierarchy_id=h.hierarchy_id(+)
  AND hl.dim_level_id=dl.level_id(+)
  AND h.dim_obj#=od.obj#(+)
/

comment on table USER_CUBES is
'OLAP Cubes owned by the user in the database'
/
comment on column USER_CUBES.CUBE_NAME is
'Name of the OLAP Cube'
/
comment on column USER_CUBES.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube'
/
comment on column USER_CUBES.CONSISTENT_SOLVE_SPEC is
'The Consistent Solve Specification for the OLAP Cube'
/
comment on column USER_CUBES.DESCRIPTION is
'Long Description of the OLAP Cube'
/
comment on column USER_CUBES.SPARSE_TYPE is
'Text value indicating type of sparsity for the OLAP Cube'
/
comment on column USER_CUBES.PRECOMPUTE_CONDITION is
'Condition syntax representing precompute condition of the OLAP Cube'
/
comment on column USER_CUBES.PRECOMPUTE_PERCENT is
'Precompute percent of the OLAP Cube'
/
comment on column USER_CUBES.PRECOMPUTE_PERCENT_TOP is
'Top precompute percent of the OLAP Cube'
/
comment on column USER_CUBES.PARTITION_DIMENSION_NAME is
'Name of the Cube Dimension for which there is a partition on the OLAP Cube'
/
comment on column USER_CUBES.PARTITION_HIERARCHY_NAME is
'Name of the Hierarchy for which there is a partition on the OLAP Cube'
/
comment on column USER_CUBES.PARTITION_LEVEL_NAME is
'Name of the HierarchyLevel for which there is a partition on the OLAP Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBES FOR SYS.USER_CUBES
/
GRANT SELECT ON USER_CUBES to public
/

-- OLAP_DIMENSIONALITY$ DATA DICTIONARY VIEWS -
create or replace view DBA_CUBE_DIMENSIONALITY
AS
SELECT
   cu.name OWNER,
   co.name CUBE_NAME,
   do.name DIMENSION_NAME,
   diml.order_num ORDER_NUM,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_SPARSE,
   io_eap.option_value ET_ATTR_PREFIX
FROM  
  olap_cubes$ c, 
  user$ cu, 
  obj$ co,
  olap_dimensionality$ diml,
  obj$ do,
  olap_impl_options$ io,
  olap_impl_options$ io_eap
WHERE 	
  co.obj# = c.obj#
  AND co.owner# = cu.user#
  AND diml.dimensioned_object_type = 1 --CUBE
  AND diml.dimensioned_object_id = c.obj#
  AND diml.dimension_type = 11 --DIMENSION
  AND diml.dimension_id = do.obj#
  AND io.object_type(+) = 16 -- DIMENSIONALITY 
  AND io.owning_objectid(+) = diml.dimensionality_id
  AND io.option_type(+) = 10 -- IS_SPARSE_DIM   
  AND io_eap.object_type(+) = 16 -- DIMENSIONALITY 
  AND io_eap.owning_objectid(+) = diml.dimensionality_id
  AND io_eap.option_type(+) =  36 -- ET_ATTR_PREFIX   
/

comment on table DBA_CUBE_DIMENSIONALITY is
'OLAP Cube Dimensionality in the database'
/
comment on column DBA_CUBE_DIMENSIONALITY.OWNER is
'Owner of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.CUBE_NAME is
'Name of the OLAP Cube of the Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.DIMENSION_NAME is
'Name of the Dimension of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.ORDER_NUM is
'Order number of the OLAP Cube Dimensionality'
/
comment on column DBA_CUBE_DIMENSIONALITY.IS_SPARSE is
'Indication of whether or not the Dimension is Sparse in the Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIMENSIONALITY FOR SYS.DBA_CUBE_DIMENSIONALITY
/
GRANT SELECT ON DBA_CUBE_DIMENSIONALITY to select_catalog_role
/

create or replace view ALL_CUBE_DIMENSIONALITY
AS
SELECT
   cu.name OWNER,
   co.name CUBE_NAME,
   do.name DIMENSION_NAME,
   diml.order_num ORDER_NUM,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_SPARSE,
   io_eap.option_value ET_ATTR_PREFIX
FROM  
  olap_cubes$ c, 
  user$ cu, 
  obj$ co,
  olap_dimensionality$ diml,
  obj$ do,
  olap_impl_options$ io,
  olap_impl_options$ io_eap,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ( exists (select null from v$enabledprivs
                          where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION
                                                -304, -- DELETE ANY PRIMARY DIMENSION
                                                -305, -- DROP ANY PRIMARY DIMENSION
                                                -306, -- INSERT ANY PRIMARY DIMENSION
                                                -307) -- SELECT ANY PRIMARY DIMENSION
                          )
                )
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      olap_dimensionality$ diml,
      olap_cube_dimensions$ dim,
      obj$ do
    WHERE
      do.obj# = dim.obj#
      AND diml.dimensioned_object_type = 1 --CUBE
      AND diml.dimensioned_object_id = c.obj#
      AND diml.dimension_type = 11 --DIMENSION
      AND diml.dimension_id = do.obj#
    )
    GROUP BY obj# ) da 
WHERE 	
  co.obj# = c.obj#
  AND c.obj#=da.obj#(+)
  AND co.owner# = cu.user#
  AND diml.dimensioned_object_type = 1 --CUBE
  AND diml.dimensioned_object_id = c.obj#
  AND diml.dimension_type = 11 --DIMENSION
  AND diml.dimension_id = do.obj#
  AND io.object_type(+) = 16 -- DIMENSIONALITY 
  AND io.owning_objectid(+) = diml.dimensionality_id
  AND io.option_type(+) = 10 -- IS_SPARSE_DIM   
  AND io_eap.object_type(+) = 16 -- DIMENSIONALITY 
  AND io_eap.owning_objectid(+) = diml.dimensionality_id
  AND io_eap.option_type(+) =  36 -- ET_ATTR_PREFIX   
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_DIMENSIONALITY is
'OLAP Cube Dimensionality in the database accessible to the user'
/
comment on column ALL_CUBE_DIMENSIONALITY.OWNER is
'Owner of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMENSIONALITY.CUBE_NAME is
'Name of the OLAP Cube of the Dimensionality'
/
comment on column ALL_CUBE_DIMENSIONALITY.DIMENSION_NAME is
'Name of the Dimension of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMENSIONALITY.ORDER_NUM is
'Order number of the OLAP Cube Dimensionality'
/
comment on column ALL_CUBE_DIMENSIONALITY.IS_SPARSE is
'Indication of whether or not the Dimension is Sparse in the Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIMENSIONALITY FOR SYS.ALL_CUBE_DIMENSIONALITY
/
GRANT SELECT ON ALL_CUBE_DIMENSIONALITY to public
/

create or replace view USER_CUBE_DIMENSIONALITY
AS
SELECT
   co.name CUBE_NAME,
   do.name DIMENSION_NAME,
   diml.order_num ORDER_NUM,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_SPARSE,
   io_eap.option_value ET_ATTR_PREFIX
FROM  
  olap_cubes$ c, 
  obj$ co,
  olap_dimensionality$ diml,
  obj$ do,
  olap_impl_options$ io,
  olap_impl_options$ io_eap
WHERE 	
  co.obj# = c.obj# AND co.owner#=USERENV('SCHEMAID')
  AND diml.dimensioned_object_type = 1 --CUBE
  AND diml.dimensioned_object_id = c.obj#
  AND diml.dimension_type = 11 --DIMENSION
  AND diml.dimension_id = do.obj#
  AND io.object_type(+) = 16 -- DIMENSIONALITY 
  AND io.owning_objectid(+) = diml.dimensionality_id
  AND io.option_type(+) = 10 -- IS_SPARSE_DIM   
  AND io_eap.object_type(+) = 16 -- DIMENSIONALITY 
  AND io_eap.owning_objectid(+) = diml.dimensionality_id
  AND io_eap.option_type(+) =  36 -- ET_ATTR_PREFIX   
/
comment on table USER_CUBE_DIMENSIONALITY is
'OLAP Cube Dimensionality owned by the user in the database'
/
comment on column USER_CUBE_DIMENSIONALITY.CUBE_NAME is
'Name of the OLAP Cube of the Dimensionality'
/
comment on column USER_CUBE_DIMENSIONALITY.DIMENSION_NAME is
'Name of the Dimension of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMENSIONALITY.ORDER_NUM is
'Order number of the OLAP Cube Dimensionality'
/
comment on column USER_CUBE_DIMENSIONALITY.IS_SPARSE is
'Indication of whether or not the Dimension is Sparse in the Cube'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIMENSIONALITY FOR SYS.USER_CUBE_DIMENSIONALITY
/
GRANT SELECT ON USER_CUBE_DIMENSIONALITY to public
/

-- OLAP_CUBE_MEASURES DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_MEASURES
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME, 
  m.measure_name MEASURE_NAME,
  ss.syntax_clob OVERRIDE_SOLVE_SPEC, 
  DECODE(m.measure_type, 1, 'BASE', 2, 'DERIVED') MEASURE_TYPE,
  DECODE(m.measure_type, 2, s.syntax_clob) EXPRESSION,
  d.description_value DESCRIPTION,
  DECODE(m.type#, 1, decode(m.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(m.scale, null,
                            decode(m.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(m.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(m.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(m.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||m.scale|| ')',
                  179, 'TIME(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||m.scale|| ')',
                  181, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||m.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||m.precision#||') TO SECOND(' ||
                        m.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  m.length DATA_LENGTH, 
  m.precision# DATA_PRECISION, 
  m.scale DATA_SCALE
FROM   
  olap_measures$ m, 
  user$ u, 
  obj$ o, 
  olap_syntax$ ss,
  olap_syntax$ s, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 2 --MEASURE
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.cube_obj#=o.obj#
  AND o.owner#=u.user# 
  AND m.measure_id=s.owner_id(+) 
  AND m.measure_id=ss.owner_id(+)
  AND m.is_hidden=0 --NOT HIDDEN
  AND s.owner_type(+)=2 --MEASURE 
  AND s.ref_role(+)=14 --DERIVED_MEAS_EXPRESSION 
  AND ss.owner_type(+)=2 --MEASURE
  AND ss.ref_role(+)=16 --CONSISTENT_SOLVE_SPEC
  AND m.measure_id=d.owning_object_id(+)
/

comment on table DBA_CUBE_MEASURES is
'OLAP Measures in the database'
/
comment on column DBA_CUBE_MEASURES.OWNER is
'Owner of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.CUBE_NAME is
'Name of the OLAP Cube which owns the Measure'
/
comment on column DBA_CUBE_MEASURES.MEASURE_NAME is
'Name of Measure in the OLAP Cube'
/
comment on column DBA_CUBE_MEASURES.OVERRIDE_SOLVE_SPEC is
'Override solve specification of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.MEASURE_TYPE is
'Type of Measure in the OLAP Cube'
/
comment on column DBA_CUBE_MEASURES.EXPRESSION is
'Expression of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DESCRIPTION is
'Description of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DATA_TYPE is
'Data Type of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DATA_LENGTH is
'Data Length of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DATA_PRECISION is
'Data Precision of the OLAP Measure'
/
comment on column DBA_CUBE_MEASURES.DATA_SCALE is
'Data Scale of the OLAP Measure'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_MEASURES FOR SYS.DBA_CUBE_MEASURES
/
GRANT SELECT ON DBA_CUBE_MEASURES to select_catalog_role
/

create or replace view ALL_CUBE_MEASURES
as
SELECT 
  u.name OWNER,
  o.name CUBE_NAME, 
  m.measure_name MEASURE_NAME,
  ss.syntax_clob OVERRIDE_SOLVE_SPEC, 
  DECODE(m.measure_type, 1, 'BASE', 2, 'DERIVED') MEASURE_TYPE,
  DECODE(m.measure_type, 2, s.syntax_clob) EXPRESSION,
  d.description_value DESCRIPTION,
  DECODE(m.type#, 1, decode(m.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(m.scale, null,
                            decode(m.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(m.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(m.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(m.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||m.scale|| ')',
                  179, 'TIME(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||m.scale|| ')',
                  181, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||m.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||m.precision#||') TO SECOND(' ||
                        m.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  m.length DATA_LENGTH, 
  m.precision# DATA_PRECISION, 
  m.scale DATA_SCALE
FROM   
  olap_measures$ m, 
  user$ u, 
  obj$ o, 
  olap_syntax$ ss,
  olap_syntax$ s, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 2 --MEASURE
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ( exists (select null from v$enabledprivs
                          where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION
                                                -304, -- DELETE ANY PRIMARY DIMENSION
                                                -305, -- DROP ANY PRIMARY DIMENSION
                                                -306, -- INSERT ANY PRIMARY DIMENSION
                                                -307) -- SELECT ANY PRIMARY DIMENSION
                          )
                )
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE  
  m.cube_obj#=o.obj#
  AND o.obj#=da.obj#(+)
  AND o.owner#=u.user# 
  AND m.measure_id=s.owner_id(+) 
  AND m.measure_id=ss.owner_id(+)
  AND m.is_hidden=0 --NOT HIDDEN
  AND s.owner_type(+)=2 --MEASURE 
  AND s.ref_role(+)=14 --DERIVED_MEAS_EXPRESSION 
  AND ss.owner_type(+)=2 --MEASURE
  AND ss.ref_role(+)=16 --CONSISTENT_SOLVE_SPEC
  AND m.measure_id=d.owning_object_id(+)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_MEASURES is
'OLAP Measures in the database accessible to the user'
/
comment on column ALL_CUBE_MEASURES.OWNER is
'Owner of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.CUBE_NAME is
'Name of the OLAP Cube which owns the Measure'
/
comment on column ALL_CUBE_MEASURES.MEASURE_NAME is
'Name of Measure in the OLAP Cube'
/
comment on column ALL_CUBE_MEASURES.OVERRIDE_SOLVE_SPEC is
'Override solve specification of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.MEASURE_TYPE is
'Type of Measure in the OLAP Cube'
/
comment on column ALL_CUBE_MEASURES.EXPRESSION is
'Expression of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DESCRIPTION is
'Description of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DATA_TYPE is
'Data Type of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DATA_LENGTH is
'Data Length of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DATA_PRECISION is
'Data Precision of the OLAP Measure'
/
comment on column ALL_CUBE_MEASURES.DATA_SCALE is
'Data Scale of the OLAP Measure'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_MEASURES FOR SYS.ALL_CUBE_MEASURES
/
GRANT SELECT ON ALL_CUBE_MEASURES to public
/


create or replace view USER_CUBE_MEASURES
as
SELECT 
  o.name CUBE_NAME, 
  m.measure_name MEASURE_NAME,
  ss.syntax_clob OVERRIDE_SOLVE_SPEC, 
  DECODE(m.measure_type, 1, 'BASE', 2, 'DERIVED') MEASURE_TYPE,
  DECODE(m.measure_type, 2, s.syntax_clob) EXPRESSION,
  d.description_value DESCRIPTION,
  DECODE(m.type#, 1, decode(m.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(m.scale, null,
                            decode(m.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(m.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(m.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(m.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||m.scale|| ')',
                  179, 'TIME(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||m.scale|| ')',
                  181, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||m.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||m.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||m.precision#||') TO SECOND(' ||
                        m.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  m.length DATA_LENGTH, 
  m.precision# DATA_PRECISION, 
  m.scale DATA_SCALE
FROM   
  olap_measures$ m, 
  obj$ o, 
  olap_syntax$ ss,
  olap_syntax$ s, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 2 --MEASURE
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.cube_obj#=o.obj# AND o.owner#=USERENV('SCHEMAID')
  AND m.measure_id=s.owner_id(+) 
  AND m.measure_id=ss.owner_id(+)
  AND m.is_hidden=0 --NOT HIDDEN
  AND s.owner_type(+)=2 --MEASURE 
  AND s.ref_role(+)=14 --DERIVED_MEAS_EXPRESSION 
  AND ss.owner_type(+)=2 --MEASURE
  AND ss.ref_role(+)=16 --CONSISTENT_SOLVE_SPEC
  AND m.measure_id=d.owning_object_id(+)
/

comment on table USER_CUBE_MEASURES is
'OLAP Measures owned by the user in the database'
/
comment on column USER_CUBE_MEASURES.CUBE_NAME is
'Name of the OLAP Cube which owns the Measure'
/
comment on column USER_CUBE_MEASURES.MEASURE_NAME is
'Name of Measure in the OLAP Cube'
/
comment on column USER_CUBE_MEASURES.OVERRIDE_SOLVE_SPEC is
'Override solve specification of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.MEASURE_TYPE is
'Type of Measure in the OLAP Cube'
/
comment on column USER_CUBE_MEASURES.EXPRESSION is
'Expression of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DESCRIPTION is
'Long Description of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DATA_TYPE is
'Data Type of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DATA_LENGTH is
'Data Length of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DATA_PRECISION is
'Data Precision of the OLAP Measure'
/
comment on column USER_CUBE_MEASURES.DATA_SCALE is
'Data Scale of the OLAP Measure'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_MEASURES FOR SYS.USER_CUBE_MEASURES
/
GRANT SELECT ON USER_CUBE_MEASURES to public
/


-- OLAP_CUBE_DIMENSIONS DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_DIMENSIONS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  DECODE(dim.dimension_type,1, 'STANDARD',
                            2, 'TIME',
                            3, 'LINEITEM',
                            4, 'MEASURE',
                            5, 'LANGUAGE',
                            6, 'FINANCIAL_ELEMENT',
                            7, 'SPATIAL') DIMENSION_TYPE, 
  a.awname AW_NAME, 
  h.hierarchy_name DEFAULT_HIERARCHY_NAME, 
  d.description_value DESCRIPTION
FROM   
   olap_cube_dimensions$ dim, 
   user$ u,  
   aw$ a, 
   obj$ o, 
   olap_hierarchies$ h, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 11 --DIMENSION
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
   o.obj#=dim.obj# AND o.owner#=u.user#
   AND dim.awseq#=a.awseq#(+) 
   AND h.hierarchy_id(+)=dim.default_hierarchy_id
   AND d.owning_object_id(+)=dim.obj#
/

comment on table DBA_CUBE_DIMENSIONS is
'OLAP Cube Dimensions in the database'
/
comment on column DBA_CUBE_DIMENSIONS.OWNER is
'Owner of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DIMENSION_NAME is
'Name of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DIMENSION_TYPE is
'Type of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DESCRIPTION is
'Description of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DEFAULT_HIERARCHY_NAME is
'Default Hierarchy name of the OLAP Cube Dimension'
/
comment on column DBA_CUBE_DIMENSIONS.DESCRIPTION is
'Long Description of the OLAP Cube Dimension'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIMENSIONS 
FOR SYS.DBA_CUBE_DIMENSIONS
/
GRANT SELECT ON DBA_CUBE_DIMENSIONS to select_catalog_role
/

create or replace view ALL_CUBE_DIMENSIONS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  DECODE(dim.dimension_type,1, 'STANDARD',
                            2, 'TIME',
                            3, 'LINEITEM',
                            4, 'MEASURE',
                            5, 'LANGUAGE',
                            6, 'FINANCIAL_ELEMENT',
                            7, 'SPATIAL') DIMENSION_TYPE, 
  a.awname AW_NAME, 
  h.hierarchy_name DEFAULT_HIERARCHY_NAME, 
  d.description_value DESCRIPTION
FROM   
   olap_cube_dimensions$ dim, 
   user$ u,  
   aw$ a, 
   obj$ o, 
   olap_hierarchies$ h, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 11 --DIMENSION
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
   o.obj#=dim.obj# AND o.owner#=u.user#
   AND dim.awseq#=a.awseq#(+) 
   AND h.hierarchy_id(+)=dim.default_hierarchy_id
   AND d.owning_object_id(+)=dim.obj#
   AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_DIMENSIONS is
'OLAP Cube Dimensions in the database accessible by the user'
/
comment on column ALL_CUBE_DIMENSIONS.OWNER is
'Owner of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DIMENSION_NAME is
'Name of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DIMENSION_TYPE is
'Type of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DESCRIPTION is
'Description of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DEFAULT_HIERARCHY_NAME is
'Default Hierarchy name of the OLAP Cube Dimension'
/
comment on column ALL_CUBE_DIMENSIONS.DESCRIPTION is
'Long Description of the OLAP Cube Dimension'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIMENSIONS FOR SYS.ALL_CUBE_DIMENSIONS
/
GRANT SELECT ON ALL_CUBE_DIMENSIONS to public
/

create or replace view USER_CUBE_DIMENSIONS
as
SELECT 
  o.name DIMENSION_NAME, 
  DECODE(dim.dimension_type,1, 'STANDARD',
                            2, 'TIME',
                            3, 'LINEITEM',
                            4, 'MEASURE',
                            5, 'LANGUAGE',
                            6, 'FINANCIAL_ELEMENT',
                            7, 'SPATIAL') DIMENSION_TYPE, 
  a.awname AW_NAME, 
  h.hierarchy_name DEFAULT_HIERARCHY_NAME, 
  d.description_value DESCRIPTION
FROM   
   olap_cube_dimensions$ dim, 
   aw$ a, 
   obj$ o, 
   olap_hierarchies$ h, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 11 --DIMENSION
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
   o.obj#=dim.obj# AND o.owner#=USERENV('SCHEMAID')
   AND dim.awseq#=a.awseq#(+) 
   AND h.hierarchy_id(+)=dim.default_hierarchy_id
   AND d.owning_object_id(+)=dim.obj#
/

comment on table USER_CUBE_DIMENSIONS is
'OLAP Cube Dimensions owned by the user in the database'
/
comment on column USER_CUBE_DIMENSIONS.DIMENSION_NAME is
'Name of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.DIMENSION_TYPE is
'Type of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.AW_NAME is
'Name of the Analytic Workspace which owns the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.DESCRIPTION is
'Description of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.DEFAULT_HIERARCHY_NAME is
'Default Hierarchy name of the OLAP Cube Dimension'
/
comment on column USER_CUBE_DIMENSIONS.DESCRIPTION is
'Long Description of the OLAP Cube Dimension'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIMENSIONS FOR SYS.USER_CUBE_DIMENSIONS
/
GRANT SELECT ON USER_CUBE_DIMENSIONS to public
/

-- OLAP_CUBE_HIERARCHIES DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_HIERARCHIES
as
SELECT 
   u.name OWNER, 
   o.name DIMENSION_NAME, 
   h.hierarchy_name HIERARCHY_NAME, 
   DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') HIERARCHY_TYPE,  
   d.description_value DESCRIPTION,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_RAGGED,
   (case
     when io2.option_num_value is null then 0
     else io2.option_num_value
    end) IS_SKIP_LEVEL
FROM 
  olap_hierarchies$ h, 
  user$ u, 
  obj$ o, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 13 --HIERARCHY
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2
WHERE 
  h.dim_obj#=o.obj#
  AND o.owner#=u.user#
  AND d.owning_object_id(+)=h.hierarchy_id
  AND io.object_type(+) = 13 -- HIERARCHY 
  AND io.owning_objectid(+) = h.hierarchy_id
  AND io.option_type(+) = 6 -- IS_RAGGED 
  AND io2.object_type(+) = 13 -- HIERARCHY 
  AND io2.owning_objectid(+) = h.hierarchy_id
  AND io2.option_type(+) = 1 -- IS_SKIP_LEVEL 
/

comment on table DBA_CUBE_HIERARCHIES is
'OLAP Hierarchies in the database'
/
comment on column DBA_CUBE_HIERARCHIES.OWNER is
'Owner of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.HIERARCHY_NAME is
'Name of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.HIERARCHY_TYPE is
'Type of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.DESCRIPTION is
'Long Description of the OLAP Hierarchy'
/
comment on column DBA_CUBE_HIERARCHIES.IS_RAGGED is
'Indication of whether the OLAP Hierarchy is Ragged'
/
comment on column DBA_CUBE_HIERARCHIES.IS_SKIP_LEVEL is
'Indication of whether the OLAP Hierarchy is SkipLevel'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_HIERARCHIES FOR SYS.DBA_CUBE_HIERARCHIES
/
GRANT SELECT ON DBA_CUBE_HIERARCHIES to select_catalog_role
/

create or replace view ALL_CUBE_HIERARCHIES
as
SELECT 
   u.name OWNER, 
   o.name DIMENSION_NAME, 
   h.hierarchy_name HIERARCHY_NAME, 
   DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') HIERARCHY_TYPE,  
   d.description_value DESCRIPTION,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_RAGGED,
   (case
     when io2.option_num_value is null then 0
     else io2.option_num_value
    end) IS_SKIP_LEVEL
FROM 
  olap_hierarchies$ h, 
  user$ u, 
  obj$ o, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 13 --HIERARCHY
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2
WHERE 
  h.dim_obj#=o.obj#
  AND o.owner#=u.user#
  AND d.owning_object_id(+)=h.hierarchy_id
  AND io.object_type(+) = 13 -- HIERARCHY 
  AND io.owning_objectid(+) = h.hierarchy_id
  AND io.option_type(+) = 6 -- IS_RAGGED 
  AND io2.object_type(+) = 13 -- HIERARCHY 
  AND io2.owning_objectid(+) = h.hierarchy_id
  AND io2.option_type(+) = 1 -- IS_SKIP_LEVEL 
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_HIERARCHIES is
'OLAP Hierarchies in the database accessible by the user'
/
comment on column ALL_CUBE_HIERARCHIES.OWNER is
'Owner of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.HIERARCHY_NAME is
'Name of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.HIERARCHY_TYPE is
'Type of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.DESCRIPTION is
'Long Description of the OLAP Hierarchy'
/
comment on column ALL_CUBE_HIERARCHIES.IS_RAGGED is
'Indication of whether the OLAP Hierarchy is Ragged'
/
comment on column ALL_CUBE_HIERARCHIES.IS_SKIP_LEVEL is
'Indication of whether the OLAP Hierarchy is SkipLevel'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_HIERARCHIES FOR SYS.ALL_CUBE_HIERARCHIES
/
GRANT SELECT ON ALL_CUBE_HIERARCHIES to public
/

create or replace view USER_CUBE_HIERARCHIES
as
SELECT 
   o.name DIMENSION_NAME, 
   h.hierarchy_name HIERARCHY_NAME, 
   DECODE(h.hierarchy_type, 1, 'LEVEL', 2, 'VALUE') HIERARCHY_TYPE,  
   d.description_value DESCRIPTION,
   (case
     when io.option_num_value is null then 0
     else io.option_num_value
    end) IS_RAGGED,
   (case
     when io2.option_num_value is null then 0
     else io2.option_num_value
    end) IS_SKIP_LEVEL
FROM 
  olap_hierarchies$ h, 
  obj$ o, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 13 --HIERARCHY
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_impl_options$ io,
  olap_impl_options$ io2
WHERE 
  h.dim_obj#=o.obj# AND o.owner#=USERENV('SCHEMAID')
  AND d.owning_object_id(+)=h.hierarchy_id
  AND io.object_type(+) = 13 -- HIERARCHY 
  AND io.owning_objectid(+) = h.hierarchy_id
  AND io.option_type(+) = 6 -- IS_RAGGED 
  AND io2.object_type(+) = 13 -- HIERARCHY 
  AND io2.owning_objectid(+) = h.hierarchy_id
  AND io2.option_type(+) = 1 -- IS_SKIP_LEVEL 
/

comment on table USER_CUBE_HIERARCHIES is
'OLAP Hierarchies owned by the user in the database'
/
comment on column USER_CUBE_HIERARCHIES.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.HIERARCHY_NAME is
'Name of the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.HIERARCHY_TYPE is
'Type of the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.DESCRIPTION is
'Long Description of the OLAP Hierarchy'
/
comment on column USER_CUBE_HIERARCHIES.IS_RAGGED is
'Indication of whether the OLAP Hierarchy is Ragged'
/
comment on column USER_CUBE_HIERARCHIES.IS_SKIP_LEVEL is
'Indication of whether the OLAP Hierarchy is SkipLevel'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_HIERARCHIES FOR SYS.USER_CUBE_HIERARCHIES
/
GRANT SELECT ON USER_CUBE_HIERARCHIES to public
/

-- OLAP_HIER_LEVELS DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_HIER_LEVELS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  h.hierarchy_name HIERARCHY_NAME, 
  dl.level_name LEVEL_NAME, 
  hl.order_num ORDER_NUM,  
  d.description_value DESCRIPTION
FROM 
  olap_hier_levels$ hl, 
  user$ u, obj$ o, 
  olap_hierarchies$ h,
  olap_dim_levels$ dl, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 14 --HIER_LEVEL
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  hl.hierarchy_id=h.hierarchy_id AND o.owner#=u.user#
  AND dl.level_id=hl.dim_level_id AND o.obj#=dl.dim_obj#
  AND d.owning_object_id(+)=hl.hierarchy_level_id
/

comment on table DBA_CUBE_HIER_LEVELS is
'OLAP Hierarchy Levels in the database'
/
comment on column DBA_CUBE_HIER_LEVELS.OWNER is
'Owner of the OLAP Hierarchy Level'
/
comment on column DBA_CUBE_HIER_LEVELS.DIMENSION_NAME is
'Name of the owning Dimension of the OLAP Hierarchy Level'
/
comment on column DBA_CUBE_HIER_LEVELS.HIERARCHY_NAME is
'Name of the owning Hierarchy of the OLAP Hierarchy Level'
/
comment on column DBA_CUBE_HIER_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column DBA_CUBE_HIER_LEVELS.ORDER_NUM is
'Order number of the OLAP Hierarchy Level within the hierarchy'
/
comment on column DBA_CUBE_HIER_LEVELS.DESCRIPTION is
'Long Description of the OLAP Hierarchy Level'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_HIER_LEVELS 
FOR SYS.DBA_CUBE_HIER_LEVELS
/
GRANT SELECT ON DBA_CUBE_HIER_LEVELS to select_catalog_role
/

create or replace view ALL_CUBE_HIER_LEVELS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  h.hierarchy_name HIERARCHY_NAME, 
  dl.level_name LEVEL_NAME, 
  hl.order_num ORDER_NUM,  
  d.description_value DESCRIPTION
FROM 
  olap_hier_levels$ hl, 
  user$ u, obj$ o, 
  olap_hierarchies$ h,
  olap_dim_levels$ dl, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 14 --HIER_LEVEL
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  hl.hierarchy_id=h.hierarchy_id AND o.owner#=u.user#
  AND dl.level_id=hl.dim_level_id AND o.obj#=dl.dim_obj#
  AND d.owning_object_id(+)=hl.hierarchy_level_id
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_HIER_LEVELS is
'OLAP Hierarchy Levels in the database accessible to the user'
/
comment on column ALL_CUBE_HIER_LEVELS.OWNER is
'Owner of the OLAP Hierarchy Level'
/
comment on column ALL_CUBE_HIER_LEVELS.DIMENSION_NAME is
'Name of the owning Dimension of the OLAP Hierarchy Level'
/
comment on column ALL_CUBE_HIER_LEVELS.HIERARCHY_NAME is
'Name of the owning Hierarchy of the OLAP Hierarchy Level'
/
comment on column ALL_CUBE_HIER_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column ALL_CUBE_HIER_LEVELS.ORDER_NUM is
'Order number of the OLAP Hierarchy Level within the hierarchy'
/
comment on column ALL_CUBE_HIER_LEVELS.DESCRIPTION is
'Long Description of the OLAP Hierarchy Level'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_HIER_LEVELS 
FOR SYS.ALL_CUBE_HIER_LEVELS
/
GRANT SELECT ON ALL_CUBE_HIER_LEVELS to public
/

create or replace view USER_CUBE_HIER_LEVELS
as
SELECT 
  o.name DIMENSION_NAME, 
  h.hierarchy_name HIERARCHY_NAME, 
  dl.level_name LEVEL_NAME, 
  hl.order_num ORDER_NUM,  
  d.description_value DESCRIPTION
FROM 
  olap_hier_levels$ hl, 
  obj$ o, 
  olap_hierarchies$ h,
  olap_dim_levels$ dl, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 14 --HIER_LEVEL
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  hl.hierarchy_id=h.hierarchy_id AND o.owner#=USERENV('SCHEMAID')
  AND dl.level_id=hl.dim_level_id AND o.obj#=dl.dim_obj#
  AND d.owning_object_id(+)=hl.hierarchy_level_id
/

comment on table USER_CUBE_HIER_LEVELS is
'OLAP Hierarchy Levels owned by the user in the database'
/
comment on column USER_CUBE_HIER_LEVELS.DIMENSION_NAME is
'Name of the owning Dimension of the OLAP Hierarchy Level'
/
comment on column USER_CUBE_HIER_LEVELS.HIERARCHY_NAME is
'Name of the owning Hierarchy of the OLAP Hierarchy Level'
/
comment on column USER_CUBE_HIER_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column USER_CUBE_HIER_LEVELS.ORDER_NUM is
'Order number of the OLAP Hierarchy Level within the hierarchy'
/
comment on column USER_CUBE_HIER_LEVELS.DESCRIPTION is
'Long Description of the OLAP Hierarchy Level'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_HIER_LEVELS 
FOR SYS.USER_CUBE_HIER_LEVELS
/
GRANT SELECT ON USER_CUBE_HIER_LEVELS to public
/

-- OLAP_DIM_LEVELS$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_DIM_LEVELS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  dl.level_name LEVEL_NAME, 
  d.description_value DESCRIPTION
FROM 
  obj$ o, 
  olap_dim_levels$ dl, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 12 --DIM_LEVEL
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  o.obj#=dl.dim_obj# AND o.owner#=u.user#
  AND d.owning_object_id(+)=dl.level_id
/

comment on table DBA_CUBE_DIM_LEVELS is
'OLAP Dimension Levels in the database'
/
comment on column DBA_CUBE_DIM_LEVELS.OWNER is
'Owner of the OLAP Dimension Level'
/
comment on column DBA_CUBE_DIM_LEVELS.DIMENSION_NAME is
'Name of the dimension which owns the OLAP Dimension Level'
/
comment on column DBA_CUBE_DIM_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column DBA_CUBE_DIM_LEVELS.DESCRIPTION is
'Long Description of the OLAP Dimension Level'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIM_LEVELS 
FOR SYS.DBA_CUBE_DIM_LEVELS
/
GRANT SELECT ON DBA_CUBE_DIM_LEVELS to select_catalog_role
/

create or replace view ALL_CUBE_DIM_LEVELS
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  dl.level_name LEVEL_NAME, 
  d.description_value DESCRIPTION
FROM 
  obj$ o, 
  olap_dim_levels$ dl, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 12 --DIM_LEVEL
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  o.obj#=dl.dim_obj# AND o.owner#=u.user#
  AND d.owning_object_id(+)=dl.level_id
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_DIM_LEVELS is
'OLAP Dimension Levels in the database accessible by the user'
/
comment on column ALL_CUBE_DIM_LEVELS.OWNER is
'Owner of the OLAP Dimension Level'
/
comment on column ALL_CUBE_DIM_LEVELS.DIMENSION_NAME is
'Name of the dimension which owns the OLAP Dimension Level'
/
comment on column ALL_CUBE_DIM_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column ALL_CUBE_DIM_LEVELS.DESCRIPTION is
'Long Description of the OLAP Dimension Level'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIM_LEVELS 
FOR SYS.ALL_CUBE_DIM_LEVELS
/
GRANT SELECT ON ALL_CUBE_DIM_LEVELS to public
/

create or replace view USER_CUBE_DIM_LEVELS
as
SELECT 
  o.name DIMENSION_NAME, 
  dl.level_name LEVEL_NAME, 
  d.description_value DESCRIPTION
FROM 
  obj$ o, 
  olap_dim_levels$ dl, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 12 --DIM_LEVEL
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  o.obj#=dl.dim_obj# AND o.owner#=USERENV('SCHEMAID')
  AND d.owning_object_id(+)=dl.level_id
/

comment on table USER_CUBE_DIM_LEVELS is
'OLAP Dimension Levels owned by the user in the database'
/
comment on column USER_CUBE_DIM_LEVELS.DIMENSION_NAME is
'Name of the dimension which owns the OLAP Dimension Level'
/
comment on column USER_CUBE_DIM_LEVELS.LEVEL_NAME is
'Name of the OLAP Dimension Level'
/
comment on column USER_CUBE_DIM_LEVELS.DESCRIPTION is
'Long Description of the OLAP Dimension Level'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIM_LEVELS 
FOR SYS.USER_CUBE_DIM_LEVELS
/
GRANT SELECT ON USER_CUBE_DIM_LEVELS to public
/

-- OLAP_CUBE_ATTRIBUTES$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_ATTRIBUTES
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  a.attribute_name ATTRIBUTE_NAME, 
  tdo.name TARGET_DIMENSION_NAME,
  (CASE a.attribute_role_mask
     WHEN 1 THEN 'SHORT_DESCRIPTION'
     WHEN 2 THEN 'LONG_DESCRIPTION'
     WHEN 3 THEN 'DESCRIPTION'
     WHEN 4 THEN 'TIME_SPAN'
     WHEN 8 THEN 'END_DATE'
     WHEN 16 THEN 'START_DATE'
     ELSE null END) ATTRIBUTE_ROLE,
  d.description_value DESCRIPTION,
  DECODE(a.type#, 1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(a.scale, null,
                            decode(a.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||a.scale|| ')',
                  179, 'TIME(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||a.scale|| ')',
                  181, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||a.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||a.precision#||') TO SECOND(' ||
                        a.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  a.length DATA_LENGTH, 
  a.precision# DATA_PRECISION, 
  a.scale DATA_SCALE
FROM 
  olap_attributes$ a, 
  obj$ o, 
  obj$ tdo, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 15 --ATTRIBUTE
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  o.obj#=a.dim_obj#
  AND o.owner#=u.user#
  AND a.target_dim#=tdo.obj#(+)
  AND a.attribute_id = d.owning_object_id(+)
/

comment on table DBA_CUBE_ATTRIBUTES is
'OLAP Attributes in the database'
/
comment on column DBA_CUBE_ATTRIBUTES.OWNER is
'Owner of OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DIMENSION_NAME is
'Name of owning Cube Dimension of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.TARGET_DIMENSION_NAME is
'Name of Target Dimension of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.ATTRIBUTE_ROLE is
'Special role this attribute plays (e.g. ShortDescription), or null if none'
/
comment on column DBA_CUBE_ATTRIBUTES.DESCRIPTION is
'Long Description of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DATA_TYPE is
'Data Type of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DATA_LENGTH is
'Data Length of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DATA_PRECISION is
'Data Precision of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTRIBUTES.DATA_SCALE is
'Data Scale of the OLAP Attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_ATTRIBUTES
FOR SYS.DBA_CUBE_ATTRIBUTES
/
GRANT SELECT ON DBA_CUBE_ATTRIBUTES to select_catalog_role
/

create or replace view ALL_CUBE_ATTRIBUTES
as
SELECT 
  u.name OWNER, 
  o.name DIMENSION_NAME, 
  a.attribute_name ATTRIBUTE_NAME, 
  tdo.name TARGET_DIMENSION_NAME,
  (CASE a.attribute_role_mask
     WHEN 1 THEN 'SHORT_DESCRIPTION'
     WHEN 2 THEN 'LONG_DESCRIPTION'
     WHEN 3 THEN 'DESCRIPTION'
     WHEN 4 THEN 'TIME_SPAN'
     WHEN 8 THEN 'END_DATE'
     WHEN 16 THEN 'START_DATE'
     ELSE null END) ATTRIBUTE_ROLE,
  d.description_value DESCRIPTION,
  DECODE(a.type#, 1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(a.scale, null,
                            decode(a.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||a.scale|| ')',
                  179, 'TIME(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||a.scale|| ')',
                  181, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||a.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||a.precision#||') TO SECOND(' ||
                        a.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  a.length DATA_LENGTH, 
  a.precision# DATA_PRECISION, 
  a.scale DATA_SCALE
FROM 
  olap_attributes$ a, 
  obj$ o, 
  obj$ tdo, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 15 --ATTRIBUTE
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_syntax$ s
WHERE 
  o.obj#=a.dim_obj#
  AND o.owner#=u.user#
  AND a.target_dim#=tdo.obj#(+)
  AND a.attribute_id=s.owner_id(+) 
  AND s.owner_type(+) = 15 --ATTRIBUTE 
  AND s.ref_role(+) = 2 --ATTRIBUTE_ROLE 
  AND a.attribute_id = d.owning_object_id(+)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_ATTRIBUTES is
'OLAP Attributes in the database accessible by the user'
/
comment on column ALL_CUBE_ATTRIBUTES.OWNER is
'Owner of OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DIMENSION_NAME is
'Name of owning Cube Dimension of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.TARGET_DIMENSION_NAME is
'Name of Target Dimension of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.ATTRIBUTE_ROLE is
'Special role this attribute plays (e.g. ShortDescription), or null if none'
/
comment on column ALL_CUBE_ATTRIBUTES.DESCRIPTION is
'Long Description of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DATA_TYPE is
'Data Type of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DATA_LENGTH is
'Data Length of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DATA_PRECISION is
'Data Precision of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTRIBUTES.DATA_SCALE is
'Data Scale of the OLAP Attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_ATTRIBUTES
FOR SYS.ALL_CUBE_ATTRIBUTES
/
GRANT SELECT ON ALL_CUBE_ATTRIBUTES to public
/

create or replace view USER_CUBE_ATTRIBUTES
as
SELECT 
  o.name DIMENSION_NAME, 
  a.attribute_name ATTRIBUTE_NAME, 
  tdo.name TARGET_DIMENSION_NAME,
  (CASE a.attribute_role_mask
     WHEN 1 THEN 'SHORT_DESCRIPTION'
     WHEN 2 THEN 'LONG_DESCRIPTION'
     WHEN 3 THEN 'DESCRIPTION'
     WHEN 4 THEN 'TIME_SPAN'
     WHEN 8 THEN 'END_DATE'
     WHEN 16 THEN 'START_DATE'
     ELSE null END) ATTRIBUTE_ROLE,
  d.description_value DESCRIPTION,
  DECODE(a.type#, 1, decode(a.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                  2, decode(a.scale, null,
                            decode(a.precision#, null, 'NUMBER', 'FLOAT'),
                            'NUMBER'),
                  8, 'LONG',
                  9, decode(a.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                  12, 'DATE',
                  23, 'RAW', 24, 'LONG RAW',
                  69, 'ROWID',
                  96, decode(a.charsetform, 2, 'NCHAR', 'CHAR'),
                  100, 'BINARY_FLOAT',
                  101, 'BINARY_DOUBLE',
                  105, 'MLSLABEL',
                  106, 'MLSLABEL',
                  112, decode(a.charsetform, 2, 'NCLOB', 'CLOB'),
                  113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                  178, 'TIME(' ||a.scale|| ')',
                  179, 'TIME(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  180, 'TIMESTAMP(' ||a.scale|| ')',
                  181, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH TIME ZONE',
                  231, 'TIMESTAMP(' ||a.scale|| ')' || ' WITH LOCAL TIME ZONE',
                  182, 'INTERVAL YEAR(' ||a.precision#||') TO MONTH',
                  183, 'INTERVAL DAY(' ||a.precision#||') TO SECOND(' ||
                        a.scale || ')',
                  208, 'UROWID',
                  'UNDEFINED') DATA_TYPE,
  a.length DATA_LENGTH, 
  a.precision# DATA_PRECISION, 
  a.scale DATA_SCALE
FROM 
  olap_attributes$ a, 
  obj$ o, 
  obj$ tdo, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 15 --ATTRIBUTE
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d,
  olap_syntax$ s
WHERE 
  o.obj#=a.dim_obj#
  AND o.owner#=USERENV('SCHEMAID')
  AND a.target_dim#=tdo.obj#(+)
  AND a.attribute_id=s.owner_id(+) 
  AND s.owner_type(+) = 15 --ATTRIBUTE 
  AND s.ref_role(+) = 2 --ATTRIBUTE_ROLE 
  AND a.attribute_id = d.owning_object_id(+)
/

comment on table USER_CUBE_ATTRIBUTES is
'OLAP Attributes owned by the user in the database'
/
comment on column USER_CUBE_ATTRIBUTES.DIMENSION_NAME is
'Name of owning Cube Dimension of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.TARGET_DIMENSION_NAME is
'Name of Target Dimension of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.ATTRIBUTE_ROLE is
'Special role this attribute plays (e.g. ShortDescription), or null if none'
/
comment on column USER_CUBE_ATTRIBUTES.DESCRIPTION is
'Long Description of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.DATA_TYPE is
'Data Type of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.DATA_LENGTH is
'Data Length of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.DATA_PRECISION is
'Data Precision of the OLAP Attribute'
/
comment on column USER_CUBE_ATTRIBUTES.DATA_SCALE is
'Data Scale of the OLAP Attribute'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_ATTRIBUTES
FOR SYS.USER_CUBE_ATTRIBUTES
/
GRANT SELECT ON USER_CUBE_ATTRIBUTES to public
/


-- xxx_CUBE_ATTR_VISIBILITY --

create or replace view DBA_CUBE_ATTR_VISIBILITY
AS
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIMENSION' TO_TYPE
FROM
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND dl.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIER_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 14 -- HIER_LEVEL
  AND av.owning_dim_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.dim_obj# = o.obj#
  AND o.owner# = u.user#
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.level_id = hl.dim_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
/
comment on table DBA_CUBE_ATTR_VISIBILITY is
'OLAP Attributes visible for Dimensions, Hierarchies, and Levels'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.OWNER is
'Owner of OLAP Attribute'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.DIMENSION_NAME is
'Name of the OLAP Cube Dimension that owns the OLAP Attribute'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.ATTRIBUTE_NAME is
'Name of the OLAP Attribute'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.HIERARCHY_NAME is
'Name of the OLAP Hierarchy for which the Attribute is visible'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.LEVEL_NAME is
'Name of the OLAP Level for which the Attribute is visible'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.FROM_TYPE is
'Object type on which the visibility has been explicitly set'
/
comment on column DBA_CUBE_ATTR_VISIBILITY.TO_TYPE is
'Object type on which the visibility has been implicitly derived'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_ATTR_VISIBILITY
FOR SYS.DBA_CUBE_ATTR_VISIBILITY
/
GRANT SELECT ON DBA_CUBE_ATTR_VISIBILITY to select_catalog_role
/


create or replace view ALL_CUBE_ATTR_VISIBILITY
AS
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIMENSION' TO_TYPE
FROM
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND dl.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIER_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 14 -- HIER_LEVEL
  AND av.owning_dim_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT
  u.name OWNER,
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o,
  user$ u
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.level_id = hl.dim_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = u.user#
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/
comment on table ALL_CUBE_ATTR_VISIBILITY is
'OLAP Attributes visible for Dimensions, Hierarchies, and Levels'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.OWNER is
'Owner of OLAP Attribute'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.DIMENSION_NAME is
'Name of the OLAP Cube Dimension that owns the OLAP Attribute'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.ATTRIBUTE_NAME is
'Name of the OLAP Attribute'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.HIERARCHY_NAME is
'Name of the OLAP Hierarchy for which the Attribute is visible'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.LEVEL_NAME is
'Name of the OLAP Level for which the Attribute is visible'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.FROM_TYPE is
'Object type on which the visibility has been explicitly set'
/
comment on column ALL_CUBE_ATTR_VISIBILITY.TO_TYPE is
'Object type on which the visibility has been implicitly derived'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_ATTR_VISIBILITY
FOR SYS.ALL_CUBE_ATTR_VISIBILITY
/
GRANT SELECT ON ALL_CUBE_ATTR_VISIBILITY to public
/


create or replace view USER_CUBE_ATTR_VISIBILITY
AS
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIMENSION' TO_TYPE
FROM
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND dl.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIMENSION' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 11 -- DIMENSION
  AND av.owning_dim_id = o.obj#  
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  null LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIERARCHY' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIERARCHY' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 13 -- HIERARCHY
  AND av.owning_dim_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'HIER_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 14 -- HIER_LEVEL
  AND av.owning_dim_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND dl.level_id = hl.dim_level_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  null HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'DIM_LEVEL' TO_TYPE
FROM
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
UNION ALL
SELECT
  o.name DIMENSION_NAME,
  a.attribute_name ATTRIBUTE_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  dl.level_name LEVEL_NAME,
  'DIM_LEVEL' FROM_TYPE,
  'HIER_LEVEL' TO_TYPE
FROM
  olap_hierarchies$ h,
  olap_hier_levels$ hl,
  olap_dim_levels$ dl,
  olap_attributes$ a,
  olap_attribute_visibility$ av,
  obj$ o
WHERE  
  av.is_unique_key = 0
  AND av.attribute_id = a.attribute_id
  AND av.owning_dim_type = 12 -- DIM_LEVEL
  AND av.owning_dim_id = dl.level_id
  AND dl.level_id = hl.dim_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = o.obj#
  AND o.owner# = USERENV('SCHEMAID')
/
comment on table USER_CUBE_ATTR_VISIBILITY is
'OLAP Attributes visible for Dimensions, Hierarchies, and Levels'
/
comment on column USER_CUBE_ATTR_VISIBILITY.DIMENSION_NAME is
'Name of the OLAP Cube Dimension that owns the OLAP Attribute'
/
comment on column USER_CUBE_ATTR_VISIBILITY.ATTRIBUTE_NAME is
'Name of the OLAP Attribute'
/
comment on column USER_CUBE_ATTR_VISIBILITY.HIERARCHY_NAME is
'Name of the OLAP Hierarchy for which the Attribute is visible'
/
comment on column USER_CUBE_ATTR_VISIBILITY.LEVEL_NAME is
'Name of the OLAP Level for which the Attribute is visible'
/
comment on column USER_CUBE_ATTR_VISIBILITY.FROM_TYPE is
'Object type on which the visibility has been explicitly set'
/
comment on column USER_CUBE_ATTR_VISIBILITY.TO_TYPE is
'Object type on which the visibility has been implicitly derived'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_ATTR_VISIBILITY
FOR SYS.USER_CUBE_ATTR_VISIBILITY
/
GRANT SELECT ON USER_CUBE_ATTR_VISIBILITY to public
/


-- OLAP_MODELS$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_DIM_MODELS
AS
SELECT 
  du.name OWNER, 
  do.name DIMENSION_NAME,
  m.model_name MODEL_NAME,
  d.description_value DESCRIPTION
FROM
  olap_models$ m, 
  obj$ do,
  user$ du, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 16 --MODEL
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.owning_obj_type = 11 --DIMENSION
  AND m.owning_obj_id = do.obj#
  AND do.owner# = du.user# 
  AND m.model_id = d.owning_object_id(+)
/

comment on table DBA_CUBE_DIM_MODELS is
'OLAP Dimension Models in the database'
/
comment on column DBA_CUBE_DIM_MODELS.OWNER is
'Owner of OLAP Dimension Model'
/
comment on column DBA_CUBE_DIM_MODELS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension Model'
/
comment on column DBA_CUBE_DIM_MODELS.MODEL_NAME is
'Name of the OLAP Dimension Model'
/
comment on column DBA_CUBE_DIM_MODELS.DESCRIPTION is
'Long Description of the OLAP Dimension Model'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIM_MODELS 
FOR SYS.DBA_CUBE_DIM_MODELS
/
GRANT SELECT ON DBA_CUBE_DIM_MODELS to select_catalog_role
/

create or replace view ALL_CUBE_DIM_MODELS
AS
SELECT 
  du.name OWNER, 
  do.name DIMENSION_NAME,
  m.model_name MODEL_NAME,
  d.description_value DESCRIPTION
FROM
  olap_models$ m, 
  obj$ do,
  user$ du, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 16 --MODEL
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.owning_obj_type = 11 --DIMENSION
  AND m.owning_obj_id = do.obj#
  AND do.owner# = du.user# 
  AND m.model_id = d.owning_object_id(+)
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_DIM_MODELS is
'OLAP Dimension Models in the database accessible to the user'
/
comment on column ALL_CUBE_DIM_MODELS.OWNER is
'Owner of OLAP Dimension Model'
/
comment on column ALL_CUBE_DIM_MODELS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension Model'
/
comment on column ALL_CUBE_DIM_MODELS.MODEL_NAME is
'Name of the OLAP Dimension Model'
/
comment on column ALL_CUBE_DIM_MODELS.DESCRIPTION is
'Long Description of the OLAP Dimension Model'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIM_MODELS 
FOR SYS.ALL_CUBE_DIM_MODELS
/
GRANT SELECT ON ALL_CUBE_DIM_MODELS to public
/

create or replace view USER_CUBE_DIM_MODELS
AS
SELECT 
  do.name DIMENSION_NAME,
  m.model_name MODEL_NAME,
  d.description_value DESCRIPTION
FROM
  olap_models$ m, 
  obj$ do,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 16 --MODEL
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE  
  m.owning_obj_type = 11 --DIMENSION
  AND m.owning_obj_id = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND m.model_id = d.owning_object_id(+)
/

comment on table USER_CUBE_DIM_MODELS is
'OLAP Dimension Models in the database accessible to the user'
/
comment on column USER_CUBE_DIM_MODELS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension Model'
/
comment on column USER_CUBE_DIM_MODELS.MODEL_NAME is
'Name of the OLAP Dimension Model'
/
comment on column USER_CUBE_DIM_MODELS.DESCRIPTION is
'Long Description of the OLAP Dimension Model'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIM_MODELS 
FOR SYS.USER_CUBE_DIM_MODELS
/
GRANT SELECT ON USER_CUBE_DIM_MODELS to public
/

-- OLAP_CUBE_CALCULATED_MEMBERS$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_CALCULATED_MEMBERS
as
SELECT 
  u.name OWNER,
  o.name DIMENSION_NAME,
  cm.member_name MEMBER_NAME, 
  DECODE(cm.is_customaggregate, 1, 'YES', 0, 'NO') IS_CUSTOM_AGGREGATE,
  DECODE(cm.storage_type, 1, 'DYNAMIC', 2, 'PRECOMPUTE') STORAGE_TYPE,
  syn.syntax_clob EXPRESSION
FROM 
  olap_calculated_members$ cm, 
  obj$ o, 
  user$ u,
  olap_syntax$ syn
WHERE 
  cm.dim_obj#=o.obj# 
  AND o.owner#=u.user#
  AND cm.member_id = syn.owner_id(+)
  AND syn.owner_type = 6 --CALC_MEMBER 
  AND syn.ref_role=19 -- MEMBER_EXPRESSION_ROLE 
/

comment on table DBA_CUBE_CALCULATED_MEMBERS is
'OLAP Calculated Members in the database'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.OWNER is
'Owner of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.MEMBER_NAME is
'Member Name of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.IS_CUSTOM_AGGREGATE is
'Custom Aggregate flag of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.STORAGE_TYPE is
'Storage Type of the OLAP Calculated Member'
/
comment on column DBA_CUBE_CALCULATED_MEMBERS.EXPRESSION is
'Expression of the OLAP Calculated Member'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_CALCULATED_MEMBERS
FOR SYS.DBA_CUBE_CALCULATED_MEMBERS
/
GRANT SELECT ON DBA_CUBE_CALCULATED_MEMBERS to select_catalog_role
/

create or replace view ALL_CUBE_CALCULATED_MEMBERS
as
SELECT 
  u.name OWNER,
  o.name DIMENSION_NAME,
  cm.member_name MEMBER_NAME, 
  DECODE(cm.is_customaggregate, 1, 'YES', 0, 'NO') IS_CUSTOM_AGGREGATE,
  DECODE(cm.storage_type, 1, 'DYNAMIC', 2, 'PRECOMPUTE') STORAGE_TYPE,
  syn.syntax_clob EXPRESSION
FROM 
  olap_calculated_members$ cm, 
  obj$ o, 
  user$ u,
  olap_syntax$ syn
WHERE 
  cm.dim_obj#=o.obj# 
  AND o.owner#=u.user#
  AND cm.member_id = syn.owner_id(+)
  AND syn.owner_type = 6 --CALC_MEMBER 
  AND syn.ref_role=19 -- MEMBER_EXPRESSION_ROLE 
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_CALCULATED_MEMBERS is
'OLAP Calculated Members in the database accessible to the user'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.OWNER is
'Owner of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.MEMBER_NAME is
'Member Name of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.IS_CUSTOM_AGGREGATE is
'Custom Aggregate flag of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.STORAGE_TYPE is
'Storage Type of the OLAP Calculated Member'
/
comment on column ALL_CUBE_CALCULATED_MEMBERS.EXPRESSION is
'Expression of the OLAP Calculated Member'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_CALCULATED_MEMBERS
FOR SYS.ALL_CUBE_CALCULATED_MEMBERS
/
GRANT SELECT ON ALL_CUBE_CALCULATED_MEMBERS to public
/

create or replace view USER_CUBE_CALCULATED_MEMBERS
as
SELECT 
  o.name DIMENSION_NAME,
  cm.member_name MEMBER_NAME, 
  DECODE(cm.is_customaggregate, 1, 'YES', 0, 'NO') IS_CUSTOM_AGGREGATE,
  DECODE(cm.storage_type, 1, 'DYNAMIC', 2, 'PRECOMPUTE') STORAGE_TYPE,
  syn.syntax_clob EXPRESSION
FROM 
  olap_calculated_members$ cm, 
  obj$ o, 
  olap_syntax$ syn
WHERE 
  cm.dim_obj#=o.obj# 
  AND o.owner#=USERENV('SCHEMAID')
  AND cm.member_id = syn.owner_id(+)
  AND syn.owner_type = 6 --CALC_MEMBER 
  AND syn.ref_role=19 -- MEMBER_EXPRESSION_ROLE 
/

comment on table USER_CUBE_CALCULATED_MEMBERS is
'OLAP Calculated Members in the database accessible to the user'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Calculated Member'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.MEMBER_NAME is
'Member Name of the OLAP Calculated Member'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.IS_CUSTOM_AGGREGATE is
'Custom Aggregate flag of the OLAP Calculated Member'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.STORAGE_TYPE is
'Storage Type of the OLAP Calculated Member'
/
comment on column USER_CUBE_CALCULATED_MEMBERS.EXPRESSION is
'Expression of the OLAP Calculated Member'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_CALCULATED_MEMBERS
FOR SYS.USER_CUBE_CALCULATED_MEMBERS
/
GRANT SELECT ON USER_CUBE_CALCULATED_MEMBERS to public
/

-- OLAP_AW_VIEWS$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_VIEWS
as
SELECT
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ co,
  user$ cu,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id=co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner#=cu.user#
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=cu.user#      
/

comment on table DBA_CUBE_VIEWS is
'OLAP Cube Views in the database'
/
comment on column DBA_CUBE_VIEWS.OWNER is
'Owner of the OLAP Cube View'
/
comment on column DBA_CUBE_VIEWS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View'
/
comment on column DBA_CUBE_VIEWS.VIEW_NAME is
'View Name of the OLAP Cube View'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_VIEWS
FOR SYS.DBA_CUBE_VIEWS
/
GRANT SELECT ON DBA_CUBE_VIEWS to select_catalog_role
/

create or replace view ALL_CUBE_VIEWS
as
SELECT
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ co,
  user$ cu,
  obj$ vo,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ( exists (select null from v$enabledprivs
                          where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION
                                                -304, -- DELETE ANY PRIMARY DIMENSION
                                                -305, -- DROP ANY PRIMARY DIMENSION
                                                -306, -- INSERT ANY PRIMARY DIMENSION
                                                -307) -- SELECT ANY PRIMARY DIMENSION
                          )
                )
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id=co.obj#
  AND co.obj#=da.obj#(+)
  AND av.view_type = 1 -- ET 
  AND co.owner#=cu.user#
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=cu.user#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL))
/

comment on table ALL_CUBE_VIEWS is
'OLAP Cube Views in the database accessible by the user'
/
comment on column ALL_CUBE_VIEWS.OWNER is
'Owner of the OLAP Cube View'
/
comment on column ALL_CUBE_VIEWS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View'
/
comment on column ALL_CUBE_VIEWS.VIEW_NAME is
'View Name of the OLAP Cube View'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_VIEWS
FOR SYS.ALL_CUBE_VIEWS
/
GRANT SELECT ON ALL_CUBE_VIEWS to public
/

create or replace view USER_CUBE_VIEWS
as
SELECT
  co.name CUBE_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ co,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id=co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner#=USERENV('SCHEMAID')
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#      
/

comment on table USER_CUBE_VIEWS is
'OLAP Cube Views owned by the user in the database'
/
comment on column USER_CUBE_VIEWS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View'
/
comment on column USER_CUBE_VIEWS.VIEW_NAME is
'View Name of the OLAP Cube View'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_VIEWS
FOR SYS.USER_CUBE_VIEWS
/
GRANT SELECT ON USER_CUBE_VIEWS to public
/

create or replace view DBA_CUBE_VIEW_COLUMNS
as
SELECT 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'MEASURE' COLUMN_TYPE,
  m.measure_name OBJECT_NAME -- name of measure  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_measures$ m,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 2 -- MEASURE 
  AND avc.referenced_object_id = m.measure_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by dimension 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 11 -- DIMENSION 
  AND d.dimension_id = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by dimension level 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_dim_levels$ dl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 12 -- DIM_LEVEL 
  AND d.dimension_id = dl.level_id
  AND dl.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by hierarchy 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 13 -- HIERARCHY 
  AND d.dimension_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by hierarchy level 
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h,
  olap_hier_levels$ hl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 14 -- HIER_LEVEL 
  AND d.dimension_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
/

comment on table DBA_CUBE_VIEW_COLUMNS is
'OLAP Cube View Columns in the database'
/
comment on column DBA_CUBE_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Cube View Column'
/
comment on column DBA_CUBE_VIEW_COLUMNS.OBJECT_NAME is
'Name of Measure of the OLAP Cube View Column'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_VIEW_COLUMNS
FOR SYS.DBA_CUBE_VIEW_COLUMNS
/
GRANT SELECT ON DBA_CUBE_VIEW_COLUMNS to select_catalog_role
/

create or replace view ALL_CUBE_VIEW_COLUMNS
as
SELECT OWNER, CUBE_NAME, VIEW_NAME, COLUMN_NAME, COLUMN_TYPE, OBJECT_NAME
FROM
(SELECT 
  co.obj# obj#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'MEASURE' COLUMN_TYPE,
  m.measure_name OBJECT_NAME -- name of measure  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_measures$ m,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 2 -- MEASURE 
  AND avc.referenced_object_id = m.measure_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
UNION ALL
SELECT -- dimensioned by dimension 
  co.obj# obj#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 11 -- DIMENSION 
  AND d.dimension_id = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
UNION ALL
SELECT -- dimensioned by dimension level 
  co.obj# obj#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_dim_levels$ dl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 12 -- DIM_LEVEL 
  AND d.dimension_id = dl.level_id
  AND dl.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
UNION ALL
SELECT -- dimensioned by hierarchy 
  co.obj# obj#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 13 -- HIERARCHY 
  AND d.dimension_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
UNION ALL
SELECT -- dimensioned by hierarchy level 
  co.obj# obj#,
  cu.name OWNER,
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  user$ cu,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h,
  olap_hier_levels$ hl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = cu.user#
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 14 -- HIER_LEVEL 
  AND d.dimension_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or co.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privilages 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
) u,
 (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE u.obj#=da.obj#(+)
  AND ((have_all_dim_access = 1) OR (have_all_dim_access is NULL)
         or   -- user has system privileges
                ( exists (select null from v$enabledprivs
                          where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION
                                                -304, -- DELETE ANY PRIMARY DIMENSION
                                                -305, -- DROP ANY PRIMARY DIMENSION
                                                -306, -- INSERT ANY PRIMARY DIMENSION
                                                -307) -- SELECT ANY PRIMARY DIMENSION
                          )
                )
  )

/

comment on table ALL_CUBE_VIEW_COLUMNS is
'OLAP Cube View Columns in the database accessible by the user'
/
comment on column ALL_CUBE_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Cube View Column'
/
comment on column ALL_CUBE_VIEW_COLUMNS.OBJECT_NAME is
'Name of Measure of the OLAP Cube View Column'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_VIEW_COLUMNS
FOR SYS.ALL_CUBE_VIEW_COLUMNS
/
GRANT SELECT ON ALL_CUBE_VIEW_COLUMNS to public
/

create or replace view USER_CUBE_VIEW_COLUMNS
as
SELECT 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'MEASURE' COLUMN_TYPE,
  m.measure_name OBJECT_NAME -- name of measure  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_measures$ m,
  col$ col,
  obj$ co,
  obj$ vo
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 2 -- MEASURE 
  AND avc.referenced_object_id = m.measure_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by dimension 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 11 -- DIMENSION 
  AND d.dimension_id = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by dimension level 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_dim_levels$ dl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 12 -- DIM_LEVEL 
  AND d.dimension_id = dl.level_id
  AND dl.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by hierarchy 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 13 -- HIERARCHY 
  AND d.dimension_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
UNION ALL
SELECT -- dimensioned by hierarchy level 
  co.name CUBE_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'KEY' COLUMN_TYPE,
  do.name OBJECT_NAME -- name of dimension 
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ co,
  obj$ vo,
  obj$ do,
  olap_dimensionality$ d,
  olap_hierarchies$ h,
  olap_hier_levels$ hl
WHERE
  av.olap_object_type = 1 -- CUBE 
  AND av.olap_object_id = co.obj#
  AND av.view_type = 1 -- ET 
  AND co.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = avc.view_obj#
  AND avc.column_type = 2 -- KEY 
  AND avc.referenced_object_type = 16 -- DIMENSIONALITY 
  AND avc.referenced_object_id = d.dimensionality_id
  AND d.dimension_type = 14 -- HIER_LEVEL 
  AND d.dimension_id = hl.hierarchy_level_id
  AND hl.hierarchy_id = h.hierarchy_id
  AND h.dim_obj# = do.obj#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=co.owner#
/

comment on table USER_CUBE_VIEW_COLUMNS is
'OLAP Cube View Columns owned by the user in the database'
/
comment on column USER_CUBE_VIEW_COLUMNS.CUBE_NAME is
'Name of owning cube of the OLAP Cube View Column'
/
comment on column USER_CUBE_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Cube View Column'
/
comment on column USER_CUBE_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Cube View Column'
/
comment on column USER_CUBE_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Cube View Column'
/
comment on column USER_CUBE_VIEW_COLUMNS.OBJECT_NAME is
'Name of Measure of the OLAP Cube View Column'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_VIEW_COLUMNS
FOR SYS.USER_CUBE_VIEW_COLUMNS
/
GRANT SELECT ON USER_CUBE_VIEW_COLUMNS to public
/

create or replace view DBA_CUBE_DIM_VIEWS
as
SELECT
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id=do.obj#
  AND av.view_type = 1 -- ET 
  AND do.owner#=du.user#
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
/

comment on table DBA_CUBE_DIM_VIEWS is
'OLAP Dimension Views in the database'
/
comment on column DBA_CUBE_DIM_VIEWS.OWNER is
'Owner of the OLAP Dimension View'
/
comment on column DBA_CUBE_DIM_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View'
/
comment on column DBA_CUBE_DIM_VIEWS.VIEW_NAME is
'View Name of the OLAP Dimension View'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIM_VIEWS
FOR SYS.DBA_CUBE_DIM_VIEWS
/
GRANT SELECT ON DBA_CUBE_DIM_VIEWS to select_catalog_role
/

create or replace view ALL_CUBE_DIM_VIEWS
as
SELECT
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id=do.obj#
  AND av.view_type = 1 -- ET 
  AND do.owner#=du.user#
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_DIM_VIEWS is
'OLAP Dimension Views in the database accessible by the user'
/
comment on column ALL_CUBE_DIM_VIEWS.OWNER is
'Owner of the OLAP Dimension View'
/
comment on column ALL_CUBE_DIM_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View'
/
comment on column ALL_CUBE_DIM_VIEWS.VIEW_NAME is
'View Name of the OLAP Dimension View'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIM_VIEWS
FOR SYS.ALL_CUBE_DIM_VIEWS
/
GRANT SELECT ON ALL_CUBE_DIM_VIEWS to public
/

create or replace view USER_CUBE_DIM_VIEWS
as
SELECT
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  obj$ do,
  obj$ vo
WHERE
  av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id=do.obj#
  AND av.view_type = 1 -- ET 
  AND do.owner#=USERENV('SCHEMAID')
  AND av.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
/

comment on table USER_CUBE_DIM_VIEWS is
'OLAP Dimension Views owned by the user in the database'
/
comment on column USER_CUBE_DIM_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View'
/
comment on column USER_CUBE_DIM_VIEWS.VIEW_NAME is
'View Name of the OLAP Dimension View'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIM_VIEWS
FOR SYS.USER_CUBE_DIM_VIEWS
/
GRANT SELECT ON USER_CUBE_DIM_VIEWS to public
/

create or replace view DBA_CUBE_DIM_VIEW_COLUMNS
as
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          4, 'LEVEL_NAME',
                          7, 'DIM_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME -- no object name for these column types  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type IN (2, 4, 6, 7, 9)
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND do.owner# = du.user#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND a.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
/

comment on table DBA_CUBE_DIM_VIEW_COLUMNS is
'OLAP Dimesion View Columns in the database'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Dimension View Column'
/
comment on column DBA_CUBE_DIM_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Dimension View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_DIM_VIEW_COLUMNS
FOR SYS.DBA_CUBE_DIM_VIEW_COLUMNS
/
GRANT SELECT ON DBA_CUBE_DIM_VIEW_COLUMNS to select_catalog_role
/

create or replace view ALL_CUBE_DIM_VIEW_COLUMNS
as
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          4, 'LEVEL_NAME',
                          7, 'DIM_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME -- no object name for these column types  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type IN (2, 4, 6, 7, 9)
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND do.owner# = du.user#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#   
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND a.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_DIM_VIEW_COLUMNS is
'OLAP Dimesion View Columns in the database accessible to the user'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Dimension View Column'
/
comment on column ALL_CUBE_DIM_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Dimension View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_DIM_VIEW_COLUMNS
FOR SYS.ALL_CUBE_DIM_VIEW_COLUMNS
/
GRANT SELECT ON ALL_CUBE_DIM_VIEW_COLUMNS to public
/

create or replace view USER_CUBE_DIM_VIEW_COLUMNS
as
SELECT 
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          4, 'LEVEL_NAME',
                          7, 'DIM_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME -- no object name for these column types  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type IN (2, 4, 6, 7, 9)
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
UNION ALL
SELECT 
  do.name DIMENSION_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 11 --DIMENSION
  AND av.olap_object_id = do.obj#
  AND av.view_type = 1 -- ET 
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND a.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj#=vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner#=do.owner#
/

comment on table USER_CUBE_DIM_VIEW_COLUMNS is
'OLAP Dimesion View Columns in the database accessible to the user'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Dimension View Column'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Dimension View Column'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Dimension View Column'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Dimension View Column'
/
comment on column USER_CUBE_DIM_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Dimension View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_DIM_VIEW_COLUMNS
FOR SYS.USER_CUBE_DIM_VIEW_COLUMNS
/
GRANT SELECT ON USER_CUBE_DIM_VIEW_COLUMNS to public
/

create or replace view DBA_CUBE_HIER_VIEWS
as
SELECT
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  olap_hierarchies$ h,
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  av.olap_object_type = 13 --HIERACHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
/

comment on table DBA_CUBE_HIER_VIEWS is
'OLAP Hierarchy Views in the database'
/
comment on column DBA_CUBE_HIER_VIEWS.OWNER is
'Owner of the OLAP Hierarchy View'
/
comment on column DBA_CUBE_HIER_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View'
/
comment on column DBA_CUBE_HIER_VIEWS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View'
/
comment on column DBA_CUBE_HIER_VIEWS.VIEW_NAME is
'View Name of the OLAP Hierarchy View'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_HIER_VIEWS
FOR SYS.DBA_CUBE_HIER_VIEWS
/
GRANT SELECT ON DBA_CUBE_HIER_VIEWS to select_catalog_role
/

create or replace view ALL_CUBE_HIER_VIEWS
as
SELECT
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  olap_hierarchies$ h,
  obj$ do,
  user$ du,
  obj$ vo
WHERE
  av.olap_object_type = 13 --HIERACHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_HIER_VIEWS is
'OLAP Hierarchy Views in the database accessible to the user'
/
comment on column ALL_CUBE_HIER_VIEWS.OWNER is
'Owner of the OLAP Hierarchy View'
/
comment on column ALL_CUBE_HIER_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View'
/
comment on column ALL_CUBE_HIER_VIEWS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View'
/
comment on column ALL_CUBE_HIER_VIEWS.VIEW_NAME is
'View Name of the OLAP Hierarchy View'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_HIER_VIEWS
FOR SYS.ALL_CUBE_HIER_VIEWS
/
GRANT SELECT ON ALL_CUBE_HIER_VIEWS to public
/

create or replace view USER_CUBE_HIER_VIEWS
as
SELECT
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME
FROM
  olap_aw_views$ av,   
  olap_hierarchies$ h,
  obj$ do,
  obj$ vo
WHERE
  av.olap_object_type = 13 --HIERACHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
/

comment on table USER_CUBE_HIER_VIEWS is
'OLAP Hierarchy Views owner by the user in the database'
/
comment on column USER_CUBE_HIER_VIEWS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View'
/
comment on column USER_CUBE_HIER_VIEWS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View'
/
comment on column USER_CUBE_HIER_VIEWS.VIEW_NAME is
'View Name of the OLAP Hierarchy View'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_HIER_VIEWS
FOR SYS.USER_CUBE_HIER_VIEWS
/
GRANT SELECT ON USER_CUBE_HIER_VIEWS to public
/

create or replace view DBA_CUBE_HIER_VIEW_COLUMNS
as
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          3, 'PARENT',
                          4, 'LEVEL_NAME',
                          5, 'DEPTH',
                          8, 'HIER_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME -- no object name for these column types  
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND avc.column_type IN (2, 3, 4, 5, 8, 9)
  AND av.olap_object_type = 13 --HIERARCHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'LEVEL' COLUMN_TYPE,
  dl.level_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_hier_levels$ l,
  olap_dim_levels$ dl,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 12 --DIM_LEVEL
  AND avc.referenced_object_id = dl.level_id
  AND l.dim_level_id = dl.level_id
  AND l.hierarchy_id = h.hierarchy_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
/

comment on table DBA_CUBE_HIER_VIEW_COLUMNS is
'OLAP Hierarchy View Columns in the database'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Hierarchy View Column'
/
comment on column DBA_CUBE_HIER_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Hierarchy View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_HIER_VIEW_COLUMNS 
FOR SYS.DBA_CUBE_HIER_VIEW_COLUMNS
/
GRANT SELECT ON DBA_CUBE_HIER_VIEW_COLUMNS to select_catalog_role
/

create or replace view ALL_CUBE_HIER_VIEW_COLUMNS
as
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          3, 'PARENT',
                          4, 'LEVEL_NAME',
                          5, 'DEPTH',
                          8, 'HIER_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND avc.column_type IN (2, 3, 4, 5, 8, 9)
  AND av.olap_object_type = 13 --HIERARCHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
UNION ALL
SELECT 
  du.name OWNER,
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'LEVEL' COLUMN_TYPE,
  dl.level_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_hier_levels$ l,
  olap_dim_levels$ dl,
  col$ col,
  obj$ do,
  user$ du,  
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 12 --DIM_LEVEL
  AND avc.referenced_object_id = dl.level_id
  AND l.dim_level_id = dl.level_id
  AND l.hierarchy_id = h.hierarchy_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = du.user#
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
  AND (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or do.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION 
                                              -304, -- DELETE ANY PRIMARY DIMENSION 
                                              -305, -- DROP ANY PRIMARY DIMENSION 
                                              -306, -- INSERT ANY PRIMARY DIMENSION 
                                              -307) -- SELECT ANY PRIMARY DIMENSION
                        )
              )
            )
/

comment on table ALL_CUBE_HIER_VIEW_COLUMNS is
'OLAP Hierarchy View Columns in the database accessible to the user'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.OWNER is
'Owner of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Hierarchy View Column'
/
comment on column ALL_CUBE_HIER_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Hierarchy View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_HIER_VIEW_COLUMNS 
FOR SYS.ALL_CUBE_HIER_VIEW_COLUMNS
/
GRANT SELECT ON ALL_CUBE_HIER_VIEW_COLUMNS to public
/

create or replace view USER_CUBE_HIER_VIEW_COLUMNS
as
SELECT 
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  DECODE(avc.column_type, 2, 'KEY',
                          3, 'PARENT',
                          4, 'LEVEL_NAME',
                          5, 'DEPTH',
                          8, 'HIER_ORDER',
                          9, 'MEMBER_TYPE') COLUMN_TYPE,
  NULL OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND avc.column_type IN (2, 3, 4, 5, 8, 9)
  AND av.olap_object_type = 13 --HIERARCHY
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
UNION ALL
SELECT 
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'ATTRIBUTE' COLUMN_TYPE,
  a.attribute_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_attributes$ a,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 15 --ATTRIBUTE
  AND avc.referenced_object_id = a.attribute_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
UNION ALL
SELECT 
  do.name DIMENSION_NAME,
  h.hierarchy_name HIERARCHY_NAME,
  vo.name VIEW_NAME,
  col.name COLUMN_NAME,
  'LEVEL' COLUMN_TYPE,
  dl.level_name OBJECT_NAME
FROM
  olap_aw_view_columns$ avc,
  olap_aw_views$ av,
  olap_hierarchies$ h,
  olap_hier_levels$ l,
  olap_dim_levels$ dl,
  col$ col,
  obj$ do,
  obj$ vo
WHERE
  avc.view_obj# = av.view_obj#
  AND av.olap_object_type = 13 --HIERARCHY
  AND avc.column_type = 1 -- OBJECT 
  AND avc.referenced_object_type = 12 --DIM_LEVEL
  AND avc.referenced_object_id = dl.level_id
  AND l.dim_level_id = dl.level_id
  AND l.hierarchy_id = h.hierarchy_id
  AND av.olap_object_id = h.hierarchy_id
  AND av.view_type = 1 -- ET 
  AND h.dim_obj# = do.obj#
  AND do.owner# = USERENV('SCHEMAID')
  AND avc.view_obj# = col.obj#
  AND avc.column_obj# = col.col#
  AND av.view_obj# = vo.obj#
  AND vo.type# != 10 -- not NON-EXISTENT
  AND vo.owner# = do.owner#
/

comment on table USER_CUBE_HIER_VIEW_COLUMNS is
'OLAP Hierarchy View Columns owned by the user in the database'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.DIMENSION_NAME is
'Name of owning dimension of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.HIERARCHY_NAME is
'Name of hierarchy of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.VIEW_NAME is
'View Name of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.COLUMN_NAME is
'Name of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.COLUMN_TYPE is
'View Type of the OLAP Hierarchy View Column'
/
comment on column USER_CUBE_HIER_VIEW_COLUMNS.OBJECT_NAME is
'No object names for OLAP Hierarchy View Columns'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_HIER_VIEW_COLUMNS 
FOR SYS.USER_CUBE_HIER_VIEW_COLUMNS
/
GRANT SELECT ON USER_CUBE_HIER_VIEW_COLUMNS to public
/

-- OLAP_MEASURE_FOLDERS$ DATA DICTIONARY VIEWS --

create or replace view DBA_MEASURE_FOLDERS
as
SELECT 
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  d.description_value DESCRIPTION
FROM 
  olap_measure_folders$ mf, 
  obj$ o, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 10 --MEASURE_FOLDER
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  mf.obj# = o.obj# 
  AND o.owner# = u.user# 
  AND mf.obj# = d.owning_object_id(+)
/

comment on table DBA_MEASURE_FOLDERS is
'OLAP Measure Folders in the database'
/
comment on column DBA_MEASURE_FOLDERS.OWNER is
'Owner of the OLAP Measure Folder'
/
comment on column DBA_MEASURE_FOLDERS.MEASURE_FOLDER_NAME is
'Name of the OLAP Measure Folder'
/
comment on column DBA_MEASURE_FOLDERS.DESCRIPTION is
'Long Description of the OLAP Measure Folder'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_MEASURE_FOLDERS 
FOR SYS.DBA_MEASURE_FOLDERS
/
GRANT SELECT ON DBA_MEASURE_FOLDERS to select_catalog_role
/

create or replace view ALL_MEASURE_FOLDERS
as
SELECT 
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  d.description_value DESCRIPTION
FROM 
  olap_measure_folders$ mf, 
  obj$ o, 
  user$ u, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 10 --MEASURE_FOLDER
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  mf.obj# = o.obj# 
  AND o.owner# = u.user# 
  AND mf.obj# = d.owning_object_id(+)
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-316, -- DELETE ANY MEASURE FOLDER 
                                              -317, -- DROP ANY MEASURE FOLDER 
                                              -318) -- INSERT ANY MEASURE FOLDER
                        )
              )
       or   -- user has access to cubes in measure folder
              ( exists ( select null
                         from 
                           olap_meas_folder_contents$ mfc, 
                           obj$ mfo, 
                           user$ mfu,
                           olap_measures$ m,
                           obj$ co,
                           user$ cu,
                           (SELECT
                             obj#,
                             MIN(have_dim_access) have_all_dim_access
                           FROM
                             (SELECT
                               c.obj# obj#,
                               (CASE
                                 WHEN
                                 (do.owner# in (userenv('SCHEMAID'), 1)    -- public objects
                                  or do.obj# in
                                       ( select obj#   -- directly granted privileges
                                         from sys.objauth$
                                         where grantee# in ( select kzsrorol from x$kzsro )
                                       )
                                  or    -- user has system privileges
                                         ( exists (select null from v$enabledprivs
                                                   where priv_number in (-302,  -- ALTER ANY PRIMARY DIMENSION
                                                                         -304,  -- DELETE ANY PRIMARY DIMENSION
                                                                         -305,  -- DROP ANY PRIMARY DIMENSION
                                                                         -306,  -- INSERT ANY PRIMARY DIMENSION
                                                                         -307)  -- SELECT ANY PRIMARY DIMENSION
                                                   )
                                         ) 
                                )
                                 THEN 1
                                 ELSE 0
                                END) have_dim_access
                             FROM
                               olap_cubes$ c,
                               dependency$ d,
                               obj$ do
                             WHERE
                               do.obj# = d.p_obj#
                               AND do.type# = 92  -- CUBE DIMENSION
                               AND c.obj# = d.d_obj#
                             )
                             GROUP BY obj# ) da
                         WHERE 
                           mfc.measure_folder_obj#=mf.obj# 
                           AND mfc.measure_folder_obj#=mfo.obj# 
                           AND mfo.owner#=mfu.user# 
                           AND mfc.object_type = 2  -- MEASURE 
                           AND mfc.object_id = m.measure_id
                           AND m.cube_obj# = co.obj#
                           AND co.owner# = cu.user#
                           AND (co.owner# in (userenv('SCHEMAID'), 1) -- public objects 
                                or    -- user has access to cube
                                      (co.obj# in 
                                           ( select obj#   -- directly granted privileges 
                                             from sys.objauth$
                                             where grantee# in ( select kzsrorol from x$kzsro ) ) )
                                or    -- user has system privileges 
                                       ( exists (select null from v$enabledprivs
                                                 where priv_number in (-309,  -- ALTER ANY CUBE 
                                                                       -311,  -- DROP ANY CUBE 
                                                                       -312,  -- SELECT ANY CUBE 
                                                                       -313)  -- UPDATE ANY CUBE
                                                 )
                                       )
                                     )
                           AND co.obj# = da.obj#(+)
                           AND (da.have_all_dim_access = 1 or da.have_all_dim_access is NULL)
                       )
               )
      )
/

comment on table ALL_MEASURE_FOLDERS is
'OLAP Measure Folders in the database accessible to the user'
/
comment on column ALL_MEASURE_FOLDERS.OWNER is
'Owner of the OLAP Measure Folder'
/
comment on column ALL_MEASURE_FOLDERS.MEASURE_FOLDER_NAME is
'Name of the OLAP Measure Folder'
/
comment on column ALL_MEASURE_FOLDERS.DESCRIPTION is
'Long Description of the OLAP Measure Folder'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_MEASURE_FOLDERS 
FOR ALL_MEASURE_FOLDERS
/
GRANT SELECT ON ALL_MEASURE_FOLDERS to public
/

create or replace view USER_MEASURE_FOLDERS
as
SELECT 
  o.name MEASURE_FOLDER_NAME,
  d.description_value DESCRIPTION
FROM 
  olap_measure_folders$ mf, 
  obj$ o, 
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 10 --MEASURE_FOLDER
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  mf.obj# = o.obj# 
  AND o.owner# = USERENV('SCHEMAID')
  AND mf.obj# = d.owning_object_id(+)
/

comment on table USER_MEASURE_FOLDERS is
'OLAP Measure Folders owned by the user in the database'
/
comment on column USER_MEASURE_FOLDERS.MEASURE_FOLDER_NAME is
'Name of the OLAP Measure Folder'
/
comment on column USER_MEASURE_FOLDERS.DESCRIPTION is
'Long Description of the OLAP Measure Folder'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_MEASURE_FOLDERS 
FOR USER_MEASURE_FOLDERS
/
GRANT SELECT ON USER_MEASURE_FOLDERS to public
/

create or replace view DBA_MEASURE_FOLDER_CONTENTS
as
SELECT 
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  cu.name CUBE_OWNER,
  co.name CUBE_NAME,
  m.measure_name MEASURE_NAME,
  mf.order_num ORDER_NUM
FROM 
  olap_meas_folder_contents$ mf, 
  obj$ o, 
  user$ u,
  olap_measures$ m,
  obj$ co,
  user$ cu
WHERE 
  mf.measure_folder_obj#=o.obj# 
  AND o.owner#=u.user# 
  AND mf.object_type = 2 -- MEASURE 
  AND mf.object_id = m.measure_id
  AND m.cube_obj# = co.obj#
  AND co.owner# = cu.user#
/

comment on table DBA_MEASURE_FOLDER_CONTENTS is
'OLAP Measure Folder Contents in the database'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.OWNER is
'Owner of the OLAP Measure Folder Content'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.MEASURE_FOLDER_NAME is
'Name of the owning OLAP Measure Folder'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.CUBE_OWNER is
'Owner of the cube of the OLAP Measure Folder Content'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.CUBE_NAME is
'Name of the owning cube of the OLAP Measure Folder Content'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.MEASURE_NAME is
'Name of the owning measure of the OLAP Measure Folder Content'
/
comment on column DBA_MEASURE_FOLDER_CONTENTS.ORDER_NUM is
'Order number of the OLAP Measure Folder Content'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_MEASURE_FOLDER_CONTENTS
FOR SYS.DBA_MEASURE_FOLDER_CONTENTS
/
GRANT SELECT ON DBA_MEASURE_FOLDER_CONTENTS to select_catalog_role
/

create or replace view ALL_MEASURE_FOLDER_CONTENTS
as
SELECT 
  u.name OWNER,
  o.name MEASURE_FOLDER_NAME,
  cu.name CUBE_OWNER,
  co.name CUBE_NAME,
  m.measure_name MEASURE_NAME,
  mf.order_num ORDER_NUM
FROM 
  olap_meas_folder_contents$ mf, 
  obj$ o, 
  user$ u,
  olap_measures$ m,
  obj$ co,
  user$ cu,
  (SELECT
    obj#,
    MIN(have_dim_access) have_all_dim_access
  FROM
    (SELECT
      c.obj# obj#,
      (CASE
        WHEN
        (do.owner# in (userenv('SCHEMAID'), 1)   -- public objects
         or do.obj# in
              ( select obj#  -- directly granted privileges
                from sys.objauth$
                where grantee# in ( select kzsrorol from x$kzsro )
              )
         or   -- user has system privileges
                ( exists (select null from v$enabledprivs
                          where priv_number in (-302, -- ALTER ANY PRIMARY DIMENSION
                                                -304, -- DELETE ANY PRIMARY DIMENSION
                                                -305, -- DROP ANY PRIMARY DIMENSION
                                                -306, -- INSERT ANY PRIMARY DIMENSION
                                                -307) -- SELECT ANY PRIMARY DIMENSION
                          )
                )
        )
        THEN 1
        ELSE 0
       END) have_dim_access
    FROM
      olap_cubes$ c,
      dependency$ d,
      obj$ do
    WHERE
      do.obj# = d.p_obj#
      AND do.type# = 92 -- CUBE DIMENSION
      AND c.obj# = d.d_obj#
    )
    GROUP BY obj# ) da
WHERE 
  mf.measure_folder_obj#=o.obj# 
  AND o.owner#=u.user# 
  AND mf.object_type = 2 -- MEASURE 
  AND mf.object_id = m.measure_id
  AND m.cube_obj# = co.obj#
  AND co.owner# = cu.user#
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- folder is ownwd by user or public object
       or   -- user has access to measure folder
             (co.obj# in 
                  ( select obj#  -- directly granted privileges 
                    from sys.objauth$
                    where grantee# in ( select kzsrorol from x$kzsro ) ) )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-316, -- DELETE ANY MEASURE FOLDER 
                                              -317, -- DROP ANY MEASURE FOLDER 
                                              -318) -- INSERT ANY MEASURE FOLDER
                        )
              )
            )
  AND (co.owner# in (userenv('SCHEMAID'), 1)   -- cube is owned by user or public object
       or   -- user has access to cube
             (co.obj# in 
                  ( select obj#  -- directly granted privileges 
                    from sys.objauth$
                    where grantee# in ( select kzsrorol from x$kzsro ) ) )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-309, -- ALTER ANY CUBE 
                                              -311, -- DROP ANY CUBE 
                                              -312, -- SELECT ANY CUBE 
                                              -313) -- UPDATE ANY CUBE
                        )
              )
            )
  AND co.obj# = da.obj#(+)
  AND (da.have_all_dim_access = 1 or da.have_all_dim_access is NULL)
/

comment on table ALL_MEASURE_FOLDER_CONTENTS is
'OLAP Measure Folder Contents in the database accessible by the user'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.OWNER is
'Owner of the OLAP Measure Folder Content'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.MEASURE_FOLDER_NAME is
'Name of the owning OLAP Measure Folder'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.CUBE_OWNER is
'Owner of the cube of the OLAP Measure Folder Content'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.CUBE_NAME is
'Name of the owning cube of the OLAP Measure Folder Content'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.MEASURE_NAME is
'Name of the owning measure of the OLAP Measure Folder Content'
/
comment on column ALL_MEASURE_FOLDER_CONTENTS.ORDER_NUM is
'Order number of the OLAP Measure Folder Content'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_MEASURE_FOLDER_CONTENTS
FOR SYS.ALL_MEASURE_FOLDER_CONTENTS
/
GRANT SELECT ON ALL_MEASURE_FOLDER_CONTENTS to public
/

create or replace view USER_MEASURE_FOLDER_CONTENTS
as
SELECT 
  o.name MEASURE_FOLDER_NAME,
  cu.name CUBE_OWNER,
  co.name CUBE_NAME,
  m.measure_name MEASURE_NAME,
  mf.order_num ORDER_NUM
FROM 
  olap_meas_folder_contents$ mf, 
  obj$ o, 
  olap_measures$ m,
  obj$ co,
  user$ cu
WHERE 
  mf.measure_folder_obj#=o.obj# 
  AND o.owner#=USERENV('SCHEMAID')
  AND mf.object_type = 2 -- MEASURE 
  AND mf.object_id = m.measure_id
  AND m.cube_obj# = co.obj#
  AND co.owner# = cu.user#
/

comment on table USER_MEASURE_FOLDER_CONTENTS is
'OLAP Measure Folder Contents owned by the user in the database'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.MEASURE_FOLDER_NAME is
'Name of the owning OLAP Measure Folder'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.CUBE_OWNER is
'Owner of the cube of the OLAP Measure Folder Content'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.CUBE_NAME is
'Name of the owning cube of the OLAP Measure Folder Content'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.MEASURE_NAME is
'Name of the owning measure of the OLAP Measure Folder Content'
/
comment on column USER_MEASURE_FOLDER_CONTENTS.ORDER_NUM is
'Order number of the OLAP Measure Folder Content'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_MEASURE_FOLDER_CONTENTS
FOR SYS.USER_MEASURE_FOLDER_CONTENTS
/
GRANT SELECT ON USER_MEASURE_FOLDER_CONTENTS to public
/

-- OLAP_CUBE_BUILD_PROCESSES$ DATA DICTIONARY VIEWS --

create or replace view DBA_CUBE_BUILD_PROCESSES
as
SELECT 
  u.name OWNER,
  o.name BUILD_PROCESS_NAME,
  syn.syntax_clob BUILD_PROCESS,
  d.description_value DESCRIPTION
FROM 
  olap_cube_build_processes$ ia, 
  obj$ o, 
  user$ u, 
  olap_syntax$ syn,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 8 --BUILD_PROCESS
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  ia.obj# = o.obj# 
  AND o.owner# = u.user# 
  AND ia.obj# = d.owning_object_id(+)
  AND syn.owner_id(+)=ia.obj#
  AND syn.owner_type(+)=8
  AND syn.ref_role(+)=13 -- build process 
/

comment on table DBA_CUBE_BUILD_PROCESSES is
'OLAP Build Processes in the database'
/
comment on column DBA_CUBE_BUILD_PROCESSES.OWNER is
'Owner of the OLAP Build Process'
/
comment on column DBA_CUBE_BUILD_PROCESSES.BUILD_PROCESS_NAME is
'Name of the OLAP Build Process'
/
comment on column DBA_CUBE_BUILD_PROCESSES.BUILD_PROCESS is
'The Build Process syntax text for the OLAP Build Process'
/
comment on column DBA_CUBE_BUILD_PROCESSES.DESCRIPTION is
'Long Description of the OLAP Build Process'
/

CREATE OR REPLACE PUBLIC SYNONYM DBA_CUBE_BUILD_PROCESSES 
FOR SYS.DBA_CUBE_BUILD_PROCESSES
/
GRANT SELECT ON DBA_CUBE_BUILD_PROCESSES to select_catalog_role
/

create or replace view ALL_CUBE_BUILD_PROCESSES
as
SELECT 
  u.name OWNER,
  o.name BUILD_PROCESS_NAME,
  syn.syntax_clob BUILD_PROCESS,
  d.description_value DESCRIPTION
FROM 
  olap_cube_build_processes$ ia, 
  obj$ o, 
  user$ u, 
  olap_syntax$ syn,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 8 --BUILD_PROCESS
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  ia.obj# = o.obj# 
  AND o.owner# = u.user# 
  AND ia.obj# = d.owning_object_id(+)
  AND syn.owner_id(+)=ia.obj#
  AND syn.owner_type(+)=8
  AND syn.ref_role(+)=13 -- build process 
  AND (o.owner# in (userenv('SCHEMAID'), 1)   -- public objects 
       or o.obj# in 
            ( select obj#  -- directly granted privileges 
              from sys.objauth$
              where grantee# in ( select kzsrorol from x$kzsro )
            )
       or   -- user has system privileges 
              ( exists (select null from v$enabledprivs
                        where priv_number in (-321, -- DROP ANY BUILD PROCESS 
                                              -322) -- UPDATE ANY BUILD PROCESS
                        )
              )
            )
/

comment on table ALL_CUBE_BUILD_PROCESSES is
'OLAP Build Processes in the database accessible to the user'
/
comment on column ALL_CUBE_BUILD_PROCESSES.OWNER is
'Owner of the OLAP Build Processes'
/
comment on column ALL_CUBE_BUILD_PROCESSES.BUILD_PROCESS_NAME is
'Name of the OLAP Build Process'
/
comment on column ALL_CUBE_BUILD_PROCESSES.BUILD_PROCESS is
'The Build Process syntax text for the OLAP Build Process'
/
comment on column ALL_CUBE_BUILD_PROCESSES.DESCRIPTION is
'Long Description of the OLAP Build Process'
/

CREATE OR REPLACE PUBLIC SYNONYM ALL_CUBE_BUILD_PROCESSES 
FOR SYS.ALL_CUBE_BUILD_PROCESSES
/
GRANT SELECT ON ALL_CUBE_BUILD_PROCESSES to public
/

create or replace view USER_CUBE_BUILD_PROCESSES
as
SELECT 
  o.name BUILD_PROCESS_NAME,
  syn.syntax_clob BUILD_PROCESS,
  d.description_value DESCRIPTION
FROM 
  olap_cube_build_processes$ ia, 
  obj$ o, 
  olap_syntax$ syn,
  (select d.* from olap_descriptions$ d, nls_session_parameters n where
	n.parameter = 'NLS_LANGUAGE'
	and d.description_type = 'Description'
	and d.owning_object_type = 8 --BUILD_PROCESS
	and (d.language = n.value
             or d.language like n.value || '\_%' escape '\')) d
WHERE 
  ia.obj# = o.obj# 
  AND o.owner# = USERENV('SCHEMAID')
  AND ia.obj# = d.owning_object_id(+)
  AND syn.owner_id(+)=ia.obj#
  AND syn.owner_type(+)=8
  AND syn.ref_role(+)=13 -- build process 
/

comment on table USER_CUBE_BUILD_PROCESSES is
'OLAP Build Processes owned by the user in the database'
/
comment on column USER_CUBE_BUILD_PROCESSES.BUILD_PROCESS_NAME is
'Name of the OLAP Build Process'
/
comment on column USER_CUBE_BUILD_PROCESSES.BUILD_PROCESS is
'The Build Process syntax text for the OLAP Build Process'
/
comment on column USER_CUBE_BUILD_PROCESSES.DESCRIPTION is
'Long Description of the OLAP Build Process'
/

CREATE OR REPLACE PUBLIC SYNONYM USER_CUBE_BUILD_PROCESSES 
FOR SYS.USER_CUBE_BUILD_PROCESSES
/
GRANT SELECT ON USER_CUBE_BUILD_PROCESSES to public
/

