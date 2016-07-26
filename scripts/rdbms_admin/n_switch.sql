Rem
Rem $Header: n_switch.sql 19-jul-2004.04:01:54 kquinn Exp $
Rem
Rem n_switch.sql
Rem
Rem Copyright (c) 2001, 2004, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      n_switch.sql - Migration script for NCHAR data from 8i to 9i after
Rem                     switching ncharset between utf8 and al16utf16
Rem
Rem    DESCRIPTION
Rem      Migration script for NCHAR data from 8i to 9i after switching ncharset
Rem      between utf8 and al16utf16
Rem
Rem    NOTES
Rem      1) use SQLPLUS
Rem      2) connect AS SYSDBA
Rem      3) operation requires database is in RESTRICTED mode
Rem
Rem      The migration script is to migrate NCHAR data, including
Rem      nchar, nvarchar2 and nclob, from 8i and 9i after switching 
Rem      ncharset to make NCHAR data accessible in 9i.  It should be 
Rem      run after the database is upgraded from 8i to 9i.
Rem      Once the script runs, it can not be undone.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kquinn      07/19/04 - 3772100: quote object names 
Rem    arrajara    08/14/01 - bug 1881019
Rem    yzhu        05/11/01 - Commit after adcs.
Rem    arrajara    05/10/01 - replication nchar/nvarchar2 upgrade temp fix
Rem    yzhu        04/26/01 - Remove redundent values.
Rem    yzhu        04/13/01 - Merged yzhu_utlnchar_switch
Rem    yzhu        04/13/01 - Created
Rem

prompt
prompt Warning:
prompt The script is to migrate NCHAR data, including nchar
prompt nvarchar2 and nclob, from 8i to 9i.
prompt Once it runs, it can not be undone.
prompt
prompt To run, 1) use SQLPLUS  and 2) connect AS SYSDBA
prompt            3) operation requires database is in RESTRICTED mode
prompt

accept confirm prompt "Press ctrl-C, then return to quit or any other key to continue: ";

set serveroutput on size 1000000;

rem-------------------------------------------------------
rem  Create table fixedcs_0000 to hold fixec char sets and
rem  its byte width
rem-------------------------------------------------------

DROP TABLE nrmig0000;
CREATE TABLE nrmig0000 
  (sname VARCHAR2(30), oname VARCHAR2(30), trigflag NUMBER);

drop table fixedcs_0000;
create table fixedcs_0000 (name varchar2(40), length number, csid number);

insert into fixedcs_0000 values('US16TSTFIXED', 2, 1001);
insert into fixedcs_0000 values('JA16EUCFIXED', 2, 1830);
insert into fixedcs_0000 values('JA16SJISFIXED', 2, 1832);
insert into fixedcs_0000 values('JA16DBCSFIXED', 2, 1833);
insert into fixedcs_0000 values('KO16KSC5601FIXED', 2, 1840);
insert into fixedcs_0000 values('KO16DBCSFIXED', 2, 1842);
insert into fixedcs_0000 values('ZHS16CGB231280FIXED', 2, 1850);
insert into fixedcs_0000 values('ZHS16GBKFIXED', 2, 1852);
insert into fixedcs_0000 values('ZHS16DBCSFIXED', 2, 1853);
insert into fixedcs_0000 values('ZHT32EUCFIXED', 2, 1860);
insert into fixedcs_0000 values('ZHT32TRISFIXED', 4, 1863);
insert into fixedcs_0000 values('ZHT16DBCSFIXED', 2, 1864);
insert into fixedcs_0000 values('ZHT16BIG5FIXED', 2, 1865);
insert into fixedcs_0000 values('Al16UTF16', 2, 2000);


rem-------------------------------------------------------
rem  Create  stored procedure new_nchar
rem-------------------------------------------------------

create or replace procedure new_nchar (
    table_obj#        in number,
    byte_width        in number
) is
  -- Cursor of colunm name, type and length for NCHAR data from col$
  cursor c is
    select name, type#, length, property, spare3 from col$
        where obj# = table_obj# and charsetform=2 and type# in (1, 96, 112);

  table_name    varchar2(30);     -- The table name for the given table_obj#
  length        number;           -- The length in char for new nchar data
  atb_stmt      varchar2(120);
  owner_name    varchar2(30);
  owner_id      number;
  ncsetnm       varchar(40);
begin
  -- Get the table_name and owner_name for the given table obj#
  select name into table_name from obj$ where obj#=table_obj#;
  select owner# into owner_id from obj$ where obj#=table_obj#;
  select username into owner_name from all_users where user_id = owner_id;

  -- Get national character set name
  select value into ncsetnm from nls_database_parameters
      where parameter = 'NLS_NCHAR_CHARACTERSET';

  -- Scan all the columns in the table for nchar, nvarchar2 and nclob
  for c_rec in c loop

    -- The common part of alter table modify command
    atb_stmt :='alter table "'||owner_name||'"."'||table_name||'" modify "';
    atb_stmt := atb_stmt || c_rec.name || '"';

    length := c_rec.length/byte_width;

    -- The nchar columns
    if c_rec.type# = 96  then

      -- Migrate from 8i to 9i
      if (bitand(c_rec.property, 8388608) = 0) then
        if (length > 2000 and ncsetnm = 'UTF8') then
          dbms_output.put_line('Warning: Length of ' || c_rec.name ||
                               ' exceeds 2000');
          length := 2000;
        end if;
  
        if (length > 1000 and ncsetnm = 'AL16UTF16') then
          dbms_output.put_line('Warning: Length of ' || c_rec.name ||
                               ' exceeds 1000');
          length := 1000;
        end if;

        atb_stmt := atb_stmt || ' nchar(' || length || ')';
      -- Convert from old 9i to new 9i
      else
        atb_stmt := atb_stmt || ' nchar(' || c_rec.spare3 || ')';
      end if;

    end if;

    -- The nvarchar2 columns
    if c_rec.type# = 1  then

      -- Migrate from 8i to 9i
      if (bitand(c_rec.property, 8388608) = 0) then
        if (length > 4000 and ncsetnm = 'UTF8') then
          dbms_output.put_line('Warning: Length of ' || c_rec.name ||
                               ' exceeds 4000');
          length := 4000;
        end if;
  
        if (length > 2000 and ncsetnm = 'AL16UTF16') then
          dbms_output.put_line('Warning: Length of ' || c_rec.name ||
                               ' exceeds 2000');
          length := 2000;
        end if;
  
        atb_stmt := atb_stmt || ' nvarchar2(' || length || ')';
      -- Convert from old 9i to new 9i
      else
        atb_stmt := atb_stmt || ' nvarchar2(' || c_rec.spare3 || ')';
      end if;

    end if;

    -- The nclob columns
    if c_rec.type# = 112  then
      atb_stmt := atb_stmt || ' nclob';
    end if;

    -- execute the alter table modify command
    execute immediate atb_stmt;
  end loop;

end new_nchar;
/

rem-------------------------------------------------------
rem  Create  stored function get_byte_width
rem-------------------------------------------------------

create or replace function get_byte_width
return number is
  -- The cursor to get old charsetid for nchar data
  cursor c_ocsid is
    select charsetid from col$
      where charsetform = 2 and bitand(property, 8388608) = 0 and
                  obj# in (select obj# from obj$
                   where type# = 2 and owner# not in 
                   (select user_id from all_users
                    where username='SYS' or username='SYSTEM'));

  ncsid         number := 0;
  byte_width    number := 1;
begin
  -- Get byte_width of old ncharset
  open c_ocsid;
  fetch c_ocsid into  ncsid;
  close c_ocsid;

  select length into byte_width from fixedcs_0000
        where ncsid = fixedcs_0000.csid ;
  return(byte_width);

exception
  when NO_DATA_FOUND then
    return (1);

end get_byte_width;
/

Rem--------------------------------------------------------
Rem Disable internal triggers 
Rem--------------------------------------------------------

CREATE OR REPLACE PROCEDURE disable_internal_triggers0000 IS
BEGIN
  FOR cur IN (SELECT sname, oname, trigflag FROM nrmig0000) LOOP

    dbms_output.put_line('disable_internal_triggers0000: sname :' 
                          || cur.sname || '  oname :' || cur.oname
                          || '  trigflag:' || cur.trigflag);
    -- replication trigger
    IF bitand(cur.trigflag,1)=1 THEN
      sys.dbms_internal_trigger.destroy(cur.sname, cur.oname, 
                                      dbms_internal_trigger.trigger_type_rep);
    END IF;

    -- materialized view log 
    IF bitand(cur.trigflag,2)=2 THEN
      sys.dbms_internal_trigger.destroy(cur.sname, cur.oname, 
                                      dbms_internal_trigger.trigger_type_log);
    END IF;

    -- updatable materialized view
    IF bitand(cur.trigflag,4)=4 THEN
      sys.dbms_internal_trigger.destroy(cur.sname, cur.oname, 
                                      dbms_internal_trigger.trigger_type_snp);
    END IF;

    -- sync cdc trigger
    IF bitand(cur.trigflag,16)=16 THEN
      sys.dbms_internal_trigger.destroy(cur.sname, cur.oname, 
                                      dbms_internal_trigger.trigger_type_scdc);
    END IF;
   
  END LOOP;
END disable_internal_triggers0000;
/

Rem--------------------------------------------------------
Rem Enable internal triggers 
Rem--------------------------------------------------------

CREATE OR REPLACE PROCEDURE enable_internal_triggers0000 IS
BEGIN
  FOR cur IN (SELECT sname, oname, trigflag FROM nrmig0000) LOOP 

    dbms_output.put_line('enable_internal_triggers0000: sname :' 
                           || cur.sname || '  oname :' || cur.oname
                           || '  trigflag:' || cur.trigflag);

    -- replication trigger
    IF bitand(cur.trigflag,1)=1 THEN
      sys.dbms_internal_trigger.make(cur.sname, cur.oname, 
                                      dbms_internal_trigger.trigger_type_rep);
    END IF;

    -- materialized view log 
    IF bitand(cur.trigflag,2)=2 THEN
      sys.dbms_internal_trigger.make(cur.sname, cur.oname, 
                                      dbms_internal_trigger.trigger_type_log);
    END IF;

    -- updatable materialized view
    IF bitand(cur.trigflag,4)=4 THEN
      sys.dbms_internal_trigger.make(cur.sname, cur.oname, 
                                      dbms_internal_trigger.trigger_type_snp);
    END IF;

    -- sync cdc trigger
    IF bitand(cur.trigflag,16)=16 THEN
      sys.dbms_internal_trigger.make(cur.sname, cur.oname, 
                                      dbms_internal_trigger.trigger_type_scdc);
    END IF;
  END LOOP;
END enable_internal_triggers0000;
/
   

rem--------------------------------------------------------
rem switch national character set between utf8 and al16utf16
rem--------------------------------------------------------

declare
  ncsname varchar2(40);
begin
  select value into ncsname from nls_database_parameters
         where parameter = 'NLS_NCHAR_CHARACTERSET';
  update props$ set name='NLS_OLD_NCHAR_CS' where name='NLS_SAVED_NCHAR_CS';
  commit;
  if ncsname= 'UTF8' then 
    execute immediate
    'alter database national character set internal_use al16utf16';
  else 
    execute immediate 
    'alter database national character set internal_use utf8';
  end if;
  commit;
exception
  when others then
    update props$ set name='NLS_SAVED_NCHAR_CS' where name='NLS_OLD_NCHAR_CS';
    commit;
    raise;
end;
/

rem--------------------------------------------------------
rem Migrate old NCHAR data to new NCHAR data and convert 
rem 9i NCHAR data from old ncharset to new ncharset
rem--------------------------------------------------------

declare
  -- The cursor to get each user table' obj#.
  cursor c is
    select obj# from obj$ where type# = 2;

  byte_width    number;
  obj#          number;
begin

  -- Get byte_width
  byte_width := get_byte_width();

  -- Get all the replicated tables with nchar/nvarchar2 column
  INSERT INTO nrmig0000 (sname, oname, trigflag)
    (SELECT trim(u.name) sname, trim(o.name) oname, t.trigflag
      FROM sys.tab$ t, sys.obj$ o, sys.user$ u
      WHERE t.obj# = o.obj#  AND
        t.trigflag > 0   AND
        u.user# = o.owner# AND
        t.obj# IN (SELECT c.obj# FROM col$ c
                     WHERE charsetform=2 and c.type# in (1, 96, 112)));

  BEGIN 
    disable_internal_triggers0000;  
  EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line('disable_internal_triggers0000 error:'|| sqlcode);
  END;

  -- For each user table, loop to check NCHAR data
  for c_rec in c loop
    obj# := c_rec.obj#;
    new_nchar(obj#, byte_width);
  end loop;

  BEGIN
    enable_internal_triggers0000;  
  EXCEPTION WHEN OTHERS THEN 
    dbms_output.put_line('enable_internal_triggers0000 error:'|| sqlcode);
  END;

end;
/

drop table nrmig0000;
drop procedure  enable_internal_triggers0000;
drop procedure disable_internal_triggers0000;

drop table fixedcs_0000;
drop procedure new_nchar;
drop function get_byte_width;
set serveroutput off;
