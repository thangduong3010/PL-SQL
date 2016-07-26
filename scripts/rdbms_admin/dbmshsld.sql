Rem
Rem $Header: dbmshsld.sql 15-nov-2007.17:39:20 kchen Exp $
Rem
Rem dbmshsld.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmshsld.sql - HS bulk load packages and  types  
Rem
Rem    DESCRIPTION
Rem     This file includes HS bulk load packages and  types 
Rem
Rem    NOTES
Rem     The script is run by sys (connect internal). 
Rem     The tables , types and packages are created by sys.
Rem    MODIFIED   (MM/DD/YY)
Rem    kchen       11/07/07 - fixed bug 6612226
Rem    kchen       06/12/07 - fixed bug 6126126
Rem    kchen       03/19/07 - fixed lrg 2900123
Rem    kchen       02/14/07 - fixed bug 5883421, add cpu number check function
Rem    kchen       06/01/06 - create dbms_hs_bulk_load package
Rem    kchen       06/01/06 - create dbms_hs_bulk_load package
Rem    kchen       06/01/06 - Created
Rem


drop sequence hs_bulk_seq;

create sequence hs_bulk_seq start with 1 nocache;
grant select  on hs_bulk_seq to public;


CREATE TABLE  HS_BULKLOAD_VIEW_OBJ
(
SCHEMA_NAME varchar2 (30),
VIEW_NAME  varchar2 (30),
TEMP_OBJ_ID  number
);
grant select on HS_BULKLOAD_VIEW_OBJ to public;


CREATE OR REPLACE TYPE HS_PARTITION_OBJ authid current_user AS OBJECT
 (low_value number,
 high_value number,
 position  number);
/
grant execute  on HS_PARTITION_OBJ to public;


CREATE OR REPLACE TYPE  HSBLKValAry as  VARRAY(250)  of varchar2(4000);
/
grant execute on  HSBLKValAry  to public;


CREATE OR REPLACE type HSBLKNamLst  as table of varchar2(30);
/
grant execute on  HSBLKNamLst to public;


CREATE OR REPLACE TYPE HS_PART_OBJ  authid current_user AS OBJECT
 (low_value sys.HSBLKValAry,
 high_value sys.HSBLKValAry,
 col_name    sys. HSBLKNamLst,
 col_type     sys.HSBLKNamLst ,
 position   number);
/
grant execute on HS_PART_OBJ  to public;



CREATE OR REPLACE TYPE hs_sample_obj authid current_user AS OBJECT
 (low_value varchar2(4000),
 high_value varchar2(4000),
 position  number,
 data_type varchar2(106));
/
grant execute on  hs_sample_obj to public;

create table hs$_parallel_metadata
(dblink varchar2(128),     /* database link */
 remote_table_name varchar2(30), /* remote table name */
 remote_schema_name varchar2(30), /* remote schema name */
 parallel     varchar2(1) default 'Y' not null, /* Is parallel supported or not */
 parallel_degree integer default 4 not null,
 range_partitioned varchar2(1) default 'N' not null, /* remote table is range
                                              partitioned or not */
 sampled varchar2(1) default 'N' not null, /* is sample available */
 histogram varchar2(1) default 'N' not null, /* is histogram available */
 ind_available  varchar2(1) default 'Y' not null, /* is index available */ 
 sample_cap varchar2(1) default 'N' not null, /* is sample capability on */
 hist_column  varchar2(30),         /* histogram column */
 hist_column_type varchar2(30),    /* histogram column data type */
 sample_column  varchar2(30) default null,           /* sample  column name */
 sample_column_type varchar2(30),       /* sample column data type */
 num_partitions integer  default 0,      /* number of partitions */
 num_partition_columns integer  default 0,  /* number of partition columns */
 partition_col_names sys.HSBLKNamLst default null,   /* list of partition column or index column names */
 partition_col_types sys.HSBLKNamLst,  /* list of partition column or index column data types */
 ncol_min_val number default null,  /* numeric column min  value */
 ncol_avg_val number default null, /* numeric column avg  value */ 
 ncol_max_val number default null, /* numeric column max value */
 num_buckets integer default 0,  /* histogram number of buckets */
 constraint hs_parallel_metadata_pk  primary key (dblink, remote_table_name, remote_schema_name ))
 nested table partition_col_names store as hs_partition_col_name
 nested table partition_col_types store as hs_partition_col_type ;

create or replace view  HS_PARALLEL_METADATA as select * from HS$_PARALLEL_METADATA;

grant select on  HS$_PARALLEL_METADATA to public;
grant select on HS_PARALLEL_METADATA to public;

create or replace public synonym HS_PARALLEL_METADATA for HS_PARALLEL_METADATA;


create table hs$_parallel_partition_data (
 dblink varchar2(128) not null,   /* remote database link */
 remote_table_name varchar2 (30) not null, /* remote table name */
 remote_schema_name varchar2(30) not null, /* remote schema name */
 low_value sys.HSBLKValAry, /* list of partition bound values */
 high_value sys.HSBLKValAry, /* list of partition bound values */
 partition_position number, /* the partition position */
 constraint hs_parallel_partition_data_fk foreign key (dblink, remote_table_name, remote_schema_name)
 references hs$_parallel_metadata 
 (dblink, remote_table_name, remote_schema_name)
 on delete cascade );


create or replace view hs_parallel_partition_data (
dblink, remote_table_name, remote_schema_name,low_value, high_value, 
 partition_position,  partition_col_names , partition_col_types )
as select hp.dblink, hp.remote_table_name, hp.remote_schema_name, hp.low_value,
  hp.high_value, hp.partition_position , hm.partition_col_names,
 hm.partition_col_types
from hs$_parallel_partition_data hp, HS$_PARALLEL_METADATA hm
  where hp.dblink = hm.dblink and hp.remote_table_name = hm.remote_table_name 
   and hp.remote_schema_name = hm.remote_schema_name ;

grant select on hs_parallel_partition_data to public;

create or replace public synonym hs_parallel_partition_data for hs_parallel_partition_data;

 

create table hs$_parallel_histogram_data (
 dblink varchar2(128) not null,   /* remote database link */
 remote_table_name varchar2 (30) not null, /* remote table name */
 remote_schema_name varchar2(30) not null, /* remote schema name */
 low_value number, /* histogram end point value */
 high_value number, /*  histogram end point value  */
 bucket_num number, /* bucket number */
  constraint hs_parallel_histogram_data_fk  foreign key (dblink, remote_table_name, remote_schema_name)
 references hs$_parallel_metadata 
 (dblink, remote_table_name, remote_schema_name)
 on delete cascade );

create or replace view hs_parallel_histogram_data (
dblink, remote_table_name, remote_schema_name,low_value, high_value,
bucket_num  ) as 
select dblink, remote_table_name, remote_schema_name, low_value,
  high_value, bucket_num  
from hs$_parallel_histogram_data ;

grant select  on  hs_parallel_histogram_data to public;
create or replace public synonym hs_parallel_histogram_data for hs_parallel_histogram_data;



 create table  hs$_parallel_sample_data( 
 dblink varchar2(128) not null,   /* remote database link */
 remote_table_name varchar2 (30) not null, /* remote table name */
 remote_schema_name varchar2(30) not null, /* remote schema name */
 low_value varchar2(4000), /* sample data boundary value */
 high_value varchar2(4000), /* sample data boundary value  */
 position number , 
 constraint hs_parallel_sample_data_fk foreign key (dblink, remote_table_name, remote_schema_name)
 references hs$_parallel_metadata
 (dblink, remote_table_name, remote_schema_name)
 on delete cascade );

create or replace view  hs_parallel_sample_data(
dblink, remote_table_name, remote_schema_name,low_value, high_value,
position,  sample_column  , sample_column_type  ) as
select hs.dblink, hs.remote_table_name, hs.remote_schema_name, hs.low_value,
  hs.high_value, hs.position , hm.sample_column, hm.sample_column_type        
from hs$_parallel_sample_data hs, HS$_PARALLEL_METADATA hm
  where hs.dblink = hm.dblink and hs.remote_table_name = hm.remote_table_name  and
       hs.remote_schema_name = hm.remote_schema_name ;
 
grant select  on  hs_parallel_sample_data to public;
create or replace public synonym hs_parallel_sample_data for hs_parallel_sample_data;

CREATE or replace PACKAGE dbms_hs_parallel_metadata  as  
  type HvList is table of varchar2(5000);
  type NumList is table of number;
  function check_cap(dblink in varchar2, cap_number in number) return boolean;
  function get_cpu_num return integer;
  function get_domain_name return varchar2;
  procedure  raise_system_error(error_number IN INTEGER, arg1  IN VARCHAR2);
  procedure  loadIndColinfo (remote_schema in varchar2, 
  remote_table_name in varchar2, dblink in varchar2,
  ind_available in boolean, max_val in number , min_val in number,
   avg_val in number, part_column in varchar2 , part_col_type in varchar2 ,
   p_col_names in HSBLKNamLst, p_col_types in HSBLKNamLst ,
   col_names in HSBLKNamLst, col_types in HSBLKNamLst,
  parallel_degree in integer);
  procedure  loadHisinfo (remote_schema in varchar2,
  remote_table_name in varchar2, dblink in varchar2,
  ind_available in boolean, numBucket in number , part_column in varchar2 ,
    part_col_type in varchar2 , p_col_names in HSBLKNamLst,
    p_col_types in HSBLKNamLst , hisValues in NumList,
   col_names in HSBLKNamLst, col_types in HSBLKNamLst,
   parallel_degree in integer);
  procedure  loadPatitioninfo (remote_schema in varchar2,
   remote_table_name in varchar2, dblink in varchar2,
   p_cnt in number, p_key_cols in HSBLKNamLst, p_key_cnt in  number,
   typlst in HSBLKNamLst,hvalueList in HvList,
   hvalLen in  NumList, partPos  in NumList ,
   parallel_degree in integer);
  procedure  purgemetadata(remote_schema in varchar2, remote_table_name
  in varchar2, dblink in varchar2 );

  procedure update_samplemeta(remote_schema in varchar2, remote_table_name
  in varchar2, dblink in varchar2 ,parallel_degree in integer, 
 sample_column in varchar2, sample_column_type in varchar2);
  procedure load_sampledata(remote_schema in varchar2, remote_table_name
  in varchar2, dblink in varchar2 , low_value in varchar2, 
  high_value in varchar2, position in integer);


  procedure  insert_viewobj( ora_view_schema in varchar2, oraview_name 
  in varchar2, hsbkseq in number);

  procedure  delete_viewobj( ora_view_schema in varchar2, ora_view_name
  in varchar2);


  procedure table_sampling( remote_schema in varchar2,
      remote_table_name in varchar2, database_link in varchar2,
       hs_remote_tab_typ in varchar2,  p_degree in number,
      row_count in number,  ora_user in varchar2, oracle_table_name  in varchar2,
       pt_col_names in HSBLKNamLst , pt_col_types in  HSBLKNamLst ,
       col_names in  HSBLKNamLst , col_types in  HSBLKNamLst) ;
  procedure schedule_sampling (remote_schema in varchar2,
      remote_table_name in varchar2, database_link in varchar2,
       hs_remote_tab_typ in varchar2, p_degree in integer,
      row_count in number, ora_user in varchar2, oracle_table_name  in varchar2,
      pt_col_names in HSBLKNamLst , pt_col_types in  HSBLKNamLst ,
      col_names in  HSBLKNamLst , col_types in  HSBLKNamLst);


end dbms_hs_parallel_metadata;
/


CREATE or replace PACKAGE DBMS_HS_PARALLEL  authid current_user  as
   no_dblink  exception;
   no_remote_table exception;
   no_view  exception;
   pragma exception_init(no_dblink, -24277);
   pragma exception_init(no_remote_table, -24278);
   pragma exception_init(no_view, -24279);
   no_dblink_num number := -24277;
   no_remote_table_num number := -24278;
   no_view_num number := -24279;
  type hs_part_rec is  record (t hs_partition_obj);
  type hs_partion_rec is  record (t hs_part_obj);
  type hs_sample_rec is  record (t hs_sample_obj);
  type hs_part_refcur_t is ref cursor return hs_part_rec;
  type hs_partion_refcur_t is ref cursor return hs_partion_rec;
  type hs_sample_refcur_t is ref cursor return hs_sample_rec;

  procedure LOAD_TABLE(remote_table in varchar2 ,
   database_link in varchar2 , 
   oracle_table in varchar2 := null,  truncate in boolean := true, 
   parallel_degree in integer := null,  row_count out number) ;
  procedure CREATE_OR_REPLACE_VIEW(remote_table in varchar2 , 
   database_link in varchar2 , 
   oracle_view  in varchar2 :=  null, parallel_degree in integer := null ) ;
  procedure DROP_VIEW(oracle_view in varchar2);
  procedure CREATE_TABLE_TEMPLATE (remote_table in varchar2, database_link in varchar2,
   oracle_table in varchar2 := null, create_table_template_string out varchar2);

end DBMS_HS_PARALLEL;
/


grant execute on DBMS_HS_PARALLEL to public;



create or replace public synonym DBMS_HS_PARALLEL for DBMS_HS_PARALLEL;


begin
 
sys.dbms_scheduler.create_program
  ( program_name => 'hs_parallel_sampling',
    program_action => 'sys.dbms_hs_parallel_metadata.table_sampling',
    program_type  => 'stored_procedure',
    number_of_arguments => 12,
    enabled => false
  );

sys.dbms_scheduler.define_program_argument (
program_name =>  'sys.hs_parallel_sampling' , argument_position => 1,
   argument_type => 'VARCHAR2' );
sys.dbms_scheduler.define_program_argument (
program_name =>  'sys.hs_parallel_sampling' , argument_position => 2,
   argument_type => 'VARCHAR2' );
sys.dbms_scheduler.define_program_argument (
program_name =>  'sys.hs_parallel_sampling' , argument_position => 3,
   argument_type => 'VARCHAR2' );
sys.dbms_scheduler.define_program_argument (
program_name =>  'sys.hs_parallel_sampling' , argument_position => 4,
   argument_type => 'VARCHAR2' );

sys.dbms_scheduler.define_anydata_argument (
 program_name =>  'sys.hs_parallel_sampling' , argument_position => 5,
default_value => NULL,   argument_type => 'NUMBER' );
sys.dbms_scheduler.define_anydata_argument (
 program_name =>   'sys.hs_parallel_sampling' , argument_position => 6,
 default_value => NULL,   argument_type => 'NUMBER' );

sys.dbms_scheduler.define_program_argument (
program_name =>  'sys.hs_parallel_sampling' , argument_position => 7,
   argument_type => 'VARCHAR2' );
sys.dbms_scheduler.define_program_argument (
program_name =>  'sys.hs_parallel_sampling' , argument_position => 8,
   argument_type => 'VARCHAR2' );

sys.dbms_scheduler.define_anydata_argument (
program_name =>   'sys.hs_parallel_sampling' , argument_position => 9,
default_value => NULL,   argument_type => 'HSBLKNamLst' );
sys.dbms_scheduler.define_anydata_argument (
program_name =>   'sys.hs_parallel_sampling' , argument_position => 10,
default_value => NULL,   argument_type => 'HSBLKNamLst' );
sys.dbms_scheduler.define_anydata_argument (
program_name =>   'sys.hs_parallel_sampling' , argument_position => 11,
default_value => NULL,   argument_type => 'HSBLKNamLst' );
sys.dbms_scheduler.define_anydata_argument (
program_name =>   'sys.hs_parallel_sampling' , argument_position => 12,
default_value => NULL,   argument_type => 'HSBLKNamLst' );



sys.dbms_scheduler.enable ( 'hs_parallel_sampling' ) ;

exception when others then
  if sqlcode = -27477 then NULL;
  else  raise ;
  end if;

end ;
/

grant execute on hs_parallel_sampling to public;

