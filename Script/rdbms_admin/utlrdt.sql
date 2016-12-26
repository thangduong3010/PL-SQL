Rem Copyright (c) 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      utlrdt.sql - Recompile DDL triggers while still in UPGRADE mode
Rem
Rem    DESCRIPTION
Rem      This script recompiles all DDL triggers in UPGRADE mode at the
Rem      end of one of three operations:
Rem      1. DB upgrade
Rem      2. utlirp to invalidate and recompile all PL/SQL
Rem      3. dbmsupgnv/dbmsupgin to convert PL/SQL to native/interpreted
Rem
Rem    NOTES
Rem      Two DDL triggers referencing the same external object (e.g.,
Rem      ORA_SYSEVENT) cannot be recompiled successfully in regular mode.
Rem      Here is the sequence of events causing a failure:
Rem      1. DDL is executed
Rem      2. Trigger 1 needs to be fired, is invalid and gets recompiled
Rem      3. Trigger 1 references ORA_SYSEVENT 
Rem      4. ORA_SYSEVENT is invalid and gets recompiled using ALTER COMPILE
Rem      5. Before COMMIT, ALTER COMPILE fires DDL trigger 2
Rem      6. Trigger 2 references ORA_SYSEVENT. Because ORA_SYSEVENT is
Rem         being recompiled, PLS-201 is raised and trigger 2 compiles
Rem         with errors.
Rem      7. Trigger 2 compiled with errors causes all subsequent DDLs to fail.
Rem 
Rem      [5476415] I've observed a self-deadlock brought on by the existence (in
Rem      my testing environment) of certain system triggers.  While such
Rem      triggers do not exist today, to forestall any problems when we do have
Rem      such triggers, we'll pre-compile the ORA_* synonyms here.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jmuller     10/17/06 - Fix bug 5476415: avoid self-deadlock in utlrp
Rem    gviswana    03/09/06 - Created
Rem

SET ECHO ON

declare
   cursor ora_dict_synonyms is
      select o.object_id from dba_objects o
       where o.owner = 'PUBLIC'
         and o.object_type = 'SYNONYM'
         and o.object_name like 'ORA_%';

   cursor ddl_triggers is
      select o.object_id from dba_triggers t, dba_objects o
       where t.owner = o.owner and t.trigger_name = o.object_name
         and o.object_type = 'TRIGGER'
         and (t.triggering_event like '%ALTER%' or
              t.triggering_event like '%DDL%');
begin
   for s in ora_dict_synonyms loop
      dbms_utility.validate(s.object_id);
   end loop;

   for t in ddl_triggers loop
      dbms_utility.validate(t.object_id);
   end loop;
end;
/
