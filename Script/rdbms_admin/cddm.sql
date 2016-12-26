Rem
Rem $Header: rdbms/admin/cddm.sql /st_rdbms_11.2.0/1 2012/01/12 15:42:16 amozes Exp $
Rem
Rem cddm.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cddm.sql - Catalog DDM.bsq views
Rem
Rem    DESCRIPTION
Rem      Data Mining Model objects.
Rem
Rem    NOTES
Rem      This script contains catalog views for objects in ddm.bsq.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      01/05/12 - Backport amozes_bug-12926436 from main
Rem    mmcracke    07/18/09 - Add ADP binning table type
Rem    bmilenov    06/15/09 - Bug-8661316: Add H inversion table to NMF
Rem    mmcracke    12/24/08 - Add ADP table to DBA_MINING_MODEL_TABLES
Rem    dmukhin     03/05/08 - bug 6620177: ADP coefficients reversal
Rem    mmcracke    07/06/06 - Add new table type ocSplitPredicate 
Rem    pstengar    05/02/06 - update system privilege numbers
Rem    bmilenov    05/26/06 - Add GLM 
Rem    dmukhin     05/17/06 - prj 18876: scoring cost matrix 
Rem    cdilling    05/04/06 - Created
Rem

remark
remark  FAMILY "DATA MINING MODELS"
remark  List of models
remark
create or replace view USER_MINING_MODELS
    (MODEL_NAME, MINING_FUNCTION, ALGORITHM,
     CREATION_DATE, BUILD_DURATION, MODEL_SIZE, COMMENTS)
as
select o.name,
       cast(decode(func, /* Mining Function */
              1, 'CLASSIFICATION',
              2, 'REGRESSION',
              3, 'CLUSTERING',
              4, 'FEATURE_EXTRACTION',
              5, 'ASSOCIATION_RULES',
              6, 'ATTRIBUTE_IMPORTANCE',
                 'UNDEFINED') as varchar2(30)),
       cast(decode(alg, /* Mining Algorithm */
              1, 'NAIVE_BAYES',
              2, 'ADAPTIVE_BAYES_NETWORK',
              3, 'DECISION_TREE',
              4, 'SUPPORT_VECTOR_MACHINES',
              5, 'KMEANS',
              6, 'O_CLUSTER',
              7, 'NONNEGATIVE_MATRIX_FACTOR',
              8, 'GENERALIZED_LINEAR_MODEL',
              9, 'APRIORI_ASSOCIATION_RULES',
             10, 'MINIMUM_DESCRIPTION_LENGTH',
                 'UNDEFINED') as varchar2(30)),
       o.ctime, bdur, msize, c.comment$
from sys.model$ m, sys.obj$ o, sys.com$ c
where o.obj#=m.obj#
  and o.obj#=c.obj#(+)
  and o.type#=82
  and o.owner#=userenv('SCHEMAID')
/
comment on table USER_MINING_MODELS is
'Description of the user''s own models'
/
comment on column USER_MINING_MODELS.MODEL_NAME is
'Name of the model'
/
comment on column USER_MINING_MODELS.MINING_FUNCTION is
'Mining function of the model'
/
comment on column USER_MINING_MODELS.ALGORITHM is
'Algorithm of the model'
/
comment on column USER_MINING_MODELS.CREATION_DATE is
'Creation date of the model'
/
comment on column USER_MINING_MODELS.BUILD_DURATION is
'Model build time (in seconds)'
/
comment on column USER_MINING_MODELS.MODEL_SIZE is
'Model size (in Mb)'
/
comment on column USER_MINING_MODELS.COMMENTS is
'Model comments'
/
create or replace public synonym USER_MINING_MODELS for USER_MINING_MODELS
/
grant select on USER_MINING_MODELS to public;
/
create or replace view ALL_MINING_MODELS
    (OWNER, MODEL_NAME, MINING_FUNCTION, ALGORITHM,
     CREATION_DATE, BUILD_DURATION, MODEL_SIZE, COMMENTS)
as
select u.name, o.name,
       cast(decode(func, /* Mining Function */
              1, 'CLASSIFICATION',
              2, 'REGRESSION',
              3, 'CLUSTERING',
              4, 'FEATURE_EXTRACTION',
              5, 'ASSOCIATION_RULES',
              6, 'ATTRIBUTE_IMPORTANCE',
                 'UNDEFINED') as varchar2(30)),
       cast(decode(alg, /* Mining Algorithm */
              1, 'NAIVE_BAYES',
              2, 'ADAPTIVE_BAYES_NETWORK',
              3, 'DECISION_TREE',
              4, 'SUPPORT_VECTOR_MACHINES',
              5, 'KMEANS',
              6, 'O_CLUSTER',
              7, 'NONNEGATIVE_MATRIX_FACTOR',
              8, 'GENERALIZED_LINEAR_MODEL',
              9, 'APRIORI_ASSOCIATION_RULES',
             10, 'MINIMUM_DESCRIPTION_LENGTH',
                 'UNDEFINED') as varchar2(30)),
       o.ctime, bdur, msize, c.comment$
from sys.model$ m, sys.obj$ o, sys.user$ u, sys.com$ c
where o.obj#=m.obj#
  and o.obj#=c.obj#(+)
  and o.type#=82
  and o.owner#=u.user#
  and (o.owner#=userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-292 /* DROP ANY MINING MODEL */,
                                        -293 /* SELECT ANY MINING MODEL */,
                                        -294 /* ALTER ANY MINING MODEL */)
                  )
      )
/
comment on table ALL_MINING_MODELS is
'Description of the models accessible to the user'
/
comment on column ALL_MINING_MODELS.MODEL_NAME is
'Name of the model'
/
comment on column ALL_MINING_MODELS.MINING_FUNCTION is
'Mining function of the model'
/
comment on column ALL_MINING_MODELS.ALGORITHM is
'Algorithm of the model'
/
comment on column ALL_MINING_MODELS.CREATION_DATE is
'Creation date of the model'
/
comment on column ALL_MINING_MODELS.BUILD_DURATION is
'Model build time (in seconds)'
/
comment on column ALL_MINING_MODELS.MODEL_SIZE is
'Model size (in Mb)'
/
comment on column ALL_MINING_MODELS.COMMENTS is
'Model comments'
/
create or replace public synonym ALL_MINING_MODELS for ALL_MINING_MODELS
/
grant select on ALL_MINING_MODELS to public;
/
create or replace view DBA_MINING_MODELS
    (OWNER, MODEL_NAME, MINING_FUNCTION, ALGORITHM,
     CREATION_DATE, BUILD_DURATION, MODEL_SIZE, COMMENTS)
as
select u.name, o.name,
       cast(decode(func, /* Mining Function */
              1, 'CLASSIFICATION',
              2, 'REGRESSION',
              3, 'CLUSTERING',
              4, 'FEATURE_EXTRACTION',
              5, 'ASSOCIATION_RULES',
              6, 'ATTRIBUTE_IMPORTANCE',
                 'UNDEFINED') as varchar2(30)),
       cast(decode(alg, /* Mining Algorithm */
              1, 'NAIVE_BAYES',
              2, 'ADAPTIVE_BAYES_NETWORK',
              3, 'DECISION_TREE',
              4, 'SUPPORT_VECTOR_MACHINES',
              5, 'KMEANS',
              6, 'O_CLUSTER',
              7, 'NONNEGATIVE_MATRIX_FACTOR',
              8, 'GENERALIZED_LINEAR_MODEL',
              9, 'APRIORI_ASSOCIATION_RULES',
             10, 'MINIMUM_DESCRIPTION_LENGTH',
                 'UNDEFINED') as varchar2(30)),
       o.ctime, bdur, msize, c.comment$
from sys.model$ m, sys.obj$ o, sys.user$ u, sys.com$ c
where o.obj#=m.obj#
  and o.obj#=c.obj#(+)
  and o.type#=82
  and o.owner#=u.user#
/
comment on table DBA_MINING_MODELS is
'Description of all the models in the database'
/
comment on column DBA_MINING_MODELS.OWNER is
'Owner of the model'
/
comment on column DBA_MINING_MODELS.MODEL_NAME is
'Name of the model'
/
comment on column DBA_MINING_MODELS.MINING_FUNCTION is
'Mining function of the model'
/
comment on column DBA_MINING_MODELS.ALGORITHM is
'Algorithm of the model'
/
comment on column DBA_MINING_MODELS.CREATION_DATE is
'Creation date of the model'
/
comment on column DBA_MINING_MODELS.BUILD_DURATION is
'Model build time (in seconds)'
/
comment on column DBA_MINING_MODELS.MODEL_SIZE is
'Model size (in Mb)'
/
comment on column DBA_MINING_MODELS.COMMENTS is
'Model comments'
/
create or replace public synonym DBA_MINING_MODELS for DBA_MINING_MODELS
/
grant select on DBA_MINING_MODELS to select_catalog_role
/
remark  List of model attributes
remark
create or replace view USER_MINING_MODEL_ATTRIBUTES
    (MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_TYPE, DATA_TYPE,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, USAGE_TYPE, TARGET)
as
select o.name, a.name,
       decode(atyp, /* attribute type */
              1, 'NUMERICAL',
              2, 'CATEGORICAL',
              3, 'ORDINAL',
                 'UNDEFINED'),
       decode(dtyp, /* data type */
              1, 'VARCHAR2',
              2, 'NUMBER',
              4, 'FLOAT',
             96, 'CHAR',
            122, 'NESTED TABLE',
                 'UNDEFINED'),
       a.length,
       a.precision#,
       a.scale,
       decode(bitand(a.properties,1),1,'ACTIVE','INACTIVE'),
       decode(bitand(a.properties,2),2,'YES','NO')
from sys.modelatt$ a, sys.obj$ o
where o.obj#=a.mod#
  and o.owner#=userenv('SCHEMAID')
  and bitand(a.properties, 4) = 0
/
comment on table USER_MINING_MODEL_ATTRIBUTES is
'Description of the user''s own model attributes'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.MODEL_NAME is
'Name of the model to which the attribute belongs'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_TYPE is
'Mining type of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.DATA_TYPE is
'Data type of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.DATA_LENGTH is
'Data length of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.DATA_PRECISION is
'Data precision of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.DATA_SCALE is
'Data scale of the attribute'
/
comment on column USER_MINING_MODEL_ATTRIBUTES.USAGE_TYPE is
'Usage type for the attribute'
/
create or replace public synonym USER_MINING_MODEL_ATTRIBUTES
  for USER_MINING_MODEL_ATTRIBUTES
/
grant select on USER_MINING_MODEL_ATTRIBUTES to public
/
create or replace view ALL_MINING_MODEL_ATTRIBUTES
    (OWNER, MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_TYPE, DATA_TYPE,
     DATA_LENGTH, DATA_PRECISION, DATA_SCALE, USAGE_TYPE, TARGET)
as
select u.name, o.name, a.name,
       decode(atyp, /* attribute type */
              1, 'NUMERICAL',
              2, 'CATEGORICAL',
              3, 'ORDINAL',
                 'UNDEFINED'),
       decode(dtyp, /* data type */
              1, 'VARCHAR2',
              2, 'NUMBER',
              4, 'FLOAT',
             96, 'CHAR',
            122, 'NESTED TABLE',
                 'UNDEFINED'),
       a.length,
       a.precision#,
       a.scale,
       decode(bitand(a.properties,1),1,'ACTIVE','INACTIVE'),
       decode(bitand(a.properties,2),2,'YES','NO')
from sys.modelatt$ a, sys.obj$ o, sys.user$ u
where o.obj#=a.mod#
  and o.owner#=u.user#
  and (o.owner#=userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-293 /* SELECT ANY MINING MODEL */)
                  )
      )
  and bitand(a.properties, 4) = 0
/
comment on table ALL_MINING_MODEL_ATTRIBUTES is
'Description of all the model attributes accessible to the user'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.MODEL_NAME is
'Name of the model to which the attribute belongs'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_TYPE is
'Mining type of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.DATA_TYPE is
'Data type of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.DATA_LENGTH is
'Data length of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.DATA_PRECISION is
'Data precision of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.DATA_SCALE is
'Data scale of the attribute'
/
comment on column ALL_MINING_MODEL_ATTRIBUTES.USAGE_TYPE is
'Usage type for the attribute'
/
create or replace public synonym ALL_MINING_MODEL_ATTRIBUTES
  for ALL_MINING_MODEL_ATTRIBUTES
/
grant select on ALL_MINING_MODEL_ATTRIBUTES to public
/
create or replace view DBA_MINING_MODEL_ATTRIBUTES
    (OWNER, MODEL_NAME, ATTRIBUTE_NAME, ATTRIBUTE_TYPE,
     DATA_TYPE, DATA_LENGTH, DATA_PRECISION, DATA_SCALE,
     USAGE_TYPE, TARGET)
as
select u.name, o.name, a.name,
       decode(atyp, /* attribute type */
              1, 'NUMERICAL',
              2, 'CATEGORICAL',
              3, 'ORDINAL',
                 'UNDEFINED'),
       decode(dtyp, /* data type */
              1, 'VARCHAR2',
              2, 'NUMBER',
              4, 'FLOAT',
             96, 'CHAR',
            122, 'NESTED TABLE',
                 'UNDEFINED'),
       a.length,
       a.precision#,
       a.scale,
       decode(bitand(a.properties,1),1,'ACTIVE','INACTIVE'),
       decode(bitand(a.properties,2),2,'YES','NO')
from sys.modelatt$ a, sys.obj$ o, sys.user$ u
where o.obj#=a.mod#
  and o.owner#=u.user#
  and bitand(a.properties, 4) = 0
/
comment on table DBA_MINING_MODEL_ATTRIBUTES is
'Description of all the model attributes in the database'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.MODEL_NAME is
'Name of the model to which the attribute belongs'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_NAME is
'Name of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.ATTRIBUTE_TYPE is
'Mining type of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.DATA_TYPE is
'Data type of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.DATA_LENGTH is
'Data length of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.DATA_PRECISION is
'Data precision of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.DATA_SCALE is
'Data scale of the attribute'
/
comment on column DBA_MINING_MODEL_ATTRIBUTES.USAGE_TYPE is
'Usage type for the attribute'
/
create or replace public synonym DBA_MINING_MODEL_ATTRIBUTES 
  for DBA_MINING_MODEL_ATTRIBUTES
/
grant select on DBA_MINING_MODEL_ATTRIBUTES to select_catalog_role
/
remark  List of model settings
remark
create or replace view USER_MINING_MODEL_SETTINGS
    (MODEL_NAME, SETTING_NAME, SETTING_VALUE, SETTING_TYPE)
as
select o.name, s.name, s.value,
       decode(bitand(s.properties,1),1,'INPUT','DEFAULT')
from sys.modelset$ s, sys.obj$ o
where s.mod#=o.obj#
  and o.owner#=userenv('SCHEMAID')
  and bitand(s.properties,2) != 2
/
comment on table USER_MINING_MODEL_SETTINGS is
'Description of the user''s own model settings'
/
comment on column USER_MINING_MODEL_SETTINGS.MODEL_NAME is
'Name of the model to which the setting belongs'
/
comment on column USER_MINING_MODEL_SETTINGS.SETTING_NAME is
'Name of the setting'
/
comment on column USER_MINING_MODEL_SETTINGS.SETTING_VALUE is
'Value of the setting'
/
comment on column USER_MINING_MODEL_SETTINGS.SETTING_TYPE is
'Type of the setting'
/
create or replace public synonym USER_MINING_MODEL_SETTINGS
  for USER_MINING_MODEL_SETTINGS
/
grant select on USER_MINING_MODEL_SETTINGS to public
/
create or replace view ALL_MINING_MODEL_SETTINGS
    (OWNER, MODEL_NAME, SETTING_NAME, SETTING_VALUE, SETTING_TYPE)
as
select u.name, o.name, s.name, s.value,
       decode(s.properties,1,'INPUT','DEFAULT')
from sys.modelset$ s, sys.obj$ o, sys.user$ u
where s.mod#=o.obj#
  and o.owner#=u.user#
  and (o.owner#=userenv('SCHEMAID')
       or o.obj# in
            (select oa.obj#
             from sys.objauth$ oa
             where oa.grantee# in ( select kzsrorol
                                         from x$kzsro
                                  )
            )
        or /* user has system privileges */
          exists (select null from v$enabledprivs
                  where priv_number in (-293 /* SELECT ANY MINING MODEL */)
                  )
      )
  and bitand(s.properties,2) != 2
/
comment on table ALL_MINING_MODEL_SETTINGS is
'Description of all the settings accessible to the user'
/
comment on column ALL_MINING_MODEL_SETTINGS.MODEL_NAME is
'Name of the model to which the setting belongs'
/
comment on column ALL_MINING_MODEL_SETTINGS.SETTING_NAME is
'Name of the setting'
/
comment on column ALL_MINING_MODEL_SETTINGS.SETTING_VALUE is
'Value of the setting'
/
comment on column ALL_MINING_MODEL_SETTINGS.SETTING_TYPE is
'Type of the setting'
/
create or replace public synonym ALL_MINING_MODEL_SETTINGS
  for ALL_MINING_MODEL_SETTINGS
/
grant select on ALL_MINING_MODEL_SETTINGS to public
/
create or replace view DBA_MINING_MODEL_SETTINGS
    (OWNER, MODEL_NAME, SETTING_NAME, SETTING_VALUE, SETTING_TYPE)
as
select u.name, o.name, s.name, s.value,
       decode(s.properties,1,'INPUT','DEFAULT')
from sys.modelset$ s, sys.obj$ o, sys.user$ u
where s.mod#=o.obj#
  and o.owner#=u.user#
  and bitand(s.properties,2) != 2
/
comment on table DBA_MINING_MODEL_SETTINGS is
'Description of all the model settings in the database'
/
comment on column DBA_MINING_MODEL_SETTINGS.MODEL_NAME is
'Name of the model to which the setting belongs'
/
comment on column DBA_MINING_MODEL_SETTINGS.SETTING_NAME is
'Name of the setting'
/
comment on column DBA_MINING_MODEL_SETTINGS.SETTING_VALUE is
'Value of the setting'
/
comment on column DBA_MINING_MODEL_SETTINGS.SETTING_TYPE is
'Type of the setting'
/
create or replace public synonym  DBA_MINING_MODEL_SETTINGS
  for DBA_MINING_MODEL_SETTINGS
/
grant select on DBA_MINING_MODEL_SETTINGS to select_catalog_role
/

remark
create or replace view DBA_MINING_MODEL_TABLES
    (OWNER, MODEL_NAME, TABLE_NAME, TABLE_TYPE)
as
select u.name,
       o1.name,
       o2.name,
       decode(typ#,
              1, 'categoricalMapTable',
              2, 'explosionMapTable',
              3, 'rulesTable',
              4, 'priorsTable',
              5, 'treesTable',
              6, 'timingTable',
              7, 'clDescriptionTable',
              8, 'clCentroidTable',
              9, 'clTaxonomyTable',
             10, 'clParameterTable',
             11, 'clHistogramTable',
             12, 'clBinBoundaryTable',
             13, 'clRuleTable',
             14, 'clPredicateTable',
             15, 'clCentModeTable',
             16, 'treeTgtMap',
             17, 'treeTgtHist',
             18, 'treeSplit',
             19, 'treeSplitCat',
             20, 'treeParams',
             21, 'svmParams',
             22, 'svmSettings',
             23, 'svmCoefficients',
             24, 'svmSqnorm',
             25, 'svmAlphas',
             26, 'supportVectors',
             27, 'nmfEncodedMatrix',
             28, 'costTable',
             29, 'itemBinTable',
             30, 'itemSetTable',
             31, 'itemSetItemTable',
             32, 'ocClusterTable',
             33, 'ocRulesTable',
             34, 'aiTable',
             35, 'xformTable',
             36, 'costScoreTable',
             37, 'glmGlobDiagTable',
             38, 'glmModelDiagTable', 
             39, 'glmFisherTable',
             40, 'glmMappingTable',
             41, 'glmFtrCmpTable',
             42, 'glmScoreInfoTable',
             43, 'glmTgtMapTable',
             44, 'ocSplitPredicateTable',
             45, 'xfNorm',
             46, 'adpDataTable',
             47, 'nmfInvertedMatrix',
             48, 'adpBinDataTable',
                 'UNDEFINED')
from sys.model$ m, sys.modeltab$ t, sys.obj$ o1, sys.obj$ o2, sys.user$ u
where m.obj#=o1.obj#
  and m.obj#=t.mod#
  and t.obj#=o2.obj#
  and o1.owner#=u.user#;
/
comment on table DBA_MINING_MODEL_TABLES is
'Description of all the mining model tables in the system'
/
comment on column DBA_MINING_MODEL_TABLES.OWNER is
'Name of the owner to which the table belongs'
/
comment on column DBA_MINING_MODEL_TABLES.MODEL_NAME is
'Name of the model to which the table belongs'
/
comment on column DBA_MINING_MODEL_TABLES.TABLE_NAME is
'Name of the model table'
/
comment on column DBA_MINING_MODEL_TABLES.TABLE_TYPE is
'Name of the mining model table type'
/
grant select on DBA_MINING_MODEL_TABLES to select_catalog_role
/
create or replace public synonym DBA_MINING_MODEL_TABLES
 for DBA_MINING_MODEL_TABLES
/
create or replace view DM_USER_MODELS
    (NAME, FUNCTION_NAME, ALGORITHM_NAME, CREATION_DATE,
     BUILD_DURATION, TARGET_ATTRIBUTE, MODEL_SIZE)
as
select m.model_name, mining_function, algorithm,
     creation_date, build_duration, attribute_name, model_size
from user_mining_models m, user_mining_model_attributes a
where m.model_name=a.model_name(+)
  and target(+)='YES'
/
create or replace public synonym DM_USER_MODELS for SYS.DM_USER_MODELS
/
grant select on DM_USER_MODELS to public
/
