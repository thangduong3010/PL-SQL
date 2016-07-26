Rem
Rem $Header: rdbms/admin/catdwgrd.sql /st_rdbms_11.2.0/2 2012/03/21 14:55:04 bmccarth Exp $
Rem
Rem catdwgrd.sql
Rem
Rem Copyright (c) 2000, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catdwgrd.sql -  DataBase DoWnGrade from the current release 
Rem                      to the original release (if supported)
Rem
Rem    DESCRIPTION
Rem
Rem      This script is to be used for downgrading your database from the
Rem      current release you have installed to the release from which 
Rem      you upgraded.
Rem
Rem    NOTES
Rem      * This script needs to be run in the current release environment
Rem        (before installing the release to which you want to downgrade).
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bmccarth    03/06/12 - 11.2.0.4
Rem    cdilling    02/24/11 - add support for 11.2.0.3
Rem    bmccarth    05/25/10 - deal with 1102000
Rem    cdilling    08/20/09 - add support for patch downgrades in 11.2
Rem    cdilling    06/04/09 - update to reflect supported downgrade versions
Rem    rpang       02/05/09 - 7600720: Network ACL check only when XDB present
Rem    rgmani      10/30/08 - Downgrade scheduler java code
Rem    rpang       03/28/08 - no xml rewrite for network acl query
Rem    nkgopal     01/29/08 - lrg 3284618
Rem    nkgopal     01/14/08 - Add DBMS_AUDIT_MGMT downgrade check
Rem    rpang       01/09/08 - add check for PL/SQL network ACLs
Rem    rburns      01/03/08 - 11.2 major release downgrade
Rem    rburns      12/10/07 - component patch downgrade
Rem    rburns      08/27/07 - change compatible test
Rem    cdilling    08/09/07 - add support for 11g patch downgrade
Rem    cdilling    04/19/07 - em downgrade changes
Rem    rburns      02/25/07 - recompile indextypes
Rem    cdilling    09/15/06 - add call to f&downgrade_file for pl/sql calls
Rem    rtjoa       07/10/06 - Avoid XMLindexes check before downgrade for XDB 
Rem                           objects 
Rem    liwong      06/07/06 - Check user buffered message apply 
Rem    rburns      05/08/06 - check patch compatible value 
Rem    xbarr       03/09/06 - add support for 11g to 10.2 data mining downgrade 
Rem    cdilling    11/02/05 - add support for 11g to 10.2 downgrade 
Rem    rburns      10/05/05 - remove 9.2 downgrade 
Rem    rburns      03/28/05 - enable component check 
Rem    rburns      03/14/05 - dbms_registry_sys timestamp 
Rem    rburns      02/27/05 - record action for history 
Rem    attran      11/04/04 - check for XMLIDX
Rem    htran       07/26/04 - check for commit-time queue tables
Rem    rburns      06/28/04 - consolidate warnings 
Rem    clei        06/10/04 - disallow downgrade if encrypted columns exist
Rem    rburns      05/17/04 - rburns_single_updown_scripts
Rem    rburns      02/04/04 - Created

Rem =======================================================================
Rem Exit immediately if there are errors in the initial checks
Rem =======================================================================

WHENEVER SQLERROR EXIT;

Rem Check instance version and status; set session attributes
EXECUTE dbms_registry.check_server_instance;

Rem Determine the previous release 
CREATE OR REPLACE FUNCTION version_script
RETURN VARCHAR2 IS

  p_prv_version VARCHAR2(30);
  p_compatible  VARCHAR2(30);

BEGIN
  -- Get the previous version of the CATPROC component
  SELECT prv_version INTO p_prv_version
  FROM registry$ WHERE cid='CATPROC';

  IF p_prv_version IS NULL THEN
     RAISE_APPLICATION_ERROR(-20000,
       'Downgrade not supported - database has not been upgraded');
  END IF;

  -- Only allow downgrades to versions from which we support upgrades
  IF substr(p_prv_version, 1, 8) NOT IN 
('10.1.0.5','10.2.0.2','10.2.0.3','10.2.0.4','10.2.0.5','11.1.0.6','11.1.0.7',
 '11.2.0.1','11.2.0.2','11.2.0.3')
 THEN
     RAISE_APPLICATION_ERROR(-20000,
       'Downgrade not supported to version ' || p_prv_version );
  END IF;
 
  -- Get the current compatible value   
  SELECT value INTO p_compatible
  FROM v$parameter
  WHERE name = 'compatible';
  IF p_compatible > p_prv_version THEN
     dbms_sys_error.raise_system_error(-39707, p_compatible, p_prv_version);
  END IF;

  IF substr(p_prv_version, 1, 6) = '10.1.0' THEN
     RETURN '1001000';
  ELSIF substr(p_prv_version, 1, 6) = '10.2.0' THEN
     RETURN '1002000';
  ELSIF substr(p_prv_version, 1, 6) = '11.1.0' THEN
     RETURN '1101000';
  ELSIF substr(p_prv_version, 1, 6) = '11.2.0' THEN
     RETURN '1102000';
  END IF;
END version_script;
/

Rem get the version correct into the "downgrade_file" variable
COLUMN file_name NEW_VALUE downgrade_file NOPRINT;
SELECT version_script AS file_name FROM DUAL;
DROP function version_script;

Rem =========================================================================
Rem BEGIN STAGE 1: Perform checks prior to downgrade to previous release
Rem =========================================================================

SET SERVEROUTPUT ON
SET VERIFY OFF


Rem =========================================================================
Rem Perform 11.2 downgrade checks
Rem =========================================================================

Rem Placeholder for 11.2 downgrade checks

Rem =========================================================================
Rem Perform 11.1 downgrade checks
Rem =========================================================================

DOC
#############################################################################
#############################################################################

    If the below PL/SQL block raises an ORA-20001 error, then
    de-initialize the DBMS_AUDIT_MGMT package using
    declare
      RetVal BOOLEAN;
    begin
      RetVal := DBMS_AUDIT_MGMT.is_cleanup_initialized
                (DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD);
      if RetVal = TRUE then
        DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION
        (DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD, 'SYSTEM');

        DBMS_AUDIT_MGMT.DEINIT_CLEANUP(DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD);
      end if;

      RetVal := DBMS_AUDIT_MGMT.is_cleanup_initialized
                (DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD);
      if RetVal = TRUE then
        DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION
        (DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD, 'SYSTEM');

        DBMS_AUDIT_MGMT.DEINIT_CLEANUP(DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD);
      end if;
    end;
    /

#######################################################################
#######################################################################
#

declare
  RetVal BOOLEAN;
  ErrMsg VARCHAR2(1024);
begin
  ErrMsg := 'Cannot continue with downgrade. ' ||
            'Some Audit Trails initialized using DBMS_AUDIT_MGMT.INIT_CLEANUP.' ||
            ' Please use DBMS_AUDIT_MGMT.DEINIT_CLEANUP and additionally '||
            'DBMS_AUDIT_MGMT.SET_AUDIT_TRAIL_LOCATION to move the tables back to ' ||
            'SYSTEM tablespace.';

  RetVal := DBMS_AUDIT_MGMT.is_cleanup_initialized
            (DBMS_AUDIT_MGMT.AUDIT_TRAIL_AUD_STD);
  if RetVal = TRUE then
    RAISE_APPLICATION_ERROR(-20001, ErrMsg);
  end if;

  RetVal := DBMS_AUDIT_MGMT.is_cleanup_initialized
            (DBMS_AUDIT_MGMT.AUDIT_TRAIL_FGA_STD);
  if RetVal = TRUE then
    RAISE_APPLICATION_ERROR(-20001, ErrMsg);
  end if;
end;
/

Rem =========================================================================
Rem Perform 10.2 downgrade checks
Rem =========================================================================

DOC
#############################################################################
#############################################################################

    If the below PL/SQL block raises an ORA-20000 error, then
    consult the 11g Upgrade Guide for instructions for downgrading
    the EM Database Control Repository.

    Drop the SYSMAN user prior to downgrade using
    DROP USER SYSMAN CASCADE;

#######################################################################
#######################################################################
#

BEGIN
   IF '&downgrade_file' = '1101000' THEN
       RETURN;
   END IF;
   IF dbms_registry.is_loaded('EM') IS NOT NULL THEN
     RAISE_APPLICATION_ERROR(-20000,('Direct downgrade of EM Database Control not supported.'));
   END IF;
END;
/

DOC
#############################################################################
#############################################################################

    If the below PL/SQL block raises an ORA-40350 error, use the following
    query to identify Data Mining Models that need to be dropped (11g models)

      SELECT a.owner, a.model_name
      FROM  dba_mining_models a, model$ b, obj$ c 
      WHERE b.version = 2 
      AND   a.owner = c.owner#
      AND   b.obj#=c.obj#
      AND   a.model_name = c.name;

    Drop above models prior to downgrade 

#######################################################################
#######################################################################
#

Rem   Raise error if there are 11g Mining models
DECLARE
   cnt                 NUMBER;
   odm_downgrade_error exception;
   PRAGMA EXCEPTION_INIT(odm_downgrade_error, -40350);
   missing exception;
   PRAGMA EXCEPTION_INIT(missing, -942);
BEGIN
   IF '&downgrade_file' IN ('1101000', '1102000') THEN
       RETURN;
   END IF;
   execute immediate 'select count(*) from sys.model$ where version=2' into cnt;
   IF cnt != 0 THEN
     RAISE odm_downgrade_error;
   END IF;
exception
   when missing then NULL;
   when OTHERS then RAISE;
END;
/

DOC
#############################################################################
#############################################################################

    If the below PL/SQL block raises an ORA-25342 error, use the following
    query to identify Applys for user buffered messages that need to be dropped

      SELECT apply_name FROM dba_apply
        WHERE apply_captured = 'NO'
          AND MESSAGE_DELIVERY_MODE = 'BUFFERED';

    Drop the Applys prior to downgrade 

#######################################################################
#######################################################################
#

Rem   Raise error if there are Apply processes for user buffered messages
DECLARE
  cnt                      NUMBER;
  apply_ub_downgrade_error exception;
  PRAGMA EXCEPTION_INIT(apply_ub_downgrade_error, -25342);
BEGIN
  IF '&downgrade_file' IN ('1101000', '1102000') THEN
      RETURN;
  END IF;
  SELECT count(*) INTO cnt FROM dba_apply
    WHERE apply_captured = 'NO'
      AND MESSAGE_DELIVERY_MODE = 'BUFFERED';
  IF cnt > 0 THEN
    RAISE apply_ub_downgrade_error;
  END IF;
END;
/

DOC
#############################################################################
#############################################################################

    If the below PL/SQL block raises an ORA-20000 error, then the network
    access control lists need to be dropped prior to downgrade using
    the following script

    begin
       for r in (select /*+NO_XMLINDEX_REWRITE*/ any_path
                   from xds_acl x, resource_view r
                  where extractValue(x.security_class_ns, '.') =
                           'http://xmlns.oracle.com/plsql'
                    and extractValue(x.security_class_name, '.') = 'network'
                    and sys_op_r2o(extractValue(r.res, '/Resource/XMLRef')) =
                           x.aclid) loop
          dbms_network_acl_admin.drop_acl(r.any_path);
       end loop;
    end;
    /


#######################################################################
#######################################################################
#

DECLARE
   acl_cnt       NUMBER;
   p_prv_version VARCHAR2(30);
   p_compatible  VARCHAR2(30);
BEGIN

   -- Downgrade to 11.1.0.x
   IF '&downgrade_file' IN ('1101000', '1102000') THEN

      -- Get the previous version of the CATPROC component
      SELECT prv_version INTO p_prv_version
      FROM registry$ WHERE cid = 'CATPROC';

      IF p_prv_version IS NULL THEN
         RAISE_APPLICATION_ERROR(-20000,
           'Downgrade not supported - database has not been upgraded');
      END IF;

      -- No check necessary unless downgrading to 11.1.0.6
      IF p_prv_version NOT LIKE '11.1.0.6.%' THEN
         RETURN;
      END IF;

      -- If downgrading to 11.1.0.6, ok if the compatible value is at least
      -- 11.0.0
      SELECT value INTO p_compatible
      FROM v$parameter WHERE name = 'compatible';
      IF p_compatible >= '11.0.0' THEN
         RETURN;
      END IF;
   END IF;

   IF dbms_registry.is_loaded('XDB') IS NOT NULL THEN
     EXECUTE IMMEDIATE 'SELECT /*+NO_XMLINDEX_REWRITE*/ count(*) ' ||
                       '  FROM xds_acl ' ||
                       ' WHERE extractValue(security_class_ns, ''.'') = ''http://xmlns.oracle.com/plsql'' ' ||
                       '   AND extractValue(security_class_name, ''.'') = ''network''' into acl_cnt;
     IF acl_cnt > 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'Network access control lists need to be dropped prior to downgrade.');
     END IF;
   END IF;

END;
/

Rem =========================================================================
Rem Perform 10.1 downgrade checks
Rem =========================================================================

DOC
#######################################################################
#######################################################################

 If the below PL/SQL block raises an ORA-30957 error, use the following
 query to identify XMLINDEXes that need to be dropped.

   SELECT index_owner, index_name
   FROM dba_xml_indexes
   WHERE index_owner != 'XDB';

 Drop all the (Non-XDB) XML indexes shown in the above query before 
 downgrade. 

#######################################################################
#######################################################################
#

Rem Raise error if there are XML indexes
DECLARE
   cnt                 NUMBER;
   xix_downgrade_error exception;
   PRAGMA EXCEPTION_INIT(xix_downgrade_error, -30957);
   missing exception;
   PRAGMA EXCEPTION_INIT(missing, -942);
BEGIN
   IF '&downgrade_file' IN ('1102000','1101000','1002000') THEN
      RETURN;
   END IF;
   execute immediate 'select count(*) from dba_xml_indexes xi
    where xi.index_owner != ''XDB''' into cnt;
   IF cnt != 0 THEN
     RAISE xix_downgrade_error;
   END IF;
exception
   when missing then NULL; 
   when OTHERS then RAISE;
END;
/

DOC
#######################################################################
#######################################################################

 If the below PL/SQL block raises an ORA-25331 error, use the following
 query to identify commit-time queue tables that need to be dropped.

   SELECT owner, queue_table
   FROM dba_queue_tables
   WHERE sort_order like '%COMMIT_TIME%';

 Drop all the queue tables shown in the above query before downgrade.

#######################################################################
#######################################################################
#

Rem Raise error if there are commit-time queue tables
DECLARE
  cnt                 NUMBER;
  ct_downgrade_error  exception;
  PRAGMA EXCEPTION_INIT(ct_downgrade_error, -25331);
BEGIN
  IF '&downgrade_file' IN ('1102000','1101000','1002000') THEN
     RETURN;
  END IF;
  select count(*) into cnt from dba_queue_tables where
    sort_order like '%COMMIT_TIME%';
  IF cnt != 0 THEN
    RAISE ct_downgrade_error; 
  END IF;
END;
/

DOC
#######################################################################
#######################################################################

 If the following PL/SQL block gets an ORA-25427 error, use the 
 following  query to list all the database links that must be dropped
 prior to downgrading:

 SELECT  name, flag  FROM sys.link$
 WHERE  bitand(flag, 2) = 2; 

 Consult Oracle  documentation for instructions to drop a database link.

#######################################################################
#######################################################################
#

Rem Raise errors if database link data dictionary has passwords
DECLARE
  CURSOR d_link IS
  SELECT  name, flag  FROM sys.link$;
  dblink_upgraded_error exception;
  PRAGMA EXCEPTION_INIT(dblink_upgraded_error, -25427);
BEGIN
  IF '&downgrade_file' IN ('1102000','1101000','1002000') THEN
     RETURN;
  END IF;
  FOR rec IN d_link LOOP
    -- Raise error if dblink data dictionary has passwords
   IF bitand(rec.flag, 2) = 2 THEN
      RAISE dblink_upgraded_error;
    END IF;
  END LOOP;
END;
/

DOC
#######################################################################
#######################################################################

 If the following PL/SQL block raises an ORA-26740 error, use the following
 query to identify file groups that need to be dropped.

   SELECT file_group_owner, file_group_name
   FROM dba_file_groups;

 Drop all the file groups shown in the above query before downgrade.

#######################################################################
#######################################################################
#

Rem Raise error if there are file groups
DECLARE
  cnt                 NUMBER;
  fg_downgrade_error  exception;
  PRAGMA EXCEPTION_INIT(fg_downgrade_error, -26740);
BEGIN
  IF '&downgrade_file' IN ('1102000','1101000','1002000') THEN
     RETURN;
  END IF;
  select count(*) into cnt from sys.fgr$_file_groups;
  IF cnt != 0 THEN
    RAISE fg_downgrade_error; 
  END IF;
END;
/

DOC
#######################################################################
#######################################################################

 If the below PL/SQL block raises an ORA-28345 error, use the following
 query to identify tables with encrypted columns that need to be
 decrypted.

   SELECT owner, table_name, column_name
   FROM dba_encrypted_columns;

 Decrypt all the encrypted columns shown in the above query before
 downgrade.

#######################################################################
#######################################################################
#
 
Rem Raise error if there exists any encrypted column
DECLARE
  cnt                  NUMBER;
  tce_downgrade_error  exception;
  PRAGMA EXCEPTION_INIT(tce_downgrade_error, -28345);
BEGIN
  IF '&downgrade_file' IN ('1102000','1101000','1002000') THEN
     RETURN;
  END IF;
  select count(*) into cnt from sys.enc$;
  IF cnt != 0 THEN
    RAISE tce_downgrade_error;
  END IF;
END;
/

Rem =========================================================================
Rem END STAGE 1: Perform checks prior to downgrade to previous release
Rem =========================================================================

SET SERVEROUTPUT OFF
SET VERIFY ON
WHENEVER SQLERROR CONTINUE

SELECT dbms_registry_sys.time_stamp('DWGRD_BGN') AS timestamp FROM DUAL;

Rem =========================================================================
Rem BEGIN STAGE 2: downgrade installed components to previous release
Rem =========================================================================

Rem =========================================================================
Rem Collect indextype names for later recompiles
Rem =========================================================================

create table ityp$temp1
  (ityp_own varchar2(30), ityp_nam varchar2(30), 
   typ_own varchar2(30), typ_nam varchar2(30));

-- get the indextypes and their implementation types and insert into the
-- temporary table

insert into ityp$temp1
  (select u1.name ityp_own, o1.name ityp_nam, u2.name typ_own, o2.name typ_nam 
       from  obj$ o1, obj$ o2, user$ u1, user$ u2, indtypes$ ityp
       where o1.type# = 32 and o1.obj# = ityp.obj# and
       o1.owner# = u1.user# and ityp.implobj# = o2.obj#
       and o2.owner# = u2.user#);

Rem =========================================================================
Rem          Remove scheduler java-related code
Rem =========================================================================

DROP JAVA SOURCE "schedFileWatcherJava";
DROP JAVA SOURCE "dbFWTrace";
EXECUTE sys.dbms_java.dropjava('-s rdbms/jlib/schagent.jar');


Rem =========================================================================
Rem Downgrade Components 
Rem Use cmpdbdwg for major release downgrade
Rem Use cmpdwpth for patch release downgrade
Rem =========================================================================

VARIABLE cmpdw_name VARCHAR2(256)                   
COLUMN :cmpdw_name NEW_VALUE cmpdw_file NOPRINT

BEGIN
  IF '&downgrade_file' = '1102000' THEN
     :cmpdw_name := '@cmpdwpth';
  ELSE
     :cmpdw_name := '@cmpdbdwg';
  END IF;
END;
/
SELECT :cmpdw_name FROM DUAL;
@&cmpdw_file

Rem =========================================================================
Rem END STAGE 2: downgrade installed components to previous release
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 3: downgrade actions always performed
Rem =========================================================================

Rem Remove all DataPump objects including all Metadata API types
@@catnodp

Rem Truncate export actions tables (reloaded during catrelod.sql)
truncate table noexp$;
truncate table exppkgobj$;
truncate table exppkgact$;
truncate table expdepobj$;
truncate table expdepact$;

Rem Drop dbms_rcvman (refers to new fixed views)
drop package dbms_rcvman;

Rem =========================================================================
Rem END STAGE 3: downgrade actions always performed
Rem =========================================================================

Rem =========================================================================
Rem BEGIN STAGE 4: downgrade dictionary to specified release
Rem =========================================================================

Rem First the "f" script is run which contains downgrade actions that
Rem call PL/SQL packages. These downgrade actions must be executed
Rem prior to running the "e" downgrade script in case the dropping of 
Rem dependent objects causes the packages to become invalid. 
Rem
Rem If your downgrade code references PL/SQL packages then update the "f" 
Rem downgrade_file to include these actions.
Rem

@@f&downgrade_file


Rem Downgrade dictionary objects
Rem The "e" downgrade file contains actions to downgrade data dictionary 
Rem objects. Code in the "e" downgrade script should not reference any
Rem PL/SQL packages.
Rem

@@e&downgrade_file

Rem =========================================================================
Rem Recompile any invalid indextypes to update object numbers
Rem with  ALTER INDEXTYPE ... USING
Rem =========================================================================

DECLARE
   cursor find_invld_idxtyp IS
              SELECT t.ityp_own, t.ityp_nam, t.typ_own, t.typ_nam
              FROM obj$ o, user$ u, ityp$temp1 t
              WHERE t.ityp_own = u.name and u.user# = o.owner#
                    and o.name = t.ityp_nam and o.status >1;
   alt_idxtyp_sql VARCHAR2(300);
   alt_typ_sql    VARCHAR2(300);

BEGIN
   FOR rec IN find_invld_idxtyp LOOP
        alt_typ_sql := 'ALTER TYPE ' || rec.typ_own || '.' 
                        || rec.typ_nam ||
                        ' COMPILE REUSE SETTINGS';
        alt_idxtyp_sql := 'ALTER INDEXTYPE ' || rec.ityp_own || '.' ||
                             rec.ityp_nam || ' USING ' || rec.typ_own ||
                          '.' || rec.typ_nam;
        BEGIN
           EXECUTE IMMEDIATE alt_typ_sql;
           EXECUTE IMMEDIATE alt_idxtyp_sql;
        EXCEPTION
           WHEN OTHERS THEN NULL;
        END;
   END LOOP;
END;
/

DROP TABLE ityp$temp1;

Rem =========================================================================
Rem END STAGE 4: downgrade dictionary to specified release
Rem =========================================================================

Rem put timestamps into spool log,registry$history, and registry$log
INSERT INTO registry$log (cid, namespace, operation, optime)
       VALUES ('DWGRD_END','SERVER',-1,SYSTIMESTAMP);
INSERT INTO registry$history (action_time, action)
        VALUES(SYSTIMESTAMP,'DOWNGRADE');
COMMIT;
SELECT 'COMP_TIMESTAMP DWGRD_END ' || 
        TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ')  || 
        TO_CHAR(SYSTIMESTAMP,'J SSSSS ')
        AS timestamp FROM DUAL;

Rem ***********************************************************************
Rem END catdwgrd.sql
Rem ***********************************************************************

