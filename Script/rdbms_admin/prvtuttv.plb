create or replace view dba_analyze_objects (owner, object_name, object_type) as
       select u.name, o.name, decode(o.type#, 2, 'TABLE', 3, 'CLUSTER')
       from sys.user$ u, sys.obj$ o, sys.tab$ t
       where o.owner# = u.user#
       and   o.obj# = t.obj# (+)
       and   t.bobj# is null
       and   o.type# in (2,3)
       and   bitand(o.flags, 128) = 0 
       and   o.linkname is null
/
