Rem
Rem $Header: dbmspitr.sql 29-jul-99.12:47:58 smuthuli Exp $
Rem
Rem dbmspitr.sql
Rem
Rem  Copyright (c) Oracle Corporation 1996, 1997, 1998, 1999. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmspitr.sql - tablespace point-in-time recovery functions
Rem
Rem    DESCRIPTION
Rem      This package contains a set of procedures using during
Rem      a tablespace point-in-time recovery.
Rem
Rem    NOTES
Rem      This package uses dynamic SQL to execute DDL statements.
Rem      CATPROC.SQL script should be run.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    smuthuli    07/29/99 - change prototype: tablespace migration
Rem    apareek     10/14/98 - bitmap support
Rem    wuling      10/14/98 - bitmap tablespace support
Rem    asurpur     01/13/97 - Adding grant on dbms_pitr to EXECUTE_CATALOG_ROLE
Rem    wuling      10/25/96 - change endTablespace
Rem    wuling      10/15/96 - Add exceptions
Rem    wuling      10/03/96 - Change timestamp type to number
Rem    wuling      09/11/96 - dropTablespaces -> commitPitr
Rem    wuling      08/07/96 - Interface changes
Rem    gpongrac    08/07/96 - add new emit interface
Rem    wuling      07/29/96 - Creation
Rem    gpongrac    08/03/95 - creation
Rem

CREATE OR REPLACE
PACKAGE dbms_pitr IS

  TS_PITR_VERSION  CONSTANT varchar2(15) := '8.1.5.0.0';

  ------------------
  -- Introduction --
  ------------------

  -- This package contains procedures which get called during the import
  -- phase and export phase of point-in-time recovery (PITR).
  --
  -- During the export phase, EXP calls this package to obtain the text
  -- of 2 anonymous PL/SQL blocks.  The first block goes at the front of 
  -- the .dmp file, and the second block goes at the end.  Inbetween the 2
  -- blocks are the DDL commands created by EXP to reconstruct the dictionary
  -- for the tablespaces being PITR'd.
  --
  -- The emitted PL/SQL code contains calls to other procedures in this
  -- package.  IMP must read each anonymous PL/SQL block from the .dmp file,
  -- collect it into a single contiguous memory buffer, and then parse
  -- and execute the PL/SQL block.  The parsed SQL statement (the plsql
  -- anonymous block) must precisely the lines of text that were returned
  -- to EXP from this package, with no characters added or deleted.
  --
  -- The "emit" procedures are intended to be called in the following sequence:
  -- 
  -- dbms_pitr.beginExport;
  --
  --   dbms_pitr.selectTablespace('tsname_1'); \
  --            :                               > called once per tablespace
  --   dbms_pitr.selectTablespace('tsname_N'); /
  --
  --   dbms_pitr.selectBlock(dbms_pitr.ts_pitr_begin);
  --
  --     dbms_pitr.getLine;  > called until it returns NULL 
  --
  --   dbms_pitr.selectBlock(dbms_pitr.ts_pitr_end);
  --
  --     dbms_pitr.getLine;  > called until it returns NULL
  --
  --
  -- In the exp.dmp file, it would look like:
  --   dbms_pitr.beginImport;
  --
  --   dbms_pitr.adjustCompatibility(...);
  --		:
  --
  --     dbms_pitr.beginTablespace(tsname);
  --     dbms_pitr.doFileVerify(...);
  --     	: 
  --     dbms_pitr.endTablespace;
  --
  --   dbms_pitr.commitPitr;
  --		
  --   dbms_pitr.endImport;


  -------------------------------
  -- Package Public Exceptions --
  -------------------------------

  pitr_others  EXCEPTION;
  PRAGMA exception_init(pitr_others, -29300);
  pitr_others_num NUMBER := -29300;

  wrong_order  EXCEPTION;
  PRAGMA exception_init(wrong_order, -29301);
  wrong_order_num NUMBER := -29301;

  database_not_open_clone  EXCEPTION;
  PRAGMA exception_init(database_not_open_clone, -29302);
  database_not_open_clone_num NUMBER := -29302;
  
  user_not_SYS  EXCEPTION;
  PRAGMA exception_init(user_not_SYS, -29303);
  user_not_SYS_num NUMBER := -29303;

  wrong_tsname  EXCEPTION;
  PRAGMA exception_init(wrong_tsname, -29304);
  wrong_tsname_num NUMBER := -29304;

  not_read_only  EXCEPTION;
  PRAGMA exception_init(not_read_only, -29305);
  not_read_only_num NUMBER := -29305;

  file_offline  EXCEPTION;
  PRAGMA exception_init(file_offline, -29306);
  file_offline_num NUMBER := -29306;

  file_error  EXCEPTION;
  PRAGMA exception_init(file_error, -29307);
  file_error_num NUMBER := -29307;

  pitr_check  EXCEPTION;
  PRAGMA exception_init(pitr_check, -29308);
  pitr_check_num NUMBER := -29308;

  wrong_package_version  EXCEPTION;
  PRAGMA exception_init(wrong_package_version, -29309);
  wrong_package_version_num NUMBER := -29309;

  not_open_primary  EXCEPTION;
  PRAGMA exception_init(not_open_primary, -29310);
  not_open_primary_num NUMBER := -29310;

  database_not_match  EXCEPTION;
  PRAGMA exception_init(database_not_match, -29311);
  database_not_match_num NUMBER := -29311;

  not_compatible  EXCEPTION;
  PRAGMA exception_init(not_compatible, -29312);
  not_compatible_num NUMBER := -29312;

  ts_twice  EXCEPTION;
  PRAGMA exception_init(ts_twice, -29313);
  ts_twice_num NUMBER := -29313;

  not_offline_for_recovery  EXCEPTION;
  PRAGMA exception_init(not_offline_for_recovery, -29314);
  not_offline_for_recovery_num NUMBER := -29314;

  tablespace_recreated  EXCEPTION;
  PRAGMA exception_init(tablespace_recreated, -29315);
  tablespace_recreated_num NUMBER := -29315;

  file_twice  EXCEPTION;
  PRAGMA exception_init(file_twice, -29316);
  file_twice_num NUMBER := -29316;

  no_datafile  EXCEPTION;
  PRAGMA exception_init(no_datafile, -29317);
  no_datafile_num NUMBER := -29317;

  file_online  EXCEPTION;
  PRAGMA exception_init(file_online, -29318);
  file_online_num NUMBER := -29318;

  import_file_error  EXCEPTION;
  PRAGMA exception_init(import_file_error, -29319);
  import_file_error_num NUMBER := -29319;

  fileheader_error  EXCEPTION;
  PRAGMA exception_init(fileheader_error, -29320);
  fileheader_error_num NUMBER := -29320;

  too_many_file  EXCEPTION;
  PRAGMA exception_init(too_many_file, -29321);
  too_many_file_num NUMBER := -29321;

--    EXCEPTION;
--  PRAGMA exception_init(, -);
--  _num NUMBER := -;


  -------------------------------------------
  -- PLSQL Anonymous Block Emit Procedures --
  -------------------------------------------

  PROCEDURE beginExport;

  -- This procedure initialize all private variables in dbms_pitr package.
  -- It must be called before any other procedure calls.
  -- It also checks if database is open clone; if user login as SYS.
  -- If there is any indoubt txn, the txn is abort.
  -- It also brings unnecessary tablespaces offline.
  --
  -- Exceptions:
  --   DATABASE_NOT_OPEN_CLONE (ORA-29302)
  --     database is not open as a clone database.
  --   USER_NOT_SYS (ORA-29303)
  --     user does not login as SYS
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.


  PROCEDURE selectTablespace( tsname  IN varchar2 );

  -- This procedure informs this package that the caller intends to do
  -- point-in-time recovery on the specified tablespace.  This procedure must
  -- be called once for each tablespace in the recovery set.
  -- It alter selected tablespace read only, also checks datafiles in the
  -- selected tablespace.
  --
  -- Input parameters:
  --   tsname
  --     The tablespace name.
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   WRONG_TSNAME (ORA-29304)
  --     select tablespace does not exist
  --   NOT_READ_ONLY (ORA-29305)
  --     cannot alter the tablespace read only
  --   FILE_OFFLINE (ORA-29306)
  --     datafile is not online
  --   FILE_ERROR (ORA-29307)
  --     datafile error
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.

  PROCEDURE selectBlock( blockId  IN binary_integer );

  -- This procedures selects a particular PL/SQL anonymous block for retrieval.
  -- The various blocks that may be selected are listed below as constant 
  -- public package variables.  
  -- When select the 1st block, selectBlock would check if there any crossing
  -- reference objects exist.
  -- After selectBlock is called, selectBlock cannot be called again until 
  -- getLine gets a NULL return.
  --
  -- Input parameters:
  --   blockId
  --     One of the public package constants defined below.
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   PITR_CHECK (ORA-29308)
  --     view TS_PITR_CHECK failure
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.

  ---------------
  -- Block IDs --
  ---------------

  TS_PITR_BEGIN  CONSTANT BINARY_INTEGER := 1;
  TS_PITR_END    CONSTANT BINARY_INTEGER := 2;


  FUNCTION getLine  RETURN varchar2;

  -- This function returns the next line of a block that has been
  -- previously selected for retrieval via selectBlock.
  --
  -- Returns:
  --   The next line of the block.  The maximum length of a line is 200
  --   characters.  NULL is returned when all lines of a block have
  --   been returned.
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.

  --------------------------------------
  -- PUBLIC Functions and Procedures --
  --------------------------------------

  -- The PLSQL code to call the following procedures/functions should
  -- be obtained only by calling the procedures described above.


  PROCEDURE beginImport( packageVersion  IN varchar2
			,databaseID      IN number
			,resetSCN        IN number
		        ,resetStamp      IN number
			,highestSCN      IN number );

  -- This procedure is called from an anonymous PL/SQL block embedded.  
  -- It checks package version, database ID, resetlog SCN and stamp.
  -- It also adjusts primary database SCN if necessary, and enable pseudo
  -- create syntax.
  --
  -- Input parameters:
  --   packageVersion
  --     The version number of the package that emitted the PL/SQL anonymous
  --     block.
  --   databaseID
  --     32 bits database ID.
  --   resetSCN
  --     Reset SCN expected in primary database.
  --   resetStamp
  --     Reset timesatmp expected in primary database.
  --   highestSCN
  --     It is the highest clean SCN of the tablespaces in the clone database.
  --     The production database needs to adjust the SCN if the highest clean
  --     SCN is larger than the SCN in production database.
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   WRONG_PACKAGE_VERSION (ORA-29309)
  --     packageVersion does not match the packageVersion in clone.
  --   NOT_OPEN_PRIMARY (ORA-29310)
  --     database is either not open or open as a clone.
  --   DATABASE_NOT_MATCH (ORA-29311)
  --     databaseID does not match the clone databaseID.
  --     reset scn and time stamp do not match the previous reset of the clone.
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.


  PROCEDURE adjustCompatibility( comID  IN varchar2
				,comRL  IN varchar2 );

  -- This routine checks the primary database compatibility segment.
  -- If an entry already exists in the clone databasebut not in the primary 
  -- database, then the entry is created. 
  -- If the primary compatible parameter does not recognize the format,
  -- then an error is returned. 
  -- 
  -- This is called once for each entry in the clone database compatibility 
  -- segment other than undo, bootstrap, and the compatibility segment itself.
  --
  -- Input parameters:
  --   comID
  --	Compatibility type id.
  --   comRL
  --	Current release level used by type comID.
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   NOT_COMPATIBLE (ORA-29312)
  --     current using database is not compatible with the database used 
  --     at the point-in-time
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.

  PROCEDURE beginTablespace( tsid       IN binary_integer
			    ,createSCN  IN number 
                            ,tsBitmap   IN number
                            ,tsFlags    IN number
                            ,tsSegfno   IN number
                            ,tsSegbno   IN number
                            ,tsSegsize  IN number);

  -- This procedure is called from an anonymous PL/SQL block embedded
  -- at the beginning of the .dmp file.  The anonymous block is parsed
  -- and executed by IMP.
  --
  -- Input parameters:
  --   tsid 
  --     The tablespace number undergoing point-in-time recovery. 
  --   createSCN
  --     Tablespace creation SCN.
  --   tsBitmap
  --     Is tablespace bitmapped
  --   tsFlags
  --     Other flags
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   TS_TWICE (ORA-29313)  
  --     tablespace has been imported already
  --   NOT_OFFLINE_FOR_RECOVERY (ORA-29314)  
  --     tablespace is not OFFLINE FOR RECOVERY nor READ ONLY
  --   TABLESPACE_RECREATED (ORA-29315)  
  --     tablespace has been recreated
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.

  PROCEDURE doFileVerify( fno         IN binary_integer
			 ,tsid        IN binary_integer
                         ,ckptSCN     IN number
			 ,resetSCN    IN number
			 ,resetStamp  IN number
                         ,filesize    IN number
                         ,hdba        IN number );

  -- This procedure must follow a beginTablespace call.  The file must
  -- be for the tablespace.  There must be one call for each datafile
  -- that is part of the tablespace (in the clone database).
  -- EXP shoud obtain the text for the call to this procedure by calling
  -- emitFileVerify.
  --
  -- Input parameters:
  --   fno
  --     Absolute datafile number
  --   tsid
  --     Corresponding tablespace number.
  --   ckptSCN
  --     The datafile checkpoint SCN.
  --   resetSCN
  --     Reset SCN in file header.
  --   resetStamp
  --     Reset timesatmp in file header.
  --   filesize
  --     The size of the file in blocks.
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   DATAFILE_TWICE (ORA-29316)
  --     datafile been imported twice
  --   NO_DATAFILE (ORA-29317)
  --     datafile not found
  --   FILE_ONLINE (ORA-29318)
  --     datafile online
  --   IMPORT_FILE_ERROR (ORA-29319)
  --     datafile header error
  --   FILEHEADER_ERROR (ORA-29320)
  --     datafile header error
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.

  PROCEDURE endTablespace( cleanSCN    IN number
			  ,resetSCN    IN number
			  ,resetStamp  IN number );

  -- This procedure must follow the last doFileVerify call.  Each
  -- beginTablespace call must have a matching endTablespace call.
  -- It builds a list of the files added between the current and the 
  -- recovery point-in-time.
  --
  -- Input parameters:
  --   cleanSCN
  --     tablespace clean SCN from the clone database.
  --   resetSCN
  --     tablespace resetlog SCN from the clone database.
  --   resetStamp
  --     tablespace resetlog time stamp from the clone database.
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.


  PROCEDURE commitPitr;

  -- This procedure is called after all tablespaces have been registered
  -- by beginTablespace and endTablespace.  This ICD actually drops the
  -- tablespaces in tspitr set on production database.
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   PITR_CHECK (ORA-29308)
  --     view TS_PITR_CHECK failure
  --   TOO_MANY_FILE (ORA-29321)
  --    too many datafile added since the point-in-time
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.


  PROCEDURE endImport;

  -- This procedure is called from an anonymous PL/SQL block embedded.  
  -- It provides recovery layer an entry point to do what it should do in  
  -- the end of importing.  It should be called in the end of IMPORT.
  -- It does nothing in this version.
  --
  -- Exceptions:
  --   WRONG_ORDER (ORA-29301)
  --     wrong dbms_pitr package functions/procedure order.
  --   PITR_OTHERS (ORA-29300)
  --     other oracle error.

END dbms_pitr;
/
GRANT EXECUTE ON dbms_pitr TO execute_catalog_role;






