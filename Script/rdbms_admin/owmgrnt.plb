declare
  found        integer := 0;
  version_str  varchar2(50) := wmsys.wm$getDbVersionStr ;
begin
  
  select count(*) into found 
  from all_triggers 
  where owner = 'WMSYS' and 
         trigger_name in ('NO_VM_DDL', 'NO_VM_DROP_A');

  if (found < 2) then 
    
    WMSYS.WM_ERROR.RAISEERROR(WMSYS.LT.WM_ERROR_99_NO);
  end if;   

  
  select count(*) into found 
  from all_errors 
  where owner = 'WMSYS' and 
        type  = 'TRIGGER' and
        name in ('NO_VM_DDL', 'NO_VM_DROP_A');

  if (found != 0) then 
    WMSYS.WM_ERROR.RAISEERROR(WMSYS.LT.WM_ERROR_99_NO);
  end if;
 
  
  

  
  if (nlssort(version_str, 'nls_sort=ascii7') >= nlssort('A.2.0.0.0', 'nls_sort=ascii7')) then
    wmsys.wm$execSQL('grant execute on wmsys.lt_ctx_pkg to public') ;
    wmsys.wm$execSQL('grant execute on wmsys.owm_vt_pkg to public') ;
  else
    wmsys.wm$execSQL('grant execute on wmsys.lt_ctx_pkg to public with grant option') ;
    wmsys.wm$execSQL('grant execute on wmsys.owm_vt_pkg to public with grant option') ;
  end if ;

  wmsys.wm$execSQL('grant execute on wmsys.lt to public') ;
  wmsys.wm$execSQL('grant execute on wmsys.wm_error to public') ;
  wmsys.wm$execSQL('grant execute on wmsys.lt_export_pkg to public') ;
  wmsys.wm$execSQL('grant execute on wmsys.ltadm to imp_full_database') ;

end;
/
execute wmsys.wm$execSQL('grant delete on wmsys.wm$workspaces_table to imp_full_database') ;
execute wmsys.wm$execSQL('grant delete on wmsys.wm$workspace_priv_table to imp_full_database') ;
execute wmsys.wm$execSQL('grant delete on wmsys.wm$version_hierarchy_table to imp_full_database') ;
declare
  obj_name  varchar2(30) ;

  cursor c1 is
    select object_name
    from dba_objects
    where owner = 'WMSYS'
      and status != 'VALID'
      and object_type = 'VIEW'
    order by created ;

  cursor c2 is
    select ds.synonym_name
    from dba_objects do, dba_synonyms ds
    where do.owner = 'PUBLIC'
      and do.status != 'VALID'
      and do.object_type = 'SYNONYM'
      and ds.owner = 'PUBLIC'
      and ds.synonym_name = do.object_name
      and ds.table_owner = 'WMSYS' ;

begin
  loop
    open c1 ;
    fetch c1 into obj_name ;
    exit when c1%NOTFOUND ;

    execute immediate 'alter view WMSYS.' || dbms_assert.simple_sql_name(obj_name) || ' compile' ;

    close c1 ;
  end loop;

  for c2_rec in c2 loop
    execute immediate 'alter public synonym ' || dbms_assert.simple_sql_name(c2_rec.synonym_name) || ' compile' ;
  end loop;
end;
/
drop procedure wmsys.wm$execSQL;
