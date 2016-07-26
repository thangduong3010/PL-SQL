Rem
Rem $Header: cdmanage.sql 20-oct-2006.22:40:43 schakkap Exp $
Rem
Rem cdmanage.sql
Rem
Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      cdmanage.sql - Catalog DMANAGE.bsq views
Rem
Rem    DESCRIPTION
Rem      SQL tuning, SQL text, SQL profile, etc
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in dmanage.bsq.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    schakkap    10/20/06 - move v$object_usage from cdcore.sql
Rem    cdilling    05/04/06 - Created
Rem

Rem
Rem Object usage information. Currently shows only index usage information.
Rem
create or replace view V$OBJECT_USAGE
    (INDEX_NAME,
     TABLE_NAME,
     MONITORING,
     USED,
     START_MONITORING,
     END_MONITORING)
as
select io.name, t.name,
       decode(bitand(i.flags, 65536), 0, 'NO', 'YES'),
       decode(bitand(ou.flags, 1), 0, 'NO', 'YES'),
       ou.start_monitoring,
       ou.end_monitoring
from sys.obj$ io, sys.obj$ t, sys.ind$ i, sys.object_usage ou
where io.owner# = userenv('SCHEMAID')
  and i.obj# = ou.obj#
  and io.obj# = ou.obj#
  and t.obj# = i.bo#
/
create or replace public synonym V$OBJECT_USAGE for V$OBJECT_USAGE
/
grant select on V$OBJECT_USAGE to public
/
comment on table V$OBJECT_USAGE is
'Record of index usage'
/
comment on column V$OBJECT_USAGE.INDEX_NAME is
'Name of the index'
/
comment on column V$OBJECT_USAGE.TABLE_NAME is
'Name of the table upon which the index was build'
/
comment on column V$OBJECT_USAGE.MONITORING is
'Whether the monitoring feature is on'
/
comment on column V$OBJECT_USAGE.USED is
'Whether the index has been accessed'
/
comment on column V$OBJECT_USAGE.START_MONITORING is
'When the monitoring feature is turned on'
/
comment on column V$OBJECT_USAGE.END_MONITORING is
'When the monitoring feature is turned off'
/
