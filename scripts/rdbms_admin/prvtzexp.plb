delete from sys.exppkgact$ 
where package = 'DBMSZEXP_SYSPKGGRNT'
/
insert into sys.exppkgact$(package, schema, class, level#)
values('DBMSZEXP_SYSPKGGRNT','SYS', 1, 2000)
/
CREATE OR REPLACE PACKAGE dbmszexp_syspkggrnt wrapped 
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
126 113
TRSR4fO7XlHs994hWlt8M2yd8W0wg3nQ2igVfHRGkxMP7vMUGyvoL1lNntxdUzSnWud3+zcv
AaY/AGJynlKbn0+79YcTWbpG1yMPGWGcC1ZkQ1LqjrBqiPVpng5CjG5fGkrKVtaPIeghwPMf
vM2I7ZnhlmM2j0lrm0RiwOrt8Da8ZUrn8DbuiVap2UTJ7NdUx2QK8RpgF4Vr4vbb+WZGTld1
V7cA93tjs2hCIYLy/9JCzdXO1QIhRu5wqys9GlQu0lgNWSUgVfuBNIQ9

/
CREATE OR REPLACE PACKAGE BODY dbmszexp_syspkggrnt wrapped 
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
13c0 5d8
HE8JRA5Nx5Xtho+TOwweDKZD9iEwg81UDCCG3y+5KvmUNPpgAt1SwtDY8UQR9PG+p6ECUeAX
luEYbxIWo1bsHGHpP88HGhH3p2KCEtVL5nAH7qXrR3iu6BUpqx82YkIzRj9zQ9DBqqr4Mw0Q
+cE6HrsPvOSBwZrnsbe95qVeiPrfAdMpF6GIb65iAfGOog4o/hFBqXFiLRSFQqdunDaCbMrp
hNMapk5AY/HAQIXiBuZhgV5Vg3iO4YKTrs3x7rI1iajS4+lFFeDzrmmFjDhTfJkZhXM6WABk
nUT38HD41/9wRjzpPgr1TDB1PhdwLHxpjQ32Onngco+kMfeGF1QDk6sICgL3scXTD89k+tIj
Isfbo4feFYqGEXyJJ/Y+FtV2S5XP6BlH7MIhBo0O0B3/Xxj04HChnpcbEuy5uZ5mumCfm4aA
cwd+viYFctUJK5wnB5Yk98OfvB7nQWCPPBZg4kmGAC0tGEAELs+/laeJtIIWPJLUG0XJ9FLz
15gRt9UV2FHf4a+0dpwq27rENXBSEbvuvbYOc2AfdgD2RgGlg7lzK70uQxC7EGPcW6aYQf7d
/rkzzGQ3HPODCb5lE4V+YKG/1OWPbkmjQs3zcbGihQwVHKvRskNeNeXTsJEnWPCPsyzMIW0q
oQPbglTauQmGKvGnwyJMrEzeEwEBCr6DLxuwzJHSXrqypVuL6X1DQ8ra7SE/Qvvz+g1ohzL4
HjWKy8iJRaF3JuU03j6PqRGMx48bwgz01D39upQ+dnrKJ7EoP6ZU0Xw7geZrkNhepdPEQTem
UB1YWE5v/1nVyk+xJYMO/HW3vhA+mKXVOdaRwq2KPOIwwFJroiyvprCrzkOz43zCeZxsrrEQ
RPUZev0+P/009goys6sToYt3SzWzD2gUETQctbRzLfidBQKgeS7F0A35KP4jXS0Na9nqXQ1M
69vtxTCg1xKGl/O9BfHzwOyuT4Yn5QSgbF4juUz2blHBnIggV+f8z3PGn+kMBi7jv2pmCcCH
k0PwP0p6dNBhbSjPXVKw7Ize9ShXBaKhluekOKYjUH6uqIHtgefUZnTWwsyJHi+OzDyMynio
yoj69Gm5HAIjtsuBUC8IIZ4z33ZZAUpwU3RnEP6kTcFHPyxdOQljVEoGaECPig2epjTsB/Y5
YLBDV4M91VCrOV4ojgd+dmUWKCdA1QJt1XtKn3OrREOI9iCH+xvl9XaKLgQEXxKtAlDZEUHQ
HbyybOKHCII10/HTuLbVYeHqlPOGcLsPaqNSYAMFj5GklmFMq3FuZ49Chwlgo4dfajaVnUSZ
Bj/ztFsieTSeov92hZl6UzExY9or3TdLqo3bn/F1bNxkgYCOox7UP2jKAdE010z52Mltc0yG
yFg1sP5wW91OkcD85cd81naQhEDqcNBD+3DGYKpTmAYjX0dKRWdid3fgnBkum11MwEdwu/JC
uFxZ3HJjtmziFUOChSampkWZr5Gb66oQq3ua

/
CREATE OR REPLACE PUBLIC SYNONYM dbmszexp_syspkggrnt FOR sys.dbmszexp_syspkggrnt
/
GRANT EXECUTE ON sys.dbmszexp_syspkggrnt TO exp_full_database
/ 
GRANT EXECUTE ON sys.dbmszexp_syspkggrnt TO execute_catalog_role
/
