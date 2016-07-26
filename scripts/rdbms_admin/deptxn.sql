Rem
Rem $Header: rdbms/admin/deptxn.sql /st_rdbms_11.2.0/2 2011/06/16 09:13:53 andmuell Exp $
Rem
Rem deptxn.sql
Rem
Rem Copyright (c) 2007, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      deptxn.sql - For dependent objects in transaction layer
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    andmuell    06/14/11 - Backport andmuell_bug-12543110 from main
Rem    liaguo      07/19/10 - XbranchMerge liaguo_bug-9850223 from main
Rem    liaguo      06/24/10 - bug 9850223
Rem    liaguo      01/15/10 - bug 9221735
Rem    vakrishn    05/20/09 - bug 6119867 : add status to indicate disabling of
Rem                           flashback archive
Rem    vakrishn    12/05/08 - bug 5996066 - add owner to dba_flashback_archive
Rem                           and user_flashback_archive views
Rem    vakrishn    06/24/07 - bug 6120630 - SYS_FBA_USERS can be empty when only 
Rem                           the dba has created the FA. 
Rem                           Allow user_flashback_archive_tables to show for a 
Rem                           user with a dba role who has enabled a table for FDA.
Rem    vakrishn    02/16/07 - Flashback Archive Views
Rem    vakrishn    02/16/07 - Created
Rem

remark
remark  FAMILY "FLASHBACK_ARCHIVE"
remark
remark  These views describe the Archives, tablespaces used in the Archives
remark  for Flashback Archive and tables that are enabled for Flashback Archive.
remark  There is also a  view that provides all the user tables that
remark  are enabled for Flashback Archive in that users schema.
remark

/* Show all flashback archives in the system to DBA or Flashback Archive Admin */
create or replace view DBA_FLASHBACK_ARCHIVE
    (OWNER_NAME, FLASHBACK_ARCHIVE_NAME, FLASHBACK_ARCHIVE#, RETENTION_IN_DAYS, 
     CREATE_TIME, LAST_PURGE_TIME, STATUS)
as select f.OWNERNAME, f.FANAME, f.FA#, f.RETENTION, 
          case when f.CREATESCN < f.PURGESCN then NULL 
               else scn_to_timestamp(f.CREATESCN) 
               end,
          scn_to_timestamp(f.PURGESCN),
          decode(bitand(f.flags, 1), 1, 'DEFAULT', NULL)
from SYS_FBA_FA f
/
create or replace public synonym DBA_FLASHBACK_ARCHIVE for DBA_FLASHBACK_ARCHIVE
/
grant select on DBA_FLASHBACK_ARCHIVE to PUBLIC with grant option 
/
comment on table DBA_FLASHBACK_ARCHIVE is
'Description of the flashback archives available in the system'
/
comment on column DBA_FLASHBACK_ARCHIVE.OWNER_NAME is
'Name of the creator of the flashback archive'
/
comment on column DBA_FLASHBACK_ARCHIVE.FLASHBACK_ARCHIVE_NAME is
'Name of the flashback archive'
/
comment on column DBA_FLASHBACK_ARCHIVE.FLASHBACK_ARCHIVE# is
'Number of the flashback archive'
/
comment on column DBA_FLASHBACK_ARCHIVE.RETENTION_IN_DAYS is
'Maximum duration in days for which data is retained in the flashback archive'
/
comment on column DBA_FLASHBACK_ARCHIVE.CREATE_TIME is
'Time at which the flashback archive was created'
/
comment on column DBA_FLASHBACK_ARCHIVE.LAST_PURGE_TIME is
'Time at which the data in the flashback archive was last purged by the system'
/
comment on column DBA_FLASHBACK_ARCHIVE.STATUS is
'Indicates whether the flashback archive is a default flashback archive for the system'
/

/* 
 * Show flashback archives in the system for which the user has
 * Flashback Archive object privileges
 */
create or replace view USER_FLASHBACK_ARCHIVE
    (OWNER_NAME, FLASHBACK_ARCHIVE_NAME, FLASHBACK_ARCHIVE#, RETENTION_IN_DAYS, 
     CREATE_TIME, LAST_PURGE_TIME, STATUS)
as select unique f.OWNERNAME, f.FANAME, f.FA#, f.RETENTION, 
          case when f.CREATESCN < f.PURGESCN then NULL 
               else scn_to_timestamp(f.CREATESCN) 
               end,
          scn_to_timestamp(f.PURGESCN),
          decode(bitand(f.flags, 1), 1, 'DEFAULT', NULL)
from SYS_FBA_FA f, SYS_FBA_USERS fp, USER$ u  
where 
  /* user has flashback archive object privilege */
  (f.FA# = fp.FA# and fp.user# = u.USER#) and
  /* show only this user's objects */
  ((u.user# = userenv('SCHEMAID'))
  or
  /* user has system privileges - show all users */
  exists (select null from v$enabledprivs where priv_number = -350))
/
create or replace public synonym USER_FLASHBACK_ARCHIVE for USER_FLASHBACK_ARCHIVE
/
grant select on USER_FLASHBACK_ARCHIVE to PUBLIC with grant option 
/
comment on table USER_FLASHBACK_ARCHIVE is
'Description of the flashback archives available to the user'
/
comment on column USER_FLASHBACK_ARCHIVE.OWNER_NAME is
'Name of the creator of the flashback archive'
/
comment on column USER_FLASHBACK_ARCHIVE.FLASHBACK_ARCHIVE_NAME is
'Name of the flashback archive'
/
comment on column USER_FLASHBACK_ARCHIVE.FLASHBACK_ARCHIVE# is
'Number of the flashback archive'
/
comment on column USER_FLASHBACK_ARCHIVE.RETENTION_IN_DAYS is
'Maximum duration in days for which data is retained in the flashback archive'
/
comment on column USER_FLASHBACK_ARCHIVE.CREATE_TIME is
'Time at which the flashback archive was created'
/
comment on column USER_FLASHBACK_ARCHIVE.LAST_PURGE_TIME is
'Time at which the data in the flashback archive was last purged by the system'
/
comment on column USER_FLASHBACK_ARCHIVE.STATUS is
'Indicates whether the flashback archive is a default flashback archive for the system'
/

/*
 * Show for all flashback archives in the system the associated tablespaces 
 * to DBA or Flashback Archive Admin
 */
create or replace view DBA_FLASHBACK_ARCHIVE_TS
    (FLASHBACK_ARCHIVE_NAME, FLASHBACK_ARCHIVE#, TABLESPACE_NAME, QUOTA_IN_MB)
as select f.FANAME, fts.FA#, t.NAME, decode(fts.QUOTA, 0, NULL, fts.QUOTA) 
from SYS_FBA_FA f, SYS_FBA_TSFA fts, TS$ t 
where fts.TS# = t.TS# and fts.FA# = f.FA#
/
create or replace public synonym DBA_FLASHBACK_ARCHIVE_TS for DBA_FLASHBACK_ARCHIVE_TS
/
grant select on DBA_FLASHBACK_ARCHIVE_TS to PUBLIC with grant option
/
comment on table DBA_FLASHBACK_ARCHIVE_TS is
'Description of tablespaces in the flashback archives available in the system'
/
comment on column DBA_FLASHBACK_ARCHIVE_TS.FLASHBACK_ARCHIVE_NAME is
'Name of the flashback archive'
/
comment on column DBA_FLASHBACK_ARCHIVE_TS.FLASHBACK_ARCHIVE# is
'Number of the flashback archive'
/
comment on column DBA_FLASHBACK_ARCHIVE_TS.TABLESPACE_NAME is
'Name of a tablespace in the flashback archive'
/
comment on column DBA_FLASHBACK_ARCHIVE_TS.QUOTA_IN_MB is
'Maximum space in MB that can be used for Flashback Archive from the tablespace. NULL indicates no Quota restriction'
/

/* 
 * Show all tables enabled for flashback archive in the system to 
 * DBA or Flashback Archive Admin
 */
create or replace view DBA_FLASHBACK_ARCHIVE_TABLES
    (TABLE_NAME, OWNER_NAME, FLASHBACK_ARCHIVE_NAME, ARCHIVE_TABLE_NAME, STATUS)
as select o.NAME, u.NAME, f.FANAME, 'SYS_FBA_HIST_'||o.obj#,
     case bitand(t.FLAGS,160) 
       when 128 then 'DISABLED'
       when 32  then 'DISASSOCIATED'
       else 'ENABLED'
     end
from OBJ$ o, USER$ u, SYS_FBA_FA f, SYS_FBA_TRACKEDTABLES t 
where t.FA# = f.FA# and t.OBJ# = o.OBJ# and o.OWNER# = u.USER#
/
create or replace public synonym DBA_FLASHBACK_ARCHIVE_TABLES for DBA_FLASHBACK_ARCHIVE_TABLES
/
grant select on DBA_FLASHBACK_ARCHIVE_TABLES to PUBLIC with grant option
/
comment on table DBA_FLASHBACK_ARCHIVE_TABLES is
'Information about the tables that are enabled for Flashback Archive'
/
comment on column DBA_FLASHBACK_ARCHIVE_TABLES.TABLE_NAME is
'Name of the table enabled for Flashback Archive'
/
comment on column DBA_FLASHBACK_ARCHIVE_TABLES.OWNER_NAME is
'Owner name of the table enabled for Flashback Archive'
/
comment on column DBA_FLASHBACK_ARCHIVE_TABLES.FLASHBACK_ARCHIVE_NAME is
'Name of the flashback archive'
/
comment on column DBA_FLASHBACK_ARCHIVE_TABLES.ARCHIVE_TABLE_NAME is
'Name of the archive table containing the historical data for the user table'
/
comment on column DBA_FLASHBACK_ARCHIVE_TABLES.STATUS is
'Status of whether flashback archive is enabled or being disabled on the table'
/

/* 
 * Show only those tables enabled for flashback archive in the system 
 * by the logged in user provided the user has owner/alter privilege on 
 * the table. In addition, If user is not DBA or Flashback Archive Admin 
 * the user has to have object privilege on the flashback archive where 
 * the history for table is archived
 */
create or replace view USER_FLASHBACK_ARCHIVE_TABLES
    (TABLE_NAME, OWNER_NAME, FLASHBACK_ARCHIVE_NAME, ARCHIVE_TABLE_NAME, STATUS)
as select unique o.NAME, d.USERNAME, f.FANAME, 'SYS_FBA_HIST_'||o.obj#,
     case bitand(t.FLAGS,160) 
       when 128 then 'DISABLED'
       when 32  then 'DISASSOCIATED'
       else 'ENABLED'
     end
from OBJ$ o, USER$ u, SYS_FBA_FA f, SYS_FBA_TRACKEDTABLES t, 
     SYS.OBJAUTH$ oa, SYS.DBA_USERS d
where t.FA# = f.FA# and t.OBJ# = o.OBJ# and o.OWNER# = d.USER_ID and
  /* user is owner of the table or has alter privilege on the table */
  ((o.OWNER# = u.USER#) or      
   (o.OBJ# = oa.OBJ# and oa.GRANTEE# = u.user# and oa.PRIVILEGE# = 0)) 
  and 
  /* user has system privileges or flashback archive object privilege */
  ((exists (select null from v$enabledprivs where priv_number = -350)) or
   (t.FA# = (select FA# from SYS_FBA_USERS fp where fp.user# = u.USER#))) 
  and
  /* show only this user's objects */
  (u.user# = userenv('SCHEMAID'))
/
create or replace public synonym USER_FLASHBACK_ARCHIVE_TABLES for USER_FLASHBACK_ARCHIVE_TABLES
/
grant select on USER_FLASHBACK_ARCHIVE_TABLES to PUBLIC with grant option
/
comment on table USER_FLASHBACK_ARCHIVE_TABLES is
'Information about the user tables that are enabled for Flashback Archive'
/
comment on column USER_FLASHBACK_ARCHIVE_TABLES.TABLE_NAME is
'Name of the table enabled for Flashback Archive'
/
comment on column USER_FLASHBACK_ARCHIVE_TABLES.OWNER_NAME is
'Owner name of the table enabled for Flashback Archive'
/
comment on column USER_FLASHBACK_ARCHIVE_TABLES.FLASHBACK_ARCHIVE_NAME is
'Name of the flashback archive'
/
comment on column USER_FLASHBACK_ARCHIVE_TABLES.ARCHIVE_TABLE_NAME is
'Name of the archive table containing the historical data for the user table'
/
comment on column USER_FLASHBACK_ARCHIVE_TABLES.STATUS is
'Status of whether flashback archive is enabled or being disabled on the table'
/

