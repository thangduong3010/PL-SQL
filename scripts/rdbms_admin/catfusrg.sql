Rem
Rem $Header: rdbms/admin/catfusrg.sql /st_rdbms_11.2.0/11 2013/06/22 16:34:50 elu Exp $
Rem
Rem catfusrg.sql
Rem
Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catfusrg.sql - Catalog registration file for DB Feature Usage clients
Rem
Rem    DESCRIPTION
Rem      Clients of the DB Feature Usage infrastructure can register their
Rem      features and high water marks in this file.
Rem
Rem      It is important to register the following 8 features:
Rem        RAC, Partitioning, OLAP, Data Mining, Oracle Label Security,
Rem        Oracle Advanced Security, Oracle Programmer(?), Oracle Spatial.
Rem
Rem    NOTES
Rem      The tracking for the following advisors is currently disabled:
Rem         Tablespace Advisor - smuthuli
Rem         SGA/Memory Advisor - tlahiri
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gkulkarn    06/18/13 - Backport gkulkarn_bug-16910396 from main
Rem    elu         06/10/13 - Backport elu_bug-16830636 from main
Rem    kamotwan    05/29/13 - Backport kamotwan_bug-16874207 from MAIN.
Rem                           Added feature tracking for
Rem                           DBENCRYPTION in goldengate
Rem    kamotwan    01/08/13 - Backport kamotwan_featuretracking_1 and 
Rem                           lzheng_bug-13917504from main 
Rem                           (as kamotwan_bug-15967833)
Rem    siravic     10/13/12 - Bug# 13888340: Data Redaction feature usage
Rem                           tracking
Rem    alhollow    02/17/12 - Backport alhollow_bug-13041324 from main
Rem    kamotwan    05/20/13 - 16830636 : Added feature tracking for GGSESSION
Rem                           and DELCASCADEHINT in goldengate
Rem    alhollow    08/01/11 - Add HCC stats
Rem    alui        07/12/11 - Backport alui_bug-12698413 from main
Rem    rdongmin    05/03/11 - Backport rdongmin_bug-10264073 from main
Rem    mtozawa     12/01/10 - Backport mtozawa_bug-10280821 from main
Rem    fsanchez    10/30/10 - Backport fsanchez_bug-9689580 from main
Rem    bpwang      05/30/10 - LRG 4646114: Handle GoldenGate Capture change
Rem    rmao        05/19/10 - change to dba_capture/apply.purpose
Rem    evoss       05/07/10 - better dbms_scheduler queries
Rem    bpwang      04/23/10 - Add XStream In, XStream Out, GoldenGate
Rem    jheng       04/06/10 - Fix bug 9256867: use dba_policies for OLS
Rem    yemeng      03/03/10 - change the name for diag/tuning pack
Rem    hbaer       02/26/10 - bug 9404352: fix Partition feature usage tracking for 11gR2
Rem    ysarig      02/10/10 - fixing bug 8940905
Rem    bvaranas    02/03/10 - 8803049: Feature usage tracking for deferred
Rem                           segment creation
Rem    pbelknap    09/23/09 - correct advisor fusg for reports
Rem    suelee      08/26/09 - Add tracking for dNFS and instance caging
Rem    fsanchez    07/22/09 - XbranchMerge fsanchez_bug-8657554 from
Rem                           st_rdbms_11.2.0.1.0
Rem    baleti      06/29/09 - split SF into user and system tracking
Rem    jcarey      06/30/09 - better olap query
Rem    qyu         06/30/09 - fix bug 8643026
Rem    pbelknap    06/22/09 - #8618452 - feature usage for reports
Rem    bsthanik    06/30/09 - 8643032: Exclude user APEX for XDB feature usage
Rem                           reporting
Rem    pbelknap    06/22/09 - #8618452 - feature usage for reports
Rem    cchui       06/17/09 - Register Database Vault
Rem    baleti      06/16/09 - Add SF compression, encryption and deduplication
Rem                           feature tracking
Rem    etucker     06/19/09 - break up OJVM stats
Rem    ychan       06/18/09 - Fix bug 8607966
Rem    xbarr       06/18/09 - Bug 8610599: update feature usage tracking for Data Mining option
Rem    mfallen     06/16/09 - add awr reports feature
Rem    mhho        06/17/09 - update ASO tracking queries
Rem    baleti      06/16/09 - Add SF compression, encryption and deduplication
Rem                           feature tracking
Rem    bsthanik    06/09/09 - Exclude user OE for XDB feature tracking
Rem    fsanchez    06/05/09 - change compression name DEFAULT -> BASIC
Rem    sugpande    06/24/09 - Change xml in HWM for exadata to a simple sql
Rem    sugpande    06/19/09 - Change HWM name
Rem    suelee      06/03/09 - Bug 8544790: gather feature info for Resource
Rem                           Manager
Rem    spsundar    05/29/09 - bug 8540405
Rem    alexsanc    05/26/09 - bug 7012409
Rem    weizhang    05/22/09 - bug 7026782: segment advisor (user)
Rem    sravada     05/22/09 - fix Spatial usage tracking so that only Spatial
Rem                           usage is counted and Locator is not counted
Rem    wbattist    05/26/09 - bug 7009390 - properly ignore XDB service and any
Rem                           streams services for feature usage
Rem    sravada     05/22/09 - fix Spatial usage tracking so that only Spatial
Rem                           usage is counted and Locator is not counted
Rem    qyu         05/14/09 - bug 7012411 and 7012412
Rem    vmarwah     05/14/09 - feature tracking for hybrid columnar compression
Rem    bsthanik    05/13/09 - 7009367: report xdb usage correctly
Rem    vgokhale    05/12/09 - Add feature usage for server flash cache
Rem    fsanchez    04/06/09 - bug 8411943
Rem    mkeihl      03/12/09 - Bug 5074668: active_instance_count is deprecated
Rem    ataracha    01/29/09 - enhance dbms_feature_xdb
Rem    etucker     12/02/08 - add javavm registration
Rem    sugpande    01/06/09 - Add db feature usage and high water mark for
Rem                           exadata
Rem    ysarig      09/25/08 - Fix bug# 7425224
Rem    fsanchez    08/28/08 - bug 6623413
Rem    jberesni    07/10/08 - add 7-day dbtime and dbcpu to AWR feature_info
Rem    lgalanis    06/25/08 - fix date logic in capture and replay procs
Rem    msakayed    04/17/08 - compression/encryption feature tracking for 11.2
Rem    ssamaran    02/13/08 - Add RMAN tracking
Rem    jiashi      03/19/08 - Remove dest_id from ADG RTQ feature tracking
Rem    jiashi      02/28/08 - Update ADG RTQ feature name
Rem    achoi       01/22/08 - track Edition feature
Rem    dolin       01/15/08 - Update Multimedia to Oracle Multimedia, DICOM to
Rem                           Oracle Multimedia DICOM
Rem    rkgautam    08/17/07 - bug-5475037 Using the feature 
Rem                         - Externally authenticated users 
Rem    evoss       06/08/07 - Add scheduler feature usage support
Rem    mlfeng      05/22/07 - more information for tablespaces
Rem    siroych     05/22/07 - fix errors in Auto SGA/MEM procedures
Rem    sdizdar     05/13/07 - bug-6040046: add tracking for backup compression
Rem    soye        04/25/07 - #5599389: add failgroup info to ASM tracking
Rem    dolin       04/10/07 - Update feature usage for interMedia->Multimedia
Rem                         - interMedia DICOM->DICOM
Rem    rmir        11/19/06 - Bug 5570546, VPD feature usage query correction
Rem    gstredie    02/19/07 - Add tracking for heap compression
Rem    siroych     04/13/07 - bug 5868103: fix feature usage for ASMM
Rem    vakrishn    02/27/07 - Flashback Data Archive feature usage
Rem    mlfeng      03/28/07 - add feature usage capture for baselines
Rem    veeve       02/26/07 - add db usage for workload capture and replay
Rem    hchatter    03/09/07 - 5868117: correctly report IPQ usage
Rem    amadan      02/19/07 - bug 5570961: fix db feature usage for stream
Rem    pbelknap    02/24/07 - lrg 2875206 - add nvl to asta query
Rem    ychan       02/13/07 - Support em feature usage
Rem    jsoule      01/25/07 - add db usage for metric baselines
Rem    pbelknap    02/12/07 - add projected db time saved for auto sta
Rem    ilistvin    01/24/07 - add autotask clients
Rem    weizhang    01/29/07 - add tracking for auto segadv and shrink
Rem    pbelknap    01/12/07 - split STS usage into system and user
Rem    sackulka    01/22/07 - Usage tracking for securefiles
Rem    kyagoub     12/28/06 - add db usage for SQL replay advisor
Rem    suelee      01/02/07 - Disable IORM
Rem    ilistvin    11/15/06 - move procedure invokations to execsvrm.sql
Rem    mannamal    12/21/06 - Fix the problems caused by merge (lrg 2750790)
Rem    shsong      11/01/06 - Add tracking for recovery layer
Rem    achaudhr    12/05/06 - Result_Cache: Add feature tracking
Rem    yohu        12/06/06 - use sysstat instead of inststat 
Rem    sltam       11/13/06 - count service with goal = null
Rem    sltam       10/30/06 - dbms_feature_services - Handle if db_domain 
Rem                           is not set
Rem    rvenkate    10/25/06 - enhance service usage tracking
Rem    mannamal    10/31/06 - Add tracking for semantics/RDF
Rem    yohu        11/21/06 - add tracking for XA/RAC (clusterwide global txn)
Rem    ddas        10/27/06 - rename OPM to SPM
Rem    msakayed    10/17/06 - add tracking for loader/datapump/metadata api
Rem    jdavison    10/19/06 - Add more Data Guard feature info
Rem    mbrey       10/09/06 - add support for CDC
Rem    sbodagal    10/03/06 - add support for Materialized Views (user)
Rem    soye        10/05/06 - #5582564: add more ASM usage tracking
Rem    jdavison    10/10/06 - Modify Data Guard features
Rem    kigoyal     10/11/06 - add cache features
Rem    suelee      10/02/06 - Track IORM
Rem    molagapp    10/06/06 - track usage of BMR and rollforward
Rem    dolin       10/10/06 - add interMedia feature
Rem    rmir        09/27/06 - 5566035,add Transparent Database Encryption
Rem                           feature
Rem    jstraub     10/04/06 - Changed registering of Application Express per
Rem                           mfeng comments
Rem    jstraub     10/02/06 - add Application Express
Rem    bspeckha    09/26/06 - add workspace manager feature
Rem    ayalaman    09/26/06 - tracking for RUL and EXF components
Rem    oshiowat    09/18/06 - bug5385695 - add oracle text
Rem    amozes      09/25/06 - add support for data mining
Rem    molagapp    09/25/06 - add data repair advisor
Rem    ddas        09/07/06 - register optimizer plan management feature
Rem    xbarr       06/06/06 - remove DMSYS entries for Data Mining 
Rem    qyu         05/11/06 - add more xml in xdb 
Rem    mrafiq      03/22/06 - number of resources changed 
Rem    mlfeng      01/18/06 - add flag to USER_TABLES highwater mark for 
Rem                           recycle bin 
Rem    vkapoor     12/23/05 - Number of resources changed 
Rem    qyu         12/15/05 - add xml, lob, object and extensibility feature 
Rem    mrafiq      08/18/05 - adding XDB feature 
Rem    swerthei    08/15/05 - add backup encryption
Rem    swerthei    08/15/05 - add Oracle Secure Backup 
Rem    yuli        07/21/05 - remove standby unprotected mode feature 
Rem    mlfeng      05/16/05 - upper to values 
Rem    mlfeng      05/09/05 - fix spatial query 
Rem    rpang       02/18/05 - 4148642: long report in dbms_feature_plsql_native
Rem    pokumar     08/11/04 - change query for Dynamic SGA feature usage
Rem    fayang      08/02/04 - add CSSCAN features usage detection 
Rem    bpwang      08/03/04 - lrg 1726108:  disregard wmsys in streams query
Rem    jywang      08/02/04 - Add temp tbs into DBFUS_LOCALLY_MANAGED_USER_STR 
Rem    ckearney    07/29/04 - fix Olap Cube SQL to match how it is populated 
Rem    pokumar     05/20/04 - change query for Dynamic SGA feature usage 
Rem    veeve       04/28/04 - Populate CLOB column for ADDM
Rem    mrhodes     02/25/04 - OSM->ASM 
Rem    mlfeng      01/14/04 - tune high water mark queries 
Rem    mkeihl      11/10/03 - Bug 3238893: Fix RAC feature usage tracking 
Rem    mlfeng      11/05/03 - add tracking for SQL Tuning Set, AWR 
Rem    gmulagun    10/28/03 - improve performance of audit query 
Rem    mlfeng      10/30/03 - add ASM tracking, services HWM
Rem    mlfeng      10/30/03 - track system/user
Rem    jwlee       10/16/03 - add flashback database feature 
Rem    ckearney    10/08/03 - fix owner of DBA_OLAP2_CUBES
Rem    hbaer       09/30/03 - lrg1578529 
Rem    esoyleme    09/22/03 - change analytic workspace query 
Rem    mlfeng      09/05/03 - change HDM -> ADDM, OMF logic 
Rem    rpang       08/15/03 - Tune SQL for PL/SQL NCOMP sampling
Rem    bpwang      08/08/03 - bug 2993461:  updating streams query
Rem    hbaer       07/31/03 - fix bug 3074607 
Rem    rsahani     07/29/03 - enable SQL TUNING ADVISOR
Rem    myechuri    07/10/03 - change file mapping query
Rem    gngai       07/15/03 - seed db register
Rem    mlfeng      07/02/03 - change high water mark statistics logic
Rem    sbalaram    06/19/03 - Bug 2993464: fix usage query for adv. replication
Rem    tbosman     05/13/03 - add cpu count tracking
Rem    rpang       05/21/03 - Fixed PL/SQL native compilation
Rem    mlfeng      05/02/03 - change unused aux_count from 0 to null
Rem    xcao        05/22/03 - modify Messaging Gateway usage registration
Rem    aime        04/25/03 - aime_going_to_main
Rem    rjanders    03/11/03 - Correct 'standby archival' query for beta1
Rem    mpoladia    03/11/03 - Change audit options query
Rem    dwildfog    03/10/03 - Enable tracking for several advisors
Rem    swerthei    03/07/03 - fix RMAN usage queries
Rem    hbaer       03/07/03 - adjust dbms_feature_part for cdc tables
Rem    mlfeng      02/20/03 - Change name of oracle label security
Rem    wyang       03/06/03 - enable tracking undo advisor
Rem    mlfeng      02/07/03 - Add PL/SQL native and interpreted tracking
Rem    mlfeng      01/31/03 - Add test flag to test features and hwm
Rem    mlfeng      01/23/03 - Updating Feature Names and Descriptions
Rem    mlfeng      01/13/03 - DB Feature Usage
Rem    mlfeng      01/08/03 - Comments for registering DB Features and HWM
Rem    mlfeng      01/08/03 - Added Partitioning procedure and test procs
Rem    mlfeng      11/07/02 - Registering more features
Rem    mlfeng      11/05/02 - Created
Rem


  -- ******************************************************** 
  --  To register a database feature, the following procedure 
  --  is used (A more detailed description of the input
  --  parameters is given in the dbmsfus.sql file):
  --
  --    procedure REGISTER_DB_FEATURE 
  --       ( feature_name           IN VARCHAR2,
  --         install_check_method   IN INTEGER,
  --         install_check_logic    IN VARCHAR2,
  --         usage_detection_method IN INTEGER,
  --         usage_detection_logic  IN VARCHAR2,
  --         feature_description    IN VARCHAR2);
  --
  --  Input arguments:
  --   feature_name           - name of feature
  --   install_check_method   - how to check if the feature is installed.
  --                            currently support the values:
  --                            DBU_INST_ALWAYS_INSTALLED, DBU_INST_OBJECT
  --   install_check_logic    - logic used to check feature installation.
  --                            if method is DBU_INST_ALWAYS_INSTALLED, 
  --                            this argument will take the NULL value.
  --                            if method is DBU_INST_OBJECT, this argument 
  --                            will take the owner and object name for
  --                            an object that must exist if the feature has 
  --                            been installed.
  --   usage_detection_method - how to capture the feature usage, either
  --                            DBU_DETECT_BY_SQL, DBU_DETECT_BY_PROCEDURE, 
  --                            DBU_DETECT_NULL
  --   usage_detection_logic  - logic used to detect usage.  
  --                            If method is DBU_DETECT_BY_SQL, logic will 
  --                            SQL statement used to detect usage.
  --                            If method is DBU_DETECT_BY_PROCEDURE, logic
  --                            will be PL/SQL procedure used to detect usage.
  --                            If method is DBU_DETECT_NULL, this argument
  --                            will not be used. Usage is not tracked.
  --   feature_description    - Description of feature
  --
  --
  --  Examples:
  --
  --  To register the Label Security feature (an install check
  --  is required and the detection method is to use a SQL query), 
  --  the following is used:
  --  
  --  declare
  --   DBFUS_LABEL_SECURITY_STR CONST VARCHAR2(1000) :=
  --       'select count(*), 0, NULL from lbacsys.lbac$polt ' ||
  --        'where owner != ''SA_DEMO''';
  --
  --  begin
  --   dbms_feature_usage.register_db_feature
  --      ('Label Security',
  --       dbms_feature_usage.DBU_INST_OBJECT, 
  --       'LBACSYS.lbac$polt',
  --       dbms_feature_usage.DBU_DETECT_BY_SQL,
  --       DBFUS_LABEL_SECURITY_STR,
  --       'Oracle 9i database security option');
  --  end;
  --
  --  To register the Partitioning feature (an install check is not
  --  required and the detection method is to use a PL/SQL procedure),
  --  the following is used:
  --
  --  declare
  --   DBFUS_PARTN_USER_PROC CONST VARCHAR2(1000) :=
  --       'DBMS_FEATURE_PARTITION_USER';
  --
  --  begin
  --   dbms_feature_usage.register_db_feature
  --      ('Partitioning (user)',
  --       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
  --       NULL,
  --       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
  --       DBFUS_PARTN_USER_PROC,
  --       'Partitioning');
  --  end;
  -- ******************************************************** 


  -- ******************************************************** 
  --  To register a high water mark, the following procedure 
  --  is used (A more detailed description of the input
  --  parameters is given in the dbmsfus.sql file):
  -- 
  --    procedure REGISTER_HIGH_WATER_MARK
  --       ( hwm_name   IN VARCHAR2,
  --         hwm_method IN INTEGER,
  --         hwm_logic  IN VARCHAR2,
  --         hwm_desc   IN VARCHAR2);
  --
  --  Input arguments:
  --   hwm_name   - name of high water mark
  --   hwm_method - how to compute the high water mark, either
  --                DBU_HWM_BY_SQL, DBU_HWM_BY_PROCEDURE, or DBU_HWM_NULL
  --   hwm_logic  - logic used for high water mark.
  --                If method is DBU_HWM_BY_SQL, this argument will be SQL 
  --                statement used to compute hwm.
  --                If method is DBU_HWM_BY_PROCEDURE, this argument will be
  --                PL/SQL procedure used to compute hwm.
  --                If method is DBU_HWM_NULL, this argument will not be
  --                used. The high water mark will not be tracked.
  --   hwm_desc   - Description of high water mark
  --
  -- 
  --  Example:
  --
  --  To register the number of user tables (method is SQL), the 
  --  following is used:
  --
  --  declare
  --   HWM_USER_TABLES_STR CONST VARCHAR2(1000) :=
  --       'select count(*) from dba_tables where owner not in ' ||
  --       '(''SYS'', ''SYSTEM'')';
  --
  --  begin
  --   dbms_feature_usage.register_high_water_mark
  --      ('USER_TABLES',
  --       dbms_feature_usage.DBU_HWM_BY_SQL,
  --       HWM_USER_TABLES_STR,
  --       'Number of User Tables');
  --  end;
  -- ******************************************************** 




Rem *********************************************************
Rem Procedures used by the Features to Track Usage
Rem *********************************************************

/***************************************************************
 * DBMS_FEATURE_ASM
 *  The procedure to detect usage for ASM
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_asm
      (is_used OUT number, total_diskgroup_size OUT number, summary OUT clob)
AS
   redundancy_type    clob;
   max_diskgroup_size number;
   min_diskgroup_size number;
   num_disk           number;
   num_diskgroup      number;
   min_disk_size      number;
   max_disk_size      number;
   num_failgroup      number;
   min_failgroup_size number;
   max_failgroup_size number;

BEGIN
  -- initialize
  redundancy_type      := 'Redundancy';
  max_diskgroup_size   := NULL;
  min_diskgroup_size   := NULL;
  total_diskgroup_size := NULL;
  num_disk             := NULL;
  num_diskgroup        := NULL;
  min_disk_size        := NULL;  
  max_disk_size        := NULL;
  num_failgroup        := NULL;
  min_failgroup_size   := NULL;
  max_failgroup_size   := NULL;

  select count(*) into is_used from v$asm_client; 
  -- if asm is used 
  if (is_used >= 1) then

       select max(total_mb), min(total_mb), sum(total_mb), count(*)
         into max_diskgroup_size, min_diskgroup_size, 
              total_diskgroup_size, num_diskgroup
         from v$asm_diskgroup;

       select max(total_mb), min(total_mb), count(*)
         into max_disk_size, min_disk_size, num_disk
         from v$asm_disk;

       select max(total_fg_mb), min(total_fg_mb), count(*)
         into max_failgroup_size, min_failgroup_size, num_failgroup
         from (select sum(total_mb) as total_fg_mb 
                 from v$asm_disk 
                 group by failgroup);

                               
                        
       for item in (select type, count(*) as rcount from v$asm_diskgroup group by type)
       loop
         redundancy_type:=redundancy_type||':'||item.type||'='||item.rcount;
       end loop;

       summary :=redundancy_type||':total_diskgroup_size:'||total_diskgroup_size
                ||':max_diskgroup_size:'||max_diskgroup_size
                ||':min_diskgroup_size:'||min_diskgroup_size
                ||':num_diskgroup:'||num_diskgroup
                ||':max_disk_size:'||max_disk_size
                ||':min_disk_size:'||min_disk_size
                ||':num_disk:'||num_disk
                ||':max_failgroup_size:'||max_failgroup_size
                ||':min_failgroup_size:'||min_failgroup_size
                ||':num_failgroup:'||num_failgroup;

  end if;
END;
/

/***************************************************************
 * DBMS_FEATURE_AUTOSTA
 *  The procedure to detect usage for Automatic SQL Tuning
 ***************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_autosta
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  asqlt_task_name    VARCHAR2(30) := 'SYS_AUTO_SQL_TUNING_TASK';

  execs_since_sample NUMBER;                  -- # of execs since last sample
  total_execs        NUMBER;                  -- number of task executions 
  w_auto_impl        NUMBER;                  -- execs with AUTO implement on
  profs_rec          NUMBER;                  -- total profiles in task
  savedsecs          NUMBER;                  -- db time saved (s)
  tmp_buf            VARCHAR2(32767);         -- temp buffer
BEGIN

  /*
   * We compute the following stats for db feature usage:
   *   Number of executions since last sample (execs_since_sample)
   *   Total number of executions in the task (total_execs)
   *   Total number of executions with auto-implement ON (w_auto_impl)
   *   Total number of SQL profiles recommended in the task (profs_rec)
   *   Projected DB Time Saved through Auto Implementation (savedsecs)
   *
   * Note that these stats are only computed through looking at the task,
   * which, by default, stores results from the last month of history only.
   */

  -- execs since last sample
  SELECT count(*)
  INTO   execs_since_sample 
  FROM   dba_advisor_executions 
  WHERE  task_name = asqlt_task_name AND 
         execution_last_modified >= (SELECT nvl(max(last_sample_date),
                                                sysdate-7) 
                                     FROM   dba_feature_usage_statistics);
  
  -- total # of executions
  SELECT count(*) 
  INTO   total_execs
  FROM   dba_advisor_executions 
  WHERE  task_name = asqlt_task_name;

  -- #execs with auto implement ON
  SELECT count(*) 
  INTO   w_auto_impl
  FROM   dba_advisor_exec_parameters 
  WHERE  task_name = asqlt_task_name AND 
         parameter_name = 'ACCEPT_SQL_PROFILES' AND 
         parameter_value = 'TRUE';

  -- total profiles recommended so far
  SELECT count(*) 
  INTO   profs_rec
  FROM   dba_advisor_recommendations r 
  WHERE  r.task_name = asqlt_task_name AND
         r.type = 'SQL PROFILE';

  -- db time saved by AUTO impl profiles
  SELECT round(nvl(sum(before_usec - after_usec)/1000000, 0))
  INTO   savedsecs 
  FROM   (SELECT nvl(o.attr8, 0) before_usec, 
                 nvl(o.attr8, 0) * (1 - r.benefit/10000) after_usec
          FROM   dba_sql_profiles sp,
                 dba_advisor_objects o,
                 dba_advisor_findings f,
                 dba_advisor_recommendations r
          WHERE  o.task_name = asqlt_task_name AND
                 o.type = 'SQL' AND
                 sp.task_id = o.task_id AND
                 sp.task_obj_id = o.object_id AND
                 sp.task_exec_name = o.execution_name AND
                 o.task_id = f.task_id AND 
                 o.execution_name = f.execution_name AND
                 o.object_id = f.object_id AND
                 f.finding_id = sp.task_fnd_id AND
                 r.task_id = f.task_id AND
                 r.execution_name = f.execution_name AND
                 r.finding_id = f.finding_id AND
                 r.rec_id = sp.task_rec_id AND
                 sp.type = 'AUTO');

  -- the used boolean and aux count we set to the number of execs since last
  -- sample
  feature_boolean := execs_since_sample;
  aux_count := execs_since_sample;

  -- compose the CLOB
  tmp_buf := 'Execution count so far: '          || total_execs || ', ' ||
             'Executions with auto-implement: '  || w_auto_impl || ', ' ||
             'SQL profiles recommended so far: ' || profs_rec   || ', ' ||
             'Projected DB Time Saved Automatically (s): ' || savedsecs;

  dbms_lob.createtemporary(feature_info, TRUE);
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);

END dbms_feature_autosta;
/


/************************************************************************
 * DBMS_FEATURE_STATS_INCREMENTAL
 *  The procedure to detect usage for statistics incremental maintenance
 ***********************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_stats_incremental
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  im_preference      VARCHAR2(30) := 'INCREMENTAL';
  global_on          VARCHAR2(20);
  table_im_on        NUMBER;
  table_im_off       NUMBER;
  stats_gathered_im  NUMBER;
  tmp_buf            VARCHAR2(32767);   
BEGIN

  /*
   * We compute the following stats for db feature usage:
   *   whether global preference of incremental maintenance turned on
   *   # of tables with table level incremental maintenance preference 
   *     turned on
   *   # of tables with table level incremental maintenance preference 
   *     turned off
   *   # of tables that have had stats gathered in incremental mode
   */

  --whether global preference of incremental maintenance turned on
  SELECT decode(count(*), 0, 'FALSE', 'TRUE')
  INTO   global_on  
  FROM   dual
  WHERE  dbms_stats.get_prefs(im_preference) = 'TRUE';

  --# of tables with table level incremental maintenance preference 
  -- turned on
  SELECT count(*)
  INTO   table_im_on
  FROM   all_tab_stat_prefs
  WHERE  PREFERENCE_NAME = im_preference and PREFERENCE_VALUE = 'TRUE';

  -- # of tables with table level incremental maintenance preference 
  -- turned off
  SELECT count(*)
  INTO   table_im_off
  FROM   all_tab_stat_prefs
  WHERE  PREFERENCE_NAME = im_preference and PREFERENCE_VALUE = 'FALSE';

  -- # of tables that have had stats gathered in incremental mode
  SELECT distinct count(bo#)
  INTO   stats_gathered_im
  FROM   sys.wri$_optstat_synopsis_head$
  WHERE  analyzetime is not null;

  -- the used boolean and aux count we set to the number of execs since last
  -- sample
  feature_boolean := stats_gathered_im;
  aux_count := stats_gathered_im;

  -- compose the CLOB
  tmp_buf := 'Incremental global preference on : ' || global_on || ', ' ||
    'Number of tables with table level incremental maintenance preference ' ||
      'turned on: ' || table_im_on || ', ' ||
    'Number of tables with table level incremental maintenance preference ' ||
      'turned off: ' || table_im_off || ', ' ||
    'Number of tables that have had statistics gathered in incremental mode: ' || 
      stats_gathered_im;

  dbms_lob.createtemporary(feature_info, TRUE);
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);

END dbms_feature_stats_incremental;
/

/***************************************************************
 * DBMS_FEATURE_WCR_CAPTURE
 *  The procedure to detect usage for Workload Capture
 ***************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_wcr_capture
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  prev_sample_count     NUMBER;
  prev_sample_date      DATE;
  prev_sample_date_dbtz DATE;
  date_format           CONSTANT VARCHAR2(64) := 'YYYY:MM:DD HH24:MI:SS';

  captures_since     NUMBER;             -- # of captures since last sample
BEGIN

  /*
   * We compute the total number of captures done on the 
   * current database by finding the number of captures done
   * since the last sample and adding it to the current aux_count.
   */

  -- Find prev_sample_count and prev_sample_date first
  select nvl(max(aux_count), 0), nvl(max(last_sample_date), sysdate-7)
  into   prev_sample_count, prev_sample_date
  from   dba_feature_usage_statistics
  where  name = 'Database Replay: Workload Capture';

  -- convert date to db timezone
  select to_date(to_char(from_tz(cast(prev_sample_date as timestamp), 
         sessiontimezone) at time zone dbtimezone, date_format), 
         date_format) into prev_sample_date_dbtz from dual;

  -- Find # of workload captures since last sample in current DB
  select count(*)
  into   captures_since
  from   dba_workload_captures
  where  (prev_sample_date_dbtz is null OR start_time > prev_sample_date_dbtz)
   and   dbid = (select dbid from v$database);

  -- Mark boolean to be captures_since
  feature_boolean := captures_since;
  -- Add current aux_count with captures_since for new value
  aux_count       := prev_sample_count + captures_since;
  -- Feature_info not used
  feature_info    := NULL;

END dbms_feature_wcr_capture;
/

show errors;
/

/***************************************************************
 * DBMS_FEATURE_WCR_REPLAY
 *  The procedure to detect usage for Workload Replay
 *  Almost Verbatim to DBMS_FEATURE_WCR_CAPTURE
 ***************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_wcr_replay
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  prev_sample_count     NUMBER;
  prev_sample_date      DATE;
  prev_sample_date_dbtz DATE;
  date_format           CONSTANT VARCHAR2(64) := 'YYYY:MM:DD HH24:MI:SS';

  replays_since      NUMBER;             -- # of replays since last sample
BEGIN

  /*
   * We compute the total number of replays done on the 
   * current database by finding the number of replays done
   * since the last sample and adding it to the current aux_count.
   */

  -- Find prev_sample_count and prev_sample_date first
  select nvl(max(aux_count), 0), nvl(max(last_sample_date), sysdate-7)
  into   prev_sample_count, prev_sample_date
  from   dba_feature_usage_statistics
  where  name = 'Database Replay: Workload Replay';

  -- convert date to db timezone
  select to_date(to_char(from_tz(cast(prev_sample_date as timestamp), 
         sessiontimezone) at time zone dbtimezone, date_format), 
         date_format) into prev_sample_date_dbtz from dual;

  -- Find # of workload replays since last sample in current DB
  select count(*)
  into   replays_since
  from   dba_workload_replays
  where  (prev_sample_date_dbtz is null OR start_time > prev_sample_date_dbtz)
    and  dbid = (select dbid from v$database);

  -- Mark boolean to be replays_since
  feature_boolean := replays_since;
  -- Add current aux_count with replays_since for new value
  aux_count       := prev_sample_count + replays_since;
  -- Feature_info not used
  feature_info    := NULL;

END dbms_feature_wcr_replay;
/

show errors;
/

/***************************************************************
 * DBMS_FEATURE_PARTITION_USER
 *  The procedure to detect usage for Partitioning (user)
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_partition_user
      (is_used OUT number, data_ratio OUT number, clob_rest OUT clob)
AS  
BEGIN
  -- initialize
  is_used := 0;
  data_ratio := 0;
  clob_rest := NULL;

  FOR crec IN (select num||':'||idx_or_tab||':'||ptype||':'||subptype||':'||pcnt||':'||subpcnt||':'||
                      pcols||':'||subpcols||':'||idx_flags||':'||
                      idx_type||':'||idx_uk||'|' my_string
               from (select * from
                     (select /*+ full(o) */ dense_rank() over 
                             (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM, 
                      decode(o.type#,1,'I',2,'T',null) IDX_OR_TAB, 
                      is_xml ||
                      decode(p.parttype, 1, case when bitand(p.flags,64)=64 then 'INTERVAL' 
                                                 else 'RANGE' end 
                                         ,2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 5, 'REF'
                                         ,p.parttype||'-?') ||
                      decode(bitand(p.flags,32),32,' (PARENT)') PTYPE, 
                      decode(mod(p.spare2, 256), 0, null, 1, 'RANGE', 2, 'HASH', 3,'SYSTEM' 
                                                    , 4, 'LIST', 5, 'REF' 
                                                    , p.spare2||'-?') SUBPTYPE,
                      p.partcnt  || 
                      case when bitand(p.flags,64)=64 then '-' || op.xnumpart 
                      end  PCNT, 
                      case mod(trunc(p.spare2/65536), 65536) 
                           when 0 then null
                           else mod(trunc(p.spare2/65536), 65536) ||'-'|| osp.numsubpart end SUBPCNT,
                      p.partkeycols PCOLS, 
                      case mod(trunc(p.spare2/256), 256) 
                           when 0 then null 
                           else mod(trunc(p.spare2/256), 256) end SUBPCOLS,
                      case when bitand(p.flags,1) = 1 then 
                                case when bitand(p.flags,2) = 2 then 'LP'
                                      else 'L' end
                           when bitand(p.flags,2) = 2 then 'GP' 
                      end IDX_FLAGS,
                      decode(i.type#, 1, 'NORMAL'||
                                     decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN')  || 
                       case when bitand(i.property,16) = 16 then '-FUNC' end IDX_TYPE,
                      decode(i.property, null,null,
                                         decode(bitand(i.property, 1), 0, 'NU', 
                                         1, 'U', '?')) IDX_UK
                      from partobj$ p, obj$ o, user$ u, ind$ i, 
                           ( select distinct obj#, 'XML-' as is_xml from opqtype$ where type=1) xml,
                           ( select /* NO_MERGE FULL(tsp) FULL(tcp) */ tcp.bo#, count(*) numsubpart
                             from tabsubpart$ tsp, tabcompart$ tcp 
                             where tcp.obj# = tsp.pobj# 
                             group by tcp.bo#
                             union all
                             select /* NO_MERGE FULL(isp) FULL(icp) */ icp.bo#, count(*) numsubpart
                             from indsubpart$ isp, indcompart$ icp 
                             where icp.obj# = isp.pobj# 
                             group by icp.bo#) osp,
                           ( select tp.bo#, count(*) xnumpart
                             from tabpart$ tp
                             group by tp.bo#
                             union all
                             select ip.bo#, count(*) xnumpart
                             from indpart$ ip
                             group by ip.bo#) op                            
                      where o.obj# = i.obj#(+)
                      and   o.owner# = u.user# 
                      and   p.obj# = o.obj#
                      and   p.obj# = xml.obj#(+)
                      and   p.obj# = osp.bo#(+) 
                      and   p.obj# = op.bo#(+)
                      and   u.name not in ('SYS','SYSTEM','SH','SYSMAN')
                      -- fix bug 3074607 - filter on obj$
                      and o.type# in (1,2,19,20,25,34,35)
                      -- exclude flashback data archive  tables
                      and upper(o.name) not like 'SYS_FBA%'
                      -- exclude change tables
                      and o.obj# not in ( select obj# from cdc_change_tables$)
                      -- exclude local partitioned indexes on change tables
                      and i.bo# not in  ( select obj# from cdc_change_tables$)
                union all
                -- global nonpartitioned indexes on partitioned tables
                select dense_rank() over (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM,
                       'I' IDX_OR_TAB,
                        null,null,null,null,
                        case cols when 0 then null
                                  else cols end PCOLS,null,
                       'GNP' IDX_FLAGS, 
                       decode(i.type#, 1, 'NORMAL'||
                                      decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                                      9, 'DOMAIN') ||
                       case when bitand(i.property,16) = 16 then '-FUNC' end IDX_TYPE,
                       decode(i.property, null,null,
                                          decode(bitand(i.property, 1), 0, 'NU', 
                                          1, 'U', '?')) IDX_UK
                from partobj$ p, user$ u, obj$ o, ind$ i
                where p.obj# = i.bo#
                -- exclude global nonpartitioned indexes on change tables
                and   i.bo# not in  ( select obj# from cdc_change_tables$)
                -- exclude flashback data archive  tables
                and   upper(o.name) not like 'SYS_FBA%'
                and   o.owner# = u.user# 
                and   p.obj# = o.obj# 
                and   p.flags =0
                and   bitand(i.property, 2) <>2
                and   u.name not in ('SYS','SYSTEM','SH','SYSMAN'))
                order by num, idx_or_tab desc )) LOOP

     if (is_used = 0) then
       is_used:=1;
     end if;  

     clob_rest := clob_rest||crec.my_string;
   end loop;

   if (is_used = 1) then
     select pcnt into data_ratio
     from
     (
       SELECT c1, TRUNC((ratio_to_report(sum_blocks) over())*100,2) pcnt  
       FROM
       (
        select decode(p.obj#,null,'REST','PARTTAB') c1, sum(s.blocks) sum_blocks
        from tabpart$ p, seg$ s
        where s.file#=p.file#(+)
        and s.block#=p.block#(+)
        and s.type#=5
        group by  decode(p.obj#,null,'REST','PARTTAB')
        )
      )
      where c1 = 'PARTTAB';
   end if;
end;
/

/***************************************************************
 * DBMS_FEATURE_PARTITION_SYSTEM
 *  The procedure to detect usage for Partitioning (system)
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_partition_system
      (is_used OUT number, data_ratio OUT number, clob_rest OUT clob)
AS  
BEGIN
  -- initialize
  is_used := 0;
  data_ratio := 0;
  clob_rest := NULL;

  FOR crec IN (select num||':'||idx_or_tab||':'||ptype||':'||subptype||':'||pcnt||':'||subpcnt||':'||
                      pcols||':'||subpcols||':'||idx_flags||':'||
                      idx_type||':'||idx_uk||'|' my_string
               from (select * from
                     (select /*+ full(o) */ dense_rank() over 
                             (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM, 
                      decode(o.type#,1,'I',2,'T',null) IDX_OR_TAB, 
                      is_xml ||
                      decode(p.parttype, 1, case when bitand(p.flags,64)=64 then 'INTERVAL' 
                                                 else 'RANGE' end 
                                         ,2, 'HASH', 3, 'SYSTEM', 4, 'LIST', 5, 'REF'
                                         ,p.parttype||'-?') ||
                      decode(bitand(p.flags,32),32,' (PARENT)') PTYPE, 
                      decode(mod(p.spare2, 256), 0, null, 1, 'RANGE', 2, 'HASH', 3,'SYSTEM' 
                                                    , 4, 'LIST', 5, 'REF' 
                                                    , p.spare2||'-?') SUBPTYPE,
                      p.partcnt  || 
                      case when bitand(p.flags,64)=64 then '-' || op.xnumpart 
                      end  PCNT, 
                      case mod(trunc(p.spare2/65536), 65536) 
                           when 0 then null
                           else mod(trunc(p.spare2/65536), 65536) ||'-'|| osp.numsubpart end SUBPCNT,
                      p.partkeycols PCOLS, 
                      case mod(trunc(p.spare2/256), 256) 
                           when 0 then null 
                           else mod(trunc(p.spare2/256), 256) end SUBPCOLS,
                      case when bitand(p.flags,1) = 1 then 
                                case when bitand(p.flags,2) = 2 then 'LP'
                                      else 'L' end
                           when bitand(p.flags,2) = 2 then 'GP' 
                      end IDX_FLAGS,
                      decode(i.type#, 1, 'NORMAL'||
                                     decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                      9, 'DOMAIN')  || 
                       case when bitand(i.property,16) = 16 then '-FUNC' end IDX_TYPE,
                      decode(i.property, null,null,
                                         decode(bitand(i.property, 1), 0, 'NU', 
                                         1, 'U', '?')) IDX_UK
                      from partobj$ p, obj$ o, user$ u, ind$ i, 
                           ( select distinct obj#, 'XML-' as is_xml from opqtype$ where type=1) xml,
                           ( select /* NO_MERGE FULL(tsp) FULL(tcp) */ tcp.bo#, count(*) numsubpart
                             from tabsubpart$ tsp, tabcompart$ tcp 
                             where tcp.obj# = tsp.pobj# 
                             group by tcp.bo#
                             union all
                             select /* NO_MERGE FULL(isp) FULL(icp) */ icp.bo#, count(*) numsubpart
                             from indsubpart$ isp, indcompart$ icp 
                             where icp.obj# = isp.pobj# 
                             group by icp.bo#) osp,
                           ( select tp.bo#, count(*) xnumpart
                             from tabpart$ tp
                             group by tp.bo#
                             union all
                             select ip.bo#, count(*) xnumpart
                             from indpart$ ip
                             group by ip.bo#) op                            
                      where o.obj# = i.obj#(+)
                      and   o.owner# = u.user# 
                      and   p.obj# = o.obj#
                      and   p.obj# = xml.obj#(+)
                      and   p.obj# = osp.bo#(+) 
                      and   p.obj# = op.bo#(+)
                      -- fix bug 3074607 - filter on obj$
                      and o.type# in (1,2,19,20,25,34,35)
                union all
                -- global nonpartitioned indexes on partitioned tables
                select dense_rank() over (order by  decode(i.bo#,null,p.obj#,i.bo#)) NUM,
                       'I' IDX_OR_TAB,
                        null,null,null,null,
                        case cols when 0 then null
                                  else cols end PCOLS,null,
                       'GNP' IDX_FLAGS, 
                       decode(i.type#, 1, 'NORMAL'||
                                      decode(bitand(i.property, 4), 0, '', 4, '/REV'),
                                      2, 'BITMAP', 3, 'CLUSTER', 4, 'IOT - TOP',
                                      5, 'IOT - NESTED', 6, 'SECONDARY', 7, 'ANSI', 8, 'LOB',
                                      9, 'DOMAIN') ||
                       case when bitand(i.property,16) = 16 then '-FUNC' end IDX_TYPE,
                       decode(i.property, null,null,
                                          decode(bitand(i.property, 1), 0, 'NU', 
                                          1, 'U', '?')) IDX_UK
                from partobj$ p, user$ u, obj$ o, ind$ i
                where p.obj# = i.bo#
                and   o.owner# = u.user# 
                and   p.obj# = o.obj# 
                and   p.flags =0
                and   bitand(i.property, 2) <>2
                )
                order by num, idx_or_tab desc )) LOOP

     if (is_used = 0) then
       is_used:=1;
     end if;  

     clob_rest := clob_rest||crec.my_string;
   end loop;

   if (is_used = 1) then
     select pcnt into data_ratio
     from
     (
       SELECT c1, TRUNC((ratio_to_report(sum_blocks) over())*100,2) pcnt  
       FROM
       (
        select decode(p.obj#,null,'REST','PARTTAB') c1, sum(s.blocks) sum_blocks
        from tabpart$ p, seg$ s
        where s.file#=p.file#(+)
        and s.block#=p.block#(+)
        and s.type#=5
        group by  decode(p.obj#,null,'REST','PARTTAB')
        )
      )
      where c1 = 'PARTTAB';
   end if;
end;
/

/***************************************************************
 * DBMS_FEATURE_PLSQL_NATIVE
 *  The procedure to detect usage for PL/SQL Native
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_plsql_native (
  o_is_used     OUT           number,
  o_aux_count   OUT           number, -- not used, set to zero
  o_report      OUT           clob )

  --
  -- Find ncomp usage from ncomp_dll$
  --
  -- When >0 NATIVE units, sets "o_is_used=1". Always generates XML report,
  -- for example...
  --
  -- <plsqlNativeReport date ="04-feb-2003 14:34">
  -- <owner name="1234" native="2" interpreted="1"/>
  -- <owner name="1235" native="10" interpreted="1"/>
  -- <owner name="CTXSYS" native="118"/>
  -- ...
  -- <owner name="SYS" native="1292" interpreted="6"/>
  -- <owner name="SYSTEM" native="6"/>
  -- ...
  -- <owner name="XDB" native="176"/>
  -- </plsqlNativeReport>
  --

is
  YES      constant number := 1;
  NO       constant number := 0;
  NEWLINE  constant varchar2(2 char) := '
';
  v_date   constant varchar2(30) := to_char(sysdate, 'dd-mon-yyyy hh24:mi');
  v_report          varchar2(400); -- big enough to hold one "<owner .../>"
begin

  o_is_used   := NO;
  o_aux_count := 0;
  o_report    := '<plsqlNativeReport date ="' || v_date || '">' || NEWLINE;

  -- For security and privacy reasons, we do not collect the names of the
  -- non-Oracle schemas. In the case statement below, we filter the schema
  -- names against v$sysaux_occupants, which contains the list of Oracle
  -- schemas.
  for r in (select (case when u.name in
                              (select distinct schema_name
                                 from v$sysaux_occupants)
                         then u.name
                         else to_char(u.user#)
                    end) name,
              count(o.obj#) total, count(d.obj#) native
              from user$ u, ncomp_dll$ d, obj$ o
              where o.obj# = d.obj# (+)
                and o.type# in (7,8,9,11,12,13,14)
                and u.user# = o.owner#
              group by u.name, u.user#
              order by u.name) loop
    if (r.native > 0) then
      o_is_used := YES;
    end if;
    v_report := '<owner name="'|| r.name || '"';
    if (r.native > 0) then
      v_report := v_report || ' native="' || r.native || '"';
    end if;
    if (r.total > r.native) then
      v_report := v_report || ' interpreted="' || (r.total - r.native) || '"';
    end if;
    v_report := v_report || '/>' || NEWLINE;
    o_report := o_report || v_report;
  end loop;
  o_report := o_report || '</plsqlNativeReport>';
end dbms_feature_plsql_native;
/

/*******************************************************************
 * DBMS_FEATURE_QOSM
 *  The procedure to detect usage for Quality of Service Management
 *******************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_qosm
      (is_used OUT number, aux_count OUT number, feature_info OUT clob)
AS

BEGIN
  -- initialize
  feature_info := NULL;
  aux_count := NULL;

  -- get number of performance classes

  select count(*) into is_used from x$kywmpctab
    where kywmpctabsp not like ':%';

  -- if QOSM is used
  if (is_used >= 1) then

    -- number of Performance Classes
    aux_count := is_used;

  end if;
END;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_RAC
 *  The procedure to detect usage for RAC
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_rac
      (is_used OUT number, nodes OUT number, clob_rest OUT clob)
AS
   cpu_count_current number;
   cpu_stddev_current number;
BEGIN
  -- initialize
  clob_rest := NULL;
  nodes := NULL;
  cpu_count_current := NULL;
  cpu_stddev_current := NULL;

  select count(*) into is_used from v$system_parameter where
     name='cluster_database' and value='TRUE';
   -- if RAC is used see if only active/passive or active/active
   if (is_used = 1) then
       select count(*) into nodes from gv$instance;
       select sum(cpu_count_current), round(stddev(cpu_count_current),1)
          into cpu_count_current, cpu_stddev_current from gv$license;
       -- active_instance_count init.ora has been deprecated
       --   so 'usage:Active Passive' will no longer be returned
       clob_rest:='usage:All Active:cpu_count_current:'||cpu_count_current
                ||':cpu_stddev_current:'||cpu_stddev_current;
  end if;
END;
/

/***************************************************************
 * DBMS_FEATURE_XDB
 *  The procedure to detect usage for XDB
 ***************************************************************/
/*
 * XDB is being used if user has created atleast 1 of the following
 ***** resource in XDB repositor, 
 ***** XML schema, 
 ***** table with XMLType column, or
 ***** view with XMLType column

 * Here is an example of what this procedure puts in OUT var feature_info
<xdb_feature_usage>
  <user_resources>	 2 </user_resources>
  <user_schemas>	 1 </user_schemas>
  <user_SB_columns>	 1 </user_SB_columns>
  <user_NSB_columns>	 7 </user_NSB_columns>
  <user_SB_views>	 0 </user_SB_views>
  <user_NSB_views>	 0 </user_NSB_views>
  <user_OR_cols>	 0 </user_OR_cols>
  <user_CLOB_cols>	 6 </user_CLOB_cols>
  <user_BINARY_cols>	 2 </user_BINARY_cols>
  <all_resconfigs>	 8 </all_resconfigs>
  <all_acls>		 4 </all_acls>
</xdb_feature_usage>

 * Notes:
*/

create or replace procedure DBMS_FEATURE_XDB
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  num_xdb_res           number := 0;
  num_xdb_rc            number := 0;
  num_xdb_acl           number := 0;
  num_xdb_schemas       number := 0;
  num_sb_tbl            number := 0;
  num_xdb_tbl           number := 0;
  num_xdb_vw            number := 0;
  num_nsb_tbl           number := 0;
  num_sb_vw             number := 0;
  num_nsb_vw            number := 0;
  num_st_or             number := 0;
  num_st_lob            number := 0;
  num_st_clob           number := 0;
  num_st_bin            number := 0;
  feature_usage         varchar2(1000);
  TYPE cursor_t         IS REF CURSOR;
  cursor_objtype        cursor_t;
  total_count           number := 0;
  flag                  number := 0;
  objtype               number := 0;
 
begin
    /* get number of non system resources from resource_view */
    execute immediate q'[select count(*) 
    from xdb.xdb$resource e, sys.user$ u 
    where to_number(utl_raw.cast_to_binary_integer(e.xmldata.ownerid)) = 
        u.user# and u.name not in ('XDB', 'SYS', 'MDSYS', 'EXFSYS', 'ORDSYS', 
        'ORDDATA', 'OE', 'SH', 'HR', 'SCOTT') and u.name not like 'APEX_%']'
        into num_xdb_res;

    /* get number of non system xml schemas registered */
    execute immediate q'[select count(*) 
    from dba_xml_schemas 
    where owner not in ('XDB', 'SYS', 'MDSYS', 'EXFSYS', 'ORDSYS', 'ORDDATA',
        'OE', 'SH', 'HR', 'SCOTT') and owner not like 'APEX_%'
    ]' into num_xdb_schemas ;
    
    /* count non system, SB and NSB xml columns */
       OPEN cursor_objtype FOR q'[
             select count(*), o.type#, bitand(p.flags, 2)
             from sys.opqtype$ p, sys.obj$ o, sys.user$ u
             where o.obj# = p.obj# and p.type = 1 and
                   (o.type# = 2 or o.type# = 4) and
                   o.owner# = u.user# and
                   u.name not in ('XDB', 'SYS', 'MDSYS', 'EXFSYS', 'ORDSYS', 
                                  'ORDDATA', 'OE', 'SH', 'HR', 'SCOTT' ) and
                   u.name not like 'APEX_%'
             group by (bitand(p.flags, 2), o.type#)]';

        LOOP
          BEGIN
            FETCH cursor_objtype INTO total_count, objtype, flag;
            EXIT WHEN cursor_objtype%NOTFOUND;


            /* get number of non schema based tables */
            IF (flag = 0) and (objtype = 2) THEN
              num_nsb_tbl := total_count;
            END IF;

            /* get number of non shema based views */
            IF (flag = 0) and (objtype = 4) THEN
              num_nsb_vw := total_count;
            END IF;

            /* get number of schema based tables */
            IF (flag = 2) and (objtype = 2) THEN
              num_sb_tbl := total_count;
            END IF;

            /* get number of schema based views */
            IF (flag = 2) and (objtype = 4) THEN
              num_sb_vw := total_count;
            END IF;
          END;
        END LOOP;


    num_xdb_vw := num_nsb_vw + num_sb_vw;
    num_xdb_tbl := num_nsb_tbl + num_sb_tbl;

    if (num_xdb_res > 0) or (num_xdb_schemas > 0) or
        (num_xdb_vw > 0) or (num_xdb_tbl > 0) then

        /* xdb is being used by user */
        OPEN cursor_objtype FOR q'[
             select count(*), bitand(p.flags, 69)
             from sys.opqtype$ p, sys.user$ u, sys.obj$ o
             where p.type = 1 and 
                  (bitand(p.flags, 1) = 1 or bitand(p.flags, 4) = 4 or 
                   bitand(p.flags, 68) = 68) and
                  p.obj# = o.obj# and
                  o.owner# = u.user# and 
                  u.name not in ('XDB', 'SYS', 'MDSYS', 'EXFSYS', 'ORDSYS', 
                                'ORDDATA', 'OE', 'SH', 'HR', 'SCOTT') and 
                  u.name not like 'APEX_%'                 
             group by (bitand(p.flags, 69))]';

        LOOP 
          BEGIN
            FETCH cursor_objtype INTO total_count, flag;
            EXIT WHEN cursor_objtype%NOTFOUND;

            /* get number of xmltype columns stored as object */
            IF flag = 1 THEN 
              num_st_or := total_count; 
            END IF;

            /* get number of xmltype columns stored as lob */
            IF flag = 4 THEN
              num_st_clob := total_count;
            END IF;

            /* get number of xmltype columns stored as binary */
            IF flag = 68 THEN
              num_st_bin := total_count;
            END IF;
          END;
        END LOOP;

        /* get number of resconfigs */ 
        execute immediate 'select count(*) from xdb.xdb$resconfig' into 
                                                        num_xdb_rc;
        /* get number of acls */ 
        execute immediate 'select count(*) from xdb.xdb$acl' into 
                                                        num_xdb_acl;


        feature_boolean := 1;
        aux_count := 0; 

        feature_usage := chr(10) ||
           '<xdb_feature_usage>'||
                chr(10)||chr(32)||chr(32)||
                '<user_resources>       '|| to_char(num_xdb_res)  || 
                ' </user_resources>'||
                chr(10) ||chr(32)||chr(32)||
                '<user_schemas>         '|| to_char(num_xdb_schemas) || 
                ' </user_schemas>'||
                chr(10)||chr(32)||chr(32)||
                '<user_SB_columns>      '|| to_char(num_sb_tbl)   || 
                ' </user_SB_columns>'||
                chr(10)||chr(32)||chr(32)||
                '<user_NSB_columns>     '|| to_char(num_nsb_tbl)  || 
                ' </user_NSB_columns>'||
                chr(10)||chr(32)||chr(32)||
                '<user_SB_views>        '|| to_char(num_sb_vw)    || 
                ' </user_SB_views>'||
                chr(10)||chr(32)||chr(32)||
                '<user_NSB_views>       '|| to_char(num_nsb_vw)   || 
                ' </user_NSB_views>'||
                chr(10)||chr(32)||chr(32)||
                '<user_OR_cols>         '|| to_char(num_st_or)    || 
                ' </user_OR_cols>'||
                chr(10)||chr(32)||chr(32)||
                '<user_CLOB_cols>       '|| to_char(num_st_clob)  || 
                ' </user_CLOB_cols>'||
                chr(10)||chr(32)||chr(32)||
                '<user_BINARY_cols>     '|| to_char(num_st_bin)   || 
                ' </user_BINARY_cols>'||
                chr(10)||chr(32)||chr(32)||
                '<all_resconfigs>       '|| to_char(num_xdb_rc)   || 
                ' </all_resconfigs>'||
                chr(10)||chr(32)||chr(32)||
                '<all_acls>             '|| to_char(num_xdb_acl)  || 
                ' </all_acls>'||
                chr(10) ||
           '</xdb_feature_usage>';
        
        feature_info := to_clob(feature_usage);
    else
        feature_boolean := 0;
        aux_count := 0; 
        feature_info := 
            to_clob('<xdb_feature_usage>SYSTEM</xdb_feature_usage>');
    end if;
 
end;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_APEX
 *  The procedure to detect usage for Application Express 
 ***************************************************************/

create or replace procedure DBMS_FEATURE_APEX
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
    l_apex_schema   varchar2(30) := null;
    l_usage_detect  number := 0;
    l_num_apps      number := 0;
    l_num_workspace number := 0;
    l_num_users     number := 0;
begin
    /* Determine current schema for Application Express
       Note: this will only return one row              */
    for c1 in (select schema
                 from dba_registry
                where comp_id = 'APEX' ) loop
        l_apex_schema := dbms_assert.enquote_name(c1.schema, FALSE);
    end loop;

    /* If not found, then APEX is not installed */
    if l_apex_schema is null then
        feature_boolean := 0;
        aux_count := 0;
        feature_info := to_clob('APEX usage not detected');
        return;
    end if;

    /* Determine if any activity since last sample date */
    execute immediate 'select count(*)
  from dual
 where exists (select null
                 from '||l_apex_schema||'.wwv_flow_activity_log
                where time_stamp > nvl((select last_sample_date
                                          from dba_feature_usage_statistics
                                         where name = ''Application Express''),
                                       (sysdate -7)) )' into l_usage_detect;

    if l_usage_detect = 1 then

       /* Determine the number of user-created applications */
       execute immediate 'select count(*)
  from '||l_apex_schema||'.wwv_flows
 where security_group_id != 10' into l_num_apps;

        /* Determine the number of workspaces */
        execute immediate 'select count(*)
  from '||l_apex_schema||'.wwv_flow_companies
 where provisioning_company_id != 10' into l_num_workspace;

        /* Determine the number of non-internal Application Express users */
        execute immediate 'select count(*)
  from '||l_apex_schema||'.wwv_flow_fnd_user
 where security_group_id != 10' into l_num_users;

        feature_boolean := 1;
        aux_count := l_num_apps;
        feature_info := to_clob('Number of applications: '||to_char(l_num_apps)||
        ', '||'Number of workspaces: '||to_char(l_num_workspace)||
        ', '||'Number of users: '||to_char(l_num_users));

    else
        feature_boolean := 0;
        aux_count := 0;
        feature_info := to_clob('APEX usage not detected');
    end if;

end DBMS_FEATURE_APEX;
/

/***************************************************************
 * DBMS_FEATURE_OBJECT
 *  The procedure to detect usage for OBJECT 
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_OBJECT
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  num_obj_types         number;
  num_obj_tables        number;
  num_obj_columns       number;
  num_obj_views         number;
  num_anydata_cols      number;
  num_nt_cols           number;
  num_varray_cols       number;
  num_octs              number;
  feature_usage         varchar2(1000);
  TYPE cursor_t         IS REF CURSOR;
  cursor_coltype        cursor_t;
  total_count           number;
  flag                  number;

BEGIN
  --initialize
  num_obj_types         :=0;
  num_obj_tables        :=0;
  num_obj_columns       :=0;
  num_obj_views         :=0;
  num_anydata_cols      :=0;
  num_nt_cols           :=0;
  num_varray_cols       :=0;
  num_octs              :=0;
  total_count           :=0;
  flag                  :=0;

  feature_boolean := 0;
  aux_count := 0;

  /* get number of object types */
  execute immediate 'select count(*) from sys.type$ t, sys.obj$ o, sys.user$ u 
          where o.owner# = u.user# and o.oid$ = t.tvoid and 
            u.name not in (select schema_name from v$sysaux_occupants) and
            u.name not in (''OE'', ''IX'', ''PM'', ''FLOWS_FILES'', ''FLOWS_030000'',
                           ''FLOWS_030100'', ''APEX_030200'')' 
          into num_obj_types;

  /* get number of object tables */
  execute immediate 'select count(*) from  sys.tab$ t, sys.obj$ o, sys.user$ u
          where o.owner# = u.user# and o.obj# = t.obj# and
                bitand(t.property, 1) = 1 and bitand(o.flags, 128) = 0 and
                u.name not in (select schema_name from v$sysaux_occupants) and
                u.name not in (''OE'', ''PM'', ''FLOWS_FILES'', ''FLOWS_030000'',
                               ''FLOWS_030100'', ''APEX_030200'')'
          into num_obj_tables;
 

  /* get number of object views */ 
  execute immediate 'select count(*) from sys.typed_view$ t, sys.obj$ o, sys.user$ u
          where o.owner# = u.user# and o.obj# = t.obj# and
                u.name not in (select schema_name from v$sysaux_occupants) and
                u.name not in (''OE'', ''FLOWS_FILES'', ''FLOWS_030000'',
                               ''FLOWS_030100'', ''APEX_030200'')' 
          into num_obj_views;

  /* get number of object columns, nested table columns, varray columns,
   * anydata columns and OCTs
   */  
  OPEN cursor_coltype FOR '
    select /*+ index(o i_obj1) */ count(*), bitand(t.flags, 16414)
    from sys.coltype$ t, sys.obj$ o, sys.user$ u
    where o.owner# = u.user# and o.obj# = t.obj# and
          u.name not in (select schema_name from v$sysaux_occupants) and
          u.name not in (''OE'', ''IX'', ''PM'', ''FLOWS_FILES'', ''FLOWS_030000'',
                         ''FLOWS_030100'', ''APEX_030200'') and
          ((bitand(t.flags, 30) != 0) OR
           (bitand(t.flags, 16384) = 16384 and
            t.toid = ''00000000000000000000000000020011''))
    group by (bitand(t.flags, 16414))';


  LOOP
    BEGIN
      FETCH cursor_coltype INTO total_count, flag;
      EXIT WHEN cursor_coltype%NOTFOUND;

      /* number of nested table columns */
      IF flag = 4 THEN
        num_nt_cols := total_count;
      END IF;

      /* number of varray columns */
      IF flag = 8 THEN
        num_varray_cols := total_count;
      END IF;

      /* number of OCTs */
      IF flag = 12 THEN
        num_octs := total_count;
      END IF;

      /* number of adt and ref columns */
      IF (flag = 2 or flag = 16) THEN
        num_obj_columns  := num_obj_columns + total_count;
      END IF;

      /* number of anydata columns */
      IF (flag = 16384) THEN
        num_anydata_cols := total_count;
      END IF;
    END;
  END LOOP;

  if ((num_obj_types > 0) OR (num_obj_tables > 0) OR (num_obj_columns >0)
      OR (num_obj_views > 0) OR (num_anydata_cols > 0) OR (num_nt_cols > 0)
      OR (num_varray_cols > 0) OR (num_octs > 0)) then

    feature_boolean := 1;  
    feature_usage := 'num of object types: ' || to_char(num_obj_types) ||
        ',' || 'num of object tables: ' || to_char(num_obj_tables) ||
        ',' || 'num of adt and ref columns: ' || to_char(num_obj_columns) ||
        ',' || 'num of object views: ' || to_char(num_obj_views) ||
        ',' || 'num of anydata cols: ' || to_char(num_anydata_cols) ||
        ',' || 'num of nested table cols: ' || to_char(num_nt_cols) ||
        ',' || 'num of varray cols: ' || to_char(num_varray_cols) ||
        ',' || 'num of octs: ' || to_char(num_octs);

    feature_info := to_clob(feature_usage);
  else
    feature_info := to_clob('OBJECT usage not detected');
  end if;

end;
/
 
/***************************************************************
 * DBMS_FEATURE_EXTENSIBILITY
 *  The procedure to detect usage for EXTENSIBILITY 
 ***************************************************************/
  
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_EXTENSIBILITY
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB) 
AS
  num_user_opts         number;
  num_user_aggs         number;
  num_table_funs        number;
  num_idx_types         number;
  num_domain_idxs       number;
  feature_usage         varchar2(1000);
  TYPE cursor_t         IS REF CURSOR;
  cursor_udftype        cursor_t;
  total_count           number;
  flag                  number;

begin
  --initialize
  num_user_opts         :=0;
  num_user_aggs         :=0;
  num_table_funs        :=0;
  num_idx_types         :=0;
  num_domain_idxs       :=0;
  total_count           :=0;
  flag                  :=0;


  feature_boolean := 0;
  aux_count := 0;

  /* get number of user-defined operators */
  execute immediate 'select count(*) from DBA_OPERATORS
          where owner not in (select schema_name from v$sysaux_occupants)
          and owner not in (''SH'')'
          into num_user_opts;

  /* get number of user-defined index types */
  execute immediate 'select count(*) 
          from sys.indtypes$ i, sys.user$ u, sys.obj$ o
          where i.obj# = o.obj# and o.owner# = u.user# and
                u.name not in (select schema_name from v$sysaux_occupants)
                and u.name not in (''SH'')'
          into num_idx_types;

  /* get number of user-defined domain indexes */
  execute immediate 'select count(*) from sys.user$ u, sys.ind$ i, sys.obj$ o
          where u.user# = o.owner# and o.obj# = i.obj# and
                i.type# = 9 and
                u.name not in (select schema_name from v$sysaux_occupants)
                and u.name not in (''SH'')'
          into num_domain_idxs; 

  /* get number of user-defined aggregates and user-defined 
   * pipelined table functions
   */
  OPEN cursor_udftype FOR '
    select count(*), bitand(p.properties, 24)
    from sys.obj$ o, sys.user$ u, sys.procedureinfo$ p
    where o.owner# = u.user# and o.obj# = p.obj# and
          bitand(p.properties, 24) != 0 and
          u.name not in (select schema_name from v$sysaux_occupants)
          and u.name not in (''SH'')
    group by (bitand(p.properties, 24))';

  LOOP
    BEGIN
      FETCH cursor_udftype INTO total_count, flag;
      EXIT WHEN cursor_udftype%NOTFOUND;

      IF flag = 8 THEN
        num_user_aggs := total_count;
      END IF;

      IF flag = 16 THEN
        num_table_funs := total_count;
      END IF;
    END;
  END LOOP; 
   
  if ((num_user_opts > 0) OR (num_user_aggs > 0) OR (num_table_funs > 0)
      OR (num_idx_types > 0) OR (num_domain_idxs > 0)) then
    feature_boolean := 1;
    feature_usage := 'num of user-defined operators: ' || to_char(num_user_opts) ||
        ',' || 'num of user-defined aggregates: ' || to_char(num_user_aggs) ||
        ',' || 'num of table functions: ' || to_char(num_table_funs) ||
        ',' || 'num of index types: ' || to_char(num_idx_types) ||
        ',' || 'num of domain indexes: ' || to_char(num_domain_idxs);

    feature_info := to_clob(feature_usage);
  else
    feature_info := to_clob('EXTENSIBILITY usage not detected');
  end if;
 
end;
/

/***************************************************************
 * DBMS_FEATURE_RULESMANAGER
 *  The procedure to detect usage for RULES MANAGER & EXPRESSION FILTER
 ***************************************************************/
  
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RULESMANAGER
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB) 
AS
  num_rule_clss        number := 0; 
  num_comp_rulcls       number := 0; 
  max_pmevt_prcmp       number := 0; 
  avg_pmevt_prcmp       number := 0; 
  num_cllt_evts         number := 0; 
  num_pure_expcols      number := 0; 
  num_domain_idxs       number;

  feature_usage         varchar2(1000);
  TYPE cursor_t         IS REF CURSOR;
  cursor_udftype        cursor_t;
  total_count           number;
  flag                  number;

begin
  --initialize
  feature_boolean := 0;
  aux_count := 0;

  /* get the number of rule classes */ 
  begin  
    execute immediate 'select count(*) from exfsys.adm_rlmgr_rule_classes'
                          into num_rule_clss; 
  exception 
    when others then 
       num_rule_clss := 0; 
  end; 

  if (num_rule_clss > 0) then 
    /* get the numbers on rule classes with composite events */ 
    execute immediate 'select count(*), avg(prmevtprc), max(prmevtprc) 
     from (select count(*) as prmevtprc from 
           exfsys.adm_rlmgr_comprcls_properties
           group by rule_class_owner, rule_class_name) ' into 
         num_comp_rulcls, avg_pmevt_prcmp, max_pmevt_prcmp;

    /* rule class with collection events */
    execute immediate 'select count(*) from 
            exfsys.adm_rlmgr_comprcls_properties
              where collection_enb = ''Y''' into num_cllt_evts;
  end if; 

  /* expression columns outside the context of rule classes */ 
  execute immediate 'select count(*) from exfsys.adm_expfil_expression_sets
     where not(expr_column like ''RLM$%'')' into num_pure_expcols;
   
  if ((num_rule_clss > 0) OR (num_comp_rulcls > 0) OR (avg_pmevt_prcmp > 0)
      OR (max_pmevt_prcmp > 0) OR (num_pure_expcols > 0)) then
    feature_boolean := 1; 
    feature_usage :=
       'num of rule classes: '||to_char(num_rule_clss) ||', '||
       'num of rule classes with composite events: '||
                          to_char(num_comp_rulcls) ||', '||
       'avg num of primitive events per composite: '||
                          to_char(avg_pmevt_prcmp) ||', '||
       'max num of primitive events for a rule class: '||
                          to_char(max_pmevt_prcmp) ||', '||
       'num expression columns(user): '||
                          to_char(num_pure_expcols); 
     feature_info := to_clob(feature_usage);
  else
     feature_info := to_clob(
              'Rules Manager/Expression Filter usage not detected');  
  end if;
 
end;
/

/***************************************************************
 * DBMS_FEATURE_CDC
 *  The procedure to detect usage for Change Data Capture (CDC)
 ***************************************************************/
  
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_CDC
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB) 
AS
  num_autolog           number := 0; 
  num_hotlog            number := 0; 
  num_sync              number := 0; 
  num_dist              number := 0; 
  num_hotmine           number := 0;

  num_auto_sets         number := 0;
  num_hot_sets          number := 0;
  num_sync_sets         number := 0;
  num_dist_sets         number := 0;
  num_mine_sets         number := 0;

  num_auto_tabs         number := 0;
  num_hot_tabs          number := 0;
  num_sync_tabs         number := 0;
  num_dist_tabs         number := 0;
  num_mine_tabs         number := 0;

  num_auto_subs         number := 0;
  num_hot_subs          number := 0;
  num_sync_subs         number := 0;
  num_dist_subs         number := 0;
  num_mine_subs         number := 0;

  feature_usage         varchar2(2000);

begin
  --initialize
  aux_count := 0;

  /* get the number of total change tables and dump in aux_count */
  begin
    execute immediate 'select count(*) from sys.cdc_change_Tables$'
                        into aux_count;
  exception
    when others then
      aux_count := 0;
  end;

  if (aux_count > 0) then
    feature_boolean := 1;
  else
    feature_boolean := 0;
    feature_info := to_clob('CDC usage not detected');
    return;
  end if;

  /* get data for AUTOLOG */
  begin
    execute immediate 'select count(*) from sys.cdc_change_sources$
                         where BITAND(source_type, 2) = 2'
                        into num_autolog;
  exception
    when others then
      num_autolog := 0;
  end;
  
  if (num_autolog > 0 ) then

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b
                           where BITAND(a.source_type, 2) = 2 AND
                              b.change_source_name = a.source_name'
                          into num_auto_sets;
    exception
      when others then
        num_auto_sets := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_change_tables$ c
                           where BITAND(a.source_type, 2) = 2 AND
                              b.change_source_name = a.source_name AND
                              c.change_set_name = b.set_name'
                          into num_auto_tabs;
    exception
      when others then
        num_auto_tabs := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_subscribers$ c
                           where BITAND(a.source_type, 2) = 2 AND
                              b.change_source_name = a.source_name AND
                              c.set_name = b.set_name'
                          into num_auto_subs;
    exception
      when others then
        num_auto_subs := 0;
    end;

  end if;

  /* get data for HOTLOG */
  begin
    execute immediate 'select count(*) from sys.cdc_change_sources$
                         where BITAND(source_type, 4) = 4'
                        into num_hotlog;
  exception
    when others then
      num_hotlog := 0;
  end;
  
  if (num_hotlog > 0 ) then

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b
                           where BITAND(a.source_type, 4) = 4 AND
                              b.change_source_name = a.source_name'
                          into num_hot_sets;
    exception
      when others then
        num_hot_sets := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_change_tables$ c
                           where BITAND(a.source_type, 4) = 4 AND
                              b.change_source_name = a.source_name AND
                              c.change_set_name = b.set_name'
                          into num_hot_tabs;
    exception
      when others then
        num_hot_tabs := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_subscribers$ c
                           where BITAND(a.source_type, 4) = 4 AND
                              b.change_source_name = a.source_name AND
                              c.set_name = b.set_name'
                          into num_hot_subs;
    exception
      when others then
        num_hot_subs := 0;
    end;

  end if;

  /* get data for SYNCHRONOUS */
  begin
    execute immediate 'select count(*) from sys.cdc_change_sources$
                         where BITAND(source_type, 8) = 8'
                        into num_sync;
  exception
    when others then
      num_sync := 0;
  end;
  
  if (num_sync > 0 ) then

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b
                           where BITAND(a.source_type, 8) = 8 AND
                              b.change_source_name = a.source_name'
                          into num_sync_sets;
    exception
      when others then
        num_sync_sets := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_change_tables$ c
                           where BITAND(a.source_type, 8) = 8 AND
                              b.change_source_name = a.source_name AND
                              c.change_set_name = b.set_name'
                          into num_sync_tabs;
    exception
      when others then
        num_sync_tabs := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_subscribers$ c
                           where BITAND(a.source_type, 8) = 8 AND
                              b.change_source_name = a.source_name AND
                              c.set_name = b.set_name'
                          into num_sync_subs;
    exception
      when others then
        num_sync_subs := 0;
    end;

  end if;

  /* get data for DISTRIBUTED HOTLOG */
  begin
    execute immediate 'select count(*) from sys.cdc_change_sources$
                         where BITAND(source_type, 64) = 64'
                        into num_dist;
  exception
    when others then
      num_dist := 0;
  end;
  
  if (num_dist > 0 ) then

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b
                           where BITAND(a.source_type, 64) = 64 AND
                              b.change_source_name = a.source_name'
                          into num_dist_sets;
    exception
      when others then
        num_dist_sets := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_change_tables$ c
                           where BITAND(a.source_type, 64) = 64 AND
                              b.change_source_name = a.source_name AND
                              c.change_set_name = b.set_name'
                          into num_dist_tabs;
    exception
      when others then
        num_dist_tabs := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_subscribers$ c
                           where BITAND(a.source_type, 64) = 64 AND
                              b.change_source_name = a.source_name AND
                              c.set_name = b.set_name'
                          into num_dist_subs;
    exception
      when others then
        num_dist_subs := 0;
    end;

  end if;

  /* get data for DISTRIBUTED HOTMINING */
  begin
    execute immediate 'select count(*) from sys.cdc_change_sources$
                         where BITAND(source_type, 128) = 128'
                        into num_hotmine;
  exception
    when others then
      num_hotmine := 0;
  end;
  
  if (num_hotmine > 0 ) then

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b
                           where BITAND(a.source_type, 128) = 128 AND
                              b.change_source_name = a.source_name'
                          into num_mine_sets;
    exception
      when others then
        num_mine_sets := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_change_tables$ c
                           where BITAND(a.source_type, 128) = 128 AND
                              b.change_source_name = a.source_name AND
                              c.change_set_name = b.set_name'
                          into num_mine_tabs;
    exception
      when others then
        num_mine_tabs := 0;
    end;

    begin
      execute immediate 'select count(*) from sys.cdc_change_sources$ a,
                           sys.cdc_change_sets$ b, sys.cdc_subscribers$ c
                           where BITAND(a.source_type, 128) = 128 AND
                              b.change_source_name = a.source_name AND
                              c.set_name = b.set_name'
                          into num_mine_subs;
    exception
      when others then
        num_mine_subs := 0;
    end;

  end if;


  feature_usage := 'autolog - source: ' || to_char(num_autolog) ||', '||
                  'sets: '  || to_char(num_auto_sets) ||', '||
                  'tables: ' || to_char(num_auto_tabs) ||', '||
                  'subscriptions: ' || to_char(num_auto_subs) ||', '||
                  'hotlog - source: ' || to_char(num_hotlog) ||', '||
                  'sets: '  || to_char(num_hot_sets) ||', '||
                  'tables: ' || to_char(num_hot_tabs) ||', '||
                  'subscriptions: ' || to_char(num_hot_subs) ||', '||
                  'sync - source: ' || to_char(num_sync) ||', '||
                  'sets: '  || to_char(num_sync_sets) ||', '||
                  'tables: ' || to_char(num_sync_tabs) ||', '||
                  'subscriptions: ' || to_char(num_sync_subs) ||', '||
                  'distributed - source: ' || to_char(num_dist) ||', '||
                  'sets: '  || to_char(num_dist_sets) ||', '||
                  'tables: ' || to_char(num_dist_tabs) ||', '||
                  'subscriptions: ' || to_char(num_dist_subs) ||', '||
                  'HotMine - source: ' || to_char(num_hotmine) ||', '||
                  'sets: '  || to_char(num_mine_sets) ||', '||
                  'tables: ' || to_char(num_mine_tabs) ||', '||
                  'subscriptions: ' || to_char(num_mine_subs);

  feature_info := to_clob(feature_usage);

end;
/


/***************************************************************
 * DBMS_FEATURE_SERVICES
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_services
      (is_used OUT number, hwm OUT number, feature_info OUT clob)
AS
  -- Based off dba_services
  num_clb_long                            NUMBER := 0;
  num_clb_short                           NUMBER := 0;
  num_goal_service_time                   NUMBER := 0;
  num_goal_throughput                     NUMBER := 0;
  num_goal_none                           NUMBER := 0;
  num_goal_null                           NUMBER := 0;
  num_aq_notifications                    NUMBER := 0;

  -- Based off gv$active_services
  num_active_svcs                         NUMBER := 0;
  num_active_svcs_wo_distinct             NUMBER := 0;
  avg_active_cardinality                  NUMBER := 0;

  default_service_name                    varchar2(1000);
  default_xdb_service_name                varchar2(1000);
  db_domain                               varchar2(1000);

BEGIN
  -- initialize
  is_used      := 0;
  hwm          := 0;
  feature_info := 'Services usage not detected';

  -- get default service name - db_unique_name[.db_domain]

  SELECT value INTO default_service_name FROM v$parameter WHERE
        lower(name) = 'db_unique_name';

  SELECT value INTO db_domain FROM v$parameter WHERE
        lower(name) = 'db_domain';

  -- create default XDB service name
  default_xdb_service_name := default_service_name || 'XDB';

  -- append db_domain if it is set
  IF db_domain IS NOT NULL then
    default_service_name := default_service_name || '.' || db_domain;
  END IF;

  SELECT count(*) INTO hwm
  FROM dba_services
  WHERE 
      NAME NOT LIKE 'SYS$%'
  AND NETWORK_NAME NOT LIKE 'SYS$%'
  AND NAME <> default_xdb_service_name
  AND NAME <> default_service_name;

  IF hwm > 0 THEN
    is_used := 1;
  END IF;

  -- if services is used 
  IF (is_used = 1) THEN

    -- Get the counts for CLB_GOAL variations
    FOR item IN (
      SELECT clb_goal, count(*) cg_count
      FROM dba_services
      where 
          NAME NOT LIKE 'SYS$%'
      AND NETWORK_NAME NOT LIKE 'SYS$%'
      AND NAME <> default_xdb_service_name
      AND NAME <> default_service_name
      GROUP BY clb_goal) 

    LOOP

      IF item.clb_goal = 'SHORT' THEN
        num_clb_short := item.cg_count;
      ELSIF item.clb_goal = 'LONG' THEN
        num_clb_long  := item.cg_count;
      END IF;

    END LOOP;

    
    -- Get the counts for GOAL variations
    FOR item IN (
      SELECT goal, count(*) g_count
      FROM dba_services
      where 
          NAME NOT LIKE 'SYS$%'
      AND NETWORK_NAME NOT LIKE 'SYS$%'
      AND NAME <> default_xdb_service_name
      AND NAME <> default_service_name
      GROUP BY goal) 

    LOOP

      IF item.goal = 'SERVICE_TIME' THEN
        num_goal_service_time := item.g_count;
      ELSIF item.goal = 'THROUGHPUT' THEN
        num_goal_throughput  := item.g_count;
      ELSIF item.goal = 'NONE' THEN
        num_goal_none := item.g_count;
      ELSIF item.goal is NULL THEN
        num_goal_null := item.g_count;
      END IF;

    END LOOP;

    -- count goal is NULL as goal = NONE
    num_goal_none := num_goal_none + num_goal_null;

    -- Get the count for aq_ha_notifications
    SELECT count(*) into num_aq_notifications
    FROM dba_services
    where 
        NAME NOT LIKE 'SYS$%'
    AND NETWORK_NAME NOT LIKE 'SYS$%'
    AND NAME <> default_xdb_service_name
    AND NAME <> default_service_name
    AND AQ_HA_NOTIFICATIONS = 'YES';


    SELECT count(distinct name), count(*)
      INTO num_active_svcs, num_active_svcs_wo_distinct
    FROM gv$active_services
    WHERE 
        NAME NOT LIKE 'SYS$%'
    AND NETWORK_NAME NOT LIKE 'SYS$%'
    AND NAME <> default_xdb_service_name
    AND NAME <> default_service_name;

    IF num_active_svcs > 0 THEN

      avg_active_cardinality := 
        round(num_active_svcs_wo_distinct / num_active_svcs);

    END IF;

    feature_info := 
        ' num_clb_long: '          || num_clb_long
      ||' num_clb_short: '         || num_clb_short
      ||' num_goal_service_time: ' || num_goal_service_time
      ||' num_goal_throughput: '   || num_goal_throughput
      ||' num_goal_none: '         || num_goal_none
      ||' num_aq_notifications: '  || num_aq_notifications
      ||' num_active_services: '   || num_active_svcs
      ||' avg_active_cardinality: '|| avg_active_cardinality;

  END IF;

END;
/

/***************************************************************
 * DBMS_FEATURE_STREAMS(system)
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_streams
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  num_capture                             NUMBER;
  num_ds_capture                          NUMBER;
  num_apply                               NUMBER;
  num_prop                                NUMBER;
  feature_usage                           VARCHAR2(2000);
  total_feature_usage                     NUMBER;
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_capture                      := 0;
  num_ds_capture                   := 0;
  num_apply                        := 0;
  num_prop                         := 0;
  feature_usage                    := NULL;
  total_feature_usage              := 0;

  select decode (count(*), 0, 0, 1) into num_capture 
     from dba_capture 
     where UPPER(purpose) NOT IN ('GOLDENGATE CAPTURE','XSTREAM_OUT');

  select decode (count(*), 0, 0, 1) into num_ds_capture 
     from dba_capture 
     where UPPER(purpose) NOT IN ('GOLDENGATE CAPTURE','XSTREAM_OUT')
       and UPPER(capture_type) = 'DOWNSTREAM';

  select decode (count(*), 0, 0, 1) into num_apply 
     from dba_apply 
     where UPPER(purpose) NOT IN ('GOLDENGATE CAPTURE','GOLDENGATE APPLY',
                                  'XSTREAM IN', 'XSTREAM OUT');

  select decode (count(*), 0, 0, 1) into num_prop from dba_propagation;

  total_feature_usage := num_capture + num_apply + num_prop; 

  feature_usage := feature_usage ||
        'tcap:'                  || num_capture
      ||' dscap:'                || num_ds_capture
      ||' app:'                  || num_apply
      ||' prop:'                 || num_prop;

  feature_info   := to_clob(feature_usage);
  if (total_feature_usage > 0) THEN
      feature_boolean := 1;
  end if;
  if(num_capture > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_apply > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_prop > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;

END dbms_feature_streams;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_XSTREAM_OUT
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_xstream_out
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  num_capture                             NUMBER;
  num_ds_capture                          NUMBER;
  num_apply                               NUMBER;
  feature_usage                           VARCHAR2(2000);
  total_feature_usage                     NUMBER;
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_capture                      := 0;
  num_ds_capture                   := 0;
  num_apply                        := 0;
  feature_usage                    := NULL;
  total_feature_usage              := 0;

  select decode (count(*), 0, 0, 1) into num_capture 
     from dba_capture where UPPER(purpose) = 'XSTREAM OUT';

  select decode (count(*), 0, 0, 1) into num_ds_capture 
     from dba_capture where UPPER(purpose) = 'XSTREAM OUT' and
                            UPPER(capture_type) = 'DOWNSTREAM';

  select decode (count(*), 0, 0, 1) into num_apply 
     from dba_apply where UPPER(purpose) = 'XSTREAM OUT';


  total_feature_usage := num_capture + num_apply; 

  feature_usage := feature_usage ||
        'tcap:'                  || num_capture
      ||' dscap:'                || num_ds_capture
      ||' app:'                  || num_apply;

  feature_info   := to_clob(feature_usage);
  if (total_feature_usage > 0) THEN
      feature_boolean := 1;
  end if;
  if(num_capture > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_apply > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;

END dbms_feature_xstream_out;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_XSTREAM_IN
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_xstream_in
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  num_apply                               NUMBER;
  feature_usage                           VARCHAR2(2000);
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_apply                        := 0;
  feature_usage                    := NULL;

  select decode (count(*), 0, 0, 1) into num_apply 
     from dba_apply where UPPER(purpose) = 'XSTREAM IN';

  feature_usage := feature_usage ||
        'app:'                   || num_apply;

  feature_info   := to_clob(feature_usage);
  if (num_apply > 0) THEN
      feature_boolean := 1;
      aux_count      :=  aux_count+1;
  end if;

END dbms_feature_xstream_in;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_XSTREAM_STREAMS
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_xstream_streams
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  num_capture                             NUMBER;
  num_ds_capture                          NUMBER;
  num_apply                               NUMBER;
  num_prop                                NUMBER;
  feature_usage                           VARCHAR2(2000);
  total_feature_usage                     NUMBER;
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_capture                      := 0;
  num_ds_capture                   := 0;
  num_apply                        := 0;
  num_prop                         := 0;
  feature_usage                    := NULL;
  total_feature_usage              := 0;

  select decode (count(*), 0, 0, 1) into num_capture 
     from dba_capture where UPPER(purpose) = 'XSTREAM STREAMS';

  select decode (count(*), 0, 0, 1) into num_ds_capture 
     from dba_capture where UPPER(purpose) = 'XSTREAM STREAMS' and
                            UPPER(capture_type) = 'DOWNSTREAM';

  select decode (count(*), 0, 0, 1) into num_apply 
     from dba_apply where UPPER(purpose) = 'XSTREAM STREAMS';

  select decode (count(*), 0, 0, 1) into num_prop from dba_propagation;

  total_feature_usage := num_capture + num_apply + num_prop; 

  feature_usage := feature_usage ||
        'tcap:'                  || num_capture
      ||' dscap:'                || num_ds_capture
      ||' app:'                  || num_apply
      ||' prop:'                 || num_prop;

  feature_info   := to_clob(feature_usage);
  if (total_feature_usage > 0) THEN
      feature_boolean := 1;
  end if;
  if(num_capture > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_apply > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_prop > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;

END dbms_feature_xstream_streams;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_GOLDENGATE
 *  The procedure to detect usage for Services
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_goldengate
      (feature_boolean  OUT  NUMBER, 
       aux_count        OUT  NUMBER, 
       feature_info     OUT  CLOB)
AS
  -- Based on goldengate usage
  num_capture                             NUMBER;
  num_ds_capture                          NUMBER;
  num_apply                               NUMBER;
  num_trigger_suppression                 NUMBER;
  num_transient_duplicate                 NUMBER;
  num_dblogreader                         NUMBER;
  num_ggsddltrigopt                       NUMBER;
  feature_usage                           VARCHAR2(4000);
  total_feature_usage                     NUMBER;
  num_dbencryption                        NUMBER;
  num_ggsession                           NUMBER;
  num_delcascadehint                      NUMBER;
  num_suplog                              NUMBER;
BEGIN
  -- initialize
  feature_boolean                  := 0;
  aux_count                        := 0;
  feature_info                     := NULL;
  num_capture                      := 0;
  num_ds_capture                   := 0;
  num_apply                        := 0;
  num_trigger_suppression          := 0;
  num_transient_duplicate          := 0;
  num_dblogreader                  := 0;
  num_ggsddltrigopt                := 0;
  feature_usage                    := NULL;
  total_feature_usage              := 0;
  num_dbencryption                 := 0;
  num_ggsession                    := 0;
  num_delcascadehint               := 0;
  num_suplog                       := 0;

  select decode (count(*), 0, 0, 1) into num_capture 
     from dba_capture where UPPER(purpose) = 'GOLDENGATE CAPTURE';

  select decode (count(*), 0, 0, 1) into num_ds_capture 
     from dba_capture where UPPER(purpose) = 'GOLDENGATE CAPTURE' and
                            UPPER(capture_type) = 'DOWNSTREAM';

  select decode (count(*), 0, 0, 1) into num_apply from dba_apply 
     where UPPER(purpose) IN ('GOLDENGATE APPLY', 'GOLDENGATE CAPTURE');

  select sum(count) into num_dblogreader 
     from GV$GOLDENGATE_CAPABILITIES where name like 'DBLOGREADER';
  
  select sum(count) into num_transient_duplicate
     from GV$GOLDENGATE_CAPABILITIES where name like 'TRANSIENTDUPLICATE';

  select sum(count) into num_trigger_suppression
     from GV$GOLDENGATE_CAPABILITIES where name like 'TRIGGERSUPPRESSION';

  select sum(count) into num_ggsddltrigopt 
     from GV$GOLDENGATE_CAPABILITIES where name like 'DDLTRIGGEROPTIMIZATION';
 
  select sum(count) into num_dbencryption
     from GV$GOLDENGATE_CAPABILITIES where name like 'DBENCRYPTION';

  select sum(count) into num_ggsession
     from GV$GOLDENGATE_CAPABILITIES where name like 'GGSESSION';

  select sum(count) into num_delcascadehint
     from GV$GOLDENGATE_CAPABILITIES where name like 'DELETECASCADEHINT';

  select sum(count) into num_suplog
     from GV$GOLDENGATE_CAPABILITIES where name like 'SUPPLEMENTALLOG';


  total_feature_usage := num_capture + num_apply + num_dblogreader + 
     num_transient_duplicate + num_ggsddltrigopt + num_trigger_suppression +
     num_dbencryption + num_ggsession + num_delcascadehint + num_suplog;

  feature_usage := feature_usage ||
        'tcap:'                  || num_capture
      ||' dscap:'                || num_ds_capture
      ||' app:'                  || num_apply
      ||' dblogread:'            || num_dblogreader
      ||' tdup:'                 || num_transient_duplicate
      ||' suptrig:'              || num_trigger_suppression
      ||' dtrigopt:'             || num_ggsddltrigopt
      ||' dbenc:'                || num_dbencryption
      ||' ggsess:'               || num_ggsession
      ||' delhint:'              || num_delcascadehint
      ||' suplog:'               || num_suplog;
   
  feature_info   := to_clob(feature_usage);
  if (total_feature_usage > 0) THEN
      feature_boolean := 1;
  end if;
  if(num_capture > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_apply > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_dblogreader > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_transient_duplicate > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_ggsddltrigopt > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_trigger_suppression > 0 ) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_dbencryption > 0) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_ggsession > 0) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_delcascadehint > 0) THEN
       aux_count      :=  aux_count+1;
  end if;
  if(num_suplog > 0) THEN
       aux_count      :=  aux_count+1;
  end if;

END dbms_feature_goldengate;
/

show errors;

/****************************************************************
 * DBMS_FEATURE_USER_MVS
 * The procedure to detect usage for MATERIALIZED VIEWS (USER)
 ****************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_USER_MVS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
 num_mv         number;     -- total number of user mvs (user mvs of all types)
 num_ondmd      number;                                   -- on-demand user mvs
 num_cmplx      number;  -- complex user mvs (mvs that can't be fast refreshed)
 num_mav        number;                                          -- (user) mavs
 num_mjv        number;                                          -- (user) mjvs
 num_mav1       number;                                         -- (user) mav1s
 num_oncmt      number;                                   -- on-commit user mvs
 num_enqrw      number;                           -- rewrite enabled (user) mvs
 num_rmt        number;                                    -- remote (user) mvs
 num_pk         number;                                        -- pk (user) mvs
 num_rid        number;                                     -- rowid (user) mvs
 num_obj        number;                                    -- object (user) mvs
 feature_usage  varchar2(1000);
 user_mv_test   varchar2(100);

BEGIN
  -- initialize
  num_mv := 0;                                   
  num_ondmd := 0;
  num_cmplx := 0;
  num_mav := 0;
  num_mjv := 0;
  num_mav1 := 0;
  num_oncmt := 0;
  num_enqrw := 0;
  num_rmt := 0;
  num_pk := 0;
  num_rid := 0;
  num_obj := 0;
  user_mv_test := ' s.sowner not in (''SYS'', ''SYSTEM'', ''SH'', ''SYSMAN'')';

  feature_boolean := 0;
  aux_count := 0;

  /* get the user mv count (user mvs of all types) */
  execute immediate 'select count(*) from dba_mviews
                     where owner not in (''SYS'', ''SYSTEM'', ''SH'', ''SYSMAN'')'
  into num_mv;

  if (num_mv > 0)
  then

    /* get number of rowid (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 16) = 16 and' || user_mv_test
    into num_rid;

    /* get number of pk (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 32) = 32 and' || user_mv_test
    into num_pk;

    /* get number of on-demand user mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 64) = 64 and' || user_mv_test
    into num_ondmd;

    /* get number of complex user mvs (mvs that can't be fast refreshed) */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 256) = 256 and' || user_mv_test
    into num_cmplx;

    /* get number of (user) mavs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 4096) = 4096 and' || user_mv_test
    into num_mav;

    /* get number of (user) mjvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 8192) = 8192 and' || user_mv_test
    into num_mjv;

    /* get number of (user) mav1s */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 16384) = 16384 and' || user_mv_test
    into num_mav1;

    /* get number of on-commit user mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 32768) = 32768 and' || user_mv_test
    into num_oncmt;

    /* get number of rewrite enabled (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 1048576) = 1048576 and' ||
                       user_mv_test
    into num_enqrw;

    /* get number of remote (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where s.mlink is not null and' || user_mv_test
    into num_rmt;

    /* get number of object (user) mvs */
    execute immediate 'select count(*) from snap$ s
                       where bitand(s.flag, 536870912) = 536870912 and' ||
                       user_mv_test
    into num_obj;

    feature_boolean := 1;

    feature_usage := 'total number of user mvs (user mvs of all types):' || to_char(num_mv) ||
          ',' || ' num of (user) mavs:' || to_char(num_mav) ||
          ',' || ' num of (user) mjvs:' || to_char(num_mjv) ||
          ',' || ' num of (user) mav1s:' || to_char(num_mav1) ||
          ',' || ' num of on-demand user mvs:' || to_char(num_ondmd) ||
          ',' || ' num of on-commit user mvs:' || to_char(num_oncmt) ||
          ',' || ' num of remote (user) mvs:' || to_char(num_rmt) ||
          ',' || ' num of pk (user) mvs:' || to_char(num_pk) ||
          ',' || ' num of rowid (user) mvs:' || to_char(num_rid) ||
          ',' || ' num of object (user) mvs:' || to_char(num_obj) ||
          ',' || ' num of rewrite enabled (user) mvs:' || to_char(num_enqrw) ||
          ',' || ' num of complex user mvs:' || to_char(num_cmplx) ||
          '.';

    feature_info := to_clob(feature_usage);
  else
    feature_info := to_clob('User MVs do not exist.');
  end if;

end;
/


/****************************************************************
 * DBMS_FEATURE_HCC
 * The procedure to detect usage for Hybrid Columnar Compression
 ****************************************************************/

create or replace procedure DBMS_FEATURE_HCC
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    num_cmp_dollar        number;
    num_level1            number;
    num_level2            number;
    num_level3            number;
    num_hcc               number;
    num_dmls              number;
    blk_level1            number;
    blk_level2            number;
    blk_level3            number;
    blk_nonhcc            number;
    blk_nonhcctry         number;

begin
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    num_cmp_dollar := 0;
    num_hcc := 0;
    num_level1  := 0;
    num_level2  := 0;
    num_level3  := 0;
    blk_level1 := 0;
    blk_level2 := 0;
    blk_level3 := 0;

    -- check for Data Guard usage by counting valid standby destinations
    execute immediate 'select count(*) from compression$ '
        into num_cmp_dollar;

    -- check if there is something compressed
    execute immediate 'select count(*) from seg$ s ' ||
         ' where bitand(s.spare1, 100663296) = 33554432 OR ' ||
               ' bitand(s.spare1, 100663296) = 67108864 OR ' ||
               ' bitand(s.spare1, 100663296) = 100663296 '
        into num_hcc;
    
    if ((num_cmp_dollar > 0) OR (num_hcc > 0)) then
    
        feature_boolean := 1;

        -- check for HCC for Query LOW (level 1)
        execute immediate 'select count(*) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 100663296) = 33554432 '
           into num_level1;

        execute immediate 'select sum(blocks) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 100663296) = 33554432 '
           into blk_level1;

        -- check for HCC for Query HIGH (level 2)
        execute immediate 'select count(*) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 100663296) = 67108864 '
           into num_level2;

        execute immediate 'select sum(blocks) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 100663296) = 67108864 '
           into blk_level2;

        -- check for HCC for Archive (level 3)
        execute immediate 'select count(*) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 100663296) = 100663296 '
           into num_level3;

        execute immediate 'select sum(blocks) from seg$ s ' ||
          ' where bitand(s.spare1, 2048) = 2048 AND ' ||
                ' bitand(s.spare1, 100663296) = 100663296 '
           into blk_level3;

        -- track OLTP compression (non-HCC compression) w/in HCC
        execute immediate 'select value from v$sysstat' ||
            ' where name like ''EHCC Block Compressions'''
            into blk_nonhcc;

        execute immediate 'select value from v$sysstat' ||
            ' where name like ''EHCC Attempted' ||
            ' Block Compressions'''
            into blk_nonhcctry;

        execute immediate 'select value from v$sysstat' ||
            ' where name like ''EHCC Conventional DMLs'''
            into num_dmls;

     feature_usage :=
      'Number of Hybrid Columnar Compressed Segments: ' || to_char(num_hcc) ||
        ', ' || ' Segments Analyzed: ' || to_char(num_cmp_dollar) ||
        ', ' || ' Segments Compressed Query Low: ' || to_char(num_level1) ||
        ', ' || ' Blocks Compressed Query Low: ' || to_char(blk_level1) ||
        ', ' || ' Segments Compressed Query High: ' || to_char(num_level2) ||
        ', ' || ' Blocks Compressed Query High: ' || to_char(blk_level2) ||
        ', ' || ' Segments Compressed Archive: ' || to_char(num_level3) ||
        ', ' || ' Blocks Compressed Archive: ' || to_char(blk_level3) ||
        ', ' || ' Blocks Compressed Non-HCC: ' || to_char(blk_nonhcc) || 
        ', ' || ' Attempts to Block Compress: ' || to_char(blk_nonhcctry) || 
        ', ' || ' Conventional DMLs: ' || to_char(num_dmls);

        feature_info := to_clob(feature_usage);
    else
        feature_info := to_clob('Hybrid Columnar Compression not detected');
    end if;

end;
/
show errors;

CREATE OR REPLACE LIBRARY DBMS_STORAGE_TYPE_LIB TRUSTED AS STATIC;
/
create or replace procedure kdzstoragetype(tsn IN number, type out NUMBER) as
  LANGUAGE C
  NAME "kdzstoragetype"
  LIBRARY DBMS_STORAGE_TYPE_LIB
  with context
  PARAMETERS (context, tsn OCINumber, type OCINumber);
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_ZFS_STORAGE
 * Procedure to detect use of ZFS storage
 *****************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_ZFS_STORAGE
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  feature_count NUMBER;
  tsn           NUMBER;
  stortype      NUMBER;
  TYPE cursor_t         IS REF CURSOR;
  cursor_objtype        cursor_t;
  feature_usage         varchar2(1000);
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  OPEN cursor_objtype FOR q'[select ts# from sys.ts$]';

  LOOP
    BEGIN
      FETCH cursor_objtype INTO tsn;
      EXIT WHEN cursor_objtype%NOTFOUND;
      kdzstoragetype(tsn, stortype);
      IF (stortype = 1) THEN
        feature_count := feature_count + 1;
      END IF;
    END;
  END LOOP;

  feature_usage := 'TS on ZFS: ' || to_char(feature_count);
  feature_info := to_clob(feature_usage);

  if (feature_count > 0) then
    feature_boolean := 1;
  else
    feature_boolean := 0;
  end if;
  aux_count       := feature_count;
END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_PILLAR_STORAGE
 * Procedure to detect use of PILLAR storage
 *****************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_PILLAR_STORAGE
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  feature_count  NUMBER;
  tsn            NUMBER;
  stortype       NUMBER;
  TYPE cursor_t  IS REF CURSOR;
  cursor_objtype cursor_t;
  feature_usage         varchar2(1000);
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  OPEN cursor_objtype FOR q'[select ts# from sys.ts$]';

  LOOP
    BEGIN
      FETCH cursor_objtype INTO tsn;
      EXIT WHEN cursor_objtype%NOTFOUND;
      kdzstoragetype(tsn, stortype);
      IF (stortype = 2) THEN
        feature_count := feature_count + 1;
      END IF;
    END;
  END LOOP;

  feature_usage := 'TS on Pillar: ' || to_char(feature_count);
  feature_info := to_clob(feature_usage);
  
  if (feature_count > 0) then
    feature_boolean := 1;
  else
    feature_boolean := 0;
  end if;  
  aux_count       := feature_count;
END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_ZFS_EHCC
 * Procedure to detect use of ZFS storage with EHCC
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_ZFS_EHCC
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  feature_count NUMBER;
  feature_usage         varchar2(1000);
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  execute immediate 'select value from v$sysstat' ||
    ' where name like ''EHCC Used on ZFS Tablespace'''
    into feature_count;

  feature_usage := 'EHCC on ZFS: ' || to_char(feature_count);
  feature_info := to_clob(feature_usage);

  if (feature_count > 0) then
    feature_boolean := 1; 
  else
    feature_boolean := 0;
  end if;
  aux_count       := feature_count;
end;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_PILLAR_EHCC
 * Procedure to detect use of Pillar storage with EHCC
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_PILLAR_EHCC
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  feature_count NUMBER;
    feature_usage         varchar2(1000);
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  execute immediate 'select value from v$sysstat' ||
    ' where name like ''EHCC Used on Pillar Tablespace'''
    into feature_count;

  feature_usage := 'EHCC on Pillar: ' || to_char(feature_count);
  feature_info := to_clob(feature_usage);

  if (feature_count > 0) then
    feature_boolean := 1; 
  else
    feature_boolean := 0;
  end if;
  aux_count       := feature_count;
end;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_SECUREFILES_USR
 * Procedure to detect usage of Oracle SecureFiles 
 * by non-system users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SECUREFILES_USR
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;
END;
/
show errors;


/*****************************************************************
 * DBMS_FEATURE_SECUREFILES_SYS
 * Procedure to detect usage of Oracle SecureFiles
 * by system (internal) users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SECUREFILES_SYS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;
END;
/
show errors;


/*****************************************************************
 * DBMS_FEATURE_SFENCRYPT_USR
 * Procedure to detect usage of Oracle SecureFile Encryption
 * by non-system users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFENCRYPT_USR
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 4096), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 4096), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 4096), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;
END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_SFENCRYPT_SYS
 * Procedure to detect usage of Oracle SecureFile Encryption
 * by system (internal) users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFENCRYPT_SYS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 4096), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 4096), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 4096), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;
END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_SFCOMPRESS_USR
 * Procedure to detect usage of Oracle SecureFile Compression
 * by non-system users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFCOMPRESS_USR
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 57344), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 57344), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 57344), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;

END;
/
show errors;

/*****************************************************************
 * DBMS_FEATURE_SFCOMPRESS_SYS
 * Procedure to detect usage of Oracle SecureFile Compression
 * by system (internal) users
 *****************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFCOMPRESS_SYS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 57344), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 57344), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 57344), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;

END;
/
show errors;

/********************************************************************
 * DBMS_FEATURE_SFDEDUP_USR
 * Procedure to detect usage of Oracle SecureFile Deduplication
 * by non-system users
 ********************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFDEDUP_USR
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 458752), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 458752), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 458752), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# not in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;

END;
/
show errors;

/********************************************************************
 * DBMS_FEATURE_SFDEDUP_SYS
 * Procedure to detect usage of Oracle SecureFile Deduplication
 * by system (internal) users
 ********************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_SFDEDUP_SYS
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_count      NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_count     := 0;

  -- skip internal usage by flashback archive
  select count(*) into feature_count from (
    select l.obj#, l.lobj#, l.lobj#, l.lobj#, 'U' fragtype  
      from tab$ t, lob$ l, obj$ o
      where l.obj#=t.obj# and 
            decode(bitand(l.property, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(l.flags, 458752), 0, 'NO', 'YES')='YES' and 
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                             where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select pl.tabobj#, pl.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, partlob$ pl, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 458752), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=pl.lobj# and pl.tabobj#=t.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
    union
    select l.obj#, lc.lobj#, fragobj#, parentobj#, fragtype$ 
      from lobfrag$ lf, lobcomppart$ lc, lob$ l, tab$ t, obj$ o
      where decode(bitand(lf.fragpro, 2048), 0, 'NO', 'YES')='YES' and
            decode(bitand(lf.fragflags, 458752), 0, 'NO', 'YES')='YES' and 
            lf.parentobj#=lc.partobj# and l.lobj#=lc.lobj# and 
            t.obj#=l.obj# and  
            decode(bitand(t.property, 8589934592), 0, 'NO', 'YES')='NO' and
            o.obj# = t.obj# and 
            o.owner# in (select user# from user$ 
                         where name in ('SYS', 'SYSTEM', 'XDB'))
  );
  
  feature_boolean := feature_count;
  aux_count       := feature_count;

END;
/
show errors;

/***************************************************************
 * DBMS_FEATURE_DATA_GUARD
 * The procedure to detect usage for Data Guard
 ***************************************************************/

create or replace procedure DBMS_FEATURE_DATA_GUARD
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    log_transport         varchar2(25);
    num_arch              number;
    num_compression       number;
    num_lgwr_async        number;
    num_lgwr_sync         number;
    num_realtime_apply    number;
    num_redo_apply        number;
    num_snapshot          number;
    num_sql_apply         number;
    num_standbys          number;
    protection_mode       varchar2(24);
    use_broker            varchar2(5);
    use_compression       varchar2(8);
    use_flashback         varchar2(18);
    use_fs_failover       varchar2(22);
    use_realtime_apply    varchar2(5);
    use_redo_apply        varchar2(5);
    use_snapshot          varchar2(5);
    use_sql_apply         varchar2(5);

begin
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    log_transport := NULL;
    num_arch := 0;
    num_compression := 0;
    num_lgwr_async := 0;
    num_lgwr_sync := 0;
    num_realtime_apply := 0;
    num_redo_apply := 0;
    num_snapshot := 0;
    num_sql_apply := 0;
    num_standbys := 0;
    use_broker := 'FALSE';
    use_compression := 'FALSE';
    use_flashback := 'FALSE';
    use_fs_failover := 'FALSE';
    use_realtime_apply := 'FALSE';
    use_redo_apply := 'FALSE';
    use_snapshot := 'FALSE';
    use_sql_apply := 'FALSE';

    -- check for Data Guard usage by counting valid standby destinations
    execute immediate 'select count(*) from v$archive_dest ' ||
        'where status = ''VALID'' and target = ''STANDBY'''
        into num_standbys;

    if (num_standbys > 0) then
        feature_boolean := 1;

        -- check for Redo Apply (Physical Standby) usage
        execute immediate 'select count(*) from v$archive_dest_status ' ||
            'where status = ''VALID'' and type = ''PHYSICAL'''
            into num_redo_apply;
        if (num_redo_apply > 0) then
            use_redo_apply := 'TRUE';
        end if;

        -- check for SQL Apply (Logical Standby) usage
        execute immediate 'select count(*) from v$archive_dest_status ' ||
            'where status = ''VALID'' and type = ''LOGICAL'''
            into num_sql_apply;
        if (num_sql_apply > 0) then
            use_sql_apply := 'TRUE';
        end if;

        -- check for Snapshot Standby usage
        execute immediate 'select count(*) from v$archive_dest_status ' ||
            'where status = ''VALID'' and type = ''SNAPSHOT'''
            into num_snapshot;
        if (num_snapshot > 0) then
            use_snapshot := 'TRUE';
        end if;

        -- check for Broker usage by selecting the init param value
        execute immediate 'select value from v$system_parameter ' ||
            'where name = ''dg_broker_start'''
            into use_broker;

        -- get all log transport methods
        execute immediate 'select count(*) from v$archive_dest ' ||
            'where status = ''VALID'' and target = ''STANDBY'' ' ||
            'and archiver like ''ARC%'''
            into num_arch;
        if (num_arch > 0) then
            log_transport := 'ARCH ';
        end if;
        execute immediate 'select count(*) from v$archive_dest ' ||
            'where status = ''VALID'' and target = ''STANDBY'' ' ||
            'and archiver = ''LGWR'' ' ||
            'and (transmit_mode = ''SYNCHRONOUS'' or ' ||
            '     transmit_mode = ''PARALLELSYNC'')'
            into num_lgwr_sync;
        if (num_lgwr_sync > 0) then
            log_transport := log_transport || 'LGWR SYNC ';
        end if;
        execute immediate 'select count(*) from v$archive_dest ' ||
            'where status = ''VALID'' and target = ''STANDBY'' ' ||
            'and archiver = ''LGWR'' ' ||
            'and transmit_mode = ''ASYNCHRONOUS'''
            into num_lgwr_async;
        if (num_lgwr_async > 0) then
            log_transport := log_transport || 'LGWR ASYNC';
        end if;

        -- get protection mode for primary db
        execute immediate 'select protection_mode from v$database'
            into protection_mode;

        -- check for fast-start failover usage
        execute immediate 'select fs_failover_status from v$database'
            into use_fs_failover;
        if (use_fs_failover != 'DISABLED') then
            use_fs_failover := 'TRUE';
        else
            use_fs_failover := 'FALSE';
        end if;

        -- check for realtime apply usage
        execute immediate 'select count(*) from v$archive_dest_status ' ||
            'where status = ''VALID'' ' ||
            'and recovery_mode like ''%REAL TIME APPLY'''
            into num_realtime_apply;
        if (num_realtime_apply > 0) then
            use_realtime_apply := 'TRUE';
        end if;

        -- check for network compression usage
        execute immediate 'select count(*) from v$archive_dest ' ||
            'where status = ''VALID'' and target = ''STANDBY'' ' ||
            'and compression = ''ENABLE'''
            into num_compression;
        if (num_compression > 0) then
            use_compression := 'TRUE';
        end if;

        -- check for flashback usage
        execute immediate 'select flashback_on from v$database'
            into use_flashback;
        if (use_flashback = 'YES') then
            use_flashback := 'TRUE';
        else
            use_flashback := 'FALSE';
        end if;

        feature_usage :=
                'Number of standbys: ' || to_char(num_standbys) ||
        ', ' || 'Redo Apply used: ' || upper(use_redo_apply) ||
        ', ' || 'SQL Apply used: ' || upper(use_sql_apply) ||
        ', ' || 'Snapshot Standby used: ' || upper(use_snapshot) ||
        ', ' || 'Broker used: ' || upper(use_broker) ||
        ', ' || 'Protection mode: ' || upper(protection_mode) ||
        ', ' || 'Log transports used: ' || upper(log_transport) ||
        ', ' || 'Fast-Start Failover used: ' || upper(use_fs_failover) ||
        ', ' || 'Real-Time Apply used: ' || upper(use_realtime_apply) ||
        ', ' || 'Compression used: ' || upper(use_compression) ||
        ', ' || 'Flashback used: ' || upper(use_flashback)
        ;
        feature_info := to_clob(feature_usage);
    else
        feature_info := to_clob('Data Guard usage not detected');
    end if;

end;
/

/***************************************************************
 * DBMS_FEATURE_DATA_REDACTION
 * The procedure to detect usage for Data Redaction
 ***************************************************************/

create or replace procedure DBMS_FEATURE_DATA_REDACTION
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
    feature_usage         varchar2(1000);
    num_policies          number;
    num_policies_enabled  number;
    num_full_redaction    number;
    num_partial_redaction number;
    num_random_redaction  number;
    num_regexp_redaction   number;

begin
    -- initialize
    feature_boolean := 0;
    aux_count := 0;
    num_policies := 0;
    num_policies_enabled := 0;
    num_full_redaction := 0;
    num_partial_redaction := 0;
    num_random_redaction := 0;
    num_regexp_redaction := 0;
    
    -- check for Data Redaction usage by counting number of policies
    execute immediate 'select count(*) from REDACTION_POLICIES '
        into num_policies;

    if (num_policies > 0) then
        feature_boolean := 1;

        -- check for enable Data Radaction policy usage
        execute immediate 'select count(*) from REDACTION_POLICIES ' ||
            'where upper(ENABLE) like ''%YES%'''
            into num_policies_enabled;

        -- check for Full Data Redaction type usage
        execute immediate 'select count(*) from REDACTION_COLUMNS ' ||
            'where FUNCTION_TYPE = ''FULL REDACTION'''
            into num_full_redaction;
     
        -- check for Partial Data Redaction type usage
        execute immediate 'select count(*) from REDACTION_COLUMNS ' ||
            'where FUNCTION_TYPE = ''PARTIAL REDACTION'''
            into num_partial_redaction;

        -- check for Random Data Redaction type usage
        execute immediate 'select count(*) from REDACTION_COLUMNS ' ||
            'where FUNCTION_TYPE = ''RANDOM REDACTION'''
            into num_random_redaction;

        -- check for Regexp-based Data Redaction type usage
        execute immediate 'select count(*) from REDACTION_COLUMNS ' ||
            'where FUNCTION_TYPE = ''REGEXP REDACTION'''
            into num_regexp_redaction;

        feature_usage :=
                'Number of data redaction policies: ' || 
                 to_char(num_policies) ||
        ', ' || 'Number of enabled policies: ' || 
                 to_char(num_policies_enabled) ||
        ', ' || 'Number of policies using full redaction: ' || 
                 to_char(num_full_redaction) ||
        ', ' || 'Number of policies using partial redaction: ' || 
                 to_char(num_partial_redaction) ||
        ', ' || 'Number of policies using random redaction: ' || 
                 to_char(num_random_redaction)  ||
        ', ' || 'Number of policies using regexp redaction: ' || 
                 to_char(num_regexp_redaction)
        ;
        feature_info := to_clob(feature_usage);
    else
        feature_info := to_clob('Data Redaction usage not detected');
    end if;

end;
/


/***************************************************************
 * DBMS_FEATURE_DYN_SGA
 * The procedure to detect usage of Dynamic SGA
 ***************************************************************/

create or replace procedure DBMS_FEATURE_DYN_SGA
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  num_resize_ops         number;                 -- number of resize operations
  feature_usage          varchar2(1000);
begin
  -- initialize
  num_resize_ops := 0;
  feature_boolean := 0;
  aux_count := 0;
  feature_info := to_clob('Dynamic SGA usage not detected');
  feature_usage := '';

  execute immediate 'select count(*) from v$sga_resize_ops ' ||
                    'where oper_type in (''GROW'', ''SHRINK'') and ' ||
                    'oper_mode=''MANUAL''and ' ||
                    'start_time >= ' ||
                    'to_date((select nvl(max(last_sample_date), sysdate-7) ' ||
                    'from dba_feature_usage_statistics))'
  into num_resize_ops;

  if num_resize_ops > 0
  then

    feature_boolean := 1;

    feature_usage := feature_usage||':rsz ops:'||num_resize_ops;

    -- get v$memory_dynamic_components info
    for item in (select component, current_size, min_size, max_size,
                 user_specified_size from
                 v$memory_dynamic_components where current_size != 0)
    loop
      feature_usage := feature_usage||':comp:'||item.component||
                       ':cur:'||item.current_size||':min:'||
                       item.min_size||':max:'||item.max_size||
                       ':usr:'||item.user_specified_size;
    end loop;

    -- get v$system_event info for SGA events
    for item in (select substr(event, 0, 15) evt, total_waits, time_waited
                 from v$system_event where event like '%SGA%')
    loop
      feature_usage := feature_usage||':event:'||item.evt||':waits:'||
                       item.total_waits||':time:'||item.time_waited;
    end loop;

    feature_info := to_clob(feature_usage);

  end if;

end;
/

/***************************************************************
 * DBMS_FEATURE_AUTO_SGA
 * The procedure to detect usage of Automatic SGA Tuning
 ***************************************************************/

create or replace procedure DBMS_FEATURE_AUTO_SGA
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  feature_usage          varchar2(1000);
  sga_target             number;
  sga_max_size           number;
begin

  -- initialize
  feature_boolean := 0;
  aux_count := 0;
  feature_info := to_clob('Automatic SGA Tuning usage not detected');
  feature_usage := '';
  sga_target := 0;
  sga_max_size := 0;

  execute immediate 'select to_number(value) from v$system_parameter where ' ||
                    'name like ''sga_target'''
  into sga_target;

  if sga_target > 0
  then

    feature_boolean := 1;

    feature_usage := feature_usage||':sga_target:'||sga_target;

    -- get sga_max_size value
    execute immediate 'select to_number(value) from v$system_parameter where ' ||
                      'name like ''sga_max_size'''
    into sga_max_size;

    feature_usage := feature_usage||':sga_max_size:'||sga_max_size;

    -- get v$memory_dynamic_components info
    for item in (select component, current_size, min_size, max_size,
                 user_specified_size from
                 v$memory_dynamic_components where current_size != 0)
    loop
      feature_usage := feature_usage||':comp:'||item.component||
                       ':cur:'||item.current_size||':min:'||
                       item.min_size||':max:'||item.max_size||
                       ':usr:'||item.user_specified_size;
    end loop;

    -- get v$system_event info for SGA events
    for item in (select substr(event, 0, 15) evt, total_waits, time_waited
                 from v$system_event where event like '%SGA%')
    loop
      feature_usage := feature_usage||':event:'||item.evt||':waits:'||
                       item.total_waits||':time:'||item.time_waited;
    end loop;
    feature_info := to_clob(feature_usage);

  end if;

end;
/

/***************************************************************
 * DBMS_FEATURE_AUTO_MEM
 * The procedure to detect usage of Automatic Memory Tuning
 ***************************************************************/

create or replace procedure DBMS_FEATURE_AUTO_MEM
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  feature_usage          varchar2(1000);
  memory_target             number;
  sga_max_size              number;
  memory_max_target         number;
begin

  -- initialize
  feature_boolean := 0;
  aux_count := 0;
  feature_info := to_clob('Automatic Memory Tuning usage not detected');
  feature_usage := '';
  memory_target := 0;
  sga_max_size := 0;
  memory_max_target := 0;

  execute immediate 'select to_number(value) from v$system_parameter where ' ||
                    'name like ''memory_target'''
  into memory_target;

  if memory_target > 0
  then

    feature_boolean := 1;

    feature_usage := feature_usage||':memory_target:'||memory_target;

    -- get sga_max_size value
    execute immediate 'select to_number(value) from v$system_parameter where ' ||
                      'name like ''sga_max_size'''
    into sga_max_size;

    feature_usage := feature_usage||':sga_max_size:'||sga_max_size;

    -- get memory_max_target value
    execute immediate 'select to_number(value) from v$system_parameter where ' ||
                      'name like ''memory_max_target'''
    into memory_max_target;

    feature_usage := feature_usage||':memory_max_target:'||memory_max_target;

    -- get v$memory_dynamic_components info
    for item in (select component, current_size, min_size, max_size,
                 user_specified_size from
                 v$memory_dynamic_components where current_size != 0)
    loop
      feature_usage := feature_usage||':comp:'||item.component||
                       ':cur:'||item.current_size||':min:'||
                       item.min_size||':max:'||item.max_size||
                       ':usr:'||item.user_specified_size;
    end loop;

    -- get v$pgastat info
    for item in (select name, value from v$pgastat where
                 name in ('tot PGA alc', 'over alc cnt',
                          'tot PGA for auto wkar',
                          'tot PGA for man wkar',
                          'glob mem bnd', 'aggr PGA auto tgt',
                          'aggr PGA tgt prm'))
    loop
      feature_usage := feature_usage||':'||item.name||':'||item.value;
    end loop;

    -- get v$memory_target_advice info
    feature_usage := feature_usage||':mem tgt adv:';
    for item in (select memory_size, memory_size_factor, estd_db_time,
                 estd_db_time_factor from v$memory_target_advice
                 order by memory_size)
    loop
      feature_usage := feature_usage||':msz:'||item.memory_size||
                       ':sf:'||item.memory_size_factor||
                       ':time:'||item.estd_db_time||
                       ':tf:'||item.estd_db_time_factor;
    end loop;

    -- get v$system_event info for SGA events
    for item in (select substr(event, 0, 15) evt, total_waits, time_waited
                 from v$system_event where event like '%SGA%')
    loop
      feature_usage := feature_usage||':event:'||item.evt||':waits:'||
                       item.total_waits||':time:'||item.time_waited;
    end loop;

    feature_info := to_clob(feature_usage);

  end if;

end;
/

/***************************************************************
 * DBMS_FEATURE_RESOURCE_MANAGER
 * The procedure to detect usage of Resource Manager
 ***************************************************************/

create or replace procedure DBMS_FEATURE_RESOURCE_MANAGER
    (feature_boolean  OUT  NUMBER,
     aux_count        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  feature_usage             varchar2(1000);
  non_maint_sql             varchar2(1000);
  non_maint_usage           number;
  non_maint_cpu             number;
  non_maint_other           number;
begin

  -- Initialize all variables

  feature_boolean := 0;  
  aux_count       := 0;
  feature_info    := to_clob('Resource Manager usage not detected');

  feature_usage   := NULL;
  non_maint_sql   := NULL;
  non_maint_cpu   := 0;
  non_maint_other := 0;

  -- 'feature_boolean' is set to 1 if Resource Manager was enabled, not
  -- including for maintenance windows.

  non_maint_sql := 
      'select decode(count(*), 0, 0, 1) from v$rsrc_plan_history where ' ||
      'name != ''INTERNAL_PLAN'' and name is not null and ' ||
      '(name != ''DEFAULT_MAINTENANCE_PLAN'' or ' ||
      '  (window_name is null or ' ||
      '   (window_name != ''MONDAY_WINDOW'' and ' ||
      '    window_name != ''TUESDAY_WINDOW'' and ' ||
      '    window_name != ''WEDNESDAY_WINDOW'' and ' ||
      '    window_name != ''THURSDAY_WINDOW'' and ' ||
      '    window_name != ''FRIDAY_WINDOW'' and ' ||
      '    window_name != ''SATURDAY_WINDOW'' and ' ||
      '    window_name != ''SUNDAY_WINDOW''))) ';

  execute immediate
    non_maint_sql
  into feature_boolean;

  -- 'aux_count' is not being used

  -- 'feature_info' is constructed of the following name-value pairs:
  --   Non-Maintenance CPU Management:
  --     This field is set to 1 if Resource Manager was enabled explicitly
  --     and the Resource Plan was managing CPU.
  --   Non-Maintenance Other Management:
  --     This field is set to 1 if Resource Manager was enabled explicitly
  --     and the Resource Plan was NOT managing CPU, i.e. the Resource Plan
  --     was managing idle time, switch time, DOP, etc.

  if feature_boolean > 0
  then
    execute immediate 
      non_maint_sql || ' and cpu_managed = ''ON'' '
    into non_maint_cpu;

    execute immediate 
      non_maint_sql || ' and cpu_managed = ''OFF'' '
    into non_maint_other;

    feature_usage := 
      'Non-Maintenance CPU Management: ' || non_maint_cpu ||
      ', Non-Maintenance Other Management: ' || non_maint_other;

    feature_info := to_clob(feature_usage);
  end if;

end dbms_feature_resource_manager;
/
show errors;


/***************************************************************
 * DBMS_FEATURE_RMAN_ZLIB
 *  The procedure to detect usage of RMAN ZLIB compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_ZLIB
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted => FALSE, 
                    compalg => 'ZLIB');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_BZIP2
 *  The procedure to detect usage of RMAN BZIP2 compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_BZIP2
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'BZIP2');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_BASIC
 *  The procedure to detect usage of RMAN BASIC compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_BASIC
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'BASIC');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_LOW
 *  The procedure to detect usage of RMAN LOW compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_LOW
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'LOW');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_MEDIUM
 *  The procedure to detect usage of RMAN MEDIUM compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_MEDIUM
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'MEDIUM');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_HIGH
 *  The procedure to detect usage of RMAN HIGH compression
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_HIGH
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => 'HIGH');
    
    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/


/***************************************************************
 * DBMS_FEATURE_BACKUP_ENCRYPTION
 *  The procedure to detect usage of RMAN ENCRYPTION on backups
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_BACKUP_ENCRYPTION
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => TRUE, 
                    compalg     => NULL);

    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/


/***************************************************************
 * DBMS_FEATURE_RMAN_BACKUP
 *  The procedure to detect usage of RMAN backups
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_BACKUP
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => NULL);

    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_DISK_BACKUP
 *  The procedure to detect usage of RMAN backups on DISK
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_DISK_BACKUP
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => TRUE, 
                    nondiskonly => FALSE, 
                    encrypted   => FALSE, 
                    compalg     => NULL);

    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/

/***************************************************************
 * DBMS_FEATURE_RMAN_TAPE_BACKUP
 *  The procedure to detect usage of RMAN backups
 ***************************************************************/

CREATE OR REPLACE PROCEDURE DBMS_FEATURE_RMAN_TAPE_BACKUP
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
BEGIN

    /* assume that feature is not used. */
    feature_boolean := 0;
    aux_count := 0;
    feature_info := NULL;

    aux_count := sys.dbms_backup_restore.rman_usage(
                    diskonly    => FALSE, 
                    nondiskonly => TRUE, 
                    encrypted   => FALSE, 
                    compalg     => NULL);

    IF aux_count > 0 THEN
       feature_boolean := 1;
    END IF;
END;
/


/***************************************************************
 * DBMS_FEATURE_AUTO_SSM
 *  The procedure to detect usage for Automatic Segment Space
 *  Managed tablespaces
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_auto_ssm
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  auto_seg_space boolean;
  ts_info        varchar2(1000);
BEGIN

  /* initialize everything */
  auto_seg_space := FALSE;
  ts_info        := '';
  aux_count      := 0;

  for ts_type in 
     (select segment_space_management, count(*) tcount, sum(size_mb) size_mb
       from
        (select ts.tablespace_name, segment_space_management, 
              sum(bytes)/1048576 size_mb
          from dba_data_files df, dba_tablespaces ts
         where df.tablespace_name = ts.tablespace_name
         group by ts.tablespace_name, segment_space_management)
       group by segment_space_management)
  loop

    /* check for auto segment space management */    
    if ((ts_type.segment_space_management = 'AUTO') and
         (ts_type.tcount > 0)) then
      auto_seg_space  := TRUE;
      aux_count       := ts_type.tcount;
    end if;

    ts_info := ts_info || 
        '(Segment Space Management: ' || ts_type.segment_space_management ||
       ', TS Count: ' || ts_type.tcount ||
       ', Size MB: '  || ts_type.size_mb || ') ';

  end loop; 

  /* set the boolean and feature info.  the aux count is already set above */
  if (auto_seg_space) then
    feature_boolean := 1;
    feature_info    := to_clob(ts_info);
  else
    feature_boolean := 0;
    feature_info    := null;
  end if;

END dbms_feature_auto_ssm;
/

show errors;


/******************************************************************
 * DBMS_FEATURE_LMT
 *  The procedure to detect usage for Locally Managed tablespaces
 ******************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_lmt
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  loc_managed boolean;
  ts_info     varchar2(1000);  
BEGIN

  /* initialize everything */
  loc_managed := FALSE;
  ts_info     := '';
  aux_count   := 0;

  for ts_type in 
     (select extent_management, count(*) tcount, sum(size_mb) size_mb
       from
        (select ts.tablespace_name, extent_management, 
                sum(bytes)/1048576 size_mb
           from dba_data_files df, dba_tablespaces ts
          where df.tablespace_name = ts.tablespace_name
          group by ts.tablespace_name, extent_management)
       group by extent_management)
  loop

    /* check for auto segment space management */    
    if ((ts_type.extent_management = 'LOCAL') and
         (ts_type.tcount > 0)) then
      loc_managed  := TRUE;
      aux_count       := ts_type.tcount;
    end if;

    ts_info := ts_info || 
        '(Extent Management: ' || ts_type.extent_management ||
       ', TS Count: ' || ts_type.tcount ||
       ', Size MB: '  || ts_type.size_mb || ') ';

  end loop; 

  /* set the boolean and feature info.  the aux count is already set above */
  if (loc_managed) then
    feature_boolean := 1;
    feature_info    := to_clob(ts_info);
  else
    feature_boolean := 0;
    feature_info    := null;
  end if;

END dbms_feature_lmt;
/

show errors;

/******************************************************************
 * DBMS_FEATURE_SEGADV_USER
 *  The procedure to detect usage for Segment Advisor (user)
 ******************************************************************/

CREATE OR REPLACE PROCEDURE dbms_feature_segadv_user
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  execs_since_sample    NUMBER;               -- # of execs since last sample
  total_execs           NUMBER;               -- total # of execs
  total_recs            NUMBER;               -- total # of recommendations
  total_space_saving    NUMBER;               -- total potential space saving
  tmp_buf               VARCHAR2(32767);      -- temp buffer
BEGIN
  -- executions since last sample
  SELECT  count(*) 
  INTO    execs_since_sample
  FROM    dba_advisor_executions
  WHERE   advisor_name = 'Segment Advisor' AND
          task_name not like 'SYS_AUTO_SPCADV%' AND
          execution_last_modified >= (SELECT nvl(max(last_sample_date),
                                                sysdate-7) 
                                     FROM   dba_feature_usage_statistics);
      
  -- total # of executions
  SELECT  count(*) 
  INTO    total_execs
  FROM    dba_advisor_executions
  WHERE   advisor_name = 'Segment Advisor' AND
          task_name not like 'SYS_AUTO_SPCADV%';

  -- total # of recommendations and total potential space saving
  SELECT  count(task.task_id), NVL(sum(msg.p3),0)
  INTO    total_recs, total_space_saving
  FROM    dba_advisor_tasks task, 
          sys.wri$_adv_findings fin,
          sys.wri$_adv_recommendations rec,
          sys.wri$_adv_message_groups msg
  WHERE   task.advisor_name = 'Segment Advisor' AND
          task.task_name not like 'SYS_AUTO_SPCADV%' AND
          task.task_id = rec.task_id AND
          nvl(rec.annotation,0) <> 3 AND
          fin.task_id = rec.task_id AND 
          fin.id = rec.finding_id AND
          msg.task_id = fin.task_id AND 
          msg.id = fin.more_info_id;
  
  -- set feature_used and aux_count 
  feature_boolean := execs_since_sample;
  aux_count := execs_since_sample;

  -- prepare feature_info
  tmp_buf := 'Executions since last sample: ' || execs_since_sample || ', ' ||
             'Total Executions: ' || total_execs || ', ' ||
             'Total Recommendations: ' || total_recs   || ', ' ||
             'Projected Space saving (byte): ' || total_space_saving;

  dbms_lob.createtemporary(feature_info, TRUE);
  dbms_lob.writeappend(feature_info, length(tmp_buf), tmp_buf);
  
END dbms_feature_segadv_user;
/

show errors;

/******************************************************************
 * DBMS_FEATURE_AUM
 *  The procedure to detect usage for Automatic Undo Management
 ******************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_aum
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  ts_info         varchar2(1000);  
  undo_blocks     number;
  max_concurrency number;  
BEGIN

  select count(*) into feature_boolean from v$system_parameter where
    name = 'undo_management' and upper(value) = 'AUTO';

  if (feature_boolean = 0) then
    /* not automatic undo management */
    aux_count    := 0;
    feature_info := null;
  else

    aux_count := 0;

    /* undo tablespace information */
    for ts_type in 
      (select retention, count(*) tcount, sum(size_mb) size_mb
        from
         (select ts.tablespace_name, retention, sum(bytes)/1048576 size_mb
           from dba_data_files df, dba_tablespaces ts
          where df.tablespace_name = ts.tablespace_name
            and ts.contents = 'UNDO'
          group by ts.tablespace_name, retention)
        group by retention)
    loop

      /* track total number of tablespaces */
      aux_count := aux_count + ts_type.tcount;

      ts_info := ts_info || 
          '(Retention: ' || ts_type.retention ||
         ', TS Count: ' || ts_type.tcount ||
         ', Size MB: '  || ts_type.size_mb || ') ';

    end loop; 

    /* get some more information */
    select sum(undoblks), max(maxconcurrency) 
      into undo_blocks, max_concurrency
      from v$undostat
      where begin_time >=
             (SELECT nvl(max(last_sample_date), sysdate-7) 
                FROM dba_feature_usage_statistics);

    ts_info := ts_info || '(Undo Blocks: ' || undo_blocks ||
                         ', Max Concurrency: ' || max_concurrency || ') ';

    for ssold in
      (select to_char(min(begin_time), 'YYYY-MM-DD HH24:MI:SS') btime,
              to_char(max(end_time),   'YYYY-MM-DD HH24:MI:SS') etime,
              sum(SSOLDERRCNT) errcnt
        from v$undostat 
        where (begin_time >=
               (SELECT nvl(max(last_sample_date), sysdate-7) 
                  FROM dba_feature_usage_statistics)))
    loop
      ts_info := ts_info || 
          '(Snapshot Old Info - Begin Time: ' || ssold.btime || 
                        ', End Time: '   || ssold.etime || 
                        ', SSOLD Error Count: ' || ssold.errcnt || ') ';
    end loop;

    feature_boolean := 1;
    feature_info    := to_clob(ts_info);

  end if;

END dbms_feature_aum;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_JOB_SCHEDULER
 *  The procedure to detect usage for DBMS_SCHEDULER
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_job_scheduler
      (is_used OUT number, nr_of_jobs OUT number, summary OUT clob)
AS
sum1 varchar2(4000);
n1 number;
n2 number;
n3 number;
n4 number;
n5 number;
n6 number;
n7 number;
n8 number;
n9 number;

BEGIN
  select count(*) into nr_of_jobs from dba_scheduler_jobs where 
      owner not in ('SYS', 'ORACLE_OCM', 'EXFSYS' ) 
       and job_name not like 'AQ$%'
       and job_name not like 'MV_RF$J_%';

  is_used := nr_of_jobs;
  -- if job used 
  if is_used = 0  then return; end if;

select count(*) into n1 from dba_scheduler_jobs;
    sum1  := sum1 
              || 'JNRA:' || n1
              || ',JNRU:' || nr_of_jobs; 

select count(*) into n1 from dba_jobs;
    sum1  := sum1 
              || ',DJOBS:' || n1; 
-- Direct per job type counts, i.e of the total number of jobs how many are
--  program vs executable vs plsql block vs stored procedure vs chain


  for it in  (
select jt t, count(*) n
from (select   nvl(job_type, 'PROGRAM') jt
from   dba_scheduler_jobs )
group by jt order by 1) 
  loop  
    sum1  := sum1 || ',JTD' || substr(it.t,1,3) || ':' || it.n;
  end loop;

 
-- Indirect per job type counts. 
-- In this case the you have to track down the program type of all 
-- the jobs whose jobs are of type program. 
-- So now of the the total number of jobs, how many are
--  executable vs plsql block vs stored procedure vs chain

  for it in  (
select jt t, count(*) n from 
   (select program_type jt
      from dba_scheduler_jobs j, 
         dba_scheduler_programs p 
    where 
            job_type is null 
            and p.owner = j.program_owner 
            and p.program_name = j.program_name 
    union all 
     select 'NAP' 
      from dba_scheduler_jobs j
       where
            j.job_type is null
            and not exists (select 1 from 
             dba_scheduler_programs p
              where
               p.owner = j.program_owner    
              and p.program_name = j.program_name) 
    union all 
    select   job_type
    from   dba_scheduler_jobs where job_type is not null)
     group by jt order by 1)
  loop  
    sum1  := sum1 || ',JTI' || substr(it.t,1,3) || ':' || it.n;
  end loop;
-- Direct per schedule type counts, i.e. of the total 
-- number of jobs how many are
-- repeat_interval is null, schedule based, event based, file watcher based, 
-- plsql repeat interval, calendar repeat interval, window based



  for it in  (
select schedule_type t, 
         count(*) n 
from   dba_scheduler_jobs 
group by schedule_type order by 1)
  loop  
    sum1  := sum1 || ',JDS' || substr(replace(it.t, 'WINDOW_','W'),1,3) || ':' || it.n;
  end loop;

-- Indirect per schedule type counts. In this case the schedule based jobs are 
-- tracked down to their eventual schedule type. So now of the total number of jobs, how many are
--  repeat_interval is null, event based, file watcher, plsql repeat interval, 
-- calendar repeat interval, window (group) based

  for it in  (
select schedule_type t, count(*) n from 
   (select p.schedule_type
      from dba_scheduler_jobs j, 
         dba_scheduler_schedules p 
    where 
            j.schedule_type = 'NAMED' 
            and p.owner = j.schedule_owner 
            and p.schedule_name = j.schedule_name 
    union all 
    select   schedule_type
    from   dba_scheduler_jobs where schedule_type <> 'NAMED')
     group by schedule_type order by 1)
  loop  
    sum1  := sum1 || ',JIS' || substr(replace(it.t, 'WINDOW_','W'),1,3) || ':' || it.n;
  end loop;
   

-- Number of jobs that have destination set to a 
-- single destination vs destination set to a destination group

 for it in (
select dest t, count(*) n 
   from (select decode(number_of_destinations,1, 'SD', 'MD') dest 
       from dba_scheduler_jobs where destination is not null)
   group by dest order by 1) 
  loop  
    sum1  := sum1 || ',JD' || it.t || ':' || it.n;
  end loop;

-- Number of external jobs (job type or program type executable) split across local without a credential, 
-- local with credential, remote single destination, remote destination group
 for it in (
select ext_type t, count(*) n from
(select job_name, decode(destination, null,
     decode(credential_name, null,'JXL','JXLC'),
     decode(dest_type,null,'JXRID','SINGLE','JXRSD','JXRGD')) ext_type from
(select job_name, job_type, credential_name, destination_owner, destination
from all_scheduler_jobs where program_name is null
union all
select job_name, program_type, credential_name, destination_owner, destination
from all_scheduler_jobs aj, all_scheduler_programs ap
where aj.program_owner = ap.owner and aj.program_name = ap.program_name) aij,
(select owner, group_name dest_name, 'GROUP' dest_type from all_scheduler_groups
where group_type = 'EXTERNAL_DEST'
union all
select 'SYS', destination_name, 'SINGLE' from all_scheduler_external_dests) ad
where job_type = 'EXECUTABLE' and aij.destination_owner = ad.owner(+) and
aij.destination = ad.dest_name(+)) group by ext_type order by 1)
  loop  
    sum1  := sum1 || ',' || it.t || ':' || it.n;
  end loop;


-- Number of remote database jobs with single destination versus number of jobs with destination group (i.e. destination is set and job type or program type is plsql block or stored procedure).

 for it in (
select dest_type t, count(*) n from
    (select  job_type, destination_owner, destination
        from all_scheduler_jobs where program_name is null
    union all
    select  program_type, destination_owner, destination
        from all_scheduler_jobs aj, all_scheduler_programs ap
            where aj.program_owner = ap.owner and aj.program_name = ap.program_name) aij,
    (select owner, group_name dest_name, 'JDBG' dest_type from all_scheduler_groups
            where group_type = 'DB_DEST'
     union all
     select owner, destination_name, 'JDBS' from all_scheduler_db_dests) ad
 where (job_type = 'STORED_PROCEDURE' OR job_type = 'PLSQL_BLOCK') and
       aij.destination is not null and aij.destination_owner = ad.owner(+) and
       aij.destination = ad.dest_name(+) group by dest_type order by 1)
  loop  
    sum1  := sum1 || ',' || it.t || ':' || it.n;
  end loop;

-- Number of jobs with arguments. For those jobs with arguments, avg,
-- median and max number of job arguments.

select count(*),  
       avg(number_of_arguments), 
       median(number_of_arguments), 
       max(number_of_arguments) into  n1, n2, n3, n4
from dba_scheduler_jobs where number_of_arguments > 0;

    sum1  := sum1 
              || ',JAC:' || n1 
              || ',JAA:' || round(n2) 
              || ',JAM:' || n3 
              || ',JAX:' || n4; 

-- Split total number of jobs across job_style, i.e. regular vs lightweight

 for it in (
select job_style t, count(*) n from dba_scheduler_jobs
     group by job_style order by 1)
  loop  
    sum1  := sum1 || ',JST' || substr(it.t,1,3) || ':' || it.n;
  end loop;
   

-- Number of jobs that have restartable set to true
-- How many have max_run_duration set
-- How many have schedule_limit set
-- How many have instance_id set
-- How many have allow_runs_in_restricted_mode set
-- How many have raise_events set
-- How many have parallel_instances set
select sum(decode(restartable,null, 0,1)),
       sum(decode(max_run_duration,null, 0,1)) ,
       sum(decode(schedule_limit,null, 0,1)) ,
       sum(decode(instance_id,null, 0,1)) ,
       sum(decode(allow_runs_in_restricted_mode,'FALSE', 0,1)) ,
       sum(decode(bitand(flags, 2147483648),2147483648,1,0)),
       sum(decode(bitand(flags, 68719476736),68719476736,1,0)),
       sum(decode(enabled,'FALSE',1,0)),
       sum(decode(raise_events,null, 0,1)) 
             into n1, n2, n3, n4, n5,n6, n7, n8, n9
from dba_scheduler_jobs;
    sum1  := sum1 
              || ',JRS:' || n1 
              || ',JMRD:' || n2 
              || ',JSL:' || n3 
              || ',JII:' || n4 
              || ',JAR:' || n5 
              || ',JFLW:' || n7 
              || ',JRE:' || n9 
              || ',JDIS:' || n8 
              || ',JPI:' || n6; 

-- Total number of programs
-- Per type program numbers, i.e. the number of executable, plsql_block, 
-- stored procedure, chain programs

 for it in (
select program_type t, count(*) n from dba_scheduler_programs 
    group by program_type order by 1)
  loop  
    sum1  := sum1 || ',PRT' || substr(it.t,1,3) || ':' || it.n;
  end loop;


-- Number of programs with arguments
-- For programs with arguments, avg, mean and max number of arguments
select count(*) ,  round(avg(number_of_arguments)) , 
       median(number_of_arguments) , 
      max(number_of_arguments)  
         into n1, n2, n3, n4
from dba_scheduler_programs where number_of_arguments > 0;
    sum1  := sum1 
              || ',PAC:' || n1 
              || ',PAA:' || n2 
              || ',PAM:' || n3 
              || ',PAX:' || n4; 

-- Total number of schedules
-- Split across schedule type. How many in each category:
-- run once, plsql repeat interval, calendar repeat interval, event based, 
-- file watcher, window based


 for it in (
select schedule_type t, count(*) n from dba_scheduler_schedules group by
     schedule_type order by 1)
  loop  
    sum1  := sum1 || ',SST' || substr(it.t,1,3) || ':' || it.n;
  end loop;


-- Total number of arguments
-- How many of them are named arguments

 for it in (
select an t, count(*) n 
    from (select  decode(argument_name, null, 'PA_', 'PAN') an from
    dba_scheduler_program_args) group by an order by 1)
  loop  
    sum1  := sum1 || ',' || it.t || ':' || it.n;
  end loop;

-- Split across count of metadata arguments, varchar based args, anydata based arguments
 for it in (
select metadata_attribute t, count(*) n from dba_scheduler_program_args where 
         metadata_attribute is not null group by metadata_attribute order by 1)
  loop  
    sum1  := sum1 || ',PM' || 
                  substr(replace(replace(it.t,'JOB_','J'),'WINDOW_','W'),1,3) 
                    || ':' || it.n;
  end loop;

-- Job Classes
-- Total number of job classes
-- How many have service set
-- How many have resource consumer group set
-- split across logging levels, i.e. how many no logging, failed runs, runs only, full

select count(*) , sum(decode(service, null, 0, 1)) ,
sum(decode(resource_consumer_group, null, 0, 1)) into n1,n2,n3 
from dba_scheduler_job_classes;
    sum1  := sum1 
              || ',JCNT:' || n1 
              || ',JCSV:' || n2 
              || ',JCCG:' || n3 ;

 for it in (
select logging_level t, count(*) n from dba_scheduler_job_classes 
    group by logging_level order by 1)
  loop  
    sum1  := sum1 || ',LL' || substr(it.t,1,3)  || ':' || it.n;
  end loop;

-- Windows
-- Total number of windows
-- Number of high priority windows (low = total - high)
-- Number of windows without a resource plan
-- Number of named schedule based windows (inlined schedule = total - named schedule)
 for it in (
select window_priority t, count(*) n from dba_scheduler_windows 
    group by window_priority order by 1) 
  loop  
    sum1  := sum1 || ',WIP' || substr(it.t,1,2) || ':' || it.n;
  end loop;

select count(*) into n1 from dba_scheduler_windows  where resource_plan is
 null;
    sum1  := sum1 
              || ',WINR:' || n1;

 for it in (
select st t, count(*) n from  
   (select schedule_type  st
     from
     dba_scheduler_windows)  group by st order by 1) 
  loop  
    sum1  := sum1 || ',SWT' || substr(it.t,1,2) || ':' || it.n;
  end loop;


-- Chains
-- Total number of chains
-- How many have evaluation interval set
-- How many were created with a rule set passed in
-- Total number of steps
-- How many steps have destination set
-- Avg, mean and max number of steps per chain
-- Total number of rules
-- Avg, mean and max number of rules per chain
-- ? How many of them use simple syntax
-- ? Avg, mean and max number of steps per rule condition
-- ? Avg, mean and max number of steps per rule action

select count(*), sum(decode(evaluation_interval, null, 0, 1)) EV,
       sum(decode(user_rule_set, 'TRUE', 1, 0)) UR, 
       sum(nvl(number_of_rules,0)) NR, sum(nvl(number_of_steps,0)) NS, 
       round(avg(number_of_steps)) VS , median(number_of_steps) MS, 
       max(number_of_steps) XS into n1, n2,n3,n4,n5,n6,n7,n8 
    from dba_scheduler_chains;
    sum1  := sum1 
              || ',CCNT:' || n1 
              || ',CEVI:' || n2 
              || ',CURS:' || n3 
              || ',CNRR:' || n4 
              || ',CNRS:' || n5 
              || ',CAVS:' || n6 
              || ',CMDS:' || n7 
              || ',CMXS:' || n8;
   

select count(*) into n1 
    from dba_scheduler_chain_steps where destination is not null; 
    sum1  := sum1 
              || ',CSRD:' || n1 ;

-- Direct per step type counts. Of total how many steps point to:
--    program vs (sub)chain vs event
 for it in (
select step_type t, count(*)  n from dba_scheduler_chain_steps 
   group by step_type order by 1)
  loop  
    sum1  := sum1 || ',CSP' || substr(it.t,1,3) || ':' || it.n;
  end loop;

-- Indirect per step type counts. By following the program type how many are:
--    executable vs plsql block vs stored procedure vs (sub)chain vs event

 for it in (
select step_type t, count(*) n from 
      (select step_type from dba_scheduler_chain_steps  
            where step_type <> 'PROGRAM' 
      union all 
       select program_type from dba_scheduler_programs p,
                                dba_scheduler_chain_steps s 
          where 
           s.step_type = 'PROGRAM' and
          s.program_owner =p.owner and 
          s.program_name = p.program_name)
   group by step_type order by 1)
  loop  
    sum1  := sum1 || ',CHST' || substr(it.t,1,3) || ':' || it.n;
  end loop;
     
-- Total number of credentials
-- How many have database role set
-- How many have windows domain set

select count(*), sum(decode(database_role, null, 0, 1)),
       sum(decode(windows_domain, null, 0, 1)) 
     into n1,n2,n3
    from dba_scheduler_credentials;
    sum1  := sum1 
              || ',CRNR:' || n1  
              || ',CRDB:' || n2  
              || ',CSWD:' || n3 ;

-- Total number of destinations
-- How many database destinations (external dests = total - database dests)
-- Of the database destinations, how many specified connect info (non null tns_name)

 for it in (
select dt t, count(*) n from 
   (select decode(destination_type, 'EXTERNAL', 'DSXT', 'DSDB') dt
     from dba_scheduler_dests )
    group by dt order by 1)
  loop  
    sum1  := sum1 || ',' || it.t || ':' || it.n;
  end loop;

select count(*) into n1 from dba_scheduler_db_dests 
         where connect_info is null;
    sum1  := sum1 
              || ',DSDN:' || n1  ;
-- File Watcher
-- Total number of file watchers
-- How many remote file watchers (destination is non null)
-- How many have minimum file size > 0
-- How many have steady_state_duration set to a non-null value
select count(*), 
       sum(decode(steady_state_duration, null, 0,1)),
       sum(decode(destination, null, 0,1)),
       sum(decode(nvl(min_file_size,0), 0, 0, 1))
      into n1,n2,n3,n4
 from dba_scheduler_file_watchers;
    sum1  := sum1 
              || ',FWNR:' || n1  
              || ',FWSS:' || n2  
              || ',FWDS:' || n3  
              || ',FWMF' || n4  ;


-- Groups
-- Total number of groups
-- Per group type count, i.e. how many are db_dest vs external_dest vs window
-- Avg, mean and max number of members per group

 for it in (
select group_type t, count(*) n , round(avg(number_of_members)) a ,
              max(number_of_members) b,
              median(number_of_members) c
        from dba_scheduler_groups group by group_type order by 1)
  loop  
    sum1  := sum1 || ',G' || substr(it.t,1,3) || 'N:' || it.n
                        || ',G' || substr(it.t,1,3) || 'A:' || it.a
                        || ',G' || substr(it.t,1,3) || 'X:' || it.b
                        || ',G' ||substr( it.t,1,3) || 'M:' || it.c;
  end loop;


-- Calendar Syntax
-- Total number of schedules
-- Total number of non-null repeat_intervals schedules
-- Of the calendar syntax ones how many:
-- use include, exclude, or intersect
-- have a user defined frequency
-- use offset

select count(*) into n1 from dba_scheduler_schedules; 
    sum1  := sum1 
              || ',SCHNRA:' || n1;  

select count(*) into n1 from dba_scheduler_schedules
       where repeat_interval is not null;
    sum1  := sum1 
              || ',SCHNNR:' || n1;  
                             
 for it in (
select typ t, count(*) n from 
      (select decode(instr(i,'FREQ=YEARLY'),1, 'Y', 
        decode(instr(i, 'FREQ=MONTHLY'),1,'M', 
         decode(instr(i,'FREQ=WEEKLY'),1, 'W', 
          decode(instr(i,'FREQ=DAILY'),1, 'D', 
           decode(instr(i,'FREQ=HOURLY'),1, 'H', 
           decode(instr(i,'FREQ=MINUTELY'),1, 'MI', 
           decode(instr(i,'FREQ=SECONDLY'),1, 'S',
           decode(instr(i,'FREQ='),1, 'U','X')))))))) typ
      from (select replace(upper(iv), ' ', '') i from (
         select repeat_interval iv 
        from dba_scheduler_jobs 
          where schedule_type = 'CALENDAR' 
       union all select repeat_interval from dba_scheduler_schedules where
         schedule_type = 'CALENDAR')))
 group by typ order by 1)
  loop  
    sum1  := sum1 || ',CAF' || it.t || ':' || it.n;
  end loop;


select sum(decode(instr(i, 'OFFSET'), 0, 0, 1)) "Offset",  
       sum(decode(instr(i, 'SPAN'), 0, 0, 1)) "Span",  
       sum(decode(instr(i, 'BYSETPOS'), 0, 0, 1)) "Bysetp",  
       sum(decode(instr(i, 'INCLUDE'), 0, 0, 1)) "Inc",  
       sum(decode(instr(i, 'EXCLUDE'), 0, 0, 1)) "EXC",  
      sum(decode(instr(i, 'INTERSECT'), 0, 0, 1)) "ISEC"
      into n1,n2,n3,n4,n5,n6
from (select replace(upper(iv), ' ', '') i from (
   select repeat_interval iv 
  from dba_scheduler_jobs 
    where schedule_type = 'CALENDAR' 
 union all select repeat_interval from dba_scheduler_schedules where
   schedule_type = 'CALENDAR'));
    sum1  := sum1 
              || ',CAOF:' || n1  
              || ',CASC:' || n2  
              || ',CABS:' || n3  
              || ',CAIC:' || n4  
              || ',CAEX:' || n5  
              || ',CAIS:' || n6;  
 

select count (distinct owner||job_name) into n1
     from dba_scheduler_notifications;
    sum1  := sum1 
              || ',SNNR:' || n1;  

 for it in (
select event t, count(*) n
     from dba_scheduler_notifications
     group by event order by 1)
  loop  
    sum1  := sum1 || ',JN' 
               || substr(replace(it.t, 'JOB_','J'),1,5) || ':' || it.n;
  end loop;
  summary := to_clob(sum1);
END;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_EXADATA
 *  The procedure to detect usage for EXADATA storage
 ***************************************************************/
create or replace procedure DBMS_FEATURE_EXADATA
    (feature_boolean  OUT  NUMBER,
     num_cells        OUT  NUMBER,
     feature_info     OUT  CLOB)
AS
  feature_usage          varchar2(1000);
begin
  -- initialize
  num_cells := 0;
  feature_boolean := 0;
  feature_info := to_clob('EXADATA usage not detected');
  feature_usage := '';

  execute immediate 'select count(*) from (select distinct cell_name from gv$cell_state)'
  into num_cells;

  if num_cells > 0
  then

    feature_boolean := 1;

    feature_usage := feature_usage||':cells:'||num_cells;

    feature_info := to_clob(feature_usage);

  end if;

end;
/
show errors;


/***************************************************************
 * DBMS_FEATURE_UTILITIES1
 *  The procedure to detect usage for Oracle database Utilities
 *  for datapump export.
 *  Also reports on compression/encryption usage if
 *  applicable. 
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities1
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage      VARCHAR2(1000);
   feature_count      NUMBER;
   compression_count  NUMBER;
   encryption_count   NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_usage     := NULL;
  feature_count     := 0;
  compression_count := 0;
  encryption_count  := 0;

  select usecnt, encryptcnt, compresscnt
    into feature_count, encryption_count, compression_count
    from sys.ku_utluse
   where utlname = 'Oracle Utility Datapump (Export)'
     and   (last_used >=
            (SELECT nvl(max(last_sample_date), sysdate-7)
               FROM dba_feature_usage_statistics));

  feature_usage := feature_usage || 'Oracle Utility Datapump (Export) ' || 
                   'invoked: ' || feature_count || 
                   ' times, compression used: ' || compression_count   ||
                   ' times, encryption used: ' || encryption_count || ' times';

  feature_info := to_clob(feature_usage);

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities1;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_UTILITIES2
 *  The procedure to detect usage for Oracle database Utilities
 *  for datapump import
 *  Also reports on compression/encryption usage if
 *  applicable. 
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities2
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage      VARCHAR2(1000);
   feature_count      NUMBER;
   compression_count  NUMBER;
   encryption_count   NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_usage     := NULL;
  feature_count     := 0;
  compression_count := 0;
  encryption_count  := 0;

  select usecnt, encryptcnt, compresscnt
    into feature_count, encryption_count, compression_count
    from sys.ku_utluse
   where utlname = 'Oracle Utility Datapump (Import)'
     and   (last_used >=
            (SELECT nvl(max(last_sample_date), sysdate-7)
               FROM dba_feature_usage_statistics));

  feature_usage := feature_usage || 'Oracle Utility Datapump (Import) ' || 
                   'invoked: ' || feature_count || 
                   ' times, compression used: ' || compression_count   ||
                   ' times, encryption used: ' || encryption_count || ' times';

  feature_info := to_clob(feature_usage);

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities2;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_UTILITIES3
 *  The procedure to detect usage for Oracle database Utilities
 *  for MetaData API.
 *  Also reports on compression/encryption usage if
 *  applicable. 
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities3
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage      VARCHAR2(1000);
   feature_count      NUMBER;
   compression_count  NUMBER;
   encryption_count   NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_usage     := NULL;
  feature_count     := 0;
  compression_count := 0;
  encryption_count  := 0;

  select usecnt, encryptcnt, compresscnt
    into feature_count, encryption_count, compression_count
    from sys.ku_utluse
   where utlname = 'Oracle Utility Metadata API'
     and   (last_used >=
            (SELECT nvl(max(last_sample_date), sysdate-7)
               FROM dba_feature_usage_statistics));

  feature_usage := feature_usage || 'Oracle Utility Metadata API ' || 
                   'invoked: ' || feature_count || 
                   ' times, compression used: ' || compression_count   ||
                   ' times, encryption used: ' || encryption_count || ' times';

  feature_info := to_clob(feature_usage);

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities3;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_UTILITIES4
 *  The procedure to detect usage for Oracle database Utilities
 *  for external tables. 
 *  Also reports on compression/encryption usage if
 *  applicable. 
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_utilities4
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage      VARCHAR2(1000);
   feature_count      NUMBER;
   compression_count  NUMBER;
   encryption_count   NUMBER;
BEGIN
  -- initialize
  feature_info      := NULL;
  feature_usage     := NULL;
  feature_count     := 0;
  compression_count := 0;
  encryption_count  := 0;

  select usecnt, encryptcnt, compresscnt
    into feature_count, encryption_count, compression_count
    from sys.ku_utluse
   where utlname = 'Oracle Utility External Table'
     and   (last_used >=
            (SELECT nvl(max(last_sample_date), sysdate-7)
               FROM dba_feature_usage_statistics));

  feature_usage := feature_usage || 'Oracle Utility External Table ' || 
                   'invoked: ' || feature_count || 
                   ' times, compression used: ' || compression_count   ||
                   ' times, encryption used: ' || encryption_count || ' times';

  feature_info := to_clob(feature_usage);

  feature_boolean := feature_count;
  aux_count       := feature_count;
END dbms_feature_utilities4;
/

show errors;


/********************************************************* 
* DBMS_FEATURE_AWR
* counts snapshots since last sample
* also counts DB time and DB cpu over last 7 days
*********************************************************/ 
create or replace procedure DBMS_FEATURE_AWR
     ( feature_boolean_OUT  OUT  NUMBER,
       aux_count_OUT        OUT  NUMBER,
       feature_info_OUT     OUT  CLOB)
AS
  DBFUS_LAST_SAMPLE_DATE  DATE;

  l_DBtime7day_secs   number;
  l_DBcpu7day_secs    number;

  -- cursor fetches last 7 days of AWR snapshot DB time and DB cpu
  cursor TimeModel7day_cur
  IS
WITH snap_ranges AS
(select /*+ FULL(ST) */
        SN.dbid
       ,SN.instance_number
       ,SN.startup_time
       ,ST.stat_id
       ,ST.stat_name
       ,MIN(SN.snap_id) as MIN_snap
       ,MAX(SN.snap_id) as MAX_snap
       ,MIN(CAST(begin_interval_time AS DATE)) as MIN_date
       ,MAX(CAST(end_interval_time AS DATE)) as MAX_date
   from
        dba_hist_snapshot   SN
       ,wrh$_stat_name      ST
  where 
        SN.begin_interval_time > TRUNC(SYSDATE) - 7
    and SN.end_interval_time   < TRUNC(SYSDATE)
    and SN.dbid = ST.dbid
    and ST.stat_name IN ('DB time', 'DB CPU')
  group by
        SN.dbid,SN.instance_number,SN.startup_time,ST.stat_id,ST.stat_name
)
,delta_data AS
(select
        SR.dbid
       ,SR.instance_number
       ,SR.stat_name
       ,CASE WHEN SR.startup_time BETWEEN SR.MIN_date AND SR.MAX_date
               THEN TM1.value + (TM2.value - TM1.value)
             ELSE (TM2.value - TM1.value)
        END
        as delta_time
   from
        WRH$_SYS_TIME_MODEL   TM1
       ,WRH$_SYS_TIME_MODEL   TM2
       ,snap_ranges           SR
  where
        TM1.dbid = SR.dbid
    and TM1.instance_number = SR.instance_number
    and TM1.snap_id         = SR.MIN_snap
    and TM1.stat_id         = SR.stat_id
    and TM2.dbid = SR.dbid
    and TM2.instance_number = SR.instance_number
    and TM2.snap_id         = SR.MAX_snap
    and TM2.stat_id         = SR.stat_id
)
select
       stat_name
      ,ROUND(SUM(delta_time/1000000),2) as secs
  from
       delta_data
 group by
       stat_name;

begin
  --> initialize OUT parameters
  feature_boolean_OUT := 0;
  aux_count_OUT       := null;
  feature_info_OUT    := null;

  --> initialize last sample date
  select nvl(max(last_sample_date), sysdate-7)  
    into DBFUS_LAST_SAMPLE_DATE
   from wri$_dbu_usage_sample;

  if DBFUS_LAST_SAMPLE_DATE IS NOT NULL
  then
    --> get snapshot count since last sample date
    select count(*) 
      into feature_boolean_OUT
      from wrm$_snapshot 
     where dbid = (select dbid from v$database) 
       and status = 0 
       and bitand(snap_flag, 1) = 1 
       and end_interval_time > DBFUS_LAST_SAMPLE_DATE;
  end if;

  --> fetch 7 day DB time and DB CPU from AWR
  for TimeModel7day_rec in TimeModel7day_cur
  loop
    case TimeModel7day_rec.stat_name
      when 'DB time' then l_DBtime7day_secs := TimeModel7day_rec.secs;
      when 'DB CPU'  then l_DBcpu7day_secs := TimeModel7day_rec.secs;
    end case;
  end loop;

  --> assemble feature info CLOB
  feature_info_OUT := 'DBtime:'||TO_CHAR(l_DBtime7day_secs)||
                      ',DBcpu:'||TO_CHAR(l_DBcpu7day_secs);


end;
/
show errors


/***************************************************************
 * DBMS_FEATURE_DATABASE_VAULT
 *  The procedure to detect usage for Oracle Database Vault
 ***************************************************************/
CREATE OR REPLACE PROCEDURE dbms_feature_database_vault
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   dv_linkon          NUMBER;
   dvsys_uid          NUMBER;
   dvowner_uid        NUMBER;
   dvacctmgr_uid      NUMBER;
BEGIN
  -- initialize
  feature_boolean   := 0;
  aux_count         := 0;
  feature_info      := NULL;

  -- check to see if DV is linked on
  select count(*) into dv_linkon from v$option where 
     parameter = 'Oracle Database Vault' and
     value = 'TRUE';

  if (dv_linkon = 0) then
    return;
  end if;

  -- get DVSYS hard coded uid
  select count(*) into dvsys_uid from user$ where
    name = 'DVSYS' and
    user# = 1279990;

  -- get uids for hard coded roles
  select count(*) into dvowner_uid from user$ where 
     name = 'DV_OWNER' and
     user# = 1279992;
  select count(*) into dvacctmgr_uid from user$ where
     name = 'DV_ACCTMGR' and
     user# = 1279991;

  if (dvsys_uid = 0 or
      dvowner_uid = 0 or
      dvacctmgr_uid = 0) then
     return;
  end if;
  
  feature_boolean := 1;

END dbms_feature_database_vault;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_DEFERRED_SEG_CRT
 *  The procedure to detect usage for the deferred segment
 *  creation feature.
 ***************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_DEFERRED_SEG_CRT
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
   feature_usage        VARCHAR2(1000);
   table_count          NUMBER;
   index_count          NUMBER;
   lob_count            NUMBER;
   tabpart_count        NUMBER;
   indpart_count        NUMBER;
   lobpart_count        NUMBER;
   tabsubpart_count     NUMBER;
   indsubpart_count     NUMBER;
   lobsubpart_count     NUMBER;
   total_segments       NUMBER;
   total_def_segments   NUMBER;
BEGIN
  -- initialize
  feature_boolean    := 0;
  aux_count          := 0;
  feature_info       := NULL;
  feature_usage      := NULL;
  table_count        := 0;
  index_count        := 0;
  lob_count          := 0;
  tabpart_count      := 0;
  indpart_count      := 0;
  lobpart_count      := 0;
  tabsubpart_count   := 0;
  indsubpart_count   := 0;
  lobsubpart_count   := 0;
  total_segments     := 0;
  total_def_segments := 0;

  -- check to see if DSC parameter is turned on
  select count(*) into feature_boolean from v$system_parameter where 
     name = 'deferred_segment_creation' and value = 'TRUE';

  -- Regardless of the value of the parameter, compute the number of 
  -- objects that do not yet have segments created

  -- non-partitioned tables
--  select count(*) into table_count from dba_tables where 
--      segment_created = 'NO';

  select count(*) into table_count from 
  (  select decode(bitand(t.property, 17179869184), 17179869184, 'NO', 
                   decode(bitand(t.property, 32), 32, 'N/A', 'YES')) x 
     from tab$ t
  ) 
  where x = 'NO';

  -- non-partitioned indexes
--  select count(*) into index_count from dba_indexes where 
--      segment_created = 'NO';

  select count(*) into index_count from 
  (  select  decode(bitand(i.flags, 67108864), 67108864, 'NO','?')  x
     from ind$ i
   )
   where x = 'NO';

  -- non-partitioned lobs
--  select count(*) into lob_count from dba_lobs where 
--      segment_created = 'NO';

  select count(*) into lob_count from 
  ( select decode(bitand(l.property, 4096), 4096, 'NO','?') x
    from lob$ l
   )
   where x = 'NO';

  -- table partitions
--  select count(*) into tabpart_count from dba_tab_partitions where 
--      segment_created = 'NO';

  select count(*) into tabpart_count from
  ( select  decode(bitand(tp.flags, 65536), 65536, 'NO', 'YES') x 
    from tabpart$ tp
  ) where x = 'NO';

  -- index partitions
--  select count(*) into indpart_count from dba_ind_partitions where 
--      segment_created = 'NO';

  select count(*) into indpart_count from
  ( select  decode(bitand(ip.flags, 65536), 65536, 'NO', 'YES') x 
    from indpart$ ip
  ) where x = 'NO';

  -- lob partitions
--  select count(*) into lobpart_count from dba_lob_partitions where 
--      segment_created = 'NO';

    select count(*) into lobpart_count from
  ( select decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES') x
    from lobfrag$ lf where lf.fragtype$='P'
  ) where x = 'NO';

  -- table sub-partitions
--  select count(*) into tabsubpart_count from dba_tab_subpartitions where 
--      segment_created = 'NO';

  select count(*) into tabsubpart_count from
  ( select  decode(bitand(tsp.flags, 65536), 65536, 'NO', 'YES') x 
    from tabsubpart$ tsp
  ) where x = 'NO';

  -- index sub-partitions
--  select count(*) into indsubpart_count from dba_ind_subpartitions where 
--      segment_created = 'NO';

  select count(*) into indsubpart_count from
  ( select  decode(bitand(isp.flags, 65536), 65536, 'NO', 'YES') x 
    from indsubpart$ isp
  ) where x = 'NO';

  -- lob sub-partitions
--  select count(*) into lobsubpart_count from dba_lob_subpartitions where 
--      segment_created = 'NO';

  select count(*) into lobsubpart_count from
  ( select decode(bitand(lf.fragflags, 33554432), 33554432, 'NO', 'YES') x
    from lobfrag$ lf where lf.fragtype$='S'
  ) where x = 'NO';

  -- Total segments of objects which can have deferred segment creation
--  select count(*) into total_segments from dba_segments where
--      segment_type IN ('TABLE', 
--                       'INDEX', 
--                       'LOBSEGMENT', 
--                       'LOBINDEX', 
--                       'TABLE PARTITION', 
--                       'INDEX PARTITION', 
--                       'LOB PARTITION' );

 select count(*) into total_segments from seg$ where type# in (5,6,8);
 
  -- Total # of segments whose creation is deferred
  total_def_segments := table_count + index_count + lob_count +
                        tabpart_count + indpart_count + lobpart_count +
                        tabsubpart_count + indsubpart_count + lobsubpart_count;

  feature_usage := feature_usage || 'Deferred Segment Creation ' || 
                   ' Parameter:' || feature_boolean ||
                   ' Total Deferred Segments:' || total_def_segments || 
                   ' Total Created Segments:' || total_segments   ||
                   ' Table Segments:' || table_count   ||
                   ' Index Segments:' || index_count   ||
                   ' Lob Segments:'   || lob_count   ||
                   ' Table Partition Segments:' || tabpart_count   ||
                   ' Index Partition Segments:' || indpart_count   ||
                   ' Lob Partition Segments:'   || lobpart_count   ||
                   ' Table SubPartition Segments:' || tabsubpart_count   ||
                   ' Index SubPartition Segments:' || indsubpart_count   ||
                   ' Lob SubPartition Segments:'   || lobsubpart_count;

  -- update feature_boolean if even one segment is uncreated
  if (total_def_segments > 0) then
    feature_boolean := feature_boolean+1;
  end if;

  feature_info    := to_clob(feature_usage);
  aux_count       := total_def_segments;

END dbms_feature_deferred_seg_crt;
/

show errors;

/***************************************************************
 * DBMS_FEATURE_DMU
 *  The procedure to detect usage for DMU
 ***************************************************************/
CREATE OR REPLACE PROCEDURE DBMS_FEATURE_DMU
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
  v_usage_value   varchar2(4000);
  v_last_used     date;
  v_last_sampled  date;
BEGIN
  --
  -- start with 'DMU usage not detected'
  -- we do not utilize aux_count.
  --
  feature_boolean := 0;
  feature_info := to_clob('DMU usage not detected');
  aux_count := 0;
  --
  -- test if DMU was used since last sampled date
  --
  begin
    --
    -- get the date DMU was used last time
    --
    select value$ into v_usage_value
      from sys.props$
     where name = 'NLS_DMU_USAGE';
    v_last_used := to_date(substr(v_usage_value,1,instr(v_usage_value,',')-1),
                           'YYYYMMDDHH24MISS');
    --
    -- get the date sampled last time
    --
    select nvl(max(last_sample_date), sysdate-7)
      into v_last_sampled
      from wri$_dbu_usage_sample;
    --
    -- DMU usage is detected
    --
    if v_last_sampled < v_last_used then
      feature_boolean := 1;
      feature_info := to_clob(v_usage_value);
    end if;
  exception
    --
    -- DMU usage is not detected if any exception is thrown including:
    --  * NLS_DMU_USAGE not found in sys.props$
    --  * the value is not in the format of 'YYYYMMDDHH24MISS'
    --
    when others then
      null;
  end;
END DBMS_FEATURE_DMU;
/
show errors;

  -- ******************************************************** 
  --   TEST_PROC_1
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_1
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
     
    /* doesn't matter what I do here as long as the values get 
     * returned correctly 
     */
    feature_boolean := 0;
    aux_count := 12;
    feature_info := NULL;
    
end;
/

  -- ******************************************************** 
  --   TEST_PROC_2
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_2
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
     
    /* doesn't matter what I do here as long as the values get 
     * returned correctly 
     */
    feature_boolean := 1;
    aux_count := 33;
    feature_info := 'Extra Feature Information for TEST_PROC_2';    
end;
/


-- ******************************************************** 
--   TEST_PROC_3
-- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_3
  ( current_value  OUT  NUMBER) 
AS
begin
     
    /* doesn't matter what I do here as long as the values get 
     * returned correctly.
     */
    current_value := 101;    
end;
/

  -- ******************************************************** 
  --   TEST_PROC_4
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_4
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
    
    /* raise an application error to make sure the error is being
     * handled correctly 
     */     
    raise_application_error(-20020, 'Error for Test Proc 4 ');
    
end;
/

  -- ******************************************************** 
  --   TEST_PROC_5
  -- ******************************************************** 

create or replace procedure DBMS_FEATURE_TEST_PROC_5
     ( feature_boolean  OUT  NUMBER,
       aux_count        OUT  NUMBER,
       feature_info     OUT  CLOB)
AS
begin
    
    /* What happens if values are not set? */     
    feature_info := 'TEST PROC 5';
    
end;
/

/*************************************************
 * Database Features Usage Tracking Registration 
 *************************************************/

create or replace procedure DBMS_FEATURE_REGISTER_ALLFEAT
as
  /* string to get the last sample date */
  DBFUS_LAST_SAMPLE_DATE_STR CONSTANT VARCHAR2(100) :=
            ' (select nvl(max(last_sample_date), sysdate-7) ' || 
                'from wri$_dbu_usage_sample) ';

begin

  /********************** 
   * Advanced Replication
   **********************/

  declare 
    DBFUS_ADV_REPLICATION_STR CONSTANT VARCHAR2(1000) := 
        'select count(*), NULL, NULL from dba_repcat';

  begin
    dbms_feature_usage.register_db_feature
     ('Advanced Replication',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ADV_REPLICATION_STR,
      'Advanced Replication has been enabled.');
  end;

  /********************** 
   * Advanced Security Option Encryption/Checksumming
   **********************/

  declare
    DBFUS_ASO_STR CONSTANT VARCHAR2(1000) := 
     'select count (*), NULL, NULL from v$session_connect_info where ' ||
        'network_service_banner like ''%AES256 encryption%'' or ' ||
        'network_service_banner like ''%AES192 encryption%'' or ' ||
        'network_service_banner like ''%AES128 encryption%'' or ' ||
        'network_service_banner like ''%RC4_256 encryption%'' or ' ||
        'network_service_banner like ''%RC4_128 encryption%'' or ' ||
        'network_service_banner like ''%3DES168 encryption%'' or ' ||
        'network_service_banner like ''%3DES112 encryption%'' or ' ||
        'network_service_banner like ''%RC4_56 encryption%'' or ' ||
        'network_service_banner like ''%RC4_40 encryption%'' or ' ||
        'network_service_banner like ''%DES encryption%'' or ' ||
        'network_service_banner like ''%DES40 encryption%'' or ' ||
        'network_service_banner like ''%SHA1 crypto-checksumming%'' or ' ||
        'network_service_banner like ''%MD5 crypto-checksumming%''';
  begin
    dbms_feature_usage.register_db_feature
     ('ASO native encryption and checksumming',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ASO_STR,
      'ASO network native encryption and checksumming is being used.');
  end;

  /********************** 
   * Audit Options
   **********************/

  declare 
    DBFUS_AUDIT_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from audit$ where exists ' ||
       '(select 1 from v$parameter where name = ''audit_trail'' and ' ||
          'upper(value) != ''FALSE'' and upper(value) != ''NONE'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Audit Options',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AUDIT_STR,
      'Audit options in use.');
  end;

  /**********************************************
   * Auto-Maintenance Tasks
   *********************************************/

  declare 
    DBFUS_KET_OPT_STATS_STR CONSTANT VARCHAR(1000) :=
     'select nvl(ats, 0) * nvl(cls, 0) enabled, ' ||
      'NVL((select SUM(jobs_created) ' ||
             'from dba_autotask_client_history ' ||
            'where client_name = ''auto optimizer stats collection'' ' ||
              'and window_start_time >  ' ||
                  '(SYSDATE - INTERVAL ''168'' HOUR) ), 0) jobs, NULL ' ||
     'from (select DECODE(MAX(autotask_status),''ENABLED'',1,0) ats, ' ||
            'DECODE(MAX(OPTIMIZER_STATS),''ENABLED'',1,0) cls ' ||
            'from dba_autotask_window_clients)';

    DBFUS_KET_SEG_STATS_STR CONSTANT VARCHAR(1000) :=
     'select nvl(ats, 0) * nvl(cls, 0) enabled, ' ||
      'NVL((select SUM(jobs_created) ' ||
             'from dba_autotask_client_history ' ||
            'where client_name = ''auto space advisor'' ' ||
              'and window_start_time >  ' ||
                  '(SYSDATE - INTERVAL ''168'' HOUR) ), 0) jobs, NULL ' ||
     'from (select DECODE(MAX(autotask_status),''ENABLED'',1,0) ats, ' ||
            'DECODE(MAX(SEGMENT_ADVISOR),''ENABLED'',1,0) cls ' ||
            'from dba_autotask_window_clients)';

    DBFUS_KET_SQL_STATS_STR CONSTANT VARCHAR(1000) :=
     'select nvl(ats, 0) * nvl(cls, 0) enabled, ' ||
      'NVL((select SUM(jobs_created) ' ||
             'from dba_autotask_client_history ' ||
            'where client_name = ''sql tuning advisor'' ' ||
              'and window_start_time >  ' ||
                  '(SYSDATE - INTERVAL ''168'' HOUR) ), 0) jobs, NULL ' ||
     'from (select DECODE(MAX(autotask_status),''ENABLED'',1,0) ats, ' ||
            'DECODE(MAX(SQL_TUNE_ADVISOR),''ENABLED'',1,0) cls ' ||
            'from dba_autotask_window_clients)';


  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Maintenance - Optimizer Statistics Gathering',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_KET_OPT_STATS_STR,
      'Automatic initiation of Optimizer Statistics Collection');

    dbms_feature_usage.register_db_feature
     ('Automatic Maintenance - Space Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_KET_SEG_STATS_STR,
      'Automatic initiation of Space Advisor');

    dbms_feature_usage.register_db_feature
     ('Automatic Maintenance - SQL Tuning Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_KET_SQL_STATS_STR,
      'Automatic initiation of SQL Tuning Advisor');
  end;

  /**********************************************
   * Automatic Segment Space Management (system)
   **********************************************/

  declare 
    DBFUS_BITMAP_SEGMENT_SYS_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_AUTO_SSM';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Segment Space Management (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_BITMAP_SEGMENT_SYS_PROC,
      'Extents of locally managed tablespaces are managed ' ||
      'automatically by Oracle.');
  end;

  /********************************************
   * Automatic Segment Space Management (user)
   ********************************************/

  declare 
    DBFUS_BITMAP_SEGMENT_USER_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_tablespaces where ' ||
        'segment_space_management = ''AUTO'' and ' ||
        'tablespace_name not in ' ||
          '(''SYSTEM'', ''SYSAUX'', ''TEMP'', ''USERS'', ''EXAMPLE'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Segment Space Management (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BITMAP_SEGMENT_USER_STR,
      'Extents of locally managed user tablespaces are managed ' ||
      'automatically by Oracle.');
  end;

  /*********************************
   * Automatic SQL Execution Memory
   *********************************/

  declare 
    DBFUS_AUTO_PGA_STR CONSTANT VARCHAR2(1000) := 
      'select decode(pga + wap, 2, 1, 0), pga_aux + wap_aux, NULL from ' ||
        '(select count(*) pga, 0 pga_aux from v$system_parameter ' ||
          'where name = ''pga_aggregate_target'' and value != ''0''), ' ||
        '(select count(*) wap, 0 wap_aux from v$system_parameter ' ||
          'where name = ''workarea_size_policy'' and upper(value) = ''AUTO'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic SQL Execution Memory',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AUTO_PGA_STR,
      'Sizing of work areas for all dedicated sessions (PGA) is automatic.');
  end;

  /******************************** 
   * Automatic Storage Management
   ******************************/

  declare 
    DBFUS_ASM_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_ASM';
 
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Storage Management',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_ASM_PROC,
      'Automatic Storage Management has been enabled');
  end;

  /***************************
   * Automatic Undo Management
   ***************************/

  declare 
    DBFUS_AUM_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_AUM';

  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Undo Management',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_AUM_PROC,
      'Oracle automatically manages undo data using an UNDO tablespace.');
  end;

  /**************************************
   * Automatic Workload Repository (AWR)
   **************************************/
  begin
    dbms_feature_usage.register_db_feature
       ('Automatic Workload Repository'
       ,dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED
       ,NULL
       ,dbms_feature_usage.DBU_DETECT_BY_PROCEDURE
       ,'DBMS_FEATURE_AWR'
       ,'A manual Automatic Workload Repository (AWR) snapshot was taken ' ||
        'in the last sample period.');
  end;


  /***************
   * AWR Baseline
   ***************/

  declare 
    DBFUS_AWR_BASELINE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), count(*), NULL from dba_hist_baseline ' ||
        'where baseline_name != ''SYSTEM_MOVING_WINDOW''';

  begin
    dbms_feature_usage.register_db_feature
     ('AWR Baseline',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AWR_BASELINE_STR,
      'At least one AWR Baseline has been created by the user');
  end;

  /************************
   * AWR Baseline Template
   ************************/

  declare 
    DBFUS_AWR_BL_TEMPLATE_STR VARCHAR2(1000) := 
      'select count(*), count(*), NULL ' ||
        'from dba_hist_baseline_template';

  begin
    dbms_feature_usage.register_db_feature
     ('AWR Baseline Template',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AWR_BL_TEMPLATE_STR,
      'At least one AWR Baseline Template has been created by the user');
  end;

  /***************
   * AWR Reports
   ***************/

  declare 
    DBFUS_AWR_REPORT_STR CONSTANT VARCHAR2(1000) := 
    q'[with last_period as
       (select * from wrm$_wr_usage
         where upper(feature_type) like 'REPORT'
           and usage_time >= ]' ||
    DBFUS_LAST_SAMPLE_DATE_STR ||
    q'[) 
       select decode (count(*), 0, 0, 1),
              count(*),
              feature_list
         from last_period,
        (select substr(sys_connect_by_path(feature_count, ','),2) feature_list
           from 
             (select feature_count,
                     count(*) over () cnt, 
                     row_number () over (order by 1) seq 
                from 
                  (select feature_name || ':' || count(*) feature_count
                     from last_period
                 group by feature_name)
             ) 
        where seq=cnt
        start with seq=1 
   connect by prior seq+1=seq)
     group by feature_list]';

  begin
    dbms_feature_usage.register_db_feature
     ('AWR Report',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_AWR_REPORT_STR,
      'At least one Workload Repository Report has been created by the user');
  end;

  /**************************
   * Backup Encryption
   **************************/

  /* This query returns 1 if there are any encrypted backup pieces,
   * whose status is 'available'.
   * Controlfile autobackups are ignored, because we don't want to 
   * consider RMAN in use if they just turned on the controlfile autobackup
   * feature. */

  begin
    dbms_feature_usage.register_db_feature
     ('Backup Encryption',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_BACKUP_ENCRYPTION',
      'Encrypted backups are being used.');
  end;

  /********************************
   * Baseline Adaptive Thresholds
   ********************************/

  declare
    DBFUS_BASELINE_ADAPTIVE_STR CONSTANT VARCHAR2(1000) :=
      'select decode(nvl(sum(moving)+sum(static),0), 0, 0, 1) '||
            ',nvl(sum(moving)+sum(static),0) '||
            ',''Adaptive: ''||nvl(sum(moving),0)||''; Static:''||nvl(sum(static),0) '||
        'from (select decode(AB.baseline_id, 0, 0, 1) static '||
                    ',decode(AB.baseline_id, 0, 1, 0) moving '||
                'from dbsnmp.bsln_threshold_params TP '||
                    ',dbsnmp.bsln_baselines B '||
                    ',dba_hist_baseline AB '||
                    ',v$database D '||
                    ',v$instance I '||
               'where AB.dbid = D.dbid '||
                 'and B.dbid = AB.dbid '||
                 'and B.baseline_id = AB.baseline_id '||
                 'and B.instance_name = I.instance_name '||
                 'and TP.bsln_guid = B.bsln_guid '||
                 'and in_effect = ''Y'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Baseline Adaptive Thresholds',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BASELINE_ADAPTIVE_STR,
      'Adaptive Thresholds have been configured.');
  end;

  /********************************
   * Baseline Static Computations
   ********************************/

  declare
    DBFUS_BASELINE_COMPUTES_STR CONSTANT VARCHAR2(1000) :=
      'select decode(count(*), 0, 0, 1), count(*), NULL '||
        'from dba_hist_baseline_metadata AB '||
            ',dbsnmp.bsln_baselines B '||
            ',v$database D '||
            ',v$instance I '||
       'where AB.dbid = D.dbid '||
         'and AB.baseline_type <> ''MOVING_WINDOW'' '||
         'and B.dbid = AB.dbid '||
         'and B.baseline_id = AB.baseline_id '||
         'and B.instance_name = I.instance_name '||
         'and B.last_compute_date IS NOT NULL';
  begin
    dbms_feature_usage.register_db_feature
     ('Baseline Static Computations',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BASELINE_COMPUTES_STR,
      'Static baseline statistics have been computed.');
  end;

  /************************ 
   * Block Change Tracking
   ************************/

  declare 
    DBFUS_BLOCK_CHANGE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL ' ||
        'from v$block_change_tracking where status = ''ENABLED''';

  begin
    dbms_feature_usage.register_db_feature
     ('Change-Aware Incremental Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BLOCK_CHANGE_STR,
      'Track blocks that have changed in the database.');
  end;

  /********************** 
   * Client Identifier
   **********************/

  declare 
    DBFUS_CLIENT_IDN_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$session ' ||
      'where client_identifier is not null';

  begin
    dbms_feature_usage.register_db_feature
     ('Client Identifier',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CLIENT_IDN_STR,
      'Application User Proxy Authentication: Client Identifier is ' ||
      'used at this specific time.');
  end;


  /**********************************
   * Clusterwide Global Transactions
   **********************************/

  declare 
    DBFUS_CLUSTER_GTX_STR CONSTANT VARCHAR2(1000) :=
      'select value, NULL, NULL from v$sysstat ' ||
        'where name = ''Clusterwide global transactions''';
  
  begin
    dbms_feature_usage.register_db_feature
     ('Clusterwide Global Transactions',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CLUSTER_GTX_STR,
      'Clusterwide Global Transactions is being used.');
  end;

  /**********************************
   * Crossedition Triggers
   **********************************/

  declare 
    DBFUS_XEDTRG_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), count(1), NULL from trigger$ t ' ||
        'where bitand(t.property, 8192) = 8192';
  
  begin
    dbms_feature_usage.register_db_feature
     ('Crossedition Triggers',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_XEDTRG_STR,
      'Crossedition triggers is being used.');
  end;

  /****************************** 
   * CSSCAN - character set scan
   *******************************/

  declare 
    DBFUS_CSSCAN_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), null, null  from ' ||
      'csmig.csm$parameters c ' ||
      'where c.name=''TIME_START'' and ' ||
      'to_date(c.value, ''YYYY-MM-DD HH24:MI:SS'') ' ||
      '>= ' || DBFUS_LAST_SAMPLE_DATE_STR;

  begin
    dbms_feature_usage.register_db_feature
     ('CSSCAN',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'CSMIG.csm$parameters',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CSSCAN_STR,
      'Oracle Database has been scanned at least once for character set:' ||
      'CSSCAN has been run at least once.');
  end;
  
 
  /****************************** 
   * Character semantics turned on
   *******************************/

  declare 
    DBFUS_CHAR_SEMANTICS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), null, null  from ' ||
      'sys.v$nls_parameters where ' ||
      'parameter=''NLS_LENGTH_SEMANTICS'' and upper(value)=''CHAR'' ';

  begin
    dbms_feature_usage.register_db_feature
     ('Character Semantics',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CHAR_SEMANTICS_STR,
      'Character length semantics is used in Oracle Database');
  end;
  
  /**************************** 
   * Character Set of Database
   ****************************/

  declare 
    DBFUS_CHAR_SET_STR CONSTANT VARCHAR2(1000) := 
      'select 1, null, value  from ' ||
      'sys.v$nls_parameters where ' ||
      'parameter=''NLS_CHARACTERSET'' ';

  begin
    dbms_feature_usage.register_db_feature
     ('Character Set',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_CHAR_SET_STR,
      'Character set is used in Oracle Database');
  end;
  

  /********************** 
   * Data Guard
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('Data Guard',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_DATA_GUARD',
      'Data Guard, a set of services, is being used to create, ' ||
      'maintain, manage, and monitor one or more standby databases.');
  end;

  /********************** 
   * Data Mining
   **********************/

  declare 
    DBFUS_ODM_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), null, null from model$ where ' ||
      '(alg not in (4,5)) or ' ||
      '(alg in (4,5) and obj# in (select mod# from modeltab$ where typ#=2))';
  begin
    dbms_feature_usage.register_db_feature
     ('Data Mining',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ODM_STR,
      'There exist Oracle Data Mining models in the database.');
  end;

  /********************** 
   * Dynamic SGA
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('Dynamic SGA',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_DYN_SGA',
      'The Oracle SGA has been dynamically resized through an ' ||
      'ALTER SYSTEM SET statement.');
  end;

  /*************************************************
   * DMU - Database Migration Assistant for Unicode
   *************************************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Database Migration Assistant for Unicode',
      dbms_feature_usage.DBU_INST_OBJECT,
      'SYS.PROPS$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_DMU',
      'Database Migration Assistant for Unicode has been used.');
  end;

  /******************************
   * Editions
   *******************************/

  declare
    DBFUS_EDITION_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), count(1), null from sys.edition$ e, sys.obj$ o ' ||
      'where e.obj# = o.obj# and o.name != ''ORA$BASE''';

  begin
    dbms_feature_usage.register_db_feature
     ('Editions',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EDITION_STR,
      'Editions is being used.');
  end;

  /******************************
   * Editioning Views
   *******************************/

  declare
    DBFUS_EDITION_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), count(1), null from sys.view$ v ' ||
      'where bitand(v.property, 32) = 32';

  begin
    dbms_feature_usage.register_db_feature
     ('Editioning Views',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EDITION_STR,
      'Editioning views is being used.');
  end;

  /******************************
   * EM - DB Control tracking
   *******************************/

  declare
    DBFUS_EM_DBC_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), null, null from ' ||
      'dbsnmp.mgmt_db_feature_log a ' ||
      'where a.source=''DBC'' and ' ||
      'CAST(a.last_update_date AS DATE) ' ||
      '>= ' || DBFUS_LAST_SAMPLE_DATE_STR;
  begin
    dbms_feature_usage.register_db_feature
     ('EM Database Control',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EM_DBC_STR,
      'EM Database Control Home Page has been visited at least once.');
  end;

  /******************************
   * EM - Grid Control tracking
   *******************************/

  declare
    DBFUS_EM_GC_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), null, null from ' ||
      'dbsnmp.mgmt_db_feature_log a ' ||
      'where a.source=''GC'' and ' ||
      'CAST(a.last_update_date AS DATE) ' ||
      '>= ' || DBFUS_LAST_SAMPLE_DATE_STR;
  begin
    dbms_feature_usage.register_db_feature
     ('EM Grid Control',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EM_GC_STR,
      'EM Grid Control Database Home Page has been visited at least once.');
  end;

  /******************************
   * EM Performance Page  tracking
   *******************************/

  declare
    DBFUS_EM_DIAG_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), null, null from ' ||
      'dbsnmp.mgmt_db_feature_log a ' ||
      'where a.source=''Diagnostic'' and ' ||
      'CAST(a.last_update_date AS DATE) ' ||
      '>= ' || DBFUS_LAST_SAMPLE_DATE_STR;
  begin
    dbms_feature_usage.register_db_feature
     ('EM Performance Page',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EM_DIAG_STR,
      'EM Performance Page has been visited at least once.');
  end;

  /******************************
   * EM - SQL Monitoring and Tuning pages tracking
   *******************************/

  declare
    DBFUS_EM_TUNING_STR CONSTANT VARCHAR2(1000) :=
      'select count(1), null, null from ' ||
      'dbsnmp.mgmt_db_feature_log a ' ||
      'where a.source=''Tuning'' and ' ||
      'CAST(a.last_update_date AS DATE) ' ||
      '>= ' || DBFUS_LAST_SAMPLE_DATE_STR;
  begin
    dbms_feature_usage.register_db_feature
     ('SQL Monitoring and Tuning pages',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_EM_TUNING_STR,
      'EM SQL Monitoring and Tuning pages has been visited at least once.');
  end;

  /********************** 
   * File Mapping
   **********************/

  declare 
    DBFUS_FILE_MAPPING_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name = ''file_mapping'' and upper(value) = ''TRUE'' and ' ||
        'exists (select 1 from v$map_file)';

  begin
    dbms_feature_usage.register_db_feature
     ('File Mapping',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_FILE_MAPPING_STR,
      'File Mapping, the mechanism that shows a complete mapping ' ||
      'of a file to logical volumes and physical devices, is ' ||
      'being used.');
  end;


  /***************************
   * Flashback Database
   ***************************/

  declare 
    DBFUS_FB_DB_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$database where ' ||
        'flashback_on = ''YES''';

  begin
    dbms_feature_usage.register_db_feature
     ('Flashback Database',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_FB_DB_STR,
      'Flashback Database, a rewind button for the database, is enabled');
  end;


  /***************************
   * Flashback Data Archive
   ***************************/

  declare 
    DBFUS_FDA_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from DBA_FLASHBACK_ARCHIVE_TABLES';

  begin
    dbms_feature_usage.register_db_feature
     ('Flashback Data Archive',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_FDA_STR,
      'Flashback Data Archive, a historical repository of changes to data ' ||
      'contained in a table, is used ');
  end;


  /******************************
   * Internode Parallel Execution
   ******************************/

  declare 
    DBFUS_INODE_PRL_EXEC_STR CONSTANT VARCHAR2(1000) := 
      'select sum(value), NULL, NULL from gv$pq_sysstat ' ||
        'where statistic like ''%Initiated (IPQ)%''';
      

  begin
    dbms_feature_usage.register_db_feature
     ('Internode Parallel Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_INODE_PRL_EXEC_STR,
      'Internode Parallel Execution is being used.');
  end;

  /********************** 
   * Label Security
   **********************/

  declare 
    DBFUS_LABEL_SECURITY_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_policies ' ||
       'where pf_owner = ''LBACSYS'' and policy_name like ''LBAC_%'' '||
       'and object_owner != ''SA_DEMO''';

  begin
    dbms_feature_usage.register_db_feature
     ('Label Security',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'LBACSYS.lbac$polt',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LABEL_SECURITY_STR,
      'Oracle Label Security, that enables label-based access control ' ||
      'Oracle applications, is being used.');
  end;

  /********************** 
   * Oracle Database Vault
   **********************/
  declare
     DBFUS_DATABASE_VAULT_PROC CONSTANT VARCHAR2(1000) :=
       'DBMS_FEATURE_DATABASE_VAULT';
  begin
     dbms_feature_usage.register_db_feature
     ('Oracle Database Vault',
      dbms_feature_usage.DBU_INST_OBJECT,
      'dvsys.realm$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_DATABASE_VAULT_PROC,
      'Oracle Database Vault is being used');
  end;

  /***************************************
   * Deferred Segment Creation
   ***************************************/

  declare 
    DBFUS_DEFERRED_SEG_CRT_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_DEFERRED_SEG_CRT';
  begin
    dbms_feature_usage.register_db_feature
     ('Deferred Segment Creation',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_DEFERRED_SEG_CRT_PROC,
      'Deferred Segment Creation is being used');
  end;

  /***************************************
   * Locally Managed Tablespaces (system)
   ***************************************/

  declare 
    DBFUS_LOCALLY_MANAGED_SYS_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_LMT';

  begin
    dbms_feature_usage.register_db_feature
     ('Locally Managed Tablespaces (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_LOCALLY_MANAGED_SYS_PROC,
      'There exists tablespaces that are locally managed in ' ||
      'the database.');
  end;

  /*************************************
   * Locally Managed Tablespaces (user)
   *************************************/

  declare 
    DBFUS_LOCALLY_MANAGED_USER_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_tablespaces where ' ||
        'extent_management = ''LOCAL'' and ' ||
        'tablespace_name not in ' ||
          '(''SYSTEM'', ''SYSAUX'', ''TEMP'', ''USERS'', ''EXAMPLE'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Locally Managed Tablespaces (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LOCALLY_MANAGED_USER_STR,
      'There exists user tablespaces that are locally managed in ' ||
      'the database.');
  end;

  /******************************
   * Messaging Gateway
   ******************************/

  declare
    DBFUS_MSG_GATEWAY_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from dba_registry ' ||
        'where comp_id = ''MGW'' and status != ''REMOVED'' and ' ||
        'exists (select 1 from mgw$_links)';

  begin
    dbms_feature_usage.register_db_feature
     ('Messaging Gateway',
      dbms_feature_usage.DBU_INST_OBJECT,
      'SYS.MGW$_GATEWAY',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MSG_GATEWAY_STR,
      'Messaging Gateway, that enables communication between non-Oracle ' ||
      'messaging systems and Advanced Queuing (AQ), link configured.');
  end;

  /********************** 
   * VLM
   **********************/

  declare 
    DBFUS_VLM_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name like ''use_indirect_data_buffers'' and upper(value) != ''FALSE''';
  begin
    dbms_feature_usage.register_db_feature
     ('Very Large Memory',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_VLM_ADV_STR,
      'Very Large Memory is enabled.');
  end;


  /********************** 
   * Automatic Memory Tuning
   **********************/
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic Memory Tuning',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_AUTO_MEM',
      'Automatic Memory Tuning is enabled.');
  end;

  /********************** 
   * Automatic SGA Tuning
   **********************/
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic SGA Tuning',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_AUTO_SGA',
      'Automatic SGA Tuning is enabled.');
  end;


  /********************** 
   * ENCRYPTED Tablespace
   **********************/
  declare 
    DBFUS_ENT_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$encrypted_tablespaces'; 
  begin
    dbms_feature_usage.register_db_feature
     ('Encrypted Tablespaces',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_ENT_ADV_STR,
      'Encrypted Tablespaces is enabled.');
  end;

  
  /********************** 
   * MTTR Advisor
   **********************/

  declare 
    DBFUS_MTTR_ADV_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$statistics_level where ' ||
        'statistics_name = ''MTTR Advice'' and ' ||
        'system_status = ''ENABLED'' and ' ||
        'exists (select 1 from v$instance_recovery ' ||
                  'where target_mttr != 0) and ' ||
        'exists (select 1 from v$mttr_target_advice ' ||
                  'where advice_status = ''ON'')';

  begin
    dbms_feature_usage.register_db_feature
     ('MTTR Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MTTR_ADV_STR,
      'Mean Time to Recover Advisor is enabled.');
  end;

  /*********************** 
   * Multiple Block Sizes
   ***********************/

  declare 
    DBFUS_MULT_BLOCK_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name like ''db_%_cache_size'' and value != ''0''';

  begin
    dbms_feature_usage.register_db_feature
     ('Multiple Block Sizes',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MULT_BLOCK_SIZE_STR,
      'Multiple Block Sizes are being used with this database.');
  end;

  /***************************** 
   * OLAP - Analytic Workspaces
   *****************************/

  declare 
    DBFUS_OLAP_AW_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), count(*), NULL from dba_aws where AW_NUMBER >= 1000' ||
        'and owner not in (''DM'',''OLAPTRAIN'',''GLOBAL'',''HR'',''OE'','||
        '''PM'',''SH'',''IX'',''BI'',''SCOTT'')';

  begin
    dbms_feature_usage.register_db_feature
     ('OLAP - Analytic Workspaces',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OLAP_AW_STR,
      'OLAP - the analytic workspaces stored in the database.');
  end;

  /***************************** 
   * OLAP - Cubes
   *****************************/

  declare 
    DBFUS_OLAP_CUBE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), count(*), NULL from DBA_OLAP2_CUBES ' ||
        'where invalid != ''Y'' and OWNER = ''SYS'' ' ||
        'and CUBE_NAME = ''STKPRICE_TBL''';

  begin
    dbms_feature_usage.register_db_feature
     ('OLAP - Cubes',
      dbms_feature_usage.DBU_INST_OBJECT,
      'PUBLIC.DBA_OLAP2_CUBES',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OLAP_CUBE_STR,
      'OLAP - number of cubes in the OLAP catalog that are fully ' ||
      'mapped and accessible by the OLAP API.');
  end;

  /*********************** 
   * Oracle Managed Files 
   ***********************/

  declare 
    DBFUS_OMF_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from dba_data_files where ' ||
        'upper(file_name) like ''%O1_MF%''';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Managed Files',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OMF_STR,
      'Database files are being managed by Oracle.');
  end;

  /***********************
   * Oracle Secure Backup
   ***********************/

  /* This query returns the number of backup pieces created with 
   * Oracle Secure Backup whose status is 'available'. */

  declare
    DBFUS_OSB_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from x$kccbp where ' ||
      'bitand(bpext, 256) = 256 and '                   ||
      'bitand(bpflg,1+4096+8192) = 0';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Secure Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OSB_STR,
      'Oracle Secure Backup is used for backups to tertiary storage.');
  end;

  /*******************************
   * Parallel SQL DDL Execution
   *******************************/

  declare 
    DBFUS_PSQL_DDL_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$pq_sysstat ' ||
        'where rtrim(statistic,'' '') = ''DDL Initiated''';

  begin
    dbms_feature_usage.register_db_feature
     ('Parallel SQL DDL Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PSQL_DDL_STR,
      'Parallel SQL DDL Execution is being used.');
  end;

  /*******************************
   * Parallel SQL DML Execution
   *******************************/

  declare 
    DBFUS_PSQL_DML_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$pq_sysstat ' ||
        'where rtrim(statistic,'' '') = ''DML Initiated''';

  begin
    dbms_feature_usage.register_db_feature
     ('Parallel SQL DML Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PSQL_DML_STR,
      'Parallel SQL DML Execution is being used.');
  end;

  /*******************************
   * Parallel SQL Query Execution
   *******************************/

  declare 
    DBFUS_PSQL_QUERY_STR CONSTANT VARCHAR2(1000) := 
      'select value, NULL, NULL from v$pq_sysstat ' ||
        'where rtrim(statistic,'' '') = ''Queries Initiated''';

  begin
    dbms_feature_usage.register_db_feature
     ('Parallel SQL Query Execution',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_PSQL_QUERY_STR,
      'Parallel SQL Query Execution is being used.');
  end;

  /************************
   * Partitioning (system)
   ************************/

  declare 
    DBFUS_PARTN_SYS_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_PARTITION_SYSTEM';

  begin
    dbms_feature_usage.register_db_feature
     ('Partitioning (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PARTN_SYS_PROC,
      'Oracle Partitioning option is being used - there is at ' ||
      'least one partitioned object created.');
  end;

  /**********************
   * Partitioning (user)
   **********************/

  declare 
    DBFUS_PARTN_USER_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_PARTITION_USER';

  begin
    dbms_feature_usage.register_db_feature
     ('Partitioning (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PARTN_USER_PROC,
      'Oracle Partitioning option is being used - there is at ' ||
      'least one user partitioned object created.');
  end;

  /****************************
   * Oracle Text
   ****************************/

  declare
    DBFUS_TEXT_PROC CONSTANT VARCHAR2(1000) := 'ctxsys.drifeat.dr$feature_track';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Text',
      dbms_feature_usage.DBU_INST_OBJECT,
      'ctxsys.drifeat',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_TEXT_PROC,
      'Oracle Text is being used - there is at least one oracle '|| 
      'text index');
  end;

  /****************************
   * PL/SQL Native Compilation
   ****************************/

  declare 
    DBFUS_PLSQL_NATIVE_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_PLSQL_NATIVE';

  begin
    dbms_feature_usage.register_db_feature
     ('PL/SQL Native Compilation',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_PLSQL_NATIVE_PROC,
      'PL/SQL Native Compilation is being used - there is at least one ' ||
      'natively compiled PL/SQL library unit in the database.');
  end;

  /********************************
   * Quality of Service Management
   ********************************/

  declare 
    DBFUS_QOSM_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_QOSM';
 
  begin
    dbms_feature_usage.register_db_feature
     ('Quality of Service Management',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_QOSM_PROC,
      'Quality of Service Management has been used.');
  end;

  /****************************
   * Real Application Clusters 
   ****************************/

  declare 
    DBFUS_RAC_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_RAC';

  begin
    dbms_feature_usage.register_db_feature
     ('Real Application Clusters (RAC)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_RAC_PROC,
      'Real Application Clusters (RAC) is configured.');
  end;

  /********************** 
   * Recovery Area
   **********************/

  declare 
    DBFUS_RECOVERY_AREA_STR CONSTANT VARCHAR2(1000) := 
      'select p, s, NULL from ' ||
        '(select count(*) p from v$parameter ' ||
         'where name = ''db_recovery_file_dest'' and value is not null), ' ||
        '(select to_number(value) s from v$parameter ' ||
         'where name = ''db_recovery_file_dest_size'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Recovery Area',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RECOVERY_AREA_STR,
      'The recovery area is configured.');
  end;

  /**************************
   * Recovery Manager (RMAN)
   **************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Recovery Manager (RMAN)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_BACKUP',
      'Recovery Manager (RMAN) is being used to backup the database.');
  end;

  /********************** 
   * RMAN - Disk Backup
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('RMAN - Disk Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_DISK_BACKUP',
      'Recovery Manager (RMAN) is being used to backup the database to disk.');
  end;

  /********************** 
   * RMAN - Tape Backup
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('RMAN - Tape Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_TAPE_BACKUP',
      'Recovery Manager (RMAN) is being used to backup the database to tape.');
  end;

  /**********************************
   * RMAN - ZLIB compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup ZLIB Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_ZLIB',
      'ZLIB compressed backups are being used.');
  end;

  /**********************************
   * RMAN - BZIP2 compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup BZIP2 Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_BZIP2',
      'BZIP2 compressed backups are being used.');
  end;

  /**********************************
   * RMAN - BASIC compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup BASIC Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_BASIC',
      'BASIC compressed backups are being used.');
  end;

  /**********************************
   * RMAN - LOW compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup LOW Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_LOW',
      'LOW compressed backups are being used.');
  end;

  /**********************************
   * RMAN - MEDIUM compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup MEDIUM Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_MEDIUM',
      'MEDIUM compressed backups are being used.');
  end;

  /**********************************
   * RMAN - HIGH compressed backups
   **********************************/
  begin
    
    dbms_feature_usage.register_db_feature
     ('Backup HIGH Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RMAN_HIGH',
      'HIGH compressed backups are being used.');
  end;

  /****************************
  * Long-term archival backups
  *****************************/

  declare
  DBFUS_KEEP_BACKUP_STR CONSTANT VARCHAR2(1000) :=
    'select count(*), NULL, decode(min(keep_options), ''BACKUP_LOGS'',
    ''Consistent backups archived'') from v$backup_set where keep = ''YES'''; 

  begin
    dbms_feature_usage.register_db_feature
     ('Long-term Archival Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_KEEP_BACKUP_STR,
      'Long-term archival backups are being used.');
  end;

  /****************************
  * Multi section backups
  *****************************/

  declare
  DBFUS_MULTI_SECTION_BACKUP_STR CONSTANT VARCHAR2(1000) :=
    'select count(*), NULL, NULL ' ||
    'from v$backup_set where multi_section = ''YES'''; 

  begin
    dbms_feature_usage.register_db_feature
     ('Multi Section Backup',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MULTI_SECTION_BACKUP_STR,
      'Multi section backups are being used.');
  end;    

  /*********************** 
   * Block Media Recovery
   ***********************/

  declare
    DBFUS_BLOCK_MEDIA_RCV_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation = ''BLOCK MEDIA RECOVERY'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Block Media Recovery',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BLOCK_MEDIA_RCV_STR,
      'Block Media Recovery is being used to repair the database.');
  end;


  /*********************** 
   * Restore Point
   ***********************/

  declare
    DBFUS_RESTORE_POINT_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$restore_point)';
  begin
    dbms_feature_usage.register_db_feature
     ('Restore Point',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_RESTORE_POINT_STR,
      'Restore Points are being used as targets for Flashback');
  end;

  /*********************** 
   * Logfile Multiplexing
   ***********************/

  declare
    DBFUS_LOGFILE_MULTIPLEX_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from ' ||
        '  (select count(*) a from v$logfile group by group#)' ||
        '  where a>1)';
  begin
    dbms_feature_usage.register_db_feature
     ('Logfile Multiplexing',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LOGFILE_MULTIPLEX_STR,
      'Multiple members are used in a single log file group');
  end;


  /*********************** 
   * Bigfile Tablespace
   ***********************/

  declare
    DBFUS_BIGFILE_TBS_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$tablespace' ||
        '  where bigfile = ''YES'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Bigfile Tablespace',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BIGFILE_TBS_STR,
      'Bigfile tablespace is being used');
  end;


  /************************** 
   * Transportable Tablespace
   **************************/

  declare
    DBFUS_TRANSPORTABLE_TBS_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$datafile' ||
        '  where plugged_in = 1)';
  begin
    dbms_feature_usage.register_db_feature
     ('Transportable Tablespace',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_TRANSPORTABLE_TBS_STR,
      'Transportable tablespace is being used');
  end;


  /*********************** 
   * Read Only Tablespace
   ***********************/
  
  declare
    DBFUS_READONLY_TBS_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$datafile' ||
        '  where enabled = ''READ ONLY'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Read Only Tablespace',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_READONLY_TBS_STR,
      'Read only tablespace is being used');
  end;

  /************************* 
   * Read Only Open Delayed
   *************************/
  
  declare
    DBFUS_READOPEN_DELAY_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$parameter' ||
        '  where name = ''read_only_open_delayed'' and value = ''TRUE'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Deferred Open Read Only',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_READOPEN_DELAY_STR,
      'Deferred open read only feature is enabled');
  end;


  /*************************************
   * Active Data Guard: Real Time Query
   *************************************/

  declare
    DBFUS_READABLE_SBY_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from ' ||
        '   (select count(*) a from v$archive_dest_status ' ||
        '     where recovery_mode like ''MANAGED%'' ' ||
        '       and status = ''VALID'' ' ||
        '       and database_mode = ''OPEN_READ-ONLY''), ' ||
        '   (select count(*) b from v$parameter '||
        '     where name = ''compatible'' and value like ''11%'') '||
        '   where a > 0 and b > 0)';
  begin
    dbms_feature_usage.register_db_feature
     ('Active Data Guard - Real-Time Query on Physical Standby',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_READABLE_SBY_STR,
      'Active Data Guard real-time query is enabled on a physical standby');
  end;


  /********************* 
   * Backup Rollforward
   *********************/

  declare
    DBFUS_BACKUP_ROLLFORWARD_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$rman_status' ||
        '  where operation = ''BACKUP COPYROLLFORWARD'')';
  begin
    dbms_feature_usage.register_db_feature
     ('Backup Rollforward',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_BACKUP_ROLLFORWARD_STR,
      'Backup Rollforward strategy is being used to backup the database.');
  end;

  /************************ 
   * Data Recovery Advisor
   ************************/

  declare
    DBFUS_DATA_RCV_ADVISOR_STR CONSTANT VARCHAR2(1000) :=
      'select p, NULL, NULL from ' ||
        '(select count(*) p from v$ir_repair' ||
        '  where rownum = 1)';
  begin
    dbms_feature_usage.register_db_feature
     ('Data Recovery Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DATA_RCV_ADVISOR_STR,
      'Data Recovery Advisor (DRA) is being used to repair the database.');
  end;

  /********************** 
   * Resource Manager
   **********************/

  begin
    dbms_feature_usage.register_db_feature
     ('Resource Manager',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_RESOURCE_MANAGER',
      'Oracle Database Resource Manager is being used to manage ' ||
      'database resources.');
  end;

  /********************** 
   * Instance Caging
   **********************/

  declare
    DBFUS_DATA_INSTANCE_CAGING_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from v$rsrc_plan_history where ' ||
      'name != ''INTERNAL_PLAN'' and name is not null and ' ||
      'instance_caging = ''ON'' and ' ||
      '(name != ''DEFAULT_MAINTENANCE_PLAN'' or ' ||
      '  (window_name is null or ' ||
      '   (window_name != ''MONDAY_WINDOW'' and ' ||
      '    window_name != ''TUESDAY_WINDOW'' and ' ||
      '    window_name != ''WEDNESDAY_WINDOW'' and ' ||
      '    window_name != ''THURSDAY_WINDOW'' and ' ||
      '    window_name != ''FRIDAY_WINDOW'' and ' ||
      '    window_name != ''SATURDAY_WINDOW'' and ' ||
      '    window_name != ''SUNDAY_WINDOW''))) ';
  begin
    dbms_feature_usage.register_db_feature
     ('Instance Caging',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DATA_INSTANCE_CAGING_STR,
      'Instance Caging is being used to limit the CPU usage by the ' ||
      'database instance.');
  end;

  /********************** 
   * dNFS
   **********************/

  declare
    DBFUS_DATA_DNFS_STR CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from v$dnfs_servers';
  begin
    dbms_feature_usage.register_db_feature
     ('Direct NFS',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_DATA_DNFS_STR,
      'Direct NFS is being used to connect to an NFS server');
  end;

  /*********************** 
   * Server Flash Cache
   ***********************/

  declare 
    DBFUS_SRV_FLASH_CACHE_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name like ''%flash_cache_size'' and value != ''0''';

  begin
    dbms_feature_usage.register_db_feature
     ('Server Flash Cache',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SRV_FLASH_CACHE_SIZE_STR,
      'Server Flash Cache is being used with this database.');
  end;

  /************************ 
   * Server Parameter File
   ************************/

  declare 
    DBFUS_SPFILE_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter where ' ||
        'name = ''spfile'' and value is not null';

  begin
    dbms_feature_usage.register_db_feature
     ('Server Parameter File',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SPFILE_STR,
      'The server parameter file (SPFILE) was used to startup the database.');
  end;

  /********************** 
   * Shared Server
   **********************/

  declare 
    DBFUS_MTS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from v$system_parameter ' ||
        'where name = ''shared_servers'' and value != ''0'' and ' ||
        'exists (select 1 from v$shared_server where requests > 0)';

  begin
    dbms_feature_usage.register_db_feature
     ('Shared Server',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_MTS_STR,
      'The database is configured as Shared Server, where one server ' ||
      'process can service multiple client programs.');
  end;

  /********************** 
   * Spatial 
     If Spatial is installed then the second query returns 1;
     else it returns 0. So use that to multiply the metadata count
     to get only the Spatial install usage and not the Locator install 
     usage. 
   **********************/

  declare 
    DBFUS_SPATIAL_STR CONSTANT VARCHAR2(1000) := 
     'select atc*ix, atc*ix, NULL from ' ||
       '(select count(*) atc ' ||
          'from mdsys.sdo_geom_metadata_table '||
         'where sdo_owner not in (''MDSYS'', ''OE'')), ' ||
       '(select count(*) ix ' ||
          'from  dba_registry where comp_id = ''SDO'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Spatial',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'MDSYS.all_sdo_index_metadata',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SPATIAL_STR,
      'There is at least one usage of the Oracle Spatial index ' ||
      'metadata table.');
  end;

  /**********************
   * Locator
     If Locator is installed then the second query returns 1;
     else it returns 0. So use that to multiply the metadata count
     to get only the Locator install usage and not the Spatial install
     usage.
   **********************/

  declare
    DBFUS_LOCATOR_STR CONSTANT VARCHAR2(1000) :=
     'select atc*six, atc*six, NULL from ' ||
       '(select count(*) atc ' ||
          'from mdsys.sdo_geom_metadata_table '||
         'where sdo_owner not in (''MDSYS'', ''OE'')), ' ||
     ' ( select decode(sx-ix, -1, 0, 0, 0, 1) six from ( ' ||
     ' select count(*) sx from  dba_registry where comp_id = ''ORDIM''), '||
     ' ( select count(*) ix from  dba_registry where comp_id = ''SDO'')) ';

  begin
    dbms_feature_usage.register_db_feature
     ('Locator',
      dbms_feature_usage.DBU_INST_OBJECT,
      'MDSYS.sdo_geom_metadata_table',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_LOCATOR_STR,
      'There is at least one usage of the Oracle Locator index ' ||
      'metadata table.');
  end;


  /***********************************************************************
   * All advisors using the advisor framework. This includes all advisors 
   * listed in DBA_ADVISOR_DEFINITIONS and DBA_ADVISOR_USAGE views.
   ************************************************************************/
  /* FIXME: Mike would like to use a pl/sql procedure instead of a query */ 
  declare 
      dbu_detect_sql VARCHAR2(32767); 
  begin 
      FOR adv_rec IN (SELECT advisor_name, advisor_id 
                      FROM dba_advisor_definitions
                      WHERE bitand(property, 64) != 64
                      ORDER BY advisor_id)  
      LOOP
        -- build the query that will be executed to track an advisor usage

        -- clob column FEATURE_INFO will contain XML for advisor framework-
        -- level info, with advisor extra info sitting beneath the framework
        -- tag
        IF (adv_rec.advisor_name = 'ADDM') THEN 
          dbu_detect_sql := ', xmltype(prvt_hdm.db_feature_clob) ';
        ELSE
          dbu_detect_sql := '';
        END IF;

        dbu_detect_sql := 
          ' xmlelement("advisor_usage", 
              xmlelement("reports", 
                xmlelement("first_report_time", 
                            to_char(first_report_time, 
                                    ''dd-mon-yyyy hh24:mi:ss'')), 
                xmlelement("last_report_time", 
                           to_char(last_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss'')),
                xmlelement("num_db_reports", num_db_reports)) 
                ' || dbu_detect_sql || ').getClobVal(2,2) ';

        -- used:       1 if advisor executed since last sample
        -- sofar_exec: total # of executions since db create
        -- dbf_clob:   reporting, plus advisor-specific stuff
        dbu_detect_sql := 
          'SELECT used, sofar_exec, dbf_clob FROM 
             (SELECT num_execs sofar_exec, ' || dbu_detect_sql || ' dbf_clob
              FROM   dba_advisor_usage u 
              WHERE  u.advisor_name = ''' || adv_rec.advisor_name || '''), ' ||
            '(SELECT count(*) used
              FROM   dba_advisor_usage u
              WHERE u.advisor_name = ''' || adv_rec.advisor_name || ''' AND 
                    (u.num_execs > 0 or u.num_db_reports > 0) and 
                     greatest(nvl(u.last_exec_time, sysdate - 1000), 
                              nvl(u.last_report_time, sysdate - 1000)) >= 
                                       ' || DBFUS_LAST_SAMPLE_DATE_STR || ')';

        -- register the current advisor
        dbms_feature_usage.register_db_feature
          (adv_rec.advisor_name,
           dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
           NULL,
           dbms_feature_usage.DBU_DETECT_BY_SQL,
           dbu_detect_sql,
           adv_rec.advisor_name || ' has been used.');
      END LOOP;
  end;

  /******************************
   * Real-Time SQL Monitoring
   ******************************/
  declare 
      dbu_detect_sql VARCHAR2(32767); 
  begin 
      -- used:       1 if db report for monitoring details requested since
      --             last sample (list report is not tracked)
      -- sofar_exec: total # of db reports requested since db creation
      -- dbf_clob:   extra XML info
      dbu_detect_sql := 
        'SELECT used, sofar_exec, dbf_clob
         FROM   (SELECT count(*) used
                 FROM   dba_sql_monitor_usage
                 WHERE  num_db_reports > 0 AND
                        last_db_report_time >= ' || DBFUS_LAST_SAMPLE_DATE_STR
                || '), 
                (SELECT num_db_reports sofar_exec, 
                        xmlelement("sqlmon_usage", 
                         xmlelement("num_em_reports", num_em_reports),
                         xmlelement("first_db_report_time", 
                           to_char(first_db_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss'')),
                         xmlelement("last_db_report_time", 
                           to_char(last_db_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss'')),
                         xmlelement("first_em_report_time", 
                           to_char(first_em_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss'')),
                         xmlelement("last_em_report_time", 
                           to_char(last_em_report_time, 
                                   ''dd-mon-yyyy hh24:mi:ss''))
                        ).getClobVal(2,2) dbf_clob
                FROM dba_sql_monitor_usage)'; 

      -- register the feature
      dbms_feature_usage.register_db_feature
        ('Real-Time SQL Monitoring',
         dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
         NULL,
         dbms_feature_usage.DBU_DETECT_BY_SQL,
         dbu_detect_sql,
         'Real-Time SQL Monitoring Usage.');
  end;
  

  /******************************
   * SQL Tuning Set
   ******************************/
  declare 
    -- A 'user' SQL Tuning Set is one not owned by SYS, and a 'system' SQL
    -- Tuning Set is one that is owned by SYS.  This will cover the $$ STSes
    -- that Access Advisor creates, and users do not use EM as SYS, so it should
    -- be good enough for now.
    DBFUS_USER_SQL_TUNING_SET_STR CONSTANT VARCHAR2(1000) := 
      'select numss, numref, NULL from ' ||
        '(select count(*) numss ' ||
        ' from wri$_sqlset_definitions ' ||
        ' where owner <> ''SYS''), ' ||
        '(select count(*) numref ' ||
        ' from wri$_sqlset_references r, wri$_sqlset_definitions d ' ||
        ' where d.id = r.sqlset_id and d.owner <> ''SYS'')';

    DBFUS_SYS_SQL_TUNING_SET_STR CONSTANT VARCHAR2(1000) := 
      'select numss, numref, NULL from ' ||
        '(select count(*) numss ' ||
        ' from wri$_sqlset_definitions ' ||
        ' where owner = ''SYS''), ' ||
        '(select count(*) numref ' ||
        ' from wri$_sqlset_references r, wri$_sqlset_definitions d ' ||
        ' where d.id = r.sqlset_id and d.owner = ''SYS'')';
  begin
    dbms_feature_usage.register_db_feature
     ('SQL Tuning Set (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_USER_SQL_TUNING_SET_STR,
      'A SQL Tuning Set has been created in the database in a user schema.');


    dbms_feature_usage.register_db_feature
     ('SQL Tuning Set (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SYS_SQL_TUNING_SET_STR,
      'A SQL Tuning Set has been created in the database in the SYS schema.');
  end;

  /******************************
   * Automatic SQL Tuning Advisor
   ******************************/
  declare
    DBFUS_AUTOSTA_PROC VARCHAR2(100) := 'DBMS_FEATURE_AUTOSTA';
  begin
    dbms_feature_usage.register_db_feature
     ('Automatic SQL Tuning Advisor',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_AUTOSTA_PROC,
      'Automatic SQL Tuning Advisor has been used.');
  end;

  /******************************
   * SQL Profiles 
   ******************************/
  /* FIXME: Mike would like to use a pl/sql procedure instead of a query */ 
  declare 
    DBFUS_SQLPROFILE_STR CONSTANT VARCHAR2(32767) := 
      q'#SELECT used,
                prof_count, 
                profs || ', ' || manual || ', ' || auto || ', ' || 
                enabl || ', ' || cat as details
         FROM (SELECT sum(decode(status, 'ENABLED', 1, 0)) used,
                      sum(1) prof_count,
                     'Total so far: ' || sum(1) profs, 
                     'Enabled: ' || sum(decode(status, 'ENABLED', 1, 0)) enabl,
                     'Manual: ' || sum(decode(type, 'MANUAL', 1, 0)) manual,
                     'Auto: ' || sum(decode(type, 'AUTO', 1, 0)) auto,
                     'Category count: ' || count(unique category) cat
               FROM dba_sql_profiles)#';
  begin
    dbms_feature_usage.register_db_feature
     ('SQL Profile',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SQLPROFILE_STR,
      'SQL profiles have been used.');
  end;

  /************************************************
   * Database Replay: Workload Capture and Replay *
   ************************************************/
  declare
    prev_sample_count     NUMBER;
    prev_sample_date      NUMBER;

    DBFUS_WCR_CAPTURE_PROC VARCHAR2(1000) := 'DBMS_FEATURE_WCR_CAPTURE';
    DBFUS_WCR_REPLAY_PROC  VARCHAR2(1000) := 'DBMS_FEATURE_WCR_REPLAY';
  begin
    dbms_feature_usage.register_db_feature
     ('Database Replay: Workload Capture',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_WCR_CAPTURE_PROC,
      'Database Replay: Workload was ever captured.');

    dbms_feature_usage.register_db_feature
     ('Database Replay: Workload Replay',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_WCR_REPLAY_PROC,
      'Database Replay: Workload was ever replayed.');
  end;

  /********************** 
   * Streams (system)
   **********************/

  declare 
    DBFUS_STREAMS_SYS_PROC CONSTANT VARCHAR2(1000) := 
       'dbms_feature_streams';

  begin
    dbms_feature_usage.register_db_feature
     ('Streams (system)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_STREAMS_SYS_PROC,
      'Oracle Streams processes have been configured');
  end;

  /********************** 
   * Streams (user)
   **********************/

  declare 
    DBFUS_STREAMS_USER_STR CONSTANT VARCHAR2(1000) := 
    -- for AQ, there are default queues in the sys, system, ix, wmsys, sysman
    -- schemas which we do not want to count towards Streams user feature usage
    -- for Streams messaging these consumers are in db by default
     'select decode(strmsg + aq, 0, 0, 1), 0, NULL from ' ||
     '(select decode(count(*), 0, 0, 1) strmsg ' ||
     '  from dba_streams_message_consumers ' ||
     '  where streams_name != ''SCHEDULER_COORDINATOR'' and ' ||
     '  streams_name != ''SCHEDULER_PICKUP''),' ||  
     '(select decode (count(*), 0, 0, 1) aq ' ||
     '  from system.aq$_queue_tables where schema not in ' ||
     '  (''SYS'', ''SYSTEM'', ''IX'', ''WMSYS'', ''SYSMAN''))';

  begin
    dbms_feature_usage.register_db_feature
     ('Streams (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_STREAMS_USER_STR,
      'Users have configured Oracle Streams AQ');
  end;

  /********************** 
   * XStream In
   **********************/

  declare 
    DBFUS_XSTREAM_IN_PROC CONSTANT VARCHAR2(1000) := 
       'dbms_feature_xstream_in';

  begin
    dbms_feature_usage.register_db_feature
     ('XStream In',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_XSTREAM_IN_PROC,
      'Oracle XStream Inbound servers have been configured');
  end;

  /**********************
   * XStream Out
   **********************/

  declare
    DBFUS_XSTREAM_OUT_PROC CONSTANT VARCHAR2(1000) :=
       'dbms_feature_xstream_out';

  begin
    dbms_feature_usage.register_db_feature
     ('XStream Out',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_XSTREAM_OUT_PROC,
      'Oracle XStream Outbound servers have been configured');
  end;

  /**********************
   * XStream Streams
   **********************/

  declare
    DBFUS_XSTREAM_STREAMS_PROC CONSTANT VARCHAR2(1000) :=
       'dbms_feature_xstream_streams';

  begin
    dbms_feature_usage.register_db_feature
     ('XStream Streams',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_XSTREAM_STREAMS_PROC,
      'Oracle Streams with XStream functionality has been configured');
  end;

  /**********************
   * GoldenGate
   **********************/

  declare
    DBFUS_GOLDENGATE_PROC CONSTANT VARCHAR2(1000) :=
    'dbms_feature_goldengate';

  begin
    dbms_feature_usage.register_db_feature
     ('GoldenGate',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_GOLDENGATE_PROC,
      'Oracle GoldenGate Capabilities are in use.');
  end;

  /********************** 
   * Transparent Gateway
   **********************/

  declare 
    DBFUS_GATEWAYS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from hs_fds_class_date ' || 
        'where fds_class_name != ''BITE''';

  begin
    dbms_feature_usage.register_db_feature
     ('Transparent Gateway',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_GATEWAYS_STR,
      'Heterogeneous Connectivity, access to a non-Oracle system, has ' ||
      'been configured.');
  end;

  /***************************
   * Virtual Private Database
   ***************************/

  declare 
    DBFUS_VPD_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), NULL, NULL from DBA_POLICIES where OBJECT_OWNER ' || 
      'NOT IN (''SYSMAN'',''XDB'',''CTXSYS'',''OE'',''LBACSYS'')';

  begin
    dbms_feature_usage.register_db_feature
     ('Virtual Private Database (VPD)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_VPD_STR,
      'Virtual Private Database (VPD) policies are being used.');
  end;

  /********************** 
   * Workspace Manager
   **********************/

  declare 
    DBFUS_OWM_STR CONSTANT VARCHAR2(1000) := 
     'select count(*), count(*), NULL ' ||
     'from wmsys.wm$versioned_tables';

  begin
    dbms_feature_usage.register_db_feature
     ('Workspace Manager',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'WMSYS.wm$versioned_tables',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_OWM_STR,
      'There is at least one version enabled table.');
  end;

  /**************************
   * XDB
   **************************/
   
  begin
    dbms_feature_usage.register_db_feature
     ('XDB',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'XDB.Resource_View',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_XDB',
      'XDB feature is being used.');
  end;

  /*****************************
   * Application Express (APEX)
   *****************************/
  begin
    dbms_feature_usage.register_db_feature
    ( 'Application Express',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_APEX',
      'Application Express feature is being used.');
  end;

  /***************************
   * LOB 
   ***************************/

  declare
    DBMS_FEATURE_LOB CONSTANT VARCHAR2(1000) :=
      'select count(*), NULL, NULL from sys.lob$ l, sys.obj$ o, sys.user$ u ' ||
       'where l.obj# = o.obj# ' ||
         'and o.owner# = u.user# ' ||
         'and u.name not in (select schema_name from v$sysaux_occupants) ' ||
         'and u.name not in (''OUTLN'', ''OE'', ''IX'', ''PM'', ''SH'', 
              ''FLOWS_FILES'', ''FLOWS_030000'', ''FLOWS_030100'', ''APEX_030200'')';

  begin
    dbms_feature_usage.register_db_feature
     ('LOB',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBMS_FEATURE_LOB,
      'Persistent LOBs are being used.');
  end;

  /***************************
   * OBJECT 
   ***************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Object',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_OBJECT',
      'Object feature is being used.');
  end;

  /***************************
   * EXTENSIBILITY 
   ***************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Extensibility',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_EXTENSIBILITY',
      'Extensibility feature is being used.');
  end;

  /******************************
   * SQL Plan Management
   ******************************/

  declare 
    DBFUS_SQL_PLAN_MANAGEMENT_STR CONSTANT VARCHAR2(1000) := 
      'select count(*), count(*) num_plans, NULL from sqlobj$ ' ||
       'where obj_type = 2 ';

  begin
    dbms_feature_usage.register_db_feature
     ('SQL Plan Management',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SQL_PLAN_MANAGEMENT_STR,
      'SQL Plan Management has been used.');
  end;


  /******************************
   * DBMS_FEATURE_STATS_INCREMENTAL
   ******************************/
  begin
    dbms_feature_usage.register_db_feature
     ('DBMS_STATS Incremental Maintenance',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_STATS_INCREMENTAL',
      'DBMS_STATS Incremental Maintenance has been used.');
  end;


  /***************************
   * RULES MANAGER and EXPRESSION FILTER
   ***************************/
  begin
    dbms_feature_usage.register_db_feature
        ('Rules Manager',
          dbms_feature_usage.DBU_INST_OBJECT, 
          'EXFSYS.exf$attrset',
          dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
          'DBMS_FEATURE_RULESMANAGER',
           'Rules Manager and Expression Filter');
  end;

  /***************************************************************
   *  DATABASE UTILITY: ORACLE DATAPUMP EXPORT
   ***************************************************************/
  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility Datapump (Export)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities1',
       'Oracle Utility Datapump (Export) has been used.');
  end;

  /***************************************************************
   *  DATABASE UTILITY: ORACLE DATAPUMP IMPORT
   ***************************************************************/
  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility Datapump (Import)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities2',
       'Oracle Utility Datapump (Import) has been used.');
  end;

  /***************************************************************
   *  DATABASE UTILITY: SQL*LOADER (DIRECT PATH LOAD)
   ***************************************************************/
  declare
   DBFUS_UTL_SQLLOADER_STR CONSTANT VARCHAR2(1000) :=
       'select usecnt, NULL, NULL, NULL, NULL from sys.ku_utluse          ' ||
       ' where utlname = ''Oracle Utility SQL Loader (Direct Path Load)'' ' ||
       ' and   (last_used >=                                              ' ||
       '       (SELECT nvl(max(last_sample_date), sysdate-7)              ' ||
       '          FROM dba_feature_usage_statistics))';

  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility SQL Loader (Direct Path Load)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_SQL,
       DBFUS_UTL_SQLLOADER_STR,
       'Oracle Utility SQL Loader (Direct Path Load) has been used.');
  end;

  /***************************************************************
   *  DATABASE UTILITY: METADATA API
   ***************************************************************/
  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility Metadata API',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities3',
       'Oracle Utility (Metadata API) has been used.');
  end;

  /***************************************************************
   *  DATABASE UTILITY: EXTERNAL TABLE
   ***************************************************************/
  declare
  begin
   dbms_feature_usage.register_db_feature
      ('Oracle Utility External Table',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'dbms_feature_utilities4',
       'Oracle Utility External Table has been used.');
  end;
  
  /***************************************************************
   *  RESULT CACHE
   ***************************************************************/
  declare
   DBFUS_RESULT_CACHE_STR CONSTANT VARCHAR2(1000) :=
       'select (select value from v$result_cache_statistics ' ||
       '        where name = ''Block Count Current''), '      ||
       '       (select value from v$result_cache_statistics ' ||
       '        where name = ''Find Count''), null '          ||
       'from dual';

  begin
   dbms_feature_usage.register_db_feature
      ('Result Cache', 
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_SQL,
       DBFUS_RESULT_CACHE_STR,
       'The Result Cache feature has been used.');
  end;

  /************************************** 
   * TDE - Transparent Data Encryption
   **************************************/

  declare 
    DBFUS_TDE_STR CONSTANT VARCHAR2(1000) :=
      'SELECT (T1.A + T2.B) IsFeatureUsed, ' ||
             '(T1.A + T2.B) AUX_COUNT, ' ||
             '''Encryption TABLESPACE Count = '' || T1.A || '','||
               'Encryption COLUMN Count = '' || T2.B REMARK ' ||
      'FROM   (SELECT count(*) A FROM DBA_TABLESPACES WHERE ' ||
                    ' UPPER(ENCRYPTED) = ''YES'') T1, ' ||
             '(SELECT count(*) B FROM DBA_ENCRYPTED_COLUMNS) T2 ' ;
  begin
    dbms_feature_usage.register_db_feature
     ('Transparent Data Encryption',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_TDE_STR,
      'Transparent Database Encryption is being used. There is' || 
      ' atleast one column or tablespace that is encrypted.');
  end;

  /******************* 
   * Data Redaction
   *******************/
  
  /* Bug# 13888340: Data redaction feature usage tracking
   * Related test files are tmfudru.tsc and tmfudr.tsc.
   */
  begin
    dbms_feature_usage.register_db_feature
     ('Data Redaction',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_DATA_REDACTION',
      'Data Redaction is being used. There is' || 
      ' at least one defined policy.');
  end;

  /********************** 
   * Oracle Multimedia
   **********************/

  declare 
    DBFUS_MULTIMEDIA_STR CONSTANT VARCHAR2(1000) := 
      'ordsys.CARTRIDGE.dbms_feature_multimedia';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Multimedia',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'ORDSYS.ORDIMERRORCODES',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_MULTIMEDIA_STR,
      'Oracle Multimedia has been used');
  end;

  /*****************************************************************
   * Oracle Multimedia DICOM: medical imaging 
   * DICOM stands for Digital Imaging and COmmunications in Medicine
   *****************************************************************/

  declare 
    DBFUS_DICOM_STR CONSTANT VARCHAR2(1000) := 
      'ordsys.CARTRIDGE.dbms_feature_dicom';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Multimedia DICOM',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'ORDSYS.ORDDICOM',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_DICOM_STR,
      'Oracle Multimedia DICOM (Digital Imaging and COmmunications in Medicine) has been used');
  end;

  /****************************
   * Materialized Views (User)
   ****************************/

  declare
    DBFUS_USER_MVS CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_USER_MVS';

  begin
    dbms_feature_usage.register_db_feature
     ('Materialized Views (User)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_USER_MVS,
      'User Materialized Views exist in the database');
  end;

  /***************************
   * Change Data Capture (CDC) 
   ***************************/
  begin
    dbms_feature_usage.register_db_feature
        ('Change Data Capture',
          dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
          NULL,
          dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
          'DBMS_FEATURE_CDC',
           'Change Data Capture exit in the database');
  end;

  /********************************
   * Services
   *********************************/
  declare
    DBFUS_SERVICES_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_SERVICES';
  begin
    dbms_feature_usage.register_db_feature
     ('Services',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_SERVICES_PROC,
      'Oracle Services.');
  end;

  /***********************
   * Semantics/RDF/OWL
   ***********************/

   declare
     DBFUS_SEMANTICS_RDF_STR CONSTANT VARCHAR2(1000) := 
        'select cnt, cnt, null from ' ||
        ' (select count(*) cnt from mdsys.rdf_model$)';

   begin
     dbms_feature_usage.register_db_feature
       ('Semantics/RDF', 
         dbms_feature_usage.DBU_INST_OBJECT, 
         'MDSYS.RDF_Models',
         dbms_feature_usage.DBU_DETECT_BY_SQL,
         DBFUS_SEMANTICS_RDF_STR,
         'A semantic network has been created indicating usage of the ' ||
         'Oracle Semantics Feature.');
    end;
    
  /***********************
   * SecureFiles (user)
   ***********************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFiles (user)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SECUREFILES_USR',
       'SecureFiles is being used');
  end;

  /***********************
   * SecureFiles (system)
   ***********************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFiles (system)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SECUREFILES_SYS',
       'SecureFiles is being used by system users');
  end;

  /*********************************
   * SecureFile Encryption (user)
   *********************************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFile Encryption (user)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SFENCRYPT_USR',
       'SecureFile Encryption is being used');
  end;

  /*********************************
   * SecureFile Encryption (system)
   *********************************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFile Encryption (system)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SFENCRYPT_SYS',
       'SecureFile Encryption is being used by system users');
  end;

  /*********************************
   * SecureFile Compression (user)
   *********************************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFile Compression (user)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SFCOMPRESS_USR',
       'SecureFile Compression is being used');
  end;

  /*********************************
   * SecureFile Compression (system)
   *********************************/

  begin
   dbms_feature_usage.register_db_feature
      ('SecureFile Compression (system)',
        dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
        NULL,
        dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_SFCOMPRESS_SYS',
       'SecureFile Compression is being used by system users');
  end;

  /*********************************
   * SecureFile Deduplication (user)
   *********************************/

  begin
    dbms_feature_usage.register_db_feature
     ('SecureFile Deduplication (user)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_SFDEDUP_USR',
      'SecureFile Deduplication is being used');
  end;

  /*********************************
   * SecureFile Deduplication (system)
   *********************************/

  begin
    dbms_feature_usage.register_db_feature
     ('SecureFile Deduplication (system)',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_SFDEDUP_SYS',
      'SecureFile Deduplication is being used by system users');
  end;

  /******************************
   * Segment Advisor
   ******************************/

  declare 
    DBFUS_SEGADV_USER_PROC CONSTANT VARCHAR2(100) := 'DBMS_FEATURE_SEGADV_USER';
  begin
    dbms_feature_usage.register_db_feature
     ('Segment Advisor (user)',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED, 
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_SEGADV_USER_PROC,
      'Segment Advisor has been used. There is at least one user task executed.');
  end;
  
  /***********************
   * Compression
   ***********************/

  declare
   DBFUS_COMPRESSION_STR CONSTANT VARCHAR2(1000) :=
         'select value, 0, NULL' ||
            ' from v$sysstat' ||
            ' where name like ''HSC OLTP positive compression''';

  begin
   dbms_feature_usage.register_db_feature
      ('HeapCompression',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_SQL,
       DBFUS_COMPRESSION_STR,
       'Heap Compression is being used');
  end;


 /******************************
   * Hybrid Columnar Compression
   *****************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Hybrid Columnar Compression',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_HCC',
      'Hybrid Columnar Compression is used');
  end;

  /******************************
    * ZFS Storage
    ******************************/
  begin
    dbms_feature_usage.register_db_feature
      ('ZFS Storage',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_ZFS_STORAGE',
       'Tablespaces stored on Oracles Sun ZFS Storage');
  end;

  /******************************
    * Pillar Storage
    ******************************/
  begin
    dbms_feature_usage.register_db_feature
      ('Pillar Storage',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_PILLAR_STORAGE',
       'Tablespaces stored on Oracles Pillar Axiom Storage');
  end;

  /******************************
    * ZFS Storage + EHCC
    *****************************/
  begin
    dbms_feature_usage.register_db_feature
      ('Sun ZFS with EHCC',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_ZFS_EHCC',
       'EHCC used on tablespaces stored on Oracles Sun ZFS Storage');
  end;

  /******************************
    * Pillar Storage + EHCC
    *****************************/
  begin
    dbms_feature_usage.register_db_feature
      ('Pillar Storage with EHCC',
       dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
       NULL,
       dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
       'DBMS_FEATURE_PILLAR_EHCC',
       'EHCC used on tablespaces stored on Oracles Pillar Axiom Storage');
  end;

  /******************************
   * Segment Shrink
   ******************************/

  declare 
    DBFUS_SEG_SHRINK_STR CONSTANT VARCHAR2(1000) :=
      'select  count(*), 0, null ' ||
        'from  sys.seg$ s ' ||
        'where s.scanhint != 0 and ' ||
              'bitand(s.spare1, 65793) = 257 and ' ||
              's.type# in (5, 6,8) ';
  begin
    dbms_feature_usage.register_db_feature
     ('Segment Shrink',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      DBFUS_SEG_SHRINK_STR,
      'Segment Shrink has been used.');
  end;

  /***************************
   * Job Scheduler 
   ***************************/

  begin
    dbms_feature_usage.register_db_feature
     ('Job Scheduler',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_JOB_SCHEDULER',
      'Job Scheduler feature is being used.');
  end;

  /*******************************
   * Java Virtual Machine (user)
   *******************************/

  declare 
    DBFUS_OJVM_STR CONSTANT VARCHAR2(1000) := 
      'sys.dbms_java.dbms_feature_ojvm';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Java Virtual Machine (user)',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'SYS.JAVA$POLICY$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_OJVM_STR,
      'OJVM has been used by at least one non-system user');
  end;

  /*********************************
   * Java Virtual Machine (system)
   *********************************/

  declare 
    DBFUS_OJVM_SYS_STR CONSTANT VARCHAR2(1000) := 
      'sys.dbms_java.dbms_feature_system_ojvm';

  begin
    dbms_feature_usage.register_db_feature
     ('Oracle Java Virtual Machine (system)',
      dbms_feature_usage.DBU_INST_OBJECT, 
      'SYS.JAVA$POLICY$',
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_OJVM_SYS_STR,
      'OJVM default system users');
  end;



  /******************************
   * EXADATA
   ******************************/

  declare 
    DBFUS_EXADATA_PROC CONSTANT VARCHAR2(1000) := 'DBMS_FEATURE_EXADATA';

  begin
    dbms_feature_usage.register_db_feature
     ('Exadata',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      DBFUS_EXADATA_PROC,
      'Exadata is being used');
  end;

  /*********************************************
   * TEST features to test the infrastructure 
   *********************************************/

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_1',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 1, 0, NULL from dual',
      'Test sql 1');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_2',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 0, 10, to_clob(''hi, mike'') from dual',
      'Test sql 2');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_3',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 13, NULL, to_clob(''hello, mike'') from dual',
      'Test sql 3');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_4',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.tab$',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 11, 11, to_clob(''test sql 4 check tab$'') from dual',
      'Test sql 4');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_5',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.foo',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 2, 0, to_clob(''check foo'') from dual',
      'Test sql 5');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_6',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.tab$',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select 0, 0, to_clob(''should not see'') from dual',
      'Test sql 6');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_7',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_NULL,
      'junk',
      'Test sql 7');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_8',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select junk from foo',
      'Test sql 8 - Test error case');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_9',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'test.test',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select junk from foo',
      'Test sql 9 - Test error case for install');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_SQL_10',
      dbms_feature_usage.DBU_INST_OBJECT + 
      dbms_feature_usage.DBU_INST_TEST,
      'sys.dbu_test_table',
      dbms_feature_usage.DBU_DETECT_BY_SQL,
      'select count(*), count(*), max(letter) from dbu_test_table',
      'Test sql 10 - Test infrastructure');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_1',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_1',
      'Test feature 1');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_2',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_2',
      'Test feature 2');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_3',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'Junk Procedure',
      'Test feature 3 - Bad procedure name');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_4',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_4',
      'Test feature 4');

  dbms_feature_usage.register_db_feature
     ('_DBFUS_TEST_PROC_5',
      dbms_feature_usage.DBU_INST_ALWAYS_INSTALLED + 
      dbms_feature_usage.DBU_INST_TEST,
      NULL,
      dbms_feature_usage.DBU_DETECT_BY_PROCEDURE,
      'DBMS_FEATURE_TEST_PROC_5',
      'Test feature 5');

end;
/
show errors; 

Rem ************************************
Rem     High Water Mark Registration
Rem ************************************

create or replace procedure DBMS_FEATURE_REGISTER_ALLHWM
as
begin

  /**************************
   * User Tables
   **************************/

  declare 
    HWM_USER_TABLES_STR CONSTANT VARCHAR2(1000) := 
     'select count(*) from sys.tab$ t, sys.obj$ o ' ||
       'where t.obj# = o.obj# ' ||
         'and bitand(t.property, 1) = 0 ' ||
         'and bitand(o.flags, 128) = 0 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                                'where u.name in (''SYS'', ''SYSTEM''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('USER_TABLES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_USER_TABLES_STR,
      'Number of User Tables');
  end;

  /**************************
   * Segment Size 
   **************************/

  declare 
    HWM_SEG_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select max(bytes) from dba_segments';

  begin
    dbms_feature_usage.register_high_water_mark
     ('SEGMENT_SIZE',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_SEG_SIZE_STR,
      'Size of Largest Segment (Bytes)');
  end;

  /**************************
   * Partition Tables
   **************************/

  declare 
    HWM_PART_TABLES_STR CONSTANT VARCHAR2(1000) := 
     'select nvl(max(p.partcnt), 0) from sys.partobj$ p, sys.obj$ o ' ||
       'where p.obj# = o.obj# ' ||
         'and o.type# = 2 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                               'where u.name in (''SYS'', ''SYSTEM'', ''SH''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('PART_TABLES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_PART_TABLES_STR,
      'Maximum Number of Partitions belonging to an User Table');
  end;

  /**************************
   * Partition Indexes
   **************************/

  declare 
    HWM_PART_INDEXES_STR CONSTANT VARCHAR2(1000) := 
     'select nvl(max(p.partcnt), 0) from sys.partobj$ p, sys.obj$ o ' ||
       'where p.obj# = o.obj# ' ||
         'and o.type# = 1 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                               'where u.name in (''SYS'', ''SYSTEM'', ''SH''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('PART_INDEXES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_PART_INDEXES_STR,
      'Maximum Number of Partitions belonging to an User Index');
  end;

  /**************************
   * User Indexes
   **************************/

  declare 
    HWM_USER_INDEX_STR CONSTANT VARCHAR2(1000) := 
     'select count(*) from sys.ind$ i, sys.obj$ o ' ||
       'where i.obj# = o.obj# ' ||
         'and bitand(i.flags, 4096) = 0 ' ||
         'and o.owner# not in (select u.user# from user$ u ' ||
                                'where u.name in (''SYS'', ''SYSTEM''))';

  begin
    dbms_feature_usage.register_high_water_mark
     ('USER_INDEXES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_USER_INDEX_STR,
      'Number of User Indexes');
  end;

  /**************************
   * Sessions
   **************************/

  declare 
    HWM_SESSIONS_STR CONSTANT VARCHAR2(1000) := 
      'select sessions_highwater from V$LICENSE';

  begin
    dbms_feature_usage.register_high_water_mark
     ('SESSIONS',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_SESSIONS_STR,
      'Maximum Number of Concurrent Sessions seen in the database');
  end;

  /**************************
   * DB Size
   **************************/

  declare 
    HWM_DB_SIZE_STR CONSTANT VARCHAR2(1000) := 
      'select sum(bytes) from dba_data_files';

  begin
    dbms_feature_usage.register_high_water_mark
     ('DB_SIZE',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_DB_SIZE_STR,
      'Maximum Size of the Database (Bytes)');
  end;

  /**************************
   * Datafiles
   **************************/

  declare 
    HWM_DATAFILES_STR CONSTANT VARCHAR2(1000) := 
      'select count(*) from dba_data_files';

  begin
    dbms_feature_usage.register_high_water_mark
     ('DATAFILES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_DATAFILES_STR,
      'Maximum Number of Datafiles');
  end;

  /**************************
   * Tablespaces
   **************************/

  declare 
    HWM_TABLESPACES_STR CONSTANT VARCHAR2(1000) := 
     'select count(*) from sys.ts$ ts ' ||
       'where ts.online$ != 3 ' ||
         'and bitand(ts.flags, 2048) != 2048';

  begin
    dbms_feature_usage.register_high_water_mark
     ('TABLESPACES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_TABLESPACES_STR,
      'Maximum Number of Tablespaces');
  end;

  /**************************
   * CPU count
   **************************/

  declare 
    HWM_CPU_COUNT_STR CONSTANT VARCHAR2(1000) := 
      'select sum(cpu_count_highwater) from gv$license';

  begin
    dbms_feature_usage.register_high_water_mark
     ('CPU_COUNT',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_CPU_COUNT_STR,
      'Maximum Number of CPUs');
  end;

  /**************************
   * Query Length
   **************************/

  declare 
    HWM_QUERY_LENGTH_STR CONSTANT VARCHAR2(1000) := 
      'select max(maxquerylen) from v$undostat';

  begin
    dbms_feature_usage.register_high_water_mark
     ('QUERY_LENGTH',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_QUERY_LENGTH_STR,
      'Maximum Query Length');
  end;

  /****************************** 
   * National Character Set Usage
   *******************************/

  declare 
    HWM_NCHAR_COLUMNS_STR CONSTANT VARCHAR2(1000) := 
      'select count(*) from col$ c, obj$ o ' ||
      ' where c.charsetform = 2 and c.obj# = o.obj# ' ||
      ' and o.owner# not in ' || 
      ' (select distinct u.user_id from all_users u, ' ||
      ' sys.ku_noexp_view k where (k.OBJ_TYPE=''USER'' and ' ||
      ' k.name=u.username) or (u.username=''SYSTEM'')) ' ;

  begin
    dbms_feature_usage.register_high_water_mark
     ('SQL_NCHAR_COLUMNS',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_NCHAR_COLUMNS_STR,
      'Maximum Number of SQL NCHAR Columns');
  end;
  
  /********************************
   * Instances
   *********************************/
  declare
    HWM_INSTANCES_STR CONSTANT VARCHAR2(1000) := 
      'SELECT count(*) FROM gv$instance';
  begin
    dbms_feature_usage.register_high_water_mark
     ('INSTANCES',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_INSTANCES_STR,
      'Oracle Database instances');
  end;

  /****************************
   * Materialized Views (User)
   ****************************/

  declare
    HWM_USER_MV_STR CONSTANT VARCHAR2(1000) :=
     'select count(*) from dba_mviews ' ||
       'where owner not in (''SYS'',''SYSTEM'', ''SH'')';

  begin
    dbms_feature_usage.register_high_water_mark
     ('USER_MV',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_USER_MV_STR,
      'Maximum Number of Materialized Views (User)');
  end;


  /*******************
   * Active Sessions
   *******************/

  declare
    HWM_ACTIVE_SESSIONS_STR CONSTANT VARCHAR2(1000) :=
     'select max(value) from v$sysmetric_history ' ||
       'where metric_name = ''Average Active Sessions''';

  begin
    dbms_feature_usage.register_high_water_mark
     ('ACTIVE_SESSIONS',
      dbms_feature_usage.DBU_HWM_BY_SQL,
      HWM_ACTIVE_SESSIONS_STR,
      'Maximum Number of Active Sessions seen in the system');
  end;

  /*******************
   * DBMS_SCHEDULER   HWM is number of jobs per day
   *******************/

   declare 
     HWM_DBMS_SCHEDULER_STR CONSTANT VARCHAR2(1000) := 
   'select max(rpd) from ('  ||
      'select trunc(log_date),' ||
          ' sum(gap-decode(operation, ''RUN'', 0, 1)) rpd '  ||
          ' from (' ||
            'select operation, log_date,log_id-lag(log_id, 1) '||
                                         'over (order by log_id) gap ' ||
              'from scheduler$_event_log) ' ||
                'where log_date > systimestamp - interval ''8'' day ' ||
                'group by trunc(log_date))';
   begin
     dbms_feature_usage.register_high_water_mark
      ('HWM_DBMS_SCHEDULER',
       dbms_feature_usage.DBU_HWM_BY_SQL,
       HWM_DBMS_SCHEDULER_STR,
       'number of job runs per day');
   end;

  /*******************
   * Exadata
   *******************/

   declare 
     HWM_EXADATA_STR CONSTANT VARCHAR2(1000) := 
	'select replace(substr(statistics_value, 23), ''</nphysicaldisks_stats>'') from gv$cell_state where statistics_type = ''NPHYSDISKS''';
   begin
     dbms_feature_usage.register_high_water_mark
      ('EXADATA_DISKS',
       dbms_feature_usage.DBU_HWM_BY_SQL,
       HWM_EXADATA_STR,
       'Number of physical disks');
   end;

  /**************************
   * Test HWM
   **************************/

  declare 
    HWM_TEST_PROC CONSTANT VARCHAR2(1000) := 
      'DBMS_FEATURE_TEST_PROC_3';

  begin
    dbms_feature_usage.register_high_water_mark
     ('_HWM_TEST_1',
      dbms_feature_usage.DBU_HWM_BY_PROCEDURE +
      dbms_feature_usage.DBU_HWM_TEST,
      HWM_TEST_PROC,
      'Test HWM 1');
  end;

  dbms_feature_usage.register_high_water_mark
     ('_HWM_TEST_2',
      dbms_feature_usage.DBU_HWM_NULL +
      dbms_feature_usage.DBU_HWM_TEST,
      'Junk',
      'Test HWM 2');
  
  dbms_feature_usage.register_high_water_mark
     ('_HWM_TEST_3',
      dbms_feature_usage.DBU_HWM_BY_SQL +
      dbms_feature_usage.DBU_HWM_TEST,
      'select 10 from dual',
      'Test HWM 3');

  dbms_feature_usage.register_high_water_mark  
     ('_HWM_TEST_4',
      dbms_feature_usage.DBU_HWM_BY_SQL +
      dbms_feature_usage.DBU_HWM_TEST,
      'select 1240 from foo',
      'Test HWM 4 - Error case');

end;
/
show errors; 
