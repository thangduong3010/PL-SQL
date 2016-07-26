-- 
--
-- dbmsaw.sql
-- 
-- Copyright (c) 2006, 2016, Oracle and/or its affiliates. All rights reserved.
--
--    NAME
--      dbmsaw.sql - RDBMS OLAP option package
--
--    DESCRIPTION
--      Defines the interfaces for the OLAP option
--
--    NOTES
--      None
--
--    MODIFIED  (MM/DD/YY)
--    apfwkr     01/14/16 - Backport jcarey_bug-20596234 from main
--    cchiappa   12/10/12 - Backport cchiappa_bug-10332890_olap_full_transport
--                          (10332890 - OLAP / AW SUPPORT FOR FULL DATABASE
--                          TRANSPORTABLE EXPORT / IMPORT)
--    cchiappa   04/29/11 - Backport cchiappa_bug-11899596 from main
--    cchiappa   03/03/11 - Backport cchiappa_bug-11804916 from main
--    jcarey     03/09/15 - bug 20596234 - add dbms_aw.validate_aw_name
--    cchiappa   03/01/11 - Add in_aw_cleanup
--    cchiappa   06/29/09 - Move set_obj_protect to DBMS_AW_EXP
--    cchiappa   10/30/08 - Add ADVICE_NOSAMPLE
--    almurphy   08/18/08 - eif import/export default to include api metadata
--    glyon      11/06/07 - bug 6596816 - change 'grant all' to 'grant execute'
--    hyechung   10/11/07 - add {set,get}_obj_protect
--    hyechung   07/02/07 - eif_out has new argument "dfns"
--    hyechung   05/31/07 - snowflake
--    cchiappa   02/14/07 - Fix partby member of dim_source_t
--    jcarey     10/23/06 - add split param copy
--    jcarey     06/23/06 - cannot convert aw to same name with schema 
--    jcarey     05/25/06 - add DBMS_AW.OLAP_ACTIVE 
--    cchiappa   12/21/05 - Add access tracking hooks 
--    cchiappa   09/13/05 - Add ADVISE_PARTITIONING_LEVEL 
--    jcarey     07/27/05 - back out maint job 
--    jcarey     07/08/05 - add gather stats
--    zqiu       03/02/05 - define awname_null_error 
--    cchiappa   02/28/05 - Add compress param to agg advisor 
--    cchiappa   01/19/05 - Move types out of package into objects
--    cchiappa   01/03/05 - Add CLOB advise_dimensionality 
--    cchiappa   12/13/04 - Move private defs to prvtaw 
--    cchiappa   11/29/04 - Sparsity advisor 
--    ckearney   08/11/04 - add extra limitmap parameters
--    cchiappa   07/13/04 - Move DBMS_AW_EXP to dbmsawex.sql (again) 
--    cchiappa   07/02/04 - Backout split
--    cchiappa   06/30/04 - Move DBMS_AW_EXP to dbmsawex.sql
--    dpeltier   05/14/04 - aw_upgrade -> polymorphic convert
--    cchiappa   05/12/04 - Add DBMS_AW.OLAP_RUNNING
--    cchiappa   04/07/04 - Fix comments
--    dpeltier   03/31/04 - aw_upgrade
--    cchiappa   03/18/04 - DBMS_AW_EXP in exppkgact$ for instances as well
--    ghicks     03/04/04 - more property functions
--    cchiappa   02/20/04 - DBMS_AW.RUN
--    cchiappa   02/16/04 - xsCmdExc, take 2
--    cchiappa   12/15/03 - Add vectored lob import
--    zqiu       10/14/03 - give partnum to the good aw_create
--    zqiu       09/26/03 - add prop_val function
--    ilyubash   08/25/03 - Add OLAPRanCurImpl_t and OLAPRC_TABLE
--    zqiu       09/08/03 - add partnum to aw_create
--    zqiu       09/03/03 - parameter for partitions in aw_copy
--    install    08/06/03 - Dropping body
--    ilyubash   07/10/03 - No more dummy functions
--    esoyleme   07/25/03 - add aw_copy
--    cwelton    02/05/03 - Table functions
--    esoyleme   01/02/03 - convert support
--    cchiappa   12/20/02 - Add more eif synonyms
--    zqiu       12/20/02 - change aw_rename interface
--    cchiappa   12/16/02 - Enhanced eif lob entry points
--    cwelton    12/03/02 - xstfPrepare gets qkn rather than rws
--    cchiappa   10/16/02 - BASE64 for import/export
--    ahopeman   10/10/02 - Add IN/OUT Parms to trusted callouts
--    zqiu       10/09/02 - move procedures for AW_*$
--    cchiappa   10/04/02 - Remove spurious slashes
--    ckearney   10/01/02 - Remove xsmdmgr objects
--    esoyleme   09/26/02 - cube precompute advisor
--    cwelton    10/04/02 - Add Table function Prepare method
--    ckearney   09/16/02 - Add OLAP_EXPRESSION_BOOL.
--    esoyleme   09/06/02 - add simple aggregate advisors
--    ckearney   08/30/02 - Move single row functions operators to C.
--    esoyleme   08/28/02 - grants for OLAP_TEXT_EXPR, etc
--    ilyubash   09/04/02 - add Describe method
--    ckearney   08/13/02 - Add text and date single row function support
--    cwelton    08/23/02 - Remove useless DROP commands
--    ckearney   08/06/02 - Removed dependency of SYS.OLAPROW2CELL object
--    cchiappa   08/01/02 - Tweak aw_update
--    ckearney   08/01/02 - more single row function support
--    cchiappa   07/29/02 - Allow shutdown of OLAP, rename startup
--    cwelton    07/11/02 - add dbms_aw.eval_*
--    jcarey     06/03/02 - support for r2c 
--    cchiappa   03/27/02 - New utility functions
--    cchiappa   01/24/01 - Add IMPORT/EXPORT functionality
--    ahopeman   11/07/01 - Add printlog procedure
--    cwelton    10/29/01 - Move table function body to prvtaw.sql
--    esoyleme   10/09/01 - second enabling transaction
--    jcarey     09/12/01 - More interface work
--    esoyleme   09/10/01 - official tables.
--    ahopeman   09/26/01 - change dbms_xs to dbms_aw
--    jcarey     07/05/01 - interfaces
--    esoyleme   05/11/01 - new function to peek at filter
--    jcarey     06/09/00 - Created
--

DROP PUBLIC SYNONYM dbms_aw$_dimension_sources_t
/
DROP PUBLIC SYNONYM dbms_aw$_dimension_source_t
/
DROP PUBLIC SYNONYM dbms_aw$_columnlist_t
/
DROP TYPE sys.dbms_aw$_dimension_sources_t
/
DROP TYPE sys.dbms_aw$_dimension_source_t
/
DROP TYPE sys.dbms_aw$_columnlist_t
/

CREATE OR REPLACE TYPE sys.dbms_aw$_columnlist_t AS TABLE OF VARCHAR2(100)
/
SHOW ERRORS;
CREATE OR REPLACE PUBLIC SYNONYM dbms_aw$_columnlist_t
                         FOR sys.dbms_aw$_columnlist_t
/
GRANT EXECUTE ON dbms_aw$_columnlist_t TO PUBLIC
/

CREATE OR REPLACE TYPE sys.dbms_aw$_dimension_source_t AS OBJECT
   (dimname     VARCHAR2(100),
    columnname  VARCHAR2(100),
    sourcevalue VARCHAR2(32767),
    dimtype     NUMBER(3,0),
    hiercols    dbms_aw$_columnlist_t,
    partby      NUMBER(10,0))
/
SHOW ERRORS;
CREATE OR REPLACE PUBLIC SYNONYM dbms_aw$_dimension_source_t
                         FOR sys.dbms_aw$_dimension_source_t
/
GRANT EXECUTE ON dbms_aw$_dimension_source_t TO PUBLIC
/

CREATE OR REPLACE TYPE dbms_aw$_dimension_sources_t
   AS TABLE OF dbms_aw$_dimension_source_t
/
SHOW ERRORS;
CREATE OR REPLACE PUBLIC SYNONYM dbms_aw$_dimension_sources_t
                         FOR sys.dbms_aw$_dimension_sources_t
/
GRANT EXECUTE ON dbms_aw$_dimension_sources_t TO PUBLIC
/

CREATE OR REPLACE PACKAGE dbms_aw AUTHID CURRENT_USER AS

  ---------------------
  --  OVERVIEW
  --
  --  This package is the interface to the Express server routines.  
  --    interp     - This function interprets an OLAP DML command and
  --                 returns the output as a character LOB.
  --    execute    - This procedure executes an OLAP DML command and uses
  --                 dbms_output to print the results.
  --
  ---------------------
  --  Visibility        
  --   All users
  --
  ---------------------
  --  PROCEDURES

  PROCEDURE initdriver;
  PROCEDURE startup;
  PROCEDURE shutdown(force IN BOOLEAN DEFAULT FALSE);
  PROCEDURE toggleDBCreate;
  FUNCTION  interpclob(cmd_clob IN CLOB) RETURN CLOB;
  FUNCTION  getlog return clob;
  PROCEDURE printlog(log_clob IN CLOB);

  -- Routines which handle output for the user
  PROCEDURE run(cmd IN STRING, silent IN            BOOLEAN DEFAULT FALSE);
  PROCEDURE run(cmd IN CLOB,   silent IN            BOOLEAN DEFAULT FALSE);

  -- Routines which pass data back
  PROCEDURE run(cmd IN STRING, output    OUT        STRING);
  PROCEDURE run(cmd IN STRING, output IN OUT NOCOPY CLOB);
  PROCEDURE run(cmd IN CLOB,   output    OUT        STRING);
  PROCEDURE run(cmd IN CLOB,   output IN OUT NOCOPY CLOB);

  PROCEDURE execute(cmd IN STRING);
  FUNCTION  interp(cmd IN string) RETURN clob;
  PROCEDURE interp_silent(cmd IN STRING);
  PROCEDURE infile(ifilename IN STRING);

  FUNCTION  eval_number(cmd IN STRING) RETURN NUMBER;
  FUNCTION  eval_text(cmd IN STRING) RETURN VARCHAR2;

  FUNCTION  olap_on RETURN BOOLEAN;
  FUNCTION  olap_running RETURN BOOLEAN;
  FUNCTION  olap_active RETURN BOOLEAN;

  PROCEDURE advise_rel(  relname    IN VARCHAR2, 
                         valueset   IN VARCHAR2,
                         pct        IN BINARY_INTEGER DEFAULT 20,
                         compressed IN BOOLEAN        DEFAULT FALSE);
  PROCEDURE advise_cube( aggmap     IN VARCHAR2, 
                         pct        IN BINARY_INTEGER DEFAULT 20,
                         compressed IN BOOLEAN        DEFAULT FALSE);

  PROCEDURE enable_access_tracking(objname IN VARCHAR2);
  PROCEDURE disable_access_tracking(objname IN VARCHAR2);
  PROCEDURE clean_access_tracking(objname IN VARCHAR2);

  NO_HIER                 CONSTANT BINARY_INTEGER := 0;
  MEASURE                 CONSTANT BINARY_INTEGER := 1;
  HIER_PARENTCHILD        CONSTANT BINARY_INTEGER := 2;
  HIER_LEVELS             CONSTANT BINARY_INTEGER := 3;
  HIER_SNOWFLAKE          CONSTANT BINARY_INTEGER := 4;

  PARTBY_DEFAULT          CONSTANT BINARY_INTEGER := 0;
  PARTBY_NONE             CONSTANT BINARY_INTEGER := 1;
  PARTBY_FORCE            CONSTANT BINARY_INTEGER := 2147483647;
 
  ADVICE_DEFAULT          CONSTANT BINARY_INTEGER := 0;
  ADVICE_FAST             CONSTANT BINARY_INTEGER := 1;
  ADVICE_FULL             CONSTANT BINARY_INTEGER := 2;
  ADVICE_NOSAMPLE         CONSTANT BINARY_INTEGER := 3;

  PROCEDURE sparsity_advice_table(tblname IN     VARCHAR2 DEFAULT NULL);

  PROCEDURE add_dimension_source(dimname  IN      VARCHAR2,
                                 colname  IN      VARCHAR2,
                                 sources  IN OUT  dbms_aw$_dimension_sources_t,
                                 srcval   IN      VARCHAR2 DEFAULT NULL,
                                 dimtype  IN      NUMBER DEFAULT NO_HIER,
                                 hiercols IN      dbms_aw$_columnlist_t
                                          DEFAULT NULL,
                                 partby   IN      NUMBER
                                          DEFAULT PARTBY_DEFAULT);

  PROCEDURE advise_sparsity(fact       IN      VARCHAR2,
                            cubename   IN      VARCHAR2,
                            dimsources IN      dbms_aw$_dimension_sources_t,
                            advmode    IN      BINARY_INTEGER
                                       DEFAULT ADVICE_DEFAULT,
                            partby     IN      BINARY_INTEGER
                                       DEFAULT PARTBY_DEFAULT,
                            advtable   IN      VARCHAR2 DEFAULT NULL);

  FUNCTION advise_dimensionality(cubename   IN     VARCHAR2,
                                 sparsedfn     OUT VARCHAR2,
                                 sparsename IN     VARCHAR2 DEFAULT NULL,
                                 partnum    IN     NUMBER DEFAULT 1,
                                 advtable   IN     VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;
  PROCEDURE advise_dimensionality(output        OUT NOCOPY CLOB,
                                  cubename   IN     VARCHAR2,
                                  sparsename IN     VARCHAR2 DEFAULT NULL,
                                  dtype      IN     VARCHAR2 DEFAULT 'NUMBER',
                                  advtable   IN     VARCHAR2 DEFAULT NULL);
  FUNCTION advise_partitioning_dimension(cubename IN VARCHAR2,
                                    dimsources IN dbms_aw$_dimension_sources_t,
                                    advtable   IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;
  FUNCTION advise_partitioning_level(cubename  IN VARCHAR2,
                                    dimsources IN dbms_aw$_dimension_sources_t,
                                    advtable   IN VARCHAR2 DEFAULT NULL)
    RETURN VARCHAR2;

  PROCEDURE aw_update(name     IN VARCHAR2 DEFAULT NULL);
  PROCEDURE aw_update(schema   IN VARCHAR2,
                      name     IN VARCHAR2);

  PROCEDURE aw_attach(name     IN VARCHAR2,
                      forwrite IN BOOLEAN  DEFAULT FALSE,
                      createaw IN BOOLEAN  DEFAULT FALSE,
                      attargs  IN VARCHAR2 DEFAULT NULL,
                      tbspace  IN VARCHAR2 DEFAULT NULL);
  PROCEDURE aw_attach(schema   IN VARCHAR2,
                      name     IN VARCHAR2,
                      forwrite IN BOOLEAN  DEFAULT FALSE,
                      createaw IN BOOLEAN  DEFAULT FALSE,
                      attargs  IN VARCHAR2 DEFAULT NULL,
                      tbspace  IN VARCHAR2 DEFAULT NULL);

  PROCEDURE aw_detach(name     IN VARCHAR2);

  PROCEDURE aw_detach(schema   IN VARCHAR2,
                      name     IN VARCHAR2);

  PROCEDURE aw_create(name     IN VARCHAR2,
                      tbspace  IN VARCHAR2 DEFAULT NULL,
                      partnum  IN NUMBER   DEFAULT NULL);

  PROCEDURE aw_create(schema   IN VARCHAR2,
                      name     IN VARCHAR2,
                      tbspace  IN VARCHAR2 DEFAULT NULL,
                      partnum  IN NUMBER   DEFAULT NULL);

  PROCEDURE aw_copy(oldname IN VARCHAR2,
                    newname IN VARCHAR2,
                    newtablespace IN VARCHAR2 DEFAULT NULL,
                    partnum IN NUMBER DEFAULT NULL);

  PROCEDURE aw_copy(oldschema IN VARCHAR2,
                    oldname IN VARCHAR2,
                    newname IN VARCHAR2,
                    newtablespace IN VARCHAR2 DEFAULT NULL,
                    partnum IN NUMBER DEFAULT NULL);

  PROCEDURE aw_delete(name     IN VARCHAR2);
  PROCEDURE aw_delete(schema   IN VARCHAR2,
                      name     IN VARCHAR2);

  PROCEDURE aw_rename(inname   IN VARCHAR2,
                      outname  IN VARCHAR2);

  FUNCTION  aw_tablespace(schema IN VARCHAR2,
                          name   IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION  aw_tablespace(name   IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION  aw_is_system(schema IN VARCHAR2,
                         name   IN VARCHAR2) RETURN BOOLEAN;

  TYPE eif_t         IS TABLE OF BLOB NOT NULL;
  TYPE eif_objlist_t IS TABLE OF VARCHAR2(100);

  -- Enumerated Types for the datadfns param to EIF import
  EIFIMP_DATA        CONSTANT BINARY_INTEGER := 1;
  EIFIMP_DEFINES     CONSTANT BINARY_INTEGER := 2;
  EIFIMP_DFNS        CONSTANT BINARY_INTEGER := EIFIMP_DEFINES;
  EIFIMP_DATADEFINES CONSTANT BINARY_INTEGER := 3;
  EIFIMP_DATADFNS    CONSTANT BINARY_INTEGER := EIFIMP_DATADEFINES;

  AWNAME_IS_NULL EXCEPTION;

  FUNCTION  eif_blob_out(name IN VARCHAR2,
                         objlist IN eif_objlist_t DEFAULT NULL,
                         api IN BOOLEAN DEFAULT TRUE) RETURN BLOB;
  FUNCTION  eif_blob_out(schema IN VARCHAR2, name IN VARCHAR2,
                         objlist IN eif_objlist_t DEFAULT NULL,
                         api IN BOOLEAN DEFAULT TRUE) RETURN BLOB;
  PROCEDURE eif_blob_in(name IN VARCHAR2, implob IN BLOB,
                        datadfns IN BINARY_INTEGER DEFAULT EIFIMP_DATA,
                        objlist  IN eif_objlist_t  DEFAULT NULL,
                        api IN BOOLEAN DEFAULT TRUE);
  PROCEDURE eif_blob_in(schema IN VARCHAR2, name IN VARCHAR2, implob IN BLOB,
                        datadfns IN BINARY_INTEGER DEFAULT EIFIMP_DATA,
                        objlist  IN eif_objlist_t  DEFAULT NULL,
                        api IN BOOLEAN DEFAULT TRUE);
  PROCEDURE eif_out(name IN VARCHAR2, expeif OUT eif_t,
                    objlist IN eif_objlist_t DEFAULT NULL,
                    dfns IN BOOLEAN DEFAULT FALSE,
                    api IN BOOLEAN DEFAULT TRUE);
  PROCEDURE eif_out(schema IN VARCHAR2, name IN VARCHAR2, expeif OUT eif_t,
                    objlist IN eif_objlist_t DEFAULT NULL,
                    dfns IN BOOLEAN DEFAULT FALSE,
                    api IN BOOLEAN DEFAULT TRUE);
  PROCEDURE eif_in(name IN VARCHAR2, impeif IN eif_t,
                   datadfns IN BINARY_INTEGER DEFAULT EIFIMP_DATA,
                   objlist IN eif_objlist_t DEFAULT NULL,
                   api IN BOOLEAN DEFAULT TRUE);
  PROCEDURE eif_in(schema IN VARCHAR2, name IN VARCHAR2, impeif IN eif_t,
                   datadfns IN BINARY_INTEGER DEFAULT EIFIMP_DATA,
                   objlist IN eif_objlist_t DEFAULT NULL,
                   api IN BOOLEAN DEFAULT TRUE);
  PROCEDURE eif_delete(eif IN OUT eif_t);
  FUNCTION  get_obj_protect RETURN BOOLEAN;

  bad_compat_error NUMBER := -20002;
  aw_changed_error NUMBER := -20003;
  awname_null_error NUMBER := -20004;
  has_schema_error NUMBER := -20005;
  bad_snowflake_error NUMBER := -20006;

  PROCEDURE convert(awname IN VARCHAR2);
  PROCEDURE convert(oldname IN VARCHAR2, newname IN VARCHAR2,
                    newtablespace IN VARCHAR2 DEFAULT NULL);

  en_tbs_error NUMBER := -20001;
  PROCEDURE move_awmeta(dest_tbs IN VARCHAR2);
  
  FUNCTION prop_val(rid IN ROWID) RETURN VARCHAR2;
  FUNCTION olap_type(otype IN NUMBER) RETURN VARCHAR2;
  FUNCTION prop_clob(rid IN ROWID) RETURN CLOB;
  FUNCTION prop_len(rid IN ROWID) RETURN NUMBER;
  PROCEDURE gather_stats;
  FUNCTION in_aw_cleanup RETURN BOOLEAN;
  PROCEDURE VALIDATE_AW_NAME(awname IN VARCHAR2);

  -- Internal types, not for user consumption
  TYPE loblineiter_t IS RECORD (
    mylob   CLOB,
    loc     NUMBER,
    clength NUMBER,
    cmax    NUMBER,
    linemax NUMBER);

END dbms_aw; 
/
show errors;

-- Give execute privileges
CREATE OR REPLACE PUBLIC SYNONYM dbms_aw FOR sys.dbms_aw
/
GRANT EXECUTE ON dbms_aw TO PUBLIC
/
