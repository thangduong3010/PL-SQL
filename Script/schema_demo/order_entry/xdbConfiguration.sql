Rem
Rem $Header: rdbms/demo/schema/order_entry/xdbConfiguration.sql /st_rdbms_11.2.0/1 2012/03/28 22:32:42 bhammers Exp $
Rem
Rem xdbConfiguration.sql
Rem
Rem Copyright (c) 2002, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      xdbConfiguration.sql - Create view DATABASE_SUMMARY and package XDB_CONFIGURATION
Rem
Rem    DESCRIPTION
Rem      .
Rem
Rem    NOTES
Rem      .
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    bhammers    03/27/12 - Backport bhammers_mdrakebugs from main
Rem    cbauwens    09/23/04 - cbauwens_bug3031915
Rem    cbauwens    03/16/04 - Created 
R

CREATE OR REPLACE VIEW DATABASE_SUMMARY 
AS
SELECT d.NAME, p.VALUE "SERVICE_NAME", i.HOST_NAME, n.VALUE "DB_CHARACTERSET" 
  FROM v$system_parameter p, v$database d, v$instance i, nls_database_parameters n
  WHERE p.name = 'service_names' 
    AND n.parameter='NLS_CHARACTERSET';
/


GRANT SELECT ON DATABASE_SUMMARY TO PUBLIC
/
ALTER SESSION SET current_schema = XDB
/

CREATE OR REPLACE PACKAGE COE_CONFIGURATION
AUTHID CURRENT_USER
AS
  PROCEDURE  setHTTPport (PORT_NUMBER number);
  PROCEDURE  setFTPport  (PORT_NUMBER number);
  FUNCTION   getDatabaseSummary return xmltype;
  PROCEDURE  folderDatabaseSummary;
END COE_CONFIGURATION;
/


CREATE OR REPLACE PACKAGE BODY COE_CONFIGURATION AS

ftp_xpath   VARCHAR2(256) := '/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-port';
http_xpath  VARCHAR2(256) := '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-port';

FUNCTION getDatabaseSummary
  RETURN XMLType
  AS
    summary XMLType;
    dummy XMLType;
BEGIN
  SELECT DBMS_XDB.cfg_get()
    INTO dummy
    FROM dual;

  SELECT xmlElement
         (
           "Database",
           XMLAttributes
           (
             x.NAME as "Name",
             extractValue(config,'/xdbconfig/sysconfig/protocolconfig/httpconfig/http-port') as "HTTP",
             extractValue(config,'/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-port') as "FTP"
           ),
           xmlElement
           (
             "Services",
             (
               xmlForest(SERVICE_NAME as "ServiceName")
             )
           ),
           xmlElement
           (
             "NLS",
             (
               XMLForest(DB_CHARACTERSET as "DatabaseCharacterSet")
             )
           ),
           xmlElement
           (
             "Hosts",
             (
               XMLForest(HOST_NAME as "HostName")
             )
           ),
           xmlElement
           (
             "VersionInformation",
             ( XMLCONCAT
                      (
                        (select XMLAGG(XMLElement
                        (
                           "ProductVersion",
                           BANNER
                        )
                        )from V$VERSION),
                        (select XMLAGG(XMLElement
                        (
                           "ProductVersion",
                           BANNER
                        )
                        ) from ALL_REGISTRY_BANNERS)
                      )
             ) 
           )
         )
    INTO summary
    FROM SYS.DATABASE_SUMMARY x, (SELECT DBMS_XDB.cfg_get() config FROM dual);
  summary := XMLType(summary.getClobVal());
  RETURN summary;
END;

PROCEDURE folderDatabaseSummary
AS
   result BOOLEAN;
   targetResource VARCHAR2(256) := '/sys/databaseSummary.xml';

   xmlref REF XMLType;

BEGIN

   BEGIN
     DBMS_XDB.deleteResource(targetResource, DBMS_XDB.DELETE_FORCE);
   EXCEPTION
     WHEN OTHERS THEN
       NULL;
   END;

   SELECT make_ref(DATABASE_SUMMARY,'DATABASE_SUMMARY')
     INTO xmlref
     FROM DATABASE_SUMMARY;
   result := DBMS_XDB.createResource(targetResource, xmlref);
   DBMS_XDB.setAcl(targetResource, '/sys/acls/bootstrap_acl.xml');
END;

PROCEDURE setXDBport(port_xpath VARCHAR2, port_number NUMBER)
AS
   config XMLType;
BEGIN
   config := DBMS_XDB.cfg_get();
   SELECT updateXML(config, port_xpath, port_number)
     INTO config
     FROM DUAL;
   DBMS_XDB.cfg_update(config);
   COMMIT;
   DBMS_XDB.cfg_refresh();
END;
--
-- Create the setHTTPport and setFTPport procudures

PROCEDURE setHTTPport (port_number NUMBER)
AS
BEGIN
  setXDBport(HTTP_XPATH || '/text()', port_number);
END;

PROCEDURE setFTPport(port_number NUMBER)
AS
BEGIN
  setXDBport(FTP_XPATH || '/text()', port_number);
END;

END COE_CONFIGURATION;
/


CREATE OR REPLACE VIEW database_summary OF XMLType
WITH object id
(
'DATABASE_SUMMARY'
)
AS SELECT coe_configuration.getDatabaseSummary() FROM DUAL
/


ALTER PACKAGE COE_CONFIGURATION compile
/


ALTER VIEW database_summary COMPILE
/


GRANT SELECT ON database_summary TO PUBLIC
/

CREATE OR REPLACE TRIGGER no_dml_operations_allowed
INSTEAD OF INSERT OR UPDATE OR DELETE ON database_summary
BEGIN
 NULL;
END;
/


CREATE OR REPLACE PUBLIC SYNONYM COE_CONFIGURATION FOR COE_CONFIGURATION
/
GRANT EXECUTE ON COE_CONFIGURATION TO PUBLIC
/
CALL COE_CONFIGURATION.folderDatabaseSummary()
/
ALTER SESSION SET current_schema = SYS
/
