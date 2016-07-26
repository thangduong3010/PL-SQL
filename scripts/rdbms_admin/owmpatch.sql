Rem
Rem $Header: ovmpatch.sql 24-oct-2006.09:28:19 bspeckha Exp $
Rem
Rem ovmpatch.sql
Rem
Rem Copyright (c) 2002, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      ovmpatch.sql - Patch script
Rem
Rem    DESCRIPTION
Rem          The "patch" script is used to apply bug fixes to the component. 
Rem          It is run in the context of catpatch.sql, after the RDBMS catalog.sql 
Rem          and catproc.sql scripts are run. It is run with a special EVENT 
Rem          set which causes CREATE OR REPLACE statements to only recompile 
Rem          objects if the new source is different than
Rem          the source stored in the database. Tables, types, and public 
Rem          interfaces should not be changed by patch scripts. 
Rem          
Rem                 ALTER SESSION SET CURRENT_SCHEMA = MYCSYS;
Rem                 EXECUTE dbms_registry.loading('MYC','My Component Name');
Rem                 Rem Only reload views, private PL/SQL types and packages, and type/package bodies
Rem                 @@mycpvs.plb
Rem                 @@mycview.sql
Rem                 @@myctyb.plb
Rem                 @@mycplb.plb
Rem                  
Rem                 Rem Reload classes if Java is in the database
Rem                 COLUMN file_name NEW_VALUE comp_file NOPRINT;
Rem                 SELECT dbms_registry.script('JAVAVM','@initmyc.sql') AS file_name FROM DUAL;
Rem                 @comp_file
Rem                 EXECUTE dbms_registry.loaded('MYC'); /* uses RDBMS release version number */
Rem                 EXECUTE myc_validate;
Rem                 ALTER SESSION SET CURRENT_SCHEMA = SYS;
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bspeckha    10/24/06 - moving everything to wmsys
Rem    saagarwa    11/19/02 - Add calls in the begining and end
Rem    saagarwa    08/13/02 - Invoke owmuany
Rem    saagarwa    07/31/02 - Patch script can be same as upgrade script for OWM
Rem    saagarwa    07/28/02 - saagarwa_conflict_view_perf_fix_and_922_scripts
Rem    saagarwa    07/23/02 - Created
Rem

WHENEVER SQLERROR EXIT;
EXECUTE dbms_registry.check_server_instance;
WHENEVER SQLERROR CONTINUE;

@@owmuany.plb

Rem == dbms_registry.loaded called in the above scripts ==
