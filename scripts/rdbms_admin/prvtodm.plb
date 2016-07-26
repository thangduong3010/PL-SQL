PROMPT Model Util Package, qgen
@@prvtdmmi.plb
PROMPT DBMS_DATA_MINING_TRANSFORM
@@prvtdmxf.plb
PROMPT Meta Code package (adaptor,sys,sec,exp code,superh/b)
@@prvtdmsu.plb
PROMPT Adaptive Bayesian Networks 
@@prvtdmab.plb
PROMPT Association Rules 
@@prvtdmar.plb
PROMPT  O-Cluster 
@@prvtdmoc.plb
PROMPT KM,SVM,NMF Trusted code
@@prvtdmtf.plb
PROMPT DBMS DM Internal, DBMS DM
@@prvtdm.plb
PROMPT Predictive code 
@@prvtdmpa.plb
CREATE OR REPLACE PUBLIC SYNONYM odm_ABN_model
  FOR sys.odm_ABN_model
/
CREATE OR REPLACE PUBLIC SYNONYM odm_association_rule_model
  FOR sys.odm_association_rule_model
/
CREATE OR REPLACE PUBLIC SYNONYM odm_clustering_util
  FOR sys.odm_clustering_util
/
CREATE OR REPLACE PUBLIC SYNONYM odm_model_util
  FOR sys.odm_model_util
/
CREATE OR REPLACE PUBLIC SYNONYM odm_oc_clustering_model
  FOR sys.odm_oc_clustering_model
/
CREATE OR REPLACE PUBLIC SYNONYM odm_util
  FOR sys.odm_util
/
GRANT EXECUTE ON odm_util TO PUBLIC
/
