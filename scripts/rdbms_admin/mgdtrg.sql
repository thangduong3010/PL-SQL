Rem
Rem $Header: rdbms/admin/mgdtrg.sql /main/3 2010/06/09 08:08:44 hgong Exp $
Rem
Rem mgdtrg.sql
Rem
Rem Copyright (c) 2006, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      mgdtrg.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hgong       05/21/10 - add mgd_id_category_tab
Rem    hgong       05/31/06 - move after delete trigger logic to utility 
Rem    hgong       05/16/06 - rename MGD_ID_META to MGD_ID_UTL 
Rem    hgong       04/04/06 - rename oidcode.jar 
Rem    hgong       03/31/06 - create triggers 
Rem    hgong       03/31/06 - Created
Rem

prompt .. Creating the user_mgd_id_scheme_ins_trig trigger for inserting into user_mgd_id_category view

CREATE OR REPLACE TRIGGER user_mgd_id_category_ins_trig
INSTEAD OF INSERT ON user_mgd_id_category
REFERENCING NEW AS n
FOR EACH ROW
declare
 user_name varchar2(32);
BEGIN
  EXECUTE IMMEDIATE 'SELECT user FROM dual' into user_name;
  INSERT INTO mgd_id_category_tab(
    owner,
    category_id,
    category_name,
    version,
    agency,
    uri
  )
  VALUES(
    user_name,
    :n.category_id,
    :n.category_name,
    :n.version,
    :n.agency,
    :n.uri
  );
END;
/
show errors;

prompt .. Creating the user_mgd_id_category_del_trig trigger for deleting from user_mgd_id_category view

CREATE OR REPLACE TRIGGER user_mgd_id_category_del_trig
INSTEAD OF DELETE ON user_mgd_id_category
REFERENCING OLD AS o
FOR EACH ROW
DECLARE
  user_name    VARCHAR2(256);
BEGIN

  EXECUTE IMMEDIATE 'SELECT USER FROM DUAL' INTO user_name;

  DELETE FROM mgd_id_category_tab
  WHERE OWNER = user_name
    AND NLS_UPPER(category_id) = :o.category_id;
END;
/
SHOW ERRORS;



prompt .. Creating the user_mgd_id_category_upd_trig trigger for updating user_mgd_id_category view

CREATE OR REPLACE TRIGGER user_mgd_id_category_upd_trig
INSTEAD OF UPDATE ON user_mgd_id_category
REFERENCING OLD AS o NEW AS n
FOR EACH ROW
DECLARE
  user_name    VARCHAR2(256);
BEGIN
  EXECUTE IMMEDIATE 'SELECT USER FROM DUAL' INTO user_name;
  UPDATE mgd_id_category_tab
  SET(
    category_name,
    version,
    agency,
    uri
  ) =
  (SELECT
    :n.category_name,
    :n.version,
    :n.agency,
    :n.uri
   FROM DUAL
   WHERE owner = user_name
     AND category_id = :o.category_id
  );
END;
/
show errors;


prompt .. Creating the idcode_scheme_before_ins_trig trigger which validates each TDT before insertion and sets the type_name and encoding fields appropriately

CREATE OR REPLACE TRIGGER mgd_id_scheme_before_ins_trig
BEFORE INSERT ON mgd_id_scheme_tab
FOR EACH ROW
DECLARE
  type_and_encodings VARCHAR2(1024);
  pos1               INTEGER;
  pos2               INTEGER;
BEGIN
  type_and_encodings := DBMS_MGD_ID_UTL.validate_scheme(:new.tdt_xml);
  pos1 := instr(type_and_encodings, ';');
  pos2 := instr(type_and_encodings, ';', 1, 2);
  :new.type_name := substr(type_and_encodings, 0, pos1 - 1);
  :new.encodings := substr(type_and_encodings, pos1 + 1, pos2 - pos1 - 1); 
  :new.components := substr(type_and_encodings, pos2 + 1, length(type_and_encodings) - pos2); 
END;
/
show errors;


prompt .. Creating the idcode_scheme_before_upd_trig trigger which validates the new scheme after update and refreshes the category to which it belongs

CREATE OR REPLACE TRIGGER mgd_id_scheme_before_upd_trig
BEFORE UPDATE ON mgd_id_scheme_tab
FOR EACH ROW
DECLARE
  type_and_encodings VARCHAR2(1024);
  pos1               INTEGER;
  pos2               INTEGER;
BEGIN
  type_and_encodings := DBMS_MGD_ID_UTL.validate_scheme(:NEW.tdt_xml);
  pos1 := instr(type_and_encodings, ';');
  pos2 := instr(type_and_encodings, ';', 1, 2);
  :new.type_name := substr(type_and_encodings, 0, pos1 - 1);
  :new.encodings := substr(type_and_encodings, pos1 + 1, pos2 - pos1 - 1); 
  :new.components := substr(type_and_encodings, pos2 + 1, length(type_and_encodings) - pos2);  
  DBMS_MGD_ID_UTL.refresh_category(to_char(:old.category_id));
END;
/
show errors;


prompt .. Creating the user_mgd_id_scheme_ins_trig trigger for inserting into user_mgd_id_scheme view

CREATE OR REPLACE TRIGGER user_mgd_id_scheme_ins_trig
INSTEAD OF INSERT ON user_mgd_id_scheme
REFERENCING NEW AS n
FOR EACH ROW
declare
 user_name varchar2(32);
BEGIN
  EXECUTE IMMEDIATE 'SELECT user FROM dual' into user_name;
  INSERT INTO mgd_id_scheme_tab(
    owner,
    category_id,
    type_name,
    tdt_xml,
    encodings,
    components
  )
  VALUES(
    user_name,
    :n.category_id,
    :n.type_name,
    :n.tdt_xml,
    :n.encodings,
    :n.components
  );
END;
/
show errors;



prompt .. Creating the user_mgd_id_scheme_del_trig trigger for deleting from user_mgd_id_scheme view

CREATE OR REPLACE TRIGGER user_mgd_id_scheme_del_trig
INSTEAD OF DELETE ON user_mgd_id_scheme
REFERENCING OLD AS o
FOR EACH ROW
DECLARE
  user_name    VARCHAR2(256);
BEGIN
  
  EXECUTE IMMEDIATE 'SELECT USER FROM DUAL' INTO user_name;

  DELETE FROM mgd_id_scheme_tab 
  WHERE OWNER = user_name
    AND NLS_UPPER(category_id) = :o.category_id
    AND type_name = :o.type_name;
END;
/
SHOW ERRORS;


prompt .. Creating the user_mgd_id_scheme_upd_trig trigger for updating user_mgd_id_scheme view

CREATE OR REPLACE TRIGGER user_mgd_id_scheme_upd_trig
INSTEAD OF UPDATE ON user_mgd_id_scheme
REFERENCING OLD AS o NEW AS n
FOR EACH ROW
DECLARE
  user_name    VARCHAR2(256);
BEGIN
  EXECUTE IMMEDIATE 'SELECT USER FROM DUAL' INTO user_name;
  UPDATE mgd_id_scheme_tab
  SET(
    tdt_xml,
    encodings,
    components
  ) = 
  (SELECT 
    :n.tdt_xml,
    :n.encodings,
    :n.components
   FROM DUAL
   WHERE owner = user_name
     AND category_id = :o.category_id
     AND type_name = :o.type_name 
  );
END;
/
show errors;

