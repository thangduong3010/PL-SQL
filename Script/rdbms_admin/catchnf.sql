Rem
Rem $Header: rdbms/admin/catchnf.sql /main/12 2010/06/11 01:11:31 tbhosle Exp $
Rem
Rem catchnf.sql
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catchnf.sql - Catalog for change notification
Rem
Rem    DESCRIPTION
Rem      Creates the dictionary objects necessary for the change notification.
Rem
Rem    NOTES
Rem      Refer to the change notification functional spec.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tbhosle     02/02/10 - 8670389: move regid seq to catqueue.sql
Rem    ssvemuri    02/08/08 - Add schema table for CQN query dependents
Rem    amullick    03/01/07 - add username to dba_cq_notification_queries
Rem    schitti     02/12/07 - create indexes
Rem    amullick    11/03/06 - fix misc bugs
Rem    ssvemuri    09/31/06 - Index modifications
Rem    schitti     08/01/06  - add userid column to chnf$_queries
Rem    amullick    06/28/06  - add objn column to chnf$_query_deltas
Rem    ssvemuri    07/24/06 - Add userid column to chnf$_queries 
Rem    ssvemuri    06/08/06 -  DBA views for query registrations
Rem    amullick    05/04/06 - add table chnfdirectload$,
Rem                           add scn column to chnf$_queries
Rem    ssvemuri    05/12/05 - increase the size of the row_id col
Rem    ssvemuri    08/10/04 - Add change notification view 
Rem    ssvemuri    07/09/04 - ssvemuri_change_notification
Rem    ssvemuri    04/12/04 - Created
Rem

create table invalidation_registry$ ( 
  regid   number,
  regflags number,
  numobjs number,
  objarray  raw(512),
  plsqlcallback varchar2(128),
  changelag number,
  username varchar2(30))
/

create index i_invalidation_registry$ on invalidation_registry$(regid)
/

Rem we will use a canonical representation for base filter conditions
Rem like (T.col < 10). In this case clauseOp will be LT, lhs will be
Rem T.col and rhs will be 10. We will use a post fix notation for 
Rem expression operands to make parsing simple. The dependent list
Rem contains the list of higher level entities (like clauses/queries)
Rem that reference the clause. When the dependent_list becomes empty,
Rem the clause is no longer needed and can be deleted.

create table chnf$_clauses (
  clauseId  number PRIMARY KEY,
  objectNum number,
  childList CLOB,
  clauseOp number,
  lhs CLOB,
  predicateop number,
  rhsVal CLOB,
  rhsType number,
  clauseFlags number,
  global_refcount number,
  hashval RAW(20))
  organization index tablespace sysaux overflow tablespace sysaux
/

Rem the index on hashval is needed for dupclauseRPI
create index i1_chnf$_clauses on chnf$_clauses(hashval)
/

Rem the index on object number is needed when refreshing the predicate
Rem cache for a specific object.
create index i2_chnf$_clauses on chnf$_clauses(objectNum)
/

Rem create a table to track dependents for each clause
Rem each dependent may have its own reference count for the clause
Rem indicating how many times the same clause was generated by this
Rem dependent. Optionally, this can be enhanced to include per
Rem dependent stats such as how many times the clause was true but the
Rem dependent was FALSE. In the case of multi-table queries that involve
Rem JOINS, the dependent is set to the queryId. If the clause
Rem evaluates to TRUE, we must further lookup
Rem chnf$_query_table based on the queryId, objn to determine if there
Rem are any dependent objects for which predicates need to be updated.
Rem If a query is being deleted, we must delete all clauses 
Rem whose dependent is set to every (queryId, objectId) tuple.

create table chnf$_clause_dependents(
       clauseId number ,
       dependentId number,
       dependentType number,
       refcount   number)
/

Rem indices for speeding up CQ clause dependent operations.
Rem Note - index on clauseid also needed for reading clauses
create index i1_chnf$_clause_dependents on chnf$_clause_dependents(clauseId)
/

create index i2_chnf$_clause_dependents on chnf$_clause_dependents(clauseId, dependentid, dependenttype)
/


Rem Meta-data for a (queryId, table) tuple. When the dependent of a clause
Rem is a query we may need to update predicates on dependent objects.
Rem We may need to execute a query to compute the updated predicates.
Rem The dependent_objs field tells us the potential set of dependent objects
create table chnf$_query_object(
       queryId number,
       objn    number,
       flags   number,
       virtualClause CLOB,
       source_query_sel  CLOB,
       source_query_fropos raw(64),
       source_query_whr CLOB,
       refcols RAW(32),
       position number,
       topclauseid number,
       joinclauseid number,
       maxdepth number)
/
create index i1_chnf$_query_object on chnf$_query_object(queryId)
/

create index i2_chnf$_query_object on chnf$_query_object(objn)
/

create table chnf$_reg_queries(
       regid number,
       queryId number)
/
create index i1_chnf$_reg_queries on chnf$_reg_queries(queryId)
/
Rem Index on regid needed to delete all entries corresponding to
Rem a registration when the reg. is being deleted.
create index i2_chnf$_reg_queries on chnf$_reg_queries(regid)
/

Rem Symbolic and parsed representation of select list, from list and
Rem where clause of a query. Expressions and clauses are represented
Rem in POST FIX. hashval is the MD5 hash of the query text.
Rem We are assuming that a query cannot have more than 16 objects. So 
Rem the set of dependent objects fits in a raw(64)

create table chnf$_queries(
       queryId number,
       queryflags number,
       selectList CLOB,
       fromList   RAW(100),
       whereClause CLOB,
       hashval  RAW(20),
       scn number,
       userid number)
/
Rem Index created on the hashval to quickly check for duplicates
Rem when registering queries.
create index i1_chnf$_queries on chnf$_queries(hashval)
/

create index i2_chnf$_queries on chnf$_queries(queryId)
/

create table chnf$_query_binds(
       queryId number,
       queryBindPos number,
       queryBindName varchar2(128),
       queryBindValue raw(512))
/
create index i1_chnf$_query_binds on chnf$_query_binds(queryId)
/
       

create table chnf$_group_filter_iot(
   objectNum number,
   exprfilter char,
   exprlhs    CLOB,
   colId     number,
   operator  number,
   rhsVal    RAW(500),
   filterId  number,
   primary key(objectNum, colId, operator, rhsVal) )
   organization index tablespace sysaux overflow tablespace sysaux
/

create table chnf$_query_dependencies(primarytype NUMBER,
                                      primaryid   NUMBER,
                                      dependencytype NUMBER,
                                      dependentname VARCHAR2(256))
/

create index i1_chnf$_query_deps on chnf$_query_dependencies(dependencytype, dependentname)
/

create index i2_chnf$_query_deps on chnf$_query_dependencies(primarytype, primaryid)
/                                    

create sequence chnf$_queryid_seq          /* queryid sequence number */
  start with 1
  increment by 1
  minvalue 1 
  nomaxvalue
  cache 20
  order
  nocycle
/

create sequence chnf$_clauseid_seq          /* queryid sequence number */
  start with 1
  increment by 1
  minvalue 1 
  nomaxvalue
  cache 20
  order
  nocycle
/

drop table chnf$_query_deltas
/
create global temporary table chnf$_query_deltas(
XID    RAW(8),
COL_OPERATION NUMBER,
queryId number, trigobj number,
chgrowid varchar2(2000),
chgrowop number,
rowid1 varchar2(2000),
rowid2 varchar2(2000),
rowid3 varchar2(2000),
rowid4 varchar2(2000),
rowid5 varchar2(2000),
col0_0 NUMBER,
col0_1 NUMBER, col0_2 NUMBER,
col0_3 NUMBER, col0_4 NUMBER,
col0_5 NUMBER, col0_6 NUMBER,
col0_7 NUMBER, col0_8 NUMBER,
col0_9 NUMBER, col0_10 NUMBER,
col1_0 VARCHAR2(4000),
col1_1 VARCHAR2(4000), col1_2 VARCHAR2(4000),
col1_3 VARCHAR2(4000), col1_4 VARCHAR2(4000),
col1_5 VARCHAR2(4000), col1_6 VARCHAR2(4000),
col1_7 VARCHAR2(4000), col1_8 VARCHAR2(4000),
col1_9 VARCHAR2(4000), col1_10 VARCHAR2(4000),
col2_0 RAW(512),
col2_1 RAW(512), col2_2 RAW(512),
col2_3 RAW(512), col2_4 RAW(512),
col2_5 RAW(512), col2_6 RAW(512),
col2_7 RAW(512), col2_8 RAW(512),
col2_9 RAW(512), col2_10 RAW(512),
col3_0 DATE,
col3_1 DATE, col3_2 DATE,
col3_3 DATE, col3_4 DATE,
col3_5 DATE, col3_6 DATE,
col3_7 DATE, col3_8 DATE,
col3_9 DATE, col3_10 DATE,
srcfropos NUMBER)
ON COMMIT DELETE ROWS
/

create  or replace type sys.chnf$_reg_info_oc4j as object (
       network_ip_address varchar2(128),
       network_port number,
       qosflags number,
       timeout number,
       operations_filter number,
       transaction_lag number)
/

create or replace type sys.chnf$_reg_info as object (
       callback varchar2(64),
       qosflags number,
       timeout number,
       operations_filter number,
       transaction_lag number,
       ntfn_grouping_class        NUMBER,    -- ntfn grouping class
       ntfn_grouping_value        NUMBER,    -- ntfn grouping value
       ntfn_grouping_type         NUMBER,    -- ntfn grouping type
       ntfn_grouping_start_time   TIMESTAMP WITH TIME ZONE, -- grp start time
       ntfn_grouping_repeat_count NUMBER,    -- ntfn grp repeat count
       CONSTRUCTOR FUNCTION chnf$_reg_info(
         callback varchar2,
         qosflags number,
         timeout number)  
       RETURN SELF AS RESULT ,   -- basic type without any frills
       CONSTRUCTOR FUNCTION chnf$_reg_info(
         callback varchar2,
         qosflags number,
         timeout number,
         operations_filter number,
         transaction_lag number)  -- 10gR2 type for backward compat 
       RETURN SELF AS RESULT,
       CONSTRUCTOR FUNCTION chnf$_reg_info(
         callback varchar2,
         qosflags number,
         timeout number,
         operations_filter number,
         ntfn_grouping_class        NUMBER,
         ntfn_grouping_value        NUMBER,
         ntfn_grouping_type         NUMBER,
         ntfn_grouping_start_time   TIMESTAMP WITH TIME ZONE,
         ntfn_grouping_repeat_count NUMBER)
         RETURN SELF AS RESULT 
         );                    -- depracating the transaction_lag param
/

create or replace public synonym CQ_NOTIFICATION$_REG_INFO for 
sys.chnf$_reg_info
/


create or replace type chnf$_rdesc as object(
   opflags number,
   row_id varchar2(2000))
/

create or replace public synonym CQ_NOTIFICATION$_ROW for 
sys.chnf$_rdesc
/

create or replace type chnf$_rdesc_array as VARRAY(1073741824) of chnf$_rdesc
/

create or replace public synonym CQ_NOTIFICATION$_ROW_ARRAY for
chnf$_rdesc_array
/

create or replace type chnf$_tdesc as object(
   opflags number,
   table_name varchar2(64),
   numrows number,
   row_desc_array chnf$_rdesc_array)
/

create or replace public synonym CQ_NOTIFICATION$_TABLE for sys.chnf$_tdesc
/

create or replace type chnf$_tdesc_array as VARRAY(1073741824) of chnf$_tdesc
/

create or replace public synonym CQ_NOTIFICATION$_TABLE_ARRAY
for sys.chnf$_tdesc_array
/

create or replace type chnf$_qdesc as object(
    queryid number,
    queryop number,
    table_desc_array chnf$_tdesc_array)
/

create or replace public synonym CQ_NOTIFICATION$_QUERY for 
sys.chnf$_qdesc
/

create or replace type chnf$_qdesc_array as VARRAY(1073741824) of chnf$_qdesc
/
create or replace public synonym CQ_NOTIFICATION$_QUERY_ARRAY for
sys.chnf$_qdesc_array
/


create or replace type chnf$_desc as object(
   registration_id number,
   transaction_id  raw(8),
   dbname          varchar2(30),
   event_type      number,
   numtables       number,
   table_desc_array   chnf$_tdesc_array,
   query_desc_array   chnf$_qdesc_array)
/

create or replace public synonym CQ_NOTIFICATION$_DESCRIPTOR for sys.chnf$_desc
/

GRANT EXECUTE on chnf$_reg_info_oc4j to PUBLIC;
/
GRANT EXECUTE on chnf$_reg_info to PUBLIC;
/
GRANT EXECUTE on chnf$_desc to PUBLIC;
/
GRANT EXECUTE on chnf$_tdesc to PUBLIC;
/
GRANT EXECUTE on chnf$_tdesc_array to PUBLIC;
/
GRANT EXECUTE on chnf$_rdesc to PUBLIC;
/
GRANT EXECUTE on chnf$_rdesc_array to PUBLIC;
/
GRANT EXECUTE on chnf$_qdesc to PUBLIC;
/
GRANT EXECUTE on chnf$_qdesc_array to PUBLIC;
/

create or replace view DBA_CHANGE_NOTIFICATION_REGS 
as select username, regid, regflags, callback, operations_filter, changelag, timeout,
   table_name from sys.x$ktcnreg
/
comment on table DBA_CHANGE_NOTIFICATION_REGS is
'Description of the registrations for change notification'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.USERNAME is
'owner of the registration'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.REGID is
'internal registration id'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.REGFLAGS is
'registration flags'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.CALLBACK is
'notification callback'
/
comment on column  DBA_CHANGE_NOTIFICATION_REGS.OPERATIONS_FILTER is
'operations filter (if specified)'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.CHANGELAG is
'transaction lag between notifications (if specified)'
/
comment on  column DBA_CHANGE_NOTIFICATION_REGS.TIMEOUT is
'registration timeout (if specified)'
/
comment on column DBA_CHANGE_NOTIFICATION_REGS.TABLE_NAME is
'name of registered table'
/
create or replace public synonym DBA_CHANGE_NOTIFICATION_REGS for DBA_CHANGE_NOTIFICATION_REGS
/
grant select on DBA_CHANGE_NOTIFICATION_REGS to select_catalog_role
/


create or replace view USER_CHANGE_NOTIFICATION_REGS
as 
select  r.regid, r.regflags, r.callback, r.operations_filter, r.changelag, r.timeout,
        r.table_name from
DBA_CHANGE_NOTIFICATION_REGS r, user$ u where u.user#= userenv('SCHEMAID')
and u.name = r.username
/
comment on table USER_CHANGE_NOTIFICATION_REGS is
'change notification registrations for current user'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.REGID is
'internal registration id'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.REGFLAGS is
'registration flags'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.CALLBACK is
'notification callback'
/
comment on column  USER_CHANGE_NOTIFICATION_REGS.OPERATIONS_FILTER is
'operations filter (if specified)'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.CHANGELAG is
'transaction lag between notifications (if specified)'
/
comment on  column USER_CHANGE_NOTIFICATION_REGS.TIMEOUT is
'registration timeout (if specified)'
/
comment on column USER_CHANGE_NOTIFICATION_REGS.TABLE_NAME is
'name of registered table'
/
create or replace public synonym USER_CHANGE_NOTIFICATION_REGS for USER_CHANGE_NOTIFICATION_REGS
/
grant select on USER_CHANGE_NOTIFICATION_REGS to public with grant option
/
   
create or replace view DBA_CQ_NOTIFICATION_QUERIES as select q.queryid, querytext, r.regid, username     from sys.x$ktcnquery q, sys.x$ktcnregquery r, sys.x$ktcnreg reg where q.queryid =  r.queryid and r.regid = reg.regid
/
comment on table DBA_CQ_NOTIFICATION_QUERIES is
'Description of registered queries for CQ notification'
/

comment on column DBA_CQ_NOTIFICATION_QUERIES.QUERYID is
'queryid of the query'
/

comment on column DBA_CQ_NOTIFICATION_QUERIES.QUERYTEXT is
'querytext of the query'
/

comment on column DBA_CQ_NOTIFICATION_QUERIES.REGID is
'Registration Id which the query is registered with'
/

comment on column DBA_CQ_NOTIFICATION_QUERIES.USERNAME is
'Name of user who registered the query'
/

create or replace public synonym DBA_CQ_NOTIFICATION_QUERIES FOR
                                 DBA_CQ_NOTIFICATION_QUERIES
/
                                 
grant select on DBA_CQ_NOTIFICATION_QUERIES to select_catalog_role
/                                               

create or replace view USER_CQ_NOTIFICATION_QUERIES as select q.queryid, q.querytext, q.regid     from USER_CHANGE_NOTIFICATION_REGS r, DBA_CQ_NOTIFICATION_QUERIES q where r.regid = q.regid
/

comment on table USER_CQ_NOTIFICATION_QUERIES is
'Description of registered queries for CQ notification'
/

comment on column USER_CQ_NOTIFICATION_QUERIES.QUERYID is
'queryid of the query'
/

comment on column USER_CQ_NOTIFICATION_QUERIES.QUERYTEXT is
'querytext of the query'
/

comment on column USER_CQ_NOTIFICATION_QUERIES.REGID is
'Registration Id which the query is registered with'
/

create or replace public synonym USER_CQ_NOTIFICATION_QUERIES FOR
                                 USER_CQ_NOTIFICATION_QUERIES
/
grant select on USER_CQ_NOTIFICATION_QUERIES to public with grant option
/                                               
                                                           
                                                           
                                                           

create table chnfdirectload$           /* table to store directload
                                        * rowid ranges for change
                                        * notification*/
( tableobj#     number not null, /* detail table obj# loaded */
  partitionobj# number not null, /* partition obj# that was loaded */
  dmloperation  number,     /* 1=insert, -1=delete */
  scn           number not null, /* SCN when the bulk DML occurred. */
  lowrowid      varchar2(20) not null,  /* low rowid modified in partition. */
  highrowid     varchar2(20) not null,  /* high rowid modified in partition. */
  xid           RAW(8),                     /* XID of the transaction */
  spare1        number,
  spare2        number,
  spare3        varchar2(1000),
  spare4        date
)
/
create unique index i_chnfdirectload$ on 
  chnfdirectload$(tableobj#, xid, lowrowid, highrowid) 
/
