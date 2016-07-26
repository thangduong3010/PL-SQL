Rem
Rem $Header: rdbms/admin/catidxu.sql /st_rdbms_11.2.0/4 2013/02/11 11:46:45 wesmith Exp $
Rem
Rem catidxu.sql
Rem
Rem Copyright (c) 2002, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catidxu.sql - Catalog views for Index Utilities
Rem
Rem    DESCRIPTION
Rem      Creates views to gather index components
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    wesmith     02/07/13 - Backport wesmith_bug-13637733 from main
Rem    jkrismer    01/25/13 - backport nmukherj_ktsap2 bugs 13384876, 13388682,
Rem                           13717643; excluding ktsld.c and ktslst.c
Rem    ddoda       04/20/11 - Backport ddoda_bug-11824603 from main
Rem    wesmith     06/08/07 - add join index flag to view UTL_ALL_IND_COMPS 
Rem    wesmith     03/09/06 - lrg 2018157: fix views "_utl$*" for IOTs
Rem    nfolkert    09/11/03 - add estimate for missing statistics
Rem    nfolkert    05/01/03 - check composite partition for subpartitions
Rem    nfolkert    03/17/03 - change degree for partitions
Rem    nfolkert    01/29/03 - fix degree for partitioned indexes
Rem    nfolkert    01/13/03 - changes for idx_utl list interface
Rem    nfolkert    10/12/02 - nfolkert_idx_rebuild
Rem    nfolkert    10/08/02 - Created
Rem

-- ============================================================================
-- DICTIONARY VIEWS
-- ============================================================================
-- UTL_ALL_IND_COMPS
-- All index components
-- Provides a view including all rebuildable index components including whole
-- indexes, index partitions, and index subpartitions.  Comprised of four
-- private subviews as follows.

-- Types (used for pruning union branches)
-- 'G': NON-PARTITIONED GLOBAL INDEX
-- 'P': PARTITIONED GLOBAL INDEX PARTITION
-- 'L': NON-COMPOSITE LOCAL INDEX PARTITION
-- 'C': COMPOSITE LOCAL INDEX SUBPARTITION

-- Locality
-- 'G': GLOBAL
-- 'L': LOCAL

-- Status
-- 'U': UNUSABLE
-- 'V': VALID

-- ---------------------------------------------------------------------------
-- Notes on size estimates: in the case of indexes being built on tables
-- without statistics (e.g. build-deferred MVs), we are using the allocated
-- segments of the base table as an estimate of the number of rows.  

-- Right now this can be arbitrarily inaccurate.  The extents allocated to
-- a table may not accurately reflect the amount of data in a table (for 
-- example, when large amounts of data are deleted from a table, the 
-- extent size does not change.  

-- We are using the default average row length (100) from kke (KKEDDRL) to
-- estimate the size of the table.  Naturally this may be arbitrarily 
-- inaccurate.  If possible, the code should be reorganized to allow reuse
-- between these functions, but there did not seem to be a simple way to do 
-- that.

-- In some cases, the size of the table cannot be determined from the 
-- segment table, for example index organized tables.  For these cases, we
-- are going to assume the table is very large, so that we will try to run
-- them in parallel.  The value we have chosen is one billion rows.
-- ---------------------------------------------------------------------------

-- Private: ALL GLOBAL NON-PARTITIONTED INDEXES 
CREATE OR REPLACE VIEW "_utl$_gnp_ind" 
(ctype, index_name, component_name, table_id, tab_owner_id, idx_id,
 ind_owner_id, ind_owner_name, comp_id, tcomp_id, ccomp_id, tccomp_id,
 status, locality, degree, rowcnt, join_index)
AS
SELECT 'G', Obj_Idx.name, NULL, Obj_Tab.obj#, Obj_Tab.owner#,
       Obj_Idx.obj#, Obj_Idx.owner#, Usr.name, NULL, NULL, NULL, NULL,
       DECODE(bitand(Ind.flags, 1), 1, 'U', 'V'),
       'G', Ind.degree,
       CASE WHEN Tab.rowcnt IS NOT NULL THEN Tab.rowcnt
            WHEN Seg.file# IS NULL THEN 
              -- for deferred segment creation, set rowcnt to 0
              (CASE WHEN bitand(Tab.property, 17179869184) = 17179869184 THEN 0
               ELSE 1000000000
               END)
            ELSE CEIL((dbms_space_admin.segment_number_blocks(TSpc.ts#, 
              Seg.file#, Seg.block#, Seg.type#, Seg.cachehint, 
              NVL(Seg.spare1, 0),  
              decode(bitand(Seg.spare1, 1), 1, 
              Seg.hwmincr, Tab.dataobj#), 
              Seg.blocks) *
              TSpc.blocksize) / 100) END,
       DECODE(bitand(Ind.property, 1024), 1024, 'Y', 'N')
FROM
     sys.obj$ Obj_Idx, 
     sys.user$ Usr,
     sys.ind$ Ind, 
     sys.obj$ Obj_Tab, 
     sys.ts$ TSpc,
     sys.tab$ Tab
LEFT OUTER JOIN
     sys.seg$ Seg
ON Seg.file# = Tab.file#
  AND Seg.block# = Tab.block#
  AND Seg.ts# = Tab.ts#
  AND Seg.type# = 5
WHERE Obj_Idx.owner# = Usr.user#
  AND Obj_Tab.obj# = Ind.bo#
  AND Ind.type# <> 4                    -- not IOT - TOP
  AND Ind.obj# = Obj_Idx.obj#
  AND NOT (bitand(Ind.property, 2) = 2) -- 0x02 = Partitioned Index
  AND Tab.obj# = Obj_Tab.obj#
  AND Tab.ts# = TSpc.ts#;

-- Private: ALL GLOBAL PARTITIONED INDEX PARTITIONS
-- rowcnt is an estimate.  Since table is not partitioned in the same way
-- that the index is partitioned, the rowcnt is estimated as the total table
-- size divided by the number of index partitions.  Is this correct?  It may
-- be more accurate to use just the table count, given that the lack of 
-- partition correspondence will require a full scan.
CREATE OR REPLACE VIEW "_utl$_gp_ind_parts" 
(ctype, index_name, component_name, table_id, tab_owner_id, idx_id,
 ind_owner_id, ind_owner_name, comp_id, tcomp_id, ccomp_id, tccomp_id,
 status, locality, degree, rowcnt, join_index)
AS
SELECT 'P', Obj_IdxPart.name, Obj_IdxPart.subname, Obj_Tab.obj#,
       Obj_Tab.owner#, Obj_Idx.obj#, Obj_Idx.owner#, 
       Usr.name, Obj_IdxPart.obj#, NULL, NULL, NULL,
       DECODE(bitand(IndPart.flags, 1), 1, 'U', 'V'),
       'G', Ind.degree, 
       CASE WHEN Tab.rowcnt IS NOT NULL THEN Tab.rowcnt / PartObj.partcnt
            WHEN Seg.file# IS NULL THEN 
              -- for deferred segment creation, set rowcnt to 0
              (CASE WHEN bitand(Tab.property, 17179869184) = 17179869184 THEN 0
               ELSE 1000000000
               END)
            ELSE CEIL((dbms_space_admin.segment_number_blocks(TSpc.ts#, 
              Seg.file#, Seg.block#, Seg.type#, Seg.cachehint, 
              NVL(Seg.spare1, 0),
              decode(bitand(Seg.spare1, 1), 1, 
              Seg.hwmincr, Tab.dataobj#),
              Seg.blocks) *
              TSpc.blocksize) / (100 * PartObj.partcnt)) END,
       DECODE(bitand(Ind.property, 1024), 1024, 'Y', 'N')
FROM 
     sys.user$ Usr, 
     sys.obj$ Obj_Idx,
     sys.obj$ Obj_Tab,
     sys.partobj$ PartObj, 
     sys.ind$ Ind, 
     sys.obj$ Obj_IdxPart,
     sys.indpart$ IndPart,
     sys.ts$ TSpc,
     sys.tab$ Tab
LEFT OUTER JOIN
     sys.seg$ Seg
ON Seg.file# = Tab.file#
  AND Seg.block# = Tab.block#
  AND Seg.ts# = Tab.ts#
  AND Seg.type# = 5
WHERE IndPart.bo# = Ind.obj#
  AND Ind.type# <> 4               -- not IOT - TOP
  AND Ind.bo# = Obj_Tab.obj#
  AND IndPart.obj# = Obj_IdxPart.obj#
  AND Ind.obj# = Obj_Idx.obj#
  AND PartObj.obj# = Ind.obj#
  AND bitand(PartObj.flags, 1) = 0 -- 0x01 = Local index
  AND Obj_Idx.owner# = Usr.user#
  AND Tab.obj# = Obj_Tab.obj#
  AND Tab.ts# = TSpc.ts#;

-- Private: ALL LOCAL NON-COMPOSITE INDEX PARTITIONS
CREATE OR REPLACE VIEW "_utl$_lnc_ind_parts"
(ctype, index_name, component_name, table_id, tab_owner_id, idx_id,
 ind_owner_id, ind_owner_name, comp_id, tcomp_id, ccomp_id, tccomp_id,
 status, locality, degree, rowcnt, join_index)
AS
SELECT 'L', Obj_IdxPart.name, Obj_IdxPart.subname, Obj_Tab.obj#, 
       Obj_Tab.owner#, Obj_Idx.obj#, Obj_Idx.owner#, 
       Usr.name, Obj_IdxPart.obj#, TabPart.obj#, NULL, NULL,
       DECODE(bitand(IndPart.flags, 1), 1, 'U', 'V'),
       'L', Ind.degree, 
       CASE WHEN TabPart.rowcnt IS NOT NULL THEN TabPart.rowcnt
            WHEN Seg.file# IS NULL THEN 
              -- for deferred segment creation, set rowcnt to 0
              (CASE WHEN bitand(TabPart.flags, 65536) = 65536 THEN 0
               ELSE 1000000000
               END)
            ELSE CEIL((dbms_space_admin.segment_number_blocks(TSpc.ts#, 
             Seg.file#, Seg.block#, Seg.type#, Seg.cachehint, 
             NVL(Seg.spare1, 0), 
             decode(bitand(Seg.spare1, 1), 1, 
             Seg.hwmincr, TabPart.dataobj#), 
             Seg.blocks) *
             TSpc.blocksize) / 100) END,
       DECODE(bitand(Ind.property, 1024), 1024, 'Y', 'N')
FROM 
     sys.obj$ Obj_Idx, 
     sys.user$ Usr, 
     sys.partobj$ PartObj, 
     sys.ind$ Ind,
     sys.obj$ Obj_IdxPart,
     sys.indpart$ IndPart, 
     sys.obj$ Obj_Tab, 
     sys.tab$ Tab,
     sys.ts$ TSpc,
     sys.tabpart$ TabPart
LEFT OUTER JOIN
     sys.seg$ Seg
ON Seg.file# = TabPart.file#
  AND Seg.block# = TabPart.block#
  AND Seg.ts# = TabPart.ts#
  AND Seg.type# = 5
WHERE Obj_Tab.obj# = Ind.bo#
  AND Ind.type# <> 4               -- not IOT - TOP
  AND Ind.obj# = IndPart.bo#
  AND PartObj.obj# = Ind.obj#
  AND IndPart.obj# = Obj_IdxPart.obj#
  AND Ind.obj# = Obj_Idx.obj#
  AND bitand(PartObj.flags, 1) = 1 -- 0x01 = local index
  AND Obj_Idx.owner# = Usr.user#
  AND TabPart.bo# = Obj_Tab.obj#
  AND TabPart.part# = IndPart.part#
  AND Tab.obj# = Obj_Tab.obj#
  AND TabPart.ts# = TSpc.ts#;

-- Private: ALL LOCAL COMPOSITE INDEX SUBPARTITIONS
CREATE OR REPLACE VIEW "_utl$_lc_ind_subs"
(ctype, index_name, component_name, table_id, tab_owner_id, idx_id,
 ind_owner_id, ind_owner_name, comp_id, tcomp_id, ccomp_id, tccomp_id,
 status, locality, degree, rowcnt, join_index)
AS
SELECT 'C', Obj_IdxSubPart.name, Obj_IdxSubPart.subname, 
       Obj_Tab.obj#, Obj_Tab.owner#, Obj_Idx.obj#, Obj_Idx.owner#, 
       Usr.name, Obj_IdxSubPart.obj#, TabSubPart.obj#, 
       IndComPart.obj#, TabComPart.obj#,
       DECODE(bitand(IndSubPart.flags, 1), 1, 'U', 'V'),
       'L', Ind.degree,
       CASE WHEN TabSubPart.rowcnt IS NOT NULL THEN TabSubPart.rowcnt
            WHEN Seg.file# IS NULL THEN 
              -- for deferred segment creation, set rowcnt to 0
              (CASE WHEN bitand(TabSubPart.flags, 65536) = 65536 THEN 0
               ELSE 1000000000
               END)
            ELSE CEIL((dbms_space_admin.segment_number_blocks(TSpc.ts#, 
              Seg.file#, Seg.block#, Seg.type#, Seg.cachehint, 
              NVL(Seg.spare1, 0), 
              decode(bitand(Seg.spare1, 1), 1, 
              Seg.hwmincr, TabSubPart.dataobj#),
              Seg.blocks) *
              TSpc.blocksize) / 100) END,
       DECODE(bitand(Ind.property, 1024), 1024, 'Y', 'N')
FROM 
     sys.obj$ Obj_IdxSubPart, 
     sys.indsubpart$ IndSubPart,
     sys.indcompart$ IndComPart, 
     sys.user$ Usr, 
     sys.obj$ Obj_Idx, 
     sys.Ind$ Ind, 
     sys.obj$ Obj_Tab, 
     sys.partobj$ PartObj,
     sys.tabcompart$ TabComPart,
     sys.tab$ Tab,
     sys.ts$ TSpc,
     sys.tabsubpart$ TabSubPart
LEFT OUTER JOIN
     sys.seg$ Seg
ON   Seg.file# = TabSubPart.file#
  AND Seg.block# = TabSubPart.block#
  AND Seg.ts# = TabSubPart.ts#
  AND Seg.type# = 5
WHERE IndComPart.obj# = IndSubPart.pobj#
  AND IndComPart.bo# = Ind.obj#
  AND Ind.type# <> 4             -- not IOT - TOP
  AND Ind.bo# = Obj_Tab.obj#
  AND Obj_IdxSubPart.obj# = IndSubPart.obj#
  AND Obj_Idx.owner# = Usr.user#
  AND Ind.obj# = Obj_Idx.obj#
  AND PartObj.obj# = Ind.obj#
  AND TabComPart.bo# = Obj_Tab.obj#
  AND TabComPart.part# = IndComPart.part#
  AND TabComPart.obj# = TabSubPart.pobj#
  AND TabSubPart.subpart# = IndSubPart.subpart#
  AND Tab.obj# = Obj_Tab.obj#
  AND TabSubPart.ts# = TSpc.ts#;

-- The Union view of all components

-- PUBLIC: All Index Components
-- This view is for use with the public interface to the index rebuild package.
-- The owner of the table can rebuild all indexes on that table.  Also, users
-- with alter any index or alter any table privileges. /* Bug# 11824603 */
-- Columns:
--   ctype - type of component -- see above
--   index_name - name of the index 
--   component_name - name of the component of the index, if appropriate
--   table_id - obj# of the table being indexed
--   tab_owner_id - owner# of the table being indexed
--   idx_id - obj# of the index
--   ind_owner_id - owner# of the index
--   ind_owner_name - name of the owner of the index
--   comp_id - obj# of the component, if appropriate
--   tcomp_id - obj# of table component related to index component, if
--              appropriate
--   ccomp_id - obj# of composite partition containing this component, if 
--              appropriate
--   tccomp_id - obj# of the composite partition containing the table 
--               component related to the index component, if appropriate
--   status - unusable or valid, see above
--   locality - global or local, see above
--   degree - degree of parallelism for the index
--   rowcnt - number of rows in the index/index component
--   join_index - Y if this is a join index, N otherwise
CREATE OR REPLACE VIEW utl_all_ind_comps
(ctype, index_name, component_name, table_id, tab_owner_id, idx_id,
 ind_owner_id, ind_owner_name, comp_id, tcomp_id, ccomp_id, tccomp_id,
 status, locality, degree, rowcnt, join_index)
AS
SELECT * FROM "_utl$_gnp_ind" WHERE (tab_owner_id = userenv('SCHEMAID')
       OR ind_owner_id = userenv('SCHEMAID')
       OR EXISTS (SELECT NULL FROM sys.v$enabledprivs
                  WHERE priv_number in (-72 /* ALTER ANY INDEX */,
                                        -42 /* ALTER ANY TABLE */)))
UNION ALL
SELECT * FROM "_utl$_gp_ind_parts" WHERE (tab_owner_id = userenv('SCHEMAID')
       OR ind_owner_id = userenv('SCHEMAID')
       OR EXISTS (SELECT NULL FROM sys.v$enabledprivs
                  WHERE priv_number in (-72 /* ALTER ANY INDEX */,
                                        -42 /* ALTER ANY TABLE */)))
UNION ALL
SELECT * FROM "_utl$_lnc_ind_parts" WHERE (tab_owner_id = userenv('SCHEMAID')
       OR ind_owner_id = userenv('SCHEMAID')
       OR EXISTS (SELECT NULL FROM sys.v$enabledprivs
                  WHERE priv_number in (-72 /* ALTER ANY INDEX */,
                                        -42 /* ALTER ANY TABLE */)))
UNION ALL
SELECT * FROM "_utl$_lc_ind_subs" WHERE (tab_owner_id = userenv('SCHEMAID')
       OR ind_owner_id = userenv('SCHEMAID')
       OR EXISTS (SELECT NULL FROM sys.v$enabledprivs
                  WHERE priv_number in (-72 /* ALTER ANY INDEX */,
                                        -42 /* ALTER ANY TABLE */)));
CREATE OR REPLACE PUBLIC SYNONYM utl_all_ind_comps FOR utl_all_ind_comps;
GRANT SELECT ON utl_all_ind_comps TO PUBLIC;





