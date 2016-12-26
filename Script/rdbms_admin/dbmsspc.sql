Rem
Rem $Header: rdbms/admin/dbmsspc.sql /main/19 2010/01/07 18:23:38 sursridh Exp $
Rem
Rem dbmsspc.sql
Rem
Rem Copyright (c) 1997, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsspc.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sursridh    12/28/09 - Add new procedure
Rem                           materialize_deferred_with_opt.
Rem    sursridh    06/04/09 - Add new procedures drop_empty_segments,
Rem                           materialize_deferred_segments.
Rem    weizhang    01/08/09 - add bg allocation test segment_extend
Rem    weizhang    11/19/07 - SecureFile segment repair
Rem    nmukherj    05/15/06 - added nglob_verify procedure
Rem    weizhang    10/13/04 - add assm_segment_synchwm() 
Rem    nmukherj    02/08/04 - project 13244: modified segment_verify and tablespace_verify
Rem                           procedures to include more diagnosibility options
Rem                           the segment_repair procedure is used to corrupt the 
Rem                           segment metadata by enabling event 42221
Rem                           for verification testing purposes
Rem    mmpandey    03/17/04 - b3270428: change of ret type of space functions 
Rem    nmukherj    11/26/03 - added procedure tablespace_fix_segment_extblks
Rem    smuthuli    04/22/03 - move out shrink functions to dbms_space
Rem    smuthuli    01/16/03 - APIs for shrink
Rem    atsukerm    07/16/01 - moving blocks from master to process free list.
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    bemeng      06/15/00 - change float datatype to number (bug 1308631)
Rem    smuthuli    07/12/99 - rename dbmsspace to dbmsspc
Rem    ncramesh    08/07/98 - change for sqlplus
Rem    bhimatsi    03/26/98 - migrate to dicitionary
Rem    bhimatsi    03/08/98 - add rebuild quotas
Rem    bhimatsi    02/26/98 - add calls for getting extent and blocks for segme
Rem    bhimatsi    01/05/98 - cleanup a bit
Rem    bhimatsi    11/19/97 - dbms_space_admin package
Rem    bhimatsi    11/19/97 - Created
Rem

create or replace package dbms_space_admin is
  ------------
  --  OVERVIEW
  --
  --  This package provides tablespace/segment space administration
  --  not available through the standard sql.

  --  SECURITY
  --
  --  run with SYS privileges. thus any user who has privilege to execute the
  -- the package gets to manipulate the bitmapes.

  --  CONSTANTS to be used as OPTIONS for various procedures
  --  refer comments with procedure(s) for more detail

  SEGMENT_VERIFY_EXTENTS         constant positive := 1;
  -- used to verify that the space owned by segment is appropriately reflected
  -- in the bitmap as used
  SEGMENT_VERIFY_EXTENTS_GLOBAL  constant positive := 2;
  -- used to verify that the space owned bu segment is appropriately reflected
  -- in the bitmap as used and that no other segment claims any of this space
  -- to be used by it
  SEGMENT_MARK_CORRUPT          constant positive := 3;
  -- used to mark a temp segment as corrupt whereby facilitating its
  -- elimination from the dictionary (without space reclaim)
  SEGMENT_MARK_VALID            constant positive := 4;
  -- used to mark a corrupt temp segment as valid. Useful when the corruption
  -- in the segment extent map or elsewhere has been resolved and the segment
  -- can be dropped normally
  SEGMENT_DUMP_EXTENT_MAP       constant positive := 5;
  -- dump the extent map for a given segment
  TABLESPACE_VERIFY_BITMAP      constant positive := 6;
  -- verifies the bitmap of the tablespace with extent maps of the segments
  -- in that tablespace to make sure everything is consistent
  TABLESPACE_EXTENT_MAKE_FREE   constant positive := 7;
  -- makes this range (extent) of space free in the bitmaps
  TABLESPACE_EXTENT_MAKE_USED   constant positive := 8;
  -- makes this range (extent) of space used in the bitmaps

  SEGMENT_VERIFY_BASIC          constant positive := 9;
  SEGMENT_VERIFY_DEEP           constant positive := 10;
  SEGMENT_VERIFY_SPECIFIC       constant positive := 11;
  HWM_CHECK                     constant positive := 12;
  BMB_CHECK                     constant positive := 13;
  SEG_DICT_CHECK                constant positive := 14;
  EXTENT_TS_BITMAP_CHECK        constant positive := 15;
  DB_BACKPOINTER_CHECK          constant positive := 16;
  EXTENT_SEGMENT_BITMAP_CHECK   constant positive := 17;
  BITMAPS_CHECK                 constant positive := 18;


  TS_VERIFY_BITMAPS             constant positive := 19;
  TS_VERIFY_DEEP                constant positive := 20;
  TS_VERIFY_SEGMENTS            constant positive := 21;

  SEGMENT_DUMP_BITMAP_SUMMARY   constant positive := 27;

  NGLOB_HBB_CHECK               constant positive := 12;
  NGLOB_FSB_CHECK               constant positive := 13;
  NGLOB_PUA_CHECK               constant positive := 14;
  NGLOB_CFS_CHECK               constant positive := 15;



  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  
  procedure segment_verify(
        tablespace_name         in    varchar2 ,
        header_relative_file    in    positive ,
        header_block            in    positive ,
        verify_option           in    positive  DEFAULT SEGMENT_VERIFY_EXTENTS
                           );
  --
  --  Verifies the consistency of the extent map of the segment
  --  Input arguments:
  --   tablespace_name      - name of tablespace in which segment resides
  --   header_relative_file - relative file number of segment segment header
  --   header_block         - block number of segment segment header
  --   verify_option        - SEGMENT_VERIFY_EXTENTS  or
  --                          SEGMENT_VERIFY_EXTENTS_GLOBAL
  --
  procedure segment_corrupt(
        tablespace_name         in    varchar2  ,
        header_relative_file    in    positive ,
        header_block            in    positive ,
        corrupt_option          in    positive  DEFAULT SEGMENT_MARK_CORRUPT
                  );
  --
  --  Marks the segment corrupt/valid so that appropriate error recovery
  --  can be done/skipped. Only for segments already temporary.
  --  Input arguments:
  --   tablespace_name      - name of tablespace in which segment resides
  --   header_relative_file - relative file number of segment segment header
  --   header_block         - block number of segment segment header
  --   corrupt_option       - SEGMENT_MARK_CORRUPT  or
  --                          SEGMENT_MARK_VALID
  --
  procedure segment_drop_corrupt(
        tablespace_name         in    varchar2  ,
        header_relative_file    in    positive ,
        header_block            in    positive 
                        );
  --
  --  Drops a segment currently marked corrupt (without reclaiming space)
  --  Input arguments:
  --   tablespace_name      - name of tablespace in which segment resides
  --   header_relative_file - relative file number of segment segment header
  --   header_block         - block number of segment segment header
  --
  procedure segment_dump(
        tablespace_name         in    varchar2 ,
        header_relative_file    in    positive ,
        header_block            in    positive ,
        dump_option                in    positive  DEFAULT SEGMENT_DUMP_EXTENT_MAP
                        );

  --
  --  Dumps the extent map of a given segment
  --  Input arguments:
  --   tablespace_name      - name of tablespace in which segment resides
  --   header_relative_file - relative file number of segment segment header
  --   header_block         - block number of segment segment header
  --   dump_option          - SEGMENT_DUMP_EXTENT_MAP
  --
  
  procedure tablespace_verify(
        tablespace_name         in    varchar2 ,
        verify_option                in    positive DEFAULT TABLESPACE_VERIFY_BITMAP
                        );
  --
  --  Verifies that the extent maps and the bitmaps are in sync.
  --  Input arguments:
  --   tablespace_name      - name of tablespace
  --   verify_option        - TABLESPACE_VERIFY_BITMAP
  --
  procedure tablespace_fix_bitmaps(
        tablespace_name         in    varchar2 ,
        dbarange_relative_file  in    positive ,
        dbarange_begin_block    in    positive ,
        dbarange_end_block      in    positive ,
        fix_option                in    positive
                        );
  --
  --  Marks the appropriate dba range (extent) as free/used in bitmap
  --  Input arguments:
  --   tablespace_name         - name of tablespace
  --   dbarange_relative_file  - relative fileno of dba range (extent)
  --   dbarange_begin_block    - block number of beginning of extent
  --   dbarange_end_block      - block number (inclusive) of end of extent
  --   fix_option              - TABLESPACE_EXTENT_MAKE_FREE or
  --                             TABLESPACE_EXTENT_MAKE_USED
  --
  procedure tablespace_rebuild_bitmaps(
        tablespace_name         in    varchar2 ,
        bitmap_relative_file    in    positive   DEFAULT NULL,
        bitmap_block            in    positive   DEFAULT NULL
                        );
  --
  --  Rebuilds the appropriate bitmap(s). If no bitmap block dba specified then
  --  rebuilds all bitmaps for the given tablespace
  --  Input arguments:
  --   tablespace_name        - name of tablespace
  --   bitmap_relative_file   - relative file number of bitmap block to rebuild
  --   bitmap_block           - block number of bitmap block to rebuild
  --

--
  procedure tablespace_rebuild_quotas(
        tablespace_name         in    varchar2 
                        );
  --
  --  Rebuilds quotas for given tablespace
  --  Input arguments:
  --   tablespace_name        - name of tablespace
  --

--
  procedure tablespace_migrate_from_local(
        tablespace_name         in    varchar2 
                        );
  --
  --  Migrates a locally-managed tablespace to dictionary managed
  --  Input arguments:
  --   tablespace_name        - name of tablespace

--
  procedure tablespace_migrate_to_local(
        tablespace_name         in    varchar2,
        unit_size               in    positive DEFAULT NULL,
        rfno                    in    positive DEFAULT NULL 
                        );
  --
  --  Migrates a dictionary-managed tablespace to locally managed
  --  Input arguments:
  --   tablespace_name        - name of tablespace
  --   unit_size              - bitmap unit size for the tablespace
  --

--
   procedure tablespace_relocate_bitmaps(
         tablespace_name         in     varchar2,
         filno                   in     positive,
         blkno                   in     positive);
  
  --
  --  Tablespace relocate bitmaps to a different location
  --  Input arguments:
  --   tablespace_name        - name of tablespace
  --

--
   procedure tablespace_fix_segment_states(
        tablespace_name         in     varchar2);
  
  -- 
  -- Tablespace fix segment states. During migration of tablespaces
  -- the segments are put in a transition state. If migration fails,
  -- the state of the segments can be corrected by calling this 
  -- procedure. This procedure should be called if migration failed
  -- and the user tries to run in an incompatible mode.

--
   procedure tablespace_fix_segment_extblks(
        tablespace_name         in     varchar2);
  
    --
    -- Tablespace fix segment extents and blocks based on segment 
    -- header entries

--
   procedure tablespace_dump_bitmaps(
        tablespace_name         in     varchar2);
 
    --
    -- Tablespace space header of files

  function segment_number_extents(
        header_tablespace_id    in    natural ,
        header_relative_file    in    positive ,
        header_block            in    positive ,
        segment_type            in    positive ,
        buffer_pool_id          in    natural ,
        dictionary_flags        in    natural ,
        data_object_id          in    number,
        dictionary_extents      in    number
                        ) return pls_integer;
  pragma RESTRICT_REFERENCES(segment_number_extents,WNDS,WNPS,RNPS);
  --
  -- Returns the number of extents which belong to the segment. Will return
  -- NULL if segment has disappeared. IS NOT to be used for any other
  -- purposes but by the views which need it and are sure that there info
  -- is correct. Else internal errors will abound
  --
  function segment_number_blocks(
        header_tablespace_id    in    natural ,
        header_relative_file    in    positive ,
        header_block            in    positive ,
        segment_type            in    positive ,
        buffer_pool_id          in    natural ,
        dictionary_flags        in    natural ,
        data_object_id          in    number,
        dictionary_blocks       in    number
                        ) return pls_integer;
  pragma RESTRICT_REFERENCES(segment_number_blocks,WNDS,WNPS,RNPS);
  --
  -- Returns the number of blocks which belong to the segment. Will return
  -- NULL if segment has disappeared. IS NOT to be used for any other
  -- purposes but by the views which need it and are sure that there info
  -- is correct. Else internal errors will abound
  --
  procedure segment_moveblocks(
        segment_owner           in    varchar2,
        segment_name            in    varchar2,
        partition_name          in    varchar2,
        segment_type            in    varchar2,
        group_id                in    natural,
        minimum_size                in    positive,
        move_count                  in    positive,
        pause_time                  in    natural,
        iterations                  in    positive
                        );
  --
  --  Moves blocks from the segment header to the process freelist
  --  It only moves blocks if the list is shorter than the minimum
  --  size for the move_count blocks
  --   segment_owner        - name of the object's owner
  --   segment_name         - name of the object
  --   partition_name       - name of the partition (NULL if not partitioned)
  --   segment_type         - object type (TABLE, INDEX, etc - see DBMS_SPACE)
  --   group_id             - freelist group (0 for the segment header)
  --   minimum_size         - do not move if process free list is longer 
  --   move_count           - move up to this number of blocks
  --   pause_time           - pause between loop iterations
  --   iterations           - number of iterations (infinite if NULL)
  --  
  


  procedure assm_segment_verify(
    segment_owner           in varchar2,
    segment_name            in varchar2,
    segment_type            in varchar2,
    partition_name          in varchar2,
    verify_option           in positive default SEGMENT_VERIFY_BASIC ,
    attrib                  in positive default NULL);

  --
    
  --  Verifies the consistency of the segment
  --  Input arguments:
  --   segment_owner        - owner
  --   segment_name         - name of the segment
  --   segment_type         - type of segment
  --   partition_name       - name of partition default NULL
  --   verify_option        - one of SEGMENT_VERIFY_BASIC, DEEP , SPECIFIC
  --   attrib               - used when option SEGMENT_VERIFY_SPECIFIC
 
 
  procedure nglob_segment_verify(
    segment_owner           in varchar2,
    segment_name            in varchar2,
    segment_type            in varchar2,
    partition_name          in varchar2,
    verify_option           in positive default SEGMENT_VERIFY_BASIC ,
    attrib                  in positive default NULL);

  --

  --  Verifies the consistency of the segment
  --  Input arguments:
  --   segment_owner        - owner
  --   segment_name         - name of the segment
  --   segment_type         - type of segment
  --   partition_name       - name of partition default NULL
  --   verify_option        - one of SEGMENT_VERIFY_BASIC, DEEP , SPECIFIC
  --   attrib               - used when option SEGMENT_VERIFY_SPECIFIC
 
  procedure assm_tablespace_verify(
    tablespace_name           in varchar2,
    ts_option                 in positive,
    segment_option            in positive default NULL);

  --
  --  Verifies that the tablespace consistency.
  --  Input arguments:
  --   tablespace_name      - name of tablespace
  --   ts_option            - TS_VERIFY_BITMAPS, TS_VERIFY_DEEP, TS_VERIFY_SEGMENTS
  --   segment option       - used when TS_VERIFY_SEGMENTS, one of SEGMENT_VERIFY_DEEP, SPECIFIC
  --


  function assm_segment_synchwm(
    segment_owner           in varchar2,
    segment_name            in varchar2,
    segment_type            in varchar2,
    partition_name          in varchar2 default NULL,
    check_only              in number default 1
    ) return pls_integer;

  --
  --  Synchronize HWMs of the ASSM segment
  --  Input arguments:
  --   segment_owner        - owner
  --   segment_name         - name of the segment
  --   segment_type         - type of segment
  --   partition_name       - name of partition default NULL
  --   check_only           - whether it is check only default YES
  --  Output:
  --   Return TRUE if the segment requires HWM synchronization
  --   Return FALSE otherwise

  procedure flush_lobsegment_stats;

  procedure purge_lobsegment_stats;

  
  -------------------------------------------------------------------------
  -- PROCEDURE securefile_segment_repair
  -------------------------------------------------------------------------

  -- segment repair option: repair metadata blocks
  SEGMENT_REPAIR_METADATA     constant positive := 1;

  procedure segment_repair(
    segment_owner         in varchar2,
    segment_name          in varchar2,
    segment_type          in varchar2,
    partition_name        in varchar2 default NULL,
    repair_option         in number default SEGMENT_REPAIR_METADATA
    );

  --
  --  Description:
  --    Repair SecureFile segment
  --  Input parameters:
  --    segment_owner     - owner
  --    segment_name      - name of the LOB segment
  --    segment_type      - type of segment
  --                        values: 'LOB', 'LOB PARTITION', 'LOB SUBPARTITION'
  --    partition_name    - name of the LON partition segment
  --                        default: NULL
  --    repair_option     - segment repair option, 
  --                        values: see SEGMENT_REPAIR_*** definitions
  --                        default: SEGMENT_REPAIR_METADATA
  --  Note:
  --    This function is only used internally and does not require 
  --    documentation.


  -------------------------------------------------------------------------
  -- PROCEDURE segment_extend
  -------------------------------------------------------------------------
  
  procedure segment_extend(
    segment_owner         in varchar2,
    segment_name          in varchar2,
    segment_type          in varchar2,
    partition_name        in varchar2 default NULL,
    target_size           in number default 1
    );

  --
  --  Description:
  --    SecureFile segment extend in background
  --  Input parameters:
  --    segment_owner     - owner
  --    segment_name      - name of the LOB segment
  --    segment_type      - type of segment
  --                        values: 'LOB', 'LOB PARTITION', 'LOB SUBPARTITION'
  --    partition_name    - name of the LOB partition segment
  --                        default: NULL
  --    target_size       - segment target size in GB
  --  Note:
  --    This function is only used internally and does not require 
  --    documentation.


  -------------------------------------------------------------------------
  -- PROCEDURE drop_empty_segments
  -------------------------------------------------------------------------
  
  procedure drop_empty_segments(
    schema_name           in varchar2 default NULL,
    table_name            in varchar2 default NULL,
    partition_name        in varchar2 default NULL
    );

  --
  --  Description:
  --    Drop segments from empty table(s)/table fragments and dependent
  --    objects.
  --  Input parameters:
  --    schema_name       - schema name, default: NULL
  --    table_name        - table name, default: NULL
  --    partition_name    - partition name, default: NULL
  --  Note:
  --    Given a schema name, this procedure scans all tables in the schema
  --    For each table, if the table or any of its fragments are found to be
  --    empty, and the table satisfies certain criteria [restrictions being
  --    the same as those imposed by segment creation on demand], the empty
  --    fragments and associated index segments are dropped.  A subsequent
  --    insert will create segments with the same properties.
  --    Optionally,
  --    a. no schema name may be specified in which case we would scan
  --       tables belonging to all schemas
  --    b. both schema_name and table_name may be specified to do this
  --       operation on one particular table
  --    c. all three arguments may be supplied, in which case we will
  --       restrict this operation to that partition and its dependent
  --       objects.


  -------------------------------------------------------------------------
  -- PROCEDURE materialize_deferred_segments
  -------------------------------------------------------------------------
  
  procedure materialize_deferred_segments(
    schema_name           in varchar2 default NULL,
    table_name            in varchar2 default NULL,
    partition_name        in varchar2 default NULL
    );

  --
  --  Description:
  --    Materialize segments for tables/table fragments with deferred
  --    segment creation (and their dependent objects)
  --  Input parameters:
  --    schema_name       - schema name, default: NULL
  --    table_name        - table name, default: NULL
  --    partition_name    - partition name, default: NULL
  --  Note:
  --    Given a schema name, this procedure scans all tables in the schema.
  --    For each table, if the deferred/delayed segment property is set for
  --    the table or any of its fragments, a new segment is created for
  --    those fragments and their dependent objects.
  --    Optionally,
  --    a. no schema name may be specified in which case we would scan tables
  --       belonging to all schemas
  --    b. both schema_name and table_name may be specified to do this
  --       operation on one particular table
  --    c. all three arguments may be supplied, in which case we will
  --       restrict this operation to that partition and its dependent
  --       objects


  -------------------------------------------------------------------------
  -- PROCEDURE materialize_deferred_with_opt
  -------------------------------------------------------------------------
  
  procedure materialize_deferred_with_opt(
    schema_name           in varchar2 default NULL,
    table_name            in varchar2 default NULL,
    partition_name        in varchar2 default NULL,
    partitioned_only      in boolean default FALSE
    );

  --
  --  Description:
  --    Materialize segments for tables/table fragments with deferred
  --    segment creation (and their dependent objects), with an additional
  --    option.
  --  Input parameters:
  --    schema_name       - schema name, default: NULL
  --    table_name        - table name, default: NULL
  --    partition_name    - partition name, default: NULL
  --    partitioned_only  - apply materialize procedure on partitioned
  --                        tables only, default: FALSE
  --  Note:
  --    The materialize_deferred_segments procedure is a wrapper around
  --    this.  This procedure is required for downgrading (from 11.2.0.2)
  --    to materialize segments for partitioned tables only.  The
  --    partitioned_only argument supports this limited behavior.


end;
/

create or replace public synonym dbms_space_admin for sys.dbms_space_admin
/

-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_SPACE_ADMIN_LIB TRUSTED AS STATIC;
/
