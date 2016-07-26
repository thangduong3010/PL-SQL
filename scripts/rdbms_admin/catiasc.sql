Rem
Rem $Header: rdbms/admin/catiasc.sql /main/7 2008/12/25 17:24:23 yurxu Exp $
Rem
Rem catiasc.sql
Rem
Rem Copyright (c) 1900, 2008, Oracle and/or its affiliates.
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catiasc.sql  IAS views and catalog
Rem
Rem    DESCRIPTION
Rem      views required to support IAS
Rem
Rem    NOTES
Rem      requires catrepc.sql to have already been executed
Rem      execute as sys
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jingliu     12/10/04 - lrg_1803304
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    htseng      04/12/01 - eliminate execute twice (remove ;).
Rem    celsbern    03/20/01 - moved export views to this file from dbmsiast.
Rem    jingliu     12/11/00 - add index repcat$_template_objects_n2
Rem    celsbern    11/16/00 - fixed views to use new IAS tables
Rem    jingliu     07/27/00 - add view dba_ias_objects_exp
Rem    jingliu     05/15/00 - add internal view dba_ias_objects_base
Rem    masubram    04/20/00 - add temporary tables
Rem    masubram    04/18/00 - remove user synonym object types
Rem    masubram    04/12/00 - add sequence and remove trigger types
Rem    celsbern    04/07/00 - added alter of template tables/objects at start.
Rem    masubram    04/05/00 - add new types for IAS template objects
Rem    masubram    03/29/00 - add new ias object types
Rem    celsbern    03/29/00 - even more site changes
Rem    celsbern    03/29/00 - fixed dba_ias_templates synonym
Rem    celsbern    03/28/00 - created.
Rem
 
create index system.repcat$_template_objects_n2 on
system.repcat$_template_objects (refresh_template_id,
  object_name,schema_name,object_type );


-- IAS templates view
create or replace view dba_ias_templates as
select owner, refresh_group_name,
  refresh_template_name ias_template_name,
  refresh_template_id   ias_template_id,
  template_comment
from system.repcat$_refresh_templates rt,
  system.repcat$_template_types tt
where rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),2) = 2
/

create or replace public synonym dba_ias_templates for dba_ias_templates
/
grant select on dba_ias_templates to select_catalog_role
/

-- IAS internal object view
create or replace view dba_ias_objects_base as 
select rt.refresh_template_name ias_template_name,
  ro.schema_name,
  ro.object_name,
  ro.object_type object_type_id,
  ot.object_type_name object_type,
  ro.derived_from_sname,
  ro.derived_from_oname
from system.repcat$_refresh_templates rt,
  system.repcat$_template_objects ro,
  system.repcat$_object_types ot,
  system.repcat$_template_types tt
where rt.refresh_template_id = ro.refresh_template_id
and ro.object_type = ot.object_type_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),2) = 2
/

grant select on dba_ias_objects_base to select_catalog_role
/
-- IAS internal object view for export
create or replace view dba_ias_objects_exp as
select ro.refresh_template_id template_id,
       ro.object_name,
       ro.schema_name,
       ot.object_type_name object_type
from system.repcat$_template_objects ro,
  system.repcat$_refresh_templates rt,
  system.repcat$_template_types tt,
  system.repcat$_object_types ot
where ro.refresh_template_id = rt.refresh_template_id
and ro.object_type = ot.object_type_id
and rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),2) = 2
/
grant select on dba_ias_objects_exp to select_catalog_role
/

--IAS objects view
create or replace view dba_ias_objects as 
select ro.ias_template_name,
  ro.schema_name,
  ro.object_name,
  ro.object_type,
  ro.derived_from_sname,
  ro.derived_from_oname
from sys.dba_ias_objects_base ro 
/
create or replace public synonym dba_ias_objects for  dba_ias_objects
/
grant select on dba_ias_objects to select_catalog_role
/

create or replace view dba_ias_sites 
(ias_template_name,user_name,site_name) as
select refresh_template_name, user_name, site_name
from system.repcat$_template_sites
where status = -100 /*secret code for IAS template sites? */
/
create or replace public synonym dba_ias_sites for  dba_ias_sites
/
grant select on dba_ias_sites to select_catalog_role
/

create or replace view dba_ias_constraint_exp as
select 1 pkexists, cd.obj# from sys.cdef$ cd
where cd.type# = 2
/
grant select on dba_ias_constraint_exp to select_catalog_role
/


--IAS generated statements view
create or replace view dba_ias_gen_stmts as 
select rt.refresh_template_name ias_template_name,
  decode(ro.object_type, -1017, to_number(ro.object_name), 0) lineno, ddl_text
from system.repcat$_refresh_templates rt,
  system.repcat$_template_objects ro,
  system.repcat$_template_types tt
where rt.template_type_id = tt.template_type_id
and bitand(rawtohex(tt.flags),2) = 2
and rt.refresh_template_id = ro.refresh_template_id
and ro.object_type = -1017   -- object_type = dbms_ias_template.generated_ddl
/
create or replace public synonym dba_ias_gen_stmts for  dba_ias_gen_stmts
/
grant select on dba_ias_gen_stmts to select_catalog_role
/
-- IAS generated statements view for export
create or replace view dba_ias_gen_stmts_exp as
select ro.refresh_template_id ias_template_id,
  decode(ro.object_type, -1017, to_number(ro.object_name), 0) lineno, ddl_text
from system.repcat$_template_objects ro
where ro.object_type = -1017   
/
grant select on dba_ias_gen_stmts_exp to select_catalog_role
/

-- IAS pre-generated statements view.
-- pre-gen stmts are exported after table export

create or replace view dba_ias_pregen_stmts as
select * from sys.dba_ias_gen_stmts_exp gs
  where gs.lineno < (select lineno from sys.dba_ias_gen_stmts_exp f
                       where dbms_lob.substr(f.ddl_text,1,1)='0'
                         and dbms_lob.getlength(f.ddl_text) = 1
                         and f.ias_template_id = gs.ias_template_id)
/
grant select on dba_ias_pregen_stmts to select_catalog_role
/

-- IAS post generated statment.
-- post-gen stmts are exported at the end of database objects export.

create or replace view dba_ias_postgen_stmts as
select * from sys.dba_ias_gen_stmts_exp gs
  where gs.lineno > (select lineno from sys.dba_ias_gen_stmts_exp f
                       where dbms_lob.substr(f.ddl_text,1,1)='0'
                         and dbms_lob.getlength(f.ddl_text) = 1
                         and f.ias_template_id = gs.ias_template_id)
/
grant select on dba_ias_postgen_stmts to select_catalog_role
/













