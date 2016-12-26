CREATE or REPLACE PACKAGE BODY dbms_frequent_itemset wrapped 
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
2b 61
rRX2aEQaANTZ01zKEkEmKGgErtAwg5m49TOf9b9cuJu/9MNaoZdiSq7V8mJWLtfV9HJWoddi
3GLMuHSLwIHHLcmmpioqstI=

/
CREATE OR REPLACE TYPE ORA_DM_Tree_Node wrapped 
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
ef eb
NNtUehiDtyn6shlr8I/RfNSQu5gwg0zwmMusZy/peb+d4PLfa7RNkD2mtt2K1dmmLYNgJ7a1
nXxtGNspub6+F85v58/bd7TbcgGhuVIPplulPY0nQOY5X120OkBn5+5gusxWQ+yCtIUvWXK7
prUw5rdAfzb7neFYjISYo0lfMgcIVG6gxWMIxxxU5sS2MhAFAWhQ0jLNXL4G36rT4SLE3nKj
9mw9Q6XhG0OtsQ==

/
CREATE OR REPLACE TYPE ORA_DM_Tree_Nodes AS
  TABLE OF ORA_DM_Tree_Node;
/
CREATE or REPLACE FUNCTION ORA_FI_DECISION_TREE_HORIZ wrapped 
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
219 144
pn0fjPjekVawyL2jP85VBXaKSlgwg433LUgdqHRn2prqMH5jdFzUQXu4j9mT4dZf9MCT5LWq
8+JJ6ddQxThnBOTkRgB4M/JYqG0DWFYOsIMLXjWgbJlMmlupT9Y6GyqZaB9SmvyjLrgZmssA
nAne5kWj5pSbncdy3OQGXef7F7FR4cQEeGDM8Wy/KflR2YQQSN7mOtbKb9IrDBQQ7BaHDxTf
W8GppfGGrRXB5XPB7V4fzmQDKI+l+6yDkSy6Wvig3zgCBtuV47PIVY7znpRf2wSpJ/4CpyWD
HtVBadQ4FbYIc5Ie/SLG+61fIHjmhUDY

/
CREATE or REPLACE PUBLIC SYNONYM ORA_DM_Tree_Nodes  for sys.ORA_DM_Tree_Nodes;
CREATE or REPLACE PUBLIC SYNONYM ORA_FI_DECISION_TREE_HORIZ
  for sys.ORA_FI_DECISION_TREE_HORIZ;
grant execute on ORA_DM_Tree_Nodes  to PUBLIC;
grant execute on ORA_FI_DECISION_TREE_HORIZ to PUBLIC;
CREATE OR REPLACE TYPE ORA_DMSB_Node wrapped 
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
f6 ce
H1bqFzPmoRZlH6LKdAo3kElO0uAwg5n0dLhcpSjAX78Isp8Y/tmuoVy4dCulv5vAMsvMUI+e
58AyCMfSMlzd+xV21m4AdtZfIV+yITLd5daEkGerV61/iXUEBKmOrUKSOgKSe745PrjAwOZU
L5A4SiLnTDD1HT37bMghEjoSkgJX+AKpKg5tWzY62mvjx96jgqamTlghPg==

/
CREATE OR REPLACE TYPE ORA_DMSB_Nodes AS
  TABLE OF ORA_DMSB_Node;
/
CREATE or REPLACE FUNCTION ORA_FI_SUPERVISED_BINNING wrapped 
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
131 10b
lL38UBp6fJLWao2VjCeNvbcKXzgwgxDQLUhqfHSigvjVV99nQEcqZVo8MWxnXjk+RFpvc7UP
ogLMHS43wI9nvJjvweVe7tiJYqBYE7GynxeAJ/dck5zQN33V/SQFw9cDs8zY7TpqEzgZv5z/
6OSMFCMLDeLzW8OT07MkyIyJSIad1rXoCRV25YnRlIj/kRY9M9Al/C3e3LiDrETzWtZAFg7w
eOfV0y2qD8OxgbPXmW+0V6JW2MbOTmCxUqnoCNLhO0jyAg==

/
CREATE or REPLACE PUBLIC SYNONYM ORA_DMSB_Nodes  for sys.ORA_DMSB_Nodes;
CREATE or REPLACE PUBLIC SYNONYM ORA_FI_SUPERVISED_BINNING
  for sys.ORA_FI_SUPERVISED_BINNING;
grant execute on ORA_DMSB_Nodes  to PUBLIC;
grant execute on ORA_FI_SUPERVISED_BINNING to PUBLIC;
