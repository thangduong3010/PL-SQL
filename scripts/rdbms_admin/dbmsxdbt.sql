Rem
Rem $Header: rdbms/admin/dbmsxdbt.sql /main/11 2009/10/08 17:21:09 attran Exp $
Rem
Rem dbmsxdbt.sql
Rem
Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsxdbt.sql - XDB conText index setup
Rem
Rem    DESCRIPTION
Rem      Useful routines and scripts for conText indexes on XDB
Rem
Rem    NOTES
Rem      Must be connected as SYS to run this script
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    attran      09/09/09 - 8915200 - IFILTER -> PolicyFilter
Rem    badeoti     03/19/09 - dbms_xdbz.get_username moved to dbms_xdbz0
Rem    llsun       06/19/08 - bug 7137308: xdb.dbms_xdbt
Rem    petam       02/04/05 - fix for bug 4148632 
Rem    najain      06/05/03 - dont use XDB_RESINFO
Rem    najain      08/01/03 - 3071986: index more fields
Rem    smuralid    01/08/03 - dbms_xdbt: ctx security rewrite
Rem    sichandr    10/03/02 - getCharsetId: handle Oracle names too
Rem    rshaikh     08/08/02 - bug2456600: change IndexMemory to be 
Rem                           equal to MAX_INDEX_MEMORY
Rem    smuralid    01/28/02 - globalization support
Rem    smuralid    01/24/02 - Merged smuralid_repos_search
Rem    smuralid    01/23/02 - Created
Rem

Rem
Rem Make sure that XDB can see these packages
Rem
GRANT EXECUTE ON ctxsys.ctx_ddl TO xdb;
GRANT EXECUTE ON ctxsys.ctx_output TO xdb;
GRANT ctxapp TO xdb;

Rem
Rem Package to simplify context index creation on XDB 
Rem
CREATE OR REPLACE PACKAGE xdb.dbms_xdbt AUTHID CURRENT_USER IS

  ------------
  --  OVERVIEW
  --
  --    This package provides utilities for creating and managing conText
  --    indexes on the XDB repository.
  --
  --    The preferred mode of operation is as follows
  --    (a) drop any existing preferences. dbms_xdbt.dropPreferences
  --    (b) re-create preferences for the index 
  --        (dbms_xdbt.createPreferences)
  --    (c) Create the index
  --        (dbms_xdbt.createIndex)
  --        Verify that things have gone smoothly using
  --          "select * from ctx_user_index_errors"
  --    (d) Setup automatic sync'ing of the index
  --        (dbms_xdbt.configureAutoSync)
  --    (e) Sit back and relax
  --
  --    The package spec contains a a list of package variables that
  --    describe the configuration settings. These are intended to
  --    cover some of the more basic customizations that installations
  --    might require, but is not intended to be a complete set.
  --
  --    There are 2 ways to customize this package.
  --    (a) Use a PL/SQL procedure to set the appropriate package variables
  --        that control the relevant configurations, and then execute 
  --        the package. Obviously, this only applies to the set of existing
  --        package variables
  --    (b) The more general approach is to modify (in place, or as a copy)
  --        this package to introduce the appropriate customizations 
  --
  --    For instance, if you need to change the amount of memory available
  --    for indexing, you could use option (a). 
  --
  --    NOTES:
  --      If you're using this package as is, please note the following
  --    (a) Make sure that the LOG_DIRECTORY parameter is set using 
  --        ctx_adm.set_parameter
  --        Alternately, turn off rowid logging by setting the 
  --        'LogFile' package variable to the empty string.
  --    (b) Make sure that the MAX_INDEX_MEMORY parameter is at least 
  --        128M. Other change the package variable 'IndexMemory' 
  --        appropriately
  --      
  ------------  

TYPE varcharset IS TABLE OF VARCHAR2(100);

-------------------------------------------------------------
-- CONSTANTS
-------------------------------------------------------------

----------------------
-- FILTERING OPTIONS
--
-- The following constants describe the kinds of filtering we may want
-- to do.
-- USE_NULL_FILTER simply sends the document over to the charset converter
-- USE_INSO_FILTER uses the IFILTER api of INSO to convert the document
--    into HTML
-- SKIP_DATA is used to completely ignore the document's contents for
-- filtering. (The document metadata is indexed, however)  
---------------------- 

USE_NULL_FILTER            CONSTANT PLS_INTEGER := 1;
USE_INSO_FILTER            CONSTANT PLS_INTEGER := 2;
SKIP_DATA                  CONSTANT PLS_INTEGER := 3;

----------------------
-- Sync options
--
-- There are basically two mechanisms of automatic sync provided here.
-- SYNC_BY_PENDING_COUNT indicates that when the number of entries in the
--   pending queue reaches a threshold, it is time to sync up the index
-- SYNC_BY_TIME indicates that the index should be synced up at regular 
--   intervals
-- SYNC_BY_PENDING_COUNT_AND_TIME is a combination of both these strategies
--
----------------------
SYNC_BY_PENDING_COUNT      CONSTANT PLS_INTEGER := 1;
SYNC_BY_TIME               CONSTANT PLS_INTEGER := 2;
SYNC_BY_PENDING_COUNT_AND_TIME CONSTANT PLS_INTEGER := 3;
SyncTimeOut                NUMBER := NULL;

-----------------------------------------------------------------------
-- CONFIGURATION SETTINGS
--
-- This section contains the default settings for the index. This
-- section should be changed as appropriate.
-- 
-----------------------------------------------------------------------
-- The name of the context index
IndexName         CONSTANT VARCHAR2(32) := 'XDB$CI';

-- The default memory to be used for index creation and sync
-- NOTE: This must be less than (or equal to) the MAX_INDEX_MEMORY
--       parameter
IndexMemory       CONSTANT VARCHAR2(32) := '50M';


-------------------------------------------------------------
-- SYNC OPTIONS
-------------------------------------------------------------
-- The following section describes the automatic sync policy. 
-- By default, the auto-sync policy (once it has been configured)
-- is to sync based on the pending count.

-- Should we sync up based on pending count, or time or both ?
AutoSyncPolicy             PLS_INTEGER := SYNC_BY_PENDING_COUNT;

-- This parameter determines the maximum size of the pending queue
--   before the index is sync-ed. Applies only when the sync policy
--   is SYNC_BY_PENDING_COUNT or SYNC_BY_TIME_AND_PENDING_COUNT
--
MaxPendingCount            PLS_INTEGER := 2;

-- This parameter determines the interval - in minutes - at 
-- which the "regular" sync should be performed on the index.
-- Applies only to the SYNC_BY_TIME and the SYNC_BY_PENDING_COUNT_AND_TIME
-- policies
SyncInterval               PLS_INTEGER := 60;

--
-- This parameter determines how frequently - in minutes - the pending 
-- queue is polled. Applies only to the SYNC_BY_PENDING_COUNT
-- (and the SYNC_BY_PENDING_COUNT_AND_TIME) policies
-- 
CheckPendingCountInterval  PLS_INTEGER := 10;

----------------------------------------------------
-- LOGGING OPTIONS
--
-- Please ensure that the LOG_DIRECTORY parameter is
-- already set if you need rowid logging
----------------------------------------------------
--
-- Logging options. This parameter determines the logfile used - for
-- rowid logging during index creation etc. 
-- Set this parameter to NULL to avoid rowid-logging
--
LogFile                    VARCHAR2(32) := '';

-------------------------------------
-- FILTER OPTIONS
--
-- The following classes determine the filtering options based on the
-- mime type of the document
--
-- The skipFilter_Types list contains a list of regular expressions
-- that describe mime types for which the document is *not* to be 
-- filtered/indexed. (The document metadata, however, is still indexed)
-- Use this for document types that cannot really be indexed. Good 
-- examples of this class are images, audio files etc
--
-- The NullFilter_Types list contains a list of regular expressions
-- that describe mime types of documents for which no INSO filtering
-- is required - these documents should be basically text formats
-- and the only filtering required should be character set conversion
-- (if needed)
--
-- For any given document, the skipFilter_Types list is first scanned
-- to determine if any regular expression in that list matches the  
-- document's content type. If it does, then the document content is 
-- not indexed.
-- Failing this, the NullFilter_Types list is then scanned. If any 
-- regular expression in this list matches the document's content type,
-- the document is sent through character-set conversion
-- failing this, the document is filtered using the INSO filter (using the
-- IFILTER interfaces)
-------------------------------------
SkipFilter_Types varcharset := varcharset('image/%', 'audio/%', 'video/%', 
                                          'model/%');
NullFilter_Types varcharset := varcharset('%text/plain', '%text/html', 
                                          '%text/xml');

-------------------------------------
-- STOPWORD Settings
--
-- This list describes the set of stopwords over and above that
-- specified by the CTXSYS.DEFAULT_STOPLIST stoplist
-- 
-------------------------------------
StopWords        varcharset := varcharset('0','1','2','3','4','5','6',
                                          '7','8','9',
                                          'a','b','c','d','e','f','g','h','i',
                                          'j','k','l','m','n','o','p','q','r',
                                          's','t','u','v','w','x','y','z',
                                          'A','B','C','D','E','F','G','H','I',
                                          'J','K','L','M','N','O','P','Q','R',
                                          'S','T','U','V','W','X','Y','Z'
                                         );       

--------------------------------------
-- LEXER preferences
--
-- This parameter determines if multi-language lexers can be
-- used.
-- Not supported currently, and this parameter should always be FALSE
--------------------------------------
UseMultiLexer   BOOLEAN := false;

--------------------------------------
-- SECTION GROUP
--
-- This parameter determines the sectioner to use.
-- By default, this is an HTML section group. No zone sections have been
-- created - (ie) WITHIN searches are not possible
-- If the vast majority of documents are XML or XML-like, consider using
-- the AUTO_SECTION_GROUP or the PATH_SECTION_GROUP or even a 
-- NULL_SECTION_GROUP
--------------------------------------
SectionGroup    VARCHAR2(100) := 'HTML_SECTION_GROUP';

--------------------------------------
-- PUBLIC INTERFACES
--
-- The public APIs exposed by this package 
--------------------------------------

  --
  -- This procedure drops all preferences required by the context index
  -- 
  PROCEDURE dropPreferences;

  --
  -- This procedure creates all preferences required by the context index
  -- on the XDB repository.
  -- The set of preferences include Datastore, Storage, Filter, Lexer,
  -- SectionGroup, Stoplist and Wordlist preferences
  -- NOTE: This will raise exceptions if any of the preferences already 
  --       exist
  --
  PROCEDURE createPreferences;

  --
  -- Creates the datastore preference
  -- Will raise an exception if the datastore already exists
  PROCEDURE createDatastorePref;

  --
  -- Creates the storage preferences
  -- Will raise an exception if the preference already exists
  -- 
  PROCEDURE createStoragePref;

  --
  -- Creates the section group
  -- Will raise an exception if the preference already exists
  --
  PROCEDURE createSectiongroupPref;

  -- 
  -- Creates the filter preference
  -- Will raise an exception if the preference already exists
  --
  PROCEDURE createFilterPref;

  --
  -- Creates the lexer preference
  -- Will raise an exception if the preference already exists
  --
  PROCEDURE createLexerPref;

  --
  -- Creates the stoplist
  -- Will raise an exception if the preference already exists
  --
  PROCEDURE createStoplistPref;

  -- 
  -- Creates the wordlist
  -- Will raise an exception if the preference already exists
  -- 
  PROCEDURE createWordlistPref;

  -- 
  -- Creates the index
  -- This requires the above preferences to have already been created.
  -- (a) The LOG_DIRECTORY parameter must be set (to enable
  --     rowid logging during index creation) 
  -- (b) Ensure that the memory size specified to index creation is less than
  --     the MAX_INDEX_MEMORY parameter
  --
  PROCEDURE createIndex;

  -- 
  -- Syncs up the index 
  -- This can be used to explicitly sync up the index. 
  -- The preferred mechanism is to set up automatic sync'ing with 
  -- the "configureAutoSync" procedure 
  -- 
  PROCEDURE syncIndex(myIndexName VARCHAR2 := Indexname, 
                      myIndexMemory VARCHAR2 := IndexMemory);

  -- 
  -- Set a suggested time limit on the SYNC operation, in minutes.
  -- SYNC_INDEX will process as many documents in the queue as possible
  -- within the time limit.
  -- The maxtime value of NULL is equivalent to CTX_DDL.MAXTIME_UNLIMITED.
  -- 
  PROCEDURE setSyncTimeout(timeout IN INTEGER := NULL);

  -- 
  -- Optimizes the index
  --
  PROCEDURE optimizeIndex;

  --
  -- Configures for automatic sync of the index
  -- NOTE: The system must be configured for job queues. Also, the 
  --   number of job queue processes must be non-zero
  --
  PROCEDURE configureAutoSync;

  -- 
  -- Procedure used by dbms_job to automatically sync up the context
  -- index
  -- Don't use this directly
  --
  PROCEDURE autoSyncJobByCount(myIndexName VARCHAR2, myMaxPendingCount NUMBER,
                               myIndexMemory VARCHAR2);
  -- 
  -- Procedure used by dbms_job to automatically sync up the context
  -- index
  -- Don't use this directly
  --
  PROCEDURE autoSyncJobByTime(myIndexName VARCHAR2, myIndexMemory VARCHAR2);

  --
  -- The user-datastore procedure 
  -- Do *not* call this directly
  --
  PROCEDURE xdb_datastore_proc(rid IN ROWID, outlob IN OUT NOCOPY CLOB);

end dbms_xdbt;
/
show errors;

CREATE OR REPLACE PACKAGE BODY xdb.dbms_xdbt AS

-----------------------------------------------------------------------
-- CONFIGURATION SETTINGS
--
-- This section contains the default settings for the index. This
-- section should be changed as appropriate.
-- 
-----------------------------------------------------------------------

--
-- The following are the default values for the policy_filter
-- used to filter out HTML, from BLOB into CLOB.
-- 'Policy-based' procedures do not make use of the Ctx index.
--
PolicyFilterName           VARCHAR2(32) := IndexName || '_POLICYFILTER';
BlobLanguage               VARCHAR2(32) := NULL;
BlobFormat                 VARCHAR2(32) := 'BINARY';
BlobCharset                VARCHAR2(32) := NULL;

--
-- The following are the default names for the various preferences
--
DatastorePref              VARCHAR2(32) := IndexName || '_DATASTORE';
AutoFilterPref             VARCHAR2(32) := IndexName || '_AUTO_FILTER';
FilterPref                 VARCHAR2(32) := IndexName || '_FILTER';
SectionGroupPref           VARCHAR2(32) := IndexName || '_SECTIONGROUP';
MultiLexerPref             VARCHAR2(32) := IndexName || '_LEXER';
DefaultLexerPref           VARCHAR2(32) := IndexName || '_DEFAULT_LEXER';
WordlistPref               VARCHAR2(32) := IndexName || '_WORDLIST';
StoplistPref               VARCHAR2(32) := IndexName || '_STOPLIST';
StoragePref                VARCHAR2(32) := IndexName || '_STORAGE';

LanguageColumn             VARCHAR2(32) := '"XMLDATA"."LANGUAGE"';

-----------------------------------------------------------------------
  -- PRIVATE ROUTINES
-----------------------------------------------------------------------

--
-- This function determines the filtering required by a document
-- based on its mime type.
--
FUNCTION  getFilterOption(mimeType IN VARCHAR2) RETURN PLS_INTEGER;

--
-- This function determines the internal character setid given an
-- external character set name
--
FUNCTION  getCharsetId(extCSName IN VARCHAR2) RETURN NUMBER;

-- This function determines if a sync is needed.
FUNCTION  checkSync(myIndexName VARCHAR2, myMaxPendingCount NUMBER) 
  RETURN BOOLEAN;

--
-- This function creates the index
--
PROCEDURE createIndex IS
  sqlstr  VARCHAR2(4000);
BEGIN

  -- Turn rowid logging on if requested
  IF LogFile IS NOT NULL THEN
    -- Turn rowid logging on during a create index
    BEGIN
      ctxsys.ctx_output.end_log;
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    ctxsys.ctx_output.start_log(LogFile);
    ctxsys.ctx_output.add_event(ctxsys.ctx_output.EVENT_INDEX_PRINT_ROWID);
  END IF;

  -- Actually create the index
  sqlstr :=  'create index ' || IndexName || 
                    ' on xdb.xdb$resource p(value(p))' || 
                    ' indextype is ctxsys.context' ||
                    ' parameters (''datastore ' || DatastorePref ||
                                  ' storage ' || StoragePref ||
                                  ' filter ' || FilterPref ||
                                  ' section group ' || SectionGroupPref ;

  if UseMultiLexer = true THEN
    sqlstr := sqlstr || ' language column ' || LanguageColumn || 
              ' lexer ' || MultiLexerPref;
  ELSE
    sqlstr := sqlstr || ' lexer ' || DefaultLexerPref;
  END IF;
  sqlstr := sqlstr || ' wordlist ' || WordlistPref ||
            ' stoplist ' || StoplistPref || 
            ' memory ' || IndexMemory ||
            ''')';

  execute immediate sqlstr;
END createIndex;

--
-- This function drops all preferences used by the context index on XDB
--
PROCEDURE dropPreferences IS
BEGIN
  -- datastore preference
  BEGIN
    ctx_ddl.drop_policy(policy_name => PolicyFilterName);
  EXCEPTION WHEN OTHERS THEN NULL; END;
  -- policy preference
  BEGIN
    ctx_ddl.drop_preference(DatastorePref);
  EXCEPTION WHEN OTHERS THEN NULL; END;
  -- filter preference
  BEGIN
    ctx_ddl.drop_preference(FilterPref);
  EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN
    ctx_ddl.drop_preference(AutoFilterPref);
  EXCEPTION WHEN OTHERS THEN NULL; END;
  -- section group
  BEGIN
    ctx_ddl.drop_section_group(SectionGroupPref);
  EXCEPTION WHEN OTHERS THEN NULL; END;
  -- lexer preferences
  BEGIN
    ctx_ddl.drop_preference(MultiLexerPref);
  EXCEPTION WHEN OTHERS THEN NULL; END;
  BEGIN
    ctx_ddl.drop_preference(DefaultLexerPref);
  EXCEPTION WHEN OTHERS THEN NULL; END;
  -- wordlist preferences
  BEGIN
    ctx_ddl.drop_preference(WordlistPref);
  EXCEPTION WHEN OTHERS THEN NULL; END;
  -- stoplist preferences
  BEGIN
    ctx_ddl.drop_stoplist(StoplistPref);
  EXCEPTION WHEN OTHERS THEN NULL; END;
  -- storage preference
  BEGIN
    ctx_ddl.drop_preference(StoragePref);
  EXCEPTION WHEN OTHERS THEN NULL; END;

END dropPreferences;

--
-- This function creates all preferences required by the cntext index on XDB
--
PROCEDURE createPreferences IS
  LexerPref VARCHAR2(32);
BEGIN
  createDatastorePref;
  createFilterPref;
  createLexerPref;
  createStoplistPref;
  createWordlistPref;
  createStoragePref;
  createSectiongroupPref;

  IF UseMultiLexer = true THEN
    LexerPref := MultiLexerPref;
  ELSE
    LexerPref := DefaultLexerPref;
  END IF;

  ctx_ddl.create_policy(policy_name   =>PolicyFilterName,
                        filter        =>AutoFilterPref);
END createPreferences;

--
-- This function creates the datastore preference. A USER datastore
-- is used.
--
PROCEDURE createDatastorePref IS
BEGIN
  ctx_ddl.create_preference(DatastorePref, 'USER_DATASTORE');
  ctx_ddl.set_attribute(DatastorePref, 'PROCEDURE', 'XDB_DATASTORE_PROC');
  ctx_ddl.set_attribute(DatastorePref, 'OUTPUT_TYPE', 'CLOB');
END createDatastorePref;

--
-- Creates the filter preference. 
-- A NULL filter is used - the user datastore procedure calls the IFILTER
-- APIs to INSO when appropriate 
-- 
PROCEDURE createFilterPref IS
BEGIN
  ctx_ddl.create_preference(FilterPref, 'NULL_FILTER');
  ctx_ddl.create_preference(AutoFilterPref, 'AUTO_FILTER');
END createFilterPref;

--
-- Creates the section group. 
--
PROCEDURE createSectiongroupPref IS
BEGIN
  ctx_ddl.create_section_group(SectionGroupPref, SectionGroup);
END createSectiongroupPref;

--
-- Creates the lexer preferences
-- Creates a default lexer with base letter transcriptions, and 
-- adds this as a sub-lexer of a multi-lexer
-- Currently, the multi-lexer is not used.
--
PROCEDURE createLexerPref IS
BEGIN
  ctx_ddl.create_preference(DefaultLexerPref, 'BASIC_LEXER');
  -- Turn on base letter translations
  ctx_ddl.set_attribute(DefaultLexerPref, 'base_letter', 'YES');

  ctx_ddl.create_preference(MultiLexerPref, 'MULTI_LEXER');
  ctx_ddl.add_sub_lexer(MultiLexerPref, 'DEFAULT', DefaultLexerPref);
END createLexerPref;

--
-- Creates the word-list preferences
--
PROCEDURE createWordlistPref IS
BEGIN
  ctx_ddl.create_preference(WordlistPref, 'BASIC_WORDLIST');
  
  -- default values for stemming and fuzzy match
  ctx_ddl.set_attribute(WordlistPref, 'fuzzy_match', 'AUTO');
  ctx_ddl.set_attribute(WordlistPref, 'stemmer', 'AUTO');
END createWordlistPref;

--
-- Creates the stoplist.
-- Imports the stopwords from CTXSYS.DEFAULT_STOPLIST
-- And adds the stopwords specified in StopWords
-- By default, NUMBERS are treated as a stopclass
--
PROCEDURE createStoplistPref IS
  i   PLS_INTEGER;
  wordset varcharset := varcharset();
BEGIN
  -- 
  -- You can also create a MULTI_STOPLIST instead of a basic stoplist
  -- The problem then is to specify the appropriate language for the
  -- stopwords that are part of the default stoplist, and the stopwords
  -- that the user provides
  -- ctx_ddl.create_stoplist(StoplistPref, 'MULTI_STOPLIST');
  --
  IF UseMultiLexer = true THEN
    ctx_ddl.create_stoplist(StoplistPref, 'MULTI_STOPLIST');
  ELSE
    ctx_ddl.create_stoplist(StoplistPref, 'BASIC_STOPLIST');
  END IF;

  -- don't index any numbers
  ctx_ddl.add_stopclass(StoplistPref, 'NUMBERS');

  -- extend the local stopwords array
  wordset.extend(4096);
  SELECT spw_word BULK COLLECT INTO wordset 
  FROM ctx_stopwords 
  WHERE spw_stoplist = 'DEFAULT_STOPLIST' and
        spw_owner = 'CTXSYS';

  -- add all stopwords for the default stoplist to our stoplist
  FOR i in 1..wordset.COUNT LOOP
    ctx_ddl.add_stopword(StoplistPref, wordset(i));
  END LOOP;

  -- Then add our own specific stop words
  FOR i in 1..StopWords.COUNT LOOP
    BEGIN
      ctx_ddl.add_stopword(StoplistPref, StopWords(i));
    EXCEPTION WHEN OTHERS THEN NULL; END;
  END LOOP;

END createStoplistPref;

--
-- Storage preferences
-- Determine if the $I table and the $X index require a special tablespace
-- or any other properties
-- Note that prefix and substr indexing are turned off
--
PROCEDURE createStoragePref IS
  -- The tablespace of the tables/indexes that constitute the context index. 
  IndexTableSpace   VARCHAR2(32);
  ts_clause         varchar2(100);
BEGIN

  -- Get the tablespace of xdb$resource, that can be considered as the
  -- default tablespace. Only one row can be returned from the query.
  IndexTableSpace := xdb.dbms_xdb.getxdb_tablespace();
  ts_clause := 'tablespace ' || IndexTableSpace;

  ctx_ddl.create_preference(StoragePref, 'BASIC_STORAGE');
  ctx_ddl.set_attribute(StoragePref, 'I_TABLE_CLAUSE', ts_clause);
  ctx_ddl.set_attribute(StoragePref, 'K_TABLE_CLAUSE', ts_clause);
  ctx_ddl.set_attribute(StoragePref, 'R_TABLE_CLAUSE', 
                        ts_clause || ' lob(data) store as (cache)');
  ctx_ddl.set_attribute(StoragePref, 'N_TABLE_CLAUSE', ts_clause);
  ctx_ddl.set_attribute(StoragePref, 'I_INDEX_CLAUSE', 
                        ts_clause || ' compress 2');
  ctx_ddl.set_attribute(StoragePref, 'P_TABLE_CLAUSE', ts_clause);
END createStoragePref;

--
-- Determines the filtering to use for a document 
--
FUNCTION getFilterOption(mimeType IN VARCHAR2) RETURN PLS_INTEGER IS
  filterOption PLS_INTEGER := USE_INSO_FILTER;
  i            PLS_INTEGER;
BEGIN
  -- We have 3 choices. 
  -- (a) Skip the data completely - this is true for resources that
  --     contain images, audios etc
  -- (b) No filtering required - this can be used when the data 
  --     is a text type
  -- (c) Use INSO filter - for everything else

  FOR i IN 1..SkipFilter_Types.COUNT LOOP
    IF mimeType LIKE SkipFilter_Types(i) THEN 
      filterOption := SKIP_DATA;
      EXIT;
    END IF;
  END LOOP;

  FOR i in 1..NullFilter_Types.COUNT LOOP
    IF mimeType LIKE NullFilter_Types(i) THEN
      filterOption := USE_NULL_FILTER;
      EXIT;
    END IF;
  END LOOP;

  RETURN filterOption;  
END getFilterOption;

--
-- Determines the internal charset-id for an external charset name
-- Currently hardcoded to 2 (represents UTF-8)
--
FUNCTION getCharsetId(extCSName IN VARCHAR2) RETURN NUMBER IS
  intCSName varchar2(255);
BEGIN
  intCSName := utl_gdk.charset_map(extCSName, utl_gdk.IANA_TO_ORACLE);
  IF intCSName is null THEN
    RETURN NLS_CHARSET_ID(extCSName);
  ELSE
    RETURN NLS_CHARSET_ID(intCSName);
  END IF;
END getCharsetId;

PROCEDURE annotate_doclob(author     IN varchar2,
                          dispname   IN varchar2,  -- resource's display name
                          rescomment IN varchar2,  -- resource creation comment
                          owner      IN varchar2,  -- owner user name
                          creator    IN varchar2,  -- creator user name
                          lastmod    IN varchar2,  -- last modifier user name 
                          resextra   IN clob,      -- resource extra properties
                          xmlref_lob IN clob,      -- xmldata
                          outlob     IN OUT NOCOPY clob) IS 
begin 
  -- Write the metadata fields into output lob
  if author is not null then 
    dbms_lob.writeappend(outlob, length(author), author);
    dbms_lob.writeappend(outlob, 1, ' ');
  end if;
  if dispname is not null then 
    dbms_lob.writeappend(outlob, length(dispname), dispname);
    dbms_lob.writeappend(outlob, 1, ' ');
  end if;
  if rescomment is not null then 
    dbms_lob.writeappend(outlob, length(rescomment), rescomment);  
    dbms_lob.writeappend(outlob, 1, ' ');
  end if;
  if owner is not null then 
    dbms_lob.writeappend(outlob, length(owner), owner);
    dbms_lob.writeappend(outlob, 1, ' ');
  end if;
  if creator is not null then 
    dbms_lob.writeappend(outlob, length(creator), creator);
    dbms_lob.writeappend(outlob, 1, ' ');
  end if;
  if lastmod is not null then 
    dbms_lob.writeappend(outlob, length(lastmod), lastmod);
    dbms_lob.writeappend(outlob, 1, ' ');
  end if;

   -- check if resextra holds data
  if resextra is not null and dbms_lob.getlength(resextra) > 0 then 
    dbms_lob.append(outlob, resextra);
    dbms_lob.writeappend(outlob, 1, ' ');
  end if;

   -- check if xmlref/xmllob holds data
  if xmlref_lob is not null and dbms_lob.getlength(xmlref_lob) > 0 then 
    dbms_lob.append(outlob, xmlref_lob);
  end if;
END annotate_doclob;

--
-- The datastore procedure
-- This reads the data from the underlying row
-- Some of the metadata of the document are also indexed - notably, 
-- the author, the creation comment of the resource, the display name etc
-- 
PROCEDURE xdb_datastore_proc(rid IN ROWID, outlob IN OUT NOCOPY CLOB) IS
 author varchar2(128);                  -- the author
 dispname varchar2(128);                -- resource's display name
 rescomment varchar2(128);              -- resource creation comment
 contype varchar2(80);                  -- mimetype of the resource
 xmllob blob;                           -- blob containing inline resource
 xmlref_lob clob;                       -- xmldata
 charset varchar2(128);                 -- character set of the resource
 resextra   clob;                       -- extra properties about the resource
 owneridr   raw(16);                    -- owner id in its raw form
 creatoridr raw(16);                    -- creator id in its raw form
 lastmodidr raw(16);                    -- last modifier id in its raw form
 owner      varchar2(32);               -- owner user name
 creator    varchar2(32);               -- creator user name
 lastmod    varchar2(32);               -- last modifier user name 
 
begin 
  if (dbms_lob.getlength(outlob) <> 0) then
    raise_application_error(-20010, 'non-zero lob');
  end if;

  -- Get the columns from the resource row 
  SELECT e.xmldata.author, e.xmldata.dispname,
         e.xmldata.rescomment, e.xmldata.contype,
         CASE WHEN e.xmldata.xmlref IS NOT NULL 
              THEN DEREF(e.xmldata.xmlref).getclobval() 
              ELSE NULL END, 
         e.xmldata.xmllob, e.xmldata.charset,e.xmldata.ownerid,
         e.xmldata.creatorid, e.xmldata.lastmodifierid, e.xmldata.resextra
  INTO 
         author, dispname, rescomment, contype, xmlref_lob, xmllob,
         charset, owneridr, creatoridr, lastmodidr, resextra

  FROM xdb.xdb$resource e
  WHERE ROWID = rid;

  -- get the user names for the owner, creator and the last modifier
  xdb.dbms_xdbz0.get_username(owneridr, owner);
  xdb.dbms_xdbz0.get_username(creatoridr, creator);
  xdb.dbms_xdbz0.get_username(lastmodidr, lastmod);
 
  annotate_doclob(author,
                  dispname,
                  rescomment,
                  owner,
                  creator,
                  lastmod,
                  resextra,
                  xmlref_lob,
                  outlob);

  -- If resource data is stored in the blob, filter it
  IF xmllob IS NOT NULL AND dbms_lob.getlength(xmllob) > 0 THEN 
    DECLARE
      filterOption PLS_INTEGER;          -- what kind of filter should I use
    BEGIN
      filterOption := getFilterOption(conType);
      IF (filterOption = USE_NULL_FILTER) THEN
      DECLARE
        amount number := dbms_lob.getlength(xmllob);
        dest_offset number := dbms_lob.getlength(outlob) + 1;
        src_offset number := 1;
        blob_csid number;
        lang_context integer := 0;
        warning integer := 0;
      BEGIN
        blob_csid := getCharsetId(charset);
        dbms_lob.convertToClob(outlob, xmllob, amount, dest_offset, 
                               src_offset, blob_csid, lang_context, 
                               warning);
      END;
      ELSIF (filterOption = USE_INSO_FILTER) THEN
--      BUG 8915200: IFILTER deprecated since 9i.
--      ctx_doc.ifilter(xmllob, outlob);
--      This solution was suggested by mfaisal.
        ctx_doc.policy_filter(policy_name=>PolicyFilterName,
                              document   =>xmllob,
                              restab     =>outlob,
                              plaintext  =>FALSE,    -- yes we want HTML / XML
                              language   =>BlobLanguage,
                              format     =>BlobFormat,
                              charset    =>BlobCharset);
        annotate_doclob(author,
                        dispname,
                        rescomment,
                        owner,
                        creator,
                        lastmod,
                        resextra,
                        xmlref_lob,
                        outlob);
      END IF;
    END;
  END IF;

END xdb_datastore_proc;

--
-- Sync's up the index
--
PROCEDURE syncIndex(myIndexName VARCHAR2, myIndexMemory VARCHAR2) IS
BEGIN
  ctx_ddl.sync_index(myIndexName, myIndexMemory, maxtime=>SyncTimeOut);
END syncIndex;

--
-- Set time limit for Sync Index
PROCEDURE setSyncTimeout(timeout IN INTEGER := NULL)
IS
BEGIN
-- Don't care about weird / negative values !
  SyncTimeOut := timeout;
END setSyncTimeOut;

--
-- Optimizes the index
-- 
PROCEDURE optimizeIndex IS
BEGIN
  null;
  -- ctx_ddl.optimize_index(IndexName, lvl, OptimizeTime, NULL, NULL);
END optimizeIndex;

--
-- This function determines if a sync is needed.
-- This is really applicable ONLY when the sync policy is _BY_PENDING_COUNT
-- This function looks at the pending queue, and determines if the 
-- queue is larger than the predefined threshold.
-- NOTE: This function is only to be used by the autoSyncJob procedure
--
FUNCTION checkSync(myIndexName VARCHAR2, myMaxPendingCount NUMBER) 
  RETURN BOOLEAN IS
  doSync       BOOLEAN := false;
  pendingCount NUMBER;
BEGIN
  -- Check to see if there are many documents waiting to be indexed
  SELECT COUNT(*) INTO pendingCount 
  FROM ctx_user_pending 
  WHERE pnd_index_name = myIndexName;

  IF pendingCount > myMaxPendingCount THEN 
    doSync := true;
  END IF;

  -- Is the index in a reasonable state to be sync'ed
  RETURN doSync;
END checkSync;

--
-- procedure used by dbms_jobs to automatically sync the index
--
PROCEDURE autoSyncJobByCount(myIndexName VARCHAR2, myMaxPendingCount NUMBER,
                             myIndexMemory VARCHAR2) IS
BEGIN
  IF checkSync(myIndexname, myMaxPendingCount) = true THEN
    syncIndex(myIndexName, myIndexMemory);
  END IF;
END autoSyncJobByCount;

--
-- procedure used by dbms_jobs to automatically sync the index
--
PROCEDURE autoSyncJobByTime(myIndexName VARCHAR2,
                            myIndexmemory VARCHAR2) IS
BEGIN
  syncIndex(myIndexName, myIndexMemory);
END autoSyncJobByTime;

--
-- Configures auto-sync
-- The system must be configured for job queues
--
PROCEDURE configureAutoSync IS
  job number;
  what varchar2(255);
  quote varchar2(1) := '''';
BEGIN
  IF (AutoSyncPolicy = SYNC_BY_TIME or 
      AutoSyncPolicy = SYNC_BY_PENDING_COUNT_AND_TIME) THEN
    what := 'xdb.dbms_xdbt.autoSyncJobByTime(' || quote ||
            IndexName || quote || ',' ||
            quote || IndexMemory || quote || ');' ;
    dbms_job.submit(job, what, interval=>'SYSDATE+'|| SyncInterval/1440);
  END IF;
  IF (AutoSyncPolicy = SYNC_BY_PENDING_COUNT or 
      AutoSyncPolicy = SYNC_BY_PENDING_COUNT_AND_TIME) THEN
    what := 'xdb.dbms_xdbt.autoSyncJobByCount(' || quote ||
            IndexName || quote || ',' ||
            MaxPendingCount || ',' ||
            quote || IndexMemory || quote || ');';
    dbms_job.submit(job, what, interval=>'SYSDATE+'|| CheckPendingCountInterval/1440);
  END IF;
END configureAutoSync;

END dbms_xdbt;
/

show errors;

Rem
Rem Create the "real" user-datastore procedure
Rem Note: This is around only for backward compatibility. In 9iR2, the
Rem user-datastore procedure needed to be owned by CTXSYS. In 10i, it needs
Rem to be owned by the index owner. Changing the user-datastore-proc name
Rem may require a rebuild of the index - which we don't really want, and
Rem hence we create a procedure of the same name in XDB's schema
Rem
CREATE OR REPLACE PROCEDURE xdb.xdb_datastore_proc(rid IN ROWID, 
                                                   outlob IN OUT NOCOPY CLOB)
  AUTHID CURRENT_USER IS
BEGIN
  xdb.dbms_xdbt.xdb_datastore_proc(rid, outlob);
END;
/
show errors;

Rem Remember to set these
Rem exec ctxsys.ctx_adm.set_parameter('MAX_INDEX_MEMORY', '128M');
Rem exec ctxsys.ctx_adm.set_parameter('LOG_DIRECTORY', '/tmp');

