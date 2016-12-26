Rem
Rem $Header: dbmssupp.sql 18-nov-98.12:54:10 hbergh Exp $
Rem
Rem dbmssupp.sql
Rem
Rem  Copyright (c) Oracle Corporation 1998. All Rights Reserved.
Rem
Rem    NAME
Rem      dbmssupp.sql - Specification of the DBMS_SUPPORT package
Rem
Rem    DESCRIPTION
Rem      The aim of these procedures is to expose useful functionality while
Rem      keeping a simple user interface for selected operations only.
Rem
Rem    NOTES
Rem      This package should only be installed when requested by Oracle
Rem      Support. It is not documented in the server documentation.
Rem      It is to be used only as directed by Oracle Support.
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    hbergh      11/18/98 -
Rem    hbergh      10/12/98 - dbms_support package
Rem    hbergh      10/12/98 - Created
Rem
create or replace package dbms_support as

  function package_version return varchar2;
  pragma restrict_references (package_version, WNDS, WNPS, RNPS);

  function mysid return number;
  pragma restrict_references (mysid, WNDS, WNPS, RNPS);

  procedure start_trace(waits IN boolean  default TRUE,
                        binds IN boolean  default FALSE);

  procedure stop_trace;

  procedure start_trace_in_session(sid    IN number,
                                   serial IN number,
                                   waits  IN boolean  default TRUE,
                                   binds  IN boolean  default FALSE);

  procedure stop_trace_in_session(sid IN number,
                                  serial IN number);

end dbms_support;
/
@@prvtsupp.plb
