declare
 sql_str        varchar2(1000);
 env_vars_table varchar2(61) := null;
 release_ver    varchar2(50);
 cnt            integer;
 wmsys_exist    integer;

 table_not_exists EXCEPTION;
 PRAGMA EXCEPTION_INIT(table_not_exists, -00942);

 invalid_synonym EXCEPTION;
 PRAGMA EXCEPTION_INIT(invalid_synonym, -01432);
begin

  
  select count(*) into cnt
  from dba_tables
  where owner = 'WMSYS' and
        table_name = 'WM$ENV_VARS';

  if (cnt = 1) then 
    env_vars_table := 'WMSYS.WM$ENV_VARS';

  else
    select count(*) into cnt
    from dba_tables
    where owner = 'SYSTEM' and
          table_name = 'WM$ENV_VARS';

    if (cnt = 1) then  
      env_vars_table := 'SYSTEM.WM$ENV_VARS';
    else
      execute immediate 'create or replace view sys.wm_installation as select ''OWM_VERSION'' name, ''NOT_INSTALLED'' value from dual';
    end if;
  end if;

  if (env_vars_table is not null) then
    select count(*) into wmsys_exist
    from dba_users
    where username = 'WMSYS' ;

    
    if (wmsys_exist>0) then
      begin
        execute immediate 'drop view sys.wm_installation' ;

      exception when table_not_exists then null ;
      end ;

      sql_str := 'create or replace view wmsys.wm_installation as select name, value from ' || env_vars_table;
    else
      begin
        execute immediate 'drop view wmsys.wm_installation' ;

      exception when table_not_exists then null ;
      end ;

      sql_str := 'create or replace view sys.wm_installation as select name, value from ' || env_vars_table;
    end if ;
   
    
    execute immediate 'select count(*) from ' || env_vars_table || ' where name = ''OWM_VERSION''' into cnt; 

    if (cnt = 0) then
      
      select count(*) into cnt
      from dba_tables
      where owner = 'SYSTEM' and
            table_name = 'WM$LOCKROWS_INFO';

      if(cnt = 1) then 
       release_ver := '9.0.1.0.0'; 
      else
        release_ver := 'BETA RELEASE'; 
      end if;

      
      sql_str := sql_str || ' union select ''OWM_VERSION'',''' || release_ver || ''' from dual'; 
    end if;

    begin
      select 1 into cnt
      from dba_tab_columns
      where owner = 'WMSYS' and
            table_name = 'WM$ENV_VARS' and
            column_name = 'HIDDEN' ;

      sql_str := sql_str || ' where hidden=0' ;

    exception when no_data_found then null;
    end ;

    
    begin
      execute immediate 'select 1 from dual where exists
       (select 1 from wmsys.wm$sysparam_all_values)' into cnt ;

      sql_str := sql_str || ' union 
       select name, value from wmsys.wm$sysparam_all_values sv where isdefault = ''YES'' and
         not exists (select 1 from wmsys.wm$env_vars ev where ev.name = sv.name) ' ;

    exception when table_not_exists then null;
    end ;

    execute immediate sql_str || ' WITH READ ONLY';
  end if;


  if (wmsys_exist>0) then
    execute immediate 'grant select on wmsys.wm_installation to public with grant option' ;
    execute immediate 'create or replace public synonym wm_installation for wmsys.wm_installation' ;
  else
    execute immediate 'grant select on sys.wm_installation to public with grant option' ;
    execute immediate 'create or replace public synonym wm_installation for sys.wm_installation' ;
  end if ;
  
end;
/
