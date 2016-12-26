Rem
Rem $Header: dbmslmd.sql 13-feb-2006.15:15:25 ajadams Exp $
Rem
Rem dbmslmd.sql
Rem
Rem Copyright (c) 1998, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmslmd.sql - DBMS Logminer Dictionary package specification 
Rem      for DBMS_LOGMNR_D 
Rem
Rem    DESCRIPTION
Rem	 This file contains the logminer package specification for DBMS_LOGMNR_D 
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ajadams     02/13/06 - create synonym 
Rem    abrown      09/13/05 - bug 3776830: unwind dictionary 
Rem    jnesheiw    02/17/05 - Bug 4028220 Relocated change history and logmnr
Rem                           metada creation to prvtlmd.sql
Rem    doshaugh    04/14/98 - Created
Rem
Rem
Rem  PUBLIC PROCEDURES
Rem
Rem     BUILD (FileName, FileLocation, Options)
Rem 
Rem     SET_TABLESPACE(NewTablespace);
Rem
Rem  PUBLIC CONSTANTS
Rem
Rem     STORE_IN_FLAT_FILE
Rem
Rem     STORE_IN_REDO_LOGS
Rem
Rem     MARK_SAFE_MINE_POINT
Rem     
Rem
Rem

-- --------------------------------------------------------------
--
CREATE or REPLACE PACKAGE dbms_logmnr_d AS
--
--    PACKAGE NAME
--      dbms_logmnr_d
--
--    DESCRIPTION
--      This package contains Logminer Dictionary related procedures.
--      "build" is used to gather the logminer dictionary.
--
--      "set_tablespace" is used to alter the default tablespace of
--      Logminer tables.
--
--      BUILD
--      The logminer dictionary can be gathered
--      into a flat file (Logminer V1 behavior) or it can be gathered
--      into the redo log stream.
--
--      When creating a Flat File dictionary the procedure queries the
--      dictionary tables of the current database and creates a text based
--      file containing their contents. Each table is represented by
--      "pseudo" SQL statements. A description of the columns in a 
--      table is created by a "CREATE_TABLE" line (one statement for
--      table). It contains the name, datatype and length for each 
--      column. A "INSERT_INTO" statement is created for each row in a 
--      selected table. It contains the values for each row. The file
--      is created in preparation of future analysis of databases
--      log files using the logminer tool.
--
--      When gathering the system dictionary into the logstream the procedure
--      queries the dictionary tables inserting the results into a special
--      set of Logminer Gather tables (SYS.LOGMNRG_*).  A side effect of
--      each query is that the resultant inserts cause redo to be generated.
--      Down stream processing can mine this redo to determine the contents
--      of this system's system dictionary at the time this procedure was
--      executed.
-- 
--      NOTE:  Database must be in "Archivelog Mode" and supplemental logging
--             must be enabled for this procedure to run
--
--      BUILD INPUTS
--      dictionary_filename - name of the dictionary file
--      dictionary_location - path to file directory
--      options - To explicitly indicate flat file or log stream destination.
-- 
--      BUILD EXAMPLE1
--      Creating a dictionary file as:
--                   /usr/ora/dict.ora
--      Complete syntax, typed all on one line:
--
--      SQL> execute dbms_logmnr_d.build('dict.ora',
--                                       '/usr/ora',
--                                       DBMS_LOGMNR_D.STORE_IN_FLAT_FILE);
--
--      BUILD EXAMPLE2
--      Creating a dictionary file as:
--                   /usr/ora/dict.ora
--      Logminer V1 syntax.
--
--      SQL> execute dbms_logmnr_d.build('dict.ora', '/usr/ora');
--
--      BUILD EXAMPLE3
--      Gathering a dictionary into the log stream
--      Complete syntax, typed all on one line:
--
--      SQL> execute dbms_logmnr_d.build('', '',
--                                          DBMS_LOGMNR_D.STORE_IN_REDO_LOGS);
--
--      BUILD NOTES
--      The dictionary gather should be done after all dictionary
--      changes to a database and prior to the creation of any log
--      files that are to be analyzed.
--
--
--      SET_TABLESPACE
--      By default all Logminer tables are created to use the SYSAUX
--      tablespace.  All users will find it desirable to alter Logminer
--      tables to employ an alternate tablespace.  Use this routine to
--      recreate all Logminer tables in an alternate tablespace.
--
--      SET_TABLESPACE INPUTS
--      new_tablespace         - a string naming a preexistant tablespace.
--

STORE_IN_FLAT_FILE CONSTANT INTEGER := 1;
STORE_IN_REDO_LOGS CONSTANT INTEGER := 2;
MARK_SAFE_MINE_POINT  CONSTANT INTEGER := 8;

PROCEDURE  build
		(dictionary_filename IN VARCHAR2 DEFAULT '',
		 dictionary_location IN VARCHAR2 DEFAULT '',
                 options IN NUMBER DEFAULT 0);

--
--
PROCEDURE set_tablespace( new_tablespace IN VARCHAR2 );
--
--
END dbms_logmnr_d; -- End Definition of package
/

CREATE OR REPLACE PUBLIC SYNONYM dbms_logmnr_d FOR sys.dbms_logmnr_d;

