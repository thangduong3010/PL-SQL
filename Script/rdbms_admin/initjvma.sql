-- status tables referenced in initjvmaux
begin
execute immediate 'create table java$jvm$status(action varchar2(40),' ||
                                               'inprogress varchar2(1),' ||
                                               'execid varchar2(40),' ||
                                               'rmjvmtime date,' ||
                                               'punting varchar2(5))';
exception
when others then
if sqlcode not in (-955) then raise; end if;
end;
/

begin
execute immediate 'create table java$jvm$steps$done(step varchar2(40))';
exception
when others then
if sqlcode not in (-955) then raise; end if;
end;
/

-- initjvmaux: support package for conditional execution during jvm scripts
create or replace package initjvmaux authid current_user is 
 -- exec: execute a statement
 procedure exec (x varchar2);
 -- drp: execute a statement
 -- with some errors typically seen in drop commands ignored
 procedure drp (x varchar2);
 -- rollbacksetup: do whatever is possible to ensure that there is a large
 -- enough rollback segment available and where apppropriate make it so that
 -- rollbackset will make that segment be in use for the current transaction
 procedure rollbacksetup;
 -- rollbackset: make the rollback segment determined by rollbacksetup, if any,
 -- be in use for the current transaction
 procedure rollbackset;
 -- rollbackcleanup: deallocate any rollback segment allocated by rollbacksetup
 procedure rollbackcleanup;
 -- setloading: make dbms_registry entry for status loading
 procedure setloading;
 -- setloaded: make dbms_registry entry for status loaded
 procedure setloaded;
 -- validate_javavm: validation procedure for dbms_registry
 procedure validate_javavm;
 -- registrystatus: get the value of status from dba_registry for JAVAVM
 function registrystatus return varchar2;
 -- startup_pending_p: see whether startup_required bit is set in registry
 -- for JAVAVM
 function startup_pending_p return boolean;
 -- check_sizes_for_cjs: verify that pool sizes and tablespace are large
 -- enough for create java system
 procedure check_sizes_for_cjs(required_shared_pool number := 24000000,
                               required_shared_pool_if_10049
                                       number := 70000000,
                               required_java_pool number := 12000000,
                               required_tablespace number := 70000000);
 -- create_if_not_present: create an object only if it's not there
 procedure create_if_not_present(command varchar2);
 -- abort_message: dbms_output a highlighted message
 procedure abort_message(msg1 varchar2, msg2 varchar2 default null);
 -- jvmuscript: return jvmuxxx script name if it is appropriate to run it
 -- given the upgrade from version indicated in dba_registry, else return
 -- jvmempty.sql (the empty script).
 function jvmuscript return varchar2;
 -- jvmversion: return version value for JAVAVM from dba_registry
 function jvmversion return varchar2;
 -- current_release_version: return version value from v$instance
 function current_release_version return varchar2;
 -- drop_sys_class: drop the (long)named class from SYS, along with any
 -- public synonym and MD5 table entry
 procedure drop_sys_class(name varchar2);
 -- drop_sys_resource: drop the (long)named resource from SYS, along with any
 -- MD5 table entry
 procedure drop_sys_resource(name varchar2);
 -- do_jis_drop: say whether jis is installed and so needs to be dropped
 -- turn off Compiler if so
 function do_jis_drop return boolean;
 -- startaction_outarg: declare intention to start a given action
 -- returns requested action, if allowed, else conflicting pending action
 procedure startaction_outarg(newaction IN OUT varchar2);
 -- startaction: convenience wrapper for startaction_outarg which ignores
 -- return value and so is callable with a literal string
 procedure startaction(newaction IN varchar2);
 -- endaction_outarg: declare end of current action
 -- returns (in the OUT arg) current action if not punting else 'PUNT'
 procedure endaction_outarg(action OUT varchar2);
 -- endaction: convenience wrapper for endaction_outarg which ignores
 -- return value
 procedure endaction;
 -- endaction_asload: endaction and if not punting, set last action to 'LOAD'
 procedure endaction_asload;
 -- startstep: indicate start of a script step
 -- returns true if step should be attempted
 function startstep(newstep varchar2) return boolean;
 -- endstep: indicate current step completed successfully
 procedure endstep;
 -- currentexecid: return the unique id for the current session that is
 -- used to indicate what session last did startaction
 function currentexecid return varchar2;
 -- Some debugoutput functions
 procedure set_debug_output_on;
 procedure set_debug_output_off;
 procedure debug_output(line varchar2);
 procedure set_alt_tablespace_limit(l number);
 -- drop sros during up/downgrade
 procedure drop_sros;
end;
/

create or replace package body initjvmaux is

deallocate_rollback_name varchar2(30);
sec_rollback_segment_name varchar2(32);

current_step varchar2(40);
standalone_action boolean := false;
do_debug_output boolean := false;

alt_tablespace_limit number := 0;

procedure exec (x varchar2) as
begin
dbms_output.put_line(substr(x, 1, 250));
if login_user != 'SYS' then
  declare
   foo exception;
   pragma exception_init(foo,-1031);
  begin
   raise foo;
  end;
end if;
execute immediate x;
end;

procedure drp (x varchar2) as
begin
exec(x);
exception
when others then
if sqlcode not in (-4080, -1418, -1919, -942, -1432, -4043, -1918, -2289,
                   -6550, -1598, -1534, -1434) then raise; end if;
end;

procedure rollbacksetup as
  x number;
  rollback_segment_name varchar2(30);
BEGIN
  deallocate_rollback_name := null;
  sec_rollback_segment_name := null;

-- no rollback actions when undo_management is AUTO
  begin
    select num into x from v$parameter 
       where name='undo_management' and value='AUTO';
    return;
  exception when no_data_found then null;
  end;

  begin
    select segment_name into rollback_segment_name from dba_rollback_segs
      where tablespace_name='SYSTEM' and next_extent*max_extents>100000000 and
            status='ONLINE' and initial_extent>1000000 and rownum < 2;
    debug_output('found good enough rollback segment ' ||
       rollback_segment_name);
  exception when no_data_found then
    debug_output('didnt find good enough rollback segment');
    x := 1;
    rollback_segment_name := 'MONSTER';
    loop
      begin
        select segment_name into deallocate_rollback_name 
        from dba_rollback_segs where segment_name = rollback_segment_name;
        debug_output('skipped rollback segment ' || rollback_segment_name);
      exception when no_data_found then
        deallocate_rollback_name := rollback_segment_name;
        sec_rollback_segment_name := 
          dbms_assert.simple_sql_name(rollback_segment_name);
        exec('create rollback segment ' || sec_rollback_segment_name ||
             ' storage (initial 2 m next 2 m maxextents unlimited)');
        exec('alter rollback segment ' ||
           sec_rollback_segment_name || ' online');
        debug_output('created rollback segment ' || rollback_segment_name);
        exit;
      end;
      rollback_segment_name := 'MONSTER' || x;
      x := x + 1;
    end loop;
  end;

  sec_rollback_segment_name := 
    dbms_assert.simple_sql_name(rollback_segment_name);
END;

procedure rollbackset as
begin
if sec_rollback_segment_name is not null then
   execute immediate 'set transaction use rollback segment ' ||
     sec_rollback_segment_name;
end if;
end;

procedure rollbackcleanup as
counter number := 0;
begin
if deallocate_rollback_name is not null then
    loop
    declare
      sec_name varchar2(32); --  30+2
    begin
    sec_name := dbms_assert.simple_sql_name(deallocate_rollback_name);
    drp('alter rollback segment ' || sec_name || ' offline');
    begin
    drp('drop rollback segment ' || sec_name);
    exit;
    exception when others then
        if sqlcode not in (-1545) then raise; end if;
    end;
    counter := counter + 1;
    dbms_output.put_line('retrying because of ORA-01545');
    dbms_lock.sleep(2);
    exit when counter > 150;
    exception when others then
      if sqlcode in (-20000) then
        dbms_output.disable;
        dbms_output.enable;
      else
        raise;
      end if;
    end;
    end loop;
end if;
end;

procedure setloading as
begin
dbms_registry.loading('JAVAVM',
                      'JServer JAVA Virtual Machine',
                      'initjvmaux.validate_javavm');
end;

procedure setloaded as
begin
dbms_registry.loaded('JAVAVM');
validate_javavm;
end;

procedure validate_javavm as
begin
  execute immediate
  'declare junk varchar2(10) := dbms_java.longname(''foo''); begin null; end;';
  dbms_registry.valid('JAVAVM');
exception when others then
  dbms_registry.invalid('JAVAVM');
end;

function registrystatus return varchar2 as
result varchar2(30) := dbms_registry.status('JAVAVM');
begin
  if result = 'VALID' then result := 'LOADED'; end if;
  return result;
end;

function startup_pending_p return boolean as
 result boolean := false;
 rmjvmtime date;
begin
  begin
    select rmjvmtime into rmjvmtime from java$jvm$status
       where rmjvmtime = (select startup_time from v$instance);
    result := true;
  exception when no_data_found then null;
  end;
  return result;
end;

procedure check_sizes_for_cjs(required_shared_pool number := 24000000,
                              required_shared_pool_if_10049
                                      number := 70000000,
                              required_java_pool number := 12000000,
                              required_tablespace number := 70000000) as
foo exception;
pragma exception_init(foo, -29554);
free number;
shared_pool_limit number := required_shared_pool;
tablespace_limit number := required_tablespace;
step_name varchar2(40) := 'CHECK_SIZES';
sga_target_value number := 0;
begin
  if alt_tablespace_limit != 0 then
    tablespace_limit := alt_tablespace_limit;
  end if;
  if startstep(step_name) then
    exec('alter system flush shared_pool');
    begin
      select 0 into free from v$parameter2
         where name='event' and value like '%10049 trace%'
         and not exists (select * from v$parameter2
                         where name='event'
                         and value='10049 trace name all off');
      shared_pool_limit := required_shared_pool_if_10049;
    exception when no_data_found then null;
    end;
    begin
      select current_size into sga_target_value
        from v$memory_dynamic_components
        where component='SGA Target';
    exception when no_data_found then null;
    end;
    if sga_target_value = 0 then
      begin
        select sum(bytes) into free from v$sgastat where pool='java pool';
      exception when no_data_found then free := 0;
      end;
      if free < required_java_pool then
        abort_message('Aborting because available java pool, ' || free ||
                      ', is less than ' || required_java_pool || ' .');
        raise foo;
      end if;
      declare
        msg1 varchar2(200);
      begin
        select bytes into free from v$sgastat
           where name='free memory' and
                 pool='shared pool' and
                 bytes < shared_pool_limit;
        msg1 := 'Aborting because available shared pool, ' || free ||
                ', is less than ' || shared_pool_limit || ' .';
        if shared_pool_limit = required_shared_pool_if_10049 then
          abort_message(msg1,
                        'Required value is large because event 10049 is set.');
        else
          abort_message(msg1);
        end if;
        raise foo;
      exception when no_data_found then null;
      end;
    else
      if sga_target_value <
         required_java_pool + shared_pool_limit + 1000000 then
        abort_message('Aborting because sga_target value, ' ||
                       sga_target_value ||
                      ', is not sufficiently larger than the sum of '||
                      ' the required java_pool size, ' || required_java_pool ||
                      ', and the required shared_pool size, ' ||
                      shared_pool_limit || ' .');
        raise foo;
      end if;
    end if;
    select sum(length) into free from idl_ub1$,x$joxft
       where obj#=joxftobn and bitand(joxftflags,96)!=0;
    tablespace_limit := tablespace_limit - free;
    select sum(length) into free from idl_ub1$ u,obj$ o
       where o.obj#=u.obj# and o.type#=56 and name like 'Locale%';
    tablespace_limit := tablespace_limit - free;
    select sum(bytes) into free from dba_free_space 
       where tablespace_name='SYSTEM';
    if free < tablespace_limit then
      abort_message('Aborting because available SYSTEM tablespace, ' || free ||
                    ', is less than ' || tablespace_limit || ' .');
      raise foo;
    end if;
  end if;
  endstep;
  delete from java$jvm$steps$done where step = step_name;
  commit;
end;

procedure create_if_not_present(command varchar2) as
begin
  exec(command);
exception when others then
  if sqlcode not in (-955, -1921) then raise; end if;
end;

procedure abort_message(msg1 varchar2, msg2 varchar2 default null) as
begin
    dbms_output.put_line('.');
    dbms_output.put_line('###');
    dbms_output.put_line('### ' || msg1);
    if msg2 is not null then dbms_output.put_line('### ' || msg2);end if;
    dbms_output.put_line('###');
    dbms_output.put_line('.');
end;

function jvmuscript return varchar2 as
result varchar2(30) := 'jvmempty.sql';
stat varchar2(30);
registry_version varchar2(30);
begin
  begin
    select status, version into stat, registry_version from dba_registry 
      where comp_id='JAVAVM';
    if stat = 'UPGRADING' then
      result := 'jvmu' || substr(translate(registry_version,'x.','x'), 1, 3) || '.sql';
    end if;
  exception when no_data_found then null;
  end;
  return result;
end;

function jvmversion return varchar2 as
begin
  return dbms_registry.version('JAVAVM');
end;

function current_release_version return varchar2 as
v varchar2(20);
begin
  SELECT version INTO v from v$instance;
  return v;
end;

procedure drop_sys_class(name varchar2) as
begin
  drp('drop java class ' || dbms_assert.enquote_name(name, false));
  drp('drop public synonym ' || dbms_assert.enquote_name(name, false));
end;

procedure drop_sys_resource(name varchar2) as
begin
  drp('drop java resource ' || dbms_assert.enquote_name(name, false));
end;

function do_jis_drop return boolean as
junk number;
begin
  select count(*) into junk from obj$
    where type#=4 and owner#=0 and name='ALL_IDS';
  if junk = 0 then return false; end if;
   update obj$ set status=5 where obj#=(select obj# from obj$,javasnm$ 
      where owner#=0 and type#=29 and short(+)=name and 
      nvl(longdbcs,name)='oracle/aurora/rdbms/Compiler');
  commit;
  return true;
end;

-- actions: LOAD       initjvm.sql
--          UNLOAD     rmjvm.sql
--          UPGRADE    udjvmrm from jvmdbmig
--          DOWNGRADE* jvmexxx
--          STANDALONE initsec

-- If input action is compatible with the current action status, as
-- given by the values in the single row in table java$jvm$status,
-- then change java$jvm$status to reflect that the input action is
-- now (or again) in progress.  If the input action is incompatible,
-- set the punting column in java$jvm$status so that until a subsequent
-- endaction or startaction call resets things, startstep will always
-- indicate that a given step should be skipped.
procedure startaction_outarg(newaction IN OUT varchar2) as
lastaction varchar2(40);
inprogress varchar2(1);
inaction varchar(40) := newaction;
begin
  begin
    select action,inprogress into lastaction,inprogress from java$jvm$status;
  exception when no_data_found then
    lastaction := 'NONE';
    inprogress := 'N';
    insert into java$jvm$status values('NONE','N',null,null,'TRUE');
  end;
  standalone_action := false;
  if inprogress = 'Y' then
    if not (newaction = lastaction or
            (newaction = 'UNLOAD' and lastaction = 'LOAD') or
            (substr(newaction,1,13) = 'DOWNGRADE_TO_' and
             substr(lastaction,1,13) = 'DOWNGRADE_TO_')) then
      newaction := 'PUNT';
    end if;
  elsif newaction = 'LOAD' then
    if lastaction != 'UNLOAD' and lastaction != 'NONE' then
      newaction := 'PUNT';
    end if;
  elsif newaction = 'UPGRADE' then
    if (not (lastaction = 'LOAD' or lastaction = 'NONE')) or
       jvmversion = current_release_version
    then 
      newaction := 'PUNT';
    end if;
  elsif newaction = 'DOWNGRADERELOAD' then
    if substr(lastaction,1,9) != 'DOWNGRADE' then 
      newaction := 'PUNT';
    end if;
  elsif substr(newaction,1,9) = 'DOWNGRADE' then
    if lastaction != 'LOAD' then 
      newaction := 'PUNT';
    end if;
  elsif newaction = 'PATCHSET' then
    if lastaction != 'LOAD' then 
      newaction := 'PUNT';
    end if;
  elsif newaction = 'STANDALONE' then
    if lastaction != 'LOAD' then 
      newaction := 'PUNT';
    end if;
  elsif newaction != 'UNLOAD' then
    newaction := 'PUNT';
  end if;

  if newaction = 'PUNT' then
    debug_output('startaction(' || inaction || ') PUNTED');
    update java$jvm$status set punting = 'TRUE';
  elsif newaction = 'STANDALONE' then
    standalone_action := true;
    update java$jvm$status set punting = 'FALSE';
  else
    debug_output('startaction(' || inaction || ') STARTED');
    update java$jvm$status set
      action = newaction,
      inprogress = 'Y',
      execid = currentexecid,
      punting = 'FALSE';
  end if;

  commit;

end;

procedure startaction(newaction IN varchar2) as
newaction_outarg varchar2(40) := newaction;
begin
  startaction_outarg(newaction_outarg);
end;

procedure endaction_outarg(action OUT varchar2) as
begin
  if standalone_action then
    update java$jvm$status set punting = 'FALSE';
    standalone_action := false;
    action := 'STANDALONE';
  else
    begin
      select action into action from java$jvm$status where
         punting = 'FALSE' and
         execid = currentexecid;
      delete from java$jvm$steps$done;
      update java$jvm$status set inprogress = 'N', execid = null;
      debug_output('endaction(' || action || ') DONE');
    exception when no_data_found then
      debug_output('endaction while PUNTING');
      update java$jvm$status set punting = 'FALSE';
      action := 'PUNT';
    end;
  end if;

  commit;

end;

procedure endaction as
outarg varchar2(40);
begin
  endaction_outarg(outarg);
end;

procedure endaction_asload as
outarg varchar2(40);
begin
  endaction_outarg(outarg);
  if (outarg != 'PUNT') then
    update java$jvm$status set action = 'LOAD';
    commit;
  end if;
end;

function startstep(newstep varchar2) return boolean as
punting varchar2(5);
execid varchar2(40);
oldstep varchar2(40);
try boolean := false;
begin
  current_step := null;
  begin
    select execid, punting into execid, punting from java$jvm$status;
    if punting = 'FALSE' then
      debug_output('NOT YET PUNTING AT ' || newstep);
      if standalone_action then
        try := true;
        update java$jvm$status set punting = 'TRUE';
      elsif execid = currentexecid then
        begin
          select step into oldstep from java$jvm$steps$done where step = newstep;
        exception when no_data_found then
          try := true;
          current_step := newstep;
          update java$jvm$status set punting = 'TRUE';
        end;
      else
        debug_output('startstep(' || newstep || ') PUNTED');
        update java$jvm$status set punting = 'TRUE';
      end if;
    end if;
  exception when no_data_found then
    insert into java$jvm$status values('NONE','N',null,null,'TRUE');
  end;

  commit;

  if try then
    debug_output('TRIED ' || newstep);
  else
    debug_output('SKIPPED ' || newstep);
  end if;

  return try;

end;

procedure endstep as
begin
  if current_step is not null then
    debug_output('COMPLETED ' || current_step);
    insert into java$jvm$steps$done values(current_step);
    current_step := null;
  end if;
  update java$jvm$status set punting = 'FALSE';
  commit;
end;

function currentexecid return varchar2 as
execid varchar2(40);
begin
  select sid||'-'||serial# into execid from v$session 
         where sid = (select unique(sid) from v$mystat);
  return execid;
end;

procedure set_debug_output_on as begin do_debug_output := true; end;
procedure set_debug_output_off as begin do_debug_output := false; end;

procedure debug_output(line varchar2) as
begin
  if do_debug_output then dbms_output.put_line(line);end if;
end;

procedure set_alt_tablespace_limit(l number) as
begin
  alt_tablespace_limit := l;
end;

-- drop sros during up/downgrade
procedure drop_sros as
begin
  update obj$ set status=5 where obj#=(select obj# from obj$,javasnm$ 
    where owner#=0 and type#=29 and short(+)=name and 
    nvl(longdbcs,name)='oracle/aurora/rdbms/Compiler');
  commit;
  declare
    cursor C1 is select
       u.name, o.name
       from obj$ o,user$ u where o.type#=56 and u.user#=o.owner#;
    ddl_statement varchar2(200);
    uname         varchar2(30);
    oname         varchar2(30);
    iterations number;
    previous_iterations number;
    loop_count number;
    my_err     number;
  begin
    previous_iterations := 10000000;
    loop
      -- To make sure we eventually stop, pick a max number of iterations
      select count(*) into iterations from obj$ where type#=56;
      exit when iterations=0 or iterations >= previous_iterations;
      previous_iterations := iterations;
      loop_count := 0;
      open C1;
      loop
        begin
          fetch C1 into uname,oname;
          -- zsqi LRG 4937433 (Enquote_Name in place of manually added quotes)
          ddl_statement := 'DROP JAVA DATA ' ||
                           dbms_assert.enquote_name(uname,FALSE) || '.' ||
                           dbms_assert.enquote_name(oname,FALSE);
          exit when C1%NOTFOUND or loop_count > iterations;
        exception when others then
           my_err := sqlcode;
           if my_err = -1555 then -- snapshot too old, re-execute fetch query
             exit;
           else
             raise;
           end if;
        end;
        initjvmaux.exec(ddl_statement);
        loop_count := loop_count + 1;
      end loop;
      close C1;
    end loop;
  end;
  commit;
  drp('delete from java$policy$shared$table');
  update obj$ set status=1 where obj#=(select obj# from obj$,javasnm$ 
    where owner#=0 and type#=29 and short(+)=name and 
    nvl(longdbcs,name)='oracle/aurora/rdbms/Compiler');
  commit;
end;

end;
/

show errors

call initjvmaux.drp('drop table java$rmjvm$aux');
call initjvmaux.drp('drop table java$rmjvm$aux2');
call initjvmaux.drp('drop table java$rmjvm$aux3');
create table java$rmjvm$aux(obj# number);
create table java$rmjvm$aux2(name varchar2(30));
create table java$rmjvm$aux3(obj# number);
create unique index java$rmjvm$auxi on java$rmjvm$aux(obj#);
create unique index java$rmjvm$auxi2 on java$rmjvm$aux2(name);
create unique index java$rmjvm$auxi3 on java$rmjvm$aux3(obj#);

call initjvmaux.create_if_not_present('create table javajar$ (name varchar2(30) not null, owner# number not null, path varchar2(4000), contents blob)');
call initjvmaux.create_if_not_present('create unique index javajar$i on javajar$(name, owner#)');

call initjvmaux.create_if_not_present('create table javajarobjects$ (jarname varchar2(30) not null, owner# number not null, objname varchar2(40) not null, namespace number not null)');

call initjvmaux.create_if_not_present('create table java$jvm$runtime$parameters (owner# number not null, flags number)');
call initjvmaux.create_if_not_present('create unique index java$jvm$runtime$parameters$i on java$jvm$runtime$parameters(owner#)');

call initjvmaux.create_if_not_present('create table java$jvm$rjbc (id varchar2(100), path varchar2(4000), lob blob)');
call initjvmaux.create_if_not_present('create unique index java$jvm$rjbc$i on java$jvm$rjbc(id)');

-- Persistent storage for jit
call initjvmaux.create_if_not_present('create table java$mc$ (  obj#    number not null,  method# number not null,  piece#  number not null,  length  number not null,  piece   long raw not null )');
call initjvmaux.create_if_not_present('create index java$mc$objn_idx on java$mc$(obj#)');

-- Method-level jit-dependences
call initjvmaux.create_if_not_present('create table java$mc$deps (  obj#    number not null,  method# number not null,  dobj#  number not null,  dtype#  number not null )');
call initjvmaux.create_if_not_present('create index java$mc$deps$objn_idx on java$mc$deps(obj#)');

-- Method-level metadata
call initjvmaux.create_if_not_present('create table java$method$metadata (  obj#    number not null,  method# number not null,  piece#  number not null,  length  number not null,  piece   long raw not null )');
call initjvmaux.create_if_not_present('create index java$method$metadata$$objn_idx on java$method$metadata(obj#)');

-- JIT compiler options
call initjvmaux.create_if_not_present('create table java$compiler$options (owner# number not null, property varchar2(64), value varchar2(4000))');

-- Java external call credentials
call initjvmaux.create_if_not_present('create table java$runtime$exec$user$ (owner# number not null, os_username varchar2(512), os_password varchar2(512))');

-- Java negative dependencies
call initjvmaux.create_if_not_present('create table javanegdeps$ (obj# number,name varchar2(30),uname varchar2(30))');
call initjvmaux.create_if_not_present('create index i_javanegdeps_1 on javanegdeps$(obj#)');
call initjvmaux.create_if_not_present('create index i_javanegdeps_2 on javanegdeps$(name, uname)');

-- Package rmjvm: encapsulates undo logic for removing Java system objects
-- during upgrade/downgrade and for full removal of Java to back out of
-- the results of a failed initjvm

create or replace package rmjvm authid current_user is
 procedure run(remove_all boolean);
 procedure strip;
 function hextochar(x varchar2) return varchar2;
 procedure check_for_rmjvm;
end;
/

create or replace package body rmjvm is

procedure exec (x varchar2) as
begin
 initjvmaux.exec(x);
end;

procedure drp (x varchar2) as
begin
 initjvmaux.drp(x);
end;

procedure run(remove_all boolean) as
begin
--    DESCRIPTION
--      This removes java related objects from the data dictionary.
--      If remove_all is true, it removes all java objects and java
--      related tables and packages, including user objects.
--      If remove all is false, it removes only the java objects, such
--      as system classes, that are considered to be a fixed part of a
--      given Oracle release.  It does not remove user objects.
--
--    NOTES
--      This procedure is destructive.  After it runs, System classes 
--      must be reloaded either by initjvm or in a subsequent 
--      upgraded/downgrade phase before Java is again usable.
--
--      This procedure requires a significant amount of rollback
--      to execute.
--

dbms_output.enable(10000000); -- biggest size we can get

initjvmaux.rollbacksetup;

commit;
initjvmaux.rollbackset;

declare
c number;
begin
select count(*) into c from java$rmjvm$aux;
if c = 0 then
  commit;
  initjvmaux.rollbackset;
  if remove_all then
  exec('insert into java$rmjvm$aux (select obj# from obj$ where ' ||
    'type#=28 or type#=29 or type#=30 or namespace=32)');
  else
  exec('insert into java$rmjvm$aux (select joxftobn from x$joxfc ' ||
    'where bitand(joxftflags,96)!=0)');
  commit;
  initjvmaux.rollbackset;
  exec('insert into java$rmjvm$aux (select joxftobn from x$joxfr ' ||
    'where bitand(joxftflags,96)!=0)');
  commit;
  initjvmaux.rollbackset;
  exec('insert into java$rmjvm$aux (select obj# from obj$ ' ||
    'where namespace=32)');
  end if;
end if;
end;

commit;
initjvmaux.rollbackset;

dbms_output.put_line('drop or disable triggers with java implementations');

drp('drop trigger JIS$ROLE_TRIGGER$'); 

drp('delete from duc$ where owner=''SYS'' and pack=''JIS$INTERCEPTOR$'' ' ||
    'and proc=''USER_DROPPED''');
drp('delete from aurora$startup$classes$ where ' ||
    'classname=''oracle.aurora.mts.http.admin.RegisterService'''); 
drp('delete from aurora$dyn$reg'); 
drp('alter trigger CDC_ALTER_CTABLE_BEFORE disable');
drp('alter trigger CDC_CREATE_CTABLE_BEFORE disable');
drp('alter trigger CDC_CREATE_CTABLE_AFTER disable');
drp('alter trigger CDC_DROP_CTABLE_BEFORE disable');
drp('delete from JAVA$CLASS$MD5$TABLE');
commit;

initjvmaux.rollbackset;

dbms_output.put_line('drop synonyms with java targets');

DECLARE
  cursor C1 is select name from java$rmjvm$aux2;

  DDL_CURSOR integer;
  syn_name varchar2(30);
  iterations number;
  previous_iterations number;
  loop_count number;
  my_err     number;
BEGIN
 previous_iterations := 10000000;

 DDL_CURSOR := dbms_sql.open_cursor;

 loop
 
  exec('delete from java$rmjvm$aux2');
  if remove_all then
  exec('insert into  java$rmjvm$aux2 (select unique o1.name from ' ||
     'obj$ o1,obj$ o2 where o1.type#=5 and o1.owner#=1 and o1.name=o2.name and o2.type#=29)');
  else
  exec('insert into  java$rmjvm$aux2 (select unique o1.name ' ||
            'from obj$ o1,obj$ o2, java$rmjvm$aux j ' ||
            'where o1.type#=5 and o1.owner#=1 and o1.name=o2.name and o2.obj#=j.obj#)');
  end if;

 -- To make sure we eventually stop, pick a max number of iterations
  select count(*) into iterations from java$rmjvm$aux2;
 
  exit when iterations=0 or iterations >= previous_iterations;
  previous_iterations := iterations;
  loop_count := 0;
 
  OPEN C1;
 
  LOOP
 
    BEGIN
      FETCH C1 INTO syn_name;
      EXIT WHEN C1%NOTFOUND OR loop_count > iterations;
    EXCEPTION
     WHEN OTHERS THEN
       my_err := SQLCODE;
       IF my_err = -1555 THEN -- snapshot too old, re-execute fetch query
        exit;
       ELSE
        RAISE;
       END IF;
    END;

    BEGIN
        -- Issue the Alter Statement  (Parse implicitly executes DDLs)
        dbms_sql.parse(DDL_CURSOR, 'DROP PUBLIC SYNONYM '|| 
            dbms_assert.enquote_name(syn_name, false), 
            dbms_sql.native); 

    EXCEPTION
        WHEN OTHERS THEN
        null; -- ignore, and proceed.
    END;
 
  <<continue>>
    loop_count := loop_count + 1;

  END LOOP;
  CLOSE C1;

 end loop;
 dbms_sql.close_cursor(DDL_CURSOR);

END;
commit;

dbms_output.put_line('flush shared_pool');
execute immediate 'alter system flush shared_pool';
execute immediate 'alter system flush shared_pool';
execute immediate 'alter system flush shared_pool';

declare
total_to_delete number;
deletions_per_iteration number := 1000;
begin

initjvmaux.rollbackset;

dbms_output.put_line('delete from dependency$');

if remove_all then
select count(*) into total_to_delete from dependency$
  where p_obj# in (select obj# from java$rmjvm$aux);
else
select count(*) into total_to_delete from dependency$
  where p_obj# in (select obj# from obj$ where (type#=29 or type#=56));
end if;
commit;

loop
  dbms_output.put_line(total_to_delete ||' remaining at ' || to_char(sysdate,'mm-dd hh:mi:ss'));
  initjvmaux.rollbackset;
  if remove_all then
  delete from dependency$ where p_obj# in
    (select obj# from java$rmjvm$aux)
    and rownum <= deletions_per_iteration;
  else
  delete from dependency$ where p_obj# in
    (select obj# from obj$ where (type#=29 or type#=56))
    and rownum <= deletions_per_iteration;
  end if;
  commit;
  exit when total_to_delete <= deletions_per_iteration;
  total_to_delete := total_to_delete - deletions_per_iteration;
end loop;

initjvmaux.rollbackset;

dbms_output.put_line('delete from error$');

if remove_all then
select count(*) into total_to_delete from error$
  where obj# in (select obj# from java$rmjvm$aux);
else
select count(*) into total_to_delete from error$
  where obj# in (select obj# from obj$
                 where type#=28 or type#=29 or type#=30 or type#=56);
end if;
commit;
loop
  dbms_output.put_line(total_to_delete ||' remaining at ' || to_char(sysdate,'mm-dd hh:mi:ss'));
  initjvmaux.rollbackset;
  if remove_all then
  delete from error$ where obj# in
    (select obj# from java$rmjvm$aux)
    and rownum <= deletions_per_iteration;
  else
  delete from error$ where obj# in
    (select obj# from obj$ where type#=28 or type#=29 or type#=30 or type#=56)
    and rownum <= deletions_per_iteration;
  end if;
  commit;
  exit when total_to_delete <= deletions_per_iteration;
  total_to_delete := total_to_delete - deletions_per_iteration;
end loop;

initjvmaux.rollbackset;

dbms_output.put_line('delete from objauth$');

select count(*) into total_to_delete from objauth$
   where obj# in (select obj# from java$rmjvm$aux);
commit;
loop
  dbms_output.put_line(total_to_delete ||' remaining at ' || to_char(sysdate,'mm-dd hh:mi:ss'));
  initjvmaux.rollbackset;
  delete from objauth$ where obj# in (select obj# from java$rmjvm$aux)
    and rownum <= deletions_per_iteration;
  commit;
  exit when total_to_delete <= deletions_per_iteration;
  total_to_delete := total_to_delete - deletions_per_iteration;
end loop;

initjvmaux.rollbackset;

dbms_output.put_line('delete from access$');

select count(*) into total_to_delete from access$
   where d_obj# in (select obj# from java$rmjvm$aux);
commit;
loop
  dbms_output.put_line(total_to_delete ||' remaining at ' || to_char(sysdate,'mm-dd hh:mi:ss'));
  initjvmaux.rollbackset;
  delete from access$ where d_obj# in (select obj# from java$rmjvm$aux)
    and rownum <= deletions_per_iteration;
  commit;
  exit when total_to_delete <= deletions_per_iteration;
  total_to_delete := total_to_delete - deletions_per_iteration;
end loop;

if remove_all then
initjvmaux.rollbackset;

dbms_output.put_line('delete from javasnm$');
delete from javasnm$;
commit;
end if;

initjvmaux.rollbackset;

dbms_output.put_line('delete from idl_ub1$');

select count(*) into total_to_delete
 from idl_ub1$ where obj# in (select obj# from java$rmjvm$aux);
commit;
loop
  dbms_output.put_line(total_to_delete ||' remaining at ' || to_char(sysdate,'mm-dd hh:mi:ss'));
  initjvmaux.rollbackset;
  delete from idl_ub1$ where obj# in (select obj# from java$rmjvm$aux)
     and rownum <= deletions_per_iteration;
  commit;
  exit when total_to_delete <= deletions_per_iteration;
  total_to_delete := total_to_delete - deletions_per_iteration;
end loop;

dbms_output.put_line('delete from idl_ub2$');

execute immediate
'select count(*) from idl_ub2$ ' ||
  'where obj# in (select obj# from java$rmjvm$aux)' into total_to_delete;
commit;
loop
  dbms_output.put_line(total_to_delete ||' remaining at ' || to_char(sysdate,'mm-dd hh:mi:ss'));
  initjvmaux.rollbackset;
  execute immediate
  'delete from idl_ub2$ where obj# in (select obj# from java$rmjvm$aux) ' ||
     'and rownum <= :deletions_per_iteration' using deletions_per_iteration;
  commit;
  exit when total_to_delete <= deletions_per_iteration;
  total_to_delete := total_to_delete - deletions_per_iteration;
end loop;

dbms_output.put_line('delete from idl_char$');

select count(*) into total_to_delete
 from idl_char$ where obj# in (select obj# from java$rmjvm$aux);
commit;
loop
  dbms_output.put_line(total_to_delete ||' remaining at ' || to_char(sysdate,'mm-dd hh:mi:ss'));
  initjvmaux.rollbackset;
  delete from idl_char$ where obj# in (select obj# from java$rmjvm$aux)
     and rownum <= deletions_per_iteration;
  commit;
  exit when total_to_delete <= deletions_per_iteration;
  total_to_delete := total_to_delete - deletions_per_iteration;
end loop;

dbms_output.put_line('delete from idl_sb4$');

execute immediate
'select count(*) from idl_sb4$ ' ||
 'where obj# in (select obj# from java$rmjvm$aux)' into total_to_delete;
commit;
loop
  dbms_output.put_line(total_to_delete ||' remaining at ' || to_char(sysdate,'mm-dd hh:mi:ss'));
  initjvmaux.rollbackset;
  execute immediate
  'delete from idl_sb4$ where obj# in (select obj# from java$rmjvm$aux) ' ||
     'and rownum <= :deletions_per_iteration' using deletions_per_iteration;
  commit;
  exit when total_to_delete <= deletions_per_iteration;
  total_to_delete := total_to_delete - deletions_per_iteration;
end loop;

dbms_output.put_line('delete from obj$');
-- 
-- only delete from obj$ if all the java information was deleted
-- from the other tables correctly.  Once we run this delete
-- there is no going back to remove the information from 
-- syn$, objauth$, access$ and dependency$ using this script.
--
DECLARE
 c1 number;
 c2 number;
 c3 number;
 c4 number; 
 c5 number; 
BEGIN
  if remove_all then
  select count(*) into c1 from syn$ where obj# in
        (select o1.obj# from obj$ o1,obj$ o2 
                where o1.name=o2.name and 
                o1.type#=5 and o1.owner#=1 and o2.type#=29);
  select count(*) into c2 from dependency$ where p_obj# in 
        (select obj# from java$rmjvm$aux);
  select count(*) into c4 from javasnm$;
  else
  select count(*) into c1 from syn$ where obj# in
        (select o1.obj# from obj$ o1,obj$ o2,java$rmjvm$aux j
           where o1.name=o2.name and o1.type#=5 and o1.owner#=1
                 and o2.obj#=j.obj#);
  select count(*) into c2 from dependency$ where p_obj# in
        (select obj# from obj$ where
         type#=28 or type#=29 or type#=30 or type#=56);
  c4 := 0;
  end if;

  select count(*) into c3 from objauth$ where obj# in
        (select obj# from java$rmjvm$aux);
  select count(*) into c5 from access$ where d_obj# in
        (select obj# from java$rmjvm$aux);

  update java$jvm$status set rmjvmtime = (select startup_time from v$instance);

  IF c1 = 0 AND c2 = 0 AND c3 = 0 AND c4 = 0 AND c5 = 0 THEN
        select count(*) into total_to_delete
         from obj$ where obj# in (select obj# from java$rmjvm$aux);
        commit;
        loop
        initjvmaux.rollbackset;
        delete from obj$ where obj# in (select obj# from java$rmjvm$aux)
           and rownum <= deletions_per_iteration;
        commit;
        exit when total_to_delete <= deletions_per_iteration;
        total_to_delete := total_to_delete - deletions_per_iteration;
        end loop;

        initjvmaux.rollbackset;
        if not remove_all then
        update obj$ set status=5 where type#=28 or type#=29;
        end if;

        commit;
        initjvmaux.rollbackset;
        delete from java$rmjvm$aux;

        commit;
        initjvmaux.rollbackset;

        insert into java$rmjvm$aux
           (select obj# from obj$ where type#=10 and owner#=1);
        delete from java$rmjvm$aux
            where obj# in (select p_obj# from dependency$);
        delete from obj$ where obj# in  (select obj# from java$rmjvm$aux);
        commit;
        delete from java$rmjvm$aux;
        commit;

        dbms_output.put_line('All java objects removed');
  ELSE
        dbms_output.put_line('Java objects not completely removed. ' ||
                             'Rerun rmjvm.run');
  END IF;
END;

end;

commit;

initjvmaux.rollbackcleanup;

dbms_output.put_line('flush shared_pool');
execute immediate 'alter system flush shared_pool';
execute immediate 'alter system flush shared_pool';
execute immediate 'alter system flush shared_pool';
end;

function hextochar(x varchar2) return varchar2 as
  y varchar2(200) := '';
  d number;
begin
  for i in 1..length(x)/2 loop
    d := to_number(substr(x,i*2-1,2),'XX');
    if d = 0 then return y;end if;
    y := y || chr(d);
  end loop;
  return y;
end;

procedure check_for_rmjvm as
 foo exception;
 pragma exception_init(foo,-28);
 ct number;
begin
  -- check whether registry says startup is pending
  if initjvmaux.startup_pending_p then raise foo; end if;
  -- check whether there are any KGL handles for non fixed objects which
  -- do not appear in obj$.  This can indicate that rmjvm has run in the
  -- current instance
  -- Ignore SYS temp tables created during optimizer statstics
  -- collection.
  select count(*) into ct from x$kglob,obj$ where 
     kglnaobj=name(+) and name is null and kglobtyp in (28, 29, 30, 56);
  if ct != 0 then raise foo; end if;
end;

procedure strip as
begin
--    DESCRIPTION
--      This strips bytecode optimizations from non-system java classes,
--      and sets the status of these classes to invalid (unresolved).
--      It is intended for use only prior to downgrade to 8.1.5, and is
--      present only because 8.1.5 resolution code incorrectly fails to
--      do such stripping, allowing 8.1.6 optimization codes that cannot
--      be correctly interpreted by 8.1.5 to remain in place.
--

dbms_output.enable(10000000); -- biggest size we can get
initjvmaux.rollbacksetup;
commit;
initjvmaux.rollbackset;

delete from java$rmjvm$aux;

exec('insert into java$rmjvm$aux (select joxftobn from x$joxfc ' ||
    'where bitand(joxftflags,96)=0)');

commit;
initjvmaux.rollbackset;

exec('create or replace java source named java$rmjvm$src as import java.lang.Object;');

commit;
initjvmaux.rollbackset;

dbms_output.put_line('strip 8.1.6 bytecode optimizations');

DECLARE
  done boolean;
  already_done number := 0;
  cursor C1(above number) is select
     'ALTER JAVA CLASS "' || u.name || '"."' || o.name || '" RESOLVE',
     o.obj# from 
     obj$ o, user$ u, java$rmjvm$aux j where 
     o.obj#=j.obj# and u.user# = o.owner# and j.obj# > above
     order by j.obj#;

  DDL_CURSOR integer;
  ddl_statement varchar2(200);
  my_err     number;
BEGIN

 DDL_CURSOR := dbms_sql.open_cursor;

 loop
  done := true; 
  OPEN C1(already_done);
 
  LOOP
 
    BEGIN
      FETCH C1 INTO ddl_statement, already_done;
      EXIT WHEN C1%NOTFOUND;
    EXCEPTION
     WHEN OTHERS THEN
       my_err := SQLCODE;
       IF my_err = -1555 THEN -- snapshot too old, re-execute fetch query
--        CLOSE C1;
        done := false;
        exit;
       ELSE
        RAISE;
       END IF;
    END;
 
    BEGIN
        -- Issue the Alter Statement  (Parse implicitly executes DDLs)
        dbms_sql.parse(DDL_CURSOR, dbms_assert.noop(ddl_statement),
                       dbms_sql.native);
    EXCEPTION
        WHEN OTHERS THEN
        null; -- ignore, and proceed.
    END;
 
  END LOOP;
  CLOSE C1;
  exit when done;

 end loop;
 dbms_sql.close_cursor(DDL_CURSOR);

END;
commit;

initjvmaux.rollbackset;

exec('drop java source java$rmjvm$src');
delete from java$rmjvm$aux;

commit;

initjvmaux.rollbackcleanup;

end;

end;
/

create or replace package jvmfcb authid current_user is
procedure init(dirpath varchar2);
procedure put(buff raw);
procedure exit;
end;
/

create or replace package body jvmfcb is

fd utl_file.file_type;

procedure init(dirpath varchar2) as
begin
  execute immediate
   'create or replace directory wfcjadmin as ' ||
     dbms_assert.enquote_literal(dirpath);
  fd := utl_file.fopen('WFCJADMIN', 'fclasses.bin', 'wb');
  delete from java$rmjvm$aux;
  insert into java$rmjvm$aux
  (select joxftobn from x$joxft where bitand(joxftflags,4384) in (32,256,288));
  delete from java$rmjvm$aux2;
  insert into java$rmjvm$aux2
  (select unique(jj.name)
   from java$rmjvm$aux j,obj$ o,javajar$ jj,javajarobjects$ jjo
   where o.obj#=j.obj# and
    (select 1 from x$joxft
     where joxftobn=j.obj# and bitand(joxftflags,8192)=8192)=1 and
    jj.name=jjo.jarname and jj.owner#=0 and jjo.owner#=0 and
    jjo.objname=o.name);
end;

procedure put(buff raw) as
begin
  utl_file.put_raw(fd, buff, true);
end;

procedure exit as
begin
  utl_file.fclose(fd);
  delete from java$rmjvm$aux;
  delete from java$rmjvm$aux2;
end;

end;
/




