DROP TABLE utl_recomp_sorted;
DROP TABLE utl_recomp_compiled;
DROP TABLE utl_recomp_errors;
CREATE TABLE utl_recomp_sorted
(
  obj#         number not null,
  owner        varchar2(30),
  objname      varchar2(30),
  edition_name varchar2(30),
  namespace    number,
  depth        number,
  batch#       number
);
CREATE TABLE utl_recomp_compiled
(
  obj#        number not null,
  batch#      number,
  compiled_at timestamp,
  compiled_by varchar2(64)
);
CREATE TABLE utl_recomp_errors
(
  obj#        number,
  error_at    timestamp,
  compile_err varchar2(4000)
);
CREATE OR REPLACE VIEW utl_recomp_all_objects AS
   SELECT o.obj#, u.name owner, o.name objname, o.type#, o.namespace, o.status,
          o.defining_edition edition_name
   FROM "_ACTUAL_EDITION_OBJ" o, user$ u
   WHERE     o.owner# = u.user#
         AND o.remoteowner IS NULL
         AND (   o.type# IN (1, 2, 4, 5, 7, 8, 9, 11, 12, 14,
                             22, 24, 29, 32, 33, 42, 43, 46, 59, 62)
              OR (o.type# = 13 AND o.subname IS NULL AND
                  NOT REGEXP_LIKE(o.name, 'SYS_PLSQL_[0-9]+_[0-9]+_[12]')))
         AND (BITAND(o.flags, 128) = 0)
   UNION ALL
   SELECT s.obj#, a.ext_username owner, s.name objname, s.type#, s.namespace,
          s.status, e.name edition_name
   FROM  obj$ s, user$ a, obj$ e
   WHERE     s.remoteowner IS NULL
         AND s.type# = 88
         AND s.status = 5
         AND s.owner# = a.user#
         AND a.spare2 = e.obj#;
CREATE OR REPLACE VIEW utl_recomp_invalid_all AS
    SELECT * FROM utl_recomp_all_objects
     WHERE status IN (4, 5, 6)
       AND obj# NOT IN (SELECT obj# FROM utl_recomp_compiled);
CREATE OR REPLACE VIEW utl_recomp_invalid_seq AS
   SELECT * FROM utl_recomp_invalid_all WHERE type# = 29;
CREATE OR REPLACE VIEW utl_recomp_invalid_mv AS
  WITH invalid_mvs_and_deps_base(obj_num, order_num) AS
       (SELECT obj#, 0 
          FROM utl_recomp_all_objects 
         WHERE type# = 42
           AND status IN (4, 5, 6)
        UNION ALL
        SELECT d.d_obj#, i.order_num + 1
          from dependency$ d, invalid_mvs_and_deps_base i
         where i.obj_num = d.p_obj#),
       invalid_mvs_and_dependents(obj_num, order_num) AS
       (SELECT obj_num, MAX(order_num)
          FROM invalid_mvs_and_deps_base
        GROUP BY obj_num 
        ORDER BY MAX(order_num))
SELECT obj#, owner, objname, type#, namespace, status, edition_name 
  FROM invalid_mvs_and_dependents, utl_recomp_all_objects urao
 WHERE obj_num = urao.obj#
   AND urao.type# = 42
   AND urao.obj# NOT IN (SELECT obj# FROM utl_recomp_compiled)
ORDER BY order_num;
CREATE OR REPLACE VIEW utl_recomp_invalid_parallel AS
   SELECT * FROM utl_recomp_invalid_all WHERE type# NOT IN (29, 42);
CREATE OR REPLACE VIEW utl_recomp_invalid_java_syn AS
   SELECT * FROM utl_recomp_all_objects
   WHERE type# = 5 AND status in (4, 5, 6) AND
         obj# IN (SELECT d.d_obj# FROM obj$ o, dependency$ d
                  WHERE o.obj# = d.p_obj# and o.type# = 29);
