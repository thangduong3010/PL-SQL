Rem
Rem $Header: rdbms/admin/dbmsslrt.sql /main/17 2010/05/05 10:40:19 rmao Exp $
Rem
Rem dbmsslrt.sql
Rem
Rem Copyright (c) 2002, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsslrt.sql - RDBMS Server Alert Package Specification
Rem
Rem    DESCRIPTION
Rem      Defines the interface for alert functions.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bpwang      04/20/10 - split out Streams, XStream, and GoldenGate
Rem    rmao        12/21/09 - bug 9156278: add KELTSTR_SPLIT_MERGE
Rem    arbalakr    11/13/09 - increase length of module and action columns
Rem    rcolle      10/04/07 - make WCR metrics alertable
Rem    mlfeng      10/04/06 - new metrics to make alertable
Rem    ilistvin    08/29/06 - change execution_context_id length to 128
Rem    bpwang      07/01/05 - Add contants and reason ids for Streams alerts
Rem    wfisher     08/19/05 - Add grant for datapump_imp_full_database 
Rem    kneel       11/02/04 - moving reason ids to public package 
Rem    ilistvin    08/20/04 - make Exec/Sec alertable 
Rem    ilistvin    07/12/04 - add new alertable metric, db time per sec 
Rem    nmukherj    04/28/04 - 
Rem    jxchen      09/30/03 - Add new session object type 
Rem    jxchen      08/20/03 - Remove PX downgrade per txn constants 
Rem    jxchen      07/18/03 - Add metric constants
Rem    jxchen      05/28/03 - Add package-wide constants
Rem    aime        04/25/03 - aime_going_to_main
Rem    jxchen      04/15/03 - Move threshold table to SYSAUX tablespace
Rem    jxchen      11/20/02 - Add get_threshold procedure
Rem    jxchen      11/14/02 - jxchen_alrt1
Rem    jxchen      11/13/02 - Create public synonym and grant execute to dba
Rem    jxchen      11/11/02 - Add alert views
Rem    jxchen      10/24/02 - Adding set threshold procedure
Rem    jxchen      09/26/02 - Created
Rem

-- Create threshold type for threshold table function
CREATE TYPE threshold_type AS OBJECT(
      object_type               NUMBER,
      object_name               VARCHAR2(513),
      metrics_id                NUMBER,
      instance_name             VARCHAR2(16),
      flags                     NUMBER,
      warning_operator          NUMBER,
      warning_value             VARCHAR2(256),
      critical_operator         NUMBER,
      critical_value            VARCHAR2(256),
      observation_period        NUMBER,
      consecutive_occurrences   NUMBER,
      object_id                 NUMBER);
/

-- Create threshold set type for threshold table function 
CREATE TYPE threshold_type_set AS TABLE OF threshold_type;
/

-- Create alert type used for in AQ messages 
CREATE TYPE sys.alert_type AS OBJECT (
        timestamp_originating    timestamp with time zone,
        organization_id          varchar2(10),           
        component_id             varchar2(3),           
        message_id               number,               
        hosting_client_id        varchar2(64),        
        message_type             varchar2(12),       
        message_group            varchar2(30),      
        message_level            number,           
        host_id                  varchar2(256),   
        host_nw_addr             varchar2(256),   
        module_id                varchar2(64),  
        process_id               varchar2(128),
        user_id                  varchar2(30),
        upstream_component_id    varchar2(30),            
        downstream_component_id  varchar2(4),            
        execution_context_id     varchar2(128),          
        error_instance_id        varchar2(142),         
        reason_argument_count    number,              
        reason_argument_1        varchar2(513),      
        reason_argument_2        varchar2(513),     
        reason_argument_3        varchar2(513),    
        reason_argument_4        varchar2(513),   
        reason_argument_5        varchar2(513),  
        sequence_id              number,        
        reason_id                number,
        object_owner             varchar2(30), 
        object_name              varchar2(513),           
        subobject_name           varchar2(30),           
        object_type              varchar2(30),          
        instance_name            varchar2(16),         
        instance_number          number,              
        scope                    varchar2(10),
        advisor_name             varchar2(30),
        metric_value             number,         
        suggested_action_msg_id  number,             
        action_argument_count    number,            
        action_argument_1        varchar2(30),     
        action_argument_2        varchar2(30),    
        action_argument_3        varchar2(30),   
        action_argument_4        varchar2(30),  
        action_argument_5        varchar2(30)); 
/

CREATE OR REPLACE PUBLIC SYNONYM alert_type FOR sys.alert_type;
GRANT execute on alert_type TO public;

CREATE OR REPLACE PACKAGE dbms_server_alert AS

-- PUBLIC CONSTANTS

-- operator types
OPERATOR_GT           CONSTANT BINARY_INTEGER := 0;
OPERATOR_EQ           CONSTANT BINARY_INTEGER := 1;
OPERATOR_LT           CONSTANT BINARY_INTEGER := 2;
OPERATOR_LE           CONSTANT BINARY_INTEGER := 3;
OPERATOR_GE           CONSTANT BINARY_INTEGER := 4;
OPERATOR_CONTAINS     CONSTANT BINARY_INTEGER := 5;
OPERATOR_NE           CONSTANT BINARY_INTEGER := 6;
OPERATOR_DO_NOT_CHECK CONSTANT BINARY_INTEGER := 7;

-- object types
OBJECT_TYPE_SYSTEM       CONSTANT BINARY_INTEGER := 1;
OBJECT_TYPE_FILE         CONSTANT BINARY_INTEGER := 2;
OBJECT_TYPE_SERVICE      CONSTANT BINARY_INTEGER := 3;
OBJECT_TYPE_EVENT_CLASS  CONSTANT BINARY_INTEGER := 4;
OBJECT_TYPE_TABLESPACE   CONSTANT BINARY_INTEGER := 5;
OBJECT_TYPE_SESSION      CONSTANT BINARY_INTEGER := 9;
OBJECT_TYPE_WRCLIENT     CONSTANT BINARY_INTEGER := 16;

-- message levels
SUBTYPE SEVERITY_LEVEL_T IS PLS_INTEGER;
LEVEL_CRITICAL      CONSTANT PLS_INTEGER := 1;
LEVEL_WARNING       CONSTANT PLS_INTEGER := 5;
LEVEL_CLEAR         CONSTANT PLS_INTEGER := 32;

-- metrics names
AVG_USERS_WAITING        CONSTANT BINARY_INTEGER := 1000;
DB_TIME_WAITING          CONSTANT BINARY_INTEGER := 1001;
BUFFER_CACHE_HIT         CONSTANT BINARY_INTEGER := 2000;
MEMORY_SORTS_PCT         CONSTANT BINARY_INTEGER := 2001;
REDO_ALLOCATION_HIT      CONSTANT BINARY_INTEGER := 2002;
USER_TRANSACTIONS_SEC    CONSTANT BINARY_INTEGER := 2003;
PHYSICAL_READS_SEC       CONSTANT BINARY_INTEGER := 2004;
PHYSICAL_READS_TXN       CONSTANT BINARY_INTEGER := 2005; 
PHYSICAL_WRITES_SEC      CONSTANT BINARY_INTEGER := 2006; 
PHYSICAL_WRITES_TXN      CONSTANT BINARY_INTEGER := 2007; 
PHYSICAL_READS_DIR_SEC   CONSTANT BINARY_INTEGER := 2008;
PHYSICAL_READS_DIR_TXN   CONSTANT BINARY_INTEGER := 2009;
PHYSICAL_WRITES_DIR_SEC  CONSTANT BINARY_INTEGER := 2010;
PHYSICAL_WRITES_DIR_TXN  CONSTANT BINARY_INTEGER := 2011;
PHYSICAL_READS_LOB_SEC   CONSTANT BINARY_INTEGER := 2012;
PHYSICAL_READS_LOB_TXN   CONSTANT BINARY_INTEGER := 2013;
PHYSICAL_WRITES_LOB_SEC  CONSTANT BINARY_INTEGER := 2014;
PHYSICAL_WRITES_LOB_TXN  CONSTANT BINARY_INTEGER := 2015;
REDO_GENERATED_SEC       CONSTANT BINARY_INTEGER := 2016;
REDO_GENERATED_TXN       CONSTANT BINARY_INTEGER := 2017;
LOGONS_SEC               CONSTANT BINARY_INTEGER := 2018;
LOGONS_TXN               CONSTANT BINARY_INTEGER := 2019;
OPEN_CURSORS_SEC         CONSTANT BINARY_INTEGER := 2020;
OPEN_CURSORS_TXN         CONSTANT BINARY_INTEGER := 2021;
USER_COMMITS_SEC         CONSTANT BINARY_INTEGER := 2022;
USER_COMMITS_TXN         CONSTANT BINARY_INTEGER := 2023;
USER_ROLLBACKS_SEC       CONSTANT BINARY_INTEGER := 2024;
USER_ROLLBACKS_TXN       CONSTANT BINARY_INTEGER := 2025;
USER_CALLS_SEC           CONSTANT BINARY_INTEGER := 2026;
USER_CALLS_TXN           CONSTANT BINARY_INTEGER := 2027;
RECURSIVE_CALLS_SEC      CONSTANT BINARY_INTEGER := 2028;
RECURSIVE_CALLS_TXN      CONSTANT BINARY_INTEGER := 2029;
SESS_LOGICAL_READS_SEC   CONSTANT BINARY_INTEGER := 2030;
SESS_LOGICAL_READS_TXN   CONSTANT BINARY_INTEGER := 2031;
DBWR_CKPT_SEC            CONSTANT BINARY_INTEGER := 2032;
BACKGROUND_CKPT_SEC      CONSTANT BINARY_INTEGER := 2033;
REDO_WRITES_SEC          CONSTANT BINARY_INTEGER := 2034;
REDO_WRITES_TXN          CONSTANT BINARY_INTEGER := 2035;
LONG_TABLE_SCANS_SEC     CONSTANT BINARY_INTEGER := 2036;
LONG_TABLE_SCANS_TXN     CONSTANT BINARY_INTEGER := 2037;
TOTAL_TABLE_SCANS_SEC    CONSTANT BINARY_INTEGER := 2038;
TOTAL_TABLE_SCANS_TXN    CONSTANT BINARY_INTEGER := 2039;
FULL_INDEX_SCANS_SEC     CONSTANT BINARY_INTEGER := 2040;
FULL_INDEX_SCANS_TXN     CONSTANT BINARY_INTEGER := 2041;
TOTAL_INDEX_SCANS_SEC    CONSTANT BINARY_INTEGER := 2042;
TOTAL_INDEX_SCANS_TXN    CONSTANT BINARY_INTEGER := 2043;
TOTAL_PARSES_SEC         CONSTANT BINARY_INTEGER := 2044;
TOTAL_PARSES_TXN         CONSTANT BINARY_INTEGER := 2045;
HARD_PARSES_SEC          CONSTANT BINARY_INTEGER := 2046;
HARD_PARSES_TXN          CONSTANT BINARY_INTEGER := 2047;
PARSE_FAILURES_SEC       CONSTANT BINARY_INTEGER := 2048;
PARSE_FAILURES_TXN       CONSTANT BINARY_INTEGER := 2049;
CURSOR_CACHE_HIT         CONSTANT BINARY_INTEGER := 2050;
DISK_SORT_SEC            CONSTANT BINARY_INTEGER := 2051;
DISK_SORT_TXN            CONSTANT BINARY_INTEGER := 2052;
ROWS_PER_SORT            CONSTANT BINARY_INTEGER := 2053;
EXECUTE_WITHOUT_PARSE    CONSTANT BINARY_INTEGER := 2054;
SOFT_PARSE_PCT           CONSTANT BINARY_INTEGER := 2055;
USER_CALLS_PCT           CONSTANT BINARY_INTEGER := 2056;
NETWORK_BYTES_SEC        CONSTANT BINARY_INTEGER := 2058;
ENQUEUE_TIMEOUTS_SEC     CONSTANT BINARY_INTEGER := 2059;
ENQUEUE_TIMEOUTS_TXN     CONSTANT BINARY_INTEGER := 2060;
ENQUEUE_WAITS_SEC        CONSTANT BINARY_INTEGER := 2061;
ENQUEUE_WAITS_TXN        CONSTANT BINARY_INTEGER := 2062;
ENQUEUE_DEADLOCKS_SEC    CONSTANT BINARY_INTEGER := 2063;
ENQUEUE_DEADLOCKS_TXN    CONSTANT BINARY_INTEGER := 2064;
ENQUEUE_REQUESTS_SEC     CONSTANT BINARY_INTEGER := 2065;
ENQUEUE_REQUESTS_TXN     CONSTANT BINARY_INTEGER := 2066;
DB_BLKGETS_SEC           CONSTANT BINARY_INTEGER := 2067;
DB_BLKGETS_TXN           CONSTANT BINARY_INTEGER := 2068;
CONSISTENT_GETS_SEC      CONSTANT BINARY_INTEGER := 2069;
CONSISTENT_GETS_TXN      CONSTANT BINARY_INTEGER := 2070;
DB_BLKCHANGES_SEC        CONSTANT BINARY_INTEGER := 2071;
DB_BLKCHANGES_TXN        CONSTANT BINARY_INTEGER := 2072;
CONSISTENT_CHANGES_SEC   CONSTANT BINARY_INTEGER := 2073;
CONSISTENT_CHANGES_TXN   CONSTANT BINARY_INTEGER := 2074;
SESSION_CPU_SEC          CONSTANT BINARY_INTEGER := 2075;
SESSION_CPU_TXN          CONSTANT BINARY_INTEGER := 2076;
CR_BLOCKS_CREATED_SEC    CONSTANT BINARY_INTEGER := 2077;
CR_BLOCKS_CREATED_TXN    CONSTANT BINARY_INTEGER := 2078;
CR_RECORDS_APPLIED_SEC   CONSTANT BINARY_INTEGER := 2079;
CR_RECORDS_APPLIED_TXN   CONSTANT BINARY_INTEGER := 2080;
RB_RECORDS_APPLIED_SEC   CONSTANT BINARY_INTEGER := 2081;
RB_RECORDS_APPLIED_TXN   CONSTANT BINARY_INTEGER := 2082;
LEAF_NODE_SPLITS_SEC     CONSTANT BINARY_INTEGER := 2083;
LEAF_NODE_SPLITS_TXN     CONSTANT BINARY_INTEGER := 2084;
BRANCH_NODE_SPLITS_SEC   CONSTANT BINARY_INTEGER := 2085;
BRANCH_NODE_SPLITS_TXN   CONSTANT BINARY_INTEGER := 2086;
PX_DOWNGRADED_25_SEC     CONSTANT BINARY_INTEGER := 2087;
PX_DOWNGRADED_50_SEC     CONSTANT BINARY_INTEGER := 2088;
PX_DOWNGRADED_75_SEC     CONSTANT BINARY_INTEGER := 2089;
PX_DOWNGRADED_SEC        CONSTANT BINARY_INTEGER := 2090;
PX_DOWNGRADED_SER_SEC    CONSTANT BINARY_INTEGER := 2091; 
PX_DOWNGRADED_SEC        CONSTANT BINARY_INTEGER := 2093;
PX_DOWNGRADED_SER_SEC    CONSTANT BINARY_INTEGER := 2095;
GC_AVG_CR_GET_TIME       CONSTANT BINARY_INTEGER := 2098;
GC_AVG_CUR_GET_TIME      CONSTANT BINARY_INTEGER := 2099;
GC_BLOCKS_CORRUPT        CONSTANT BINARY_INTEGER := 2101;
GC_BLOCKS_LOST           CONSTANT BINARY_INTEGER := 2102;
LOGONS_CURRENT           CONSTANT BINARY_INTEGER := 2103;
OPEN_CURSORS_CURRENT     CONSTANT BINARY_INTEGER := 2104;
USER_LIMIT_PCT           CONSTANT BINARY_INTEGER := 2105;
SQL_SRV_RESPONSE_TIME    CONSTANT BINARY_INTEGER := 2106;
DATABASE_WAIT_TIME       CONSTANT BINARY_INTEGER := 2107;
DATABASE_CPU_TIME        CONSTANT BINARY_INTEGER := 2108;
RESPONSE_TXN             CONSTANT BINARY_INTEGER := 2109;
ROW_CACHE_HIT            CONSTANT BINARY_INTEGER := 2110;
ROW_CACHE_MISS           CONSTANT BINARY_INTEGER := 2111;
LIBARY_CACHE_HIT         CONSTANT BINARY_INTEGER := 2112;
LIBARY_CACHE_MISS        CONSTANT BINARY_INTEGER := 2113;
SHARED_POOL_FREE_PCT     CONSTANT BINARY_INTEGER := 2114;
PGA_CACHE_HIT            CONSTANT BINARY_INTEGER := 2115;
PROCESS_LIMIT_PCT        CONSTANT BINARY_INTEGER := 2118;
SESSION_LIMIT_PCT        CONSTANT BINARY_INTEGER := 2119;
EXECUTIONS_PER_SEC       CONSTANT BINARY_INTEGER := 2121;
DB_TIME_PER_SEC          CONSTANT BINARY_INTEGER := 2123;
STREAMS_POOL_USED_PCT    CONSTANT BINARY_INTEGER := 2136;
BLOCKED_USERS            CONSTANT BINARY_INTEGER := 4000;
ELAPSED_TIME_PER_CALL    CONSTANT BINARY_INTEGER := 6000;
CPU_TIME_PER_CALL        CONSTANT BINARY_INTEGER := 6001;
AVG_FILE_READ_TIME       CONSTANT BINARY_INTEGER := 7000;
AVG_FILE_WRITE_TIME      CONSTANT BINARY_INTEGER := 7001;
TABLESPACE_PCT_FULL      CONSTANT BINARY_INTEGER := 9000;
TABLESPACE_BYT_FREE      CONSTANT BINARY_INTEGER := 9001;
WCR_AVG_IO_LAT           CONSTANT BINARY_INTEGER := 13000;
WCR_PCPU                 CONSTANT BINARY_INTEGER := 13001;
WCR_PIO                  CONSTANT BINARY_INTEGER := 13002;

-- alert reasons -- copied from kelt.h
SUBTYPE REASON_ID_T      IS PLS_INTEGER;
RSN_SLTE       CONSTANT REASON_ID_T:= 0;              -- stateless test alert
RSN_SFTE       CONSTANT REASON_ID_T:= 1;               -- stateful test alert
RSN_SYS_BFCHP  CONSTANT REASON_ID_T:= 2;            -- buffer cache hit ratio
RSN_FIL_AFRT   CONSTANT REASON_ID_T:= 3;                -- avg file read time
RSN_SVC_ELAPC  CONSTANT REASON_ID_T:= 4;              -- service elapsed time
RSN_EVC_AUWC   CONSTANT REASON_ID_T:= 5;                -- wait session count
RSN_SES_BLUSC  CONSTANT REASON_ID_T:= 6;                     -- blocked users
RSN_SYS_GBKCR  CONSTANT REASON_ID_T:= 7;       -- global cache blocks corrupt
RSN_SYS_GBKLS  CONSTANT REASON_ID_T:= 8;          -- global cache blocks lost
RSN_SFTS       CONSTANT REASON_ID_T:= 9;                  -- tablespace alert
RSN_LQWT       CONSTANT REASON_ID_T:=10;    -- long query warning on undo tbs
RSN_LQWR       CONSTANT REASON_ID_T:=11;   -- long query warn on rollback seg
RSN_OSAT       CONSTANT REASON_ID_T:=12; -- operation suspended on tablespace
RSN_OSAR       CONSTANT REASON_ID_T:=13;    -- oper suspended on rollback seg
RSN_OSAD       CONSTANT REASON_ID_T:=14;       -- operation suspended on data
RSN_OSAQ       CONSTANT REASON_ID_T:=15;      -- operation suspended on quota
RSN_SYS_MSRTP  CONSTANT REASON_ID_T:=16;                -- memory sorts ratio
RSN_SYS_RDAHP  CONSTANT REASON_ID_T:=17;         -- redo allocation hit ratio
RSN_SYS_UTXNR  CONSTANT REASON_ID_T:=18;          -- user transaction per sec
RSN_SYS_PHRDR  CONSTANT REASON_ID_T:=19;            -- physical reads per sec
RSN_SYS_PHRDX  CONSTANT REASON_ID_T:=20;            -- physical reads per txn
RSN_SYS_PHWRR  CONSTANT REASON_ID_T:=21;           -- physical writes per sec
RSN_SYS_PHWRX  CONSTANT REASON_ID_T:=22;            -- physical write per txn
RSN_SYS_PRDDR  CONSTANT REASON_ID_T:=23;     -- physical reads direct per sec
RSN_SYS_PRDDX  CONSTANT REASON_ID_T:=24;     -- physical reads direct per txn
RSN_SYS_PWRDR  CONSTANT REASON_ID_T:=25;    -- physical writes direct per sec
RSN_SYS_PWRDX  CONSTANT REASON_ID_T:=26;    -- physcial writes direct per txn
RSN_SYS_PRDLR  CONSTANT REASON_ID_T:=27;    -- phys reads direct lobs per sec
RSN_SYS_PRDLX  CONSTANT REASON_ID_T:=28;    -- phys reads direct lobs per txn
RSN_SYS_PWDLR  CONSTANT REASON_ID_T:=29;   -- phys writes direct lobs per sec
RSN_SYS_PWDLX  CONSTANT REASON_ID_T:=30;   -- phys writes direct lobs per txn
RSN_SYS_RDGNR  CONSTANT REASON_ID_T:=31;            -- redo generated per sec
RSN_SYS_LGNTR  CONSTANT REASON_ID_T:=32;                    -- logons per sec
RSN_SYS_LGNTX  CONSTANT REASON_ID_T:=33;                    -- logons per txn
RSN_SYS_OCSTR  CONSTANT REASON_ID_T:=34;              -- open cursors per sec
RSN_SYS_OCSTX  CONSTANT REASON_ID_T:=35;              -- open cursors per txn
RSN_SYS_UCMTR  CONSTANT REASON_ID_T:=36;              -- user commits per sec
RSN_SYS_UCMTP  CONSTANT REASON_ID_T:=37;           -- user commits percentage
RSN_SYS_URBKR  CONSTANT REASON_ID_T:=38;            -- user rollbacks per sec
RSN_SYS_URBKP  CONSTANT REASON_ID_T:=39;         -- user rollbacks percentage
RSN_SYS_UCALR  CONSTANT REASON_ID_T:=40;                -- user calls per sec
RSN_SYS_UCALX  CONSTANT REASON_ID_T:=41;                -- user calls per txn
RSN_SYS_RCALR  CONSTANT REASON_ID_T:=42;           -- recursive calls per sec
RSN_SYS_RCALX  CONSTANT REASON_ID_T:=43;           -- recursive calls per txn
RSN_SYS_SLRDR  CONSTANT REASON_ID_T:=44;             -- logical reads per sec
RSN_SYS_SLRDX  CONSTANT REASON_ID_T:=45;             -- logical reads per txn
RSN_SYS_DWCPR  CONSTANT REASON_ID_T:=46;          -- DBWR checkpoints per sec
RSN_SYS_BGCPR  CONSTANT REASON_ID_T:=47;    -- background checkpoints per sec
RSN_SYS_RDWRR  CONSTANT REASON_ID_T:=48;               -- redo writes per sec
RSN_SYS_RDWRX  CONSTANT REASON_ID_T:=49;               -- redo writes per txn
RSN_SYS_LTSCR  CONSTANT REASON_ID_T:=50;          -- long table scans per sec
RSN_SYS_LTSCX  CONSTANT REASON_ID_T:=51;          -- long table scans per txn
RSN_SYS_TTSCR  CONSTANT REASON_ID_T:=52;         -- total table scans per sec
RSN_SYS_TTSCX  CONSTANT REASON_ID_T:=53;         -- total table scans per txn
RSN_SYS_FISCR  CONSTANT REASON_ID_T:=54;          -- full index scans per sec
RSN_SYS_FISCX  CONSTANT REASON_ID_T:=55;          -- full index scans per txn
RSN_SYS_TISCR  CONSTANT REASON_ID_T:=56;         -- total index scans per sec
RSN_SYS_TISCX  CONSTANT REASON_ID_T:=57;         -- total index scans per txn
RSN_SYS_TPRSR  CONSTANT REASON_ID_T:=58;         -- total parse count per sec
RSN_SYS_TPRSX  CONSTANT REASON_ID_T:=59;         -- total parse count per txn
RSN_SYS_HPRSR  CONSTANT REASON_ID_T:=60;          -- hard parse count per sec
RSN_SYS_HPRSX  CONSTANT REASON_ID_T:=61;          -- hard parse count per txn
RSN_SYS_FPRSR  CONSTANT REASON_ID_T:=62;       -- parse failure count per sec
RSN_SYS_FPRSX  CONSTANT REASON_ID_T:=63;       -- parse failure count per txn
RSN_SYS_CCHTR  CONSTANT REASON_ID_T:=64;            -- cursor cache hit ratio
RSN_SYS_DSRTR  CONSTANT REASON_ID_T:=65;                 -- disk sort per sec
RSN_SYS_DSRTX  CONSTANT REASON_ID_T:=66;                 -- disk sort per txn
RSN_SYS_RWPST  CONSTANT REASON_ID_T:=67;                     -- rows per sort
RSN_SYS_XNPRS  CONSTANT REASON_ID_T:=68;       -- execute without parse ratio
RSN_SYS_SFPRP  CONSTANT REASON_ID_T:=69;                  -- soft parse ratio
RSN_SYS_UCALP  CONSTANT REASON_ID_T:=70;                  -- user calls ratio
RSN_SYS_NTWBR  CONSTANT REASON_ID_T:=71;    -- network traffic volume per sec
RSN_SYS_EQTOR  CONSTANT REASON_ID_T:=72;          -- enqueue timeouts per sec
RSN_SYS_EQTOX  CONSTANT REASON_ID_T:=73;          -- enqueue timeouts per txn
RSN_SYS_EQWTR  CONSTANT REASON_ID_T:=74;             -- enqueue waits per sec
RSN_SYS_EQWTX  CONSTANT REASON_ID_T:=75;             -- enqueue waits per txn
RSN_SYS_EQDLR  CONSTANT REASON_ID_T:=76;         -- enqueue deadlocks per sec
RSN_SYS_EQDLX  CONSTANT REASON_ID_T:=77;         -- enqueue deadlocks per txn
RSN_SYS_EQRQR  CONSTANT REASON_ID_T:=78;          -- enqueue requests per sec
RSN_SYS_EQRQX  CONSTANT REASON_ID_T:=79;          -- enqueue requests per txn
RSN_SYS_DBBGR  CONSTANT REASON_ID_T:=80;             -- db block gets per sec
RSN_SYS_DBBGX  CONSTANT REASON_ID_T:=81;             -- db block gets per txn
RSN_SYS_CRGTR  CONSTANT REASON_ID_T:=82;      -- consistent read gets per sec
RSN_SYS_CRGTX  CONSTANT REASON_ID_T:=83;      -- consistent read gets per txn
RSN_SYS_DBBCR  CONSTANT REASON_ID_T:=84;          -- db block changes per sec
RSN_SYS_DBBCX  CONSTANT REASON_ID_T:=85;          -- db block changes per txn
RSN_SYS_CRCHR  CONSTANT REASON_ID_T:=86;   -- consistent read changes per sec
RSN_SYS_CRCHX  CONSTANT REASON_ID_T:=87;   -- consistent read changes per txn
RSN_SYS_CPUUR  CONSTANT REASON_ID_T:=88;                 -- cpu usage per sec
RSN_SYS_CPUUX  CONSTANT REASON_ID_T:=89;                 -- cpu usage per txn
RSN_SYS_CRBCR  CONSTANT REASON_ID_T:=90;         -- cr blocks created per sec
RSN_SYS_CRBCX  CONSTANT REASON_ID_T:=91;         -- cr blocks created per txn
RSN_SYS_CRRAX  CONSTANT REASON_ID_T:=92;   -- cr undo records applied per txn
RSN_SYS_RBRAR  CONSTANT REASON_ID_T:=93;  -- user rollbk undorec appl per sec
RSN_SYS_RBRAX  CONSTANT REASON_ID_T:=94;  -- user rollbk undorec appl per txn
RSN_SYS_LNSPR  CONSTANT REASON_ID_T:=95;          -- leaf node splits per sec
RSN_SYS_LNSPX  CONSTANT REASON_ID_T:=96;          -- leaf node splits per txn
RSN_SYS_BNSPR  CONSTANT REASON_ID_T:=97;        -- branch node splits per sec
RSN_SYS_BNSPX  CONSTANT REASON_ID_T:=98;        -- branch node splits per txn
RSN_SYS_PX25R  CONSTANT REASON_ID_T:=99; -- px downgraded 25% or more per sec
RSN_SYS_PX50R CONSTANT REASON_ID_T:=100; -- px downgraded 50% or more per sec
RSN_SYS_PX75R CONSTANT REASON_ID_T:=101; -- px downgraded 75% or more per sec
RSN_SYS_PXDGR CONSTANT REASON_ID_T:=102;             -- px downgraded per sec
RSN_SYS_PXSRR CONSTANT REASON_ID_T:=103;   -- px downgraded to serial per sec
RSN_SYS_GACRT CONSTANT REASON_ID_T:=104;  -- global cache average CR get time
RSN_SYS_GACUT CONSTANT REASON_ID_T:=105; -- global cache ave current get time
RSN_SYS_LGONC CONSTANT REASON_ID_T:=106;              -- current logons count
RSN_SYS_OPCSC CONSTANT REASON_ID_T:=107;        -- current open cursors count
RSN_SYS_USLMP CONSTANT REASON_ID_T:=108;                      -- user limit %
RSN_SYS_SQSRT CONSTANT REASON_ID_T:=109;         -- sql service response time
RSN_SYS_DBWTT CONSTANT REASON_ID_T:=110;          -- database wait time ratio
RSN_SYS_DBCPT CONSTANT REASON_ID_T:=111;           -- database cpu time ratio
RSN_SYS_RSPTX CONSTANT REASON_ID_T:=112;             -- response time per txn
RSN_SYS_RCHTR CONSTANT REASON_ID_T:=113;               -- row cache hit ratio
RSN_SYS_LCHTR CONSTANT REASON_ID_T:=114;           -- library cache hit ratio
RSN_SYS_LCMSR CONSTANT REASON_ID_T:=115;          -- library cache miss ratio
RSN_SYS_SPFRP CONSTANT REASON_ID_T:=116;                -- shared pool free %
RSN_SYS_PGCHR CONSTANT REASON_ID_T:=117;                   -- pga cache hit %
RSN_SYS_PRCLP CONSTANT REASON_ID_T:=118;                   -- process limit %
RSN_SYS_SESLP CONSTANT REASON_ID_T:=119;                   -- session limit %
RSN_FIL_AFWT  CONSTANT REASON_ID_T:=120;               -- avg file write time
RSN_EVC_DTSW  CONSTANT REASON_ID_T:=121;                 -- total time waited
RSN_SYS_RCMSR CONSTANT REASON_ID_T:=122;              -- row cache miss ratio
RSN_RADL      CONSTANT REASON_ID_T:=123;   -- recovery area disk limit alerts
RSN_SYS_RDGNX CONSTANT REASON_ID_T:=124;            -- redo generated per txn
RSN_SYS_CRRAR CONSTANT REASON_ID_T:=125;   -- cr undo records applied per sec
RSN_SYS_THNTF CONSTANT REASON_ID_T:=126;   -- threshold notice on system type
RSN_FIL_THNTF CONSTANT REASON_ID_T:=127;     -- threshold notice on file type
RSN_EVC_THNTF CONSTANT REASON_ID_T:=128;   -- threshold notice on event class
RSN_SVC_THNTF CONSTANT REASON_ID_T:=129;      -- threshold notice on service
RSN_TBS_THNTF CONSTANT REASON_ID_T:=130;    -- threshold notice on tablespace
RSN_SVC_CPUPC CONSTANT REASON_ID_T:=131;            -- cpu time per user call
RSN_SES_THNTF CONSTANT REASON_ID_T:=132;      -- threshold notice on sessions
RSN_SFBTS     CONSTANT REASON_ID_T:=133; -- tablespace bytes based thresholds
RSN_SYS_INQPR CONSTANT REASON_ID_T:=134;       -- instance should be quiesced
RSN_FAN_INSTANCE_UP            CONSTANT REASON_ID_T:=135;      -- instance up
RSN_FAN_INSTANCE_DOWN          CONSTANT REASON_ID_T:=136;    -- instance down
RSN_FAN_SERVICE_UP             CONSTANT REASON_ID_T:=137;       -- service up
RSN_FAN_SERVICE_DOWN           CONSTANT REASON_ID_T:=138;     -- service down
RSN_FAN_SERVICE_MEMBER_UP      CONSTANT REASON_ID_T:=139;    -- svc member up
RSN_FAN_SERVICE_MEMBER_DOWN    CONSTANT REASON_ID_T:=140;  -- svc member down
RSN_FAN_SVC_PRECONNECT_UP      CONSTANT REASON_ID_T:=141;    -- preconnect up
RSN_FAN_SVC_PRECONNECT_DOWN    CONSTANT REASON_ID_T:=142;  -- preconnect down
RSN_FAN_NODE_DOWN              CONSTANT REASON_ID_T:=143;        -- node down
RSN_FAN_ASM_INSTANCE_UP        CONSTANT REASON_ID_T:=144;  -- asm instance up
RSN_FAN_ASM_INSTANCE_DOWN      CONSTANT REASON_ID_T:=145;    -- asm inst down
RSN_FAN_DATABASE_UP            CONSTANT REASON_ID_T:=146;      -- database up
RSN_FAN_DATABASE_DOWN          CONSTANT REASON_ID_T:=147;    -- database down
RSN_SYS_DBTMR CONSTANT REASON_ID_T:=148;                   -- DB Time per Sec
RSN_SYS_XCNTR CONSTANT REASON_ID_T:=149;                -- Executions Per Sec
RSN_STR_CAPTURE_ABORTED        CONSTANT REASON_ID_T:=150;  -- capture aborted 
RSN_STR_APPLY_ABORTED          CONSTANT REASON_ID_T:=151;    -- apply aborted 
RSN_STR_PROPAGATION_ABORTED    CONSTANT REASON_ID_T:=152; -- propgatn aborted 
RSN_STR_STREAMSPOOL_FREE_PCT   CONSTANT REASON_ID_T:=153; -- streamspool free 
RSN_STR_ERROR_QUEUE            CONSTANT REASON_ID_T:=154;
                                                  -- new entry in error queue 
RSN_LOG_ARCHIVE_LOG_GAP        CONSTANT REASON_ID_T:=155;  
                                             -- archived log gap for logminer 
RSN_SYS_ACTVS CONSTANT REASON_ID_T:=156;           -- average active sessions 
RSN_SYS_SRLAT CONSTANT REASON_ID_T:=157; 
                                   -- Avg synchronous single-blk read latency 
RSN_SYS_IOMBS CONSTANT REASON_ID_T:=158;                     -- i/o megabytes
RSN_SYS_IOREQ CONSTANT REASON_ID_T:=159;                      -- i/o requests
RSN_WCR_IOLAT CONSTANT REASON_ID_T:=160;                 --average IO latency
RSN_WCR_PCPU  CONSTANT REASON_ID_T:=161;        -- % of replay threads on CPU
RSN_WCR_PIO   CONSTANT REASON_ID_T:=162;      -- % of replay threads doing IO
RSN_WRC_THNTF CONSTANT REASON_ID_T:=163; -- threshold notice on WRCLIENT type
RSN_WRC_STATUS CONSTANT REASON_ID_T:=164; -- change of status for capt/replay
RSN_STR_SPLIT_MERGE            CONSTANT REASON_ID_T:=166; -- auto split/merge
RSN_XSTR_CAPTURE_ABORTED       CONSTANT REASON_ID_T:=167;  -- capture aborted 
RSN_XSTR_APPLY_ABORTED         CONSTANT REASON_ID_T:=168;    -- apply aborted 
RSN_XSTR_PROPAGATION_ABORTED   CONSTANT REASON_ID_T:=169; -- propgatn aborted 
RSN_XSTR_ERROR_QUEUE           CONSTANT REASON_ID_T:=170;
                                                  -- new entry in error queue 
RSN_XSTR_SPLIT_MERGE           CONSTANT REASON_ID_T:=171; -- auto split/merge
RSN_GG_CAPTURE_ABORTED         CONSTANT REASON_ID_T:=172;  -- capture aborted 
RSN_GG_APPLY_ABORTED           CONSTANT REASON_ID_T:=173;    -- apply aborted 
RSN_GG_PROPAGATION_ABORTED     CONSTANT REASON_ID_T:=174; -- propgatn aborted 
RSN_GG_ERROR_QUEUE             CONSTANT REASON_ID_T:=175;
                                                  -- new entry in error queue 
RSN_GG_SPLIT_MERGE             CONSTANT REASON_ID_T:=176; -- auto split/merge

-- procedure to set warning and critical thresholds
procedure set_threshold(
           metrics_id              IN BINARY_INTEGER,
           warning_operator        IN BINARY_INTEGER,
           warning_value           IN VARCHAR2,
           critical_operator       IN BINARY_INTEGER,
           critical_value          IN VARCHAR2,
           observation_period      IN BINARY_INTEGER,
           consecutive_occurrences IN BINARY_INTEGER,
           instance_name           IN VARCHAR2,
           object_type             IN BINARY_INTEGER,
           object_name             IN VARCHAR2);

-- procedure to get threshold setting
procedure get_threshold(
           metrics_id              IN  BINARY_INTEGER,
           warning_operator        OUT BINARY_INTEGER,
           warning_value           OUT VARCHAR2,
           critical_operator       OUT BINARY_INTEGER,
           critical_value          OUT VARCHAR2,
           observation_period      OUT BINARY_INTEGER,
           consecutive_occurrences OUT BINARY_INTEGER,
           instance_name           IN  VARCHAR2,
           object_type             IN  BINARY_INTEGER,
           object_name             IN  VARCHAR2);

-- function to expand alert messages
function  expand_message(
         user_language     in varchar2,
         message_id        in number,
         argument_1        in varchar2,
         argument_2        in varchar2,
         argument_3        in varchar2,
         argument_4        in varchar2,
         argument_5        in varchar2)
RETURN varchar2;

FUNCTION view_thresholds 
RETURN threshold_type_set PIPELINED;

END dbms_server_alert;
/
-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_SVRALRT_LIB TRUSTED AS STATIC;
/
-- create public synonym
CREATE OR REPLACE PUBLIC SYNONYM dbms_server_alert
FOR sys.dbms_server_alert
/
-- grant execute privilege to dba, old import and Data Pump import
GRANT EXECUTE ON dbms_server_alert TO dba
/
GRANT EXECUTE ON dbms_server_alert TO imp_full_database
/
