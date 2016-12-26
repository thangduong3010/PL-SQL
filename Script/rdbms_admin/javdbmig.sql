Rem
Rem $Header: javdbmig.sql 11-dec-2007.07:02:18 gssmith Exp $
Rem
Rem javdbmig.sql
Rem
Rem Copyright (c) 2001, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      javdbmig.sql - CATalog DataBase MIGration script
Rem
Rem    DESCRIPTION
Rem      This script upgrades the RDBMS java classes
Rem
Rem    NOTES
Rem      It is invoked by the cmpdbmig.sql script after JAVAVM 
Rem      has been upgraded.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gssmith     12/11/07 - Fix bug 6445932
Rem    gssmith     02/12/07 - Remove Summary Advisor objects
Rem    cdilling    11/10/05 - remove 817 and 901 code 
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      11/12/02 - use dbms_registry.check_server_instance
Rem    rburns      03/30/02 - restructure queries
Rem    rburns      01/12/02 - Merged rburns_catjava
Rem    rburns      12/18/01 - Created
Rem

Rem *************************************************************************
Rem Check instance version and status; set session attributes
Rem *************************************************************************

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

Rem *************************************************************************
Rem Remove obsolete Summary Advisor java classes
Rem *************************************************************************

declare
  cursor cur1 is
  select owner, nvl(longname, object_name) from
       dba_objects, javasnm
       where object_type='JAVA CLASS' and
             short(+)=object_name and
             nvl(longname, object_name) like 'oracle/qsma/%'; 
  l_owner varchar2(30);
  l_name varchar2(4000);
  l_buf varchar2(4000);
  l_restart boolean;
begin
  ------------------------------------------------------------------------------
  --  We do the outer loop just in case we get a 'snapshot too old' error.
  ------------------------------------------------------------------------------
  loop
    open cur1;

    l_restart := FALSE;

    loop
      fetch cur1 into l_owner, l_name;
      exit when cur1%notfound;
  
      l_buf := 'DROP JAVA CLASS ' || l_owner || '."' ||
               l_name || '"';
  
      begin
        execute immediate l_buf;
      exception
        when others then
          if sqlcode = -1555 then
            l_restart := TRUE;
            exit;
          end if;
      end;
    end loop;
  
    close cur1;

    exit when not l_restart;
  end loop;
end;
/

Rem *************************************************************************
Rem Reload current version of Java Classes
Rem *************************************************************************

@@catjava
