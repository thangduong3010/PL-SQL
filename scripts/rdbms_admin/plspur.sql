Rem
Rem $Header: plspurity.sql 21-apr-98.19:27:13 nle Exp $
Rem
Rem plspurity.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998. All Rights Reserved.
Rem
Rem    NAME
Rem      plspur.sql - sys_stub_for_purity_analysis definitions
Rem
Rem    DESCRIPTION
Rem      Define package sys_stub_for_purity_analysis.
Rem      As we create the top level subprograms, a dependency between
Rem    the subprogram and this package is formed.  For more info on
Rem    this package, please refer to the document on interop purity
Rem
Rem    NOTES
Rem      This package has to run after the creation of standard and
Rem    before any other creation of top level subprograms.
Rem      Top level subprograms should NOT be defined in standard.sql
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    nle         05/11/98 - change stub package name
Rem    nle         04/27/98 - Created
Rem

create or replace package sys_stub_for_purity_analysis as
  procedure prds;
  pragma restrict_references(prds, wnds, rnps, wnps);

  procedure pwds;
  pragma restrict_references(pwds, rnds, rnps, wnps);

  procedure prps;
  pragma restrict_references(prps, rnds, wnds, wnps);

  procedure pwps;
  pragma restrict_references(pwps, rnds, wnds, rnps);
end sys_stub_for_purity_analysis;
/
show errors;
