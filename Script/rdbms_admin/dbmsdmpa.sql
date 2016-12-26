Rem
Rem $Header: dbmsdmpa.sql 14-sep-2006.11:58:40 pstengar Exp $
Rem
Rem dbmsdmpa.sql
Rem 
Rem Copyright (c) 2001, 2006, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      dbmsdmpa.sql - DBMS_PREDICTIVE_ANALYTICS
Rem
Rem    DESCRIPTION
Rem      The package provides routines for predictive analytics operations.
Rem
Rem    NOTES
Rem      The procedural option is needed to use this package. This package
Rem      must be created under SYS (connect internal). Operations provided 
Rem      by this package are performed under the current calling user, not
Rem      under the package owner SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    pstengar    09/14/06 - bug 5499909: modify input params for PROFILE
Rem    mmcracke    04/01/05 - Change to use SYS schema. 
Rem    pstengar    03/17/06 - added PROFILE
Rem    pstengar    08/23/04 - split package header from body 
Rem    xbarr       06/25/04 - xbarr_dm_rdbms_migration
Rem    amozes      06/23/04 - remove hard tabs
Rem    pstengar    06/10/04 - add DATE support for predict and explain
Rem    pstengar    05/17/04 - add accuracy measure to predict api
Rem    pstengar    05/11/04 - add support for float datatype
Rem    pstengar    04/05/04 - pstengar_txn111007
Rem    pstengar    03/16/04 - Creation
Rem
Rem ********************************************************************
Rem THE FUNCTIONS SUPPLIED BY THIS PACKAGE AND ITS EXTERNAL INTERFACE
Rem ARE RESERVED BY ORACLE AND ARE SUBJECT TO CHANGE IN FUTURE RELEASES.
Rem ********************************************************************
Rem
Rem ********************************************************************
Rem THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO COULD
Rem CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE RDBMS.
Rem ********************************************************************
Rem
Rem ********************************************************************
Rem THIS PACKAGE MUST BE CREATED UNDER SYS.
Rem ********************************************************************
Rem
Rem --------------------------------------------
Rem dbms_predictive_analytics PACKAGE DEFINITION
Rem --------------------------------------------
  
CREATE OR REPLACE PACKAGE dbms_predictive_analytics AUTHID CURRENT_USER AS
  --
  -- PUBLIC PROCEDURES AND FUNCTIONS
  --

  -- Procedure: PREDICT
  -- The purpose of this procedure is to produce predictions for unknown
  -- targets. The input data table should contain records where the target
  -- value is known (not null). The known cases will be used to train and test
  -- a model. Any cases where the target is unknown, i.e. where the target
  -- value is null, will not be considered during model training. Once a
  -- mining model is built internally, it will be used to score all the
  -- records from the input data (both known and unknown), and a table will be
  -- persisted containing the results. In the case of binary classification,
  -- an ROC analysis of the results will be performed, and the predictions
  -- will be adjusted to support the optimal probability threshold resulting
  -- in the highest True Positive Rate (TPR) versus False Positive Rate (FPR).
  PROCEDURE predict(
                  accuracy            OUT NUMBER,
                  data_table_name     IN VARCHAR2,
                  case_id_column_name IN VARCHAR2,
                  target_column_name  IN VARCHAR2,
                  result_table_name   IN VARCHAR2,
                  data_schema_name    IN VARCHAR2 DEFAULT NULL);

  -- Procedure: EXPLAIN
  -- This procedure is used for identifying attributes that are important/
  -- useful for explaining the variation on an attribute of interest (e.g. a
  -- measure of an OLAP fact table). Only known cases (i.e. cases where the
  -- value of the explain column is not null) will be taken into consideration
  -- when assessing the importance of the input attributes upon the dependent
  -- attribute. The resulting table will contain one row for each of the input
  -- attributes.
  PROCEDURE explain(
                  data_table_name     IN VARCHAR2,
                  explain_column_name IN VARCHAR2,
                  result_table_name   IN VARCHAR2,
                  data_schema_name    IN VARCHAR2 DEFAULT NULL);

  -- Procedure: SEGMENT
  -- This procedure is used to segment similar records together. It uses
  -- segmentation analysis to identify groups embedded in the data, where a
  -- group is a collection of data objects that are similar to one another. The
  -- SEGMENT task can be applied to a wide range of business problems such as:
  -- customer segmentation, gene and protein analysis, product grouping,
  -- finding numerical taxonomies, and text mining.
--  PROCEDURE segment(
--                  data_table_name            IN VARCHAR2,
--                  case_id_column_name        IN VARCHAR2,
--                  segment_result_table_name  IN VARCHAR2,
--                  details_result_table_name  IN VARCHAR2,
--                  number_of_segments         IN NUMBER DEFAULT 10,
--                  max_descriptive_attributes IN NUMBER DEFAULT 5,
--                  data_schema_name           IN VARCHAR2 DEFAULT NULL);

  -- Procedure: DETECT
  -- This procedure is used to find anomalies or atypical records within sets of
  -- data. It can be described as an indicator of strange behavior Identifying
  -- such anomalies or outliers can be useful in problems such as fraud
  -- detection (insurance, tax, credit card, etc.) and computer network
  -- intrusion detection. Anomaly detection estimates whether a data point is
  -- typical for a given distribution or not. An atypical data point can be
  -- either an outlier or an instance of a previously unseen class.
--  PROCEDURE detect(
--                  data_table_name            IN VARCHAR2,
--                  case_id_column_name        IN VARCHAR2,
--                  result_table_name          IN VARCHAR2,
--                  detect_column_name         IN VARCHAR2 DEFAULT NULL,
--                  detection_rate             IN NUMBER DEFAULT 0.01,
--                  max_descriptive_attributes IN NUMBER DEFAULT 5,
--                  data_schema_name           IN VARCHAR2 DEFAULT NULL);

  -- Procedure: PROFILE
  -- This procedure is used to segment data based on some target attribute and
  -- value. It will create profiles or rules for records where the specific
  -- attribute and value exist, in some sense it can be seen directed or
  -- supervised segmentation. 
  PROCEDURE profile(
                  data_table_name     IN VARCHAR2,
                  target_column_name  IN VARCHAR2,
                  result_table_name   IN VARCHAR2,
                  data_schema_name    IN VARCHAR2 DEFAULT NULL);

END dbms_predictive_analytics;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_predictive_analytics
FOR sys.dbms_predictive_analytics
/
GRANT EXECUTE ON dbms_predictive_analytics TO PUBLIC
/
SHOW ERRORS
