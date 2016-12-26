Rem
Rem $Header: rdbms/admin/dbmsfspi.sql /st_rdbms_11.2.0/10 2012/02/02 09:53:08 kkunchit Exp $
Rem
Rem dbmsfspi.sql
Rem
Rem Copyright (c) 2008, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsfspi.sql - DBFS SFS reference provider specification.
Rem
Rem    DESCRIPTION
Rem      DBFS SFS reference provider specification.
Rem
Rem    NOTES
Rem      Specification for the "dbms_dbfs_sfs" and "dbms_dbfs_sfs_admin"
Rem      packages. The SFS provider implements POSIX filesystem semantics.
Rem
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      01/24/12 - Backport
Rem                           kkunchit_blr_backport_12944766_11.2.0.2.0 from
Rem                           st_rdbms_11.2.0
Rem    kkunchit    06/17/11 - Backport kkunchit_bug-10051996 from main
Rem    kkunchit    06/10/11 - Backport kkunchit_bug-12582607 from main
Rem    kkunchit    04/20/11 - Backport kkunchit_bug-10158541 from main
Rem    kkunchit    03/08/11 - Backport kkunchit_bug-10630023 from main
Rem    kkunchit    03/02/11 - Backport kkunchit_bug-10349967 from main
Rem    kkunchit    12/29/10 - Backport kkunchit_bug-9270948 from main
Rem    kkunchit    08/04/10 - Backport kkunchit_bug-9956078 from main
Rem    smuthuli    07/21/10 - Backport smuthuli_bug-9582487 from main
Rem    kkunchit    07/14/10 - Backport kkunchit_bug-9881611 from main
Rem    kkunchit    05/27/11 - bug-12568334: sfs sequence cache
Rem    kkunchit    05/23/11 - bug-12582607: nanosecond resolution timestamps
Rem    kkunchit    02/17/11 - bug-10349967: dbfs export/import support
Rem    kkunchit    01/04/11 - bug-10630023: split rename/move semantics
Rem    kkunchit    10/05/10 - bug-10158541: transactional filesystem
Rem                           create/destroy/cleanup
Rem    kkunchit    08/25/10 - bug-10051996: online filesystem redefinition
Rem    kkunchit    07/26/10 - bug-9956078: dbfs fastpath
Rem    kkunchit    07/09/10 - df improvements: bulk APIs
Rem    kkunchit    07/03/10 - bug-9881611: readdir enhancements
Rem    kkunchit    04/26/10 - bug-9651229: consistent root guid
Rem    kkunchit    04/12/10 - bug-9199152: cleanup of orphan metadata
Rem    kkunchit    04/12/10 - optimized space usage computation
Rem    kkunchit    09/29/09 - sfs shrink
Rem    kkunchit    09/16/08 - Created
Rem



/* ----------------------------- dbms_dbfs_sfs ----------------------------- */
/*
 * The package "dbms_dbfs_sfs" is a store provider for the DBFS API and thus
 * conforms to the DBFS SPI defined in "dbms_dbfs_content_spi".
 *
 */

create or replace package dbms_dbfs_sfs
    authid current_user
as



    /*
     *
     * Special properties for SFS filesystems.
     *
     *
     * sfs_props_pts:
     * If specified, the granularity (in seconds) of the update of the
     * timestamp of the parent directory of a file element being created
     * or deleted. If the most recent update to the parent directory was
     * more recent than the specified interval, no changes are made to
     * the parent---this can lead to 2 types of potential problems: (a)
     * a slightly inaccurate timestamp and (b) race conditions where one
     * application is attempting to delete an empty directory and
     * another application is attempting to create a new file element
     * inside that directory.
     *
     * If the child element is a directory, this property is ignored
     * since directory creation/deletion involve other changes to the
     * parent (link counting) that cannot be skipped.
     *
     * Use with care and only when it is absolutely clear what
     * specifying this property means.
     *
     *
     * sfs_props_rootid:
     * An internally generated and maintained number indicating the
     * filesystem incarnation (root node ID) at the time of creation or
     * truncation. **NOTE**: This value should not be used or modified
     * by anyone except the SFS provider itself.
     *
     *
     * sfs_props_normid:
     * If specified (as a boolean equivalent), and if the filesystem
     * uses normalized root node IDs (see "sfs_props_rootid" above), the
     * SFS provider will attempt to dynamically generate and translate
     * guids so as to be globally unique.
     *
     *
     * sfs_props_df:
     * If specified, denotes the type of algorithm used for space usage
     * computation in a filesystem. Possible values are:
     *
     *   'full' (the default) implying a detailed computation that
     *   maps used and free space based on segment bitmaps.
     *
     *   'fast' implying a segment-level summary of the total bytes
     *   used (with no "free" space).
     *
     *   'none' implying no space usage computation (both "used" and
     *   "free" space denoted as zero).
     *
     * Non-default values will result in "df"-like commands executing
     * very quickly, but will show varying levels of inaccurate data.
     *
     *
     * sfs_props_df_cache:
     * If specified, the cache lifetime (in seconds) of the space
     * computation results of the given store. A value <= "0" implies no
     * caching of the results. If space usage is cached, tools like "df"
     * will not immediately reflect changes to the filesystem, but the
     * overall performance of DBFS operations will improve (since
     * expensive queries are not run as long as the cache is considered
     * valid).
     *
     */

    sfs_props_pts       constant varchar2(32)   := 'sfs:props:pts';
    sfs_props_rootid    constant varchar2(32)   := 'sfs:props:rootid';
    sfs_props_normid    constant varchar2(32)   := 'sfs:props:normid';
    sfs_props_df        constant varchar2(32)   := 'sfs:props:df';
    sfs_props_df_cache  constant varchar2(32)   := 'sfs:props:df_cache';



    /*
     * Table/filesystem descriptors:
     *
     * A "table_t" is a record that describes a POSIX filesystem table
     * (in any schema) that is available for use a POSIX store.
     *
     * A "filesystem_t" is a record that describes a POSIX filesystem
     * registered for use by the current user.
     *
     * Clients can query this API for the list of available store
     * tables, determine which ones are suitable for their use, and
     * register one or more of these tables as stores.
     *
     */

    type table_t        is record (
        schema_name         varchar2(32),
        table_name          varchar2(32),
        ptable_name         varchar2(32),
        version#            varchar2(32),
        created             timestamp,
        formatted           timestamp,
        properties          dbms_dbfs_content_properties_t
    );
    type tables_t is table of table_t;


    type volume_t       is record (
        schema_name         varchar2(32),
        table_name          varchar2(32),
        volume_name         varchar2(128),
        created             timestamp,
        from_volume         varchar2(128),
        from_snapshot       varchar2(128)
    );
    type volumes_t is table of volume_t;


    type snapshot_t     is record (
        schema_name         varchar2(32),
        table_name          varchar2(32),
        volume_name         varchar2(128),
        snapshot_name       varchar2(128),
        created             timestamp
    );
    type snapshots_t is table of snapshot_t;


    type filesystem_t   is record (
        store_name          varchar2(32),
        schema_name         varchar2(32),
        table_name          varchar2(32),
        volume_name         varchar2(128),
        snapshot_name       varchar2(128),
        created             timestamp
    );
    type filesystems_t is table of filesystem_t;



    /* fastpath types */
    type dir_entry_t is record (
        path        varchar2(1024),              /* dbms_dbfs_content.path_t */
        item_name   varchar2(256),               /* dbms_dbfs_content.name_t */
        st_ino      integer,
        st_mode     integer,
        st_nlink    integer,
        st_uid      integer,
        st_gid      integer,
        st_size     integer,
        st_blksize  integer,
        st_blocks   integer,
        st_atime    integer,
        st_mtime    integer,
        st_ctime    integer,
        st_atimens  integer,
        st_mtimens  integer,
        st_ctimens  integer
    );
    type dir_entries_t is table of dir_entry_t;


    /* table of dbms_dbfs_content.propname_t */
    type propnames_t is table of varchar2(32);



    /* dependent segments */
    type dsegment_t is record (
        schema          varchar2(128),
        segment_name    varchar2(128)
    );
    type dsegments_t is table of dsegment_t index by pls_integer;



    /*
     * List all available store tables and their properties.
     *
     */

    function    listTables
            return  tables_t
                pipelined;


    /*
     * List all volumes available for POSIX store tables.
     *
     */

    function    listVolumes
            return  volumes_t
                pipelined;


    /*
     * List all snapshots available for POSIX store tables.
     *
     */

    function    listSnapshots
            return  snapshots_t
                pipelined;


    /*
     * List all registered POSIX filesystems.
     *
     */

    function    listFilesystems
            return  filesystems_t
                pipelined;



    /*
     * Lookup store features (see dbms_dbfs_content.feature_XXX). Lookup
     * store id.
     *
     * A store ID identifies a provider-specific store, across
     * registrations and mounts, but independent of changes to the store
     * contents.
     *
     * I.e. changes to the store table(s) should be reflected in the
     * store ID, but re-initialization of the same store table(s) should
     * preserve the store ID.
     *
     * Providers should also return a "version" (either specific to a
     * provider package, or to an individual store) based on a standard
     * <a.b.c> naming convention (for <major>, <minor>, and <patch>
     * components).
     *
     */

    function    getFeatures(
        store_name          in      varchar2)
            return  integer;

    function    getStoreId(
        store_name          in      varchar2)
            return  number;

    function    getVersion(
        store_name          in      varchar2)
            return  varchar2;



    /*
     * Lookup pathnames by (store_name, std_guid) or (store_mount,
     * std_guid) tuples.
     *
     * If the underlying "std_guid" is found in the underlying store,
     * this function returns the store-qualified pathname.
     *
     * If the "std_guid" is unknown, a "null" value is returned. Clients
     * are expected to handle this as appropriate.
     *
     */

    function    getPathByStoreId(
        store_name          in      varchar2,
        guid                in      integer)
            return  varchar2;



    /*
     * to_epoch:  timestamp to Unix epoch convertor.
     * get_epoch: the Unix epoch.
     *
     */

    function    to_epoch(
        tv              in              timestamp)
        return  number
            deterministic;

    function    get_epoch
        return  timestamp
            deterministic;



    /*
     * DBFS SPI: space usage.
     *
     * Clients can query filesystem space usage statistics via the
     * "spaceUsage()" method. Store providers, in turn, are expected to
     * support at least the "spaceUsage()" method for their stores (and
     * to make a best effort determination of space usage---esp. if the
     * store consists of multiple tables/indexes/lobs, etc. scattered
     * across multiple tablespaces/datafiles/disk-groups, etc.).
     *
     * See "dbms_dbfs_content_spi" for more details on the
     * DBFS-API/provider-SPI contract.
     *
     *
     * "blksize" is the natural tablespace blocksize that holds the
     * store---if multiple tablespaces with different blocksizes are
     * used, any valid blocksize is acceptable.
     *
     * "tbytes" is the total size of the store in bytes, and "fbytes" is
     * the free/unused size of the store in bytes. These values are
     * computed over all segments that comprise the store.
     *
     * "nfile", "ndir", "nlink", and "nref" count the number of
     * currently available files, directories, links, and references in
     * the store.
     *
     * Since database objects are dynamically growable, it is not easy
     * to estimate the division between "free" space and "used" space.
     *
     *
     * The SPI has 2 space usage methods: "spaceUsage()" and
     * "spaceUsageFull()". The difference between the two is that the
     * latter function should implement a "bulk" API---i.e. the ability
     * to query and aggregate space usage information for all stores
     * specified as the "propvalue" fields of the "store_names" property
     * list (the other fields of the property list can be ignored).
     *
     * If the SPI does not support the "bulk" aggregation API, the DBFS
     * API will itself do the necessary iteration and aggregation,
     * however, at the risk of inaccurate data due to potential
     * double-counting.
     *
     *
     * In all cases, the DBFS API will invoke the SPI's space usage
     * functions with only those stores that are managed by the provider
     * package.
     *
     *
     * If "useEstimate" is specified, providers capable of computing
     * fast-but-approximate space usage information can make use of this
     * optimization. Otherwise, the default space usage computation will
     * be used.
     *
     */

    procedure   spaceUsage(
        store_name  in              varchar2,
        blksize     out             integer,
        tbytes      out             integer,
        fbytes      out             integer,
        nfile       out             integer,
        ndir        out             integer,
        nlink       out             integer,
        nref        out             integer);

    procedure   spaceUsage(
        store_name  in              varchar2,
        blksize     out             integer,
        tbytes      out             integer,
        fbytes      out             integer,
        nfile       out             integer,
        ndir        out             integer,
        nlink       out             integer,
        nref        out             integer,
        useEstimate in              integer);

    procedure   spaceUsageFull(
        store_names in              dbms_dbfs_content_properties_t,
        blksize     out             integer,
        tbytes      out             integer,
        fbytes      out             integer,
        nfile       out             integer,
        ndir        out             integer,
        nlink       out             integer,
        nref        out             integer);

    procedure   spaceUsageFull(
        store_names in              dbms_dbfs_content_properties_t,
        blksize     out             integer,
        tbytes      out             integer,
        fbytes      out             integer,
        nfile       out             integer,
        ndir        out             integer,
        nlink       out             integer,
        nref        out             integer,
        useEstimate in              integer);



    /*
     * Fastpath lookup view support.
     *
     * Providers that are willing/able to create a fastpath lookup view
     * (whose structure conforms to the schema of
     * "dbms_fuse.dir_entry_t") should define "createGetattrView()" and
     * "dropGetattrView()" methods, and create/drop the underlying view
     * as needed.
     *
     * The view name should be returned to the caller. The provider is
     * free to invalidate or drop the view at any time, even without
     * explicit request, based on its own state.
     *
     *
     * The "recreateGetattrView" is meant for internal-use only during
     * export/import operations.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   createGetattrView(
        store_name  in              varchar2,
        ctx         in              dbms_dbfs_content_context_t,
        view_name   out nocopy      varchar2);

    procedure   recreateGetattrView(
        store_name  in              varchar2,
        ctx         in              dbms_dbfs_content_context_t,
        view_name   in              varchar2);

    procedure   dropGetattrView(
        store_name  in              varchar2,
        view_name   in              varchar2);



    /*
     * DBFS SPI: notes on pathnames.
     *
     * All pathnames used in the SPI are store-qualified, i.e. a 2-tuple
     * of the form (store_name, pathname) (where the pathname is rooted
     * within the store namespace).
     *
     *
     * Stores/providers that support contentID-based access (see
     * "feature_content_id") also support a form of addressing that is
     * not based on pathnames. Items are identified by an explicit store
     * name, a "null" pathname, and possibly a contentID specified as a
     * parameter or via the "opt_content_id" property.
     *
     * Not all operations are supported with contentID-based access, and
     * applications should depend only on the simplest create/delete
     * functionality being available.
     *
     */



    /*
     * DBFS SPI: creation operations
     *
     * The SPI must allow the DBFS API to create directory, file, link,
     * and reference elements (subject to store feature support).
     *
     *
     * All of the creation methods require a valid pathname (see the
     * special exemption for contentID-based access below), and can
     * optionally specify properties to be associated with the pathname
     * as it is created. It is also possible for clients to fetch-back
     * item properties after the creation completes (so that
     * automatically generated properties (e.g. "std_creation_time") are
     * immediately available to clients (the exact set of properties
     * fetched back is controlled by the various "prop_xxx" bitmasks in
     * "prop_flags").
     *
     *
     * Links and references require an additional pathname to associate
     * with the primary pathname.
     *
     * File pathnames can optionally specify a BLOB value to use to
     * initially populate the underlying file content (the provided BLOB
     * may be any valid lob: temporary or permanent). On creation, the
     * underlying lob is returned to the client (if "prop_data" is
     * specified in "prop_flags").
     *
     * Non-directory pathnames require that their parent directory be
     * created first. Directory pathnames themselves can be recursively
     * created (i.e. the pathname hierarchy leading up to a directory
     * can be created in one call).
     *
     *
     * Attempts to create paths that already exist is an error; the one
     * exception is pathnames that are "soft-deleted" (see below for
     * delete operations)---in these cases, the soft-deleted item is
     * implicitly purged, and the new item creation is attempted.
     *
     *
     * Stores/providers that support contentID-based access accept an
     * explicit store name and a "null" path to create a new element.
     * The contentID generated for this element is available via the
     * "opt_content_id" property (contentID-based creation automatically
     * implies "prop_opt" in "prop_flags").
     *
     * The newly created element may also have an internally generated
     * pathname (if "feature_lazy_path" is not supported) and this path
     * is available via the "std_canonical_path" property.
     *
     * Only file elements are candidates for contentID-based access.
     *
     */

    procedure   createFile(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     in out nocopy   blob,
        prop_flags  in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   createLink(
        store_name  in              varchar2,
        srcPath     in              varchar2,
        dstPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        prop_flags  in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   createReference(
        store_name  in              varchar2,
        srcPath     in              varchar2,
        dstPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        prop_flags  in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   createDirectory(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        prop_flags  in              integer,
        recurse     in              integer,
        ctx         in              dbms_dbfs_content_context_t);



    /*
     * DBFS SPI: deletion operations
     *
     * The SPI must allow the DBFS API to delete directory, file, link,
     * and reference elements (subject to store feature support).
     *
     *
     * By default, the deletions are "permanent" (get rid of the
     * successfully deleted items on transaction commit), but stores may
     * also support "soft-delete" features. If requested by the client,
     * soft-deleted items are retained by the store (but not typically
     * visible in normal listings or searches).
     *
     * Soft-deleted items can be "restore"d, or explicitly purged.
     *
     *
     * Directory pathnames can be recursively deleted (i.e. the pathname
     * hierarchy below a directory can be deleted in one call).
     * Non-recursive deletions can be performed only on empty
     * directories. Recursive soft-deletions apply the soft-delete to
     * all of the items being deleted.
     *
     *
     * Individual pathnames (or all soft-deleted pathnames under a
     * directory) can be restored or purged via the restore and purge
     * methods.
     *
     *
     * Providers that support filtering can use the provider "filter" to
     * identify subsets of items to delete---this makes most sense for
     * bulk operations (deleteDirectory, restoreAll, purgeAll), but all
     * of the deletion-related operations accept a "filter" argument.
     *
     *
     * Stores/providers that support contentID-based access can also
     * allow file items to be deleted by specifying their contentID.
     *
     */

    procedure   deleteFile(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        soft_delete in              integer,
        ctx         in              dbms_dbfs_content_context_t);

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
        ctx         in              dbms_dbfs_content_context_t);

    procedure   restorePath(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   purgePath(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   restoreAll(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   purgeAll(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        ctx         in              dbms_dbfs_content_context_t);



    /*
     * DBFS SPI: path get/put operations.
     *
     * Existing path items can be accessed (for query or for update) and
     * modified via simple get/put methods.
     *
     * All pathnames allow their metadata (i.e. properties) to be
     * read/modified. On completion of the call, the client can request
     * (via "prop_flags") specific properties to be fetched as well.
     *
     * File pathnames allow their data (i.e. content) to be
     * read/modified. On completion of the call, the client can request
     * (via the "prop_data" bitmaks in "prop_flags") a new BLOB locator
     * that can be used to continue data access.
     *
     * Files can also be read/written without using BLOB locators, by
     * explicitly specifying logical offsets/buffer-amounts and a
     * suitably sized buffer.
     *
     *
     * Update accesses must specify the "forUpdate" flag. Access to link
     * pathnames can be implicitly and internally dereferenced by stores
     * (subject to feature support) if the "deref" flag is
     * specified---however, this is dangerous since symbolic links are
     * not always resolvable.
     *
     *
     * The read methods (i.e. "getPath" where "forUpdate" is "false"
     * also accepts a valid "asof" timestamp parameter that can be used
     * by stores to implement "as of" style flashback queries. Mutating
     * versions of the "getPath" and the "putPath" methods do not
     * support as-of modes of operation.
     *
     *
     * "getPathNowait" implies a "forUpdate", and, if implemented (see
     * "feature_nowait"), allows providers to return an exception
     * (ORA-54) rather than wait for row locks.
     *
     */

    procedure   getPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     out    nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer,
        forUpdate   in              integer,
        deref       in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   getPathNowait(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     out    nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer,
        deref       in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   getPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        amount      in out          number,
        offset      in              number,
        buffer      out    nocopy   raw,
        prop_flags  in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   getPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        amount      in out          number,
        offset      in              number,
        buffers     out    nocopy   dbms_dbfs_content_raw_t,
        prop_flags  in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   putPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     in out nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   putPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        amount      in              number,
        offset      in              number,
        buffer      in              raw,
        prop_flags  in              integer,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   putPath(
        store_name  in              varchar2,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        written     out             number,
        offset      in              number,
        buffers     in              dbms_dbfs_content_raw_t,
        prop_flags  in              integer,
        ctx         in              dbms_dbfs_content_context_t);



    /*
     * DBFS SPI: rename/move operations.
     *
     * Pathnames can be renamed or moved, possibly across directory
     * hierarchies and mount-points, but within the same store.
     *
     *
     * Path renaming functions like the POSIX "rename" syscall while
     * path moving functions like the POSIX "mv" command.
     *
     *
     * The following table summarizes the behavior of "rename" and
     * "move".
     *
     * -------------------------------------------------------------------------------
     * operation         oldPath               newPath   behavior
     * -------------------------------------------------------------------------------
     * rename      non-directory                  self   noop/success
     * rename      non-directory          non-existent   rename/success
     * rename      non-directory         non-directory   delete "newPath", rename
     * rename      non-directory             directory   invalid_arguments exception
     *
     * rename          directory                  self   noop/success
     * rename          directory          non-existent   rename/success
     * rename          directory         non-directory   invalid_arguments exception
     * rename          directory       empty directory   delete "newPath", rename
     * rename          directory   non-empty directory   invalid_arguments exception
     * -------------------------------------------------------------------------------
     * move        non-directory                  self   noop/success
     * move        non-directory          non-existent   rename/success
     * move        non-directory         non-directory   delete "newPath", rename
     * move        non-directory             directory   move "oldPath" into "newPath"
     *               (delete existing non-directory, else invalid_arguments exception)
     *
     * move            directory                  self   noop/success
     * move            directory          non-existent   rename/success
     * move            directory         non-directory   invalid_arguments exception
     * move            directory       empty directory   move "oldPath" into "newPath"
     * move            directory   non-empty directory   move "oldPath" into "newPath"
     *             (delete existing empty directory, else invalid_arguments exception)
     * -------------------------------------------------------------------------------
     *
     * Since the semantics of rename/move w.r.t. non-existent/existent
     * and non-directory/directory targets is complex, clients may
     * choose to implement complex renames and moves as a sequence of
     * simpler moves or copies.
     *
     *
     * Stores/providers that support contentID-based access and lazy
     * pathname binding also support the "setPath" method that
     * associates an existing "contentID" with a new "path".
     *
     */

    procedure   renamePath(
        store_name  in              varchar2,
        oldPath     in              varchar2,
        newPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   movePath(
        store_name  in              varchar2,
        oldPath     in              varchar2,
        newPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   setPath(
        store_name  in              varchar2,
        contentID   in              raw,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        ctx         in              dbms_dbfs_content_context_t);



    /*
     * DBFS SPI: directory navigation and search.
     *
     * The DBFS API can list or search the contents of directory
     * pathnames, optionally recursing into sub-directories, optionally
     * seeing soft-deleted items, optionally using flashback "as of" a
     * provided timestamp, and optionally filtering items in/out within
     * the store based on list/search predicates.
     *
     *
     * "listCursor" is a highly specialized directory enumerator that is
     * meant for use with "dbms_fuse" and "dbfs_client" as the ultimate
     * callers, and with "dbms_dbfs_sfs.listCursor" as the callee.
     *
     * Other providers are not expected to implement this method
     * (dbms_fuse can compensate for this by falling back to using the
     * generic "list()" method).
     *
     */

    function    list(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        recurse     in              integer,
        ctx         in              dbms_dbfs_content_context_t)
            return  dbms_dbfs_content_list_items_t
                pipelined;

    function    listCursor(
        store_name  in              varchar2,
        mnt_prefix  in              varchar2,
        path        in              varchar2,
        withProps   in              integer,
        doSort      in              integer,
        doFts       in              integer,
        doBulk      in              integer,
        ctx         in              dbms_dbfs_content_context_t)
            return  integer;

    function    search(
        store_name  in              varchar2,
        path        in              varchar2,
        filter      in              varchar2,
        recurse     in              integer,
        ctx         in              dbms_dbfs_content_context_t)
            return  dbms_dbfs_content_list_items_t
                pipelined;



    /*
     * DBFS SPI: locking operations.
     *
     * Clients of the DBFS API can apply user-level locks to any valid
     * pathname (subject to store feature support), associate the lock
     * with user-data, and subsequently unlock these pathnames.
     *
     * The status of locked items is available via various optional
     * properties (see "opt_lock*" above).
     *
     *
     * It is the responsibility of the store (assuming it supports
     * user-defined lock checking) to ensure that lock/unlock operations
     * are performed in a consistent manner.
     *
     */

    procedure   lockPath(
        store_name  in              varchar2,
        path        in              varchar2,
        lock_type   in              integer,
        lock_data   in              varchar2,
        ctx         in              dbms_dbfs_content_context_t);

    procedure   unlockPath(
        store_name  in              varchar2,
        path        in              varchar2,
        ctx         in              dbms_dbfs_content_context_t);



    /*
     * DBFS SPI: access checks.
     *
     * Check if a given pathname (store_name, path, pathtype) can be
     * manipulated by "operation (see the various
     * "dbms_dbfs_content.op_xxx" opcodes) by "principal".
     *
     * This is a convenience function for the DBFS API; a store that
     * supports access control still internally performs these checks to
     * guarantee security.
     *
     */

    function    checkAccess(
        store_name  in              varchar2,
        path        in              varchar2,
        pathtype    in              integer,
        operation   in              varchar2,
        principal   in              varchar2)
            return  integer;



    /*
     * Create and register a new POSIX store.
     *
     *
     * Create a new POSIX store "store_name" in schema "schema_name"
     * (defaulting to the current schema) as table "tbl_name", with the
     * table (and internal indexes) in tablespace "tbl_tbs" (defaulting
     * to the schema's default tablespace), and its lob column in
     * tablespace "lob_tbs" (defaulting to "tbl_tbs").
     *
     * If "tbl_name" is not specified, an internally generated name is
     * used.
     *
     * If "use_bf" is true, a basicfile lob is used, otherwise a
     * securefile lob is used.
     *
     *
     * "props" is a table of (name, value, typecode) tuples that can be
     * used to configure the store properties. Currently, no such
     * properties are defined or used, but the placeholder exists for
     * future versions of the reference implementation.
     *
     *
     * If the "create_only" argument is "true", the filesystem is
     * created, but not registered with the current user---a separate
     * call to "dbms_dbfs_sfs_admin.registerFilesystem" (by the same
     * users or by other users) is needed to make the filesystem visible
     * for provider operations.
     *
     *
     * If "use_objects" is true, a single base-table with an object-type
     * column (using a nested table) is created to back the new
     * filesystem. Otherwise, a pair of (parent, child) tables is used
     * to back the filesystem. In any case, the object type nested table
     * or the child table is used only for user-defined properties.
     *
     *
     * If "with_grants" is true, DML and query access permissions are
     * granted to the "dbfs_role" as part of creating the filesystem.
     * Otherwise, explicit grants (or existing permissions) are required
     * to be able to access the filesystem.
     *
     *
     * All of the remaining arguments to the procedure deal with special
     * storage options for the file content lobs or to control the
     * partitioning strategy of the filesystem tables. Settings that do
     * not apply (to basicfiles or partitioning strategy) will be
     * silently ignored and coerced to sane values.
     *
     * "createStore" is a wrapper around "createFilesystem".
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    -- "compression" parameter
    compression_default constant varchar2(32)   := '';
    compression_low     constant varchar2(32)   := 'low';
    compression_medium  constant varchar2(32)   := 'medium';
    compression_high    constant varchar2(32)   := 'high';

    -- "encryption" parameter
    encryption_default  constant varchar2(32)   := '';
    encryption_3des168  constant varchar2(32)   := '3DES168';
    encryption_aes128   constant varchar2(32)   := 'AES128';
    encryption_aes192   constant varchar2(32)   := 'AES192';
    encryption_aes256   constant varchar2(32)   := 'AES256';

    -- "npartitions" parameter
    default_partitions  constant integer        := 16;

    -- "partition_key" parameter
    partition_by_item   constant integer        := 1;
    partition_by_path   constant integer        := 2;
    partition_by_guid   constant integer        := 3;

    procedure   createFilesystem(
        store_name      in          varchar2,
        schema_name     in          varchar2    default null,
        tbl_name        in          varchar2    default null,
        tbl_tbs         in          varchar2    default null,
        lob_tbs         in          varchar2    default null,
        use_bf          in          boolean     default false,
        properties      in          dbms_dbfs_content_properties_t
                                                default null,
        create_only     in          boolean     default false,
        use_objects     in          boolean     default false,
        with_grants     in          boolean     default false,
        do_dedup        in          boolean     default false,
        do_compress     in          boolean     default false,
        compression     in          varchar2    default compression_default,
        do_encrypt      in          boolean     default false,
        encryption      in          varchar2    default encryption_default,
        do_partition    in          boolean     default false,
        npartitions     in          number      default default_partitions,
        partition_key   in          number      default partition_by_item,
        partition_guidi in          boolean     default false,
        partition_pathi in          boolean     default false,
        partition_prop  in          boolean     default true);

    procedure   createStore(
        store_name  in              varchar2,
        tbl_name    in              varchar2    default null,
        tbs_name    in              varchar2    default null,
        use_bf      in              boolean     default false,
        stgopts     in              varchar2    default '');



    /*
     * Export a filesystem (for general cross-schema use) by granting
     * suitable permissions to the tables underlying the filesystem to
     * the "dbfs_role".
     *
     * These methods can be successfully invoked only by those users who
     * are capable of granting the necessary privileges, i.e. either by
     * the users who own the underlying filesystem tables, or
     * sufficiently privileged users who can grant access across
     * schemas.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   exportTable(
        schema_name in              varchar2    default null,
        tbl_name    in              varchar2,
        toUserRole  in              varchar2    default 'DBFS_ROLE');

    procedure   exportFilesystem(
        store_name  in              varchar2,
        toUserRole  in              varchar2    default 'DBFS_ROLE');



    /*
     * (Re)initialize a POSIX store.
     *
     *
     * The table associated with the POSIX store "store_name" is
     * truncated and reinitialized with a single "root" directory entry.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   initFS(
        store_name  in              varchar2);



    /*
     * Normalize the guid numbering of an existing POSIX store.
     *
     *
     * Lock the tables associated with the store, renumber the
     * std_guid/std_parent_guid of the various store elements, and
     * modify the store to use normalized numbering (see
     * "sfs_props_rootid").
     *
     * **NOTE**: do not invoke this procedure unless you know exactly
     * what you are doing.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   normalizeFS(
        store_name  in              varchar2);



    /*
     * Shrink a POSIX store.
     *
     *
     * Logically shrink a POSIX store by releasing space from the
     * various segments underlying the store.
     *
     * The primary benefit of the shrink is expected to come from the
     * lob segments in the store (although it is possible in certain
     * circumstances---a large number of very small inline lobs---for
     * the shrink to benefit by operating on table segments).
     *
     * By default, the shrink operation attempts to recover space
     * unconditionally. However, it is possible to specify either a
     * minimum percentage or minimum #bytes reduction before the shrink
     * is triggered---these reduction checks are performed only on the
     * lob segments underlying the store, and are based on an
     * approximate comparison between the size of active lobs vs. size
     * of the underlying segments.
     *
     * If a POSIX store is partitioned, the shrink benefit checks, if
     * enabled, are performed on a per-partition basis.
     *
     *
     * If "dryrun" is specified, the store is not modified, but various
     * checks and space usage computations are traced (via the DBFS API
     * trace).
     *
     *
     * In the case of POSIX stores based on securefiles, shrink requires
     * the use of interim tables. These tables are created, by default,
     * in the default tablespace corresponding to the user that executes
     * the shrink. The "tbs" argument can be used to specify a different
     * tablespace (presumably with enough space) to hold any interim
     * tables created for the shrink.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   shrinkFS(
        store_name  in              varchar2,
        min_pct     in              number      default null,
        min_bytes   in              number      default null,
        dryrun      in              boolean     default false,
        tbs         in              varchar2    default null);



    /*
     * (Online) redefine/reorganize a POSIX store.
     *
     *
     * Redefine/reorganize the logical structure of a POSIX store using
     * another (initially empty) POSIX store as the template for the new
     * organization.
     *
     * This procedure internally uses "dbms_redefinition" and on
     * completion, swaps the objects underlying the old and new stores,
     * as per the semantics of online redefinition.
     *
     *
     * The "srcStore" being reorganized remains available during the
     * process.
     *
     * The "dstStore" being used as the template for reorganization
     * should start out empty (but with the desired new logical
     * structure). This store should also not be in active use (i.e. no
     * ContentAPI registrations or mounts).
     *
     *
     * On completion of the reorganization, both "srcStore" and
     * "dstStore" will have a copy of the same logical data, and
     * "srcStore" will have the desired new structure.
     *
     * At this point, "dstStore" can be dropped to clean up space.
     *
     *
     * The reorganization procedure can be used to:
     *
     *  . shrink a store to release space.
     *  . convert partitioned stores into non-partitioned ones,
     *    or vice versa.
     *  . change the compression, encryption, deduplication storage
     *    properties of the securefiles underlying a store.
     *  . move a store across tablespaces.
     *  . and more
     *
     *
     * The only kind of reorganization not currently supported is
     * converting a user-properties child table based store to/from a
     * nested object-table based store.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   reorganizeFS(
        srcStore    in              varchar2,
        dstStore    in              varchar2);



    /*
     * Modify the properties of a POSIX store.
     *
     * Add, remove, or set the properties of a POSIX store. Changing
     * store properties is best done when there are no users of the
     * filesystem (existing users will attempt to reinitialize the
     * filesystem state and can behave in surprising and inconsistent
     * ways).
     *
     */

    procedure   addFSProperties(
        store_name  in              varchar2,
        properties  in              dbms_dbfs_content_properties_t);

    procedure   deleteFSProperties(
        store_name  in              varchar2,
        properties  in              dbms_dbfs_content_properties_t);

    procedure   setFSProperties(
        store_name  in              varchar2,
        properties  in              dbms_dbfs_content_properties_t);



    /*
     * Unregister and drop a POSIX store.
     *
     *
     * If the specified store table is registered by the current user,
     * it will be unregistered from the DBFS API and the POSIX metadata
     * tables.
     *
     * Subsequent to unregistration, an attempt will be made to store
     * table(s). This operation may fail if other users are currently
     * using this store table---in these cases, it is necessary to also
     * execute "dbms_dbfs_sfs.dropFilesystem" or
     * "dbms_dbfs_sfs_admin.unregisterFilesystem" as these users first
     * before the actual store table can be dropped.
     *
     * Finally, the user attempting a drop of the tables underlying the
     * store must actually have the privileges to complete the drop
     * operation (either as the owner of the tables, or as a
     * sufficiently privileged user for cross-schema operations).
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   dropFilesystem(
        schema_name in              varchar2    default null,
        tbl_name    in              varchar2);

    procedure   dropFilesystem(
        store_name  in              varchar2);



    /*
     * Drop orphaned POSIX stores.
     *
     *
     * An "orphaned" POSIX store is one that is (a) empty of user-data,
     * (b) not referred to in any of the DBFS/SFS metadata tables, and
     * (c) conforming to the structure and signature of an SFS-managed
     * table.
     *
     * Such orphans are most likely left over from past failed and
     * incompletely cleaned up filesystem operations.
     *
     * This procedure will cleanup such orphans by first cleaning up
     * orphaned metadata, and then dropping the orphaned tables.
     *
     *
     * By default, only orphans in the current session_user's schema
     * will be cleaned up. It is possible to explicitly specify a
     * "schema_name" to invoke cleanup in other schemas, and to also
     * explicitly specify a "table_name" to test-and-cleanup a single
     * orphan.
     *
     * **NOTE**: Use this procedure with care.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   cleanupOrphans(
        schema_name     in          varchar2    default null,
        table_name      in          varchar2    default null);



    /*
     * Snapshot operations.
     *
     * All snapshot operations must specify a valid store name
     * "store_name" and a valid snapshot name "snap_name". Additionally,
     * the methods accept a volume name "vol_name" (which may be "null"
     * or defaulted to "main"---these refer to the primary volume);
     * non-default volumes are not currently supported.
     *
     * Since "snap_name" may be used as a pathname component, it should
     * conform to the standard rules about such names (i.e. no embedded
     * "/" characters).
     *
     * All operations also accept a "do_wait" parameter (default "true")
     * which controls whether the invoking session waits for other
     * active transactions to finish, or if it exits immediately if the
     * specified operation cannot be initiated.
     *
     * All operations execute like DDL (i.e. auto-commit before and
     * after their execution).
     *
     *
     * "createSnapshot" creates a new snapshot on the specified
     * store/volume.
     *
     * "revertSnapshot" drops all snapshots/changes in the specified
     * store/volume more recent than the specified snapshot.
     *
     * "dropSnapshot" drops the specified snapshot from the specified
     * store/volume.
     *
     */

    procedure   createSnapshot(
        store_name  in              varchar2,
        snap_name   in              varchar2,
        vol_name    in              varchar2    default 'main',
        do_wait     in              boolean     default true);

    procedure   revertSnapshot(
        store_name  in              varchar2,
        snap_name   in              varchar2,
        vol_name    in              varchar2    default 'main',
        do_wait     in              boolean     default true);

    procedure   dropSnapshot(
        store_name  in              varchar2,
        snap_name   in              varchar2,
        vol_name    in              varchar2    default 'main',
        do_wait     in              boolean     default true,
        recurse     in              boolean     default false);



    /*
     * Filesystem/store operations.
     *
     * Filesystem operations are used to map a (schema, table, volume,
     * snapshot) tuple to a filesystem (aka store) name. A filesystem is
     * accessible via the DBFS API as a store/mount.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   registerFilesystem(
        store_name  in              varchar2,
        schema_name in              varchar2,
        tbl_name    in              varchar2,
        vol_name    in              varchar2    default 'main',
        snap_name   in              varchar2    default null);

    procedure   unregisterFilesystem(
        store_name  in              varchar2);



    /*
     * Fastpath operations for dbms_fuse/dbfs_client only.
     *
     * DO NOT USE DIRECTLY.
     *
     */

    function    fs_getattr(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_ino          out             integer,
        st_mode         out             integer,
        st_nlink        out             integer,
        st_uid          out             integer,
        st_gid          out             integer,
        st_size         out             integer,
        st_blksize      out             integer,
        st_blocks       out             integer,
        st_atime        out             integer,
        st_mtime        out             integer,
        st_ctime        out             integer,
        st_atimens      out             integer,
        st_mtimens      out             integer,
        st_ctimens      out             integer)
        return  integer;

    function    fs_readlink(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        link            out nocopy      varchar2)
        return  integer;

    function    fs_mknod(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_mode         in              integer,
        st_uid          in              integer,
        st_gid          in              integer)
        return  integer;

    function    fs_mknod(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_mode         in              integer,
        st_uid          in              integer,
        st_gid          in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_mkdir(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_mode         in              integer,
        st_uid          in              integer,
        st_gid          in              integer)
        return  integer;

    function    fs_mkdir(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_mode         in              integer,
        st_uid          in              integer,
        st_gid          in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_unlink(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2)
        return  integer;

    function    fs_rmdir(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2)
        return  integer;

    function    fs_symlink(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer,
        st_gid          in              integer)
        return  integer;

    function    fs_symlink(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer,
        st_gid          in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_rename(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        opath           in              varchar2,
        npath           in              varchar2)
        return  integer;

    function    fs_link(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer,
        st_gid          in              integer)
        return  integer;

    function    fs_link(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        link            in              varchar2,
        st_uid          in              integer,
        st_gid          in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_chmod(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_mode         in              integer)
        return  integer;

    function    fs_chmod(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_mode         in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_chown(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_uid          in              integer,
        st_gid          in              integer)
        return  integer;

    function    fs_chown(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_uid          in              integer,
        st_gid          in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_truncate(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        newlen          in              number)
        return  integer;

    function    fs_truncate(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        newlen          in              number,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_utime(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        atime           in              integer,
        mtime           in              integer,
        atimens         in              integer,
        mtimens         in              integer)
        return  integer;

    function    fs_utime(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        atime           in              integer,
        mtime           in              integer,
        atimens         in              integer,
        mtimens         in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_open(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        content         out nocopy      blob,
        forWrite        in              integer)
        return  integer;

    function    fs_open(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        content         out nocopy      blob,
        forWrite        in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_read(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        buffer          out nocopy      raw,
        amount          in              integer,
        offset0         in              integer)
        return  integer;

    function    fs_read(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        amount          in              integer,
        offset0         in              integer,
        buffers         out nocopy      dbms_dbfs_content_raw_t)
        return  integer;

    function    fs_write(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        buffer          in              raw,
        amount          in              integer,
        offset0         in              integer)
        return  integer;

    function    fs_write(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        buffer          in              raw,
        amount          in              integer,
        offset0         in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_write(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        offset0         in              integer,
        buffers         in              dbms_dbfs_content_raw_t)
        return  integer;

    function    fs_write(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        offset0         in              integer,
        buffers         in              dbms_dbfs_content_raw_t,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_statfs(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        f_bsize         out             integer,
        f_frsize        out             integer,
        f_blocks        out             integer,
        f_bfree         out             integer,
        f_bavail        out             integer,
        f_files         out             integer,
        f_ffree         out             integer,
        f_favail        out             integer,
        f_fsid          out             integer,
        f_flag          out             integer,
        f_namemax       out             integer)
        return  integer;

    function    fs_flush(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2)
        return  integer;

    function    fs_release(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2)
        return  integer;

    function    fs_fsync(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2)
        return  integer;

    function    fs_setxattr(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        xname           in              varchar2,
        xvalue          in              raw,
        xflags          in              integer)
        return  integer;

    function    fs_getxattr(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        xname           in              varchar2,
        xvalue          out nocopy      raw)
        return  integer;

    function    fs_listxattr(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2)
        return  propnames_t
            pipelined;

    function    fs_removexattr(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        xname           in              varchar2)
        return  integer;

    function    fs_opendir(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2)
        return  integer;

    function    fs_readdir(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        withProps       in              integer,
        doCursor        in              integer,
        doSort          in              integer,
        doFts           in              integer,
        doBulk          in              integer,
        doFallback      in              integer)
        return  dir_entries_t
            pipelined;

    function    fs_releasedir(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2)
        return  integer;

    function    fs_fsyncdir(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2)
        return  integer;

    function    fs_init
        return  integer;

    function    fs_destroy
        return  integer;

    function    fs_access(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_mode         in              integer)
        return  integer;

    function    fs_creat(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_mode         in              integer,
        content         out nocopy      blob,
        st_uid          in              integer,
        st_gid          in              integer)
        return  integer;

    function    fs_creat(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_mode         in              integer,
        content         out nocopy      blob,
        st_uid          in              integer,
        st_gid          in              integer,
        ret_ino         out             integer,
        ret_mode        out             integer,
        ret_nlink       out             integer,
        ret_uid         out             integer,
        ret_gid         out             integer,
        ret_size        out             integer,
        ret_blksize     out             integer,
        ret_blocks      out             integer,
        ret_atime       out             integer,
        ret_mtime       out             integer,
        ret_ctime       out             integer,
        ret_atimens     out             integer,
        ret_mtimens     out             integer,
        ret_ctimens     out             integer)
        return  integer;

    function    fs_ftruncate(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        newlen          in              integer,
        content         in out nocopy   blob)
        return  integer;

    function    fs_fgetattr(
        store           in              varchar2,
        mount           in              varchar2,
        ctx             in              dbms_dbfs_content_context_t,
        path            in              varchar2,
        st_ino          out             integer,
        st_mode         out             integer,
        st_nlink        out             integer,
        st_uid          out             integer,
        st_gid          out             integer,
        st_size         out             integer,
        st_blksize      out             integer,
        st_blocks       out             integer,
        st_atime        out             integer,
        st_mtime        out             integer,
        st_ctime        out             integer,
        st_atimens      out             integer,
        st_mtimens      out             integer,
        st_ctimens      out             integer)
        return  integer;



end;
/
show errors;

create or replace public synonym dbms_dbfs_sfs
    for sys.dbms_dbfs_sfs;

grant execute on dbms_dbfs_sfs
    to dbfs_role;



/* -------------------------- dbms_dbfs_sfs_admin -------------------------- */
/*
 * The package "dbms_dbfs_sfs_admin" defines provider-specific
 * administrative operations for the POSIX filesystems managed by
 * "dbms_dbfs_sfs".
 *
 * For the most part, the terms "POSIX filesystems" and "POSIX stores" are
 * synonymous.
 *
 * POSIX stores are identified by a (store_owner, store_name) tuple, where
 * "store_owner" is the name of the "session_user" user that creates a store
 * and "store_name" is the specified store name.
 *
 * Store owners are implicit, and a user will not be able to see or access
 * another user's stores via the store APIs.
 *
 */

create or replace package dbms_dbfs_sfs_admin
    authid definer
as



    /*
     * Bless the current session user with sufficient _direct_
     * privileges to enable them to use various DBFS API types in their
     * internal tables.
     *
     * This procedure is not meant to be invoked directly, but is a
     * helper function available for use with the
     * "dbms_dbfs_sfs.createFilesystem" method.
     *
     *
     */

    procedure   blessUser(forView in boolean default false);



    /*
     * Helper function for store creation (only for use with
     * dbms_dbfs_sfs.createFilesystem).
     *
     */

    function    defaultTablespace(
        uname       in          varchar2)
            return  varchar2;



    /*
     * Helper function for looking up a store id (only for use with
     * dbms_dbfs_sfs.getStoreId).
     *
     */

    function    getStoreId(
        schema_name in      varchar2,
        tbl_name    in      varchar2)
            return  number;



    /*
     * Helper functions for space usage queries (only for use with
     * dbms_dbfs_sfs.spaceUsage).
     *
     */

    procedure   spaceDependents(
        schema_name in              varchar2,
        tbl_name    in              varchar2,
        potbl_name  in              varchar2,
        dseg        in out nocopy   dbms_dbfs_sfs.dsegments_t);

    procedure   spaceUsage(
        tbs         in out nocopy   dbms_dbfs_content_properties_t,
        schema_name in              varchar2,
        tbl_name    in              varchar2,
        potbl_name  in              varchar2,
        dseg        in out nocopy   dbms_dbfs_sfs.dsegments_t,
        blksize     out             integer,
        tbytes      out             integer,
        ubytes      out             integer,
        fbytes      out             integer,
        do_fast     in              boolean     default false,
        useEstimate in              integer     default 0);

    function    tbsUsage(
        tbs         in              dbms_dbfs_content_properties_t)
            return  integer;



    /*
     * Helper function for space usage queries (only for use with
     * dbms_dbfs_sfs.shrinkFS).
     *
     */

    procedure   lobUsage(
        schema_name in          varchar2,
        tbl_name    in          varchar2,
        part_name   in          varchar2    default null,
        nbytes      out         integer);



    /*
     * Create a POSIX store.
     *
     * Helper function for store creation (only for use with
     * dbms_dbfs_sfs.createFilesystem).
     *
     *
     * Add a newly created POSIX table to the list of known POSIX
     * tables. At this stage, no store is registered to a particular
     * owner as an accessible filesystem (use "registerFilesystem", if
     * needed).
     *
     * The (schema_name, tbl_name) and its identifier (tabid) must both
     * be database-wide unique. If the table uses object-types,
     * "ptbl_name" should be "null", else the name of a valid properties
     * table.
     *
     */

    procedure   createFilesystem(
        tabid       in              number,
        schema_name in              varchar2,
        tbl_name    in              varchar2,
        ptbl_name   in              varchar2,
        version     in              varchar2,
        properties  in              dbms_dbfs_content_properties_t
                                                default null);



    /*
     * Register a POSIX store.
     *
     *
     * Register an already created POSIX store table
     * (dbms_dbfs_sfs.createFilesystem) in schema "schema_name", table
     * "tbl_name", as a new filesystem named "store_name".
     *
     * The new filesystem/store can optionally be volume/snapshot
     * qualified (by default the "main" volume and current snapshot are
     * used).
     *
     * The same table can be registered as different filesystems by the
     * same/different user as long as the "store_name" and (schema_name,
     * tbl_name, volume_name, snapshot_name) tuple are unique per-user.
     *
     */

    procedure   registerFilesystem(
        store_name      in          varchar2,
        schema_name     in          varchar2,
        tbl_name        in          varchar2,
        volume_name     in          varchar2    default 'main',
        snapshot_name   in          varchar2    default null);



    /*
     * Unregister a POSIX store.
     *
     *
     * The store is removed from the metadata tables, unregistered from
     * the DBFS API, but the underlying filesystem itself is otherwise
     * untouched.
     *
     */

    procedure   unregisterFilesystem(
        store       in              varchar2);



    /*
     * Initialize a POSIX store.
     *
     * Helper function for store initialization (only for use with
     * dbms_dbfs_sfs.initFS).
     *
     *
     * Remove all volumes and snapshots associated with a POSIX
     * filesystem table, and update its "formatted" timestamp.
     *
     */

    procedure   initFilesystem(
        schema_name in              varchar2,
        tbl_name    in              varchar2);



    /*
     * Update the properties of a POSIX store.
     *
     * Helper function for store modification (only for use with
     * dbms_dbfs_sfs.{add,delete,set}FSProperties).
     *
     *
     * Update the store-wide properties of a POSIX store.
     *
     */

    procedure   setFSProperties(
        schema_name in              varchar2,
        tbl_name    in              varchar2,
        properties  in              dbms_dbfs_content_properties_t);



    /*
     * Drop a POSIX store.
     *
     * Helper function for store creation (only for use with
     * dbms_dbfs_sfs.dropFilesystem).
     *
     *
     * Remove a POSIX filesystem table from the list of known POSIX
     * filesystem tables.
     *
     * The table underlying the store must not be in use (i.e. all
     * filesystems referring to this table must have been unregistered
     * prior to this call).
     *
     */

    procedure   dropFilesystem(
        schema_name in              varchar2,
        tbl_name    in              varchar2);



    /*
     * Snapshot operations.
     *
     * Helper functions for snapshot operations meant to be invoked only
     * from "dbms_dbfs_sfs".
     *
     */

    procedure   createSnapshot(
        store_name  in              varchar2,
        snap_name   in              varchar2,
        vol_name    in              varchar2    default 'main');

    procedure   revertSnapshot(
        store_name  in              varchar2,
        snap_name   in              varchar2,
        vol_name    in              varchar2    default 'main');

    procedure   dropSnapshot(
        store_name  in              varchar2,
        snap_name   in              varchar2,
        vol_name    in              varchar2    default 'main');



    /*
     * Drop _all_ POSIX filesystem tables.
     *
     * Action to be invoked only during cleanup/downgrade.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   drop_all_tables;



    /*
     * Delete orphaned filesystem/table entries.
     *
     * Action to be invoked only during explicit and immediate cleanup
     * (for cases where the user does not want to wait for auto
     * cleanup).
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   delete_orphans;



    /*
     * Partition the SFS sequence# generator for distributed
     * multi-master environments.
     *
     *
     * The procedure partitions (by regenerating the sequence) for use
     * with "nodes" nodes/databases, where the current node/database has
     * an index of "myid" (in the range [0 .. nodes-1]).
     *
     *
     * A "newstart" value can be specified as the starting value for the
     * sequence and will be used as long as it is larger than the
     * current sequence value.
     *
     * The same value of "newstart" must be specified across the various
     * "nodes" to make sure that the sequence#s generated by each node
     * have no overlap.
     *
     * **NOTE**: do not invoke this procedure unless you know exactly
     * what you are doing.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   partition_sequence(
        nodes       in              number,
        myid        in              number,
        newstart    in              number      default null);



    /*
     * Adjust the SFS sequence# cache to allow for higher concurrency
     * and file ingest throughput.
     *
     *
     * The default cache size of "20" is increased to "8192" (or the
     * user-specified value).
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   recache_sequence(
        newcache    in              number      default 8192);



    /*
     * DBFS export/import procedural actions.
     *
     * For internal use only. See project-5464 for details.
     *
     */

    function    system_info_exp(
        prepost             in          pls_integer,
        connectstring       out nocopy  varchar2,
        version             in          varchar2,
        new_block           out         pls_integer)
            return  varchar2;

    function    schema_info_exp(
        schema              in          varchar2,
        prepost             in          pls_integer,
        isdba               in          pls_integer,
        version             in          varchar2,
        new_block           out         pls_integer)
            return  varchar2;

    function    instance_info_exp(
        name                in          varchar2,
        schema              in          varchar2,
        prepost             in          pls_integer,
        isdba               in          pls_integer,
        version             in          varchar2,
        new_block           out         pls_integer)
            return  varchar2;



    /*
     * DBFS export/import support.
     *
     * A one-time action to register the SFS entities with the
     * procedural action infrastructure.
     *
     * The registrations should normally have already occurred
     * implicitly during catalog initialization; however, invoking this
     * procedure (one or more times) explicitly is harmless.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   eximRegisterAll;



    /*
     * DBFS export/import support (helper functions).
     *
     * These functions are _strictly_ for internal use in the DBFS
     * export/import infrastructure. Do not even _think_ about using
     * them explicitly.
     *
     */

    procedure   exim_seq(
        newval              in          number);
    procedure   exim_tab(
        tabid               out         number,
        schema_name         in          varchar2,
        table_name          in          varchar2,
        ptable_name         in          varchar2,
        version#            in          varchar2,
        created             in          number,
        formatted           in          number);
    procedure   exim_tabp(
        tabid               in          number,
        propname            in          varchar2,
        propvalue           in          varchar2,
        typecode            in          number);
    procedure   exim_vol(
        tabid               in          number,
        volid               in          number,
        volname             in          varchar2,
        created             in          number,
        csnap#              in          number,
        dvolid              in          number,
        dsnap#              in          number,
        deleted             in          number);
    procedure   exim_snap(
        tabid               in          number,
        volid               in          number,
        snap#               in          varchar2,
        snapname            in          varchar2,
        created             in          number,
        deleted             in          number);
    procedure   exim_fs(
        tabid               in          number,
        store_owner         in          varchar2,
        store_name          in          varchar2,
        volid               in          number,
        snap#               in          varchar2,
        created             in          number);
    procedure   exim_grants(
        tabid               in          number);
    procedure   exim_attrv(
        tabid               in          number,
        attrv               in          varchar2,
        asof                in          number,
        vol#                in          number,
        goff                in          number);



end;
/
show errors;

create or replace public synonym dbms_dbfs_sfs_admin
    for sys.dbms_dbfs_sfs_admin;

grant execute on dbms_dbfs_sfs_admin
    to dbfs_role;



