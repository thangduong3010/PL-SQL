Rem
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem    NAME
Rem      catmacdd.sql - Data pump support for Database vault protected schema
Rem
Rem    DESCRIPTION
Rem      Data Pump support for Database Vault Protected Schema.
Rem
Rem      Insert rows into sys.metaview$ to register the real Data Pump types,
Rem      which are created in the DVSYS schema (by the Database Vault
Rem      installation script rdbms/admin/catmacc.sql).
Rem
Rem    MODIFIED (MM/DD/YY)
Rem    vigaur    06/23/10 - Add set current schema
Rem    jsamuel   10/24/08 - execute in anonymous block
Rem    pknaggs   07/07/08 - bug 6938028: add Factor and Role support for DVPS.
Rem    pknaggs   06/20/08 - bug 6938028: Database Vault Protected Schema.
Rem    pknaggs   06/20/08 - Created
Rem
Rem
Rem

ALTER SESSION SET CURRENT_SCHEMA = SYS;

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_REALM',0,0,'ORACLE',1002000200,
  'DVPS_REALM_T',
  'KU$_DV_REALM_T','DVSYS','KU$_DV_REALM_VIEW');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_REALM_MEMBERSHIP',0,0,'ORACLE',1002000200,
  'DVPS_REALM_MEMBERSHIP_T',
  'KU$_DV_REALM_MEMBER_T','DVSYS','KU$_DV_REALM_MEMBER_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_REALM_AUTHORIZATION',0,0,'ORACLE',1002000200,
  'DVPS_REALM_AUTHORIZATION_T',
  'KU$_DV_REALM_AUTH_T','DVSYS','KU$_DV_REALM_AUTH_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_IMPORT_STAGING_REALM',0,0,'ORACLE',1002000200,
  'DVPS_IMPORT_STAGING_REALM_T',
  'KU$_DV_ISR_T','DVSYS','KU$_DV_ISR_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_STAGING_REALM_MEMBERSHIP',0,0,'ORACLE',1002000200,
  'DVPS_STAGING_REALM_MEMBERSHP_T',
  'KU$_DV_ISRM_T','DVSYS','KU$_DV_ISRM_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_DROP_IMPORT_STAGING_REALM',0,0,'ORACLE',1002000200,
  'DVPS_DISR_T',
  'KU$_DV_ISR_T','DVSYS','KU$_DV_ISR_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_RULE',0,0,'ORACLE',1002000200,
  'DVPS_RULE_T',
  'KU$_DV_RULE_T','DVSYS','KU$_DV_RULE_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_RULE_SET',0,0,'ORACLE',1002000200,
  'DVPS_RULE_SET_T',
  'KU$_DV_RULE_SET_T','DVSYS','KU$_DV_RULE_SET_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_RULE_SET_MEMBERSHIP',0,0,'ORACLE',1002000200,
  'DVPS_RULE_SET_MEMBERSHIP_T',
  'KU$_DV_RULE_SET_MEMBER_T','DVSYS','KU$_DV_RULE_SET_MEMBER_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_COMMAND_RULE',0,0,'ORACLE',1002000200,
  'DVPS_COMMAND_RULE_T',
  'KU$_DV_COMMAND_RULE_T','DVSYS','KU$_DV_COMMAND_RULE_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_ROLE',0,0,'ORACLE',1002000200,
  'DVPS_ROLE_T',
  'KU$_DV_ROLE_T','DVSYS','KU$_DV_ROLE_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_FACTOR',0,0,'ORACLE',1002000200,
  'DVPS_FACTOR_T',
  'KU$_DV_FACTOR_T','DVSYS','KU$_DV_FACTOR_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_FACTOR_LINK',0,0,'ORACLE',1002000200,
  'DVPS_FACTOR_LINK_T',
  'KU$_DV_FACTOR_LINK_T','DVSYS','KU$_DV_FACTOR_LINK_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_FACTOR_TYPE',0,0,'ORACLE',1002000200,
  'DVPS_FACTOR_TYPE_T',
  'KU$_DV_FACTOR_TYPE_T','DVSYS','KU$_DV_FACTOR_TYPE_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_IDENTITY',0,0,'ORACLE',1002000200,
  'DVPS_IDENTITY_T',
  'KU$_DV_IDENTITY_T','DVSYS','KU$_DV_IDENTITY_VIEW');
   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/

BEGIN
insert into sys.metaview$ (type, flags, properties, model, version,
                       xmltag,
                       udt, schema, viewname) values
 ('DVPS_IDENTITY_MAP',0,0,'ORACLE',1002000200,
  'DVPS_IDENTITY_MAP_T',
  'KU$_DV_IDENTITY_MAP_T','DVSYS','KU$_DV_IDENTITY_MAP_VIEW');

   EXCEPTION
   WHEN OTHERS THEN
     IF SQLCODE IN ( -00001) THEN NULL; --ignore unique constraint violation
     ELSE RAISE;
     END IF;

END;
/
