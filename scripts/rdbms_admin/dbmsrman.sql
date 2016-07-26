create or replace package dbms_rcvman IS

----------------------------------------
-- PUBLIC VARIABLES AND TYPES SECTION --
----------------------------------------

actual_dbinc_key number := NULL; -- see comments on getActualDbinc

TRUE#  CONSTANT number := 1;
FALSE# CONSTANT number := 0;

-- Below public variables used in KQFV.H to obtain summary information based
-- on job filter attributes.
SESSION_KEY number;
SESSION_FROMTIME DATE;
SESSION_UNTILTIME DATE;

-- The values here must never be changed, because the 8.0 rman executables have
-- these values hard-coded in the krmkbt enum in krmk.h.  The setFrom procedure
-- in particular is using hard-coded values.

-- The 8.1.5 rman executable calls a procedure, set_package_constants, that
-- re-assigns these constants to whatever the package needs them to be, then
-- queries the package for their new values.  The 8.1.5 rman does not care
-- what the values are, however, the cursor used by reportGetDFDel used to use
-- these values to perform an order-by to return rows in preference order.
-- The preference order is used to decide which ones to delete.

-- As of 8.1.6, the order-by in reportGetDFDel is independant of these values.
-- The 8.1.6 rman does not use these values at all, except in setFrom.
-- However, for backwards compatibility with the 8.1.5 RMAN, these must remain
-- as public package constants.

COPY                  number := 1; -- any image copy of a file
FULL_DF_BACKUP        number := 2; -- datafile in a full backup set
INCREMENTAL_DF_BACKUP number := 3; -- datafile in an incr backup set
BACKUP                number := 4; -- any file in a backup set (incl proxy)
OFFLINE_RANGE         number := 5; -- an offline range
CUMULATIVE            number := 6; -- cumulative incremental - for LIST only
PROXY                 number := 7; -- any proxy copy of a file
NONPROXY              number := 9; -- any image, backup set other than proxy
AVMCOPY               number := 10; --  only avm image copy of a file

-- Recovery Action Kinds (Obsolete as of 8.1.6) --

implicitOfflRange CONSTANT NUMBER := 2**0;
cleanRange        CONSTANT NUMBER := 2**1;
applyOfflRange    CONSTANT NUMBER := 2**2;
dfCopy            CONSTANT NUMBER := 2**3;
proxyFull         CONSTANT NUMBER := 2**4;
buSet             CONSTANT NUMBER := 2**5;
applyIncremental  CONSTANT NUMBER := 2**6;
redo              CONSTANT NUMBER := 2**7;

-- kind masks
maxKind           CONSTANT NUMBER := redo;            -- last real kind above
allKind           CONSTANT NUMBER := (maxKind*2) - 1; -- all real backup types
fullKind          CONSTANT NUMBER := dfCopy + proxyFull + buSet;
tagKind           CONSTANT NUMBER := fullKind + applyIncremental;

-- pseudo kinds
deletedKind       CONSTANT NUMBER := maxKind*2;      -- action deleted

----------------------------------
-- Backupset Availability Masks --
----------------------------------

BSavailable     CONSTANT BINARY_INTEGER := 2**0;
BSunavailable   CONSTANT BINARY_INTEGER := 2**1;
BSdeleted       CONSTANT BINARY_INTEGER := 2**2;
BSexpired       CONSTANT BINARY_INTEGER := 2**3;
-- BSpartial_avail is a backupset validation mask and NOT a backuppiece
-- filter.  For eg. to get 'A', 'U', 'X' pieces and to enable validation
-- to succeed for partially available backupset use
-- BSpartial_avail + BSavailable + BSunavailable + BSexpired.
BSpartial_avail CONSTANT BINARY_INTEGER := 2**4;


----------------------
-- BackupType Mask ---
----------------------
BSdatafile_full  CONSTANT BINARY_INTEGER := 2**0;
BSdatafile_incr  CONSTANT BINARY_INTEGER := 2**1;
BSarchivelog     CONSTANT BINARY_INTEGER := 2**2;

---------------------------
-- ControlfileType Mask ---
---------------------------
BScfile_all      CONSTANT BINARY_INTEGER := 2**0;      -- shouldn't be altered
BScfile_auto     CONSTANT BINARY_INTEGER := 2**1;

---------------------
-- Datafile Record --
---------------------

TYPE dfRec_t IS RECORD
(
   dfNumber             number,
   dfCreationSCN        number,
   dfCreationTime       date,
   fileName             varchar2(1024),
   tsName               varchar2(30),
   tsNumber             number,
   status               number,
   blocks               number,
   blockSize            number,
   kbytes               number,
   unrecovSCN           number,
   stopSCN              number,
   readOnly             number,
   rfNumber             number,
   inBackup             number,     -- if greater than 0 then
                                    -- included_in_database_backup is set
   auxName              varchar2(1024),
   dbincKey             number,
   dfOfflineSCN         number, 
   dfOnlineSCN          number, 
   dfOnlineTime         date,
   encrypt              number,     -- encrypt value 1=ON, 2=OFF, 3=CLEAR
   foreignDbid          number,         -- foreign database id
   pluggedRonly         binary_integer, -- 1 for read-only. Otherwise, 0
   pluginSCN            number,         -- plugin change#
   pluginRlgSCN         number,         -- plugin resetlogs_change#
   pluginRlgTime        date,           -- plugin resetlogs_time
   newDfCreationSCN     number,         -- plugin scn or creation scn
   creation_thread      number,         -- creation thread
   creation_size        number          -- creation size
);

---------------------
-- Tempfile Record --
---------------------

TYPE tfRec_t IS RECORD
(
   tfNumber             number,
   tfCreationSCN        number,
   tfCreationTime       date,
   fileName             varchar2(1024),
   tsName               varchar2(30),
   tsNumber             number,
   status               number,
   isSFT                varchar2(3),
   blocks               number,
   blockSize            number,
   maxSize              number,
   nextSize             number,
   rfNumber             number,
   dbincKey             number
);

-------------------------
-- Archived Log Record --
-------------------------

TYPE alRec_t IS RECORD
(
   key                  number,
   recid                number,
   stamp                number,
   thread               number,
   sequence             number,
   fileName             varchar2(1024),
   lowSCN               number,
   lowTime              date,
   nextSCN              number,
   nextTime             date,
   rlgSCN               number,
   rlgTime              date,
   blocks               number,
   blockSize            number,
   status               varchar2(1),
   compTime             date,
   duplicate            number,
   isrdf                varchar2(3),
   compressed           varchar2(3),
   stby                 varchar2(1),
   terminal             varchar2(3),
   site_key             number,
   site_key_order_col   number,
   source_dbid          number
);

-- All of the queries which return data about a backup/imagecopy/proxycopy
-- select into a rcvRec_t record type.  We have standardized all of our
-- queries to have a common select-list and the results of the queries are
-- returned through a common public package function.  The reason for this is
-- so that krmk.pc can populate its internal data structures consistantly,
-- regardless of what particular procedure it has called to query the catalog.

-- By having all queries select into the same record type, we can ensure
-- that all queries use the same select list.  Any new fields that get added
-- to this record will require updating the select lists of all queries.
-- Failure to make the correct updates will result in PLSQL giving an error
-- when the package body is re-created, so the error will be easily detected
-- without the need to run any test suite.

-- The record is divided into three sections.  These correpond to
-- three krmk.h data structures which will be populated with the data
-- from this record.  Refer to krmk.h for a description of the purpose
-- of each of these three data strucutres.

-- Think of this as:  the container acts on the object.

---------------------
-- Recovery Record --
---------------------

TYPE rcvRec_t IS RECORD
(
   -- *** Recovery Container Section ***

   type_con             number,         -- recovery container type
   key_con              number,         -- primary key
   recid_con            number,         -- recid
   stamp_con            number,         -- stamp
   setStamp_con         number,         -- set count if backup set (null)
   setCount_con         number,         -- set stamp if backup set (null)
   bsRecid_con          number,         -- backup set recid (null)
   bsStamp_con          number,         -- backup set stamp (null)
   bsKey_con            number,         -- backup set key (null)
   bsLevel_con          number,         -- backup set level (null)
   bsType_con           varchar2(1),    -- backup set type
   elapseSecs_con       number,         -- backup set elapse seconds (null)
   pieceCount_con       number,         -- backup set piece count (null)
   fileName_con         varchar2(1024), -- filename if a copy (or) piece (null)
   tag_con              varchar2(32),   -- tag (null)
                                        -- filled in by addAction() for
                                        -- backup sets
   copyNumber_con       number,         -- backup set copy# (null) maxlimit 256
                                        -- filled in by addAction() only
   status_con           varchar2(1),    -- status (null)
   blocks_con           number,         -- size of file in blocks (null)
   blockSize_con        number,         -- block size (null)
   deviceType_con       varchar2(255),  -- device type required (null)
                                        -- filled in by addAction() for
                                        -- backup sets
   compTime_con         date,           -- completion time
   cfCreationTime_con   date,           -- controlfile creation time if
                                        -- offline range (null)
   pieceNumber_con      number,
   bpCompTime_con       date,
   bpCompressed_con     varchar2(3),

   multi_section_con    varchar2(1),    -- multi-section backup piece

   -- *** Recovery Action Section ***

   type_act             number,         -- recovery action type
   fromSCN_act          number,
   toSCN_act            number,
   toTime_act           date,
   rlgSCN_act           number,
   rlgTime_act          date,
   dbincKey_act         number,
   level_act            number,
   section_size_act     number,

   -- *** Recovery Object Section ***

   dfNumber_obj         number,
   dfCreationSCN_obj    number,
   cfSequence_obj       number,        -- controlfile autobackup sequence
   cfDate_obj           date,          -- controlfile autobackup date
   logSequence_obj      number,
   logThread_obj        number,
   logRlgSCN_obj        number,
   logRlgTime_obj       date,
   logLowSCN_obj        number,
   logLowTime_obj       date,
   logNextSCN_obj       number,
   logNextTime_obj      date,
   logTerminal_obj      varchar2(3),
   cfType_obj           varchar2(1),   -- controlfile type ('B' or 'S')

   -- *** Retention Policy Section ***
   keep_options         number,
   keep_until           date,

   -- *** Optimization Action Section ***

   afzSCN_act           number,
   rfzTime_act          date,
   rfzSCN_act           number,

   -- *** media Action Section ***
   media_con            varchar2(80),    -- media volume name for backup piece

   isrdf_con            varchar2(3),

   -- ** site specific information for recovery action ***
   site_key_con         number,

   -- *** plugged Section ***
   foreignDbid_obj      number,         -- foreign database id
   pluggedRonly_obj     binary_integer, -- 1 for read-only. Otherwise, 0
   pluginSCN_obj        number,         -- plugin change#
   pluginRlgSCN_obj     number,         -- plugin resetlogs change#
   pluginRlgTime_obj    date,           -- plugin resetlogs time

   -- ** sort order Section ***
   newDfCreationSCN_obj number,         -- plugin scn or creation scn
   newToSCN_act         number,         -- plugin scn or checkpoint scn
   newRlgSCN_act        number,         -- plugin rlgscn or rlgscn
   newRlgTime_act       date,           -- plugin rlgtime or rlgtime

   -- ** SPFILE specific data **
   sfDbUniqueName_obj   VARCHAR2(30)
);

------------------------------
-- Recovery Container Types --
------------------------------

--
-- NOTE!!! NOTE!!! NOTE!!!
-- 
-- You must never change these constants values between releases. Doing so
-- would break the compatibility by making lower version of RMAN executable
-- not able to talk to this recovery catalog. We have never changed these
-- constants from 8.1.5 onwards. See bug 893864 for details.
--

-- NOTE:  Order is important, it is used in an ORDER BY.

offlineRangeRec_con_t   CONSTANT NUMBER := 2**0;
proxyCopy_con_t         CONSTANT NUMBER := 2**1;
imageCopy_con_t         CONSTANT NUMBER := 2**2;
backupSet_con_t         CONSTANT NUMBER := 2**3;
addredo_con_t           CONSTANT NUMBER := 2**4;
deleted_con_t           CONSTANT NUMBER := 2**8;
datafile_con_t          CONSTANT NUMBER := 2**9;
avmImageCopy_con_t      CONSTANT NUMBER := 2**10;

-- Masks
backupMask_con_t        CONSTANT NUMBER := proxyCopy_con_t + imageCopy_con_t +
                                           backupSet_con_t;
tagMask_con_t           CONSTANT NUMBER := proxyCopy_con_t + imageCopy_con_t +
                                           backupSet_con_t;

---------------------------
-- Recovery Action Types --
---------------------------

full_act_t              CONSTANT NUMBER := 2**0;
incremental_act_t       CONSTANT NUMBER := 2**1;
redo_act_t              CONSTANT NUMBER := 2**2;
offlineRange_act_t      CONSTANT NUMBER := 2**3;
cleanRange_act_t        CONSTANT NUMBER := 2**4;
implicitRange_act_t     CONSTANT NUMBER := 2**5;
spanningRange_act_t     CONSTANT NUMBER := 2**6;
createdatafile_act_t    CONSTANT NUMBER := 2**7;

-----------------------------------------
-- Recovery Record Returning Functions --
-----------------------------------------

-- These defines are used as the funCode arg to getRcvRec to tell it which
-- function it should call.  We do this so that krmk.pc can have a single
-- interface routine for getting a rcvRec_t.

getCfCopy               CONSTANT NUMBER := 0;
getDfCopy               CONSTANT NUMBER := 1;
getAnyProxy             CONSTANT NUMBER := 2;
getCfBackup             CONSTANT NUMBER := 3;
listCfCopy              CONSTANT NUMBER := 4;
listDfCopy              CONSTANT NUMBER := 5;
listCfBackup            CONSTANT NUMBER := 6;
listDfBackup            CONSTANT NUMBER := 7;
listAlBackup            CONSTANT NUMBER := 8;
listDfProxy             CONSTANT NUMBER := 9;
getRecovAction          CONSTANT NUMBER := 10;
getAlBackup             CONSTANT NUMBER := 11;
listAlCopy              CONSTANT NUMBER := 12;
listBSet                CONSTANT NUMBER := 13;
getSfBackup             CONSTANT NUMBER := 14;
listSfBackup            CONSTANT NUMBER := 15;
getAllBSet              CONSTANT NUMBER := 16;
listAlProxy             CONSTANT NUMBER := 17;
getRangeAlBackup        CONSTANT NUMBER := 18;

------------------------
-- RMAN command types --
------------------------
-- These defines are used as an interface to find out the command executed
-- by rman.
--
unknownCmd_t            CONSTANT BINARY_INTEGER := 0;
recoverCmd_t            CONSTANT BINARY_INTEGER := 1;
rcvCopyCmd_t            CONSTANT BINARY_INTEGER := 2;
obsoleteCmd_t           CONSTANT BINARY_INTEGER := 3;
restoreCmd_t            CONSTANT BINARY_INTEGER := 4;
blkRestoreCmd_t         CONSTANT BINARY_INTEGER := 5;

----------------------------------------
-- What to do when archiver is stuck? --
----------------------------------------
-- Set this to 0 if you want to disable the behavior of using memory
-- sorting when archiver is stuck.
--
stuckMemorySize CONSTANT NUMBER := 50 * 1024 * 1024;

-----------------------
-- Backup Set Record --
-----------------------

TYPE bsRec_t IS RECORD
(
   recid                number,
   stamp                number,
   key                  number,
   setStamp             number,
   setCount             number,
   bsType               varchar2(1),
   level                number,
   elapseSecs           number,
   compTime             date,
   status               varchar2(1),
   pieceCount           number,
   keep_options         number,
   keep_until           date,
   multi_section        varchar2(1)
);

------------------------
-- Backup Piece Record --
-------------------------

TYPE bpRec_t IS RECORD
(
   recid                number,
   stamp                number,
   key                  number,
   bskey                number,
   setStamp             number,
   setCount             number,
   pieceNumber          number,
   copyNumber           number,
   status               varchar2(1),
   compTime             date,
   handle               varchar2(1024),
   tag                  varchar2(32),
   deviceType           varchar2(255),
   media                varchar2(80),
   bytes                number,
   compressed           varchar2(3),
   site_key             number
);

---------------------------------
-- Backupset Validation Record --
---------------------------------

TYPE validBackupSetRec_t IS RECORD
(
   deviceType   varchar2(255),
   tag          varchar2(32),                   -- may be null
   copyNumber   number,                         -- null if code 2 or 3
   code         number                          -- 1 => same copy#
                                                -- 2 => mix of copy#s, but
                                                --      same tag
                                                -- 3 => mix of copy#s and tags
);

bsRecCacheEnabled   constant boolean := TRUE;  -- FALSE to use pre10i method
bsRecCacheLowLimit  constant number  := 2048;  -- minimum cache size
bsRecCacheHighLimit constant number  := 32768; -- maximum cache size


TYPE incarnation_t IS RECORD
(
INCARNATION#                                       NUMBER,
RESETLOGS_CHANGE#                                  NUMBER,
RESETLOGS_TIME                                     DATE,
PRIOR_RESETLOGS_CHANGE#                            NUMBER,
PRIOR_RESETLOGS_TIME                               DATE,
STATUS                                             VARCHAR2(7),
RESETLOGS_ID                                       NUMBER,
PRIOR_INCARNATION#                                 NUMBER
);

TYPE incarnation_set IS VARRAY(1) OF incarnation_t;

--------------------
-- backup history --
--------------------
TYPE bhistoryRec_t IS RECORD
(
   dfNumber        number,
   create_scn      number,
   reset_scn       number,
   reset_time      date,
   ckp_scn         number,
   ckp_time        date,
   stop_scn        number,
   logThread       number,
   logSequence     number,
   setStamp        number,
   setCount        number,
   compTime        date,
   nbackups        number,
   logTerminal     varchar2(3),
   next_scn        number,
   pluggedRonly    binary_integer, -- 1 for read-only. Otherwise, 0
   pluginSCN       number,
   pluginRlgSCN    number,
   pluginRlgTime   date,
   newcreate_scn   number,    -- create_scn or pluginSCN
   newreset_scn    number,    -- reset_scn  or pluginRlgSCN
   newreset_time   date       -- reset_time or pluginRlgTime
);

---------------
-- aged file --
---------------
TYPE agedFileRec_t IS RECORD
(
   type           number,
   key            number,
   stamp          number
);

--------------------------------------------------------
-- List Backup Constants, Record and Global Varaibles --
--------------------------------------------------------

-- Constants
-- NOTE: These constants are will be displayed in the RC_ view and will be
--       visible to the user. 
backupset_txt      CONSTANT VARCHAR2(16) := 'BACKUP SET';
copy_txt           CONSTANT VARCHAR2(16) := 'COPY';
proxycopy_txt      CONSTANT VARCHAR2(16) := 'PROXY COPY';
datafile_txt       CONSTANT VARCHAR2(16) := 'DATAFILE';
spfile_txt         CONSTANT VARCHAR2(16) := 'SPFILE';
archivedlog_txt    CONSTANT VARCHAR2(16) := 'ARCHIVED LOG';
controlfile_txt    CONSTANT VARCHAR2(16) := 'CONTROLFILE';
piece_txt          CONSTANT VARCHAR2(16) := 'PIECE';
available_txt      CONSTANT VARCHAR2(16) := 'AVAILABLE';
unavailable_txt    CONSTANT VARCHAR2(16) := 'UNAVAILABLE';
expired_txt        CONSTANT VARCHAR2(16) := 'EXPIRED';
deleted_txt        CONSTANT VARCHAR2(16) := 'DELETED';
other_txt          CONSTANT VARCHAR2(16) := 'OTHER';
full_txt           CONSTANT VARCHAR2(16) := 'FULL';
incr1_txt          CONSTANT VARCHAR2(16) := 'INCR1';
incr2_txt          CONSTANT VARCHAR2(16) := 'INCR2';
incr3_txt          CONSTANT VARCHAR2(16) := 'INCR3';
incr4_txt          CONSTANT VARCHAR2(16) := 'INCR4';
incr_txt           CONSTANT VARCHAR2(16) := 'INCR';        -- level unknown

-- The following record type is returned by the listBackup() function
-- NOTE: The name of variables in this structure are displayed in 
--       the view V_$BACKUP_FILES. rc_lbRec_t structure is used to display
--       RC_BACKUP_FILES. So, remember to make change in rc_lbRec_t, 
--       rc_lbRec_t_body and rc_listBackup() if you need to make new
--       columns visible to user.
--
TYPE lbRec_t IS RECORD
(
   list_order1        NUMBER,       -- just hint to correctly order records

   list_order2        NUMBER,       -- just hint to correctly order records

   pkey               NUMBER,       -- primary key
   --
   -- row part
   --
   backup_type        VARCHAR2(32),  -- Type of the backup:
                                     --  * 'BACKUP SET'
                                     --  * 'COPY'
                                     --  * 'PROXY COPY'

   --
   -- file part
   --
   file_type           VARCHAR2(32), -- Type of the file:
                                     --  * 'DATAFILE', 
                                     --  * 'CONTROLFILE'
                                     --  * 'SPFILE'
                                     --  * 'REDO LOG'
                                     --  * 'PIECE'

   -- Common part.
   -- This part is shared by rows returned from listBackup.
   keep               VARCHAR2(3),
   keep_until         DATE,
   keep_options       VARCHAR2(13),
   status             VARCHAR2(16),   -- Status of the piece/copy:
                                      --  * 'AVAIABLE'
                                      --  * 'UNAVAIABLE' 
                                      --  * 'EXPIRED'
                                      --  * 'OTHER'
   fname              VARCHAR2(1024), -- piece or copy name
   tag                VARCHAR2(32),   -- piece or copy tag
   media              VARCHAR2(80),
   recid              NUMBER,
   stamp              NUMBER,
   device_type        VARCHAR2(255),
   block_size         NUMBER,
   completion_time    DATE,
   is_rdf             VARCHAR2(3),
   compressed         VARCHAR2(3),
   obsolete           VARCHAR2(3),
   keep_for_dbpitr    VARCHAR2(3),
   bytes              NUMBER,

   -- BACKUP SET part. 
   -- Valid only when backup_type is 'BACKUP SET'.
   bs_key                NUMBER,        
   bs_count              NUMBER,        
   bs_stamp              NUMBER,        
   bs_type               VARCHAR2(32), -- Type of the backup set:
                                       --  * 'DATAFILE'
                                       --  * 'ARCHIVED LOG'
   bs_incr_type          VARCHAR2(32), 
   bs_pieces             NUMBER,
   bs_copies             NUMBER,
   bs_completion_time    DATE,
   bs_status             VARCHAR2(16),   -- Status of the backup set:
                                         --  * 'AVAIABLE'
                                         --  * 'UNAVAIABLE' 
                                         --  * 'EXPIRED'
                                         --  * 'OTHER'
   bs_bytes              NUMBER,
   bs_compressed         VARCHAR2(3),    -- If backup set is compressed:
                                         --  * 'YES'
                                         --  * 'NO' 
                                         --  * 'OTHER'

   bs_tag                VARCHAR2(1024), -- List of all tags of pieces.
                                         -- We don't repeate same tags. Tags
                                         -- divided by commas.

   bs_device_type        VARCHAR2(255),  -- List of device types of pieces. 
                                         -- Device types are divided by commas.
 
   -- BACKUP PIECE part. 
   -- Valid only when file_type is 'PIECE' and backup_type is 'BACKUP SET'.
   bp_piece#             NUMBER,
   bp_copy#              NUMBER,

   -- DATAFILE part. 
   -- Valid only when file_type is 'DATAFILE', 'CONTROLFILE', or 'SPFILE'.
   df_file#                  NUMBER,
   df_tablespace             VARCHAR2(30),
   df_resetlogs_change#      NUMBER,
   df_creation_change#       NUMBER,
   df_checkpoint_change#     NUMBER,
   df_ckp_mod_time           DATE, 
   df_incremental_change#    NUMBER,
   
   -- REDO LOG part. 
   -- This part is valid only when file_type is 'REDO LOG'.
   rl_thread#            NUMBER,
   rl_sequence#          NUMBER,
   rl_resetlogs_change#  NUMBER,
   rl_first_change#      NUMBER,
   rl_first_time         DATE,
   rl_next_change#       NUMBER,
   rl_next_time          DATE,

   -- SPFILE part
   sf_db_unique_name     VARCHAR2(30)
);

-- This record keeps a datafile information for listBackup function.
-- In addition to normal datafile record, it contains various keepscn
-- information.
TYPE lbDfRec_t IS RECORD
(
   dfRec                dfRec_t,
   -- This is the minimum checkpoint_change# of the backup that are kept
   -- for retention policy and its corresponding resetlogs_change#.
   -- A full backup of this datafile is kept if its checkpoint_change# is
   -- greater than fullmin_scn and its resetlogs_change# is greater
   -- that fullmin_scn or equal to fullmin_rlgscn.
   fullmin_scn           NUMBER,
   fullmin_rlgscn        NUMBER,

   -- This is the minimum checkpoint_change# of the backup that are kept
   -- for retention policy and its corresponding resetlogs_change#.
   -- A incremental backup of this datafile is kept if its checkpoint_change#
   -- is greater than incrmin_scn and its resetlogs_change# is greater
   -- than incrmin_scn or equal to incrmin_rlgscn.
   incrmin_scn           NUMBER,
   incrmin_rlgscn        NUMBER,

   -- This is the minimum checkpoint_change# of its backup that are kept
   -- for archived logs attribute and its corresponding resetlogs_change#.
   -- All archivelogs and its backups are kept if its first_change# is
   -- greater than the logmin_scn and its resetlogs_change# is greater
   -- thatn logmin_scn or equal to logmin_rlgscn.
   logmin_scn            NUMBER,
   logmin_rlgscn         NUMBER
);

TYPE lbDfRecTab_t  IS TABLE     OF lbDfRec_t      INDEX BY BINARY_INTEGER;
TYPE lbRecTab_t    IS TABLE     OF lbRec_t        INDEX BY BINARY_INTEGER;
TYPE lbRecVar_t    IS VARRAY(1) OF lbRec_t;
TYPE rcvRecTabI_t  IS TABLE     OF rcvRec_t       INDEX BY BINARY_INTEGER;
TYPE rcvRecTabII_t IS TABLE     OF rcvRecTabI_t   INDEX BY BINARY_INTEGER;
TYPE dfRecTab_t    IS TABLE     OF dfRec_t        INDEX BY BINARY_INTEGER;
TYPE numTab_t      IS TABLE     OF number         INDEX BY BINARY_INTEGER;
TYPE lbCursor_t    IS REF                         CURSOR;

-----------------------------------------------------------------------------
-- The following structire is used by the function listBackup. 
-- The variables in the strcuture are initialized when listBackup is called
-- with firstCall=TRUE.
-----------------------------------------------------------------------------
TYPE lbState_t   IS RECORD
  (
   -- The collection table lbRecOutTab keeps track of the rows which should
   -- returned by the function listBackup. The function listBackup will loop 
   -- until it does not fill lbRecOutTab with at least one element.
   lbRecOutTab        lbRecTab_t,
   lbRecOutTab_count  binary_integer,

   -- The collection table lbRecTmpTab keeps track of the backup datafiles and
   -- backup archived log rows which are part of the backup set.
   lbRecTmpTab        lbRecTab_t,

   -- The collection lbRecCmn keeps track of the backup set attributes.
   lbRecCmn           lbRec_t,

   -- The collection table lbDfRecTab contains the list of all database files 
   -- which ever existed after untilSCN.
   lbDfRecTabUs       lbDfRecTab_t,

   -- The collection table lbDfRecTab contains the list of all database files 
   -- which ever existed.
   lbDfRecTab         dfRecTab_t,

   -- This variable hols the maximum number of the datafile. It is used for 
   -- indextin of lbDfRecTab.
   lbMaxDfNumber      number,

   -- For keep backups we need to know the current time.
   lbNowTime          date,

   -- The table piece_count stores number of pieces in each copy. The variable
   -- copy_count says how many copies we have.
   lbPieceCountTab    numTab_t,
   lbCopyCount        binary_integer,

   -- Must Keep List is a table of rcvRecTabI_t indexed by binary_integer
   -- which itself is a table of rcvRec_t
   lbMkTab            rcvRecTabII_t,

   -- Must Keep Incremental List is a table of rcvRecTabI_t indexed by
   -- binary_integer which itself is a table of rcvRec_t
   lbMkITab           rcvRecTabII_t,

   -- The variable lbMinGrsp stands for minimum guaranteed restore point.
   -- An archived log backup set is obsolete if all rl_first_change#
   -- in the backup set is less than lbMinGrsp. No resetlogs information
   -- is compared. The redo log copies DOES NOT FOLLOW this rule. We
   -- keep the redo log copies only if needed by guaranteed restore point.
   -- The idea of keeping the backupset of redo log since the oldest GRP is
   -- to flashback to GRP2 from GRP1 (where GRP2 > GRP1) because it
   -- will require archivelogs outside the range listed by grsp table
   -- (from_scn - to_scn column).
   lbMinGrsp         number,

   -- The variable lbFbUntilTime stands for Flashback Until Time. 
   -- An archived log backup set is obsolete if all rl_first_time in the
   -- backup set is less than lbFbUntilTime. No resetlogs information is
   -- compared. The redo log copies (that is archived logs and proxy
   -- copies) follow the same rule.
   lbFbUntilTime     date,

   -- The variable lbRlKeepRlgSCN is the resetlogs_change# associated with
   -- the lbRlKeepSCN. It is used in conjunction with lbRlKeepSCN to
   -- decide an obsolete archived log. When NULL, the resetlogs_change#
   -- is unknown.
   lbRlKeepRlgSCN     number,

   -- The variable lbRlKeepSCN says that archived log backup set is
   -- obsolete if the rl_first_change# in the backup set is less than
   -- lbRlKeepSCN and its resetlogs_change# greater than lbRlKeepSCN and
   -- equal to lbRlKeepRlgSCN.
   -- The redo logs copies (that is archived logs and proxy copies)
   -- follow the same rule.
   lbRlKeepSCN        number,

   -- If either lbObsoleteRetention or lbObsoleteKeep is set to TRUE when the
   -- current backup processed by listBackup is obsolete. 
   -- If lbObsoleteRetention is TRUE, then the backup is obsolete because of 
   -- retention policy. If lbObsoleteKeep is TRUE, then the backup is obsolete 
   -- because of its keep attributes.
   lbObsoleteRetention boolean,
   lbKeepForDBPITR     boolean,
   lbObsoleteKeep      boolean,

   lbNeedObsoleteData  boolean
 );

-- In case that listBackup is not called from pipeline function, then
-- there is no need for the called to save and maintain the state:  the
-- function will use state from the package.
lbStatePck   lbState_t;

---------------------------------------------------------------------------
-- End of global variable used by the function listBackup. 
---------------------------------------------------------------------------

-- Intelligent Repair variables

TYPE failureRec_t IS RECORD
(
   priority      VARCHAR2(8),
   failureId     NUMBER,
   parentId      NUMBER,
   childCount    NUMBER,
   description   VARCHAR2(1024),
   timeDetected  DATE,
   status        VARCHAR2(12),
   impacts       VARCHAR2(1024)
);

TYPE repairRec_t IS RECORD
(
   type          NUMBER,
   failureidx    NUMBER,
   repairidx     NUMBER,
   description   VARCHAR2(1024)
);

TYPE repairParmsRec_t IS RECORD
(
   type          NUMBER,
   failureidx    NUMBER,
   repairidx     NUMBER,
   name          VARCHAR2(256),
   value         VARCHAR2(512)
);

TYPE repairOptionRec_t IS RECORD
(
   optionidx     NUMBER,
   description   VARCHAR2(1024)
);

TYPE repairStepRec_t IS RECORD
(
   type           NUMBER,
   failureidx     NUMBER,
   repairidx      NUMBER,
   repairstepidx  NUMBER,
   workingrepair  NUMBER,
   description    VARCHAR2(1024),
   repairscript   VARCHAR2(1024)
);
    
-----------------------------------------------------
-- PUBLIC FUNCTION/PROCEDURE SPECIFICATION SECTION --
-----------------------------------------------------

----------------------------------------
-- Debugging functions and procedures --
----------------------------------------

FUNCTION dumpState(
   lineno IN number)
RETURN varchar2;

PROCEDURE dumpPkgState(msg in varchar2 default null);

PROCEDURE setDebugOn;

PROCEDURE setDebugOff;

----------------------------
-- Package Initialization --
----------------------------

-- This is a vestigal function that was released to customers in 8.1.3 Beta.
-- It is no longer called, and is no longer needed, but must still be here
-- because this version of the package may be called by an 8.1.3 rman
-- executable.

PROCEDURE initialize(rman_vsn IN number);

-- Used by 8.1.5 to re-assign the order of the backup_type constants to their
-- correct order.  This procedure is not called by 8.1.4-, so the constants
-- will reamin set to the above values for those executables.

PROCEDURE set_package_constants;

-----------------------
-- Utility functions --
-----------------------

FUNCTION stamp2date(stamp IN number) RETURN date;

------------------------------------
-- Get Current Database Incarnation 
------------------------------------
PROCEDURE getCurrentIncarnation(
   db_id          IN  number
  ,reset_scn      OUT number
  ,reset_time     OUT date);

------------------------------
-- Set Database Incarnation --
------------------------------

-- setDatabase selects which target database subsequent dbms_rcvman
-- procedures operate on. Note that only the current incarnation can be
-- selected. If the target database or its current incarnation is not
-- registered then setDatabase will fail.
-- setDatabase sets the package state variables to point to the selected
-- database and its current incarnation.
-- The settings will be valid until the end of the session unless setDatabase
-- is called again

-- When dbms_rcvman package executes against the target database controlfile,
-- setDatabase just returns without doing anything.

-- Input parameters:
--   db_id
--     the value of kccfhdbi from the controlfile of the target database
--   db_name
--     the name of the database
--   reset_scn
--     the resetlogs SCN of this database
--   reset_time
--     the resetlogs time
-- Exceptions:
--   DATABASE_NOT_FOUND (ORA-20001)
--     No database with the given db_id was found in the recovery catalog
--     The database must be registered using registerDatabase first
--   DATABASE_INCARNATION_NOT_FOUND (ORA-20003)
--     No database incarnation matches the given arguments
--     The database incarnation must be registered using resetDatabase first

PROCEDURE setDatabase(
   db_name    IN varchar2
  ,reset_scn  IN number
  ,reset_time IN date
  ,db_id      IN number
  ,db_unique_name IN varchar2 default NULL
  ,site_aware IN boolean default FALSE
  ,dummy_instance  IN boolean default FALSE);

-- Return the db_unique_name associated with the db_id if there is one 
-- db_unique_name. If there is more than one db_unique_name, then raise
-- too_many_rows error. If there is no row, then return NULL.
FUNCTION getDbUniqueName(
   db_id      IN number)
RETURN varchar2;

-- Return TRUE if the database site identified by current db_unique_name 
-- is standby
FUNCTION DbUniqueNameIsStandby
RETURN NUMBER;

-- setCanConvertCf used to tell that client is capable of control file
-- conversion
PROCEDURE setCanConvertCf(flag IN boolean);

-- setDbincKey used in lieu of setDatabase for when SET DBID command is
-- issued.
PROCEDURE setDbincKey(
   key IN number);

-- getParent Incarnation returns the parent incarnation.  If resetlogs_change#
-- is NULL on input, then the current incarnation is returned.  Returns TRUE
-- if a row was returned, otherwise returns FALSE.

FUNCTION getParentIncarnation(
   resetlogs_change# IN OUT number
  ,resetlogs_time    IN OUT date)
RETURN number;

-- getCheckpoint gets and returns the highest recovery catalog checkpoint SCN
-- for FULL checkpoints.  This SCN indicates how current the datafilenames and
-- lognames in the recovery catalog are.  This SCN can be compared with a
-- backup controlfile SCN to decide which name to use if they differ.

PROCEDURE getCheckpoint(
   scn OUT number
  ,seq OUT number);

-- This version of getCheckpoint is only used internally by
-- dbms_rcvcat.cleanupCKP, to find out which rows can't be deleted from ckp.

PROCEDURE getCheckpoint(
   scn       OUT number
  ,seq       OUT number
  ,ckp_key_1 OUT number
  ,ckp_key_2 OUT number);

-- This procedure sets the package variables to return all logs not
-- backed ntimes to specific device type until sbpscn (standby became primary
-- SCN) ignore needstby flag for the subsequent archivelog translations.
PROCEDURE SetGetSinceLastBackedAL(ntimes  IN number DEFAULT 1,
                                  devtype IN varchar2 DEFAULT NULL,
                                  sbpscn  IN number);

-------------------
-- Query Filters --
-------------------

-- setCompletedRange sets completedBefore and/or completedAfter filters for
-- use by computeRecoveryActions.
-- setLikePattern sets fileName patter for computeRecoveryActions.
--
-- setUntilTime, setUntilScn, setUntilLog, setToLog, setUntilResetlogs,
-- resetUntil.
-- These procedures are used to inform dbms_rcvman of an until_clause.
-- The setUntil remains in effect until another setUntil has been called,
-- or until resetUntil has been called.
-- If none of these have been called, then all queries for name
-- translation, restore, and recovery should assume that a complete recovery
-- is being done.  Otherwise, all restore and recovery queries should limit
-- their replies to backup sets and datafile copies that are appropriate for
-- use in an incomplete recovery until the specified until condition.  Name
-- translations should be done relative to the specified epoch.
--
-- "appropriate" means that the fuzziness of the backup datafile or datafile
-- copy ends at an SCN less than the untilChange SCN (for untilChange), or the
-- low SCN of the specified log (for untilLog), or the fuzziness timestamp is
-- less than the specified time (for unttime).  Note that datafiles have three
-- kinds of fuzziness, all of which must be less than the specified SCN or
-- time.  If the fuzziness of a datafile is unknown, then it should be
-- ignored.
--
-- The setUntil procedures will signal an error when executed against
-- the target database controlfile. The resetUntil procedure can be
-- executed against the controlfile, it but doesn't have any effect.

-- Input parameters:
--   unttime
--     The incomplete recovery will stop when this timestamp is reached
--     in the redo log.
--   scn
--     The incomplete recovery will stop when this scn is reached in the redo
--     log.
--   sequence#, thread#
--     The incomplete recovery will stop when this log becomes the very next
--     log to be applied.
--
-- Exceptions:
--   NO_RECOVERY_CATALOG (ORA-20300)
--     this operation is not supported without the recovery catalog
--   SEQUENCE_IS_NULL (ORA-20205)
--     A null log sequence# was given
--   LOG_MISSING (ORA-20206)
--     No log with the give thread# and sequence# was found

PROCEDURE setCompletedRange(
   after  IN date
  ,before IN date);

PROCEDURE setLikePattern(
   pattern IN varchar2);

PROCEDURE setcanApplyAnyRedo(
   flag IN boolean);

-- Obsolete as of 8.1.6
PROCEDURE setAllFlag(
   flag IN boolean);

PROCEDURE setAllIncarnations(
   flag IN boolean);

PROCEDURE setUntilTime(
   unttime IN date);

-- If rlgscn, rlgtime is not provided, then the provided scn belongs to
-- current or one of its parent. Otherwise, it should belong to the given
-- rlgscn and lrgtime.
-- If flbrp (flashback to restore point) is TRUE, then allow scn to be
-- in orphan branch. Otherwise, we force scn be in one of its parent or
-- current branch.
PROCEDURE setUntilScn(
   scn     IN number
  ,rlgscn  IN number  DEFAULT NULL
  ,rlgtime IN date    DEFAULT NULL
  ,flbrp   IN boolean DEFAULT FALSE
  ,rpoint  IN boolean DEFAULT FALSE);

PROCEDURE setUntilLog(
   sequence# IN number
  ,thread#   IN number);

PROCEDURE setToLog(
   sequence# IN number
  ,thread#   IN number);

PROCEDURE setUntilResetlogs;

FUNCTION getUntilTime return date;

FUNCTION getUntilScn return number;

PROCEDURE resetUntil;

-- setFrom is used to limit the potential restore candidates to either
-- backup sets or datafile copies, or to allow either kind of file to
-- be used.
--
-- Input parameters:
--   restorefrom
--     One of BACKUP, COPY, or NULL.

PROCEDURE setFrom(
   restorefrom IN number DEFAULT NULL);

-- setDeviceType specifies the type of an allocated device.  It is called 1 or
-- more (up to 8) times , depending on the number of different device types
-- that are allocated.  dbms_rcvman should return only files that can be
-- accessed through one of the device types specifed through this call.
--
-- Input parameters:
--   type
--     type of the device
-- Exceptions:
--   NULL_DEVICE_TYPE
--     A null device type was specied
--   TOO_MANY_DEVICE_TYPES
--     At most 8 device types can be specified

PROCEDURE setDeviceType(
   type IN varchar2);

-- setDeviceTypeAny is an alternative to setDeviceType.  It causes dbms_rcvman
-- to return a backup set on ANY device type.

PROCEDURE setStandby(
   stby IN boolean);

PROCEDURE setDeviceTypeAny;

-- resetDeviceType resets the list of device types to null.

PROCEDURE resetDeviceType;

-- setTag is used to limit the restore candidates to backups and copies with
-- the given tag. If the tag is NULL then all backups and copies are searched
-- by the find functions.
--
-- Input parameters:
--   tag
--     tag of the datafile copies to be translated
--     The tag must be passed in uppercase ### ok?

PROCEDURE setTag(tag IN varchar2 DEFAULT NULL);

-- setRecoveryDestFile is used to limit the translation only to recovery   
-- area files.
--            
-- Input parameters:
--   onlyrdf
--      TRUE  - only recovery area files
--      FALSE - all files

PROCEDURE setRecoveryDestFile(onlyrdf IN BOOLEAN);

-- Set a site name in catalog -- all the translation will happen against this
-- site. The package variable will be cleared after translation.
-- If for_realfiles parameter is non-zero, then the translation for files
-- in working area (datafile/onlinelogs/tempfiles) are done against
-- the requested site.
PROCEDURE setSiteName(db_unique_name IN VARCHAR2, for_realfiles IN NUMBER);

-- Clear package variables set by setSiteName procedure
PROCEDURE clrSiteName;

-- get site name for given site_key
FUNCTION getSiteName(site_key IN NUMBER) RETURN VARCHAR2;

-- get site key for given db_unique_name
FUNCTION getSiteKey(db_unique_name IN VARCHAR2) RETURN NUMBER;

-- set Archive log file sharing scope attributes for the session
PROCEDURE setArchiveFileScopeAttributes(logs_shared IN NUMBER);

-- set Backup file sharing scope attributes for the session
PROCEDURE setBackupFileScopeAttributes(
                 disk_backups_shared IN NUMBER,
                 tape_backups_shared IN NUMBER);

-- resetAll calls resetUntil, setFrom, resetDevice and setTag to reset
-- everything.

PROCEDURE resetAll(transclause IN BOOLEAN DEFAULT TRUE);

---------------------------
-- Backup Set Validation --
---------------------------

-- Use the findValidBackupSetRec public variable to save a backupset record
-- for later use as an input argument to this procedure.

findValidBackupSetRcvRec rcvRec_t;              -- place to save a rcvRec_t

PROCEDURE findValidBackupSet(
   backupSetRec            IN     rcvRec_t
  ,deviceType              IN     varchar2       DEFAULT NULL
  ,tag                     IN     varchar2       DEFAULT NULL
  ,available               IN     number         DEFAULT TRUE#  -- for compat.
  ,unavailable             IN     number         DEFAULT FALSE# -- for compat.
  ,deleted                 IN     number         DEFAULT FALSE# -- for compat.
  ,expired                 IN     number         DEFAULT FALSE# -- for compat.
  ,availableMask           IN     binary_integer DEFAULT NULL); -- for compat.

findValidBackupSetBsRec  bsRec_t;               -- place to save a bsRec_t

-- Obsolete as of 8.1.7
PROCEDURE findValidBackupSet(
   backupSetRec            IN     bsRec_t
  ,deviceType              IN     varchar2       DEFAULT NULL
  ,tag                     IN     varchar2       DEFAULT NULL
  ,available               IN     number         DEFAULT TRUE#  -- for compat.
  ,unavailable             IN     number         DEFAULT FALSE# -- for compat.
  ,deleted                 IN     number         DEFAULT FALSE# -- for compat.
  ,expired                 IN     number         DEFAULT FALSE# -- for compat.
  ,availableMask           IN     binary_integer DEFAULT NULL); -- for compat.

FUNCTION getValidBackupSet(
   validBackupSetRec            OUT NOCOPY validBackupSetRec_t
  ,checkDeviceIsAllocated       IN  number DEFAULT FALSE#)
RETURN number;                                  -- TRUE# -> got a record
                                                -- FALSE# -> no_data_found

---------------------
-- Get an rcvRec_t --
---------------------

-- This function is a cover function for all procedures/functions that
-- return a rcvRec_t.  It routes the call to the correct procedure.  It
-- is provided for the convienence of krmk.pc.  The function return value
-- is whatever the underlying function returns.  If we call a procedure,
-- then getRcvRec returns 0.  Refer to the funCode list above in the
-- types/variables section.

FUNCTION getRcvRec(
   funCode      IN number
  ,rcvRec       OUT NOCOPY rcvRec_t
  ,callAgain    OUT number)
RETURN number;

--------------------------
-- Datafile Translation --
--------------------------

-- translateTableSpace translates a tablespace name into a list of datafile
-- numbers.  translateDataBase translates the database into a list of datafile
-- numbers in the database excluding datafiles belonging to tablespaces
-- specified using skipTableSpace.  The translation is performed relative to
-- epoch setting currently in use.  getDataFile is used to obtain the datafile
-- numbers, one at a time until null is returned.

-- When doing the translation relative to current time the client should
-- ensure that recovery catalog is up-to-date. When doing translations
-- relative to an point-in-time in the past two potential anomalies may
-- show up.
--
-- 1) files belonging to a tablespace that was dropped before the point-in-time
-- may be returned since the drop_scn and drop_time are approximations.
-- As a result of this point-in-time recovery will restore and recover
-- a tablespace which will be dropped before the database is opened.
-- No real harm, just extra work for the recovery. And this won't happen
-- if rcvcat is resynced immediatly after dropping a tablespace.
-- 2) A tablespace which is created and dropped between two consecutive
-- recovery catalog resyncs will never be recorded in the rcvcat. It is
-- conceivable that such a tablespace existed at the intended point-in-time.
-- As a result the tablespace will not be recovered and must be dropped
-- after the database is opened. The worst case scenario is that a rollback
-- segment was also created in this tablespace. The recovered database
-- might fail to rollback some transactions. Again, this won't happen if
-- rcvcat is always resynced after creating a tablespace.
-- PS. These anomalies won't occur if the point-in-time is chosen to be
-- a rcvcat checkpoint.

-- Input parameters:
--   ts_name
--     name of the tablespace to be translated or skipped.
--     The name must be in uppercase
-- Exceptions:
--   TABLESPACE_DOES_NOT_EXIST (ORA-20202)
--     the tablespace to be translated does not exists (does not have any
--     datafiles). Check that the recovery catalog is current.
--   TRANSLATION_IN_PROGRESS (ORA-20203)
--     the previous translation conversation is still in progess.
--     To terminate get all datafiles with getDataFile.
--   TRANSLATION_NOT_IN_PROGRESS (ORA-20204)
--     getDataFile was called with no translation in progress

PROCEDURE translateDatabase(
   sinceUntilSCN IN number DEFAULT NULL);

PROCEDURE skipTableSpace(
   ts_name IN varchar2);

PROCEDURE translateTablespace(
   ts_name IN varchar2);

-- translateDataFile translates the datafile name/number into
-- a datafile number and creation SCN and filename.  getDataFile must
-- be called to obtain the translation info, just as for the other translate
-- functions.
-- Unlike the other translation functions, translateDatafile by name is always
-- performed relative to current time.  If an until setting is in effect,
-- and if the filename is ambiguous, then an exception is raised.  Ambiguous
-- means that the filename refers to different datafile at the until time than
-- it does at the current time.  This happens only when a filename has been
-- reused.  When fno and ckpscn are passed, the filename and other info as of
-- that scn is returned.

-- Input parameters:
--   fname
--     name of the datafile to be translated.
--     The name must be a normalized filename.
--   fno
--     The datafile number.  If the datafile number was not in use at the
--     until time, then an exception is raised.
-- Exceptions:
--   DATAFILE_DOES_NOT_EXIST (ORA-20201)
--     the datafile to be translated does not exists
--     Check that the recovery catalog is current.

PROCEDURE translateDataFile(
   fname IN varchar2);

PROCEDURE translateDatafile(
   fno   IN number);

PROCEDURE translateDatafile(
   fno    IN number
  ,ckpscn IN number);

-- translateAllDatafile returns a list of all datafiles that ever
-- existed in this database.

PROCEDURE translateAllDatafile;

PROCEDURE translateCorruptList;

PROCEDURE getDatafile(
   dfRec     OUT NOCOPY dfRec_t
  ,oldClient IN  boolean DEFAULT FALSE);

-- Obsolete as of 8.1.6
PROCEDURE getDataFile(
   file#        OUT number
  ,crescn       OUT number
  ,creation_time OUT date
  ,fname        OUT varchar2
  ,ts_name      OUT varchar2
  ,status       OUT number
  ,blksize      OUT number
  ,kbytes       OUT number
  ,blocks       OUT number
  ,unrecoverable_change# OUT number
  ,stop_change# OUT number
  ,read_only    OUT number);

--------------------------
-- Tempfile Translation --
--------------------------
-- translateTempfile translates tempfiles known to database in current
-- incarnation.
PROCEDURE translateTempfile;

PROCEDURE translateTempfile(fname IN varchar2);

PROCEDURE translateTempfile(fno IN number);

-- Fetch the cursor opened by translateTempfiles and return a row one
-- at a time until all rows are returned. Signal ORA-1403 (no-data-found)
-- when there are no more rows to return.
PROCEDURE getTempfile(tfRec OUT NOCOPY tfRec_t);

----------------------------
-- Online Log Translation --
----------------------------

-- translateOnlineLogs translates the database to a list of online redo logs.
-- The translation is always performed relative to current epoch.

PROCEDURE translateOnlineLogs(srls IN number DEFAULT 0);

PROCEDURE getOnlineLog(
   fname        OUT varchar2
  ,thread#      OUT number
  ,group#       OUT number);

-----------------------------
-- Archivedlog Translation --
-----------------------------

-- translateArchivedLogKey translates the archived log key to a archived
-- log recid and stamp in V$ARCHIVED_LOG.

-- translateArchivedLogRange* procedures translate a specified
-- archive log range to a list of archived logs.
-- getArchivedLog is used to get the recid and stamp for each archived log,
-- one at a time until null is returned.

-- The available, unavailable and deleted parameters are used to limit
-- the translation to archived logs with the desired status. For example,
-- only available archived logs can be backed up, but unavailable and deleted
-- archived logs can be restored from backups.

-- The duplicates parameter controls whether the translation returns all
-- archived logs or eliminates duplicate ones. Archived logs that have the
-- same thread#, sequence# and low_scn are considered duplicates. (duplicate
-- archived logs are usually created by copying archived logs).

-- Note that only archived logs recorded in the recovery catalog or
-- controlfile file are returned. If there is an archived log that belongs
-- to the range but is not known, there will be a "hole" in the range.

-- Input parameters:
--    al_key
--      key of the archived log record in the recovery catalog
--   thread#
--     return only logs that belong to this thread#
--     if NULL return logs for all threads
--   fromseq#
--     lowest log sequence number in the range
--   toseq#
--     highest log sequence number in the range
--   fromtime
--     exclude logs that were switched out before fromtime
--   totime
--     exclude logs that were switched in after totime
--   fromscn
--     exclude logs that were switched out before fromscn
--   toscn
--     exclude logs that were switched in after toscn
--   pattern
--     return only archived logs whose filename match the pattern
--     The pattern is matched against normalized filenames ### ok?
--   available
--     if TRUE (1) return available archived logs
--   unavailable
--     if TRUE (1) return unavailable archived logs
--   deleted
--     if TRUE (1) return deleted archived logs
--   online
--     if TRUE (1) return also inspected online logs (in addition to
--     archived logs)
--   duplicates
--     if TRUE (1) return all archived logs
--     if FALSE (0) eliminate duplicate archived logs
-- Output parameters:
--    recid
--      recid of the archived log record (in V$ARCHIVED_LOG)
--    stamp
--      stamp of the archived log record (in V$ARCHIVED_LOG)
--    thread#
--    sequence#
--    low_scn
--    fname
--    reset_scn
--    block_size
-- Exceptions:
--  NO_RECOVERY_CATALOG (ORA-20300)
--    this operation is not supported without the recovery catalog
--  ARCHIVED_LOG_DOES_NOT_EXIST
--    the key does not match any archived log
--   TRANSLATION_IN_PROGRESS (ORA-20203)
--     the previous translation conversation is still in progess.
--     To terminate get all datafiles with getArchivedLog.
--   TRANSLATION_NOT_IN_PROGRESS (ORA-20204)
--     getArchivedLog was called with no translation in progress
--   THREAD_IS_NULL (ORA-20210)
--     a null thread# was passed to translateArchivedLogSeqRange
--   HIGH_SEQUENCE_IS_NULL
--     a null toseq# was passed to translateArchivedLogSeqRange
--   UNTIL_TIME_IS_NULL (ORA-20212)
--     a null totime was passed to translateArchivedLogTimeRange
--   UNTIL_SCN_IS_NULL (ORA-20213)
--     a null toscn was passed to translateArchivedLogSCNRange
--   ARCHIVED_LOG_RANGE_IS_EMPTY
--     the specified range doesn't contain any archived log

------------------------------
-- Archived Log Translation --
------------------------------

PROCEDURE getArchivedLog(
   alRec       OUT NOCOPY alRec_t
  ,closeCursor IN  boolean DEFAULT FALSE);

PROCEDURE translateArchivedLogKey(
   al_key       IN  number
  ,available    IN  number       DEFAULT 1 -- ignored (for compatability)
  ,unavailable  IN  number       DEFAULT 1 -- ignored (for compatability)
  ,deleted      IN  number       DEFAULT 1 -- ignored (for compatability)
  ,online       IN  number       DEFAULT 1 -- ignored (for compatability)
  ,recid        OUT number
  ,stamp        OUT number
  ,thread#      OUT number
  ,sequence#    OUT number
  ,low_scn      OUT number
  ,reset_scn    OUT number
  ,block_size   OUT number
  ,fname        OUT varchar2
  ,needstby     IN number        DEFAULT NULL);

PROCEDURE translateArchivedLogName(
   fname        IN varchar2
  ,available    IN number         DEFAULT NULL   -- for compatability
  ,unavailable  IN number         DEFAULT NULL   -- for compatability
  ,deleted      IN number         DEFAULT NULL   -- for compatability
  ,online       IN number                        -- ignored
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL   -- for compatability
  ,needstby     IN number         DEFAULT NULL); -- for compatability

-- For translate functions, the incarn parameter is interpreted as:
--    -1   -- current incarnation
--    0    -- any incarnation
--    other-- a specific incarnation number
--    NULL -- should be defaulted

PROCEDURE translateArchivedLogSeqRange(
   thread#      IN number
  ,fromseq#     IN number
  ,toseq#       IN number
  ,pattern      IN varchar2
  ,available    IN number         DEFAULT NULL     -- for compatability
  ,unavailable  IN number         DEFAULT NULL     -- for compatability
  ,deleted      IN number         DEFAULT NULL     -- for compatability
  ,online       IN number                          -- ignored
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL     -- for compatability
  ,needstby     IN number         DEFAULT NULL     -- for compatability
  ,foreignal    IN binary_integer DEFAULT 0        -- for compatability
  ,incarn       IN number         DEFAULT NULL);   -- for compatibility

PROCEDURE translateArchivedLogTimeRange(
   thread#      IN number
  ,fromTime     IN date
  ,toTime       IN date
  ,pattern      IN varchar2
  ,available    IN number         DEFAULT NULL     -- for compatability
  ,unavailable  IN number         DEFAULT NULL     -- for compatability
  ,deleted      IN number         DEFAULT NULL     -- for compatability
  ,online       IN number                          -- ignored
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL     -- for compatability
  ,needstby     IN number         DEFAULT NULL     -- for compatability
  ,foreignal    IN binary_integer DEFAULT 0        -- for compatability
  ,incarn       IN number         DEFAULT NULL);   -- for compatibility

PROCEDURE translateArchivedLogSCNRange(
   thread#      IN number
  ,fromSCN      IN number
  ,toSCN        IN number
  ,pattern      IN varchar2
  ,available    IN number         DEFAULT NULL     -- for compatability
  ,unavailable  IN number         DEFAULT NULL     -- for compatability
  ,deleted      IN number         DEFAULT NULL     -- for compatability
  ,online       IN number
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL     -- for compatability
  ,needstby     IN number         DEFAULT NULL
  ,doingRecovery IN  number DEFAULT FALSE#
  ,onlyrdf      IN binary_integer DEFAULT 0        -- for compatability
  ,reset_scn    IN number         DEFAULT NULL     -- for compatability
  ,reset_time   IN date           DEFAULT NULL     -- for compatability
  ,sequence#    IN number         DEFAULT NULL     -- for compatability
  ,foreignal    IN binary_integer DEFAULT 0        -- for compatability
  ,incarn       IN number         DEFAULT NULL);   -- for compatibility

PROCEDURE translateArchivedLogPattern(
   pattern      IN varchar2
  ,available    IN number         DEFAULT NULL     -- for compatability
  ,unavailable  IN number         DEFAULT NULL     -- for compatability
  ,deleted      IN number         DEFAULT NULL     -- for compatability
  ,online       IN number                          -- ignored
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL     -- for compatability
  ,needstby     IN number         DEFAULT NULL     -- for compatability
  ,foreignal    IN binary_integer DEFAULT 0);      -- for compatability

PROCEDURE translateArchivedLogCancel;


-- Set/Get filter functions for job views
PROCEDURE sv_setSessionKey(skey IN NUMBER);
PROCEDURE sv_setSessionTimeRange(fromTime IN DATE, untilTime IN DATE);

FUNCTION sv_getSessionKey RETURN NUMBER;
FUNCTION sv_getSessionfromTimeRange RETURN DATE;
FUNCTION sv_getSessionUntilTimeRange RETURN DATE;

-- translateBackupPieceKey looks up a backup piece by primary key.
-- translateBackupPieceHandle looks up a backup piece by handle and deviceType.
-- translatebackupPieceTag looks up backup pieces by tag.

-- The available are unavailable parameters are used to limit the translation
-- to backup pieces with the desired status. For example, only available
-- backup pieces can be backed up, but unavailable pieces can be made
-- available.  Deleted backup pieces are never returned.

-- Input parameters:
--    bp_key
--      key of the backup piece record in the recovery catalog
--    handle
--      backup piece handle
--    device type
--      device type on which the backup piece resides
-- Exceptions:
--   NO_RECOVERY_CATALOG (ORA-20300)
--     this operation is not supported without the recovery catalog
--   BACKUP_PIECE_DOES_NOT_EXIST
--     the key does not match any backup piece
--   BACKUP_PIECE_HANDLE_IS_AMBIGUOUS
--     the key does not match any backup piece

-- Obsolete as of 8.1.6
PROCEDURE getArchivedLog(
   recid        OUT number
  ,stamp        OUT number
  ,thread#      OUT number
  ,sequence#    OUT number
  ,low_scn      OUT number
  ,nxt_scn      OUT number
  ,fname        OUT varchar2
  ,reset_scn    OUT number
  ,block_size   OUT number
  ,blocks       OUT number);

---------------------------------
-- Controlfilecopy Translation --
---------------------------------

-- translateControlFileCopyName translates a control file name into a list of
-- control file copies.
-- Input parameters:
--   fname
--     name of the controlfile copy to be translated.
--     The name must be a normalized filename
-- Exceptions:
--   CONTROLFILE_COPY_DOES_NOT_EXIST
--     The filename does not match any controlfile copy

PROCEDURE translateControlFileCopyName(
   fname        IN varchar2
  ,available    IN number         DEFAULT NULL -- for compatability
  ,unavailable  IN number         DEFAULT NULL -- for compatability
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL -- for compatability
  ,onlyone      IN number         DEFAULT 1);

PROCEDURE translateControlFileCopyTag(
   cftag        IN varchar2
  ,available    IN number         DEFAULT NULL -- for compatability
  ,unavailable  IN number         DEFAULT NULL -- for compatability
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL -- for compatability
  ,onlyone      IN number         DEFAULT 1);

PROCEDURE translateControlFileCopyKey(
   key          IN number
  ,available    IN number         DEFAULT NULL    -- for compatability
  ,unavailable  IN number         DEFAULT NULL    -- for compatability
  ,statusMask   IN binary_integer DEFAULT NULL);  -- for compatability


PROCEDURE getControlFileCopy(
   rcvRec       IN OUT NOCOPY rcvRec_t);

-- Obsolete as of 8.1.6
PROCEDURE getControlFileCopy(
   recid        OUT number
  ,stamp        OUT number
  ,reset_scn    OUT number
  ,ckp_scn      OUT number
  ,block_size   OUT number);

------------------------------
-- Datafilecopy Translation --
------------------------------

PROCEDURE getDataFileCopy(
   rcvRec       OUT NOCOPY rcvRec_t
  ,closeCursor  IN  boolean DEFAULT FALSE);

-- translateDataFileCopyKey translates the datafile copy key into a
-- datafile copy recid and stamp in V$DATAFILE_COPY.

-- translateDataFileCopyNumber translates a file number and (optional) tag
-- to a datafile copy recid and stamp. Not used currently in 8.0.

-- translatedDataFileCopyName translates the datafile copy name into a
-- a list of datafile copies and getDataFileCopy returns the recid and stamp
-- of each datafile copy. The duplicates parameter controls whether
-- getDataFileCopy returns all matching datafile copies or just the most
-- recent copy (highest stamp in rcvcat or highest recid in controlfile).

-- translateDataFileCopyTag translates the tag into a list of datafile
-- copies and getDataFileCopy returns the recid and stamp of each datafile copy
-- one at a time until null is returned.

-- translateDataFileCopyFno translates a file number into a list of datafile
-- copies.  getDataFileCopy returns the recid and stamp of each datafile
-- copy one at at time until null is returned.  The duplicates parameter
-- controls whether getDataFileCopy returns all matching datafile copies or
-- just the most recent copy (highest stamp in rcvcat or highest recid in
-- controlfile).

-- The available are unavailable parameters are used to limit the translation
-- to datafile copies with the desired status. For example, only available
-- datafile copies can be backed up, but unavailable copies can be made
-- available. Deleted copies are never returned.

-- The duplicates parameter controls whether getDataFileCopy returns all
-- datafile copies or just the most recent (highest checkpoint scn) copy
-- of each datafile (file#).

-- Input parameters:
--   cdf_key
--     key of the datafile copy record in the recovery catalog
--   fname
--     name of the datafile copy to be translated.
--     The name must be a normalized filename
--   tag
--     tag of the datafile copies to be translated
--     The tag must be passed exactly as stored in the controlfile,
--     it is not uppercased by translate
--   available
--     if TRUE (1) return available datafile copies
--   unavailable
--     if TRUE (1) return unavailable datafile copies
--   duplicates
--     if TRUE (1) return all datafile copies
--     if FALSE (0) eliminate duplicate datafile copies
--
--    The remaining parameters are returned for deleteDataFileCopy
--
--    file#
--    fname
--    reset_scn
--    create_scn
--    ckp_scn
--    blocks_size
--
-- Exceptions:
--   NO_RECOVERY_CATALOG (ORA-20300)
--     translation by key is not supported without the recovery catalog
--   DATAFILE_COPY_DOES_NOT_EXIST
--     the specified key or filename does not match any datafile copy
--   DATAFILE_COPY_NAME_AMBIGUOUS
--     the specified filename matches more than one datafile copy
--   TAG_DOES_NOT_MATCH
--     the specified tag doesn't match any datafile copies
--   TRANSLATION_IN_PROGRESS (ORA-20203)
--     the previous translation conversation is still in progess.
--     To terminate get all datafiles with getDataFileCopy.
--   TRANSLATION_NOT_IN_PROGRESS (ORA-20204)
--     getDataFileCopy was called with no translation in progress

PROCEDURE translateDataFileCopyKey(
   cdf_key      IN number
  ,available    IN number         DEFAULT NULL   -- for compatability
  ,unavailable  IN number         DEFAULT NULL   -- for compatability
  ,statusMask   IN binary_integer DEFAULT NULL); -- for compatability

-- Obsolete as of 8.1.6
PROCEDURE translateDataFileCopyKey(
   cdf_key      IN number
  ,available    IN number
  ,unavailable  IN number
  ,recid        OUT number
  ,stamp        OUT number
  ,file#        OUT number
  ,fname        OUT varchar2
  ,reset_scn    OUT number
  ,create_scn   OUT number
  ,ckp_scn      OUT number
  ,block_size   OUT number
  ,blocks       OUT number);

PROCEDURE translateDataFileCopyName(
   fname        IN varchar2
  ,available    IN number         DEFAULT NULL   -- for compatability
  ,unavailable  IN number         DEFAULT NULL   -- for compatability
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL   -- for compatability
  ,onlyone      IN number         DEFAULT 1
  ,pluginSCN    IN number         DEFAULT 0);

PROCEDURE translateDataFileCopyTag(
   tag          IN varchar2
  ,available    IN number         DEFAULT NULL     -- for compatibility
  ,unavailable  IN number         DEFAULT NULL     -- for compatibility
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL     -- for compatibility
  ,pluginSCN    IN number         DEFAULT 0
  ,onlytc       IN binary_integer DEFAULT FALSE#); -- for compatibility

PROCEDURE translateDataFileCopyFno(
   fno          IN number
  ,available    IN number         DEFAULT NULL
  ,unavailable  IN number         DEFAULT NULL
  ,duplicates   IN number
  ,statusMask   IN binary_integer DEFAULT NULL
  ,pluginSCN    IN number         DEFAULT 0);

PROCEDURE translateDataFileCopy(
   duplicates   IN number
  ,statusMask   IN binary_integer
  ,onlyrdf      IN binary_integer
  ,pluginSCN    IN number         DEFAULT 0);

-- Bug 2391697
PROCEDURE translateDatafileCancel;

-- Obsolete as of 8.1.6
PROCEDURE getDataFileCopy(
   recid        OUT number
  ,stamp        OUT number
  ,file#        OUT number
  ,fname        OUT varchar2
  ,reset_scn    OUT number
  ,create_scn   OUT number
  ,ckp_scn      OUT number
  ,block_size   OUT number
  ,blocks       OUT number);

----------------------------
-- Proxy Copy Translation --
----------------------------

PROCEDURE getProxyCopy(
   rcvRec       OUT NOCOPY rcvRec_t
  ,closeCursor  IN  boolean DEFAULT FALSE);

PROCEDURE translateProxyCopyKey(
   pc_key       IN number
  ,deviceType   IN varchar2
  ,available    IN number           DEFAULT NULL   -- for compatability
  ,unavailable  IN number           DEFAULT NULL   -- for compatability
  ,deleted      IN number           DEFAULT NULL   -- for compatability
  ,expired      IN number           DEFAULT NULL   -- for compatability
  ,statusMask   IN binary_integer   DEFAULT NULL); -- for compatability

-- Obsolete as of 8.1.6
PROCEDURE translateProxyCopyKey(
   pc_key       IN number
  ,device_type  IN varchar2
  ,available    IN number
  ,unavailable  IN number
  ,deleted      IN number
  ,recid        OUT number
  ,stamp        OUT number
  ,handle       OUT varchar2);

PROCEDURE translateProxyCopyHandle(
   handle       IN varchar2
  ,deviceType   IN varchar2
  ,available    IN number           DEFAULT NULL   -- for compatability
  ,unavailable  IN number           DEFAULT NULL   -- for compatability
  ,deleted      IN number           DEFAULT NULL   -- for compatability
  ,expired      IN number           DEFAULT NULL   -- for compatability
  ,statusMask   IN binary_integer   DEFAULT NULL); -- for compatability

-- Obsolete as of 8.1.6
PROCEDURE translateProxyCopyHandle(
   handle       IN varchar2
  ,device_type  IN varchar2
  ,available    IN number
  ,unavailable  IN number
  ,deleted      IN number
  ,recid        OUT number
  ,stamp        OUT number);

PROCEDURE translateProxyCopyTag(
   tag          IN varchar2
  ,device_type  IN varchar2
  ,available    IN number           DEFAULT NULL   -- for compatability
  ,unavailable  IN number           DEFAULT NULL   -- for compatability
  ,deleted      IN number           DEFAULT NULL   -- for compatability
  ,statusMask   IN binary_integer   DEFAULT NULL); -- for compatability

-- translateProxyCopyKey translates a proxy copy key to a
-- recid and stamp in V$PROXY_DATAFILE/V$PROXY_ARCHIVEDLOG
-- translateProxyCopyHandle translates handle and device type to a
-- proxy copy recid and stamp.

-- getProxyCopy returns one proxy copy after calling translateProxyCopyTag.
-- keep calling getProxyCopy until recid is null.

-- The available and unavailable parameters are used to limit the
-- translation to backup pieces with the desired status.

-- Input parameters:
--    pc_key
--      key of the proxy copy record in the recovery catalog
--    handle
--      proxy copy handle
--    device type
--      device type on which the proxy copy resides
-- Output parameters:
--    recid
--      recid/stamp of the proxy copy record (in V$PROXY_DATAFILE or
--                                               V$PROXY_ARCHIVEDLOG)
-- Exceptions:
--   NO_RECOVERY_CATALOG (ORA-20300)
--     this operation is not supported without the recovery catalog
--   PROXY_COPY_DOES_NOT_EXIST
--     the key does not match any proxy copy
--   PROXY_COPY_HANDLE_IS_AMBIGUOUS
--     the key matches more than one proxy copy

-- Obsolete as of 8.1.6
PROCEDURE getProxyCopy(
   recid OUT number
  ,stamp OUT number
  ,handle OUT varchar2);

------------------------------
-- Backup Piece Translation --
------------------------------

PROCEDURE getBackupPiece(
   bpRec        OUT NOCOPY bpRec_t
  ,closeCursor  IN  boolean DEFAULT FALSE);

PROCEDURE translateBackupPieceKey(
   key         IN  number
  ,available   IN  number            DEFAULT TRUE#
  ,unavailable IN  number            DEFAULT TRUE#
  ,expired     IN  number            DEFAULT TRUE#
  ,statusMask  IN  binary_integer    DEFAULT NULL);   -- for compatability

PROCEDURE translateBackupPieceKey(                        -- only used in 8.1.6
   bp_key       IN  number
  ,available    IN  number
  ,unavailable  IN  number
  ,recid        OUT number
  ,stamp        OUT number
  ,handle       OUT varchar2
  ,set_stamp    OUT number
  ,set_count    OUT number
  ,piece#       OUT number);

PROCEDURE translateBackupPieceHandle(
   handle      IN  varchar2
  ,deviceType  IN  varchar2
  ,available   IN  number            DEFAULT NULL     -- for compatability
  ,unavailable IN  number            DEFAULT NULL     -- for compatability
  ,expired     IN  number            DEFAULT NULL     -- for compatability
  ,statusMask  IN  binary_integer    DEFAULT NULL);   -- for compatability

PROCEDURE translateBackupPieceHandle(                     -- only used in 8.1.6
   handle       IN  varchar2
  ,device_type  IN  varchar2
  ,available    IN  number
  ,unavailable  IN  number
  ,recid        OUT number
  ,stamp        OUT number
  ,set_stamp    OUT number
  ,set_count    OUT number
  ,piece#       OUT number);

PROCEDURE translateBackupPieceTag(
   tag          IN varchar2
  ,available    IN number             DEFAULT NULL     -- for compatability
  ,unavailable  IN number             DEFAULT NULL     -- for compatability
  ,statusMask   IN binary_integer     DEFAULT NULL);   -- for compatability

PROCEDURE translateBackupPieceBSKey(
   key          IN number
  ,tag          IN varchar2           DEFAULT NULL
  ,deviceType   IN varchar2           DEFAULT NULL
  ,pieceCount   IN number
  ,duplicates   IN number             DEFAULT TRUE#
  ,copyNumber   IN number             DEFAULT NULL
  ,available    IN number             DEFAULT TRUE#
  ,unavailable  IN number             DEFAULT FALSE#
  ,deleted      IN number             DEFAULT FALSE#
  ,expired      IN number             DEFAULT FALSE#
  ,statusMask   IN binary_integer     DEFAULT NULL);   -- for compatability

PROCEDURE translateBackupPieceBsKey(
   startBsKey   IN number
  ,tag          IN varchar2        DEFAULT NULL
  ,statusMask   IN binary_integer  DEFAULT NULL);
-- Translates all backupsets starting with specified backupset key, tag and
-- status. Used to fetch a list of backuppieces in one cursor.
   
PROCEDURE translateSeekBpBsKey(
   bsKey        IN number
  ,deviceType   IN varchar2
  ,pieceCount   IN number
  ,duplicates   IN number   DEFAULT TRUE#
  ,copyNumber   IN number   DEFAULT NULL);
-- Seek follows translateBackupPieceBsKey. It is used seek to a specified
-- backupset key, device, copyNumber. May return no_data_found if the
-- backupset key is not found or the cursor have passed over the
-- backupset key, device, copyNumber.
-- If this function doesn't return any error, then use getBackupPiece to
-- fetch all backuppieces until no_data_found.
-- Then seek again for a backupset key that is greater than previous.
-- The seek is expected to succeed always if the feeded backupset key is
-- in ascending order.

PROCEDURE translateBpBsKeyCancel;
-- End the translation once you are done with fetching pieces of all
-- backupsets. This will close the cursor and reset the package translation
-- variables.

-- Obsolete as of 8.1.6
PROCEDURE translateBackupSetKey(
   bs_key          IN  number
  ,device_type     IN  varchar2
  ,available       IN  number
  ,unavailable     IN  number
  ,deleted         IN  number
  ,duplicates      IN  number
  ,backup_type     OUT varchar2
  ,recid           OUT number
  ,stamp           OUT number
  ,set_stamp       OUT number
  ,set_count       OUT number
  ,bslevel         OUT number
  ,completion_time OUT date);

-- Obsolete as of 8.1
PROCEDURE translateBackupSetKey(
   bs_key      IN  number
  ,device_type IN  varchar2
  ,available   IN  number
  ,unavailable IN  number
  ,deleted     IN  number
  ,duplicates  IN  number
  ,backup_type OUT varchar2
  ,recid       OUT number
  ,stamp       OUT number);

-- Obsolete as of 8.1.6
PROCEDURE translateBackupSetRecid(
   recid       IN  number
  ,stamp       IN  number
  ,device_type IN  varchar2
  ,bs_key      OUT number
  ,bslevel     OUT number
  ,completed   OUT date);

-- Obsolete as of 8.1
PROCEDURE translateBackupSetRecid(
   recid       IN  number
  ,stamp       IN  number
  ,device_type IN  varchar2);

-- translateBackupPieceBSKey translates the specified backup set into a list of
-- backup pieces.  If there are multiple available copies of a piece then
-- only the latest (with highest stamp) is returned.  If there is no available
-- copy of a piece then raise an exception.
-- 
-- Input parameters:
--    key      
--      key of the backup set record in the recovery catalog
--    recid
--      recid of the backup set record (in V$BACKUP_SET)
--    stamp    
--      stamp of the backup set record (in V$BACKUP_SET)
--    startBsKey
--      translate all backupsets with this key and above.
--    tag
--      translate backuppieces with this tag
--    statusMask
--      translate backuppieces with this status
--    deviceType
--      translate backuppieces that are resides on this device
-- Exceptions:
--   BACKUP_SET_MISSING
--     no backup set with the specified recid and stamp found
--   NO_RECOVERY_CATALOG (ORA-20300)
--     translation by bs_key is not supported without the recovery catalog

-- Obsolete as of 8.1.6
PROCEDURE getBackupPiece(
   recid      OUT number
  ,stamp      OUT number
  ,bpkey      OUT number
  ,set_stamp  OUT number
  ,set_count  OUT number
  ,piece#     OUT number
  ,copy#      OUT number
  ,status     OUT varchar2
  ,completion OUT date
  ,handle     OUT varchar2);

-- Obsolete as of 8.1
PROCEDURE getBackupPiece(
   recid      OUT number
  ,stamp      OUT number
  ,set_stamp  OUT number
  ,set_count  OUT number
  ,piece#     OUT number
  ,handle     OUT varchar2);

----------------------------
-- Backup Set Translation --
----------------------------

PROCEDURE translateBackupSetKey(
   key        IN  number
  ,bsRec      OUT NOCOPY bsRec_t);

PROCEDURE translateAllBackupSet(
   backupType            IN  binary_integer
  ,tag                   IN  varchar2
  ,statusMask            IN  binary_integer
  ,completedAfter        IN  date
  ,completedBefore       IN  date
  ,onlyrdf               IN  binary_integer DEFAULT 0);

PROCEDURE getAllBackupSet(
   rcvRec OUT NOCOPY rcvRec_t);

------------------------
-- Controlfile Backup --
------------------------

-- allCopies = TRUE fetches duplex ones
PROCEDURE findControlfileBackup(
   allCopies IN boolean default FALSE);

-- getControlfileBackup is not a public function, but needs to be here due
-- to bug 1269570.
FUNCTION getControlfileBackup(
   rcvRec     OUT NOCOPY rcvRec_t)
RETURN number;

-- getPrimaryDfName: return the name of a datafile as it appears on the primary
FUNCTION getPrimaryDfName(fno IN NUMBER) RETURN VARCHAR2;

-- findControlFileBackup finds the optimal copy or backup of the controlfile
-- based on the given criteria.
-- The optimal copy is the one with highest checkpoint SCN.  Returns one of:
-- SUCCESS, AVAILABLE, UNAVAILABLE.

-- This is for 8.0.4 thru 8.1.5 compatibility
FUNCTION findControlFileBackup(
   type         OUT number
  ,recid        OUT number
  ,stamp        OUT number
  ,fname        OUT varchar2
  ,device_type  OUT varchar2
  ,ckp_scn      OUT number)
RETURN number;

-- Obsolete as of 8.1.6 (8.1.5 uses this)
FUNCTION findControlFileBackup(
   type         OUT number
  ,recid        OUT number
  ,stamp        OUT number
  ,fname        OUT varchar2
  ,device_type  OUT varchar2
  ,ckp_scn      OUT number
  ,rlg_scn      OUT number
  ,blksize      OUT number)
RETURN number;

-------------------------
-- Archived Log Backup --
-------------------------

PROCEDURE findRangeArchivedLogBackup(
   minthread    IN number
  ,minsequence  IN number
  ,minlowSCN    IN number
  ,maxthread    IN number
  ,maxsequence  IN number
  ,maxlowSCN    IN number
  ,allCopies    IN boolean default FALSE);

-- findRangeArchivedLogBackup finds all the backup sets that are required to
-- restore the archivelog specified in the range.
-- getRangeArchivedLogBackup returns the record for the backup set. The
-- return value is one of:  SUCCESS, AVAILABLE, UNAVAILABLE for each of the
-- backup sets.
--
-- Input Parameter:
--    minthread#, maxthread#     - range of threads
--    minsequence#, maxsequence# - range of sequence#
--    minlowSCN, maxlowSCN       - range of lowSCN
--    allCopies                  - TRUE fetches duplex ones

-- Obsolete as of 11g
PROCEDURE findArchivedLogBackup(
   thread    IN number
  ,sequence  IN number
  ,lowSCN    IN number
  ,allCopies IN boolean default FALSE);

-- findArchivedLogBackup finds a backup set containing the given archived log.
-- getArchivedLogBackup returns the record for the backup set.  The return
-- value is one of:  SUCCESS, AVAILABLE, UNAVAILABLE.
--
-- Input Parameter:
--    thread#
--    sequence#
--    low_scn
--    allCopies - TRUE fetches duplex ones

-- Obsolete as of 11g
FUNCTION getArchivedLogBackup(
   rcvRec       OUT NOCOPY rcvRec_t)
RETURN binary_integer;

-- Obsolete as of 8.1.6
FUNCTION findArchivedLogBackup(
   thread#    IN  number
  ,sequence#  IN  number
  ,low_scn    IN  number
  ,type       OUT number
  ,recid      OUT number
  ,stamp      OUT number
  ,device_type OUT varchar2)
RETURN number;

-------------------
-- SPFILE Backup --
-------------------

-- allCopies = TRUE fetches duplex ones
-- redundancy determine the number of redundant copies to fetch.
-- rmanCmd = is the specific rman command
-- scn_warn = 1 if we must estimate the time, 0 otherwise
PROCEDURE findSpfileBackup(
   allCopies  IN boolean default FALSE
  ,redundancy IN number  default NULL
  ,rmanCmd    IN number  default unknownCmd_t);

PROCEDURE findSpfileBackup(
   allCopies  IN boolean default FALSE
  ,redundancy IN number  default NULL
  ,rmanCmd    IN number  default unknownCmd_t
  ,scn_warn  OUT number);

-- redundancy determine the number of redundant copies to fetch if
-- findSpfileBackup wasn't called earlier.
FUNCTION getSpfileBackup(
   rcvRec       OUT NOCOPY rcvRec_t
  ,redundancy   IN         number default NULL
  ,rmanCmd      IN         number default unknownCmd_t)
RETURN number;

---------------
-- List Copy --
---------------

PROCEDURE listTranslateControlfileCopy(
   tag             IN  varchar2
  ,completedAfter  IN  date
  ,completedBefore IN  date
  ,statusMask      IN  binary_integer   DEFAULT
                       BSavailable+BSunavailable+BSexpired
  ,liststby        IN  binary_integer   DEFAULT NULL -- default for 8.1
  ,file_pattern    IN varchar2       DEFAULT NULL);

PROCEDURE listGetControlfileCopy(
   rcvRec OUT NOCOPY rcvRec_t);

-- Obsolete as of 8.1.6
FUNCTION listGetControlfileCopy(
   bcfkey     OUT number
  ,ckpscn     OUT number
  ,ckptime    OUT date
  ,status     OUT varchar2
  ,completion OUT date
  ,fname      OUT varchar2)
RETURN number;

PROCEDURE listTranslateDataFileCopy(
   file#             IN number
  ,creation_change#  IN number
  ,tag               IN varchar2        DEFAULT NULL
  ,file_name_pattern IN varchar2        DEFAULT NULL
  ,completedAfter    IN date            DEFAULT NULL
  ,completedBefore   IN date            DEFAULT NULL
  ,statusMask        IN binary_integer  DEFAULT BSavailable+BSunavailable
                                                             -- default for 8.1
  ,pluginSCN         IN number          DEFAULT 0);

PROCEDURE listGetDataFileCopy(
   rcvRec OUT NOCOPY rcvRec_t);

-- Obsolete as of 8.1.6
FUNCTION listGetDataFileCopy(
   cdf_key            OUT number
  ,status             OUT varchar2
  ,fname              OUT varchar2
  ,completion_time    OUT date
  ,checkpoint_change# OUT number
  ,checkpoint_time    OUT date)
RETURN number;

PROCEDURE listTranslateArchivedLogCopy(
   thread#           IN number
  ,sequence#         IN number
  ,first_change#     IN number
  ,file_name_pattern IN varchar2        DEFAULT NULL
  ,completedAfter    IN date            DEFAULT NULL
  ,completedBefore   IN date            DEFAULT NULL
  ,statusMask        IN binary_integer  DEFAULT
                       BSavailable+BSunavailable+BSexpired  -- 8.0/8.1 defaults
  ,needstby          IN number          DEFAULT NULL);

PROCEDURE listGetArchivedLogCopy(
   rcvRec       OUT NOCOPY rcvRec_t);

-- Obsolete as of 8.1.6
FUNCTION listGetArchivedLogCopy(
   al_key          OUT number
  ,status          OUT varchar2
  ,fname           OUT varchar2
  ,completion_time OUT date)
RETURN number;

-----------------
-- List Backup --
-----------------

PROCEDURE listTranslateControlfileBackup(
   tag             IN  varchar2
  ,completedAfter  IN  date
  ,completedBefore IN  date
  ,statusMask      IN  binary_integer   DEFAULT
                      BSavailable+BSunavailable+BSexpired   -- 8.0/8.1 defaults
  ,autobackup      IN  binary_integer    DEFAULT BScfile_all
  ,liststby        IN  binary_integer    DEFAULT NULL);

PROCEDURE listGetControlfileBackup(
   rcvRec OUT NOCOPY rcvRec_t);

-- Obsolete as of 8.1.6
FUNCTION listGetControlfileBackup(
   bskey      OUT number,
   ckpscn     OUT number,
   ckptime    OUT date)
RETURN number;

PROCEDURE listTranslateSpfileBackup(
   completedAfter  IN  date
  ,completedBefore IN  date);

PROCEDURE listGetSpfileBackup(
   rcvRec OUT NOCOPY rcvRec_t);

PROCEDURE listTranslateDataFileBackup(
   file#             IN number
  ,creation_change#  IN number
  ,tag               IN varchar2        DEFAULT NULL
  ,completedAfter    IN date            DEFAULT NULL
  ,completedBefore   IN date            DEFAULT NULL
  ,statusMask        IN binary_integer  DEFAULT
                      BSavailable+BSunavailable+BSexpired   -- 8.0/8.1 defaults
  ,pluginSCN         IN number          DEFAULT 0);

PROCEDURE listGetDataFileBackup(
   rcvRec OUT NOCOPY rcvRec_t);

-- Obsolete as of 8.1.6
FUNCTION listGetDataFileBackup(
   bs_key             OUT number
  ,backup_type        OUT varchar2
  ,incremental_level  OUT number
  ,completion_time    OUT date
  ,checkpoint_change# OUT number
  ,checkpoint_time    OUT date)
RETURN number;

-- 8.1.5 LIST implementation
PROCEDURE translateBackupFile(
   bs_recid    IN  number
  ,bs_stamp    IN  number
  ,fno         IN  number
  ,bskey       OUT number
  ,inclevel    OUT number
  ,backup_type OUT varchar2
  ,completed   OUT date);

-- Used by 8.0 and 8.1.6, but not 8.1.5
PROCEDURE listTranslateArchivedLogBackup(
   thread#           IN number
  ,sequence#         IN number
  ,first_change#     IN number
  ,completedAfter    IN date           DEFAULT NULL
  ,completedBefore   IN date           DEFAULT NULL
  ,statusMask        IN binary_integer DEFAULT
                      BSavailable+BSunavailable+BSexpired); -- 8.0/8.1 defaults

PROCEDURE listGetArchivedLogBackup(
   rcvRec OUT NOCOPY rcvRec_t);

-- Obsolete as of 8.1
FUNCTION listGetArchivedLogBackup(
   bs_key          OUT number
  ,completion_time OUT date)
RETURN number;

-- Obsolete as of 8.1.6, but used in 9.0
PROCEDURE listTranslateArchivedLogBackup(
   thread#      IN number   DEFAULT NULL
  ,lowseq       IN number   DEFAULT NULL
  ,highseq      IN number   DEFAULT NULL
  ,lowscn       IN number   DEFAULT NULL
  ,highscn      IN number   DEFAULT NULL
  ,from_time    IN date     DEFAULT NULL
  ,until_time   IN date     DEFAULT NULL
  ,pattern      IN varchar2 DEFAULT NULL);

-- Obsolete as of 8.1.6
FUNCTION listGetArchivedLogBackup(
   bs_key          OUT number
  ,thread#         OUT number
  ,sequence#       OUT number
  ,first_change#   OUT number
  ,next_change#    OUT number
  ,first_time      OUT date
  ,next_time       OUT date)
RETURN number;

--------------------
-- List Backupset --
--------------------

PROCEDURE listTranslateBackupsetFiles(
   bs_key          IN  number);

PROCEDURE listGetBackupsetFiles(
   rcvRec          OUT NOCOPY rcvRec_t);

---------------------
-- List Proxy Copy --
---------------------

-- Note that this is used for both datafiles and the controlfile
PROCEDURE listTranslateProxyDataFile(
   file#             IN number
  ,creation_change#  IN number
  ,tag               IN varchar2        DEFAULT NULL
  ,handle_pattern    IN varchar2        DEFAULT NULL
  ,completedAfter    IN date            DEFAULT NULL
  ,completedBefore   IN date            DEFAULT NULL 
  ,statusMask        IN binary_integer  DEFAULT
                       BSavailable+BSunavailable+BSexpired
  ,liststby          IN binary_integer  DEFAULT NULL -- default for 8.1
  ,pluginSCN         IN number          DEFAULT 0);

PROCEDURE listGetProxyDataFile(
   rcvRec OUT NOCOPY rcvRec_t);

-- Obsolete as of 8.1.6
FUNCTION listGetProxyDataFile(
   xdf_key            OUT number
  ,recid              OUT number
  ,stamp              OUT number
  ,status             OUT varchar2
  ,handle             OUT varchar2
  ,completion_time    OUT date
  ,checkpoint_change# OUT number
  ,checkpoint_time    OUT date)
RETURN number;

-- This procedure serves absolutely no purpose.  It is here only for
-- backwards compatbility with 8.1.5.  The only call to this is from
-- krmkafs(), which gets called from krmkgra().  Since the calls are always
-- in sequence, we can simply save the last record returned from
-- getRecoveryAction and avoid doing an extra query.
-- The only value this functions returns that krmkgra() didn't already have
-- in 8.1.5 is the xdf_key.  Completion time was being estimated from the
-- stamp.
PROCEDURE listTranslateProxyDFRecid(
   recid              IN number
  ,stamp              IN number
  ,xdf_key            OUT number
  ,file#              OUT number
  ,status             OUT varchar2
  ,handle             OUT varchar2
  ,completion_time    OUT date
  ,checkpoint_change# OUT number
  ,checkpoint_time    OUT date);

PROCEDURE listTranslateProxyArchivedLog(
   thread#           IN number
  ,sequence#         IN number
  ,first_change#     IN number
  ,tag               IN varchar2        DEFAULT NULL
  ,handle_pattern    IN varchar2        DEFAULT NULL
  ,completedAfter    IN date            DEFAULT NULL
  ,completedBefore   IN date            DEFAULT NULL
  ,statusMask        IN binary_integer  DEFAULT
                                        BSavailable+BSunavailable+BSexpired);

PROCEDURE listGetProxyArchivedLog(
   rcvRec OUT NOCOPY rcvRec_t);

-------------------------------
-- List Database Incarnation --
-------------------------------

PROCEDURE listTranslateDBIncarnation(
   db_name       IN varchar2 DEFAULT NULL,
   all_databases IN number  DEFAULT 0);

FUNCTION listGetDBIncarnation(
   db_key            OUT number
  ,dbinc_key         OUT number
  ,db_name           OUT varchar2
  ,db_id             OUT number
  ,current_inc       OUT varchar2
  ,resetlogs_change# OUT number
  ,resetlogs_time    OUT date
  ,dbinc_status      OUT varchar2)
RETURN number;

FUNCTION listGetDBIncarnation(
   db_key            OUT number
  ,dbinc_key         OUT number
  ,db_name           OUT varchar2
  ,db_id             OUT number
  ,current_inc       OUT varchar2
  ,resetlogs_change# OUT number
  ,resetlogs_time    OUT date)
RETURN number;

-------------------------------
-- List Database Sites --
-------------------------------

PROCEDURE listTranslateDBSite(
   db_name      IN varchar2 DEFAULT NULL,
   alldbs       IN binary_integer DEFAULT 1);

FUNCTION listGetDBSite(
   db_key            OUT number
  ,db_id             OUT number
  ,db_name           OUT varchar2
  ,db_role           OUT varchar2
  ,db_unique_name    OUT varchar2)
RETURN number;

--------------------------------------
-- List Rollback Segment Tablespace --
--------------------------------------

PROCEDURE listRollbackSegTableSpace;

FUNCTION listGetTableSpace(
   ts#               OUT number
  ,ts_name           OUT varchar2)
RETURN number;

------------------------
-- Incremental Backup --
------------------------

-- getIncrementalScn returns the starting scn for an incremental backup.
-- Input Parameters:
--   file#
--     datafile number
--   reset_scn
--     the resetlogs SCN of the datafile
--   reset_time
--     the resetlogs time of the datafile
--   incr_scn
--     level of the incremental backup
--   cumulative
--      TRUE# if the backup is cumulative
--   first
--      TRUE open the cursor, otherwise just fetch from already opened cursor
--   sourcemask
--      the source on which this incremental is based on
--   tag
--      the source tag on which this incremental is based on

-- Exceptions
--   DATAFILE_DOES_NOT_EXIST
--   INVALID_LEVEL
--   NO_PARENT_BACKUP_FOUND

FUNCTION getIncrementalScn(
   file#        IN number
  ,create_scn   IN number
  ,reset_scn    IN number
  ,reset_time   IN date
  ,incr_level   IN number
  ,cumulative   IN number
  ,sourcemask   IN number   DEFAULT NULL 
  ,tag          IN varchar2 DEFAULT NULL
  ,pluginSCN    IN number   DEFAULT 0)
RETURN number;

-- This one is an improved version of above. If you want to get
-- incremental scn for all datafiles by opening the cursor only once, then
-- using this will give enormous performance improvement.
--
-- NOTE!! NOTE!! NOTE!!
-- If you pass NULL to file# then it means all of the following
--  o all datafiles
--  o datafiles which has reset_scn and reset_time of current incarnation.
-- It is the callers responsibility to fetch the incremental scn of remaining
-- datafiles which doesn't have reset_scn and reset_time of current
-- incarnation.

PROCEDURE getIncrementalScn(
   first        IN  boolean                  -- open the cursor if this is TRUE
  ,file#        IN  number
  ,create_scn   IN  number
  ,reset_scn    IN  number
  ,reset_time   IN  date
  ,incr_level   IN  number
  ,cumulative   IN  number
  ,rcvRec       OUT NOCOPY rcvRec_t
  ,sourcemask   IN  number    DEFAULT NULL
  ,tag          IN  varchar2  DEFAULT NULL 
  ,pluginSCN    IN  number    DEFAULT 0
  ,keep         IN  boolean   DEFAULT NULL);


--------------------
-- Offline Ranges --
--------------------

PROCEDURE findOfflineRangeCopy(
   offr_recid   IN number
  ,offr_ckpscn  IN number
  ,cf_cretime   IN date
  ,dbinc_key    IN number);

PROCEDURE getOfflineRangeCopy(
   rcvRec       OUT  NOCOPY rcvRec_t);

-- Obsolete as of 8.1.6
FUNCTION getOfflineRangeCopy
RETURN varchar2;

-- findOfflineRangeCopy begins the search for a controlfile copy
-- containing a specified offline range.  getOfflinRangeCopy is called
-- to retrieve the controlfile names one by one.  NULL is returned at
-- end of fetch.

-- Input Parameters:
--   offr_recid
--     recid of offline range
--   offr_ckpscn
--     online checkpoint SCN (end) of offline range
--   dbinc_rlgscn
--     resetlogs SCN of the db incarnation that contains this range
-- Output Parameters:
--   offr_recid
--     recid of the offline range record
--   offr_stamp
--     stamp of the offline range record
--   type
--     type of the controlfile that contains the offline range.
--     COPY or BACKUP
--   recid
--     the recid of datafile copy record or
--     the recid of the backup set record
--   stamp
--     The timestamp associated with the recid in the controlfile.
--   fname
--     filename of the controlfile copy
--     NULL if a backup controlfile is returned

-- returns TRUE (1) if a copy or backup was found
-- returns FALSE (0) if no copy or backup was found

-- Exceptions:
--   OFFLINE_RANGE_NOT_FOUND (ORA-20250)
--     No offline range was found for the datafile starting at the offline SCN

---------------------------------------
-- Recovery Functions and Procedures --
---------------------------------------

PROCEDURE setComputeRecoveryActionMasks(
   containerMask        IN number
  ,actionMask           IN number
  ,allRecords           IN number
  ,availableMask        IN binary_integer
  ,fullBackups          IN number DEFAULT NULL);
-- Input parameters:
--   fullBackups
--     Stop when these many full backups are fetched. Dependency on
--     allRecords value is as follows:
--     1. When allRecords = FALSE# and fullBackups = NULL, we stop when
--        one full backup is fetched.
--     2. When allRecords = FALSE# and fullBackups = N, we stop when
--        N full backups are fetched.
--     3. When allRecords = TRUE# and fullBackups = NULL, we get all
--        records.
--     4. When allRecords = TRUE# and fullBackups = N, we stack N
--        full backups and all non-full backup records.
--

--Obsolete as of 8.1.7
PROCEDURE setComputeRecoveryActionMasks(
   containerMask        IN number
  ,actionMask           IN number
  ,allRecords           IN number);

-- Obsolete as of 8.1.6
PROCEDURE setRAflags(
   kindMask    IN number
  ,allRecords  IN boolean);

FUNCTION computeRecoveryActions(
fno        IN number,   -- Datafile number.
crescn     IN number,   -- Datafile creation SCN.
df_rlgscn  IN number    -- Datafile resetlogs SCN.  Null if this is a RESTORE
   default null,        -- command, else this is the value in the datafile
                        -- header for the datafile we are RECOVERing.
df_rlgtime IN date      -- Datafile resetlogs time.  Null if df_rlgscn is
   default null,        -- null, else value from datafile header.
df_ckpscn  IN number    -- Datafile checkpoint SCN.  Null if df_rlgscn is
   default null,        -- null, else value from datafile header.
offlscn    IN number    -- kccfeofs (may be null).
   default 0,
onlscn     IN number    -- kccfeonc (null if offlscn is null).
   default 0,
onltime    IN date      -- kccfeonc_time
   default null,
cleanscn   IN number    -- kccfecps if either SOR or WCC set, else null.
   default 0,
clean2scn  IN number    -- CF ckpt SCN if WCC set, infinity if SOR bit set
   default 0,           -- else null.
clean2time IN date      -- cf ckpt time if WCC, SYSDATE if SOR
   default null,
allowfuzzy IN boolean   -- TRUE if can be fuzzy at until SCN/time, FALSE if
  default FALSE,        -- not.  default is FALSE.
partial_rcv IN boolean  -- TRUE if can do partial recovery, FALSE if not
  default FALSE,
cf_scn     IN number    -- controlfile checkpoint SCN (NULL if none mounted)
  default NULL,
cf_cretime IN date      -- controlfile creation time (NULL if none mounted)
  default NULL,
cf_offrrid IN number    -- recid of oldest offline range in controlfile
  default NULL,         -- (NULL if none mounted)
allCopies  IN boolean   -- if TRUE, then stack all valid copies of a bu set
  default FALSE,
df_cretime IN date      -- datafile creation time
  default NULL,
rmanCmd    IN binary_integer
  default unknownCmd_t,
foreignDbid   IN number
  default 0,
pluggedRonly  IN binary_integer
  default 0,
pluginSCN     IN number
  default 0,
pluginRlgSCN  IN number
  default 0,
pluginRlgTime IN date 
  default NULL,
creation_thread IN number
  default NULL,
creation_size   IN number
  default NULL
) return binary_integer;

-- Returns:
--   SUCCESS -> the file can be restored/recovered.
--   else one of RESTORABLE, AVAILABLE, UNAVAILABLE, NO_ACTION.

-- computeRecoveryActions return values --

SUCCESS     CONSTANT binary_integer := 0;
UNAVAILABLE CONSTANT binary_integer := 1;
AVAILABLE   CONSTANT binary_integer := 2;
RESTORABLE  CONSTANT binary_integer := 3;
NO_ACTION   CONSTANT binary_integer := 4;

-- SUCCESS:      A file has been found for RESTORE, or the file on disk
--               can be recovered.
-- UNAVAILABLE:  If RESTORE, then no datafilecopy or level 0 backup was found.
--               If RECOVER, then some incremental backup is missing, or the
--               datafile on disk is too old to recover.
-- AVAILABLE:    If RESTORE, then some level 0 or datafilecopy exists, but
--               the required device type is not allocated.
-- RESTORABLE:   This is returned only when doing a RECOVER.  It means that
--               the file on disk cannot be recovered, but there is some level
--               0 or datafilecopy that could be restored and then recovered.
-- NO_ACTION:    There are no incrementals or offline ranges to apply, but
--               the file should be recoverable with redo.  No guarantee is
--               made that the logs needed are actually available.

FUNCTION getRecoveryAction(
   action OUT NOCOPY rcvRec_t)
RETURN binary_integer;

-- Obsolete as of 8.1.6
FUNCTION getRecoveryAction(
   kind       OUT number
  ,set_stamp  OUT number
  ,set_count  OUT number
  ,recid      OUT number
  ,stamp      OUT number
  ,fname      OUT varchar2
  ,blocksize  OUT number
  ,blocks     OUT number
  ,devtype    OUT varchar2
  ,from_scn   OUT number
  ,to_scn     OUT number
  ,to_time    OUT date
  ,rlgscn     OUT number
  ,rlgtime    OUT date
  ,cfcretime  OUT date
  ,dbinc_key  OUT number)
RETURN binary_integer;

PROCEDURE printRecoveryActions;

PROCEDURE trimRecoveryActions(
   maxActions           IN number
  ,containerMask        IN number
  ,actionMask           IN number);

-- trimRecoveryActions will trim the stack down to the specified number
-- actions if it contains more.  This is used by report obsolete to implement
-- the redundancy count.  The reason for it is that getRecoveryActions
-- returns actions in LIFO order.  This means the oldest actions, which
-- were stacked most recently, are returned first.  However, report obsolete
-- wants to keep only the most recent backups when constructing the
-- "must keep" list.  We solve the problem by getting rid of any excess
-- actions first, and so the order in which getRecoveryActions returns them
-- won't matter.  Note that only actions whose type_con and type_act are
-- selected by the masks will be deleted.  Other actions are left on the
-- stack.

---------------------
-- Report Obsolete --
---------------------

PROCEDURE reportTranslateDFDel ;

-- pre 8.1.5 version
FUNCTION reportGetDFDel(
   file#               OUT number
  ,filetype            OUT number
  ,checkpoint_change#  OUT number
  ,checkpoint_time     OUT date
  ,resetlogs_change#   OUT number
  ,resetlogs_time      OUT date
  ,incremental_change# OUT number
  ,fuzzy_change#       OUT number
  ,recid               OUT number
  ,stamp               OUT number
  ,fname               OUT varchar2
  ,restorable          OUT number)
RETURN number;

-- 8.1.5+ version
FUNCTION reportGetDFDel(
   file#               OUT number
  ,filetype            OUT number
  ,checkpoint_change#  OUT number
  ,checkpoint_time     OUT date
  ,resetlogs_change#   OUT number
  ,resetlogs_time      OUT date
  ,incremental_change# OUT number
  ,fuzzy_change#       OUT number
  ,recid               OUT number
  ,stamp               OUT number
  ,fname               OUT varchar2
  ,restorable          OUT number
  ,key                 OUT number
  ,completion_time     OUT date)
RETURN number;

------------
-- TSPITR --
------------

FUNCTION getCloneName(
   fno    IN number
  ,crescn IN number
  ,pluscn IN number DEFAULT 0)
RETURN varchar2;


---------------
-- DUPLICATE --
---------------

FUNCTION wasFileOffline(
   fno    IN number
  ,untilscn IN number)
RETURN number;

-------------------------
-- RMAN Configuration ---
-------------------------

procedure getConfig(
   conf#          OUT    number
  ,name           IN OUT varchar2
  ,value          IN OUT varchar2
  ,first          IN     boolean);

------------------------------
-- Get max(copy#) --
------------------------------

FUNCTION getmaxcopyno(
   bsstamp         IN    number
  ,bscount         IN    number)
RETURN number;

--------------------------
-- Add Corruption Table --
--------------------------

PROCEDURE bmrAddCorruptTable(
   dfnumber    OUT number
  ,blknumber   OUT number
  ,range       OUT number
  ,first       IN  boolean);

------------------------
-- Get Backup History --
------------------------

PROCEDURE getDfBackupHistory(
   backedUpDev     IN   varchar2
  ,first           IN   boolean
  ,bhistoryRec     OUT  NOCOPY bhistoryRec_t
  ,recentbackup    IN   boolean DEFAULT FALSE  -- get no: recent backups
  ,doingCmd        IN   varchar2 DEFAULT NULL
  ,keepTag         IN   varchar2 DEFAULT NULL
  ,toDest1         IN   varchar2 DEFAULT NULL
  ,toDest2         IN   varchar2 DEFAULT NULL
  ,toDest3         IN   varchar2 DEFAULT NULL
  ,toDest4         IN   varchar2 DEFAULT NULL);

PROCEDURE getAlBackupHistory(
   backedUpDev     IN   varchar2
  ,first           IN   boolean
  ,bhistoryRec     OUT  NOCOPY bhistoryRec_t
  ,doingCmd        IN   varchar2 DEFAULT NULL
  ,keepTag         IN   varchar2 DEFAULT NULL
  ,toDest1         IN   varchar2 DEFAULT NULL
  ,toDest2         IN   varchar2 DEFAULT NULL
  ,toDest3         IN   varchar2 DEFAULT NULL
  ,toDest4         IN   varchar2 DEFAULT NULL);

PROCEDURE getBsBackupHistory(
   backedUpDev     IN   varchar2
  ,first           IN   boolean
  ,set_stamp       IN   number DEFAULT NULL
  ,set_count       IN   number DEFAULT NULL
  ,bhistoryRec     OUT  NOCOPY bhistoryRec_t
  ,doingCmd        IN   varchar2 DEFAULT NULL
  ,keepTag         IN   varchar2 DEFAULT NULL
  ,toDest1         IN   varchar2 DEFAULT NULL
  ,toDest2         IN   varchar2 DEFAULT NULL
  ,toDest3         IN   varchar2 DEFAULT NULL
  ,toDest4         IN   varchar2 DEFAULT NULL);

PROCEDURE getDcBackupHistory(
   backedUpDev     IN   varchar2
  ,first           IN   boolean
  ,bhistoryRec     OUT  NOCOPY bhistoryRec_t
  ,doingCmd        IN   varchar2 DEFAULT NULL
  ,keepTag         IN   varchar2 DEFAULT NULL
  ,toDest1         IN   varchar2 DEFAULT NULL
  ,toDest2         IN   varchar2 DEFAULT NULL
  ,toDest3         IN   varchar2 DEFAULT NULL
  ,toDest4         IN   varchar2 DEFAULT NULL);

-- Obsolute as of 9.2.0.1
PROCEDURE getBackupHistory(
   dfRec            IN  dfRec_t
  ,backedUpDev      IN  varchar2
  ,nbackupsFlag     IN  number
  ,bscompletionFlag IN  number
  ,nbackups         OUT number
  ,bscompletion     OUT date);

-- Obsolute as of 9.2.0.1
PROCEDURE getBackupHistory(
   alRec            IN  alRec_t
  ,backedUpDev      IN  varchar2
  ,nbackupsFlag     IN  number
  ,bscompletionFlag IN  number
  ,nbackups         OUT number
  ,bscompletion     OUT date);

PROCEDURE getBackupHistory(
   bpRec            IN  bpRec_t
  ,backedUpDev      IN  varchar2
  ,nbackupsFlag     IN  number
  ,bscompletionFlag IN  number
  ,nbackups         OUT number
  ,bscompletion     OUT date
  ,toDest1          IN  varchar2 DEFAULT NULL
  ,toDest2          IN  varchar2 DEFAULT NULL
  ,toDest3          IN  varchar2 DEFAULT NULL
  ,toDest4          IN  varchar2 DEFAULT NULL);

------------------
-- Version Info --
------------------

FUNCTION getPackageVersion
RETURN varchar2;

------------------
-- Simple Calls --
------------------
FUNCTION isStatusMatch(status      IN VARCHAR2,
                       mask        IN NUMBER) RETURN NUMBER;
FUNCTION isDeviceTypeAllocated(deviceType IN varchar2)
                      RETURN NUMBER;
FUNCTION isBackupTypeMatch(btype       IN VARCHAR2,
                           mask        IN binary_integer)
                                              RETURN NUMBER;
------------------------------
-- set rcvRecBackupAge value --
-------------------------------
PROCEDURE setRcvRecBackupAge(age IN number);

------------------------------
-- reset thisBackupAge value --
-------------------------------
PROCEDURE resetthisBackupAge;

-------------------------------------
-- List (Obsolete) Backup Function --
-------------------------------------

PROCEDURE getRetentionPolicy(recovery_window OUT number
                            ,redundancy      OUT number);
--
-- The function getRetentionPolicy is used to get currently configured
-- retention policy.
--

FUNCTION listBackup(lbRecOut         OUT     NOCOPY lbRec_t
                   ,firstCall        IN      boolean
                   ,only_obsolete    IN      boolean
                   ,redundancy       IN      number
                   ,piped_call       IN      boolean
                   ,lbCursor         IN  OUT NOCOPY lbCursor_t
                   ,lbState          IN  OUT NOCOPY lbState_t
                   ,extRlKeepSCN     IN      number DEFAULT NULL)
  RETURN boolean;

--
-- The function listBackup lists (obsolete) backups (backup sets, pieces,
-- copies, proxy copies, and archived logs). 
-- 
-- The parameter firstCall must be TRUE on the very first call of the function.
-- The return of the function is stored in lbRecOut. However the function can
-- return without putting data in lbRecOut, so the caller should always check
-- whether lbRecOut is NULL.
-- If the exit code of the function is FALSE, then it means that all there
-- no more data to be returned. 
--
-- piped_call   - If FALSE, you must pass dbms_rcvman.lbStatePck as lbState.
-- extRlKeepSCN - When passed a non-null value, the algorithm ensure to
--                keep all archivelogs at and above this scn.

PROCEDURE setNeedObsoleteData(NeedObsoleteData IN boolean DEFAULT TRUE);
-- The function is an optimization fix to not to call computeRecoveryAction if
-- client is not interested in obsolete column value.

----------------------------- getCopyofDatafile -------------------------------

-- This function obtains the latest AVAILABLE datafilecopy for all translated
-- datafiles (and possibly the datafilecopies having a specific tag).
PROCEDURE getCopyofDatafile(
   first          IN      boolean     -- TRUE if this is the first time called
  ,itag           IN      varchar2    -- tag that the copy should have or NULL
  ,fno            OUT     number      -- datafile number
  ,crescn         OUT     number      -- creation scn of the datafile
  ,rlogscn        OUT     number      -- resetlogs scn of the datafile
  ,rlgtime        OUT     date        -- resetlogs time of the datafile
  ,recid          OUT     binary_integer -- recid of the latest datafilecopy
  ,stamp          OUT     binary_integer -- stamp of the latest datafilecopy
  ,name           OUT     varchar2    -- name of the datafilecopy
  ,otag           OUT     varchar2    -- tag of the datafilecopy
  ,status         OUT     varchar2    -- status of the datafilecopy
  ,nblocks        OUT     binary_integer -- number of blocks of datafilecopy
  ,bsz            OUT     binary_integer -- blocksize of the datafilecopy
  ,ctime          OUT     date        -- creation time of the datafilecopy
  ,toscn          OUT     number      -- checkpoint scn of the datafilecopy
  ,totime         OUT     date        -- checkpoint time of the datafilecopy
  ,pluggedRonly   OUT     binary_integer -- 1 for read-only. Otherwise, 0
  ,pluginSCN      OUT     number      -- plugin scn
  ,pluginRlgSCN   OUT     number      -- resetlogs when datafile was plugged
  ,pluginRlgTime  OUT     date);      -- resetlog time when df was plugged

-- This function obtains the latest AVAILABLE datafilecopy for a given 
-- datafile number (and possibly the datafilecopy having a specific tag).
-- It returns all the information identifying the datafilecopy.
-- Obsolete as of 11.2.0.3

PROCEDURE getCopyofDatafile(
   dfnumber       IN      number      -- datafile number
  ,itag           IN      varchar2    -- tag that the copy should have or NULL
  ,crescn         IN  OUT number      -- creation scn of the datafile
  ,rlogscn        IN  OUT number      -- resetlogs scn of the datafile
  ,rlgtime        IN  OUT date        -- resetlogs time of the datafile
  ,recid          OUT     binary_integer -- recid of the latest datafilecopy
  ,stamp          OUT     binary_integer -- stamp of the latest datafilecopy
  ,name           OUT     varchar2    -- name of the datafilecopy
  ,otag           OUT     varchar2    -- tag of the datafilecopy
  ,status         OUT     varchar2    -- status of the datafilecopy
  ,nblocks        OUT     binary_integer -- number of blocks of datafilecopy
  ,bsz            OUT     binary_integer -- blocksize of the datafilecopy
  ,ctime          OUT     date        -- creation time of the datafilecopy
  ,toscn          OUT     number      -- checkpoint scn of the datafilecopy
  ,totime         OUT     date        -- checkpoint time of the datafilecopy
  ,pluggedRonly   OUT     binary_integer -- 1 for read-only. Otherwise, 0
  ,pluginSCN      IN      number);    -- plugin scn

-- This function obtains the latest AVAILABLE datafilecopy for a given 
-- datafile number (and possibly the datafilecopy having a specific tag).
-- It returns all the information identifying the datafilecopy.
-- Obsolete as of 11g

PROCEDURE getCopyofDatafile(
   dfnumber    IN  number          -- datafile number
  ,itag        IN  varchar2        -- tag that the copy should have or NULL
  ,crescn      IN  number          -- creation scn of the datafile
  ,rlogscn     IN  number          -- resetlogs scn of the datafile
  ,rlgtime     IN  date            -- resetlogs time of the datafile
  ,recid       OUT binary_integer  -- recid of the latest datafilecopy
  ,stamp       OUT binary_integer  -- stamp of the latest datafilecopy
  ,name        OUT varchar2        -- name of the datafilecopy
  ,otag        OUT varchar2        -- tag of the datafilecopy
  ,status      OUT varchar2        -- status of the datafilecopy
  ,nblocks     OUT binary_integer  -- number of blocks of the datafilecopy
  ,bsz         OUT binary_integer  -- blocksize of the datafilecopy
  ,ctime       OUT date            -- creation time of the datafilecopy
  ,toscn       OUT number          -- checkpoint scn of the datafilecopy
  ,totime      OUT date);          -- checkpoint time of the datafilecopy

---------------
-- Aged File --
---------------
PROCEDURE getdropOSFiles(
   first         IN  boolean
  ,agedFileRec   OUT NOCOPY agedFileRec_t);

PROCEDURE getBackedUpFiles(
   first         IN  boolean
  ,agedFileRec   OUT NOCOPY agedFileRec_t);

-- getRedoLogDeletion Policy --
-- Returns the policyType string as 'TO NONE' or 'TO APPLIED ON STANDBY' --
PROCEDURE getRedoLogDeletionPolicy(
   policy        OUT varchar2);

-- setRedoLogDeletion Policy --
-- Initialize global variables
-- a) policyType to 'TO NONE' or 'TO APPLIED ON STANDBY' 
-- b) policyBind to 'MANDATORY' or 'NULL'
-- c) policyTarget to 'NULL', 'STANDBY' or 'REMOTE'
-- 
-- If standbyConfig validation failed to enfore the specified policyType,
-- then we fallback to 'NONE' policy.
--
-- Input parameters:
--  policy  - 'TO NONE' or 'TO APPLIED ON STANDBY' 
--  alldest - TRUE indicates the policyType is enforced on all destinations.
--            Otherwise, only MANDATORY destination is honored. 
-- 
PROCEDURE setRedoLogDeletionPolicy(
   policy  IN  varchar2
  ,alldest IN  number);

-- For a specified policyType, validate the standby configuration.
-- Basically, it checks if there is atleast one destination on which the
-- APPLIED policy can be enforced. Returns TRUE on success. Otherwise,
-- FALSE.
--
FUNCTION validateStandbyConfig(
   policy  IN  varchar2
  ,alldest IN  number)
RETURN NUMBER;

-- getSCNForAppliedPolicy--
-- Must be called after setRedoLogDeletionPolicy call.
-- The function is intended to compute the SCN
-- above which all archivelogs are kept for TO APPLIED|SHIPPED policy.
--
-- Output Parameters:
--    minscn  - minimum scn that is applied on all standby and 
--              guaranteed restore point
--    rlgscn  - resetlogs scn corresponding to minscn
--
PROCEDURE getSCNForAppliedPolicy(
   minscn    OUT  number
  ,rlgscn    OUT  number);

-- getAppliedAl --
-- Return archivelogs records that has been applied on all destinations
-- specified by validateStandbyConfig TARGET string and redoLogDeletionPolicy.
-- 
-- Input parameters:
--    first        - Pass it TRUE when you are calling for first time.
--    agedFileRec  - Archivelog record that can be deleted.
--
PROCEDURE getAppliedAl(
   first         IN  boolean
  ,agedFileRec   OUT NOCOPY agedFileRec_t);

-- getRequiredSCN --
-- Calculate the lowest gap for all destinations.  Calculate the highest
-- scn available on all valid standby destinations.  If no gap, return the
-- high scn, otherwise return the gap. If streams is true consider streams
-- also when computing remote destination required SCN.
PROCEDURE getRequiredSCN(
   reqscn   OUT  number
  ,rlgscn   OUT  number
  ,streams  IN   number DEFAULT 0
  ,alldest  IN   number DEFAULT 0);

-- getAppliedSCN --
-- returns the SCN till where the logs are applied at physical standby database
PROCEDURE getAppliedSCN(
   appscn   OUT  number
  ,rlgscn   OUT  number
  ,alldest  IN   number);

-- Is this file translated by RMAN?
-- Returns TRUE# if translated. Otherwise, FALSE#
FUNCTION isTranslatedFno(fno IN number) RETURN NUMBER;

-- Is this a match in cacheBsRec Table?.
-- Returns TRUE# if hit. Otherwise, FALSE#
FUNCTION isBsRecCacheMatch(
   key         IN   number
  ,deviceType  IN   varchar2
  ,tag         IN   varchar2
  ,status      IN   varchar2)
RETURN NUMBER;

-- Reset reclaimable record.
PROCEDURE resetReclRecid;

-- Set Reclaimable record.
PROCEDURE setReclRecid(
   rectype  IN  binary_integer
  ,recid    IN  number);

-- Is this record reclaimable?
-- Returns TRUE# if so. Otherwise, FALSE#.
FUNCTION IsReclRecid(
   rectype  IN  binary_integer
  ,recid    IN  number)
RETURN NUMBER;

-- Return space reclaimable in bytes for files in reclaimable record table 
-- ceilAsm - when TRUE, ceil ASM file size in MB
FUNCTION getSpaceRecl(ceilAsm IN binary_integer default 0) RETURN NUMBER;

-- Given a name return information about the restore point.
PROCEDURE getRestorePoint(
   name         IN varchar2
  ,rlgscn       OUT number
  ,rlgtime      OUT date
  ,scn          OUT number
  ,guaranteed   OUT number);

-- Prep for LIST RESTORE POINT [name/null]
PROCEDURE listTranslateRestorePoint(
   name       IN  varchar2);

-- Fetch for LIST RESTORE POINT [name/null]
PROCEDURE listGetRestorePoint(
   name         OUT varchar2
  ,scn          OUT number
  ,rsptime      OUT date
  ,cretime      OUT date
  ,rsptype      OUT varchar2);

-- Convert input number to displayable canonical format. The number is
-- converted to nearest M (mega bytes)/ G (giga bytes)/ T (tera bytes)
-- /P (peta bytes).
FUNCTION Num2DisplaySize(input_size IN NUMBER) return VARCHAR2;

-- Convert input seconds to displayable canonical format [HH:MM:SI]
FUNCTION Sec2DisplayTime(input_secs IN NUMBER) return VARCHAR2;

FUNCTION getEncryptTSCount RETURN BINARY_INTEGER;

-- Hint to indicate the archivelog that is interested. Later,
-- isTranslatedArchivedLog can be called to verify the presence. It doesn't
-- take resetlogs information in order to keep it simple. It is responsible
-- for the client to validate further by comparing resetlogs information. 
PROCEDURE setArchivedLogRecord(
   thread#   IN  number
  ,sequence# IN  number
  ,first     IN  boolean);

-- To indicate that the database can handle backup transportable tablespace.
-- Hence, RMAN client should make the plugged readonly files visible for
-- translation.
PROCEDURE setCanHandleTransportableTbs(
   flag IN boolean);

-- Return the maximum next SCN to which the database can be recovered using
-- archived logs.
FUNCTION getArchivedNextSCN RETURN NUMBER;

-- Check if there a log is missing between fromscn to untilscn. Return TRUE
-- if a log is missing. Otherwise, FALSE.
FUNCTION isArchivedLogMissing(fromSCN IN NUMBER, untilSCN IN NUMBER)
  RETURN NUMBER;

-- Return the incarnation key to which the untilscn belongs if the untilscn
-- is in one of its parent. 0 to indicate if the untilscn is in current
-- incarnation.
FUNCTION getIncarnationKey(untilSCN IN NUMBER) RETURN NUMBER;

-- Hint to indicate the dbid that is interested. Later, isTranslatedDbid can
-- be called to verify the presence.
PROCEDURE setDbidTransClause(dbid IN number);

-- Is this dbid translated by RMAN?
-- Returns TRUE# if translated. Otherwise, FALSE#
FUNCTION isTranslatedDbid(dbid IN number) RETURN NUMBER;


-- Obtain maximum scn from archived logs registered in the catalog
-- Obsolete in 11.2
FUNCTION getMaxScn RETURN number;

FUNCTION getMaxScn(logmaxnt OUT date) RETURN NUMBER;

FUNCTION getActualDbinc RETURN number;

-- Returns the key of the incarnation that a previous set until 
-- performed with allIncarnations = TRUE# ended up using when 
-- the current incarnation was not selected.  This is a recovery catalog
-- only function.
-- At the time of introduction of this function, it is only used by
-- targetless duplicate.


-----------------------------------
-- Intelligent Repair Procedures --
-----------------------------------

----------------------------- isInFailureList ---------------------------------
--
-- isInFailureList is called to find out whether the parent_id or failureid
-- is part of getFailureNumList or getFailureExclude list.
-- Return TRUE# if present in failure_list.  Otherwise, return FALSE#.
--
-- Input parameters:
--    parent_id   : parent id in question
--    failureid   : failure id in question
--    for_exclude : > 0 if to look up getFailureExclude. Otherwise, 0
--                  to look up getFailureNumList.
--                
FUNCTION isInFailureList(
   parentId     IN number
  ,failureId    IN number
  ,for_exclude  IN binary_integer
  )
RETURN NUMBER;
 
----------------------------- createFailureList -------------------------------
--
-- createFailureList is called to initialize a failure list in dbms_rcvman
-- package.
--
-- Input parameters:
--    first_call  : Pass it as TRUE if this is first entry in the list
--    failureId   : The failure id to be added to the list
--    for_exclude : FALSE to initialize getFailureNumList and TRUE to
--                  initialize getFailureExclude list.
--                  
PROCEDURE createFailureList(
   first_call   IN boolean
  ,failureId    IN number
  ,for_exclude  IN boolean);

------------------------------ translateFailure -------------------------------
--
-- translateFailure is called to open the cursor in order to retrieve the list
-- of failures (using getFailure) from ADR. createFailureList may be
-- called before this function to initialize getFailureNumList and
-- getFailureExclude list which is used to filter the output that corresponds
-- to FAILNUM or EXCLUDE FAILNUM option in the grammar.
-- 
-- Input Parameters:
--    critical   :  > 0 if priority is critical or ALL. Otherwise, 0.
--    high       :  > 0 if priroity is high or ALL. Otherwise, 0.
--    low        :  > 0 if priority is low or ALL. Otherwise, 0.
--    closed     :  > 0 if to list closed failures. Otherwise, 0.
--    adviseId   :  If non-null adviseid is passed, then other parameters
--                  are ignored because adviseid the grammar doesn't
--                  allow adviseid with other options.
--
PROCEDURE translateFailure(
   critical        IN  binary_integer
  ,high            IN  binary_integer
  ,low             IN  binary_integer
  ,closed          IN  binary_integer
  ,adviseId        IN  number);

--------------------------------- getFailure ----------------------------------
--
-- getFailure is called to retrieve the failure list whose cursor is opened
-- by translateFailure procedure. Until it returns no-data-found exception,
-- this function is called again and again to retrieve all the failures.
--
-- Output Parameters:
--    failureRec   : failure record that describes the failure.
--
PROCEDURE getFailure(
   failureRec      OUT NOCOPY failureRec_t);

------------------------------ translateRepair --------------------------------
--
-- translateRepair is called to open the cursor in order to retrieve the list
-- of repairs (using getRepair).
--
-- Input Parameters:
--    adviseId   :  available repairs that corresponds to this advise id.
--
PROCEDURE translateRepair(
   adviseid        IN  number);

----------------------------------- getRepair ---------------------------------
--
-- getRepair is called to retrieve the repair list whose cursor is opened
-- by translateRepair procedure. Until it returns no-data-found exception,
-- this function is called again and again to retrieve all the options.
--
-- Output Parameters:
--    repairRec: repair record that describes the repair.
--
PROCEDURE getRepair(
   repairRec OUT NOCOPY repairRec_t);

-------------------------- translateRepairParms -------------------------------
--
-- translateRepairParms is called to open the cursor in order to retrieve
-- the list of repair parameters(using getRepairParms).
--
-- Input Parameters:
--    adviseId   :  available repairs that corresponds to this advise id.
-- 
PROCEDURE translateRepairParms(
   adviseid        IN  number);

--------------------------------- getRepairParms -----------------------------
-- 
-- getRepairParms is called to retrieve the repair parameters whose cursor
-- is opened by translateRepairParms procedure. Until it returns no-data-found
-- exception, this function is called again and again to retrieve all
-- the repair parameters.
--
-- Output Parameters:
--    repairRecParams: repair record that describes the repair.
-- 
PROCEDURE getRepairParms(
   repairParmsRec OUT NOCOPY repairParmsRec_t);

---------------------------- translateRepairOption --------------------------
--
-- translateRepairOption is called to open the cursor in order to retrieve
-- the list of repair option (using getRepairOption).
--
-- Input Parameters:
--    adviseId   :  available repair option that corresponds to this advise id.
--
PROCEDURE translateRepairOption(
   adviseid        IN  number);

------------------------------- getRepairOption -------------------------------
--
-- getRepairOption is called to retrieve the repair option list whose cursor
-- is opened by translateRepairOption procedure. Until it returns 
-- no-data-found exception, this function is called again and again to
-- retrieve all the options.
--
-- Output Parameters:
--    repairOptionRec: repair option record that describes the option.
--
PROCEDURE getRepairOption(
   repairOptionRec OUT NOCOPY repairOptionRec_t);

----------------------------- translateRepairStep ----------------------------
--
-- translateRepairStep is called to open the cursor in order to retrieve the
-- list of repair step (using getRepairStep).
--
-- Input Parameters:
--    optionidx:  available repair step that corresponds to this option idx.
--
PROCEDURE translateRepairStep(
   optionidx       IN  number); 

-------------------------------- getRepairStep --------------------------------
--
-- getRepairStep is called to retrieve the repair steps whose cursor 
-- is opened by translateRepairStep procedure. Until it returns   
-- no-data-found exception, this function is called again and again to
-- retrieve all the steps.
--
-- Output Parameters:
--    repairStepRec: repair step record that describes the step.
--
PROCEDURE getRepairStep(
   repairStepRec   OUT NOCOPY repairStepRec_t);

---------------------------- translateManualRepair ----------------------------
--
-- translateManualRepair is called to open the cursor in order to retrieve
-- the list of manual repairs (using getManualRepair).
--
-- Input Parameters:
--    adviseId   :  available manualrepairs that corresponds to this advise id.
--
PROCEDURE translateManualRepair(
   adviseId        IN  number);

-------------------------------- getManualRepair ------------------------------
--
-- getManualRepair is called to retrieve the manual repair message whose cursor 
-- is opened by translateManualRepair procedure. Until it returns
-- no-data-found exception, this function is called again and again to
-- retrieve all the manual messages.
--
-- Return:
--    Return the manual repair message.
--
FUNCTION getManualRepair(
   mandatory OUT varchar2)
RETURN varchar2;

----------------------------- getRepairScriptName -----------------------------
--
-- getRepairScriptName is called to retrieve the repair script filename
-- from v$ir_repair and description.
--
-- Input Parameters:
--    repairId   :  retrieve repair script filename for this repair id
-- Return:
--    Return the repair script location and description.
--
FUNCTION getRepairScriptName(
   repairId       IN  number,
   description    OUT varchar2)
RETURN varchar2;

pragma TIMESTAMP('2000-03-12:13:51:00');

END; -- dbms_rcvman or x$dbms_rcvman

/

--  Move the role/grant here from catalog.sql due to restructuring.
--  Recovery Catalog owner role
--  Do not drop this role recovery_catalog_owner.
--  Drop this role will revoke this role from all rman users.
--  If this role exists, ORA-1921 is expected.
declare
    role_exists exception;
    pragma exception_init(role_exists, -1921);
begin
   execute immediate 'create role recovery_catalog_owner';
exception
   when role_exists then
      null;
end;
/
grant create session,alter session,create synonym,create view,
 create database link,create table,create cluster,create sequence,
 create trigger,create procedure, create type to recovery_catalog_owner; 

drop public synonym v$backup_files;
drop view v_$backup_files;
drop function v_listBackupPipe;
drop type v_lbRecSetImpl_t;
drop type v_lbRecSet_t;
drop type v_lbRec_t;
-- obsolete column is at 20 position in this object and the object
-- implementation performs some optimization based on whether user selected
-- obsolete column (see Fetch function). If you happen to add a element in
-- this object before 20th position, you should fix the Fetch function also.
create type v_lbRec_t as object
   (
      list_order1               NUMBER,
      list_order2               NUMBER,
      pkey                      NUMBER,
      backup_type               VARCHAR2(32),
      file_type                 VARCHAR2(32),
      keep                      VARCHAR2(3),
      keep_until                DATE,
      keep_options              VARCHAR2(13),
      status                    VARCHAR2(16),
      fname                     VARCHAR2(1024),
      tag                       VARCHAR2(32),
      media                     VARCHAR2(80),
      recid                     NUMBER,
      stamp                     NUMBER,
      device_type               VARCHAR2(255),
      block_size                NUMBER,
      completion_time           DATE,
      is_rdf                    VARCHAR2(3),
      compressed                VARCHAR2(3),
      obsolete                  VARCHAR2(3),
      bytes                     NUMBER,

      bs_key                    NUMBER,
      bs_count                  NUMBER,
      bs_stamp                  NUMBER,
      bs_type                   VARCHAR2(32),
      bs_incr_type              VARCHAR2(32),
      bs_pieces                 NUMBER,
      bs_copies                 NUMBER,
      bs_completion_time        DATE,
      bs_status                 VARCHAR2(16),
      bs_bytes                  NUMBER,
      bs_compressed             VARCHAR2(3),
      bs_tag                    VARCHAR2(1024),
      bs_device_type            VARCHAR2(255),

      bp_piece#                 NUMBER,
      bp_copy#                  NUMBER,

      df_file#                  NUMBER,
      df_tablespace             VARCHAR2(30),
      df_resetlogs_change#      NUMBER,
      df_creation_change#       NUMBER,
      df_checkpoint_change#     NUMBER,
      df_ckp_mod_time           DATE,
      df_incremental_change#    NUMBER,

      rl_thread#                NUMBER,
      rl_sequence#              NUMBER,
      rl_resetlogs_change#      NUMBER,
      rl_first_change#          NUMBER,
      rl_first_time             DATE,
      rl_next_change#           NUMBER,
      rl_next_time              DATE
   );
/
create type v_lbRecSet_t as table of v_lbRec_t;
/
create type v_lbRecSetImpl_t as object 
(
   curval                number,  -- current rownum
   done                  number,  -- done with the query
   needobsolete          number,  -- user requested obsolete column

   static function ODCITablePrepare(sctx OUT    v_lbRecSetImpl_t, 
                                   ti    IN     SYS.ODCITabFuncInfo) 
      return number,

   static function ODCITableStart(sctx   IN OUT v_lbRecSetImpl_t)
      return number,

   member function ODCITableFetch(self   IN OUT v_lbRecSetImpl_t, 
                                  nrows  IN     number, 
                                  objSet OUT    v_lbRecSet_t) 
      return number,

   member function ODCITableClose(self   IN     v_lbRecSetImpl_t) 
      return number
);
/
create or replace type body v_lbRecSetImpl_t is

  static function ODCITablePrepare(sctx OUT v_lbRecSetImpl_t, 
                                   ti   IN  SYS.ODCITabFuncInfo) 
    return number is
  begin
    -- create instance of object, initialise curval, done and needobsolete
    sctx:=v_lbRecSetImpl_t(0, 0, 0);

    -- check if user is interested in obsolete column. If this column location
    -- is changed in object definition, this should be fixed.
    for i in ti.Attrs.first .. ti.Attrs.last
    loop
      if (ti.Attrs(i) = 20) then
         sctx.needobsolete := 1;
         exit;
      end if;
    end loop;

    return SYS.ODCIConst.Success;
  end ODCITablePrepare;

  static function ODCITableStart(sctx IN OUT v_lbRecSetImpl_t) 
    return number is
  begin
    return SYS.ODCIConst.Success;
  end ODCITableStart;

-- Fetch function is not called more than once. It returns all rows when
-- called first time for each query because we can not have package composite
-- types within object definition. For the same reason, the nrows parameter 
-- is ignored.
  member function ODCITableFetch(self   IN OUT v_lbRecSetImpl_t, 
                                 nrows  IN     number, 
                                 objSet OUT    v_lbRecSet_t) 
    return number is
    n               number  := 0;
    firstCall       boolean := TRUE;
    ret             boolean := TRUE;
    redundancy      number;
    recovery_window number;
    untilTime       date;
    lbRec           sys.dbms_rcvman.lbrec_t;
    lbCursor        sys.dbms_rcvman.lbCursor_t;
    lbState         sys.dbms_rcvman.lbState_t;
  begin
    objSet:=v_lbRecSet_t();

    -- reset package state
    sys.dbms_rcvman.resetAll;

    -- Set database so that user does not need to care
    sys.dbms_rcvman.setDatabase(NULL, NULL, NULL, NULL);

    redundancy := 1;
    recovery_window := 0;

    -- We need to get the retention policy, and to set untilTime if
    -- retention policy is recovery_window.
    -- Get retention policy (recovery window and redunadcy).
    sys.dbms_rcvman.getRetentionPolicy(recovery_window, redundancy);

    -- Always work with all incarnations.
    sys.dbms_rcvman.setAllIncarnations(TRUE);

    -- Set untilTime and untilSCN for recovery window (if any).
    if (recovery_window > 0)
    then
      select (sysdate-recovery_window) into untilTime from dual;
      sys.dbms_rcvman.setUntilTime(untilTime);
    end if;

    sys.dbms_rcvman.setDeviceTypeAny;

    if (recovery_window = 0 and redundancy = 0) then
       -- don't need obsolete data if there the policy is NONE
       sys.dbms_rcvman.setNeedObsoleteData(false);
    else
       if self.needobsolete = 1 then
          sys.dbms_rcvman.setNeedObsoleteData(true);
       else
          sys.dbms_rcvman.setNeedObsoleteData(false);
       end if;
    end if;

    while ret and self.done = 0 loop
      ret := sys.dbms_rcvman.listBackup(lbRec, firstCall, FALSE, 
                                        redundancy,
                                        TRUE, lbCursor, lbState, null);
      if (lbRec.pkey is not null)
      then
        objSet.extend;
        n := n + 1;
        objSet(n):= v_lbRec_t(
                            to_number(null),   -- list_order1
                            to_number(null),   -- list_order2
                            to_number(null),   -- pkey
                            to_char(null),     -- backup_type
                            to_char(null),     -- file_type
                            to_char(null),     -- keep
                            to_date(null),     -- keep_until
                            to_char(null),     -- keep_options
                            to_char(null),     -- status
                            to_char(null),     -- fname
                            to_char(null),     -- tag
                            to_char(null),     -- media
                            to_number(null),   -- recid
                            to_number(null),   -- stamp
                            to_char(null),     -- device_type
                            to_number(null),   -- block_size
                            to_date(null),     -- completion_time
                            to_char(null),     -- is_rdf
                            to_char(null),     -- compressed
                            to_char(null),     -- obsolete
                            to_number(null),   -- bytes
                            to_number(null),   -- bs_key
                            to_number(null),   -- bs_count
                            to_number(null),   -- bs_stamp
                            to_char(null),     -- bs_type
                            to_char(null),     -- bs_incr_type
                            to_number(null),   -- bs_pieces
                            to_number(null),   -- bs_copies
                            to_date(null),     -- bs_completion_time
                            to_char(null),     -- bs_status
                            to_number(null),   -- bs_bytes
                            to_char(null),     -- bs_compressed
                            to_char(null),     -- bs_tag
                            to_char(null),     -- bs_device_type
                            to_number(null),   -- bp_piece#
                            to_number(null),   -- bp_copy#
                            to_number(null),   -- df_file#
                            to_char(null),     -- df_tablespace
                            to_number(null),   -- df_resetlogs_change#
                            to_number(null),   -- df_creation_change#
                            to_number(null),   -- df_checkpoint_change#
                            to_date(null),     -- df_ckp_mod_time
                            to_number(null),   -- df_incremental_change#
                            to_number(null),   -- rl_thread#
                            to_number(null),   -- rl_sequence#
                            to_number(null),   -- rl_resetlogs_change#
                            to_number(null),   -- rl_first_change#
                            to_date(null),     -- rl_first_time
                            to_number(null),   -- rl_next_change#
                            to_date(null));    -- rl_next_time;
        objSet(n).list_order1            := lbRec.list_order1;
        objSet(n).list_order2            := lbRec.list_order2;
        objSet(n).pkey                   := lbRec.pkey;
        objSet(n).backup_type            := lbRec.backup_type;
        objSet(n).file_type              := lbRec.file_type;
        objSet(n).keep                   := lbRec.keep;
        objSet(n).keep_until             := lbRec.keep_until;
        objSet(n).keep_options           := lbRec.keep_options;
        objSet(n).status                 := lbRec.status;
        objSet(n).fname                  := lbRec.fname;
        objSet(n).tag                    := lbRec.tag;
        objSet(n).media                  := lbRec.media;
        objSet(n).recid                  := lbRec.stamp;
        objSet(n).stamp                  := lbRec.stamp;
        objSet(n).device_type            := lbRec.device_type;
        objSet(n).block_size             := lbRec.block_size;
        objSet(n).completion_time        := lbRec.completion_time;
        objSet(n).is_rdf                 := lbRec.is_rdf;
        objSet(n).compressed             := lbRec.compressed;
        objSet(n).obsolete               := lbRec.obsolete;
        objSet(n).bytes                  := lbRec.bytes;
        objSet(n).bs_key                 := lbRec.bs_key;
        objSet(n).bs_count               := lbRec.bs_count;
        objSet(n).bs_stamp               := lbRec.bs_stamp;
        objSet(n).bs_type                := lbRec.bs_type;
        objSet(n).bs_incr_type           := lbRec.bs_incr_type;
        objSet(n).bs_pieces              := lbRec.bs_pieces;
        objSet(n).bs_copies              := lbRec.bs_copies;
        objSet(n).bs_completion_time     := lbRec.bs_completion_time;
        objSet(n).bs_status              := lbRec.bs_status;
        objSet(n).bs_bytes               := lbRec.bs_bytes;
        objSet(n).bs_compressed          := lbRec.bs_compressed;
        objSet(n).bs_tag                 := lbRec.bs_tag;
        objSet(n).bs_device_type         := lbRec.bs_device_type;
        objSet(n).bp_piece#              := lbRec.bp_piece#;
        objSet(n).bp_copy#               := lbRec.bp_copy#;
        objSet(n).df_file#               := lbRec.df_file#;
        objSet(n).df_tablespace          := lbRec.df_tablespace;
        objSet(n).df_resetlogs_change#   := lbRec.df_resetlogs_change#;
        objSet(n).df_creation_change#    := lbRec.df_creation_change#;
        objSet(n).df_checkpoint_change#  := lbRec.df_checkpoint_change#;
        objSet(n).df_ckp_mod_time        := lbRec.df_ckp_mod_time;
        objSet(n).df_incremental_change# := lbRec.df_incremental_change#;
        objSet(n).rl_thread#             := lbRec.rl_thread#;
        objSet(n).rl_sequence#           := lbRec.rl_sequence#;
        objSet(n).rl_resetlogs_change#   := lbRec.rl_resetlogs_change#;
        objSet(n).rl_first_change#       := lbRec.rl_first_change#;
        objSet(n).rl_first_time          := lbRec.rl_first_time;
        objSet(n).rl_next_change#        := lbRec.rl_next_change#;
        objSet(n).rl_next_time           := lbRec.rl_next_time;
      end if;
      firstCall := false;
      self.curval:=self.curval+1;
      if not ret then
        self.done := 1;
      end if;
    end loop;
    return SYS.ODCIConst.Success;
  end ODCITableFetch;

  member function ODCITableClose(self IN v_lbRecSetImpl_t) 
    return number 
  is
  begin
    return SYS.ODCIConst.Success;
  end ODCITableClose;
end;
/
CREATE OR REPLACE FUNCTION v_listBackupPipe
   RETURN v_lbRecSet_t PIPELINED using v_lbRecSetImpl_t;
/
--
-- The following views are connected with dbms_rcvman packages and
-- they are only part of the admin/dbmsrman.sql file which started from 
-- catproc.sql. Note that these views are not fixed views and they don't
-- NOTE: The following elemnts from lbRect_t should not be in the view:
--       - is_rdf 
--       - list_order 
--       - df_incremental_change#
--
create or replace view v_$backup_files
       as select pkey,
                 backup_type,
                 file_type,
                 keep,
                 keep_until,
                 keep_options,
                 status,
                 fname,
                 tag,
                 media,
                 recid,
                 stamp,
                 device_type,
                 block_size,
                 completion_time,
                 compressed,
                 obsolete,
                 bytes,
                 bs_key,
                 bs_count,
                 bs_stamp,
                 bs_type,
                 bs_incr_type,
                 bs_pieces,
                 bs_copies,
                 bs_completion_time,
                 bs_status,
                 bs_bytes,
                 bs_compressed,
                 bs_tag,
                 bs_device_type,
                 bp_piece#,
                 bp_copy#,
                 df_file#,
                 df_tablespace,
                 df_resetlogs_change#,
                 df_creation_change#,
                 df_checkpoint_change#,
                 df_ckp_mod_time,
                 rl_thread#,
                 rl_sequence#,
                 rl_resetlogs_change#,
                 rl_first_change#,
                 rl_first_time,
                 rl_next_change#,
                 rl_next_time
            from table(v_listBackupPipe);
create or replace public synonym v$backup_files
       for v_$backup_files;
/
grant execute on sys.dbms_rcvman to select_catalog_role;

grant select on v_$backup_files to select_catalog_role;

create or replace view v_$rman_backup_subjob_details as select * from v$rman_backup_subjob_details;
create or replace public synonym v$rman_backup_subjob_details for v_$rman_backup_subjob_details;
grant select on v_$rman_backup_subjob_details to select_catalog_role;

create or replace view v_$rman_backup_job_details as select * from v$rman_backup_job_details;
create or replace public synonym v$rman_backup_job_details for v_$rman_backup_job_details;
grant select on v_$rman_backup_job_details to select_catalog_role;

create or replace view v_$backup_set_details as select * from v$backup_set_details;
create or replace public synonym v$backup_set_details for v_$backup_set_details;
grant select on v_$backup_set_details to select_catalog_role;

create or replace view v_$backup_piece_details as select * from v$backup_piece_details;
create or replace public synonym v$backup_piece_details for v_$backup_piece_details;
grant select on v_$backup_piece_details to select_catalog_role;

create or replace view v_$backup_copy_details as select * from v$backup_copy_details;
create or replace public synonym v$backup_copy_details for v_$backup_copy_details;
grant select on v_$backup_copy_details to select_catalog_role;

create or replace view v_$proxy_copy_details as select * from v$proxy_copy_details;
create or replace public synonym v$proxy_copy_details for v_$proxy_copy_details;
grant select on v_$proxy_copy_details to select_catalog_role;

create or replace view v_$proxy_archivelog_details as select * from v$proxy_archivelog_details;
create or replace public synonym v$proxy_archivelog_details for v_$proxy_archivelog_details;
grant select on v_$proxy_archivelog_details to select_catalog_role;

create or replace view v_$backup_datafile_details as select * from v$backup_datafile_details;
create or replace public synonym v$backup_datafile_details for v_$backup_datafile_details;
grant select on v_$backup_datafile_details to select_catalog_role;

create or replace view v_$backup_controlfile_details as select * from v$backup_controlfile_details;
create or replace public synonym v$backup_controlfile_details for v_$backup_controlfile_details;
grant select on v_$backup_controlfile_details to select_catalog_role;

create or replace view v_$backup_archivelog_details as select * from v$backup_archivelog_details;
create or replace public synonym v$backup_archivelog_details for v_$backup_archivelog_details;
grant select on v_$backup_archivelog_details to select_catalog_role;

create or replace view v_$backup_spfile_details as select * from v$backup_spfile_details;
create or replace public synonym v$backup_spfile_details for v_$backup_spfile_details;
grant select on v_$backup_spfile_details to select_catalog_role;

create or replace view v_$backup_set_summary as select * from v$backup_set_summary;
create or replace public synonym v$backup_set_summary for v_$backup_set_summary;
grant select on v_$backup_set_summary to select_catalog_role;

create or replace view v_$backup_datafile_summary as select * from v$backup_datafile_summary;
create or replace public synonym v$backup_datafile_summary for v_$backup_datafile_summary;
grant select on v_$backup_datafile_summary to select_catalog_role;

create or replace view v_$backup_controlfile_summary as select * from v$backup_controlfile_summary;
create or replace public synonym v$backup_controlfile_summary for v_$backup_controlfile_summary;
grant select on v_$backup_controlfile_summary to select_catalog_role;

create or replace view v_$backup_archivelog_summary as select * from v$backup_archivelog_summary;
create or replace public synonym v$backup_archivelog_summary for v_$backup_archivelog_summary;
grant select on v_$backup_archivelog_summary to select_catalog_role;

create or replace view v_$backup_spfile_summary as select * from v$backup_spfile_summary;
create or replace public synonym v$backup_spfile_summary for v_$backup_spfile_summary;
grant select on v_$backup_spfile_summary to select_catalog_role;

create or replace view v_$backup_copy_summary as select * from v$backup_copy_summary;
create or replace public synonym v$backup_copy_summary for v_$backup_copy_summary;
grant select on v_$backup_copy_summary to select_catalog_role;

create or replace view v_$proxy_copy_summary as select * from v$proxy_copy_summary;
create or replace public synonym v$proxy_copy_summary for v_$proxy_copy_summary;
grant select on v_$proxy_copy_summary to select_catalog_role;

create or replace view v_$proxy_archivelog_summary as select * from v$proxy_archivelog_summary;
create or replace public synonym v$proxy_archivelog_summary for v_$proxy_archivelog_summary;
grant select on v_$proxy_archivelog_summary to select_catalog_role;

create or replace view v_$unusable_backupfile_details as select * from v$unusable_backupfile_details;
create or replace public synonym v$unusable_backupfile_details for v_$unusable_backupfile_details;
grant select on v_$unusable_backupfile_details to select_catalog_role;

create or replace view v_$rman_backup_type as select * from v$rman_backup_type;
create or replace public synonym v$rman_backup_type for v_$rman_backup_type;
grant select on v_$rman_backup_type to select_catalog_role;

create or replace view v_$rman_encryption_algorithms as select * from
v$rman_encryption_algorithms;
create or replace public synonym v$rman_encryption_algorithms for
v_$rman_encryption_algorithms;
grant select on v_$rman_encryption_algorithms to select_catalog_role;

