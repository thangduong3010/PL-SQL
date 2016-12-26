Rem
Rem Copyright (c) 2003, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsdmxf.sql - DBMS Data Mining XForms
Rem
Rem    DESCRIPTION
Rem      The main principle behind the design of this package is a fact that
Rem    SQL has enough power to efficiently perform most of the common mining
Rem    xforms. For example, binning can be done using CASE expression or DECODE
Rem    function, and linear normalization is just a simple algebraic expression
Rem    of the form (x - shift)/scale. However, the queries that perform the
Rem    xforms can be rather lengthy, thus it seems quite desirable to have some
Rem    convenience routines that will help in query generation. Thus, the goal
Rem    of this package is to provide query generation services for the most
Rem    common mining xforms, as well as to provide a framework that can be
Rem    easily extended for implementing other xforms.
Rem      Query generation (xfrom_*) is driven by a few simple xform specific
Rem    definition tables with a predefined schema. The tables can be created
Rem    either directly or by means of create_* routines. Query generation
Rem    routines should be viewed as macros, and xform definition tables as
Rem    parameters used in macro expansions. Similar to C #define  macros,
Rem    invoker is responsible for ensuring the correctness of the expanded
Rem    macro, in other words, that the result is a valid SQL query. Normally
Rem    consistency and integrity of xform definition tables is guaranteed by
Rem    the creation process. Alternatively it can be achieved by leveraging
Rem    integrity constraints mechanism. This can be done either by altering the
Rem    tables created with create_* routines, or by creating the tables
Rem    manually with the necessary integrity constraints.
Rem      Another form of query generation (xform_stack) is driven by the
Rem    in-memory transformation definition (transformation stack definition or
Rem    stack definition for short) that defines arbitrary transformations
Rem    represented as SQL expressions. These expressions can be either entered
Rem    manually or generated (stack_*) as a combination of multiple basic
Rem    transformations defined by transformation definition tables.
Rem      The most common way of defining the xform (populating the xform
Rem    definition tables) is based on the data inspection using some predefined
Rem    methods (also known as automatic xform definition). Some of the most
Rem    popular methods have been captured by insert_* routines. For example,
Rem    zscore normalization method estimates mean and standard deviation from
Rem    the data to be used as a shift and scale parameters of the linear
Rem    normalization xform. After performing automatic xform definition some or
Rem    all of the definitions can be adjusted by issuing DML statements
Rem    against the xfrom definition tables, thus providing virtually infinite
Rem    flexibility in defining custom xforms.
Rem      Most of the convenience routines are equivalent to one (or can be
Rem    viewed as one) of the SQL statements:
Rem      create_* - CREATE TABLE <table> (...)
Rem      insert_* - INSERT INTO <table> SELECT ...
Rem      xform_*  - CREATE VIEW <view> AS SELECT ...
Rem
Rem    NOTES
Rem      Internally input data is provided by p_*_tref parameters representing
Rem    table_reference clause allowed in the FROM clause of the SELECT
Rem    statement. The data is obtained by performing
Rem          SELECT * FROM p_*_tref
Rem
Rem      Internally output data is provided by p_*_texpr parameters
Rem    representing dml_table_expression clause allowed in the INTO clause of
Rem    the INSERT statement. The data is stored by performing
Rem          INSERT INTO p_*_texpr (...) VALUES (...)
Rem
Rem      Both transformation and stack definitions have two fields for
Rem    identifing mining attributes (COLumn and subATTribute or attribute name
Rem    and attribute subname). The second one is used for nested attributes.
Rem    For regular attributes it is set to NULL. In the examples when no nested
Rem    attributes are present the second field will be ommited for clarity.
Rem
Rem      Nested specification is used to specify a transform for an existing
Rem    nested column. It allows to specify different transformations for
Rem    different attributes in the nested column as well as a default (catch
Rem    all) specification for the ramaining attributes. The default
Rem    specification has NULL in the column field and the name of the nested
Rem    column in the subattribute field. For example, given a stack definition
Rem        {attr = COL1, subn = ATT1, expr = ("VALUE" - (-1.5))/20,
Rem                                   rexp = "VALUE"*20 + (-1.5)} 
Rem        {attr = COL1, subn = ATT2, expr = NULL,
Rem                                   rexp = NULL} 
Rem        {attr = NULL, subn = COL1, expr = "VALUE"/10,
Rem                                   rexp = "VALUE"*10} 
Rem    the following expression for COL1 is generated
Rem        CAST(MULTISET(SELECT DM_NESTED_NUMERICAL(
Rem                               "ATTRIBUTE_NAME",
Rem                               DECODE("ATTRIBUTE_NAME",
Rem                                 'ATT1', ("VALUE" - (-1.5))/20,
Rem                                 "VALUE"/10))
Rem                        FROM TABLE("COL1") 
Rem                       WHERE "ATTRIBUTE_NAME" IS NOT IN ('ATT2'))
Rem             AS DM_NESTED_NUMERICALS)
Rem    When default is not explicitly specified the default attributes remain
Rem    unchanged (i.e. it is treated as expresion "VALUE")
Rem        CAST(MULTISET(SELECT DM_NESTED_NUMERICAL(
Rem                               "ATTRIBUTE_NAME",
Rem                               DECODE("ATTRIBUTE_NAME",
Rem                                 'ATT1', ("VALUE" - (-1.5))/20,
Rem                                 "VALUE"))
Rem                        FROM TABLE("COL1") 
Rem                       WHERE "ATTRIBUTE_NAME" IS NOT IN ('ATT2'))
Rem             AS DM_NESTED_NUMERICALS)
Rem    Since DECODE is limited to 256 arguments, multiple DECODE functions are
Rem    nested to support an arbitrary number of attribute specifications. The
Rem    same is true for the exclusion list which is limited to 1000 elements.
Rem    Multiple lists can be concatenated with an AND/OR predicate. If the
Rem    default expression excludes the remaining attributes (NULL expression)
Rem    inclusion list is used instead of exclusion list to keep only explicitly
Rem    specified attributes. If there are no explicitly specified attribute
Rem    transformation the whole nested column is excluded. If there is only
Rem    a default specification DECODE function is omited
Rem        CAST(MULTISET(SELECT DM_NESTED_NUMERICAL(
Rem                               "ATTRIBUTE_NAME",
Rem                               "VALUE"/10)
Rem                        FROM TABLE("COL1") 
Rem                       WHERE "ATTRIBUTE_NAME" IS NOT IN ('ATT2'))
Rem             AS DM_NESTED_NUMERICALS)
Rem
Rem      The data type of the transformed nested column is determined by the
Rem    data type of individial nested expressions. If expressions have
Rem    different data types an arbitrary expression will be chosen to
Rem    determine the data type of the columns and the remaining expressions
Rem    will be coerced to the selected data type. If the selected expression
Rem    resolves to NUMBER the selected data type is NUMBER and the
Rem    corresponding nested type is DM_NESTED_NUMERICALS, othervise the
Rem    selected data type is VARCHAR2 and the corresponding nested type is 
Rem    DM_NESTED_CATEGORICALS.
Rem
Rem      Nested specification has the following restrictions:
Rem        1. It is used to specify a transform for an existing nested column,
Rem           it cannot be used for adding a new nested column.
Rem        2. Nested specification cannot be mixed with non-nested for the
Rem           same column.
Rem        3. Default nested expression should be valid (should not cause
Rem           run-time errors) for any attribute even those that have explicit
Rem           transformation.
Rem
Rem      STACK interfaces involving nested specifications have the following
Rem    additional rules:
Rem      1. When a nested attribute in the stack definition does not have an
Rem         exact match in the transformations definition, a default nested
Rem         specification from the transformation difinition is used if
Rem         available.
Rem      2. When adding a new nested specification to the stack it will be
Rem         initialized with expression of the default nested specification
Rem         from the stack definition is available.
Rem    For example, given a stack definition
Rem        {attr = COL1, subn = ATT1, expr = log(10, VALUE),
Rem                                   rexp = power(10, VALUE)} 
Rem        {attr = NULL, subn = COL1, expr = ln(VALUE),
Rem                                   rexp = exp(VALUE)}
Rem    and a transformation definition for normalization
Rem        {col = COL1, att = ATT2, shift = 0, scale = 20}
Rem        {col = NULL, att = COL1, shift = 0, scale = 10}
Rem    the following stack definition is generated
Rem        {attr = COL1, subn = ATT1, expr = (log(10, VALUE) - 0)/10,
Rem                                   rexp = power(10, VALUE*10 + 0)}
Rem        {attr = NULL, subn = COL1, expr = (ln(VALUE) - 0)/10,
Rem                                   rexp = exp(VALUE*10 + 0)}
Rem        {attr = COL1, subn = ATT2, expr = (ln(VALUE) - 0)/20,
Rem                                   rexp = exp(VALUE*20 + 0)}
Rem
Rem      When stacking on top of the excluded expression it remains excluded.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    mmcracke    01/11/11 - Add DESCRIBE_STACK which uses dbms_sql.desc_tab3
Rem    mmcracke    12/24/08 - Support alternate ADP table format
Rem    dmukhin     02/12/07 - bug 5532106: ADP column removal
Rem    dmukhin     01/05/07 - bug 5746322: attribute spec
Rem    dmukhin     11/03/06 - lob performance
Rem    dmukhin     06/01/06 - prj 18875: stack interface 
Rem    amozes      05/19/06 - 
Rem    dmukhin     03/24/06 - ADP: stack interface
Rem    dmukhin     03/24/06 - move package body to prvtdmxf.sql
Rem    dmukhin     02/02/05 - bug 4148499: use dbms_assert
Rem    dmukhin     01/12/05 - bug 4053211: add missing value treatment
Rem    dmukhin     12/23/04 - bug 4075208: parameter sample_size is not used
Rem    dmukhin     10/28/04 - clean up
Rem    dmukhin     10/06/04 - add scale normalization
Rem    gtang       09/10/04 - Typo correction
Rem    gtang       08/26/04 - Add max number of bins in autobin for security 
Rem                           purposes 
Rem    gtang       08/13/04 - rename max_buffer to sample_size in autobin 
Rem    gtang       08/09/04 - Fix bug #3785785 
Rem    gtang       07/15/04 - Refine checking empty exclusion list 
Rem    gtang       07/14/04 - Fix bug #3742118 
Rem    xbarr       06/25/04 - xbarr_dm_rdbms_migration
Rem    gtang       04/28/04 - fix debugging code
Rem    gtang       02/23/04 - add adaptive binning
Rem    dmukhin     09/25/03 - add trimming and winsorizing
Rem    dmukhin     09/12/03 - open source dbmsdmxf
Rem    dmukhin     09/02/03 - synchronize dbms_dm_xform and dm_xform
Rem    dmukhin     04/15/03 - rework xforms
Rem    dmukhin     01/15/03 - Created
Rem

CREATE OR REPLACE PACKAGE dbms_data_mining_transform AUTHID CURRENT_USER AS 
  -----------------------------------------------------------------------------
  -- COLUMN LIST collection type
  -----------------------------------------------------------------------------
  -- This type is used to store both quoted and non-quoted identifiers for 
  -- column names of a table.
  TYPE
    COLUMN_LIST                    IS VARRAY(1000) OF VARCHAR2(32);

  -----------------------------------------------------------------------------
  -- DESCribe LIST collection TYPE
  -----------------------------------------------------------------------------
  -- This type holds the results of describe operations. Note that col_name 
  -- field of DESC_TAB2 is VARCHAR2(32767). This is applicable to cases when a
  -- SELECT expression is not given an alias and thus the expression itself is
  -- used as name (with whitespaces removed) and thus can be larger than 30
  -- bytes. However when those names get larger than 30 bytes the corresponding
  -- SELECT cannot be used as an inline view.
  SUBTYPE
    DESCRIBE_LIST                  IS dbms_sql.DESC_TAB2;

  SUBTYPE
    DESCRIBE_LIST3                 IS dbms_sql.DESC_TAB3;

  -----------------------------------------------------------------------------
  -- EXPRESSION RECord type
  -----------------------------------------------------------------------------
  -- This type is used for storing transformation expressions. Unlike VARCHAR2
  -- it can be used for expression that can grow larger than 32K. Field lb is
  -- the smallest index and ub is the largest index of the elements of the
  -- VARCHAR2A array.
  TYPE 
    EXPRESSION_REC                 IS RECORD (
      lstmt                          dbms_sql.VARCHAR2A,
      lb                             BINARY_INTEGER DEFAULT 1,
      ub                             BINARY_INTEGER DEFAULT 0);

  -----------------------------------------------------------------------------
  -- TRAMSFORMation RECord type
  -----------------------------------------------------------------------------
  -- This type is used for storing in-memory transformation stack definition
  -- for a single attribute.
  -- Attribute specification field is used to specify additional information
  -- and actions for an attribute:
  --   NOPREP - disables data prep for an attribute.
  --            This is applicable to both stack_* interfaces in this package
  --            as well as dbms_data_mining.create_model. Stack_* methods do
  --            not do any stacking for attributes with NOPREP specified, while
  --            create_model does not do any auto data prep even when the
  --            global PREP_AUTO setting is set to ON.
  TYPE
    TRANSFORM_REC                  IS RECORD (
      attribute_name                 VARCHAR2(30),
      attribute_subname              VARCHAR2(4000),
      expression                     EXPRESSION_REC,
      reverse_expression             EXPRESSION_REC,
      attribute_spec                 VARCHAR2(4000));

  -----------------------------------------------------------------------------
  -- TRAMSFORMation LIST collection type
  -----------------------------------------------------------------------------
  -- This type is used for storing in-memory transformation stack definition.
  TYPE
    TRANSFORM_LIST                 IS TABLE OF TRANSFORM_REC;

  -----------------------------------------------------------------------------
  -- NESTed COLumn TYPEs
  -----------------------------------------------------------------------------
  nest_num_col_type              CONSTANT NUMBER := 100001;
  nest_cat_col_type              CONSTANT NUMBER := 100002;

  nest_nums_col_name        CONSTANT VARCHAR2(20) := 'DM_NESTED_NUMERICALS';
  nest_cats_col_name        CONSTANT VARCHAR2(22) := 'DM_NESTED_CATEGORICALS';

  -----------------------------------------------------------------------------
  --                            create_col_rem                               --
  -----------------------------------------------------------------------------
  -- NAME
  --   create_col_rem - CREATE COLumn REMoval definition table
  -- DESCRIPTION
  --   Creates column removal definition table:
  --       CREATE TABLE <col_rem>(
  --         col   VARCHAR2(30),
  --         att   VARCHAR2(4000))
  --   This table is used to guide query generation process that removes
  --   specified columns.
  -- PARAMETERS
  --   rem_table_name                 - column removal definition table
  --   rem_schema_name                - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers. It is allowed to have multiple entries in the xform
  --   defintion table for the same {col}.
  -----------------------------------------------------------------------------
  PROCEDURE create_col_rem(
    rem_table_name                 VARCHAR2,
    rem_schema_name                VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              xform_col_rem                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_col_rem - XFORMation COLumn REMoval
  -- DESCRIPTION
  --   Creates a view that perfoms column removal from the data table. Only the
  --   columns that are specified in the xform definition are removed, the
  --   remaining columns do not change.
  -- PARAMETERS
  --   rem_table_name                 - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   rem_schema_name                - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE xform_col_rem(
    rem_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    rem_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              stack_col_rem                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   stack_col_rem - STACK COLumn REMoval 
  -- DESCRIPTION
  --   For every column in the stack definition that has a matching entry in
  --   the transformation definition, stacks column removal expression (NULL
  --   expression) instead of the existing expression and updates the stack
  --   definition. Columns in the stack definition that have no matching
  --   entries in the transformation definition or have NULL expression are not
  --   changed. Columns in the transformation definition that have no matching
  --   entries in the stack definition are added to the stack definition (with
  --   NULL expression). Reverse expressions in the stack definition are
  --   updated accordingly, that is if an expression is updated, added or
  --   remains unchanged then a corresponding reverse expression is also
  --   updated, added or remains unchanged. When reverse expression is NULL it
  --   is treated as "{attr}" (identity function) or "VALUE" for nested
  --   columns. Given an entry ({attr}, {expr}, {rexp}) in the stack definition
  --   and a matching entry in the transformation definition, after stacking
  --   {expr} and {rexp} are both changed to NULL.
  --   Example 1. Given transformation definition:
  --       {col = COL1, att = NULL}
  --       {col = COL2, att = NULL}
  --   and stack definition:
  --       {attr = COL1, expr = log(10, COL1), rexp = power(10, COL1)} 
  --       {attr = COL3, expr = ln(COL3),      rexp = exp(COL3)} 
  --   the following updated stack definition is generated:
  --       {attr = COL1, expr = NULL,     rexp = NULL}
  --       {attr = COL3, expr = ln(COL3), rexp = exp(COL3)}
  --       {attr = COL2, expr = NULL,     rexp = NULL}
  -- PARAMETERS
  --   rem_table_name                 - xform definition table
  --   xform_list                     - stack definition
  --   rem_schema_name                - xform definition table schema name
  -- RETURNS
  --   xform_list                     - updated stack definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE stack_col_rem(
    rem_table_name                 VARCHAR2,
    xform_list                     IN OUT NOCOPY TRANSFORM_LIST,
    rem_schema_name                VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                            create_norm_lin                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   create_norm_lin - CREATE LINear NORMalization definition table
  -- DESCRIPTION
  --   Creates linear normalization definition table:
  --       CREATE TABLE <norm_lin>(
  --         col   VARCHAR2(30),
  --         att   VARCHAR2(4000),
  --         shift NUMBER,
  --         scale NUMBER)
  --   This table is used to guide query generation process to construct
  --   linear normalization expressions of the following form:
  --       ("{col}" - {shift})/{scale} "{col}"
  --   For example when col = 'my_col', shift = -1.5 and scale = 20 the 
  --   following expression is generated:
  --       ("my_col" - (-1.5))/20 "my_col"
  -- PARAMETERS
  --   norm_table_name                - linear normalization definition table
  --   norm_schema_name               - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers.  When there are multiple entries in the xform defintion 
  --   table for the same {col} the behavior is undefined.  Any one of the 
  --   definitions may be used in query generation. NULL values remain 
  --   unchanged.
  -----------------------------------------------------------------------------
  PROCEDURE create_norm_lin(
    norm_table_name                VARCHAR2,
    norm_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                          insert_norm_lin_minmax                         --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_norm_lin_minmax - INSERT into LINear NORMalization MINMAX
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds normalization definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the min
  --   and max values that are computed from the data table:
  --       shift = min
  --       scale = max - min
  --   The values of shift and scale are rounded to round_num significant 
  --   digits prior to storing them in the definition table.
  -- PARAMETERS
  --   norm_table_name                - linear normalization definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   norm_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored.
  -----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin_minmax(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                          insert_norm_lin_scale                          --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_norm_lin_scale - INSERT into LINear NORMalization SCALE
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds normalization definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the min
  --   and max values that are computed from the data table:
  --       shift = 0
  --       scale = greatest(abs(max), abs(min))
  --   The value of scale is rounded to round_num significant digits prior to
  --   storing it in the definition table.
  -- PARAMETERS
  --   norm_table_name                - linear normalization definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   norm_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or all zeros are ignored.
  -----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin_scale(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                          insert_norm_lin_zscore                         --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_norm_lin_zscore - INSERT into LINear NORMalization Z-SCORE
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds normalization definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the 
  --   mean and standard deviation that are estimated from the data table:
  --       shift = mean
  --       scale = stddev
  --   The values of shift and scale are rounded to round_num significant 
  --   digits prior to storing them in the definition table.
  -- PARAMETERS
  --   norm_table_name                - linear normalization definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   norm_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored.
  -----------------------------------------------------------------------------
  PROCEDURE insert_norm_lin_zscore(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              xform_norm_lin                             --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_norm_lin - XFORMation LINear NORMalization
  -- DESCRIPTION
  --   Creates a view that perfoms linear normalization of the data table 
  --   Only the columns that are specified in the xform definition are 
  --   normalized, the remaining columns do not change.
  -- PARAMETERS
  --   norm_table_name                - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   norm_schema_name               - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE xform_norm_lin(
    norm_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    norm_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              stack_norm_lin                             --
  -----------------------------------------------------------------------------
  -- NAME
  --   stack_norm_lin - STACK LINear NORMalization
  -- DESCRIPTION
  --   For every column in the stack definition that has a matching entry in
  --   the transformation definition, stacks linear normalization expression on
  --   top of the existing expression and updates the stack definition.
  --   Columns in the stack definition that have no matching entries in the
  --   transformation definition or have NULL expression are not changed.
  --   Columns in the transformation definition that have no matching entries
  --   in the stack definition are added to the stack definition (using "{col}"
  --   in place of the original expression or "VALUE" for nested attributes).
  --   Reverse expressions in the stack definition are updated accordingly,
  --   that is if an expression is updated, added or remains unchanged then a
  --   corresponding reverse expression is also updated, added or remains
  --   unchanged. When reverse expression is NULL it is treated as identity
  --   function ("{attr}" or "VALUE" for nested attributes).
  --   Given an entry ({attr}, {expr}, {rexp}) in the stack definition and a
  --   matching entry in the transformation definition, after stacking {expr}
  --   has the following form:
  --       ({expr} - {shift})/{scale}
  --   and {rexp} maintains the following form with every occurance of {attr}
  --   replaced with:
  --       {attr}*{scale} + {shift}
  --   Example 1. Given transformation definition:
  --       {col = COL1, shift = -1.5, scale = 20}
  --       {col = COL2, shift = 0,    scale = 10}
  --   and stack definition:
  --       {attr = COL1, expr = log(10, COL1), rexp = power(10, COL1)} 
  --       {attr = COL3, expr = ln(COL3),      rexp = exp(COL3)} 
  --   the following updated stack definition is generated:
  --       {attr = COL1,
  --        expr = (log(10, COL1) - (-1.5)) / 20,
  --        rexp = power(10, COL1*20 + (-1.5))}
  --       {attr = COL3,
  --        expr = ln(COL3),
  --        rexp = exp(COL3)}
  --       {attr = COL2,
  --        expr = (COL2 - 0) / 10,
  --        rexp = COL2*10 + 0}
  -- PARAMETERS
  --   norm_table_name                - xform definition table
  --   xform_list                     - stack definition
  --   norm_schema_name               - xform definition table schema name
  -- RETURNS
  --   xform_list                     - updated stack definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE stack_norm_lin(
    norm_table_name                VARCHAR2,
    xform_list                     IN OUT NOCOPY TRANSFORM_LIST,
    norm_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                            create_bin_num                               --
  -----------------------------------------------------------------------------
  -- NAME
  --   create_bin_num - CREATE NUMerical BINning definition table
  -- DESCRIPTION
  --   Creates numerical binning definition table:
  --       CREATE TABLE <bin_num>(
  --         col   VARCHAR2(30),
  --         att   VARCHAR2(4000),
  --         val   NUMBER,
  --         bin   VARCHAR2(4000))
  --   This table is used to guide query generation process to construct
  --   numerical binning expressions of the following form:
  --       CASE WHEN "{col}" <  {val0}   THEN '{bin0}'
  --            WHEN "{col}" <= {val1}   THEN '{bin1}'
  --            ...
  --            WHEN "{col}" <= {valN}   THEN '{binN}'
  --            WHEN "{col}" IS NOT NULL THEN '{bin(N+1)}'
  --       END "{col}"
  --   This expression maps values in the range [{val0};{valN}] into N bins
  --   {bin1}, ..., {binN}, values outside of this range into {bin0} or 
  --   {bin(N+1)}, such that 
  --       (-inf; {val0})       -> {bin0}
  --       [{val0}; {val1}]     -> {bin1}
  --       ... 
  --       ({val(N-1)}; {valN}] -> {binN}
  --       ({valN}; +inf)       -> {bin(N+1)}.
  --   NULL values remain unchanged. {bin(N+1)} is optional. If it is not 
  --   specified the values ("{col}" > {valN}) are mapped to NULL. To specify
  --   {bin(N+1)} provide a row with {val} = NULL. The order of the WHEN .. 
  --   THEN pairs is based on the ascending order of {val} for a given {col}.
  --   Example 1. <bin_num> contains four rows with {col} = 'mycol':
  --       {col = 'mycol', val = 15.5, bin = 'small'}
  --       {col = 'mycol', val = 10,   bin = 'tiny'}
  --       {col = 'mycol', val = 20,   bin = 'large'}
  --       {col = 'mycol', val = NULL, bin = 'huge'}
  --   the following expression is generated:
  --       CASE WHEN "mycol" <  10       THEN 'tiny'
  --            WHEN "mycol" <= 15.5     THEN 'small'
  --            WHEN "mycol" <= 20       THEN 'large'
  --            WHEN "mycol" IS NOT NULL THEN 'huge'
  --       END "mycol"
  --   Example 2. <bin_num> contains three rows with {col} = 'mycol':
  --       {col = 'mycol', val = 15.5, bin = NULL}
  --       {col = 'mycol', val = 10,   bin = 'tiny'}
  --       {col = 'mycol', val = 20,   bin = 'large'}
  --   the following expression is generated:
  --       CASE WHEN "mycol" <  10   THEN NULL
  --            WHEN "mycol" <= 15.5 THEN 'small'
  --            WHEN "mycol" <= 20   THEN 'large'
  --       END "mycol"
  -- PARAMETERS
  --   bin_table_name                 - numerical binning definition table
  --   bin_schema_name                - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers. In cases when there are multiple entries with the same 
  --   {col}, {val} combiniation with different {bin} the behavior is 
  --   undefined. Any one of the {bin} might be used. The maximum number of 
  --   arguments in a CASE expression is 255, and each WHEN ... THEN pair 
  --   counts as two arguments.
  -----------------------------------------------------------------------------
  PROCEDURE create_bin_num(
    bin_table_name                 VARCHAR2,
    bin_schema_name                VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                          insert_bin_num_eqwidth                         --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_bin_num_eqwidth - INSERT into NUMerical BINning EQual-WIDTH
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds numerical binning definition and inserts it into the
  --   definition table. Definition for each relevant column is computed based
  --   on the min and max values that are computed from the data table. Each
  --   of the N (p_bin_num) bins {bin1}, ..., {binN} span ranges of equal
  --   width
  --       inc = (max - min) / N
  --   where {binI} = I when N > 0 or {binI} = N+1-I when N < 0, and 
  --   {bin0} = {bin(N+1)} = NULL. For example, when N=2, col='mycol', min=10,
  --   and max = 21, the following three rows are inserted into the 
  --   definition table (inc = 5.5):
  --       COL     VAL BIN
  --       ----- ----- -----
  --       mycol    10 NULL
  --       mycol  15.5 1
  --       mycol    21 2
  --   The values of {val} are rounded to round_num significant digits prior
  --   to storing them in the definition table.
  -- PARAMETERS
  --   bin_table_name                 - numerical binning definition table
  --   data_table_name                - data table
  --   bin_num                        - number of bins
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   bin_schema_name                - definition table schema name 
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored. Nothing
  --   is done when bin_num IS NULL or bin_num = 0.
  -----------------------------------------------------------------------------
  PROCEDURE insert_bin_num_eqwidth(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 10,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                          insert_bin_num_qtile                           --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_bin_num_qtile - INSERT into NUMerical BINning QuanTILE
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds numerical binning definition and inserts it into the
  --   definition table. Definition for each relevant column is computed based
  --   on the min values per quantile, where quantiles are computed from the
  --   data using NTILE function. Bin {bin1} spans range [min(1), min(2)],
  --   bins {bin2}, ..., {bin(N-1)} span ranges (min(I), min(I+1)] and {binN}
  --   range (min(N), max(N)] with {binI} = I when N > 0 or {binI} = N+1-I
  --   when N < 0, and {bin0}={bin(N+1)} = NULL. Bins with equal left and
  --   right boundaries are collapsed. For example, when N=4, col='mycol',
  --   and data is {1,2,2,2,2,3,4}, the following three rows are inserted into
  --   the definition table:
  --       COL     VAL BIN
  --       ----- ----- -----
  --       mycol     1 NULL
  --       mycol     2 1
  --       mycol     4 2
  --   Here quantiles are {1,2}, {2,2}, {2,3}, {4} and min(1) = 1, min(2) = 2,
  --   min(3) = 2, min(4) = 4, max(4) = 4, and ranges are [1,2], (2,2], (2,4],
  --   (4,4]. After collapsing [1,2], (2,4].
  -- PARAMETERS
  --   bin_table_name                 - numerical binning definition table
  --   data_table_name                - data table
  --   bin_num                        - number of bins
  --   exclude_list                   - column exclusion list
  --   bin_schema_name                - definition table schema name 
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored. Nothing
  --   is done when bin_num IS NULL or bin_num = 0.
  -----------------------------------------------------------------------------
  PROCEDURE insert_bin_num_qtile(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 10,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                      insert_autobin_num_eqwidth                         --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_autobin_num_eqwidth - INSERT into NUMerical BINning AUTOmated
  --                                EQual-WIDTH
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds numerical binning definition and inserts it into the
  --   definition table. Definition for each relevant column is computed using
  --   equal-width method (see description for insert_bin_nume_eqwidth). The
  --   number of bins (N) is computed for each column separately and is based
  --   on the number of non-NULL values (cnt), min and max values, and the
  --   standard deviation (dev)
  --       N = floor(power(cnt, 1/3)*(max - min)/(C*dev))
  --   where C = 3.49/0.9. Parameter bin_num is used to adjust N to be at
  --   least bin_num. No adjustment is done when bin_num is NULL or zero.
  --   Parameter max_bin_num is used to adjust N to be at most max_bin_num.
  --   No adjustment is done when max_bin_num is NULL or zero. For columns
  --   with all integer values (discrete columns) N is adjusted to be at most
  --   the maximum number of distinct values in the obseved range
  --       max - min + 1
  --   Parameter sample_size is used to adjust cnt to be at most sample_size.
  --   No adjustment is done when sample_size is NULL or zero.
  -- PARAMETERS
  --   bin_table_name                 - numerical binning definition table
  --   data_table_name                - data table
  --   bin_num                        - minimum number of bins
  --   max_bin_num                    - maximum number of bins
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   sample_size                    - maximum size of the sample
  --   bin_schema_name                - definition table schema name
  --   data_schema_name               - data table schema name
  --   rem_table_name                 - column removal definition table
  --   rem_schema_name                - removal definition table schema
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs or only one unique value are ignored. The sign
  --   of bin_num, max_bin_num, sample_size has no effect on the result, only
  --   the absolute values are being used. The value adjustment for N is done
  --   in the following order: first, bin_num, then max_bin_num, and then
  --   discrete column adjustment.
  --   Column removal definition table is optional. If specified columns with
  --   all NULLs or only one unique value will be inserted into the column
  --   removal definition table.
  -----------------------------------------------------------------------------
  PROCEDURE insert_autobin_num_eqwidth(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 3,
    max_bin_num                    PLS_INTEGER DEFAULT 100,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    sample_size                    PLS_INTEGER DEFAULT 50000,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    rem_table_name                 VARCHAR2 DEFAULT NULL,
    rem_schema_name                VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              xform_bin_num                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_bin_num - XFORMation NUMerical BINning 
  -- DESCRIPTION
  --   Creates a view that perfoms numerical binning of the data table. Only
  --   the columns that are specified in the xform definition are binned, the
  --   remaining columns do not change.
  -- PARAMETERS
  --   bin_table_name                 - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   literal_flag                   - literal flag
  --   bin_schema_name                - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Literal flag indicates whether the values in {bin} are valid SQL 
  --   literals. When the the flag is set to TRUE the value of {bin} is used 
  --   as is in query generation, otherwise it is converted into a valid text
  --   literal (surround by quotes and double the quotes inside). By default 
  --   the flag is set to FALSE. One example when it can be set to TRUE is in
  --   cases when all {bin} are numbers. In that case the xformed column will
  --   remain numeric as opposed to textual (default behavior). For example,
  --   for the following xfrom definition:
  --       COL     VAL BIN
  --       ----- ----- -----
  --       mycol    10 NULL
  --       mycol  15.5 1
  --       mycol    21 2
  --   the following expression is generated when the flag is set to FALSE:
  --       CASE WHEN "mycol" <  10   THEN NULL
  --            WHEN "mycol" <= 15.5 THEN '1'
  --            WHEN "mycol" <= 20   THEN '2'
  --       END "mycol"
  --   and when the flag is set to TRUE:
  --       CASE WHEN "mycol" <  10   THEN NULL
  --            WHEN "mycol" <= 15.5 THEN 1
  --            WHEN "mycol" <= 20   THEN 2
  --       END "mycol"
  -----------------------------------------------------------------------------
  PROCEDURE xform_bin_num(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    literal_flag                   BOOLEAN DEFAULT FALSE,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              stack_bin_num                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   stack_bin_num - STACK NUMerical BINning 
  -- DESCRIPTION
  --   For every column in the stack definition that has a matching entry in
  --   the transformation definition, stacks numerical binning expression on
  --   top of the existing expression and updates the stack definition.
  --   Columns in the stack definition that have no matching entries in the
  --   transformation definition or have NULL expression are not changed.
  --   Columns in the transformation definition that have no matching entries
  --   in the stack definition are added to the stack definition (using "{col}"
  --   in place of the original expression or "VALUE" for nested attributes).
  --   Reverse expressions in the stack definition are updated accordingly,
  --   that is if an expression is updated, added or remains unchanged then a
  --   corresponding reverse expression is also updated, added or remains
  --   unchanged. When reverse expression is NULL it is treated as identity
  --   function ("{attr}" or "VALUE" for nested attributes).
  --   Given an entry ({attr}, {expr}, {rexp}) in the stack definition and a
  --   matching entry in the transformation definition, after stacking {expr}
  --   has the following form:
  --       CASE WHEN ({expr}) <  {val0}   THEN '{bin0}'
  --            WHEN ({expr}) <= {val1}   THEN '{bin1}'
  --            ...
  --            WHEN ({expr}) <= {valN}   THEN '{binN}'
  --            WHEN ({expr}) IS NOT NULL THEN '{bin(N+1)}'
  --       END
  --   and {rexp} has the following form:
  --       DECODE("{attr}", '{bin0}',     '( ; {rev0})',
  --                        '{bin1}',     '[{rev0}; {rev1})',
  --                        ...
  --                        '{binN}',     '[{rev(N-1)}; {revN}]',
  --                        '{bin(N+1)}', '({revN}; )',
  --                        NULL,         'NULL')
  --   where {revI} is the result of applying reverese expression to {valI}.
  --   If {binI} and {binJ} are equal then the corresponding entries of the
  --   DECODE function above are merged into:
  --       '{binI}', '[{rev(I-1)}; {revI}), [{rev(J-1)}; {revJ})'
  --   Note that reverse expressions implicitly maps invalid bins to NULL.
  --   Example 1. Given transformation definition:
  --       {col = COL1, val = 0,   bin = NULL}
  --       {col = COL1, val = 1,   bin = A}
  --       {col = COL1, val = 2,   bin = B}
  --       {col = COL1, val = 3,   bin = A}
  --       {col = COL2, val = 10,  bin = NULL}
  --       {col = COL2, val = 15,  bin = 1}
  --       {col = COL2, val = 20,  bin = 2}
  --   and stack definition:
  --       {attr = COL1, expr = log(10, COL1), rexp = power(10, COL1)} 
  --       {attr = COL3, expr = ln(COL3),      rexp = exp(COL3)} 
  --   the following updated stack definition is generated:
  --       {attr = COL1,
  --        expr = CASE WHEN (log(10, COL1)) <  0 THEN NULL
  --                    WHEN (log(10, COL1)) <= 1 THEN 'A'
  --                    WHEN (log(10, COL1)) <= 2 THEN 'B'
  --                    WHEN (log(10, COL1)) <= 3 THEN 'A' END,
  --        rexp = DECODE("COL1", 'A',   '[1; 10), [100; 1000]',
  --                              'B',   '[10; 100)',
  --                               NULL, '( ; 1), (1000; ), NULL')}
  --       {attr = COL3,
  --        expr = ln(COL3),
  --        rexp = exp(COL3)}
  --       {attr = COL2,
  --        expr = CASE WHEN "COL2" <  10 THEN NULL
  --                    WHEN "COL2" <= 15 THEN '1'
  --                    WHEN "COL2" <= 20 THEN '2' END
  --        rexp = DECODE("COL2", '1',  '[10; 15)',
  --                              '2',  '[15; 20]',
  --                              NULL, '( ; 10) OR (20; ) OR NULL')}
  -- PARAMETERS
  --   bin_table_name                 - xform definition table
  --   xform_list                     - stack definition
  --   literal_flag                   - literal flag
  --   bin_schema_name                - xform definition table schema name
  -- RETURNS
  --   xform_list                     - updated stack definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Literal flag indicates whether the values in {bin} are valid SQL 
  --   literals. When the the flag is set to TRUE the value of {bin} is used 
  --   "as is" in the expression generation, otherwise it is converted into a
  --   valid text literal (surround by quotes and double the quotes inside). By
  --   default the flag is set to FALSE. One example when it can be set to TRUE
  --   is in cases when all {bin} are numbers. In that case the xformed column
  --   will remain numeric as opposed to textual (default behavior). For
  --   example, for the following xfrom definition:
  --       COL     VAL BIN
  --       ----- ----- -----
  --       mycol    10 NULL
  --       mycol    15 1
  --       mycol    20 2
  --   the following {expr} and {rexp} are generated when the flag is FALSE:
  --        expr = CASE WHEN "mycol" <  10 THEN NULL
  --                    WHEN "mycol" <= 15 THEN '1'
  --                    WHEN "mycol" <= 20 THEN '2' END
  --        rexp = DECODE("mycol", '1',  '[10; 15)',
  --                               '2',  '[15; 20]'
  --                               NULL, '( ; 10) OR (20; ) OR NULL')
  --   and when the flag is set to TRUE:
  --        expr = CASE WHEN "mycol" <  10 THEN NULL
  --                    WHEN "mycol" <= 15 THEN 1
  --                    WHEN "mycol" <= 20 THEN 2 END
  --        rexp = DECODE("mycol", 1,    '[10; 15)',
  --                               2,    '[15; 20]',
  --                               NULL, '( ; 10) OR (20; ) OR NULL')
  -----------------------------------------------------------------------------
  PROCEDURE stack_bin_num(
    bin_table_name                 VARCHAR2,
    xform_list                     IN OUT NOCOPY TRANSFORM_LIST,
    literal_flag                   BOOLEAN DEFAULT FALSE,
    bin_schema_name                VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                            create_bin_cat                               --
  -----------------------------------------------------------------------------
  -- NAME
  --   create_bin_cat - CREATE CATegorical BINning definition table
  -- DESCRIPTION
  --   Creates categorical binning definition table:
  --       CREATE TABLE <bin_cat>(
  --         col   VARCHAR2(30),
  --         att   VARCHAR2(4000),
  --         val   VARCHAR2(4000),
  --         bin   VARCHAR2(4000))
  --   This table is used to guide query generation process to construct
  --   categorical binning expressions of the following form:
  --       DECODE("{col}", {val1}, {bin1},
  --                       ...
  --                       {valN}, {binN},
  --                       NULL,   NULL,
  --                               {bin(N+1)}) "{col}"
  --   This expression maps values {val1}, ..., {valN} into N bins {bin1},...,
  --   {binN}, and other values into {bin(N+1)}, while NULL values remain 
  --   unchanged. {bin(N+1)} is optional. If it is not specified it defaults
  --   to NULL. To specify {bin(N+1)} provide a row with {val} = NULL. 
  --   Example 1. <bin_cat> contains four rows with {col} = 'mycol':
  --       {col = 'mycol', val = 'Waltham',        bin = 'MA'}
  --       {col = 'mycol', val = 'Burlington',     bin = 'MA'}
  --       {col = 'mycol', val = 'Redwood Shores', bin = 'CA'}
  --       {col = 'mycol', val = NULL,             bin = 'OTHER'}
  --   the following expression is generated:
  --       DECODE("mycol", 'Waltham',        'MA',
  --                       'Burlington',     'MA',
  --                       'Redwood Shores', 'CA',
  --                       NULL,             NULL,
  --                                         'OTHER') "mycol"
  --   Example 2. <bin_cat> contains three rows with {col} = 'mycol':
  --       {col = 'mycol', val = 'Waltham',        bin = 'MA'}
  --       {col = 'mycol', val = 'Burlington',     bin = 'MA'}
  --       {col = 'mycol', val = 'Redwood Shores', bin = 'CA'}
  --   the following expression is generated:
  --       DECODE("mycol", 'Waltham',        'MA',
  --                       'Burlington',     'MA',
  --                       'Redwood Shores', 'CA') "mycol"
  -- PARAMETERS
  --   bin_table_name                 - categorical binning definition table
  --   bin_schema_name                - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers. In cases when there are multiple entries with the same 
  --   {col}, {val} combiniation with different {bin} the behavior is 
  --   undefined. Any one of the {bin} might be used. The maximum number of 
  --   arguments of a DECODE function is 255.
  -----------------------------------------------------------------------------
  PROCEDURE create_bin_cat(
    bin_table_name                 VARCHAR2,
    bin_schema_name                VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                          insert_bin_cat_freq                            --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_bin_cat_freq - INSERT into CATegorical BINning top-FREQuency
  -- DESCRIPTION
  --   For every VARCHAR2, CHAR column in the data table that is not in the
  --   exclusion list finds categorical binning definition and inserts it into
  --   the definition table. Definition for each relevant column is computed
  --   based on occurence frequency of column values that are computed from
  --   the data table reference. Each of the N (bin_num) bins {bin1}, ...,
  --   {binN} correspond to the values with top frequencies when N > 0 or
  --   bottom frequencies when N < 0, and {bin(N+1)} to all remaining
  --   values, where {binI} = I. Ordering ties among identical frequencies are
  --   broken by ordering on column values (ASC for N > 0 or DESC for N < 0).
  --   When the the number of distinct values C < N only C+1 bins will be 
  --   created. Parameter default_num (D) is used for prunning based on the
  --   number of values that fall in the default bin. When D > 0 only columns
  --   that have at least D defaults are kept while others are ignored. When
  --   D < 0 only columns that have at most D values are kept. No prunning is
  --   done when D is NULL or when D = 0. Parameter bin_support (SUP) is used
  --   for restricting bins to frequent (SUP > 0) values frq >= SUP*tot, or
  --   infrequent (SUP < 0) ones frq <= (-SUP)*tot, where frq is a given value
  --   count and tot is a sum of all counts as computed from the data. No
  --   support filtering is done when SUP is NULL or when SUP = 0.
  -- PARAMETERS
  --   bin_table_name                 - categorical binning definition table
  --   data_table_name                - data table
  --   bin_num                        - number of bins
  --   exclude_list                   - column exclusion list
  --   default_num                    - number of default values
  --   bin_support                    - bin support (fraction)
  --   bin_schema_name                - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Nothing is done when bin_num IS NULL or bin_num = 0. NULL values 
  --   are not counted. Columns with all NULLs are ignored. 
  -----------------------------------------------------------------------------
  PROCEDURE insert_bin_cat_freq(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    bin_num                        PLS_INTEGER DEFAULT 9,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    default_num                    PLS_INTEGER DEFAULT 2,
    bin_support                    NUMBER DEFAULT NULL,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              xform_bin_cat                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_bin_cat - XFORMation CATegorical BINning 
  -- DESCRIPTION
  --   Creates a view that perfoms categorical binning of the data table. Only
  --   the columns that are specified in the xform definition are binned, the
  --   remaining columns do not change.
  -- PARAMETERS
  --   bin_table_name                 - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   litiral_flag                   - literal flag
  --   bin_schema_name                - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Literal flag indicates whether the values in {bin} are valid SQL 
  --   literals. When the the flag is set to TRUE the value of {bin} is used 
  --   as is in query generation, otherwise it is converted into a valid text
  --   literal (surround by quotes and double the quotes inside). By default 
  --   the flag is set to FALSE. One example when it can be set to TRUE is in
  --   cases when all {bin} are numbers. In that case the xformed column will
  --   be numeric as opposed to textual (default behavior). For example,
  --   for the following xfrom definition:
  --       COL   VAL            BIN
  --       ----- -------------- ----
  --       mycol Waltham        1
  --       mycol Burlington     1
  --       mycol Redwood Shores 2
  --   the following expression is generated when the flag is set to FALSE:
  --       DECODE("mycol", 'Waltham',       '1',
  --                       'Burlington',    '1',
  --                       'Redwood Shores','2') "mycol"
  --   and when the flag is set to TRUE:
  --       DECODE("mycol", 'Waltham',        1,
  --                       'Burlington',     1,
  --                       'Redwood Shores', 2) "mycol"
  -----------------------------------------------------------------------------
  PROCEDURE xform_bin_cat(
    bin_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    literal_flag                   BOOLEAN DEFAULT FALSE,
    bin_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              stack_bin_cat                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   stack_bin_cat - STACK CATegorical BINning 
  -- DESCRIPTION
  --   For every column in the stack definition that has a matching entry in
  --   the transformation definition, stacks categorical binning expression on
  --   top of the existing expression and updates the stack definition.
  --   Columns in the transformation definition that have no matching entries
  --   in the stack definition are added to the stack definition (using "{col}"
  --   in place of the original expression or "VALUE" for nested attributes).
  --   Reverse expressions in the stack definition are updated accordingly,
  --   that is if an expression is updated, added or remains unchanged then a
  --   corresponding reverse expression is also updated, added or remains
  --   unchanged. When reverse expression is NULL it is treated as identity
  --   function ("{attr}" or "VALUE" for nested attributes).
  --   Given an entry ({attr}, {expr}, {rexp}) in the stack definition and a
  --   matching entry in the transformation definition, after stacking {expr}
  --   has the following form:
  --       DECODE({expr}, '{val1}', '{bin1}',
  --                      ...
  --                      '{valN}', '{binN}',
  --                      NULL,     NULL,
  --                                '{bin(N+1)}')
  --   and {rexp} has the following form:
  --       DECODE("{attr}", '{bin1}',     '{rev1}',
  --                        ...
  --                        '{binN}',     '{revN}',
  --                        NULL,         'NULL',
  --                        '{bin(N+1)}', 'DEFAULT')
  --   where {revI} is the result of applying reverese expression to {valI}.
  --   If {binI} and {binJ} are equal then the corresponding entries of the
  --   DECODE function above are merged into:
  --       '{binI}', '{revI}, {revJ}'
  --   If more than one entry maps to the default bin {bin(N+1)} they are all
  --   merged to
  --       '{bin(N+1)}', 'DEFAULT'
  --   Note that reverse expression implicitly maps invalid bins to NULL.
  --   Example 1. Given transformation definition:
  --       {col = COL1, val = waltham,        bin = MA}
  --       {col = COL1, val = burlington,     bin = MA}
  --       {col = COL1, val = redwood shores, bin = CA}
  --       {col = COL2, val = MA,             bin = East}
  --       {col = COL2, val = CA,             bin = West}
  --       {col = COL2, val = NULL,           bin = USA}
  --   and stack definition:
  --       {attr = COL1, expr = lower(COL1), rexp = initcap(COL1)} 
  --       {attr = COL3, expr = upper(COL3), rexp = initcap(COL3)} 
  --   the following updated stack definition is generated:
  --       {attr = COL1,
  --        expr = DECODE(lower(COL1), 'waltham',        'MA',
  --                                   'burlington',     'MA',
  --                                   'redwood shores', 'CA'),
  --        rexp = DECODE("COL1", 'MA', '''Waltham'', ''Burlington''',
  --                              'CA', '''Redwood Shores''',
  --                              NULL, 'DEFAULT')}
  --       {attr = COL3,
  --        expr = upper(COL3),
  --        rexp = initcap(COL3)}
  --       {attr = COL2,
  --        expr = DECODE("COL2", 'MA', 'East',
  --                              'NY', 'East',
  --                              'CA', 'West',
  --                              NULL, NULL,
  --                                    'USA')
  --        rexp = DECODE("COL2", 'East', '''MA''',
  --                              'West', '''CA''',
  --                              NULL,   'NULL',
  --                              'USA',  'DEFAULT')}
  -- PARAMETERS
  --   bin_table_name                 - xform definition table
  --   xform_list                     - stack definition
  --   literal_flag                   - literal flag
  --   bin_schema_name                - xform definition table schema name
  -- RETURNS
  --   xform_list                     - updated stack definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Literal flag indicates whether the values in {bin} are valid SQL 
  --   literals. When the the flag is set to TRUE the value of {bin} is used 
  --   "as is" in the expression generation, otherwise it is converted into a
  --   valid text literal (surround by quotes and double the quotes inside). By
  --   default the flag is set to FALSE. One example when it can be set to TRUE
  --   is in cases when all {bin} are numbers. In that case the xformed column
  --   will remain numeric as opposed to textual (default behavior). For
  --   example, for the following xfrom definition:
  --       COL   VAL            BIN
  --       ----- -------------- ----
  --       mycol Waltham        1
  --       mycol Burlington     1
  --       mycol Redwood Shores 2
  --   the following {expr} and {rexp} are generated when the flag is FALSE:
  --        expr = DECODE("mycol", 'Waltham',        '1',
  --                               'Burlington',     '1',
  --                               'Redwood Shores', '2')
  --        rexp = DECODE("COL1", '1',  '''Waltham'', ''Burlington''',
  --                              '2',  '''Redwood Shores''',
  --                              NULL, 'DEFAULT')
  --   and when the flag is set to TRUE:
  --        expr = DECODE("mycol", 'Waltham',        1,
  --                               'Burlington',     1,
  --                               'Redwood Shores', 2)
  --        rexp = DECODE("COL1", 1,    '''Waltham'', ''Burlington''',
  --                              2,    '''Redwood Shores''',
  --                              NULL, 'DEFAULT')
  -----------------------------------------------------------------------------
  PROCEDURE stack_bin_cat(
    bin_table_name                 VARCHAR2,
    xform_list                     IN OUT NOCOPY TRANSFORM_LIST,
    literal_flag                   BOOLEAN DEFAULT FALSE,
    bin_schema_name                VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                            insert_bin_super                             --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_bin_super - INSERT into BINning SUPERvised
  -- DESCRIPTION
  --   For every NUMBER, VARCHAR2, or CHAR, as well as DM_NESTED_NUMERICAL, or
  --   DM_NESTED_CATEGORICAL column in the data table that is not in the
  --   exclusion list finds numerical and categorical binning definition
  --   and inserts them into the corresponding definition tables. Definition
  --   for each relevant column is computed based on the splits found by the
  --   Decision Tree model build on a single predictor. Columns that have no
  --   splits are inserted into the column removal definition table.
  -- PARAMETERS
  --   num_table_name                 - numerical binning definition table
  --   cat_table_name                 - categorical binning definition table
  --   data_table_name                - data table
  --   target_column_name             - target column
  --   max_bin_num                    - maximum number of bins
  --   exclude_list                   - column exclusion list
  --   num_schema_name                - numerical definition table schema 
  --   cat_schema_name                - categorical definition table schema 
  --   data_schema_name               - data table schema name
  --   rem_table_name                 - column removal definition table
  --   rem_schema_name                - removal definition table schema
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Column removal definition table is optional.
  -----------------------------------------------------------------------------
  PROCEDURE insert_bin_super(
    num_table_name                 VARCHAR2,
    cat_table_name                 VARCHAR2,
    data_table_name                VARCHAR2,
    target_column_name             VARCHAR2,
    max_bin_num                    PLS_INTEGER DEFAULT 1000,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    num_schema_name                VARCHAR2 DEFAULT NULL,
    cat_schema_name                VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    rem_table_name                 VARCHAR2 DEFAULT NULL,
    rem_schema_name                VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                             xform_expr_num                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_expr_num - XFORMation EXPRession NUMber 
  -- DESCRIPTION
  --   Creates a view that applies a given expression for every NUMBER column
  --   in the data table that is not in the exclusion list and in the
  --   inclusion list. The remaining columns do not change. Expressions are 
  --   constructed from the expression pattern by replacing every occurance of
  --   the column pattern with an actual column name.
  --   Example 1. For a table TAB with two NUMBER columns CN1, CN3 and one
  --   CHAR columns CC2 and expression pattern TO_CHAR(:col) the following
  --   query is generated:
  --       SELECT TO_CHAR("CN1") "CN1", "CC2", TO_CHAR("CN3") "CN3"
  --         FROM TAB
  --   Example 2. This procedure can be used for clipping (winsorizing) 
  --   normalized data to a [0..1] range, that is values x > 1 become 1 and
  --   values x < 0 become 0. For the table in example 1 and pattern
  --       CASE WHEN :col < 0 THEN 0 WHEN :col > 1 THEN 1 ELSE :col END
  --   the following query is generated:
  --       SELECT CASE WHEN "CN1" < 0 THEN 0 WHEN "CN1" > 1 THEN 1 
  --                   ELSE "CN1" END "CN1", 
  --              "CC2",
  --              CASE WHEN "CN3" < 0 THEN 0 WHEN "CN3" > 1 THEN 1 
  --                   ELSE "CN3" END "CN3"
  --         FROM TAB
  -- PARAMETERS
  --   expr_pattern                   - expression pattern
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   exclude_list                   - column exclusion list
  --   include_list                   - column inclusion list
  --   col_pattern                    - column pattern
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   The default value of column pattern is ':col'. Column pattern is case
  --   sensetive. Expressions are constructed using SQL REPLACE function:
  --       REPALCE(expr_pattern, col_pattern, '"<column>"')||' "<column>"'
  --   NULL exclusion list is treated as an empty set (exclude none) and NULL
  --   inclusion list is treated as a full set (include all).
  -----------------------------------------------------------------------------
  PROCEDURE xform_expr_num(
    expr_pattern                   VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    include_list                   COLUMN_LIST DEFAULT NULL,
    col_pattern                    VARCHAR2 DEFAULT ':col',
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                             xform_expr_str                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_expr_str - XFORMation EXPRession STRing
  -- DESCRIPTION
  --   Similar to xform_expr_num, except that it applies to CHAR and VARCHAR2
  --   columns instead of NUMBER.
  -- PARAMETERS
  --   expr_pattern                   - expression pattern
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   exclude_list                   - column exclusion list
  --   include_list                   - column inclusion list
  --   col_pattern                    - column pattern
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE xform_expr_str(
    expr_pattern                   VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    include_list                   COLUMN_LIST DEFAULT NULL,
    col_pattern                    VARCHAR2 DEFAULT ':col',
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              create_clip                                --
  -----------------------------------------------------------------------------
  -- NAME
  --   create_clip - CREATE CLIPping definition table
  -- DESCRIPTION
  --   Creates clippping definition table:
  --       CREATE TABLE <clip>(
  --         col  VARCHAR2(30),
  --         att  VARCHAR2(4000),
  --         lcut NUMBER,
  --         lval NUMBER,
  --         rcut NUMBER,
  --         rval NUMBER)
  --   This table is used to guide query generation process to construct
  --   clipping expressions of the following form:
  --       CASE WHEN "{col}" < {lcut} THEN {lval}
  --            WHEN "{col}" > {rcut} THEN {rval}
  --                                  ELSE "{col}"
  --       END "{col}"
  --   Example 1. (winsorizing) When col = 'my_col', lcut = -1.5, lval = -1.5,
  --   and rcut = 4.5 and rval = 4.5 the following expression is generated:
  --       CASE WHEN "my_col" < -1.5 THEN -1.5
  --            WHEN "my_col" >  4.5 THEN  4.5
  --                                 ELSE "my_col"
  --       END "my_col"
  --   Example 2. (trimming) When col = 'my_col', lcut = -1.5, lval = NULL,
  --   and rcut = 4.5 and rval = NULL the following expression is generated:
  --       CASE WHEN "my_col" < -1.5 THEN NULL
  --            WHEN "my_col" >  4.5 THEN NULL
  --                                 ELSE "my_col"
  --       END "my_col"
  -- PARAMETERS
  --   clip_table_name                - clipping definition table
  --   clip_schema_name               - clipping definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers.  When there are multiple entries in the xform defintion 
  --   table for the same {col} the behavior is undefined.  Any one of the 
  --   definitions may be used in query generation. NULL values remain 
  --   unchanged.
  -----------------------------------------------------------------------------
  PROCEDURE create_clip(
    clip_table_name                VARCHAR2,
    clip_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                        insert_clip_winsor_tail                          --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_clip_winsor_tail - INSERT into CLIPping WINSORizing TAIL
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds clipping definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the
  --   non-NULL values sorted in ascending order such that val(1)<val(2)<...<
  --   val(N), where N is a total number of non-NULL values in a column:
  --       lcut = val(1+floor(N*q))
  --       lval = lcut
  --       rcut = val(N-floor(N*q))
  --       rval = rcut
  --   where q = ABS(NVL(tail_frac,0)). Nothing is done when q >= 0.5.
  -- PARAMETERS
  --   clip_table_name                - clipping definition table
  --   data_table_name                - data table
  --   tail_frac                      - tail fraction
  --   exclude_list                   - column exclusion list
  --   clip_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs are ignored.
  -----------------------------------------------------------------------------
  PROCEDURE insert_clip_winsor_tail(
    clip_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    tail_frac                      NUMBER DEFAULT 0.025,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    clip_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                        insert_clip_trim_tail                            --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_clip_trim_tail - INSERT into CLIPping TRIMming TAIL
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds clipping definition and inserts it into the definition
  --   table. Definition for each relevant column is computed based on the
  --   non-NULL values sorted in ascending order such that val(1)<val(2)<...<
  --   val(N), where N is a total number of non-NULL values in a column:
  --       lcut = val(1+floor(N*q))
  --       lval = NULL
  --       rcut = val(N-floor(N*q))
  --       rval = NULL
  --   where q = ABS(NVL(tail_frac,0)). Nothing is done when q >= 0.5.
  -- PARAMETERS
  --   clip_table_name                - clipping definition table
  --   data_table_name                - data table
  --   tail_frac                      - tail fraction
  --   exclude_list                   - column exclusion list
  --   clip_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs are ignored.
  -----------------------------------------------------------------------------
  PROCEDURE insert_clip_trim_tail(
    clip_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    tail_frac                      NUMBER DEFAULT 0.025,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    clip_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                               xform_clip                                --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_clip - XFORMation CLIPping
  -- DESCRIPTION
  --   Creates a view that perfoms clipping of the data table. Only the
  --   columns that are specified in the xform definition are clipped, the
  --   remaining columns do not change.
  -- PARAMETERS
  --   clip_table_name                - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   clip_schema_name               - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE xform_clip(
    clip_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    clip_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                                stack_clip                               --
  -----------------------------------------------------------------------------
  -- NAME
  --   stack_clip - STACK CLIPping
  -- DESCRIPTION
  --   For every column in the stack definition that has a matching entry in
  --   the transformation definition, stacks clipping expression on top of the
  --   existing expression and updates the stack definition. Columns in the
  --   stack definition that have no matching entries in the transformation
  --   definition or have NULL expression are not changed. Columns in the
  --   transformation definition that have no matching entries in the stack
  --   definition are added to the stack definition (using "{col}" in place of
  --   the original expression or "VALUE" for nested attributes).
  --   Reverse expressions in the stack definition are updated accordingly,
  --   that is if an expression is updated, added or remains unchanged then a
  --   corresponding reverse expression is also updated, added or remains
  --   unchanged. When reverse expression is NULL it is treated as identity
  --   function ("{attr}" or "VALUE" for nested attributes).
  --   Given an entry ({attr}, {expr}, {rexp}) in the stack definition and a
  --   matching entry in the transformation definition, after stacking {expr}
  --   has the following form:
  --       CASE WHEN {expr} < {lcut} THEN {lval}
  --            WHEN {expr} > {rcut} THEN {rval}
  --                                 ELSE {expr}
  --       END
  --   and {rexp} remains unchanged
  --   Example 1. Given transformation definition:
  --       {col = COL1, lcut = -1.5, lval = -1.5, rcut = 4.5, rval = 4.5}
  --       {col = COL2, lcut = 0,    lval = 0,    rcut = 1,   rval = 1}
  --   and stack definition:
  --       {attr = COL1, expr = log(10, COL1), rexp = power(10, COL1)} 
  --       {attr = COL3, expr = ln(COL3),      rexp = exp(COL3)} 
  --   the following updated stack definition is generated:
  --       {attr = COL1,
  --        expr = CASE WHEN log(10, COL1) < -1.5 THEN -1.5
  --                    WHEN log(10, COL1) > 4.5  THEN 4.5
  --                                              ELSE log(10, COL1)
  --               END,
  --        rexp = power(10, COL1)}
  --       {attr = COL3,
  --        expr = ln(COL3),
  --        rexp = exp(COL3)}
  --       {attr = COL2,
  --        expr = CASE WHEN COL2 < 0 THEN 0
  --                    WHEN COL2 > 1 THEN 1
  --                                  ELSE COL2
  --               END,
  --        rexp = NULL}
  -- PARAMETERS
  --   clip_table_name                - xform definition table
  --   xform_list                     - stack definition
  --   clip_schema_name               - xform definition table schema name
  -- RETURNS
  --   xform_list                     - updated stack definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE stack_clip(
    clip_table_name                VARCHAR2,
    xform_list                     IN OUT NOCOPY TRANSFORM_LIST,
    clip_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                            create_miss_num                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   create_miss_num - CREATE NUMerical MISSing value treatment definition
  --                     table
  -- DESCRIPTION
  --   Creates numerical missing value treatment definition table:
  --       CREATE TABLE <miss_num>(
  --         col VARCHAR2(30),
  --         att VARCHAR2(4000),
  --         val NUMBER)
  --   This table is used to guide query generation process to construct
  --   missing value treatment expressions of the following form:
  --       NVL("{col}", {val}) "{col}"
  --   For example when col = 'my_col', val = 20 the 
  --   following expression is generated:
  --       NVL("my_col", 20) "my_col"
  -- PARAMETERS
  --   miss_table_name                - definition table
  --   miss_schema_name               - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers.  When there are multiple entries in the xform defintion 
  --   table for the same {col} the behavior is undefined.  Any one of the 
  --   definitions may be used in query generation.
  -----------------------------------------------------------------------------
  PROCEDURE create_miss_num(
    miss_table_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                           insert_miss_num_mean                          --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_miss_num_mean - INSERT into NUMerical MISSining value treatment
  --                          MEAN
  -- DESCRIPTION
  --   For every NUMBER column in the data table that is not in the exclusion
  --   list finds missing value treatment definition and inserts it into the
  --   definition table. Definition for each relevant column is computed based
  --   on the mean (average) value that is computed from the data table:
  --       val = mean
  --   The value of mean is rounded to round_num significant digits prior to
  --   storing it in the definition table.
  -- PARAMETERS
  --   miss_table_name                - definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   round_num                      - number of significant digits
  --   miss_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs are ignored.
  -----------------------------------------------------------------------------
  PROCEDURE insert_miss_num_mean(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    round_num                      PLS_INTEGER DEFAULT 6,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              xform_miss_num                             --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_miss_num - XFORMation NUMerical MISSing value treatment
  -- DESCRIPTION
  --   Creates a view that perfoms numerical missing value treatment of the
  --   data table. Only the columns that are specified in the xform definition
  --   are treated, the remaining columns do not change.
  -- PARAMETERS
  --   miss_table_name                - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   miss_schema_name               - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE xform_miss_num(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              stack_miss_num                             --
  -----------------------------------------------------------------------------
  -- NAME
  --   stack_miss_num - STACK NUMerical MISSing value treatment
  -- DESCRIPTION
  --   For every column in the stack definition that has a matching entry in
  --   the transformation definition, stacks numerical missing value treatment
  --   expression on top of the existing expression and updates the stack
  --   definition. Columns in the stack definition that have no matching
  --   entries in the transformation definition or have NULL expression are
  --   not changed. Columns in the transformation definition that have no
  --   matching entries in the stack definition are added to the stack
  --   definition (using "{col}" in place of the original expression or "VALUE"
  --   for nested attributes). Reverse expressions in the stack definition are
  --   updated accordingly, that is if an expression is updated, added or
  --   remains unchanged then a corresponding reverse expression is also
  --   updated, added or remains unchanged. When reverse expression is NULL it
  --   is treated as identity function ("{attr}" or "VALUE" for nested
  --   attributes). Given an entry ({attr}, {expr}, {rexp}) in the stack
  --   definition and a matching entry in the transformation definition, after
  --   stacking {expr} has the following form:
  --       NVL({expr}, {val})
  --   and {rexp} remains unchanged
  --   Example 1. Given transformation definition:
  --       {col = COL1, val = 4.5}
  --       {col = COL2, val = 0}
  --   and stack definition:
  --       {attr = COL1, expr = log(10, COL1), rexp = power(10, COL1)} 
  --       {attr = COL3, expr = ln(COL3),      rexp = exp(COL3)} 
  --   the following updated stack definition is generated:
  --       {attr = COL1,
  --        expr = NVL(log(10, COL1), 4.5),
  --        rexp = power(10, COL1)}
  --       {attr = COL3,
  --        expr = ln(COL3),
  --        rexp = exp(COL3)}
  --       {attr = COL2,
  --        expr = NVL(COL2, 0),
  --        rexp = NULL}
  -- PARAMETERS
  --   miss_table_name                - xform definition table
  --   xform_list                     - stack definition
  --   miss_schema_name               - xform definition table schema name
  -- RETURNS
  --   xform_list                     - updated stack definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE stack_miss_num(
    miss_table_name                VARCHAR2,
    xform_list                     IN OUT NOCOPY TRANSFORM_LIST,
    miss_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                            create_miss_cat                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   create_miss_cat - CREATE CATegorical MISSing value treatment definition
  --                     table
  -- DESCRIPTION
  --   Creates categorical missing value treatment definition table:
  --       CREATE TABLE <miss_cat>(
  --         col VARCHAR2(30),
  --         att VARCHAR2(4000),
  --         val VARCHAR2(4000))
  --   This table is used to guide query generation process to construct
  --   missing value treatment expressions of the following form:
  --       NVL("{col}", {val}) "{col}"
  --   For example when col = 'zip_code', val = 'MA' the 
  --   following expression is generated:
  --       NVL("zip_code", 'MA') "zip_code"
  -- PARAMETERS
  --   miss_table_name                - definition table
  --   miss_schema_name               - definition table schema name 
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Note, that {col} is case sensitive since it generates quoted 
  --   identifiers.  When there are multiple entries in the xform defintion 
  --   table for the same {col} the behavior is undefined.  Any one of the 
  --   definitions may be used in query generation.
  -----------------------------------------------------------------------------
  PROCEDURE create_miss_cat(
    miss_table_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                           insert_miss_cat_mode                          --
  -----------------------------------------------------------------------------
  -- NAME
  --   insert_miss_cat_mode - INSERT into CATegorical MISSining value
  --                          treatment MODE
  -- DESCRIPTION
  --   For every VARCHAR2, CHAR column in the data table that is not in the
  --   exclusion list finds missing value treatment definition and inserts it
  --   into the definition table. Definition for each relevant column is
  --   computed based on the mode value that is computed from the data table:
  --       val = mode
  -- PARAMETERS
  --   miss_table_name                - definition table
  --   data_table_name                - data table
  --   exclude_list                   - column exclusion list
  --   miss_schema_name               - definition table schema name
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   Columns with all NULLs are ignored.
  -----------------------------------------------------------------------------
  PROCEDURE insert_miss_cat_mode(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    exclude_list                   COLUMN_LIST DEFAULT NULL,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              xform_miss_cat                             --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_miss_cat - XFORMation CATegorical MISSing value treatment
  -- DESCRIPTION
  --   Creates a view that perfoms categorical missing value treatment of the
  --   data table. Only the columns that are specified in the xform definition
  --   are treated, the remaining columns do not change.
  -- PARAMETERS
  --   miss_table_name                - xform definition table
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   miss_schema_name               - xform definition table schema name
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   The data type of the xformed columns is preseved by putting a CAST
  --   expression around NVL. For example, when col = 'zip_code', val = 'MA'
  --   the data type is CHAR(2) the following expression is generated:
  --       CAST(NVL("zip_code", 'MA') AS CHAR(2)) "zip_code"
  -----------------------------------------------------------------------------
  PROCEDURE xform_miss_cat(
    miss_table_name                VARCHAR2,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    miss_schema_name               VARCHAR2 DEFAULT NULL,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              stack_miss_cat                             --
  -----------------------------------------------------------------------------
  -- NAME
  --   stack_miss_cat - STACK CATegorical MISSing value treatment
  -- DESCRIPTION
  --   For every column in the stack definition that has a matching entry in
  --   the transformation definition, stacks categorical missing value
  --   treatment expression on top of the existing expression and updates the
  --   stack definition. Columns in the stack definition that have no matching
  --   entries in the transformation definition or have NULL expression are
  --   not changed. Columns in the transformation definition that have no
  --   matching entries in the stack definition are added to the stack
  --   definition (using "{col}" in place of the original expression or "VALUE"
  --   for nested attributes). Reverse expressions in the stack definition are
  --   updated accordingly, that is if an expression is updated, added or
  --   remains unchanged then a corresponding reverse expression is also
  --   updated, added or remains unchanged. When reverse expression is NULL it
  --   is treated as identity function ("{attr}" or "VALUE" for nested
  --   attributes). Given an entry ({attr}, {expr}, {rexp}) in the stack
  --   definition and a matching entry in the transformation definition, after
  --   stacking {expr} has the following form:
  --       NVL({expr}, {val})
  --   and {rexp} remains unchanged
  --   Example 1. Given transformation definition:
  --       {col = COL1, val = 'ma'}
  --       {col = COL2, val = 'CA'}
  --   and stack definition:
  --       {attr = COL1, expr = lower(COL1), rexp = initcap(COL1)} 
  --       {attr = COL3, expr = upper(COL3), rexp = initcap(COL3)} 
  --   the following updated stack definition is generated:
  --       {attr = COL1,
  --        expr = NVL(lower(COL1), 'ma'),
  --        rexp = initcap(COL1)}
  --       {attr = COL3,
  --        expr = upper(COL3),
  --        rexp = initcap(COL3)}
  --       {attr = COL2,
  --        expr = NVL(COL2, 'CA'),
  --        rexp = NULL}
  -- PARAMETERS
  --   miss_table_name                - xform definition table
  --   xform_list                     - stack definition
  --   miss_schema_name               - xform definition table schema name
  -- RETURNS
  --   xform_list                     - updated stack definition
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE stack_miss_cat(
    miss_table_name                VARCHAR2,
    xform_list                     IN OUT NOCOPY TRANSFORM_LIST,
    miss_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                              xform_stack                                --
  -----------------------------------------------------------------------------
  -- NAME
  --   xform_stack - XFORMation STACK
  -- DESCRIPTION
  --   Creates a view that perfoms transformation of the data table specified
  --   by the stack definition. Only the columns that are specified in the
  --   stack definition are transformed, the remaining columns do not change.
  --   All columns in the stack definition are applied. Columns with NULL value
  --   in the expression field are excluded. Columns in the stack definition
  --   that do not have a matching column in the data are added to the view.
  -- PARAMETERS
  --   xform_list                     - stack definition
  --   data_table_name                - data table
  --   xform_view_name                - xform view
  --   data_schema_name               - data table schema name
  --   xform_schema_name              - xform view schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE xform_stack(
    xform_list                     TRANSFORM_LIST,
    data_table_name                VARCHAR2,
    xform_view_name                VARCHAR2,
    data_schema_name               VARCHAR2 DEFAULT NULL,
    xform_schema_name              VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                             describe_stack                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   describe_stack - DESCRIBE STACK
  -- DESCRIPTION
  --   Desribes transformation of the data table specified by the stack
  --   definition. Only the columns that are specified in the stack definition
  --   are transformed, the remaining columns do not change. All columns in the
  --   stack definition are applied. Columns with NULL value in the expression
  --   field are excluded. Columns in the stack definition that do not have a
  --   matching column in the data are added to the describe list.
  -- PARAMETERS
  --   xform_list                     - stack definition
  --   data_table_name                - data table
  --   describe_list                  - describe list/describe list3
  --   data_schema_name               - data table schema name
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   When the DESCRIBE_LIST type is specified for the describe_list parameter
  --   a DM_NESTED_NUMERICALS type is indicated by a value of nest_num_col_type
  --   in the col_type field and nest_cat_col_type for DM_NESTED_CATEGORICALS.
  --
  --   When the DESCRIBE_LIST3 type is specified for the describe_list
  --   parameter, nested types are indicated with the ADT type in the col_type
  --   field with the specific nested type indicated in the col_name_type
  --   field as a string.  This behavior is consistent with the call to
  --   describe_columns3 in the dbms_sql package (dbmssql.sql).
  -----------------------------------------------------------------------------
  PROCEDURE describe_stack(
    xform_list                     TRANSFORM_LIST,
    data_table_name                VARCHAR2,
    describe_list                  OUT DESCRIBE_LIST,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  PROCEDURE describe_stack(
    xform_list                     TRANSFORM_LIST,
    data_table_name                VARCHAR2,
    describe_list                  OUT DESCRIBE_LIST3,
    data_schema_name               VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                             set_expression                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   set_expression - SET xform EXPRESSION
  -- DESCRIPTION
  --   Appends a VARCHAR2 chunk to the expression. Appeding NULL clears the
  --   expression.
  -- PARAMETERS
  --   expression                     - expression
  --   chunk                          - VARCHAR2 chunk
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE set_expression(
    expression                     IN OUT NOCOPY EXPRESSION_REC,
    chunk                          VARCHAR2 DEFAULT NULL);

  -----------------------------------------------------------------------------
  --                             get_expression                              --
  -----------------------------------------------------------------------------
  -- NAME
  --   get_expression - GET xform EXPRESSION
  -- DESCRIPTION
  --   Gets a VARCHAR2 chunk from the expression. Chunks numbering starts from
  --   one. For chunks outside of the range the return value is NULL. When
  --   chunk number is NULL the whole expression is returned as a string. If
  --   expression is too big VALUE_ERROR is raised.
  -- PARAMETERS
  --   expression                     - expression
  --   chunk_num                      - chunk number
  -- RETURNS
  --   VARCHAR2 chunk.
  -- EXCEPTIONS
  --   VALUE_ERROR
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  FUNCTION get_expression(
    expression                     EXPRESSION_REC,
    chunk_num                      PLS_INTEGER DEFAULT NULL)
  RETURN VARCHAR2;

  -----------------------------------------------------------------------------
  --                             set_transform                               --
  -----------------------------------------------------------------------------
  -- NAME
  --   set_transform - SET TRANSFORM list
  -- DESCRIPTION
  --   Appends an element to the transformation list.
  -- PARAMETERS
  --   expression                     - expression
  --   chunk                          - VARCHAR2 chunk
  -- RETURNS
  --   None
  -- EXCEPTIONS
  --   None
  -- NOTES
  --   None
  -----------------------------------------------------------------------------
  PROCEDURE set_transform(
    xform_list                     IN OUT NOCOPY TRANSFORM_LIST,
    attribute_name                 VARCHAR2,
    attribute_subname              VARCHAR2,
    expression                     VARCHAR2,
    reverse_expression             VARCHAR2,
    attribute_spec                 VARCHAR2 DEFAULT NULL);
END dbms_data_mining_transform;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_data_mining_transform
   FOR sys.dbms_data_mining_transform
/
GRANT EXECUTE ON dbms_data_mining_transform TO PUBLIC
/
