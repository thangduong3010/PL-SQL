Rem
Rem $Header: rdbms/admin/catxtbix.sql /st_rdbms_11.2.0/1 2010/08/05 10:57:16 juding Exp $
Rem
Rem catxtbix.sql
Rem
Rem Copyright (c) 2004, 2010, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      catxtbix.sql - XMLTableIndex related schema objects
Rem
Rem    DESCRIPTION
Rem     This script creates the views, packages, index types, operators and 
Rem     indexes required for supporting the XMLTableIndex
Rem
Rem    NOTES
Rem      This script should be run as "XDB".
Rem
Rem    MODIFIED     (MM/DD/YY)
Rem    juding       08/03/10 - Backport juding_bug-9903850 from main
Rem    thbaby       06/08/10 - add segattrs column to xdb.xdb$xtab
Rem    thbaby       02/26/10 - add depgrppos column
Rem    thbaby       02/25/10 - add grppos column to xdb$xtab
Rem    thbaby       05/21/09 - remove xtimetadata_pkg
Rem    sipatel      09/16/08 - #(7414934) - change schema from sys to xdb 
Rem    thbaby       07/30/08 - disable xmltableindex indextype
Rem    bhammers     10/30/07 - change ODCIIndexGetMetadata for imp/exp
Rem                            deactivate ODCIIndexUtilGetTableNames
Rem                            added xtimetadata_pkg package
Rem    hxzhang      03/18/08 - coltype to varchar2(100)
Rem    shvenugo     10/04/07 - partitioning
Rem    hxzhang      08/27/07 - add add/drop column 
Rem    hxzhang      05/16/07 - change xpath to varchar2(4000)
Rem    bhammers     04/19/07 - add flag for orig col type
Rem    hxzhang      06/26/06 - add group# 
Rem    hxzhang      06/06/06 - add flag column to xtabcols
Rem    rburns       05/05/06 - rename script 
Rem    hxzhang      12/14/05 - Created

declare
  exist number;
  sys_exist number;
begin
  select count(*) into exist from DBA_TABLES where table_name = 'XDB$XTAB'
  and owner = 'XDB';

  if exist = 0 then
    select count(*) into sys_exist from DBA_TABLES where table_name = 'XDB$XTAB'
    and owner = 'SYS';

    if sys_exist = 1 then
      begin
        execute immediate
          'drop library sys.xmltableindex_lib force';
      exception
        when others then null;
      end;

      begin
        execute immediate
          'drop table sys.xdb$xtab force';
      exception
        when others then null;
      end;

      begin
        execute immediate
          'drop table sys.xdb$xtabnmsp force';
      exception
        when others then null;
      end;

      begin
        execute immediate
          'drop table sys.xdb$xtabcols force';
      exception
        when others then null;
      end;
    end if;

    execute immediate
      'create table xdb.xdb$xtab (
         idxobj#    number not null,             -- object # of XMLTableIndex
         groupName  NVARCHAR2(30)  not null,     -- group name of XMLTableIndex
         xmltabobj# number not null,             -- object # of XML TABLE
         ptabobj#   number,                      -- object # of parent table
         xpath      VARCHAR2(4000) not null,    -- row source 
         xquery     clob,                       -- xquery row source 
         flags      number,
         parameters XMLType,
         grppos     number,                     -- group position
         depgrppos  number,                     -- dependent group position
         segattrs   varchar2(4000),             -- segment attributes and
                                                -- table properties
           constraint xdb$xtabpk primary key (idxobj#,groupName,xmltabobj#)) xmltype column parameters store as CLOB';
    execute immediate
      'create index xdb.xdb$idxxtab_1 on xdb.xdb$xtab(idxobj#, groupname, ptabobj#)';
    execute immediate
      'create index xdb.xdb$idxxtab_2 on xdb.xdb$xtab(idxobj#, depgrppos, xmltabobj#)';

    execute immediate
      'create table xdb.xdb$xtabnmsp (
         idxobj# number not null,           -- object # of XMLTableIndex
         groupName  NVARCHAR2(30) not null, -- group  name of XMLTableIndex
         xmltabobj# number not null,        -- object # of XMLTable
         prefix  NVARCHAR2(30),             -- namespace prefix
         namespace   NVARCHAR2(2000),       -- namespace or xpath
         flags   number not null)';         -- 0x01 NAMESPACE 
    execute immediate
      'create index xdb.xdb$idxtabnmsp_1 on xdb.xdb$xtabnmsp(idxobj#, groupname, xmltabobj#, flags)';

    execute immediate
      'create table xdb.xdb$xtabcols (
         idxobj# number not null,           -- object # of XMLTableIndex
         groupName  NVARCHAR2(30) not null, -- group  name of XMLTableIndex
         xmltabobj# number not null,        -- object # of XMLTable
         colname  NVARCHAR2(2000) not null, -- column name
         coltype  NVARCHAR2(100)   not null, -- column type
         xpath    VARCHAR2(4000) not null,  -- xpath
         flags number not null)';    -- flags 
    execute immediate
      'create index xdb.xdb$idxtabcols_1 on xdb.xdb$xtabcols(idxobj#, groupname, xmltabobj#)';
  end if;

end;
/





