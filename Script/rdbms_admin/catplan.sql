Rem
Rem $Header: catplan.sql 03-feb-2008.18:33:06 kyagoub Exp $
Rem
Rem catplan.sql
Rem
Rem Copyright (c) 2003, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catplan.sql - CATALOG create public plan table
Rem
Rem    DESCRIPTION
Rem      This script creates a public plan table as a global temporary
Rem      table accessible from any schema. It also creates the plan_id
Rem      sequence number.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kyagoub     02/03/08 - lrg#3285833: re-create plan_table$
Rem    rburns      05/07/06 - split for parallel 
Rem    pbelknap    07/07/05 - add columns to sql_plan_stat_row_type 
Rem    bdagevil    02/24/05 - increase maximum line size 
Rem    pbelknap    07/23/04 - type oid for stat_row_type 
Rem    pbelknap    06/30/04 - change oids 
Rem    kyagoub     06/23/04 - add sql_plan_stat_row_type 
Rem    pbelknap    06/25/04 - reserve toids 
Rem    kyagoub     04/27/04 - grant execute on sql_plan_xxx to public, create 
Rem                           public synonyms and move drop statements to 
Rem                           catnplan.sql 
Rem    pbelknap    04/20/04 - plan diff types 
Rem    bdagevil    05/08/04 - add other_xml column 
Rem    bdagevil    11/01/03 - all run dbms_xplan 
Rem    bdagevil    06/18/03 - rename hint alias to object_alias
Rem    bdagevil    06/06/03 - hint alias increased in size
Rem    aime        04/25/03 - aime_going_to_main
Rem    bdagevil    02/24/03 - bdagevil_sql_tune_5
Rem    bdagevil    02/13/03 - Created
Rem
  

create type dbms_xplan_type
  as object (plan_table_output varchar2(300));
/

create type dbms_xplan_type_table
  as table of dbms_xplan_type;
/

REM necessary for lower privileged users
grant execute on dbms_xplan_type to public;
grant execute on dbms_xplan_type_table to public;  
  
Rem
Rem Plan object type for plan diffs
Rem   - the sql_plan_table_type is a convenient way to store a handle on an
Rem     entire plan.  The dbms_xplan.compare_query_plans function takes in
Rem     two plans as arguments, so it needs a rolled-up type.  
Rem   - *** Note that these types are used by this function ONLY and should not
Rem         be used in user scripts/tables as they may be changed in the future
  
Rem
Rem SQL_PLAN_ROW_TYPE, SQL_PLAN_TABLE_TYPE
Rem
Rem  These types mirror the structure of the plan table and are used
Rem  to pass plans into this package for comparing plans.
Rem
Rem  You can populate a nested table of type SQL_PLAN_TABLE_TYPE as follows:
Rem
Rem  select CAST(COLLECT
Rem              (sql_plan_row_type(statement_id,plan_id,timestamp,remarks,
Rem               operation,options,object_node,object_owner,object_name,
Rem               object_alias,object_instance,object_type,optimizer,
Rem               search_columns,id,parent_id,depth,position,cost,
Rem               cardinality,bytes,other_tag,partition_start,
Rem               partition_stop,partition_id,NULL,distribution,cpu_cost,
Rem               io_cost,temp_space,access_predicates,filter_predicates,
Rem               projection,time,qblock_name,other_xml))
Rem         AS SQL_PLAN_TABLE_TYPE)
Rem  from plan_table where plan_id = :plid order by id;

create type sql_plan_row_type 
timestamp '1997-04-12:12:59:00' oid '00000000000000000000000000020210'
as object (
        statement_id       varchar2(30),
        plan_id            number,
        timestamp          date,
        remarks            varchar2(4000),
        operation          varchar2(30),
        options            varchar2(255),
        object_node        varchar2(128),
        object_owner       varchar2(30),
        object_name        varchar2(30),
        object_alias       varchar2(65),
        object_instance    numeric,
        object_type        varchar2(30),
        optimizer          varchar2(255),
        search_columns     number,
        id                 numeric,
        parent_id          numeric,
        depth              numeric,
        position           numeric,
        cost               numeric,
        cardinality        numeric,
        bytes              numeric,
        other_tag          varchar2(255),
        partition_start    varchar2(255),
        partition_stop     varchar2(255),
        partition_id       numeric,
        distribution       varchar2(30),
        cpu_cost           numeric,
        io_cost            numeric,
        temp_space         numeric,
        access_predicates  varchar2(4000),
        filter_predicates  varchar2(4000),
        projection         varchar2(4000),
        time               numeric,
        qblock_name        varchar2(30),
        other_xml          clob
) NOT FINAL
/
create or replace public synonym sql_plan_row_type for sql_plan_row_type
/
grant execute on sql_plan_row_type to public
/

Rem 
Rem sql_plan_table_type
Rem
create type sql_plan_table_type 
timestamp '1997-04-12:12:59:00' oid '00000000000000000000000000020211'
as table of sql_plan_row_type
/
create or replace public synonym sql_plan_table_type for sql_plan_table_type
/
grant execute on sql_plan_table_type to public
/

  
Rem
Rem ora_plan_id$: sequence number to uniquely identify explain plans
Rem 
create sequence ora_plan_id_seq$
  increment by 1
  start with 1
  minvalue 1
  maxvalue 4294967295
  cycle
  cache 10
/

Rem
Rem explain plan table
Rem
Rem NOTE: the plan table was not upgraded when the other_xml has been added
Rem       in 10.2. This means that upgraded databases to 10.2 or post 10.2
Rem       will not have this column which will invalid all packages and 
Rem       funtionalities which use the column.   
Rem       This is the main reason the table is recreated in here. 
drop table plan_table$;

create global temporary table plan_table$
(
        statement_id       varchar2(30),
        plan_id            number,
        timestamp          date,
        remarks            varchar2(4000),
        operation          varchar2(30),
        options            varchar2(255),
        object_node        varchar2(128),
        object_owner       varchar2(30),
        object_name        varchar2(30),
        object_alias       varchar2(65),
        object_instance    numeric,
        object_type        varchar2(30),
        optimizer          varchar2(255),
        search_columns     number,
        id                 numeric,
        parent_id          numeric,
        depth              numeric,        
        position           numeric,
        cost               numeric,
        cardinality        numeric,
        bytes              numeric,
        other_tag          varchar2(255),
        partition_start    varchar2(255),
        partition_stop     varchar2(255),
        partition_id       numeric,
        other              long,
        other_xml          clob,
        distribution       varchar2(30),
        cpu_cost           numeric,
        io_cost            numeric,
        temp_space         numeric,
        access_predicates  varchar2(4000),
        filter_predicates  varchar2(4000),
        projection         varchar2(4000),
        time               numeric,
        qblock_name        varchar2(30)
) on commit preserve rows
/

Rem
Rem Add necessary privileges and make plan_table$ the default for 
Rem everyone
Rem
grant select, insert, update, delete on plan_table$ to public
/
create or replace public synonym plan_table for plan_table$
/

Rem
Rem SQL_PLAN_STAT_ROW_TYPE (DEPRECATED)
Rem
Rem  This type was used in 10.2 to represent row source stats for the plan.  It
Rem  is currently deprecated, but it remains for backwards compatibility of the
Rem  sql tuning set import/export feature.  Use sql_plan_allstat_row_type now.
Rem
create type sql_plan_stat_row_type 
timestamp '1997-04-12:12:59:00' oid '00000000000000000000000000020212'
under sql_plan_row_type(
 executions             NUMBER,
 starts                 NUMBER,
 output_rows            NUMBER,
 cr_buffer_gets         NUMBER,
 cu_buffer_gets         NUMBER,
 disk_reads             NUMBER,
 disk_writes            NUMBER,
 elapsed_time           NUMBER
)
/
create or replace public synonym sql_plan_stat_row_type for sql_plan_stat_row_type
/
grant execute on sql_plan_stat_row_type to public
/

Rem
Rem SQL_PLAN_ALLSTAT_ROW_TYPE
Rem
Rem This type extends the sql_plan_row_type to contain all of the row source
Rem statistics used by the sql tuning set. This type should be used in 11g
Rem and the future.
Rem
create type sql_plan_allstat_row_type 
timestamp '1997-04-12:12:59:00' oid '00000000000000000000000000020215'
under sql_plan_row_type
(
 executions             NUMBER,
 last_starts            NUMBER,
 starts                 NUMBER,
 last_output_rows       NUMBER,
 output_rows            NUMBER,
 last_cr_buffer_gets    NUMBER,
 cr_buffer_gets         NUMBER,
 last_cu_buffer_gets    NUMBER,
 cu_buffer_gets         NUMBER,
 last_disk_reads        NUMBER,
 disk_reads             NUMBER,
 last_disk_writes       NUMBER,
 disk_writes            NUMBER,
 last_elapsed_time      NUMBER,
 elapsed_time           NUMBER,
 policy                 VARCHAR2(10),
 estimated_optimal_size NUMBER,
 estimated_onepass_size NUMBER,
 last_memory_used       NUMBER,
 last_execution         VARCHAR2(10),
 last_degree            NUMBER,
 total_executions       NUMBER,
 optimal_executions     NUMBER,
 onepass_executions     NUMBER,
 multipasses_executions NUMBER,
 active_time            NUMBER,
 max_tempseg_size       NUMBER,
 last_tempseg_size      NUMBER,
 
 -- Define a constructor function that converts from the old
 -- sql_plan_stat_row_type to the new sql_plan_allstat_row_type
 CONSTRUCTOR FUNCTION sql_plan_allstat_row_type(
   stat_row   sql_plan_stat_row_type)
 RETURN SELF AS RESULT
)
not final
/

create or replace public synonym sql_plan_allstat_row_type for sql_plan_allstat_row_type
/
grant execute on sql_plan_allstat_row_type to public
/

