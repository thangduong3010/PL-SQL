Rem
Rem $Header: dbmstrst.sql 24-may-2001.15:45:39 gviswana Exp $
Rem
Rem dbmstrst.sql
Rem
Rem  Copyright (c) Oracle Corporation 1996, 1997. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmstrst.sql - distributed trust administration
Rem
Rem    DESCRIPTION
Rem      These procedures maintain the Trusted Database List. Both 
Rem      Deny_all and Allow_all empty the list, and then insert a row 
Rem      indicating all servers should be untrusted or trusted, 
Rem      respectively.  Note that allow_all only applies to the 
Rem      servers listed as trusted at the Central Authority.  
Rem      Deny_server provides a way to indicate that, even though 
Rem      allow all is indicated in the list, a specific server is 
Rem      to be denied.  Similarly, allow_server provides a way to 
Rem      indicate that even though deny all is indicated in the 
Rem      list, some specific servers are to be allowed access.
Rem
Rem    NOTES
Rem      Note that this list is used in conjunction with the list
Rem      at the Central Authority to determine if a privileged 
Rem      database link from a particular server can be accepted.  
Rem      A particular server can be listed locally in the Trusted
Rem      Database List regardless of its listing at the CA. 
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    gviswana    05/24/01 - CREATE OR REPLACE SYNONYM
Rem    nlewis      04/22/97 - fix description 
Rem    nlewis      03/19/97 - change name of package
Rem    jbellemo    11/10/96 - Creation
Rem    jbellemo    11/10/96 - Created
Rem

create or replace package dbms_distributed_trust_admin is

  procedure allow_all;
  procedure deny_all;
  procedure allow_server(server in varchar2);
  procedure deny_server(server in varchar2);

end;
/

create or replace public synonym dbms_distributed_trust_admin
   for sys.dbms_distributed_trust_admin;

grant execute on dbms_distributed_trust_admin to execute_catalog_role;

