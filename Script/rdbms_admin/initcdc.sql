Rem
Rem $Header: rdbms/admin/initcdc.sql /main/12 2008/10/29 10:26:35 astoler Exp $
Rem
Rem initcdc.sql
Rem
Rem Copyright (c) 2000, 2008, Oracle and/or its affiliates. All rights reserved.
Rem
Rem    NAME
Rem      initcdc.sql - script used to load CDC jar files into the database
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      script must be run as SYS
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    astoler     10/07/08 - bug 6970590
Rem    mbrey       03/15/06 - bug 5092790 add datapump registration
Rem    pabingha    02/25/03 - fix undoc interfaces
Rem    wnorcott    03/14/02 - bug-2239726 disable triggers.
Rem    wnorcott    01/31/02 - function 'active' return 0 or 1.
Rem    wnorcott    01/30/02 - disable CDC triggers, CREATE_CHANGE_TABLE re-enables.
Rem    wnorcott    06/26/01 - rid trailing slash.  As per Mark Jungermann
Rem    gviswana    05/25/01 - CREATE OR REPLACE SYNONYM
Rem    jgalanes    11/17/00 - for Import/Export grant execute on util to 
REM                           SELECT_CATLOG_ROLE
Rem    wnorcott    09/07/00 - new loadjava syntax for performance.
Rem    wnorcott    07/18/00 - rid LOGMNR_UID$.clientid
Rem    wnorcott    06/28/00 - move logmnr_dict view here
Rem    wnorcott    03/28/00 - fix trigger install
Rem    wnorcott    03/27/00 - Install change table triggers
Rem    mbrey       01/26/00 - script to load CDC jars
Rem    mbrey       01/26/00 - Created
Rem
call sys.dbms_java.loadjava('-v -f -r -s -g public rdbms/jlib/CDC.jar');

REM
REM Data Pump support
REM
REM Register calls to support full-database export of CDC objects
REM (most processing is at schema level for future schema-level support,
REM but can only support database-level for 10iR1 because this is the
REM only level supported for Streams.)
REM
REM During export, CDC generates various import PL/SQL calls that
REM create CDC metadata rows during the import. The import calls do
REM not perform any validation on the new metadata rows except for
REM duplicate index errors.
REM
REM During export, CDC also creates, populates, exports and deletes an
REM import validation table for each schema that owns CDC objects. This
REM table is used to control validation of CDC objects during the import
REM after all schemas have been imported. This accounts for cases where,
REM for example, a change set owned by one publisher contains a change
REM table owned by a different publisher. During import, each schema's
REM import validation table is deleted after it has been processed.

DELETE FROM sys.exppkgact$
WHERE schema = 'SYS' AND package IN ('DBMS_CDC_EXPDP', 'DBMS_CDC_EXPVDP');

REM pre-system action generates call to bump system SCN
REM should execute early

INSERT INTO sys.exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_CDC_EXPDP', 'SYS', 1, 1);

REM pre-schema callout creates and populates schema's import validation table
REM post-schema callout drops schema's import validation table

INSERT INTO sys.exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_CDC_EXPDP', 'SYS', 6, 1000);

REM post-schema action generates PL/SQL calls to import CDC objects
REM (must be BEFORE Streams actions so that CDC metadata is present
REM  before Streams attempts to start any CDC apply handlers)

INSERT INTO sys.exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_CDC_EXPDP', 'SYS', 2, 1000);

REM post-schema action generates validation call for schema
REM (must be AFTER all CDC imports for all schemas have executed)
REM (must also be AFTER Streams actions for all schemas have executed
REM  so that Streams objects are present for validation)

INSERT INTO sys.exppkgact$ (package, schema, class, level#)
  VALUES ('DBMS_CDC_EXPVDP', 'SYS', 2, 6000);

REM
REM now set up the triggers
REM

CREATE OR REPLACE TRIGGER sys.cdc_alter_ctable_before
  BEFORE
    ALTER ON DATABASE
    BEGIN
      /* NOP UNLESS A TABLE OBJECT */
      IF dictionary_obj_type = 'TABLE' 
      THEN
        sys.dbms_cdc_ipublish.change_table_trigger(dictionary_obj_owner,dictionary_obj_name,sysevent);
      END IF;
      END;
/
CREATE OR REPLACE TRIGGER sys.cdc_create_ctable_after
  AFTER
    CREATE ON DATABASE
    BEGIN
      /* NOP UNLESS A TABLE OBJECT */
      IF dictionary_obj_type = 'TABLE' 
      THEN
        sys.dbms_cdc_ipublish.change_table_trigger(dictionary_obj_owner,dictionary_obj_name,sysevent);
      END IF;
      END;
/
CREATE OR REPLACE TRIGGER sys.cdc_create_ctable_before
  BEFORE
    CREATE ON DATABASE
    BEGIN
      /* NOP UNLESS A TABLE OBJECT */
      IF dictionary_obj_type = 'TABLE' 
      THEN
        sys.dbms_cdc_ipublish.change_table_trigger(dictionary_obj_owner,dictionary_obj_name,'LOCK');
      END IF;
      END;
/
CREATE OR REPLACE TRIGGER sys.cdc_drop_ctable_before
  BEFORE
    DROP ON DATABASE
    BEGIN
      /* NOP UNLESS A TABLE OBJECT */
      IF dictionary_obj_type = 'TABLE' 
      THEN
        sys.dbms_cdc_ipublish.change_table_trigger(dictionary_obj_owner,dictionary_obj_name,sysevent);
      END IF;
      END;
/
Rem    wnorcott    01/30/02 - disable CDC triggers, CREATE_CHANGE_TABLE 
Rem    re-enables them.  therefore database users who never use  CDC will
Rem    never execute the triggers
Rem
ALTER TRIGGER sys.cdc_alter_ctable_before DISABLE;
ALTER TRIGGER sys.cdc_create_ctable_after DISABLE;
ALTER TRIGGER sys.cdc_create_ctable_before DISABLE;
ALTER TRIGGER sys.cdc_drop_ctable_before DISABLE;

-- bug 6970590
--  Granting execute on dbms_cdc_utility to select_catalog_role is 
--  a security issue and granting to execute_catalog_role is safer, 
--  documentation specifies that the CDC publisher needs to have 
--  both of these role privs so functionality is unaffected
GRANT execute on sys.dbms_cdc_utility to execute_catalog_role;

    
