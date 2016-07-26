Rem
Rem $Header: wwg_src_1/admin/owa/owainst.sql /st_www_101200rdbms/11 2012/06/25 23:03:44 rpang Exp $
Rem
Rem owainst.sql
Rem
Rem Copyright (c) 2001, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      owainst.sql - OWA pkg installation script
Rem
Rem    DESCRIPTION
Rem      This file is a driver file that installs the OWA packages
Rem      bundled with the database.  If you are directly invoking
Rem      the script you must run this script as SYS.
Rem
Rem      Note: this script also gets used during upgrades.
Rem      If the OWA packages already loaded in the database (if any) 
Rem      are more recent (based on OWA_UTIL.get_version() value), 
Rem      then this script will not reload the shipped OWA packages.
Rem
Rem    NOTES
Rem      This script can automatically install OWA packages in databases 
Rem      version 8.0.x and higher and is normally invoked via owaload.sql
Rem      Here is what the script does
Rem      - For 9.0.x and above, installs owacomm.sql
Rem      - For 8.1.x and above, installs wpiutl.sql and owacomm8i.sql
Rem      - For 8.0.x and above, installs wpiutl.sql and owacomm8.sql
Rem      To install the OWA packages in a 7.x database (not certified,
Rem      but should work), manually install wpiutl7.sql and owacomm7.sql
Rem
Rem BEGIN SQL_FILE_METADATA
Rem SQL_SOURCE_FILE: wwg_src_1/admin/owa/owainst.sql
Rem SQL_SHIPPED_FILE: rdbms/admin/owainst.sql
Rem SQL_PHASE: CATPEXEC_MAIN
Rem SQL_STARTUP_MODE: NORMAL
Rem SQL_IGNORABLE_ERRORS: NONE
Rem SQL_CALLING_FILE: rdbms/admin/catpexec.sql
Rem END SQL_FILE_METADATA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rpang       06/21/12 - Bump up version
Rem    surman      03/28/12 - 13615447: Add SQL patching tags
Rem    rpang       03/30/10 - Revalidate objects after revoke
Rem    rpang       01/20/10 - Revoke debug privilege
Rem    pkapasi     06/25/07 - Increment version(bug#6013207)
Rem    pkapasi     11/03/06 - Bump up owa version for next release
Rem    pkapasi     10/12/06 - Increment version number
Rem    mmuppago    04/27/06 - bumping up ship version 
Rem    akatti      11/14/05 - Bump up version 
Rem    mmuppago    10/03/05 - Bump up the version
Rem    ehlee       04/25/05 - Bump up version
Rem    ehlee       09/02/04 - Bump up version
Rem    dnonkin     09/01/04 - Bump up version
Rem    pkapasi     11/27/03 - Bump up version
Rem    pkapasi     05/29/03 - Fix bugs and bump up version
Rem    ehlee       11/01/02 - Bump up version
Rem    ehlee       10/31/02 - Bump up version
Rem    pkapasi     10/09/02 - Bump up version
Rem    pkapasi     08/07/02 - Bump up version
Rem    ehlee       06/10/02 - Bump up version
Rem    ehlee       12/03/01 - Bump up version
Rem    ehlee       10/15/01 - Bump up version
Rem    pkapasi     09/21/01 - Bump up version
Rem    skwong      08/20/01 - Add owacomm8i.sql for 8i.
Rem    pkapasi     08/02/01 - Remove recompile of owa_util. causes invalidations
Rem    ehlee       07/11/01 - Change version to 3.0.0.0.6
Rem    pkapasi     06/14/01 - Change script to work for all 8.x databases
Rem    pkapasi     06/12/01 - Cleanup logic to figure which file is installed
Rem    pkapasi     06/12/01 - Add logic to install based on database version
Rem    kmuthukk    04/27/01 - version check based OWA pkg install
Rem    kmuthukk    04/27/01 - Created
Rem

whenever sqlerror exit sql.sqlcode

Prompt Revoking the debug privileges

declare
   l_privilege varchar2(10) := 'DEBUG';
   l_owner varchar2(10) := 'PUBLIC';

   /** 
    * Revokes the debug privilege on specific packages
    * for which excess privileges were granted 
    * incorrectly in earlier releases.
    **/
   procedure revoke_privileges
    (
         p_privilege      in varchar2,
         p_user           in varchar2 
    )
    is
        object_name dba_tab_privs.table_name%type := null;

        -- Fetch all the specific objects  
        -- for which the user has the privilege.
        -- Here we are revoking privileges on precise objects for which
        -- privileges were granted incorrectly in earlier releases through
        -- the scripts owacomm.sql and privcust.sql.
        -- This cursor will be invoked using the 
        -- 'Debug' Privilege and 'Public' user.


        cursor  object_prv (p_privilege IN varchar2 ,p_user IN varchar2)
          is select table_name from dba_tab_privs, 
         dba_objects where privilege=p_privilege
         and grantee = p_user and table_name = 
         object_name and object_type ='PACKAGE'
         and dba_objects.OWNER ='SYS' 
         and dba_objects.OWNER = dba_tab_privs.OWNER 
         and object_name in 
         ('OWA_CUSTOM','OWA', 'HTF',
          'HTP','OWA_COOKIE','OWA_IMAGE',
          'OWA_OPT_LOCK','OWA_PATTERN','OWA_SEC',
          'OWA_TEXT','OWA_UTIL','OWA_CACHE','OWA_MATCH');

         l_revoke_cmd varchar2(4000);

    begin
         
         -- Execute the query for fetching
         -- the objects for which the user has privilege.
         open object_prv (p_privilege,p_user);

         -- Loop through the objects on which 
         -- the user has the privilege and
         -- revoke the privilege.

         loop
            fetch object_prv into object_name;
            exit when object_prv%NOTFOUND;

            -- Execute the revoke privilege command
            l_revoke_cmd := 'Revoke ' ||  p_privilege || ' on ' || object_name
                        || ' from ' ||  p_user;
            dbms_output.put_line ('Revoking privilege on ' || object_name);

            execute immediate l_revoke_cmd ;
         end loop;

         -- Close the cursor.
         close object_prv;
   exception
       when others then 
           dbms_output.put_line
               ('ERROR: owacomm.sql while revoking the  privilege on ' 
                 ||  object_name );
           dbms_output.put_line(sqlerrm );

           if object_prv%isopen then
            close object_prv;
           end if;

           raise;  
   end revoke_privileges;

   /**
    * Returns true if the user has
    * privilege on specific packages for which
    * excess privilege was granted incorrectly
    * during earlier releases.
    * False otherwise.
    */

   function has_privilege
    (
         p_privilege      in varchar2,
         p_user           in varchar2 
    )
    return boolean
    is
        l_count number := null;

        -- Fetch the count of objects (precise packages)  
        -- for which the user has the privilege.
        -- This cursor will be invoked using the 
        -- 'Debug' Privilege and 'Public' user.
        -- So this fetches the count of precise packages for which
        -- the public user has debug privileges that were 
        -- incorrectly granted in earlier releases.
        
        cursor  object_prv (p_privilege IN varchar2 ,p_user IN varchar2)
          is select count(1) from dba_tab_privs, 
         dba_objects where privilege = p_privilege
         and grantee = p_user and table_name = 
         object_name
         and dba_objects.OWNER ='SYS' 
         and dba_objects.OWNER = dba_tab_privs.OWNER 
         and object_type ='PACKAGE'
         and object_name in
         ('OWA_CUSTOM','OWA', 'HTF',
          'HTP','OWA_COOKIE','OWA_IMAGE',
          'OWA_OPT_LOCK','OWA_PATTERN','OWA_SEC',
          'OWA_TEXT','OWA_UTIL','OWA_CACHE','OWA_MATCH');

         l_has_privilege boolean := false;

    begin
        -- Get the count of owa packages
        -- for which the user has the privilege.
        -- Execute the query.
        open object_prv (p_privilege,p_user);

        -- Fetch the result.
        fetch object_prv into l_count;

        -- Close the cursor.
        close object_prv;

        -- Return true if there are packages
        -- with debug privileges for public.
        -- False otherwise.

         if l_count > 0 then
            l_has_privilege := true;
         end if;

         return l_has_privilege; 

    exception
       when others then 
           dbms_output.put_line
               ('ERROR: owacomm.sql while checking privileges.');
           dbms_output.put_line(sqlerrm );

           if object_prv%isopen then
               close object_prv;
           end if;
           raise;
    end has_privilege;

   /** 
    * Revalidate any invalid packages and package bodies
    * after the revoke.
    **/

   procedure revalidate_objects
    is
        object_name dba_objects.object_name%type := null;
        object_type dba_objects.object_type%type := null;

        -- Fetch all the invalid objects after the revoke.
        cursor  invalid_obj
          is select object_name, object_type from dba_objects
         where object_type in ('PACKAGE', 'PACKAGE BODY')
         and owner ='SYS' 
         and object_name in 
         ('OWA_CUSTOM','OWA', 'HTF',
          'HTP','OWA_COOKIE','OWA_IMAGE',
          'OWA_OPT_LOCK','OWA_PATTERN','OWA_SEC',
          'OWA_TEXT','OWA_UTIL','OWA_CACHE','OWA_MATCH')
         and status <> 'VALID'
         order by object_type;

         l_compile_cmd varchar2(4000);

    begin
         
         -- Execute the query for fetching invalid objects.
         open invalid_obj;

         -- Loop through the invalid objects
         loop
            fetch invalid_obj into object_name, object_type;
            exit when invalid_obj%NOTFOUND;

            -- Execute the compile command
            l_compile_cmd := 'Alter package ' || object_name || ' compile';

            if object_type = 'PACKAGE BODY' then
               l_compile_cmd := l_compile_cmd || ' body';
            end if;

            execute immediate l_compile_cmd ;
         end loop;

         -- Close the cursor.
         close invalid_obj;
   exception
       when others then 
           dbms_output.put_line
               ('ERROR: owacomm.sql while revalidating ' ||  object_name );
           dbms_output.put_line(sqlerrm );

           if invalid_obj%isopen then
            close invalid_obj;
           end if;

           raise;  
   end revalidate_objects;

begin
      
     /* Check if the public user has debug privileges 
      * on specific packages. Skip this step if the user
      * doesn't have the debug privilege.
      */
     
     if has_privilege(l_privilege, l_owner) then

        dbms_output.put_line ('Revoking the debug privilege from PUBLIC schema.');    
        dbms_output.put_line ('Revoking debug privilege started at ' ||
                                 to_char(sysdate, 'dd-mon-yyyy HH:MI:SS'));

        -- Revoke the debug privileges from the public user. 
        revoke_privileges(l_privilege, l_owner);

        -- Revalidate any invalid objects
        revalidate_objects;

        dbms_output.put_line ('Revoking debug privilege ended at ' ||
                                to_char(sysdate, 'dd-mon-yyyy HH:MI:SS'));
        
     else 

        dbms_output.put_line ('Debug Privileges not granted for PUBLIC.' ||
                              ' Skipping this step.');    

     end if;
end;    
/

whenever sqlerror continue

variable owa_file_name   varchar2(200);
variable wpi_file_name   varchar2(200);
variable owa_dbg_msg     varchar2(1000);
variable db_version      number;


Rem
Rem always initialize owa_file_name and wpi_file_name to some dummy value.
Rem
begin :owa_file_name := 'dummy_value'; end;
/
begin :wpi_file_name := 'dummy_value'; end;
/

DECLARE
  /*
   * This next line must be updated whenever 
   * OWA_UTIL.owa_version is updated.
   */
  shipped_owa_version    VARCHAR2(80) := '10.1.2.0.9';
  installed_owa_version  VARCHAR2(80);
  new_line               VARCHAR2(4)  := '
';
  install_pkgs           BOOLEAN;
  is_supported_db_ver    boolean;

  -- procedure executes a DDL and ignores errors if any.
  PROCEDURE execute_ddl(ddl_statement VARCHAR2) IS
    ddl_cursor INTEGER;
  BEGIN
    -- try to execute DDL
    ddl_cursor := dbms_sql.open_cursor;

    -- issue the DDL statement
    dbms_sql.parse (ddl_cursor, ddl_statement, dbms_sql.native);
    dbms_sql.close_cursor (ddl_cursor);
  EXCEPTION
    -- ignore exceptions
    when others then
      if (dbms_sql.is_open(ddl_cursor)) then
        dbms_sql.close_cursor(ddl_cursor);
      end if;
  END;

 --
 -- takes a string of the form 'num1.num2.num3.....'
 -- returns "num1" AND updates string to 'num2.num3...'
 --
 FUNCTION get_next_int_and_advance(str IN OUT varchar2)
      RETURN PLS_INTEGER is
  loc pls_integer;
  ans pls_integer;
 BEGIN
  loc := instr(str, '.', 1);
  if (loc > 0) then
   ans := to_number(substr(str, 1, loc - 1));
   str := substr(str, loc + 1, length(str) - loc);
  else
   ans := to_number(str);
   str := '';
  end if;
  return ans;
 END;

 --
 -- Determines the database version and returns a number like 80500, 81700 etc
 --
 FUNCTION get_db_version 
      RETURN NUMBER is
    ans            NUMBER;
    l_version      VARCHAR2(32);
    l_comp_version VARCHAR2(32);
 BEGIN
   -- Get the version of the backend database
   dbms_utility.db_version(l_version, l_comp_version);

   -- Convert string to a number
   ans := 0;
   FOR i in 1..5 LOOP 
     ans := 10 * ans + get_next_int_and_advance(l_version);
   END LOOP;

   RETURN ans;

 END;

  --
  -- If shipped version of OWA packages is higher than the 
  -- pre-installed version of the OWA packages, then
  -- we need to reinstall the OWA packages.
  -- 
  FUNCTION needs_reinstall(shipped_owa_version   IN VARCHAR2,
                           installed_owa_version IN VARCHAR2) 
        RETURN BOOLEAN is

     shp_str VARCHAR2(80) := shipped_owa_version;
     shp_vsn PLS_INTEGER;
     ins_str VARCHAR2(80) := installed_owa_version;
     ins_vsn PLS_INTEGER;

  BEGIN
    --
    -- either OWA pkgs are not already installed (as can happen
    -- with a new DB) or an older version of the pkg is installed
    -- where version numbering was not implemented.
    --
    IF (installed_owa_version is NULL) THEN
      return TRUE;
    END IF;

    -- If version is the same, then we don't install it again to avoid 
    -- recompiling all dependent packages.
    --
    IF (installed_owa_version = shipped_owa_version) THEN
      return FALSE;
    END IF;

    --
    -- Check if shipped version is higher.
    --
    -- The OWA_UTIL version number format is V1.V2.V3.V4.V5.
    -- Lets compare versions by comparing Vi's from left to right.
    --
    FOR i in 1..5 LOOP 

     -- parse "shipped_version" one int at a time, from L to R
     shp_vsn := get_next_int_and_advance(shp_str);

     -- parse "installed_version" one int at a time, from L to R
     ins_vsn := get_next_int_and_advance(ins_str);
 
     IF (shp_vsn > ins_vsn) THEN
       return TRUE;
     END IF;

     IF (shp_vsn < ins_vsn) THEN
       return FALSE;
     END IF;

    END LOOP;

    -- 
    -- Should never come here. Return TRUE in this case as well.
    --
    RETURN TRUE;
  END;

  FUNCTION get_installed_owa_version RETURN VARCHAR2 IS
    owa_version VARCHAR2(80);
    l_cursor    INTEGER;
    l_stmt      VARCHAR2(256);
    l_status    INTEGER;
  BEGIN

    --
    -- Run this block via dynamic SQL and not static SQL
    -- because compilation of this block could fail as OWA_UTIL
    -- might be non-existant. Doing it from dynamic SQL allows
    -- us to catch the compile error as a run-time exception
    -- and proceed.
    --
    l_stmt := 'select OWA_UTIL.get_version from dual';
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, l_stmt, dbms_sql.native);
    dbms_sql.define_column( l_cursor, 1, owa_version, 80 );
    l_status := dbms_sql.execute(l_cursor);

    loop
       if dbms_sql.fetch_rows (l_cursor) > 0 then
          dbms_sql.column_value(l_cursor, 1, owa_version);
       else
          exit; 
       end if;
    end loop;
    dbms_sql.close_cursor(l_cursor);

    return owa_version;

  EXCEPTION
    --
    -- Either OWA pkgs have not been preinstalled
    -- Or, they are older set of OWA pkgs which
    -- a.) did not implement the OWA_UTIL.get_version method
    -- b.) resulted in ORA-6571 : ignore it
    -- 
    WHEN OTHERS THEN
     if dbms_sql.is_open(l_cursor) then
         dbms_sql.close_cursor(l_cursor);
     end if;
     return NULL;
  END;

BEGIN

 -- Get the version of OWA packages installed in the database
 installed_owa_version := get_installed_owa_version;

 -- Format a message for display
 IF (installed_owa_version is NULL) THEN
    :owa_dbg_msg := 'No older OWA packages detected or OWA packages too old';
 ELSE
    :owa_dbg_msg := 'Installed OWA version is: ' || installed_owa_version;
 END IF;
 :owa_dbg_msg := :owa_dbg_msg || ';' || new_line ||
                  'Shipped OWA version is  : ' || shipped_owa_version || ';';

 -- Get the version of the backend database
 :db_version := get_db_version;

 -- Check if we have the right DB version
 if (:db_version < 81720) or (:db_version between 90100 and  90109) then
     is_supported_db_ver := false;
 else
     is_supported_db_ver := true;
 end if;

 -- Proceed with the install
 if (is_supported_db_ver) then
     -- Check if we need to install the OWA packages?
     install_pkgs := needs_reinstall(shipped_owa_version, installed_owa_version);

     IF (install_pkgs) THEN

       -- Setup the debug message
       :owa_dbg_msg := :owa_dbg_msg || new_line ||
                   'OWA packages v' || shipped_owa_version ||
                   ' will be installed into your database v' || :db_version;

       IF (:db_version < 90000) THEN
         -- Databases >= 9.x will come preinstalled with wpiutl.sql
         -- Databases < 9.x have our version of wpiutl.sql. Drop them
         execute_ddl ('drop package sys.wpiutl');

         IF (:db_version < 80000) THEN
           -- Dealing with a 7.x or older database
           :wpi_file_name := 'wpiutl7.sql';
           :owa_file_name := 'owacomm7.sql';
         ELSE
           -- Dealing with an 8.x database
           IF (:db_version < 81000) THEN
              -- Dealing with 8.0.x database
              :wpi_file_name := 'wpiutl.sql';
              :owa_file_name := 'owacomm8.sql';
           ELSE
              -- Dealing with an 8.1.x database
              :wpi_file_name := 'wpiutl.sql';
              :owa_file_name := 'owacomm8i.sql';
           END IF;
         END IF;
       ELSE
         -- Dealing with 9.x and above
         :wpi_file_name := 'owadummy.sql';
         :owa_file_name := 'owacomm.sql';
       END IF;

       :owa_dbg_msg := :owa_dbg_msg || new_line || 'Will install ' ||
                   :wpi_file_name || ' and ' || :owa_file_name;

     ELSE
       :wpi_file_name := 'owadummy.sql';
       :owa_file_name := 'owadummy.sql';
       :owa_dbg_msg := :owa_dbg_msg || new_line || 
                   'You already have a newer version of the OWA packages' ||
                   new_line || 'No install is required';
     END IF;

 else
     -- DB version is not right, print message and exit
     :owa_dbg_msg := :owa_dbg_msg || new_line ||
         'To install OWA packages v' || shipped_owa_version ||
         ' database version should be at least 8.1.7.2 or 9.0.1.1, your database is v'
         || :db_version || ', OWA packages will not be installed.';
     :wpi_file_name := 'owadummy.sql';
     :owa_file_name := 'owadummy.sql';
 end if;
END;
/

print :owa_dbg_msg;

COLUMN :wpi_file_name NEW_VALUE wpi_file_var NOPRINT;
SELECT :wpi_file_name FROM DUAL;
COLUMN :owa_file_name NEW_VALUE owa_file_var NOPRINT;
SELECT :owa_file_name FROM DUAL;

alter session set events '10520 trace name context forever, level 10';

@@&wpi_file_var;
@@&owa_file_var;

alter session set events '10520 trace name context off';


