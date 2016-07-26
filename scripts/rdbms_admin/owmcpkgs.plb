create or replace procedure wmsys.wm$execSQL wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
7
50 89
WeCtcur8g/RiT0kmc2+9WwlxhP8wg5nnm7+fMr2ywFwWclyhO1ouy8vSs6YGj8jKAnzGyhco
xsrvLkTGcNFJ6r+uJNFERLHn6sFQL+pErg8P6h+ugMqZUYPs2T1ylez7po3alPQ=

/
create or replace procedure wm$execSQLIgnoreDropExceptions wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
7
1d1 14c
N0cOtPbqhkGt3PXoX6hDd/MStoQwg43Irq4VZy+VAP5eR68dFOwh3fsDsDi/wll+xB6Kb76B
Z6uGNfJQoiK89idcj+HE+hIgP07GDGP6d+alOp8FHIMuMMXOAQXNugO7n/W0oJjQsUj4IvIj
tuCIOAJRnBa3f7iFpl/DvAhNLLPTUKO30HGtjXaWEQzk66ufdoC1Tr+4T3KbMfXYwjeOAjts
vnXSt7uhTjRJLbo4r4urtKEMchJ1SRmsVph3gPYlMhSPwhRqdeXubN6LlrIJm0Khuc6WCLpS
MsxN7xK0u2gi7Y96zGyh5iDnwMqN94L8i5m8bc/F

/
execute wm$execSQLIgnoreDropExceptions('alter trigger wmsys.no_vm_ddl disable');
execute wm$execSQLIgnoreDropExceptions('alter trigger wmsys.no_vm_drop_a disable');
execute wm$execSQLIgnoreDropExceptions('alter trigger wmsys.no_vm_drop_e disable');
execute wm$execSQLIgnoreDropExceptions('alter trigger no_vm_create disable');
execute wm$execSQLIgnoreDropExceptions('alter trigger no_vm_drop disable');
execute wm$execSQLIgnoreDropExceptions('alter trigger no_vm_drop_a disable');
execute wm$execSQLIgnoreDropExceptions('alter trigger no_vm_alter disable');
execute wm$execSQLIgnoreDropExceptions('alter trigger sys_logoff disable');
execute wm$execSQLIgnoreDropExceptions('alter trigger sys_logon disable');
declare
  cursor pkgs_cur is
  select object_name
  from dba_objects
  where owner = 'WMSYS' and
        object_type='PACKAGE' ;
begin

  for p_rec in pkgs_cur loop
    wm$execSQLIgnoreDropExceptions('drop package wmsys.' || p_rec.object_name);
  end loop ;
end;
/
drop procedure wm$execSQLIgnoreDropExceptions;
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'OPER_LOCKVALUES_TYPE' ;

  if (cnt=0) then
    execute immediate
      'create type wmsys.oper_lockvalues_type as object(parValue integer, curValue integer, interValue integer)' ;
  end if ;

  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'OPER_LOCKVALUES_ARRAY_TYPE' ;

  if (cnt=0) then
    execute immediate
      'create type wmsys.oper_lockvalues_array_type as varray(50) of wmsys.oper_lockvalues_type' ;
  end if ;
end;
/
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'INTTOSTR_ARRAY_TYPE' ;

  if (cnt=0) then
    execute immediate
      'create  type wmsys.IntToStr_array_type is varray(50) of varchar2(50)' ;
  end if ;

  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'TRIGOPTIONSTYPE' ;

  if (cnt=0) then
    execute immediate
      'create type wmsys.trigOptionsType is varray(15) of varchar2(100)' ;
  end if ;
end;
/
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'WM$NV_PAIR_TYPE' ;

  if (cnt=0) then
    execute immediate
      'create or replace type WMSYS.WM$NV_PAIR_TYPE TIMESTAMP ''2003-05-20:10:08:59'' OID ''BE1A0D04EFD56F80E034080020B6D531''
         as object (name varchar2(100), value clob)' ;
  end if ;

  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'WM$NV_PAIR_NT_TYPE' ;

  if (cnt=0) then
    execute immediate
      'create or replace type WMSYS.WM$NV_PAIR_NT_TYPE TIMESTAMP ''2003-05-20:10:08:59'' OID ''BE2E13E3081301C7E034080020B6D531''
        AS table of WMSYS.WM$NV_PAIR_TYPE' ;
  end if ;

  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'WM$EVENT_TYPE' ;

  if (cnt=0) then
    execute immediate
      'create or replace type WMSYS.WM$EVENT_TYPE TIMESTAMP ''2003-05-20:10:08:59'' OID ''BE1A0D04EFDE6F80E034080020B6D531''
         as object (event_name             varchar2(100),
                    workspace_name         varchar2(30),
                    parent_workspace_name  varchar2(30),
                    user_name              varchar2(30),
                    table_name             varchar2(60),
                    aux_params             WMSYS.WM$NV_PAIR_NT_TYPE)' ;
  end if ;
end;
/
exec wmsys.wm$execSQL('grant execute on WMSYS.WM$NV_PAIR_TYPE to public with grant option')  ;
exec wmsys.wm$execSQL('grant execute on WMSYS.WM$NV_PAIR_NT_TYPE to public with grant option')  ;
exec wmsys.wm$execSQL('grant execute on WMSYS.WM$EVENT_TYPE to public with grant option')  ;
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'WM_PERIOD' ;

  if (cnt=0) then
    execute immediate
      'create or replace type wmsys.wm_period TIMESTAMP ''2003-05-21:10:52:30'' OID ''BE2DC636D843039BE034080020EDC61B''
         as object (validfrom timestamp with time zone,
                    validtill timestamp with time zone,
                    MAP member function wm_period_map return varchar2)';
  end if ;

  select count(*) into cnt
  from dba_procedures
  where owner = 'WMSYS' and
        object_name = 'WM_PERIOD' and
        procedure_name = 'WM_PERIOD_MAP' ;

  if (cnt=0) then
    execute immediate 'alter type wmsys.wm_period add MAP member function wm_period_map return varchar2 cascade' ;
  end if ;
end;
/
create or replace type body wmsys.wm_period wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
e
db ef
IQMBRbtfSUi1VSiJ59958/Z/MQIwgxDwa8sVfI7ps/gYwUVsFnZY/IN4FpMFQ4F5aVwdDC82
rK+KhpOEfOfiU+pubnFKAOaGMkaxYgDRch5zdBuOpiszcLPfWlDL3C0Iy0rfgVrUHok+qChd
cIkaM/HfLDuvkFLZFR8DroicqEBGSRsmV7LYl8yfYMRdeQ05Uuet66CUlEeC45NdOgrCKUUP
DYdKsylFhQ0jHdFt2m4=

/
exec wmsys.wm$execSQL('grant execute on wmsys.wm_period to public with grant option')  ;
create or replace public synonym wm_period for wmsys.wm_period  ;
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'WM$NEXTVER_EXP_TYPE' ;

  if (cnt=0) then
    execute immediate 'create or replace type wmsys.wm$nextver_exp_type as object(next_vers integer, orig_nv varchar2(500), rid varchar2(100))' ;
  end if ;

  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'WM$NEXTVER_EXP_TAB_TYPE' ;

  if (cnt=0) then
    execute immediate 'create or replace type wmsys.wm$nextver_exp_tab_type as table of wmsys.wm$nextver_exp_type' ;
  end if ;
end;
/
declare
  cnt integer ;
begin
  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'WM$EXP_MAP_TYPE' ;

  if (cnt=0) then
    execute immediate
      'create or replace type wmsys.wm$exp_map_type
         as object(code     integer,
                   nfield1  number,
                   nfield2  number,
                   nfield3  number,
                   vfield1  varchar2(128),
                   vfield2  varchar2(128),
                   vfield3  clob)' ;
  end if ;

  select count(*) into cnt
  from dba_types
  where owner = 'WMSYS' and
        type_name = 'WM$EXP_MAP_TAB' ;

  if (cnt=0) then
    execute immediate 'create type wmsys.wm$exp_map_tab as table of wmsys.wm$exp_map_type' ;
  end if ;
end;
/
declare
  s varchar2(12) ;

  cursor type_cur is
    select object_name
    from dba_objects
    where owner = 'WMSYS' and
          object_type = 'TYPE' and
          status != 'VALID' ;
begin
  select status into s
  from v$instance ;

  if (s!='OPEN MIGRATE') then
    return ;
  end if ;

  for trec in type_cur loop
    execute immediate 'alter type WMSYS.' || trec.object_name || ' compile' ;
  end loop ;
end ;
/
grant execute on dbms_aq to wmsys ;
grant execute on dbms_lock to wmsys ;
@@owmadms.plb
@@owmlts.plb
create or replace function wmsys.wm$convertDbVersion wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
8
270 158
7YzoyUrxd7Gdk3sWAMdGV8+fL5QwgxDxJJkVfC+VkPg+SC+DrOMNRVR70nI9ORTm8W/ErAaP
cJnFRc7uAHmNFt9eFe3+Er9x8ZR6zH7X7p92ueySRSRMJXm+JJAoLs2JFhTejcPhl1oUQhTo
0efDAo9P4VRZo6becfekBOpTovNpbMYuPVyah8bHHdXUbIYaA0eo2gEeEGAztJ+oNixxaa0i
EE+K6efC46r7IKKCRJYsbJ88LzT0b6UqdJW091XTU/EPyBesBhwRJ6zxHIV4Nd4oIYI1tB3X
LmkzQDDyHva7VR32//hzmotzn7t3KDLctSqW7W3oggR6ptu2iZs=

/
grant execute on wmsys.wm$convertDBVersion to public;
create or replace function wmsys.wm$getDbVersionStr wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
8
117 ff
YRW+MRCq396JIrQuiRNngZ7cNm8wg3lyLpmsZy85j//5GK0waectSqFb/oyjEbG0iJSurMqz
a+G2kvh5LEA4EpAXGb+ft/3cxYK4JPjGYR8us5/E64GsEFsrCUiyjiZDmHfRNWtbaVpt/7Fa
b7wgyq9mSoYv08Ew6Cg+PugzGOU1rna3ugFuOa8hPK3t9RRUcya9YDJOoZHOVpK+EQ1ACQsC
zCYQQYh4Zq/5ke14ByhK4dOuq/dHHBZc8uw=

/
exec wmsys.wm$execSQL('revoke all on wmsys.wm$getDbVersionStr from public')  ;
exec wmsys.wm$execSQL('grant execute on wmsys.wm$getDbVersionStr to public')  ;
@@owmaggrs.plb
@@owmasrts.plb
@@owmvts.plb
@@owmctxs.plb
@@owmutls.plb
@@owmrics.plb
@@owmdtrgs.plb
@@owmaqs.plb
@@owmdutls.plb
@@owmddls.plb
@@owmprvs.plb
@@owmexps.plb
@@owmutrgs.plb
@@owmerrs.plb
@@owmcddls.plb
@@owmrepls.plb
@@owmmigs.plb
@@owmblkls.plb
@@owmmps.plb
@@owmiexps.plb
create or replace package wmsys.owm_9ip_pkg wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
8d a6
ypCHC1gUN9oj0EEciezYp/597LMwg5m49TOf9b9chZZy8MRHVuOWhdzquHSLCWm49csIdMey
CNIyMk4owAiBzKZ/1oR2EB2OFQCEet1xAhaqJOr2RA78qcqqF+qcUMrqAnCxL/U7q8rJNLAs
3O8hO75xc3HYiKZ08hsK

/
grant select  on sys.dba_views to wmsys with grant option;
grant execute on sys.dbms_lob to wmsys with grant option;
