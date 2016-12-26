Rem
Rem $Header: emll/admin/scripts/ocmdbd.sql /main/25 2012/06/14 16:46:36 jsutton Exp $
Rem
Rem ocmdbd.sql
Rem
Rem Copyright (c) 2005, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      ocmdbd.sql - OCM DB configuration collection package Definition
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    jsutton     03/22/12 - PDB support
Rem    jsutton     07/27/11 - update meta version to 10.3.6
Rem    aghanti     10/26/10 - Bumping up META_VER
Rem    jsutton     08/17/10 - bumping version
Rem    jsutton     04/29/10 - RAC instance collection - for ADR data
Rem    jsutton     04/23/10 - add trigger for db startup (RAC instance
Rem                           discovery aid)
Rem    aghanti     09/17/09 - Bump up META_VER to 10.3.3.0.0
Rem    jsutton     06/10/09 - Add IP address info to data
Rem    bkchoudh    06/04/09 - bump db version to 10.3.2.0
Rem    ysun        04/27/09 - bump db version to 10.3.1.1
Rem    ysun        03/25/09 - add 11.2 version
Rem    glavash     12/12/07 - update metadata version
Rem    dkapoor     08/13/07 - version change
Rem    dkapoor     05/07/07 - upgrade the version
Rem    dkapoor     06/13/06 - exception enabled interface 
Rem    dkapoor     01/23/07 - collect dbfus and highwwater mark separately
Rem    dkapoor     01/11/07 - update version to 10.2.5
Rem    dkapoor     06/13/06 - support for 11g 
Rem    dkapoor     06/02/06 - change ccr_user to ocm 
Rem    dkapoor     04/04/06 - change version 
Rem    dkapoor     12/06/05 - update versions 
Rem    dkapoor     10/11/05 - bump the sql version 
Rem    dkapoor     10/10/05 - change user to ccr 
Rem    dkapoor     10/05/05 - upgrade the mete version 
Rem    dkapoor     09/30/05 - impl 8.1.7 support 
Rem    ndutko      08/03/05 - ndutko_code_checkin
Rem    dkapoor     03/22/05 - Created
Rem

CREATE OR REPLACE PACKAGE ORACLE_OCM.MGMT_DB_LL_METRICS AS

TYPE GenericCurType IS REF CURSOR;
/*
This is the version of the livelink package.
Update this if there is any change in the PL/SQL.
Its read by the configVersion.pl script to obtain the installed version
of the PL/SQL.
*/
ORACLE_DATABASE_META_VER CONSTANT VARCHAR(17) := '10.3.7.0.2';
VERSION_817 CONSTANT VARCHAR(3) := '817';
VERSION_9i CONSTANT VARCHAR(3) := '9i';
VERSION_9iR2 CONSTANT VARCHAR(4) := '9iR2';
VERSION_10gR1 CONSTANT VARCHAR(5) := '10gR1';
VERSION_10gR2 CONSTANT VARCHAR(5) := '10gR2';
VERSION_11gR1 CONSTANT VARCHAR(5) := '11gR1';
VERSION_11gR2 CONSTANT VARCHAR(5) := '11gR2';
VERSION_12gR1 CONSTANT VARCHAR(5) := '12gR1';
MIN_SUPPORTED_VERSION CONSTANT VARCHAR2(10) := '08.1.7.0.0';
/*
	Not Supported Version
*/
NOT_SUPPORTED_VERSION CONSTANT VARCHAR(3) := 'NSV';
/*
	Higher Supported Version
*/
HIGHER_SUPPORTED_VERSION CONSTANT VARCHAR(3) := 'HSV';

/*
Puts the config data into the file
By default, this procedure does not raise an exception.
To raise an exception, pass "raise_exp" as TRUE.
*/
procedure collect_config_metrics(directory_location IN VARCHAR2,
  raise_exp BOOLEAN DEFAULT FALSE);

/*
Write some DB info to a file (for RAC discovery/ADR info collection)
By default, this procedure does not raise an exception.
To raise an exception, pass "raise_exp" as TRUE.
*/
procedure write_db_ccr_file(directory_location IN VARCHAR2,
  raise_exp BOOLEAN DEFAULT FALSE);

/*
Puts the statistics config data into the file
By default, this procedure does not raise an exception.
To raise an exception, pass "raise_exp" as TRUE.
*/
procedure collect_stats_metrics(directory_location IN VARCHAR2,
  raise_exp BOOLEAN DEFAULT FALSE);

/*
 Compute the version category 
*/
FUNCTION get_version_category RETURN VARCHAR2;

END MGMT_DB_LL_METRICS;
/
show errors package MGMT_DB_LL_METRICS;

