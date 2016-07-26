Rem
Rem $Header: catcr.sql 25-may-2007.08:12:55 rburns Exp $
Rem
Rem catcr.sql
Rem
Rem Copyright (c) 2001, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catcr.sql - CATalog Component Registry
Rem
Rem    DESCRIPTION
Rem      This script creates the data dictionary elements and package for
Rem      the registry of components that have been loaded into the database.
Rem
Rem    NOTES
Rem      Use SQLPLUS
Rem      Conned AS SYSDBA
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rburns      05/25/07 - add timezone file version
Rem    cdilling    11/09/06 - add registry$database table
Rem    cdilling    06/08/06 - add table registry$error
Rem    cdilling    06/06/06 - add registry$dependencies table 
Rem    rburns      05/25/06 - add start rows 
Rem    cdilling    05/18/06 - add registry$progress table 
Rem    rburns      02/15/06 - back to timestamp
Rem    rburns      11/30/05 - use date instead of timestamp for history
Rem    rburns      02/22/05 - add table for upgrade history
Rem    rburns      06/17/04 - remove registry log from loading and loaded
Rem    rburns      06/15/04 - add more procedures to dbms_registry 
Rem    rburns      05/14/04 - add schema list to registry 
Rem    rburns      02/03/04 - add error log table
Rem    rburns      11/07/03 - add new status values 
Rem    rburns      03/18/03 - add catcrsc.sql
Rem    rburns      01/13/03 - fix synonym, loaded procedure and versions
Rem    rburns      11/01/02 - add iAS functionality 
Rem    rburns      11/27/02 - move packages to prvtcr.sql
Rem    tbgraves    11/26/02 - add SYSTEM and SYSAUX tablespace calculations to 
Rem                           timestamp procedure; move internal function 
Rem                           declarations 
Rem    rburns      11/18/02 - use ORA- errors for check_server_instance
Rem    rburns      11/12/02 - set session nls_length_semantics
Rem                         - add check_server_instance interface
Rem    rburns      07/24/02 - change timestamp format
Rem    rburns      04/10/02 - always use full path for nothing.sql
Rem    rburns      04/10/02 - no script for removed components
Rem    rburns      03/27/02 - add 10i interfaces
Rem    rburns      03/08/02 - fix Intermedia populate
Rem    rburns      02/14/02 - change AMD name and fix ORDIM and SDO names
Rem    rburns      02/11/02 - add registry version
Rem    rburns      02/06/02 - add MGW component
Rem    rburns      02/04/02 - fix ODM populate
Rem    rburns      01/09/02 - fix intermedia populate and permission check
Rem    rburns      12/15/01 - add catjava
Rem    rburns      12/12/01 - MDSYS for Spatial
Rem    rburns      12/10/01 - fix validate procedure
Rem    rburns      12/06/01 - add other components
Rem    rburns      10/26/01 - add registry validation procedure
Rem    smavris     11/08/01 - Update interMedia registry
Rem    rburns      10/23/01 - fix views, add drop_user
Rem    rburns      10/15/01 - add owm, ols, and new registry columns
Rem    rburns      10/02/01 - add JAVAVM and new interfaces
Rem    rburns      09/20/01 - add flags column for restart, new interfaces
Rem    rburns      08/30/01 - Merged rburns_component_registry
Rem    rburns      08/15/01 - Created
Rem
Rem ------------------------------------------------------------------------
Rem REGISTRY$ table
Rem ------------------------------------------------------------------------

CREATE TABLE registry$ (
             cid      VARCHAR2(30),                 /* component identifier */
             cname    VARCHAR2(255),                      /* component name */
             schema#  NUMBER NOT NULL,             /* user# of schema owner */
             invoker# NUMBER NOT NULL,           /* user# of script invoker */
             version  VARCHAR2(30),             /* component version loaded */
             status   NUMBER NOT NULL,                  /* component status */
                                                         /* 0 = INVALID     */
                                                         /* 1 = VALID       */
                                                         /* 2 = LOADING     */
                                                         /* 3 = LOADED      */
                                                         /* 4 = UPGRADING   */
                                                         /* 5 = UPGRADED    */
                                                         /* 6 = DOWNGRADING */
                                                         /* 7 = DOWNGRADED  */ 
                                                         /* 8 = REMOVING    */
                                                         /* 9 = OPTION OFF  */
                                                         /* 10 = NO SCRIPT  */
                                                         /* 99 = REMOVED    */
             flags    NUMBER NOT NULL,        /* additional component flags */
                                                   /* 0x01 STARTUP REQUIRED */
             modified DATE,                       /* last modified datetime */
             pid      VARCHAR2(30),          /* parent component identifier */
             banner   VARCHAR2(80),             /* component display banner */
             vproc    VARCHAR2(61),                 /* validation procedure */
             date_invalid       DATE,              /* last INVALID datetime */
             date_valid         DATE,                /* last VALID datetime */
             date_loading       DATE,              /* last LOADING datetime */
             date_loaded        DATE,               /* last LOADED datetime */
             date_upgrading     DATE,            /* last UPGRADING datetime */
             date_upgraded      DATE,             /* last UPGRADED datetime */
             date_downgrading   DATE,          /* last DOWNGRADING datetime */
             date_downgraded    DATE,           /* last DOWNGRADED datetime */
             date_removing      DATE,             /* last REMOVING datetime */
             date_removed       DATE,              /* last REMOVED datetime */
             namespace          VARCHAR2(30),        /* component namespace */
             org_version        VARCHAR2(30),     /* original loaded version */
             prv_version        VARCHAR2(30),            /* previous version */
             CONSTRAINT registry_pk  PRIMARY KEY (namespace, cid),
             CONSTRAINT registry_parent_fk FOREIGN KEY (namespace, pid)
                        REFERENCES registry$ (namespace, cid) 
                        ON DELETE CASCADE);

CREATE TABLE registry$schemas (
             cid         VARCHAR2(30),              /* component identifier */
             namespace   VARCHAR2(30),               /* component namespace */
             schema#     NUMBER,                      /* ancillary schema # */
             CONSTRAINT registry_schema_pk PRIMARY KEY 
                        (namespace, cid, schema#),
             CONSTRAINT registry_schema_fk FOREIGN KEY (namespace, cid)
                        REFERENCES registry$ (namespace, cid) 
                        ON DELETE CASCADE);
  
CREATE TABLE registry$log (
             cid         VARCHAR2(30),              /* component identifier */
             namespace   VARCHAR2(30),               /* component namespace */
             operation   NUMBER NOT NULL,              /* current operation */
                                                         /*-1 = START       */
                                                         /* 0 = INVALID     */
                                                         /* 1 = VALID       */
                                                         /* 2 = LOADING     */
                                                         /* 3 = LOADED      */
                                                         /* 4 = UPGRADING   */
                                                         /* 5 = UPGRADED    */
                                                         /* 6 = DOWNGRADING */
                                                         /* 7 = DOWNGRADED  */ 
                                                         /* 8 = REMOVING    */
                                                         /* 9 = OPTION OFF  */
                                                         /* 10 = NO SCRIPT  */
                                                         /* 99 = REMOVED    */
                                                        /* 100 = ERROR      */
             optime      TIMESTAMP,                  /* operation timestamp */
             errmsg      VARCHAR2(1000)  /* error message text from SQL*Plus */
             );



Rem
Rem ------------------------------------------------------------------------
Rem REGISTRY$ERROR table
Rem
Rem Contains error messages for components during upgrade(if errors occur)
Rem ------------------------------------------------------------------------
Rem
Rem

CREATE TABLE sys.registry$error(username   VARCHAR(256),
                                timestamp  TIMESTAMP,
                                script     VARCHAR(1024),
                                identifier VARCHAR(256),
                                message    CLOB,
                                statement  CLOB);                      


Rem
Rem ------------------------------------------------------------------------
Rem REGISTRY$HISTORY table
Rem
Rem Contains a time-stamped entry for each upgrade/downgrade performed 
Rem and for each CPU applied to the database.
Rem ------------------------------------------------------------------------

CREATE TABLE registry$history (
             action_time     TIMESTAMP,                     /* time stamp */
             action          VARCHAR2(30),              /* name of action */
             namespace       VARCHAR2(30),           /* upgrade namespace */
             version         VARCHAR(30),               /* server version */
             id              NUMBER,                   /* CPU or Patch ID */
             comments        VARCHAR2(255)                    /* comments */
             );

Rem
Rem ------------------------------------------------------------------------
Rem REGISTRY$PROGRESS table
Rem
Rem Contains value/step entry for each progress action taken during upgrade
Rem 
Rem ------------------------------------------------------------------------

CREATE TABLE registry$progress (
             cid         VARCHAR2(30),              /* component identifier */
             namespace   VARCHAR2(30),               /* component namespace */
             action      VARCHAR2(255),                  /* progress action */
             value       VARCHAR2(255),                   /* progress value */
             step        NUMBER,                         /* progress number */
             action_time TIMESTAMP,                            /* timestamp */
             CONSTRAINT registry_progress_pk  PRIMARY KEY 
                        (cid, namespace, action),
             CONSTRAINT registry_progress_fk FOREIGN KEY (cid, namespace)
                        REFERENCES registry$ (cid,namespace) 
                        ON DELETE CASCADE
             );

Rem
Rem ------------------------------------------------------------------------
Rem REGISTRY$DEPENDENCIES table
Rem
Rem Contains component dependency information.
Rem 
Rem ------------------------------------------------------------------------

CREATE TABLE registry$dependencies (
             cid           VARCHAR2(30),            /* component identifier */
             namespace     VARCHAR2(30),             /* component namespace */
             req_cid       VARCHAR2(30),   /* required component identifier */
             req_namespace VARCHAR2(30),    /* required component namespace */
             CONSTRAINT dependencies_pk  PRIMARY KEY 
                        (namespace,cid,req_namespace,req_cid),
             CONSTRAINT dependencies_fk FOREIGN KEY (namespace,cid)
                        REFERENCES registry$ (namespace,cid) 
                        ON DELETE CASCADE,
             CONSTRAINT dependencies_req_fk FOREIGN KEY (req_namespace,req_cid)
                        REFERENCES registry$ (namespace,cid) 
                        ON DELETE CASCADE
             );


Rem
Rem ------------------------------------------------------------------------
Rem REGISTRY$DATABASE table
Rem
Rem Contains database specific information such as platform id, 
Rem platform name, edition 
Rem ------------------------------------------------------------------------
Rem
Rem

CREATE TABLE registry$database( 
             platform_id   NUMBER,        /* database platform id */
             platform_name VARCHAR2(101), /* database platform name */
             edition       VARCHAR2(30),  /* database edition */
             tz_version    NUMBER         /* timezone file version */
             );                   

Rem -------------------------------------------------------------------------
Rem DBMS REGISTRY PACKAGE - minimal version for loading CATALOG
Rem -------------------------------------------------------------------------

CREATE OR REPLACE PACKAGE dbms_registry AS

PROCEDURE loading     (comp_id      IN VARCHAR2,
                       comp_name    IN VARCHAR2,
                       comp_proc    IN VARCHAR2 DEFAULT NULL,
                       comp_schema  IN VARCHAR2 DEFAULT NULL,
                       comp_parent  IN VARCHAR2 DEFAULT NULL);

PROCEDURE loaded      (comp_id      IN VARCHAR2,
                       comp_version IN VARCHAR2 DEFAULT NULL,
                       comp_banner  IN VARCHAR2 DEFAULT NULL);

FUNCTION  time_stamp  (comp_id IN VARCHAR2) RETURN VARCHAR2; 

PROCEDURE check_server_instance;

END dbms_registry;
/

CREATE OR REPLACE PACKAGE BODY dbms_registry 
AS

-- STATUS
 
  s_invalid     NUMBER :=0;
  s_valid       NUMBER :=1;
  s_loading     NUMBER :=2;
  s_loaded      NUMBER :=3;
  s_removing    NUMBER :=8;
  s_removed     NUMBER :=99;   

no_component    EXCEPTION;
PRAGMA          EXCEPTION_INIT(no_component, -39705);

not_invoker     EXCEPTION;
PRAGMA          EXCEPTION_INIT(not_invoker, -39704);

-- GLOBAL

g_null         CHAR(1);

----------------------------------------------------------------------
-- PRIVATE FUNCTIONS
----------------------------------------------------------------------

------------------------- exists_comp --------------------------------

FUNCTION exists_comp (id IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  SELECT NULL INTO g_null FROM sys.registry$
  WHERE cid = id AND namespace='SERVER';
  RETURN TRUE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN FALSE;
END exists_comp;

------------------------- get_user --------------------------------

FUNCTION get_user RETURN NUMBER
IS

p_user# NUMBER;

BEGIN
  SELECT user# INTO p_user# FROM sys.user$
  WHERE name = SYS_CONTEXT ('USERENV', 'SESSION_USER');
  RETURN p_user#;
END get_user;

--------------------------------------------------------------------

FUNCTION get_user(usr IN VARCHAR2) RETURN NUMBER
IS

p_user# NUMBER;

BEGIN
  SELECT user# INTO p_user# FROM sys.user$
  WHERE name = usr;
  RETURN p_user#;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RAISE not_invoker;
END get_user;

------------------------- check_invoker --------------------------------

PROCEDURE check_invoker (id IN VARCHAR2, usr# IN NUMBER)
IS 
BEGIN
  SELECT NULL into g_null from sys.registry$
  WHERE id = cid AND namespace='SERVER' AND 
        (usr# = invoker# OR usr# = schema#);

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     RAISE not_invoker;
END check_invoker;

------------------------- new_comp --------------------------------

PROCEDURE new_comp (st     IN VARCHAR2,
                    id     IN VARCHAR2, 
                    nme    IN VARCHAR2, 
                    prc    IN VARCHAR2,
                    par    IN VARCHAR2,
                    inv#   IN NUMBER,
                    sch#   IN NUMBER)
IS 
  openmigrate v$instance.status%TYPE;
BEGIN

  IF par IS NOT NULL THEN
     IF NOT exists_comp(par) THEN
        RAISE no_component;
     END IF;
  END IF;
  INSERT INTO sys.registry$ (modified, status, cid, cname, 
                             pid, vproc, invoker#, schema#, flags,
                             namespace)
         VALUES (SYSDATE, st, id, nme, par, prc, inv#, sch#, 0,
                 'SERVER');
END new_comp;


------------------------- update_comp --------------------------------

PROCEDURE update_comp (st     IN VARCHAR2,
                       id     IN VARCHAR2, 
                       nme    IN VARCHAR2, 
                       prc    IN VARCHAR2,
                       par    IN VARCHAR2,
                       ver    IN VARCHAR2,
                       ban    IN VARCHAR2)

IS 
  openmigrate v$instance.status%TYPE;
BEGIN

  IF par IS NOT NULL THEN
     IF NOT exists_comp(par) THEN
        RAISE no_component;
     END IF;
  END IF;

  UPDATE sys.registry$ SET status = st, modified = SYSDATE WHERE id = cid AND
         namespace='SERVER'; 

  IF nme IS NOT NULL THEN
     UPDATE sys.registry$ SET cname = nme WHERE id = cid AND
         namespace='SERVER'; 
  END IF;
  IF par IS NOT NULL THEN
     UPDATE sys.registry$ SET pid = par WHERE id = cid AND
         namespace='SERVER'; 
  END IF;
  IF prc IS NOT NULL THEN
     UPDATE sys.registry$ SET vproc = prc WHERE id = cid AND
         namespace='SERVER'; 
  END IF;
  IF ver IS NOT NULL THEN
     UPDATE sys.registry$ SET version = ver WHERE id = cid AND
         namespace='SERVER'; 
  END IF;
  IF ban IS NOT NULL THEN
     UPDATE sys.registry$ SET banner = ban WHERE id = cid AND
         namespace='SERVER'; 
  END IF;

END update_comp;

FUNCTION  comp_name  (comp_id IN VARCHAR2) RETURN VARCHAR2
IS

p_id      registry$.cid%TYPE :=NLS_UPPER(comp_id);
p_name    registry$.cname%TYPE;

BEGIN
   SELECT cname INTO p_name FROM sys.registry$ WHERE cid=p_id AND
         namespace='SERVER'; 
   RETURN p_name;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN NULL;

END comp_name;
  
----------------------------------------------------------------------
-- PUBLIC FUNCTIONS
----------------------------------------------------------------------

------------------------- LOADING ------------------------------------

PROCEDURE loading     (comp_id      IN VARCHAR2,
                       comp_name    IN VARCHAR2,
                       comp_proc    IN VARCHAR2 DEFAULT NULL,
                       comp_schema  IN VARCHAR2 DEFAULT NULL,
                       comp_parent  IN VARCHAR2 DEFAULT NULL)
IS

p_id      VARCHAR2(30) :=NLS_UPPER(comp_id);
p_name    VARCHAR2(255):=comp_name;
p_proc    VARCHAR2(61) :=NLS_UPPER(comp_proc);
p_schema  VARCHAR2(30) :=NLS_UPPER(comp_schema);
p_parent  VARCHAR2(30) :=NLS_UPPER(comp_parent);
p_invoker#   NUMBER    :=get_user;
p_schema#    NUMBER;

BEGIN
  IF p_schema IS NOT NULL then
     p_schema#:=get_user(p_schema);
  ELSE
     p_schema#:=p_invoker#;
  END IF;

  IF exists_comp(p_id) THEN
     check_invoker(p_id,p_invoker#);
     update_comp(s_loading, p_id, p_name, p_proc, p_parent, NULL, NULL);
     update sys.registry$ set schema# = p_schema#, 
            date_loading = SYSDATE 
            where cid=p_id AND
            namespace = 'SERVER'; 
     commit;
  ELSE
     new_comp(s_loading, p_id, p_name, p_proc, p_parent, 
              p_invoker#, p_schema#); 
     update sys.registry$ set date_loading = SYSDATE where cid=p_id AND
        namespace = 'SERVER';
     commit;
END IF;

END loading;

-------------------------- LOADED -------------------------------------

PROCEDURE loaded      (comp_id      IN VARCHAR2,
                       comp_version IN VARCHAR2 DEFAULT NULL,
                       comp_banner  IN VARCHAR2 DEFAULT NULL)
IS

p_id      VARCHAR2(30) :=NLS_UPPER(comp_id);
p_version VARCHAR2(17) :=NLS_UPPER(comp_version);
p_banner  VARCHAR2(80) :=comp_banner;
p_invoker#   NUMBER       :=get_user;

BEGIN
  
IF exists_comp(p_id) THEN
   check_invoker(p_id, p_invoker#);
   IF p_version IS NULL THEN
      SELECT version INTO p_version FROM v$instance;
   END IF;
   update registry$ set prv_version = version where cid=p_id AND
        namespace = 'SERVER' and prv_version IS NULL; 
   update registry$ set org_version = version where cid=p_id AND
        namespace = 'SERVER' and org_version IS NULL; 
   IF p_banner IS NULL THEN
      SELECT banner INTO p_banner FROM v$version
      WHERE rownum = 1;
      p_banner:= substr(p_banner, instr(p_banner,'-',1) + 2);
      p_banner:= dbms_registry.comp_name(p_id) || ' Release ' ||
          p_version || ' - ' || p_banner;
   END IF;
   update_comp(s_loaded, p_id, NULL, NULL, NULL, p_version, p_banner);
   update registry$ set date_loaded = SYSDATE where cid=p_id AND
        namespace = 'SERVER';
   commit;
ELSE
   raise NO_COMPONENT;
END IF;

END loaded;

-------------------------- TIME --------------------------------

FUNCTION time_stamp (comp_id IN VARCHAR2) RETURN VARCHAR2 
IS

p_cid    VARCHAR2(30) := NLS_UPPER(comp_id);
p_null   CHAR(1);
p_string VARCHAR2(200);

BEGIN
  SELECT NULL INTO p_null FROM registry$
  WHERE cid = p_cid AND status NOT IN (s_removing, s_removed) AND 
        namespace = 'SERVER';
  p_string:='COMP_TIMESTAMP ' ||
             RPAD(p_cid,10) || ' ' || 
             TO_CHAR(SYSTIMESTAMP,'YYYY-MM-DD HH24:MI:SS ');
  RETURN p_string;
EXCEPTION
  WHEN NO_DATA_FOUND THEN 
     RETURN NULL;
END time_stamp;

----------------- CHECK_SERVER_INSTANCE ---------------------------

PROCEDURE check_server_instance
IS

  openmigrate     VARCHAR2(30);
  vers            VARCHAR2(30);

BEGIN

-- See if server version and script version match. Raise an error if no match.
   select substr(version,1,6) into vers from v$instance;
   if vers != '10.2.0' then
      RAISE_APPLICATION_ERROR(-20000,'server version does not match script');
   end if;

-- verify open for migrate
   select status into openmigrate from v$instance;
   if openmigrate != 'OPEN MIGRATE' then
      RAISE_APPLICATION_ERROR(-20000,'database not open for UPGRADE');
   end if;

-- avoid use of CHAR semantics in dictionary objects
   execute immediate 'ALTER SESSION SET NLS_LENGTH_SEMANTICS = BYTE';

-- turn off PL/SQL event used by APPS
   execute immediate 'ALTER SESSION SET EVENTS=''10933 trace name context off''';

END check_server_instance;
                    
END dbms_registry;
/

Rem Server Components script
@@catcrsc

