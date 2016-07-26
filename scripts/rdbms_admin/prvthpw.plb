CREATE OR REPLACE PACKAGE kupw$worker wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
361 1f2
+D/U7mFY+RDcXSJ+pDHCcwEgiw4wgxAJAMcVfHTNbg/uN/viS/UBCX5sUvQk3GHudXoy4BHQ
mByqnZ9awBQ3J1JWAPq77YXhJGfwipv4x7pVvGScZNXWj/0+BCiiTRB0y/Q31QlLH8yKn7uV
C12YbGrMNuboZydhHJiUV9COKhaKuSa0lfPjeGcsBa0lbvVRpZYJcIj8FjIBtJHJPipQrZR6
PFoTEHLNbFyokERyEzBl9eMljMD46dlR2ULmacz0Wk3dYMYT9TPxXn/qMPaXs0s3h9wZ6fXw
b0lTRmWvguiyeDPkprkQCGlhV87OaBO9wv5SSmh6XnW2XFBoDIyTAjHxDrodZsXS8PPtV/ZR
yydFst4/l436uYdYKCEai64uENizxq5e1O/xDLvi+APH7mwF9b6W7lrqRRaNKl2MSVDRqgFz
lYWVYUhU9AIzMU8uX0VV4B5S2eVvJ7H6cUgfJ6/Lr0ErQqol0sQkB+a+nQ==

/
grant execute on SYS.KUPW$WORKER to public;
CREATE OR REPLACE VIEW sys.ku$_table_est_view (
                cols, rowcnt, avgrln, object_schema, object_name) AS
        SELECT  t.cols, t.rowcnt, t.avgrln, u.name, o.name
        FROM    SYS.OBJ$ O, SYS.TAB$ T, SYS.USER$ U
        WHERE   t.obj# = o.obj# AND
                o.owner# = u.user# AND
                (UID IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.ku$_table_est_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_partition_est_view (
                cols, rowcnt, avgrln, object_schema, object_name,
                partition_name) AS
        SELECT  t.cols, tp.rowcnt, tp.avgrln, u.name, ot.name, op.subname
        FROM    SYS.OBJ$ OT, SYS.OBJ$ OP, SYS.TAB$ T, SYS.TABPART$ TP,
                SYS.USER$ U
        WHERE   tp.obj# = op.obj# AND
                tp.bo# = ot.obj# AND
                ot.type#=2 AND
                t.obj# = tp.bo# AND
                ot.owner# = u.user# AND
                (UID IN (0, ot.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'));
GRANT SELECT ON sys.ku$_partition_est_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_subpartition_est_view (
                cols, rowcnt, avgrln, object_schema, object_name,
                subpartition_name) AS
        SELECT  t.cols, tp.rowcnt, tp.avgrln, u.name, ot.name, op.subname
        FROM    SYS.OBJ$ OT, SYS.OBJ$ OP, SYS.TAB$ T, sys.tabcompart$ tcp, 
                SYS.TABSUBPART$ TP, SYS.USER$ U
        WHERE   tp.obj# = op.obj# AND
                tcp.bo# = ot.obj# AND
                ot.type#=2 AND
                t.obj# = tcp.bo# AND
                tp.pobj# = tcp.obj# and
                ot.owner# = u.user# AND
                (UID IN (0, ot.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.ku$_subpartition_est_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_object_status_view (
                status, owner, name, type) AS
        SELECT  o.status, u.name, o.name,
                decode(o.type#, 4, 'VIEW', 13, 'TYPE')
        FROM    sys.obj$ o, sys.user$ u
        WHERE   o.owner# = u.user# AND
                o.type# IN (4, 13) AND
                (UID IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.ku$_object_status_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_table_exists_view (
                object_schema, object_long_name) AS
        SELECT  u.name, o.name
        FROM    sys.obj$ o, sys.user$ u
        WHERE   o.owner# = u.user# AND
                o.type# = 2 AND
                (UID IN (0, o.owner#) OR
                 EXISTS (
                    SELECT  role
                    FROM    sys.session_roles
                    WHERE   role = 'SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.ku$_table_exists_view TO PUBLIC
/
CREATE OR REPLACE VIEW sys.ku$_refpar_level (
                refpar_level, owner, name) AS
        SELECT  sys.dbms_metadata_util.ref_par_level(t.obj#), u.name, o.name
        FROM    sys.obj$ o, sys.tab$ t, sys.user$ u
        where   u.user# = o.owner# AND o.obj# = t.obj# AND
                bitand(t.property, 32+64+128+256+512) = 32 AND
                EXISTS(SELECT * from sys.partobj$ po
                       WHERE  po.obj# = t.obj# AND po.parttype = 5) AND
                (SYS_CONTEXT('USERENV','CURRENT_USERID') IN (o.owner#,0) OR
                 EXISTS (SELECT * FROM sys.session_roles
                         WHERE role='SELECT_CATALOG_ROLE'))
/
GRANT SELECT ON sys.ku$_refpar_level TO PUBLIC
/
CREATE OR REPLACE VIEW ku$_all_tsltz_tab_cols(owner, table_name, column_name,
        qualified_col_name, nested, virtual_column) as
  with rw (p_obj#, d_obj#, property)  as
  (
        select p_obj#, d_obj#, property
        from   sys.dependency$
        where  p_obj# in
               (select distinct o.obj#
                from   sys.obj$ o, sys.attribute$ a
                where  o.oid$ = a.toid and
                       a.attr_toid = '00000000000000000000000000000041'
    union all
        select distinct o.obj#
        from   sys.obj$ o, sys.collection$ c
        where  o.oid$ = c.toid and
               c.elem_toid = '00000000000000000000000000000041')
    union all
        select d.p_obj#, d.d_obj#, d.property
        from   rw, sys.dependency$ d
        where  rw.d_obj# = d.p_obj# and bitand(rw.property, 1) = 1),
  va_of_tsltz_typ (name) as(
        select distinct o.name
        from   rw, sys.obj$ o, sys.coltype$ c
        where  rw.p_obj# = o.obj# and o.oid$ = c.toid and
               bitand(c.flags, 8) = 8),
  all_tsltz_candiate_tab_cols(owner, table_name, table_property, table_nested,
        column_name, data_type, qualified_col_name, virtual_column) as
       (select u.name, o.name, t.property,
               case when bitand(t.property, 8192) = 8192 then 1 else 0 end,
               c.name,
               case when c.type# = 231 then
                       'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE'
                    when c.type# in (58, 111, 121, 122, 123) then
                        nvl2(ac.synobj#, (select o.name from obj$ o
                                          where o.obj#=ac.synobj#), ot.name)
                    else 'UNDEFINED'
               end,
               decode(bitand(c.property, 1024), 1024,
                 (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
                  from   sys.col$ cl, attrcol$ rc
                  where  cl.intcol# = c.intcol#-1 and cl.obj# = c.obj# and
                         c.obj# = rc.obj#(+) and cl.intcol# = rc.intcol#(+)),
               decode(bitand(c.property, 1), 0, c.name,
                 (select tc.name
                  from   sys.attrcol$ tc
                  where  c.obj# = tc.obj# and c.intcol# = tc.intcol#))),
               decode(c.property, 0, 0, decode(bitand(c.property, 8), 8, 1, 0))
        from   sys.col$ c, sys."_CURRENT_EDITION_OBJ" o, sys.user$ u,
               sys.coltype$ ac, sys.obj$ ot, sys.tab$ t
        where  o.obj# = c.obj# and o.owner# = u.user# and
               c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+) and
               ac.toid = ot.oid$(+) and ot.type#(+) = 13 and
               o.obj# = t.obj# and c.type# in (58, 111, 121, 122, 123, 231))
  select owner, table_name, column_name, qualified_col_name, table_nested,
         virtual_column
  from  all_tsltz_candiate_tab_cols
  where data_type like 'TIMESTAMP%WITH LOCAL TIME ZONE' or
        data_type in (select name from va_of_tsltz_typ)
/
GRANT SELECT ON sys.ku$_all_tsltz_tab_cols TO SELECT_CATALOG_ROLE;
CREATE OR REPLACE VIEW ku$_all_tsltz_tables(owner, table_name) as
        SELECT UNIQUE owner, table_name
        FROM   sys.ku$_all_tsltz_tab_cols
/
GRANT SELECT ON sys.ku$_all_tsltz_tables TO SELECT_CATALOG_ROLE;
/
