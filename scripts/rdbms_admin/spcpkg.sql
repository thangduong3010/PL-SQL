Rem
Rem $Header: rdbms/admin/spcpkg.sql /st_rdbms_11.2.0/2 2012/03/06 15:07:48 shsong Exp $
Rem
Rem spcpkg.sql
Rem
Rem Copyright (c) 1999, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      spcpkg.sql
Rem
Rem    DESCRIPTION
Rem      SQL*PLUS command file to create statistics package
Rem
Rem    NOTES
Rem      Must be run as the STATSPACK owner, PERFSTAT
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    arogers     01/23/08 - 6523482 - change VM_IN/OUT_BYTES id numbers
Rem    cdgreen     03/14/07 - 11 F2
Rem    shsong      06/14/07 - Fix BUFFER_GETS
Rem    cdgreen     04/05/07 - 5691086
Rem    cdgreen     03/02/07 - use _FG for v$system_event
Rem    cdgreen     03/02/07 - 5913378
Rem    cdgreen     05/16/06 - 11 F1 
Rem    cdgreen     05/10/06 - 5215982
Rem    cdgreen     05/24/05 - 4246955
Rem    cdgreen     04/18/05 - 4228432
Rem    cdgreen     02/28/05 - 10gR2 misc
Rem    vbarrier    02/18/05 - 4081984
Rem    cdgreen     01/25/05 - 4143812
Rem    cdgreen     10/29/04 - 10gR2_sqlstats
Rem    cdgreen     10/25/04 - 3970898
Rem    cdgreen     07/16/04 - 10g R2 
Rem    vbarrier    03/18/04 - 3517841
Rem    vbarrier    02/12/04 - 3412853
Rem    cdialeri    12/04/03 - 3290482
Rem    cdialeri    11/05/03 - 3202706 
Rem    cdialeri    10/14/03 - 10g - streams - rvenkate 
Rem    cdialeri    08/05/03 - 10g F3 
Rem    cdialeri    07/31/03 - 2804307
Rem    vbarrier    02/25/03 - 10g RAC
Rem    cdialeri    01/28/03 - 10g F2: baseline, purge
Rem    cdialeri    11/15/02 - 10g F1
Rem    cdialeri    10/29/02 - 2648471
Rem    cdialeri    09/11/02 - 1995145
Rem    vbarrier    04/18/02 - 2271895
Rem    vbarrier    03/20/02 - 2184504
Rem    spommere    03/19/02 - 2274095
Rem    vbarrier    03/05/02 - Segment Statistics
Rem    spommere    02/14/02 - cleanup RAC stats that are no longer needed
Rem    spommere    02/08/02 - 2212357
Rem    cdialeri    02/07/02 - 2218573
Rem    cdialeri    01/30/02 - 2184717
Rem    cdialeri    01/09/02 - 9.2 - features 2
Rem    cdialeri    11/30/01 - 9.2 - features 1
Rem    hbergh      08/23/01 - 1940915: use substrb on sql_text
Rem    cdialeri    04/26/01 - 9.0
Rem    cdialeri    09/12/00 - sp_1404195
Rem    cdialeri    04/07/00 - 1261813
Rem    cdialeri    03/28/00 - sp_purge
Rem    cdialeri    02/16/00 - 1191805
Rem    cdialeri    11/01/99 - Enhance, 1059172
Rem    cgervasi    06/16/98 - Remove references to wrqs
Rem    cmlim       07/30/97 - Modified system events
Rem    gwood.uk    02/30/94 - Modified
Rem    densor.uk   03/31/93 - Modified
Rem    cellis.uk   11/15/89 - Created
Rem

set echo off;
whenever sqlerror exit;

spool spcpkg.lis

/* ---------------------------------------------------------------------- */

prompt Creating Package STATSPACK...

create or replace package STATSPACK as
 
   procedure STAT_CHANGES
      ( bid           IN  number
      , eid           IN  number
      , db_ident      IN  number
      , inst_num      IN  number
      , parallel      IN  varchar2
      , lhtr    OUT number,     bfwt   OUT number
      , tran    OUT number,     chng   OUT number
      , ucal    OUT number,     urol   OUT number
      , rsiz    OUT number
      , phyr    OUT number,     phyrd  OUT number
      , phyrdl  OUT number,     phyrc  OUT number
      , phyw    OUT number,     ucom   OUT number
      , prse    OUT number,     hprse  OUT number
      , recr    OUT number,     gets   OUT number
      , slr     OUT number
      , rlsr    OUT number,     rent   OUT number
      , srtm    OUT number,     srtd   OUT number
      , srtr    OUT number,     strn   OUT number
      , lhr     OUT number
      , bbc     OUT varchar2,   ebc    OUT varchar2
      , bsp     OUT varchar2,   esp    OUT varchar2
      , blb     OUT varchar2
      , bs      OUT varchar2,   twt    OUT number
      , logc    OUT number,     prscpu OUT number
      , tcpu    OUT number,     exe    OUT number
      , prsela  OUT number
      , bspm    OUT number,     espm   OUT number
      , bfrm    OUT number,     efrm   OUT number
      , blog    OUT number,     elog   OUT number
      , bocur   OUT number,     eocur  OUT number
      , bpgaalloc OUT number,   epgaalloc OUT number
      , bsgaalloc OUT number,   esgaalloc OUT number
      , bnprocs OUT number,     enprocs OUT number
      , timstat OUT varchar2,   statlvl OUT varchar2
      , bncpu   OUT number,     encpu  OUT number     -- OS Stat
      , bpmem   OUT number,     epmem  OUT number
      , blod    OUT number,     elod   OUT number
      , itic    OUT number,     btic   OUT number
      , iotic   OUT number,     rwtic  OUT number
      , utic    OUT number,     stic   OUT number
      , vmib    OUT number,     vmob   OUT number
      , oscpuw  OUT number
      , dbtim   OUT number,     dbcpu  OUT number     -- Time Model
      , bgela   OUT number,     bgcpu  OUT number
      , prstela OUT number,     sqleela OUT number
      , conmela OUT number
      , dmsd    OUT number,     dmfc   OUT number     -- begin RAC
      , dmsi    OUT number
      , pmrv    OUT number,     pmpt   OUT number
      , npmrv   OUT number,     npmpt  OUT number
      , dbfr    OUT number
      , dpms    OUT number,     dnpms  OUT number
      , glsg    OUT number,     glag   OUT number
      , glgt    OUT number
      , gccrrv  OUT number,     gccrrt OUT number,     gccrfl OUT number
      , gccurv  OUT number,     gccurt OUT number,     gccufl OUT number
      , gccrsv  OUT number
      , gccrbt  OUT number,     gccrft OUT number
      , gccrst  OUT number,     gccusv OUT number
      , gccupt  OUT number,     gccuft OUT number
      , gccust  OUT number
      , msgsq   OUT number,     msgsqt  OUT number
      , msgsqk  OUT number,     msgsqtk OUT number
      , msgrq   OUT number,     msgrqt  OUT number    -- end RAC
      );
 
   procedure SNAP
      (i_snap_level          in number   default null
      ,i_session_id          in number   default null
      ,i_ucomment            in varchar2 default null
      ,i_num_sql             in number   default null
      ,i_executions_th       in number   default null
      ,i_parse_calls_th      in number   default null
      ,i_disk_reads_th       in number   default null
      ,i_buffer_gets_th      in number   default null
      ,i_sharable_mem_th     in number   default null
      ,i_version_count_th    in number   default null
      ,i_seg_phy_reads_th    in number   default null
      ,i_seg_log_reads_th    in number   default null
      ,i_seg_buff_busy_th    in number   default null
      ,i_seg_rowlock_w_th    in number   default null
      ,i_seg_itl_waits_th    in number   default null
      ,i_seg_cr_bks_rc_th    in number   default null
      ,i_seg_cu_bks_rc_th    in number   default null
      ,i_all_init            in varchar2 default null
      ,i_old_sql_capture_mth in varchar2 default null
      ,i_pin_statspack       in varchar2 default null
      ,i_modify_parameter    in varchar2 default 'FALSE'
      );

   function SNAP
      (i_snap_level          in number   default null
      ,i_session_id          in number   default null
      ,i_ucomment            in varchar2 default null
      ,i_num_sql             in number   default null
      ,i_executions_th       in number   default null
      ,i_parse_calls_th      in number   default null
      ,i_disk_reads_th       in number   default null
      ,i_buffer_gets_th      in number   default null
      ,i_sharable_mem_th     in number   default null
      ,i_version_count_th    in number   default null
      ,i_seg_phy_reads_th    in number   default null
      ,i_seg_log_reads_th    in number   default null
      ,i_seg_buff_busy_th    in number   default null
      ,i_seg_rowlock_w_th    in number   default null
      ,i_seg_itl_waits_th    in number   default null
      ,i_seg_cr_bks_rc_th    in number   default null
      ,i_seg_cu_bks_rc_th    in number   default null
      ,i_all_init            in varchar2 default null
      ,i_old_sql_capture_mth in varchar2 default null
      ,i_pin_statspack       in varchar2 default null
      ,i_modify_parameter    in varchar2 default 'FALSE'
      )
      RETURN integer;

   procedure MODIFY_STATSPACK_PARAMETER
      ( i_dbid                in  number   default null
      , i_instance_number     in  number   default null
      , i_snap_level          in  number   default null
      , i_session_id          in  number   default null
      , i_ucomment            in  varchar2 default null
      , i_num_sql             in  number   default null
      , i_executions_th       in  number   default null
      , i_parse_calls_th      in  number   default null
      , i_disk_reads_th       in  number   default null
      , i_buffer_gets_th      in  number   default null
      , i_sharable_mem_th     in  number   default null
      , i_version_count_th    in  number   default null
      , i_seg_phy_reads_th    in  number   default null
      , i_seg_log_reads_th    in  number   default null
      , i_seg_buff_busy_th    in  number   default null
      , i_seg_rowlock_w_th    in  number   default null
      , i_seg_itl_waits_th    in  number   default null
      , i_seg_cr_bks_rc_th    in  number   default null
      , i_seg_cu_bks_rc_th    in  number   default null
      , i_all_init            in  varchar2 default null
      , i_old_sql_capture_mth in  varchar2 default null
      , i_pin_statspack       in  varchar2 default null
      , i_modify_parameter    in  varchar2 default 'TRUE'
      );

   procedure QAM_STATSPACK_PARAMETER
      ( i_dbid                in  number   default null
      , i_instance_number     in  number   default null
      , i_snap_level          in  number   default null
      , i_session_id          in  number   default null
      , i_ucomment            in  varchar2 default null
      , i_num_sql             in  number   default null
      , i_executions_th       in  number   default null
      , i_parse_calls_th      in  number   default null
      , i_disk_reads_th       in  number   default null
      , i_buffer_gets_th      in  number   default null
      , i_sharable_mem_th     in  number   default null
      , i_version_count_th    in  number   default null
      , i_seg_phy_reads_th    in  number   default null
      , i_seg_log_reads_th    in  number   default null
      , i_seg_buff_busy_th    in  number   default null
      , i_seg_rowlock_w_th    in  number   default null
      , i_seg_itl_waits_th    in  number   default null
      , i_seg_cr_bks_rc_th    in  number   default null
      , i_seg_cu_bks_rc_th    in  number   default null
      , i_all_init            in  varchar2 default null
      , i_old_sql_capture_mth in  varchar2 default null
      , i_pin_statspack       in  varchar2 default null
      , i_modify_parameter    in  varchar2 default 'FALSE'
      , o_snap_level          out number
      , o_session_id          out number
      , o_ucomment            out varchar2
      , o_num_sql             out number
      , o_executions_th       out number
      , o_parse_calls_th      out number
      , o_disk_reads_th       out number
      , o_buffer_gets_th      out number
      , o_sharable_mem_th     out number
      , o_version_count_th    out number
      , o_seg_phy_reads_th    out number
      , o_seg_log_reads_th    out number
      , o_seg_buff_busy_th    out number
      , o_seg_rowlock_w_th    out number
      , o_seg_itl_waits_th    out number
      , o_seg_cr_bks_rc_th    out number
      , o_seg_cu_bks_rc_th    out number
      , o_all_init            out varchar2
      , o_old_sql_capture_mth out varchar2
      , o_pin_statspack       out varchar2
      );

   procedure VERIFY_SNAP_ID
      ( i_snap_id         IN  number
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      );

   procedure VERIFY_DBID_INSTANCE_NUMBER
      ( i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      );

   function GET_SNAP_ID
      ( i_snap_time       IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer;

   function MAKE_BASELINE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer;

   procedure MAKE_BASELINE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      );

   function MAKE_BASELINE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer;

   procedure MAKE_BASELINE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      );

   function CLEAR_BASELINE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer;

   procedure CLEAR_BASELINE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      );

   function CLEAR_BASELINE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer;

   procedure CLEAR_BASELINE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      );

   function PURGE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer;

   procedure PURGE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      );

   function PURGE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer;

    procedure PURGE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      );

   function PURGE
      ( i_purge_before_date IN  date
      , i_extended_purge    IN  boolean default FALSE
      , i_dbid              IN  number  default null
      , i_instance_number   IN  number  default null
      )
      RETURN integer;

   procedure PURGE
      ( i_purge_before_date IN  date
      , i_extended_purge    IN  boolean default FALSE
      , i_dbid              IN  number  default null
      , i_instance_number   IN  number  default null
      );

   function PURGE
      ( i_num_days        IN  number
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer;

   procedure PURGE
      ( i_num_days        IN  number
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      );

   function V1024
      ( i_num             IN  number
      , i_unit            IN  varchar2
      , i_min_unit        IN  varchar2
      , i_precision       IN  integer
      , i_mag             IN  integer
      )
      RETURN varchar2;

end STATSPACK;
/
show errors

/* ---------------------------------------------------------------------- */

prompt Creating Package Body STATSPACK...

create or replace package body STATSPACK as

  /*  Define package variables.
      Variables prefixed with p_ are package variables.
  */
   p_snap_id               integer;                 /* snapshot id           */
   p_instance_number       number;                  /* instance number       */
   p_instance_name         varchar2(16);            /* instance name         */
   p_startup_time          date;                    /* instance startup time */
   p_parallel              varchar2(3);             /* parallel server       */
   p_version               varchar2(17);            /* Oracle release        */
   p_dbid                  number;                  /* database id           */
   p_host_name             varchar2(64);            /* host instance is on   */
   p_platform_name         varchar2(101);           /* host platform         */
   p_name                  varchar2(9);             /* database name         */
   p_new_sga               integer;     /* Instance bounced since last snap? */
   tmp_int                 integer;                 /* initialise defaults   */
   p_def_snap_level        number    default 5;     /* default snapshot lvl  */
   p_def_session_id        number    default 0;     /* default session id    */
   p_def_ucomment          varchar2(160) default null;
   p_def_pin_statspack     varchar2(10)  default 'TRUE';
   p_def_last_modified     date          default SYSDATE;
   /* Below are the default threshold (_th) values for choosing SQL statements
      to store in the stats$sqlsummary table - these statements will typically 
      be the statements using the most resources.
   */
   p_def_num_sql           number default 50;        /* Num. SQL statements  */
   p_def_executions_th     number default 100;       /* Num. executions      */
   p_def_parse_calls_th    number default 1000;      /* Num. parse calls     */
   p_def_disk_reads_th     number default 1000;      /* Num. disk reads      */
   p_def_buffer_gets_th    number default 10000;     /* Num. buf gets        */
   p_def_sharable_mem_th   number default 1048576;   /* Sharable memory      */
   p_def_version_count_th  number default 20;        /* Child Cursors        */
   /* Below are the default threshold (_th) values for choosing Segment stats
      to store in the stats$seg_stat table - these segments will typically 
      be the segments using the most resources or segments having the most 
      contention.
   */
   p_def_seg_phy_reads_th      number default 1000;   /* Num. physical reads */
   p_def_seg_log_reads_th      number default 10000;  /* Num. logical reads  */
   p_def_seg_buff_busy_th      number default 100; /* Num. buffer busy waits */
   p_def_seg_rowlock_w_th      number default 100;    /* Num. row lock waits */
   p_def_seg_itl_waits_th      number default 100;         /* Num. ITL waits */
   p_def_seg_cr_bks_rc_th      number default 1000;  /* Num. RAC CR bks done */
   p_def_seg_cu_bks_rc_th      number default 1000;  /* Num. RAC CU bks done */
   /*  Default threshold for SGASTAT capture
   */
   p_def_sgastat_pool_pct_th   number default 1;         /* % of *pool* size */
   /*  Default threshold for PGA memory capture
   */
   p_def_proc_mem_th           number default 1;      /* process size in MB */
   p_def_num_procs             number default 20;  /* #processes to capture */
   /*  Capture all init.ora's or just default?
   */
   p_def_all_init              varchar2(10)  default 'FALSE';
   /* Capture data using stats$v$sqlxs, or stats$v$sqlstat_summary 
   */
   p_def_old_sql_capture_mth   varchar2(10)  default 'FALSE';

   cursor get_instance is
   select instance_number, instance_name
        , startup_time, parallel, version
        , host_name
     from v$instance;

   cursor get_db is
   select dbid, name, platform_name
     from v$database;

   /* ------------------------------------------------------------------- */

   procedure SNAP
      (i_snap_level          in number   default null
      ,i_session_id          in number   default null
      ,i_ucomment            in varchar2 default null
      ,i_num_sql             in number   default null
      ,i_executions_th       in number   default null
      ,i_parse_calls_th      in number   default null
      ,i_disk_reads_th       in number   default null
      ,i_buffer_gets_th      in number   default null
      ,i_sharable_mem_th     in number   default null
      ,i_version_count_th    in number   default null
      ,i_seg_phy_reads_th    in number   default null
      ,i_seg_log_reads_th    in number   default null
      ,i_seg_buff_busy_th    in number   default null
      ,i_seg_rowlock_w_th    in number   default null
      ,i_seg_itl_waits_th    in number   default null
      ,i_seg_cr_bks_rc_th    in number   default null
      ,i_seg_cu_bks_rc_th    in number   default null
      ,i_all_init            in varchar2 default null
      ,i_old_sql_capture_mth in varchar2 default null
      ,i_pin_statspack       in varchar2 default null
      ,i_modify_parameter    in varchar2 default 'FALSE'
      )
   is 

   /*  Takes a snapshot by calling the SNAP function, and discards 
       the snapshot id.  This is useful when automating taking 
       snapshots from dbms_job
   */   

   l_snap_id number;

   begin
     l_snap_id := statspack.snap  ( i_snap_level, i_session_id, i_ucomment 
                                  , i_num_sql
                                  , i_executions_th 
                                  , i_parse_calls_th
                                  , i_disk_reads_th
                                  , i_buffer_gets_th
                                  , i_sharable_mem_th
                                  , i_version_count_th
                                  , i_seg_phy_reads_th
                                  , i_seg_log_reads_th
                                  , i_seg_buff_busy_th
                                  , i_seg_rowlock_w_th
                                  , i_seg_itl_waits_th
                                  , i_seg_cr_bks_rc_th
                                  , i_seg_cu_bks_rc_th
                                  , i_all_init
                                  , i_old_sql_capture_mth
                                  , i_pin_statspack 
                                  , i_modify_parameter);
   end SNAP;


   /* ------------------------------------------------------------------- */

   procedure MODIFY_STATSPACK_PARAMETER
      ( i_dbid                in  number   default null
      , i_instance_number     in  number   default null
      , i_snap_level          in  number   default null
      , i_session_id          in  number   default null
      , i_ucomment            in  varchar2 default null
      , i_num_sql             in  number   default null
      , i_executions_th       in  number   default null
      , i_parse_calls_th      in  number   default null
      , i_disk_reads_th       in  number   default null
      , i_buffer_gets_th      in  number   default null
      , i_sharable_mem_th     in  number   default null
      , i_version_count_th    in  number   default null
      , i_seg_phy_reads_th    in  number   default null
      , i_seg_log_reads_th    in  number   default null
      , i_seg_buff_busy_th    in  number   default null
      , i_seg_rowlock_w_th    in  number   default null
      , i_seg_itl_waits_th    in  number   default null
      , i_seg_cr_bks_rc_th    in  number   default null
      , i_seg_cu_bks_rc_th    in  number   default null
      , i_all_init            in  varchar2 default null
      , i_old_sql_capture_mth in  varchar2 default null
      , i_pin_statspack       in  varchar2 default null
      , i_modify_parameter    in  varchar2 default 'TRUE'
      )
      is
      /*  Calls QAM with the modify flag, and discards the
          output variables
      */
      l_snap_level                 number;
      l_session_id                 number;
      l_ucomment                   varchar2(160);
      l_num_sql                    number;
      l_executions_th              number;
      l_parse_calls_th             number;
      l_disk_reads_th              number;
      l_buffer_gets_th             number;
      l_sharable_mem_th            number;
      l_version_count_th           number;
      l_seg_phy_reads_th           number;
      l_seg_log_reads_th           number;
      l_seg_buff_busy_th           number;
      l_seg_rowlock_w_th           number;
      l_seg_itl_waits_th           number;
      l_seg_cr_bks_rc_th           number;
      l_seg_cu_bks_rc_th           number;
      l_all_init                   varchar2(5);
      l_old_sql_capture_mth        varchar2(10);
      l_pin_statspack              varchar2(10);

    begin

      statspack.qam_statspack_parameter( i_dbid
                                       , i_instance_number
                                       , i_snap_level
                                       , i_session_id
                                       , i_ucomment
                                       , i_num_sql
                                       , i_executions_th
                                       , i_parse_calls_th
                                       , i_disk_reads_th
                                       , i_buffer_gets_th
                                       , i_sharable_mem_th
                                       , i_version_count_th
                                       , i_seg_phy_reads_th
                                       , i_seg_log_reads_th
                                       , i_seg_buff_busy_th
                                       , i_seg_rowlock_w_th
                                       , i_seg_itl_waits_th
                                       , i_seg_cr_bks_rc_th
                                       , i_seg_cu_bks_rc_th
                                       , i_all_init
                                       , i_old_sql_capture_mth
                                       , i_pin_statspack
                                       , 'TRUE'
                                       , l_snap_level
                                       , l_session_id
                                       , l_ucomment
                                       , l_num_sql
                                       , l_executions_th
                                       , l_parse_calls_th
                                       , l_disk_reads_th
                                       , l_buffer_gets_th
                                       , l_sharable_mem_th
                                       , l_version_count_th
                                       , l_seg_phy_reads_th
                                       , l_seg_log_reads_th
                                       , l_seg_buff_busy_th
                                       , l_seg_rowlock_w_th
                                       , l_seg_itl_waits_th
                                       , l_seg_cr_bks_rc_th
                                       , l_seg_cu_bks_rc_th
                                       , l_all_init
                                       , l_old_sql_capture_mth
                                       , l_pin_statspack);

      /*  As we have explicity been requested to change the parameters, 
          independently of taking a snapshot, commit
      */
      commit;

   end MODIFY_STATSPACK_PARAMETER;

   /* ------------------------------------------------------------------- */

   procedure QAM_STATSPACK_PARAMETER
      ( i_dbid                in  number   default null
      , i_instance_number     in  number   default null
      , i_snap_level          in  number   default null
      , i_session_id          in  number   default null
      , i_ucomment            in  varchar2 default null
      , i_num_sql             in  number   default null
      , i_executions_th       in  number   default null
      , i_parse_calls_th      in  number   default null
      , i_disk_reads_th       in  number   default null
      , i_buffer_gets_th      in  number   default null
      , i_sharable_mem_th     in  number   default null
      , i_version_count_th    in  number   default null
      , i_seg_phy_reads_th    in  number   default null
      , i_seg_log_reads_th    in  number   default null
      , i_seg_buff_busy_th    in  number   default null
      , i_seg_rowlock_w_th    in  number   default null
      , i_seg_itl_waits_th    in  number   default null
      , i_seg_cr_bks_rc_th    in  number   default null
      , i_seg_cu_bks_rc_th    in  number   default null
      , i_all_init            in  varchar2 default null
      , i_old_sql_capture_mth in  varchar2 default null
      , i_pin_statspack       in  varchar2 default null
      , i_modify_parameter    in  varchar2 default 'FALSE'
      , o_snap_level          out number
      , o_session_id          out number
      , o_ucomment            out varchar2
      , o_num_sql             out number
      , o_executions_th       out number
      , o_parse_calls_th      out number
      , o_disk_reads_th       out number
      , o_buffer_gets_th      out number
      , o_sharable_mem_th     out number
      , o_version_count_th    out number
      , o_seg_phy_reads_th    out number
      , o_seg_log_reads_th    out number
      , o_seg_buff_busy_th    out number
      , o_seg_rowlock_w_th    out number
      , o_seg_itl_waits_th    out number
      , o_seg_cr_bks_rc_th    out number
      , o_seg_cu_bks_rc_th    out number
      , o_all_init            out varchar2
      , o_old_sql_capture_mth out varchar2
      , o_pin_statspack       out varchar2
      )
     is
   /* Query And Modify statspack parameter procedure, allows query 
      and/or user modification of the statistics collection parameters 
      for an instance.  If there are no pre-existing parameters for 
      an instance, insert the Oracle defaults.
   */

     l_instance_number number;
     l_dbid            number;
     ui_all_init       varchar2(5);
     l_params_exist    varchar2(1);

     begin

       /*  Setup dbid/instance_number.  Use supplied values if any, and
           default to current dbid/instance number where null.
           Check values supplied exist in stats$database_instance;
           do not allow setting the values on RAC instances if a
           row for the instance does not already exist in 
           stats$database_instance.
       */

       begin

         select nvl(i_dbid,            p_dbid)
              , nvl(i_instance_number, p_instance_number)
           into l_dbid
              , l_instance_number
           from stats$statspack_parameter
          where dbid            = nvl(i_dbid, p_dbid)
            and instance_number = nvl(i_instance_number, p_instance_number);

       exception when NO_DATA_FOUND then

           if    ( i_dbid is null  and i_instance_number is null )
             or ( i_dbid = p_dbid and i_instance_number = p_instance_number ) then
               -- current instance - valid pair, ok for no data to be found
               l_dbid            := p_dbid;
               l_instance_number := p_instance_number;
           else
               raise_application_error
                (-20100,'QAM_STATSPACK_PARAMETER dbid/instance number combination does not exist');
           end if;

       when others then raise;

       end;

       /*  Upper case any input vars which are inserted  */
       ui_all_init := upper(i_all_init);

       if (   (i_modify_parameter is null)
           or (upper(i_modify_parameter) = 'FALSE')  ) then

       /* Query values, if none exist, insert the defaults tempered 
          with variables supplied */

         begin

           select nvl(i_session_id,       session_id)
                , nvl(i_snap_level,       snap_level)
                , nvl(i_ucomment,         ucomment)
                , nvl(i_num_sql,          num_sql)
                , nvl(i_executions_th,    executions_th)
                , nvl(i_parse_calls_th,   parse_calls_th)
                , nvl(i_disk_reads_th,    disk_reads_th)
                , nvl(i_buffer_gets_th,   buffer_gets_th)
                , nvl(i_sharable_mem_th,  sharable_mem_th)
                , nvl(i_version_count_th, version_count_th)
                , nvl(i_seg_phy_reads_th, seg_phy_reads_th)
                , nvl(i_seg_log_reads_th, seg_log_reads_th)
                , nvl(i_seg_buff_busy_th, seg_buff_busy_th)
                , nvl(i_seg_rowlock_w_th, seg_rowlock_w_th)
                , nvl(i_seg_itl_waits_th, seg_itl_waits_th)
                , nvl(i_seg_cr_bks_rc_th, seg_cr_bks_rc_th)
                , nvl(i_seg_cu_bks_rc_th, seg_cu_bks_rc_th)
                , nvl(ui_all_init,        all_init)
                , nvl(upper(i_old_sql_capture_mth), old_sql_capture_mth)
                , nvl(i_pin_statspack,    pin_statspack)
             into o_session_id
                , o_snap_level
                , o_ucomment
                , o_num_sql
                , o_executions_th
                , o_parse_calls_th
                , o_disk_reads_th
                , o_buffer_gets_th
                , o_sharable_mem_th
                , o_version_count_th
                , o_seg_phy_reads_th
                , o_seg_log_reads_th
                , o_seg_buff_busy_th
                , o_seg_rowlock_w_th
                , o_seg_itl_waits_th
                , o_seg_cr_bks_rc_th
                , o_seg_cu_bks_rc_th
                , o_all_init
                , o_old_sql_capture_mth
                , o_pin_statspack
             from stats$statspack_parameter
            where instance_number = l_instance_number
              and dbid            = l_dbid;

         exception
           when NO_DATA_FOUND then
             insert into stats$statspack_parameter
                  ( dbid
                  , instance_number
                  , session_id
                  , snap_level
                  , ucomment
                  , num_sql
                  , executions_th
                  , parse_calls_th
                  , disk_reads_th
                  , buffer_gets_th
                  , sharable_mem_th
                  , version_count_th
                  , seg_phy_reads_th
                  , seg_log_reads_th
                  , seg_buff_busy_th
                  , seg_rowlock_w_th
                  , seg_itl_waits_th
                  , seg_cr_bks_rc_th
                  , seg_cu_bks_rc_th
                  , all_init
                  , old_sql_capture_mth
                  , pin_statspack
                  , last_modified
                  )
             values 
                  ( l_dbid
                  , l_instance_number
                  , p_def_session_id
                  , p_def_snap_level
                  , p_def_ucomment
                  , p_def_num_sql
                  , p_def_executions_th
                  , p_def_parse_calls_th
                  , p_def_disk_reads_th
                  , p_def_buffer_gets_th
                  , p_def_sharable_mem_th
                  , p_def_version_count_th
                  , p_def_seg_phy_reads_th
                  , p_def_seg_log_reads_th
                  , p_def_seg_buff_busy_th
                  , p_def_seg_rowlock_w_th
                  , p_def_seg_itl_waits_th
                  , p_def_seg_cr_bks_rc_th
                  , p_def_seg_cu_bks_rc_th
                  , p_def_all_init
                  , p_def_old_sql_capture_mth
                  , p_def_pin_statspack
                  , SYSDATE
                  )
          returning nvl(i_session_id,       p_def_session_id)
                  , nvl(i_snap_level,       p_def_snap_level)
                  , nvl(i_ucomment,         p_def_ucomment)
                  , nvl(i_num_sql,          p_def_num_sql)
                  , nvl(i_executions_th,    p_def_executions_th)
                  , nvl(i_parse_calls_th,   p_def_parse_calls_th)
                  , nvl(i_disk_reads_th,    p_def_disk_reads_th)
                  , nvl(i_buffer_gets_th,   p_def_buffer_gets_th)
                  , nvl(i_sharable_mem_th,  p_def_sharable_mem_th)
                  , nvl(i_version_count_th, p_def_version_count_th)
                  , nvl(i_seg_phy_reads_th, p_def_seg_phy_reads_th)
                  , nvl(i_seg_log_reads_th, p_def_seg_log_reads_th)
                  , nvl(i_seg_buff_busy_th, p_def_seg_buff_busy_th)
                  , nvl(i_seg_rowlock_w_th, p_def_seg_rowlock_w_th)
                  , nvl(i_seg_itl_waits_th, p_def_seg_itl_waits_th)
                  , nvl(i_seg_cr_bks_rc_th, p_def_seg_cr_bks_rc_th)
                  , nvl(i_seg_cu_bks_rc_th, p_def_seg_cu_bks_rc_th)
                  , nvl(ui_all_init,        p_def_all_init)
                  , nvl(upper(i_old_sql_capture_mth), p_def_old_sql_capture_mth)
                  , nvl(i_pin_statspack,    p_def_pin_statspack)
               into o_session_id
                  , o_snap_level
                  , o_ucomment
                  , o_num_sql
                  , o_executions_th
                  , o_parse_calls_th
                  , o_disk_reads_th
                  , o_buffer_gets_th
                  , o_sharable_mem_th
                  , o_version_count_th
                  , o_seg_phy_reads_th
                  , o_seg_log_reads_th
                  , o_seg_buff_busy_th
                  , o_seg_rowlock_w_th
                  , o_seg_itl_waits_th
                  , o_seg_cr_bks_rc_th
                  , o_seg_cu_bks_rc_th
                  , o_all_init
                  , o_old_sql_capture_mth
                  , o_pin_statspack;

         end; /* don't modify parameter values */

       elsif upper(i_modify_parameter) = 'TRUE' then

       /* modify values, if none exist, insert the defaults tempered 
          with the variables supplied */

         begin

           update stats$statspack_parameter
              set session_id       = nvl(i_session_id,       session_id)
                , snap_level       = nvl(i_snap_level,       snap_level)
                , ucomment         = nvl(i_ucomment,         ucomment)
                , num_sql          = nvl(i_num_sql,          num_sql)
                , executions_th    = nvl(i_executions_th,    executions_th)
                , parse_calls_th   = nvl(i_parse_calls_th,   parse_calls_th)
                , disk_reads_th    = nvl(i_disk_reads_th,    disk_reads_th)
                , buffer_gets_th   = nvl(i_buffer_gets_th,   buffer_gets_th)
                , sharable_mem_th  = nvl(i_sharable_mem_th,  sharable_mem_th)
                , version_count_th = nvl(i_version_count_th, version_count_th)
                , seg_phy_reads_th = nvl(i_seg_phy_reads_th, seg_phy_reads_th)
                , seg_log_reads_th = nvl(i_seg_log_reads_th, seg_log_reads_th)
                , seg_buff_busy_th = nvl(i_seg_buff_busy_th, seg_buff_busy_th)
                , seg_rowlock_w_th = nvl(i_seg_rowlock_w_th, seg_rowlock_w_th)
                , seg_itl_waits_th = nvl(i_seg_itl_waits_th, seg_itl_waits_th)
                , seg_cr_bks_rc_th = nvl(i_seg_cr_bks_rc_th, seg_cr_bks_rc_th)
                , seg_cu_bks_rc_th = nvl(i_seg_cu_bks_rc_th, seg_cu_bks_rc_th)
                , all_init         = nvl(ui_all_init,        all_init)
                , old_sql_capture_mth = nvl(upper(i_old_sql_capture_mth), old_sql_capture_mth)
                , pin_statspack    = nvl(i_pin_statspack,    pin_statspack)   
            where instance_number  = l_instance_number
              and dbid             = l_dbid
        returning session_id
                , snap_level
                , ucomment
                , num_sql
                , executions_th
                , parse_calls_th
                , disk_reads_th
                , buffer_gets_th
                , sharable_mem_th
                , version_count_th
                , seg_phy_reads_th
                , seg_log_reads_th
                , seg_buff_busy_th
                , seg_rowlock_w_th
                , seg_itl_waits_th
                , seg_cr_bks_rc_th
                , seg_cu_bks_rc_th
                , all_init
                , old_sql_capture_mth
                , pin_statspack
             into o_session_id
                , o_snap_level
                , o_ucomment
                , o_num_sql
                , o_executions_th
                , o_parse_calls_th
                , o_disk_reads_th
                , o_buffer_gets_th
                , o_sharable_mem_th
                , o_version_count_th
                , o_seg_phy_reads_th
                , o_seg_log_reads_th
                , o_seg_buff_busy_th
                , o_seg_rowlock_w_th
                , o_seg_itl_waits_th
                , o_seg_cr_bks_rc_th
                , o_seg_cu_bks_rc_th
                , o_all_init
                , o_old_sql_capture_mth
                , o_pin_statspack;

             if SQL%ROWCOUNT = 0 then

             -- First snapshot, but want to set parameters

               insert into stats$statspack_parameter
                    ( dbid
                    , instance_number
                    , session_id
                    , snap_level
                    , ucomment
                    , num_sql
                    , executions_th
                    , parse_calls_th
                    , disk_reads_th
                    , buffer_gets_th
                    , sharable_mem_th
                    , version_count_th
                    , seg_phy_reads_th
                    , seg_log_reads_th
                    , seg_buff_busy_th
                    , seg_rowlock_w_th
                    , seg_itl_waits_th
                    , seg_cr_bks_rc_th
                    , seg_cu_bks_rc_th
                    , all_init
                    , old_sql_capture_mth
                    , pin_statspack
                    , last_modified
                    )
              values 
                    ( l_dbid
                    , l_instance_number
                    , nvl(i_session_id,       p_def_session_id)
                    , nvl(i_snap_level,       p_def_snap_level)
                    , nvl(i_ucomment,         p_def_ucomment)
                    , nvl(i_num_sql,          p_def_num_sql)
                    , nvl(i_executions_th,    p_def_executions_th)
                    , nvl(i_parse_calls_th,   p_def_parse_calls_th)
                    , nvl(i_disk_reads_th,    p_def_disk_reads_th)
                    , nvl(i_buffer_gets_th,   p_def_buffer_gets_th)
                    , nvl(i_sharable_mem_th,  p_def_sharable_mem_th)
                    , nvl(i_version_count_th, p_def_version_count_th)
                    , nvl(i_seg_phy_reads_th, p_def_seg_phy_reads_th)
                    , nvl(i_seg_log_reads_th, p_def_seg_log_reads_th)
                    , nvl(i_seg_buff_busy_th, p_def_seg_buff_busy_th)
                    , nvl(i_seg_rowlock_w_th, p_def_seg_rowlock_w_th)
                    , nvl(i_seg_itl_waits_th, p_def_seg_itl_waits_th)
                    , nvl(i_seg_cr_bks_rc_th, p_def_seg_cr_bks_rc_th)
                    , nvl(i_seg_cu_bks_rc_th, p_def_seg_cu_bks_rc_th)
                    , nvl(ui_all_init,        p_def_all_init)
                    , nvl(upper(i_old_sql_capture_mth), p_def_old_sql_capture_mth)
                    , nvl(i_pin_statspack,    p_def_pin_statspack)
                    , SYSDATE
                    )
            returning session_id
                    , snap_level
                    , ucomment
                    , num_sql
                    , executions_th
                    , parse_calls_th
                    , disk_reads_th
                    , buffer_gets_th
                    , sharable_mem_th
                    , version_count_th
                    , seg_phy_reads_th
                    , seg_log_reads_th
                    , seg_buff_busy_th
                    , seg_rowlock_w_th
                    , seg_itl_waits_th
                    , seg_cr_bks_rc_th
                    , seg_cu_bks_rc_th
                    , all_init
                    , old_sql_capture_mth
                    , pin_statspack
                 into o_session_id
                    , o_snap_level
                    , o_ucomment
                    , o_num_sql
                    , o_executions_th
                    , o_parse_calls_th
                    , o_disk_reads_th
                    , o_buffer_gets_th
                    , o_sharable_mem_th
                    , o_version_count_th
                    , o_seg_phy_reads_th
                    , o_seg_log_reads_th
                    , o_seg_buff_busy_th
                    , o_seg_rowlock_w_th
                    , o_seg_itl_waits_th
                    , o_seg_cr_bks_rc_th
                    , o_seg_cu_bks_rc_th
                    , o_all_init
                    , o_old_sql_capture_mth
                    , o_pin_statspack;

                end if;

         end; /* modify values */

       else

       /* error */
          raise_application_error
            (-20100,'QAM_STATSPACK_PARAMETER i_modify_parameter value is invalid');
       end if; /* modify */

     end QAM_STATSPACK_PARAMETER;

   /* ------------------------------------------------------------------- */

     procedure DEFAULT_DBID_INSTANCE_NUMBER
      ( i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      , o_dbid            OUT number
      , o_instance_number OUT number
      ) is

     /* Defaults the DB Id and Instance number to the database instance
        currently connected to, if they are not explicitly provided
        Does not check whether any snapshots exist for the instance.

        Should only be called by Statspack package or Statspack SQL scripts, 
        not by users directly
     */

     begin

        if i_dbid is null and i_instance_number is null then
             o_dbid            := p_dbid;
             o_instance_number := p_instance_number;
        elsif     (i_dbid is     null and i_instance_number is not null)
              or  (i_dbid is not null and i_instance_number is     null) then

           raise_application_error(-20200,'Must specify both DB Id and Instance Number, not DB Id or Instance Number');
        else
             o_dbid            := i_dbid;
             o_instance_number := i_instance_number;

        end if;

     end DEFAULT_DBID_INSTANCE_NUMBER;

   /* ------------------------------------------------------------------- */

     procedure VERIFY_SNAP_ID
      ( i_snap_id         IN  number
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) is

     /* Checks the specified snap id, dbid and instance_number to see whether
        there are any rows in the stats$snapshot table which meet that
        criteria.  If not, errors.

        Should only be called by Statspack package or Statspack SQL scripts, 
        not by users directly
     */

     cursor csnapid( vsnap_id stats$snapshot.snap_id%type
                   , vdbid    stats$database_instance.dbid%type
                   , vinst    stats$database_instance.instance_number%type) is
       select snap_id
         from stats$snapshot
        where snap_id         = vsnap_id
          and dbid            = vdbid
          and instance_number = vinst;

     l_snap_id         stats$snapshot.snap_id%type;
     l_dbid            stats$database_instance.dbid%type;
     l_instance_number stats$database_instance.instance_number%type;

     begin

         default_dbid_instance_number( i_dbid            => i_dbid
                                     , i_instance_number => i_instance_number
                                     , o_dbid            => l_dbid
                                     , o_instance_number => l_instance_number);

         open csnapid(i_snap_id, l_dbid, l_instance_number);

         fetch csnapid into l_snap_id;

         if csnapid%notfound then
             raise_application_error(-20200,'Snapshot ' ||i_snap_id||' does not exist for DB Id/Instance '|| l_dbid || '/' || l_instance_number);
         end if;

         close csnapid;

    end VERIFY_SNAP_ID;

   /* ------------------------------------------------------------------- */

     procedure VERIFY_DBID_INSTANCE_NUMBER
      ( i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) is

     /* Checks whether there are any rows in the stats$database_instance table
        for the specified dbid and instance_number.  If not, errors.

        DOES NOT DEFAULT DBID / INSTANCE NUMBER

        Should only be called by Statspack package or Statspack SQL scripts, 
        not by users directly
     */

     l_snap_id stats$snapshot.snap_id%type;

     cursor cdbin( vdbid stats$database_instance.dbid%type
                 , vinst stats$database_instance.instance_number%type) is
       select 1
         from stats$database_instance
        where dbid            = vdbid
          and instance_number = vinst
          and rownum          = 1;

     l_cnt number := 0;

     begin

        open cdbin(i_dbid, i_instance_number);

        fetch cdbin into l_cnt;

        if cdbin%notfound then
           raise_application_error(-20200,'Database Instance specified (DB Id/Instance '|| i_dbid || '/' || i_instance_number || ') does not exist in STATS$DATABASE_INSTANCE');
        end if;

        close cdbin;

    end VERIFY_DBID_INSTANCE_NUMBER;

   /* ------------------------------------------------------------------- */

     function GET_SNAP_ID
      ( i_snap_time       IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) RETURN integer is

     /*  Determines the snap id which is closest to the snap time specified, 
         for that database instance.  The closest snap id can have a snap time
         earlier or later than the specified snap time.
     */

     cursor csnaps( vdbid stats$database_instance.dbid%type
                  , vinst stats$database_instance.instance_number%type) is
       select snap_id, snap_time
         from stats$snapshot
        where instance_number = vinst
          and dbid            = vdbid
        order by snap_id;

     l_snap_id1        stats$snapshot.snap_id%type := 0;
     l_snap_id2        stats$snapshot.snap_id%type := 0;
     return_snap       stats$snapshot.snap_id%type;
     l_snap_time1      stats$snapshot.snap_time%type;
     l_snap_time2      stats$snapshot.snap_time%type;
     l_dbid            stats$database_instance.dbid%type;
     l_instance_number stats$database_instance.instance_number%type;

     begin

         default_dbid_instance_number( i_dbid            => i_dbid
                                     , i_instance_number => i_instance_number
                                     , o_dbid            => l_dbid
                                     , o_instance_number => l_instance_number);

         open csnaps(l_dbid, l_instance_number);

         loop

           -- Fetch a snapshot id and date
           fetch csnaps into l_snap_id1, l_snap_time1;

           if csnaps%notfound then
             if csnaps%rowcount = 0 then
               raise_application_error(-20200,'No snapshots exist for DB Id/Instance Number '|| l_dbid || '/' || l_instance_number);
             else
               -- Only one snapshot exists OR we have iterated through all 
               -- snapshots and none matched, so return this snap
               return_snap := l_snap_id1;
               exit;
             end if;
           end if; -- %notfound

           -- Check date to see if it will fit

           if (csnaps%rowcount = 1) and (l_snap_time1 >= i_snap_time) then
              -- If first row, and date retrieved >= date specified, return it

              return_snap := l_snap_id1;
              exit;

           elsif csnaps%rowcount >= 2 then
              -- There are two dates

              if     (l_snap_time1 >= i_snap_time)
                 and (i_snap_time >= l_snap_time2) then
                 -- Specified date is between current and prev date (inclusive).
                 -- Return the snap time closest to that specified

                 if   (l_snap_time1 - i_snap_time) 
                    < (i_snap_time - l_snap_time2) then
                   return_snap := l_snap_id1;
                 else
                   return_snap := l_snap_id2;
                 end if;
                 exit;

              end if;  -- test for date between retrieved dates

           end if;  -- test for >=2 rows

           -- save old snap id and date
           l_snap_id2   := l_snap_id1;
           l_snap_time2 := l_snap_time1;

         end loop;      

         close csnaps;

         RETURN return_snap;

     end GET_SNAP_ID;

   /* ------------------------------------------------------------------- */

     function MAKE_CLEAR_BASELINE
      ( ibegin_snap       IN  number
      , iend_snap         IN  number
      , ibegin_date       IN  date
      , iend_date         IN  date
      , isnap_range       IN  boolean
      , idbid             IN  number
      , iinstance_number  IN  number
      , imake_clear       IN  varchar2
      ) RETURN integer is

     /* Either sets the baseline flag in the stats$snapshot to Y, or clears
        it (i.e. sets it to NULL), depending on whether it is called from
        MAKE_* or CLEAR_* procedure.

        Will either update just the snap id's specified, or the entire range
        of snap id's between the begin and end for that database instance.

        If begin and end dates are specified, will update the entire range
        of snapshots which fall within that date range.

        Should only be called by Statspack package or Statspack SQL scripts, 
        not by users directly
     */

     l_begin_snap      stats$snapshot.snap_id%type;
     l_end_snap        stats$snapshot.snap_id%type;
     l_bs_time         stats$snapshot.snap_time%type;
     l_es_time         stats$snapshot.snap_time%type;
     l_bu_time1        stats$snapshot.snap_time%type;
     l_eu_time1        stats$snapshot.snap_time%type;
     l_bu_time2        stats$snapshot.snap_time%type;
     l_eu_time2        stats$snapshot.snap_time%type;
     l_dbid            stats$database_instance.dbid%type;
     l_instance_number stats$database_instance.instance_number%type;
     l_rowcount        integer;

     begin

       default_dbid_instance_number( i_dbid            => idbid
                                   , i_instance_number => iinstance_number
                                   , o_dbid            => l_dbid
                                   , o_instance_number => l_instance_number);

       verify_dbid_instance_number( i_dbid            => l_dbid
                                  , i_instance_number => l_instance_number);


       if ibegin_snap is not null and iend_snap is not null then

          -- Make/clear baseline by snap_id

          if isnap_range then

             -- Update entire snapshot range between begin and end
             update stats$snapshot
                 set baseline = imake_clear
               where snap_id between ibegin_snap and iend_snap
                 and dbid               = l_dbid
                 and instance_number    = l_instance_number
                 and nvl(baseline,'A') != nvl(imake_clear,'A')
             returning count(1) into l_rowcount;

          else

             -- Update only the snapshots specified

             update stats$snapshot
                set baseline = imake_clear
              where snap_id in (ibegin_snap, iend_snap)
                and dbid               = l_dbid
                and instance_number    = l_instance_number
                and nvl(baseline,'A') != nvl(imake_clear,'A')
             returning count(1) into l_rowcount;

          end if;

          l_begin_snap := ibegin_snap;
          l_end_snap   := iend_snap;

       elsif ibegin_date is not null and iend_date is not null then

          -- update the range of snapshots identified by the dates

          update stats$snapshot
             set baseline = imake_clear
           where snap_time between ibegin_date and iend_date
             and dbid               = l_dbid
             and instance_number    = l_instance_number
             and nvl(baseline,'A') != nvl(imake_clear,'A')
          returning count(1)
               into l_rowcount;

       end if;

       commit;

       return l_rowcount;

     end MAKE_CLEAR_BASELINE;

   /* ------------------------------------------------------------------- */

     function MAKE_BASELINE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer is

     /* Creates a baseline for the specified snapshot Ids.  Can either
        baseline only the snapshots specified, or can also include the 
        entire range of snapshots between.

        Defaults the current dbid and instance number, if they are not
        specified.
     */

     l_dbid            stats$database_instance.dbid%type;
     l_instance_number stats$database_instance.instance_number%type;
     l_rowcount integer;

     begin

         default_dbid_instance_number( i_dbid            => i_dbid
                                     , i_instance_number => i_instance_number
                                     , o_dbid            => l_dbid
                                     , o_instance_number => l_instance_number);

         verify_snap_id( i_snap_id         => i_begin_snap
                       , i_dbid            => l_dbid
                       , i_instance_number => l_instance_number);

         verify_snap_id( i_snap_id         => i_end_snap
                       , i_dbid            => l_dbid
                       , i_instance_number => l_instance_number);

         l_rowcount := make_clear_baseline
                            ( ibegin_snap      => i_begin_snap
                            , iend_snap        => i_end_snap
                            , ibegin_date      => null
                            , iend_date        => null
                            , isnap_range      => i_snap_range
                            , idbid            => l_dbid
                            , iinstance_number => l_instance_number
                            , imake_clear      => 'Y');

         return l_rowcount;

     end MAKE_BASELINE;

   /* ------------------------------------------------------------------- */

     procedure MAKE_BASELINE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) is

     /* Calls the MAKE_BASELINE function which has the same input 
        parameters as this procedure, and discards the resulting 
        number of rows returned
     */

     l_rowcount integer;

     begin

         l_rowcount := make_baseline
                            ( i_begin_snap      => i_begin_snap
                            , i_end_snap        => i_end_snap
                            , i_snap_range      => i_snap_range
                            , i_dbid            => i_dbid
                            , i_instance_number => i_instance_number
                            );

     end MAKE_BASELINE;

   /* ------------------------------------------------------------------- */

     function MAKE_BASELINE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer is

     /* Creates a baseline for the specified dates.  Will basline all
        snapshots which fall within that date range.

        Defaults the current dbid and instance number, if they are not
        specified.
     */

     l_rowcount integer;

     begin

         l_rowcount := make_clear_baseline
                            ( ibegin_snap      => null
                            , iend_snap        => null
                            , ibegin_date      => i_begin_date
                            , iend_date        => i_end_date
                            , isnap_range      => null
                            , idbid            => i_dbid
                            , iinstance_number => i_instance_number
                            , imake_clear      => 'Y');

         return l_rowcount;

     end MAKE_BASELINE;

   /* ------------------------------------------------------------------- */

     procedure MAKE_BASELINE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) is

     /* Calls the MAKE_BASELINE function which has the same input 
        parameters as this procedure, and discards the resulting 
        number of rows returned
     */

     l_rowcount integer;

     begin

         l_rowcount := make_baseline
                            ( i_begin_date      => i_begin_date
                            , i_end_date        => i_end_date
                            , i_dbid            => i_dbid
                            , i_instance_number => i_instance_number
                            );

     end MAKE_BASELINE;

   /* ------------------------------------------------------------------- */

     function CLEAR_BASELINE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer is

     /* Clears the baseline for the specified snapshot Ids.  Can either
        clear the baseline only the snapshots specified, or can also include 
        the entire range of snapshots between.

        Defaults the current dbid and instance number, if they are not
        specified.
     */

     l_dbid            stats$database_instance.dbid%type;
     l_instance_number stats$database_instance.instance_number%type;
     l_rowcount integer;

     begin

         default_dbid_instance_number( i_dbid            => i_dbid
                                     , i_instance_number => i_instance_number
                                     , o_dbid            => l_dbid
                                     , o_instance_number => l_instance_number);

         verify_snap_id( i_snap_id         => i_begin_snap
                       , i_dbid            => l_dbid
                       , i_instance_number => l_instance_number);

         verify_snap_id( i_snap_id         => i_end_snap
                       , i_dbid            => l_dbid
                       , i_instance_number => l_instance_number);

         l_rowcount := make_clear_baseline
                            ( ibegin_snap      => i_begin_snap
                            , iend_snap        => i_end_snap
                            , ibegin_date      => null
                            , iend_date        => null
                            , isnap_range      => i_snap_range
                            , idbid            => l_dbid
                            , iinstance_number => l_instance_number
                            , imake_clear      => null);

          return l_rowcount;

     end CLEAR_BASELINE;

   /* ------------------------------------------------------------------- */

     procedure CLEAR_BASELINE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) is

     /* Calls the CLEAR_BASELINE function which has the same input 
        parameters as this procedure, and discards the resulting 
        number of rows returned
     */

     l_rowcount integer;

     begin

         l_rowcount := clear_baseline
                            ( i_begin_snap      => i_begin_snap
                            , i_end_snap        => i_end_snap
                            , i_snap_range      => i_snap_range
                            , i_dbid            => i_dbid
                            , i_instance_number => i_instance_number);

     end CLEAR_BASELINE;
   

   /* ------------------------------------------------------------------- */

     function CLEAR_BASELINE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer is

     /* Clears the baseline for all snapshots which fall between the 
        specified dates.

        Defaults the current dbid and instance number, if they are not
        specified.
     */

     l_rowcount integer;

     begin

         l_rowcount := make_clear_baseline
                            ( ibegin_snap      => null
                            , iend_snap        => null
                            , ibegin_date      => i_begin_date
                            , iend_date        => i_end_date
                            , isnap_range      => null
                            , idbid            => i_dbid
                            , iinstance_number => i_instance_number
                            , imake_clear      => null);

         return l_rowcount;

     end CLEAR_BASELINE;

   /* ------------------------------------------------------------------- */

     procedure CLEAR_BASELINE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) is

     /* Calls the CLEAR_BASELINE function which has the same input 
        parameters as this procedure, and discards the resulting 
        number of rows returned
     */

     l_rowcount integer;

     begin

         l_rowcount := clear_baseline
                            ( i_begin_date      => i_begin_date
                            , i_end_date        => i_end_date
                            , i_dbid            => i_dbid
                            , i_instance_number => i_instance_number);

     end CLEAR_BASELINE;

   /* ------------------------------------------------------------------- */

     function PURGE
      ( ibegin_snap        IN  number
      , iend_snap          IN  number
      , ibegin_date        IN  date
      , iend_date          IN  date
      , ipurge_before_date IN  date
      , inum_days          IN  number
      , idbid              IN  number
      , iinstance_number   IN  number
      , isnap_range        IN  boolean
      , iextended_purge    IN  boolean
      )
      RETURN integer is

     /* Purges Statspack data in either of a number of different methods, 
        depending on the parameters entered.  Baseline data is not purged.
          - if bid,eid is specified, purges by snap ids (taking into acount
            whether to purge just those snaps, or whether to purge the entire
            range
          - if begin_date and end_date aer specified, purge all snapshots
            which were taken between that date range
          - if purge_before_date is specified, purge all data older than the
            date specified
          - if num_days is specified, purges all data older than that number
            of days

        Can also specify whether to tidy-up related Statspack data such as
        the SQL Text and SQL Execution plans using the extended_purge flag

        Defaults the current dbid and instance number, if they are not
        specified.

        Should only be called by Statspack package or Statspack SQL scripts, 
        not by users directly
     */

     l_btime           stats$snapshot.snap_time%type;
     l_etime           stats$snapshot.snap_time%type;
     l_date            date;
     l_dbid            stats$database_instance.dbid%type;
     l_instance_number stats$database_instance.instance_number%type;
     l_rowcount        integer;

     begin

         default_dbid_instance_number( i_dbid            => idbid
                                     , i_instance_number => iinstance_number
                                     , o_dbid            => l_dbid
                                     , o_instance_number => l_instance_number);

       --
       --  Use RI to delete parent snapshot and all child records

       if ibegin_snap is not null and iend_snap is not null then

          -- Purge by bid, eid

          if ibegin_snap > iend_snap then
             raise_application_error
             (-20100,'Begin Snap (' || ibegin_snap || ') must be less than End Snap (' || iend_snap || ')');
          end if;

          if isnap_range then

            -- Purge entire range between (bid,eid), not just the two snaps

            delete from stats$snapshot
             where snap_id between ibegin_snap and iend_snap
               and dbid            = l_dbid
               and instance_number = l_instance_number
               and baseline       is null
            returning count(1) into l_rowcount;

          else

            -- Purge just the two snaps

            delete from stats$snapshot
             where snap_id in (ibegin_snap, iend_snap)
               and dbid            = l_dbid
               and instance_number = l_instance_number
               and baseline       is null
            returning count(1) into l_rowcount;

          end if;

       elsif ibegin_date is not null and iend_date is not null then

          -- Purge by date range

          if ibegin_date > iend_date then
             raise_application_error
             (-20100,'Begin Date (' || ibegin_date || ') must be earlier than End Date (' || iend_date || ')');
          end if;

          -- Delete stats$snapshot records, and all child records

          delete from stats$snapshot
           where snap_time between ibegin_date and iend_date
             and dbid            = l_dbid
             and instance_number = l_instance_number
             and baseline       is null
          returning count(1) into l_rowcount;

        elsif     ipurge_before_date is not null 
              or  inum_days          is not null then

          -- Either purge by purge_before_date, or num_days
          -- if num_days, translate num_days to the equivalent
          -- of a purge_before_date

          if ipurge_before_date is not null then

             if ipurge_before_date > SYSDATE   then
                raise_application_error
                (-20100,'Purge Before Date (' || ipurge_before_date || ') is in the future');
             end if;

             l_date := ipurge_before_date;

          elsif inum_days is not null then

             if inum_days <= 0 then
                raise_application_error
                 (-20100,'Number of days specified (' || inum_days || ') should be greater than 0');
             end if;

             -- Determine the closest date, and use the date

             l_date := sysdate - inum_days;

          end if;

          delete from stats$snapshot
           where dbid            = l_dbid
             and instance_number = l_instance_number
             and baseline       is null
             and snap_time       < l_date
          returning count(1) into l_rowcount;

       end if;


       if iextended_purge then
         --
         -- Purge segments which do not have RI constraints to stats$snapshot

         -- SQL text

         delete from stats$sqltext st1 
          where (st1.old_hash_value, st1.text_subset) in 
                   (select /*+ index_ffs(st) */
                           st.old_hash_value, st.text_subset 
                      from stats$sqltext st
                     where (old_hash_value, text_subset) not in
                               (select /*+ hash_aj index_ffs(ss) */
                                       distinct old_hash_value, text_subset 
                                  from stats$sql_summary ss
                               ) 
                       and st.piece = 0 
                );


         -- SQL execution plans
  
         delete from stats$sql_plan sp1
          where sp1.plan_hash_value in 
                   (select /*+ index_ffs(sp) */
                           sp.plan_hash_value
                      from stats$sql_plan sp
                     where plan_hash_value not in
                               (select /*+ hash_aj */
                                       distinct plan_hash_value
                                  from stats$sql_plan_usage spu
                               ) 
                       and sp.id = 0
                   );


         -- Segment Identifiers

         delete /*+ index_ffs(sso) */
           from stats$seg_stat_obj sso
          where (dbid, dataobj#, obj#, ts#) not in
                (select /*+ hash_aj full(ss) */
                        dbid, dataobj#, obj#, ts#
                   from stats$seg_stat ss
                );

       end if; -- extended purge

       commit;

       return l_rowcount;

     end PURGE;

   /* ------------------------------------------------------------------- */

     function PURGE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer is

     /* Purges either just the snaps specified, or the entire range.

        Can also specify whether to tidy-up related Statspack data such as
        the SQL Text and SQL Execution plans using the extended_purge flag.

        Defaults the current dbid and instance number, if they are not
        specified.
     */

     l_dbid            stats$database_instance.dbid%type;
     l_instance_number stats$database_instance.instance_number%type;
     l_rowcount integer;

     begin

         default_dbid_instance_number( i_dbid            => i_dbid
                                     , i_instance_number => i_instance_number
                                     , o_dbid            => l_dbid
                                     , o_instance_number => l_instance_number);

         verify_snap_id( i_snap_id         => i_begin_snap
                       , i_dbid            => l_dbid
                       , i_instance_number => l_instance_number);

         verify_snap_id( i_snap_id         => i_end_snap
                       , i_dbid            => l_dbid
                       , i_instance_number => l_instance_number);

         l_rowcount := purge( ibegin_snap        => i_begin_snap
                            , iend_snap          => i_end_snap
                            , ibegin_date        => null
                            , iend_date          => null
                            , ipurge_before_date => null
                            , inum_days          => null
                            , idbid              => l_dbid
                            , iinstance_number   => l_instance_number
                            , isnap_range        => i_snap_range
                            , iextended_purge    => i_extended_purge
                            );

         return l_rowcount;

     end PURGE;

   /* ------------------------------------------------------------------- */

     procedure PURGE
      ( i_begin_snap      IN  number
      , i_end_snap        IN  number
      , i_snap_range      IN  boolean default TRUE
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) is

     /* Calls the PURGE function which has the same input 
        parameters as this procedure, and discards the resulting 
        number of rows returned
     */

     l_rowcount integer;

     begin

        l_rowcount := purge( i_begin_snap       => i_begin_snap
                           , i_end_snap         => i_end_snap
                           , i_snap_range       => i_snap_range
                           , i_extended_purge   => i_extended_purge
                           , i_dbid             => i_dbid
                           , i_instance_number  => i_instance_number
                           );

     end PURGE;

   /* ------------------------------------------------------------------- */

     function PURGE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) 
      RETURN integer is

     /* Purges all snapshots taken within the specified date range.

        Can also specify whether to tidy-up related Statspack data such as
        the SQL Text and SQL Execution plans using the extended_purge flag

        Defaults the current dbid and instance number, if they are not
        specified.
     */

     l_rowcount integer;

     begin

         l_rowcount := purge( ibegin_snap        => null
                            , iend_snap          => null
                            , ibegin_date        => i_begin_date
                            , iend_date          => i_end_date
                            , ipurge_before_date => null
                            , inum_days          => null
                            , idbid              => i_dbid
                            , iinstance_number   => i_instance_number
                            , isnap_range        => null
                            , iextended_purge    => i_extended_purge
                            );

         return l_rowcount;

     end PURGE;

   /* ------------------------------------------------------------------- */

     procedure PURGE
      ( i_begin_date      IN  date
      , i_end_date        IN  date
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) is

     /* Calls the PURGE function which has the same input 
        parameters as this procedure, and discards the resulting 
        number of rows returned
     */

     l_rowcount integer;

     begin

         l_rowcount := purge( i_begin_date       => i_begin_date
                            , i_end_date         => i_end_date
                            , i_extended_purge   => i_extended_purge
                            , i_dbid             => i_dbid
                            , i_instance_number  => i_instance_number
                            );

     end PURGE;

   /* ------------------------------------------------------------------- */

     function PURGE
      ( i_purge_before_date IN  date
      , i_extended_purge    IN  boolean default FALSE
      , i_dbid              IN  number  default null
      , i_instance_number   IN  number  default null
      )
      RETURN integer is

     /* Deletes all Statspack snapshots older than the date specified
        (baselines excepted)

        Can also specify whether to tidy-up related Statspack data such as
        the SQL Text and SQL Execution plans using the extended_purge flag

        Defaults the current dbid and instance number, if they are not
        specified.
     */

     l_rowcount integer;

     begin

         l_rowcount := purge( ibegin_snap        => null
                            , iend_snap          => null
                            , ibegin_date        => null
                            , iend_date          => null
                            , ipurge_before_date => i_purge_before_date
                            , inum_days          => null
                            , idbid              => i_dbid
                            , iinstance_number   => i_instance_number
                            , isnap_range        => null
                            , iextended_purge    => i_extended_purge
                            );

         return l_rowcount;

     end PURGE;

   /* ------------------------------------------------------------------- */

     procedure PURGE
      ( i_purge_before_date IN  date
      , i_extended_purge    IN  boolean default FALSE
      , i_dbid              IN  number  default null
      , i_instance_number   IN  number  default null
      ) is

     /* Calls the PURGE function which has the same input 
        parameters as this procedure, and discards the resulting 
        number of rows returned
     */

     l_rowcount integer;

     begin

         l_rowcount := purge( i_purge_before_date => i_purge_before_date
                            , i_extended_purge    => i_extended_purge
                            , i_dbid              => i_dbid
                            , i_instance_number   => i_instance_number
                            );

     end PURGE;

   /* ------------------------------------------------------------------- */

   function PURGE
      ( i_num_days        IN  number
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      )
      RETURN integer is

     /* Deletes all Statspack snapshots older than the number of days specified
        (baselines excepted)

        Can also specify whether to tidy-up related Statspack data such as
        the SQL Text and SQL Execution plans using the extended_purge flag

        Defaults the current dbid and instance number, if they are not
        specified.
     */

     l_rowcount integer;

     begin

         l_rowcount := purge( ibegin_snap        => null
                            , iend_snap          => null
                            , ibegin_date        => null
                            , iend_date          => null
                            , ipurge_before_date => null
                            , inum_days          => i_num_days
                            , idbid              => i_dbid
                            , iinstance_number   => i_instance_number
                            , isnap_range        => null
                            , iextended_purge    => i_extended_purge
                            );

         return l_rowcount;

     end PURGE;

   /* ------------------------------------------------------------------- */

   procedure PURGE
      ( i_num_days        IN  number
      , i_extended_purge  IN  boolean default FALSE
      , i_dbid            IN  number  default null
      , i_instance_number IN  number  default null
      ) is

     /* Calls the PURGE function which has the same input 
        parameters as this procedure, and discards the resulting 
        number of rows returned
     */

     l_rowcount integer;

     begin

         l_rowcount := purge( i_num_days         => i_num_days
                            , i_extended_purge   => i_extended_purge
                            , i_dbid             => i_dbid
                            , i_instance_number  => i_instance_number
              );

     end PURGE;

   /* ------------------------------------------------------------------- */

     function V1024
      ( i_num               IN  number
      , i_unit              IN  varchar2
      , i_min_unit          IN  varchar2
      , i_precision         IN  integer
      , i_mag               IN  integer
      )
      RETURN varchar2 is
        tob integer := 1;
        tok integer;
        tom integer;
        tog integer;
        tot integer;
        top integer;
        conv varchar2(50) := ' ';
        to_conv number := i_num;

        function to_unit(conv_divisor IN integer, conv_unit in varchar2)
        return varchar2 is
        o_num varchar2(50) := '0.0'||conv_unit;
        begin
          if i_precision = 0 then
            o_num := to_char(round(to_conv/conv_divisor, i_precision),'9999')||conv_unit;
          elsif i_precision = 1 then
            o_num := to_char(round(to_conv/conv_divisor, i_precision),'9999.9')||conv_unit;
          else
            o_num := to_char(round(to_conv/conv_divisor, i_precision),'9999.99')||conv_unit;
          end if;
          return o_num;
        end to_unit;


      begin

          if to_conv != 0 then

            if i_mag = 1024 then
              -- multiples of 1024
              tok := 1024;
              tom := 1048576;
              tog := 1073741824;
              tot := 1099511627776;
              top := 1125899906842624;
            else
              -- multiples of 1000
              tok := 1000;
              tom := 1000000;
              tog := 1000000000;
              tot := 1000000000000;
              top := 1000000000000000;
            end if;

           -- Convert the incoming data to Bytes
           if    i_unit = 'P' then to_conv := to_conv * top;
           elsif i_unit = 'T' then to_conv := to_conv * tot;
           elsif i_unit = 'G' then to_conv := to_conv * tog;
           elsif i_unit = 'M' then to_conv := to_conv * tom;
           elsif i_unit = 'K' then to_conv := to_conv * tok;
           end if;

           -- Convert to units, bearing in mind the minimum unit requested
           if    i_min_unit = 'P' then
                   conv := to_unit(top, 'P');
           elsif i_min_unit = 'T' then
            if    round(to_conv/tot, i_precision) > 9999  then 
                   -- peta
                   conv := to_unit(top, 'P');
              else -- tera
                   conv := to_unit(tot, 'T');
              end if;
           elsif i_min_unit = 'G' then
              if    round(to_conv/tot, i_precision) > 9999  then 
                   -- peta
                   conv := to_unit(top, 'P');
              elsif round(to_conv/tog, i_precision) > 9999  then 
                   -- tera
                   conv := to_unit(tot, 'T');
              else -- giga
                   conv := to_unit(tog, 'G');
              end if;
           elsif i_min_unit = 'M' then
              if    round(to_conv/tot, i_precision) > 9999  then 
                   -- peta
                   conv := to_unit(top, 'P');
              elsif round(to_conv/tog, i_precision) > 9999  then 
                   -- tera
                   conv := to_unit(tot, 'T');
              elsif round(to_conv/tom, i_precision) > 9999  then
                   -- giga
                   conv := to_unit(tog, 'G');
              else
                   -- mega
                   conv := to_unit(tom, 'M');
              end if;
           elsif i_min_unit = 'K' then
              if    round(to_conv/tot, i_precision) > 9999  then 
                   -- peta
                   conv := to_unit(top, 'P');
              elsif round(to_conv/tog, i_precision) > 9999  then 
                   -- tera
                   conv := to_unit(tot, 'T');
              elsif round(to_conv/tom, i_precision) > 9999  then
                   -- giga
                   conv := to_unit(tog, 'G');
              elsif round(to_conv/tok, i_precision) > 9999  then
                   -- mega
                   conv := to_unit(tom, 'M');
              else
                   -- kilo
                   conv := to_unit(tok, 'K');
              end if;
           else
              if    round(to_conv/tot, i_precision) > 9999  then 
                   -- peta
                   conv := to_unit(top, 'P');
              elsif round(to_conv/tog, i_precision) > 9999  then 
                   -- tera
                   conv := to_unit(tot, 'T');
              elsif round(to_conv/tom, i_precision) > 9999  then
                   -- giga
                   conv := to_unit(tog, 'G');
              elsif round(to_conv/tok, i_precision) > 9999  then
                   -- mega
                   conv := to_unit(tom, 'M');
              elsif round(to_conv,     i_precision) > 9999  then
                   -- kilo
                   conv := to_unit(tok, 'K');
              else
                   conv := to_unit(tob, ' ');
              end if;

           end if;

        else  -- Value to convert is zero
           conv := ' ';
        end if;

        return conv;

      end V1024;

   /* ------------------------------------------------------------------- */

   procedure STAT_CHANGES
   /* Returns a set of differences of the values from corresponding pairs
      of rows in STATS$SYSSTAT, STATS$LIBRARYCACHE and STATS$WAITSTAT,
      based on the begin and end (bid, eid) snapshot id's specified.
      This procedure is the only call to STATSPACK made by the statsrep 
      report.
      Modified to include multi-db support.
   */
      ( bid           IN  number
      , eid           IN  number
      , db_ident      IN  number
      , inst_num      IN  number
      , parallel      IN  varchar2
      , lhtr    OUT number,     bfwt   OUT number
      , tran    OUT number,     chng   OUT number
      , ucal    OUT number,     urol   OUT number
      , rsiz    OUT number
      , phyr    OUT number,     phyrd  OUT number
      , phyrdl  OUT number,     phyrc  OUT number
      , phyw    OUT number,     ucom   OUT number
      , prse    OUT number,     hprse  OUT number
      , recr    OUT number,     gets   OUT number
      , slr     OUT number
      , rlsr    OUT number,     rent   OUT number
      , srtm    OUT number,     srtd   OUT number
      , srtr    OUT number,     strn   OUT number
      , lhr     OUT number
      , bbc     OUT varchar2,   ebc    OUT varchar2
      , bsp     OUT varchar2,   esp    OUT varchar2
      , blb     OUT varchar2
      , bs      OUT varchar2,   twt    OUT number
      , logc    OUT number,     prscpu OUT number
      , tcpu    OUT number,     exe    OUT number
      , prsela  OUT number
      , bspm    OUT number,     espm   OUT number
      , bfrm    OUT number,     efrm   OUT number
      , blog    OUT number,     elog   OUT number
      , bocur   OUT number,     eocur  OUT number
      , bpgaalloc OUT number,   epgaalloc OUT number
      , bsgaalloc OUT number,   esgaalloc OUT number
      , bnprocs OUT number,     enprocs OUT number
      , timstat OUT varchar2,   statlvl OUT varchar2
      , bncpu   OUT number,     encpu  OUT number     -- OS Stat
      , bpmem   OUT number,     epmem  OUT number
      , blod    OUT number,     elod   OUT number
      , itic    OUT number,     btic   OUT number
      , iotic   OUT number,     rwtic  OUT number
      , utic    OUT number,     stic   OUT number
      , vmib    OUT number,     vmob   OUT number
      , oscpuw  OUT number
      , dbtim   OUT number,     dbcpu  OUT number     -- Time Model
      , bgela   OUT number,     bgcpu  OUT number
      , prstela OUT number,     sqleela OUT number
      , conmela OUT number
      , dmsd    OUT number,     dmfc   OUT number     -- begin RAC
      , dmsi    OUT number
      , pmrv    OUT number,     pmpt   OUT number
      , npmrv   OUT number,     npmpt  OUT number
      , dbfr   OUT number
      , dpms    OUT number,     dnpms  OUT number
      , glsg    OUT number,     glag   OUT number
      , glgt    OUT number
      , gccrrv  OUT number,     gccrrt OUT number,     gccrfl OUT number
      , gccurv  OUT number,     gccurt OUT number,     gccufl OUT number
      , gccrsv  OUT number
      , gccrbt  OUT number,     gccrft OUT number
      , gccrst  OUT number,     gccusv OUT number
      , gccupt  OUT number,     gccuft OUT number
      , gccust  OUT number
      , msgsq   OUT number,     msgsqt  OUT number
      , msgsqk  OUT number,     msgsqtk OUT number
      , msgrq   OUT number,     msgrqt  OUT number    -- end RAC
      ) is

      bval           number;   
      eval           number;
      l_b_session_id number;                         /* begin session id */
      l_b_serial#    number;                         /* begin serial# */
      l_e_session_id number;                         /* end session id */
      l_e_serial#    number;                         /* end serial# */
      l_b_timstat    varchar2(20);        /* timed_statistics begin value */
      l_e_timstat    varchar2(20);        /* timed_statistics end   value */
      l_b_statlvl    varchar2(40);        /* statistics_level begin value */
      l_e_statlvl    varchar2(40);        /* statistics_level end   value */

      /* ---------------------------------------------------------------- */

      function LIBRARYCACHE_HITRATIO RETURN number is

      /* Returns Library cache hit ratio for the begin and end (bid, eid) 
         snapshot id's specified
      */

         cursor LH (i_snap_id number) is
            select sum(pins), sum(pinhits)
              from stats$librarycache
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num;

         bpsum number;  
         bhsum number;    
         epsum number;
         ehsum number;

      begin

         if not LH%ISOPEN then open LH (bid); end if;
         fetch LH into bpsum, bhsum;
         if LH%NOTFOUND then
            raise_application_error
                        (-20100,'Missing start value for stats$librarycache');
         end if; close LH;

         if not LH%ISOPEN then open LH (eid); end if;
         fetch LH into epsum, ehsum;
         if LH%NOTFOUND then
            raise_application_error
                        (-20100,'Missing end value for stats$librarycache');

         end if; close LH;

         return (ehsum - bhsum) / (epsum - bpsum);

      end LIBRARYCACHE_HITRATIO;
         
         
      /* ---------------------------------------------------------------- */

      function GET_PARAM (i_name varchar2, i_beid number) RETURN varchar2 is

      /* Returns the value for the init.ora parameter for the snapshot
         specified.
      */

         l_name    stats$parameter.name%type := i_name;
         par_value stats$parameter.value%type;

         cursor PARAMETER is
            select value
              from stats$parameter
             where snap_id         = i_beid
               and dbid            = db_ident
               and instance_number = inst_num
               and (   name  = '__' || i_name
                    or name  = i_name
                   )
             order by name;

      begin

         if not PARAMETER%ISOPEN then open PARAMETER; end if;
         fetch PARAMETER into par_value;
         if PARAMETER%NOTFOUND then
            raise_application_error
                        (-20100,'Missing Init.ora parameter '|| i_name || ' in snap ' || i_beid);
         end if; close PARAMETER;

         return par_value;

      end GET_PARAM;

      /* ---------------------------------------------------------------- */

      function GET_SYSSTAT (i_name varchar2, i_beid number) RETURN number is

      /* Returns the value for the System Statistic for the snapshot
         specified.
      */

         cursor SYSSTAT is
            select value
              from stats$sysstat
             where snap_id         = i_beid
               and dbid            = db_ident
               and instance_number = inst_num
               and name            = i_name;

         stat_value varchar2(512);

      begin

         if not SYSSTAT%ISOPEN then open SYSSTAT; end if;
         fetch SYSSTAT into stat_value;
         if SYSSTAT%NOTFOUND then
            raise_application_error
                        (-20100,'Missing System Statistic '|| i_name);
         end if; close SYSSTAT;

         return stat_value;

      end GET_SYSSTAT;

      /* ---------------------------------------------------------------- */

      function GET_OSSTAT (i_osstat_id number, i_beid number) RETURN number is

      /* Returns the value for the OSStat Statistic for the snapshot
         specified.
      */

         cursor OSSTAT is
            select value
             from stats$osstat os
            where os.snap_id         = i_beid
              and os.dbid            = db_ident
              and os.instance_number = inst_num
              and os.osstat_id       = i_osstat_id;

         stat_value number := null;

      begin

         if not OSSTAT%ISOPEN then open OSSTAT; end if;
         fetch OSSTAT into stat_value;
         if OSSTAT%NOTFOUND then
            null;
         end if; close OSSTAT;

         return stat_value;

      end GET_OSSTAT;

      /* ---------------------------------------------------------------- */

      function GET_PGASTAT (i_name varchar2, i_beid number) RETURN number is

      /* Returns the value for the PGAStat Statistic for the snapshot
         specified.
      */

         cursor PGASTAT is
           select value
             from stats$pgastat
            where snap_id         = i_beid
              and dbid            = db_ident
              and instance_number = inst_num
              and name            = i_name;

         stat_value number:= null;

      begin

         If not PGASTAT%ISOPEN then open PGASTAT; end if;
         fetch PGASTAT into stat_value;
         if PGASTAT%NOTFOUND then
            null;
         end if; close PGASTAT;

         return stat_value;

      end GET_PGASTAT;

      /* ---------------------------------------------------------------- */

      function GET_SGA (i_beid number) RETURN number is

      /* Returns the total SGA size
      */

         cursor SGA is
           select sum(value)
             from stats$sga
            where snap_id         = i_beid
              and dbid            = db_ident
              and instance_number = inst_num;

         stat_value number;

      begin

         if not SGA%ISOPEN then open SGA; end if;
         fetch SGA into stat_value;
         if SGA%NOTFOUND then
            raise_application_error
                        (-20100,'Unable to calculate total SGA Size');
         end if; close SGA;

         return stat_value;

      end GET_SGA;

      /* ---------------------------------------------------------------- */

      function GET_SYS_TIME_MODEL (i_name varchar2, i_beid number) RETURN number is

      /* Returns the value for the Sys Time Model Statistic for the snapshot
         specified.
      */

         cursor STM is
           select value
             from stats$sys_time_model os
                , stats$time_model_statname tms
            where os.snap_id         = i_beid
              and os.dbid            = db_ident
              and os.instance_number = inst_num
              and os.stat_id         = tms.stat_id
              and tms.stat_name      = i_name;

         stat_value number := null;

      begin

         if not STM%ISOPEN then open STM; end if;
         fetch STM into stat_value;
         if STM%NOTFOUND then
            null;
         end if; close STM;

         return stat_value;

      end GET_SYS_TIME_MODEL;

      /* ---------------------------------------------------------------- */

      function BUFFER_WAITS RETURN number is

      /* Returns the total number of waits for all buffers in the interval
         specified by the begin and end snapshot id's (bid, eid)
      */

         cursor BW (i_snap_id number) is
            select sum(wait_count)
              from stats$waitstat
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num;

         bbwsum number;  ebwsum number;

      begin

         if not BW%ISOPEN then open BW (bid); end if;
         fetch BW into bbwsum;
         if BW%NOTFOUND then
            raise_application_error
                        (-20100,'Missing start value for stats$waitstat');
         end if; close BW;

         if not BW%ISOPEN then open BW (eid); end if;
         fetch BW into ebwsum;
         if BW%NOTFOUND then
            raise_application_error
                        (-20100,'Missing end value for stats$waitstat');
         end if; close BW;

         return ebwsum - bbwsum;

      end BUFFER_WAITS;

      /* ---------------------------------------------------------------- */

      function BUFFER_GETS RETURN number is

      /* Returns the total number of buffers gets from cache in the interval
         specified by the begin and end snapshot id's (bid, eid)
      */

         cursor BG (i_snap_id number) is
            select sum(value)
              from stats$sysstat
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num
               and name in ('consistent gets from cache','db block gets from cache', 'recovery block gets from cache');

         bbgval number;  ebgval number;

      begin

         if not BG%ISOPEN then open BG (bid); end if;
         fetch BG into bbgval;
         if BG%NOTFOUND then
            raise_application_error
              (-20100,'Missing start value for stats$sysstat (db block/consistent gets from cache statistic)');
         end if; close BG;

         if not BG%ISOPEN then open BG (eid); end if;
         fetch BG into ebgval;
         if BG%NOTFOUND then
            raise_application_error
              (-20100,'Missing end value for stats$sysstat (db block/consistent gets from cache statistic)');
         end if; close BG;

         return ebgval - bbgval;

      end BUFFER_GETS;

      /* ---------------------------------------------------------------- */

      function TOTAL_EVENT_TIME RETURN number is

      /* Returns the total amount of time waited for events for
         the interval specified by the begin and end snapshot id's 
         (bid, eid).  This excludes idle wait events.
      */

         cursor WAITS (i_snap_id number) is
            select sum(time_waited_micro)
              from stats$system_event
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num
               and event not in (select event from stats$idle_event);

         bwaittime number;
         ewaittime number;

      begin

         if not WAITS%ISOPEN then open WAITS (bid); end if;
         fetch WAITS into bwaittime;
         if WAITS%NOTFOUND then
            raise_application_error
                        (-20100,'Missing start value for stats$system_event');
         end if; close WAITS;

         if not WAITS%ISOPEN then open WAITS (eid); end if;
         fetch WAITS into ewaittime;
         if WAITS%NOTFOUND then
            raise_application_error
                        (-20100,'Missing end value for stats$system_event');
         end if; close WAITS;

         return ewaittime - bwaittime;

      end TOTAL_EVENT_TIME;

      /* ---------------------------------------------------------------- */

      function LATCH_HITRATIO return NUMBER is

      /* Returns the latch hit ratio specified by the begin and 
         end snapshot id's (bid, eid)
      */

         cursor GETS_MISSES (i_snap_id number) is
            select sum(gets), sum(misses)
              from stats$latch
             where snap_id         = i_snap_id
               and dbid            = db_ident
               and instance_number = inst_num;

         blget number;  -- beginning latch gets
         blmis number;  -- beginning latch misses
         elget number;  -- end latch gets
         elmis number;  -- end latch misses

      begin

         if not GETS_MISSES%ISOPEN then open GETS_MISSES (bid); end if;
         fetch GETS_MISSES into blget, blmis;
         if GETS_MISSES%NOTFOUND then
            raise_application_error
                (-20100,'Missing start value for STATS$LATCH gets and misses');
         end if; close GETS_MISSES;

         if not GETS_MISSES%ISOPEN then open GETS_MISSES (eid); end if;
         fetch GETS_MISSES into elget, elmis;
         if GETS_MISSES%NOTFOUND then
            raise_application_error
                (-20100,'Missing end value for STATS$LATCH gets and misses');
         end if; close GETS_MISSES;

         return ( ( elmis - blmis ) / ( elget - blget ) );

      end LATCH_HITRATIO;

      /* ---------------------------------------------------------------- */

      function SGASTAT (i_name varchar2, i_beid number) RETURN number is

      /* Returns the bytes used by i_name in the shared pool
         for the begin or end snapshot (bid, eid) specified
      */

      cursor bytes_used is
        select bytes
          from stats$sgastat
         where snap_id         = i_beid
           and dbid            = db_ident
           and instance_number = inst_num
           and pool            in ('shared pool', 'all pools')
           and name            = i_name; 

       total_bytes number;

       begin
        if i_name = 'total_shared_pool' then
          select sum(bytes)
            into total_bytes
            from stats$sgastat
           where snap_id         = i_beid
             and dbid            = db_ident
             and instance_number = inst_num
             and pool            in ('shared pool','all pools');
        else
          open bytes_used; fetch bytes_used into total_bytes;
          if bytes_used%notfound then
             raise_application_error
                         (-20100,'Missing value for SGASTAT: '||i_name);
          end if;
          close bytes_used;
        end if;
 
         return total_bytes;
      end SGASTAT;

      /* ---------------------------------------------------------------- */

      function SYSDIF (i_name varchar2) RETURN number is

      /* Returns the difference between statistics for the statistic
         name specified for the interval between the begin and end 
         snapshot id's (bid, eid)

         In the case the Statspack schema includes data from a prior
         server release, this function returns NULL for statistics which
         do not appear in both the begin and end snapshots
      */

      beg_val_missing   boolean := false;
      end_val_missing   boolean := false;

      cursor SY (i_snap_id number) is
      select value 
        from stats$sysstat
       where snap_id         = i_snap_id
         and dbid            = db_ident
         and instance_number = inst_num
         and name            = i_name;

      begin
         /* Get start value */
         open SY (bid); fetch SY into bval;
         if SY%notfound then
            beg_val_missing := true;
         end if; close SY;

         /* Get end value */
         open SY (eid); fetch SY into eval;
         if SY%notfound then
            end_val_missing := true;
         end if; close SY;

         if     beg_val_missing = true
            and end_val_missing = true      then

              /* this is likely a newer SYSSTAT statistic which did not
                 exist for these snapshot ranges / database version    */
              return null;

         elsif     beg_val_missing = true
               and end_val_missing = false  then

               raise_application_error
                           (-20100,'Missing start value for statistic: '||i_name);

         elsif     beg_val_missing = false
               and end_val_missing = true   then

               raise_application_error
                           (-20100,'Missing end value for statistic: '||i_name);
         else

              /* Return difference */
              return eval - bval;

         end if;

      end SYSDIF;

      /* ---------------------------------------------------------------- */

      function OSSTAT_DIF (i_osstat_id number) RETURN number is

      /* Returns the difference between statistics for the OSStat statistic
         name specified for the interval between the begin and end 
         snapshot id's (bid, eid)

         In the case the data being queried is from a prior release
         which did not have the statistic requested, this function
         returns 0.
      */

      beg_val_missing   boolean := false;
      end_val_missing   boolean := false;

      cursor SY (i_snap_id number) is
      select value 
        from stats$osstat os
           , stats$osstatname osn
       where os.snap_id         = i_snap_id
         and os.dbid            = db_ident
         and os.instance_number = inst_num
         and os.osstat_id       = i_osstat_id;

      begin
         /* Get start value */
         open SY (bid); fetch SY into bval;
         if SY%notfound then
            beg_val_missing := true;
         end if; close SY;

         /* Get end value */
         open SY (eid); fetch SY into eval;
         if SY%notfound then
            end_val_missing := true;
         end if; close SY;

         if     beg_val_missing = true
            and end_val_missing = true      then

              /* this is likely a newer statistic which did not
                 exist for these snapshot ranges / database version    */
              return null;

         elsif     beg_val_missing = true
               and end_val_missing = false  then

               raise_application_error
                           (-20100,'Missing start value for OSStat Id : '||i_osstat_id);

         elsif     beg_val_missing = false
               and end_val_missing = true   then

               raise_application_error
                           (-20100,'Missing end value for OSStat Id: '||i_osstat_id);
         else

              /* Return difference */
              return eval - bval;

         end if;

      end OSSTAT_DIF;

      /* ---------------------------------------------------------------- */

      function SYS_TIME_MODEL_DIF (i_name varchar2) RETURN number is

      /* Returns the difference between statistics for the Time Model statistic
         name specified for the interval between the begin and end 
         snapshot id's (bid, eid)

         In the case the data being queried is from a prior release
         which did not have the statistic requested, this function
         returns 0.
      */

      beg_val_missing   boolean := false;
      end_val_missing   boolean := false;

      cursor SY (i_snap_id number) is
      select value 
        from stats$sys_time_model      stm
           , stats$time_model_statname tms
       where stm.snap_id         = i_snap_id
         and stm.dbid            = db_ident
         and stm.instance_number = inst_num
         and stm.stat_id         = tms.stat_id
         and tms.stat_name       = i_name;

      begin
         /* Get start value */
         open SY (bid); fetch SY into bval;
         if SY%notfound then
            beg_val_missing := true;
         end if; close SY;

         /* Get end value */
         open SY (eid); fetch SY into eval;
         if SY%notfound then
            end_val_missing := true;
         end if; close SY;

         if     beg_val_missing = true
            and end_val_missing = true      then

               /* this is likely a newer statitic which did not
                 exist for this database version    */
              return 0;

         elsif     beg_val_missing = true
               and end_val_missing = false  then

               raise_application_error
                           (-20100,'Missing start value for SYS_TIME_MODEL statistic: '||i_name);

         elsif     beg_val_missing = false
               and end_val_missing = true   then

               raise_application_error
                           (-20100,'Missing end value for SYS_TIME_MODEL statistic: '||i_name);
         else

              /* Return difference */
              return eval - bval;

         end if;

      end SYS_TIME_MODEL_DIF;

      /* ---------------------------------------------------------------- */

      function SESDIF (st_name varchar2) RETURN number is

      /* Returns the difference between statistics values for the 
         statistic name specified for the interval between the begin and end 
         snapshot id's (bid, eid), for the session monitored for that
         snapshot
      */

      cursor SE (i_snap_id number) is
         select ses.value 
           from stats$sysstat sys
              , stats$sesstat ses
          where sys.snap_id     = i_snap_id
            and ses.snap_id     = i_snap_id
            and ses.dbid        = db_ident
            and sys.dbid        = db_ident
            and ses.instance_number = inst_num
            and sys.instance_number = inst_num
            and ses.statistic#  = sys.statistic#
            and sys.name        = st_name;

      begin
         /* Get start value */
         open SE (bid); fetch SE into bval;
         if SE%notfound then
           eval :=0;
         end if; close SE;
 
         /* Get end value */
         open SE (eid); fetch SE into eval;
         if SE%notfound then
           eval :=0;
         end if; close SE;
 
         /* Return difference */
         return eval - bval;
      end SESDIF;

/* ---------------------------------------------------------------- */

      function DLMDIF (i_name varchar2) RETURN number is

      /* Returns the difference between statistics for the statistic
         name specified for the interval between the begin and end
         snapshot id's (bid, eid)

         In the case the Statspack schema includes data from a prior
         server release, this function returns NULL for statistics which
         do not appear in both the begin and end snapshots
      */

      beg_val_missing   boolean := false;
      end_val_missing   boolean := false;

      cursor DLM (i_snap_id number) is
      select value
        from stats$dlm_misc
       where snap_id         = i_snap_id
         and dbid            = db_ident
         and instance_number = inst_num
         and name            = i_name;

      
      begin

         /* Get start value */
         open DLM (bid); fetch DLM into bval;
         if DLM%notfound then
            beg_val_missing := true;
         end if; close DLM;

         /* Get end value */
         open DLM (eid); fetch DLM into eval;
         if DLM%notfound then
            end_val_missing := true;
         end if; close DLM;

         if     beg_val_missing = true
            and end_val_missing = true      then

              /* this is likely a newer DLM_MISC statitic which did not
                 exist for these snapshot ranges / database version    */
              return null;

         elsif     beg_val_missing = true
               and end_val_missing = false  then

               raise_application_error
                           (-20100,'Missing start value for statistic: '||i_name);

         elsif     beg_val_missing = false
               and end_val_missing = true   then

               raise_application_error
                           (-20100,'Missing end value for statistic: '||i_name);
         else

              /* Return difference */
              return eval - bval;

         end if;

      end DLMDIF;


/* ---------------------------------------------------------------- */

      function RACFLSTAT (i_name varchar2) return number is

      /* Computes the difference between CR and CURRENT block
         flush statistics for the interval between begin and end
         snapshot id's (bid, eid).

         In the case the statistic does not appear in one of the
         snapshots or the argument value is wrong, the function returns 0.
      */

      flushes                      number := 0;


      begin

         if  i_name = 'cr_flushes'  then
           select e.flushes - b.flushes into flushes
             from stats$cr_block_server b
                , stats$cr_block_server e
            where b.snap_id          = bid
              and b.dbid             = db_ident
              and b.instance_number  = inst_num
              and e.snap_id          = eid
              and e.dbid             = db_ident
              and e.instance_number  = inst_num;
 
         elsif  i_name = 'current_flushes'  then
           select (e.flush1+e.flush10+e.flush100+e.flush1000+e.flush10000)
                    - (b.flush1+b.flush10+b.flush100+b.flush1000+b.flush10000)
                  into flushes
             from stats$current_block_server b
                , stats$current_block_server e
            where b.snap_id         = bid
              and b.dbid            = db_ident
              and b.instance_number = inst_num
              and e.snap_id         = eid
              and e.dbid            = db_ident
              and e.instance_number = inst_num;
         end if;

         return flushes;

      exception
        when NO_DATA_FOUND then
           /*  begin or end value does not exist - return 0 */
          return 0;


      end RACFLSTAT;


   /* ------------------------------------------------------------------- */
 

   begin     /* main procedure body of STAT_CHANGES */

      lhtr   := LIBRARYCACHE_HITRATIO;
      bfwt   := BUFFER_WAITS;
      lhr    := LATCH_HITRATIO;
      chng   := SYSDIF('db block changes');
      ucal   := SYSDIF('user calls');
      urol   := SYSDIF('user rollbacks');
      ucom   := SYSDIF('user commits');
      tran   := ucom + urol;
      rsiz   := SYSDIF('redo size');
      phyr   := SYSDIF('physical reads');
      phyrd  := SYSDIF('physical reads direct');
      phyrdl := SYSDIF('physical reads direct (lob)');
      phyrc  := SYSDIF('physical reads cache');
      phyw   := SYSDIF('physical writes');
      hprse  := SYSDIF('parse count (hard)');
      prse   := SYSDIF('parse count (total)');
      gets   := BUFFER_GETS;
      slr    := SYSDIF('session logical reads');
      recr   := SYSDIF('recursive calls');
      rlsr   := SYSDIF('redo log space requests');
      rent   := SYSDIF('redo entries');

      srtm   := 0;
      srtd   := 0;
      select sum(e.optimal_executions - nvl(b.optimal_executions,0))
        into srtm
        from stats$sql_workarea_histogram b
           , stats$sql_workarea_histogram e
       where b.snap_id(+)           = bid
         and e.snap_id              = eid
         and b.dbid(+)              = db_ident
         and e.dbid                 = db_ident
         and b.instance_number(+)   = inst_num
         and e.instance_number      = inst_num
         and b.low_optimal_size(+)  = e.low_optimal_size
         and b.high_optimal_size(+) = e.high_optimal_size;

      select sum(e.total_executions - nvl(b.total_executions,0)) - srtm
        into srtd
        from stats$sql_workarea_histogram b
           , stats$sql_workarea_histogram e
       where b.snap_id(+)           = bid
         and e.snap_id              = eid
         and b.dbid(+)              = db_ident
         and e.dbid                 = db_ident
         and b.instance_number(+)   = inst_num
         and e.instance_number      = inst_num
         and b.low_optimal_size(+)  = e.low_optimal_size
         and b.high_optimal_size(+) = e.high_optimal_size;

      srtr   :=   GET_PGASTAT('bytes processed', eid)
                - GET_PGASTAT('bytes processed', bid);
      logc   := SYSDIF('logons cumulative');
      prscpu := SYSDIF('parse time cpu');
      prsela := SYSDIF('parse time elapsed');
      tcpu   := SYSDIF('CPU used by this session');
      exe    := SYSDIF('execute count');
      bs     := GET_PARAM('db_block_size', bid);
      bbc    := GET_PARAM('db_block_buffers', bid) * bs;
      if bbc = 0 then
        bbc  :=   GET_PARAM('db_cache_size', bid)
                + GET_PARAM('db_keep_cache_size', bid)
                + GET_PARAM('db_recycle_cache_size', bid)
                + GET_PARAM('db_2k_cache_size', bid)
                + GET_PARAM('db_4k_cache_size', bid)
                + GET_PARAM('db_8k_cache_size', bid)
                + GET_PARAM('db_16k_cache_size', bid)
                + GET_PARAM('db_32k_cache_size', bid);
      end if;
      ebc  := GET_PARAM('db_block_buffers', eid) * bs;
      if ebc = 0 then
        ebc  :=   GET_PARAM('db_cache_size', eid)
                + GET_PARAM('db_keep_cache_size', eid)
                + GET_PARAM('db_recycle_cache_size', eid)
                + GET_PARAM('db_2k_cache_size', eid)
                + GET_PARAM('db_4k_cache_size', eid)
                + GET_PARAM('db_8k_cache_size', eid)
                + GET_PARAM('db_16k_cache_size', eid)
                + GET_PARAM('db_32k_cache_size', eid);
      end if;
      bsp  := GET_PARAM('shared_pool_size', bid);
      esp  := GET_PARAM('shared_pool_size', eid);
      blb  := GET_PARAM('log_buffer', bid);
      twt  := TOTAL_EVENT_TIME;     -- total wait time for all non-idle events
      -- get value from __, rather than summing sgastat
      bspm := bsp;
      espm := esp;
      bfrm := SGASTAT('free memory', bid);
      efrm := SGASTAT('free memory', eid);
      blog := GET_SYSSTAT('logons current', bid);
      elog := GET_SYSSTAT('logons current', eid);
      bocur := GET_SYSSTAT('opened cursors current', bid);
      eocur := GET_SYSSTAT('opened cursors current', eid);
      bpgaalloc := GET_PGASTAT('total PGA allocated', bid);
      epgaalloc := GET_PGASTAT('total PGA allocated', eid);
      bsgaalloc := GET_SGA(bid);
      esgaalloc := GET_SGA(eid);
      bnprocs   := GET_PGASTAT('process count', bid);
      enprocs   := GET_PGASTAT('process count', eid);
      l_b_timstat := GET_PARAM('timed_statistics', bid);
      l_e_timstat := GET_PARAM('timed_statistics', eid);
      if (l_b_timstat = l_e_timstat) then
         timstat := l_b_timstat;
      else
         timstat := 'INCONSISTENT';
      end if;
      l_b_statlvl := upper(GET_PARAM('statistics_level', bid));
      l_e_statlvl := upper(GET_PARAM('statistics_level', eid));
      if    (l_b_statlvl = l_e_statlvl) then
         statlvl := l_b_statlvl;
      elsif (l_b_statlvl  = 'BASIC' and l_e_statlvl != 'BASIC')
         or (l_b_statlvl != 'BASIC' and l_e_statlvl  = 'BASIC')  then
         -- Timed Stats may be inconsistent and Stats Level stats inconsistent
         statlvl := 'INCONSISTENT_BASIC';
      elsif (l_b_statlvl != l_e_statlvl) then
         -- Stat level changed from TYPICAL/ADVANCED to ADVANCED/TYPICAL
         -- so timed stats and stats level stats will still be ok
         statlvl := 'INCONSISTENT';
      end if;

      -- OS Stat
      bncpu := GET_OSSTAT(0, bid);    -- NUM_CPUS
      encpu := GET_OSSTAT(0, eid);    -- NUM_CPUS
      bpmem := GET_OSSTAT(1008, bid); -- PHYSICAL_MEMORY_BYTES
      epmem := GET_OSSTAT(1008, eid); -- PHYSICAL_MEMORY_BYTES
      blod  := GET_OSSTAT(15, bid);   -- LOAD
      elod  := GET_OSSTAT(15, eid);   -- LOAD

      itic  := OSSTAT_DIF(1);      -- IDLE_TIME
      btic  := OSSTAT_DIF(2);      -- BUSY_TIME
      iotic := OSSTAT_DIF(5);      -- IOWAIT_TIME      - solaris
      rwtic := OSSTAT_DIF(14);     -- RSRC_MGR_CPU_WAIT_TIME
      utic  := OSSTAT_DIF(3);      -- USER_TIME
      stic  := OSSTAT_DIF(4);      -- SYS_TIME
      oscpuw:= OSSTAT_DIF(13);     -- OS_CPU_WAIT_TIME - solaris
      vmib  := OSSTAT_DIF(1009);   -- VM_IN_BYTES
      vmob  := OSSTAT_DIF(1010);   -- VM_OUT_BYTES
      if vmib = 0 then
        vmib  := OSSTAT_DIF(1000);   -- VM_IN_BYTES 
      end if;
      if vmob = 0 then
        vmob  := OSSTAT_DIF(1001);   -- VM_OUT_BYTES
      end if;

      -- Time Model
      dbtim   := SYS_TIME_MODEL_DIF('DB time');
      dbcpu   := SYS_TIME_MODEL_DIF('DB CPU');
      bgela   := SYS_TIME_MODEL_DIF('background elapsed time');
      bgcpu   := SYS_TIME_MODEL_DIF('background cpu time');
      prstela := SYS_TIME_MODEL_DIF('parse time elapsed');
      sqleela := SYS_TIME_MODEL_DIF('sql execute elapsed time');
      conmela := SYS_TIME_MODEL_DIF('connection management call elapsed');

      /*  Do we want to report on RAC-specific statistics? Check
          in procedure variable "parallel".
      */

      if parallel = 'YES' then

        dmsd     := DLMDIF('messages sent directly');
        dmfc     := DLMDIF('messages flow controlled');
        dmsi     := DLMDIF('messages sent indirectly');
        pmrv     := DLMDIF('gcs msgs received');
        pmpt     := DLMDIF('gcs msgs process time(ms)');
        npmrv    := DLMDIF('ges msgs received');
        npmpt    := DLMDIF('ges msgs process time(ms)');
        dbfr     := SYSDIF('DBWR fusion writes');
        dpms     := SYSDIF('gcs messages sent');
        dnpms    := SYSDIF('ges messages sent');
        glsg     := SYSDIF('global enqueue gets sync');
        glag     := SYSDIF('global enqueue gets async');
        glgt     := SYSDIF('global enqueue get time');
        gccrrv   := SYSDIF('gc cr blocks received');
        gccrrt   := SYSDIF('gc cr block receive time');
        gccurv   := SYSDIF('gc current blocks received');
        gccurt   := SYSDIF('gc current block receive time');
        gccrsv   := SYSDIF('gc cr blocks served');
        gccrbt   := SYSDIF('gc cr block build time');
        gccrft   := SYSDIF('gc cr block flush time');
        gccrst   := SYSDIF('gc cr block send time');
        gccusv   := SYSDIF('gc current blocks served');
        gccupt   := SYSDIF('gc current block pin time');
        gccuft   := SYSDIF('gc current block flush time');
        gccust   := SYSDIF('gc current block send time');
        msgsq    := DLMDIF('msgs sent queued');
        msgsqt   := DLMDIF('msgs sent queue time (ms)');
        msgsqk   := DLMDIF('msgs sent queued on ksxp');
        msgsqtk  := DLMDIF('msgs sent queue time on ksxp (ms)');
        msgrqt   := DLMDIF('msgs received queue time (ms)');
        msgrq    := DLMDIF('msgs received queued');
        gccrfl   := RACFLSTAT('cr_flushes');
        gccufl   := RACFLSTAT('current_flushes');

     end if;


      /*  Determine if we want to report on session-specific statistics.
          Check that the session is the same one for both snapshots.
      */
      select session_id
           , serial#
        into l_b_session_id
           , l_b_serial#
        from stats$snapshot
       where snap_id         = bid
         and dbid            = db_ident
         and instance_number = inst_num;

      select session_id
           , serial#
        into l_e_session_id
           , l_e_serial#
        from stats$snapshot
       where snap_id         = eid
         and dbid            = db_ident
         and instance_number = inst_num;

      if (    (l_b_session_id = l_e_session_id)
          and (l_b_serial#    = l_e_serial#)
          and (l_b_session_id != 0)              ) then
         /*  we have a valid comparison - it is the
             same session - get number of tx performed 
             by this session */
         strn := SESDIF('user rollbacks') + SESDIF('user commits');
         if strn = 0 then
            /*  No new transactions */
            strn :=  1; 
         end if;
      else
         /*  No valid comparison can be made */
         strn :=1;          
      end if;

   end STAT_CHANGES;

   /* ------------------------------------------------------------------- */

   function SNAP
      (i_snap_level               in number   default null
      ,i_session_id               in number   default null
      ,i_ucomment                 in varchar2 default null
      ,i_num_sql                  in number   default null
      ,i_executions_th            in number   default null
      ,i_parse_calls_th           in number   default null
      ,i_disk_reads_th            in number   default null
      ,i_buffer_gets_th           in number   default null
      ,i_sharable_mem_th          in number   default null
      ,i_version_count_th         in number   default null
      ,i_seg_phy_reads_th         in number   default null
      ,i_seg_log_reads_th         in number   default null
      ,i_seg_buff_busy_th         in number   default null
      ,i_seg_rowlock_w_th         in number   default null
      ,i_seg_itl_waits_th         in number   default null
      ,i_seg_cr_bks_rc_th         in number   default null
      ,i_seg_cu_bks_rc_th         in number   default null
      ,i_all_init                 in varchar2 default null
      ,i_old_sql_capture_mth      in varchar2 default null
      ,i_pin_statspack            in varchar2 default null
      ,i_modify_parameter         in varchar2 default 'FALSE'
      )
     RETURN integer IS

   /*  This function performs a snapshot of the v$ views into the
       stats$ tables, and returns the snapshot id.
       If parameters are passed, these are the values used, otherwise
       the values stored in the stats$statspack_parameter table are used.
   */

   l_snap_id                    integer;
   l_snap_start_time            timestamp;
   l_snap_end_time              timestamp;
   l_snap_level                 number;
   l_session_id                 number;
   l_serial#                    number;
   l_ucomment                   varchar2(160);
   l_num_sql                    number;
   l_executions_th              number;
   l_parse_calls_th             number;
   l_disk_reads_th              number;
   l_buffer_gets_th             number;
   l_sharable_mem_th            number;
   l_version_count_th           number;
   l_seg_phy_reads_th           number;
   l_seg_log_reads_th           number;
   l_seg_buff_busy_th           number;
   l_seg_rowlock_w_th           number;
   l_seg_itl_waits_th           number;
   l_seg_cr_bks_rc_th           number;
   l_seg_cu_bks_rc_th           number;
   l_all_init                   varchar2(5);
   l_old_sql_capture_mth        varchar2(10);
   l_pin_statspack              varchar2(10);

   l_sharable_mem               number;
   l_version_count              number;
   l_max_begin_time             date;
   l_max_resize_ops_start_time  date;
   l_prev_snap_id               integer;

   l_counter_maxvalue           positive := 100;
   l_counter                    integer  := 0;
   l_insert_done                boolean  := FALSE; -- avoid ORA-1
   CFINCREAD                    exception;         -- and ORA-235
   pragma                       exception_init(CFINCREAD,-235);
   l_param_value                varchar2(100);

   cursor GETSERIAL is
      select serial#
        from v$session
       where sid = l_session_id;

   cursor GET_CURRENT_PARAM (param_name v$parameter.name%type) is
      select ksppstvl
        from stats$x$ksppi  i
           , stats$x$ksppsv sv
       where i.indx = sv.indx
         and i.ksppinm = param_name;

  /* ---------------------------------------------------------------- */

    PROCEDURE snap_rac IS

    /*  Capture RAC-related statistics */

     begin

       insert into stats$dlm_misc
            ( snap_id
            , dbid
            , instance_number
            , statistic#
            , name
            , value
            )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , statistic#
            , name
            , value
         from v$dlm_misc;

       insert into stats$cr_block_server
            ( snap_id
            , dbid
            , instance_number
            , cr_requests
            , current_requests
            , data_requests
            , undo_requests
            , tx_requests
            , current_results
            , private_results
            , zero_results
            , disk_read_results
            , fail_results
            , fairness_down_converts
            , fairness_clears
            , free_gc_elements
            , flushes
            , flushes_queued
            , flush_queue_full
            , flush_max_time
            , light_works
            , errors
            )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , cr_requests
            , current_requests
            , data_requests
            , undo_requests
            , tx_requests
            , current_results
            , private_results
            , zero_results
            , disk_read_results
            , fail_results
            , fairness_down_converts
            , fairness_clears
            , free_gc_elements
            , flushes
            , flushes_queued
            , flush_queue_full
            , flush_max_time
            , light_works
            , errors
         from v$cr_block_server;

       insert into stats$current_block_server
            ( snap_id
            , dbid
            , instance_number
            , pin1
            , pin10
            , pin100
            , pin1000
            , pin10000
            , flush1
            , flush10
            , flush100
            , flush1000
            , flush10000
            , write1
            , write10
            , write100
            , write1000
            , write10000
            )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , pin1
            , pin10
            , pin100
            , pin1000
            , pin10000
            , flush1
            , flush10
            , flush100
            , flush1000
            , flush10000
            , write1
            , write10
            , write100
            , write1000
            , write10000
         from v$current_block_server;

       insert into stats$instance_cache_transfer
            ( snap_id
            , dbid
            , instance_number
            , instance
            , class
            , cr_block
            , cr_busy
            , cr_congested
            , current_block
            , current_busy
            , current_congested
            )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , instance
            , class
            , cr_block
            , cr_busy
            , cr_congested
            , current_block
            , current_busy
            , current_congested
         from  v$instance_cache_transfer
        where (cr_block > 0 or cr_busy > 0 or cr_congested > 0 or
               current_block > 0 or current_busy > 0 or current_congested > 0);

       insert into stats$dynamic_remaster_stats
            ( snap_id
            , dbid
            , instance_number
            , remaster_ops
            , remaster_time
            , remastered_objects
            , quiesce_time
            , freeze_time
            , cleanup_time
            , replay_time
            , fixwrite_time
            , sync_time
            , resources_cleaned
            , replayed_locks_sent
            , replayed_locks_received
            , current_objects
            )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , remaster_ops
            , remaster_time
            , remastered_objects
            , quiesce_time
            , freeze_time
            , cleanup_time
            , replay_time
            , fixwrite_time
            , sync_time
            , resources_cleaned
            , replayed_locks_sent
            , replayed_locks_received
            , current_objects
         from v$dynamic_remaster_stats;

        insert into stats$interconnect_pings
            ( snap_id
            , dbid
            , instance_number
            , target_instance
            , iter_500b
            , wait_500b
            , waitsq_500b
            , iter_8k
            , wait_8k
            , waitsq_8k
            )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , inst
            , iter_500b
            , wait_500b
            , waitsq_500b
            , iter_8k
            , wait_8k
            , waitsq_8k
        from stats$x$ksxpping;


   END snap_rac;

  /* ---------------------------------------------------------------- */

    PROCEDURE snap_segment IS

    /*  Capture Segment Statistics */

     begin

        insert into stats$seg_stat
             ( snap_id
             , dbid
             , instance_number
             , ts#
             , obj#
             , dataobj#
             , logical_reads
             , buffer_busy_waits
             , db_block_changes
             , physical_reads
             , physical_writes
             , direct_physical_reads
             , direct_physical_writes
             , gc_cr_blocks_received
             , gc_current_blocks_received
             , gc_buffer_busy
             , itl_waits
             , row_lock_waits
             )
        select /*+  ordered use_nl(s1.gv$segstat.X$KSOLSFTS) */
               l_snap_id
             , p_dbid
             , p_instance_number
             , s1.ts#
             , s1.obj#
             , s1.dataobj#
             , sum(decode(s1.statistic_name,'logical reads',value,0))
             , sum(decode(s1.statistic_name,'buffer busy waits',value,0))
             , sum(decode(s1.statistic_name,'db block changes',value,0))
             , sum(decode(s1.statistic_name,'physical reads',value,0))
             , sum(decode(s1.statistic_name,'physical writes',value,0))
             , sum(decode(s1.statistic_name,'physical reads direct',value,0))
             , sum(decode(s1.statistic_name,'physical writes direct',value,0))
             , sum(decode(s1.statistic_name,'gc cr blocks received',value,0))
             , sum(decode(s1.statistic_name,'gc current blocks received',value,0))
             , sum(decode(s1.statistic_name,'gc buffer busy',value,0))
             , sum(decode(s1.statistic_name,'ITL waits',value,0))
             , sum(decode(s1.statistic_name,'row lock waits',value,0))
          from v$segstat s1
         where (s1.dataobj#, s1.obj#, s1.ts#) in (
                                 select /*+ unnest */
                                        s2.dataobj#
                                      , s2.obj#
                                      , s2.ts#
                                   from v$segstat s2
                                  where s2.obj# > 0
                                    and s2.obj# < 4254950912 
                                    and  ( decode(s2.statistic_name,'logical reads',s2.value,0)              > l_seg_log_reads_th
                                        or decode(s2.statistic_name,'physical reads',s2.value,0)             > l_seg_phy_reads_th
                                        or decode(s2.statistic_name,'buffer busy waits',s2.value,0)          > l_seg_buff_busy_th
                                        or decode(s2.statistic_name,'row lock waits',s2.value,0)             > l_seg_rowlock_w_th
                                        or decode(s2.statistic_name,'ITL waits',s2.value,0)                  > l_seg_itl_waits_th
                                        or decode(s2.statistic_name,'gc cr blocks received',s2.value,0)      > l_seg_cr_bks_rc_th
                                        or decode(s2.statistic_name,'gc current blocks received',s2.value,0) > l_seg_cu_bks_rc_th
                                         )
                                       )
      group by s1.ts#, s1.obj#, s1.dataobj#;


     /*  Gather Segment Names having statistics captured and avoid ORA-1 */

        l_counter := 0;
        l_insert_done := FALSE;
        while (not (l_insert_done) and l_counter < l_counter_maxvalue) loop 
          begin
            insert into stats$seg_stat_obj
                 ( ts#
                 , obj#
                 , dataobj#
                 , dbid
                 , owner
                 , object_name
                 , subobject_name
                 , object_type
                 , tablespace_name
                 )
            select /*+ ordered index(ss1) */
                   vs.ts#
                 , vs.obj#
                 , vs.dataobj#
                 , p_dbid
                 , vs.owner
                 , vs.object_name
                 , vs.subobject_name
                 , vs.object_type
                 , vs.tablespace_name
              from stats$seg_stat       ss1,
                   v$segment_statistics vs
             where vs.dataobj#         = ss1.dataobj#
               and vs.obj#             = ss1.obj#
               and vs.ts#              = ss1.ts#
               and ss1.snap_id         = l_snap_id
               and ss1.dbid            = p_dbid
               and ss1.instance_number = p_instance_number
               and vs.statistic#       = 0
               and not exists (select 1
                                 from stats$seg_stat_obj ss2
                                where ss2.dataobj# = ss1.dataobj#
                                  and ss2.obj#     = ss1.obj#
                                  and ss2.ts#      = ss1.ts#)
             order by dataobj#,obj#,ts#,dbid;    -- deadlock avoidance
            l_insert_done := TRUE;
          exception
            when DUP_VAL_ON_INDEX then
              l_counter := l_counter + 1;
          end;
        end loop;


   END snap_segment;

  /* ---------------------------------------------------------------- */

    PROCEDURE snap_session IS

    /*  Capture Session-specific stats */

     begin

         insert into stats$sesstat
              ( snap_id
              , dbid
              , instance_number
              , statistic#
              , value
              )
         select l_snap_id
              , p_dbid
              , p_instance_number
              , statistic#
              , value
           from v$sesstat
          where sid = l_session_id;

         insert into stats$session_event
              ( snap_id
              , dbid
              , instance_number
              , event
              , total_waits
              , total_timeouts
              , time_waited_micro
              , max_wait
              )
         select l_snap_id
              , p_dbid
              , p_instance_number
              , event
              , total_waits
              , total_timeouts
              , time_waited_micro
              , max_wait
           from v$session_event
          where sid = l_session_id;

         insert into stats$sess_time_model
              ( snap_id
              , dbid
              , instance_number
              , stat_id
              , value
              )
         select l_snap_id
              , p_dbid
              , p_instance_number
              , stat_id
              , value
           from v$sess_time_model
          where sid = l_session_id;


   END snap_session;

  /* ---------------------------------------------------------------- */

    PROCEDURE snap_latch IS

    /*  Capture Latch details statistics */

     begin

         insert into stats$latch_children
              ( snap_id
              , dbid
              , instance_number
              , latch#
              , child#
              , gets
              , misses
              , sleeps
              , immediate_gets
              , immediate_misses
              , spin_gets
              , wait_time
              )
         select l_snap_id
              , p_dbid
              , p_instance_number
              , latch#
              , child#
              , gets 
              , misses
              , sleeps
              , immediate_gets
              , immediate_misses
              , spin_gets
              , wait_time
           from v$latch_children;

         insert into stats$latch_parent
              ( snap_id
              , dbid
              , instance_number
              , latch#
              , level#
              , gets
              , misses
              , sleeps
              , immediate_gets
              , immediate_misses
              , spin_gets
              , wait_time
              )
         select l_snap_id
              , p_dbid
              , p_instance_number
              , latch#
              , level#
              , gets 
              , misses
              , sleeps
              , immediate_gets
              , immediate_misses
              , spin_gets
              , wait_time
           from v$latch_parent;

   END snap_latch;


  /* ---------------------------------------------------------------- */

    PROCEDURE snap_advisors IS

    /*  Capture Memory advice views */

     begin

        insert into stats$db_cache_advice
             ( snap_id
             , dbid
             , instance_number
             , id
             , name
             , block_size
             , buffers_for_estimate
             , advice_status
             , size_for_estimate
             , size_factor
             , estd_physical_read_factor
             , estd_physical_reads
             , estd_physical_read_time
             , estd_pct_of_db_time_for_reads
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , id
             , name
             , block_size
             , buffers_for_estimate
             , advice_status
             , size_for_estimate
             , size_factor
             , estd_physical_read_factor
             , estd_physical_reads
             , estd_physical_read_time
             , estd_pct_of_db_time_for_reads
          from v$db_cache_advice
         where advice_status = 'ON';


        insert into stats$shared_pool_advice
             ( snap_id
             , dbid
             , instance_number
             , shared_pool_size_for_estimate
             , shared_pool_size_factor
             , estd_lc_size
             , estd_lc_memory_objects
             , estd_lc_time_saved
             , estd_lc_time_saved_factor
             , estd_lc_load_time
             , estd_lc_load_time_factor
             , estd_lc_memory_object_hits
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , shared_pool_size_for_estimate
             , shared_pool_size_factor
             , estd_lc_size
             , estd_lc_memory_objects
             , estd_lc_time_saved
             , estd_lc_time_saved_factor
             , estd_lc_load_time
             , estd_lc_load_time_factor
             , estd_lc_memory_object_hits
          from v$shared_pool_advice;


        insert into stats$sga_target_advice
             ( snap_id
             , dbid
             , instance_number
             , sga_size
             , sga_size_factor
             , estd_db_time
             , estd_db_time_factor
             , estd_physical_reads
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , sga_size
             , sga_size_factor
             , estd_db_time
             , estd_db_time_factor
             , estd_physical_reads
          from v$sga_target_advice;


        insert into stats$memory_target_advice
             ( snap_id
             , dbid
             , instance_number
             , memory_size
             , memory_size_factor
             , estd_db_time
             , estd_db_time_factor
             , version
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , memory_size
             , memory_size_factor
             , estd_db_time
             , estd_db_time_factor
             , version
          from v$memory_target_advice;


        insert into stats$pga_target_advice
             ( snap_id
             , dbid
             , instance_number
             , pga_target_for_estimate
             , pga_target_factor
             , advice_status
             , bytes_processed
             , estd_time
             , estd_extra_bytes_rw
             , estd_pga_cache_hit_percentage
             , estd_overalloc_count
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , pga_target_for_estimate
             , pga_target_factor
             , advice_status
             , bytes_processed
             , estd_time
             , estd_extra_bytes_rw
             , estd_pga_cache_hit_percentage
             , estd_overalloc_count
          from v$pga_target_advice
         where advice_status = 'ON';


        insert into stats$streams_pool_advice
             ( snap_id
             , dbid
             , instance_number
             , streams_pool_size_for_estimate
             , streams_pool_size_factor
             , estd_spill_count
             , estd_spill_time
             , estd_unspill_count
             , estd_unspill_time
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , streams_pool_size_for_estimate
             , streams_pool_size_factor
             , estd_spill_count
             , estd_spill_time
             , estd_unspill_count
             , estd_unspill_time
          from v$streams_pool_advice
         where streams_pool_size_for_estimate >0;


        insert into stats$java_pool_advice
             ( snap_id
             , dbid
             , instance_number
             , java_pool_size_for_estimate
             , java_pool_size_factor
             , estd_lc_size
             , estd_lc_memory_objects
             , estd_lc_time_saved
             , estd_lc_time_saved_factor
             , estd_lc_load_time
             , estd_lc_load_time_factor
             , estd_lc_memory_object_hits
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , java_pool_size_for_estimate
             , java_pool_size_factor
             , estd_lc_size
             , estd_lc_memory_objects
             , estd_lc_time_saved
             , estd_lc_time_saved_factor
             , estd_lc_load_time
             , estd_lc_load_time_factor
             , estd_lc_memory_object_hits
          from v$java_pool_advice;
 

     end snap_advisors;

  /* ---------------------------------------------------------------- */

    PROCEDURE snap_file_io IS

     begin

        insert into stats$iostat_function
             ( snap_id
             , dbid
             , instance_number
             , function_id
             , small_read_megabytes
             ,  small_write_megabytes
             , large_read_megabytes
             , large_write_megabytes
             , small_read_reqs
             , small_write_reqs
             , large_read_reqs
             , large_write_reqs
             , number_of_waits
             , wait_time
             )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , function_id
            , small_read_megabytes
            , small_write_megabytes
            , large_read_megabytes
            , large_write_megabytes
            , small_read_reqs
            , small_write_reqs
            , large_read_reqs
            , large_write_reqs
            , number_of_waits
            , wait_time
         from v$iostat_function;


       l_insert_done := FALSE;
       l_counter := 0;
       while (not (l_insert_done) and l_counter < l_counter_maxvalue)
       loop
         begin
           insert into stats$filestatxs
                ( snap_id
                , dbid
                , instance_number
                , tsname
                , filename
                , phyrds
                , phywrts
                , singleblkrds
                , readtim
                , writetim
                , singleblkrdtim
                , phyblkrd
                , phyblkwrt
                , wait_count
                , time
                , file#
                )
           select l_snap_id
                , p_dbid
                , p_instance_number
                , tsname
                , filename
                , phyrds
                , phywrts
                , singleblkrds
                , readtim
                , writetim
                , singleblkrdtim
                , phyblkrd
                , phyblkwrt
                , wait_count
                , time
                , file#
             from stats$v$filestatxs;
           l_insert_done := TRUE;
         exception
           when CFINCREAD then
             l_counter := l_counter + 1;
         end;
       end loop;

       insert into stats$file_histogram
            ( snap_id
            , dbid
            , instance_number
            , file#
            , singleblkrdtim_milli
            , singleblkrds
            )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , file#
            , singleblkrdtim_milli
            , singleblkrds
        from v$file_histogram
       where singleblkrds > 0 ;

       /*  Retry Temp file stats, in case of controlfile contention  */
       l_counter := 0;
       l_insert_done := FALSE;
       while (not (l_insert_done) and l_counter < l_counter_maxvalue)
       loop
         begin
           insert into stats$tempstatxs
                ( snap_id
                , dbid
                , instance_number
                , tsname
                , filename
                , phyrds
                , phywrts
                , singleblkrds
                , readtim
                , writetim
                , singleblkrdtim
                , phyblkrd
                , phyblkwrt
                , wait_count
                , time
                , file#
                )
           select l_snap_id
                , p_dbid
                , p_instance_number
                , tsname
                , filename
                , phyrds
                , phywrts
                , singleblkrds
                , readtim
                , writetim
                , singleblkrdtim
                , phyblkrd
                , phyblkwrt
                , wait_count
                , time
                , file#
             from stats$v$tempstatxs;
           l_insert_done := TRUE;
         exception
           when CFINCREAD then
             l_counter := l_counter + 1;
         end;
       end loop;


     end snap_file_io;

  /* ---------------------------------------------------------------- */

    PROCEDURE snap_memory_mgmt_stats IS

     begin

        insert into stats$memory_dynamic_comps
             ( snap_id
             , dbid
             , instance_number
             , component
             , current_size
             , min_size
             , max_size
             , user_specified_size
             , oper_count
             , last_oper_type
             , last_oper_mode
             , last_oper_time
             , granule_size
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , component
             , current_size
             , min_size
             , max_size
             , user_specified_size
             , oper_count
             , last_oper_type
             , last_oper_mode
             , last_oper_time
             , granule_size
        from v$memory_dynamic_components;


        -- Insert completed resize ops
        insert into stats$memory_resize_ops
             ( snap_id
             , dbid
             , instance_number
             , component
             , oper_type
             , oper_mode
             , start_time
             , initial_size
             , target_size
             , final_size
             , status
             , end_time
             , parameter
             , num_ops
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , component
             , oper_type
             , nvl(oper_mode,'-')
             , start_time
             , initial_size
             , target_size
             , final_size
             , status
             , end_time
             , parameter
             , count(1)
        from v$memory_resize_ops
       where start_time > l_max_resize_ops_start_time
      group by l_snap_id, p_dbid, p_instance_number
             , component, oper_type, oper_mode, start_time, parameter
             , initial_size, target_size, final_size, status, end_time;


      insert into stats$pgastat
           ( snap_id
           , dbid
           , instance_number
           , name
           , value
           )
      select l_snap_id
           , p_dbid
           , p_instance_number
           , name
           , value
        from v$pgastat
       where value > 0;

      insert into stats$sql_workarea_histogram
           ( snap_id
           , dbid
           , instance_number
           , low_optimal_size
           , high_optimal_size
           , optimal_executions
           , onepass_executions
           , multipasses_executions
           , total_executions
           )
      select l_snap_id
           , p_dbid
           , p_instance_number
           , low_optimal_size
           , high_optimal_size
           , optimal_executions
           , onepass_executions
           , multipasses_executions
           , total_executions
        from v$sql_workarea_histogram
       where total_executions > 0;

     insert into stats$process_rollup
          ( snap_id
          , dbid
          , instance_number
          , pid
          , serial#
          , spid
          , program
          , background
          , pga_used_mem
          , pga_alloc_mem
          , pga_freeable_mem
          , max_pga_alloc_mem
          , max_pga_max_mem
          , avg_pga_alloc_mem
          , stddev_pga_alloc_mem
          , num_processes
          )
     select *
       from (select *
               from (select l_snap_id
                          , p_dbid
                          , p_instance_number
                          , nvl(pid, -9)          pid
                          , nvl(serial#, -9)      serial#
                          , decode(pid, null, null, max(spid))           spid
                          , decode(pid, null, null, max(program))        program
                          , decode(pid, null, null, max(background))     background
                          , sum(pga_used_mem)     pga_used_mem
                          , sum(pga_alloc_mem)    pga_alloc_mem
                          , sum(pga_freeable_mem) pga_freeable_mem
                          , max(pga_alloc_mem)    max_pga_alloc_mem
                          , max(pga_max_mem)      max_pga_max_mem
                          , decode(pid, null, avg(pga_alloc_mem), null)    avg_pga_alloc_mem
                          , decode(pid, null, stddev(pga_alloc_mem), null) stddev_pga_alloc_mem
                          , decode(pid, null, count(pid), null)            num_processes
                       from v$process
                      where program != 'PSEUDO'
                      group by grouping sets ( (pid, serial#), () )
                    )
              where pid = -9
                 or pga_alloc_mem >= (p_def_proc_mem_th *1024*1024)
              order by pga_alloc_mem desc
            )
      where rownum <= (p_def_num_procs + 1);


      -- This statement must use column alias' in the select list for the
      -- l_snap_id, p_dbid and p_instance_number vars to avoid bug 3824971

      insert into stats$process_memory_rollup
          ( snap_id
          , dbid
          , instance_number
          , pid
          , serial#
          , category
          , allocated
          , used
          , max_allocated
          , max_max_allocated
          , avg_allocated
          , stddev_allocated
          , non_zero_allocations
          )
     select *
       from (select l_snap_id                 snap_id  -- required for 3824971
                  , p_dbid                    dbid
                  , p_instance_number         instance_number
                  , nvl(pm.pid, -9)           pid 
                  , nvl(pm.serial#, -9)       serial#
                  , pm.category
                  , sum(pm.allocated)         allocated
                  , sum(pm.used)              used
                  , max(pm.allocated)         max_allocated
                  , max(pm.max_allocated)     max_max_allocated
                  , decode(pid, null, avg(pm.allocated), null)    avg_allocated
                  , decode(pid, null, stddev(pm.allocated), null) stddev_allocated
                  , decode(pid, null ,sum(decode(allocated, 0, 0, 1)), null) non_zero_allocations
               from v$process_memory pm
              group by grouping sets (  (pm.pid, pm.serial#, pm.category)
                                      , (pm.category) )
            ) g
      where  g.pid = -9                                       -- category summary rows
         or (g.pid, g.serial#) in (select pr.pid, pr.serial#  -- detail rows
                                     from stats$process_rollup pr
                                    where pr.snap_id         = l_snap_id
                                      and pr.dbid            = p_dbid
                                      and pr.instance_number = p_instance_number
                                  );

     end snap_memory_mgmt_stats;

  /* ---------------------------------------------------------------- */

    PROCEDURE snap_streams IS

    /*  Capture Streams-related statistics */

     begin

        insert into stats$streams_capture
             ( snap_id
             , dbid
             , instance_number
             , capture_name
             , startup_time
             , total_messages_captured
             , total_messages_enqueued
             , elapsed_capture_time
             , elapsed_rule_time
             , elapsed_enqueue_time
             , elapsed_lcr_time
             , elapsed_redo_wait_time
             , elapsed_pause_time
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , capture_name
             , startup_time
             , total_messages_captured
             , total_messages_enqueued
             , elapsed_capture_time
             , elapsed_rule_time
             , elapsed_enqueue_time
             , elapsed_lcr_time
             , elapsed_redo_wait_time
             , elapsed_pause_time
         from v$streams_capture;

       insert into stats$streams_apply_sum
             ( snap_id
             , dbid
             , instance_number
             , apply_name
             , startup_time
             , reader_total_messages_dequeued
             , reader_elapsed_dequeue_time
             , reader_elapsed_schedule_time
             , coord_total_received
             , coord_total_applied
             , coord_total_wait_deps
             , coord_total_wait_commits
             , coord_elapsed_schedule_time
             , server_total_messages_applied
             , server_elapsed_dequeue_time
             , server_elapsed_apply_time
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , max(c.apply_name)
             , max(c.startup_time)
             , max(r.total_messages_dequeued)
             , max(r.elapsed_dequeue_time)
             , max(r.elapsed_schedule_time)
             , max(c.total_received)
             , max(c.total_applied)
             , max(c.total_wait_deps)
             , max(c.total_wait_commits)
             , max(c.elapsed_schedule_time)
             , sum(s.total_messages_applied)
             , sum(s.elapsed_dequeue_time)
             , sum(s.elapsed_apply_time)
          from v$streams_apply_coordinator c
             , v$streams_apply_reader      r
             , v$streams_apply_server      s
         where c.apply_name = r.apply_name
           and c.apply_name = s.apply_name
         group by c.apply_name;


        insert into stats$propagation_sender
             ( snap_id
             , dbid
             , instance_number
             , queue_schema
             , queue_name
             , dblink
             , dst_queue_schema
             , dst_queue_name
             , startup_time
             , total_msgs
             , total_bytes
             , elapsed_dequeue_time
             , elapsed_pickle_time
             , elapsed_propagation_time
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , queue_schema
             , queue_name
             , dblink
             , nvl(dst_queue_schema, '-')   -- Do not allow null
             , nvl(dst_queue_name, '-')     -- as part of PK
             , startup_time
             , total_msgs
             , total_bytes
             , elapsed_dequeue_time
             , elapsed_pickle_time
             , elapsed_propagation_time
          from v$propagation_sender;


        insert into stats$propagation_receiver
             ( snap_id
             , dbid
             , instance_number
             , src_queue_schema
             , src_queue_name
             , src_dbname
             , dst_queue_schema
             , dst_queue_name
             , startup_time
             , elapsed_unpickle_time
             , elapsed_rule_time
             , elapsed_enqueue_time
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , src_queue_schema
             , src_queue_name
             , nvl(src_dbname, '-')        -- Do not allow null
             , nvl(dst_queue_schema, '-')  -- as part of PK
             , nvl(dst_queue_name, '-')    --
             , startup_time
             , elapsed_unpickle_time
             , elapsed_rule_time
             , elapsed_enqueue_time
          from v$propagation_receiver;

        insert into stats$buffered_queues
             ( snap_id
             , dbid
             , instance_number
             , queue_schema
             , queue_name
             , startup_time
             , num_msgs
             , cnum_msgs
             , cspill_msgs
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , v.queue_schema
             , v.queue_name
             , v.startup_time
             , v.num_msgs
             , v.cnum_msgs
             , v.cspill_msgs
         from v$buffered_queues v;

        insert into stats$buffered_subscribers
             ( snap_id
             , dbid
             , instance_number
             , queue_schema
             , queue_name
             , subscriber_id
             , subscriber_name
             , subscriber_address
             , subscriber_type
             , startup_time
             , num_msgs
             , cnum_msgs
             , total_spilled_msg
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , v.queue_schema
             , v.queue_name
             , v.subscriber_id
             , v.subscriber_name
             , v.subscriber_address
             , v.subscriber_type
             , v.startup_time
             , v.num_msgs
             , v.cnum_msgs
             , v.total_spilled_msg
          from v$buffered_subscribers v;

        insert into stats$rule_set
             ( snap_id
             , dbid
             , instance_number
             , owner
             , name
             , startup_time
             , cpu_time
             , elapsed_time
             , evaluations
             , sql_free_evaluations
             , sql_executions
             , reloads
             )
        select l_snap_id
             , p_dbid
             , p_instance_number
             , owner
             , name
             , first_load_time
             , cpu_time
             , elapsed_time
             , evaluations
             , sql_free_evaluations
             , sql_executions
             , reloads
          from v$rule_set;


   END snap_streams;

  /* ---------------------------------------------------------------- */

    PROCEDURE snap_sql IS

     begin

        if l_old_sql_capture_mth = 'FALSE' then

           /*  The new method - v$sqlstats */

           /*  Gather summary statistics  */

           insert into stats$sql_statistics
                ( snap_id
                , dbid
                , instance_number
                , total_sql
                , total_sql_mem
                , single_use_sql
                , single_use_sql_mem
                , total_cursors
                )
           select l_snap_id
                , p_dbid
                , p_instance_number
                , count(1)
                , sum(sharable_mem)
                , sum(decode(executions, 1, 1,            0))
                , sum(decode(executions, 1, sharable_mem, 0))
                , sum(version_count)
             from stats$v$sqlstats_summary
            where sharable_mem > 0;


          /*  Gather SQL statements which exceed any threshold,
              excluding obsolete parent cursors
           */

           insert into stats$sql_summary
                ( snap_id
                , dbid
                , instance_number
                , text_subset
                , sql_id
                , sharable_mem
                , sorts
                , module
                , loaded_versions
                , fetches
                , executions
                , px_servers_executions
                , end_of_fetch_count
                , loads
                , invalidations
                , parse_calls
                , disk_reads
                , direct_writes
                , buffer_gets
                , application_wait_time
                , concurrency_wait_time
                , cluster_wait_time
                , user_io_wait_time
                , plsql_exec_time
                , java_exec_time
                , rows_processed
                , command_type
                , address
                , hash_value
                , old_hash_value
                , version_count
                , cpu_time
                , elapsed_time
                , avg_hard_parse_time
                , outline_sid
                , outline_category
                , child_latch
                , sql_profile
                , program_id
                , program_line#
                , exact_matching_signature
                , force_matching_signature
                , last_active_time
               )
          select /*+ index (sql.GV$SQL.X$KGLOB) */
                 l_snap_id
               , p_dbid
               , p_instance_number
               , max(substrb(sql_text,1,31)) text_subset
               , max(sql_id)                 sql_id
               , sum(sharable_mem)           sharable_mem
               , sum(sorts)                  sorts
               , max(module)                 module
               , sum(loaded_versions)        loaded_versions
               , sum(fetches)                fetches
               , sum(executions)             executions
               , sum(px_servers_executions)  px_servers_executions
               , sum(end_of_fetch_count)     end_of_fetch_count
               , sum(loads)                  loads
               , sum(invalidations)          invalidations
               , sum(parse_calls)            parse_calls
               , sum(disk_reads)             disk_reads
               , sum(direct_writes)          direct_writes
               , sum(buffer_gets)            buffer_gers
               , sum(application_wait_time)  application_wait_time
               , sum(concurrency_wait_time)  concurrency_wait_time
               , sum(cluster_wait_time)      cluster_wait_time
               , sum(user_io_wait_time)      user_io_wait_time
               , sum(plsql_exec_time)        plsql_exec_time
               , sum(java_exec_time)         java_exec_time
               , sum(rows_processed)         rows_processed
               , max(command_type)           command_type
               , address
               , max(hash_value)             hash_value
               , old_hash_value
               , count(1)                    version_count
               , sum(cpu_time)               cpu_time
               , sum(elapsed_time)           elapsed_time
               , null                        avg_hard_parse_time
               , max(outline_sid)            outline_sid
               , max(outline_category)       outline_category
               , max(child_latch)            child_latch
               , max(sql_profile)            sql_profile
               , max(program_id)             program_id
               , max(program_line#)          program_line#
               , max(exact_matching_signature) exact_matching_signature
               , max(force_matching_signature) force_matching_signature
               , max(last_active_time)       last_active_time
            from v$sql sql
           where is_obsolete = 'N'
             and sql_id in (select /*+ unnest full (sqlstats) */
                                   sql_id 
                              from stats$v$sqlstats_summary sqlstats
                             where (   buffer_gets   > l_buffer_gets_th 
                                    or disk_reads    > l_disk_reads_th
                                    or parse_calls   > l_parse_calls_th
                                    or executions    > l_executions_th
                                    or sharable_mem  > l_sharable_mem_th
                                    or version_count > l_version_count_th
                                   )
                           )
           group by old_hash_value, address;


        else /*  The old method - stats$v$sqlxs */

           /*  Gather summary statistics  */

           insert into stats$sql_statistics
                ( snap_id
                , dbid
                , instance_number
                , total_sql
                , total_sql_mem
                , single_use_sql
                , single_use_sql_mem
                , total_cursors
                )
           select l_snap_id
                , p_dbid
                , p_instance_number
                , count(1)
                , sum(sharable_mem)
                , sum(decode(executions, 1, 1,            0))
                , sum(decode(executions, 1, sharable_mem, 0))
                , sum(version_count)
           from stats$v$sqlxs
         where is_obsolete = 'N';


       /*  Gather SQL statements which exceed any threshold,
           excluding obsolete parent cursors
        */

           insert into stats$sql_summary
                ( snap_id
                , dbid
                , instance_number
                , text_subset
                , sql_id
                , sharable_mem
                , sorts
                , module
                , loaded_versions
                , fetches
                , executions
                , px_servers_executions
                , end_of_fetch_count
                , loads
                , invalidations
                , parse_calls
                , disk_reads
                , direct_writes
                , buffer_gets
                , application_wait_time
                , concurrency_wait_time
                , cluster_wait_time
                , user_io_wait_time
                , plsql_exec_time
                , java_exec_time
                , rows_processed
                , command_type
                , address
                , hash_value
                , old_hash_value
                , version_count
                , cpu_time
                , elapsed_time
                , avg_hard_parse_time
                , outline_sid
                , outline_category
                , child_latch
                , sql_profile
                , program_id
                , program_line#
                , exact_matching_signature
                , force_matching_signature
                , last_active_time
                )
           select l_snap_id
                , p_dbid
                , p_instance_number
                , substrb(sql_text,1,31)
                , sql_id
                , sharable_mem
                , sorts
                , module
                , loaded_versions
                , fetches
                , executions
                , px_servers_executions
                , end_of_fetch_count
                , loads
                , invalidations
                , parse_calls
                , disk_reads
                , direct_writes
                , buffer_gets
                , application_wait_time
                , concurrency_wait_time
                , cluster_wait_time
                , user_io_wait_time
                , plsql_exec_time
                , java_exec_time
                , rows_processed
                , command_type
                , address
                , hash_value
                , old_hash_value
                , version_count
                , cpu_time
                , elapsed_time
                , avg_hard_parse_time
                , outline_sid
                , outline_category
                , child_latch
                , sql_profile
                , program_id
                , program_line#
                , exact_matching_signature
                , force_matching_signature
                , last_active_time
             from stats$v$sqlxs
            where is_obsolete = 'N'
              and (   buffer_gets   > l_buffer_gets_th 
                   or disk_reads    > l_disk_reads_th
                   or parse_calls   > l_parse_calls_th
                   or executions    > l_executions_th
                   or sharable_mem  > l_sharable_mem_th
                   or version_count > l_version_count_th
                  );


        end if;


         /*  Insert the SQL Text for hash_values captured in the snapshot
             into stats$sqltext if it's not already there.  Identify SQL which
             execeeded the threshold by querying stats$sql_summary for this
             snapid and database instance
          */

        l_counter := 0;
        l_insert_done := FALSE;
        while (not (l_insert_done) and l_counter < l_counter_maxvalue) loop

          begin

            insert into stats$sqltext
                     ( old_hash_value
                     , text_subset
                     , piece
                     , sql_id
                     , sql_text
                     , address
                     , command_type
                     , last_snap_id
                     )
                select /*+ ordered use_nl(vst) */
                       new_sql.old_hash_value
                     , new_sql.text_subset
                     , vst.piece
                     , vst.sql_id
                     , vst.sql_text
                     , vst.address
                     , vst.command_type
                     , new_sql.snap_id
                  from (select hash_value      -- switch to using new hash_value
                             , old_hash_value  -- for looking up cursors
                             , address         -- as new hash_value in v$sql indexed
                             , text_subset
                             , snap_id
                          from stats$sql_summary ss
                         where ss.snap_id         = l_snap_id
                           and ss.dbid            = p_dbid
                           and ss.instance_number = p_instance_number
                           and not exists (select 1
                                             from stats$sqltext sst
                                            where sst.old_hash_value = ss.old_hash_value
                                              and sst.text_subset    = ss.text_subset
                                              and sst.piece          = 0
                                          )
                       )          new_sql
                     , v$sqltext  vst
                 where vst.hash_value     = new_sql.hash_value
                   and vst.address        = new_sql.address
                 order by new_sql.old_hash_value, new_sql.text_subset
                        , vst.piece;   -- deadlock avoidance

            l_insert_done := TRUE;

          exception
            when DUP_VAL_ON_INDEX then
              l_counter := l_counter + 1;
          end;

        end loop;



     IF l_snap_level >= 6 THEN

         /*  Identify SQL which execeeded the threshold by querying 
             stats$sql_summary for this snapid and database instance.

             Note: original algorithm only captured plans the first time a new
             plan appeared.  New algorithm captures each distinct plan usage
             for each high-load sql statements for each snapshot.

             Omit capturing plan usage information for cursors which
             have a zero plan hash value.

             Currently this is captured in a level 6 (or greater)
             snapshot, however this may be integrated into level 5 
             snapshot at a later date.
          */

         insert into stats$sql_plan_usage
              ( snap_id
              , dbid
              , instance_number
              , old_hash_value
              , text_subset
              , plan_hash_value
              , sql_id
              , hash_value
              , cost
              , address
              , optimizer
              , last_active_time
              )
         select /*+ ordered use_nl(sq) index(sq) */
                l_snap_id
              , p_dbid
              , p_instance_number
              , ss.old_hash_value
              , ss.text_subset
              , sq.plan_hash_value
              , max(ss.sql_id)
              , max(ss.hash_value)
              , nvl(sq.optimizer_cost,-9)
              , max(ss.address)
              , max(sq.optimizer_mode)
              , max(sq.last_active_time)
           from stats$sql_summary ss
              , v$sql             sq
          where ss.snap_id         = l_snap_id
            and ss.dbid            = p_dbid
            and ss.instance_number = p_instance_number
            and sq.hash_value      = ss.hash_value
            and sq.address         = ss.address
            and sq.plan_hash_value > 0
          group by l_snap_id
              , p_dbid
              , p_instance_number
              , ss.old_hash_value
              , ss.text_subset
              , sq.plan_hash_value
              , nvl(sq.optimizer_cost,-9);


         /*  For all new hash_value, plan_hash_value, cost combinations
             just captured, get the optimizer plans, if we don't already
             have them.  Note that the plan (and hence the plan hash value)
             comprises the access path and the join order (and not 
             variable factors such as the cardinality).
          */

        l_counter := 0;
        l_insert_done := FALSE;
        while (not (l_insert_done) and l_counter < l_counter_maxvalue) loop

          begin

            insert into stats$sql_plan
                 ( plan_hash_value
                 , id
                 , operation
                 , options
                 , object_node
                 , object#
                 , object_owner
                 , object_name
                 , object_alias
                 , object_type
                 , optimizer
                 , parent_id
                 , depth
                 , position
                 , search_columns
                 , cost
                 , cardinality
                 , bytes
                 , other_tag
                 , partition_start
                 , partition_stop
                 , partition_id
                 , other
                 , distribution
                 , cpu_cost
                 , io_cost
                 , temp_space
                 , access_predicates
                 , filter_predicates
                 , projection
                 , time
                 , qblock_name
                 , remarks
                 , snap_id
                 )
            select /*+ ordered use_nl(s) use_nl(sp.p) */
                   new_plan.plan_hash_value
                 , sp.id
                 , max(sp.operation)
                 , max(sp.options)
                 , max(sp.object_node)
                 , max(sp.object#)
                 , max(sp.object_owner)
                 , max(sp.object_name)
                 , max(sp.object_alias)
                 , max(sp.object_type)
                 , max(sp.optimizer)
                 , max(sp.parent_id)
                 , max(sp.depth)
                 , max(sp.position)
                 , max(sp.search_columns)
                 , max(sp.cost)
                 , max(sp.cardinality)
                 , max(sp.bytes)
                 , max(sp.other_tag)
                 , max(sp.partition_start)
                 , max(sp.partition_stop)
                 , max(sp.partition_id)
                 , max(sp.other)
                 , max(sp.distribution)
                 , max(sp.cpu_cost)
                 , max(sp.io_cost)
                 , max(sp.temp_space)
                 , 0 -- should be max(sp.access_predicates) (2254299)
                 , 0 -- should be max(sp.filter_predicates)
                 , max(sp.projection)
                 , max(sp.time)
                 , max(sp.qblock_name)
                 , max(sp.remarks)
                 , max(new_plan.snap_id)
              from (select /*+ index(spu) */
                           spu.plan_hash_value
                         , spu.hash_value    hash_value
                         , spu.address       address
                         , spu.text_subset   text_subset
                         , spu.snap_id       snap_id
                      from stats$sql_plan_usage spu
                     where spu.snap_id         = l_snap_id
                       and spu.dbid            = p_dbid
                       and spu.instance_number = p_instance_number
                       and not exists (select /*+ nl_aj */ *
                                         from stats$sql_plan ssp
                                        where ssp.plan_hash_value 
                                            = spu.plan_hash_value
                                      )
                   )          new_plan
                 , v$sql      s      -- join reqd to filter already known plans
                 , v$sql_plan sp
             where s.address         = new_plan.address
               and s.plan_hash_value = new_plan.plan_hash_value
               and s.hash_value      = new_plan.hash_value
               and sp.hash_value     = new_plan.hash_value
               and sp.address        = new_plan.address
               and sp.hash_value     = s.hash_value
               and sp.address        = s.address
               and sp.child_number   = s.child_number
             group by 
                   new_plan.plan_hash_value, sp.id
             order by
                   new_plan.plan_hash_value, sp.id; -- deadlock avoidance

            l_insert_done := TRUE;

          exception
            when DUP_VAL_ON_INDEX then
              l_counter := l_counter + 1;
          end;

        end loop;



     END IF;   /* snap level >=6 */


   END snap_sql;

  /* ---------------------------------------------------------------- */

   begin /* Function SNAP */

     /*  Get instance parameter defaults from stats$statspack_parameter,
         or use supplied parameters.
         If all parameters are specified, use them, otherwise get values
         from the parameters not specified from stats$statspack_parameter.
     */

     statspack.qam_statspack_parameter
       ( p_dbid
       , p_instance_number
       , i_snap_level, i_session_id, i_ucomment, i_num_sql
       , i_executions_th, i_parse_calls_th
       , i_disk_reads_th, i_buffer_gets_th, i_sharable_mem_th
       , i_version_count_th, i_seg_phy_reads_th
       , i_seg_log_reads_th, i_seg_buff_busy_th, i_seg_rowlock_w_th
       , i_seg_itl_waits_th, i_seg_cr_bks_rc_th, i_seg_cu_bks_rc_th
       , i_all_init, i_old_sql_capture_mth, i_pin_statspack
       , i_modify_parameter
       , l_snap_level, l_session_id, l_ucomment, l_num_sql
       , l_executions_th, l_parse_calls_th
       , l_disk_reads_th, l_buffer_gets_th, l_sharable_mem_th
       , l_version_count_th, l_seg_phy_reads_th
       , l_seg_log_reads_th, l_seg_buff_busy_th, l_seg_rowlock_w_th
       , l_seg_itl_waits_th, l_seg_cr_bks_rc_th, l_seg_cu_bks_rc_th
       , l_all_init, l_old_sql_capture_mth, l_pin_statspack);


     /*  Generate a snapshot id */
     select stats$snapshot_id.nextval, systimestamp
       into l_snap_id, l_snap_start_time
       from dual
      where rownum = 1;

     /*  Determine the serial# of the session to maintain stats for,
         if this was requested.
     */
     if l_session_id > 0 then
         if not GETSERIAL%ISOPEN then open GETSERIAL; end if;
         fetch GETSERIAL into l_serial#;
         if GETSERIAL%NOTFOUND then
             /*  Session has already disappeared - don't gather 
                statistics for this session in this snapshot */
             l_session_id := 0;
             l_serial#    := 0;
         end if; close GETSERIAL;
     else
       l_serial# := 0;
     end if;
 
     /*  The instance has been restarted since the last snapshot */
     if p_new_sga = 0
     then
        begin

          p_new_sga := 1;

          /*  Get the instance startup time, and other characteristics  */

          insert into stats$database_instance
               ( dbid
               , instance_number
               , startup_time
               , snap_id
               , parallel
               , version
               , db_name
               , instance_name
               , host_name
               , platform_name
               )
          select p_dbid
               , p_instance_number
               , p_startup_time
               , l_snap_id
               , p_parallel
               , p_version
               , p_name
               , p_instance_name
               , p_host_name
               , p_platform_name
            from sys.dual;


          /*  Insert any new TIME_MODEL statistic names into our reference 
              table
           */

          l_insert_done := FALSE;
          l_counter := 0;
          while (not (l_insert_done) and l_counter < l_counter_maxvalue) loop 
             begin

               merge into stats$time_model_statname stms
               using (select stat_id, stat_name
                        from v$sys_time_model
                     ) vstm
                  on (stms.stat_id = vstm.stat_id)
                when matched then
                  update 
                     set stms.stat_name  = vstm.stat_name
                   where stms.stat_name != vstm.stat_name
                when not matched then
                  insert (     stat_id,      stat_name)
                  values (vstm.stat_id, vstm.stat_name);

               l_insert_done := TRUE;
             exception
             when DUP_VAL_ON_INDEX then
                l_counter := l_counter + 1;
             end;
          end loop;


          /*  Insert any new OSStat statistic names into our reference table 
           */

          l_insert_done := FALSE;
          l_counter := 0;
          while (not (l_insert_done) and l_counter < l_counter_maxvalue) loop 
             begin

               merge into stats$osstatname sosn
               using (select osstat_id, stat_name, cumulative
                        from v$osstat
                     ) vosn
                  on (vosn.osstat_id = sosn.osstat_id)
                 when matched then
                  update
                     set sosn.stat_name   = vosn.stat_name
                       , sosn.cumulative  = vosn.cumulative
                   where sosn.stat_name           != vosn.stat_name
                      or nvl(sosn.cumulative,'a') != vosn.cumulative
                 when not matched then
                   insert (     osstat_id,      stat_name,      cumulative)
                   values (vosn.osstat_id, vosn.stat_name, vosn.cumulative);

               l_insert_done := TRUE;

             exception
             when DUP_VAL_ON_INDEX then
                l_counter := l_counter + 1;
             end;
          end loop;


          /*  Insert any new IOStat Function Types into our reference table
           */

          l_insert_done := FALSE;
          l_counter := 0;
          while (not (l_insert_done) and l_counter < l_counter_maxvalue) loop 
             begin

               merge into stats$iostat_function_name sifn
               using (select function_id, function_name
                        from v$iostat_function
                     ) vifn
                  on (vifn.function_id = sifn.function_id)
                 when matched then
                  update
                     set sifn.function_name  = vifn.function_name
                   where sifn.function_name != vifn.function_name
                 when not matched then
                   insert (     function_id,        function_name)
                   values (vifn.function_id,   vifn.function_name);

               l_insert_done := TRUE;

             exception
             when DUP_VAL_ON_INDEX then
                l_counter := l_counter + 1;
             end;
          end loop;

          commit;
          
      end;

     end if; /* new SGA */


    /* Work out the previous snap_id for this instance */

     select nvl(max(snap_id), 0)
       into l_prev_snap_id
       from stats$snapshot
      where dbid            = p_dbid
        and instance_number = p_instance_number;


    /* Work out the max undo stat time, used for gathering undo stat data */

     select nvl(max(begin_time), to_date('01011900','DDMMYYYY'))
       into l_max_begin_time
       from stats$undostat
      where dbid            = p_dbid
        and instance_number = p_instance_number;


    /* Work out the max Resize Ops time, used for gathering resize ops data */

     select nvl(max(start_time), to_date('01011900','DDMMYYYY'))
       into l_max_resize_ops_start_time
       from stats$memory_resize_ops
      where dbid            = p_dbid
        and instance_number = p_instance_number;


     /*  Save the snapshot characteristics */

     insert into stats$snapshot
          ( snap_id, dbid, instance_number
          , snap_time, startup_time
          , session_id, snap_level, ucomment
          , executions_th, parse_calls_th, disk_reads_th
          , buffer_gets_th, sharable_mem_th
          , version_count_th, seg_phy_reads_th
          , seg_log_reads_th, seg_buff_busy_th, seg_rowlock_w_th
          , seg_itl_waits_th, seg_cr_bks_rc_th, seg_cu_bks_rc_th
          , serial#, all_init)
     values
          ( l_snap_id, p_dbid, p_instance_number
          , cast(l_snap_start_time as date), p_startup_time 
          , l_session_id, l_snap_level, l_ucomment
          , l_executions_th, l_parse_calls_th, l_disk_reads_th
          , l_buffer_gets_th, l_sharable_mem_th
          , l_version_count_th, l_seg_phy_reads_th
          , l_seg_log_reads_th, l_seg_buff_busy_th, l_seg_rowlock_w_th
          , l_seg_itl_waits_th, l_seg_cr_bks_rc_th, l_seg_cu_bks_rc_th
          , l_serial#, l_all_init);


     /*  Begin gathering statistics */   

     snap_file_io;

     insert into stats$librarycache
          ( snap_id
          , dbid
          , instance_number
          , namespace
          , gets
          , gethits
          , pins
          , pinhits
          , reloads
          , invalidations
          , dlm_lock_requests
          , dlm_pin_requests
          , dlm_pin_releases
          , dlm_invalidation_requests
          , dlm_invalidations
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , namespace
          , gets
          , gethits
          , pins
          , pinhits
          , reloads
          , invalidations
          , dlm_lock_requests
          , dlm_pin_requests
          , dlm_pin_releases
          , dlm_invalidation_requests
          , dlm_invalidations
       from v$librarycache;
   
     insert into stats$buffer_pool_statistics
          ( snap_id
          , dbid
          , instance_number
          , id
          , name
          , block_size
          , set_msize
          , cnum_repl
          , cnum_write
          , cnum_set
          , buf_got
          , sum_write
          , sum_scan
          , free_buffer_wait
          , write_complete_wait
          , buffer_busy_wait
          , free_buffer_inspected
          , dirty_buffers_inspected
          , db_block_change
          , db_block_gets
          , consistent_gets
          , physical_reads
          , physical_writes
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , id
          , name
          , block_size
          , set_msize
          , cnum_repl
          , cnum_write
          , cnum_set
          , buf_got
          , sum_write
          , sum_scan
          , free_buffer_wait
          , write_complete_wait
          , buffer_busy_wait
          , free_buffer_inspected
          , dirty_buffers_inspected
          , db_block_change
          , db_block_gets
          , consistent_gets
          , physical_reads
          , physical_writes
       from v$buffer_pool_statistics;
  
     insert into stats$rollstat
          ( snap_id
          , dbid
          , instance_number
          , usn
          , extents
          , rssize
          , writes
          , xacts
          , gets
          , waits
          , optsize
          , hwmsize
          , shrinks
          , wraps
          , extends
          , aveshrink
          , aveactive
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , usn
          , extents
          , rssize
          , writes
          , xacts
          , gets
          , waits
          , optsize
          , hwmsize
          , shrinks
          , wraps
          , extends
          , aveshrink
          , aveactive
       from v$rollstat;
   
     insert into stats$rowcache_summary
          ( snap_id
          , dbid
          , instance_number
          , parameter
          , total_usage
          , usage
          , gets
          , getmisses
          , scans
          , scanmisses
          , scancompletes
          , modifications
          , flushes
          , dlm_requests
          , dlm_conflicts
          , dlm_releases
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , parameter
          , sum("COUNT")
          , sum(usage)
          , sum(gets)
          , sum(getmisses)
          , sum(scans)
          , sum(scanmisses)
          , sum(scancompletes)
          , sum(modifications)
          , sum(flushes)
          , sum(dlm_requests)
          , sum(dlm_conflicts)
          , sum(dlm_releases)
       from v$rowcache
      group by l_snap_id, p_dbid, p_instance_number, parameter;


     /*  Collect parameters every snapshot, to cater for dynamic
         parameters changable while instance is running
     */

     if l_all_init = 'FALSE' then

       -- capture only standard init.ora parameters, and those which have been
       -- automatically set by auto-memory management

       insert into stats$parameter
            ( snap_id
            , dbid
            , instance_number
            , name
            , value
            , isdefault
            , ismodified
            )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , i.ksppinm
            , sv.ksppstvl
            , sv.ksppstdf
            , decode(bitand(sv.ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE')
         from stats$x$ksppi  i
            , stats$x$ksppsv sv
        where i.indx = sv.indx
          and (   (    (translate(ksppinm,'_','#') not like '#%')
                    or (ksppstdf = 'FALSE')
                  )                      -- standard v$system_parameter
               or (    (translate(ksppinm,'_','#') like '##%') 
                  )                      -- get __
              );
     else
       insert into stats$parameter
            ( snap_id
            , dbid
            , instance_number
            , name
            , value
            , isdefault
            , ismodified
            )
       select l_snap_id
            , p_dbid
            , p_instance_number
            , i.ksppinm
            , sv.ksppstvl
            , sv.ksppstdf
            , decode(bitand(sv.ksppstvf,7),1,'MODIFIED',4,'SYSTEM_MOD','FALSE')
         from stats$x$ksppi  i
            , stats$x$ksppsv sv
        where i.indx = sv.indx;
     end if;


     /*  To cater for variable size SGA - insert on each snapshot  */
     insert into stats$sga
          ( snap_id
          , dbid
          , instance_number
          , name
          , value
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , name
          , value
      from v$sga;

     /*  Get current allocation of memory in the SGA  */

     insert into stats$sgastat
          ( snap_id
          , dbid
          , instance_number
          , pool
          , name
          , bytes
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , pool
          , name
          , bytes
       from ( select pool
                   , name
                   , bytes
                   , 100*(bytes)
                        /(sum(bytes) over (partition by pool)) part_pct
                from v$sgastat
            )
      where part_pct >= p_def_sgastat_pool_pct_th
         or pool is null
         or name = 'free memory';

     insert into stats$system_event
          ( snap_id
          , dbid
          , instance_number
          , event
          , total_waits
          , total_timeouts
          , time_waited_micro
          , total_waits_fg
          , total_timeouts_fg
          , time_waited_micro_fg
          , event_id
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , event
          , total_waits
          , total_timeouts
          , time_waited_micro
          , total_waits_fg
          , total_timeouts_fg
          , time_waited_micro_fg
          , event_id
       from v$system_event;

    insert into stats$event_histogram
          ( snap_id
          , dbid
          , instance_number
          , event_id
          , wait_time_milli
          , wait_count
          )
    select l_snap_id
          , p_dbid
          , p_instance_number
          , en.event_id
          , wait_time_milli
          , wait_count
      from v$event_histogram eh
         , v$event_name en
     where eh.event = en.name
       and eh.event# = en.event#;

     insert into stats$sysstat
          ( snap_id
          , dbid
          , instance_number
          , statistic#
          , name
          , value
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , statistic#
          , name
          , value
       from v$sysstat;
   
     insert into stats$waitstat
          ( snap_id
          , dbid
          , instance_number
          , class
          , wait_count
          , time
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , class
          , "COUNT"
          , time
       from v$waitstat;

     insert into stats$enqueue_statistics
          ( snap_id
          , dbid
          , instance_number
          , eq_type
          , req_reason
          , total_req#
          , total_wait#
          , succ_req#
          , failed_req#
          , cum_wait_time
          , event#
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , eq_type
          , req_reason
          , total_req#
          , total_wait#
          , succ_req#
          , failed_req#
          , cum_wait_time
          , event#
       from v$enqueue_statistics
      where total_req# != 0;

     insert into stats$latch
          ( snap_id
          , dbid
          , instance_number
          , name
          , latch#
          , level#
          , gets
          , misses
          , sleeps
          , immediate_gets
          , immediate_misses
          , spin_gets
          , wait_time
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , name
          , latch#
          , level#
          , gets 
          , misses
          , sleeps 
          , immediate_gets
          , immediate_misses
          , spin_gets
          , wait_time
       from v$latch;

     insert into stats$latch_misses_summary
          ( snap_id
          , dbid
          , instance_number
          , parent_name
          , where_in_code
          , nwfail_count
          , sleep_count
          , wtr_slp_count
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , parent_name
          , "WHERE"
          , sum(nwfail_count)
          , sum(sleep_count)
          , sum(wtr_slp_count)
       from v$latch_misses
      where sleep_count > 0
      group by l_snap_id, p_dbid, p_instance_number
          , parent_name, "WHERE";

     insert into stats$resource_limit
          ( snap_id
          , dbid
          , instance_number
          , resource_name
          , current_utilization
          , max_utilization
          , initial_allocation
          , limit_value
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , resource_name
          , current_utilization
          , max_utilization
          , initial_allocation
          , limit_value
       from v$resource_limit
      where limit_value != ' UNLIMITED'
        and max_utilization > 0;

      insert into stats$undostat
          ( begin_time
          , end_time
          , dbid
          , instance_number
          , snap_id
          , undotsn
          , undoblks
          , txncount
          , maxquerylen
          , maxqueryid
          , maxconcurrency
          , unxpstealcnt
          , unxpblkrelcnt
          , unxpblkreucnt
          , expstealcnt
          , expblkrelcnt
          , expblkreucnt
          , ssolderrcnt
          , nospaceerrcnt
          , activeblks
          , unexpiredblks
          , expiredblks
          , tuned_undoretention
          )
     select begin_time
          , end_time
          , max(p_dbid)
          , max(p_instance_number)
          , max(l_snap_id)
          , max(undotsn)
          , sum(undoblks)
          , sum(txncount)
          , max(maxquerylen)
          , max(maxqueryid)
          , max(maxconcurrency)
          , sum(unxpstealcnt)
          , sum(unxpblkrelcnt)
          , sum(unxpblkreucnt)
          , sum(expstealcnt)
          , sum(expblkrelcnt)
          , sum(expblkreucnt)
          , sum(ssolderrcnt)
          , sum(nospaceerrcnt)
          , sum(activeblks)
          , sum(unexpiredblks)
          , sum(expiredblks)
          , max(tuned_undoretention)
       from v$undostat
      where begin_time              >  l_max_begin_time
        and begin_time + (1/(24*6)) <= end_time
     group by begin_time, end_time;


     /* Capture Memory advice */

     snap_advisors;

     snap_memory_mgmt_stats;

     insert into stats$instance_recovery
          ( snap_id
          , dbid
          , instance_number
          , recovery_estimated_ios
          , actual_redo_blks
          , target_redo_blks
          , log_file_size_redo_blks
          , log_chkpt_timeout_redo_blks
          , log_chkpt_interval_redo_blks
          , fast_start_io_target_redo_blks
          , target_mttr
          , estimated_mttr
          , ckpt_block_writes
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , recovery_estimated_ios
          , actual_redo_blks
          , target_redo_blks
          , log_file_size_redo_blks
          , log_chkpt_timeout_redo_blks
          , log_chkpt_interval_redo_blks
          , fast_start_io_target_redo_blks
          , target_mttr
          , estimated_mttr
          , ckpt_block_writes
       from v$instance_recovery;

     insert into stats$thread
          ( snap_id
          , dbid
          , instance_number
          , thread#
          , thread_instance_number
          , status
          , open_time
          , current_group#
          , sequence#
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , t.thread#
          , i.instance_number
          , t.status
          , t.open_time
          , t.current_group#
          , t.sequence#
       from v$thread t
          , v$instance i
      where i.thread#(+) = t.thread#;

     insert into stats$sys_time_model
          ( snap_id
          , dbid
          , instance_number
          , stat_id
          , value
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , stat_id
          , value
       from v$sys_time_model;

     insert into stats$osstat
          ( snap_id
          , dbid
          , instance_number
          , osstat_id
          , value
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , osstat_id
          , value
       from v$osstat;

     insert into stats$mutex_sleep
          ( snap_id
          , dbid
          , instance_number
          , mutex_type
          , location
          , sleeps
          , wait_time
          )
     select l_snap_id
          , p_dbid
          , p_instance_number
          , mutex_type
          , location
          , sleeps
          , wait_time
       from v$mutex_sleep
      where mutex_type is not null
        and sleeps > 0;


     /*  Capture Streams */

     snap_streams;


     /*  Capture RAC statistics */

     if p_parallel = 'YES' then
       snap_rac;
     end if;


     /*  Begin gathering Extended Statistics */

     IF l_snap_level >= 5 THEN
       snap_sql;
     END IF;

     IF l_snap_level >= 7 THEN
        snap_segment;
     END IF;

     IF l_snap_level >= 10 THEN
        snap_latch;
     end if;

   
     /*  Record level session-granular statistics if a session 
         has been specified
     */
     if l_session_id > 0 then
        snap_session;
     end if;


     /*  Work out how efficently we executed, in seconds */

     select systimestamp
       into l_snap_end_time
       from sys.dual;

     update stats$snapshot
        set snapshot_exec_time_s = 
        round( (           extract(second from (l_snap_end_time - l_snap_start_time))
                + 60*      extract(minute from (l_snap_end_time - l_snap_start_time))
                + 60*60*   extract(hour   from (l_snap_end_time - l_snap_start_time))
                + 60*60*24*extract(day    from (l_snap_end_time - l_snap_start_time))
               ), 2)
      where snap_id         = l_snap_id
        and dbid            = p_dbid
        and instance_number = p_instance_number;

     commit work;

   RETURN l_snap_id;

   end SNAP; /* Function SNAP */

   /* ------------------------------------------------------------------- */


begin  /* STATSPACK body */

  /*  Query the database id, instance_number, database name, instance
      name and startup time for the instance we are working on
  */


  /*  Get information about the current instance  */
  open get_instance;
  fetch get_instance into 
        p_instance_number, p_instance_name
      , p_startup_time, p_parallel, p_version
      , p_host_name;
  close get_instance;


  /*  Select the database info for the db connected to */
  open get_db;
  fetch get_db into p_dbid, p_name, p_platform_name;
  close get_db;


  /*  Keep the package
  */
  sys.dbms_shared_pool.keep('PERFSTAT.STATSPACK', 'P');


  /*  Determine if the instance has been restarted since the previous snapshot
  */
  begin
     select 1 
       into p_new_sga
       from stats$database_instance
      where startup_time    = p_startup_time
        and dbid            = p_dbid
        and instance_number = p_instance_number;
  exception 
     when NO_DATA_FOUND then
        p_new_sga := 0;
  end;

end STATSPACK;
/
show errors;

/* ---------------------------------------------------------------------- */

prompt
prompt NOTE:
prompt   SPCPKG complete. Please check spcpkg.lis for any errors.
prompt
spool off;
whenever sqlerror continue;
set echo on;
