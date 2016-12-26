drop view xdb.xdb$resource_view;
drop view xdb.xdb$rv;
declare
 ct number;
begin
  select count(*) into ct from dba_indexes where owner = 'XDB' and 
    index_name = 'XDBHI_IDX';
  if ct > 0 then
    execute immediate 'disassociate statistics from ' ||
                      'indextypes xdb.xdbhi_idxtyp force';
    execute immediate 'disassociate statistics from ' ||
                      'packages xdb.xdb_funcimpl force';
    execute immediate 'drop index xdb.xdbhi_idx';
  end if;
end;
/
drop indextype xdb.xdbhi_idxtyp force;
drop operator xdb.path force;
drop operator xdb.depth force;
drop operator xdb.abspath force;
drop operator xdb.under_path force;
drop operator xdb.equals_path force;
drop package xdb.xdb_ancop;
drop package xdb.xdb_funcimpl;
drop type xdb.xdbhi_im force;
drop type xdb.path_array force;
drop type xdb.path_linkinfo force;
create or replace library xdb.resource_view_lib wrapped 
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
16
2d 65
V0UuJ00QMqKMoi9SSbjg22OFCnwwg04I9Z7AdBjDFvJi/5Zi8tzwltlZYtBy+lkJ572esstS
Msy4dCvny1J0CPVhyaamCwvLuA==

/
create or replace library xdb.path_view_lib wrapped 
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
16
29 5d
e4p07e2zDC/glqq04OxpO3TUJTswg04I9Z7AdBjDFlpW+uOW2Vli0HL6WQnnvZ6yy1IyzLh0
K+fLUnQI9WHJpqaknnQN

/
create or replace type xdb.path_linkinfo OID '00000000000000000000000000020117' wrapped 
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
d
79 aa
g0V6zG8egE2xYLkdFQIyNY27Wowwg5n0dLhcFlpW+uNy+kfZ/0cM2cHAdCulv5vAMsvuJY8J
aee4dAhpqal8xsoXKMbK77KEHe+2RC9eXltNFTFq68aVcrOxlKEC9yaI5jWpC8gKD1o0nbBt
5sgLU0BrWBucGx2mqUqkyQ==

/
create or replace type xdb.path_array OID '00000000000000000000000000020154'
as varray(32000) of xdb.path_linkinfo
/
show errors;
grant execute on xdb.path_linkinfo to public;
grant execute on xdb.path_array to public;
create or replace type xdb.xdbhi_im OID '00000000000000000000000000020118' wrapped 
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
d
b6a 353
lDJslGdXRJYMNHRBXxviC442370wg80r2tAFfHS5bg81aF2m1PuxJmdJ6cnglGFdWsMctzcG
QBlQ7SSdieQnBsZsv4j2ykvpJSz60E+O677mzk6STrG6czMSRMp6Q8UdKTvpLg2/ETVXfBMs
Fj7upkkCp/XhvNhXG5o8KcVUocjxS4GKXmDW+hqDqD4uEcTmUdailJfzBK6P/7mtNiEOrzQ5
bV07Oc3ZsoOTWmOCeqFtrHzMUVsYyWPEGwLytCWvNVRYmfgqTDU0aSyScD+HalwiVFkWnrng
f08lLS0eoJnq29gulIIyXF8efje5cEkD6OwmgasQKkCHG+bepx3XDrqnLq6m0nQRehyi8w9X
jUQtaNQCaD0sb1fac/SrWfcAIZ1kZQgx5HhSwP71tK9qUjjHYSN6ARMX+UPlK0N88SklLj26
1W2TC2gKGVP+EXKzg+5Xwnfqi+P7RelAlENz5dOJx4pGVxkxp3l1wGnn7U7gB8o1bdPuPjOj
xhlBDmn91YqtYfaziCBsPFsCxuwAYoXMUuklpUL1UUveiAJ4yiwMTGI7IH1KQjRUfCZY8axf
spASrUbF9zkJF3PoGNL/kv7FZQAeKKKwslUQR2fgcLxDqqWf/6f4OOdE/KRDaiPk8oJ67z1D
IcY3ei1gYQMCxOuKLTwp7zbkynP/2b9WtC1psMuLBdKSmw9L0JSKgDJU4DBBUO5voYv0YYt9
Iy6l+rnRIoe0L7xxRWGntQnmUIlW4Oi60C0B6fXAEWMpS7To13lAnLQPg2jik7JV6NfNg4HL
Bb8JYpmGL/HQLR8PP1YStbjEZ0xdjxzTKx67D/nhjaAlYw==

/
show errors;
create or replace type body xdb.xdbhi_im wrapped 
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
e
598 1ea
vzxqgyC6VezCpDAswhivE4aANskwg2O3ACDWfC9A2k7VSB0UiagLzFvGvBrq8/0xgOxZ9+XL
11DtJJ35yFHIpmuytm47Ek8HAzpQZthfe91ywcaxKTCS/4U1OY9UfKFUv6NliLJgoYPKt8mg
9qizlHfIC3yk1tpT6VR4CniJdpcBEftw99oKNb8FlKNa8OpTqJCnXgfBnDc56Z3DXfnaZMoo
bCWe/tk0Vh7ZyEtm8J80uJDSz9HYUSvEXTLfBh/9DG2sLcpS6BgBJfZeNdWKPK/cVDrFisIY
Ok2/wTv57TTCb7E8A2uWuOj36YY9G/QQnwTDLM+b9ADQ6PChoWNFXKR1wrgQVTHof1Kjw5Pr
SjD/Z06UI34EqKrsyKCE2e9fp3c95yG8u6K2/rnEsvjZVFXaroRvA0TTGZBPX7JKh6lB5p54
8JKMhMPOsDVRE999o2yLiF+eR4hH3e6q21bMsViWPK6dE6XJSg==

/
show errors;
grant execute on xdb.xdbhi_im to public;
create or replace package XDB.XDB_FUNCIMPL wrapped 
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
29c 11f
uWG4peqUXpc5hxCiVwZLyLK8Sgowg9fxr54VfHRAAPiOrcWONWTaPd/irzsK3mZOd/6qmZgt
beMdr9YCXS/55PqA7NiYg2840sHAs31NrqRUjWccbmULiVGIiBYg+xsCUC81jIDR+vJ1mJ9f
iJvvLNS8t4DmHRy3NuODT/eyWRVWdL/Z0VQiiE3JLCwxMfalSk3/iJBfOcDXZ/M5jd4xhPBn
ApIyCs8pgwFtED1/GMBxntefAn3OStKk25Y+vN3dE4NIzXyqDDezneQVyU42QcdYuA==

/
show errors;
grant execute on XDB.XDB_FUNCIMPL to public ; 
create or replace package xdb.xdb_ancop wrapped 
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
87e 160
Fjxc+LYCpqtxloJcyFg6+wpjIPEwgz2NLUoVfHRAWEKe0MpcdMRlvqEOPGPeQ1NQ3D1Vf8df
eiJ59y+E+/uE5hqiwnZz+XZzwPLDmlPfuGhzYST4nbUdDgc+3eXA8k24aVGReSwNXZHonpm8
CG17xCWJG/t58vrdXEInV4jREji0ygp0OtUpY2Bv7g4JEeldoCaNd73OuTbAacPhDdwfVf9N
YzTZ2IqSCYS2HYafGT4D9xhVY4PAidp6Tv1N7u5Axp55qVL3W2FXF0ghto3VQRSy10A81HyU
h2Xpln/d74LfeAUYlxyWgoCEWJLQKkd9aTRIFvm1QyJ5yiKG0sDA4Roa8/8=

/
show errors;
grant execute on xdb.xdb_ancop to public ; 
alter type xdb.xdbhi_im compile;
