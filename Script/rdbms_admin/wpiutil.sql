Rem
Rem $Header: wpiutil.sql 27-feb-2001.15:35:12 nle Exp $
Rem
Rem wpiutil.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      wpiutil.sql - <one-line expansion of the name>
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nle         02/09/01 - Created
Rem

create or replace package sys.wpiutl as
  TYPE tvarchar IS table of varchar2(512) index by binary_integer;
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
show errors;
create or replace package body sys.wpiutl as

  --------------------------------
  -- List of private subprograms
  --------------------------------
  -- Driving the whole process
  PROCEDURE driver(objnum NUMBER, ownerName VARCHAR2, objname VARCHAR2,
                   subname VARCHAR2, pnames IN OUT tvarchar,
                   ptnames IN OUT tvarchar, ptypes IN OUT tvchar3,
                   status OUT PLS_INTEGER, misdef OUT VARCHAR2,
                   nename OUT VARCHAR2);

  -- Find subprograms and describe the parameters
  PROCEDURE describe(objn NUMBER, name VARCHAR2, subname VARCHAR2,
                     usr VARCHAR2, prefix VARCHAR2, pnames tvarchar,
                     ptnames IN OUT tvarchar, ptypes IN OUT tvchar3,
                     status OUT PLS_INTEGER, misdef OUT VARCHAR2,
                     nename OUT VARCHAR2);
  pragma interface(C, describe);  /* first entry of this package ICD */

  -- Normalize names
  FUNCTION normalname(name VARCHAR2) RETURN VARCHAR2;

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
    driver(objnum, prename, name, subname, pnames, ptnames, ptypes,
           status, misdef, nename);
  END;

  PROCEDURE subpparam(objnum NUMBER, name VARCHAR2, subname VARCHAR2,
                      prename VARCHAR2, pnames IN OUT tvarchar,
                      ptnames IN OUT tvarchar, ptypes IN OUT tvchar3,
                      status OUT NUMBER, misdef OUT VARCHAR2,
                      nename OUT VARCHAR2) IS
  BEGIN
    driver(objnum, prename, name, subname, pnames, ptnames, ptypes,
           status, misdef, nename);
  END;

  PROCEDURE subpfparam(objnum NUMBER, name VARCHAR2, subname VARCHAR2,
                       prename VARCHAR2, pnames IN tvarchar,
                       ptnames IN OUT tvarchar, ptypes IN tvchar3,
                       status OUT NUMBER, misdef OUT VARCHAR2,
                       nename OUT VARCHAR2) IS
    vpnames tvarchar;
    vptypes tvchar3;
    tmisdef VARCHAR2(4096);
    tnename VARCHAR2(4096);
    tstatus PLS_INTEGER;
  BEGIN
    vpnames(1) := pnames(2);
    vpnames(2) := pnames(3);
    vptypes(1) := ptypes(2);
    vptypes(2) := ptypes(3);

    driver(objnum, prename, name, subname, vpnames, ptnames, vptypes,
           status, tmisdef, tnename);

    IF (status != s_ok) THEN
      vpnames := pnames;
      vptypes := ptypes;
      driver(objnum, prename, name, subname, vpnames, ptnames, vptypes,
             tstatus, tmisdef, tnename);
      IF (tstatus = s_ok) THEN
        status := tstatus;
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
                   status OUT PLS_INTEGER, misdef OUT VARCHAR2,
                   nename OUT VARCHAR2) IS
    prefix VARCHAR2(32);

  BEGIN
    -- Get the prefix
    IF (ownerName = user) THEN
      -- no need to prefix owner name to types
      prefix := NULL;
    ELSE
      prefix := ownerName || '.';
    END IF;

    -- Normalize name before comparison
    FOR i IN 1..pnames.count LOOP
      pnames(i) := normalname(pnames(i));
    END LOOP;

    describe(objnum, objname, subname, ownerName, prefix,
             pnames, ptnames, ptypes, status, misdef, nename);
  END driver;

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

end;
/
grant execute on sys.wpiutl to public
/
