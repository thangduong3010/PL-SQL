Rem
Rem $Header: rdbms/admin/catxdbvfexp.sql /st_rdbms_11.2.0/3 2011/06/23 23:28:30 spetride Exp $
Rem
Rem catxdbvfexp.sql
Rem
Rem Copyright (c) 2011, Oracle and/or its affiliates. All rights reserved. 
Rem
Rem    NAME
Rem      catxdbvfexp.sql - CATalog XDB Views for Full/database EXPort (Data Pump)
Rem
Rem    DESCRIPTION
Rem      This script creates XDB views used for full/database export and 
Rem      registers these views for export, via inserts into impcalloutreg$.
Rem
Rem    NOTES
Rem      This script should be run at the end of XDB install or upgrade,
Rem      as it assumes that XDB bootstrap XMLType schemas have been created.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    06/14/11 - Backport spetride_bug-12562859 from
Rem                           st_rdbms_11.2.0
Rem    spetride    05/31/11 - create table xdb$resource_export_view_tbl DDL
Rem                           to workaround MDAPI bug TIMEZONE in ADTs
Rem    spetride    05/10/11 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

/* ------------------------------------------------------------------- */
/*                      VIEWS, TABLES FOR EXPORT                       */   
/* ------------------------------------------------------------------- */

prompt Creating views for exporting the XDB Repository 
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* (1) relational view on top of XDB.XDB$SCHEMA */
create or replace view XDB.XDB$SCHEMA_EXPORT_VIEW(
	SYS_NC_OID$,
	SCHEMA_URL, 
	TARGET_NAMESPACE, 
	VERSION, 
	NUM_PROPS, 
	FINAL_DEFAULT, 
	BLOCK_DEFAULT, 
	ELEMENT_FORM_DFLT, 
	ATTRIBUTE_FORM_DFLT, 
	ELEMENTS, 
	SIMPLE_TYPE, 
	COMPLEX_TYPES, 
	ATTRIBUTES, 
	IMPORTS, 
	INCLUDES, 
	FLAGS, 
	SYS_XDBPD$, 
	ANNOTATIONS, 
	MAP_TO_NCHAR, 
	MAP_TO_LOB, 
	GROUPS, 
	ATTRGROUPS, 
	ID, 
	VARRAY_AS_TAB, 
	SCHEMA_OWNER, 
	NOTATIONS, 
	LANG,
        ACLOID,
        OWNERID) 
as select 
	x.SYS_NC_OID$,
	x.xmldata.SCHEMA_URL, 
	x.xmldata.TARGET_NAMESPACE, 
	x.xmldata.VERSION, 
	x.xmldata.NUM_PROPS, 
	x.xmldata.FINAL_DEFAULT.VALUE, 
	x.xmldata.BLOCK_DEFAULT.VALUE, 
	x.xmldata.ELEMENT_FORM_DFLT.VALUE, 
	x.xmldata.ATTRIBUTE_FORM_DFLT.VALUE, 
	x.xmldata.ELEMENTS, 
	x.xmldata.SIMPLE_TYPE, 
	x.xmldata.COMPLEX_TYPES, 
	x.xmldata.ATTRIBUTES, 
	x.xmldata.IMPORTS, 
	x.xmldata.INCLUDES, 
	x.xmldata.FLAGS, 
	x.xmldata.SYS_XDBPD$, 
	x.xmldata.ANNOTATIONS, 
	x.xmldata.MAP_TO_NCHAR, 
	x.xmldata.MAP_TO_LOB, 
	x.xmldata.GROUPS, 
	x.xmldata.ATTRGROUPS, 
	x.xmldata.ID, 
	x.xmldata.VARRAY_AS_TAB, 
	x.xmldata.SCHEMA_OWNER, 
	x.xmldata.NOTATIONS, 
	x.xmldata.LANG,
        x.ACLOID,
        x.OWNERID 
from xdb.xdb$schema x
/

show errors;

grant select on XDB.XDB$SCHEMA_EXPORT_VIEW to select_catalog_role;

/* table with same signature as the view above */
create table XDB.XDB$SCHEMA_EXPORT_VIEW_TBL as select * from XDB.XDB$SCHEMA_EXPORT_VIEW where 0=1;

/* (2) relational view on top of XDB.XDB$SIMPLE_TYPE */
create or replace view xdb.xdb$simple_type_view
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
NAME,
ABSTRACT,
-- begin RESTRICTION
R_SYS_XDBPD$,
R_BASE_TYPE,
---- begin BASE
	R_BASE_PREFIX_CODE,
	R_BASE_NAME,
---- end BASE
R_LCL_SMPL_DECL,
---- begin FRACTIONDIGITS
	R_FDIGIT_SYS_XDBPD$,
	R_FDIGIT_A_SYS_XDBPD$,
	R_FDIGIT_A_APPINFO,
	R_FDIGIT_A_SYS_DOC,
	R_FDIGIT_VALUE,
	R_FDIGIT_FIXED,
	R_FDIGIT_ID,
---- end FRACTIONDIGITS
---- begin TOTALDIGITS
	R_TDIGIT_SYS_XDBPD$,
	R_TDIGIT_A_SYS_XDBPD$,
	R_TDIGIT_A_APPINFO,
	R_TDIGIT_A_SYS_DOC,
	R_TDIGIT_VALUE,
	R_TDIGIT_FIXED,
	R_TDIGIT_ID,
---- end TOTALDIGITS
---- begin MINLENGTH
	R_MINLENGTH_SYS_XDBPD$,
	R_MINLENGTH_A_SYS_XDBPD$,
	R_MINLENGTH_A_APPINFO,
	R_MINLENGTH_A_SYS_DOC,
	R_MINLENGTH_VALUE,
	R_MINLENGTH_FIXED,
	R_MINLENGTH_ID,
---- end MINLENGTH
---- begin MAXLENGTH
	R_MAXLENGTH_SYS_XDBPD$,
	R_MAXLENGTH_A_SYS_XDBPD$,
	R_MAXLENGTH_A_APPINFO,
	R_MAXLENGTH_A_SYS_DOC,
	R_MAXLENGTH_VALUE,
	R_MAXLENGTH_FIXED,
	R_MAXLENGTH_ID,
---- end MAXLENGTH
---- begin LENGTH
	R_LENGTH_SYS_XDBPD$,
	R_LENGTH_A_SYS_XDBPD$,
	R_LENGTH_A_APPINFO,
	R_LENGTH_A_SYS_DOC,
	R_LENGTH_VALUE,
	R_LENGTH_FIXED,
	R_LENGTH_ID,
---- end LENGTH
---- begin WHITESPACE
	R_WSPACE_SYS_XDBPD$,
	R_WSPACE_A_SYS_XDBPD$,
	R_WSPACE_A_APPINFO,
	R_WSPACE_A_DOC,
        R_WSPACE_VALUE,
	R_WSPACE_FIXED,
	R_WSPACE_ID,
---- end WHITESPACE
---- begin PERIOD
	R_PERIOD_SYS_XDBPD$,
	R_PERIOD_A_SYS_XDBPD$,
	R_PERIOD_A_APPINFO,
	R_PERIOD_A_SYS_DOC,
	R_PERIOD_VALUE,
	R_PERIOD_FIXED,
	R_PERIOD_ID,
---- end PERIOD
---- begin DURATION
	R_DURATION_SYS_XDBPD$,
	R_DURATION_A_SYS_XDBPD$,
	R_DURATION_A_APPINFO,
	R_DURATION_A_SYS_DOC,
	R_DURATION_VALUE,
	R_DURATION_FIXED,
	R_DURATION_ID,
---- end DURATION
---- begin MIN_INCLUSIVE
	R_MIN_INCLUSIVE_SYS_XDBPD$,
	R_MIN_INCLUSIVE_A_SYS_XDBPD$,
	R_MIN_INCLUSIVE_A_APPINFO,
	R_MIN_INCLUSIVE_A_SYS_DOC,
	R_MIN_INCLUSIVE_VALUE,
	R_MIN_INCLUSIVE_FIXED,
	R_MIN_INCLUSIVE_ID,
---- end MIN_INCLUSIVE
---- begin MAX_INCLUSIVE
	R_MAX_INCLUSIVE_SYS_XDBPD$,
	R_MAX_INCLUSIVE_A_SYS_XDBPD$,
	R_MAX_INCLUSIVE_A_APPINFO,
	R_MAX_INCLUSIVE_A_SYS_DOC,
	R_MAX_INCLUSIVE_VALUE,
	R_MAX_INCLUSIVE_FIXED,
	R_MAX_INCLUSIVE_ID,
---- end MAX_INCLUSIVE
---- begin MIN_EXCLUSIVE
	R_MIN_EXCLUSIVE_SYS_XDBPD$,
	R_MIN_EXCLUSIVE_A_SYS_XDBPD$,
	R_MIN_EXCLUSIVE_A_APPINFO,
	R_MIN_EXCLUSIVE_A_SYS_DOC,
	R_MIN_EXCLUSIVE_VALUE,
	R_MIN_EXCLUSIVE_FIXED,
	R_MIN_EXCLUSIVE_ID,
---- end MIN_EXCLUSIVE
---- begin MAX_EXCLUSIVE
	R_MAX_EXCLUSIVE_SYS_XDBPD$,
	R_MAX_EXCLUSIVE_A_SYS_XDBPD$,
	R_MAX_EXCLUSIVE_A_APPINFO,
	R_MAX_EXCLUSIVE_A_SYS_DOC,
	R_MAX_EXCLUSIVE_VALUE,
	R_MAX_EXCLUSIVE_FIXED,
	R_MAX_EXCLUSIVE_ID,
---- end MAX_EXCLUSIVE
	R_PATTERN,
	R_ENUMERATION,
	R_A_SYS_XDBPD$,
	R_A_APPINFO,
	R_A_SYS_DOC,
	R_ID,
-- end RESTRICTION
-- begin LIST_TYPE
	L_SYS_XDBPD$,
	L_A_SYS_XDBPD$,
	L_A_APPINFO,
	L_A_DOC,
	L_ITEM_TYPE_PREFIX_CODE,
	L_ITEM_TYPE_NAME,
	L_TYPE_REF,
	L_SIMPLE_TYPE,
-- end LIST_TYPE
-- begin UNION_TYPE
	U_SYS_XDBPD$,
	U_A_SYS_XDBPD$,
	U_A_APPINFO,
	U_A_DOC,
	U_MEMBER_TYPES,
	U_SIMPLE_TYPES,
	U_TYPE_REFS,
-- end UNION_TYPE
-- begin ANNOTATION
-- end ANNOTATION
	A_SYS_XDBPD$,
	A_APPINFO,
	A_DOC,
-- end ANNOTATION
ID,
TYPEID,
FINAL_INFO,
SQLTYPE
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
x.xmldata.NAME,
x.xmldata.ABSTRACT,
-- begin RESTRICTION
x.xmldata.RESTRICTION.SYS_XDBPD$,
reftohex(x.xmldata.RESTRICTION.BASE_TYPE),
---- begin BASE
	x.xmldata.RESTRICTION.BASE.PREFIX_CODE,
	x.xmldata.RESTRICTION.BASE.NAME,
---- end BASE
reftohex(x.xmldata.RESTRICTION.LCL_SMPL_DECL),
---- begin FRACTIONDIGITS
	x.xmldata.RESTRICTION.FRACTIONDIGITS.SYS_XDBPD$,
	x.xmldata.RESTRICTION.FRACTIONDIGITS.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.FRACTIONDIGITS.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.FRACTIONDIGITS.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.FRACTIONDIGITS.VALUE,
	x.xmldata.RESTRICTION.FRACTIONDIGITS.FIXED,
	x.xmldata.RESTRICTION.FRACTIONDIGITS.ID,
---- end FRACTIONDIGITS
---- begin TOTALDIGITS
	x.xmldata.RESTRICTION.TOTALDIGITS.SYS_XDBPD$,
	x.xmldata.RESTRICTION.TOTALDIGITS.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.TOTALDIGITS.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.TOTALDIGITS.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.TOTALDIGITS.VALUE,
	x.xmldata.RESTRICTION.TOTALDIGITS.FIXED,
	x.xmldata.RESTRICTION.TOTALDIGITS.ID,
---- end TOTALDIGITS
---- begin MINLENGTH
	x.xmldata.RESTRICTION.MINLENGTH.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MINLENGTH.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MINLENGTH.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.MINLENGTH.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.MINLENGTH.VALUE,
	x.xmldata.RESTRICTION.MINLENGTH.FIXED,
	x.xmldata.RESTRICTION.MINLENGTH.ID,
---- end MINLENGTH
---- begin MAXLENGTH
	x.xmldata.RESTRICTION.MAXLENGTH.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MAXLENGTH.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MAXLENGTH.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.MAXLENGTH.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.MAXLENGTH.VALUE,
	x.xmldata.RESTRICTION.MAXLENGTH.FIXED,
	x.xmldata.RESTRICTION.MAXLENGTH.ID,
---- end MAXLENGTH
---- begin LENGTH
	x.xmldata.RESTRICTION.LENGTH.SYS_XDBPD$,
	x.xmldata.RESTRICTION.LENGTH.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.LENGTH.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.LENGTH.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.LENGTH.VALUE,
	x.xmldata.RESTRICTION.LENGTH.FIXED,
	x.xmldata.RESTRICTION.LENGTH.ID,
---- end LENGTH
---- begin WHITESPACE
	x.xmldata.RESTRICTION.WHITESPACE.SYS_XDBPD$,
	x.xmldata.RESTRICTION.WHITESPACE.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.WHITESPACE.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.WHITESPACE.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.WHITESPACE.VALUE.VALUE,
	x.xmldata.RESTRICTION.WHITESPACE.FIXED,
	x.xmldata.RESTRICTION.WHITESPACE.ID,
---- end WHITESPACE
---- begin PERIOD
	x.xmldata.RESTRICTION.PERIOD.SYS_XDBPD$,
	x.xmldata.RESTRICTION.PERIOD.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.PERIOD.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.PERIOD.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.PERIOD.VALUE,
	x.xmldata.RESTRICTION.PERIOD.FIXED,
	x.xmldata.RESTRICTION.PERIOD.ID,
---- end PERIOD
---- begin DURATION
	x.xmldata.RESTRICTION.DURATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.DURATION.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.DURATION.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.DURATION.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.DURATION.VALUE,
	x.xmldata.RESTRICTION.DURATION.FIXED,
	x.xmldata.RESTRICTION.DURATION.ID,
---- end DURATION
---- begin MIN_INCLUSIVE
	x.xmldata.RESTRICTION.MIN_INCLUSIVE.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MIN_INCLUSIVE.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MIN_INCLUSIVE.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.MIN_INCLUSIVE.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.MIN_INCLUSIVE.VALUE,
	x.xmldata.RESTRICTION.MIN_INCLUSIVE.FIXED,
	x.xmldata.RESTRICTION.MIN_INCLUSIVE.ID,
---- end MIN_INCLUSIVE
---- begin MAX_INCLUSIVE
	x.xmldata.RESTRICTION.MAX_INCLUSIVE.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MAX_INCLUSIVE.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MAX_INCLUSIVE.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.MAX_INCLUSIVE.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.MAX_INCLUSIVE.VALUE,
	x.xmldata.RESTRICTION.MAX_INCLUSIVE.FIXED,
	x.xmldata.RESTRICTION.MAX_INCLUSIVE.ID,
---- end MAX_INCLUSIVE
---- begin MIN_EXCLUSIVE
	x.xmldata.RESTRICTION.MIN_EXCLUSIVE.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MIN_EXCLUSIVE.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MIN_EXCLUSIVE.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.MIN_EXCLUSIVE.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.MIN_EXCLUSIVE.VALUE,
	x.xmldata.RESTRICTION.MIN_EXCLUSIVE.FIXED,
	x.xmldata.RESTRICTION.MIN_EXCLUSIVE.ID,
---- end MIN_EXCLUSIVE
---- begin MAX_EXCLUSIVE
	x.xmldata.RESTRICTION.MAX_EXCLUSIVE.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MAX_EXCLUSIVE.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.MAX_EXCLUSIVE.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.MAX_EXCLUSIVE.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.MAX_EXCLUSIVE.VALUE,
	x.xmldata.RESTRICTION.MAX_EXCLUSIVE.FIXED,
	x.xmldata.RESTRICTION.MAX_EXCLUSIVE.ID,
---- end MAX_EXCLUSIVE
	x.xmldata.RESTRICTION.PATTERN,
	x.xmldata.RESTRICTION.ENUMERATION,
	x.xmldata.RESTRICTION.ANNOTATION.SYS_XDBPD$,
	x.xmldata.RESTRICTION.ANNOTATION.APPINFO,
	x.xmldata.RESTRICTION.ANNOTATION.DOCUMENTATION,
	x.xmldata.RESTRICTION.ID,
-- end RESTRICTION
-- begin LIST_TYPE
	x.xmldata.LIST_TYPE.SYS_XDBPD$,
	x.xmldata.LIST_TYPE.ANNOTATION.SYS_XDBPD$,
	x.xmldata.LIST_TYPE.ANNOTATION.APPINFO,
	x.xmldata.LIST_TYPE.ANNOTATION.DOCUMENTATION,
	x.xmldata.LIST_TYPE.ITEM_TYPE.PREFIX_CODE,
	x.xmldata.LIST_TYPE.ITEM_TYPE.NAME,
	reftohex(x.xmldata.LIST_TYPE.TYPE_REF),
	reftohex(x.xmldata.LIST_TYPE.SIMPLE_TYPE),
-- end LIST_TYPE
-- begin UNION_TYPE
	x.xmldata.UNION_TYPE.SYS_XDBPD$,
	x.xmldata.UNION_TYPE.ANNOTATION.SYS_XDBPD$,
	x.xmldata.UNION_TYPE.ANNOTATION.APPINFO,
	x.xmldata.UNION_TYPE.ANNOTATION.DOCUMENTATION,
	x.xmldata.UNION_TYPE.MEMBER_TYPES,
	x.xmldata.UNION_TYPE.SIMPLE_TYPES,
	x.xmldata.UNION_TYPE.TYPE_REFS,
-- end UNION_TYPE
-- begin ANNOTATION
        x.xmldata.ANNOTATION.SYS_XDBPD$,
        x.xmldata.ANNOTATION.APPINFO,
        x.xmldata.ANNOTATION.DOCUMENTATION,
-- end ANNOTATION
	x.xmldata.ID,
	x.xmldata.TYPEID,
	x.xmldata.FINAL_INFO.VALUE,
	x.xmldata.SQLTYPE
from xdb.xdb$simple_type x;

show errors;

grant select on XDB.XDB$SIMPLE_TYPE_VIEW to select_catalog_role;

create table xdb.xdb$simple_type_view_tbl as select * from xdb.xdb$simple_type_view where 0=1;


/* (3) relational view on top of XDB.XDB$COMPLEX_TYPE */
create or replace view xdb.xdb$complex_type_view
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
BASE_TYPE,
NAME,
ABSTRACT,
MIXED,
FINAL_INFO,
BLOCK,
ATTRIBUTES,
ANY_ATTRS,
ATTR_GROUPS,
ALL_KID,
CHOICE_KID,
SEQUENCE_KID,
GROUP_KID,
-- begin COMPLEXCONTENT
C_SYS_XDBPD$,
C_MIXED,
---- begin RESTRICTION
	C_R_SYS_XDBPD$,
	C_R_BASE_PREFIX_CODE,
	C_R_BASE_NAME,
	C_R_ATTRIBUTES,
	C_R_ANY_ATTRS,
	C_R_ATTR_GROUPS,
	C_R_ALL_KID,
	C_R_CHOICE_KID,
	C_R_SEQUENCE_KID,
	C_R_GROUP_KID,
	C_R_A_SYS_XDBPD$,
	C_R_A_APPINFO,
	C_R_A_DOCUMENTATION,
	C_R_ID,
---- end RESTRICTION
---- begin EXTENSION
	C_E_SYS_XDBPD$,
	C_E_BASE_PREFIX_CODE,
	C_E_BASE_NAME,
	C_E_ATTRIBUTES,
	C_E_ANY_ATTRS,
	C_E_ATTR_GROUPS,
	C_E_ALL_KID,
	C_E_CHOICE_KID,
	C_E_SEQUENCE_KID,
	C_E_GROUP_KID,
	C_E_A_SYS_XDBPD$,
	C_E_A_APPINFO,
	C_E_A_DOCUMENTATION,
	C_E_ID,
---- end EXTENSION
C_ANNOTATION_SYS_XDBPD$,
C_ANNOTATION_APPINFO,
C_ANNOTATION_DOCUMENTATION,
C_ID,
-- end COMPLEXCONTENT 
annotation_sys_xdbpd$,
annotation_appinfo,
annotation_doc,
sqltype, 
sqlschema,
maintain_dom,
subtype_refs,
id,
-- begin SIMPLECONT
s_sys_xdbpd$,
	-- begin RESTRICTION
	r_sys_xdbpd$,
	r_base_prefix_code,
	r_base_name,
        r_id,
	r_lcl_smpl_decl,
	r_attributes,
	r_any_attrs,
	r_attr_groups,
	r_a_sys_xdbpd$,
	r_a_appinfo,
	r_a_doc,
	-- begin FDIGIT
	r_fdigit_sys_xdbpd$,
	r_fdigit_a_sys_xdbpd$,
	r_fdigit_a_appinfo,
	r_fdigit_a_doc,
	r_fdigit_value,
	r_fdigit_fixed,
	r_fdigit_id,
	-- end FDIGIT
	-- begin TDIGIT
	r_tdigit_sys_xdbpd$,
	r_tdigit_a_sys_xdbpd$,
	r_tdigit_a_appinfo,
	r_tdigit_a_doc,
	r_tdigit_value,
	r_tdigit_fixed,
	r_tdigit_id,
	-- end TDIGIT
	-- begin MINLENGTH
	r_minlength_sys_xdbpd$,
	r_minlength_a_sys_xdbpd$,
	r_minlength_a_appinfo,
	r_minlength_a_doc,
	r_minlength_value,
	r_minlength_fixed,
	r_minlength_id,
	-- end MINLENGTH
	-- begin MAXLENGTH
        r_maxlength_sys_xdbpd$,
	r_maxlength_a_sys_xdbpd$,
	r_maxlength_a_appinfo,
	r_maxlength_a_doc,
	r_maxlength_value,
	r_maxlength_fixed,
	r_maxlength_id,
	-- end MAXLENGTH
        -- begin WHITESPACE
	r_wspace_sys_xdbpd$,
	r_wspace_a_sys_xdbpd$,
	r_wspace_a_appinfo,
	r_wspace_a_doc,
	r_wspace_value,
	r_wspace_fixed,
	r_wspace_id,
	-- end WHISTESPACE
	-- begin PERIOD
	r_period_sys_xdbpd$,
	r_period_a_sys_xdbpd$,
	r_period_a_appinfo,
	r_period_a_doc,
	r_period_value,
	r_period_fixed,
	r_period_id,
	-- end PERIOD
	-- begin DURATION
	r_duration_sys_xdbpd$,
	r_duration_a_sys_xdbpd$,
	r_duration_a_appinfo,
	r_duration_a_doc,
	r_duration_value,
	r_duration_fixed,
	r_duration_id,
	-- end DURATION	
        -- begin MIN_INCLUSIVE
	r_min_i_sys_xdbpd$,
	r_min_i_a_sys_xdbpd$,
	r_min_i_a_appinfo,
	r_min_i_a_doc,
	r_min_i_value,
	r_min_i_fixed,
	r_min_i_id,
        -- end MIN_INCLUSIVE
        -- begin MAX_INCLUSIVE
	r_max_i_sys_xdbpd$,
	r_max_i_a_sys_xdbpd$,
	r_max_i_a_appinfo,
	r_max_i_a_doc,
	r_max_i_value,
	r_max_i_fixed,
	r_max_i_id,
        -- end MAX_INCLUSIVE
	s_pattern,
	s_enumeration,
        -- begin MIN_EXCLUSIVE
	r_min_e_sys_xdbpd$,
	r_min_e_a_sys_xdbpd$,
	r_min_e_a_appinfo,
	r_min_e_a_doc,
	r_min_e_value,
	r_min_e_fixed,
	r_min_e_id,
        -- end MIN_EXCLUSIVE
        -- begin MAX_EXCLUSIVE
	r_max_e_sys_xdbpd$,
	r_max_e_a_sys_xdbpd$,
	r_max_e_a_appinfo,
	r_max_e_a_doc,
	r_max_e_value,
	r_max_e_fixed,
	r_max_e_id,
        -- end MAX_EXCLUSIVE
	-- begin LENGTH
	r_length_sys_xdbpd$,
	r_length_a_sys_xdbpd$,
	r_length_a_appinfo,
	r_length_a_doc,
	r_length_value,
	r_length_fixed,
	r_length_id,
	-- end LENGTH
	-- end RESTRICTION
	-- begin EXTENSION
	s_e_sys_xdbpd$,
	s_e_base_prefix_code,
	s_e_base_name,
	s_e_id,
	s_e_attributes,
	s_e_any_attrs,
	s_e_attr_groups,
	s_e_a_sys_xdbpd$,
	s_e_a_appinfo,
	s_e_a_doc,
	-- end EXTENSION
s_a_sys_xdbpd$,
s_a_appinfo,
s_a_doc,
s_id,
-- end SIMPLECONT
typeid
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
reftohex(x.xmldata.BASE_TYPE),
x.xmldata.NAME,
x.xmldata.ABSTRACT,
x.xmldata.MIXED,
x.xmldata.FINAL_INFO.VALUE,
x.xmldata.BLOCK.VALUE,
x.xmldata.ATTRIBUTES,
x.xmldata.ANY_ATTRS,
x.xmldata.ATTR_GROUPS,
reftohex(x.xmldata.ALL_KID),
reftohex(x.xmldata.CHOICE_KID),
reftohex(x.xmldata.SEQUENCE_KID),
reftohex(x.xmldata.GROUP_KID),
-- begin COMPLEXCONTENT 
x.xmldata.COMPLEXCONTENT.SYS_XDBPD$,
x.xmldata.COMPLEXCONTENT.MIXED,
---- begin RESTRICTION
	x.xmldata.COMPLEXCONTENT.RESTRICTION.SYS_XDBPD$,
	x.xmldata.COMPLEXCONTENT.RESTRICTION.BASE.PREFIX_CODE,
	x.xmldata.COMPLEXCONTENT.RESTRICTION.BASE.NAME,
	x.xmldata.COMPLEXCONTENT.RESTRICTION.ATTRIBUTES,
	x.xmldata.COMPLEXCONTENT.RESTRICTION.ANY_ATTRS,
	x.xmldata.COMPLEXCONTENT.RESTRICTION.ATTR_GROUPS,
	reftohex(x.xmldata.COMPLEXCONTENT.RESTRICTION.ALL_KID),
	reftohex(x.xmldata.COMPLEXCONTENT.RESTRICTION.CHOICE_KID),
	reftohex(x.xmldata.COMPLEXCONTENT.RESTRICTION.SEQUENCE_KID),
	reftohex(x.xmldata.COMPLEXCONTENT.RESTRICTION.GROUP_KID),
	x.xmldata.COMPLEXCONTENT.RESTRICTION.ANNOTATION.SYS_XDBPD$,
	x.xmldata.COMPLEXCONTENT.RESTRICTION.ANNOTATION.APPINFO,
	x.xmldata.COMPLEXCONTENT.RESTRICTION.ANNOTATION.DOCUMENTATION,
	x.xmldata.COMPLEXCONTENT.RESTRICTION.ID,
---- end RESTRICTION
---- begin EXTENSION
	x.xmldata.COMPLEXCONTENT.EXTENSION.SYS_XDBPD$,
	x.xmldata.COMPLEXCONTENT.EXTENSION.BASE.PREFIX_CODE,
	x.xmldata.COMPLEXCONTENT.EXTENSION.BASE.NAME,
	x.xmldata.COMPLEXCONTENT.EXTENSION.ATTRIBUTES,
	x.xmldata.COMPLEXCONTENT.EXTENSION.ANY_ATTRS,
	x.xmldata.COMPLEXCONTENT.EXTENSION.ATTR_GROUPS,
	reftohex(x.xmldata.COMPLEXCONTENT.EXTENSION.ALL_KID),
	reftohex(x.xmldata.COMPLEXCONTENT.EXTENSION.CHOICE_KID),
	reftohex(x.xmldata.COMPLEXCONTENT.EXTENSION.SEQUENCE_KID),
	reftohex(x.xmldata.COMPLEXCONTENT.EXTENSION.GROUP_KID),
	x.xmldata.COMPLEXCONTENT.EXTENSION.ANNOTATION.SYS_XDBPD$,
	x.xmldata.COMPLEXCONTENT.EXTENSION.ANNOTATION.APPINFO,
	x.xmldata.COMPLEXCONTENT.EXTENSION.ANNOTATION.DOCUMENTATION,
	x.xmldata.COMPLEXCONTENT.EXTENSION.ID,
---- end EXTENSION
x.xmldata.COMPLEXCONTENT.ANNOTATION.SYS_XDBPD$,
x.xmldata.COMPLEXCONTENT.ANNOTATION.APPINFO,
x.xmldata.COMPLEXCONTENT.ANNOTATION.DOCUMENTATION,
x.xmldata.COMPLEXCONTENT.ID,
-- end COMPLEXCONTENT 
x.xmldata.annotation.sys_xdbpd$,
x.xmldata.annotation.appinfo,
x.xmldata.annotation.documentation,
x.xmldata.sqltype,
x.xmldata.sqlschema,
x.xmldata.maintain_dom,
x.xmldata.subtype_refs,
x.xmldata.id,
-- begin SIMPLECONT
x.xmldata.SIMPLECONT.sys_xdbpd$,
	-- begin RESTRICTION
	x.xmldata.SIMPLECONT.RESTRICTION.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.base.prefix_code,
	x.xmldata.SIMPLECONT.RESTRICTION.base.name,
	x.xmldata.SIMPLECONT.RESTRICTION.id,
	reftohex(x.xmldata.SIMPLECONT.RESTRICTION.lcl_smpl_decl),
	x.xmldata.SIMPLECONT.RESTRICTION.attributes,
	x.xmldata.SIMPLECONT.RESTRICTION.any_attrs,
	x.xmldata.SIMPLECONT.RESTRICTION.attr_groups,
	x.xmldata.SIMPLECONT.RESTRICTION.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.annotation.documentation,
	-- begin FDIGIT
	x.xmldata.SIMPLECONT.RESTRICTION.fractiondigits.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.fractiondigits.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.fractiondigits.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.fractiondigits.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.fractiondigits.value,
	x.xmldata.SIMPLECONT.RESTRICTION.fractiondigits.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.fractiondigits.id,
	-- end FDIGIT
	-- begin TDIGIT
	x.xmldata.SIMPLECONT.RESTRICTION.totaldigits.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.totaldigits.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.totaldigits.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.totaldigits.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.totaldigits.value,
	x.xmldata.SIMPLECONT.RESTRICTION.totaldigits.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.totaldigits.id,
	-- end TDIGIT
	-- begin MINLENGTH
	x.xmldata.SIMPLECONT.RESTRICTION.minlength.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.minlength.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.minlength.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.minlength.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.minlength.value,
	x.xmldata.SIMPLECONT.RESTRICTION.minlength.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.minlength.id,
	-- end MINLENGTH
	-- begin MAXLENGTH
	x.xmldata.SIMPLECONT.RESTRICTION.maxlength.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.maxlength.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.maxlength.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.maxlength.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.maxlength.value,
	x.xmldata.SIMPLECONT.RESTRICTION.maxlength.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.maxlength.id,
	-- end MAXLENGTH
        -- begin WHITESPACE
	x.xmldata.SIMPLECONT.RESTRICTION.whitespace.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.whitespace.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.whitespace.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.whitespace.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.whitespace.value.value,
	x.xmldata.SIMPLECONT.RESTRICTION.whitespace.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.whitespace.id,
	-- end WHISTESPACE
	-- begin PERIOD
	x.xmldata.SIMPLECONT.RESTRICTION.period.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.period.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.period.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.period.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.period.value,
	x.xmldata.SIMPLECONT.RESTRICTION.period.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.period.id,
	-- end PERIOD
	-- begin DURATION
	x.xmldata.SIMPLECONT.RESTRICTION.duration.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.duration.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.duration.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.duration.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.duration.value,
	x.xmldata.SIMPLECONT.RESTRICTION.duration.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.duration.id,
	-- end DURATION	
        -- begin MIN_INCLUSIVE
	x.xmldata.SIMPLECONT.RESTRICTION.min_inclusive.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.min_inclusive.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.min_inclusive.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.min_inclusive.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.min_inclusive.value,
	x.xmldata.SIMPLECONT.RESTRICTION.min_inclusive.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.min_inclusive.id,
        -- end MIN_INCLUSIVE
        -- begin MAX_INCLUSIVE
	x.xmldata.SIMPLECONT.RESTRICTION.max_inclusive.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.max_inclusive.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.max_inclusive.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.max_inclusive.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.max_inclusive.value,
	x.xmldata.SIMPLECONT.RESTRICTION.min_inclusive.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.max_inclusive.id,
        -- end MAX_INCLUSIVE
	x.xmldata.SIMPLECONT.RESTRICTION.pattern,
	x.xmldata.SIMPLECONT.RESTRICTION.enumeration,
        -- begin MIN_EXCLUSIVE
	x.xmldata.SIMPLECONT.RESTRICTION.min_exclusive.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.min_exclusive.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.min_exclusive.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.min_exclusive.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.min_exclusive.value,
	x.xmldata.SIMPLECONT.RESTRICTION.min_exclusive.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.min_exclusive.id,
        -- end MIN_EXCLUSIVE
        -- begin MAX_EXCLUSIVE
	x.xmldata.SIMPLECONT.RESTRICTION.max_exclusive.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.max_exclusive.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.max_exclusive.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.max_exclusive.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.max_exclusive.value,
	x.xmldata.SIMPLECONT.RESTRICTION.max_exclusive.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.max_exclusive.id,
        -- end MAX_EXCLUSIVE
	-- begin LENGTH
	x.xmldata.SIMPLECONT.RESTRICTION.length.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.length.annotation.sys_xdbpd$,
	x.xmldata.SIMPLECONT.RESTRICTION.length.annotation.appinfo,
	x.xmldata.SIMPLECONT.RESTRICTION.length.annotation.documentation,
	x.xmldata.SIMPLECONT.RESTRICTION.length.value,
	x.xmldata.SIMPLECONT.RESTRICTION.length.fixed,
	x.xmldata.SIMPLECONT.RESTRICTION.length.id,
	-- end LENGTH
	-- end RESTRICTION
	-- begin EXTENSION
	x.xmldata.SIMPLECONT.EXTENSION.sys_xdbpd$,
	x.xmldata.SIMPLECONT.EXTENSION.base.prefix_code,
	x.xmldata.SIMPLECONT.EXTENSION.base.name,
	x.xmldata.SIMPLECONT.EXTENSION.id,
	x.xmldata.SIMPLECONT.EXTENSION.attributes,
	x.xmldata.SIMPLECONT.EXTENSION.any_attrs,
	x.xmldata.SIMPLECONT.EXTENSION.attr_groups,
	x.xmldata.SIMPLECONT.EXTENSION.ANNOTATION.sys_xdbpd$,
	x.xmldata.SIMPLECONT.EXTENSION.ANNOTATION.appinfo,
	x.xmldata.SIMPLECONT.EXTENSION.ANNOTATION.documentation,
	-- end EXTENSION
x.xmldata.SIMPLECONT.ANNOTATION.sys_xdbpd$,
x.xmldata.SIMPLECONT.ANNOTATION.appinfo,
x.xmldata.SIMPLECONT.ANNOTATION.documentation,
x.xmldata.SIMPLECONT.id,
-- end SIMPLECONT
x.xmldata.typeid
from xdb.xdb$complex_type x;

show errors;

grant select on XDB.XDB$COMPLEX_TYPE_VIEW to select_catalog_role;

create table xdb.xdb$complex_type_view_tbl as select * from xdb.xdb$complex_type_view where 0=1;


/* (4) relational view on top of XDB.XDB$ALL_MODEL */
create or replace view xdb.xdb$all_model_view 
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
MIN_OCCURS,
MAX_OCCURS,
ELEMENTS,
CHOICE_KIDS,
SEQUENCE_KIDS,
ANYS,
GROUPS,
A_SYS_XDBPD$,
A_APPINFO,
A_DOCUMENTATION,
ID
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
x.xmldata.MIN_OCCURS,
x.xmldata.MAX_OCCURS,
x.xmldata.ELEMENTS,
x.xmldata.CHOICE_KIDS,
x.xmldata.SEQUENCE_KIDS,
x.xmldata.ANYS,
x.xmldata.GROUPS,
x.xmldata.ANNOTATION.SYS_XDBPD$,
x.xmldata.ANNOTATION.APPINFO,
x.xmldata.ANNOTATION.DOCUMENTATION,
x.xmldata.ID
from xdb.xdb$all_model x;

show errors;

grant select on XDB.XDB$ALL_MODEL_VIEW to select_catalog_role;

create table xdb.xdb$all_model_view_tbl as select * from xdb.xdb$all_model_view where 0=1;


/* (5) relational view on top of XDB.XDB$CHOICE_MODEL */
create or replace view xdb.xdb$choice_model_view 
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
MIN_OCCURS,
MAX_OCCURS,
ELEMENTS,
CHOICE_KIDS,
SEQUENCE_KIDS,
ANYS,
GROUPS,
A_SYS_XDBPD$,
A_APPINFO,
A_DOCUMENTATION,
ID
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
x.xmldata.MIN_OCCURS,
x.xmldata.MAX_OCCURS,
x.xmldata.ELEMENTS,
x.xmldata.CHOICE_KIDS,
x.xmldata.SEQUENCE_KIDS,
x.xmldata.ANYS,
x.xmldata.GROUPS,
x.xmldata.ANNOTATION.SYS_XDBPD$,
x.xmldata.ANNOTATION.APPINFO,
x.xmldata.ANNOTATION.DOCUMENTATION,
x.xmldata.ID
from xdb.xdb$choice_model x;

show errors;

grant select on XDB.XDB$CHOICE_MODEL_VIEW to select_catalog_role;

create table xdb.xdb$choice_model_view_tbl as select * from xdb.xdb$choice_model_view where 0=1;


/* (6) relational view on top of XDB.XDB$SEQUENCE_MODEL */
create or replace view xdb.xdb$sequence_model_view 
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
MIN_OCCURS,
MAX_OCCURS,
ELEMENTS,
CHOICE_KIDS,
SEQUENCE_KIDS,
ANYS,
GROUPS,
A_SYS_XDBPD$,
A_APPINFO,
A_DOCUMENTATION,
ID
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
x.xmldata.MIN_OCCURS,
x.xmldata.MAX_OCCURS,
x.xmldata.ELEMENTS,
x.xmldata.CHOICE_KIDS,
x.xmldata.SEQUENCE_KIDS,
x.xmldata.ANYS,
x.xmldata.GROUPS,
x.xmldata.ANNOTATION.SYS_XDBPD$,
x.xmldata.ANNOTATION.APPINFO,
x.xmldata.ANNOTATION.DOCUMENTATION,
x.xmldata.ID
from xdb.xdb$sequence_model x;

show errors;

grant select on XDB.XDB$SEQUENCE_MODEL_VIEW to select_catalog_role;

create table xdb.xdb$sequence_model_view_tbl as select * from xdb.xdb$sequence_model_view where 0=1;

/* (7) relational view on top of XDB.XDB$GROUP_DEF */
create or replace view xdb.xdb$group_def_view
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
NAME,
ALL_KID,
CHOICE_KID,
SEQUENCE_KID,
A_SYS_XDBPD$,
A_APPINFO,
A_DOCUMENTATION,
ID
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
x.xmldata.NAME,
reftohex(x.xmldata.ALL_KID),
reftohex(x.xmldata.CHOICE_KID),
reftohex(x.xmldata.SEQUENCE_KID),
x.xmldata.ANNOTATION.SYS_XDBPD$,
x.xmldata.ANNOTATION.APPINFO,
x.xmldata.ANNOTATION.DOCUMENTATION,
x.xmldata.ID
from xdb.xdb$group_def x;

show errors;

grant select on XDB.XDB$GROUP_DEF_VIEW to select_catalog_role;

create table xdb.xdb$group_def_view_tbl as select * from xdb.xdb$group_def_view where 0=1;


/* (8) relational view on top of XDB.XDB$GROUP_REF */
create or replace view xdb.xdb$group_ref_view 
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
MIN_OCCURS,
MAX_OCCURS,
G_PREFIX_CODE,
G_NAME,
GROUPREF_REF,
A_SYS_XDBPD$,
A_APPINFO,
A_DOCUMENTATION,
ID
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
x.xmldata.MIN_OCCURS,
x.xmldata.MAX_OCCURS,
x.xmldata.GROUPREF_NAME.PREFIX_CODE,
x.xmldata.GROUPREF_NAME.NAME,
reftohex(x.xmldata.GROUPREF_REF),
x.xmldata.ANNOTATION.SYS_XDBPD$,
x.xmldata.ANNOTATION.APPINFO,
x.xmldata.ANNOTATION.DOCUMENTATION,
x.xmldata.ID
from xdb.xdb$group_ref x;

show errors;

grant select on XDB.XDB$GROUP_REF_VIEW to select_catalog_role;

create table xdb.xdb$group_ref_view_tbl as select * from xdb.xdb$group_ref_view where 0=1;


/* (9) relational view on top of XDB.XDB$ATTRIBUTE */
create or replace view xdb.xdb$attribute_view
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
PROP_NUMBER,
NAME,
TYPENAME_PREFIX_CODE,
TYPENAME_NAME,
MEM_BYTE_LENGTH,
MEM_TYPE_CODE,
SYSTEM,
MUTABLE,
FORM,
SQLNAME,
SQLTYPE,
SQLSCHEMA,
JAVA_TYPE,
DEFAULT_VALUE,
SMPL_TYPE_DECL ,
TYPE_REF,
PROPREF_NAME_PREFIX_CODE,
PROPREF_NAME_NAME,
PROPREF_REF,
ATTR_USE,
FIXED_VALUE,
GLOBAL,
A_SYS_XDBPD$,
A_APPINFO,
A_DOCUMENTATION,
SQLCOLLTYPE,
SQLCOLLSCHEMA,
HIDDEN,
TRANSIENT,
ID,
BASEPROP
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
x.xmldata.PROP_NUMBER,
x.xmldata.NAME,
x.xmldata.TYPENAME.PREFIX_CODE,
x.xmldata.TYPENAME.NAME,
x.xmldata.MEM_BYTE_LENGTH,
x.xmldata.MEM_TYPE_CODE,
x.xmldata.SYSTEM,
x.xmldata.MUTABLE,
x.xmldata.FORM.VALUE,
x.xmldata.SQLNAME,
x.xmldata.SQLTYPE,
x.xmldata.SQLSCHEMA,
x.xmldata.JAVA_TYPE.VALUE,
x.xmldata.DEFAULT_VALUE,
reftohex(x.xmldata.SMPL_TYPE_DECL),
reftohex(x.xmldata.TYPE_REF),
x.xmldata.PROPREF_NAME.PREFIX_CODE,
x.xmldata.PROPREF_NAME.NAME,
reftohex(x.xmldata.PROPREF_REF),
x.xmldata.ATTR_USE.VALUE,
x.xmldata.FIXED_VALUE,
x.xmldata.GLOBAL,
x.xmldata.ANNOTATION.SYS_XDBPD$,
x.xmldata.ANNOTATION.APPINFO,
x.xmldata.ANNOTATION.DOCUMENTATION,
x.xmldata.SQLCOLLTYPE,
x.xmldata.SQLCOLLSCHEMA,
x.xmldata.HIDDEN,
x.xmldata.TRANSIENT.VALUE,
x.xmldata.ID,
x.xmldata.BASEPROP
from xdb.xdb$attribute x;

show errors;

grant select on XDB.XDB$ATTRIBUTE_VIEW to select_catalog_role;

create table xdb.xdb$attribute_view_tbl as select * from xdb.xdb$attribute_view where 0=1;


/* (10) relational view on top of XDB.XDB$ELEMENT */
create or replace view xdb.xdb$element_view
(
SYS_NC_OID$,
-- begin PROPERTY
P_SYS_XDBPD$,
P_PARENT_SCHEMA,
P_PROP_NUMBER,
P_NAME,
P_TYPENAME_PREFIX_CODE,
P_TYPENAME_NAME,
P_MEM_BYTE_LENGTH,
P_MEM_TYPE_CODE,
P_SYSTEM,
P_MUTABLE,
P_FORM,
P_SQLNAME,
P_SQLTYPE,
P_SQLSCHEMA,
P_JAVA_TYPE,
P_DEFAULT_VALUE,
P_SMPL_TYPE_DECL ,
P_TYPE_REF,
P_PROPREF_NAME_PREFIX_CODE,
P_PROPREF_NAME_NAME,
P_PROPREF_REF,
P_ATTR_USE,
P_FIXED_VALUE,
P_GLOBAL,
P_A_SYS_XDBPD$,
P_A_APPINFO,
P_A_DOCUMENTATION,
P_SQLCOLLTYPE,
P_SQLCOLLSCHEMA,
P_HIDDEN,
P_TRANSIENT,
P_ID,
P_BASEPROP,
-- end PROPERTY
SUBS_GROUP_PREFIX_CODE,
SUBS_GROUP_NAME,
NUM_COLS,
NILLABLE,
FINAL_INFO,
BLOCK,
ABSTRACT,
MEM_INLINE,
SQL_INLINE,
JAVA_INLINE,
MAINTAIN_DOM,
DEFAULT_TABLE,
DEFAULT_TABLE_SCHEMA,
TABLE_PROPS,
JAVA_CLASSNAME ,
BEAN_CLASSNAME ,
BASE_SQLNAME,
CPLX_TYPE_DECL,
SUBS_GROUP_REFS,
DEFAULT_XSL,
MIN_OCCURS,
MAX_OCCURS,
IS_FOLDER,
MAINTAIN_ORDER,
COL_PROPS,
DEFAULT_ACL,
HEAD_ELEM_REF,
UNIQUES,
KEYS,
KEYREFS,
IS_TRANSLATABLE,
XDB_MAX_OCCURS
)
as select
x.sys_nc_oid$,
-- begin PROPERTY
x.xmldata.PROPERTY.SYS_XDBPD$,
reftohex(x.xmldata.PROPERTY.PARENT_SCHEMA),
x.xmldata.PROPERTY.PROP_NUMBER,
x.xmldata.PROPERTY.NAME,
x.xmldata.PROPERTY.TYPENAME.PREFIX_CODE,
x.xmldata.PROPERTY.TYPENAME.NAME,
x.xmldata.PROPERTY.MEM_BYTE_LENGTH,
x.xmldata.PROPERTY.MEM_TYPE_CODE,
x.xmldata.PROPERTY.SYSTEM,
x.xmldata.PROPERTY.MUTABLE,
x.xmldata.PROPERTY.FORM.VALUE,
x.xmldata.PROPERTY.SQLNAME,
x.xmldata.PROPERTY.SQLTYPE,
x.xmldata.PROPERTY.SQLSCHEMA,
x.xmldata.PROPERTY.JAVA_TYPE.VALUE,
x.xmldata.PROPERTY.DEFAULT_VALUE,
reftohex(x.xmldata.PROPERTY.SMPL_TYPE_DECL),
reftohex(x.xmldata.PROPERTY.TYPE_REF),
x.xmldata.PROPERTY.PROPREF_NAME.PREFIX_CODE,
x.xmldata.PROPERTY.PROPREF_NAME.NAME,
reftohex(x.xmldata.PROPERTY.PROPREF_REF),
x.xmldata.PROPERTY.ATTR_USE.VALUE,
x.xmldata.PROPERTY.FIXED_VALUE,
x.xmldata.PROPERTY.GLOBAL,
x.xmldata.PROPERTY.ANNOTATION.SYS_XDBPD$,
x.xmldata.PROPERTY.ANNOTATION.APPINFO,
x.xmldata.PROPERTY.ANNOTATION.DOCUMENTATION,
x.xmldata.PROPERTY.SQLCOLLTYPE,
x.xmldata.PROPERTY.SQLCOLLSCHEMA,
x.xmldata.PROPERTY.HIDDEN,
x.xmldata.PROPERTY.TRANSIENT.VALUE,
x.xmldata.PROPERTY.ID,
x.xmldata.PROPERTY.BASEPROP,
-- end PROPERTY
x.xmldata.SUBS_GROUP.PREFIX_CODE,
x.xmldata.SUBS_GROUP.NAME,
x.xmldata.NUM_COLS,
x.xmldata.NILLABLE,
x.xmldata.FINAL_INFO.VALUE,
x.xmldata.BLOCK.VALUE,
x.xmldata.ABSTRACT,
x.xmldata.MEM_INLINE,
x.xmldata.SQL_INLINE,
x.xmldata.JAVA_INLINE,
x.xmldata.MAINTAIN_DOM,
x.xmldata.DEFAULT_TABLE,
x.xmldata.DEFAULT_TABLE_SCHEMA,
x.xmldata.TABLE_PROPS,
x.xmldata.JAVA_CLASSNAME ,
x.xmldata.BEAN_CLASSNAME ,
x.xmldata.BASE_SQLNAME,
reftohex(x.xmldata.CPLX_TYPE_DECL),
x.xmldata.SUBS_GROUP_REFS,
x.xmldata.DEFAULT_XSL,
x.xmldata.MIN_OCCURS,
x.xmldata.MAX_OCCURS,
x.xmldata.IS_FOLDER,
x.xmldata.MAINTAIN_ORDER,
x.xmldata.COL_PROPS,
x.xmldata.DEFAULT_ACL,
reftohex(x.xmldata.HEAD_ELEM_REF),
x.xmldata.UNIQUES,
x.xmldata.KEYS,
x.xmldata.KEYREFS,
x.xmldata.IS_TRANSLATABLE,
x.xmldata.XDB_MAX_OCCURS
from xdb.xdb$element x;

show errors;

grant select on XDB.XDB$ELEMENT_VIEW to select_catalog_role;

create table xdb.xdb$element_view_tbl as select * from xdb.xdb$element_view where 0=1;

/* (11) relational view on top of XDB.XDB$ANY */
create or replace view xdb.xdb$any_view
(
SYS_NC_OID$,
-- begin PROPERTY
P_SYS_XDBPD$,
P_PARENT_SCHEMA,
P_PROP_NUMBER,
P_NAME,
P_TYPENAME_PREFIX_CODE,
P_TYPENAME_NAME,
P_MEM_BYTE_LENGTH,
P_MEM_TYPE_CODE,
P_SYSTEM,
P_MUTABLE,
P_FORM,
P_SQLNAME,
P_SQLTYPE,
P_SQLSCHEMA,
P_JAVA_TYPE,
P_DEFAULT_VALUE,
P_SMPL_TYPE_DECL ,
P_TYPE_REF,
P_PROPREF_NAME_PREFIX_CODE,
P_PROPREF_NAME_NAME,
P_PROPREF_REF,
P_ATTR_USE,
P_FIXED_VALUE,
P_GLOBAL,
P_A_SYS_XDBPD$,
P_A_APPINFO,
P_A_DOCUMENTATION,
P_SQLCOLLTYPE,
P_SQLCOLLSCHEMA,
P_HIDDEN,
P_TRANSIENT,
P_ID,
P_BASEPROP,
-- end PROPERTY
namespace,
process_contents,
min_occurs,
max_occurs
)
as select
x.sys_nc_oid$,
-- begin PROPERTY
x.xmldata.property.SYS_XDBPD$,
reftohex(x.xmldata.property.PARENT_SCHEMA),
x.xmldata.property.PROP_NUMBER,
x.xmldata.property.NAME,
x.xmldata.property.TYPENAME.PREFIX_CODE,
x.xmldata.property.TYPENAME.NAME,
x.xmldata.property.MEM_BYTE_LENGTH,
x.xmldata.property.MEM_TYPE_CODE,
x.xmldata.property.SYSTEM,
x.xmldata.property.MUTABLE,
x.xmldata.property.FORM.VALUE,
x.xmldata.property.SQLNAME,
x.xmldata.property.SQLTYPE,
x.xmldata.property.SQLSCHEMA,
x.xmldata.property.JAVA_TYPE.VALUE,
x.xmldata.property.DEFAULT_VALUE,
reftohex(x.xmldata.property.SMPL_TYPE_DECL),
reftohex(x.xmldata.property.TYPE_REF),
x.xmldata.property.PROPREF_NAME.PREFIX_CODE,
x.xmldata.property.PROPREF_NAME.NAME,
reftohex(x.xmldata.property.PROPREF_REF),
x.xmldata.property.ATTR_USE.VALUE,
x.xmldata.property.FIXED_VALUE,
x.xmldata.property.GLOBAL,
x.xmldata.property.ANNOTATION.SYS_XDBPD$,
x.xmldata.property.ANNOTATION.APPINFO,
x.xmldata.property.ANNOTATION.DOCUMENTATION,
x.xmldata.property.SQLCOLLTYPE,
x.xmldata.property.SQLCOLLSCHEMA,
x.xmldata.property.HIDDEN,
x.xmldata.property.TRANSIENT.VALUE,
x.xmldata.property.ID,
x.xmldata.property.BASEPROP,
-- end PROPERTY
x.xmldata.namespace,
x.xmldata.process_contents.value,
x.xmldata.min_occurs,
x.xmldata.max_occurs
from xdb.xdb$any x;

show errors;

grant select on XDB.XDB$ANY_VIEW to select_catalog_role;

create table xdb.xdb$any_view_tbl as select * from xdb.xdb$any_view where 0=1;


/* (12) relational view on top of XDB.XDB$ANYATTR */
create or replace view xdb.xdb$anyattr_view
(
SYS_NC_OID$,
-- begin PROPERTY
P_SYS_XDBPD$,
P_PARENT_SCHEMA,
P_PROP_NUMBER,
P_NAME,
P_TYPENAME_PREFIX_CODE,
P_TYPENAME_NAME,
P_MEM_BYTE_LENGTH,
P_MEM_TYPE_CODE,
P_SYSTEM,
P_MUTABLE,
P_FORM,
P_SQLNAME,
P_SQLTYPE,
P_SQLSCHEMA,
P_JAVA_TYPE,
P_DEFAULT_VALUE,
P_SMPL_TYPE_DECL ,
P_TYPE_REF,
P_PROPREF_NAME_PREFIX_CODE,
P_PROPREF_NAME_NAME,
P_PROPREF_REF,
P_ATTR_USE,
P_FIXED_VALUE,
P_GLOBAL,
P_A_SYS_XDBPD$,
P_A_APPINFO,
P_A_DOCUMENTATION,
P_SQLCOLLTYPE,
P_SQLCOLLSCHEMA,
P_HIDDEN,
P_TRANSIENT,
P_ID,
P_BASEPROP,
-- end PROPERTY
namespace,
process_contents,
min_occurs,
max_occurs
)
as select
x.sys_nc_oid$,
-- begin PROPERTY
x.xmldata.property.SYS_XDBPD$,
reftohex(x.xmldata.property.PARENT_SCHEMA),
x.xmldata.property.PROP_NUMBER,
x.xmldata.property.NAME,
x.xmldata.property.TYPENAME.PREFIX_CODE,
x.xmldata.property.TYPENAME.NAME,
x.xmldata.property.MEM_BYTE_LENGTH,
x.xmldata.property.MEM_TYPE_CODE,
x.xmldata.property.SYSTEM,
x.xmldata.property.MUTABLE,
x.xmldata.property.FORM.VALUE,
x.xmldata.property.SQLNAME,
x.xmldata.property.SQLTYPE,
x.xmldata.property.SQLSCHEMA,
x.xmldata.property.JAVA_TYPE.VALUE,
x.xmldata.property.DEFAULT_VALUE,
reftohex(x.xmldata.property.SMPL_TYPE_DECL),
reftohex(x.xmldata.property.TYPE_REF),
x.xmldata.property.PROPREF_NAME.PREFIX_CODE,
x.xmldata.property.PROPREF_NAME.NAME,
reftohex(x.xmldata.property.PROPREF_REF),
x.xmldata.property.ATTR_USE.VALUE,
x.xmldata.property.FIXED_VALUE,
x.xmldata.property.GLOBAL,
x.xmldata.property.ANNOTATION.SYS_XDBPD$,
x.xmldata.property.ANNOTATION.APPINFO,
x.xmldata.property.ANNOTATION.DOCUMENTATION,
x.xmldata.property.SQLCOLLTYPE,
x.xmldata.property.SQLCOLLSCHEMA,
x.xmldata.property.HIDDEN,
x.xmldata.property.TRANSIENT.VALUE,
x.xmldata.property.ID,
x.xmldata.property.BASEPROP,
-- end PROPERTY
x.xmldata.namespace,
x.xmldata.process_contents.value,
x.xmldata.min_occurs,
x.xmldata.max_occurs
from xdb.xdb$anyattr x;

show errors;

grant select on XDB.XDB$ANYATTR_VIEW to select_catalog_role;

create table xdb.xdb$anyattr_view_tbl as select * from xdb.xdb$anyattr_view where 0=1;

/* (13) relational view on top of XDB.XDB$ATTRGROUP_DEF */
create or replace view xdb.xdb$attrgroup_def_view
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
NAME,
attributes,
any_attrs,
attr_groups,
A_SYS_XDBPD$,
A_APPINFO,
A_DOCUMENTATION,
ID
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
x.xmldata.NAME,
x.xmldata.ATTRIBUTES,
x.xmldata.ANY_ATTRS,
x.xmldata.ATTR_GROUPS,
x.xmldata.ANNOTATION.SYS_XDBPD$,
x.xmldata.ANNOTATION.APPINFO,
x.xmldata.ANNOTATION.DOCUMENTATION,
x.xmldata.ID
from xdb.xdb$attrgroup_def x;

show errors;

grant select on XDB.XDB$ATTRGROUP_DEF_VIEW to select_catalog_role;

create table xdb.xdb$attrgroup_def_view_tbl as select * from xdb.xdb$attrgroup_def_view where 0=1;


/* (14) relational view on top of XDB.XDB$ATTRGROUP_REF */
create or replace view xdb.xdb$attrgroup_ref_view
(
SYS_NC_OID$,
SYS_XDBPD$,
PARENT_SCHEMA,
ATTRGROUP_NAME_CODE,
ATTRGROUP_NAME_NAME,
ATTRGROUP_REF,
A_SYS_XDBPD$,
A_APPINFO,
A_DOCUMENTATION,
ID
)
as select
x.sys_nc_oid$,
x.xmldata.SYS_XDBPD$,
reftohex(x.xmldata.PARENT_SCHEMA),
x.xmldata.ATTRGROUP_NAME.PREFIX_CODE,
x.xmldata.ATTRGROUP_NAME.NAME,
reftohex(x.xmldata.ATTRGROUP_REF),
x.xmldata.ANNOTATION.SYS_XDBPD$,
x.xmldata.ANNOTATION.APPINFO,
x.xmldata.ANNOTATION.DOCUMENTATION,
x.xmldata.ID
from xdb.xdb$attrgroup_ref x;

show errors;

grant select on XDB.XDB$ATTRGROUP_REF_VIEW to select_catalog_role;

create table xdb.xdb$attrgroup_ref_view_tbl as select * from xdb.xdb$attrgroup_ref_view where 0=1;


/* (15) view for all dependencies XMLSCHEMAs have on types */
create or replace view DBA_TYPE_XMLSCHEMA_DEP(
	TYPE_NAME, 
	TYPE_OWNER, 
	SCHEMA_URL, 
	SCHEMA_OWNER, 
	SCHEMA_OID) 
as select distinct po.name, u.name, x.schema_url, x.owner, x.schema_id 
from dependency$ dep, dba_xml_schemas x, obj$ do, obj$ po, user$ u
where do.obj#=dep.d_obj# and po.obj#=dep.p_obj# and 
      do.type#=55 and do.name=x.int_objname and
      po.type#=13 and po.owner#=u.user#
/

show errors;

grant select on DBA_TYPE_XMLSCHEMA_DEP to select_catalog_role;
create or replace public synonym DBA_TYPE_XMLSCHEMA_DEP for DBA_TYPE_XMLSCHEMA_DEP;

/* table with same signature as the view above */
create table DBA_TYPE_XMLSCHEMA_DEP_TBL as select * from DBA_TYPE_XMLSCHEMA_DEP where 0=1;

/* (16) table with same signature as the view DBA_XML_SCHEMA_DEPENDENCY */
create table DBA_XML_SCHEMA_DEPENDENCY_TBL as select * from DBA_XML_SCHEMA_DEPENDENCY where 0=1;

/* (17) relational view on top of XDB.XDB$RESOURCE */
create or replace view XDB.XDB$RESOURCE_EXPORT_VIEW(
	SYS_NC_OID$,
	VERSIONID, 
	CREATIONDATE, 
	MODIFICATIONDATE, 
	AUTHOR, 
	DISPNAME, 
	RESCOMMENT, 
	LANGUAGE, 
	CHARSET, 
	CONTYPE, 
	REFCOUNT, 
	LOCKS, 
	ACLOID, 
	OWNERID, 
	CREATORID, 
	LASTMODIFIERID, 
	ELNUM, 
	SCHOID, 
	XMLREF, 
	XMLLOB, 
	FLAGS, 
	RESEXTRA, 
	ACTIVITYID, 
	VCRUID, 
	PARENTS, 
	SBRESEXTRA,
	SNAPSHOT, 
	ATTRCOPY, 
	CTSCOPY, 
	NODENUM, 
	SIZEONDISK, 
	RCLIST, 
	CHECKEDOUTBYID, 
	BASEVERSION) 
as select 
	x.sys_nc_oid$,
	x.xmldata.VERSIONID, 
	x.xmldata.CREATIONDATE, 
	x.xmldata.MODIFICATIONDATE, 
	x.xmldata.AUTHOR, 
	x.xmldata.DISPNAME, 
	x.xmldata.RESCOMMENT, 
	x.xmldata.LANGUAGE, 
	x.xmldata.CHARSET, 
	x.xmldata.CONTYPE, 
	x.xmldata.REFCOUNT, 
	x.xmldata.LOCKS,
	x.xmldata.ACLOID, 
	x.xmldata.OWNERID, 
	x.xmldata.CREATORID, 
	x.xmldata.LASTMODIFIERID, 
	x.xmldata.ELNUM, 
	x.xmldata.SCHOID, 
	REFTOHEX(x.xmldata.XMLREF), 
	x.xmldata.XMLLOB, 
	x.xmldata.FLAGS, 
	x.xmldata.RESEXTRA, 
	x.xmldata.ACTIVITYID, 
	x.xmldata.VCRUID, 
	x.xmldata.PARENTS, 
	x.xmldata.SBRESEXTRA,
	x.xmldata.SNAPSHOT, 
	x.xmldata.ATTRCOPY, 
	x.xmldata.CTSCOPY, 
	x.xmldata.NODENUM, 
	x.xmldata.SIZEONDISK, 
	x.xmldata.RCLIST.OID, 
	x.xmldata.CHECKEDOUTBYID,
	x.xmldata.BASEVERSION 
from XDB.XDB$RESOURCE x
/

show errors;

grant select on XDB.XDB$RESOURCE_EXPORT_VIEW to select_catalog_role;

/* table with same signature as the view above */
create table XDB.XDB$RESOURCE_EXPORT_VIEW_TBL (
    SYS_NC_OID$                                     RAW(16),
    VERSIONID					    NUMBER(38),
    CREATIONDATE		                    TIMESTAMP(6),
    MODIFICATIONDATE				    TIMESTAMP(6),
    AUTHOR 					    VARCHAR2(128),
    DISPNAME					    VARCHAR2(128),
    RESCOMMENT					    VARCHAR2(128),
    LANGUAGE					    VARCHAR2(128),
    CHARSET					    VARCHAR2(128),
    CONTYPE					    VARCHAR2(128),
    REFCOUNT					    RAW(4),
    LOCKS				            RAW(2000),
    ACLOID 					    RAW(16),
    OWNERID					    RAW(16),
    CREATORID					    RAW(16),
    LASTMODIFIERID 				    RAW(16),
    ELNUM				            NUMBER(38),
    SCHOID 					    RAW(16),
    XMLREF 					    VARCHAR2(2002),
    XMLLOB 					    BLOB,
    FLAGS				            RAW(4),
    RESEXTRA					    CLOB,
    ACTIVITYID					    NUMBER(38),
    VCRUID 					    RAW(16),
    PARENTS					    XDB.XDB$PREDECESSOR_LIST_T,
    SBRESEXTRA					    XDB.XDB$XMLTYPE_REF_LIST_T,
    SNAPSHOT					    RAW(6),
    ATTRCOPY					    BLOB,
    CTSCOPY					    BLOB,
    NODENUM					    RAW(6),
    SIZEONDISK					    NUMBER(38),
    RCLIST 					    XDB.XDB$OID_LIST_T,
    CHECKEDOUTBYID 				    RAW(16),
    BASEVERSION					    RAW(16));


/* (18) view listing all object tables owned by common users and their OIDs
 *   Needed at import time when REFs to such tables are imported,
 *   while tables they point to already exist on the target database,
 *   and so have OID potentially different from the ones on the 
 *   source/export database.
 *   Owned by SYS in the event common users other than XDB will 
 *   in the future store REFs to object/xmltype tables owned by
 *   common users. */
create or replace view SYS.XML_TABNAME2OID_VIEW as 
select distinct o.name, x.owner, o.oid$ 
 from obj$ o, dba_xml_tables x, dba_users u
 where x.table_name = o.name and x.owner=u.username and u.user_id=o.owner# and
       x.owner = 'XDB'
union
select distinct o.name, x.owner, o.oid$ 
 from obj$ o, dba_xml_tab_cols x, dba_users u
 where x.table_name = o.name and x.owner=u.username and u.user_id=o.owner# and
       x.owner = 'XDB'
/
show errors;

grant select on SYS.XML_TABNAME2OID_VIEW to select_catalog_role;
create or replace public synonym XML_TABNAME2OID_VIEW for XML_TABNAME2OID_VIEW;

/* table with same signature as the view above */
create table SYS.XML_TABNAME2OID_VIEW_TBL as select * from SYS.XML_TABNAME2OID_VIEW where 0=1;
grant select on SYS.XML_TABNAME2OID_VIEW_TBL to select_catalog_role;


prompt All views for exporting the XDB Repository have been created
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt

/* ------------------------------------------------------------------- */
/*                      SETUP impcalloutreg$ FOR EXPORT                */   
/* ------------------------------------------------------------------- */

prompt Registering export callouts for XDB Repository
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

/* callout registration for exporting XDB tables 
 * See dbmsdp.sql for flags.
 */
declare
  stmt varchar2(10000);
begin
  begin
    stmt := 'delete from sys.impcalloutreg$ where tgt_schema = ''' || 
            'XDB' || ''' ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
  begin
    stmt := 'delete from sys.exppkgact$ where package = ''' || 
            'DBMS_XDBUTIL_INT' || ''' and schema=''' || 'XDB' || ''' ';
    execute immediate stmt;
    exception
       when OTHERS then
         NULL;
  end;
end;
/

/* (0) register all XDB tables for export */
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', '%', 2, 
       3, 100, 3, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (1) register XDB.XDB$SCHEMA for export in TTS mode, and 
 *     view XDB$SCHEMA_EXPORT_VIEW otherwise */  
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$SCHEMA', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$SCHEMA_EXPORT_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');


/* (2) register XDB.XDB$SIMPLE_TYPE for export in TTS mode, and 
 *     view XDB$SIMPLE_TYPE_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$SIMPLE_TYPE', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$SIMPLE_TYPE_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');


/* (3) register XDB.XDB$COMPLEX_TYPE for export in TTS mode, and 
 *     view XDB$COMPLEX_TYPE_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$COMPLEX_TYPE', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$COMPLEX_TYPE_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');


/* (4) register XDB.XDB$ALL_MODEL for export in TTS mode, and 
 *     view XDB$ALL_MODEL_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ALL_MODEL', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ALL_MODEL_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (5) register XDB.XDB$CHOICE_MODEL for export in TTS mode, and 
 *     view XDB$CHOICE_MODEL_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$CHOICE_MODEL', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$CHOICE_MODEL_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (6) register XDB.XDB$SEQUENCE_MODEL for export in TTS mode, and 
 *     view XDB$SEQUENCE_MODEL_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$SEQUENCE_MODEL', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$SEQUENCE_MODEL_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (7) register XDB.XDB$GROUP_DEF for export in TTS mode, and 
 *     view XDB$GROUP_DEF_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$GROUP_DEF', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$GROUP_DEF_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (8) register XDB.XDB$GROUP_REF for export in TTS mode, and 
 *     view XDB$GROUP_REF_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$GROUP_REF', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$GROUP_REF_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');


/* (9) register XDB.XDB$ATTRIBUTE for export in TTS mode, and 
 *     view XDB$ATTRIBUTE_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ATTRIBUTE', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ATTRIBUTE_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (10) register XDB.XDB$ELEMENT for export in TTS mode, and 
 *     view XDB$ELEMENT_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ELEMENT', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ELEMENT_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (11) register XDB.XDB$ANY for export in TTS mode, and 
 *     view XDB$ANY_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ANY', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ANY_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (12) register XDB.XDB$ANYATTR for export in TTS mode, and 
 *     view XDB$ANYATTR_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ANYATTR', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ANYATTR_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (13) register XDB.XDB$ATTRGROUP_DEF for export in TTS mode, and 
 *     view XDB$ATTRGROUP_DEF_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ATTRGROUP_DEF', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ATTRGROUP_DEF_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (14) register XDB.XDB$ATTRGROUP_REF for export in TTS mode, and 
 *     view XDB$ATTRGROUP_REF_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ATTRGROUP_REF', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$ATTRGROUP_REF_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (15) register DBA_TYPE_XMLSCHEMA_DEP for export */
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
values ('DBMS_XDBUTIL_INT','XDB','XDB_REPOSITORY',3,10,2,
        'SYS','DBA_TYPE_XMLSCHEMA_DEP',4,
        'XDB Repository');

/* (16) register DBA_XML_SCHEMA_DEPENDENCY for export */
insert into sys.impcalloutreg$ (package, schema, tag, class, level#, flags,
                                tgt_schema, tgt_object, tgt_type, cmnt)
values ('DBMS_XDBUTIL_INT','XDB','XDB_REPOSITORY',3,10,2,
        'SYS','DBA_XML_SCHEMA_DEPENDENCY',4, 'XDB Repository');

/* (17) register XDB.XDB$RESOURCE for export in TTS mode, and 
 *     view XDB$RESOURCE_EXPORT_VIEW otherwise */ 
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$RESOURCE', 2, 
       3, 100, 16+8, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('XDB', 'XDB$RESOURCE_EXPORT_VIEW', 4, 
        3, 100, 16+2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* (18) register XML_TABNAME2OID_VIEW for export */
insert into sys.impcalloutreg$(tgt_schema, tgt_object, tgt_type, 
                               class, level#, flags, schema, package, 
                               tag, cmnt) 
values('SYS', 'XML_TABNAME2OID_VIEW', 4, 
        3, 1, 2, 'XDB', 'DBMS_XDBUTIL_INT', 
       'XDB_REPOSITORY', 'XDB Repository');

/* system-level procedural action for XDB sequences */
insert into sys.exppkgact$(package, schema, class, level#) 
values('DBMS_XDBUTIL_INT', 'XDB', 1, 1000);

prompt Registering export callouts for XDB Repository has completed
prompt ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
prompt
