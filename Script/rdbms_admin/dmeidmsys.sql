Rem
Rem $Header: dmeidmsys.sql 09-apr-2007.13:31:40 jiawang Exp $
Rem
Rem dmeidmsys.sql
Rem
Rem Copyright (c) 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dmeidmsys.sql - Data Mining Export Import DMSYS schema creation
Rem    DESCRIPTION
Rem      Minimal DMSYS Schema Definitions required for import of prior DM
Rem      versions of models
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jiawang     04/09/07 - Fix lrg2915512, use 'dmsys' as name
Rem    mmcracke    01/05/07 - Created
Rem

SET ECHO ON
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100

create user dmsys identified by dmsys default tablespace sysaux temporary tablespace temp quota 200M on sysaux;

grant
  CREATE SESSION,
  CREATE SYNONYM,
  CREATE TABLE,
  CREATE TYPE,
  CREATE PROCEDURE,
  CREATE PUBLIC SYNONYM,
  DROP PUBLIC SYNONYM
to dmsys;

connect dmsys/dmsys

-- Package Synonyms moved to dmproc.sql
CREATE TABLE dm$p_model(
  mod#             NUMBER NOT NULL,
  owner#           NUMBER NOT NULL,
  name             VARCHAR2(25) NOT NULL,
  function_name    VARCHAR2(30),
  algorithm_name   VARCHAR2(30),
  ctime            DATE,
  build_duration   NUMBER,
  target_attribute VARCHAR2(30),
  model_size       NUMBER,
  CONSTRAINT dm$p_model_unique UNIQUE (name, owner#))
/

CREATE TABLE dm$p_model_tables(
  mod#       NUMBER NOT NULL,
  table_type VARCHAR2(30) NOT NULL,
  table_name VARCHAR2(30),
  CONSTRAINT dm$p_modtab_unique UNIQUE (mod#, table_type))
/
--
-- TYPES required for CL rules persistence
--
CREATE TYPE category_type AUTHID CURRENT_USER AS OBJECT
  (value                 NUMBER(5)
  )
/
CREATE TYPE category_tab_type AS TABLE OF dmsys.category_type
/
CREATE TYPE predicate_type AUTHID CURRENT_USER AS OBJECT
  (attribute_name        VARCHAR2(30)
  ,attribute_id          NUMBER(6)
  ,comparison_function   NUMBER(2)
  ,value                 dmsys.category_tab_type
  )
/
CREATE TYPE predicate_tab_type AS TABLE OF dmsys.predicate_type
/
CREATE TYPE cl_predicate_type AUTHID CURRENT_USER AS OBJECT
  (comparison_function   NUMBER(2)
  ,value                 dmsys.category_tab_type
  )
/
CREATE TYPE cl_predicate_tab_type AS TABLE OF dmsys.cl_predicate_type
/
CREATE TYPE cluster_rule_element_type AUTHID CURRENT_USER AS OBJECT
  (attribute_name        VARCHAR2(30)
  ,attribute_id          NUMBER(6)
  ,attribute_relevance   NUMBER
  ,record_count          NUMBER(10)
  ,entries               dmsys.cl_predicate_tab_type
  )
/
CREATE TYPE cluster_rule_element_tab_type AS TABLE OF dmsys.cluster_rule_element_type
/
CREATE TYPE centroid_entry_type AUTHID CURRENT_USER AS OBJECT
  (attribute_name        VARCHAR2(30)
  ,attribute_id          NUMBER(6)
  ,value                 NUMBER(5)
  )
/
CREATE TYPE centroid_tab_type AS TABLE OF dmsys.centroid_entry_type
/
CREATE TYPE histogram_entry_type AUTHID CURRENT_USER AS OBJECT
  (count                 NUMBER
  ,value                 NUMBER(5)
  )
/
CREATE TYPE histogram_entry_tab_type AS TABLE OF dmsys.histogram_entry_type
/
CREATE TYPE attribute_histogram_type AUTHID CURRENT_USER AS OBJECT
  (attribute_name        VARCHAR2(32)
  ,attribute_id          NUMBER(6)
  ,entries               dmsys.histogram_entry_tab_type
  )
/
CREATE TYPE attribute_histogram_tab_type AS TABLE OF dmsys.attribute_histogram_type
/
CREATE TYPE child_type AUTHID CURRENT_USER AS OBJECT
  (id                    NUMBER(7)
  )
/
CREATE TYPE child_tab_type AS TABLE OF dmsys.child_type
/
CREATE TYPE cluster_type AUTHID CURRENT_USER AS OBJECT
  (id                    NUMBER(7)
  ,record_count          NUMBER(10)
  ,tree_level            NUMBER(7)
  ,parent                NUMBER(7)
  ,split_predicate       dmsys.predicate_tab_type
  ,centroid              dmsys.centroid_tab_type
  ,histogram             dmsys.attribute_histogram_tab_type
  ,child                 dmsys.child_tab_type
  )
/
CREATE TYPE cluster_tab_type AS TABLE OF dmsys.cluster_type
/
CREATE TYPE Cluster_rule_type AUTHID CURRENT_USER AS OBJECT
  (cluster_id            NUMBER(7)
  ,record_count          NUMBER(10)
  ,antecedent            dmsys.cluster_rule_element_tab_type
  )
/
CREATE TYPE Cluster_rule_tab_type IS TABLE OF Cluster_rule_type
/

CREATE OR REPLACE PUBLIC SYNONYM CLUSTER_RULE_TYPE
FOR DMSYS.CLUSTER_RULE_TYPE
/
CREATE OR REPLACE PUBLIC SYNONYM CLUSTER_TYPE
FOR DMSYS.CLUSTER_TYPE
/

GRANT EXECUTE ON category_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON category_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON predicate_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON predicate_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cl_predicate_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cl_predicate_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cluster_rule_element_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cluster_rule_element_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON centroid_entry_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON centroid_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON histogram_entry_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON histogram_entry_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON attribute_histogram_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON attribute_histogram_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON child_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON child_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cluster_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON cluster_tab_type TO PUBLIC WITH GRANT OPTION
/
GRANT EXECUTE ON Cluster_rule_type TO PUBLIC WITH GRANT OPTION
/
CREATE OR REPLACE PACKAGE dbms_dm_model_imp AUTHID CURRENT_USER AS
PROCEDURE create_model(model_name IN VARCHAR2,
                       functn     IN VARCHAR2,
                       algorm     IN VARCHAR2,
                       target     IN VARCHAR2,
                       duratn     IN NUMBER,
                       msize      IN NUMBER);

PROCEDURE add_table(model_name  IN VARCHAR2,
                    table_type  IN VARCHAR2,
                    table_name  IN VARCHAR2);
END dbms_dm_model_imp;
/
GRANT EXECUTE ON dbms_dm_model_imp TO PUBLIC
/

CREATE OR REPLACE PACKAGE BODY dbms_dm_model_imp AS
PROCEDURE create_model(model_name IN VARCHAR2,
                       functn     IN VARCHAR2,
                       algorm     IN VARCHAR2,
                       target     IN VARCHAR2,
                       duratn     IN NUMBER,
                       msize      IN NUMBER) IS
  BEGIN
    SYS.dbms_dm_model_imp.create_model(model_name, functn,
      algorm, target, duratn, msize);
  END;

PROCEDURE add_table(model_name  IN VARCHAR2,
                    table_type  IN VARCHAR2,
                    table_name  IN VARCHAR2) IS
  BEGIN
    SYS.dbms_dm_model_imp.add_table(model_name, table_type,
      table_name);
  END;
END;
/

EXIT

