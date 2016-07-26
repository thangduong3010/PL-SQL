create or replace package xdb.XDB_RVTRIG_PKG wrapped 
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
11d d2
e7L5J9C9fKiefHIEHX1UEiLsvrcwg5DIf8sVfC82Jk4YYtaOzFDoZTP6YdOK65CkbI21tZkJ
UKkmEeraAyXCLW0IRlUA7H7pUSA0MHWj5vVLXEYJ3lyhL5RqpkuRDOKe7lXQoYCoAhwjBU/2
rXUbSz77E/P9X2hkTq5Qs5IsVDHwvjIR/O9dM6huuJK435iI8rkeRjqb4etbDJA=

/
show errors;
create or replace public synonym xdb_rvtrig_pkg for xdb.xdb_rvtrig_pkg;
grant execute on xdb.xdb_rvtrig_pkg to public;
create or replace trigger xdb.xdb_rv_trig INSTEAD OF insert or delete or update
on xdb.resource_view for each row 
begin 
  if inserting then 
    xdb_rvtrig_pkg.rvtrig_ins(:new.res, :new.any_path);

    
  end if;

  if deleting then 
     xdb_rvtrig_pkg.rvtrig_del(:old.res, :old.any_path);

    
  end if;

  if updating then 
     xdb_rvtrig_pkg.rvtrig_upd(:old.res,    :new.res,
                               :old.any_path,   :new.any_path );
  end if;
end;
/
show errors;
create or replace package body XDB.XDB_FUNCIMPL wrapped 
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
5fd 1d2
8PekypcLVZmDY/LMeVSF6l84uhkwgz1erydqfHRVvg+oIyevjkX2rko7G+BKkPqfE0Gbtap/
rfqDjXkCLcw8Z3SnQU+BQV3cEx9M78OvQQ7EPUtyGWkFrVBS+2mf9KwHimKbUCl3X+OUC0Yw
GBO8Mil3a+FtTCfdwWHmK2mpf392IRNgTgPhqPgz7wDARPbjXUEZGoc1iZSFhIUmjmH3nWs3
gwXDUrv8vhgNjwReySRbqeCtHqBkx7N+3R5vOEIrKl+/Vq/MleyAJN9mIZHfV3bn0NaRRu5a
Zj02T0uuZo0CbKiAVKFIy9Bcl5Ncb/c4+n2OMHSuK0SEu0guN5lafAM3H0mkknsqnHMqbN5c
cXpbNcoxWVzb0J8/jR/Zd5FoKil+Gb5QgUhSCxRhTxcGF16lnAulmK20Gd4vHA76zuwNmIG5
LNjGt0HaIjOqgwvSn/7SOTPCx1Y=

/
show errors;
create or replace function xdb.contentSchemaIs wrapped 
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
1eb 154
7PCJFPfZ1LSmNAj4ehpET9E/1LAwg43IfyAVfC8C2v7qbnVnGARU2q2LykkxF/W8Z2XplOb8
4aSXterwtutN/Rm5QZqwEiCxwlyedMG7BXPAmMZOsUOSoSQMr+fbL/hTuTTr+amUNGr2ZJT+
cHbwtNSF6CM90MtzdkuXpjV5Aje6D4xdsund3My0V3CG82/fS2YeL3nWGXSOH49Nb+8A9QUj
kBUCK1bLgBXryIl/g/SgN37Njstg08XMhhbRsB5JczFg4Fx8YQ1s9iFa+jrjKMwCMA/w1oQZ
9oKyqrWZxcFiQHqOanfbqmoDX1jDK68l2FE9xgWWMHB5sw==

/
show errors;
grant execute on xdb.contentSchemaIs to public;
create or replace public synonym contentSchemaIs for xdb.contentSchemaIs;
create or replace function xdb.under_path_func wrapped 
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
49d 32f
rGbsDal492dkezaOt/8yklMr8Ugwg41ezCCDfC8Zgp0GHHvzFImy6Nxe8yioUt0JS+8FMX1e
otYKDrM2bDhpJiQ/F7bye95eHz7Airu5+M+aTBVGOhjAOQfgjAr1nUib0ghpkUrK013t9erZ
WlXGkef79D3hVMJu839GHDS19ABZ5Lm9qu70CC9NF/RCj16X4cKbPfy1zhTJpgHdtkQKcIsG
mA4+TMs1QLM07QYOSePyNvbEZ2OzfGOpT+N3P49YymsxDNEb5/hMWAx1+xrT6o8JGIK8c3t8
Fob7oVjEFCBQlguZQIlCs0QQRICGIG8qGaJGkPRy6pDSyZFKQ4Ev3yVMZBaZQshWCwcjuR43
bJ7JDFhR71JRcc/r42UG0ulCaEhwuoS1Q0Twv0Sy+fPNnOmMrtdsGc6K8ppqvZM4b+izUPUo
eQuhjjejj5V5hqMKJP0nFeFfE26WILZf/Nq3g/GzzZg+0mz042TKv22Bt0DG5c+s64vuG66/
BQZJXWl4HuU3hmH6qNnEmC6j4C3rJMn6JoHcF7J3cjKjkRtdi/JcKUV6w1hAC+LVso0N9p6/
sDWcbNVtFWl6emq8g6eUirGN0ewrucVMK84oWE2Q+WO/S7MyPMQqCARtM6hdFTynWpeLO3/o
kuNOztgf00OWfPFllWQLKi0E37qvKAtPtfdSlJtGRBcaguARuhcHLoqq/BNDspxSBRGD99BT
2w8G4BAXFPeenL6jV4vbSrJhgvQLZnZYR0svwcUqRrOl8a0EDtXBVxPeEhl5OoWHZuZVncvh
4rconfuJKhQy

/
show errors;
create or replace package body xdb.xdb_ancop wrapped 
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
13e0 30a
ofdW3dPCkW3TjkHSCKSAcMXloFYwg83qLiCGyi9VHovqXyMnFNUJEs29C/wO00umeDP6g9BO
uRz4TtpwiiU2gC4BefHF99P0+3I0QoJOrNXmT1r6yurpmZadqp8k+eSS+ChTN0TdC2ImQ/Lm
6YpFxwq65TZ1PNjs8Et5lWUWVAGxyh4u//WLKKsK7lgRRRuSIsdI0yzcNB9caf8Br6snE3R0
+eGcDieZLvdkpZiLpJqP/4wWhF9se3dHPKNKNS9iq8crwCmMAs3z9cZjMt0dtPMBQHySTRBG
dITnLc9nSVlvKG0UHdYDtkvIn9NS1ldTOS5hvfFQrOmUoqcNCnhEod90SM+HItuy50H2Ubos
XIKMJy6T/kcxYWqkzz/Zf4DlGgHwlXYqe0tZ/VPN9wKkKGaZb11oUgIxUvLYnjP3tTcWr5GI
lMn+z3LiUc9Z6/2f3L7gZoyMlFBeLnmP19td6K5XZozKP+2278h7j7LZxITWRKTHk9FJIxGd
qtwqeHx0y9spREmk98NcCr9L+IhYdmvSpc7AkE8/0kC9gTBqegfPihKYjnN9vxt3jK4exSyA
l8a8h19yYiQirfhM8X7jlf6QI6on8ssq3VVHpHz2CHLC2KLjTjQJvoIciLPsoAgsom4RdKrL
Mlk6mI4Qz3K023V0vRuL2wVkxTqzUhWilcxq9RUIrWh0v4KfapwJR8P0x8f3ZA5/uXKeQzay
D4oA9VrNI5zklmRRB1v8FO/1U3/iv0eM2c13hgXVjnwG5Q==

/
show errors;
create or replace package body xdb.XDB_RVTRIG_PKG wrapped 
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
380 189
+3uNmKZr1/vc7Y5Dx/tMx0AyxOEwg9def0pqyi80e2RUY8AUiQaDw/ZUOI5bUKykmAa1nVdf
9F1XH1UqSUwLbaTJyReREonqdzY7XoJZ5S56YN97Ogo5dLhXpjCf8XfdNpSC3yFZ+xV2/+s7
0ANJ+xwLW+/CisgkrshCcOHSEYFLfQxLMO9XydFSWTH0xgu+PROn9206rQpFN2xjs1AAAZG+
uHiTk3v93hgC7vcDKxTLUFbBWxaenpOiVih8K4j0s1JEp5QeUf1NbhLCe5+w2cRClIEkQxAf
eF5OUbUh0TT62jA9U9LxtLxK3WOwHOUDLp32Sf3uLMRewOOBDTuv4seYE+r/o0yyxDg9+qNP
tJGU0Eeub5iubdiDc+Cc0JbBb4+4

/
show errors;
