Rem
Rem $Header: catspaced.sql 05-nov-98.11:28:51 rshaikh Exp $
Rem
Rem catspaced.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998. All Rights Reserved.
Rem
Rem    NAME
Rem      catspaced.sql - space management downgrade
Rem
Rem    DESCRIPTION
Rem      remove views created in catspace.sql for downgrade
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rshaikh     11/05/98 - dont drop some views
Rem    rshaikh     05/01/98 - create
Rem    rshaikh     05/01/98 - Created
Rem

drop view SYS_OBJECTS;
drop view SYS_USER_SEGS;
drop view SYS_DBA_SEGS;

drop view USER_SEGMENTS;
drop public synonym DBA_SEGMENTS;
drop view DBA_SEGMENTS;

drop view USER_EXTENTS;
drop public synonym DBA_EXTENTS;
drop view DBA_EXTENTS;

drop public synonym USER_FREE_SPACE;
drop view USER_FREE_SPACE;
drop public synonym DBA_FREE_SPACE;
drop view DBA_FREE_SPACE;
drop view DBA_FREE_SPACE_COALESCED_TMP1;
drop view DBA_FREE_SPACE_COALESCED_TMP2;
drop view DBA_FREE_SPACE_COALESCED_TMP3;
drop public synonym DBA_FREE_SPACE_COALESCED;
drop view DBA_FREE_SPACE_COALESCED;

drop public synonym DBA_DATA_FILES;
drop view DBA_DATA_FILES;

drop view FILEXT$;

drop view USER_TABLESPACES;

drop public synonym DBA_TEMP_FILES;
drop view DBA_TEMP_FILES;

drop view v_$temp_extent_map;
drop public synonym v$temp_extent_map;

drop view gv_$temp_extent_map;
drop public synonym gv$temp_extent_map;

drop view v_$temp_extent_pool;
drop public synonym v$temp_extent_pool;

drop view gv_$temp_extent_pool;
drop public synonym gv$temp_extent_pool;

drop view v_$temp_space_header;
drop public synonym v$temp_space_header;

drop view gv_$temp_space_header;
drop public synonym gv$temp_space_header;






