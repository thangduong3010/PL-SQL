rem 
rem $Header: catblock.sql 06-nov-2007.05:30:41 kquinn Exp $ blocking.sql 
rem 
Rem Copyright (c) 1989, 2007, Oracle. All rights reserved.  
Rem NAME
Rem    catblock.sql
Rem  FUNCTION  -  create views of oracle locks
Rem  NOTES
Rem  MODIFIED
Rem     kquinn     11/06/07  - 6440408: avoid numeric overflow
Rem     kigoyal    01/06/04  - DBA_WAITERS/BLOCKERS to use "enq:%"
Rem     gviswana   05/24/01  - CREATE OR REPLACE SYNONYM
Rem     jdavison   10/10/00  - Fix dba_lock_internal view
Rem     vsaksena   07/07/00  - Optimize views DBA_BLOCKERS, DBA_WAITERS
Rem     arithikr   02/10/00 -  878668: Fix DBA_WAITERS view for OPS environment
Rem     sparrokk   12/17/99  - 1040651: Use v$lock defn without hint 
Rem                            in dba_dml_locks
Rem     mjungerm   06/15/99 -  add java shared data object type
Rem     nireland   03/17/98 -  Add synonyms for DBA_WAITERS, DBA_BLOCKERS
Rem                            and others. #605559
Rem     agardner   04/02/97 -  bug #226646: remove comment
Rem     jwijaya    03/19/97 -  support types
Rem     asurpur    04/08/96 -  Dictionary Protection Implementation
Rem     pgreenwa   08/14/95 -  bug #293557: optimize view queries
Rem     wmaimone   01/04/96 -  7.3 merge
Rem     pgreenwa   05/10/95 -  fix dba_lock_internal
Rem     pgreenwa   04/25/95 -  add new vlock columns
Rem     drady      03/22/93 -  merge changes from branch 1.1.312.1 
Rem     drady      03/18/93 -  fix 154271 
Rem     glumpkin   10/17/92 -  renamed from BLOCKING.SQL 
Rem     tpystyne   09/14/92 -  rename sid to session_id 
Rem     jloaiza    07/30/92 -  fix for KGL change 
Rem   tpystyne   05/27/92 - add dba_dml_locks and dba_ddl_locks views
Rem   jloaiza    05/24/91 - upgrade for v7 
Rem   Loaiza     11/01/89 - Creation
Rem


/* this is an auxiliary view containing the KGL locks and pins */
create or replace view DBA_KGLLOCK as
  select kgllkuse, kgllkhdl, kgllkmod, kgllkreq, 'Lock' kgllktype from x$kgllk
 union all
  select kglpnuse, kglpnhdl, kglpnmod, kglpnreq, 'Pin'  kgllktype from x$kglpn;
create or replace public synonym DBA_KGLLOCK for DBA_KGLLOCK;
grant select on DBA_KGLLOCK to select_catalog_role;

/* 
 * DBA_LOCK has a row for each lock that is being held, and 
 * one row for each outstanding request for a lock or latch.
 * The columns of DBA_LOCK are:
 *   session_id     - session holding or acquiring the lock
 *   type           - type of lock
 *   mode_held      - mode the lock is currently held in by the session
 *   mode_requested - mode that the lock is being requested in by the process
 *   lock_id1            - type specific identifier of the lock
 *   lock_id2            - type specific identifier of the lock
 *   last_convert   - time (in seconds) since last convert completed
 *   blocking_others     - is this lock blocking other locks
 */
drop synonym DBA_LOCKS;
drop view DBA_LOCKS;
create or replace view DBA_LOCK as
  select 
	sid session_id,
	decode(type, 
		'MR', 'Media Recovery', 
		'RT', 'Redo Thread',
		'UN', 'User Name',
		'TX', 'Transaction',
		'TM', 'DML',
		'UL', 'PL/SQL User Lock',
		'DX', 'Distributed Xaction',
		'CF', 'Control File',
		'IS', 'Instance State',
		'FS', 'File Set',
		'IR', 'Instance Recovery',
		'ST', 'Disk Space Transaction',
		'TS', 'Temp Segment',
		'IV', 'Library Cache Invalidation',
		'LS', 'Log Start or Switch',
		'RW', 'Row Wait',
		'SQ', 'Sequence Number',
		'TE', 'Extend Table',
		'TT', 'Temp Table',
		type) lock_type,
	decode(lmode, 
		0, 'None',           /* Mon Lock equivalent */
		1, 'Null',           /* N */
		2, 'Row-S (SS)',     /* L */
		3, 'Row-X (SX)',     /* R */
		4, 'Share',          /* S */
		5, 'S/Row-X (SSX)',  /* C */
		6, 'Exclusive',      /* X */
		to_char(lmode)) mode_held,
         decode(request,
		0, 'None',           /* Mon Lock equivalent */
		1, 'Null',           /* N */
		2, 'Row-S (SS)',     /* L */
		3, 'Row-X (SX)',     /* R */
		4, 'Share',          /* S */
		5, 'S/Row-X (SSX)',  /* C */
		6, 'Exclusive',      /* X */
		to_char(request)) mode_requested,
         to_char(id1) lock_id1, to_char(id2) lock_id2,
	 ctime last_convert,
	 decode(block,
	        0, 'Not Blocking',  /* Not blocking any other processes */
		1, 'Blocking',      /* This lock blocks other processes */
		2, 'Global',        /* This lock is global, so we can't tell */
		to_char(block)) blocking_others
      from v$lock;
create or replace public synonym DBA_LOCK for DBA_LOCK;
grant select on DBA_LOCK to select_catalog_role;
create or replace public synonym DBA_LOCKS for DBA_LOCK;

/*
 * DBA_LOCK_INTERNAL has a row for each lock or latch that is being held, and 
 * one row for each outstanding request for a lock or latch.
 * The columns  of DBA_LOCK_INTERNAL are:
 *   session_id     - session holding or acquiring the lock
 *   type           - type of lock (DDL, LATCH, etc.)
 *   mode_held      - mode the lock is currently held in by the session
 *   mode_requested - mode that the lock is being requested in by the process
 *   lock_id1            - type specific identifier of the lock
 *   lock_id2            - type specific identifier of the lock
 *
 * NOTE: this view can be very, very slow depending on the size of your
 *	 shared pool area and database activity.
 */
create or replace view DBA_LOCK_INTERNAL as
  select 
	sid session_id,
	decode(type, 
		'MR', 'Media Recovery', 
		'RT', 'Redo Thread',
		'UN', 'User Name',
		'TX', 'Transaction',
		'TM', 'DML',
		'UL', 'PL/SQL User Lock',
		'DX', 'Distributed Xaction',
		'CF', 'Control File',
		'IS', 'Instance State',
		'FS', 'File Set',
		'IR', 'Instance Recovery',
		'ST', 'Disk Space Transaction',
		'TS', 'Temp Segment',
		'IV', 'Library Cache Invalidation',
		'LS', 'Log Start or Switch',
		'RW', 'Row Wait',
		'SQ', 'Sequence Number',
		'TE', 'Extend Table',
		'TT', 'Temp Table',
		type) lock_type,
	decode(lmode, 
		0, 'None',           /* Mon Lock equivalent */
		1, 'Null',           /* N */
		2, 'Row-S (SS)',     /* L */
		3, 'Row-X (SX)',     /* R */
		4, 'Share',          /* S */
		5, 'S/Row-X (SSX)',  /* C */
		6, 'Exclusive',      /* X */
		to_char(lmode)) mode_held,
         decode(request,
		0, 'None',           /* Mon Lock equivalent */
		1, 'Null',           /* N */
		2, 'Row-S (SS)',     /* L */
		3, 'Row-X (SX)',     /* R */
		4, 'Share',          /* S */
		5, 'S/Row-X (SSX)',  /* C */
		6, 'Exclusive',      /* X */
		to_char(request)) mode_requested,
         to_char(id1) lock_id1, to_char(id2) lock_id2
      from v$lock                /* processes waiting on or holding enqueues */
 union all                                          /* procs holding latches */
  select s.sid, 'LATCH', 'Exclusive', 'None', rawtohex(laddr), ' '
    from v$process p, v$session s, v$latchholder h
   where h.pid  = p.pid                       /* 6 = exclusive, 0 = not held */
    and  p.addr = s.paddr
 union all                                         /* procs waiting on latch */
  select sid, 'LATCH', 'None', 'Exclusive', rawtohex(latchwait), ' '
     from v$session s, v$process p
    where latchwait is not null
     and  p.addr = s.paddr
 union all                                            /* library cache locks */
  select  s.sid,
    decode(ob.kglhdnsp, 0, 'Cursor', 1, 'Table/Procedure/Type', 2, 'Body', 
	     3, 'trigger', 4, 'Index', 5, 'Cluster', 13, 'Java Source',
             14, 'Java Resource', 32, 'Java Data', to_char(ob.kglhdnsp))
	  || ' Definition ' || lk.kgllktype,
    decode(lk.kgllkmod, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
	   to_char(lk.kgllkmod)),
    decode(lk.kgllkreq,  0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
	   to_char(lk.kgllkreq)),
    decode(ob.kglnaown, null, '', ob.kglnaown || '.') || ob.kglnaobj ||
    decode(ob.kglnadlk, null, '', '@' || ob.kglnadlk),
    rawtohex(lk.kgllkhdl)
   from v$session s, x$kglob ob, dba_kgllock lk
     where lk.kgllkhdl = ob.kglhdadr
      and  lk.kgllkuse = s.saddr;
create or replace public synonym DBA_LOCK_INTERNAL for DBA_LOCK_INTERNAL;
grant select on DBA_LOCK_INTERNAL to select_catalog_role;
  
/*
 * DBA_DML_LOCKS has a row for each DML lock that is being held, and 
 * one row for each outstanding request for a DML lock. It is subset
 * of DBA_LOCKS
 */

create or replace view DBA_DML_LOCKS as
  select 
	sid session_id,
        u.name owner,
        o.name,
	decode(lmode, 
		0, 'None',           /* Mon Lock equivalent */
		1, 'Null',           /* N */
		2, 'Row-S (SS)',     /* L */
		3, 'Row-X (SX)',     /* R */
		4, 'Share',          /* S */
		5, 'S/Row-X (SSX)',  /* C */
		6, 'Exclusive',      /* X */
		'Invalid') mode_held,
         decode(request,
		0, 'None',           /* Mon Lock equivalent */
		1, 'Null',           /* N */
		2, 'Row-S (SS)',     /* L */
		3, 'Row-X (SX)',     /* R */
		4, 'Share',          /* S */
		5, 'S/Row-X (SSX)',  /* C */
		6, 'Exclusive',      /* X */
		'Invalid') mode_requested,
	 l.ctime last_convert,
	 decode(block,
	        0, 'Not Blocking',  /* Not blocking any other processes */
		1, 'Blocking',      /* This lock blocks other processes */
		2, 'Global',        /* This lock is global, so we can't tell */
		to_char(block)) blocking_others
      from (select l.laddr addr, l.kaddr kaddr,  /* 1040651: Defn for v$lock */
                   s.ksusenum sid, r.ksqrsidt type, r.ksqrsid1 id1,
                   r.ksqrsid2 id2, l.lmode lmode, l.request request,
                   l.ctime ctime, l.block block
              from v$_lock l, x$ksuse s, x$ksqrs r
              where l.saddr = s.addr and l.raddr = r.addr and
                    s.inst_id = USERENV('Instance')) l, obj$ o, user$ u
      where l.id1 = o.obj#
      and   o.owner# = u.user#
      and   l.type = 'TM';
create or replace public synonym DBA_DML_LOCKS for DBA_DML_LOCKS;
grant select on DBA_DML_LOCKS to select_catalog_role;

/*
 * DBA_DDL_LOCKS has a row for each DDL lock that is being held, and 
 * one row for each outstanding request for a DDL lock. It is subset
 * of DBA_LOCKS
 */

create or replace view DBA_DDL_LOCKS as
  select  s.sid session_id,
          substr(ob.kglnaown,1,30) owner,
          substr(ob.kglnaobj,1,30) name,
    decode(ob.kglhdnsp, 0, 'Cursor', 1, 'Table/Procedure/Type', 2, 'Body', 
           3, 'Trigger', 4, 'Index', 5, 'Cluster', 13, 'Java Source',
             14, 'Java Resource', 32, 'Java Data', to_char(ob.kglhdnsp)) type,
    decode(lk.kgllkmod, 0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
	   'Unknown') mode_held,
    decode(lk.kgllkreq,  0, 'None', 1, 'Null', 2, 'Share', 3, 'Exclusive',
	   'Unknown') mode_requested
   from v$session s, x$kglob ob, x$kgllk lk
   where lk.kgllkhdl = ob.kglhdadr
   and   lk.kgllkuse = s.saddr
   and   ob.kglhdnsp != 0;
create or replace public synonym DBA_DDL_LOCKS for DBA_DDL_LOCKS;
grant select on DBA_DDL_LOCKS to select_catalog_role;

/*
 * Show all the sessions waiting for locks and the session that holds the 
 * lock.
 */
create or replace view DBA_WAITERS
(waiting_session
,holding_session
,lock_type
,mode_held
,mode_requested
,lock_id1
,lock_id2)
 as
select /*+ordered */ w.sid
      ,s.ksusenum
      ,decode(r.ksqrsidt,
                'MR', 'Media Recovery',
                'RT', 'Redo Thread',
                'UN', 'User Name',
                'TX', 'Transaction',
                'TM', 'DML',
                'UL', 'PL/SQL User Lock',
                'DX', 'Distributed Xaction',
                'CF', 'Control File',
                'IS', 'Instance State',
                'FS', 'File Set',
                'IR', 'Instance Recovery',
                'ST', 'Disk Space Transaction',
                'TS', 'Temp Segment',
                'IV', 'Library Cache Invalidation',
                'LS', 'Log Start or Switch',
                'RW', 'Row Wait',
                'SQ', 'Sequence Number',
                'TE', 'Extend Table',
                'TT', 'Temp Table',
                r.ksqrsidt)
      ,decode(l.lmode,
                0, 'None',           /* Mon Lock equivalent */
                1, 'Null',           /* N */
                2, 'Row-S (SS)',     /* L */
                3, 'Row-X (SX)',     /* R */
                4, 'Share',          /* S */
                5, 'S/Row-X (SSX)',  /* C */
                6, 'Exclusive',      /* X */
                l.lmode)
      ,decode(bitand(w.p1,65535),
                0, 'None',           /* Mon Lock equivalent */
                1, 'Null',           /* N */
                2, 'Row-S (SS)',     /* L */
                3, 'Row-X (SX)',     /* R */
                4, 'Share',          /* S */
                5, 'S/Row-X (SSX)',  /* C */
                6, 'Exclusive',      /* X */
                to_char(bitand(w.p1,65535)))
      ,r.ksqrsid1, r.ksqrsid2
  from v$session_wait w, x$ksqrs r, v$_lock l, x$ksuse s
 where w.wait_Time = 0
   and w.event like 'enq:%'
   and r.ksqrsid1 = w.p2
   and r.ksqrsid2 = w.p3
   and r.ksqrsidt = chr(bitand(p1,4278190080)/16777215)||
                   chr(bitand(p1,16711680)/65535)
   and l.block = 1
   and l.saddr = s.addr
   and l.raddr = r.addr
   and s.inst_id = userenv('Instance');

create or replace public synonym DBA_WAITERS for DBA_WAITERS;
grant select on DBA_WAITERS to select_catalog_role;

/*
 * Show all the sessions that have someone waiting on a lock they hold, but
 * that are not themselves waiting on a lock.
 */
create or replace view DBA_BLOCKERS as
select /*+ordered */ distinct s.ksusenum holding_session
  from v$session_wait w, x$ksqrs r, v$_lock l, x$ksuse s
 where w.wait_Time = 0
   and w.event like 'enq:%'
   and r.ksqrsid1 = w.p2
   and r.ksqrsid2 = w.p3
   and r.ksqrsidt = chr(bitand(p1,4278190080)/16777215)||
                   chr(bitand(p1,16711680)/65535)
   and l.block = 1
   and l.saddr = s.addr
   and l.raddr = r.addr
   and s.inst_id = userenv('Instance');

create or replace public synonym DBA_BLOCKERS for DBA_BLOCKERS;
grant select on DBA_BLOCKERS to select_catalog_role;
