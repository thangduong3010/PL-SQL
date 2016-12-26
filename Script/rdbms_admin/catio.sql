REM 
REM $Header: catio.sql 12-jul-2001.08:20:20 kquinn Exp $ 
REM 
REM Copyright (c) 1991, 2001, Oracle Corporation.  All rights reserved.  
REM    NAME
REM      catio.sql - I/O per table statistics
REM    DESCRIPTION
REM      Collect I/O per table (actually object) statistics by statistical
REM      sampling
REM    NOTES
REM      This works by sampling the buffer at the end of the buffer cache LRU
REM      list.  The theory is that this buffer was read in at some point and
REM      therefore counts as a an IO.  All buffers that are read in will
REM      eventually find themselves at the end of the LRU list. There is a
REM      stored procedure that periodically samples the buffer at the end of
REM      the lru list and a view that generates a database object name given
REM      the block number of the buffer.
REM
REM      Note that this file will tell you the distribution of IOs 
REM      between tables, but it will not tell you the exact number of IOs.
REM
REM      The DBMSLOCK file must be loaded before this is loaded in order to
REM      get the definition of sleep().
REM    MODIFIED   (MM/DD/YY)
Rem     bzane      07/08/01  - Bug 1308270: eliminate duplicates in undo$
Rem     kquinn     07/12/01  - 1070573: Correct sample_io code
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     nmacnaug   09/19/97 -  fix type error
Rem     nmacnaug   09/03/96 -  nxt_lru renamed to nxt_repl
Rem     atsukerm   07/22/96 -  change type for partitioned objects.
Rem     atsukerm   06/13/96 -  fix EXTENT_TO_OBJECT view.
Rem     mmonajje   05/24/96 -  Replace type col name with type#
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     atsukerm   02/29/96 -  space support for partitions.
Rem     atsukerm   02/05/96 -  fix extent_to_object definition.
Rem     atsukerm   01/03/96 -  tablespace-relative DBAs.
Rem     aho        11/13/95 -  iot
Rem     hrizvi     02/09/93 -  apply changes to x$bh 
REM     jloaiza    11/03/92 -  Creation 



/* Map an extent to a base object (table, index, ...) */

create or replace view extent_to_object as
  select file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , obj$.name name 
       , NULL partition_name
       , 'TABLE' kind
  from tab$, uet$, obj$, file$
  where bitand(tab$.property, 1024) = 0          /* exclude clustered tables */
    and tab$.file# = uet$.segfile#
    and tab$.block# = uet$.segblock#
    and tab$.ts# = uet$.ts#
    and tab$.obj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , obj$.name name 
       , obj$.subname partition_name
       , 'TABLE PARTITION' kind
  from tabpart$, uet$, obj$, file$
  where tabpart$.file# = uet$.segfile#
    and tabpart$.block# = uet$.segblock#
    and tabpart$.ts# = uet$.ts#
    and tabpart$.obj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select distinct
         file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , obj$.name name 
       , NULL partition_name
       , 'CLUSTER' kind
  from tab$, uet$, obj$, file$
  where bitand(tab$.property, 1024) <> 0
    and tab$.file# = uet$.segfile#
    and tab$.block# = uet$.segblock#
    and tab$.ts# = uet$.ts#
    and tab$.bobj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb 
       , obj$.name name 
       , NULL partition_name
       , 'INDEX' kind
  from ind$, uet$, obj$, file$
  where ind$.file# = uet$.segfile#
    and ind$.block# = uet$.segblock#
    and ind$.ts# = uet$.ts#
    and ind$.obj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file# 
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb 
       , obj$.name name 
       , obj$.subname partition_name
       , 'INDEX PARTITION' kind
  from indpart$, uet$, obj$, file$
  where indpart$.file# = uet$.segfile#
    and indpart$.block# = uet$.segblock#
    and indpart$.ts# = uet$.ts#
    and indpart$.obj# = obj$.obj#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file#
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , undo$.name name
       , NULL partition_name
       , 'ROLLBACK SEGMENT' kind
  from undo$, uet$, file$
  where undo$.status$ != 1
    and undo$.file# = uet$.segfile#
    and undo$.block# = uet$.segblock#
    and undo$.ts# = uet$.ts#
    and file$.ts# = uet$.ts#
    and file$.relfile# = uet$.file#
union all
  select file$.file# file#
       , uet$.block# lowb
       , uet$.block# + uet$.length - 1 highb
       , 'TEMP SEGMENT' name
       , NULL partition_name
       , 'TEMP SEGMENT' kind
  from uet$, seg$, file$
  where seg$.file# = uet$.segfile#
   and  seg$.block# = uet$.block#
   and  seg$.ts# = uet$.ts#
   and  seg$.type# = 3
   and file$.ts# = uet$.ts#
   and file$.relfile# = uet$.file#
union all
  select file$.file#
       , fet$.block#
       , fet$.length + fet$.block# - 1
       , 'FREE EXTENT' name
       , NULL partition_name
       , 'FREE EXTENT' kind
  from fet$, file$
  where file$.ts# = fet$.ts#
    and file$.relfile# = fet$.file#
  ;
grant select on extent_to_object to select_catalog_role;

REM  This table maps extents to database objects. This table must be 
REM  dropped and recreated to include any new extents that are added 
REM  after the last time it was created.  Its purpose is to speedup
REM  the views created below.

drop table extent_to_object_tab;
create table extent_to_object_tab as select * from extent_to_object;
create unique index extent_to_object_ind on extent_to_object_tab (file#, lowb);


REM  The IO_HISTOGRAM table contains samples of the block number of the block
REM  that is at the end of the buffer cache LRU list.

drop table io_histogram;
create table io_histogram (fileid number,blockid number, io_type varchar2(20));


REM This procedure periodically samples the buffer at the end of the lru list
REM and then writes its blockid into the IO_HISTOGRAM table.

create or replace procedure sample_io
  (duration number,     -- total sampling time in minutes
   sleep_time number    -- time to sleep between taking samples in seconds
  )
is
   time_so_far number;
   tail_of_lru raw(4);
   this_tail_of_lru raw(4);
   last_file_id number;
   this_file_id number;
   last_block_id number;
   this_block_id number;
   block_flag    number;
begin
   time_so_far := 0;
   last_file_id := 0;
   last_block_id := 0;

   -- Get the tail of lru value, this can be in flux, so try it several times
   -- to be sure.
   tail_of_lru := hextoraw('ffffffff');      -- init to very large value
   for i in 1..5 loop
     select hextoraw(min(nxt_repl)) into this_tail_of_lru from x$bh;
     if (this_tail_of_lru < tail_of_lru) 
     then 
       tail_of_lru := this_tail_of_lru;
     end if;
   end loop;

   -- loop until time runs out
   while (time_so_far < duration * 60) loop

     -- get buffer at the end of the lru list
     begin
      select file#, dbablk, flag into this_file_id, this_block_id, block_flag 
         from x$bh 
         where ((nxt_repl = tail_of_lru) and 
		(state = 1 or state = 2) and
		(rownum = 1));
     exception when no_data_found then null;
     end;

     -- don't insert same buffer twice, this means no activity on lru list
     if (this_file_id != last_file_id OR this_block_id != last_block_id)
     then
       insert into io_histogram 
            values (this_file_id, this_block_id, 
	            decode(bitand(block_flag,524288),0,'random','sequential'));
     end if;

     last_file_id := this_file_id;	
     last_block_id := this_block_id;

     dbms_lock.sleep(sleep_time);             -- go to sleep for a while
     time_so_far := time_so_far + sleep_time;    
   end loop;
end;
/


REM Create a view that summarizes the IO information per database object. 

create or replace view io_per_object as
select name, partition_name, kind, io_type, count(*) blocks_read
 from extent_to_object_tab e, io_histogram io
 where e.file# = io.fileid
  and  blockid between e.lowb and e.highb
  group by name, partition_name, kind, io_type;

grant select on io_per_object to select_catalog_role;


