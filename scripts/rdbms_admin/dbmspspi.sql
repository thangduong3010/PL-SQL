Rem
Rem $Header: rdbms/admin/dbmspspi.sql /st_rdbms_11.2.0/1 2012/05/13 21:25:15 mamapati Exp $
Rem $Header: rdbms/admin/dbmspspi.sql /st_rdbms_11.2.0/1 2012/05/13 21:25:15 mamapati Exp $
Rem
Rem dbmspspi.sql
Rem
Rem Copyright (c) 2009, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmspspi.sql - package implementing dbms_dbfs_content_spi for HS
Rem
Rem    DESCRIPTION
Rem    
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    amullick    11/29/10 - lrg4926382:add exception for dropstore
Rem    shase       07/27/09 - bug 8729613- fwd merge for bug 8666190 and bug
Rem                           8614740
Rem    schitti     04/13/09 - Add compression exceptions
Rem    amullick    02/27/09 - fix bug8291480
Rem    amullick    01/22/09 - Created
Rem

/* ------------------------- dbms_dbfs_hs --------------------------*/
/*
 * The package "dbms_dbfs_hs" is a store provider for the 
 * DBFS API and thus conforms to the provider SPI defined in 
 * "dbms_dbfs_content_spi".
 */

create or replace package dbms_dbfs_hs
    authid current_user
as

-- DBMS_DBFS_HS package is a service provider, underneath
-- DBMS_DBFS_CONTENT that enables use of tape or Amazon S3 web service
-- as store for data.  The data on tape (or Amazon S3 web service) is part
-- of the Oracle Database and can be accessed through all standard APIs, but
-- only via the database.
-- DBMS_DBFS_HS package provides users the ability to use tape
-- (or Amazon S3 web service) as a storage tier when doing Information 
-- Lifecycle Management of their content.

-- Following are the types of storage supported by this package.
-- They are the only valid values for the store_type parameter in the
-- createStore method of this package.
   STORETYPE_TAPE CONSTANT VARCHAR2(50) := 'HS_TAPE';
   STORETYPE_AMAZONS3 CONSTANT VARCHAR2(50) := 'HS_S3';
   
    -- Following are the properties used by this package.
    -- All the properties should be set using setStoreProperty method.
    PROPNAME_SBTLIBRARY CONSTANT VARCHAR2(50) := 'SBT_LIBRARY';
    PROPNAME_MEDIAPOOL CONSTANT VARCHAR2(50) := 'MEDIA_POOL';
    PROPNAME_OPTTARBALLSIZE CONSTANT VARCHAR2(50) := 'OPTIMAL_TARBALL_SIZE';
    PROPNAME_READCHUNKSIZE CONSTANT VARCHAR2(50) := 'READ_CHUNK_SIZE';
    PROPNAME_WRITECHUNKSIZE CONSTANT VARCHAR2(50) := 'WRITE_CHUNK_SIZE';
    PROPNAME_S3HOST CONSTANT VARCHAR2(50) := 'S3_HOST';
    PROPNAME_HTTPPROXY CONSTANT VARCHAR2(50) := 'HTTP_PROXY';
    PROPNAME_WALLET CONSTANT VARCHAR2(50) := 'WALLET';
    PROPNAME_BUCKET CONSTANT VARCHAR2(50) := 'BUCKET';
    PROPNAME_ALIAS CONSTANT VARCHAR2(50) := 'WALLET_ALIAS';
    PROPNAME_LICENSEID CONSTANT VARCHAR2(50) := 'LICENSE_ID';
    PROPNAME_CACHESIZE CONSTANT VARCHAR2(50) := 'CACHE_SIZE';
    PROPNAME_LOBCACHE_QUOTA CONSTANT VARCHAR2(50) := 'LOBCACHE_QUOTA';
    PROPNAME_COMPRESSLEVEL CONSTANT VARCHAR2(50) := 'COMPRESSION_LEVEL';
    PROPVAL_COMPLVL_NONE CONSTANT VARCHAR2(50) := 'NONE';
    PROPVAL_COMPLVL_LOW CONSTANT VARCHAR2(50) := 'LOW';
    PROPVAL_COMPLVL_MEDIUM CONSTANT VARCHAR2(50) := 'MEDIUM';
    PROPVAL_COMPLVL_HIGH CONSTANT VARCHAR2(50) := 'HIGH';
    
    --LRU timestamp update frequency
    PROPNAME_LRUTS_UPD_FREQ CONSTANT VARCHAR2(50) := 'LRUTS_UPD_FREQ';
        
    PROPVAL_MAXBF_S3 CONSTANT NUMBER := 3154728;
    PROPVAL_CHUNKSIZE CONSTANT VARCHAR2(50) := '1048576';

    -- Valid values for STREAMABLE property are 'TRUE' and 'FALSE'
    -- The default value of this property is 'TRUE'.
    PROPNAME_STREAMABLE CONSTANT VARCHAR2(50) := 'STREAMABLE';
    
    -- Valid values for this property are 'TRUE' and 'FALSE'.
    -- Default value is 'TRUE' for S3 and 'FALSE' for tape.
    PROPNAME_ENABLECLEANUPONDELETE CONSTANT VARCHAR2(50) := 
    'ENABLE_CLEANUP_ON_DELETE';
   
    PROPNAME_MAX_BACKUPFILE_SIZE CONSTANT VARCHAR2(50) :=
    'MAX_BACKUPFILE_SIZE';
    
    PROPNAME_STORE_TYPE CONSTANT VARCHAR2(50) := 'STORE_TYPE';
    
    -- The following EXCEPTIONS are raised by this package. In addition,
    -- this package also raises the exceptions defined by DBMS_DBFS_CONTENT.
   storenf exception;
   PRAGMA EXCEPTION_INIT(storenf, -20200);
   storenf_msg constant varchar2(256) :=
   ' STORE NOT FOUND';
   storenf_err constant pls_integer := -20200;
   -- ORA-20200: Store not found
   -- *Cause: Store with the given name was not found
   -- *Action: Check the name and Create the Store
   
   propertynf exception;
   PRAGMA EXCEPTION_INIT(propertynf, -20201);
   propertynf_msg constant varchar2(256) :=
   ' STORE PROPERTY NOT FOUND';
   propertynf_err constant pls_integer := -20201;
   -- ORA-20201: Store Property not found
   -- *Cause: A required store property was not found
   -- *Action: populate the store property


   tbsnotfound exception;
   PRAGMA EXCEPTION_INIT(tbsnotfound, -20202);
   tbsnotfound_msg constant varchar2(256) :=
   ' Specified Tablespace for staging area does not exist';
   tbsnotfound_err constant pls_integer := -20202;
   -- ORA-20122: Specified staging area tablespace not found
   -- *Cause: Invalid tablespace name
   -- *Action: Pass a valid tablespace name

   change_stagingarea exception;
   PRAGMA EXCEPTION_INIT(change_stagingarea, -20203);
   change_stagingarea_msg constant varchar2(256) :=
   'CHANGE STAGINGAREA FAILED';
   change_stagingarea_err constant pls_integer := -20203;
   -- ORA-20203: CHANGE STAGINGAREA FAILED
   -- *Cause: StagingArea is in use.
   -- *Action: Make sure that stagingarea is clean by calling 
   -- DBMS_DBFS_HS.STOREPUSH
   
   invalidpctx exception;
   PRAGMA EXCEPTION_INIT(invalidpctx, -20204);
   invalidpctx_msg constant varchar2(256) :=
   ' INVALID POLICY CONTEXT';
   invalidpctx_err constant pls_integer := -20204;
   -- ORA-20204: Invalid PolicyCtx passed in
   -- *Cause: The Policy Context passed in is invalid
   -- *Action: Pass a valid policy context

   storetype exception;
   PRAGMA EXCEPTION_INIT(storetype, -20205);
   storetype_msg constant varchar2(50) := 'STORETYPE IS INVALID';
   storetype_err constant pls_integer := -20205;
   -- ORA-20205: STORETYPE IS INVALID
   -- *Cause:  STORETYPE is not one of the types defined by 
   --          DBMS_DBFS_HS
   -- *Action: change STORETYPE to one of the types defined by 
   --          DBMS_DBFS_HS

   insufficient_cache exception;
   PRAGMA EXCEPTION_INIT(insufficient_cache, -20206);
   insufficient_cache_msg constant varchar2(50) := 'CACHESIZE IS INSUFFICIENT';
   insufficient_cache_err constant pls_integer := -20206;
   -- ORA-20206: CACHESIZE IS INSUFFICIENT
   -- *Cause   : CACHESIZE provided to DBMS_DBFS_HS store 
   --            is insufficient
   -- *Action  : increase CACHESIZE provided to create DBMS_DBFS_HS 
   --            store 
   
   string_overflow exception;
   PRAGMA EXCEPTION_INIT(string_overflow, -20207);
   string_overflow_msg constant varchar2(50) := 'string overflow';
   string_overflow_err constant pls_integer := -20207;
   -- ORA-20207: string overflow
   -- *Cause   : String is longer than allowed length
   -- *Action  : Contact Oracle Support 

   invalid_lobCacheQuota exception;
   PRAGMA EXCEPTION_INIT(invalid_lobCacheQuota, -20208);
   invalid_lobCacheQuota_msg constant varchar2(50) := 'Invalid lob Cache quota specified';
   invalid_lobCacheQuota_err constant pls_integer := -20208;
   -- ORA-20208: Invalid lobCache Quota.
   -- *Cause   : condition 0 < lobCacheQuota < 1 violated
   -- *Action  : either use default value of lobcachequota or provide
   --            a suitable positive fraction less than 1. 

   invalidcompression exception;
   PRAGMA EXCEPTION_INIT(invalidcompression, -20209);
   invalidcompression_msg constant varchar2(256) :=
   ' INVALID COMPRESSION LEVEL';
   invalidcompression_err constant pls_integer := -20209;
   -- ORA-20209: Invalid Compression Level
   -- *Cause: COMPRESSION_LEVEL StoreProperty has an invalid value
   -- *Action: Set COMPRESSION_LEVEL To a valid value
   
   filesizemismatch exception;
   PRAGMA EXCEPTION_INIT(filesizemismatch, -20210);
   filesizemismatch_msg constant varchar2(256) :=
   ' FILE SIZE MISMATCH';
   filesizemismatch_err constant pls_integer := -20210;
   -- ORA-20210: File Size mismatch
   -- *Cause: Data has been corrupted
   -- *Action: Contact Oracle Customer Support

   thrashing exception;
   PRAGMA EXCEPTION_INIT(thrashing, -20211);
   thrashing_msg constant varchar2(256) :=
   ' THRASHING IN LOBCACHE';
   thrashing_err constant pls_integer := -20211;
   -- ORA-20211: Thrahing in  lobcache
   -- *Cause: Small lob cache for bigger working set
   -- *Action: Increase cache size to accomodate working set 
   --          to minimize thrashing and improve performance
   
   filenotfound exception;
   PRAGMA EXCEPTION_INIT(filenotfound, -20212);
   filenotfound_msg constant varchar2(256) :=
   ' FILE NOT FOUND';
   filenotfound_err constant pls_integer := -20212;
   -- ORA-20212: File not found
   -- *Cause: File not found 
   -- *Action: Contact Oracle Customer Support
   
   dropstore_runningjob exception;
   PRAGMA EXCEPTION_INIT(dropstore_runningjob, -20213);
   dropstore_runningjob_msg constant varchar2(256) :=
   ' JOB STILL RUNNING.STORE NOT DROPPED. TRY AGAIN.';
   dropstore_runningjob_err constant pls_integer := -20213;
   -- ORA-20213: JOB STILL RUNNING.STORE NOT DROPPED. TRY AGAIN
   -- *Cause: Store cannot be dropped because associated job is still running.
   -- *Action: Try dropStore procedure again.
   
   FAIL    CONSTANT NUMBER := 0;
   SUCCESS CONSTANT NUMBER := 1;
   ERROR   CONSTANT NUMBER := 2;
   
      
   
    function    getFeatures(
        store_name          in      varchar2)
            return  integer;
            
    function    getStoreId(
        store_name          in      varchar2)
            return  number;

    function    getVersion(
        store_name          in      varchar2)
            return  varchar2;

    procedure   spaceUsage(
        store_name  in              varchar2,
        blksize     out             integer,
        tbytes      out             integer,
        fbytes      out             integer,
        nfile       out             integer,
        ndir        out             integer,
        nlink       out             integer,
        nref        out             integer);


    procedure   createFile(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     in out nocopy   blob,
        prop_flags  in              integer,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   createLink(
        store_name  in              varchar2,
        srcPath     in              varchar2,
        dstPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        prop_flags  in              integer,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   createReference(
        store_name  in              varchar2,
        srcPath     in              varchar2,
        dstPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        prop_flags  in              integer,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   createDirectory(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        prop_flags  in              integer,
        recurse     in              integer,
        ctx     in              dbms_dbfs_content_context_t);


    procedure   deleteFile(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        soft_delete in              integer,
        ctx     in              dbms_dbfs_content_context_t);
        
    procedure   deleteContent(
        store_name  in              varchar2,
        contentID   in              raw,
        filter      in              varchar2,
        soft_delete in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   deleteDirectory(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        soft_delete in              integer,
        recurse     in              integer,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   restorePath(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   purgePath(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   restoreAll(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   purgeAll(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        ctx     in              dbms_dbfs_content_context_t);


    procedure   getPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     out             blob,
        item_type   out             integer,
        prop_flags  in              integer,
        forUpdate   in              integer,
        deref       in              integer,
        ctx     in              dbms_dbfs_content_context_t);
    
    procedure   getPathNowait(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     out    nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer,
        deref       in              integer,
        ctx     in              dbms_dbfs_content_context_t);
  
    procedure   getPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        amount      in out          number,
        offset      in              number,
        buffer      out             raw,
        prop_flags  in              integer,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   getPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        amount      in out          number,
        offset      in              number,
        buffers     out             dbms_dbfs_content_raw_t,
        prop_flags  in              integer,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   putPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     in out nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   putPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        amount      in              number,
        offset      in              number,
        buffer      in              raw,
        prop_flags  in              integer,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   putPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        written     out             number,
        offset      in              number,
        buffers     in              dbms_dbfs_content_raw_t,
        prop_flags  in              integer,
        ctx     in              dbms_dbfs_content_context_t);


    procedure   renamePath(
        store_name  in              varchar2,
        oldPath     in              varchar2,
        newPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        ctx     in              dbms_dbfs_content_context_t);
    
    procedure   setPath(
        store_name  in              varchar2,
        contentID   in              raw,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        ctx         in              dbms_dbfs_content_context_t);

    function    list(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        recurse     in              integer,
        ctx     in              dbms_dbfs_content_context_t)
            return  dbms_dbfs_content_list_items_t
            pipelined;

    function    search(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        recurse     in              integer,
        ctx     in              dbms_dbfs_content_context_t)
            return  dbms_dbfs_content_list_items_t
            pipelined;


    procedure   lockPath(
        store_name  in              varchar2,
        path        in              varchar2,
        lock_type   in              integer,
        lock_data   in              varchar2,
        ctx     in              dbms_dbfs_content_context_t);

    procedure   unlockPath(
        store_name  in              varchar2,
        path        in              varchar2,
        ctx     in              dbms_dbfs_content_context_t);


    function    checkAccess(
        store_name  in              varchar2,
        path        in              varchar2,
        pathtype    in              integer,
        operation   in              varchar2,
        principal   in              varchar2)
            return  integer;

                
    function    getPathByStoreId(
        store_name          in      varchar2,
        guid                in      integer)
            return  varchar2;

    -- Create a new HS Store.
    -- 
    -- Creates a new HS store "store_name" of type   
    -- "store_type" ( STORETYPE_TAPE or STORETYPE_AMAZONS3" )
    --  in schema "schema_name" ( defaulting to current schema )
    --  under the ownership of invoking session user.
    --  "tbl_name" in tablespace "tbs_space" is a placeholder of the
    --  store content cached in database. 
    --
    --  "cache_size" worth of space will be used by the store
    --  to cache content in given  table space "tbs_name".
    --
    --
    procedure   createStore(
        store_name  in              varchar2,
        store_type  in              varchar2,
        tbl_name    in              varchar2,
        tbs_name    in              varchar2,
        cache_size  in              number  ,
        lob_cache_quota      in number default null,
        optimal_tarball_size in number default null,
        schema_name in              varchar2 default null);
    
    -- Drop HS Store
    -- 
    -- Drops previously created "store_name" under the ownership of the
    -- invoking session_user. 
    --
    -- The store will be un-registered from DBFS.
    -- All files within given store will be deleted from backend, 
    -- (Tape/S3). Caching table , placeholder for store's
    -- content cached in database, will be dropped. 
    --
    -- The procedure executes like a DDL (ie auto-commits before 
    -- and after its execution)
    --
    -- User can specify optional flags for dropStore.
    -- If 'DISABLE_CLEANUPBACKUPFILES' ( HS DropStore FLags) 
    -- is specified as one of the optional flags,
    -- cleanUpBackupFiles will not be issued as a part of dropStore.
    --
    -- By default, when this flag is not set , dropStore implicitly
    -- cleans up all unused backupfiles. 
    -- 
    -- dropStore purges all the dictionary information associated with 
    -- the store. If cleanupbackupFiles is disabled during dropstore,
    -- user will have to resort to out-of-band techniques to remove unused
    -- backup files. No further invocations of cleanupbackfiles for a dropped 
    -- store are possible through HS

    DISABLE_CLEANUPBACKUPFILES constant integer := 1;
    procedure dropStore(
        store_name  in              varchar2,
        opt_flags   in              integer default 0);
        

-- Push locally staged data to remote store 
   procedure storePush(store_name in varchar2, path in varchar2 default null); 
   

-- Cleanup unused backup files
   procedure cleanupUnusedBackupfiles(store_name in varchar2);

-- Send an explicit store command
   procedure sendCommand(store_name in varchar2, message in varchar2);

   
   -- This method saves properties ( = name, value pairs) of 
   -- a store in the database
   procedure setStoreProperty(store_name in varchar2, 
                              property_name in varchar2,
                              property_value in varchar2);
   -- This method retrieves the values of a property, identified
   -- by PropertyName, of a store from the database.
   -- If NoExcp is set to false, then exception is raised if the
   -- property does not exist in the database.
   -- If noexcp is set to true, then null is returned if the 
   -- property does not exist in the database                       
   function getStoreProperty(store_name  in varchar2, 
                             property_name in varchar2,
                             noexcp in boolean default false)
   return varchar2;

   -- When we try to push data to or get data from external store,
   -- we will begin an API session (to talk to the store), and after beginning
   -- the session, we will send all registered messages to the store
   -- before writing any data.
   -- Following are the valid values for the parameter FLAGS in 
   -- REGISTERSTORECOMMAND method.
   BEFORE_PUT CONSTANT NUMBER := 1;
   BEFORE_GET CONSTANT NUMBER := 2;
   procedure registerStoreCommand(store_name in varchar2, message in varchar2,
                                  flags in number);

   -- Deregister a store message.
   procedure deregStoreCommand(store_name in varchar2, message in varchar2);

   -- The AWS bucket, associated with a store of type 
   -- STORETYPE_AMAZONS3 , should already exist when the HS
   -- tries to move data into that bucket. One way of creating S3 bucket is to
   -- use the DBMS_DBFS_HS.CREATEBUCKET method.
   -- The PROPNAME_BUCKET property of the store should be set
   -- before this method is called.
   procedure createBucket(store_name in varchar2);

   -- listcontentFilename lists all the content file names across all
   -- the storeitories owned by the current session user.   
   function    listcontentfilename
      return  dbms_dbfs_hs_litems_t
              pipelined;

   -- Flushes out dirty contents from level-1 cache.
   -- And truncates all the lockable content from cache.
   procedure flushCache( store_name in varchar2);

   procedure reconfigCache( store_name in  varchar2,
                            cache_size in  number default null,
                            lob_cache_quota in number default null,
                            optimal_tarball_size in number default null);
end;
/
show errors;

create or replace public synonym dbms_dbfs_hs
    for sys.dbms_dbfs_hs;

grant execute on dbms_dbfs_hs
    to dbfs_role;

