@@owmcmdv.plb
create or replace function sys.wm$convertDbVersion wrapped 
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
grant execute on sys.wm$convertDBVersion to public;
column file_name new_value comp_file noprint;
var owm_script varchar2(30);
select * from wm_installation ;
declare
  found  integer ;

  no_col_exception EXCEPTION ;
  PRAGMA EXCEPTION_INIT(no_col_exception, -00904) ;

  no_tab_exception EXCEPTION ;
  PRAGMA EXCEPTION_INIT(no_tab_exception, -00942) ;

begin
  begin
    execute immediate 'select 1 from wm_installation where name=''OWM_VERSION'' and value=''NOT_INSTALLED''' into found;
    raise_application_error(-20000, 'Workspace Manager not installed.  Cannot upgrade.') ;

  exception
    when no_data_found then null ;
  end ;

  begin
    execute immediate 'select 1 from wmsys.wm$replication_table where status = ''E'' and rownum=1' into found ;
    raise_application_error(-20000, 'disable replication support before upgrading to a newer version') ;

  exception
    when no_data_found then null ;
    when no_col_exception then null ;
    when no_tab_exception then null ;
  end ;
end;
/
declare
 found        integer;
 owm_version  varchar2(100) ;

 no_tab_exception EXCEPTION ;
 PRAGMA EXCEPTION_INIT(no_tab_exception, -00942) ;
begin
   
  execute immediate 'select 1 from wmsys.wm$replication_table where status = ''E''' into found;
  :owm_script := 'nothing.sql';

exception when others then

  select sys.wm$convertDbVersion(value) into owm_version
  from wm_installation
  where name = 'OWM_VERSION';

  owm_version := nlssort(owm_version, 'nls_sort=ascii7') ;

  if (owm_version = nlssort('9.0.1.0.0', 'nls_sort=ascii7') or owm_version = nlssort('9.0.1.2.0', 'nls_sort=ascii7')) then
    :owm_script := 'owmu901.plb' ;

  elsif (owm_version = nlssort('9.0.1.3.0', 'nls_sort=ascii7')) then
    :owm_script := 'owmu9013.plb' ;

  elsif (1=1) then
    :owm_script := 'owmuany.plb' ;

  else
    :owm_script := 'nothing.sql' ;
  end if ;

  begin
    execute immediate 'select count(*) from wmsys.wm$versioned_tables where disabling_ver!=''VERSIONED''' into found ;

    if (found>0) then
      :owm_script := 'nothing.sql';
      raise_application_error(-20000, 'All versioned tables must have a ''VERSIONED'' status before upgrading.') ;
    end if ;

  exception when no_tab_exception then null ;
  end ;

end;
/
select :owm_script as file_name from dual ;
@@&comp_file
