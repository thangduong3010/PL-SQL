Rem
Rem $Header: rdbms/admin/dbmslobu.sql /st_rdbms_11.2.0/1 2011/03/03 17:44:56 kshergil Exp $
Rem
Rem dbmslobu.sql
Rem
Rem Copyright (c) 2006, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmslobu.sql - DBMS_LOBUTIL diagnostics package for 11globs
Rem
Rem    DESCRIPTION
Rem      DBMS_LOBUTIL diagnostics package for 11globs
Rem
Rem    NOTES
Rem The new package DBMS_LOBUTIL is a container for diagnostic and
Rem utility functions and procedures specific to 11globs.
Rem
Rem Since diagnostic operations are not part of the standard programmatic
Rem APIs in DBMS_LOB, they are provided in a separate namespace to avoid
Rem clutter.  The diagnostic API is also not quite as critical to document
Rem for end-users; its main use is for internal developer, QA, and DDR use
Rem (especially since it peeks into the internal structure of 11glob
Rem inodes and lobmaps).
Rem
Rem
Rem NOTE: DBMS_LOBUTIL is owned by SYS and should be executable only by
Rem suitably privileged users (since the package does not provide a
Rem standard programmatic API).
Rem
Rem
Rem NOTE: The API is subject to change, often in backwards-incompatible
Rem ways, depending on changes to the underlying data structures for
Rem 11glob inodes, and the diagnostic needs of the API.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    kshergil    02/24/11 - Backport kshergil_bug-11691477 from main
Rem    kkunchit    11/02/06 - overallocations, lobid
Rem    kkunchit    10/02/06 - superchunks
Rem    kkunchit    07/28/06 - Created
Rem



-- dbms_lobutil_inode_t: inode information
CREATE OR REPLACE TYPE dbms_lobutil_inode_t AS OBJECT
(
    lobid   RAW(10),    -- lobid
    flags   NUMBER,     -- inode flags
    length  NUMBER,     -- lob length
    version NUMBER,     -- lob version
    extents NUMBER,     -- #extents in inode
    lhb     NUMBER      -- lhb dba
);
/
show errors;



-- dbms_lobutil_lobmap_t: lobmap information
CREATE OR REPLACE TYPE dbms_lobutil_lobmap_t AS OBJECT
(
    lobid   RAW(10),    -- lobid
    eflag   NUMBER,     -- extent flags
    rdba    NUMBER,     -- extent header rdba
    nblks   NUMBER,     -- #blocks in extent
    offset  NUMBER,     -- offset of extent header
    length  NUMBER      -- logical length of extent
);
/
show errors;



-- dbms_lobutil_lobextent_t: extent information
CREATE OR REPLACE TYPE dbms_lobutil_lobextent_t AS OBJECT
(
    rid     VARCHAR(32),    -- rowid proxy
    row#    NUMBER,         -- rownum proxy
    lobid   RAW(10),        -- lobid
    extent# NUMBER,         -- extent# [0 .. ] for a lobmap
    hole    VARCHAR(1),     -- is the extent a hole? (y/n)
    cont    VARCHAR(1),     -- is the extent a superchunk continuation? (y/n)
    over    VARCHAR(1),     -- is the chunk an overallocation? (y/n)
    rdba    NUMBER,         -- rdba of extent start
    nblks   NUMBER,         -- #blocks in extent
    offset  NUMBER,         -- logical offset of extent start
    length  NUMBER          -- logical length of extent
);
/
show errors;



-- dbms_lobutil_lobextents_t: expanded extent map information
CREATE OR REPLACE TYPE dbms_lobutil_lobextents_t
    AS
    TABLE OF dbms_lobutil_lobextent_t;
/
show errors;



-- dbms_lobutil_dedupset_t: deduplication set information
CREATE OR REPLACE TYPE dbms_lobutil_dedupset_t AS OBJECT
(
    ismem   VARCHAR(1),     -- is this lob a member of a dedup set? (Y/N)
    setid   RAW(10),        -- deduplication setid
    lobid   RAW(10),        -- this lobid
    nmem    NUMBER,         -- number of members in set
    fhash   RAW(80),        -- full hash of set
    phash   RAW(80)         -- prefix hash of set
);
/
show errors;



Rem
Rem DBMS_LOBUTIL package
Rem
CREATE OR REPLACE PACKAGE dbms_lobutil AS


    -- inode query
    FUNCTION getinode(lob_loc IN BLOB)
        RETURN dbms_lobutil_inode_t DETERMINISTIC;
        PRAGMA RESTRICT_REFERENCES(getinode, WNDS, RNDS, WNPS, RNPS, TRUST);

    FUNCTION getinode(lob_loc IN CLOB CHARACTER SET ANY_CS)
        RETURN dbms_lobutil_inode_t DETERMINISTIC;
        PRAGMA RESTRICT_REFERENCES(getinode, WNDS, RNDS, WNPS, RNPS, TRUST);


    -- lobmap query
    FUNCTION getlobmap(lob_loc IN BLOB, n IN NUMBER)
        RETURN dbms_lobutil_lobmap_t DETERMINISTIC;
        PRAGMA RESTRICT_REFERENCES(getlobmap, WNDS, RNDS, WNPS, RNPS, TRUST);

    FUNCTION getlobmap(lob_loc IN CLOB CHARACTER SET ANY_CS, n IN NUMBER)
        RETURN dbms_lobutil_lobmap_t DETERMINISTIC;
        PRAGMA RESTRICT_REFERENCES(getlobmap, WNDS, RNDS, WNPS, RNPS, TRUST);


    -- extent expansion
    FUNCTION getextents(crs IN sys_refcursor)
        RETURN dbms_lobutil_lobextents_t DETERMINISTIC PIPELINED;
        PRAGMA RESTRICT_REFERENCES(getextents, WNDS, RNDS, WNPS, RNPS, TRUST);


    -- deduplication set query
    FUNCTION getdedupset(lob_loc IN BLOB)
        RETURN dbms_lobutil_dedupset_t DETERMINISTIC;
        PRAGMA RESTRICT_REFERENCES(getdedupset, WNDS, RNDS, WNPS, RNPS, TRUST);

    FUNCTION getdedupset(lob_loc IN CLOB CHARACTER SET ANY_CS)
        RETURN dbms_lobutil_dedupset_t DETERMINISTIC;
        PRAGMA RESTRICT_REFERENCES(getdedupset, WNDS, RNDS, WNPS, RNPS, TRUST);


END;
/
show errors;



Rem
Rem grants
Rem

GRANT EXECUTE ON dbms_lobutil_inode_t      TO PUBLIC;
GRANT EXECUTE ON dbms_lobutil_lobmap_t     TO PUBLIC;
GRANT EXECUTE ON dbms_lobutil_lobextent_t  TO PUBLIC;
GRANT EXECUTE ON dbms_lobutil_lobextents_t TO PUBLIC;
GRANT EXECUTE ON dbms_lobutil_dedupset_t   TO PUBLIC;
GRANT EXECUTE ON dbms_lobutil              TO PUBLIC;



Rem
Rem synonyms
Rem

CREATE OR REPLACE PUBLIC SYNONYM dbms_lobutil_inode_t
    FOR sys.dbms_lobutil_inode_t
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_lobutil_lobmap_t
    FOR sys.dbms_lobutil_lobmap_t
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_lobutil_lobextent_t
    FOR sys.dbms_lobutil_lobextent_t
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_lobutil_lobextents_t
    FOR sys.dbms_lobutil_lobextents_t
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_lobutil_dedupset_t
    FOR sys.dbms_lobutil_dedupset_t
/
show errors;

CREATE OR REPLACE PUBLIC SYNONYM dbms_lobutil FOR sys.dbms_lobutil
/
show errors;
