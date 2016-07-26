Rem
Rem $Header: rdbms/admin/catxdbc2.sql /main/32 2009/11/05 09:13:41 spetride Exp $
Rem
Rem catxdbc2.sql
Rem
Rem Copyright (c) 2001, 2009, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbc2.sql - Registration of default configuration for XDB
Rem
Rem    DESCRIPTION
Rem      This script registers the default configuration XML document 
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    10/30/09 - servlet realm should not specify Basic
Rem    vkapoor     07/25/06 - Bug 5371725
Rem    mrafiq      04/26/06 - change value for ac-max-age 
Rem    pbelknap    08/19/05 - add report framework servlet 
Rem    petam       04/07/06 - manually initialize resconfig after xdbconfig
Rem    thbaby      02/21/06 - Put NFS info into rootinfo
Rem    vkapoor     02/02/06 - remove , as invalid char 
Rem    sidicula    01/18/06 - Put protocol info into rootinfo 
Rem    thbaby      02/16/05 - Set ACL of xdbconfig.xml to all_owner_acl.xml
Rem    abagrawa    08/25/04 - Make xdbconfig.xml only readable by XDBADMIN 
Rem    petam       11/11/04 - added <authentication>, increase call-timeout
Rem    pnath       12/03/04 - change default http port to 0 
Rem    spannala    10/26/04 - fix bug 3926784 
Rem    rpang       10/14/04 - add mimetype mapping for js/css/png/svg
Rem    spannala    07/11/03 - put new elements at the end
Rem    athusoo     03/11/03 - Add xdbcore-xobmem-bound
Rem    athusoo     03/04/03 - add xdbcore-partition-size
Rem    ataracha    02/04/03 - add mimetype mapping for xsl
Rem    rshaikh     09/12/02 - add mimetype mapping for xsd
Rem    abagrawa    09/16/02 - Make config valid against schema
Rem    njalali     07/15/02 - adding value for resource-view-cache-size
Rem    esedlar     02/06/02 - Remove numusers
Rem    nmontoya    05/20/02 - ADD acl-cache-size
Rem    abagrawa    03/04/02 - Remove logging info, userconfig
Rem    spannala    01/31/02 - removing ftp-root
Rem    rmurthy     12/26/01 - change to 2001 xmlschema-instance namespace
Rem    spannala    12/27/01 - setup should be run as SYS
Rem    sidicula    12/14/01 - Adding max-header-size in httpconfig
Rem    sidicula    12/19/01 - Enabling session pooling
Rem    mmorsi      11/29/01 - Add ftp and http configuration
Rem    abagrawa    11/19/01 - Add servlet realm
Rem    sidicula    11/19/01 - Setting session pool size to 0
Rem    jwwarner    11/12/01 - increasing size of the document buffer
Rem    sidicula    11/08/01 - Config params for HTTP & FTP
Rem    nmontoya    11/12/01 - USE dbms_xdb.createresource
Rem    sidicula    10/31/01 - Adding timeouts
Rem    abagrawa    10/15/01 - Adding mime type mappings
Rem    jwwarner    10/19/01 - Add dburi servlet information
Rem    abagrawa    10/17/01 - Adding <servlet-schema>
Rem    abagrawa    10/07/01 - Merged abagrawa_http_trans
Rem    abagrawa    09/20/01 - Creation
Rem

Rem Register Config Schema

declare
retbool BOOLEAN;
b_abspath VARCHAR(20) := '/xdbconfig.xml';
acl_abspath VARCHAR(40) := '/sys/acls/all_owner_acl.xml';
b_data VARCHAR(32767) :=
'<xdbconfig xmlns="http://xmlns.oracle.com/xdb/xdbconfig.xsd" 
                 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                 xsi:schemaLocation="http://xmlns.oracle.com/xdb/xdbconfig.xsd http://xmlns.oracle.com/xdb/xdbconfig.xsd">
   <sysconfig>
      <acl-max-age>15</acl-max-age>
      <acl-cache-size>32</acl-cache-size>
      <invalid-pathname-chars></invalid-pathname-chars>     
      <case-sensitive>true</case-sensitive>
      <call-timeout>6000</call-timeout>
      <max-link-queue>65536</max-link-queue>
      <max-session-use>100</max-session-use>
      <persistent-sessions>false</persistent-sessions>
      <default-lock-timeout>3600</default-lock-timeout>
      <xdbcore-logfile-path/>
      <xdbcore-log-level>0</xdbcore-log-level>
      <resource-view-cache-size>1048576</resource-view-cache-size>
      <protocolconfig> 
          <common>
             <extension-mappings>
                <mime-mappings>
        <mime-mapping>
                <extension>au</extension>
                <mime-type>audio/basic</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>avi</extension>
                <mime-type>video/x-msvideo</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>bin</extension>
                <mime-type>application/octet-stream</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>bmp</extension>
                <mime-type>image/bmp</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>css</extension>
                <mime-type>text/css</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>doc</extension>
                <mime-type>application/msword</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>eml</extension>
                <mime-type>message/rfc822</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>gif</extension>
                <mime-type>image/gif</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>htm</extension>
                <mime-type>text/html</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>html</extension>
                <mime-type>text/html</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>jpe</extension>
                <mime-type>image/jpeg</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>jpeg</extension>
                <mime-type>image/jpeg</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>jpg</extension>
                <mime-type>image/jpeg</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>js</extension>
                <mime-type>application/x-javascript</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>jsp</extension>
                <mime-type>text/html</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>mid</extension>
                <mime-type>audio/mid</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>mov</extension>
                <mime-type>video/quicktime</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>movie</extension>
                <mime-type>video/x-sgi-movie</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>mp3</extension>
                <mime-type>audio/mpeg</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>mpe</extension>
                <mime-type>video/mpg</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>mpeg</extension>
                <mime-type>video/mpg</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>mpg</extension>
                <mime-type>video/mpg</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>msa</extension>
                <mime-type>application/x-msaccess</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>msw</extension>
                <mime-type>application/x-msworks-wp</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>pcx</extension>
                <mime-type>application/x-pc-paintbrush</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>pdf</extension>
                <mime-type>application/pdf</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>png</extension>
                <mime-type>image/png</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>ppt</extension>
                <mime-type>application/vnd.ms-powerpoint</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>ps</extension>
                <mime-type>application/postscript</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>qt</extension>
                <mime-type>video/quicktime</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>ra</extension>
                <mime-type>audio/x-realaudio</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>ram</extension>
                <mime-type>audio/x-realaudio</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>rm</extension>
                <mime-type>audio/x-realaudio</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>rtf</extension>
                <mime-type>application/rtf</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>rv</extension>
                <mime-type>video/x-realvideo</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>sgml</extension>
                <mime-type>text/sgml</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>svg</extension>
                <mime-type>image/svg+xml</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>tif</extension>
                <mime-type>image/tiff</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>tiff</extension>
                <mime-type>image/tiff</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>txt</extension>
                <mime-type>text/plain</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>url</extension>
                <mime-type>text/plain</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>vrml</extension>
                <mime-type>x-world/x-vrml</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>wav</extension>
                <mime-type>audio/wav</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>wpd</extension>
                <mime-type>application/wordperfect5.1</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>xls</extension>
                <mime-type>application/vnd.ms-excel</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>xml</extension>
                <mime-type>text/xml</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>xsd</extension>
                <mime-type>text/xml</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>xsl</extension>
                <mime-type>text/xml</mime-type>
        </mime-mapping>
        <mime-mapping>
                <extension>zip</extension>
                <mime-type>application/x-zip-compressed</mime-type>
        </mime-mapping>
                </mime-mappings>
                <lang-mappings>
                   <lang-mapping><extension>en</extension>
                                 <lang>english</lang>
                   </lang-mapping>
                </lang-mappings>

                <charset-mappings>
                </charset-mappings>

                <encoding-mappings>
                    <encoding-mapping><extension>gzip</extension>
                                     <encoding>zip file</encoding>      
                    </encoding-mapping>
                    <encoding-mapping><extension>tar</extension>
                                     <encoding>tar file</encoding>        
                    </encoding-mapping>
                </encoding-mappings>
             </extension-mappings>
             <session-pool-size>50</session-pool-size>
             <session-timeout>6000</session-timeout>
          </common>

          <ftpconfig>
            <ftp-port>0</ftp-port>
            <ftp-listener>local_listener</ftp-listener>
            <ftp-protocol>tcp</ftp-protocol>
            <logfile-path/>
            <log-level>0</log-level>
            <session-timeout>6000</session-timeout>
            <buffer-size>8192</buffer-size>
          </ftpconfig>

          <httpconfig>
            <http-port>0</http-port>
            <http-listener>local_listener</http-listener>
            <http-protocol>tcp</http-protocol>
            <max-http-headers>64</max-http-headers>
            <max-header-size>16384</max-header-size>
            <max-request-body>2000000000</max-request-body>
            <session-timeout>6000</session-timeout>
            <server-name>XDB HTTP Server</server-name>
            <logfile-path/>
            <log-level>0</log-level>
            <servlet-realm>XDB</servlet-realm>
            <webappconfig>
              <welcome-file-list>
                <welcome-file>index.html</welcome-file>
                <welcome-file>index.htm</welcome-file>
              </welcome-file-list>
              <error-pages>
              </error-pages>
              <servletconfig> 
                <servlet-mappings>
                  <servlet-mapping>
                    <servlet-pattern>/Test</servlet-pattern>
                    <servlet-name>TestServlet</servlet-name>
                  </servlet-mapping>
                  <servlet-mapping>
                    <servlet-pattern>/oradb/*</servlet-pattern>
                    <servlet-name>DBURIServlet</servlet-name>
                  </servlet-mapping>
                  <servlet-mapping>
                    <servlet-pattern>/orarep/*</servlet-pattern>
                    <servlet-name>ReportFmwkServlet</servlet-name>
                  </servlet-mapping>
                </servlet-mappings>
                               
                <servlet-list>
                  <servlet>
                    <servlet-name>TestServlet</servlet-name>
                    <servlet-language>Java</servlet-language>
                    <display-name>XDB Test Servlet</display-name>
                    <description>A servlet to test the internals of the XDB Servlet API</description>
                    <servlet-class>xdbtserv</servlet-class>
                    <servlet-schema>xdb</servlet-schema>
                  </servlet>
                  <servlet>
                    <servlet-name>DBURIServlet</servlet-name>
                    <servlet-language>C</servlet-language>
                    <display-name>DBURI</display-name>
                    <description>Servlet for accessing DBURIs</description>
                    <security-role-ref>
                      <role-name>authenticatedUser</role-name>
                      <role-link>authenticatedUser</role-link>
                    </security-role-ref>
                  </servlet>
                  <servlet>
                    <servlet-name>ReportFmwkServlet</servlet-name>
                    <servlet-language>C</servlet-language>
                    <display-name>REPT</display-name>
                    <description>Servlet for accessing reports</description>
                    <security-role-ref>
                      <role-name>authenticatedUser</role-name>
                      <role-link>authenticatedUser</role-link>
                    </security-role-ref>
                  </servlet>
                </servlet-list>
              </servletconfig>
            </webappconfig>
            <authentication>
              <allow-mechanism>basic</allow-mechanism>
              <digest-auth>
                <nonce-timeout>300</nonce-timeout>
              </digest-auth>
            </authentication>
          </httpconfig> 
      </protocolconfig>
      <xdbcore-xobmem-bound>1024</xdbcore-xobmem-bound>
      <xdbcore-loadableunit-size>16</xdbcore-loadableunit-size>
      <acl-evaluation-method>ace-order</acl-evaluation-method>
   </sysconfig>
</xdbconfig>';


begin

        retbool := dbms_xdb.createresource(b_abspath, b_data);
        dbms_xdb.setAcl(b_abspath, acl_abspath);
end;
/

Rem Update ROOT_INFO with protocol info
-- A simple select first to check if it works
select extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-port'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-protocol'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-port'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-protocol'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-host'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-port'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-protocol'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-host'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/nfsconfig/nfs-port'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/nfsconfig/nfs-protocol')
 from xdb.xdb$config e;

update xdb.xdb$root_info set 
(ftp_port, ftp_protocol, http_port, http_protocol, http_host, http2_port, http2_protocol, http2_host, nfs_port, nfs_protocol) 
= 
(select extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-port'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/ftpconfig/ftp-protocol'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-port'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-protocol'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http-host'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-port'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-protocol'),
        extractValue(value(e), 
          '/xdbconfig/sysconfig/protocolconfig/httpconfig/http2-host'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/nfsconfig/nfs-port'),
        extractValue(value(e),
          '/xdbconfig/sysconfig/protocolconfig/nfsconfig/nfs-protocol')
 from xdb.xdb$config e);

-- Reinitialize ResConfig since we are in a stable state now. 
call xdb.dbms_xdbz0.initXDBResConfig();
