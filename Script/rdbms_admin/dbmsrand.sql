Rem
Rem $Header: rdbms/admin/dbmsrand.sql /st_rdbms_11.2.0/1 2013/03/11 01:24:43 yujwang Exp $
Rem
Rem dbmsrand.sql
Rem
Rem Copyright (c) 1997, 2013, Oracle and/or its affiliates. 
Rem All rights reserved.
Rem
Rem    NAME
Rem      dbmsrand.sql - RANDom number generation package
Rem
Rem    DESCRIPTION
Rem      This produces random numbers
Rem
Rem    NOTES
Rem    MODIFIED   (MM/DD/YY)
Rem    yberezin    02/26/13 - record and replay random number - bug 12676338
Rem    traney      01/08/09 - add authid definer
Rem    ssonawan    09/20/06 - bug 5527875: add parallel_enable clause
Rem    rjenkins    05/09/02 - bug 2383801: fix string()
Rem    rjenkins    08/03/01 - remove limit of 60 characters on string
Rem    gviswana    05/25/01 - CREATE OR REPLACE SYNONYM
Rem    tkawasak    02/11/01 - Fix Bug#1541060
Rem    rburns      09/08/00 - sqlplus fixes
Rem    rjenkins    02/02/98 - faster, more precision, more options, auto init
Rem    rwessman    04/14/97 - Renamed package to conform to naming standards.
Rem    rwessman    04/14/97 - PL/SQL random number package
Rem    rwessman    04/14/97 - Renamed from network_src/admin/random.sql.
Rem
CREATE OR REPLACE PACKAGE dbms_random AUTHID DEFINER AS

    ------------
    --  OVERVIEW
    --
    --  This package should be installed as SYS.  It generates a sequence of
    --  random 38-digit Oracle numbers.  The expected length of the sequence
    --  is about power(10,28), which is hopefully long enough.
    --
    --------
    --  USAGE
    --
    --  This is a random number generator.  Do not use for cryptography.
    --  For more options the cryptographic toolkit should be used.
    --
    --  By default, the package is initialized with the current user
    --  name, current time down to the second, and the current session.
    --
    --  If this package is seeded twice with the same seed, then accessed
    --  in the same way, it will produce the same results in both cases.
    --
    --------
    --  EXAMPLES
    --
    --  To initialize or reset the generator, call the seed procedure as in:
    --      execute dbms_random.seed(12345678);
    --    or
    --      execute dbms_random.seed(TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS'));
    --  To get the random number, simply call the function, e.g.
    --      my_random_number BINARY_INTEGER;
    --      my_random_number := dbms_random.random;
    --    or
    --      my_random_real NUMBER;
    --      my_random_real := dbms_random.value;
    --  To use in SQL statements:
    --      select dbms_random.value from dual;
    --      insert into a values (dbms_random.value);
    --      variable x NUMBER;
    --      execute :x := dbms_random.value;
    --      update a set a2=a2+1 where a1 < :x;

    -- Seed with a binary integer
    PROCEDURE seed(val IN BINARY_INTEGER);
    PRAGMA restrict_references (seed, WNDS);

    -- Seed with a string (up to length 2000)
    PROCEDURE seed(val IN VARCHAR2);
    PRAGMA restrict_references (seed, WNDS);

    -- Get a random 38-digit precision number, 0.0 <= value < 1.0
    FUNCTION value RETURN NUMBER PARALLEL_ENABLE;
    PRAGMA restrict_references (value, WNDS);

    -- get a random Oracle number x, low <= x < high
    FUNCTION value (low IN NUMBER, high IN NUMBER) RETURN NUMBER 
                   PARALLEL_ENABLE;
    PRAGMA restrict_references (value, WNDS);

    -- get a random number from a normal distribution
    FUNCTION normal RETURN NUMBER PARALLEL_ENABLE;
    PRAGMA restrict_references (normal, WNDS);

    -- get a random string
    FUNCTION string (opt char, len NUMBER)
          /* "opt" specifies that the returned string may contain:
             'u','U'  :  upper case alpha characters only
             'l','L'  :  lower case alpha characters only
             'a','A'  :  alpha characters only (mixed case)
             'x','X'  :  any alpha-numeric characters (upper)
             'p','P'  :  any printable characters
          */
        RETURN VARCHAR2 PARALLEL_ENABLE;  -- string of <len> characters
    PRAGMA restrict_references (string, WNDS);

    -- external C function to record random value
    PROCEDURE record_random_number(val IN NUMBER);
    PRAGMA restrict_references (record_random_number, WNDS);

    -- external C function to replay random value
    FUNCTION replay_random_number RETURN NUMBER;
    PRAGMA restrict_references (replay_random_number, WNDS);

    -- Obsolete, just calls seed(val)
    PROCEDURE initialize(val IN BINARY_INTEGER);
    PRAGMA restrict_references (initialize, WNDS);

    -- Obsolete, get integer in ( -power(2,31) <= random < power(2,31) )
    FUNCTION random RETURN BINARY_INTEGER PARALLEL_ENABLE;
    PRAGMA restrict_references (random, WNDS);

    -- Obsolete, does nothing
    PROCEDURE terminate;

    TYPE num_array IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
END dbms_random;
/




CREATE OR REPLACE PACKAGE BODY dbms_random AS
    mem        num_array;           -- big internal state hidden from the user
    counter    BINARY_INTEGER := 55;-- counter through the results
    saved_norm NUMBER := NULL;      -- unused random normally distributed value
    need_init  BOOLEAN := TRUE;     -- do we still need to initialize


    -- Seed the random number generator with a binary_integer
    PROCEDURE seed(val IN BINARY_INTEGER) IS
    BEGIN
	seed(TO_CHAR(val));
    END seed;


    -- Seed the random number generator with a string.
    PROCEDURE seed(val IN VARCHAR2) IS
        junk     VARCHAR2(2000);
        piece    VARCHAR2(20);
        randval  NUMBER;
        mytemp   NUMBER;
        j        BINARY_INTEGER;
    BEGIN
        need_init   := FALSE;
        saved_norm  := NULL;
        counter     := 0;
        junk        := TO_SINGLE_BYTE(val);
        FOR i IN 0..54 LOOP
            piece   := SUBSTR(junk,1,19);
            randval := 0;
            j       := 1;

            -- convert 19 characters to a 38-digit number
            FOR j IN 1..19 LOOP
                randval := 1e2*randval + NVL(ASCII(SUBSTR(piece,j,1)),0.0);
            END LOOP;

            -- try to avoid lots of zeros
            randval := randval*1e-38+i*.01020304050607080910111213141516171819;
            mem(i)  := randval - TRUNC(randval);

            -- we've handled these first 19 characters already; move on
            junk    := SUBSTR(junk,20);
        END LOOP;

	randval := mem(54);
        FOR j IN 0..10 LOOP
            FOR i IN 0..54 LOOP

                -- barrelshift mem(i-1) by 24 digits
                randval := randval * 1e24;
                mytemp  := TRUNC(randval);
                randval := (randval - mytemp) + (mytemp * 1e-38);

                -- add it to mem(i)
                randval := mem(i)+randval;
                IF (randval >= 1.0) THEN
                    randval := randval - 1.0;
                END IF;

		-- record the result
                mem(i) := randval;
            END LOOP;
        END LOOP;
    END seed;


   PROCEDURE record_random_number(val IN NUMBER) IS
       LANGUAGE C
       NAME "kecrRecordRandomNumber"
       LIBRARY dbms_workload_capture_lib
       WITH CONTEXT
       PARAMETERS
       ( CONTEXT,
         val OCINumber );

   FUNCTION replay_random_number RETURN NUMBER IS
       LANGUAGE C
       NAME "kecpReplayRemappedRandomNumber"
       LIBRARY dbms_workload_replay_lib
       WITH CONTEXT
       PARAMETERS
       ( CONTEXT,
         RETURN INDICATOR );

    -- give values to the user
    -- Delayed Fibonacci, pilfered from Knuth volume 2
    FUNCTION value RETURN NUMBER  PARALLEL_ENABLE IS
    randval  NUMBER;
    BEGIN

        randval := replay_random_number();  -- null if not in replay mode
        IF randval IS NOT NULL THEN
            RETURN randval;
        END IF;

        counter := counter + 1;
        IF counter >= 55 THEN

            -- initialize if needed
            IF (need_init = TRUE) THEN
                seed(TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS') ||
                     USER || USERENV('SESSIONID'));
            ELSE
                -- need to generate 55 more results
                FOR i IN 0..30 LOOP
                    randval := mem(i+24) + mem(i);
                    IF (randval >= 1.0) THEN
                        randval := randval - 1.0;
                    END IF;
                    mem(i) := randval;
                END LOOP;
                FOR i IN 31..54 LOOP
                    randval := mem(i-31) + mem(i);
                    IF (randval >= 1.0) THEN
                        randval := randval - 1.0;
                    END IF;
                    mem(i) := randval;
                END LOOP;
            END IF;
            counter := 0;
        END IF;

        record_random_number(mem(counter));  -- no-op if not in recording

        RETURN mem(counter);
    END value;


    -- Random 38-digit number between LOW and HIGH.
    FUNCTION value ( low in NUMBER, high in NUMBER) RETURN NUMBER 
                   PARALLEL_ENABLE is
    BEGIN
        RETURN (value*(high-low))+low;
    END value;


    -- Random numbers in a normal distribution.
    -- Pilfered from Knuth volume 2.
    FUNCTION normal RETURN NUMBER PARALLEL_ENABLE is  
                    -- 38 decimal places: Mean 0, Variance 1
        v1  NUMBER;
        v2  NUMBER;
        r2  NUMBER;
        fac NUMBER;
    BEGIN
        IF saved_norm is not NULL THEN     -- saved from last time
            v1 := saved_norm;              -- to be returned this time
            saved_norm := NULL;
        ELSE
            r2 := 2;
            -- Find two independent uniform variables
            WHILE r2 > 1 OR r2 = 0 LOOP
                v1 := value();
                v1 := v1 + v1 - 1;
                v2 := value();
                v2 := v2 + v2 - 1;
                r2 := v1*v1 + v2*v2;  -- r2 is radius
            END LOOP;      -- 0 < r2 <= 1:  in unit circle
            /* Now derive two independent normally-distributed variables */
            fac := sqrt(-2*ln(r2)/r2);
            v1 := v1*fac;          -- to be returned this time
            saved_norm := v2*fac;  -- to be saved for next time
        END IF;
        RETURN v1;
    END  normal;


    -- Random string.  Pilfered from Chris Ellis.
    FUNCTION string (opt char, len NUMBER) 
        RETURN VARCHAR2 PARALLEL_ENABLE is      -- string of <len> characters 
        optx char (1)  := lower(opt); 
        rng  NUMBER; 
        n    BINARY_INTEGER; 
        ccs  VARCHAR2 (128);    -- candidate character subset 
        xstr VARCHAR2 (4000) := NULL; 
    BEGIN 
        IF    optx = 'u' THEN    -- upper case alpha characters only 
            ccs := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; 
            rng := 26; 
        ELSIF optx = 'l' THEN    -- lower case alpha characters only 
            ccs := 'abcdefghijklmnopqrstuvwxyz'; 
            rng := 26; 
        ELSIF optx = 'a' THEN    -- alpha characters only (mixed case) 
            ccs := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' || 
                  'abcdefghijklmnopqrstuvwxyz'; 
            rng := 52; 
        ELSIF optx = 'x' THEN    -- any alpha-numeric characters (upper) 
            ccs := '0123456789' || 
                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; 
            rng := 36; 
        ELSIF optx = 'p' THEN    -- any printable char (ASCII subset) 
            ccs := ' !"#$%&''()*+,-./' || '0123456789' || ':;<=>?@' || 
                  'ABCDEFGHIJKLMNOPQRSTUVWXYZ' || '[\]^_`' || 
                  'abcdefghijklmnopqrstuvwxyz' || '{|}~' ; 
            rng := 95; 
        ELSE 
            ccs := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'; 
            rng := 26;          -- default to upper case 
        END IF; 
        FOR i IN 1 .. least(len,4000) LOOP 
            /* Get random integer within specified range */ 
            n := TRUNC(rng * value) + 1; 
            /* Append character to string  */ 
            xstr := xstr || SUBSTR(ccs,n,1); 
        END LOOP; 
        RETURN xstr; 
    END string; 

    -- For compatibility with 8.1
    PROCEDURE initialize(val IN BINARY_INTEGER) IS
    BEGIN
	seed(to_char(val));
    END initialize;


    -- For compatibility with 8.1
    -- Random binary_integer, -power(2,31) <= Random < power(2,31)
    -- Delayed Fibonacci, pilfered from Knuth volume 2
    FUNCTION random RETURN BINARY_INTEGER PARALLEL_ENABLE IS
    BEGIN
	RETURN TRUNC(Value*4294967296)-2147483648;
    END random;


    -- For compatibility with 8.1
    PROCEDURE terminate IS
    BEGIN
	NULL;
    END terminate;

END dbms_random;
/
CREATE OR REPLACE PUBLIC SYNONYM dbms_random FOR sys.dbms_random;
GRANT EXECUTE ON dbms_random TO public;



