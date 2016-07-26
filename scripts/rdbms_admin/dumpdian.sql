Rem
Rem Copyright (c) 1992, 2008, Oracle and/or its affiliates. All rights reserved.
Rem    NAME
Rem      dumpdian.sql - <one-line expansion of the name>
Rem    DESCRIPTION
Rem      This package allows one to dump Diana out of a database in a human-
Rem      readable format.
Rem    RETURNS
Rem 
Rem    NOTES
Rem      Documentation is available in /vobs/plsql/notes/dumpdiana.txt.
Rem
Rem      Modified from the old ptftrv1 RDBMSQA test to make it more like 'pls
Rem      de=d' 
Rem    MODIFIED   (MM/DD/YY)
Rem     astocks    10/11/08 -  New dumper format
Rem     jmuller    05/10/04  - Fix bug 960764 (sort of): fix up dumpdian so it 
Rem                            runs 
Rem     jmuller    02/11/98 -  Merge to 8.1.
Rem     jmuller    01/23/98 -  node_count now a procedure
Rem     jmuller    01/12/98 -  Add print_format
Rem     jmuller    01/08/98 -  Add dump(nod)
Rem     jmuller    10/09/97 -  Add dump(nod)
Rem     jmuller    04/07/97 -  Reimplement dumpdiana as trusted callout
Rem     jmuller    02/25/97 -  Reimplement Dumpdiana
Rem     jmuller    08/27/96 -  Update: new plan
Rem     jmuller    08/23/96 -  Creation.  A method for dumping Diana out of a 
Rem                            database in a human-readable format.
Rem     jmuller    08/07/96 -  Creation (as dumpdiana)
Rem     usundara   10/02/94 -  merge changes from 1.1.710.1, 1.1.710.2
Rem     usundara   10/01/94 -  Creation
Rem
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
-- NOTE: you must be connected "internal" (i.e. as user SYS) to run this
-- script.
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE
-- NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE NOTICE

-- Create the library where 3GL callouts will reside
CREATE OR REPLACE LIBRARY dumpdiana_lib trusted as static
/
 
----------------------------------------------------------------------------
create or replace package dumpdiana is

-- The three supported output formats are the `traditional' indented tree format, 
-- the flat, ordered list of nodes, and the 'COG' format, also flat
--
-- Constants to distinguish printing formats. Wouldn't enumeration types be nice...
  print_in_order CONSTANT binary_integer := 1;
  print_cog_format CONSTANT binary_integer := 2;
  print_tree_structured CONSTANT binary_integer := 3;

-- Constant to indicate that the format specified on the command line is to
-- be used. (If unspecified, will be structured)
  print_default_format CONSTANT binary_integer := 0;

-- Parameters to the dump procedures are:
--    aName        is the name of the schema-level object to dump, 
--    lu_type      specifies whether the spec or the body is desired (see
--                 package diutil for more information and valid values),
--    nod          is the node which is the root of the tree to be dumped, and
--    print_format specifies which of the standard output formats should be
--                 used: one of the print_* constants above.

-- Various exceptions may be returned if the library unit doesn't exist, 
-- doesn't contain Diana, etc.

-- If an unsupported print_format is specified, the default format will
-- be used instead.


-- Procedure to traverse the diana of a named library unit created by PL/SQL
-- (eg: procedure/function/package-spec/package-body) and output the Diana in
-- human-readable format. 
--
  procedure dump (aName varchar2,
                  lu_type number := sys.diutil.libunit_type_spec,
                  print_format binary_integer := print_default_format);


-- Procedure to traverse the diana rooted at a given node and output the Diana 
-- in human-readable format. This procedure would typically be used in 
-- conjunction with a debugger, which would be used to supply the node value.
--
  procedure dump (nod sys.pidl.ptnod,
                  print_format binary_integer := print_default_format);


-- Procedure to print a count of the number of nodes in the Diana of a named
-- library unit. 
  procedure node_count(aName varchar2,
                       lu_type number := sys.diutil.libunit_type_spec);


-- Procedure to print a count of the number of nodes in the Diana tree
-- containing a given node. 
  procedure node_count(nod sys.pidl.ptnod);


end dumpdiana;
/
----------------------------------------------------------------------------
create or replace package body dumpdiana is

  subtype ptnodnn is sys.pidl.ptnod NOT NULL;

  procedure kkxddmp(compunit ptnodnn, print_format binary_integer) is
  external
  name "kkxddmp"
  parameters (compunit ub4, print_format ub4)
  library dumpdiana_lib;
  
  procedure kkxddnc(compunit ptnodnn) is
  external
  name "kkxddnc"
  parameters (compunit ub4)
  library dumpdiana_lib;
  
  procedure dumpdianan(compunit ptnodnn,
                       print_format binary_integer := print_default_format) is
  begin
    kkxddmp(compunit, print_format);
  end;
  
  procedure node_countn(nod ptnodnn) is
  BEGIN
    kkxddnc(nod);
  END;

  -- Procedure to traverse the diana of a given node.  The node must be procured
  -- from another source (e.g., a debugger.)
  --
  procedure dump (nod sys.pidl.ptnod,
                  print_format binary_integer := print_default_format) is
  begin
    if (nod IS NULL) OR (nod = sys.pidl.TRENULL) then
      sys.dbms_output.put_line('Warning: Null input node to dump().');
    else
      dumpdianan(nod, print_format);
    end if;
  end dump;

  -- get_diana: returns the root of the diana of a libunit, given name and usr.
  --    name will be first folded to upper case if not in quotes, else stripped
  --    of quotes.  will trace synonym links.
  --    IN:  name = subprogram name
  --         usr  = user name
  --         dbname = database name, NULL FOR CURRENT
  --         dbowner = NULL FOR CURRENT
  --         libunit_type = libunit_type_spec FOR spec,
  --                      = libunit_type_body FOR BODY
  --    RETURNS: Diana node.
  --
  FUNCTION get_diana(name VARCHAR2, usr VARCHAR2, dbname VARCHAR2,
                     dbowner VARCHAR2, 
                     libunit_type NUMBER := sys.diutil.libunit_type_spec)
  RETURN sys.pidl.ptnod IS
    compunit sys.pidl.ptnod;
    status   sys.pidl.ub4;
  begin
    -- Get the Diana from KGL
    sys.diutil.get_diana(
      name, usr, dbname,
      dbowner, status, compunit,
      libunit_type);
    if (status <> sys.diutil.s_ok) then
      sys.dbms_output.put_line('Error: couldn''t find diana; status:  ' ||
                           to_char(status));
      raise sys.diutil.e_subpNotFound;
    end if;
    RETURN compunit;
  end get_diana;
  

  procedure dump (aName varchar2,
                  lu_type number := sys.diutil.libunit_type_spec,
                  print_format binary_integer := print_default_format) is
    compunit sys.pidl.ptnod;
  begin
  
    sys.dbms_output.enable(1000000);
  
    sys.dbms_output.put_line('user: ' || user);
  
    -- Get the Diana from KGL
    compunit := get_diana(name=>aName, usr=>user, dbname=>NULL, 
                          dbowner=>NULL, libunit_type=>lu_type);
   
    dump(compunit, print_format);
  end dump;

-- Procedure to print a count of the number of nodes in the Diana of a named
-- library unit. 
  procedure node_count(aName varchar2,
                       lu_type number := sys.diutil.libunit_type_spec) IS
    compunit sys.pidl.ptnod;
  BEGIN
    compunit := get_diana(name=>aName, usr=>user, dbname=>NULL, 
                          dbowner=>NULL, libunit_type=>lu_type);
    node_count(compunit);
  END node_count;

  
-- Procedure to print a count of the number of nodes in the Diana tree
-- containing a given node. 
  procedure node_count(nod sys.pidl.ptnod) IS
  BEGIN
    if (nod IS NULL) OR (nod = sys.pidl.TRENULL) then
      sys.dbms_output.put_line('Warning: Null input node to node_count().');
    else
      node_countn(nod);
    end if;
  END;
  
end dumpdiana;
/
