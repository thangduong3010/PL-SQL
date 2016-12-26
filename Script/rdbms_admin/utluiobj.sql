Rem
Rem $Header: rdbms/admin/utluiobj.sql /st_rdbms_11.2.0/1 2012/10/24 16:43:58 cdilling Exp $
Rem
Rem utluiobj.sql
Rem
Rem Copyright (c) 2007, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utluiobj.sql - UTility Upgrade Invalid OBJects Tool
Rem
Rem    DESCRIPTION
Rem      This script provides information about invalid objects after the 
Rem      upgrade. It outputs the difference between the invalid objects
Rem      that exist after the upgrade and invalid objects that existed 
Rem      prior to upgrade. 
Rem
Rem    NOTES
Rem      Run connected AS SYSDBA to the database that was upgraded
Rem      If there were more than 5000 non-system invalid objects then
Rem      there were too many invalid non-system objects to track. 
Rem     
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    10/18/12 - Backport cdilling_lrg-7029280 from
Rem    cdilling    12/13/07 - Created
Rem

SET SERVEROUTPUT ON

DECLARE
   type cursor_t  IS REF CURSOR;
   invobj_cursor     cursor_t;
   p_owner           VARCHAR2(30);
   p_obj_name        VARCHAR2(30);
   p_obj_type        VARCHAR2(30);
   no_such_table  EXCEPTION;
   PRAGMA exception_init(no_such_table, -942);

BEGIN
   --  Display the list of objects that are invalid after the upgrade
   --  but were not invalid prior to upgrade.
   --  registry$sys_inv_objs table is created by the pre-upgrade
   --  utility file (utlu111i.sql)
   DBMS_OUTPUT.PUT_LINE('.');
   DBMS_OUTPUT.PUT_LINE(
      'Oracle Database 11.2 Post-Upgrade Invalid Objects Tool ' ||
      TO_CHAR(SYSDATE, 'MM-DD-YYYY HH24:MI:SS'));
   DBMS_OUTPUT.PUT_LINE('.');
   DBMS_OUTPUT.PUT_LINE(
      'This tool lists post-upgrade invalid objects that were not invalid');
   DBMS_OUTPUT.PUT_LINE(
      'prior to upgrade (it ignores pre-existing pre-upgrade invalid objects).');
   DBMS_OUTPUT.PUT_LINE('.');
   DBMS_OUTPUT.PUT_LINE(
      LPAD('Owner', 32) || LPAD('Object Name',32) || LPAD('Object Type', 32));
   DBMS_OUTPUT.PUT_LINE('.');

   BEGIN
   OPEN invobj_cursor FOR 
     'select owner, object_name, object_type
	  from dba_objects 
          where status !=''VALID'' AND owner in (''SYS'',''SYSTEM'') 
     MINUS
     select owner, object_name, object_type 
	  from registry$sys_inv_objs 
     order by owner, object_name';
 
   LOOP
      FETCH invobj_cursor INTO p_owner, p_obj_name, p_obj_type;
      EXIT WHEN invobj_cursor%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(LPAD(p_owner, 32) || LPAD(p_obj_name, 32) || LPAD(p_obj_type, 32));      
   END LOOP;
   CLOSE invobj_cursor;
EXCEPTION 
    WHEN no_such_table THEN
       DBMS_OUTPUT.PUT_LINE(
       'The table registry$sys_inv_objs does not exist. The pre-upgrade tool,');
       DBMS_OUTPUT.PUT_LINE(
       'utlu111i.sql, creates and populates registry$sys_inv_objs. To use this');
       DBMS_OUTPUT.PUT_LINE(
       'post-upgrade tool, you must have run utlu111i.sql prior to upgrading');
       DBMS_OUTPUT.PUT_LINE(
       'the database. ');
   END;

   BEGIN
   OPEN invobj_cursor FOR 
     'select owner, object_name, object_type
	  from dba_objects 
          where status !=''VALID'' AND owner NOT in (''SYS'',''SYSTEM'') 
     MINUS
     select owner, object_name, object_type 
	  from registry$nonsys_inv_objs 
     order by owner, object_name';
   LOOP
      FETCH invobj_cursor INTO p_owner, p_obj_name, p_obj_type;
      EXIT WHEN invobj_cursor%NOTFOUND;
      DBMS_OUTPUT.PUT_LINE(LPAD(p_owner, 32) || LPAD(p_obj_name, 32) || LPAD(p_obj_type, 32));      
   END LOOP;
   CLOSE invobj_cursor;

EXCEPTION 
    WHEN no_such_table THEN NULL;
   END;

END;

/

SET SERVEROUTPUT OFF
