Rem
Rem $Header: rdbms/admin/catexp7.sql /st_rdbms_11.2.0/2 2013/07/07 09:03:20 mjungerm Exp $
Rem
Rem catexp7.sql
Rem
Rem Copyright (c) 1996, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catexp7.sql - CATalog EXPort views for v7 SQL script
Rem
Rem    DESCRIPTION
Rem      Create v7 style export/import views against the v8 RDBMS
Rem      so that EXP/IMP v7 can be used to read out data in a v8 RDBMS
Rem
Rem    NOTES
Rem
Rem    This file is organized into 3 sections:
Rem	Section 1: Views needed by BOTH export and import
Rem	Section 2: Views required by import ONLY
Rem 	Section 3: Views required by export ONLY
Rem
Rem	No views depend on catalog.sql. This script can be run standalone.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jgalanes    10/15/04 - 3651756 switch from SELECT_CATALOG_ROLE 
Rem                           to ExP_FULL_DATABASE on exu?lnk 
Rem    prakumar    01/07/02 - #1930790:Consider tables with property 536870912
Rem    prakumar    04/04/01 - In exu7uscu,compare ind$.file# with file$.relfile#
Rem    sbalaram    06/28/00 - Fix exu7tgr view
Rem    rmurthy     06/20/00 - change objauth.option column to hold flag bits
Rem    nireland    03/14/00 - Fix view dependency ordering. #1170962
Rem    wesmith     11/13/98 - RepAPI export code review fixes                  
Rem    wfisher     11/03/98 - Don't extract privs/audits for dimensions
Rem    sbalaram    10/16/98 - MAIN -> 8.1.4                                    
Rem    wesmith     10/15/98 - Filter out RepAPI snapshots                      
Rem    nvishnub    07/30/98 - Filter datetime interval types.
Rem    lbarton     07/13/98 - lrid downgrade support
Rem    nvishnub    05/22/98 - Filter off bitmapped ts.
Rem    lbarton     04/16/98 - filter system events from pre8.1 triggers
Rem    thoang      12/16/97 - Modified views to exclude unused columns
Rem    gclaborn    01/12/98 - Filter off secondary objects with exu7obj
Rem    gclaborn    12/05/97 - Filter hidden columns out of views
Rem    gclaborn    12/02/97 - Filter out functional and extensible indexes
Rem    wesmith     11/20/97 - disable v7 export of snapshots and snapshot logs
Rem    jpearson    09/23/97 - add access by select_catalog_role
Rem    jpearson    08/12/97 - 524135 - ignore error 1921 if roles already exist
Rem    jpearson    08/01/97 - 519867 - remove blank lines
Rem    jstenois    07/15/97 - update to match bug fix in 7.3.4
Rem    jpearson    06/06/97 - v$option no longer contains procedure option
Rem    bmoy        05/29/97 - Remove 'set echo on'.
Rem    jpearson    05/02/97 - fix migration problems
Rem    jpearson    01/23/97 - fix exu7indic
Rem    syeung      01/06/97 - fix various bugs: 434588, 434601
Rem    syeung      12/26/96 - fix typo again
Rem    gdoherty    12/23/96 - fix typo in exu7ind
Rem    syeung      12/20/96 - fix bug 428299 and 428325
Rem    syeung      09/05/96 - fixed missing reverse in exu7ind; added 
Rem                           exu7indic etc for bitmap index incremental.
Rem    gdoherty    07/31/96 - shift ts# into file# to for TSR file#'s
Rem    ixhu        07/29/96 - allow v7 export/import to work against v8
Rem    ixhu        07/29/96 - Created
Rem

rem this role allows the grantee to perform full database exports
rem including incremental exports
rem The role creation will get an error 1921 if the role already exists.
rem The role may already have been created by sql.bsq, catexp.sql or 
rem by a previous execution of this script.
rem In those cases, the error can be ignored.
CREATE ROLE exp_full_database;
grant select any table to exp_full_database;
grant backup any table to exp_full_database;
grant execute any procedure to exp_full_database;
GRANT insert,update,delete
 ON sys.incexp
 TO exp_full_database;
GRANT insert,update,delete
 ON sys.incvid
 TO exp_full_database;
GRANT insert,update,delete
 ON sys.incfil
 TO exp_full_database;
grant exp_full_database to dba;

rem this role allows the grantee to perform full database imports
rem The role creation will get an error 1921 if the role already exists.
rem The role may already have been created by sql.bsq, catexp.sql or 
rem by a previous execution of this script.
rem In those cases, the error can be ignored.
CREATE ROLE imp_full_database;
grant become user to imp_full_database;
grant create any cluster to imp_full_database;
grant create any index to imp_full_database;
grant create any table to imp_full_database;
grant create any procedure to imp_full_database;
grant create any sequence to imp_full_database;
grant create any snapshot to imp_full_database;
grant create any synonym to imp_full_database;
grant create any trigger to imp_full_database;
grant create any view to imp_full_database;
grant create profile to imp_full_database;
grant create public database link to imp_full_database;
grant create database link to imp_full_database;
grant create public synonym to imp_full_database;
grant create rollback segment to imp_full_database;
grant create role to imp_full_database;
grant create tablespace to imp_full_database;
grant create user to imp_full_database;
grant audit any to imp_full_database;
grant comment any table to imp_full_database;
grant alter any table to imp_full_database;
grant select any table to imp_full_database;
grant execute any procedure to imp_full_database;
grant insert any table to imp_full_database;

rem for import of incremental export files
grant drop any cluster to imp_full_database;
grant drop any index to imp_full_database;
grant drop any table to imp_full_database;
grant drop any procedure to imp_full_database;
grant drop any sequence to imp_full_database;
grant drop any snapshot to imp_full_database;
grant drop any synonym to imp_full_database;
grant drop any trigger to imp_full_database;
grant drop any view to imp_full_database;
grant drop profile to imp_full_database;
grant drop public database link to imp_full_database;
grant drop public synonym to imp_full_database;
grant drop rollback segment to imp_full_database;
grant drop any role to imp_full_database;
grant drop tablespace to imp_full_database;
grant drop user to imp_full_database;

grant imp_full_database to dba;

rem grant roles access to the dictionary
grant select_catalog_role  to exp_full_database;
grant select_catalog_role  to imp_full_database;
grant execute_catalog_role to exp_full_database;
grant execute_catalog_role to imp_full_database;

REM **********  I M P O R T A N T  **********  I M P O R T A N T  **********
rem View exu7obj selects all rows from sys.obj$ EXCEPT secondary
rem objects as created by Domain Indexes. Secondary objects should not be
rem exported under any circumstances in a V7 export. See discussion in catexp.
rem Use sys.exu7obj in lieu of obj$.
REM **********  I M P O R T A N T  **********  I M P O R T A N T  **********

CREATE OR REPLACE view exu7obj AS
	SELECT * from sys.obj$
	WHERE bitand(flags, 16) != 16
/
grant select on exu7obj to select_catalog_role
/

Rem
Rem  ***************************************************
Rem  Section 1: Views required by BOTH export and import
Rem  ***************************************************
Rem 
rem block size
CREATE OR REPLACE view exu7bsz(blocksize) AS
       SELECT ts$.blocksize
       FROM   sys.ts$ ts$
/
grant select on exu7bsz to public;

rem all users
CREATE OR REPLACE view exu7usr 
                   (name, userid, passwd, defrole, datats, tempts, profile#, 
	            profname) AS 
       SELECT u.name, u.user#, DECODE(u.password, 'N', '', u.password), 
              DECODE(u.defrole, 0, 'N', 1, 'A', 2, 'L', 3, 'E', 'X'), 
	      ts1.name, ts2.name, u.resource$, p.name
       FROM sys.user$ u, sys.ts$ ts1, sys.ts$ ts2, sys.profname$ p
       WHERE u.datats# = ts1.ts# and u.tempts# = ts2.ts# and u.type# = 1 and
             u.resource$ = p.profile#
/
grant select on exu7usr to select_catalog_role;

CREATE OR REPLACE view exu7usru AS			     /* current user */
       SELECT * from exu7usr WHERE userid = UID
/
grant select on exu7usru to public;

rem check if user has priv to do a full db export
CREATE OR REPLACE view exu7ful(role) as
select u.name
from x$kzsro, user$ u
where kzsrorol!=uid and kzsrorol!=1 and u.user#=kzsrorol
/
grant select on sys.exu7ful to public;


Rem
Rem  ****************************************
Rem  Section 2: Views required by import ONLY
Rem  ****************************************
Rem 
REM Get Unlimited Extent Compatibility Information
CREATE or REPLACE view imp7uec (release) AS
		SELECT release 
		FROM v$compatibility
		WHERE type_id = 'UNLMTEXT'
/
grant select on imp7uec to public
/
Rem
Rem  ****************************************
Rem  Section 3: Views required by export ONLY
Rem  ****************************************
Rem 
rem all tables
CREATE OR REPLACE view exu7tab 
                   (objid, name, owner, ownerid, tablespace, fileno, blockno,
		    audit$, comment$, clusterflag, mtime, modified, pctfree$,
                    pctused$, initrans, maxtrans, parallel, cache) AS
       SELECT o$.obj#,o$.name, u$.name, o$.owner#, ts$.name,
              t$.ts# * 4096 + t$.file#, 
	      t$.block#, t$.audit$, c$.comment$, NVL(t$.bobj#, 0), o$.mtime,
	      decode(bitand(t$.flags,1),1,1,0), mod(t$.pctfree$, 100),
              t$.pctused$, t$.initrans, t$.maxtrans,
              NVL(t$.degree,1),
              decode(bitand(t$.flags,8), 8, 65536, 0)
       FROM sys.tab$ t$, sys.exu7obj o$, sys.ts$ ts$, sys.user$ u$, sys.com$ c$
       WHERE  t$.obj# = o$.obj# and t$.ts# = ts$.ts# and 
              u$.user# = o$.owner# and o$.obj# = c$.obj#(+) 
	      and c$.col#(+) is null 
              and (t$.property = 0 or bitand(t$.property,1024+536870912) != 0)
              and t$.cols <= 254
              and bitand(t$.property, 512) = 0     /* skip IOT overflow segs */
                                  /* skip tables with columns of type UROWID */
              and NOT EXISTS (SELECT * FROM sys.col$ c$
                              WHERE c$.obj# = o$.obj# AND
                                    (c$.type# = 208 OR
                                    (c$.type# >= 178 AND c$.type# <= 183)))

/
grant select on exu7tab to select_catalog_role;

rem tables for incremental export: modified, altered or new
CREATE OR REPLACE view exu7tabi AS 
       SELECT t.* from exu7tab t,incexp i, incvid v
       WHERE t.name  = i.name(+) AND t.ownerid = i.owner#(+) AND
             NVL(i.type#,2) = 2 AND  
             (bitand(t.modified,1) = 1 OR t.mtime > i.itime OR 
              NVL(i.expid,9999) > v.expid)
/
grant select on exu7tabi to select_catalog_role;
	     
rem tables for cumulative export: modified, last export was inc, altered or new
CREATE OR REPLACE view exu7tabc AS 
       SELECT t.* from exu7tab t,incexp i, incvid v
       WHERE  t.name  = i.name(+) AND t.ownerid = i.owner#(+) AND 
   	      NVL(i.type#,2) = 2 AND 
              (bitand(t.modified,1) = 1 OR i.itime > NVL(i.ctime,
                                            TO_DATE('01-01-1900','DD-MM-YYYY'))
               OR t.mtime > i.itime OR NVL(i.expid,9999) > v.expid)
/
grant select on exu7tabc to select_catalog_role;

rem current user's tables 
CREATE OR REPLACE view exu7tabu AS
       SELECT * from exu7tab WHERE ownerid = uid
/
grant select on exu7tabu to public;

rem not null constraints on columns
CREATE OR REPLACE view exu7colnn (tobjid, colid, conname, isnull, enabled) AS
      SELECT cc$.obj#, cc$.col#, 
              DECODE(SUBSTR(con$.name,1,5), 'SYS_C', '', NVL(con$.name, '')),
	      1, NVL(cd$.enabled, 0)
      FROM  sys.con$ con$, sys.cdef$ cd$, sys.ccol$ cc$
      WHERE cc$.con# = cd$.con# and
            cd$.con# = con$.con# and cd$.type# =7
/
grant select on exu7colnn to select_catalog_role;

CREATE OR REPLACE view exu7col_temp
                   (tobjid, towner, townerid, tname, name, length, precision, 
		    scale, type, isnull, conname, colid, segcolid,
		    comment$, --default$, 
	            dfltlen, enabled) AS
       SELECT o$.obj#, u$.name, o$.owner#, o$.name, c$.name, c$.length, 
              c$.precision#, c$.scale, 
              /* make long varchars or any nchar an invalid data type (0) */
              DECODE( c$.type#,
               /* char*/     1, decode(NVL(c$.charsetform,1),
                                         2,0, /* nchar */
                                       decode( least( c$.length, 2001),
                                               2001, 0, /* too long */
                                               c$.type#
                                             )
                                       ),
               /* varchar*/ 96, decode(NVL(c$.charsetform,1),
                                         2,0, /* nchar */
                                       decode( least( c$.length, 2001),
                                               2001, 0, /* too long */
                                               c$.type#
                                             )
                                       ),
                      c$.type# ),
              NVL(cn.isnull,0), 
              cn.conname, c$.col#, c$.segcol#,
	      com$.comment$,-- c$.default$, 
	      NVL(c$.deflength, 0), cn.enabled
       FROM sys.col$ c$, sys.exu7obj o$, sys.user$ u$, sys.com$ com$,
		sys.exu7colnn cn
       WHERE c$.obj# = o$.obj# and o$.owner# = u$.user# and 
	     c$.obj# = com$.obj#(+) and c$.col# = com$.col#(+) and
	     c$.obj# = cn.tobjid and c$.col# = cn.colid
  union all
       SELECT o$.obj#, u$.name, o$.owner#, o$.name, c$.name, c$.length, 
              c$.precision#, c$.scale, 
              /* make long varchars or any nchar an invalid data type (0) */
              DECODE( c$.type#,
               /* char*/     1, decode(NVL(c$.charsetform,1),
                                         2,0, /* nchar */
                                       decode( least( c$.length, 2001),
                                               2001, 0, /* too long */
                                               c$.type#
                                             )
                                       ),
               /* varchar*/ 96, decode(NVL(c$.charsetform,1),
                                         2,0, /* nchar */
                                       decode( least( c$.length, 2001),
                                               2001, 0, /* too long */
                                               c$.type#
                                             )
                                       ),
                      c$.type# ),
              0,
              null, c$.col#, c$.segcol#, com$.comment$,-- c$.default$, 
	      NVL(c$.deflength, 0), to_number(null)
       FROM sys.col$ c$, sys.exu7obj o$, sys.user$ u$, sys.com$ com$
       WHERE c$.obj# = o$.obj# and o$.owner# = u$.user# and 
	     c$.obj# = com$.obj#(+) and c$.col# = com$.col#(+)
             and bitand(c$.property,32768) != 32768     /* not unused column */
             and not exists 
              (select null from sys.exu7colnn cn
	         where c$.obj# = cn.tobjid and c$.col# = cn.colid)
/
grant select on exu7col_temp to select_catalog_role;

create or replace view exu7col
   (tobjid, towner, townerid, tname, name, length, precision,
    scale, type, isnull, conname, colid, segcolid, comment$, default$,
    dfltlen, enabled) AS
 select tobjid, towner, townerid, v$.tname, v$.name, v$.length, v$.precision,
                    v$.scale, type, isnull, conname, colid, segcolid,
		    comment$, default$,
                    dfltlen, enabled
   FROM EXU7col_temp v$, sys.col$ c$
    where c$.obj# = v$.tobjid and c$.col# = v$.colid and
          bitand(c$.property, 32) != 32	/* Not a hidden column */

/
grant select on exu7col to select_catalog_role;

CREATE OR REPLACE view exu7colu AS                 /* current user's columns */
       SELECT * from exu7col WHERE townerid = uid
/
grant select on exu7colu to public;

rem all columns for index
CREATE OR REPLACE view exu7ico 
                   (tobjid, towner, townerid, tname, name, length, precision,
		    scale, type, isnull, conname, colid, comment$, default$, 
		    dfltlen, enabled) AS
       SELECT o$.obj#, u$.name, o$.owner#, o$.name, c$.name, 0, 0, 0, 0, 0, '',
              i$.pos#, NULL, NULL, 0, 0
       FROM sys.col$ c$, sys.icol$ i$, sys.exu7obj o$, sys.user$ u$
       WHERE c$.obj# = i$.bo# and c$.col# = i$.col# and 
	     i$.obj# = o$.obj# and o$.owner# = u$.user#
/
grant select on exu7ico to select_catalog_role;

CREATE OR REPLACE view exu7icou AS		   /* current user's columns */
       SELECT * from exu7ico WHERE townerid = uid
/
grant select on exu7icou to public;

rem all users' default roles
CREATE OR REPLACE view exu7dfr (name, userid, role, roleid) AS
       SELECT u$.name, u$.user#, u1$.name, u1$.user#
       FROM sys.user$ u$, sys.user$ u1$, sys.defrole$ d$
       WHERE u$.user# = d$.user# and u1$.user# = d$.role#
/
rem all roles
CREATE OR REPLACE view exu7rol (role, password) AS    /* enumerate all roles */
       SELECT name, password
       FROM sys.user$ 
       WHERE type# = 0 and name not in 
            ('CONNECT', 'RESOURCE', 'DBA', 'PUBLIC', '_NEXT_USER', 
	     'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE')
/
grant select on exu7rol to select_catalog_role;


rem all role grants
CREATE OR REPLACE view exu7rlg
                   (grantee, granteeid, role, roleid, admin, sequence) AS
	SELECT u1$.name, u1$.user#, u2$.name, u2$.user#, 
	       NVL(g$.option$, 0), g$.sequence#
   	FROM sys.user$ u1$, sys.user$ u2$, sys.sysauth$ g$ 
	WHERE u1$.user# = g$.grantee# AND u2$.user# = g$.privilege# AND 
	      g$.privilege# > 0
/
grant select on exu7rlg to select_catalog_role;

rem all system privs, type is 1 for user, 0 for role
CREATE OR REPLACE view exu7spv (grantee, granteeid, priv, wgo, sequence) AS
       SELECT u1$.name, u1$.user#, m$.name, NVL(a$.option$,0), a$.sequence#
       FROM sys.sysauth$ a$, sys.system_privilege_map m$, sys.user$ u1$
       WHERE a$.grantee# = u1$.user# and a$.privilege# = m$.privilege AND 
	     u1$.name not in 
	     ('CONNECT', 'RESOURCE', 'DBA', 'PUBLIC', '_NEXT_USER', 
	     'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE') AND
             m$.privilege not in (-177, -178, -180, -181, -182, -183, -184, 
                                  -186, -188, -189, -190, -191, -192) AND
             m$.privilege > -200
/
grant select on exu7spv to select_catalog_role;
rem all grants
CREATE OR REPLACE view exu7grn (objid, grantor, grantorid, grantee, priv, wgo,
                    creatorid, sequence) AS
       SELECT t$.obj#, ur$.name, t$.grantor#, ue$.name, 
              m$.name, mod(NVL(t$.option$,0),2), o$.owner#, t$.sequence#
       FROM sys.objauth$ t$, sys.exu7obj o$, sys.user$ ur$,
            sys.table_privilege_map m$, sys.user$ ue$
       WHERE o$.obj# = t$.obj# AND t$.privilege# = m$.privilege AND
             t$.col# IS NULL AND t$.grantor# = ur$.user# AND
             t$.grantee# = ue$.user#
/
grant select on exu7grn to select_catalog_role;


rem just SYS's grants
CREATE OR REPLACE view exu7grs (objid, name) AS
       SELECT t$.obj#, o$.name
       FROM sys.objauth$ t$, sys.exu7obj o$
       WHERE o$.obj# = t$.obj# 
	AND t$.col# is null
	AND t$.grantor# = 0
/
grant select on exu7grs to select_catalog_role;

rem first level grants
CREATE OR REPLACE view exu7grnu AS
       SELECT * from exu7grn WHERE grantorid = UID AND creatorid = UID
/
grant select on exu7grnu to public;

rem all column grants
CREATE OR REPLACE view exu7cgr 
                   (objid, grantor, grantorid, grantee, creatorid, cname, 
	            priv, sequence, wgo) AS
       SELECT c$.obj#, ur$.name, c$.grantor#, ue$.name, o$.owner#, cl$.name,
              m$.name, c$.sequence#, mod(NVL(c$.option$,0),2)
       FROM sys.objauth$ c$, sys.exu7obj o$, sys.user$ ur$, sys.user$ ue$,
            sys.table_privilege_map m$, sys.col$ cl$
       WHERE c$.grantor# = ur$.user# AND c$.grantee# = ue$.user# AND
             c$.obj# = o$.obj# AND c$.privilege# = m$.privilege AND 
             c$.obj# = cl$.obj# AND c$.col# = cl$.col#
/
grant select on exu7cgr to select_catalog_role;

rem first level grants
CREATE OR REPLACE view exu7cgru AS
       SELECT * from exu7cgr WHERE grantorid = UID AND creatorid = UID
/
grant select on exu7cgru to public;

rem all indexes
rem add spare8 for bitmap index
CREATE OR REPLACE view exu7ind 
                   (iobjid, iname, iowner, iownerid, ispace, ifileno, iblockno,
		    btname, btobjid, btowner, btownerid, unique$,
		    cluster$, pctfree$, initrans, maxtrans, blevel, bitmap,
		    reverse) AS
       SELECT i$.obj#, i$.name, ui$.name, i$.owner#, ts$.name,
              ind$.ts# * 4096 + ind$.file#,
	      ind$.block#, t$.name, t$.obj#, ut$.name, t$.owner#,
              decode(bitand(decode(bitand(ind$.property,1),1,1,0),
                            decode(t$.type#,3,1,0)), 
                            1, 0, decode(bitand(ind$.property,1),1,1,0)),
              decode(t$.type#,3,1,0),
              ind$.pctfree$, ind$.initrans, ind$.maxtrans,
              NVL(ind$.blevel,-1), decode(ind$.type#,2,1,0),
              decode(bitand(ind$.property,4),4,1,0)
       FROM  sys.exu7obj t$, sys.exu7obj i$, sys.ind$ ind$,
	     sys.user$ ui$, sys.user$ ut$, sys.ts$ ts$
       WHERE ind$.bo# = t$.obj# AND ind$.obj# = i$.obj# AND
	     ts$.ts# = ind$.ts# AND i$.owner# = ui$.user# AND
             t$.owner# = ut$.user# AND
             bitand(ind$.property, 16) != 16 AND /* skip functional index */
             ind$.type# != 9 AND                 /* skip extensible index */
             (bitand(ind$.property,1)=0 OR 
	     NOT EXISTS (SELECT * from sys.con$ c$
			 WHERE c$.owner# = i$.owner#
                         AND   c$.name = i$.name))
/
grant select on exu7ind to select_catalog_role;

rem current user indexes
CREATE OR REPLACE view exu7indu AS
       SELECT * from exu7ind WHERE iownerid = UID and btownerid = UID
/
grant select on exu7indu to public;

rem dependency order
CREATE OR REPLACE view exu7ord (dlevel, obj#) AS
       SELECT MAX(LEVEL), d.d_obj# 
       FROM sys.dependency$ d
       WHERE
         EXISTS (select v.obj# from sys.view$ v where v.obj# = d.d_obj#)
       START WITH
         EXISTS (select v.obj# from sys.view$ v where v.obj# = d.d_obj#)
       CONNECT BY PRIOR d.d_obj# = d.p_obj#
       GROUP BY d.d_obj#, d.d_owner#
/
grant select on exu7ord to public;

rem current user's dependency order
CREATE OR REPLACE view exu7ordu (dlevel, obj#) AS
       SELECT MAX(LEVEL), d.d_obj#
       FROM sys.dependency$ d
       WHERE 
         d.d_owner# = uid AND
         EXISTS (select v.obj# from sys.view$ v where v.obj# = d.d_obj#)
       START WITH
         EXISTS (select v.obj# from sys.view$ v where v.obj# = d.d_obj#)
       CONNECT BY PRIOR d.d_obj# = d.p_obj#
       GROUP BY d.d_obj#, d.d_owner#
/
grant select on exu7ordu to public;

rem all views 
CREATE OR REPLACE view exu7vew (vobjid,vname, vlen, vtext, vowner, vownerid,
		    vaudit, vcomment, vcname, vlevel) AS
       SELECT
	o$.obj#, o$.name, v$.textlength, v$.text, u$.name, o$.owner#, 
  	      v$.audit$, com$.comment$, 
	      DECODE(SUBSTR(c$.name,1,5), 'SYS_C', '', NVL(c$.name, '')),
	      d$.dlevel
       FROM sys.exu7obj o$, sys.view$ v$, sys.user$ u$, sys.cdef$ cd$,
            sys.con$ c$, sys.com$ com$, exu7ord d$
       WHERE v$.obj# = o$.obj# AND o$.owner# = u$.user# AND
	     o$.obj# = cd$.obj#(+) AND cd$.con# = c$.con#(+) AND 
             o$.obj# = com$.obj#(+) AND com$.col#(+) IS NULL AND
	     o$.obj# = d$.obj#(+)
/
grant select on exu7vew to select_catalog_role;

rem views for incremental export: new or last export not valid
rem cannot use union as in exutabi because of long field
CREATE OR REPLACE view exu7vewi AS 
       SELECT vw.* from exu7vew vw, incexp i, incvid v
       WHERE i.name(+) = vw.vname AND i.owner#(+) = vw.vownerid
             AND v.expid < NVL(i.expid, 9999) AND NVL(i.type#, 4) = 4
/
grant select on exu7vewi to select_catalog_role;
	     
rem views for cumulative export: new, last export was inc or not valid
CREATE OR REPLACE view exu7vewc AS 
       SELECT vw.* from exu7vew vw, incexp i, incvid v
       WHERE vw.vname = i.name(+) AND vw.vownerid = i.owner#(+) AND 
             NVL(i.type#,4) = 4 AND
             (NVL(i.ctime,TO_DATE('01-01-1900','DD-MM-YYYY')) < i.itime OR 
              v.expid < NVL(i.expid, 9999))
/
grant select on exu7vewc to select_catalog_role;

rem current user's view
CREATE OR REPLACE view exu7vewu (vobjid,vname, vlen, vtext, vowner, vownerid,
		    vaudit, vcomment, vcname, vlevel) AS
       SELECT
	o$.obj#, o$.name, v$.textlength, v$.text, u$.name, o$.owner#, 
  	      v$.audit$, com$.comment$, 
	      DECODE(SUBSTR(c$.name,1,5), 'SYS_C', '', NVL(c$.name, '')),
	      d$.dlevel
       FROM sys.exu7obj o$, sys.view$ v$, sys.user$ u$, sys.cdef$ cd$,
            sys.con$ c$, sys.com$ com$, exu7ordu d$
       WHERE v$.obj# = o$.obj# AND o$.owner# = u$.user# AND
	     o$.obj# = cd$.obj#(+) AND cd$.con# = c$.con#(+) AND 
             o$.obj# = com$.obj#(+) AND com$.col#(+) IS NULL AND
	     o$.obj# = d$.obj#(+) AND u$.user# = uid
/
grant select on exu7vewu to public;

rem all synonyms
CREATE OR REPLACE view exu7syn (synnam, syntab, tabown, tabnode,
		        public$, synown, synownid, syntime) AS
       SELECT o$.name, s$.name, s$.owner, s$.node,
  	      DECODE(o$.owner#, 1, 1, 0),
   	      uo$.name, o$.owner#, TO_CHAR(o$.ctime, 'YYMMDDHH24MISS')
       FROM sys.exu7obj o$, sys.syn$ s$, sys.user$ us$, sys.user$ uo$
       WHERE s$.obj# = o$.obj# AND o$.owner# = uo$.user# AND
	     s$.owner = us$.name(+)
/
grant select on exu7syn to select_catalog_role;

rem synonyms for incremental export: new or last export not valid
CREATE OR REPLACE view exu7syni AS 
       SELECT s.* from exu7syn s, incexp i, incvid v
       WHERE s.synnam = i.name(+) AND s.synownid = i.owner#(+) AND 
             NVL(i.type#,5) = 5 AND NVL(i.expid,9999) > v.expid
/
grant select on exu7syni to select_catalog_role;

	     
rem synonyms for cumulative export: new, last export was inc or not valid
CREATE OR REPLACE view exu7sync AS 
       SELECT s.* from exu7syn s, incexp i, incvid v
       WHERE  s.synnam  = i.name(+) AND s.synownid = i.owner#(+) AND 
              NVL(i.type#,5) = 5 AND
	      (NVL(i.ctime,TO_DATE('01-01-1900','DD-MM-YYYY')) < i.itime OR 
               NVL(i.expid,9999) > v.expid)
/
grant select on exu7sync to select_catalog_role;


rem user's synnonyms
CREATE OR REPLACE view exu7synu AS
       SELECT * from exu7syn WHERE synownid = UID
/
grant select on exu7synu to public;

rem clustered tables' columns
CREATE OR REPLACE view exu7cco
                   (tname, towner, townerid, cluster$, tcolnam, seq) AS
       SELECT t$.name, u$.name, t$.owner#, c$.name, tc$.name, cc$.col#
       FROM sys.exu7obj t$, sys.tab$ tab$, sys.exu7obj c$,
	    sys.col$ tc$, sys.col$ cc$, sys.user$ u$
       WHERE t$.type# = 2 AND t$.obj# = tab$.obj# AND
  	     tab$.bobj# = cc$.obj# AND tab$.obj# = tc$.obj# AND 
             tab$.bobj# = c$.obj# AND 
             cc$.segcol# = tc$.segcol# AND t$.owner# = u$.user#
/
grant select on exu7cco to select_catalog_role;

rem current user's clustered tables' columns
CREATE OR REPLACE view exu7ccou AS
       SELECT * from exu7cco WHERE townerid = UID
/
grant select on exu7ccou to public;

rem all clusters
CREATE OR REPLACE view exu7clu 
                   (objid, owner, ownerid, name, tblspace, size$, fileno,
	            blockno, mtime, pctfree$, pctused$, initrans, maxtrans,
		    hashkeys, function, spare4, parallel, cache, 
		    functxt , funclen ) AS
       SELECT o$.obj#, u$.name, o$.owner#, o$.name, ts$.name, 
	      NVL(c$.size$, -1),
              c$.ts# * 4096 + c$.file#,
              c$.block#, o$.mtime, 
              mod(c$.pctfree$, 100), 
              c$.pctused$, c$.initrans, c$.maxtrans, NVL(c$.hashkeys, 0), 
	      NVL(c$.func, 1), NVL(c$.avgchn,-1), NVL(c$.degree,0),
              decode(bitand(c$.flags,8), 8, 65536, 0),
	      cd$.condition, cd$.condlength
       FROM sys.exu7obj o$, sys.clu$ c$, sys.ts$ ts$, sys.user$ u$,
	    sys.cdef$ cd$
       WHERE o$.obj# = c$.obj# AND c$.ts# = ts$.ts# AND o$.owner# = u$.user#
	     AND cd$.obj#(+) = c$.obj# 
/
grant select on exu7clu to select_catalog_role;

rem clusters for incremental export: new or last export invalid
rem altered cluster is now exported because its tables are also exported
CREATE OR REPLACE view exu7clui AS 
       SELECT c.* from exu7clu c,incexp i, incvid v
       WHERE c.name  = i.name(+) AND c.ownerid = i.owner#(+) AND
	    (c.mtime > i.itime OR NVL(i.expid,9999) > v.expid)
/
grant select on exu7clui to select_catalog_role;

	     
rem clusters for cumulative export: last export was inc or new
rem altered cluster is now exported because its tables are also exported
CREATE OR REPLACE view exu7cluc AS 
       SELECT c.* from exu7clu c,incexp i, incvid v
       WHERE c.name = i.name(+) AND c.ownerid = i.owner#(+) AND 
             NVL(i.type#,3) = 3 AND
	      (i.itime > NVL(i.ctime,TO_DATE('01-01-1900','DD-MM-YYYY'))
		OR c.mtime > i.itime OR NVL(i.expid,9999) > v.expid)
/
grant select on exu7cluc to select_catalog_role;


rem current user's clusters
CREATE OR REPLACE view exu7cluu AS
       SELECT * from exu7clu WHERE ownerid = UID
/
grant select on exu7cluu to public;

rem all storage parameters
CREATE OR REPLACE view exu7sto (ownerid, fileno, blockno, iniext, sext, minext,
                    maxext, pctinc, blocks, lists, groups, extents) AS
       SELECT user#,
                ts# * 4096 + file#, block#, iniexts, extsize, minexts, maxexts, 
		extpct, blocks, decode(lists, NULL, 1, 65535, 1, lists),
	      decode(groups, NULL, 1, 65535, 1, groups), extents
       FROM sys.seg$
/ 
grant select on exu7sto to select_catalog_role;

rem storage parameters for current user's segments
CREATE OR REPLACE view exu7stou AS
       SELECT * from exu7sto WHERE ownerid = UID
/
grant select on exu7stou to public;

rem find out correct size of second extent using uet$
CREATE OR REPLACE view exu7tne (fileno, blockno, length) AS
	SELECT s.ts# * 4096 + s.file#, u.segblock#, u.length
	FROM uet$ u, seg$ s 
        WHERE u.ext#=1 and s.file#=u.segfile# and
              s.block#=u.segblock# and
              s.ts#=u.ts#
/
grant select on exu7tne to public;

rem all tablespaces
CREATE OR REPLACE view exu7tbs 
                   (id, owner, name, isonline, content, iniext, sext, pctinc,
		    minext, maxext) AS
       SELECT ts$.ts#, 'SYSTEM', ts$.name, 
	      DECODE(ts$.online$, 1, 'ONLINE', 4, 'ONLINE', 'OFFLINE'), 
	      DECODE(ts$.contents$, 0, 'PERMANENT', 1, 'TEMPORARY'),
	      ts$.dflinit,
   	      ts$.dflincr, ts$.dflextpct, ts$.dflminext, ts$.dflmaxext
       FROM sys.ts$ ts$ 
       WHERE ts$.online$ in (1, 2, 4) and ts$.ts# != 0 and ts$.bitmapped = 0
/
grant select on exu7tbs to select_catalog_role;

rem tablespace quotas
CREATE OR REPLACE view exu7tsq(tsname, tsid, uname, userid, maxblocks) AS
       SELECT t$.name, q$.ts#, u$.name, u$.user#, q$.maxblocks
       FROM  sys.ts$ t$, sys.tsq$ q$, sys.user$ u$
       WHERE  q$.user# = u$.user# AND q$.ts# = t$.ts# AND q$.maxblocks != 0
	    		AND t$.online$ in (1, 2, 4)
/
grant select on exu7tsq to select_catalog_role;

rem all files
CREATE OR REPLACE view exu7fil(fname, fsize, tsid) AS
       SELECT v$.name, f$.blocks, f$.ts#
       FROM   sys.file$ f$, sys.v$dbfile v$
       WHERE  f$.file# = v$.file#
/
grant select on exu7fil to select_catalog_role;


rem all database links
CREATE OR REPLACE view exu7lnk 
                   (owner, ownerid, name, user$, passwd, host, public$) AS
       SELECT DECODE(l$.owner#, 1, 'SYSTEM', u$.name), l$.owner#, l$.name, 
              l$.userid, l$.password, l$.host, DECODE(l$.owner#, 1, 1, 0)
       FROM sys.user$ u$, sys.link$ l$
       WHERE u$.user# = l$.owner#
/
GRANT SELECT ON sys.exu7lnk TO EXP_FULL_DATABASE;

CREATE OR REPLACE view exu7lnku AS	    /* current user's database links */
       SELECT * from exu7lnk WHERE ownerid = UID
/
grant select on exu7lnku to public;

rem all rollback segments
CREATE OR REPLACE view exu7rsg 
                   (owner, name, space$, fileno , blockno, minext, public$) AS 
       SELECT 'SYSTEM', r$.name, ts$.name,
              r$.ts# * 4096 + r$.file#,
              r$.block#, s$.minexts,
   	      DECODE(r$.user#, 1, 1, 0)
       FROM sys.ts$ ts$, sys.undo$ r$, sys.seg$ s$
       WHERE r$.status$ != 1 AND r$.file# = s$.file# AND r$.block# = s$.block#
             AND s$.ts# = ts$.ts# and r$.ts# = s$.ts#
             and r$.us# != 0
/
grant select on exu7rsg to select_catalog_role;

rem info on deleted objects EXCEPT snapshots, snapshot logs
CREATE OR REPLACE view exu7del (owner, name, type, type#) AS 
       SELECT u$.name, i$.name, DECODE(i$.type#, 2, 'TABLE', 3,
              'CLUSTER', 4, 'VIEW', 5, 'SYNONYM', 6, 'SEQUENCE',
              7, 'PROCEDURE', 8, 'FUNCTION', 9, 'PACKAGE',
             -1, 'TRIGGER', -4, 'PACKAGE BODY'), i$.type#
       FROM sys.incexp i$, sys.user$ u$, sys.exu7obj o$
       WHERE i$.owner# = u$.user#
             AND i$.type# NOT IN (-2,-3)
             AND i$.owner# = o$.owner# (+) /* "+ 0" for sort-merge outer jn */
             AND i$.name   = o$.name (+)
             AND i$.type#  = DECODE(o$.type# (+), 12, -1, 11, -4, o$.type# (+))
             AND o$.owner# is NULL AND o$.linkname is NULL
/
grant select on exu7del to select_catalog_role;

rem info on sequence number
CREATE OR REPLACE view exu7seq 
                   (owner, ownerid, name, objid, curval, minval, maxval, 
		    incr, cache, cycle, order$, audt) AS
       SELECT u.name, u.user#, o.name, o.obj#, s.highwater, s.minvalue, 
	      s.maxvalue, s.increment$, s.cache, s.cycle#, s.order$, s.audit$
       FROM sys.exu7obj o, sys.user$ u, sys.seq$ s
       WHERE o.obj# = s.obj# AND o.owner# = u.user#
/
grant select on exu7seq to select_catalog_role;

CREATE OR REPLACE view exu7sequ AS 
       SELECT * from sys.exu7seq WHERE UID = ownerid
/
grant select on sys.exu7sequ to public;

rem contraints on table
CREATE OR REPLACE view exu7con 
                   (objid, owner, ownerid, tname, type, cname, cno, condition,
                    condlength, enabled) AS
       SELECT o.obj#, u.name, c.owner#, o.name, cd.type#, c.name,
              c.con#, cd.condition, cd.condlength, NVL(cd.enabled,0)
       FROM sys.exu7obj o, sys.user$ u, sys.con$ c, sys.cdef$ cd
       WHERE u.user# = c.owner# AND o.obj# = cd.obj# AND cd.con# = c.con#
/
grant select on exu7con to select_catalog_role;

CREATE OR REPLACE view exu7conu AS 
       SELECT * from sys.exu7con WHERE UID = ownerid
/
grant select on sys.exu7conu to public;

rem referential constraints
CREATE OR REPLACE view exu7ref 
                   (objid, owner, ownerid, tname, rowner, rtname, cname, cno,
	            rcno, action, enabled) AS
       SELECT o.obj#, u.name, c.owner#, o.name, ru.name, ro.name, 
              DECODE(SUBSTR(c.name, 1, 5), 'SYS_C', '', NVL(c.name, '')),
	      c.con#, cd.rcon#, NVL(cd.refact,0), NVL(cd.enabled,0)
       FROM sys.user$ u, sys.user$ ru, sys.exu7obj o, sys.exu7obj ro, 
            sys.con$ c, sys.cdef$ cd
       WHERE u.user# = c.owner# AND o.obj# = cd.obj# AND ro.obj# = cd.robj# AND
             cd.con# = c.con# AND cd.type# = 4 AND ru.user# = ro.owner#
/
grant select on exu7ref to select_catalog_role;

CREATE OR REPLACE view exu7refu 
 AS SELECT * from sys.exu7ref WHERE UID = ownerid
/
grant select on sys.exu7refu to public;

rem referential constraints for incremental and cumulative export
rem for tables just exported, i.expid will be greater than v.expid
rem as v.expid is incremented only at the end of the incremental export
rem but i.expid is incremented when the table is exported.
rem USED ONLY WHEN RECROD = YES
CREATE OR REPLACE view exu7refic AS
       SELECT * from sys.exu7ref 
       WHERE (ownerid, tname) in 
             (SELECT i.owner#, i.name 
              FROM sys.incexp i, sys.incvid v
              WHERE i.expid > v.expid AND i.type# = 2)
/
grant select on exu7refic to select_catalog_role;

rem referential constraints for incremental export
rem exutabi will return the correct table name because RECORD = NO
CREATE OR REPLACE view exu7refi AS
       SELECT * from sys.exu7ref
       WHERE (ownerid, tname) in (SELECT ownerid, name from sys.exu7tabi)
/
grant select on exu7refi to select_catalog_role;


rem referential constraints for cumulative export, assuming
rem exutabc will return the correct table name because RECORD = NO
CREATE OR REPLACE view exu7refc AS
       SELECT * from sys.exu7ref
       WHERE (ownerid, tname) in (SELECT ownerid, name from sys.exu7tabc)
/
grant select on exu7refc to select_catalog_role;


rem contraint column list
CREATE OR REPLACE view exu7ccl (ownerid, cno, colname, colno) AS
       SELECT o.owner#, cc.con#, c.name, cc.pos#
       FROM sys.exu7obj o, sys.col$ c, sys.ccol$ cc
       WHERE o.obj# = cc.obj# AND c.obj# = cc.obj# AND cc.col# = c.col#
/
grant select on exu7ccl to select_catalog_role;


CREATE OR REPLACE view exu7cclu AS
       SELECT * from sys.exu7ccl WHERE UID = ownerid
/
grant select on sys.exu7cclu to public
/
CREATE OR REPLACE view exu7cclo (ownerid, cno, colname, colno) AS
	SELECT a.ownerid, a.cno, a.colname, a.colno
	from sys.exu7ccl a, sys.con$ b , sys.cdef$ c
	WHERE b.owner#=UID
	AND   b.con# = c.con#
	AND   c.rcon# = a.cno
/
grant select on sys.exu7cclo to public
/
rem triggers
CREATE OR REPLACE view exu7tgr 
                   (ownerid, owner, baseobject, baseobjowner,
                    definition, whenclause, 
	            actionsize, action, enabled, name, basename) AS
        SELECT o.owner#, u.name, t.baseobject, u2.name,
               t.definition, t.whenclause, 
	       t.actionsize, t.action#, t.enabled, o.name, o2.name
        FROM sys.exu7obj o, sys.trigger$ t, sys.user$ u,
	     sys.exu7obj o2, sys.user$ u2
        WHERE o.obj# = t.obj# AND u.user# = o.owner# AND
	      o2.obj# = t.baseobject and t.type# in (0,1,2,3)
              and o2.owner# = u2.user#
	      and (bitand(t.property,1) = t.property OR
                   bitand(t.property,128) = 128)
/
grant select on exu7tgr to select_catalog_role;

CREATE OR REPLACE view exu7tgru AS
        SELECT * from sys.exu7tgr WHERE UID = ownerid
/
grant select on sys.exu7tgru to public
/
rem triggers for incremental and cumulative export for table just 
rem exported.  See comment on exu7refic.
CREATE OR REPLACE view exu7tgric as 
	SELECT * from sys.exu7tgr 
	WHERE (ownerid, basename) in
             (SELECT i.owner#, i.name
              from sys.incexp i, sys.incvid v
              WHERE i.expid > v.expid AND i.type# = 2)
/
grant select on exu7tgric to select_catalog_role;

rem triggers for incremental export: record=no
CREATE OR REPLACE view exu7tgri as 
       SELECT * from sys.exu7tgr
	WHERE (ownerid, basename) in (SELECT ownerid, name from sys.exu7tabi)
/
grant select on exu7tgri to select_catalog_role;

rem triggers for cumulative export: record=no
CREATE OR REPLACE view exu7tgrc as 
       SELECT * from sys.exu7tgr 
	WHERE (ownerid, basename) in (SELECT ownerid, name from sys.exu7tabc)
/
grant select on exu7tgrc to select_catalog_role;


CREATE OR REPLACE view exu7spr(ownerid, uname, id, name, time, typeid, type,
	 audt) AS
   SELECT o.owner#, u.name, o.obj#, o.name, 
	  TO_CHAR(o.mtime, 'YYYY-MM-DD:HH24:MI:SS'), o.type#,
          DECODE(o.type#, 7, 'PROCEDURE', 8, 'FUNCTION', 
	         9, 'PACKAGE', 11, 'PACKAGE BODY'), p.audit$
   FROM sys.exu7obj o, sys.user$ u, sys.procedure$ p
   WHERE o.owner# = u.user# AND o.type# in (7,8,9,11) 
	AND o.obj# = p.obj#
/
grant select on exu7spr to select_catalog_role;

CREATE OR REPLACE view exu7spu(ownerid, uname, id, name, time, typeid, type,
	audt) AS
   SELECT * from sys.exu7spr WHERE UID = ownerid
/
grant select on sys.exu7spu to public
/
rem stored procedures for incremental export: modified, altered or new
CREATE OR REPLACE view exu7spri AS
       SELECT s.* from exu7spr s,incexp i, incvid v
       WHERE s.name  = i.name(+) AND s.ownerid = i.owner#(+) AND
             NVL(i.type#,7) = 7 AND
             NVL(i.expid,9999) > v.expid
/
grant select on exu7spri to select_catalog_role;


rem stored procedures for incremental export: modified, altered or new
CREATE OR REPLACE view exu7sprc AS
       SELECT s.* from exu7spr s,incexp i, incvid v
       WHERE s.name  = i.name(+) AND s.ownerid = i.owner#(+) AND
             NVL(i.type#,7) = 7 AND
(NVL(i.ctime,TO_DATE('01-01-1900','DD-MM-YYYY')) < i.itime OR
               NVL(i.expid,9999) > v.expid)
/
grant select on exu7sprc to select_catalog_role;


CREATE OR REPLACE view exu7sps(obj#, line, source) AS
   SELECT obj#,line,source 
   FROM sys.source$ 
/
grant select on exu7sps to select_catalog_role;

CREATE OR REPLACE view exu7spsu(obj#, line, source) AS
   SELECT s.obj#, s.line, s.source
   FROM sys.source$ s, sys.exu7obj o
   WHERE s.obj# = o.obj# and o.owner# = UID
/
grant select on sys.exu7spsu to public
/
rem system auditing options
rem 
CREATE OR REPLACE view exu7aud (userid, name, action, success, failure) AS
	SELECT a.user#, u.name, m.name, NVL(a.success,0), NVL(a.failure,0)
	FROM sys.audit$ a, sys.user$ u, sys.stmt_audit_option_map m
	WHERE a.user# = u.user# AND a.option# = m.option# AND
              (m.option# < 177 OR m.option# > 193) AND
              m.option# not in (18, 34, 38, 39, 157, 158) AND
	      (m.option# < 200)
/
grant select on exu7aud to select_catalog_role;

rem profiles
CREATE OR REPLACE view exu7prf(profile#, name) AS
	SELECT profile#, name 
	FROM sys.profname$
	WHERE profile# != 0
/

grant select on exu7prf to select_catalog_role;

CREATE OR REPLACE view exu7prr(profile#, resname, limit) AS
	SELECT profile#, DECODE(resource#,
		0, 'COMPOSITE_LIMIT',
		1, 'SESSIONS_PER_USER',
		2, 'CPU_PER_SESSION',
		3, 'CPU_PER_CALL',
		4, 'LOGICAL_READS_PER_SESSION',
		5, 'LOGICAL_READS_PER_CALL',
		6, 'IDLE_TIME',
		7, 'CONNECT_TIME',
		8, 'PRIVATE_SGA', 'UNDEFINED'), limit#
	FROM sys.profile$
	WHERE resource# != 9 and type# = 0
/
grant select on exu7prr to select_catalog_role;


rem snapshots
CREATE OR REPLACE view exu7snap
( OWNER, OWNERID, NAME, TABLE_NAME, MASTER_VIEW, MASTER_OWNER, MASTER, 
  MASTER_LINK, CAN_USE_LOG, LAST_REFRESH, ERROR, TYPE, NEXT, START_WITH, QUERY,
  UPDATABLE, UPDATE_TRIG, UPDATE_LOG)
as
SELECT sowner, u.user#, vname, tname, mview, mowner, master, mlink,
       decode(can_use_log, null, 'NO', 'YES'), 
       snaptime, error#, 
       decode(auto_fast, 
              'C', 'COMPLETE', 
              'F', 'FAST', 
              '?', 'FORCE', 
              null, 'FORCE', 'ERROR'), 
       auto_fun, auto_date, query_txt, mod(trunc(flag/2),2), ustrg, uslog
from sys.snap$ s, sys.user$ u
WHERE u.name = s.sowner
AND   1 = 0                          /* v7 export of v8 snapshots disallowed */
/
grant select on exu7snap to select_catalog_role;

CREATE OR REPLACE view exu7snapu
( OWNER, OWNERID, NAME, TABLE_NAME, MASTER_VIEW, MASTER_OWNER, MASTER, 
  MASTER_LINK, CAN_USE_LOG, LAST_REFRESH, ERROR, TYPE, NEXT, START_WITH, QUERY,
  UPDATABLE, UPDATE_TRIG, UPDATE_LOG)
as
SELECT sowner, u.user#, vname, tname, mview, mowner, master, mlink,
       decode(can_use_log, null, 'NO', 'YES'), 
       snaptime, error#, 
       decode(auto_fast, 
              'C', 'COMPLETE', 
              'F', 'FAST', 
              '?', 'FORCE', 
              null, 'FORCE', 'ERROR'), 
       auto_fun, auto_date, query_txt, mod(trunc(flag/2),2), ustrg, uslog
from sys.snap$ s, sys.user$ u
WHERE u.name = s.sowner
AND   UID = u.user#
AND   1 = 0                          /* v7 export of v8 snapshots disallowed */
/
grant SELECT on sys.exu7snapu to public;

rem snapshots for incremental export: modified, altered or new
CREATE OR REPLACE view exu7snapi AS
        SELECT s.* from exu7snap s,incexp i, incvid v
       WHERE s.name  = i.name(+) AND s.ownerid = i.owner#(+) AND
             NVL(i.type#,-2) = -2 AND
             NVL(i.expid,9999) > v.expid
/
grant select on exu7snapi to select_catalog_role;

rem snapshots for cumulative export: new, last export was inc or not valid
CREATE OR REPLACE view exu7snapc AS
       SELECT s.* from exu7snap s, incexp i, incvid v
       WHERE  s.name  = i.name(+) AND s.ownerid = i.owner#(+) AND
              NVL(i.type#,-2) = -2 AND
              (NVL(i.ctime,TO_DATE('01-01-1900','DD-MM-YYYY')) < i.itime OR
               NVL(i.expid,9999) > v.expid)
/
grant select on exu7snapc to select_catalog_role;

rem snapshot logs
CREATE OR REPLACE view exu7snapl
( LOG_OWNER, LOG_OWNERID, MASTER, LOG_TABLE, LOG_TRIGGER)
as
SELECT m.mowner, u.user#, m.master, m.log, m.trig
from sys.mlog$ m, sys.user$ u
WHERE m.mowner = u.name
and   1 = 0                      /* v7 export of v8 snapshot logs disallowed */
/
grant select on exu7snapl to select_catalog_role;

CREATE OR REPLACE view exu7snaplu
( LOG_OWNER, LOG_OWNERID, MASTER, LOG_TABLE, LOG_TRIGGER)
as
SELECT m.mowner, u.user#, m.master, m.log, m.trig
from sys.mlog$ m,  sys.user$ u
WHERE  m.mowner = u.name
and    UID = u.user#
and    1 = 0                     /* v7 export of v8 snapshot logs disallowed */
/
grant SELECT on sys.exu7snaplu to public;

rem snapshot logs for incremental export: modified, altered or new
CREATE OR REPLACE view exu7snapli AS
        SELECT s.* from exu7snapl s,incexp i, incvid v
       WHERE s.master  = i.name(+) AND s.log_ownerid = i.owner#(+) AND
             NVL(i.type#,-3) = -3 AND
             NVL(i.expid,9999) > v.expid
/
grant select on exu7snapli to select_catalog_role;



rem snapshot logs for cumulative export: new, last export was inc or not valid
CREATE OR REPLACE view exu7snaplc AS
       SELECT s.* from exu7snapl s, incexp i, incvid v
       WHERE s.master  = i.name(+) AND s.log_ownerid = i.owner#(+) AND
              NVL(i.type#,-3) = -3 AND
              (NVL(i.ctime,TO_DATE('01-01-1900','DD-MM-YYYY')) < i.itime OR
               NVL(i.expid,9999) > v.expid)
/
grant select on exu7snaplc to select_catalog_role;

rem info on deleted snapshots -- they aren't in obj$
CREATE OR REPLACE view exu7delsnap (owner, name, type) as
       SELECT u$.name, i$.name, 'SNAPSHOT'
       from sys.incexp i$, sys.user$ u$
       WHERE i$.owner# = u$.user# and
	     i$.type# = -2 and
             (u$.name, i$.name)
             NOT IN (SELECT s$.sowner, s$.vname
 			from sys.snap$ s$
                        where s$.instsite = 0)
/
grant select on exu7delsnap to select_catalog_role;

rem info on deleted snapshot logs -- they aren't in obj$
CREATE OR REPLACE view exu7delsnapl (owner, name, type) as
       SELECT u$.name, i$.name, 'SNAPSHOT LOG'
       from sys.incexp i$, sys.user$ u$
       WHERE i$.owner# = u$.user# and
	     i$.type# = -3 and
             (u$.name, i$.name)
             NOT IN (SELECT m$.mowner, m$.master
 			from sys.mlog$ m$)
/
grant select on exu7delsnapl to select_catalog_role;


rem info on analyzed objects
CREATE OR REPLACE view exu7anal(id,rowcnt) as
	select obj#, NVL(rowcnt,-1) from sys.tab$
/
grant select on exu7anal to public
/

rem add a view to determine storage clause for unique constraint
rem need for it to be user level because two different users can have the
rem same index name 
CREATE OR REPLACE view exu7uscu 
(iobjid, iname, ifileno, iblockno, ibobjid, tspname, pctfree$, initrans, 
 maxtrans) as
	SELECT o$.obj#, o$.name,
               i$.ts# * 4096 + i$.file#,
               i$.block#, i$.bo#, t$.name, 
               i$.pctfree$, i$.initrans, i$.maxtrans
	from sys.exu7obj o$, sys.ind$ i$, sys.file$ f$, sys.ts$ t$
	where o$.obj# = i$.obj# and bitand(i$.property,1)=1 
        and f$.relfile#=i$.file# and f$.ts# = t$.ts#
/
grant select on sys.exu7uscu to public; 

rem referential constraints
CREATE OR REPLACE view exu7rif 
                   (objid, owner, ownerid, tname, rowner, rtname, cname, cno,
	            rcno, action, enabled, robjid) AS
       SELECT o.obj#, u.name, c.owner#, o.name, ru.name, ro.name, 
              DECODE(SUBSTR(c.name, 1, 5), 'SYS_C', '', NVL(c.name, '')),
	      c.con#, cd.rcon#, NVL(cd.refact,0), NVL(cd.enabled,0),
	      cd.robj#
       FROM sys.user$ u, sys.user$ ru, sys.exu7obj o, sys.exu7obj ro, 
            sys.con$ c, sys.cdef$ cd
       WHERE u.user# = c.owner# AND o.obj# = cd.obj# AND ro.obj# = cd.robj# AND
             cd.con# = c.con# AND cd.type# = 4 AND ru.user# = ro.owner#
/
grant select on exu7rif to select_catalog_role;

CREATE OR REPLACE view exu7erc
		(resource_name, unit_cost) as
		SELECT m.name, c.cost 
		FROM sys.resource_cost$ c, sys.resource_map m 
		WHERE c.resource# = m.resource# AND
		      m.type# = 0 AND c.resource# in (2, 4, 7, 8)
/
grant select on exu7erc to select_catalog_role;

REM
REM Job Queues
REM
CREATE OR REPLACE view exu7jbq
	        (job, ownerid, owner) as
		SELECT j$.job, u$.user#, j$.powner
		FROM sys.job$ j$, sys.user$ u$
		WHERE j$.powner = u$.name
/
grant select on exu7jbq to select_catalog_role;

CREATE OR REPLACE view exu7jbqu 
		(job, ownerid, owner) as
		SELECT * FROM sys.exu7jbq 
		WHERE uid = ownerid
/
grant select on exu7jbqu to public
/
REM
REM Refresh Groups
REM
CREATE OR REPLACE view exu7rgs 
		(refgroup, ownerid, owner) as
		SELECT r$.refgroup, u$.user#, r$.owner
		FROM sys.rgroup$ r$, sys.user$ u$
		WHERE r$.owner = u$.name
		AND   r$.instsite = 0     /* Do not include RepAPI refgroups */
/
grant select on exu7rgs to select_catalog_role;

CREATE OR REPLACE view exu7rgsu as
		SELECT * from sys.exu7rgs
		WHERE uid = ownerid
/
grant select on exu7rgsu to public
/
REM
REM Refresh Group Children
REM
CREATE OR REPLACE view exu7rgc
		(owner, ownerid, child, type, refgroup) as
		SELECT rc$.owner, u$.user#, rc$.name, rc$.type#, rc$.refgroup
		FROM sys.rgchild$ rc$, sys.user$ u$
		WHERE rc$.owner = u$.name
		AND   rc$.instsite = 0    /* Do not include RepAPI snapshots */
/
grant select on exu7rgc to select_catalog_role;

CREATE OR REPLACE view exu7rgcu as
		SELECT * from sys.exu7rgc
		WHERE uid = ownerid
/
grant select on exu7rgcu to public
/
REM
REM PoSTtables actions 
REM
/
CREATE OR REPLACE view exu7pst
		(owner, ownerid, tname, tobjid, callorder) as
		SELECT a$.owner, u$.user#, a$.name, o$.obj#, a$.callorder
		FROM sys.expact$ a$, sys.user$ u$, sys.exu7obj o$
		WHERE u$.name = a$.owner and o$.owner# = u$.user#
		      and o$.name = a$.name 
/
grant select on exu7pst to select_catalog_role;

CREATE OR REPLACE view exu7pstu
		(owner, ownerid, tname, tobjid, callorder) as
		SELECT * from sys.exu7pst
	        where ownerid = uid
/
grant select on exu7pstu to public
/

REM PoSTtables actions incremental/cumulative with record = Y
CREATE OR REPLACE view exu7pstic
		(owner, ownerid, tname, tobjid, callorder) as
		SELECT * from sys.exu7pst
		WHERE (ownerid, tname) in
	        (SELECT i.owner#, i.name
                 FROM sys.incexp i, sys.incvid v
                 WHERE i.expid > v.expid AND i.type# = 2)
/
grant select on exu7pstic to select_catalog_role;

REM PoSTtables actions for incremental export : record = N
CREATE OR REPLACE view exu7psti as
		SELECT * from sys.exu7pst
		WHERE (ownerid, tname) in 
		(SELECT ownerid, name from sys.exu7tabi)
/
grant select on exu7psti to select_catalog_role;

REM PoSTtables actions for cumulative  export : record = N
CREATE OR REPLACE view exu7pstc as
		SELECT * from sys.exu7pst
		WHERE (ownerid, tname) in 
		(SELECT ownerid, name from sys.exu7tabc)
/
grant select on exu7pstc to select_catalog_role;

REM Version Control
CREATE OR REPLACE view exu7ver (version) AS
	        SELECT TO_NUMBER(value$) from sys.props$
		WHERE name = 'EXPORT_VIEWS_VERSION'
/
grant select on exu7ver to public
/
REM Database Character Set
CREATE OR REPLACE view exu7cset (value) AS
                SELECT value$ from sys.props$
                WHERE name = 'NLS_CHARACTERSET'
/
grant select on exu7cset to public
/
REM Check for Procedural Option - as of 8.0.3 - procedural is not an option
CREATE OR REPLACE view exu7cpo (value) AS
		SELECT 1 
		FROM dual
/
grant select on exu7cpo to public
/
rem USED ONLY WHEN RECROD = YES
CREATE OR REPLACE view exu7indic AS
       SELECT * from sys.exu7ind
       WHERE (iownerid, btname) in
             ((SELECT i.owner#, i.name
              FROM sys.incexp i, sys.incvid v
              WHERE i.expid > v.expid AND i.type# = 2)
        UNION
                (SELECT r.ownerid,r.tname
                FROM sys.incexp ii, sys.incvid vv, sys.exu7ref r
                WHERE r.rtname=ii.name AND ii.expid > vv.expid 
                     AND ii.type# = 2))
/
grant select on exu7indic to select_catalog_role;

rem indexes   for incremental export
rem exutabi will return the correct table name because RECORD = NO
CREATE OR REPLACE view exu7indi AS
       SELECT * from sys.exu7ind
       WHERE (iownerid, btname) in
        ((SELECT ownerid, name from sys.exu7tabi)
        UNION
            (SELECT r.ownerid, r.tname
                FROM sys.exu7tabi ii ,sys.exu7ref r
                WHERE r.rtname= ii.name ))
/
grant select on exu7indi to select_catalog_role;


rem indexes   for cumulative export, assuming
rem exutabc will return the correct table name because RECORD = NO
CREATE OR REPLACE view exu7indc AS
       SELECT * from sys.exu7ind
       WHERE (iownerid, btname) in
               ((SELECT ownerid, name from sys.exu7tabc)
         UNION
            (SELECT r.ownerid,r.tname
                FROM sys.exu7tabc cc ,sys.exu7ref r
                WHERE r.rtname= cc.name ))
/
grant select on exu7indc to select_catalog_role;

