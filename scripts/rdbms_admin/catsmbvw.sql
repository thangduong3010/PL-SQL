Rem
Rem $Header: rdbms/admin/catsmbvw.sql /main/12 2009/12/08 18:04:23 arbalakr Exp $
Rem
Rem catsmbvw.sql
Rem
Rem Copyright (c) 2006, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catsmbvw.sql - Catalog script for SQL Management Base views
Rem
Rem    DESCRIPTION
Rem      Create SQL Management Base catalog views
Rem
Rem    NOTES
Rem      Must be run when connected as SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    arbalakr    11/18/09 - truncate module/action to max lengths from
Rem                           X$MODACT_LENGTH
Rem    ddas        09/14/09 - #(8827637) add reproduced to
Rem                           dba_sql_plan_baselines
Rem    yzhu        02/01/08 - Add stored outline origin to
Rem                           dba_sql_plan_baselines
Rem    mziauddi    06/07/07 - use dynamic_sampling hint for estimating
Rem                           selectivity of complex preds on expression
Rem                           columns (enabled, accepted, origin) of
Rem                           dba_sql_plan_baselines
Rem    pbelknap    03/20/07 - remove sqlobj$probation_stats
Rem    mziauddi    04/05/07 - dba_sql_plan_baselines: add
Rem                           st.signature=ad.signature
Rem    ddas        03/09/07 - dba_sql_plan_baselines: remove plan_id, add
Rem                           parsing_schema_name
Rem    ansingh     02/27/07 - 5623405: Distinguish between SQL profile and SQL
Rem                           patch
Rem    ddas        01/17/07 - add more plan baseline origins
Rem    ddas        10/27/06 - rename dba_plan_baselines to
Rem                           dba_sql_plan_baselines
Rem    ddas        10/02/06 - plan_hash_value=>plan_id, add version
Rem    pbelknap    10/08/06 - comment for dba_sql_profiles
Rem    mziauddi    09/15/06 - add dba_sql_management_config view
Rem    mziauddi    09/10/06 - drop priority column from
Rem                           dba_sql_plan_baselines view
Rem    ddas        08/11/06 - split long line
Rem    pbelknap    08/10/06 - change advisor task fk cols for dba_sql_prof
Rem    kyagoub     08/03/06 - add AUTO-SQLTUNE to dba_sql_plan_baselines
Rem    ddas        07/31/06 - redefine views
Rem    pbelknap    06/06/06 - new profile type for auto-creation 
Rem    mziauddi    06/13/06 - change signature_handle to sql_handle 
Rem    mziauddi    05/09/06 - define dba_sql_profiles and dba_sql_plan_baselines
Rem    mziauddi    04/07/06 - Created
Rem

Rem =========================================================================
Rem SQL Management Base: dba sql profiles view
Rem =========================================================================


--
-- NOTE: this view's schema is relied upon heavily by the import/export of
--       sql profiles feature.  Changes to its schema may imply changes to the
--       staging table and/or updating the staging table version.
--
--       The strings used in the TYPE column must agree with the 
--       XXX_SMB_STR constants kept in qsmb.h.  They also appear in logic
--       in prvtsqlt's sqltune reports.
--
CREATE OR REPLACE VIEW dba_sql_profiles (
    name, category, signature, sql_text,
    created, last_modified, description,
    type,
    status,
    force_matching,
    task_id, task_exec_name, task_obj_id, task_fnd_id,
    task_rec_id
) AS
SELECT
    so.name, so.category, so.signature, st.sql_text,
    ad.created, ad.last_modified, ad.description,
    DECODE(ad.origin, 1, 'MANUAL', 2, 'AUTO', 'UNKNOWN'),
    DECODE(BITAND(so.flags, 1), 1, 'ENABLED', 'DISABLED'),
    DECODE(BITAND(sq.flags, 1), 1, 'YES', 'NO'),
    ad.task_id, ad.task_exec_name, ad.task_obj_id, ad.task_fnd_id,
    ad.task_rec_id
FROM
    sqlobj$        so,
    sqlobj$auxdata ad,
    sql$text       st,
    sql$           sq
WHERE
    so.signature = st.signature AND
    so.signature = ad.signature AND
    so.category  = ad.category  AND
    so.signature = sq.signature AND
    so.obj_type = 1 AND
    ad.obj_type = 1
/

COMMENT ON TABLE dba_sql_profiles IS
    'set of sql profiles'
/
COMMENT ON COLUMN dba_sql_profiles.name IS
    'name of sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.category IS
    'category of sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.signature IS
    'unique identifier generated from normalized SQL text'
/
COMMENT ON COLUMN dba_sql_profiles.sql_text IS
    'un-normalized SQL text'
/
COMMENT ON COLUMN dba_sql_profiles.created IS
    'date stamp when sql profile created'
/
COMMENT ON COLUMN dba_sql_profiles.last_modified IS
    'date stamp when sql profile was last modified'
/
COMMENT ON COLUMN dba_sql_profiles.description IS
    'text description provided for sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.type IS
    'type of sql profile (how created)'
/
COMMENT ON COLUMN dba_sql_profiles.status IS
    'enabled/disabled status of sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.force_matching IS
    'signature is force matching or exact matching'
/
COMMENT ON COLUMN dba_sql_profiles.task_id IS
    'advisor task id that generated the sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.task_exec_name IS
    'advisor execution name for the sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.task_obj_id IS
    'advisor object id for the sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.task_fnd_id IS
    'advisor finding id for the sql profile'
/
COMMENT ON COLUMN dba_sql_profiles.task_rec_id IS
    'advisor recommendation id for the sql profile'
/

-- create public synonym and grant select on it.
CREATE OR REPLACE PUBLIC SYNONYM dba_sql_profiles FOR dba_sql_profiles
/
GRANT SELECT ON dba_sql_profiles TO select_catalog_role
/

Rem =========================================================================
Rem SQL Management Base: dba sql plan baselines view
Rem =========================================================================

CREATE OR REPLACE VIEW dba_sql_plan_baselines (
    signature,
    sql_handle,
    sql_text,
    plan_name,
    creator,
    origin,
    parsing_schema_name,
    description,
    version,
    created,
    last_modified,
    last_executed,
    last_verified,
    enabled,
    accepted,
    fixed,
    reproduced,
    autopurge,
    optimizer_cost,
    module,
    action,
    executions,
    elapsed_time,
    cpu_time,
    buffer_gets,
    disk_reads,
    direct_writes,
    rows_processed,
    fetches,
    end_of_fetch_count
) AS
SELECT /*+ dynamic_sampling(3) */
    so.signature,
    st.sql_handle,
    st.sql_text,
    so.name,
    ad.creator,
    DECODE(ad.origin, 1, 'MANUAL-LOAD',
                      2, 'AUTO-CAPTURE',
                      3, 'MANUAL-SQLTUNE',
                      4, 'AUTO-SQLTUNE',
                      5, 'STORED-OUTLINE',
                         'UNKNOWN'),
    ad.parsing_schema_name,
    ad.description,
    ad.version,
    ad.created,
    ad.last_modified,
    so.last_executed,
    ad.last_verified,
    DECODE(BITAND(so.flags, 1), 1, 'YES', 'NO'),
    DECODE(BITAND(so.flags, 2), 2, 'YES', 'NO'),
    DECODE(BITAND(so.flags, 4), 4, 'YES', 'NO'),
    DECODE(BITAND(so.flags, 64), 64, 'NO', 'YES'),
    DECODE(BITAND(so.flags, 8), 8, 'YES', 'NO'),
    ad.optimizer_cost,
    substrb(ad.module,1,(select ksumodlen from x$modact_length)) module,
    substrb(ad.action,1,(select ksuactlen from x$modact_length)) action,
    ad.executions,
    ad.elapsed_time,
    ad.cpu_time,
    ad.buffer_gets,
    ad.disk_reads,
    ad.direct_writes,
    ad.rows_processed,
    ad.fetches,
    ad.end_of_fetch_count
FROM
    sqlobj$        so,
    sqlobj$auxdata ad,
    sql$text       st
WHERE
    so.signature = st.signature AND
    ad.signature = st.signature AND
    so.signature = ad.signature AND
    so.plan_id = ad.plan_id AND
    so.obj_type = 2 AND
    ad.obj_type = 2
/

COMMENT ON TABLE dba_sql_plan_baselines IS
    'set of plan baselines'
/
COMMENT ON COLUMN dba_sql_plan_baselines.signature IS
    'unique SQL identifier generated from normalized SQL text'
/
COMMENT ON COLUMN dba_sql_plan_baselines.sql_handle IS
    'unique SQL identifier in string form as a search key'
/
COMMENT ON COLUMN dba_sql_plan_baselines.sql_text IS
    'un-normalized SQL text'
/
COMMENT ON COLUMN dba_sql_plan_baselines.plan_name IS
    'unique plan identifier in string form as a search key'
/
COMMENT ON COLUMN dba_sql_plan_baselines.creator IS
    'user who created the plan baseline'
/
COMMENT ON COLUMN dba_sql_plan_baselines.origin IS
    'how plan baseline was created'
/
COMMENT ON COLUMN dba_sql_plan_baselines.parsing_schema_name IS
    'name of parsing schema'
/
COMMENT ON COLUMN dba_sql_plan_baselines.description IS
    'text description provided for plan baseline'
/
COMMENT ON COLUMN dba_sql_plan_baselines.version IS
    'database version at time of plan baseline creation'
/
COMMENT ON COLUMN dba_sql_plan_baselines.created IS
    'time when plan baseline was created'
/
COMMENT ON COLUMN dba_sql_plan_baselines.last_modified IS
    'time when plan baseline was last modified'
/
COMMENT ON COLUMN dba_sql_plan_baselines.last_executed IS
    'time when plan baseline was last executed'
/
COMMENT ON COLUMN dba_sql_plan_baselines.last_verified IS
    'time when plan baseline was last verified'
/
COMMENT ON COLUMN dba_sql_plan_baselines.enabled IS
    'enabled status of plan baseline'
/
COMMENT ON COLUMN dba_sql_plan_baselines.accepted IS
    'accepted status of plan baseline'
/
COMMENT ON COLUMN dba_sql_plan_baselines.fixed IS
    'fixed status of plan baseline'
/
COMMENT ON COLUMN dba_sql_plan_baselines.reproduced IS
    'reproduced status of plan baseline'
/
COMMENT ON COLUMN dba_sql_plan_baselines.autopurge IS
    'auto-purge status of plan baseline'
/
COMMENT ON COLUMN dba_sql_plan_baselines.optimizer_cost IS
    'plan baseline optimizer cost'
/
COMMENT ON COLUMN dba_sql_plan_baselines.module IS
    'application module name'
/
COMMENT ON COLUMN dba_sql_plan_baselines.action IS
    'application action'
/
COMMENT ON COLUMN dba_sql_plan_baselines.executions IS
    'number of plan baseline executions'
/
COMMENT ON COLUMN dba_sql_plan_baselines.elapsed_time IS
    'total elapse time'
/
COMMENT ON COLUMN dba_sql_plan_baselines.cpu_time IS
    'total CPU time'
/
COMMENT ON COLUMN dba_sql_plan_baselines.buffer_gets IS
    'total buffer gets'
/
COMMENT ON COLUMN dba_sql_plan_baselines.disk_reads IS
    'total disk reads'
/
COMMENT ON COLUMN dba_sql_plan_baselines.direct_writes IS
    'total direct writes'
/
COMMENT ON COLUMN dba_sql_plan_baselines.rows_processed IS
    'total rows processed'
/
COMMENT ON COLUMN dba_sql_plan_baselines.fetches IS
    'total number of fetches'
/
COMMENT ON COLUMN dba_sql_plan_baselines.end_of_fetch_count IS
    'total number of full fetches'
/

-- create public synonym and grant select on it.
CREATE OR REPLACE PUBLIC SYNONYM dba_sql_plan_baselines
    FOR dba_sql_plan_baselines
/
GRANT SELECT ON dba_sql_plan_baselines TO select_catalog_role
/

Rem =========================================================================
Rem SQL Management Base: dba sql management configuration view
Rem =========================================================================

CREATE OR REPLACE VIEW dba_sql_management_config (
    parameter_name, parameter_value, last_modified, modified_by
) AS
SELECT
    parameter_name, parameter_value, last_updated, updated_by
FROM
    smb$config
WHERE
    parameter_name NOT LIKE '%TRACING%'
/

COMMENT ON COLUMN dba_sql_management_config.parameter_name IS
    'name of the configuration parameter'
/
COMMENT ON COLUMN dba_sql_management_config.parameter_value IS
    'value of the configuration parameter'
/
COMMENT ON COLUMN dba_sql_management_config.last_modified IS
    'datetime of last update to the parameter value'
/
COMMENT ON COLUMN dba_sql_management_config.modified_by IS
    'user who last updated the parameter value'
/

-- create public synonym and grant select on it.
CREATE OR REPLACE PUBLIC SYNONYM dba_sql_management_config
    FOR dba_sql_management_config
/
GRANT SELECT ON dba_sql_management_config TO select_catalog_role
/


--
-- NOTE: this view's schema is relied upon heavily by the import/export of
--       sql profiles feature.  Changes to its schema may imply changes to the
--       staging table and/or updating the staging table version.
--
--       The strings used in the TYPE column must agree with the 
--       XXX_SMB_STR constants kept in qsmb.h.  They also appear in logic
--       in prvtsqlt's sqltune reports.
--
CREATE OR REPLACE VIEW dba_sql_patches (
    name, category, signature, sql_text,
    created, last_modified, description,
    status,
    force_matching,
    task_id, task_exec_name, task_obj_id, task_fnd_id,
    task_rec_id
) AS
SELECT
    so.name, so.category, so.signature, st.sql_text,
    ad.created, ad.last_modified, ad.description,
    DECODE(BITAND(so.flags, 1), 1, 'ENABLED', 'DISABLED'),
    DECODE(BITAND(sq.flags, 1), 1, 'YES', 'NO'),
    ad.task_id, ad.task_exec_name, ad.task_obj_id, ad.task_fnd_id,
    ad.task_rec_id
FROM
    sqlobj$        so,
    sqlobj$auxdata ad,
    sql$text       st,
    sql$           sq
WHERE
    so.signature = st.signature AND
    so.signature = ad.signature AND
    so.category  = ad.category  AND
    so.signature = sq.signature AND
    so.obj_type = 3 AND
    ad.obj_type = 3
/
COMMENT ON TABLE dba_sql_patches IS
    'set of sql patches'
/
COMMENT ON COLUMN dba_sql_patches.name IS
    'name of sql patch'
/
COMMENT ON COLUMN dba_sql_patches.category IS
    'category of sql patch'
/
COMMENT ON COLUMN dba_sql_patches.signature IS
    'unique identifier generated from normalized SQL text'
/
COMMENT ON COLUMN dba_sql_patches.sql_text IS
    'un-normalized SQL text'
/
COMMENT ON COLUMN dba_sql_patches.created IS
    'date stamp when sql patch created'
/
COMMENT ON COLUMN dba_sql_patches.last_modified IS
    'date stamp when sql patch was last modified'
/
COMMENT ON COLUMN dba_sql_patches.description IS
    'text description provided for sql patch'
/
COMMENT ON COLUMN dba_sql_patches.status IS
    'enabled/disabled status of sql patch'
/
COMMENT ON COLUMN dba_sql_patches.force_matching IS
    'signature is force matching or exact matching'
/
COMMENT ON COLUMN dba_sql_patches.task_id IS
    'advisor task id that generated the sql patch'
/
COMMENT ON COLUMN dba_sql_patches.task_exec_name IS
    'advisor execution name for the sql patch'
/
COMMENT ON COLUMN dba_sql_patches.task_obj_id IS
    'advisor object id for the sql patch'
/
COMMENT ON COLUMN dba_sql_patches.task_fnd_id IS
    'advisor finding id for the sql patch'
/
COMMENT ON COLUMN dba_sql_patches.task_rec_id IS
    'advisor recommendation id for the sql patch'
/
-- create public synonym and grant select on it.
CREATE OR REPLACE PUBLIC SYNONYM dba_sql_patches FOR dba_sql_patches
/
GRANT SELECT ON dba_sql_patches TO select_catalog_role
/
