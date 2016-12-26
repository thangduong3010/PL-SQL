Rem
Rem $Header: utlstddw.sql 11-apr-00.06:13:58 jdavison Exp $
Rem
Rem utlstddw.sql
Rem
Rem  Copyright (c) Oracle Corporation 1999, 2000. All Rights Reserved.
Rem
Rem    NAME
Rem      utlstddw.sql - UTL STanDard.sql DoWngrade
Rem
Rem    DESCRIPTION
Rem          Before the downgraded database is open,
Rem          the timestamps in dependency$ and obj$ must 
Rem          be changed for standard spec and for all objects that depend
Rem          on standard because of the timestamp change that was introduced
Rem          in standard in version 8.1.6.  Without doing this, 
Rem          tables with type dependencies will cause a hang because
Rem          the dependency has become invalid.  If left for long enough,
Rem          this will eat all the memory on the system and make a reboot 
Rem          necessary.  See bug 994326 for more information.
Rem
Rem    NOTES:**** IMPORTANT -- THIS MUST BE RUN WHEN DOWNGRADING *****
Rem          **** TO A PRE-8.1.6 DATABASE AND BEFORE OPENING THE  *****
Rem          **** PRE-8.1.6 DATABASE !!!!!!!!!!!!!!!!!!!!!!!!!!! *****
Rem          If this is not run before the pre-8.1.6 database is 
Rem          opened and standard.sql is loaded, then all the obj$.status
Rem          values will be changed to "5".  Once this happens, it
Rem          is very hard to figure out which objects have status "5"
Rem          for a good reason, and which have status "5" because
Rem          of this problem.
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jdavison    04/11/00 - Modify usage notes for 8.2 changes.
Rem    rshaikh     09/22/99 - bug 994326: modify timestamps for standard
Rem    rshaikh     09/22/99 - Created
Rem

alter system flush shared_pool
/

update obj$ set stime = 
	to_date('1996-11-19:00:00:00', 'YYYY-MM-DD:HH24:MI:SS') 
  where name='STANDARD' and  
	type#=9 and
	owner# = (select user# from user$ where name='SYS')
/

update dependency$ set p_timestamp =
	to_date('1996-11-19:00:00:00', 'YYYY-MM-DD:HH24:MI:SS') 
  where p_obj# = (select o.obj# from obj$ o, user$ u where o.owner#=u.user#
           	    and u.name='SYS' and o.name='STANDARD' and o.type#=9)
/

commit
/
