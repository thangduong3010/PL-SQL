create or replace procedure wm$execSQLIgnoreExceptions wrapped 
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
25d 179
iS3//rv8poxd22M7SEhfrct9NcAwg/DI7dxqfI4CWE6OHASjvRqg12eN+g1kJdXTBXHayNwc
5ed/UGZnUdDQhOc7PWYBA/9ysB4LWpnIKvv4I+1IKM08IonONAWdxLi0YSBPlvhVxhQRGUWX
LYDc4NfeIgERt0Z/oYMwapUAlqk1791Xd8UoSqiHw+RNQsN9G7A6/Z8Tyd5hdYuACe3FzDCY
zKN55QjdTTxSFzHgPxUyRun7IavOE7uWNAwS0ynTNHdw7SX/hNY88PuHTXNxU25i2rmensNr
dLLjg/tq5eH0ejRAs4R9KIisrvZpCLniXsNMp0J+xgv5t6vorcSWc3jyLagm1llhePSMRKdJ
DpE/gbLtY2sT

/
declare
  t integer;

  cursor syn_cur is
    select synonym_name
    from dba_synonyms
    where owner = 'PUBLIC' and
          table_owner='WMSYS' ;

  busy_resource EXCEPTION;
  PRAGMA EXCEPTION_INIT(busy_resource, -00054);

  vt_exists EXCEPTION;
  PRAGMA EXCEPTION_INIT(vt_exists, -20172);

begin
 







  begin
    lock table wmsys.wm$versioned_tables in exclusive mode nowait ;

    select count(*) into t
    from wmsys.wm$versioned_tables ;

    if (t > 0) then
      execute immediate 'begin WMSYS.WM_ERROR.RAISEERROR(wmsys.lt.WM_ERROR_172_NO); end;';
    end if;

  exception 
    when busy_resource then 
      begin 
        
        rollback; 
        raise;
      end;

    when vt_exists then
      begin 
        
        rollback;
        raise;
      end;

    when others then null;
  end;
    
  dbms_registry.removing('OWM');

  




  wm$execSQLIgnoreExceptions('drop public synonym DBMS_WM');

  
  wm$execSQLIgnoreExceptions('drop trigger wmsys.no_vm_ddl');
  wm$execSQLIgnoreExceptions('drop trigger wmsys.no_vm_drop_e');
  wm$execSQLIgnoreExceptions('drop trigger wmsys.no_vm_drop_a');

  
  for syn_rec in syn_cur loop
    wm$execSQLIgnoreExceptions('drop public synonym ' || syn_rec.synonym_name);
  end loop ;

  
  wm$execSQLIgnoreExceptions('drop context lt_ctx');
  wm$execSQLIgnoreExceptions('drop procedure sys.validate_owm') ;
  wm$execSQLIgnoreExceptions('drop role wm_admin_role');

  
  delete from sys.exppkgact$ 
  where package = 'LT_EXPORT_PKG'
    and schema = 'WMSYS' ;

  delete sys.impcalloutreg$
  where tag='WMSYS';
  commit;

exception when others then
  raise ;
end;
/
declare
  status_var varchar2(100) ;

  user_does_not_exist EXCEPTION;
  PRAGMA EXCEPTION_INIT(user_does_not_exist, -01918);
begin
  select status into status_var
  from dba_registry
  where comp_id = 'OWM' ;

  
  
  if (status_var = 'REMOVING') then
    execute immediate 'drop user wmsys cascade';
  end if ;

exception
  when user_does_not_exist then null;
  when no_data_found then null ;
end ;
/
drop procedure sys.wm$execSQLIgnoreExceptions ;
