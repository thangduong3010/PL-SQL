Rem
Rem $Header: ocmjd10.sql 23-jan-2007.13:28:23 dkapoor Exp $
Rem
Rem ocmjd10.sql
Rem
Rem Copyright (c) 2006, 2007, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      ocmjd10.sql - OCM db config collection Job package Definition for 10g onwards.
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    dkapoor     01/23/07 - create once a month job to coll stats
Rem    dkapoor     07/21/06 - create package to re-create dir object 
Rem    dkapoor     06/07/06 - cannot impl. change interval 
Rem    dkapoor     06/02/06 - change ccr_user to ocm 
Rem    dkapoor     05/22/06 - Created
Rem

CREATE OR REPLACE PACKAGE ORACLE_OCM.MGMT_CONFIG AS
/*
Submit a job to collect the configuration.
Basically, a job with what->printCollectConfigMetrics(<collection directory>
*/
procedure submit_job;

/*
Runs the configuration collection job now.
*/
procedure run_now;

/*
Stop the job.
*/
procedure stop_job;

/*
Print the job details.
*/
procedure print_job_details;

/*
Config collection job
*/
procedure collect_config;


/*
Statistics collection job
*/
procedure collect_stats;

END MGMT_CONFIG;
/
show errors package MGMT_CONFIG;

/*
     This package is executed with invoker's rights. This is needed so that
     ORACLE_OCM user does not need to be granted "execute" permission on "dbms_system" package.
*/
CREATE OR REPLACE PACKAGE ORACLE_OCM.MGMT_CONFIG_UTL 
AUTHID CURRENT_USER AS
/*
Create or replace the directory object to recreate the path based on 
new ORACLE_HOME.
Note: 
  1. This procedure is executed with invoker's rights. This is needed so that
     ORACLE_OCM user does not need to be granted "execute" permission on "dbms_system" package.
     Only SYS would be able to run this procedure without error as it has the privilege to execute "dbms_system" and re-create
     the directory object ORACLE_OCM_CONFIG_DIR owned by it.
  2. This procedure is only supported from release 10.2 onwards that supports dbms_system.get_env.
*/
procedure create_replace_dir_obj;
END MGMT_CONFIG_UTL;
/
show errors package MGMT_CONFIG_UTL;

