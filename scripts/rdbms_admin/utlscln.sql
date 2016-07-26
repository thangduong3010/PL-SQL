rem 
rem $Header: rdbms/admin/utlscln.sql /st_rdbms_11.2.0/1 2011/04/06 10:19:53 sramakri Exp $ 
rem 
Rem  Copyright (c) 1992, 1996, 1997 by Oracle Corporation 
Rem    NAME
Rem      utlscln.sql - UTILITY SNAPshot clone
Rem    DESCRIPTION
Rem      This file is an example of a procedure that clones a snapshot
Rem      repschema.
Rem    RETURNS
Rem 
Rem    NOTES
Rem      This is an example.  It will not work for all snapshot repschemas
Rem      under all circumstances.  See comments.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     sramakri   04/05/11  - Backport sramakri_bug-9591305_3 from main
Rem     liwong     04/19/97 -  Obsolete parameters and some APIs
Rem     dsdaniel   08/08/94 -  Branch_for_patch
Rem     dsdaniel   08/08/94 -  Creation from Adowings file
 
-- 
-- Toy procedure to clone a snapshot schema from another snapshot site
--
CREATE OR REPLACE PROCEDURE sna_clone(sname   VARCHAR2,
                                      snalink VARCHAR2) IS
ss_name_1    varchar2(128);
ss_name_2    varchar2(128);
dq_pos_1     number;
dq_pos_2     number;
snalink_tgt  varchar2(128);
cur1         integer;
num_rows     integer := 0;
sql_cursor   NUMBER;
sql_cursor2  NUMBER;
dummy        NUMBER;
uc_sname     VARCHAR2(30);
oname        VARCHAR2(30);
otype        VARCHAR2(12);
comment      VARCHAR2(80);
master       VARCHAR2(80);
updatable    VARCHAR2(3);
sna_query    VARCHAR2(32767);
stmt         VARCHAR2(300);
BEGIN

---- Input validation block
  BEGIN
-- Check lengths of names
   if length(sname) > 30 or length(snalink) > 30 then
--    dbms_output.put_line('name(s) > 30 chars');
      raise_application_error(-20000, 
                               'names cannot exceed 30 chars in length');
   end if;

-- These functions will throw: "ORA-44003: invalid SQL name" on failure
   ss_name_1 := sys.dbms_assert.simple_sql_name(sname);
   ss_name_2 := sys.dbms_assert.simple_sql_name(snalink);

-- Check no double-quoted names 
   dq_pos_1 := instr(sname, '"');
   dq_pos_2 := instr(snalink, '"');
   if dq_pos_1 > 0 or dq_pos_2 > 0 then
--    dbms_output.put_line('double-quote present');
      raise_application_error(-20000, 'quoted names not allowed');
   end if;

   snalink_tgt := concat(upper(snalink), '.%');
-- dbms_output.put_line('snalink_tgt = ' || snalink_tgt);
   stmt := 'select 1 from all_db_links ' ||
        'where db_link like :1 and owner = :2 and USERNAME is NULL';

   cur1 := dbms_sql.open_cursor;
   dbms_sql.parse(cur1, stmt, dbms_sql.NATIVE);
   dbms_sql.bind_variable(cur1, ':1', snalink_tgt);
   dbms_sql.bind_variable(cur1, ':2', 'PUBLIC');
   num_rows := dbms_sql.execute_and_fetch(cur1);
   dbms_sql.close_cursor(cur1);

   if num_rows = 0 then
      raise_application_error(-20000, 'invalid snalink');
   end if;

   EXCEPTION
     WHEN OTHERS THEN
       IF dbms_sql.is_open(cur1) THEN
          dbms_sql.close_cursor(cur1);
      END IF;
      RAISE;
  END;

  uc_sname := UPPER(sname);
  sql_cursor := dbms_sql.open_cursor;
  BEGIN
    -- get schema comment from snapshot prototype
    -- Note: can't bind snalink because it gives "ORA-01729: database 
    -- link name expected" if we do
    stmt := 'select schema_comment from all_repcat @' || snalink ||
           ' where sname = :1';
    dbms_sql.parse(sql_cursor, stmt, dbms_sql.NATIVE);
    dbms_sql.bind_variable(sql_cursor, ':1', uc_sname);
    dbms_sql.define_column(sql_cursor, 1, comment, 80);
    dummy := dbms_sql.execute_and_fetch(sql_cursor, FALSE);
    dbms_sql.column_value(sql_cursor, 1, comment);

    -- get master from snapshot prototype
    stmt := 'select dblink from all_repschema @' || snalink
                   || ' where snapmaster = ''Y'' '
                   || '   and sname = :1';
    dbms_sql.parse(sql_cursor, stmt, dbms_sql.v7);
    dbms_sql.bind_variable(sql_cursor, ':1', uc_sname);
    dbms_sql.define_column(sql_cursor, 1, master, 80);
    dummy := dbms_sql.execute_and_fetch(sql_cursor, FALSE);
    dbms_sql.column_value(sql_cursor, 1, master);

    -- register snapshot schema with local site
    dbms_repcat.create_snapshot_repgroup(sname, master, comment);
  EXCEPTION WHEN dbms_repcat.duplicateschema THEN
    NULL;
  END;
    stmt := 'select oname, type, object_comment from all_repobject@' 
            || snalink
            || ' where sname = :1'
            || '   and type != ''TRIGGER''';
  dbms_sql.parse(sql_cursor, stmt, dbms_sql.v7);
  dbms_sql.bind_variable(sql_cursor, ':1', uc_sname);
  dbms_sql.define_column(sql_cursor, 1, oname, 30);
  dbms_sql.define_column(sql_cursor, 2, otype, 12);
  dbms_sql.define_column(sql_cursor, 3, comment, 80);
  dummy := dbms_sql.execute(sql_cursor);
  WHILE dbms_sql.fetch_rows(sql_cursor)>0 LOOP
    -- get object information from snapshot prototype
    dbms_sql.column_value(sql_cursor, 1, oname);
    dbms_sql.column_value(sql_cursor, 2, otype);
    dbms_sql.column_value(sql_cursor, 3, comment);
    IF otype = 'SNAPSHOT' THEN
      BEGIN
        sql_cursor2 := dbms_sql.open_cursor;
        -- note: snapshot querys over 32K will fail
       stmt :=  'select updatable, query from all_snapshots@' || snalink
               || ' where owner = :1'
               || '   and name = :2';
  
        dbms_sql.parse(sql_cursor2, stmt, dbms_sql.v7);
        dbms_sql.bind_variable(sql_cursor2, ':1', uc_sname);
        dbms_sql.bind_variable(sql_cursor2, ':2', oname);
        dbms_sql.define_column(sql_cursor2, 1, updatable, 3);
        dbms_sql.define_column(sql_cursor2, 2, sna_query, 32767);
        dummy := dbms_sql.execute_and_fetch(sql_cursor2);
        dbms_sql.column_value(sql_cursor2, 1, updatable);
        dbms_sql.column_value(sql_cursor2, 2, sna_query);
        dbms_sql.close_cursor(sql_cursor2);
      EXCEPTION WHEN others THEN
        IF dbms_sql.is_open(sql_cursor2) THEN
          dbms_sql.close_cursor(sql_cursor2);
        END IF;
        RAISE;
      END;
    ELSE
      sna_query := NULL;
    END IF;
    BEGIN
      -- replicate snapshot object to local site
      IF updatable = 'YES' AND otype = 'SNAPSHOT' THEN
        dbms_repcat.create_snapshot_repobject(sname, oname, otype, 
                 'create snapshot ' || oname || ' for update as ' || sna_query, 
                 comment);
      ELSIF otype = 'SNAPSHOT' THEN
        dbms_repcat.create_snapshot_repobject(sname, oname, otype, 
                 'create snapshot ' || oname || ' as ' || sna_query, 
                 comment);
      ELSE
        dbms_repcat.create_snapshot_repobject(sname, oname, otype, NULL,
                 comment);
      END IF;
    EXCEPTION WHEN dbms_repcat.duplicateobject THEN
      NULL;
    END;
  END LOOP;
  dbms_sql.close_cursor(sql_cursor);
EXCEPTION WHEN others THEN
  IF dbms_sql.is_open(sql_cursor) THEN
    dbms_sql.close_cursor(sql_cursor);
  END IF;
  RAISE;
END;
/

