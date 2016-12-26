Rem
Rem $Header: catnoprt.sql 10-mar-97.12:57:44 achaudhr Exp $
Rem
Rem catnoprt.sql
Rem
Rem  Copyright (c) Oracle Corporation 1997. All Rights Reserved.
Rem
Rem    NAME
Rem      catnoprt.sql - CATalog NO PaRTitioning
Rem
Rem    DESCRIPTION
Rem      Drops data dictionary views for the partitioning table.
Rem
Rem    NOTES
Rem      1. This file use to be called CATNOPART.SQL.
Rem      2. This script is used to drop these views run CATPART.SQL.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    achaudhr    03/10/97 - Created
Rem
drop view USER_PART_TABLES
/
drop view ALL_PART_TABLES
/
drop view DBA_PART_TABLES
/
drop view USER_PART_INDEXES
/
drop view ALL_PART_INDEXES
/
drop view DBA_PART_INDEXES
/
drop view USER_PART_KEY_COLUMNS
/
drop view ALL_PART_KEY_COLUMNS
/
drop view DBA_PART_KEY_COLUMNS
/
drop view USER_TAB_PARTITIONS
/
drop view ALL_TAB_PARTITIONS
/
drop view DBA_TAB_PARTITIONS
/
drop view USER_IND_PARTITIONS
/
drop view ALL_IND_PARTITIONS
/
drop view DBA_IND_PARTITIONS
/
drop view USER_PART_COL_STATISTICS
/
drop view ALL_PART_COL_STATISTICS
/
drop view DBA_PART_COL_STATISTICS
/
drop view USER_PART_HISTOGRAMS
/
drop view ALL_PART_HISTOGRAMS
/
drop view DBA_PART_HISTOGRAMS
/
