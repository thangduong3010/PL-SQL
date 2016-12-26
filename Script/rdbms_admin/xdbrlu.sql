Rem
Rem $Header: rdbms/admin/xdbrlu.sql /st_rdbms_11.2.0/2 2011/06/07 12:30:50 juding Exp $
Rem
Rem xdbrlu.sql
Rem
Rem Copyright (c) 2002, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbrlu.sql - Xml DB ReLoad Upgrade packages
Rem
Rem    DESCRIPTION
Rem      Replaces all XDB-related packages with the current versions.
Rem
Rem    NOTES
Rem      None
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    juding     05/26/11 - Backport badeoti_bug-10171737 from main
Rem    spetride   01/11/11 - Backport badeoti_bug-10096889 from main
Rem    badeoti    05/13/09 - 8503519: handle ORA-30552 during index re-enabling
Rem    badeoti    03/27/09 - 8328600: enable func-domain indexes
Rem    rburns     10/05/07 - move acl_xidx enable
Rem    mrafiq     10/12/05 - creating xdb$rclist view 
Rem    vkapoor    12/27/04 - vkapoor_lrg-1802906
Rem    vkapoor    12/16/04 - Creating new file for upgrade only scripts 
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

-- Some implementations have these operators defined, and some don't.
-- Regardless, they are unused in 9.2.0.2 and should be dropped.
begin
  execute immediate 'drop indextype xdb.path_index';
exception
  when others then
    commit;
end;
/
begin
  execute immediate 'drop operator xdb.xdbpi_noop';
exception
  when others then
    commit;
end;
/

Rem XDB$RCLIST view
--create view xdb.xdb$rclist_v as (select rclist from xdb.xdb$root_info);
declare
  c number;
begin
  select count(v.view_name) into c 
  from all_views v 
  where v.view_name = 'XDB$RCLIST_V';

  if c = 0 then
   execute immediate 'create view xdb.xdb$rclist_v as (select rclist from xdb.xdb$root_info)';
  end if;
end;
/
show errors;


Rem This is needed for users to be able to query the repository rclist
grant select on xdb.xdb$rclist_v to public;

Rem reload the DBMS_RESCONFIG package
@@dbmsxrc
@@prvtxrc.plb

Rem Reload the XML DB packages.  This is the main step.
@@dbmsxsch.sql
@@xdbptrl2.sql

Rem Clean up invalidated objects
@@xdbvlo.sql

--bug-8503519 re-enable all function-based indexes
--fix for lrg-3019679, bug-8328600 re-enable function-based indexes
--alter index xdb.xdb$acl_xidx enable;
set serveroutput on

COLUMN :xidxddl_name NEW_VALUE xidxddl_file NOPRINT
VARIABLE xidxddl_name VARCHAR2(50)

declare
  TYPE tab_char IS TABLE OF VARCHAR2(32767) INDEX BY BINARY_INTEGER;
  xdbindexes tab_char;
  cannot_change_obj exception;
  pragma exception_init(cannot_change_obj, -30552);
begin
  -- Select indices to be re-enabled
  EXECUTE IMMEDIATE q'+
    select '"XDB".' || dbms_assert.enquote_name(index_name)
      from dba_indexes
     where owner = 'XDB'
       and index_name like 'XDB%'
       and index_type like 'FUNCTION-BASED%'+'
  BULK COLLECT INTO xdbindexes;

  :xidxddl_name := 'NO';

  IF (xdbindexes.count() > 0) THEN
    FOR i IN 1 .. xdbindexes.count() LOOP
      BEGIN
        EXECUTE IMMEDIATE 'alter index ' || xdbindexes(i) || ' enable';
        dbms_output.put_line('Index ' || xdbindexes(i) || ' successfully re-enabled');
        
      EXCEPTION
        WHEN CANNOT_CHANGE_OBJ THEN
          if xdbindexes(i) like '%ACL_XIDX%' then 
            :xidxddl_name := 'YES';
          else  
            dbms_output.put_line('Warning: Index ' || xdbindexes(i) || 
                               ' could not be re-enabled and may need to be rebuilt');
          end if;
      END;
    END LOOP;
  END IF;
end;
/

-- drop acl indexes prior to re-create, if necessary
begin
  if :xidxddl_name = 'YES' then
    begin
      execute immediate 'drop index xdb.xdb$acl_xidx force';
      dbms_output.put_line('dropped acl_xidx');
      exception
        when OTHERS then
          if (SQLCODE = - 1418) then NULL;
          else dbms_output.put_line('Warning: error during acl_xidx drop' || sqlcode);
          end if;
    end;
    begin
      execute immediate 'drop index xdb.xdb$sp_xidx force';
      dbms_output.put_line('dropped sp_xidx');
      exception
        when OTHERS then
          if (SQLCODE = - 1418) then NULL;
          else dbms_output.put_line('Warning: error during sp_xidx drop' || sqlcode);
          end if;
    end;         
    :xidxddl_name := '@prvtxdz2.plb';
  else
    :xidxddl_name := '@nothing.sql';
  end if;
end;
/

select :xidxddl_name from dual;
@&xidxddl_file;

