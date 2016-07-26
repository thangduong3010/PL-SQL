CREATE LIBRARY DMSVM_LIB wrapped 
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
25 59
2xrVle0wNHt7lBgqiLmJGwuI7Powg04I9Z7AdBjDuAiyy07w/gj1Cee9nrLLUjLMuHQr58tS
dAj1YcmmpsbsnpQ=

/
CREATE LIBRARY DMSVMA_LIB wrapped 
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
26 59
iFc5aMRuQ7D8e3oBbgj+1tk68Fkwg04I9Z7AdBjDuAiyy04yX/4I9QnnvZ6yy1IyzLh0K+fL
UnQI9WHJpqazS54r

/
CREATE OR REPLACE TYPE dmsvmbo wrapped 
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
17d 11b
nrCax3QZgwTL1npMY4VhNUeIcSAwgxDIrxjhNXSiAPiUrbmsqo8+67YHEa5FobABVQxnNBhb
r7uayTJSd5Vu4YHlCdufWI+4eg9K+LZwN3c7PgTPR/vfGuaz6lysUtPO/SYLgEURoloLStKV
YU6UOQyS5mnRdkkZsV/g7f6gEIR0VAw4jp1rX7F7vxVpW2UoTQCZ1DzBrYx5hyf/odfE9WR7
vubmgzSanSnc5eqLfx3XiZgnw/n2e+i8AEdLbV6kyj6ShRVlaKIfE6rRFySIFLqU

/
GRANT EXECUTE ON dmsvmbo TO PUBLIC
/
CREATE OR REPLACE TYPE dmsvmbos AS TABLE OF dmsvmbo;
/
GRANT EXECUTE ON dmsvmbos TO PUBLIC
/
CREATE OR REPLACE TYPE dmsvmao wrapped 
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
64 92
QJZma3H6tX5Bib5x3JA7IamT800wg5n0dLhcWvpi0dkuR+q4dCulv5vAMsvMUI8JaaX1zKnW
fMbKFyjGyu+yhO+ZLqQOkUsDqsjVwyWWd7H6KucUqy9du119XSmGiNO9lEMloMmmpjSvH9M=


/
GRANT EXECUTE ON dmsvmao TO PUBLIC
/
CREATE OR REPLACE TYPE dmsvmaos AS TABLE OF dmsvmao;
/
GRANT EXECUTE ON dmsvmaos TO PUBLIC
/
CREATE OR REPLACE PACKAGE dm_svm_cur wrapped 
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
179 117
qLoKxwc1gXa38TtA7si+LvOuy50wgxDQ7csVfHRGWPiOHLr0a8N0Wlgl24me7KyGw+CXpvYf
L3okN/laO6auF1WT/joWPYdv57E8mk87nXpIynk23cHv4bchK8FGl4KJb6xNoYR2z6ZtSQdg
a5aBEnkUJpAaVocBE5E6oVrJxcfGENtTxYD82GAcdhVXkJRuokdFjYxrEpk4LSpE+kp0WaWi
IXajkdEuCJmYjJAqqgKrJKOw3uxZj5JKqrhedPNrsw7VIBOXBxpUNKa70rq9

/
SHOW ERRORS;
CREATE OR REPLACE TYPE dmsvmbimp wrapped 
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
755 1f2
57n/tjVQpkTdqusoFylk1m0ddvswg823r9xqfHRArbs+wGgUy+dShl3ouaezFI3N2IqOvVLu
fL299MGw9hp5oIh+ylfKwN4LHgx+wbUBVQ4jaDQ0SBxB33KerFZZJvXK5kl/fPHhK7xUUW8q
kBYyB/bpUNwgyZxVSkTbEVxEsJUwsM8m8GfMC5wONl8f9r4sRs/IzbCgNMICLdcBbxqnC+/1
BGXRAQ7X7zycVIBbbweFnlqWqeLQuNSIeNCY1DNxXsch3LhKiYAC3VNUrGeKi4U/D5ZkrdMr
PuwHiOlFbULjQTb2LzXCLao3d9Kh19E4RPOrgkEeNQPl257mYvzFx9RZ8/LKsHFL6atflc0P
YKuUGId2tzk8Pcp3XMJcxkkluF26HDcQyeqzMDJbvx0k4qJymopcsUEI2IeaMY+JBYLRWc8g
Nadp5AWlKDGl9qxZloPau+/p5HX4wFBke2Wz7aRyiN06QG5HSJYZpgTL9bs=

/
SHOW ERRORS;
CREATE OR REPLACE TYPE BODY dmsvmbimp wrapped 
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
d09 32f
g9aurEIskIG+yPiqoG+AVukPOG8wg80rLUgFfC/NbmTKZT2pzA6TgpAWo8mo8eFCoIb0ESWO
Yi/v6XnS+Az3wthaiYyruEBhh37x/tuY/rmQXxMY91lD/ZsBmPgN7bW8czVTvkVm28rKsJE4
bOniFMytQ+eT+uQ3YJsZB3QkQAZMIAyT2J3AOCtmhlHsSTcjeXECRZiVAXo3Mqtmw//ySTVL
IpFE7NE1ml+PU13CuHk4gHFcq8ZswqwpIY4quCnAZ7h3J4xKOuzwUuxiBkirfgRRnbTSa7fd
ji9Yb9EWL21Bw4pJVDfWGChCzY4TZ//jyRENFCUYVqLO4ud8sgKm4W+Nw+aThno+JWePmzwH
kdiPZUbfrhGNtS+qAvl/EQO2APXCoYf2B6HCro4w8YlebNpis9jJ0Prk30O8HDK1Vf7Qvrtw
ndOROGtwRtRsciF9LnexOly0sr2HBze5uVVItTrB+Xt22K3RvVz5GdpfSDnNCxB56CoLx88W
TR7UUA9xi2hO7j4hTWJ5Hdqyaxb+F0HN25NbQQ3YgRMVySzGSqPkqHB3wu8bLhGthXgmv2a7
K5rcFc0ZyuvW2eQypLoq8vjXjLSRb0CpcIFgBpQ0cFqcC4a3jZklx8AARIeI+wkKDaF0qXV3
ekShIsYPQ/QsE2eXcTNMXh+aNMnhgAgqticTeCbtBAMQQFtQnafgVxJBzxBoJM/aqkEwuUWd
gMGhjjuYBHvFZQjAjaVViMuMY2WKKF0kJ7XJshwJdKo5G6D1/c++7P+7TQewwVWGQ9on2Cgn
ixlzOSSHr+E=

/
SHOW ERRORS;
CREATE OR REPLACE FUNCTION dm_svm_build wrapped 
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
166 130
ptLHmAyAUbBPrOQsDlfSuFIBn+cwg3lKLm0VZ3RA/mgP94yZ2WaH/omfCfD1JfH60qsvlqxB
oqqdXupMjbJ0vWpOP6CTq4aHcBKlhjqPE+tInQKTRC/4Z5CZYKz4S3Gx44PYaR8PtpUVwtIz
SE6ALQRioUmFjpN6Dmt4k15kKMYvAPBSknPRyBppnOt502xl1TwpTJtmRTUozNbJGrOyHko/
2bVeI/Dve8vkXTqjq+ENddrWrWeBk0HxAY3xcaweIvvJulKp8QoUi633Kx0ody1pqW7ysP1H
Us46U6YIdJOE

/
SHOW ERRORS;
GRANT EXECUTE ON dm_svm_build TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dm_svm_build FOR dm_svm_build;
CREATE OR REPLACE TYPE dmsvmaimp wrapped 
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
68c 1d6
fPn5VdOkOkrkgPezlM/P5hGwxaswg823AK5qfC9AWPjVSH5jy895WR/45kzTBZuQ/WWTWlZ0
jcjIznMa+mkRaCUJMoan2xftwfgjGoE2ZB7QcoHZBZKkfJcVEWl/NsLxZl6mkbiV8Ynd9eGl
omI2fuj+A0K/4DV/npcRjQQXr94BNm0YRW1859TU8kG/cdGXi4z2hz0RJyRynoRq+gzOuWWf
U68bliaQ6MWT2N7qwhUObwRITnvSvCe3YK93KtZVM8xIrUTFWyCHNNuUG9LJbrBkV4jV0rSB
XF70LdNT/1uzf4pFyza+vtbYAeZyysjbcK/URQ68Ruzfqlh/pxQnLSBfw42GNni35AFf31NA
A415gqu6H3WhMyDwhoL2XI0LeyY8LNUSRx6I4DkQ0JkMVvn3rUvNF6mbxFUE7AWEuBFXHx3u
WlGWW8YOufpXY/uwA39YAHEQ+1Xb6Xw=

/
SHOW ERRORS;
CREATE OR REPLACE TYPE BODY dmsvmaimp wrapped 
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
ad1 2d5
8S2zXHyWxh6b4CkeUxFiF/fnh5Iwg81cDK6GfC8Zgp0VBqCNxRRTwOxXSCeJtPcASPr65VRQ
4qJEUT35+TKKIbL0Xg6pyFAzJTAcLXMAG1SNXxRlO4VkgYu7I4EXc1pTIq2oou/KsJHJNunR
RPc+Q+eh/3HmqDop8kAkLghFH/E5Hp2gUG3hMMzcjPAnJnn05f0GZpFwiCA+kZfA1Q5wc6dE
FntbMvO71sJH1RPhrGNg3r6aw+qDxd+ZszBOlFbd5voHwVbHeb5npy33PHdNPxG0qyluL5VQ
FjVGPtMP7udmFDiIH7w0ocTnTwJJcrdgt3aP/MqIlq/58jAoHa07UlhxRasbJdl1pSPEOpY0
ZLaHaRyoreNHZ9TnsgxBFmlcHQ0yDCwz55CSvuDqnwNMAHmuEOD6UtxN9f0PjCiJDnFiZWO6
O98pVfBF4IFxx/fAnn1nd010eZnaXVqXTEptVvEeoEliTIwlea94+jrKPLwnnCYIuY482TXX
3J+5X6SQKjCYjxzAZQjiFlSk41+GiIR7LANX2RcQGfa6NI+9a10JgF3TyyrwDaKahmEldMZW
PoHaQEwQA8n/QqYVbk5bT9/4Iv3FEM45O5pvJFcZwr/EBROaxro8N7EQHA1+cDuYBJJsZwjP
lFI98/lrvneKsuS7+rUEOpJzcwfNlKx5bSS73btQ2ddzaoszToFl1MCyVdCqHCnalg==

/
SHOW ERRORS;
CREATE OR REPLACE FUNCTION dm_svm_apply wrapped 
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
189 158
n/Zn2ExJiibNunotqpUJC744Vmgwg3nIrgw2f3SVALuwhVJvbwhys17J7FX0oFjs3x0SxayA
H282ryAgn1Tp6sfe/Rm7Qyq6t2ubFKXAESC7BzPPerw/Z8ThWl4OtDa2r+otVsZfe19Nv/3q
OP9SmuErftbeWNK6dgnVx3syZApRiVD4DT220uOC30d0uN7XCd6AnjdhES0V19QT3DZeU02C
qKeSLN3Ncyey8j3Dejdb3Samo6StqXLq8YPYyEXBLzvDgLU/a5qE6n36WjkndjzR/00EjJZG
NvhakJ3Vlm34HywtX516cO1TuOiF5vvYS4r/va1DBwquV5g4Mw==

/
SHOW ERRORS;
GRANT EXECUTE ON dm_svm_apply TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dm_svm_apply FOR dm_svm_apply;
CREATE LIBRARY DMNMF_LIB wrapped 
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
24 59
H/p7Czkf47nbLdCyJQeHa0u/qQ4wg04I9Z7AdBjDuAiBTjJt/gj1Cee9nrLLUjLMuHQr58tS
dAj1yaammCS9lQ==

/
CREATE OR REPLACE TYPE dmnmfbo wrapped 
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
a8 b2
u9hibzBlMWAbI6NJ+57Xxp0rmNcwg3n6f57hNXRgOB6t6fJElvcxc433WKLCWBXFyuDEuXPa
NelhtOoAzuSfRACLseQ0ltu23rxwuINJZtJrp/NW+4IqkhvtAbR/ENEYarRtl6ITP+ESeOQy
zS6Ad7j/Ms0ndjta907Q5nqknyBdgxb/

/
GRANT EXECUTE ON dmnmfbo TO PUBLIC
/
CREATE OR REPLACE TYPE dmnmfbos AS TABLE OF dmnmfbo
/
GRANT EXECUTE ON dmnmfbos TO PUBLIC
/
CREATE OR REPLACE PACKAGE dm_nmf_cur wrapped 
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
177 117
hkyERstXIlOK9YTIaJoMtD2Oso8wgxDQ7cusZy9GO0IYYqgtZ+A45jJoYlqJHf4zWtjiULQ4
OAb4Epeu4czE7NdHybx5Rnrj4e6DvhK/x5zBHUa9ps5oyny9ecNgFqSE3t1t7I5GGVt8MMJN
bEUJ7bEryGiZ8hUuwm08T0Zw6GUDeqKgO2UaGSeVs2ZZ67oZ9CXpxKAhn8GPH163nH6hcn0l
cDSChXH8Bh8yKJgW+ZchAKDwhlfsLbKkqrSLjt6pozflbuLAwdYp/EQq8aNP

/
SHOW ERRORS;
CREATE OR REPLACE TYPE dmnmfbimp wrapped 
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
670 1d6
b/0MUhyPOEHkSRIJEPS0AY1vYPswg823Lq5qfHRArbvqzlOhmKlTUvJev5kaoS2k8q73L+YG
fNu1JPcN49Df1rIh3F0l1Dy2xj9O8rHKaCBB3yi/0BMXaTU86Dak41ChdF82GK8fnE1Ei4Kp
1Yqpw9okD1brSun0s2lEsJUwW7x3YMM4f2wRpuhtDWhK5iKFM1484uKeXnjZVlpixmB9C4VT
qIyDegn403n15dR/wIxaZJSQQ62oAXFWjU11QK/57Ra/dr0KqOwHiOlfuggEVZlIVg8FTauC
3mUBUVKsChTy9I2eK48hx9Th52zIHR/84fhlKki1ZXtcFiPtDEmgPRaJSMKN/P2QdjqnSXBP
Qpiz9WPW64+fJJlynYpcunIwaWRPGV0/PcZKBKUZy1ZrzsTbLVYIA8Z/X8S/r+qbdte9rX2u
VX9Q7SrLiN32H1sxC2FTV0L7U4uiXQ==

/
SHOW ERRORS;
CREATE OR REPLACE TYPE BODY dmnmfbimp wrapped 
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
b4b 2ea
fSAAvyKEUlrdHkkyvLqdWIK6r4cwg81c1yDrfI7BaJ0Vg/TylNNxvyNSbncJflv4WOJJbfAu
ysxn2LWduIrRMrYXYo2eJaBxq53QtLv+7gZFARppQ+zPMeS0emg/BeRmaEfJRgQ2XYnDKwld
8tNcCUppIUdJIfHEvJHkBBh41sjCtHOJ5hjlj1FMkf2Bl1NvMqsGZclwjSDz5ZHwt8q0S0O2
EUU2c6iaB6tT9WzKVycNzPgu14NX1+UE13j9QIUBeUA7SSrE8Dq0VxE6EVpPUnFmClj/9f/0
yRENFCUYZsMwGOYTQKOm+23yxWvYUj9X3sp8n80MnivHiPK/D+MhNp6ygwaIq09DKQTvSWaq
09SAS26/x2WTh8Gi2gT+XKC1XqCu5XlnPG8nYBFxm+bWh4BLkA8CEal9xXHyuTwASCS1GYcC
2xiG8WlD/u2vEeFQvG9Y3+3svymwNwmtW8K+Vq1E0mkEd6czAr3aGMBPTk0BwKESs04qPrm9
rbtSDZX4UkuaC7OVFwesTgcMjmFqMVv+abdCpdZwTMrH9Op0KcCXc9gmhWd3kKhKUzUnDWWI
ltuEYsBiMbvOO3qRXsnDi8IfkXjkmFNc3RYZ8ThhlbkRW3j/L+7MHm0CBP+fTmpzM7keOkgz
tGO7t0hKGmNt21wDjvRqPVP8dgezYIgzH9K7vrUX4SiAdLVtSVpFlrxoWcHV/Ln4csb42dUn
8lukwCD5pnjdTB4=

/
SHOW ERRORS;
CREATE OR REPLACE FUNCTION dm_nmf_build wrapped 
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
11d 113
63uQ0dD2ugRVKnPYrWJFVXqXvDowg3lKNfbhNXQCALtkhS2s580NsFO3Pd1Zn+z6MLKFZuc9
E7Waky0SyDnmFYYSlojl0tSM3fWBBYGKsPhDv6zQy8rwN1GZG6yd4EJK7yeqZ3ODIZeOk3oO
a/5c2U2ZlPEMq8kyBco+OLErxDHDhV8BD2/ZqugfoHXAViSzf4I0tWrgoEkCZx08EaWtbVVF
DfFcjaeD5r8L+9ifj6ZiXqFH9qjNZRcYVo4Op5+7RMeXmgpbEwWA0g==

/
SHOW ERRORS;
GRANT EXECUTE ON dm_nmf_build TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM dm_nmf_build FOR sys.dm_nmf_build
/
PROMPT "-----------------------DMMODB START--------------------------"
DROP LIBRARY DMMOD_LIB
/
DROP TYPE DMMODBO FORCE
/
DROP TYPE DMMODBOS FORCE
/
CREATE LIBRARY DMMOD_LIB wrapped 
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
24 59
rmvNBPt0iBHMMjG0Zk2a4u8EJHswg04I9Z7AdBjDuAiBgb/0/gj1Cee9nrLLUjLMuHQr58tS
dAj1yaammEm92w==

/
CREATE OR REPLACE TYPE DMMODBO wrapped 
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
73 96
y6sTWY3Wldvm+mSDIRaPjIxUMp0wg+mX2supyi9GOPbcf2Mbh+GRC3zdq59i2DP5xMjbsYlO
qiO5RlSext2l4cv9Yhiz+3OMfvBdhcUwH21VNVoqPVyL0OUoWD+9SBny5aQA+uVF3lOmP852
Fw==

/
GRANT EXECUTE ON DMMODBO TO PUBLIC
/
CREATE OR REPLACE TYPE dmmodbos AS TABLE OF dmmodbo
/
GRANT EXECUTE ON dmmodbos TO PUBLIC
/
CREATE OR REPLACE PACKAGE dm_modb_cur wrapped 
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
cd d6
b/iI82WicMZh0rWb8tmp3p909wcwgzJKf5kVfI5GkE7VSH6va+O66CFCPFGhlwxmV0Sg9vM2
tZ0ookaseFWkLGgu1EFHZ3WcRXqLuu2dQXyh+zp789NDekCvgVlhyV+94GbaIeamrzAVrh9q
MxEwsYqY4vbE/OuQmXOERhGBJ9lv+dGkyqjpbxOZBz39OxZXVw8Q9RCUCSAZVjdlRA==

/
SHOW ERRORS;
CREATE OR REPLACE TYPE dmmodbimp wrapped 
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
670 1d2
TyzM6Dktfw75AmZx/cqMC43rLYIwg823AF5qfHRAWPjVIWG/TI+0dXaA3rJKpBRYyPq/cR9A
HOS1vXjuzlpxEe6XRpzbJQDxgQjyscp+YQWw12qGM4jDyA0+NVtm9dMd7zfgpZUqJzc6dI85
2so9/5Yf2fULzOAhw6/efxk3lg3zXFRZy6upKThi/u+3KML4iTLN2RV312WZCdkt85IRZUil
Td/QGjARjF4qSvfa6SM7fWZyvT6G4CailXd0M7uhvoZaVLI8ekcW4GgYxn01uAs6PGA9daH3
+rbwtnFja4lUJnBE/4J/b2cWN3ZTaR+0sCZS/pxYXgJRsfiLRmGrWCUMn4ySydxKz9m2S/40
7REjCY93U3P27jqcDSceiNDlgevcHKcQ2OP7u0Pd0xiqoW7y0yS6Smvt7Z68q3L6icjW+cOk
HVUMhnU5NCtSiXrJbQoDH5w7orQ=

/
SHOW ERRORS;
CREATE OR REPLACE TYPE BODY dmmodbimp wrapped 
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
b4b 2ea
KnFsQ18K5iDDMhGsrnPtbo31tCIwg81cDCD9qC+5MZ3hQ44MK2PS7OvdBiol0X44TYa2Jxxc
1ZXyd861ClZX9jTZ1OJssAmUD36L+0f+3VMnV2vlVPf4gZIp+TOxkljnglgv4C9pfGXE8Wtp
8U2svTajUk9QWtEQ+qULBBnS5pfg+Fx3DcVNTROTYcyW8PZpsKioCzmnOm+dLGRuRuz+urw3
yZlQD5sQTTVa6qasCyv9Ddp32F/rzxyMOslq8wJWLp2BTYvoZQ/VW/AEdCmC3FpdbLFY/z6z
djunooPsQJ6uzBHraTxn3VHx5Ss8VyRuIS8EmDNsiZzmQCXNy/dAZ2s1DJoOCC5By3/AFJuA
OM+m2d7aSZyVMtyg7VIkoviW6fjlg56R3mtdRpVjDqvSxazN5MWiHaIf7szAxLkBTnP+i2YU
p+EfRj6qubJgtqkzDYUNKXc0Lp3LiZetyGKRqAQOBxUOYdjVWbTMWc5ugGK3DIPexrFNU4Bd
NGo9JQo4S9oLPNRJ+KxOnAyOYZUxW79pt96lhNcFZ4vzT8eRbX/+TifcI1FIslLdsgkKY/ow
qIcnp/b6uYbQm8jwWMxYTiLIzaVPhsz7jM7yQDHJBQrN7VcQRls7tWLbuMITqnp+uT9BucnQ
TJISd9f3oPX3UyfxZi2dqyuQBnwrPmq1rPmk/rsbpbiVpZ0wRhqYBk7X9UVRuRxPhxz/ZE1/
pKCFEJIdPTBMPA==

/
SHOW ERRORS;
CREATE OR REPLACE FUNCTION dm_mod_build wrapped 
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
114 113
dxCKEWPDx7TCung5IhTpWf+2slMwg0xKrycdNedAEhmwpbRnPqCxQYpKE+cDucOQ5q7mtAwO
qLA0qheDkSiUorNytb/lZXuW4R6t/5wqSrHr/p7QHd00FJeoV7Zo1kPEz1FKW3exsGC+ZgwU
9V8t5WJFzDMBayFzLtonXf/CxLJoUCGAxxK7bcH9PYOlP1zCEF3dFaW1sm+wAD4U7EvJB5wi
dp9ijTTlITHiRQRwgR1JEezyBszw9RZxFgNprCfXuzlOcRkcP6YZFOlU

/
SHOW ERRORS;
GRANT EXECUTE ON dm_mod_build TO PUBLIC
/
CREATE OR REPLACE PUBLIC SYNONYM dm_mod_build FOR sys.dm_mod_build
/
PROMPT "-----------------------DMMMODB END---------------------------"
CREATE LIBRARY DMCL_LIB wrapped 
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
24 59
ivfePQFDLtt7F+7VklGFOI1VYmcwg04I9Z7AdBjDuAgyM/T+CPUJ572esstSMsy4dCvny1J0
CPVhyaamRZm94g==

/
CREATE OR REPLACE TYPE dmclbo wrapped 
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
f4 ca
kYhIWAMpwA6gpe0BvT/v93frCVowgzJKLZ5qfHSi2sHVId9QJH0UBVFTtAlLQ2dJNQUta7Wd
DYRAV8j9uwBK68aipYeHT8EfS6xT2kICTqbdYhOuO8WNnhPkEoBDwqv0uOhKIPBmUW8digOa
dT6kSKJB7KNn6dVd1wwLzfBWN/E+RXck96yn74C8O1BUBwgjkvtk0njl

/
GRANT EXECUTE ON dmclbo TO PUBLIC
/
CREATE OR REPLACE TYPE dmclbos AS TABLE OF dmclbo;
/
GRANT EXECUTE ON dmclbos TO PUBLIC
/
CREATE OR REPLACE TYPE dmclao wrapped 
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
63 92
07pA83AEsFTlJMeMpXGhsQPJRPEwg5n0dLhcWvou/6FH6rh0K6W/m8Ayy8xQjwlppfXMqdZ8
xsoXKMbK77KE75kupA6RSwOqyNXDJZZ3sfoq5xSrL127XX1dKYaI072UQyWgyaam9JxvbQ==


/
CREATE OR REPLACE TYPE dmclaos AS TABLE OF dmclao;
/
GRANT EXECUTE ON dmclaos TO PUBLIC
/
CREATE OR REPLACE PACKAGE dm_cl_cur wrapped 
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
177 117
jAkXaBCHDfaN27aS/Be3HcUM648wgxDQ7csVfHRGWPiOHLr0a8N0Wlgl24kY30TGJtuJa19L
ygj5NpLvDeF6kDIXVcG3w4CTynG7vJg6uTqm3u+mvG4vdRote0nDQWugL6KEqwaPHVR62iGe
ECaa9tWhpBQBCBsFbB6u5mVeWNocZtQ9rQkgDcLA5+vSK7jTLX0rStS5AEaV344U2mV8araz
MBH3viGVlopBn7PklCeSERPo3mXW/Xv5r9d/okZg1uLt5c/nGD2ZUD6j/Q==

/
SHOW ERRORS;
CREATE OR REPLACE TYPE dmclbimp wrapped 
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
659 1c2
HTIhFRki1UT16TzwOijCtJEGBXgwg823Lq5qfHRArbvqzlOh2srb8LcTRVbIG7fNaSPlNnHI
ddu1JPcBWhNFfoPOe7MMw9quTPiBCnPxjwGB5DPSRSNbX0VLKnWFWYcHFtup4WtF74x8kKZo
XihfVdIj364gUU08Z7btzP16RoNUlZfM8qU5tKrbfYYWjlHi0EUq4sLNwIddU7c4JjT9wj+3
r+JfoGsbeDB+3l96yhNEm1xYXmAeB6uUByGZvQVRJdndd35RAVRaPZK6iIxJrzmQ79EBz34K
iSYmr32O0ZnOdHUhwrU0mOJQCegzlCda1wbI5l3szBbweWIlUgJ6B9wzU81ynCbSVSHC1vgv
XROQqx9G//z1vx+uPoe45tQDmaILgbtGT78VsWFmKN+7+X9MP/a1DFAPI2ZqMSjB9aph7xsD
E20ovD/aEA==

/
SHOW ERRORS;
CREATE OR REPLACE TYPE BODY dmclbimp wrapped 
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
b1a 2e6
s7eQquZdgfbXL1l4MeLCt4Mujycwg81cACAFfC/Nbg81keX7jOdFyXvMSVim6atdLUpJUVIJ
oGesb/C1JPL3p2bZiYarMgdRh9j400K77dqzI/TYUEPsAHogQbmdALVwFYdMf8m9WrgrrZWh
EZX1+kQ1qH82dC3+qEOlF61V8HGDzPjq33FvUZP/AzLJAXPxR1BswxjdxQ8lfdNj6lCPU122
BLymTn8PgDlGm2wvMLlfPWQHgw2BOQpd1x+6FNPlYYYltxitWvQbH8ziPuYa255uFJ+3Pk9/
1l1fg0NAX2de/VSrTf1wj1rVVREXEH1pk+PYVUCJ4fZr4Py5sqSULAaEGuvx1UppI4mgxH2t
90C3piQ5ith5b1xCE167Pwq1lfjGlRLxkdrX8mkN1quIrugWdHUyRjFb73vvV7HNCZv++QH4
OsEze5LqrG9f9ukwgN6m3UbD5gsSRLsVTEmEvYDxAsVEW54EVGVK/vQdoyEfqG+Pl9s5Q+mu
dxoOSRRups3Y3ITutCshOwptFHSEcKbSVhg0r1Pfy+r1AtsfXk5fwuDvO2FlJOJSAdKXyY5B
uSFyjZGattyeMFlZdWGcTM95Ht4p6aklJW2Q178fBQWoCzDGjbUWNLiLXz9CaEi8QSSM+8Tu
Tl1fG7xA1PYnwdx8iroHk8FZb5yDBiBpmk75xImklgSdUiD2vnLtVITBJ95O0nNDCJuj7Aln
bYOYD2O9WY8=

/
SHOW ERRORS;
CREATE OR REPLACE FUNCTION dm_cl_build wrapped 
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
111 103
MfvzZq25Z4vM1kwZGyF7WaRa1Egwg0zwLpkVfHRAAP7qXU3KZocAAXmLnnnfJXf2Nb/zi7O1
IMHGL8ehWkHBLhMx5buI1BK+3EObUy7v2LJniqQCFQS9vEM6Pf8WYYStftVjrEFthJXgAxqH
b7SV4Go0aFxAt/b8VPWf0yYjImOqhrE6fG0LfzaS6ZwGdhMjUnfgy54SA3/m7AL27LIuT6YD
nxk119PgYq33da8ojnq31m78T3gehrhxAPs4BIQQ

/
SHOW ERRORS;
GRANT EXECUTE ON dm_cl_build TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dm_cl_build FOR sys.dm_cl_build;
CREATE OR REPLACE TYPE dmclaimp wrapped 
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
569 199
MmcYGumlbYcarAx8dBeQfl4HoS4wg83xLdzbfHRAWLs+eodjEy/9txNFJ2suxQVr9RgvVlpu
2/iuoCY2sN+/UeZ892z0O5YtqrV79TaWxsHEsLGG2g6x5dHdMMnCqzQvHZ5T5EpfFT9buK4d
fDP4E4p8GaLM9h1jxGD2F6+U6CtH/au2eh0ebGAsH6jBMoMYPCFUxFWo+lKWa14isj2f/3BP
YKPqabZWYaCiHMguAs+Qi0se7KiOTQRgYtsQEMXWNujAShu0dHV3A0QeBW4wI7xjKYkvJhQq
Pa33TT4fay2bobDZZpOf7dhTdTpWEe3UvwLSilpu5Ete61drLpBBg+7aT0lHBAgRosxPtRN/
rVG0ASEGbPc/2V8+fZayq+4R/2JVIGHB0ZjtkqYiEbK5

/
SHOW ERRORS;
CREATE OR REPLACE TYPE BODY dmclaimp wrapped 
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
9c0 2ad
4Ob7Vg1UPD3Eyu8KEgQfLp9Y0Ucwg81cLiAFfHRVvp3mfd77rKSfzfSnlICpYoiODXdJqIV7
fmdtsvb5JOgoBVJ2bFXhkQc4vLRmLGybCMzo4pTYUAHGIp2KQcSahz983rm5BII2FK26k5Wh
J5X1+mw1zJm7Z+C7AF3Sf24cFxt5PjSXQLHKE59Y8GrwUmLudxRcm90bLCV9CXfcNe+LqE+m
OqulCyLLg2G5cb02SrohkrhNKV+ELfI8WYqsa8ptGD4FjmbKel6vs2bDsnxLGo1IoCpKL4k3
WmjWB45R8cXm+KQ53yLb0IVNqLpxcIFmICB/0hNZVubi5o0ovvksF5Kdc/uz/p05XJNNNobe
Ppk2iuDX/5ZRf8kjLMlHeVUeP/jHqizN/aH21A1mCFqhWakc8uHXTUAZAI4hjYSRceUJwMoP
baigzzbcVyVxI0/DXNR4vZZgPNwwq3aEZORKt4vSdzCGN6Rh4+YnonyR0fGNyrwiSULMZLRZ
KDXynDIaaSBZYOk+sAHRFJjQJPrne4zgeUgSeEYl6+0vvfL+5th+MUmfIbDHI8H3tRbtuEN9
EEKDu7yHJCNBxCn+MbMMc+zRy1CvbhFXh5BR4lhWh/bv+Q6BC5q1p8ILrAgkm2GngIrXnkUr
DJjBu2SuxLElrUQ2PBlz4XXjnt0=

/
SHOW ERRORS;
CREATE OR REPLACE FUNCTION dm_cl_apply wrapped 
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
124 11b
yWmM554gboEn36sgtQ6stmT8BKYwg3nQAPZqZ3RA2sHqEaBr9X2DobxeCzdWDzJF5hvM7H8C
2Dr+vnsaaeNvEO0jMIEZIa1knsZPziKVsTrPRd1LHVQ8WdMYma8AVMTS9KfJoLHB4hUJXS+I
pO8qCgpz9E7ToT8HlkhNKq7tdJrwcF3XoLu3j6P7E3JuayDwd4xcwv8uJeW3AI+uWwTFECEl
oq9CigasQGZVYj7c5oS7kMSwHEFyVMGqdAR4nh/TK5dQxR75ycicmzP1RI8iWUM=

/
SHOW ERRORS;
GRANT EXECUTE ON dm_cl_apply TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dm_cl_apply FOR dm_cl_apply;
CREATE LIBRARY DMGLM_LIB wrapped 
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
25 59
qvAA2j+9w5IfUw+WFDa9yH1hymYwg04I9Z7AdBjDuAgy/gjw/gj1Cee9nrLLUjLMuHQr58tS
dAj1YcmmppUJvbU=

/
CREATE OR REPLACE TYPE dmglmbo wrapped 
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
24b fb
zDJxftSu47MZb5FX557TZ5j7rWYwgwJyNZmsfATUCOIFsDDQntpHeaez3pfKalZhPjDwDgwl
/p2NVKiBSu3GmvmlfCRusnHGBRA0emfaV41bXkJaEYxbC72oeb9W8GNHQs32wR4YyIcFJ2Q7
WhSuPh4y61gBzqxfVsWVOncu0eHRHeL5dqnCn4ep/hBABUKmC/QDFa3GQvBOOcHhwWL/iAea
E0+dtdfgN+NEZW9NVMgH1vXEI+FHw/XE

/
GRANT EXECUTE ON dmglmbo TO PUBLIC
/
CREATE OR REPLACE TYPE dmglmbos AS TABLE OF dmglmbo;
/
GRANT EXECUTE ON dmglmbos TO PUBLIC
/
CREATE OR REPLACE PACKAGE dm_glm_cur wrapped 
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
c4 db
e+mTHdqChf5ZdVDXuJsD9H1JSCgwg0xKLZ4VfARGkPiOeGGPL9tiXuzk1HC3pyShrz6ERB+Y
57ydNS9jeFVSLGgu8g+JbGg8wKrYAUIAa+AdGh6i44nxmTzSWUUUU+MnYN8R1ftX1qoCihIG
c7DsPcgp6tcYgZMIawCeqEXy9cADa4KqH9xNqEpxeZd2S76o/Z451B/azgmhvhIdw2qWTQ==


/
CREATE OR REPLACE TYPE dmglmbimp wrapped 
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
b5e 2bd
VZVdeQ0YCXQlUoZN2dlxIpgPtO0wg80rr0oTfC/NrQ84zd7v6T2HI/z6dftorC7GCy2ta1Xf
J9VsJ2MztT2v/xtnWpzDg4fC5716QXh8uwALEUzWzsL4RVUAP5pzjiVea15remYEJ+0djiW9
E8+m6QafqEbVFOaDxUUfFhMFv7+/2ZQH1a5Jf4DxoNNYeBigKhXo8rdZ8k3zJ+LT/JAc4gqC
etiwufErQpNsReXqt2eXo3ll2lzAzRm5TxntLpwqTAbrgOs8RnPI3+4V8C6EnsiB5+vW53+9
5aCzGyAod3Y1MilTmax2pVmcFg3eXqHCAVhulT+cYuZvjOtwW6LkcHhA/+F4Dk6sG0uEuJYi
k8k+L4WMiKCrwMZA9CO7VQaFSbGPddXS2eDoofkzLu69Gjr5cDN7bXqGKH5oYwaHu5dB1ZNd
en0yMew/PYrp6uqFXxdEXBXatSnF2anDUtx/FgOqCUcOeWi9fEfOuQDozHF1Otq1s8RIyYao
LtSKCexo2XZGGISQDtsy2LSbFqLw2GdoNtwcHMQTfk74TsQTfOsRxUbCcf5B5ql40dwbZ7/K
eSRzd8PGo7VBuq4N8duXreZky/T3bNm6s6mJWmq49dh/GLAcAY7DKbD4hpaXQavobDanCsFo
DvIej2Z4dDNdtRrQg/nODUJCENSKYqe7muT73AYrtg==

/
show errors;
CREATE OR REPLACE TYPE BODY dmglmbimp wrapped 
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
cd5 288
XjBp2Pzs3nWip8dedFWWB/HqtK0wg81cLvYVZy/NrZ3gCMNr5wASg37fUk0xGgO2d15pxWMO
yga1sBPXgAtZ4KMWYzuHPEeKE5Ez7cSEClRleJsrigG1RQUgGTNbOYOz2702TrZs52aVZq6m
Ur/RC4l/gPq5pDyb66yn8GmJaWEwOHwoTOeGByvKOj4WJCfVviW3Bs0xsZGYgwx6JCYhG9gH
ZzFEOlGkZbd6SHDiNeZpDqyge3UoWnqx6FvxN9tKHPfW8gDcepS9/OceAOgWc3qDyzzxhTRU
eGvW3Zm9r1+jS8Fw1KNQC0Dx08OB+XaML+o5Dkf5ZroI2vq1lHuziVMAoymUhJbXc0bLBkjK
DNbOBMC5hibvjXgy0UcyUuB4x3MXxwG94s1lwcVaMMpYhSyv6UoKbrt3ejFNBmuR7wyGIwMF
1MbNOBBoSn5I+yELZmWNnJEdYODJ2qF3jWJt9TFMVZwrwA56L25Zmex88z3UQC4MjTJ5IPET
U9BMJuWiXJjZiaTfesEaX6dmSjZ3FFQp0npxLwtaLTcId9O0AAQu4d7OVCFF/0cSlb5TUE8N
VdeEajmJQx4MhibKQ3j/deUpE9y120xkrh6GKfggkk+dRQw3TL6MpAr5mL+Or2RG

/
SHOW ERRORS;
CREATE OR REPLACE FUNCTION dm_glm_build wrapped 
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
10a fb
YMDoljkj4RCe9tPr2wTDuT9pof4wg3nwr54VZ3SiAP7VwMMvqt3rgy7EN7lhkQPjsKnnZqCA
tZrDBdYGdvF8NFghbD3mEKwFGv5SJR5Ofxlwuvui8oms39VwUf6gbATI/jm92vL8kFc7mcFB
OFy8kQF+IrlfyY4tFeSZ4c5Na20DqlTK2lyLUIg+oJtJTlUPzabFYD5u2NeX3BA56hpsKGB8
G7Px9wo3OYoWawfxzXLhXnZKEx8igqJd

/
SHOW ERRORS;
GRANT EXECUTE ON dm_glm_build TO PUBLIC;
CREATE OR REPLACE PUBLIC SYNONYM dm_glm_build FOR dm_glm_build;
/
