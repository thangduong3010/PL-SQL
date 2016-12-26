Rem
Rem $Header: rdbms/admin/catlmnr.sql /st_rdbms_11.2.0.4.0dbpsu/1 2014/04/20 12:38:16 tchorma Exp $
Rem
Rem catlmnr.sql
Rem
Rem Copyright (c) 2007, 2014, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      catlmnr.sql - Create Tables and Views for Logminer
Rem
Rem    DESCRIPTION
Rem      This script creates logminer views and partitioned tables
Rem
Rem    NOTES
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      04/05/14 - Backport
Rem                           apfwkr_blr_backport_17381384_11.2.0.4.1dbpsu from
Rem                           st_rdbms_11.2.0.4.0dbpsu
Rem    apfwkr      01/16/14 - Backport apfwkr_blr_backport_17381384_11.2.0.4.0
Rem                           from st_rdbms_11.2.0
Rem    apfwkr      10/21/13 - Backport tchorma_bug-17381384 from main
Rem    abrown      02/22/13 - abrown_bp_logmnr_ggtrigger_eliminate
Rem                           o Bbug 14508550 - logminer metadata fixes
Rem                             cdb/constraints
Rem                           o Bug 14378546 : Logminer must track CON$
Rem                           o Bug 14283060: Added logmnrc_*_gg tables
Rem    tchorma     09/11/13 - Bug 17381384 - Fix subquery for internal refs in
Rem                           logmnr_gtcs_support
Rem    abrown      05/18/10 - Bug 9708526: Missing predicate for
Rem                           XReffedTableObjn etc.
Rem    jgalanes    08/16/08 - Add logmnrC_gsba for XML FDO tracking
Rem    preilly     07/17/07 - Need to get xmlintcol for special columns
Rem    dvoss       06/10/08 - bug 7033630 - add logmnrc_i2gtcs
Rem    dvoss       03/23/07 - bug 5867998
Rem    dvoss       02/12/07 - add grant to sys
Rem    dvoss       01/04/07 - Created
Rem

Rem Create partitioned Logminer tables if they do not yet exist

alter session set events '14524 trace name context forever, level 1';
CREATE TABLE SYSTEM.LOGMNR_DICTSTATE$ (
                    LOGMNR_UID NUMBER(22),
                    START_SCNBAS NUMBER,
                    START_SCNWRP NUMBER,
                    END_SCNBAS NUMBER,
                    END_SCNWRP NUMBER,
                    REDO_THREAD NUMBER,
                    RBASQN NUMBER,
                    RBABLK NUMBER,
                    RBABYTE NUMBER,
                    LOGMNR_FLAGS NUMBER(22),
                    constraint LOGMNR_DICTSTATE$_PK
                       primary key (LOGMNR_UID) disable)
                 PARTITION BY RANGE(logmnr_uid)
                    ( PARTITION p_lessthan100 VALUES LESS THAN (100))
                 TABLESPACE SYSAUX LOGGING
/
CREATE TABLE SYSTEM.LOGMNRC_GTLO( 
                  LOGMNR_UID         NUMBER NOT NULL, 
                  KEYOBJ#            NUMBER NOT NULL,
                  LVLCNT             NUMBER NOT NULL,  /* level count */
                  BASEOBJ#           NUMBER NOT NULL,  /* base object number */
                  BASEOBJV#          NUMBER NOT NULL,  
                                                      /* base object version */
                  LVL1OBJ#           NUMBER,  /* level 1 object number */
                  LVL2OBJ#           NUMBER,  /* level 2 object number */
                  LVL0TYPE#          NUMBER NOT NULL,
                                              /* level 0 (base obj) type # */
                  LVL1TYPE#          NUMBER,  /* level 1 type # */
                  LVL2TYPE#          NUMBER,  /* level 2 type # */
                  OWNER#             NUMBER,  /* owner number */
                  OWNERNAME          VARCHAR2(30) NOT NULL,
                  LVL0NAME           VARCHAR2(30) NOT NULL,
                                              /* name of level 0 (base obj)  */
                  LVL1NAME           VARCHAR2(30), /* name of level 1 object */
                  LVL2NAME           VARCHAR2(30), /* name of level 2 object */
                  INTCOLS            NUMBER NOT NULL,
                              /* for table object, number of all types cols  */
                  COLS               NUMBER,
                           /* for table object, number of user visable cols  */
                  KERNELCOLS         NUMBER,
                        /* for table object, number of non zero secol# cols  */
                  TAB_FLAGS          NUMBER,   /* TAB$.FLAGS        */
                  TRIGFLAG           NUMBER,   /* TAB$.TRIGFLAG     */
                  ASSOC#             NUMBER,   /* IOT/OF Associated object */
                  OBJ_FLAGS          NUMBER,   /* OBJ$.FLAGS        */
                  TS#                NUMBER, /* table space number */
                  TSNAME             VARCHAR2(30), /* table space name   */
                  PROPERTY           NUMBER,
                  /* Replication Dictionary Specific Columns  */
                  START_SCN          NUMBER NOT NULL,
                                            /* SCN at which existence begins */
                  DROP_SCN         NUMBER,  /* SCN at which existence ends   */
                  XIDUSN             NUMBER,
                                        /* src txn which created this object */
                  XIDSLT             NUMBER,
                  XIDSQN             NUMBER,
                  FLAGS              NUMBER,
                  LOGMNR_SPARE1             NUMBER,
                  LOGMNR_SPARE2             NUMBER,
                  LOGMNR_SPARE3             VARCHAR2(1000),
                  LOGMNR_SPARE4             DATE,
                  LOGMNR_SPARE5             NUMBER,
                  LOGMNR_SPARE6             NUMBER,
                  LOGMNR_SPARE7             NUMBER,
                  LOGMNR_SPARE8             NUMBER,
                  LOGMNR_SPARE9             NUMBER,
                /* New in V11  */
                  PARTTYPE                  NUMBER,
                  SUBPARTTYPE               NUMBER,
                  UNSUPPORTEDCOLS           NUMBER,
                  COMPLEXTYPECOLS           NUMBER,
                  NTPARENTOBJNUM            NUMBER,
                  NTPARENTOBJVERSION        NUMBER,
                  NTPARENTINTCOLNUM         NUMBER,
                  LOGMNRTLOFLAGS            NUMBER,
                  LOGMNRMCV                 VARCHAR2(30),
                    CONSTRAINT LOGMNRC_GTLO_PK
                    PRIMARY KEY(LOGMNR_UID, KEYOBJ#, BASEOBJV#)
                    USING INDEX LOCAL
                  ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
                  TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNRC_I2GTLO 
    ON SYSTEM.LOGMNRC_GTLO (logmnr_uid, baseobj#, baseobjv#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNRC_I3GTLO 
    ON SYSTEM.LOGMNRC_GTLO (logmnr_uid, drop_scn) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNRC_GTCS(
                   LOGMNR_UID                NUMBER NOT NULL,
                   OBJ#                      NUMBER NOT NULL,
                                              /* table (base) object number  */
                   OBJV#                     NUMBER NOT NULL,
                                              /* table object version        */
                   SEGCOL#                   NUMBER NOT NULL,
                                              /* segcol# of column           */
                   INTCOL#                   NUMBER NOT NULL,
                                              /* intcol# of column           */
                   COLNAME                   VARCHAR2(30) NOT NULL, 
                                              /* name of column              */
                   TYPE#                     NUMBER NOT NULL, /* column type */
                   LENGTH                    NUMBER, /* data length */
                   PRECISION                 NUMBER, /* data precision */
                   SCALE                     NUMBER, /* data scale */
                   INTERVAL_LEADING_PRECISION  NUMBER,
                                       /* Interval Leading Precision, if any */
                   INTERVAL_TRAILING_PRECISION NUMBER,
                                      /* Interval trailing precision, if any */
                   PROPERTY                  NUMBER,
                   TOID                      RAW(16),
                   CHARSETID                 NUMBER,
                   CHARSETFORM               NUMBER,
                   TYPENAME                  VARCHAR2(30),
                   FQCOLNAME                 VARCHAR2(4000),
                                              /* fully-qualified column name */
                   NUMINTCOLS                NUMBER, /* Number of Int Cols  */
                   NUMATTRS                  NUMBER,
                   ADTORDER                  NUMBER,
                   LOGMNR_SPARE1                    NUMBER,
                   LOGMNR_SPARE2                    NUMBER,
                   LOGMNR_SPARE3                    VARCHAR2(1000),
                   LOGMNR_SPARE4                    DATE,
                   LOGMNR_SPARE5             NUMBER,
                   LOGMNR_SPARE6             NUMBER,
                   LOGMNR_SPARE7             NUMBER,
                   LOGMNR_SPARE8             NUMBER,
                   LOGMNR_SPARE9             NUMBER,
                /* New for V11.  */
                   COL#                      NUMBER,
                   XTYPESCHEMANAME           VARCHAR2(30),
                   XTYPENAME                 VARCHAR2(4000),
                   XFQCOLNAME                VARCHAR2(4000),
                   XTOPINTCOL                NUMBER,
                   XREFFEDTABLEOBJN          NUMBER,
                   XREFFEDTABLEOBJV          NUMBER,
                   XCOLTYPEFLAGS             NUMBER,
                   XOPQTYPETYPE              NUMBER,
                   XOPQTYPEFLAGS             NUMBER,
                   XOPQLOBINTCOL             NUMBER,
                   XOPQOBJINTCOL             NUMBER,
                   XXMLINTCOL                NUMBER,
                   EAOWNER#                  NUMBER,
                   EAMKEYID                  VARCHAR2(64),
                   EAENCALG                  NUMBER,
                   EAINTALG                  NUMBER,
                   EACOLKLC                  RAW(2000),
                   EAKLCLEN                  NUMBER,
                   EAFLAGS                   NUMBER,
                     constraint logmnrc_gtcs_pk
                     primary key(logmnr_uid, obj#, objv#,intcol#)
                     using index local
                  ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
                    TABLESPACE SYSAUX LOGGING
/

Rem Note the following index may not exist prior to 11.1.0.7.
CREATE INDEX SYSTEM.LOGMNRC_I2GTCS
    ON SYSTEM.LOGMNRC_GTCS (logmnr_uid, obj#, objv#, segcol#, intcol#)
    TABLESPACE SYSAUX LOCAL LOGGING
/


Rem 
Rem LOGMNRC_SEQ_GG is a table to hold sequence related information for GG.
Rem This is versioned by the commit_scn of the ddl.
Rem Sequences are versioned on every ddl on them. Each ddl on a sequence
Rem pushes a row into this table that contains the before image of the ddl.
Rem  SEQ_FLAGS is a bit field column whose bits can be
Rem     SEQ_CYCLE - derived from seq$.cycle#
Rem     SEQ_ORDER - derived from seq$.order$

CREATE TABLE SYSTEM.LOGMNRC_SEQ_GG (
                   LOGMNR_UID NUMBER NOT NULL,
                   OBJ#       NUMBER NOT NULL,
                   COMMIT_SCN NUMBER NOT NULL,
                   DROP_SCN   NUMBER,
                   SEQ_FLAGS  NUMBER NOT NULL, 
                   OWNER#      NUMBER NOT NULL,
                   OWNERNAME   VARCHAR2(128) NOT NULL,
                   OBJNAME    VARCHAR2(128) NOT NULL,
                   SEQCACHE    NUMBER, /* Used for sequences */
                   SEQINC      NUMBER,
                   SPARE1     NUMBER,
                   SPARE2     NUMBER,
                   SPARE3     VARCHAR(4000),
                   SPARE4     VARCHAR(4000),
                    constraint logmnrc_seq_gg_pk
                      primary key(logmnr_uid, obj#,commit_scn)
                      using index local
            ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
            TABLESPACE SYSAUX LOGGING
/


CREATE INDEX SYSTEM.LOGMNRC_I2SEQGG
    ON SYSTEM.LOGMNRC_SEQ_GG (logmnr_uid, drop_scn)
    TABLESPACE SYSAUX LOCAL LOGGING
/

Rem
Rem LOGMNRC_CON_GG is a table to hold the constraint information
Rem tracked by SCN.
Rem

CREATE TABLE SYSTEM.LOGMNRC_CON_GG (
                   LOGMNR_UID NUMBER NOT NULL,
                   CON#       NUMBER NOT NULL,
                   NAME       VARCHAR2(128) NOT NULL,
                   COMMIT_SCN NUMBER NOT NULL,
                   DROP_SCN   NUMBER,
                   BASEOBJ#   NUMBER NOT NULL,
                   BASEOBJV#  NUMBER NOT NULL,
                   FLAGS      NUMBER NOT NULL, 
                   INDEXOBJ#  NUMBER,
                   SPARE1     NUMBER,
                   SPARE2     NUMBER,
                   SPARE3     NUMBER,
                   SPARE4     VARCHAR2(4000),
                   SPARE5     VARCHAR2(4000),
                   SPARE6     VARCHAR2(4000),
                    constraint logmnrc_con_gg_pk
                  primary key(logmnr_uid, con#, commit_scn)
                      using index local
            ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
            TABLESPACE SYSAUX LOGGING
/

CREATE INDEX SYSTEM.LOGMNRC_I1CONGG
    ON SYSTEM.LOGMNRC_CON_GG (logmnr_uid, baseobj#, baseobjv#, commit_scn)
    TABLESPACE SYSAUX LOCAL LOGGING
/

CREATE INDEX SYSTEM.LOGMNRC_I2CONGG
    ON SYSTEM.LOGMNRC_CON_GG (logmnr_uid, drop_scn)
    TABLESPACE SYSAUX LOCAL LOGGING
/

Rem
Rem LOGMNRC_CONCOL_GG would contain the column information of the
Rem constraints pushed into LOGMNRC_CON_GG.
Rem

CREATE TABLE SYSTEM.LOGMNRC_CONCOL_GG (
                   LOGMNR_UID NUMBER NOT NULL,
                   CON#       NUMBER NOT NULL,
                   COMMIT_SCN NUMBER NOT NULL,
                   INTCOL#    NUMBER NOT NULL,
                   POS#       NUMBER,
                   SPARE1 NUMBER,
                   SPARE2 NUMBER,
                   SPARE3 VARCHAR2(4000),
                   constraint logmnrc_concol_gg_pk
                    primary key(logmnr_uid, con#, commit_scn, intcol#)
                    using index local
              ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
              TABLESPACE SYSAUX LOGGING
/

Rem
Rem LOGMNRC_IND_GG is a table to hold the index information
Rem tracked by SCN.
Rem

CREATE TABLE SYSTEM.LOGMNRC_IND_GG (
                   LOGMNR_UID NUMBER NOT NULL,
                   OBJ#       NUMBER NOT NULL,
                   NAME       VARCHAR2(128) NOT NULL,
                   COMMIT_SCN NUMBER NOT NULL,
                   DROP_SCN   NUMBER,
                   BASEOBJ#   NUMBER NOT NULL,
                   BASEOBJV#  NUMBER NOT NULL,
                   FLAGS      NUMBER NOT NULL, 
                   OWNER#     NUMBER NOT NULL,
                   OWNERNAME  VARCHAR2(128) NOT NULL,
                   SPARE1     NUMBER,
                   SPARE2     NUMBER,
                   SPARE3     NUMBER,
                   SPARE4     VARCHAR2(4000),
                   SPARE5     VARCHAR2(4000),
                   SPARE6     VARCHAR2(4000),
                    constraint logmnrc_ind_gg_pk
                  primary key(logmnr_uid, obj#, commit_scn)
                      using index local
            ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
            TABLESPACE SYSAUX LOGGING
/

CREATE INDEX SYSTEM.LOGMNRC_I1INDGG
    ON SYSTEM.LOGMNRC_IND_GG (logmnr_uid, baseobj#, baseobjv#, commit_scn)
    TABLESPACE SYSAUX LOCAL LOGGING
/

CREATE INDEX SYSTEM.LOGMNRC_I2INDGG
    ON SYSTEM.LOGMNRC_IND_GG (logmnr_uid, drop_scn)
    TABLESPACE SYSAUX LOCAL LOGGING
/

Rem 
Rem LOGMNRC_INDCOL_GG would contain the column information of the indexes
Rem pushed into LOGMNRC_IND_GG.
Rem
 
CREATE TABLE SYSTEM.LOGMNRC_INDCOL_GG (
                   LOGMNR_UID NUMBER NOT NULL,
                   OBJ#       NUMBER NOT NULL,
                   COMMIT_SCN NUMBER NOT NULL,
                   INTCOL#    NUMBER NOT NULL,
                   POS#       NUMBER NOT NULL,
                   SPARE1 NUMBER,
                   SPARE2 NUMBER,
                   SPARE3 VARCHAR2(4000),
                   constraint logmnrc_indcol_gg_pk
                    primary key(logmnr_uid, obj#, commit_scn, intcol#)
                    using index local
              ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
              TABLESPACE SYSAUX LOGGING
/

CREATE TABLE SYSTEM.LOGMNRC_GSII(
                   LOGMNR_UID                NUMBER NOT NULL,
                   OBJ#                      NUMBER NOT NULL,
                   BO#                       NUMBER NOT NULL,
                   INDTYPE#                  NUMBER NOT NULL,
                   DROP_SCN                  NUMBER,
                   LOGMNR_SPARE1             NUMBER,
                   LOGMNR_SPARE2             NUMBER,
                   LOGMNR_SPARE3             VARCHAR2(1000),
                   LOGMNR_SPARE4             DATE,
                     constraint logmnrc_gsii_pk primary key(logmnr_uid, obj#)
                                 using index local
                  ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
                    TABLESPACE SYSAUX LOGGING
/
CREATE TABLE SYSTEM.LOGMNRC_GSBA(
                   LOGMNR_UID                NUMBER NOT NULL,
                   AS_OF_SCN                 NUMBER NOT NULL,
                   FDO_LENGTH                NUMBER,
                   FDO_VALUE                 RAW(255),
                   CHARSETID                 NUMBER,
                   NCHARSETID                NUMBER,
                   DBTIMEZONE_LEN            NUMBER,
                   DBTIMEZONE_VALUE          VARCHAR2(64),
                   LOGMNR_SPARE1             NUMBER,
                   LOGMNR_SPARE2             NUMBER,
                   LOGMNR_SPARE3             VARCHAR2(1000),
                   LOGMNR_SPARE4             DATE,
                     constraint logmnrc_gsba_pk 
                       primary key(logmnr_uid, as_of_scn)
                                 using index local
                  ) PARTITION BY RANGE(logmnr_uid)
                     ( PARTITION p_lessthan100 VALUES LESS THAN (100))
                    TABLESPACE SYSAUX LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_SEED$ (
      SEED_VERSION NUMBER(22),
      GATHER_VERSION NUMBER(22),
      SCHEMANAME VARCHAR2(30),
      OBJ# NUMBER,
      OBJV# NUMBER(22),
      TABLE_NAME VARCHAR2(30),
      COL_NAME VARCHAR2(30),
      COL# NUMBER,
      INTCOL# NUMBER,
      SEGCOL# NUMBER,
      TYPE# NUMBER,
      LENGTH NUMBER,
      PRECISION# NUMBER,
      SCALE NUMBER,
      NULL$ NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_SEED$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1SEED$ 
    ON SYSTEM.LOGMNR_SEED$ (LOGMNR_UID, OBJ#, INTCOL#)
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2SEED$ 
    ON SYSTEM.LOGMNR_SEED$ (logmnr_uid, schemaname, table_name,
                     col_name, obj#, intcol#)
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_DICTIONARY$ (
      DB_NAME VARCHAR2(9),
      DB_ID NUMBER(20),
      DB_CREATED VARCHAR2(20),
      DB_DICT_CREATED VARCHAR2(20),
      DB_DICT_SCN NUMBER(22),
      DB_THREAD_MAP RAW(8),
      DB_TXN_SCNBAS NUMBER(22),
      DB_TXN_SCNWRP NUMBER(22),
      DB_RESETLOGS_CHANGE# NUMBER(22),
      DB_RESETLOGS_TIME VARCHAR2(20),
      DB_VERSION_TIME VARCHAR2(20),
      DB_REDO_TYPE_ID VARCHAR2(8),
      DB_REDO_RELEASE VARCHAR2(60),
      DB_CHARACTER_SET VARCHAR2(30),
      DB_VERSION VARCHAR2(64),
      DB_STATUS VARCHAR2(64),
      DB_GLOBAL_NAME VARCHAR(128),
      DB_DICT_MAXOBJECTS NUMBER(22),
      DB_DICT_OBJECTCOUNT NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_DICTIONARY$_pk primary key (LOGMNR_UID) disable  ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1DICTIONARY$ 
    ON SYSTEM.LOGMNR_DICTIONARY$ (LOGMNR_UID)
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_OBJ$ (
      OBJV# NUMBER(22),
      OWNER# NUMBER(22),
      NAME VARCHAR2(30),
      NAMESPACE NUMBER(22),
      SUBNAME VARCHAR2(30),
      TYPE# NUMBER(22),
      OID$  RAW(16),
      REMOTEOWNER VARCHAR2(30),
      LINKNAME VARCHAR(128),
      FLAGS NUMBER(22),
      SPARE3 NUMBER(22),
      STIME DATE,
      OBJ# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      START_SCNBAS NUMBER,
      START_SCNWRP NUMBER,
      constraint LOGMNR_OBJ$_pk primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1OBJ$ 
    ON SYSTEM.LOGMNR_OBJ$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2OBJ$ 
    ON SYSTEM.LOGMNR_OBJ$ (logmnr_uid, oid$) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TAB$ (
      TS# NUMBER(22),
      COLS NUMBER(22),
      PROPERTY NUMBER(22),
      INTCOLS NUMBER(22),
      KERNELCOLS NUMBER(22),
      BOBJ# NUMBER(22),
      TRIGFLAG NUMBER(22),
      FLAGS NUMBER(22),
      OBJ# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TAB$_pk primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TAB$ 
    ON SYSTEM.LOGMNR_TAB$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2TAB$ 
    ON SYSTEM.LOGMNR_TAB$ (logmnr_uid, bobj#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_COL$ (
      COL# NUMBER(22),
      SEGCOL# NUMBER(22),
      NAME VARCHAR2(30),
      TYPE# NUMBER(22),
      LENGTH NUMBER(22),
      PRECISION# NUMBER(22),
      SCALE NUMBER(22),
      NULL$ NUMBER(22),
      INTCOL# NUMBER(22),
      PROPERTY NUMBER(22),
      CHARSETID NUMBER(22),
      CHARSETFORM NUMBER(22),
      SPARE1 NUMBER(22),
      SPARE2 NUMBER(22),
      OBJ# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_COL$_pk 
        primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1COL$ 
    ON SYSTEM.LOGMNR_COL$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2COL$ 
    ON SYSTEM.LOGMNR_COL$ (logmnr_uid, obj#, name) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I3COL$ 
    ON SYSTEM.LOGMNR_COL$ (logmnr_uid, obj#, col#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_ATTRCOL$ (
      INTCOL#   number,
      NAME      varchar2(4000),
      OBJ#      number NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_ATTRCOL$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1ATTRCOL$
    ON SYSTEM.LOGMNR_ATTRCOL$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TS$ (
      TS# NUMBER(22),
      NAME VARCHAR2(30),
      OWNER# NUMBER(22),
      BLOCKSIZE NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TS$_pk primary key (LOGMNR_UID, TS#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TS$ 
    ON SYSTEM.LOGMNR_TS$ (LOGMNR_UID, TS#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_IND$ (
     BO#     NUMBER(22),
     COLS     NUMBER(22),
     TYPE#    NUMBER(22),
     FLAGS    NUMBER,
     PROPERTY NUMBER,
     OBJ#     NUMBER(22) NOT NULL,
     logmnr_uid NUMBER(22),
     logmnr_flags NUMBER(22),
     constraint LOGMNR_IND$_pk primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1IND$
    ON SYSTEM.LOGMNR_IND$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2IND$
    ON SYSTEM.LOGMNR_IND$ (LOGMNR_UID, BO#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_USER$ (
      USER# NUMBER(22),
      NAME VARCHAR2(30) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_USER$_pk primary key (LOGMNR_UID, USER#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1USER$ 
    ON SYSTEM.LOGMNR_USER$ (LOGMNR_UID, USER#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TABPART$ (
      OBJ# NUMBER(22),
      TS# NUMBER(22),
      PART# NUMBER,
      BO# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TABPART$_pk 
         primary key (LOGMNR_UID, OBJ#, BO#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TABPART$
    ON SYSTEM.LOGMNR_TABPART$ (LOGMNR_UID, OBJ#, BO#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2TABPART$
    ON SYSTEM.LOGMNR_TABPART$ (logmnr_uid, bo#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TABSUBPART$ (
      OBJ# NUMBER(22),
      DATAOBJ# NUMBER(22),
      POBJ# NUMBER(22),
      SUBPART# NUMBER(22),
      TS# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TABSUBPART$_pk 
         primary key (LOGMNR_UID, OBJ#, POBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TABSUBPART$
    ON SYSTEM.LOGMNR_TABSUBPART$ (LOGMNR_UID, OBJ#, POBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2TABSUBPART$
    ON SYSTEM.LOGMNR_TABSUBPART$ (logmnr_uid, pobj#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TABCOMPART$ (
      OBJ# NUMBER(22),
      BO# NUMBER(22),
      PART# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TABCOMPART$_pk 
         primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TABCOMPART$
    ON SYSTEM.LOGMNR_TABCOMPART$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2TABCOMPART$
    ON SYSTEM.LOGMNR_TABCOMPART$ (logmnr_uid, bo#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_TYPE$ (
      version# number,
      version varchar2(30),
      tvoid raw(16),
      typecode number,
      properties number,
      attributes number,
      methods number,
      hiddenMethods number,
      supertypes number,
      subtypes number,
      externtype number,
      externname varchar2(4000),
      helperclassname varchar2(4000),
      local_attrs number,
      local_methods number,
      typeid raw(16),
      roottoid raw(16),
      spare1 number,
      spare2 number,
      spare3 number,
      supertoid raw(16),
      hashcode raw(17),
      toid raw(16) not null,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_TYPE$_pk 
         primary key (LOGMNR_UID, TOID, VERSION#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1TYPE$
    ON SYSTEM.LOGMNR_TYPE$ (LOGMNR_UID, TOID, VERSION#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_COLTYPE$ (
      col# number,
      intcol# number,
      toid raw(16),
      version# number,
      packed number,
      intcols number,
      intcol#s raw(2000),
      flags number,
      typidcol# number,
      synobj# number,
      obj# number not null,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_COLTYPE$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1COLTYPE$
    ON SYSTEM.LOGMNR_COLTYPE$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_ATTRIBUTE$ (
      version#      number,
      name          varchar2(30),
      attribute#    number,
      attr_toid     raw(16),
      attr_version# number,
      synobj#       number,
      properties    number,
      charsetid     number,
      charsetform   number,
      length        number,
      precision#    number,
      scale         number,
      externname    varchar2(4000),
      xflags        number,
      spare1        number,
      spare2        number,
      spare3        number,
      spare4        number,
      spare5        number,
      setter        number,
      getter        number,
      toid          raw(16) not null,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_ATTRIBUTE$_pk 
         primary key (LOGMNR_UID, TOID, VERSION#, ATTRIBUTE#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1ATTRIBUTE$
    ON SYSTEM.LOGMNR_ATTRIBUTE$ (LOGMNR_UID, TOID, VERSION#, ATTRIBUTE#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_LOB$ (
      OBJ#          NUMBER,
      INTCOL#       NUMBER,
      COL#          NUMBER,
      LOBJ#         NUMBER,
      CHUNK         NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_LOB$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1LOB$
    ON SYSTEM.LOGMNR_LOB$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_CON$ (
     owner#        number not null,
     name          varchar2(128) not null,
     con#          number not null,
     logmnr_uid    number(22),
     logmnr_flags  number(22),
     start_scnbas  number,
     start_scnwrp  number,
       constraint logmnr_con$_pk 
          primary key (LOGMNR_UID, CON#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1CON$
    ON SYSTEM.LOGMNR_CON$ (LOGMNR_UID, CON#)
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYS.LOGMNRG_CON$ (
     OWNER#        NUMBER NOT NULL,
     NAME          VARCHAR2(128) NOT NULL,
     CON#          NUMBER NOT NULL )
   TABLESPACE SYSTEM LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_CDEF$ (
      CON#          NUMBER,
      COLS          NUMBER,
      TYPE#         NUMBER,
      ROBJ#         NUMBER, 
      RCON#         NUMBER, 
      ENABLED       NUMBER,
      DEFER         NUMBER,
      OBJ#          NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_CDEF$_pk primary key (LOGMNR_UID, CON#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1CDEF$
    ON SYSTEM.LOGMNR_CDEF$ (LOGMNR_UID, CON#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2CDEF$
    ON SYSTEM.LOGMNR_CDEF$ (LOGMNR_UID, ROBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_CCOL$ (
      CON#          NUMBER,
      OBJ#          NUMBER,
      COL#          NUMBER,
      POS#          NUMBER,
      INTCOL#       NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_CCOL$_pk 
         primary key (LOGMNR_UID, CON#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1CCOL$
    ON SYSTEM.LOGMNR_CCOL$ (LOGMNR_UID, CON#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_ICOL$ (
      OBJ#          NUMBER,
      BO#           NUMBER,
      COL#          NUMBER,
      POS#          NUMBER,
      SEGCOL#       NUMBER,
      INTCOL#       NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_ICOL$_pk 
         primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1ICOL$
    ON SYSTEM.LOGMNR_ICOL$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_LOBFRAG$ (
      FRAGOBJ#      NUMBER,
      PARENTOBJ#    NUMBER,
      TABFRAGOBJ#   NUMBER,
      INDFRAGOBJ#   NUMBER,
      FRAG#         NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_LOBFRAG$_pk 
         primary key (LOGMNR_UID, FRAGOBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1LOBFRAG$
    ON SYSTEM.LOGMNR_LOBFRAG$ (LOGMNR_UID, FRAGOBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_INDPART$ (
      OBJ# NUMBER,
      BO#  NUMBER,
      PART# NUMBER,
      TS#  NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_INDPART$_pk 
         primary key (LOGMNR_UID, OBJ#, BO#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1INDPART$
    ON SYSTEM.LOGMNR_INDPART$ (LOGMNR_UID, OBJ#, BO#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2INDPART$
    ON SYSTEM.LOGMNR_INDPART$ (logmnr_uid, bo#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_INDSUBPART$ (
      OBJ# NUMBER(22),
      DATAOBJ# NUMBER(22),
      POBJ# NUMBER(22),
      SUBPART# NUMBER(22),
      TS# NUMBER(22) NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_INDSUBPART$_pk 
         primary key (LOGMNR_UID, OBJ#, POBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1INDSUBPART$
    ON SYSTEM.LOGMNR_INDSUBPART$ (LOGMNR_UID, OBJ#, POBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_INDCOMPART$ (
      OBJ#     NUMBER,
      DATAOBJ# NUMBER,
      BO#      NUMBER,
      PART#    NUMBER NOT NULL,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_INDCOMPART$_pk 
         primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1INDCOMPART$
    ON SYSTEM.LOGMNR_INDCOMPART$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_LOGMNR_BUILDLOG (
       BUILD_DATE VARCHAR2(20),
       DB_TXN_SCNBAS NUMBER,
       DB_TXN_SCNWRP NUMBER,
       CURRENT_BUILD_STATE NUMBER,
       COMPLETION_STATUS NUMBER,
       MARKED_LOG_FILE_LOW_SCN NUMBER,
       INITIAL_XID VARCHAR2(22) NOT NULL,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_LOGMNR_BUILDLOG_pk 
          primary key (LOGMNR_UID, INITIAL_XID) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1LOGMNR_BUILDLOG
    ON SYSTEM.LOGMNR_LOGMNR_BUILDLOG (LOGMNR_UID, INITIAL_XID) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_NTAB$ (
       col# number,
       intcol# number,
       ntab# number,
       name varchar2(4000),
       obj# number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_NTAB$_pk 
          primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1NTAB$
    ON SYSTEM.LOGMNR_NTAB$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I2NTAB$
    ON SYSTEM.LOGMNR_NTAB$ (logmnr_uid, ntab#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_OPQTYPE$ (
       intcol# number not null,
       type number,
       flags number,
       lobcol number,
       objcol number,
       extracol number,
       schemaoid raw(16),
       elemnum number,
       schemaurl varchar2(4000),
       obj# number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_OPQTYPE$_pk 
          primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1OPQTYPE$
    ON SYSTEM.LOGMNR_OPQTYPE$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_SUBCOLTYPE$ (
       intcol# number not null,
       toid raw(16) not null,
       version# number not null,
       intcols number,
       intcol#s raw(2000),
       flags number,
       synobj# number,
       obj# number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_SUBCOLTYPE$_pk 
          primary key (LOGMNR_UID, OBJ#, INTCOL#, TOID) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1SUBCOLTYPE$
    ON SYSTEM.LOGMNR_SUBCOLTYPE$ (LOGMNR_UID, OBJ#, INTCOL#, TOID) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_KOPM$ (
       length number,
       metadata raw(255),
       name varchar2(30) not null,
      logmnr_uid NUMBER(22),
      logmnr_flags NUMBER(22),
      constraint LOGMNR_KOPM$_pk 
         primary key (LOGMNR_UID, NAME) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1KOPM$
    ON SYSTEM.LOGMNR_KOPM$ (LOGMNR_UID, NAME) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_PROPS$ (
       value$ varchar2(4000),
       comment$ varchar2(4000),
       name varchar2(30) not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_PROPS$_pk 
          primary key (LOGMNR_UID, NAME) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1PROPS$
    ON SYSTEM.LOGMNR_PROPS$ (LOGMNR_UID, NAME) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_ENC$ (
       obj# number,
       owner# number,
       encalg number,
       intalg number,
       colklc raw(2000),
       klclen number,
       flag number,
       mkeyid varchar2(64) not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_ENC$_pk 
          primary key (LOGMNR_UID, OBJ#, OWNER#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1ENC$
    ON SYSTEM.LOGMNR_ENC$ (LOGMNR_UID, OBJ#, OWNER#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_REFCON$ (
       col#     number,
       intcol#  number,
       reftyp   number,
       stabid   raw(16),
       expctoid raw(16),
       obj#     number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_REFCON$_pk 
          primary key (LOGMNR_UID, OBJ#, INTCOL#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1REFCON$
    ON SYSTEM.LOGMNR_REFCON$ (LOGMNR_UID, OBJ#, INTCOL#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNR_PARTOBJ$ (
      parttype    number,
       partcnt     number,
       partkeycols number,
       flags       number,
       defts#      number,
       defpctfree  number,
       defpctused  number,
       defpctthres number,
       definitrans number,
       defmaxtrans number,
       deftiniexts number,
       defextsize  number,
       defminexts  number,
       defmaxexts  number,
       defextpct   number,
       deflists    number,
       defgroups   number,
       deflogging  number,
       spare1      number,
       spare2      number,
       spare3      number,
       definclcol  number,
       parameters  varchar2(1000),
       obj#        number not null,
       logmnr_uid NUMBER(22),
       logmnr_flags NUMBER(22),
       constraint LOGMNR_PARTOBJ$_pk 
          primary key (LOGMNR_UID, OBJ#) disable ) 
   PARTITION BY RANGE(logmnr_uid)
      ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
   TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNR_I1PARTOBJ$
    ON SYSTEM.LOGMNR_PARTOBJ$ (LOGMNR_UID, OBJ#) 
    TABLESPACE SYSAUX LOCAL LOGGING
/
CREATE TABLE SYSTEM.LOGMNRP_CTAS_PART_MAP (
                    LOGMNR_UID         NUMBER NOT NULL,
                    BASEOBJ#           NUMBER NOT NULL,
                    BASEOBJV#          NUMBER NOT NULL,  
                    KEYOBJ#            NUMBER NOT NULL,
                    PART#              NUMBER NOT NULL,
                    SPARE1             NUMBER,
                    SPARE2             NUMBER,
                    SPARE3             VARCHAR2(1000),
                    CONSTRAINT LOGMNRP_CTAS_PART_MAP_PK 
                       PRIMARY KEY(LOGMNR_UID, BASEOBJV#, KEYOBJ#) 
                       using index local )
              PARTITION BY RANGE(logmnr_uid)
                 ( PARTITION p_lessthan100 VALUES LESS THAN (100)) 
              TABLESPACE SYSAUX LOGGING
/
CREATE INDEX SYSTEM.LOGMNRP_CTAS_PART_MAP_I ON
                    SYSTEM.LOGMNRP_CTAS_PART_MAP (
                      LOGMNR_UID, BASEOBJ#, BASEOBJV#, PART#)
                    TABLESPACE SYSAUX LOCAL LOGGING
/
alter session set events '14524 trace name context off';

Rem Populate NOEXP$ to ensure logminer metadata is not exported.
INSERT INTO sys.noexp$
             SELECT u.name, o.name, o.type#
             FROM sys.obj$ o, sys.user$ u
             WHERE (o.type# = 2 or o.type# = 6) AND
                   o.owner# = u.user# AND
                   u.name = 'SYSTEM' AND
                   o.name like 'LOGMNR%'
           MINUS
             SELECT x.owner, x.name, x.obj_type
             FROM sys.noexp$ x;
commit;

Rem Create or Replace Logminer Views


Rem The following is needed for some of the grants on these views
grant select any table to sys with admin option;


-- This function returns the maximum valid checkpoint 
--  for a given session.  Only valid for streams 
-- sessions and used by the dba_logmnr_session view
create or replace FUNCTION get_max_checkpoint(sessionnum IN NUMBER) 
                      RETURN number IS
                        ckpt number;
                      BEGIN
                        select ckpt_scn into ckpt
                        from 
                          (select c.ckpt_scn ckpt_scn
                          from system.logmnr_restart_ckpt$ c
                          where c.session# = sessionnum and 
                                c.valid = 1 order by ckpt_scn desc)
                        where rownum = 1 ;
                        return ckpt;
                      END get_max_checkpoint;
/
    
create or replace view dba_logmnr_log as
                select
                  l.session#                    logmnr_session_id,
                  l.file_name                   name,
                  l.db_id                       dbid,
                  l.resetlogs_change#           resetlogs_scn,
                  l.reset_timestamp             resetlogs_time,
                  l.timestamp                   modified_time,            
                  l.thread#                     thread#,
                  l.sequence#                   sequence#,
                  l.first_change#               first_scn,
                  l.next_change#                next_scn,
                  l.first_time                  first_time,
                  l.next_time                   next_time,
                  l.dict_begin                  dictionary_begin,
                  l.dict_end                    dictionary_end,
                  case 
                  when (bitand(l.status, 2) = 2) then
                   'NO'
                  else
                   'YES'
                  end                           keep,
                  case  
                  when (bitand(l.status, 4) = 4) then
                   'YES'
                  else
                   'NO'
                  end                           suspect
                from system.logmnr_log$ l 
                where bitand(l.flags, 16) != 16; 

create or replace public synonym dba_logmnr_log for dba_logmnr_log;
grant select on dba_logmnr_log to select_catalog_role;
  
create or replace view dba_logmnr_session as
      select 
        s.session#              id,
        s.session_name          name,
        s.global_db_name        source_database,
        s.db_id                 source_dbid,
        s.resetlogs_change#     source_resetlogs_scn,
        s.reset_timestamp       source_resetlogs_time,
        s.start_scn             first_scn,
        s.end_scn               end_scn,
        s.branch_scn            branch_scn,
        case
         when (bitand(s.session_attr, 16) = 16) then 'YES'
         else  'NO'
        end                     wait_for_log,
        case
          when (bitand(s.session_attr, 8388608) = 8388608) then 'YES'
         else  'NO'
        end                     hot_mine,
        /* safe_purge_scn is the scn below or at which it is safe to purge */
        /* pass this scn into dbms_logmnr_session.purge_session */
        case /* case#0 :streams or logical standby */
             /* KRVX_RESTART_CKPT_ENABLED = 268435456 */ 
          when (bitand(s.session_attr, 268435456) = 268435456) then
            null
          else /* case #0 */
            s.spill_scn 
          end    /* case #0 */        
                                      safe_purge_scn,         
        case /* case#0 :streams or logical standby */
          when (bitand(s.session_attr, 268435456) = 268435456) then     
            get_max_checkpoint(s.session#)
          else
            null
          end
                                        checkpoint_scn
      from system.logmnr_session$ s;
create or replace public synonym dba_logmnr_session for dba_logmnr_session;
grant select on dba_logmnr_session to select_catalog_role;


create or replace view LOGMNR_TAB_COLS_SUPPORT
    (logmnr_uid, obj#, owner#, OWNER, TABLE_NAME,
     COLUMN_NAME, type#, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     CHAR_USED,
     V80_FMT_IMAGE, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID,  QUALIFIED_COL_NAME)
     as
      select o.logmnr_uid, o.obj#, o.owner#, u.name, o.name,
       c.name, c.type#,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#,
                                (select o.name from system.logmnr_obj$ o
                                 where o.logmnr_uid = c.logmnr_uid and
                                 o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#,
                                (select o.name from system.logmnr_obj$ o
                                 where o.logmnr_uid = c.logmnr_uid and
                                 o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#,
                                (select o.name from system.logmnr_obj$ o
                                 where o.logmnr_uid = c.logmnr_uid and
                                 o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#,
                                (select o.name from system.logmnr_obj$ o
                                 where o.logmnr_uid = c.logmnr_uid and
                                 o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#,
                                (select o.name from system.logmnr_obj$ o
                                 where o.logmnr_uid = c.logmnr_uid and
                                 o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#,
              (select u.name 
               from system.logmnr_user$ u, system.logmnr_obj$ o
               where o.owner#=u.user# and o.obj#=ac.synobj#
                 and u.logmnr_uid = c.logmnr_uid
                 and o.logmnr_uid = c.logmnr_uid),
             ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), 
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from system.logmnr_col$ cl, system.logmnr_attrcol$ rc
               where cl.intcol# = c.intcol#-1
               and cl.logmnr_uid = c.logmnr_uid
               and rc.logmnr_uid = c.logmnr_uid
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from system.logmnr_attrcol$ tc
                      where tc.logmnr_uid = c.logmnr_uid and
                            c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from system.logmnr_col$ c, system.logmnr_obj$ o, system.logmnr_user$ u,
     system.logmnr_coltype$ ac, system.logmnr_obj$ ot, system.logmnr_user$ ut
where o.obj# = c.obj#
  and o.owner# = u.user#
  and o.logmnr_uid = c.logmnr_uid
  and o.logmnr_uid = u.logmnr_uid
  and c.logmnr_uid = ac.logmnr_uid(+)
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.logmnr_uid = ot.logmnr_uid(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.logmnr_uid = ut.logmnr_uid(+)
  and ot.owner# = ut.user#(+)
  and (o.type# in (3, 4)                                     /* cluster, view */
       or
       (o.type# = 2     /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from system.logmnr_tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))));


create or replace view LOGMNR_TAB_COLS_CAT_SUPPORT
    (obj#, owner#, OWNER, TABLE_NAME,
     COLUMN_NAME, type#, DATA_TYPE, DATA_TYPE_MOD, DATA_TYPE_OWNER,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, NULLABLE, COLUMN_ID,
     CHARACTER_SET_NAME, CHAR_COL_DECL_LENGTH,
     CHAR_USED,
     V80_FMT_IMAGE, HIDDEN_COLUMN, VIRTUAL_COLUMN,
     SEGMENT_COLUMN_ID, INTERNAL_COLUMN_ID,  QUALIFIED_COL_NAME)
     as
      select o.obj#, o.owner#, u.name, o.name,
       c.name, c.type#,
       decode(c.type#, 1, decode(c.charsetform, 2, 'NVARCHAR2', 'VARCHAR2'),
                       2, decode(c.scale, null,
                                 decode(c.precision#, null, 'NUMBER', 'FLOAT'),
                                 'NUMBER'),
                       8, 'LONG',
                       9, decode(c.charsetform, 2, 'NCHAR VARYING', 'VARCHAR'),
                       12, 'DATE',
                       23, 'RAW', 24, 'LONG RAW',
                       58, nvl2(ac.synobj#,
                                (select o.name from sys.obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       69, 'ROWID',
                       96, decode(c.charsetform, 2, 'NCHAR', 'CHAR'),
                       100, 'BINARY_FLOAT',
                       101, 'BINARY_DOUBLE',
                       105, 'MLSLABEL',
                       106, 'MLSLABEL',
                       111, nvl2(ac.synobj#,
                                (select o.name from sys.obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       112, decode(c.charsetform, 2, 'NCLOB', 'CLOB'),
                       113, 'BLOB', 114, 'BFILE', 115, 'CFILE',
                       121, nvl2(ac.synobj#,
                                (select o.name from sys.obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       122, nvl2(ac.synobj#,
                                (select o.name from sys.obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       123, nvl2(ac.synobj#,
                                (select o.name from sys.obj$ o
                                 where o.obj#=ac.synobj#), ot.name),
                       178, 'TIME(' ||c.scale|| ')',
                       179, 'TIME(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       180, 'TIMESTAMP(' ||c.scale|| ')',
                       181, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH TIME ZONE',
                       231, 'TIMESTAMP(' ||c.scale|| ')' || ' WITH LOCAL TIME ZONE',
                       182, 'INTERVAL YEAR(' ||c.precision#||') TO MONTH',
                       183, 'INTERVAL DAY(' ||c.precision#||') TO SECOND(' ||
                             c.scale || ')',
                       208, 'UROWID',
                       'UNDEFINED'),
       decode(c.type#, 111, 'REF'),
       nvl2(ac.synobj#,
              (select u.name 
               from sys.user$ u, sys.obj$ o
               where o.owner#=u.user# and o.obj#=ac.synobj#),
             ut.name),
       c.length, c.precision#, c.scale,
       decode(sign(c.null$),-1,'D', 0, 'Y', 'N'),
       decode(c.col#, 0, to_number(null), c.col#), 
       decode(c.charsetform, 1, 'CHAR_CS',
                             2, 'NCHAR_CS',
                             3, NLS_CHARSET_NAME(c.charsetid),
                             4, 'ARG:'||c.charsetid),
       decode(c.charsetid, 0, to_number(NULL),
                           nls_charset_decl_len(c.length, c.charsetid)),
       decode(c.type#, 1, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      96, decode(bitand(c.property, 8388608), 0, 'B', 'C'),
                      null),
       decode(bitand(ac.flags, 128), 128, 'YES', 'NO'),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 32), 32, 'YES',
                                          'NO')),
       decode(c.property, 0, 'NO', decode(bitand(c.property, 8), 8, 'YES',
                                          'NO')),
       decode(c.segcol#, 0, to_number(null), c.segcol#), c.intcol#,
       decode(bitand(c.property, 1024), 1024,
              (select decode(bitand(cl.property, 1), 1, rc.name, cl.name)
               from sys.col$ cl, sys.attrcol$ rc
               where cl.intcol# = c.intcol#-1
               and cl.obj# = c.obj# and c.obj# = rc.obj#(+) and
               cl.intcol# = rc.intcol#(+)),
              decode(bitand(c.property, 1), 0, c.name,
                     (select tc.name from sys.attrcol$ tc
                      where c.obj# = tc.obj# and c.intcol# = tc.intcol#)))
from sys.col$ c, sys.obj$ o, sys.user$ u,
     sys.coltype$ ac, sys.obj$ ot, sys.user$ ut
where o.obj# = c.obj#
  and o.owner# = u.user#
  and c.obj# = ac.obj#(+) and c.intcol# = ac.intcol#(+)
  and ac.toid = ot.oid$(+)
  and ot.type#(+) = 13
  and ot.owner# = ut.user#(+)
  and (o.type# in (3, 4)                                    /* cluster, view */
       or
       (o.type# = 2    /* tables, excluding iot - overflow and nested tables */
        and
        not exists (select null
                      from sys.tab$ t
                     where t.obj# = o.obj#
                       and (bitand(t.property, 512) = 512 or
                            bitand(t.property, 8192) = 8192))));


create or replace view LOGMNR_GTCS_SUPPORT
    (logmnr_uid,
     obj#,
     objv#,
     segcol#,
     intcol#,
     col#,
     colname,
     type#,
     length,
     precision,
     scale,
     interval_leading_precision,
     interval_trailing_precision,
     property,
     charsetid,
     charsetform,
     logmnrcolflags,
     XTypeSchemaName,
     XTypeName,
     XFQColName,
     XTopIntCol,
     XReffedTableObjn,
     XReffedTableObjv,
     XColTypeFlags,
     XOpqTypeType,
     XOpqTypeFlags,
     XOpqLobIntcol,
     XOpqObjIntcol,
     XXMLIntCol,
     EaOwner#,
     EaMKeyId,
     EaEncAlg,
     EaIntAlg,
     EaColKlc,
     EaKLcLen,
     EaFlags
             )
as
select
         o.logmnr_uid,
         o.obj#,
         o.objv#,
         lc.segcol#,
         lc.intcol#,
         lc.col#,
         lc.name,
         lc.type#,
         lc.length,
         lc.precision#,
         lc.scale,
         lc.spare2,  /* INTERVAL_LEADING_PRECISION */
         lc.spare1,  /* INTERVAL_TRAILING_PRECISION */
         lc.property,
         lc.charsetid,
         lc.charsetform,
         NULL LogmnrColFlags,   /* THIS IS BEING SET IN C */
         case lc.type# 
              when 1 /* DTYCHR */ then NULL  /* shortcut for most common */
              when 2 /* DTYNUM */ then NULL
              when 12 /* DTYDAT */ then NULL
              when 58 /* DTYOPQ - XMLType, ANYDATA, etc. */ then
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 121 /* DTYADT */ then
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 122 /* DTYNTB */ then
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 123 /* DTYNAR */ then
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 111 /* DTYIREF */ then  /* needed?  copied from  dba_tab_cols */
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
           else NULL end XTypeSchemaName,
         case lc.type# 
              when 1 /* DTYCHR */ then NULL  /* shortcut for most common */
              when 2 /* DTYNUM */ then NULL
              when 12 /* DTYDAT */ then NULL
              when 58 /* DTYOPQ - XMLTYPE, ANYDATA, etc. */ then
               (select lv.data_type
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 121 /* DTYADT */ then
               (select lv.data_type
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 122 /* DTYNTB */ then
               (select lv.data_type
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 123 /* DTYNAR */ then
               (select lv.data_type
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 111 /* DTYIREF */ then  /* needed?  copied from  dba_tab_cols */
               (select lv.data_type
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
           else NULL end XTypeName,
         case bitand(lc.property, 1029) 
              when 0 then
               null
              when 1 then
               (select lv.qualified_col_name
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 5 then
               (select lv.qualified_col_name
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 4 then
               (select lv.qualified_col_name
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 1024 then
               (select lv.qualified_col_name
                 from sys.logmnr_tab_cols_support lv
                 where lv.logmnr_uid = o.logmnr_uid and
                       lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
            else NULL end XFQColName,
         /* topintcol */
         case when (bitand(lt.property,1) = 0)  /* typed table bit not set */
            then /* relational table */
                 /* most columns are not hidden and thus do not have */
                 /* an associated topintcol.  Certain special columns */
                 /* where col# = 0 also do not have topintcol */
               case when
                    (bitand(lc.property,32) = 0) or  /* not hidden column */
                    (lc.col# = 0)then                /* special column */
                  NULL /* do not set topintcol */
               else /* it is hidden and is not col# = 0 (ie special) */
                    /* so find the covering user visible column */
                    (select min(sc.intcol#) /* min for speedup only */
                     from system.logmnr_col$ sc
                     where sc.logmnr_uid = o.logmnr_uid and
                           sc.obj# = lc.obj# and
                           sc.col# = lc.col# and
                           bitand(sc.property,1) = 0 and /*not an attribute*/
                           bitand(sc.property, 32) = 0)  /* not hidden */
               end
         else /* typed table */
              /* everything gets rowinfo$ column as topintcol except */
              /* for the rowinfo$ itself, and the oid */
            case when
                 (bitand(lc.property,2) = 0) and    /* not an oid */
                 (bitand(lc.property,512) = 0) then /* not rowinfo$ */
               (select min(sc.intcol#) /* min for speedup only */
                  from system.logmnr_col$ sc
                 where sc.logmnr_uid = o.logmnr_uid and 
                       sc.obj# = lc.obj# and
                       bitand(sc.property, 512) = 512) /* rowinfo col */
            else NULL end  /* oid/rowinfo, leave topintcol null */
         end XTopIntCol,
         case LC.TYPE# when 111 /* DTYIREF */ then
               (select oo.obj#
                from system.logmnr_obj$ oo, system.logmnr_refcon$ r
                where oo.logmnr_uid = o.logmnr_uid and
                      r.logmnr_uid = o.logmnr_uid and
                      oo.oid$ = r.stabid and
                      r.intcol# = lc.intcol# and 
                      r.obj# = o.obj#) 
             else NULL end XReffedTableObjn,
         case LC.TYPE# when 111 /* DTYIREF */ then
               (select oo.objv#
                from system.logmnr_obj$ oo, system.logmnr_refcon$ r
                where oo.logmnr_uid = o.logmnr_uid and
                      r.logmnr_uid = o.logmnr_uid and
                      oo.oid$ = r.stabid and
                      r.intcol# = lc.intcol# and 
                      r.obj# = o.obj#)
             else NULL end XReffedTableObjv,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ct.flags 
               from system.logmnr_coltype$ ct
               where ct.logmnr_uid = o.logmnr_uid and ct.obj# = o.obj# and
                     ct.intcol# = lc.INTCOL#)
            else NULL end XColTypeFlags,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ot.type
               from system.logmnr_opqtype$ ot
               where ot.logmnr_uid = o.logmnr_uid and ot.obj# = o.obj# and
                     ot.intcol# = lc.intcol#)
            else NULL end XOpqTypeType,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ot.flags
               from system.logmnr_opqtype$ ot
               where ot.logmnr_uid = o.logmnr_uid and ot.obj# = o.obj# and
                     ot.intcol# = lc.intcol#)
            else NULL end XOpqTypeFlags,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ot.lobcol
               from system.logmnr_opqtype$ ot
               where ot.logmnr_uid = o.logmnr_uid and ot.obj# = o.obj# and
                     ot.intcol# = lc.intcol#)
            else NULL end XOpqLobIntcol,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ot.objcol
               from system.logmnr_opqtype$ ot
               where ot.logmnr_uid = o.logmnr_uid and ot.obj# = o.obj# and
                     ot.intcol# = lc.intcol#)
            else NULL end XOpqObjIntcol,
         /* xmlintcol */
         case when (bitand(lt.property,1) = 0)  /* typed table bit not set */
            then /* relational table */
                 /* most columns are not hidden and thus do not have */
                 /* an associated topintcol/xmlintocol. */
               case when
                    (bitand(lc.property,32) = 0) then  /* not hidden column */
                  NULL /* do not set XMLintcol */
               else /* it is hidden and is not col# = 0 (ie special) */
                    /* so find the covering user visible column */
                    /* if it is not XML, then we want/get NULL */
                    (select min(sc.intcol#)
                     from system.logmnr_col$ sc, system.logmnr_opqtype$ opq
                     where sc.logmnr_uid = o.logmnr_uid and
                           opq.logmnr_uid = o.logmnr_uid and
                           sc.obj# = lc.obj# and        /* same obj# */
                           opq.obj# = lc.obj# and       /* same obj# */
                           sc.col# = lc.col# and        /* same col# */
                           sc.intcol# = opq.intcol# and
                           bitand(sc.property,1) = 0 and /*not an attribute*/
                           sc.type# = 58 and              /* opaque type */
                           opq.type = 1)                  /* XML */
               end
         else /* typed table */
               (select min(sc.intcol#)  /* NULL if topintocl is not XML */
                from system.logmnr_col$ sc, system.logmnr_opqtype$ opq
                where sc.logmnr_uid = o.logmnr_uid and sc.obj# = lc.obj# and
                      opq.logmnr_uid = o.logmnr_uid and opq.obj# = lc.obj# and
                      opq.intcol# = sc.intcol# and
                      bitand(sc.property, 512) = 512 and /* rowinfo col */
                      sc.type# = 58 and  /* opaque type */
                      opq.type = 1)    /* XML */
            end XXMLIntCol,
         case when (bitand(lc.property, 67108864) = 67108864) /* encrypt col */
           then 
         (select ea.owner#
               from system.logmnr_enc$ ea
               where ea.logmnr_uid = o.logmnr_uid and ea.obj# = o.obj#)
             else NULL end EaOwner#,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select ea.mkeyid
               from system.logmnr_enc$ ea
               where ea.logmnr_uid = o.logmnr_uid and ea.obj# = o.obj#)
             else NULL end EaMKeyId,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select ea.encalg
               from system.logmnr_enc$ ea
               where ea.logmnr_uid = o.logmnr_uid and ea.obj# = o.obj#)
             else NULL end EaEncAlg,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select ea.intalg
               from system.logmnr_enc$ ea
               where ea.logmnr_uid = o.logmnr_uid and ea.obj# = o.obj#)
             else NULL end EaIntAlg,
         case when (bitand(lc.property, 67108864) = 67108864)
           then 
         (select ea.colklc
               from system.logmnr_enc$ ea
               where ea.logmnr_uid = o.logmnr_uid and ea.obj# = o.obj#)
             else NULL end EaColKlc,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select ea.klclen
               from system.logmnr_enc$ ea
               where ea.logmnr_uid = o.logmnr_uid and ea.obj# = o.obj#)
             else NULL end EaKLcLen,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select nvl(ea.flag,0)
               from system.logmnr_enc$ ea
               where ea.logmnr_uid = o.logmnr_uid and ea.obj# = o.obj#)
             else NULL end EaFlags
       from
         system.logmnr_col$ lc, system.logmnr_tab$ lt, system.logmnr_obj$ o
       where 
         o.logmnr_uid = lc.logmnr_uid AND
         o.logmnr_uid = lt.logmnr_uid AND
         o.obj# = lt.obj# AND
         o.obj# = lc.obj#
       order by lc.logmnr_uid, o.obj#, lc.intcol#;


create or replace view LOGMNR_GTCS_CAT_SUPPORT
    (logmnr_uid,
     obj#,
     objv#,
     segcol#,
     intcol#,
     col#,
     colname,
     type#,
     length,
     precision,
     scale,
     interval_leading_precision,
     interval_trailing_precision,
     property,
     charsetid,
     charsetform,
     logmnrcolflags,
     XTypeSchemaName,
     XTypeName,
     XFQColName,
     XTopIntCol,
     XReffedTableObjn,
     XReffedTableObjv,
     XColTypeFlags,
     XOpqTypeType,
     XOpqTypeFlags,
     XOpqLobIntcol,
     XOpqObjIntcol,
     XXMLIntCol,
     EaOwner#,
     EaMKeyId,
     EaEncAlg,
     EaIntAlg,
     EaColKlc,
     EaKLcLen,
     EaFlags
             )
as
select
         0 as logmnr_uid,
         o.obj#,
         o.spare2,
         lc.segcol#,
         lc.intcol#,
         lc.col#,
         lc.name,
         lc.type#,
         lc.length,
         lc.precision#,
         lc.scale,
         lc.spare2,  /* INTERVAL_LEADING_PRECISION */
         lc.spare1,  /* INTERVAL_TRAILING_PRECISION */
         lc.property,
         lc.charsetid,
         lc.charsetform,
         NULL LogmnrColFlags,   /* THIS IS BEING SET IN C */
         case lc.type# 
              when 1 /* DTYCHR */ then NULL  /* shortcut for most common */
              when 2 /* DTYNUM */ then NULL
              when 12 /* DTYDAT */ then NULL
              when 58 /* DTYOPQ - XMLType, ANYDATA, etc. */ then
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 121 /* DTYADT */ then
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 122 /* DTYNTB */ then
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 123 /* DTYNAR */ then
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 111 /* DTYIREF */ then  /* needed?  copied from  dba_tab_cols */
               (select lv.data_type_owner
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
           else NULL end XTypeSchemaName,
         case lc.type# 
              when 1 /* DTYCHR */ then NULL  /* shortcut for most common */
              when 2 /* DTYNUM */ then NULL
              when 12 /* DTYDAT */ then NULL
              when 58 /* DTYOPQ - XMLType, ANYDATA, etc. */ then
               (select lv.data_type
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 121 /* DTYADT */ then
               (select lv.data_type
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 122 /* DTYNTB */ then
               (select lv.data_type
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 123 /* DTYNAR */ then
               (select lv.data_type
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 111 /* DTYIREF */ then  /* needed?  copied from  dba_tab_cols */
               (select lv.data_type
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
           else NULL end XTypeName,
         case bitand(lc.property, 1029) 
              when 0 then
               null
              when 1 then
               (select lv.qualified_col_name
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 5 then
               (select lv.qualified_col_name
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 4 then
               (select lv.qualified_col_name
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
              when 1024 then
               (select lv.qualified_col_name
                 from sys.logmnr_tab_cols_cat_support lv
                 where lv.obj# = lc.obj# and
                       lv.internal_column_id = lc.intcol#)
            else NULL end XFQColName,
         /* topintcol */
         case when (bitand(lt.property,1) = 0)  /* typed table bit not set */
            then /* relational table */
                 /* most columns are not hidden and thus do not have */
                 /* an associated topintcol.  Certain special columns */
                 /* where col# = 0 also do not have topintcol */
               case when
                    (bitand(lc.property,32) = 0) or  /* not hidden column */
                    (lc.col# = 0)then                /* special column */
                  NULL /* do not set topintcol */
               else /* it is hidden and is not col# = 0 (ie special) */
                    /* so find the covering user visible column */
                    (select min(sc.intcol#) /* min for speedup only */
                     from sys.col$ sc
                     where sc.obj# = lc.obj# and
                           sc.col# = lc.col# and
                           bitand(sc.property,1) = 0 and /*not an attribute*/
                           bitand(sc.property, 32) = 0)  /* not hidden */
               end
         else /* typed table */
              /* everything gets rowinfo$ column as topintcol except */
              /* for the rowinfo$ itself, and the oid */
            case when
                 (bitand(lc.property,2) = 0) and    /* not an oid */
                 (bitand(lc.property,512) = 0) then /* not rowinfo$ */
               (select min(sc.intcol#) /* min for speedup only */
                  from sys.col$ sc
                 where sc.obj# = lc.obj# and
                       bitand(sc.property, 512) = 512) /* rowinfo col */
            else NULL end  /* oid/rowinfo, leave topintcol null */
         end XTopIntCol,
         case LC.TYPE# when 111 /* DTYIREF */ then
               (select oo.obj#
                from sys.obj$ oo, sys.refcon$ r
                where oo.oid$ = r.stabid and
                      r.intcol# = lc.intcol# and 
                      r.obj# = o.obj#) 
             else NULL end XReffedTableObjn,
         case LC.TYPE# when 111 /* DTYIREF */ then
               (select oo.spare2
                from sys.obj$ oo, sys.refcon$ r
                where oo.oid$ = r.stabid and
                      r.intcol# = lc.intcol# and 
                      r.obj# = o.obj#)
             else NULL end XReffedTableObjv,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ct.flags 
               from sys.coltype$ ct
               where ct.obj# = o.obj# and
                     ct.intcol# = lc.INTCOL#)
            else NULL end XColTypeFlags,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ot.type
               from sys.opqtype$ ot
               where ot.obj# = o.obj# and
                     ot.intcol# = lc.intcol#)
            else NULL end XOpqTypeType,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ot.flags
               from sys.opqtype$ ot
               where ot.obj# = o.obj# and
                     ot.intcol# = lc.intcol#)
            else NULL end XOpqTypeFlags,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ot.lobcol
               from sys.opqtype$ ot
               where ot.obj# = o.obj# and
                     ot.intcol# = lc.intcol#)
            else NULL end XOpqLobIntcol,
         case LC.TYPE# when 58 /* DTYOPQ */ then
              (select ot.objcol
               from sys.opqtype$ ot
               where ot.obj# = o.obj# and
                     ot.intcol# = lc.intcol#)
            else NULL end XOpqObjIntcol,
         /* xmlintcol */
         case when (bitand(lt.property,1) = 0)  /* typed table bit not set */
            then /* relational table */
                 /* most columns are not hidden and thus do not have */
                 /* an associated topintcol/xmlintocol. */
               case when
                    (bitand(lc.property,32) = 0) then  /* not hidden column */
                  NULL /* do not set XMLintcol */
               else /* it is hidden and is not col# = 0 (ie special) */
                    /* so find the covering user visible column */
                    /* if it is not XML, then we want/get NULL */
                    (select min(sc.intcol#)
                     from sys.col$ sc, sys.opqtype$ opq
                     where sc.obj# = lc.obj# and        /* same obj# */
                           opq.obj# = lc.obj# and       /* same obj# */
                           sc.col# = lc.col# and        /* same col# */
                           sc.intcol# = opq.intcol# and
                           bitand(sc.property,1) = 0 and /*not an attribute*/
                           sc.type# = 58 and              /* opaque type */
                           opq.type = 1)                  /* XML */
               end
         else /* typed table */
               (select min(sc.intcol#)  /* NULL if topintocl is not XML */
                from sys.col$ sc, sys.opqtype$ opq
                where sc.obj# = lc.obj# and
                      opq.obj# = lc.obj# and
                      opq.intcol# = sc.intcol# and
                      bitand(sc.property, 512) = 512 and /* rowinfo col */
                      sc.type# = 58 and  /* opaque type */
                      opq.type = 1)    /* XML */
            end XXMLIntCol,
         case when (bitand(lc.property, 67108864) = 67108864) /* encrypt col */
           then 
         (select ea.owner#
               from sys.enc$ ea
               where ea.obj# = o.obj#)
             else NULL end EaOwner#,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select ea.mkeyid
               from sys.enc$ ea
               where ea.obj# = o.obj#)
             else NULL end EaMKeyId,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select ea.encalg
               from sys.enc$ ea
               where ea.obj# = o.obj#)
             else NULL end EaEncAlg,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select ea.intalg
               from sys.enc$ ea
               where ea.obj# = o.obj#)
             else NULL end EaIntAlg,
         case when (bitand(lc.property, 67108864) = 67108864)
           then 
         (select ea.colklc
               from sys.enc$ ea
               where ea.obj# = o.obj#)
             else NULL end EaColKlc,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select ea.klclen
               from sys.enc$ ea
               where ea.obj# = o.obj#)
             else NULL end EaKLcLen,
         case when (bitand(lc.property, 67108864) = 67108864) 
           then 
         (select nvl(ea.flag,0)
               from sys.enc$ ea
               where ea.obj# = o.obj#)
             else NULL end EaFlags
       from
         sys.col$ lc, sys.tab$ lt, sys.obj$ o
       where 
         o.obj# = lt.obj# AND
         o.obj# = lc.obj#
       order by o.obj#, lc.intcol#;


-- Create any missing partitions
declare
    type part_typ is record (table_name varchar2(32), 
                             part_name varchar2(32),
                             values_less_than number);
    type part_cur_typ is ref cursor;
    part_cur       part_cur_typ;
    part_rec       part_typ;
    part_query     varchar2(4000);
    alter_stmt     varchar2(4000);
BEGIN 

  part_query :=
    'select case when bitand(x.flags, 2) = 2 
                 then ''LOGMNR_''|| x.name
                 else x.name end table_name,
           ''P''|| TO_CHAR(ui.logmnr_uid) part_name,
           ui.logmnr_uid + 1 values_less_than
       from x$krvxdta x, system.logmnr_uid$ ui
      where bitand(x.flags,1) = 1 
        and not exists (select 1 
                        from obj$ o, user$ usr
                        where o.owner# = usr.user#
                          and usr.name = ''SYSTEM''
                          and o.name = case when bitand(x.flags, 2) = 2 
                                            then ''LOGMNR_''|| x.name
                                            else x.name end
                          and o.subname = ''P''|| TO_CHAR(ui.logmnr_uid)
                          and o.remoteowner is null 
                          and o.linkname is null
                          and o.type# = 19)
   union
     select case when bitand(x.flags, 2) = 2 
                 then ''LOGMNR_''|| x.name
                 else x.name end table_name,
           ''P''|| TO_CHAR(ui.logmnr_uid) part_name,
           ui.logmnr_uid + 1 values_less_than
       from x$krvxdta x, system.logmnrc_dbname_uid_map ui
      where bitand(x.flags,1) = 1 
        and bitand(x.flags,16) = 16 
        and not exists (select 1 
                        from obj$ o, user$ usr
                        where o.owner# = usr.user#
                          and usr.name = ''SYSTEM''
                          and o.name = case when bitand(x.flags, 2) = 2 
                                            then ''LOGMNR_''|| x.name
                                            else x.name end
                          and o.subname = ''P''|| TO_CHAR(ui.logmnr_uid)
                          and o.remoteowner is null 
                          and o.linkname is null
                          and o.type# = 19)
      order by values_less_than asc';
  open part_cur for part_query;
  loop
    fetch part_cur into part_rec;
    exit when part_cur%NOTFOUND;
    alter_stmt := 'alter table system.' || part_rec.table_name || 
                   ' add partition ' || part_rec.part_name ||
                   ' values less than (' || part_rec.values_less_than || 
                   ') logging';
    execute immediate alter_stmt;
    commit;
  end loop;
  close part_cur;
end;
/
