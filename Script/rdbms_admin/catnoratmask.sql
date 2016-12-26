Rem
Rem $Header: rdbms/admin/catnoratmask.sql /st_rdbms_11.2.0/1 2012/08/01 16:35:42 shjoshi Exp $
Rem
Rem catnoratmask.sql
Rem
Rem Copyright (c) 2010, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catnoratmask.sql - CATalog script to remove RAT masking tables
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    sburanaw    12/09/10 - add wri$_sts_masking_errors
Rem    sburanaw    11/21/10 - Created
Rem


DROP TABLE wrr$_masking_definition;
DROP TABLE wrr$_masking_parameters;
DROP TABLE wri$_sts_granules
DROP TABLE WRI$_STS_SENSITIVE_SQL;
DROP TABLE WRI$_MASKING_SCRIPT_PROGRESS;
DROP TABLE WRI$_STS_MASKING_STEP_PROGRESS;
DROP TABLE WRR$_MASKING_BIND_CACHE;
DROP TABLE WRR$_MASKING_FILE_PROGRESS;
DROP TABLE WRI$_STS_MASKING_ERRORS;
DROP TABLE WRI$_STS_MASKING_EXCEPTIONS;

DROP SEQUENCE WRI$_SQLSET_RATMASK_SEQ;
