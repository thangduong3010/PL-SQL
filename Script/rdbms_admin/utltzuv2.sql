Rem
Rem $Header: rdbms/admin/utltzuv2.sql /main/12 2010/04/20 16:19:45 huagli Exp $
Rem
Rem utltzuv2.sql
Rem
Rem Copyright (c) 2003, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utltzuv2.sql - time zone file upgrade to a new version script 
Rem
Rem    DESCRIPTION
Rem      The contents of the files timezone.dat and timezlrg.dat are
Rem      usually updated to a new version to reflect the transition rule 
Rem      changes for some time zone region names. The transition rule
Rem      changes of some time zones might affect the column data of
Rem      TIMESTAMP WITH TIME ZONE data type. For example, if users
Rem      enter TIMESTAMP '2003-02-17 09:00:00 America/Sao_Paulo', 
Rem      we convert the data to UTC based on the transition rules in the 
Rem      time zone file and store them on the disk. So '2003-02-17 11:00:00'
Rem      along with the time zone id for 'America/Sao_Paulo' is stored 
Rem      because the offset for this particular time is '-02:00' . Now the 
Rem      transition rules are modified and the offset for this particular 
Rem      time is changed to '-03:00'. when users retrieve the data, 
Rem      they will get '2003-02-17 08:00:00 America/Sao_Paulo'. There is
Rem      one hour difference compared to the original value.
Rem     
Rem      Refer to $ORACLE_HOME/oracore/zoneinfo/readme.txt for detailed 
Rem      information about time zone file updates.
Rem 
Rem      This script should be run before you update your database's
Rem      time zone file to the latest version. This is a pre-update script.
Rem
Rem      This script first determines the time zone version currently in use 
Rem      before the upgrade. It then queries an external table to get all the 
Rem      affected timezone regions between the current version (version before 
Rem      the update) and the latest one. This external table points to the 
Rem      file of $ORACLE_HOME/oracore/zoneinfo/timezdif.csv, which contains 
Rem      all the affected time zone names in each version. Please make sure 
Rem      that you have the latest version of the timezdif.csv (the one 
Rem      corresponding to the latest time zone data files) before you run this
Rem      check script.
Rem
Rem      Then, this script scans the database to find out all columns
Rem      of TIMESTAMP WITH TIME ZONE data type. If the column is defined
Rem      directly on TIMESTAMP WITH TIME ZONE data type or ADT data type 
Rem      defined on TIMESTAMP WITH TIME ZONE excluding VARRAY, the script 
Rem      also finds out how many rows might be affected by checking whether
Rem      the column data contain the values for the affected time zone names.
Rem      The results are stored in table sys.sys_tzuv2_temptab. If the column
Rem      is defined on VARRAY with TIMESTAMP WITH TIME ZONE embedded, we do NOT
Rem      scan the data to find out how many rows are affected but we still 
Rem      report the table and column information, which are stroed in table 
Rem      sys.sys_tzuv2_va_tmptab;
Rem      
Rem      Before running this script, make sure that the following tempoary 
Rem      table names do not confict with any existing table objects in
Rem      your database.
Rem
Rem         sys.sys_tzuv2_temptab
Rem         sys.sys_tzuv2_temptab1
Rem         sys.sys_tzuv2_va_temptab
Rem         sys.sys_tzuv2_va_temptab1
Rem            
Rem      If they do, change the the above table names in the script to other 
Rem      names.
Rem
Rem      If your database has column data that will be affected by the
Rem      time zone file update, dump the data before you upgrade to the
Rem      new version. After the upgrade, you need update the data
Rem      to make sure the data is stored based on the new rules in the
Rem      new version of time zone files.
Rem      
Rem      For example, user scott has a table tztab:
Rem
Rem        CREATE TABLE tztab(
Rem          x NUMBER PRIMARY KEY,
Rem          y TIMESTAMP WITH TIME ZONE);
Rem
Rem        INSERT INTO tztab VALUES(1, TIMESTAMP '...');
Rem
Rem      Before upgrade, you can create a table tztab_back, note
Rem      column y here is defined as VARCHAR2 to preserve the original
Rem      value.
Rem     
Rem        CREATE TABLE tztab_back(
Rem          x NUMBER PRIMARY KEY, 
Rem          y VARCHAR2(256));
Rem
Rem        INSERT INTO tztab_back 
Rem          SELECt x, to_char(y, 'YYYY-MM-DD HH24.MI.SSXFF TZR') 
Rem          FROM tztab;
Rem
Rem      After upgrade, you need update the data in the table tztab using
Rem      the value in tztab_back.
Rem
Rem        UPDATE tztab t SET
Rem         t.y = (SELECT TO_TIMESTAMP_TZ(t1.y, 'YYYY-MM-DD HH24.MI.SSXFF TZR')
Rem                FROM tztab_back t1 
Rem                WHERE t.x=t1.x); 
Rem     
Rem      Once you are done with the time zone files upgrade and patch of
Rem      TIMESTAMP WITH TIME ZONE data. Please drop the following temporary 
Rem      tables:
Rem       
Rem        drop table sys.sys_tzuv2_temptab;
Rem        drop table sys.sys_tzuv2_temptab1;
Rem        drop table sys.sys_tzuv2_va_temptab;
Rem        drop table sys.sys_tzuv2_va_temptab1
Rem
Rem    NOTES
Rem      1. This script needs to be run before upgrading to a new version time 
Rem         zone file. Also, before running this script, make sure that you
Rem         get the latest version of timezdif.csv file.
Rem
Rem      2. This script must be run using SQL*PLUS.
Rem
Rem      3. You must be connected AS SYSDBA to run this script.
Rem
Rem      4. This script is created only for Oracle 10.1 or higer. A separate 
Rem         script is provided for Oracle 9i.
Rem
Rem      5. tzuv2ext_*.log and tzuv2ext_*.bad will be created in the directory
Rem         of $ORACLE_HOME/oracore/zoneinfo when using the external table
Rem         for $ORACLE_HOME/oracore/zoneinfo/timezdif.csv file to get all the
Rem         affected time zone names.
Rem
Rem         After running the script, please refer to these two files to see 
Rem         if there are any rows in timezdif.csv, which are not loaded in 
Rem         table sys.sys_tzuv2_affected_regions. If so, it might affect the 
Rem         correct selection of affected TIMESTAMP WITH TIME ZONE tables in 
Rem         the database. You can always delete tzuv2ext*.log & tzuv2ext*.bad.
Rem        
Rem         Path separator is obtained by querying v$database for platform_id.
Rem         If it is windows platform, path separator uses '\'. If it is Unix
Rem         platform,  path separator uses '/'.
Rem 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    huagli      04/09/10 - 9559503: fix possible SQL injection issue
Rem    huagli      01/07/10 - 7256209: enhancements and code clean up
Rem    yifeng      03/06/07 - 5923970: added functionalities to detect and 
Rem                           count the rows affected by TZ ver changes in 
Rem                           typed table and nested tables. Added 
Rem                           functionalities to detect tables and columns of 
Rem                           affected varrays.
Rem    huagli      01/24/07 - 5838646:new line marker changed to '\n' when 
Rem                           reading from the external table
Rem                           5844057:HP OpenVMS has a specific logic to 
Rem                           provide the UNIX path equivalent to ORACLE_HOME, 
Rem                           which is ORACLE_HOME_UNIX.
Rem    huagli      10/11/06 - code hygiene
Rem    huagli      07/31/06 - time zone update
Rem    srsubram    12/27/05 - convert in-list into a join query 
Rem    srsubram    11/06/05 - 4616517:execute count query in parallel 
Rem    srsubram    05/12/05 - 4331865:Modify script to work with prior 
Rem                           releases 
Rem    lkumar      05/11/04 - Fix lrg 1691434.
Rem    rchennoj    12/02/03 - Fix query 
Rem    qyu         11/22/03 - qyu_bug-3236585 
Rem    qyu         11/17/03 - Created
Rem

SET SERVEROUTPUT ON

DECLARE
  dbv             VARCHAR2(10);
  dbtzv           VARCHAR2(5);
  numrows         NUMBER;
  TYPE cursor_t   IS REF CURSOR;
  cursor_tstz     cursor_t;
  cursor_nt_tstz  cursor_t;
  tstz_owner      VARCHAR2(30);
  tstz_tname      VARCHAR2(30);
  tstz_qcname     VARCHAR2(4000);
  eqtstz_qcname   VARCHAR2(4000);
  tz_version      NUMBER;
  oracle_home     VARCHAR(4000);
  tz_count        INTEGER;
  tz_numrows      INTEGER;
  plsql_block     VARCHAR2(200);
  file_separator  VARCHAR2(3);
  pfid            NUMBER;           
  current_user    VARCHAR2(30);
  insert_stmt     VARCHAR2(4000);
  -- constant for double quote
  DBLQT                  CONSTANT VARCHAR2(2) := '"';
  -- constants defined for platform ID
  PLATFORM_WINDOWS32     CONSTANT BINARY_INTEGER := 7;
  PLATFORM_WINDOWS64     CONSTANT BINARY_INTEGER := 8;
  PLATFORM_WINDOWS64AMD  CONSTANT BINARY_INTEGER := 12;
  PLATFORM_OPENVMS       CONSTANT BINARY_INTEGER := 15;
  
BEGIN

  --========================================================================
  -- First make sure that the check script is running by SYS
  --========================================================================

  EXECUTE IMMEDIATE 
        'SELECT SYS_CONTEXT(''userenv'', ''current_user'') FROM dual' 
  INTO current_user;

  IF current_user != 'SYS' THEN
   DBMS_OUTPUT.PUT_LINE('This check script must be run through user "SYS".');
   RETURN;
  END IF;

  --========================================================================
  -- Make sure that only version 10 or higher uses this script
  --========================================================================

  EXECUTE IMMEDIATE 'SELECT substr(version,1,6) FROM v$instance' INTO dbv;
        
  IF dbv = '8.1.7.' THEN
    DBMS_OUTPUT.PUT_LINE('TIMESTAMP WITH TIME ZONE data type was not ' ||
                         'supported in Release 8.1.7.');
    DBMS_OUTPUT.PUT_LINE('No need to validate TIMESTAMP WITH TIME ZONE data.');
    RETURN;
  END IF;
        
  IF dbv in ('9.0.1.','9.2.0.') THEN
    DBMS_OUTPUT.PUT_LINE('There are no time zone version changes ' || 
                         'for Release 9.0.1 or 9.2.0. Customers with ' ||
                         'extended maintenance support can be always ' ||
                         'provided with new time zone version files and ' ||
                         'the updated 9i style script if needed.');
    RETURN;
  END IF;

  --========================================================================
  -- Create temporary tables used by the check script
  --========================================================================
  EXECUTE IMMEDIATE
    'SELECT count(*) FROM ALL_ALL_TABLES
     WHERE owner = ''SYS'' and table_name = ''SYS_TZUV2_TEMPTAB''' 
  INTO tz_count;
  
  IF tz_count <> 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE sys.sys_tzuv2_temptab';
  END IF;
  
  EXECUTE IMMEDIATE 'CREATE TABLE sys.sys_tzuv2_temptab (
                          table_owner  VARCHAR2(30),
                          table_name   VARCHAR2(30),
                          column_name  VARCHAR2(4000),
                          rowcount     NUMBER,
                          nested_tab   VARCHAR2(3)
                     )';

  EXECUTE IMMEDIATE
    'SELECT count(*) FROM ALL_ALL_TABLES
     WHERE owner = ''SYS'' and table_name = ''SYS_TZUV2_TEMPTAB1''' 
  INTO tz_count;

  IF tz_count <> 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE sys.sys_tzuv2_temptab1';
  END IF;

  EXECUTE IMMEDIATE 'CREATE TABLE sys.sys_tzuv2_temptab1 (
                          time_zone_name VARCHAR2(60)
                     )';

  EXECUTE IMMEDIATE
    'SELECT count(*) FROM ALL_ALL_TABLES
     WHERE owner = ''SYS'' and 
           table_name = ''SYS_TZUV2_VA_TEMPTAB''' 
  INTO tz_count;

  IF tz_count <> 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE sys.sys_tzuv2_va_temptab';
  END IF;

  EXECUTE IMMEDIATE 'CREATE TABLE sys.sys_tzuv2_va_temptab(
                          table_owner  VARCHAR2(30),
                          table_name   VARCHAR2(30),
                          column_name  VARCHAR2(4000),
                          nested_tab   VARCHAR2(3)
                     )';

  EXECUTE IMMEDIATE
    'SELECT count(*) FROM ALL_ALL_TABLES
     WHERE owner = ''SYS'' and 
     table_name = ''SYS_TZUV2_VA_TEMPTAB1'''
  INTO tz_count;

  IF tz_count <> 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE sys.sys_tzuv2_va_temptab1';
  END IF;

  EXECUTE IMMEDIATE 'CREATE TABLE sys.sys_tzuv2_va_temptab1(
                         va_of_tstz_typ VARCHAR2(30)
                     )';

  --========================================================================
  -- Get $ORACLE_HOME
  --========================================================================

  EXECUTE IMMEDIATE 'SELECT platform_id FROM v$database'
  INTO pfid;
        
  plsql_block := 'BEGIN SYS.DBMS_SYSTEM.GET_ENV(:1, :2); END;';

  IF pfid = PLATFORM_OPENVMS THEN
    EXECUTE IMMEDIATE plsql_block USING 'ORACLE_HOME_UNIX', OUT oracle_home;
  ELSE
    EXECUTE IMMEDIATE plsql_block USING 'ORACLE_HOME', OUT oracle_home;
  END IF;
  
  --========================================================================
  -- Use an external table created on timezdif.csv file to get the
  -- affected time zones. In this way, every time when time zone information
  -- changes, we only need to provide user with the updated timezdif.csv file
  -- without changing utltzuv2.sql.
  -- 
  -- 1. Setup the directory for timezdif.csv and log files(log, bad log)
  -- 2. Check any existing external table with this name 
  --    sys.sys_tzuv2_affected_regions
  -- 3. Setup the parameters of the external table
  --========================================================================

  -- get the file separator by looking at the platform ID
  IF pfid = PLATFORM_WINDOWS32 OR pfid = PLATFORM_WINDOWS64 OR 
     pfid = PLATFORM_WINDOWS64AMD 
  THEN
    file_separator := '\';
  ELSE
    file_separator := '/';
  END IF;
  
  EXECUTE IMMEDIATE 'CREATE OR REPLACE DIRECTORY timezdif_dir AS ''' ||
                    oracle_home || file_separator || 'oracore' ||
                                   file_separator || 'zoneinfo''';
  
  EXECUTE IMMEDIATE
    'SELECT count(*) FROM ALL_ALL_TABLES
     WHERE owner = ''SYS'' and table_name = ''SYS_TZUV2_AFFECTED_REGIONS''' 
  INTO tz_count;

  IF tz_count <> 0 THEN
    EXECUTE IMMEDIATE 'DROP TABLE sys.sys_tzuv2_affected_regions';
  END IF;

  EXECUTE IMMEDIATE 'CREATE TABLE sys.sys_tzuv2_affected_regions 
                     (
                       version         NUMBER,
                       time_zone_name   VARCHAR2(40),
                       from_year       NUMBER,      
                       to_year         NUMBER
                     )
                        ORGANIZATION EXTERNAL
                        (
                         TYPE ORACLE_LOADER
                         DEFAULT DIRECTORY timezdif_dir
                         ACCESS PARAMETERS
                         (
                          records delimited by ''\n''
                          skip 3
                          badfile timezdif_dir:''tzuvext%a_%p.bad''
                          logfile timezdif_dir:''tzuvext%a_%p.log''
                          fields terminated by '',''
                          lrtrim
                          missing field values are null
                          (
                           version, time_zone_name, from_year, to_year
                          )
                         )
                         LOCATION (''timezdif.csv'')
                        )
                        REJECT LIMIT UNLIMITED';

   
  EXECUTE IMMEDIATE 'SELECT count(*) FROM sys.sys_tzuv2_affected_regions' 
  INTO tz_numrows;

  IF tz_numrows = 0 THEN
    DBMS_OUTPUT.PUT_LINE('The external table ' ||
                         'sys.sys_tzuv2_affected_regions is not populated ' ||
                         'correctly.');
    DBMS_OUTPUT.PUT_LINE('Please contact Oracle Support for this issue.');
    RETURN;
  END IF; 
      
  --======================================================================
  -- Check if the TIMEZONE data is consistent with the latest version.
  --======================================================================

  EXECUTE IMMEDIATE 'SELECT version FROM v$timezone_file' INTO tz_version;

  EXECUTE IMMEDIATE 'SELECT MAX(version) FROM sys_tzuv2_affected_regions' 
  INTO dbtzv;
        
  IF tz_version = dbtzv THEN
     DBMS_OUTPUT.PUT_LINE('The time zone file used for your current RDBMS ' ||
                          'has the same version (ver ' || dbtzv || ') ' ||
                          'as what this check script checks. No need to ' ||
                          'apply the patch of time zone files and ' ||
                          'TIMESTAMP WITH TIME ZONE data.');

     DBMS_OUTPUT.PUT_LINE('If you want to check for another time zone ' ||
                          'version other than version ' || dbtzv || ', ' ||
                          'please install the corresponding timezdif.csv ' ||
                          'file and then run this check script for that ' ||
                          'version.');
     RETURN;
  END IF;

  --======================================================================
  -- Get tables with columns defined as type TIMESTAMP WITH TIME ZONE.
  --======================================================================

  OPEN cursor_tstz FOR
     'SELECT atc.owner, atc.table_name, atc.qualified_col_name
      FROM   "ALL_TAB_COLS" atc, "ALL_ALL_TABLES" at
      WHERE  data_type LIKE ''TIMESTAMP%WITH TIME ZONE'' AND
             atc.owner = at.owner AND atc.table_name = at.table_name';

  --======================================================================
  -- Query the external table to get all the affected time zones based
  -- on the current database time zone version, and then put them into
  -- a temporary table, sys_tzuv2_temptab1.
  --======================================================================
  
  EXECUTE IMMEDIATE 
    'INSERT INTO sys.sys_tzuv2_temptab1 
         SELECT DISTINCT time_zone_name 
         FROM sys.sys_tzuv2_affected_regions t
         WHERE t.version > ' || tz_version;

  EXECUTE IMMEDIATE 'ANALYZE TABLE sys.sys_tzuv2_temptab1 ' ||
                    'COMPUTE STATISTICS';

  --======================================================================
  -- Check regular table columns.
  --======================================================================
  insert_stmt := 'INSERT INTO sys.sys_tzuv2_temptab VALUES(:1,:2,:3,:4,:5)';
  LOOP
     BEGIN
       FETCH cursor_tstz INTO tstz_owner, tstz_tname, tstz_qcname;
       EXIT WHEN cursor_tstz%NOTFOUND;

       -- If the qualified column is not in the format of "X"."Y"."Z",
       -- double enquote the column.
       IF INSTR(tstz_qcname, '.') = 0 OR INSTR(tstz_qcname, '"') = 0 THEN
         eqtstz_qcname := DBLQT || tstz_qcname || DBLQT;
       ELSE
         eqtstz_qcname := tstz_qcname;
       END IF;
       
       EXECUTE IMMEDIATE 
         'SELECT /*+ USE_HASH (r t) */ COUNT(1) FROM ' || 
         DBLQT || tstz_owner || DBLQT || '.' || 
         DBLQT || tstz_tname || DBLQT || ' t, ' ||
         'sys.sys_tzuv2_temptab1 r ' ||
         'WHERE UPPER(r.time_zone_name) = ' ||
         'UPPER(TO_CHAR(t.' || eqtstz_qcname || ', ''TZR'')) '
       INTO numrows;
        
       IF numrows > 0 THEN
         EXECUTE IMMEDIATE insert_stmt USING
            tstz_owner, tstz_tname, tstz_qcname, numrows, 'NO';
       END IF;
  
     EXCEPTION
       WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('OWNER : ' || tstz_owner);
         DBMS_OUTPUT.PUT_LINE('TABLE : ' || tstz_tname);
         DBMS_OUTPUT.PUT_LINE('COLUMN : ' || tstz_qcname);
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
     END;
  END LOOP;

  --======================================================================
  -- Check nested table columns.
  --======================================================================

  OPEN cursor_nt_tstz FOR
     'SELECT owner, table_name, qualified_col_name ' ||
     'FROM   "ALL_NESTED_TABLE_COLS" ' ||
     'WHERE  data_type LIKE ''TIMESTAMP%WITH TIME ZONE'' ';

  LOOP
     BEGIN
       FETCH cursor_nt_tstz INTO tstz_owner, tstz_tname, tstz_qcname;
       EXIT WHEN cursor_nt_tstz%NOTFOUND;

       -- If the qualified column is not in the format of "X"."Y"."Z",
       -- double enquote the column.
       IF INSTR(tstz_qcname, '.') = 0 OR INSTR(tstz_qcname, '"') = 0 THEN
         eqtstz_qcname := DBLQT || tstz_qcname || DBLQT;
       ELSE
         eqtstz_qcname := tstz_qcname;
       END IF;

       EXECUTE IMMEDIATE 
         'SELECT /*+ NESTED_TABLE_GET_REFS USE_HASH(r t) */ COUNT(1) FROM ' ||
         DBLQT || tstz_owner || DBLQT || '.' || 
         DBLQT || tstz_tname || DBLQT || ' t, ' ||
         'sys.sys_tzuv2_temptab1 r ' ||
         'WHERE UPPER(r.time_zone_name) = ' ||
         'UPPER(TO_CHAR(t.' || eqtstz_qcname || ', ''TZR'')) '
       INTO numrows;
       
        IF numrows > 0 THEN
          EXECUTE IMMEDIATE insert_stmt USING
            tstz_owner, tstz_tname, tstz_qcname, numrows, 'YES';
        END IF;
  
     EXCEPTION
       WHEN OTHERS THEN
         DBMS_OUTPUT.PUT_LINE('OWNER : ' || tstz_owner);
         DBMS_OUTPUT.PUT_LINE('TABLE : ' || tstz_tname);
         DBMS_OUTPUT.PUT_LINE('COLUMN : ' || tstz_qcname);
         DBMS_OUTPUT.PUT_LINE(SQLERRM);
     END;
  END LOOP;

  --======================================================================
  -- Check varrays containing TSTZ data type. Note that we do not check
  -- TSTZ data embedded in varrays. We just report the table names and
  -- column names defined over varray types which contain TSTZ data type.
  --======================================================================
  
  -- get VARRAY types containing TSTZ data type
  EXECUTE IMMEDIATE 
    'INSERT INTO sys.sys_tzuv2_va_temptab1
       SELECT DISTINCT o.name 
       FROM
         ( SELECT p_obj# obj# FROM sys.dependency$
           START WITH p_obj# in ( 
             SELECT DISTINCT o.obj#
             FROM sys.obj$ o, sys.attribute$ a
             WHERE o.oid$ = a.toid AND
                   a.attr_toid = ''0000000000000000000000000000003E''
             UNION ALL
             SELECT DISTINCT o.obj#
             FROM sys.obj$ o, sys.collection$ c
             WHERE o.oid$ = c.toid AND
                   c.elem_toid = ''0000000000000000000000000000003E'')
           CONNECT BY prior d_obj# = p_obj# AND
                      bitand(prior property, 1) = 1
           ORDER SIBLINGS BY d_obj#, p_obj# ) t,
          sys.obj$ o, sys.coltype$ c
       WHERE t.obj# = o.obj# AND o.oid$ = c.toid AND bitand(c.flags, 8) = 8';

  -- Report the tables and column names defined over varray types which
  -- contain TSTZ data type.
  EXECUTE IMMEDIATE
    'INSERT INTO sys.sys_tzuv2_va_temptab
       SELECT atc.owner, atc.table_name, atc.qualified_col_name, ''NO''
       FROM "ALL_TAB_COLS" atc, "ALL_ALL_TABLES" at, sys.sys_tzuv2_va_temptab1
       WHERE data_type = va_of_tstz_typ AND
             atc.owner = at.owner AND atc.table_name = at.table_name';

  EXECUTE IMMEDIATE
    'INSERT INTO sys.sys_tzuv2_va_temptab
       SELECT owner, table_name, qualified_col_name, ''YES''
       FROM "ALL_NESTED_TABLE_COLS", sys.sys_tzuv2_va_temptab1
       WHERE data_type = va_of_tstz_typ';
      
  DBMS_OUTPUT.PUT_LINE('Query sys.sys_tzuv2_temptab and ' ||
                       'sys.sys_tzuv2_va_temptab tables to see ' ||
                       'if any TIMESTAMP WITH TIME ZONE data are affected ' ||
                       'when upgrading from the current time zone ' ||
                       'version ' || tz_version ||
                       ' to a newer version of ' || dbtzv || '.');

EXCEPTION
  WHEN OTHERS THEN
   IF INSTR(SQLERRM, 'KUP-04063') != 0 
   THEN
      DBMS_OUTPUT.PUT_LINE('Directory for file timezdif.csv is ' ||
                           'not correctly specified!');
      DBMS_OUTPUT.PUT_LINE(sqlerrm);
   ELSIF INSTR(SQLERRM, 'KUP-04040') != 0
   THEN
      DBMS_OUTPUT.PUT_LINE('File timezdif.csv in TIMEZDIF_DIR not found!');
   ELSE 
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
   END IF;
END;
/

Rem=========================================================================
SET SERVEROUTPUT OFF
Rem=========================================================================
