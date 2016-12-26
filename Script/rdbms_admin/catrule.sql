Rem
Rem $Header: rdbms/admin/catrule.sql /main/28 2010/02/11 00:27:31 gagarg Exp $
Rem
Rem catrule.sql
Rem
Rem Copyright (c) 1998, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catrule.sql - Rules Catalog creation
Rem
Rem    DESCRIPTION
Rem      This loads the catalog and plsql packages for the rule engine
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gagarg      12/29/09 - Bug8656192: Increase limit of variable list/value
Rem                           array
Rem    shbose      11/06/09 - bug 8843855: increase output rule hit list
Rem    rburns      05/03/06 - move type body 
Rem    ksurlake    11/22/04 - Add sys.re$rule_list
Rem    weiwang     06/01/04 - fix action context export 
Rem    bpwang      04/01/04 - Adding internal lcr transformation support 
Rem    weiwang     03/26/04 - add uactx_client to rule$
Rem    weiwang     03/08/04 - add rule_set_ieuac$ 
Rem    weiwang     02/03/04 - add alter_evaluation_context 
Rem    weiwang     05/12/03 - add rule_set_iot$
Rem    weiwang     04/25/03 - sanity check in add_pair
Rem    weiwang     04/14/03 - optimize dictionary views
Rem    weiwang     04/14/03 - change indexes for rule_set_re
Rem    skaluska    09/10/02 - add r_lowbox
Rem    weiwang     08/05/02 - add column used to rule_set_re
Rem    weiwang     08/20/02 - remove dependencies from rules
Rem    weiwang     04/11/02 - store rule set evaluation info to dictionary
Rem    dcwang      06/11/02 - modify rules privilege
Rem    weiwang     01/25/02 - add support for action context export
Rem    skaluska    01/15/02 - bug 2176725: don't drop types.
Rem    weiwang     01/21/02 - mark rules engine objects created by AQ
Rem    weiwang     01/02/02 - modify dictionary views definition
Rem    weiwang     01/08/02 - remove user-defined table parameters
Rem    weiwang     11/13/01 - add method function to rec_var$
Rem    skaluska    10/30/01 - remove column number, attribute number.
Rem    weiwang     09/26/01 - change rule$ definition
Rem    weiwang     09/21/01 - add evaluation context to add rule
Rem    skaluska    09/07/01 - add column_name to sys.re$column_value.
Rem    weiwang     08/30/01 - add [user/all/dba]_rule_sets views
Rem    weiwang     09/04/01 - add import/export support
Rem    weiwang     08/14/01 - grant execute on all types to public
Rem    weiwang     08/02/01 - change to the 9iR2 API
Rem    weiwang     07/14/01 - add views for rules
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    kmeiyyap    01/07/99 - make catrule compatible for sqlplus
Rem    nbhatt      06/23/98 - remove type sys.rule$_hits
Rem    esoyleme    04/28/98 - fix security                                     
Rem    esoyleme    04/15/98 - normalize tables
Rem    esoyleme    04/15/98 - add dbmsread.sql
Rem    esoyleme    04/13/98 - add rulehits type
Rem    esoyleme    04/06/98 - create rules library
Rem    esoyleme    03/15/98 - add rules set cat creation
Rem    esoyleme    03/15/98 - Created
Rem

-- create dictionary tables and types

rem
rem Rules engine dictionary
rem
CREATE OR REPLACE TYPE sys.re$nv_node 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000030000'
AS OBJECT
( nvn_name       varchar2(30),
  nvn_value      sys.anydata)
/
CREATE OR REPLACE TYPE sys.re$nv_array 
TIMESTAMP '1997-04-12:12:59:00' OID '00000000000000000000000000030001'
AS VARRAY(1024) of sys.re$nv_node
/

CREATE OR REPLACE TYPE sys.re$name_array AS VARRAY(1024) of varchar2(30)
/

-- Create the library where 3GL callouts will reside
CREATE OR REPLACE LIBRARY dbms_rules_lib trusted as static
/

CREATE or replace TYPE sys.re$nv_list 
TIMESTAMP '2001-09-26:18:27:00' OID '00000000000000000000000000030002'
AS OBJECT
( actx_list sys.re$nv_array,
  MEMBER PROCEDURE add_pair(name IN varchar2, value IN sys.anydata),
  MEMBER PROCEDURE remove_pair(name IN varchar2),
  MEMBER FUNCTION  get_value(name IN varchar2) RETURN sys.anydata,
  MEMBER FUNCTION  get_all_names RETURN sys.re$name_array
)
/

grant execute on sys.re$nv_node to PUBLIC
/
grant execute on sys.re$nv_array to PUBLIC
/
grant execute on sys.re$nv_list to PUBLIC
/
grant execute on sys.re$name_array to PUBLIC
/

CREATE TABLE sys.rule_set_ieuac$ (
       client_name       VARCHAR2(30) primary key,            /* client name */
       export_function   VARCHAR2(100),           /* function to export actx */
       cli_comment       VARCHAR2(4000)    /* description of the application */
)
/

CREATE TABLE sys.rule_set$ (
       obj#              number not null,          /* rule set object number */
       ectx#             number,         /* evaluation context object number */
       property          number,                        /* rule set property */
                                      /* 0x1: this rule set is created by AQ */
       rs_comment        varchar2(4000),                    /* user comment  */
       num_rules         number /* number of distinct rules in the rule set */
)
/

CREATE UNIQUE INDEX sys.i_rule_set on sys.rule_set$(obj#)
/

CREATE TABLE sys.rule$( 
       obj#              number not null,              /* rule object number */
       condition         clob,                             /* rule condition */
       ectx#             number,                /* evaluation ctx obj number */
       r_action          sys.re$nv_list,                      /* rule action */
       property          number not null,                 /* rule properties */
                                          /* 0x1: this rule is created by AQ */
       r_comment         varchar2(4000),                     /* rule comment */
       uactx_client      varchar2(30)          /* client defined actx exists */
)
/
CREATE UNIQUE INDEX sys.i_rule on sys.rule$(obj#)
/

CREATE TABLE sys.rule_map$(
       r_obj#            number not null,              /* rule object number */
       rs_obj#           number not null,          /* rule set object number */
       property          number not null,         /* rule mapping properties */
                                                        /* 0x0001 - DISABLED */
       ectx#             number,                /* evaluation context number */
       rm_comment        varchar2(4000)      /* user comment for the mapping */
)
/

CREATE INDEX sys.i_rule_map1 on sys.rule_map$(rs_obj#)
/

CREATE INDEX sys.i_rule_map2 on sys.rule_map$(r_obj#)
/

CREATE TABLE sys.rule_ec$(
       obj#              number not null,   /* the evaluation ctx obj number */
       eval_func         varchar2(4000),                        /* func name */
       property          number,              /* evaluation context property */
                            /* 0x1: this evaluation context is created by AQ */
       ec_comment        varchar2(4000),    /* user comment for the eval ctx */
       num_tabs          number,      /* number of table aliases in eval ctx */
       num_vars          number           /* number of variables in eval ctx */
)
/

CREATE UNIQUE INDEX sys.i_rule_ec on sys.rule_ec$(obj#)
/

CREATE TABLE sys.rec_tab$(
       ec_obj#           number not null,             /* eval ctx obj number */
       tab_alias         varchar2(30),                        /* table alias */
       tab_name          varchar2(4000),                  /* full table name */
       property          number,                   /* table alias properties */
                                                 /* 0x1 = quoted table alias */
       tab_id            number,                     /* index of table alias */
       tab_obj#          number                       /* table object number */
)
/
CREATE INDEX sys.i_rec_tab on sys.rec_tab$(ec_obj#, tab_id)
/

CREATE TABLE sys.rec_var$(
       ec_obj#           number not null,             /* eval ctx obj number */
       var_name          varchar2(30),                     /* variable alias */
       var_type          varchar2(4000),               /* variable type desc */
       var_val_func      varchar2(4000),         /* variable value func name */
       var_mthd_func     varchar2(228),     /* variable method function name */
       property          number,                 /* variable type properties */
                                               /* 0x1 = quoted variable name */
       var_id            number,                        /* index of variable */
       var_dty           number,                                   /* oacdty */
       precision#        number,                                /* precision */
       scale             number,                                    /* scale */
       maxlen            number,                           /* maximum length */
       charsetid         number,                     /* NLS character set id */
       charsetform       number,                       /* character set form */
       toid              raw(16),                            /* OID for ADTs */
       version           number,                    /* TOID version for ADTs */
       num_attrs         number     /* number of flattened attributes in var */
)
/
CREATE INDEX sys.i_rec_var on sys.rec_var$(ec_obj#, var_id)
/

CREATE TABLE sys.rule_set_ee$(
       rs_obj#           number not null,             /* rule set obj number */
       ectx#             number not null,   /* evaluation context obj number */
       num_rules         number,              /* number of rules in rule set */
       num_boxes         number,         /* number of fast boxes in rule set */
       ee_flags          number                  /* evaluation context flags */
)
/

CREATE UNIQUE INDEX sys.i_rule_set_ee on sys.rule_set_ee$(rs_obj#, ectx#)
/

CREATE TABLE sys.rule_set_te$(
       rs_obj#           number not null,             /* rule set obj number */
       ec_obj#           number not null,   /* evaluation context obj number */
       tab_id            number not null,            /* index of table alias */
       srchcols          raw(2000)                          /* real size 125 */
)
/
CREATE UNIQUE INDEX sys.i_rule_set_te on sys.rule_set_te$(rs_obj#, ec_obj#, 
tab_id)
/

CREATE TABLE sys.rule_set_ve$(
       rs_obj#           number not null,             /* rule set obj number */
       ec_obj#           number not null,   /* evaluation context obj number */
       var_id            number not null,               /* index of variable */
       num_attrs         number,        /* max number of (nested) attributes */
       num_mthds         number           /* number of methods in fast boxes */
)
/
CREATE UNIQUE INDEX sys.i_rule_set_ve on sys.rule_set_ve$(rs_obj#, ec_obj#, 
var_id)
/

CREATE TABLE sys.rule_set_re$(
       rs_obj#           number not null,             /* rule set obj number */
       ec_obj#           number not null,   /* evaluation context obj number */
       rule_id           number not null,             /* rule ID in eval ctx */
       r_obj#            number,                          /* rule obj number */
       r_orcount         number,                      /* rule or piece count */
       r_lowbox          number,                    /* lowest box rule is in */
       tabs_used         raw(2000),                                /* 1024/8 */
       vars_used         raw(2000),                                /* 1024/8 */
       property          number,                  /* rule mapping properties */
       ent_used          number                        /* is this entry used */
)
/
CREATE UNIQUE INDEX sys.i1_rule_set_re on sys.rule_set_re$(rs_obj#, ec_obj#, 
rule_id)
/
CREATE INDEX sys.i2_rule_set_re on sys.rule_set_re$(rs_obj#, ec_obj#, ent_used)
/
CREATE INDEX sys.i3_rule_set_re on sys.rule_set_re$(rs_obj#, r_obj#, ec_obj#)
/

CREATE TABLE sys.rule_set_ror$(
       rs_obj#           number not null,             /* rule set obj number */
       ec_obj#           number not null,   /* evaluation context obj number */
       rule_id           number not null,             /* rule ID in eval ctx */
       rule_or_piece     number not null,                   /* rule or piece */
       num_rops          number,        /* # of single operators in or piece */
       box_id            number,           /* fast box this piece belongs to */
       property          number                  /* rule or piece properties */
)
/
CREATE UNIQUE INDEX sys.i_rule_set_ror on sys.rule_set_ror$(rs_obj#, ec_obj#,
rule_id, rule_or_piece)
/

CREATE TABLE sys.rule_set_fob$(
       rs_obj#           number not null,             /* rule set obj number */
       ec_obj#           number not null,   /* evaluation context obj number */
       box_id            number not null,                      /* box number */
       box_type          number,                                 /* box type */
       opr_type          number,                             /* operand type */
       oet_type          number,                  /* operand expression type */
       oeflags           number,                                /* box flags */
       num_exprs         number,         /* number of expressions in the box */
       opexpr_n1         number,  /* three numbers for operand expression id */
       opexpr_n2         number,
       opexpr_n3         number,
       opexpr_c1         varchar2(30)                        /* and a string */
)
/
CREATE UNIQUE INDEX sys.i_rule_set_fob on sys.rule_set_fob$(rs_obj#, ec_obj#, 
box_id)
/

CREATE TABLE sys.rule_set_nl$(
       rs_obj#           number not null,             /* rule set obj number */
       ec_obj#           number not null,   /* evaluation context obj number */
       box_id            number not null,                      /* box number */
       ne_id             number not null,              /* name element index */
       name              varchar2(30),                /* name of the element */
       attr_id           number,         /* attribute number within the type */
       toid              raw(16),                        /* TOID of the type */
       version           number                       /* version of the type */
)
/
CREATE UNIQUE INDEX sys.i_rule_set_nl on sys.rule_set_nl$(rs_obj#, ec_obj#, 
box_id, ne_id)
/

CREATE TABLE sys.rule_set_pr$(
       rs_obj#           number,                      /* rule set obj number */
       ec_obj#           number,            /* evaluation context obj number */
       rule_id           number,                                  /* rule ID */
       rule_or_piece     number,                     /* rule or piece number */
       rop_id            number,                         /* fast operator ID */
       eval_id           number,                      /* evaluation order ID */
       pr_id             number not null,                 /* parameter index */
       value             RAW(300),                        /* parameter value */
       primary key(rs_obj#, ec_obj#, rule_id, rule_or_piece, rop_id, eval_id,
                   pr_id))
organization index tablespace sysaux overflow tablespace sysaux
/

CREATE TABLE sys.rule_set_rdep$(
       rs_obj#           number not null,             /* rule set obj number */
       dp_obj#           number not null,  /* rule set dependency obj number */
       dp_tmsp           date not null,           /* depedency obj timestamp */
       ec_obj#           number,                /* evaluation context number */
       rule_id           number,                              /* rule number */
       isin_dp           number            /* 1 if inserted into dependency$ */
)
/
CREATE INDEX sys.i_rule_set_rdep1 on sys.rule_set_rdep$(rs_obj#, dp_obj#, 
isin_dp)
/
CREATE INDEX sys.i_rule_set_rdep2 on sys.rule_set_rdep$(dp_obj#, dp_tmsp,
isin_dp)
/

CREATE TABLE sys.rule_set_iot$(
       rs_obj#           number,                      /* rule set obj number */
       ec_obj#           number,            /* evaluation context obj number */
       box_id            number,                                   /* box ID */
       value             raw(300),                         /* indexed values */
       rule_id           number,                                  /* rule ID */
       rule_or_piece     number,                              /* or piece ID */
       rop_id            number,                         /* fast operator ID */
       primary key(rs_obj#, ec_obj#, box_id, value, rule_id, 
                   rule_or_piece, rop_id))
organization index tablespace sysaux overflow tablespace sysaux
/

CREATE INDEX sys.i_rule_set_iot on sys.rule_set_iot$(rs_obj#, ec_obj#, 
rule_id, rule_or_piece, rop_id) tablespace sysaux
/

CREATE TABLE sys.rule_set_rop$(
       rs_obj#           number,                      /* rule set obj number */
       ec_obj#           number,            /* evaluation context obj number */
       rule_id           number,                                  /* rule ID */
       rule_or_piece     number,                              /* or piece ID */
       rop_id            number,                         /* fast operator ID */
       eval_id           number,                            /* evaluation ID */
       box_id            number,                                   /* box ID */
       primary key(rs_obj#, ec_obj#, rule_id, rule_or_piece, rop_id, eval_id))
organization index tablespace sysaux overflow tablespace sysaux
/

rem
rem Rules engine types
rem


CREATE OR REPLACE TYPE sys.re$table_alias
AS OBJECT
(table_alias             varchar2(32),
 table_name              varchar2(194))
/

CREATE OR REPLACE TYPE sys.re$table_alias_list
AS VARRAY(1024) OF sys.re$table_alias
/

CREATE OR REPLACE TYPE sys.re$variable_type
AS OBJECT
(variable_name             varchar2(32),
 variable_type             varchar2(4000),
 variable_value_function   varchar2(228),
 variable_method_function  varchar2(228))
/

--Bug 8656192: Increase the limit to match the max number of variables allowed
--             for a ruleset
CREATE OR REPLACE TYPE sys.re$variable_type_list
AS VARRAY(64000) OF sys.re$variable_type
/

CREATE OR REPLACE TYPE sys.re$table_value
AS OBJECT
(table_alias             varchar2(32),
 table_rowid             varchar2(18))
/

CREATE OR REPLACE TYPE sys.re$table_value_list
AS VARRAY(1024) OF sys.re$table_value
/

CREATE OR REPLACE TYPE sys.re$column_value
AS OBJECT
(table_alias             varchar2(32),
 column_name             varchar2(4000),
 column_data             sys.anydata)
/

CREATE OR REPLACE TYPE sys.re$column_value_list
AS VARRAY(1024) OF sys.re$column_value
/

CREATE OR REPLACE TYPE sys.re$variable_value
AS OBJECT
(variable_name           varchar2(32),
 variable_data           sys.anydata)
/

--Bug 8656192: Increase the limit to match the max number of variables allowed
--             for a ruleset
CREATE OR REPLACE TYPE sys.re$variable_value_list
AS VARRAY(64000) OF sys.re$variable_value
/

CREATE OR REPLACE TYPE sys.re$attribute_value
AS OBJECT
(variable_name           varchar2(32), 
 attribute_name          varchar2(4000),
 attribute_data          sys.anydata)
/

CREATE OR REPLACE TYPE sys.re$attribute_value_list
AS VARRAY(1024) OF sys.re$attribute_value
/

CREATE OR REPLACE TYPE sys.re$rule_hit
AS OBJECT
(rule_name               varchar2(65),
 rule_action_context     sys.re$nv_list)
/

CREATE OR REPLACE TYPE sys.re$rule_hit_list
AS VARRAY(32000) OF sys.re$rule_hit
/

CREATE OR REPLACE TYPE sys.re$rule_list
AS VARRAY(1024) OF varchar2(65)
/

grant execute on sys.re$table_alias to public
/
grant execute on sys.re$table_alias_list to public
/
grant execute on sys.re$variable_type to public
/
grant execute on sys.re$variable_type_list to public
/
grant execute on sys.re$table_value to public
/
grant execute on sys.re$table_value_list to public
/
grant execute on sys.re$column_value to public
/
grant execute on sys.re$column_value_list to public
/
grant execute on sys.re$variable_value to public
/
grant execute on sys.re$variable_value_list to public
/
grant execute on sys.re$attribute_value to public
/
grant execute on sys.re$attribute_value_list to public
/
grant execute on sys.re$rule_hit to public
/
grant execute on sys.re$rule_hit_list to public
/
grant execute on sys.re$rule_list to public
/

-- create entries to provide import/export procedural object support for rules
delete from sys.exppkgobj$ 
where (package = 'DBMS_RULE_EXP_EV_CTXS' and schema = 'SYS')
or    (package = 'DBMS_RULE_EXP_RULE_SETS' and schema = 'SYS')
or    (package = 'DBMS_RULE_EXP_RULES' and schema = 'SYS')
/

insert into sys.exppkgobj$(package, schema, class, type#, prepost, level#)
values('DBMS_RULE_EXP_EV_CTXS', 'SYS', 2, 62, 1, 1000)
/
insert into sys.exppkgobj$(package, schema, class, type#, prepost, level#)
values('DBMS_RULE_EXP_RULES', 'SYS', 2, 59, 1, 1001)
/
insert into sys.exppkgobj$(package, schema, class, type#, prepost, level#)
values('DBMS_RULE_EXP_RULE_SETS', 'SYS', 2, 46, 1, 1002)
/
insert into sys.exppkgobj$(package, schema, class, type#, prepost, level#)
values('DBMS_RULE_EXP_EV_CTXS', 'SYS', 3, 62, 1, 1000)
/
insert into sys.exppkgobj$(package, schema, class, type#, prepost, level#)
values('DBMS_RULE_EXP_RULES', 'SYS', 3, 59, 1, 1001)
/
insert into sys.exppkgobj$(package, schema, class, type#, prepost, level#)
values('DBMS_RULE_EXP_RULE_SETS', 'SYS', 3, 46, 1, 1002)
/

delete from sys.exppkgact$ where (package = 'DBMS_RULE_EXP_RULES' and schema = 'SYS')
/
-- make sure this is level# is greater than the ones used in catqueue.sql
insert into sys.exppkgact$(package, schema, class, level#) values
('DBMS_RULE_EXP_RULES', 'SYS', 2, 2001)
/
insert into sys.exppkgact$(package, schema, class, level#) values
('DBMS_RULE_EXP_RULES', 'SYS', 3, 2001)
/
insert into sys.exppkgact$(package, schema, class, level#) values
('DBMS_RULE_EXP_RULES', 'SYS', 6, 2001)
/
insert into sys.exppkgact$(package, schema, class, level#) values
('DBMS_RULE_EXP_RULES', 'SYS', 7, 2001)
/
commit
/

--create dictionary views
CREATE OR REPLACE VIEW user_rule_sets
(RULE_SET_NAME, RULE_SET_EVAL_CONTEXT_OWNER, RULE_SET_EVAL_CONTEXT_NAME, 
 RULE_SET_COMMENT)
AS
SELECT /*+ all_rows */ o.name, bu.name, bo.name, r.rs_comment
FROM   rule_set$ r, obj$ o, obj$ bo, user$ bu
WHERE  r.obj# = o.obj# and o.owner# = USERENV('SCHEMAID') 
       and r.ectx# = bo.obj#(+) and bo.owner# = bu.user#(+)
/
COMMENT ON TABLE user_rule_sets IS
'Rule sets owned by the user'
/
COMMENT ON COLUMN user_rule_sets.rule_set_name IS
'Name of the rule set'
/
COMMENT ON COLUMN user_rule_sets.rule_set_eval_context_owner IS
'The evaluation context owner name associated with the rule set, if any'
/
COMMENT ON COLUMN user_rule_sets.rule_set_eval_context_name IS
'The evaluation context name associated with the rule set, if any'
/
COMMENT ON COLUMN user_rule_sets.rule_set_comment IS
'user description of the rule set'
/
CREATE OR REPLACE PUBLIC SYNONYM user_rule_sets FOR user_rule_sets
/
GRANT SELECT ON user_rule_sets TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_rule_sets
(RULE_SET_OWNER, RULE_SET_NAME, RULE_SET_EVAL_CONTEXT_OWNER, 
 RULE_SET_EVAL_CONTEXT_NAME, RULE_SET_COMMENT)
AS
SELECT /*+ all_rows */
       u.name, o.name, bu.name, bo.name, r.rs_comment
FROM   rule_set$ r, obj$ o, user$ u, obj$ bo, user$ bu
WHERE  r.obj# = o.obj# and
       (o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */) or
        o.obj# in (select oa.obj# from sys.objauth$ oa 
                   where grantee# in (select kzsrorol from x$kzsro)) or
        exists (select null from v$enabledprivs where priv_number in (
                 -251, /* create any rule set */
                 -252, /* alter any rule set */
                 -253, /* drop any rule set */
                 -254  /* execute any rule set */))) and
       u.user# = o.owner# and
       r.ectx# = bo.obj#(+) and bo.owner# = bu.user#(+)
/

COMMENT ON TABLE all_rule_sets IS
'Rule sets seen by the user'
/
COMMENT ON COLUMN all_rule_sets.rule_set_owner IS
'Owner of the rule set'
/
COMMENT ON COLUMN all_rule_sets.rule_set_name IS
'Name of the rule set'
/
COMMENT ON COLUMN all_rule_sets.rule_set_eval_context_owner IS
'The evaluation context owner name associated with the rule set, if any'
/
COMMENT ON COLUMN all_rule_sets.rule_set_eval_context_name IS
'The evaluation context name associated with the rule set, if any'
/
COMMENT ON COLUMN all_rule_sets.rule_set_comment IS
'user description of the rule set'
/
CREATE OR REPLACE PUBLIC SYNONYM all_rule_sets FOR all_rule_sets
/
GRANT SELECT ON all_rule_sets TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_rule_sets
(RULE_SET_OWNER, RULE_SET_NAME, RULE_SET_EVAL_CONTEXT_OWNER, 
 RULE_SET_EVAL_CONTEXT_NAME, RULE_SET_COMMENT)
AS
SELECT /*+ all_rows */
       u.name, o.name, bu.name, bo.name, r.rs_comment
FROM   rule_set$ r, obj$ o, user$ u, obj$ bo, user$ bu
WHERE  r.obj# = o.obj# and u.user# = o.owner#
       and r.ectx# = bo.obj#(+) and bo.owner# = bu.user#(+)
/

COMMENT ON TABLE dba_rule_sets IS
'Rule sets in the database'
/
COMMENT ON COLUMN dba_rule_sets.rule_set_owner IS
'Owner of the rule set'
/
COMMENT ON COLUMN dba_rule_sets.rule_set_name IS
'Name of the rule set'
/
COMMENT ON COLUMN dba_rule_sets.rule_set_eval_context_owner IS
'The evaluation context owner name associated with the rule set, if any'
/
COMMENT ON COLUMN dba_rule_sets.rule_set_eval_context_name IS
'The evaluation context name associated with the rule set, if any'
/
COMMENT ON COLUMN dba_rule_sets.rule_set_comment IS
'user description of the rule set'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_rule_sets FOR dba_rule_sets
/
GRANT SELECT ON dba_rule_sets TO select_catalog_role
/

CREATE OR REPLACE VIEW user_rulesets
(RULESET_NAME, RULESET_STORAGE_TABLE, BASE_TABLE, RULESET_COMMENT)
AS
SELECT rule_set_name, NULL,
       decode(rule_set_eval_context_owner, NULL, NULL,
              rule_set_eval_context_owner||'.'||rule_set_eval_context_name),
       rule_set_comment 
FROM   user_rule_sets
/
COMMENT ON TABLE user_rulesets IS
'Rulesets owned by the user: maintained for backward compatibility'
/
COMMENT ON COLUMN user_rulesets.ruleset_name IS
'Name of the ruleset'
/
COMMENT ON COLUMN user_rulesets.ruleset_storage_table IS
'name of the table to store rules in the ruleset'
/
COMMENT ON COLUMN user_rulesets.base_table IS
'name of the evaluation context for the rule set'
/
COMMENT ON COLUMN user_rulesets.ruleset_comment IS
'user description of the ruleset'
/
create or replace public synonym USER_RULESETS for USER_RULESETS
/
GRANT SELECT ON user_rulesets TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_rulesets
(OWNER, RULESET_NAME, RULESET_STORAGE_TABLE, BASE_TABLE, RULESET_COMMENT)
AS
SELECT rule_set_owner, rule_set_name, NULL,
       decode(rule_set_eval_context_owner, NULL, NULL,
              rule_set_eval_context_owner||'.'||rule_set_eval_context_name),
       rule_set_comment 
FROM   all_rule_sets
/

COMMENT ON TABLE all_rulesets IS
'Rulesets seen by the user: maintained for backward compatibility'
/
COMMENT ON COLUMN all_rulesets.owner IS
'Owner of the ruleset'
/
COMMENT ON COLUMN all_rulesets.ruleset_name IS
'Name of the ruleset'
/
COMMENT ON COLUMN all_rulesets.ruleset_storage_table IS
'name of the table to store rules in the ruleset'
/
COMMENT ON COLUMN all_rulesets.base_table IS
'name of the evaluation context for the rule set'
/
COMMENT ON COLUMN all_rulesets.ruleset_comment IS
'user description of the ruleset'
/
CREATE OR REPLACE PUBLIC SYNONYM all_rulesets FOR all_rulesets
/
GRANT SELECT ON all_rulesets TO public WITH GRANT OPTION
/


CREATE OR REPLACE VIEW dba_rulesets
(OWNER, RULESET_NAME, RULESET_STORAGE_TABLE, BASE_TABLE, RULESET_COMMENT)
AS
SELECT rule_set_owner, rule_set_name, NULL,
       decode(rule_set_eval_context_owner, NULL, NULL,
              rule_set_eval_context_owner||'.'||rule_set_eval_context_name),
       rule_set_comment 
FROM   dba_rule_sets
/

COMMENT ON TABLE dba_rulesets IS
'Rulesets in the database: maintained for backward compatibility'
/
COMMENT ON COLUMN dba_rulesets.owner IS
'Owner of the ruleset'
/
COMMENT ON COLUMN dba_rulesets.ruleset_name IS
'Name of the ruleset'
/
COMMENT ON COLUMN dba_rulesets.ruleset_storage_table IS
'name of the table to store rules in the ruleset'
/
COMMENT ON COLUMN dba_rulesets.base_table IS
'name of the evaluation context for the rule set'
/
COMMENT ON COLUMN dba_rulesets.ruleset_comment IS
'user description of the ruleset'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_rulesets FOR dba_rulesets
/
GRANT SELECT ON dba_rulesets TO select_catalog_role
/


CREATE OR REPLACE VIEW user_rules
(RULE_NAME, RULE_CONDITION, RULE_EVALUATION_CONTEXT_OWNER, 
 RULE_EVALUATION_CONTEXT_NAME, RULE_ACTION_CONTEXT, 
 RULE_COMMENT)
AS
SELECT /*+ all_rows */
       o.name, r.condition, bu.name, bo.name, r.r_action, r.r_comment 
FROM   rule$ r, obj$ o, obj$ bo, user$ bu
WHERE  r.obj# = o.obj# and o.owner# = USERENV('SCHEMAID') and
       r.ectx# = bo.obj#(+) and bo.owner# = bu.user#(+)
/

COMMENT ON TABLE user_rules IS
'Rules owned by the user'
/
COMMENT ON COLUMN user_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN user_rules.rule_condition IS
'the rule expression'
/
COMMENT ON COLUMN user_rules.rule_evaluation_context_owner IS
'owner of the evaluation context on which rule is defined'
/
COMMENT ON COLUMN user_rules.rule_evaluation_context_name IS
'name of the evaluation context on which rule is defined'
/
COMMENT ON COLUMN user_rules.rule_action_context IS
'action context of the rule'
/
COMMENT ON COLUMN user_rules.rule_comment IS
'user description of the rule'
/
CREATE OR REPLACE PUBLIC SYNONYM user_rules for user_rules
/
GRANT SELECT ON user_rules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_rules
(RULE_OWNER, RULE_NAME, RULE_CONDITION, RULE_EVALUATION_CONTEXT_OWNER, 
 RULE_EVALUATION_CONTEXT_NAME, RULE_ACTION_CONTEXT, RULE_COMMENT)
AS
SELECT /*+ all_rows */
       u.name, o.name, r.condition, bu.name, bo.name, r.r_action, r.r_comment 
FROM   rule$ r, obj$ o, user$ u, obj$ bo, user$ bu
WHERE  r.obj# = o.obj# and 
       (o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */) or
        o.obj# in (select oa.obj# from sys.objauth$ oa 
                   where grantee# in (select kzsrorol from x$kzsro)) or
        exists (select null from v$enabledprivs where priv_number in (
                 -258, /* create any rule */
                 -259, /* alter any rule */
                 -260, /* drop any rule */
                 -261  /* execute any rule set */))) and
       o.owner# = u.user# and r.ectx# = bo.obj#(+) and bo.owner# = bu.user#(+)
/

COMMENT ON TABLE all_rules IS
'Rules seen by the user'
/
COMMENT ON COLUMN all_rules.rule_owner IS
'Owner of the rule'
/
COMMENT ON COLUMN all_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN all_rules.rule_condition IS
'the rule expression'
/
COMMENT ON COLUMN all_rules.rule_evaluation_context_owner IS
'owner of the evaluation context on which rule is defined'
/
COMMENT ON COLUMN all_rules.rule_evaluation_context_name IS
'name of the evaluation context on which rule is defined'
/
COMMENT ON COLUMN all_rules.rule_action_context IS
'action context of the rule'
/
COMMENT ON COLUMN all_rules.rule_comment IS
'user description of the rule'
/
CREATE OR REPLACE PUBLIC SYNONYM all_rules for all_rules
/
GRANT SELECT ON all_rules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_rules
(RULE_OWNER, RULE_NAME, RULE_CONDITION, RULE_EVALUATION_CONTEXT_OWNER, 
 RULE_EVALUATION_CONTEXT_NAME, RULE_ACTION_CONTEXT, RULE_COMMENT)
AS
SELECT /*+ all_rows */
       u.name, o.name, r.condition, bu.name, bo.name, r.r_action, r.r_comment 
FROM   rule$ r, obj$ o, user$ u, obj$ bo, user$ bu
WHERE  r.obj# = o.obj# and o.owner# = u.user# and 
       r.ectx# = bo.obj#(+) and bo.owner# = bu.user#(+)
/

COMMENT ON TABLE dba_rules IS
'Rules in the databse'
/
COMMENT ON COLUMN dba_rules.rule_owner IS
'Owner of the rule'
/
COMMENT ON COLUMN dba_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN dba_rules.rule_condition IS
'the rule expression'
/
COMMENT ON COLUMN all_rules.rule_evaluation_context_owner IS
'owner of the evaluation context on which rule is defined'
/
COMMENT ON COLUMN all_rules.rule_evaluation_context_name IS
'name of the evaluation context on which rule is defined'
/
COMMENT ON COLUMN dba_rules.rule_action_context IS
'action context of the rule'
/
COMMENT ON COLUMN dba_rules.rule_comment IS
'user description of the rule'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_rules for dba_rules
/
GRANT SELECT ON dba_rules TO select_catalog_role
/

CREATE OR REPLACE VIEW user_rule_set_rules
(RULE_SET_NAME, RULE_OWNER, RULE_NAME, RULE_SET_RULE_ENABLED, 
 RULE_SET_RULE_EVAL_CTX_OWNER, RULE_SET_RULE_EVAL_CTX_NAME, 
 RULE_SET_RULE_COMMENT)
AS
SELECT /*+ all_rows */
       o.name, ru.name, ro.name,
       decode(bitand(rm.property, 1), 1, 'DISABLED', 'ENABLED'),
       eu.name, eo.name, rm.rm_comment 
FROM   rule_map$ rm, obj$ o, obj$ ro, user$ ru, obj$ eo, user$ eu
WHERE  rm.rs_obj# = o.obj# and o.owner# = USERENV('SCHEMAID') and
       rm.r_obj# = ro.obj# and ro.owner# = ru.user# and rm.ectx# = eo.obj#(+)
       and eo.owner# = eu.user#(+)
/

COMMENT ON TABLE user_rule_set_rules IS
'Rules in user rule sets'
/
COMMENT ON COLUMN user_rule_set_rules.rule_set_name IS
'Name of the rule set'
/
COMMENT ON COLUMN user_rule_set_rules.rule_owner IS
'Owner of the rule'
/
COMMENT ON COLUMN user_rule_set_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN user_rule_set_rules.rule_set_rule_enabled IS
'Whether the rule is enabled in this ruleset'
/
COMMENT ON COLUMN user_rule_set_rules.rule_set_rule_eval_ctx_owner IS
'evaluation context owner specified when the rule is added to this rule set'
/
COMMENT ON COLUMN user_rule_set_rules.rule_set_rule_eval_ctx_name IS
'evaluation context name specified when the rule is added to this rule set'
/
COMMENT ON COLUMN user_rule_set_rules.rule_set_rule_comment IS
'User description of this mapping'
/
CREATE OR REPLACE PUBLIC SYNONYM user_rule_set_rules for user_rule_set_rules
/
GRANT SELECT ON  user_rule_set_rules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_rule_set_rules
(RULE_SET_OWNER, RULE_SET_NAME, RULE_OWNER, RULE_NAME, RULE_SET_RULE_ENABLED, 
 RULE_SET_RULE_EVAL_CTX_OWNER, RULE_SET_RULE_EVAL_CTX_NAME, 
 RULE_SET_RULE_COMMENT)
AS
SELECT /*+ all_rows */
       u.name, o.name, ru.name, ro.name,
       decode(bitand(rm.property, 1), 1, 'DISABLED', 'ENABLED'),
       eu.name, eo.name, rm.rm_comment 
FROM   rule_map$ rm, obj$ o, user$ u, obj$ ro, user$ ru, obj$ eo, user$ eu
WHERE  rm.rs_obj# = o.obj# and 
       (o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */) or
        o.obj# in (select oa.obj# from sys.objauth$ oa 
                   where grantee# in (select kzsrorol from x$kzsro)) or
        exists (select null from v$enabledprivs where priv_number in (
                 -251, /* create any rule set */
                 -252, /* alter any rule set */
                 -253, /* drop any rule set */
                 -254  /* execute any rule set */))) and
       o.owner# = u.user# and rm.r_obj# = ro.obj# and ro.owner# = ru.user#
       and rm.ectx# = eo.obj#(+) and eo.owner# = eu.user#(+)
/

COMMENT ON TABLE all_rule_set_rules IS
'Rules in all rule sets seen by the user'
/
COMMENT ON COLUMN all_rule_set_rules.rule_set_owner IS
'Owner of the rule set'
/
COMMENT ON COLUMN all_rule_set_rules.rule_set_name IS
'Name of the rule set'
/
COMMENT ON COLUMN all_rule_set_rules.rule_owner IS
'Owner of the rule'
/
COMMENT ON COLUMN all_rule_set_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN all_rule_set_rules.rule_set_rule_enabled IS
'Whether the rule is enabled in this ruleset'
/
COMMENT ON COLUMN all_rule_set_rules.rule_set_rule_eval_ctx_owner IS
'evaluation context owner specified when the rule is added to this rule set'
/
COMMENT ON COLUMN all_rule_set_rules.rule_set_rule_eval_ctx_name IS
'evaluation context name specified when the rule is added to this rule set'
/
COMMENT ON COLUMN all_rule_set_rules.rule_set_rule_comment IS
'User description of this mapping'
/
CREATE OR REPLACE PUBLIC SYNONYM all_rule_set_rules for all_rule_set_rules
/
GRANT SELECT ON  all_rule_set_rules TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_rule_set_rules
(RULE_SET_OWNER, RULE_SET_NAME, RULE_OWNER, RULE_NAME, RULE_SET_RULE_ENABLED, 
 RULE_SET_RULE_EVAL_CTX_OWNER, RULE_SET_RULE_EVAL_CTX_NAME, 
 RULE_SET_RULE_COMMENT)
AS
SELECT /*+ all_rows */
       u.name, o.name, ru.name, ro.name,
       decode(bitand(rm.property, 1), 1, 'DISABLED', 'ENABLED'),
       eu.name, eo.name, rm.rm_comment 
FROM   rule_map$ rm, obj$ o, user$ u, obj$ ro, user$ ru, obj$ eo, user$ eu
WHERE  rm.rs_obj# = o.obj# and o.owner# = u.user# and rm.r_obj# = ro.obj# and 
       ro.owner# = ru.user# and rm.ectx# = eo.obj#(+) and 
       eo.owner# = eu.user#(+)
/

COMMENT ON TABLE dba_rule_set_rules IS
'Rules in all rule sets in the database'
/
COMMENT ON COLUMN dba_rule_set_rules.rule_set_owner IS
'Owner of the rule set'
/
COMMENT ON COLUMN dba_rule_set_rules.rule_set_name IS
'Name of the rule set'
/
COMMENT ON COLUMN dba_rule_set_rules.rule_owner IS
'Owner of the rule'
/
COMMENT ON COLUMN dba_rule_set_rules.rule_name IS
'Name of the rule'
/
COMMENT ON COLUMN dba_rule_set_rules.rule_set_rule_enabled IS
'Whether the rule is enabled in this ruleset'
/
COMMENT ON COLUMN dba_rule_set_rules.rule_set_rule_eval_ctx_owner IS
'evaluation context owner specified when the rule is added to this rule set'
/
COMMENT ON COLUMN dba_rule_set_rules.rule_set_rule_eval_ctx_name IS
'evaluation context name specified when the rule is added to this rule set'
/
COMMENT ON COLUMN dba_rule_set_rules.rule_set_rule_comment IS
'User description of this mapping'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_rule_set_rules for dba_rule_set_rules
/
GRANT SELECT ON  dba_rule_set_rules TO select_catalog_role
/

CREATE OR REPLACE VIEW user_evaluation_contexts
(EVALUATION_CONTEXT_NAME, EVALUATION_FUNCTION, EVALUATION_CONTEXT_COMMENT)
AS
SELECT /*+ all_rows */
       o.name, ec.eval_func, ec.ec_comment
FROM   rule_ec$ ec, obj$ o
WHERE  ec.obj# = o.obj# and o.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_evaluation_contexts IS
'rule evaluation contexts owned by user'
/
COMMENT ON COLUMN user_evaluation_contexts.evaluation_context_name IS
'Name of the evaluation context'
/
COMMENT ON COLUMN user_evaluation_contexts.evaluation_function IS
'User supplied function to evaluate rules'
/
COMMENT ON COLUMN user_evaluation_contexts.evaluation_context_comment IS
'user description of the evaluation context'
/
CREATE OR REPLACE PUBLIC SYNONYM user_evaluation_contexts FOR user_evaluation_contexts
/
GRANT SELECT ON user_evaluation_contexts TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_evaluation_contexts
(EVALUATION_CONTEXT_OWNER, EVALUATION_CONTEXT_NAME, EVALUATION_FUNCTION, 
 EVALUATION_CONTEXT_COMMENT)
AS
SELECT /*+ all_rows */
       u.name, o.name, ec.eval_func, ec.ec_comment
FROM   rule_ec$ ec, obj$ o, user$ u
WHERE  ec.obj# = o.obj# and 
       (o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */) or
        o.obj# in (select oa.obj# from sys.objauth$ oa 
                   where grantee# in (select kzsrorol from x$kzsro)) or
        exists (select null from v$enabledprivs where priv_number in (
                 -246, /* create any evaluation context */
                 -247, /* alter any evaluation context */
                 -248, /* drop any evaluation context */
                 -249  /* execute any evaluation context */))) and
       o.owner# = u.user#
/

COMMENT ON TABLE all_evaluation_contexts IS
'rule evaluation contexts seen by user'
/
COMMENT ON COLUMN all_evaluation_contexts.evaluation_context_owner IS
'Owner of the evaluation context'
/
COMMENT ON COLUMN all_evaluation_contexts.evaluation_context_name IS
'Name of the evaluation context'
/
COMMENT ON COLUMN all_evaluation_contexts.evaluation_function IS
'User supplied function to evaluate rules'
/
COMMENT ON COLUMN all_evaluation_contexts.evaluation_context_comment IS
'user description of the evaluation context'
/
CREATE OR REPLACE PUBLIC SYNONYM all_evaluation_contexts FOR all_evaluation_contexts
/
GRANT SELECT ON all_evaluation_contexts TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_evaluation_contexts
(EVALUATION_CONTEXT_OWNER, EVALUATION_CONTEXT_NAME, EVALUATION_FUNCTION,
 EVALUATION_CONTEXT_COMMENT)
AS
SELECT /*+ all_rows */
       u.name, o.name, ec.eval_func, ec.ec_comment
FROM   rule_ec$ ec, obj$ o, user$ u
WHERE  ec.obj# = o.obj# and o.owner# = u.user#
/

COMMENT ON TABLE dba_evaluation_contexts IS
'rule evaluation contexts in the database'
/
COMMENT ON COLUMN dba_evaluation_contexts.evaluation_context_owner IS
'Owner of the evaluation context'
/
COMMENT ON COLUMN dba_evaluation_contexts.evaluation_context_name IS
'Name of the evaluation context'
/
COMMENT ON COLUMN dba_evaluation_contexts.evaluation_function IS
'User supplied function to evaluate rules'
/
COMMENT ON COLUMN dba_evaluation_contexts.evaluation_context_comment IS
'user description of the evaluation context'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_evaluation_contexts FOR dba_evaluation_contexts
/
GRANT SELECT ON dba_evaluation_contexts TO select_catalog_role
/

CREATE OR REPLACE VIEW user_evaluation_context_tables
(EVALUATION_CONTEXT_NAME, TABLE_ALIAS, TABLE_NAME)
AS
SELECT o.name, ect.tab_alias, ect.tab_name
FROM   rec_tab$ ect, obj$ o
WHERE  ect.ec_obj# = o.obj# and o.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_evaluation_context_tables IS
'tables in user rule evaluation contexts'
/
COMMENT ON COLUMN user_evaluation_context_tables.evaluation_context_name IS
'Name of the evaluation context'
/
COMMENT ON COLUMN user_evaluation_context_tables.table_alias IS
'Alias of the table'
/
COMMENT ON COLUMN user_evaluation_context_tables.table_name IS
'Name of the table'
/
CREATE OR REPLACE PUBLIC SYNONYM user_evaluation_context_tables FOR user_evaluation_context_tables
/
GRANT SELECT ON user_evaluation_context_tables TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_evaluation_context_tables
(EVALUATION_CONTEXT_OWNER, EVALUATION_CONTEXT_NAME, TABLE_ALIAS, TABLE_NAME)
AS
SELECT /*+ all_rows */
       u.name, o.name, ect.tab_alias, ect.tab_name
FROM   rec_tab$ ect, obj$ o, user$ u
WHERE  ect.ec_obj# = o.obj# and 
       (o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */) or
        o.obj# in (select oa.obj# from sys.objauth$ oa 
                   where grantee# in (select kzsrorol from x$kzsro)) or
        exists (select null from v$enabledprivs where priv_number in (
                 -246, /* create any evaluation context */
                 -247, /* alter any evaluation context */
                 -248, /* drop any evaluation context */
                 -249  /* execute any evaluation context */))) and
       o.owner# = u.user#
/
COMMENT ON TABLE all_evaluation_context_tables IS
'tables in all rule evaluation contexts seen by the user'
/
COMMENT ON COLUMN all_evaluation_context_tables.evaluation_context_owner IS
'Owner of the evaluation context'
/
COMMENT ON COLUMN all_evaluation_context_tables.evaluation_context_name IS
'Name of the evaluation context'
/
COMMENT ON COLUMN all_evaluation_context_tables.table_alias IS
'Alias of the table'
/
COMMENT ON COLUMN all_evaluation_context_tables.table_name IS
'Name of the table'
/
CREATE OR REPLACE PUBLIC SYNONYM all_evaluation_context_tables FOR all_evaluation_context_tables
/
GRANT SELECT ON all_evaluation_context_tables TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_evaluation_context_tables
(EVALUATION_CONTEXT_OWNER, EVALUATION_CONTEXT_NAME, TABLE_ALIAS, TABLE_NAME)
AS
SELECT /*+ all_rows */
       u.name, o.name, ect.tab_alias, ect.tab_name
FROM   rec_tab$ ect, obj$ o, user$ u
WHERE  ect.ec_obj# = o.obj# and o.owner# = u.user#
/
COMMENT ON TABLE dba_evaluation_context_tables IS
'tables in all rule evaluation contexts in the database'
/
COMMENT ON COLUMN dba_evaluation_context_tables.evaluation_context_owner IS
'Owner of the evaluation context'
/
COMMENT ON COLUMN dba_evaluation_context_tables.evaluation_context_name IS
'Name of the evaluation context'
/
COMMENT ON COLUMN dba_evaluation_context_tables.table_alias IS
'Alias of the table'
/
COMMENT ON COLUMN dba_evaluation_context_tables.table_name IS
'Name of the table'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_evaluation_context_tables FOR dba_evaluation_context_tables
/
GRANT SELECT ON dba_evaluation_context_tables TO select_catalog_role
/

CREATE OR REPLACE VIEW user_evaluation_context_vars
(EVALUATION_CONTEXT_NAME, VARIABLE_NAME, VARIABLE_TYPE, 
 VARIABLE_VALUE_FUNCTION, VARIABLE_METHOD_FUNCTION)
AS
SELECT o.name, ecv.var_name, ecv.var_type, ecv.var_val_func, ecv.var_mthd_func
FROM   rec_var$ ecv, obj$ o
WHERE  ecv.ec_obj# = o.obj# and o.owner# = USERENV('SCHEMAID')
/
COMMENT ON TABLE user_evaluation_context_vars IS
'variables in user rule evaluation contexts'
/
COMMENT ON COLUMN user_evaluation_context_vars.evaluation_context_name IS
'Name of the evaluation context'
/
COMMENT ON COLUMN user_evaluation_context_vars.variable_name IS
'Name of the variable'
/
COMMENT ON COLUMN user_evaluation_context_vars.variable_value_function IS
'Function to provide variable value'
/
COMMENT ON COLUMN user_evaluation_context_vars.variable_method_function IS
'Function to provide variable method return value'
/
CREATE OR REPLACE PUBLIC SYNONYM user_evaluation_context_vars FOR user_evaluation_context_vars
/
GRANT SELECT ON user_evaluation_context_vars TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW all_evaluation_context_vars
(EVALUATION_CONTEXT_OWNER, EVALUATION_CONTEXT_NAME, VARIABLE_NAME,
 VARIABLE_TYPE, VARIABLE_VALUE_FUNCTION, VARIABLE_METHOD_FUNCTION)
AS
SELECT /*+ all_rows */
       u.name, o.name, ecv.var_name, ecv.var_type, ecv.var_val_func, 
       ecv.var_mthd_func
FROM   rec_var$ ecv, obj$ o, user$ u
WHERE  ecv.ec_obj# = o.obj# and 
       (o.owner# in (USERENV('SCHEMAID'), 1 /* PUBLIC */) or
        o.obj# in (select oa.obj# from sys.objauth$ oa 
                   where grantee# in (select kzsrorol from x$kzsro)) or
        exists (select null from v$enabledprivs where priv_number in (
                 -246, /* create any evaluation context */
                 -247, /* alter any evaluation context */
                 -248, /* drop any evaluation context */
                 -249  /* execute any evaluation context */))) and
       o.owner# = u.user#
/
COMMENT ON TABLE all_evaluation_context_vars IS
'variables in all rule evaluation contexts seen by the user'
/
COMMENT ON COLUMN all_evaluation_context_vars.evaluation_context_owner IS
'Owner of the evaluation context'
/
COMMENT ON COLUMN all_evaluation_context_vars.evaluation_context_name IS
'Name of the evaluation context'
/
COMMENT ON COLUMN all_evaluation_context_vars.variable_name IS
'Name of the variable'
/
COMMENT ON COLUMN all_evaluation_context_vars.variable_value_function IS
'Function to provide variable value'
/
COMMENT ON COLUMN all_evaluation_context_vars.variable_method_function IS
'Function to provide variable method return value'
/
CREATE OR REPLACE PUBLIC SYNONYM all_evaluation_context_vars FOR all_evaluation_context_vars
/
GRANT SELECT ON all_evaluation_context_vars TO public WITH GRANT OPTION
/

CREATE OR REPLACE VIEW dba_evaluation_context_vars
(EVALUATION_CONTEXT_OWNER, EVALUATION_CONTEXT_NAME, VARIABLE_NAME, 
 VARIABLE_TYPE, VARIABLE_VALUE_FUNCTION, VARIABLE_METHOD_FUNCTION)
AS
SELECT /*+ all_rows */
       u.name, o.name, ecv.var_name, ecv.var_type, ecv.var_val_func,
       ecv.var_mthd_func
FROM   rec_var$ ecv, obj$ o, user$ u
WHERE  ecv.ec_obj# = o.obj# and o.owner# = u.user#
/
COMMENT ON TABLE dba_evaluation_context_vars IS
'variables in all rule evaluation contexts in the database'
/
COMMENT ON COLUMN dba_evaluation_context_vars.evaluation_context_owner IS
'Owner of the evaluation context'
/
COMMENT ON COLUMN dba_evaluation_context_vars.evaluation_context_name IS
'Name of the evaluation context'
/
COMMENT ON COLUMN dba_evaluation_context_vars.variable_name IS
'Name of the variable'
/
COMMENT ON COLUMN dba_evaluation_context_vars.variable_value_function IS
'Function to provide variable value'
/
COMMENT ON COLUMN dba_evaluation_context_vars.variable_method_function IS
'Function to provide variable method return value'
/
CREATE OR REPLACE PUBLIC SYNONYM dba_evaluation_context_vars FOR dba_evaluation_context_vars
/
GRANT SELECT ON dba_evaluation_context_vars TO select_catalog_role
/

