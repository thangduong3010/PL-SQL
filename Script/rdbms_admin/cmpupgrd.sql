Rem
Rem $Header: rdbms/admin/cmpupgrd.sql /st_rdbms_11.2.0/1 2011/01/18 07:53:36 spetride Exp $
Rem
Rem cmpupgrd.sql
Rem
Rem Copyright (c) 2006, 2011, Oracle and/or its affiliates. 
Rem All rights reserved. 
Rem
Rem    NAME
Rem      cmpupgrd.sql - CoMPonent UPGRaDe script
Rem
Rem    DESCRIPTION
Rem      This script upgrades the components in the database
Rem
Rem    NOTES
Rem      
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    spetride    01/11/11 - Backport badeoti_bug-10096889 from main
Rem    badeoti     05/07/10 - disable xdk schema caching for inserts into csx
Rem                           tables during migrations
Rem    rburns      05/22/06 - parallel upgrade 
Rem    rburns      05/22/06 - Created
Rem

--CATCTL -S
@@cmpupstr.sql

-- Java upgrade and non-Java/nonXDB dependent upgrades in parallel
--CATCTL -M
@@cmpupjav.sql
@@cmpupnjv.sql

-- set xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context forever, level 0x8000';

-- XDB upgrade and Java-only dependents in parallel
--CATCTL -M
@@cmpupxdb.sql
@@cmpupnxb.sql

-- Both  XDB and Java dependents
--CATCTL -M

-- check status of xdb schema cache event
set serveroutput on
declare
  lev     BINARY_INTEGER;
  newlvls varchar2(20);
BEGIN
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
  -- set level 0x8000 
  newlvls := '0x' ||
      ltrim(to_char(rawtohex(utl_raw.bit_or(
                                utl_raw.cast_from_binary_integer(lev),
                                utl_raw.cast_from_binary_integer(32768)))), '0');
  -- make sure event is set
  execute immediate
    'alter session set events ''31150 trace name context forever, level ' ||
    newlvls || ''' ';
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
end;
/

set serveroutput off

-- additionally, trace any further lxs-0002x errors 
alter session set events '31061 trace name errorstack level 3, forever';

@@cmpupord.sql

-- check status of xdb schema cache event
set serveroutput on
declare
  lev     BINARY_INTEGER;
  newlvls varchar2(20);
BEGIN
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
  -- set level 0x8000 
  newlvls := '0x' ||
      ltrim(to_char(rawtohex(utl_raw.bit_or(
                                utl_raw.cast_from_binary_integer(lev),
                                utl_raw.cast_from_binary_integer(32768)))), '0');
  -- make sure event is set
  execute immediate
    'alter session set events ''31150 trace name context forever, level ' ||
    newlvls || ''' ';
  dbms_system.read_ev(31150, lev);
  if (lev > 0) then
    dbms_output.put_line('event 31150 set to level ' || '0x' ||
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
  else
    dbms_output.put_line('event 31150 NOT SET!');
  end if;
end;
/

set serveroutput off

-- additionally, trace any further lxs-0002x errors 
alter session set events '31061 trace name errorstack level 3, forever';

@@cmpupmsc.sql

-- clear xdk schema cache event
ALTER SESSION SET EVENTS='31150 trace name context off';

-- Final component actions
--CATCTL -S
@@cmpupend.sql


