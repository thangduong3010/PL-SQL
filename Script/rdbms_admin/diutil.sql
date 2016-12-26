Rem
Rem $Header: diutil.sql 25-apr-2006.15:01:04 wxli Exp $ 
Rem
Rem Copyright (c) 1992, 2006, Oracle. All rights reserved.  
Rem   NAME
Rem     diutil.pls - package DIUTIL
Rem
Rem   DESCRIPTION
Rem     Diana application routines
Rem
Rem   RETURNS
Rem
Rem   NOTES
Rem     <other useful comments, qualifications, etc.>
Rem
Rem   MODIFIED    (MM/DD/YY)
Rem      wxli      04/25/06 - remove procedure pstub since the generated
Rem                           functions are no longer available:bug 5126756
Rem      wxli      10/06/03 - bug-3157646: change to temporary table 
Rem      jmuller   05/28/99 - Fix bug 708690: TAB -> blank
Rem      dalpern   07/18/97 - bug 504692 - handle character set any_cs
Rem      dnizhego  04/11/97 - add procedures to report diana size
Rem      rhari     04/01/97 - #407223, Support for LIBRARY
Rem      usundara  03/07/96 - sys.pstubtbl --> pstubtbl
Rem      usundara  12/08/95 - subptxt: print  DEFAULTED for parameter default v
Rem      cbarclay  11/21/95 - merge percenttype change
Rem      cbarclay  11/10/95 - merge: fix is_v6_compatible type
Rem      usundara  07/28/95 - bugfix 264375 (mrg from 2.32) - add load_source
Rem                           modify eText : include D_NUMERI and D_NULL_A.
Rem     zwalcott   07/05/95 -  merge from 2.3 to 3.0. bug 268956.
Rem     zwalcott   06/18/95 -  merge from 2.2.  Bug 268956.  fix in normalName
Rem     zwalcott   06/14/95 -  fix bug : 268956.  var firstChar   in function n
Rem     usundara   10/01/94 -  merge from 1.23.720.5: PSTUBI,PSTUBQ,PSTUBR
Rem     usundara   06/07/94 -  merge 1.20.710.3 and 1.20.710.4 (bug #196374);
Rem                            also, don't pass in PUBLIC cos kgl does this.
Rem     usundara   04/08/94 -  merge changes from branch 1.20.710.2
Rem                            fix traversals (161306,147036) add libunit_type
Rem     usundara   01/06/94 -  fix #190597; deal with %type; reindent (merge)
Rem     smuench    05/26/93 -  fix problems w/ boolean support
Rem     pshaw      10/21/92 -  modify script for bug 131187 
Rem     gclossma   09/28/92 -  sanitize 
Rem     gclossma   09/07/92 -  logic error (as if there's some other kind?) 
Rem     gclossma   09/04/92 -  no more to-varchar2 
Rem     gclossma   08/05/92 -  source-control Steve M's changes for booleans 
Rem     smuench    07/17/92 -  add boolean param supt, int_to_bool/bool_to_int
Rem     gclossma   07/14/92 -  pstubT: add constraints to CHARs; bigger pkgs 
Rem     gclossma   05/08/92 -  simplify; check buffer lengths 
Rem     gclossma   04/10/92 -  gen CHAR stead of VARCHAR2 for sqlforms3 for v6 
Rem     ahong      03/25/92 -  fix synonym expansion for pstub
Rem     ahong      03/20/92 -  add s_notInPackage
Rem     ahong      03/12/92 -  synonym
Rem     ahong      03/10/92 -  no s_noPriv
Rem     ahong      03/03/92 -  return empty instead of null
Rem     ahong      02/21/92 -  upper names
Rem     ahong      02/11/92 -  Creation


Rem  NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
Rem  NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
Rem  NOTE: you must be connected "internal" (i.e. as user SYS) to run this
Rem  script.
Rem  NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
Rem  NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE


drop table sys.pstubtbl
/

create global temporary table sys.pstubtbl ( 
  username varchar2(30), 
  dbname   varchar2(128), 
  lun      varchar2(30), 
  lutype   varchar2(3), 
  lineno   number, 
  line     varchar2(1800) 
) on commit preserve rows 
/ 

grant select,delete on sys.pstubtbl to public
/

drop package body sys.diutil
/

drop package sys.diutil
/

CREATE OR REPLACE PACKAGE sys.diutil IS

  e_subpnotfound EXCEPTION;
  e_notinpackage EXCEPTION;
  e_nopriv EXCEPTION;
  e_stubtoolong EXCEPTION;
  e_notv6compat EXCEPTION;
  e_other EXCEPTION;
  
  SUBTYPE ptnod IS pidl.ptnod;
  SUBTYPE ub4 IS pidl.ub4;
  
  --   RETURN code FROM diutil functions
  --
  s_ok CONSTANT NUMBER := 0;            -- successful
  s_notinpackage CONSTANT NUMBER := 6;  -- PACKAGE found, proc NOT found
  s_subpnotfound CONSTANT NUMBER := 1;  -- subprogram NOT found
  s_stubtoolong CONSTANT NUMBER := 3;   -- text TO be returned IS too long
  s_logic CONSTANT NUMBER := 4;         -- logic error
  s_other CONSTANT NUMBER := 5;         -- other error
  s_defaultval CONSTANT NUMBER := 8;    -- true iff parameters have DEFAULT
  --   VALUES.  applicable TO pstub
  s_notv6compat CONSTANT NUMBER := 7;   -- found non v6 TYPE OR construct
  
  char_for_varchar2 BOOLEAN;            -- SET FROM flags FOR v6 compatibility
  
  libunit_type_spec CONSTANT NUMBER := 1;
  libunit_type_body CONSTANT NUMBER := 2;
  
  load_source_yes CONSTANT NUMBER := 1;
  load_source_no  CONSTANT NUMBER := 2;
  
  -- get_d: returns the root OF the diana OF a libunit, given name AND usr.
  --    name will be first folded TO upper CASE IF NOT IN quotes, ELSE stripped
  --    OF quotes.
  --    IN:  name = subprogram name
  --         usr  = user name
  --         dbname = database name, NULL FOR CURRENT
  --         dbowner = NULL FOR CURRENT
  --         libunit_type = libunit_type_spec FOR spec,
  --                      = libunit_type_body FOR BODY
  --    OUT: status = s_ok(0): diana root returned IN nod
  --                  s_subpnotfound:  nod NULL
  --                  s_other:   other error, nod NULL
  --
  PROCEDURE get_d(name VARCHAR2, usr VARCHAR2, dbname VARCHAR2,
                    dbowner VARCHAR2, status IN OUT ub4, nod OUT ptnod, 
                    libunit_type NUMBER := libunit_type_spec,
                    load_source NUMBER := load_source_no);
  
  -- get_diana: returns the root OF the diana OF a libunit, given name AND usr.
  --    name will be first folded TO upper CASE IF NOT IN quotes, ELSE stripped
  --    OF quotes.  will trace synonym links.
  --    IN:  name = subprogram name
  --         usr  = user name
  --         dbname = database name, NULL FOR CURRENT
  --         dbowner = NULL FOR CURRENT
  --         libunit_type = libunit_type_spec FOR spec,
  --                      = libunit_type_body FOR BODY
  --    OUT: status = s_ok(0): diana root returned IN nod
  --                  s_subpnotfound:  nod NULL
  --                  s_other:   other error, nod NULL
  --
  PROCEDURE get_diana(name VARCHAR2, usr VARCHAR2, dbname VARCHAR2,
                        dbowner VARCHAR2, status IN OUT ub4, nod IN OUT ptnod,
                        libunit_type NUMBER := libunit_type_spec,
                        load_source NUMBER := load_source_no);
  
  -- subptxt: returns the text OF a subprogram source (describe).
  --    IN:  name - PACKAGE OR toplevel proc/func name;
  --         subname - non-NULL TO specify proc/func IN PACKAGE <name>.
  --         dbname - database name
  --         dbowner - dbase owner
  --    OUT:  status = s_ok (0): text returned IN txt
  --                   s_subpnotfound: txt empty
  --                   s_notinpackagte: txt empty
  --                   s_stubtoolong: txt len too small; txt empty
  --                   s_logic: logic error; txt empty
  --                   s_other: other failure; txt empty
  --
  PROCEDURE subptxt(name VARCHAR2, subname VARCHAR2, usr VARCHAR2, 
    dbname VARCHAR2, dbowner VARCHAR2, txt IN OUT VARCHAR2,
    status IN OUT ub4);
  
  -- bool_to_int:  translates 3-valued BOOLEAN TO NUMBER FOR USE
  --               IN sending BOOLEAN parameter / RETURN VALUES
  --               BETWEEN pls v1 (client) AND pls v2. since sqlnet
  --               has no BOOLEAN bind variable TYPE, we encode 
  --               booleans AS false = 0, true = 1, NULL = NULL FOR
  --               network transfer AS NUMBER
  --
  FUNCTION bool_to_int( b BOOLEAN) RETURN NUMBER;
  
  -- int_to_bool:  translates 3-valued NUMBER encoding TO BOOLEAN FOR USE
  --               IN sending BOOLEAN parameter / RETURN VALUES
  --               BETWEEN pls v1 (client) AND pls v2. since sqlnet
  --               has no BOOLEAN bind variable TYPE, we encode 
  --               booleans AS false = 0, true = 1, NULL = NULL FOR
  --               network transfer AS NUMBER
  --
  function int_to_bool( n NUMBER) return boolean;

  -- node_use_statistics: reports libunit's node count and limit
  -- 
  -- Parameters:
  -- 
  --   libunit_node : legal ptnod, as returned by get_diana or get_d
  --   node_count   : how many diana nodes the unit contains   
  --   node_limit   : that many diana nodes allowed to allocate
  -- 
  procedure node_use_statistics (libunit_node IN ptnod, 
                                 node_count out ub4,
                                 node_limit out ub4);

  -- attribute_use_statistics: reports libunit's attribute count and limit
  -- 
  -- Parameters:
  -- 
  --   libunit_node       : legal ptnod, as returned by get_diana or get_d
  --   attribute_count   : how many diana attributes the unit contains   
  --   attribute_limit   : that many diana attributes allowed to allocate
  -- 
  procedure attribute_use_statistics (libunit_node IN ptnod,
                                        attribute_count out ub4, 
                                        attribute_limit out ub4);

end diutil;
/


Rem
Rem  Package body DIUTIL:
Rem
Rem
create OR replace PACKAGE BODY sys.diutil IS

  defvaloption_ignore CONSTANT NUMBER := 0;
  defvaloption_full CONSTANT NUMBER := 1;
  defvaloption_default_comment CONSTANT NUMBER := 2;

  -----------------------
  --  PRIVATE members
  -----------------------

  PROCEDURE diugdn(name VARCHAR2, usr VARCHAR2, dbname VARCHAR2,
                   dbowner VARCHAR2, status OUT ub4, nod OUT ptnod,
                   libunit_type BINARY_INTEGER,
                   load_source BINARY_INTEGER);
    PRAGMA interface(c,diugdn);
  PROCEDURE diustx(n ptnod, txt OUT VARCHAR2, status OUT ub4);
    PRAGMA interface(c,diustx);

  assertval CONSTANT BOOLEAN := true;

  -----------------------
  -- assert
  -----------------------
  PROCEDURE assert(v BOOLEAN, str VARCHAR2) IS
    x INTEGER;
  BEGIN
    IF (assertval AND NOT v) THEN
      RAISE program_error;
    END IF;
  END assert;

  -----------------------
  -- assert
  -----------------------
  PROCEDURE assert(v BOOLEAN) IS
  BEGIN
    assert(v, '');
  END;

  -----------------------
  -- last_elt
  -----------------------
  FUNCTION last_elt (seq pidl.ptseqnd) RETURN pidl.ptnod IS
    len BINARY_INTEGER;
  BEGIN
    len := pidl.ptslen(seq);
    assert(len > 0);
    RETURN pidl.ptgend(seq, len - 1);
  END last_elt;

  -----------------------
  -- normalname: RETURN a normalized name.  fold up IF NOT IN quotes,
  -- ELSE strip quotes.
  -----------------------
  FUNCTION normalname(name VARCHAR2) RETURN VARCHAR2 IS
    firstchar VARCHAR2(4);
    len NUMBER;
  BEGIN
    IF (name IS NULL OR name = '') THEN RETURN name; END IF;
    firstchar := substr(name, 1, 1);
    IF (firstchar = '"') THEN
      len := length(name);
      IF (len > 1 AND substr(name, len, 1) = '"') THEN
        IF (len > 33) THEN
          len := 31;
        ELSE
          len := len-2;
        END IF;
        RETURN substr(name, 2, len);
      END IF;
     END IF;
     RETURN upper(name);
  END normalname;

  -----------------------
  -- coatname: enquote name IF necessary
  -----------------------
  FUNCTION coatname(name VARCHAR2) RETURN VARCHAR2 IS
  BEGIN
    IF (name <> upper(name)) THEN
      RETURN '"' || name || '"';
    ELSIF char_for_varchar2 AND name = 'VARCHAR2' THEN
      RETURN 'CHAR';
    ELSE
      RETURN name;
    END IF;
  END coatname;

  -----------------------
  -- idname
  -----------------------
  FUNCTION idname(n ptnod) RETURN VARCHAR2 IS
    -- RETURN the text OF an id node.  this FUNCTION IS also
    -- used TO limit the recursion IN exprtext() below.
    -- should have the semantics OF listtext(diana.as_list(n), ',');
    seq pidl.ptseqnd;
  BEGIN
    assert(pidl.ptkin(n) = diana.ds_id);
    seq := diana.as_list(n);
    RETURN coatname(diana.l_symrep(last_elt(seq)));
  END idname;

  -----------------------
  -- exprtext: general unparsing FUNCTION
  -----------------------
  PROCEDURE exprtext(x ptnod, rv IN OUT VARCHAR2);

  -----------------------
  -- genprocspec
  --  append the spec FOR a top-LEVEL node n TO stext.
  --  defvaloption controls whether parm DEFAULT vals should be ignored,
  --    printed fully OR flagged IN comments AS "defaulted"
  --  hasdefval returned true iff parm DEFAULT vals exist.
  --  toplevel name returned IN pname.  
  --  IF FUNCTION, FUNCTION STRING returned IN returnval.
  -----------------------
  PROCEDURE genprocspec(n ptnod, 
                        defvaloption NUMBER,
                        hasdefval IN OUT BOOLEAN,
                        pname IN OUT VARCHAR2, 
                        returnval IN OUT VARCHAR2, 
                        flags VARCHAR2,
                        stext IN OUT VARCHAR2);


  -----------------------
  -- procname
  -----------------------
  FUNCTION procname(k ptnod) RETURN VARCHAR2 IS
    x ptnod; xkind pidl.ptnty;
  BEGIN
    IF (k IS NULL OR k = 0) THEN RETURN NULL; END IF;
    IF (pidl.ptkin(k) <> diana.d_s_decl) THEN RETURN NULL; END IF;
    x := diana.a_d_(k);
    xkind := pidl.ptkin(x);
    IF (    xkind <> diana.di_funct
        AND xkind <> diana.di_proc
        AND xkind <> diana.d_def_op) THEN
      RETURN NULL;
    END IF;
    RETURN diana.l_symrep(x);
  END;


  -----------------------
  --  PRIVATE members
  -----------------------


  -----------------------
  -- get_d
  -----------------------
  PROCEDURE get_d (name VARCHAR2, usr VARCHAR2, dbname VARCHAR2,
                   dbowner VARCHAR2, status IN OUT ub4, nod OUT ptnod,
                   libunit_type NUMBER := libunit_type_spec,
                   load_source NUMBER := load_source_no) IS
    nname VARCHAR2(100);
    nusr VARCHAR2(100);
    ndbname VARCHAR2(100);
    ndbowner VARCHAR2(100);
  BEGIN -- get_d
    nod := NULL;
    BEGIN
      nname := normalname(name);
      nusr := normalname(usr);
      ndbname := normalname(dbname);
      ndbowner := normalname(dbowner);
      IF (nname IS NULL OR nname = '') THEN
        RAISE e_subpnotfound;
      END IF;
      diugdn(nname, nusr, ndbname, ndbowner, status, nod,
             libunit_type, load_source);

      IF (status = 1) THEN
        diugdn(nname, '', ndbname, ndbowner, status, nod,
               libunit_type, load_source);
      END IF;

      IF (status = 1) THEN
        RAISE e_subpnotfound;
      ELSIF (status = 2) THEN
        RAISE e_nopriv;
      ELSIF (status <> 0) THEN
        RAISE e_other;
      END IF;
      status := s_ok;
    EXCEPTION
      WHEN e_subpnotfound THEN
        status := s_subpnotfound;
      WHEN e_nopriv THEN
        status := s_subpnotfound;
      WHEN OTHERS THEN
        status := s_other;
    END;
  END get_d;

  -----------------------
  -- get_diana
  -----------------------
  PROCEDURE get_diana (name VARCHAR2, usr VARCHAR2, dbname VARCHAR2,
                       dbowner VARCHAR2,
                       status IN OUT ub4, nod IN OUT ptnod,
                       libunit_type NUMBER := libunit_type_spec,
                       load_source NUMBER := load_source_no) IS
    t ptnod;
  BEGIN -- get_diana
    nod := NULL;
    BEGIN
      get_d(name, usr, dbname, dbowner, status, nod,
            libunit_type, load_source);
      IF (status = s_ok) THEN
        t := diana.a_unit_b(nod);
        assert(pidl.ptkin(t) <> diana.q_create);
      END IF;
    EXCEPTION
      WHEN program_error THEN
        status := s_other;
      WHEN OTHERS THEN
        status := s_other;
    END;
  END get_diana;


  -----------------------
  -- subptxt
  -----------------------
  PROCEDURE subptxt(name VARCHAR2, subname VARCHAR2, usr VARCHAR2,
                    dbname VARCHAR2, dbowner VARCHAR2, txt IN OUT VARCHAR2, 
                    status IN OUT ub4) IS
    e_defaultval BOOLEAN := false;

    -----------------------
    -- describeproc
    -----------------------
    PROCEDURE describeproc(n ptnod, s IN OUT VARCHAR2) IS
      tmpval VARCHAR2(100);
      rval VARCHAR2(500);
    BEGIN -- describeproc
      -- we call genprocspec here because it IS NOT
      -- possible TO get the text reliably FOR arbitrary node
      -- through diustx
      --
      tmpval := NULL;
      genprocspec(n, defvaloption_default_comment,
                  e_defaultval, tmpval, rval, '', s);
      s := s || '; ';
    END describeproc;

  BEGIN -- subptxt
    txt := '';

    DECLARE
      troot ptnod;
      n ptnod;
      nsubname VARCHAR2(100);
    BEGIN
      get_diana(name, usr, dbname, dbowner, status, troot,
                libunit_type_spec, load_source_yes);
      IF (troot IS NULL OR troot = 0) THEN RETURN; END IF;

      nsubname := normalname(subname);
      n := diana.a_unit_b(troot);

      IF (nsubname IS NULL OR nsubname = '') THEN
        IF ((pidl.ptkin(n) = diana.d_p_decl) OR
            (pidl.ptkin(n) = diana.d_library)) THEN
          diustx(troot, txt, status);
        ELSE
          describeproc(n, txt);
        END IF;
      ELSE
        -- search FOR subname among ALL func/proc IN the PACKAGE
        IF (pidl.ptkin(n) <> diana.d_p_decl) THEN
          status := s_subpnotfound;
          RETURN;
        END IF;
        n := diana.a_packag(n);
        DECLARE
          seq pidl.ptseqnd := diana.as_list(diana.as_decl1(n));
          len INTEGER := pidl.ptslen(seq) - 1;
          tmp INTEGER;
        BEGIN
          FOR i IN 0..len LOOP --FOR each MEMBER OF the PACKAGE
            n := pidl.ptgend(seq, i);
            IF (procname(n) = nsubname) THEN
              describeproc(n, txt);
            END IF;
          END LOOP;
        END;
        IF (txt IS NULL OR txt = '') THEN
          status := s_notinpackage;
        END IF;
      END IF;

    EXCEPTION   -- txt reset TO NULL
      WHEN value_error THEN
        status := s_stubtoolong;
      WHEN program_error THEN
        status := s_logic;
      WHEN e_other THEN
        status := s_other;
      WHEN OTHERS THEN
        status := s_other;
    END;
  END subptxt;


  -----------------------------------------------------------------------
  --     PRIVATE implementations
  -----------------------------------------------------------------------


  --------------------
  -- exprtext:
  --  general unparsing FUNCTION
  --------------------
  PROCEDURE exprtext(x ptnod, rv IN OUT VARCHAR2) IS

    --------------------
    -- etext:
    --------------------
    PROCEDURE etext(n ptnod);

    --------------------
    -- listtext
    --------------------
    PROCEDURE listtext(seq pidl.ptseqnd, spc VARCHAR2) IS
      len INTEGER;
    BEGIN
      len := pidl.ptslen(seq);
      IF (len >= 1) THEN
        etext(pidl.ptgend(seq, 0));
        len := len - 1;
        FOR i IN 1..len LOOP
          rv := rv || spc;
          etext(pidl.ptgend(seq, i));
        END LOOP;
      END IF;
    END;

    --------------------
    -- etext:
    --------------------
    PROCEDURE etext(n ptnod) IS
      nkind pidl.ptnty;
    BEGIN
      IF (n IS NOT NULL) THEN
        nkind := pidl.ptkin(n);
        -- simple expr
        IF (nkind = diana.di_u_nam OR nkind = diana.d_used_b
        OR nkind = diana.di_u_blt OR nkind = diana.di_funct
        OR nkind = diana.di_proc OR nkind = diana.di_packa
        OR nkind = diana.di_var OR nkind = diana.di_type
        OR nkind = diana.di_subty OR nkind = diana.di_in
        OR nkind = diana.di_out OR nkind = diana.di_in_ou) THEN
          rv := rv ||  coatname(diana.l_symrep(n));

        ELSIF (nkind = diana.d_s_ed) THEN
          -- x.y
          etext(diana.a_name(n));
          rv := rv || '.';
          etext(diana.a_d_char(n));

        ELSIF (nkind = diana.d_string OR nkind = diana.d_used_c 
        OR nkind = diana.d_def_op) THEN
          rv := rv || '''' || diana.l_symrep(n) || '''';

        ELSIF (nkind = diana.d_attrib) THEN
          -- x.y%TYPE
          -- simply ADD the %TYPE text rather than try TO resolve
          -- it TO get the name OF the TYPE
          --
          etext(diana.a_name(n));
          rv := rv || '%';
          etext(diana.a_id(n));

        ELSIF (nkind = diana.d_numeri) THEN
          rv := rv ||  diana.l_numrep(n);

        ELSIF (nkind = diana.d_null_a) THEN
          rv := rv ||  'null';

        ELSIF (nkind = diana.d_constr) THEN  -- constraint
          etext(diana.a_name(n));
          -- -- Function params and returns do not accept constraints directly.
          -- IF (diana.a_constt(n) IS NOT NULL AND diana.a_constt(n) <> 0) THEN
          --   rv := rv || ' ';
          --   etext(diana.a_constt(n));
          -- END IF;
          IF (diana.a_constt(n) IS NOT NULL AND diana.a_constt(n) <> 0) THEN
            RAISE e_notv6compat;
          END IF;
          IF (diana.a_cs(n) IS NOT NULL) THEN
            IF ((diana.s_charset_form(diana.a_cs(n)) = 1) OR
                (diana.s_charset_form(diana.a_cs(n)) = 4)) THEN
              -- SQLCS_IMPLICIT: don't need to mark anything.
              -- SQLCS_FLEXIBLE: for now, don't mark anything.  If we ever
              --   need to support v8 clients, for those we'd want marking.
              NULL;
            ELSE
              -- SQLCS_NCHAR and SQLCS_EXPLICIT cases are not usable by v6
              --   or v7 clients.  SQLCS_LIT_NULL should never occur as the
              --   type of a formal or result.  Anything else is really bogus.
              RAISE e_notv6compat;
            END IF;
          END IF;

        /*
        -- 14jul92 =g=> many OF these remaining cases BY an work,
        -- but aren't needed.

        -- implicit conversion
        ELSIF (nkind = diana.d_parm_c) THEN
          DECLARE seq pidl.ptseqnd := diana.as_list(diana.as_p_ass(n));
          BEGIN
            etext(last_elt(seq));
          END; 

        -- arglist
        ELSIF (nkind = diana.ds_apply) THEN
          DECLARE aseq ptnod := diana.as_list(n); BEGIN
            rv := rv || '(';
            listtext(aseq, ',');
            rv := rv || ')';
          END;

        -- d_f_call
        ELSIF (nkind = diana.d_f_call) THEN
          DECLARE args ptnod := diana.as_p_ass(n);
          BEGIN
            IF (pidl.ptkin(args) <> diana.ds_param) THEN
              -- ordinary function call
              etext(diana.a_name(n));
              etext(args);
            ELSE  -- operator functions, determine if unary or n-ary
              DECLARE s pidl.ptseqnd := diana.as_list(args);
                namenode ptnod := diana.a_name(n);
              BEGIN
                IF (pidl.ptslen(s) = 1) THEN -- unary
                  etext(namenode);
                  rv := rv || ' ';
                  etext(pidl.ptgend(s, 0));
                ELSE exprtext(namenode, rv); listtext(s, rv);
                END IF;
              END;
            END IF;
          END;

        -- parenthesized expr
        -- whenever this gets uncommented, we must fully support the
        -- D_F_CALL case as well (Usha - 6/28/95)
        ELSIF (nkind = diana.d_parent) THEN
          rv := rv || '(';
          etext(diana.a_exp(n));
          rv := rv || ')';

        -- binary logical operation
        ELSIF (nkind = diana.d_binary) THEN
          etext(diana.a_exp1(n));
          rv := rv || ' '; 
          etext(diana.a_binary(n));
          rv := rv || ' '; 
          etext(diana.a_exp2(n));
        ELSIF (nkind = diana.d_and_th) THEN
          rv := rv || 'and';
        ELSIF (nkind = diana.d_or_els) THEN
          rv := rv || 'or';

        ELSIF (nkind = diana.ds_id) THEN  -- idList
          -- listText(diana.as_list(n), ','); causes PL/SQL Check #21037.
          DECLARE seq pidl.ptseqnd := diana.as_list(n);
          BEGIN       
            rv := rv || coatname(diana.l_symrep(last_elt(seq)));
          END;

        ELSIF (nkind = diana.ds_d_ran) THEN
          DECLARE seq pidl.ptseqnd := diana.as_list(n);
            x ptnod;
          BEGIN
            x := last_elt(seq);
            etext(diana.a_name(x));
          END;

        -- declarations
        ELSIF (nkind = diana.d_var OR nkind = diana.d_consta) THEN 
          -- var and const
          etext(diana.as_id(n));
          rv := rv || ' ';
          IF (nkind = diana.d_consta) THEN
            rv := rv || 'constant ';
          END IF;
          etext(diana.a_type_s(n));
          IF (diana.a_object(n) IS NOT NULL AND diana.a_object(n) <> 0) THEN
            rv := rv || ' := ';
            etext(diana.a_object(n));
          ELSE assert(nkind <> diana.d_consta);
          END IF;

        ELSIF (nkind = diana.d_intege) THEN
          etext(diana.a_range(n));
        ELSIF (nkind = diana.d_range) THEN
          IF (diana.a_exp1(n) IS NOT NULL AND diana.a_exp1(n) <> 0) THEN
            -- in case of array single index;
            rv := rv || 'range ';
            etext(diana.a_exp1(n));
            rv := rv || '..';
          END IF;
          etext(diana.a_exp2(n));

        ELSIF (nkind = diana.d_type) THEN -- type declaration
          rv := rv || 'type ';
          etext(diana.a_id(n));
          IF (diana.a_type_s(n) IS NOT NULL AND diana.a_type_s(n) <> 0) THEN
            rv := rv || ' is ';
            etext(diana.a_type_s(n));
          END IF;
        ELSIF (nkind = diana.d_subtyp) THEN -- subtype declaration
          rv := rv || 'subtype ';
          etext(diana.a_id(n));
          rv := rv || ' is ';
          etext(diana.a_constd(n));
        ELSIF (nkind = diana.d_r_) THEN -- record type
          rv := rv || 'record (';
          -- listText(diana.as_list(n), ','); causes PL/SQL Check #21037.
          DECLARE seq pidl.ptseqnd := diana.as_list(n);
          BEGIN
            listtext(seq, ', ');
          END;
          rv := rv || ')';
        ELSIF (nkind = diana.d_array) THEN
          rv := rv || 'table of ';
          etext(diana.a_name(diana.a_constd(n)));
          rv := rv || '(';
          etext(diana.a_constt(diana.a_constd(n)));
          rv := rv || ') indexed by ';
          etext(diana.as_dscrt(n));
        ELSIF (nkind = diana.d_except) THEN
          etext(diana.as_id(n));
          rv := rv || ' exception';

        */

        ELSE
          RAISE e_notv6compat;
        END IF;

      END IF;
    END etext;

  BEGIN -- exprText
    etext(x);
  END exprtext;


  --------------------
  -- is_v6_type
  --
  -- check whether given D_NAME node (from an a_NAME(parm)) names a
  -- v6-compatible type, e.g., DATE, NUMBER, or CHAR
  --------------------
  FUNCTION is_v6_type (typenode ptnod) RETURN BOOLEAN IS
    typename VARCHAR2(100);
    percenttype BOOLEAN;
  BEGIN
    typename := '';
    exprtext(typenode, typename);
    typename := ltrim(rtrim(typename));
    percenttype := ( length(typename) > 5 AND 
                    substr(typename, -5, 5) = '%TYPE' );
    /* check length as else will get null as substr result */
    IF  (typename = '' OR typename IS NULL) OR
    NOT (   typename = 'DATE'
         OR typename = 'NUMBER'
         OR typename = 'BINARY_INTEGER'
         OR typename = 'PLS_INTEGER'
         OR typename = 'CHAR'
         OR typename = 'VARCHAR2'
         OR typename = 'VARCHAR'
         OR typename = 'INTEGER'
         OR typename = 'BOOLEAN'
         OR percenttype 
    --   or typename = 'RAW'
    --   or typename = 'CHARN'
    --   or typename = 'STRING'
    --   or typename = 'STRINGN'
    --   or typename = 'DATEN'
    --   or typename = 'NUMBERN'
    --   or typename = 'PLS_INTEGERN'
    --   or typename = 'NATURAL'
    --   or typename = 'NATURALN'
    --   or typename = 'POSITIVE'
    --   or typename = 'POSITIVEN'
    --   or typename = 'SIGNTYPE'
    --   or typename = 'BOOLEANN'
    --   or typename = 'REAL'
    --   or typename = 'DECIMAL'
    --   or typename = 'FLOAT'
        )
    THEN
      RETURN false;
    ELSE
      RETURN true;
    END IF;
  END is_v6_type;


  --------------------
  -- genProcSpec:
  --  Append the spec for a top-level node n to sText.
  --  defValOption controls whether parm default vals should be ignored,
  --    printed fully or flagged in comments as "DEFAULTED"
  --  hasDefVal returned true iff parm default vals exist.
  --  Toplevel name returned in pName.  If function, function
  --  string returned in returnVal.
  --------------------
  PROCEDURE genprocspec(n ptnod,
                        defvaloption NUMBER,
                        hasdefval IN OUT BOOLEAN,
                        pname IN OUT VARCHAR2, 
                        returnval IN OUT VARCHAR2,
                        flags VARCHAR2,
                        stext IN OUT VARCHAR2) IS
    nodekind pidl.ptnty;
    leftchild ptnod;
    rightchild ptnod;
    returntypenode ptnod;

    --------------------
    -- genParmText
    --------------------
    PROCEDURE genparmtext(parmseq pidl.ptseqnd) IS
      -- append text for param list sText
      parmnum NATURAL;
      k ptnod;
      knd pidl.ptnty;
    BEGIN
      parmnum := pidl.ptslen(parmseq);
      IF (parmnum > 0) THEN
        stext := stext || ' (';
        FOR i IN 1 .. parmnum LOOP
          k := pidl.ptgend(parmseq, i-1);
          assert(k IS NOT NULL);
          stext := stext || idname(diana.as_id(k)) || ' ';
          knd := pidl.ptkin(k);
          IF (knd = diana.d_out) THEN
            stext := stext || 'out ';
          ELSIF (knd = diana.d_in_out) THEN
            stext := stext || 'in out ';
          ELSE
            assert(knd = diana.d_in);
          END IF;
          exprtext(diana.a_name(k), stext);
          IF 0 < instr(flags, '6') AND NOT is_v6_type(diana.a_name(k)) THEN
            RAISE e_notv6compat;
          END IF;

          k := diana.a_exp_vo(k);
          IF (k IS NOT NULL AND k <> 0) THEN
            hasdefval := true;
            IF defvaloption = defvaloption_full THEN
              stext := stext || ' := ';
              exprtext(k, stext);
            ELSIF defvaloption = defvaloption_default_comment THEN
              stext := stext || ' /* DEFAULTED */';
            ELSE
              assert(defvaloption = defvaloption_ignore);
            END IF;
          END IF;

          IF (i < parmnum) THEN
            stext := stext || ', ';
          END IF;
        END LOOP;

      stext := stext || ')';
      END IF;
    END genparmtext;

  BEGIN -- genProcSpec
    -- generate a procedure declaration into sText spec

    returnval := '';
    assert(n IS NOT NULL);
    leftchild := diana.a_d_(n);
    assert(leftchild IS NOT NULL);
    nodekind := pidl.ptkin(leftchild);

    rightchild := diana.a_header(n);
    IF (nodekind = diana.di_funct OR nodekind = diana.d_def_op) THEN
      stext := stext || 'function ';
      returntypenode := diana.a_name_v(rightchild);
      exprtext(returntypenode, returnval);
      -- ?? returnVal := substr(exprText(diana.a_name_v(rightChild)), 1, 511);
    ELSE
      stext := stext || 'procedure ';
      returnval := NULL;
      assert(nodekind = diana.di_proc);
    END IF;
    IF (pname IS NULL) THEN
      exprtext(leftchild, pname);
    END IF;
    stext := stext || pname;

    rightchild := diana.as_p_(rightchild);
    assert(rightchild IS NOT NULL);
    genparmtext(diana.as_list(rightchild));

    IF (returnval IS NOT NULL) THEN
      IF 0 < instr(flags, '6') AND NOT is_v6_type(returntypenode) 
        THEN RAISE e_notv6compat;
      END IF;
      stext := stext || ' return ' || returnval;
    END IF;
  END genprocspec;

  --------------------
  -- bool_to_int
  --------------------
  FUNCTION bool_to_int(b BOOLEAN) RETURN NUMBER IS
  BEGIN
    IF b THEN
      RETURN 1;
    ELSIF NOT b THEN
      RETURN 0;
    ELSE
      RETURN NULL;
    END IF;
  END bool_to_int;

  --------------------
  -- int_to_bool
  --------------------
  FUNCTION int_to_bool(n NUMBER) RETURN BOOLEAN IS
  BEGIN
    IF n IS NULL THEN
      RETURN NULL;
    ELSIF n = 1 THEN
      RETURN true;
    ELSIF n = 0 THEN
      RETURN false;
    ELSE
      RAISE value_error;
    END IF;
  END int_to_bool;

  procedure diu_node_use_statistics (libunit_node IN ptnod, 
                                     node_count out ub4,
                                     node_limit out ub4);
  pragma interface(c,diu_node_use_statistics);

  procedure diu_attribute_use_statistics (libunit_node IN ptnod,
                                          attribute_count out ub4, 
                                          attribute_limit out ub4);
  pragma interface(c,diu_attribute_use_statistics);

  -- node_use_statistics: reports libunit's node count and limit
  -- 
  -- Parameters:
  -- 
  --   libunit_node : legal ptnod, as returned by get_diana or get_d
  --   node_count   : how many diana nodes the unit contains   
  --   node_limit   : that many diana nodes allowed to allocate
  -- 
  procedure node_use_statistics (libunit_node IN ptnod, 
                                 node_count out ub4,
                                 node_limit out ub4) 
  IS
  BEGIN 
     diu_node_use_statistics(libunit_node, node_count, node_limit);
  END node_use_statistics;
  
  -- attribute_use_statistics: reports libunit's attribute count and limit
  -- 
  -- Parameters:
  -- 
  --   libunit_node       : legal ptnod, as returned by get_diana or get_d
  --   attribute_count   : how many diana attributes the unit contains   
  --   attribute_limit   : that many diana attributes allowed to allocate
  -- 
  procedure attribute_use_statistics (libunit_node IN ptnod,
                                      attribute_count out ub4, 
                                      attribute_limit out ub4)
  IS
  BEGIN 
    diu_attribute_use_statistics
      (libunit_node, attribute_count, attribute_limit);
  END attribute_use_statistics;
  
end diutil;
/

grant execute on diutil to public
/
