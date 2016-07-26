Rem
Rem $Header: rdbms/admin/catxdbtm.sql /st_rdbms_11.2.0/3 2013/04/12 11:41:35 stirmizi Exp $
Rem
Rem catxdbtm.sql
Rem
Rem Copyright (c) 2003, 2013, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxdbtm.sql - XDB compact xml Token Manager related tables
Rem
Rem    DESCRIPTION
Rem      This script creates the tables required for XDB Compact XML
Rem      token management.         
Rem
Rem    NOTES
Rem      This script should be run as the user "XDB".
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    stirmizi    04/04/13 - backport stirmizi_lrg-8673916 from MAIN
Rem    apfwkr      01/18/13 - Backport mkandarp_bug-14572948 from main
Rem    bhammers    04/15/12 - bug 13647232, remove dupliucates in TTSET 
Rem    badeoti     03/21/09 - dbms_csx_admin.guidto32 moved to dbms_csx_int
Rem    bsthanik    05/18/07 - Bug 6054818
Rem    spetride    11/01/07 - token tables not registered for export 
Rem    spetride    01/16/07 - do not drop tables if already exist
Rem    spetride    08/10/06 - check for already existing tok tables
Rem    spetride    03/01/06 - support for multiple token repositories
Rem    nitgupta    02/07/06 - Token MGR uses VARCHAR2 columns
Rem    smukkama    11/19/04 - use even smaller token size (UTF8 ncharset)
Rem    smukkama    10/12/04 - for less than 8K blk sz use smaller token columns
Rem    smukkama    09/30/04 - move xmlidx plsql stuff to catxidx.sql
Rem    smukkama    08/13/04 - add flags column (for attr) to xdb$qname_id
Rem    smukkama    06/23/04 - Remove set echo on
Rem    athusoo     04/06/04 - Add path suffix table function 
Rem    smukkama    02/27/04 - Add reverse path index on xdb$path_id
Rem    smukkama    12/16/03 - Created
Rem

-- delete exp/imp related info
declare
  stmtdrop       varchar2(2000);
begin
  stmtdrop :=  
    'delete from sys.exppkgact$ where ( schema like ''' || 'XDB' || ''' )';
  execute immediate stmtdrop;
  stmtdrop :=
    'delete from sys.expdepact$ where ( schema like ''' || 'XDB' || ''' )';
  execute immediate stmtdrop;
  exception
       when others then
         -- we are here if this is the first time we call catxdbtm.sql
         -- no error  
         NULL;
end;
/

/*************** Create XDB.XDB$TTSET table *****************/
begin
   execute immediate 
      'create table xdb.xdb$ttset( 
          guid     raw(16), 
          toksuf   varchar(26), 
          flags    number, 
          obj#     number unique)';  
  exception
       when others then
         -- raise no error if table already exists
         NULL;
     
end;
/



--bug 13647232, remove duplicate rows (remove all but default toksuf ( flags== 0))
begin
 execute immediate 
 'delete from xdb.xdb$ttset where FLAGS != 0 AND TOKSUF in (select TOKSUF from xdb.xdb$ttset where FLAGS = 0)';
    exception
       when others then
         NULL;
end;
/
--bug 13647232,  add unique constraint
begin
   execute immediate 
        'alter table xdb.xdb$ttset
         add constraint xdb$ttset_uniq unique (toksuf)';
    exception
       when others then
         NULL;
end;
/


/************ Create Token - ID mapping tables *********************/
/* If the block size is less than 8K use smaller token sizes so
 * that index creation doesn't fail. (see bug 3928505)
 *
 * The max index key sizes for various block sizes are:
 *  2K max index key size = 1478 bytes (on Linux)
 *  4K max index key size = 3118 bytes (on Linux)
 *  8K max index key size = 6398 bytes (on Linux)
 *
 * For each of the various token column sizes below, the maximum token
 * length that would permit token-->id index creation was determined and
 * then a value 5% less (to account for any platform specific variance)
 * was picked as the token size.
 *
 */

declare
  bsz number;
  nmspc_tok_chars  number;
  qname_tok_chars  number;
  path_tok_bytes   number;
  guid             raw(16);
  guid32           varchar2(26);
  nmguid           varchar2(34);
  qnguid           varchar2(34);
  ptguid           varchar2(34); 
  qnguid2          varchar2(30);
  regstmt          varchar2(2000);
  stmt1            varchar2(2000);
  stmt2            varchar2(2000);
  stmt3            varchar2(2000);
  tabno            number;
  tsno             number;
begin
    /* figure out block size and use appropriate token size */
   select t.block_size into bsz from dba_tablespaces t, dba_users u
     where u.default_tablespace = t.tablespace_name and u.username = 'XDB';

   if bsz < 4096 then
      nmspc_tok_chars := 464;
      qname_tok_chars := 460;
      path_tok_bytes  := 1395;
   elsif bsz < 8192 then
      nmspc_tok_chars := 984;
      qname_tok_chars := 979;
      path_tok_bytes  := 2000;
   else
      nmspc_tok_chars := 2000;
      qname_tok_chars := 2000;
      path_tok_bytes  := 2000;
   end if;

    -- create the default GUID
   guid := sys_guid();
   guid32 := xdb.dbms_csx_int.guidto32(guid);
   nmguid := 'xdb.x$nm' || guid32;    -- name of the default Qname ID token table
                                  -- used to be XDB.XDB$QNAME_ID

   qnguid := 'xdb.x$qn' || guid32;    -- name of the default URI ID token table
                                  -- used to be XDB.XDB$NMSPC_ID
 
   ptguid := 'xdb.x$pt' || guid32;    -- name of the default Path Id token table  
                                  -- used to be XDB.XDB$PATH_ID

   qnguid2 := 'X$QN' || guid32;


   execute immediate                           -- Namespace URI ID Token Table
      'create table ' || nmguid || ' (
         nmspcuri varchar2(' || nmspc_tok_chars || '), 
         id        raw(8)) ';

   execute immediate                           -- QName ID Token Table
      'create table ' || qnguid || ' (
         nmspcid      raw(8),
         localname    varchar2(' || qname_tok_chars || '),
         flags        raw(4),
         id           raw(8)) ';

   execute immediate                           -- PathID Token Table
      'create table ' || ptguid || ' (
         path         raw(' || path_tok_bytes || '),
         id           raw(8)) ';
   commit;

  -- insert reserved values into default token tables 

  execute immediate 
     'insert into ' || nmguid || ' values(:1, :2)'
       using 'http://www.w3.org/XML/1998/namespace', HEXTORAW('01');
  execute immediate
     'insert into ' || nmguid || ' values(:1, :2)' 
       using 'http://www.w3.org/XML/2000/xmlns', HEXTORAW('02');
  execute immediate
      'insert into ' || nmguid || ' values(:1, :2)'
       using 'http://www.w3.org/2001/XMLSchema-instance', HEXTORAW('03');
  execute immediate 
      'insert into ' || nmguid || ' values(:1, :2)' 
       using  'http://www.w3.org/2001/XMLSchema', HEXTORAW('04');
  execute immediate 
      'insert into ' || nmguid || ' values(:1, :2)' 
       using 'http://xmlns.oracle.com/2004/csx',  HEXTORAW('05');
  execute immediate 
      'insert into ' || nmguid || ' values(:1, :2)' 
       using 'http://xmlns.oracle.com/xdb',  HEXTORAW('06');
  execute immediate
      'insert into ' || nmguid || ' values(:1, :2)' 
       using 'http://xmlns.oracle.com/xdb/nonamespace', HEXTORAW('07');
  execute immediate 
      'insert into ' || nmguid || ' values(:1, :2)' 
       using 'http://www.w3.org/2001/XInclude',  HEXTORAW('08');
  commit;

  -- START hard coded namespaces for 11.2 to 12.1 conflict avoidance
  EXECUTE IMMEDIATE
      'insert into ' || nmguid || ' values (:1, :2)'
      USING 'http://xmlns.oracle.com/xs', HEXTORAW('07CE');
  EXECUTE IMMEDIATE
      'insert into ' || nmguid || ' values (:1, :2)'
      USING 'http://xmlns.oracle.com/S', HEXTORAW('1460');
  EXECUTE IMMEDIATE
      'insert into ' || nmguid || ' values (:1, :2)'
      USING 'http://xmlns.oracle.com/plsql', HEXTORAW('223D');
  EXECUTE IMMEDIATE
      'insert into ' || nmguid || ' values (:1, :2)'
      USING 'http://www.w3.org/1999/xlink', HEXTORAW('266A');
  EXECUTE IMMEDIATE
      'insert into ' || nmguid || ' values (:1, :2)'
      USING 'http://xmlns.oracle.com/xdb/acl.xsd', HEXTORAW('35CD');
  EXECUTE IMMEDIATE
      'insert into ' || nmguid || ' values (:1, :2)'
      USING 'DAV:', HEXTORAW('5DEC');
  EXECUTE IMMEDIATE
      'insert into ' || nmguid || ' values (:1, :2)'
      USING 'http://xmlns.oracle.com/xdb/XDBResConfig.xsd', HEXTORAW('6B4C');
  EXECUTE IMMEDIATE
      'insert into ' || nmguid || ' values (:1, :2)'
      USING 'http://xmlns.oracle.com/xdb/xdbconfig.xsd', HEXTORAW('6D9F');
  COMMIT;
  -- END hard coded namespaces for 11.2 to 12.1 conflict avoidance

  execute immediate
     'insert into ' || qnguid || ' values(:1, :2, :3, :4)'
      using  HEXTORAW('01'), 'space', HEXTORAW('01'), HEXTORAW('10');
  execute immediate
     'insert into ' || qnguid || ' values(:1, :2, :3, :4)'
      using HEXTORAW('01'), 'lang', HEXTORAW('01'), HEXTORAW('11');
  execute immediate
     'insert into ' || qnguid || ' values(:1, :2, :3, :4)'
      using HEXTORAW('03'), 'type', HEXTORAW('01'), HEXTORAW('12');
  execute immediate
     'insert into ' || qnguid || ' values(:1, :2, :3, :4)'
      using HEXTORAW('03'), 'nil', HEXTORAW('01'), HEXTORAW('13');
  execute immediate
     'insert into ' || qnguid ||  ' values(:1, :2, :3, :4)'
      using HEXTORAW('03'), 'schemaLocation', HEXTORAW('01'), HEXTORAW('14');
  execute immediate
     'insert into ' || qnguid || ' values(:1, :2, :3, :4)'
      using HEXTORAW('03'), 'noNamespaceSchemaLocation', HEXTORAW('01'), HEXTORAW('15');
  execute immediate 
     'insert into ' || qnguid || ' values(:1, :2, :3, :4)'
      using HEXTORAW('02'), 'xmlns', HEXTORAW('01'), HEXTORAW('16');
  commit;

  -- START hard coded qnames for 11.2 to 12.1 conflict avoidance
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'resolve', HEXTORAW('00'), HEXTORAW('93');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'principal', HEXTORAW('00'), HEXTORAW('BB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'when', HEXTORAW('00'), HEXTORAW('BC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'authentication-implement-method', HEXTORAW('00'), HEXTORAW('014E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'principalFormat', HEXTORAW('01'), HEXTORAW('01B7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'postalCode', HEXTORAW('01'), HEXTORAW('01CC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'http2-port', HEXTORAW('00'), HEXTORAW('021C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'credential', HEXTORAW('00'), HEXTORAW('022C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'trusted-session-user', HEXTORAW('00'), HEXTORAW('026D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'default-lock-timeout', HEXTORAW('00'), HEXTORAW('0270');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'max-link-queue', HEXTORAW('00'), HEXTORAW('0286');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'expire-mapping', HEXTORAW('00'), HEXTORAW('029A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'common', HEXTORAW('00'), HEXTORAW('02D4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'title', HEXTORAW('01'), HEXTORAW('02D6');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'roomNumber', HEXTORAW('01'), HEXTORAW('02E2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'max-http-headers', HEXTORAW('00'), HEXTORAW('0305');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'update', HEXTORAW('00'), HEXTORAW('0357');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'session-state-management', HEXTORAW('00'), HEXTORAW('0365');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'acl-cache-size', HEXTORAW('00'), HEXTORAW('0384');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'street', HEXTORAW('01'), HEXTORAW('038A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'createSession', HEXTORAW('00'), HEXTORAW('0396');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'source', HEXTORAW('00'), HEXTORAW('03DA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'href', HEXTORAW('01'), HEXTORAW('03EC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'primaryKey', HEXTORAW('00'), HEXTORAW('0495');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-InconsistentUpdate', HEXTORAW('00'), HEXTORAW('04DD');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'grant', HEXTORAW('00'), HEXTORAW('04E2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'write-content', HEXTORAW('00'), HEXTORAW('04FE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'SectionConfig', HEXTORAW('00'), HEXTORAW('0551');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'display-name', HEXTORAW('00'), HEXTORAW('05AC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'ResConfig', HEXTORAW('00'), HEXTORAW('05B9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'createRoleSet', HEXTORAW('00'), HEXTORAW('05CD');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'set-invoker', HEXTORAW('01'), HEXTORAW('0608');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'execute', HEXTORAW('00'), HEXTORAW('060E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-InconsistentUpdate', HEXTORAW('00'), HEXTORAW('06B6');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'mime-mappings', HEXTORAW('00'), HEXTORAW('06C7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'LinkMetadata', HEXTORAW('00'), HEXTORAW('074A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet-class', HEXTORAW('00'), HEXTORAW('0763');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'upload-as-long-raw', HEXTORAW('00'), HEXTORAW('08A4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-LinkTo', HEXTORAW('00'), HEXTORAW('095B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'allow-authentication-trust', HEXTORAW('00'), HEXTORAW('09A4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'exception-type', HEXTORAW('00'), HEXTORAW('09C9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'securityClass', HEXTORAW('00'), HEXTORAW('0A5D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'static', HEXTORAW('01'), HEXTORAW('0AEA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'start_date', HEXTORAW('01'), HEXTORAW('0B3F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'acls', HEXTORAW('00'), HEXTORAW('0B88');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-export-paths', HEXTORAW('00'), HEXTORAW('0B8E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'protocolconfig', HEXTORAW('00'), HEXTORAW('0BB0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'max-session-use', HEXTORAW('00'), HEXTORAW('0C80');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'rewriteManually', HEXTORAW('01'), HEXTORAW('0CDD');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'viewUser', HEXTORAW('00'), HEXTORAW('0E0B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-listener', HEXTORAW('00'), HEXTORAW('0E5E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'surName', HEXTORAW('01'), HEXTORAW('0E94');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'type', HEXTORAW('01'), HEXTORAW('0EAF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'localApplicationGroupStore', HEXTORAW('00'), HEXTORAW('0ECF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'applicationData', HEXTORAW('00'), HEXTORAW('0ED8');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'shared', HEXTORAW('01'), HEXTORAW('0EE6');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nls-language', HEXTORAW('00'), HEXTORAW('0F15');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'buffer-size', HEXTORAW('00'), HEXTORAW('0F39');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'addtoSet', HEXTORAW('00'), HEXTORAW('0F52');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'modifySession', HEXTORAW('00'), HEXTORAW('0F8F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'always-describe-procedure', HEXTORAW('00'), HEXTORAW('1067');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'UnresolvedLink', HEXTORAW('01'), HEXTORAW('10AA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'physicalDeliveryOfficeName', HEXTORAW('01'), HEXTORAW('112C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'functionRole', HEXTORAW('00'), HEXTORAW('1171');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'organizationalUnit', HEXTORAW('01'), HEXTORAW('11D4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'max-request-body', HEXTORAW('00'), HEXTORAW('1253');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'mail', HEXTORAW('01'), HEXTORAW('1265');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'http-listener', HEXTORAW('00'), HEXTORAW('12DB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'resolvedpath', HEXTORAW('00'), HEXTORAW('130A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'viewRole', HEXTORAW('00'), HEXTORAW('1336');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'custom-authentication-trust', HEXTORAW('00'), HEXTORAW('13D8');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'aggregatePrivilege', HEXTORAW('00'), HEXTORAW('13F1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'trust-scheme', HEXTORAW('00'), HEXTORAW('13FA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'errnum', HEXTORAW('00'), HEXTORAW('1414');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'viewRoleset', HEXTORAW('00'), HEXTORAW('1477');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'write-acl', HEXTORAW('00'), HEXTORAW('14BF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'OracleError', HEXTORAW('00'), HEXTORAW('14C1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'link-to', HEXTORAW('00'), HEXTORAW('1511');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'secretary', HEXTORAW('01'), HEXTORAW('1519');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'session-cookie-name', HEXTORAW('00'), HEXTORAW('154F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('02'), 'xsi', HEXTORAW('01'), HEXTORAW('15A5');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'security-class', HEXTORAW('00'), HEXTORAW('15DD');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'owa-debug-enable', HEXTORAW('00'), HEXTORAW('1621');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('1460'), 'OlapPrivileges', HEXTORAW('00'), HEXTORAW('16AF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'sectionPath', HEXTORAW('00'), HEXTORAW('16D2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'xdbcore-loadableunit-size', HEXTORAW('00'), HEXTORAW('1731');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'targetNamespace', HEXTORAW('01'), HEXTORAW('1737');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'resource-view-cache-size', HEXTORAW('00'), HEXTORAW('1749');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'attributeSecs', HEXTORAW('00'), HEXTORAW('1780');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('1460'), 'insert', HEXTORAW('00'), HEXTORAW('17E3');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'selectPrivilege', HEXTORAW('00'), HEXTORAW('184B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet', HEXTORAW('00'), HEXTORAW('1898');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'secClassNumber', HEXTORAW('01'), HEXTORAW('18C0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'roleGrant', HEXTORAW('00'), HEXTORAW('193F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'default-type-mappings', HEXTORAW('00'), HEXTORAW('19E3');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'createRole', HEXTORAW('00'), HEXTORAW('1A47');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'lang', HEXTORAW('01'), HEXTORAW('1A57');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-client-subnet', HEXTORAW('00'), HEXTORAW('1A70');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'userName', HEXTORAW('00'), HEXTORAW('1A86');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'DistinguishedName', HEXTORAW('01'), HEXTORAW('1ABB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet-schema', HEXTORAW('00'), HEXTORAW('1B87');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'init-param', HEXTORAW('00'), HEXTORAW('1C03');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('266A'), 'type', HEXTORAW('01'), HEXTORAW('1CA2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'read-current-user-privilege-set', HEXTORAW('00'), HEXTORAW('1CD7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'termSession', HEXTORAW('00'), HEXTORAW('1CFF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'xdbcore-logfile-path', HEXTORAW('00'), HEXTORAW('1D09');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'preferredLanguage', HEXTORAW('01'), HEXTORAW('1D27');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'non-folder-hard-links', HEXTORAW('00'), HEXTORAW('1E3A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet-mappings', HEXTORAW('00'), HEXTORAW('1F3A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'max-requests-per-session', HEXTORAW('00'), HEXTORAW('1F93');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'database-username', HEXTORAW('00'), HEXTORAW('2050');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet-pattern', HEXTORAW('00'), HEXTORAW('207E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'labeledURI', HEXTORAW('01'), HEXTORAW('20E9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'privNumber', HEXTORAW('01'), HEXTORAW('2131');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'jsp-file', HEXTORAW('00'), HEXTORAW('216B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'configuration', HEXTORAW('00'), HEXTORAW('2188');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'event-listeners', HEXTORAW('00'), HEXTORAW('21BD');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'welcome-file', HEXTORAW('00'), HEXTORAW('21E1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-VersionControl', HEXTORAW('00'), HEXTORAW('21F2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'scope', HEXTORAW('01'), HEXTORAW('22AA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'request-validation-function', HEXTORAW('00'), HEXTORAW('2346');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'commonName', HEXTORAW('01'), HEXTORAW('239B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'elementNum', HEXTORAW('00'), HEXTORAW('2423');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'xml-extensions', HEXTORAW('00'), HEXTORAW('2448');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'welcome-file-list', HEXTORAW('00'), HEXTORAW('2467');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'allowRegistration', HEXTORAW('00'), HEXTORAW('2472');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'email', HEXTORAW('01'), HEXTORAW('247F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'invert', HEXTORAW('00'), HEXTORAW('2483');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'userPKCS12', HEXTORAW('01'), HEXTORAW('24AA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'privilege', HEXTORAW('00'), HEXTORAW('24AC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'functionName', HEXTORAW('00'), HEXTORAW('25B6');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'allow-mechanism', HEXTORAW('00'), HEXTORAW('261E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'user', HEXTORAW('01'), HEXTORAW('262D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'charset-mapping', HEXTORAW('00'), HEXTORAW('263A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'employeeType', HEXTORAW('01'), HEXTORAW('2677');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'read-acl', HEXTORAW('00'), HEXTORAW('2692');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'realm', HEXTORAW('00'), HEXTORAW('2748');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'fetch-buffer-size', HEXTORAW('00'), HEXTORAW('2793');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'authentication-pattern', HEXTORAW('00'), HEXTORAW('2894');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'aclDirectory', HEXTORAW('00'), HEXTORAW('2897');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'defaultChildACL', HEXTORAW('00'), HEXTORAW('28CF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'role-link', HEXTORAW('00'), HEXTORAW('28E8');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-client-netmask', HEXTORAW('00'), HEXTORAW('2952');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'systemPrivileges', HEXTORAW('00'), HEXTORAW('295F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'exclusion-list', HEXTORAW('00'), HEXTORAW('2969');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'element', HEXTORAW('00'), HEXTORAW('29BB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'attachToSession', HEXTORAW('00'), HEXTORAW('29CE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'copy-on-inconsistent-update', HEXTORAW('01'), HEXTORAW('2AB1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'tableSpace', HEXTORAW('00'), HEXTORAW('2AC4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'privilegeName', HEXTORAW('00'), HEXTORAW('2B0E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'http-host', HEXTORAW('00'), HEXTORAW('2B35');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet-language', HEXTORAW('00'), HEXTORAW('2B46');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'postalAddress', HEXTORAW('01'), HEXTORAW('2C38');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'all', HEXTORAW('00'), HEXTORAW('2CF5');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'bind-bucket-lengths', HEXTORAW('00'), HEXTORAW('2DE5');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'custom-authentication-mapping', HEXTORAW('00'), HEXTORAW('2E61');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-UncheckOut', HEXTORAW('00'), HEXTORAW('2E71');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Render', HEXTORAW('00'), HEXTORAW('2EDF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'givenName', HEXTORAW('01'), HEXTORAW('2F0C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'justification', HEXTORAW('01'), HEXTORAW('2F91');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'encoding', HEXTORAW('00'), HEXTORAW('2FDF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'description', HEXTORAW('00'), HEXTORAW('2FE2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'encoding-mappings', HEXTORAW('00'), HEXTORAW('3033');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'http-port', HEXTORAW('00'), HEXTORAW('304C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet-list', HEXTORAW('00'), HEXTORAW('30A1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'schemaLocation-mappings', HEXTORAW('00'), HEXTORAW('3141');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'num_job_queue_processes', HEXTORAW('00'), HEXTORAW('3158');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'xsProvision', HEXTORAW('00'), HEXTORAW('315B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'compatibility-mode', HEXTORAW('00'), HEXTORAW('3175');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'http-protocol', HEXTORAW('00'), HEXTORAW('3222');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'on-deny', HEXTORAW('00'), HEXTORAW('3230');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'extend', HEXTORAW('00'), HEXTORAW('3284');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'postOfficeBox', HEXTORAW('01'), HEXTORAW('3360');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'error-style', HEXTORAW('00'), HEXTORAW('3369');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-Update', HEXTORAW('00'), HEXTORAW('3394');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'x121Address', HEXTORAW('01'), HEXTORAW('33C3');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-LinkIn', HEXTORAW('00'), HEXTORAW('33C5');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-CheckOut', HEXTORAW('00'), HEXTORAW('33F3');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'externalSource', HEXTORAW('00'), HEXTORAW('3444');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'description', HEXTORAW('01'), HEXTORAW('3476');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'error-code', HEXTORAW('00'), HEXTORAW('3492');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Section', HEXTORAW('00'), HEXTORAW('3493');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('1460'), 'select', HEXTORAW('00'), HEXTORAW('349B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'custom-authentication', HEXTORAW('00'), HEXTORAW('34BA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'authentication-description', HEXTORAW('00'), HEXTORAW('3559');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'grant', HEXTORAW('00'), HEXTORAW('355B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'destinationIndicator', HEXTORAW('01'), HEXTORAW('3589');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'admin', HEXTORAW('00'), HEXTORAW('359A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'xdbconfig', HEXTORAW('00'), HEXTORAW('35BE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'default-url-charset', HEXTORAW('00'), HEXTORAW('3616');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-UnlinkIn', HEXTORAW('00'), HEXTORAW('3663');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-UnlinkFrom', HEXTORAW('00'), HEXTORAW('3686');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'logfile-path', HEXTORAW('00'), HEXTORAW('36BC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'KerberosPrincipalName', HEXTORAW('01'), HEXTORAW('372B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'pre-condition', HEXTORAW('00'), HEXTORAW('3796');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'inheritedFrom', HEXTORAW('00'), HEXTORAW('37A7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'setAttribute', HEXTORAW('00'), HEXTORAW('37AF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-Lock', HEXTORAW('00'), HEXTORAW('381F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'lock', HEXTORAW('00'), HEXTORAW('388B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'end_date', HEXTORAW('01'), HEXTORAW('3899');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'packageName', HEXTORAW('00'), HEXTORAW('3989');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'userCertificate', HEXTORAW('01'), HEXTORAW('39B5');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-Open', HEXTORAW('00'), HEXTORAW('39BC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-LinkIn', HEXTORAW('00'), HEXTORAW('39DB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'role-name', HEXTORAW('00'), HEXTORAW('3A13');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-client-dnsname', HEXTORAW('00'), HEXTORAW('3A6B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'oid', HEXTORAW('00'), HEXTORAW('3AFD');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'defaultAcl', HEXTORAW('00'), HEXTORAW('3B56');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'foreignKey', HEXTORAW('00'), HEXTORAW('3B67');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'authentication-implement-schema', HEXTORAW('00'), HEXTORAW('3B7A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'write-properties', HEXTORAW('00'), HEXTORAW('3BA7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'title', HEXTORAW('00'), HEXTORAW('3BE0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-client-address', HEXTORAW('00'), HEXTORAW('3C53');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('1460'), 'delete', HEXTORAW('00'), HEXTORAW('3CBE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'documentPath', HEXTORAW('00'), HEXTORAW('3CEE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'schema', HEXTORAW('00'), HEXTORAW('3CFB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'unlink-from', HEXTORAW('00'), HEXTORAW('3DC0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'XPath', HEXTORAW('00'), HEXTORAW('3E07');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'inherits-from', HEXTORAW('00'), HEXTORAW('3F23');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'host-name', HEXTORAW('00'), HEXTORAW('3F7A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'parentSchemaName', HEXTORAW('00'), HEXTORAW('3FBB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'ftp-listener', HEXTORAW('00'), HEXTORAW('4035');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'description', HEXTORAW('00'), HEXTORAW('4039');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet-realm', HEXTORAW('00'), HEXTORAW('405D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'param-name', HEXTORAW('00'), HEXTORAW('40D1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'expire-default', HEXTORAW('00'), HEXTORAW('418B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'log-level', HEXTORAW('00'), HEXTORAW('41CC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'ace', HEXTORAW('00'), HEXTORAW('41E1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-exports', HEXTORAW('00'), HEXTORAW('41EF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'parentObjectName', HEXTORAW('00'), HEXTORAW('4200');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'failedlogins', HEXTORAW('00'), HEXTORAW('4201');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-Create', HEXTORAW('00'), HEXTORAW('4211');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-Lock', HEXTORAW('00'), HEXTORAW('42B6');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'facility', HEXTORAW('00'), HEXTORAW('42C7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'mime-mapping', HEXTORAW('00'), HEXTORAW('42F7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'max-parameters', HEXTORAW('00'), HEXTORAW('42FA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'rollback-on-sync-error', HEXTORAW('00'), HEXTORAW('432D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'privilegeRef', HEXTORAW('00'), HEXTORAW('4353');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'read-contents', HEXTORAW('00'), HEXTORAW('43FB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'carLicense', HEXTORAW('01'), HEXTORAW('441B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'enable', HEXTORAW('00'), HEXTORAW('44BF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'departmentNumber', HEXTORAW('01'), HEXTORAW('450A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'baseDav', HEXTORAW('00'), HEXTORAW('4593');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'plsql', HEXTORAW('00'), HEXTORAW('45B6');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'state', HEXTORAW('01'), HEXTORAW('45C1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'server-name', HEXTORAW('00'), HEXTORAW('462B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'lang-mappings', HEXTORAW('00'), HEXTORAW('4649');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'lang', HEXTORAW('00'), HEXTORAW('472A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'homePostalAddress', HEXTORAW('01'), HEXTORAW('47A5');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'schemaURL', HEXTORAW('00'), HEXTORAW('47B2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'document-procedure', HEXTORAW('00'), HEXTORAW('48E1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'PrincipalSecurityClass', HEXTORAW('00'), HEXTORAW('490B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'call-timeout', HEXTORAW('00'), HEXTORAW('499B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'attribute', HEXTORAW('00'), HEXTORAW('4A97');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'homePhone', HEXTORAW('01'), HEXTORAW('4A9E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'take-ownership', HEXTORAW('00'), HEXTORAW('4B00');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'write', HEXTORAW('00'), HEXTORAW('4B02');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'default-language', HEXTORAW('01'), HEXTORAW('4BF9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'trust-scheme-description', HEXTORAW('00'), HEXTORAW('4C17');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'instanceSet', HEXTORAW('00'), HEXTORAW('4C3F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'location', HEXTORAW('00'), HEXTORAW('4C4E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'read', HEXTORAW('00'), HEXTORAW('4C8A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'listener', HEXTORAW('00'), HEXTORAW('4CA9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'displayName', HEXTORAW('01'), HEXTORAW('4CC0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'colName', HEXTORAW('00'), HEXTORAW('4CEC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'constrained-with', HEXTORAW('00'), HEXTORAW('4D31');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'schema', HEXTORAW('00'), HEXTORAW('4D8A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'administerAttributes', HEXTORAW('00'), HEXTORAW('4D8C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-LinkTo', HEXTORAW('00'), HEXTORAW('4EB6');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-client', HEXTORAW('00'), HEXTORAW('4F1B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'security-role-ref', HEXTORAW('00'), HEXTORAW('4F23');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'after-procedure', HEXTORAW('00'), HEXTORAW('4FD4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-export-path', HEXTORAW('00'), HEXTORAW('4FE3');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'load-on-startup', HEXTORAW('00'), HEXTORAW('4FF7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'flags', HEXTORAW('00'), HEXTORAW('5028');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'registeredAddress', HEXTORAW('01'), HEXTORAW('5051');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'x500uniqueIdentifier', HEXTORAW('01'), HEXTORAW('507D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-Create', HEXTORAW('00'), HEXTORAW('50D4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'transfer-mode', HEXTORAW('00'), HEXTORAW('50DB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'link', HEXTORAW('00'), HEXTORAW('50E7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'ftpconfig', HEXTORAW('00'), HEXTORAW('51AA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'switchUser', HEXTORAW('00'), HEXTORAW('5256');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'trust-scheme-name', HEXTORAW('00'), HEXTORAW('52E0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'before-procedure', HEXTORAW('00'), HEXTORAW('5306');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'owner', HEXTORAW('00'), HEXTORAW('5313');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'employeeNumber', HEXTORAW('01'), HEXTORAW('5334');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'readAttribute', HEXTORAW('00'), HEXTORAW('534B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'mime-type', HEXTORAW('00'), HEXTORAW('543F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'xdbcore-xobmem-bound', HEXTORAW('00'), HEXTORAW('547D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'info-logging', HEXTORAW('00'), HEXTORAW('548C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'preferredDeliveryMethod', HEXTORAW('01'), HEXTORAW('5519');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'administerNamespace', HEXTORAW('00'), HEXTORAW('551C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'case-sensitive', HEXTORAW('00'), HEXTORAW('551E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-Update', HEXTORAW('00'), HEXTORAW('55A9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'ftp-port', HEXTORAW('00'), HEXTORAW('55AE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'user-prefix', HEXTORAW('00'), HEXTORAW('55C1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-clientgroup', HEXTORAW('00'), HEXTORAW('5672');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'default-workspace', HEXTORAW('00'), HEXTORAW('56C0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'userconfig', HEXTORAW('00'), HEXTORAW('56F4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'ContentFormat', HEXTORAW('00'), HEXTORAW('5778');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'path', HEXTORAW('00'), HEXTORAW('57A9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'expire-pattern', HEXTORAW('00'), HEXTORAW('57E0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'unbind', HEXTORAW('00'), HEXTORAW('5817');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'update-acl', HEXTORAW('00'), HEXTORAW('586C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-export', HEXTORAW('00'), HEXTORAW('587F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'httpconfig', HEXTORAW('00'), HEXTORAW('58EB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'namespace', HEXTORAW('00'), HEXTORAW('58EC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-Delete', HEXTORAW('00'), HEXTORAW('58F7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'lang-mapping', HEXTORAW('00'), HEXTORAW('5941');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'UID', HEXTORAW('00'), HEXTORAW('5959');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'custom-authentication-mappings', HEXTORAW('00'), HEXTORAW('596A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'respond-with-server-info', HEXTORAW('00'), HEXTORAW('59CE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'manager', HEXTORAW('01'), HEXTORAW('5A2F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'read-acl', HEXTORAW('00'), HEXTORAW('5A5F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'document-path', HEXTORAW('00'), HEXTORAW('5A84');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'ftp-welcome-message', HEXTORAW('00'), HEXTORAW('5A86');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'createUser', HEXTORAW('00'), HEXTORAW('5ADE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('02'), 'dav', HEXTORAW('01'), HEXTORAW('5B00');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'path-alias-procedure', HEXTORAW('00'), HEXTORAW('5BA2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-Unlock', HEXTORAW('00'), HEXTORAW('5BBA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'sysconfig', HEXTORAW('00'), HEXTORAW('5BBE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'facsimileTelephoneNumber', HEXTORAW('01'), HEXTORAW('5BF0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'rewriteMinACL', HEXTORAW('01'), HEXTORAW('5D62');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'aclFiles', HEXTORAW('00'), HEXTORAW('5E1F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('06'), 'srclang', HEXTORAW('01'), HEXTORAW('5E24');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'ACL', HEXTORAW('00'), HEXTORAW('5E40');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'principal', HEXTORAW('00'), HEXTORAW('5E5D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'bind-bucket-widths', HEXTORAW('00'), HEXTORAW('5F0C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'folder-hard-links', HEXTORAW('00'), HEXTORAW('5F37');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'error-pages', HEXTORAW('00'), HEXTORAW('5F44');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'write-config', HEXTORAW('00'), HEXTORAW('5F85');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'effectiveDates', HEXTORAW('00'), HEXTORAW('5FA1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'acl-max-age', HEXTORAW('00'), HEXTORAW('5FBE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'name', HEXTORAW('00'), HEXTORAW('5FF4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'database-edition', HEXTORAW('00'), HEXTORAW('6001');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'grantTo', HEXTORAW('00'), HEXTORAW('6061');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'copy-on-inconsistent-update', HEXTORAW('00'), HEXTORAW('607E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'authentication-implement-language', HEXTORAW('00'), HEXTORAW('6094');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'invalid-pathname-chars', HEXTORAW('00'), HEXTORAW('60BC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'namespace', HEXTORAW('00'), HEXTORAW('60C3');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'assignUser', HEXTORAW('00'), HEXTORAW('60F4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'elementName', HEXTORAW('00'), HEXTORAW('6141');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'error-page', HEXTORAW('00'), HEXTORAW('617E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'attributeSec', HEXTORAW('00'), HEXTORAW('61C1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'authentication', HEXTORAW('00'), HEXTORAW('61DA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'existsNode', HEXTORAW('00'), HEXTORAW('61EE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'baseSystemPrivileges', HEXTORAW('00'), HEXTORAW('626A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'profile', HEXTORAW('00'), HEXTORAW('627E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfsconfig', HEXTORAW('00'), HEXTORAW('62C8');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'name', HEXTORAW('01'), HEXTORAW('62EE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'XIncludeConfig', HEXTORAW('00'), HEXTORAW('635A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'encoding-mapping', HEXTORAW('00'), HEXTORAW('6381');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-Open', HEXTORAW('00'), HEXTORAW('63B6');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'read-properties', HEXTORAW('00'), HEXTORAW('6406');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-port', HEXTORAW('00'), HEXTORAW('6475');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet-mapping', HEXTORAW('00'), HEXTORAW('649B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'privilege', HEXTORAW('00'), HEXTORAW('64AC');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-Unlock', HEXTORAW('00'), HEXTORAW('6556');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('266A'), 'href', HEXTORAW('01'), HEXTORAW('6588');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'authentication-trust-name', HEXTORAW('00'), HEXTORAW('658E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'events', HEXTORAW('00'), HEXTORAW('65B0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'document-table-name', HEXTORAW('00'), HEXTORAW('6657');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'seeAlso', HEXTORAW('01'), HEXTORAW('6717');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('1460'), 'update', HEXTORAW('00'), HEXTORAW('6747');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'digest-auth', HEXTORAW('00'), HEXTORAW('67B6');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'persistent-sessions', HEXTORAW('00'), HEXTORAW('67D1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'unlink', HEXTORAW('00'), HEXTORAW('6814');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-UncheckOut', HEXTORAW('00'), HEXTORAW('6826');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'extension-mappings', HEXTORAW('00'), HEXTORAW('68F1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'requireParsingSchema', HEXTORAW('00'), HEXTORAW('691F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'session-pool-size', HEXTORAW('00'), HEXTORAW('6951');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'expire', HEXTORAW('00'), HEXTORAW('696D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'param-value', HEXTORAW('00'), HEXTORAW('69A9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'description', HEXTORAW('00'), HEXTORAW('69E1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'acl-evaluation-method', HEXTORAW('00'), HEXTORAW('6A10');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'unlock', HEXTORAW('00'), HEXTORAW('6A2B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'default-schema', HEXTORAW('01'), HEXTORAW('6ABA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-CheckIn', HEXTORAW('00'), HEXTORAW('6AC8');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'all', HEXTORAW('00'), HEXTORAW('6AD2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'principalID', HEXTORAW('00'), HEXTORAW('6B2E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'userSMIMECertificate', HEXTORAW('01'), HEXTORAW('6B48');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'memberEvaluationRule', HEXTORAW('00'), HEXTORAW('6B57');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'paramDatatype', HEXTORAW('00'), HEXTORAW('6BCD');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'write-acl-ref', HEXTORAW('00'), HEXTORAW('6BD7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'icon', HEXTORAW('00'), HEXTORAW('6C3F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'GUID', HEXTORAW('00'), HEXTORAW('6C40');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'trusted-parsing-schema', HEXTORAW('00'), HEXTORAW('6C6E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'XSAllSecurityClass', HEXTORAW('00'), HEXTORAW('6D67');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'telexNumber', HEXTORAW('01'), HEXTORAW('6DCF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'mutable', HEXTORAW('01'), HEXTORAW('6DD4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'proxyUser', HEXTORAW('00'), HEXTORAW('6E11');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'language', HEXTORAW('00'), HEXTORAW('6E4E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'system', HEXTORAW('01'), HEXTORAW('6E5A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'duration', HEXTORAW('00'), HEXTORAW('6E60');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'proxyRole', HEXTORAW('00'), HEXTORAW('6E7F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'DataSecurity', HEXTORAW('00'), HEXTORAW('6ECB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-UnlinkIn', HEXTORAW('00'), HEXTORAW('6EDF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'enable', HEXTORAW('01'), HEXTORAW('6EF0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'path-alias', HEXTORAW('00'), HEXTORAW('6F32');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'ConflictRule', HEXTORAW('00'), HEXTORAW('6F67');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'charset', HEXTORAW('00'), HEXTORAW('6F6B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-VersionControl', HEXTORAW('00'), HEXTORAW('6F81');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-CheckIn', HEXTORAW('00'), HEXTORAW('6F9A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'path', HEXTORAW('00'), HEXTORAW('7025');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'srclang', HEXTORAW('01'), HEXTORAW('7050');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'authentication-name', HEXTORAW('00'), HEXTORAW('7059');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'audio', HEXTORAW('01'), HEXTORAW('7063');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nfs-protocol', HEXTORAW('00'), HEXTORAW('70A4');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'instanceSets', HEXTORAW('00'), HEXTORAW('70E5');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'mobile', HEXTORAW('01'), HEXTORAW('70ED');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'principalString', HEXTORAW('00'), HEXTORAW('70F2');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'telephoneNumber', HEXTORAW('01'), HEXTORAW('70F7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'aclFile', HEXTORAW('00'), HEXTORAW('7119');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servletconfig', HEXTORAW('00'), HEXTORAW('711B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'user', HEXTORAW('00'), HEXTORAW('7120');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'role', HEXTORAW('00'), HEXTORAW('712B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'LinkType', HEXTORAW('00'), HEXTORAW('7161');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'param', HEXTORAW('00'), HEXTORAW('7176');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'PathFormat', HEXTORAW('00'), HEXTORAW('71EE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-Delete', HEXTORAW('00'), HEXTORAW('7218');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Post-UnlinkFrom', HEXTORAW('00'), HEXTORAW('722C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'dav', HEXTORAW('00'), HEXTORAW('7233');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'createTermSession', HEXTORAW('00'), HEXTORAW('727A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'businessCategory', HEXTORAW('01'), HEXTORAW('7283');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'input-filter-enable', HEXTORAW('00'), HEXTORAW('72CF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'collection', HEXTORAW('01'), HEXTORAW('72E1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'organization', HEXTORAW('01'), HEXTORAW('72EA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('5DEC'), 'bind', HEXTORAW('00'), HEXTORAW('7300');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'dynamicRole', HEXTORAW('00'), HEXTORAW('73C9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'session-timeout', HEXTORAW('00'), HEXTORAW('73EF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'locality', HEXTORAW('01'), HEXTORAW('7448');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'case-sensitive-index-clause', HEXTORAW('00'), HEXTORAW('74AB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'nonce-timeout', HEXTORAW('00'), HEXTORAW('74C9');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'max-header-size', HEXTORAW('00'), HEXTORAW('74DF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'http2-protocol', HEXTORAW('00'), HEXTORAW('7535');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'extends-from', HEXTORAW('00'), HEXTORAW('7546');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'servlet-name', HEXTORAW('00'), HEXTORAW('756C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'user_status', HEXTORAW('01'), HEXTORAW('759B');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'xsCallback', HEXTORAW('00'), HEXTORAW('75F1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'cgi-environment-list', HEXTORAW('00'), HEXTORAW('770E');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'extension', HEXTORAW('00'), HEXTORAW('7747');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'jpegPhoto', HEXTORAW('01'), HEXTORAW('778C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'schemaURL', HEXTORAW('00'), HEXTORAW('77D7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'pager', HEXTORAW('01'), HEXTORAW('7807');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'ftp-protocol', HEXTORAW('00'), HEXTORAW('7810');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'colValue', HEXTORAW('00'), HEXTORAW('7858');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'xdbcore-log-level', HEXTORAW('00'), HEXTORAW('793C');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'allow-repository-anonymous-access', HEXTORAW('00'), HEXTORAW('7969');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'custom-authentication-list', HEXTORAW('00'), HEXTORAW('7983');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'defaultChildConfig', HEXTORAW('00'), HEXTORAW('799A');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'acl', HEXTORAW('00'), HEXTORAW('7A0F');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'mode', HEXTORAW('00'), HEXTORAW('7AB1');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'http2-host', HEXTORAW('00'), HEXTORAW('7ADA');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'webappconfig', HEXTORAW('00'), HEXTORAW('7B49');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'XLinkConfig', HEXTORAW('00'), HEXTORAW('7BB5');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6B4C'), 'Pre-CheckOut', HEXTORAW('00'), HEXTORAW('7BC0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'schemaLocation-mapping', HEXTORAW('00'), HEXTORAW('7BEB');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'administerSession', HEXTORAW('00'), HEXTORAW('7C20');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'changeUserPassword', HEXTORAW('00'), HEXTORAW('7CAF');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'authentication-mode', HEXTORAW('00'), HEXTORAW('7D37');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'photo', HEXTORAW('01'), HEXTORAW('7DA0');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'charset-mappings', HEXTORAW('00'), HEXTORAW('7E48');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('6D9F'), 'default-page', HEXTORAW('00'), HEXTORAW('7E5D');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'teletexTerminalIdentifier', HEXTORAW('01'), HEXTORAW('7EA7');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'internationaliSDNNumber', HEXTORAW('01'), HEXTORAW('7EDD');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07'), 'initials', HEXTORAW('01'), HEXTORAW('7F36');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('07CE'), 'proxyTo', HEXTORAW('00'), HEXTORAW('7FBE');
  EXECUTE IMMEDIATE
      'insert into ' || qnguid || ' values (:1, :2, :3, :4)'
      USING HEXTORAW('35CD'), 'schemaOID', HEXTORAW('00'), HEXTORAW('7FE4');
  -- END hard coded qnames for 11.2 to 12.1 conflict avoidance
 
  -- create Indexes on default token tables 

   -- used to be called xdb.xdb$nmspc_id_nmspcuri
  execute immediate
    'create unique index xdb.x$nn' || guid32 || ' on ' ||  nmguid || '(nmspcuri)';
   --used to be called xdb.xdb$nmspc_id_id
  execute immediate
    'create unique index xdb.x$ni' || guid32 || ' on ' || nmguid || '(id) ';
 
   --used to be called xdb.xdb$qname_id_nmspcid
  execute immediate
    'create index xdb.x$qs' || guid32 || ' on ' || qnguid || ' (nmspcid) ';
   --used to be called xdb.xdb$qname_id_qname
  execute immediate
    'create unique index xdb.x$qq' || guid32 || '  on ' || qnguid || 
    '(nmspcid, localname, flags) ';
  --used to be called xdb.xdb$qname_id_id
  execute immediate 
    'create unique index xdb.x$qi' || guid32  || ' on ' || qnguid || '(id) ';

  --used to be called xdb.xdb$path_id_path
  execute immediate
    'create unique index xdb.x$pp' || guid32 || ' on ' || ptguid || '(path) ';
  --used to be called xdb.xdb$path_id_id
  execute immediate
    'create unique index xdb.x$pi' || guid32 || ' on ' || ptguid || '(id) ';
  --used to be called xdb.xdb$path_id_revpath
  execute immediate
    'create unique index xdb.x$pr' || guid32 || ' on ' || ptguid || 
    '(SYS_PATH_REVERSE(path)) ';
  commit;

   -- add entry to XDB.XDB$TTSET
   stmt1 := 'select o.obj# from sys.obj$ o, sys.user$ u where (u.name = ''' || 
            'XDB' || ''') and (o.name = ''' || qnguid2 || 
            ''') and (o.owner# = u.user#)'; 
   execute immediate stmt1 into tabno;
   stmt2 := 'select t.ts# from dba_tables x, sys.ts$ t where (x.table_name = ''' || 
            qnguid2 || ''')  and (x.owner = ''' || 'XDB' || 
            ''') and (x.tablespace_name = t.name)';
   execute immediate stmt2 into tsno;  

   insert into xdb.xdb$ttset values (guid, guid32, 0, tsno);

  -- register DBMS_XDB_EXP_RULES for export
  begin
    stmt1 := 'insert into sys.exppkgact$ values(:1, :2, 3, 2006)';
    execute immediate stmt1 using 'DBMS_CSX_ADMIN', 'XDB';
  end;
  commit;


  exception
       when others then
         -- 1. raise no error if tables/indexes already exist
         -- 2. still need to register the  DBMS_XDB_EXP_RULES for export
         begin
          stmt1 := 'insert into sys.exppkgact$ values(:1, :2, 3, 2006)';
          execute immediate stmt1 using 'DBMS_CSX_ADMIN', 'XDB';           
         exception
           when others then
             NULL;
         end;
         NULL;
end;
/



