Rem
Rem $Header: rdbms/admin/exftab.sql /main/13 2009/01/08 11:05:03 ayalaman Exp $
Rem
Rem exftab.sql
Rem
Rem Copyright (c) 2002, 2008, Oracle. All rights reserved.
Rem
Rem    NAME
Rem      exftab.sql - EXpression Filter dictionary TABles
Rem
Rem    DESCRIPTION
Rem      Expression filter dictionary tables are used to store the metadata
Rem      for the expression sets and the indexes defined on them.
Rem
Rem    NOTES
Rem      See Documentation
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    07/29/08 - compiled sparse preds
Rem    ayalaman    09/14/05 - table aliases and conditions table 
Rem    ayalaman    07/29/05 - contains operator in stored expressions 
Rem    ayalaman    05/07/05 - spatial operators in stored expressions 
Rem    ayalaman    02/25/04 - 
Rem    ayalaman    01/20/04 - namespace support in XPath expressions 
Rem    ayalaman    12/25/03 - fix expression filter version for non-english 
Rem    ayalaman    07/23/03 - attribute set with default valued attributes
Rem    ayalaman    02/27/03 - create plan table
Rem    ayalaman    12/05/02 - defer the referential constraints
Rem    ayalaman    10/31/02 - define index on privilege table
Rem    ayalaman    10/21/02 - modify priv name
Rem    ayalaman    10/08/02 - store predicate storage clause in the metadata
Rem    ayalaman    10/03/02 - mainatin index status 
Rem    ayalaman    09/26/02 - ayalaman_expression_filter_support
Rem    ayalaman    09/06/02 - Created
Rem


REM
REM Create the Expression Filter dictionary tables
REM 
prompt .. creating Expression Filter dictionary

/***************************************************************************/
/***  EXF$VERSION - Table to store the version of the Expression Filter  ***/
/***************************************************************************/
create table exf$version 
(
  exfversion  number
);

truncate table exf$version;

insert into exf$version values (1.0);
commit;

/***************************************************************************/
/***  EXF$PARAMETER - Table to store (tunable) parameters                ***/
/***************************************************************************/
create table exf$parameter
(num         NUMBER, 
 name        VARCHAR2(64), 
 valtype     NUMBER,            --- 1 for number; 2 for varchar
 value       VARCHAR2(512),
 constraint dup_parameter primary key (num));

truncate table exf$parameter;

insert into exf$parameter (num, name, valtype, value) values 
       (1, 'dynamic_query_cpu_cost', 1, 1000000);
insert into exf$parameter (num, name, valtype, value) values 
       (2, 'pred_eval_cpu_cost', 1, 100000);
commit;

/***************************************************************************/
/***  EXF$JAVAMSG - Java implementations used for the expression filter  ***/
/***  dump the errors/msgs in this table. This is used as a workaround   ***/
/***  to return more than one value from Java functions. At any point    ***/
/***  there will be only one error message in this table.                ***/
/***  The data is private to the session and should be commit preserved  ***/
/***  to allow DDLs in between                                           ***/
/***************************************************************************/
create global temporary table exf$javamsg
(
  code       VARCHAR2(15),
  message    VARCHAR2(500)
) on commit preserve rows;

/***************************************************************************/
/*** EXF$ATTRSET -  This table stores the complete list of attribute sets ***/
/*** configured in the current instance. One row per attribute set       ***/
/***************************************************************************/
create table exf$attrset
(
  atsowner     VARCHAR2(32) not null,   -- owner of the attribute set
  atsname      VARCHAR2(32) not null,   -- attribute set name
  atstabtyp    VARCHAR2(32),            -- typed table for equiv query
  atsflags     NUMBER, 
                                    /* derived from an existing ADT : 0x01 */
  constraint dupl_attrset primary key (atsowner, atsname)
) organization index;

/***************************************************************************/
/*** EXF$EXPRSET - This table stores the complete list of expression sets ***/
/*** in the current instance. One row per expression set. Each expr set  ***/
/*** is associated with an attribute set                                 ***/
/***************************************************************************/
create table exf$exprset
(
   exsowner    VARCHAR2(32) not null,   -- owner of expr set and attr set 
   exstabnm    VARCHAR2(32) not null,   -- name of the table with exp col
   exscolnm    VARCHAR2(32) not null,   -- name of the column storing expr
   exsatsnm    VARCHAR2(32) not null,   -- assoc. attribute set name 
   exstabobj   NUMBER,                  -- expression set table obj#
   exsprvtrig  VARCHAR2(32),            -- trigger in EXPFIL sch for priv
   exsetlanl   DATE,                    -- expression set last analyzed 
   exsetnexp   NUMBER,                  -- number of expression in the set 
   exsetsprp   NUMBER,                  -- no of sparse predicates 
   avgprpexp   NUMBER,                  -- avg no of conj. predis per expr
   constraint  dupl_exprset primary key (exsowner, exstabnm, exscolnm),
   CONSTRAINT  ref_exprset_attrset FOREIGN KEY (exsowner, exsatsnm)
             references exf$attrset (atsowner, atsname) 
) organization index;

create index exf$esetidx on exf$exprset(exsatsnm);
/***************************************************************************/
/***  EXF$EXPSETPRIVS - Expresssion set privileges                        ***/
/***  Grantor is always same as the owner of the expression set          ***/
/***************************************************************************/
create table exf$expsetprivs
(
  esowner    VARCHAR2(32),      
  esexptab   VARCHAR2(32),            -- table with exp column(obj#)
  esexpcol   VARCHAR2(32),            -- column storing expressions in tab
  esgrantee  VARCHAR2(32), 
  escrtpriv  VARCHAR2(1), 
  esupdpriv  VARCHAR2(1), 
  CONSTRAINT esprivs_pkey PRIMARY KEY (esowner, esexptab, esexpcol,
                                       esgrantee),
  CONSTRAINT ref_priv_expr_set FOREIGN KEY (esowner, esexptab, esexpcol)
    references exf$exprset (exsowner, exstabnm, exscolnm) on delete cascade 
        initially deferred
) organization index;

create index exf$privgranteeidx on exf$expsetprivs(esgrantee);

/***************************************************************************/
/***  EXF$ATTRLIST - list of attributes in various attribute sets         ***/
/***  The attributes listed here may not be attributes used in the index ***/
/***  creation. These will be used next time the user issues the alter   ***/
/***  index rebuild. The attributes listed in this table are classified  ***/
/***  into                                                               ***/
/***    - elementary attributes                                          ***/
/***    - complex attributes                                             ***/
/***    - indexed attributes                                             ***/
/***    - stored attributes                                              ***/
/***************************************************************************/
create table exf$attrlist
(
  atsowner    VARCHAR2(32)   not null,   -- owner of the attribute set
  atsname     VARCHAR2(32)   not null,   -- attribute set name
  elattrid    number         default 10000,
  attrname    VARCHAR2(32)   not null,   -- elementary attr name
  attrtype    VARCHAR2(65),              -- type of attribute
  attrtptab   VARCHAR2(75),              -- table for tab aliases
  attrdefvl   VARCHAR2(100),             -- elem attr: default value
  attrprop    NUMBER,     
                                   /* ALL : elementary attribute 1 : 0x01 */
                                                 /* table alias 16 : 0x10 */
                                              /* text attribute 32 : 0x20 */
  attrtxtprf  VARCHAR2(1000),   
  CONSTRAINT duplicate_attribute_name PRIMARY KEY (atsowner, atsname,
                                                   attrname), 
  CONSTRAINT ref_attribute_set FOREIGN KEY (atsowner, atsname)
             references exf$attrset (atsowner, atsname) on delete cascade 
) organization index overflow including attrprop;

/***************************************************************************/
/*** EXF$DEFIDXPARAM - Default index parameters for an attribute set     ***/
/*** Keep the structure of the following two tables in sync(except key)  ***/
/***************************************************************************/
create table exf$defidxparam
(
  atsowner    VARCHAR2(32)   not null,   -- owner of the attribute set
  atsname     VARCHAR2(32)   not null,   -- attribute set name 
  attrsexp    VARCHAR2(300)   not null,  -- complex attr form (subexp)
  attrtype    VARCHAR2(65),              -- type of attribute
  attroper    exf$indexoper,             -- common operators
  attrprop    NUMBER,      
                                         /* elementary attribute 1 : 0x01 */
                                       /* ALL : stored attribute 4 : 0x04 */
                                           /*  indexed attribute 8 : 0x08 */
                                           /* xml tag : elememt 32 : 0x20 */
                                         /* xml tag : attribute 64 : 0x40 */
                                      /* xpath position filter 128 : 0x80 */
                                        /* xpath value filter 256 : 0x100 */
                                                  /* compiled sparse 1024 */
  xmltattr    VARCHAR2(32) default null, -- the XML Type for XML Tags
  xmlnselp    NUMBER default null,       -- element position incase of NS */
  CONSTRAINT duplicate_strdattr_name UNIQUE (atsowner, atsname,
                                                   attrsexp, xmltattr), 
  CONSTRAINT refdip_attribute_set FOREIGN KEY (atsowner, atsname)
             references exf$attrset (atsowner, atsname) on delete cascade 
);


/***************************************************************************/
/*** EXF$ESETIDXPARAM - index parameters for an expression set           ***/
/*** Keep this table structure in sync with the above table (except key) ***/
/***************************************************************************/
create table exf$esetidxparam
(
  esetowner   VARCHAR2(32)   not null, 
  esettabn    VARCHAR2(32)   not null, 
  esetcoln    VARCHAR2(32)   not null, 
  attrsexp    VARCHAR2(300)   not null,  -- complex attr form (subexp)
  attrtype    VARCHAR2(65),              -- type of attribute
  attroper    exf$indexoper,             -- common operators
  attrprop    NUMBER,      
                                         /* elementary attribute 1 : 0x01 */
                                       /* ALL : stored attribute 4 : 0x04 */
                                           /*  indexed attribute 8 : 0x08 */
                                           /* xml tag : elememt 32 : 0x20 */
                                         /* xml tag : attribute 64 : 0x40 */
                                      /* xpath position filter 128 : 0x80 */
                                        /* xpath value filter 256 : 0x100 */
                                                  /* compiled sparse 1024 */
  xmltattr    VARCHAR2(32) default null, -- the XML Type for XML Tags
  xmlnselp    NUMBER default null,       -- element position incase of NS */
  CONSTRAINT duplicate_esstrdattr_name UNIQUE (esetowner, esettabn, 
                                           esetcoln, attrsexp, xmltattr), 
  CONSTRAINT refesip_attribute_set FOREIGN KEY (esetowner, esettabn, 
    esetcoln) references exf$exprset (exsowner, exstabnm, exscolnm) 
        on delete cascade initially deferred
);

/***************************************************************************/
/*** EXF$ASUDFLIST - List of approved user-defined functions for an      ***/
/***   attribute set                                                     ***/
/***************************************************************************/
create table exf$asudflist 
(
  udfasoner  VARCHAR2(32)   not null, 
  udfasname  VARCHAR2(32)   not null,
  udfname    VARCHAR2(100)  not null, 
  udfobjown  VARCHAR2(32)   not null, 
  udfobjnm   VARCHAR2(32)   not null,
  udftype    VARCHAR2(20),
                                                               /* function */
                                                                /* package */
                                                                   /* type */
                                   /* derived package/ type member methods */
  CONSTRAINT duplicate_udfpt_name PRIMARY KEY(udfasoner, udfasname, udfname),
  CONSTRAINT udf_ref_atset FOREIGN KEY (udfasoner, udfasname) 
             references exf$attrset (atsowner, atsname) on delete cascade 
) organization index;

/***************************************************************************/
/***  EXF$IDXSECOBJ - secondary objects created for an exp filter index  ***/
/***  There is one entry in this table for every exp filter index        ***/
/***  This dictionary table stores the information about an exp filter   ***/
/***  index instance. Some information stored here can be derived from   ***/
/***  the other EXF$ table and USER_INDEXES and USER_IND_COLUMNS catalog ***/
/***  views. However, this info is need at the run time (in IndexStart)  ***/
/***  and it is duplicated here to avoid joins for every query           ***/
/***  Also store the optimizer summaries here so that the optimizer      ***/
/***  gets all the required info with dictionary I/O                     ***/
/***************************************************************************/
create sequence exf$idxobjseq;

create table exf$idxsecobj
(
   idxobj#     NUMBER       not null,   -- expfil index object #
   idxowner    VARCHAR2(32) not null,   -- index owner name 
   idxname     VARCHAR2(25) not null,   -- index_name 25 chars len
   idxattrset  VARCHAR2(32) not null,   -- attribute set name (for eff)
   idxesettab  VARCHAR2(32) not null,   -- expr set table (for efficiency)
   idxesetcol  VARCHAR2(32) not null,   -- expr set col (for efficiency)
   idxpredtab  VARCHAR2(32),            -- predicate table name 
   idxaccfunc  VARCHAR2(32),            -- access function package name
   idxstatus   VARCHAR2(11),            -- VALID/INPROGRESS/INVALID 
   optfccpuct  NUMBER,                  -- func based cpu cost/expr
   optfcioct   NUMBER,                  -- func based i/o cost/expr
   optixselvt  NUMBER,                  -- index selectivity %
   optixcpuct  NUMBER,                  -- index based cpu cost 
   optixioct   NUMBER,                  -- index based i/o cost    
   optptfscct  NUMBER,                  -- predicate table full scan cost 
   idxptabstg  VARCHAR2(1000),          -- params stg clause for pred tab
   idxpquery   CLOB,                    -- predicate table query 
   CONSTRAINT duplicate_idx_objno UNIQUE (idxobj#),
   CONSTRAINT duplicate_idx_name PRIMARY KEY (idxowner, idxname)
-- ,CONSTRAINT index_on_exprset FOREIGN KEY(idxowner, idxesettab, idxesetcol)
--     references exf$exprset (exsowner, exstabnm, exscolnm)
--        on delete cascade initially deferred
) organization index overflow including optptfscct;

create index exf$expsetidx on exf$idxsecobj(idxesettab, idxesetcol);

/***************************************************************************/
/***  EXF$PREDATTRMAP - predicate table column mapping to complex attrs  ***/
/***  There will be one entry in this table for every complex/elem attr  ***/
/***  stored in the predicate table. This table stores the system gen    ***/
/***  name for each of these attributes. The actual table has two cols   ***/
/***  with _OP and _CT suffixes to store the attributes' operand and     ***/
/***  constant. The predicate table also has a sparse_pred column which  ***/
/***  stores the sparse predicates. The entries in this table are mostly ***/
/***  used to build the access function                                  ***/
/***************************************************************************/
create table exf$predattrmap
(
   ptidxobj#    NUMBER        not null,  -- expfil index object#  
   ptattrsexp   VARCHAR2(300) not null,  -- attribute name/sub-expression
   ptattrid     NUMBER,                  -- id for the attribute
   ptattralias  VARCHAR2(25),            -- sys gen name (bind var in AF)
                                         --  actual columns are *_OP & *_CT
   ptattroper   exf$indexoper,            -- common operators
   ptattrtype   VARCHAR2(65),            -- no ADTs expected 
   ptattrprop   NUMBER,         
                                               /* stored attribute 1: 0x01 */
                                              /* indexed attribute 2: 0x02 */
                                            /* duplicate attribute 4: 0x04 */
                                    /* xpath filter : xml element 8 : 0x08 */
                                 /* xpath filter : xml attribute 16 : 0x10 */
                                    /* xpath filter : positional 32 : 0x20 */
                                   /* xpath filter : value based 64 : 0x40 */
        /* for perf */                /* XP Value : String type 128 : 0x80 */
        /*    "     */               /* XP Value : Number type 256 : 0x100 */
        /*    "     */                 /* XP Value : Date type 512 : 0x200 */
                           /* atoms for compiled sparse preds 1024 : 0x400 */ 
   xmltattr    VARCHAR2(32) default null, -- the XML Type for XML Tags
   xmlnselp    NUMBER default null,       -- element position incase of NS */
   CONSTRAINT dup_attr_exp UNIQUE (ptidxobj#, ptattrsexp, ptattralias,
                                   xmltattr),
   CONSTRAINT ref_idx_attrs FOREIGN KEY (ptidxobj#)
              references exf$idxsecobj (idxobj#) on delete cascade
);

/***************************************************************************/
/*** EXF$EXPSETSTATS - Predicate statistics for an expression set         ***/
/*** There will be a set of entries in this table for every expression   ***/
/*** set that is analyzed. An expression set name is obtained via the    ***/
/*** attribute-set name. This is to avoid any dangling stats owing to    ***/
/*** rename table                                                        ***/
/***************************************************************************/
create table exf$expsetstats 
(
  esetowner    VARCHAR2(32) not null,   -- owner of the expression set set
  esettable    VARCHAR2(32) not null,   -- expression set table
  esetcolumn   VARCHAR2(32) not null,   -- expression set column 
  predlhs     VARCHAR2(300) not null,
  noeqpreds   NUMBER,                  -- number of equality predicates
  noltpreds   NUMBER,                  -- number of less than preds 
  nogtpreds   NUMBER,                  -- number of greater than preds
  nolteqprs   NUMBER,                  -- number of <= predicates
  nogteqprs   NUMBER,                  -- number of >= predicates
  noneqprs    NUMBER,                  -- number of != predicates
  noisnlprs   NUMBER,                  -- number of is null predicates
  noisnnlprs  NUMBER,                  -- number of is not null predicates
  nobetpreds  NUMBER,                  -- number of between predicates
  nonvlpreds  NUMBER,                  -- number of NVL predicates
  nolikeprs   NUMBER,                  -- number of LIKE predicates
  CONSTRAINT stats_pkey primary key (esetowner, esettable, esetcolumn,
                                     predlhs), 
  CONSTRAINT ref_stats_key FOREIGN KEY (esetowner, esettable, esetcolumn) 
     references exf$exprset (exsowner, exstabnm, exscolnm) on delete cascade
       initially deferred
) organization index;

/***************************************************************************/
/*** EXF$VALIDOPER - list of valid operands to be passed to exf$indexoper  ***/
/***************************************************************************/

create table exf$validioper
(
   operstr  VARCHAR2(15)
);

truncate table exf$validioper;

insert into exf$validioper values ('=');
insert into exf$validioper values ('>');
insert into exf$validioper values ('<');
insert into exf$validioper values ('>=');
insert into exf$validioper values ('<=');
insert into exf$validioper values ('!=');
insert into exf$validioper values ('^=');
insert into exf$validioper values ('<>');
insert into exf$validioper values ('IS NULL');
insert into exf$validioper values ('IS NOT NULL');
insert into exf$validioper values ('ALL');
insert into exf$validioper values ('BETWEEN');
insert into exf$validioper values ('NVL');
insert into exf$validioper values ('LIKE');
insert into exf$validioper values ('SDO_WIDIST');
insert into exf$validioper values ('CONTAINS'); 

/***************************************************************************/
/*** EXF$VALIDPRIVS - list of valid privileges for the expression mgmt   ***/
/***************************************************************************/
create table exf$validprivs
(
  code       number, 
  privstr    varchar2(20)
); 

truncate table exf$validprivs;

insert into exf$validprivs values (1, 'INSERT EXPRESSION');
insert into exf$validprivs values (2, 'UPDATE EXPRESSION');
insert into exf$validprivs values (10, 'ALL');

/***************************************************************************/
/*** EXF$PLAN_TABLE : Execution plan/cost for predicate table query      ***/
/*** Entries will be dropped from this table at the time drop index      ***/
/***************************************************************************/
@@utlxplan

alter table plan_table rename to exf$plan_table;

alter table exf$plan_table add constraint plan_stmt_id
  primary key (statement_id, id);

