Rem
Rem
Rem Copyright (c) 1995, 2007, Oracle. All rights reserved.  
Rem    NAME
Rem      privoolk.sql - package of various OWA OPTIMISTIC LOCKING procedures
Rem    DESCRIPTION
Rem      This file contains one package:
Rem         owa_opt_lock    - Utitility procedures/functions for use
Rem                           with the Oracle Web Agent
Rem
Rem    NOTES
Rem      The Oracle Web Agent is needed to use these facilities.
Rem      The package owa is needed to use these facilities.
Rem      The package owa_util is needed to use these facilities.
Rem      The packages htp and htf are needed to use these facilities.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem     howu       06/28/07  - add DBMS_ASSERT to prevent SQL injection.
Rem     akatti     11/22/04  - [3927257]:wrap XMLTYPE column value with 
Rem                            getclobval 
Rem     pkapasi    08/21/04 -  Fix 3878775. Remove tabs
Rem     ehlee      10/17/01 -  Fix 1690540
Rem     rdasarat   01/05/99 -  Fix 789868
Rem     rdasarat   08/06/98 -  Fix 711814
Rem     mpal       07/09/97 -  Implement COMMON schema
Rem     mpal       06/24/96 -  Creation

REM Creating OWA_OPT_LOCK package...
create or replace package body owa_opt_lock
as
   
   last_column      exception;
   pragma exception_init( last_column, -1007 );
   
   /******************************************************************/
   /* Function to check if the argument is a valid object            */
   /******************************************************************/
   procedure validate_object_name (p_owner in varchar2, p_object in varchar2) 
   is
      stmt_cursor number;
      rc          number;
      found       number := 0;
      p_schema    varchar2(30) := upper(p_owner);
      p_obj       varchar2(30) := upper(p_object);
   begin
      stmt_cursor := dbms_sql.open_cursor;
      sys.dbms_sys_sql.parse_as_user(stmt_cursor,
         'begin
             select count(*)
               into :found
               from all_objects
             where owner = :p_schema 
             and object_name = :p_obj;
          exception
              when others then
                 :found := 0;
          end;', dbms_sql.v7);
      dbms_sql.bind_variable(stmt_cursor, ':p_schema', p_schema);
      dbms_sql.bind_variable(stmt_cursor, ':p_obj', p_obj);
      dbms_sql.bind_variable(stmt_cursor, ':found', found);
      rc := dbms_sql.execute(stmt_cursor);
      dbms_sql.variable_value(stmt_cursor, ':found', found);
      dbms_sql.close_cursor(stmt_cursor);

      if (found = 0) then
         raise_application_error(-20001, 'Cannot resolve object');
      end if;
   end;

   /******************************************************************/
   /* Function to calculate checksum                                 */
   /******************************************************************/
   function checksum( p_buff in varchar2 ) return number
   is
      l_sum       number default 0; 
      l_n         number; 
      l_nu        number; 
      l_nl        number; 
   begin 
      for i in 1 .. trunc(length(p_buff||'x')/2) loop 
         if ascii(substr(p_buff||'x', 1+(i-1)*2, 1))>255 then 
            --2byte char + (1byte char or 2byte char) 
            l_nu:=0; 
            l_nl:=ascii(substr(p_buff||'x', 1+(i-1)*2, 1)); 
            l_n := l_nl; 
            l_sum := mod( l_sum+l_n, 4294967296); 
      
            if ascii(substr(p_buff||'x', 2+(i-1)*2, 1))>255 then 
               --2byte char + 2byte char 
               l_nu:=0; 
               l_nl:=ascii(substr(p_buff||'x', 2+(i-1)*2, 1)); 
               l_n := l_nl; 
               l_sum := mod( l_sum+l_n, 4294967296); 
            else 
               --2byte char + 1byte char 
               l_nu:=ascii(substr(p_buff||'x', 2+(i-1)*2, 1)); 
               l_nl:=ascii('x'); 
               l_n := l_nu*256 + l_nl; 
               l_sum := mod( l_sum+l_n, 4294967296); 
            end if; 
      
            elsif ascii(substr(p_buff||'x', 2+(i-1)*2, 1))>255 then 
               --1byte char + 2byte char 
               l_nu:=0; 
               l_nl:=ascii(substr(p_buff||'x', 2+(i-1)*2, 1)); 
               l_n := l_nl; 
               l_sum := mod( l_sum+l_n, 4294967296); 
      
               l_nu:=ascii('x'); 
               l_nl:=ascii(substr(p_buff||'x', 2+(i-1)*2, 1)); 
               l_n := l_nu*256 + l_nl; 
               l_sum := mod( l_sum+l_n, 4294967296); 
      
            else 
               --1byte char + 1byte char 
               l_nu:=ascii(substr(p_buff||'x', 1+(i-1)*2, 1)); 
               l_nl:=ascii(substr(p_buff||'x', 2+(i-1)*2, 1)); 
               l_n := l_nu*256 + l_nl; 
               l_sum := mod( l_sum+l_n, 4294967296); 
      
               -- dbms_output.put_line('l_n : '||l_n); 
            end if; 
         end loop; 

         -- dbms_output.put_line('l_sum : '||l_sum); 

         while ( l_sum > 65536 ) loop 
            -- l_sum := bitand( l_sum, 65535 ) + trunc(l_sum/65536); 
            l_sum := mod( l_sum, 65536 ) + trunc(l_sum/65536); 
         end loop; 
      return l_sum; 
   end checksum;

   function checksum( p_owner in varchar2, 
                      p_tname in varchar2, 
                      p_rowid in rowid ) return number
   is
      l_theQuery     varchar2(4096) default NULL;
      l_cursor       integer;
      l_variable     number;
      l_status       number;
      l_column_name  varchar2(255);
      l_data_type    varchar2(106);
      p_schema       varchar2(30) := upper(p_owner);
      p_obj          varchar2(30) := upper(p_tname);
   begin
      -- Verify that there is no SQL injection
      validate_object_name (p_schema, p_obj);

      l_cursor := dbms_sql.open_cursor;

      -- Fix 789868 - Common schema may not have access to this info.
      sys.dbms_sys_sql.parse_as_user(
               l_cursor,
               'select column_name, data_type
                  from all_tab_columns
                where owner = :p_schema
                and table_name = :p_obj
                order by column_id', dbms_sql.native);
      dbms_sql.bind_variable(l_cursor, ':p_schema', p_schema);
      dbms_sql.bind_variable(l_cursor, ':p_obj', p_obj);
      dbms_sql.define_column(l_cursor, 1, l_column_name, 255);
      dbms_sql.define_column(l_cursor, 2, l_data_type, 106);
   
      l_status := dbms_sql.execute(l_cursor);
      loop
         l_status := dbms_sql.fetch_rows(l_cursor);
         if (l_status <= 0) then
            exit;
          end if;
          dbms_sql.column_value(l_cursor, 1, l_column_name);
          dbms_sql.column_value(l_cursor, 2, l_data_type);
          if (l_theQuery is NULL) then
             l_theQuery := 'select owa_opt_lock.checksum(';
          else
             l_theQuery := l_theQuery || '||';
          end if;
          -- if the column type is XMLTYPE, then we cannot concatenate
          -- just the l_column_name, as it undergoes xml2char conversion
          -- which has a limitation for converted length that it cannot
          -- exceed 4000, otherwise it throws ORA-19011,
          -- instead, we need to wrap xml column with xmltype.getclobval
          if (l_data_type != 'XMLTYPE') then
              l_theQuery := l_theQuery || l_column_name;
          else
            l_theQuery := l_theQuery || 'xmltype.getclobval(' || l_column_name
                          || ')';
          end if; 
      end loop;
      dbms_sql.close_cursor(l_cursor);

      l_theQuery := l_theQuery || ') from ' || DBMS_ASSERT.ENQUOTE_NAME(p_schema) || '.' || DBMS_ASSERT.ENQUOTE_NAME(p_obj) ||
                    ' where rowid = :x1 for update';

      l_cursor := dbms_sql.open_cursor;
      sys.dbms_sys_sql.parse_as_user( l_cursor, l_theQuery, dbms_sql.v7);
      dbms_sql.bind_variable( l_cursor, ':x1', p_rowid );
      dbms_sql.define_column( l_cursor, 1, l_variable );

      l_status := dbms_sql.execute(l_cursor);
      l_status := dbms_sql.fetch_rows(l_cursor);
      dbms_sql.column_value( l_cursor, 1, l_variable );
      dbms_sql.close_cursor( l_cursor );

      return l_variable;
   end;
   
   /******************************************************************/
   /* Procedure to store values before modifying values              */
   /******************************************************************/
   procedure store_values( p_owner in varchar2, 
                           p_tname in varchar2, 
                           p_rowid in rowid )
   is
      l_theQuery    varchar2(4096);
      l_cursor      integer;
      l_variable    varchar2(2000);
      l_status      number;
      l_col_cnt     number default 0;
      p_schema      varchar2(30) := upper(p_owner);
      p_obj         varchar2(30) := upper(p_tname);
   begin
      -- Verify that there is no SQL injection
      validate_object_name (p_schema, p_obj);

      l_theQuery := 'select rowid, a.* from ' || DBMS_ASSERT.ENQUOTE_NAME(p_schema) || '.' || DBMS_ASSERT.ENQUOTE_NAME(p_obj) ||
                  ' a where rowid = :x1';

      l_cursor := dbms_sql.open_cursor;
   
      sys.dbms_sys_sql.parse_as_user( l_cursor, l_theQuery, dbms_sql.v7 );
      dbms_sql.bind_variable( l_cursor, ':x1', p_rowid );
      for i in 1 .. 255 loop
         begin
            dbms_sql.define_column( l_cursor, i, l_variable, 2000 );
            l_col_cnt := l_col_cnt + 1;
         exception
            when last_column then exit;
         end;
      end loop;
   
      l_status := dbms_sql.execute(l_cursor);
      l_status := dbms_sql.fetch_rows(l_cursor);

      htp.formHidden( 'old_' || p_tname, htf.escape_sc(p_owner) );
      htp.formHidden( 'old_' || p_tname, htf.escape_sc(p_tname) );
      for i in 1 .. l_col_cnt loop
         dbms_sql.column_value( l_cursor, i, l_variable );
         htp.formHidden( 'old_'||p_tname, htf.escape_sc(l_variable) );
      end loop;
   
      dbms_sql.close_cursor( l_cursor );
   end;
   
   /******************************************************************/
   /* Function to verify stored values                               */
   /******************************************************************/
   function verify_values( p_old_values in vcArray ) return boolean
   is
      l_theQuery    varchar2(4096);
      l_cursor      integer;
      l_variable    varchar2(2000);
      l_status      number;
      l_col_cnt     number default 0;
      l_return_val  boolean default TRUE;
      p_schema      varchar2(30) := upper(p_old_values(1));
      p_obj         varchar2(30) := upper(p_old_values(2));
   begin
      -- Verify that there is no SQL injection
      validate_object_name (p_schema, p_obj);

      l_theQuery := 'select * from ' || DBMS_ASSERT.ENQUOTE_NAME(p_schema) || '.' || DBMS_ASSERT.ENQUOTE_NAME(p_obj) ||
                    ' where rowid = :x1 for update';

      l_cursor := dbms_sql.open_cursor;

      sys.dbms_sys_sql.parse_as_user( l_cursor, l_theQuery, dbms_sql.v7 );
      dbms_sql.bind_variable( l_cursor, ':x1', p_old_values(3) );
      for i in 1 .. 255 loop
         begin
            dbms_sql.define_column( l_cursor, i, l_variable, 2000 );
            l_col_cnt := l_col_cnt + 1;
         exception
            when last_column then exit;
         end;
      end loop;
   
      l_status := dbms_sql.execute(l_cursor);
      l_status := dbms_sql.fetch_rows(l_cursor);
   
      for i in 1 .. l_col_cnt loop
         dbms_sql.column_value( l_cursor, i, l_variable );
         if ( l_variable <> p_old_values(i+3) AND
             l_variable is not null          AND
             p_old_values(i+3) is not null ) then 
               l_return_val := FALSE;
               exit;
         end if;
      end loop;

      dbms_sql.close_cursor( l_cursor );
      return l_return_val;
   end;
   
   /******************************************************************/
   /* Internal function used by verify_values                        */
   /******************************************************************/
   function get_rowid( p_old_values in vcArray ) return rowid
   is
   begin
      return p_old_values(3);
   end;

end;
/
show errors

