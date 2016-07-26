Rem
Rem $Header: rdbms/admin/dbmsspu.sql /st_rdbms_11.2.0/2 2010/08/05 15:04:35 smuthuli Exp $
Rem
Rem dbmsspu.sql
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsspu.sql - Space Utility procedures
Rem
Rem    DESCRIPTION
Rem      Contains utility procedures various space layer 
Rem
Rem    NOTES
Rem      Must be run when connected to SYS or INTERNAL.
Rem
Rem      The procedural option is needed to use these facilities.
Rem
Rem      All of the packages below run with the privileges of calling user,
Rem      rather than the package owner ('sys').
Rem
Rem      The dbms_utility package is run-as-caller (psdicd.c) only for
Rem      its name_resolve, compile_schema and analyze_schema
Rem      procedures.  This package is not run-as-caller
Rem      w.r.t. SQL (psdpgi.c) so that the SQL works correctly (runs as
Rem      SYS).  The privileges are checked via dbms_ddl.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    smuthuli    07/21/10 - Backport smuthuli_bug-9582487 from main
Rem    smuthuli    03/18/10 - Add procedure to parse the segadvisor output
Rem    smuthuli    07/31/06 - add space_usage for NGLOBS
Rem    baleti      03/05/05 - Add lob column name 
Rem    nmukherj    01/14/05 - put isDatafileDroppable checks
Rem    smuthuli    06/24/04 - smuthuli_lrg_asa
Rem    smuthuli    06/17/04 - Created
Rem
-- These two types will be used by CREATE_TABLE_COST procedure
drop type create_table_cost_columns
/
drop type create_table_cost_colinfo
/
create type create_table_cost_colinfo is object
  (
                         col_type varchar(200),
                         col_size number
  )
/
create type create_table_cost_columns is varray(50000) of create_table_cost_colinfo
/
create  type tablespace_list is varray (64000) of number
/
grant execute on create_table_cost_columns to public
/
grant execute on create_table_cost_colinfo to public
/
grant execute on tablespace_list to public
/

create or replace package dbms_space AUTHID CURRENT_USER as
  ------------
  --  OVERVIEW
  --
  --  This package provides segment space information not currently
  --  available through the standard views.

  --  SECURITY
  --
  --  The execution privilege is granted to PUBLIC. Procedures in this
  --  package run under the caller security. The user must have ANALYZE
  --  privilege on the object.

  OBJECT_TYPE_TABLE                  constant positive := 1;
  OBJECT_TYPE_NESTED_TABLE           constant positive := 2;
  OBJECT_TYPE_INDEX                  constant positive := 3;
  OBJECT_TYPE_CLUSTER                constant positive := 4;
  OBJECT_TYPE_LOB_INDEX              constant positive := 5;
  OBJECT_TYPE_LOBSEGMENT             constant positive := 6;
  OBJECT_TYPE_TABLE_PARTITION        constant positive := 7;
  OBJECT_TYPE_INDEX_PARTITION        constant positive := 8;
  OBJECT_TYPE_TABLE_SUBPARTITION     constant positive := 9;
  OBJECT_TYPE_INDEX_SUBPARTITION     constant positive := 10;
  OBJECT_TYPE_LOB_PARTITION          constant positive := 11;
  OBJECT_TYPE_LOB_SUBPARTITION       constant positive := 12;
  OBJECT_TYPE_MV                     constant positive := 13;
  OBJECT_TYPE_MVLOG                  constant positive := 14;
  OBJECT_TYPE_ROLLBACK_SEGMENT       constant positive := 15;

  SPACEUSAGE_EXACT                   constant positive := 16;
  SPACEUSAGE_FAST                    constant positive := 17;

  ----------------------------

  ----------------------------
  --  PROCEDURES AND FUNCTIONS
  --
  procedure unused_space(segment_owner IN varchar2, 
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         total_blocks OUT number,
                         total_bytes OUT number,
                         unused_blocks OUT number,
                         unused_bytes OUT number,
                         last_used_extent_file_id OUT number,
                         last_used_extent_block_id OUT number,
                         last_used_block OUT number,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(unused_space,WNDS);

  --  Returns information about unused space in an object (table, index,
  --    or cluster).
  --  Input arguments:
  --   segment_owner  
  --      schema name of the segment to be analyzed
  --   segment_name  
  --      object name of the segment to be analyzed
  --   partition_name  
  --      partition name of the segment to be analyzed
  --   segment_type  
  --      type of the segment to be analyzed (TABLE, INDEX, or CLUSTER)
  --  Output arguments:
  --   total_blocks  
  --      total number of blocks in the segment
  --   total_bytes  
  --      the same as above, expressed in bytes
  --   unused_blocks  
  --      number of blocks which are not used 
  --   unused_bytes  
  --      the same as above, expressed in bytes
  --   last_used_extent_file_id 
  --      the file ID of the last extent which contains data
  --   last_used_extent_block_id 
  --      the block ID of the last extent which contains data
  --   last_used_block  
  --      the last block within this extent which contains data
  procedure free_blocks (segment_owner IN varchar2, 
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         freelist_group_id IN number,
                         free_blks OUT number,
                         scan_limit IN number DEFAULT NULL,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(free_blocks,WNDS);

  --  Returns information about free blocks in an object (table, index,
  --    or cluster).
  --  Input arguments:
  --   segment_owner  
  --      schema name of the segment to be analyzed
  --   segment_name  
  --      name of the segment to be analyzed
  --   partition_name  
  --      partition name of the segment to be analyzed
  --   segment_type  
  --      type of the segment to be analyzed (TABLE, INDEX, or CLUSTER)
  --   freelist_group_id  
  --      freelist group (instance) whose free list size is to be computed
  --   scan_limit (optional)
  --      maximum number of free blocks to read
  --  Output arguments:
  --   free_blks  
  --      count of free blocks for the specified group

  --  PROCEDURES AND FUNCTIONS
  --
  procedure space_usage(segment_owner IN varchar2,
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         unformatted_blocks OUT number,
                         unformatted_bytes OUT number,
                         fs1_blocks OUT number,
                         fs1_bytes  OUT number,
                         fs2_blocks OUT number,
                         fs2_bytes  OUT number,
                         fs3_blocks OUT number,
                         fs3_bytes  OUT number,
                         fs4_blocks OUT number,
                         fs4_bytes  OUT number,
                         full_blocks OUT number,
                         full_bytes OUT number,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(space_usage,WNDS);

  --  Returns information about space occupation in an object (table, index,
  --    or cluster).
  --  Input arguments:
  --   segment_owner
  --      schema name of the segment to be analyzed
  --   segment_name
  --      object name of the segment to be analyzed
  --   partition_name
  --      partition name of the segment to be analyzed
  --   segment_type
  --      type of the segment to be analyzed (TABLE, INDEX, or CLUSTER)
  --  Output arguments:
  --   unformatted_blocks
  --      total number of blocks that are unformatted
  --   unformatted_bytes
  --      the same as above, expressed in bytes
  --   fs1_blocks
  --      number of blocks that have atleast 0 to 25% free space.
  --   fs1_bytes
  --      same as above, expressed in bytes
  --   fs2_blocks
  --      number of blocks that have atleast 25% to 50% free space.
  --   fs2_bytes
  --      same as above, expressed in bytes
  --   fs3_blocks
  --      number of blocks that have atleast 50% to 75% free space.
  --   fs3_bytes
  --      same as above, expressed in bytes
  --   fs4_blocks
  --      number of blocks that have atleast 75% to 100% free space.
  --   fs4_bytes
  --      same as above, expressed in bytes
  --   full_blocks
  --      total number of blocks that are full in the segment
  --   full_bytes
  --      the same as above, expressed in bytes

  procedure space_usage (segment_owner IN varchar2,
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         segment_size_blocks OUT number,
                         segment_size_bytes OUT number,
                         used_blocks OUT number,
                         used_bytes OUT number,
                         expired_blocks OUT number,
                         expired_bytes OUT number,
                         unexpired_blocks OUT number,
                         unexpired_bytes OUT number,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(space_usage,WNDS);
  --  Returns information about space usage in Securefile segment
  --  Input arguments:
  --   segment_owner
  --      schema name of the segment to be analyzed
  --   segment_name
  --      object name of the segment to be analyzed
  --   partition_name
  --      partition name of the segment to be analyzed
  --   segment_type
  --      type of the segment to be analyzed 
  --  Output arguments:
  --   segment_size_blocks
  --      number of blocks in the segment
  --   segment_size_bytes
  --      number of bytes in the segment
  --   used_blocks
  --      number of used blocks in the segment
  --   used_bytes
  --      number of used bytes in the segment
  --   expired_blocks
  --      number of expired blocks in the segment
  --   expired_bytes
  --      number of expired bytes in the segment
  --   unexpired_blocks
  --      number of unexpired blocks in the segment
  --   unexpired_bytes
  --      number of unexpired bytes in the segment

  procedure space_usage (segment_owner IN varchar2,
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         suoption IN number,
                         segment_size_blocks OUT number,
                         segment_size_bytes OUT number,
                         used_blocks OUT number,
                         used_bytes OUT number,
                         expired_blocks OUT number,
                         expired_bytes OUT number,
                         unexpired_blocks OUT number,
                         unexpired_bytes OUT number,
                         partition_name IN varchar2 DEFAULT NULL
                         );
  pragma restrict_references(space_usage,WNDS);
  --  Returns information about space usage in Securefile segment
  --  Optionally gets space usage faster by caching and retreiving 
  --  data from memory.
  --
  --  Input arguments:
  --   segment_owner
  --      schema name of the segment to be analyzed
  --   segment_name
  --      object name of the segment to be analyzed
  --   partition_name
  --      partition name of the segment to be analyzed
  --   segment_type
  --      type of the segment to be analyzed
  --   suoption
  --      SPACEUSAGE_EXACT: Computes space usage exhaustively
  --      SPACEUSAGE_FAST: Retrieves values from in-memory statistics
  --
  --  Output arguments:
  --   segment_size_blocks
  --      number of blocks in the segment
  --   segment_size_bytes
  --      number of bytes in the segment
  --   used_blocks
  --      number of used blocks in the segment
  --   used_bytes
  --      number of used bytes in the segment
  --   expired_blocks
  --      number of expired blocks in the segment
  --   expired_bytes
  --      number of expired bytes in the segment
  --   unexpired_blocks
  --      number of unexpired blocks in the segment
  --   unexpired_bytes
  --      number of unexpired bytes in the segment


  procedure isDatafileDroppable_Name(
          filename               in varchar2,
          value                  out number);
  pragma restrict_references(isDatafileDroppable_Name,WNDS);

  -- Checks whether datafile is droppable
  -- Input args:
  -- filename               - full filename of datafile
  -- value                  - 1 if droppable, 0 if not droppable


  procedure create_table_cost (
                         tablespace_name IN varchar2,
                         avg_row_size IN number,
                         row_count IN number,
                         pct_free IN number,
                         used_bytes OUT number,
                         alloc_bytes OUT number
                         );
  pragma restrict_references(create_table_cost,WNDS);

  procedure create_table_cost (
                         tablespace_name IN varchar2,
                         colinfos IN create_table_cost_columns,
                         row_count IN number,
                         pct_free IN number,
                         used_bytes OUT number,
                         alloc_bytes OUT number
                         );
  pragma restrict_references(create_table_cost,WNDS);


  procedure create_index_cost (
                         ddl IN varchar2,
                         used_bytes OUT number,
                         alloc_bytes OUT number,
                         plan_table IN varchar2 DEFAULT NULL
                         );


  function verify_shrink_candidate (
                         segment_owner IN varchar2, 
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         shrink_target_bytes IN number,
                         partition_name IN varchar2 DEFAULT NULL
                         ) return boolean;
  pragma restrict_references(verify_shrink_candidate,WNDS);

  type verify_shrink_row is record
  (
    status     number
  );
  type verify_shrink_table is table of verify_shrink_row;

  function verify_shrink_candidate_tbf (
                         segment_owner IN varchar2, 
                         segment_name IN varchar2,
                         segment_type IN varchar2,
                         shrink_target_bytes IN number,
                         partition_name IN varchar2 DEFAULT NULL
                         ) return verify_shrink_table pipelined;
  pragma restrict_references(verify_shrink_candidate_tbf,WNDS);

  --  Primary task is to check if shrinking a segment by the given
  --  number of bytes would result in an extent being freed or an
  --  extent being truncated, and if so return true.  If the segment
  --  is not bitmap managed, then the function also returns false.
  --  However, to properly check for proper segment type and segment
  --  attributes (e.g. row movement enabled) to allow shrink, the
  --  user is expected to use the ALTER ... SHRINK CHECK statement.
  --
  --  Input arguments:
  --   segment_owner
  --      schema name of the segment to be analyzed
  --   segment_name
  --      object name of the segment to be analyzed
  --   partition_name
  --      partition name of the segment to be analyzed
  --   segment_type
  --      type of the segment to be analyzed (TABLE, INDEX, or CLUSTER)
  --  Returns:
  --   True if shrinking the segment will likely return space to the
  --   tablespace containing the segment.

  -- EM Special. Used to parse the data returned by segment advisor.
  procedure parse_space_adv_info(info                  varchar2,
                                 used_space        out varchar2,
                                 allocated_space   out varchar2,
                                 reclaimable_space out varchar2);
  pragma restrict_references(parse_space_adv_info,WNDS);

  procedure object_space_usage (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         sample_control IN number,
                         space_used OUT number,
                         space_allocated OUT number,
                         chain_pcent     OUT number,
                         partition_name IN varchar2 DEFAULT NULL,
                         preserve_result IN boolean DEFAULT TRUE,
                         timeout_seconds IN number DEFAULT NULL
                         );
  pragma restrict_references(object_space_usage,WNDS);

  type object_space_usage_row is record
  (
    space_used       number,
    space_allocated  number,
    chain_pcent      number
  );
  type object_space_usage_table is table of object_space_usage_row;

  function object_space_usage_tbf (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         sample_control IN number,
                         partition_name IN varchar2 DEFAULT NULL,
                         preserve_result IN varchar2 DEFAULT 'TRUE',
                         timeout_seconds IN number DEFAULT NULL
                         ) return object_space_usage_table pipelined;
  pragma restrict_references(object_space_usage_tbf,WNDS);


  type asa_reco_row is record
  (
    tablespace_name       varchar2(30),
    segment_owner         varchar2(30),
    segment_name          varchar2(30),
    segment_type          varchar2(18),
    partition_name        varchar2(30),
    allocated_space       number,
    used_space            number,
    reclaimable_space     number,
    chain_rowexcess       number,
    ioreqpm               number,
    iowaitpm              number,
    iowaitpr              number,
    recommendations       varchar2(1000),
    c1                    varchar2(1000),
    c2                    varchar2(1000),
    c3                    varchar2(1000),
    task_id               number,
    mesg_id               number
  );
  type asa_reco_row_tb is table of asa_reco_row;

  function asa_recommendations (
                         all_runs    in varchar2 DEFAULT 'TRUE',
                         show_manual in varchar2 DEFAULT 'TRUE',
                         show_findings in varchar2 DEFAULT 'FALSE'
                         ) return asa_reco_row_tb pipelined;


  --
  -- DBFS_DF : The function returns the free space in the 
  -- storage used by the tablespaces. 
  -- PARAMETERS : userid - user id of the user that can use the tablespaces
  --              ntbs   - number of tablespaces 
  --              ints_list - list of tablespace ids
  -- RETURNS : Sum of free space in KB allocatable in the list of tablespaces
  -- Free space in each tablespace is the number of KB available to theuser
  -- for creation of new objects and growth of existing objects.
  --
  -- It does not account for space already allocated to the segments
  -- in the tablespaces.
  --
  -- Functionality not supported for the following
  -- 1. Undo tablespaces
  -- 2. Temporary tablespaces
  -- 3. Dictionary managed tablespaces
  -- 4. Tablespaces with autoextensible files in file system storage.
  -- The return value for unsupported tablespaces will be 0.
  -- 

  function dbfs_df (
                  userid  IN number,
                  ntbs    IN number,
                  ints_list IN tablespace_list) return number;

  -- content of one row in dependent_segments table.
  type object_dependent_segment is record (
                       segment_owner   varchar2(100),
                       segment_name    varchar2(100),
                       segment_type    varchar2(100),
                       tablespace_name varchar2(100),
                       partition_name  varchar2(100),
                       lob_column_name  varchar2(100)
                       );

  -- dependent_segments_table is a table of dependent_segment records. There
  -- is one record for all the dependent segments of the object

  type dependent_segments_table is table of object_dependent_segment;

  function object_dependent_segments(
        objowner IN varchar2,
        objname IN varchar2,
        partname IN varchar2,
        objtype IN number
        ) return dependent_segments_table pipelined;
  -- pragma RESTRICT_REFERENCES(object_dependent_segments,WNDS,WNPS,RNPS);

  -- objowner  - owner of the object
  -- objname   - object name
  -- partname   - name of the partition or subpartition
  -- objtype   - object name space

  -- object_growth_trend_row and object_growth_trend_table are used
  --   by the object_growth_trend table function to describe its output
  type object_growth_trend_row is record (
                         timepoint      timestamp,
                         space_usage    number,
                         space_alloc    number,
                         quality        varchar(20)
                         );

  type object_growth_trend_table is table of object_growth_trend_row;

  -- object_growth_swrf_row,  object_growth_swrf_table,
  --   object_growth_swrf_cursor, object_growth_trend_curtab,
  --   and object_growth_trend_test_swrf are internal to the
  --   implementation of object_growth_trend but need to be declared
  --   here instead of in the private package body.  These internal types
  --   and procedures do not expose any internal information to the user.

  type object_growth_swrf_row is record
  (
                         timepoint timestamp,
                         delta_space_usage number,
                         delta_space_alloc number,
                         total_space_usage number,
                         total_space_alloc number,
                         instance_number number,
                         objn number
  );
  
  type object_growth_swrf_table is table of object_growth_swrf_row;
  
  type object_growth_swrf_cursor is ref cursor return object_growth_swrf_row;

  function object_growth_trend_i_to_s (
                         interv in dsinterval_unconstrained
                         ) return number;
  
  function object_growth_trend_s_to_i (
                         secsin in number
                         ) return dsinterval_unconstrained;
  
  function object_growth_trend_curtab
                         return object_growth_trend_table pipelined;
  
  function object_growth_trend_swrf (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         partition_name IN varchar2 DEFAULT NULL
                         ) return object_growth_swrf_table pipelined;


  function object_growth_trend (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         partition_name IN varchar2 DEFAULT NULL,
                         start_time IN timestamp DEFAULT NULL,
                         end_time IN timestamp DEFAULT NULL,
                         interval IN dsinterval_unconstrained DEFAULT NULL,
                         skip_interpolated IN varchar2 DEFAULT 'FALSE',
                         timeout_seconds IN number DEFAULT NULL,
                         single_datapoint_flag IN varchar2 DEFAULT 'TRUE'
                         ) return object_growth_trend_table pipelined;


  function object_growth_trend_cur (
                         object_owner IN varchar2,
                         object_name IN varchar2,
                         object_type IN varchar2,
                         partition_name IN varchar2 DEFAULT NULL,
                         start_time IN timestamp DEFAULT NULL,
                         end_time IN timestamp DEFAULT NULL,
                         interval IN dsinterval_unconstrained DEFAULT NULL,
                         skip_interpolated IN varchar2 DEFAULT 'FALSE',
                         timeout_seconds IN number DEFAULT NULL
                         ) return sys_refcursor;

  procedure auto_space_advisor_job_proc;

end;
/
show errors;
create or replace public synonym dbms_space for sys.dbms_space
/
grant execute on dbms_space to public
/
