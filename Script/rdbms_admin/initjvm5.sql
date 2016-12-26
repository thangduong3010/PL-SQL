-- subscript for initjvm.sql and ilk

-- create USER|DBA|ALL_JAVA_* views
@@catjvm.sql

-- SQLJ initialization
@@initsqlj

-- XA JSP initialization
@@initxa

-- Load some stuff that is mostly jars we got from sun
-- These used to be loaded by initjis, but that has gone away

begin if initjvmaux.startstep('LOAD_JIS_JARS') then
  -- noverify is suppressing a warning.
  dbms_java.loadjava('-noverify -resolve -install -synonym -grant PUBLIC lib/activation.jar lib/mail.jar javavm/lib/logging.properties');

  initjvmaux.endstep;
end if; end;
/
