rem 
rem $Header: catsvrmg.sql 24-may-2001.14:38:27 gviswana Exp $ 
rem 
Rem  Copyright (c) 1991, 1996 by Oracle Corporation 
Rem    NAME
Rem      catsvrmg.sql - Create the views and tables required for Server Manager
Rem    DESCRIPTION
Rem      
Rem    RETURNS
Rem 
Rem    NOTES
Rem      Connects as internal (no password)
Rem    MODIFIED   (MM/DD/YY)
Rem     gviswana   05/24/01 - CREATE AND REPLACE SYNONYM
Rem     asurpur    04/08/96 - Dictionary Protection Implementation
Rem     dbuchhei   11/30/95 - update version to 7.3.2
Rem     dsternbe   02/21/95 - merge 214 into main line
Rem     dsternbe   02/16/95 - merge
Rem     dsternbe   02/16/95 - update version to 7.2.2
Rem     kzabora    12/19/94 - change version number
Rem     kzabora    10/27/94 - comment out v$pwfile view
Rem     kzabora    10/27/94 - comment out v$pwfile view
Rem     kzabora    10/25/94 - Update SM_$VERSION
Rem     kzabora    10/12/94 - update views version number
Rem     kzabora    09/15/94 - Update sm$version
Rem     barthur    08/30/94 - Added versioning to the modified actions so we st
Rem     barthur    08/30/94 -
Rem     barthur    08/29/94 -  Add SQL to create public.v$pwfile_users
Rem     barthur    08/29/94 -  Add SQL to create public.v$pwfile_users
Rem     sstorkel   05/05/94 -  Creation 
Rem     msinykin   01/25/94 -  update version number 
Rem     barthur    01/23/94 -  Remove the sm$security items we no longer need 
Rem     barthur    01/11/94 -  Add DROP SYS.SM$ROLE_TREE
Rem     barthur    12/30/93 -  Add new views and table for improvements to secu
Rem     ameyer     10/28/93 -  Updated version number to match database (7.1.2)
Rem     ameyer     10/21/93 -  Fixed sm$version.version_number to be VSNNUMBER.
Rem                         -  Also removed old tables and @@catnosvm.sql
Rem     ameyer     10/12/93 -  Added sm$version and comments. 
Rem     durry      09/22/93 -  add public alias for v$sess_io 
Rem     sstorkel   09/10/93 -  Remove connect command. 
Rem     barthur    07/30/93 -  Change sm$ts view for the new tablespace select 
Rem     msinykin   06/21/93 -  Clean up views. 
Rem     barthur    05/07/93 -  Creation 

REM List of Server Manager Tables and views
REM These need to be created by SYS when Server Manager is installed.
REM
REM This script needs to be run as INTERNAL or SYS
REM

REM For debugging
REM set echo ON

REM You *must* be connected as SYS or INTERNAL for this script to
REM work correctly.

REM sm$version
REM Version_number is conceptually VSNNUMBER(version_text).
REM In the case of '7.1.2.0.0', it's hex 0x07102000
REM converted to decimal 118497280.
create or replace view sys.sm_$version as
    select '7.3.2.0.0' version_text, 120594432 version_number, created
    from sys.dba_objects where owner = 'SYS' and object_name = 'SM_$VERSION';
grant select on sys.sm_$version to public;
create or replace public synonym sm$version for sys.sm_$version;

REM sm$ts_avail
create or replace view sys.sm$ts_avail as
    select tablespace_name, sum(bytes) bytes from dba_data_files
    group by tablespace_name;
grant select on sys.sm$ts_avail to select_catalog_role;

REM sm$ts_used
create or replace view sys.sm$ts_used as
    select tablespace_name, sum(bytes) bytes from dba_segments
    group by tablespace_name;
grant select on sys.sm$ts_used to select_catalog_role;

REM sm$ts_free
create or replace view sys.sm$ts_free as
    select tablespace_name, sum(bytes) bytes from dba_free_space
    group by tablespace_name;
grant select on sys.sm$ts_free to select_catalog_role;

REM sm$audit_config
create or replace view sys.sm$audit_config
    ( audit_type, schema_user, audit_target) as
    select 'Object', owner, object_type || ' ' || object_name
    from sys.dba_obj_audit_opts
    where ALT != '-/-' OR AUD != '-/-' OR COM != '-/-' OR DEL != '-/-'
       OR GRA != '-/-' OR IND != '-/-' OR INS != '-/-' OR LOC != '-/-'
       OR REN != '-/-' OR SEL != '-/-' OR UPD != '-/-' OR FBK != '-/-'
       OR EXE != '-/-'
    union all select 'Privilege', user_name, privilege
    from sys.dba_priv_audit_opts
    union all select 'Statement', user_name, audit_option
    from sys.dba_stmt_audit_opts;
grant select on sys.sm$audit_config to select_catalog_role;

REM sm$integrity_cons
create or replace view sys.sm$integrity_cons as
select owner || '.' || table_name table_name, constraint_name,
    decode(status, 'ENABLED', 'Y', NULL) enabled from sys.dba_constraints;
grant select on sys.sm$integrity_cons to select_catalog_role;

REM Now, make v$sess_io public.
REM This is here as a workaround for bug #149629.  Basically, there is a bug
REM in catalog.sql.  It fails to create the view and public synonym for
REM v$sess_io.  This makes it impossible for regular DBA's to run monitors
REM using this view.
REM This should disappear at some point.
create or replace view sys.v_$sess_io as select * from sys.v$sess_io;
create or replace public synonym v$sess_io for sys.v_$sess_io;
grant select on sys.v_$sess_io to select_catalog_role;

REM The following view and public synonym are created as part of catalog.sql
REM in versions 7.1.5 and greater.  If you are using Server Manager to 
REM administer a 7.1.3 or 7.1.4 rdbms, you may have to uncomment the 
REM following lines and run this portion of the script.

REM Add SQL to create the public.v$pwfile_users
REM create or replace view sys.v_$pwfile_users as 
REM     select * from sys.v$pwfile_users;
REM create or replace public synonym v$pwfile_users for sys.v_$pwfile_users;

