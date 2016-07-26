Rem
Rem $Header: rdbms/admin/xdbeo112.sql /st_rdbms_11.2.0/4 2013/07/04 09:45:09 rafsanto Exp $
Rem
Rem xdbeo112.sql
Rem
Rem Copyright (c) 2011, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      xdbeo112.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    stirmizi    12/06/12 - remove xdb$import_tt_info
Rem    apfwkr      03/15/12 - Backport qyu_bug-13474450 from main
Rem    juding      07/28/11 - Get previous_version from CATPROC when it is NULL
Rem    hxzhang     07/14/11 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

-----------------------------------------------------------------------------
-- downgrade SXI to 11.2.0.1
-- set OID column to null for SXI table created for partitioned xmltype table
-----------------------------------------------------------------------------

alter session set events '19119 trace name context forever, level 0x20000000';

declare
  -- local SXI table created for partitioned xmltype table
  cursor XTAB_CUR_1 is
    select t.IDXOBJ# idx_id
         , t.XMLTABOBJ# idxtab_id
         , bu.NAME btab_user
         , bo.NAME btab_name
         , u.NAME xtab_user
         , o.NAME xtab_name
    from XDB.XDB$XTAB t
       , IND$ i, OBJ$ bo, USER$ bu
       , OBJ$ o, USER$ u
    where bitand(t.FLAGS, 16640) = 16640
    and t.IDXOBJ# = i.OBJ#
    and i.BO# = bo.OBJ#
    and bo.OWNER# = bu.USER#
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#;

  previous_version varchar2(30);
  stmt varchar2(2000);
begin
  select prv_version into previous_version
  from registry$
  where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL
  then
    select prv_version into previous_version
    from registry$
    where cid = 'CATPROC';
  end if;

  if previous_version like '11.2.0.1%' then
    for XTAB_REC in XTAB_CUR_1
    loop
        -- set OID column nullable
        stmt :=
        'alter table '
        || dbms_assert.enquote_name(XTAB_REC.xtab_user, FALSE) || '.' 
        || dbms_assert.enquote_name(XTAB_REC.xtab_name, FALSE)
        || ' modify (OID null)';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;

        -- set OID column to null
        stmt :=
        'update '
        || dbms_assert.enquote_name(XTAB_REC.xtab_user, FALSE) || '.' 
        || dbms_assert.enquote_name(XTAB_REC.xtab_name, FALSE) || ' xt'
        || ' set OID = null';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
    end loop;
    commit;
  end if;
end;
/

alter session set events '19119 trace name context off';

-----------------------------------------------------------------------------
-- downgrade SXI to 11.2.0.2
-- set KEY column to null for SXI leaf table
-----------------------------------------------------------------------------

alter session set events '19119 trace name context forever, level 0x20000000';

declare
  -- SXI leaf table
  cursor XTAB_CUR_1 is
    select u.NAME xtab_user
         , o.NAME xtab_name
         , t.IDXOBJ# idx_id
         , t.XMLTABOBJ# idxtab_id
         , iu.NAME xidx_user
         , io.NAME xidx_name
         , decode(bitand(t.FLAGS, 16384), 16384, 'local', '') ptlcl
    from XDB.XDB$XTAB t, OBJ$ o, USER$ u
       , XDB.XDB$XTAB k, OBJ$ io, USER$ iu
    where 1=1
    and t.XMLTABOBJ# = o.OBJ#
    and o.OWNER# = u.USER#
    and t.XMLTABOBJ# = k.PTABOBJ# (+)
    and t.IDXOBJ# = io.OBJ#
    and io.OWNER# = iu.USER#
    group by u.NAME 
           , o.NAME
           , t.PTABOBJ#
           , t.IDXOBJ#
           , t.XMLTABOBJ#
           , iu.NAME
           , io.NAME
           , t.FLAGS
    having count(k.XMLTABOBJ#) = 0;

  previous_version varchar2(30);
  stmt varchar2(2000);

  idxnm varchar2(200);
  cstcnt integer;
begin
  select prv_version into previous_version
  from registry$
  where cid = 'XDB';

  /* If XDB was installed during a upgrade, previous_version will be NULL.
   * When that happens, get previous_version from CATPROC.
   */
  if previous_version is NULL
  then
    select prv_version into previous_version
    from registry$
    where cid = 'CATPROC';
  end if;

  if previous_version like '11.2.0.2%' then
    for XTAB_REC in XTAB_CUR_1
    loop
      idxnm := 'SYS' || XTAB_REC.idx_id || '_'
               || XTAB_REC.idxtab_id || '_KEY_IDX';

      -- KEY column is primary key?
      select count(*) into cstcnt
      from all_constraints
      where OWNER = XTAB_REC.xtab_user
      and CONSTRAINT_NAME = idxnm
      and CONSTRAINT_TYPE = 'P'
      and TABLE_NAME = XTAB_REC.xtab_name;

      if cstcnt > 0
      then
        -- drop primary key constraint on KEY column
        stmt :=
        'alter table '
        || dbms_assert.enquote_name(XTAB_REC.xtab_user, FALSE) || '.' 
        || dbms_assert.enquote_name(XTAB_REC.xtab_name, FALSE)
        || ' drop primary key drop index';
        -- dbms_output.put_line(stmt);
        execute immediate stmt;
      end if;

      -- set KEY column to null
      stmt :=
      'update '
      || dbms_assert.enquote_name(XTAB_REC.xtab_user, FALSE) || '.' 
      || dbms_assert.enquote_name(XTAB_REC.xtab_name, FALSE)
      || ' set KEY = null';
      -- dbms_output.put_line(stmt);
      execute immediate stmt;
    end loop;
    commit;
  end if;
end;
/

alter session set events '19119 trace name context off';


