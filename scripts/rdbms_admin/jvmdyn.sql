-- subscript for initjvm.sql and ilk

-- Put in the entries for Dynamic registration, by default.
begin if initjvmaux.startstep('JVMDYN1_INSERT1') then

initjvmaux.exec('

insert into aurora$startup$classes$ (schema, classname) values (0, ''oracle.aurora.net.DynamicRegistration'')

');

initjvmaux.endstep; end if; end;
/

begin if initjvmaux.startstep('JVMDYN1_INSERT2') then

initjvmaux.exec('

insert into aurora$shutdown$classes$ (schema, classname) values (0, ''oracle.aurora.net.DynamicRegistration'')

');

initjvmaux.endstep; end if; end;
/


commit;
