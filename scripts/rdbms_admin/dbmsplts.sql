Rem
Rem $Header: rdbms/admin/dbmsplts.sql /st_rdbms_11.2.0/6 2013/02/11 02:44:44 mjangir Exp $
Rem
Rem dbmsplts.sql
Rem
Rem Copyright (c) 1998, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsplts.sql - Pluggable Tablespace Package Specification
Rem
Rem    DESCRIPTION
Rem      This package contains procedures and functions supporting
Rem      the Pluggable Tablespace feature.  They are mostly called
Rem      by import/export.
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mjangir     01/16/13 - Backport mjangir_bug-14785068 from main 
Rem    jkaloger    06/20/11 - encryption password work for db consolidation
Rem    dgagne      06/14/11 - do not fail containment check for encrypted
Rem                           columns if full
Rem    rmir        05/18/11 - Backport rmir_bug-10351061 from main
Rem    rmir        03/17/11 - Bug 10351061, datapump support for CE tables
Rem    adalee      04/12/11 - addd get_protected_tse_key
Rem    adalee      03/22/11 - Backport adalee_bug-11652268 from main
Rem    dgagne      03/16/11 - add argument to checkplugglable
Rem    dgagne      11/03/10 - Backport dgagne_bug-10205110 from main
Rem    dgagne      03/20/07 - remove public grant
Rem    dgagne      09/19/06 - add insert_error procedure
Rem    spetride    05/15/06 - add check_csx_closure
Rem    dgagne      06/22/06 - use number when fetching number variables from 
Rem                           dictionary 
Rem    kamble      03/17/06 - 4282397: patch lob property for pre10i tts
Rem    dgagne      01/31/06 - add exception definitions and put routine
Rem                           comments before the routine definition and add
Rem                           comments to routines that don't have any
Rem    dgagne      02/28/06 - add additional optional argument to 
Rem                           checktablespace 
Rem    dgagne      02/17/06 - add sendtracemessage 
Rem    dgagne      11/18/05 - create global temp tables for plugts packages
Rem    dgagne      10/06/05 - change reclaim_temp_segment to reclaim_segment
Rem    ahwang      05/18/04 - external db char set check
Rem    jgalanes    05/11/04 - Add new fixup proc for 3573604 BITMAP index
Rem                           version lost on TTS transport
Rem    wfisher     05/05/04 - Remap tsnames and control closure checking
Rem    ahwang      03/19/04 - bug 3551627 - allow more multibyte char sets
Rem    wyang       03/01/04 - transportable db
Rem    bkhaladk    02/25/04 - support for SB Xmltype
Rem    ahwang      07/09/03 - bug 277194 - temp segment transport
Rem    jgalanes    07/22/03 - Fix 3048060 Xplatform INTCOLS
Rem    apareek     06/14/03 - add containment check for nested tables
Rem    wesmith     06/11/03 - verify_MV(): add parameter full_check
Rem    apareek     05/29/03 - add support for MVs
Rem    rasivara    04/22/03 - bug 2918098: BIG ts_list field for some
Rem                           procedures
Rem    apareek     03/03/03 - grant dbms_plugts to execute_catalog_role
Rem    apareek     09/30/02 - cross platform changes
Rem    dfriedma    05/22/02 - kfp renamed to kcp
Rem    sjhala      04/04/02 - 2198861: preserve migrated ts info with plugin
Rem    yuli        02/25/02 - add function kfp_getcomp
Rem    bmccarth    01/14/02 - Bug 802824 -move patchtablemetadata into its
Rem                           own package and set to execute public
Rem    bzane       11/05/01 - BUG 1754947: add exception 29353
Rem    rburns      10/26/01 - catch 942 exception
Rem    smuralid    09/08/01 - add patchTableMetadata
Rem    amsrivas    06/21/01 - bug 1826474: get absolute file# from file header
Rem    apareek     02/08/01 - add full_check for 2 way violations
Rem    apareek     11/10/00 - bug 1494388
Rem    jdavison    11/28/00 - Drop extra semi-colons
Rem    apareek     10/30/00 - add verify_unused_cols
Rem    apareek     07/10/00 - fix for sqlplus
Rem    apareek     05/30/00 - add extended_tts_checks
Rem    yuli        12/06/99 - bug 972035: add function kfp_getfh
Rem    jwlee       06/09/99 - bug 864670: check nchar set ID
Rem    jwlee       09/28/98 - check system and temporary tablespace
Rem    jwlee       06/25/98 - misc fixes
Rem    jwlee       06/16/98 - create temp table on the fly
Rem    jwlee       05/19/98 - add dbms_tts package
Rem    jwlee       05/03/98 - add place holder for char set name
Rem    jwlee       04/04/98 - add more exceptions
Rem    jwlee       04/02/98 - Complete coding for first phase
Rem    jwlee       03/30/98 - more
Rem    jwlee       03/30/98 - more on transportable tablespace
Rem    jwlee       03/26/98 - more
Rem    jwlee       03/19/98 - more on Pluggable Tablespace
Rem    jwlee       03/06/98 - Remove highSCN parameter from beginImport
Rem    jwlee       02/25/98 - Pluggable Tablespace Package Specification
Rem    jwlee       02/25/98 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_plugts IS

  TS_EXP_BEGIN   CONSTANT binary_integer := 1;
  TS_EXP_END     CONSTANT binary_integer := 2;

  /**********************************************
  **   Routines called directly by EXPORT      **
  **********************************************/

  --++
  -- Definition:  This procedure constructs the beginImport call in an
  --              anonymous PL/SQL block.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  PROCEDURE beginExport;

  --++
  -- Definition:  This procedure verifies tablespaces are read-only during
  --              export. It is called for each tablespace specified
  --
  -- Inputs:      tsname = tablespace name to verify
  --
  -- Outputs:     None
  --
  -- Possible Exceptions:
  --              ts_not_found
  --              ts_not_read_only
  --++
  PROCEDURE beginExpTablespace (
        tsname  IN varchar2);

  --++
  -- Definition:  This procedure verifies objects are self-contained in the
  --              tablespaces specified.
  --
  -- Inputs:      incl_constraints = 1 if include constraints, 0 otherwise
  --              incl_triggers    = 1 if include triggers, 0 otherwise
  --              incl_grants      = 1 if include grants, 0 otherwise
  --              full_closure     = TRUE if both IN and OUT pointers are
  --                                 considered violations
  --                                 (should be TRUE for TSPITR)
  --              do_check         = 1 if check should be done, 0 if not done
  --              job_type         = DATABASE_EXPORT IF FULL TTS
  --              encryption_password = true if encryption password supplied
  --                                    on command line.
  --
  -- Outputs:     None
  --
  -- Possible Exceptions:
  --              ORA-29341 (not_self_contained)
  --++
  PROCEDURE checkPluggable (
        incl_constraints        IN number,
        incl_triggers           IN number,
        incl_grants             IN number,
        full_check              IN number,
        do_check                IN number DEFAULT 1,
        job_type                IN varchar2 DEFAULT NULL,
        encryption_password     IN BOOLEAN DEFAULT FALSE);


  --++
  -- Definition:  This function returns the next line of a block that has been
  --              previously selected for retrieval via selectBlock.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --
  -- Returns:     A string to be appended to the export file.
  --++
  FUNCTION getLine
    RETURN varchar2;

  --++
  -- Definition:  This procedures selects a particular PL/SQL anonymous block
  --              for retrieval.
  --
  -- Inputs:      blockID = the ID to pick a PL/SQL anonymous block
  --                        dbms_plugts.TS_EXP_BEGIN at the beginning of export
  --                        dbms_plugts.TS_EXP_END at the end of export
  -- Outputs:     None
  --++
  PROCEDURE selectBlock (
        blockID         IN binary_integer);

  /**********************************************
  **   Routines called directly by IMPORT      **
  **********************************************/

  --++
  -- Definition:  The procedure informs the dbms_Plugts package about the
  --              location of the new datafiles. If the file can not be found,
  --              an error will be signaled, possible at a later point.
  --
  -- Inputs:      filename = file name (including path)
  --
  -- Outputs:     None
  --++
  PROCEDURE newDatafile (
        filename        IN varchar2);

  --++
  -- Definition:  This procedure informs the dbms_plugts package about
  --              tablespace name to be included in the job.
  --
  -- Inputs:      tsname - Tablespace name
  --
  -- Outputs:     None
  --++
  PROCEDURE newTablespace (
        tsname          IN varchar2);

  --++
  -- Definition:   This procedure adds a user to the import job.
  --
  -- Inputs:       usrname - user name
  --
  -- Outputs:      None
  --++
  PROCEDURE pluggableUser (
        usrname         IN varchar2);

  --++
  -- Definition:  This procedure informs the plugts package about remap_user
  --              information.
  --
  -- Inputs:      from_user - a user in FROM_USER list
  --              to_user   - the corresponding user in TO_USER list
  --
  -- Outputs:     None
  --++
  PROCEDURE mapUser (
        from_user       IN varchar2,
        to_user         IN varchar2);

  --++
  -- Definition:  This procedure informs the plugts package about
  --              REMAP_TABLESPACE information.
  --
  -- Inputs:      from_ts - a tablespace name to be remapped
  --              to_ts   - the new corresponding tablespace to be created
  --
  -- Outputs:     None
  --++
  PROCEDURE mapTs (
        from_ts         IN varchar2,
        to_ts           IN varchar2);

  /*******************************************************************
  **  Routines called automatically via the PL/SQL anonymous block  **
  *******************************************************************/
  --++
  -- Definition:  This procedure informs the plugts package about the target
  --              tablespaces and it's owner. It checks to make sure the
  --              tablespace name does not conflict with any existing
  --              tablespaces already in the database. It verifies the block
  --              size is the same as that in the target database. If all this
  --              succeeds, it begins importing metadata for the tablespace.
  --              This procedure call appears in the export file.
  --
  --              The parameter list includes all columns for ts$, except those
  --              that will be discarded (online$, undofile#, undoblock#,
  --              ownerinstance, backupowner).  The spares are included so that
  --              the interface does not have to be changed even when these
  --              spares are used in the future.
  --
  --              Three extra parameters are added for transporting migrated
  --              tablespaces. seg_fno, seg_bno and seg_blks represent the
  --              dictionary information held in SEG$ for any tablespace which
  --              was migrated from dictionary managed to locally managed. The
  --              file# and block# give the location of bitmap space header for
  --              the migrated tablespace and the blocks parameter represents
  --              the size of the space header in blocks.
  --
  -- Inputs:      tsname          - tablespace name
  --              tsID            - tablespace ID in original database
  --              owner           - owner of tablespace
  --              n_files         - number of datafiles in the tablespace
  --              contents        - contents column of ts$ (TEMP/PERMANENT)
  --              blkSize         - size of block in bytes
  --              inc_num         - incarnation number of extent
  --              clean_SCN       - tablespace clean SCN,
  --              dflminext       - default minimum number of extents
  --              dflmaxext       - default maximum number of extents
  --              dflinit         - default initial extent size
  --              dflincr         - default initial extent size
  --              dflminlen       - default minimum extent size
  --              dflextpct       - default percent extent size increase
  --              dflogging       - default logging attribute
  --              affstrength     - Affinity strength
  --              bitmapped       - If bitmapped
  --              dbID            - database ID
  --              directallowed   - allowed
  --              flags           - flags
  --              creation_SCN    - tablespace creation SCN
  --              groupname       - Group name
  --              spare1          - spare1 in ts$
  --              spare2          - spare2 in ts$
  --              spare3          - spare3 in ts$
  --              spare4          - spare4 in ts$
  --              seg_fno         - file# for space_hdr in seg$
  --              seg_bno         - block# for space_hdr in seg$
  --              seg_blks        - blocks, size of space_hdr in seg$
  --
  -- Outputs:     None
  --++
  PROCEDURE beginImpTablespace (
        tsname          IN varchar2,
        tsID            IN number,
        owner           IN varchar2,
        n_files         IN binary_integer,
        contents        IN binary_integer,
        blkSize         IN binary_integer,
        inc_num         IN binary_integer,
        clean_SCN       IN number,
        dflminext       IN number,
        dflmaxext       IN number,
        dflinit         IN number,
        dflincr         IN number,
        dflminlen       IN number,
        dflextpct       IN binary_integer,
        dflogging       IN binary_integer,
        affstrength     IN number,
        bitmapped       IN number,
        dbID            IN number,
        directallowed   IN number,
        flags           IN binary_integer,
        creation_SCN    IN number,
        groupname       IN varchar2,
        spare1          IN number,
        spare2          IN number,
        spare3          IN varchar2,
        spare4          IN date,
        seg_fno         IN number DEFAULT 0,
        seg_bno         IN number DEFAULT 0,
        seg_blks        IN number DEFAULT 0);

  --++
  -- Definition:  This procedure checks to see that the user name in the
  --              pluggable set matches that entered by the DBA via the import
  --              USERS command line option. Make sure that, after the user
  --              mappings, the required user is already in the database. This
  --              procedure call appears in the export file.
  --
  -- Inputs:      username - user name
  --
  -- Outputs:     None
  --++
  PROCEDURE checkUser (
        username        IN varchar2);

  --++
  -- Definition:  This procedure passes the information about the pluggable set
  --              to the PL/SQL package. Among them is the release version of
  --              the Oracle executable that created the pluggable set, which
  --              is used for checking compatibility.  This procedure call
  --              appears in the export file.
  --
  -- Inputs:      clone_oracle_version - release version of Oracle executable
  --                                     that created the pluggable set
  --              charsetID            - character set ID
  --              ncharsetID           - nchar set ID, in varchar2 format
  --                                     (May be NULL if generated by 8.1.5)
  --              platformID           - platform ID
  --              platformName         - platform name
  --              highest_data_objnum  - highest data object # in pluggable set
  --              highest_lob_sequence - highest LOB seq # in pluggable set
  --              n_ts                 - number of tablespace to be plugged in
  --              has_clobs            - if tablespaces have CLOB data
  --              has_nchars           - if tablespaces have nchar data
  --              char_smeantics_on    - if tablespaces have char semantic data
  --
  -- Outputs:     None
  --++
  PROCEDURE beginImport (
        clone_oracle_version    IN varchar2,
        charsetID               IN binary_integer,
        ncharsetID              IN varchar2,
        srcplatformID           IN binary_integer,
        srcplatformName         IN varchar2,
        highest_data_objnum     IN number,
        highest_lob_sequence    IN number,
        n_ts                    IN number,
        has_clobs               IN number DEFAULT 1,
        has_nchars              IN number DEFAULT 1,
        char_semantics_on       IN number DEFAULT 1);

  --++
  -- Definition:  This procedure checks and adjusts the version for each
  --              compatibility type. This procedure is in the export file.
  --
  -- Inputs:      compID - compatibility type name
  --              compRL - release level
  --
  -- Outputs:     None
  --++
  PROCEDURE checkCompType (
        compID          IN varchar2,
        compRL          IN varchar2);

  --++
  -- Definition:  This procedure calls statically linked C routines to
  --              associate the datafile with the tablespace and validates file
  --              headers. This procedure appears in the export file.
  --
  --              The parameter list includes all columns in file$, except
  --              those that will be discarded (status$, ownerinstance).
  --
  -- Inputs:      name             - file name (excluding path)
  --              databaseID       - database ID
  --              absolute_fno     - absolute file number
  --              curFileBlks      - size of file in blocks
  --              tablespace_ID    - tablespace ID in original database
  --              relative_fno     - relative file number
  --              maxextend        - maximum file size
  --              inc              - increment amount
  --              creation_SCN     - file creation SCN
  --              checkpoint_SCN   - file checkpoint SCN
  --              reset_SCN        - file reset SCN
  --              spare1           - spare1 in file$
  --              spare2           - spare2 in file$
  --              spare3           - spare3 in file$
  --              spare4           - spare4 in file$
  --
  -- Outputs:     None
  --++
  PROCEDURE checkDatafile (
        name            IN varchar2,
        databaseID      IN number,
        absolute_fno    IN binary_integer,
        curFileBlks     IN number,
        tablespace_ID   IN number,
        relative_fno    IN binary_integer,
        maxextend       IN number,
        inc             IN number,
        creation_SCN    IN number,
        checkpoint_SCN  IN number,
        reset_SCN       IN number,
        spare1          IN number,
        spare2          IN number,
        spare3          IN varchar2,
        spare4          IN date);

  --++
  -- Definition:  This procedure wraps up the tablespace check. This procedure
  --              call appears in the export file.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  PROCEDURE endImpTablespace;

  --++
  -- Definition:  This procedure calls a statically linked C routine to
  --              atomically plug-in the pluggable set. This procedure call
  --              appears in the export file.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  PROCEDURE commitPluggable;

  --++
  -- Definition:  This procedure reclaims a segment by calling the statically
  --              linked C routine kcp_plg_reclaim_segment.  This procedure
  --              call appears in the export file.
  --
  -- Inputs:      The parameters match seg$ columns exactly. See seg$
  --              description.
  --
  -- Outputs:     NOne
  --++
  PROCEDURE reclaimTempSegment (
        file_no         IN binary_integer,
        block_no        IN binary_integer,
        type_no         IN binary_integer,
        ts_no           IN binary_integer,
        blocks          IN binary_integer,
        extents         IN binary_integer,
        iniexts         IN binary_integer,
        minexts         IN binary_integer,
        maxexts         IN binary_integer,
        extsize         IN binary_integer,
        extpct          IN binary_integer,
        user_no         IN binary_integer,
        lists           IN binary_integer,
        groups          IN binary_integer,
        bitmapranges    IN number,
        cachehint       IN binary_integer,
        scanhint        IN binary_integer,
        hwmincr         IN binary_integer,
        spare1          IN binary_integer,
        spare2          IN binary_integer);

  --++
  -- Definition:  This procedure does any final cleanup to end the import job.
  --
  -- Inputs:      None
  --
  -- Outputs:     None
  --++
  PROCEDURE endImport;

  --++
  -- Definition:  This procedure gets the db char set properties of the
  --              tablespaces in sys.tts_tbs$
  --
  -- Inputs:      None
  --
  -- Outputs:     has_clobs       - tablespaces have clobs columns
  --              has_nchars      - tablespaces have nchars columns
  --              char_semantics  - has character semantics columns
  --++
  PROCEDURE get_db_char_properties (
        has_clobs       OUT binary_integer,
        has_nchars      OUT binary_integer,
        char_semantics  OUT binary_integer);

  /*******************************************************************
  **               Possible Exceptions                              **
  *******************************************************************/
  ts_not_found                  EXCEPTION;
  PRAGMA exception_init         (ts_not_found, -29304);
  ts_not_found_num              NUMBER := -29304;

  ts_not_read_only              EXCEPTION;
  PRAGMA exception_init         (ts_not_read_only, -29335);
  ts_not_read_only_num          NUMBER := -29335;

  internal_error                EXCEPTION;
  PRAGMA exception_init         (internal_error, -29336);
  internal_error_num            NUMBER := -29336;

  datafile_not_ready            EXCEPTION;
  PRAGMA exception_init         (datafile_not_ready, -29338);
  datafile_not_ready_num        NUMBER := -29338;

  blocksize_mismatch            EXCEPTION;
  PRAGMA exception_init         (blocksize_mismatch, -29339);
  blocksize_mismatch_num        NUMBER := -29339;

  exportfile_corrupted          EXCEPTION;
  PRAGMA exception_init         (exportfile_corrupted, -29340);
  exportfile_corrupted_num      NUMBER := -29340;

  not_self_contained            EXCEPTION;
  PRAGMA exception_init         (not_self_contained, -29341);
  not_self_contained_num        NUMBER := -29341;

  user_not_found                EXCEPTION;
  PRAGMA exception_init         (user_not_found, -29342);
  user_not_found_num            NUMBER := -29342;

  mapped_user_not_found         EXCEPTION;
  PRAGMA exception_init         (mapped_user_not_found, -29343);
  mapped_user_not_found_num     NUMBER := -29343;

  user_not_in_list              EXCEPTION;
  PRAGMA exception_init         (user_not_in_list, -29344);
  user_not_in_list_num          NUMBER := -29344;

  different_char_set            EXCEPTION;
  PRAGMA exception_init         (different_char_set, -29345);
  different_char_set_num        NUMBER := -29345;

  invalid_ts_list               EXCEPTION;
  PRAGMA exception_init         (invalid_ts_list, -29346);
  invalid_ts_list_num           NUMBER := -29346;

  ts_not_in_list                EXCEPTION;
  PRAGMA exception_init         (ts_not_in_list, -29347);
  ts_not_in_list_num            NUMBER := -29347;

  datafiles_missing             EXCEPTION;
  PRAGMA exception_init         (datafiles_missing, -29348);
  datafiles_missing_num         NUMBER := -29348;

  ts_name_conflict              EXCEPTION;
  PRAGMA exception_init         (ts_name_conflict, -29349);
  ts_name_conflict_num          NUMBER := -29349;

  sys_or_tmp_ts                 EXCEPTION;
  PRAGMA exception_init         (sys_or_tmp_ts, -29351);
  sys_or_tmp_ts_num             NUMBER := -29351;

  ts_list_overflow              EXCEPTION;
  PRAGMA exception_init         (ts_list_overflow, -29353);
  ts_list_overflow_num          NUMBER := -29353;

  ts_failure_list               EXCEPTION;
  PRAGMA exception_init         (ts_failure_list, -39185);
  ts_failure_list_num           NUMBER := -39185;

  ts_list_empty                 EXCEPTION;
  PRAGMA exception_init         (ts_list_empty, -39186);
  ts_list_empty_num             NUMBER := -39186;

  not_self_contained_list       EXCEPTION;
  PRAGMA exception_init         (not_self_contained_list, -39187);
  not_self_contained_list_num   NUMBER := -39187;

  /******************************************************************
  **             Interface for testing, etc.                       **
  ******************************************************************/
  PROCEDURE init;

  --++
  -- Description:  Initialize global variables used for debugging trace
  --               messages
  --
  -- Inputs:       debug_flags: Trace/debug flags from /TRACE param or
  --                            trace/debug event, possibly including global
  --                            trace/debug flags
  --
  -- Outputs:      None
  --++
  PROCEDURE SetDebug (
    debug_flags IN BINARY_INTEGER);
  --++
  -- Description: This procedure will send a message to the trace file using
  --              KUPF$FILE.TRACE.
  --
  -- Inputs:
  --      msg                     - message to print
  --
  -- Outputs:
  --      None
  --+
  PROCEDURE SendTraceMsg (
    msg         IN VARCHAR2);

  /*******************************************************************
  **               Interface for trusted callouts                   **
  *******************************************************************/
  -- begin export
  PROCEDURE kcp_bexp(
        vsn             OUT varchar2,           -- Oracle server version
        dobj_half       OUT binary_integer,     -- half of data obj#
        dobj_odd        OUT binary_integer);    -- lowest bit of data obj#

  -- get char, nchar ID and name
  PROCEDURE kcp_getchar(
        cid             OUT binary_integer,     -- char ID
        ncid            OUT binary_integer);    -- nchar ID

  -- check if char, nchar set match (signal error is not)
  PROCEDURE kcp_chkchar(
        cid             IN binary_integer,      -- char ID
        ncid            IN binary_integer,      -- nchar ID
        chknc           IN binary_integer,      -- chech nchar (1 or 0)
        has_clobs       IN binary_integer,
        has_nchars      IN binary_integer,
        char_semantics_on IN binary_integer);

  -- read file header
  PROCEDURE kcp_rdfh(
        fname           IN varchar2);

  -- convert sb4 to ub4
  FUNCTION sb4_to_ub4 (
        b               IN binary_integer)
    RETURN number;

  -- new tablespace
  PROCEDURE kcp_newts(
        tsname          IN varchar2,            -- tablespace name
        tsid            IN binary_integer,      -- ts ID
        n_files         IN binary_integer,      -- # of datafiles in ts
        blksz           IN binary_integer,      -- block size
        inc_num         IN binary_integer,      -- inc #
        cleanSCN        IN number,              -- cleanSCN
        dflminext       IN binary_integer,      -- dflminext in ts$
        dflmaxext       IN binary_integer,      -- dflmaxext in ts$
        dflinit         IN binary_integer,      -- dflinit in ts$
        dflincr         IN binary_integer,      -- dflincr in ts$
        dflminlen       IN binary_integer,      -- dflminlen in ts$
        dflextpct       IN binary_integer,      -- dflextpct in ts$
        dflogging       IN binary_integer,      -- dflogging in ts$
        bitmapped       IN binary_integer,      -- bitmapped in ts$
        dbID            IN binary_integer,      -- db ID
        crtSCN          IN number,              -- creation SCN
        contents        IN binary_integer,      -- contents$ in ts$
        flags           IN binary_integer,      -- flags in ts$
        seg_fno         IN binary_integer,      -- file# in seg$
        seg_bno         IN binary_integer,      -- block# in seg$
        seg_blks        IN binary_integer);     -- blocks in seg$

  -- Plug in datafile
  PROCEDURE kcp_plgdf(
        dbID            IN binary_integer,      -- database ID
        afn             IN binary_integer,      -- absolute file #
        fileBlks        IN binary_integer,      -- size of file in blocks
        tsID            IN binary_integer,      -- tablespace ID
        rfn             IN binary_integer,      -- relative file #
        maxextend       IN binary_integer,
        inc             IN binary_integer,
        crtSCN          IN number,              -- creation SCN
        cptSCN          IN number,              -- checkpoint SCN
        rstSCN          IN number,              -- reset SCN
        spare1          IN binary_integer);     -- spare1 in file$

  -- Commit Pluggable
  PROCEDURE kcp_cmt (
        data_objn       IN number);     -- data object number

  -- Initialize kernel data structures
  PROCEDURE kcp_init;

  -- adjust compatibility level
  PROCEDURE kcp_acomp (
        compID          IN varchar2,            -- compatibility type
        compRL          IN varchar2);           -- release level

  -- get current compatible setting
  --
  PROCEDURE kcp_getcomp (szcomp  OUT varchar2);           -- compatible setting

  -- get file header infomation according to file number
  PROCEDURE kcp_getfh (
        afn             IN  binary_integer,     -- absolute file number
        dbID            OUT binary_integer,     -- database ID
        ckpt_SCN        OUT varchar2,           -- checkpoint SCN
        reset_SCN       OUT varchar2,           -- reset log SCN
        hdr_afn         OUT binary_integer);    -- file# from header

  -- verification checks needed for cross platform transport
  PROCEDURE kcp_chkxPlatform(
        srcplatformID   IN binary_integer,
        srcplatformName IN varchar2,
        tgtplatformID   IN binary_integer,
        tgtplatformName IN varchar2,
        src_rls_version IN varchar2);

  -- fix up seg$ to reclaim a temp segment
  PROCEDURE kcp_plg_reclaim_segment(
        file_no         IN binary_integer,
        block_no        IN binary_integer,
        type_no         IN binary_integer,
        ts_no           IN binary_integer,
        blocks          IN binary_integer,
        extents         IN binary_integer,
        iniexts         IN binary_integer,
        minexts         IN binary_integer,
        maxexts         IN binary_integer,
        extpct          IN binary_integer,
        user_no         IN binary_integer,
        lists           IN binary_integer,
        groups          IN binary_integer,
        bitmapranges    IN binary_integer,
        cachehint       IN binary_integer,
        scanhint        IN binary_integer,
        hwmincr         IN binary_integer,
        spare1          IN binary_integer,
        spare2          IN binary_integer);

  -- compute whether a plug into a specified db char and nchar set is
  -- compatible with current db.
  PROCEDURE kcp_check_tts_char_set_compat(
        has_clobs               IN binary_integer,
        has_nchars              IN binary_integer,
        char_semantics_on       IN binary_integer,
        target_charset_name     IN varchar2,
        target_ncharset_name    IN varchar2);

END dbms_plugts;
/
GRANT EXECUTE ON dbms_plugts TO execute_catalog_role
/

CREATE OR REPLACE PACKAGE dbms_plugtsp IS

  --++
  -- Definition:  This procedure will finish things up after objects have been
  --              created.  Patchup table metadata after table has been created
  --              at the import site. This procedure is called by import
  --
  -- Inputs:      schemaName     - schema name
  --              tableName      - table name
  --              mdClob         - data pump's metadata
  --              expSrvrEndian  - export endian
  --              impSrvrEndian  - import endian
  --
  -- Outputs:     None
  --++
  PROCEDURE patchTableMetadata(
        schemaName      IN VARCHAR2,
        tableName       IN VARCHAR2,
        mdClob          IN CLOB,
        expSrvrEndian   IN BINARY_INTEGER,
        impSrvrEndian   IN BINARY_INTEGER);

  --++
  -- Description:  This procedure wil fixup various things that get lost across
  --               transport due to no relevant syntax (i.e. options/versions
  --               based on compatibility rather than explicit syntax).  This
  --               is called during TTS import.
  --
  -- Inputs:       str1
  --               str2
  --               str3
  --               str4
  --               str5
  --               str6
  --               str7
  --               bin1
  --
  -- Outputs:      None
  --++
  PROCEDURE patchDictionary(
        str1            IN VARCHAR2,
        str2            IN VARCHAR2,
        str3            IN VARCHAR2,
        str4            IN VARCHAR2,
        str5            IN VARCHAR2,
        str6            IN VARCHAR2,
        str7            IN VARCHAR2,
        bin1            IN BINARY_INTEGER);

  PROCEDURE patchLobProp(schemaName IN VARCHAR2,           -- schema name
                         tableName  IN VARCHAR2);          -- table name
  -- patchup lob property after table has been created
  -- at the import site
  -- This procedure is called by import for pre 10i tts dump files

  /*******************************************************************
  **               Possible Exceptions                              **
  *******************************************************************/

  -- These were copied from the dbms_plugts package which is not public-execute

  ts_not_found                  EXCEPTION;
  PRAGMA exception_init         (ts_not_found, -29304);
  ts_not_found_num              NUMBER := -29304;

  ts_not_read_only              EXCEPTION;
  PRAGMA exception_init         (ts_not_read_only, -29335);
  ts_not_read_only_num          NUMBER := -29335;

  internal_error                EXCEPTION;
  PRAGMA exception_init         (internal_error, -29336);
  internal_error_num            NUMBER := -29336;

  datafile_not_ready            EXCEPTION;
  PRAGMA exception_init         (datafile_not_ready, -29338);
  datafile_not_ready_num        NUMBER := -29338;

  blocksize_mismatch            EXCEPTION;
  PRAGMA exception_init         (blocksize_mismatch, -29339);
  blocksize_mismatch_num        NUMBER := -29339;

  exportfile_corrupted          EXCEPTION;
  PRAGMA exception_init         (exportfile_corrupted, -29340);
  exportfile_corrupted_num      NUMBER := -29340;

  not_self_contained            EXCEPTION;
  PRAGMA exception_init         (not_self_contained, -29341);
  not_self_contained_num        NUMBER := -29341;

  user_not_found                EXCEPTION;
  PRAGMA exception_init         (user_not_found, -29342);
  user_not_found_num            NUMBER := -29342;

  mapped_user_not_found         EXCEPTION;
  PRAGMA exception_init         (mapped_user_not_found, -29343);
  mapped_user_not_found_num     NUMBER := -29343;

  user_not_in_list              EXCEPTION;
  PRAGMA exception_init         (user_not_in_list, -29344);
  user_not_in_list_num          NUMBER := -29344;

  different_char_set            EXCEPTION;
  PRAGMA exception_init         (different_char_set, -29345);
  different_char_set_num        NUMBER := -29345;

  invalid_ts_list               EXCEPTION;
  PRAGMA exception_init         (invalid_ts_list, -29346);
  invalid_ts_list_num           NUMBER := -29346;

  ts_not_in_list                EXCEPTION;
  PRAGMA exception_init         (ts_not_in_list, -29347);
  ts_not_in_list_num            NUMBER := -29347;

  datafiles_missing             EXCEPTION;
  PRAGMA exception_init         (datafiles_missing, -29348);
  datafiles_missing_num         NUMBER := -29348;

  ts_name_conflict              EXCEPTION;
  PRAGMA exception_init         (ts_name_conflict, -29349);
  ts_name_conflict_num          NUMBER := -29349;

  sys_or_tmp_ts                 EXCEPTION;
  PRAGMA exception_init         (sys_or_tmp_ts, -29351);
  sys_or_tmp_ts_num             NUMBER := -29351;

  ts_list_overflow              EXCEPTION;
  PRAGMA exception_init         (ts_list_overflow, -29353);
  ts_list_overflow_num          NUMBER := -29353;

  ts_failure_list               EXCEPTION;
  PRAGMA exception_init         (ts_failure_list, -39185);
  ts_failure_list_num           NUMBER := -39185;

  ts_list_empty                 EXCEPTION;
  PRAGMA exception_init         (ts_list_empty, -39186);
  ts_list_empty_num             NUMBER := -39186;

  not_self_contained_list       EXCEPTION;
  PRAGMA exception_init         (not_self_contained_list, -39187);
  not_self_contained_list_num   NUMBER := -39187;

  /*********************************************
  ** C callout definitions                    **
  *********************************************/
  -- patch table metadata
  PROCEDURE kcp_ptmd(
        schemaName      IN VARCHAR2,            -- schema name
        tableName       IN VARCHAR2,            -- table name
        mdClob          IN CLOB,                -- data pump's metadata
        expSrvrEndian   IN BINARY_INTEGER,      -- export server endian
        impSrvrEndian   IN BINARY_INTEGER);     -- import server endian

  -- patch dictionary
  PROCEDURE kcp_pd(
        str1    IN VARCHAR2,                    -- schema name
        str2    IN VARCHAR2,
        str3    IN VARCHAR2,
        str4    IN VARCHAR2,
        str5    IN VARCHAR2,
        str6    IN VARCHAR2,
        str7    IN VARCHAR2,
        bin1    IN BINARY_INTEGER);             -- Bitmap, etc.

END dbms_plugtsp;
/
GRANT EXECUTE on dbms_plugtsp TO execute_catalog_role

/

CREATE OR REPLACE PACKAGE dbms_tts IS

  --
  -- Input formats for passphrase in set_passphrase procedure.
  --
  OBFUSCATED     CONSTANT PLS_INTEGER := 1;  -- obfuscated binary value
  ENCRYPTED      CONSTANT PLS_INTEGER := 2;  -- encrypted binary value

  -- This package checks if the transportable set is self-contained.  All
  -- violations are inserted into a temporary table that can be selected from
  -- view transport_set_violations.
  --
  TYPE tablespace_names IS TABLE OF varchar(30) INDEX BY binary_integer;

  --++
  -- Definition: This procedure checks if a tablespace is temporary or if it is
  --             a tablespace that can not be exported using transportable
  --             tablespace mode.
  --
  -- Inputs:     a_tsname - tablespace name
  --             a_ts_num - tablespace id number
  --             upcase   - allow upcasing of username or not
  --
  -- Outputs:    None
  --++
  PROCEDURE checkTablespace (
        a_tsname        IN varchar2,
        a_ts_num        IN OUT number,
        upcase          IN BOOLEAN DEFAULT FALSE);

  --++
  -- Definition:  This procedure sets the passphrase in a package state
  --              variable. Subsequent calls to get/put protected routines
  --              can pass the obfuscated passphrase to their respective
  --              C callouts as needed.
  --
  -- Inputs:      passphrase       - passphrase that is placed in a package
  --                                 state variable and passed to the get/put
  --                                 protected routines in subsequent calls.
  --              passphraseFmt    - passphrase is either in obfuscated or
  --                                 encrypted format. Valid values are:
  --                                   - SYS.DBMS_TTS.OBFUSCATED
  --
  -- Possible Exceptions:
  --              Internal errors
  --++
  PROCEDURE set_passphrase (
        passphrase              IN raw,
        passphraseFmt           IN pls_integer DEFAULT SYS.DBMS_TTS.OBFUSCATED);

  --++
  -- Definition:  This procedure verifies that the tablespace list provided is
  --              a closed set.  Any violations will be stored in the
  --              sys.tts_error$ table.
  --
  -- Inputs:      ts_list          - comma separated tablespace name list
  --              incl_constraints - include constraints or not
  --              full_check       - perform a full check or not
  --
  -- Outputs:     None
  --++
  PROCEDURE transport_set_check (
        ts_list                 IN clob,
        incl_constraints        IN boolean  DEFAULT FALSE,
        full_check              IN boolean  DEFAULT FALSE);

  --++
  -- Definition:  This function verifies that the tablespace list provided is
  --              a closed set.  If called from within a datapump job then all
  --              violations will be in the sys.tts_error$ table and false will
  --              be returned. Otherwise, false will be returned on the first
  --              violation detected and no information is stored in the
  --              sys.tts_error$ table.
  --
  -- Inputs:      ts_list          - comma separated tablespace name list
  --              incl_constraints - include constraints or not
  --              full_check       - perform a full check or not
  --              job_type         = DATABASE_EXPORT IF FULL TTS
  --              encryption_password = true if encryption password supplied
  --                                    on command line.
  --
  -- Outputs:     None
  --
  -- Return:      True if self contained, false if not.
  --++
  FUNCTION isSelfContained (
        ts_list                 IN clob,
        incl_constraints        IN boolean,
        full_check              IN boolean,
        job_type                IN varchar2 DEFAULT NULL,
        encryption_password     IN BOOLEAN DEFAULT FALSE)
    RETURN BOOLEAN;

  --
  -- Description:  This procedure checks if the transportable set is compatible
  --               with the specified char sets. Result is displayed in output.
  --               Must set serveroutput on.
  --
  -- Inputs:       ts_list      - comma separated tablespace name list
  --               target_db_char_set_name
  --               target_db_nchar_set_name
  --
  -- Outputs:      None
  --++
  PROCEDURE transport_char_set_check_msg (
        ts_list                         IN  CLOB,
        target_db_char_set_name         IN  VARCHAR2,
        target_db_nchar_set_name        IN  VARCHAR2);

  --
  -- Description:  This procedure adds an error to sys.tts_error$ if the error
  --               was not already previously added.
  --
  -- Inputs:       exp_err_num - expected error number
  --               err_num     - error number raised
  --               err_msg     - error text to insert
  --
  -- Outputs:      None
  --
  -- Return:       TRUE = expected error -- FALSE = error not expected
  --++
  FUNCTION insert_error (
        exp_err_num IN number,
        err_num     IN number,
        err_msg     IN varchar2)
    RETURN BOOLEAN;

  --++
  -- Definition:  This function returns TRUE if char set is compatible. msg is
  --              set to OK or error message.
  --
  -- Inputs:       ts_list      - comma separated tablespace name list
  --               target_db_char_set_name
  --               target_db_nchar_set_name
  --
  -- Outputs:      None
  --
  -- Returns:      True if compatible, false otherwise
  --++
  FUNCTION transport_char_set_check (
        ts_list                         IN  CLOB,
        target_db_char_set_name         IN  VARCHAR2,
        target_db_nchar_set_name        IN  VARCHAR2,
        err_msg                         OUT VARCHAR2)
    RETURN BOOLEAN;

--++
-- Procedure:    get_protected_ce_tab_key
--
-- Description:  This trusted callout provides an interface to get the 
--               column encryption table keys in the protected form.
--               The table key is extracted from the enc$, unwrapped with the 
--               Master Key, re-wrapped with the passphrase setup in a previous
--               call to dbms_tts.set_passphrase.
--               
-- Inputs:       schemaName   - schema name
--               tableName    - table name
--
-- Outputs:      protTableKey - protected table key
--
-- Note:         If not executed within dbms_datapump, it is a no-op.
--
--               If the procedure is executed successfully, the protected 
--               table key is returned to the caller.
--
--               Errors are signaled otherwise.
--++
-- internal version is the trusted callout, not to be called directly
-- by the user

PROCEDURE  get_protected_ce_tab_key (
        schemaName     IN  VARCHAR2,            -- schema name
        tableName      IN  VARCHAR2,            -- table name
        protTableKey   OUT RAW);                -- protected Table Key

--++
-- Procedure:    get_protected_tse_key
--
-- Description:  This trusted callout provides an interface to get the 
--               tablespace encryption keys in the protected form. The
--               TSE key is rewrapped using the passphrase setup in a
--               previous call to dbms_tts.set_passphrase.
--               
-- Inputs:       tablespaceNumber - tablespace number
--
-- Outputs:      protTablespaceKey - protected tablespace key
--
-- Note:         If not executed within dbms_datapump, it is a no-op.
--
--               If the procedure is executed successfully, the protected 
--               tablespace key is returned to the caller.
--
--               Errors are signaled otherwise.
--++
-- internal version is the trusted callout, not to be called directly
-- by the user

PROCEDURE  get_protected_tse_key (
        tablespaceNumber  IN  NUMBER,          -- tablespace number
        protTablespaceKey OUT RAW);            -- protected Tablespace Key

  --++
  -- Description:  NULL
  --
  -- Inputs:       None
  --
  -- Outputs:      None
  --++
  PROCEDURE downgrade;

  /*******************************************************************
  **               Possible Exceptions                              **
  *******************************************************************/

  ts_not_found                  EXCEPTION;
  PRAGMA exception_init         (ts_not_found, -29304);
  ts_not_found_num              NUMBER := -29304;

  invalid_ts_list               EXCEPTION;
  PRAGMA exception_init         (invalid_ts_list, -29346);
  invalid_ts_list_num           NUMBER := -29346;

  sys_or_tmp_ts                 EXCEPTION;
  PRAGMA exception_init         (sys_or_tmp_ts, -29351);
  sys_or_tmp_ts_num             NUMBER := -29351;

  encpwd_error                  EXCEPTION;
  PRAGMA exception_init         (encpwd_error, -39330);
  encpwd_error_num              NUMBER := -39330;

  /*******************************************************************
  **               Trusted callouts                                 **
  *******************************************************************/

END dbms_tts;
/
GRANT EXECUTE ON dbms_tts TO execute_catalog_role
/
Rem  Create objects needed for transportable tablespace export/import
BEGIN
  BEGIN
    EXECUTE IMMEDIATE
      'create global temporary table sys.tts_tbs$ ' ||
          '(name     varchar2(30), ' ||
           'ts#      number, ' ||
           'found    number) on commit preserve rows';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -955 THEN
        NULL;
      ELSE
        RAISE;
      END IF;
  END;
  BEGIN
    EXECUTE IMMEDIATE
      'create global temporary table sys.tts_usr$ ' ||
          '(name      varchar2(30), ' ||
           'found     number) on commit preserve rows';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -955 THEN
        NULL;
      ELSE
        RAISE;
      END IF;
  END;
  BEGIN
    EXECUTE IMMEDIATE
      'create global temporary table sys.tts_error$ ' ||
      '(violations varchar2(2000)) on commit preserve rows';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -955 THEN
        NULL;
      ELSE
        RAISE;
      END IF;
  END;
  --
  -- create view
  --
  EXECUTE IMMEDIATE
        'create or replace view TRANSPORT_SET_VIOLATIONS ' ||
        '(VIOLATIONS) as select * from sys.tts_error$';

  --
  -- grant view
  --
  EXECUTE IMMEDIATE
        'grant select on TRANSPORT_SET_VIOLATIONS to SELECT_CATALOG_ROLE';
END;

/
/*****************************************************************************/
 -- The following package contains procedures and packages supporting
 -- additional checks for the transportable tablespace feature. It adds support
 -- to capture any objects that would prevent the transportable feature to be
 -- used because of dependencies between objects in the transportable set and
 -- those not contained in the transportable set
 --
 --  Note that these are in addition to the ones that are captured by the
 --  dbms_tts.straddling_ts_objects
 --
 -- If a new feature is introduced, developers should write a new function to
 -- build a tablespace list associated with any object that is part of the
 -- feature and ensure its self containment by using the function
 -- dbms_extended_tts_checks.objectlist_Contained
 --
 --  ********************************************************************
 --  * The following shows example usage:                               *
 --  *                                                                  *
 --  * New Feature --> Extensible Index                                 *
 --  *                                                                  *
 --  * New Function                                                     *
 --  * Function dbms_extended_tts_checks.verify_Exensible               *
 --  *                                                                  *
 --  *   The above function ensures that all objects associated with    *
 --  *   extensible index are self contained. It                        *
 --  *     - Identifies objects of type Extensible indexes (o1,o2..oN)  *
 --  *     - Gets a list of dependent objects for each object oI        *
 --  *     - Generates a dependent tablespace list for that object      *
 --  *     - Ensures that the dependent list is either fully contained  *
 --  *       or fully outside the list of tablespaces to be transported *
 --  *       using dbms_extended_tts_checks.objectlist_Contained        *
 --  *                                                                  *
 --  * The above function should then be invoked from the function      *
 --  * dbms_tts.straddling_ts_objects                                   *
 --  ********************************************************************
 --
 -- Current functions that identify tablespaces containing a base object
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_tab
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_ind
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_tabpart
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_indpart
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_tabsubpart
 -- FUNCTION dbms_extended_tts_checks.get_tablespace_indsubpart
 --
 -- For any new objects that take up storage, a function that identifies the
 -- storage tablespace must be added
 --
 /****************************************************************************/
CREATE OR REPLACE PACKAGE SYS.DBMS_EXTENDED_TTS_CHECKS IS

  /*************************************************************************
      Data Structures
   *************************************************************************/

  -- following data structure is used to pass information about an object
  TYPE objrec IS RECORD (
        v_pobjschema    varchar2(30),
        v_pobjname      varchar2(30),
        v_objid         number,
        v_objname       varchar2(30),
        v_objsubname    varchar2(30),
        v_objowner      varchar2(30),
        v_objtype       varchar2(15));

  --  List of object records
  TYPE t_objlist IS TABLE OF objrec
    INDEX BY BINARY_INTEGER;

  --++
  -- Definition:  This function verifies Schema based XMLType tables that are
  --              part of the transport set are self contained. i.e. the out of
  --              line pieces that the table points to are also part of the
  --              transport set. This will ensure that the SB XMLType table is
  --              self contained.
  --
  -- Inputs:      tsnames - plsql table of tablespace names
  --              fromexp - stop after first violation found
  --
  -- Outputs:     None
  --
  -- Returns:     If fromExp is true, return false if violation found, true
  --              for all other cases (even if violations have been found).
  --++
  Function  verify_XMLSchema(
        tsnames dbms_tts.tablespace_names, 
        fromExp in boolean)
    RETURN boolean;

  --++
  -- Function      check_csx_closure
  --
  -- Description:  Verifies that all token manager tables for XML tables and columns 
  --               with binary storage (CSX) are also contained in the transported
  --               tablespaces. This is needed so that data at the import site can be
  --               decoded without a full remapping.
  --
  --               To be combined with verify_XMLSchema. 
  --
  -- Inputs:       tsnames  - comma separated list of tablespace names
  --               fromExp  - being called by export?
  --
  -- Outputs:      None
  --
  -- Results       True if contained, otherwise false.
  --               As for verify_XMLSchema, even if violation is found, returns true
  --               if from Exp is false.
  --++
  FUNCTION check_csx_closure(
      tsnames IN dbms_tts.tablespace_names,
      fromExp IN  boolean )
    RETURN boolean;

  --++

  --++
  -- Definition:  This function verifies secondary objects that are associated
  --              with an extensible index are contained in the list of
  --              tablespaces or fully outside the list. This guarantees self
  --              containment of all or none of the secondary objects
  --              associated with the extensible index. For simple types like
  --              tables and indexes it is clear why this check works. What may
  --              not be so obvious is that this works even for objects like
  --              partitions, lobs etc.  For e.g. if Table T1 is partitioned
  --              two ways P1 and P2, has a lob object L1 and Table T2 is an
  --              IOT, and extensible index E1 is associated with L1 and T2
  --              then it is sufficient just check that tablespace(L1) and
  --              tablespace(T2) are either fully contained or fully out of
  --              the tts set. Self Containment of T1 and T2 is guaranteed by
  --              the straddling_rs_objects function
  --
  -- Inputs:      fromexp - stop after first violation found
  --
  -- Outputs:     None
  --
  -- Returns:     If fromExp is true, return false if violation found, true
  --              for all other cases (even if violations have been found).
  --++
  Function  verify_Extensible (
        fromExp in boolean)
    RETURN boolean;

  --++
  -- Definition :  This function verifies that:
  --               1. Materialized view logs stored as tables and the
  --                  corresponding master tables are self contained. The
  --                  containment check is similar to tables and its indexes:
  --                  If full_check is TRUE, then BOTH the MV log and the
  --                  master table must be in or both must be out of the
  --                  transportable set. If full_check is FALSE, then it is ok
  --                  for the MV log to be out of the transportable set but it
  --                  is NOT ok for the MV log to be in and its master table to
  --                  be out of the set.
  --               2. Updateable Materialized view tables and their
  --                  corresponding logs are fully contained in the
  --                  transportable set.
  --
  --               If fromExp is false, populate the violation table with the
  --               offending violation object information for each violation.
  --
  --               Note that it is ok to transport just the MVs and not their
  --               masters or vice versa. It is also ok to just transport
  --               master tables without the mv logs, but NOT vice versa.
  --
  -- Inputs:      fromexp    - stop after first violation found
  --              full_check - perform full check - described above
  --
  -- Outputs:     None
  --
  -- Returns:     If fromExp is true, return false if violation found, true
  --              for all other cases (even if violations have been found).
  --++
  FUNCTION verify_MV (
        fromExp         in boolean,
        full_check      in boolean) 
    RETURN boolean;

  --++
  -- Definition:  This function verifies that all nested tables are fully in or
  --              out of the tts set.
  --
  -- Inputs:      fromexp    - stop after first violation found
  --
  -- Outputs:     None
  --
  -- Returns:     If fromExp is true, return false if violation found, true
  --              for all other cases (even if violations have been found).
  --++
  FUNCTION  verify_NT(
        fromExp in boolean)
    RETURN boolean;

  --++
  -- Definition:  This function ensures that the group of objects that are
  --              passed in either are fully IN or OUT of the tslist (set of
  --              tablespaces to be transported
  --
  -- Inputs:      vobjlist
  --
  -- Outputs:     None
  --
  -- Return:      straddling objects across transportable set - 0
  --              all objects in list are fully contained     - 1
  --              all objects in list are fully outside       - 2
  --++
  FUNCTION objectlist_Contained(
        vobjlist        t_objlist)
    RETURN number;

  --
  -- The following get_tablespace_* functions take information about an object
  -- that takes up physical storage in the database and returns the tablespace
  -- name associated with the object.
  --

  --++
  -- Definition:  This function checks if table is non partitioned and not an
  --              IOT then return its tablespace.  If the TABLE is an IOT or
  --              partitioned then just return the tablespace associated with
  --              the index or the first partition respectively. If a specific
  --              tablespace is needed then the get_tablespace_tabpart routine
  --              should be invoked by the caller.
  --
  -- Inputs:      object_id      - obj# of object to check
  --              object_owner   - owner of object
  --              object_name    - object name
  --              object_subname - object subname (partition or subpartition)
  --              object_type    - object type
  --
  -- Outputs:     None
  --
  -- Returns:     Tablespace name
  --++
  FUNCTION get_tablespace_tab(
        object_id       number,
        object_owner    varchar2,
        object_name     varchar2,
        object_subname  varchar2,
        object_type     varchar2)
    RETURN varchar2;

  --++
  -- Description:  If the INDEX is partitioned then simply return the
  --               tablespace associated the first partition
  --
  -- Inputs:      object_id      - obj# of object to check
  --              object_owner   - owner of object
  --              object_name    - object name
  --              object_subname - object subname (partition or subpartition)
  --              object_type    - object type
  --
  -- Outputs:     None
  --
  -- Returns:     Tablespace name
  --++
  FUNCTION get_tablespace_ind(
        object_id       number,
        object_owner    varchar2,
        object_name     varchar2,
        object_subname  varchar2,
        object_type     varchar2)
    RETURN varchar2;

  --++
  -- Definition:  If the table is partitioned, then return the tablespace
  --              associated with the first partition
  --
  -- Inputs:      object_id      - obj# of object to check
  --              object_owner   - owner of object
  --              object_name    - object name
  --              object_subname - object subname (partition or subpartition)
  --              object_type    - object type
  --
  -- Outputs:     None
  --
  -- Returns:     Tablespace name
  --++
  FUNCTION get_tablespace_tabpart(
        object_id       number,
        object_owner    varchar2,
        object_name     varchar2,
        object_subname  varchar2,
        object_type     varchar2)
    RETURN varchar2;

  --++
  -- Definition:  If the index is partitioned, then return the tablespace
  --              associated with the first partition
  --
  -- Inputs:      object_id      - obj# of object to check
  --              object_owner   - owner of object
  --              object_name    - object name
  --              object_subname - object subname (partition or subpartition)
  --              object_type    - object type
  --
  -- Outputs:     None
  --
  -- Returns:     Tablespace name
  --++
  FUNCTION get_tablespace_indpart(
        object_id       IN number,
        object_owner    varchar2,
        object_name     varchar2,
        object_subname  varchar2,
        object_type     varchar2)
    RETURN varchar2;

  --++
  -- Definition:  Return the tablespace associated with the first subpartition
  --
  -- Inputs:      object_id      - obj# of object to check
  --              object_owner   - owner of object
  --              object_name    - object name
  --              object_subname - object subname (partition or subpartition)
  --              object_type    - object type
  --
  -- Outputs:     None
  --
  -- Returns:     Tablespace name
  --++
  FUNCTION get_tablespace_tabsubpart(
        object_id       number,
        object_owner    varchar2,
        object_name     varchar2,
        object_subname  varchar2,
        object_type     varchar2)
    RETURN varchar2;

  --++
  -- Definition:  Return the tablespace associated with the first subpartition
  --
  -- Inputs:      object_id      - obj# of object to check
  --              object_owner   - owner of object
  --              object_name    - object name
  --              object_subname - object subname (partition or subpartition)
  --              object_type    - object type
  --
  -- Outputs:     None
  --
  -- Returns:     Tablespace name
  --++
  FUNCTION get_tablespace_indsubpart(
        object_id       number,
        object_owner    varchar2,
        object_name     varchar2,
        object_subname  varchar2,
        object_type     varchar2)
    RETURN varchar2;

  --++
  -- Description:  This function returns objects associated with an extensible
  --               index in a list format
  --
  -- Inputs:       objn   - object number
  --
  -- Outputs:      None
  --
  -- Returns       objects associated with an extensible index in a list format
  FUNCTION get_domain_index_secobj(
        objn    number)
    RETURN t_objlist;

  --++
  -- Description:  This function returns child nested tables associated with a
  --               parent nested table object in a list format
  --
  -- Inputs:       objn   - object number
  --
  -- Outputs:      None
  --
  -- Returns       child nested tables associated with a parent nested table
  --               object in a list format
  FUNCTION get_child_nested_tables(
        objn    number)
    RETURN t_objlist;

END DBMS_EXTENDED_TTS_CHECKS;
/

/***************************************************************************
 -- NAME
 --   dbms_tdb - Transportable DataBase
 -- DESCRIPTION
 --  This package is used to check if a database if ready to be transported.
 **************************************************************************/
CREATE OR REPLACE PACKAGE SYS.DBMS_TDB IS
  --++
  -- Description:  This function checks if a database is ready to be
  --               transported to a target platform. If the database is not
  --               ready to be transported and serveroutput is on, a detailed
  --               description of the reason why the database cannot be
  --               transported and possible ways to fix the problem will be
  --               displayed
  --
  -- Inputs:       target_platform - name of the target platform
  --
  -- Outputs:      None
  --
  -- Returns:      TRUE if the datababase is ready to be transported.
  --               FALSE otherwise.
  --++
  SKIP_NONE          constant number := 0;
  SKIP_INACCESSIBLE  constant number := 1;
  SKIP_OFFLINE       constant number := 2;
  SKIP_READONLY      constant number := 3;

  FUNCTION check_db(
        target_platform_name    IN varchar2,
        skip_option             IN number)
    RETURN boolean;

  FUNCTION check_db(
        target_platform_name    IN varchar2)
    RETURN boolean;

  FUNCTION check_db
    RETURN boolean;

  --++
  -- Description:  This function checks if a database has external tables,
  --               directories or BFILEs. It will use dbms_output.put_line to
  --               output the external objects and their owners.
  --
  -- Inputs:       None
  --
  -- Outputs:      None
  --
  -- Returns:      TRUE if the datababase has external tables, directories or
  --               BFILEs. FALSE otherwise.
  --++
  FUNCTION check_external
    RETURN boolean;

  --++
  -- Description:  This procedure is used in transport script to throw a SQL
  --               error so that the transport script can exit.
  --
  -- Inputs:       should_exit - whether to exit from transport script
  --
  -- Outputs:      None
  --
  -- EXCEPTIONS:   ORA-9330
  --++
  PROCEDURE exit_transport_script(
        should_exit     IN varchar2);
END;
/
GRANT EXECUTE ON SYS.DBMS_TDB TO dba;
