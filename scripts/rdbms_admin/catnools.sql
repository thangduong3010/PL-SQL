Rem
Rem $Header: rdbms/admin/catnools.sql /main/16 2010/06/04 09:11:44 aramappa Exp $
Rem
Rem catnools.sql
Rem
Rem Copyright (c) 2001, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnools.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      This script drops the OLS product and all of its LBACSYS
Rem      objects from a database instance.  All OLS policies will
Rem      also be dropped but user tables will not have their OLS
Rem      policy columns automatically dropped.
Rem
Rem    NOTES
Rem      Must be run as SYSDBA.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mjgreave    05/10/10 - maintain delete_catalog_role privs. #9697811
Rem    aramappa    04/28/10 - bug 9554753: use dbms_assert
Rem    srtata      02/17/09 - remove logon trigger
Rem    sarchak     04/27/08 - Bug 6925041,Creating aud$ in correct tablespace.
Rem    nkgopal     01/22/08 - SYS.I_AUD1 index is dropped in this release
Rem    cchui       11/24/03 - Bug 3278427. 
Rem    srtata      04/25/02 - remove startup trigger.
Rem    shwong      10/10/01 - remove OLS from registry
Rem    srtata      05/02/01 - Add error handling.
Rem    gmurphy     04/13/01 - document run as SYSDBA
Rem    gmurphy     04/12/01 - drop after_drop trigger first
Rem    gmurphy     04/06/01 - add index to aud$ table
Rem    gmurphy     04/03/01 - drop synonyms
Rem    gmurphy     03/02/01 - cleanup
Rem    kraghura    02/06/01 - Echo Off
Rem    gmurphy     02/02/01 - Merged gmurphy_ols_2rdbms
Rem    gmurphy     01/30/01 - complete rewrite of pl/sql script
Rem    gmurphy     01/29/01 - move cleanup from catlbacs.sql 
Rem    gmurphy     01/15/01 - rename droplbacsys.sql to catnools.sql
Rem    rsripada    11/13/00 - add commit at the end
Rem    rsripada    10/16/00 - Created
Rem



WHENEVER SQLERROR EXIT;

BEGIN

-- Check the user who is executing this script.
   if sys_context('userenv','session_user') != 'SYS' then
RAISE_APPLICATION_ERROR(-20000,
  'Execute the script as user SYS as SYSDBA');
   end if;
END;
/

WHENEVER SQLERROR CONTINUE;

-- remove OLS via registry
EXECUTE DBMS_REGISTRY.REMOVING('OLS');

-- drop OLS database triggers.
DROP TRIGGER LBACSYS.lbac$after_drop;
DROP TRIGGER LBACSYS.lbac$after_create;
DROP TRIGGER LBACSYS.lbac$before_alter;

-- copy system.aud$ back to sys.aud$.

DECLARE
  tbs_name    VARCHAR2(30);
BEGIN
    select TABLESPACE_NAME INTO tbs_name FROM dba_tables where TABLE_NAME='AUD$';
    EXECUTE IMMEDIATE 'DROP SYNONYM aud$';
    EXECUTE IMMEDIATE 'CREATE TABLE SYS.aud$ tablespace '||dbms_assert.simple_sql_name(tbs_name) ||' AS SELECT * FROM SYSTEM.aud$';
    EXECUTE IMMEDIATE 'DROP TABLE SYSTEM.aud$';
    EXECUTE IMMEDIATE 'GRANT DELETE ON SYS.aud$ to DELETE_CATALOG_ROLE';
END;
/

-- cleanup OLS by removing any roles, contexts,or synonyms
-- owned by LBACSYS.
DECLARE

CURSOR lbacroles IS
  SELECT granted_role
  FROM   dba_role_privs
  WHERE  grantee = 'LBACSYS'
  AND    granted_role like '%_DBA'
  AND    admin_option = 'YES';

CURSOR lbaccontexts IS
  SELECT namespace
  FROM   dba_context
  WHERE  schema = 'LBACSYS';

CURSOR lbacsynonyms IS
  SELECT synonym_name
  FROM   dba_synonyms
  WHERE  table_owner = 'LBACSYS';

rolename          VARCHAR2(30);

BEGIN

-- drop roles
  FOR r IN lbacroles LOOP
    dbms_output.put_line('Dropping role ' || r.granted_role  );

    BEGIN
      EXECUTE IMMEDIATE 'DROP ROLE ' || 
                         dbms_assert.enquote_name(r.granted_role,FALSE);
    EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Unable to drop role ' || r.granted_role);
    END;

  END LOOP;

-- drop contexts
  FOR c IN lbaccontexts LOOP
    dbms_output.put_line('Dropping context ' ||  c.namespace);

    BEGIN
      EXECUTE IMMEDIATE 'DROP CONTEXT ' || 
                         dbms_assert.enquote_name(c.namespace,FALSE);
    EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Unable to drop context ' ||  c.namespace);
    END;

  END LOOP;

-- drop synonyms
  FOR s IN lbacsynonyms LOOP
    dbms_output.put_line('Dropping public synonym ' || s.synonym_name);

    BEGIN
      EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM ' || 
                         dbms_assert.enquote_name(s.synonym_name,FALSE);
    EXCEPTION
    WHEN OTHERS THEN
      dbms_output.put_line('Unable to drop synonym ' || s.synonym_name);
    END;

  END LOOP;

END;
/

-- now remove lbacsys account and it's content
-- drop user cascade will also remove the OLS entry from the registry
DROP USER LBACSYS CASCADE;
DELETE FROM exppkgact$ WHERE PACKAGE = 'LBAC_UTL';

COMMIT;
