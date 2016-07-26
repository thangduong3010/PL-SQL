Rem
Rem $Header: plsql/admin/dbmsnacl.sql /st_rdbms_11.2.0/1 2012/04/26 11:51:02 rpang Exp $
Rem
Rem dbmsnacl.sql
Rem
Rem Copyright (c) 2006, 2012, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      dbmsnacl.sql - DBMS Network ACL
Rem
Rem    DESCRIPTION
Rem      This package provides the PL/SQL interface to administer the
Rem      access control list of network access from the database through
Rem      the PL/SQL network-related utility packages.
Rem
Rem    NOTES
Rem      This package must be created under SYS.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    apfwkr      04/23/12 - Backport rpang_bug-13932413 from main
Rem    rpang       03/17/08 - Add API to assign ACL to wallets
Rem    rpang       01/02/08 - IPv6 support
Rem    rpang       03/09/07 - Use ACLID
Rem    rpang       12/13/06 - Move check_privilege_aclid impl to body
Rem    rpang       09/21/06 - Handle ACE start_date and end_date
Rem    rpang       08/24/06 - Add ACE start_date/end_date
Rem    rpang       06/08/06 - Created
Rem

create or replace package dbms_network_acl_admin is

  /*
   * DBMS_NETWORK_ACL_ADMIN is the PL/SQL package that provides the interface
   * to administer the network ACL. The EXECUTE privilege on the package will
   * be granted only to the DBA role by default.
   */

  ----------------
  -- Exceptions --
  ----------------
  ace_already_exists          EXCEPTION;
  empty_acl                   EXCEPTION;
  acl_not_found               EXCEPTION;
  invalid_acl_path            EXCEPTION;
  invalid_host                EXCEPTION;
  invalid_privilege           EXCEPTION;
  invalid_wallet_path         EXCEPTION;
  bad_argument                EXCEPTION;
  unresolved_principal        EXCEPTION;
  PRAGMA EXCEPTION_INIT(ace_already_exists,          -24243);
  PRAGMA EXCEPTION_INIT(empty_acl,                   -24246);
  PRAGMA EXCEPTION_INIT(acl_not_found,               -31001);
  PRAGMA EXCEPTION_INIT(invalid_acl_path,            -46059);
  PRAGMA EXCEPTION_INIT(invalid_host,                -24244);
  PRAGMA EXCEPTION_INIT(invalid_privilege,           -24245);
  PRAGMA EXCEPTION_INIT(invalid_wallet_path,         -29248);
  PRAGMA EXCEPTION_INIT(bad_argument,                -29261);
  PRAGMA EXCEPTION_INIT(unresolved_principal,        -44416);
  ace_already_exists_num      constant PLS_INTEGER := -24243;
  empty_acl_num               constant PLS_INTEGER := -24246;
  acl_not_found_num           constant PLS_INTEGER := -31001;
  invalid_acl_path_num        constant PLS_INTEGER := -46059;
  invalid_host_num            constant PLS_INTEGER := -24244;
  invalid_privilege_num       constant PLS_INTEGER := -24245;
  invalid_wallet_path_num     constant PLS_INTEGER := -29248;
  bad_argument_num            constant PLS_INTEGER := -29261;
  unresolved_principal_num    constant PLS_INTEGER := -44416;

  -- IP address mask: xxx.xxx.xxx.xxx
  IP_ADDR_MASK    constant VARCHAR2(80) := '([[:digit:]]+\.){3}[[:digit:]]+';
  -- IP submet mask:  xxx.xxx...*
  IP_SUBNET_MASK  constant VARCHAR2(80) := '([[:digit:]]+\.){0,3}\*';
  -- Hostname mask:   ???.???.???...???
  HOSTNAME_MASK   constant VARCHAR2(80) := '[^\.\:\/\*]+(\.[^\.\:\/\*]+)*';
  -- Hostname mask:   *.???.???...???
  DOMAIN_MASK     constant VARCHAR2(80) := '\*(\.[^\.\:\/\*]+)*';

  /*--------------- API for ACL and privilege administration ---------------*/

  /*
   * Creates an access control list (ACL) with an initial privilege setting.
   * An ACL must have at least one privilege setting. The ACL has no access
   * control effect unless it is assigned to a network host.
   *
   * PARAMETERS
   *   acl          the name of the ACL. Relative path will be relative to
   *                "/sys/acls".
   *   description  the description attribute in the ACL
   *   principal    the principal (database user or role) whom the privilege
   *                is granted to or denied from
   *   is_grant     is the privilege is granted or denied
   *   privilege    the network privilege to be granted or denied
   *   start_date   the start date of the access control entry (ACE). When
   *                specified, the ACE will be valid only on and after the
   *                specified date.
   *   end_date     the end date of the access control entry (ACE). When
   *                specified, the ACE will expire after the specified date.
   *                The end_date must be greater than or equal to the
   *                start_date.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   *   To remove the ACL, use DROP_ACL. To assign the ACL to a network host,
   *   use ASSIGN_ACL.
   */
  procedure create_acl(acl          in varchar2,
                       description  in varchar2,
                       principal    in varchar2,
                       is_grant     in boolean,
                       privilege    in varchar2,
                       start_date   in timestamp with time zone default null,
                       end_date     in timestamp with time zone default null);

  /*
   * Adds a privilege to grant or deny the network access to the user. The
   * access control entry (ACE) will be created if it does not exist.
   *
   * PARAMETERS
   *   acl          the name of the ACL. Relative path will be relative to
   *                "/sys/acls".
   *   principal    the principal (database user or role) whom the privilege
   *                is granted to or denied from
   *   is_grant     is the privilege is granted or denied
   *   privilege    the network privilege to be granted or denied
   *   position     the position of the ACE. If a non-null value is given,
   *                the privilege will be added in a new ACE at the given
   *                position and there should not be another ACE for the
   *                principal with the same is_grant (grant or deny). If a null
   *                value is given, the privilege will be added to the ACE
   *                matching the principal and the is_grant if one exists, or
   *                to the end of the ACL if the matching ACE does not exist.
   *   start_date   the start date of the access control entry (ACE). When
   *                specified, the ACE will be valid only on and after the
   *                specified date. The start_date will be ignored if the
   *                privilege is added to an existing ACE.
   *   end_date     the end date of the access control entry (ACE). When
   *                specified, the ACE will expire after the specified date.
   *                The end_date must be greater than or equal to the
   *                start_date. The end_date will be ignored if the
   *                privilege is added to an existing ACE.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   *   To remove the privilege, use DELETE_privilege.
   */
  procedure add_privilege(acl        in varchar2,
                          principal  in varchar2,
                          is_grant   in boolean,
                          privilege  in varchar2,
                          position   in pls_integer default null,
                          start_date in timestamp with time zone default null,
                          end_date   in timestamp with time zone default null);

  /*
   * Delete a privilege.
   *
   * PARAMETERS
   *   acl          the name of the ACL. Relative path will be relative to
   *                "/sys/acls".
   *   principal    the principal (database user or role) for whom the
   *                privileges will be deleted
   *   is_grant     is the privilege is granted or denied. If a null
   *                value is given, the deletion is applicable to both
   *                granted or denied privileges.
   *   privilege    the privilege to be deleted. If a null value is given,
   *                the deletion is applicable to all privileges.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   *   Any ACE that does not contain any privilege after the deletion will
   *   be removed also.
   */
  procedure delete_privilege(acl          in varchar2,
                             principal    in varchar2,
                             is_grant     in boolean  default null,
                             privilege    in varchar2 default null);

  /*
   * Drops an access control list (ACL).
   *
   * PARAMETERS
   *   acl          the name of the ACL. Relative path will be relative to
   *                "/sys/acls".
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   */
  procedure drop_acl(acl in varchar2);

  /*--------- API for ACL assignment to network hosts and wallets ---------*/

  /*
   * Assigns an access control list (ACL) to a network host, and optionally
   * specific to a TCP port range.
   *
   * PARAMETERS
   *   acl        the name of the ACL. Relative path will be relative to
   *              "/sys/acls".
   *   host       the host to which the ACL will be assigned. The host can be
   *              the name or the IP address of the host. A wildcard can be
   *              used to specify a domain or a IP subnet. The host or
   *              domain name is case-insensitive.
   *   lower_port the lower bound of a TCP port range if not NULL.
   *   upper_port the upper bound of a TCP port range. If NULL,
   *              lower_port is assumed.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   * 1. The ACL assigned to a domain takes a lower precedence than the other
   *    ACLs assigned sub-domains, which take a lower precedence than the ACLs
   *    assigned to the individual hosts. So for a given host say
   *    "www.us.mycompany.com", the following domains are listed in decreasing
   *    precedences:
   *      - www.us.mycompany.com
   *      - *.us.mycompany.com
   *      - *.mycompany.com
   *      - *.com
   *      - *
   *    In the same way, the ACL assigned to an subnet takes a lower
   *    precedence than the other ACLs assigned smaller subnets, which take a
   *    lower precedence than the ACLs assigned to the individual IP addresses.
   *    So for a given IP address say "192.168.0.100", the following subnets
   *    are listed in decreasing precedences:
   *      - 192.168.0.100
   *      - 192.168.0.*
   *      - 192.168.*
   *      - 192.*
   *      - *
   * 2. The port range is applicable only to the "connect" privilege
   *    assignments in the ACL. The "resolve" privilege assignments in an ACL
   *    have effects only when the ACL is assigned to a host without a port
   *    range.
   * 3. For the "connect" privilege assignments, an ACL assigned to the host
   *    without a port range takes a lower precedence than other ACLs assigned
   *    to the same host with a port range.
   * 4. When specifying a TCP port range, both lower_port and upper_port must
   *    not be NULL and upper_port must be greater than or equal to lower_port.
   *    The port range must not overlap with any other port ranges for the same
   *    host assigned already.
   * 5. To remove the assignment, use UNASSIGN_ACL.
   */
  procedure assign_acl(acl        in varchar2,
                       host       in varchar2,
                       lower_port in pls_integer default null,
                       upper_port in pls_integer default null);

  /*
   * Unassign the access control list (ACL) currently assigned to a network
   * host.
   *
   * PARAMETERS
   *   acl        the name of the ACL. Relative path will be relative to
   *              "/sys/acls". If acl is NULL, any ACL assigned to the host
   *              will be unassigned.
   *   host       the host remove the ACL assignment from. The host can be
   *              the name or the IP address of the host. A wildcard can be
   *              used to specify a domain or a IP subnet. The host or
   *              domain name is case-insensitive. If host is null, the ACL
   *              will be unassigned from any host. If both host and acl are
   *              NULL, all ACLs assigned to any hosts will be unassigned.
   *   lower_port if not NULL, the lower bound of a TCP port range for the
   *              host.
   *   upper_port the upper bound of a TCP port range. If NULL,
   *              lower_port is assumed.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   */
  procedure unassign_acl(acl        in varchar2 default null,
                         host       in varchar2 default null,
                         lower_port in pls_integer default null,
                         upper_port in pls_integer default null);

  /*
   * Assigns an access control list (ACL) to a wallet.
   *
   * PARAMETERS
   *   acl         the name of the ACL. Relative path will be relative to
   *               "/sys/acls".
   *   wallet_path the directory path of the wallet to which the ACL will be
   *               assigned. The path is case-sensitive and of the format
   *               "file:<directory-path>".
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   * NOTES
   *   To remove the assignment, use UNASSIGN_WALLET_ACL.
   */
  procedure assign_wallet_acl(acl         in varchar2,
                              wallet_path in varchar2);

  /*
   * Unassign the access control list (ACL) currently assigned to a wallet.
   *
   * PARAMETERS
   *   acl         the name of the ACL. Relative path will be relative to
   *               "/sys/acls". If acl is NULL, any ACL assigned to the wallet
   *               will be unassigned.
   *   wallet_path the directory path of the wallet to which the ACL will be
   *               assigned. The path is case-sensitive and of the format
   *               "file:<directory-path>". If wallet_path is null, the ACL
   *               will be unassigned from any wallet.
   * RETURN
   *   None
   * EXCEPTIONS
   *   
   */
  procedure unassign_wallet_acl(acl         in varchar2 default null,
                                wallet_path in varchar2 default null);

  /*
   * Check if a privilege is granted to or denied from the user in an
   * access control list.
   *
   * PARAMETERS
   *   acl        the name of the ACL. Relative path will be relative to
   *              "/sys/acls".
   *   aclid      the object ID of the ACL.
   *   user       the user to check against. If the user is NULL, the invoker
   *              is assumed. The username is case-sensitive as in the
   *              USERNAME column of the ALL_USERS view.
   *   privilege  the network privilege to check
   * RETURN
   *   1 when the privilege is granted; 0 when the privilege is denied;
   *   NULL when the privilege is neither granted or denied.
   * EXCEPTIONS
   *   
   */
  function check_privilege(acl       in varchar2,
                           user      in varchar2,
                           privilege in varchar2) return number; 
  function check_privilege_aclid(aclid     in raw,
                                 user      in varchar2,
                                 privilege in varchar2) return number; 

  /*
   * This procedure is for internal use. It is the pre-delete XDB event
   * handler to remove the ACL assignments when the ACL is dropped.
   */
  procedure handlePreDelete(event in DBMS_XEvent.XDBRepositoryEvent);

end;
/

grant execute on sys.dbms_network_acl_admin to dba;
grant execute on sys.dbms_network_acl_admin to xdb;

create or replace public synonym dbms_network_acl_admin
for sys.dbms_network_acl_admin;

create or replace package dbms_network_acl_utility is

  /*
   * DBMS_NETWORK_ACL_UTILITY is the PL/SQL package that provides the utility
   * functions to facilitate the evaluation of ACL assignments governing
   * TCP connections to network hosts.
   */

  -----------
  -- Types --
  -----------
  type domain_table is table of varchar2(1000);

  ----------------
  -- Exceptions --
  ----------------
  access_denied               EXCEPTION;
  PRAGMA EXCEPTION_INIT(access_denied,               -24247);
  access_denied_num           constant PLS_INTEGER := -24247;

  /*
   * For a given host, return the domains whose ACL assigned will be used to
   * determine if a user has the privilege to access the given host or not.
   * When the IP address of the host is given, return the subnets instead.
   *
   * PARAMETERS
   *   host       the network host.
   * RETURN
   *   The domains or subnets for the given host.
   * EXCEPTIONS
   *
   * NOTES
   *   This function cannot handle IPv6 addresses. Nor can it generate
   *   subnets of arbitrary number of prefix bits for an IPv4 address.
   */
  function domains(host in varchar2) return domain_table pipelined;

  /*
   * Return the domain level of the given host name, domain, or subnet.
   *
   * PARAMETERS
   *   host       the network host, domain, or subnet.
   * RETURN
   *   The domain level of the given host, domain, or subnet.
   * EXCEPTIONS
   *
   * NOTES
   *   This function cannot handle IPv6 addresses and subnets, and subnets
   *   in Classless Inter-Domain Routing (CIDR) notation.
   */
  function domain_level(host in varchar2) return number;

  /*
   * Determines if the two given hosts, domains, or subnets are equal. For
   * IP addresses and subnets, this function can handle different
   * representations of the same address or subnet. For example, an IPv6
   * representation of an IPv4 address versus its IPv4 representation.
   *
   * PARAMETERS
   *   host1      the network host, domain, or subnet to compare.
   *   host2      the network host, domain, or subnet to compare.
   * RETURN
   *   1 if the two hosts, domains, or subnets are equal. 0 when not equal.
   *   NULL when either of the hosts is NULL.
   * EXCEPTIONS
   *
   * NOTES
   *   This function does not perform domain name resolution when comparing
   * any host or domain for equality.
   */
  function equals_host(host1 in varchar2, host2 in varchar2) return number;
    pragma interface(C, equals_host);

  /*
   * Determines if the given host is equal to or contained in the given host,
   * domain, or subnet. For IP addresses and subnets, this function can handle
   * different representations of the same address or subnet. For example, an
   * IPv6 representation of an IPv4 address versus its IPv4 representation.
   *
   * PARAMETERS
   *   host       the network host.
   *   domain     the host, domain, or subnet.
   * RETURN
   *   A non-NULL value will be returned if the given host is equal to or
   *   contained in the given host, domain, or subnet:
   *     - if domain is a hostname, the level of its domain + 1 will be
   *       returned;
   *     - if domain is a domain name, the domain level will be returned;
   *     - if domain is an IP address or subnet, the number of significant
   *       address bits of the IP address or subnet will be returned;
   *     - if domain is the wildcard "*", 0 will be returned.
   *   The non-NULL value returned indicates the precedence of the domain or
   *   subnet for ACL assignment. The higher the value, the higher is the
   *   precedence. NULL will be returned if the host is not equal to or
   *   contained in the given host, domain or subnet. NULL will also be
   *   returned if either the host or domain is NULL.
   * EXCEPTIONS
   *   
   * NOTES
   *   This function does not perform domain name resolution when evaluating
   * any host or domain.
   */
  function contains_host(host in varchar2, domain in varchar2) return number;
    pragma interface(C, contains_host);

end;
/

grant execute on sys.dbms_network_acl_utility to public;

create or replace public synonym dbms_network_acl_utility
for sys.dbms_network_acl_utility;

create or replace view USER_NETWORK_ACL_PRIVILEGES
(HOST, LOWER_PORT, UPPER_PORT, PRIVILEGE, STATUS)
as
select a.host, a.lower_port, a.upper_port, p.priv,
       decode(p.status, 0, 'DENIED', 1, 'GRANTED', null)
  from net$_acl a,
       (select /*+ no_merge no_push_pred */ aclid, 'connect' priv,
               dbms_network_acl_admin.check_privilege_aclid(aclid, name,
                 'connect') status
         from (select distinct aclid from net$_acl) ac, user$
        where user# = userenv('SCHEMAID')) p
 where a.aclid = p.aclid and p.status is not null
union
select a.host, a.lower_port, a.upper_port, p.priv,
       decode(p.status, 0, 'DENIED', 1, 'GRANTED', null)
  from net$_acl a,
       (select /*+ no_merge no_push_pred */ aclid, 'resolve' priv,
               dbms_network_acl_admin.check_privilege_aclid(aclid, name,
                 'resolve') status
         from (select distinct aclid from net$_acl
                where lower_port is null and upper_port is null), user$
        where user# = userenv('SCHEMAID')) p
 where a.aclid = p.aclid and
       a.lower_port is null and a.upper_port is null and
       p.status is not null
/
grant select on USER_NETWORK_ACL_PRIVILEGES to PUBLIC
/
create or replace public synonym USER_NETWORK_ACL_PRIVILEGES
for USER_NETWORK_ACL_PRIVILEGES
/
comment on table USER_NETWORK_ACL_PRIVILEGES is
'User privileges to access network hosts through PL/SQL network utility packages'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.HOST is
'Network host'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.LOWER_PORT is
'Lower bound of the port range'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.UPPER_PORT is
'Upper bound of the port range'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.PRIVILEGE is
'Privilege'
/
comment on column USER_NETWORK_ACL_PRIVILEGES.STATUS is
'Privilege status'
/
