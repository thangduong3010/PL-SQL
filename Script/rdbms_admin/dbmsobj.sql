Rem
Rem $Header: rdbms/admin/dbmsobj.sql /st_rdbms_11.2.0/9 2013/04/08 21:45:16 tojhuan Exp $
Rem
Rem dbmsobj.sql
Rem
Rem Copyright (c) 2006, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsobj.sql - General Objects Procedure and Functions
Rem
Rem    DESCRIPTION
Rem      This contains procedures and functions for SQL Objects.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: rdbms/admin/dbmsobj.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/dbmsobj.sql
Rem SQL_PHASE: CATPDBMS_MAIN
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpdbms.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    tojhuan     04/05/13 - Backport 16162444: add OWNER_MIGRATE_UPDATE_TDO,
Rem                           OWNER_MIGRATE_UPDATE_HASHCODE
Rem    elu         01/28/13 - add get_oldversion_hashcode2
Rem    apfwkr      07/16/12 - Backport skabraha_bug-14301358 from main
Rem    skabraha    06/29/12 - procedure to delete orphaned type id cols
Rem    surman      03/27/12 - 13615447: Add SQL patching tags
Rem    skabraha    05/24/11 - make authid current_user
Rem    skabraha    08/03/11 - add recompile_types
Rem    skabraha    04/19/11 - change split_source output
Rem    skabraha    01/18/11 - add fns for apps upgrade
Rem    atomar      05/01/08 - bug upgrade 6770913
Rem    skabraha    06/07/07 - add get_oldvsn_hashcode
Rem    skabraha    12/18/06 - Created
Rem

-- these are the type info we need for update types
create or replace type dbms_objects_utils_tinfo as object (
name       varchar2(30),
objid      number,
toid       raw(16),
hashcode   raw(17),
version    number,
stime      date
);
/

-- element for the source$ array
create or replace type dbms_objects_utils_tselem as object (
objid     number,
source    varchar2(4000)
);
/

-- array of source$ entries
create or replace type dbms_objects_utils_tsource as varray(100) of 
dbms_objects_utils_tselem;
/

-- array of type names
create or replace type dbms_objects_utils_tname as object (
schema  varchar2(128),
typname varchar2(128)
);
/
create or replace type dbms_objects_utils_tnamearr as table of
dbms_objects_utils_tname;
/

-- Package definition
create or replace package dbms_objects_utils authid current_user is
procedure upgrade_dict_image;

procedure update_types(schema1 varchar2, schema2 varchar2, 
typename varchar2, check_update boolean);

function split_source(tschema char, tname char, sources 
OUT dbms_objects_utils_tsource) return number;

procedure recompile_types(names dbms_objects_utils_tnamearr);

procedure delete_orphan_typeidcols;

end;
/


create or replace package body dbms_objects_utils is

-- This procedure upgrades the type dictionary images from 8.0 to 8.1. The
-- dictionary tables that could be in 8.0 are kottd$, kottb$, kottbx$, 
-- kotad$ and kotmd$, which existed in 8.0 or 8.1, when 8.0 compatibility
-- was possible, kotadx$ was created in 9iR2 when we required 8.1 minimum
-- compatibility.

procedure upgrade_dict_image is

oldimg number;
origcnt number;
inscnt  number;
begin

oldimg := 0;
-- first make sure that there are dictionary tables in 8.0 format
execute immediate 'select bitand(flags, 128) from coltype$ where 
obj#=(select obj# from obj$ where name=''KOTTD$'' and owner#=0)' into oldimg;
if (oldimg = 0) then
  dbms_output.put_line ('No type dictionary table to upgrade');
  return;
end if;

execute immediate 'alter session set events ''22372 trace name 
context forever''';

-- upgrade kottd$

dbms_output.put_line('Upgrading kottd$ ...');
execute immediate 'create table kottd_temp$ of kottd';
execute immediate 'select count(*) from kottd$' into origcnt;
execute immediate 'insert into kottd_temp$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kottd$';
commit;
execute immediate  'update coltype$ set flags=flags-bitand(flags,128)
where obj#=(select obj# from obj$ where name=''KOTTD$'' and owner#=0)';
commit;
execute immediate 'alter system flush shared_pool';
--error expected discarding it
-- it is just to build the cursor
execute immediate 'begin insert into kottd$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kottd_temp$;
exception when others then null; end;';
execute immediate 'delete from kottd$';
execute immediate 'begin insert into kottd$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kottd_temp$;
exception when others then null; end;';
execute immediate 'select count(*) from kottd$' into inscnt;
if(origcnt = inscnt) then
  commit;
  dbms_output.put_line('kottd$ Upgraded ...');
  execute immediate 'drop table kottd_temp$';
else
  dbms_output.put_line('Upgrade failed for kottd$ ...');
  rollback;
  return;
end if;
-- now kottb$

dbms_output.put_line('Upgrading kottb$ ...');
origcnt := 0;
inscnt  := 0;  

execute immediate 'create table kottb_temp$ of kottb';
execute immediate 'insert into kottb_temp$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kottb$';
execute immediate 'select count(*) from kottb$' into origcnt;
commit;
execute immediate  'update coltype$ set flags=flags-bitand(flags,128)
where obj#=(select obj# from obj$ where name=''KOTTB$'' and owner#=0)';
commit;
execute immediate 'alter system flush shared_pool';
execute immediate 'begin insert into kottb$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kottb_temp$ ; exception when
others then null;end;';
execute immediate 'delete from kottb$';
execute immediate 'begin insert into kottb$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kottb_temp$ ; exception when
others then null;end;';
execute immediate 'select count(*) from kottb$' into inscnt;
if(inscnt = origcnt) then
  commit;
  dbms_output.put_line('kottb$ Upgraded ...');
  execute immediate 'drop table kottb_temp$';
else
  dbms_output.put_line('Upgrade failed for kottb$ ...');
  rollback;
  return;
end if;


-- now kottbx$

dbms_output.put_line('Upgrading kottbx$ ...');
origcnt := 0;
inscnt  := 0;

execute immediate 'create table kottbx_temp$ of kottbx';
execute immediate 'insert into kottbx_temp$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kottbx$';
execute immediate 'select count(*) from kottbx$' into origcnt;
commit;
execute immediate  'update coltype$ set flags=flags-bitand(flags,128)
where obj#=(select obj# from obj$ where name=''KOTTBX$'' and owner#=0)';
execute immediate 'alter system flush shared_pool';
execute immediate 'begin insert into kottbx$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kottbx_temp$  ; exception when
others then null; end;';
commit;
execute immediate 'delete from kottbx$';
execute immediate 'begin insert into kottbx$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kottbx_temp$  ; exception when
others then null; end;';
execute immediate 'select count(*) from kottbx$' into inscnt;
if(inscnt = origcnt) then
  commit;
  dbms_output.put_line('kottbx$ Upgraded ...');
  execute immediate 'drop table kottbx_temp$';
else
  dbms_output.put_line('Upgrade failed for kottbx$ ...');
  rollback;
  return;
end if;

-- now kotad$
dbms_output.put_line('Upgrading kotad$ ...');
origcnt := 0;
inscnt  := 0;

execute immediate 'create table kotad_temp$ of kotad';
execute immediate 'insert into kotad_temp$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kotad$';
commit;
execute immediate 'select count(*) from kotad$' into origcnt;
execute immediate  'update coltype$ set flags=flags-bitand(flags,128)
where obj#=(select obj# from obj$ where name=''KOTAD$'' and owner#=0)';
execute immediate 'alter system flush shared_pool';

execute immediate 'begin insert into kotad$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kotad_temp$; exception when others
 then null; end;';
commit;
execute immediate 'delete from kotad$';
execute immediate 'begin insert into kotad$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kotad_temp$; exception when others
 then null; end;';
execute immediate 'select count(*) from kotad$' into inscnt;

if(inscnt = origcnt) then
  commit;
  dbms_output.put_line('kotad$ Upgraded ...');
  execute immediate 'drop table kotad_temp$';
else
  dbms_output.put_line('Upgrade failed for kotad$ ...');
  rollback;
  return;
end if;


-- now kotmd$

dbms_output.put_line('Upgrading kotmd$ ...');
origcnt := 0;
inscnt  := 0;

execute immediate 'create table kotmd_temp$ of kotmd';
execute immediate 'insert into kotmd_temp$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kotmd$';
commit;
execute immediate 'select count(*) from kotmd$' into origcnt;
execute immediate  'update coltype$ set flags=flags-bitand(flags,128)
where obj#=(select obj# from obj$ where name=''KOTMD$'' and owner#=0)';
execute immediate 'alter system flush shared_pool';
execute immediate 'begin insert into kotmd$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kotmd_temp$; exception when others
 then null; end;';
execute immediate 'delete from kotmd$';
execute immediate 'begin insert into kotmd$(sys_nc_oid$, sys_nc_rowinfo$)
select sys_nc_oid$, sys_nc_rowinfo$ from kotmd_temp$; exception when others
 then null; end;';
execute immediate 'select count(*) from kotmd$' into inscnt;
if(inscnt = origcnt) then
  commit;
  dbms_output.put_line('kotmd$ Upgraded ...');
  execute immediate 'drop table kotmd_temp$';
else
  dbms_output.put_line('Upgrade failed for kotmd$ ...');
  rollback;
  return;
end if;

-- reset the event
execute immediate 'alter session set events ''22372 trace name 
context off''';

end; /* end of procedure upgrade_dict_image */

-- Prodecure update_types for APPS UPGRADE
-- This one will take in 2 schema names, schema1 and schema2 and will 
-- do the following ...
-- For each type type1 present in schema2 and schema1, it will make any
-- object column/table dependent on schema1.type1 point to schema2.type1
--
-- This can also be used for updating just one type in schema1. In that
-- case give the typename as the 3rd parameter. If you give NULL for typename
-- it will default to the above behaviour.
--
-- This also takes another parameter check_update. If this is set to TRUE
-- then it will check to make sure that none of the types in schema1 has 
-- any tables dependencies after the dictionary update. In cases where 
-- this may not hold true, including most cases where typename is given,
-- set it to FALSE.
--
-- This will do a couple of sanity checks, hashcode and version, to make
-- sure that the schema1.type1 and schema2.type2 are structurally similar
-- and have the same version#.
--
-- IMPORTANT: When using this function make sure that if you are moving the
-- table dependency for any type in schema1 to a similar type in schema2, all
-- of it's referenced types are also moved. ie for type 
-- t1 (a1 int, b1 t2, b2 t3), schema2 should contain t2 and t3 if t1 is 
-- included. If not the dictionary will end up in an inconsistent state. 

-- only sys can make this work. bwahaha <evil laugh> ...
procedure update_types (schema1 varchar2, schema2 varchar2,
typename varchar2, check_update boolean) is

userid number;
lname varchar2(30);
lobjid number;
ltoid raw(16);
lhashcode raw(17);
lversion number;
lstime date;
i number;
numtypes number;
ltinfo dbms_objects_utils_tinfo;
j number;
allgood int := 0;

type tabtinfo is table of dbms_objects_utils_tinfo index by binary_integer;

vtabtinfo tabtinfo;

-- query to get relevant type info
cursor c1 is 
select o.name, o.obj#, o.oid$, t.hashcode, t.version#, o.stime 
from obj$ o, obj$ o1, type$ t 
where o.owner#=(select user# from user$ where name=schema2) and
o1.owner#=(select user# from user$ where name=schema1) and
o1.name= o.name and o.type#=13 and o1.type#=13 and o.oid$=t.tvoid
and o.subname is NULL;

-- query to get relevant type info if type name is given
cursor c5 is 
select o.name, o.obj#, o.oid$, t.hashcode, t.version#, o.stime 
from obj$ o, obj$ o1, type$ t 
where o.owner#=(select user# from user$ where name=schema2) and
o1.owner#=(select user# from user$ where name=schema1) and
o1.name= o.name and o.type#=13 and o1.type#=13 and o.oid$=t.tvoid
and o.name = typename and o.subname is NULL;

cursor c2 is
select user# from user$ where name=schema1;

-- hashcode sanity check query
cursor c3 (c3name varchar2, c3hashcode raw) is
select 1 from obj$ o, type$ t where o.name=c3name and o.owner#=userid and
t.tvoid=o.oid$ and t.hashcode = c3hashcode and o.subname is NULL;

-- version sanity check query
cursor c4 (c3name varchar2, c3version number) is
select 1 from obj$ o, type$ t where o.name=c3name and o.owner#=userid and
t.tvoid=o.oid$ and t.version# = c3version and o.subname is NULL;

-- sanity check to make sure that none of the tables are now dependent on 
-- schema1
cursor c6 is
select 1 from dependency$ d, obj$ o where o.type#=2 and o.obj#=d.d_obj# and 
d.p_obj# in (select obj# from obj$ where type#=13 and subname is null and
owner#=userid);

begin

-- populate the list of types from schema2 ... and the relevant info
i := 1;
if typename is null then
i := 1;
open c1;
loop
  fetch c1 into lname, lobjid, ltoid, lhashcode, lversion, lstime;
  exit when c1%notfound;
  vtabtinfo(i) := dbms_objects_utils_tinfo(lname, lobjid, ltoid, lhashcode, lversion, lstime);
  i := i + 1;
end loop;
close c1;
numtypes := i-1;
else 
open c5;
loop
  fetch c5 into lname, lobjid, ltoid, lhashcode, lversion, lstime;
  exit when c5%notfound;
  vtabtinfo(i) := dbms_objects_utils_tinfo(lname, lobjid, ltoid, lhashcode, lversion, lstime);
  i := i + 1;
end loop;
close c5;
numtypes := i-1;
end if;

-- now get the user# for schema1
open c2;
fetch c2 into userid;
close c2;

-- now lets do a wee little check to make sure that the types that we
-- are replacing are structurally similar, using hashcode check
for i in 1..numtypes loop
  ltinfo := vtabtinfo(i);
  open c3 (ltinfo.name, ltinfo.hashcode);
  fetch c3 into j;
  if c3%notfound then
    close c3;
    goto error1;
  end if;
  close c3;
end loop;


-- Also make sure that the versions match
for i in 1..numtypes loop
  ltinfo := vtabtinfo(i);
  open c4 (ltinfo.name, ltinfo.version);
  fetch c4 into j;
  if c4%notfound then
    close c4;
    goto error2;
  end if;
  close c4;
end loop;

-- ok, we are ready to update the metadata. We do 3 updates
-- 1. update the toid value in coltype$
-- 2. update the toid value in subcoltype$
-- 3. update the p_obj# and p_timestamp in dependency$ for the type,
--    for all table dependents
allgood := 1;
for i in 1..numtypes loop
  ltinfo := vtabtinfo(i);
-- coltype$ update
  update coltype$ set toid=ltinfo.toid where toid=(select oid$ from
  obj$ where name=ltinfo.name and owner#=userid and type#=13 and subname is NULL);
-- subcoltype$ update
  update subcoltype$ set toid=ltinfo.toid where toid=(select oid$ from
  obj$ where name=ltinfo.name and owner#=userid and type#=13 and subname is NULL);
-- dependency$ update
  update dependency$ set p_obj#=ltinfo.objid, p_timestamp=ltinfo.stime
  where p_obj#=(select obj# from obj$ where name=ltinfo.name and 
        owner#=userid and type#=13 and subname is NULL)
  and d_obj# in (select obj# from obj$ where type#=2);
end loop;

-- check to make sure that none of the table are now dependent on schema1 types
-- do this only if check_update is TRUE
if (check_update = TRUE) then
  open c6;
  j := 0;
  fetch c6 into j;
  if (j=1) then
    allgood := 0;
    close c6;
    rollback;
    goto error3;
  end if;
end if;

-- all is well ...
commit;

-- clear SGA
execute immediate 'alter system flush shared_pool';

<<error1>>
if (allgood = 0) then
-- ah, the hashcode check failed ...
  dbms_output.put_line('Type ' || ltinfo.name || 
' failed structural sanity check');
end if;

allgood := 1;

<<error2>>
if (allgood = 0) then
-- version mismatch ...
  dbms_output.put_line('Versions do not match for type ' || ltinfo.name);
end if;

allgood := 1;

<<error3>>
if (allgood = 0) then
-- not all columns/tables updated
  dbms_output.put_line('Not all tables/columns dependent on ' ||
  schema1 || ' updated');
end if;

exception
 when others then
   if (allgood = 1) then
     dbms_output.put_line('Error updating dictionary');
   end if;
 raise;

end; /* end of procedure update types */

-- Function SPLIT_SOURCE
-- This function will take 3 arguments, schema name, type name and an OUT
-- argument sources and will split the source$ entry for the latest version
-- of the type to its CREATE and ALTERs and will return it in sources, with
-- with the corresponding obj#. The number or split sources will be the return
-- value of the functions.
-- The obj# here can be used to determine the order of execution of connected
-- types. For example if t2 is dependent on t1 and the order is create t1,
-- create t2, alter t1, alter t2, then to get the right version for t2 we need
-- to execute in that order, which can be got from obj#.

function split_source
(tschema char, tname char, sources OUT dbms_objects_utils_tsource)
return number is

source           varchar2(32767);
new_source       varchar2(32767);
tmpsource_line   varchar2(4000);
source_line      varchar2(4000);
newsource_line   varchar2(4000);
sourceelem       dbms_objects_utils_tselem;
objid            number;
line_len         number;
total_lines      number;
obj_id           number;
total_len        number;
i                number;
src_pos          number;
source_len       number;
new_pos          number;
j                number;
line_no          number;

cursor c1 is 
select obj# from obj$ where name= tname and owner#=
(select user# from user$ where name=tschema) 
and type#=13 and subname is null;

cursor c2 is 
select line, source, length(source) from source$ where obj#= obj_id;

cursor c3 is
select obj# from obj$ o, type$ t where t.version#=i and o.name=tname and
o.oid$=t.tvoid and o.type#=13;

begin

-- get the obj#
  open c1;
  fetch c1 into obj_id;
  close c1;

-- Get the type's source entries
  total_len := 0;
  source := '';
  new_source := '';
-- First get the total no: of lines
  select count(*) into total_lines from source$ where obj# = obj_id;
  OPEN C2;
  LOOP
    FETCH C2 INTO line_no, tmpsource_line, line_len;
    EXIT WHEN c2%notfound;
-- First get rid of the newline, if existing. That would be the case for all 
-- except the last line.
    IF (line_no < total_lines) THEN
      line_len := line_len-1;
    END IF;
    source_line := substr(tmpsource_line, 1, line_len); 
    source := concat(source, source_line);
    total_len := total_len + line_len;
  END LOOP;
  CLOSE C2;
-- store away total lines
  total_lines := line_no;


-- Go through the source and split it based on seeing alter
  src_pos := 1;
  i := 1;
-- initialize with a create
  sources := dbms_objects_utils_tsource(dbms_objects_utils_tselem(0,'create '),dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''),dbms_objects_utils_tselem(0,''),   dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''), dbms_objects_utils_tselem(0,''));


  WHILE (src_pos < total_len) LOOP

    /* Ok, where's the alter. */
    new_pos := instr(upper(source),' ALTER ', src_pos+3, 1); 
    /* If no alter, copy till end */
    if (new_pos = 0) then
      if (i = 1) then
        sources(i).source := concat(sources(i).source, substr(source, src_pos, total_len));
      else 
        sources(i).source :=  substr(source, src_pos, total_len);
      end if;
      exit;
    end if;

    /* copy the source until ALTER. This is one create type/alter type */
    if (i = 1) then
      sources(i).source := concat(sources(i).source, 
                     substr(source, src_pos, (new_pos-src_pos+1)));
    else 
      sources(i).source := substr(source, src_pos, (new_pos-src_pos+1));
    end if;
-- get the obj# for the version
  open c3;
  fetch c3 into sources(i).objid;
  close c3;

    i := i+1;
  
   src_pos := new_pos+1;
   END LOOP;

-- get the obj# for latest version
  open c3;
  fetch c3 into sources(i).objid;
  close c3;

-- print out the type sources
--  for j in 1..i loop
--    dbms_output.put_line('* ' || to_char(j) || ' : ' || 
--    sources(j).objid || ' ' || sources(j).source);
--  end loop;

 return i;

end; /* end of split_source */

-- Procedure recompile_types
-- This procedure will take in an array (nested table) of type name and
-- invalidate them with status 6. This status will keep the spec timestamp
-- when recompiling, this keeping the dependencies valid. This is used during
-- upgrade/downgrade predominently and the only way to recompile a type with
-- table dependents. Afterwards this will call utl_recomp.recomp_parallel 
-- to revalidate the invalidated types.

procedure recompile_types(
names dbms_objects_utils_tnamearr) is
i number;
numtypes number;
temp  number;
closec boolean := FALSE;
typname dbms_objects_utils_tname;

cursor c1 is
select 1 from sys.obj$ o,sys.type$ t1 ,sys.user$ u where o.oid$=t1.tvoid and 
o.name=typname.typname and o.subname is NULL and o.OWNER# = USER# and 
u.name= typname.schema and substr(t1.hashcode,1,1)='2';

begin

-- invalidate the types
numtypes := 0;
for i in names.first .. names.last loop
  if (closec = TRUE) then
    close c1;
  end if;
  closec := TRUE;
  typname := names(i);
  dbms_output.put_line('Processing ' || typname.schema || '.' ||
   typname.typname);     
-- see if this one is in vsn 1 hashcode
  open c1;
  fetch c1 into temp;
  continue when c1%notfound;
  close c1;
  closec := FALSE;

-- increment the count of types invalidated
  numtypes := numtypes+1;      
  dbms_output.put_line('Invalidating ' || typname.schema || '.' ||
   typname.typname);     
  update obj$ set status=6 where type#=13 and subname is null and
  name=typname.typname and owner#=(select user# from user$ where
  name=typname.schema);
end loop;
commit;

-- if no types were invalidated, exit
if (numtypes = 0) then
  goto end1;
end if;

-- clear SGA
execute immediate 'alter system flush shared_pool';

-- now recompile
utl_recomp.recomp_parallel(null);

/*
  for i in names.first .. names.last loop
    typname := names(i);
    execute immediate 'ALTER TYPE ' || typname.schema || '.' ||
    typname.typname || ' compile specification reuse settings';
  end loop;
*/

<<end1>>
numtypes := 0;

end; /* end of procedure recompile_types */

-- Procedure delete_orphan_typeidcols
-- A little background on the problem - There is a bug in drop attribute
-- code which leaves the typeid column in col$. I fixed that in 12g. But
-- these orphaned rows causes issues for datapump, so we need a way to clean
-- them up, so here it is.
-- This will clean up all orphaned entries in col$.
-- IMPORTANT NOTE: This will not work if the columns are only marked unused.
-- So you will need to drop unsued columns from any table that you want to 
-- clean up. I am not doing that in this function as that can take quite a 
-- while if there is a lot of data to be deleted.
procedure delete_orphan_typeidcols
is

objno number;
intcolno number;

-- Query to get the orphaned rows
cursor c1 is
select distinct c.obj#, c.intcol# from col$ c, coltype$ t where 
bitand(c.property, 33554432)=33554432 and c.obj#=t.obj# and 
c.intcol# not in (select typidcol# from coltype$ t1 where c.obj#=t1.obj# and 
typidcol# is not null);

begin

OPEN c1;
LOOP
  -- get the orphoned typeid row
  FETCH C1 into objno, intcolno;
  EXIT WHEN c1%notfound;
  -- delete from col$
  DELETE from col$ where obj#=objno and intcol#=intcolno;
END LOOP;
CLOSE c1; 

-- all done
COMMIT;

end; /* end of delete_orphan_typeidcols */ 

end; /* end of package dbms_objects_utils */
/

show errors


-- For now let's use the same library that we use for upgrade callouts.
CREATE OR REPLACE LIBRARY UTL_OBJECTS_LIB TRUSTED AS STATIC
/

CREATE OR REPLACE FUNCTION get_oldversion_hashcode
(schema varchar2, slen pls_integer, typename varchar2, tlen pls_integer)
return raw is
LANGUAGE C
NAME "GET_OLDVSN_HASHCODE"
LIBRARY UTL_OBJECTS_LIB
parameters(schema String, slen ub2, typename String, tlen ub2,
return OCIRaw);
/
CREATE OR REPLACE PUBLIC SYNONYM get_oldversion_hashcode 
for sys.get_oldversion_hashcode
/
GRANT EXECUTE ON get_oldversion_hashcode TO PUBLIC
/


CREATE OR REPLACE FUNCTION get_oldversion_hashcode2
(toid raw, vsn pls_integer)
return raw is
LANGUAGE C
NAME "GET_OLDVSN_HASHCODE2"
LIBRARY UTL_OBJECTS_LIB
parameters(toid RAW, toid INDICATOR sb4, toid LENGTH sb4, vsn ub2,
vsn indicator sb2, return indicator sb2, return OCIRaw);
/
CREATE OR REPLACE PUBLIC SYNONYM get_oldversion_hashcode2
for sys.get_oldversion_hashcode2
/
GRANT EXECUTE ON get_oldversion_hashcode2 TO PUBLIC
/

-- invoked during type owner migration to update object cache
CREATE OR REPLACE PROCEDURE owner_migrate_update_tdo
 (toid raw, new_owner varchar2) IS
LANGUAGE C
NAME "OWNER_MIGRATE_TDO"
LIBRARY UTL_OBJECTS_LIB
parameters(toid OCIRaw, new_owner String);
/

-- invoked during type owner migration to update type hashcode
CREATE OR REPLACE FUNCTION owner_migrate_update_hashcode
(toid raw)
return raw IS
LANGUAGE C
NAME "OWNER_MIGRATE_HC"
LIBRARY UTL_OBJECTS_LIB
parameters(toid OCIRaw,
return OCIRaw);
/
