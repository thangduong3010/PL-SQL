Rem
Rem $Header: emll/admin/scripts/ocmdbb.sql /st_emll_10.3.8/1 2012/12/28 09:24:00 jsutton Exp $
Rem
Rem ocmdbb.sql
Rem
Rem Copyright (c) 2005, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ocmdbb.sql - OCM DB configuration collection package Body
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsutton     12/27/12 - more CDB required work
Rem    jsutton     11/13/12 - do not uppercase users
Rem    jsutton     10/22/12 - fix up pdb related queries per bug 14564972
Rem    jsutton     08/22/12 - Fix discovery and collection issues
Rem    jsutton     08/20/12 - Fix queries so they work in RAC
Rem    jsutton     03/21/12 - PDB support
Rem    jsutton     03/06/12 - headroom calculation fix
Rem    jsutton     02/24/12 - date range for time_dp subtly different
Rem    jsutton     02/17/12 - fix conditional
Rem    jsutton     02/14/12 - need execute immediate blocks for pre-10g
Rem    jsutton     02/13/12 - fix date format
Rem    jsutton     01/26/12 - Add SCN info
Rem    jsutton     12/01/11 - catch exceptions around calls to UTL_FILE
Rem    pbhogara    07/08/11 - removing db_inst_only
Rem    glavash     07/07/11 - change cpu_usage query to return 1 row, null out
Rem                           timestamp
Rem    jsutton     06/21/11 - ensure cell_list is in instrumentation file
Rem    pbhogara    05/19/11 - collect db_inst_only_info
Rem    davili      04/25/11 - Add exadata releaseVersion and patches
Rem    jsutton     03/07/11 - Flush output so as not to consume PGA per bug
Rem                           8738709
Rem    nmittal     02/23/11 - bug 11677129
Rem    glavash     02/08/11 - add gc columns
Rem    ysun        12/03/10 - add version
Rem    ckalivar    11/18/10 - Bug 10198634: handled case- missing
Rem                           diagnostic_dest parameter from v
Rem    aghanti     10/14/10 - Bug 9033775 - Write end marker to
Rem                           .ll*/.ccr/.emrep file
Rem    jsutton     08/17/10 - XbranchMerge jsutton_xmldb_check from
Rem                           st_emll_10.3.3
Rem    ckalivar    07/22/10 - XbranchMerge ckalivar_bug-9903308 from main
Rem    ckalivar    07/20/10 - Bug 9903308 - Improve query to check usage of
Rem                           data_vault
Rem    jsutton     04/23/10 - add trigger for db startup (RAC instance
Rem                           discovery aid)
Rem    raankire    02/10/10 - Adding autotask_client metric
Rem    raankire    02/10/10 - Adding supplemental log to db_dbNInstanceInfo table
Rem    aghanti     12/07/09 - Use word length to determine bit-ness of the DB
Rem    jsutton     07/24/09 - catch exceptions when writing header
Rem    bkchoudh    07/15/09 - Fixed Bug 8686321 
Rem    jsutton     06/10/09 - Get IP address of host where collection runs
Rem    bkchoudh    06/04/09 - add db_compnents and db scheduler jobs
Rem    pparida     06/04/09 - 8268571: Check for compatible param too.
Rem    aghanti     04/26/09 - Collect NLS_CHARACTERSET & add it as config
Rem                           property to .ll file
Rem    ysun        04/22/09 - add more versions
Rem    ysun        04/10/09 - update column size
Rem    ysun        03/13/09 - add cell support
Rem    pparida     02/19/09 - 6111739: Fix query in
Rem                           collect_high_water_mark_stats
Rem    glavash     01/05/09 - increase size of l_column for escape characters
Rem                           in write_results
Rem    glavash     12/15/08 - change write_oem query to be non dynamic
Rem    glavash     12/11/07 - escape |
Rem    dkapoor     07/26/07 - implement LMS infrastructure
Rem    pparida     08/06/07 - ER 5900734: Construct is_64bit and rel_status
Rem                           columns for metric db_dbNInstanceInfo.
Rem    dkapoor     03/30/07 - add cpu usage stats
Rem    dkapoor     06/13/06 - exception enabled interface 
Rem    dkapoor     01/23/07 - collect dbfus and highwwater mark separately
Rem    dkapoor     10/03/06 - add create bytes in datafile metric
Rem    dkapoor     09/12/06 - set proper number format
Rem    dkapoor     09/12/06 - add db_users
Rem    dkapoor     06/17/06 - collect ha_info for 8i 
Rem    dkapoor     06/13/06 - support for 11g 
Rem    dkapoor     06/02/06 - change ccr_user to ocm 
Rem    dkapoor     04/04/06 - remove HMMSize in db_rollback_segs 
Rem    dkapoor     12/09/05 - use v$instance for version 
Rem    dkapoor     11/23/05 - add release,edition,version in 
Rem                           db_dbNInstanceInfo 
Rem    dkapoor     11/16/05 - add db feature usage and high water mark config 
Rem    dkapoor     10/11/05 - impl stats pack, backup metrics 
Rem    dkapoor     10/10/05 - change user to ccr 
Rem    dkapoor     10/05/05 - mask archived column of redologs metric 
Rem    dkapoor     10/05/05 - round of SGAsizes 
Rem    dkapoor     10/05/05 - use the time stamp format:(yyyy-MM-dd HH:mm:ss) 
Rem    dkapoor     09/30/05 - impl 8.1.7 support 
Rem    dkapoor     09/22/05 - fix the 9.2 sql query 
Rem    ndutko      08/03/05 - ndutko_code_checkin
Rem    dkapoor     03/22/05 - Created
Rem

CREATE OR REPLACE PACKAGE body ORACLE_OCM.MGMT_DB_LL_METRICS AS

g_config_handle UTL_FILE.FILE_TYPE := NULL;
g_version_category VARCHAR2(10) := NULL;

g_dbID v$database.DBID%TYPE := NULL;
g_db_version v$instance.version%TYPE := NULL;

g_is_cdb VARCHAR2(4) := 'NO';

METRIC_END_MARKER constant VARCHAR2(4) := ':End';
METRIC_BEGIN_MARKER constant VARCHAR2(6) := ':Begin';

INSTANCE_DELIMITER constant VARCHAR2(1) := ':';
CELL_DELIMITER constant VARCHAR2(1) := '&';

/*
 Compute the version category 
*/
FUNCTION get_version_category RETURN VARCHAR2 IS
  l_db_version   v$instance.version%TYPE;
  l_temp_version v$instance.version%TYPE;
  l_compat_vers  v$parameter.value%TYPE;
  l_major_version_ndx NUMBER;
BEGIN
  IF g_db_version IS NULL THEN
    select version into l_db_version from v$instance;
  ELSE
    l_db_version := g_db_version;
  END IF;

  begin
    select substr(value,1,5) into l_compat_vers from v$parameter where lower(name) = 'compatible';
  exception
    WHEN NO_DATA_FOUND THEN
      l_compat_vers := SUBSTR(l_db_version,1,5);
  end;

  l_temp_version := LPAD(l_db_version,10, '0');
  IF  l_temp_version < MIN_SUPPORTED_VERSION THEN
      return NOT_SUPPORTED_VERSION;
  END IF;

  IF l_compat_vers = '8.1.7' THEN 
      return VERSION_817;
  END IF;
  l_temp_version := SUBSTR(l_db_version,1,4);
  IF l_temp_version = '10.1' THEN 
      return VERSION_10gR1;
  END IF;
  IF  l_temp_version= '10.2' THEN 
        return VERSION_10gR2; 
  END IF;
  IF  l_temp_version= '11.1' THEN 
        return VERSION_11gR1; 
  END IF;
  IF  l_temp_version= '11.2' THEN 
        return VERSION_11gR2; 
  END IF;
  IF  l_temp_version= '12.0' OR l_temp_version='12.1' THEN 
        return VERSION_12gR1; 
  END IF;
  l_temp_version := SUBSTR(l_db_version,1,3);
  IF l_temp_version = '9.2' THEN 
      return VERSION_9iR2; 
  END IF;
  l_temp_version := SUBSTR(l_db_version,1,3);
  IF l_temp_version = '9.0' THEN 
      return VERSION_9i; 
  END IF;
  l_temp_version := SUBSTR(l_db_version,1,5);
  IF l_temp_version = '8.1.7' THEN 
      return VERSION_817; 
  END IF;
  return HIGHER_SUPPORTED_VERSION;
END get_version_category;


/* Check for consolidated database */
PROCEDURE CHECK_IS_CDB IS
BEGIN
  IF g_version_category = VERSION_12gR1 THEN
    BEGIN
      execute immediate 'SELECT UPPER(CDB) FROM V$DATABASE' into g_is_cdb;
      EXCEPTION
        WHEN OTHERS THEN
          null;
    END;
  END IF;
  IF g_is_cdb = 'YES' THEN
    execute immediate 'alter session set container=CDB$ROOT';
  END IF;
END;


/*
Write em_error record
*/
PROCEDURE write_error(p_error_msg VARCHAR2) IS 
BEGIN
  UTL_FILE.PUT_LINE(g_config_handle,'em_error=' || p_error_msg);
  UTL_FILE.FFLUSH(g_config_handle);
END write_error;


/*
Put marker for the metric
*/
PROCEDURE put_metric_marker(marker in VARCHAR2, 
    metric in VARCHAR2,
    instance_name in VARCHAR2 default null,
    cell_name in VARCHAR2 default null )
IS
BEGIN
    UTL_FILE.PUT( g_config_handle, metric );
    IF instance_name is not NULL THEN
        UTL_FILE.PUT( g_config_handle, INSTANCE_DELIMITER||instance_name);
    END IF; 
    IF cell_name is not NULL THEN
        UTL_FILE.PUT( g_config_handle, CELL_DELIMITER||cell_name);
    END IF; 
    UTL_FILE.PUT_LINE(g_config_handle,marker);
END put_metric_marker;


/*
 Generic function to write results of the query to the config dump file
*/
PROCEDURE write_results(query IN VARCHAR2, separator IN VARCHAR2 default '|')
IS
    l_em_result_cur INTEGER DEFAULT DBMS_SQL.OPEN_CURSOR;
    l_col_cnt       NUMBER DEFAULT 0;
    /* increase size to handle escape characters */
    l_columnValue   VARCHAR2(6000);
    l_status        NUMBER ;

BEGIN
  BEGIN
    dbms_sql.parse(l_em_result_cur, query, dbms_sql.native);

    /* define all the columns */
    FOR i IN 1 .. 255 LOOP
      BEGIN
        dbms_sql.define_column(l_em_result_cur, i, l_columnValue, 4000);
        l_col_cnt := i;
        EXCEPTION
          WHEN OTHERS THEN
            IF (sqlcode = -1007) THEN exit; 
              ELSE
                RAISE;
            END IF;
      END;
    END LOOP;

    dbms_sql.define_column(l_em_result_cur, 1, l_columnValue, 4000);
    l_status := DBMS_SQL.EXECUTE (l_em_result_cur);

    LOOP
      exit when (dbms_sql.fetch_rows(l_em_result_cur) <= 0);
      UTL_FILE.PUT( g_config_handle, 'em_result=');
      FOR i IN 1 .. l_col_cnt LOOP
        IF i != 1 THEN
          UTL_FILE.PUT( g_config_handle, separator);
        END IF;
        dbms_sql.column_value( l_em_result_cur, i, l_columnValue );
        /* replace seperators with escaped separators */
        l_columnValue := replace(l_columnValue,'#','##');
        l_columnValue := replace(l_columnValue,separator,'#'|| separator);
        UTL_FILE.PUT( g_config_handle, l_columnValue );
      END LOOP;
      UTL_FILE.NEW_LINE(g_config_handle );
    END LOOP;

    dbms_sql.close_cursor(l_em_result_cur);

    EXCEPTION
      WHEN UTL_FILE.INVALID_FILEHANDLE 
      OR UTL_FILE.INVALID_OPERATION 
      OR UTL_FILE.WRITE_ERROR THEN
        IF DBMS_SQL.IS_OPEN(l_em_result_cur) = TRUE THEN
          dbms_sql.close_cursor(l_em_result_cur);
        END IF;
        RAISE;
      WHEN OTHERS THEN
        IF DBMS_SQL.IS_OPEN(l_em_result_cur) = TRUE THEN
          dbms_sql.close_cursor(l_em_result_cur);
        END IF;
        /*
        On any non-utl file exceptions, log as em_error
        for the metric.
        */
      write_error('SQLERRM: ' || SQLERRM || ' SQLCODE: ' || SQLCODE);
  END;
END write_results;


/*
 Generic function to write to the config dump file
*/
PROCEDURE write_metric(metric IN VARCHAR2, query IN VARCHAR2, instance_name in VARCHAR2 default null, 
                       cell_name in VARCHAR2 default null, separator IN VARCHAR2 default '|')
IS
  l_end_done BOOLEAN DEFAULT FALSE;
BEGIN
  put_metric_marker(METRIC_BEGIN_MARKER,metric,instance_name, cell_name);
  write_results(query,separator);
  put_metric_marker(METRIC_END_MARKER,metric,instance_name, cell_name);
  l_end_done   := TRUE;
  UTL_FILE.FFLUSH(g_config_handle);
  EXCEPTION
    WHEN OTHERS THEN
      IF NOT l_end_done THEN
        put_metric_marker(METRIC_END_MARKER,metric,instance_name, cell_name);
        UTL_FILE.FFLUSH(g_config_handle);
      END IF;
    RAISE;
END write_metric;


/*
Private procedure
Collect metric=db_init_params
*/
procedure collect_db_init_params IS
  CURSOR l_res_cur IS select inst_id,instance_name from gv$instance;
BEGIN
  FOR inst_id_row in l_res_cur LOOP
    write_metric('db_init_params', 
      'SELECT name, '||
      ' case '||
      '  when name=''filesystemio_options'' and value like ''asynch%'' then ''asynch'' '||
      '  when name=''filesystemio_options'' and value like ''none%'' then ''none'''||
      '  when name=''filesystemio_options'' and value like ''directIO%'' then ''directIO'''||
      '  when name=''filesystemio_options'' and value like ''setall%'' then ''setall'''||
      '  when name=''filesystemio_options'' then '' '''||
      '  else value '||
      ' end,'||
      ' isdefault FROM gv$parameter ' ||
      ' WHERE name != ''resource_manager_plan'' '||
      ' AND inst_id = ' || inst_id_row.inst_id,inst_id_row.instance_name);
  END LOOP;
END collect_db_init_params;


/*
Private procedure
Collect metric=cdb_init_params
*/
procedure collect_cdb_init_params IS
  CURSOR l_res_cur IS select inst_id,instance_name from gv$instance;
BEGIN
  FOR inst_id_row in l_res_cur LOOP
    write_metric('cdb_init_params',
      'SELECT pdb, '||
      ' name, '||
      ' CASE '||
       ' WHEN name=''filesystemio_options'' and value like ''asynch%'' then ''asynch'' '||
       ' WHEN name=''filesystemio_options'' and value like ''none%'' then ''none'' '||
       ' WHEN name=''filesystemio_options'' and value like ''directIO%'' then ''directIO'' '||
       ' WHEN name=''filesystemio_options'' and value like ''setall%'' then ''setall''  '||
       ' WHEN name=''filesystemio_options'' then '' '' '||
       ' ELSE value END value, '||
       ' isdefault '||
       'FROM '||
       ' (SELECT * FROM  '||
        ' (WITH '||
         ' override AS (SELECT name, value, isdefault, con_id '||
          ' FROM gv$system_parameter  '||
          ' WHERE con_id != 0 AND inst_id = ' || inst_id_row.inst_id ||'), '||
         ' pdbs AS (SELECT DISTINCT con_id, name pdb '||
          ' FROM gv$containers WHERE con_id != 2 and inst_id = '|| inst_id_row.inst_id ||') '||
         ' SELECT p.name, p.value, p.isdefault, pdb.pdb '||
         ' FROM gv$system_parameter p, pdbs pdb '||
         ' WHERE name NOT IN '||
          ' (SELECT name '||
           ' FROM override o '||
           ' WHERE o.con_id = pdb.con_id) '||
          ' AND p.con_id = 0 '||
         ' UNION '||
         ' SELECT name,value,isdefault,pdb.pdb '||
          ' FROM override o, pdbs pdb '||
           ' WHERE pdb.con_id = o.con_id) '||
        ') WHERE name != ''resource_manager_plan'' order by 1,2', inst_id_row.instance_name);
  END LOOP;
END;

/*
Private procedure
  collect metric=cdb_pdb_over_params
*/
procedure collect_cdb_pdb_over_params IS
  CURSOR l_res_cur IS select inst_id,instance_name from gv$instance;
BEGIN
  FOR inst_id_row in l_res_cur LOOP
    write_metric('cdb_pdb_over_params',
    'SELECT distinct pdb.pdb,' ||
    ' p.name,' ||
    ' case ' ||
    ' when p.name=''filesystemio_options'' and p.value like ''asynch%'' then ''asynch''' ||
    ' when p.name=''filesystemio_options'' and p.value like ''none%'' then ''none''' ||
    ' when p.name=''filesystemio_options'' and p.value like ''directIO%'' then ''directIO''' ||
    ' when p.name=''filesystemio_options'' and p.value like ''setall%'' then ''setall'' ' ||
    ' when p.name=''filesystemio_options'' then '' ''' ||
    ' else p.value end,' ||
    ' p.isdefault' ||
    ' from gv$system_parameter p, (select DISTINCT con_id, name pdb from gv$containers where con_id != 2) pdb' ||
    ' where p.con_id = pdb.con_id' ||
    ' and name != ''resource_manager_plan'' ' ||
    ' and inst_id = ' || inst_id_row.inst_id,inst_id_row.instance_name);
  END LOOP;
END collect_cdb_pdb_over_params;


/*
Private procedure
Collect metric=db_asm_disk
*/
procedure collect_db_asm_disk IS
BEGIN
  IF g_version_category = VERSION_10gR1
  OR g_version_category = VERSION_10gR2
  OR g_version_category = VERSION_11gR1
  OR g_version_category = VERSION_11gR2
  OR g_version_category = VERSION_12gR1
  OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    write_metric('db_asm_disk',
    'select inst_id, group_number, disk_number, header_status, path '||
    'from gv$asm_disk where group_number > 0 and header_status != ''MEMBER'' ');
  END IF;
END collect_db_asm_disk;


/*
Private procedure
Collect metric=autotask_client
*/
procedure collect_autotask_client IS
BEGIN
  IF g_version_category = VERSION_11gR1
  OR g_version_category = VERSION_11gR2
  OR g_version_category = VERSION_12gR1
  OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    write_metric('db_autotask_client',
    'select client_name, status from DBA_AUTOTASK_CLIENT where lower(client_name) = ''sql tuning advisor'' ');
  END IF;
END collect_autotask_client;


/*
Private procedure
Collect metric=db_components
*/
procedure collect_db_components IS
BEGIN
  IF g_version_category <> VERSION_817 THEN
    IF g_version_category = VERSION_9iR2
    OR g_version_category = VERSION_9i THEN
      write_metric('db_components',' select '' '' namespace, comp_id, comp_name, version, status, schema from sys.dba_registry');
    ELSE
      write_metric('db_components',' select namespace, comp_id, comp_name, version, status, schema from sys.dba_registry');
    END IF;
  END IF;
END collect_db_components;


/*
Private procedure
Collect metric=db_invobj_cnt
*/
procedure collect_db_invobj_cnt IS
BEGIN
  write_metric('db_invobj_cnt',' select owner, count(*) from sys.dba_objects where status = ''INVALID'' group by owner ');
END collect_db_invobj_cnt;


/*
Private procedure
Collect metric=db_scheduler_jobs
*/
procedure collect_db_scheduler_jobs IS
BEGIN
  IF g_version_category = VERSION_10gR2
  OR g_version_category = VERSION_10gR1 THEN
    write_metric('db_scheduler_jobs',' select OWNER,JOB_NAME,STATE,SCHEDULE_NAME from sys.dba_scheduler_jobs where job_name=''GATHER_STATS_JOB''');
  END IF;
END collect_db_scheduler_jobs;


/*
Private procedure
Collect metric=db_scnInfo
*/
procedure collect_db_scnInfo IS
  l_max_rate      NUMBER := 16*1024;
  l_seconds_1988  NUMBER := 0;
  l_maximum_scn   NUMBER;
  l_base_year     NUMBER := 1988;
  l_db_version    VARCHAR2(10);
  l_patch         NUMBER;

  l_current_scn   NUMBER;
  l_headroom      NUMBER;
  l_growth_24hrs  NUMBER;
  l_scn_calls     NUMBER;
  l_dblink_out    NUMBER;
  l_dblink_in     NUMBER;
  l_max_jump      NUMBER ;
  l_max_jump_time VARCHAR2(32);
  l_created       VARCHAR2(32);
  l_reject_thresh NUMBER;

  c_time_16       NUMBER;
  c_time_32       NUMBER;

  l_end_done      BOOLEAN := FALSE;
  l_sql_text      VARCHAR2(2000);
  l_sql_piece     VARCHAR2(200);
  l_is_gmt        VARCHAR2(10);

BEGIN
  select 16*1024*24*60*60, 32*1024*24*60*60 into c_time_16, c_time_32 from dual;

  SELECT LPAD(version, 10, '0') into l_db_version from v$instance;
  IF (l_db_version = '11.2.0.2.0' OR l_db_version = '11.2.0.3.0') THEN
    l_sql_text :=
      'SELECT count(*) from dba_registry_history ' ||
      'where comments=''CPUJan2012'' OR comments=''CPUApr2012''';
    -- presence of this parameter indicates CPU patch is installed.
    EXECUTE IMMEDIATE l_sql_text INTO l_patch;
    -- if no rows, then patch is not installed on 11.2.0.2 and 11.2.0.3
    IF (l_patch = 0) THEN
      l_max_rate := 32*1024;
      l_base_year := 2009;
      select 4*1024*1024*1024*2575 into l_seconds_1988 from dual;
    END IF;
  END IF;
  -- current_scn, intrinsic change (not rate!)
  IF (l_db_version > '10.0.0.0.0') THEN
    l_sql_text :=
    'SELECT d.current_scn, svalue ' ||
    'FROM v$database d, ' ||
    '(SELECT sum(s.value) svalue from v$sysstat s WHERE s.name in (''calls to kcmgas'', ''redo writes''))';
    EXECUTE IMMEDIATE l_sql_text INTO l_current_scn, l_scn_calls;
  ELSE
    l_sql_text :=
    'select dbms_flashback.get_system_change_number from dual';
    EXECUTE IMMEDIATE l_sql_text INTO l_current_scn;
    l_sql_text :=
    'SELECT sum(s.value) svalue from v$sysstat s WHERE s.name in (''calls to kcmgas'', ''redo writes'')';
    EXECUTE IMMEDIATE l_sql_text INTO l_scn_calls;
  END IF;

  -- this formula comes from kcmbts
  SELECT
    (((((( (to_number(to_char(sysdate,'YYYY'))-l_base_year)* 12  
          +(to_number(to_char(sysdate,'MM'))-1))           * 31  
         + (to_number(to_char(sysdate,'DD'))-1))           * 24  
        +  (to_number(to_char(sysdate,'HH24'))))           * 60  
       +   (to_number(to_char(sysdate,'MI'  ))))           * 60  
      +    (to_number(to_char(sysdate,'SS'  ))))
     * l_max_rate) + l_seconds_1988
    INTO l_maximum_scn FROM dual;

  -- scn_headroom
  IF (l_max_rate = 32768) THEN
    IF (l_current_scn > l_seconds_1988) THEN
      SELECT to_char(((l_maximum_scn - l_current_scn) / c_time_32),'99999D99')
        INTO l_headroom FROM dual;        
    ELSE
      SELECT to_char((((l_maximum_scn - l_seconds_1988) / c_time_32) +
                     ((l_seconds_1988 - l_current_scn) / c_time_16)),'99999D99')
          INTO l_headroom FROM dual; 
    END IF;
  ELSE
    SELECT to_char(((l_maximum_scn - l_current_scn) / c_time_16),'99999D99')
      INTO l_headroom FROM dual;
  END IF;

  -- outgoing DB links
  SELECT count(*) INTO l_dblink_out FROM DBA_DB_LINKS;

  -- incoming DB links
  SELECT count(*) INTO l_dblink_in FROM dba_audit_trail 
    WHERE action_name='LOGON' AND comment_text LIKE '%DBLINK_INFO%' AND timestamp > (sysdate-1) ORDER BY timestamp;

  -- max jump size, average (total) growth rate, max jump timestamp
  IF (l_db_version > '10.0.0.0.0') THEN
    BEGIN
      EXECUTE IMMEDIATE 'select PROPERTY_VALUE from DATABASE_PROPERTIES where PROPERTY_NAME=''Flashback Timestamp TimeZone''' INTO l_is_gmt;
      EXCEPTION
        WHEN OTHERS THEN 
          l_is_gmt := '';
    END; 
    IF (l_is_gmt = 'GMT') THEN
      l_sql_piece := 'WHERE time_dp > sys_extract_utc(systimestamp)-1';
    ELSE
      l_sql_piece := 'WHERE time_dp > sysdate-1';
    END IF;
    l_sql_text := 
    'SELECT scn_per_sec, round(avg_scn_per_sec), to_char(time_stamp, ''YYYY-MM-DD HH24:MI:SS'') ' ||
    'FROM ' ||
      '( SELECT time_stamp, scn_per_sec, avg(scn_per_sec) over() avg_scn_per_sec, max(scn_per_sec) over() max_scn_per_sec ' ||
        'FROM ' ||
          '( SELECT time_dp time_stamp, scn, ' ||
                 'round ((scn - lag(scn,1) over(ORDER BY time_dp))/ ' ||
                        '(60*60*24 * (time_dp - lag(time_dp,1) over(ORDER BY time_dp))), ' ||
                        '0) scn_per_sec ' ||
            'FROM sys.smon_scn_time ' ||
            l_sql_piece ||
          ') ' ||
        'WHERE scn_per_sec IS NOT NULL order by time_stamp desc ' ||
      ') ' || -- remove first entry which will have null because of lag()
    'WHERE scn_per_sec = max_scn_per_sec and rownum = 1';
    EXECUTE IMMEDIATE l_sql_text INTO l_max_jump, l_growth_24hrs, l_max_jump_time;
  END IF;
  -- db creation time
  SELECT to_char(created,'YYYY-MM-DD HH24:MI:SS') INTO l_created FROM v$database;

  -- reject threshold (may not exist, catch that)
  BEGIN
    SELECT value INTO l_reject_thresh FROM v$parameter WHERE name='_external_scn_rejection_threshold_hours';
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_reject_thresh := -1;
  END;

  BEGIN
    put_metric_marker(METRIC_BEGIN_MARKER,'db_scnInfo',null,null);
    UTL_FILE.PUT_LINE( g_config_handle,
                       'em_result=' || l_current_scn ||'|'|| l_headroom ||'|'|| l_growth_24hrs ||'|'|| l_scn_calls ||'|'|| l_dblink_out ||
                       '|'|| l_dblink_in ||'|'|| l_max_jump ||'|'|| l_max_jump_time ||'|'|| l_created ||'|'|| l_reject_thresh );

    put_metric_marker(METRIC_END_MARKER,'db_scnInfo',null,null);
    l_end_done   := TRUE;
    UTL_FILE.FFLUSH(g_config_handle);
  EXCEPTION
    WHEN OTHERS THEN
      IF NOT l_end_done THEN
        put_metric_marker(METRIC_END_MARKER,'db_scnInfo',null,null);
        UTL_FILE.FFLUSH(g_config_handle);
      END IF;
      RAISE;
  END;
END  collect_db_scnInfo;


/*
Private procedure
Collect metric=db_redoLogs
*/
procedure collect_db_redoLogs IS
BEGIN
    write_metric('db_redoLogs',
' SELECT  l.group# group_num, ' ||
/*
Comment this column as it changes frequently 
'          NLS_INITCAP(l.status) status, ' ||
*/
' '''', ' ||
' l.members members, ' ||
' lf.member file_name, ' ||
/*
Comment this column as it changes frequently 
' NLS_INITCAP(l.archived) archived, ' ||
*/
' '''', ' ||
' l.bytes logsize, ' ||
/*
Comment this column as it changes frequently 
' l.sequence# sequence_num, ' ||
*/
' '''', ' ||
/*
Comment this column as it changes frequently 
' l.first_change# first_change_scn, ' ||
*/
' '''', ' ||
' l.thread# as thread_num , lf.type type' ||
' FROM    v$log l, ' ||
'         v$logfile lf ' ||
' WHERE   l.group# = lf.group#'); 
END collect_db_redoLogs;


/*
Private procedure
Collect metric=db_datafiles
*/
procedure collect_db_datafiles IS
  l_status_clause1 VARCHAR2(100);
  l_status_clause2 VARCHAR2(100);
BEGIN
  IF g_version_category = VERSION_9iR2 THEN
    l_status_clause1 := 'vdf.status status, ';
    l_status_clause2 := 'vtf.status status, ';
  ELSIF g_version_category = VERSION_10gR1
     OR g_version_category = VERSION_10gR2 THEN
    l_status_clause1 := 'ddf.online_status status, ';
    l_status_clause2 := 'vtf.status status, ';
  ELSIF g_version_category = VERSION_11gR1
     OR g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1 
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_status_clause1 := 'ddf.online_status status, ';
    l_status_clause2 := 'dtf.status status, ';
  END IF;

  write_metric('db_datafiles',
    'SELECT /*+ ORDERED */ ' ||
    ' REPLACE(REPLACE(ddf.file_name, chr(10), ''''), chr(13), '''') file_name, ' ||
    l_status_clause1 ||
    ' ddf.tablespace_name tablespace_name,'||
    ' '''', ' ||
    ' ddf.autoextensible autoextensible, '||
    ' ddf.increment_by increment_by, ' ||
    ' ddf.maxbytes max_file_size, ' ||
    ' vdf.create_bytes, ' ||
    ' ''NA'' os_storage ' ||
    'FROM v$datafile vdf, ' ||
    'sys.dba_data_files ddf ' ||
    'WHERE  (vdf.file# = ddf.file_id) ' ||
    'UNION ALL ' ||
    'SELECT /*+ ORDERED  */ ' ||
    ' REPLACE(REPLACE(dtf.file_name, chr(10), ''''), chr(13), '''') file_name, '||
    l_status_clause2 ||
    ' dtf.tablespace_name tablespace_name,'||
    ' '''', ' ||
    ' dtf.autoextensible autoextensible, '||
    ' dtf.increment_by increment_by, ' ||
    ' dtf.maxbytes max_file_size, ' ||
    ' vtf.create_bytes, ' ||
    ' ''NA'' os_storage ' ||
    'FROM v$tempfile vtf, ' ||
    ' sys.dba_temp_files dtf ' ||
    'WHERE (dtf.file_id =  vtf.file#)');

END collect_db_datafiles;

/*
Private procedure
Collect metric=cdb_datafiles
*/
procedure collect_cdb_datafiles IS
BEGIN
  write_metric('cdb_datafiles',
  'SELECT /*+ ORDERED NO_PARALLEL(ddf) */ pdb.pdb,' ||
        ' REPLACE(REPLACE(ddf.file_name, chr(10), ''''), chr(13), ''''), ' ||
        ' ddf.online_status,' ||
        ' ddf.tablespace_name,' ||
        ' '''',' ||
        ' ddf.autoextensible,' ||
        ' ddf.increment_by,' ||
        ' ddf.maxbytes,' ||
        ' vdf.create_bytes,' ||
        ' ''NA'' ' ||
  'FROM sys.cdb_data_files ddf, v$datafile vdf, ' ||
  '(select DISTINCT con_id, name pdb from gv$containers where con_id != 2 ) pdb ' ||
  'WHERE (vdf.file# = ddf.file_id) and ddf.con_id = pdb.con_id and vdf.con_id = pdb.con_id ' ||
  'UNION ALL ' ||
  'SELECT /*+ NO_PARALLEL(dtf) */ pdb.pdb,' ||
        ' REPLACE(REPLACE(dtf.file_name, chr(10), ''''), chr(13), ''''),' ||
        ' dtf.status,' ||
        ' dtf.tablespace_name,' ||
        ' '''',' ||
        ' dtf.autoextensible,' ||
        ' dtf.increment_by,' ||
        ' dtf.maxbytes,' ||
        ' vtf.create_bytes,' ||
        ' ''NA'' ' ||
  'FROM sys.cdb_temp_files dtf, v$tempfile vtf, ' ||
  '(select DISTINCT con_id, name pdb from gv$containers where con_id != 2) pdb ' ||
  'WHERE (dtf.file_id = vtf.file#) and dtf.con_id = pdb.con_id and vtf.con_id = pdb.con_id');
END;

/*
Private procedure
Collect metric=db_tablespaces
*/
procedure collect_db_tablespaces IS
  l_sql_db_tablespaces VARCHAR2(4000);
  l_segspace VARCHAR2(100)  := ' dtp.segment_space_management,';
  l_blocksize VARCHAR2(100) := ' dtp.block_size,';
  l_bigfile VARCHAR2(100)   := ' dtp.bigfile ';
BEGIN
  -- build the query with the appropriate subclauses based on DB versions
  IF g_version_category = VERSION_817 THEN
    l_segspace := ' '''', ';
    l_blocksize := ' '''', ';
    l_bigfile := ' '''', ';
  ELSIF g_version_category = VERSION_9iR2
     OR g_version_category = VERSION_9i THEN
    l_segspace := ' dtp.segment_space_management,';
    l_blocksize := ' dtp.block_size,';
    l_bigfile := ' '''', ';
  ELSIF g_version_category = VERSION_10gR2 
   OR g_version_category = VERSION_10gR1 
   OR g_version_category = VERSION_11gR1 
   OR g_version_category = VERSION_11gR2 
   OR g_version_category = VERSION_12gR1
   OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_segspace := ' dtp.segment_space_management,';
    l_blocksize := ' dtp.block_size,';
    l_bigfile := ' dtp.bigfile ';
  END IF;

  l_sql_db_tablespaces := 'SELECT ' ||
  ' dtp.tablespace_name,'  ||
  ' dtp.status,' ||
  ' dtp.contents,' ||
  ' dtp.extent_management,' ||
  ' dtp.allocation_type,' ||
  ' dtp.logging,' ||
  ' '''',' || -- this column in GC metric changes too often
  ' dtp.initial_extent,' ||
  ' dtp.next_extent,' ||
  ' dtp.pct_increase,' ||
  ' dtp.max_extents,' ||
  ' '''',' || -- this column in GC metric changes too often
  ' dtp.min_extents,' ||
  ' dtp.min_extlen,' ||
  l_segspace ||
  l_blocksize ||
  l_bigfile ||
  ' FROM '||
  ' sys.dba_tablespaces dtp';

  -- collect the metric, given the decisions made above
  write_metric('db_tablespaces',l_sql_db_tablespaces);

END collect_db_tablespaces;

/*
Private procedure
Collect metric=cdb_tablespaces
*/
procedure collect_cdb_tablespaces IS
BEGIN
  -- collect the metric
  write_metric('cdb_tablespaces',
    'with pdbview AS' ||
    '(SELECT DISTINCT con_id, name pdb FROM gv$containers where con_id != 2) ' ||
    'SELECT /*+ NO_PARALLEL(dtp) */ pdb.pdb,' ||
    'dtp.tablespace_name,' ||
    'dtp.status,' ||
    'dtp.contents,' ||
    'dtp.extent_management,' ||
    'dtp.allocation_type,' ||
    'dtp.logging,' ||
    ''''',' ||
    'dtp.initial_extent,' ||
    'dtp.next_extent,' ||
    'dtp.pct_increase,' ||
    'dtp.max_extents,' ||
    ''''',' ||
    'dtp.min_extents,' ||
    'dtp.min_extlen,' ||
    'dtp.segment_space_management,' ||
    'dtp.block_size,' ||
    'dtp.bigfile ' ||
    'FROM sys.cdb_tablespaces dtp, pdbview pdb ' ||
    'WHERE NOT (dtp.extent_management LIKE ''LOCAL'' AND ' ||
    'dtp.contents LIKE ''TEMPORARY'') AND ' ||
    'dtp.con_id = pdb.con_id ' ||
    'UNION ALL ' ||
    'SELECT  /*+ NO_PARALLEL(dtp) */ pdb.pdb,' ||
    'dtp.tablespace_name,' ||
    'dtp.status,' ||
    'dtp.contents,' ||
    'dtp.extent_management,' ||
    'dtp.allocation_type,' ||
    'dtp.logging,' ||
    ''''',' ||
    'dtp.initial_extent,' ||
    'dtp.next_extent,' ||
    'dtp.pct_increase,' ||
    'dtp.max_extents,' ||
    ''''',' ||
    'dtp.min_extents,' ||
    'dtp.min_extlen,' ||
    'dtp.segment_space_management,' ||
    'dtp.block_size,' ||
    'dtp.bigfile ' ||
    'FROM sys.cdb_tablespaces dtp, pdbview pdb ' ||
    'WHERE dtp.extent_management LIKE ''LOCAL'' AND ' ||
    'dtp.contents LIKE ''TEMPORARY'' AND ' ||
    'dtp.con_id = pdb.con_id');
END;
/*
Private procedure
Collect metric=db_controlfiles
*/
procedure collect_db_controlfiles IS
BEGIN
  write_metric('db_controlfiles',
    'SELECT cf.name file_name, ' ||
    ' db.controlfile_type status, ' ||
    ' to_char(db.controlfile_created,''YYYY-MM-DD HH24:MI:SS'') creation_date, ' ||
/*
Comment this column as it changes frequently 
    ' db.controlfile_sequence# sequence_num, ' ||
*/
    ' '''', ' ||
/*
Comment this column as it changes frequently 
    ' db.controlfile_change# change_num, ' ||
*/
    ' '''', ' ||
/*
Comment this column as it changes frequently 
    ' to_char(db.controlfile_time,''YYYY-MM-DD HH24:MI:SS'') mod_date ' ||
*/
    ' '''', ' ||
/*
Comment this column as it is unavailable from db
    ' os_storage_entity ' 
*/
    ' ''NA'' ' ||
    ' FROM v$controlfile cf, ' ||
    ' v$database db ' );

END collect_db_controlfiles;


/*
Private procedure
Collect metric=db_rollback_segs
*/
procedure collect_db_rollback_segs IS
BEGIN
  write_metric('db_rollback_segs',
    'SELECT ' ||
    ' drs.segment_name rollname, ' ||
    ' drs.status status, ' ||
    ' drs.tablespace_name tablespace_name, ' ||
    ' rs.extents extents, ' ||
/*
Comment this column as per George
    ' rs.rssize rollsize, ' ||
*/
    ' '''', ' ||
    ' drs.initial_extent initial_size, ' ||
    ' drs.next_extent next_size, ' ||
    ' drs.max_extents maximum_extents, ' ||
    ' drs.min_extents minimum_extents, ' ||
    ' drs.pct_increase pct_increase, ' ||
    ' rs.optsize optsize, ' ||
    ' rs.aveactive aveactive, ' ||
    ' rs.wraps wraps, ' ||
    ' rs.shrinks shrinks, ' ||
    ' rs.aveshrink aveshrink, ' ||
/*
Comment this column as its a volatile data 
    ' rs.hwmsize hwmsize ' ||
*/
    ' '''' ' ||
    ' FROM sys.dba_rollback_segs drs, ' ||
    ' v$rollstat rs ' ||
    ' WHERE drs.segment_id = rs.usn (+) ' ||
    ' and substr(drs.segment_name,1,7) != ''_SYSSMU''');
END collect_db_rollback_segs;


/*
Private procedure
Collect metric=cdb_rollback_segs
*/
procedure collect_cdb_rollback_segs IS
BEGIN
  write_metric('cdb_rollback_segs',
    'SELECT /*+ NO_PARALLEL(drs) */ pdb.pdb pdb_name, '||
    ' drs.segment_name rollname, ' ||
    ' drs.status status, ' ||
    ' drs.tablespace_name tablespace_name, ' ||
    ' rs.extents extents, ' ||
/*
Comment this column as per George
    ' rs.rssize rollsize, ' ||
*/
    ' '''', ' ||
    ' drs.initial_extent initial_size, ' ||
    ' drs.next_extent next_size, ' ||
    ' drs.max_extents maximum_extents, ' ||
    ' drs.min_extents minimum_extents, ' ||
    ' drs.pct_increase pct_increase, ' ||
    ' rs.optsize optsize, ' ||
    ' rs.aveactive aveactive, ' ||
    ' rs.wraps wraps, ' ||
    ' rs.shrinks shrinks, ' ||
    ' rs.aveshrink aveshrink, ' ||
/*
Comment this column as its a volatile data 
    ' rs.hwmsize hwmsize ' ||
*/
    ' '''' ' ||
    ' FROM sys.cdb_rollback_segs drs, (SELECT DISTINCT con_id, name pdb FROM gv$containers where con_id != 2) pdb, ' ||
    ' v$rollstat rs ' ||
    ' WHERE drs.segment_id = rs.usn (+) ' ||
    ' and substr(drs.segment_name,1,7) != ''_SYSSMU'' ' ||
    ' and drs.con_id = pdb.con_id' );
END collect_cdb_rollback_segs;


/*
Private procedure
Collect metric=db_sga
*/
procedure collect_db_sga IS
  CURSOR l_res_cur IS select inst_id,instance_name from gv$instance;
BEGIN
  FOR inst_id_row in l_res_cur LOOP
    write_metric('db_sga',
    ' select sganame,sgasize  ' ||
    ' from ' ||
    ' ((SELECT ''Shared Pool (MB)'' sganame, ' ||
    ' ROUND(NVL(sum(bytes)/1024/1024,0)) sgasize ' ||
    ' FROM gv$sgastat WHERE INST_ID = ' || inst_id_row.inst_id ||
    ' AND pool = ''shared pool'') ' ||
    ' UNION ' ||
    ' (SELECT ''Buffered Cache (MB)'' sganame, ' ||
    ' ROUND(NVL(bytes/1024/1024,0)) sgasize ' ||
    ' FROM gv$sgastat WHERE INST_ID = ' || inst_id_row.inst_id ||
    ' AND ((name = ''db_block_buffers'' AND pool IS NULL ) OR name = ''buffer_cache'')) ' ||
    ' UNION ' ||
    ' (SELECT ''Large Pool (KB)'' "NAME", ' ||
    ' ROUND(NVL(sum(bytes)/1024,0)) "SIZE" ' ||
    ' FROM gv$sgastat WHERE INST_ID = ' || inst_id_row.inst_id ||
    ' AND pool = ''large pool'') ' ||
    ' UNION ' ||
    ' (SELECT ''Java Pool (MB)'' "NAME", ' ||
    ' ROUND(NVL(sum(bytes)/1024/1024,0)) "SIZE" ' ||
    ' FROM gv$sgastat WHERE INST_ID = ' || inst_id_row.inst_id ||
    ' AND pool = ''java pool'') ' ||
    ' UNION ' ||
    ' (SELECT ''Fixed SGA (KB)'' "NAME", ' ||
    ' ROUND(NVL(value/1024,0)) "SIZE" ' ||
    ' FROM gv$sga WHERE INST_ID = ' || inst_id_row.inst_id ||
    ' AND name=''Fixed Size'') ' ||
    ' UNION ' ||
    ' (SELECT ''Variable SGA (MB)'' "NAME", ' ||
    ' ROUND(NVL(value/1024/1024,0)) "SIZE" ' ||
    ' FROM gv$sga WHERE INST_ID = ' || inst_id_row.inst_id ||
    ' AND name=''Variable Size'') ' ||
    ' UNION ' ||
    ' (SELECT ''Redo Buffers (KB)'' "NAME", ' ||
    ' ROUND(NVL(value/1024,0)) "SIZE" ' ||
    ' FROM gv$sga WHERE INST_ID = ' || inst_id_row.inst_id ||
    ' AND name=''Redo Buffers'') ' ||
    ' UNION ' ||
    ' (SELECT ''Total SGA (MB)'' "NAME", ' ||
    ' ROUND(NVL(sum(bytes)/1024/1024,0)) "SIZE" ' ||
    ' FROM gv$sgastat WHERE INST_ID = ' || inst_id_row.inst_id ||
    ') ' ||
    ' UNION ' ||
    ' (SELECT ''Maximum SGA (MB)'' "NAME", ' ||
    ' ROUND(NVL(sum(value)/1024/1024,0)) "SIZE" ' ||
    ' FROM gv$sga WHERE INST_ID = ' || inst_id_row.inst_id ||
    ')) ' ||
    ' ORDER BY sgasize ' , inst_id_row.instance_name);
  END LOOP;
END collect_db_sga;


/*
Private procedure
Collect metric=db_license
*/
procedure collect_db_license IS
BEGIN
    write_metric('db_license',
    'SELECT sessions_max, ' ||
    'sessions_warning, ' ||
/*
Comment this column as per George
'sessions_current , ' ||
*/
    ' '''', ' ||
    ' sessions_highwater, ' ||
    ' users_max ' ||
    ' FROM v$license ');
END collect_db_license;


/*
Private procedure
Collect metric=db_options
*/
procedure collect_db_options IS
  l_data_mining VARCHAR2(500);
BEGIN
  IF g_version_category = VERSION_817
  OR g_version_category = VERSION_9i THEN
    l_data_mining := 'select ''ORACLE_DATA_MINING'' as name, ''FALSE'' as selected ';
  ELSIF g_version_category = VERSION_9iR2
     OR g_version_category = VERSION_10gR1 
     OR g_version_category = VERSION_10gR2 
     OR g_version_category = VERSION_11gR1 
     OR g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_data_mining := ' select ''ORACLE_DATA_MINING'' as name, decode((select status from dba_registry where comp_id=''ODM''), ''VALID'', ''TRUE'', ''FALSE'') as selected ';
  ELSE
    RETURN;
 END IF;

    write_metric('db_options',
    ' select ''INTER_MEDIA'' as name, decode((select username from dba_users where username=''ORDSYS''), ''ORDSYS'', ''TRUE'', ''FALSE'') as selected  ' ||
    ' from dual ' ||
    ' union ' ||
    ' select ''SPATIAL'' as name, decode((select username from dba_users where username=''MDSYS''), ''MDSYS'', ''TRUE'', ''FALSE'') as selected  ' ||
    ' from dual ' ||
    ' union ' ||
    ' select ''OLAP'' as name, decode((select username from dba_users where username=''OLAPSYS''), ''OLAPSYS'', ''TRUE'', ''FALSE'') as selected  ' ||
    ' from dual ' ||
    ' union ' ||
    ' select ''ORACLE_TEXT'' as name, decode((select username from dba_users where username=''CTXSYS''), ''CTXSYS'', ''TRUE'', ''FALSE'') as selected  ' ||
    ' from dual ' ||
    ' union ' ||
    ' select ''ULTRA_SEARCH'' as name, decode((select username from dba_users where username=''WKSYS''), ''WKSYS'', ''TRUE'', ''FALSE'') as selected  ' ||
    ' from dual ' ||
    ' union ' ||
    ' select ''LABEL_SECURITY'' as name, decode((select username from dba_users where username=''LBACSYS''), ''LBACSYS'', ''TRUE'', ''FALSE'') as selected  ' ||
    ' from dual ' ||
    ' union ' ||
    ' select ''SAMPLE_SCHEMA'' as name, decode((select count(*) from dba_users where username IN(''HR'',''PM'',''QS'',''SH'',''OE'')), 0, ''FALSE'', ''TRUE'') as selected  ' ||
    ' from dual ' ||
    ' union ' ||
    ' select ''JSERVER'' as name, decode((select count(*) from sys.obj$ where type#=29), 0, ''FALSE'', ''TRUE'') as selected  ' ||
    ' from dual ' ||
    ' union ' ||
    l_data_mining ||
    ' from dual ' ||
    ' union ' ||
    ' select ''XDB'' as name, decode((select username from dba_users where username=''XDB''), ''XDB'', ''TRUE'', ''FALSE'') as selected  ' ||
    ' from dual ' ||
    ' union ' ||
    ' select ''EM_REPOSITORY'' as name, decode((select username from dba_users where username=''SYSMAN''), ''SYSMAN'', ''TRUE'', ''FALSE'') as selected  ' ||
    ' from dual ');

END collect_db_options;


/*
Private procedure
Collect metric=statspack_config
*/
procedure collect_statspack_config IS
BEGIN
  write_metric('statspack_config',
    'select '||
    ' (select decode(count(*),1,''YES'',''NO'') FROM sys.obj$ o, sys.user$ u '||
    '  WHERE u.name = ''PERFSTAT'' AND o.owner# = u.user# AND o.name = ''STATSPACK'' '||
    '  AND o.type# = 11 AND o.status = 1) is_installed, '|| 
    ' (select nvl(INTERVAL,'''') from dba_jobs '||
    '  where what like ''statspack.snap%'' and SCHEMA_USER=''PERFSTAT'' and rownum = 1) freq from dual');
END collect_statspack_config;


/*
Private procedure
Collect metric=db_users
*/
procedure collect_db_users IS
BEGIN
  write_metric('db_users',
  'select USERNAME, USER_ID, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, '||
  'to_char(CREATED,''YYYY-MM-DD HH24:MI:SS'') creation_time, PROFILE,'||
  'to_char(EXPIRY_DATE,''YYYY-MM-DD HH24:MI:SS'') expire_time from dba_users');
END collect_db_users;


/*
Private procedure
Collect metric=db_users
*/
procedure collect_cdb_users IS
BEGIN
  write_metric('cdb_users',
  'WITH pdbs AS (SELECT DISTINCT con_id, name pdb FROM gv$containers where con_id != 2) '||
  'SELECT /*+ NO_PARALLEL(u) */ pdb, '||
  ' USERNAME, USER_ID, DEFAULT_TABLESPACE, TEMPORARY_TABLESPACE, '||
  ' to_char(CREATED,''YYYY-MM-DD HH24:MI:SS'') ,' ||
  ' PROFILE, ' ||
  ' to_char(EXPIRY_DATE,''YYYY-MM-DD HH24:MI:SS'') ' ||
  ' FROM cdb_users u, pdbs p '||
  ' WHERE p.con_id = u.con_id');
END collect_cdb_users;


/*
Private procedure
Collect metric=backup_config
*/
/*
procedure collect_backup_config IS
BEGIN
  write_metric('backup_config',
    'select DEVICE_TYPE, ''DATAFILE'' from v$backup_datafile d, V$BACKUP_PIECE p '||
    'where d.SET_COUNT=p.SET_COUNT and d.SET_STAMP=p.SET_STAMP and p.STATUS =''A'' '||
    'and d.FILE# != 0 '||
    'union all '||
    'select p.DEVICE_TYPE,''REDOLOG'' from V$BACKUP_REDOLOG r, V$BACKUP_PIECE p '||
    'where r.SET_COUNT=p.SET_COUNT and r.SET_STAMP=p.SET_STAMP and p.STATUS =''A''');
END collect_backup_config;
*/


/*
Private procedure
Collect metric=ha_info
*/
procedure collect_ha_info IS
BEGIN
  IF g_version_category = VERSION_817 OR 
     g_version_category = VERSION_9i THEN
        write_metric('ha_info',
        'SELECT dbid, log_mode FROM v$database');
  END IF;

  IF g_version_category = VERSION_9iR2 THEN 
        write_metric('ha_info',
        'SELECT dbid, log_mode, force_logging, database_role FROM v$database');
  END IF;

  IF g_version_category = VERSION_10gR1 
     OR g_version_category = VERSION_10gR2 
     OR g_version_category = VERSION_11gR1 
     OR g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
        write_metric('ha_info',
    'SELECT  dbid, log_mode, force_logging, database_role, flashback_on, supplemental_log_data_min FROM v$database');
  END IF;
END collect_ha_info;


/*
Private procedure
Collect metric=ha_rman_config
*/
procedure collect_ha_rman_config IS
BEGIN
  IF g_version_category = VERSION_9i
     OR g_version_category = VERSION_9iR2
     OR g_version_category = VERSION_10gR1 
     OR g_version_category = VERSION_10gR2 
     OR g_version_category = VERSION_11gR1 
     OR g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    write_metric('ha_rman_config',
                 'select ''CONTROLFILE AUTOBACKUP'',nvl((select value from v$rman_configuration where name=''CONTROLFILE AUTOBACKUP''),'''') from dual ' ||
                 'union ' ||
                 'select name, value from v$rman_configuration where name=''CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE'' and value like ''DISK%'' ' );
 END IF;
END collect_ha_rman_config;

/*
Private procedure
Collect metric=db_dbNInstanceInfo
*/
procedure collect_db_dbNInstanceInfo IS

  CURSOR l_res_cur IS select inst_id,instance_name from gv$instance;

  l_word_length         NUMBER;
  l_is_64bit            VARCHAR2(1);
  l_banner_bitrelstr VARCHAR2(4000);
  l_banner_bitrelstr_clause VARCHAR2(4000);
  l_banner_split_clause VARCHAR2(4000) ;
  l_supplemental_log  VARCHAR2(100);
  l_dbproperties_select   VARCHAR2(100);
  l_dbproperties_from   VARCHAR2(100);
  l_dbproperties_where   VARCHAR2(100);
  l_dv_status VARCHAR2(1000);

BEGIN

  -- l_supplemental_log, dbproperties strings
  IF  g_version_category = VERSION_817 OR g_version_category =  VERSION_9i THEN
    l_supplemental_log :=', null as SUPPLEMENTAL_LOG  ';
    l_dbproperties_select := ' ''SYSTEM'' default_temp_tablespace, ';
    l_dbproperties_from := '';
    l_dbproperties_where := '';
  ELSIF  g_version_category = VERSION_9iR2
      OR g_version_category = VERSION_10gR1
      OR g_version_category = VERSION_10gR2
      OR g_version_category = VERSION_11gR1
      OR g_version_category = VERSION_11gR2
      OR g_version_category = VERSION_12gR1
      OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_supplemental_log :=  ',a.supplemental_log_data_min  as SUPPLEMENTAL_LOG ';
    l_dbproperties_select := ' p.property_value default_temp_tablespace, ';
    l_dbproperties_from := ', database_properties p';
    l_dbproperties_where := '   AND p.property_name = ''DEFAULT_TEMP_TABLESPACE'' ';
  END IF;

  IF g_version_category =  VERSION_817 THEN
    l_dv_status := ' , NULL as dv_status_code ';
  ELSIF  g_version_category = VERSION_9i
      OR g_version_category = VERSION_9iR2
      OR g_version_category = VERSION_10gR1
      OR g_version_category = VERSION_10gR2
      OR g_version_category = VERSION_11gR1
      OR g_version_category = VERSION_11gR2
      OR g_version_category = VERSION_12gR1
      OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_dv_status := ' , case when (select count(*) from dba_users where username =''DVSYS'' and user_id = 1279990)  > 0 ' ||
                   ' then case when (select value from v$option where parameter =''Oracle Database Vault'') =''TRUE'' ' ||
                   '  then 1 ' || -- Enabled
                   '  else 0 ' || --Disabled
                   ' end ' ||
                   ' when (select count(*) from dba_users where username =''DVSYS'' and user_id = 1279990) = 0 ' ||
                   ' then case when (select value from v$option where parameter =''Oracle Database Vault'') = ''TRUE'' ' ||
                   '  then -1 ' || -- Not Configured
                   '  else -2 ' || -- Not Installed
                   ' end ' ||
                   'end ' ||
                   ' dv_status_code ';
  END IF;

  -- the word length denotes 32 or 64-bit
  select length(addr)*4 into l_word_length from v$process where rownum=1;
  IF l_word_length = 64 THEN
      l_is_64bit := 'Y';
  ELSE
      l_is_64bit := 'N';
  END IF;

  -- The portion after the - in the banner is given by
  -- substr(banner, instr(banner, '-') + 2)
  l_banner_bitrelstr := 'substr(banner, instr(banner, ''-'') + 2)';
  l_banner_bitrelstr_clause :=
  ' , ''' || l_is_64bit || ''' , ' ||
  ' substr(' || l_banner_bitrelstr || ', instr(' || l_banner_bitrelstr || ', '' '') + 1) ';
  IF g_version_category = VERSION_817 THEN
      l_banner_split_clause := 
    ' , substr(banner,instr(banner,''Oracle8i''),8) , ' || 
    ' nvl(trim(substr(banner,instr(banner,''Oracle8i'') + 8,instr(banner,'' Release'')  ' || 
    ' - instr(banner,''Oracle8i'')  - 8 )),decode(instr(banner,''Personal''),0,'''',''Personal'')) , ' ;
  ELSIF g_version_category = VERSION_9i 
        OR g_version_category = VERSION_9iR2 THEN
      l_banner_split_clause := 
    ' , substr(banner,instr(banner,''Oracle9i''),8) , ' || 
    ' nvl(trim(substr(banner,instr(banner,''Oracle9i'') + 8,instr(banner,'' Release'')  ' || 
    ' - instr(banner,''Oracle9i'')  - 8 )),decode(instr(banner,''Personal''),0,'''',''Personal'')) , ';
  ELSIF g_version_category = VERSION_10gR1 
     OR g_version_category = VERSION_10gR2 
     OR g_version_category = VERSION_11gR1 
     OR g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1 THEN
    l_banner_split_clause :=
      ' , substr(banner,instr(banner,''Oracle Database ''),19), ' ||
      'nvl(trim(substr(banner,instr(banner,''Oracle Database '')+19,instr(banner,'' Release'')' ||
      ' - instr(banner,''Oracle Database '')-19 )), decode(instr(banner,''Personal''),0,'''',''Personal'')), ' ;
  END IF;

  FOR inst_id_row in l_res_cur LOOP
    write_metric('db_dbNInstanceInfo',
                 'SELECT '||
                 ' a.name database_name, ' ||
                 ' e.global_name global_name, ' ||
                 ' b.banner banner, ' ||
                 ' c.host_name host_name, ' ||
                 ' c.instance_name instance_name, ' ||
                 ' to_char(c.startup_time,''YYYY-MM-DD HH24:MI:SS'') startup_time, ' ||
                 ' decode(c.logins,''RESTRICTED'',''YES'',''NO'') logins, ' ||
                 ' a.log_mode log_mode, ' ||
                 ' decode(a.open_mode,''READ ONLY'',''YES'',''NO'') open_mode, ' ||
                 ' nlsp1.value characterset, ' ||
                 ' nlsp2.value national_characterset, ' ||
                 l_dbproperties_select || 
                 ' to_char(a.created,''YYYY-MM-DD HH24:MI:SS'') created ' ||
                 l_banner_split_clause ||
                 ' c.version' ||
                 l_banner_bitrelstr_clause ||
                 l_supplemental_log ||
                 l_dv_status ||
                 ' FROM  gv$database a, ' ||
                       ' gv$version b, ' ||
                       ' gv$instance c, ' ||
                       ' global_name e,' ||
                       ' gv$nls_parameters nlsp1 , ' ||
                       ' gv$nls_parameters nlsp2 ' ||
                 l_dbproperties_from ||
                 ' WHERE b.banner LIKE ''%Oracle%''  ' ||
                 ' AND nlsp1.parameter = ''NLS_CHARACTERSET'' ' ||
                 ' AND nlsp2.parameter = ''NLS_NCHAR_CHARACTERSET'' ' ||
                 l_dbproperties_where || 
                 ' AND a.INST_ID = ' || inst_id_row.inst_id ||
                 ' AND b.INST_ID = ' || inst_id_row.inst_id ||
                 ' AND c.INST_ID = ' || inst_id_row.inst_id ||
                 ' AND nlsp1.INST_ID = ' || inst_id_row.inst_id ||
                 ' AND nlsp2.INST_ID = ' || inst_id_row.inst_id
                 ,inst_id_row.instance_name);
  END LOOP;

END collect_db_dbNInstanceInfo;

/*
Private procedure
Collect metric=cdb_dbNInstanceInfo
*/
procedure collect_cdb_dbNInstanceInfo IS
  CURSOR l_res_cur IS select inst_id,instance_name from gv$instance;
BEGIN
  FOR inst_id_row in l_res_cur LOOP
    write_metric('cdb_dbNInstanceInfo',
    'with pdbview AS (SELECT DISTINCT con_id, name pdb FROM gv$containers where con_id != 2) ' ||
    'SELECT /*+ NO_PARALLEL(e) NO_PARALLEL(p) NO_PARALLEL(u) */ pdb.pdb, ' ||
           'a.name, ' ||
           'e.property_value, ' ||
           'b.banner, ' ||
           'c.host_name, ' ||
           'c.instance_name, ' ||
           'to_char(c.startup_time,''YYYY-MM-DD HH24:MI:SS''), ' ||
           'decode(c.logins,''RESTRICTED'',''YES'',''NO''), ' ||
           'a.log_mode, ' ||
           'case when pdb.con_id=0 then ' ||
             'decode(a.open_mode,''READ ONLY'',''YES'',''NO'') ' ||
           'else ' ||
             'decode(vpb.OPEN_MODE,''READ ONLY'',''YES'',''NO'') ' ||
           'end, ' ||
           'nlsp1.value, ' ||
           'nlsp2.value, ' ||
           'p.property_value, ' ||
           'to_char(a.created,''YYYY-MM-DD HH24:MI:SS''), ' ||
           'substr(banner,instr(banner,''Oracle Database ''),19), ' ||
           'nvl(trim(substr(banner,instr(banner,''Oracle Database '')+19,instr(banner,'' Release'') - instr(banner,''Oracle Database  '') - 19)),decode(instr(banner,''Personal''),0,'''',''Personal'')), ' ||
           'c.version dbversion, ' ||
           'DECODE(addr.word_len, 64, ''Y'', ''N''), ' ||
           'substr(substr(banner, instr(banner, ''-'') + 2), instr(substr(banner, instr(banner, ''-'') + 2),'' '')+1), ' ||
           'a.supplemental_log_data_min, ' ||
           'case when (select count(*) from cdb_users u where u.username =''DVSYS'' and u.user_id = 1279990 and u.con_id = pdb.con_id) > 0 then  ' ||
             'case when (select value from v$option o where o.parameter =''Oracle Database Vault'' and (o.con_id = pdb.con_id or o.con_id = 0)) = ''TRUE'' ' ||
               'then 1 ' || -- Enabled
               'else 0 ' || --Disabled 
             'end ' ||
           'when (select count(*) from cdb_users u where u.username =''DVSYS'' and u.user_id = 1279990 and u.con_id = pdb.con_id) = 0 then  ' ||
             'case when (select value from v$option o where parameter =''Oracle Database Vault''  and (o.con_id = pdb.con_id or o.con_id = 0)) = ''TRUE'' ' ||
               'then -1 ' || -- Not Configured
               'else -2 ' || -- Not Installed
             'end ' ||
           'end ' ||
    'FROM gv$database a, ' ||
         'gv$version b, ' ||
         'gv$instance c, ' ||
         'CDB_PROPERTIES e, ' ||
         'gv$nls_parameters nlsp1, ' ||
         'gv$nls_parameters nlsp2, ' ||
         'CDB_PROPERTIES p, ' ||
         '(select length(addr)*4 word_len from gv$process where rownum=1) addr, ' ||
         'pdbview pdb, ' ||
         'gv$pdbs vpb ' ||
    'WHERE b.banner LIKE ''%Oracle%''  ' ||
    'AND   nlsp1.parameter = ''NLS_CHARACTERSET'' ' ||
    'AND   nlsp2.parameter = ''NLS_NCHAR_CHARACTERSET'' ' ||
    'AND   e.property_name = ''GLOBAL_DB_NAME'' ' ||
    'AND   p.property_name = ''DEFAULT_TEMP_TABLESPACE'' ' ||
    'AND   (a.con_id = pdb.con_id OR a.con_id = 0) ' ||
    'AND   (b.con_id = pdb.con_id OR b.con_id = 0) ' ||
    'AND   (c.con_id = pdb.con_id OR c.con_id = 0) ' ||
    'AND   (nlsp1.con_id = pdb.con_id OR nlsp1.con_id = 0) ' ||
    'AND   (nlsp2.con_id = pdb.con_id OR nlsp2.con_id = 0) ' ||
    'AND   e.con_id = pdb.con_id ' ||
    'AND   p.con_id = pdb.con_id ' ||
    'AND   vpb.con_id(+) = pdb.con_id' ||
    ' AND  a.INST_ID = ' || inst_id_row.inst_id ||
    ' AND  b.INST_ID = ' || inst_id_row.inst_id ||
    ' AND  c.INST_ID = ' || inst_id_row.inst_id ||
    ' AND  nlsp1.INST_ID = ' || inst_id_row.inst_id ||
    ' AND  nlsp2.INST_ID = ' || inst_id_row.inst_id ||
    ' AND  vpb.INST_ID = ' || inst_id_row.inst_id
    ,inst_id_row.instance_name);

  END LOOP;
END;


-- write the record for an option, if its found to be installed
-- 'OCM ' is appended to the Option Name, so that to distinguish it from other
-- mechanism of collections like db feature usage statistics.
procedure write_option_record(p_name VARCHAR2,p_install_sql VARCHAR2,
         p_usage_sql VARCHAR2,
         p_info_sql VARCHAR2 DEFAULT null,p_version_sql VARCHAR2 DEFAULT null)
IS
 l_isInstalled INTEGER := 0;
 l_isUsed VARCHAR2(5) :='FALSE';
 TYPE cur_type IS REF CURSOR;
 l_featureInfoCur cur_type; 
 l_feature_row VARCHAR2(4000) := NULL;
 l_feature_info VARCHAR2(4000) := NULL;
 l_size INTEGER := 4000;
 l_row_separator VARCHAR2(1) := ';';
 l_option_version v$instance.version%TYPE := NULL;
BEGIN
  --check if installed
  IF p_install_sql is NOT NULL THEN
    BEGIN
     execute immediate 'select 1 from dual where exists (' || p_install_sql || ')' into l_isInstalled;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      null;
      WHEN OTHERS THEN
       -- error out exception that is not
       -- 00942: table or view does not exist
       -- 00904: invalid identifier
       -- 01031: insufficient privileges
       IF ( sqlcode != -942 AND sqlcode != -904
            AND sqlcode != -1031) THEN 
           write_error(p_name || ' install_sql=[' || 
            p_install_sql ||'] SQLERRM: ' || SQLERRM 
                     || ' SQLCODE: ' || SQLCODE);
       END IF;
       
       -- if insufficient priv, set the used to unknown
       -- and place the error in the feature info
       IF ( sqlcode = -1031) THEN 
         l_isUsed := 'UNK';
         l_feature_info := 'i:' || SQLCODE;
       END IF;
    END;
  END IF;

  --check if used
  BEGIN
    execute immediate 'select ''TRUE'' from dual where exists (' || p_usage_sql || ')' into l_isUsed;
  EXCEPTION 
     WHEN NO_DATA_FOUND THEN
       null;
    WHEN OTHERS THEN
        -- error out exception that is not
        -- 00942: table or view does not exist
        -- 00904: invalid identifier
        -- 01031: insufficient privileges
       IF ( sqlcode != -942 AND sqlcode != -904
            AND sqlcode != -1031) THEN 
         write_error(p_name || ' usage_sql=[' || 
         p_usage_sql ||'] SQLERRM: ' || SQLERRM 
         || ' SQLCODE: ' || SQLCODE);
       END IF;

       -- if insufficient priv, set the used to unknown
       -- and place the error in the feature info
       IF ( sqlcode = -1031) THEN 
         l_isUsed := 'UNK';
         l_feature_info := 'u:'||SQLCODE;
       END IF;
  END;

  --if the option is used it is installed too by default.
  IF l_isUsed = 'TRUE' then
    l_isInstalled := 1; 
  END IF;

  -- the option is being used and the sql to get its 
  -- information is not null
  IF l_isUsed = 'TRUE' AND p_info_sql IS NOT NULL THEN
  -- feature is used, get feature details
   l_feature_info :='';
   BEGIN
     OPEN l_featureInfoCur FOR p_info_sql;
   EXCEPTION
    WHEN NO_DATA_FOUND THEN
      null;
    WHEN OTHERS THEN
       -- Capture any exception in info sql 
       -- error out exception that is not
       -- 00942: table or view does not exist
       -- 00904: invalid identifier
       -- 01031: insufficient privileges
       IF ( sqlcode != -942 AND sqlcode != -904
            AND sqlcode != -1031) THEN 
           write_error(p_name || ' feature_info_sql=[' || 
           p_info_sql ||'] SQLERRM: ' || SQLERRM 
           || ' SQLCODE: ' || SQLCODE);
       END IF;

       -- if insufficient priv set the used to unknown
       -- and place the error in the feature info
       IF ( sqlcode = -1031) THEN 
         l_feature_info := 'fi:' ||SQLCODE;
       END IF;
   END;

   BEGIN  
     LOOP
        FETCH l_featureInfoCur INTO l_feature_row;
        EXIT WHEN l_featureInfoCur%NOTFOUND;
        l_feature_info := l_feature_info || l_feature_row 
                                         || l_row_separator ;
        l_feature_row := NULL;
     END LOOP; 
   EXCEPTION
   WHEN OTHERS THEN
      IF l_feature_row IS NOT NULL THEN
        -- save the data 3 chars less than the limit
        l_feature_info := substr(l_feature_info || l_feature_row || l_row_separator ,0,l_size - 3);
        -- save the trailing elipses to indicate that more data was present
        l_feature_info := l_feature_info || '...';
      END IF;
   END;
  END IF;
  
  -- write a record for this option, if its installed or there
  -- is an entry in the option feature
  IF l_isInstalled = 1 OR l_feature_info IS NOT NULL THEN
    -- get the option version if a version sql is present
    IF p_version_sql is NOT NULL THEN
      BEGIN
        execute immediate  p_version_sql into l_option_version;
      EXCEPTION
        WHEN OTHERS THEN
         l_option_version := g_db_version;
      END;
    ELSE
      l_option_version := g_db_version;
    END IF;

    -- replace '|' char in feature into with '#'
    write_results(
      'select ' ||
      '''' || g_dbID || ''', ' || -- DBID
      '''' ||  substr('OCM ' || p_name,0,64) || ''',' || -- NAME
      '''' || l_option_version || ''',' || -- Version
      'decode(''' || l_isUsed || ''',''TRUE'',''1'',''''),' || -- Detected Usages
      '1,' || -- Total Samples
      '''' || l_isUsed || ''' ,' || -- Currently Used
      ''''',' || -- First Usage Date
      ''''',' || -- Last Usage Date
      ''''',' || -- Aux Count
      ''''',' || -- Last Sample Date
      ''''',' || -- Last Sample Period
      '''' || replace(l_feature_info,'|','#') || '''' || -- Feature Info
      ' from dual');
  END IF;

EXCEPTION 
WHEN OTHERS THEN
 --capture any error
 write_error(p_name || ' SQLERRM: ' || SQLERRM 
                     || ' SQLCODE: ' || SQLCODE);
END write_option_record;

/*
--- TEMPLATE FUNCTION FOR DB Option collection 
Write <OPTION_NAME> option 
Provide three sqls:
1. check for install
2. check for usage
3. get option information for validation
*/
/*
PROCEDURE write_<OPTION_NAME>
IS
 l_isInstalledSQL VARCHAR2(500) := 
        '<OPTION INSTALL CHECK SQL: 
              returns a row if installed, otherwise none>';
 l_isUsedSQL VARCHAR2(500) :=
        '<OPTION USAGED CHECK SQL: 
              returns a row if installed, otherwise none>';
  l_infoSQL VARCHAR2(500) :=
        '<OPTION INFO SQL:
              may return multiple rows of one or more columns.
              Data from this is collapsed into a line
              with a row separator as validation data for this option
              >';
BEGIN
   write_option_record(<OPTION_NAME>,l_isInstalledSQL,l_isUsedSQL,l_infoSQL);
end write_<OPTION_NAME>;
*/


/*
Write RAC option 
Provide three sqls:
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_rac
IS
 l_isInstalledSQL VARCHAR2(500) := 
    'SELECT 1 from v$option where parameter=''Real Application Clusters'' and value =''TRUE'' and rownum = 1';
 l_isUsedSQL VARCHAR2(500) :=
    'select 1  from (select count(*) CNT from gv$instance where rownum <=2) where CNT >= 2';
  l_infoSQL VARCHAR2(500) := NULL;
BEGIN
   write_option_record('RAC',l_isInstalledSQL,l_isUsedSQL,l_infoSQL);
end write_rac;


/*
Write Label Security option 
Provide three sqls:
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_lsec
IS
 l_isInstalledSQL VARCHAR2(500) := 
    'SELECT 1 from v$option where parameter=''Oracle Label Security'' and value =''TRUE'' and rownum = 1';
 l_isUsedSQL VARCHAR2(500) :=
    'select 1  from lbacsys.lbac$polt where owner <> ''SA_DEMO'' and rownum = 1';
  l_infoSQL VARCHAR2(500) := NULL;
BEGIN
   write_option_record('Label Security',l_isInstalledSQL,l_isUsedSQL,l_infoSQL);
end write_lsec;


/*
Write Data Mining option 
Provide three sqls:
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_data_mining
IS
 l_isInstalledSQL VARCHAR2(500) := 
    'SELECT 1 from v$option where parameter like ''%Data Mining'' and value =''TRUE'' and rownum = 1';
 l_isUsedSQL VARCHAR2(500) :=
    'select 1  from odm.odm_mining_model where rownum = 1';
  l_infoSQL VARCHAR2(500) := NULL;
BEGIN
   write_option_record('ORACLE DATA MINING',l_isInstalledSQL,l_isUsedSQL,l_infoSQL);
end write_data_mining;


/*
Write Data Vault
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_data_vault
IS
 l_isInstalledSQL VARCHAR2(500) := 
    'SELECT 1 from (Select count(*) CNT from dba_users where username in (''DVSYS'',''DVF'') ) where CNT = 2';
  l_isUsedSQL VARCHAR2(500) :=
    'select 1 from dba_users where username = ''DVSYS'' and user_id = 1279990';
  l_infoSQL VARCHAR2(500) := NULL;
BEGIN
   write_option_record('Database Vault',l_isInstalledSQL,l_isUsedSQL,l_infoSQL);
end write_data_vault;


/*
Write Audit Vault
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_audit_vault
IS
 l_isInstalledSQL VARCHAR2(500) := NULL;
 l_isUsedSQL VARCHAR2(500) := 
    'SELECT 1 from dba_users where username = ''AVSYS'' and rownum = 1';
 l_infoSQL VARCHAR2(500) := NULL;
BEGIN
   write_option_record('Audit Vault',l_isInstalledSQL,l_isUsedSQL,l_infoSQL);
end write_audit_vault;


/*
Write Content Database
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_content_db
IS
 l_isInstalledSQL VARCHAR2(500) := 
    'SELECT 1 from dba_users where username = ''CONTENT'' and rownum = 1';
 l_isUsedSQL VARCHAR2(500) :=
    -- odm_document contains more than 9004 rows
    'select 1 from (select count(*) CNT from content.odm_document where rownum <= 9005 ) where CNT > 9004';
 l_infoSQL VARCHAR2(500) := NULL;
BEGIN
   write_option_record('Content Database',l_isInstalledSQL,l_isUsedSQL,l_infoSQL);
end write_content_db;


/*
Write Records Database
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_records_db
IS
 l_isInstalledSQL VARCHAR2(500) := 
    'SELECT 1 from dba_users where username = ''CONTENT'' and rownum = 1';
 l_isUsedSQL VARCHAR2(500) :=
    'select 1 from content.odm_record where rownum = 1';
 l_infoSQL VARCHAR2(500) := NULL;
BEGIN
   write_option_record('Records Database',l_isInstalledSQL,l_isUsedSQL,l_infoSQL);
end write_records_db;


/*
Write OEM
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_oem
IS
  cursor1 integer;
  v_count number(1) := 0;
  v_schema dba_tables.owner%TYPE;
  v_version varchar2(10);
  v_component varchar2(20);
  l_rows_processed integer;
  CURSOR schema_array IS
     SELECT '"' || owner || '"' 
     FROM dba_tables WHERE table_name = 'SMP_REP_VERSION';

  CURSOR schema_array_v2 IS
     SELECT owner 
     FROM dba_tables WHERE table_name = 'SMP_VDS_REPOS_VERSION';
BEGIN
   BEGIN
      SELECT COUNT(*)
      INTO v_count FROM ( SELECT DISTINCT program FROM
        v$session WHERE
        upper(program) LIKE '%XPNI.EXE%'
        OR upper(program) LIKE '%VMS.EXE%'
        OR upper(program) LIKE '%EPC.EXE%'
        OR upper(program) LIKE '%TDVAPP.EXE%'
        OR upper(program) LIKE 'VDOSSHELL%'
        OR upper(program) LIKE '%VMQ%'
        OR upper(program) LIKE '%VTUSHELL%'
        OR upper(program) LIKE '%JAVAVMQ%'
        OR upper(program) LIKE '%XPAUTUNE%'
        OR upper(program) LIKE '%XPCOIN%'
        OR upper(program) LIKE '%XPKSH%'
        OR upper(program) LIKE '%XPUI%');
   EXCEPTION
    WHEN OTHERS THEN
    null;
   END;

   IF v_count = 0 THEN
   BEGIN

     OPEN schema_array;
     OPEN schema_array_v2;

     cursor1:=dbms_sql.open_cursor;

     LOOP -- this loop steps through each valid schema.
       FETCH schema_array INTO v_schema;
       EXIT WHEN schema_array%notfound;
       dbms_sql.parse(cursor1,'select c_current_version, c_component from '||v_schema||'.smp_rep_version', dbms_sql.native);
       dbms_sql.define_column(cursor1, 1, v_version, 10);
       dbms_sql.define_column(cursor1, 2, v_component, 20);

       l_rows_processed:=dbms_sql.execute ( cursor1 );

       LOOP -- to step through cursor1 to find console version.
         if dbms_sql.fetch_rows(cursor1) >0 then
           dbms_sql.column_value (cursor1, 1, v_version);
           dbms_sql.column_value (cursor1, 2, v_component);
           if v_component = 'CONSOLE' then
            --Found a schema that has a repository version 
             v_count := v_count + 1;
             exit;
           end if;
         else
            --Did not find any row 
           exit;
         end if;
       END LOOP;
     END LOOP;

     LOOP -- this loop steps through each valid V2 schema.
       FETCH schema_array_v2 INTO v_schema;
       EXIT WHEN schema_array_v2%notfound;

       v_count := v_count + 1;
       --( 'Schema '||rpad(v_schema,15)|| ' has a repository version 2.x' );
     END LOOP;

     dbms_sql.close_cursor (cursor1);
     close schema_array;
     close schema_array_v2;
   EXCEPTION 
     WHEN OTHERS THEN
       null;
   END;
   END IF;

   IF v_count > 0 THEN
     write_option_record('OEM 9i',NULL,'select 1 from dual');
    END IF;
end write_oem;


/*
Write Spatial
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_spatial
IS
 l_isInstalledSQL VARCHAR2(500) := 
    'select 1 from dual where sdo_version IS NOT NULL';
 l_isUsedSQL VARCHAR2(500) :=
    'select 1 from (select count(*) CNT from ALL_SDO_GEOM_METADATA where owner <> ''MDSYS'' and rownum =1) where CNT >0';
 l_infoSQL VARCHAR2(500) := 
    'select count(*) from ALL_SDO_GEOM_METADATA where owner <> ''MDSYS''';
 l_versionSQL VARCHAR2(50) := 'select sdo_version from dual';
BEGIN
   write_option_record('Spatial',l_isInstalledSQL,l_isUsedSQL,l_infoSQL,l_versionSQL);
end write_spatial;


/*
Write Partitioning
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_partitioning
IS
 l_isInstalledSQL VARCHAR2(500) := 
    'SELECT 1 from v$option where parameter = ''Partitioning'' and value =''TRUE'' and rownum = 1';
 l_isUsedSQL VARCHAR2(4000) :=
  'select 1 from (select sum(tot) CNT from
 ( select count(*) tot 
   from
   ( select owner, table_name
     from dba_tables
     where partitioned=''YES''
     -- list of schemas to be excluded
     and owner not in (''SYS'',''SYSTEM'',''SH'',''MDSYS'')
     minus
     select change_table_schema, change_table_name
     from change_tables )
   union all
   select count(*) tot
   from dba_indexes di
   where partitioned=''YES''
   and owner not in (''SYS'',''SYSTEM'',''SH'',''MDSYS'')
   and not exists
   ( select change_table_schema, change_table_name 
     from change_tables ct
     where di.table_owner = ct.change_table_schema 
     and di.table_name = ct.change_table_name))) where CNT > 0';

 l_infoSQL VARCHAR2(5000) := 
 ' select num||'':''||idx_or_tab||'':''||user_id||'':''||ptype||'':''||subptype||'':''|| 
    pcnt||'':''||subpcnt||'':''||
    pcols||'':''||subpcols||'':''||idx_flags||'':''||
    idx_type||'':''||idx_uk||''|'' my_string
   from (select * from
          (select /*+ full(o) */ dense_rank() over 
                  (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM,
                  decode(o.type#,1,''I'',2,''T'',null)  IDX_OR_TAB, 
                  u.user# USER_ID,
                  decode(p.parttype, 1, ''RANGE'', 2, ''HASH'', 3, 
                  ''SYSTEM'', 4, ''LIST'', ''UNKNOWN'') PTYPE, 
                  decode(mod(p.spare2, 256), 0, null, 2, ''HASH'', 3,
                  ''SYSTEM'', 4, ''LIST'', ''UNKNOWN'') SUBPTYPE,
                  p.partcnt PCNT, 
                  mod(trunc(p.spare2/65536), 65536) SUBPCNT,
                  p.partkeycols PCOLS, 
                  mod(trunc(p.spare2/256), 256) SUBPCOLS,
                  decode(p.flags, 0, null, decode(mod(p.flags,3),0,''LP'',1,''L'',2,''GP'', null)) IDX_FLAGS, 
                  decode(i.type#, 1, ''NORMAL''|| decode(bitand(i.property, 4), 0, '''', 4, ''/REV''),
                  2, ''BITMAP'', 3, ''CLUSTER'', 4, ''IOT - TOP'',
                  5, ''IOT - NESTED'', 6, ''SECONDARY'', 7, ''ANSI'', 8, ''LOB'',
                  9, ''DOMAIN'') IDX_TYPE,
                  decode(i.property, null,null,
                    decode(bitand(i.property, 1), 0, ''NONUNIQUE'', 1, ''UNIQUE'', ''UNDEFINED'')) IDX_UK
                  from sys.partobj$ p, sys.obj$ o, sys.user$ u, sys.ind$ i
                  where o.obj# = i.obj#(+)
                  and   o.owner# = u.user# 
                  and   p.obj# = o.obj# 
                  and   u.name not in (''SYS'',''SYSTEM'',''SH'',''MDSYS'')
                  -- fix bug 3074607 - filter on obj$
                  and o.type# in (1,2,19,20,25,34,35)
                  -- exclude change tables
                  and o.obj# not in ( select obj# from sys.cdc_change_tables$)
                  -- exclude local partitioned indexes on change tables
                  and i.bo# not in  ( select obj# from sys.cdc_change_tables$)
            union all
            -- global nonpartitioned indexes on partitioned tables
            select dense_rank() over (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM,
                  ''I'' IDX_OR_TAB,
                  u.user# USER_ID,
                  null,null,null,null,cols PCOLS,null,
                  ''GNP'' IDX_FLAGS, 
                  decode(i.type#, 1, ''NORMAL''||
                                 decode(bitand(i.property, 4), 0, '''', 4, 
                                    ''/REV''),
                                  2, ''BITMAP'', 3, ''CLUSTER'', 4, 
                                     ''IOT - TOP'',
                                  5, ''IOT - NESTED'', 6, ''SECONDARY'', 7, 
                                      ''ANSI'', 8, ''LOB'',
                                  9, ''DOMAIN'') IDX_TYPE,
                  decode(i.property, null,null,
                         decode(bitand(i.property, 1),
                                0, ''NONUNIQUE'', 
                                1, ''UNIQUE'', ''UNDEFINED'')) IDX_UK
            from sys.partobj$ p, sys.user$ u, sys.obj$ o, sys.ind$ i
            where p.obj# = i.bo#
            -- exclude global nonpartitioned indexes on change tables
            and   i.bo# not in  ( select obj# from sys.cdc_change_tables$)
            and   o.owner# = u.user# 
            and   p.obj# = o.obj# 
            and   p.flags =0
            and   bitand(i.property, 2) <>2
            and   u.name not in (''SYS'',''SYSTEM'',''SH'',''MDSYS''))
            order by num, idx_or_tab desc)';
BEGIN
  IF g_version_category = VERSION_817  THEN
    l_isUsedSQL := 
   'select 1 from (select sum(tot) CNT from
 ( select count(*) tot 
   from dba_tables 
   where partitioned=''YES''
   and owner not in (''SYS'',''SYSTEM'',''SH'',''MDSYS'')
   union all
   select count(*) tot
   from dba_indexes
   where partitioned=''YES''
   and owner not in (''SYS'',''SYSTEM'',''SH'',''MDSYS''))) where CNT > 0';

   l_infoSQL :=
   'select num||'':''||idx_or_tab||'':''||user_id||'':''||ptype||'':''||subptype||'':''
       ||pcnt||'':'' ||subpcnt||'':''||
       pcols||'':''||subpcols||'':''||idx_flags||'':''||
       idx_type||'':''||idx_uk||''|'' my_string from (select * from
          (select /*+ full(o) */ dense_rank() over 
                  (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM,
                  decode(o.type#,1,''I'',2,''T'',null)  IDX_OR_TAB, 
                  u.user# USER_ID,
                  decode(p.parttype, 1, ''RANGE'', 2, ''HASH'', 3, 
                              ''SYSTEM'', 4, ''LIST'', ''UNKNOWN'') PTYPE, 
                  decode(mod(p.spare2, 256), 0, null, 2, ''HASH'', 3,
                        ''SYSTEM'', 4, ''LIST'', ''UNKNOWN'') SUBPTYPE,
                  p.partcnt PCNT, 
                  mod(trunc(p.spare2/65536), 65536) SUBPCNT,
                  p.partkeycols PCOLS, 
                  mod(trunc(p.spare2/256), 256) SUBPCOLS,
                  decode(p.flags,0,null,decode(mod(p.flags,3),0,
                             ''LP'',1,''L'', 2,''GP'' ,null)) IDX_FLAGS, 
                  decode(i.type#, 1, ''NORMAL''||
                                  decode(bitand(i.property, 4), 0, 
                                      '''', 4, ''/REV''),
                  2, ''BITMAP'', 3, ''CLUSTER'', 4, ''IOT - TOP'',
                  5, ''IOT - NESTED'', 6, ''SECONDARY'', 7, ''ANSI'', 
                           8, ''LOB'', 9, ''DOMAIN'') IDX_TYPE,
                  decode(i.property, null,null,
                                     decode(bitand(i.property, 1), 0, 
                                         ''NONUNIQUE'', 
                                     1, ''UNIQUE'', ''UNDEFINED'')) IDX_UK
                  from sys.partobj$ p, sys.obj$ o, sys.user$ u, sys.ind$ i
                  where o.obj# = i.obj#(+)
                  and   o.owner# = u.user# 
                  and   p.obj# = o.obj# 
                  and   u.name not in (''SYS'',''SYSTEM'',''SH'',''MDSYS'')
                  -- fix bug 3074607 - filter on obj$
                  and o.type# in (1,2,19,20,25,34,35)
            union all
            select dense_rank() over (order by  decode(i.bo#,null,p.obj#,
                                                           i.bo#)) NUM,
                   ''I'' IDX_OR_TAB,
                   u.user# USER_ID,
                   cast(null as varchar2(20)) c0,
                   cast(null as varchar2(20)) c1,
                   cast(null as number) c2,
                   cast( null as number) c3,
                   cols PCOLS,
                   cast(null as number) c4,
                   ''GNP'' IDX_FLAGS, 
                   decode(i.type#, 1, ''NORMAL''||
                                 decode(bitand(i.property, 4), 0, '''', 4,
                                                            ''/REV''),
                                  2, ''BITMAP'', 3, ''CLUSTER'', 4, 
                                           ''IOT - TOP'',
                                  5, ''IOT - NESTED'', 6, ''SECONDARY'', 7, 
                                           ''ANSI'', 8, ''LOB'',
                                  9, ''DOMAIN'') IDX_TYPE,
                   decode(i.property, null,null,
                     decode(bitand(i.property, 1), 0,  ''NONUNIQUE'',  1, ''UNIQUE'', ''UNDEFINED'')) IDX_UK
            from sys.partobj$ p, sys.user$ u, sys.obj$ o, sys.ind$ i
            where p.obj# = i.bo#
            and   o.owner# = u.user# 
            and   p.obj# = o.obj# 
            and   p.flags =0
            and   bitand(i.property, 2) <>2
            and   u.name not in (''SYS'',''SYSTEM'',''SH'',''MDSYS''))
            order by num, idx_or_tab desc)';
  END IF;

  write_option_record('Partitioning',l_isInstalledSQL,l_isUsedSQL,
     l_infoSQL);
end write_partitioning;


/*
Write OLAP option 
Provide three sqls:
1. check for install
2. check for usage
3. get option information for validation
*/
PROCEDURE write_olap 
IS
 l_isInstalledSQL VARCHAR2(500) := 
    'SELECT 1 from v$option where parameter=''OLAP'' and value =''TRUE'' and rownum = 1';
 l_isUsedSQL VARCHAR2(500) :=
    'SELECT 1 FROM olapsys.dba$olap_cubes '||
    ' WHERE OWNER <> ''SH'' and rownum = 1 '||
    ' UNION ALL '||
    'SELECT 1 FROM '||
    ' (SELECT count(*) CNT FROM dba_aws '||
    '  where upper(AW_NAME) NOT IN '||
    '  (''EXPRESS'', ''CWMTOECM'', ''AWMD'', ''AWREPORT'', ''AWCREATE10G'', ''AWXML'')'||
    ' ) where CNT > 0';
  l_infoSQL VARCHAR2(500) :=
    'SELECT OWNER || ''-'' || AW_NAME FROM DBA_AWS ';
BEGIN
   write_option_record('OLAP',l_isInstalledSQL,l_isUsedSQL,l_infoSQL);
end write_olap;


PROCEDURE write_db_feature_usage IS
BEGIN
  write_results(
    'SELECT DBID,NAME, VERSION, DETECTED_USAGES, TOTAL_SAMPLES, CURRENTLY_USED, '||
    'to_char(FIRST_USAGE_DATE,''YYYY-MM-DD HH24:MI:SS'') FIRST_USAGE, '||
    'to_char(LAST_USAGE_DATE,''YYYY-MM-DD HH24:MI:SS'') LAST_USAGE, '||
    'AUX_COUNT, '||
    'to_char(LAST_SAMPLE_DATE,''YYYY-MM-DD HH24:MI:SS'') LAST_SAMPLE, '||
    'LAST_SAMPLE_PERIOD, '||
    'replace((nvl(TO_CHAR(substr(FEATURE_INFO,0,4000)),'''')),''|'',''#'') FEATURE_DETAIL '||
    'FROM DBA_FEATURE_USAGE_STATISTICS where version in ( select max(version) from DBA_FEATURE_USAGE_STATISTICS  )' );

end write_db_feature_usage;


/*
Private procedure
Collect metric=db_feature_usage
*/
procedure collect_db_feature_usage IS
 l_sql VARCHAR2(4000);
 l_end_done      BOOLEAN DEFAULT FALSE;
BEGIN
    put_metric_marker(METRIC_BEGIN_MARKER,'db_feature_usage',null);
    IF g_version_category = VERSION_817 
       OR g_version_category = VERSION_9i
       OR g_version_category = VERSION_9iR2 THEN
          write_partitioning;
          write_oem;
          write_olap;
          write_rac;
          write_lsec;
          write_data_mining;
          write_data_vault;
          write_audit_vault;
          write_content_db;
          write_records_db;
          write_spatial;
    END IF;

    IF g_version_category = VERSION_10gR1 
      OR g_version_category = VERSION_10gR2 
      OR g_version_category = VERSION_11gR1 
      OR g_version_category = VERSION_11gR2 
      OR g_version_category = VERSION_12gR1
      OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
          write_data_vault;
          write_audit_vault;
          write_content_db;
          write_records_db;
          write_db_feature_usage;
    END IF;
    put_metric_marker(METRIC_END_MARKER,'db_feature_usage',null);
    l_end_done   := TRUE;
EXCEPTION
 WHEN OTHERS THEN
    IF NOT l_end_done  THEN
     put_metric_marker(METRIC_END_MARKER,'db_feature_usage',null);
    END IF;
    RAISE;
END collect_db_feature_usage;


PROCEDURE write_cdb_feature_usage IS
BEGIN
  write_results( 
    'with pdbview AS (SELECT DISTINCT con_id, name pdb FROM gv$containers where con_id != 2) ' ||
    'SELECT pdb.pdb, DBID, NAME, VERSION, DETECTED_USAGES, TOTAL_SAMPLES, CURRENTLY_USED, ' ||
    ' to_char(FIRST_USAGE_DATE,''YYYY-MM-DD HH24:MI:SS'') FIRST_USAGE, ' ||
    ' to_char(LAST_USAGE_DATE,''YYYY-MM-DD HH24:MI:SS'') LAST_USAGE, ' ||
    ' AUX_COUNT, ' ||
    ' to_char(LAST_SAMPLE_DATE,''YYYY-MM-DD HH24:MI:SS'') LAST_SAMPLE, ' ||
    ' LAST_SAMPLE_PERIOD, ' ||
    ' replace((nvl(TO_CHAR(substr(FEATURE_INFO,0,4000)),'''')),''|'',''#'') FEATURE_DETAIL ' ||
    'FROM CDB_FEATURE_USAGE_STATISTICS cfus, pdbview pdb ' ||
    'where cfus.version in ' ||
    '  (select max(version) from CDB_FEATURE_USAGE_STATISTICS where con_id = pdb.con_id) ' ||
    '  and cfus.con_id = pdb.con_id ');
end write_cdb_feature_usage;


/*
Private procedure
Collect metric=cdb_feature_usage
*/
procedure collect_cdb_feature_usage IS
 l_sql VARCHAR2(4000);
 l_end_done      BOOLEAN DEFAULT FALSE;
BEGIN
    put_metric_marker(METRIC_BEGIN_MARKER,'cdb_feature_usage',null);
    write_cdb_feature_usage;
    put_metric_marker(METRIC_END_MARKER,'cdb_feature_usage',null);
    l_end_done   := TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF NOT l_end_done THEN
          put_metric_marker(METRIC_END_MARKER,'cdb_feature_usage',null);
        END IF;
      RAISE;
END collect_cdb_feature_usage;

/*
Private procedure
Collect metric=high_water_mark_stats
*/
procedure collect_high_water_mark_stats IS
BEGIN
  IF g_version_category = VERSION_10gR1 
  OR g_version_category = VERSION_10gR2 
  OR g_version_category = VERSION_11gR1 
  OR g_version_category = VERSION_11gR2 
  OR g_version_category = VERSION_12gR1
  OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    write_metric('high_water_mark_stats',
      'SELECT  s.DBID, s.NAME, s.VERSION, s.HIGHWATER, s.LAST_VALUE '||
      ' FROM DBA_HIGH_WATER_MARK_STATISTICS s, V$DATABASE d '||
      ' where s.version in ( select max(version) from dba_high_water_mark_statistics ) ' ||
      ' and s.dbid = d.dbid');
  END IF;
END collect_high_water_mark_stats;


/*
Private procedure
Collect metric=cdb_high_water_mark_stats
*/
procedure collect_cdb_hwm_stats IS
BEGIN
  write_metric('cdb_high_water_mark_stats',
    'WITH pdbs AS (SELECT DISTINCT con_id, name pdb FROM gv$containers where con_id != 2) ' ||
    'SELECT p.pdb, s.DBID, s.NAME, s.VERSION, s.HIGHWATER, s.LAST_VALUE ' ||
    'FROM CDB_HIGH_WATER_MARK_STATISTICS s, V$DATABASE d, pdbs p ' ||
    'WHERE s.version in ( SELECT max(version) FROM dba_high_water_mark_statistics ) ' ||
    'AND s.dbid = d.dbid ' ||
    'AND s.con_id = p.con_id');
END collect_cdb_hwm_stats;


/*
Private procedure
Collect metric=db_cpu_usage
*/
procedure collect_db_cpu_usage IS
BEGIN
  IF g_version_category = VERSION_10gR2 
  OR g_version_category = VERSION_11gR1 
  OR g_version_category = VERSION_11gR2 
  OR g_version_category = VERSION_12gR1
  OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    write_metric('db_cpu_usage',
      'SELECT * FROM (SELECT DBID,VERSION ,to_char(TIMESTAMP,''YYYY-MM-DD HH24:MI:SS''), CPU_COUNT, CPU_CORE_COUNT, CPU_SOCKET_COUNT '||
      'FROM DBA_CPU_USAGE_STATISTICS '||
      'where version in (select max(version) from DBA_CPU_USAGE_STATISTICS) ORDER BY Timestamp desc) WHERE ROWNUM <= 1 ');
  END IF;
END collect_db_cpu_usage;


/*
Private procedure
Collect metric=oracle_pdb_list, oracle_pdb_targets
*/
procedure collect_pdb_list IS
BEGIN
    write_metric('oracle_pdb_list',
                 'select /*+ NO_PARALLEL(dp) */ '||
                 'sys_context(''USERENV'',''CON_NAME'') as NAME, con_uid as CON_UID, sys_context(''USERENV'',''DB_UNIQUE_NAME'') as SERVICE_NAME '||
                 'from dba_pdbs dp where dp.pdb_name = ''PDB$SEED'' '||
                 'union '||
                 'select /*+ NO_PARALLEL(a) NO_PARALLEL(b) */ a.pdb_name as NAME, a.con_uid as CON_UID, NVL(b.NAME,a.pdb_name) as SERVICE_NAME '||
                 'from dba_pdbs a LEFT JOIN cdb_services b ON a.pdb_name = b.pdb '||
                 'where a.pdb_name <> ''PDB$SEED'' and '||
                 '(b.name is null or regexp_like(b.name,''^''||a.pdb_name||''$|^''||a.pdb_name||''\.'', ''i'')) ORDER BY name');
    write_metric('oracle_pdb_targets',
                 'select /*+ NO_PARALLEL(dp) */ '||
                 'sys_context(''USERENV'',''CON_NAME'') as NAME, con_uid, sys_context(''USERENV'',''DB_UNIQUE_NAME'') as SERVICE_NAME, ''YES'' as IS_ROOT '||
                 'from dba_pdbs dp where dp.pdb_name = ''PDB$SEED'' '||
                 'union  '||
                 'select /*+ NO_PARALLEL(a) NO_PARALLEL(b) */ a.pdb_name as NAME, a.con_uid, NVL(b.NAME,a.pdb_name) as SERVICE_NAME, ''NO'' as IS_ROOT '||
                 'from dba_pdbs a LEFT JOIN cdb_services b ON a.pdb_name = b.pdb '||
                 'where a.pdb_name <> ''PDB$SEED'' and '||
                 '(b.name is null or regexp_like(b.name,''^''||a.pdb_name||''$|^''||a.pdb_name||''\.'', ''i'')) ORDER BY name');
END collect_pdb_list;

/*
Private procedure
Collect metric=oracle_cdb_services
*/
procedure collect_cdb_services IS
  CURSOR l_res_cur IS select inst_id,instance_name from gv$instance;
BEGIN
  FOR inst_id_row in l_res_cur LOOP
    write_metric('cdb_services',
      'WITH pdbs AS (SELECT DISTINCT con_id, name pdb, inst_id FROM gv$containers where con_id != 2) ' ||
      'select /*+ NO_PARALLEL(s) */ p.pdb, name, network_name, TO_CHAR(creation_date, ''YYYY-MM-DD HH24:MI:SS''), '||
      'failover_method, failover_type, failover_retries, failover_delay,min_cardinality, max_cardinality, '||
      'goal, dtp, enabled, aq_ha_notifications, clb_goal, edition '||
      'from sys.cdb_services s, pdbs p WHERE s.con_id = p.con_id and p.inst_id = ' || inst_id_row.inst_id
      ,inst_id_row.instance_name);

 END LOOP;
END collect_cdb_services;

/************************************************
* BEGIN Cell Metrics
***********************************************/

procedure collect_cell_list IS 
  l_sql VARCHAR2(4000);
BEGIN
  IF g_version_category = VERSION_11gR2 
  OR g_version_category = VERSION_12gR1
  OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_sql :=  'select replace(cc.cellname, '':'', ''_'') , cell.name, cell.id, cell.cellVersion, cell.releaseVersion' ||
     ' from v$cell_config cc, ' ||
     ' xmltable ' ||
     '(''/cli-output/cell'' passing xmltype(cc.confval) ' ||
     ' columns ' ||
     ' name varchar2(256) path ''name'', ' ||
     ' id varchar2(256) path ''id'', ' ||
     ' cellVersion varchar2(256) path ''cellVersion'', ' ||
     ' releaseVersion varchar2(256) path ''releaseVersion'' ' ||
     ') cell where cc.conftype=''CELL''';
    write_metric('cell_list', l_sql);
  END IF;
END collect_cell_list;

/*
Private procedure
Collect metric=cell_config
*/
procedure collect_cell_config IS
  l_ip_cur INTEGER;
  l_ip_var VARCHAR2(256);
  l_res INTEGER;
  l_sql VARCHAR2(4000);
BEGIN
  IF g_version_category = VERSION_11gR2 
  OR g_version_category = VERSION_12gR1
  OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_ip_cur := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_ip_cur, 'select distinct cellname from v$cell_config', 
    DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(l_ip_cur, 1, l_ip_var, 256);
    l_res := DBMS_SQL.EXECUTE(l_ip_cur);
    LOOP
      IF DBMS_SQL.FETCH_ROWS(l_ip_cur)>0 THEN
        DBMS_SQL.COLUMN_VALUE(l_ip_cur, 1, l_ip_var);
        l_sql := 'select cell.* ' ||
    ' from ' ||
    ' v$cell_config cc, ' ||
    ' xmltable ' ||
    ' (''/cli-output/cell'' passing xmltype(cc.confval) ' ||
    ' columns ' ||
    ' name varchar2(256) path ''name'', ' ||
    ' bmcType varchar2(256) path ''bmcType'', ' ||
    ' cellVersion varchar2(256) path ''cellVersion'', ' ||
    ' cpuCount varchar2(256) path ''cpuCount'', ' ||
    ' fanCount varchar2(256) path ''fanCount'', ' ||
    ' id varchar2(256) path ''id'', ' ||
    ' interconnectCount varchar2(256) path ''interconnectCount'', ' ||
    ' iormBoost varchar2(256) path ''iormBoost'', '||
    ' ipaddress1 varchar2(256) path ''ipaddress1'', ' ||
    ' ipaddress2 varchar2(256) path ''ipaddress2'', ' ||
    ' ipaddress3 varchar2(256) path ''ipaddress3'', ' ||
    ' ipaddress4 varchar2(256) path ''ipaddress4'', ' ||
    '  kernelVersion varchar2(256) path ''kernelVersion'', ' ||
    ' makeModel varchar2(256) path ''makeModel'', ' ||
    ' metricHistoryDays varchar2(256) path ''metricHistoryDays'', ' ||
    ' powerCount varchar2(256) path ''powerCount'' ' ||
    ' ) cell where ' ||
    ' cc.conftype=''CELL'' and cellname='''|| l_ip_var || '''';
        write_metric('cell_config', l_sql, null, replace(l_ip_var, ':', '_') , '|' );
      END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_ip_cur) THEN
         DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
      END IF;      
END collect_cell_config;


procedure collect_griddisk_config IS
  l_ip_cur INTEGER;
  l_ip_var VARCHAR2(256);
  l_res INTEGER;
  l_sql VARCHAR2(4000);
BEGIN
  IF g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_ip_cur := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_ip_cur, 'select distinct cellname from v$cell_config', 
    DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(l_ip_cur, 1, l_ip_var, 256);
    l_res := DBMS_SQL.EXECUTE(l_ip_cur);
    LOOP
    IF DBMS_SQL.FETCH_ROWS(l_ip_cur)>0 THEN
    DBMS_SQL.COLUMN_VALUE(l_ip_cur, 1, l_ip_var);
  l_sql := 'select gds.name, gds.availableTo, gds.cellDisk, gds.gdcomment, ' ||
    'gds.creationTime, gds.errorCount, gds.id, round(gds.offset/1048576), ' ||
    'round(gds.gdsize/1048576), gds.status ' ||
    ' from ' ||
    ' v$cell_config cc, ' ||
    ' xmltable ' ||
    ' (''/cli-output/griddisk'' passing xmltype(cc.confval) ' ||
    ' columns ' ||
    ' name varchar2(256) path ''name'', ' ||
    ' availableTo varchar2(256) path ''availableTo'', ' ||
    ' cellDisk varchar2(256) path ''cellDisk'', ' ||
    ' gdcomment varchar2(4000) path ''comment'', ' ||
    ' creationTime varchar2(256) path ''creationTime'', ' ||
    ' errorCount varchar2(256) path ''errorCount'', ' ||
    ' id varchar2(256) path ''id'', ' ||
    ' offset varchar2(256) path ''offset'', ' ||
    ' gdsize varchar2(256) path ''size'', ' ||
    ' status varchar2(256) path ''status'' ' ||
    ' ) gds  where cc.conftype=''GRIDDISKS'' and cellname='''|| l_ip_var || '''';
    write_metric('cell_griddisk_config', l_sql,
    null, replace(l_ip_var, ':', '_'), '|' );
    END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_ip_cur) THEN
         DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
      END IF;      
END collect_griddisk_config;


procedure collect_celldisk_config IS
  l_ip_cur INTEGER;
  l_ip_var VARCHAR2(256);
  l_res INTEGER;
  l_sql VARCHAR2(4000);
BEGIN
  IF g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_ip_cur := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_ip_cur, 'select distinct cellname from v$cell_config', 
    DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(l_ip_cur, 1, l_ip_var, 256);
    l_res := DBMS_SQL.EXECUTE(l_ip_cur);
    LOOP
    IF DBMS_SQL.FETCH_ROWS(l_ip_cur)>0 THEN
    DBMS_SQL.COLUMN_VALUE(l_ip_cur, 1, l_ip_var);
  l_sql :=
    ' select cds.name, cds.cdcomment, cds.creationTime, cds.deviceName, ' ||
    ' cds.devicePartition, cds.errorCount,round(cds.freeSpace/1073741824, 2), cds.id, cds.lun, ' ||
    ' cds.raidLevel,round(cds.cdsize/1073741824, 2), cds.status ' ||
    ' from ' ||
    ' v$cell_config cc, ' ||
    ' xmltable ' ||
    ' (''/cli-output/celldisk'' passing xmltype(cc.confval) ' ||
    ' columns ' ||
    ' name varchar2(256) path ''name'', ' ||
    ' cdcomment varchar2(4000) path ''comment'', ' ||
    ' creationTime varchar2(256) path ''creationTime'', ' ||
    ' deviceName varchar2(256) path ''deviceName'', ' ||
    ' devicePartition varchar2(256) path ''devicePartition'', ' ||
    ' errorCount varchar2(256) path ''errorCount'', ' ||
    ' freeSpace varchar2(256) path ''freeSpace'', ' ||
    ' id varchar2(256) path ''id'', ' ||
    ' lun varchar2(256) path ''lun'', ' ||
    ' raidLevel varchar2(256) path ''raidLevel'', ' ||
    ' cdsize varchar2(256) path ''size'', ' ||
    ' status varchar2(256) path ''status'' ' ||
    ' ) cds  where cc.conftype=''CELLDISKS'' and cellname='''|| l_ip_var || '''';
    write_metric('cell_celldisk_config', l_sql,
    null, replace(l_ip_var, ':', '_'), '|' );
    END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_ip_cur) THEN
         DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
      END IF;      
END collect_celldisk_config;


procedure collect_lun_config IS
  l_ip_cur INTEGER;
  l_ip_var VARCHAR2(256);
  l_res INTEGER;
  l_sql VARCHAR2(4000);
BEGIN
  IF g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_ip_cur := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_ip_cur, 'select distinct cellname from v$cell_config', 
    DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(l_ip_cur, 1, l_ip_var, 256);
    l_res := DBMS_SQL.EXECUTE(l_ip_cur);
    LOOP
    IF DBMS_SQL.FETCH_ROWS(l_ip_cur)>0 THEN
    DBMS_SQL.COLUMN_VALUE(l_ip_cur, 1, l_ip_var);
  l_sql :=
    ' select luns.name, luns.cellDisk, luns.deviceName, luns.id, luns.isSystemLun,  ' ||
    ' luns.lunAutoCreate, round(luns.lunSize/1073741824, 2), luns.physicalDevices, ' ||
    ' luns.raidLevel, luns.status ' ||
    ' from ' ||
    '     v$cell_config cc, ' ||
    ' xmltable ' ||
    ' (''/cli-output/lun'' passing xmltype(cc.confval) ' ||
    '  columns ' ||
    '   name varchar2(256) path ''name'', ' ||
    '   cellDisk varchar2(256) path ''cellDisk'', ' ||
    '   deviceName varchar2(256) path ''deviceName'', ' ||
    '   id varchar2(256) path ''id'', ' ||
    '   isSystemLun varchar2(256) path ''isSystemLun'', ' ||
    '   lunAutoCreate varchar2(256) path ''lunAutoCreate'', ' ||
    '   lunSize varchar2(256) path ''lunSize'', ' ||
    '   physicalDevices varchar2(256) path ''physicalDevices'', ' ||
    '   raidLevel varchar2(256) path ''raidLevel'', ' ||
    '   status varchar2(256) path ''status'' ' ||
    ' ) luns where cc.conftype=''LUNS'' and cellname='''|| l_ip_var || '''';
    write_metric('cell_lun_config', l_sql,
    null, replace(l_ip_var, ':', '_'), '|' );
    END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_ip_cur) THEN
         DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
      END IF;      
END collect_lun_config;


procedure collect_physicaldisk_config IS
  l_ip_cur INTEGER;
  l_ip_var VARCHAR2(256);
  l_res INTEGER;
  l_sql VARCHAR2(4000);
BEGIN
  IF g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_ip_cur := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_ip_cur, 'select distinct cellname from v$cell_config', 
    DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(l_ip_cur, 1, l_ip_var, 256);
    l_res := DBMS_SQL.EXECUTE(l_ip_cur);
    LOOP
    IF DBMS_SQL.FETCH_ROWS(l_ip_cur)>0 THEN
    DBMS_SQL.COLUMN_VALUE(l_ip_cur, 1, l_ip_var);
  l_sql :=
    ' select pds.name, pds.id, pds.luns, pds.physicalInsertTime,  ' ||
    ' round (pds.physicalSize/1073741824, 2), pds.status ' ||
    ' from ' ||
    '     v$cell_config cc, ' ||
    ' xmltable ' ||
    ' (''/cli-output/physicaldisk'' passing xmltype(cc.confval) ' ||
    '  columns ' ||
    '   name varchar2(256) path ''name'', ' ||
    '   id varchar2(256) path ''id'', ' ||
    '   luns varchar2(256) path ''luns'', ' ||
    '   physicalInsertTime varchar2(256) path ''physicalInsertTime'', ' ||
    '   physicalSize varchar2(256) path ''physicalSize'', ' ||
    '   status varchar2(256) path ''status'' ' ||
    ' ) pds where cc.conftype like ''PHYSICAL%'' and cellname='''|| l_ip_var || '''';
    write_metric('cell_physicaldisk_config', l_sql,
    null, replace(l_ip_var, ':', '_'), '|' );
    END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_ip_cur) THEN
         DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
      END IF;      
END collect_physicaldisk_config;


procedure collect_iorm_config IS
    l_ip_cur INTEGER;
    l_ip_var VARCHAR2(256);
    l_res INTEGER;
    l_sql VARCHAR2(4000);
BEGIN
  IF g_version_category = VERSION_11gR2 
     OR g_version_category = VERSION_12gR1
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_ip_cur := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_ip_cur, 'select distinct cellname from v$cell_config', 
    DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(l_ip_cur, 1, l_ip_var, 256);
    l_res := DBMS_SQL.EXECUTE(l_ip_cur);
    LOOP
    IF DBMS_SQL.FETCH_ROWS(l_ip_cur)>0 THEN
    DBMS_SQL.COLUMN_VALUE(l_ip_cur, 1, l_ip_var);
  l_sql :=
    ' select iorm.* ' ||
    ' from ' ||
    '     v$cell_config cc, ' ||
    ' xmltable ' ||
    ' (''/cli-output/interdatabaseplan'' passing xmltype(cc.confval) ' ||
    '  columns ' ||
    '   name varchar2(256) path ''name'', ' ||
    '   catPlan varchar2(256) path ''catPlan'', ' ||
    '   dbPlan varchar2(256) path ''dbPlan'', ' ||
    '   status varchar2(256) path ''status'' ' ||
    ' ) iorm where cc.conftype =''IORM'' and cellname='''|| l_ip_var || '''';
    write_metric('cell_iorm_config', l_sql,
    null, replace(l_ip_var, ':', '_'), '|' );
    END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_ip_cur) THEN
         DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
      END IF;      
END collect_iorm_config;

procedure collect_patches IS
    l_ip_cur INTEGER;
    l_ip_var VARCHAR2(256);
    l_res INTEGER;
    l_sql VARCHAR2(4000);
BEGIN
  IF g_version_category = VERSION_11gR2
     OR g_version_category = VERSION_12gR1
     OR g_version_category = HIGHER_SUPPORTED_VERSION THEN
    l_ip_cur := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(l_ip_cur, 'select distinct cellname from v$cell_config',
    DBMS_SQL.NATIVE);
    DBMS_SQL.DEFINE_COLUMN(l_ip_cur, 1, l_ip_var, 256);
    l_res := DBMS_SQL.EXECUTE(l_ip_cur);
    LOOP
    IF DBMS_SQL.FETCH_ROWS(l_ip_cur)>0 THEN
    DBMS_SQL.COLUMN_VALUE(l_ip_cur, 1, l_ip_var);
  l_sql := 'select cell.* ' ||
    '  from ' ||
    '  v$cell_config cc, ' ||
    ' xmltable ' ||
    ' (''/cli-output/cell'' passing xmltype(cc.confval) ' ||
    ' columns ' ||
    '   releaseTrackingBug varchar2(256) path ''releaseTrackingBug'' ' ||
    ' ) cell where ' ||
    '   cc.conftype=''CELL'' and cellname='''|| l_ip_var || '''';
     write_metric('cell_patches', l_sql,
     null, replace(l_ip_var, ':', '_') , '|' );
    END IF;
    END LOOP;
    DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_ip_cur) THEN
         DBMS_SQL.CLOSE_CURSOR(l_ip_cur);
      END IF;
END collect_patches;

/************************************************
* END Cell Metrics
***********************************************/


/*
get the destination file name
*/
FUNCTION get_dest_file_name(p_ext IN VARCHAR2 DEFAULT '.ll')  RETURN VARCHAR2 IS
  l_db_name  v$database.name%TYPE;
  l_par v$instance.PARALLEL%TYPE;
BEGIN
   SELECT  name into l_db_name FROM v$database ;
  /*
    Check if the database is running in RAC mode.
    If so, name the file as <db_name>-RAC.ll
  */
   select PARALLEL into l_par  from v$instance;
   IF l_par = 'YES' THEN
       RETURN l_db_name || '-RAC'||p_ext;
   END IF;

   RETURN l_db_name || p_ext;
END get_dest_file_name; 

/**
Write file header
*/
PROCEDURE  write_file_header
IS
   l_db_characterset VARCHAR2(20);
   l_vers            v$instance.version%TYPE;
   l_comp_cnt        NUMBER;
   l_checkXMLdb      VARCHAR2(500);
BEGIN
   select value into l_db_characterset from NLS_DATABASE_PARAMETERS where parameter = 'NLS_CHARACTERSET';
   UTL_FILE.PUT_LINE(g_config_handle,'META_VER=' || ORACLE_DATABASE_META_VER);
   UTL_FILE.PUT_LINE(g_config_handle,'TIMESTAMP=' || TO_CHAR(sysdate,'yyyy-mm-dd hh24:mi:ss')); 
   UTL_FILE.PUT_LINE(g_config_handle,'NLS_CHARACTERSET=' || l_db_characterset);
   -- If 11+, check for XML DB before calling UTL_INADDR package, otherwise go ahead
   select LPAD(version,10,'0') into l_vers from v$instance;
   IF l_vers >= '11.0.0.0.0' THEN
      l_checkXMLdb :=
         'select count(*) from dba_registry where COMP_NAME = ''Oracle XML Database'' ' ||
         'and STATUS = ''VALID''' ;
       -- check for XML DB installed
       execute immediate l_checkXMLdb into l_comp_cnt;
   ELSE
      l_comp_cnt := 1;
   END IF;
   IF l_comp_cnt > 0 THEN
      -- wrap with exception block
      BEGIN
         UTL_FILE.PUT_LINE(g_config_handle,'IP_ADDRESS=' || UTL_INADDR.GET_HOST_ADDRESS);
         UTL_FILE.PUT_LINE(g_config_handle,'HOSTNAME='   || UTL_INADDR.GET_HOST_NAME);
      EXCEPTION
         WHEN OTHERS THEN NULL;
      END;
   END IF;
END;

/**
Write file footer
*/
PROCEDURE  write_file_footer
IS
BEGIN
   UTL_FILE.PUT_LINE(g_config_handle,'_CCR_EOF_');
END;


/*
The implementation procedure which does the collection.
*/
procedure collect_config_metrics_impl IS
  l_asm_instance_name VARCHAR2(4000) ;
BEGIN
  write_file_header();

  IF g_version_category = VERSION_10gR1 OR
     g_version_category = VERSION_10gR2 THEN
    execute immediate 'select * from (select instance_name ' ||
                ' from (select '' '' instance_name from dual ' ||
                ' union all ' ||
                ' select instance_name from v$asm_client) ' ||
                ' order by instance_name desc) ' ||
                ' where rownum = 1 ' into l_asm_instance_name;
    IF l_asm_instance_name != ' ' THEN
      UTL_FILE.PUT_LINE(g_config_handle,'OSMInstance=' || l_asm_instance_name);
     END IF;
   END IF;

   collect_db_init_params; 
   collect_db_asm_disk;
   collect_autotask_client;
   collect_db_components;
   collect_db_invobj_cnt;
   collect_db_scheduler_jobs;
   collect_db_sga;
   collect_db_tablespaces;
   collect_db_datafiles;
   collect_db_controlfiles;
   collect_db_redoLogs;
   collect_db_rollback_segs;
   collect_db_license;
   collect_db_options;
   collect_db_dbNInstanceInfo;
   collect_ha_info;
   collect_ha_rman_config;
   collect_statspack_config;
   -- collect_backup_config;
   collect_db_users;

   -- cell metrics
   collect_cell_list;
   collect_cell_config;
   collect_griddisk_config;
   collect_celldisk_config;
   collect_lun_config;
   collect_physicaldisk_config;
   collect_iorm_config;
   collect_patches;

   collect_db_scnInfo;

   if g_is_cdb = 'YES' then
     collect_pdb_list;
     collect_cdb_services;
     collect_cdb_datafiles;
     collect_cdb_init_params;
     collect_cdb_pdb_over_params;
     collect_cdb_rollback_segs;
     collect_cdb_tablespaces;
     collect_cdb_users;
     collect_cdb_dbNInstanceInfo;
   end if;

   write_file_footer();

   UTL_FILE.FFLUSH(g_config_handle);

END collect_config_metrics_impl;

/*
Puts the config data into the file
By default, this procedure does not raise an exception.
To raise an exception, pass "raise_exp" as TRUE.
*/
procedure collect_config_metrics(directory_location IN VARCHAR2,
 raise_exp BOOLEAN DEFAULT FALSE) IS
BEGIN
  BEGIN
  select dbid into g_dbID from v$database;
  select version into g_db_version from v$instance;

  g_version_category := get_version_category(); 
  IF g_version_category != NOT_SUPPORTED_VERSION THEN
    BEGIN
      g_config_handle := UTL_FILE.FOPEN(directory_location,get_dest_file_name(),'W',32767); 
      EXCEPTION
        WHEN UTL_FILE.INVALID_FILEHANDLE OR 
             UTL_FILE.INVALID_PATH OR
             UTL_FILE.INVALID_OPERATION OR 
             UTL_FILE.WRITE_ERROR THEN
          -- Just bail out, we cannot open or write to the ll file(s)
          RETURN;
    END;

    execute immediate 'ALTER SESSION SET nls_numeric_characters=". "';

    CHECK_IS_CDB;

    MGMT_DB_LL_METRICS.collect_config_metrics_impl;

    UTL_FILE.FCLOSE(g_config_handle); 
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF UTL_FILE.IS_OPEN (g_config_handle) = TRUE THEN
        UTL_FILE.FCLOSE(g_config_handle); 
      END IF;
      g_config_handle := null;
      g_version_category  := NULL;
      -- Raise exception only if explicitly asked for, by passing TRUE
      -- for "raise_exp" parameter.
      IF (raise_exp) THEN 
        RAISE;
      END IF;
  END;
END collect_config_metrics; 

/*
Puts the statistics config data into the file
By default, this procedure does not raise an exception.
To raise an exception, pass "raise_exp" as TRUE.
*/
procedure collect_stats_metrics(directory_location IN VARCHAR2,
 raise_exp BOOLEAN DEFAULT FALSE) IS
BEGIN
  BEGIN
    select dbid into g_dbID from v$database;
    select version into g_db_version from v$instance;

    g_version_category := get_version_category(); 
    IF g_version_category != NOT_SUPPORTED_VERSION THEN
      BEGIN
        g_config_handle := UTL_FILE.FOPEN(directory_location,get_dest_file_name('.ll-stat'),'W',32767);
        EXCEPTION
          WHEN UTL_FILE.INVALID_FILEHANDLE OR 
               UTL_FILE.INVALID_PATH OR
               UTL_FILE.INVALID_OPERATION OR 
               UTL_FILE.WRITE_ERROR THEN
            -- Just bail out, we cannot open or write to the ll file(s)
            RETURN;
      END;

      execute immediate 'ALTER SESSION SET nls_numeric_characters=". "';

      CHECK_IS_CDB;

      write_file_header();

      collect_db_feature_usage;
      collect_high_water_mark_stats;
      collect_db_cpu_usage;
      if g_is_cdb = 'YES' then
        collect_cdb_feature_usage;
        collect_cdb_hwm_stats;
      end if;

      write_file_footer();

      UTL_FILE.FFLUSH(g_config_handle);
      UTL_FILE.FCLOSE(g_config_handle); 

    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN (g_config_handle) = TRUE THEN
          UTL_FILE.FFLUSH(g_config_handle);
          UTL_FILE.FCLOSE(g_config_handle); 
        END IF;
        g_config_handle := null;
        g_version_category  := NULL;
        -- Raise exception only if explicitly asked for, by passing TRUE
        -- for "raise_exp" parameter.
        IF (raise_exp) THEN 
          RAISE;
        END IF;
  END;
END collect_stats_metrics; 

procedure write_db_ccr_file_impl IS
  l_hostName v$instance.HOST_NAME%TYPE;
  l_dbUniqueName v$parameter.VALUE%TYPE;
  l_dbDomain v$parameter.VALUE%TYPE;

  l_diagDest v$parameter.VALUE%TYPE;
  l_dbName v$parameter.VALUE%TYPE;
  l_dbInstanceName v$parameter.VALUE%TYPE;

BEGIN
  write_file_header();

  select host_name into l_hostName from v$instance;
  select value into l_dbUniqueName from v$parameter where name='db_unique_name';
  select value into l_dbDomain from v$parameter where name='db_domain';

  UTL_FILE.PUT_LINE(g_config_handle,'HOST_NAME='      || l_hostName);
  UTL_FILE.PUT_LINE(g_config_handle,'DB_UNIQUE_NAME=' || l_dbUniqueName);
  UTL_FILE.PUT_LINE(g_config_handle,'DB_DOMAIN='      || l_dbDomain);

  -- diagnostic_dest is property introduced from 11g
  -- So, pre 11g db will not have this so prepare for that
  BEGIN
    select value into l_diagDest from v$parameter where lower(name)='diagnostic_dest';
    UTL_FILE.PUT_LINE(g_config_handle,'DIAG_DEST='     || l_diagDest);
  EXCEPTION
       WHEN NO_DATA_FOUND THEN 
       null;
  END;

  select value into l_dbName from v$parameter where name='db_name';
  select value into l_dbInstanceName from v$parameter where name='instance_name';

  UTL_FILE.PUT_LINE(g_config_handle,'DB_NAME='       || l_dbName);
  UTL_FILE.PUT_LINE(g_config_handle,'INSTANCE_NAME=' || l_dbInstanceName);

  collect_db_dbNInstanceInfo;
  if g_is_cdb = 'YES' then
    collect_pdb_list;
  end if;
  collect_cell_list;

  write_file_footer();

END;

/*

By default, this procedure does not raise an exception.
To raise an exception, pass "raise_exp" as TRUE.
*/
procedure write_db_ccr_file(directory_location IN VARCHAR2,
 raise_exp BOOLEAN DEFAULT FALSE) IS
BEGIN
  BEGIN
    select dbid into g_dbID from v$database;
    select version into g_db_version from v$instance;

    g_version_category := get_version_category(); 
    IF g_version_category != NOT_SUPPORTED_VERSION THEN
      BEGIN
        g_config_handle := UTL_FILE.FOPEN(directory_location,get_dest_file_name('.ccr'),'W',32767); 
        EXCEPTION
          WHEN UTL_FILE.INVALID_FILEHANDLE OR 
               UTL_FILE.INVALID_PATH OR
               UTL_FILE.INVALID_OPERATION OR 
               UTL_FILE.WRITE_ERROR THEN
               -- Just bail out, we cannot open or write to the ll file(s)
                 RETURN;
      END;

      execute immediate 'ALTER SESSION SET nls_numeric_characters=". "';

      CHECK_IS_CDB;

      MGMT_DB_LL_METRICS.write_db_ccr_file_impl;
      UTL_FILE.FFLUSH(g_config_handle);
      UTL_FILE.FCLOSE(g_config_handle); 
    END IF;
    EXCEPTION
      WHEN OTHERS THEN
        IF UTL_FILE.IS_OPEN (g_config_handle) = TRUE THEN
          UTL_FILE.FFLUSH(g_config_handle);
          UTL_FILE.FCLOSE(g_config_handle); 
        END IF;
        g_config_handle := null;
        g_version_category  := NULL;
        -- Raise exception only if explicitly asked for, by passing TRUE
        -- for "raise_exp" parameter.
        IF (raise_exp) THEN 
          RAISE;
        END IF;
  END;
END write_db_ccr_file; 

END MGMT_DB_LL_METRICS;
/
show errors;
