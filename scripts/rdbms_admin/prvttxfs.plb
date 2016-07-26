CREATE OR REPLACE PACKAGE dbms_transform_internal wrapped 
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
407 185
ca06YE1ksPOR/CUAySv+50Z41wQwg5DxLvZqfHRAv7lkUFLWkJ/NofSNPUdhrH4g0pGjYa9w
18rNtRfe2X2b6SWS4O86s9XtTdvkRE+9GcSYEHt3Eye1Ol67Jeoyzk0K13gRnVSmiRWtJhY2
e0PmBBZENcG7E3HBzs/pbxI4zdyx1fK85kIjitbLYvtopm8V34EBmMrd56s8bEwKiFeysnuZ
ih7X4dA/H1Zv1sl4OaxR4Yy9j1F/HVygroOnVjhpIgvfRtf4ZPI31Otqwpjhp43RPLE73fCZ
fPA451EDtNgabd/vOtCQ78dVbjyroGT2GYkS8lNZzTmSG0Gb9Jpx9g4IPP+1lm9htSwTyrBn
ATwPGrefN9trkxlz4Z8Acvo=

/
CREATE OR REPLACE PACKAGE dbms_transform_eximp_internal wrapped 
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
313 17d
KTsfyA90gtONU/+PS7WPY3httZcwg5DxLq5qfHRArbvqXbTyblMzXRrRmV2MwNOPb7J/GqGg
DkhbPyLNCXmULGNwOo+iI5u8YV7WUwL2ka7Q1yIcRS6Yqj/N7FMQmiogUrEcYUyYQjiPK9XU
CSuv55Y7OCqTN//prnBxNruhm1akkfqSyEBYDq0lQ93XgAaK7TWrU9rKLTlFo1mrUIXokf/n
EA5O6VJIOCLQEI03kv4nygfGxAO8IGNgWDUX47fZTy57LWCyJmGvlhpgWCQJp5oOpSb5XXyW
P7pw31XdUTquW6rhVPSUNkP419UqeJzdAKXMuU+48flv/7e7ZA+mLvry4sbo1Qx7BtZ3MonU
74hplZVb0iGwfQ==

/
CREATE OR REPLACE PACKAGE dbms_transform_eximp wrapped 
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
57c 1ee
r+DNPVTWmsXgj+YWTRSQC+73Xzwwg9eJf65qfC8CWE7VemEJSTzcH8Eloi5+xyIfe5PKZ+AW
Dqc3T9C2dxve7KABZoSOMT/+QZ3HfmfRODcGOt4DTg8Fxv5VHsafhg+8mt9P4XYXQmYa7+aV
GZMU+98YRqhif1JGZpbwGzNZDn7lJjb/Dezn8/SMsIfuO0dLRskh6j0SRBSCDrr3cJ7icGtx
zEflWDdlnvJ+0J/ZbivoGtlBtYH7/GU036S1beFLuQW1Aqm5BSycWP+EtzlFXTdY+QEH5XCH
KbOQ1yPFEuowz3xGPECMeNTvMvIrxoJZozlss8HFPY0wJUq6DAdzRYtio7F95nGMYnh7XrTI
QFI39WDsBRRAn3fZY9UaHYz2JcU0/lJrQ2XP9sak2d5ibJGA/GkgIlRkVUAPMC62Uet+gLe5
NUHvLbCfSFUcs03eaoxRs0CzW/Nr8qLTnGG+72rJaiitnTr7/jDKWQ==

/
CREATE OR REPLACE PUBLIC SYNONYM dbms_transform_eximp
   FOR sys.dbms_transform_eximp
/
GRANT EXECUTE ON sys.dbms_transform_eximp TO PUBLIC
/
GRANT EXECUTE ON sys.dbms_transform_eximp TO SYSTEM WITH GRANT OPTION
/
GRANT EXECUTE ON sys.dbms_transform_eximp TO imp_full_database
/
GRANT EXECUTE ON sys.dbms_transform_eximp TO exp_full_database
/
GRANT EXECUTE ON sys.dbms_transform_eximp TO execute_catalog_role
/
