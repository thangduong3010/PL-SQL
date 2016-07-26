Rem
Rem $Header: rdbms/admin/wkremov.sql /main/2 2008/10/07 13:29:23 bmccarth Exp $
Rem
Rem wk0deinst_noarg.sql
Rem
Rem Copyright (c) 2008, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      wk0deinst_noarg.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This is a script to drop Ultra Search schema. This is 
Rem      a copy of wk0deinst.sql but there are two differences:
Rem       1) The script does not accept any parameter values
Rem          First, the user has to connect as SYS user and 
Rem          run the script.
Rem       2) After executing the script, quit SQL*Plus.
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bmccarth    10/02/08 - put check in to catch non-exist objects
Rem    cdilling    07/30/08 - Moving this file to rdbms/admin for hkoide -
Rem                           for 11.2 there will be no ultra search directory
Rem    hkoide      07/09/08 - Deinstall script when DB connection is already
Rem                           established
Rem    hkoide      07/09/08 - Created
Rem

PROMPT ==============  Ultra Search Deinstallation ==============
PROMPT

set heading on
whenever sqlerror continue;

declare
  drop_context EXCEPTION;
  PRAGMA EXCEPTION_INIT(drop_context, -04043);
begin
   execute immediate 'drop context wk$context' ;

exception when drop_context then 
  null;
end;
/


declare
  drop_context EXCEPTION;
  PRAGMA EXCEPTION_INIT(drop_context, -04043);
begin
   execute immediate 'drop context wk$ctx_ldap' ;

exception when drop_context then 
  null;
end;
/

drop user wksys cascade;

drop role wkuser; 

drop user wkproxy cascade;

drop user wk_test cascade;

PROMPT Clean up interMedia Text dictionary
begin
  ctxsys.ctx_adm.recover;
end;
/

prompt Drop public synonyms
begin
  for s in (select synonym_name from all_synonyms where table_owner = 'WKSYS') loop
    execute immediate 'drop public synonym "'||s.synonym_name||'"';
  end loop;
end;
/

PROMPT Removing all XDB resources (ACLs and folders)
declare
  type t_cursor is ref cursor;
  l_cursor t_cursor;
  l_stmt VARCHAR2(4000);
  l_stmt2 VARCHAR2(4000);
  l_path varchar2(4000);
  l_result number := 0;
begin
 
  l_stmt := 'select count(*) from resource_view where any_path = ''/sys/apps/ultrasearch''';
  l_stmt2 := 'begin dbms_xdb.setacl(:1, :2); end;';
  begin
    execute immediate l_stmt into l_result; 
  exception 
    when others THEN
      l_result := 0;
  end;        

  if (l_result > 0) then
    -- Making sure all ACLs are not referenced
    l_stmt :=
    'select any_path from resource_view where ' ||
      ' UNDER_PATH(res, ''/sys/apps/ultrasearch'', 1) = 1' ||
      ' order by depth(1) desc';
    open l_cursor for l_stmt;
    loop
      fetch l_cursor into l_path;
      exit when l_cursor%NOTFOUND;
      execute immediate l_stmt2 using l_path, '/sys/acls/all_all_acl.xml';
      commit;
    end loop;
  
    -- Deleting all acls and folders
    l_stmt :=
      'select any_path from resource_view where ' ||
      ' UNDER_PATH(res, ''/sys/apps/ultrasearch'', 1) = 1' ||
      ' order by depth(1) desc';
    l_stmt2 := 'delete from resource_view where any_path = :1';
    open l_cursor for l_stmt;
    loop
      fetch l_cursor into l_path;
      exit when l_cursor%NOTFOUND;
      execute immediate l_stmt2 using l_path;
      commit;
    end loop;
  
    l_stmt2 := 'delete from resource_view where any_path = :1';
    execute immediate l_stmt2 using '/sys/apps/ultrasearch';
    execute immediate l_stmt2 using '/sys/apps/ultrasearch_acl.xml';
    commit;
  end if;
end;
/


