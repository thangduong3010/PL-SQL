Rem
Rem $Header: rdbms/admin/a1102000.sql /st_rdbms_11.2.0/7 2013/07/22 04:29:06 mthiyaga Exp $
Rem
Rem a1102000.sql
Rem
Rem Copyright (c) 2009, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      a1102000.sql - additional ANONYMOUS BLOCK dictionary upgrade
Rem                     making use of PL/SQL packages installed by
Rem                     catproc.sql.
Rem
Rem    DESCRIPTION
Rem      Additional upgrade script to be run during the upgrade of an
Rem      11.2.0 database to the new 11.2.0.x patch release.
Rem
Rem      This script is called from catupgrd.sql and a1101000.sql
Rem
Rem      Put any anonymous block related changes here.
Rem      Any dictionary create, alter, updates and deletes  
Rem      that must be performed before catalog.sql and catproc.sql go 
Rem      in c1102000.sql
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: upgrade from 11.2 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      07/19/13 - Backport
Rem                           mthiyaga_blr_backport_16924879_11.2.0.3.0 from
Rem                           st_rdbms_11.2.0
Rem    yujwang     06/20/12 - backport kmorfoni_lrg-5759823
Rem    mthiyaga    07/12/13 - Backport of fix for 16924879
Rem    nbhatt      05/26/11 - Backport nbhatt_bug-10637224 from main
Rem    yurxu       05/04/11 - Backport yurxu_bug-12391440 from main
Rem    yurxu       04/12/11 - Backport yurxu_bug-11922716 from main
Rem    huntran     02/08/11 - Backport huntran_bug-11678106 from main
Rem    huntran     02/01/11 - grant select privs for xstream table stats
Rem    huntran     01/30/11 - grant xstream view privileges
Rem    jawilson    05/04/10 - Change aq$_replay_info address format
Rem    pbelknap    03/23/10 - #8710750: add WRI$_SQLTEXT_REFCOUNT
Rem    ilistvin    12/05/09 - bug8811401: populate wrh_tablespace
Rem    shbose      11/05/09 - Bug 9068654: upgrade changes for 8764375
Rem    alui        10/28/09 - add alerts tables for wlm
Rem    cdilling    08/03/09 - Created
Rem

Rem *************************************************************************
Rem BEGIN a1102000.sql
Rem *************************************************************************

Rem =====================
Rem Begin XStream changes
Rem =====================
Rem Grant SELECT on dictionary views to XStream and GG apply and * users
DECLARE
  user_names_xs_and_gg       dbms_sql.varchar2s;
  select_privs_xs_and_gg     dbms_sql.varchar2s;
  user_names_gg              dbms_sql.varchar2s;
  i                          PLS_INTEGER;
BEGIN
  SELECT username, grant_select_privileges
  BULK COLLECT INTO user_names_xs_and_gg, select_privs_xs_and_gg
  FROM (SELECT username, grant_select_privileges FROM dba_goldengate_privileges
          WHERE privilege_type IN ('APPLY', '*')
        UNION
        SELECT username, grant_select_privileges
          FROM dba_xstream_administrator);

  SELECT username
  BULK COLLECT INTO user_names_gg
  FROM dba_goldengate_privileges;

  -- privs for both xs and gg
  FOR i IN 1 .. user_names_xs_and_gg.count
  LOOP
    -- Don't uppercase username during enquote_name
    IF (user_names_xs_and_gg(i) <> 'SYS' AND
        user_names_xs_and_gg(i) <> 'SYSTEM') THEN
      EXECUTE IMMEDIATE 'grant select on sys.gv_$xstream_table_stats to ' ||
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);
      EXECUTE IMMEDIATE 'grant select on sys.v_$xstream_table_stats to ' ||
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      EXECUTE IMMEDIATE 'grant select on ALL_APPLY_DML_CONF_HANDLERS to ' ||
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      EXECUTE IMMEDIATE 'grant select on ALL_APPLY_DML_CONF_COLUMNS to ' ||
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      EXECUTE IMMEDIATE 'grant select on ALL_APPLY_HANDLE_COLLISIONS to ' ||
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      EXECUTE IMMEDIATE 'grant select on ALL_APPLY_REPERROR_HANDLERS to ' ||
        dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

      IF (select_privs_xs_and_gg(i) = 'YES') THEN
        EXECUTE IMMEDIATE 'grant select on DBA_APPLY_DML_CONF_HANDLERS to ' ||
          dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

        EXECUTE IMMEDIATE 'grant select on DBA_APPLY_DML_CONF_COLUMNS to ' ||
          dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

        EXECUTE IMMEDIATE 'grant select on DBA_APPLY_HANDLE_COLLISIONS to ' ||
          dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);

        EXECUTE IMMEDIATE 'grant select on DBA_APPLY_REPERROR_HANDLERS to ' ||
          dbms_assert.enquote_name(user_names_xs_and_gg(i), FALSE);
      END IF;
    END IF;
  END LOOP;

  -- privs for gg
  FOR i IN 1 .. user_names_gg.count
  LOOP
    -- Don't uppercase username during enquote_name
    IF (user_names_gg(i) <> 'SYS' AND user_names_gg(i) <> 'SYSTEM') THEN
      EXECUTE IMMEDIATE 'grant select on sys.gv_$goldengate_table_stats to '||
        dbms_assert.enquote_name(user_names_gg(i), FALSE);
      EXECUTE IMMEDIATE 'grant select on sys.v_$goldengate_table_stats to '||
        dbms_assert.enquote_name(user_names_gg(i), FALSE);
    END IF;
  END LOOP;
END;
/

Rem Move xstream users from streams$_privileged_user to xstream$_privileges
DECLARE
  user_names_xs     dbms_sql.varchar2s;
  cnt               NUMBER;
BEGIN
  SELECT u.name
  BULK COLLECT INTO user_names_xs
  FROM sys.streams$_privileged_user pu, sys.user$ u
  WHERE (bitand(pu.flags, 1) = 1) AND u.user# = pu.user#;

  FOR i IN 1 .. user_names_xs.count 
  LOOP 
    -- delete from streams$_privileged_user
    DELETE FROM sys.streams$_privileged_user
     WHERE user# IN
       (SELECT u.user#
        FROM sys.user$ u
        WHERE u.name = user_names_xs(i));

    -- insert into xstream$_privileges
    SELECT count(*) into cnt 
     FROM sys.xstream$_privileges xp
     WHERE user_names_xs(i) = xp.username;

    IF (cnt = 0) THEN
      INSERT INTO sys.xstream$_privileges(username, privilege_type,
                                          privilege_level)
       VALUES (user_names_xs(i), 3, 1);
    END IF;
  END LOOP;
END;
/

Rem Add connect_user in xstream$_server
DECLARE
  CURSOR server_cur IS SELECT xo.server_name, xo.capture_user
                       FROM dba_xstream_outbound xo;
BEGIN
  FOR server_cur_rec in server_cur LOOP
    UPDATE sys.xstream$_server SET connect_user = server_cur_rec.capture_user
    WHERE  server_name =  server_cur_rec.server_name;
  END LOOP;
END;
/


Rem =====================
Rem End XStream changes
Rem =====================

Rem =====================
Rem Begin AQ changes
Rem =====================

alter session set events '10866 trace name context forever, level 4';

DECLARE
CURSOR s_c IS   SELECT  s.oid, s.destination
                FROM    sys.aq$_schedules s ;
at_pos          BINARY_INTEGER;
dest_q          BINARY_INTEGER := 0;
BEGIN

  -- Update Destq column of aq$_schedules table.

  FOR s_c_rec in s_c LOOP

  -- determine whether destination queue is specified
  at_pos := INSTRB(s_c_rec.destination, '@', 1, 1);
  IF (at_pos = LENGTHB(s_c_rec.destination)) THEN
    dest_q := 0;
  ELSE
    dest_q := 1;
  END IF;

  UPDATE sys.aq$_schedules SET destq = dest_q
  WHERE oid = s_c_rec.oid AND DESTINATION = s_c_rec.destination;

  commit;

  END LOOP;
END;
/   

alter session set events '10866 trace name context off';

DECLARE
CURSOR s_c IS   SELECT  r.eventid, r.agent.address as address
                from sys.aq$_replay_info r where r.agent.address IS NOT NULL;
dot_pos         BINARY_INTEGER;
at_pos          BINARY_INTEGER;
db_domain       VARCHAR2(1024);
new_address     VARCHAR2(1024);
BEGIN

  SELECT UPPER(value) INTO db_domain FROM v$parameter WHERE name = 'db_domain';

  IF db_domain IS NOT NULL THEN
    FOR s_c_rec in s_c LOOP
      at_pos := INSTRB(s_c_rec.address, '@', 1, 1);
      IF (at_pos != 0) THEN
        dot_pos := INSTRB(s_c_rec.address, '.', at_pos, 1);
      ELSE
        dot_pos := INSTRB(s_c_rec.address, '.', 1, 1);
      END IF;
      IF (dot_pos = 0) THEN
        new_address := s_c_rec.address || '.' || db_domain;
        UPDATE sys.aq$_replay_info r set r.agent.address = new_address WHERE
          r.eventid = s_c_rec.eventid AND r.agent.address = s_c_rec.address;
      END IF;

      COMMIT;
    END LOOP;
  END IF;
END;
/


Rem =====================
Rem End AQ changes
Rem =====================

Rem =================
Rem Begin WLM changes
Rem =================

ALTER SESSION SET CURRENT_SCHEMA = APPQOSSYS;

CREATE TABLE wlm_mpa_stream
(
   name               VARCHAR2(4000),
   serverorpool       VARCHAR2(8),
   risklevel          NUMBER
)
/

CREATE TABLE wlm_violation_stream
(
   timestamp         DATE,
   serverpool        VARCHAR2(4000),
   violation         VARCHAR2(4000)
)
/

Rem Allow the EM Agent access to this table for alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_MPA_STREAM
  FOR APPQOSSYS.WLM_MPA_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_mpa_stream TO DBSNMP;

Rem Allow the EM Agent access to this table for alert purposes
CREATE OR REPLACE PUBLIC SYNONYM WLM_VIOLATION_STREAM
  FOR APPQOSSYS.WLM_VIOLATION_STREAM;
GRANT SELECT ON APPQOSSYS.wlm_violation_stream TO DBSNMP;

ALTER SESSION SET CURRENT_SCHEMA = SYS;

Rem =================
Rem End WLM changes
Rem =================

Rem =======================================================================
Rem  Begin Changes for Logminer
Rem =======================================================================

  /*
   * bug-9038074
   * ComplexTypeCols is supposed to have
   *   bit 0x01 set IFF table contains XMLCLOB column
   *   bit 0x04 set IFF table contains Binary XML
   * Prior versions would incorrectly set bot 0x01 and 0x04 for binary XML.
   * Note1: The setting of both 0x01 and 0x05 is legitimate IFF the table
   * contains at least one XMLCLOB AND one Binary XML column.
   * Note2: On upgrade the max(objv#) entrys in logmnrc_gtcs and _gtlo will
   * be refreshed, so the upgrade steps below are primarily to benefit
   * older objv#s.
   * Note3: Though unlikely, if logmnr_gtcs has not been populated for a given
   * entry in logmnr_gtlo, the nvl function is used to leave results, though
   * not correct, as they were.  In most cases this is the best option.
   */
update system.logmnrc_gtlo tlo
  set tlo.complextypecols = nvl
  (
    (
      select
/* lob     */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 68), 4, 1, 0)) +
/* object  */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 1), 1, 2, 0)) +
/* binary  */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 68), 68, 4, 0)) +
/* schema  */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 2), 2, 8, 0)) +
/* hierach */ sum( distinct decode(bitand(tcs.XopqTypeFlags, 512), 512, 16, 0))
      from system.logmnrc_gtcs tcs
      where tcs.logmnr_uid = tlo.logmnr_uid AND
            tcs.XopqTypeType = 1 AND
            tcs.obj# = tlo.BASEOBJ# AND
            tcs.objv# = tlo.BASEOBJV#
    ), tlo.complextypecols
  )
  where 5 = bitand(tlo.complextypecols, 5);
commit;

/*
 *  bug-9038074
 *  logmnrtloflags is supposed to have
 *    bit 0x02 set for XMLTYPE table stored as CLOB
 *    bit 0x04 set for XMLTYPE table stored as OR
 *    bit 0x08 set for XMLTYPE table stored as Binary XML
 *  Because of this bug XMLTYPE table stored as Binary XML would incorrectly
 *  be identified as XMLTYPE table stored as CLOB.  This upgrade change
 *  corrects the error.  Note2 and Note3 above for complextypecols upgrade
 *  are also relevant to this upgrade.
 *
 *  Note: 4294967281 is 0xFFFFFFF1.  This is to keep all current logmnrtloflags
 *        except the possible problematic setting of flags related to
 *        CLOB, OR, or Binary XML XMLTYPE tables.
 */
update system.logmnrc_gtlo tlo
  set tlo.logmnrtloflags = nvl
  (
    (
      (bitand(4294967281, tlo.logmnrtloflags)) +
      (
        select case 
          when bitand(tcs.XopqTypeFlags, 1) = 1 /* XMLOR */
            then 4 /* KRVX_OA_TLO_XMLTYPEOR */
          when bitand(tcs.XopqTypeFlags, 64) = 64 /* Binary XML */
            then 8 /* KRVX_OA_TLO_XMLTYPECSX */
          when bitand(tcs.XopqTypeFlags, 4) = 4 /* clob */
            then 2 /* KRVX_OA_TLO_XMLTYPECLOB */
          else 0
          end
        from system.logmnrc_gtcs tcs
        where tcs.logmnr_uid = tlo.logmnr_uid AND
              tcs.XopqTypeType = 1 AND
              tcs.obj# = tlo.BASEOBJ# AND
              tcs.objv# = tlo.BASEOBJV# AND
              tcs.colname = 'SYS_NC_ROWINFO$' AND
              tcs.type# = 58
      )
    ), tlo.logmnrtloflags
  )
  where 2 = bitand(tlo.logmnrtloflags, 2) AND
        1 = bitand(tlo.property, 1);
commit;

/*
 *  bug-9038074
 *    With the above changes to complextypecols the MCV must be recalculated
 *    for the modified rows.
 *    Also 11.1 contained a flaw with the logic that determined the MCV for
 *    tables containing ADTs that contained an XMLOR attribute.  These would
 *    incorrectly be given an MCV of 11.0.0. when the correct MCV should have
 *    been 99.99.99 (i.e. not supported).
 *    Here we try to selectively recalculate all MCVs that are potentially
 *    incorrect.
 *    Note: The Streams MVDD does not maintain LOGMNRMCV.  Presumably
 *          gtlo.logmnrmcv will be NULL for MVDDs and not be updated by
 *          this statement.
 */
update system.logmnrc_gtlo gtlo
    set gtlo.LOGMNRMCV = '99.9.9.9.9'
    where gtlo.logmnrmcv = '11.0.0.0.0' AND
          (4 = bitand(GTLO.complextypecols, 4) /* KRVX_OA_XMLCSX column pres */
           OR                               /* Unsupported ADT present */
           0 <> bitand(GTLO.UnsupportedCols, /* KRVX_OA_ADT */ 32 +
                                             /* KRVX_OA_NTB */ 64 +
                                             /* KRVX_OA_NAR */ 128 ));
commit;


Rem =======================================================================
Rem  End Changes for Logminer
Rem =======================================================================
Rem ==========================
Rem Begin Bug 8811401 changes
Rem ==========================
create index WRH$_SEG_STAT_OBJ_INDEX on WRH$_SEG_STAT_OBJ(dbid, snap_id)
  tablespace SYSAUX
/

begin
insert into wrh$_tablespace
        (snap_id, dbid, ts#, tsname, contents, segment_space_management,
         extent_management)
  select 0, (select dbid from v$database), ts.ts#, ts.name as tsname,
        decode(ts.contents$, 0, (decode(bitand(ts.flags, 16), 16, 'UNDO',
               'PERMANENT')), 1, 'TEMPORARY')            as contents,
        decode(bitand(ts.flags,32), 32,'AUTO', 'MANUAL') as segspace_mgmt,
        decode(ts.bitmapped, 0, 'DICTIONARY', 'LOCAL')   as extent_management
   from sys.ts$ ts
  where ts.online$ != 3
    and bitand(ts.flags, 2048) != 2048
    and not exists (select 1 from wrh$_tablespace t
                     where dbid = (select dbid from v$database)
                       and t.ts# = ts.ts#);
  commit;
end;
/

Rem ==========================
Rem End Bug 8811401 changes
Rem ==========================

Rem ===========================================================================
Rem Begin Bug#8710750 changes: split WRH$_SQLTEXT table to avoid ref counting
Rem contention.
Rem ===========================================================================

-- Handle re-/failed upgrade case
truncate table WRI$_SQLTEXT_REFCOUNT
/

alter table WRI$_SQLTEXT_REFCOUNT disable constraint 
WRI$_SQLTEXT_REFCOUNT_PK
/

insert into WRI$_SQLTEXT_REFCOUNT(dbid, sql_id, ref_count)
  select dbid, sql_id, ref_count
  from   wrh$_sqltext
  where  ref_count > 0;

commit;

alter table WRI$_SQLTEXT_REFCOUNT enable constraint
WRI$_SQLTEXT_REFCOUNT_PK
/

Rem ===========================================================================
Rem End Bug#8710750 changes: split WRH$_SQLTEXT table to avoid ref counting
Rem contention.
Rem ===========================================================================

Rem Advanced Queuing related upgrade changes
Rem =============================================================================
Rem Bug #10637224 - recreate the dequeue by condition view to fix the join clause
Rem =============================================================================

DECLARE
  CURSOR qt_cur IS
  SELECT qt.schema, qt.name, qt.flags
  FROM system.aq$_queue_tables qt;
BEGIN
  FOR qt_rec IN qt_cur LOOP
  
    BEGIN
      IF dbms_aqadm_sys.mcq_8_1(qt_rec.flags) THEN
        sys.dbms_prvtaqim.create_deq_view(qt_rec.schema, qt_rec.name,
                                          qt_rec.flags); 
      END IF;

    EXCEPTION
      when others then
        dbms_system.ksdwrt(dbms_system.alert_file,
                           'a1102000.sql:  recreate deq view ' ||
                           'failed for ' || qt_rec.schema || '.' ||
                           qt_rec.name);
    END;
  END LOOP;
END;
/

Rem =======================================================================
Rem  Begin Changes for Database Replay 
Rem =======================================================================

Rem
Rem Set capture file id equal to replay file id. This is the correct behavior
Rem for non-consolidated replays. Since this is an upgrade, this rule holds.
Rem
update WRR$_REPLAY_DIVERGENCE
set cap_file_id = file_id
where cap_file_id IS NOT NULL;

commit;

update WRR$_REPLAY_SQL_BINDS
set cap_file_id = file_id
where cap_file_id IS NOT NULL;

commit;

Rem =======================================================================
Rem  End Changes for Database Replay 
Rem =======================================================================

Rem ===============================
Rem Begin Drop SQL Advisor Synonyms
Rem ===============================

Rem Drop all summary advisor related public synonyms created by QSMA.JAR,
Rem which is called from $ORACLE_HOME/rdbms/admin/initqsma.sql IN 10.2.

BEGIN
   FOR cur_rec IN (SELECT synonym_name
                     FROM dba_synonyms
                    WHERE synonym_name LIKE '%oracle/qsma/Qsma%' OR
                          synonym_name LIKE '%oracle/qsma/Char%' OR
                          synonym_name LIKE '%oracle/qsma/Parse%' OR
                          synonym_name LIKE '%oracle/qsma/Token%' OR
                          synonym_name LIKE '%_QsmaReport%' OR
                          synonym_name LIKE '%_QsmaSql%'
                   )
   LOOP
      BEGIN
         IF (cur_rec.synonym_name LIKE '%oracle/qsma/Qsma%' OR
             cur_rec.synonym_name LIKE '%oracle/qsma/Char%' OR
             cur_rec.synonym_name LIKE '%oracle/qsma/Parse%' OR
             cur_rec.synonym_name LIKE '%oracle/qsma/Token%' OR
             cur_rec.synonym_name LIKE '%_QsmaReport%' OR
             cur_rec.synonym_name LIKE '%_QsmaSql%')
           THEN
              EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM '
                            || DBMS_ASSERT.ENQUOTE_NAME(cur_rec.synonym_name, FALSE);
           END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
             DBMS_SYSTEM.ksdwrt(DBMS_SYSTEM.trace_file,'FAILED: DROP '
                                  || '"'
                                  || cur_rec.synonym_name
                                  || '"');
      END;
   END LOOP; 
END;
/

Rem ===============================
Rem End Drop SQL Advisor Synonyms
Rem ===============================


Rem *************************************************************************
Rem END a1102000.sql
Rem *************************************************************************
