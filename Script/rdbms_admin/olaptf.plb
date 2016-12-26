CREATE or REPLACE TYPE OLAP_SRF_T wrapped 
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
43 81
W5k4+sqVQjtqncAgNbc3AtqGS2swg0SvLbKpfHQ2ZyfozmUxpvSXNu9n41QsumeNc8SP/yRe
dwzYeEhVqO74LVE2JsT+EfJahEzcYkoh4ZKr172Xt+huwe5bz6nzjQ==

/
show errors;
create or replace function OLAP_NUMBER_SRF wrapped 
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
2bc 16d
Oj7mmngM285kcSCagjqo7gx/3NYwg43Mf0hqfHSKbuovWNMOfcgNtmLZy/sTZRblnxsgMUUh
FlDB6uJ3V9HTDjwUpNB3COKefol21vZL/a2gAo2zDA231vvgL4pPeKW1CwdIJxKEf4CJauWH
5qVJtQbyhNtjpF/LCpLvqpIFRC4F2ypgTCqv6i6y+kZzYNg57uQ2m0Jp1nFb2GJ1dHxhb2EP
nNnGWCSaxJ0hxTZDNgGzkvP4f7zHY0kArFLYn1B0MhZS46MImApoR3WBrvRXhG2iCfJsiMNJ
gnpjLyaHAlOHFb+0RsT+WPstJHX9RG1n8QXQTSTcYL367STOpLIxisaNHthxtJ0iEB1n5PDT


/
show errors;
drop public synonym OLAP_EXPRESSION;
create or replace operator OLAP_EXPRESSION binding(raw, VARCHAR2) 
  return NUMBER with index context, scan context OLAP_SRF_T 
    using OLAP_NUMBER_SRF;
/
show errors;
create or replace function OLAP_TEXT_SRF wrapped 
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
2b1 16d
70kmwpx0RASbTQbtdBq3/Fxxaj4wg43MNUhqyi+KrWRUQ4laXCi+M6DUtJP6OfaTJ8HbOygR
I4VOHTc8Uo1aKkkEyXCf6AhgvZMdYWqo40EUV0ifz2lnOQTGsbLkvyneWlEokTKiIthp06za
vni61WZeHqH6oOakMSkPHmyu81vnwua77OJEhvjyTj9qo3pyhKa+m2kH6IG0J2lEfLT2tIf/
wWSuvs8gqhHDf5u9/OW/+8YvckPJFK2swhsCcQ77rSJm7FW5sUg4R/leHyuzUW1ori6elZt0
sDlmPb233pylHd/ucz/JZ3cSMsFwzIDc+IiBpwGgyIbk1iSlaQY/P7cXPn35c0OeC7JtNQ==


/
show errors;
drop public synonym OLAP_EXPRESSION_TEXT;
create or replace operator OLAP_EXPRESSION_TEXT binding(raw, VARCHAR2) 
  return VARCHAR2 with index context, scan context OLAP_SRF_T 
    using OLAP_TEXT_SRF;
/
show errors;
create or replace function OLAP_DATE_SRF wrapped 
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
2ae 171
qU07zN++f797FIJH1S2VArdsWgUwg43MNUhqyi+KrWRUQ4laXCi+M6A5itiR1g1WDcfm7dL7
LstCP2voMnFsCde9QFgBdSbWXOb/rPYt0KuVonKBSiieheGGpTQ3tdGCM5PSQNhKhQeU8ual
SbUGoGbCg1/y1JT82/+7RcrrliVbUdhQ+EV53UDiZTSaS/fdb8DTZ7x03rPf+/0d5aZv2h0F
HjrkOmualgUsq1xfz+FMMiIGL+u+aHQUgGn/GIhjZwDAq2ZAc7mxJzhHGcco3LNRByb9Lp6V
CHTB0rY9mbd5p6Wk3+7NP8lnJVsyhnDMlYnS7/y/SvoVjkMs5EoH04GGEyHV/mmPcx7rH7ya
9JI=

/
show errors;
drop public synonym OLAP_EXPRESSION_DATE;
create or replace operator OLAP_EXPRESSION_DATE binding(raw, VARCHAR2) 
  return DATE with index context, scan context OLAP_SRF_T 
    using OLAP_DATE_SRF;
/
show errors;
create or replace function OLAP_BOOL_SRF wrapped 
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
2b3 171
IUHcfGQH0hI18+PO3szP3Ms/qOwwg43Mf0hqfHSKbuovWNMOfcgNti7Zy/u6ZRblnxt5kJ42
EacincA71FL3pg0bKTCApEJcSxqKVlM5mFRXsaKWPdzLNn41S6oZ3arQiEXM0kDmgIlqnmzv
zreqUmx/BSV0GmqeMuDQtUUO647eqU3V0rwnJ0trYl+KeOAh49eucE8FIREeqQ37l6mVPN0z
HsA6z5b/wdDNltCZNa01k6Ai4Czr2uojPO/IAyc512kH8UVN852YRddfMfkEAu+Hon+VXmVr
e1juf6migcV+HmzPB9cwEk+IyNI3SHZWJXWnc+OSA5eROKOaLORKBzTNxo32ZHG0nSIQHepu
bbM=

/
show errors;
drop public synonym OLAP_EXPRESSION_BOOL;
create or replace operator OLAP_EXPRESSION_BOOL binding(raw, VARCHAR2) 
  return NUMBER with index context, scan context OLAP_SRF_T 
    using OLAP_BOOL_SRF;
/
show errors;
drop type body OLAPImpl_t;
create or replace type OLAPImpl_t wrapped 
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
8f be
EIRG/2mT9NgI9iSPGvYFDdiol58wg+nw7Z4VfI5gkE6Ov341bpncePoCYSGhviQR6DSprNa7
0CbLQQjPLHY72jUxuA9BZIASHez/DEZwR4kNWC8dno6dCWl4V6ZY9z5hDr+m1AV88MFItz6S
8LySICqnmi3vXNF1CjOPf/Qbee31yGJC4HiHrixLge/+

/
show errors;
create or replace type OLAPRanCurImpl_t wrapped 
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
e6b 31e
yDCAintbN1duA04z97r7oq3bd78wg0OnLtDrfC9Arf7qXzOJ8ue93FpudheDdS6KfEFQzT7F
CmbIb1QN6QbBgkjE9T7/xrnyPStdL2xB0LSCch51wZSs1cPpbbuSwZfPmO3e3w4n/y45RRvm
2S7N92dCuCkSd3ryYKYi6kaTjDqeqXdWQto/PowB18ViuNrPBENHzXZDm8e18jGt2RfWPpHg
lWBqGmHs8AOPZXlhk2XS7FkY9FedOepOUri1Y43/Lb7brbRFWfc5YL5R0Xle5Z4ixSXCJXgL
46LTwC5v5RV41GXc92bcCWHmMd476Od74JZZ8hiLyGNjIHfY9/7jnFxsFZVkgYuCKX6+vIcQ
c6A0487XdMFlqljXlIBHjWah21oc8czPKQVQMJDmLINi+BcLgoyUmKfgLKPhj6Ap/NkQsbzY
B6cC2EH6tN6d9q48mDkMxwKG0cPV5j5iGyJwHFpVxfKT88g+ClHuNY+I2lLABbCyT72E1uAk
cYPo4J7uZjQ1qK3l/Gt/0NPDWa5ygNw9J0KYVJCHLjeNn9kkJ9POTTxivoN/MWU9p9UGqjPs
VZn7n8d5RPgoc1ud+ebkDaiibbFF6eM3MMQ1NvQkSNAOWAdzWbVevpLX4A2t9i1BPSxpqR4J
swgswttLdef5tpGQSRxt+ralxF2RItOq6gP7q8jvCoC8qiNHjtWI/HuzkHb8+sDHc0PSaQx4
g2Id3hmBGgeGTB9FfmrQ4PPHKBJFuBwoiqRSeD9gdn0TLB5DQsBQVQ6zzlVtmhvjR3o=

/
show errors;
create or replace function OLAP_TABLE wrapped 
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
2e0 fb
7jmelfCSxeI0bGSpSqSYB0kCLl0wg2MlLp4VZ3REcLFBZgxE89idj8WQ6Kuh6zgb7/U9+Jrm
5Qk1Tee3Lm9CLDE0eyaCSJSjNZr9p+ZtrTTGY/GPElQP+EqvTH+OCn8Zp3jAPLrB3nvLlD11
22e3hcYrEbR4faq87EsVsgWpeIhhhUsFdJjZS/h0EoVLxnQSkrHRONs3VkQCtJUqJ3jDbPHw
sb4XrhXylBqFI0IrWP2W7ZAXKPz1EzA=

/
show errors;
create or replace function CUBE_TABLE wrapped 
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
7f a2
QzUf5JyTzy3etZxTULoHHpFaVQgwg0wYf8upynSmkELpgEx2cZCew3msAmd/OJu1nXxgho9i
nHFIJgaJjKkKp9zp/U14pcB4zmqbzt2K30frpc1YoMk3JZfjJXrFbwkL00meVl1rb6eU4N3b
Ep6w/1VExmt2zw==

/
show errors;
create or replace function OLAPRC_TABLE wrapped 
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
ab be
RqkrMY7nDPwJ5Nr/xKo0z1X0CiYwg3lKf8sVfHSmWPie0MqoOSsbsSp3JwaiSvCJPrW16Qdm
r91ixGi4cmnAPp5sOCqrSscGTjYs595DLVIHLKIo9l1YzZLwDBjY7wtztp2zEemYD920ao6j
IHh3vA4LC0/lw9xRNGchs7EI1vI48far+VfNwt1Jtw==

/
show errors;
CREATE OR REPLACE PUBLIC SYNONYM OLAP_TABLE FOR SYS.OLAP_TABLE
/
GRANT EXECUTE ON SYS.OLAP_TABLE TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM CUBE_TABLE FOR SYS.CUBE_TABLE
/
GRANT EXECUTE ON SYS.CUBE_TABLE TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAPRC_TABLE FOR SYS.OLAPRC_TABLE
/
GRANT EXECUTE ON SYS.OLAPRC_TABLE TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAP_SRF_T FOR SYS.OLAP_SRF_T
/
GRANT EXECUTE ON SYS.OLAP_SRF_T TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAP_NUMBER_SRF FOR SYS.OLAP_NUMBER_SRF
/
GRANT EXECUTE ON SYS.OLAP_NUMBER_SRF TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAP_EXPRESSION FOR SYS.OLAP_EXPRESSION
/
GRANT EXECUTE ON SYS.OLAP_EXPRESSION TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAP_TEXT_SRF FOR SYS.OLAP_TEXT_SRF
/
GRANT EXECUTE ON SYS.OLAP_TEXT_SRF TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAP_EXPRESSION_TEXT 
  FOR SYS.OLAP_EXPRESSION_TEXT
/
GRANT EXECUTE ON SYS.OLAP_EXPRESSION_TEXT TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAP_DATE_SRF FOR SYS.OLAP_DATE_SRF
/
GRANT EXECUTE ON SYS.OLAP_DATE_SRF TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAP_EXPRESSION_DATE 
  FOR SYS.OLAP_EXPRESSION_DATE
/
GRANT EXECUTE ON SYS.OLAP_EXPRESSION_DATE TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAP_BOOL_SRF FOR SYS.OLAP_BOOL_SRF
/
GRANT EXECUTE ON SYS.OLAP_BOOL_SRF TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM OLAP_EXPRESSION_BOOL 
  FOR SYS.OLAP_EXPRESSION_BOOL
/
GRANT EXECUTE ON SYS.OLAP_EXPRESSION_BOOL TO PUBLIC
/
CREATE OR REPLACE FUNCTION OLAP_CONDITION wrapped 
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
116 e7
QZvPnONnf/RjJgThAJS7SLHyKXEwg41Kr8usZ3SiALvq0ue9HKnbL3gclwkNvY4Jn7MF+bUP
Uwr0I2PE3PjJi6vbQkFEi/OcfcmIzu1vDvAdb2nPwzmfXxNAR3lNuUqDitbe7wiInHyBGri8
Z7JjzJs1nWbi+oI9bTRgvYZ1S7CMbP5hKcIWGRvk3vcCEAj+D68tADJMuqPr6/BsmBDhJ/Za
ORIw+6Guew0=

/
SHOW ERRORS;
GRANT EXECUTE ON OLAP_CONDITION TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM OLAP_CONDITION FOR SYS.OLAP_CONDITION
/
