Rem
Rem $Header: rdbms/admin/cmpdwpth.sql /st_rdbms_11.2.0/2 2013/03/18 12:08:30 mjaeger Exp $
Rem
Rem cmpdwpth.sql
Rem
Rem Copyright (c) 2007, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      cmpdwpth.sql - CoMPonent DoWngrade for PaTcH releases
Rem
Rem    DESCRIPTION
Rem      This script just runs downgrades for components that
Rem      require patch downgrade actions.   Most components
Rem      do not require any patch downgrade actions, so the
Rem      list is shorter than for major release downgrades.
Rem
Rem    NOTES
Rem      Invoked by catdwgrd.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mjaeger     03/12/13 - bug 16398444: downgrade XDK for Java
Rem    mjungerm    07/07/11 - drop sros - bug 12728759
Rem    vigaur      06/02/10 - Add support for dve112.sql
Rem    cmlim       05/26/10 - lrg 4672945 - invoke ctxe112.sql
Rem    badeoti     05/07/10 - disable xdk schema caching for inserts into csx
Rem                           tables during migrations
Rem    cmlim       05/03/10 - bug 9653608 - invoke OWM too in downgrade patch
Rem                           from 112
Rem    badeoti     03/09/10 - add XDB patch downgrade
Rem    cdilling    09/18/09 - add ORDIM patch downgrade
Rem    rburns      12/10/07 - component patch downgrade
Rem    rburns      12/10/07 - Created
Rem

Rem=========================================================================
Rem BEGIN Component patch downgrades
Rem=========================================================================

Rem Setup component script filename variable
COLUMN dbdwg_name NEW_VALUE dbdwg_file NOPRINT;

-- set xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context forever, level 0x8000';

Rem ======================================================================
Rem Downgrade Data Vault
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('DV') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('DV') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Spatial
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('SDO') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('SDO') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Intermedia
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('ORDIM') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('ORDIM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade Oracle Workspace Manager
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('OWM') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('OWM') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade XDB - XML Database
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XDB') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('XDB') AS timestamp FROM DUAL;

-- clear xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context off';

Rem ======================================================================
Rem Downgrade CTX - CONTEXT
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('CONTEXT') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('CONTEXT') AS timestamp FROM DUAL;

Rem ======================================================================
Rem Downgrade XML - XDK for Java
Rem ======================================================================

SELECT dbms_registry_sys.dbdwg_script('XML') AS dbdwg_name FROM DUAL;
@&dbdwg_file
SELECT dbms_registry_sys.time_stamp('XML') AS timestamp FROM DUAL;

Rem=========================================================================
Rem JAVAVM actions for jvmrelod.sql in lieu of jvme112
Rem=========================================================================

BEGIN
  EXECUTE IMMEDIATE '
    begin initjvmaux.drop_sros; end;
    ';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE '
    UPDATE java$jvm$status SET action=''DOWNGRADE'', inprogress = ''N'',
         punting=''FALSE''
    ';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

Rem=========================================================================
Rem END Component patch downgrades
Rem=========================================================================

