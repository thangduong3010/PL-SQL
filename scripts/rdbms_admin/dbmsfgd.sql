Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsfgd.sql - Fine-grain dependency information
Rem
Rem    DESCRIPTION
Rem      This script provides views PUBLIC_SYN_BASE and
Rem      PUBLIC_FINE_GRAIN_DEPENDENCY described below.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sagrawal    12/18/09 - add more debugging packages
Rem    gviswana    10/02/06 - Created
Rem

--
-- NAME:
--   DBMS_FINE_GRAIN_DEP
--
-- DESCRIPTION:
--   This package provides a table function FG_ELEMENTS that translates the
--   fine-grain dependency information stored in dependency$ into a user
--   readable format.
--
create or replace package dbms_fine_grain_dep authid current_user as
   type fg_rec is record(element_num number, element_desc varchar2(30));
   type fg_tab is table of fg_rec;
   function fg_elements(bitvec raw) return fg_tab pipelined;
end;
/
show errors;

--
-- NAME:
--   PUBLIC_SYN_TARGET
--
-- DESCRIPTION:
--   This view maps each synonym to its target object. It works by picking
--   the "last" synonym dependency parent (i.e., the one with the largest
--   order number.
--
create or replace view PUBLIC_SYN_TARGET as
   with ranked_syn_target as
   (select s.obj# syn_id, d.p_obj# target_id, d.order# rank,
           MAX(d.order#) KEEP (DENSE_RANK FIRST ORDER BY d.order# desc)
           OVER (PARTITION BY s.obj#) max_rank
      from sys.syn$ s, sys.dependency$ d
     where s.obj# = d.d_obj# and s.node is null)
   select syn_id, target_id from ranked_syn_target where rank = max_rank;

--
-- NAME:
--   PUBLIC_SYN_BASE
--
-- DESCRIPTION:
--   This view maps each synonym to its base object. The result is different
--   from PUBLIC_SYN_TARGET only when there are synonym chains.
--
--   Intermediate view RANKED_SYN_BASE builds expanded synonym chains using
--   CONNECT BY and RANKED_SYN_MAX ranks synonym targets according to level
--   in the CONNECT BY hierarchy.
--
create or replace view PUBLIC_SYN_BASE as
   with ranked_syn_base as
    (select connect_by_root syn_id syn_id, connect_by_root target_id target_id,
       target_id base_id, connect_by_iscycle is_cycle, level l
      from public_syn_target
      connect by nocycle prior target_id = syn_id),
   ranked_syn_max as
     (select syn_id, target_id, base_id, l, 
             MAX(l) KEEP (DENSE_RANK FIRST order by l desc)
             OVER(PARTITION BY syn_id) max_l
        from ranked_syn_base)
   select syn_id, target_id, base_id from ranked_syn_max where l = max_l;

--
-- NAME:
--   PUBLIC_FINE_GRAIN_DEPENDENCY
--
-- DESCRIPTION:
--   This view uses package DBMS_FINE_GRAIN_DEP to translate fine-grain
--   dependency information in dependency$ for user consumption.
--
create or replace view PUBLIC_FINE_GRAIN_DEPENDENCY
   (object_id, referenced_object_id, element_num, element_desc) as
   select d_obj#, d.p_obj#, e.element_num, e.element_desc
     from sys.dependency$ d, TABLE(dbms_fine_grain_dep.fg_elements(d.d_attrs)) e;



create or replace view DBA_fine_grain_DEPENDENCIES
  (OWNER, NAME, TYPE, REFERENCED_OWNER, REFERENCED_NAME,
  REFERENCED_TYPE, REFERENCED_LINK_NAME, DEPENDENCY_type,
  ELEMENT_NUM ,ELEMENT_DESC )
as
select u.name, o.name,
       decode(o.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      42, 'MATERIALIZED VIEW', 43, 'DIMENSION',
                      46, 'RULE SET', 55, 'XML SCHEMA', 56, 'JAVA DATA',
                      59, 'RULE', 62, 'EVALUATION CONTXT', 87, 'ASSEMBLY',
                      92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      'UNDEFINED'),
       decode(po.linkname, null, pu.name, po.remoteowner), po.name,
       decode(po.type#, 0, 'NEXT OBJECT', 1, 'INDEX', 2, 'TABLE', 3, 'CLUSTER',
                      4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE', 7, 'PROCEDURE',
                      8, 'FUNCTION', 9, 'PACKAGE', 10, 'NON-EXISTENT',
                      11, 'PACKAGE BODY', 12, 'TRIGGER',
                      13, 'TYPE', 14, 'TYPE BODY', 22, 'LIBRARY',
                      28, 'JAVA SOURCE', 29, 'JAVA CLASS', 
                      32, 'INDEXTYPE', 33, 'OPERATOR',
                      42, 'MATERIALIZED VIEW', 43, 'DIMENSION',
                      46, 'RULE SET', 55, 'XML SCHEMA', 56, 'JAVA DATA',
                      59, 'RULE', 62, 'EVALUATION CONTXT', 87, 'ASSEMBLY',
                      92, 'CUBE DIMENSION', 93, 'CUBE',
                      94, 'MEASURE FOLDER', 95, 'CUBE BUILD PROCESS',
                      'UNDEFINED'),
       po.linkname,
  decode(bitand(d.property, 3), 2, 'REF', 'HARD'), 
  e.element_num, e.element_desc
from sys."_CURRENT_EDITION_OBJ" o, sys.disk_and_fixed_objects po,
  sys.dependency$ d, sys.user$ u, sys.user$ pu, 
  TABLE(dbms_fine_grain_dep.fg_elements(d.d_attrs)) e
where o.obj# = d.d_obj#
  and o.owner# = u.user#
  and po.obj# = d.p_obj#
  and po.owner# = pu.user#
/
create or replace public synonym DBA_fine_grain_DEPENDENCIES FOR
  DBA_fine_grain_DEPENDENCIES
/
grant select on DBA_fine_grain_DEPENDENCIES to select_catalog_role
/

@@prvtfgd.plb
