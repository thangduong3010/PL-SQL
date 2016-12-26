create or replace package wmsys.owm_vt_pkg wrapped 
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
54e 168
+tanpMmHQaI1bThUQoeNGjjSPVIwg+3rLSdqfC85j/9CGP225wL11/WFF4B3Igq/sEDcq9pG
JctjEHPF0fsL5mlbMvMlvfm1Hbr7Ve+fNruaICkeghBuh/uMpM8d0Rgvuhjy4Yfq1anfwoIk
ZXYHISK30gT1pJ86TZYjTwc329DXbxVqwGH7qG0VjzFN2fT4bh82mPtO8OwwF6FNY2gpWrED
QGJ2vlg8ToebRTGWKsHDzOz/qpRii0TCQrr04iDPBTwXLipsHDos0GibVlpIkYRylKqwDISo
EcrCGOw+vMglt+WkyB7e0bICDtznTplN9uyNjsJ9PuAPCBNziw/GL8EfUv4dn3x+PQ==

/
declare
  dep_operator  EXCEPTION;
  PRAGMA        EXCEPTION_INIT(dep_operator, -29809);
begin
  begin
    execute immediate 'create or replace operator wmsys.wm_overlaps binding (wmsys.wm_period, wmsys.wm_period) return integer using wmsys.owm_vt_pkg.wm_overlaps' ;
  exception when dep_operator then
    null ;
  end;

  begin
    execute immediate 'create or replace operator wmsys.wm_intersection binding (wmsys.wm_period, wmsys.wm_period) return wmsys.wm_period using wmsys.owm_vt_pkg.wm_intersection' ;
  exception when dep_operator then
    null ;
  end;

  begin
    execute immediate 'create or replace operator wmsys.wm_ldiff binding (wmsys.wm_period, wmsys.wm_period) return wmsys.wm_period using wmsys.owm_vt_pkg.wm_ldiff' ;
  exception when dep_operator then
    null ;
  end;

  begin
    execute immediate 'create or replace operator wmsys.wm_rdiff binding (wmsys.wm_period, wmsys.wm_period) return wmsys.wm_period using wmsys.owm_vt_pkg.wm_rdiff' ;
  exception when dep_operator then
    null ;
  end;

  begin
    execute immediate 'create or replace operator wmsys.wm_contains binding (wmsys.wm_period, wmsys.wm_period) return integer using wmsys.owm_vt_pkg.wm_contains' ;
  exception when dep_operator then
    null ;
  end;

  begin
    execute immediate 'create or replace operator wmsys.wm_meets binding (wmsys.wm_period, wmsys.wm_period) return integer using wmsys.owm_vt_pkg.wm_meets' ;
  exception when dep_operator then
    null ;
  end;

  begin
    execute immediate 'create or replace operator wmsys.wm_lessthan binding (wmsys.wm_period, wmsys.wm_period) return integer using wmsys.owm_vt_pkg.wm_lessthan' ;
  exception when dep_operator then
    null ;
  end;

  begin
    execute immediate 'create or replace operator wmsys.wm_greaterthan binding (wmsys.wm_period, wmsys.wm_period) return integer using wmsys.owm_vt_pkg.wm_greaterthan' ;
  exception when dep_operator then
    null ;
  end;

  begin
    execute immediate 'create or replace operator wmsys.wm_equals binding (wmsys.wm_period, wmsys.wm_period) return integer using wmsys.owm_vt_pkg.wm_equals' ;
  exception when dep_operator then
    null ;
  end;
end;
/
grant execute on wmsys.wm_overlaps to public ;
grant execute on wmsys.wm_intersection to public ;
grant execute on wmsys.wm_ldiff to public ;
grant execute on wmsys.wm_rdiff to public ;
grant execute on wmsys.wm_contains to public ;
grant execute on wmsys.wm_meets to public ;
grant execute on wmsys.wm_lessthan to public ;
grant execute on wmsys.wm_greaterthan to public ;
grant execute on wmsys.wm_equals to public ;
create or replace public synonym wm_overlaps for wmsys.wm_overlaps ;
create or replace public synonym wm_intersection for wmsys.wm_intersection ;
create or replace public synonym wm_ldiff for wmsys.wm_ldiff ;
create or replace public synonym wm_rdiff for wmsys.wm_rdiff ;
create or replace public synonym wm_contains for wmsys.wm_contains ;
create or replace public synonym wm_meets for wmsys.wm_meets ;
create or replace public synonym wm_lessthan for wmsys.wm_lessthan ;
create or replace public synonym wm_greaterthan for wmsys.wm_greaterthan ;
create or replace public synonym wm_equals for wmsys.wm_equals ;
