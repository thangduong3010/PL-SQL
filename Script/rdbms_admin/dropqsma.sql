Rem
Rem $Header: rdbms/src/server/summgmt/advisor/dropqsma.sql /st_rdbms_11.2.0.4.0dbpsu/1 2014/10/14 06:16:53 mthiyaga Exp $
Rem
Rem dropqsma.sql
Rem
Rem Copyright (c) 2013, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dropqsma.sql - Drop all QSMA specific public synonyms.
Rem
Rem    DESCRIPTION
Rem      In 9.2 and 10g, certain QSMA specific public synonyms are created
Rem      QSMA.JAR, which is called from rdbms/admin/initqsma.sql. These
Rem      synonyms are not required in 11.* and higher releases, and can be
Rem      safely dropped by running this script.
Rem
Rem    NOTES
Rem      This script needs to be run as dba
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mthiyaga    07/18/13 - Drop QSMA Public Synonyms
Rem    mthiyaga    07/18/13 - Created
Rem
Rem    BEGIN SQL_FILE_METADATA 
Rem    SQL_SOURCE_FILE: rdbms/src/server/summgmt/advisor/dropqsma.sql 
Rem    SQL_SHIPPED_FILE: 
Rem    SQL_PHASE: 
Rem    SQL_STARTUP_MODE: NORMAL 
Rem    SQL_IGNORABLE_ERRORS: NONE 
Rem    SQL_CALLING_FILE: 
Rem    END SQL_FILE_METADATA

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100


Rem Begin Drop SQL Advisor Synonyms
Rem ===============================

Rem First display any QSMA synonyms present
Rem
SELECT synonym_name FROM dba_synonyms WHERE lower(SYNONYM_NAME) LIKE '%qsma%';

Rem Drop all summary advisor related public synonyms created by QSMA.JAR,
Rem which is called from $ORACLE_HOME/rdbms/admin/initqsma.sql IN 10.2.

BEGIN
   FOR cur_rec IN (SELECT synonym_name
                     FROM dba_synonyms
                    WHERE synonym_name LIKE '%oracle/qsma/Qsma%' OR
                          synonym_name LIKE '%oracle/qsma/Char%' OR
                          synonym_name LIKE '%oracle/qsma/Parse%' OR
                          synonym_name LIKE '%oracle/qsma/Token%' OR
                          synonym_name LIKE '%_QsmaReport%' OR
                          synonym_name LIKE '%_QsmaSql%'
                   )
   LOOP
      BEGIN
         IF (cur_rec.synonym_name LIKE '%oracle/qsma/Qsma%' OR
             cur_rec.synonym_name LIKE '%oracle/qsma/Char%' OR
             cur_rec.synonym_name LIKE '%oracle/qsma/Parse%' OR
             cur_rec.synonym_name LIKE '%oracle/qsma/Token%' OR
             cur_rec.synonym_name LIKE '%_QsmaReport%' OR
             cur_rec.synonym_name LIKE '%_QsmaSql%')
           THEN
              EXECUTE IMMEDIATE 'DROP PUBLIC SYNONYM '
                            || DBMS_ASSERT.ENQUOTE_NAME(cur_rec.synonym_name, FALSE);
           END IF;
      EXCEPTION
         WHEN OTHERS
         THEN
             DBMS_SYSTEM.ksdwrt(DBMS_SYSTEM.trace_file,'FAILED: DROP '
                                  || '"'
                                  || cur_rec.synonym_name
                                  || '"');
      END;
   END LOOP;
END;
/


Rem Display any QSMA synonyms currently present. There should be no synonyms now.
Rem
SELECT synonym_name FROM dba_synonyms WHERE lower(SYNONYM_NAME) LIKE '%qsma%';

Rem ===============================
Rem End Drop SQL Advisor Synonyms
Rem ===============================


