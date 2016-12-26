Rem
Rem $Header: dbmsmap.sql 29-jan-2002.17:05:27 gviswana Exp $
Rem
Rem dbmsmap.sql
Rem
Rem Copyright (c) 2001, 2002, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      dbmsmap.sql - DBMS Storage Map package for administrators.
Rem
Rem    DESCRIPTION
Rem      Specification for storage map interface
Rem
Rem    NOTES
Rem      Going to make some trusted callouts to server with this package.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    01/29/02 - CREATE OR REPLACE SYNONYM
Rem    wojeil      11/28/01 - change permissions from public to dba.
Rem    wojeil      11/21/01 - adding map_object procedure.
Rem    wojeil      09/10/01 - Merged wojeil_emc_project
Rem    mlfeng      07/19/01 - dbms_storage_map package
Rem    mlfeng      07/19/01 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_storage_map AUTHID CURRENT_USER AS

  --
  -- map_object()
  -- builds the mapping information for the object identified by
  -- objname.
  --
  -- Input arguments:
  --   objname			- name of object
  --   objtype                  - object type
  --

  PROCEDURE map_object(objname IN VARCHAR2,
                       owner   IN VARCHAR2,
		       objtype IN VARCHAR2
		       );    

  --
  -- map_element()
  -- builds the mapping information for the element identified by
  -- elemname.
  --
  -- Input arguments:
  --   elemname			- name of element
  --   cascade			- cascade parameter, if true, all elements 
  --				  within the I/O stack DAG for elemname
  --				  are mapped.
  --   dictionary_update	- if true, mapping info in data dictionary
  --				  is updated to reflect changes
  --

  PROCEDURE map_element(elemname IN VARCHAR2,
			cascade IN BOOLEAN,
			dictionary_update IN BOOLEAN DEFAULT TRUE
			);
			
  --
  -- map_file()
  -- builds the mapping info for the file identified by filename
  --
  -- Input arguments:
  --   file			- name of file
  --   filetype			- type of file, 'datafile', 'spfile', 
  --				  'tempfile', 'controlfile', 'logfile',
  --				  'archivefile'
  --   cascade			- cascade parameter, if true, mapping DAGs are
  --				  also built for elements where file resides
  --   max_num_fileextent	- the maximum number of file extents to 
  --				  be mapped
  --   dictionary_update	- if true, update data dictionary w/ map info
  --

  PROCEDURE map_file(filename IN VARCHAR2,
		     filetype IN VARCHAR2,
		     cascade IN BOOLEAN,
		     max_num_fileextent IN NUMBER DEFAULT 100,
		     dictionary_update IN BOOLEAN DEFAULT TRUE
		     );

  --
  -- map_all()
  -- builds the entire mapping info for all Oracle data files including
  -- DAG elements
  --
  -- Input arguments:
  --   max_num_fileext          - the maximum number of file extents to 
  --				  be mapped
  --   dictionary_update	- if true, update data dictionary w/ map info
  --

  PROCEDURE map_all(max_num_fileextent IN NUMBER DEFAULT 100,
		    dictionary_update IN BOOLEAN DEFAULT TRUE
		    );


  --
  -- drop_element()
  -- drops mapping info for the element defined by elemname
  --
  -- Input arguments:
  --   elemname			- name of element
  --   cascade			- cascade parameter, if true, all elements 
  --				  within the I/O stack DAG for elemname
  --				  are dropped.
  --   dictionary_update	- if true, mapping info in data dictionary
  --				  is updated to reflect changes
  --

  PROCEDURE drop_element(elemname IN VARCHAR2,
			 cascade IN BOOLEAN,
			 dictionary_update IN BOOLEAN DEFAULT TRUE
			 );

  --
  -- drop_file()
  -- drop the file mapping infor defined by filename
  --
  -- Input arguments:
  --   filename			- name of file
  --   cascade			- cascade parameter, mapping DAGs for elements
  --				  where the file resides are dropped
  --   dictionary_update	- if true, update data dictionary
  --

  PROCEDURE drop_file(filename IN VARCHAR2,
		      cascade IN BOOLEAN,
		      dictionary_update IN BOOLEAN DEFAULT TRUE
		      );

  --
  -- drop_all()
  -- drop all mapping information in the shard memory of the instance
  --
  --   dictionary_update	- if true, update data dictionary
  --

  PROCEDURE drop_all(dictionary_update IN BOOLEAN DEFAULT TRUE
		     );

  --
  -- save()
  -- This function saves into the data dictionary the required information
  -- needed to regenerate the entire mapping information.
  --

  PROCEDURE save;

  --
  -- restore()
  -- This function restores the entire mapping information from the data
  -- dictionary into the shared memory of the instance. restore() needs to
  -- be explicitly called in a warm startup scenario. restore() can only
  -- be invoked after a save() operation.
  --

  PROCEDURE restore;
  
  --
  -- lock_map()
  -- This function locks the mapping information in the shared memory of 
  -- the instance in either shared or exclusive mode
  -- 
  -- Input argument:
  --   lock_mode - locking mode - 'SHARED' or 'EXCLUSIVE'
  --
  
  PROCEDURE lock_map;

  --
  -- unlock_map()
  -- This function unlocks the mapping information in the shared memory
  -- of the instance
  --

  PROCEDURE unlock_map;

END dbms_storage_map;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_storage_map FOR sys.dbms_storage_map
/
GRANT EXECUTE ON dbms_storage_map TO dba
/
-- create the trusted pl/sql callout library
CREATE OR REPLACE LIBRARY DBMS_MAP_LIB TRUSTED AS STATIC;
/
