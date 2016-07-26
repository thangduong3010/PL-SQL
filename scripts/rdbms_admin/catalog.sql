Rem
Rem $Header: catalog.sql 07-mar-2008.13:28:05 huagli Exp $ catalog.sql
Rem
Rem Copyright (c) 1988, 2007, Oracle. All rights reserved.  
Rem
Rem NAME
Rem   CATALOG.SQL
Rem FUNCTION
Rem   Creates data dictionary views.
Rem NOTES
Rem   Must be run when connected AS SYSDBA
Rem
Rem MODIFIED
Rem     huagli     01/07/08  - add cddst.sql
Rem     cdilling   01/18/07  - remove reference to cdfmap.sql
Rem     schakkap   09/20/06  - cdoptim.sql depends on *partv views created in
Rem                            cdpart.sql, run it as single process.
Rem     cdilling   08/03/06  - add catexp.sql, catldr.sql, catsum.sql
Rem     rburns     05/18/06  - add multiprocessing notations 
Rem     cdilling   05/04/06  - move definitions into separate files 
Rem     mgirkar    04/26/06  - Add redo_dest_resp_histogram view 
Rem     jforsyth   03/07/06  - shifting encryption, compression, and sharing 
Rem                            flags 
Rem     jforsyth   03/06/06  - add ENCRYPT, COMPRESS, SHARE columns to LOB 
Rem                            views 
Rem     rdongmin   04/12/06  - add fixed view for hint definition 
Rem     spsundar   05/01/06  - change DOMIDX_MANAGEMENT bit 
Rem     dmukhin    04/25/06  - ADP: embedded xforms 
Rem     dmukhin    03/28/06  - ADP: add xform table type 
Rem     rdecker    03/28/06  - add assembly
Rem     jgalanes   03/14/06  - Syns for LogMiner views (IDR) 
Rem     mbaloglu   03/06/06  - Add SYNC column for LOB views, enable CACHE 
Rem                            NOLOGGING 
Rem     spsundar   02/22/06  - add DOMIDX_MANAGEMENT to *_indexes
Rem     shsong     04/20/06  - Bug 5014810: remove useless V$temp_histogram 
Rem     tbingol    11/22/05  - Result_Cache: Add synonyms for V$ fixed views 
Rem     rdongmin   03/15/06  - add fixed views for feature control 
Rem     msusaira   03/03/06  - add vSiostat_network 
Rem     ssubrama   02/21/06  - lrg 2069988 fix dba_indexes 
Rem     svshah     02/22/06  - Fix gv,v$sqlstats declarations 
Rem     ssubrama   02/07/06  - bug 4969399 change dba_indexes 
Rem     ramekuma   12/10/05  - Add invisible flag to index flags 
Rem     mtakahar   10/28/05  - #(4704779) fix wrong histogram type
Rem     aramarao   12/13/05  - all_tables, all_tab_columns and 
Rem                            all_tab_comments are notconsistent handling the 
Rem                            objects in recyclebin 
Rem     svivian    10/11/05  - add public synonyms for 
Rem                            v/gv$fs_failover_histogram 
Rem     jmuller    07/27/05  - Fix bug 4118196: Add DEFAULTED parameter to 
Rem                            *_ARGUMENTS 
Rem     tyurek     08/02/05  - define public synonyms for 
Rem                            v$/gv$dynamic_remastering_stats 
Rem     lvbcheng   07/19/05  - Add triggers and package initialization to 
Rem                            PROCEDURE views 
Rem     lvbcheng   07/14/05  - Columns for ASH 
Rem     adagarwa   05/06/05  - added DBA_ARGUMENTS view
Rem     nireland   06/26/05  - Additional LOB changes. #4060216 
Rem     gmulagun   06/23/05  - bug 4035677 add v$object_privilege
Rem     ansingh    05/04/05  - 3217740: remove rule hint in all_col_comments 
Rem     svshah     05/11/05  - Add gv$,v$mutex_sleep(_history) 
Rem     rdongmin   04/11/05  - add fixed views for bug-fix-control
Rem     mmcracke   03/15/05  - Add data mining model views 
Rem     mtakahar   01/18/05  - #(3536027) fix wrong histogram type shown
Rem     sourghos   01/05/05  - Fix bug 4043119 
Rem     kumamage   12/12/04  - add gv$parameter_valid_values 
Rem     smuthuli   12/02/04  - move space quotas to catspace.sql
Rem     nireland   11/09/04  - Fix display of pctversion/retention. #3844939 
Rem     wyang      11/01/04  - bug 3981575 
Rem     rvissapr   10/26/04  - remove linksencoding views 
Rem     araghava   10/25/04 - 3448802: don't use partobj$ to get blocksize in 
Rem                           *_LOBS 
Rem     sourghos   10/20/04  - Add comments for clb_goal 
Rem     sourghos   10/19/04  - Adding comments for CLB_GOAL 
Rem     sourghos   10/14/04  - clb_goal has been added 
Rem     sourghos   10/13/04  - Fix bug 3936900 by adding clb_goal in 
Rem                            catalog.sql 
Rem     pthornto   10/07/04  - 
Rem     rburns     09/13/04  - check for SYS user 
Rem     pthornto   10/05/04  - add view DBA_CONNECT_ROLE_GRANTEES 
Rem     jmzhang    08/26/04  - change v$phystdby_status to v$dataguard_stats
Rem                          - add gv/v$standby_threadinfo
Rem     clei       09/10/04  - fix *_encrypted_columns
Rem     mtakahar   06/07/04  - mon_mods$ -> mon_mods_all$
Rem     jmzhang    08/17/04  - add v$phystdby_status
Rem     jmzhang    07/25/04  - add gv$rfs_thread
Rem     mhho       07/20/04  - add wallet views
Rem     clei       06/29/04  - add dictionary views for encrypted columns
Rem     bsinha     06/17/04  - restore_point privilege changes 
Rem     svshah     06/28/04  - Public synonyms for v$, gv$ sqlstats
Rem     bhabeck    06/14/04  - add v$process_memory_detail synonyms 
Rem     suelee     05/29/04  - Add v$rsrc_plan_history 
Rem     kumamage   06/03/04  - add interconnect views 
Rem     bdagevil   06/19/04  - add [g]v$sqlstats and [g]v$sqlarea_plan_hash 
Rem     sridsubr   06/04/04  - Add new RM Stat views 
Rem     gmulagun   05/30/04  - add v$xml_audit_trail 
Rem     jnarasin   05/26/04  - Alter User changes for EUS Proxy project 
Rem     kpatel     05/18/04  - add v$asm_diskgroup_stat and v$asm_disk_stat
Rem     bhabeck    05/13/04  - add public synonyms for g/v$process_memory 
Rem     rvissapr   05/19/04  - mark password column deprecated 
Rem     narora     05/19/04  - add v$streams_pool_advice 
Rem     nikeda     04/12/04  - [OCI Events] Add Notifications enable/disable 
Rem     tcruanes   05/27/04  - add SQL_JOIN_FILTER fixed view synonyms 
Rem     rramkiss   05/13/04  - Update objects views for scheduler chains
Rem     jciminsk   04/28/04  - merge from RDBMS_MAIN_SOLARIS_040426 
Rem     jciminsk   04/07/04  - merge from RDBMS_MAIN_SOLARIS_040405 
Rem     ckantarj   02/27/04  - add cardinality columns to service$ 
Rem     jciminsk   02/06/04  - merge from RDBMS_MAIN_SOLARIS_040203 
Rem     jciminsk   12/12/03  - merge from RDBMS_MAIN_SOLARIS_031209 
Rem     jciminsk   08/19/03  - branch merge 
Rem     ckantarj   07/16/03  - add TAF column comments for service$
Rem     bbhowmic   01/20/04  - #3370034: USER_NESTED_TABLES DBA_NESTED_TABLES 
Rem     pokumar    05/11/04  - add v$sga_target_advice view 
Rem     dsemler    05/03/04  - fix dba_services view decode 
Rem     dsemler    04/13/04  - update views on service$ to add goal 
Rem     wyang      04/27/04  - transportable db 
Rem     molagapp   05/22/04  - add v$flash_recovery_area_usage
Rem     ahwang     05/07/04  - add restore point synonyms 
Rem     mxyang     05/10/04  - add plsql_ccflags
Rem     alakshmi   04/19/04  - system privilege READ_ANY_FILE_GROUP 
Rem     alakshmi   04/14/04  - File Groups 
Rem     smangala   04/16/04  - add logmnr_dictionary_load view 
Rem     vshukla    05/06/04  - add STATUS field to *_TABLES views 
Rem     vmarwah    04/08/04  - Bug 3255906: Do not show RB objects in *_TABLES
Rem     mjaeger    02/26/04  - bug 3369744: all_synonyms: include syns for syns
Rem     nlee       02/24/04  - Fix for bug 3431384.
Rem     bbhowmic   01/20/04  - #3370034: USER_NESTED_TABLES DBA_NESTED_TABLES
Rem     mtakahar   12/18/03  - fix NUM_BUCKETS/HISTOGRAM columns
Rem     najain     12/08/03  - change all_objects: use xml_schema_name_present
Rem     weili      11/18/03  - use RBO for ALL_TAB_COLUMNS & ALL_COL_COMMENTS
Rem     qyu        11/12/03  - add v$timezone_file
Rem     arithikr   11/02/03  - 3121812 - add drop_segments column to mon_mods$
Rem     hqian      10/27/03  - OSM -> ASM
Rem     vraja      10/20/03  - bug3161569: rename DBA_TRANSACTION_QUERY to
Rem                            FLASHBACK_TRANSACTION_QUERY
Rem     rvenkate   10/14/03  - remove buffered from propagation views
Rem     nireland   10/01/03  - Remove dba_procedures grant. #3157539
Rem     agardner   09/10/03  - bug#2658177: ind_columns to report user
Rem                            attribute name rather than sys generated name
Rem     rburns     09/09/03  - cleanup
Rem     qyu        08/27/03  - tab_cols: qualified_col_names, add nested_table_cols
Rem     mlfeng     08/06/03  - change v$svcmetric to v$servicemetric
Rem     kmeiyyap   08/22/03  - buffered propagation views
Rem     skaluska   08/25/03  - fix merge problems
Rem     sdizdar    08/22/03  - remove GV_$RMAN_STATUS_CURRENT
Rem     jawilson   08/08/03  - Remove streams_pool_advice view
Rem     nmacnaug   08/13/03  - add instance cache transfer table
Rem     ckantarj   07/16/03  - add TAF column comments for service$
Rem     ajadams    08/13/03  - add logmnr_latch
Rem     alakshmi   07/17/03  - List types for streams apply/capture objects
Rem     dsemler    07/03/03  - add public synonyms for v$services and gv$services
Rem     vmarwah    06/30/03  - Fix TABLE views for including Dropped Col
Rem     kigoyal    07/16/03  - add v$service_event and v$service_wait_class
Rem     vraja      06/18/03  - decode(commit_scn) in dba_transaction_query
Rem     smuthuli   06/18/03  - add PARTITIONED col to *_LOBS views
Rem     koi        06/17/03  - 2994527: change *_TABLES for IOT LOGGING
Rem     dsemler    06/06/03  - Fix bug where dba/all_services report deleted services
Rem     molagapp   03/28/03  - add type privilege to recovery_catalog_owner
Rem     rpang      05/15/03  - add *_plsql_object_settings views
Rem     njalali    05/12/03  - changing ALL_OBJECTS to use ALL_XML_SCHEMAS2
Rem     bdagevil   05/08/03  - grant select on v$advisor_progress to public
Rem     bdagevil   04/28/03  - merge new file
Rem     skaluska   04/16/03  - add v$tsm_sessions
Rem     raguzman   03/10/03  - move catlsby from catalog to catproc
Rem     abagrawa   03/12/03  - Fix all_objects for XML schemas
Rem     kquinn     03/07/03  - 2644204: speed up index_stats
Rem     jawilson   02/03/03  - add public synonyms for V$BUFFERED_QUEUES
Rem     vraja      02/12/03  - grant select to public on DBA_TRANSACTION_QUERY
Rem     tfyu       02/14/03  - Bug 2803767
Rem     ruchen     01/29/03  - add public synonym for px_buffer_advice
Rem     kigoyal    01/29/03  - adding v$temp_histogram
Rem     evoss      01/06/03  - scheduler fixed views
Rem     rramkiss   01/13/03  - add job scheduler object types
Rem     bdagevil   03/16/03  - add [g]v$advisor_progress dynamic view
Rem     dsemler    02/18/03  - fix the all_services synonym
Rem     lilin      12/19/02  - add fixed table instance_log_group
Rem     gngai      01/15/03  - added synonyms for V$ metric views
Rem     smuthuli   01/18/03  - add tablespace_name to *_lobs views
Rem     wyang      12/19/02  - user_resumable use user#
Rem     dsemler    12/06/02  - create dba, all views for services
Rem     asundqui   12/04/02  - add (g)v$osstat
Rem     schakkap   12/17/02  - fixed table stats
Rem     asundqui   12/04/02  - add (g)v$osstat
Rem     srseshad   12/03/02  - dty code change for binary float/double
Rem     rburns     11/30/02  - postpone validation
Rem     nmacnaug   11/14/02  - add current_block_server view
Rem     gtarora    11/25/02  - xxx_LOBS: new column
Rem     jwlee      11/07/02  - add v$flashback_database_stat
Rem     gngai      12/31/02  - added synonyms for Metric views
Rem     msheehab   10/29/02  - Add V$AW_LONGOPS for olap
Rem     vraja      10/28/02  - add DBA_TRANSACTION_QUERY
Rem     aramarao   10/26/02  - 2643490 change all_objects definition to
Rem                            include clusters
Rem     mtakahar   10/31/02  - reverted the x$ksppcv change due to #(2652698)
Rem     yhu        10/29/02  - handle native data type in _INDEXTYPE_ARRAYTYPES
Rem     wwchan     10/11/02  - add v$active_services
Rem     kpatel     10/15/02  - add fixed view for sga info
Rem     veeve      10/11/02  - added synonym for [g]v$active_session_history
Rem     sdizdar    10/10/02  - add V$RMAN_STATUS and V$RMAN_OUTPUT
Rem     molagapp   09/27/02  - Add v$_recovery_file_dest table
Rem     mtakahar   10/15/02  - put x$ksppi and x$ksppcv in the select list
Rem     weiwang    10/01/02  - add v$rule
Rem     vmarwah    10/04/02  - Undrop Tables: add BASE_OBJ to RecycleBin views
Rem     cluu       10/06/02  - rm v$mts
Rem     swerthei   08/15/02  - block change tracking
Rem     gkulkarn   09/30/02  - 10.1 extensions to LOG_GROUPS view
Rem     asundqui   09/24/02  - add v$enqueue_statistics, v$lock_type
Rem     btao       09/30/02  - add managability advisor script
Rem     mtakahar   09/24/02  - #(2585900): switch order of x$ksppi and x$ksppcv
Rem     apareek    09/20/02  - create synonym for cross transportable views
Rem     mtakahar   09/19/02  - show monitoring=NO for external tables
Rem     kigoyal    10/01/02  - v$session_wait_class, v$system_wait_class
Rem     mtakahar   09/24/02  - #(2563435): fix *_tab_modifications
Rem     vmarwah    09/04/02  - Undrop Tables: modify RecycleBin$ views.
Rem     mtakahar   08/26/02  - tie monitoring to _dml_monitoring_enabled
Rem     yhu        09/11/02  - indextype for array insert
Rem     kigoyal    09/13/02  - adding V$SESSION_WAIT_HISTORY
Rem     cluu       08/21/02  - add v$dispatcher_config, remove v$mts
Rem     asundqui   07/31/02  - consumer group mapping
Rem     mtakahar   08/06/02  - #(2352663) fix num_buckets, add histogram col
Rem     mdcallag   08/20/02  - support binary_float and binary_double
Rem     gssmith    08/21/02  - Adding new Manageability Advisor script
Rem     hbaer      08/08/02  - bug 2474106: added compression to *_TABLES
Rem     mjstewar   09/01/02  - Add flashback views
Rem     vmarwah    07/19/02  - Undrop Tables: Remove DROPPED_BY from RecycleBin
Rem     tchorma    07/23/02  - Support WITH COLUMN CONTEXT clause for operators
Rem     mlfeng     07/17/02  - public synonym for (g)v$sysaux_occupant
Rem     abrumm     07/11/02  - Bug #2427319: external tables have no tablespace
Rem     cchiappa   07/16/02  - Add V$AW_{AGGREGATE,ALLOCATE}_OP
Rem     gssmith    08/06/02  - Adding Advisor components
Rem     aime       06/27/02 -  remove v_$backup_files and v_$obsolete_backup_fi
Rem     pbagal     06/26/02  - Add v$osm_operation
Rem     sdizdar    02/14/02  - add V$OBSOLETE_BACKUP_FILES and V$BACKUP_FILES
Rem     xuhuali    07/02/02  - add v$javapool
Rem     mxiao      06/17/02  - donot show comments for MV in *_TAB_COMMENTS
Rem     dcwang     06/11/02  - modify rules privilege
Rem     qyu        05/29/02  - fix ts in xxx_LOBS
Rem     smcgee     06/10/02  - Add V$DATAGUARD_CONFIG fixed view.
Rem     kigoyal    08/05/02  - adding v$event_histogram and v$file_histogram
Rem     bdagevil   07/28/02  - add views exposing compile environment
Rem     tkeefe     05/23/02  - Add support for new credential type in PROXY
Rem                            views
Rem     rburns     05/06/02  - remove v$mls_parameters
Rem     nireland   04/29/02  - Fix user_sys_privs. #2321697
Rem     pbagal     04/18/02  - Add synonyms for OSM_VIEWS.
Rem     rburns     04/01/02  - use default registry banner
Rem     echong     04/10/02  - redundant pkey elim. for iot sec. idx
Rem     vmarwah    03/14/02  - Undrop Tables: Creating views over RecycleBin$.
Rem     yuli       04/22/02  - 10.1 irreversible compatibility
Rem     skaluska   04/04/02  - add v$rule_set.
Rem     rburns     02/11/02  - add registry version
Rem     kpatel     01/12/02  - add dynamic sga stats
Rem     emagrath   01/09/02  - Elim. endian REF problem
Rem     weiwang    01/04/02  - change definition of all_objects for rules
Rem                            engine objects
Rem     qcao       01/07/02  - fix bug 2168748
Rem     rburns     10/26/01  - add registry validation
Rem     cfreiwal   11/14/01  - move logstby views to catlsby.sql
Rem     sbalaram   11/02/01  - Remove catstr.sql
Rem     apadmana   10/26/01  - catlrep.sql to catstr.sql
Rem     sichandr   11/05/01  - _OBJECTS : handle XMLSchemas
Rem     weiwang    08/07/01  - add evaluation context
Rem     weiwang    07/17/01  - add rule and ruleset to object views
Rem     narora     06/28/01  - add catlrep
Rem     smangala   05/21/01  - add logmnr_stats.
Rem     qiwang     04/29/01  - add catlsby.sql
Rem     molagapp   06/01/01  - add v$database_incarnation changes
Rem     cmlim      10/31/01  - update object_id_type in ref views for unscoped
Rem                            pkrefs
Rem     ayoaz      10/16/01  - change decode-0 to nvl2 for coltype$.synobj#
Rem     somichi    10/19/01  - #(2050584) eliminate unprepared txn
Rem     bdagevil   10/18/01  - fix error on merge
Rem     qcao       10/18/01  - add tablespace_name to dba_object_stats
Rem     esoyleme   10/10/01  - add v$olap
Rem     vshukla    10/16/01  - fix wrong decode values in *_objects for lob
Rem                            (sub)partitions.
Rem     kpatel     10/04/01  - add shared_pool_advice, library_cache_memory
Rem     smuthukr   10/08/01  - fix pga_target_advice_histogram name length
Rem     wojeil     10/30/01  - adding v$ file mapping synonyms.
Rem     rburns     10/01/01  - fix public synonyms, remove drops
Rem     bdagevil   10/04/01  - add v$pga_target_advice_histogram
Rem     smuthukr   09/20/01  - add v$pga_target_advice
Rem     mzait      09/28/01  - support row source execution statistics
Rem     yuli       10/03/01  - add (g)v$statistics_level
Rem     smuthukr   09/10/01  - rename v$sort_usage to v$tempseg_usage
Rem     ayoaz      08/31/01  - change _OBJECT_TABLES view to to get syn by join
Rem     mmorsi     08/29/01  - use create or replace instead of drop & create
Rem     bdagevil   09/01/01  - add v$sql_workarea_histogram
Rem     ayoaz      08/21/01  - Support type synonyms in column types
Rem     sdizdar    08/05/01  - add v$backup_spfile and gv$backup_spfile
Rem     smangala   05/21/01  - add logmnr_stats.
Rem     qiwang     04/29/01  - add catlsby.sql
Rem     nireland   07/26/01  - Fix DBA_JOIN_IND_COLUMNS synonym. #1901895
Rem     smcgee     08/14/01  - phase 1 of DG monitoring project.
Rem     yuli       06/19/01  - add (g)v$MTTR_TARGET_ADVICE
Rem     vmarwah    07/10/01  - add processing for RETENTION LOB storage option.
Rem     gtarora    06/05/01  - replace type$ toid with tvoid
Rem     swerthei   04/03/01  - add v$database_block_corruption
Rem     sbedarka   05/16/01  - #(1775864) decode refact in xxx_constraints
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     gtarora    05/24/01  - inheritance support
Rem     narora     04/24/01  - correction for sqlplus
Rem     narora     04/16/01  - fix USER_NESTED_TABLES,ALL_NESTED_TABLES
Rem     narora     04/16/01  - DBA_NESTED_TABLES: join user$.user# with
Rem                          - parent table's obj$.owner#
Rem     tkeefe     04/11/01  - Fix comment.
Rem     eyho       04/11/01  - reduce identifier length for rac view
Rem     htseng     04/12/01  - eliminate execute twice (remove ;).
Rem     rguzman    04/04/01  - Remove catlsby call until 9iR2.
Rem     rjanders   04/06/01  - Add v$dataguard_status view.
Rem     qyu        03/29/01  - remove ; at the end of xxx_lobs
Rem     sagrawal   03/30/01  - fix procedureinfo$ based views
Rem     tkeefe     04/04/01  - Drop PROXY_ROLES public synonym before
Rem                            trying to create it.
Rem     eyho       04/03/01  - rac name changes
Rem     weiwang    04/09/01  - fix invalid column error in all_lobs & dba_lobs
Rem     ssubrama   03/22/01 -  bug1682637 modify dba_tab_col_statistics
Rem     cunnitha   03/27/01  - #(1642865):add subpartn to all_objects
Rem     tkeefe     03/22/01  - Add data dictionary views for n-tier.
Rem     vle        03/23/01  - bug 1651458
Rem     arithikr   03/15/01  - 1645892: remove drop recovery_catalog_owner role
Rem     smuthuli   03/15/01  - pctused = null for bitmap segments
Rem     qyu        03/14/01  - #1331689: fix xxx_lobs
Rem     tkeefe     03/06/01  - Simplify normalization of n-tier schema.
Rem     sbedarka   02/27/01  - #(1231780) add xxx_tab_cols view family
Rem     mtakahar   02/26/01  - add join order hints to *_tab_histograms
Rem     bdagevil   03/02/01  - add v$pgastat
Rem     wwchan     03/01/01  - adding new ops views
Rem     nshodhan   02/06/01  - Remove dba_consistent_read
Rem     sagrawal   01/08/01  - flags for procedureinfo
Rem     dpotapov   12/27/00  - bugs 954684-954669.
Rem     evoss      12/09/00  - add [g]v.sql_redirection
Rem     bemeng     12/11/00  - change v$object_stats to v$object_usage
Rem     rjenkins   11/22/00  - add char_length, char_used to arguments
Rem     sbedarka   11/21/00  - (1231780) backout txn
Rem     cku        11/17/00 - PBMJI.
Rem     tchou      11/20/00 - add support for ejb generated classes
Rem     spsundar   11/17/00 - fix *_indexes view for tablespace name
Rem     rwessman   11/17/00 - Backed out tab_ovf$ due to problems in upgrade an
Rem     bpanchap   10/10/00 -  Adding sequence_no to all_sumdelta
Rem     kquinn     11/17/00 - 1375879: alter operator -> alter any operator
Rem     heneman    10/20/00 - Rename MTS.
Rem     thoang     10/06/00 - add new columns to tab_columns view
Rem     clei       10/02/00 - add gv$vpd_policy and v$vpd_policy
Rem     qyu        09/25/00 - grant v$timezone_names to public
Rem     shihliu    09/11/00 - resumable view fix
Rem     rburns     09/08/00 - sqlplus fixes
Rem     smuthuli   07/18/00 - fix dba_rollback_segs for SMU.
Rem     sbedarka   08/21/00  - #(1188948) materialized view object type
Rem     kosinski   07/09/00 - Add dba_stored_settings
Rem     rmurthy    08/16/00 - add hierarchy option to tab_privs views
Rem     nireland   07/31/00 - Fix dba_profiles for verify_function. #843856
Rem     spsundar   10/17/00 -  fix *_indexes to reflect null tblspc for dom idx
Rem     kumamage   07/27/00 -  add v$spparameter and gv$spparameter
Rem     rjanders   07/31/00 -  add gv$archive_gap
Rem     svivian    07/25/00 -  add gv$logstdby_stats
Rem     amozes     07/17/00  - bitmap join index
Rem     evoss      07/26/00  - add external table catalog views
Rem     schatter   07/07/00  - add v$enqueue_stat
Rem     bdagevil   07/26/00  - add v$sql_memory_usage
Rem     rmurthy    07/25/00  - add superview info to xxx_views
Rem     rjenkins   05/05/00  - make char_used null for nonstrings
Rem     sdizdar    07/05/00  - RMAN configuration:
Rem                          - add create/drop v_$rman_configuration
Rem     shihliu    06/26/00 - fix dba(user)_resumable column name
Rem     kosinski   06/12/00  - Persistent parameter views
Rem     ayalaman   07/05/00 -  dba_object_tables fix for sqlplus
Rem     lsheng     06/26/00  - change user_, all_, dba_constraints definition.
Rem     rmurthy    06/19/00  - change objauth.option to flag bits
Rem     rmurthy    06/23/00  - xxx_ind_columns:handle attribute names correctly
Rem     rmurthy    06/30/00  - add XXX_PROCEDURES views
Rem     bdagevil   06/05/00  - add v$sql_workarea_active
Rem     bdagevil   06/05/00  - add v$sql_workarea
Rem     bdagevil   06/05/00  - add v$sql_plan
Rem     rjanders   07/05/00 -  Correct v$standby_log definition.
Rem     wnorcott   06/08/00 -  catcdc.sql
Rem     qyu        06/12/00  - DLS: add v$timezone_names, gv$timezone_names
Rem     arhee      06/08/00  - add new Resource Manager views
Rem     rwessman   06/08/00  - N-Tier enhancements
Rem     svivian    06/15/00 -  add logstdby fixed view
Rem     shihliu    05/29/00  - resumable views
Rem     smuthuli   04/06/00  - SMU: Add v$undostat and gv$undostat
Rem     ayalaman   06/08/00 -  guess stats for IOT with mapping table
Rem     atsukerm   05/26/00  - add database_properties view..
Rem     bemeng     05/25/00  - add new view v$object_stats
Rem     liwong     05/19/00  - Add dba_consistent_read
Rem     nagarwal   06/20/00  - add partition_name to *_ustat views
Rem     wixu       04/25/00  - wixu_resman_chg
Rem     tlahiri    04/17/00 -  Add cache size advisory views
Rem     ayalaman   04/14/00 -  key compress suggestion in index_stats
Rem     nagarwal   04/20/00  - fix *_ustat views for partitioned domain indexes
Rem     rjanders   03/30/00 -  Add missing managed standby views.
Rem     najain     03/30/00  - support for v$sql_shared_memory
Rem     rguzman    03/17/00 -  Add views for log groups, exclude log groups fro
Rem     nagarwal   03/31/00  - fix ustat view privileges
Rem     nagarwal   03/21/00  - add partition info to ustat views
Rem     rguzman    04/11/00 -  Logical Standby views and tables
Rem     ayalaman   03/20/00 -  index_stats fix for key compressed indexes
Rem     ayalaman   03/28/00 -  overflow statistics for IOT
Rem     ayalaman   04/04/00 -  iot with mapping table
Rem     rjenkins   02/08/00  - extended unicode support
Rem     nagarwal   03/09/00  - populate version info to association views
Rem     mwjohnso   03/15/00 -  Add $archive_dest_status
Rem     gkulkarn   03/14/00 -  Adding synonyms for LogMiner 8.2 fixed views
Rem     rjanders   03/09/00 -  Add V$MANAGED_STANDBY views.
Rem     rjenkins   02/02/99  - report the index being used by constraints
Rem     nagarwal   03/02/00  - add partition info to ustat views
Rem     nireland   02/01/00  - Fix line length related ORA-942. #1175426
Rem     spsundar   02/14/00 -  update *_indexes views
Rem     nagarwal   01/13/00  - add partitioning info to indextype views
Rem     jklein     01/19/00  -
Rem     nireland   12/20/99  - Add subpartitions to index_stats. #1114064
Rem     nagarwal   01/07/00  - add partition column to indextype views
Rem     yuli       12/28/99  - remove v$targetrba
Rem     nireland   11/20/99  - Fix #691329
Rem     jklein     11/30/99  - row seq #
Rem     liwong     10/13/99  - Expose opaque types in %_tab_columns
Rem     nagarwal   10/29/99 -  fix views for extensible indexing
Rem     attran     09/22/99 -  PIOT: TAB$/blkcnt
Rem     nagarwal   10/02/99  - Add views for extensible indexing - 8.2
Rem     nireland   09/17/99  - Fix ALL_SYNONYMS. #641756
Rem     hyoshiok   10/05/99 -  lrg regression
Rem     hyoshiok   08/31/99 -  #915791, add CLUSTER_OWNER in dba_tables
Rem     nagarwal   09/21/99 -  fix extensible indexing views
Rem     qyu        07/27/99 -  keep YES/NO of cache column in xxx_LOBS
Rem     attran     07/13/99 -  PIOT:pctused$/iotpk_objn
Rem     kosinski   08/13/99 -  Bug 822440: Add PLS_TYPE to *_ARGUMENTS
Rem     anithrak   08/06/99 -  Add V$BUFFER_POOL_STATISTICS
Rem     thoang     07/13/99  - Not using spare1 for datetime
Rem     tnbui      07/21/99  - Implicit -> Local
Rem     kensuzuk   07/14/99 -  Bug932236: fix XXX_TABLES, XXX_OBJECT_TABLES
Rem     evoss      07/11/99  - add  v$hs_parameter synonyms
Rem     mjungerm   06/15/99 -  add java shared data object type
Rem     tnbui      06/24/99  - change in user_arguments
Rem     tnbui      06/18/99  - TIMESTAMP WITH IMPLICIT TZ
Rem     rwessman   06/08/99 -  Bug 895111 - select on v$session_connect_info no
Rem     rshaikh    05/24/99 -  bug 897514: add com on tabs for DICTIONARY view
Rem     bnnguyen   06/01/99 -  bug837941
Rem     amganesh   05/05/99 -  Fast-Start nomenclature change
Rem     nireland   04/22/99 -  Add LOBs to dba_objects and all_objects #852521
Rem     sbedarka   04/16/99 -  #(816507) optimize [user|dba]_role_privs views
Rem     qyu        03/04/99 -  add CACHE READS lob mode
Rem     rshaikh    03/18/99 -  bug 685170: make nls_* value columns longer for
Rem     rshaikh    03/10/99 -  fix typo in ALL_INDEXES comment
Rem     qyu        03/04/99 -  add CACHE READS lob mode
Rem     rshaikh    02/22/99 -  fix bugs 322891,170720
Rem     rherwadk   02/12/99 -  compatibility for parameter tables & views
Rem     rmurthy    12/24/98 -  changes to *_INDEXES for domain indexes
Rem     rmurthy    12/24/98 -  changes to *_INDEXES views (bgoyal)
Rem     rmurthy    11/17/98 -  fix indextype views
Rem     tlahiri    11/09/98 -  Add (g)v_instance_recovery views
Rem     nireland   11/08/98 -  clu$.spare4 is now avgchn. #736363
Rem     spsundar   11/03/98 -  modify *_indexes views to reflect invalid status
Rem     atsukerm   10/12/98 -  fix UROWID type in ARGUMENTS views.
Rem     dmwong     09/23/98  - move application context views to catproc
Rem     sbedarka   09/03/98 -  #(709058) coerce datatype for decoded date expr
Rem     kmuthiah   09/20/98  - added IND_EXPRESSIONS views
Rem     akruglik   08/24/98  - fix for bug 717826:
Rem                              correct definition of ROW_MOVEMENT column
Rem     amozes     07/24/98  - global index stats
Rem     ncramesh   08/06/98 -  change for sqlplus
Rem     smuthuli   07/30/98 -  Bug 696705
Rem     bgoyal     08/06/98  - change *_INDEXES to show DISABLED status
Rem     qyu        08/17/98 -  706957: fix xxx_LOBS
Rem     rshaikh    07/30/98 -  add DATABASE_COMPATIBLE_LEVEL
Rem     wnorcott   08/20/98 -  Get rid of SUMMARY from XXX_OBJECTS
Rem     qyu        07/20/98 -  bug428835, fix xxx_col_comments
Rem     sbedarka   07/17/98 -  #(664195) user_ind_columns modified for perform
Rem     spsundar   07/23/98 -  add ityp_name and parameters to *_indexes
Rem     amozes     08/24/98  - expose endpoint actual value
Rem     sagrawal   06/25/98 -  DTYRID
Rem     rshaikh    06/22/98 -  move catsvrmg to catproc.sql
Rem     arhee      06/15/98 -  shorten name of rsrcmgr view
Rem     akalra     06/12/98 -  inicongroup -> defschclass
Rem     akalra     06/01/98  - Add inicongroup to dba_users, user_users
Rem     nagarwal   06/11/98 -  fix privs on _ustats and _association views
Rem     ayalaman   06/12/98 -  add guess stats to *_indexes
Rem     rjanders   06/01/98 -  Add GV$ARCHIVE_PROCESSES/V$ARCHIVE_PROCESSES vie
Rem     arhee      05/26/98 -  new names for db resource manager
Rem     ayalaman   06/05/98 -  index compression : fix index views
Rem     nagarwal   05/25/98 -  remove rpad from ustats views
Rem     ajoshi     05/22/98 -  Add gv_targetrba
Rem     bgoyal     05/18/98 -  remove *_TABLESPACES from catalog.sql
Rem     qyu        05/08/98 -  add views xxx_VARRAYS
Rem     mcusson    05/11/98 -  Name change: LogViewr -> LogMnr.
Rem     tnbui      05/12/98 -  Re-number datetime types
Rem     anithrak   05/12/98 -  Add V$RESERVED_WORDS
Rem     nagarwal   05/12/98 -  Modify ustat views for new properties
Rem     swerthei   02/17/98 -  add synonyms for backup I/O views
Rem     swerthei   04/13/98 -  add proxy_datafile, proxy_archivelog fixed views
Rem     mcoyle     05/06/98 -  Add GV$BLOCKED_LOCKS
Rem     qyu        05/01/98  - add storage_spec,return_type to *_NESTED_TABLES
Rem     lcprice    05/07/98 -  fix merge errors in *_tables
Rem     lcprice    05/06/98 -  add skip corrupt to dba_tables
Rem     bgoyal     05/07/98  - remove user_tablespaces from catalog.sql, a merg
Rem     bgoyal     04/17/98  - fix row_movement in user_*tables
Rem     weiwang    04/03/98 - add more types in user_objects
Rem     amozes     04/30/98 -  add modification information views
Rem     ato        04/30/98 -  add queues
Rem     spsundar   04/29/98 - add domain indexes to user_ustats view
Rem     kmuthiah   05/01/98 -  add cols. to user_refs and user_object_tables to
Rem     ajoshi     04/20/98 -  add targetrba view
Rem     rwessman   04/01/98 -  Added support for N-tier authentication
Rem     dmwong     04/13/98 -  fix privilege of KZSCAC and KZSDAC in ALL_OBJECTS
Rem     nagarwal   04/10/98 -  Update views for operator
Rem     rpark      04/10/98 -  add v$temporary_lob entries
Rem     syeung     02/25/98 -  add table subpartition to sys_objects list
Rem     pamor      04/10/98  - PX fixed tables
Rem     bhimatsi   04/14/98 -  bitmap ts - fixed view synonyms
Rem     dmwong     04/02/98 - support for app ctx
Rem     nagarwal   04/10/98 -  Add views for user defined stats
Rem     amozes     03/27/98  - add new stats information
Rem     rfrank     04/08/98 -  add log viewer views
Rem     pamor      03/31/98 -  add v$px_session v$px_sesstat
Rem     thoang     04/01/98 -  Define datetime/interval datatypes
Rem     amganesh   03/27/98 -  new views
Rem     thoang     03/27/98  - Add partial_drop_tabs view
Rem     alsrivas   03/30/98 -  removing FILTER info from indextype views
Rem     rjenkins   03/02/98  - adding DESCEND to index columns
Rem     wnorcott   03/28/98 -  Fix all_objects summary # 38-->42
Rem     araghava   03/25/98 -  Add ROW_MOVEMENT to *_TABLES.
Rem     ayalaman   03/27/98 -  use 2 bytes of pctthres for guess quality
Rem     arhee      03/19/98 -  add db scheduler views
Rem     atsukerm   03/24/98 -  add v$obsolete_parameter view.
Rem     kquinn     03/10/98 -  638499: Correct quoted string problems
Rem     eyho       03/10/98 -  add v$dlm_all_locks
Rem     syeung     02/25/98 -  add table subpartition to sys_objects list
Rem     pravelin   02/10/98  - Add HS fixed views
Rem     bhimatsi   03/07/98 -  bitmapped ts - reinstate index_stats
Rem     atsukerm   03/04/98 -  add UROWID column type to arguments and columns
Rem     vkarra     02/10/98 -  single table hash clusters
Rem     cfreiwal   02/24/98 -  key compression : index stats
Rem     thoang     12/12/97 -  Modified views to exclude unused columns.
Rem     rjenkins   01/20/98 -  functional indexes again
Rem     nagarwal   02/19/98 -  Modify optimizer views
Rem     nagarwal   12/30/97 -  Fix access privs on operator views
Rem     wbridge    01/16/98 -  eliminate v$current_bucket, v$recent_bucket
Rem     ato        01/14/98 -  merge from 8.0.4
Rem     nagarwal   12/28/97 -  Add views for extensible optimizer
Rem     akruglik   01/21/98 -  update definitions of _OBJECTS views to
Rem                            display LOB PARTITION and LOB SUBPARTITION
Rem     bhimatsi   02/24/98 -  bitmapped ts - dba_tablespace,data_files etc. vi
Rem     bhimatsi   01/20/98 -  bitmapped ts - dba_data_files
Rem     bnnguyen   12/22/97 -  bug555033
Rem     nagarwal   12/17/97 -  Fix _OPBINDING views
Rem     mcoyle     11/14/97 -  Change v$lock_activity to public
Rem     mjungerm   11/07/97 -  Add Java
Rem     skaluska   11/07/97 -  Add v$rowcache_parent, v$rowcache_subordinate
Rem     wesmith    11/06/97  - sumdelta$ shape change
Rem     jsriniva   11/17/97 -  iot: fix merge problem
Rem     jsriniva   11/17/97 -  move key compression attribute to flag
Rem     spsundar   11/03/97 -  fix views with secondary objects
Rem     rmurthy    10/28/97 -  fix status in index views
Rem     jsriniva   11/16/97 -  iot: add key-compression fields to ALL|USER|DBA_
Rem     rmurthy    10/23/97 -  merge from 8.0.4
Rem     nagarwal   10/23/97 -  Merge fix - decode # for operators
Rem     tnbui      10/21/97 -  Add new column RELY for xxx_CONSTRAINTS view
Rem     spsundar   10/13/97 -  update object views for secondary objects
Rem     spsundar   10/08/97 -  update index views for incomplete domain index
Rem     jingliu    10/06/97 -  Add view all_sumdelta
Rem     jfeenan    12/16/97 -  Add support for summaries to all_objects
Rem     jfeenan    11/06/97 -  add catsum.sql
Rem     bhimatsi   12/27/97 -  enhance dba_data_files for bitmapped tablespaces
Rem     thoang     09/26/97 -  Remove comma before FROM keyword
Rem     tlahiri    09/15/97 -  Add v$current_bucket, v$recent_bucket
Rem     nbhatt     09/15/97 -  change V$/GV$ aq_statistics to v$ gv$aq1
Rem     wuling     07/22/97 -  GV$, and V$RECOVERY_PROGRESS: creation
Rem     hyoshiok   09/05/97 -  nls_session_parameters; remove NLS_NCHAR_CHARACT
Rem     varora     09/10/97 -  fix tab_columns views to filter out nested table
Rem     whuang     09/09/97 -  expose the reverse index inform.
Rem     nbhatt     08/27/97 -  add v$aq_statistics
Rem     mcoyle     08/22/97 -  Add v,gv$ lock_activity - moved from catparr.sql
Rem     gpongrac   08/21/97 -  add v_$kccdi
Rem     gpongrac   08/20/97 -  add v_$kccfe view and grant to system
Rem     mkrishna   08/04/97 -  (bug 517730) change UPDATABLE_COLUMNS views
Rem     isung      08/05/97 -  To add NCHAR column length in character unit at
Rem     nbhatt     08/07/97 -  add synonym for aq_statistics
Rem     spsundar   08/29/97 -  modify index views
Rem     nagarwal   09/03/97 -  Make changes wrt opbinding change
Rem     alsrivas   08/28/97 -  updating indextype views to reflect dictionary c
Rem     eyho       07/16/97 -  add v$dlm_locks
Rem     nireland   07/07/97 -  Definition of dba_users and user_users incorrect
Rem     mkrishna   06/27/97 -  move grant authorization to cat8003
Rem     asurpur    06/04/97 -  Fix definition for dba_roles: add global roles
Rem     mkrishna   05/27/97 -  change # to Rem
Rem     rjenkins   05/14/97 -  functional indexes
Rem     rpark      05/08/97 -  465138: assign a type for lobs in USER_OBJECTS
Rem     alsrivas   06/10/97 -  updating INDEXTYPE_OPERATORS role
Rem     spsundar   06/10/97 -  update index views to reflect domain indexes
Rem     alsrivas   05/28/97 -  updating views for indextype
Rem     mkrishna   04/30/97 -  Add comment line
Rem     skaluska   04/21/97 -  argument$ type support
Rem     syeung     05/07/97 -  pti 8.1 project
Rem     mkrishna   04/15/97 -  Fix bug 479090
Rem     dalpern    04/16/97 -  return of on-disk package STANDARD
Rem     jfischer   04/16/97 -  Add DLM Fixed Views
Rem     alsrivas   05/16/97 -  updating IndexType views to reflect dictionary c
Rem     alsrivas   05/12/97 -  adding views for indextypes
Rem     nagarwal   05/04/97 -  Change OPERATOR name to OPERATORS
Rem     nagarwal   05/02/97 -  Adding catalog entries for operators
Rem     tlahiri    04/10/97 -  Add OPS performance views
Rem     jsriniva   04/01/97 -  iot: fix *_tables to display tablspace correctly
Rem     atsukerm   03/28/97 -  add views on enqueues and transactions.
Rem     ssamu      04/03/97 -  support partition index in INDEX_STATS
Rem     vkrishna   03/24/97 -  remove PACKED
Rem     rjenkins   03/17/97 -  ENFORCE to ENABLE NOVALIDATE
Rem     atsukerm   03/25/97 -  add resource limit views.
Rem     aho        03/25/97 -  gv$buffer_pool
Rem     nlewis     03/25/97 -  add trusted_servers view
Rem     aho        03/22/97 -  fix syntax errors in  USER, ALL, & DBA_LOBS
Rem     rshaikh    03/17/97 -   fix bug 403882 on *_tables
Rem     esoyleme   03/17/97 -  add v$dispatcher_rate
Rem     aho        03/13/97 -  partitioned cache: v$buffer_pool
Rem     aho        02/28/97 -  partitioned cache: add comments for buffer_pool
Rem     aho        02/27/97 -  partitioned cache: add buffer_pool to views
Rem     hpiao      03/10/97 -  add catsnmp.sql
Rem     bhimatsi   03/07/97 -  inline lobs - enhance lob views
Rem     amozes     02/21/97 -  remove execution_location
Rem     tpystyne   02/17/97 -  create recovery_catalog_owner role
Rem     gdoherty   01/20/97 -  remove catsnmp, logs in as another user
Rem     rdbmsint   01/10/97 -  add catsnmp.sql
Rem     cxcheng    01/02/97 -  fix bug where non-existent type is included
Rem                            in table views output
Rem     atsukerm   12/16/96 -  change EXTENTS views to take advantage of ts#.
Rem     thoang     11/22/96 -  Update views for NCHAR
Rem     rjenkins   11/20/96 -  adding column BAD to constraint views
Rem     jwijaya    11/19/96 -  revise object terminologies
Rem     rshaikh    11/08/96 -  fix *_neste_tables views
Rem     jbellemo   11/07/96 -  DistSecDoms: add external to _USERS
Rem     rshaikh    10/25/96 -  add views for nested tables
Rem     amozes     11/05/96 -  qpm - execution tree location
Rem     tpystyne   11/07/96 -  add v$backup_device and v$archive_dest
Rem     rmurthy    10/23/96 -  support attribute names in REF views
Rem     schandra   10/22/96 -  global_transaction synonym - fix typo
Rem     tcheng     10/10/96 -  fix comments for {USER,ALL,DBA}_VIEWS
Rem     tcheng     10/10/96 -  add type owner and name to {USER,ALL,DBA}_VIEWS
Rem     schandra   09/16/96 -  Add GLOBAL_TRANSACTIONS view
Rem     jwijaya    10/03/96 -  add vsession_object_cache
Rem     rmurthy    09/25/96 -  modify views on REF columns
Rem     jsriniva   09/17/96 -  iot: fix include column comment
Rem     jsriniva   09/05/96 -  add inclcol to *_INDEXES
Rem     rmurthy    09/09/96 -  add views for REFS
Rem     rhari      08/30/96 -  Add USER_LIBRARIES, ALL_LIBRARIES, DBA_LIBRARIES
Rem     rxgovind   08/14/96 -  add catalog views for directory objects
Rem     jsriniva   08/12/96 -  fix iot catalogue changes
Rem     skaluska   08/09/96 -  Fix CACHE column for clu$ views
Rem     mcoyle     08/05/96 -  Add synonyms for global fixed views (GV$)
Rem     jsriniva   08/06/96 -  modify views to display iot physical attr
Rem     tcheng     08/01/96 -  show type text in {user,all,dba}_views
Rem     skaluska   07/31/96 -  Fix tab$ and clu$ views
Rem     rjenkins   07/24/96 -  enable vs enforce
Rem     jwijaya    07/25/96 -  test charsetform
Rem     rhari      07/23/96 -  LIBRARY as a PL/SQL object
Rem     atsukerm   07/22/96 -  put 'INDEX/TABLE partition' into OBJECTS views.
Rem     akruglik   07/10/96 -  modify definition of
Rem                            {user|dba|all}_{tables|indexes} to display
Rem                            NULL in place of LOGGING attribute of
Rem                            partitioned tables/indices
Rem     rjenkins   06/18/96 -  add GENERATED column name
Rem     jwijaya    06/14/96 -  check for EXECUTE ANY TYPE
Rem     jwijaya    06/19/96 -  fix COL
Rem     tcheng     06/25/96 -  add column comments for user_views
Rem     tpystyne   06/14/96 -  add v$datafile_header
Rem     atsukerm   06/13/96 -  fix EXTENT views.
Rem     asurpur    06/14/96 -  Fix dba_users and user_users for password manage
Rem     rjenkins   06/10/96 -  correct flag in user constraints
Rem     tcheng     06/11/96 -  change SYS_NC_ROWINFO$
Rem     vkrishna   06/10/96 -  change ROW_INFO to SYS_NC_ROW_INFO
Rem     jpearson   06/11/96 -  correct the EXP_DBA_OBJECTS view
Rem     tcheng     06/01/96 -  don't show hidden cols in *_updatable_columns
Rem     tcheng     05/30/96 -  enhance user_updatable_columns for views with tr
Rem     asurpur    05/30/96 -  Fix the views user_users and dba_users
Rem     mmonajje   05/20/96 -  Replace timestamp col name with timestamp#
Rem     bhimatsi   05/18/96 -  change in lob$ field names, fix views
Rem     rjenkins   05/17/96 -  novalidate constraints
Rem     asurpur    05/15/96 -  Dictionary Protection: Granting privileges
Rem     jsriniva   05/14/96 -  iot-related catalog changes
Rem     schandra   05/13/96 -  V$SORT_USAGE: Creation
Rem     atsukerm   05/13/96 -  change DBA_OBJECTS views to expose partition
Rem                            name and data object ID
Rem     jwijaya    05/06/96 -  add LOBS views
Rem     ajasuja    05/02/96 -  merge OBJ to BIG
Rem     jwijaya    04/29/96 -  check for EXECUTE ANY PROCEDURE for types
Rem     tpystyne   04/26/96 -  speedup DBA_DATA_FILES by eliminating outer join
Rem     jwijaya    04/26/96 -  filter out nested tables from _TABLES
Rem     jwijaya    04/23/96 -  fixed user_tables
Rem     bhimatsi   04/16/96 -  enhance views for lob segments and indexes
Rem     tcheng     04/16/96 -  enhance views on view$ to show typed_view$
Rem     vkrishna   04/09/96 -  fix user_tab_columns and user_tables view querie
Rem     asurpur    04/03/96 -  Dictionary protection implementation
Rem     schatter   03/07/96 -  define v$session_longops
Rem     nmallava   04/18/96 -  create public synonyms for new views
Rem     atsukerm   04/09/96 -  fix ALL_INDEXES.
Rem     achaudhr   04/08/96 -  reorder decodes to eliminate to_number's
Rem     achaudhr   04/04/96 -  fix yet another decode bug
Rem     rjenkins   04/05/96 -  fix user_indexes pct_free
Rem     jwijaya    03/28/96 -  test the property of column
Rem     atsukerm   03/26/96 -  merge fix.
Rem     achaudhr   03/21/96 -  put decodes in {user|all|dba}_{tables|indexes}
Rem     jwijaya    03/21/96 -  support global TOID
Rem     schatter   03/07/96 -  define v$session_longops
Rem     hasun      03/04/96 -  Merge bug fix#284791 into OBJECT branch
Rem     asurpur    03/05/96 -  Password Management implementation
Rem     atsukerm   02/29/96 -  space support for partitions.
Rem     akruglik   02/28/96 -  add logging attribute to
Rem                            {USER | ALL | DBA}_{TABLES | INDICES}
Rem     bhimatsi   02/27/96 -  minimum feature - add new column to ts$
Rem     fsmith     02/22/96 -  Add synonym for v$subcache
Rem     ltan       02/14/96 -  PDML: add logging attribute to dba_tablespaces
Rem     tcheng     02/09/96 -  rename adtcol$ to coltype$
Rem     mramache   01/24/96 -  CM - change usertables definition
Rem     ixhu       01/16/96 -  fix user_indexes syntax error
Rem     lwillis    01/16/96 -  7.3 merge
Rem     atsukerm   01/12/96 -  fix DBA_DATA_FILES.
Rem     jklein     01/11/96 -  free space stats for pdml
Rem     atsukerm   01/03/96 -  tablespace-relative DBAs.
Rem     rjenkins   12/15/95 -  fixing deferred constraints
Rem     gdoherty   12/15/95 -  fix deferred constraints merge with objects
Rem     rdbmsint   12/13/95 -  add v_system_parameter
Rem     achaudhr   12/08/95 -  Change value of STATUS in USER_INDEXES
Rem     msimon     11/21/95 -  Fix suntax error on USER_CLUSTER_HASH_EXPRESSIONS
Rem     lwillis    11/16/95 -  Change *_histograms.bucket_number
Rem     aho        11/13/95 -  iot
Rem     rtaranto   11/09/95 -  Add synonym for v$sql_shared_memory
Rem     jwijaya    11/07/95 -  type privilege fix
Rem     rtaranto   11/03/95 -  Add new bind fixed views
Rem     schandra   11/02/95 -  Migration - change dba_tablespaces view
Rem     achaudhr   10/30/95 -  PTI: Invoke catpart.sql
Rem     rjenkins   10/27/95 -  deferred constraints
Rem     achaudhr   10/27/95 -  PTI: add outer-joins to INDEXES family of views
Rem     achaudhr   10/25/95 -  PTI: Add lpads around degree, instances, cache
Rem     hjakobss   10/19/95 -  bitmap indexes in index views
Rem     schandra   10/17/95 -  Migration - Change dba_tablepsaces view
Rem     achaudhr   10/06/95 -  PTI: cache flag value changed
Rem     skaluska   10/04/95 -  Rename unique$ to property
Rem     achaudhr   10/03/95 -  PTI: change degree, instances, cache
Rem     jbellemo   09/25/95 -  #284791: fix security in ALL_OBJECTS
Rem     jwijaya    09/21/95 -  support ADTs/objects
Rem     wmaimone   08/11/95 -  merge changes from branch 1.182.720.6
Rem     achaudhr   07/20/95 -  PTI: fix flags
Rem     achaudhr   07/20/95 -  PTI: Fix old views and add new ones
Rem     wmaimone   07/17/95 -  add all_arguments views
Rem     arhee      07/06/95 -  add v$active_instances
Rem     amozes     06/23/95 -  add v$pq_tqstat for table queue statistics
Rem     ssamu      06/15/95 -  change views on tab$
Rem     schatter   03/21/95 -  add v$latch_misses for latch tracking
Rem     gngai      03/07/95 -  Added v$locked_object
Rem     jcchou     03/06/95 -  #258792, fixed view TABLE_PRIVILEGES
Rem     atsukerm   02/20/95 -  Sort Segment - Temporary Tablespace Support
Rem     glumpkin   02/10/95 -  fix histogram views
Rem     aho        02/02/95 -  merge changes from branch 1.182.720.5 (95.02.02)
Rem     ksriniva   01/27/95 -  merge of hier. latch stuff from 7.3
Rem     jbellemo   01/25/95 -  merge changes from branch 1.182.720.3
Rem     jbellemo   01/13/95 -  #259639: fix security for pack bodies in all_obj
Rem     glumpkin   01/10/95 -  add sample_size to tab_columns
Rem     jbellemo   01/06/95 -  #211270: speed up table_privileges view
Rem     bhimatsi   01/05/95 -  Add view(s) : DBA_FREE_SPACE_COALESCED
Rem     glumpkin   12/29/94 -  add histogram views
Rem     bhirano    12/29/94 -  merge changes from branch 1.182.720.2
Rem     bhirano    12/28/94 -  bug 257956: add synonym for shared_pool_reserved
Rem     ksriniva   12/22/94 -  add more latch views
Rem     ksriniva   11/16/94 -  merge changes from branch 1.182.720.1
Rem     gpongrac   10/21/94 -  media recovery views
Rem     glumpkin   10/01/94 -  Histograms
Rem     achaudhr   09/19/94 -  UJV: Add UPDATABLE_COLUMNS
Rem     ksriniva   09/17/94 -  bug 236209: add synonyms for v$execution and
Rem                            v$session_connect_info
Rem     aho        07/08/94 -  freelist groups for indexes
Rem     ajasuja    07/07/94 -  add v
Rem     agupta     07/05/94 -  224310 - add comments for freelists
Rem     nmichael   06/21/94 -  Hash expressions for clusters & ALL_CLUSTERS vie
Rem     jloaiza    06/20/94 -  fix all_tables
Rem     jloaiza    06/16/94 -  add disable dml locks
Rem     ksriniva   06/15/94 -  bug 219066: add V$EVENT_NAME
Rem     wmaimone   05/06/94 -  #158950,156147 fix DICTIONARY; 186155 dba_ syns
Rem     jloaiza    05/23/94 -  add new fixed views
Rem     wmaimone   04/07/94 -  merge changes from branch 1.163.710.11
Rem     jcohen     04/07/94 -  merge changes from branch 1.163.710.5
Rem     agupta     03/28/94 -  merge changes from branch 1.163.710.6
Rem     thayes     03/22/94 -  merge changes from branch 1.163.710.12
Rem     ltung      03/02/94 -  merge changes from branch 1.163.710.10
Rem     aho        01/03/95 -  add synonym for v$instance, v$mystat,
Rem                            v$sqltext, and v$shared_pool_reserved
Rem     jbellemo   09/02/94 -  add synonym for v$pwfile_users
Rem     thayes     03/02/94 -  Add compatibility views
Rem     wmaimone   03/02/94 -  add view and public synonym for v$sess_io
Rem     ltung      02/20/94 -  yet another parallel/cache semantic change
Rem     ltung      01/23/94 -  add v$pq_sysstat
Rem     ltung      01/19/94 -  add v$pq_sesstat and v$pq_slave
Rem     ltung      01/15/94 -  new parallel/cache/partitions semantics
Rem     hrizvi     01/03/94 -  bug191476 - omit invalid RSs from
Rem                            dba_rollback_segs
Rem     agupta     01/05/94 -  192948 - change units for *_extents in *_segment
Rem     jcohen     01/04/94 - #(192450) add v$option table
Rem     jcohen     12/20/93 - #(191673) fix number fmt for user_tables,cluster
Rem     jbellemo   12/17/93 -  merge changes from branch 1.163.710.3
Rem     agupta     11/29/93 -  92383 - make seg$ freelist info visible
Rem     jbellemo   11/09/93 -  #170173: change uid to userenv('schemaid')
Rem     gdoherty   11/01/93 -  add call to catsvrmg for Server Manager
Rem     gdoherty   10/20/93 -  add v$nls_valid_values
Rem     hkodaval   11/05/93 -  merge changes from branch 1.163.710.1
Rem     hkodaval   10/14/93 -  merge changes from branch 1.151.312.7
Rem     wbridge    07/02/93 -  add v$controlfile fixed table
Rem     ltung      06/25/93 -  merge changes from branch 1.151.312.4
Rem     jcohen     06/22/93 - #(165117) new view product_component_version
Rem     vraghuna   06/17/93 -  bug 166480 - move resource_map into sql.bsq
Rem     ltung      05/28/93 -  parallel/cache in table/cluster views
Rem     wmaimone   05/20/93 -  merge changes from branch 1.151.312.3
Rem     wmaimone   05/20/93 -  merge changes from branch 1.151.312.1
Rem     jcohen     05/18/93 - #(163749) passwords visible in SYS.DBA_DB_LINKS
Rem     wmaimone   05/18/93 -  fix width of all_indexes
Rem     ltung      05/14/93 - #(157449) add v$dblink
Rem     hkodaval   04/30/93 -  Bug 162360: free lists/groups should show > 0
Rem                             in views user_segments and dba_segments
Rem     rnakhwa    04/12/93 -  merge changes from branch 1.151.312.2
Rem     wbridge    04/02/93 -  read-only tablespaces
Rem     agupta     01/10/93 -  141957 - remove divide by 0 window
Rem     wmaimone   05/07/93 -  #(161964) use system privs for all_*
Rem     rnakhwa    04/12/93 -  Embedded comments are not allowd within SQL stat
Rem     wmaimone   04/02/93 -  #(158143) grant select on nls_parameters
Rem     wmaimone   04/02/93 -  #(158143) grant select on nls_parameters
Rem     ksriniva   11/30/92 -  add synonyms for v$session_event, v$system_event
Rem     tpystyne   11/27/92 -  add nls_* views
Rem     ghallmar   11/20/92 -  fix DBA_2PC_PENDING.GLOBAL_TRAN_ID
Rem     amendels   11/19/92 -  fix 139681, 140003: modify *_constraints
Rem     ksriniva   11/13/92 -  add public synonym for v$session_wait
Rem     pritto     11/09/92 -  add synonym for V$MTS
Rem     tpystyne   11/06/92 -  use create or replace view
Rem     jklein     09/29/92 -  histogram support
Rem     vraghuna   10/29/92 -  bug 130560 - move map tables in sql.bsq
Rem     jloaiza    10/28/92 -  add v$db_object_cache and v$open_cursor
Rem     glumpkin   10/20/92 -  Adjust for new .sql filenames
Rem     ltan       10/20/92 -  rename DBA_ROLLBACK_SEGS status
Rem     mmoore     10/15/92 - #(134232) show more privs in all_tab_privs
Rem     mmoore     10/15/92 - #(133927) speed up table_privileges view
Rem     dsdaniel   10/13/92 -  bug 112376 112374 125947 alter/create profile
Rem     amendels   10/08/92 -  132726: fix *_constraints to show DELETE CASCADE
Rem     mmoore     10/08/92 - #(132956) remove _next_objects from dba_objects
Rem     jwijaya    10/07/92 -  add v$*cursor_cache
Rem     ltan       10/07/92 -  fix undefined status for dba_rollback_segs
Rem     mmoore     10/02/92 -  fix role_privs views
Rem     ltan       09/11/92 -  decode new status for rollback segment
Rem     jbellemo   09/24/92 -  merge changes from branch 1.124.311.2
Rem     jbellemo   09/18/92 -  #126685: show datatype 106 as MLSLABEL in *_TAB_
Rem     mmoore     09/23/92 -  fix comment on dba_role_privs
Rem     aho        09/23/92 -  change view text to upper case & make shorter
Rem     pritto     09/04/92 -  rename dispatcher view synonyms
Rem     jwijaya    09/09/92 -  add v$fixed_table
Rem     aho        08/31/92 -  merge forward status column in *_indexes from v6
Rem                         -  bug 126268
Rem     mmoore     08/28/92 - #(124859) add default role information to role vi
Rem     mmoore     08/10/92 - #(121120) remove create index from system_priv_ma
Rem     rjenkins   07/24/92 -  removing drop & alter snapshot
Rem     hrizvi     07/16/92 -  add v$license
Rem     mmoore     07/13/92 - #(104081) change alter resource priv name -> add
Rem     agupta     06/26/92 -  115032 - add lists,groups to *_segments
Rem     wbridge    06/25/92 -  fixed tables for file headers
Rem     jwijaya    06/25/92 -  MODIFIED -> LAST_DDL_TIME per marketing
Rem     achaudhr   07/20/95 -  PTI: fix flags
Rem     achaudhr   07/20/95 -  PTI: Fix old views and add new ones
Rem     epeeler    06/23/92 -  accomodate new type 7 in cdef$
Rem     jwijaya    06/15/92 -  v$plsarea is obsolete
Rem     jbellemo   06/12/92 -  add mapping for MLSLABEL to *_TAB_COLUMNS
Rem     jwijaya    06/04/92 -  fix a typo
Rem     mmoore     06/04/92 - #(112281) add execute to table_privs
Rem     agupta     06/01/92 -  111558 - user_tablespaces view wrong
Rem     mmoore     06/01/92 - #(111110) fix dba_role_privs
Rem     rlim       05/29/92 -  #110883 - add missing views in dictionary
Rem     jwijaya    05/26/92 -  fix bug 110884 - don't grant on v$sga
Rem     jwijaya    05/19/92 -  add v$type_size
Rem     rlim       05/15/92 -  fix bug 101589 - correct spelling mistakes
Rem     epeeler    05/06/92 -  fix NULL columns - bug 103146
Rem     mmoore     05/01/92 - #(107592) fix all_views to look at enabled roles
Rem     jwijaya    04/23/92 -  status for _NEXT_OBJECT is N/A
Rem     agupta     04/16/92 -  add columns to dba_segments
Rem     mmoore     04/13/92 -  merge changes from branch 1.101.300.1
Rem     mmoore     03/03/92 -  change grant view names
Rem     rnakhwa    03/10/92 -  + synonyms 4 views-v$thread, v$datafile, v$log
Rem     thayes     03/24/92 -  Define v$rollname in catalog.sql instead of kqfv
Rem     wmaimone   02/24/92 -  add v$mls_parameters
Rem     mmoore     02/19/92 -  remove more v$osroles
Rem     mmoore     02/19/92 -  remove v$enabledroles and v$osroles
Rem     jwijaya    02/06/92 -  add v$librarycache
Rem     mmoore     01/31/92 -  fix the user_free_space view
Rem     rkooi      01/23/92 -  drop global naming views before creating them
Rem     rkooi      01/23/92 -  use @@ command for subscripts
Rem     rkooi      01/18/92 -  add synonym
Rem     rkooi      01/18/92 -  add object_sizes views
Rem     rkooi      01/10/92 -  fix up trigger views
Rem     ajasuja    12/31/91 -  fix dba_audit_trail view
Rem     ajasuja    12/30/91 -  audit EXISTS
Rem     amendels   12/23/91 -  simplify *_clusters as clu$.hashkeys cannot be n
Rem     amendels   12/23/91 -  fix *_clusters views for hashing
Rem     agupta     12/23/91 -  89036 - dba_ts_quotas
Rem     rkooi      12/15/91 -  change 'triggering_statement' to 'trigger_body'
Rem     ajasuja    11/27/91 -  add system privilege auditing
Rem     amendels   11/26/91 -  modify user/dba_clusters for hash cluster
Rem     ghallmar   11/08/91 -  add GLOBAL_NAME view
Rem     rjenkins   11/07/91 -  commenting snapshots
Rem     ltan       12/02/91 -  add inst# to undo$
Rem     mroberts   10/30/91 -  apply error view changes (for views) to IMRG
Rem     rkooi      10/20/91 -  add public_dependency, fix priv checking
Rem                            on all_objects
Rem     smcadams   10/19/91 -  tweak audit_action table
Rem                            add execute obj audit option to audit views
Rem                            add new_owner to dba_audit_trail
Rem     mroberts   10/14/91 -  add v$nls_parameters view
Rem     mroberts   10/11/91 -  put VIEW changes in the mainline
Rem     jcleland   10/11/91 -  add mac privileges to sys_priv_map
Rem     epeeler    10/10/91 -  add enabled status columns to constraint views
Rem     cheigham   10/03/91 -  remove extra ;'s
Rem     mmoore     09/18/91 - #(74112) add dba_roles view to show all roles
Rem     agupta     09/03/91 -  add sequence# to tabauth$
Rem     mmoore     09/03/91 -  change trigger view column names again
Rem     ghallmar   08/12/91 -  global naming
Rem     amendels   08/29/91 -  fix dict_columns: 'ALL$' -> 'ALL%'
Rem     rlim       08/22/91 -  add comments regarding dba synonyms
Rem     mmoore     08/17/91 - #77458  change trigger views
Rem     mmoore     08/01/91 -  merge changes from branch 1.59.100.1
Rem     mmoore     08/01/91 -  move column_privileges back
Rem     rlim       07/31/91 -  added remarks column to syscatalog & catalog
Rem     rlim       07/30/91 -  moved dba synonyms to dba_synonyms.sql
Rem     mmoore     07/22/91 - #65139  fix bug in user_tablespaces
Rem     jwijaya    07/14/91 -  remove unnecessary LINKNAME IS NULL
Rem   mmoore     07/08/91 - change trigger view column names
Rem   amendels   07/02/91 - remove change to *_constraints.constraint_type
Rem   mmoore     06/28/91 - move table_privileges back in
Rem   ltan       06/24/91 - bug 65188,add comment on DBA_ROLLBACK_SEGS.BLOCK_ID
Rem   mmoore     06/24/91 - move table and column_privileges to catalog6
Rem   ghallmar   06/11/91 -         new improved 2PC views
Rem   amendels   06/10/91 - move obsolete sql2 views to catalog6.sql;
Rem                       - remove decodes for type 97;
Rem                       - union -> union all;
Rem                       - improve *_constraints.constraint_type (66063)
Rem   mmoore     06/10/91 - add grantable column to privilege views
Rem   smcadams   06/09/91 - add actions to audit_actions
Rem   mmoore     06/03/91 - change user$ column names
Rem   agupta     06/07/91 - syntax error in exp_objects view
Rem   rkooi      10/22/91 - deleted lots of comments (co truncate bug)
Rem   Grayson    03/21/88 - Creation
 
 
--CATCTL -S    Initial scripts single process
@@cdstrt
@@cdfixed.sql
@@cdcore.sql

--CATCTL -M
@@cdplsql.sql
@@cdsqlddl.sql
@@cdmanage.sql
@@cdtxnspc.sql
@@cdenv.sql
@@cdrac.sql
@@cdsec.sql
@@cdobj.sql
@@cdjava.sql
@@cdpart.sql
@@cdrep.sql
@@cdaw.sql
@@cdsummgt.sql
@@cdtools.sql
@@cdexttab.sql
@@cddm.sql
@@catldr.sql


--CATCTL -S     Final scripts single process
@@cdoptim.sql
@@catsum.sql
@@catexp.sql
@@cddst.sql
@@cdend.sql
