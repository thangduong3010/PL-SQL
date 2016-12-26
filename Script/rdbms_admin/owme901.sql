Rem
Rem $Header: ovm/src/server/ovme901.sql /st_ovm_11.2.0/1 2012/02/06 13:57:15 bspeckha Exp $
Rem
Rem ovme901.sql
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ovme901.sql - Downgrade script run in new server. This is
Rem    invoked by RDBMSs f0900010.sql while downgrading to 901
Rem    release
Rem
Rem    DESCRIPTION
Rem      This is run before RDBMS downgrade. For only OWM downgrade,
Rem    its invoked by owmd901
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bspeckha    02/06/12 - Backport bspeckha_bug-9981198 from main
Rem    bspeckha    12/05/07 - drop dbms_registry validate procedures
Rem    bspeckha    11/08/07 - use nls_sort=ascii7 when comparing version strings
Rem    bspeckha    01/26/07 - downgrade pk index
Rem    bspeckha    10/24/06 - moving everything to wmsys
Rem    bspeckha    11/19/03 - move convertDbVersion 
Rem    bspeckha    03/21/03 - dont filter wm_ columns
Rem    bspeckha    01/30/03 - group by in 817 cant use parentheses when using multiple columns
Rem    bspeckha    01/28/03 - drop types use in ltadm
Rem    bspeckha    11/06/02 - filter out all columns starting with WM$ or WM_
Rem    saagarwa    09/30/02 - MOve moveWMMetadata to before calling r script
Rem    rachatte    09/19/02 - move to system tablespace 
Rem    rachatte    08/09/02 - downgrade history columns before disablversioning
Rem    saagarwa    07/29/02 - Create proc in wmsys to grant privs
Rem    saagarwa    07/26/02 - Copy insertion of sentinels in this file for 901
Rem    saagarwa    06/24/02 - Store versioned_tables column in temp table before downgrading to 901
Rem    saagarwa    06/13/02 - saagarwa_fix_upgrade_downgrade_bugs
Rem    saagarwa    06/12/02 - Fix implicit savepoint bug
Rem    saagarwa    04/19/02 - Convert db_version for comparison
Rem    saagarwa    04/22/02 - Copy only required columns of _aux tables for downgrade
Rem    saagarwa    03/29/02 - saagarwa_split_downgrade_scripts_into_e_and_o
Rem    saagarwa    03/29/02 - Created
Rem

/* --------------------------------------------------------------------- */
/* Create procedure in wmsys schema for grating privs, etc.              */
/* --------------------------------------------------------------------- */
create or replace procedure wmsys.wm$execSQL(sqlstr varchar2) as
begin
  execute immediate sqlstr;
end;
/

/* 
 * Call dbms_registry.downgrade This is always the first call in Downgrade.
 */
declare
  version_str             varchar2(1000) := '';
  compatibility_str       varchar2(1000) := '';
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := wmsys.wm$convertDbVersion(version_str);

   if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
     execute immediate 'begin dbms_registry.downgrading(''OWM''); end;' ;
   end if;
end;
/

/*
 * Re-insert sentinel rows and de-populate ltlock columns
 * ======================================================
 */
create or replace function wm$getNullInsStr( schema varchar2, tab_name varchar2 ) return varchar2 is
  l_column_name  varchar2(40);
  null_str       varchar2(32000);
  found          integer;
  defaultValue   long;

  cursor col_info_cur is 
    select column_name 
    from all_tab_columns
    where owner = schema and 
          table_name = tab_name || '_LT' and
          column_name not in(select column_name
                             from wmsys.wm$nested_columns_table
                             where owner = schema and 
                             table_name = tab_name) and
          column_name not in ('VERSION','CREATETIME','RETIRETIME','NEXTVER','DELSTATUS','LTLOCK') and
          column_name not like 'WM$%'
    order by column_id;

begin

    open col_info_cur;
    fetch col_info_cur into l_column_name;
    loop
      begin  
        select 1 into found from dual where exists (
          select 1 from all_cons_columns where owner = schema and 
          table_name = tab_name || '_LT' and 
          instr('"'||column_name||'"','"'||l_column_name||'"') > 0 ) ; 


          select data_default into defaultValue
          from   dba_tab_columns
          where  owner = schema and 
                table_name = tab_name || '_LT'  
                and column_name = upper(l_column_name); 

          null_str := null_str  || l_column_name;

      exception when no_data_found then
        select count(*) into found 
        from   dba_part_key_columns 
        where  owner = schema  and 
               name = tab_name || '_LT' and 
               instr(object_type, 'TABLE') > 0              and 
               column_name = l_column_name;

        if (found > 0) then
           -- partition key
             select data_default into defaultValue
             from   dba_tab_columns
             where  owner = schema and 
                   table_name = tab_name || '_LT'  
                   and column_name = upper(l_column_name); 

             null_str := null_str || l_column_name;
        else
           null_str := null_str || 'null';
        end if;
      end ;

      fetch col_info_cur into l_column_name;
      exit when col_info_cur%NOTFOUND;

      null_str := null_str || ',';
    end loop;

    return null_str ;
end;
/

create or replace function wm$getWhereClauseStr( str varchar2, prfx1 varchar2, prfx2 varchar2 ) return varchar2 is 
    retVal      varchar2(32000) := '';
    comma_pos   integer;
    col_width   integer;
    colname     varchar2(50);

begin

   comma_pos  := 1;
   col_width  := instr (str, ',', comma_pos, 1);

   loop
     col_width := col_width - comma_pos;
     colname   := substr (str, comma_pos, col_width);

     retVal := retVal || prfx1 || colname || ' = ' ||  prfx2 || colname;

     comma_pos := comma_pos + col_width +1;
     col_width  := instr (str, ',', comma_pos, 1);
     exit when col_width = 0;

     retVal := retVal || ' AND ';
   end loop;

   return retVal;

end;
/

create or replace procedure wm$Fixsentinelandltlock( schema varchar2, tab_name varchar2) is
 sql_string1 varchar2(8000) ;
 sql_string2 varchar2(8000) ;

 next_ver varchar2(50) ;
 version_var integer ;
 ltlock_var  varchar2(150) ;
 rowid_var   rowid ;

 type cursor_type is ref cursor ;
 c1 cursor_type ;
 c2 cursor_type ;

 keycols varchar2(4000) ;

 md_str  varchar2(4000) ;

 hist_var varchar2(100) ;
 where_clause_str varchar2(4000) ;

begin

 select pkey_cols, hist into keycols, hist_var 
 from wmsys.wm$versioned_tables 
 where owner = schema and table_name = tab_name ;

 where_clause_str := wm$getwhereclausestr(keycols || ',', 't1.', 't2.');

 sql_string1 := '
    select min(rowid) from ' || schema || '.' || tab_name || '_LT  
      where version > 0
      and ((' || keycols || ') not in 
           (select ' || keycols || ' from ' || schema || '.' || tab_name || '_LT 
            where version = 0 or version = -1)
          )
    group by ' || keycols ;


   open c1 for sql_string1 ;
   loop
     fetch c1 into rowid_var ;
     exit when c1%NOTFOUND ;
  
     sql_string2 := '
       select t1.version, t1.ltlock from ' || schema || '.' || tab_name || '_LT t1, ' || schema || '.' || tab_name || '_LT t2
          where substr(t1.ltlock, 
                       (instr(t1.ltlock, '','',
                            instr(t1.ltlock, ''*'',1,1) ,
                            2) + 1), 
                       (instr(t1.ltlock,''*'',1,2) - 
                        instr(t1.ltlock, '','', 
                             instr(t1.ltlock, ''*'',
                             1,1) ,2) - 1)
                    ) = ''-1''
       and t2.rowid = ''' || rowid_var || '''
       and ' || where_clause_str ;

     next_ver := ',' ;
     open c2 for sql_string2 ;
     loop
       fetch c2 into version_var, ltlock_var ;
       exit when c2%NOTFOUND ;
       next_ver := next_ver || version_var || ',' ;
     end loop;
     close c2 ;

     if(next_ver = ',') then 
       raise_application_error(-20000, 'Internal error while populating sentinel rows') ;
     end if ;

     if(ltlock_var is not null and instr(ltlock_var,'*') > 0) then
       ltlock_var := substr(ltlock_var,1,instr(ltlock_var,'@',1,2)) || substr(ltlock_var,instr(ltlock_var,'*',1,2)+1) ;
     end if;
 
     if(hist_var = 'NONE') then
       md_str := ',-1,''' || next_ver || ''',-9,''' || ltlock_var || '''' ;
     else
       md_str := ',-1,sysdate,null,''' || next_ver || ''',-9,''' || ltlock_var || '''' ;
     end if ;

     /* Insert sentinels
      */
     execute immediate 'insert into ' || schema || '.' || tab_name || '_LT 
       select ' || wm$getNullInsStr(schema, tab_name) || md_str || '
       from ' || schema || '.' || tab_name || '_LT where rowid = ''' || rowid_var || '''' ;

   end loop;
   close c1;


   /* Remove source-ver info from ltlock
    */
   execute immediate 'update ' || schema || '.' || tab_name || '_LT 
                      set ltlock = substr(ltlock,1,instr(ltlock,''@'',1,2)) || substr(ltlock,instr(ltlock,''*'',1,2)+1)
                      where (ltlock is not null and instr(ltlock,''*'',1,1) > 0) 
                      and version >= 0';
   commit ;
end ;
/


declare
 owner_var      varchar2(30) ;
 table_name_var varchar2(30) ;

 cursor c1 is
   select owner, table_name
   from wmsys.wm$versioned_tables ;
begin
  open c1;
  loop
    fetch c1 into owner_var, table_name_var ;
    exit when c1%NOTFOUND ;

    wm$Fixsentinelandltlock(owner_var, table_name_var) ;

  end loop;
  close c1;
end;
/

drop function wm$getNullInsStr ;
drop function wm$getWhereClauseStr ;
drop procedure wm$Fixsentinelandltlock ;

-- ################################################################
-- Rollback the Architectural changes after 9013
-- ################################################################

/* --------------------------------------------------------------------- */
/* Fix CR workspaces to hang off latest version in parent-workspace      */
/* --------------------------------------------------------------------- */
execute wmsys.owm_mig_pkg.RollbackFixCrWorkspaces ;

/* --------------------------------------------------------------------- */
/* Fix the version number of sentinel rows                               */
/* --------------------------------------------------------------------- */
execute wmsys.owm_mig_pkg.AllRollbackFixSentinelVersion ;

-- ################################################################
-- Downgrade tables, packages, metadata
-- ################################################################

/* Store modified_tables in a temp table because it will get blown away
 * when we temporary verion-disable the tables.
 */
create table wm$modified_tables$ as select * from wmsys.wm$modified_tables;


-- ################################################################
-- Disable System Triggers to allow Temporary DisableVersioning
-- ################################################################
execute wmsys.ltadm.disableSystemTriggers_exp ;

/* --------------------------------------------------------------------- */
/* Temporary Disable Version the tables without blowing the data.        */
/* ----------------------------------------------------------------------*/

create table wm_downgrade_tables ( 
id          integer primary key,
owner       varchar2(30), 
table_name  varchar2(30), 
hist        varchar2(50) default 'NONE',      /* history option */
pkey_cols   varchar2(4000),
status      varchar2(100),
error_msg   varchar2(200),
constraint wm_downgrade_tables_unq unique (owner,table_name)
);

-- downgrade history columns
execute wmsys.owm_mig_pkg.dgHistoryColumns_internal;

-- downgrade constraints
execute wmsys.owm_mig_pkg.dgPrimaryKeyIndex ;

-- call disableversioning on topology index tables
execute wmsys.owm_mig_pkg.disableversionTopoIndexTables ;

/*
 * Algorithm for temporary DisableVersioning without removing the data is as follows :
 * For each versioned tables -
 * 1. Rename _LT to _L$
 * 2. Rename _pki$ index to _p$ so that Re-EnableVersioning does not generate an error.
 * 3. create empty _LT table with same definition as original _LT.
 * 4. DisableVersion the table.
 * 5. Create PK constraint on the table (to allow EnableVersioning later).
 */

declare

  id_var              integer := 0;

  l_owner             varchar2(30);
  l_table_name        varchar2(30);
  l_hist              varchar2(50);
  l_pkey_cols         varchar2(4000);

  found               integer;
  error_flag          boolean := false;

  err_num             number;
  err_msg             varchar2(200);

  colname             varchar2(100);
  pkcols              varchar2(1000);

  cname               varchar2(50);

  cursor vertab_cur is select owner, table_name, hist, pkey_cols from wmsys.wm$versioned_tables 
    where disabling_ver = 'VERSIONED' order by ricweight;

begin

     open vertab_cur;
     loop
       fetch vertab_cur into l_owner, l_table_name, l_hist, l_pkey_cols;
       EXIT WHEN vertab_cur%NOTFOUND;

       begin

         /* update state for the tables being downgraded. Also allows to bypass the
          * no_vm_drop trigger.
          */
         insert into wm_downgrade_tables values(id_var, l_owner, l_table_name, l_hist, l_pkey_cols, 'PRE_ERROR_PRE_DISABLE_VERSIONING', null);
         id_var := id_var + 1;
         update wm_downgrade_tables set status = 'PRE_ERROR_RENAMING_LT_TO_L$' 
           where owner = l_owner and table_name = l_table_name;
  
         /* Do not exceed current length while renaming */
         execute immediate 'create or replace procedure ' || l_owner || '.' || l_table_name || '_R$ is
                            begin  
                              execute immediate ''rename ' || l_table_name || '_LT to ' || l_table_name || '_L$''; 
                            end;' ;
         execute immediate 'begin ' || l_owner || '.' || l_table_name || '_R$; end;' ;
         execute immediate 'drop procedure ' || l_owner || '.' || l_table_name || '_R$' ;
         execute immediate 'alter index ' || l_owner || '.' || l_table_name || '_PKI$ rename to ' || l_table_name || '_P$';
         execute immediate 'create table ' || l_owner || '.' || l_table_name || '_LT as select * from ' || l_owner 
                               || '.' || l_table_name || '_L$ where 1=2';

         /* Copy _aux table to _au$ */
         update wm_downgrade_tables set status = 'PRE_ERROR_COPYING_AUX_TABLE_TO_AU$' 
           where owner = l_owner and table_name = l_table_name;
         execute immediate 'create table ' || l_owner || '.' || l_table_name || '_AU$ as select ' || l_pkey_cols || ',childstate,parentstate,snapshotchild,versionchild,snapshotparent,versionparent,value from ' || l_owner || '.' || l_table_name || '_AUX';

         /* Disable Version the Empty _LT table */           
         update wm_downgrade_tables set status = 'PRE_ERROR_DISABLE_VERSIONING' where owner = l_owner and table_name = l_table_name;  
         delete from wmsys.wm$constraints_table where owner = l_owner and table_name = l_table_name ;
         commit ;

         -- This is needed for self_ric. During DisableVersioning the ric constraint is created on the
         -- non-versioned tables and foreign key should be primary key for the parent table. 
         execute immediate 'alter table ' || l_owner || '.' || l_table_name || '_LT add constraint ' 
                 || l_table_name || '_PK$ PRIMARY KEY (' || l_pkey_cols || ')';

         dbms_wm.disableVersioning(l_owner || '.' || l_table_name); 

         update wm_downgrade_tables set status = 'DONE_PRE_DOWNGRADE' where owner = l_owner and table_name = l_table_name;  

         commit;
           
       exception 
         when others then 
           begin
            err_num := SQLCODE;
            err_msg := substr(SQLERRM,1,200);
	    error_flag := true;
            update wm_downgrade_tables set error_msg = err_msg where owner = l_owner and table_name = l_table_name;  
           end;
       end;
     end loop;
     close vertab_cur;
   
   if(error_flag) then
     -- Raise an error if some table failed during migration
     WMSYS.WM_ERROR.RAISEERROR(WMSYS.LT.WM_ERROR_192_NO, err_msg);
   end if;

end;
/

/* --------------------------------------------------------------------- */
/* Drop things that might cause owminst to fail                          */
/* ----------------------------------------------------------------------*/

/* Create procedure in sys schema for executing sql with ignoring error. */
create or replace procedure wm$execSQLIgnoreError(sql_stmt varchar2) is
begin
 begin
   execute immediate sql_stmt;
 exception 
   when others then null;
 end;
end;
/

execute wmsys.owm_mig_pkg.moveWMMetaData('SYSTEM'); 

/* --------------------------------------------------------------------- */
/* Call owmr9013.plb to Rollback the metadate to 9013.                   */
/* Ideally we should have owmr901.plb but 901 release was a special case */
/* where we blow away the metadata user that existed in 9013, so there   */
/* is no incremental rollback needed from 9013 to 901.                   */
/* --------------------------------------------------------------------- */
@@owmr9013.plb

drop procedure sys.validate_owm ;
drop procedure wmsys.validate_owm ;

/* Rename the implicit sp names, so that they do not conflict with 901 release
 * while creating a child workspace.
 */
update wmsys.wm$workspace_savepoints_table set savepoint = savepoint || '-' || workspace
where is_implicit = 1;
commit;

/* store versioned_tables columns in temp table because 
 * wmsys.wm$unco_code_table_type doesn't compile in 9i.
 */ 
create table sys.wm$versioned_tables_tmp as select vtid,table_name,owner,notification,notifyWorkspaces,disabling_ver,ricWeight,isFastLive,isWorkflow,hist,pkey_cols from wmsys.wm$versioned_tables ; 

/* Drop packages added after 901 in SYS schema. Drop synonyms also  */
Begin

  /* Drop procs and trigs */
  wm$execSQLIgnoreError('drop procedure logon_proc');
  wm$execSQLIgnoreError('drop trigger sys_logon');    

  /* Drop packages */
  wm$execSQLIgnoreError('drop package owm_ddl_pkg');

  /* Drop Synonyms */
  wm$execSQLIgnoreError('drop public synonym all_wm_vt_errors');
  wm$execSQLIgnoreError('drop public synonym user_wm_vt_errors');
  wm$execSQLIgnoreError('drop public synonym wm_installation');
  wm$execSQLIgnoreError('drop public synonym wm$parvers_view');
  wm$execSQLIgnoreError('drop public synonym wm$versions_in_live_view');

  /* Drop SYS views */
  wm$execSQLIgnoreError('drop view wm_installation');

End;
/

/* drop all other public synonyms, because they will be re-created for tables,views in SYS schema */
  Declare
    t integer;
  Begin 

    wm$execSQLIgnoreError('drop public synonym all_workspaces_internal');
    wm$execSQLIgnoreError('drop public synonym all_version_hview');
    wm$execSQLIgnoreError('drop public synonym user_wm_privs');
    wm$execSQLIgnoreError('drop public synonym role_wm_privs');
    wm$execSQLIgnoreError('drop public synonym user_workspaces');
    wm$execSQLIgnoreError('drop public synonym all_workspaces');
    wm$execSQLIgnoreError('drop public synonym lt_workspace_tree');
    wm$execSQLIgnoreError('drop public synonym user_workspace_privs');
    wm$execSQLIgnoreError('drop public synonym all_workspace_privs');
    wm$execSQLIgnoreError('drop public synonym user_wm_versioned_tables');
    wm$execSQLIgnoreError('drop public synonym all_wm_versioned_tables');
    wm$execSQLIgnoreError('drop public synonym user_workspace_savepoints');
    wm$execSQLIgnoreError('drop public synonym all_workspace_savepoints');
    wm$execSQLIgnoreError('drop public synonym user_wm_modified_tables');
    wm$execSQLIgnoreError('drop public synonym all_wm_modified_tables');
    wm$execSQLIgnoreError('drop public synonym dba_workspace_sessions');
    wm$execSQLIgnoreError('drop public synonym user_wm_ric_info');
    wm$execSQLIgnoreError('drop public synonym all_wm_ric_info');
    wm$execSQLIgnoreError('drop public synonym user_wm_tab_triggers');
    wm$execSQLIgnoreError('drop public synonym all_wm_tab_triggers');
    wm$execSQLIgnoreError('drop public synonym all_wm_locked_tables');
    wm$execSQLIgnoreError('drop public synonym user_wm_locked_tables');
    wm$execSQLIgnoreError('drop public synonym dba_workspaces');
    wm$execSQLIgnoreError('drop public synonym dba_workspace_savepoints');
    wm$execSQLIgnoreError('drop public synonym dba_wm_versioned_tables');
    wm$execSQLIgnoreError('drop public synonym dba_workspace_privs');
    wm$execSQLIgnoreError('drop public synonym dba_wm_sys_privs');
  
    wm$execSQLIgnoreError('drop public synonym wm$current_parvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_nextvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$curConflict_parvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$curConflict_nextvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$parConflict_parvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$parConflict_nextvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_workspace_view');
    wm$execSQLIgnoreError('drop public synonym wm$parent_workspace_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$parent_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$curConflict_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$parConflict_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_savepoints_view');
    wm$execSQLIgnoreError('drop public synonym wm$diff1_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$diff2_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$base_hierarchy_view');
    wm$execSQLIgnoreError('drop public synonym wm$diff1_nextver_view');
    wm$execSQLIgnoreError('drop public synonym wm$diff2_nextver_view');
    wm$execSQLIgnoreError('drop public synonym wm$base_nextver_view');
    wm$execSQLIgnoreError('drop public synonym wm$current_ver_view');
    wm$execSQLIgnoreError('drop public synonym wm$ver_bef_inst_parvers_view');
    wm$execSQLIgnoreError('drop public synonym wm$ver_bef_inst_nextvers_view');

    wm$execSQLIgnoreError('drop role wm_admin_role');

    wm$execSQLIgnoreError('drop procedure logoff_proc');

    wm$execSQLIgnoreError('drop trigger sys_logoff');    

    wm$execSQLIgnoreError('drop public synonym DBMS_WM');

    -- Drop objects that did not exist in the 901 release
    wm$execSQLIgnoreError('drop type wmsys.oper_lockvalues_array_type') ;
    wm$execSQLIgnoreError('drop type wmsys.oper_lockvalues_type') ;
    wm$execSQLIgnoreError('drop type wmsys.IntToStr_array_type') ;
    wm$execSQLIgnoreError('drop type wmsys.trigOptionsType') ;

    -- delete the entry from exppkgact$ which tells export the package to
    -- invoke system procedural actions from.
    delete from sys.exppkgact$ 
    where package = 'LT_EXPORT_PKG' and
          schema = 'SYS';
    commit;
  
End;
/

/* 
 * Update the registry. This should always be the last step.
 */
declare
  version_str             varchar2(100)  := '';
  compatibility_str       varchar2(100)  := '';
  cnt                     integer        := 0 ;
  ver                     varchar2(100)  := null;
begin
   dbms_utility.db_version(version_str,compatibility_str);
   version_str := sys.wm$convertDbVersion(version_str);

   if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('9.2.0.0.0', 'nls_sort=ascii7')) then
       execute immediate 'begin dbms_registry.loading(''OWM'',''Oracle Workspace Manager'',NULL,''SYS''); end;' ;
       execute immediate 'begin dbms_registry.downgraded(''OWM'',''9.0.1.0.0''); end;' ;
   end if;
end;
/
