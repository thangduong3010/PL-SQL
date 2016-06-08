CREATE OR REPLACE FUNCTION DEMOEBANKING.fn_get_err_msgs(
                            ierr_code in err_msgs.err_code%type,
                            ilang         in err_msgs.language%type,                           
                            iparam1    in varchar2 :=null,
                            iparam2    in varchar2 :=null,
                            iparam3    in varchar2 :=null)
return varchar2
is
v_message    err_msgs.message%type;

begin

--INTERFACE_LOG('ML',null,'plang='||plang||'perr_code='||perr_code);   

  select message into v_message 
  from err_msgs  
  where upper(err_code)=upper(ierr_code)
  and upper(language) =upper(ilang)
  ;
  
  if iparam1 is not null then
     v_message := replace(v_message,'{0}',iparam1);
  end if;
  if iparam2 is not null then
     v_message := replace(v_message,'{1}',iparam2);
  end if;
  if iparam3 is not null then
     v_message := replace(v_message,'{2}',iparam3);
  end if;
  
  return v_message;
  exception
  when no_data_found then 
     return ' Chua dinh nghia ma loi :'||upper(ierr_code);
       
  when others then
     return  sqlerrm;
      
end;
/