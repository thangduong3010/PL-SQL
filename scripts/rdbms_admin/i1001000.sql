Rem
Rem $Header: i1001000.sql 12-oct-2006.00:57:48 slynn Exp $
Rem
Rem i1001000.sql
Rem
Rem Copyright (c) 1999, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      i1001000.sql - load 10.2 specific tables that are need to
Rem                     process basic DDL statements
Rem
Rem    DESCRIPTION
Rem      This script MUST be one of the first things called from the 
Rem      top-level upgrade script.
Rem
Rem      Only put statements in here that must be run in order
Rem      to process basic sql commands.  For example, in order to 
Rem      drop a package, the server code may depend on new tables.
Rem      If these tables do not exist, a recursive sql error will occur,
Rem      causing the command to be aborted.
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: load 10.2 specific tables 
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem 
Rem    MODIFIED   (MM/DD/YY)
Rem    slynn       10/12/06 - smartfile->securefile
Rem    smuthuli    05/19/06 - project 18567: nglob 
Rem    cdilling    06/08/05 - call i1002000 
Rem    rburns      04/13/05 - fix up 901 dependency 
Rem    xuhuali     07/01/04 - audit java
Rem    rdecker     03/03/04 - support for procedureplsql$
Rem    rburns      01/16/04 - rburns_add_10_1_updw_scripts 
Rem    rburns      01/07/04 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: load 10.2 specific tables for basic DDL
Rem =========================================================================

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

Rem remove obsolete dependencies before dropping any fixed views
--delete from dependency$ where d_obj# in (select obj# from obj$ where name in
--  (<list of removed fixed view names>));

Rem need explicit delete for 10.1 fixed objects not in 10.2
--delete from dependency$ where p_obj# in (<list of fixed object numbers>);
--commit;

Rem clean up 901 type dependency$
select distinct o.name from obj$ o, dependency$ d
where o.stime != d.p_timestamp and 
      o.type#=13 and
      o.obj# = d.p_obj#;

update dependency$ d set p_timestamp = 
      (select stime from obj$ p
       where d.p_obj#=p.obj#)
where d.p_obj# in (select obj# from obj$ where type#=13) and
      d.p_timestamp != (select stime from obj$ o
                        where d.p_obj#=o.obj#);

alter system flush shared_pool;

Rem Add sql.bsq changes required for 10.2 basic DDL here

Rem Create table for collecting plsql metadata
create table procedureplsql$
( obj#          number not null,                 /* spec/body object number */
  procedure#    number not null,                 /* procedure# or position */
  entrypoint#   number not null)                 /* entrypoint table entry# */
/
create unique index i_procedureplsql$ on procedureplsql$ (obj#, procedure#)
/

Rem
Rem javaobj$ contains information about java objects (java class, java source 
Rem java resource, java data and etc). 
Rem the audit$ field length should be the same as S_OPFL defined in gendef.h. 
Rem
create table javaobj$                                   /* java object table */
( obj#          number not null,                            /* object number */
  audit$        varchar2(38) not null                     /* auditing options */
)
/
create unique index i_javaobj1 on javaobj$(obj#)
/

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

@@i1002000

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END i1001000.sql
Rem *************************************************************************











