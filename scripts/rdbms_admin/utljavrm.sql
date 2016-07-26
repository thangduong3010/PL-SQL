Rem
Rem $Header: utljavarm.sql 12-jan-99.17:10:39 rshaikh Exp $
Rem
Rem utljavarm.sql
Rem
Rem  Copyright (c) Oracle Corporation 1999. All Rights Reserved.
Rem
Rem    NAME
Rem      utljavarm.sql - Remove all java objects
Rem
Rem    DESCRIPTION
Rem      This removes all the java objects from the data dictionary.
Rem
Rem    NOTES
Rem      WARNING:  This script is highly destructive.  It should
Rem		only be run if you upgrading to or downgrading 
Rem		from 8.1.5.  Once this script is run all of your
Rem		java objects will be gone unless you have a backup!!!
Rem
Rem      This script requires a significant amount of rollback
Rem      to execute.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rshaikh     01/12/99 - Created (for mjungerm)
Rem

REM Java objects have a format change between 8.1.4 and 8.1.5.
REM We have to remove all java objects between these releases 
REM because they are not compatible.

set serveroutput on

drop trigger AURORA$SERVER$SHUTDOWN
/
drop trigger AURORA$SERVER$STARTUP
/

DECLARE
 obj_number number := 0;

 cursor C1 is select o1.obj#, 
     'DROP PUBLIC SYNONYM "' || o1.name || '"'
           from obj$ o1, obj$ o2 
           where o1.obj# > obj_number and 
	   o1.name=o2.name and
	   o1.type#=5 and 
	   o2.type#=29
           order by o1.obj#;

  DDL_CURSOR integer;
  ddl_statement varchar2(200);
  iterations number;
  loop_count number;
  my_err     number;
BEGIN
 loop_count := 0;
 -- To make sure we eventually stop, pick a max number of iterations
 select count(*) into iterations from obj$ o1,obj$ o2 
	where o1.name=o2.name and o1.type#=5 and o2.type#=29;


 DDL_CURSOR := dbms_sql.open_cursor;
 OPEN C1;

 LOOP

   BEGIN
     FETCH C1 INTO obj_number, ddl_statement;
     EXIT WHEN C1%NOTFOUND OR loop_count > iterations;
   EXCEPTION
    WHEN OTHERS THEN
      my_err := SQLCODE;
      IF my_err = -1555 THEN -- snapshot too old, re-execute fetch query
       CLOSE C1;
       -- Here is why C1 orders by obj#.  When we restart the query, we 
       -- will only find object with obj# greater than the last one tried.
       -- This keeps us from re-trying objects that failed.
       OPEN  C1;
       GOTO continue;
      ELSE
       RAISE;
      END IF;
   END;

   BEGIN
       -- Issue the Alter Statement  (Parse implicitly executes DDLs)
       dbms_sql.parse(DDL_CURSOR, ddl_statement, dbms_sql.native);
   EXCEPTION
       WHEN OTHERS THEN
        null; -- ignore, and proceed.
   END;

 <<continue>>
   loop_count := loop_count + 1;
 END LOOP;
 dbms_sql.close_cursor(DDL_CURSOR);
 CLOSE C1;
END;
/

commit
/

alter system flush shared_pool
/
alter system flush shared_pool
/
alter system flush shared_pool
/

delete from dependency$ where p_obj# in (select obj# from obj$ where type#=29)
/
commit
/

delete from objauth$ where obj# in (select obj# from obj$ 
	where type#>27 and type#<31)
/
commit
/

delete from javasnm$
/
commit
/

REM
REM We don't need to do these deletes since the idl tables
REM will be truncated when we do an upgrade or a downgrade
REM 
REM delete from idl_ub1$ where obj# in (select obj# from obj$
REM 	where type#>27 and type#<31)
REM delete from idl_ub2$ where obj# in (select obj# from obj$
REM	where type#>27 and type#<31)
REM delete from idl_char$ where obj# in (select obj# from obj$ 
REM 	where type#>27 and type#<31)
REM delete from idl_sb4$ where obj# in (select obj# from obj$ 
REM 	where type#>27 and type#<31)


REM 
REM only delete from obj$ if all the java information was delete
REM from the other tables correctly.  Once we run this delete
REM there is no going back to remove the information from 
REM syn$, objauth$ and dependency$ using this script.
REM
DECLARE
 c1 number;
 c2 number;
 c3 number;
 c4 number; 
BEGIN
  select count(*) into c1 from syn$ where obj# in
	(select o1.obj# from obj$ o1,obj$ o2 
               	where o1.name=o2.name and 
		o1.type#=5 and o2.type#=29);
  select count(*) into c2 from dependency$ where p_obj# in 
	(select obj# from obj$ where type#=29);
  select count(*)into c3 from objauth$ where obj# in (select obj# from obj$ 
	where type#>27 and type#<31);
  select count(*)into c4 from javasnm$;
	

  IF c1 = 0 AND c2 = 0 AND c3 = 0 AND c4 = 0 THEN
	delete from obj$ where type#>27 and type#<31;
	dbms_output.put_line('All java object removed');
  ELSE
	dbms_output.put_line('Java objects not completely removed. Rerun utljavarm.sql');
  END IF;
END;
/

alter system flush shared_pool
/
alter system flush shared_pool
/
alter system flush shared_pool
/

REM 
REM end java object removal
REM

