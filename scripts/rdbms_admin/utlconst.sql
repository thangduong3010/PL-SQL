Rem
Rem $Header: rdbms/admin/utlconst.sql /st_rdbms_11.2.0/1 2010/07/30 09:44:55 cdilling Exp $
Rem
Rem utlconst.sql
Rem
Rem Copyright (c) 1997, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      utlconst.sql - constraint check utility 
Rem
Rem    DESCRIPTION
Rem      Script to check for valid date constraints. 
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem      * This script can be run any number of times.
Rem      * The invalid date constraints are flagged as BAD and disabled.
Rem      * Table cdef$ can be queried to get the list of BAD constraints.
Rem      * The script runs a select statement at the end to produce 
Rem        a list of bad and disabled constraints that need to be changed.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cdilling    04/16/10 - fix bug 9954112
Rem    sbedarka    06/27/01 - #(777789) avoid overflow in altstmt
Rem    jdavison    04/11/00 - Modify usage notes for 8.2 changes.
Rem    mkrishna    12/15/97 - fix bug 598700
Rem    rshaikh     04/04/97 - Date constraint check utility
Rem    rshaikh     04/04/97 - Created
Rem

set serveroutput on;
alter session set events '10149 trace name context off';  

declare

   /* Create a cursor to read all type 1 constraints (Table check constraints)*/
    drop_table_ex exception;
    pragma EXCEPTION_INIT( drop_table_ex , -2444);
    date_check_ex  exception;
    pragma EXCEPTION_INIT( date_check_ex, -2436);
   
   /* Cursor to read the conditions */
    cursor conscur is 
       select obj#, con#,condition
       from   cdef$ 
       where  type# = 1;                   

    consrect   conscur%ROWTYPE;
    tabname    obj$.name%TYPE; 
    consname   con$.name%TYPE;
    username   user$.name%TYPE;

    altcurnam  integer;  
    altstmt    varchar2(32767);
    rowsproc   integer;
    consflag   integer := 0;
    newconst   varchar2(20) := 'SYS$Y2KCHK_$'; 

begin
   
   dbms_output.enable;
   
   dbms_output.put_line(' Checking for bad date constraints ');
   open conscur;
   loop
       
       /* Get one constraint */
       fetch conscur into consrect;
       exit when conscur%NOTFOUND;
       
       /* Get the table name for the constraint */ 
       select obj$.name 
       into   tabname 
       from   obj$ 
       where  obj$.obj# = consrect.obj# ;
       
       /* Get the constraint description and user name */ 
       select con$.name,user$.name  
       into   consname , username
       from   con$ , user$
       where  con# = consrect.con#
       and    con$.owner# = user#;
        
       altcurnam :=  dbms_sql.open_cursor;
       
       /* Form a  new duplicate constraint disabled */ 
       altstmt := 'alter table ' || dbms_assert.enquote_name(username, FALSE)
                          || '.' ||  dbms_assert.enquote_name(tabname, FALSE)
		  || ' add constraint ' || newconst || TO_CHAR(consflag) 
                  || ' check (' || consrect.condition || ') disable ';
      begin 
       
       dbms_sql.parse(altcurnam, altstmt,dbms_sql.native);
       rowsproc :=  dbms_sql.execute(altcurnam);
         
       altstmt := 'alter table ' ||  dbms_assert.enquote_name(username, FALSE)
                          || '.' ||  dbms_assert.enquote_name(tabname, FALSE) 
                   || ' drop constraint ' || newconst || TO_CHAR(consflag); 
       dbms_sql.parse(altcurnam, altstmt,dbms_sql.native);
       rowsproc :=  dbms_sql.execute(altcurnam);
         
      exception
	
         when date_check_ex or drop_table_ex then 
            
	    consflag := consflag + 1;
            
            /* Make constraint bad */
            update cdef$ set enabled = null,defer = 16 
            where con# = consrect.con# ;

         when others   then 
           
	    consflag := consflag + 1;
            dbms_output.put_line( ' Statement "'||altstmt|| '" failed ..');
            dbms_output.put_line(' Internal error '|| sqlcode );
      end;
     
      dbms_sql.close_cursor(altcurnam);

   end loop;
   close   conscur;

   if consflag = 0 then
     dbms_output.put_line(' Finished checking -- All constraints OK!'); 
   else 
     dbms_output.put_line('Bad constraints present -- check table cdef$ ' ||
                          ' for defer = 0x16 (BAD flag) and enabled is NULL');
     
     dbms_output.put(' Finished checking -- ' || TO_CHAR(consflag));
     if consflag = 1 then
        dbms_output.put_line(' constraint needs to be changed!'); 
     else 
        dbms_output.put_line(' constraints need to be changed!'); 
     end if; 

   end if; 
   
end ; 
/

-------------------------------------------------------------------------
-- Select all the constraints with the username,tablename,constraint name 
-- and the constraint definition
-- List of BAD and DISABLED constraints
-------------------------------------------------------------------------

select user$.name AS "USERNAME" ,obj$.name AS "TABLENAME",
       con$.name AS "CONSTRAINT NAME" ,cdef$.condition AS "CONSTRAINT DEFN"
from   cdef$ ,con$,obj$,user$
where  cdef$.defer = 16 
 and   cdef$.enabled is NULL
 and   con$.owner# = user$.user#
 and   cdef$.con#  = con$.con# 
 and   cdef$.obj#  = obj$.obj#
/   
