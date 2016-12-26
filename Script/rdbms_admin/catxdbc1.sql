Rem
Rem $Header: catxdbc1.sql 29-apr-2008.15:26:09 vhosur Exp $
Rem
Rem catxdbc1.sql
Rem
Rem Copyright (c) 2001, 2008, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbc1.sql - Registration of XDB Config Schema
Rem
Rem    DESCRIPTION
Rem      This script registers the XDB configuration schema
Rem
Rem    NOTES
Rem      Subject to change, as the schema evolves
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    vhosur      04/29/08 - IPv6 support
Rem    rangrish    07/03/07 - change roles for web services
Rem    rangrish    08/15/06 - create new WS roles 
Rem    abagrawa    03/11/06 - Use xdbconfig.xsd in registerschema 
Rem    pnath       10/13/05 - add num_job_queue_processes 
Rem    najain      12/28/04 - no length restriction on ipaddress
Rem    abagrawa    12/27/05 - Use CSX for xdbconfig 
Rem    rtjoa       11/21/05 - Adding http and http2 host into xdbconfig 
Rem    mrafiq      09/20/05 - merging changes for upgrade/downgrade 
Rem    thbaby      09/19/05 - add acl-evaluation-method
Rem    najain      12/28/04 - no length restriction on ipaddress
Rem    rpang       04/01/05 - request-validation-function/input-filter-enable
Rem    rpang       03/24/05 - Fix SSO typo 
Rem    petam       03/18/05 - add allow-repository-anonymous-access for http
Rem    abagrawa    02/08/05 - Remove public grants on xdb$config
Rem    rpang       12/01/04 - Reordered plsql element 
Rem    petam       11/02/04 - bug#3957281 - add element <ftp-welcome-message> 
Rem    petam       11/11/04 - added <authentication> element
Rem    spannala    11/21/04 - adding rollback-on-error and 
Rem                           copy-on-inconsistent-update 
Rem    spannala    03/22/04 - adding nfsconfig 
Rem    rpang       10/27/04 - Added owa-debug-enable
Rem    rpang       10/14/04 - plsql-servlet-config to the end for downgrade
Rem    rpang       07/28/04 - Added database-username attribute
Rem    rpang       06/02/04 - Added PL/SQL servlet configuration
Rem    rangrish    05/11/04 - add XDBWEBSERVICES role 
Rem    spannala    05/10/04 - remove http2 listener 
Rem    thbaby      02/17/04 - add HTTP2 elements to schema 
Rem    spannala    07/11/03 - put new elements at the end
Rem    athusoo     07/17/03 - Set minOccurs=0 for new elements
Rem    athusoo     03/11/03 - Add xdbcore-xobmem-bound
Rem    rmurthy     11/20/02 - add schemalocation and xml mimetype mappings
Rem    njalali     09/26/02 - granting select privs on config tbl to public
Rem    dchiba      06/28/02 - Adding default URL charset in httpconfig
Rem    nmontoya    05/20/02 - ADD acl-cache-size
Rem    spannala    07/10/02 - adding case-sensitive-index-clause
Rem    nmontoya    07/08/02 - GRANT ALL ON xdb$config to xdbadmin
Rem    fge         04/26/02 - add resource-view-cache-size to sysconfig
Rem    abagrawa    03/08/02 - Change default log values
Rem    abagrawa    03/04/02 - Change userconfig to have minoccurs=0
Rem    nmontoya    02/26/02 - SET acl-max-age TYPE TO unsignedInt
Rem    rmurthy     02/14/02 - fix schema
Rem    spannala    01/31/02 - removing ftp-root
Rem    esedlar     02/05/02 - Remove duplicate type defs for protocols
Rem    rmurthy     12/28/01 - set elementForm to qualified
Rem    spannala    12/27/01 - setup should be run as SYS
Rem    sidicula    12/14/01 - Adding max-header-size in httpconfig
Rem    rmurthy     12/17/01 - fix schemas
Rem    abagrawa    11/19/01 - Add servlet realm
Rem    abagrawa    11/20/01 - Add default table
Rem    sidicula    11/08/01 - Config params for HTTP & FTP
Rem    jwwarner    10/24/01 - add authenticated user role
Rem    abagrawa    10/17/01 - Adding <servlet-schema>
Rem    sidicula    10/24/01 - Timeouts
Rem    abagrawa    10/07/01 - Merged abagrawa_http_trans
Rem    abagrawa    09/20/01 - Created
Rem

Rem alter session set events='31156 trace name context forever';
Rem Register Config Schema

declare
 CONFIGURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';  
 CONFIGXSD BFILE := dbms_metadata_hack.get_bfile('xdbconfig.xsd.11.2');
begin
 xdb.dbms_xmlschema.registerSchema(CONFIGURL, CONFIGXSD, FALSE, FALSE, FALSE, TRUE, FALSE, 'XDB', options => DBMS_XMLSCHEMA.REGISTER_BINARYXML);
end;
/


-- create the "virtual" authenticated user role we use in servlets
create role authenticatedUser;

-- create role for web services.  Must be granted to users for web services use
create role XDB_WEBSERVICES;
-- grant XDB_WEBSERVICES to xdb;
create role XDB_WEBSERVICES_WITH_PUBLIC;
create role XDB_WEBSERVICES_OVER_HTTP;

-- grant database privileges on xdb$config table so that users with xdbadmin 
--   role can proceed with xdb configuration update
grant all on xdb.xdb$config to xdbadmin ; 

create or replace trigger xdb.xdbconfig_validate before insert or update
on xdb.XDB$CONFIG for each row
declare
  xdoc xmltype;  
begin
  xdoc := :new.sys_nc_rowinfo$;
  xmltype.schemaValidate(xdoc);
end;
/
