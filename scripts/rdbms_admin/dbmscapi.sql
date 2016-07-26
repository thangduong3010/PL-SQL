Rem
Rem $Header: rdbms/admin/dbmscapi.sql /st_rdbms_11.2.0/7 2011/06/14 06:45:15 kkunchit Exp $
Rem
Rem dbmscapi.sql
Rem
Rem Copyright (c) 2008, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmscapi.sql - The DBFS API specification.
Rem
Rem    DESCRIPTION
Rem      The DBFS API specification.
Rem
Rem    NOTES
Rem      Specifications for the "dbms_dbfs_content",
Rem      "dbms_dbfs_content_admin", and "dbms_dbfs_content_spi" packages.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kkunchit    06/10/11 - Backport kkunchit_bug-12582607 from main
Rem    kkunchit    03/08/11 - Backport kkunchit_bug-10630023 from main
Rem    kkunchit    03/02/11 - Backport kkunchit_bug-10349967 from main
Rem    kkunchit    02/24/11 - Backport kkunchit_bug-11739080 from main
Rem    kkunchit    08/04/10 - Backport kkunchit_bug-9956078 from main
Rem    smuthuli    07/21/10 - Backport smuthuli_bug-9582487 from main
Rem    kkunchit    07/14/10 - Backport kkunchit_bug-9881611 from main
Rem    kkunchit    05/26/11 - bug-12568334: unified attribute views
Rem    kkunchit    05/23/11 - bug-12582607: recreate dbfs mounts
Rem    kkunchit    02/17/11 - bug-10349967: dbfs export/import support
Rem    kkunchit    02/10/11 - bug-11739080: expanded capi exceptions
Rem    kkunchit    01/04/11 - bug-10630023: split rename/move semantics
Rem    kkunchit    07/26/10 - bug-9956078: dbfs fastpath
Rem    kkunchit    07/09/10 - df improvements: bulk APIs
Rem    kkunchit    07/03/10 - bug-9881611: readdir enhancements
Rem    kkunchit    09/16/08 - Created
Rem



/* --------------------------- dbms_dbfs_content --------------------------- */
/*
 * A "DBFS Store" is a collection of entities, each identified by a unique
 * absolute "pathname" (i.e. a "/" followed by one or more "component names"
 * separated by "/"). Some stores may implement only a flat-namespace,
 * others might implement "directories" (or "folders") implicitly, while
 * still others may implement a comprehensive "filesystem" like collection
 * of entities: hierarchical directories, files, 'symbolic links" (or just
 * "links"), "hard links" (or "references"), etc. along with a rich set of
 * "metadata" (or "properties") associated with documents, and a rich set of
 * behaviors w.r.t. "security", "access control", "locking", "versioning",
 * "content addressing", "retention control", etc.
 *
 *
 * Since stores are typically designed and evolve independent of each other,
 * applications that use a specific store are either already written and
 * packaged by the store implementors, or else require the "client" (aka
 * "user") programmer to use a store-specific API (sometimes with intimate
 * knowledge of the schema of the database tables that are used to implement
 * the store itself).
 *
 *
 * The "DBFS API" is a client-side programmatic API (package
 * "dbms_dbfs_content") that attempts to: (a) abstract out the common
 * features of various stores into a (b) simple and minimalist interface
 * that can be used to build portable client applications while (c) being
 * insulated from store-specific libraries and implementation.
 *
 *
 * The DBFS API aggregates the path namespace of one or more stores into a
 * single unified namespace, using the first component of the pathname as a
 * disambiguator, and presents this namespace to client-applications.
 *
 * This allows clients to access the underlying documents using either a
 * full-absolute pathname (i.e. a single string):
 *
 *    "/<store-name>/<store-specific-pathname>"
 *
 * or a store-qualified pathname (i.e. a string 2-tuple):
 *
 *      ["<store-name>", "/<store-specific-pathname>"]
 *
 * The DBFS API then takes care of correctly dispatching various operations
 * on pathnames to the appropriate stores, and integrating the results back
 * into the client-desired namespace.
 *
 *
 * Store providers must conform to the SPI as declared by the package
 * "dbms_dbfs_content_spi"---the SPI is not a client-side API and serves as
 * a private contract between the implementation of the DBFS API and various
 * stores that wish to be pluggable into it.
 *
 *
 * The DBFS API defines client-visible behavior (normal and exceptional) of
 * various store operations, while allowing different stores to implement as
 * rich a set of features as they choose---the API allows stores to
 * self-describe their capabilities and allows intelligent client
 * applications to tune their behavior based on these capabilities (rather
 * than hard-code logic specific to stores identified by name or by
 * implementation).
 *
 */

create or replace package dbms_dbfs_content
    authid current_user
as



    /*
     * Pathname constants and types:
     *
     * PATH_MAX is the maximum length of an absolute pathname visible to
     * clients. NAME_MAX is the maximum length of any individual
     * component of an absolute pathname visible to clinets. These
     * constants are modeled after the POSIX counterparts.
     *
     * PL/SQL types "path_t" and "name_t" are portable aliases for
     * strings that can represent pathnames and component names, rspy.
     *
     */

    NAME_MAX                constant pls_integer    := 256;
    subtype name_t          is varchar2(256);                    /* NAME_MAX */

    PATH_MAX                constant pls_integer    := 1024;
    subtype path_t          is varchar2(1024);                   /* PATH_MAX */



    /*
     * ContentID constants and types:
     *
     * CONTENT_ID_MAX is the maximum length of a store-specific
     * provider-generated contentID that identifies a file-type item.
     *
     * PL/SQL type "content_id_t" is a portable aliases for raw buffers
     * that can represent contentID values.
     *
     */

    CONTENT_ID_MAX          constant pls_integer    := 128;
    subtype content_id_t    is raw(128);                   /* CONTENT_ID_MAX */



    /*
     * Path properties: generalized (name, value, typecode) tuples:
     *
     * Every pathname in a store is associated with a set of properties.
     * For simplicity and genericity, each property is identified by a
     * string "name", has a string "value" (possibly "null" if unset or
     * undefined or unsupported by a specific store implementation) and
     * a value "typecode" (a numeric discriminant for the actual type of
     * value held in the "value" string.
     *
     * Coercing property values to strings has the advantage of making
     * the various interfaces uniform and compact (and can even simplify
     * implementation of the underlying stores), but has the
     * disadvantage of the potential for information loss during
     * conversions to/from strings.
     *
     * It is expected that clients and stores use well-defined database
     * conventions for these conversions, and use the "typecode" field
     * (explained below) as appropriate.
     *
     *
     * PROPNAME_MAX is the maximum length of a property name, and
     * PROPVAL_MAX is the maximum length of the string value of a
     * property.
     *
     * PL/SQL types "propname_t" and "propval_t" are portable aliases
     * for strings that can represent property names and values, rspy.
     *
     *
     * A typecode is a numeric value (see the various constants defined
     * in "dbms_types") representing the true type of a string-coerced
     * property value. Not all typecodes defined in "dbms_types" are
     * necessarily even supportable in stores. Simple scalar types
     * (numbers, dates, timestamps, etc.) can be depended on by clients
     * and must be implemented by stores.
     *
     * Since standard RDBMS typecodes are positive integers, the DBFS
     * API allows negative integers to represent client-defined types by
     * negative typecodes. These typecodes do not conflict with standard
     * typecodes, and will be persisted and returned to the client as
     * needed, but need not be interpreted by the DBFS API or any
     * particular store. Portable client applications should not use
     * user-defined typecodes as a backdoor way of passing information
     * to specific stores.
     *
     */

    PROPNAME_MAX            constant pls_integer    := 32;
    subtype propname_t      is varchar2(32);                 /* PROPNAME_MAX */

    PROPVAL_MAX             constant pls_integer    := 1024;
    subtype propval_t       is varchar2(1024);                /* PROPVAL_MAX */



    /*
     * Pathname types:
     *
     * Stores can contain and provide access to 4 types of entities:
     *
     * type_file:
     *  A regular file storing data (a logically linear sequence of
     *  bytes accessing as a BLOB).
     *
     * type_directory:
     *  A container of other pathname types, including file types.
     *
     * type_link:
     *  A symbolic link (i.e. an uninterpreted string value associated
     *  with a pathname). Since symbolic links may represent pathnames
     *  that fall outside the scope of any given store (or even the
     *  entire aggregation of stores managed by the DBFS API), or may
     *  not even represent pathnames, clients must be careful in
     *  creating symbolic links, and stores must be careful in trying
     *  to resolve these links internally.
     *
     * type_reference:
     *  A hard link (i.e. an always valid pathname alias) to other
     *  paths.
     *
     *
     * Not all stores need to implement all of directories, links, or
     * references (see "features" below).
     *
     */

    type_file               constant pls_integer    := 1;     /* normal file */
    type_directory          constant pls_integer    := 2;       /* directory */
    type_link               constant pls_integer    := 3;   /* symbolic link */
    type_reference          constant pls_integer    := 4;       /* hard link */



    /*
     * Store features:
     *
     * In order to provide a common programmatic interface to as many
     * different types of stores as possible, the DBFS API leaves some
     * of the behavior of various operations to individual store
     * providers to define and implement.
     *
     * However, it is still important to provide client-side programmers
     * with an API that is sufficiently rich and conducive to portable
     * applications.
     *
     * The DBFS API achieves this by allowing different store providers
     * (and different stores) to describe themselves via a "feature set"
     * (a bitmask indicating which features they support and which ones
     * they do not).
     *
     * Using the feature set, it is possible, albeit tricky, for client
     * applications to compensate for the feature deficiences of
     * specific stores by implementing additional logic on the
     * client-side, and deferring complex operations to stores capable
     * of supporting them.
     *
     *
     * feature_folders:
     *  Set if the store supports folders (or directories) as part of
     *  hierarchical pathnames.
     *
     * feature_foiat:
     *  Set if implicit folder operations within the store (performed
     *  as part of a client-requested operation) runs inside autonomous
     *  transactions. In general, the use of autonomous transactions is
     *  a compromise between (a) simplicity in the implementation and
     *  client-controlled transaction scope for all operations, at the
     *  cost of greatly reduced concurrency (feature_foiat not set),
     *  vs. (b) more complex implementation and smaller
     *  client-controlled transaction scope, at the benefit of greatly
     *  increased concurrency (feature_foiat set).
     *
     *  Access to read-only (or read-mostly) stores should not be
     *  greatly affected by this feature.
     *
     * feature_nowait:
     *  Set if the store allows "nowait" gets of path elements. The
     *  default behavior is to wait for row locks; if "nowait" gets are
     *  implemented, the get operation raises an ORA-54 exception if
     *  the path element is already locked by another transaction.
     *
     *
     * feature_acls:
     *  Set if the store supports "access control lists" and internal
     *  authorization/checking based on these acls. Acls are standard
     *  properties (see below), but a store may do nothing more than
     *  store and retrieve the "acls" without interpreting them in any
     *  way.
     *
     *
     * feature_links, feature_link_deref:
     *  Set if the store supports symbolic links, and if certain types
     *  of symbolic links (specifically non-absolute pathnames) can be
     *  internally resolved by the store itself.
     *
     * feature_references:
     *  Set if the store supports hard links.
     *
     *
     * feature_locking:
     *  Set if the store supports user-level locks (read-only,
     *  write-only, read-write) that can be applied on various items of
     *  the store, and if the store uses these lock settings to control
     *  various types of accesses to the locked items. User-level locks
     *  are orthogonal to transaction locks and persist beyond the
     *  scope of any specific transaction, session, or
     *  connection---this implies that the store itself may not be able
     *  to clean up after dangling locks, and client-applications need
     *  to perform any garbage collection.
     *
     * feature_lock_hierarchy:
     *  Set if the store allows a user-lock to control access to the
     *  entire subtree under the locked pathname. A simpler locking
     *  model would have locking semantics apply only to a specific
     *  pathname, and depend on the locks placed on its parents or
     *  children (unless the requested operation would implicitly need
     *  to modify these parents or children).
     *
     * feature_lock_convert:
     *  Set if the store supports upgrade/downgrade of locks from one
     *  mode to another.
     *
     *
     * feature_versioning:
     *  Set if the store supports at least a linear versioning and
     *  version management. Different versions of the same pathname are
     *  idenfied by monotonic version numbers, with a
     *  version-nonqualified pathname representing the latest version.
     *
     * feature_version_path:
     *  Set if the store supports a hierarchical namespace for
     *  different versions of a pathname.
     *
     * feature_soft_deletes:
     *  Set if the store supports a "soft-delete", i.e. the ability to
     *  delete a pathname and make it invisible to normal operations,
     *  but retain the ability to restore the pathname later (as long
     *  as it has not been overwritten by a new create operation). The
     *  store also supports purging soft-deleted pathnames (making them
     *  truly deleted), and navigation modes that show soft-deleted
     *  items.
     *
     *
     * feature_hashing:
     *  Set if the store automatically computes and maintains some type
     *  of a secure hash of the contents of a pathname (typically a
     *  type_file path).
     *
     * feature_hash_lookup:
     *  Set if the store allows "content-based addressing", i.e. the
     *  ability to locate an item based, not on its pathname, but on
     *  its content hash.
     *
     *
     * feature_filtering:
     *  Set if the store allows clients to pass a filter function (a
     *  PL/SQL function conforming to the signature below) that returns
     *  a logical boolean indicating if a given store item satisfies a
     *  selection predicate. Stores that support filtering may be able
     *  to more efficiently perform item listing, directory navigation,
     *  and deletions by embedding the filtering logic inside their
     *  implementation. If filtering is not supported, clients can
     *  retrieve more items than necessary and perform the filtering
     *  checks themselves, albeit less efficiently.
     *
     * A filter predicate is a function with the following signature:
     *
     *  function filterFunction(
     *              path        in      varchar2,
     *              store_name  in      varchar2,
     *              opcode      in      integer,
     *              item_type   in      integer,
     *              properties  in      dbms_dbfs_content_properties_t,
     *              content     in      blob)
     *                  return  integer;
     *
     * Any PL/SQL function conforming to this signature can examine the
     * contents and properties of a store item, and decide if the item
     * satisfies the selection criterion for the current operation. A
     * "true" return value (i.e. non-zero) will result in the DBFS API
     * processing the item as part of the current operation; a "false"
     * return value (i.e. zero or null) will result in the item being
     * skipped entirely from processing.
     *
     * feature_searching:
     *  Set if the store allows clients to pass a text-search filter
     *  query to locate type_file pathnames based on their content.
     *  Stores that support searching may use indexes to accelerate
     *  such searches; otherwise, clients need to build their own
     *  indexes, or else search a potentially larger set of items to
     *  locate the ones of interest for the current search.
     *
     * feature_asof:
     *  Set if the store allows clients to use a "flashback" timestamp
     *  in query operations (non-mutating getPath, list, search).
     *
     * feature_provider_props:
     *  Set if the store allows per-operation properties (that control
     *  the behavior of the store w.r.t. the current operation, as
     *  opposed to properties associated with individual items).
     *
     * feature_snapshots:
     *  Set if the store allows the use of named, read-only snapshots
     *  of its contents. It is up to the provider to implement
     *  snapshots using any suitable means (including creating
     *  immediate copies of the content, or using copy-on-write) and
     *  managing dependencies between snapshots and its parent view.
     *
     * feature_dot_snapshot:
     *  Set if the store implicitly automounts and allows access to
     *  snapshots via a ".snapshots" (or similar) pseudo-directory,
     *  without the need to explicitly create a new store. Automounting
     *  snapshots can confuse various tools that depend on the
     *  uniqueness of pathname GUIDs within a filesystem.
     *
     * feature_clones:
     *  Set if the store allows the use of named, writeable clones of
     *  its contents. It is up to the provider to implement clones
     *  using any suitable means (including creating immediate copies
     *  of the content, or using copy-on-write) and managing
     *  dependencies between clones and its parent view.
     *
     * feature_locator:
     *  Set if the store allows direct access to file contents via a
     *  lob locator. Stores that internally manipulate the file
     *  contents, perhaps by shredding/reassembling them in separate
     *  pieces, performing other transformations, etc., cannot
     *  transparently give out a lob locator to clients. The file
     *  contents of these stores should be accessed using the
     *  buffer-based APIs.
     *
     * feature_content_id:
     *  Set if the store allows a "pathless", contentID-based access to
     *  files (there is no notion of a directory, link, or reference in
     *  this model).
     *
     * feature_lazy_path:
     *  Set if the store allows a "lazy" binding of a pathname to file
     *  elements that are otherwise identified by a contentID; this
     *  feature makes sense only in conjunction with
     *  "feature_content_id".
     *
     * feature_no_special:
     *  A mount-specific property that disables special pathname
     *  conventions w.r.t. the "@@" infix/suffix and the ".dbfs"
     *  component name (see "special pathname conventions" below).
     *
     * feature_getattr_view:
     *  Set if the provider can create and support a view conforming to
     *  the "dbms_fuse.dir_entry_t" schema and specialized for
     *  "dbms_fuse.fs_getattr()" lookups.
     *
     *
     */

    feature_folders         constant pls_integer    := 1;
    feature_foiat           constant pls_integer    := 2;
    feature_nowait          constant pls_integer    := 4;

    feature_acls            constant pls_integer    := 8;

    feature_links           constant pls_integer    := 16;
    feature_link_deref      constant pls_integer    := 32;
    feature_references      constant pls_integer    := 64;

    feature_locking         constant pls_integer    := 128;
    feature_lock_hierarchy  constant pls_integer    := 256;
    feature_lock_convert    constant pls_integer    := 512;

    feature_versioning      constant pls_integer    := 1024;
    feature_version_path    constant pls_integer    := 2048;
    feature_soft_deletes    constant pls_integer    := 4096;

    feature_hashing         constant pls_integer    := 8192;
    feature_hash_lookup     constant pls_integer    := 16384;

    feature_filtering       constant pls_integer    := 32768;
    feature_searching       constant pls_integer    := 65536;

    feature_asof            constant pls_integer    := 131072;
    feature_provider_props  constant pls_integer    := 262144;

    feature_snapshots       constant pls_integer    := 524288;
    feature_dot_snapshot    constant pls_integer    := 1048576;
    feature_clones          constant pls_integer    := 2097152;

    feature_locator         constant pls_integer    := 4194304;

    feature_content_id      constant pls_integer    := 8388608;
    feature_lazy_path       constant pls_integer    := 16777216;
    feature_no_special      constant pls_integer    := 33554432;
    feature_getattr_view    constant pls_integer    := 67108864;



    /*
     * Lock types:
     *
     * Stores that support locking should implement 3 types of locks:
     * lock_read_only, lock_write_only, and lock_read_write.
     *
     * User-locks (of one of these 3 types) can be associated with a
     * user-supplied "lock_data"---this is not interpreted by the store,
     * but can be used by client applications for their own purposes
     * (for example, the user-data could indicate the time at which the
     * lock was placed, assuming some part of the client application is
     * interested in later using this information to control its
     * actions, e.g. garbage collect stale locks or explicitly break
     * locks).
     *
     *
     * In the simplest locking model, a lock_read_only prevents all
     * explicit modifications to a pathname (but allows implicit
     * modifications, and changes to parent/child pathnames). A
     * lock_write_only prevents all explicit reads to the pathname (but
     * allows implicit reads, and reads to parent/child pathnames). A
     * lock_wread_write allows both
     *
     *
     * All locks are associated with a "principal" performing the
     * locking operation; stores that support locking are expected to
     * preserve this information, and use it to perform read/write lock
     * checking (see "opt_locker").
     *
     *
     * More complex lock models: multiple read-locks, lock-scoping
     * across pathname hierarchies, lock conversions, group-locking,
     * etc. are possible but currently not defined by the DBFS API.
     *
     */

    lock_read_only          constant pls_integer    := 1;
    lock_write_only         constant pls_integer    := 2;
    lock_read_write         constant pls_integer    := 3;



    /*
     * Standard properties:
     *
     * Standard properties are well-defined, mandatory properties
     * associated with all pathames that all stores should support (in
     * the manner described by the DBFS API), with some concessions
     * (e.g. a read-only store need not implement a "modification_time"
     * or "creation_time"; stores created against tables with a
     * fixed-schema may choose reasonable defaults for as many of these
     * properties as needed, etc.).
     *
     * All standard properties informally use the "std:" namespace.
     * Clients and stores should avoid using this namespace to define
     * their own properties since this can cause conflicts in future.
     *
     * The menu of standard properties is expected to be fairly stable
     * over time.
     *
     *
     * std_access_time (TYPECODE_TIMESTAMP in UTC):
     *  The time of last access of a pathname's contents.
     *
     * std_acl (TYPECODE_VARCHAR2):
     *  The access control list (in standard ACL syntax) associated
     *  with the pathname.
     *
     * std_canonical_path (TYPECODE_VARCHAR2):
     *  The canonical store-specific pathname of an item, suitably
     *  cleaned up (leading/trailing "/" collapsed/trimmed, etc.)
     *
     * std_change_time (TYPECODE_TIMESTAMP in UTC):
     *  The time of last change to the metadata of a pathname.
     *
     * std_children (TYPECODE_NUMBER):
     *  The number of child directories/folders a directory/folder path
     *  has (this property should be available in providers that
     *  support the "feature_folders" feature).
     *
     * std_content_type (TYPECODE_VARCHAR2):
     *  The client-supplied mime-type(s) (in standard RFC syntax)
     *  describing the (typically type_file) pathname. The content type
     *  is not necessarily interpreted by the store.
     *
     * std_creation_time (TYPECODE_TIMESTAMP in UTC):
     *  The time at which the item was created (once set, this value
     *  never changes for the lifetime of the pathname).
     *
     * std_deleted (TYPECODE_NUMBER as a boolean):
     *  Set to a non-zero number if the pathname has been
     *  "soft-deleted" (see above for this feature), but not yet
     *  purged.
     *
     * std_guid (TYPECODE_NUMBER):
     *  A store-specific unique identifier for a pathname. Clients must
     *  not depend on the GUID being unique across different stores,
     *  but a given (<store-name>, <store-specific-pathname>) has a
     *  stable and unique GUID for its lifetime.
     *
     * std_length (TYPECODE_NUMBER):
     *  The length of the content (BLOB) of a type_file/type_reference
     *  path, or the length of the referent of a type_link symbolic
     *  link. Directories do not have a well-defined length and stores
     *  are free to set this property to zero, null, or any other value
     *  they choose.
     *
     * std_modification_time (TYPECODE_TIMESTAMP in UTC):
     *  The time of last change to the data associated with a pathname.
     *  Changes to the content of a type_file/type_reference path, the
     *  referent of the type_link path, and addtion/deletion of
     *  immediate children in a type_directory path, all constitute
     *  data changes.
     *
     * std_owner (TYPECODE_VARCHAR2):
     *  A client-supplied (or implicit) owner name for the pathname.
     *  The owner name may be used (along with the current "principal")
     *  for access checks by stores that support ACLs and/or locking.
     *
     * std_parent_guid (TYPECODE_NUMBER):
     *  A store-specific unique identifier for the parent of a
     *  pathname. Clients must not depend on the GUID being unique
     *  across different stores, but a given (<store-name>,
     *  <store-specific-pathname>) has a stable and unique GUID for its
     *  lifetime.
     *
     *  std_parent_guid(pathname) == std_guid(parent(pathname))
     *
     * std_referent (TYPECODE_VARCHAR2):
     *  The content of the symbolic link of a type_link path; null
     *  otherwise. As mentioned before, the std_referent can be an
     *  arbitrary string and must not necessarily be interpreted as
     *  pathname by clients (or such interpretation should be done with
     *  great care).
     *
     */

    std_access_time         constant varchar2(32)   := 'std:access_time';
    std_acl                 constant varchar2(32)   := 'std:acl';
    std_canonical_path      constant varchar2(32)   := 'std:canonical_path';
    std_change_time         constant varchar2(32)   := 'std:change_time';
    std_children            constant varchar2(32)   := 'std:children';
    std_content_type        constant varchar2(32)   := 'std:content_type';
    std_creation_time       constant varchar2(32)   := 'std:creation_time';
    std_deleted             constant varchar2(32)   := 'std:deleted';
    std_guid                constant varchar2(32)   := 'std:guid';
    std_length              constant varchar2(32)   := 'std:length';
    std_modification_time   constant varchar2(32)   := 'std:modification_time';
    std_owner               constant varchar2(32)   := 'std:owner';
    std_parent_guid         constant varchar2(32)   := 'std:parent_guid';
    std_referent            constant varchar2(32)   := 'std:referent';



    /*
     * Optional properties:
     *
     * Optional properties are well-defined but non-mandatory properties
     * associated with all pathames that all stores are free to support
     * (but only in the manner described by the DBFS API). Clients
     * should be prepared to deal with stores that support none of the
     * optional properties.
     *
     * All optional properties informally use the "opt:" namespace.
     * Clients and stores should avoid using this namespace to define
     * their own properties since this can cause conflicts in future.
     *
     * The menu of optional properties is expected to be expand over
     * time.
     *
     *
     * opt_hash_type (TYPECODE_NUMBER):
     *  The type of hash provided in the "opt_hash_value" property; see
     *  "dbms_crypto" for possible options.
     *
     * opt_hash_value (TYPECODE_RAW):
     *  The hash value of type "opt_hash_type" describing the content
     *  of the pathname.
     *
     *
     * opt_lock_count (TYPECODE_NUMBER):
     *  The number of (compatible) locks placed on a pathname. If
     *  different principals are allowed to place compatible (read)
     *  locks on a path, the "opt_locker" must specify all lockers
     *  (with repeats so that lock counts can be correctly maintained).
     *
     * opt_lock_data (TYPECODE_VARCHAR2):
     *  The client-supplied user-data associated with a user-lock,
     *  uninterpreted by the store.
     *
     * opt_locker (TYPECODE_VARCHAR2):
     *  The implicit or client-specified principal(s) that applied a
     *  user-lock on a pathname.
     *
     * opt_lock_status (TYPECODE_NUMBER):
     *  One of the "lock_read_only", "lock_write_only",
     *  "lock_read_write" values describing the type of lock currently
     *  applied on a pathname.
     *
     *
     * opt_version (TYPECODE_NUMBER):
     *  A sequence number for linear versioning of a pathname.
     *
     * opt_version_path (TYPECODE_VARCHAR2):
     *  A version-pathname for hierarchical versioning of a pathname.
     *
     * opt_content_id (TYPECODE_RAW):
     *  A stringified provider-generated store-specific unique
     *  contentID for a file element (that may optionally not be
     *  associated with a path; see "feature_content_id" and
     *  "feature_lazy_path").
     *
     */

    opt_hash_type           constant varchar2(32)   := 'opt:hash_type';
    opt_hash_value          constant varchar2(32)   := 'opt:hash_value';
    opt_lock_count          constant varchar2(32)   := 'opt:lock_count';
    opt_lock_data           constant varchar2(32)   := 'opt:lock_data';
    opt_locker              constant varchar2(32)   := 'opt:locker';
    opt_lock_status         constant varchar2(32)   := 'opt:lock_status';
    opt_version             constant varchar2(32)   := 'opt:version';
    opt_version_path        constant varchar2(32)   := 'opt:version_path';
    opt_content_id          constant varchar2(32)   := 'opt:content_id';



    /*
     * Property access flags:
     *
     * DBFS API methods to get/set properties can use combinations of
     * property access flags to fetch properties from different
     * namespaces in a single API call.
     *
     *
     * prop_none:
     *  Used when the client is not interested in any properties, and
     *  is invoking the content access method for other reasons
     *  (pathname existence/lockability validation, data access, etc.)
     *
     * prop_std:
     *  Used when the client is interested in the standard properties;
     *  all standard properties are retrieved if this flag is
     *  specified.
     *
     * prop_opt:
     *  Used when the client is interested in the optional properties;
     *  all optional properties are retrieved if this flag is
     *  specified.
     *
     * prop_usr:
     *  Used when the client is interested in the user-defined
     *  properties; all user-defined properties are retrieved if this
     *  flag is specified.
     *
     * prop_all:
     *  An alias for the combination of all standard, optional, and
     *  user-defined properties.
     *
     * prop_data:
     *  Used when the client is interested only in data access, and
     *  does not care about properties.
     *
     * prop_spc:
     *  Used when the client is interested in a mix-and-match of
     *  different subsets of various property namespaces; the names of
     *  the specific properties to fetch are passed into the DBFS API
     *  method call as arguments, and only these property values are
     *  fetched and returned to the client. This is useful in cases
     *  where there are a very large number of properties potentially
     *  accessible, but the client is interested in only a small number
     *  of them (and knows the names of these "interesting" properties
     *  beforehand).
     *
     *  "prop_spc" is applicable only to the various "getPath"
     *  operations. Other operations that specify properties will
     *  simply ignore "prop_spc" specifications.
     *
     */

    prop_none               constant pls_integer    :=  0;           /* none */
    prop_std                constant pls_integer    :=  1;      /* mandatory */
    prop_opt                constant pls_integer    :=  2;       /* optional */
    prop_usr                constant pls_integer    :=  4;   /* user-defined */
    prop_all                constant pls_integer    := prop_std +
                                                       prop_opt +
                                                       prop_usr;      /* all */
    prop_data               constant pls_integer    :=  8;        /* content */
    prop_spc                constant pls_integer    := 16;       /* specific */



    /*
     * Exceptions:
     *
     * DBFS API operations can raise any one of the following top-level
     * exceptions.
     *
     * Clients can program against these specific exceptions in their
     * error handlers without worrying about the specific store
     * implementations of the underlying error signally code.
     *
     * Store providers, for their part, should do their best to
     * trap/wrap any internal exceptions into one of the following
     * exception types, as appropriate.
     *
     */

    /* a specified pathname, e.g. create, already exists */
    path_exists             exception;
        pragma  exception_init(path_exists,
                               -64000);

    /* the parent of a specified pathname does not exist */
    invalid_parent          exception;
        pragma  exception_init(invalid_parent,
                               -64001);

    /* the specified pathname does not exist, or is not valid */
    invalid_path            exception;
        pragma  exception_init(invalid_path,
                               -64002);

    /* an operation unsupported by a store was invoked */
    unsupported_operation   exception;
        pragma  exception_init(unsupported_operation,
                               -64003);

    /* an operation was invoked with invalid arguments */
    invalid_arguments       exception;
        pragma  exception_init(invalid_arguments,
                               -64004);

    /* access control checks failed for the current operation */
    invalid_access          exception;
        pragma  exception_init(invalid_access,
                               -64005);

    /* the current operation failed lock conflict checks */
    lock_conflict           exception;
        pragma  exception_init(lock_conflict,
                               -64006);

    /* an invalid store name was specified */
    invalid_store           exception;
        pragma  exception_init(invalid_store,
                               -64007);

    /* an invalid mount-point was specified */
    invalid_mount           exception;
        pragma  exception_init(invalid_mount,
                               -64008);

    /* an invalid provider-package was specified */
    invalid_provider        exception;
        pragma  exception_init(invalid_provider,
                               -64009);

    /* a mutating operation was invoked on a read-only mount/store */
    readonly_path           exception;
        pragma  exception_init(readonly_path,
                               -64010);

    /* an operation spanning 2 or more distinct stores was invoked */
    cross_store_operation   exception;
        pragma  exception_init(cross_store_operation,
                               -64011);

    /* specified path is a directory */
    path_is_directory       exception;
        pragma  exception_init(path_is_directory,
                               -64012);

    /* specified path is not a directory */
    path_not_directory      exception;
        pragma  exception_init(path_not_directory,
                               -64013);

    /* specified directory is not empty */
    directory_not_empty     exception;
        pragma  exception_init(directory_not_empty,
                               -64014);



    /*
     * Property bundles:
     *
     * The "property_t" record type describes a single (value, typecode)
     * property value tuple; the property name is implied (see
     * "properties_t" below).
     *
     * "properties_t" is a name-indexed hash table of property tuples.
     * The implicit hash-table association between the index and the
     * value allows the client to build up the full
     * "dbms_dbfs_content_property_t" tuples for a "properties_t".
     *
     *
     * There is an approximate correspondence between
     * "dbms_dbfs_content_property_t" and "property_t"---the former is a
     * SQL object type that describes the full property tuple, while the
     * latter is a PL/SQL record type that describes only the property
     * value component.
     *
     * Likewise, there is an approximate correspondence between
     * "dbms_dbfs_content_properties_t" and "properties_t"---the former
     * is a SQL nested table type, while the latter is a PL/SQL hash
     * table type.
     *
     *
     * Dynamic SQL calling conventions force the use of SQL types, but
     * PL/SQL code may be implemented more conveniently in terms of the
     * hash-table types.
     *
     * The DBFS API provides convenient utility functions to convert
     * between "dbms_dbfs_content_properties_t" and "properties_t" (see
     * "propertiesT2H" and "propertiesH2T" below).
     *
     */

    type property_t  is record (
        propvalue   propval_t,
        typecode    integer
    );
    type properties_t is table of property_t
        index by propname_t;

    /* properties table to hash */
    /* convert a dbms_dbfs_content_properties_t to a property_t */
    function    propertiesT2H(
        sprops              in      dbms_dbfs_content_properties_t)
            return  properties_t;

    /* properties hash to table */
    /* convert a properties_t into a dbms_dbfs_content_properties_t */
    function    propertiesH2T(
        pprops              in      properties_t)
            return  dbms_dbfs_content_properties_t;



    /*
     * Simple property constructors.
     *
     */

    function    propAny(
        val                 in      number)
            return  property_t;
    function    propAny(
        val                 in      varchar2)
            return  property_t;
    function    propAny(
        val                 in      timestamp)
            return  property_t;
    function    propAny(
        val                 in      raw)
            return  property_t;

    function    propNumber(
        val                 in      number)
            return  property_t;
    function    propVarchar2(
        val                 in      varchar2)
            return  property_t;
    function    propTimestamp(
        val                 in      timestamp)
            return  property_t;
    function    propRaw(
        val                 in      raw)
            return  property_t;



    /*
     * Store descriptors:
     *
     * A "store_t" is a record that describes a store registered with
     * and managed by the DBFS API (see the Administrative APIs below).
     *
     * A "mount_t" is a record that describes a store mount point and
     * its properties.
     *
     * Clients can query the DBFS API for the list of available stores,
     * determine which store will handle accesses to a given pathname,
     * and determine the feature set for the store.
     *
     */

    type store_t    is record (
        store_name          varchar2(32),
        store_id            number,
        provider_name       varchar2(32),
        provider_pkg        varchar2(32),
        provider_id         number,
        provider_version    varchar2(32),
        created             timestamp,
        store_features      integer,
        store_guid          number
    );
    type stores_t is table of store_t;


    type mount_t    is record (
        store_name          varchar2(32),
        store_id            number,
        provider_name       varchar2(32),
        provider_pkg        varchar2(32),
        provider_id         number,
        provider_version    varchar2(32),
        store_features      integer,
        store_guid          number,
        store_mount         name_t,
        created             timestamp,
        mount_properties    dbms_dbfs_content_properties_t
    );
    type mounts_t is table of mount_t;



    /*
     * Administrative and query APIs:
     *
     * (Administrative) clients and store providers are expected to
     * register stores with the DBFS API. Additionally, administrative
     * clients are expected to mount stores into the toplevel namespace
     * of their choice.
     *
     * The registration/unregistration of a store is separated from the
     * mount/unmount of a store since it is possible for the same store
     * to be mounted multiple times at different mount-points (and this
     * is under client control).
     *
     *
     * The administrative methods in "dbms_dbfs_content" are merely
     * wrappers that delegate to the matching methods in
     * "dbms_dbfs_content_admin". Clients can use the methods in either
     * package to perform administrative operations.
     *
     */



    /*
     * Register a new store "store_name" backed by provider
     * "provider_name" that uses "provider_package" as the store
     * provider (conforming to the "dbms_dbfs_content_spi" package
     * signature).
     *
     * This method is to be used primarily by store providers after they
     * have created a new store.
     *
     * Store names must be unique.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   registerStore(
        store_name          in      varchar2,
        provider_name       in      varchar2,
        provider_package    in      varchar2);


    /*
     * Unregister a previously registered store (invalidating all
     * mount-points associated with it).
     *
     * Once unregistered all access to the store (and its mount-points)
     * are not guaranteed to work (although CR may provide a temporary
     * illusion of continued access).
     *
     *
     * If the "ignore_unknown" argument is "true", attempts to
     * unregister unknown stores will not raise an exception.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   unregisterStore(
        store_name          in      varchar2,
        ignore_unknown      in      boolean         default false);


    /*
     * Mount a registered store "store_name" and bind it to the
     * "store_mount" mount-point.
     *
     * Once mounted, accesses to pathnames of the form
     * "/<store_mount>/xyz..." will be redirected to <store_name> and
     * its store provider.
     *
     *
     * Store mount-points must be unique, and a syntactically valid
     * pathname component (i.e. a "name_t" with no embedded "/").
     *
     *
     * If a mount-point is not specified (i.e. is null), the DBFS API
     * attempts to use the store name itself as the mount-point name
     * (subject to the uniqueness and syntactic constraints).
     *
     *
     * A special empty mount-point is available for singleton stores,
     * i.e. a scenario where the DBFS API manages a single backend
     * store---in such cases, the client can directly deal with full
     * pathnames of the form "/xyz..." since there is no ambiguity in
     * how to redirect these accesses.
     *
     * Singleton mount-points are indicated by the "singleton" boolean
     * argument, and the "store_mount" argument is ignored.
     *
     *
     * The same store can be mounted multiple times, obviously at
     * different mount-points.
     *
     *
     * Mount properties can be used to specify the DBFS API execution
     * environment, i.e. default values of the principal, owner, acl,
     * and asof for a particular mount-point. Mount properties can also
     * be used to specify a read-only mount. If a flashback mount is
     * specified (via "asof"), it implies a read-only mount.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   mountStore(
        store_name          in      varchar2,
        store_mount         in      varchar2        default null,
        singleton           in      boolean         default false,
        principal           in      varchar2        default null,
        owner               in      varchar2        default null,
        acl                 in      varchar2        default null,
        asof                in      timestamp       default null,
        read_only           in      boolean         default false);


    /*
     * Remount a previously mounted store, either by name or by mount
     * point, or remount all known mounts.
     *
     *
     * A remount of an existing mount-point preserves the properties of
     * the underlying store/mount, but re-executes the implicit
     * side-effect actions of dropping and creating the mount.
     *
     * An example of such a side-effect is the recreation of attribute
     * views.
     *
     *
     * Remounting a store by name (i.e. "store_name" is not null,
     * "store_mount" is null) will remount all mount-points associated
     * with the store.
     *
     * Remounting a store by mount point (i.e. "store_mount" is not
     * null) will remount only the specified mount---the "store_name"
     * can be specified as "null". If "store_name" is also specified, it
     * is used for validation (i.e. an invalid store_name/store_mount
     * combination will fail).
     *
     * Singleton mounts can be remounted by specifying either the
     * store_name (first option above), or by specifying both
     * "store_name" and "store_mount" as null.
     *
     *
     * If the "ignore_unknown" argument is "true", attempts to remount
     * unknown or invalid combinations of stores/mounts will not raise
     * an exception.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   remountStore(
        store_name          in      varchar2        default null,
        store_mount         in      varchar2        default null,
        ignore_unknown      in      boolean         default false);

    procedure   remountAll;


    /*
     * Unmount a previously mounted store, either by name or by mount
     * point, or unmount all known mounts.
     *
     *
     * Unmounting a store by name (i.e. "store_name" is not null,
     * "store_mount" is null) will unmount all mount-points associated
     * with the store.
     *
     * Unmounting a store by mount point (i.e. "store_mount" is not
     * null) will unmount only the specified mount---the "store_name"
     * can be specified as "null". If "store_name" is also specified, it
     * is used for validation (i.e. an invalid store_name/store_mount
     * combination will fail).
     *
     * Singleton mounts can be unmounted by specifying either the
     * store_name (first option above), or by specifying both
     * "store_name" and "store_mount" as null.
     *
     * Once unmounted all access to the store (or mount-point) are not
     * guaranteed to work (although CR may provide a temporary illusion
     * of continued access).
     *
     *
     * If the "ignore_unknown" argument is "true", attempts to unmount
     * unknown or invalid combinations of stores/mounts will not raise
     * an exception.
     *
     *
     * The procedure executes like a DDL (i.e. auto-commits before and
     * after its execution).
     *
     */

    procedure   unmountStore(
        store_name          in      varchar2        default null,
        store_mount         in      varchar2        default null,
        ignore_unknown      in      boolean         default false);

    procedure   unmountAll;


    /*
     * List all available stores and their features.
     *
     * The "store_mount" field of the returned records is set to "null"
     * (since mount-points are separate from stores themselves).
     *
     */

    function    listStores
            return  stores_t
                pipelined;


    /*
     * List all available mount-points, their backing stores, and the
     * store features.
     *
     * A singleton mount results in a single returned row, with its
     * "store_mount" field set to "null".
     *
     */

    function    listMounts
            return  mounts_t
                pipelined;


    /*
     * Lookup specific stores and their features by: pathname, store
     * name, or mount-point.
     *
     */

    type feature_t is record (
        feature_name    varchar2(32),
        feature_mask    integer,
        feature_state   varchar2(3)
    );
    type features_t is table of feature_t;

    function    getStoreByPath(
        path                in      path_t)
            return  store_t;

    function    getStoreByName(
        store_name          in      varchar2)
            return  store_t;

    function    getStoreByMount(
        store_mount         in      varchar2)
            return  store_t;

    function    getFeaturesByPath(
        path                in      path_t)
            return  integer;

    function    getFeaturesByName(
        store_name          in      varchar2)
            return  integer;

    function    getFeaturesByMount(
        store_mount         in      varchar2)
            return  integer;

    function    decodeFeatures(
        featureSet          in      integer)
            return  features_t
                deterministic
                pipelined;

    function    featureName(
        featureBit          in      integer)
            return  varchar2
                deterministic;



    /*
     * Lookup pathnames by (store_name, std_guid) or (store_mount,
     * std_guid) tuples.
     *
     * If the underlying "std_guid" is found in the underlying store,
     * these functions return the store-qualified pathname, or the full
     * absolute pathname, rspy.
     *
     * If the "std_guid" is unknown, a "null" value is returned. Clients
     * are expected to handle this as appropriate.
     *
     */

    function    getPathByStoreId(
        store_name          in      varchar2,
        guid                in      integer)
            return  varchar2;

    function    getPathByMountId(
        store_mount         in      varchar2,
        guid                in      integer)
            return  varchar2;



    /*
     * DBFS API: space usage.
     *
     * Clients can query filesystem space usage statistics via the
     * "spaceUsage()" method. Store providers, in turn, are expected to
     * support at least the equivalent "spaceUsage()" method for their
     * stores (and to make a best effort determination of space
     * usage---esp. if the store consists of multiple
     * tables/indexes/lobs, etc. scattered across multiple
     * tablespaces/datafiles/disk-groups, etc.).
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
     * A space usage query on the toplevel root directory will return a
     * combined summary of the space usage of all available distinct
     * stores under it (if the same store is mounted multiple times, it
     * will still be counted only once).
     *
     *
     * If "useEstimate" is specified, providers capable of computing
     * fast-but-approximate space usage information can make use of this
     * optimization. Otherwise, the default space usage computation will
     * be used.
     *
     */

    procedure   spaceUsage(
        path        in              varchar2,
        blksize     out             integer,
        tbytes      out             integer,
        fbytes      out             integer,
        nfile       out             integer,
        ndir        out             integer,
        nlink       out             integer,
        nref        out             integer,
        store_name  in              varchar2    default null,
        useEstimate in              boolean     default false);



    /*
     * DBFS API session defaults.
     *
     * Normal client access to the DBFS API executes with an implicit
     * context that consists of:
     *
     *  -> the "principal" invoking the current operation,
     *
     *  -> the "owner" for all new elements created (implicitly or
     *  explicitly) by the current operation,
     *
     *  -> the "acl" for all new elements created (implicitly or
     *  explicitly) by the current operation,
     *
     *  and
     *
     *  -> the "asof" timestamp at which the underlying read-only
     *  operation (or its read-only sub-components) execute.
     *
     *
     * All of this information can be passed in explicitly via arguments
     * to the various DBFS API method calls, allowing the client
     * fine-grained control over individual operations.
     *
     * The DBFS API also allows clients to set session-duration defaults
     * for the context that is automatically inherited by all operations
     * for which the defaults are not explicitly overridden.
     *
     *
     * All of the context defaults start out as "null", and can be
     * cleared by setting them to "null".
     *
     */

    procedure   setDefaultContext(
        principal   in              varchar2,
        owner       in              varchar2,
        acl         in              varchar2,
        asof        in              timestamp);
    procedure   setDefaultPrincipal(
        principal   in              varchar2);
    procedure   setDefaultOwner(
        owner       in              varchar2);
    procedure   setDefaultACL(
        acl         in              varchar2);
    procedure   setDefaultAsOf(
        asof        in              timestamp);

    procedure   getDefaultContext(
        principal   out nocopy      varchar2,
        owner       out nocopy      varchar2,
        acl         out nocopy      varchar2,
        asof        out             timestamp);
    function    getDefaultPrincipal
        return  varchar2;
    function    getDefaultOwner
        return  varchar2;
    function    getDefaultACL
        return  varchar2;
    function    getDefaultAsOf
        return  timestamp;



    /*
     * DBFS API: interface versioning.
     *
     * To allow for the DBFS API itself to evolve, an internal API
     * version will count up with each change to the public API.
     *
     * A standard naming convention will be followed in the version
     * string: <a.b.c> corresponding to <major>, <minor>, and <patch>
     * components.
     *
     */

    function    getVersion
        return  varchar2;



    /*
     * DBFS API: notes on pathnames.
     *
     * Clients of the DBFS API refer to store items via absolute
     * pathnames (but see the special exemptions for contentID-based
     * access below).
     *
     * These pathnames can be "full", i.e. a single string of the form
     * "/mount-point/pathname", or store-qualified, i.e. a 2-tuple of
     * the form (store_name, pathname) (where the pathname is rooted
     * within the store namespace).
     *
     * Clients may use either naming scheme as it suits them, and can
     * mix-and-match the naming within their programs.
     *
     * If pathnames are returned by DBFS API calls, the exact values
     * being returned depend on the naming scheme used by the client in
     * the call---for example, a listing or search on a full-absolute
     * directory name returns items with their full-absolute pathnames,
     * while a listing or search on a store-qualified directory name
     * returns items whose pathnames are store-specific (i.e. the
     * store-qualification is implied).
     *
     * The implementation of the DBFS API internally manages the
     * normalization and inter-conversion between these 2 naming
     * schemes.
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
     * DBFS API: special pathname conventions.
     *
     * The DBFS, by default, reserves the path component name ".dbfs"
     * and the "@@" infix/suffix sequence for special semantics.
     *
     *
     * The "@@" sequence is used to access extended attributes via
     * special pathnames. For example, if a pathname element "/a/b/c/d"
     * has extended attributes "a1" and "a2" with values "v1" and "v2",
     * the following pathnames will have special meaning:
     *
     *
     *  /a/b/c/d            the original pathname
     *  /a/b/c/d@@          a pseudo-directory containing "a1" and "a2"
     *  /a/b/c/d@@a1        a pseudo-file containing "v1"
     *  /a/b/c/d@@a2        a pseudo-file containing "v2"
     *
     * Client applications can use these pathnames, especially the last
     * 3 pathnames as if they were real pathnames, and seamlessly get
     * access to extended attributes using the same access methods that
     * would be used for normal directories and files.
     *
     * However, this implies that the "@@" sequence cannot occur as a
     * suffix (conflicts with the attribute pseudo-directory) or as an
     * infix (conflicts with attribute pseudo-files).
     *
     * The "@@" special pathnames do not show up in normal directory
     * listings; they need to be explicitly specified by the client.
     *
     * Creation, deletion, modification operations are allowed on the
     * "@@" infix qualified pathnames---these are internally implemented
     * as the creation, deletion, and modification of user-defined
     * attributes of the element. The "@@" qualified pathnames cannot be
     * renamed or otherwise manipulated.
     *
     *
     * Additionally, the ".dbfs" component name is reserved for future
     * use by the DBFS API, and is currently not allowed inside any
     * user-supplied pathname.
     *
     *
     * By default, the DBFS API will enforce the above constraints and
     * special semantics on pathnames. These constraints and special
     * semantics can be disabled via the mount-specific
     * "feature_no_special"; mounts created with this feature will not
     * enforce any special constraints or semantics on pathnames, and
     * will simply pass through the user-supplied pathnames,
     * uninterpreted, to the underlying store providers.
     *
     */



    /*
     * DBFS API: creation operations
     *
     * The DBFS API allows clients to create directory, file, link, and
     * reference elements (subject to store feature support).
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
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     in out nocopy   blob,
        prop_flags  in              integer     default (prop_std +
                                                         prop_data),
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   createFile(
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        content     in out nocopy   blob,
        prop_flags  in              integer     default (prop_std +
                                                         prop_data),
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   createLink(
        srcPath     in              varchar2,
        dstPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        prop_flags  in              integer     default prop_std,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   createLink(
        srcPath     in              varchar2,
        dstPath     in              varchar2,
        properties  in out nocopy   properties_t,
        prop_flags  in              integer     default prop_std,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   createReference(
        srcPath     in              varchar2,
        dstPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        prop_flags  in              integer     default prop_std,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   createReference(
        srcPath     in              varchar2,
        dstPath     in              varchar2,
        properties  in out nocopy   properties_t,
        prop_flags  in              integer     default prop_std,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   createDirectory(
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        prop_flags  in              integer     default prop_std,
        recurse     in              boolean     default false,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   createDirectory(
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        prop_flags  in              integer     default prop_std,
        recurse     in              boolean     default false,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);



    /*
     * DBFS API: deletion operations
     *
     * The DBFS API allows clients to delete directory, file, link, and
     * reference elements (subject to store feature support).
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
        path        in              varchar2,
        filter      in              varchar2    default null,
        soft_delete in              boolean     default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   deleteContent(
        store_name  in              varchar2,
        contentID   in              raw,
        filter      in              varchar2    default null,
        soft_delete in              boolean     default null,
        principal   in              varchar2    default null);

    procedure   deleteDirectory(
        path        in              varchar2,
        filter      in              varchar2    default null,
        soft_delete in              boolean     default null,
        recurse     in              boolean     default false,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   restorePath(
        path        in              varchar2,
        filter      in              varchar2    default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   purgePath(
        path        in              varchar2,
        filter      in              varchar2    default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   restoreAll(
        path        in              varchar2,
        filter      in              varchar2    default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   purgeAll(
        path        in              varchar2,
        filter      in              varchar2    default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);



    /*
     * DBFS API: path get/put operations.
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
     * pathnames can be implicitly and internally deferenced by stores
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
     * The DBFS API does not have an explicit copy operation since a
     * copy is easily implemented as a combination of a "getPath"
     * followed by a "createXXX" with appropriate data/metadata transfer
     * across the calls. This allows copies _across_ stores (while an
     * internalized copy operation cannot provide this facility).
     *
     *
     * "getPathNowait" implies a "forUpdate", and, if implemented (see
     * "feature_nowait"), allows providers to return an exception
     * (ORA-54) rather than wait for row locks.
     *
     */

    procedure   getPath(
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     out    nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt +
                                                         prop_data),
        asof        in              timestamp   default null,
        forUpdate   in              boolean     default false,
        deref       in              boolean     default false,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   getPath(
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        content     out    nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt +
                                                         prop_data),
        asof        in              timestamp   default null,
        forUpdate   in              boolean     default false,
        deref       in              boolean     default false,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   getPathNowait(
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     out    nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt +
                                                         prop_data),
        deref       in              boolean     default false,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   getPathNowait(
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        content     out    nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt +
                                                         prop_data),
        deref       in              boolean     default false,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   getPath(
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        amount      in out          number,
        offset      in              number,
        buffer      out    nocopy   raw,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt),
        asof        in              timestamp   default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   getPath(
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        amount      in out          number,
        offset      in              number,
        buffer      out    nocopy   raw,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt),
        asof        in              timestamp   default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   getPath(
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        amount      in out          number,
        offset      in              number,
        buffers     out    nocopy   dbms_dbfs_content_raw_t,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt),
        asof        in              timestamp   default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   getPath(
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        amount      in out          number,
        offset      in              number,
        buffers     out    nocopy   dbms_dbfs_content_raw_t,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt),
        asof        in              timestamp   default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   putPath(
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        content     in out nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt +
                                                         prop_data),
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   putPath(
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        content     in out nocopy   blob,
        item_type   out             integer,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt +
                                                         prop_data),
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   putPath(
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        amount      in              number,
        offset      in              number,
        buffer      in              raw,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt),
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   putPath(
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        amount      in              number,
        offset      in              number,
        buffer      in              raw,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt),
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   putPath(
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        written     out             number,
        offset      in              number,
        buffers     in              dbms_dbfs_content_raw_t,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt),
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   putPath(
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        written     out             number,
        offset      in              number,
        buffers     in              dbms_dbfs_content_raw_t,
        prop_flags  in              integer     default (prop_std +
                                                         prop_opt),
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);



    /*
     * DBFS API: rename/move operations.
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
        oldPath     in              varchar2,
        newPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   renamePath(
        oldPath     in              varchar2,
        newPath     in              varchar2,
        properties  in out nocopy   properties_t,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   movePath(
        oldPath     in              varchar2,
        newPath     in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   movePath(
        oldPath     in              varchar2,
        newPath     in              varchar2,
        properties  in out nocopy   properties_t,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   setPath(
        store_name  in              varchar2,
        contentID   in              raw,
        path        in              varchar2,
        properties  in out nocopy   dbms_dbfs_content_properties_t,
        principal   in              varchar2    default null);

    procedure   setPath(
        store_name  in              varchar2,
        contentID   in              raw,
        path        in              varchar2,
        properties  in out nocopy   properties_t,
        principal   in              varchar2    default null);



    /*
     * Directory listings.
     *
     * A "path_item_t" is a tuple describing a (store, mount) qualified
     * path in a store, with all standard and optional properties
     * associated with it.
     *
     * A "prop_item_t" is a tuple describing a (store, mount) qualified
     * path in a store, with all user-defined properties associated with
     * it, expanded out into individual (name, value, type) tuples.
     *
     */

    type path_item_t is record (
        store              name_t,
        mount                   name_t,
        pathname                path_t,
        pathtype                varchar2(32),
        filedata                blob,
        std_access_time         timestamp,
        std_acl                 varchar2(1024),
        std_change_time         timestamp,
        std_children            number,
        std_content_type        varchar2(1024),
        std_creation_time       timestamp,
        std_deleted             integer,
        std_guid                integer,
        std_modification_time   timestamp,
        std_owner               varchar2(32),
        std_parent_guid         integer,
        std_referent            varchar2(1024),
        opt_hash_type           varchar2(32),
        opt_hash_value          varchar2(128),
        opt_lock_count          integer,
        opt_lock_data           varchar2(128),
        opt_locker              varchar2(128),
        opt_lock_status         integer,
        opt_version             integer,
        opt_version_path        path_t,
        opt_content_id          content_id_t
    );
    type path_items_t is table of path_item_t;

    type prop_item_t is record (
        store              name_t,
        mount                   name_t,
        pathname                path_t,
        property_name           propname_t,
        property_value          propval_t,
        property_type           integer
    );
    type prop_items_t is table of prop_item_t;



    /*
     * DBFS API: directory navigation and search.
     *
     * Clients of the DBFS API can list or search the contents of
     * directory pathnames, optionally recursing into sub-directories,
     * optionally seeing soft-deleted items, optionally using flashback
     * "as of" a provided timestamp, and optionally filtering items
     * in/out within the store based on list/search predicates.
     *
     * The DBFS API currently returns only list items; the client is
     * expected to explicitly use one of the "getPath" methods to access
     * the properties or content associated with an item, as
     * appropriate.
     *
     *
     * "listCursor" is a highly specialized directory enumerator that is
     * meant for use with "dbms_fuse" and "dbfs_client" as callers, and
     * with "dbms_dbfs_sfs.listCursor" as the callee.
     *
     * Other users are not expected to invoke this method, and other
     * providers are not expected to implement this method (dbms_fuse
     * can compensate for this by falling back to using the generic
     * "list()" method).
     *
     */

    function    list(
        path        in              varchar2,
        filter      in              varchar2    default null,
        recurse     in              integer     default 0,
        asof        in              timestamp   default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null)
            return  dbms_dbfs_content_list_items_t
                pipelined;

    function    listCursor(
        path        in              varchar2,
        withProps   in              integer     default 0,
        doSort      in              integer     default 0,
        doFts       in              integer     default 0,
        doBulk      in              integer     default 0)
            return  integer;

    function    search(
        path        in              varchar2,
        filter      in              varchar2    default null,
        recurse     in              integer     default 0,
        asof        in              timestamp   default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null)
            return  dbms_dbfs_content_list_items_t
                pipelined;



    /*
     * DBFS API: locking operations.
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
        path        in              varchar2,
        lock_type   in              integer     default lock_read_only,
        lock_data   in              varchar2    default null,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);

    procedure   unlockPath(
        path        in              varchar2,
        store_name  in              varchar2    default null,
        principal   in              varchar2    default null);



    /*
     * DBFS API: abstract operations.
     *
     * All of the operations in the DBFS API are represented as abstract
     * opcodes.
     *
     * Clients can use these opcodes to directly and explicitly invoke
     * the "checkAccess" method (see below) to verify if a particular
     * operation can be invoked by a given principal on a particular
     * pathname.
     *
     *
     * All of the operations listed below should have an obvious
     * meaning, with the following clarifications.
     *
     * An "op_acl" is an implicit operation invoked during an
     * "op_create" or "op_put" that specifies a "std_acl" property---the
     * operation tests to see if the principal is allowed to set or
     * change the ACL of a store item.
     *
     * Soft-deletion, purge, and restore operations are all represented
     * by "op_delete".
     *
     * The source and destination operations of a rename/move are
     * separated out, although stores are free to unify these opcodes
     * (and to also treat a rename as a combination of delete+create).
     *
     * "op_store" is a catch-all category for miscellaneous store
     * operations that do not fall under any of the other operational
     * APIs.
     *
     */

    op_create               constant pls_integer    :=  1;
    op_createFile           constant pls_integer    :=  op_create;
    op_createLink           constant pls_integer    :=  op_create;
    op_createReference      constant pls_integer    :=  op_create;
    op_createDirectory      constant pls_integer    :=  op_create;

    op_delete               constant pls_integer    :=  2;
    op_deleteFile           constant pls_integer    :=  op_delete;
    op_deleteDirectory      constant pls_integer    :=  op_delete;
    op_restore              constant pls_integer    :=  op_delete;
    op_purge                constant pls_integer    :=  op_delete;

    op_read                 constant pls_integer    :=  3;
    op_get                  constant pls_integer    :=  op_read;

    op_write                constant pls_integer    :=  4;
    op_put                  constant pls_integer    :=  op_write;

    op_rename               constant pls_integer    :=  5;
    op_renameFrom           constant pls_integer    :=  op_rename;
    op_renameTo             constant pls_integer    :=  op_rename;
    op_move                 constant pls_integer    :=  6;
    op_moveFrom             constant pls_integer    :=  op_move;
    op_moveTo               constant pls_integer    :=  op_move;
    op_setPath              constant pls_integer    :=  7;

    op_list                 constant pls_integer    :=  8;
    op_search               constant pls_integer    :=  9;

    op_lock                 constant pls_integer    := 10;
    op_unlock               constant pls_integer    := 11;

    op_acl                  constant pls_integer    := 12;
    op_store                constant pls_integer    := 13;



    /*
     * DBFS API: access checks.
     *
     * Check if a given pathname (path, pathtype, store_name) can be
     * manipulated by "operation (see the various "op_xxx" opcode above)
     * by "principal".
     *
     * This is a convenience function for the client; a store that
     * supports access control still internally performs these checks to
     * guarantee security.
     *
     */

    function    checkAccess(
        path        in              varchar2,
        pathtype    in              integer,
        operation   in              varchar2,
        principal   in              varchar2,
        store_name  in              varchar2    default null)
            return  boolean;



    /*
     * DBFS API: path normalization.
     *
     * Convert a store-specific or full-absolute pathname into
     * normalized form:
     *
     *  -> verifies that the pathname is absolute, i.e. starts with a
     *  "/".
     *
     *  -> collapses multiple consecutive "/" into a single "/".
     *
     *  -> strips trailing "/".
     *
     *  -> breaks up a store-specific normalized pathname into 2
     *  components: (parent pathname, trailing component name).
     *
     *  -> breaks up a full-absolute normalized pathname into 3
     *  components: (store name, parent pathname, trailing component
     *  name).
     *
     * The root path "/" is special: its parent pathname is also "/",
     * and its component name is "null", and, in full-absolute mode, has
     * a "null" store name (unless a singleton mount has been created,
     * in which name the appropriate store name is returned).
     *
     *
     * The return value is always the completely normalized
     * store-specific or full-absolute pathname.
     *
     */

    function    normalizePath(
        path        in              varchar2,
        parent      out nocopy      varchar2,
        tpath       out nocopy      varchar2)
            return varchar2;

    function    normalizePath(
        path        in              varchar2,
        store_name  out nocopy      varchar2,
        parent      out nocopy      varchar2,
        tpath       out nocopy      varchar2)
            return varchar2;

    function    normalizePath(
        path        in              varchar2,
        forWrite    in              integer,
        store_name  out nocopy      varchar2,
        parent      out nocopy      varchar2,
        tpath       out nocopy      varchar2,
        provider    out nocopy      varchar2,
        ctx         out nocopy      dbms_dbfs_content_context_t)
            return varchar2;



    /*
     * DBFS API: statistics support.
     *
     * Enable or disable DBFS API statistics.
     *
     * DBFS API statistics are expensive to collect and maintain
     * persistently. The implementation has support for buffering
     * statistics in-memory for a maximum of "flush_time" centiseconds
     * and/or a maximum of "flush_count" operations (whichever limit is
     * reached first), at which time the buffers are implicitly flushed
     * to disk.
     *
     * Clients can also explicitly invoke a flush via "flushStats". An
     * implicit flush also occurs when statistics collection is
     * disabled.
     *
     * "setStats" is used to enable/disable statisics collection; the
     * client can optionally control the flush settings (by specifying
     * non-null values for the time and/or count parameters).
     *
     */

    procedure   getStats(
        enabled     out             boolean,
        flush_time  out             integer,
        flush_count out             integer);

    procedure   setStats(
        enable      in              boolean,
        flush_time  in              integer default null,
        flush_count in              integer default null);

    procedure   flushStats;



    /*
     * DBFS API: tracing support.
     *
     * Enable or disable DBFS API tracing.
     *
     * This is a generic tracing facility that can be used by any DBFS
     * API user (i.e. both clients and providers). The DBFS API
     * dispatcher itself uses the tracing facility.
     *
     * Trace information is written to the foreground tracefile, with
     * varying levels of detail as specified by the trace
     * level/arguments.
     *
     *
     * The global trace level consists of 2 components: "severity" and
     * "detail". These can be thought of as additive bitmasks.
     *
     * The "severity" allows the separation of toplevel vs. low-level
     * tracing of different components, and allows the amount of tracing
     * to be increased as needed. There are no semantics associated with
     * different levels, and users are free to set/trace at any severity
     * they choose, although a good rule of thumb would use severity "1"
     * for toplevel API entry/exit traces, "2" for internal operations,
     * and "3" or greater for very low-level traces.
     *
     * The "detail" controls how much additional information:
     * timestamps, short-stack, etc. is dumped along with each trace
     * record.
     *
     */

    function    getTrace
        return  integer;

    procedure   setTrace(
        trclvl      in              integer);

    function    traceEnabled(
        sev         in              integer)
        return  integer;

    procedure   trace(
        sev         in              integer,
        msg0        in              varchar2,
        msg1        in              varchar     default '',
        msg2        in              varchar     default '',
        msg3        in              varchar     default '',
        msg4        in              varchar     default '',
        msg5        in              varchar     default '',
        msg6        in              varchar     default '',
        msg7        in              varchar     default '',
        msg8        in              varchar     default '',
        msg9        in              varchar     default '',
        msg10       in              varchar     default '');



    /*
     * Content/property view support.
     *
     */

    function    listAllContent
        return  path_items_t
            pipelined;

    function    listAllProperties
        return  prop_items_t
            pipelined;



    /*
     * Utility function: check SPI.
     *
     *
     * Given the name of a putative "dbms_dbfs_content_spi" conforming
     * package, attempt to check that the package really does implement
     * all of the provider methods (with the proper signatures), and
     * report on the conformance.
     *
     * The functional form returns a (cache) temporary lob (of session
     * duration) with the results of the analysis. The caller is
     * expected to manage the lifetime of this lob, as needed.
     *
     * The procedural form generates the results of the analysis into
     * the "chk" lob parameter (if the value passed in is "null", the
     * results are written to the foreground tracefile if DBFS API
     * tracing is enabled). If neither tracing is enabled nor a valid
     * lob passed in, the checker does not provide any useful indication
     * of the analysis (other than raise exceptions if it encounters a
     * serious error).
     *
     * If "schema_name" is "null", standard name resolution rules
     * (current schema, private synonym, public synonym) are used to try
     * and locate a suitable package to analyze.
     *
     * This is a helper wrapper around
     * "dbms_dbfs_content_admin.checkSpi()".
     *
     */

    function    checkSpi(
        package_name        in              varchar2)
            return  clob;

    function    checkSpi(
        schema_name         in              varchar2,
        package_name        in              varchar2)
            return  clob;

    procedure   checkSpi(
        package_name        in              varchar2,
        chk                 in out nocopy   clob);

    procedure   checkSpi(
        schema_name         in              varchar2,
        package_name        in              varchar2,
        chk                 in out nocopy   clob);



    /*
     * Fastpath lookup acceleration view.
     *
     * For a given path, return the (optional) path prefix and view_name
     * that may be used to directly query the "getattr" values.
     *
     * For example, if "path" is of the form "/a/b/c", and the return
     * values are "a" (prefix) and "v" (view_name), it should be
     * possible to query view "v" with column "pathname" bound to values
     * like "/b/c" or "/e" or "/f/g".
     *
     * Paths on singleton mounts would return a null (prefix) and a
     * view_name, and the client must not strip out any leading
     * components of the path when querying the view.
     *
     * The procedure can raise exceptions under various circumstances:
     *
     * . No stores are currently mounted (invalid_path).
     * . A "/" path is used for non-singleton mounts (invalid_path).
     * . The underlying provider does not support lookup views
     *   (unsupported_operation).
     *
     * The view name returned by this procedure can become invalid or
     * disappear at any time becaue of a change in the DBFS state.
     * Clients must treat errors during view access as a signal to
     * refresh their own state (perhaps, re-invoking this method to
     * figure out the new view names, etc.) before proceeding, or else
     * fall back to using standard DBFS methods for their lookup
     * operations.
     *
     *
     * Also note that the getattr view need not (and will most likely
     * not) return pseudo-filesystem entries like "." and ".."---it is
     * up to the client to regenerate entries of this form if needed
     * (for example, if the getattr view is used to generate
     * full/partial recursive filesystem listings instead of point
     * lookups).
     *
     */

    procedure   getattr_view(
        path                in              varchar2,
        prefix              out nocopy      varchar2,
        view_name           out nocopy      varchar2);



end;
/
show errors;

create or replace public synonym dbms_dbfs_content
    for sys.dbms_dbfs_content;

grant execute on dbms_dbfs_content
    to dbfs_role;



/* ------------------------ dbms_dbfs_content_admin ------------------------ */
/*
 * The DBFS administrative API allows users to create store "mount-points",
 * and associate these mount-points with "Store Providers".
 *
 * Store registrations, mounts, and statistics are all qualified by the
 * owner of the underlying store (i.e. the "session_user" executing DBFS API
 * operational or administrative methods).
 *
 */

create or replace package dbms_dbfs_content_admin
    authid definer
as



    /*
     * Administrative and query APIs:
     *
     * (Administrative) clients and store providers are expected to
     * register stores with the DBFS API. Additionally, administrative
     * clients are expected to mount stores into the toplevel namespace
     * of their choice.
     *
     * The registration/unregistration of a store is separated from the
     * mount/unmount of a store since it is possible for the same store
     * to be mounted multiple times at different mount-points (and this
     * is under client control).
     *
     *
     * The administrative methods in "dbms_dbfs_content" are merely
     * wrappers that delegate to the matching methods in
     * "dbms_dbfs_content_admin". Clients can use the methods in either
     * package to perform administrative operations.
     *
     */



    /*
     * Register a new store "store_name" backed by provider
     * "provider_name" that uses "provider_package" as the store
     * provider (conforming to the "dbms_dbfs_content_spi" package
     * signature).
     *
     * This method is to be used primarily by store providers after they
     * have created a new store.
     *
     * Store names must be unique.
     *
     */

    procedure   registerStore(
        store_name          in      varchar2,
        provider_name       in      varchar2,
        provider_package    in      varchar2);


    /*
     * Unregister a previously registered store (invalidating all
     * mount-points associated with it).
     *
     * Once unregistered all access to the store (and its mount-points)
     * are not guaranteed to work (although CR may provide a temporary
     * illusion of continued access).
     *
     *
     * If the "ignore_unknown" argument is "true", attempts to
     * unregister unknown stores will not raise an exception.
     *
     */

    procedure   unregisterStore(
        store_name          in      varchar2,
        ignore_unknown      in      boolean         default false);


    /*
     * Mount a registered store "store_name" and bind it to the
     * "store_mount" mount-point.
     *
     * Once mounted, accesses to pathnames of the form
     * "/<store_mount>/xyz..." will be redirected to <store_name> and
     * its store provider.
     *
     *
     * Store mount-points must be unique, and a syntactically valid
     * pathname component (i.e. a "name_t" with no embedded "/").
     *
     *
     * If a mount-point is not specified (i.e. is null), the DBFS API
     * attempts to use the store name itself as the mount-point name
     * (subject to the uniqueness and syntactic constraints).
     *
     *
     * A special empty mount-point is available for singleton stores,
     * i.e. a scenario where the DBFS API manages a single backend
     * store---in such cases, the client can directly deal with full
     * pathnames of the form "/xyz..." since there is no ambiguity in
     * how to redirect these accesses.
     *
     * Singleton mount-points are indicated by the "singleton" boolean
     * argument, and the "store_mount" argument is ignored.
     *
     *
     * The same store can be mounted multiple times, obviously at
     * different mount-points.
     *
     *
     * Mount properties can be used to specify the DBFS API execution
     * environment, i.e. default values of the principal, owner, acl,
     * and asof for a particular mount-point. Mount properties can also
     * be used to specify a read-only store.
     *
     */

    procedure   mountStore(
        store_name          in      varchar2,
        store_mount         in      varchar2        default null,
        singleton           in      boolean         default false,
        principal           in      varchar2        default null,
        owner               in      varchar2        default null,
        acl                 in      varchar2        default null,
        asof                in      timestamp       default null,
        read_only           in      boolean         default false,
        view_name           in      varchar2        default null);


    /*
     * Unmount a previously mounted store, either by name or by mount
     * point.
     *
     * Singleton stores can be unmounted only by store name (since they
     * have no mount-points).
     *
     * Attempting to unmount a store by name will unmount all
     * mount-points associated with the store.
     *
     * Once unmounted all access to the store (or mount-point) are not
     * guaranteed to work (although CR may provide a temporary illusion
     * of continued access).
     *
     *
     * If the "ignore_unknown" argument is "true", attempts to
     * unregister unknown stores/mounts will not raise an exception.
     *
     */

    procedure   unmountStore(
        store_name          in      varchar2        default null,
        store_mount         in      varchar2        default null,
        ignore_unknown      in      boolean         default false);


    /*
     * Update operation statistics for a store/mount.
     *
     * Statistics flushes are invoked by the DBFS API operations, and
     * update the common metadata tables in a secure manner.
     *
     */

    procedure   updateStats(
        store_name          in      varchar2,
        store_mount         in      varchar2,
        op                  in      integer,
        cnt                 in      integer,
        wt                  in      integer,
        ct                  in      integer);



    /*
     * Utility function: check SPI.
     *
     *
     * Given the name of a putative "dbms_dbfs_content_spi" conforming
     * package, attempt to check that the package really does implement
     * all of the provider methods (with the proper signatures), and
     * report on the conformance.
     *
     * The result is generated into the "chk" lob that the caller must
     * manage.
     *
     * This is a helper for "dbms_dbfs_content.checkSpi()".
     *
     */

    procedure   checkSpi(
        schema_name         in              varchar2,
        package_name        in              varchar2,
        chk                 in out nocopy   clob);



    /*
     * Utility function: update DBFS context.
     *
     * Internal helper function that modifies the DBFS context (and
     * allows sessions to refresh their internal state on subsequent
     * operations). Invoked by various clients after any significant
     * changes to persistent state.
     *
     */

    procedure   updateCtx;



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
     * A one-time action to register the ContentAPI entities with the
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

    procedure   exim_store(
        s_owner             in          varchar2,
        s_name              in          varchar2,
        p_name              in          varchar2,
        p_pkg               in          varchar2,
        created             in          number);
    procedure   exim_mount(
        s_owner             in          varchar2,
        s_name              in          varchar2,
        s_mount             in          varchar2,
        created             in          number);
    procedure   exim_mountp(
        s_owner             in          varchar2,
        s_name              in          varchar2,
        s_mount             in          varchar2,
        propname            in          varchar2,
        propvalue           in          varchar2,
        typecode            in          number);



end;
/
show errors;

create or replace public synonym dbms_dbfs_content_admin
    for sys.dbms_dbfs_content_admin;

grant execute on dbms_dbfs_content_admin
    to dbfs_role;



/* ----------------------------- dbfs context ------------------------------ */
/*
 * A globally accessed helper context that can be used to maintain
 * cross-session shared state for DBFS API users.
 *
 * The "dbfs_context" namespace currently contains the following attributes.
 * All attributes are prefixed by "sys_context('userenv', 'session_user') ||
 * '.'" so that individual DBFS API users can access their own partitioned
 * namespaces.
 *
 *
 *  seq#
 *  A counter that is incremented each time a DBFS API administrative
 *  operation is performed. Any store/mount metadata that has been cached
 *  upto sequence# "N" should be discarded and reconstructed if the current
 *  "seq#" is "> N".
 *
 *  If no administrative operations have been performed so far during the
 *  instance's lifetime, the "seq#" is "null".
 *
 */

create or replace context dbfs_context
    using dbms_dbfs_content_admin
    accessed globally;



/* ------------------------- dbms_dbfs_content_spi ------------------------- */
/*
 * The "DBFS Store Provider" interface (the SPI) describes an internal
 * contract between the implementation of the DBFS API (package body
 * "dbms_dbfs_content") and individual store providers (whatever package
 * their code lives in).
 *
 * Since PL/SQL does not allow a compile-time, declarative type-conformation
 * between package signatures, store providers should informally conform to
 * the SPI, i.e. they should implement the SPI via a package which contains
 * all of the methods specified in package "dbms_dbfs_content_spi", with the
 * same method signatures and semantics. Obviously, these provider packages
 * can implement other methods and expose other interfaces---however, these
 * interfaces will not be used by the DBFS API itself.
 *
 * Since the SPI is merely a contract specification, there is no package
 * body for "dbms_dbfs_content_spi", and it is not possible to actually
 * invoke any methods via this package.
 *
 *
 * The SPI references various elements (constants, types, exceptions)
 * defined by the DBFS API (package "dbms_dbfs_content").
 *
 * Additionally, there is an almost one-to-one correspondence between the
 * client-API exported by the DBFS API and the SPI that the DBFS API itself
 * expects to work against.
 *
 * The main distinction in the method naming conventions is that all
 * pathname references are always store-qualified, i.e. the notion of
 * mount-points and full-absolute pathnames have been normalized and
 * converted to store-qualified pathnames by the DBFS API before it invokes
 * any of the SPI methods.
 *
 *
 * Since the (DBFS API) <-> (DBFS SPI) is a 1-to-many pluggable
 * architecture, the DBFS uses dynamic SQL to invoke methods in the
 * SPI---this can lead to runtime errors.
 *
 *
 * There are no explicit init/fini methods to indicate when the DBFS API
 * plugs/unplugs a particular SPI. Providers must be willing to
 * auto-initialize themselves at any SPI entry-point.
 *
 */

create or replace package dbms_dbfs_content_spi
    authid definer
as



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
     */

    procedure   createGetattrView(
        store_name  in              varchar2,
        ctx         in              dbms_dbfs_content_context_t,
        view_name   out nocopy      varchar2);

    procedure   dropGetattrView(
        store_name  in              varchar2,
        view_name   out nocopy      varchar2);



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
     * pathnames can be implicitly and internally deferenced by stores
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



end;
/
show errors;



