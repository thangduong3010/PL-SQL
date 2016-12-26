Rem
Rem $Header: rdbms/admin/dbmspump.sql /st_rdbms_11.2.0/2 2012/07/17 07:46:55 jstenois Exp $
Rem
Rem dbmspump.sql
Rem
Rem Copyright (c) 2000, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmspump.sql - DBMS procedures for dataPUMP
Rem
Rem    DESCRIPTION
Rem      objects used by datapump
Rem
Rem    NOTES
Rem      none
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jstenois    06/26/12 - Backport jstenois_bug-13725431 from main
Rem    jstenois    03/15/12 - Backport jstenois_bug-5560282 from main
Rem    msakayed    05/29/08 - Remove exec grants on sys.oracle_loader/datapump
Rem    msakayed    04/25/07 - Bug #5119713: Memleak - use "LANGUAGE C" callspec
Rem    hsbedi      07/30/02 - 
Rem    hsbedi      06/29/02 - External table populate
Rem    abrumm      02/05/01 - add 'AUTHID CURRENT_USER' clause
Rem    rphillip    02/08/01 - support DPAPI stream versions
Rem    abrumm      10/11/00 - use ODCIColInfoList2
Rem    jstenois    08/30/00 - Created
Rem
rem create type for external tables

-- CREATE EXTERNAL TABLE IMPLEMENTATION TYPE   (SYS.ORACLE_LOADER)
CREATE OR REPLACE TYPE sys.oracle_loader AUTHID CURRENT_USER AS OBJECT
(
  xtctx  RAW(4),
  STATIC FUNCTION ODCIGetInterfaces(ifclist OUT NOCOPY SYS.ODCIObjectList)
         RETURN NUMBER,

  STATIC FUNCTION ODCIExtTableOpen(lctx  IN OUT NOCOPY oracle_loader,
                                   xti   IN            SYS.ODCIExtTableInfo,
                                   xri      OUT NOCOPY SYS.ODCIExtTableQCInfo,
                                   pcl      OUT NOCOPY SYS.ODCIColInfoList2,
                                   flag  IN OUT        number,
                                   strv  IN OUT        number,
                                   env   IN            SYS.ODCIEnv)
         RETURN number,

-- Fetch data for the given granule.  Note that cnverr is the number
-- of conversion errors that occurred while fetching and converting rows
-- for the current granule, gnum is the current granule number.

  MEMBER FUNCTION ODCIExtTableFetch(gnum   IN     number,
                                    cnverr IN OUT number,
                                    flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv)
         RETURN number,
  MEMBER FUNCTION ODCIExtTablePopulate(flag IN OUT number,
                                       env  IN     SYS.ODCIEnv)
         RETURN number,

  MEMBER FUNCTION ODCIExtTableClose(flag IN OUT number,
                                    env  IN     SYS.ODCIEnv)
         RETURN number
);
/

-- CREATE EXTERNAL TABLE IMPLEMENTATION TYPE   (SYS.ORACLE_DATAPUMP)
CREATE OR REPLACE TYPE sys.oracle_datapump AUTHID CURRENT_USER AS OBJECT
(
  xtctx  RAW(4),
  STATIC FUNCTION ODCIGetInterfaces(ifclist OUT NOCOPY SYS.ODCIObjectList)
         RETURN NUMBER,

  STATIC FUNCTION ODCIExtTableOpen(lctx  IN OUT NOCOPY oracle_datapump,
                                   xti   IN            SYS.ODCIExtTableInfo,
                                   xri      OUT NOCOPY SYS.ODCIExtTableQCInfo,
                                   pcl      OUT NOCOPY SYS.ODCIColInfoList2,
                                   flag  IN OUT        number,
                                   strv  IN OUT        number,
                                   env   IN            SYS.ODCIEnv)
         RETURN number,

-- Fetch data for the given granule.  Note that cnverr is the number
-- of conversion errors that occurred while fetching and converting rows
-- for the current granule, gnum is the current granule number.

  MEMBER FUNCTION ODCIExtTableFetch(gnum   IN     number,
                                    cnverr IN OUT number,
                                    flag   IN OUT number,
                                    env    IN     SYS.ODCIEnv)
         RETURN number,
  MEMBER FUNCTION ODCIExtTablePopulate(flag IN OUT number,
                                       env  IN     SYS.ODCIEnv)
         RETURN number,

  MEMBER FUNCTION ODCIExtTableClose(flag IN OUT number,
                                    env  IN     SYS.ODCIEnv)
         RETURN number
);
/

---------------------------------
--  CREATE IMPLEMENTATION UNIT --
---------------------------------
-- CREATE LIBRARY
CREATE OR REPLACE LIBRARY QXXQLIB TRUSTED AS STATIC;
/

-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY sys.oracle_loader
IS
--
-- ODCIGetInterfaces - returns supported interface and stream version.
--
  STATIC FUNCTION ODCIGETINTERFACES(ifclist OUT NOCOPY SYS.ODCIOBJECTLIST) 
       RETURN NUMBER IS
  BEGIN
      ifclist := SYS.ODCIOBJECTLIST
                        (
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE1'),
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE_STREAM1')
                        );
      RETURN ODCICONST.SUCCESS;
  END ODCIGETINTERFACES;
--
-- ODCIExtTableOpen
--
  STATIC FUNCTION ODCIEXTTABLEOPEN(LCTX IN OUT NOCOPY oracle_loader,
                                   xti  IN            SYS.ODCIEXTTABLEINFO,
                                   xri     OUT NOCOPY SYS.ODCIEXTTABLEQCINFO,
                                   pcl     OUT NOCOPY SYS.ODCICOLINFOLIST2,
                                   flag IN OUT        NUMBER,
                                   strv IN OUT        NUMBER,
                                   env  IN            SYS.ODCIENV)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_OPEN"
    LIBRARY QXXQLIB     
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      lctx,
      lctx   INDICATOR STRUCT,
      lctx   duration,
      xti,
      xti    INDICATOR STRUCT,
      xri,
      xri    INDICATOR STRUCT,
      pcl,
      pcl    INDICATOR,
      flag,
      flag   INDICATOR,
      strv,
      strv   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableFetch
--
  MEMBER FUNCTION ODCIEXTTABLEFETCH(gnum     IN     NUMBER,
                                    cnverr   IN OUT NUMBER,
                                    flag     IN OUT NUMBER,
                                    env      IN     SYS.ODCIENV)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_FETCH"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      gnum,
      gnum   INDICATOR,
      cnverr,
      cnverr INDICATOR,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      RETURN OCINUMBER
    );
--
-- ODCIExtTablePopulate
--
  MEMBER FUNCTION ODCIEXTTABLEPOPULATE(flag  IN OUT NUMBER,
                                       env   IN     SYS.ODCIENV)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_POPULATE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableClose
--
  MEMBER FUNCTION ODCIEXTTABLECLOSE(flag  IN OUT NUMBER,
                                    env   IN     SYS.ODCIENV)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_CLOSE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      RETURN OCINUMBER
    );
END;
/

-- CREATE TYPE BODY
CREATE OR REPLACE TYPE BODY sys.oracle_datapump
IS
--
-- ODCIGetInterfaces - returns supported interface and stream version.
--
  STATIC FUNCTION ODCIGETINTERFACES(ifclist OUT NOCOPY SYS.ODCIOBJECTLIST)
       RETURN NUMBER IS
  BEGIN
      ifclist := SYS.ODCIOBJECTLIST
                        (
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE1'),
                          SYS.ODCIOBJECT('SYS','ODCIEXTTABLE_STREAM1')
                        );
      RETURN ODCICONST.SUCCESS;
  END ODCIGETINTERFACES;
--
-- ODCIExtTableOpen
--
  STATIC FUNCTION ODCIEXTTABLEOPEN(LCTX IN OUT NOCOPY oracle_datapump,
                                   xti  IN            SYS.ODCIEXTTABLEINFO,
                                   xri     OUT NOCOPY SYS.ODCIEXTTABLEQCINFO,
                                   pcl     OUT NOCOPY SYS.ODCICOLINFOLIST2,
                                   flag IN OUT NUMBER,
                                   strv IN OUT NUMBER,
                                   env  IN     SYS.ODCIENV)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_OPEN"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      lctx,
      lctx   INDICATOR STRUCT,
      lctx   duration,
      xti,
      xti    INDICATOR STRUCT,
      xri,
      xri    INDICATOR STRUCT,
      pcl,
      pcl    INDICATOR,
      flag,
      flag   INDICATOR,
      strv,
      strv   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      RETURN OCINUMBER
    );
--
-- ODCIExtTableFetch
--
  MEMBER FUNCTION ODCIEXTTABLEFETCH(gnum   IN     NUMBER,
                                    cnverr IN OUT NUMBER,
                                    flag   IN OUT NUMBER,
                                    env    IN     SYS.ODCIENV)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_FETCH"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      gnum,
      gnum   INDICATOR,
      cnverr,
      cnverr INDICATOR,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      RETURN OCINUMBER
    );
--
-- ODCIExtTablePopulate
--
  MEMBER FUNCTION ODCIEXTTABLEPOPULATE(flag  IN OUT NUMBER,
                                       env   IN     SYS.ODCIENV)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_POPULATE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      RETURN OCINUMBER
    );

--
-- ODCIExtTableClose
--
  MEMBER FUNCTION ODCIEXTTABLECLOSE(flag  IN OUT NUMBER,
                                    env   IN     SYS.ODCIENV)
    RETURN NUMBER AS LANGUAGE C
    NAME "QXXQ_CLOSE"
    LIBRARY QXXQLIB
    WITH CONTEXT
    PARAMETERS
    (
      CONTEXT,
      SELF,
      SELF   INDICATOR STRUCT,
      flag,
      flag   INDICATOR,
      env,
      env    INDICATOR STRUCT,
      RETURN OCINUMBER
    );

END;
/
