@@owminst.plb
alter table wmsys.wm$adt_func_table modify(type_name varchar2(68)) ;
delete from wm$workspaces_table ;
delete from wm$version_hierarchy_table ;
delete from wm$workspace_priv_table ;
commit;
insert into sys.wm$version_table select * from wmsys.wm$version_table;
insert into sys.wm$nextver_table select * from wmsys.wm$nextver_table;
insert into sys.wm$version_hierarchy_table select * from wmsys.wm$version_hierarchy_table;
insert into sys.wm$workspaces_table(workspace,parent_workspace,current_version,
parent_version,post_version,verlist,owner,createTime,description,workspace_lock_id,
freeze_status,freeze_mode,freeze_writer,oper_status,wm_lockmode,isRefreshed)
select workspace,parent_workspace,current_version,parent_version,post_version,
verlist,owner,createTime,description,workspace_lock_id,freeze_status,
substr(freeze_mode,1,12),freeze_writer,oper_status,wm_lockmode,isRefreshed 
from wmsys.wm$workspaces_table;
insert into sys.wm$workspace_priv_table select * from wmsys.wm$workspace_priv_table;
delete from sys.wm$workspace_priv_table where grantee = 'WM_ADMIN_ROLE' 
 and workspace is null and grantor = 'SYS' and priv = 'FA' and admin = 1;
insert into sys.wm$workspace_sessions_table select * from wmsys.wm$workspace_sessions_table;
insert into sys.wm$workspace_savepoints_table select * from wmsys.wm$workspace_savepoints_table;
insert into sys.wm$resolve_workspaces_table select * from wmsys.wm$resolve_workspaces_table;
insert into sys.wm$adt_func_table select * from wmsys.wm$adt_func_table;
declare
 vtid_v          integer;
 table_name_v    varchar2(30);
 owner_v         varchar2(30);
 notification_v  integer;
 notifyWorkspaces_v varchar2(4000);
 disabling_ver_v VARCHAR2(13);
 ricWeight_v     integer;
 isFastLive_v    integer default 0;
 isWorkflow_v    integer default 0;
 hist_v          varchar2(50) ;
 pkey_cols_v     varchar2(4000) default '';
 index_type_v    integer;
 index_field_v   integer;
 sql_str_v      clob;

 cursor c1 is select vtid,table_name,owner,notification,notifyWorkspaces,disabling_ver,ricWeight,isFastLive,isWorkflow,hist,pkey_cols from sys.wm$versioned_tables_tmp;

begin

  open c1;
  loop
    fetch c1 into vtid_v,table_name_v,owner_v,notification_v,notifyWorkspaces_v,disabling_ver_v,ricWeight_v,isFastLive_v,isWorkflow_v,hist_v,pkey_cols_v;
    exit when c1%NOTFOUND;

    insert into sys.wm$versioned_tables values(vtid_v,table_name_v,owner_v,notification_v,notifyWorkspaces_v,disabling_ver_v,ricWeight_v,isFastLive_v,isWorkflow_v,hist_v,pkey_cols_v,sys.wm$ed_undo_code_table_type());

  end loop;
  close c1;

end;
/
declare
  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := sys.wm$convertDbVersion(version_str);

  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
    purgeOption := ' PURGE' ;
  end if ;

  execute immediate 'drop table sys.wm$versioned_tables_tmp' || purgeOption ;
end;
/
insert into sys.wm$ric_table select * from wmsys.wm$ric_table; 
insert into sys.wm$ric_triggers_table select * from wmsys.wm$ric_triggers_table; 
insert into sys.wm$insteadof_trigs_table select * from wmsys.wm$insteadof_trigs_table;
declare
 trig_owner_name_v  varchar2(50);
 trig_name_v        varchar2(50);
 table_owner_name_v varchar2(50);
 table_name_v       varchar2(50);
 trig_type_v        varchar2(3);
 status_v           varchar(10); 
 trig_procedure_v   varchar2(50);
 when_clause_v      varchar2(4000);
 description_v      varchar2(4000);
 trig_code_v        long;

 cursor c1 is select trig_owner_name,trig_name,table_owner_name,table_name,trig_type,status, trig_procedure,when_clause,description,trig_code from wmsys.wm$udtrig_info;

begin

  open c1;
  loop
    fetch c1 into trig_owner_name_v,trig_name_v,table_owner_name_v,table_name_v,trig_type_v,status_v, trig_procedure_v,when_clause_v,description_v,trig_code_v;
    exit when c1%NOTFOUND;

    insert into system.wm$udtrig_info values(trig_owner_name_v,trig_name_v,table_owner_name_v,table_name_v,trig_type_v,status_v, trig_procedure_v,when_clause_v,description_v,trig_code_v);
  end loop;
  close c1;

end;
/
insert into sys.wm$udtrig_dispatch_procs select * from wmsys.wm$udtrig_dispatch_procs;
insert into system.wm$lockrows_info select * from wmsys.wm$lockrows_info;
update wmsys.wm$versioned_tables set disabling_ver = 'NO';
commit;
drop sequence sys.wm$up_del_trig_name_sequence;
drop sequence sys.wm$insteadof_trigs_sequence;
drop sequence sys.wm$lock_sequence;
drop sequence sys.wm$vtid;
drop sequence sys.wm$adt_sequence;
drop sequence sys.wm$version_sequence;
drop sequence sys.wm$row_sync_id_sequence;
drop sequence sys.wm$udtrig_dispatcher_sequence;
Declare
 val integer;
Begin

 select wmsys.wm$up_del_trig_name_sequence.nextval into val from dual; 
 execute immediate 'create sequence sys.wm$up_del_trig_name_sequence start with ' || val;

 select wmsys.wm$insteadof_trigs_sequence.nextval into val from dual; 
 execute immediate 'create sequence sys.wm$insteadof_trigs_sequence start with ' || val;

 select wmsys.wm$lock_sequence.nextval into val from dual; 
 execute immediate 'create sequence sys.wm$lock_sequence start with ' || val;

 select wmsys.wm$vtid.nextval into val from dual; 
 execute immediate 'create sequence sys.wm$vtid start with ' || val;

 select wmsys.wm$adt_sequence.nextval into val from dual; 
 execute immediate 'create sequence sys.wm$adt_sequence start with ' || val;

 select wmsys.wm$version_sequence.nextval into val from dual; 
 execute immediate 'create sequence sys.wm$version_sequence start with ' || val;

 select wmsys.wm$row_sync_id_sequence.nextval into val from dual; 
 execute immediate 'create sequence sys.wm$row_sync_id_sequence start with ' || val;

 select wmsys.wm$udtrig_dispatcher_sequence.nextval into val from dual; 
 execute immediate 'create sequence sys.wm$udtrig_dispatcher_sequence start with ' || val;

End;
/
drop user wmsys cascade;
update wm_downgrade_tables set hist = 'VIEW_WO_OVERWRITE' where hist = 'VIEW_WO_OVERWRITE_PERF';
commit;
create table wm_downgrade_tables_temp as select * from wm_downgrade_tables ;
declare
  l_owner             varchar2(30);
  l_table_name        varchar2(30);
  l_hist              varchar2(30);
  l_pkey_cols         varchar2(4000);
  l_pkey_cols_lt      varchar2(4100);

  l_trig_name         varchar2(40);

  vtid_var            integer;

  found               integer;
  error_flag          boolean := false;

  err_num             number;
  err_msg             varchar2(200);

  colname             varchar2(100);
  pkcols              varchar2(1000);

  l_constraint_name   varchar2(30);

  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);

  cursor vertab_cur is
    select owner, table_name, hist, pkey_cols
    from wm_downgrade_tables_temp
    where status = 'DONE_PRE_DOWNGRADE' order by id desc;

begin
     dbms_utility.db_version(version_str,compatibility_str);
     version_str := sys.wm$convertDbVersion(version_str);

     if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
       purgeOption := ' PURGE' ;
     end if ;

     open vertab_cur;
     loop
       fetch vertab_cur into l_owner, l_table_name, l_hist, l_pkey_cols;
       EXIT WHEN vertab_cur%NOTFOUND;

       begin
         
         update wm_downgrade_tables set status = 'POST_ERROR_ENABLE_VERSIONING' where owner = l_owner and table_name = l_table_name;
         dbms_wm.enableVersioning(l_owner || '.' || l_table_name, l_hist); 

         sys.lt_expadm_pkg.DisableSystemTriggers ;

         
         update wm_downgrade_tables set status = 'POST_ERROR_COPYING_AUX_TABLES' where owner = l_owner and table_name = l_table_name;
         execute immediate 'insert into ' || l_owner || '.' || l_table_name || '_AUX select * from ' || l_owner || '.' || l_table_name || '_AU$';
         execute immediate 'drop table ' || l_owner || '.' || l_table_name || '_AU$' || purgeOption;


                    
         update wm_downgrade_tables set status = 'POST_ERROR_RENAMING_LT' where owner = l_owner and table_name = l_table_name;
         execute immediate 'drop table ' || l_owner || '.' || l_table_name || '_LT' || purgeOption;
         execute immediate 'alter index ' || l_owner || '.' || l_table_name || '_P$ rename to ' || l_table_name || '_PKI$';
         execute immediate 'create or replace procedure ' || l_owner || '.' || l_table_name || '_R$ is
                            begin  
                              execute immediate ''rename ' || l_table_name || '_L$ to ' || l_table_name || '_LT''; 
                            end;' ;
         execute immediate 'begin ' || l_owner || '.' || l_table_name || '_R$; end;' ;
         execute immediate 'drop procedure ' || l_owner || '.' || l_table_name || '_R$' ;


           
         if(l_hist = 'VIEW_WO_OVERWRITE') then
           update wm_downgrade_tables set status = 'POST_ERROR_RECREATING_PK_CONSTRAINT' where owner = l_owner and table_name = l_table_name;
           select constraint_name into l_constraint_name from dba_constraints 
             where owner = l_owner and table_name = l_table_name || '_LT' and constraint_type = 'P';

           
           execute immediate 'alter table ' || l_owner || '.' || l_table_name || '_LT drop constraint ' || l_constraint_name ;

           select count(*) into found
           from dba_indexes 
           where table_owner = l_owner and
                 index_name  = l_constraint_name ;

           if (found>0) then
             execute immediate 'drop index ' || l_owner || '.' || l_constraint_name ;
           end if ;

           l_pkey_cols_lt := 'VERSION,' || l_pkey_cols || ',CREATETIME,DELSTATUS'; 

           
           execute immediate 'alter table ' || l_owner || '.' || l_table_name || '_LT add constraint ' 
                 || l_constraint_name || ' PRIMARY KEY (' || l_pkey_cols_lt || ')';
         end if;


         
         update wm_downgrade_tables set status = 'POST_ERROR_COPYING_MODIFIED_TABLES' where owner = l_owner and table_name = l_table_name;
         select vtid into vtid_var from wm$versioned_tables where owner = l_owner and table_name = l_table_name;
         execute immediate 'insert into wm$modified_tables select ' || vtid_var || ',table_name,version,workspace from wm$modified_tables$ where table_name = ''' || l_owner || '.' || l_table_name || ''' and version != 0';
         delete from wm$modified_tables$ where table_name = l_owner || '.' || l_table_name ;

         
         update wm_downgrade_tables set status = 'POST_ERROR_RECOMPILING_THE_TRIGGERS' where owner = l_owner and table_name = l_table_name;
         select insert_trig_name into l_trig_name from wm$insteadof_trigs_table where table_owner = l_owner and table_name = l_table_name;
         execute immediate 'alter trigger ' || l_owner || '.' || l_trig_name || ' compile' ;
         select update_trig_name into l_trig_name from wm$insteadof_trigs_table where table_owner = l_owner and table_name = l_table_name;
         execute immediate 'alter trigger ' || l_owner || '.' || l_trig_name || ' compile' ;
         select delete_trig_name into l_trig_name from wm$insteadof_trigs_table where table_owner = l_owner and table_name = l_table_name;
         execute immediate 'alter trigger ' || l_owner || '.' || l_trig_name || ' compile' ;

         
         update wm$versioned_tables set disabling_ver = 'NO' 
           where owner = l_owner and table_name = l_table_name;

         delete from wm_downgrade_tables where owner = l_owner and table_name = l_table_name;

         
         commit;
  
       exception 
         when others then 
           begin
            err_num := SQLCODE;
            err_msg := substr(SQLERRM,1,200);
	    error_flag := true;
            update wm_downgrade_tables set error_msg = err_msg 
              where owner = l_owner and table_name = l_table_name;
            commit;
           end;
       end;
     end loop;
     close vertab_cur;


   if(error_flag) then
     
     RAISE_application_error(-20000, 'Atleast one table failed during Re-EnableVersioning
Select from sys.wm_downgrade_tables to get the tables and error message');
   end if;

end;
/
declare
  idummy             integer ;

  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := sys.wm$convertDbVersion(version_str);

  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
    purgeOption := ' PURGE' ;
  end if ;

  begin
    select 1 into idummy from dual where exists (select 1 from wm_downgrade_tables) ;
  exception when no_data_found then
    execute immediate 'drop table wm_downgrade_tables' || purgeOption;
  end;
end;
/
declare
  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := sys.wm$convertDbVersion(version_str);

  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
    purgeOption := ' PURGE' ;
  end if ;
  
  execute immediate 'drop table wm_downgrade_tables_temp' || purgeOption;
end;
/
Declare
    delTrigCode varchar2(32000);
    updTrigCode varchar2(32000);

    cursor ricPtTrigCur is 
    select * 
    from sys.wm$ric_triggers_table
    where not exists
      ( select 1 from sys.wm$versioned_tables
        where owner = pt_owner
          and (table_name = pt_name or
               table_name || '_LT' = pt_name)
      ) ;

Begin
    for ricPtTrigCurRec in ricPtTrigCur loop
       sys.ltric.getPtBeforeTrigStrs(ricPtTrigCurRec.ct_owner,
                                     ricPtTrigCurRec.ct_name, 
                                     ricPtTrigCurRec.pt_owner,
                                     ricPtTrigCurRec.pt_name,
                                     ricPtTrigCurRec.update_trigger_name,
                                     updTrigCode,
                                     ricPtTrigCurRec.delete_trigger_name,
                                     delTrigCode);

       execute immediate delTrigCode;
       execute immediate updTrigCode;
    end loop;
End;
/
declare
 found integer;
begin
   begin
     select 1 into found from dual where exists (select 1 from wm$versioned_tables);
     sys.lt_expadm_pkg.enableSystemTriggers;
   exception
     when no_data_found then null;
     when others then raise;
   end;
end;
/
insert into wm$modified_tables select * from wm$modified_tables$;
commit;
declare
  purgeOption        varchar2(30) := null ;
  version_str        varchar2(50);
  compatibility_str  varchar2(50);
begin
  dbms_utility.db_version(version_str,compatibility_str);
  version_str := sys.wm$convertDbVersion(version_str);

  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.0.0.0.0', 'nls_sort=ascii7')) then
    purgeOption := ' PURGE' ;
  end if ;
  
  execute immediate 'drop table wm$modified_tables$' || purgeOption;
end;
/
drop procedure wm$execSQLIgnoreError;
declare
 sql_str varchar2(1000);
 env_vars_table varchar2(61) := null;
 release_ver  varchar2(50);
 cnt   integer;

 table_not_exists EXCEPTION;
 PRAGMA EXCEPTION_INIT(table_not_exists, -00942);
begin

  
 select count(*) into cnt from dba_tables where owner = 'WMSYS' and table_name = 'WM$ENV_VARS';
 if(cnt = 1) 
 then 
   env_vars_table := 'WMSYS.WM$ENV_VARS';
 else
   select count(*) into cnt from dba_tables where owner = 'SYSTEM' and table_name = 'WM$ENV_VARS';
   if(cnt = 1) then  
     env_vars_table := 'SYSTEM.WM$ENV_VARS';
   else
     execute immediate 'create or replace view sys.wm_installation as select ''OWM_VERSION'' name, ''NOT_INSTALLED'' value from dual';
   end if;
 end if;

 if(env_vars_table is not null) then
   
   sql_str := 'create or replace view sys.wm_installation as select * from ' || env_vars_table;
   
   
   execute immediate 'select count(*) from ' || env_vars_table || ' where name = ''OWM_VERSION''' into cnt; 
   if(cnt = 0) then
     
     select count(*) into cnt from dba_tables where owner = 'SYSTEM' and table_name = 'WM$LOCKROWS_INFO';
     if(cnt = 1) 
     then 
       release_ver := '9.0.1.0.0'; 
     else
       release_ver := 'BETA RELEASE'; 
     end if;
    
     
     sql_str := sql_str || ' union select ''OWM_VERSION'',''' || release_ver || ''' from dual'; 
   end if;
  
  
   sql_str := sql_str || ' union 
    select ''IMPORT_ALLOWED'',''NO'' from dual where exists (select 1 from all_version_hview
    where version != 0)  OR exists (select 1 from dba_wm_versioned_tables)
    union 
    select ''IMPORT_ALLOWED'',''YES'' from dual where not (exists (select 1 from all_version_hview
    where version != 0)  OR exists (select 1 from dba_wm_versioned_tables))' ;

    
    begin
      execute immediate 'select 1 from dual where exists
       (select 1 from wmsys.wm$sysparam_all_values)' into cnt ;

      sql_str := sql_str || ' union 
       select name,value from wmsys.wm$sysparam_all_values sv where isdefault = ''YES'' and
         not exists (select 1 from wmsys.wm$env_vars ev where ev.name = sv.name) ' ;
    exception when table_not_exists then null;
    end ;
    
   execute immediate sql_str || ' WITH READ ONLY';
 end if;
  
end;
/
grant select on sys.wm_installation to public with grant option;
create public synonym wm_installation for sys.wm_installation;
drop function sys.wm$convertDbVersion ;
