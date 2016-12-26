begin
  execute immediate 
     'create or replace type exf$xpposlst is VARRAY(100) of NUMBER';
exception 
  when others then 
    if (SQLCODE = -02303) then null;
    else raise; 
    end if; 
end;
/
grant execute on exf$xpposlst to public;
begin
  execute immediate 
   'create or replace type exf$xpvarclst is VARRAY(100) of VARCHAR2(500)';
exception 
  when others then 
    if (SQLCODE = -02303) then null;
    else raise; 
    end if; 
end;
/
grant execute on exf$xpvarclst to public;
begin
  execute immediate
    'create or replace type exf$xpnumblst is VARRAY(100) of NUMBER';
exception 
  when others then 
    if (SQLCODE = -02303) then null;
    else raise; 
    end if;
end;
/
grant execute on exf$xpnumblst to public;
begin
  execute immediate
    'create or replace type exf$xpdatelst is VARRAY(100) of DATE';
exception
  when others then
    if (SQLCODE = -02303) then null;
    else raise;
    end if;
end;
/
grant execute on exf$xpdatelst to public;
begin
  execute immediate
    'create or replace type exf$xptaginfo as object (
  tag_name  VARCHAR2(70), 
  type      NUMBER, 
  poslst    exf$xpposlst, 
  varclst   exf$xpvarclst, 
  numblst   exf$xpnumblst, 
  datelst   exf$xpdatelst)';
exception
  when others then
    if (SQLCODE = -02303) then null;
    else raise;
    end if;
end;
/
show errors;
grant execute on exf$xptaginfo to public;
create or replace type exf$xptagsinfo as VARRAY(490) of exf$xptaginfo;
/
grant execute on exf$xptagsinfo to public;
create or replace procedure getDummyTags wrapped 
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
7
2a1 1b6
YuZVYftwLil1ExIS3vUBXgMnHR0wg43M2q5qfC/J/2RXvUCispQ4GvyP25zfFi07Ax25hal7
MuE5+QDBgCxZiVkzwZi7lIRFhK22FflzXj+ky5q5ebX7Q8rtJabW4SquYglM3T1PuEp3jp8P
NjK6NdAq5AtV9PDKnh4jn6m8nU5Af9pNh+rKVl4ygpMuUCr6fbMLCSImK3y0FH5S2//766Wp
6SAnUyB1xRG+kDV9oa7Mly+XfCG9HWS6FEfU8AuoVSKaFatRGmnT5CFgYNTxwhv0Ns3R1bLA
XHZOXzEUejvuOFygU+6p5IMHdsdfBSomM24L5XB3g47B3Kd9pOVaI+gBvM9xIZyWAWAKfFIn
f4lUwhmbwm24ci7kCE+20LOfoOLY/M8oArXh5nc2cYTGAgtu4qyqywTHZBgvgYtbe3N1Zg==


/
show errors;
create or replace procedure getTagsArrOCI wrapped 
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
7
fd 10f
c9A+2zqAsllp4PRqwdLj7GqnpNYwg+lKLcsVfC+EWE6Ub+AOCRsr6PbsYfclGkWHqFnj+y0f
+Q8UYtMTQwMQIF0RfoIDlR4698YeLtnT8GqzKj6id9EvmrnR481W9hamFBU43QK00ttJ8CHO
G6sELPaya0p17uEGVksmABp/EreZedhnt5dBVMtdjcX2NzltEP9VmGJTluK/KsHGY5aT1XGQ
0nx/xxTMBPTHYnJZV6fOuw5th6+BLPWN/QbFeGcC/DT44flaIus=

/
show errors;
create or replace function getTagsArray wrapped 
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
8
1fb 164
A8F09Tn5X0iKStlGgIWdqKVwZhgwg/DIfyBqyi8C2k7VSIVwDCtASumkfG6kFFdm3fcAyU3C
sEybuxI2sDvYyzhnfblV+Bl/WRoDsjac0GTPvM/lHoHP1tTsWOFQXRJfpE1u70JXJk0oxbyf
4UEAA78bEVoMg06CloB+RKJHXhTdQrTXxtjUkd7nDtMFwAyVU3nt7SDFLtWT2NY1yXeJY93n
HyNQz6GzhhH0bZ+pyfA4tm2Q9qgsyI+8leMxWRmWlb5Ic1TEumpozH3TGDJrrI+iPcdyOQK/
CeJAkvtvMSTdsPd0bGrJm/cDfb6IoFXcXINPKcA/wR6dp5Zk4T5T7w+8+5eLMBU=

/
show errors;
grant execute on getTagsArray to public;
create or replace function v02c wrapped 
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
8
177 144
5h3HxZ34VZ0T3wTJvp1eWLrmfXUwgzJpmNwdfy8avGR14T4ivWvv9VQ+dgMbp26B+tBeexjk
hOX4MDzcZza9eJjaHkK04sJiImXR6zN0Q4ZZvfXA0LBCSq1dZWbMJvQtdZEoG3nuTqk5BlsJ
ZOshJzV5Lq0btB9NleT3KSGtWOEx4f2EAJvB4OZsU47QFsks55fscasFXRL7f7TrB8ETOgXL
cYRQ1kfiQjw2cuAQEGrjL4ZopO3WJ3RP2guirS8PA8/VvTo6v8pVsY5lVZr2AUx4rhMycwcV
uwaxkjwN5wCPzZljfTVvku6Zpk6j5Q==

/
show errors;
create or replace function v12c wrapped 
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
8
17a 140
KjxyReZiZcPi+QfU9KDfw2GN3nUwgzJpmEgdqC9ZEA9/6RTH8ZQx3B9d4bdsYBW4o49d0en5
qD0Qz1SKomFjUIq5Vk6m6oxiIunPIL8PaSIu2w4DEiKuAzj9wIivw8WAhc8hNNZyHTbbLBqH
eBPMeHcr//Q4xGkDQncpNJ9lRMJE3wIjGE8DvY2PV5BpR6gviSq+51VdWwLJUg4oLGQzIBLb
q6wcg4rbDWXPfoucF1/nPi5VJdoWOM5oiO+X9wZsR2QJ751oGyUQLqjrcwA+2cKjZKdDLPLP
ID8lDEnzI90eSWFRB2FQriSZybqT

/
show errors;
create or replace function v22c wrapped 
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
8
17a 144
8NOhu3fjggBuVPv2cY0yZuvyBvEwgzJpmEgdqC9ZEA9/6RTH8ZQxnNGFRICnBPS63HrcuXHO
LHFVxltLC2yn5gOYA0cdWcmQ2BdxB+7hOHNZ+/VlZLBYTiFFdSM28q18b5TSzAL7359NyhzI
MJrNI5NpkITS+yMoLU0XkNTVSfHvkA7t2bZPH0NlrzYkqCaz80Yrf1xFGK6eleAaltm/+NAd
V9pJmGUT/OwdVh9OBYIjV7vByd6yogG0tAQAJffOb4uAJsiaP0nxeS7RJZoSDdgeyZiTsaoW
5JPkJw+Yq2tENKrgPsLVmTqbssrWun4=

/
show errors;
create or replace function v32c wrapped 
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
8
17a 144
xVCEq9GqK+j4crR44NIiSZUV6s8wgzLImEjhfy/pXrvqaGbThz4Y5/UtFl+IWwzJNJsL6Zxm
tcgnJCILhC81GBNCOv++YQp+bdBfu82LmZfG9NN9ikFy66+Onr5fWsMn4EcbMYyh/c56DipS
9ibNIwAnKYPswFlLIGkDQmjrMsBlRMJE30AjBnIxRvK4PkFpRyIviSq+Ib76KP02LbAocurk
+MtxhFDWd+LM9qwXNw9Bf2bbVzIav2ku7sfqXxaABm1Ymi5mP+2/GvhUS9L+h5nZwiOTYtkk
0yLnZENi9m9Frx5J8lDWdNLrKJq1un8=

/
show errors;
create or replace procedure exf$xpdumptagsinfo wrapped 
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
7
2a4 19d
HpezcZhzLKbNBzVWxgW/rlDSRyswgwLx2SfWZ45AmDM+/2YO0WYuRW317gFW+5CI9Yn1bOYu
L/wCJ8pELLwXw03eGBwEV5y1tTmLdChYhGhXFMia/xO6TlJiE9GYoOky4jW2PLo2XV153HHo
gPx/pNha+7hNpqtb370u2LjO1bfFXi29G6mC0ALWqwqkBEB3YEBq4H46X1LDX/lqHnwlaQoT
hLEN1hYBLY8tfKUa+ffTUHfNemfNEvXS7Z6/cztFprPD90ypyQHLhHYURJZ4pRp3noXl6s94
KBm/vIqGMrr16UyvF7OfjJZCGdqb97L/ZiTTklEk+rzdJlB7TrsbquAC/8Wph9lb3T/hhUzi
4WjY2Ww4yzBYpuJshZ6Pu7n59FL2RkVqmnyUR0ewLIzgZP8=

/
grant execute on exf$xpdumptagsinfo to public;
