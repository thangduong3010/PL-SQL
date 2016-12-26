Rem
Rem $Header: rultab.sql 06-mar-2007.07:06:22 ayalaman Exp $
Rem
Rem rultab.sql
Rem
Rem Copyright (c) 2004, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      rultab.sql - Rule Manager dictionary
Rem
Rem    DESCRIPTION
Rem      This script creates the dictionary objects to store the metadata
Rem      pertaining to rules and rule sets. 
Rem
Rem    NOTES
Rem      See Documentation. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ayalaman    02/18/07 - having attributes
Rem    ayalaman    03/07/07 - retrict the size of the function based index
Rem    ayalaman    03/28/05 - aggregate predicates in rule conditions 
Rem    ayalaman    12/05/05 - event struct partial 
Rem    ayalaman    01/26/05 - shared primitive rule conditions 
Rem    ayalaman    07/18/05 - database change notification 
Rem    ayalaman    02/04/05 - expand the equal clause length 
Rem    ayalaman    01/31/05 - rlm4j dictionary for aliases 
Rem    ayalaman    11/23/04 - constraint on rlm4j_evtstructs 
Rem    ayalaman    10/08/04 - revoke create any job 
Rem    ayalaman    07/27/04 - nullable timestamp in scheduled action 
Rem    ayalaman    06/25/04 - negation with deadline dictionary 
Rem    ayalaman    05/11/04 - sub-equal clause 
Rem    ayalaman    05/11/04 - rename rule set to rule class 
Rem    ayalaman    04/23/04 - ayalaman_rule_manager_support 
Rem    ayalaman    04/21/04 - scheduler privileges 
Rem    ayalaman    04/21/04 - event cleanup schedule 
Rem    ayalaman    04/13/04 - transfer error messages to e41001.msg
Rem    ayalaman    04/02/04 - Created
Rem

REM 
REM Create the Rule Manager dictionary tables
REM 
prompt .. creating Rule Manager dictionary

/***************************************************************************/
/*** RLM$ERRCODE : Rule Manager error codes (Temporary)                  ***/
/***************************************************************************/

create table rlm$errcode 
(
  errno   number, 
  errmsg  VARCHAR2(200), 
  errdsc  VARCHAR2(500),
  erract  VARCHAR2(500),
  constraint rlm$errcodepk primary key (errno)
) organization index overflow;

truncate table rlm$errcode;

/***************************************************************************/
/*** RLM$RULESETSTCODE : Rule set status while creation                  ***/
/***************************************************************************/
create table rlm$rulesetstcode 
(
  rset_stcode  NUMBER primary key, 
  rset_stdesc  VARCHAR2(100),
  rset_stnext  VARCHAR2(100)
) organization index;

truncate table rlm$rulesetstcode;

insert into rlm$rulesetstcode values (0, 
 'VALID', NULL);
insert into rlm$rulesetstcode values (1, 
 'DICTIONARY SETUP', 'Creating Event Structure Objects');
insert into rlm$rulesetstcode values (2, 
 'EVENT STRUCTURE CREATED', 'Creating and Configuring Rule Class Repository');
insert into rlm$rulesetstcode values (3,
 'RULE CLASS TABLE(S) CREATED', 'Configuring Incremental Results tables');
insert into rlm$rulesetstcode values (4, 
 'INCREMENTAL RESULTS TABLES CREATED', 'Creating Action Callback Procedure');
insert into rlm$rulesetstcode values (5, 
 'ACTION CALLBACK PROCEDURE CREATED',
 'Creating Rule Set Access Package(s)');
insert into rlm$rulesetstcode values (6, 
 'RULE SET ACCESS PACKAGES CREATED', 
 'Creating Expression Filter Indexes for Rule Conditions');
insert into rlm$rulesetstcode values (7, 
 'EXPRESSION FILTER INDEXE(S) CREATED', NULL);


/***************************************************************************/
/*** RLM$EVENTSTUCT - Rule Manager's event structures. There are special ***/
/*** forms of attribute sets which have RLM$CRTTIME attribute defaulted  ***/
/*** to systdate. Also, all the required methods in the object type are  ***/
/*** created before the actual assignment (to save time)                 ***/
/***************************************************************************/
create table rlm$eventstruct 
(
  evst_owner    VARCHAR2(32),
  evst_name     VARCHAR2(32),
  evst_prop     NUMBER,
                                 -- 1 : Has creation timestamp attribute --
                                 -- 2 : Can only be primitive --
                                 -- 128: Event structure incomplete:IMP --
  evst_prct     VARCHAR2(32),    -- primitive rule conditions table 
  evst_prcttls  VARCHAR2(75),    -- table alias for which the ctab is crtd
  CONSTRAINT rlm$evst_primkey PRIMARY KEY (evst_owner, evst_name),
  CONSTRAINT rlm$evst_refkey FOREIGN KEY (evst_owner, evst_name)
    REFERENCES exf$attrset (atsowner, atsname) on delete cascade
) organization index;

-- to speed up the validation for DROP TABLE command --
create index rlm$evtstprctab on rlm$eventstruct (evst_owner, evst_prct);

/***************************************************************************/
/*** RLM$RULESET - Dictionary table to store the rule set information.   ***/
/*** It stores the rule set level properties and names for the database  ***/
/*** objects created for this rule set                                   ***/
/***************************************************************************/
create table rlm$ruleset
(
  rset_owner    VARCHAR2(32),
  rset_name     VARCHAR2(32),
  rset_pack     VARCHAR2(75),   -- quoted name with schema ext --
  rset_eventst  VARCHAR2(75),   -- dictionary name: no quotes --
  action_cbk    VARCHAR2(75),   -- dictionary name: no quotes --
  rset_rsltvw   VARCHAR2(32),   -- system gen or user spec name --
  rset_rslttab  VARCHAR2(32),   -- system gen name:no quotes --
  rset_prmexpt  VARCHAR2(32),   -- table storing primitive event exprs --
  rset_prmobjt  VARCHAR2(32),   -- table storing primitive events
  rset_prmrslt  VARCHAR2(32),   -- table storing primitive evt results --  
  rset_status   NUMBER,
  rset_prop     NUMBER,
                                               -- 1 : rule set is indexed --
                                               -- 2 : PRIMITIVE Rule set --
                                               -- 4 : COMPOSITE Rule set --
                                               -- 8 : SEQUENCE enabled --
                                               -- 16 : autocommit - YES --
                                               -- 32 : consumption EXCLUSIVE
                                               -- 64 : consumption RULE 
                                               -- 128 : 'I' DML Event 
                                               -- 256 : 'IU' DML Event 
                                               -- 512 : 'IUD' DML Event 
                                               -- 1024 : 'I' DML Event 
                                               -- 2048 : 'IU' DML Event 
                                               -- 4096 : 'IUD' DML Event 
  rset_durmin   NUMBER,         --- min/ -1 for tx and -2 for session --  
  rset_durtcl   VARCHAR2(100),
  rset_ordrcl   VARCHAR2(4000), -- ordering clause for conflict resolution --
  rset_rewocl   VARCHAR2(4000), -- rewritten ordering clause (tab aliases) 
  rset_stgcls   VARCHAR2(4000), -- storage clause for the tables --
  rset_eqcls    VARCHAR2(1000),
  rset_objnm    NUMBER,         -- object number for the rule set --
  CONSTRAINT rlm$rset_pkey primary key (rset_owner, rset_name),
  CONSTRAINT rlm$rset_status_ref FOREIGN KEY (rset_status) 
     references rlm$rulesetstcode (rset_stcode)
) organization index overflow including rset_prop;

/***************************************************************************/
/*** RLM$RULESETPRIVS - Dictionary table to store the privilege infor for **/
/*** the rule sets.                                                      ***/
/***************************************************************************/
/*** RLM$RULESETPRIVS - Rule set privileges ***/
create table rlm$rulesetprivs 
(
  rset_owner    VARCHAR2(32), 
  rset_name     VARCHAR2(32), 
  prv_grantee   VARCHAR2(32),
  prv_prcrule   VARCHAR2(1), 
  prv_addrule   VARCHAR2(1),
  prv_delrule   VARCHAR2(1),
  CONSTRAINT rlm$rset_privspkey PRIMARY KEY (rset_owner, rset_name,
                                             prv_grantee), 
  CONSTRAINT rlm$rset_privsrefs FOREIGN KEY (rset_owner, rset_name)
    references rlm$ruleset(rset_owner, rset_name)  on delete cascade 
       initially deferred
) organization index;

/***************************************************************************/
/*** RLM$RSPRIMEVENTS - Dictionary table to store the properties and dbase**/
/*** objects created for the primitive event structures within a composite**/
/*** event structure. For each rule set with composite events, this table **/
/*** has as many entries as the primitive events in the composite event  ***/
/*** This is the case even when there are duplicate primitive event types **/
/*** in the composite event.                                             ***/
/***************************************************************************/
create table rlm$rsprimevents 
(
  rset_owner    VARCHAR2(32),
  rset_name     VARCHAR2(32), 
  prim_attr     VARCHAR2(32), 
  prim_attrpos  NUMBER,
  prim_attrals  VARCHAR2(32),   -- system assigned alias for this attr --
  prim_asetnm   VARCHAR2(32),   -- dictionary name --
  CONSTRAINT rlm$crspkey PRIMARY KEY (rset_owner, rset_name, prim_attr), 
  CONSTRAINT rlm$crsprefk FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name)  on delete cascade 
       initially deferred
) organization index;

/***************************************************************************/
/*** RLM$PRIMEVTTYPEMAP - Primitive event type map and their properties  ***/
/*** This table has the entries for unique primitive event types used for **/
/*** each rule set                                                       ***/
/***************************************************************************/
create table rlm$primevttypemap
(
  rset_owner    VARCHAR2(32),
  rset_name     VARCHAR2(32),        
  prim_evntst   VARCHAR2(32),   -- dictionary name --
  prim_eslias   VARCHAR2(32),   -- system assigned alias for this type --
  prim_evttflgs NUMBER, 
                              --- 1 : has EXF$CRTTIME atttribute for date --
                              --- 2 : crspndg aset is a table alias aset --
                              --- 4 : crspndg aset is a XML Type aset -- 
                              ---   : autocommit - N/A --
                              --- 32 : consumption EXCLUSIVE --
                              --- 64 : call duration
                              --- 128 : collection type for agg preds
  prim_durmin   NUMBER,       --- min/ -1 for tx/-2 for sess/-3 call --
  prim_evdurcls VARCHAR2(200),   -- duration clause --
  talstabonr    VARCHAR2(32),
  talstabnm     VARCHAR2(32),
  havngattrs    VARCHAR2(4000),
  collcttab     VARCHAR2(32), --- collection table when flag 128 ---
  grpbyattrs    VARCHAR2(1000), 
  CONSTRAINT rlm$primmappkey PRIMARY KEY (rset_owner, rset_name, prim_evntst),
  CONSTRAINT rlm$primmaprefk FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name)  on delete cascade 
       initially deferred
) organization index overflow;

/***************************************************************************/
/*** RLM$EQUALSPEC - Most common equal specifications in the rule set    ***/
/***************************************************************************/
create table rlm$equalspec
(
  rset_owner    VARCHAR2(32),
  rset_name     VARCHAR2(32),
  opcode_id     NUMBER,        --- opcode mapping: 0 equal w/ all events ---
  eqlkeytyp     VARCHAR2(100), --- Number or VARCHAR(x) or Date ---
  eqspecflg     NUMBER, 
  equalattrs    RLM$EQUALATTR,
  CONSTRAINT rlm$eqspecpk PRIMARY KEY (rset_owner, rset_name, opcode_id),
  CONSTRAINT rlm$equalspecfk FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name)  on delete cascade 
       initially deferred
) organization index overflow;

/***************************************************************************/
/*** RLM$COLLGRPBYSPEC - Group by specification for the event configured ***/
/*** for aggregate predicates                                            ***/
/***************************************************************************/
create table rlm$collgrpbyspec
(
  rset_owner   VARCHAR2(32), 
  rset_name    VARCHAR2(32), 
  primevttp    VARCHAR2(32),  -- dictionary name --
  grpattidx    NUMBER,
  attrname     VARCHAR2(100), -- quoted(if necc) name for the grp exprn
  evtattr      VARCHAR2(32), 
  CONSTRAINT rlm$grpbyspecpk PRIMARY KEY (rset_owner, rset_name, 
                                             primevttp, attrname), 
  CONSTRAINT rlm$grpbyspecfk FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name)  on delete cascade 
       initially deferred
) organization index overflow; 

/***************************************************************************/
/*** RLM$ORDERCLSALS - Aliases for the variables used in the ordering    ***/
/*** clause. Used only if the composite event consists of primitive      ***/
/*** events that represent relational table and one or more columns from ***/
/*** this table are used on the ORDERING clause                          ***/
/***************************************************************************/
create table rlm$orderclsals
(
  rset_owner    VARCHAR2(32),
  rset_name     VARCHAR2(32),
  ordrkeyals    VARCHAR2(65),
  ordrkeypfx    VARCHAR2(32),
  ordrkey       VARCHAR2(300),
  datatype      VARCHAR2(100),
  CONSTRAINT rlm$orderspcpk PRIMARY KEY (rset_owner, rset_name, ordrkeyals),
  CONSTRAINT rlm$orderclsfk FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name)  on delete cascade 
       initially deferred
) organization index;

/***************************************************************************/
/*** RLM$DMLEVTTRIGS : Triggers created for DML event tracking           ***/
/***************************************************************************/
create table rlm$dmlevttrigs 
(
  rset_owner    VARCHAR2(32),
  rset_name     VARCHAR2(32),
  tatab_name    VARCHAR2(32), -- owner is same as the rule set for dml evt --
  presttrig     VARCHAR2(32), 
  dmlrowtrig    VARCHAR2(32),
  poststtrig    VARCHAR2(32),
  dbcnfregid    NUMBER,
  dbcnfcbkprc   VARCHAR2(75),
  CONSTRAINT rlm$dmlevtpkey PRIMARY KEY (rset_owner, rset_name, tatab_name), 
  CONSTRAINT rlm$dmlevtrefk FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name) on delete cascade 
) organization index;

/***************************************************************************/
/*** RLM$VALIDPRIVS - list of valid privileges for the rule mgmt         ***/
/***************************************************************************/
create table rlm$validprivs
(
  code       number,
  privstr    varchar2(25),
  constraint rlm$validpriv_pkey primary key (privstr)
) organization index;

truncate table rlm$validprivs;

insert into rlm$validprivs values (2, 'EXECUTE RULE');
insert into rlm$validprivs values (2, 'EXECUTE RULES');
insert into rlm$validprivs values (2, 'PROCESS RULE');
insert into rlm$validprivs values (2, 'PROCESS RULES');
insert into rlm$validprivs values (2, 'EXECUTE_RULE');
insert into rlm$validprivs values (2, 'EXECUTE_RULES');
insert into rlm$validprivs values (2, 'PROCESS_RULE');
insert into rlm$validprivs values (2, 'PROCESS_RULES');
insert into rlm$validprivs values (3, 'ADD RULE');
insert into rlm$validprivs values (3, 'ADD RULES');
insert into rlm$validprivs values (3, 'ADD_RULE');
insert into rlm$validprivs values (3, 'ADD_RULES');
insert into rlm$validprivs values (4, 'DELETE RULE');
insert into rlm$validprivs values (4, 'DELETE RULES');
insert into rlm$validprivs values (4, 'DELETE_RULE');
insert into rlm$validprivs values (4, 'DELETE_RULES');

insert into rlm$validprivs values (10, 'ALL');

/***************************************************************************/
/***     Private tables used by the rule manager implementation          ***/
/***************************************************************************/
create global temporary table rlm$parsedcond 
(
  tagname     VARCHAR2(32),
  peseqpos    NUMBER, 
  tagvalue    VARCHAR2(4000)
);


create or replace function rlm$uniquetag(tag varchar2, pos int) return varchar2
  deterministic is
begin
  if (instr(tag, 'RLM$RCND_COLL') > 0) then
    return tag||pos;
  else
    return tag;
  end if;
end;
/

create unique index rlm$unqcondtag on  rlm$parsedcond(
                              substr(rlm$uniquetag(tagname, peseqpos),1,40));

grant select on exfsys.rlm$parsedcond to public;

/***************************************************************************/
/*** Scheduled action list : List of actions scheduled for all the rule  ***/
/*** classes in the instance. This is done to make use of fewer scheduler **/
/*** processes while performing the actions                              ***/
/***************************************************************************/
create table rlm$schactlist 
(
  actschat     TIMESTAMP,     --- NULL => action running / ran / bef del  
  rsetproc     VARCHAR2(200), --- schema extended rule set pack and 
                              --- procedure name with arguments ---
  rsetincrrs   RLM$ROWIDTAB,  --- incremental results row idents ---
  rset_owner   VARCHAR2(32), 
  rset_name    VARCHAR2(32), 
  rset_prior   NUMBER default 3 NOT NULL, 
  CONSTRAINT rlm$schactfkey  FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name)  on delete cascade
       initially deferred
) nested table rsetincrrs store as rlm$incrrrschact 
   ((primary key(nested_table_id, column_value)) organization index);

--- scheduled process(es) pick up the action list in the index order ---
create index rlm$schactionorder on  rlm$schactlist(actschat);

create index rlm$schactrvrslkp on rlm$incrrrschact(column_value);

/***************************************************************************/
/*** Error during the execution of the action in background process      ***/
/***************************************************************************/
create table rlm$schacterrs
(
  actschat     TIMESTAMP,     
  rset_owner   VARCHAR2(32),
  rset_name    VARCHAR2(32),
  oraerrcde    NUMBER, 
  CONSTRAINT rlm$scaterrfkey FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name)  on delete cascade
       initially deferred,
  constraint rlm$scaterrpkey primary key (rset_owner, rset_name,
       actschat, oraerrcde)
) organization index;

/***************************************************************************/
/***   Event cleanup or any other scheduled operations                   ***/
/***************************************************************************/
create table rlm$jobqueue 
(
  sched_at     TIMESTAMP,
  rset_owner   VARCHAR2(32), 
  rset_name    VARCHAR2(32),
  priority     NUMBER,    --- priority of the job 
                          --- 10: cleanup job ---
  reschmin     NUMBER,    --- number of minutes for the next execution ---
  dynmcmd      VARCHAR2(1000), --- dynamic commands for execution --
  CONSTRAINT rlm$joinqkey primary key (sched_at, rset_owner, rset_name),
  CONSTRAINT rlm$joinqref FOREIGN KEY (rset_owner, rset_name) references
    rlm$ruleset(rset_owner, rset_name)  on delete cascade
       initially deferred
) organization index overflow;

--- Roles are not inherited in the package ---
---grant scheduler_admin to exfsys;
grant CREATE JOB to exfsys;
grant MANAGE SCHEDULER to exfsys;

/***************************************************************************/
/***             Rule Manager  for Java dictionary tables                ***/
/***************************************************************************/

/**************** Event Structures created from JDeveloper *****************/
create table rlm4j$evtstructs
(
   dbowner    VARCHAR2(32),  -- owner of the event struct in the instance --
   dbesname   VARCHAR2(32),  -- event struct name in the db --
   javapck    VARCHAR2(200), -- full java package name for corr. java file --
   javacls    VARCHAR2(100), -- java class corr. to the event struct --
   estflags   NUMBER, 
                             -- 1 : can be used for composite event stuct
   constraint rlm4j$unqevtstruct primary key (dbowner, dbesname),
   constraint rlm4j$evtstructs foreign key (dbowner, dbesname) references
      rlm$eventstruct (evst_owner, evst_name) on delete cascade 
        initially deferred
 ) organization index overflow;

/******************** Rule Sets created from JDeveloper ********************/
create table rlm4j$ruleset
(
  dbowner    VARCHAR2(32),  -- owner of the rule set in the db instance --
  dbrsname   VARCHAR2(32),  -- name of the rule set in the db --
  dbevsnm    VARCHAR2(32),  -- name of the corr event struct --
  javapck    VARCHAR2(200), -- full java package for the rule set --
  javacls    VARCHAR2(100), -- java class for the rule set --
  CONSTRAINT rlm4j$unqrsnm PRIMARY KEY (dbowner, dbrsname), 
  CONSTRAINT rlm4jrefsrlm FOREIGN KEY (dbowner, dbrsname) 
       references rlm$ruleset (rset_owner, rset_name) on delete cascade 
       initially deferred, 
  CONSTRAINT rlm4jrefsrlmes FOREIGN KEY (dbowner, dbevsnm) 
     REFERENCES rlm4j$evtstructs (dbowner, dbesname)
) organization index overflow;

/********************** Aliases for attributes in UI **********************/
create table rlm4j$attraliases
(
  esowner   VARCHAR2(32), 
  esname    VARCHAR2(32), 
  esattals  VARCHAR2(100),    --- alias for attribute or sub-expression --
  esattexp  VARCHAR2(4000),   --- expression aliased --
  aliastype NUMBER,           --- 1: predicate alias ---
  CONSTRAINT rlm4j$aalspkey PRIMARY KEY (esowner, esname, esattals), 
  CONSTRAINT rlm4j$aalfkey FOREIGN KEY (esowner, esname)
    references rlm$eventstruct (evst_owner, evst_name) on delete cascade
      initially deferred
) organization index overflow;


