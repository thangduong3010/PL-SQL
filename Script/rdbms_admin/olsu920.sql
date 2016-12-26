Rem
Rem $Header: olsu920.sql 26-feb-2004.14:12:57 srtata Exp $
Rem
Rem olsu920.sql
Rem
Rem Copyright (c) 2002, 2004, Oracle Corporation.  All rights reserved.  
Rem
Rem    NAME
Rem      olsu920.sql - OLS Upgrade script for 9.2.0 database.
Rem
Rem    DESCRIPTION
Rem      This is the upgrade script for OLS from 9.2 to 10.0.0
Rem
Rem    NOTES
Rem      Must be run as SYSDBA.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    srtata      02/26/04 - call olsu101.sql 
Rem    srtata      02/07/03 - remove aud$ changes
Rem    srtata      01/30/03 - increase privs field in saprofiles
Rem    srtata      01/27/03 - remove insert stmts
Rem    srtata      01/11/03 - changed the saprofiles definition
Rem    srtata      11/07/02 - add table sa$dip_events
Rem    srtata      10/31/02 - srtata_bug-2625108
Rem    srtata      10/16/02 - Created
Rem

-- Upgrade OLS from 9.2.0.0 to 10.0.0.0.0

-- Drop obsolete objects (views, packages, etc.) from prior release

DROP TRIGGER LBACSYS.LBAC$STARTUP;


-- Create new tables and indexes

CREATE TABLE LBACSYS.lbac$policy_admin(
      admin_dn    VARCHAR2(1024) NOT NULL,
      policy_name VARCHAR2(30)   NOT NULL,
      CONSTRAINT admin_policy_fk FOREIGN KEY (policy_name)
                 REFERENCES LBACSYS.lbac$pol(pol_name) ON DELETE CASCADE );

CREATE TABLE LBACSYS.sa$profiles (
      policy_name     VARCHAR2(30)   NOT NULL,
      profile_name    VARCHAR2(30)   NOT NULL,
      max_read_label  VARCHAR2(4000),
      max_write_label VARCHAR2(4000),
      min_write_label VARCHAR2(4000),
      def_read_label  VARCHAR2(4000),
      def_row_label   VARCHAR2(4000),
      privs           VARCHAR2(256),
      CONSTRAINT profile_pk        PRIMARY KEY (policy_name, profile_name),
      CONSTRAINT profile_policy_fk FOREIGN KEY (policy_name)
                 REFERENCES LBACSYS.lbac$pol(pol_name) ON DELETE CASCADE);

CREATE TABLE LBACSYS.sa$dip_debug(
      event_id      VARCHAR2(32)  NOT NULL,
      objectdn      VARCHAR2(1024) NOT NULL,
      ols_operation VARCHAR2(50) );

CREATE TABLE LBACSYS.sa$dip_events(
      event_id      VARCHAR2(32) NOT NULL,
      purpose       VARCHAR2(40) NOT NULL );

-- ALTER tables to add/change columns and constraints for the new release

ALTER TABLE LBACSYS.lbac$user MODIFY usr_name varchar2(1024);
ALTER TABLE LBACSYS.sa$user_levels MODIFY usr_name varchar2(1024);
ALTER TABLE LBACSYS.sa$user_compartments MODIFY usr_name varchar2(1024);
ALTER TABLE LBACSYS.sa$user_groups MODIFY usr_name varchar2(1024);

-- Create new types for the release

CREATE TYPE LBACSYS.LDAP_ATTR AS OBJECT (
     attr_name        VARCHAR2(256),
     attr_value       VARCHAR2(4000),
     attr_bvalue      BLOB,
     attr_value_len   INTEGER,
     attr_type        INTEGER,  -- (0 - String, 1 - Binary)
     attr_mod_op      INTEGER
);
/

CREATE TYPE LBACSYS.LDAP_ATTR_LIST AS TABLE OF LBACSYS.LDAP_ATTR;
/

CREATE TYPE LBACSYS.LDAP_EVENT AS OBJECT (
          event_type  VARCHAR2(32),
          event_id    VARCHAR2(32),
          event_src   VARCHAR2(1024),
          event_time  VARCHAR2(32),
          object_name VARCHAR2(1024),
          object_type VARCHAR2(32),
          object_guid VARCHAR2(32),
          object_dn   VARCHAR2(1024),
          profile_id  VARCHAR2(1024),
          attr_list   LBACSYS.LDAP_ATTR_LIST ) ;
/

CREATE TYPE LBACSYS.LDAP_EVENT_STATUS AS OBJECT (
          event_id          VARCHAR2(32),
          orclguid          VARCHAR(32),
          error_code        INTEGER,
          error_String      VARCHAR2(1024),
          error_disposition VARCHAR2(32)) ;
/

-- Call 101 upgrade script

@@olsu101.sql


