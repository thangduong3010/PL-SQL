create or replace type wmsys.wm_concat_impl wrapped 
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
1f8 150
YUIR1Dz0MSRYQuBTM5CNlAO2qhIwg43INQxqZy8CAMHqR383cV9wKEEbBfqfkb+2yRe6zQE+
AL0rAOf5EMTMGONve5yIi6/+MK4sSazQhBmdvIq/uzoppTN0dfWVDHyhRqyLjqGm719zAIg7
/J7JPoCUFgNgf9WJ4rwpb8Rt6HOoF15IeDN5XEHMzDHdyKzMHB1fDGoRO8jpbMvYX0rEw4CM
KN3prp79T9cEdCfJJL45RiGhqcjPrmVeAKRytU3yCSuk+rKq77p14q690YsfNMG4wM7w+VE7
s2zsO8HFcLgRhsSVlUpB20Fyx9hk2g9xPWhMEOF0bAee

/
exec wmsys.wm$execSQL('grant execute on wm_concat_impl to public')  ;
create or replace function wmsys.wm_concat wrapped 
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
53 96
antgYqrbNGLSC7Re+71hueZFyT4wg0SvLZ6pyi+mUCJD1KOsoxPiallQXtwu7BTsCmx9/hIg
+ln6MEC75cHHT8YFQPvfjqPM1MuiY1Z0kXN0TQ0W8KE1SkAqjh/+tB/q+oI45dREmV5OHaYy
H/E=

/
exec wmsys.wm$execSQL('revoke all on wm_concat from public')  ;
exec wmsys.wm$execSQL('grant execute on wm_concat to public')  ;
create or replace public synonym wm_concat for wmsys.wm_concat  ;
