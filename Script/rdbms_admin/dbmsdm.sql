Rem Copyright (c) 2002, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsdm.sql - dbms Data Mining
Rem
Rem    DESCRIPTION
Rem      This package provides routines for Data Mining operations
Rem      in an Oracle Server.
Rem
Rem    NOTES
Rem      The procedural option is needed to use this package. This package
Rem      must be created under SYS. Operations provided by this package
Rem      are performed under the current calling user, not under the package
Rem      owner SYS.
Rem
Rem    MODIFIED   (MM/DD/YY) 
REM    pstengar    07/31/09 - add PMML import
REM    bmilenov    06/15/09 - Bug-8661316: Add a new scoring setting to NMF
REM    amozes      05/06/08 - #(6868134): add force to drop_model
REM    ramkrish    04/17/07 - add xnal input to create_model
REM    dmukhin     03/04/08 - bug 6620177: ADP coefficients reversal
REM    pstengar    10/23/07 - bug 6439266: add score_criterion_type parameter
REM    dmukhin     02/09/07 - bug 5854733: remove coefficient reverse xform
REM    jyarmus     01/30/07 - add glm setting VIF for ridge
REM    dmukhin     12/13/06 - bug 5557333: AR scoping
REM    dmukhin     11/13/06 - lob performance
REM    dmukhin     10/06/06 - bug 5462460: alter reverse expression
REM    bmilenov    08/16/06 - Change missing value treatment constants
REM    bmilenov    08/07/06 - Bug #5447741 - GLM setting cleanup
REM    amozes      06/08/06 - add transform_coeff to NMF and SVM 
REM    amozes      05/23/06 - add get_model_transformations 
REM    bmilenov    05/25/06 - Add get_model_details_global 
REM    dmukhin     05/11/06 - prj 18876: scoring cost matrix
REM    dmukhin     03/27/06 - ADP: stack interface
REM    ramkrish    03/24/06 - add GLM 
REM    mmcracke    03/31/05 - Change public synonyms from DMSYS to SYS 
REM    mmcracke    02/07/05 - Add max_rule_length filter to 
REM                           get_association_rules. 
REM    gtang       02/04/05 - Fix bug #4107224 
REM    mmcracke    01/13/05 - Remove obsolete SVM delete_class API call 
REM    mmcracke    12/15/04 - Remove reference to DMSYS. 
REM    mmcracke    11/03/04 - Add filtering items to get_assocation_rules. 
REM    mmcracke    09/03/04 - Change name of topn parameter. 
REM    mmcracke    08/05/04 - Add top-N parameter to get_association_rules. 
REM    amozes      08/04/04 - make TREES singular 
REM    bmilenov    08/03/04 - Introduce SVM outlier rate setting
REM    xbarr       06/25/04 - xbarr_dm_rdbms_migration
REM    gtang       05/19/04 - add get_model_details_oc
REM    cbhagwat    05/19/04 - Remove ref to predictor variance
REM    jyarmus     05/14/04 - fix active learning parameter values
REM    bmilenov    05/10/04 - create constant for default kernel
REM    jyarmus     05/10/04 - add active learning
REM    amozes      04/21/04 - add support for decision tree builds 
REM    mmcracke    03/12/04 - Add delete_class API call for SVM
REM    gtang       02/18/04 - Adding O-Cluster model
REM    pstengar    10/31/03 - fixed order of parameters in create_model
REM    ramkrish    10/23/03 - replace predictor_variance w/ ai_mdl
REM    hyoon       10/22/03 - to add MDL for AI
REM    cbhagwat    10/17/03 - feature select renamed to feature_extract
REM    cbhagwat    09/23/03 - svm comments
REM    cbhagwat    09/15/03 - Remove NMFS_STOP_CRITERIA
REM    ramkrish    09/08/03 - Add get_model_details_svm
REM    cbhagwat    09/05/03 - KMN setting fixes
REM    pstengar    08/29/03 - Removed exposure of get_model_details
REM    cbhagwat    07/29/03 - Add settings (Attr Imp)
REM    cbhagwat    07/21/03 - Fix 3058974
REM    ramkrish    07/15/03 - fix rules for KM
REM    ramkrish    07/11/03 - remove compute_rules/histograms settings
REM    ramkrish    06/22/03 - chg BUILD to CREATE_MODEL
REM    gtang       06/16/03 - Change import_model() signature
REM    ramkrish    06/13/03 - remove get_target_values
REM    pstengar    06/02/03 - Added get_model_details returning XMLType
REM    gtang       06/04/03 - Fix tabulation in one line
REM    gtang       05/30/03 - change type of modelnames to varchar2
REM                           in import_model()
REM    ramkrish    05/30/03 - add get_frequent_itemsets
REM    ramkrish    05/29/03 - get_model_details_ar to get_association_rules
REM    cbhagwat    05/21/03 - kmns settings changes
REM    pstengar    05/19/03 - removed precesion_recall since
REM                           multi target is not supported
REM    pstengar    05/15/03 - Added get_default_settings table FUNCTION
REM                           and moved defaults to dmp_sec
REM    ramkrish    05/09/03 - code review changes
REM    cbhagwat    04/28/03 - renaming svms_tolerance
REM    pstengar    04/22/03 - Made dm_kmn_conv_tolerance NUMBER type
REM    cbhagwat    04/18/03 - approx => regression
REM    pstengar    04/17/03 - Removed "p_" from parameter names
REM    cbhagwat    04/16/03 - Package name change
REM    cbhagwat    04/08/03 - new input params in rank_apply
REM    pstengar    04/07/03 - Added parameters to compute specifications
REM    pstengar    04/03/03 - Made get_model_signature pipelined
REM    gtang       04/02/03 - Add model export/import
REM    pstengar    03/31/03 - Added get_model_settings
REM    cbhagwat    03/31/03 - Add nmf stop criteria enum
REM    ramkrish    03/27/03 - add get_model_details_abn
REM    cbhagwat    03/26/03 - remove named exceptions
REM    bbloom      03/24/03 - Fix constants for ABNS model types to be
REM                           strings rather than numbers
REM    pstengar    03/20/03 - Added cost matrix parameter to compute functions
REM    cbhagwat    03/25/03 - Desupport CLAS_COST_MATRIX setting
REM    bbloom      03/20/03 - Change "abns_nb_predictors" TO
REM                           "abns_max_nb_predictors"
REM    cbhagwat    03/20/03 - Adding rank_apply
REM    cbhagwat    03/14/03 - change complexity and std dev default for svm
REM    bbloom      03/04/03 - Fix algo_adaptive_bayes_network
REM    pstengar    03/03/03 - Added "DM_" prefix to public types
REM    mmcracke    03/03/03 - implement get_model_details_nmf
REM    bbloom      02/24/03 - Add default values for abn_param
REM    bbloom      02/20/03 - Add constants for ABN
REM    cbhagwat    02/20/03 - kmn-build
REM    cbhagwat    02/18/03 - add get_model_details_nb
REM    cbhagwat    02/13/03 - removing DATA_ settings
REM    mmcracke    02/12/03 - Add additional nmf default params
REM    pstengar    02/10/03 - Modified compute_confusion_matrix AND
REM                           compute lift signatures
REM    ramkrish    02/10/03 - add named exceptions
REM    cbhagwat    02/12/03 - km => cl
REM    cbhagwat    02/10/03 - Adding k-means get_model_details code
REM    cbhagwat    02/06/03 - change max ar rule length to 20
REM    cbhagwat    02/03/03 - change order
REM    ramkrish    01/30/03 - cleanup API signatures - add eval templates
REM    cbhagwat    01/29/03 - take data prep out
REM    cbhagwat    01/17/03 - implement get_model_details_ar
REM    cbhagwat    01/14/03 - Adding nmf constants
REM    ramkrish    01/10/03 - add get_model_details_ar
REM    cbhagwat    01/10/03 - continue svm
REM    cbhagwat    01/07/03 - supporting svm
REM    ramkrish    12/28/02 - fix comments on settings table
REM    cbhagwat    12/24/02 - code AR
REM    cbhagwat    12/17/02 - fix errors
REM    cbhagwat    12/16/02 - adding svm stubs
REM    pstengar    12/11/02 - Added get_target_values function
REM    cbhagwat    12/09/02 - case-id compulsory
REM    cbhagwat    12/03/02 - Changing lift signature
REM    cbhagwat    11/05/02 - name changes
REM    ramkrish    11/04/02 - fix signatures
REM    ramkrish    11/01/02 - reflect review comments
REM    cbhagwat    09/19/02 - defining constants etc
REM    cbhagwat    09/16/02 - Skeleton for pl/sql api
REM    mmcampos    04/15/02 - Add header and settings and enums constants
REM    dmukhin     02/15/02 - add more prototypes  
REM    ramkrish    01/11/02 - Creation    
Rem
  
REM ********************************************************************
REM THE FUNCTIONS SUPPLIED BY THIS PACKAGE AND ITS EXTERNAL INTERFACE
REM ARE RESERVED BY ORACLE AND ARE SUBJECT TO CHANGE IN FUTURE RELEASES.
REM ********************************************************************

REM ********************************************************************
REM THIS PACKAGE MUST NOT BE MODIFIED BY THE CUSTOMER.  DOING SO COULD
REM CAUSE INTERNAL ERRORS AND SECURITY VIOLATIONS IN THE RDBMS.
REM ********************************************************************

REM ********************************************************************
REM THIS PACKAGE MUST BE CREATED UNDER DMSYS.
REM ********************************************************************
  
CREATE OR REPLACE PACKAGE dbms_data_mining AUTHID CURRENT_USER AS

  ------------
  --  OVERVIEW
  --
  --     This package provides general purpose routines for Data Mining
  --     operations viz.
  --     . CREATE a MODEL against build data.
  --     . DROP an existing MODEL.
  --     . RENAME an existing MODEL.  
  --     . COMPUTE various metrics to test a model against the APPLY
  --       results on test data, with cost inputs
  --     . APPLY a model to (production) mining data
  --     . RANK the APPLY results based on cost and other factors
  --     . GET the MODEL SIGNATURE - i.e. retrieve the attributes
  --       that constitute the model and their relevant characteristics.
  --     . GET the MODEL DETAILS - i.e. retrieve the contents of
  --       the model - the specific patterns and rules that were used
  --       in making the prediction (in the case of predictive models),
  --       and/or the declarative rules (in the case of declarative models).
  --
  
  ------------------------
  -- RULES AND LIMITATIONS
  --
  --     The following rules apply in the specification of functions and 
  --     procedures in this package.
  --
  --     A function/procedure will raise an INVALID_ARGVAL exception if the
  --     the following restrictions are not followed in specifying values
  --     for parameters (unless otherwise specified):
  --
  --     1. Every BUILD operation MUST have the mining function
  --        name specified at the minimum.
  --     2. All schema object names, except models, should be maximum
  --        30 bytes in size.
  --     3. All model names should be maximum 25 bytes in size.
  --     4. The SETTINGS discussed below under CONSTANTS represent the name
  --        tags and values that act as column values in a user-created
  --        Settings Table, with a fixed schema and column types:
  --   
  --        SETTING_NAME  SETTING_VALUE
  --        varchar2(30)  varchar2(30)
  --
  --     5. For numerical settings, use TO_CHAR() to store them in the
  --        SETTING_VALUE column - the API will interpret the values.
  --
  --
  
  -----------
  -- SECURITY
  -- 
  --     Privileges are associated with the the caller of the procedures/
  --     functions in this package as follows:
  --     If the caller is an anonymous PL/SQL block, the procedures/functions
  --     are run with the privilege of the current user. 
  --     If the caller is a stored procedure, the procedures/functions are run
  --     using the privileges of the owner of the stored procedure.
  --

  ------------
  -- CONSTANTS
  --
  -- General Settings - Begin ------------------------------------------------

  -- Data Prep: Setting Names 
  prep_auto                CONSTANT VARCHAR2(30) := 'PREP_AUTO';

  -- Data Prep: Setting Values for prep_auto
  prep_auto_off            CONSTANT VARCHAR2(30) := 'OFF';
  prep_auto_on             CONSTANT VARCHAR2(30) := 'ON';

  -- Score Criterion Type: Setting Values for score_criterion_type
  score_criterion_probability CONSTANT VARCHAR2(30) := 'PROBABILITY';
  score_criterion_cost        CONSTANT VARCHAR2(30) := 'COST';

  -- Row Weights - Setting Name
  odms_row_weight_column_name    CONSTANT VARCHAR2(30) :=
    'ODMS_ROW_WEIGHT_COLUMN_NAME';

  -- Cost Matrix
  cost_matrix_type_score   CONSTANT VARCHAR2(30) := 'SCORE';
  cost_matrix_type_create  CONSTANT VARCHAR2(30) := 'CREATE';

  -- Missing Value Treatment - Setting Name
  odms_missing_value_treatment   CONSTANT VARCHAR2(30) :=
    'ODMS_MISSING_VALUE_TREATMENT';

  -- Missing Value Treatment: Setting Values for ODMS_MISSING_VALUE_TREATMENT
  odms_missing_value_mean_mode   CONSTANT VARCHAR2(30) := 
    'ODMS_MISSING_VALUE_MEAN_MODE';
  odms_missing_value_delete_row  CONSTANT VARCHAR2(30) := 
    'ODMS_MISSING_VALUE_DELETE_ROW';

  -- Transactional training data format: Setting Names
  odms_item_id_column_name       CONSTANT VARCHAR2(30) :=
    'ODMS_ITEM_ID_COLUMN_NAME';
  odms_item_value_column_name    CONSTANT VARCHAR2(30) :=
    'ODMS_ITEM_VALUE_COLUMN_NAME';

  -- General Settings - End -------------------------------------------------
  
  -----------   Function and Algorithm Settings - Begin ---------------------

  -- FUNCTION NAME (input as CREATE_MODEL parameter)
  --
  classification           CONSTANT VARCHAR2(30) := 'CLASSIFICATION';
  regression               CONSTANT VARCHAR2(30) := 'REGRESSION';
  clustering               CONSTANT VARCHAR2(30) := 'CLUSTERING';
  association              CONSTANT VARCHAR2(30) := 'ASSOCIATION';
  feature_extraction       CONSTANT VARCHAR2(30) := 'FEATURE_EXTRACTION';
  attribute_importance     CONSTANT VARCHAR2(30) := 'ATTRIBUTE_IMPORTANCE';

  -- FUNCTION: Setting Names (input to settings_name column in settings table)
  clas_priors_table_name   CONSTANT VARCHAR2(30) := 'CLAS_PRIORS_TABLE_NAME';
  clas_weights_table_name  CONSTANT VARCHAR2(30) := 'CLAS_WEIGHTS_TABLE_NAME';
  clas_cost_table_name     CONSTANT VARCHAR2(30) := 'CLAS_COST_TABLE_NAME';
  asso_max_rule_length     CONSTANT VARCHAR2(30) := 'ASSO_MAX_RULE_LENGTH';
  asso_min_confidence      CONSTANT VARCHAR2(30) := 'ASSO_MIN_CONFIDENCE';
  asso_min_support         CONSTANT VARCHAR2(30) := 'ASSO_MIN_SUPPORT';
  feat_num_features        CONSTANT VARCHAR2(30) := 'FEAT_NUM_FEATURES';
  clus_num_clusters        CONSTANT VARCHAR2(30) := 'CLUS_NUM_CLUSTERS';

  -- ALGORITHM Setting Name (input to settings_name column in settings table)
  --
  algo_name CONSTANT VARCHAR2(30) := 'ALGO_NAME';
  
  -- ALGORITHM: Setting Values for algo_name
  algo_naive_bayes               CONSTANT VARCHAR2(30) :=
    'ALGO_NAIVE_BAYES';
  algo_adaptive_bayes_network    CONSTANT VARCHAR2(30) :=
    'ALGO_ADAPTIVE_BAYES_NETWORK';
  algo_support_vector_machines   CONSTANT VARCHAR2(30) :=
    'ALGO_SUPPORT_VECTOR_MACHINES';
  algo_nonnegative_matrix_factor CONSTANT VARCHAR2(30) :=
    'ALGO_NONNEGATIVE_MATRIX_FACTOR';
  algo_apriori_association_rules CONSTANT VARCHAR2(30) :=
     'ALGO_APRIORI_ASSOCIATION_RULES';
  algo_kmeans                    CONSTANT VARCHAR2(30) :=
    'ALGO_KMEANS';
  algo_ocluster                  CONSTANT VARCHAR2(30) :=
    'ALGO_O_CLUSTER'; 
  algo_ai_mdl                    CONSTANT VARCHAR2(30) :=
    'ALGO_AI_MDL';
  algo_decision_tree             CONSTANT VARCHAR2(30) :=
    'ALGO_DECISION_TREE';
  algo_generalized_linear_model  CONSTANT VARCHAR2(30) :=
    'ALGO_GENERALIZED_LINEAR_MODEL';

  -- ALGORITHM SETTINGS AND VALUES
  --
  -- ABN: Setting Names
  abns_model_type          CONSTANT VARCHAR2(30) := 'ABNS_MODEL_TYPE';
  abns_max_build_minutes   CONSTANT VARCHAR2(30) := 'ABNS_MAX_BUILD_MINUTES';
  abns_max_predictors      CONSTANT VARCHAR2(30) := 'ABNS_MAX_PREDICTORS';
  abns_max_nb_predictors   CONSTANT VARCHAR2(30) := 'ABNS_MAX_NB_PREDICTORS';

  -- ABN: Setting Values for abns_model_type
  abns_multi_feature       CONSTANT VARCHAR2(30) := 'ABNS_MULTI_FEATURE';
  abns_single_feature      CONSTANT VARCHAR2(30) := 'ABNS_SINGLE_FEATURE';
  abns_naive_bayes         CONSTANT VARCHAR2(30) := 'ABNS_NAIVE_BAYES';
  
  -- NB: Setting Names
  nabs_pairwise_threshold  CONSTANT VARCHAR2(30) := 'NABS_PAIRWISE_THRESHOLD';
  nabs_singleton_threshold CONSTANT VARCHAR2(30) := 'NABS_SINGLETON_THRESHOLD';
  
  -- SVM: Setting Names
  -- NOTE: svms_epsilon applies only for SVM Regression
  --       svms_complexity_factor applies to both 
  --       svms_std_dev applies only for Gaussian Kernels
  --       kernel_cache_size to Gaussian kernels only
  svms_conv_tolerance      CONSTANT VARCHAR2(30) := 'SVMS_CONV_TOLERANCE';
  svms_std_dev             CONSTANT VARCHAR2(30) := 'SVMS_STD_DEV';
  svms_complexity_factor   CONSTANT VARCHAR2(30) := 'SVMS_COMPLEXITY_FACTOR';
  svms_kernel_cache_size   CONSTANT VARCHAR2(30) := 'SVMS_KERNEL_CACHE_SIZE';
  svms_epsilon             CONSTANT VARCHAR2(30) := 'SVMS_EPSILON';
  svms_kernel_function     CONSTANT VARCHAR2(30) := 'SVMS_KERNEL_FUNCTION';
  svms_active_learning     CONSTANT VARCHAR2(30) := 'SVMS_ACTIVE_LEARNING';
  svms_outlier_rate        CONSTANT VARCHAR2(30) := 'SVMS_OUTLIER_RATE';
  
  -- SVM: Setting Values for svms_kernel_function
  svms_linear              CONSTANT VARCHAR2(30) := 'SVMS_LINEAR';
  svms_gaussian            CONSTANT VARCHAR2(30) := 'SVMS_GAUSSIAN';
  
  -- SVM: Setting Values for svms_active_learning
  svms_al_enable           CONSTANT VARCHAR2(30) := 'SVMS_AL_ENABLE';
  svms_al_disable          CONSTANT VARCHAR2(30) := 'SVMS_AL_DISABLE';

  -- KMNS: Setting Names
  kmns_distance            CONSTANT VARCHAR2(30) := 'KMNS_DISTANCE';
  kmns_iterations          CONSTANT VARCHAR2(30) := 'KMNS_ITERATIONS';
  kmns_conv_tolerance      CONSTANT VARCHAR2(30) := 'KMNS_CONV_TOLERANCE';
  kmns_split_criterion     CONSTANT VARCHAR2(30) := 'KMNS_SPLIT_CRITERION';
  kmns_min_pct_attr_support CONSTANT VARCHAR2(30):= 'KMNS_MIN_PCT_ATTR_SUPPORT'; 
  kmns_block_growth        CONSTANT VARCHAR2(30) := 'KMNS_BLOCK_GROWTH';
  kmns_num_bins            CONSTANT VARCHAR2(30) := 'KMNS_NUM_BINS';
  
  -- KMNS: Setting Values for kmns_distance
  kmns_euclidean           CONSTANT VARCHAR2(30) := 'KMNS_EUCLIDEAN';
  kmns_cosine              CONSTANT VARCHAR2(30) := 'KMNS_COSINE';
  kmns_fast_cosine         CONSTANT VARCHAR2(30) := 'KMNS_FAST_COSINE';
  
  -- KMNS: Setting Values for kmns_split_criterion
  kmns_size                CONSTANT VARCHAR2(30) := 'KMNS_SIZE';   
  kmns_variance            CONSTANT VARCHAR2(30) := 'KMNS_VARIANCE';
  
  -- NMF: Setting Names
  nmfs_num_iterations      CONSTANT VARCHAR2(30) := 'NMFS_NUM_ITERATIONS';
  nmfs_conv_tolerance      CONSTANT VARCHAR2(30) := 'NMFS_CONV_TOLERANCE';
  nmfs_random_seed         CONSTANT VARCHAR2(30) := 'NMFS_RANDOM_SEED';     
  nmfs_nonnegative_scoring CONSTANT VARCHAR2(30) := 
                                          'NMFS_NONNEGATIVE_SCORING';
  -- Setting values for NMFS_NONNEGATIVE_SCORING
  nmfs_nonneg_scoring_enable CONSTANT VARCHAR2(30) := 
                                          'NMFS_NONNEG_SCORING_ENABLE';
  nmfs_nonneg_scoring_disable CONSTANT VARCHAR2(30) := 
                                          'NMFS_NONNEG_SCORING_DISABLE';
  
  -- OCLT: Setting Names for O-Cluster
  oclt_sensitivity         CONSTANT VARCHAR2(30) := 'OCLT_SENSITIVITY';
  oclt_max_buffer          CONSTANT VARCHAR2(30) := 'OCLT_MAX_BUFFER';

  -- TREE: Setting Names
  tree_impurity_metric     CONSTANT VARCHAR2(30) := 'TREE_IMPURITY_METRIC';
  tree_term_max_depth      CONSTANT VARCHAR2(30) := 'TREE_TERM_MAX_DEPTH';
  tree_term_minrec_split   CONSTANT VARCHAR2(30) := 'TREE_TERM_MINREC_SPLIT';
  tree_term_minpct_split   CONSTANT VARCHAR2(30) := 'TREE_TERM_MINPCT_SPLIT';
  tree_term_minrec_node    CONSTANT VARCHAR2(30) := 'TREE_TERM_MINREC_NODE';
  tree_term_minpct_node    CONSTANT VARCHAR2(30) := 'TREE_TERM_MINPCT_NODE';

  -- TREE: Setting Values for tree_impurity_metric
  tree_impurity_gini       CONSTANT VARCHAR2(30) := 'TREE_IMPURITY_GINI';
  tree_impurity_entropy    CONSTANT VARCHAR2(30) := 'TREE_IMPURITY_ENTROPY';
 
  -- GLM: Setting Names
  glms_ridge_regression    CONSTANT VARCHAR2(30) := 'GLMS_RIDGE_REGRESSION';
  glms_diagnostics_table_name    CONSTANT VARCHAR2(30) :=
    'GLMS_DIAGNOSTICS_TABLE_NAME';
  glms_reference_class_name      CONSTANT VARCHAR2(30) :=
    'GLMS_REFERENCE_CLASS_NAME';
  glms_ridge_value     CONSTANT VARCHAR2(30) := 'GLMS_RIDGE_VALUE';
  glms_conf_level     CONSTANT VARCHAR2(30) := 'GLMS_CONF_LEVEL';
  glms_vif_for_ridge     CONSTANT VARCHAR2(30) := 'GLMS_VIF_FOR_RIDGE';
  
  -- GLM: Setting Values for glms_ridge_regression
  glms_ridge_reg_enable    CONSTANT VARCHAR2(30) := 'GLMS_RIDGE_REG_ENABLE';
  glms_ridge_reg_disable   CONSTANT VARCHAR2(30) := 'GLMS_RIDGE_REG_DISABLE';
  
  -- GLM: Setting Values for glms_vif_for_ridge
  glms_vif_ridge_enable    CONSTANT VARCHAR2(30) := 'GLMS_VIF_RIDGE_ENABLE';
  glms_vif_ridge_disable   CONSTANT VARCHAR2(30) := 'GLMS_VIF_RIDGE_DISABLE';

  -----------   Function and Algorithm Settings - End ------------------------

  --------------
  -- LOCAL TYPES
  --
  SUBTYPE TRANSFORM_LIST IS dbms_data_mining_transform.TRANSFORM_LIST;

  -- Default values for model build settings
  TYPE default_settings_type IS TABLE OF VARCHAR2(30) INDEX BY VARCHAR2(30);
  external_default_settings default_settings_type;
  internal_default_settings default_settings_type;

  ---------------------------
  -- PROCEDURES AND FUNCTIONS
  --
  PROCEDURE apply(model_name          IN VARCHAR2,
                  data_table_name     IN VARCHAR2,
                  case_id_column_name IN VARCHAR2,
                  result_table_name   IN VARCHAR2,
                  data_schema_name    IN VARCHAR2 DEFAULT NULL);
 
  PROCEDURE compute_confusion_matrix(
                  accuracy                    OUT NUMBER,
                  apply_result_table_name     IN  VARCHAR2,
                  target_table_name           IN  VARCHAR2,
                  case_id_column_name         IN  VARCHAR2,
                  target_column_name          IN  VARCHAR2,
                  confusion_matrix_table_name IN  VARCHAR2,
                  score_column_name           IN  VARCHAR2 DEFAULT
                                                             'PREDICTION',
                  score_criterion_column_name IN  VARCHAR2 DEFAULT
                                                             'PROBABILITY',
                  cost_matrix_table_name      IN  VARCHAR2 DEFAULT NULL,
                  apply_result_schema_name    IN  VARCHAR2 DEFAULT NULL,
                  target_schema_name          IN  VARCHAR2 DEFAULT NULL,
                  cost_matrix_schema_name     IN  VARCHAR2 DEFAULT NULL,
                  score_criterion_type        IN  VARCHAR2 DEFAULT NULL);
  
  PROCEDURE compute_lift(
                  apply_result_table_name     IN VARCHAR2,
                  target_table_name           IN VARCHAR2,
                  case_id_column_name         IN VARCHAR2,
                  target_column_name          IN VARCHAR2,
                  lift_table_name             IN VARCHAR2,
                  positive_target_value       IN VARCHAR2,
                  score_column_name           IN VARCHAR2 DEFAULT
                                                            'PREDICTION',
                  score_criterion_column_name IN VARCHAR2 DEFAULT
                                                            'PROBABILITY',
                  num_quantiles               IN NUMBER   DEFAULT 10,
                  cost_matrix_table_name      IN VARCHAR2 DEFAULT NULL,
                  apply_result_schema_name    IN VARCHAR2 DEFAULT NULL,
                  target_schema_name          IN VARCHAR2 DEFAULT NULL,
                  cost_matrix_schema_name     IN VARCHAR2 DEFAULT NULL,
                  score_criterion_type        IN VARCHAR2 DEFAULT NULL);
 
  PROCEDURE compute_roc(
                  roc_area_under_curve        OUT NUMBER,
                  apply_result_table_name     IN  VARCHAR2,
                  target_table_name           IN  VARCHAR2,
                  case_id_column_name         IN  VARCHAR2,
                  target_column_name          IN  VARCHAR2,
                  roc_table_name              IN  VARCHAR2,
                  positive_target_value       IN  VARCHAR2,
                  score_column_name           IN  VARCHAR2 DEFAULT
                                                             'PREDICTION',
                  score_criterion_column_name IN  VARCHAR2 DEFAULT
                                                             'PROBABILITY',
                  apply_result_schema_name    IN  VARCHAR2 DEFAULT NULL,
                  target_schema_name          IN  VARCHAR2 DEFAULT NULL);
  
  PROCEDURE create_model(
                  model_name            IN VARCHAR2,
                  mining_function       IN VARCHAR2,
                  data_table_name       IN VARCHAR2,
                  case_id_column_name   IN VARCHAR2,
                  target_column_name    IN VARCHAR2 DEFAULT NULL,
                  settings_table_name   IN VARCHAR2 DEFAULT NULL,
                  data_schema_name      IN VARCHAR2 DEFAULT NULL,
                  settings_schema_name  IN VARCHAR2 DEFAULT NULL,
                  xform_list            IN TRANSFORM_LIST DEFAULT NULL);
 
  PROCEDURE drop_model(model_name IN VARCHAR2,
                       force      IN BOOLEAN DEFAULT FALSE);

  PROCEDURE export_model (filename      IN VARCHAR2,
                          directory     IN VARCHAR2,
                          model_filter  IN VARCHAR2 DEFAULT NULL,
                          filesize      IN VARCHAR2 DEFAULT NULL,
                          operation     IN VARCHAR2 DEFAULT NULL,
                          remote_link   IN VARCHAR2 DEFAULT NULL,
                          jobname       IN VARCHAR2 DEFAULT NULL);

  -- XML (PMML) versions of get model details
  FUNCTION get_model_details_xml(model_name IN VARCHAR2)
  RETURN XMLType;

  -- Specifying topn orders by confidence DESC, support DESC
  --   otherwise by rule_id
  FUNCTION get_association_rules(model_name       IN VARCHAR2,
                                 topn             IN NUMBER DEFAULT NULL,
                                 rule_id          IN INTEGER DEFAULT NULL,
                                 min_confidence   IN NUMBER DEFAULT NULL,
                                 min_support      IN NUMBER DEFAULT NULL,
                                 max_rule_length  IN INTEGER DEFAULT NULL,
                                 min_rule_length  IN INTEGER DEFAULT NULL,
                                 sort_order       IN ORA_MINING_VARCHAR2_NT DEFAULT NULL,
                                 antecedent_items IN DM_ITEMS DEFAULT NULL,
                                 consequent_items IN DM_ITEMS DEFAULT NULL,
                                 min_lift         IN NUMBER DEFAULT NULL)
  RETURN DM_Rules PIPELINED;

  -- Specifying topn orders by support DESC otherwise there
  --   is no ordering
  FUNCTION get_frequent_itemsets(model_name IN VARCHAR2,
                                 topn IN NUMBER DEFAULT NULL,
                                 max_itemset_length IN NUMBER DEFAULT NULL)
  RETURN DM_ItemSets PIPELINED;
  
  FUNCTION get_model_details_abn(model_name IN VARCHAR2)
  RETURN DM_ABN_Details PIPELINED;

  FUNCTION get_model_details_ai(model_name IN VARCHAR2)
  RETURN dm_ranked_attributes pipelined;
  
  FUNCTION get_model_details_glm(model_name IN VARCHAR2)
  RETURN DM_GLM_Coeff_Set PIPELINED;

  FUNCTION get_model_details_km(model_name VARCHAR2,
                                cluster_id NUMBER   DEFAULT NULL,
                                attribute  VARCHAR2 DEFAULT NULL,
                                centroid   NUMBER   DEFAULT 1,
                                histogram  NUMBER   DEFAULT 1,
                                rules      NUMBER   DEFAULT 2,
                                attribute_subname  VARCHAR2 DEFAULT NULL)
  RETURN dm_clusters PIPELINED;
 
  FUNCTION get_model_details_nb(model_name IN VARCHAR2)
  RETURN DM_NB_Details PIPELINED;

  FUNCTION get_model_details_nmf(model_name IN VARCHAR2)
  RETURN DM_NMF_Feature_Set PIPELINED;

  FUNCTION get_model_details_oc(model_name VARCHAR2,
                                cluster_id NUMBER   DEFAULT NULL,
                                attribute  VARCHAR2 DEFAULT NULL,
                                centroid   NUMBER   DEFAULT 1,
                                histogram  NUMBER   DEFAULT 1,
                                rules      NUMBER   DEFAULT 2)
  RETURN dm_clusters PIPELINED;

  FUNCTION get_model_details_svm(model_name   VARCHAR2,
                                 reverse_coef NUMBER DEFAULT 0)
  RETURN DM_SVM_Linear_Coeff_Set PIPELINED;
  
  FUNCTION get_model_details_global(model_name IN VARCHAR2)
  RETURN DM_model_global_details PIPELINED;
  
  FUNCTION get_model_settings(model_name IN VARCHAR2)
  RETURN DM_Model_Settings PIPELINED;

  FUNCTION get_default_settings
  RETURN DM_Model_Settings PIPELINED;

  FUNCTION get_model_signature(model_name IN VARCHAR2)
  RETURN DM_Model_Signature PIPELINED;
  
  FUNCTION get_model_transformations(model_name IN VARCHAR2)
  RETURN DM_Transforms PIPELINED;
  
  PROCEDURE get_transform_list(xform_list   OUT NOCOPY TRANSFORM_LIST,
                               model_xforms IN DM_TRANSFORMS);

  PROCEDURE import_model (filename        IN VARCHAR2,
                          directory       IN VARCHAR2,
                          model_filter    IN VARCHAR2 DEFAULT NULL,
                          operation       IN VARCHAR2 DEFAULT NULL,
                          remote_link     IN VARCHAR2 DEFAULT NULL,
                          jobname         IN VARCHAR2 DEFAULT NULL,
                          schema_remap    IN VARCHAR2 DEFAULT NULL);  
 
  PROCEDURE import_model (model_name      IN VARCHAR2,
                          pmmldoc         IN XMLTYPE); 
  
  PROCEDURE rank_apply(apply_result_table_name     IN VARCHAR2,
                       case_id_column_name         IN VARCHAR2,
                       score_column_name           IN VARCHAR2,
                       score_criterion_column_name IN VARCHAR2,
                       ranked_apply_table_name     IN VARCHAR2,
                       top_n                       IN INTEGER  DEFAULT 1,
                       cost_matrix_table_name      IN VARCHAR2 DEFAULT NULL,
                       apply_result_schema_name    IN VARCHAR2 DEFAULT NULL,
                       cost_matrix_schema_name     IN VARCHAR2 DEFAULT NULL);

  PROCEDURE rename_model(model_name     IN VARCHAR2,
                         new_model_name IN VARCHAR2);

  PROCEDURE add_cost_matrix(model_name              IN VARCHAR2,
                            cost_matrix_table_name  IN VARCHAR2,
                            cost_matrix_schema_name IN VARCHAR2 DEFAULT NULL);

  PROCEDURE remove_cost_matrix(model_name IN VARCHAR2);

  FUNCTION get_model_cost_matrix(model_name  IN VARCHAR2,
                                 matrix_type IN VARCHAR2 
                                                DEFAULT cost_matrix_type_score)
  RETURN DM_COST_MATRIX PIPELINED;

  PROCEDURE alter_reverse_expression(
    model_name                     VARCHAR2,
    expression                     CLOB,
    attribute_name                 VARCHAR2 DEFAULT NULL,
    attribute_subname              VARCHAR2 DEFAULT NULL);

END dbms_data_mining;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_data_mining FOR sys.dbms_data_mining
/
GRANT EXECUTE ON dbms_data_mining TO PUBLIC
/
SHOW ERRORS
