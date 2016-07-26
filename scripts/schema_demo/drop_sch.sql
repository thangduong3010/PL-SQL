Rem
Rem $Header: rdbms/demo/schema/drop_sch.sql /main/1 2009/04/03 15:56:48 cbauwens Exp $
Rem
Rem drop_sch.sql
Rem
Rem Copyright (c) 2009, Oracle and/or its affiliates.All rights reserved. 
Rem
Rem    NAME
Rem      drop_sch.sql
Rem
Rem    DESCRIPTION
Rem      Drops all Sample Schemas (HR,OE,IX,PM,SH)
Rem
Rem    NOTES
Rem      Must be run as SYSTEM
Rem      
Rem      CAUTION: Never use the above mentioned Sample Schemas for
Rem               anything other than demos and examples.
Rem      CAUTION: Do not use this script if you have production user accounts
Rem               named HR,OE,IX,PM,SH
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    cbauwens    03/05/09 - Drop Sample Schemas
Rem    cbauwens    03/05/09 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 120
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET PAUSE OFF

COLUMN object_name      FORMAT A30
COLUMN object_type      FORMAT A20
COLUMN owner            FORMAT A6
COLUMN schema_owner     FORMAT A16
COLUMN status           FORMAT A8



PROMPT 
PROMPT specify password for SYSTEM:
DEFINE pwd_system

PROMPT specify spoolfile name:
DEFINE spl_file
PROMPT 

CONNECT system/&pwd_system
SPOOL &spl_file

Rem ******** List schemas and objects ********
PROMPT
PROMPT All user named objects owned by schema accounts

 SELECT   owner, object_type, object_name, status
 FROM     dba_objects
 WHERE    owner in ('HR','OE','SH','PM','IX','BI')
 AND      object_name NOT LIKE 'SYS%'
 ORDER BY 1,2,3,4;


PROMPT
PROMPT All SYS named objects owned by schema accounts

 SELECT    owner, object_type, object_name, status
 FROM     dba_objects
 WHERE    owner in ('HR','OE','SH','PM','IX','BI')
 AND      object_name LIKE 'SYS%'
 ORDER BY 2,1,3;

Rem ******** Drop Sample Schemas, cascade to objects ********
PROMPT
PROMPT Dropping Sample Schemas

DROP USER hr CASCADE;
DROP USER oe CASCADE;
DROP USER pm CASCADE;
DROP USER ix CASCADE;
DROP USER sh CASCADE;
DROP USER bi CASCADE;


Rem ******** Verify that all Sample Schemas and objects have been dropped ********
PROMPT
PROMPT Verifying drop of Sample Schemas

SELECT   owner, object_type, object_name
 FROM     dba_objects
 WHERE    owner in ('HR','OE','SH','PM','IX','BI')
 ORDER BY 1,2,3;

SPOOL OFF
UNDEFINE pwd_system
UNDEFINE spl_file

PROMPT
PROMPT ALL Sample Schemas have been dropped.
