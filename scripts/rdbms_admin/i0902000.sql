Rem
Rem $Header: i0902000.sql 12-oct-2006.00:57:45 slynn Exp $
Rem
Rem i0902000.sql
Rem
Rem Copyright (c) 1999, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      i0902000.sql - load 10.1 specific tables that are need to
Rem      process basic DDL statements
Rem
Rem    DESCRIPTION
Rem      This script MUST be one of the first things called from the 
Rem      one path upgrade scripts (ie - u0902000.sql, ...)
Rem
Rem      Only put statements in here that must be run in order
Rem      to process basic sql commands.  For example, in order to 
Rem      drop a package, the server code may depend on new tables.
Rem      If these tables do not exist, we get a recursive sql error
Rem      causing the command to be aborted.
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: load 10.1 specific tables 
Rem        STAGE 2: invoke script for subsequent version
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem    slynn       10/12/06 - smartfile->securefile
Rem    smuthuli    05/19/06 - project 18567: nglob 
Rem    smuthuli    05/02/06 - project 18567 
Rem    rburns      11/04/05 - change for patch script 
Rem    rburns      01/07/04 - add calls to 10.1 scripts 
Rem    kmuthukk    10/27/03 - add dllname column to ncomp_dll$
Rem    arithikr    10/24/03 - 3126930 - add drop_segments column to mon_mods 
Rem    rburns      08/28/03 - cleanup 
Rem    rburns      06/27/03 - add removed fixed tables
Rem    arithikr    06/30/03 - 1486580 - add sys.ind_online$ table
Rem    krajaman    05/20/03 - Remove d_owner# from dependency$
Rem    tbgraves    03/13/03 - revert_updown_scripts
Rem    spolsani    11/21/02 - 
Rem    tbgraves    10/04/02 - no tabs
Rem    tbgraves    10/03/02 - svrmgmt updown scripts
Rem    rxgovind    09/15/02 - finer grained dependencies
Rem    weiwang     07/30/02 - back out rules engine upgrade script
Rem    weiwang     04/11/02 - add rules engine upgrade script
Rem    rburns      06/05/02 - move dependency deletes
Rem    rburns      03/17/02 - rburns_10i_updown_scripts
Rem    rburns      02/12/02 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: load 10.1 specific tables for basic DDL
Rem =========================================================================

Rem set SYSTEM tablespace as the default permanent tablespace
Rem do not change or insert anything if a value already exists

Rem Add columns to partition dictionary.
alter table partlob$ add (
  defmaxsize  number,
  defretention  number,
  defmintime number);

alter table tabcompart$ add (
  defmaxsize  number);

alter table partobj$ add (
  defmaxsize  number);

alter table lobcomppart$ add (
  defmaxsize  number,
  defretention  number,
  defmintime number);

alter table indcompart$ add (
  defmaxsize  number);

insert into props$ (name, value$, comment$) 
    (select 'DEFAULT_PERMANENT_TABLESPACE', 'SYSTEM',
            'Default Permanent Tablespace ID' from dual
     where 'DEFAULT_PERMANENT_TABLESPACE' NOT IN 
     (select name from props$ where name =  'DEFAULT_PERMANENT_TABLESPACE'));
commit;

Rem remove obsolete dependencies before dropping any fixed views
delete from dependency$ where d_obj# in (select obj# from obj$ where name in
  ('V_$COMPATIBILITY', 'GV_$COMPATIBILITY', 'V_$COMPATSEG', 'GV_$COMPATSEG'));

Rem need explicit delete for 9.2 fixed objects not in 10.1
Rem     V$COMPATIBILITY,V$COMPATSEG,GV$COMPATIBILITY,GV$COMPATSEG,
Rem     X$KSFHDVNT,X$KSMGST,X$KSMGOP,X$KSMGV,X$KSMGSC,X$BUFQM,
Rem     X$TEMPORARY_LOB_REFCNT
delete from dependency$ where p_obj# in (4294951125,4294951126,4294951321,
        4294951322,4294951380,4294951662,4294951663,4294951664,4294951734,
        4294951932,4294951944);
commit;

Rem Remove d_owner# from dependency$
ALTER TABLE dependency$ modify(d_owner# null);
Rem Finer grained dependencies need these extra columns in dependency$
ALTER TABLE dependency$ ADD(d_attrs raw(2000), d_reason raw(2000));

create table ncomp_dll$         /* table for ncomp dlls */
( obj#          number not null,       /* object number */
  version       number,               /* version number */
  dll           blob,                     /* dll object */
  dllname       raw(1024)) /* os base file name for dll */
  storage (initial 10k next 100k maxextents unlimited pctincrease 0);

create unique index i_ncomp_dll1 ON ncomp_dll$(obj#, version);
REM
REM ADD warning_settings$
rem  
create table warning_settings$ (
  obj#          number not null,                            /* object number */
  warning_num   number not null,                            /* warning number*/
  global_mod     number,                                   /* global modifier*/
  property      number);   
create index i_warning_settings on warning_settings$(obj#);

REM
REM ADD IND_ONLINE$ table to keep track of ONLINE index rebuild
REM
create table ind_online$
( obj#          number not null,
  type#         number not null,              /* what kind of index is this? */
                                                               /* normal : 1 */
                                                               /* bitmap : 2 */
                                                              /* cluster : 3 */
                                                            /* iot - top : 4 */
                                                         /* iot - nested : 5 */
                                                            /* secondary : 6 */
                                                                 /* ansi : 7 */
                                                                  /* lob : 8 */
                                             /* cooperative index method : 9 */
  flags         number not null
                                      /* index is being online built : 0x100 */
                                    /* index is being online rebuilt : 0x200 */
);

rem
REM changes IN error$
REM
ALTER TABLE error$   ADD (
                           property      NUMBER default 0,
                           error#        NUMBER default 0);

Rem ===========================================
Rem add drop_segments column to mon_mods$ table
Rem See comments in sql.bsq
Rem if the column is already existed, just ignore the ORA-01430
Rem ===========================================
alter table sys.mon_mods$ add
(
   drop_segments number default 0
)
/

alter system flush shared_pool;

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release 
Rem =========================================================================

@@i1001000

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release 
Rem =========================================================================

Rem *************************************************************************
Rem END i0902000.sql
Rem *************************************************************************

