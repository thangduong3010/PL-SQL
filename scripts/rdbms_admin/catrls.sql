Rem
Rem $Header: rdbms/admin/catrls.sql /main/20 2008/10/27 11:10:33 achoi Exp $
Rem
Rem catrls.sql
Rem
Rem Copyright (c) 1998, 2008, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      catrls.sql - Catalog views for Row Level Security
Rem
Rem    DESCRIPTION
Rem      Creates data dictionary views for row level security policies
Rem
Rem    NOTES
Rem      Must be run while connected to SYS
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achoi       10/02/08 - fix bug7450078
Rem    clei        12/19/05 - add XDS policy type for funstion security
Rem    clei        11/03/03 - update comments for relevant columns views
Rem    clei        10/13/03 - ALL_COLUMNS -> ALL_ROWS
Rem    clei        08/18/03 - add security relevant column option
Rem    clei        05/19/03 - synonym policies not attached to base object
Rem    clei        01/15/03 - change rls_sc$
Rem    clei        11/26/02 - add Index statement type
Rem    clei        07/22/02 - 10i policy type, long_predicate, sec rel cols
Rem    clei        10/10/01 - add synonym rls_grp$, rls_ctx and comment cleanup 
Rem    clei        07/20/01 - add synonym support
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    clei        04/12/01 - add static policy flag
Rem    htseng      04/12/01 - eliminate execute twice (remove ;).
Rem    dmwong      03/01/01 - rename dict vws to be consistent with the rest.
Rem    dmwong      12/19/00 - add public synonyms.
Rem    dmwong      07/11/00 - add DBA_POLICY_GROUP and DBA_POLICY_CONTEXT.
Rem    rshaikh     02/24/99 - change create view to create or replace view
Rem    dmwong      06/16/98 - update all_policies to depend on all_table and al
Rem    clei        03/09/98 - Created
Rem

create or replace view DBA_POLICIES (OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP,
                          POLICY_NAME, PF_OWNER, PACKAGE, FUNCTION, SEL, INS,
                          UPD, DEL, IDX, CHK_OPTION, ENABLE, STATIC_POLICY,
                          POLICY_TYPE, LONG_PREDICATE) 
as
select u.name, o.name, r.gname, r.pname, r.pfschma, r.ppname, r.pfname,
       decode(bitand(r.stmt_type,1), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,2), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,4), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,8), 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,2048), 0, 'NO', 'YES'),
       decode(r.check_opt, 0, 'NO', 'YES'),
       decode(r.enable_flag, 0, 'NO', 'YES'),
       decode(bitand(r.stmt_type,16), 0, 'NO', 'YES'),
       case bitand(r.stmt_type,16)+
            bitand(r.stmt_type,64)+
            bitand(r.stmt_type,128)+
            bitand(r.stmt_type,256)+
            bitand(r.stmt_type,8192)+
            bitand(r.stmt_type,16384)+
            bitand(r.stmt_type,32768)
         when 16 then 'STATIC'
         when 64 then 'SHARED_STATIC'
         when 128 then 'CONTEXT_SENSITIVE'
         when 256 then 'SHARED_CONTEXT_SENSITIVE'
         when 8192 then 'XDS1'
         when 16384 then 'XDS2'
         when 32768 then 'XDS3'
         else 'DYNAMIC'
       end,
   decode(bitand(r.stmt_type,512), 0, 'YES', 'NO')
from user$ u, "_CURRENT_EDITION_OBJ" o, rls$ r
where u.user# = o.owner# 
and r.obj# = o.obj#;
/
comment on table DBA_POLICIES is
'All row level security policies in the database'
/
comment on column DBA_POLICIES.OBJECT_OWNER is
'Owner of the synonym, table, or view'
/
comment on column DBA_POLICIES.OBJECT_NAME is
'Name of the synonym, table, or view'
/
comment on column DBA_POLICIES.POLICY_GROUP is
'Name of the policy group'
/
comment on column DBA_POLICIES.POLICY_NAME is
'Name of the policy'
/
comment on column DBA_POLICIES.PF_OWNER is
'Owner of the policy function'
/
comment on column DBA_POLICIES.PACKAGE is
'Name of the package containing the policy function'
/
comment on column DBA_POLICIES.FUNCTION is
'Name of the policy function'
/
comment on column DBA_POLICIES.SEL is
'If YES, policy is applied to query on the object'
/
comment on column DBA_POLICIES.INS is
'If YES, policy is applied to insert on the object'
/
comment on column DBA_POLICIES.UPD is
'If YES, policy is applied to update on the object'
/
comment on column DBA_POLICIES.DEL is
'If YES, policy is applied to delete on the object'
/
comment on column DBA_POLICIES.IDX is
'If YES, policy is applied to IDX on the object'
/
comment on column DBA_POLICIES.CHK_OPTION is
'Is check option enforced for this policy?'
/
comment on column DBA_POLICIES.ENABLE is
'Is this policy is enabled?'
/
comment on column DBA_POLICIES.STATIC_POLICY is
'Is this policy is static?'
/
comment on column DBA_POLICIES.POLICY_TYPE is
'policy types'
/
comment on column DBA_POLICIES.LONG_PREDICATE is
'If YES, maximum predicate size can be 32K'
/
create or replace public synonym DBA_POLICIES for DBA_POLICIES
/
grant select on DBA_POLICIES to select_catalog_role
/
create or replace view ALL_POLICIES (OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP,
                          POLICY_NAME, PF_OWNER, PACKAGE, FUNCTION, SEL, INS,
                          UPD, DEL, IDX, CHK_OPTION, ENABLE, STATIC_POLICY, 
                          POLICY_TYPE, LONG_PREDICATE) 
as
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP, POLICY_NAME, PF_OWNER, 
PACKAGE, FUNCTION, SEL, INS, UPD, DEL, IDX, CHK_OPTION, ENABLE, STATIC_POLICY,
POLICY_TYPE, LONG_PREDICATE
FROM DBA_POLICIES, ALL_TABLES t
WHERE 
(OBJECT_OWNER = t.OWNER AND OBJECT_NAME = t.TABLE_NAME) 
union all
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP, POLICY_NAME, PF_OWNER,
PACKAGE, FUNCTION, SEL, INS, UPD, DEL, IDX, CHK_OPTION, ENABLE, STATIC_POLICY,
POLICY_TYPE, LONG_PREDICATE
FROM DBA_POLICIES, ALL_VIEWS v
WHERE
(OBJECT_OWNER = v.OWNER AND OBJECT_NAME = v.VIEW_NAME )
union all
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP, POLICY_NAME, PF_OWNER,
PACKAGE, FUNCTION, SEL, INS, UPD, DEL, IDX, CHK_OPTION, ENABLE, STATIC_POLICY,
POLICY_TYPE, LONG_PREDICATE
FROM DBA_POLICIES, ALL_SYNONYMS s
WHERE
(OBJECT_OWNER = s.OWNER AND OBJECT_NAME = s.SYNONYM_NAME)
/

comment on table ALL_POLICIES is
'All policies for objects if the user has system privileges or owns the objects'
/
comment on column ALL_POLICIES.OBJECT_OWNER is
'Owner of the synonym, table, or view'
/
comment on column ALL_POLICIES.OBJECT_NAME is
'Name of the synonym, table, or view'
/
comment on column ALL_POLICIES.POLICY_NAME is
'Name of the policy'
/
comment on column ALL_POLICIES.PF_OWNER is
'Owner of the policy function'
/
comment on column ALL_POLICIES.PACKAGE is
'Name of the package containing the policy function'
/
comment on column ALL_POLICIES.FUNCTION is
'Name of the policy function'
/
comment on column ALL_POLICIES.SEL is
'If YES, policy is applied to query on the object'
/
comment on column ALL_POLICIES.INS is
'If YES, policy is applied to insert on the object'
/
comment on column ALL_POLICIES.UPD is
'If YES, policy is applied to update on the object'
/
comment on column ALL_POLICIES.DEL is
'If YES, policy is applied to delete on the object'
/
comment on column ALL_POLICIES.IDX is
'If YES, policy is applied to IDX on the object'
/
comment on column ALL_POLICIES.CHK_OPTION is
'Is check option enforced for this policy?'
/
comment on column ALL_POLICIES.ENABLE is
'Is this policy is enabled?'
/
comment on column ALL_POLICIES.STATIC_POLICY is
'Is this policy is static?'
/
comment on column ALL_POLICIES.POLICY_TYPE is
'policy types'
/
comment on column ALL_POLICIES.LONG_PREDICATE is
'If YES, maximum predicate size can be 32K'
/
create or replace public synonym ALL_POLICIES for ALL_POLICIES
/
grant select on ALL_POLICIES to PUBLIC with grant option
/
create or replace view USER_POLICIES (OBJECT_NAME, POLICY_GROUP, POLICY_NAME, 
                          PF_OWNER, PACKAGE, FUNCTION, SEL, INS,
                          UPD, DEL, IDX, CHK_OPTION, ENABLE, STATIC_POLICY,
                          POLICY_TYPE, LONG_PREDICATE) 
as
SELECT OBJECT_NAME, POLICY_GROUP, POLICY_NAME, PF_OWNER, PACKAGE, 
FUNCTION, SEL, INS, UPD, DEL, IDX, CHK_OPTION, ENABLE, STATIC_POLICY,
POLICY_TYPE, LONG_PREDICATE
FROM DBA_POLICIES
WHERE 
OBJECT_OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/
comment on table USER_POLICIES is
'All row level security policies for synonyms, tables, or views owned by the user'
/
comment on column USER_POLICIES.OBJECT_NAME is
'Name of the synonym, table, or view'
/
comment on column USER_POLICIES.POLICY_NAME is
'Name of the policy'
/
comment on column USER_POLICIES.PF_OWNER is
'Owner of the policy function'
/
comment on column USER_POLICIES.PACKAGE is
'Name of the package containing the policy function'
/
comment on column USER_POLICIES.FUNCTION is
'Name of the policy function'
/
comment on column USER_POLICIES.SEL is
'If YES, policy is applied to query on the object'
/
comment on column USER_POLICIES.INS is
'If YES, policy is applied to insert on the object'
/
comment on column USER_POLICIES.UPD is
'If YES, policy is applied to update on the object'
/
comment on column USER_POLICIES.DEL is
'If YES, policy is applied to delete on the object'
/
comment on column USER_POLICIES.IDX is
'If YES, policy is applied to IDX on the object'
/
comment on column USER_POLICIES.CHK_OPTION is
'Is check option enforced for this policy?'
/
comment on column USER_POLICIES.ENABLE is
'Is this policy is enabled?'
/
comment on column USER_POLICIES.STATIC_POLICY is
'Is this policy is static?'
/
comment on column USER_POLICIES.POLICY_TYPE is
'policy types'
/
comment on column USER_POLICIES.LONG_PREDICATE is
'If YES, maximum predicate size is 32K'
/
create or replace public synonym USER_POLICIES for USER_POLICIES
/
grant select on USER_POLICIES to PUBLIC with grant option
/

create or replace view DBA_POLICY_GROUPS (OBJECT_OWNER, OBJECT_NAME,
                          POLICY_GROUP)
as
select u.name, o.name, g.gname
from user$ u, obj$ o, rls_grp$ g
where u.user# = o.owner#
and g.obj# = o.obj#;
/
comment on table DBA_POLICY_GROUPS is
'All policy groups defined for any synonym, table, view in the database'
/
comment on column DBA_POLICY_GROUPS.OBJECT_OWNER is
'Schema of the synonym, table, or view'
/
comment on column DBA_POLICY_GROUPS.OBJECT_NAME is
'Name of the synonym, table, or view'
/
comment on column DBA_POLICY_GROUPS.POLICY_GROUP is
'Policy group defined'
/
create or replace public synonym DBA_POLICY_GROUPS for DBA_POLICY_GROUPS
/
grant select on DBA_POLICY_GROUPS to select_catalog_role
/

create or replace view ALL_POLICY_GROUPS (OBJECT_OWNER, OBJECT_NAME,
                          POLICY_GROUP)
as
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP
FROM DBA_POLICY_GROUPS, ALL_TABLES t
WHERE
(OBJECT_OWNER = t.OWNER AND OBJECT_NAME = t.TABLE_NAME) 
union all
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP
FROM DBA_POLICY_GROUPS, ALL_VIEWS v
WHERE
(OBJECT_OWNER = v.OWNER AND OBJECT_NAME = v.VIEW_NAME )
union all
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP
FROM DBA_POLICY_GROUPS, ALL_SYNONYMS s
WHERE
(OBJECT_OWNER = s.OWNER AND OBJECT_NAME = s.SYNONYM_NAME)
/

comment on table ALL_POLICY_GROUPS is
'All policy groups defined for any synonym, table or view accessable to the user'
/
comment on column ALL_POLICY_GROUPS.OBJECT_OWNER is
'Schema of the synonym, table, or view'
/
comment on column ALL_POLICY_GROUPS.OBJECT_NAME is
'Name of the synonym, table, or view'
/
comment on column ALL_POLICY_GROUPS.POLICY_GROUP is
'Policy group defined'
/
create or replace public synonym ALL_POLICY_GROUPS for ALL_POLICY_GROUPS
/
grant select on ALL_POLICY_GROUPS to public
/


create or replace view USER_POLICY_GROUPS (OBJECT_NAME, POLICY_GROUP)
as
SELECT OBJECT_NAME, POLICY_GROUP
FROM DBA_POLICY_GROUPS
WHERE OBJECT_OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_POLICY_GROUPS is
'All policy groups defined for any synonym, table, or view'
/
comment on column USER_POLICY_GROUPS.OBJECT_NAME is
'Name of the synonym, table, or view'
/
comment on column USER_POLICY_GROUPS.POLICY_GROUP is
'Policy group defined'
/
create or replace public synonym USER_POLICY_GROUPS for USER_POLICY_GROUPS
/
grant select on USER_POLICY_GROUPS to public
/


create or replace view DBA_POLICY_CONTEXTS (OBJECT_OWNER, OBJECT_NAME,
                          NAMESPACE,ATTRIBUTE)
as
select u.name, o.name, c.ns, c.attr
from user$ u, obj$ o, rls_ctx$ c
where u.user# = o.owner#
and c.obj# = o.obj#;
/
comment on table DBA_POLICY_CONTEXTS is
'All policy driving context defined for any synonym, table, or view in the database'
/
comment on column DBA_POLICY_CONTEXTS.OBJECT_OWNER is
'Schema of the synonym, table, or view'
/
comment on column DBA_POLICY_CONTEXTS.OBJECT_NAME is
'Name of the synonym, table, or view'
/
comment on column DBA_POLICY_CONTEXTS.NAMESPACE is
'Namespace of the context'
/
comment on column DBA_POLICY_CONTEXTS.ATTRIBUTE is
'Attribute of the context'
/
create or replace public synonym DBA_POLICY_CONTEXTS for DBA_POLICY_CONTEXTS
/
grant select on DBA_POLICY_CONTEXTS to select_catalog_role
/

create or replace view ALL_POLICY_CONTEXTS (OBJECT_OWNER, OBJECT_NAME,
                          NAMESPACE,ATTRIBUTE)
as
SELECT OBJECT_OWNER, OBJECT_NAME,NAMESPACE,ATTRIBUTE
FROM DBA_POLICY_CONTEXTS, ALL_TABLES t
WHERE
(OBJECT_OWNER = t.OWNER AND OBJECT_NAME = t.TABLE_NAME)
union all
SELECT OBJECT_OWNER, OBJECT_NAME,NAMESPACE,ATTRIBUTE
FROM DBA_POLICY_CONTEXTS, ALL_VIEWS v
WHERE
(OBJECT_OWNER = v.OWNER AND OBJECT_NAME = v.VIEW_NAME )
union all
SELECT OBJECT_OWNER, OBJECT_NAME,NAMESPACE,ATTRIBUTE
FROM DBA_POLICY_CONTEXTS, ALL_SYNONYMS s
WHERE
(OBJECT_OWNER = s.OWNER AND OBJECT_NAME = s.SYNONYM_NAME )
/
/

comment on table ALL_POLICY_CONTEXTS is
'All policy driving context defined for all synonyms, tables, or views accessable to the user'
/
comment on column ALL_POLICY_CONTEXTS.OBJECT_OWNER is
'Schema of the synonym, table, or view'
/
comment on column ALL_POLICY_CONTEXTS.OBJECT_NAME is
'Name of the synonym, table, or view'
/
comment on column ALL_POLICY_CONTEXTS.NAMESPACE is
'Namespace of the context'
/
comment on column ALL_POLICY_CONTEXTS.ATTRIBUTE is
'Attribute of the context'
/
create or replace public synonym ALL_POLICY_CONTEXTS for ALL_POLICY_CONTEXTS
/
grant select on ALL_POLICY_CONTEXTS to public
/

create or replace view USER_POLICY_CONTEXTS (OBJECT_NAME,
                          NAMESPACE,ATTRIBUTE)
as
SELECT OBJECT_NAME,NAMESPACE,ATTRIBUTE
FROM DBA_POLICY_CONTEXTS
WHERE OBJECT_OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_POLICY_CONTEXTS is
'All policy driving context defined for synonyms, tables, or views in current schema'
/
comment on column USER_POLICY_CONTEXTS.OBJECT_NAME is
'Name of the synonym, table, or view'
/
comment on column USER_POLICY_CONTEXTS.NAMESPACE is
'Namespace of the context'
/
comment on column USER_POLICY_CONTEXTS.ATTRIBUTE is
'Attribute of the context'
/
create or replace public synonym USER_POLICY_CONTEXTS for USER_POLICY_CONTEXTS
/
grant select on USER_POLICY_CONTEXTS to public
/

create or replace view DBA_SEC_RELEVANT_COLS
      (OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP, POLICY_NAME,
       SEC_REL_COLUMN, COLUMN_OPTION)
as
select u.name, o.name, r.gname, r.pname, c.name,
       decode(bitand(r.stmt_type, 4096), 0, 'NONE', 'ALL_ROWS')
from sys.rls$ r, sys.rls_sc$ sc, sys.user$ u, sys.obj$ o, sys.col$ c
where u.user# = o.owner#
  and r.obj# = o.obj#
  and r.obj# = sc.obj#
  and r.gname=sc.gname and r.pname=sc.pname
  and r.obj# = c.obj# and sc.intcol# = c.intcol# 
  and bitand(c.property, 32) = 0
/

comment on table DBA_SEC_RELEVANT_COLS is
'Security Relevant columns of all VPD policies in the database'
/
comment on column DBA_SEC_RELEVANT_COLS.OBJECT_OWNER is
'Owner of the table or view'
/
comment on column DBA_SEC_RELEVANT_COLS.OBJECT_NAME is
'Name of the table or view'
/
comment on column DBA_SEC_RELEVANT_COLS.POLICY_GROUP is
'Name of the policy group'
/
comment on column DBA_SEC_RELEVANT_COLS.POLICY_NAME is
'Name of the policy'
/
comment on column DBA_SEC_RELEVANT_COLS.SEC_REL_COLUMN is
'Name of the security relevant column'
/
comment on column DBA_SEC_RELEVANT_COLS.COLUMN_OPTION is
'Option of the security relevant column'
/
create or replace public synonym DBA_SEC_RELEVANT_COLS for DBA_SEC_RELEVANT_COLS
/
grant select on DBA_SEC_RELEVANT_COLS to select_catalog_role
/

create or replace view ALL_SEC_RELEVANT_COLS
      (OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP, POLICY_NAME,
       SEC_REL_COLUMN, COLUMN_OPTION)
as
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP, POLICY_NAME,
       SEC_REL_COLUMN, COLUMN_OPTION
from DBA_SEC_RELEVANT_COLS, ALL_TABLES t
WHERE
(OBJECT_OWNER = t.OWNER AND OBJECT_NAME = t.TABLE_NAME)
union all
SELECT OBJECT_OWNER, OBJECT_NAME, POLICY_GROUP, POLICY_NAME,
       SEC_REL_COLUMN, COLUMN_OPTION
from DBA_SEC_RELEVANT_COLS, ALL_VIEWS v
WHERE
(OBJECT_OWNER = v.OWNER AND OBJECT_NAME = v.VIEW_NAME )
/

comment on table ALL_SEC_RELEVANT_COLS is
'Security Relevant columns of all VPD policies for tables or views which the user has access'
/
comment on column ALL_SEC_RELEVANT_COLS.OBJECT_OWNER is
'Owner of the table or view'
/
comment on column ALL_SEC_RELEVANT_COLS.OBJECT_NAME is
'Name of the table or view'
/
comment on column ALL_SEC_RELEVANT_COLS.POLICY_GROUP is
'Name of the policy group'
/
comment on column ALL_SEC_RELEVANT_COLS.POLICY_NAME is
'Name of the policy'
/
comment on column ALL_SEC_RELEVANT_COLS.SEC_REL_COLUMN is
'Name of security relevant column'
/
comment on column ALL_SEC_RELEVANT_COLS.COLUMN_OPTION is
'Option of the security relevant column'
/
create or replace public synonym ALL_SEC_RELEVANT_COLS for ALL_SEC_RELEVANT_COLS
/
grant select on ALL_SEC_RELEVANT_COLS to PUBLIC with grant option
/

create or replace view USER_SEC_RELEVANT_COLS
      (OBJECT_NAME, POLICY_GROUP, POLICY_NAME, SEC_REL_COLUMN, COLUMN_OPTION)
as
SELECT OBJECT_NAME, POLICY_GROUP, POLICY_NAME, SEC_REL_COLUMN, COLUMN_OPTION
FROM ALL_SEC_RELEVANT_COLS
WHERE
OBJECT_OWNER = SYS_CONTEXT('USERENV','CURRENT_USER')
/

comment on table USER_SEC_RELEVANT_COLS is
'Security Relevant columns of VPD policies for tables or views owned by the user'
/
comment on column USER_SEC_RELEVANT_COLS.OBJECT_NAME is
'Name of the table or view'
/
comment on column USER_SEC_RELEVANT_COLS.POLICY_GROUP is
'Name of the policy group'
/
comment on column USER_SEC_RELEVANT_COLS.POLICY_NAME is
'Name of the policy'
/
comment on column USER_SEC_RELEVANT_COLS.SEC_REL_COLUMN is
'Name of security relevant column'
/
comment on column USER_SEC_RELEVANT_COLS.COLUMN_OPTION is
'Option of the security relevant column'
/
create or replace public synonym USER_SEC_RELEVANT_COLS for USER_SEC_RELEVANT_COLS
/
grant select on USER_SEC_RELEVANT_COLS to PUBLIC with grant option
/
