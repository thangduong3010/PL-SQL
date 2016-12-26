Rem
Rem $Header: wpiutl7.sql 12-apr-98.20:55:26 nle Exp $
Rem
Rem dbmspbx.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998. All Rights Reserved.
Rem
Rem    NAME
Rem     wpiutl.sql - PL/SQL describe API for webdb
Rem
Rem    NOTES
Rem	A portion of this file is copied from diutil.sql.  Because this
Rem	package is specificly for webdb, we didn't want to add its
Rem     functionality into package diutil.sql.  If we ever make these more
Rem     generic, we should merge these code into diutil.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ehlee       03/06/01 - fix optimized fix failed type desc (bug#1658132)
Rem    ehlee       02/20/01 - fix quoted parameters (bug#1644973)
Rem    ehlee       02/20/01 - optimize fix failed type description
Rem    ehlee       02/06/01 - fix failed type description
Rem    nle         10/14/99 - Port wpiutl to 7.x version
Rem
create or replace package sys.wpiutl as
  TYPE tvarchar IS table of varchar2(512) index by binary_integer;
  TYPE tchar3 IS table of CHAR(3) index by binary_integer;
  TYPE tvchar3 IS table of VARCHAR2(3) index by binary_integer;
  SUBTYPE ptnod IS pidl.ptnod;

  -- Constant for errors
  s_ok CONSTANT NUMBER := 0;            -- successful
  s_subpnotfound CONSTANT NUMBER := 1;  -- subprogram NOT found
  s_notinpackage CONSTANT NUMBER := 2;  -- PACKAGE found, proc NOT found
  s_notasub CONSTANT NUMBER := 3;       -- found, but not a subprog
  s_notunique CONSTANT NUMBER := 4;     -- too many matches (overloading error)
  s_nomatch CONSTANT NUMBER := 5;       -- found, but param names not matched
  s_typenotmatch CONSTANT NUMBER := 6;  -- name match, type doesn't match

  -- The following t_ constants can NOT exceed 999
  t_scalar  CONSTANT CHAR(3) := '000';
  t_v7array CONSTANT CHAR(3) := '001';

  -- subpparam: 
  --   IN:  name        name of the subprogram, package, or owner
  --        subname     name of subprogram if not null
  --        prename     name of owner if not null
  --        pnames      names of formal parameter
  --   OUT: ptnames     names of formal parameter types
  --        ptypes      characteristic of the types: scalar, V7_array, ...
  --        status      error code = s_ok           : subprogram found
  --                                 s_subpnotfound : not found in schema
  --                                 s_notinpackage : not found in package
  --                                 s_notasub      : found, but not a subprog
  --                                 s_notunique    : too many matches.
  --                                 s_nomatch      : found, but no match
  --
  -- This function analyzes the following types of names:
  --    <NAME>
  --    <NAME>.<SUBNAME>
  --    <PRENAME>.<NAME>.<SUBNAME>
  -- It resolves overloading subprograms by parameter names (i.e. PNAMES),
  -- and returns types of the parameters that are listed in pnames
  -- <NAME> may not be NULL while prename and subname may.
  -- 
  -- pnames, ptnames, and ptypes are optional.
  --
  PROCEDURE subpparam(objnum NUMBER, name VARCHAR2, subname VARCHAR2,
                      prename VARCHAR2, status OUT NUMBER, misdef OUT VARCHAR2,
                      nename OUT VARCHAR2);
  PROCEDURE subpparam(objnum NUMBER, name VARCHAR2, subname VARCHAR2,
                      prename VARCHAR2, pnames IN OUT tvarchar,
                      ptnames IN OUT tvarchar, ptypes IN OUT tvchar3,
                      status OUT NUMBER, misdef OUT VARCHAR2,
                      nename OUT VARCHAR2);

  -- This is similar to subpparam but used for flexible parameter
  -- Note: different from subpparam, pnames and ptypes are INput only
  PROCEDURE subpfparam(objnum NUMBER, name VARCHAR2, subname VARCHAR2,
                       prename VARCHAR2, pnames IN tvarchar,
                       ptnames IN OUT tvarchar, ptypes IN tvchar3,
                       status OUT NUMBER, misdef OUT VARCHAR2,
                       nename OUT VARCHAR2);
end;
/
create or replace package body sys.wpiutl as
  TYPE tptnod is table of ptnod index by binary_integer;
  TYPE tbool is table of boolean index by binary_integer;
  TYPE tnumber is table of number index by binary_integer;
  owner_prefix VARCHAR2(31);
  package_prefix VARCHAR2(31);

  -- These two variables are used when users pass an array of values
  -- to a scalar parameter
  MatchTypes tvchar3;
  MatchList tptnod;
  MLcnt NUMBER;
  OLnums tnumber;
  CharList tbool;

  -- Error message variables
  missing_defaults VARCHAR2(4096);
  non_exist_names VARCHAR2(4096);
  posterr BOOLEAN;
  posnotunique BOOLEAN; -- flag for posibility of not unique

  --------------------------------
  -- List of private subprograms
  --------------------------------
  -- Driving the whole process
  PROCEDURE driver(objnum NUMBER, ownerName VARCHAR2, objname VARCHAR2,
                   subname VARCHAR2, pnames IN OUT tvarchar,
                   ptnames IN OUT tvarchar, ptypes IN OUT tvchar3,
                   status OUT NUMBER);

  -- Setting error messages
  PROCEDURE setErrMsg(misdef OUT VARCHAR2, nename OUT VARCHAR2);

  -- Find subprograms and describe the parameters
  PROCEDURE describe(objn NUMBER, name VARCHAR2, subname VARCHAR2,
                     usr VARCHAR2, pnames IN OUT tvarchar,
                     ptnames IN OUT tvarchar, ptypes IN OUT tvchar3,
                     status OUT NUMBER);

  -- name of an identifier
  FUNCTION idname(n ptnod) RETURN VARCHAR2;

  -- name of a subprogram
  FUNCTION procname(k ptnod) RETURN VARCHAR2;

  -- name of a type
  FUNCTION typename(k ptnod) RETURN VARCHAR2;

  -- check if a type is a character type
  FUNCTION isCharType(tname VARCHAR2) RETURN BOOLEAN;

  -- read type nodes from a subprog for parameters listed in pnames.
  PROCEDURE getTypeNodes(subnod ptnod, pnames tvarchar,
                         pnodes OUT tptnod);

  -- check if a package subprog has parameter names matching with given names
  FUNCTION ismatched(subnod ptnod, pnames IN OUT tvarchar,
                     pnodes OUT tptnod) RETURN BOOLEAN;

  -- Get types and type names of given parameters (in pnodes)
  PROCEDURE gettypes(pnodes tptnod, ptypes IN OUT tvchar3, objn NUMBER,
                     subname VARCHAR2, olnum NUMBER, pnames tvarchar);
  PROCEDURE gettnames(pnodes tptnod, ptnames IN OUT tvarchar,
                      parent_list pidl.ptseqnd);

  -- Get type and type name of one parameter
  FUNCTION gettname(parnod ptnod, parent_list pidl.ptseqnd) RETURN VARCHAR2;
  FUNCTION gettype(parnod ptnod, objn NUMBER, subname VARCHAR2, olnum NUMBER,
                   pname VARCHAR2) RETURN VARCHAR2;
  FUNCTION descType(objn NUMBER, subname VARCHAR2, olnum number,
                    pname varchar2) RETURN VARCHAR2;

  -- Get text version of all diana nodes
  PROCEDURE exprtext(x ptnod, rv IN OUT VARCHAR2);

  -- Normalize names
  FUNCTION normalname(name VARCHAR2) RETURN VARCHAR2;

  -- enquote special name
  FUNCTION coatname(name VARCHAR2) RETURN VARCHAR2;

  -- Concatenate names into one
  FUNCTION concatNames(prename VARCHAR2, name VARCHAR2, subname VARCHAR2)
    RETURN VARCHAR2;

  ------------------------------------------------------------------------
  --            Public suprogram implementation                         --
  ------------------------------------------------------------------------
  PROCEDURE subpparam(objnum NUMBER, name VARCHAR2, subname VARCHAR2,
                      prename VARCHAR2, status OUT NUMBER, misdef OUT VARCHAR2,
                      nename OUT VARCHAR2) IS
    pnames tvarchar;
    ptnames tvarchar;
    ptypes tvchar3;
  BEGIN
    driver(objnum,prename,name,subname,pnames,ptnames,ptypes,status);
    setErrMsg(misdef, nename);
  END;

  PROCEDURE subpparam(objnum NUMBER, name VARCHAR2, subname VARCHAR2,
                      prename VARCHAR2, pnames IN OUT tvarchar,
                      ptnames IN OUT tvarchar, ptypes IN OUT tvchar3,
                      status OUT NUMBER, misdef OUT VARCHAR2,
                      nename OUT VARCHAR2) IS
  BEGIN
    driver(objnum,prename,name,subname,pnames,ptnames,ptypes,status);
    setErrMsg(misdef, nename);
  END;

  PROCEDURE subpfparam(objnum NUMBER, name VARCHAR2, subname VARCHAR2,
                       prename VARCHAR2, pnames IN tvarchar,
                       ptnames IN OUT tvarchar, ptypes IN tvchar3,
                       status OUT NUMBER, misdef OUT VARCHAR2,
                       nename OUT VARCHAR2) IS
    vpnames tvarchar;
    vptypes tvchar3;
  BEGIN
    vpnames(1) := pnames(2);
    vpnames(2) := pnames(3);
    vptypes(1) := ptypes(2);
    vptypes(2) := ptypes(3);
    
    driver(objnum,prename,name,subname,vpnames,ptnames,vptypes,status);
    setErrMsg(misdef, nename);

    IF (status != s_ok) THEN
      vpnames := pnames;
      vptypes := ptypes;
      driver(objnum,prename,name,subname,vpnames,ptnames,vptypes,status);
      IF (status = s_ok) THEN
        misdef := NULL;
        nename := NULL;
      END IF;
    END IF;
  END;

  ------------------------------------------------------------------------
  --                                                                    --
  --      Private subprogram implementation                             --
  --                                                                    --
  ------------------------------------------------------------------------
  PROCEDURE driver(objnum NUMBER, ownerName VARCHAR2, objname VARCHAR2,
                   subname VARCHAR2, pnames IN OUT tvarchar,
                   ptnames IN OUT tvarchar, ptypes IN OUT tvchar3,
                   status OUT NUMBER) IS
    PROCEDURE setPrefix(prefix VARCHAR2) is
    BEGIN
      IF (prefix = user) THEN
        -- no need to prefix owner name to types
        owner_prefix := NULL;
      ELSE
        owner_prefix := prefix;
      END IF;
    END setPrefix;

  BEGIN
    setPrefix(ownerName);
    missing_defaults := NULL;
    non_exist_names := NULL;
    posterr := TRUE;
    describe(objnum, objname, subname, ownerName, pnames,
             ptnames, ptypes, status);
  END driver;

  PROCEDURE setErrMsg(misdef OUT VARCHAR2, nename OUT VARCHAR2) IS
  BEGIN
    IF (posterr) THEN
      misdef := missing_defaults;
      nename := non_exist_names;
    ELSE
      misdef := NULL;
      nename := NULL;
    END IF;
  END;

  PROCEDURE describe(objn NUMBER, name VARCHAR2, subname VARCHAR2,
                     usr VARCHAR2, pnames IN OUT tvarchar,
                     ptnames IN OUT tvarchar, ptypes IN OUT tvchar3,
                     status OUT NUMBER) is
    oroot ptnod;                -- object root
    subnod ptnod;               -- subprogram tree node
    pnodes tptnod;              -- array of tree nodes for given pnames
    dummy  tptnod;              -- array of tree nodes for given pnames
    fmcnt NUMBER;
    readTypes tvchar3;
    seq pidl.ptseqnd := 0;
    len INTEGER;
    olnum NUMBER;               -- overload number
    found_name boolean;

    di_status diutil.ub4;

    PROCEDURE filterByArrayStatus(nodlis tptnod) IS
      keepbest BOOLEAN := TRUE;
      keepnew  BOOLEAN := TRUE;
      ptype CHAR(3);
      rtype CHAR(3);
      mtype CHAR(3);
    BEGIN
      gettypes(nodlis, readTypes, objn, subname, olnum, pnames);

      -- If this is the first call, assign value and return.
      IF (fmcnt = 0) THEN
        MLcnt := 1;
        MatchList(MLcnt) := subnod;
        OLnums(MLcnt) := olnum;
        FOR i IN 1..ptypes.count LOOP
          IF (ptypes(i) = readTypes(i)) THEN
            MatchTypes(i) := ptypes(i);
          ELSE
            MatchTypes(i) := NULL;
          END IF;
        END LOOP;
        RETURN;
      END IF;

      -- Find the bestmatches sofar
      FOR i IN 1..ptypes.count LOOP
        ptype := ptypes(i);
        mtype := MatchTypes(i);
        rtype := readTypes(i);
        IF (ptype = rtype AND (mtype is NULL OR ptype != mtype)) THEN
          MatchTypes(i) := ptype;
          keepbest := FALSE;
        ELSIF (ptype = mtype AND ptype != rtype) THEN
          keepnew := FALSE;
        END IF;
      END LOOP;

      IF (keepnew != keepbest) THEN
        -- Keep only one of them
        IF (keepnew) THEN
          -- Keep only new one and destroy the current matchlist.
          MLcnt := 1;
          MatchList(MLcnt) := subnod;
          OLnums(MLcnt) := olnum;
        END IF;
      ELSE
        -- Either keep both or destroy both.
        IF (keepnew) THEN
          MLcnt := MLcnt+1;
          MatchList(MLcnt) := subnod;
          OLnums(MLcnt) := olnum;
        ELSE
          MLcnt := 0;
        END IF;
      END IF;
    END;

    PROCEDURE findMatch(nodlis OUT tptnod) IS
    BEGIN
      IF (ismatched(subnod, pnames, nodlis)) THEN
        filterByArrayStatus(nodlis);
        fmcnt := fmcnt+1;
      END IF;
    END;

    PROCEDURE filterByCharType(matchnod OUT ptnod, oln OUT NUMBER) IS
      anod ptnod;
      mb   BOOLEAN;
      nb   BOOLEAN;
      elimbest BOOLEAN;
      elimnew  BOOLEAN;
    BEGIN
      FOR i in 1..MLcnt LOOP
        anod := MatchList(i);
        getTypeNodes(anod, pnames, dummy);
        IF (i = 1) THEN
          gettypes(dummy, MatchTypes, objn, subname, olnum, pnames);
          FOR j IN 1..dummy.count LOOP
            CharList(j) := (MatchTypes(j) = t_scalar) AND
                           (isCharType(gettname(dummy(j),seq)));
          END LOOP;
          matchnod := anod;
          oln := OLnums(i);
        ELSE
          elimbest := FALSE;
          elimnew  := FALSE;
          FOR j IN 1..dummy.count LOOP
            IF (MatchTypes(j) = t_scalar) THEN
              mb := CharList(j);
              nb := isCharType(gettname(dummy(j),seq));
              IF (mb != nb) THEN
                IF (nb) THEN
                  CharList(j) := nb;
                  elimbest := TRUE;
                ELSE
                  elimnew := TRUE;
                END IF;
              END IF;
            END IF;
          END LOOP;

          IF (elimbest != elimnew) THEN
            IF (elimbest) THEN
              matchnod := anod;
              oln := OLnums(i);
            END IF;
          ELSE
            -- since we can only keep one, get rid of both of them
            matchnod := NULL;
          END IF;
        END IF;
      END LOOP;
    END;

  BEGIN
    status := s_ok;

    -- Looking for the object in the schema
    diutil.get_diana(name, usr, NULL, NULL, di_status, oroot,
                     diutil.libunit_type_spec, diutil.load_source_yes);
    IF (oroot is NULL OR oroot = 0) THEN
      status := s_subpnotfound;
      RETURN;
    END IF;

    -- Object is found
    -- Check if it's a subprog and return the type names
    subnod := diana.a_unit_b(oroot);

    -- Normalize name before comparison
    FOR i IN 1..pnames.count LOOP
      pnames(i) := normalname(pnames(i));
    END LOOP;

    IF (subname IS NULL OR subname = '') THEN
      IF (pidl.ptkin(subnod) = diana.d_p_decl) THEN
        status := s_notasub;
      ELSIF (ismatched(subnod, pnames, pnodes)) THEN
        -- No overloading
        gettypes(pnodes, ptypes, objn, NULL, NULL, pnames);
        gettnames(pnodes,ptnames,seq);
      ELSE
        status := s_nomatch;
      END IF;
      RETURN;
    END IF;

    -- search FOR subname among ALL func/proc IN the PACKAGE
    IF (pidl.ptkin(subnod) != diana.d_p_decl) THEN
      status := s_notasub;
      RETURN;
    END IF;

    posnotunique := FALSE;
    package_prefix := name;
    subnod := diana.a_packag(subnod);
    seq := diana.as_list(diana.as_decl1(subnod));
    len := pidl.ptslen(seq) - 1;
    found_name := FALSE;
    olnum := 0;
    MLcnt := 0;
    fmcnt := 0;
    FOR i IN 0..len LOOP
      subnod := pidl.ptgend(seq, i);
      IF (procname(subnod) = subname) THEN
        olnum := olnum+1;
        found_name := TRUE;
        -- If there's already a match, we pass a dummy,
        -- so we won't overwrite pnodes -> optimize the non-overload case
        IF (fmcnt = 0) THEN
          findmatch(pnodes);
        ELSE
          findmatch(dummy);
        END IF;
      END IF;
    END LOOP;

    IF (fmcnt = 0) THEN
      IF (found_name) THEN
        status := s_nomatch;
      ELSE
        status := s_notinpackage;
      END IF;
      RETURN;
    END IF;

    -- No overloading
    IF (fmcnt = 1) THEN
      ptypes := readtypes;
      gettnames(pnodes,ptnames,seq);
      RETURN;
    END IF;

    -- No match for array types
    IF (MLcnt = 0) THEN
      status := s_typenotmatch;
      RETURN;
    END IF;

    IF (MLcnt = 1) THEN
      subnod := MatchList(1);
      olnum := OLnums(1);
    ELSE
      filterByCharType(subnod, olnum);
      IF (subnod is NULL) THEN
        status := s_notunique;
        RETURN;
      END IF;
    END IF;

    getTypeNodes(subnod, pnames, pnodes);
    gettypes(pnodes, ptypes, objn, subname, olnum, pnames);
    gettnames(pnodes,ptnames,seq);
  END describe;

  -----------------------
  -- idname
  -----------------------
  FUNCTION idname(n ptnod) RETURN VARCHAR2 IS
    seq pidl.ptseqnd;
    len BINARY_INTEGER;
  BEGIN
    seq := diana.as_list(n);
    len := pidl.ptslen(seq);
    RETURN normalname(diana.l_symrep(pidl.ptgend(seq, len-1)));
  END idname;

  -----------------------
  -- procname
  -----------------------
  FUNCTION procname(k ptnod) RETURN VARCHAR2 IS
    x ptnod;
    xkind pidl.ptnty;
  BEGIN
    IF (k IS NULL OR k = 0) THEN RETURN NULL; END IF;
    IF (pidl.ptkin(k) != diana.d_s_decl) THEN RETURN NULL; END IF;
    x := diana.a_d_(k);
    xkind := pidl.ptkin(x);
    IF (    xkind != diana.di_funct
        AND xkind != diana.di_proc
        AND xkind != diana.d_def_op) THEN
      RETURN NULL;
    END IF;
    RETURN diana.l_symrep(x);
  END;

  -----------------------
  -- typename
  -----------------------
  FUNCTION typename(k ptnod) RETURN VARCHAR2 IS
    ktype pidl.ptnty;
  BEGIN
    IF (k IS NOT NULL AND k != 0) THEN
      ktype := pidl.ptkin(k);
      IF (ktype = diana.d_type OR ktype = diana.d_subtyp) THEN
        RETURN diana.l_symrep(diana.a_id(k));
      END IF;
    END IF;

    RETURN NULL;
  END;

  -----------------------
  -- ischartype
  -----------------------
  FUNCTION isCharType(tname VARCHAR2) RETURN BOOLEAN IS
  BEGIN
    return (tname LIKE '%CHAR%') OR
           (tname = 'STRING') OR
           (tname = 'LONG') OR
           (tname LIKE '%RAW%') OR
           (tname LIKE '%ROWID');
  END;

  -----------------------
  -- getTypeNodes
  -----------------------
  PROCEDURE getTypeNodes(subnod ptnod, pnames tvarchar,
                         pnodes OUT tptnod) IS
    parseq pidl.ptseqnd;
    parnum NATURAL;
    parnod ptnod;
    parname VARCHAR2(128);
    actnum NATURAL;
  BEGIN
    parseq := diana.as_list(diana.as_p_(diana.a_header(subnod)));
    parnum := pidl.ptslen(parseq);
    actnum := pnames.count;

    FOR j IN 1..actnum LOOP
      FOR i IN 1..parnum LOOP
        parnod := pidl.ptgend(parseq, i-1);
        parname := idname(diana.as_id(parnod));
        IF (parname = pnames(j)) THEN
          pnodes(j) := parnod;
          GOTO found_matched;
        END IF;
      END LOOP;
    <<found_matched>> null;
    END LOOP;
  END;

  -----------------------
  -- ismatched
  -----------------------
  FUNCTION ismatched(subnod ptnod, pnames IN OUT tvarchar,
                     pnodes OUT tptnod) RETURN BOOLEAN IS
    parseq pidl.ptseqnd;
    parnum NATURAL;
    parnod ptnod;
    parname VARCHAR2(128);
    defval ptnod;
    retval boolean := TRUE;
    actnum NATURAL;
  BEGIN
    parseq := diana.as_list(diana.as_p_(diana.a_header(subnod)));
    parnum := pidl.ptslen(parseq);
    actnum := pnames.count;

    IF (missing_defaults IS NOT NULL OR non_exist_names IS NOT NULL) THEN
      posterr := FALSE;
    END IF;

    IF (parnum = 0 AND actnum = 0) THEN
      RETURN TRUE;
    END IF;

    FOR i IN 1..actnum LOOP
      pnodes(i) := 0;
    END LOOP;

    -- First, make sure each formal parameter has an actual value
    FOR i IN 1..parnum LOOP
      parnod := pidl.ptgend(parseq, i-1);
      parname := idname(diana.as_id(parnod));

      FOR j IN 1..actnum LOOP
        IF (parname = pnames(j)) THEN
          pnodes(j) := parnod;
          GOTO found_matched;
        END IF;
      END LOOP;

      defval := diana.a_exp_vo(parnod);
      IF (defval IS NULL OR defval = 0) THEN
        IF (posterr) THEN
          IF (missing_defaults IS NULL) THEN
            missing_defaults := parname;
          ELSE
            missing_defaults := missing_defaults || ',' || parname;
          END IF;
        END IF;
        retval := FALSE;
      END IF;

      <<found_matched>> null;
    END LOOP;

    -- Second, make sure all actual values have associated formal parameters
    FOR i IN 1..actnum LOOP
      IF (pnodes(i) = 0) THEN
        IF (posterr) THEN
          IF (non_exist_names IS NULL) THEN
            non_exist_names := pnames(i);
          ELSE
            non_exist_names := non_exist_names || ',' || pnames(i);
          END IF;
        END IF;
        retval := FALSE;
      END IF;
    END LOOP;

    RETURN retval;
  END;

  -------------------------------
  -- gettypes
  -------------------------------
  PROCEDURE gettypes(pnodes tptnod, ptypes IN OUT tvchar3, objn NUMBER,
                     subname VARCHAR2, olnum NUMBER, pnames tvarchar) IS
    parnum NATURAL;
  BEGIN
    parnum := pnodes.count;
    FOR i IN 1..parnum LOOP
      ptypes(i) := gettype(pnodes(i), objn, subname, olnum, pnames(i));
    END LOOP;
  END;

  -------------------------------
  -- gettnames
  -------------------------------
  PROCEDURE gettnames(pnodes tptnod, ptnames IN OUT tvarchar,
                      parent_list pidl.ptseqnd) IS
    parnum NATURAL;
  BEGIN
    parnum := pnodes.count;
    FOR i IN 1..parnum LOOP
      ptnames(i) := gettname(pnodes(i), parent_list);
    END LOOP;
  END;

  -------------------------------------------------------------------
  -- gettname
  -- This function does name-resolution for two cases:
  --   * var A_TYPE
  --   * var A_OWNER.A_PACK.A_TYPE
  --   For these two case it will look for the package or owner of
  --   the type and prefix the type name with that.
  -- No name-resolution for others. We'll print the type name as is
  -------------------------------------------------------------------
  FUNCTION gettname(parnod ptnod, parent_list pidl.ptseqnd) RETURN VARCHAR2 IS
    tnod ptnod;
    prenod1 ptnod;
    prenod2 ptnod;
    tkind pidl.ptnty;

    name VARCHAR2(512) := NULL;
    typname VARCHAR2(512) := NULL;

    -- Check if a type is defined in the package
    FUNCTION isInPackage(oname VARCHAR2) RETURN BOOLEAN IS
      len NATURAL;
      typnod ptnod;
    BEGIN
      len := pidl.ptslen(parent_list)-1;
      FOR i IN 0..len LOOP
        typnod := pidl.ptgend(parent_list, i);
        IF (typename(typnod) = oname) THEN
          RETURN TRUE;
        END IF;
      END LOOP;
      RETURN FALSE;
    END;

    -- Check if a type is defined in the owner's schema
    FUNCTION isInSchema(oname VARCHAR2) RETURN BOOLEAN IS
      cnt NUMBER;
    BEGIN
      SELECT count(*) INTO cnt FROM all_objects
        WHERE owner=owner_prefix AND object_name=oname;
      IF (cnt = 0) THEN
        RETURN FALSE;
      END IF;
      RETURN TRUE;
    END;

  BEGIN
    tnod := diana.a_name(parnod);

    <<try_again>>
    tkind := pidl.ptkin(tnod);
    -- CASE: (var A_TYPE) 
    IF (tkind = diana.di_u_nam) THEN
      typname := diana.l_symrep(tnod);
      IF (parent_list != 0 AND isInPackage(typname)) THEN
        typname := package_prefix || '.' || typname;
      ELSIF (NOT isInSchema(typname)) THEN
        RETURN typname;
      END IF;
      IF (owner_prefix IS NOT NULL) THEN
        typname := owner_prefix || '.' || typname;
      END IF;

    -- CASE: (var A_PACK.A_TYPE) or (var A_OWNER.A_PACK.A_TYPE) 
    ELSIF (tkind = diana.d_s_ed) THEN
      typname := diana.l_symrep(diana.a_d_char(tnod));
      prenod2 := diana.a_name(tnod);
      tkind := pidl.ptkin(prenod2);

      IF (tkind = diana.di_u_nam) THEN
        name := diana.l_symrep(prenod2);
        typname := name || '.' || typname;
        IF (owner_prefix IS NOT NULL AND isInSchema(name)) THEN
          typname := owner_prefix || '.' || typname;
        END IF;

      ELSIF (tkind = diana.d_s_ed) THEN
        prenod1 := diana.a_name(prenod2);
        IF (pidl.ptkin(prenod1) = diana.di_u_nam) THEN
          typname := diana.l_symrep(prenod1) || '.' ||
                     diana.l_symrep(diana.a_d_char(prenod2)) || '.' ||
                     typname;
        END IF;
      END IF;
    END IF;

    -- OTHER CASES: unknown shape of types; no name resolution
    IF (typname IS NULL) THEN
       exprtext(tnod, typname);
    END IF;

    RETURN typname;
  END;

  ---------------------------------
  -- Get characteristic of the type
  ---------------------------------
  FUNCTION gettype(parnod ptnod, objn NUMBER, subname VARCHAR2, olnum NUMBER,
                   pname VARCHAR2) RETURN VARCHAR2 IS
    tnod ptnod;
    tkind pidl.ptnty;
  BEGIN
    tnod := diana.a_name(parnod);
    tkind := pidl.ptkin(tnod);

    IF (tkind = diana.d_s_ed) THEN
      tnod := diana.a_d_char(tnod);
      tkind := pidl.ptkin(tnod);
    END IF;

    IF (tkind = diana.di_u_nam) THEN
      tnod := diana.s_defn(tnod);

      -- First check for DI_TYPE
      IF (pidl.ptkin(tnod) = diana.di_type AND
          pidl.ptkin(diana.s_t_spec(tnod)) = diana.d_array) THEN
        RETURN t_v7array;
      END IF;

      -- Second check for DI_SUBTY
      IF (pidl.ptkin(tnod) = diana.di_subty) THEN
        tnod := diana.s_t_spec(tnod);
        IF (pidl.ptkin(tnod) = diana.d_constr) THEN
          tnod := diana.s_base_t(tnod);
          IF (pidl.ptkin(tnod) = diana.d_array) THEN
            RETURN t_v7array;
          END IF;
        END IF;
      END IF;

      -- Couldn't find the type in diana, look for it in the database
      IF (tnod = 0) THEN
        RETURN desctype(objn, subname, olnum, pname);
      END IF;
    END IF;

    RETURN t_scalar;
  END;

  -------------------------------------------------------
  -- describe kind of types when it's not granted to user
  -------------------------------------------------------
  FUNCTION descType(objn NUMBER, subname VARCHAR2, olnum number,
                    pname varchar2) RETURN VARCHAR2 IS
    tkind VARCHAR2(4) := t_scalar;
    typnum NUMBER;
  BEGIN
    IF (subname IS NULL) THEN
      SELECT type INTO typnum FROM argument$
        WHERE obj#=objn AND argument=pname;
    ELSE
      BEGIN
        SELECT type INTO typnum FROM argument$
          WHERE obj#=objn AND procedure$=subname AND argument=pname;
      EXCEPTION
        WHEN too_many_rows THEN
          SELECT type INTO typnum FROM argument$
            WHERE obj#=objn AND procedure$=subname AND overload#=olnum
                  AND argument=pname;
      END;
    END IF;

    IF (typnum = 251) THEN
      tkind := t_v7array;
    END IF;

    return tkind;
  END;

  -------------------------------
  -- exprtext:
  --  general unparsing FUNCTION
  -------------------------------
  PROCEDURE exprtext(x ptnod, rv IN OUT VARCHAR2) IS

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
          etext(diana.a_name(n));
          rv := rv || '%';
          etext(diana.a_id(n));

        ELSIF (nkind = diana.d_numeri) THEN
          rv := rv ||  diana.l_numrep(n);

        ELSIF (nkind = diana.d_constr) THEN  -- constraint
          etext(diana.a_name(n));

        ELSE
          rv := '';
        END IF;

      END IF;
    END etext;

  BEGIN -- exprText
    etext(x);
  END exprtext;

  -----------------------
  -- normalname: RETURN a normalized name.
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
    IF (name != upper(name)) THEN
      RETURN '"' || name || '"';
    ELSE
      RETURN name;
    END IF;
  END coatname;

  FUNCTION concatNames(prename VARCHAR2, name VARCHAR2, subname VARCHAR2)
  RETURN VARCHAR2 AS
    fullname VARCHAR2(128) := NULL;
  BEGIN
    IF (subname IS NOT NULL) THEN
      fullname := subname;
    END IF;
    IF (name IS NOT NULL) THEN
      IF (fullname IS NOT NULL) THEN
        fullname := name || '.' || fullname;
      ELSE
        fullname := name;
      END IF;
    END IF;
    IF (prename IS NOT NULL) THEN
      IF (fullname IS NOT NULL) THEN
        fullname := prename || '.' || fullname;
      ELSE
        fullname := prename;
      END IF;
    END IF;
    RETURN fullname;
  END;

END;
/
show errors;
grant execute on sys.wpiutl to public
/
