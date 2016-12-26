create or replace 
package body STANDARD is         -- careful on this line; SED edit occurs!

subtype Cursor_Handle is binary_integer range 0..255;

INVALID_USERENV_PARAMETER exception;
pragma EXCEPTION_INIT(INVALID_USERENV_PARAMETER, -2003);

-- This exception is used by several sped-up STANDARD functions' ICDs to
-- indicate that the ICD is unable to compute the result, and that SQL should
-- be used to do the computation.
ICD_UNABLE_TO_COMPUTE exception;
pragma EXCEPTION_INIT(ICD_UNABLE_TO_COMPUTE, -6594);

-- icds 

  function pesxlt(ch VARCHAR2 CHARACTER SET ANY_CS,
                  cpy VARCHAR2 CHARACTER SET ch%CHARSET,
                  frm VARCHAR2 CHARACTER SET ch%CHARSET,
                  too VARCHAR2 CHARACTER SET ch%CHARSET)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma interface (c,pesxlt);

-- trig fns 
  function pesxco(c VARCHAR2 CHARACTER SET ANY_CS, format VARCHAR2) return raw;
    pragma interface (c,pesxco);

  function pesxup(ch VARCHAR2 CHARACTER SET ANY_CS, format VARCHAR2)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma interface (c,pesxup);

  function pesxlo(ch VARCHAR2 CHARACTER SET ANY_CS, format VARCHAR2)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma interface (c,pesxlo);

  function pesxcp(ch VARCHAR2 CHARACTER SET ANY_CS, format VARCHAR2)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma interface (c,pesxcp);

-- end of NLS icds

-- begin trusted icds
-- Comparisons
-- Conversions
--  function peslts(label MLSLABEL,format VARCHAR2) return VARCHAR2;
--    pragma interface (c,peslts);
--  function pesstl(label varchar2,format VARCHAR2) return MLSLABEL;
--    pragma interface (c,pesstl);
-- end trusted icds
-----------------------------------------------------------

  function sqlerrm return varchar2 is
    n1 number;
  begin
    n1 := sqlcode;
    return sqlerrm(n1);
  end sqlerrm;

  function pessdx (ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma interface (c,pessdx);

  -- Special: if the ICD raises ICD_UNABLE_TO_COMPUTE, that means we should do
  -- the old 'select soundex(...) from dual;' thing.  This allows us to do the 
  -- SELECT from PL/SQL rather than having to do it from C (within the ICD.)
  function SOUNDEX(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET is
    c VARCHAR2(2000) CHARACTER SET ch%CHARSET;
  begin
    c := pessdx(ch);
    return c;
  exception
    when ICD_UNABLE_TO_COMPUTE then
      select soundex(ch) into c from sys.dual;
      return c;
  end SOUNDEX;

  function TRANSLATE(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                     SRC VARCHAR2 CHARACTER SET STR1%CHARSET,
                     DEST VARCHAR2 CHARACTER SET STR1%CHARSET)
        return VARCHAR2 CHARACTER SET STR1%CHARSET is
  begin
    if str1 is null then return str1; else
        -- The substr and concat in arg list to pesxlt is done to
        -- allocate a modifiable COPY of the first arg, STR1. This
        -- operation is a complete cheat, because we pass the copy
        -- as an IN parm, and modify it on the sly.  
    return pesxlt(STR1, substr(str1,1,1) || substr(str1,2),
                           SRC, DEST);
    end if;
  end TRANSLATE;

  function 'REM' (LEFT NUMBER, RIGHT NUMBER) return NUMBER is
  begin
    return (LEFT - (trunc(LEFT / RIGHT) * RIGHT));
  end;

  function 'REM' (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT)
    return BINARY_FLOAT is
  begin
    return (LEFT - (trunc(LEFT / RIGHT) * RIGHT));
  end;

  function 'REM' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE)
    return BINARY_DOUBLE is
  begin
    return (LEFT - (trunc(LEFT / RIGHT) * RIGHT));
  end;

-- Just call the other to_char with a null format string. 
-- Perhaps this can be done more intelligently in the future. JEM 3/14/90.
--  function TO_CHAR(LEFT NUMBER)        return varchar2 is
--  begin
--    return TO_CHAR(LEFT, '');
--  end TO_CHAR;

-- Added 3/16/90 by JEM.
 function TO_NUMBER(LEFT NUMBER) return NUMBER is
 begin
   return(LEFT);
 end to_number;

 function TO_BINARY_FLOAT (LEFT BINARY_FLOAT) return BINARY_FLOAT is
 begin
   return(LEFT);
 end TO_BINARY_FLOAT;

 function TO_BINARY_DOUBLE(LEFT BINARY_DOUBLE) return BINARY_DOUBLE is
 begin
   return(LEFT);
 end TO_BINARY_DOUBLE;

 function 'IS NAN' (N NUMBER) RETURN BOOLEAN is
 begin
   if N IS NULL then
     return NULL;
   else
     return FALSE;
   end if;
 end 'IS NAN';

 function 'IS NOT NAN' (N NUMBER) RETURN BOOLEAN is
 begin
   if N IS NULL then
     return NULL;
   else
     return TRUE;
   end if;
 end 'IS NOT NAN';

 function NANVL(n1 NUMBER, n2 NUMBER) return NUMBER is
 begin
   return (n1);
 end NANVL;

 function NANVL(f1 BINARY_FLOAT, f2 BINARY_FLOAT) return BINARY_FLOAT is
 begin
   if f1 is nan then return (f2); else return (f1); end if;
 end NANVL; 

 function NANVL(d1 BINARY_DOUBLE, d2 BINARY_DOUBLE) return BINARY_DOUBLE is
 begin
   if d1 is nan then return (d2); else return (d1); end if;
 end NANVL; 

 function TO_DATE(LEFT NUMBER, RIGHT VARCHAR2) return DATE IS
 begin
   return (TO_DATE(TO_char(LEFT), RIGHT));
 end TO_DATE;

  function UID return PLS_INTEGER is
  i pls_integer;
  begin
        select uid into i from sys.dual;
        return i;
  end;

  function USER return varchar2 is
  c varchar2(255);
  begin
        select user into c from sys.dual;
        return c;
  end;


  function pesuen(envstr VARCHAR2) return VARCHAR2;
    pragma interface (c,pesuen);

  -- Special: if the ICD raises ICD_UNABLE_TO_COMPUTE, that means we should do 
  -- the old 'select userenv(...) from dual;' thing.  This allows us to do the 
  -- select from PL/SQL rather than having to do it from C (within the ICD.)
  function USERENV (envstr varchar2) return varchar2 is
  c varchar2(255);
  begin
    c := upper(envstr);

    -- Gaak: we can't replace the following with a single block of code based
    -- around 'USERENV(c)' because passing USERENV() anything but a string
    -- literal parameter result in ORA-2003: Invalid USERENV parameter!  This 
    -- also means that we must manually update this file whenever RDBMS adds a
    -- new option.  
    if c = 'COMMITSCN' then
      raise USERENV_COMMITSCN_ERROR;
    elsif c = 'TERMINAL' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('TERMINAL') into c from sys.dual;
      end;
    elsif c = 'ENTRYID' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('ENTRYID') into c from sys.dual;
      end;
    elsif c = 'SESSIONID' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('SESSIONID') into c from sys.dual;
      end;
    elsif c = 'LANGUAGE' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('LANGUAGE') into c from sys.dual;
      end;
    elsif c = 'LANG' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('LANG') into c from sys.dual;
      end;
    elsif c = 'INSTANCE' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('INSTANCE') into c from sys.dual;
      end;
    elsif c = 'CLIENT_INFO' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('CLIENT_INFO') into c from sys.dual;
      end;
    elsif c = 'ISDBA' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('ISDBA') into c from sys.dual;
      end;
    elsif c = 'SCHEMAID' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('SCHEMAID') into c from sys.dual;
      end;
    elsif c = 'SID' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('SID') into c from sys.dual;
      end;
    elsif c = 'PID' then
      begin
        c := pesuen(c);
      exception 
        when ICD_UNABLE_TO_COMPUTE then
          select userenv('PID') into c from sys.dual;
      end;
    else
      raise INVALID_USERENV_PARAMETER;
    end if;
    return c;
  end;

-- Trusted*Oracle additions 

  Function ROWLABEL return MLSLABEL is
        begin return null; end;
-- removed - now builtin's

--  Function TO_CHAR(label MLSLABEL, format varchar2 := '')
--       return VARCHAR2 is
--    begin return peslts(label,format); end;
--
--  Function TO_LABEL(label varchar2, format varchar2 := '')
--       return MLSLABEL is
--    begin return pesstl(label,format); end;

-- group functions 
  Function LUB (label MLSLABEL) return MLSLABEL is
        begin return null; end;
  Function GLB (label MLSLABEL) return MLSLABEL is
        begin return null; end;

-- end of Trusted*Oracle additions 

    
-- beginning of NLS routines 
-- replaced with new versions 6/3/92 JEM 

  function NLSSORT(c VARCHAR2 CHARACTER SET ANY_CS) return RAW is
  begin
    return pesxco(c,'');
  end NLSSORT;

  function NLS_UPPER(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET is
  begin
    return pesxup(ch,'');
  end NLS_UPPER;

  function NLS_LOWER(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET is
  begin
    return pesxlo(ch,'');
  end NLS_LOWER;

  function NLS_INITCAP(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET is
  begin
    return pesxcp(ch,'');
  end NLS_INITCAP;

  function NLS_CHARSET_NAME(csetid PLS_INTEGER) 
    return VARCHAR2 is
   v varchar2(2000);
  begin
   select nls_charset_name(csetid) into v from sys.dual;
   return v;
  end NLS_CHARSET_NAME;

  function NLS_CHARSET_ID(csetname VARCHAR2) 
    return PLS_INTEGER is
   i PLS_INTEGER;
  begin
   select nls_charset_id(csetname) into i from sys.dual;
   return i;
  end NLS_CHARSET_ID;

  function NLS_CHARSET_DECL_LEN(bytecnt NUMBER, csetid NUMBER) 
    return PLS_INTEGER is
   i PLS_INTEGER;
  begin
   select nls_charset_decl_len(bytecnt, csetid) into i from sys.dual;
   return i;
  end NLS_CHARSET_DECL_LEN;
-- end of NLS routines 


-- DUMP and VSIZE are now not allowed in non-sql plsql, has code to forbid 
-- it there, and is defined as a builtin in stdspc. The body will not be 
-- called in plsql.
--- CMB
----
-- dump 
-- dump( expr [,display_format[,start_pos[,length]]]) return varchar2
-- how large should the plsql varchar2 string be 
--

-- why do we need these dummy bodies for LEVEL and ROWNUM?

  function LEVEL return NUMBER is
        begin return 0.0; end;

  function ROWNUM return NUMBER is
        begin return 0.0; end;

--
-- ACOS, ASIN, ATAN, ATAN2 
--   These functions return NULL if any of the inputs are NULL
--
  function pesacos(n NUMBER) return NUMBER;
    pragma interface (c,pesacos);

  function pesasin(n NUMBER) return NUMBER;
    pragma interface (c,pesasin);

  function pesatn2(x NUMBER, y NUMBER) return NUMBER;
    pragma interface (c,pesatn2);

  function ACOS(n NUMBER) return NUMBER is
  begin
    if (n > 1) or (n < -1) then raise VALUE_ERROR; end if;
    return pesacos(n);
  end ACOS;

  function ASIN(n NUMBER) return NUMBER is
  begin
    if (n > 1) or (n < -1) then raise VALUE_ERROR; end if;
    return pesasin(n);
  end ASIN;

  function ATAN2(x NUMBER, y NUMBER) return NUMBER is
  begin
    if ((x = 0) and (y = 0)) then raise VALUE_ERROR; end if;
    return pesatn2(x, y);
  end ATAN2;

--****************************************************************

  -- This body is required, and will be called 
  function NVL (B1 "<REF_CURSOR_1>", B2 "<REF_CURSOR_1>") 
        return "<REF_CURSOR_1>" is
  begin
    if (B1 IS NULL) then return(B2); else return(B1); end if;
  end NVL;

  /* these are special internal functions
     they are potential dangerous and not to be used by customers */
  function "SYS$LOB_REPLICATION" (x in blob) return blob 
        is begin return x; end;
  function "SYS$LOB_REPLICATION" (x in clob character set any_cs) 
    return clob character set x%charset
  is begin return x; end;

  --  Generic SQL DDL routine
  --
  --  This used to use plzopn, plzosq, etc. declared above;  now we use a 
  --  single bundled call.  Move these defs here so new ICD will not disturb
  --  the ordering of the list.

  FUNCTION plzsql(stmt VARCHAR2) RETURN binary_integer;
  PRAGMA interface (c,plzsql);
  
  procedure SQL_DDL(Stmt VARCHAR2) is
         rc Binary_Integer;
         DDL_ERROR exception;
  Begin
         rc := plzsql(Stmt);
         if ( rc IS NOT NULL ) then
                RAISE DDL_ERROR;
         end if;
  End;

  --  SQL Transaction routines

  procedure SET_TRANSACTION_USE (vc varchar2) is
  Begin
         SQL_DDL('SET TRANSACTION USE ROLLBACK SEGMENT ' || vc);
  End;

  procedure COMMIT is
  Begin
         SQL_DDL('COMMIT');
  End;

  procedure COMMIT_CM (vc varchar2) is
  Begin
    -- bug13944958:
    -- COMMIT_CM procedure takes the input argument "vs" as the comment string
    -- to execute the SQL DDL "COMMIT work comment 'vc'" statement.
    -- The input comment string to the COMMIT statement is vulnerable to
    -- SQL injection because it may contain single-quotes.
    -- Before we manually quote the comment string, we need to escape any
    -- embedded quotes first.
    SQL_DDL('COMMIT work comment ' || '''' ||
            replace(vc, '''', '''''') || '''');
  End;

  procedure ROLLBACK_NR is
  Begin
         SQL_DDL('ROLLBACK');
  End;

  procedure ROLLBACK_SV(Save_Point CHAR) is
  Begin
         SQL_DDL('ROLLBACK TO ' || Save_Point);
  End;

  procedure SAVEPOINT(Save_Point CHAR) is
  begin
         SQL_DDL('SAVEPOINT ' || Save_Point);
  end;


------ Datetime code starts here ------
  
 
-- functions to create intervals from constituent parts.  

  function pesn2ymi(numerator number, units number)
    return yminterval_unconstrained;
  pragma interface (c,pesn2ymi);
  function pesn2dsi(numerator number, units number)
     return dsinterval_unconstrained;
  pragma interface (c,pesn2dsi);

  function NUMTOYMINTERVAL(numerator number, units number) 
     return yminterval_unconstrained
     is begin return pesn2ymi(numerator,units); end;
  function NUMTODSINTERVAL(numerator number, units number) 
     return dsinterval_unconstrained
     is begin return pesn2dsi(numerator,units); end;

 function NUMTOYMINTERVAL(numerator number, units varchar2 character set any_cs) 
     return yminterval_unconstrained
     IS unitno NUMBER := 0; 
        unitstr VARCHAR2(5) character set units%charset := upper(trim(units));
     begin 
     IF (unitstr = 'YEAR')  THEN unitno := 1; 
     elsif (unitstr = 'MONTH') THEN unitno := 2; 
     END IF;
     return pesn2ymi(numerator,unitno); 
     -- IF unitno := 0 core will RAISE correct error
     end;

 function NUMTODSINTERVAL(numerator number, units varchar2 character set any_cs) 
     return dsinterval_unconstrained
     IS unitno NUMBER := 0; 
        unitstr VARCHAR2(6) character set units%charset := upper(trim(units));
     begin 
     IF (unitstr = 'DAY') THEN  unitno := 1; 
     elsif (unitstr = 'HOUR') THEN unitno := 2; 
     elsif (unitstr = 'MINUTE') THEN  unitno := 3; 
     elsif (unitstr = 'SECOND') THEN unitno := 4; 
     END IF;
     return pesn2dsi(numerator,unitno); 
     -- IF unitno = 0 core will RAISE correct error
     end;
     
  function pessdt return DATE;
    pragma interface (c,pessdt);

  -- Bug 1287775: back to calling ICD.
  -- Special: if the ICD raises ICD_UNABLE_TO_COMPUTE, that means we should do 
  -- the old 'SELECT SYSDATE FROM DUAL;' thing.  This allows us to do the 
  -- SELECT from PL/SQL rather than having to do it from C (within the ICD.)
  function sysdate return date is 
    d date; 
  begin
    d := pessdt;
    return d;
  exception
    when ICD_UNABLE_TO_COMPUTE then
      select sysdate into d from sys.dual;
      return d;
  end;

  function SYS_GUID return raw is
  c raw(16);
  begin
        select sys_guid() into c from sys.dual;
        return c;
  end;

  function pessysctx2(namespace varchar2, attribute varchar2) return varchar2;
    pragma interface (c,pessysctx2);

  -- Special: if the ICD raises ICD_UNABLE_TO_COMPUTE, that means we should do 
  -- the old 'select sys_context(...) from dual;' thing.  This allows us to do 
  -- the select from PL/SQL rather than having to do it from C (within the ICD.)
  function SYS_CONTEXT(namespace varchar2, attribute varchar2)
    return varchar2 is 
  c varchar2(4000);
  BEGIN
    c := pessysctx2(namespace, attribute);
    return c;
  exception
    when ICD_UNABLE_TO_COMPUTE then
      select sys_context(namespace,attribute) into c from sys.dual;
      return c;
  end;

-- time zone functions       

  function pessts return timestamp_tz_unconstrained;
    pragma interface (c,pessts);

  -- Special: if the ICD raises ICD_UNABLE_TO_COMPUTE, that means we should do 
  -- the old 'SELECT systimestamp FROM dual;' thing.  This allows us to do the 
  -- SELECT from PL/SQL rather than having to do it from C (within the ICD.)
  FUNCTION systimestamp RETURN timestamp_tz_unconstrained 
  IS  t timestamp_tz_unconstrained;
  BEGIN
    t := pessts;
    RETURN t; 
  EXCEPTION 
    WHEN ICD_UNABLE_TO_COMPUTE THEN
      SELECT systimestamp INTO t FROM sys.dual; 
      RETURN t; 
  END;
  
  function pesdbtz return varchar2;
    pragma interface (c,pesdbtz);

  -- Special: if the ICD raises ICD_UNABLE_TO_COMPUTE, that means we should do
  -- the old 'SELECT dbtimezone FROM dual;' thing.  This allows us to do the 
  -- SELECT from PL/SQL rather than having to do it from C (within the ICD.)
  FUNCTION dbtimezone RETURN varchar2
  IS  t VARCHAR2(75);                                -- == TZNMSTRLEN [2213965]
  BEGIN 
    t := pesdbtz;
    RETURN t; 
  EXCEPTION 
    WHEN ICD_UNABLE_TO_COMPUTE THEN
      SELECT dbtimezone INTO t FROM sys.dual;
      RETURN t; 
  END;

  FUNCTION localtimestamp RETURN timestamp_unconstrained
  IS t timestamp_tz_unconstrained := current_timestamp;
  BEGIN
   RETURN (cast(t AS timestamp_unconstrained)); 
  END;
  
  FUNCTION localtime RETURN time_unconstrained
  IS t time_tz_unconstrained := current_time;
  BEGIN 
   RETURN (cast(t AS time_unconstrained)); 
  END;
  
  function pessysctx3(namespace varchar2, attribute varchar2, 
                      newoptional varchar2) return varchar2;
    pragma interface (c,pessysctx3);

  -- Special: if the ICD raises ICD_UNABLE_TO_COMPUTE, that means we should do 
  -- the old 'select sys_context(...) from dual;' thing.  This allows us to do 
  -- the select from PL/SQL rather than having to do it from C (within the ICD.)
  function SYS_CONTEXT(namespace varchar2, attribute varchar2, 
                       newoptional varchar2)
    return varchar2 is 
  c varchar2(4000);
  BEGIN
    c := pessysctx3(namespace, attribute, newoptional);
    return c;
  exception
    when ICD_UNABLE_TO_COMPUTE then
      select sys_context(namespace,attribute,newoptional) into c from sys.dual;
      return c;
  end;

  function TO_NCLOB(cl CLOB CHARACTER SET ANY_CS) return NCLOB is
  begin
    return cl;
  end;
  function TO_CLOB(cl CLOB CHARACTER SET ANY_CS) return CLOB is
  begin
    return cl;
  end;

  function NCHR(n PLS_INTEGER) return NVARCHAR2 is
  begin
    return CHR(n using NCHAR_CS);
  end;

-- REFs of opaque types are not yet supported.
--  function NVL (B1 REF "<OPAQUE_1>", B2 REF "<OPAQUE_1>")
--         return REF "<OPAQUE_1>" is
--  begin
--    if (B1 IS NULL) then return(B2); else return(B1); end if;
--  end NVL;


-- END OF PACKAGE standard  
end;



/
