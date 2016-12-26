create or replace package xdb.xdb$acl_pkg_int wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
d3 fb
59oBLkvGtJDKlRQZlFcOp+ca3P8wgy5KAJkVZy+iO7vqfjjzmMqfJjzZ1FaHPAsgrqCeP6nj
Zm9v+c+35i11yY/tWOM/8NWs/jpXAG65c06fKWTQnGp+YrGPA8X0ga334Um4YdA2+iG4wi18
cTmsLh26w5pR/23pk6cDlyqTNAhgPxhNVkHvQDbyp1w/7IX34Zk9qsMYXYiE0CKOhHCxAlIj
MwFsv9nuCS5ggy10qzON7yYK+lvU6Xt+

/
create or replace package body xdb.xdb$acl_pkg_int wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
2a1 21b
eEG83VPR26q23S26Ms9tN/BUfJswg2PMTK4VfI6BWA9ShFlhbFNrCL1qhCnRg7QNLgW9emLn
XvThOW9qcsTNqREGEyj4fQDBaBJyJmbS92jvX5Ei1mqbOsC8zk0img8KPegpfB2kqVI+TQEJ
pmINYDjVY1gOWfNIZ4xiDaYLKhfUrOCerbZ1hNVEUPGMykQVtrPSN30TzmGau0m/y3buALZi
2R52MtOA5XZSYIxnzsyWsvxXrSvGCR0DVKm3xjmtCf2L3VTZ4UdHGjnwUv3qvCfTjwnlDuSz
s3haAD9+GGYoNJjcmL98i6hbRoOtOYzIZRXV5kKKHHVvaP+OG7B8opNfaYRKbzKvRtkCzJzG
Js29LHRVLMHBFOE/9cfN2JOItDsLIFaWvSDQt1t351cyO/DIrZIqIy8BubnCklB3E0P5/AHE
TIAAV4M548se0Nc/tBD27HI1pwJeRVWtoZDRYR5HVe2xsAdzwv1sfPXaU3UFEfl2IQ93MSdO
XLvstfA6lFO1boT+ZG0geXs7sw==

/
grant execute on xdb.xdb$acl_pkg_int to public;
declare
  lev     BINARY_INTEGER;
  newlvls varchar2(20);
  lvls    varchar2(20);
BEGIN
  dbms_system.read_ev(31150, lev);
  lvls := '0x' || 
           ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0');

  
  newlvls := '0x' ||
      ltrim(to_char(rawtohex(utl_raw.bit_or(
                               utl_raw.cast_from_binary_integer(lev),
                               utl_raw.cast_from_binary_integer(4)))), '0');

  execute immediate 
    'alter session set events ''31150 trace name context forever, level ' || 
    newlvls || ''' ';

  dbms_output.put_line('event 31150: old level = ' || lvls || ', new = ' || newlvls);
end;
/
DECLARE
 lev BINARY_INTEGER;
BEGIN
  dbms_system.read_ev(31150, lev);
  dbms_output.put_line('0x' ||
      ltrim(to_char(rawtohex(utl_raw.cast_from_binary_integer(lev))),'0'));
END;
/
declare
  cur integer;
  rc  integer;
begin
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur,
     'create index xdb.xdb$acl_xidx on xdb.xdb$acl(object_value) '||
     'indextype is xdb.xmlindex '||
     'parameters(''PATH TABLE XDBACL_PATH_TAB VALUE INDEX XDBACL_PATH_TAB_VALUE_IDX'') ',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
end;
/
declare
  cur integer;
  rc  integer;
begin
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur,
     'create index xdb.xdb$acl_spidx on xdb.xdb$acl(xdb.xdb$acl_pkg_int.special_acl(object_value), object_id)',
    dbms_sql.native);
  rc := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
end;
/
