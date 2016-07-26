Rem
Rem
Rem Copyright (c) 2004, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      catmacp.sql
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for CODE$ table.(data fault)
Rem
Rem    NOTES
Rem
Rem    MODIFIED (MM/DD/YY)
Rem       apfwkr 07/02/12 - Backport jibyun_bug-7118790 from main
Rem       sanbha 05/23/12 - Bug 13781732 - introducing
Rem                         dbms_macadm.enable_dv_patch_admin_audit()
Rem                         procedure.
Rem       jibyun 05/03/11 - Backport jibyun_bug-12356827 from main
Rem       jibyun 03/02/11 - Backport jibyun_bug-11662436 from main
Rem       dvekar 03/02/11 - Backport dvekaria_bug-9068994_1 from main
Rem       sanbha 03/01/11 - Backport sanbhara_bug-10225918 from main
Rem       jheng  01/14/09 - add scheduler authorization procedure
Rem       srtata 12/26/08 - static rule sets
Rem       rupara 12/18/08 - Bug 7657506
Rem       youyan 11/19/08 - add check_is_drop_object_maint in
Rem                         dbms_macsec_events
Rem       jibyun 05/13/08 - Bug 7550987: Add dbms_macutl.check_streams_admin 
Rem                         function
Rem       jsamue 10/27/08 - remove error messages
Rem       ssonaw 09/25/08 - Bug-6938843: Add functions for seeded rules 
Rem       jibyun 05/13/08 - Bug 7550987: Add dbms_macutl.check_streams_admin 
Rem                         function
Rem       clei   05/30/08 - Bug 6435192: Add enable_dv_check/disable_dv_check
Rem       jibyun 04/27/08 - Fix Bug 6908550
Rem       jibyun 04/07/08 - Fix Bug 5926711: add a new parameter, p_user, to
Rem                         audit procedures
Rem       rupara 03/27/08 - Add authorize_datapump_user procedure
Rem       clei   02/18/08 - Add enable_event and disable_event
Rem       jibyun 10/31/07 - To fix Bug 6441524
Rem       jibyun 07/18/07 - To fix Bug 6068504
Rem       rupara 02/23/07 - Bug fix 5900679
Rem       rupara 11/17/06 - bug 5594883
Rem       rvissa 12/01/06 -  alter system set schema
Rem       clei   12/07/06 - remove VPD dependencies
Rem       cchuiu 07/05/06 - add more functions for cmd rules enforcement 
Rem       cchui  07/04/06 - fix char string buffer too small in 
Rem                         dvsys.event.set 
Rem       fjlee  06/07/06 - add delete_row w/o p_id
Rem       jcimin 05/02/06 - cleanup embedded file boilerplate 
Rem       jcimin 05/02/06 - created admin/catmacp.sql 
Rem       sgaetj 11/08/05 - unit test fixes 
Rem       sgaetj 11/03/05 - NLS support changes
Rem       sgaetj 08/11/05 - sgaetjen_dvschema
Rem       sgaetj 08/05/05 - Merge into ADE with Protected Schema
Rem       sgaetj 07/29/05 - Created
Rem       sgaetj 07/28/05 - dos2unix
Rem    raustin   Thu Dec 16 13:28:36 EST 2004 - Generated
Rem
Rem
Rem

Rem Set the current schema to dvsys
Rem This script should do this within itself as it can be called by relod scripts also
Rem apart from catmac.sql


ALTER SESSION SET CURRENT_SCHEMA = DVSYS; 

CREATE OR REPLACE PACKAGE DVSYS.CODE$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# CODE$.ID#%TYPE
    , CODE_GROUP CODE$.CODE_GROUP%TYPE
    , CODE CODE$.CODE%TYPE
    --, VALUE CODE$.VALUE%TYPE
    --, LANGUAGE CODE_T$.LANGUAGE%TYPE
    --, DESCRIPTION CODE_T$.DESCRIPTION%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_CODE_GROUP IN VARCHAR2,
    p_CODE IN VARCHAR2,
    p_VALUE IN VARCHAR2,
    p_LANGUAGE IN VARCHAR2,
    p_DESCRIPTION IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_CODE_GROUP OUT VARCHAR2
    , x_CODE OUT VARCHAR2
    , x_VALUE OUT VARCHAR2
    , x_LANGUAGE OUT VARCHAR2
    , x_DESCRIPTION OUT VARCHAR2
    );

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_CODE_GROUP IN VARCHAR2
    , p_CODE IN VARCHAR2
    , p_VALUE IN VARCHAR2
    , p_LANGUAGE IN VARCHAR2
    , p_DESCRIPTION IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for COMMAND_RULE$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.COMMAND_RULE$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# COMMAND_RULE$.ID#%TYPE
    , CODE_ID# COMMAND_RULE$.CODE_ID#%TYPE
    , RULE_SET_ID# COMMAND_RULE$.RULE_SET_ID#%TYPE
    , OBJECT_OWNER COMMAND_RULE$.OBJECT_OWNER%TYPE
    , OBJECT_NAME COMMAND_RULE$.OBJECT_NAME%TYPE
    , ENABLED COMMAND_RULE$.ENABLED%TYPE
    , PRIVILEGE_SCOPE COMMAND_RULE$.PRIVILEGE_SCOPE%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_CODE_ID# IN NUMBER,
    p_RULE_SET_ID# IN NUMBER,
    p_OBJECT_OWNER IN VARCHAR2,
    p_OBJECT_NAME IN VARCHAR2,
    p_ENABLED IN VARCHAR2,
    p_PRIVILEGE_SCOPE IN NUMBER,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_CODE_ID# OUT NUMBER
    , x_RULE_SET_ID# OUT NUMBER
    , x_OBJECT_OWNER OUT VARCHAR2
    , x_OBJECT_NAME OUT VARCHAR2
    , x_ENABLED OUT VARCHAR2
    );

  PROCEDURE read_by_RULE_SET_ID#_(
    p_RULE_SET_ID# IN number,
    x_attribute_list OUT attribute_list);

  PROCEDURE read_by_CODE_ID#_(
    p_CODE_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_CODE_ID# IN NUMBER
    , p_RULE_SET_ID# IN NUMBER
    , p_OBJECT_OWNER IN VARCHAR2
    , p_OBJECT_NAME IN VARCHAR2
    , p_ENABLED IN VARCHAR2
    , p_PRIVILEGE_SCOPE IN NUMBER
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_RULE_SET_ID#_(
    p_RULE_SET_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_CODE_ID#_(
    p_CODE_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for DOCUMENT$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.DOCUMENT$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# DOCUMENT$.ID#%TYPE
    , NAME DOCUMENT$.NAME%TYPE
    , DOC_TYPE DOCUMENT$.DOC_TYPE%TYPE
    , DOC_REVISION DOCUMENT$.DOC_REVISION%TYPE
    , ENABLED DOCUMENT$.ENABLED%TYPE
    , XML_DATA DOCUMENT$.XML_DATA%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_NAME IN VARCHAR2,
    p_DOC_TYPE IN NUMBER,
    p_DOC_REVISION IN VARCHAR2,
    p_ENABLED IN NUMBER,
    p_XML_DATA IN CLOB,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_NAME OUT VARCHAR2
    , x_DOC_TYPE OUT NUMBER
    , x_DOC_REVISION OUT VARCHAR2
    , x_ENABLED OUT NUMBER
    , x_XML_DATA OUT CLOB
    );

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_NAME IN VARCHAR2
    , p_DOC_TYPE IN NUMBER
    , p_DOC_REVISION IN VARCHAR2
    , p_ENABLED IN NUMBER
    , p_XML_DATA IN CLOB
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for FACTOR$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.FACTOR$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# FACTOR$.ID#%TYPE
    , NAME FACTOR$.NAME%TYPE
    -- , DESCRIPTION FACTOR$.DESCRIPTION%TYPE
    , FACTOR_TYPE_ID# FACTOR$.FACTOR_TYPE_ID#%TYPE
    , ASSIGN_RULE_SET_ID# FACTOR$.ASSIGN_RULE_SET_ID#%TYPE
    , GET_EXPR FACTOR$.GET_EXPR%TYPE
    , VALIDATE_EXPR FACTOR$.VALIDATE_EXPR%TYPE
    , IDENTIFIED_BY FACTOR$.IDENTIFIED_BY%TYPE
    , NAMESPACE FACTOR$.NAMESPACE%TYPE
    , NAMESPACE_ATTRIBUTE FACTOR$.NAMESPACE_ATTRIBUTE%TYPE
    , LABELED_BY FACTOR$.LABELED_BY%TYPE
    , EVAL_OPTIONS FACTOR$.EVAL_OPTIONS%TYPE
    , AUDIT_OPTIONS FACTOR$.AUDIT_OPTIONS%TYPE
    , FAIL_OPTIONS FACTOR$.FAIL_OPTIONS%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_NAME IN VARCHAR2,
    p_DESCRIPTION IN VARCHAR2,
    p_FACTOR_TYPE_ID# IN NUMBER,
    p_ASSIGN_RULE_SET_ID# IN NUMBER,
    p_GET_EXPR IN VARCHAR2,
    p_VALIDATE_EXPR IN VARCHAR2,
    p_IDENTIFIED_BY IN NUMBER,
    p_NAMESPACE IN VARCHAR2,
    p_NAMESPACE_ATTRIBUTE IN VARCHAR2,
    p_LABELED_BY IN NUMBER,
    p_EVAL_OPTIONS IN NUMBER,
    p_AUDIT_OPTIONS IN NUMBER,
    p_FAIL_OPTIONS IN NUMBER,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_NAME OUT VARCHAR2
    , x_DESCRIPTION OUT VARCHAR2
    , x_FACTOR_TYPE_ID# OUT NUMBER
    , x_ASSIGN_RULE_SET_ID# OUT NUMBER
    , x_GET_EXPR OUT VARCHAR2
    , x_VALIDATE_EXPR OUT VARCHAR2
    , x_IDENTIFIED_BY OUT NUMBER
    , x_NAMESPACE OUT VARCHAR2
    , x_NAMESPACE_ATTRIBUTE OUT VARCHAR2
    , x_LABELED_BY OUT NUMBER
    , x_EVAL_OPTIONS OUT NUMBER
    , x_AUDIT_OPTIONS OUT NUMBER
    , x_FAIL_OPTIONS OUT NUMBER
    );

  PROCEDURE read_by_FACTOR_TYPE_ID#_(
    p_FACTOR_TYPE_ID# IN number,
    x_attribute_list OUT attribute_list);

  PROCEDURE read_by_ASSIGN_RULE_SET_ID#_(
    p_ASSIGN_RULE_SET_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_NAME IN VARCHAR2
    , p_DESCRIPTION IN VARCHAR2
    , p_FACTOR_TYPE_ID# IN NUMBER
    , p_ASSIGN_RULE_SET_ID# IN NUMBER
    , p_GET_EXPR IN VARCHAR2
    , p_VALIDATE_EXPR IN VARCHAR2
    , p_IDENTIFIED_BY IN NUMBER
    , p_NAMESPACE IN VARCHAR2
    , p_NAMESPACE_ATTRIBUTE IN VARCHAR2
    , p_LABELED_BY IN NUMBER
    , p_EVAL_OPTIONS IN NUMBER
    , p_AUDIT_OPTIONS IN NUMBER
    , p_FAIL_OPTIONS IN NUMBER
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_FACTOR_TYPE_ID#_(
    p_FACTOR_TYPE_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_ASSIGN_RULE_SET_ID#_(
    p_ASSIGN_RULE_SET_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for FACTOR_LINK$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.FACTOR_LINK$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# FACTOR_LINK$.ID#%TYPE
    , PARENT_FACTOR_ID# FACTOR_LINK$.PARENT_FACTOR_ID#%TYPE
    , CHILD_FACTOR_ID# FACTOR_LINK$.CHILD_FACTOR_ID#%TYPE
    , LABEL_IND FACTOR_LINK$.LABEL_IND%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_PARENT_FACTOR_ID# IN NUMBER,
    p_CHILD_FACTOR_ID# IN NUMBER,
    p_LABEL_IND IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_PARENT_FACTOR_ID# OUT NUMBER
    , x_CHILD_FACTOR_ID# OUT NUMBER
    , x_LABEL_IND OUT VARCHAR2
    );

  PROCEDURE read_by_PARENT_FACTOR_ID#_(
    p_PARENT_FACTOR_ID# IN number,
    x_attribute_list OUT attribute_list);

  PROCEDURE read_by_CHILD_FACTOR_ID#_(
    p_CHILD_FACTOR_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_PARENT_FACTOR_ID# IN NUMBER
    , p_CHILD_FACTOR_ID# IN NUMBER
    , p_LABEL_IND IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_PARENT_FACTOR_ID#_(
    p_PARENT_FACTOR_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_CHILD_FACTOR_ID#_(
    p_CHILD_FACTOR_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for FACTOR_TYPE$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.FACTOR_TYPE$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# FACTOR_TYPE$.ID#%TYPE
    --, NAME FACTOR_TYPE$.NAME%TYPE
    --, DESCRIPTION FACTOR_TYPE$.DESCRIPTION%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_NAME IN VARCHAR2,
    p_DESCRIPTION IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_NAME OUT VARCHAR2
    , x_DESCRIPTION OUT VARCHAR2
    );

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_NAME IN VARCHAR2
    , p_DESCRIPTION IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for IDENTITY$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.IDENTITY$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# IDENTITY$.ID#%TYPE
    , FACTOR_ID# IDENTITY$.FACTOR_ID#%TYPE
    , VALUE IDENTITY$.VALUE%TYPE
    , TRUST_LEVEL IDENTITY$.TRUST_LEVEL%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_FACTOR_ID# IN NUMBER,
    p_VALUE IN VARCHAR2,
    p_TRUST_LEVEL IN NUMBER,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_FACTOR_ID# OUT NUMBER
    , x_VALUE OUT VARCHAR2
    , x_TRUST_LEVEL OUT NUMBER
    );

  PROCEDURE read_by_FACTOR_ID#_(
    p_FACTOR_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_FACTOR_ID# IN NUMBER
    , p_VALUE IN VARCHAR2
    , p_TRUST_LEVEL IN NUMBER
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_FACTOR_ID#_(
    p_FACTOR_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for IDENTITY_MAP$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.IDENTITY_MAP$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# IDENTITY_MAP$.ID#%TYPE
    , IDENTITY_ID# IDENTITY_MAP$.IDENTITY_ID#%TYPE
    , FACTOR_LINK_ID# IDENTITY_MAP$.FACTOR_LINK_ID#%TYPE
    , OPERATION_CODE_ID# IDENTITY_MAP$.OPERATION_CODE_ID#%TYPE
    , OPERAND1 IDENTITY_MAP$.OPERAND1%TYPE
    , OPERAND2 IDENTITY_MAP$.OPERAND2%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_IDENTITY_ID# IN NUMBER,
    p_FACTOR_LINK_ID# IN NUMBER,
    p_OPERATION_CODE_ID# IN NUMBER,
    p_OPERAND1 IN VARCHAR2,
    p_OPERAND2 IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_IDENTITY_ID# OUT NUMBER
    , x_FACTOR_LINK_ID# OUT NUMBER
    , x_OPERATION_CODE_ID# OUT NUMBER
    , x_OPERAND1 OUT VARCHAR2
    , x_OPERAND2 OUT VARCHAR2
    );

  PROCEDURE read_by_IDENTITY_ID#_(
    p_IDENTITY_ID# IN number,
    x_attribute_list OUT attribute_list);

  PROCEDURE read_by_FACTOR_LINK_ID#_(
    p_FACTOR_LINK_ID# IN number,
    x_attribute_list OUT attribute_list);

  PROCEDURE read_by_OPERATION_CODE_ID#_(
    p_OPERATION_CODE_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_IDENTITY_ID# IN NUMBER
    , p_FACTOR_LINK_ID# IN NUMBER
    , p_OPERATION_CODE_ID# IN NUMBER
    , p_OPERAND1 IN VARCHAR2
    , p_OPERAND2 IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_IDENTITY_ID#_(
    p_IDENTITY_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_FACTOR_LINK_ID#_(
    p_FACTOR_LINK_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_OPERATION_CODE_ID#_(
    p_OPERATION_CODE_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for MAC_POLICY$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.MAC_POLICY$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# MAC_POLICY$.ID#%TYPE
    , POLICY_ID# MAC_POLICY$.POLICY_ID#%TYPE
    , ALGORITHM_CODE_ID# MAC_POLICY$.ALGORITHM_CODE_ID#%TYPE
    , ERROR_LABEL MAC_POLICY$.ERROR_LABEL%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_POLICY_ID# IN NUMBER,
    p_ALGORITHM_CODE_ID# IN NUMBER,
    p_ERROR_LABEL IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_POLICY_ID# OUT NUMBER
    , x_ALGORITHM_CODE_ID# OUT NUMBER
    , x_ERROR_LABEL OUT VARCHAR2
    );

  PROCEDURE read_by_ALGORITHM_CODE_ID#_(
    p_ALGORITHM_CODE_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_POLICY_ID# IN NUMBER
    , p_ALGORITHM_CODE_ID# IN NUMBER
    , p_ERROR_LABEL IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_ALGORITHM_CODE_ID#_(
    p_ALGORITHM_CODE_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for MAC_POLICY_FACTOR$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.MAC_POLICY_FACTOR$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# MAC_POLICY_FACTOR$.ID#%TYPE
    , FACTOR_ID# MAC_POLICY_FACTOR$.FACTOR_ID#%TYPE
    , MAC_POLICY_ID# MAC_POLICY_FACTOR$.MAC_POLICY_ID#%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_FACTOR_ID# IN NUMBER,
    p_MAC_POLICY_ID# IN NUMBER,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_FACTOR_ID# OUT NUMBER
    , x_MAC_POLICY_ID# OUT NUMBER
    );

  PROCEDURE read_by_FACTOR_ID#_(
    p_FACTOR_ID# IN number,
    x_attribute_list OUT attribute_list);

  PROCEDURE read_by_MAC_POLICY_ID#_(
    p_MAC_POLICY_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_FACTOR_ID# IN NUMBER
    , p_MAC_POLICY_ID# IN NUMBER
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_FACTOR_ID#_(
    p_FACTOR_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_MAC_POLICY_ID#_(
    p_MAC_POLICY_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for POLICY_LABEL$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.POLICY_LABEL$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# POLICY_LABEL$.ID#%TYPE
    , IDENTITY_ID# POLICY_LABEL$.IDENTITY_ID#%TYPE
    , POLICY_ID# POLICY_LABEL$.POLICY_ID#%TYPE
    , LABEL_ID# POLICY_LABEL$.LABEL_ID#%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_IDENTITY_ID# IN NUMBER,
    p_POLICY_ID# IN NUMBER,
    p_LABEL_ID# IN NUMBER,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_IDENTITY_ID# OUT NUMBER
    , x_POLICY_ID# OUT NUMBER
    , x_LABEL_ID# OUT NUMBER
    );

  PROCEDURE read_by_IDENTITY_ID#_(
    p_IDENTITY_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_IDENTITY_ID# IN NUMBER
    , p_POLICY_ID# IN NUMBER
    , p_LABEL_ID# IN NUMBER
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_IDENTITY_ID#_(
    p_IDENTITY_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for REALM_AUTH$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.REALM_AUTH$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# REALM_AUTH$.ID#%TYPE
    , REALM_ID# REALM_AUTH$.REALM_ID#%TYPE
    , GRANTEE REALM_AUTH$.GRANTEE%TYPE
    , AUTH_RULE_SET_ID# REALM_AUTH$.AUTH_RULE_SET_ID#%TYPE
    , AUTH_OPTIONS REALM_AUTH$.AUTH_OPTIONS%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_REALM_ID# IN NUMBER,
    p_GRANTEE IN VARCHAR2,
    p_AUTH_RULE_SET_ID# IN NUMBER,
    p_AUTH_OPTIONS IN NUMBER,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_REALM_ID# OUT NUMBER
    , x_GRANTEE OUT VARCHAR2
    , x_AUTH_RULE_SET_ID# OUT NUMBER
    , x_AUTH_OPTIONS OUT NUMBER
    );

  PROCEDURE read_by_REALM_ID#_(
    p_REALM_ID# IN number,
    x_attribute_list OUT attribute_list);

  PROCEDURE read_by_AUTH_RULE_SET_ID#_(
    p_AUTH_RULE_SET_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_REALM_ID# IN NUMBER
    , p_GRANTEE IN VARCHAR2
    , p_AUTH_RULE_SET_ID# IN NUMBER
    , p_AUTH_OPTIONS IN NUMBER
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_REALM_ID#_(
    p_REALM_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_AUTH_RULE_SET_ID#_(
    p_AUTH_RULE_SET_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for REALM$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.REALM$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# REALM$.ID#%TYPE
    --, NAME REALM$.NAME%TYPE
    --, DESCRIPTION REALM$.DESCRIPTION%TYPE
    , ENABLED REALM$.ENABLED%TYPE
    , AUDIT_OPTIONS REALM$.AUDIT_OPTIONS%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_NAME IN VARCHAR2,
    p_DESCRIPTION IN VARCHAR2,
    p_ENABLED IN VARCHAR2,
    p_AUDIT_OPTIONS IN NUMBER,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_NAME OUT VARCHAR2
    , x_DESCRIPTION OUT VARCHAR2
    , x_ENABLED OUT VARCHAR2
    , x_AUDIT_OPTIONS OUT NUMBER
    );

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_NAME IN VARCHAR2
    , p_DESCRIPTION IN VARCHAR2
    , p_ENABLED IN VARCHAR2
    , p_AUDIT_OPTIONS IN NUMBER
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for REALM_OBJECT$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.REALM_OBJECT$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# REALM_OBJECT$.ID#%TYPE
    , REALM_ID# REALM_OBJECT$.REALM_ID#%TYPE
    , OWNER REALM_OBJECT$.OWNER%TYPE
    , OBJECT_NAME REALM_OBJECT$.OBJECT_NAME%TYPE
    , OBJECT_TYPE REALM_OBJECT$.OBJECT_TYPE%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_REALM_ID# IN NUMBER,
    p_OWNER IN VARCHAR2,
    p_OBJECT_NAME IN VARCHAR2,
    p_OBJECT_TYPE IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_REALM_ID# OUT NUMBER
    , x_OWNER OUT VARCHAR2
    , x_OBJECT_NAME OUT VARCHAR2
    , x_OBJECT_TYPE OUT VARCHAR2
    );

  PROCEDURE read_by_REALM_ID#_(
    p_REALM_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_REALM_ID# IN NUMBER
    , p_OWNER IN VARCHAR2
    , p_OBJECT_NAME IN VARCHAR2
    , p_OBJECT_TYPE IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  -- Delete method, doesn't require p_id#
  PROCEDURE delete_row(
    p_REALM_NAME IN VARCHAR2,
    p_OWNER IN VARCHAR2,
    p_OBJECT_NAME IN VARCHAR2,
    p_OBJECT_TYPE IN VARCHAR2);

  PROCEDURE delete_by_REALM_ID#_(
    p_REALM_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for ROLE$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.ROLE$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# ROLE$.ID#%TYPE
    , ROLE ROLE$.ROLE%TYPE
    , RULE_SET_ID# ROLE$.RULE_SET_ID#%TYPE
    , ENABLED ROLE$.ENABLED%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_ROLE IN VARCHAR2,
    p_RULE_SET_ID# IN NUMBER,
    p_ENABLED IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_ROLE OUT VARCHAR2
    , x_RULE_SET_ID# OUT NUMBER
    , x_ENABLED OUT VARCHAR2
    );

  PROCEDURE read_by_RULE_SET_ID#_(
    p_RULE_SET_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_ROLE IN VARCHAR2
    , p_RULE_SET_ID# IN NUMBER
    , p_ENABLED IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_RULE_SET_ID#_(
    p_RULE_SET_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for RULE_SET$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.RULE_SET$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# RULE_SET$.ID#%TYPE
    --, NAME RULE_SET$.NAME%TYPE
    --, DESCRIPTION RULE_SET$.DESCRIPTION%TYPE
    , ENABLED RULE_SET$.ENABLED%TYPE
    , EVAL_OPTIONS RULE_SET$.EVAL_OPTIONS%TYPE
    , AUDIT_OPTIONS RULE_SET$.AUDIT_OPTIONS%TYPE
    , FAIL_OPTIONS RULE_SET$.FAIL_OPTIONS%TYPE
    --, FAIL_MESSAGE RULE_SET$.FAIL_MESSAGE%TYPE
    , FAIL_CODE RULE_SET$.FAIL_CODE%TYPE
    , HANDLER_OPTIONS RULE_SET$.HANDLER_OPTIONS%TYPE
    , HANDLER RULE_SET$.HANDLER%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_NAME IN VARCHAR2,
    p_DESCRIPTION IN VARCHAR2,
    p_ENABLED IN VARCHAR2,
    p_EVAL_OPTIONS IN NUMBER,
    p_AUDIT_OPTIONS IN NUMBER,
    p_FAIL_OPTIONS IN NUMBER,
    p_FAIL_MESSAGE IN VARCHAR2,
    p_FAIL_CODE IN VARCHAR2,
    p_HANDLER_OPTIONS IN NUMBER,
    p_HANDLER IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_NAME OUT VARCHAR2
    , x_DESCRIPTION OUT VARCHAR2
    , x_ENABLED OUT VARCHAR2
    , x_EVAL_OPTIONS OUT NUMBER
    , x_AUDIT_OPTIONS OUT NUMBER
    , x_FAIL_OPTIONS OUT NUMBER
    , x_FAIL_MESSAGE OUT VARCHAR2
    , x_FAIL_CODE OUT VARCHAR2
    , x_HANDLER_OPTIONS OUT NUMBER
    , x_HANDLER OUT VARCHAR2
    );

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_NAME IN VARCHAR2
    , p_DESCRIPTION IN VARCHAR2
    , p_ENABLED IN VARCHAR2
    , p_EVAL_OPTIONS IN NUMBER
    , p_AUDIT_OPTIONS IN NUMBER
    , p_FAIL_OPTIONS IN NUMBER
    , p_FAIL_MESSAGE IN VARCHAR2
    , p_FAIL_CODE IN VARCHAR2
    , p_HANDLER_OPTIONS IN NUMBER
    , p_HANDLER IN VARCHAR2
    );

  PROCEDURE rename_rule_set
              (rule_set_name IN varchar2,
               new_name      IN varchar2); 

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for RULE_SET_RULE$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.RULE_SET_RULE$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# RULE_SET_RULE$.ID#%TYPE
    , RULE_SET_ID# RULE_SET_RULE$.RULE_SET_ID#%TYPE
    , RULE_ID# RULE_SET_RULE$.RULE_ID#%TYPE
    , RULE_ORDER RULE_SET_RULE$.RULE_ORDER%TYPE
    , ENABLED RULE_SET_RULE$.ENABLED%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_RULE_SET_ID# IN NUMBER,
    p_RULE_ID# IN NUMBER,
    p_RULE_ORDER IN NUMBER,
    p_ENABLED IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_RULE_SET_ID# OUT NUMBER
    , x_RULE_ID# OUT NUMBER
    , x_RULE_ORDER OUT NUMBER
    , x_ENABLED OUT VARCHAR2
    );

  PROCEDURE read_by_RULE_SET_ID#_(
    p_RULE_SET_ID# IN number,
    x_attribute_list OUT attribute_list);

  PROCEDURE read_by_RULE_ID#_(
    p_RULE_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_RULE_SET_ID# IN NUMBER
    , p_RULE_ID# IN NUMBER
    , p_RULE_ORDER IN NUMBER
    , p_ENABLED IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_RULE_SET_ID#_(
    p_RULE_SET_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_RULE_ID#_(
    p_RULE_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for RULE$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.RULE$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# RULE$.ID#%TYPE
    --, NAME RULE$.NAME%TYPE
    , RULE_EXPR RULE$.RULE_EXPR%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_NAME IN VARCHAR2,
    p_RULE_EXPR IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_NAME OUT VARCHAR2
    , x_RULE_EXPR OUT VARCHAR2
    );

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_NAME IN VARCHAR2
    , p_RULE_EXPR IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for FACTOR_SCOPE$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.FACTOR_SCOPE$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# FACTOR_SCOPE$.ID#%TYPE
    , FACTOR_ID FACTOR_SCOPE$.FACTOR_ID#%TYPE
    , GRANTEE FACTOR_SCOPE$.GRANTEE%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_FACTOR_ID IN NUMBER,
    p_GRANTEE IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_FACTOR_ID OUT NUMBER
    , x_GRANTEE OUT VARCHAR2
    );

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_FACTOR_ID IN NUMBER
    , p_GRANTEE IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for realm_command_rule$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.realm_command_rule$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# realm_command_rule$.ID#%TYPE
    , REALM_ID# realm_command_rule$.REALM_ID#%TYPE
    , CODE_ID# realm_command_rule$.CODE_ID#%TYPE
    , RULE_SET_ID# realm_command_rule$.RULE_SET_ID#%TYPE
    , OBJECT_OWNER realm_command_rule$.OBJECT_OWNER%TYPE
    , OBJECT_NAME realm_command_rule$.OBJECT_NAME%TYPE
    , GRANTEE realm_command_rule$.GRANTEE%TYPE
    , ENABLED realm_command_rule$.ENABLED%TYPE
    , PRIVILEGE_SCOPE realm_command_rule$.PRIVILEGE_SCOPE%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_REALM_ID# IN NUMBER,
    p_CODE_ID# IN NUMBER,
    p_RULE_SET_ID# IN NUMBER,
    p_OBJECT_OWNER IN VARCHAR2,
    p_OBJECT_NAME IN VARCHAR2,
    p_GRANTEE IN VARCHAR2,
    p_ENABLED IN VARCHAR2,
    p_PRIVILEGE_SCOPE IN NUMBER,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_REALM_ID# OUT NUMBER
    , x_CODE_ID# OUT NUMBER
    , x_RULE_SET_ID# OUT NUMBER
    , x_OBJECT_OWNER OUT VARCHAR2
    , x_OBJECT_NAME OUT VARCHAR2
    , x_GRANTEE OUT VARCHAR2
    , x_ENABLED OUT VARCHAR2
    );

  PROCEDURE read_by_RULE_SET_ID#_(
    p_RULE_SET_ID# IN number,
    x_attribute_list OUT attribute_list);

  PROCEDURE read_by_CODE_ID#_(
    p_CODE_ID# IN number,
    x_attribute_list OUT attribute_list);

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_REALM_ID# IN NUMBER
    , p_CODE_ID# IN NUMBER
    , p_RULE_SET_ID# IN NUMBER
    , p_OBJECT_OWNER IN VARCHAR2
    , p_OBJECT_NAME IN VARCHAR2
    , p_GRANTEE IN VARCHAR2
    , p_ENABLED IN VARCHAR2
    , p_PRIVILEGE_SCOPE IN NUMBER
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

  PROCEDURE delete_by_RULE_SET_ID#_(
    p_RULE_SET_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_REALM_ID#_(
    p_REALM_ID# IN number,
    p_delete_children IN boolean := false);

  PROCEDURE delete_by_CODE_ID#_(
    p_CODE_ID# IN number,
    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Public CRUD interface for monitor_rule$ table.
Rem
Rem
Rem
Rem
Rem
CREATE OR REPLACE PACKAGE DVSYS.monitor_rule$_priv AS

  TYPE attribute_rec IS RECORD (
      ID# monitor_rule$.ID#%TYPE
    --, NAME monitor_rule$.NAME%TYPE
    --, DESCRIPTION monitor_rule$.DESCRIPTION%TYPE
    , MONITOR_RULE_SET_ID monitor_rule$.RESTART_FREQ%TYPE
    , RESTART_FREQ monitor_rule$.RESTART_FREQ%TYPE
    , ENABLED monitor_rule$.ENABLED%TYPE
  );

  TYPE attribute_list IS VARRAY(4096) OF attribute_rec;

  -- Create method
  PROCEDURE create_row(
    p_NAME IN VARCHAR2,
    p_DESCRIPTION IN VARCHAR2,
    p_MONITOR_RULE_SET_ID IN NUMBER,
    p_RESTART_FREQ IN NUMBER,
    p_ENABLED IN VARCHAR2,
    x_id# OUT number);

  -- Read method
  PROCEDURE read_row(p_id#        IN     number,
      x_ID# OUT NUMBER
    , x_NAME OUT VARCHAR2
    , x_DESCRIPTION OUT VARCHAR2
    , x_MONITOR_RULE_SET_ID OUT NUMBER
    , x_RESTART_FREQ OUT NUMBER
    , x_ENABLED OUT VARCHAR2
    );

  -- Update method
  PROCEDURE update_row(
      p_id# NUMBER
    , p_NAME IN VARCHAR2
    , p_DESCRIPTION IN VARCHAR2
    , p_MONITOR_RULE_SET_ID IN NUMBER
    , p_RESTART_FREQ IN NUMBER
    , p_ENABLED IN VARCHAR2
    );

  -- Delete method
  PROCEDURE delete_row(p_id# IN number,
                    p_delete_children IN boolean := false);

END;
/
Rem
Rem
Rem    DESCRIPTION
Rem      Package specification for dbms_output replacement package
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macout
AS
    /**
    * Turn on tracing.
    */
    PROCEDURE enable;

    /**
    * Turn off tracing.
    */
    PROCEDURE disable;

    /**
    * Add text to the output (without a new line)
    * @param s String
    */
    PROCEDURE put( s IN VARCHAR2 );


    /**
    * Add text to the output (with a new line)
    * @param s String
    */
    PROCEDURE put_line( s IN VARCHAR2 );

    /**
    * Add a new line to the output
    */
    PROCEDURE new_line;

    /**
    * Same as put.
    * @param s String
    */
    PROCEDURE p( s IN VARCHAR2 );

    /**
    * Same as put_line.
    * @param s String
    */
    PROCEDURE pl( s IN VARCHAR2 );

    /**
    * Same as new_line.
    */
    PROCEDURE nl;

    /**
    * Retrieve a line of text from the buffer.  The line is deleted from
    * the line buffer.
    * @param n Line number
    */
    FUNCTION get_line( n IN NUMBER ) RETURN VARCHAR2;

    PRAGMA RESTRICT_REFERENCES( get_line, WNDS, RNDS );

    /**
    * Number of lines in the buffer.
    * @return Number of lines in the buffer
    */
    FUNCTION get_line_COUNT RETURN NUMBER;

    /**
    * Is the trace facility enabled.
    * @return An indicator that the trace facility is enabled for this session
    */
    FUNCTION is_enabled RETURN BOOLEAN;

    PRAGMA RESTRICT_REFERENCES( get_line_COUNT, WNDS, RNDS, WNPS );

    PRAGMA RESTRICT_REFERENCES( dbms_macout, WNDS, RNDS, WNPS, RNPS );
END;
/
show errors;

BEGIN
EXECUTE IMMEDIATE
'CREATE SYNONYM dvsys.out FOR dvsys.dbms_macout';
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00955) THEN NULL; --synonym already created
     ELSE RAISE;
     END IF;
END;
/

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Package specification for public Data Vault Administration APIs
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macutl AS

  /********************/
  /* Global Constants */
  /********************/
  -- Yes constant for enabled and label_ind columns (Boolean TRUE)
  g_yes CONSTANT VARCHAR2(1) := 'Y';
  -- No constant for enabled and label_ind columns (Boolean FALSE)
  g_no  CONSTANT VARCHAR2(1) := 'N';

  -- Factor audit_options: No audit
  g_audit_off                       CONSTANT NUMBER := 0;
  -- Factor audit_options: Always audit
  g_audit_always                    CONSTANT NUMBER := POWER(2,0);
  -- Factor audit_options: Audit if get_expr returns an error
  g_audit_on_get_error              CONSTANT NUMBER := POWER(2,1);
  -- Factor audit_options: Audit if get_expr is null
  g_audit_on_get_null               CONSTANT NUMBER := POWER(2,2);
  -- Factor audit_options: Audit if validation function returns error
  g_audit_on_validate_error         CONSTANT NUMBER := POWER(2,3);
  -- Factor audit_options: Audit if validation function is false
  g_audit_on_validate_false         CONSTANT NUMBER := POWER(2,4);
  -- Factor audit_options: Audit if no trust level
  g_audit_on_trust_level_null       CONSTANT NUMBER := POWER(2,5);
  -- Factor audit_options: Audit if trus level is negative
  g_audit_on_trust_level_neg        CONSTANT NUMBER := POWER(2,6);

  -- Fail_options: Fail with message
  g_fail_with_message   CONSTANT NUMBER := POWER(2,0);
  -- Fail_options: Fail with message
  g_fail_silently       CONSTANT NUMBER := POWER(2,1);

  -- Factor identify_by column: Fixed value in get_expr column
  g_identify_by_constant    CONSTANT NUMBER := 0;
  -- Factor identify_by column: Expression in get_expr column
  g_identify_by_method      CONSTANT NUMBER := 1;
  -- Factor identify_by column: Sub-factors via factor_link$ table
  g_identify_by_factor      CONSTANT NUMBER := 2;
  -- Factor identify_by session context
  g_identify_by_context     CONSTANT NUMBER := 3;

  -- Factor identify_by column:  Expression and Rule Set via factor_expr$ table
  -- g_identify_by_ruleset     CONSTANT NUMBER := 4;

  -- Factor eval_options: Evaluate once upon login
  g_eval_on_session CONSTANT NUMBER := 0;
  -- Factor eval_options: Re-evaluate on each access
  g_eval_on_access  CONSTANT NUMBER := 1;
  -- Factor eval_options: Evaluate once at database startup
  g_eval_on_startup  CONSTANT NUMBER := 2;

  -- Factor labeled_by column: Factor's identities are labeled
  g_labeled_by_self     CONSTANT NUMBER := 0;
  -- Factor labeled_by column: Derive label from sub-factor and merge algorithm
  g_labeled_by_factors  CONSTANT NUMBER := 1;

  -- Realm Objects: Wild card to indicate all object names or all object types
  g_all_object CONSTANT VARCHAR2(1) := '%';

  -- Rule Set audit_options: No auditing
  g_ruleset_audit_off            CONSTANT NUMBER := 0;
  -- Rule Set audit_options: Audit on Rule Set failure
  g_ruleset_audit_fail           CONSTANT NUMBER := POWER(2,0);
  -- Rule Set audit_options: Audit on Rule Set success
  g_ruleset_audit_success        CONSTANT NUMBER := POWER(2,1);

  -- Rule Set eval_options: Rule Set succeeds if all Rules are TRUE
  g_ruleset_eval_all             CONSTANT NUMBER := 1;
  -- Rule Set eval_options: Rule Set succeeds if any Rule is TRUE
  g_ruleset_eval_any             CONSTANT NUMBER := 2;

  -- Rule Set fail_options: Show error message
  g_ruleset_fail_show            CONSTANT NUMBER := 1;
  -- Rule Set fail_options: No error message
  g_ruleset_fail_silent          CONSTANT NUMBER := 2;

  -- Rule Set handler_options: No call to handler
  g_ruleset_handler_off          CONSTANT NUMBER := 0;
  -- Rule Set handler_options: Call handler on Rule Set failure
  g_ruleset_handler_fail         CONSTANT NUMBER := POWER(2,0);
  -- Rule Set handler_options: Call handler on Rule Set success
  g_ruleset_handler_success      CONSTANT NUMBER := POWER(2,1);

  -- Realm audit_options: No auditing
  g_realm_audit_off              CONSTANT NUMBER := 0;
  -- Realm audit_options: Audit on realm violation
  g_realm_audit_fail             CONSTANT NUMBER := POWER(2,0);
  -- Realm audit_options: Audit on successful realm access
  g_realm_audit_success          CONSTANT NUMBER := POWER(2,1);

  -- Realm authoriations: Participant
  g_realm_auth_participant       CONSTANT NUMBER := 0;
  -- Realm authoriations: Owner
  g_realm_auth_owner             CONSTANT NUMBER := 1;


  -- Code groups: Audit Event Descriptions
  g_codes_audit_events    CONSTANT VARCHAR2(30) := 'AUDIT_EVENTS';
  -- Code groups: Boolean values
  g_codes_boolean         CONSTANT VARCHAR2(30) := 'BOOLEAN';
  -- Code groups: DDL commands
  g_codes_ddl_cmds        CONSTANT VARCHAR2(30) := 'DDL_CMDS';
  -- Code groups: Factor audit_options
  g_codes_factor_audit    CONSTANT VARCHAR2(30) := 'FACTOR_AUDIT';
  -- Code groups: Factor eval_options
  g_codes_factor_eval     CONSTANT VARCHAR2(30) := 'FACTOR_EVALUATE';
  -- Code groups: Factor fail_options
  g_codes_factor_fail     CONSTANT VARCHAR2(30) := 'FACTOR_FAIL';
  -- Code groups: Factor identity_by
  g_codes_factor_identify CONSTANT VARCHAR2(30) := 'FACTOR_IDENTIFY';
  -- Code groups: Factor labeled_by
  g_codes_factor_label    CONSTANT VARCHAR2(30) := 'FACTOR_LABEL';
  -- Code groups: Database object types
  g_codes_db_object_type  CONSTANT VARCHAR2(30) := 'DB_OBJECT_TYPE';
  -- Code groups: OLS Policy merge algorithms
  g_codes_label_alg       CONSTANT VARCHAR2(30) := 'LABEL_ALG';
  -- Code groups: DV Error messages
  g_codes_messages        CONSTANT VARCHAR2(30) := 'DV_MESSAGES';
  -- Code groups: SQL relational operators
  g_codes_operators       CONSTANT VARCHAR2(30) := 'OPERATORS';
  -- Code groups: Realm audit_options
  g_codes_realm_audit     CONSTANT VARCHAR2(30) := 'REALM_AUDIT';
  -- Code groups: Rule Set audit_options
  g_codes_ruleset_audit   CONSTANT VARCHAR2(30) := 'RULESET_AUDIT';
  -- Code groups: Rule Set evaluate_options
  g_codes_ruleset_eval    CONSTANT VARCHAR2(30) := 'RULESET_EVALUATE';
  -- Code groups: Rule Set handler_options
  g_codes_ruleset_event   CONSTANT VARCHAR2(30) := 'RULESET_EVENT';
  -- Code groups: Rule Set fail_options
  g_codes_ruleset_fail    CONSTANT VARCHAR2(30) := 'RULESET_FAIL';
  -- Code groups: SQL Commands
  g_codes_sql_cmds        CONSTANT VARCHAR2(30) := 'SQL_CMDS';

  -- Context:   Namespace, Attribute, Value
  -- MACSEC/MACOLS context start with this
  g_context_prefix CONSTANT VARCHAR2(30) := 'MAC$';
  -- Factor Labels:    MAC$F$<policy>, <factor_name>, <factor label>
  g_context_factor_label CONSTANT VARCHAR2(30) := g_context_prefix||'F$';
  -- Session Labels:   MAC$S$<policy>, <session attribute>, <label>
  g_context_session_label CONSTANT VARCHAR2(30) := g_context_prefix||'S$';
  -- Factors:   MAC$FACTOR,<factor name>, <factor value>
  g_context_factor CONSTANT VARCHAR2(30) := g_context_prefix||'FACTOR';
  -- Realm:   MAC$REALM,<factor name>, <factor value>
  g_context_realm CONSTANT VARCHAR2(30) := g_context_prefix||'REALM';

  -- This is that label that a factor will a null label will default to
  g_min_policy_label CONSTANT VARCHAR2(30) := 'MIN_POLICY_LABEL';
  -- This is the highest label a user could set based on the factors
  -- (it does not take into account the user's label)
  g_max_session_label CONSTANT VARCHAR2(30) := 'MAX_SESSION_LABEL';
  -- The user's OLS session label at the time init_session is executed
  g_ols_session_label CONSTANT VARCHAR2(30) := 'OLS_SESSION_LABEL';
  -- This is what MACOLS decided the user's label should be set to
  -- after factoring in the above values.
  g_user_policy_label CONSTANT VARCHAR2(30) := 'USER_POLICY_LABEL';

  /**
  * Returns an indicator as to whether or not OLS is installed
  *
  * @return TRUE if OLS is installed
  */
  FUNCTION is_ols_installed RETURN BOOLEAN;

  /**
  * Returns an indicator as to whether or not OLS is installed
  *
  * @return Y if OLS is installed, N otherwise
  */
  FUNCTION is_ols_installed_varchar RETURN VARCHAR2;

  /**
  * Returns an indicator as to whether or not DV is enabled 
  *
  * @return TRUE if DV is enabled, FALSE otherwise
  */
  FUNCTION is_dv_enabled RETURN BOOLEAN ;
 
  /**
  * Returns an indicator as to whether logon user has DV datapump auth
  * on the object specified.
  * @return TRUE if logon user has the auth, otherwise return FALSE  
  */
  FUNCTION check_datapump_privilege(
               p_object_owner            IN varchar2,
               p_object_name             IN varchar2,
               p_object_type             IN varchar2
             )
  RETURN BOOLEAN ;
 
  /**
  * Returns an indicator as to whether or not DV is enabled 
  *
  * @return Y if DV is enabled, N otherwise
  */
  FUNCTION is_dv_enabled_varchar RETURN VARCHAR2 ;

  /**
  * Returns an indicator as to whether or not OID enabled OLS is installed
  *
  * @return TRUE if OID enabled OLS is installed
  */
  FUNCTION is_oid_enabled_ols RETURN BOOLEAN;

  /**
  * Returns ldap user if OID enabled OLS is installed
  *
  * @return logon user
  */
  FUNCTION ols_ldap_user RETURN VARCHAR2;

  /**
  * Returns unique user ID whether user is from OID or standard database accounts
  *
  * @return unique user ID from OID or dbms_standard.login_user
  */
  FUNCTION unique_user RETURN VARCHAR2;

  /**
  * Looks up the value for a code within a code group
  *
  * @param p_code_group Code group - e.g. AUDIT_EVENTS or BOOLEAN
  * @return Value of the code
  */
  FUNCTION get_code_value(p_code_group VARCHAR2, p_code VARCHAR2) RETURN VARCHAR2;

  /**
  * Looks up the id for a code within a code group
  *
  * @param p_code_group Code group - e.g. AUDIT_EVENTS or BOOLEAN
  * @return Id of the code
  */
  FUNCTION get_code_id(p_code_group VARCHAR2, p_code VARCHAR2) RETURN NUMBER;

  /**
  * Looks up an error message and replaces parameters accordingly
  *
  * @param p_message_code VARCHAR Message code
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  * @param p_parameter5 Value to substitute for %5
  * @param p_parameter6 Value to substitute for %6
  * @return Error message
  */
  FUNCTION get_message_label(p_message_code VARCHAR2,
                        p_parameter1   IN VARCHAR2 DEFAULT NULL,
                        p_parameter2   IN VARCHAR2 DEFAULT NULL,
                        p_parameter3   IN VARCHAR2 DEFAULT NULL,
                        p_parameter4   IN VARCHAR2 DEFAULT NULL,
                        p_parameter5   IN VARCHAR2 DEFAULT NULL,
                        p_parameter6   IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;

  /**
  * Looks up an error message and replaces parameters accordingly
  *
  * @param p_message_code NUMBER Message code
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  * @param p_parameter5 Value to substitute for %5
  * @param p_parameter6 Value to substitute for %6
  * @return Error message
  */
  FUNCTION get_message_label(p_message_code NUMBER,
                        p_parameter1   IN VARCHAR2 DEFAULT NULL,
                        p_parameter2   IN VARCHAR2 DEFAULT NULL,
                        p_parameter3   IN VARCHAR2 DEFAULT NULL,
                        p_parameter4   IN VARCHAR2 DEFAULT NULL,
                        p_parameter5   IN VARCHAR2 DEFAULT NULL,
                        p_parameter6   IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2;
  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  */
  PROCEDURE raise_error(p_message_code IN NUMBER);
  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2);
  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2);
  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2,
                        p_parameter3   IN VARCHAR2);
  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2,
                        p_parameter3   IN VARCHAR2,
                        p_parameter4   IN VARCHAR2);

  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  * @param p_parameter5 Value to substitute for %5
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2,
                        p_parameter3   IN VARCHAR2,
                        p_parameter4   IN VARCHAR2,
                        p_parameter5   IN VARCHAR2);

  /**
  * Convience function to look up an error message and
  * replaces parameters accordingly and raise an exception
  *
  * @param p_message_code Oracle error number
  * @param p_parameter1 Value to substitute for %1
  * @param p_parameter2 Value to substitute for %2
  * @param p_parameter3 Value to substitute for %3
  * @param p_parameter4 Value to substitute for %4
  * @param p_parameter5 Value to substitute for %5
  * @param p_parameter6 Value to substitute for %6
  */
  PROCEDURE raise_error(p_message_code IN NUMBER,
                        p_parameter1   IN VARCHAR2,
                        p_parameter2   IN VARCHAR2,
                        p_parameter3   IN VARCHAR2,
                        p_parameter4   IN VARCHAR2,
                        p_parameter5   IN VARCHAR2,
                        p_parameter6   IN VARCHAR2);


  /**
  * Converts the audit_options value for a table to a VARCHAR2 form.
  *
  * @param p_table_name Name of a DV table with a audit_options column (e.g. realm$)
  * @param p_audit_options Audit_options column value (can be several options 'OR-ed' together')
  * @return Audit_options in VARCHAR2 form, separated by commas
  */
  FUNCTION decode_audit_options(p_table_name IN VARCHAR2,
                                p_audit_options IN NUMBER) RETURN VARCHAR2;

  /**
  * Constructs an XML document which contains the values for all of the factors.  Note that
  * the document is only intended for auditing or tracing and will be truncated if it is
  * longer than 4000 characters.
  *
  * @return XML document containing the factor context
  */
  FUNCTION get_factor_context RETURN VARCHAR2;

  /**
  * Concatenates the elements of an ora_name_list_t into a single VARCHAR2.
  *
  * @param p_sql_test Table of VARCHAR2 strings
  * @return Single string
  */
  FUNCTION get_sql_text(p_sql_text IN ora_name_list_t) RETURN VARCHAR2;

  /**
  * Checks whether the character is alphabetic.
  *
  * @param c String with one character
  * @return TRUE if the character is alphabetic
  */
  FUNCTION is_alpha(c IN varchar2) RETURN BOOLEAN;

  /**
  * Checks whether the character is numeric
  *
  * @param c String with one character
  * @return TRUE if the character is a digit
  */
  FUNCTION is_digit(c IN varchar2) RETURN BOOLEAN;

  /**
  * Alters a string to make it a legal Oracle identifier
  *
  * @param id Illegal identifier
  * @return Identifier
  */
  FUNCTION to_oracle_identifier(id IN varchar2) RETURN VARCHAR2;

  /**
  * Convenience procedure for generic disallowed operation exception
  * throws ORA 20920 (Unauthorized Operation) error.
  *
  * @param p_user User performing the operation
  */
  PROCEDURE raise_unauthorized_operation(p_user IN VARCHAR2 DEFAULT USER);

  /**
  * Determines whether a user is authorized to manage the DV configuration.  The
  * DVSYS user and users directly granted the DV_OWNER role are authorized.
  *
  * @param p_user User to check
  * @return TRUE if user is authorized
  */
  FUNCTION is_dvsys_owner(p_user IN VARCHAR2 DEFAULT USER) RETURN BOOLEAN;

  /**
  * Verifies that a public-APIs are not being bypassed by users updating the DV
  * configuration.
  *
  * @param p_user User performing the operation
  * @throws ORA 20920 Unauthorized Operation
  */
  PROCEDURE check_dvsys_dml_allowed(p_user IN VARCHAR2 DEFAULT USER);

  /**
  * Checks for a string in the PL/SQL call stack
  *
  * @param p_search_term String to search for
  * @return TRUE if string is in the call stack
  */
  FUNCTION in_call_stack(p_search_term IN VARCHAR2) RETURN BOOLEAN;

  /**
  * Checks whether a user has a role privilege, directly or indirectly (via another role).
  *
  * @param p_role Role privilege to check for
  * @param p_user User
  * @return TRUE if use has the role
  */
  FUNCTION user_has_role(p_role IN VARCHAR2, p_user IN VARCHAR2 DEFAULT USER)
    RETURN BOOLEAN;

     /**
  * Checks whether a user or role may access an object via a object privilege
  * grant.  The object privilege may have been granted directly to the
  * specified user/role or may have been granted indirectly via another role.
  *
  * @param p_user User or Role
  * @param p_object_owner Object owner
  * @param p_object_name Object name
  * @param p_privilege Object privilege (SELECT, UPDATE, INSERT, ...)
  * @return TRUE if user/role has the privilege
  */
  FUNCTION user_has_object_privilege(p_user         IN VARCHAR2,
                                     p_object_owner IN VARCHAR2,
                                     p_object_name  IN VARCHAR2,
                                     p_privilege    IN VARCHAR2)
   RETURN BOOLEAN;

  /**
  * Checks whether a user has a role privilege, directly or indirectly (via another role).
  *
  * @param p_role Role privilege to check for
  * @param p_user User
  * @return Y if use has the role, Y otherwise
  */
  FUNCTION user_has_role_varchar(p_role IN VARCHAR2, p_user IN VARCHAR2 DEFAULT USER) RETURN VARCHAR2;

  /**
  * Checks whether a user has a system privilege, directly or indirectly (via a role).
  *
  * @param p_role System privilege to check for
  * @param p_user User
  * @return TRUE if use has the privilege
  */
  FUNCTION user_has_system_privilege(p_privilege IN VARCHAR2, p_user IN VARCHAR2 DEFAULT USER) RETURN BOOLEAN;


  /**
  * Checks whether a user has a system privilege, directly or indirectly (via a role).
  *
  * @param p_role System privilege to check for
  * @param p_user User
  * @return Y if use has the privilege; N otherwise
  */
  FUNCTION user_has_system_priv_varchar (p_privilege IN VARCHAR2, p_user IN VARCHAR2 DEFAULT USER) RETURN VARCHAR2;

 /*
  * Checks whether the given user can perform Streams administrative operation. 
  * This is determined by whether the user has DV_STREAMS_ADMIN role. Note that
  * if DV is not enabled, then this function returns TRUE.
  *
  * @param p_user User
  * @return TRUE if 1) DV is not enabled, or 2) the user has DV_STREAMS_ADMIN role.
  *         FALSE otherwise.
  */
  FUNCTION check_streams_admin(p_user IN VARCHAR2) RETURN BOOLEAN;

 /*
  * Checks whether the given user can perform Golden Gate extract operation. 
  * This is determined by whether the user has DV_GOLDENGATE_ADMIN role. Note 
  * that if DV is not enabled, then this function returns TRUE.
  *
  * @param p_user User
  * @return TRUE if 1) DV is not enabled, or 2) user has DV_GOLDENGATE_ADMIN role.
  *         FALSE otherwise.
  */
  FUNCTION check_goldengate_admin(p_user IN VARCHAR2) RETURN BOOLEAN;

 /*
  * Checks whether the given user can perform XSTREAM capture operation. 
  * This is determined by whether the user has DV_XSTREAM_ADMIN role. Note 
  * that if DV is not enabled, then this function returns TRUE.
  *
  * @param p_user User
  * @return TRUE if 1) DV is not enabled, or 2) user has DV_XSTREAM_ADMIN role.
  *         FALSE otherwise.
  */
  FUNCTION check_xstream_admin(p_user IN VARCHAR2) RETURN BOOLEAN;

 /*
  * Checks whether the given user can perform Golden Gate extract operation
  * using the OCI interface. This is determined by whether the user has the 
  * DV_GOLDENGATE_REDO_ACCESS role. Note that if DV is not enabled, then this 
  * function always returns TRUE.
  *
  * @param p_user User
  * @return TRUE if 1) DV is not enabled, or 
  *                 2) user has DV_GOLDENGATE_REDO_ACCESS role.
  *         FALSE otherwise.
  */
  FUNCTION check_goldengate_redo_access(p_user IN VARCHAR2) RETURN BOOLEAN;

  /**
  * Returns the month in Oracle MM format (01-12).
  * @param p_date Date
  * @return Month 01-12.
  */
  FUNCTION get_month(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the day in Oracle DD format (01-31).
  *
  * @param p_date Date
  * @return Day 01-31.
  */
  FUNCTION get_day(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the year in Oracle YYYY format (0001-9999).
  *
  * @param p_date Date
  * @return Year 0001-9999.
  */
  FUNCTION get_year(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the month in Oracle HH24 format (00-23).
  *
  * @param p_date Date
  * @return Hour 00-23.
  */
  FUNCTION get_hour(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the minute in Oracle MI format (00-59).
  *
  * @param p_date Date
  * @return Minute 00-59.
  */
  FUNCTION get_minute(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

  /**
  * Returns the seconds in Oracle SS format (00-59).
  *
  * @param p_date Date
  * @return Second 00-59.
  */
  FUNCTION get_second(p_date IN DATE DEFAULT SYSDATE) RETURN NUMBER;

END;
/

SHOW ERRORS;

Rem
Rem
Rem    DESCRIPTION
Rem      Package specification for public Data Vault Administration APIs
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macadm AS

  /* Global Constants */
  
  G_NLS_dir_obj       CONSTANT VARCHAR2(255) := 'DV_ADMIN_DIR' ;
  

  /*****************************/
  /**Public Administration API */
  /*****************************/

  
  /**
  * Used to enable auditing on activities performed by user with
  * DV_PATCH_ADMIN role. If DV authorization is successful only because of 
  * a user having dv_patch_admin, we would not normally audit this event. But 
  * if this procedure is executed, we will record the event in the audit trail.
  */
  PROCEDURE enable_dv_patch_admin_audit;

  /**
  * Used to disable auditing on dv_patch_admin bypass of DV protection.
  */
  PROCEDURE disable_dv_patch_admin_audit;

  /**
  * Used to allow mixed case identifiers.  By default, they are not allowed.
  *
  * @param setting TRUE to allow mixed case
  */
  PROCEDURE set_preserve_case(setting IN BOOLEAN);

  /* Factor Type */

  /**
  * Create a Factor Type
  *
  * @param name Factor Type name
  * @param description Description
  * @throws ORA 20000 Factor Type already exists
  * @throws ORA 20002 Error creating Factor Type
  */
  PROCEDURE create_factor_type
              (name        IN varchar2,
               description IN varchar2);

  /**
  * Delete a Factor Type
  *
  * @param name Factor Type name
  * @throws ORA 20003 Error deleting Factor Type
  */
  PROCEDURE delete_factor_type
              (name IN varchar2);

  /**
  * Update a Factor Type
  *
  * @param name Factor Type name
  * @param description New Description
  * @throws ORA 20004 Error updating Factor Type
  */
  PROCEDURE update_factor_type
              (name IN varchar2,
               description IN varchar2);

  /**
  * Rename a Factor Type
  *
  * @param old_name Previous Factor Type name
  * @param new_name New Factor Type name
  * @throws ORA 20005 Error renaming Factor Type
  */
  PROCEDURE rename_factor_type
              (old_name IN varchar2,
               new_name    IN varchar2);

  /* Factor */

  /**
  * Create a Factor
  *
  * @param factor_name Factor Name
  * @param factor_type_name Factor Type Name
  * @param description Factor description
  * @param rule_set_name Rule Set Name (for assignment)
  * @param get_expr Expression for evaluating Factor
  * @param validate_expr Name of function to validate Factor
  * @param identify_by Options for determining the Factor's identity (see dbms_macutl)
  * @param labeled_by Options for labeling the Factor (see dbms_macutl)
  * @param eval_options Options for evaluating the Factor (see dbms_macutl)
  * @param audit_options Options for auditing the Factor (see dbms_macutl)
  * @param fail_options Options for reporting Factor errors (see dbms_macutl)
  *
  * @throws ORA 20020 Factor already defined
  * @throws ORA 20022 Error creating Factor
  */
  PROCEDURE create_factor
              (factor_name      IN varchar2,
               factor_type_name IN varchar2,
               description      IN varchar2,
               rule_set_name    IN varchar2,
               get_expr         IN varchar2,
               validate_expr    IN varchar2,
               identify_by      IN number,
               labeled_by       IN number,
               eval_options     IN number,
               audit_options    IN number,
               fail_options     IN number,
               namespace           IN varchar2 DEFAULT NULL,
               namespace_attribute IN varchar2 DEFAULT NULL
               );

  /**
  * Update a Factor
  *
  * @param factor_name Factor Name
  * @param factor_type_name Factor Type Name
  * @param description Factor description
  * @param rule_set_name Rule Set Name (for assignment)
  * @param get_expr Expression for evaluating Factor
  * @param validate_expr Name of function to validate Factor
  * @param identify_by Options for determining the Factor's identity (see dbms_macutl)
  * @param labeled_by Options for labeling the Factor (see dbms_macutl)
  * @param eval_options Options for evaluating the Factor (see dbms_macutl)
  * @param audit_options Options for auditing the Factor (see dbms_macutl)
  * @param fail_options Options for reporting Factor errors (see dbms_macutl)
  *
  * @throws ORA 20024 Error updating Factor
  */
  PROCEDURE update_factor
              (factor_name      IN varchar2,
               factor_type_name IN varchar2,
               description      IN varchar2,
               rule_set_name    IN varchar2,
               get_expr         IN varchar2,
               validate_expr    IN varchar2,
               identify_by      IN number,
               labeled_by       IN number,
               eval_options     IN number,
               audit_options    IN number,
               fail_options     IN number,
               namespace           IN varchar2 DEFAULT NULL,
               namespace_attribute IN varchar2 DEFAULT NULL
               );

  /**
  * Delete a Factor
  *
  * @param factor_name Factor to delete
  *
  * @throws ORA 20023 Error deleting Factor
  */
  PROCEDURE delete_factor
              (factor_name IN varchar2);

  /**
  * Delete a Factor
  *
  * @param factor_name Factor to delete
  *
  * @throws ORA 20024 Error updating Factor
  */
  PROCEDURE rename_factor
              (factor_name IN varchar2, new_factor_name IN varchar2);

  /**Factor Link **/

  /**
  * Specify a parent-child relationship for two factors.  The relationship may be
  * used for computing the Factor's identity or label.
  *
  * @param parent_factor_name Parent Factor name
  * @param child_factor_name Child Factor name
  * @param label_indicator Indication of whether the child contributes to the parent's label
  * @throws ORA 20025 Link already exists
  * @throws ORA 20026 Error adding link
  */
  PROCEDURE add_factor_link
              (parent_factor_name IN varchar2,
               child_factor_name  IN varchar2,
               label_indicator    IN varchar2);

  /**
  * Remove a parent-child relationship for two factors.
  *
  * @param parent_factor_name Parent Factor name
  * @param child_factor_name Child Factor name
  *
  * @throws ORA 20027 Link does not exist
  * @throws ORA 20028 Error removing link
  */
  PROCEDURE delete_factor_link
              (parent_factor_name IN varchar2,
               child_factor_name  IN varchar2);


  /* Policy Factor */

  /**
  * Specify that the label for a Factor contributes to the MAC OLS Label for a
  * policy.
  *
  * @param policy_name OLS Policy Name
  * @param factor_name Factor Name
  *
  * @throws ORA 20200 MAC Policy Factor already defined
  * @throws ORA 20202 Error adding MAC Policy FACTOR
  */
  PROCEDURE add_policy_factor
              (policy_name IN varchar2,
               factor_name IN varchar2);

  /**
  * Remove the Factor from contributing to the MAC OLS Label.
  *
  * @param policy_name OLS Policy Name
  * @param factor_name Factor Name
  *
  * @throws ORA 20203 Error deleting MAC Policy FACTOR
  */
  PROCEDURE delete_policy_factor
              (policy_name IN varchar2,
               factor_name IN varchar2);


  /**
  * Create an Identity.  Entities in the environment which will be labeled should be
  * given an identity (except for users, which are handled by OLS).
  *
  * @param factor_name Factor Name
  * @param value VARCHAR2 value associated with the identity
  * @param trust_level >0 for trust level, =0 for not trusted, <0 for distrust level
  *
  * @throws ORA 20040 Identity already defined
  * @throws ORA 20042 Error creating identity
  */
  PROCEDURE create_identity
              (factor_name IN varchar2,
               value       IN varchar2,
               trust_level IN number);

  /**
  * Update an Identity.
  *
  * @param factor_name Factor Name
  * @param value VARCHAR2 value associated with the identity
  * @param trust_level >0 for trust level, =0 for not trusted, <0 for distrust level
  *
  * @throws ORA 20044 Error updating identity
  */
  PROCEDURE update_identity
              (factor_name IN varchar2,
               value       IN varchar2,
               trust_level IN number);

  /**
  * Associate an identity with a different Factor.
  *
  * @param factor_name Current Factor Name
  * @param value Value of the Identity to update
  * @param new_factor_name Factor Name
  *
  * @throws ORA 20044 Error updating identity
  */
  PROCEDURE change_identity_factor
              (factor_name      IN varchar2,
               value            IN varchar2,
               new_factor_name  IN varchar2);

  /**
  * Update the value of an Identity.
  *
  * @param factor_name Factor Name
  * @param value Current value associated with the identity
  * @param new_value New Identity value
  *
  * @throws ORA 20044 Error updating identity
  */
  PROCEDURE change_identity_value
              (factor_name IN varchar2,
               value       IN varchar2,
               new_value   IN varchar2);

  /**
  * Remove an Identity.
  *
  * @param factor_name Factor Name
  * @param value Value associated with the identity
  *
  * @throws ORA 20044 Error deleting identity
  */
  PROCEDURE delete_identity
              (factor_name IN varchar2,
               value       IN varchar2);

  /* Identity Map */

  /*
  * Define a set of tests that are used to derive the identity of a Factor from
  * the value of linked child factors (sub-factors).
  *
  * @param identity_factor_name Factor the identity map is for
  * @param identity_factor_value Value the Factor will assume if the Identity Map is TRUE
  * @param parent_factor_name Identifies the Factor Link the Map is related to
  * @param child_factor_name Identifies the Factor Link the Map is related to
  * @param operation Relational operator for the Map (i.e. <, >, =, ...)
  * @param operand1 Left operand for the relational operator
  * @param operand1 Right operand for the relational operator
  *
  * @throws ORA 20081 Operation not found
  * @throws ORA 20060 Factor Link not found
  * @throws ORA 20062 Error creating Identity Map
  */
  PROCEDURE create_identity_map
               (identity_factor_name  IN varchar2,
                identity_factor_value IN varchar2,
                parent_factor_name    IN varchar2,
                child_factor_name     IN varchar2,
                operation             IN varchar2,
                operand1              IN varchar2,
                operand2              IN varchar2);

  /*
  * Remove an Identity Map for a Factor.
  *
  * @param identity_factor_name Factor the identity map is for
  * @param identity_factor_value Value the Factor will assume if the Identity Map is TRUE
  * @param parent_factor_name Identifies the Factor Link the Map is related to
  * @param child_factor_name Identifies the Factor Link the Map is related to
  * @param operation Relational operator for the Map (i.e. <, >, =, ...)
  * @param operand1 Left operand for the relational operator
  * @param operand1 Right operand for the relational operator
  *
  * @throws ORA 20081 Operation not found
  * @throws ORA 20063 Error deleting Identity Map
  */
  PROCEDURE delete_identity_map
               (identity_factor_name  IN varchar2,
                identity_factor_value IN varchar2,
                parent_factor_name    IN varchar2,
                child_factor_name     IN varchar2,
                operation             IN varchar2,
                operand1              IN varchar2,
                operand2              IN varchar2);

  /**Policy Label */

  /**
  * Label an Identity within a MAC OLS Policy.
  *
  * @param identity_factor_name Name of factor being labeled
  * @param identity_factor_value Value of Identity for the Factor being labeled
  * @param policy_name OLS Policy Name
  * @param label OLS Label
  *
  * @throws ORA 20220 Label already defined in policy
  * @throws ORA 20222 Error creating policy label
  */
  PROCEDURE create_policy_label
              (identity_factor_name  IN varchar2,
               identity_factor_value IN varchar2,
               policy_name           IN varchar2,
               label                 IN varchar2);
               -- algorithm             IN varchar2);

  /**
  * Remove the Label from an Identity within a MAC OLS Policy.
  *
  * @param identity_factor_name Name of factor being labeled
  * @param identity_factor_value Value of Identity for the Factor being labeled
  * @param policy_name OLS Policy Name
  * @param label OLS Label
  *
  * @throws ORA 20223 Error deleting policy label
  */
  PROCEDURE delete_policy_label
              (identity_factor_name  IN varchar2,
               identity_factor_value IN varchar2,
               policy_name           IN varchar2,
               label                 IN varchar2);
               -- algorithm             IN varchar2);

  /* MAC Policy Algorithm */

  /**
  * Specify the algorithm that is used to merge labels when computing the label for
  * a Factor, or the MAC OLS Session label.  The algorithm is a 3-letter acronym
  * (e.g. LII, HUU, ...).  Consult OLS documentation for details.
  *
  * @param policy_name OLS Policy Name
  * @param algorithm Merge algorithm
  *
  * @throws ORA 20180 MAC Policy already defined
  * @throws ORA 20182 Algorithm not found
  * @throws ORA 20381 Policy not found
  */
  PROCEDURE create_mac_policy
              (policy_name           IN varchar2,
               algorithm             IN varchar2,
               error_label           IN varchar2 DEFAULT 'NULL');

  /**
  * Specify the algorithm that is used to merge labels when computing the label for
  * a Factor, or the MAC OLS Session label.  The algorithm is a 3-letter acronym
  * (e.g. LII, HUU, ...).  Consult OLS documentation for details.
  *
  * @param policy_name OLS Policy Name
  * @param algorithm Merge algorithm
  *
  * @throws ORA 20182 Algorithm not found
  * @throws ORA 20184 Error updating MAC Policy
  * @throws ORA 20381 Policy not found
  */
  PROCEDURE update_mac_policy
              (policy_name  IN varchar2,
               algorithm             IN varchar2,
               error_label           IN varchar2 DEFAULT 'NULL');

  /**
  * Deletes all DV objects related to an OLS policy.  This method should be called
  * after an OLS policy has been deleted to ensure that there are not any broken
  * references between DV and OLS.  Note that there is not any referential integrity
  * constraints between DV and OLS.  The affected objects are in the mac_policy$,
  * mac_policy_factor$, and policy_label$ tables.
  *
  * @param policy_name OLS Policy Name
  *
  * @throws ORA 20185 Error deleting MAC Policy
  * @throws ORA 20381 Policy not found
  */
  PROCEDURE delete_mac_policy_cascade(policy_name IN varchar2);

  /* Realm */

  /**
  * Create a Realm
  *
  * @param realm_name Realm name
  * @param description Realm description
  * @param enabled Indication of whether the realm checking is on or off (g_yes/g_no)
  * @param audit_options How to audit realm (described in dbms_macutl)
  *
  * @throws ORA 20240 Realm already defined
  * @throws ORA 20242 Error creating realm
  */
  PROCEDURE create_realm
              (realm_name  IN varchar2,
               description IN varchar2,
               enabled IN varchar2,
               audit_options IN number ) ;

  /**
  * Update a Realm
  *
  * @param realm_name Realm name
  * @param description Realm description
  * @param enabled Indication of whether the realm checking is on or off (g_yes/g_no)
  * @param audit_options How to audit realm (described in dbms_macutl)
  *
  * @throws ORA 20244 Error updating realm
  */
  PROCEDURE update_realm
              (realm_name  IN varchar2,
               description IN varchar2,
               enabled IN varchar2,
               audit_options IN number default NULL) ;

  /**
  * Rename a Realm
  *
  * @param realm_name Realm name
  * @param new_name New Realm name
  *
  * @throws ORA 20245 Error renaming realm
  */
  PROCEDURE rename_realm
              (realm_name  IN varchar2,
               new_name    IN varchar2);

  /**
  * Drop a Realm
  *
  * @param realm_name Realm name
  *
  * @throws ORA 20243 Error deleting realm
  */
  PROCEDURE delete_realm
              (realm_name IN varchar2);

  /**
  * Deletes a DV realm, including the related Realm objects (realm_object$),
  * and authorizations (realm_auth$).
  *
  * @param realm_name Realm name
  *
  * @throws ORA 20241 Realm not found
  * @throws ORA 20243 Error deleting realm
  */
  PROCEDURE delete_realm_cascade
              (realm_name IN varchar2);

  
  PROCEDURE user_has_auth_in_realm
        (realm_name  IN varchar2,
         user_name   IN varchar2,
         grantee     IN Varchar2,
         id          OUT NOCOPY NUMBER,
         rsid        OUT NOCOPY NUMBER);
  /**
  * Authorize a user or role to access a realm as a participant or owner.  The
  * authorization can be made conditional based on a Rule Set (i.e. only authorized
  * if the Rule Set evaluates to TRUE).
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  * @param rule_set_name Rule Set to check before authorizing (optional)
  * @param auth_options Authorization level (participant or owner - see dbms_macutl)
  *
  * @throws ORA 20260 Realm Authorization already defined
  * @throws ORA 20262 Error adding Realm Authorization
  */
  PROCEDURE add_auth_to_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2,
               rule_set_name IN varchar2,
               auth_options  IN number);

  /**
  * Authorize a user or role to access a realm as a participant.
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  *
  * @throws ORA 20260 Realm Authorization already defined
  * @throws ORA 20262 Error adding Realm Authorization
  */
  PROCEDURE add_auth_to_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2);

  /**
  * Authorize a user or role to access a realm as an owner or participant (no Rule Set).
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  * @param auth_options Authorization level (participant or owner - see dbms_macutl)
  *
  * @throws ORA 20260 Realm Authorization already defined
  * @throws ORA 20262 Error adding Realm Authorization
  */
  PROCEDURE add_auth_to_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2,
               auth_options  IN number);

  /**
  * Authorize a user or role to access a realm as a participant (optional).
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  * @param rule_set_name Rule Set to check before authorizing (optional)
  *
  * @throws ORA 20260 Realm Authorization already defined
  * @throws ORA 20262 Error adding Realm Authorization
  */
  PROCEDURE add_auth_to_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2,
               rule_set_name IN varchar2);

  /**
  * Remove the authorization of a user or role to access a realm.
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  *
  * @throws ORA 20263 Error deleting Realm Authorization
  */
  PROCEDURE delete_auth_from_realm
              (realm_name    IN varchar2,
               grantee       IN varchar2);
               -- rule_set_name IN varchar2);

  /**
  * Update the authorization of a user or role to access a realm.
  *
  * @param realm_name Realm name
  * @param grantee User or role name
  * @param rule_set_name Rule Set to check before authorizing (optional)
  * @param auth_options Authorization level (participant or owner - see dbms_macutl)
  *
  * @throws ORA 20264 Error updating Realm Authorization
  */
  PROCEDURE update_realm_auth
              (realm_name    IN varchar2,
               grantee       IN varchar2,
               rule_set_name IN varchar2,
               auth_options  IN number);

  /**
  * Register a set of objects for Realm protection.
  *
  * @param realm_name Realm name
  * @param object_owner Object owner
  * @param object_name Object name (Wild card % is allowed)
  * @param object_type Object type (Wild card % is allowed)
  *
  * @throws ORA 20280 Object already in Realm
  * @throws ORA 20282 Error adding object to Realm
  */
  PROCEDURE add_object_to_realm
              (realm_name    IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2,
               object_type   IN varchar2);

  /**
  * Remove a set of objects from Realm protection.
  *
  * @param realm_name Realm name
  * @param object_owner Object owner
  * @param object_name Object name (Wild card % is allowed)
  * @param object_type Object type (Wild card % is allowed)
  *
  * @throws ORA 20283 Error deleting object to Realm
  */
  PROCEDURE delete_object_from_realm
              (realm_name    IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2,
               object_type   IN varchar2);

  /**
  * Enable/disable runtime DV check
  *
  * @param enable
  *
  */
  PROCEDURE enable_dv_check;
  PROCEDURE disable_dv_check;

  /**
  * Enable/disable Event
  *
  * @param enable
  *
  */
  PROCEDURE enable_event(event IN number);
  PROCEDURE disable_event(event IN number);

  /* Rule Set */

  /**
  * Create a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param description Description
  * @param enabled Whether to evaluate Rule Set or ignore it
  * @param eval_options Evaluation options (see dbms_macutl)
  * @param audit_options Audit options (see dbms_macutl)
  * @param fail_options Fail options (see dbms_macutl)
  * @param fail_message Error message for failure
  * @param fail_code Error code to return on failure
  * @param handler_options Handler options (see dbms_macutl)
  * @param handler Handler method
  *
  * @throws ORA 20340 Rule Set already defined
  * @throws ORA 20342 Error creating Rule Set
  */
  PROCEDURE create_rule_set
              (rule_set_name   IN varchar2,
               description     IN varchar2,
               enabled         IN varchar2,
               eval_options    IN number,
               audit_options   IN number,
               fail_options    IN number,
               fail_message    IN varchar2,
               fail_code       IN number,
               handler_options IN number,
               handler         IN varchar2,
               is_static       IN boolean default false);

  /**
  * Update a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param description Description
  * @param enabled Whether to evaluate Rule Set or ignore it
  * @param eval_options Evaluation options (see dbms_macutl)
  * @param audit_options Audit options (see dbms_macutl)
  * @param fail_options Fail options (see dbms_macutl)
  * @param fail_message Error message for failure
  * @param fail_code Error code to return on failure
  * @param handler_options Handler options (see dbms_macutl)
  * @param handler Handler method
  *
  * @throws ORA 20344 Error updating Rule Set
  */
  PROCEDURE update_rule_set
              (rule_set_name   IN varchar2,
               description     IN varchar2,
               enabled         IN varchar2,
               eval_options    IN number,
               audit_options   IN number,
               fail_options    IN number,
               fail_message    IN varchar2,
               fail_code       IN number,
               handler_options IN number,
               handler         IN varchar2,
               is_static       IN boolean default false);

  /**
  * Rename a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param new_name New rule set name
  *
  * @throws ORA 20344 Error updating Rule Set
  */
  PROCEDURE rename_rule_set
              (rule_set_name IN varchar2,
               new_name      IN varchar2);

  /**
  * Delete a Rule Set.
  *
  * @param rule_set_name Rule Set name
  *
  * @throws ORA 20343 Error deleting Rule Set
  */
  PROCEDURE delete_rule_set
              (rule_set_name IN varchar2);

  /**
  * Add a Rule to a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param rule_name Rule name
  * @param rule_order Order of evaluation for Rule in Rule Set
  * @param enabled Whether or not the Rule is enabled
  *
  * @throws ORA 20360 Rule already added to Rule Set
  * @throws ORA 20362 Error adding Rule to Rule Set
  */
  PROCEDURE add_rule_to_rule_set
              (rule_set_name IN varchar2,
               rule_name     IN varchar2,
               rule_order    IN number,
               enabled       IN varchar2) ;

  /**
  * Add an enabled Rule to a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param rule_name Rule name
  * @param rule_order Order of evaluation for Rule in Rule Set
  *
  * @throws ORA 20360 Rule already added to Rule Set
  * @throws ORA 20362 Error adding Rule to Rule Set
  */
  PROCEDURE add_rule_to_rule_set
              (rule_set_name IN varchar2,
               rule_name     IN varchar2,
               rule_order    IN number);

  /**
  * Add an enabled Rule to the end of Rule Set (i.e. evaluated last).
  *
  * @param rule_set_name Rule Set name
  * @param rule_name Rule name
  *
  * @throws ORA 20360 Rule already added to Rule Set
  * @throws ORA 20362 Error adding Rule to Rule Set
  */
  PROCEDURE add_rule_to_rule_set
              (rule_set_name IN varchar2,
               rule_name     IN varchar2);

  /**
  * Delete a Rule from a Rule Set.
  *
  * @param rule_set_name Rule Set name
  * @param rule_name Rule name
  *
  * @throws ORA 20363 Error deleting Rule to Rule Set
  */
  PROCEDURE delete_rule_from_rule_set
              (rule_set_name IN varchar2,
               rule_name     IN varchar2);

  /* Rule */

  /**
  * Create a Rule
  *
  * @param rule_name Rule name
  * @param rule_expr PL/SQL Boolean expression
  *
  * @throws ORA 20320 Rule already defined
  * @throws ORA 20322 Error creating Rule
  */
  PROCEDURE create_rule
              (rule_name  IN varchar2,
               rule_expr  IN varchar2);
  /**
  * Update a Rule
  *
  * @param rule_name Rule name
  * @param rule_expr PL/SQL Boolean expression
  *
  * @throws ORA 20324 Error updating Rule
  */
  PROCEDURE update_rule
              (rule_name  IN varchar2,
               rule_expr  IN varchar2);

  /**
  * Rename a Rule
  *
  * @param rule_name Rule name
  * @param new_name New Rule name
  *
  * @throws ORA 20324 Error updating Rule
  */
  PROCEDURE rename_rule
              (rule_name  IN varchar2,
               new_name  IN varchar2);

  /**
  * Delete a Rule
  *
  * @param rule_name Rule name
  *
  * @throws ORA 20323 Error deleting Rule
  */
  PROCEDURE delete_rule
              (rule_name  IN varchar2);


  /* Role */

  /**
  * Create a DV Secure Application Role.  Access to the role is protected
  * by a Rule Set.
  *
  * @param role_name Role name
  * @param enabled Whether the role is enabled or diabled
  * @param rule_set_name Rule Set to determine whether a user can set the role
  *
  * @throws ORA 20300 Role already defined
  * @throws ORA 20302 Error creating role
  *
  */
  PROCEDURE create_role
              (role_name IN varchar2,
               enabled   IN varchar2,
               rule_set_name IN varchar2);

  /**
  * Delete a DV Secure Application Role.
  *
  * @param role_name Role name
  *
  * @throws ORA 20303 Error deleting role
  *
  */
  PROCEDURE delete_role
              (role_name IN varchar2);

  /**
  * Update a DV Secure Application Role.  Access to the role is protected
  * by a Rule Set.
  *
  * @param role_name Role name
  * @param enabled Whether the role is enabled or diabled
  * @param rule_set_name Rule Set to determine whether a user can set the role
  *
  * @throws ORA 20304 Error updating role
  *
  */
  PROCEDURE update_role
              (role_name IN varchar2,
               enabled   IN varchar2,
               rule_set_name IN varchar2);

  /**
  * Rename a DV Secure Application Role.
  *
  * @param role_name Role name
  * @param new_role_name Role name
  *
  * @throws ORA 20304 Error updating role
  *
  */
  PROCEDURE rename_role
              (role_name IN varchar2,
               new_role_name  IN varchar2);

  /* Command Rule */

  /**
  * Protect a database command by associating it with a Rule Set.  The
  * command can only be executed if the Rule Set evaluates to TRUE.
  *
  * @param command SQL command to protect
  * @param rule_set_name Rule Set to protect command
  * @param object_owner Related database object schema
  * @param object_name Related database object name
  * @param enabled Whether the command rule is enabled or disabled
  *
  * @throws ORA 20081 Command not found
  * @throws ORA 20100 Command rule already defined
  * @throws ORA 20102 Error creating Command Rule
  */
  PROCEDURE create_command_rule
              (command IN varchar2,
               rule_set_name IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2,
               enabled       IN varchar2,
               privilege_scope IN NUMBER DEFAULT NULL);

  /**
  * Drop a Command Rule declaration.
  *
  * @param command SQL command to protect
  * @param object_owner Related database object schema
  * @param object_name Related database object name
  *
  * @throws ORA 20081 Command not found
  * @throws ORA 20103 Error deleting Command Rule
  */
  PROCEDURE delete_command_rule
              (command IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2);

  /**
  * Update a Command Rule declaration.
  *
  * @param command SQL command to protect
  * @param rule_set_name Rule Set to protect command
  * @param object_owner Related database object schema
  * @param object_name Related database object name
  * @param enabled Whether the command rule is enabled or disabled
  *
  * @throws ORA 20081 Command not found
  * @throws ORA 20104 Error updating Command Rule
  */
  PROCEDURE update_command_rule
              (command IN varchar2,
               rule_set_name IN varchar2,
               object_owner  IN varchar2,
               object_name   IN varchar2,
               enabled       IN varchar2,
               privilege_scope IN NUMBER DEFAULT NULL);

  /**
  * Returns information from the sys.v_$instance view.
  *
  *  @param p_parameter Column name in sys.v_$instance
  *  @return Value of column p_parameter in sys.v_$instance
  */
  FUNCTION get_instance_info(p_parameter IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Returns information from the sys.v_$session view for the current session
  *
  *  @param p_parameter Column name in sys.v_$session
  *  @return Value of column p_parameter in sys.v_$session
  */
  FUNCTION get_session_info(p_parameter IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Add a RAC database node to a domain. If the identity for the domain does
  * not exist the identity will be added.
  * Creates the required identity map information for the database hostname provided.
  * If the OLS policy is provided, domain will be added as a policy factor
  * if it is not already associated. If the label for the identity of this domain
  * does not exist the label will be added.
  * This call must be made with the instance running on the host specified.
  *
  * @param domain_name Name of the domain to add the host to
  * @param domain_host RAC host name being added to the domain
  * @param policy_name OLS Policy Name to label the domain for
  * @param label OLS Label to label the domain within this policy
  *
  * @throws ORA 20921 Error adding host to domain
  */

  PROCEDURE create_domain_identity
              (domain_name IN varchar2,
               domain_host IN varchar2,
               policy_name IN varchar2 DEFAULT NULL,
               domain_label IN varchar2 DEFAULT NULL
               );

  /**
  * Remove a RAC database node from a domain.
  * Creates the required identity map information for the database hostname provided.
  *
  * @param domain_name Name of the domain to add the host to
  * @param domain_host RAC host name being added to the domain
  *
  * @throws ORA 20922 Error removing host to domain
  */
  PROCEDURE drop_domain_identity
              (domain_name IN varchar2,
               domain_host IN varchar2);

  /**
  * Returns the character set for the database
  *
  * @return character set for the database
  */
  FUNCTION get_db_charset RETURN VARCHAR2;

  /**
  * Returns the 3 character Oracle language for the current administration session
  * Based on set_ora_lang_from_java
  *
  * @return 3 character oracle language identifier for the administration current session
  */
  FUNCTION get_ora_lang RETURN VARCHAR2;

  /**
  * Sets the 3 character Oracle language for the current session
  * based on the Java language parameter passed in, converting as required
  *
  * @param p_lang Java language to set
  */
  PROCEDURE set_ora_lang_from_java(p_lang IN VARCHAR2);


  /**
  * Synchronize the rules in DV and AQ Rules engine -
  * Need to perform this operation immediately after a ROLLBACK of
  * some add/delete/modify rule operations.
  */
  PROCEDURE sync_rules;

  /**
  * check to see if alter system set system_trig_enabled
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_trig_parm_varchar RETURN VARCHAR2;
 
  /**
  * check to see if following O7_DICTIONARY_ACCESSIBILITY 
  * is allowed: 
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_o7_parm_varchar RETURN VARCHAR2;

  /**
  * check to see if alter system set _dynamic_rls_policies
  * are allowed 
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_dynrls_parm_varchar RETURN VARCHAR2;

  /**
  * check to see if following ALTER SYSTEM security system parameters
  * are allowed :
  *    _SYSTEM_TRIG_ENABLED POLICIES
  *    O7_DICTIONARY_ACCESSIBILITY 
  *    _DYNAMIC_RLS_POLICIES 
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_sys_sec_parm_varchar RETURN VARCHAR2;

  /**
  * check to see if following ALTER SYSTEM dump or dest parameters
  * are allowed :
  *    MAX_DUMP_FILE_SIZE
  *    %DUMP%
  *    %_DEST%
  *    LOG_ARCHIVE%
  *    STANDBY_ARCHIVE%
  *    DB_RECOVERY_FILE_DEST_SIZE
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_dump_dest_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM backup restore parameters
  * are allowed :
  *    RECYCLEBIN
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_backup_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM database file parameters
  * are allowed :
  *    CONTROL_FILES
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_db_file_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM optimizer parameters
  * are allowed :
  *    OPTIMIZER_SECURE_VIEW_MERGING
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_optimizer_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM plsql parameters
  * are allowed :
  *    UTL_FILE_DIR
  *    PLSQL_DEBUG
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_plsql_parm_varchar RETURN VARCHAR2;
  
  /**
  * check to see if following ALTER SYSTEM security parameters
  * are allowed :
  *    AUDIT_SYS_OPERATIONS
  *    AUDIT_TRAIL
  *    AUDIT_SYSLOG_LEVEL
  *    REMOTE_OS_ROLES
  *    OS_ROLES
  *    SQL92_SECURITY
  *
  * return 'Y' or 'N'
  */
  FUNCTION check_security_parm_varchar RETURN VARCHAR2;

  /**
  * check to see if alter dvsys
  *
  * return 'Y' or 'N'
  */
  FUNCTION is_alter_user_allow_varchar(login_user VARCHAR2) RETURN VARCHAR2;

  FUNCTION is_drop_user_allow_varchar(login_user VARCHAR2) RETURN VARCHAR2;

  PROCEDURE authorize_datapump_user(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT NULL,
       objname     IN VARCHAR2 DEFAULT NULL,
       rulename    IN VARCHAR2 DEFAULT NULL
   );

  PROCEDURE unauthorize_datapump_user(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT NULL,
       objname     IN VARCHAR2 DEFAULT NULL,
       rulename    IN VARCHAR2 DEFAULT NULL
  );
   
  /* API to authorize a user to run jobs in the schema of other users. */
  PROCEDURE authorize_scheduler_user(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT NULL
   );

  PROCEDURE unauthorize_scheduler_user(
       uname       IN VARCHAR2,
       sname       IN VARCHAR2 DEFAULT NULL
   );

  /* BUG FIX 10225918 - Procedure to insert DV metadata in supported languages. 
   Supported input Language values are :
   ENGLISH
   GERMAN
   SPANISH
   FRENCH
   ITALIAN
   JAPANESE
   KOREAN
   BRAZILIAN PORTUGUESE
   SIMPLIFIED CHINESE
   TRADITIONAL CHINESE
  */
  PROCEDURE add_nls_data(
       lang        IN VARCHAR2 
   );

  -- Control ORADEBUG in Database Vault environment
  PROCEDURE enable_oradebug;
  PROCEDURE disable_oradebug;
END;
/

SHOW ERRORS;
Rem
Rem
Rem    DESCRIPTION
Rem      Package specification for Data Vault Audit APIs
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macaud AS

  /*********************/
  /*  Global Constants */
  /*********************/

  -- Action code for audit_event method
  G_FACTOR_EVALUATION_AUDIT_CODE         CONSTANT VARCHAR2(6) := '10000' ;
  -- Action code for audit_event method
  G_FACTOR_ASSIGNMENT_AUDIT_CODE         CONSTANT VARCHAR2(6) := '10001' ;
  -- Action code for audit_event method
  G_FACTOR_EXPRESSION_AUDIT_CODE         CONSTANT VARCHAR2(6) := '10002' ;
  -- Action code for audit_event method
  G_REALM_VIOLATION_AUDIT_CODE           CONSTANT VARCHAR2(6) := '10003' ;
  -- Action code for audit_event method
  G_REALM_AUTH_AUDIT_CODE                CONSTANT VARCHAR2(6) := '10004' ;
  -- Action code for audit_event method
  G_COMMAND_AUTH_AUDIT_CODE              CONSTANT VARCHAR2(6) := '10005' ;
  -- Action code for audit_event method
  G_SECURE_ROLE_AUDIT_CODE               CONSTANT VARCHAR2(6) := '10006' ;
  -- Action code for audit_event method
  G_MAC_SEC_INIT_AUDIT_CODE              CONSTANT VARCHAR2(6) := '10007' ;
  -- Action code for audit_event method
  G_MAC_SEC_CMD_AUDIT_CODE               CONSTANT VARCHAR2(6) := '10008' ;
  -- Action code for audit_event method
  G_MAC_OLS_INIT_AUDIT_CODE              CONSTANT VARCHAR2(6) := '10009' ;
  -- Action code for audit_event method
  G_MAC_OLS_UPGRADE_AUDIT_CODE           CONSTANT VARCHAR2(6) := '10010' ;

  /**
  * Audit MACSEC Initialization events.  Calls the audit_event method below.
  * @param p_username Name of the user being audited
  * @param p_action_object_name Name of object being audited
  * @param p_action_command Command that caused the audit event (e.g. SQL text)
  * @param p_return_code Oracle error number
  * @param p_audit_option Audit options that caused the event to be audited
  * @param p_rule_set_name Rule set that caused the audit event
  * @param p_rule_name Rule within the Rule Set
  * @param p_factor_context Values of the DV factors
  * @param p_comment Extra information for the audit log
  * @param p_statement_id Database statement id
  * @param p_proxy_session_id Proxy Session Id
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_macsec_init(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );

  /**
  * Audit events during MACOLS initialization.  See audit_macsec_init for
  * parameter descriptions.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_macols_init(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );

  -- mac ols upgrade
  /**
  * Audit events inside MACOLS wrapper.  See audit_macsec_init for
  * parameter descriptions.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_macols_upgrade(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );

  /**
  * Audit events during MACSEC Secure Application Role processing.
  * See audit_macsec_init for parameter descriptions.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_secure_role(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );

  /**
  * Audit events during MACOLS initialization.  See audit_macsec_init for
  * parameter descriptions.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_command_authorization(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );

  /**
  * Audit events during MACSEC Realm authorization.  See audit_macsec_init for
  * parameter descriptions.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_realm_authorization(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );

  /**
  * Audit call for Realm violations.  See audit_macsec_init for
  * parameter descriptions.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_realm_violation(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );

  /**
  * Audit events for future factor expression processing.  See audit_macsec_init for
  * parameter descriptions.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_factor_expression(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );


  /**
  * Audit events when setting a factor.  See audit_macsec_init for
  * parameter descriptions.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_factor_assignment(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );

  /**
  * Audit events when evaluating a factor.  See audit_macsec_init for
  * parameter descriptions.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_factor_evaluation(
     p_username VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER  := 0
   , p_proxy_session_id NUMBER  := 0
  );

  /**
  * Audit events during MACOLS initialization.  See audit_macsec_init for
  * parameter descriptions.  This is the general audit method that is called by
  * all of the others.
  */
  -- Bug 5926711: add a new parameter, p_username.
  PROCEDURE audit_event(
     p_action_code VARCHAR2
   , p_username VARCHAR2
   , p_object_owner VARCHAR2
   , p_object_name VARCHAR2
   , p_action_object_id VARCHAR2
   , p_action_object_name VARCHAR2
   , p_action_command VARCHAR2
   , p_return_code NUMBER
   , p_audit_option VARCHAR2
   , p_rule_set_name VARCHAR2
   , p_rule_name VARCHAR2
   , p_factor_context VARCHAR2
   , p_comment VARCHAR2
   , p_statement_id NUMBER := 0
   , p_proxy_session_id NUMBER := 0
  );

END;
/

SHOW ERRORS;
Rem
Rem
Rem    DESCRIPTION
Rem      MACSEC APIs for authorizing database events
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macsec_events AS

  is_drop_object_maint    BOOLEAN := false;

  /**
  * Place holder for any DV role-based checks.  Currently, there are none.
  *
  * See authorize_event above for parameter definitions.
  *
  * @returns TRUE if the operation is allowed.
  */
  FUNCTION is_authorized_by_role(
              p_event           IN VARCHAR2,
              p_user            IN VARCHAR2,
              p_instance_number IN NUMBER,
              p_database_name   IN VARCHAR2,
              p_object_type     IN VARCHAR2,
              p_object_owner    IN VARCHAR2,
              p_object_name     IN VARCHAR2,
              p_is_nested_table IN BOOLEAN,
              p_sql_text        IN ora_name_list_t,
              p_grantee         IN ora_name_list_t,
              p_revokee         IN ora_name_list_t,
              p_grant_option    IN BOOLEAN,
              p_privileges      IN ora_name_list_t) RETURN BOOLEAN;

  /**
  * Performs the DV Realm checking.  Consult the documentation for details.
  * Highlights:
  * - Supports DDL operations, including GRANT and REVOKE
  * - CREATE, ALTER, DROP, ...
  *   - If the object is in a realm, only allows the operation if performed
  *       by the realm owner
  * - GRANT and REVOKE
  *   - Only realm owner is allowed to grant/revoke permissions to an object
  *       in a realm
  *   - Only realm owner is allow to grant/revoke a role in a realm
  * - Realm violations are audited
  *
  * See authorize_event above for parameter definitions.
  *
  * @returns TRUE if the operation is allowed.
  */
  FUNCTION is_authorized_by_realm(
              p_event           IN VARCHAR2,
              p_user            IN VARCHAR2,
              p_instance_number IN NUMBER,
              p_database_name   IN VARCHAR2,
              p_object_type     IN VARCHAR2,
              p_object_owner    IN VARCHAR2,
              p_object_name     IN VARCHAR2,
              p_is_nested_table IN BOOLEAN,
              p_sql_text        IN ora_name_list_t,
              p_sql_text_str    IN VARCHAR2,
              p_grantee         IN ora_name_list_t,
              p_revokee         IN ora_name_list_t,
              p_grant_option    IN BOOLEAN,
              p_privileges      IN ora_name_list_t) RETURN BOOLEAN;

  /**
  * Convenience function for use by SELECT/DML VPD policies.  Same as the above
  * is_authorized_by_realm, but passed default values for the other parameters.
  *
  * See authorize_event above for parameter definitions.
  *
  * @returns TRUE if the operation is allowed.
  */
  FUNCTION is_authorized_by_realm(
              p_event           IN VARCHAR2,
              p_user            IN VARCHAR2,
              p_object_owner    IN VARCHAR2,
              p_object_name     IN VARCHAR2) RETURN BOOLEAN;

  /**
  * Convenience function for use by SELECT/DML VPD policies.  Same as the above
  * is_authorized_by_realm, but passed default values for the other parameters.
  * Used to determine if the user can administer RLS privileges on the object
  *
  * See authorize_event above for parameter definitions.
  *
  * @returns > 0 if the operation is allowed, <= 0 if not
  */
  FUNCTION is_rls_authorized_by_realm(
              p_user            IN VARCHAR2,
              p_object_owner    IN VARCHAR2,
              p_object_name     IN VARCHAR2) RETURN NUMBER;

  /**
  * Performs Command Rule checking for the specified event.  If necessary,
  * combines the p_event and p_object_type parameters to derive the command.
  * For example, if p_event = 'ALTER' and p_object_type = 'TABLE', then
  * the command 'ALTER TABLE' is looked up in the command_rule$ table.
  *
  * See authorize_event above for parameter definitions.
  *
  * @returns TRUE if the command rule is true, or there is no command rule, FALSE only if the command rule is FALSE
  */
  FUNCTION is_authorized_by_rule(
              p_event           IN VARCHAR2,
              p_user            IN VARCHAR2,
              p_instance_number IN NUMBER,
              p_database_name   IN VARCHAR2,
              p_object_type     IN VARCHAR2,
              p_object_owner    IN VARCHAR2,
              p_object_name     IN VARCHAR2,
              p_is_nested_table IN BOOLEAN,
              p_sql_text        IN ora_name_list_t,
              p_sql_text_str    IN VARCHAR2,
              p_grantee         IN ora_name_list_t,
              p_revokee         IN ora_name_list_t,
              p_grant_option    IN BOOLEAN,
              p_privileges      IN ora_name_list_t) RETURN BOOLEAN;

  /**
   * Since ddls processing are moved into C, KZVDV_DROP_MAINT will be used 
   * to indicate is_drop_object_maint.
   */
  FUNCTION check_is_drop_object_maint RETURN BOOLEAN;

END;
/
show errors;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACSEC APIs for evaluating rules
Rem
Rem
Rem
Rem
Rem

/**
 * Package for capturing transient event data
 */
-- Fix for Bug 6068504: The procedures below are used to load the session
-- information to SYS_CONTEXT. The load information can be retrieved from
-- SYS_CONTEXT through designated procedures (e.g., dvsys.DV_SYSEVENT) 
-- during rule evaluation.
CREATE OR REPLACE PACKAGE dvsys.event IS

 PROCEDURE set_c (P_SYSEVENT        VARCHAR2,
                  P_LOGIN_USER      VARCHAR2,
                  P_INSTANCE_NUM    VARCHAR2,
                  P_DATABASE_NAME   VARCHAR2,
                  P_DICT_OBJ_TYPE   VARCHAR2,
                  P_DICT_OBJ_OWNER  VARCHAR2,
                  P_DICT_OBJ_NAME   VARCHAR2,
                  P_SQL_TEXT        VARCHAR2);

 PROCEDURE set (P_SYSEVENT        VARCHAR2,
                P_LOGIN_USER      VARCHAR2,
                P_INSTANCE_NUM    NUMBER,
                P_DATABASE_NAME   VARCHAR2,
                P_DICT_OBJ_TYPE   VARCHAR2,
                P_DICT_OBJ_OWNER  VARCHAR2,
                P_DICT_OBJ_NAME   VARCHAR2,
                P_SQL_TEXT        VARCHAR2);

 PROCEDURE setdefault;

END event;
/

CREATE OR REPLACE PACKAGE BODY dvsys.event AS

 PROCEDURE set_c (P_SYSEVENT        VARCHAR2,
                  P_LOGIN_USER      VARCHAR2,
                  P_INSTANCE_NUM    VARCHAR2,
                  P_DATABASE_NAME   VARCHAR2,
                  P_DICT_OBJ_TYPE   VARCHAR2,
                  P_DICT_OBJ_OWNER  VARCHAR2,
                  P_DICT_OBJ_NAME   VARCHAR2,
                  P_SQL_TEXT        VARCHAR2) 
 IS LANGUAGE C
   NAME "kzvdvssetup"
   LIBRARY DVSYS.KZV$RUL_LIBT
   WITH CONTEXT
   PARAMETERS (CONTEXT, 
               P_SYSEVENT, P_SYSEVENT INDICATOR, 
               P_LOGIN_USER, P_LOGIN_USER INDICATOR, 
               P_INSTANCE_NUM, P_INSTANCE_NUM INDICATOR, 
               P_DATABASE_NAME, P_DATABASE_NAME INDICATOR, 
               P_DICT_OBJ_TYPE, P_DICT_OBJ_TYPE INDICATOR, 
               P_DICT_OBJ_OWNER, P_DICT_OBJ_OWNER INDICATOR,
               P_DICT_OBJ_NAME, P_DICT_OBJ_NAME INDICATOR, 
               P_SQL_TEXT, P_SQL_TEXT INDICATOR);

 PROCEDURE set (P_SYSEVENT        VARCHAR2,
                P_LOGIN_USER      VARCHAR2,
                P_INSTANCE_NUM    NUMBER,
                P_DATABASE_NAME   VARCHAR2,
                P_DICT_OBJ_TYPE   VARCHAR2,
                P_DICT_OBJ_OWNER  VARCHAR2,
                P_DICT_OBJ_NAME   VARCHAR2,
                P_SQL_TEXT        VARCHAR2) AS
   l_loginuser VARCHAR2(100);
   l_instancenum VARCHAR2(100);
   l_sqltext VARCHAR2(4000);
 BEGIN
   IF (P_LOGIN_USER IS NULL) OR (LENGTH(P_LOGIN_USER) = 0) THEN
      l_loginuser := SYS_CONTEXT ( 'USERENV','SESSION_USER' );
   ELSE 
      l_loginuser := P_LOGIN_USER;
   END IF;

   l_instancenum := TO_CHAR(P_INSTANCE_NUM);

   IF (P_SQL_TEXT IS NOT NULL) THEN
      l_sqltext := SUBSTRB(UPPER(P_SQL_TEXT), 1, 4000);
   ELSE 
      l_sqltext := '';
   END IF;

   dvsys.event.set_c(P_SYSEVENT, l_loginuser, l_instancenum, P_DATABASE_NAME, 
                     P_DICT_OBJ_TYPE, P_DICT_OBJ_OWNER, P_DICT_OBJ_NAME, l_sqltext);
 END;

 PROCEDURE setdefault AS
 BEGIN
   dvsys.event.set(ORA_SYSEVENT, ORA_LOGIN_USER, ORA_INSTANCE_NUM, ORA_DATABASE_NAME,
                   ORA_DICT_OBJ_TYPE, ORA_DICT_OBJ_OWNER, ORA_DICT_OBJ_NAME, '');
 END; 
END event;
/

/*
 * Utility functions to return event data for rule evaluation
 */
create or replace function dvsys.DV_SYSEVENT return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'SYSEVENT');
end;
/

create or replace function dvsys.DV_LOGIN_USER return VARCHAR2 as
begin
   -- Fix for Bug 6068504
   return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'LOGIN_USER');
end;
/

create or replace function dvsys.DV_INSTANCE_NUM return NUMBER as
begin  
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'INSTANCE_NUM');
end;
/

create or replace function dvsys.DV_DATABASE_NAME return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'DATABASE_NAME');
end;
/

create or replace function dvsys.DV_DICT_OBJ_TYPE return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'DICT_OBJ_TYPE');
end;
/

create or replace function dvsys.DV_DICT_OBJ_OWNER return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'DICT_OBJ_OWNER');
end;
/

create or replace function dvsys.DV_DICT_OBJ_NAME return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'DICT_OBJ_NAME');
end;
/

create or replace function dvsys.DV_SQL_TEXT return VARCHAR2 as
begin
  -- Fix for Bug 6068504
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'SQL_TEXT');
end;
/

create or replace function dvsys.DV_JOB_INVOKER return VARCHAR2 as
begin  
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'JOB_INVOKER');
end;
/

create or replace function dvsys.DV_JOB_OWNER return VARCHAR2 as
begin
  return SYS_CONTEXT('DV_EVENT_SESSION_STATE', 'JOB_OWNER');
end;
/

CREATE OR REPLACE PACKAGE DVSYS.dbms_macsec_rules AS

  /**
  * Evaluates a Rule Set in accordance with the options specified in the
  * rule_set$ table.
  * @param p_rule_set Rule Set Name
  * @param x_result Whether Rule Set evaluated to TRUE or FALSE.  Note: NULL result returns as FALSE
  * @param x_rule Name of last Rule evaluated
  * @param x_rule_error True if a rule raised an error
  * @param x_handler_error True if the rule set handler raised an error
  * @param x_error_code If x_rule_error or x_handler_error, returns the error code
  * @param x_error_text If x_rule_error or x_handler_error, returns the error code
  */
  PROCEDURE evaluate(p_rule_set      IN  VARCHAR2,
                     p_sql_text      IN  VARCHAR2,
                     x_result        OUT BOOLEAN,
                     x_rule          OUT VARCHAR2,
                     x_rule_error    OUT BOOLEAN,
                     x_handler_error OUT BOOLEAN,
                     x_error_code    OUT NUMBER,
                     x_error_text    OUT VARCHAR2);

  PROCEDURE evaluate_tr(p_rule_set    IN NUMBER,
                        p_eval_ret    IN OUT BINARY_INTEGER,
                        p_error_code  IN OUT BINARY_INTEGER,
                        p_error_text  IN OUT VARCHAR2) as
    LANGUAGE C
    NAME "kzvdversetev"
    LIBRARY DVSYS.KZV$RUL_LIBT
    WITH CONTEXT PARAMETERS(context, p_rule_set OCINUMBER, p_eval_ret,
                            p_error_code, p_error_text);


  /**
  * This is a temporary wrapper for evaluate.  OCI cannot pass BOOLEAN
  * variables to or from PL/SQL.  Therefore, we need a wrapper that
  * converts booleans to integers.
  */
  PROCEDURE evaluate_wr(p_rule_set      IN  VARCHAR2,
                         x_result        OUT INTEGER,
                         x_rule          OUT VARCHAR2,
                         x_rule_error    OUT INTEGER,
                         x_handler_error OUT INTEGER,
                         x_error_code    OUT NUMBER,
                         x_error_text    OUT VARCHAR2);
END;
/

show errors;


CREATE OR REPLACE PROCEDURE dvsys.evaluate_rule_set(
                        p_rule_set      IN  VARCHAR2,
                        x_result        OUT INTEGER,
                        x_rule          OUT VARCHAR2,
                        x_rule_error    OUT INTEGER,
                        x_handler_error OUT INTEGER,
                        x_error_code    OUT NUMBER,
                        x_error_text    OUT VARCHAR2)
  IS
    x_result_bool        BOOLEAN;
    x_rule_error_bool    BOOLEAN;
    x_handler_error_bool BOOLEAN;
  BEGIN
    -- buffer overflow checks
    IF (LENGTH(p_rule_set) > 90) THEN
        DBMS_MACUTL.RAISE_ERROR(47951,'p_rule_set');
    END IF;

    DVSYS.DBMS_MACSEC_RULES.EVALUATE(
             p_rule_set,
             NULL,
             x_result_bool,
             x_rule,
             x_rule_error_bool,
             x_handler_error_bool,
             x_error_code,
             x_error_text);

    IF (x_result_bool) THEN
      x_result := 1;
    ELSE
      x_result := 0;
    END IF;

    IF (x_rule_error_bool) THEN
      x_rule_error := 1;
    ELSE
      x_rule_error := 0;
    END IF;

    IF (x_handler_error_bool) THEN
      x_handler_error := 1;
    ELSE
      x_handler_error := 0;
    END IF;
  END;
/

show errors;


Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACSEC APIs
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macsec AS

  /**
  * Set value of a Factor (if allowed by the assignment Rule Set)
  *
  * @param p_factor Factor name
  * @param p_value Value to assign to Factor
  * @throws ORA 20391 If the assignment Rule Set is FALSE
  * @throws ORA 20392 If the Factor does not have an assignment Rule Set
  */
  PROCEDURE set_factor(p_factor IN VARCHAR2,
                       p_value  IN VARCHAR2);

  /**
  * Returns the value of a factor.  Note that this method will return the
  * value cached in the context if the eval_option is set for evaluate on
  * session.
  *
  * @param p_factor Factor name
  * @throws ORA 20021 Factor not found
  * @throws ORA 20402 Bad eval_options
  * @throws ORA 20397 Bad identified_by
  */
  FUNCTION get_factor(p_factor IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Returns the label of a factor.
  *
  * @param p_factor Factor name
  * @param p_policy_name OLS Policy name
  * @throws ORA 20021 Factor not found
  * @throws ORA 20402 Bad eval_options
  * @throws ORA 20397 Bad identified_by
  */
  FUNCTION get_factor_label(p_factor IN VARCHAR2, p_policy_name IN VARCHAR2) RETURN VARCHAR2;

  /**
  * Get Trust Level of a Factor
  *
  * @param p_factor Factor name
  * @return > 0 indicates level of trust, 0 is no trust, < 0 indicates distrust
  */
  FUNCTION get_trust_level(p_factor IN VARCHAR2) RETURN NUMBER;

  /**
  * Get Trust Level of a Factor Identity
  *
  * @param p_factor Factor name
  * @param p_identity Identity value
  * @return > 0 indicates level of trust, 0 is no trust, < 0 indicates distrust
  */
  FUNCTION get_trust_level(p_factor   IN VARCHAR2,
                           p_identity IN VARCHAR2) RETURN NUMBER;

  /**
  * This method determines if a Secure Application Role is enabled
  * for use.
  * @param p_role Role name
  * @return TRUE if a SET ROLE command can be issued
  */
  FUNCTION role_is_enabled(p_role IN VARCHAR2) RETURN BOOLEAN;

  /** Fix for Bug 6441524
  * Checks whether or not the given role is a secure application role
  *
  * @param role name
  * @return TRUE if the role is a secure application role; FALSE otherwise
  */
  FUNCTION is_secure_application_role(p_role VARCHAR2) RETURN BOOLEAN;  

END;
/
show errors;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACOLS APIs
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macols AS

  /**
  * Initializes MACOLS and sets the user's session label.  This method should
  * be called during the Login trigger processing, after MACSEC init_session
  * has completed.  This method should only be called if OLS is installed -
  * see dbms_macutl.is_ols_installed.  At a high level, the processing performs
  * the following:
  *
  * for each OLS policy + merge algorithm
  *    determine the user's OLS label for the session;
  *    for each labeled factor loop
  *       compute the label of the factor based on the policy algorithm;
  *    end loop;
  *    merge the factor labels together using the policy algorithm to compute
  *      the maximum possible label for the user's session (MACOLS label);
  *    if the user's OLS label dominates the MAXOLS label then
  *      merge the labels using the algorithm to compute the user's new session label;
  *    end if;
  *  cache the factor labels, MACOLS label, and session labels in the user's context
  *   set the user's session label for the policy;
  * end loop;
  */
  PROCEDURE init_session;

  -- Methods below are exposed temporarily for debugging
  /**
  * Determines the lowest sensitivity level for a policy.
  *
  * @param p_mac_policy_id Id of policy from mac_policy$ table
  * @return Label of lowest sensitivity
  */
  FUNCTION min_policy_label_of(p_mac_policy_id IN NUMBER) RETURN VARCHAR2;

  /**
  * Computes the label of a factor for the specified policy
  *
  * @param p_mac_policy_id Id of policy from mac_policy$ table
  * @return Label of factor
  */
  FUNCTION label_of(p_mac_policy_id IN NUMBER,
                    p_factor_id     IN NUMBER) RETURN VARCHAR2;

  /**
  * Create the contexts used to cache MACOLS labels.  One context is
  * created to cache the labels for each Factor, and another is
  * create to cache session related label values (see dbms_macutl).
  *
  * @param p_policy_name OLS Policy Name
  *
  */
  PROCEDURE create_macols_contexts(p_policy_name IN VARCHAR2);

  /**
  * Drop the contexts used to cache MACOLS labels.
  *
  * @param p_policy_name OLS Policy Name
  *
  */
  PROCEDURE drop_macols_contexts(p_policy_name IN VARCHAR2);

  /**
  /**
  * Sets a value in a MACOLS context
  *
  * @param p_policy_name OLS Policy Name
  * @param p_context_type Context name (see dbms_macutl for helpful constants)
  * @param p_label Label value
  */
  PROCEDURE update_policy_label_context(p_policy_name  IN VARCHAR2,
                                        p_context_type IN VARCHAR2,
                                        p_label        IN VARCHAR2);

END;
/
show errors;
Rem
Rem
Rem    DESCRIPTION
Rem      MACSEC Secure Application Role Manager
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macsec_roles AUTHID CURRENT_USER AS

  /**
  * Checks whether the user invoking the method is authorized to use
  * the specified DV Secure Application Role.  The authorization is
  * determined by checking the Rule Set associted with the role.
  *
  * @param p_role Secure Application Role name
  * @return TRUE if user is allowed to set the role
  */
  FUNCTION can_set_role(p_role IN VARCHAR2) RETURN BOOLEAN ;

  /**
  * Issues the SET ROLE command for a DV Secure Application Role.  Before
  * the SET ROLE is issued, the can_set_role method is called to check
  * the Rule Set associated with the role.
  *
  * @param p_role Secure Application Role name
  * @throws Exception if user is not authorized
  */
  PROCEDURE set_role(p_role IN VARCHAR2);

END;
/
show errors;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACSEC Secure Application Role Convenience Admin Functions
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macsec_role_admin AS

  /**
  * Creates a DV Secure Application Role, which controls the ability for users to
  * access the role based on a Rule Set.  Essentially, the following command is
  * issued:
  *
  * CREATE ROLE <role name> IDENTIFIED USING dvsys.dbms_macsec_roles;
  *
  * @param p_role Name of role to create
  */
  PROCEDURE create_role(p_role IN VARCHAR2);

  /**
  * Drops a DV Secure Application Role
  *
  * @param p_role Name of role to drop
  */
  PROCEDURE drop_role(p_role IN VARCHAR2);

END;
/
show errors;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MACOLS APIs for integrating into the LBACSYS.SA_SESSION package
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macols_session AS

    /**
    * Is OLS policy is protected by MAC OLS under DV
    *
    * @param policy_name OLS Policy Name
    */
    FUNCTION is_mac_policy(policy_name VARCHAR2) RETURN NUMBER;

    /**
    * Can the label be set under MAC OLS for this policy beyond max session label
    *
    * @param policy_name OLS Policy Name
    * @param label OLS Label for the policy
    */
    FUNCTION can_set_label(policy_name VARCHAR2,label VARCHAR2) RETURN NUMBER;

    /**
    * Set the MAC OLS session context variable for the attribute specified
    *
    * @param policy_name OLS Policy Name
    * @param label OLS Label for the policy
    * @param attribute session context attribute
    */
    PROCEDURE set_policy_label_context(policy_name VARCHAR2,label VARCHAR2,attribute VARCHAR2);

    /**
    * Audit invalid attempt to set the label for this policy
    * beyond max session label and raise the appropriate exception
    *
    * @param policy_name OLS Policy Name
    * @param label OLS Label for the policy
    */
    PROCEDURE set_label_audit_raise(policy_name VARCHAR2 ,label VARCHAR2) ;

    /**
    * MAC OLS processing to merge default session label for the policy
    * with the labels of any factors associated to the policy after the
    * SA_SESSION restore_default_labels method is called
    *
    * @param policy_name OLS Policy Name
    * @param x_session_label resulting session label after the merge
    * @param x_mac_label resulting MAX session label after the merge
    */
    PROCEDURE restore_default_labels(policy_name IN VARCHAR2
           , x_session_label OUT VARCHAR2
           , x_mac_label OUT VARCHAR2) ;

    /**
    * MAC OLS processing to merge default session label for the policy
    * with the exist MAX session label after the
    * SA_SESSION set_access_profile method is called
    *
    * @param policy_name OLS Policy Name
    * @param user_name OLS Policy User Name
    * @param p_max_session_label existing MAX session label for the policy
    * @param x_new_max_session_label new MAX session label for the policy
    */
    FUNCTION set_access_profile(policy_name VARCHAR2 ,
            user_name VARCHAR2,
            p_max_session_label IN VARCHAR2,
            x_new_session_label OUT VARCHAR2) RETURN NUMBER ;

END;
/
show errors;



Rem
Rem
Rem
Rem    DESCRIPTION
Rem      MAC APIs for VPD policy that enforces realms
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PACKAGE DVSYS.dbms_macvpd AS

  g_scope_add_realm    CONSTANT NUMBER(1) := 1;
  g_scope_delete_realm CONSTANT NUMBER(1) := 2;
  g_scope_add_rule     CONSTANT NUMBER(1) := 3;
  g_scope_delete_rule  CONSTANT NUMBER(1) := 4;
  g_scope_add_object   CONSTANT NUMBER(1) := 5;

 /* Used by kzvrcSynchObject()  */   
 PROCEDURE synchronize_policy_for_obj_rc(
       p_id                  IN NUMBER, 
       p_scope               IN NUMBER,
       p_delete_cascade      IN NUMBER);

END ;
/
SHOW ERRORS;

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to get_factor in dbms_macsec package.  Purpose is
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE FUNCTION dvsys.get_factor
                            (p_factor IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  RETURN dvsys.dbms_macsec.get_factor(p_factor => p_factor);
END;
/

CREATE OR REPLACE FUNCTION dvsys.get_factor_label
                            (p_factor IN VARCHAR2, p_policy_name IN VARCHAR2) RETURN VARCHAR2
IS
BEGIN
  RETURN dvsys.dbms_macsec.get_factor_label(p_factor => p_factor, p_policy_name => p_policy_name);
END;
/

CREATE OR REPLACE FUNCTION dvsys.get_trust_level(p_factor IN VARCHAR2) RETURN NUMBER
IS
BEGIN
  RETURN dvsys.dbms_macsec.get_trust_level(p_factor => p_factor);
END;
/

CREATE OR REPLACE FUNCTION dvsys.get_trust_level_for_identity(p_factor IN VARCHAR2,
                           p_identity IN VARCHAR2) RETURN NUMBER
IS
BEGIN
  RETURN dvsys.dbms_macsec.get_trust_level(p_factor => p_factor, p_identity => p_identity);
END;
/

SHOW ERRORS;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to init_session in dbms_macols package.  
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PROCEDURE dvsys.macols_init_session
IS
BEGIN
  dvsys.dbms_macols.init_session;
EXCEPTION
  -- Try to suppress stack trace
  WHEN OTHERS THEN
    --RAISE;
    NULL;
END;
/
SHOW ERRORS;

CREATE OR REPLACE PROCEDURE dvsys.ols_init_session
IS
BEGIN

    IF DVSYS.DBMS_MACUTL.IS_OID_ENABLED_OLS THEN                 
      LBACSYS.OLS_INIT_SESSION(DVSYS.DBMS_MACUTL.OLS_LDAP_USER); 
    ELSE                                                         
      LBACSYS.OLS_INIT_SESSION(DBMS_STANDARD.LOGIN_USER);        
    END IF;    

EXCEPTION
  -- Try to suppress stack trace
  WHEN OTHERS THEN
    --RAISE;
    NULL;
END;
/
SHOW ERRORS;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to set_factor in dbms_macsec package.  Purpose is
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE PROCEDURE dvsys.set_factor(p_factor IN VARCHAR2,
                                       p_value  IN VARCHAR2)
IS
BEGIN
  dvsys.dbms_macsec.set_factor(p_factor => p_factor,
                         p_value  => p_value);
END;
/
SHOW ERRORS;
Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to role_is_enabled in dbms_macsec package.  Purpose is
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE FUNCTION dvsys.role_is_enabled(p_role IN VARCHAR2) RETURN BOOLEAN
IS
BEGIN
  RETURN dvsys.dbms_macsec.role_is_enabled(p_role => p_role);
END;
/
SHOW ERRORS;

Rem Fix for Bug 6441524
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to is_secure_application role in dbms_macsec package.
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE FUNCTION dvsys.is_secure_application_role(p_role VARCHAR2) 
RETURN BOOLEAN IS
BEGIN
  RETURN dvsys.dbms_macsec.is_secure_application_role(p_role => p_role);
END;
/
SHOW ERRORS;

Rem
Rem
Rem
Rem    DESCRIPTION
Rem      Stand-alone call to dbms_macvpd packages for
Rem
Rem
Rem
Rem
Rem

CREATE OR REPLACE FUNCTION dvsys.predicate_true(p_owner IN VARCHAR2,
  p_object_name IN VARCHAR2)
RETURN VARCHAR2 IS
BEGIN
    return '0=0';
END;
/
SHOW ERRORS;

CREATE OR REPLACE FUNCTION dvsys.is_rls_authorized_by_realm(
       p_owner IN VARCHAR2,
       p_object_name IN VARCHAR2,
       p_user IN VARCHAR2 DEFAULT USER) RETURN NUMBER
IS
BEGIN
  -- buffer overflow checks
  IF (LENGTH(p_owner) > 30) THEN
      DBMS_MACUTL.RAISE_ERROR(47951,'p_owner');
  END IF;
  IF (LENGTH(p_object_name) > 30) THEN
      DBMS_MACUTL.RAISE_ERROR(47951,'p_object_name');
  END IF;
  IF (LENGTH(p_user) > 30) THEN
      DBMS_MACUTL.RAISE_ERROR(47951,'p_user');
  END IF;
  RETURN dvsys.dbms_macsec_events.is_rls_authorized_by_realm(
       p_user => p_user,
       p_object_owner => p_owner,
       p_object_name  => p_object_name);
END;
/
SHOW ERRORS;

Rem
Rem    DESCRIPTION
Rem      MACSECURE APIs for monitoring the runtime environment
Rem
Rem
Rem



CREATE OR REPLACE PACKAGE DVSYS.dbms_macsec_monitor AS

    g_startup_only NUMBER := 0;

    /**
    * Checks the monitoring rule repository for any tests and actions that need to be performed
    */
    PROCEDURE monitor_startup;


    /**
    * Test for a database parameters being equal to the expected values
    * @returns true if any do not pass the expected value test
    */
    FUNCTION test_parameters RETURN BOOLEAN;

    /**
    * Test for a database parameter being equal to an expected value
    * @returns true if did not pass the expected value test
    */
    FUNCTION test_parameter(
          p_paramter_name IN VARCHAR2
        , p_value IN VARCHAR2
    ) RETURN BOOLEAN;


    /**
    * Adds a rule to the rule set that controls the database session connect
        event for use as an action in a monitoring rule
    * @param p_rule_name - rule name to add to the rule set
        that controls the allowance of database sessions
    * @param p_enable_admin - indicator that controls the addition of
        an expression to allow sessions from MAC adminsitrators with the DV_ADMIN role
        to be created despite the connection restriction
    */
    PROCEDURE modify_connect_rule(
          p_rule_name    IN VARCHAR2
        , p_enable_admin IN BOOLEAN DEFAULT TRUE
    );

    /**
    * Disables the the database session connect event for a domain.
    * For use as an action in a monitoring rule
    * @param p_domain - the  name of the domain to disable connections for
    * @param p_enable_admin - indicator that controls the addition of
        an expression to allow sessions from MAC adminsitrators with the DV_ADMIN role
        to be created despite the connection restriction
    */
    PROCEDURE disable_domain_connect(
          p_domain       IN VARCHAR2
        , p_enable_admin IN BOOLEAN DEFAULT TRUE
    );


END;
/
show errors;



