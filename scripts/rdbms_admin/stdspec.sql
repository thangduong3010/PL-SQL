create or replace 
package STANDARD AUTHID CURRENT_USER is              -- careful on this line; SED edit occurs!

  /********** Types and subtypes, do not reorder **********/
  type BOOLEAN is (FALSE, TRUE);

  type DATE is DATE_BASE;

  type NUMBER is NUMBER_BASE;
  subtype FLOAT is NUMBER; -- NUMBER(126)
  subtype REAL is FLOAT; -- FLOAT(63)
  subtype "DOUBLE PRECISION" is FLOAT;
  subtype INTEGER is NUMBER(38,0);
  subtype INT is INTEGER;
  subtype SMALLINT is NUMBER(38,0);
  subtype DECIMAL is NUMBER(38,0);
  subtype NUMERIC is DECIMAL;
  subtype DEC is DECIMAL;


  subtype BINARY_INTEGER is INTEGER range '-2147483647'..2147483647;
  subtype NATURAL is BINARY_INTEGER range 0..2147483647;
  subtype NATURALN is NATURAL not null;
  subtype POSITIVE is BINARY_INTEGER range 1..2147483647;
  subtype POSITIVEN is POSITIVE not null;
  subtype SIGNTYPE is BINARY_INTEGER range '-1'..1;  -- for SIGN functions

  type VARCHAR2 is NEW CHAR_BASE;

  subtype VARCHAR is VARCHAR2;
  subtype STRING is VARCHAR2;

  subtype LONG is VARCHAR2(32760);

  subtype RAW is VARCHAR2;
  subtype "LONG RAW" is RAW(32760);

  subtype ROWID is VARCHAR2(256);

  -- Ansi fixed-length char
  -- Define synonyms for CHAR and CHARN.
  subtype CHAR is VARCHAR2;
  subtype CHARACTER is CHAR;

  type MLSLABEL is new CHAR_BASE;

  -- Large object data types.
  --  binary, character, binary file.
  type  BLOB is BLOB_BASE;
  type  CLOB is CLOB_BASE;
  type  BFILE is BFILE_BASE;

  -- Verbose and NCHAR type names
  subtype "CHARACTER VARYING" is VARCHAR;
  subtype "CHAR VARYING" is VARCHAR;
  subtype "NATIONAL CHARACTER" is CHAR CHARACTER SET NCHAR_CS;
  subtype "NATIONAL CHAR" is CHAR CHARACTER SET NCHAR_CS;
  subtype "NCHAR" is CHAR CHARACTER SET NCHAR_CS;
  subtype "NATIONAL CHARACTER VARYING" is VARCHAR CHARACTER SET NCHAR_CS;
  subtype "NATIONAL CHAR VARYING" is VARCHAR CHARACTER SET NCHAR_CS;
  subtype "NCHAR VARYING" is VARCHAR CHARACTER SET NCHAR_CS;
  subtype "NVARCHAR2" is VARCHAR2 CHARACTER SET NCHAR_CS;
  subtype "CHARACTER LARGE OBJECT" is CLOB;
  subtype "CHAR LARGE OBJECT" is CLOB;
  subtype "NATIONAL CHARACTER LARGE OBJEC" is CLOB CHARACTER SET NCHAR_CS;
  subtype "NCHAR LARGE OBJECT" is CLOB CHARACTER SET NCHAR_CS;
  subtype "NCLOB" is CLOB CHARACTER SET NCHAR_CS;
  subtype "BINARY LARGE OBJECT" is BLOB;

  subtype pls_integer is binary_integer;

  type TIME is new DATE_BASE;
  type TIMESTAMP is new DATE_BASE;
  type "TIME WITH TIME ZONE" is new DATE_BASE;
  type "TIMESTAMP WITH TIME ZONE" is new DATE_BASE;
  type "INTERVAL YEAR TO MONTH" is new DATE_BASE;
  type "INTERVAL DAY TO SECOND" is new DATE_BASE;

  SUBTYPE TIME_UNCONSTRAINED IS TIME(9);
  SUBTYPE TIME_TZ_UNCONSTRAINED IS TIME(9) WITH TIME ZONE;
  SUBTYPE TIMESTAMP_UNCONSTRAINED IS TIMESTAMP(9);
  SUBTYPE TIMESTAMP_TZ_UNCONSTRAINED IS TIMESTAMP(9) WITH TIME ZONE;
  SUBTYPE YMINTERVAL_UNCONSTRAINED IS INTERVAL YEAR(9) TO MONTH;
  SUBTYPE DSINTERVAL_UNCONSTRAINED IS INTERVAL DAY(9) TO SECOND (9);

  TYPE UROWID IS NEW CHAR_BASE;

  type "TIMESTAMP WITH LOCAL TIME ZONE" is new DATE_BASE;
  subtype timestamp_ltz_unconstrained is timestamp(9) with local time zone;

  subtype BINARY_FLOAT is NUMBER;
  subtype BINARY_DOUBLE is NUMBER;

  -- The following data types are generics, used specially within package
  -- STANDARD and some other Oracle packages.  They are protected against
  -- other use; sorry.  True generic types are not yet part of the language.

  type "<ADT_1>" as object (dummy char(1));
  type "<RECORD_1>" is record (dummy char(1));
  type "<TUPLE_1>" as object (dummy char(1));
  type "<VARRAY_1>" is varray (1) of char(1);
  type "<V2_TABLE_1>" is table of char(1) index by binary_integer;
  type "<TABLE_1>" is table of char(1);
  type "<COLLECTION_1>" is table of char(1);
  type "<REF_CURSOR_1>" is ref cursor;

  -- This will actually match against a Q_TABLE
  type "<TYPED_TABLE>" is table of  "<ADT_1>";
  subtype "<ADT_WITH_OID>" is "<TYPED_TABLE>";

  -- The following generic index table data types are used by the PL/SQL
  -- compiler to materialize an array attribute at the runtime (for more
  -- details about the array attributes, please see Bulk Binds document).
  type " SYS$INT_V2TABLE" is table of pls_integer index by binary_integer;

  -- The following record type and the corresponding generic index table 
  -- data types are used by the PL/SQL compiler to materialize a table
  -- at the runtime in order to record the exceptions raised during the
  -- execution of FORALL bulk bind statement (for more details, please 
  -- see bulk binds extensions document in 8.2).
  type " SYS$BULK_ERROR_RECORD" is
          record (error_index pls_integer, error_code pls_integer);
  type " SYS$REC_V2TABLE" is table of " SYS$BULK_ERROR_RECORD"
                               index by binary_integer;

  /* Adding a generic weak ref cursor type */
  type sys_refcursor is ref cursor;

  /* the following data type is a generic for all opaque types */
  type "<OPAQUE_1>" as opaque FIXED(1) USING LIBRARY dummy_lib
    (static function dummy return number);

  type "<ASSOC_ARRAY_1>" is table of char(1) index by varchar2(1);

  /********** Add new types or subtypes here **********/

  -- Simple scalar types

  subtype SIMPLE_INTEGER is BINARY_INTEGER NOT NULL;
  subtype SIMPLE_FLOAT   is BINARY_FLOAT   NOT NULL;
  subtype SIMPLE_DOUBLE  is BINARY_DOUBLE  NOT NULL;

  /********** Predefined constants **********/

  BINARY_FLOAT_NAN constant BINARY_FLOAT;
  BINARY_FLOAT_INFINITY constant BINARY_FLOAT;
  BINARY_FLOAT_MAX_NORMAL constant BINARY_FLOAT;
  BINARY_FLOAT_MIN_NORMAL constant BINARY_FLOAT;
  BINARY_FLOAT_MAX_SUBNORMAL constant BINARY_FLOAT;
  BINARY_FLOAT_MIN_SUBNORMAL constant BINARY_FLOAT;
  BINARY_DOUBLE_NAN constant BINARY_DOUBLE;
  BINARY_DOUBLE_INFINITY constant BINARY_DOUBLE;
  BINARY_DOUBLE_MAX_NORMAL constant BINARY_DOUBLE;
  BINARY_DOUBLE_MIN_NORMAL constant BINARY_DOUBLE;
  BINARY_DOUBLE_MAX_SUBNORMAL constant BINARY_DOUBLE;
  BINARY_DOUBLE_MIN_SUBNORMAL constant BINARY_DOUBLE;

  /********** Add new constants here **********/

  /********** Predefined exceptions **********/

  CURSOR_ALREADY_OPEN exception;
    pragma EXCEPTION_INIT(CURSOR_ALREADY_OPEN, '-6511');

  DUP_VAL_ON_INDEX exception;
    pragma EXCEPTION_INIT(DUP_VAL_ON_INDEX, '-0001');

  TIMEOUT_ON_RESOURCE exception;
    pragma EXCEPTION_INIT(TIMEOUT_ON_RESOURCE, '-0051');

  INVALID_CURSOR exception;
    pragma EXCEPTION_INIT(INVALID_CURSOR, '-1001');

  NOT_LOGGED_ON exception;
    pragma EXCEPTION_INIT(NOT_LOGGED_ON, '-1012');

  LOGIN_DENIED exception;
    pragma EXCEPTION_INIT(LOGIN_DENIED, '-1017');

  NO_DATA_FOUND exception;
    pragma EXCEPTION_INIT(NO_DATA_FOUND, 100);

  ZERO_DIVIDE exception;
    pragma EXCEPTION_INIT(ZERO_DIVIDE, '-1476');

  INVALID_NUMBER exception;
    pragma EXCEPTION_INIT(INVALID_NUMBER, '-1722');

  TOO_MANY_ROWS exception;
    pragma EXCEPTION_INIT(TOO_MANY_ROWS, '-1422');

  STORAGE_ERROR exception;
    pragma EXCEPTION_INIT(STORAGE_ERROR, '-6500');

  PROGRAM_ERROR exception;
    pragma EXCEPTION_INIT(PROGRAM_ERROR, '-6501');

  VALUE_ERROR exception;
    pragma EXCEPTION_INIT(VALUE_ERROR, '-6502');

  ACCESS_INTO_NULL exception;
    pragma EXCEPTION_INIT(ACCESS_INTO_NULL, '-6530');

  COLLECTION_IS_NULL exception;
    pragma EXCEPTION_INIT(COLLECTION_IS_NULL , '-6531');

  SUBSCRIPT_OUTSIDE_LIMIT exception;
    pragma EXCEPTION_INIT(SUBSCRIPT_OUTSIDE_LIMIT,'-6532');

  SUBSCRIPT_BEYOND_COUNT exception;
    pragma EXCEPTION_INIT(SUBSCRIPT_BEYOND_COUNT ,'-6533');

  -- exception for ref cursors
  ROWTYPE_MISMATCH exception;
  pragma EXCEPTION_INIT(ROWTYPE_MISMATCH, '-6504');

  SYS_INVALID_ROWID  EXCEPTION;
  PRAGMA EXCEPTION_INIT(SYS_INVALID_ROWID, '-1410');

  -- The object instance i.e. SELF is null
  SELF_IS_NULL exception;
    pragma EXCEPTION_INIT(SELF_IS_NULL, '-30625');

  CASE_NOT_FOUND exception;
    pragma EXCEPTION_INIT(CASE_NOT_FOUND, '-6592');

  -- Added for USERENV enhancement, bug 1622213.
  USERENV_COMMITSCN_ERROR exception;
    pragma EXCEPTION_INIT(USERENV_COMMITSCN_ERROR, '-1725');

  -- Parallel and pipelined support
  NO_DATA_NEEDED exception;
    pragma EXCEPTION_INIT(NO_DATA_NEEDED, '-6548');
  -- End of 8.2 parallel and pipelined support

  /********** Add new exceptions here **********/

  /********** Function, operators and procedures **********/

  function "EXISTS" return BOOLEAN;
    pragma BUILTIN('EXISTS',10,240,240); -- This is special cased in PH2 -- Pj

  function GREATEST (pattern NUMBER) return NUMBER;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj
  function GREATEST (pattern VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET pattern%CHARSET;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj
  function GREATEST (pattern DATE) return DATE;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj

  function LEAST (pattern NUMBER) return NUMBER;
    pragma BUILTIN('LEAST',13,240,240);-- This is special cased in PH2 -- Pj
  function LEAST (pattern VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET pattern%CHARSET;
    pragma BUILTIN('LEAST',13,240,240);-- This is special cased in PH2 -- Pj
  function LEAST (pattern DATE) return DATE;
    pragma BUILTIN('LEAST',13,240,240);-- This is special cased in PH2 -- Pj

  function DECODE (expr NUMBER, pat NUMBER, res NUMBER) return NUMBER;
    pragma BUILTIN('DECODE',22,240,240);-- This is special cased in PH2 -- Pj
  function DECODE (expr NUMBER,
                   pat NUMBER,
                   res VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET res%CHARSET;
    pragma BUILTIN('DECODE',22,240,240);-- This is special cased in PH2 -- Pj
  function DECODE (expr NUMBER, pat NUMBER, res DATE) return DATE;
    pragma BUILTIN('DECODE',22,240,240);-- This is special cased in PH2 -- Pj

  function DECODE (expr VARCHAR2 CHARACTER SET ANY_CS,
                   pat VARCHAR2 CHARACTER SET expr%CHARSET,
                   res NUMBER) return NUMBER;
    pragma BUILTIN('DECODE',22,240,240);-- This is special cased in PH2 -- Pj
  function DECODE (expr VARCHAR2 CHARACTER SET ANY_CS,
                   pat VARCHAR2 CHARACTER SET expr%CHARSET,
                   res VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET res%CHARSET;
    pragma BUILTIN('DECODE',22,240,240);-- This is special cased in PH2 -- Pj
  function DECODE (expr VARCHAR2 CHARACTER SET ANY_CS,
                   pat VARCHAR2 CHARACTER SET expr%CHARSET,
                   res DATE) return DATE;
    pragma BUILTIN('DECODE',22,240,240);-- This is special cased in PH2 -- Pj

  function DECODE (expr DATE, pat DATE, res NUMBER) return NUMBER;
    pragma BUILTIN('DECODE',22,240,240);-- This is special cased in PH2 -- Pj
  function DECODE (expr DATE,
                   pat DATE,
                   res VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET res%CHARSET;
    pragma BUILTIN('DECODE',22,240,240);-- This is special cased in PH2 -- Pj
  function DECODE (expr DATE, pat DATE, res DATE) return DATE;
    pragma BUILTIN('DECODE',22,240,240);-- This is special cased in PH2 -- Pj

  function SQLCODE return PLS_INTEGER;
    pragma BUILTIN('SQLCODE',45, 10, 0); -- PEMS_DB, DB_SQLCODE

  function SQLERRM return varchar2;
    pragma FIPSFLAG('SQLERRM', 1452);   

  function SQLERRM (code PLS_INTEGER) return varchar2;
    pragma BUILTIN('SQLERRM',46, 10, 1); -- PEMS_DB, DB_SQLERRM
    pragma FIPSFLAG('SQLERRM', 1452);   

  function LEVEL return NUMBER;

  function ROWNUM return NUMBER;

  function '='  (LEFT BOOLEAN, RIGHT BOOLEAN) return BOOLEAN;
    pragma BUILTIN('=',2, 3, 1); -- PEMS_INTEGER, PEMDCMEQ
    pragma FIPSFLAG('=', 1450); 
  function '!=' (LEFT BOOLEAN, RIGHT BOOLEAN) return BOOLEAN; -- also <> and ~=
    pragma BUILTIN('!=',5, 3, 2); -- PEMS_INTEGER, PEMDCMNE
    pragma FIPSFLAG('!=', 1450);        
  function '<'  (LEFT BOOLEAN, RIGHT BOOLEAN) return BOOLEAN;
    pragma BUILTIN('<',4, 3, 3);  -- PEMS_INTEGER, PEMDCMLT
    pragma FIPSFLAG('<', 1450); 
  function '<=' (LEFT BOOLEAN, RIGHT BOOLEAN) return BOOLEAN;
    pragma BUILTIN('<=',6, 3, 4); -- PEMS_INTEGER, PEMDCMLE
    pragma FIPSFLAG('<=', 1450);        
  function '>'  (LEFT BOOLEAN, RIGHT BOOLEAN) return BOOLEAN;
    pragma BUILTIN('>',1, 3, 5); -- PEMS_INTEGER, PEMDCMGT
    pragma FIPSFLAG('>', 1450); 
  function '>=' (LEFT BOOLEAN, RIGHT BOOLEAN) return BOOLEAN;
    pragma BUILTIN('>=',3, 3, 6); -- PEMS_INTEGER, PEMDMGE
    pragma FIPSFLAG('>=', 1450);        

  --  Since SQL permits short-circuit evaluation, the 'and' and 'or'
  --  operations will always be interpreted as 'and then' and 'or else'
  --  when they occur in conditional statements.

  function XOR (LEFT BOOLEAN, RIGHT BOOLEAN) return BOOLEAN;
    pragma BUILTIN('XOR',8, 3, 9); -- PEMS_INTEGER, INT_XOR
    pragma FIPSFLAG('XOR', 1450);       

  function 'NOT' (RIGHT BOOLEAN) return BOOLEAN;
    pragma BUILTIN('NOT',9, 3, 10); -- PEMS_INTEGER, INT_NOT

  function 'IS NULL' (B BOOLEAN) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 3, 0);  -- PEMS_INTEGER, PEMDNUL
    pragma FIPSFLAG('IS NULL', 1450);   

  function 'IS NOT NULL' (B BOOLEAN) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 3, 50); -- PEMS_INTEGER, PEMDNUL
    pragma FIPSFLAG('IS NOT NULL', 1450);       

  function NVL (B1 BOOLEAN, B2 BOOLEAN) return BOOLEAN;
    pragma FIPSFLAG('NVL', 1450);       

  function '='  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('=',2, 1, 14); -- PEMS_CHAR, PEMDCMEQ (VARCHAR2 SEMANTICS)
    pragma FIPSFLAG('=', 1454);
  function '!=' (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('!=',5, 1, 15);  -- PEMS_CHAR, PEMDCMNE (VARCHAR2 SEMANTICS)
    pragma FIPSFLAG('!=', 1454);
  function '<'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('<',4, 1, 16); -- PEMS_CHAR, PEMDCMLT (VARCHAR2 SEMANTICS)
    pragma FIPSFLAG('<', 1454);
  function '<=' (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('<=',6, 1, 17); -- PEMS_CHAR, PEMDCMLE (VARCHAR2 SEMANTICS)
    pragma FIPSFLAG('<=', 1454);
  function '>'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('>',1, 1, 18); -- PEMS_CHAR, PEMDCMGT (VARCHAR2 SEMANTICS)
    pragma FIPSFLAG('>', 1454);
  function '>=' (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('>=',3, 1, 19); -- PEMS_CHAR, PEMDCMGE (VARCHAR2 SEMANTICS)
    pragma FIPSFLAG('>=', 1454);

  function '||' (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET LEFT%CHARSET;
    pragma BUILTIN('||',25, 1, 7); -- PEMS_CHAR, CHAR_CONCAT
    pragma FIPSFLAG('||', 1454);

  function CONCAT(LEFT VARCHAR2 CHARACTER SET ANY_CS,
                  RIGHT VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET LEFT%CHARSET;
    pragma BUILTIN(CONCAT,25, 1, 7); -- PEMS_CHAR, CHAR_CONCAT
    pragma FIPSFLAG(CONCAT, 1454);

  function LENGTH(ch VARCHAR2 CHARACTER SET ANY_CS) return natural;
    pragma FIPSFLAG('LENGTH', 1452);   
  -- In SUBSTR, LEN defaults to remainder of string
  -- In substr and instr, a negative value of parameter POS means to
  -- count from the right end of the string.
  function SUBSTR(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                  POS PLS_INTEGER,
                  LEN PLS_INTEGER := 2147483647)
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('SUBSTR', 1452);    

  -- Find nth occurrence of str1 in str2 starting at pos
  function INSTR(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                 STR2 VARCHAR2 CHARACTER SET STR1%CHARSET,
                 POS PLS_INTEGER := 1,
                 NTH POSITIVE := 1) return PLS_INTEGER;
    pragma FIPSFLAG('INSTR', 1452);     

  function UPPER(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('UPPER', 1452);     
  function LOWER(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('LOWER', 1452);     
  function ASCII(ch VARCHAR2 CHARACTER SET ANY_CS)
        return PLS_INTEGER; -- should be ASCII.CHRANGE
    pragma FIPSFLAG('ASCII', 1452);     
  function ASCIISTR(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('ASCIISTR', 1452);
  function UNISTR(ch VARCHAR2 CHARACTER SET ANY_CS)
        return NVARCHAR2;
    pragma FIPSFLAG('UNISTR', 1452);
  function CHR(n PLS_INTEGER) return varchar2;  -- N should be ASCII.CHRANGE
    pragma FIPSFLAG('CHR', 1452);       
  function " SYS$STANDARD_CHR"(n PLS_INTEGER,csn VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET csn%CHARSET;
    pragma FIPSFLAG(' SYS$STANDARD_CHR', 1452);
  function INITCAP(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('INITCAP', 1452);   
  function SOUNDEX(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('SOUNDEX', 1452);   

  function LPAD(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                LEN pls_integer,
                PAD VARCHAR2 CHARACTER SET STR1%CHARSET)
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('LPAD', 1452);      
  function LPAD(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                LEN pls_integer)
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
  pragma FIPSFLAG('LPAD', 1452);

  function RPAD(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                LEN pls_integer,
                PAD VARCHAR2 CHARACTER SET STR1%CHARSET)
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('RPAD', 1452);       
  function RPAD(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                LEN pls_integer)
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('RPAD', 1452);       

  function TRANSLATE(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                     SRC VARCHAR2 CHARACTER SET STR1%CHARSET,
                     DEST VARCHAR2 CHARACTER SET STR1%CHARSET)
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('TRANSLATE', 1452); 

  function REPLACE(SRCSTR VARCHAR2 CHARACTER SET ANY_CS,
                   OLDSUB VARCHAR2 CHARACTER SET SRCSTR%CHARSET,
                   NEWSUB VARCHAR2 CHARACTER SET SRCSTR%CHARSET := NULL)
        return VARCHAR2 CHARACTER SET SRCSTR%CHARSET;
    pragma FIPSFLAG('REPLACE', 1452);

  function LTRIM(STR1 VARCHAR2 CHARACTER SET ANY_CS := ' ',
                 TSET VARCHAR2 CHARACTER SET STR1%CHARSET)
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('LTRIM', 1452);
  function LTRIM(STR1 VARCHAR2 CHARACTER SET ANY_CS := ' ')
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('LTRIM', 1452);

  function RTRIM(STR1 VARCHAR2 CHARACTER SET ANY_CS := ' ',
                 TSET VARCHAR2 CHARACTER SET STR1%CHARSET)
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('RTRIM', 1452);
  function RTRIM(STR1 VARCHAR2 CHARACTER SET ANY_CS := ' ')
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('RTRIM', 1452);

  function 'LIKE' (str VARCHAR2 CHARACTER SET ANY_CS,
                   pat VARCHAR2 CHARACTER SET str%CHARSET)
        return BOOLEAN;
  function 'NOT_LIKE' (str VARCHAR2 CHARACTER SET ANY_CS,
                       pat VARCHAR2 CHARACTER SET str%CHARSET)
        return BOOLEAN;
  function 'LIKE' (str VARCHAR2 CHARACTER SET ANY_CS,
                   pat VARCHAR2 CHARACTER SET str%CHARSET,
                   esc VARCHAR2 CHARACTER SET str%CHARSET)
        return BOOLEAN;
  function 'NOT_LIKE' (str VARCHAR2 CHARACTER SET ANY_CS,
                       pat VARCHAR2 CHARACTER SET str%CHARSET,
                       esc VARCHAR2 CHARACTER SET str%CHARSET)
        return BOOLEAN;
  function 'IS NULL' (s VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 1, 20);  -- PEMS_CHAR, PEMDNUL
  function 'IS NOT NULL' (s VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 1, 50); -- PEMS_CHAR, PEMDNUL

  function NVL(s1 VARCHAR2 CHARACTER SET ANY_CS,
               s2 VARCHAR2 CHARACTER SET s1%CHARSET)
        return VARCHAR2 CHARACTER SET s1%CHARSET;
    pragma FIPSFLAG('NVL', 1452);


  function '='  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
    pragma BUILTIN('=',2, 2, 1); -- PEMS_NUMBER, PEMDCMEQ
  function '!=' (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;  -- also <> and ~=
    pragma BUILTIN('!=',5, 2, 2); -- PEMS_NUMBER, PEMDCMNE
    pragma FIPSFLAG('!=', 1452);
  function '<'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
    pragma BUILTIN('<',4, 2, 3); -- PEMS_NUMBER, PEMDCMLT
  function '<=' (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
    pragma BUILTIN('<=',6, 2, 4); -- PEMS_NUMBER, PEMDCMLE
  function '>'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
    pragma BUILTIN('>',1, 2, 5); -- PEMS_NUMBER, PEMDCMGT
  function '>=' (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
    pragma BUILTIN('>=',3, 2, 6); -- PEMS_NUMBER, PEMDCMGE

  function 'IS NULL' (n NUMBER) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 2, 0); -- PEMS_NUMBER, PEMDNUL
  function 'IS NOT NULL' (n NUMBER) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 2, 50); -- PEMS_NUMBER, PEMDNUL

  function NVL(n1 NUMBER, n2 NUMBER) return NUMBER;
    pragma FIPSFLAG('NVL', 1452);

  function '+' (RIGHT NUMBER) return NUMBER;
    pragma BUILTIN('+',14, 0, 1); -- PEMS_QUICK
  function '-' (RIGHT NUMBER) return NUMBER;
    pragma BUILTIN('-',15, 2, 7); -- PEMS_NUMBER, NUM_NEG
  function ABS(n NUMBER) return NUMBER;
    pragma FIPSFLAG('ABS', 1452);

  function '+' (LEFT NUMBER, RIGHT NUMBER) return NUMBER;
    pragma BUILTIN('+',14, 2, 8); -- PEMS_NUMBER, NUM_ADD
  function '-' (LEFT NUMBER, RIGHT NUMBER) return NUMBER;
    pragma BUILTIN('-',15, 2, 9); -- PEMS_NUMBER, NUM_SUB
  function '*' (LEFT NUMBER, RIGHT NUMBER) return NUMBER;
    pragma BUILTIN('*',17, 2, 10); -- PEMS_NUMBER, NUM_MUL
  function '/' (LEFT NUMBER, RIGHT NUMBER) return NUMBER;
    pragma BUILTIN('/',18, 2, 11); -- PEMS_NUMBER, NUM_DIV

  function 'REM' (LEFT NUMBER, RIGHT NUMBER) return NUMBER;
    pragma FIPSFLAG('REM', 1452);
  function 'MOD'(n1 NUMBER, n2 NUMBER) return NUMBER;
    pragma FIPSFLAG('MOD', 1452);

  function '**' (LEFT NUMBER, RIGHT NUMBER) return NUMBER;
    pragma FIPSFLAG('**', 1452);

  function FLOOR(n NUMBER) return NUMBER;
    pragma FIPSFLAG('FLOOR', 1452);
  function CEIL(n NUMBER) return NUMBER;
    pragma FIPSFLAG('CEIL', 1452);
  function SQRT(n NUMBER) return NUMBER;
    pragma FIPSFLAG('SQRT', 1452);
  function SIGN(n NUMBER) return SIGNTYPE;
  pragma FIPSFLAG('SIGN', 1452);

  function COS(N NUMBER) return NUMBER;
    pragma FIPSFLAG('COS', 1452);
  function SIN(N NUMBER) return NUMBER;
    pragma FIPSFLAG('SIN', 1452);
  function TAN(N NUMBER) return NUMBER;
    pragma FIPSFLAG('TAN', 1452);
  function COSH(N NUMBER) return NUMBER;
    pragma FIPSFLAG('COSH', 1452);
  function SINH(N NUMBER) return NUMBER;
    pragma FIPSFLAG('SINH', 1452);
  function TANH(N NUMBER) return NUMBER;
    pragma FIPSFLAG('TANH', 1452);

  function EXP(N NUMBER) return NUMBER;
  function LN(N NUMBER) return NUMBER;

  function BITAND (LEFT pls_integer, RIGHT pls_integer)  
        return pls_integer; 
  function BITAND (LEFT integer, RIGHT integer)
        return integer; 
  function LOG (LEFT NUMBER, RIGHT NUMBER) return NUMBER;

  function TRUNC (n NUMBER, places pls_integer := 0) return NUMBER;
    pragma FIPSFLAG('TRUNC', 1452);

  function ROUND (LEFT NUMBER, RIGHT pls_integer := 0) return NUMBER;
    pragma FIPSFLAG('ROUND', 1452);

  function POWER (n NUMBER, e NUMBER) return NUMBER;
    pragma FIPSFLAG('POWER', 1452);

  function '='  (LEFT DATE, RIGHT DATE) return BOOLEAN;
    pragma BUILTIN('=',2, 12, 1); -- PEMS_DATE, PEMDCMEQ
    pragma FIPSFLAG('=', 1450);
  function '!=' (LEFT DATE, RIGHT DATE) return BOOLEAN;  -- also <> and ~=
    pragma BUILTIN('!=',5, 12, 2); -- PEMS_DATE, PEMDCMNE
    pragma FIPSFLAG('!=', 1450);
  function '<'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
    pragma BUILTIN('<',4, 12, 3); -- PEMS_DATE, PEMDCMLT
    pragma FIPSFLAG('<', 1450);
  function '<=' (LEFT DATE, RIGHT DATE) return BOOLEAN;
    pragma BUILTIN('<=',6, 12, 4); -- PEMS_DATE, PEMDCMLE
    pragma FIPSFLAG('<=', 1450);
  function '>'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
    pragma BUILTIN('>',1, 12, 5);  -- PEMS_DATE, PEMDCMGT
    pragma FIPSFLAG('>', 1450);
  function '>=' (LEFT DATE, RIGHT DATE) return BOOLEAN;
    pragma BUILTIN('>=',3, 12, 6);  -- PEMS_DATE, PEMDCMGE
    pragma FIPSFLAG('>=', 1450);

  function '+' (LEFT DATE, RIGHT NUMBER) return DATE;
    pragma BUILTIN('+',14, 12, 7); -- PEMS_DATE, DATE_ADD1
    pragma FIPSFLAG('+', 1450);
  function '+' (LEFT NUMBER, RIGHT DATE) return DATE;
    pragma BUILTIN('+',14, 12, 8); -- PEMS_DATE, DATE_ADD2
    pragma FIPSFLAG('+', 1450);
  function '-' (LEFT DATE, RIGHT NUMBER) return DATE;
    pragma BUILTIN('-',15, 12, 9); -- PEMS_DATE, DATE_SUB1
    pragma FIPSFLAG('-', 1450);
  function '-' (LEFT NUMBER, RIGHT DATE) return DATE;
    pragma BUILTIN('-',15, 12, 10); -- PEMS_DATE, DATE_SUB2
    pragma FIPSFLAG('-', 1450);
  function '-' (LEFT DATE, RIGHT DATE) return NUMBER;
    pragma BUILTIN('-',15, 12, 11); -- PEMS_DATE, DATE_SUB3
    pragma FIPSFLAG('-', 1450);

  function LAST_DAY(RIGHT DATE) return DATE;
    pragma BUILTIN('LAST_DAY',38, 12, 12); -- PEMS_DATE, DATE_LAST_DAY
    pragma FIPSFLAG('LAST_DAY', 1450);
  function ADD_MONTHS(LEFT DATE, RIGHT NUMBER) return DATE;
    pragma BUILTIN('ADD_MONTHS',39, 12, 13); -- PEMS_DATE, DATE_ADD_MONTHS1
    pragma FIPSFLAG('ADD_MONTHS', 1450);
  function ADD_MONTHS(LEFT NUMBER, RIGHT DATE) return DATE;
    pragma BUILTIN('ADD_MONTHS',39, 12, 14); -- PEMS_DATE, DATE_ADD_MONTHS2
    pragma FIPSFLAG('ADD_MONTHS', 1450);

  function MONTHS_BETWEEN(LEFT DATE, RIGHT DATE) return NUMBER;
    pragma BUILTIN('MONTHS_BETWEEN',42, 12, 15); -- PEMS_DATE, DATE_MONTHS_BET
    pragma FIPSFLAG('MONTHS_BETWEEN', 1450);
  function NEXT_DAY(LEFT DATE, RIGHT VARCHAR2) return DATE;
    pragma BUILTIN('NEXT_DAY',43, 12, 16); -- PEMS_DATE, DATE_NEXT_DAY
    pragma FIPSFLAG('NEXT_DAY', 1450);
  function ROUND(RIGHT DATE) return DATE;
    pragma BUILTIN('ROUND',24, 12, 17); -- PEMS_DATE, DATE_ROUND
    pragma FIPSFLAG('ROUND', 1450);
  function NEW_TIME(RIGHT DATE, MIDDLE VARCHAR2, LEFT VARCHAR2) return DATE;
    pragma FIPSFLAG('NEW_TIME', 1450);

  function 'IS NULL' (d DATE) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 12, 0);  -- PEMS_DATE, PEMDNUL
    pragma FIPSFLAG('IS NULL', 1450);
  function 'IS NOT NULL' (d DATE) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 12, 50);  -- PEMS_DATE, PEMDNUL
    pragma FIPSFLAG('IS NOT NULL', 1450);
  function NVL (d1 DATE, d2 DATE) return DATE;
    pragma FIPSFLAG('NVL', 1450);

  function TRUNC(LEFT DATE) return DATE;
    pragma BUILTIN('TRUNC',51, 12, 20); -- PEMS_DATE, DATE_TRUNC1
    pragma FIPSFLAG('TRUNC', 1450);
  function TRUNC(LEFT DATE, RIGHT VARCHAR2) return DATE;
    pragma BUILTIN('TRUNC',51, 12, 21); -- PEMS_DATE, DATE_TRUNC2
    pragma FIPSFLAG('TRUNC', 1450);
  function ROUND(LEFT DATE, RIGHT VARCHAR2) return DATE;
    pragma BUILTIN('ROUND',24, 12, 22); -- PEMS_DATE, DATE_ROUND2
    pragma FIPSFLAG('ROUND', 1450);

  function TO_DATE    (RIGHT VARCHAR2 character set any_cs)  return DATE;
    pragma BUILTIN('TO_DATE',40, 1, 10); -- PEMS_CHAR, CHR_CNV_DAT
    pragma FIPSFLAG('TO_DATE', 1450);

  function TO_DATE (LEFT VARCHAR2 character set any_cs, 
       RIGHT VARCHAR2 character set LEFT%charset) return DATE;
    pragma BUILTIN('TO_DATE',40, 1, 8); -- PEMS_CHAR, CHR_CNV_DATE
    pragma FIPSFLAG('TO_DATE', 1450);

  function TO_DATE (LEFT NUMBER, RIGHT VARCHAR2) return DATE;
    pragma FIPSFLAG('TO_DATE', 1450);

  function TO_DATE(left varchar2 character set any_cs, 
                   format varchar2 character set LEFT%charset, 
                   parms varchar2 character set LEFT%charset) return date;

  function TO_CHAR (RIGHT VARCHAR2) return VARCHAR2;
    pragma BUILTIN('TO_CHAR',14, 0, 2);

  function TO_CHAR (LEFT DATE, RIGHT VARCHAR2) return VARCHAR2;
    pragma BUILTIN('TO_CHAR',41, 12, 19); -- PEMS_DATE, DAT_CNV_CHR1
    pragma FIPSFLAG('TO_CHAR', 1450);

  function TO_CHAR (LEFT NUMBER, RIGHT VARCHAR2) return VARCHAR2;
    pragma BUILTIN('TO_CHAR',41, 2, 14); -- PEMS_NUMBER, NUM_CNV_CHR

  function TO_NUMBER (RIGHT NUMBER) RETURN NUMBER;
    pragma BUILTIN('TO_NUMBER',14, 0, 1); -- PEMS_QUICK

  function TO_NUMBER (RIGHT VARCHAR2 character set any_cs)    return NUMBER;
    pragma BUILTIN('TO_NUMBER',48, 1, 9); -- PEMS_CHAR, CHR_CNV_NUM

  function TO_NUMBER(left varchar2 character set any_cs, 
        format varchar2 character set LEFT%charset)    
    return number;
  function TO_NUMBER(left varchar2 character set any_cs, 
                     format varchar2 character set LEFT%charset, 
                     parms varchar2 character set LEFT%charset) 
    return number;

  -- Define SQL predicates.  These don't gen code, so no body is needed.

  -- PRIOR is WEIRD - For now, it will be treated as a function call.
  -- Does the function only take a column name?  how about its use in
  -- a predicate?
  function 'PRIOR'(colname VARCHAR2 CHARACTER SET ANY_CS)
          return VARCHAR2 CHARACTER SET colname%CHARSET;
      pragma FIPSFLAG('PRIOR', 1452);
  function 'PRIOR'(colname NUMBER) return NUMBER;
      pragma FIPSFLAG('PRIOR', 1452);
  function 'PRIOR'(colname DATE) return DATE;
      pragma FIPSFLAG('PRIOR', 1450);

  -- Outer Join has same problem as PRIOR
  function '(+)'(colname VARCHAR2 CHARACTER SET ANY_CS)
          return VARCHAR2 CHARACTER SET colname%CHARSET;
  function '(+)'(colname NUMBER) return NUMBER;
  function '(+)'(colname DATE) return DATE;
      pragma FIPSFLAG('(+)', 1450);

  function '=ANY'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                    RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '=ANY'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('=ANY', 1450);
  function '=ANY'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '!=ANY'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '!=ANY'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('!=ANY', 1450);
  function '!=ANY'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '<ANY'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                    RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '<ANY'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('<ANY', 1450);
  function '<ANY'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '<=ANY'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '<=ANY'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('<=ANY', 1450);
  function '<=ANY'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '>ANY'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                    RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '>ANY'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('>ANY', 1450);
  function '>ANY'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '>=ANY'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '>=ANY'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('>=ANY', 1450);
  function '>=ANY'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '=ALL'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                    RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '=ALL'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('=ALL', 1450);
  function '=ALL'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '!=ALL'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '!=ALL'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('!=ALL', 1450);
  function '!=ALL'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '<ALL'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                    RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '<ALL'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('<ALL', 1450);
  function '<ALL'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '<=ALL'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '<=ALL'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('<=ALL', 1450);
  function '<=ALL'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '>ALL'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                    RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '>ALL'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('>ALL', 1450);
  function '>ALL'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '>=ALL'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '>=ALL'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('>=ALL', 1450);
  function '>=ALL'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '=SOME'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '=SOME'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('=SOME', 1450);
  function '=SOME'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '!=SOME'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                      RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '!=SOME'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('!=SOME', 1450);
  function '!=SOME'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '<SOME'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '<SOME'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('<SOME', 1450);
  function '<SOME'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '<=SOME'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                      RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '<=SOME'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('<=SOME', 1450);
  function '<=SOME'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '>SOME'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '>SOME'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('>SOME', 1450);
  function '>SOME'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  function '>=SOME'  (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                      RIGHT VARCHAR2 CHARACTER SET LEFT%CHARSET)
          return BOOLEAN;
  function '>=SOME'  (LEFT DATE, RIGHT DATE) return BOOLEAN;
      pragma FIPSFLAG('>=SOME', 1450);
  function '>=SOME'  (LEFT NUMBER, RIGHT NUMBER) return BOOLEAN;
  
  -- SQL Transaction routines
  procedure SET_TRANSACTION_USE(vc VARCHAR2);
  procedure COMMIT;
  procedure COMMIT_CM(vc VARCHAR2);
  procedure ROLLBACK_NR;
  procedure ROLLBACK_SV(Save_Point CHAR);
  procedure SAVEPOINT(Save_Point CHAR);
  
  function SYSDATE return DATE;
    pragma FIPSFLAG('SYSDATE', 1452);

  function UID return PLS_INTEGER;
    pragma FIPSFLAG('UID', 1452);

  function USER return VARCHAR2;

  function USERENV (envstr VARCHAR2) return VARCHAR2;
    pragma FIPSFLAG('USERENV', 1452);

  -- ROWID: this dreadful identifier is supposed to represent a datatype
  -- outside of SQL and and a pseudo-column (function, to us) when inside
  -- a sql statement.  ADA data model doesn't allow for any
  -- function X return X;
  -- so we must special case this.  Yuk.  There's special-case code in ph2nre
  -- which maps "rowid" to "rowid " if we're inside a SQL stmt.
  function "ROWID " return ROWID;
    pragma builtin('ROWID ', 1, 209, 240);  -- this had better never be called.

  function NULLFN (str VARCHAR2) return RAW;
    pragma builtin('NULLFN', 1, 0, 1); 

  function HEXTORAW (c VARCHAR2) return RAW;
     pragma builtin('HEXTORAW', 1, 23, 1);

  function RAWTOHEX (r RAW) return VARCHAR2;
     pragma builtin('RAWTOHEX', 1, 23, 2);

  function CHARTOROWID (str VARCHAR2) return ROWID;
    pragma builtin('CHARTOROWID', 1, 0, 1);

  function ROWIDTOCHAR (str ROWID) return VARCHAR2;
    pragma builtin('ROWIDTOCHAR', 1, 0, 1);


  -- Trusted*Oracle additions
  Function ROWLABEL return MLSLABEL;                     -- pseudo column

  Function TO_CHAR(label MLSLABEL, format VARCHAR2) return VARCHAR2;
    pragma BUILTIN('TO_CHAR',90, 4, 19); -- PEMS_DATE, MLS_CNV_CHR1
    pragma FIPSFLAG('TO_CHAR', 1450);

  Function TO_LABEL(label VARCHAR2, format VARCHAR2 ) return  MLSLABEL;
    pragma BUILTIN('TO_LABEL',90, 4, 8); -- PEMS_CHAR, CHR_CNV_MLS
    pragma FIPSFLAG('TO_LABEL', 1450);

  Function TO_LABEL(label VARCHAR2 ) return  MLSLABEL;
    pragma BUILTIN('TO_LABEL',90, 4, 2); -- PEMS_CHAR, CHR_CNV_MLS
    pragma FIPSFLAG('TO_LABEL', 1450);

  -- vararg routines - icds in stdbdy 
  Function LEAST_UB    (pattern MLSLABEL) return MLSLABEL;
    pragma BUILTIN('LEAST_UB',90, 4, 3); -- PEMS_CHAR, CHR_CNV_MLS
  Function GREATEST_LB (pattern MLSLABEL) return MLSLABEL;
    pragma BUILTIN('GREATEST_LB',90, 4, 4); -- PEMS_CHAR, CHR_CNV_MLS

  Function '>=' (label1 MLSLABEL, label2 MLSLABEL) return BOOLEAN;
  Function '>'  (label1 MLSLABEL, label2 MLSLABEL) return BOOLEAN;
  Function '<=' (label1 MLSLABEL, label2 MLSLABEL) return BOOLEAN;
  Function '<'  (label1 MLSLABEL, label2 MLSLABEL) return BOOLEAN;
  Function '='  (label1 MLSLABEL, label2 MLSLABEL) return BOOLEAN;
  Function '!=' (label1 MLSLABEL, label2 MLSLABEL) return BOOLEAN;
  function 'IS NULL' (label MLSLABEL) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 1, 20); -- same "cod" as IS NULL(varchar2)
  function 'IS NOT NULL' (label MLSLABEL) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 1, 50);

  function NVL(label1 MLSLABEL, label2 MLSLABEL) return MLSLABEL;
    pragma FIPSFLAG('NVL', 1452);

  -- group functions 
  Function LUB (label MLSLABEL) return MLSLABEL;
  Function GLB (label MLSLABEL) return MLSLABEL;

  -- end of Trusted*Oracle additions 


  -- beginning of NLS routines 

  function NLSSORT(c VARCHAR2 CHARACTER SET ANY_CS) return RAW;
    pragma FIPSFLAG('NLSSORT', 1452);   
  function NLSSORT(c VARCHAR2 CHARACTER SET ANY_CS, c2 VARCHAR2) return RAW;
    pragma FIPSFLAG('NLSSORT', 1452);   
  function NLS_UPPER(ch VARCHAR2 CHARACTER SET ANY_CS, 
                     parms VARCHAR2 CHARACTER SET ch%CHARSET)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_UPPER', 1452); 
  function NLS_UPPER(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_UPPER', 1452); 
  function NLS_LOWER(ch VARCHAR2 CHARACTER SET ANY_CS, 
                     parms VARCHAR2 CHARACTER SET ch%CHARSET)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_LOWER', 1452); 
  function NLS_LOWER(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_LOWER', 1452); 
  function NLS_INITCAP(ch VARCHAR2 CHARACTER SET ANY_CS, 
                       parms VARCHAR2 CHARACTER SET ch%CHARSET)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_INITCAP', 1452);       
  function NLS_INITCAP(ch VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_INITCAP', 1452);       

  function LENGTHB(ch VARCHAR2 CHARACTER SET ANY_CS) return NUMBER;
    pragma FIPSFLAG('LENGTHB', 1452);   
  function SUBSTRB(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                   POS PLS_INTEGER, 
                   LEN PLS_INTEGER := 2147483647)
        return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('SUBSTRB', 1452);   
  function INSTRB(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                 STR2 VARCHAR2 CHARACTER SET STR1%CHARSET,
                 POS PLS_INTEGER := 1,
                 NTH POSITIVE := 1) return PLS_INTEGER;
    pragma FIPSFLAG('INSTRB', 1452);

  function TO_SINGLE_BYTE(c VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET c%CHARSET;
    pragma FIPSFLAG('TO_SINGLE_BYTE', 1452);    
  function TO_MULTI_BYTE(c VARCHAR2 CHARACTER SET ANY_CS)
        return VARCHAR2 CHARACTER SET c%CHARSET;
    pragma FIPSFLAG('TO_MULTI_BYTE', 1452);     

  -- Next two added for NLS 6/3/92 JEM.
  function TO_CHAR(left date, format varchar2, parms varchar2) return varchar2;
  function TO_CHAR(left number, format varchar2, parms varchar2) 
    return varchar2;
  function NLS_CHARSET_NAME(csetid PLS_INTEGER) return VARCHAR2;
  function NLS_CHARSET_ID(csetname VARCHAR2) return PLS_INTEGER;
  function NLS_CHARSET_DECL_LEN(bytecnt NUMBER, csetid NUMBER)
    return PLS_INTEGER;

  -- end of NLS routines 

  function CONVERT(src VARCHAR2 character set any_cs, 
                   destcset VARCHAR2) 
           return VARCHAR2 character set src%charset;
  function CONVERT(src VARCHAR2 character set any_cs, 
                   destcset VARCHAR2, 
                   srccset VARCHAR2) 
          return VARCHAR2 character set src%charset;
  
  function " SYS$STANDARD_TRANSLATE" (src VARCHAR2 CHARACTER SET ANY_CS,
                                      csn VARCHAR2 CHARACTER SET ANY_CS)
          return VARCHAR2 CHARACTER SET csn%CHARSET;
     pragma FIPSFLAG(' SYS$STANDARD_TRANSLATE',1452);
  
  function VSIZE (e number ) return NUMBER;
      pragma builtin('VSIZE', 1, 0, 1);
  function VSIZE (e DATE) return NUMBER;
      pragma builtin('VSIZE', 1, 0, 1);
  function VSIZE (e VARCHAR2 CHARACTER SET ANY_CS) return NUMBER;
      pragma builtin('VSIZE', 1, 0, 1);
  
  
  -- dump( expr [,display_format[,start_pos[,length]]]) return VARCHAR2
  function DUMP(e varchar2 character set any_cs,
                df pls_integer := null,sp pls_integer := null,
                len pls_integer := null) return VARCHAR2;
      pragma builtin('DUMP', 1, 0, 1);
  
  function DUMP(e number,df pls_integer := null,sp pls_integer := null,
                  len pls_integer := null) return VARCHAR2;
      pragma builtin('DUMP', 1, 0, 1);
  
  function DUMP(e date,df pls_integer := null,sp pls_integer := null,
                  len pls_integer := null) return VARCHAR2;
      pragma builtin('DUMP', 1, 0, 1);

  --
  -- ACOS, ASIN, ATAN, ATAN2 
  --   Inverse Trigonometric functions
  --   These functions return NULL if any of the inputs are NULL
  --
  function ACOS(N NUMBER) return NUMBER;
    pragma FIPSFLAG('ACOS', 1452);
    
  function ASIN(N NUMBER) return NUMBER;
    pragma FIPSFLAG('ASIN', 1452);
    
  function ATAN(N NUMBER) return NUMBER;
    pragma FIPSFLAG('ATAN', 1452);
    
  function ATAN2(x NUMBER, y NUMBER) return NUMBER;
  pragma FIPSFLAG('ATAN2', 1452);

  --#### This is the end of 7.3 Standard
  
  -- LOB IS NULL
  function 'IS NULL' (n CLOB CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 2, 0); -- PEMS_NUMBER, PEMDNUL
  function 'IS NOT NULL' (n CLOB CHARACTER SET ANY_CS) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 2, 50);

  function 'IS NULL' (n BLOB) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 2, 0); -- PEMS_NUMBER, PEMDNUL
  function 'IS NOT NULL' (n BLOB) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 2, 50);

  function 'IS NULL' (n BFILE) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 2, 0); -- PEMS_NUMBER, PEMDNUL
  function 'IS NOT NULL' (n BFILE) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 2, 50);
  -- end LOB IS NULL

  --****************************************************************
  -- 20 mar 96 =G=> In the following, arguments "1, 1, 1" to pragma BUILTIN
  -- e.g.,                pragma builtin('whatever', 1, 1, 1)
  -- indicate that those three numeric arguments to pragma BUILTIN are unknown,
  -- because they are not yet implemented by the backend.

  function '='  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('=', 1, 1, 1);
    pragma FIPSFLAG('=', 1450); 
  function '!=' (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN; 
    pragma BUILTIN('!=', 1, 1, 1);
    pragma FIPSFLAG('!=', 1450);        
  function '<'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('<', 1, 1, 1);
    pragma FIPSFLAG('<', 1450); 
  function '<=' (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('<=', 1, 1, 1);
    pragma FIPSFLAG('<=', 1450);        
  function '>'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('>', 1, 1, 1);
    pragma FIPSFLAG('>', 1450); 
  function '>=' (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('>=', 1, 1, 1);
    pragma FIPSFLAG('>=', 1450);        

  function '=ANY'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '!=ANY'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '<ANY'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '<=ANY'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '>ANY'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '>=ANY'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '=ALL'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '!=ALL'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '<ALL'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '<=ALL'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '>ALL'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '>=ALL'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '=SOME'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '!=SOME'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '<SOME'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '<=SOME'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '>SOME'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;
  function '>=SOME'  (LEFT "<ADT_1>", RIGHT "<ADT_1>") return BOOLEAN;

  -- Outer Join
  function '(+)'  ( colname "<ADT_1>") return "<ADT_1>";
    pragma FIPSFLAG('(+)', 1450);

  --  GREATEST and LEAST are not yet supported for ADTs in 8.0.2.
  --  function GREATEST (pattern "<ADT_1>") return "<ADT_1>";
  --    pragma BUILTIN('GREATEST', 1, 1, 1);

  --  function LEAST (pattern "<ADT_1>") return "<ADT_1>";
  --    pragma BUILTIN('LEAST', 1, 1, 1);

  function DECODE (expr "<ADT_1>", pat "<ADT_1>", res "<ADT_1>") 
        return "<ADT_1>";
    pragma BUILTIN('DECODE', 1, 1, 1);

  function 'IS NULL' (B "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 3, 0);
    pragma FIPSFLAG('IS NULL', 1450);   

  function 'IS NOT NULL' (B "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 3, 50);
    pragma FIPSFLAG('IS NOT NULL', 1450);       

  function NVL (B1 "<ADT_1>", B2 "<ADT_1>") return "<ADT_1>";
    pragma FIPSFLAG('NVL', 1450);       

  function VALUE (item "<ADT_WITH_OID>") return "<ADT_1>";
    pragma BUILTIN('VALUE', 1, 1, 1);
    pragma FIPSFLAG('VALUE', 1450);
    
  function REF (item "<ADT_WITH_OID>") return REF "<ADT_1>";
    pragma BUILTIN('REF', 1, 1, 1);
    pragma FIPSFLAG('REF', 1450); 

  function DEREF (r REF "<ADT_1>") return "<ADT_1>";
    pragma BUILTIN('DEREF', 1, 1, 1);
    pragma FIPSFLAG('DEREF', 1450);

  -- overloadings for REF ADT

  function 'IS NULL' (B REF "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 3, 0);
    pragma FIPSFLAG('IS NULL', 1450);   

  function 'IS NOT NULL' (B REF "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 3, 50);
    pragma FIPSFLAG('IS NOT NULL', 1450);       

  function 'IS DANGLING' (B REF "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('IS DANGLING', 1, 1, 1);
    pragma FIPSFLAG('IS DANGLING', 1450);

  function 'IS NOT DANGLING' (B REF "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('IS NOT DANGLING', 1, 1, 1);
    pragma FIPSFLAG('IS NOT DANGLING', 1450);

  function NVL (B1 REF "<ADT_1>", B2 REF "<ADT_1>") return REF "<ADT_1>";
    pragma FIPSFLAG('NVL', 1450);       

  function '='  (LEFT REF "<ADT_1>", RIGHT REF "<ADT_1>") return BOOLEAN;
    pragma BUILTIN('=', 0, 3, 1);
    pragma FIPSFLAG('=', 1450); 

  function '!=' (LEFT REF "<ADT_1>", RIGHT REF "<ADT_1>") return BOOLEAN; 
    pragma BUILTIN('!=', 0, 3, 2);
    pragma FIPSFLAG('!=', 1450);        

  --  function '='  (LEFT "<COLLECTION_1>", RIGHT "<COLLECTION_1>") 
  --      return BOOLEAN;
  --    pragma BUILTIN('=', 1, 1, 1);
  --    pragma FIPSFLAG('=', 1450);       
  --
  --  function '!=' (LEFT "<COLLECTION_1>", RIGHT "<COLLECTION_1>") 
  --      return BOOLEAN; 
  --    pragma BUILTIN('!=', 1, 1, 1);
  --    pragma FIPSFLAG('!=', 1450);      
  --
  --  function '=ANY'  (LEFT "<COLLECTION_1>", RIGHT "<COLLECTION_1>") 
  --      return BOOLEAN;
  --  function '!=ANY'  (LEFT "<COLLECTION_1>", RIGHT "<COLLECTION_1>") 
  --      return BOOLEAN;
  --  function '=ALL'  (LEFT "<COLLECTION_1>", RIGHT "<COLLECTION_1>") 
  --      return BOOLEAN;
  --  function '!=ALL'  (LEFT "<COLLECTION_1>", RIGHT "<COLLECTION_1>") 
  --      return BOOLEAN;
  --  function '=SOME'  (LEFT "<COLLECTION_1>", RIGHT "<COLLECTION_1>") 
  --      return BOOLEAN;
  --  function '!=SOME'  (LEFT "<COLLECTION_1>", RIGHT "<COLLECTION_1>") 
  --      return BOOLEAN;
  --
  --  function DECODE (expr "<COLLECTION_1>", pat "<COLLECTION_1>", 
  --                                        res "<COLLECTION_1>")
  --      return "<COLLECTION_1>";
  --    pragma BUILTIN('DECODE', 1, 1, 1);

  function 'IS NULL' (B "<COLLECTION_1>") return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 3, 0);
    pragma FIPSFLAG('IS NULL', 1450);   

  function 'IS NOT NULL' (B "<COLLECTION_1>") return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 3, 50);
    pragma FIPSFLAG('IS NOT NULL', 1450);       

  function NVL (B1 "<COLLECTION_1>", B2 "<COLLECTION_1>") 
        return "<COLLECTION_1>";
    pragma FIPSFLAG('NVL', 1450);       

  function 'IS NULL' (B "<REF_CURSOR_1>") return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 3, 0);
    pragma FIPSFLAG('IS NULL', 1450);   

  function 'IS NOT NULL' (B "<REF_CURSOR_1>") return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 3, 50);
    pragma FIPSFLAG('IS NOT NULL', 1450);       

  function NVL (B1 "<REF_CURSOR_1>", B2 "<REF_CURSOR_1>") 
        return "<REF_CURSOR_1>";
    pragma FIPSFLAG('NVL', 1450);       

  function EMPTY_CLOB return clob;
  function EMPTY_BLOB return blob;

  function BFILENAME(directory varchar2,filename varchar2) return BFILE;

  function "SYS$LOB_REPLICATION" (x in blob) return blob;
  function "SYS$LOB_REPLICATION" (x in clob character set any_cs) 
    return clob character set x%charset;

  --#### This is the end of 8.0 Standard
  
  --  + overloadings
    
  function '+'(LEFT TIMESTAMP_UNCONSTRAINED, RIGHT YMINTERVAL_UNCONSTRAINED) 
               return TIMESTAMP_UNCONSTRAINED;
  function '+'(LEFT TIMESTAMP_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED) 
               return TIMESTAMP_UNCONSTRAINED;

  function '+'(LEFT TIMESTAMP_TZ_UNCONSTRAINED, RIGHT YMINTERVAL_UNCONSTRAINED)
               return TIMESTAMP_TZ_UNCONSTRAINED ; 
  function '+'(LEFT TIMESTAMP_TZ_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED)
               return TIMESTAMP_TZ_UNCONSTRAINED ; 

  function '+'(LEFT TIME_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED) 
               return TIME_UNCONSTRAINED; 

  function '+'(LEFT TIME_TZ_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED) 
               return TIME_TZ_UNCONSTRAINED; 

  function '+'(LEFT date, RIGHT YMINTERVAL_UNCONSTRAINED) return date ; 
  function '+'(LEFT date, RIGHT DSINTERVAL_UNCONSTRAINED) return date ; 
  function '+'(LEFT YMINTERVAL_UNCONSTRAINED, RIGHT TIMESTAMP_UNCONSTRAINED) 
               return TIMESTAMP_UNCONSTRAINED; 
  function '+'(LEFT YMINTERVAL_UNCONSTRAINED, RIGHT TIMESTAMP_TZ_UNCONSTRAINED) 
               return TIMESTAMP_TZ_UNCONSTRAINED ; 
  function '+'(LEFT YMINTERVAL_UNCONSTRAINED, RIGHT date) return date ; 

  function '+'(LEFT DSINTERVAL_UNCONSTRAINED, RIGHT TIMESTAMP_UNCONSTRAINED)  
               return TIMESTAMP_UNCONSTRAINED; 
  function '+'(LEFT DSINTERVAL_UNCONSTRAINED, RIGHT TIMESTAMP_TZ_UNCONSTRAINED) 
                return TIMESTAMP_TZ_UNCONSTRAINED ; 
  function '+'(LEFT DSINTERVAL_UNCONSTRAINED, RIGHT TIME_UNCONSTRAINED) 
                return TIME_UNCONSTRAINED ;
  function '+'(LEFT DSINTERVAL_UNCONSTRAINED, RIGHT TIME_TZ_UNCONSTRAINED) 
                return TIME_TZ_UNCONSTRAINED ; 
  function '+'(LEFT DSINTERVAL_UNCONSTRAINED, RIGHT date) return date ; 

  function '+'(LEFT DSINTERVAL_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED) 
               return DSINTERVAL_UNCONSTRAINED ; 
  function '+'(LEFT YMINTERVAL_UNCONSTRAINED, RIGHT YMINTERVAL_UNCONSTRAINED) 
               return YMINTERVAL_UNCONSTRAINED ; 
  
  -- begin subtract 
  function " SYS$DSINTERVALSUBTRACT"(LEFT TIMESTAMP_UNCONSTRAINED, 
                                     RIGHT TIMESTAMP_UNCONSTRAINED) 
           return DSINTERVAL_UNCONSTRAINED ; 
  function " SYS$YMINTERVALSUBTRACT"(LEFT TIMESTAMP_UNCONSTRAINED, 
                                     RIGHT TIMESTAMP_UNCONSTRAINED) 
           return YMINTERVAL_UNCONSTRAINED ; 
  function '-'(LEFT TIMESTAMP_UNCONSTRAINED, RIGHT YMINTERVAL_UNCONSTRAINED) 
               return TIMESTAMP_UNCONSTRAINED; 
  function '-'(LEFT TIMESTAMP_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED) 
               return TIMESTAMP_UNCONSTRAINED; 

  function " SYS$DSINTERVALSUBTRACT"
   (LEFT TIMESTAMP_TZ_UNCONSTRAINED, RIGHT TIMESTAMP_TZ_UNCONSTRAINED) 
    return DSINTERVAL_UNCONSTRAINED ; 
  function " SYS$YMINTERVALSUBTRACT"
   (LEFT TIMESTAMP_TZ_UNCONSTRAINED, RIGHT TIMESTAMP_TZ_UNCONSTRAINED) 
    return YMINTERVAL_UNCONSTRAINED ; 
  function '-' (LEFT TIMESTAMP_TZ_UNCONSTRAINED, RIGHT YMINTERVAL_UNCONSTRAINED)
    return TIMESTAMP_TZ_UNCONSTRAINED ; 
  function '-' (LEFT TIMESTAMP_TZ_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED)
    return TIMESTAMP_TZ_UNCONSTRAINED ; 

  function " SYS$DSINTERVALSUBTRACT" (LEFT TIME_UNCONSTRAINED, 
                                      RIGHT TIME_UNCONSTRAINED) 
     return DSINTERVAL_UNCONSTRAINED ; 
  function '-' (LEFT TIME_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED) 
    return TIME_UNCONSTRAINED ; 
  function " SYS$DSINTERVALSUBTRACT" 
   (LEFT TIME_TZ_UNCONSTRAINED, RIGHT TIME_TZ_UNCONSTRAINED) 
    return DSINTERVAL_UNCONSTRAINED ; 
  function '-' (LEFT TIME_TZ_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED) 
    return TIME_TZ_UNCONSTRAINED ; 
  function  " SYS$DSINTERVALSUBTRACT" (LEFT date, RIGHT date)  
    return DSINTERVAL_UNCONSTRAINED ; 
  function " SYS$YMINTERVALSUBTRACT" (LEFT date, RIGHT date)  
    return YMINTERVAL_UNCONSTRAINED ; 
  function '-' (LEFT date, RIGHT YMINTERVAL_UNCONSTRAINED) return date; 
  function '-' (LEFT date, RIGHT DSINTERVAL_UNCONSTRAINED) return date; 

  function '-' (LEFT YMINTERVAL_UNCONSTRAINED, RIGHT YMINTERVAL_UNCONSTRAINED) 
    return YMINTERVAL_UNCONSTRAINED ; 
  function '-' (LEFT DSINTERVAL_UNCONSTRAINED, RIGHT DSINTERVAL_UNCONSTRAINED) 
   return DSINTERVAL_UNCONSTRAINED ; 

  -- end subtract 

  -- other datetime operators

  function '*' (LEFT number, RIGHT YMINTERVAL_UNCONSTRAINED) 
    return YMINTERVAL_UNCONSTRAINED ; 
  function '*' (LEFT number, RIGHT DSINTERVAL_UNCONSTRAINED) 
    return DSINTERVAL_UNCONSTRAINED ; 

  function '*' (LEFT YMINTERVAL_UNCONSTRAINED, RIGHT number) 
    return YMINTERVAL_UNCONSTRAINED ; 
  function '*' (LEFT DSINTERVAL_UNCONSTRAINED, RIGHT number) 
    return DSINTERVAL_UNCONSTRAINED ; 

  function '/' (LEFT YMINTERVAL_UNCONSTRAINED, RIGHT number) 
    return YMINTERVAL_UNCONSTRAINED ; 
  function '/' (LEFT DSINTERVAL_UNCONSTRAINED, RIGHT number) 
    return DSINTERVAL_UNCONSTRAINED ; 

  
  function current_date return date;
  function current_time return TIME_TZ_UNCONSTRAINED; 
  function current_timestamp return TIMESTAMP_TZ_UNCONSTRAINED;

  function TO_TIME (RIGHT varchar2 character set any_cs) return
    time_unconstrained;
    pragma BUILTIN('TO_TIME', 0, 15, 1);
    function TO_TIMESTAMP (RIGHT varchar2 character set any_cs)  
                           return TIMESTAMP_UNCONSTRAINED;
    pragma BUILTIN('TO_TIMESTAMP', 0, 15, 3);
  function TO_TIME_TZ (RIGHT varchar2 character set any_cs) 
    return  TIME_TZ_UNCONSTRAINED;
    pragma BUILTIN('TO_TIME_TZ', 0, 15, 5);
  function TO_TIMESTAMP_TZ (RIGHT varchar2 character set any_cs) 
    return  TIMESTAMP_TZ_UNCONSTRAINED;
    pragma BUILTIN('TO_TIMESTAMP_TZ', 0, 15, 7);
  function TO_YMINTERVAL (RIGHT varchar2 character set any_cs) 
    return  YMINTERVAL_UNCONSTRAINED;
    pragma BUILTIN('TO_YMINTERVAL', 0, 15, 9);
  function TO_DSINTERVAL (RIGHT varchar2 character set any_cs) 
    return  DSINTERVAL_UNCONSTRAINED;
    pragma BUILTIN('TO_DSINTERVAL', 0, 15, 11);

  -- with nls args 
  function TO_TIME(left varchar2 character set any_cs, 
                   format varchar2 character set left%charset, 
                   parms varchar2 character set left%charset) 
    return TIME_UNCONSTRAINED;
  function TO_TIME(left varchar2 character set any_cs, 
                   format varchar2 character set left%charset) 
    return TIME_UNCONSTRAINED;
  function TO_TIMESTAMP(left varchar2 character set any_cs, 
                        format varchar2 character set left%charset, 
                        parms varchar2 character set left%charset) 
    return TIMESTAMP_UNCONSTRAINED;
  function TO_TIMESTAMP(left varchar2 character set any_cs, 
                        format varchar2 character set left%charset) 
    return TIMESTAMP_UNCONSTRAINED;
  function TO_TIMESTAMP_TZ(left varchar2 character set any_cs, 
                           format varchar2 character set left%charset, 
                           parms varchar2 character set left%charset) 
    return TIMESTAMP_TZ_UNCONSTRAINED;
  function TO_TIMESTAMP_TZ(left varchar2 character set any_cs, 
                           format varchar2 character set left%charset)
    return TIMESTAMP_TZ_UNCONSTRAINED;
  function TO_TIME_TZ(left varchar2 character set any_cs, 
                      format varchar2 character set left%charset, 
                      parms varchar2 character set left%charset) 
    return TIME_TZ_UNCONSTRAINED;
  function TO_TIME_TZ(left varchar2 character set any_cs, 
                      format varchar2 character set left%charset)
    return TIME_TZ_UNCONSTRAINED;
  function TO_DSINTERVAL(RIGHT varchar2 character set any_cs, 
                         parms varchar2 character set RIGHT%charset) 
    return DSINTERVAL_UNCONSTRAINED;
  
  function NUMTOYMINTERVAL(numerator number,
                           units varchar2 character set any_cs) 
    return YMINTERVAL_UNCONSTRAINED;
  function NUMTODSINTERVAL(numerator number,
                           units varchar2 character set any_cs) 
    return DSINTERVAL_UNCONSTRAINED;
  
  function '='  (LEFT UROWID, RIGHT UROWID) return BOOLEAN;
    pragma BUILTIN('=',0, 11, 1);
    pragma FIPSFLAG('=', 1450);
  function '!=' (LEFT UROWID, RIGHT UROWID) return BOOLEAN;  -- also <> and ~=
    pragma BUILTIN('!=',0, 11, 2);
    pragma FIPSFLAG('!=', 1450);
  function '<'  (LEFT UROWID, RIGHT UROWID) return BOOLEAN;
    pragma BUILTIN('<',0, 11, 3);
    pragma FIPSFLAG('<', 1450);
  function '<=' (LEFT UROWID, RIGHT UROWID) return BOOLEAN;
    pragma BUILTIN('<=',0, 11, 4);
    pragma FIPSFLAG('<=', 1450);
  function '>'  (LEFT UROWID, RIGHT UROWID) return BOOLEAN;
    pragma BUILTIN('>',0, 11, 5);
    pragma FIPSFLAG('>', 1450);
  function '>=' (LEFT UROWID, RIGHT UROWID) return BOOLEAN;
    pragma BUILTIN('>=',0, 11, 6);
    pragma FIPSFLAG('>=', 1450);

  function 'IS NULL' (u UROWID) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 14, 0); -- PEMS_UROWID, PEMDNUL
    pragma FIPSFLAG('IS NULL', 1450);
  function 'IS NOT NULL' (u UROWID) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 14, 50); -- PEMS_UROWID, PEMDNUL
    pragma FIPSFLAG('IS NOT NULL', 1450);
  
  function "UROWID " return UROWID;
    pragma builtin('UROWID ', 1, 209, 240);  -- this had better never be called.

  -- New built-in function SYS_GUID, returns globally unique id
  function SYS_GUID return RAW;

  -- New built-in function SYS_CONTEXT
  function SYS_CONTEXT (namespace varchar2, attribute varchar2)
    return varchar2; 

  function TRIM(v VARCHAR2 CHARACTER SET ANY_CS)
    return VARCHAR2 CHARACTER SET v%CHARSET;

  --#### This is the end of 8.1.5 Standard

  -- SYS_CONTEXT now has an additional optional parameter
  function SYS_CONTEXT(namespace varchar2, attribute varchar2,
                       newoptional varchar2)
    return varchar2; 

  -- CUBE and ROLLUP are not real functions; they are variants on the GROUP
  -- BY clause (GROUP BY CUBE (...) and GROUP BY ROLLUP (...)). They have
  -- been added here as functions to avoid name capture issues.
  --
  -- Note that both CUBE and ROLLUP look like true vararg functions with
  -- *no* repeating pattern of formals - hence they are special cased in
  -- the overloading code.
  function CUBE return NUMBER;
  function ROLLUP return NUMBER;

  -- The GROUPING function must be used in conjunction with CUBE and ROLLUP
  -- in the GROUP BY clause. The type of the parameter to GROUPING can be
  -- any type that can appear in a GROUP BY list.
  function GROUPING(v VARCHAR2) return NUMBER;
  function GROUPING(a "<ADT_1>") return NUMBER;

  -- This is for TRIM(x). No trim set.
  function " SYS$STANDARD_TRIM" (v VARCHAR2 CHARACTER SET ANY_CS)
    return VARCHAR2 CHARACTER SET v%CHARSET;

  -- This is for TRIM(LEADING/TRAILING FROM x). No trim set.
  function " SYS$STANDARD_TRIM" (STR1 VARCHAR2 CHARACTER SET ANY_CS ,
                                 TRFLAG PLS_INTEGER)
    return VARCHAR2 CHARACTER SET STR1%CHARSET;

  -- General TRIM. LEADING, TRAILING and BOTH options as 3rd argument.
  -- This one takes a trim set.
  function " SYS$STANDARD_TRIM" (STR1   VARCHAR2 CHARACTER SET ANY_CS ,
                                 TSET   VARCHAR2 CHARACTER SET STR1%CHARSET,
                                 TRFLAG PLS_INTEGER)
    return VARCHAR2 CHARACTER SET STR1%CHARSET;

  --#### This is the end of the supported parts of 8.1.6 Standard

  --## Support for ANSI datetime data types is under development.
  --## The following operations, as well as the related types and
  --## operations defined above in the 8.1.5 section, are not yet
  --## available for use and are still subject to change.

  --- datetime equivalence 
  function '='  (LEFT TIME_UNCONSTRAINED, 
                 RIGHT TIME_UNCONSTRAINED) return BOOLEAN;
  function '!=' (LEFT TIME_UNCONSTRAINED,
                 RIGHT TIME_UNCONSTRAINED) return BOOLEAN; 
  function '<'  (LEFT TIME_UNCONSTRAINED, 
                 RIGHT TIME_UNCONSTRAINED) return BOOLEAN;
  function '<=' (LEFT TIME_UNCONSTRAINED, 
                 RIGHT TIME_UNCONSTRAINED) return BOOLEAN;
  function '>'  (LEFT TIME_UNCONSTRAINED, 
                 RIGHT TIME_UNCONSTRAINED) return BOOLEAN;
  function '>=' (LEFT TIME_UNCONSTRAINED, 
                 RIGHT TIME_UNCONSTRAINED) return BOOLEAN;

  function '='  (LEFT TIMESTAMP_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_UNCONSTRAINED) return BOOLEAN;
  function '!=' (LEFT TIMESTAMP_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_UNCONSTRAINED) return BOOLEAN; 
  function '<'  (LEFT TIMESTAMP_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_UNCONSTRAINED) return BOOLEAN;
  function '<=' (LEFT TIMESTAMP_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_UNCONSTRAINED) return BOOLEAN;
  function '>'  (LEFT TIMESTAMP_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_UNCONSTRAINED) return BOOLEAN;
  function '>=' (LEFT TIMESTAMP_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_UNCONSTRAINED) return BOOLEAN;

  function '='  (LEFT TIME_TZ_UNCONSTRAINED, 
                 RIGHT TIME_TZ_UNCONSTRAINED) return BOOLEAN;
  function '!=' (LEFT TIME_TZ_UNCONSTRAINED, 
                 RIGHT TIME_TZ_UNCONSTRAINED) return BOOLEAN; 
  function '<'  (LEFT TIME_TZ_UNCONSTRAINED, 
                 RIGHT TIME_TZ_UNCONSTRAINED) return BOOLEAN;
  function '<=' (LEFT TIME_TZ_UNCONSTRAINED, 
                 RIGHT TIME_TZ_UNCONSTRAINED) return BOOLEAN;
  function '>'  (LEFT TIME_TZ_UNCONSTRAINED, 
                 RIGHT TIME_TZ_UNCONSTRAINED) return BOOLEAN;
  function '>=' (LEFT TIME_TZ_UNCONSTRAINED, 
                 RIGHT TIME_TZ_UNCONSTRAINED) return BOOLEAN;
                 
  function '='  (LEFT YMINTERVAL_UNCONSTRAINED, 
                 RIGHT YMINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function '!=' (LEFT YMINTERVAL_UNCONSTRAINED, 
                 RIGHT YMINTERVAL_UNCONSTRAINED) return BOOLEAN; 
  function '<'  (LEFT YMINTERVAL_UNCONSTRAINED, 
                 RIGHT YMINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function '<=' (LEFT YMINTERVAL_UNCONSTRAINED, 
                 RIGHT YMINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function '>'  (LEFT YMINTERVAL_UNCONSTRAINED, 
                 RIGHT YMINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function '>=' (LEFT YMINTERVAL_UNCONSTRAINED, 
                 RIGHT YMINTERVAL_UNCONSTRAINED) return BOOLEAN;
                 
  function '='  (LEFT DSINTERVAL_UNCONSTRAINED, 
                 RIGHT DSINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function '!=' (LEFT DSINTERVAL_UNCONSTRAINED, 
                 RIGHT DSINTERVAL_UNCONSTRAINED) return BOOLEAN; 
  function '<'  (LEFT DSINTERVAL_UNCONSTRAINED, 
                 RIGHT DSINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function '<=' (LEFT DSINTERVAL_UNCONSTRAINED, 
                 RIGHT DSINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function '>'  (LEFT DSINTERVAL_UNCONSTRAINED, 
                 RIGHT DSINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function '>=' (LEFT DSINTERVAL_UNCONSTRAINED, 
                 RIGHT DSINTERVAL_UNCONSTRAINED) return BOOLEAN;
                 
  function TO_TIME (RIGHT TIME_TZ_UNCONSTRAINED)  return TIME_UNCONSTRAINED;
    pragma BUILTIN('TO_TIME', 0, 15, 13);
  function TO_TIME_TZ (RIGHT TIME_UNCONSTRAINED)  return TIME_TZ_UNCONSTRAINED;
    pragma BUILTIN('TO_TIME_TZ', 0, 15, 14);
  function TO_TIMESTAMP (RIGHT TIMESTAMP_TZ_UNCONSTRAINED)  
    return TIMESTAMP_UNCONSTRAINED;
    pragma BUILTIN('TO_TIMESTAMP', 0, 15, 15);
  function TO_TIMESTAMP_TZ (RIGHT TIMESTAMP_UNCONSTRAINED)  
    return TIMESTAMP_TZ_UNCONSTRAINED;
    pragma BUILTIN('TO_TIMESTAMP_TZ', 0, 15, 16);

  function '-'
      (LEFT TIME_UNCONSTRAINED, RIGHT TIME_UNCONSTRAINED) 
    return DSINTERVAL_UNCONSTRAINED; 
  function '-'
      (LEFT TIMESTAMP_UNCONSTRAINED, RIGHT TIMESTAMP_UNCONSTRAINED) 
    return DSINTERVAL_UNCONSTRAINED; 
  function '-'
      (LEFT TIME_TZ_UNCONSTRAINED, RIGHT TIME_TZ_UNCONSTRAINED) 
    return DSINTERVAL_UNCONSTRAINED; 
  function '-'
      (LEFT TIMESTAMP_TZ_UNCONSTRAINED, RIGHT TIMESTAMP_TZ_UNCONSTRAINED) 
    return DSINTERVAL_UNCONSTRAINED; 
   
  -- timezone functions
  function SYS_AT_TIME_ZONE(t time_tz_unconstrained,
                            i varchar2) RETURN time_tz_unconstrained;
  function SYS_AT_TIME_ZONE(t timestamp_tz_unconstrained,
                            i varchar2) RETURN timestamp_tz_unconstrained;
  FUNCTION systimestamp RETURN timestamp_tz_unconstrained;
  FUNCTION dbtimezone RETURN varchar2;
  FUNCTION sessiontimezone RETURN varchar2;
  FUNCTION localtimestamp RETURN timestamp_unconstrained;
  FUNCTION localtime RETURN time_unconstrained;

  function TO_TIMESTAMP (RIGHT DATE)  return TIMESTAMP_UNCONSTRAINED;
    pragma BUILTIN('TO_TIMESTAMP', 0, 15, 17);

  function '+'(LEFT TIMESTAMP_LTZ_UNCONSTRAINED,
               RIGHT yminterval_unconstrained)
    return TIMESTAMP_LTZ_UNCONSTRAINED; 
  function '+'(LEFT TIMESTAMP_LTZ_UNCONSTRAINED,
               RIGHT dsinterval_unconstrained)
    return TIMESTAMP_LTZ_UNCONSTRAINED; 
  function '+'(LEFT yminterval_unconstrained,
               RIGHT TIMESTAMP_LTZ_UNCONSTRAINED)
    return TIMESTAMP_LTZ_UNCONSTRAINED ; 
  function '+'(LEFT dsinterval_unconstrained,
               RIGHT TIMESTAMP_LTZ_UNCONSTRAINED)
    return TIMESTAMP_LTZ_UNCONSTRAINED ; 

  function '-'(LEFT TIMESTAMP_LTZ_UNCONSTRAINED,
               RIGHT yminterval_unconstrained) 
    return TIMESTAMP_LTZ_UNCONSTRAINED ; 
  function '-'(LEFT TIMESTAMP_LTZ_UNCONSTRAINED,
               RIGHT dsinterval_unconstrained) 
    return TIMESTAMP_LTZ_UNCONSTRAINED ; 

  function " SYS$DSINTERVALSUBTRACT"(LEFT TIMESTAMP_LTZ_UNCONSTRAINED,
                                     RIGHT TIMESTAMP_LTZ_UNCONSTRAINED) 
    return dsinterval_unconstrained; 
  function " SYS$YMINTERVALSUBTRACT"(LEFT TIMESTAMP_LTZ_UNCONSTRAINED,
                                     RIGHT TIMESTAMP_LTZ_UNCONSTRAINED) 
    return yminterval_unconstrained; 

  function '-'(LEFT TIMESTAMP_LTZ_UNCONSTRAINED,
               RIGHT TIMESTAMP_LTZ_UNCONSTRAINED) 
    return dsinterval_unconstrained; 

  function '='  (LEFT TIMESTAMP_TZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_TZ_UNCONSTRAINED) return BOOLEAN;
  function '!=' (LEFT TIMESTAMP_TZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_TZ_UNCONSTRAINED) return BOOLEAN; 
  function '<'  (LEFT TIMESTAMP_TZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_TZ_UNCONSTRAINED) return BOOLEAN;
  function '<=' (LEFT TIMESTAMP_TZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_TZ_UNCONSTRAINED) return BOOLEAN;
  function '>'  (LEFT TIMESTAMP_TZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_TZ_UNCONSTRAINED) return BOOLEAN;
  function '>=' (LEFT TIMESTAMP_TZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_TZ_UNCONSTRAINED) return BOOLEAN;
                 
  function '='  (LEFT TIMESTAMP_LTZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_LTZ_UNCONSTRAINED) return BOOLEAN;
  function '!=' (LEFT TIMESTAMP_LTZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_LTZ_UNCONSTRAINED) return BOOLEAN; 
  function '<'  (LEFT TIMESTAMP_LTZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_LTZ_UNCONSTRAINED) return BOOLEAN;
  function '<=' (LEFT TIMESTAMP_LTZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_LTZ_UNCONSTRAINED) return BOOLEAN;
  function '>'  (LEFT TIMESTAMP_LTZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_LTZ_UNCONSTRAINED) return BOOLEAN;
  function '>=' (LEFT TIMESTAMP_LTZ_UNCONSTRAINED, 
                 RIGHT TIMESTAMP_LTZ_UNCONSTRAINED) return BOOLEAN;
   
  function SYS_LITERALTOYMINTERVAL(numerator varchar2, units varchar2) 
    return YMINTERVAL_UNCONSTRAINED;
  function SYS_LITERALTODSINTERVAL(numerator varchar2, units varchar2) 
    return DSINTERVAL_UNCONSTRAINED;
  function SYS_LITERALTOTIME(numerator varchar2) 
    return TIME_UNCONSTRAINED;    
  function SYS_LITERALTOTZTIME(numerator varchar2) 
    return TIME_TZ_UNCONSTRAINED;    
  function SYS_LITERALTOTIMESTAMP(numerator varchar2) 
    return TIMESTAMP_UNCONSTRAINED;    
  function SYS_LITERALTOTZTIMESTAMP(numerator varchar2) 
    return TIMESTAMP_TZ_UNCONSTRAINED;    
  function SYS_LITERALTODATE(numerator varchar2) return DATE;    

                          
  -- Explicit conversions between date and datetime
  function TO_TIMESTAMP(ARG TIMESTAMP_LTZ_UNCONSTRAINED) 
    return TIMESTAMP_UNCONSTRAINED;
    pragma BUILTIN('TO_TIMESTAMP', 0, 15, 24);

  function TO_TIMESTAMP_TZ(ARG DATE) return TIMESTAMP_TZ_UNCONSTRAINED;
    pragma BUILTIN('TO_TIMESTAMP_TZ', 0, 15, 27);

  function TO_TIMESTAMP_TZ(ARG TIMESTAMP_LTZ_UNCONSTRAINED)
    return TIMESTAMP_TZ_UNCONSTRAINED;
    pragma BUILTIN('TO_TIMESTAMP_TZ', 0, 15, 26);

  -- IS [NOT] NULL / NVL for datetime 
  function 'IS NULL' (b TIME_UNCONSTRAINED) return BOOLEAN;
  function 'IS NOT NULL' (b TIME_UNCONSTRAINED) return BOOLEAN;
  function NVL (b1 TIME_UNCONSTRAINED, 
                b2 TIME_UNCONSTRAINED) return TIME_UNCONSTRAINED;

  function 'IS NULL' (b TIME_TZ_UNCONSTRAINED) return BOOLEAN;
  function 'IS NOT NULL' (b TIME_TZ_UNCONSTRAINED) return BOOLEAN;
  function NVL (b1 TIME_TZ_UNCONSTRAINED, b2 TIME_TZ_UNCONSTRAINED) 
    return TIME_TZ_UNCONSTRAINED;

  function 'IS NULL' (b TIMESTAMP_UNCONSTRAINED) return BOOLEAN;
  function 'IS NOT NULL' (b TIMESTAMP_UNCONSTRAINED) return BOOLEAN;
  function NVL (b1 TIMESTAMP_UNCONSTRAINED, 
                b2 TIMESTAMP_UNCONSTRAINED) return TIMESTAMP_UNCONSTRAINED;

  function 'IS NULL' (b TIMESTAMP_TZ_UNCONSTRAINED) return BOOLEAN;
  function 'IS NOT NULL' (b TIMESTAMP_TZ_UNCONSTRAINED) return BOOLEAN;
  function NVL (b1 TIMESTAMP_TZ_UNCONSTRAINED, b2 TIMESTAMP_TZ_UNCONSTRAINED) 
    return TIMESTAMP_TZ_UNCONSTRAINED;
 
  function 'IS NULL' (b TIMESTAMP_LTZ_UNCONSTRAINED) return BOOLEAN;
  function 'IS NOT NULL' (b TIMESTAMP_LTZ_UNCONSTRAINED) return BOOLEAN;
  function NVL (b1 TIMESTAMP_LTZ_UNCONSTRAINED, 
                b2 TIMESTAMP_LTZ_UNCONSTRAINED) 
    return TIMESTAMP_LTZ_UNCONSTRAINED;
 
  function 'IS NULL' (b YMINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function 'IS NOT NULL' (b YMINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function NVL (b1 YMINTERVAL_UNCONSTRAINED, b2 YMINTERVAL_UNCONSTRAINED) 
    return YMINTERVAL_UNCONSTRAINED;

  function 'IS NULL' (b DSINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function 'IS NOT NULL' (b DSINTERVAL_UNCONSTRAINED) return BOOLEAN;
  function NVL (b1 DSINTERVAL_UNCONSTRAINED, b2 DSINTERVAL_UNCONSTRAINED) 
    return DSINTERVAL_UNCONSTRAINED;
                   
  function " SYS$EXTRACT_FROM"
              (T TIME_UNCONSTRAINED,FIELD VARCHAR2) return NUMBER;
  function " SYS$EXTRACT_FROM"
              (T TIME_TZ_UNCONSTRAINED,FIELD varchar2) return NUMBER;
  function " SYS$EXTRACT_FROM"
              (T TIMESTAMP_UNCONSTRAINED,FIELD VARCHAR2) return NUMBER;
  function " SYS$EXTRACT_FROM"
              (T TIMESTAMP_TZ_UNCONSTRAINED,FIELD VARCHAR2) return NUMBER;
  function " SYS$EXTRACT_FROM"
              (T TIMESTAMP_LTZ_UNCONSTRAINED,FIELD varchar2) return NUMBER;
  function " SYS$EXTRACT_FROM"
              (T DATE,FIELD VARCHAR2) return NUMBER;
  function " SYS$EXTRACT_FROM"
              (I YMINTERVAL_UNCONSTRAINED,FIELD VARCHAR2) return NUMBER;
  function " SYS$EXTRACT_FROM"
              (I DSINTERVAL_UNCONSTRAINED,FIELD VARCHAR2) return NUMBER;

  -- ##########      8.2 LOB Built-in Functions       ######## --

  -- LENGTH -- 	
  function LENGTH(ch CLOB CHARACTER SET ANY_CS) return integer;
    pragma FIPSFLAG('LENGTH', 1452);    

  function LENGTHB(ch CLOB CHARACTER SET ANY_CS) return integer;
    pragma FIPSFLAG('LENGTHB', 1452);    

  function LENGTH(bl BLOB) return integer;
    pragma FIPSFLAG('LENGTH', 1452);    

  function LENGTHB(bl BLOB) return integer;
    pragma FIPSFLAG('LENGTHB', 1452);    

  -- SUBSTR --
  function SUBSTR(STR1 CLOB CHARACTER SET ANY_CS,
                  POS INTEGER,
                  LEN INTEGER := 18446744073709551615)
    return CLOB CHARACTER SET STR1%CHARSET;	
    pragma FIPSFLAG('SUBSTR', 1452);    		

  function SUBSTRB(STR1 CLOB CHARACTER SET ANY_CS,
                  POS INTEGER,
                  LEN INTEGER := 18446744073709551615)
    return CLOB CHARACTER SET STR1%CHARSET;	
    pragma FIPSFLAG('SUBSTRB', 1452);    		
	
  -- INSTR --
  function INSTR(STR1 CLOB CHARACTER SET ANY_CS,
                 STR2 CLOB CHARACTER SET STR1%CHARSET,
                 POS INTEGER := 1,
                 NTH INTEGER := 1) return INTEGER;
    pragma FIPSFLAG('INSTR', 1452);     	

  function INSTRB(STR1 CLOB CHARACTER SET ANY_CS,
                  STR2 CLOB CHARACTER SET STR1%CHARSET,
                  POS INTEGER := 1,
                  NTH INTEGER := 1) return INTEGER;
    pragma FIPSFLAG('INSTRB', 1452);     	

  -- CONCAT --
  function '||' (LEFT CLOB CHARACTER SET ANY_CS,
                 RIGHT CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET LEFT%CHARSET;
    pragma FIPSFLAG('||', 1454);        
	
  function CONCAT(LEFT CLOB CHARACTER SET ANY_CS,
                  RIGHT CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET LEFT%CHARSET;
    pragma FIPSFLAG(CONCAT, 1454);      

  -- UPPER --
  function UPPER(ch CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('UPPER', 1452);     

  -- LOWER -- 
  function LOWER(ch CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('LOWER', 1452);     

  -- LPAD --
  function LPAD(STR1 CLOB CHARACTER SET ANY_CS,
                LEN integer,
                PAD CLOB CHARACTER SET STR1%CHARSET)
    return CLOB CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('LPAD', 1452);      

  function LPAD(STR1 CLOB CHARACTER SET ANY_CS,
                LEN integer)
    return CLOB CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('LPAD', 1452);

  -- RPAD --
  function RPAD(STR1 CLOB CHARACTER SET ANY_CS,
                LEN integer,
                PAD CLOB CHARACTER SET STR1%CHARSET)
    return CLOB CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('RPAD', 1452);       

  function RPAD(STR1 CLOB CHARACTER SET ANY_CS,
                LEN integer)
    return CLOB CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('RPAD', 1452);       

  -- LTRIM --
  function LTRIM(STR1 CLOB CHARACTER SET ANY_CS,
                 TSET CLOB CHARACTER SET STR1%CHARSET)
    return CLOB CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('LTRIM', 1452);

  function LTRIM(STR1 CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('LTRIM', 1452);

  -- RTRIM --
  function RTRIM(STR1 CLOB CHARACTER SET ANY_CS,
                 TSET CLOB CHARACTER SET STR1%CHARSET)
    return CLOB CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('RTRIM', 1452);

  function RTRIM(STR1 CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('RTRIM', 1452);

  -- TRIM -- 
  function TRIM(v CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET v%CHARSET;

  -- This is for TRIM(x). No trim set.
  function " SYS$STANDARD_TRIM" (v CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET v%CHARSET;

  -- This is for TRIM(LEADING/TRAILING FROM x). No trim set.
  function " SYS$STANDARD_TRIM" (STR1 CLOB CHARACTER SET ANY_CS ,
                               TRFLAG PLS_INTEGER)
    return CLOB CHARACTER SET STR1%CHARSET;

  -- General TRIM. LEADING, TRAILING and BOTH options as 3rd argument.
  -- This one takes a trim set.
  function " SYS$STANDARD_TRIM" (STR1   CLOB CHARACTER SET ANY_CS ,
                                 TSET   CLOB CHARACTER SET STR1%CHARSET,
                                 TRFLAG PLS_INTEGER)
    return CLOB CHARACTER SET STR1%CHARSET;


  -- LIKE --	
  function 'LIKE' (str CLOB CHARACTER SET ANY_CS,
                   pat CLOB CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'NOT_LIKE' (str CLOB CHARACTER SET ANY_CS,
                       pat CLOB CHARACTER SET str%CHARSET)
    return BOOLEAN;

  function 'LIKE' (str CLOB CHARACTER SET ANY_CS,
                   pat CLOB CHARACTER SET str%CHARSET,
                   esc VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'NOT_LIKE' (str CLOB CHARACTER SET ANY_CS,
                       pat CLOB CHARACTER SET str%CHARSET,
                       esc VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;

  -- NVL -- 
  function NVL(s1 CLOB CHARACTER SET ANY_CS,
               s2 CLOB CHARACTER SET s1%CHARSET)
    return CLOB CHARACTER SET s1%CHARSET;
    pragma FIPSFLAG('NVL', 1452);

  -- REPLACE --
  function REPLACE(SRCSTR CLOB CHARACTER SET ANY_CS,
                   OLDSUB CLOB CHARACTER SET SRCSTR%CHARSET,
                   NEWSUB CLOB CHARACTER SET SRCSTR%CHARSET := NULL)
    return CLOB CHARACTER SET SRCSTR%CHARSET;
    pragma FIPSFLAG('REPLACE', 1452);

  -- LOB RELATIONAL OPERATORS --

  Function '='  (LEFT  CLOB CHARACTER SET ANY_CS, 
	         RIGHT CLOB CHARACTER SET ANY_CS) return BOOLEAN;
  Function '!=' (LEFT  CLOB CHARACTER SET ANY_CS, 
	         RIGHT CLOB CHARACTER SET ANY_CS) return BOOLEAN;
  Function '>'  (LEFT  CLOB CHARACTER SET ANY_CS, 
                 RIGHT CLOB CHARACTER SET ANY_CS) return BOOLEAN;
  Function '<'  (LEFT  CLOB CHARACTER SET ANY_CS, 
	         RIGHT CLOB CHARACTER SET ANY_CS) return BOOLEAN;
  Function '>=' (LEFT  CLOB CHARACTER SET ANY_CS, 
                 RIGHT CLOB CHARACTER SET ANY_CS) return BOOLEAN;
  Function '<=' (LEFT  CLOB CHARACTER SET ANY_CS, 
                 RIGHT CLOB CHARACTER SET ANY_CS) return BOOLEAN;

  Function '='  (LEFT  CLOB     CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
  Function '!=' (LEFT  CLOB     CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
  Function '>'  (LEFT  CLOB     CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
  Function '<'  (LEFT  CLOB     CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
  Function '>=' (LEFT  CLOB     CHARACTER SET ANY_CS, 
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;
  Function '<=' (LEFT  CLOB     CHARACTER SET ANY_CS,
                 RIGHT VARCHAR2 CHARACTER SET ANY_CS) return BOOLEAN;

  Function '='  (LEFT  VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT CLOB     CHARACTER SET ANY_CS) return BOOLEAN;
  Function '!=' (LEFT  VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT CLOB     CHARACTER SET ANY_CS) return BOOLEAN;
  Function '>'  (LEFT  VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT CLOB     CHARACTER SET ANY_CS) return BOOLEAN;
  Function '<'  (LEFT  VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT CLOB     CHARACTER SET ANY_CS) return BOOLEAN;
  Function '>=' (LEFT  VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT CLOB     CHARACTER SET ANY_CS) return BOOLEAN;
  Function '<=' (LEFT  VARCHAR2 CHARACTER SET ANY_CS,
                 RIGHT CLOB     CHARACTER SET ANY_CS) return BOOLEAN;

  /* LOB-related conversion functions */
  function TO_CLOB(RIGHT VARCHAR2 CHARACTER SET ANY_CS) return CLOB;
    pragma BUILTIN('TO_CLOB', 0, 15, 29); -- OPC_CVT_CHR2CLB
  function TO_BLOB(RIGHT RAW) return BLOB;
    pragma BUILTIN('TO_BLOB', 0, 15, 30); -- OPC_CVT_RAW2BLB
  function TO_RAW(RIGHT BLOB) return RAW;
    pragma BUILTIN('TO_RAW', 0, 15, 32); -- OPC_CVT_BLB2RAW
  
  -- ####### end of 8.2 LOB Built-in Functions  ######## --

  function NULLIF(v1 VARCHAR2, v2 VARCHAR2) return VARCHAR2;
  function NULLIF(v1 BOOLEAN, v2 BOOLEAN) return VARCHAR2;
  function NULLIF(a1 "<ADT_1>", a2 "<ADT_1>") return VARCHAR2;

  function COALESCE return VARCHAR2;

  /* Daylight Saving Time Functions */
  FUNCTION tz_offset(region VARCHAR2)  RETURN VARCHAR2; 
  FUNCTION from_tz(t TIMESTAMP_UNCONSTRAINED,timezone VARCHAR2)  
    RETURN timestamp_tz_unconstrained; 

  function " SYS$EXTRACT_STRING_FROM"
              (T TIME_TZ_UNCONSTRAINED,FIELD varchar2) return VARCHAR2;
  function " SYS$EXTRACT_STRING_FROM"
              (T TIMESTAMP_TZ_UNCONSTRAINED,FIELD VARCHAR2) return VARCHAR2;
  function " SYS$EXTRACT_STRING_FROM"
              (T TIMESTAMP_LTZ_UNCONSTRAINED,FIELD varchar2) return VARCHAR2;

  function INSTR2(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                  STR2 VARCHAR2 CHARACTER SET STR1%CHARSET,
                  POS PLS_INTEGER := 1,
                  NTH POSITIVE := 1) return PLS_INTEGER;
    pragma FIPSFLAG('INSTR2', 1452);

  function INSTR4(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                  STR2 VARCHAR2 CHARACTER SET STR1%CHARSET,
                  POS PLS_INTEGER := 1,
                  NTH POSITIVE := 1) return PLS_INTEGER;
    pragma FIPSFLAG('INSTR4', 1452);

  function INSTRC(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                  STR2 VARCHAR2 CHARACTER SET STR1%CHARSET,
                  POS PLS_INTEGER := 1,
                  NTH POSITIVE := 1) return PLS_INTEGER;
    pragma FIPSFLAG('INSTRC', 1452);

  function LENGTH2(ch VARCHAR2 CHARACTER SET ANY_CS) return natural;
    pragma FIPSFLAG('LENGTH2', 1452);

  function LENGTH4(ch VARCHAR2 CHARACTER SET ANY_CS) return natural;
    pragma FIPSFLAG('LENGTH4', 1452);

  function LENGTHC(ch VARCHAR2 CHARACTER SET ANY_CS) return natural;
    pragma FIPSFLAG('LENGTHC', 1452);

  function 'LIKE2' (str VARCHAR2 CHARACTER SET ANY_CS,
                    pat VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'NOT_LIKE2' (str VARCHAR2 CHARACTER SET ANY_CS,
                        pat VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'LIKE2' (str VARCHAR2 CHARACTER SET ANY_CS,
                    pat VARCHAR2 CHARACTER SET str%CHARSET,
                    esc VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'NOT_LIKE2' (str VARCHAR2 CHARACTER SET ANY_CS,
                        pat VARCHAR2 CHARACTER SET str%CHARSET,
                        esc VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;

  function 'LIKE4' (str VARCHAR2 CHARACTER SET ANY_CS,
                    pat VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'NOT_LIKE4' (str VARCHAR2 CHARACTER SET ANY_CS,
                        pat VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'LIKE4' (str VARCHAR2 CHARACTER SET ANY_CS,
                    pat VARCHAR2 CHARACTER SET str%CHARSET,
                    esc VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'NOT_LIKE4' (str VARCHAR2 CHARACTER SET ANY_CS,
                        pat VARCHAR2 CHARACTER SET str%CHARSET,
                        esc VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;

  function 'LIKEC' (str VARCHAR2 CHARACTER SET ANY_CS,
                    pat VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'NOT_LIKEC' (str VARCHAR2 CHARACTER SET ANY_CS,
                        pat VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'LIKEC' (str VARCHAR2 CHARACTER SET ANY_CS,
                    pat VARCHAR2 CHARACTER SET str%CHARSET,
                    esc VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;
  function 'NOT_LIKEC' (str VARCHAR2 CHARACTER SET ANY_CS,
                        pat VARCHAR2 CHARACTER SET str%CHARSET,
                        esc VARCHAR2 CHARACTER SET str%CHARSET)
    return BOOLEAN;

  function SUBSTR2(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                   POS PLS_INTEGER,
                   LEN PLS_INTEGER := 2147483647)
    return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('SUBSTR2', 1452);

  function SUBSTR4(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                   POS PLS_INTEGER,
                   LEN PLS_INTEGER := 2147483647)
    return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('SUBSTR4', 1452);

  function SUBSTRC(STR1 VARCHAR2 CHARACTER SET ANY_CS,
                   POS PLS_INTEGER,
                   LEN PLS_INTEGER := 2147483647)
    return VARCHAR2 CHARACTER SET STR1%CHARSET;
    pragma FIPSFLAG('SUBSTRC', 1452);

  /**** char <--> nchar conversion functions in Unicode project ********/
  
  function TO_NCHAR(RIGHT NVARCHAR2) return NVARCHAR2;
    pragma BUILTIN('TO_NCHAR',14, 0, 2);

  function TO_NCLOB(cl CLOB CHARACTER SET ANY_CS) return NCLOB;
  function TO_CLOB(cl CLOB CHARACTER SET ANY_CS) return CLOB;

  function TO_NCLOB(RIGHT VARCHAR2 CHARACTER SET ANY_CS)
    return NCLOB;
    pragma BUILTIN('TO_NCLOB', 0, 15, 29); -- OPC_CVT_CHR2CLB
  /* convert to either CLOB or NCLOB respectively if parm is char or nchar */
  function TO_ANYLOB(RIGHT VARCHAR2 CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET RIGHT%CHARSET;
    pragma BUILTIN('TO_ANYLOB', 0, 15, 29); -- OPC_CVT_CHR2CLB

  /* Followings are the same builtin op codes as without N prefix functions, 
   * implementation relys on impilcit conversion MCODEs 
   */
  function TO_NCHAR (LEFT DATE, FORMAT NVARCHAR2) return NVARCHAR2;
    pragma BUILTIN('TO_NCHAR',41, 12, 19); -- PEMS_DATE, DAT_CNV_CHR1
    pragma FIPSFLAG('TO_NCHAR', 1450);
  function TO_NCHAR (LEFT NUMBER, FORMAT NVARCHAR2) return NVARCHAR2;
    pragma BUILTIN('TO_NCHAR',41, 2, 14); -- PEMS_NUMBER, NUM_CNV_CHR

  function NHEXTORAW (c NVARCHAR2) return RAW;
    pragma builtin('NHEXTORAW', 1, 23, 1);
  function RAWTONHEX (r RAW) return NVARCHAR2;
    pragma builtin('RAWTONHEX', 1, 23, 2);
  function NCHARTOROWID (str NVARCHAR2) return ROWID;
    pragma builtin('NCHARTOROWID', 1, 0, 1);
  function ROWIDTONCHAR (str ROWID) return NVARCHAR2;
    pragma builtin('ROWIDTONCHAR', 1, 0, 1);

  function NCHR(n pls_integer) return NVARCHAR2;

  /* implemented by icd calls as the same as TO_CHAR */
  function TO_NCHAR(left date, format nvarchar2, parms nvarchar2)
    return nvarchar2;
  function TO_NCHAR(left number, format nvarchar2, parms nvarchar2)
    return nvarchar2;

  /* implemented as a icd call, return TRUE if nchar, otherwise FALSE */
  function ISNCHAR(c VARCHAR2 character set any_cs) return boolean;

  /************ end of char <--> nchar conversion functions ************/

  /* Create overloads for all standard functions that work with <ADT_1> for
     <OPAQUE_1> */
  function '='  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
    pragma BUILTIN('=', 1, 1, 1);
    pragma FIPSFLAG('=', 1450); 
  function '!=' (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN; 
    pragma BUILTIN('!=', 1, 1, 1);
    pragma FIPSFLAG('!=', 1450);        
  function '<'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
    pragma BUILTIN('<', 1, 1, 1);
    pragma FIPSFLAG('<', 1450); 
  function '<=' (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
    pragma BUILTIN('<=', 1, 1, 1);
    pragma FIPSFLAG('<=', 1450);        
  function '>'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
    pragma BUILTIN('>', 1, 1, 1);
    pragma FIPSFLAG('>', 1450); 
  function '>=' (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
    pragma BUILTIN('>=', 1, 1, 1);
    pragma FIPSFLAG('>=', 1450);        

  function '=ANY'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '!=ANY'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '<ANY'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '<=ANY'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '>ANY'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '>=ANY'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '=ALL'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '!=ALL'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '<ALL'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '<=ALL'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '>ALL'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '>=ALL'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '=SOME'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '!=SOME'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '<SOME'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '<=SOME'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '>SOME'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;
  function '>=SOME'  (LEFT "<OPAQUE_1>", RIGHT "<OPAQUE_1>") return BOOLEAN;

  -- Outer Join
  function '(+)'  ( colname "<OPAQUE_1>") return "<OPAQUE_1>";
    pragma FIPSFLAG('(+)', 1450);

  --  GREATEST and LEAST are not yet supported for ADTs in 8.0.2.
  --  function GREATEST (pattern "<OPAQUE_1>") return "<OPAQUE_1>";
  --    pragma BUILTIN('GREATEST', 1, 1, 1);

  --  function LEAST (pattern "<OPAQUE_1>") return "<OPAQUE_1>";
  --    pragma BUILTIN('LEAST', 1, 1, 1);

  function DECODE (expr "<OPAQUE_1>", pat "<OPAQUE_1>", res "<OPAQUE_1>") 
    return "<OPAQUE_1>";
    pragma BUILTIN('DECODE', 1, 1, 1);

  function 'IS NULL' (B "<OPAQUE_1>") return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 3, 0);
    pragma FIPSFLAG('IS NULL', 1450);   

  function 'IS NOT NULL' (B "<OPAQUE_1>") return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 3, 50);
    pragma FIPSFLAG('IS NOT NULL', 1450);       

  function NVL (B1 "<OPAQUE_1>", B2 "<OPAQUE_1>") return "<OPAQUE_1>";
    pragma FIPSFLAG('NVL', 1450);       

  --  REFs to opaques are not supported yet.
  --  function VALUE (item "<ADT_WITH_OID>") return "<OPAQUE_1>";
  --    pragma BUILTIN('VALUE', 1, 1, 1);
  --    pragma FIPSFLAG('VALUE', 1450);
    
  --  function REF (item "<ADT_WITH_OID>") return REF "<OPAQUE_1>";
  --    pragma BUILTIN('REF', 1, 1, 1);
  --    pragma FIPSFLAG('REF', 1450); 

  --  function DEREF (r REF "<OPAQUE_1>") return "<OPAQUE_1>";
  --    pragma BUILTIN('DEREF', 1, 1, 1);
  --    pragma FIPSFLAG('DEREF', 1450);

  -- overloadings for REF OPAQUE
  
  --  function 'IS NULL' (B REF "<OPAQUE_1>") return BOOLEAN;
  --    pragma BUILTIN('IS NULL', 0, 3, 0);
  --    pragma FIPSFLAG('IS NULL', 1450);   
  
  --  function 'IS NOT NULL' (B REF "<OPAQUE_1>") return BOOLEAN;
  --    pragma FIPSFLAG('IS NOT NULL', 1450);       
  
  --  function 'IS DANGLING' (B REF "<OPAQUE_1>") return BOOLEAN;
  --    pragma BUILTIN('IS DANGLING', 1, 1, 1);
  --    pragma FIPSFLAG('IS DANGLING', 1450);
  
  --  function 'IS NOT DANGLING' (B REF "<OPAQUE_1>") return BOOLEAN;
  --    pragma BUILTIN('IS NOT DANGLING', 1, 1, 1);
  --    pragma FIPSFLAG('IS NOT DANGLING', 1450);
  
  --  function NVL (B1 REF "<OPAQUE_1>", B2 REF "<OPAQUE_1>")
  --    return REF "<OPAQUE_1>";
  --    pragma FIPSFLAG('NVL', 1450);       
  
  --  function '='  (LEFT REF "<OPAQUE_1>", RIGHT REF "<OPAQUE_1>")
  --    return BOOLEAN;
  --    pragma BUILTIN('=', 0, 3, 1);
  --    pragma FIPSFLAG('=', 1450); 
  
  --  function '!=' (LEFT REF "<OPAQUE_1>", RIGHT REF "<OPAQUE_1>")
  --    return BOOLEAN; 
  --    pragma BUILTIN('!=', 0, 3, 2);
  --    pragma FIPSFLAG('!=', 1450);        

  function GROUPING(a "<OPAQUE_1>") return NUMBER;
  function NULLIF(a1 "<OPAQUE_1>", a2 "<OPAQUE_1>") return VARCHAR2;

  function GREATEST (pattern TIME_UNCONSTRAINED) return TIME_UNCONSTRAINED;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj
  function GREATEST (pattern TIME_TZ_UNCONSTRAINED)
    return TIME_TZ_UNCONSTRAINED;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj
  function GREATEST (pattern TIMESTAMP_UNCONSTRAINED) 
    return TIMESTAMP_UNCONSTRAINED;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj
  function GREATEST (pattern TIMESTAMP_TZ_UNCONSTRAINED)
    return TIMESTAMP_TZ_UNCONSTRAINED;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj
  function GREATEST (pattern TIMESTAMP_LTZ_UNCONSTRAINED)
    return TIMESTAMP_LTZ_UNCONSTRAINED;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj
  function GREATEST (pattern YMINTERVAL_UNCONSTRAINED)
    return YMINTERVAL_UNCONSTRAINED;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj
  function GREATEST (pattern DSINTERVAL_UNCONSTRAINED)
    return DSINTERVAL_UNCONSTRAINED;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2 -- Pj

  function LEAST (pattern TIME_UNCONSTRAINED) return TIME_UNCONSTRAINED;
    pragma BUILTIN('LEAST',12,240,240);-- This is special cased in PH2 -- Pj
  function LEAST (pattern TIME_TZ_UNCONSTRAINED) return TIME_TZ_UNCONSTRAINED;
    pragma BUILTIN('LEAST',12,240,240);-- This is special cased in PH2 -- Pj
  function LEAST (pattern TIMESTAMP_UNCONSTRAINED)
    return TIMESTAMP_UNCONSTRAINED;
    pragma BUILTIN('LEAST',12,240,240);-- This is special cased in PH2 -- Pj
  function LEAST (pattern TIMESTAMP_TZ_UNCONSTRAINED)
    return TIMESTAMP_TZ_UNCONSTRAINED;
    pragma BUILTIN('LEAST',12,240,240);-- This is special cased in PH2 -- Pj
  function LEAST (pattern TIMESTAMP_LTZ_UNCONSTRAINED)
    return TIMESTAMP_LTZ_UNCONSTRAINED;
    pragma BUILTIN('LEAST',12,240,240);-- This is special cased in PH2 -- Pj
  function LEAST (pattern YMINTERVAL_UNCONSTRAINED)
    return YMINTERVAL_UNCONSTRAINED;
    pragma BUILTIN('LEAST',12,240,240);-- This is special cased in PH2 -- Pj
  function LEAST (pattern DSINTERVAL_UNCONSTRAINED)
    return DSINTERVAL_UNCONSTRAINED;
    pragma BUILTIN('LEAST',12,240,240);-- This is special cased in PH2 -- Pj

  function TO_CHAR(left TIME_UNCONSTRAINED, format VARCHAR2, 
                   parms VARCHAR2) return VARCHAR2;
  function TO_CHAR(left TIME_UNCONSTRAINED, format VARCHAR2) return VARCHAR2;
  function TO_CHAR(left TIME_TZ_UNCONSTRAINED, format VARCHAR2, 
                   parms VARCHAR2) return VARCHAR2;
  function TO_CHAR(left TIME_TZ_UNCONSTRAINED, format VARCHAR2)
    return VARCHAR2;
  function TO_CHAR(left TIMESTAMP_UNCONSTRAINED, format VARCHAR2, 
                   parms VARCHAR2) return VARCHAR2;
  function TO_CHAR(left TIMESTAMP_UNCONSTRAINED, format VARCHAR2)
    return VARCHAR2;
  function TO_CHAR(left TIMESTAMP_TZ_UNCONSTRAINED, format VARCHAR2, 
                   parms VARCHAR2) return VARCHAR2;
  function TO_CHAR(left TIMESTAMP_TZ_UNCONSTRAINED, format VARCHAR2)
    return VARCHAR2;
  function TO_CHAR(left TIMESTAMP_LTZ_UNCONSTRAINED, format VARCHAR2, 
                   parms VARCHAR2) return VARCHAR2;
  function TO_CHAR(left TIMESTAMP_LTZ_UNCONSTRAINED, format VARCHAR2)
    return VARCHAR2;
  function TO_CHAR(left YMINTERVAL_UNCONSTRAINED, format VARCHAR2, 
                   parms VARCHAR2) return VARCHAR2;
  function TO_CHAR(left YMINTERVAL_UNCONSTRAINED, format VARCHAR2)
    return VARCHAR2;
  function TO_CHAR(left DSINTERVAL_UNCONSTRAINED, format VARCHAR2, 
                   parms VARCHAR2) return VARCHAR2;
  function TO_CHAR(left DSINTERVAL_UNCONSTRAINED, format VARCHAR2)
    return VARCHAR2;

  -- CONVERT FOR LOB --
  function CONVERT(SRCSTR CLOB CHARACTER SET ANY_CS,
                   DSTCSN VARCHAR2)
    return CLOB CHARACTER SET SRCSTR%CHARSET;
  function CONVERT(SRCSTR CLOB CHARACTER SET ANY_CS,
                   DSTCSN VARCHAR2,
                   SRCCSN VARCHAR2)
    return CLOB CHARACTER SET SRCSTR%CHARSET;
    
  -- NLS_UPPER/NLS_LOWER FOR LOB --
  function NLS_UPPER(ch CLOB CHARACTER SET ANY_CS, 
                     parms VARCHAR2 CHARACTER SET ch%CHARSET)
    return CLOB CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_UPPER', 1452); 
  function NLS_UPPER(ch CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_UPPER', 1452); 
  function NLS_LOWER(ch CLOB CHARACTER SET ANY_CS, 
                     parms VARCHAR2 CHARACTER SET ch%CHARSET)
    return CLOB CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_LOWER', 1452); 
  function NLS_LOWER(ch CLOB CHARACTER SET ANY_CS)
    return CLOB CHARACTER SET ch%CHARSET;
    pragma FIPSFLAG('NLS_LOWER', 1452); 

  function COMPOSE(ch VARCHAR2 CHARACTER SET ANY_CS)
    return varchar2 character set ch%charset;
    pragma FIPSFLAG('COMPOSE', 1452);
  function DECOMPOSE(ch VARCHAR2 CHARACTER SET ANY_CS,
                     canmode in VARCHAR2 DEFAULT 'CANONICAL')
    return varchar2 character set ch%charset;
    pragma FIPSFLAG('DECOMPOSE', 1452);
  FUNCTION SYS_EXTRACT_UTC(t timestamp_tz_unconstrained) 
    return TIMESTAMP_UNCONSTRAINED;

  -- Begin REGEXP Support (10iR1) --

  -- REGEXP_LIKE --
  function REGEXP_LIKE (srcstr   VARCHAR2 CHARACTER SET ANY_CS,
                        pattern  VARCHAR2 CHARACTER SET srcstr%CHARSET,
                        modifier VARCHAR2 DEFAULT NULL)
    return BOOLEAN;
    pragma FIPSFLAG('REGEXP_LIKE', 1452);

  function REGEXP_LIKE (srcstr   CLOB CHARACTER SET ANY_CS,
                        pattern  VARCHAR2 CHARACTER SET srcstr%CHARSET,
                        modifier VARCHAR2 DEFAULT NULL)
    return BOOLEAN;
    pragma FIPSFLAG('REGEXP_LIKE', 1452);

  -- REGEXP_INSTR --
  function REGEXP_INSTR(srcstr      VARCHAR2 CHARACTER SET ANY_CS,
                        pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
                        position    PLS_INTEGER := 1,
                        occurrence  PLS_INTEGER := 1,
                        returnparam PLS_INTEGER := 0,
                        modifier    VARCHAR2 DEFAULT NULL,
                        subexpression PLS_INTEGER := 0)
    return PLS_INTEGER;
    pragma FIPSFLAG('REGEXP_INSTR', 1452);

  function REGEXP_INSTR(srcstr      CLOB CHARACTER SET ANY_CS,
                        pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
                        position    INTEGER := 1,
                        occurrence  INTEGER := 1,
                        returnparam PLS_INTEGER := 0,
                        modifier    VARCHAR2 DEFAULT NULL,
                        subexpression PLS_INTEGER := 0)
    return INTEGER;
    pragma FIPSFLAG('REGEXP_INSTR', 1452);


  -- REGEXP_SUBSTR --
  function REGEXP_SUBSTR(srcstr      VARCHAR2 CHARACTER SET ANY_CS,
                         pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
                         position    PLS_INTEGER := 1,
                         occurrence  PLS_INTEGER := 1,
                         modifier    VARCHAR2 DEFAULT NULL,
                         subexpression PLS_INTEGER := 0)
    return VARCHAR2 CHARACTER SET srcstr%CHARSET;
    pragma FIPSFLAG('REGEXP_SUBSTR', 1452);

  function REGEXP_SUBSTR(srcstr      CLOB CHARACTER SET ANY_CS,
                         pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
                         position    INTEGER := 1,
                         occurrence  INTEGER := 1,
                         modifier    VARCHAR2 DEFAULT NULL,
                         subexpression PLS_INTEGER := 0)
    return CLOB CHARACTER SET srcstr%CHARSET;
    pragma FIPSFLAG('REGEXP_SUBSTR', 1452);

  -- REGEXP_REPLACE --
  function REGEXP_REPLACE(srcstr      VARCHAR2 CHARACTER SET ANY_CS,
                          pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
                          replacestr  VARCHAR2 CHARACTER SET srcstr%CHARSET
                                        DEFAULT NULL,
                          position    PLS_INTEGER := 1,
                          occurrence  PLS_INTEGER := 0,
                          modifier    VARCHAR2 DEFAULT NULL)
    return VARCHAR2 CHARACTER SET srcstr%CHARSET;
    pragma FIPSFLAG('REGEXP_REPLACE', 1452);

  function REGEXP_REPLACE(srcstr      CLOB CHARACTER SET ANY_CS,
                          pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
                          replacestr  CLOB CHARACTER SET srcstr%CHARSET
                                        DEFAULT NULL,
                          position    INTEGER := 1,
                          occurrence  INTEGER := 0,
                          modifier    VARCHAR2 DEFAULT NULL)
    return CLOB CHARACTER SET srcstr%CHARSET;
    pragma FIPSFLAG('REGEXP_REPLACE', 1452);

  function REGEXP_REPLACE(srcstr      CLOB CHARACTER SET ANY_CS,
                          pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
                          replacestr  VARCHAR2 CHARACTER SET srcstr%CHARSET
                                        DEFAULT NULL,
                          position    INTEGER := 1,
                          occurrence  INTEGER := 0,
                          modifier    VARCHAR2 DEFAULT NULL)
    return CLOB CHARACTER SET srcstr%CHARSET;
    pragma FIPSFLAG('REGEXP_REPLACE', 1452);

  -- End REGEXP Support --

  -- binary_float and binary_double functions and operators.
  function TO_BINARY_FLOAT (RIGHT BINARY_FLOAT) RETURN BINARY_FLOAT;
    pragma BUILTIN('TO_BINARY_FLOAT',14, 0, 1); -- PEMS_QUICK
  function TO_BINARY_FLOAT (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     FORMAT VARCHAR2 CHARACTER SET LEFT%CHARSET)
    RETURN BINARY_FLOAT;
  function TO_BINARY_FLOAT (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     FORMAT VARCHAR2 CHARACTER SET LEFT%CHARSET,
                     PARMS VARCHAR2 CHARACTER SET LEFT%CHARSET)
    RETURN BINARY_FLOAT;

  function TO_BINARY_DOUBLE (RIGHT BINARY_DOUBLE) RETURN BINARY_DOUBLE;
    pragma BUILTIN('TO_BINARY_DOUBLE',14, 0, 1); -- PEMS_QUICK
  function TO_BINARY_DOUBLE (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     FORMAT VARCHAR2 CHARACTER SET LEFT%CHARSET)
    RETURN BINARY_DOUBLE;
  function TO_BINARY_DOUBLE (LEFT VARCHAR2 CHARACTER SET ANY_CS,
                     FORMAT VARCHAR2 CHARACTER SET LEFT%CHARSET,
                     PARMS VARCHAR2 CHARACTER SET LEFT%CHARSET)
    RETURN BINARY_DOUBLE;

  function 'IS NAN' (N NUMBER) RETURN BOOLEAN;
  function 'IS NAN' (F BINARY_FLOAT) RETURN BOOLEAN;
  function 'IS NAN' (D BINARY_DOUBLE) RETURN BOOLEAN;
  function 'IS INFINITE' (N NUMBER) RETURN BOOLEAN;
  function 'IS INFINITE' (F BINARY_FLOAT) RETURN BOOLEAN;
  function 'IS INFINITE' (D BINARY_DOUBLE) RETURN BOOLEAN;
  function 'IS NOT NAN' (N NUMBER) RETURN BOOLEAN;
  function 'IS NOT NAN' (F BINARY_FLOAT) RETURN BOOLEAN;
  function 'IS NOT NAN' (D BINARY_DOUBLE) RETURN BOOLEAN;
  function 'IS NOT INFINITE' (N NUMBER) RETURN BOOLEAN;
  function 'IS NOT INFINITE' (F BINARY_FLOAT) RETURN BOOLEAN;
  function 'IS NOT INFINITE' (D BINARY_DOUBLE) RETURN BOOLEAN;

  function TO_CHAR (left binary_float, format varchar2)
    return VARCHAR2;
  function TO_CHAR (left binary_double, format varchar2)
    return VARCHAR2;

  function TO_CHAR(left binary_float, format varchar2, parms varchar2) 
    return varchar2;
  function TO_CHAR(left binary_double, format varchar2, parms varchar2) 
    return varchar2;

  function TO_NCHAR(left binary_float, format nvarchar2) return NVARCHAR2;
  function TO_NCHAR(left binary_double, format nvarchar2) return NVARCHAR2;

  function TO_NCHAR(left binary_float, format nvarchar2, parms nvarchar2) 
    return nvarchar2;
  function TO_NCHAR(left binary_double, format nvarchar2, parms nvarchar2) 
    return nvarchar2;

  function 'REMAINDER'(n1 NUMBER, n2 NUMBER) return NUMBER;
    pragma FIPSFLAG('REMAINDER', 1452);
  function REMAINDER(n1 NUMBER, n2 NUMBER) return NUMBER;
    pragma FIPSFLAG(REMAINDER, 1452);
  function 'REMAINDER'(f1 BINARY_FLOAT, f2 BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('REMAINDER', 1452);
  function REMAINDER(f1 BINARY_FLOAT, f2 BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG(REMAINDER, 1452);
  function 'REMAINDER'(d1 BINARY_DOUBLE, d2 BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('REMAINDER', 1452);
  function REMAINDER(d1 BINARY_DOUBLE, d2 BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG(REMAINDER, 1452);

  function '='  (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BOOLEAN;
    pragma BUILTIN('=',2, 2, 15);
  function '!=' (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BOOLEAN;
    pragma BUILTIN('!=',5, 2, 16);
    pragma FIPSFLAG('!=', 1452);
  function '<'  (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BOOLEAN;
    pragma BUILTIN('<',4, 2, 17);
  function '<=' (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BOOLEAN;
    pragma BUILTIN('<=',6, 2, 18);
  function '>'  (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BOOLEAN;
    pragma BUILTIN('>',1, 2, 19);
  function '>=' (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BOOLEAN;
    pragma BUILTIN('>=',3, 2, 20);

  function 'IS NULL' (n BINARY_FLOAT) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 2, 0);
  function 'IS NOT NULL' (n BINARY_FLOAT) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 2, 50);

  function NVL(f1 BINARY_FLOAT, f2 BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('NVL', 1452);

  function '+' (RIGHT BINARY_FLOAT) return BINARY_FLOAT;
    pragma BUILTIN('+',14, 0, 1);
  function '-' (RIGHT BINARY_FLOAT) return BINARY_FLOAT;
    pragma BUILTIN('-',15, 2, 23);
  function ABS(F BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('ABS', 1452);

  function '+' (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BINARY_FLOAT;
    pragma BUILTIN('+',14, 2, 24);
  function '-' (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BINARY_FLOAT;
    pragma BUILTIN('-',15, 2, 25);
  function '*' (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BINARY_FLOAT;
    pragma BUILTIN('*',17, 2, 26);
  function '/' (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BINARY_FLOAT;
    pragma BUILTIN('/',18, 2, 27);

  function 'REM' (LEFT BINARY_FLOAT, RIGHT BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('REM', 1452);
  function 'MOD'(F1 BINARY_FLOAT, F2 BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('MOD', 1452);

  function FLOOR(F BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('FLOOR', 1452);
  function CEIL(F BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('CEIL', 1452);
  function SIGN(f BINARY_FLOAT) return SIGNTYPE;
    pragma FIPSFLAG('SIGN', 1452);
  function SQRT(f BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('SQRT', 1452);

  function TRUNC (F BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('TRUNC', 1452);

  function ROUND (LEFT BINARY_FLOAT) return BINARY_FLOAT;
    pragma FIPSFLAG('ROUND', 1452);

  function '='  (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BOOLEAN;
    pragma BUILTIN('=',2, 2, 28);
  function '!=' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BOOLEAN;
    -- also <> and ~=
    pragma BUILTIN('!=',5, 2, 29);
    pragma FIPSFLAG('!=', 1452);
  function '<'  (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BOOLEAN;
    pragma BUILTIN('<',4, 2, 30);
  function '<=' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BOOLEAN;
    pragma BUILTIN('<=',6, 2, 31);
  function '>'  (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BOOLEAN;
    pragma BUILTIN('>',1, 2, 32);
  function '>=' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BOOLEAN;
    pragma BUILTIN('>=',3, 2, 33);

  function 'IS NULL' (n BINARY_DOUBLE) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 2, 0);
  function 'IS NOT NULL' (n BINARY_DOUBLE) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 2, 50);

  function NVL(d1 BINARY_DOUBLE, d2 BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('NVL', 1452);

  function '+' (RIGHT BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma BUILTIN('+',14, 0, 1);
  function '-' (RIGHT BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma BUILTIN('-',15, 2, 36);
  function ABS(D BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('ABS', 1452);

  function ACOS(D BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('ACOS', 1452);
    
  function ASIN(D BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('ASIN', 1452);
    
  function ATAN(D BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('ATAN', 1452);
    
  function ATAN2(x BINARY_DOUBLE, y BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('ATAN2', 1452);

  function '+' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma BUILTIN('+',14, 2, 37);
  function '-' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma BUILTIN('-',15, 2, 38);
  function '*' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma BUILTIN('*',17, 2, 39);
  function '/' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma BUILTIN('/',18, 2, 40);

  function 'REM' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE)
    return BINARY_DOUBLE;
    pragma FIPSFLAG('REM', 1452);
  function 'MOD'(D1 BINARY_DOUBLE, D2 BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('MOD', 1452);

  function '**' (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE)
    return BINARY_DOUBLE;
    pragma FIPSFLAG('**', 1452);

  function FLOOR(D BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('FLOOR', 1452);
  function CEIL(D BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('CEIL', 1452);
  function SQRT(d BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('SQRT', 1452);
  function SIGN(d BINARY_DOUBLE) return SIGNTYPE;
  pragma FIPSFLAG('SIGN', 1452);

  function COS(D BINARY_DOUBLE) return BINARY_DOUBLE;
  function SIN(D BINARY_DOUBLE) return BINARY_DOUBLE;
  function TAN(D BINARY_DOUBLE) return BINARY_DOUBLE;
  function COSH(D BINARY_DOUBLE) return BINARY_DOUBLE;
  function SINH(D BINARY_DOUBLE) return BINARY_DOUBLE;
  function TANH(D BINARY_DOUBLE) return BINARY_DOUBLE;
  function EXP(D BINARY_DOUBLE) return BINARY_DOUBLE;
  function LN(D BINARY_DOUBLE) return BINARY_DOUBLE;

  function LOG (LEFT BINARY_DOUBLE, RIGHT BINARY_DOUBLE) return BINARY_DOUBLE;

  function TRUNC (D BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('TRUNC', 1452);

  function ROUND (LEFT BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('ROUND', 1452);

  function POWER (d BINARY_DOUBLE, e BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma FIPSFLAG('POWER', 1452);

  function NANVL(n1 NUMBER, n2 NUMBER) return NUMBER;
  function NANVL(f1 BINARY_FLOAT, f2 BINARY_FLOAT) return BINARY_FLOAT;
  function NANVL(d1 BINARY_DOUBLE, d2 BINARY_DOUBLE) return BINARY_DOUBLE;

  function GREATEST (pattern BINARY_FLOAT) return BINARY_FLOAT;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2
  function GREATEST (pattern BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2
  function LEAST (pattern BINARY_FLOAT) return BINARY_FLOAT;
    pragma BUILTIN('LEAST',13,240,240);-- This is special cased in PH2
  function LEAST (pattern BINARY_DOUBLE) return BINARY_DOUBLE;
    pragma BUILTIN('LEAST',13,240,240);-- This is special cased in PH2


  function '+' (RIGHT PLS_INTEGER) return PLS_INTEGER;
    pragma BUILTIN('+',14, 0, 1); -- PEMS_QUICK
  function '-' (RIGHT PLS_INTEGER) return PLS_INTEGER;
    pragma BUILTIN('-',15, 2, 41);
  function ABS(I PLS_INTEGER) return PLS_INTEGER;
    pragma FIPSFLAG('ABS', 1452);

  function '+' (LEFT PLS_INTEGER, RIGHT PLS_INTEGER) return PLS_INTEGER;
    pragma BUILTIN('+',14, 2, 42);
  function '-' (LEFT PLS_INTEGER, RIGHT PLS_INTEGER) return PLS_INTEGER;
    pragma BUILTIN('-',14, 2, 43);
  function '*' (LEFT PLS_INTEGER, RIGHT PLS_INTEGER) return PLS_INTEGER;
    pragma BUILTIN('*',14, 2, 44);

  function '='  (LEFT PLS_INTEGER, RIGHT PLS_INTEGER) return BOOLEAN;
    pragma BUILTIN('=',2, 2, 45); -- PEMS_PLS_INTEGER, PEMDCMEQ
  function '!=' (LEFT PLS_INTEGER, RIGHT PLS_INTEGER) return BOOLEAN;
    -- also <> and ~=
    pragma BUILTIN('!=',5, 2, 46); -- PEMS_PLS_INTEGER, PEMDCMNE
    pragma FIPSFLAG('!=', 1452);
  function '<'  (LEFT PLS_INTEGER, RIGHT PLS_INTEGER) return BOOLEAN;
    pragma BUILTIN('<',4, 2, 47); -- PEMS_PLS_INTEGER, PEMDCMLT
  function '<=' (LEFT PLS_INTEGER, RIGHT PLS_INTEGER) return BOOLEAN;
    pragma BUILTIN('<=',6, 2, 48); -- PEMS_PLS_INTEGER, PEMDCMLE
  function '>'  (LEFT PLS_INTEGER, RIGHT PLS_INTEGER) return BOOLEAN;
    pragma BUILTIN('>',1, 2, 49); -- PEMS_PLS_INTEGER, PEMDCMGT
  function '>=' (LEFT PLS_INTEGER, RIGHT PLS_INTEGER) return BOOLEAN;
    pragma BUILTIN('>=',3, 2, 51); -- PEMS_PLS_INTEGER, PEMDCMGE

  function 'IS NULL' (I PLS_INTEGER) return BOOLEAN;
    pragma BUILTIN('IS NULL', 0, 2, 0); -- PEMS_PLS_INTEGER, PEMDNUL
  function 'IS NOT NULL' (I PLS_INTEGER) return BOOLEAN;
    pragma BUILTIN('IS NOT NULL', 0, 2, 50); -- PEMS_PLS_INTEGER, PEMDNUL

  function NVL(I1 PLS_INTEGER, I2 PLS_INTEGER) return PLS_INTEGER;
    pragma FIPSFLAG('NVL', 1452);

  function TRUNC (i pls_integer, places pls_integer := 0) return pls_integer;
    pragma FIPSFLAG('TRUNC', 1452);

  function ROUND (i pls_integer, places pls_integer := 0) return pls_integer;
    pragma FIPSFLAG('ROUND', 1452);

  function SIGN(i PLS_INTEGER) return SIGNTYPE;
    pragma FIPSFLAG('SIGN', 1452);

  function GREATEST (pattern PLS_INTEGER) return PLS_INTEGER;
    pragma BUILTIN('GREATEST',12,240,240);-- This is special cased in PH2
  function LEAST (pattern PLS_INTEGER) return PLS_INTEGER;
    pragma BUILTIN('LEAST',13,240,240);-- This is special cased in PH2

  -- MultiSet Functions and Operators.
  
  -- Equality
  function '='(collection1 IN "<TABLE_1>",collection2 IN "<TABLE_1>") 
    return BOOLEAN; 
      pragma BUILTIN('=',2, 16, 1);

  function '!='(collection1 IN "<TABLE_1>",collection2 IN "<TABLE_1>") 
    return BOOLEAN; 
      pragma BUILTIN('!=',2, 16, 2);

  function CARDINALITY (collection IN "<TABLE_1>") return PLS_INTEGER; 

  function SET (collection IN "<TABLE_1>") return "<TABLE_1>"; 
    pragma BUILTIN('SET',18, 2, 40);-- Dummy

  function 'IS A SET' (collection IN  "<TABLE_1>") return BOOLEAN;
    pragma BUILTIN('IS A SET',18, 2, 40);-- Dummy
  function 'IS NOT A SET'(collection IN  "<TABLE_1>") return BOOLEAN;
    pragma BUILTIN('IS NOT A SET',18, 2, 40);-- Dummy

  function 'IS EMPTY' (collection IN  "<TABLE_1>") return BOOLEAN;
  function 'IS NOT EMPTY'(collection IN  "<TABLE_1>") return BOOLEAN;

  -- IS A SUBMULTISET OF 
  function 'SUBMULTISET' (collection IN  "<TABLE_1>", 
                          collection2 IN "<TABLE_1>")    
    return BOOLEAN;
      pragma BUILTIN('SUBMULTISET',18, 2, 40);

  function 'MULTISET_UNION_ALL' (collection IN  "<TABLE_1>", 
                                 collection2 IN "<TABLE_1>")  
    return "<TABLE_1>"; 
      pragma BUILTIN('MULTISET_UNION_ALL',18, 2, 40);

  function 'MULTISET_UNION_DISTINCT' (collection IN  "<TABLE_1>", 
                                      collection2 IN "<TABLE_1>")  
    return "<TABLE_1>"; 
    pragma BUILTIN('MULTISET_UNION_DISTINCT',18, 2, 40);-- Dummy

  function 'MULTISET_EXCEPT_ALL' (collection IN  "<TABLE_1>", 
                                 collection2 IN "<TABLE_1>")  
    return "<TABLE_1>"; 
    pragma BUILTIN('MULTISET_EXCEPT_ALL',18, 2, 40);-- Dummy

  function 'MULTISET_EXCEPT_DISTINCT' (collection IN  "<TABLE_1>", 
                                      collection2 IN "<TABLE_1>")  
    return "<TABLE_1>"; 
    pragma BUILTIN('MULTISET_EXCEPT_DISTINCT',18, 2, 40);-- Dummy

  function 'MULTISET_INTERSECT_ALL' (collection IN  "<TABLE_1>", 
                                 collection2 IN "<TABLE_1>")  
    return "<TABLE_1>"; 
    pragma BUILTIN('MULTISET_INTERSECT_ALL',18, 2, 40);-- Dummy

  function 'MULTISET_INTERSECT_DISTINCT' (collection IN  "<TABLE_1>", 
                                      collection2 IN "<TABLE_1>")  
    return "<TABLE_1>"; 
    pragma BUILTIN('MULTISET_INTERSECT_DISTINCT',18, 2, 40);-- Dummy

  -- These are dummy procedures for correct management of new control
  -- statements added to PL/SQL. They ensure local procedures which have the
  -- same names as newly introduced keywords are not masked by those keywords.
    
  procedure continue;

  -- REGEXP_COUNT --
  function REGEXP_COUNT(srcstr      VARCHAR2 CHARACTER SET ANY_CS,
                        pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
                        position    PLS_INTEGER := 1,
                        modifier    VARCHAR2 DEFAULT NULL)
    return PLS_INTEGER;
    pragma FIPSFLAG('REGEXP_COUNT', 1452);

  function REGEXP_COUNT(srcstr      CLOB CHARACTER SET ANY_CS,
                        pattern     VARCHAR2 CHARACTER SET srcstr%CHARSET,
                        position    INTEGER := 1,
                        modifier    VARCHAR2 DEFAULT NULL)
    return INTEGER;
    pragma FIPSFLAG('REGEXP_COUNT', 1452);

  --#### All user-visible declarations should preceed this point.  The 
  --#### following are implementation-oriented pragmas that may need
  --#### editing in the future; we would prefer to be able to edit them
  --#### without affecting the rft numbering of user-visible items.

  --#### interface pragmas

  --#### Note that for any ICD which maps directly to a PVM
  --#### Opcode MUST be mapped to pes_dummy.
  --#### An ICD which invokes another ICD by flipping operands is
  --#### mapped to pes_flip, and an ICD whose result is the inverse of
  --#### another ICD is mapped to pes_invert
  --#### New ICDs should be placed at the end of this list, and a 
  --#### corresponding entry must be made in the ICD table in pdz7

  PRAGMA interface(c,length,"pes_dummy",1);
  PRAGMA interface(c,substr,"pes_dummy",1);
  PRAGMA interface(c,instr,"pesist",1);
  PRAGMA interface(c,UPPER,"pesupp",1);
  PRAGMA interface(c,LOWER,"peslow",1);
  PRAGMA interface(c,ASCII,"pesasc");
  PRAGMA interface(c,ASCIISTR,"pesastr");
  PRAGMA interface(c,UNISTR,"pesustr");
  PRAGMA interface(c,CHR,"peschr");
  PRAGMA interface(c," SYS$STANDARD_CHR","peschr");
  PRAGMA interface(c,INITCAP,"pesicp");
  PRAGMA interface(c,LPAD,"peslpd",1);  
  PRAGMA interface(c,LPAD,"peslpd",2);  
  PRAGMA interface(c,RPAD,"pesrpd",1);  
  PRAGMA interface(c,RPAD,"pesrpd",2);
  PRAGMA interface(c,REPLACE,"pesrep",1);
  PRAGMA interface(c,LTRIM,"pesltr",1);
  PRAGMA interface(c,LTRIM,"pesltr",2);
  PRAGMA interface(c,RTRIM,"pesrtr",1);
  PRAGMA interface(c,RTRIM,"pesrtr",2);
  PRAGMA interface(c,'LIKE',"peslik",1);
  PRAGMA interface(c,'LIKE',"pesli2",2);
  PRAGMA interface(c,ABS,"pes_dummy",1);
  PRAGMA interface(c,'MOD',"pesmod", 1);
  PRAGMA interface(c,floor,"pesflo", 1);
  PRAGMA interface(c,CEIL,"pescei", 1);
  PRAGMA interface (c, SQRT, "pessqt", 1);
  PRAGMA interface(c,SIGN,"pessgn", 1);
  PRAGMA interface(c,cos,"pescos", 1);
  PRAGMA interface(c,sin,"pessin",1);
  PRAGMA interface(c,TAN,"pestan",1);
  PRAGMA interface(c,COSH,"pescsh",1);
  PRAGMA interface(c,SINH,"pessnh",1);
  PRAGMA interface(c,TANH,"pestnh",1);
  PRAGMA interface(c,EXP,"pesexp",1);
  PRAGMA interface(c,LN,"pesln",1);
  PRAGMA interface(c,BITAND,"pesbtd",1);
  PRAGMA interface(c,BITAND,"pesbtdn",2);
  PRAGMA interface(c,LOG,"peslog",1);
  PRAGMA interface(c,TRUNC,"pestru",1);
  PRAGMA interface(c,ROUND,"pesrnd",1);
  PRAGMA interface(c,POWER,"pespow",1);
  PRAGMA interface(c,NEW_TIME,"pesnwt");
  PRAGMA interface(c,TO_DATE,"pesc2d",4);
  PRAGMA interface(c,TO_NUMBER,"pesc2n",3);
  PRAGMA interface(c,TO_NUMBER,"pesc2n",4);
  PRAGMA interface(c,'>=',"pes_flip",5); 
  PRAGMA interface(c,'>',"pes_flip",5);  
  PRAGMA interface(c,'<=',"peszle",5);
  PRAGMA interface(c,'<',"peszlt",5);        -- ICD #50
  PRAGMA interface(c,'=',"peszeq",5);  
  PRAGMA interface(c,'!=',"pes_invert",5);
  PRAGMA interface(c,nlssort,"pesxco",2);
  PRAGMA interface(c,NLS_UPPER,"pesxup",1);
  PRAGMA interface(c,NLS_UPPER,"peslcnup",3); -- LOB NLS_UPPER
  PRAGMA interface(c,NLS_UPPER,"peslcnup",4); -- LOB NLS_UPPER
  PRAGMA interface(c,NLS_LOWER,"pesxlo",1);
  PRAGMA interface(c,NLS_LOWER,"peslcnlr",3); -- LOB NLS_LOWER
  PRAGMA interface(c,NLS_LOWER,"peslcnlr",4); -- LOB NLS_LOWER
  PRAGMA interface(c,NLS_INITCAP,"pesxcp",1);
  PRAGMA interface(c,lengthb,"pes_dummy",1);
  PRAGMA interface(c,substrb,"pes_dummy",1);
  PRAGMA interface(c,instrb,"pesxis",1);
  PRAGMA interface(c,TO_SINGLE_BYTE, "pesxsi");
  PRAGMA interface(c,TO_MULTI_BYTE,"pesxmu");
  PRAGMA interface(c,TO_CHAR,"pesd2c",5);
  PRAGMA interface(c,TO_CHAR,"pesn2c",6);
  PRAGMA interface(c,TO_NCHAR,"pesd2c",4);
  PRAGMA interface(c,TO_NCHAR,"pesn2c",5);
  PRAGMA interface(c," SYS$STANDARD_TRANSLATE","pesxcs");
  PRAGMA interface(c,ATAN,"pesatan",1);
  PRAGMA interface(c,EMPTY_CLOB,"peslcem");  
  PRAGMA interface(c,EMPTY_BLOB,"peslbem");
  PRAGMA interface(c,BFILENAME,"pesfnm");  
  PRAGMA interface(c,TO_TIME,"pes3tm",2);
  PRAGMA interface(c,TO_TIME,"pes3tm",3);
  PRAGMA interface(c,TO_TIMESTAMP,"pes3ts",2);
  PRAGMA interface(c,TO_TIMESTAMP,"pes3ts",3);
  PRAGMA interface(c,TO_TIMESTAMP_TZ,"pes3tp",2); 
  PRAGMA interface(c,TO_TIMESTAMP_TZ,"pes3tp",3);
  PRAGMA interface(c,TO_TIME_TZ,"pes3te",2);
  PRAGMA interface(c,TO_TIME_TZ,"pes3te",3); 
  PRAGMA interface(c,TO_DSINTERVAL,"pes2dsi",2);
  PRAGMA interface(c,SYS_AT_TIME_ZONE,"pesatz",1);
  PRAGMA interface(c,SYS_AT_TIME_ZONE,"pesatz",2);
  PRAGMA interface(c,SESSIONTIMEZONE,"pesstz",1);
  PRAGMA interface(c," SYS$STANDARD_TRIM","pestrim",1);
  PRAGMA interface(c," SYS$STANDARD_TRIM","pestrim",2);
  PRAGMA interface(c," SYS$STANDARD_TRIM","pestrim",3);
  PRAGMA interface(c,TRIM,"pestrim",1);
  -- Datetime addition
  PRAGMA interface(c,'+',"pesati",5);    --  +(tsp, iym) return tsp
  PRAGMA interface(c,'+',"pesati",6);    --  +(tsp, ids) return tsp
  PRAGMA interface(c,'+',"pesati",7);    --  +(tsz, iym) return tsz
  PRAGMA interface(c,'+',"pesati",8);    --  +(tsz, ids) return tsz
  PRAGMA interface(c,'+',"pesati",9);    --  +(tim, ids) return tim
  PRAGMA interface(c,'+',"pesati",10);   --  +(tmz, ids) return tmz
  PRAGMA interface(c,'+',"pesadi",11);   --  +(dat, iym) return dat
  PRAGMA interface(c,'+',"pesadi",12);   --  +(dat, ids) return dat
  PRAGMA interface(c,'+',"pes_flip",13); --  +(iym, tsp) return tsp
  PRAGMA interface(c,'+',"pes_flip",14); --  +(iym, tsz) return tsz -- ICD #100
  PRAGMA interface(c,'+',"pes_flip",15); --  +(iym, dat) return dat
  PRAGMA interface(c,'+',"pes_flip",16); --  +(ids, tsp) return tsp
  PRAGMA interface(c,'+',"pes_flip",17); --  +(ids, tsz) return tsz
  PRAGMA interface(c,'+',"pes_flip",18); --  +(ids, tim) return tim
  PRAGMA interface(c,'+',"pes_flip",19); --  +(ids, tmz) return tmz
  PRAGMA interface(c,'+',"pes_flip",20); --  +(ids, dat) return dat
  PRAGMA interface(c,'+',"pesaii",21);   --  +(ids, ids) return ids
  PRAGMA interface(c,'+',"pesaii",22);   --  +(iym, iym) return iym
  PRAGMA interface(c,'+',"pesati",23);   --  +(ltz, iym) return ltz
  PRAGMA interface(c,'+',"pesati",24);   --  +(ltz, ids) return ltz
  PRAGMA interface(c,'+',"pes_flip",25);--  +(iym, ltz) return ltz
  PRAGMA interface(c,'+',"pes_flip",26);--  +(ids, ltz) return ltz
  -- Datetime subtraction
  PRAGMA interface(c,'-',"pessti",6);    --  -(tsp, iym) return tsp
  PRAGMA interface(c,'-',"pessti",7);    --  -(tsp, ids) return tsp
  PRAGMA interface(c,'-',"pessti",8);    --  -(tsz, iym) return tsz
  PRAGMA interface(c,'-',"pessti",9);    --  -(tsz, ids) return tsz
  PRAGMA interface(c,'-',"pessti",10);   --  -(tim, ids) return tim
  PRAGMA interface(c,'-',"pessti",11);   --  -(tmz, ids) return tmz
  PRAGMA interface(c,'-',"pessdi",12);   --  -(dat, iym) return dat
  PRAGMA interface(c,'-',"pessdi",13);   --  -(dat, ids) return dat
  PRAGMA interface(c,'-',"pessii",14);   --  -(iym, iym) return iym
  PRAGMA interface(c,'-',"pessii",15);   --  -(ids, ids) return ids
  PRAGMA interface(c,'-',"pessttds",16); --  -(tim, tim) return ids
  PRAGMA interface(c,'-',"pessttds",17); --  -(tsp, tsp) return ids
  PRAGMA interface(c,'-',"pessttds",18); --  -(tmz, tmz) return ids
  PRAGMA interface(c,'-',"pessttds",19); --  -(tsz, tsz) return ids
  PRAGMA interface(c,'-',"pessti",20);   --  -(ltz, iym) return iym
  PRAGMA interface(c,'-',"pessti",21);   --  -(ltz, ids) return ids
  PRAGMA interface(c,'-',"pessttds",22); --  -(ltz, ltz) return ids
  PRAGMA interface(c," SYS$DSINTERVALSUBTRACT","pessttds",1);
  PRAGMA interface(c," SYS$DSINTERVALSUBTRACT","pessttds",2);
  PRAGMA interface(c," SYS$DSINTERVALSUBTRACT","pessttds",3);
  PRAGMA interface(c," SYS$DSINTERVALSUBTRACT","pessttds",4);
  PRAGMA interface(c," SYS$DSINTERVALSUBTRACT","pessddds",5);
  PRAGMA interface(c," SYS$DSINTERVALSUBTRACT","pessttds",6);
  PRAGMA interface(c," SYS$YMINTERVALSUBTRACT","pessttym",1);
  PRAGMA interface(c," SYS$YMINTERVALSUBTRACT","pessttym",2);
  PRAGMA interface(c," SYS$YMINTERVALSUBTRACT","pessddym",3);
  PRAGMA interface(c," SYS$YMINTERVALSUBTRACT","pessttym",4);
  -- Datetime multiplication
  PRAGMA interface(c,'*',"pesmni",2);    --  *(num, iym) return iym
  PRAGMA interface(c,'*',"pesmni",3);    --  *(num, ids) return ids
  PRAGMA interface(c,'*',"pes_flip",4);  --  *(iym, num) return iym
  PRAGMA interface(c,'*',"pes_flip",5);  --  *(ids, num) return ids
  -- Datetime division
  PRAGMA interface(c,'/',"pesdvin",2);   --  /(iym, num) return iym
  PRAGMA interface(c,'/',"pesdvin",3);   --  /(ids, num) return ids
  -- TIME
  PRAGMA interface(c,'=',"pes_dummy",9);
  PRAGMA interface(c,'!=',"pes_invert",9);
  PRAGMA interface(c,'>',"pes_flip",8);
  PRAGMA interface(c,'<',"pes_dummy",8);
  PRAGMA interface(c,'>=',"pes_flip",8);   -- ICD #150
  PRAGMA interface(c,'<=',"pes_dummy",8);
  -- TIME WITH TIME ZONE
  PRAGMA interface(c,'=',"pes_dummy",10);
  PRAGMA interface(c,'!=',"pes_invert",10);
  PRAGMA interface(c,'>',"pes_flip",9);
  PRAGMA interface(c,'<',"pes_dummy",9);
  PRAGMA interface(c,'>=',"pes_flip",9);
  PRAGMA interface(c,'<=',"pes_dummy",9);
  -- TIMESTAMP
  PRAGMA interface(c,'=',"pes_dummy",11);
  PRAGMA interface(c,'!=',"pes_invert",11);
  PRAGMA interface(c,'>',"pes_flip",10);
  PRAGMA interface(c,'<',"pes_dummy",10);
  PRAGMA interface(c,'>=',"pes_flip",10);
  PRAGMA interface(c,'<=',"pes_dummy",10);
  -- INTERVAL YEAR TO MONTH
  PRAGMA interface(c,'=',"pes_dummy",12);
  PRAGMA interface(c,'!=',"pes_invert",12);
  PRAGMA interface(c,'>',"pes_flip",11);
  PRAGMA interface(c,'<',"pes_dummy",11);
  PRAGMA interface(c,'>=',"pes_flip",11);
  PRAGMA interface(c,'<=',"pes_dummy",11);
  -- INTERVAL DAY TO SECOND
  PRAGMA interface(c,'=',"pes_dummy",13);
  PRAGMA interface(c,'!=',"pes_invert",13);
  PRAGMA interface(c,'>',"pes_flip",12);
  PRAGMA interface(c,'<',"pes_dummy",12);
  PRAGMA interface(c,'>=',"pes_flip",12);
  PRAGMA interface(c,'<=',"pes_dummy",12);
  -- TIMESTAMP_TZ_UNCONSTRAINED     
  PRAGMA interface(c,'=',"pes_dummy",14);
  PRAGMA interface(c,'!=',"pes_invert",14);
  PRAGMA interface(c,'>',"pes_flip",13);
  PRAGMA interface(c,'<',"pes_dummy",13);
  PRAGMA interface(c,'>=',"pes_flip",13);
  PRAGMA interface(c,'<=',"pes_dummy",13);
  -- TIMESTAMP WITH LOCAL TIME ZONE
  PRAGMA interface(c,'=',"pes_dummy",15);
  PRAGMA interface(c,'!=',"pes_invert",15);
  PRAGMA interface(c,'>',"pes_flip",14);
  PRAGMA interface(c,'<',"pes_dummy",14);
  PRAGMA interface(c,'>=',"pes_flip",14);
  PRAGMA interface(c,'<=',"pes_dummy",14);
  -- Other datetime functions
  PRAGMA interface(c,'CURRENT_DATE',"pescdt",1);
  PRAGMA interface(c,'CURRENT_TIME',"pesctm",1);
  PRAGMA interface(c,'CURRENT_TIMESTAMP',"pescts",1);
  --  Internal calls to evaluate datetime/interval literals without NLS parms.
  PRAGMA interface(c,SYS_LITERALTOYMINTERVAL,"pesc2ymi",1);
  PRAGMA interface(c,SYS_LITERALTODSINTERVAL,"pesc2dsi",1);
  PRAGMA interface(c,SYS_LITERALTOTIME,"pesc2tim",1);
  PRAGMA interface(c,SYS_LITERALTOTZTIME,"pesc2tim",1);
  PRAGMA interface(c,SYS_LITERALTOTIMESTAMP,"pesc2tsp",1);
  PRAGMA interface(c,SYS_LITERALTOTZTIMESTAMP,"pesc2tsp",1);
  PRAGMA interface(c,SYS_LITERALTODATE,"pesc2date",1);
  -- extract(field from expr)
  PRAGMA interface(c," SYS$EXTRACT_FROM","pesefd",1);  
  PRAGMA interface(c," SYS$EXTRACT_FROM","pesefd",2);
  PRAGMA interface(c," SYS$EXTRACT_FROM","pesefd",3);   -- ICD #200
  PRAGMA interface(c," SYS$EXTRACT_FROM","pesefd",4);
  PRAGMA interface(c," SYS$EXTRACT_FROM","pesefd",5);
  PRAGMA interface(c," SYS$EXTRACT_FROM","pesefdt",6);
  PRAGMA interface(c," SYS$EXTRACT_FROM","pesefi",7);
  PRAGMA interface(c," SYS$EXTRACT_FROM","pesefi",8);
  -- datetime is null
  PRAGMA interface(c,"IS NULL","pes_dummy",14); -- time
  PRAGMA interface(c,"IS NULL","pes_dummy",15); -- time wtz
  PRAGMA interface(c,"IS NULL","pes_dummy",16); -- timestamp
  PRAGMA interface(c,"IS NULL","pes_dummy",17); -- timestamp wtz
  PRAGMA interface(c,"IS NULL","pes_dummy",18); -- timestamp lwtz
  PRAGMA interface(c,"IS NULL","pes_dummy",19); -- interval ym
  PRAGMA interface(c,"IS NULL","pes_dummy",20); -- interval ds

  -- 8.2 LOB Built-in Functions 
  PRAGMA interface(c,length, "peslcln",2);    -- LOB LENGTH
  PRAGMA interface(c,lengthb,"peslclb",2);    -- LOB LENGTHB
  PRAGMA interface(c,substr, "peslcst",2);    -- LOB SUBSTR
  PRAGMA interface(c,substrb,"peslcsb",2);    -- LOB SUBSTRB
  PRAGMA interface(c,instr,  "peslcin",2);    -- LOB INSTR
  PRAGMA interface(c,instrb, "peslcib",2);    -- LOB INSTRB  
  PRAGMA interface(c,'||',   "peslcct",2);    -- LOB '||'
  PRAGMA interface(c,concat, "peslcct",2);    -- LOB CONCAT
  PRAGMA interface(c,lpad,   "peslclp",3);    -- LOB LPAD
  PRAGMA interface(c,lpad,   "peslclp",4);    -- LOB LPAD
  PRAGMA interface(c,rpad,   "peslcrp",3);    -- LOB RPAD
  PRAGMA interface(c,rpad,   "peslcrp",4);    -- LOB RPAD
  PRAGMA interface(c,lower,  "peslclr",2);    -- LOB LOWER
  PRAGMA interface(c,upper,  "peslcup",2);    -- LOB UPPER
  PRAGMA interface(c,ltrim,  "peslclm",3);    -- LOB LTRIM
  PRAGMA interface(c,ltrim,  "peslclm",4);    -- LOB LTRIM
  PRAGMA interface(c,rtrim,  "peslcrm",3);    -- LOB RTRIM
  PRAGMA interface(c,rtrim,  "peslcrm",4);    -- LOB RTRIM
  PRAGMA interface(c,trim,   "peslctr",2);    -- LOB TRIM
  PRAGMA interface(c," SYS$STANDARD_TRIM","peslctr",4); -- LOB TRIM
  PRAGMA interface(c," SYS$STANDARD_TRIM","peslctr",5); -- LOB TRIM
  PRAGMA interface(c," SYS$STANDARD_TRIM","peslctr",6); -- LOB TRIM
  PRAGMA interface(c,'LIKE', "peslclk",3);    -- LOB LIKE
  PRAGMA interface(c,'LIKE', "peslcl2",4);    -- LOB LIKE
  PRAGMA interface(c,nvl,"peslcnl",17);       -- LOB NVL
  PRAGMA interface(c,replace, "peslcrl",2);   -- LOB REPLACE

     -- LOB Relational Operators 
     -- LHS: CLOB,    RHS:CLOB
  PRAGMA interface(c,'=' ,"pes_dummy",16);     -- LOB '='
  PRAGMA interface(c,'!=',"pes_invert",16);    -- LOB '!='
  PRAGMA interface(c,'>' ,"pes_flip",15);      -- LOB '>'
  PRAGMA interface(c,'<' ,"pes_dummy",15);     -- LOB '<'
  PRAGMA interface(c,'>=',"pes_flip",15);      -- LOB '>='
  PRAGMA interface(c,'<=',"pes_dummy",15);       -- LOB '<='
     -- LHS: CLOB,     RHS:VARCHAR2
  PRAGMA interface(c,'=' ,"pesleq2",17);       -- LOB '='
  PRAGMA interface(c,'!=',"pes_invert",17);    -- LOB '!='
  PRAGMA interface(c,'>' ,"pes_flip",16);      -- LOB '>'
  PRAGMA interface(c,'<' ,"pesllt2",16);       -- LOB '<'
  PRAGMA interface(c,'>=',"pes_flip",16);      -- LOB '>='
  PRAGMA interface(c,'<=',"peslle2",16);       -- LOB '<='  -- ICD #250
     -- LHS: VARCHAR2, RHS:CLOB
  PRAGMA interface(c,'=' ,"pes_flip",18);      -- LOB '='
  PRAGMA interface(c,'!=',"pes_flip",18);      -- LOB '!='
  PRAGMA interface(c,'>' ,"pes_flip",17);      -- LOB '>'
  PRAGMA interface(c,'<' ,"pesllt3",17);       -- LOB '<'
  PRAGMA interface(c,'>=',"pes_flip",17);      -- LOB '>='
  PRAGMA interface(c,'<=',"peslle3",17);       -- LOB '<='

  PRAGMA interface(c,length, "peslbln",3);    -- BLOB LENGTH
  PRAGMA interface(c,lengthb,"peslblb",3);    -- BLOB LENGTHB
  -- End of 8.2 LOB Built-in Functions 


  PRAGMA interface(c,tz_offset,"pestzo",1); 
  PRAGMA interface(c,from_tz,"pesftz",1); 

  PRAGMA interface(c,ISNCHAR,"pesinc", 1); 

  PRAGMA interface(c,CONVERT,"pescnv", 1);
  PRAGMA interface(c,CONVERT,"pescnv", 2);
  PRAGMA interface(c,CONVERT,"peslccnv", 3);  -- LOB CONVERT
  PRAGMA interface(c,CONVERT,"peslccnv", 4);  -- LOB CONVERT

  PRAGMA interface(c," SYS$EXTRACT_STRING_FROM","pesefdrvc2",1);
  PRAGMA interface(c," SYS$EXTRACT_STRING_FROM","pesefdrvc2",2);
  PRAGMA interface(c," SYS$EXTRACT_STRING_FROM","pesefdrvc2",3);

  PRAGMA interface(c,TO_CHAR,"pesdtm2c",7); -- datetime 
  PRAGMA interface(c,TO_CHAR,"pesdtm2c",8);
  PRAGMA interface(c,TO_CHAR,"pesdtm2c",9);
  PRAGMA interface(c,TO_CHAR,"pesdtm2c",10);
  PRAGMA interface(c,TO_CHAR,"pesdtm2c",11);
  PRAGMA interface(c,TO_CHAR,"pesdtm2c",12);
  PRAGMA interface(c,TO_CHAR,"pesdtm2c",13);
  PRAGMA interface(c,TO_CHAR,"pesdtm2c",14);
  PRAGMA interface(c,TO_CHAR,"pesdtm2c",15);
  PRAGMA interface(c,TO_CHAR,"pesdtm2c",16);
  PRAGMA interface(c,TO_CHAR,"pesitv2c",17); -- interval 
  PRAGMA interface(c,TO_CHAR,"pesitv2c",18);
  PRAGMA interface(c,TO_CHAR,"pesitv2c",19);
  PRAGMA interface(c,TO_CHAR,"pesitv2c",20);
  
  --#### new_names pragmas

  -- This is an internal pragma that restricts the use
  -- of particular new entries in package standard.
  -- It is only valid in package standard.
  -- Note that left out of the 8.1.5 set are non datetime
  -- entries urowid, "UROWID ", self_is_null and trim.

  pragma new_names('8.1.5',
                   time,"TIME WITH TIME ZONE",
                   timestamp,"TIMESTAMP WITH TIME ZONE",
                   "INTERVAL DAY TO SECOND",
                   "INTERVAL YEAR TO MONTH",
                   to_time, to_timestamp,
                   to_time_tz, to_timestamp_tz,
                   " SYS$DSINTERVALSUBTRACT",
                   " SYS$YMINTERVALSUBTRACT",
                   to_yminterval,to_dsinterval,
                   NUMTOYMINTERVAL, NUMTODSINTERVAL,
                   current_date, 
                   current_time,current_timestamp);

  pragma new_names('8.1.6',
                   dbtimezone, sessiontimezone, localtimestamp,
                   localtime, 
                   cube, rollup, grouping, "TIMESTAMP WITH LOCAL TIME ZONE");

  -- Should there be a 8.2 new names pragma ?

  -- 8.2 UCS2/UCS4/Complete Built-in Functions

  PRAGMA interface(c,INSTR2,"pesist2",1);
  PRAGMA interface(c,INSTR4,"pesist4",1);
  PRAGMA interface(c,INSTRC,"pesistc",1);

  PRAGMA interface(c,LENGTH2,"peslen2",1);
  PRAGMA interface(c,LENGTH4,"peslen4",1);
  PRAGMA interface(c,LENGTHC,"peslenc",1);

  PRAGMA interface(c,LIKE2,"peslik2",1);
  PRAGMA interface(c,LIKE2,"pesli22",2);
  PRAGMA interface(c,LIKE4,"peslik4",1);
  PRAGMA interface(c,LIKE4,"pesli42",2);
  PRAGMA interface(c,LIKEC,"peslikc",1);
  PRAGMA interface(c,LIKEC,"peslic2",2);

  PRAGMA interface(c,SUBSTR2,"pes_dummy",1);
  PRAGMA interface(c,SUBSTR4,"pes_dummy",1);
  PRAGMA interface(c,SUBSTRC,"pes_dummy",1);
  PRAGMA interface(c,SYS_EXTRACT_UTC,"pessexu");
  PRAGMA interface(c,COMPOSE,"pescomp");
  PRAGMA interface(c,DECOMPOSE,"pesdcmp");



  -- End of 8.2 UCS2/UCS4/Complete Built-in Functions

  -- Begin REGEXP support (10iR1) --
  PRAGMA interface(c,regexp_like,    "pes_dummy",1);
  PRAGMA interface(c,regexp_instr,   "pes_dummy",1);    -- ICD #300
  PRAGMA interface(c,regexp_substr,  "pes_dummy",1);
  PRAGMA interface(c,regexp_replace, "pes_dummy",1);
  PRAGMA interface(c,regexp_count,   "pes_dummy",1);
  PRAGMA interface(c,regexp_like,    "pes_dummy",2);    -- LOB REGEXP_LIKE
  PRAGMA interface(c,regexp_instr,   "pes_dummy",2);    -- LOB REGEXP_INSTR
  PRAGMA interface(c,regexp_substr,  "pes_dummy",2);    -- LOB REGEXP_SUBSTR
  PRAGMA interface(c,regexp_replace, "pes_dummy",2);    -- LOB REGEXP_REPLACE
  PRAGMA interface(c,regexp_count,   "pes_dummy",2);    -- LOB REGEXP_COUNT
  PRAGMA interface(c,regexp_replace, "pes_dummy",3);    -- LOB REGEXP_REPLACE

  -- End of REGEXP Built-in Functions --


  -- 10i Binary Floating-point Built-in Functions

  PRAGMA interface(c,"IS NAN","pesnanf",2);
  PRAGMA interface(c,"IS NAN","pesnand",3);
  PRAGMA interface(c,"IS INFINITE","pesinf",1);
  PRAGMA interface(c,"IS INFINITE","pesinff",2);
  PRAGMA interface(c,"IS INFINITE","pesinfd",3);
  PRAGMA interface(c,TO_BINARY_FLOAT,"pesc2flt",2);
  PRAGMA interface(c,TO_BINARY_FLOAT,"pesc2flt",3);
  PRAGMA interface(c,TO_BINARY_DOUBLE,"pesc2dbl",2);
  PRAGMA interface(c,TO_BINARY_DOUBLE,"pesc2dbl",3);
  PRAGMA interface(c,TO_CHAR,"pesflt2c",21);
  PRAGMA interface(c,TO_CHAR,"pesdbl2c",22);
  PRAGMA interface(c,TO_CHAR,"pesflt2c",23);
  PRAGMA interface(c,TO_CHAR,"pesdbl2c",24);
  PRAGMA interface(c,TO_NCHAR,"pesflt2c",6);
  PRAGMA interface(c,TO_NCHAR,"pesdbl2c",7);
  PRAGMA interface(c,TO_NCHAR,"pesflt2c",8);
  PRAGMA interface(c,TO_NCHAR,"pesdbl2c",9);
  PRAGMA interface(c,'REMAINDER',"pesrem", 1);
  PRAGMA interface(c,REMAINDER,"pesrem", 2);
  PRAGMA interface(c,'REMAINDER',"pesremf", 3);
  PRAGMA interface(c,REMAINDER,"pesremf", 4);
  PRAGMA interface(c,'REMAINDER',"pesremd", 5);
  PRAGMA interface(c,REMAINDER,"pesremd", 6);
  PRAGMA interface(c,ABS,"pes_dummy",2);
  PRAGMA interface(c,ABS,"pes_dummy",3);
  PRAGMA interface(c,ABS,"pes_dummy",4);
  PRAGMA interface(c,ATAN,"pesatand",2);
  PRAGMA interface(c,'MOD',"pesmodf", 2);
  PRAGMA interface(c,'MOD',"pesmodd", 3);
  PRAGMA interface(c,floor,"pesflof", 2);
  PRAGMA interface(c,floor,"pesflod", 3);
  PRAGMA interface(c,CEIL,"pesceif", 2);
  PRAGMA interface(c,CEIL,"pesceid", 3);
  PRAGMA interface (c, SQRT, "pessqtf", 2);
  PRAGMA interface (c, SQRT, "pessqtd", 3);
  PRAGMA interface(c,SIGN,"pessgnf", 2);
  PRAGMA interface(c,SIGN,"pessgnd", 3);
  PRAGMA interface(c,SIGN,"pessgni", 4);
  PRAGMA interface(c,cos,"pescosd", 2);
  PRAGMA interface(c,sin,"pessind",2);
  PRAGMA interface(c,TAN,"pestand",2);
  PRAGMA interface(c,COSH,"pescshd",2);
  PRAGMA interface(c,SINH,"pessnhd",2);   -- ICD #350
  PRAGMA interface(c,TANH,"pestnhd",2);
  PRAGMA interface(c,EXP,"pesexpd",2);
  PRAGMA interface(c,LN,"peslnd",2);
  PRAGMA interface(c,LOG,"peslogd",2);
  PRAGMA interface(c,TRUNC,"pestruf",4);
  PRAGMA interface(c,TRUNC,"pestrud",5);
  PRAGMA interface(c,TRUNC,"pestrui",6);
  PRAGMA interface(c,ROUND,"pesrndf",4);
  PRAGMA interface(c,ROUND,"pesrndd",5);
  PRAGMA interface(c,ROUND,"pesrndi",6);
  PRAGMA interface(c,POWER,"pespowd",2);

  -- End of 10i Binary Floating-point Built-in Functions

  -- ICDs for MULTISET

  PRAGMA interface(c,CARDINALITY,"pesmcnt"); 
  PRAGMA interface(c,"IS EMPTY","pesmie"); 
  PRAGMA interface(c,"IS NOT EMPTY","pes_invert",1);
  -- ICDs which used to be in the body of standard, but which new COG can
  -- handle directly

  -- NOT (some ICD)
  PRAGMA interface(c,NOT_LIKE,"pes_invert",1);
  PRAGMA interface(c,NOT_LIKE,"pes_invert",2);
  PRAGMA interface(c,NOT_LIKE,"pes_invert",3);
  PRAGMA interface(c,NOT_LIKE,"pes_invert",4);
  PRAGMA interface(c,NOT_LIKE2,"pes_invert",1);
  PRAGMA interface(c,NOT_LIKE2,"pes_invert",2);
  PRAGMA interface(c,NOT_LIKE4,"pes_invert",1);
  PRAGMA interface(c,NOT_LIKE4,"pes_invert",2);
  PRAGMA interface(c,NOT_LIKEC,"pes_invert",1);
  PRAGMA interface(c,NOT_LIKEC,"pes_invert",2);
  PRAGMA interface(c,"IS NOT NAN","pes_invert",2);
  PRAGMA interface(c,"IS NOT NAN","pes_invert",3);
  PRAGMA interface(c,"IS NOT INFINITE","pes_invert",1);
  PRAGMA interface(c,"IS NOT INFINITE","pes_invert",2);
  PRAGMA interface(c,"IS NOT INFINITE","pes_invert",3);

  -- datetime is not null
  PRAGMA interface(c,"IS NOT NULL","pes_dummy",14); -- time
  PRAGMA interface(c,"IS NOT NULL","pes_dummy",15); -- time wtz
  PRAGMA interface(c,"IS NOT NULL","pes_dummy",16); -- timestamp
  PRAGMA interface(c,"IS NOT NULL","pes_dummy",17); -- timestamp wtz
  PRAGMA interface(c,"IS NOT NULL","pes_dummy",18); -- timestamp lwtz
  PRAGMA interface(c,"IS NOT NULL","pes_dummy",19); -- interval ym
  PRAGMA interface(c,"IS NOT NULL","pes_dummy",20); -- interval ds

  -- Misc
  PRAGMA interface(c,"**",   "pespow",1);    -- number
  PRAGMA interface(c,"**",   "pespowd",2);   -- binary double
  PRAGMA interface(c,"ACOS", "pesacosd",2);  -- binary double
  PRAGMA interface(c,"ASIN", "pesasind",2);  -- binary double
  PRAGMA interface(c,"ATAN2","pesatn2d",2);  -- binary double

  -- All the flavors of NVL
  PRAGMA interface(c,nvl,"pes_dummy",1);       -- Boolean -- ICD #400
  PRAGMA interface(c,nvl,"pes_dummy",2);       -- Varchar2
  PRAGMA interface(c,nvl,"pes_dummy",3);       -- Number
  PRAGMA interface(c,nvl,"pes_dummy",4);       -- Date
  PRAGMA interface(c,nvl,"pes_dummy",5);       -- MLSLabel
  PRAGMA interface(c,nvl,"pes_dummy",6);       -- ADT
  PRAGMA interface(c,nvl,"pes_dummy",7);       -- Ref ADT
  PRAGMA interface(c,nvl,"pes_dummy",8);       -- Collection

--  Ref Cursor has problems. The MOVCR instruction needs more information than
--  the other MOV* instructions, including the PVM register of the destination
--  This cannot be easily supplied through the generic NVL instruction, so
--  for now, this flavor will continue to have a real body
--  PRAGMA interface(c,nvl,"pes_dummy",9);       -- Ref Cursor

  PRAGMA interface(c,nvl,"pes_dummy",10);       -- Time
  PRAGMA interface(c,nvl,"pes_dummy",11);       -- Time-tz
  PRAGMA interface(c,nvl,"pes_dummy",12);       -- Timestamp
  PRAGMA interface(c,nvl,"pes_dummy",13);       -- Timestamp-tz
  PRAGMA interface(c,nvl,"pes_dummy",14);       -- Timestamp-ltz
  PRAGMA interface(c,nvl,"pes_dummy",15);       -- Intervalym
  PRAGMA interface(c,nvl,"pes_dummy",16);       -- Intervalds
--  PRAGMA interface(c,nvl,"pes_dummy",17);       -- Clob (Handled above, ICD)
  PRAGMA interface(c,nvl,"pes_dummy",18);       -- Opaque
  PRAGMA interface(c,nvl,"pes_dummy",19);       -- Binaryfloat
  PRAGMA interface(c,nvl,"pes_dummy",20);       -- Binarydouble
  PRAGMA interface(c,nvl,"pes_dummy",21);       -- PLSInteger

  -- The following pragma overrides any other setting of the timestamp,
  -- and is used so that we recognize the client-side and server-side instances
  -- of package STANDARD as being the same.  Package STANDARD is special in
  -- that it is really the root of the PL/SQL dependencies graph; as such it
  -- itself doesn't ever need recompiling due to changes to things below it.
  -- The pragma mechanism used here is currently ignored except for
  -- package STANDARD, but in future may not be.  Do NOT add similar pragmas
  -- to your own code as it may in future interfere with the package
  -- consistency maintenance mechanisms and could have dire results.

  --#### timestamp pragma (please keep this last)
  pragma TIMESTAMP('2006-04-18:00:00:00');
end;

/
