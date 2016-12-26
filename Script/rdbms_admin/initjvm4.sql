-- subscript for initjvm.sql and ilk

-- Find all the error messages.  The following query returns the errors
-- that caused the invalid classes (if any) from the previous query (in
-- the script which called initjvm4, either initjvm.sql or jvmursc.sql).

select nvl(longdbcs, o.name), text
 from error$ e,obj$ o,javasnm$,java$rmjvm$aux3 a where
 e.obj#=o.obj# and o.owner#=0 and o.obj#=a.obj# and o.name=short(+);

-- There should be zero results from the above query in a correct installation
-- of the Java VM

delete from java$rmjvm$aux3;

-- Create the get error package for LoadJava
create or replace package get_error$ as 
  type myrec is record (errormsg varchar(4000));
  type myrctype is ref cursor return myrec;
  function error_lines (classname varchar2) return myrctype; 
end get_error$;
/
create or replace package body get_error$ as 
  function error_lines (classname varchar2) return myrctype is 
    rc myrctype; short_name varchar2(50); n number;
  begin 
    open rc for select text from user_errors
       where name = dbms_java.shortname(classname);
    return rc; 
  end; 
end get_error$;
/

call initjvmaux.drp('drop public synonym get_error$');

create public synonym get_error$ for get_error$;

grant execute on get_error$ to public;


