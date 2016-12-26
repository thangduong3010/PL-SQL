Rem
Rem $Header: rdbms/admin/i1102000.sql /st_rdbms_11.2.0/1 2012/08/25 00:06:31 pknaggs Exp $
Rem
Rem i1102000.sql
Rem
Rem Copyright (c) 2011, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      i1102000.sql - load 11.2.0.4 specific tables that are needed to
Rem                     process basic DDL statements
Rem
Rem    DESCRIPTION
Rem      This script MUST be one of the first things called from the 
Rem      top-level upgrade script.
Rem
Rem      Only put statements in here that must be run in order
Rem      to process basic SQL commands.  For example, in order to 
Rem      drop a package, the server code may depend on new tables.
Rem      Another example: in order to alter a table, the server code
Rem      needs to perform an update of the radm_mc$ dictionary table.
Rem      If these tables do not exist, a recursive SQL error will occur,
Rem      causing the command to be aborted.
Rem
Rem      The upgrade is performed in the following stages:
Rem        STAGE 1: upgrade from 11.2 to the current release
Rem        STAGE 2: invoke script for subsequent release
Rem
Rem    NOTES
Rem      * This script must be run using SQL*PLUS.
Rem      * You must be connected AS SYSDBA to run this script.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pknaggs    01/31/12 - Bug #12885283: Remove type from radm_mc$
Rem    pknaggs    01/31/12 - Created
Rem

Rem =========================================================================
Rem BEGIN STAGE 1: upgrade from 11.2 to the current release
Rem =========================================================================

Rem ======================================
Rem Begin RADM changes.
Rem ======================================

Rem *************************************************************************
Rem RADM (Real-time Application-controlled Data Masking): create
Rem the column-level RADM policy information dictionary table.
Rem The creation of the radm_mc$ must take place here, ahead of any use
Rem of any "alter table" DDL SQL command, because the intcol# column of
Rem the radm_mc$ table is now registered in the atbDT[] array, such that
Rem when the alter table driver runs, it automatically updates the intcol# 
Rem value in the radm_mc$ table. For this to work, the radm_mc$ table
Rem must of course exist, otherwise a recursive SQL error would occur
Rem during the attempted (recursive) update of the radm_mc$ table.
Rem *************************************************************************
Rem
create table radm_mc$                      /* RADM policies - Masked Columns */
(
  obj#                   NUMBER NOT NULL,             /* table object number */
  intcol#                NUMBER NOT NULL,                   /* column number */
  mfunc                  NUMBER NOT NULL,           /* RADM Masking Function */
  mparams                VARCHAR2(1000),          /* RADM Masking Parameters */
  regexp_pattern         VARCHAR2(512),        /* Regular Expression pattern */
  regexp_replace_string  VARCHAR2(4000),               /* Replacement string */
  regexp_position        NUMBER,                 /* Position to begin search */
  regexp_occurrence      NUMBER,    /* Replace specified or every occurrence */
  regexp_match_parameter VARCHAR2(10),          /* Control matching behavior */
  mp_iformat_start_byte  INTEGER,         /* starting byte # of INPUT FORMAT */
  mp_iformat_end_byte    INTEGER,           /* ending byte # of INPUT FORMAT */
  mp_oformat_start_byte  INTEGER,        /* starting byte # of OUTPUT FORMAT */
  mp_oformat_end_byte    INTEGER,          /* ending byte # of OUTPUT FORMAT */
  mp_maskchar_start_byte INTEGER,            /* starting byte # of MASK CHAR */
  mp_maskchar_end_byte   INTEGER,              /* ending byte # of MASK CHAR */
  mp_maskfrom            INTEGER,         /* MASK FROM, converted to integer */
  mp_maskto              INTEGER,           /* MASK TO, converted to integer */
  mp_datmask_Mo          INTEGER,                     /* date mask for Month */
  mp_datmask_D           INTEGER,                       /* date mask for Day */
  mp_datmask_Y           INTEGER,                      /* date mask for Year */
  mp_datmask_H           INTEGER,                      /* date mask for Hour */
  mp_datmask_Mi          INTEGER,                    /* date mask for Minute */
  mp_datmask_S           INTEGER                     /* date mask for Second */
)
/
create index i_radm_mc1 on radm_mc$(obj#)
/
create index i_radm_mc2 on radm_mc$(obj#, intcol#)
/

Rem ====================================
Rem End RADM changes.
Rem ====================================

Rem =========================================================================
Rem BEGIN STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem uncomment the following line for next release to call subsequent i script
Rem @@ixxxxxxx.sql

Rem =========================================================================
Rem END STAGE 2: invoke script for subsequent release
Rem =========================================================================

Rem *************************************************************************
Rem END i1102000.sql
Rem *************************************************************************

