Rem
Rem $Header: catcrc.sql 09-jun-2007.13:36:25 mbastawa Exp $
Rem
Rem catcrc.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catcrc.sql - CATalog Client Result Cache
Rem
Rem    DESCRIPTION
Rem      The file contains the dictionary information for client result cache
Rem      in the SYS schema. The table(s) are:
Rem          CRC$_RESULT_CACHE_STATS - stores information about each 
Rem                                     client result cache statistic
Rem
Rem    NOTES
Rem     Must be run when connected to SYS or INTERNAL.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mbastawa    05/31/07 - filter rows from stats
Rem    mbastawa    02/13/07 - add view for stats table
Rem    mbastawa    08/31/06 - client result cache
Rem    mbastawa    08/31/06 - Created
Rem

-- TABLE CRC$_RESULT_CACHE_STATS : client result set cache statistics
CREATE TABLE crc$_result_cache_stats
(
  cache_id   number not null,
  stat_id    number, 
  name       varchar2(128),
  value      number,
   constraint crc$_rcstatspk  primary key (cache_id,stat_id)
)
  TABLESPACE SYSAUX
/

comment on table CRC$_RESULT_CACHE_STATS is 
'Internal table for client result cache statistics. Statistics are stored as name value pairs. For each client cache ID there will be multiple rows for each statistic.'
/

comment on column CRC$_RESULT_CACHE_STATS.CACHE_ID is 
'Unique ID per client cache'
/
comment on column CRC$_RESULT_CACHE_STATS.STAT_ID is 
'ID of the statistic'
/
comment on column CRC$_RESULT_CACHE_STATS.NAME is 
'Name of the statistic'
/
comment on column CRC$_RESULT_CACHE_STATS.VALUE is 
'Value of the statistic'
/

Rem Creating view for statistic table 
create or replace view crcstats_$ as 
     select * from crc$_result_cache_stats where cache_id != 0;
create or replace public synonym client_result_cache_stats$ for crcstats_$;
grant select on client_result_cache_stats$ to select_catalog_role;

