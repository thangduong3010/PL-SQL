DECLARE
  obj_not_found EXCEPTION;
  PRAGMA EXCEPTION_INIT(obj_not_found, -4043);
BEGIN  
  BEGIN
    execute immediate 'DROP PACKAGE prvt_awr_data';
    EXCEPTION WHEN obj_not_found THEN NULL;    
  END;
  BEGIN
    execute immediate 'DROP TYPE prvt_awr_period';
    EXCEPTION WHEN obj_not_found THEN NULL;
  END;
  BEGIN
    execute immediate 'DROP TYPE prvt_awr_inst_meta_tab';
    EXCEPTION WHEN obj_not_found THEN NULL;
  END;
  BEGIN
    execute immediate 'DROP TYPE prvt_awr_inst_meta';
    EXCEPTION WHEN obj_not_found THEN NULL;
  END;
END;
/
CREATE TYPE prvt_awr_inst_meta wrapped 
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
23e 18d
LZJKhuV05vuO0Y/Q3XiYc/Ao6ewwgwHxr9xqfHRnrf7Vz35sy3RQLwaJoNGyJ7cGVwVXk9q4
j6bmjKyasExFO1XAwpuHilfLnQ3nmpia3GGq2jrOkildTu0FrJ5xWOGbZ0anbDAUWolbsA98
wRQupqt/PAPCrRiy8LlEqQRxahy6xlFMfQLhBntqUTwUWl2FrlJHzQKlKg7Baik+DeU1dTuN
UTQJ9RPRp5P1xcFC0RyQQ3N9oA0GJbMU7j5y1+CJkhv0hNV+y75ATZp5g9JI9SEi/dp/pp6V
BIiD4GDo2FDB7XaWpXWkjZTxeP+HM5K4wIuUyWRjz2xdPPG6vBpTLEwx0PQH04qR63dnhTdW
0qgoJBT6DiErPS+A/2Apq0/i+fv3NvT+

/
show errors;
GRANT EXECUTE ON prvt_awr_inst_meta TO PUBLIC;
CREATE TYPE prvt_awr_inst_meta_tab 
AS TABLE OF prvt_awr_inst_meta;
/
show errors;
GRANT EXECUTE ON prvt_awr_inst_meta_tab TO PUBLIC;
CREATE OR REPLACE TYPE prvt_awr_xmltab
AS TABLE OF XMLTYPE;
/
show errors;
GRANT EXECUTE ON prvt_awr_xmltab TO PUBLIC;
CREATE OR REPLACE TYPE prvt_awr_evtList
AS TABLE OF VARCHAR2(64);
/
show errors;
GRANT EXECUTE ON prvt_awr_evtList TO PUBLIC;
CREATE OR REPLACE TYPE prvt_awr_numtab
AS TABLE OF NUMBER;
/
show errors;
GRANT EXECUTE ON prvt_awr_numtab TO PUBLIC;
CREATE TYPE prvt_awr_period wrapped 
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
551 2a1
Jl/RIPyFcqWGah1n+pNEgCRKHVAwg/DDLUgFfC/N2GSPb/2FyDYWGBp9uFH/3x30w0qAmFjj
pilQJjfMoJ0s8fEBCfc3uLa77etVEq4GwRyVBQiaD7WbtX2aP6SqtUKUjzCwq6ik8ycz/2b0
nth8ge/y4iuNL5DBhVb/HFq5qbkrxHgeHkbe/FDoV/KCSPdAwPC6Y+09UPjz6onMeOlSKxvP
mw5rEGGX0XTK0+cU2hHHaHSJafK6OWKzxJfAMfwezUxU6Gcx3hNBM4ruZyZd2pGldIHev52A
wpd90JLP/YH0d9PS87aSEX24ocH4S6mFiZEy1CrdMADMGwDHhWYWnki/QGryWSmjmOLL7MEO
fF4xEb02n8H6djR3egOWHaTj8Ug40wTiqp95XzxLNMKHMu2o1JXnyveoLATrdkT4phqNGcmp
2DTMqLbgpYmUd2Ke3hW2rfpA29Te+rOcJ8ky0BpZA/wHuNWQrqD1kpNHJGqFt7WI5Imar0Bf
7xw/4xPZ29LzW9I+CfM/PbfecaP5JwBlvTH3b28F8Ock4eYeo9xmCyPuGm8TGjPjclV1+8SF
aurvuuckdQ5JgChA2E9Jo0+j8HKco5VXYPbgBtyJf7cfBAsht/c+RyfgNjiraGdUCM+IjRaS
Kx4C5xC1m8vfueaA

/
show errors;
GRANT EXECUTE ON prvt_awr_period TO PUBLIC;
CREATE OR REPLACE PACKAGE prvt_awr_data wrapped 
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
a86 213
YkqKecxfuIsW86zHFV3PLJdKGCcwgw2NLtwdf3Rgk/6Oh6zbslS+9BerhQ8LcmfqzGzLqeWe
4q6jXMoNHVEVggVfQYci+F5l7EmKvRmfu/hFc7Q9sc0/mVeFl5N8hD6OY8tZRG+FmalI42Bx
GFC3dxf14Hpl6gMVZsQG4T1ZlWyZ0earNuBlPiDKnMzFIpzrKUzvlPFrojC9h99YHG/Bpe9W
FAyHnNn9yTUBMVwGYEhU+Swfj25oyd0mwx+ATAu7Rp6S3wXf+UJ3KB7M3n7920W5iJk5J/n8
lwyRF8WbJ0GicSWPh1p4C9p7hJfp3pAbusfyhwIouIhaDg6vQPTYx9BO21Hb7SHJPkY3wZ4a
AZCX6OyOwBi1lkPbnxPFRO+/w+VsNcENErvgZGnKVFkTv5CCklhUq8EWAF4Sn4EsZaG+m4MP
JJ34C52qOsDNg0gSxsA5e77kKSX2qlWNqqAJLSnMqqaTHSMtQN46TXuzz8rclf6V44Qvcdz6
zKCanZOOz1M6Nt1vPSM=

/
show errors;
GRANT EXECUTE ON prvt_awr_data TO PUBLIC;
